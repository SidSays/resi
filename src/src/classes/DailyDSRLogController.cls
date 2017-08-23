/**
  * Class Name: DailyDSRLogController
  * Author: Amitkumar Bangad, Accenture
  * Date: 23-May-2013
  * Requirement # Request Id: 241, 242,243,244,245
  * Description: Contains supporting actions for VF page DailyDSRLog to display DSR locations on Map
  * Last Modified :Tejaswini kasar (10th Aug 2017)
  * Description : US1147215(System Engineering : SDM is not able to view the XSP location in MAP view)
  */
 public class DailyDSRLogController {
     private User user;
     public String mapDataPointsStr {get; set;}
     public Utility__c utilObj {get; set;}
     public List < Task > knockList {get; set;}
     public Map < Id, Customer_Address__c > addressMap {get; set;}
     public Set < Id > knockAddressIds;
     public list < cLocation > locationHistoryList {get; set;}
     public string selectedRep {get; set;}
     public string selectedTeam {get; set;}
     public string sRegion {get; set;}
     public string selectedMapType {get; set;}
     public string selectedRegion {get; set;}
     public string locationStatusMessage {get; set;}
     public cLocation cfirstDataPoint {get; set;}
     public cLocation clastDataPoint {get; set;}
     public cLocation cfirstDisposition {get; set;}
     public cLocation clastDisposition {get; set;}
     public boolean bDisplayFilters {get; set;}
     public boolean bMapValid {get; set;}
     public boolean bproxExc {get; set;}
     public string RoleName;
     public Map < String, List < cLocation > > gpsKnockMap;
     public User repUser {get; set;}
     public List < DailyDSRLogController.cTableView > tableData {get; set;}
     public final Id RecTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Knock').getRecordTypeId();
     public List < SelectOption > repList {get; set;}
     public List < SelectOption > teamList {get; set;}
     public Map < String, Id > userRoleMap;
     public List < selectOption > getRegionValues() {
         List < SelectOption > options = new List < SelectOption > ();
         options.add(new SelectOption('', ''));
         for (Division d: [select id, name from Division WHERE IsActive = true ORDER BY Name]) {
             options.add(new SelectOption(d.name, d.name));
         }
         return options;
     }

     /**
      * Constructor /Paramameter initializations
      */
     public DailyDSRLogController() {
         userRoleMap = new Map < String, Id > ();
         locationHistoryList = new List < cLocation > ();
         gpsKnockMap = new Map < String, List < cLocation > > ();
         addressMap = new Map < Id, Customer_Address__c > ();
         repList = new List < SelectOption > ();
         teamList = new List < SelectOption > ();
         tableData = new List < DailyDSRLogController.cTableView > ();
         utilObj = new Utility__c();
         knockList = new List < Task > ();
         repUser = new User();
         bproxExc = false;
         knockAddressIds = new Set < Id > ();
         bDisplayFilters = false;
         bMapValid = false;
         for (UserRole ur: [select id, name from UserRole]) {
             userRoleMap.put(ur.name, ur.id);
         }
         user = [select id, Division, defaultDivision, userroleId, userrole.DeveloperName from User where id = : userInfo.getUserId()];
         if (user.userRoleId != null) {
             //UserRole ur = [select id, name from UserRole where id = : user.UserRoleId];
             RoleName = user.userrole.DeveloperName;
             system.debug(RoleName);
             if (RoleName == null) {
                 RoleName = Label.SystemAdminProfileName;
             }
             if (Label.Log_RoleString.contains(RoleName)) {
                 bDisplayFilters = true;
             } else {
                 bDisplayFilters = false;
             }
         } else {
             apexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, Label.No_UserRole_Error));
         }
         selectedMapType = '0';
         getReps();
         getTeams();
     }

     /**
      * @Description: This method changes the DSR list when region changes.
      * @Author: Amitkumar Bangad, Accenture
      * @Date: 23-May-2013
      * @Param: None
      * @Return: void.
      */
     public void changeRegions() {
         repList.clear();
         getReps();

        teamList.clear();
         getTeams();
     }

    /**
    * @Description: This method processes the data as per the view selected by User on UI.
    * @Author: Amitkumar Bangad, Accenture
    * @Date: 23-May-2013 
    * @Param: None
    * @Return: void.
    */
    public pageReference processRepView(){
        if (selectedMapType == '0'){
            apexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, LAbel.No_View_Selected));
        } else{
            if (selectedRep != 'NONE'){
                cLocation latestLoc = new cLocation();
                cLocation thisLoc = new cLocation();
                DateTime recentLoc;
                if (selectedMapType == '1'){
                    bproxExc = false;
                    for(Location__c loc : [Select Id, CreatedDate, OwnerId, Name, Geocode_TimeStamp__c, Timestamp__c, Latitude__c,                       Longitude__c  from Location__c 
                                           where OwnerId=: selectedRep 
                                           AND createdDate >= : System.Now().addMinutes(- 120)
                                           ORDER BY Geocode_TimeStamp__c DESC limit 1]){
                        thisLoc.platitude = String.Valueof(loc.Latitude__c);
                        thisLoc.plongitude = String.Valueof(loc.Longitude__c);
                        thisLoc.comcastDate = string.valueof(loc.CreatedDate);
                        thisloc.rUser = repUser;                                        
                        bMapValid = true;
                        String[] dateParts = loc.Geocode_TimeStamp__c.split('-',0);
                    
                        String[] timeParts = dateParts[3].split(':',0);
                        String seconds = timeParts[2];
                        //US1147215(System Engineering : SDM is not able to view the XSP location in MAP view)
                        //Added By :Tejaswini kasar
                        //Logic added to handle 12 hr as well as 24 hr format of Geocode_TimeStamp__c(Start)
                        if(seconds.contains('PM')){
                            if( timeParts[0].contains('12')){
                                timeParts[0] = '12';
                                timeParts[2] = timeParts[2].substring(0,seconds.length()-3);
                            }else{
                                timeParts[0] = String.ValueOf(Integer.ValueOf(timeParts[0]) + 12);
                                 timeParts[2] = timeParts[2].substring(0,seconds.length()-3);
                            }
                        }else if(seconds.contains('AM')){
                            if( timeParts[0].contains('12')){
                                timeParts[0] = '00';
                                timeParts[2] = timeParts[2].substring(0,seconds.length()-3);
                            }else{
                                timeParts[0] = String.ValueOf(Integer.ValueOf(timeParts[0]));
                                timeParts[2] = timeParts[2].substring(0,seconds.length()-3);
                            }
                        }
                        //End
                        Datetime myDate;
                        if(recentLoc == null){
                            myDate = datetime.newInstance(integer.valueof(dateParts[0]), integer.valueof(dateParts[1]),integer.valueof(dateParts[2]), integer.valueof(timeParts[0]), integer.valueof(timeParts[1]), integer.valueof(timeParts[2]));
                            recentLoc = myDate;                                                       
                        } else{
                            myDate = datetime.newInstance(integer.valueof(dateParts[0]), integer.valueof(dateParts[1]),integer.valueof(dateParts[2]), integer.valueof(timeParts[0]), integer.valueof(timeParts[1]), integer.valueof(timeParts[2]));
                            if(myDate > recentLoc){
                                recentLoc = myDate;
                            }
                        }
                        thisloc.pDateTime = myDate;
                        thisLoc.pLeftTime=thisLoc.pDateTime.format('h:mm a');
                        thisLoc.pRightTime=thisLoc.pDateTime.format('h:mm a');
                        thisLoc.gMapsLink= '<a href="#" onclick="javascript:window.open(\'http://maps.google.com/?q='+thisLoc.pLatitude +','+thisLoc.pLongitude+'\')">'+thisLoc.pLatitude+','+thisLoc.pLongitude+'</a>';
                        thisLoc.sMapLinkText='\'http://maps.google.com/?q='+thisLoc.platitude +','+thisLoc.plongitude+'\'';
                        thisLoc.formattedDate = thisLoc.pDateTime.format();
                        thisLoc.key=thisLoc.comcastDate;
                        locationHistoryList.add(thisLoc);
                    } 
                    if(recentLoc != null){
                        latestLoc = locationHistoryList[0];
                        locationStatusMessage = Label.Last_Location + ' ' + repUser.name + ' ' +'on' + ' ' + recentLoc.format();
                    } else{
                        apexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO, Label.No_Location_History + ' ' + repUser.name));
                        bMapValid = false;
                    }
                }else{
                    if (utilObj.Date_Field__c == null){
                        apexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, Label.No_Date_Error));
                        bMapValid = false;
                    }
                    else if (utilObj.Date_Field__c.addDays(Integer.valueOf(ConfigurableParameters__c.getValues('LocationPullUpLimit').NumberValue__c)) < system.today() || utilObj.Date_Field__c > system.today()){
                        apexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, Label.Valid_Date_Error1 + ' ' + Integer.valueof(ConfigurableParameters__c.getValues('LocationPullUpLimit').NumberValue__c) + ' ' + Label.Valid_Date_Error2));
                        bMapValid = false;
                        return null;
                    } else{
                        if (selectedMapType == '2'){
                            bproxExc = false;
                            recentLoc = null;
                            latestLoc = new cLocation();
                            Datetime dt1 = Datetime.newInstance(utilObj.Date_Field__c, Time.newInstance(0, 0, 0, 0));
                            Datetime dt2 = Datetime.newInstance(utilObj.Date_Field__c, Time.newInstance(23, 59, 59, 0));
                            for(Location__c loc : [Select Id, OwnerId, Name, Geocode_TimeStamp__c,CreatedDate, Timestamp__c, Latitude__c, Longitude__c  from Location__c 
                                                            where OwnerId=: selectedRep 
                                                            and CreatedDate > : dt1
                                                            and CreatedDate < : dt2
                                                            ORDER BY Geocode_TimeStamp__c ASC limit 300]){
                                thisLoc = new cLocation();                            
                                thisLoc.platitude = String.Valueof(loc.Latitude__c);
                                thisLoc.plongitude = String.Valueof(loc.Longitude__c);
                                thisloc.rUser = repUser;                                        
                                bMapValid = true;
                                String[] dateParts = loc.Geocode_TimeStamp__c.split('-',0);
                                String[] timeParts = dateParts[3].split(':',0);
                                //US1147215(System Engineering : SDM is not able to view the XSP location in MAP view)
                                //Added By :Tejaswini kasar
                                //Logic added to handle 12 hr as well as 24 hr format of Geocode_TimeStamp__c(Start)
                                String seconds = timeParts[2];
                                if(seconds.contains('PM')){
                                    if( timeParts[0].contains('12')){
                                        timeParts[0] = '12';
                                        timeParts[2] = timeParts[2].substring(0,seconds.length()-3);
                                    }else{
                                            timeParts[0] = String.ValueOf(Integer.ValueOf(timeParts[0]) + 12);
                                            timeParts[2] = timeParts[2].substring(0,seconds.length()-3);
                                    }
                                }else if(seconds.contains('AM')){
                                    if( timeParts[0].contains('12')){
                                        timeParts[0] = '00';
                                        timeParts[2] = timeParts[2].substring(0,seconds.length()-3);
                                    }else{
                                        timeParts[0] = String.ValueOf(Integer.ValueOf(timeParts[0]));
                                        timeParts[2] = timeParts[2].substring(0,seconds.length()-3);
                                    }
                                }
                                //End
                                Datetime myDate;
                                if(recentLoc == null){
                                    myDate = datetime.newInstance(integer.valueof(dateParts[0]), integer.valueof(dateParts[1]),integer.valueof(dateParts[2]), integer.valueof(timeParts[0]), integer.valueof(timeParts[1]), integer.valueof(timeParts[2]));
                                    recentLoc = myDate;
                                } else{
                                    myDate = datetime.newInstance(integer.valueof(dateParts[0]), integer.valueof(dateParts[1]),integer.valueof(dateParts[2]), integer.valueof(timeParts[0]), integer.valueof(timeParts[1]), integer.valueof(timeParts[2]));
                                    if(myDate > recentLoc){
                                        recentLoc = myDate;
                                    }
                                }
                                thisLoc.comcastDate = string.valueof(loc.CreatedDate);
                                thisloc.pDateTime = myDate;
                                thisLoc.pLeftTime=thisLoc.pDateTime.format('h:mm a');
                                thisLoc.pRightTime=thisLoc.pDateTime.format('h:mm a');
                                thisLoc.gMapsLink= '<a href="#" onclick="javascript:window.open(\'http://maps.google.com/?q='+thisLoc.pLatitude +','+thisLoc.pLongitude+'\')">'+thisLoc.pLatitude+','+thisLoc.pLongitude+'</a>';
                                thisLoc.sMapLinkText='\'http://maps.google.com/?q='+thisLoc.platitude +','+thisLoc.plongitude+'\'';
                                thisLoc.formattedDate = thisLoc.pDateTime.format();
                                thisLoc.key = thisLoc.comcastDate;
                                locationHistoryList.add(thisLoc);
                            }
                            
                            if (!locationHistoryList.isEmpty()){
                                latestLoc = locationHistoryList[0];
                                locationStatusMessage = Label.Daily_Location + ' ' + repUser.name + ' ' + Label.On + ' ' + utilObj.Date_Field__c.format();
                                bMapValid = true;
                            }else{
                                apexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO, Label.No_Location_History + ' ' + repUser.name + ' ' + Label.On + ' '+ utilObj.Date_Field__c.format()));
                                bMapValid = false;
                            }
                        }
                    }
                }
                if (bMapValid || selectedMapType == '3'){
                    processMapCalcs();
                }
            }
        }
        return null;
    }

    /**
    * @Description: This method processes the data as per the view selected by Team on UI.
    * @Author: Amitkumar Bangad, Accenture
    * @Date: 23-May-2013 
    * @Param: None
    * @Return: void.
    */
    public pageReference processTeamView(){
        locationStatusMessage='';
        Set<Id> locationHistorySet=new Set<Id>();
        if (selectedMapType == '0'){
            apexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, LAbel.No_View_Selected));
        } else{
            if (selectedTeam != 'NONE'){
                
                
                if (selectedMapType == '1'){
                    bproxExc = false;
                    Map<Id, User> teamsUsers=new Map<Id, User>([Select Id, Name From User Where ManagerId=:selectedTeam AND IsActive=true]);
                    Integer locCount=[Select COUNT() from Location__c 
                                           where OwnerId IN (Select Id From User Where ManagerId=:selectedTeam And IsActive=true) 
                                           AND createdDate >= : System.Now().addMinutes(-120)];
                    if(locCount!=0){                     
                    for(Location__c loc : [Select Id, CreatedDate, OwnerId, Name, Geocode_TimeStamp__c, Timestamp__c, Latitude__c, Longitude__c  from Location__c 
                                           where OwnerId IN (Select Id From User Where ManagerId=:selectedTeam And IsActive=true) 
                                           AND createdDate >= :  System.Now().addMinutes(-120)
                                           ORDER BY Geocode_TimeStamp__c DESC]){
                        if(!locationHistorySet.contains(loc.OwnerId)){
                        DateTime recentLoc;
                        cLocation thisLoc = new cLocation();
                        thisLoc.platitude = String.Valueof(loc.Latitude__c);
                        thisLoc.plongitude = String.Valueof(loc.Longitude__c);
                        thisLoc.comcastDate = string.valueof(loc.CreatedDate);
                        thisloc.rUser = teamsUsers.get(loc.OwnerId);                                        
                        bMapValid = true;
                        String[] dateParts = loc.Geocode_TimeStamp__c.split('-',0);
                        String[] timeParts = dateParts[3].split(':',0);
                        //US1147215(System Engineering : SDM is not able to view the XSP location in MAP view)
                        //Added By :Tejaswini kasar
                        //Logic added to handle 12 hr as well as 24 hr format of Geocode_TimeStamp__c(Start)
                        String seconds = timeParts[2];
                        if(seconds.contains('PM')){
                            if( timeParts[0].contains('12')){
                                timeParts[0] = '12';
                                timeParts[2] = timeParts[2].substring(0,seconds.length()-3);
                            }else{
                                timeParts[0] = String.ValueOf(Integer.ValueOf(timeParts[0]) + 12);
                                timeParts[2] = timeParts[2].substring(0,seconds.length()-3);
                            }
                        }else if(seconds.contains('AM')){
                            if( timeParts[0].contains('12')){
                                timeParts[0] = '00';
                                timeParts[2] = timeParts[2].substring(0,seconds.length()-3);
                            }else{
                                timeParts[0] = String.ValueOf(Integer.ValueOf(timeParts[0]));
                                timeParts[2] = timeParts[2].substring(0,seconds.length()-3);
                            }
                        }
                        //End
                        Datetime myDate;
                        if(recentLoc == null){
                            myDate = datetime.newInstance(integer.valueof(dateParts[0]), integer.valueof(dateParts[1]),integer.valueof(dateParts[2]), integer.valueof(timeParts[0]), integer.valueof(timeParts[1]), integer.valueof(timeParts[2]));
                            recentLoc = myDate;                                                       
                        } else{
                            myDate = datetime.newInstance(integer.valueof(dateParts[0]), integer.valueof(dateParts[1]),integer.valueof(dateParts[2]), integer.valueof(timeParts[0]), integer.valueof(timeParts[1]), integer.valueof(timeParts[2]));
                            if(myDate > recentLoc){
                                recentLoc = myDate;
                            }
                        }
                        thisloc.pDateTime = myDate;
                        thisLoc.pLeftTime=thisLoc.pDateTime.format('h:mm a');
                        thisLoc.pRightTime=thisLoc.pDateTime.format('h:mm a');
                        thisLoc.gMapsLink= '<a href="#" onclick="javascript:window.open(\'http://maps.google.com/?q='+thisLoc.pLatitude +','+thisLoc.pLongitude+'\')">'+thisLoc.pLatitude+','+thisLoc.pLongitude+'</a>';
                        thisLoc.sMapLinkText='\'http://maps.google.com/?q='+thisLoc.platitude +','+thisLoc.plongitude+'\'';
                        thisLoc.formattedDate = thisLoc.pDateTime.format();
                        thisLoc.key=thisLoc.comcastDate;

                            locationHistoryList.add(thisLoc);
                        system.debug(recentLoc);
                        if(recentLoc != null){
                            locationStatusMessage += Label.Last_Location + ' ' + teamsUsers.get(loc.OwnerId).name + ' ' +Label.On + ' ' + recentLoc.format()+'<br/>';
                        }
                        else{
                            apexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO, Label.No_Location_History + ' ' + teamsUsers.get(loc.OwnerId).name));
                            bMapValid = false;
                        }
                        locationHistorySet.add(loc.OwnerId);
                    }
                        }
                    }else{
                            User teamSup=[Select Id, Name From User Where Id=:selectedTeam];
                            apexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO, Label.No_Location_History + ' ' + teamSup.Name+'\'s Team' ));
                            bMapValid = false; 
                    } 
            }
        }
                        if(!locationHistorySet.isEmpty()){
                            List<User> teamUsers=[Select Name From User WHERE ManagerId=:selectedTeam AND ID NOT IN:locationHistorySet];
                            for(User user:teamUsers){
                                apexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO, 'No location history available for  ' + user.name));
                            }
                        }
                        if (bMapValid || selectedMapType == '3'){
                    processMapCalcs();
                }
    }
            return null;
}

     /**
      * @Description: This method processes the data and prepares the parameters to be passed to Google Map Javascript.
      * @Author: Amitkumar Bangad, Accenture
      * @Date: 23-May-2013
      * @Param: None
      * @Return: void.
      */
     public void processMapCalcs() {
         if (selectedMapType != '4') {
             mapDataPointsStr = '';
             decimal lat;
             decimal longX;
             integer m = 1;
             if (!knockList.isEmpty()) {
                 for (Task k: knockList) {
                     bMapValid = true;
                     DailyDSRLogController.cLocation knockLoc = new DailyDSRLogController.cLocation(k);
                     DailyDSRLogController.cLocation acctLoc = new DailyDSRLogController.cLocation(addressMap.get(k.WhatId));
                     DailyDSRLogController.cKnockAddress knockAdd = new DailyDSRLogController.cKnockAddress(knockLoc,
                         acctLoc);
                     DailyDSRLogController.cTableView tab = new DailyDSRLogController.cTableView();
                     boolean isValid = true;
                     if (m == 1) {
                         cfirstDisposition = knockLoc;
                     }
                     clastDisposition = knockLoc;
                     if (gpsKnockMap.get(knockLoc.key) == null) {
                         gpsKnockMap.put(knockLoc.key, new List < DailyDSRLogController.cLocation > {
                             knockLoc
                         });
                     } else {
                         gpsKnockMap.get(knockLoc.key).add(knockLoc);
                     }
                     if (bproxExc) {
                         if (knockAdd.proxDiff < 1) {
                             isValid = false;
                         }
                     }
                     if(selectedMapType!='3'){
                         if (knockLoc.pLatitude == null || knockLoc.pLongitude == null || acctLoc.pLatitude == null || acctLoc.pLongitude == null) {
                             isValid = false;
                         }
                    }
                     if (isValid) {
                         mapDataPointsStr += 'k$' + knockLoc.pLatitude + '$' + knockLoc.pLongitude + '$' + knockLoc.name + '$' + knockLoc.sRecordId + '$' + knockLoc.sRecordText + '$' + knockLoc.sMapLinkText + '$' + knockLoc.pDateTime.format() + '$' + knockLoc.primaryColor + '$' + m + '@';
                         mapDataPointsStr += 'a$' + acctLoc.pLatitude + '$' + acctLoc.pLongitude + '$' + acctLoc.name + '$' + acctLoc.sRecordId + '$' + acctLoc.sRecordText + '$' + acctLoc.sMapLinkText + '$' + ' ' + '$' + acctLoc.primaryColor + '$' + m + '@';
                         tab.knockList.add(knockAdd);
                         tab.count = m;
                         tableData.add(tab);
                         m++;
                     }
                 }
             } else {
                 if (selectedMapType == '3') {
                     apexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO, Label.No_Disposition_History + ' ' + repUser.name + ' ' + Label.On + ' ' + utilObj.Date_Field__c.format()));
                 }
             }
             integer j = locationHistoryList.size();
             integer count = 1;
             system.debug(j);
             for (integer n = 0; n < j; n++) {
                 DailyDSRLogController.cLocation l = locationHistoryList[n];
                 lat = decimal.valueOf(l.pLatitude);
                 longX = decimal.valueOf(l.pLongitude);
                 if (n == locationHistoryList.size() - 1) {
                     clastDataPoint = l;
                 }
                 if (n == 0) {
                     tableData.clear();
                     cfirstDataPoint = l;
                 }
                 DailyDSRLogController.cTableView tab = new DailyDSRLogController.cTableView();
                 tab.knockList = new List < DailyDSRLogController.cKnockAddress > ();
                 boolean isValid = true;
                 if (gpsKnockMap.get(l.key) != null) {
                     for (DailyDSRLogController.cLocation knockLoc: gpsKnockMap.get(l.key)) {
                         DailyDSRLogController.cLocation addressLoc = new DailyDSRLogController.cLocation(addressMap.get(knockLoc.accountId));
                         DailyDSRLogController.cKnockAddress knockAdd = new DailyDSRLogController.cKnockAddress(knockLoc,
                             addressLoc);
                         if (bproxExc) {
                             if (knockAdd.proxDiff < 1) {
                                 isValid = false;
                             }
                         }
                         if (isValid) {
                             tab.knockList.add(new DailyDSRLogController.cKnockAddress(knockLoc, addressLoc));
                         }
                     }
                 } else if (bproxExc) {
                     isValid = false;
                 }
                 if (isValid) {
                     bMapValid = true;
                     tab.count = count;
                     tab.BreadCrumb = l;
                     tableData.add(tab);
                     count++;
                     mapDataPointsStr += 'l$' + lat + '$' + longX + '$' + l.rUser.Name + '$' + l.sRecordId + '$' + l.sRecordText + '$' + l.sMapLinkText + '$' + l.pDateTime.format() + '$' + l.primaryColor + '$' + count + '$' + l.pStreet + '@';
                 }
             }
         }
     }

     /**
      * @Description: Place holder method for Future Use
      * @Author: Amitkumar Bangad, Accenture
      * @Date: 23-May-2013
      * @Param: None
      * @Return: void.
      */
     public PageReference initMapLoad() {
         return null;
     }

     /**
      * @Description: This method clears all parameters on View Change
      * @Author: Amitkumar Bangad, Accenture
      * @Date: 23-May-2013
      * @Param: None
      * @Return: void.
      */
     public void clear() {
         bMapValid = true;
         addressMap.clear();
         tableData.clear();
         knockList.clear();
         locationHistoryList.clear();
         gpsKnockMap = new Map < String, List < cLocation > > ();
         cfirstDisposition = new cLocation();
         clastDisposition = new cLocation();
         clastDatapoint = new cLocation();
         cfirstDatapoint = new cLocation();
         knockAddressIds.clear();
         addressMap = new Map < Id, Customer_Address__c > ();
         tableData = new List < cTableView > ();
     }

     /**
      * @Description: This method validates the Onscreen data.
      * @Author: Amitkumar Bangad, Accenture
      * @Date: 23-May-2013
      * @Param: None
      * @Return: void.
      */
     public pageReference go() {
         clear();
         if ((selectedMapType == '3' || selectedMapType == '2') && utilObj.Date_Field__c == null) {
             apexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, Label.No_Date_Error));
             bMapValid = false;
             return null;
         }
         //Validate the data from VF page & call method to process data
         if ((selectedRep == null || selectedRep == 'NONE') && (selectedTeam == null || selectedTeam == 'NONE')) {
             apexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, Label.No_DSR_Error));
             bMapValid = false;
         } else if (selectedRep != 'NONE' && selectedRep != null) {
             repUser = [select defaultDivision, id, name from User where id = : selectedRep];
             if (bMapValid) {
                 //Knock and Address Info
                 if (selectedMapType == '3' || selectedMapType == '4') {
                     bMapValid = false;
                     if (utilObj.Date_Field__c != null) {
                         Datetime dt1 = Datetime.newInstance(utilObj.Date_Field__c, Time.newInstance(0, 0, 0, 0));
                         Datetime dt2 = Datetime.newInstance(utilObj.Date_Field__c, Time.newInstance(23, 59, 59, 0));
                         knockList = [Select Id, Subject, RecordTypeId, Disposition__c, Geocode_TimeStamp__c, Plan_Id__c, CreatedDate, Knocked_Date__c, WhatId, Disposition_Latitude__c, Disposition_Longitude__c from Task
                             where RecordTypeId = : RecTypeId
                             and createdById = : selectedRep
                             and Knocked_Date__c > : dt1
                             and Knocked_Date__c < : dt2 order by CreatedDate asc
                         ];
                         for (Task k: knockList) {
                             knockAddressIds.add(k.whatId);
                         }
                         for (Customer_Address__c addr: [Select Id, Name, Number_of_Knocks__c, Plan__c, Address__c, Address_2__c, Most_Recent_Disposition__c, Latitude__c, Longitude__c, Last_Knock_Date__c From Customer_Address__c where id in : knockAddressIds]) {
                             addressMap.put(addr.id, addr);
                         }
                         if (bMapValid) {
                             if (knockList.isEmpty()) {
                                 apexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO, Label.No_Disposition_History + ' ' + repUser.name + ' ' + Label.On + ' ' + utilObj.Date_Field__c.format()));
                             } else {
                                 if (selectedMapType == '3') {
                                     locationStatusMessage = Label.Address_Disposition_Location + ' ' + repUser.name + ' ' + Label.On + ' ' + utilObj.Date_Field__c.format();
                                 }
                             }
                         }
                     }
                 }
                 processRepView();
             }
         }
         else if(selectedTeam!= 'NONE' && selectedTeam != null){
            processTeamView();
         }
         return null;
     }

     /**
      * @Description: This method gets the list of Reps as per the Region selected on Screen.
      * @Author: Amitkumar Bangad, Accenture
      * @Date: 23-May-2013
      * @Param: None
      * @Return: void.
      */
     public void getReps() {
        system.debug(sRegion);
        if (sRegion == null){
            sRegion = [select Region__c from User where Id = : userinfo.getUserId()].Region__c;
        }
        repList.add(new SelectOption('NONE', ''));
        for (Division d: [select Name from Division where isActive = true]){
            if (d.Name==sRegion){
                selectedRegion = d.Name;
                break;
            }
        }
        for (User u: [select DefaultDivision, id, name from User where userRole.Name = : Label.DSR and isActive = true and Region__c = : selectedRegion order by Name asc]){
            repList.add(new SelectOption(u.id, u.name));
        } 
     }

     /**
      * @Description: This method gets the list of Teams as per the Region selected on Screen.
      * @Author: Erin McGee, Acumen Solutions
      * @Date: 06-Aug-2014
      * @Param: None
      * @Return: void.
      */
     public void getTeams() {
        User currentUser=[select Region__c, UserRole.Name from User where Id = : userinfo.getUserId()];
        if (sRegion == null){
            sRegion = currentUser.Region__c;
        }
        teamList.add(new SelectOption('NONE', ''));
        for (Division d: [select Name from Division where isActive = true]){
            String divId = d.Name;
            if (d.Name==sRegion){
                selectedRegion = d.Name;
                break;
            }
        }
            if(currentUser.UserRole.Name!=Label.SupervisorRoleName){
            for (User u: [select DefaultDivision, id, name from User where userRole.name = : Label.SupervisorRoleName and isActive = true and Region__c = : selectedRegion order by Name asc]) {
                teamList.add(new SelectOption(u.id, u.name + '\'s Team'));
            }
        }

            if (teamList.size()==1){
                teamList.add(new SelectOption(UserInfo.getUserId(), 'My Team'));
            }
     }

     /**
      * @Description: This method calculates distance between 2 points on Map.
      * @Author: Amitkumar Bangad, Accenture
      * @Date: 23-May-2013
      * @Param: None
      * @Return: void.
      */
     public static decimal getDistance(DailyDSRLogController.cKnockAddress knockAdd) {
         if (knockAdd.accountLoc.pLatitude != null && knockAdd.knockLoc.pLatitude != null && knockAdd.knockLoc.pLongitude != null && knockAdd.accountLoc.pLongitude != null) {
             decimal distance;
             //miles
             double r = 3963.1;
             double toRad = 57.29577951;
             double kLat = double.valueOf(knockAdd.knockLoc.pLatitude) / toRad;
             double kLon = double.valueOf(knockAdd.knockLoc.pLongitude) / toRad;
             double aLat = double.valueOf(knockAdd.accountLoc.pLatitude) / toRad;
             double aLon = double.valueOf(knockAdd.accountLoc.pLongitude) / toRad;
             decimal a = math.sin(kLat) * math.sin(aLat) + math.cos(kLat) * math.cos(aLat) * math.cos(kLon - aLon);
             if (a > 1) {
                 a = 1;
             }
             decimal c = math.acos(a);
             distance = (r * c).setScale(2);
             return distance;
         } else {
             return 0;
         }
     }

     /**
      * @Description: This is wrapper class for Location data .
      * @Author: Amitkumar Bangad, Accenture
      * @Date: 23-May-2013
      * @Param: None
      * @Return: void.
      */
     public class cLocation {
         public string pLeftTime {get; set;}
         public string comcastDate {get; set;}
         public string pRightTime {get; set;}
         public DateTime pDateTime {get; set;}
         public string pLatitude {get; set;}
         public string pLongitude {get; set;}
         public string pPhoneNum {get; set;}
         public string pStreet {get; set;}
         public string key {get; set;}
         public string AccountId {get; set;}
         public string gMapsLink {get; set;}
         public string sMapLinkText {get; set;}
         public string sRecordId {get; set;}
         public string sRecordText {get; set;}
         public string primaryColor {get; set;}
         public string name {get; set;}
         public string formattedDate {get; set;}
         public string sLabel {get; set;}
         public string sRecordName {get; set;}
         public User rUser {get; set;}
         public cLocation() {
             this.primaryColor = '#FF6666';
         }
         public cLocation(Customer_Address__c a) {
             this.platitude = string.valueOf(a.latitude__c);
             this.plongitude = string.valueOf(a.longitude__c);
             this.gMapsLink = '<a href="#" onclick="javascript:window.open(\'http://maps.google.com/?q=' + platitude + ',' + plongitude + '\')">' + platitude + ',' + plongitude + '</a>';
             this.sMapLinkText = '\'http://maps.google.com/?q=' + platitude + ',' + plongitude + '\'';
             this.primaryColor = '#000099';
             this.name = a.name;
             this.sRecordId = a.id;
             this.sRecordText = 'View Address';
             this.sRecordName = a.name;
         }
         public cLocation(Task k) {
             this.platitude = string.valueOf(k.disposition_latitude__c);
             this.plongitude = string.valueOf(k.disposition_longitude__c);
             this.gMapsLink = '<a href="#" onclick="javascript:window.open(\'http://maps.google.com/?q=' + platitude + ',' + plongitude + '\')">' + platitude + ',' + plongitude + '</a>';
             this.sMapLinkText = '\'http://maps.google.com/?q=' + platitude + ',' + plongitude + '\'';
             this.accountId = k.WhatId;
             this.pLeftTime = k.Knocked_Date__c.format('h:mm a');
             this.pRightTime = k.Knocked_Date__c.format('h:mm a');
             this.primaryColor = '#FF6666';
             this.name = k.disposition__c;
             this.sRecordName = k.Subject;
             this.srecordId = k.id;
             this.sRecordText = Label.View_Knock;
             this.pdateTime = k.Knocked_Date__c;
             this.formattedDate = k.Knocked_Date__c.format();
             this.key = this.comcastDate;
         }

     }

     /**
      * @Description: This is wrapper class for Knock & Address Mapping.
      * @Author: Amitkumar Bangad, Accenture
      * @Date: 23-May-2013
      * @Param: None
      * @Return: void.
      */
     public class cKnockAddress {
         public DailyDSRLogController.cLocation knockLoc {get; set;}
         public DailyDSRLogController.cLocation accountLoc {get; set;}
         public decimal proxDiff {get; set;}
         public string sProxDiff {get; set;}

         public cKnockAddress(cLocation k, cLocation a) {
             this.knockLoc = k;
             this.accountLoc = a;
             if (k.pLatitude == null) {
                 this.sProxDiff = '';
             } else if (k.pLatitude != 'N/A' && k.pLatitude != '0') {
                 this.proxDiff = DailyDSRLogController.getDistance(this);
                 this.sProxDiff = this.proxDiff + ' mi';
             } else {
                 this.proxDiff = 5;
                 this.sProxDiff = '';
             }
         }
     }
     /**
      * @Description: This is wrapper class for data table.
      * @Author: Amitkumar Bangad, Accenture
      * @Date: 23-May-2013
      * @Param: None
      * @Return: void.
      */
     public class cTableView {
         public DailyDSRLogController.cLocation BreadCrumb {get; set;}
         public List < DailyDSRLogController.cKnockAddress > knockList {get; set;}
         public integer count {get; set;}
         public cTableView() {
             this.breadCrumb = new DailyDSRLogController.cLocation();
             knockList = new List < DailyDSRLogController.cKnockAddress > ();
         }
     }

 }