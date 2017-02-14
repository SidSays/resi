@isTest
private class PropertyEventValidationTest {
    
    private static final string LABEL_NAME_SPLIT = ';';
    public static MDU_Property__c createTestPropertyData(){
            TestDataUtility.createCustomSettingRecords();
            String labelName = System.Label.XfinityPropertyRecordType;  
            List<String> recordTypeSet = new List<String>();
            if(!string.IsBlank(labelName)){
                for(String str : labelName.split(LABEL_NAME_SPLIT)){
                    recordTypeSet.add(Schema.SObjectType.MDU_Property__c.getRecordTypeInfosByName().get(str).getRecordTypeId());
                }
            }    
            MDU_Property__c  testProperty = TestDataUtility.createProperty();
            testProperty.recordTypeId = recordTypeSet[0];
            return testProperty;
        }

    private static testMethod void testPropertyEventValidation(){
    
        List<Property_Events__c>lstPE = new List<Property_Events__c>();
        
        
        
        Test.startTest();
            
            Property_Events__c PE = new Property_Events__c();
            PE.name = 'TestPropertyEvent';
           // PE.Event_date__c = date.today();
            MDU_Property__c prop = createTestPropertyData();
            Database.insert(prop);
            
            PE.Property__c = prop.id;
            PE.Type__c = 'Other';
            insert PE;
            
            lstPE.add(PE);
            
            PropertyEventValidation objPE = new PropertyEventValidation();
            objPE.doNotDeleteWithItems(lstPE);
            
           
                Property_Event_Item__c PEitem = new Property_Event_Item__c();
                PEitem.name = 'TestPropertyEventitem';
                PEitem.Property_Event__c = PE.id;
                PEitem.Category__c = 'other';
                PEitem.Quantity__c = 3;
                PEitem.Cost_per_Unit__c = 4;
                
                insert PEitem ;        
                
               // objPE.mapPropertyEventToItems.put(PE.id, new List<Property_Event_Item__c>{PEitem});
                objPE.doNotDeleteWithItems(lstPE);
                Test.stopTest();
           
        
       
       
     }
   }