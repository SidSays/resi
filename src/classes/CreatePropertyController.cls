public with sharing class CreatePropertyController {

    public String propertyCodes {get;set;}
    public boolean assignPropertyCodes {get;set;}

    public CreatePropertyController() {
        String addressId=ApexPages.currentPage().getParameters().get('Id');
        assignPropertyCodes=false;
        if(ApexPages.currentPage().getParameters().get('PropertyCode')==''){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'In order to create a Property, Property Code on the address much be populated.<br/>Please click <a style="margin: 0; font-size: 100%; font-family: Arial,Helvetica,sans-serif; color: #222;" href="/'+addressId+'">here</a> to return to the Address.'));
        }
        else{
            if(ApexPages.currentPage().getParameters().get('ComplexOffice')=='0'){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'In order to create a Property, Complex Office on the address much be checked.<br/>Please click <a style="margin: 0; font-size: 100%; font-family: Arial,Helvetica,sans-serif; color: #222;" href="/'+addressId+'">here</a> to return to the Address.'));
            }else{
                String propertyCode=ApexPages.currentPage().getParameters().get('PropertyCode');
                propertyCodes=propertyCode;
                assignPropertyCodes=true;
            }
        }
    }

    public void createProperty(){
        if(propertyCodes!=null && propertyCodes!=''){
            String addressId=ApexPages.currentPage().getParameters().get('Id');
            Customer_Address__c address=[Select Id, Parent_Address__c,Region__c, State__c, Number_of_Units__c,Is_New__c From Customer_Address__c Where Id=:addressId];
            Set<String> propertyCodesSet= new Set<String>();
            if(propertyCodes.contains(',')){
                for(String propertyCode:propertyCodes.split(',')){
                    propertyCodesSet.add(propertyCode.trim());
                }
            }else{
                propertyCodesSet.add(propertyCodes);
            }
            List<Customer_Address__c> propertyAddresses=[SELECT Id,Parent_Address__c,Is_New__c FROM Customer_Address__c WHERE Property_Code__c IN: propertyCodesSet AND id !=:address.Id AND Region__c=:address.Region__c AND State__c=:address.State__c];
            
            List<Customer_Address__c> newAddressList = new List<Customer_Address__c>();
            if(address.Parent_Address__c == Null && address.Is_New__c == false){
                for(Customer_Address__c addr : propertyAddresses){
                    addr.Parent_Address__c = addressId;
                    addr.Is_New__c = false;
                    newAddressList.add(addr);
                }
                Database.update(newAddressList,false);
                if(!newAddressList.isEmpty()){
                    try{
                        address.Number_of_Units__c= newAddressList.size();
                        update address;
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, newAddressList.size()+' addresses were added to the Property. Click <a style="margin: 0; font-size: 100%; font-family: Arial,Helvetica,sans-serif; color: #222;" href="/'+address.Id+'">here</a> to retun to the address, or to view the property <a style="margin: 0; font-size: 100%; font-family: Arial,Helvetica,sans-serif; color: #222;" href="/apex/ViewAddressUnits?id='+address.Id+'">here</a>.'));
             
                    }catch (Exception ex){
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Exception encountered when updating Parent Addresses for property.'));
                    }
                }else{
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'No addresses were found with the entered Property Codes in this City and State. Please check the Property Codes you have entered.'));        
                }
            }
            else if(address.Parent_Address__c == Null && address.Is_New__c == true){
                List<Customer_Address__c> updatedAddressList = new List<Customer_Address__c>();
                system.debug('**Propertyaddress*'+propertyAddresses);
                for(Customer_Address__c addr : propertyAddresses){
                    if(addr.Parent_Address__c == Null && addr.Is_New__c == false && address.Is_New__c == true){
                        address.Parent_Address__c = addr.Id;
                        address.Is_New__c = false;
                        updatedAddressList.add(addr);
                    }
                    else if(addr.Parent_Address__c == Null && addr.Is_New__c == true){
                        addr.Parent_Address__c = address.Id;
                        addr.Is_New__c = false;
                        updatedAddressList.add(addr);
                    }
                    else if(addr.Parent_Address__c != Null){
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'This property code already has a parent address'));
                        //addr.Parent_Address__c = address.Id;
                        //addr.Is_New__c = false;
                        //updatedAddressList.add(addr);
                    }
                }
                Database.update(updatedAddressList,false);
                if(!updatedAddressList.isEmpty()){
                    try{
                        address.Number_of_Units__c= updatedAddressList.size();
                        address.Is_New__c = false;
                        update address;
                        if(!ApexPages.hasMessages()){
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, updatedAddressList.size()+' addresses were added to the Property. Click <a style="margin: 0; font-size: 100%; font-family: Arial,Helvetica,sans-serif; color: #222;" href="/'+address.Id+'">here</a> to retun to the address, or to view the property <a style="margin: 0; font-size: 100%; font-family: Arial,Helvetica,sans-serif; color: #222;" href="/apex/ViewAddressUnits?id='+address.Id+'">here</a>.'));
                        }
             
                    }catch (Exception ex){
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Exception encountered when updating Parent Addresses for property.'));
                    }
                }else{
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'No addresses were found with the entered Property Codes in this City and State. Please check the Property Codes you have entered.'));        
                }
            }
            else{
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,' This Address already has a Parent Address linked to it'));
            }
        }else{
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please enter a value into the Property Codes field.'));
        }
    }
}