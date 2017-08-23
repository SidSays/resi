/*=====================================================================
* Get Next Case Offering
* Version         2.0
* Author          Trevor Scott <tscott@salesforce.com>
*                 Ryan Mccullough <rmccullough@salesforce.com>
*                 Hao Dong <hdong@salesforce.com>
*                 Derek Anderson <derek.anderson@salesforce.com>
*                 Binod Kumar <binod@comitydesigns.com>
*
* Usage           The Get Next Case offering allows agents to click a button on the console component and pull the next
*                 case from queues they are assigned to
*                  - One click custom footer component
*                  - Three levels of queue/group hierarchy
*                  - Case priority is determined by case.SFPS_GNC_PriorityLeve__c, 
*                    then case.SFPS_GNC_PriorityDate__c that defaults to case creation date
*                  - Allows declartive configuration on overwrite priority data field
*
* Component       SFPS_GNC_GetNextCase.cls - Actions related to Get Next Case
*                 SFPS_GNC_GetNextCaseTest.cls - Test class for Get Next Case actions
*                 SFPS_GNC_GetNextCase.page - Visualforce Page for Custom Console Component
*                 SFPS_GNC_CSS.resource - stylesheets
*                 SFPS_GNC_GetNextCase.customApplicationComponent - Custom Console Component
*                 SFPS_GNC_[...] Custom Labels - Various custom labels
*
* Change Log      v0.1  Trevor Scott - "Next In Queue" demo component (https://org62.my.salesforce.com/a2x30000002eB16)
*                 v0.9  Ryan Mccullough - Initial Version
*                 v1.0  Hao Dong, Derek Anderson
*                       Various UI update
*                       Support console toolkit API v34.0
*                       Support case open as sub tab defined in app setting
*                       Add Priority Date custom field on Case to support declarative configuration on routing priority
*                 v1.12 Hao Dong, Derek Anderson, Binod Kumar
*                       Add priority level case field to support different priority by queue 
*                       Workflow rule to set default priority date
*                       Support Role as queue membership (Not Role and Subordinates) 
*                       Support up to three levels of queue, group, and role as membership hierarchy
*                 v2.0  Hao Dong
*                       Support Skill based pull, with profile based settings. 
*                       Support both ProfileSkill and FSO__Skill__c object
*
* Last Modified   03/22/2016
=====================================================================*/
public class SFPS_GNC_GetNextCase
{
    public Boolean NoSearches { get; set; }
    public String CaseIdAssigned { get; set; }
    public String CaseNumberAssigned { get; set; }
    public String CasePreviousQueue { get; set; }
    public String CaseSkill { get; set; }
    public String ErrorMessage { get; set; }
    public Integer AutoCloseDelay { get; set; }

    public Boolean SkillFilter { get; set; }
    public Set<String> SkillSet { get; set; }

    //public SFPS_GNC_SETTINGS__c sfps_gnc_settings {get {return SFPS_GNC_SETTINGS__c.getInstance();} set;}

    public SFPS_GNC_GetNextCase()
    {
        System.debug('SFPS_GNC - SFPS_GNC_GetNextCase() entered');
        this.NoSearches = true;
        this.AutoCloseDelay = 5;
        this.SkillFilter = false;
        this.SkillSet = new Set<String>();
    }

    public void GetSkills()
    {
        SFPS_GNC_SETTINGS__c sfps_gnc_settings = SFPS_GNC_SETTINGS__c.getInstance();
        boolean sbr_enabled = sfps_gnc_settings.SBR_Enabled__c;
        boolean sbr_include_unspecified = sfps_gnc_settings.SBR_Include_Unspecified__c;
        String sbr_skill_object = sfps_gnc_settings.SBR_Skill_Object__c;

        this.SkillFilter = false;
        this.SkillSet = new Set<String>();

        if (sbr_enabled)
        {
            SkillFilter = true;
            String sQuery = '';
            if (sbr_skill_object == 'ProfileSkill')
                sQuery = 'SELECT Name FROM ProfileSkill WHERE Id in (Select ProfileSkillId from ProfileSkillUser Where UserId = \'' + UserInfo.getUserId() + '\')';
            else if (sbr_skill_object == 'FSO__Skill__c')
                sQuery = 'SELECT Name FROM FSO__Skill__c WHERE Id in (Select FSO__Skill__c from FSO__SkillUser__c Where FSO__User__c = \'' + UserInfo.getUserId() + '\')';

            System.debug('SFPS_GNC - Retrieving My Skills Query: ' + sQuery);

            if (sQuery != Null)
            {
                Set<SObject> SkillRecords = new Set<SObject>();
                
                this.SkillSet = new Set<String>();
                SkillRecords = new Set<SObject> (Database.query(sQuery));

                System.debug('SFPS_GNC - Retrieving my skills object: ' + SkillRecords);

                for (SObject skillRecord : SkillRecords)
                {
                    this.SkillSet.add(String.valueOf(skillRecord.get('Name')));
                }

                if (sbr_include_unspecified)
                    this.SkillSet.add('Unspecified');

                System.debug('SFPS_GNC - Retrieving my skills Set: ' + SkillSet);
            }
        }
    }

    public void AssignNextRecord()
    {
        try
        {
            System.debug('SFPS_GNC - Retrieving Group Memberships of type \'Queue\' for User Id: ' + UserInfo.getUserId());

            // flip the "No Searches" flag
            this.NoSearches = false;

            // clear the assigned vals
            this.CaseIdAssigned = null;
            this.CaseNumberAssigned = null;
            this.CasePreviousQueue = null;
            this.ErrorMessage = null;

            // Get the group records where the Related Id = the users's role
            Set<Id> PublicGroups = new Set<Id>();
            if(UserInfo.getUserRoleId() != null)
            {
                for (Group grp : [SELECT Id, RelatedId, Type 
                                  FROM Group 
                                  Where RelatedId = :UserInfo.getUserRoleId()])
                {
                   PublicGroups.add(grp.Id);
                }
            }

            System.debug('SFPS_GNC - Retrieving Role Related Group Ids::' + PublicGroups);

            // Get the public groups to which the current user is part of
            for (GroupMember mem : [SELECT GroupId, Group.Type, UserOrGroupId 
                                    FROM GroupMember 
                                    WHERE UserOrGroupId = :UserInfo.getUserId() AND Group.Type = 'Regular'])
            {
                PublicGroups.add(mem.GroupId);
            }

            // Get one level up of public groups (if any) associated with the PublicGroup Ids
            for (GroupMember mem : [SELECT GroupId, Group.Type, UserOrGroupId 
                                    FROM GroupMember 
                                    WHERE (UserOrGroupId IN :PublicGroups AND Group.Type = 'Regular')])
            {
                PublicGroups.add(mem.GroupId);
            }

            // Pick the queues that are associated with the public groups and for ones where the user is a direct queue member
            List<GroupMember> GroupMemberships = [SELECT GroupId, Group.Name 
                                                  FROM GroupMember 
                                                  WHERE Group.Type = 'Queue' 
                                                  AND (UserOrGroupId = :UserInfo.getUserId() 
                                                  OR UserOrGroupId IN :PublicGroups)];

            System.debug('User (' + UserInfo.getUserId() + ') Is a Member of these groups: ' + GroupMemberships);

            // put the group memberships into a map where the Key is the Group Id
            Map<Id, GroupMember> GroupIdToMember = new Map<Id, GroupMember>();
            for (GroupMember GroupMembership : GroupMemberships)
            {
                GroupIdToMember.put(GroupMembership.GroupId, GroupMembership);
            }
            System.debug('SFPS_GNC - Group Memberships: ' + GroupIdToMember.keySet());

            GetSkills();

            // default next case to null
            Case NextCase = null;

            // get the next case for those queues sorted by SFPS_GNC_PriorityDate__c
            // The system will pick a bucket of cases (say 5) and attempt to lock one by one and
            // whichever is successful will be returned to the front end
            List<Case> cases = new List<Case>();
            System.debug('SFPS_GNC - Skill Filter: ' + SkillFilter);
            System.debug('SFPS_GNC - Skill Set: ' + SkillSet);
                
            if (SkillFilter)
            {
                if (SkillSet.size() > 0)
                    cases = [SELECT Id, OwnerId, CaseNumber, Owner.Name, SFPS_GNC_SkillName__c FROM Case
                        WHERE OwnerId IN :GroupIdToMember.keySet() AND SFPS_GNC_SkillName__c in :SkillSet AND IsClosed = false
                        ORDER BY SFPS_GNC_PriorityLevel__c ASC NULLS LAST, SFPS_GNC_PriorityDate__c ASC LIMIT 5];
            }
            else
                cases = [SELECT Id, OwnerId, CaseNumber, Owner.Name, SFPS_GNC_SkillName__c FROM Case
                    WHERE OwnerId IN :GroupIdToMember.keySet() AND IsClosed = false
                    ORDER BY SFPS_GNC_PriorityLevel__c ASC NULLS LAST, SFPS_GNC_PriorityDate__c ASC LIMIT 5];

            for (Case c : cases)
            {
                System.debug('SFPS_GNC - Attemping to lock Case Number: ' + c.CaseNumber + ', Id: ' + c.Id);
                // Attempt to lock the case
                try
                {
                    // Confirm that the case is still in the queue and Lock it
                    NextCase = [SELECT Id, OwnerId, CaseNumber, Owner.Name, SFPS_GNC_SkillName__c FROM Case WHERE Id =: c.Id AND OwnerId =: c.OwnerId FOR UPDATE];
                    System.debug('SFPS_GNC - Case should be locked here.');
                    String sQueueName = NextCase.Owner.Name;

                    NextCase.OwnerId = UserInfo.getUserId();
                    NextCase.SFPS_GNC_LastAssigned__c = DateTime.now();
                    update NextCase;
                    System.debug('SFPS_GNC - Case has been updated.');

                    // Fetch again to make sure one, that you are still the owner and second, the previous queue information
                    //NextCase = [SELECT Id, OwnerId, CaseNumber, Last_Assigned_Queue__c FROM Case WHERE Id =: c.Id AND OwnerId =: UserInfo.getUserId()];
                    NextCase = [SELECT Id, OwnerId, CaseNumber, SFPS_GNC_SkillName__c FROM Case WHERE Id =: c.Id AND OwnerId =: UserInfo.getUserId()];
                    System.debug('Updated case owner: ' + NextCase.OwnerId + ', current user Id: ' + UserInfo.getUserId());

                    // assign next case to current user and store some info about the case in public vars for the page
                    this.CasePreviousQueue = sQueueName;
                    this.CaseSkill = NextCase.SFPS_GNC_SkillName__c;
                    this.CaseNumberAssigned = NextCase.CaseNumber;
                    this.CaseIdAssigned = NextCase.Id;

                    // exit the for loop if we re-assigned the case
                    break;
                }
                catch (Exception e)
                {
                    this.ErrorMessage = e.getMessage();
                    System.debug(LoggingLevel.ERROR, 'SFPS_GNC - Could not re-assign case. Exception: ' + e);
                    // Any exceptions including Lock, Dont do anything and just move to the record case record.
                    NextCase = null;
                }
            }
            System.debug('SFPS_GNC - Next Case: ' + NextCase);
        }
        catch (Exception e)
        {
            this.ErrorMessage = e.getMessage() + ' ' + e.getLineNumber();
            System.debug(LoggingLevel.ERROR, e.getMessage());
        }
    }
}