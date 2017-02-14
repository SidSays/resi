@isTest
private class CommunitiesRateIncreaseTest {
    static testMethod void communitiesRateIncreaseWorkGridTest(){
        PageReference pageRef = Page.CommunitiesRateIncreaseWorkGridReport;
        Test.setCurrentPage(pageRef);
         //CommunitiesRateIncreaseWorkGridReport controller = new CommunitiesRateIncreaseWorkGridReport();
        //String nextPage = controller.save().getUrl();
        
        List<Bulk_Service__c> bs = new List<Bulk_Service__c>();
        MDU_Property__c prop = TestDataUtility.createProperty();
        database.insert(prop);
        Bulk_Rate_Increase__c bulkRateObject = TestDataUtility.createBulkRateIncrease(prop.Id);
        database.insert(bulkRateObject);
        Bulk_Service__c bulkServiceObject = TestDataUtility.createBulkService(bulkRateObject.Id);
        bs.add(bulkServiceObject);
        database.insert(bs);
        Contract__c contract = TestDataUtility.createContract(prop.Id);
        database.insert(contract);
        
        CommunitiesRateIncreaseWorkGridReport.getContract(prop.Id);
        CommunitiesRateIncreaseWorkGridReport.getAccount('10/10/2015','10/12/2015' ,1,'Comcast Cable','Central','Big South', 'Delta', 'Mobile');
        CommunitiesRateIncreaseWorkGridReport.getAccount('10/10/2015','10/12/2015' ,0,'Comcast Cable','Central','Big South', 'Delta', 'Mobile');
        CommunitiesRateIncreaseWorkGridReport.updateBSData obj = new CommunitiesRateIncreaseWorkGridReport.updateBSData();   
       List<CommunitiesRateIncreaseWorkGridReport.updateBSData> UpdateBs=new List<CommunitiesRateIncreaseWorkGridReport.updateBSData>();
        obj.bsId=bs[0].id;
        obj.bSName='pranjal singh';
        obj.units='20';
        obj.currentRate='45';
        obj.increaseAmount='45';
        obj.increaseAmountUnit='$';
        obj.increaseDate='10/20/2015';
        obj.noticeDueDate='10/10/2015';
        obj.implement =true;
updateBs.add(obj);
                CommunitiesRateIncreaseWorkGridReport.updatebulkServices(updateBs);
       updateBs[0].increaseDate='10/20';
        updateBs[0].noticeDueDate='10/10';
                CommunitiesRateIncreaseWorkGridReport.updatebulkServices(updateBs);

    }
}