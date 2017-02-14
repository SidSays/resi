/***************************************************************************************************************************************
 * Author     : Apurva Gandhi, Accenture
 * Date       : 20/12/2013
 * Description: This class handels logic to update All team member field on Team object,which is in turn used in creation of  Plan list views.
 * History
     Version             : 1.0
     Author Last Updated : Apurva Gandhi, Accenture
     PROJECT             : Direct Sales
***************************************************************************************************************************************/
public Class TeamMemberTriggerController{
 /**
    * @Author: Apurva Gandhi, Accenture
    * @Description: This method is called upon before insert, afterupdate,beforedelete and afterundelete triggers on Teammember object. based on the events it populates the All team member field on Team object
    * @Request id:457 (My Teams Plans list view Creation)
    * @Date: 20-Dec-2013
    * @Param: NewList,OldMap
    * @Return: void.
    */
    public void updateAllTeamMember(List<Team_Member__C> newMembersList,Map<id,Team_Member__C>oldMembersMap){
        String allTeamMemberString='';
        Map<id,team__c> updatedTeamMap = new map<id,team__c>();
        set<id> teamIds = new set<id>();
        set<id> oldTeamIds = new set<id>();
        if(trigger.isDelete){
            for (Team_Member__c t :oldMembersMap.values()){
                oldTeamIds.add(t.team__c);
            }
            for(Team__c t:[Select id, All_Team_Members__c from Team__c  where id in:oldTeamIds]){
                for(Team_Member__c u :oldMembersMap.values()){
                    if(u.Team__c == t.id){
                        if(t.All_Team_Members__c!=null){
                            String existingAllTeamMembers =(String)(t.All_Team_Members__c);
                            String delUserId=((String)(u.user_name__C)).substring(0,15);
                            if((existingAllTeamMembers.contains(delUserId))){
                                String str = existingAllTeamMembers.remove(delUserId);
                                t.All_Team_Members__c=str; 
                                updatedTeamMap.put(t.id,t);
                            }
                        }
                    }
                }
            }
        }else{
            for (Team_Member__c t :newMembersList){
                teamIds.add(t.team__c);
            }
            for(Team__c t:[Select id, All_Team_Members__c from Team__c where id in :teamIds]){
                for(Team_Member__c u:newMembersList){
                    if(u.Team__c == t.id){                                                            
                      if(trigger.isUpdate){
                            if(t.All_Team_Members__c!=null){
                                String oldUserId=((String)(oldMembersMap.get(u.id).user_name__C)).substring(0,15);
                                String newUserId=((String)(u.user_name__C)).substring(0,15);
                                String allTeamMemString = (String)(t.All_Team_Members__c);
                                if(allTeamMemString.contains(oldUserId)){
                                    String str=allTeamMemString.replace(oldUserId,newUserId);
                                    t.All_Team_Members__c=str; 
                                }
                                else{
                                    t.All_Team_Members__c = t.All_Team_Members__c+','+newUserId ;
                                }
                                updatedTeamMap.put(t.id,t);
                            }
                        }
                        else{ 
                            if(u.User_Name__c!=null){
                                allTeamMemberString =','+((String)u.user_name__c).substring(0,15);
                                if(t.All_Team_Members__c==null){
                                    t.All_Team_Members__c='';
                                }
                                t.All_Team_Members__c = t.All_Team_Members__c+ allTeamMemberString;
                                updatedTeamMap.put(t.id,t);
                                }else{
                                    u.User_Name__c.addError('Please enter a User Name!');
                                }
                        }
                    }
                }
            }
        }
        if(!updatedTeamMap.IsEmpty()){
            try{
                update updatedTeamMap.values();
            }catch(System.DmlException e){
                for (Integer i = 0; i < e.getNumDml(); i++){
                    // Process exception here
                    System.debug(e.getDmlMessage(i)); 
                }
            }
        }
    }
}