global class DailyCommissionBatch implements Database.Batchable<sObject>, Schedulable{
    public String query = 'SELECT Id, CaseNumber, Name__c, OwnerId, Owner.Name, Affiliate_Account__c, Affiliate_Account__r.Name, CreatedDate, Status FROM Case WHERE (RecordType.Name IN (\'Open Assigned Claim\', \'Open Accepted Claim\') ) AND (Status != \'Closed\' AND Status != \'Cancelled\')';

    global void execute(SchedulableContext SC) {
        DailyCommissionBatch b = new DailyCommissionBatch();
        Database.executeBatch(b,200); 
    } 

    global database.queryLocator start(Database.BatchableContext BC) {
        system.debug('----------------------------query');
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope) {
        List<Case> newClaims = new List<Case>();
        List<Case> claimsOpen = new List<Case>();
        List<Case> claimsWaiting = new List<Case>();
        List<Case> oldClaims = new List<Case>();

        //System.debug('Recipients - ' + getRecipients());

        for(Case c : (List<Case>) scope){
            if(c.Status == 'New' && c.CreatedDate > (Date.today() - 14)){
                newClaims.add(c);
            }
            
            if(c.CreatedDate < (Date.today() - 14)){
                claimsOpen.add(c);
            }

            if(c.Status == 'Management Review'){
                claimsWaiting.add(c);
            }

            if(c.CreatedDate < (Date.today() - 30)){
                oldClaims.add(c);
            }
        }

        String htmlBody = '<html>'+
                                '<head>'+
                                    '<style>'+
                                        'table,th,td'+
                                        '{'+
                                            'border:1px solid black;'+
                                            'border-collapse:collapse;'+
                                        '}'+
                                        'th, td'+
                                        '{'+
                                            'padding:5px;'+
                                        '}'+
                                    '</style>'+
                                '</head>'+
                        '<body>';

        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        
        List<String> recipients = new List<String>();
        //recipients = getRecipients();

        //mail.setToAddresses(recipients);
        mail.setBccSender(true);
        mail.setBccAddresses(getRecipients());
        //mail.setToAddresses(new String[]{'drice@acumensolutions.com'});
        mail.setSenderDisplayName('Comcast');
        mail.setSubject('Claims Report As of ' + Datetime.now().format());

        htmlBody = generateTable(newClaims, htmlBody, 'New Claims');
        htmlBody = generateTable(claimsWaiting, htmlBody, 'Claims Waiting for Management Review');
        htmlBody = generateTable(claimsOpen, htmlBody, 'Claims Older Than 14 Days');
        htmlBody = generateTable(oldClaims, htmlBody, 'Claims Older Than 30 Days');
        htmlBody += '</body></html>';       

        mail.setHtmlBody(htmlBody);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    } 

    public List<String> getRecipients(){
        List<String> recipients = new List<String>();
        List<Id> userIds = new List<Id>();
        List<Group> groups = new List<Group>([SELECT Id, (SELECT userOrGroupId FROM GroupMembers) 
            FROM Group WHERE Name = 'Claim Investigation Group' OR Name = 'Claim Approval Group']);

        for(Group g : groups){
            for(GroupMember gm : g.GroupMembers){
                userIds.add(gm.userOrGroupId);
            }
        }

        List<User> users = new List<User>([SELECT Email, isActive FROM User WHERE isActive = true AND id IN :userIds]);
        for(User u : users){
            recipients.add(u.Email);
        }

        //recipients.add('drice@acumensolutions.com');

        return recipients;
    } 

    public String generateTable(List<Case> cases, String htmlBody, String title){ 
        htmlBody += '<strong>' + title + '</strong>'+
                    '<table>'+
                        '<tr>'+
                            '<td><strong>Case #</strong></td>'+
                            '<td><strong>Affiliate</strong></td>'+                          
                            '<td><strong>Case Name</strong></td>'+
                            '<td><strong>Case Owner</strong></td>'+
                            '<td><strong>Date Opened</strong></td>'+
                            '<td><strong>Status</strong></td>'+
                        '</tr>';

        for(Case c : cases){
            htmlBody += '<tr>'+
                            '<td><a href="https://' + URL.getSalesforceBaseURL().getHost() + '/' + c.Id + '">' + c.CaseNumber + '</a></td>';

            if(c.Affiliate_Account__c != null){
                htmlBody += '<td>' + c.Affiliate_Account__r.Name + '</td>';
            } else{
                htmlBody += '<td></td>';
            }
            
            htmlBody +=     '<td>' + c.Name__c + '</td>'+
                            '<td>' + c.Owner.Name + '</td>'+
                            '<td>' + c.CreatedDate + '</td>'+
                            '<td>' + c.Status + '</td>'+
                        '</tr>';                    
        }

        return htmlBody += '</table><br />';            
    }

    global void finish(Database.BatchableContext BC) {
        
    }   
}