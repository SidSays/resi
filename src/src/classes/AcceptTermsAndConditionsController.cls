public without sharing class AcceptTermsAndConditionsController {

    public string termsAndConditionsText {get; set;}
    public string firstName {get; set;}
    public string lastName {get; set;}
    public string email {get; set;}
    public boolean acceptTandC {get; set;}

    public AcceptTermsAndConditionsController() {
        Terms_and_Conditions__c tandc;

        List<Terms_and_Conditions__c> tandcList=[Select Terms_and_Conditions_Text__c From Terms_and_Conditions__c Where Active__c=true];
        if(!tandcList.isEmpty()){
            termsAndConditionsText=tandcList.get(0).Terms_and_Conditions_Text__c;
        }
    }

    public void emailTermsAndCondtionsSignupInfoForUser() {
        if(firstName=='' || lastName=='' || email==''){
            if(firstName==''){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please enter your First Name.'));
            }
            else if(lastName==''){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please enter your Last Name.')); 
            }
            else if(email==''){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please enter your email.'));
            }
        }else{
            if(acceptTandC){
                Terms_Conditions_Form__c tandcForm= new Terms_Conditions_Form__c(Name=firstName+' '+lastName,Email__c=email, Submitted_Date__c=datetime.now());
                insert tandcForm;
                Group chatterAdministratorsGroup=[select Id from Group WHERE Name='Chatter Administrators'];
                List<User> chatterAdministratorUsers=[Select Email From User Where ID IN (Select UserOrGroupId From GroupMember WHERE GroupID =:chatterAdministratorsGroup.ID)];
                String[] toEmailAddresses=new String[]{};
                for(User user:chatterAdministratorUsers){
                    toEmailAddresses.add(user.Email);
                }
                Messaging.SingleEmailMessage mailObj = new Messaging.SingleEmailMessage();
                mailObj.setToAddresses(toEmailAddresses);
                mailObj.setSubject('New Chatter User Request for '+firstName+' '+lastName);
                String msg = 'A new user has requested access to Chatter. <br/><br/>Name:&nbsp;'+firstName+' '+lastName+'<br/>Email:&nbsp;'+email+'<br/><br/>Their New Chatter User request record can be found <a href="https://'+Label.Instance+'.salesforce.com/' + tandcForm.Id + '">here</a>. Please create a new Chatter Free User license for them as soon as possible.';
                    mailObj.setHtmlBody('<html><body>'+msg+'<br/></body></html>');
                    Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mailObj });
                /*User currentUser=[Select Terms_and_Conditions_Accepted__c From User WHERE username=:username];
                currentUser.Terms_and_Conditions_Accepted__c=Date.Today();
                update currentUser;*/
                firstName='';
                lastName='';
                email='';
                acceptTandC=false;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'Thank You for accepting the Terms & Conditions! The Chatter team will create a new Chatter account for you; please look for an email from Salesforce with your username and link to set your password and login..'));
            }
            else{
              ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please check the "I Accept the Terms and Conditions" checkbox.'));
            }
        }
    }
}