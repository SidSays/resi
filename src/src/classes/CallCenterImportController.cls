public with sharing class CallCenterImportController {

    ApexPages.StandardController controller;
    public Document document {
        get{
            if(document == null){
                document = new Document();
            }
            return document;
        }
        set;
    }

    public CallCenterImportController(ApexPages.StandardController stdController) {
        controller = stdController;
    }

    public PageReference updateLeadsAndOpps(){
        if(document != null && document.Body != null && document.Name.contains('.csv')){
            List<String> csvLines = new List<String>();
            List<String> csvCells = new List<String>();
            List<Opportunity> oppsToUpdate = new List<Opportunity>();
            List<Lead> leadsFromTelesales = new List<Lead>();
            List<Lead> leadsToUpdate = new List<Lead>();

            String body = document.body.toString();

            //Remove column titles from body
            Integer endOfFirstLineIndex = body.indexOf('\r', body.indexOf('LS_CUST_CONTACT_DT'));
            body = body.substring(endOfFirstLineIndex);
            
            //Remove quotes and line breaks from the file
            body = body.replaceAll('\"', '');
            body = body.replaceAll('\r', '');
            body = body.replaceAll('\n', '');

            //Break file body into lines
            Integer nextOppIdIndex;
            Integer nextLeadIdIndex;
            Boolean breakFlag = false;
            while(!breakFlag){
                nextOppIdIndex = body.indexOf(',' + Label.OpportunityPrefix);
                nextLeadIdIndex = body.indexOf(',' + Label.LeadPrefix);

                if(nextOppIdIndex != -1 && (nextLeadIdIndex == -1 || nextOppIdIndex < nextLeadIdIndex)){
                    if(nextOppIdIndex + 18 < body.length()){
                        csvLines.add(body.substring(0, nextOppIdIndex + 19));
                        body = body.substring(nextOppIdIndex + 19);
                    }
                } else if(nextLeadIdIndex != -1 && (nextOppIdIndex == -1 || nextLeadIdIndex < nextOppIdIndex)){
                    if(nextLeadIdIndex + 18 < body.length()){
                        csvLines.add(body.substring(0, nextLeadIdIndex + 19));
                        body = body.substring(nextLeadIdIndex + 19);
                    }
                } else {
                    breakFlag = true;
                }
            }

            //Break lines into individual cells
            for(String str : csvLines){
                Integer commaCount = 0;
                for(Integer i = 0; i < str.length(); i++){
                    if(str.substring(i, i+1) == ','){
                        commaCount++;
                    }
                }

                if(commaCount == 7){
                    List<String> tempList = str.split(',');
                    csvCells.addAll(tempList);
                } else {
                    Integer lineIndex = 0;
                    for(Integer i = 0; i < 6; i++){
                        csvCells.add(str.substring(lineIndex, str.indexOf(',', lineIndex)));
                        lineIndex = str.indexOf(',') + 1;
                    }
                    nextOppIdIndex = str.indexOf(',' + Label.OpportunityPrefix);
                    nextLeadIdIndex = str.indexOf(',' + Label.LeadPrefix);
                    if(nextOppIdIndex != -1){
                        csvCells.add(str.substring(lineIndex, nextOppIdIndex));
                        csvCells.add(str.substring(nextOppIdIndex + 1, nextOppIdIndex + 19));
                    } else if(nextLeadIdIndex != -1){
                        csvCells.add(str.substring(lineIndex, nextLeadIdIndex));
                        csvCells.add(str.substring(nextLeadIdIndex + 1, nextLeadIdIndex + 19));
                    } else {
                        System.debug('Line did not contain appropriate Lead or Opportunity Prefix. str=' + str);
                    }
                }
            }

            List<String> oppIds = new List<String>();
            List<String> leadIds = new List<String>();
            Map<String, Integer> id_indices = new Map<String, Integer>();
            //Create a list of SF Id's and a map of their corresponding indices
            for(Integer i = 7; i < csvCells.size(); i+=8){
                if(csvCells.get(i).substring(0,3) == Label.OpportunityPrefix){
                    oppIds.add(csvCells.get(i));
                    id_indices.put(csvCells.get(i), i);
                }else if(csvCells.get(i).substring(0,3) == Label.LeadPrefix){
                    leadIds.add(csvCells.get(i));
                    id_indices.put(csvCells.get(i), i);
                } else {
                    System.debug('Cell did not contain correct Lead or Opportunity Prefix. csvCells.get(i)=' + csvCells.get(i));
                }
            }

            leadsFromTelesales = [SELECT Id, Lead_Name__c, Status, Telesales_Last_Modified_Date__c, Telesales_Notes__c, Lead_Reason_Description__c,
                                ConvertedOpportunityId, Phone, LocationID__c, isConverted FROM Lead WHERE Id IN :leadIds];

            List<Lead> leadsToConvert = new List<Lead>();
            Integer index;
            String tempDateTime;
            for(Lead l : leadsFromTelesales){
                if(!l.isConverted){
                    index = id_indices.get(l.Id);
                    //If there was a sale, add to list to be converted
                    if(csvCells.get(index - 2) != null || csvCells.get(index - 3) == '1' || csvCells.get(index - 4) == '1'){
                        leadsToConvert.add(l);
                    }
                    //If no sale, just update Lead
                    else {
                        l.Telesales_Notes__c = csvCells.get(index - 1);
                        if(csvCells.get(index - 5) == 'Competition'){
                            l.Lead_Reason_Description__c = 'In Competitor Contract';
                        } else {
                            l.Lead_Reason_Description__c = csvCells.get(index - 5);
                        }
                        l.Status = csvCells.get(index - 6);

                        tempDateTime = csvCells.get(index - 7);
                        tempDateTime = tempDateTime.replace('/', '-');
                        Integer tempIndex = tempDateTime.lastIndexOf('-');
                        tempDateTime = tempDateTime.substring(tempIndex+1, tempIndex+5)+'-'+tempDateTime.substring(0, tempIndex)+tempDateTime.substring(tempIndex+5, tempDateTime.length());
                        l.Telesales_Last_Modified_Date__c = Date.valueOf(tempDateTime);

                        leadsToUpdate.add(l);
                    }
                } else {
                    //replace converted Lead Id with ConvertedOpportunityId, and add it to oppIds
                    if(l.ConvertedOpportunityId != null){
                        index = id_indices.get(l.id);
                        id_indices.remove(l.id);
                        id_indices.put(l.ConvertedOpportunityId, index);

                        oppIds.add(l.ConvertedOpportunityId);
                    }
                }
            }

            //Gather relevant Account and Contact information
            List<String> locationIds = new List<String>();
            List<String> phoneNumbers = new List<String>();
            for(Lead l : leadsToConvert){
                locationIds.add(l.LocationID__c);
                phoneNumbers.add(l.Phone);
            }

            List<Account> accountsRelatedToLeads = new List<Account>();
            accountsRelatedToLeads = [SELECT Id, Customer__c, Phone, LocationID__c FROM Account WHERE LocationID__c IN: locationIds AND Phone IN: phoneNumbers];
            List<String> customerIds = new List<String>();
            for(Account a : accountsRelatedToLeads){
                customerIds.add(a.Customer__c);
            }

            List<Contact> contactsRelatedToAccounts = new List<Contact>();
            contactsRelatedToAccounts = [SELECT Id FROM Contact WHERE Id IN: customerIds];

            //create List of LeadConverts
            List<Database.LeadConvert> leadConverts = new List<Database.LeadConvert>();
            for(Lead l : leadsToConvert){
                Database.LeadConvert lc;
                Account tempAccount;
                lc = new Database.LeadConvert();
                lc.setLeadId(l.Id);
                lc.setOpportunityName(l.Lead_Name__c);
                lc.convertedStatus = 'Closed';
                for(Account a : accountsRelatedToLeads){
                    if(a.LocationID__c == l.LocationID__c && a.Phone == l.Phone){
                        lc.setAccountId(a.Id);
                        tempAccount = a;
                    }
                }
                if(tempAccount != null){
                    for(Contact c : contactsRelatedToAccounts){
                        if(tempAccount.Customer__c == c.Id){
                            lc.setContactID(c.Id);
                            lc.overwriteLeadSource = true;
                        }
                    }
                }
                leadConverts.add(lc);
            }
            Database.LeadConvert[] leadsToConvertArray = new Database.LeadConvert[leadConverts.size()];
            for(Integer i = 0; i < leadsToConvertArray.size(); i++){
                leadsToConvertArray[i] = leadConverts.get(i);
            }

            //Update information on Opportunities
            oppsToUpdate = [SELECT Id, StageName, CHSI_Sale__c, CDV_Sale__c, Video_Sale__c, Telesales_Last_Modified_Date__c, 
                                Telesales_Notes__c, Opportunity_Reason_Description__c FROM Opportunity WHERE Id IN :oppIds];

            for(Opportunity o : oppsToUpdate){
                index = id_indices.get(o.Id);
                o.Telesales_Notes__c = csvCells.get(index - 1);
                if(csvCells.get(index - 2) != null){
                    o.Video_Sale__c = csvCells.get(index - 2);
                }
                if(csvCells.get(index - 3) == '1'){
                    o.CDV_Sale__c = true;
                } else {
                    o.CDV_Sale__c = false;
                }
                if(csvCells.get(index - 4) == '1'){
                    o.CHSI_Sale__c = true;
                } else {
                    o.CHSI_Sale__c = false;
                }

                if(csvCells.get(index - 5) == 'Competition'){
                    o.Opportunity_Reason_Description__c = 'In Competitor Contract';
                } else {
                    o.Opportunity_Reason_Description__c = csvCells.get(index - 5);
                }

                if(csvCells.get(index - 6) == 'SALE-COMPLETE'){
                    o.StageName = 'Closed Won';
                } else if(csvCells.get(index - 6) == 'NOSALE-COMPLETE' || csvCells.get(index - 6) == 'UNSELLABLE'){
                    o.StageName = 'Closed Lost';
                } else {
                    o.StageName = csvCells.get(index - 6);
                }

                tempDateTime = csvCells.get(index - 7);
                tempDateTime = tempDateTime.replace('/', '-');
                Integer tempIndex = tempDateTime.lastIndexOf('-');
                tempDateTime = tempDateTime.substring(tempIndex+1, tempIndex+5)+'-'+tempDateTime.substring(0, tempIndex)+tempDateTime.substring(tempIndex+5, tempDateTime.length());
                o.Telesales_Last_Modified_Date__c = Date.valueOf(tempDateTime);
            }

            try{
                List<Database.LeadConvertResult> lcr = Database.convertLead(leadsToConvertArray);
            }
            catch(DmlException e) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'An Error Occured Converting Leads'));
                System.debug(e);
            }
            try{
                //update oppsToUpdate;
            } catch(DmlException e) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'An Error Occured Updating Opportunities'));
                System.debug(e);
            }
            try{
                //update leadsToUpdate;
            } catch(DmlException e) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'An Error Occured Updating Leads'));
                System.debug(e);
            }
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'Update Complete.'));
        }else{
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'Invalid File'));
        }
        return null;
    }
}