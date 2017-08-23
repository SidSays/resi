public with sharing class ClaimEligibleSubmissionController {    
    List<Order__c> eligibleOrdersList {get;set;}
    public Order_Display__c displayObject {get;set;}
    public transient List<List<Order__c>> ordersToDisplay {get;set;}

    public String errorMessages {get;set;}
    public Boolean isError {get;set;}
    public Boolean displayOrderResults {get;set;}
    public Boolean showAffiliate {get;set;}

    public Boolean inConsole {get;set;}
    public Boolean inBrowser {get;set;}

    public User currentUser;
    public Id affiliateAccountId;
    public String profileName;
    public Contact currentUserContact;
    
    
    
    public ClaimEligibleSubmissionController(ApexPages.StandardSetController controller) {    
        displayObject = new Order_Display__c();
        Datetime now = Datetime.now();
        currentUserContact = new Contact();
        displayOrderResults = false;

        ordersToDisplay = new List<List<Order__c>>();

        profileName = [SELECT Name FROM Profile WHERE Id = :UserInfo.getProfileId() limit 1].Name;
        currentUser = [SELECT Id, ContactId FROM User WHERE Id = :UserInfo.getUserId() limit 1];
        
        if(currentUser.ContactId != null && profileName == 'Affiliate Claims User'){
            showAffiliate = false;
            inConsole = false;
            inBrowser = true;
            currentUserContact = [SELECT Id, AccountId, Account.Name, Account.ClaimWaitDuration__c, Account.ClaimEligibilityDuration__c FROM Contact WHERE Id = :currentUser.ContactId limit 1];
        } else if(profileName == 'Claims Manager' || profileName == 'Claims User' || profileName == 'System Administrator'){
            showAffiliate = true;
            inConsole = true;
            inBrowser = false;
        }
    }

    public PageReference displayOrders(){        
        ordersToDisplay = new List<List<Order__c>>();  

        if(profileName == 'Affiliate Claims User'){
            affiliateAccountId = currentUserContact.AccountId;
        } else if(profileName == 'Claims Manager' || profileName == 'Claims User'){
            affiliateAccountId = displayObject.Affiliate_Account__c;
        }

        List<Order__c> innerOrdersList = new List<Order__c>();
        List<Order__c> queryResults = new List<Order__c>();

        if(checkValidDates()){
            displayOrderResults = true;

            if(displayObject.ViewOptions__c == 'All Eligible Orders'){
                queryResults = getEligibleOrders();
            } else if(displayObject.ViewOptions__c == 'All Orders'){
                queryResults = getAllOrders();
            }

            for(Order__c o : queryResults){
                if(innerOrdersList.size() < 1000){
                    innerOrdersList.add(o);
                }

                if(innerOrdersList.size() == 1000 || innerOrdersList.size() == queryResults.size()){
                    ordersToDisplay.add(innerOrdersList);
                    innerOrdersList = new List<Order__c>();
                }
            }
            
            if(innerOrdersList.size() > 0){
                ordersToDisplay.add(innerOrdersList);
            }
        } 

        return null;
    }

    public List<Order__c> getEligibleOrders(){
        return [SELECT Id, Affiliate_Account__c, Name, OrderStatus__c, Order_Created_Date__c, OrderCompletedDate__c, Claim_Eligibility__c
            FROM Order__c WHERE Lead_Source__c = 'Affiliate' AND OrderStatus__c = 'Activated' AND isClaimEligible__c = true AND Affiliate_Account__c = :affiliateAccountId AND 
            OrderCompletedDate__c > :displayObject.Filter_Start__c AND OrderCompletedDate__c < :displayObject.Filter_End__c];
    }

    public List<Order__c> getAllOrders(){
        return [SELECT Id, Affiliate_Account__c, Name, OrderStatus__c, Order_Created_Date__c, OrderCompletedDate__c, Claim_Eligibility__c
            FROM Order__c WHERE Lead_Source__c = 'Affiliate' AND OrderStatus__c = 'Activated' AND Affiliate_Account__c = :affiliateAccountId AND 
            OrderCompletedDate__c > :displayObject.Filter_Start__c AND OrderCompletedDate__c < :displayObject.Filter_End__c];
    }
    
    public PageReference redirect(){
        // if current user isn't a Claims User, Claims Manager, or Affiliate User, don't override the object tab
        //String profileName = [SELECT Name FROM Profile WHERE Id = :UserInfo.getProfileId() limit 1].Name;
        
        
        if(profileName == 'Claims Manager' || profileName == 'Claims User' || profileName == 'Affiliate Claims User'){
            return null;
        } else{
            Schema.DescribeSObjectResult r = Order__c.sObjectType.getDescribe();
            String keyPrefix = r.getKeyPrefix();
            
            return new PageReference('/' + keyPrefix + '/o?nooverride=1');
        }
    }

    private Boolean checkValidDates(){
        if(displayObject.Filter_Start__c == null){
            isError = true;
            errorMessages = 'Please select a Start Date';

            return false;
        } else if(displayObject.Filter_End__c == null){
            isError = true;
            errorMessages = 'Please select an End Date';

            return false;
        } else if(displayObject.Filter_End__c < displayObject.Filter_Start__c){
            isError = true;
            errorMessages = 'Please select an End Date after the Start Date.';
        
            return false;
        } else{
            isError = false;
            return true;
        }
    }
}