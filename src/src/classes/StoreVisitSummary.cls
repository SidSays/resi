/**
 * Decorator class to aggregate summary results for a store visit
 *
 * @author  Ryan Sayles     <rsayles@acumensolutions.com>
 * @author  Sahil Grover    <sgrover@acumensolutions.com>
 * @Last Modified By: Shraddha Patil
 * @Last Modified Data: 9th June 2017
 * @Description: Code changes to display appropriate Required activities for users other than Store visit owner
 * @User Store: US1118657(Indirect - VF Snippet on Store Visit record page - Required Activities)      
 */

public virtual with sharing class StoreVisitSummary {

    public final Store_Visit__c StoreVisit {get; private set;}
    public final Account Store {get; private set;}
    public final List<RequiredStoreActivity> RequiredActivities {get; private set;}
    public final List<Task> VisitTasks {get; private set;}
    public Integer NumberOfRequiredActivities {get; private set;}
    public String StoreDisplayName;

    public Integer NumberOfRemainingActivities {
        get {
            if (remainingActivities < 0) {
                return 0;
            }
            return remainingActivities;
        }
    }

    public Integer PercentOfCompletedActivities {
        get {
            Integer numberOfCompletedActivities = this.NumberOfRequiredActivities - this.NumberOfRemainingActivities;
            if (numberOfCompletedActivities > this.NumberOfRequiredActivities || this.NumberOfRequiredActivities == 0) {
                return 100;
            }

            return (Integer)(((Decimal.valueOf(numberOfCompletedActivities) / Decimal.valueOf(this.NumberOfRequiredActivities))).setScale(2) * 100);
        }
    }

    public Boolean IsVisitActive {
        get {
            return this.StoreVisit.Start_Date_Time__c != null && this.StoreVisit.End_Date_Time__c == null;
        }
    }

    public Boolean IsVisitComplete {
        get {
            return this.StoreVisit.Start_Date_Time__c != null && this.StoreVisit.End_Date_Time__c != null;
        }
    }

    public String TimeSpentInStore {
        get {
            DateTime endDateTime = DateTime.now();
            if (this.StoreVisit.End_Date_Time__c != null) {
                endDateTime = this.StoreVisit.End_Date_Time__c;
            }
            Long msInStore = endDateTime.getTime() - this.StoreVisit.Start_Date_Time__c.getTime();
            return StoreVisitUtility.convertMsToTimeDisplay(msInStore);
        }
    }

    public Integer NumberOfCompletedTasks {
    
        get {
            Integer numberCompleted = 0;
            /*for (Task visitTask : this.VisitTasks) {
                if (visitTask.Status == 'Completed') {
                    numberCompleted++;
                }
            }
            system.debug('numberCompleted >>>>'+numberCompleted);
             system.debug('VisitTasks >>>>'+this.VisitTasks);*/
            List<Task> visitTask = [SELECT id,Status, accountId from Task where accountId =: this.StoreVisit.Store__c ];
            system.debug('visitTaskList >>>>'+visitTask);
            for(Task vt : visitTask){
                if (vt.Status == 'Completed') {
                    numberCompleted++;
                }
                
            }
            system.debug('numberCompleted >>>>'+numberCompleted);
            return numberCompleted;
        }
    }

    public DateTime StartDateTime {
        get {
            return StoreVisitUtility.getLocalTimeFromGmt(this.StoreVisit.Start_Date_Time__c);
        }
    }

    public DateTime EndDateTime {
        get {
            return StoreVisitUtility.getLocalTimeFromGmt(this.StoreVisit.End_Date_Time__c);
        }
    }

    private Integer remainingActivities = 0;

    public StoreVisitSummary(final Account store, final Store_Visit__c storeVisit, final List<RequiredStoreActivity> requiredActivities) {
        this(store, storeVisit, requiredActivities, new List<Task>());
    }

    public StoreVisitSummary(
        final Account store, 
        final Store_Visit__c storeVisit, 
        final List<RequiredStoreActivity> requiredActivities,
        final List<Task> visitTasks
        ) {

        this.Store = store;
        this.storeVisit = StoreVisit;
        if(storeVisit.Old_records__c != true && store != null )
        {   
            
             /***********************************
             * @Last Modified By: Shraddha Patil
             * @Last Modified Data: 9th June 2017
             * @Description: Code changes to display appropriate Required activities for users other than Store visit owner
             * @User Store: US1118657(Indirect - VF Snippet on Store Visit record page - Required Activities)--Start      
             ***********************************/
             
            User visitOwner = StoreQueryUtility.queryUser(storeVisit.OwnerId);
            UserRole role = StoreQueryUtility.queryUserRole(visitOwner.UserRoleId);
            
            /***********************************
            * @User Store: US1118657(Indirect - VF Snippet on Store Visit record page - Required Activities)--End
             ***********************************/
            
            List<Store_Visit_Activity_Category__c> requiredActivity = [SELECT Record_Type_Id__c,New_Records__c,Store_Type__c,User_Role__c,
                                                                         Number_Required__c       
                                                                        FROM Store_Visit_Activity_Category__c
                                                                        WHERE Store_Type__c = :Store.Store_Type__c AND User_Role__c = :role.DeveloperName
                                                                        AND New_Records__c = true AND Number_Required__c > 0
                                                                        ORDER BY Number_Required__c DESC];
           
           this.NumberOfRequiredActivities = requiredActivity.size();
           List<String> recordTypes = new List<String>();
            for(Store_Visit_Activity_Category__c cate:  requiredActivity )
            {
            recordTypes.add(cate.Record_Type_Id__c);
            }                                                                       
                                                                        
              List<Store_Activity__c> completedActivities = [SELECT Id,Is_Activity_Completed_New__c,RecordTypeId,Store__c   
                                                            FROM Store_Activity__c
                                                            WHERE Store_Visit__c = :storeVisit.Id and 
                                                            RecordTypeId IN :recordTypes and Store__c != null
                                                            AND Is_Activity_Completed_New__c = true
                                                            ];                                                          
            this.remainingActivities = this.NumberOfRequiredActivities - completedActivities.size();
        }
        else
        {
        this.NumberOfRequiredActivities = 0;
        this.RequiredActivities = requiredActivities;
        for (RequiredStoreActivity requiredActivity : this.RequiredActivities) {
            if (requiredActivity.StoreActivityCategory.Number_Required__c == 0) {
                continue;
            }
            Integer numberRequired = (Integer)requiredActivity.StoreActivityCategory.Number_Required__c;
            Integer numberCompleted = requiredActivity.getNumberOfCompletedActivities();
            this.NumberOfRequiredActivities += numberRequired;
            Integer remaining = numberRequired - numberCompleted;
            this.remainingActivities += (remaining < 0 ? 0 : remaining);
        }
        }
        this.VisitTasks = visitTasks;
    }

    public virtual String getStoreDisplayName(){
        if (String.isBlank(this.Store.Store_Nickname__c)) {
            return this.Store.Name;
        } else {
            return this.Store.Store_Nickname__c;
        }
    }

    public static StoreVisitSummary createSummary(
        final Account store, 
        final Store_Visit__c storeVisit, 
        final List<RequiredStoreActivity> requiredActivities,
        final List<Task> visitTasks
        ) {
        if (store == null) {
            return new ProspectiveStoreVisitSummary(storeVisit, requiredActivities, visitTasks);
        }
        else {
            return new StoreVisitSummary(store, storeVisit, requiredActivities, visitTasks);
        }
    }

}