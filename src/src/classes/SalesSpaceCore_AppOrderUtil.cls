global class SalesSpaceCore_AppOrderUtil {
    public static void createProfileSpecificEntries(){
        DELETE [SELECT Id FROM SalesSpace_Profile_Specific_App_Ordering__c];
        String[] lAppNames=new String[]{'BCD_Travel_Portal','Box_com','CARPro','Coach','Comcast_Now','Comcast_Store','Comcast_Training_Portal','Communities','CSE_Marketing_Items_for_XC','Einstein','MDU_Health_Scorecard','NRSA','OBI_for_Xfinity_Communities','OTM_Lead_Submission_Tool','Watchtower','XC_Tableau_Reporting','XCSales_com','XFINITY_Communities_Sharepoint','XFINITY_Rewards'};
        List<AppMenuItem> lApps=[Select id, ApplicationId, Name from AppMenuItem WHERE Name IN :lAppNames ORDER BY Name];
        System.debug(System.LoggingLevel.DEBUG,lApps.size());
        System.debug(System.LoggingLevel.DEBUG,lApps);

        Map<String,Integer[]> mProfiles = new Map<String,Integer[]>();
        mProfiles.put('XC Manager',new Integer[]{17,16,-1,2,15,11,14,1,8,13,9,7,4,-1,12,3,5,6,10});
        mProfiles.put('XC Account Executive', new Integer[]{-1,10,-1,6,9,-1,8,1,-1,11,-1,7,4,-1,-1,2,3,5,-1});
        mProfiles.put('XC Portfolio AE', new Integer[]{14,12,-1,6,11,-1,10,1,-1,13,8,7,4,-1,9,2,3,5,-1});
        mProfiles.put('XC AE Contractors', new Integer[]{-1,-1,-1,-1,-1,-1,-1,1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1});
        mProfiles.put('Xfinity CAR Manager', new Integer[]{-1,15,5,6,14,11,13,1,9,16,12,-1,2,4,-1,3,7,8,10});
        mProfiles.put('Xfinity CAR', new Integer[]{-1,15,5,6,14,11,13,1,9,16,12,-1,2,4,-1,3,7,8,10});
        mProfiles.put('XC Sales Support', new Integer[]{-1,11,-1,-1,10,-1,9,1,7,8,-1,5,3,-1,-1,6,2,4,-1});
        mProfiles.put('XC SME', new Integer[]{-1,11,12,-1,10,-1,9,1,6,8,7,-1,3,-1,-1,2,4,5,-1});
        mProfiles.put('XC Analyst', new Integer[]{-1,9,-1,6,7,-1,8,1,-1,-1,-1,-1,4,-1,-1,5,2,3,-1});
        mProfiles.put('XC Paralegals', new Integer[]{-1,9,-1,6,7,-1,8,1,-1,-1,-1,-1,4,-1,-1,5,2,3,-1});

        List<SalesSpace_Profile_Specific_App_Ordering__c> lSSPSAOs=new List<SalesSpace_Profile_Specific_App_Ordering__c>();

        for (String key : mProfiles.keySet())  { //CWD-- loop through the set of profiles
            Integer[] lAppOrdering= mProfiles.get(key); //CWD-- grab the ordering for the profile
            List<String> lAppListForProfile = new List<String>();
            String[] lSpecificOrder=new String[lApps.size()];

            for(AppMenuItem ami : lApps){ //CWD-- loop the list of apps
                System.debug(System.LoggingLevel.DEBUG,ami.name);
                Integer nameIndex = null;
                Integer i = 0;
                for (String appName : lAppNames) { //CWD-- loop through the names
                  if ( appName == ami.name) { //CWD-- if the name matches the current app
                    nameIndex = i; //CWD-- set the index of the app. Should prolly break on find
                  }
                  i++;
                }

                if (nameIndex != null) { //CWD-- if we found the app
                    Integer orderLocation = lAppOrdering[nameIndex]; //CWD-- get the ording position of the app

                    if (orderLocation != -1) { //CWD-- if it's not -1
                        lSpecificOrder[orderLocation] = ami.Id; //ApplicationId; //CWD-- set the app's Id at the right location
                        System.debug(System.LoggingLevel.DEBUG,key+'='+ami.name+'/'+ami.ApplicationId+':'+orderLocation);
                    }
                }
            }

            for(Integer jj=0; jj<lSpecificOrder.size();++jj) //CWD-- loop the newly created list of Ids in order
            {
                String s=lSpecificOrder[jj];

                if(s!=null){ //CWD-- if we've an id there then
                    lAppListForProfile.add(s); //CWD-- set it on the list for the profile
                }
            }

            System.debug(System.LoggingLevel.DEBUG,key+'='+String.join(lAppListForProfile,','));
            lSSPSAOs.add(new SalesSpace_Profile_Specific_App_Ordering__c (Profile_Identifier__c=key,
                App_Ids_Csv_Str__c=String.join(lAppListForProfile,','))); //CWD-- create a new ordering record for the Profile
        }

        if(lSSPSAOs.size()>0){
            System.debug(System.LoggingLevel.DEBUG,lSSPSAOs.size()+' to insert');
            System.debug(System.LoggingLevel.DEBUG,lSSPSAOs);
            insert lSSPSAOs;
        }
    }
}