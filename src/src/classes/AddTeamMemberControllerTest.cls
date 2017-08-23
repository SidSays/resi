@isTest
public class AddTeamMemberControllerTest{ 

	private static Property_Events__c propEvent;
	private static MDU_Property__c prop;
	private static List<AddTeamMemberController.UserORContactWrapper> carUserList;
	private static Map<Integer, List<AddTeamMemberController.UserORContactWrapper>> userOrContactMap;
	
    private static testMethod void testAddTeamMember(){
        SetupTestData.createCustomSettingRecords();
                        
        Account comcastAccount = TestDataUtility.createAccount();
        Database.insert(comcastAccount);
        
        Variable_Setting__c variableSetting3 = new Variable_Setting__c();
        variableSetting3.name = 'PropertyEventComcastAccountID';
        variableSetting3.Description__c = 'Dummy Account Record';
        variableSetting3.Value__c = String.valueOf(comcastAccount.Id);
        insert variableSetting3;
        User currentUser = [SELECT Id, Region__c, Name FROM User WHERE Id=:UserInfo.getUserId()];
        Contact newContact = new Contact();
        newContact.FirstName = 'Amit';
        newContact.LastName = 'Pradhan';
        newContact.Email = 'amit@accenture.com';
        newContact.AccountId = comcastAccount.Id;
        newContact.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('CAR Contact').getRecordTypeId();
        newContact.Phone = '12346789';
        insert newContact;
        
        User carUser = TestDataUtility.createXfinityCARUser();
        carUser.firstName = 'Amit';
        carUser.lastName = 'Pradhan';
        carUser.Region__c = currentUser.Region__c;
        update carUser;
        
        MDU_Property__c prop = TestDataUtility.createProperty();
        Database.insert(prop);
        
        Property_Events__c propEvent = new Property_Events__c();
        propEvent.Name = 'Test';
        propEvent.Property__c = prop.Id;
        propEvent.Start_Time__c = System.today()+2;
        propEvent.End_Time__c = System.today()+2;
        propEvent.Type__c = 'Other';
        Database.insert(propEvent);
        
        
        PageReference pageRef = Page.AddPropertyEventTeamMembers;
        Test.setCurrentPage(pageRef);       
        ApexPages.currentPage().getParameters().put('propEventId', propEvent.Id);
        ApexPages.currentPage().getHeaders().put('USER-AGENT','iPad');
        ApexPages.StandardController propEventTeamMemberController = new ApexPages.StandardController(propEvent);
        AddTeamMemberController addTeamMember = new AddTeamMemberController(propEventTeamMemberController);
        addTeamMember.fName = 'Amit';
        addTeamMember.lName = 'Pradhan';
        
        addTeamMember.contactFirstName = 'Test';
        addTeamMember.contactLastName = 'Test';
        addTeamMember.contactEmail = 'test@test.com';
        addTeamMember.contactPhone = '123456778';
         
        addTeamMember.userORContactSearch();
        addTeamMember.selectedRecordId = carUser.id;
        addTeamMember.addTeamMember();
        addTeamMember.createNewContact();
                 
    } 
    
    private static testMethod void testAddTeamMemberValidation(){
        MDU_Property__c prop = TestDataUtility.createProperty();
        Database.insert(prop);
        
        Property_Events__c propEvent = new Property_Events__c();
        propEvent.Name = 'Test';
        propEvent.Property__c = prop.Id;
        propEvent.Start_Time__c = System.today()+2;
        propEvent.End_Time__c = System.today()+2;
        propEvent.Type__c = 'Other';
        Database.insert(propEvent);
    
        PageReference pageRef = Page.AddPropertyEventTeamMembers;
        Test.setCurrentPage(pageRef);       
        ApexPages.currentPage().getParameters().put('propEventId', propEvent.Id);
        //ApexPages.currentPage().getHeaders().put('USER-AGENT','iPad11');
        ApexPages.StandardController propEventTeamMemberController1 = new ApexPages.StandardController(propEvent);
        AddTeamMemberController addTeamMember1 = new AddTeamMemberController(propEventTeamMemberController1);
        addTeamMember1.fName = 'Am';
        addTeamMember1.contactFirstName = '';
        addTeamMember1.contactLastName = '';
        addTeamMember1.contactEmail = '';
        addTeamMember1.contactPhone = '';
        addTeamMember1.selectedRecordId ='';
        
        addTeamMember1.userORContactSearch();
        addTeamMember1.addTeamMember();
        addTeamMember1.createNewContact();
    }
    
    private static void setupDataForPagination(){
    	
    	prop = TestDataUtility.createProperty();
        Database.insert(prop);
        
        propEvent = new Property_Events__c();
        propEvent.Name = 'Test';
        propEvent.Property__c = prop.Id;
        propEvent.Start_Time__c = System.today()+2;
        propEvent.End_Time__c = System.today()+2;
        propEvent.Type__c = 'Other';
        Database.insert(propEvent);
        
        User currentUser = [SELECT Id, Region__c, Name FROM User WHERE Id=:UserInfo.getUserId()]; 
        
        carUserList = new List<AddTeamMemberController.UserORContactWrapper>();
        for(Integer i = 0; i < 25 ; i++){
        	User user = TestDataUtility.createXfinityCARUser();
        	user.firstName = 'userTest';
        	user.Region__c = currentUser.Region__c;
        	user.isActive = true;
        	update user;
        	AddTeamMemberController.UserORContactWrapper userWrapper = new AddTeamMemberController.UserORContactWrapper(user);
        	carUserList.add(userWrapper);
        }
        
        userOrContactMap = new Map<Integer, List<AddTeamMemberController.UserORContactWrapper>>();
        userOrContactMap.put(1, carUserList);
        userOrContactMap.put(2, carUserList);
        
        Variable_Setting__c variableSetting3 = new Variable_Setting__c();
		variableSetting3.name = 'PaginationSize';
		variableSetting3.Description__c = 'The limit to the number of records to be displayed';
		variableSetting3.Value__c = '25';
		insert variableSetting3;
        
    }
    
    private static testMethod void testPagination(){
    	
    	setupDataForPagination();
    	PageReference pageRef = Page.AddPropertyEventTeamMembers;
        Test.setCurrentPage(pageRef);       
        ApexPages.currentPage().getParameters().put('propEventId', propEvent.Id);
        ApexPages.currentPage().getHeaders().put('USER-AGENT','iPad');
        ApexPages.StandardController propEventTeamMemberController = new ApexPages.StandardController(propEvent);
        AddTeamMemberController addTeamMember = new AddTeamMemberController(propEventTeamMemberController);
        addTeamMember.fName = 'userTest';
        addTeamMember.lName = 'Testing1';
        
        User currentUser = [SELECT Id, Region__c, Name FROM User WHERE Id=:UserInfo.getUserId()]; 
        User user = TestDataUtility.createXfinityCARUser();
        user.firstName = 'userTest';
        user.Region__c = currentUser.Region__c;
        user.isActive = true;
        update user;
        addTeamMember.userORContactSearch();
        
        addTeamMember.userORContactDetails = carUserList;
        addTeamMember.userOrContactMap = new Map<Integer, List<AddTeamMemberController.UserORContactWrapper>>(userOrContactMap);
        addTeamMember.pageNumber = 2;
        addTeamMember.previous();
        addTeamMember.getPrev();
        addTeamMember.noOfPages = 2;
        addTeamMember.getNxt();
        
        addTeamMember.userORContactDetails = carUserList;
        addTeamMember.userOrContactMap = new Map<Integer, List<AddTeamMemberController.UserORContactWrapper>>(userOrContactMap);
        addTeamMember.pageNumber = 1;
        addTeamMember.next();
        addTeamMember.getNxt();
        addTeamMember.getPrev();
        
    }
}