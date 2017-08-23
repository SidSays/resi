/**************************************************************
* Class Name : AddTeamMemberController
* Author : Amit Kumar Pradhan, Accenture
* Date : 31-May-2017
* Description : This class is Controller extension of "AddPropertyEventTeamMembers" visualforce page.
* User Story : US1071692(XC Property Events: Improve Team Member Workflow)
* Modifiled By: Deepika Jain Naresh, Accenture, US1072089-  XC Property Events: Team Member Phone
* @Last modified By: Lavanya Hosbet
* @Last modified Date: 26-Jun-2017 
* @Description : Need to be able to view 25 records at a time when searching for Team members to add to an event and see more records if needed
* @User Story : US1123523 - Property Event - Team Member Pagination
* @Last modified By: Deepika Jain, Accenture
* @Last modified Date: 13-July-2017 
* @Description : Update the user or contact phone when phone is updated in property event team member page. 
* @User Story : US1141203(XC Property Event - Team Member phone) -Lavanya
***************************************************************/
public class AddTeamMemberController{
    //Initialization of constant variable
    private static final String USER_AGENT = 'USER-AGENT';
    private static final String IPHONE = 'iPhone';
    private static final String IPAD = 'iPad';
    private static final String XFINITY_RECORD_TYPE_NAME = 'Xfinity Record Type';
    private static final String CAR_CONTACT_RECORD_TYPE_NAME = 'CAR Contact';
    private static final String PROPERTY_EVENT_PARAM_NAME = 'propEventId';
    private static final String AMPERSAND_STRING = '%';
    private static final String BLANK_STRING = '';
    private static final String SPACE_WITH_COMMA = ', ';
    private static final String SLASH_STRING = '/';
    private static final String SPACE = ' ';
    private static final String CS_COMCAST_ACCOUNT = 'PropertyEventComcastAccountID';
    private static final String PAGINATION_SIZE = 'PaginationSize';
    
    //Class Variable
    public String comcastAccountId = BLANK_STRING;
    public List<Property_Event_Team_Member__c> teamMemberList = new List<Property_Event_Team_Member__c>();
    public Map<String, String> emailVsContactIdMap = new Map<String, String>();
    public Set<String> emailIdSet = new Set<String>();    
    public String accountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(XFINITY_RECORD_TYPE_NAME).getRecordTypeId();
    public String contactRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(CAR_CONTACT_RECORD_TYPE_NAME).getRecordTypeId();
    public Boolean isSF1 = false;
    public Integer totalRecord = 0;
    public String propEventId = BLANK_STRING;
    public String userRegion = BLANK_STRING;
    
    //Getter Setter variable.   
    public String fName{get;set;}       
    public String lName{get; set;}
    public List<UserORContactWrapper> userORContactDetails{get; set;}
    public Integer recordSize{get;set;}
    public String selectedRecordId{get;set;}    
    public String contactFirstName{get;set;}       
    public String contactLastName{get; set;}
    public String contactEmail{get; set;}
    public String contactPhone{get; set;}
    public Boolean showAddContactSec{get; set;}
    public Boolean showAddTeamMemberSec{get; set;}
    public Boolean isSearchComplete{get; set;}
    public String existingContactId{ get; set;}
    public Boolean isValidation{get; set;}  
    
    public Integer pageSize{get; set;}
    public Map<Integer, List<UserORContactWrapper>> userOrContactMap = new Map<Integer, List<UserORContactWrapper>>();  
    public Integer pageNumber = 1;
    public Integer noOfPages = 1;
    
    /*********************************************    
    * @Description : Constructor for AddTeamMemberController
                    1.Initialization of variable.
                    2.Check for SF1 or not.
                    3.Current user Region
                    4.Fetching email id of Team Member and contact records 
                        which will be used while filtering the search list/validation
    * @Author : Amit Kumar Pradhan, Accenture    
    * @Date : 31-May-2017 
    * @User Story : US1071692(XC Property Events: Improve Team Member Workflow)
    * @Last modified By: Lavanya Hosbet
    * @Last modified Date: 26-Jun-2017 
    * @Description : Reset Offset and pageSize for Pagination on team member search
    * @User Story : US1123523 - Property Event - Team Member Pagination
    * @Param : ApexPages.StandardController    
    **********************************************/ 
    public AddTeamMemberController(ApexPages.StandardController controller){
        try{
            //Initialization of variable
            userORContactDetails = new List<UserORContactWrapper>();        
            resetFlag();
            //Logic to find out wheather property event team member is created from SF1 or SFDC.        
            String userAgent = ApexPages.currentPage().getHeaders().get(USER_AGENT);        
            if(userAgent.contains(IPHONE) || userAgent.contains(IPAD) ){
                //Getting propEventId from controller.
                Property_Events__c propEvent = (Property_Events__c)controller.getRecord();
                if(propEvent != null){
                    propEventId = propEvent.Id;
                }
                isSF1 = true;
            }else{
                //Getting propEventId from current page parameter.
                propEventId = apexpages.currentpage().getparameters().get(PROPERTY_EVENT_PARAM_NAME);
                isSF1 = false;
            }
            //Getting comcast account id from Variable_Setting__c
            Variable_Setting__c comcastAccountCS = Variable_Setting__c.getInstance(CS_COMCAST_ACCOUNT);
            if(comcastAccountCS != null){
                comcastAccountId = comcastAccountCS.Value__c;
            }
            //Creating set of email id for property event team member that is associated with current property event.
            //Which will be using while filtering the search records.
            for(Property_Event_Team_Member__c teamMember : [SELECT User_Email__c FROM Property_Event_Team_Member__c 
                                                                WHERE Property_Event__c =: propEventId 
                                                                LIMIT : (Limits.getLimitQueryRows()-Limits.getQueryRows())]){
                emailIdSet.add(String.valueOf(teamMember.User_Email__c).toLowerCase());
            }
            
            //Creating Map of email-contactid of contact records.(Map is used becase) 
            //Which will be using to validate and restrict creation of duplicate contact.
            for(Contact contactRecord : [SELECT Id, FirstName, LastName, Email FROM Contact 
                                            WHERE AccountId =: comcastAccountId 
                                            LIMIT : (Limits.getLimitQueryRows()-Limits.getQueryRows())]){
                emailVsContactIdMap.put(contactRecord.Email.toLowerCase(), contactRecord.Id);
            }
            //Fetching current user region.
            List<User> currentUser = [SELECT Id, Region__c FROM User WHERE Id =: UserInfo.getUserId() LIMIT 1];
            if(currentUser != null && !currentUser.isEmpty() && currentUser[0].Region__c != null){
                userRegion = currentUser[0].Region__c;
            }
            
            //US1123523 : Reset the Limit Size and OffsetSize for Pagination on Team member search
            Variable_Setting__c paginationSize = Variable_Setting__c.getInstance(PAGINATION_SIZE);
            if(paginationSize != null){
                pageSize = Integer.valueOf(paginationSize.Value__c);
            }
            //pageSize = 25;
            pageNumber = 1;
            noOfPages = 1;
        }catch(Exception ex){
            isValidation = true;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,Label.PESomeThingWentWrong));
        }   
    }
    
    /*********************************************    
    * @Description : userORContactSearch method for searching contact and active user                   
    * @Author : Amit Kumar Pradhan, Accenture    
    * @Date : 31-May-2017 
    * @User Story : US1071692(XC Property Events: Improve Team Member Workflow)
    * @Last modified By: Lavanya Hosbet
    * @Last modified Date: 26-Jun-2017 
    * @Description : Modified method to fetch 25 contacts or users at a time for pagination
    * @User Story : US1123523 - Property Event - Team Member Pagination
    * @Param : void 
    * @Return : PageReference
    **********************************************/     
    public PageReference userORContactSearch(){
        try{
            resetFlag();//Reseting all flag variable.
            //Error message if length of first name(search) is less then 3
            if(fName.length()!=null && fName.length() < 3){
                isValidation = true;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,Label.PEMinimumSearchString));                                         
            }else{
                isValidation = false;               
                isSearchComplete = true;//set isSearchComplete = true
                List<UserORContactWrapper> userORContact = new List<UserORContactWrapper>();            
                String firstNameStr = fName + AMPERSAND_STRING;
                String lastNameStr = lName + AMPERSAND_STRING;
                /******
                Currently we have put the limit(499-configurable) for both query user and contact as 
                there is no pagination implemented to avoid view state error. 
                After pagination is implemented we can remove this limit.
                *******/
                Integer userLimit = 499;
                if(System.Label.PEUserLimit!=null && System.Label.PEUserLimit.isNumeric()){
                    userLimit = Integer.valueOf(System.Label.PEUserLimit);
                }
                
                Integer contactLimit = 499;
                if(System.Label.PEContactLimit !=null && System.Label.PEContactLimit.isNumeric()){
                    contactLimit = Integer.valueOf(System.Label.PEContactLimit);
                }
                
                /*
                //Fixed nova suite violation.
                //Search User list as per First name and last name.
                List<User> searchUsers = [SELECT Id, FirstName, LastName, Email FROM User 
                                            WHERE isActive = True AND Region__c =: userRegion 
                                            AND FirstName LIKE : firstNameStr 
                                            AND LastName LIKE: lastNameStr LIMIT :userLimit];
                //Search User list as per Last name and last name.                          
                List<Contact> searchContacts = [SELECT Id, FirstName, LastName, Email FROM Contact 
                                                WHERE (FirstName LIKE : firstNameStr AND LastName LIKE : lastNameStr) 
                                                AND AccountId =: comcastAccountId LIMIT :contactLimit];
                */
                //US1123523 : initialize variables for pagination
                Variable_Setting__c paginationSize = Variable_Setting__c.getInstance(PAGINATION_SIZE);
                if(paginationSize != null){
                    pageSize = Integer.valueOf(paginationSize.Value__c);
                }
                Integer i = 0;
                pageNumber =1;
                noOfPages = 1;
                List<UserORContactWrapper> tempUserORContact = new List<UserORContactWrapper>(); 
                
                //Userlist added in wrapper
                for(User userObj : [SELECT Id, FirstName, LastName, Email, MobilePhone FROM User 
                                        WHERE isActive = True AND Region__c =: userRegion AND FirstName LIKE : firstNameStr 
                                        AND LastName LIKE: lastNameStr LIMIT : (Limits.getLimitQueryRows()-Limits.getQueryRows())]){
                    if(!emailIdSet.contains(userObj.Email)){
                        UserORContactWrapper userWrapper = new UserORContactWrapper(userObj);
                        userORContact.add(userWrapper);
                    }
                }
                //Contactlist added in wrapper
                for(Contact contactObj : [SELECT Id, FirstName, LastName, Email, MobilePhone FROM Contact 
                                            WHERE (FirstName LIKE : firstNameStr AND LastName LIKE : lastNameStr) 
                                            AND AccountId =: comcastAccountId LIMIT :(Limits.getLimitQueryRows()-Limits.getQueryRows())]){
                    if(!emailIdSet.contains(contactObj.Email)){
                        UserORContactWrapper contactWrapper = new UserORContactWrapper(contactObj);
                        userORContact.add(contactWrapper);
                    }
                }
                //Put wrapper list in userORContactDetails
                //userORContactDetails = userORContact;
                totalRecord = userORContact.size();
                
                ////US1123523 : if number of records returned is lesser than the pagination limit, display all records. If not, display the first 25 records on page load
                if(totalRecord <= pageSize){
                    userOrContactMap.put(pageNumber, userORContact);
                } else {
                    recordSize = pageSize;
                    for(UserORContactWrapper userOrCon : userORContact){
                        //add records to temp list
                        tempUserORContact.add(userOrCon);
                        i++;
                        if(i == pageSize){
                            // add 25 records at a time into the map
                            userOrContactMap.put(pageNumber, tempUserORContact);
                            tempUserORContact = new List<UserORContactWrapper>();
                            i = 0;
                            //increment the page number and the count of pages
                            pageNumber++;
                            noOfPages++;
                        }
                    }
                    if(!tempUserORContact.isEmpty()){
                        userOrContactMap.put(pageNumber, tempUserORContact);
                        noOfPages++;
                    }
                }
                //reset the page number to 1 to display the first 25 results
                pageNumber = 1;
                userORContactDetails = userOrContactMap.get(pageNumber);
                recordSize = userORContactDetails.size();
                //US1123523 : end
                
                
                if(recordSize == 0){
                    showAddContactSec = true;
                }else{
                    showAddTeamMemberSec = true;
                }     
            }
        }catch(Exception ex){isValidation = true;ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,Label.PESomeThingWentWrong));} 
        return null;            
    }
    
    /*********************************************    
    * @Description : addTeamMember method to add new property event team member to a property event.                
    * @Author : Amit Kumar Pradhan, Accenture    
    * @Date : 31-May-2017 
    * @User Story : US1071692(XC Property Events: Improve Team Member Workflow)
    * @Param : void 
    * @Return : PageReference
    **********************************************/     
    public PageReference addTeamMember(){
        try{
            //Error message if user is not selected any record and click on add team member button.
            if(selectedRecordId == BLANK_STRING){
                isValidation = true;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,Label.PESelectOneRecord ));         
            }else{
                isValidation = false;
                //Logic for getting selected wrapper from wrapper list.
                UserORContactWrapper selectedUserORContact = new UserORContactWrapper();
                if(selectedRecordId != null){
                    for(UserORContactWrapper userORContact : userORContactDetails){
                        if(userORContact.id == selectedRecordId){
                            selectedUserORContact = userORContact;
                        }
                    }
                }   
                
                if(selectedRecordId != null && propEventId != BLANK_STRING){
                    //Create new property Event team Member record
                    Property_Event_Team_Member__c teamMember = new Property_Event_Team_Member__c();
                    teamMember.Name = selectedUserORContact.firstName + SPACE + selectedUserORContact.lastName;     
                    teamMember.Property_Event__c = propEventId;
                    if(selectedUserORContact.isSalesforceUser){
                        teamMember.Team_Member__c = selectedUserORContact.id;
                    }else{
                        teamMember.Contact__c = selectedUserORContact.id;
                    } 
                    teamMember.Mobile_Phone__c = selectedUserORContact.mobilePhone;  //adding as part of US1072089
                    teamMember.Email__c = selectedUserORContact.email;
                    Database.insert(teamMember);
                    if(!isSF1){
                        //Redirect to property event record list after creation of property Event team Member record in SFDC.
                        String pageReference = URL.getSalesforceBaseUrl().toExternalForm() + SLASH_STRING + propEventId;
                        PageReference pageRef = new PageReference(pageReference);
                        pageRef.setredirect(true);
                        return pageRef;
                    }else{
                        return null;
                    }
                }
                else{
                    return null;
                }
            }
        }catch(Exception ex){isValidation = true;ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,Label.PESomeThingWentWrong));}
        return null;
    }
    
    /*********************************************    
    * @Description : createNewContact method to add new property event team member to a property event and 
                    create a new contact and associate with comcast account from add new contact section if search result is not found              
    * @Author : Amit Kumar Pradhan, Accenture    
    * @Date : 31-May-2017 
    * @User Story : US1071692(XC Property Events: Improve Team Member Workflow)
    * @Param : void 
    * @Return : PageReference
    **********************************************/ 
    public PageReference createNewContact(){
        try{
            String errorMsg = BLANK_STRING;
            //Error message if mandetory field is not filled out(first name, last name, email, phone).
            if(contactFirstName == BLANK_STRING || contactLastName == BLANK_STRING || contactEmail == BLANK_STRING || contactPhone == BLANK_STRING){
                if(contactFirstName == BLANK_STRING){
                    errorMsg += Label.PEFirstNameErrorMsgBody;
                }
                
                if(contactLastName == BLANK_STRING){
                    if(errorMsg != BLANK_STRING){
                        errorMsg += SPACE_WITH_COMMA;
                    }
                    errorMsg += Label.PELastNameErrorMsgBody;
                }
                if(contactEmail == BLANK_STRING){
                    if(errorMsg != BLANK_STRING){
                        errorMsg += SPACE_WITH_COMMA;
                    }
                    errorMsg += Label.PEEmailErrorMsgBody;
                }
                if(contactPhone == BLANK_STRING){
                    if(errorMsg != BLANK_STRING){
                        errorMsg += SPACE_WITH_COMMA;
                    }
                    errorMsg += Label.PEPhoneErrorMsgBody;
                }
                
                errorMsg += SPACE + Label.PEFinalErrorMsgBody;
                isValidation = true;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,errorMsg));                                         
            }else{
                
                if(emailVsContactIdMap.containskey(contactEmail.toLowerCase()) || emailIdSet.contains(contactEmail.toLowerCase())){
                    isValidation = true;
                    //Error message if contact is already exists with same email id
                    if(emailVsContactIdMap.containskey(contactEmail.toLowerCase())){
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,Label.PEEmailInContactAlreadyExist));
                    }
                    //Error message if team member is already added with same email id.
                    if(emailIdSet.contains(contactEmail.toLowerCase())){
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,Label.PEEmailInMemberAlreadyExist));
                    }
                    
                }else{
                    isValidation = false;
                    if(propEventId != BLANK_STRING && comcastAccountId != BLANK_STRING && contactFirstName != BLANK_STRING && contactLastName != BLANK_STRING && contactEmail != BLANK_STRING && contactPhone != BLANK_STRING){
                        //Create New Contact record 
                        Contact newContact = new Contact();
                        newContact.FirstName = contactFirstName;
                        newContact.LastName = contactLastName;
                        newContact.Email = contactEmail;
                        newContact.AccountId = comcastAccountId;
                        newContact.RecordTypeId = contactRecordTypeId;
                        //newContact.Phone = contactPhone; //Removing as part of US1141203
                        newContact.MobilePhone = contactPhone; // Adding as part of US1141203 - Capturing the number and updating the MobilePhone field on Contact.
                        Database.SaveResult saveContact = Database.insert(newContact);
                        
                        //Create property Event team Member
                        Property_Event_Team_Member__c teamMember = new Property_Event_Team_Member__c();
                        teamMember.Name = contactFirstName + SPACE + contactLastName;     
                        teamMember.Property_Event__c = propEventId; 
                        teamMember.Email__c = contactEmail;
                        teamMember.Mobile_Phone__c = contactPhone; //adding as part of US1072089
                        if(saveContact.isSuccess()){
                            teamMember.Contact__c = newContact.id;
                        }
                        Database.insert(teamMember);
                        //Redirect to property event record list after creation of property Event team Member record in SFDC.
                        if(!isSF1){
                            String pageReference = URL.getSalesforceBaseUrl().toExternalForm() + SLASH_STRING + propEventId;
                            PageReference pageRef = new PageReference(pageReference);
                            pageRef.setredirect(true);
                            return pageRef;
                        }else{
                            return null;
                        }                   
                    }
                    else{
                        return null;
                    }
                }   
            }
        }catch(Exception ex){isValidation = true;ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,Label.PESomeThingWentWrong));} 
        return null;
    }
    
    /*********************************************    
    * @Description : resetFlag method to reseting all flag variable.                    
    * @Author : Amit Kumar Pradhan, Accenture    
    * @Date : 31-May-2017 
    * @User Story : US1071692(XC Property Events: Improve Team Member Workflow)
    * @Param : none 
    * @Return : void
    **********************************************/
    private void resetFlag(){
        showAddContactSec = false;
        showAddTeamMemberSec = false;
        isSearchComplete = false;
        isValidation = false;
    }
    
    /*********************************************    
    * @Description : UserORContactWrapper class for adding user and contact records.                    
    * @Author : Amit Kumar Pradhan, Accenture    
    * @Date : 31-May-2017 
    * @User Story : US1071692(XC Property Events: Improve Team Member Workflow)
    **********************************************/
    public class UserORContactWrapper{
        public String firstName { get; set; }
        public String lastName { get; set; }
        public String email { get; set; }
        public String mobilePhone { get; set; } // adding as part of US1072089
        public Id id {get; set;}
        public Boolean isSalesforceUser {get; set;}
        //non-parameterized constructor as used for instantiate of "selectedUserORContact"
        public UserORContactWrapper(){}
        
        /*********************************************    
        * @Description : parameterized constructor as user as a user as parameter.                  
        * @Author : Amit Kumar Pradhan, Accenture    
        * @Date : 31-May-2017 
        * @User Story : US1071692(XC Property Events: Improve Team Member Workflow)
        **********************************************/
        public UserORContactWrapper(User userRecord){
            firstName = userRecord.FirstName;
            lastName = userRecord.LastName;
            email = userRecord.Email;
            mobilePhone=userRecord.MobilePhone;
            id = userRecord.Id;
            isSalesforceUser = true;           
        }
        
        /*********************************************    
        * @Description : parameterized constructor as user as a user as parameter.                  
        * @Author : Amit Kumar Pradhan, Accenture    
        * @Date : 31-May-2017 
        * @User Story : US1071692(XC Property Events: Improve Team Member Workflow)
        **********************************************/
        public UserORContactWrapper(Contact contactRecord){
            firstName = contactRecord.FirstName;
            lastName = contactRecord.LastName;
            email = contactRecord.Email;
            mobilePhone=contactRecord.MobilePhone;
            id = contactRecord.Id;
            isSalesforceUser = false;        
            
        }
    }  
    
    /*********************************************    
    * @Description : This method is used during pagination to navigate to previous page                   
    * @Author : Lavanya Hosbet    
    * @Date : 26-Jun-2017 
    * @User Story : US1123523(Property Event - Team Member Pagination)
    **********************************************/
    public PageReference previous()
    {
        pageNumber--;
        userORContactDetails = new List<UserORContactWrapper>();
        userORContactDetails =  userOrContactMap.get(pageNumber);
        recordSize = userORContactDetails.size();
        return null;
    }

    /*********************************************    
    * @Description : This method is used during pagination to navigate to next page                   
    * @Author : Lavanya Hosbet    
    * @Date : 26-Jun-2017 
    * @User Story : US1123523(Property Event - Team Member Pagination)
    **********************************************/
    public PageReference next()
    {
        pageNumber++;
        userORContactDetails = new List<UserORContactWrapper>();
        userORContactDetails =  userOrContactMap.get(pageNumber);
        recordSize = userORContactDetails.size();
        return null;
    }

    /*********************************************    
    * @Description : This method is used determine if the 'Previous' button should be enabled                  
    * @Author : Lavanya Hosbet    
    * @Date : 26-Jun-2017 
    * @User Story : US1123523(Property Event - Team Member Pagination)
    **********************************************/
    public boolean getPrev()
    {
        if(pageNumber == 1)
            return true;
        else
            return false;
    }

    /*********************************************    
    * @Description : This method is used determine if the 'Next' button should be enabled                  
    * @Author : Lavanya Hosbet    
    * @Date : 26-Jun-2017 
    * @User Story : US1123523(Property Event - Team Member Pagination)
    **********************************************/
   public boolean getNxt()
    {
        if(noOfPages == 1 || pageNumber == (noOfPages - 1))
            return true;
        else
            return false;
    }     
}