global class QuotaUpdateController{
    public set<id>managerid{get;set;}
    public  Map<String,List<Metric>> result {Set;get;}
    public  Map<String,Decimal> regionalMap {Set;get;}
    public Set<String> regLeadSetUser = new Set<String>();
    public Set<Id> itrRegSetUser = new Set<Id> ();
    public Decimal capCustSetVal = 0.00;
    public List<Goal> goalList = new List<Goal>();
    public string region{get; set;}
    public List<string> month{get; set;}
    public String year{get; set;}
    public string useraemanager{get; set;}
    public string useraAE{get; set;}
    public string userReg{get; set;}
    public List<metric> metricList {get;set;} 
    public Map<Id,Decimal> oldMetricMap = new Map<Id,Decimal>();
    public User itrUser {get;set;}
    public map<String,List<Metric>> strMap{get;set;}
    public map<String,Decimal> metricNameVsTotal{get;set;} 
    public map<String,Decimal> metricNameVsTotalFinal{get;set;}
    public boolean flag {get;set;}
    public boolean flag1 {get;set;}
    public static final string SUPER_USER = 'Super User Group';
    public static final string  XC_MANAGER ='XC Manager';
    public static final string  REGION_VAL = 'Region';
    public static final string  XC_AE ='XC Account Executive';
    public static final string  XC_AE_Contractor = 'XC AE Contractors';
    public static final string UNITS_VAL ='Units';
    public static final string  NEW_BUSINES = 'New Business';
    public String yearVal;
    
    list<user> userAeList ;
    List<GroupMember> groupMember;
    set<Id> groupMemberId;
    Group grp;
    // constructor
    public QuotaUpdateController(ApexPages.StandardController controller) {
       flag =false;
       itrUser = new User();
       groupMember = new List<GroupMember>();
       grp = new Group();
       groupMemberId = new set<Id>();
       itrUser = [select Id,name,ManagerId, Region__c,Sales_Rep_Type__c, profile.name from user where  Id=:UserInfo.getUserId() AND IsActive = True]; 
       grp = [select Id, Name FROM Group WHERE name =: SUPER_USER ];
       groupMember = [SELECT UserOrGroupId FROM GroupMember WHERE GroupId =: grp.id];
       for(GroupMember gm : groupMember ){
          groupMemberId.add(gm.UserOrGroupId);
      }
      month = new List<string>();
      month.add ('Owner - Metric Name');
      month.add ('JAN');
      month.add ('FEB');
      month.add ('MAR');
      month.add ('APR');
      month.add ('MAY');
      month.add ('JUN');
      month.add ('JUL');
      month.add ('AUG');
      month.add ('SEP');
      month.add ('OCT');
      month.add ('NOV');
      month.add ('DEC');
      month.add ('TOTAL');
      month.add ('CAP');
      
    }
    //  Region picklist values
   public list<selectoption> getregionlist(){
       
       set<string> usr = new set<string>() ;
       set<string> xcmanager = new set<string>() ;
    Schema.DescribeFieldResult fieldResult = User.Region__c.getDescribe();
     List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
    list<selectoption> optionsReg= new list<selectoption>();
      if(itrUser.profile.name == XC_MANAGER && itrUser.Sales_Rep_Type__c != REGION_VAL && !groupMemberId.contains(itrUser.id)){
           optionsReg.add(new selectoption(itrUser.Region__c , itrUser.Region__c ));
       } else if(groupMemberId.contains(itrUser.id) ){
           optionsReg.add(new selectoption('--Select Region--' , '--Select Region--')); 
          optionsReg.add(new selectoption('All Regions' , 'All Regions'));      
            
           for( Schema.PicklistEntry f : ple)
               {
                  optionsReg.add(new SelectOption(f.getLabel(), f.getValue()));
                }
                    
         }
         else if(itrUser.Sales_Rep_Type__c == REGION_VAL){
             optionsReg.add(new selectoption(itrUser.Region__c , itrUser.Region__c ));
          }
          else{}
        return optionsReg;
    }
    
     public list<selectoption> getYearlist(){
       Integer CurrentYear = datetime.now().year();
      
       list<selectoption> optionsYear= new list<selectoption>();
       optionsYear.add(new selectoption('--Select Year--','--Select Year--'));
       optionsYear.add(new selectoption(String.valueOf(CurrentYear-1),String.valueOf(CurrentYear-1)));
       optionsYear.add(new selectoption(String.valueOf(CurrentYear),String.valueOf(CurrentYear)));
       optionsYear.add(new selectoption(String.valueOf(CurrentYear+1),String.valueOf(CurrentYear+1)));     
     
       return optionsYear;
    }
    //  AE Manager picklist values
    public list<selectoption> getaeManager(){
        list<selectoption> options= new list<selectoption>();
         userAeList= [select id ,managerid,name from user where profile.name =: XC_MANAGER and region__c =:region AND IsActive = True];
        if(itrUser.profile.name == XC_MANAGER && itrUser.Sales_Rep_Type__c != REGION_VAL  && !groupMemberId.contains(itrUser.id)){
           options.add(new selectoption(itrUser.name , itrUser.name ));
       } else if(groupMemberId.contains(itrUser.id)){
            options.add(new selectoption('--Select AE Manager--', '--Select AE Manager--'));
            for(user c : userAeList){
                options.add(new selectoption(c.id,c.name));
            }
        }else if(itrUser.Sales_Rep_Type__c == REGION_VAL){
            options.add(new selectoption('--Select AE Manager--', '--Select AE Manager--'));
           for( User user : [select id ,managerid,name from user where region__c =: itrUser.region__c and profile.name =: XC_MANAGER AND IsActive = True] ){
            options.add(new selectoption(user.name,user.name));
            }
        }else{}
        return options;
    }
    // AE picklist values
    public list<selectoption> getaeUser(){
        List<User> userAeList1 = new List<User>()  ;
        List<User> userAeList2 =new List<User>() ;
        List<Contractor_Region_Mapping__c> userAEContractorList = new List<Contractor_Region_Mapping__c>();
        userAeList2= [select id ,managerid,name,Sales_Rep_Type__c ,profile.name from user where (profile.name =: XC_AE OR profile.name ='XC Portfolio AE') AND  managerid =: itrUser.Id AND IsActive = True];
        if(useraemanager !=null){
            userAeList1= [select id,name,Region__c ,Sales_Rep_Type__c,profile.name from user where (profile.name =: XC_AE OR profile.name ='XC Portfolio AE') AND manager.Region__c =:region  and  (managerid=:useraemanager OR manager.name =: useraemanager) AND IsActive = True];
        
        }
            userAEContractorList = [select id,name, AE_Contractor__r.Name, Region__c, Reporting_Manager__c from Contractor_Region_Mapping__c where (Reporting_Manager__c =:useraemanager) OR (Reporting_Manager__c =:itrUser.id AND Reporting_Manager__c NOT IN :groupMemberId  ) ];
            list<selectoption> options= new list<selectoption>();
            options.add(new selectoption('--Select AE --', '--Select AE--'));
            if(itrUser.profile.name == XC_MANAGER && itrUser.Sales_Rep_Type__c != REGION_VAL && !groupMemberId.contains(itrUser.id)){                
                for(User usr : userAeList2){
                    options.add(new selectoption(usr.name, usr.name ));
                }   
            }else{}
            if((groupMemberId.contains(itrUser.id)) || (itrUser.Sales_Rep_Type__c == REGION_VAL)){
                     for( user c : userAeList1){
                     options.add(new selectoption(c.name,c.name));
                }           
            }else{}
            
            if(!userAEContractorList.isEmpty()){
                for(Contractor_Region_Mapping__c crm:userAEContractorList){
                    options.add(new selectoption(crm.AE_Contractor__r.Name,crm.AE_Contractor__r.Name));
                }
                
            } 
            
        return options;
    }
    // Display Metic values based on AE selection pickilist
    public void getMetricList() { 
    
     String ownerMetric='' ;    
        strMap = new map<String,List<Metric>> ();
        regionalMap = new Map<String,Decimal> ();
        metricNameVsTotal = new Map<String,Decimal> ();
          if(useraAE == '--Select AE --')  {
              getMetricListAe();
          } else{  
             List<Goal> goalList = [SELECT Id,Name,ownerId ,DueDate,owner.name,(select id,goal.owner.name,owner.name,name,TargetValue from metrics ) from goal where  owner.name =: useraAE and region__c=:region  ];  
    
    
    
             for(Goal g : goallist){
             for(Metric metric : g.metrics){
                if (g.DueDate != null){
                    yearVal = string.valueOf(g.DueDate.year());   
                }
                if((yearVal == year) && (year != '--Select Year--')){
                
              ownerMetric = metric.owner.name+'-'+metric.Name;
              List<metric> namelist = new List<metric>()  ;  
               if(strMap.containsKey(ownerMetric)){            
                namelist = strMap.get(ownerMetric);
                }
                namelist.add(metric);
                namelist.sort();
                strMap.put(ownerMetric,namelist);
                oldMetricMap.put(metric.Id,metric.targetvalue);
                regionalMap.put(ownerMetric,0.00);
                metricNameVsTotal.put(ownerMetric,0.00);
                //metricNameVsTotalFinal.put(ownerMetric,0.00);
             }
            }
       }
          if(!strMap.isEmpty()){
                flag1 = true;
            }
            else {
                flag1 = false;    
            }                 
            result = strMap;
      }
  } 
  
  
  // Displaying the metric list based on user logged in User
   public  void getMetricListAe() { 
      strMap = new map<String,List<Metric>> ();
      metricNameVsTotal = new Map<String,Decimal>();
      regionalMap = new Map<String,Decimal> ();
      List<Goal> goalList = new List<Goal>();
      String ownerMetric='' ;
      set<Id> aeId = new set<Id>();
      
         
      if((useraemanager== '--Select AE Manager--')){
              getMetricLists();
          }
         else{
       for(User u : [select id, name,managerid, profile.name from user where (profile.name =: XC_AE OR profile.name ='XC Portfolio AE') and   managerId =: itrUser.id AND IsActive = True]){
         aeId.add(u.id);
       }
        if(itrUser.profile.name == XC_MANAGER  && itrUser.Sales_Rep_Type__c != REGION_VAL){
            goalList = [SELECT Id,Name,ownerId ,DueDate,owner.name,(select id,goal.owner.name,owner.name,name,TargetValue from metrics ) from goal where ownerId IN : aeId]; 
         }
        else if(groupMemberId.contains(itrUser.id) || useraemanager != null){
        Set<Id> userid = new Set<Id> ();
             if(useraemanager != null){
                    for(User itrUser1 : [SELECT Id ,profile.name FROM User WHERE (profile.name =: XC_AE OR profile.name ='XC Portfolio AE') AND (managerid=:useraemanager OR manager.name =: useraemanager) AND IsActive = True]) {
                        userid.add(itrUser1.Id);
                    }
                }
        goalList = [SELECT Id,Name,ownerId ,DueDate,owner.name,(select id,goal.owner.name,owner.name,name,TargetValue from metrics  ) from goal where ownerId IN : userid  ]; 
        }
        else if(itrUser.Sales_Rep_Type__c == REGION_VAL ){
            list<user> userlst = [select id,name,Region__c,profile.name from user where  Region__c =: itrUser.Region__c and profile.name =: XC_MANAGER AND IsActive = True];
            goalList = [SELECT Id,Name,ownerId ,DueDate,owner.name,(select id,goal.owner.name,owner.name,name,TargetValue from metrics ) from goal where ownerId IN : userlst AND sales_rep_type__c != 'Region']; 
            
         }  
           for(Goal g : goallist){
             for(Metric metric : g.metrics){
                ownerMetric = metric.owner.name+'-'+ metric.Name;
               if (g.DueDate != null){
                    yearVal = string.valueOf(g.DueDate.year());   
                }
                if((yearVal == year)&& (year != '--Select Year--')){
                   
                List<metric> namelist = new List<metric>()  ;  
                    if(strMap.containsKey(ownerMetric)){            
                        namelist = strMap.get(ownerMetric);
                    }
                namelist.add(metric);
                namelist.sort();
                strMap.put(ownerMetric,namelist);
                oldMetricMap.put(metric.Id,metric.targetvalue);
                regionalMap.put(ownerMetric,0.00);
                metricNameVsTotal.put(ownerMetric,0.00);
               
                }
                 
              }
           }  
           if(!strMap.isEmpty()){
               flag1 = true;
            }
            else {
                flag1 = false;    
            }     
     result = strMap;
     
         }
    }
      public void getMetricLists() {
        
         String ownerMetric='' ;
         String ownerMetric1='' ;
         strMap = new map<String,List<Metric>> ();
         metricNameVsTotal = new Map<String,Decimal>();
         regionalMap = new Map<String,Decimal> ();
         Set<Id>itrSetUser = new Set<Id> ();
         Set<String>itrRegLeadSetUser = new Set<String> ();
         List<Goal> goalList = new List<Goal>();
         List<Goal> goalListReg = new List<Goal>();
         if(region == 'All Regions')
        { 
            regMetricList();
            }else{   
                for(User itrUser1 : [select id,managerid,Sales_Rep_Type__c,region__c,profile.name,name from user where profile.name =: XC_MANAGER and region__c =:region AND IsActive = True ]) {
                  itrSetUser.add(itrUser1.Id);
                 
                }
             
              goalList = [SELECT Id,Name,ownerId ,DueDate,owner.name,Sales_Rep_Type__c,(select id,goal.owner.name,owner.name,name,TargetValue from metrics ) from goal where ownerId IN :itrSetUser AND Sales_Rep_Type__c != 'Region' ]; 
             
            Map<String, QuotaCAPValues__c> capCustomSetMap = new Map<String, QuotaCAPValues__c>();
            for(Goal g : goallist){
             for(Metric metric : g.metrics){
                    ownerMetric = metric.owner.name+'-'+ metric.Name;
                    if (g.DueDate != null){
                    yearVal = string.valueOf(g.DueDate.year());   
                }
                if((yearVal == year) && (year != '--Select Year--')){
                    regionalMap.put(ownerMetric,0.00);
                    metricNameVsTotal.put(ownerMetric,0.00);
                    List<metric> namelist = new List<metric>()  ;  
                    if(strMap.containsKey(ownerMetric) ){            
                     namelist = strMap.get(ownerMetric);
                    }
                    namelist.add(metric);
                    namelist.sort();
                    strMap.put(ownerMetric,namelist);
               
                    
                    oldMetricMap.put(metric.Id,metric.targetvalue);
                } 
            }
        }          
           if(!strMap.isEmpty()){
               flag1 = true;
            }
            else {
                flag1 = false;    
            }     
     result = strMap;
     
    } 
    }
    
    public void regMetricList() {
         String ownerMetric='' ;
         strMap = new map<String,List<Metric>> ();
         metricNameVsTotal = new Map<String,Decimal>();
         
         
         regionalMap = new Map<String,Decimal> ();
         List<Goal> goalListReg = new List<Goal>();
            for(User itrRegUser : [select id,managerid,Sales_Rep_Type__c,region__c,profile.name,name from user where profile.name =: XC_MANAGER and Sales_Rep_Type__c = 'Region' AND IsActive = True ]) {
                itrRegSetUser.add(itrRegUser.Id);
                regLeadSetUser.add(itrRegUser.name);
                
            }
            goalListReg = [SELECT Id,Name,ownerId ,DueDate,sales_rep_type__c,owner.name,Region__c,(select id,goal.owner.name,owner.name,name,TargetValue,goal.region__c from metrics ) from goal where ownerId IN :itrRegSetUser AND sales_rep_type__c = 'Region' ];
            
            Map<String, QuotaCAPValues__c> capCustomSetMap = QuotaCAPValues__c.getAll();
            for(Goal g : goalListReg){
             for(Metric metric : g.metrics){
                 
                 Decimal tempTotal = 0;
                 ownerMetric = metric.owner.name+'-'+metric.Name+'-Region';
                 if (g.DueDate != null){
                    yearVal = string.valueOf(g.DueDate.year());   
                }
                if((yearVal == year) && (year != '--Select Year--')){
                 if((metric.Targetvalue != NULL) && (metric.Targetvalue != 0.00))
                    {
                     for(QuotaCAPValues__c cusSet: capCustomSetMap.values()){
                         if(cusSet.Name == g.Region__c){
                            if(metric.Name == 'Total Units'){
                             capCustSetVal = cusSet.Total_Units__c;
                            }else if(metric.Name == 'New Business'){
                               capCustSetVal = cusSet.New_Business__c;
                            }
                             if(g.Sales_Rep_Type__c == 'Region')                        
                             regionalMap.put(ownerMetric,capCustSetVal);
                         }
                     }
                     
                        if(metricNameVsTotal.containsKey(ownerMetric)){
                            tempTotal = metricNameVsTotal.get(ownerMetric);
                        }
                           tempTotal += metric.Targetvalue;
                        
                        if(g.Sales_Rep_Type__c == 'Region')
                        metricNameVsTotal.put(ownerMetric,tempTotal);
                        
                       
                        List<metric> namelist = new List<metric>()  ;  
                        if(strMap.containsKey(ownerMetric)){            
                            namelist = strMap.get(ownerMetric);
                        }
                        namelist.add(metric);
                        namelist.sort();
                        strMap.put(ownerMetric,namelist);
                        oldMetricMap.put(metric.Id,metric.targetvalue);
                        
                    } 
                    
                    
                }
              }
           }
            
           if(!strMap.isEmpty()){
               flag1 = true;
            }
            else {
                flag1 = false;    
            }     
     result = strMap;
    
    } 
    
  // save method
  public pagereference savemethod() {
      Map<String, Decimal> oldMetricNameVsTotal = new Map<String,Decimal>(metricNameVsTotal);
       metricNameVsTotalFinal = new Map<String,Decimal>();
        MetricTriggerController.allowValidation=false;
        List<Metric> metricList = new List<Metric>();
        List<Metric> metricList1 = new List<Metric>();
        List<decimal> totalList =  new List<decimal>();
        Map<String, List<Metric>> ownerMetricListForRegionMap = new Map<String, List<Metric>>(); 
        Map<String, Decimal> totalRegMap =  new Map<String, Decimal>();
       
        
        for(String ownerMetricName : strMap.keySet()){
            boolean isChanged = false;
            Decimal finalTarget = 0;
            for(Metric meticObj : strMap.get(ownerMetricName)){ 
                String ownerMetric = meticObj.owner.name+'-'+ meticObj.Name; 
                if((meticObj.Targetvalue != NULL) && (meticObj.Targetvalue != 0.00) ){        
                    if((meticObj.TargetValue != oldMetricMap.get(meticObj.Id))&& (itrRegSetUser.contains(meticObj.ownerId))){
                        isChanged = true;
                        
                    }
                    if(itrRegSetUser.contains(meticObj.ownerId)){
                        if((meticObj.name == 'Total Units') || (meticObj.name == 'New Business'))
                        {
                            if(metricNameVsTotalFinal.containsKey(ownerMetric)){
                                finalTarget = metricNameVsTotalFinal.get(ownerMetric);
                            }
                                finalTarget += meticObj.Targetvalue; 
                           
                        }
                       
                        if((isChanged == true))
                        {
                            
                            metricNameVsTotalFinal.put(ownerMetricName,finalTarget);
                            if(meticObj.TargetValue != oldMetricMap.get(meticObj.Id)){
                                List<Metric> tempList = new List<Metric>(); 
                                if(ownerMetricListForRegionMap.containsKey(ownerMetricName)){
                                    tempList = ownerMetricListForRegionMap.get(ownerMetricName);
                                }
                                tempList.add(meticObj);
                                ownerMetricListForRegionMap.put(ownerMetricName,tempList);
                                
                            }
                           
                        }
                         
                    
                    }
                    else if(!metricNameVsTotalFinal.containsKey(ownerMetric) && (meticObj.TargetValue != oldMetricMap.get(meticObj.Id))  ){
                        metricList.add(meticObj);
                    
                   }
                }
            }  
        }
       
                    
     
         
        
        for(String ownerMetricName : metricNameVsTotalFinal.keySet()){
            boolean targetNotEqual = false;    
            for(String ownerName : regionalMap.keySet()){
                if(ownerMetricName == ownerName){
                    if(ownerName.contains('-Region')){
                        if(metricNameVsTotalFinal.get(ownerMetricName) != regionalMap.get(ownerName)) {
                           targetNotEqual = true;
                          
                        } else{
                            if(ownerMetricListForRegionMap.containsKey(ownerMetricName)){
                               metricList1.addAll(ownerMetricListForRegionMap.get(ownerMetricName));
                            }
                        }
                        if((targetNotEqual==true)&& (metricNameVsTotalFinal.get(ownerMetricName) != regionalMap.get(ownerName)))  {
                          ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Below records have errors:'+ ownerMetricName+': Total and CAP should match')); 
                        }                 
                    }               
                }
            }
        }
           if(!metricList.isEmpty()){
             database.saveResult[] res = Database.Update(metricList,false);
             ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM,'Record Updated Successfully.!'));
            }
            if(!metricList1.isEmpty()){
               ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM,'Record Updated Successfully.!'));
               database.saveResult[] res1 = Database.Update(metricList1,false); 
            }
       
       flag1 = true;
        return null;
    }
    public pagereference cancelMethod() {
        pagereference pg = new pagereference('/apex/QuotaUpdateScreen');
        pg.setRedirect(true);
         flag1 = true;
        return pg;
        
    } 
}