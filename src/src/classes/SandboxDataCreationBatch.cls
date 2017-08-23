global class SandboxDataCreationBatch implements Database.Batchable<sObject>,Database.AllowsCallouts{
    public String queryString= '';
    public String sql= '';
    public String userName= '';
    public String passwordSecurityToken= '';
    public String tempQuery = '';
    global SandboxDataCreationBatch(String query,String sql,String userName, String passwordSecurityToken){ 
        this.queryString=query;
        this.sql=sql;
        this.userName=userName;
        this.passwordSecurityToken=passwordSecurityToken;
        tempQuery = sql;
    }
    global Database.QueryLocator start(Database.BatchableContext BC) { 
        return Database.getQueryLocator(queryString);
    }
    
    global void execute(Database.BatchableContext BC, List<User> userList){
        SandboxRefreshParam__c customSetttingObj = SandboxRefreshParam__c.getinstance('Account');
        String sql1 = ' LIMIT ' + integer.valueof(customSetttingObj.Limit__c) + ' Offset ' + integer.valueof(customSetttingObj.Offset__c);
        sql += sql1;//' LIMIT ' + customSetttingObj.Limit__c + ' Offset ' + customSetttingObj.Offset__c';
        SandboxRefreshDataCreationHelper.fetchData(sql,userName,passwordSecurityToken);
    }
     
    //Execute Finish logic after execution of batch records completed
    global void finish(Database.BatchableContext BC){ //
            SandboxRefreshParam__c customSetttingObj = SandboxRefreshParam__c.getinstance('Account');
            customSetttingObj.Offset__c += customSetttingObj.Limit__c;
            customSetttingObj.ExternalId_Value__c += customSetttingObj.Limit__c + 100;
            update customSetttingObj;
            String query = 'SELECT Id, Name FROM User LIMIT 1';
            //sql = tempQuery + ' LIMIT ' + customSetttingObj.Limit__c + ' Offset ' + customSetttingObj.Offset__c';
            integer batchsize = 1; 
            if(integer.valueof(customSetttingObj.Offset__c)<=500){
                SandboxDataCreationBatch inst = new SandboxDataCreationBatch(query,tempQuery,userName,passwordSecurityToken); 
                database.executebatch(inst, batchSize);
            }
    }
}