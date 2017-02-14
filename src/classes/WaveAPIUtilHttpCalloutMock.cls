@isTest
global class WaveAPIUtilHttpCalloutMock implements HttpCalloutMock {
  global HttpResponse respond(HTTPRequest req) {
    HttpResponse res = new HttpResponse();
    String currentEndpoint = req.getEndpoint();

    if (currentEndpoint.contains('wave/dashboards/')) {
      res.setBody(getDashboard());
      res.setStatusCode(200);
    } else if (currentEndpoint.contains('wave/dashboards')) {
      res.setBody(getDashboardList());
      res.setStatusCode(200);
    } else if (currentEndpoint.contains('wave/datasets/')) {
      res.setBody(getDataset());
      res.setStatusCode(200);
    } else if (currentEndpoint.contains('wave/datasets')) {
      res.setBody(getDatasetList());
      res.setStatusCode(200);
    } else if (currentEndpoint.contains('wave/folders/')) {
      res.setBody(getFolder());
      res.setStatusCode(200);
    } else if (currentEndpoint.contains('wave/folders')) {
      res.setBody(getFolderList());
      res.setStatusCode(200);
    } else if (currentEndpoint.contains('wave/lenses/')) {
      res.setBody(getLens());
      res.setStatusCode(200);
    } else if (currentEndpoint.contains('wave/lenses')) {
      res.setBody(getLensList());
      res.setStatusCode(200);
    } else if (currentEndpoint.contains('wave/query')) {
      res.setBody(postQuery());
      res.setStatusCode(200);
    } else if (currentEndpoint.contains('wave')) {
      res.setBody(getWave());
      res.setStatusCode(200);
    } else {
      res.setStatusCode(404);
    }

    return res;
  }

  //////////
  // HELPER METHODS
  //////////

  // JSON returned from getDashboard
  private String getDashboard() {
    return '{' +
      '\"allowPreview\": true,' +
      '\"assetSharingUrl\": \"https://onecomcast--wavedev.cs4.my.salesforce.com/analytics/wave/dashboard?assetId=0FK16000000TNLAGA4&orgId=00DP0000000DZAp&loginHost=cs4.salesforce.com&urlType=sharing\",' +
      '\"createdBy\": {' +
        '\"id\": \"00516000006iwFlAAI\",' +
        '\"name\": \"Bobby Kiely\",' +
        '\"profilePhotoUrl\": \"https://onecomcast--wavedev--c.cs4.content.force.com/profilephoto/005/T\"' +
      '},' +
      '\"createdDate\": \"2016-07-20T16:45:55.000Z\",' +
      '\"datasets\": [' +
        '{' +
          '\"id\": \"0Fb16000000PB8QCAW\",' +
          '\"label\": \"Prop_Oppty\",' +
          '\"name\": \"Property_with_Oppty\",' +
          '\"url\": \"/services/data/v36.0/wave/datasets/0Fb16000000PB8QCAW\"' +
        '}' +
      '],' +
      '\"files\": [' +
        '{' +
          '\"contentType\": \"image/png\",' +
          '\"fileLength\": 8307,' +
          '\"fileName\": \"assetPreviewThumb\",' +
          '\"id\": \"0FJ16000000TNL0GAO\",' +
          '\"lastModifiedDate\": \"2016-08-16T14:34:46.000Z\",' +
          '\"url\": \"/services/data/v36.0/wave/lenses/0FK16000000TNLAGA4/files/0FJ16000000TNL0GAO\"' +
        '}' +
      '],' +
      '\"folder\": {' +
        '\"id\": \"00l160000029wb4AAA\",' +
        '\"label\": \"XFINITY Communities Shared App\",' +
        '\"name\": \"XFINITY_Communities_Shared_App\",' +
        '\"url\": \"/services/data/v36.0/wave/folders/00l160000029wb4AAA\"' +
      '},' +
      '\"id\": \"0FK16000000TNLAGA4\",' +
      '\"label\": \"Heartland Forecast Dashboard\",' +
      '\"lastAccessedDate\": \"2016-08-24T16:26:37.000Z\",' +
      '\"lastModifiedBy\": {' +
        '\"id\": \"00516000006iwFlAAI\",' +
        '\"name\": \"Bobby Kiely\",' +
        '\"profilePhotoUrl\": \"https://onecomcast--wavedev--c.cs4.content.force.com/profilephoto/005/T\"' +
      '},' +
      '\"lastModifiedDate\": \"2016-07-27T19:42:55.000Z\",' +
      '\"name\": \"Heartland_Forecast_Dashboard\",' +
      '\"permissions\": {' +
        '\"manage\": true,' +
        '\"modify\": true,' +
        '\"view\": true' +
      '},' +
      '\"state\": {' +
        '\"gridLayouts\": [],' +
        '\"layouts\": [],' +
        '\"steps\": {' +
          '\"Oppty_Type_19\": {' +
            '\"datasets\": [' +
              '{' +
                '\"id\": \"0Fb16000000PB8QCAW\",' +
                '\"label\": \"Prop_Oppty\",' +
                '\"name\": \"Property_with_Oppty\",' +
                '\"url\": \"/services/data/v36.0/wave/datasets/0Fb16000000PB8QCAW\"' +
              '}' +
            '],' +
            '\"isFacet\": true,' +
            '\"isGlobal\": false,' +
            '\"query\": {' +
              '\"query\": \"{&quot;measures&quot;:[[&quot;count&quot;,&quot;*&quot;,null,{&quot;display&quot;:&quot;# of Properties&quot;}]],&quot;groups&quot;:[&quot;Oppty_Type&quot;],&quot;filters&quot;:[[&quot;Oppty_CloseDate&quot;,[[1466553600000,1482278400000]],&quot;&gt;=&lt;=&quot;],[&quot;Prop1_Property_Division__c&quot;,[&quot;Central&quot;],&quot;in&quot;],[&quot;Oppty_CloseDate&quot;,[[1466553600000,1482278400000]],&quot;&gt;=&lt;=&quot;],[&quot;Oppty_StageName&quot;,[&quot;Closed Lost&quot;,&quot;Closed Won&quot;],&quot;not in&quot;],[&quot;Prop1_Property_Region__c&quot;,[&quot;Heartland Region&quot;],&quot;in&quot;],[&quot;Oppty_Name3&quot;,[&quot;John Cosenza&quot;,&quot;John Pluskota&quot;,&quot;Meghan Martin Kern&quot;],&quot;in&quot;],[&quot;Oppty_Type&quot;,[&quot;Addendum&quot;],&quot;not in&quot;]]}\",' +
              '\"version\": -1' +
            '},' +
            '\"selectMode\": \"single\",' +
            '\"type\": \"aggregate\",' +
            '\"useGlobal\": true,' +
            '\"visualizationParameters\": {' +
              '\"visualizationType\": \"pie\"' +
            '}' +
          '},' +
          '\"Prop1_Development__c_23\": {' +
            '\"datasets\": [' +
              '{' +
                '\"id\": \"0Fb16000000PB8QCAW\",' +
                '\"label\": \"Prop_Oppty\",' +
                '\"name\": \"Property_with_Oppty\",' +
                '\"url\": \"/services/data/v36.0/wave/datasets/0Fb16000000PB8QCAW\"' +
              '}' +
            '],' +
            '\"isFacet\": true,' +
            '\"isGlobal\": false,' +
            '\"query\": {' +
              '\"query\":' + '\"{&quot;measures&quot;:[[&quot;sum&quot;,&quot;Prop1_Number_of_Units__c&quot;]],&quot;groups&quot;:[&quot;Prop1_Development__c&quot;],&quot;filters&quot;:[[&quot;Prop1_Property_Region__c&quot;,[&quot;Heartland Region&quot;],&quot;in&quot;],[&quot;Oppty_Name3&quot;,[&quot;John Cosenza&quot;,&quot;John Pluskota&quot;,&quot;Meghan Martin Kern&quot;,&quot;Sandra Houser&quot;],&quot;in&quot;],[&quot;Oppty_National_Deal__c&quot;,[[0]],&quot;==&quot;],[&quot;Oppty_Type&quot;,[&quot;Addendum&quot;],&quot;not in&quot;]]}\",' +
              '\"version\": -1' +
            '},' +
            '\"selectMode\": \"multi\",' +
            '\"start\": \"[]\",' +
            '\"type\": \"aggregate\",' +
            '\"useGlobal\": true,' +
            '\"visualizationParameters\": {' +
              '\"visualizationType\": \"hbar\"' +
            '}' +
          '}' +
        '},' +
        '\"widgets\": {' +
          '\"dimfilter_9\": {' +
            '\"parameters\": {' +
              '\"expanded\": false,' +
              '\"measureField\": \"sum_Prop1_Number_of_Units__c\",' +
              '\"selectModeOverride\": \"multi\",' +
              '\"step\": \"Prop1_Development__c_23\",' +
              '\"title\": \"Property Development Name\"' +
            '},' +
            '\"position\": {' +
              '\"h\": \"50\",' +
              '\"w\": \"160\",' +
              '\"x\": 1020,' +
              '\"y\": 70,' +
              '\"zIndex\": 100006' +
            '},' +
            '\"type\": \"listselector\"' +
          '},' +
          '\"chart_4\": {' +
            '\"parameters\": {' +
              '\"sqrt\": true,' +
              '\"visualizationType\": \"hbar\",' +
              '\"step\": \"Oppty_Name3_Oppty_Name1_Oppty_Type_Oppty_StageName_17\"' +
            '},' +
            '\"position\": {' +
              '\"h\": \"590\",' +
              '\"w\": \"920\",' +
              '\"x\": 10,' +
              '\"y\": 150,' +
              '\"zIndex\": 6' +
            '},' +
            '\"type\": \"chart\"' +
          '}' +
        '}' +
      '},' +
      '\"type\": \"dashboard\",' +
      '\"url\": \"/services/data/v36.0/wave/dashboards/0FK16000000TNLAGA4\"' +
    '}';
  }

  // JSON returned from getDashboardList
  private String getDashboardList() {
    return '{' +
      '\"dashboards\": [' +
        '{' +
          '\"allowPreview\": true,' +
          '\"assetSharingUrl\": \"https://onecomcast--wavedev.cs4.my.salesforce.com/analytics/wave/dashboard?assetId=0FK16000000TNLAGA4&orgId=00DP0000000DZAp&loginHost=cs4.salesforce.com&urlType=sharing\",' +
          '\"createdBy\": {' +
            '\"id\": \"00516000006iwFlAAI\",' +
            '\"name\": \"Bobby Kiely\",' +
            '\"profilePhotoUrl\": \"https://onecomcast--wavedev--c.cs4.content.force.com/profilephoto/005/T\"' +
          '},' +
          '\"createdDate\": \"2016-07-20T16:45:55.000Z\",' +
          '\"datasets\": [' +
            '{' +
              '\"id\": \"0Fb16000000PB8QCAW\",' +
              '\"label\": \"Prop_Oppty\",' +
              '\"name\": \"Property_with_Oppty\",' +
              '\"url\": \"/services/data/v36.0/wave/datasets/0Fb16000000PB8QCAW\"' +
            '}' +
          '],' +
          '\"files\": [' +
            '{' +
              '\"contentType\": \"image/png\",' +
              '\"fileLength\": 8307,' +
              '\"fileName\": \"assetPreviewThumb\",' +
              '\"id\": \"0FJ16000000TNL0GAO\",' +
              '\"lastModifiedDate\": \"2016-08-16T14:34:46.000Z\",' +
              '\"url\": \"/services/data/v36.0/wave/lenses/0FK16000000TNLAGA4/files/0FJ16000000TNL0GAO\"' +
            '}' +
          '],' +
          '\"folder\": {' +
            '\"id\": \"00l160000029wb4AAA\",' +
            '\"label\": \"XFINITY Communities Shared App\",' +
            '\"name\": \"XFINITY_Communities_Shared_App\",' +
            '\"url\": \"/services/data/v36.0/wave/folders/00l160000029wb4AAA\"' +
          '},' +
          '\"id\": \"0FK16000000TNLAGA4\",' +
          '\"label\": \"Heartland Forecast Dashboard\",' +
          '\"lastAccessedDate\": \"2016-08-19T19:29:46.000Z\",' +
          '\"lastModifiedBy\": {' +
            '\"id\": \"00516000006iwFlAAI\",' +
            '\"name\": \"Bobby Kiely\",' +
            '\"profilePhotoUrl\": \"https://onecomcast--wavedev--c.cs4.content.force.com/profilephoto/005/T\"' +
          '},' +
          '\"lastModifiedDate\": \"2016-07-27T19:42:55.000Z\",' +
          '\"name\": \"Heartland_Forecast_Dashboard\",' +
          '\"permissions\": {' +
            '\"manage\": true,' +
            '\"modify\": true,' +
            '\"view\": true' +
          '},' +
          '\"type\": \"dashboard\",' +
          '\"url\": \"/services/data/v36.0/wave/dashboards/0FK16000000TNLAGA4\"' +
        '},' +
        '{' +
          '\"allowPreview\": true,' +
          '\"assetSharingUrl\": \"https://onecomcast--wavedev.cs4.my.salesforce.com/analytics/wave/dashboard?assetId=0FK16000000TNZRGA4&orgId=00DP0000000DZAp&loginHost=cs4.salesforce.com&urlType=sharing\",' +
          '\"createdBy\": {' +
            '\"id\": \"00516000006iwPoAAI\",' +
            '\"name\": \"Josium Lopez\",' +
            '\"profilePhotoUrl\": \"https://onecomcast--wavedev--c.cs4.content.force.com/profilephoto/005/T\"' +
          '},' +
          '\"createdDate\": \"2016-07-29T14:06:38.000Z\",' +
          '\"datasets\": [' +
            '{' +
              '\"id\": \"0Fb16000000PB8QCAW\",' +
              '\"label\": \"Prop_Oppty\",' +
              '\"name\": \"Property_with_Oppty\",' +
              '\"url\": \"/services/data/v36.0/wave/datasets/0Fb16000000PB8QCAW\"' +
            '}' +
          '],' +
          '\"description\": \"Updated w/o contract info\",' +
          '\"files\": [' +
            '{' +
              '\"contentType\": \"image/png\",' +
              '\"fileLength\": 11762,' +
              '\"fileName\": \"assetPreviewThumb\",' +
              '\"id\": \"0FJ16000000TNZCGA4\",' +
              '\"lastModifiedDate\": \"2016-08-12T13:24:32.000Z\",' +
              '\"url\": \"/services/data/v36.0/wave/lenses/0FK16000000TNZRGA4/files/0FJ16000000TNZCGA4\"' +
            '}' +
          '],' +
          '\"folder\": {' +
            '\"id\": \"00l160000029wb4AAA\",' +
            '\"label\": \"XFINITY Communities Shared App\",' +
            '\"name\": \"XFINITY_Communities_Shared_App\",' +
            '\"url\": \"/services/data/v36.0/wave/folders/00l160000029wb4AAA\"' +
          '},' +
          '\"id\": \"0FK16000000TNZRGA4\",' +
          '\"label\": \"GCR Forecast Dashboard - Shared App\",' +
          '\"lastAccessedDate\": \"2016-08-17T17:22:50.000Z\",' +
          '\"lastModifiedBy\": {' +
            '\"id\": \"00516000006iwPoAAI\",' +
            '\"name\": \"Josium Lopez\",' +
            '\"profilePhotoUrl\": \"https://onecomcast--wavedev--c.cs4.content.force.com/profilephoto/005/T\"' +
          '},' +
          '\"lastModifiedDate\": \"2016-08-05T17:41:55.000Z\",' +
          '\"name\": \"GCR_Forecast_Dashboard_Shared_App\",' +
          '\"permissions\": {' +
            '\"manage\": true,' +
            '\"modify\": true,' +
            '\"view\": true' +
          '},' +
          '\"type\": \"dashboard\",' +
          '\"url\": \"/services/data/v36.0/wave/dashboards/0FK16000000TNZRGA4\"' +
        '}' +
      '],' +
      '\"nextPageUrl\": null,' +
      '\"totalSize\": 2,' +
      '\"url\": \"/services/data/v36.0/wave/dashboards\"' +
    '}';
  }

  // JSON returned from getDataset
  private String getDataset() {
    return '{' +
      '\"createdBy\": {' +
        '\"id\": \"0051600000752yMAAQ\",' +
        '\"name\": \"Scott McCambridge\",' +
        '\"profilePhotoUrl\": \"https://onecomcast--wavedev--c.cs4.content.force.com/profilephoto/005/T\"' +
      '},' +
      '\"createdDate\": \"2016-08-17T11:38:56.000Z\",' +
      '\"currentVersionId\": \"0FcP00000006geyKAA\",' +
      '\"currentVersionUrl\": \"/services/data/v36.0/wave/datasets/0FbP00000006hQiKAI/versions/0FcP00000006geyKAA\",' +
      '\"folder\": {' +
        '\"id\": \"00lP0000000rbbzIAA\",' +
        '\"label\": \"Turf Planning\",' +
        '\"name\": \"Turf_Planning\",' +
        '\"url\": \"/services/data/v36.0/wave/folders/00lP0000000rbbzIAA\"' +
      '},' +
      '\"id\": \"0FbP00000006hQiKAI\",' +
      '\"label\": \"Customer Address\",' +
      '\"lastAccessedDate\": \"2016-08-24T16:26:54.000Z\",' +
      '\"lastModifiedBy\": {' +
        '\"id\": \"00516000006wLW4AAM\",' +
        '\"name\": \"Integration User\",' +
        '\"profilePhotoUrl\": \"https://onecomcast--wavedev--c.cs4.content.force.com/profilephoto/005/T\"' +
      '},' +
      '\"lastModifiedDate\": \"2016-08-17T11:39:25.000Z\",' +
      '\"name\": \"Customer_Address\",' +
      '\"permissions\": {' +
        '\"manage\": true,' +
        '\"modify\": true,' +
        '\"view\": true' +
      '},' +
      '\"type\": \"dataset\",' +
      '\"url\": \"/services/data/v36.0/wave/datasets/0FbP00000006hQiKAI\",' +
      '\"versionsUrl\": \"/services/data/v36.0/wave/datasets/0FbP00000006hQiKAI/versions\"' +
    '}';
  }

  // JSON returned from getDatasetList
  private String getDatasetList() {
    return '{' +
      '\"datasets\": [' +
        '{' +
          '\"createdBy\": {' +
            '\"id\": \"0051600000752yMAAQ\",' +
            '\"name\": \"Scott McCambridge\",' +
            '\"profilePhotoUrl\": \"https://onecomcast--wavedev--c.cs4.content.force.com/profilephoto/005/T\"' +
          '},' +
          '\"createdDate\": \"2016-08-17T11:38:56.000Z\",' +
          '\"currentVersionId\": \"0FcP00000006geyKAA\",' +
          '\"currentVersionUrl\": \"/services/data/v36.0/wave/datasets/0FbP00000006hQiKAI/versions/0FcP00000006geyKAA\",' +
          '\"folder\": {' +
            '\"id\": \"00lP0000000rbbzIAA\",' +
            '\"label\": \"Turf Planning\",' +
            '\"name\": \"Turf_Planning\",' +
            '\"url\": \"/services/data/v36.0/wave/folders/00lP0000000rbbzIAA\"' +
          '},' +
          '\"id\": \"0FbP00000006hQiKAI\",' +
          '\"label\": \"Customer Address\",' +
          '\"lastAccessedDate\": \"2016-08-23T21:02:06.000Z\",' +
          '\"lastModifiedBy\": {' +
            '\"id\": \"00516000006wLW4AAM\",' +
            '\"name\": \"Integration User\",' +
            '\"profilePhotoUrl\": \"https://onecomcast--wavedev--c.cs4.content.force.com/profilephoto/005/T\"' +
          '},' +
          '\"lastModifiedDate\": \"2016-08-17T11:39:25.000Z\",' +
          '\"name\": \"Customer_Address\",' +
          '\"permissions\": {' +
            '\"manage\": true,' +
            '\"modify\": true,' +
            '\"view\": true' +
          '},' +
          '\"type\": \"dataset\",' +
          '\"url\": \"/services/data/v36.0/wave/datasets/0FbP00000006hQiKAI\",' +
          '\"versionsUrl\": \"/services/data/v36.0/wave/datasets/0FbP00000006hQiKAI/versions\"' +
        '},' +
        '{' +
          '\"createdBy\": {' +
            '\"id\": \"00516000005coewAAA\",' +
            '\"name\": \"Deepraj Bhushan\",' +
            '\"profilePhotoUrl\": \"https://onecomcast--wavedev--c.cs4.content.force.com/profilephoto/005/T\"' +
          '},' +
          '\"createdDate\": \"2016-06-14T12:06:49.000Z\",' +
          '\"folder\": {' +
            '\"id\": \"00l160000029wTjAAI\",' +
            '\"label\": \"Shared App\",' +
            '\"name\": \"SharedApp\",' +
            '\"url\": \"/services/data/v36.0/wave/folders/00l160000029wTjAAI\"' +
          '},' +
          '\"id\": \"0Fb16000000PB7SCAW\",' +
          '\"label\": \"Prop_Oppty_Contract\",' +
          '\"lastAccessedDate\": \"2016-08-23T21:02:01.000Z\",' +
          '\"lastModifiedBy\": {' +
            '\"id\": \"00516000006wLW4AAM\",' +
            '\"name\": \"Integration User\",' +
            '\"profilePhotoUrl\": \"https://onecomcast--wavedev--c.cs4.content.force.com/profilephoto/005/T\"' +
          '},' +
          '\"lastModifiedDate\": \"2016-08-16T11:53:58.000Z\",' +
          '\"name\": \"Property_with_Oppty_and_Contract\",' +
          '\"permissions\": {' +
            '\"manage\": true,' +
            '\"modify\": true,' +
            '\"view\": true' +
          '},' +
          '\"type\": \"dataset\",' +
          '\"url\": \"/services/data/v36.0/wave/datasets/0Fb16000000PB7SCAW\",' +
          '\"versionsUrl\": \"/services/data/v36.0/wave/datasets/0Fb16000000PB7SCAW/versions\"' +
        '}' +
      '],' +
      '\"nextPageUrl\": null,' +
      '\"totalSize\": 2,' +
      '\"url\": \"/services/data/v36.0/wave/datasets\"' +
    '}';
  }

  // JSON returned from getFolder
  private String getFolder() {
    return '{' +
      '\"applicationStatus\": \"newstatus\",' +
      '\"assetSharingUrl\": \"https://onecomcast--wavedev.cs4.my.salesforce.com/analytics/wave/application?assetId=00lP0000000rbbzIAA&orgId=00DP0000000DZAp&loginHost=cs4.salesforce.com&urlType=sharing\",' +
      '\"createdBy\": {' +
        '\"id\": \"0051600000752yMAAQ\",' +
        '\"name\": \"Scott McCambridge\",' +
        '\"profilePhotoUrl\": \"https://onecomcast--wavedev--c.cs4.content.force.com/profilephoto/005/T\"' +
      '},' +
      '\"createdDate\": \"2016-08-17T11:35:38.000Z\",' +
      '\"icon\": {' +
        '\"id\": \"00lP0000000rbbzIAA\",' +
        '\"name\": \"16.png\",' +
        '\"url\": \"/analytics/wave/web/proto/images/app/icons/16.png\"' +
      '},' +
      '\"id\": \"00lP0000000rbbzIAA\",' +
      '\"label\": \"Turf Planning\",' +
      '\"lastModifiedBy\": {' +
        '\"id\": \"0051600000752yMAAQ\",' +
        '\"name\": \"Scott McCambridge\",' +
        '\"profilePhotoUrl\": \"https://onecomcast--wavedev--c.cs4.content.force.com/profilephoto/005/T\"' +
      '},' +
      '\"lastModifiedDate\": \"2016-08-17T11:42:40.000Z\",' +
      '\"name\": \"Turf_Planning\",' +
      '\"permissions\": {' +
        '\"manage\": true,' +
        '\"modify\": true,' +
        '\"view\": true' +
      '},' +
      '\"shares\": [' +
        '{' +
          '\"accessType\": \"edit\",' +
          '\"imageUrl\": \"https://onecomcast--wavedev--c.cs4.content.force.com/profilephoto/005/T\",' +
          '\"shareType\": \"user\",' +
          '\"sharedWithId\": \"005G0000004KRG3IAO\",' +
          '\"sharedWithLabel\": \"Anand B Narasimhan\"' +
        '},' +
        '{' +
          '\"accessType\": \"manage\",' +
          '\"imageUrl\": \"https://onecomcast--wavedev--c.cs4.content.force.com/profilephoto/005/T\",' +
          '\"shareType\": \"user\",' +
          '\"sharedWithId\": \"0051600000752yMAAQ\",' +
          '\"sharedWithLabel\": \"Scott McCambridge\"' +
        '},' +
        '{' +
          '\"accessType\": \"manage\",' +
          '\"imageUrl\": \"https://onecomcast--wavedev--c.cs4.content.force.com/profilephoto/005/T\",' +
          '\"shareType\": \"user\",' +
          '\"sharedWithId\": \"005P0000001F9dRIAS\",' +
          '\"sharedWithLabel\": \"Shawn Franklin\"' +
        '}' +
      '],' +
      '\"type\": \"folder\",' +
      '\"url\": \"/services/data/v36.0/wave/folders/00lP0000000rbbzIAA\"' +
    '}';
  }

  // JSON returned from  getFolderList
  private String getFolderList() {
    return '{' +
      '\"folders\": [' +
        '{' +
          '\"applicationStatus\": \"newstatus\",' +
          '\"assetSharingUrl\": \"https://onecomcast--wavedev.cs4.my.salesforce.com/analytics/wave/application?assetId=00lP0000000rbbzIAA&orgId=00DP0000000DZAp&loginHost=cs4.salesforce.com&urlType=sharing\",' +
          '\"createdBy\": {' +
            '\"id\": \"0051600000752yMAAQ\",' +
            '\"name\": \"Scott McCambridge\",' +
            '\"profilePhotoUrl\": \"https://onecomcast--wavedev--c.cs4.content.force.com/profilephoto/005/T\"' +
          '},' +
          '\"createdDate\": \"2016-08-17T11:35:38.000Z\",' +
          '\"icon\": {' +
            '\"id\": \"00lP0000000rbbzIAA\",' +
            '\"name\": \"16.png\",' +
            '\"url\": \"/analytics/wave/web/proto/images/app/icons/16.png\"' +
          '},' +
          '\"id\": \"00lP0000000rbbzIAA\",' +
          '\"label\": \"Turf Planning\",' +
          '\"lastAccessedDate\": \"2016-08-17T16:57:51.000Z\",' +
          '\"lastModifiedBy\": {' +
            '\"id\": \"0051600000752yMAAQ\",' +
            '\"name\": \"Scott McCambridge\",' +
            '\"profilePhotoUrl\": \"https://onecomcast--wavedev--c.cs4.content.force.com/profilephoto/005/T\"' +
          '},' +
          '\"lastModifiedDate\": \"2016-08-17T11:42:40.000Z\",' +
          '\"name\": \"Turf_Planning\",' +
          '\"permissions\": {' +
            '\"manage\": true,' +
            '\"modify\": true,' +
            '\"view\": true' +
          '},' +
          '\"shares\": [],' +
          '\"type\": \"folder\",' +
          '\"url\": \"/services/data/v36.0/wave/folders/00lP0000000rbbzIAA\"' +
        '},' +
        '{' +
          '\"applicationStatus\": \"newstatus\",' +
          '\"assetSharingUrl\": \"https://onecomcast--wavedev.cs4.my.salesforce.com/analytics/wave/application?assetId=00l160000029wX7AAI&orgId=00DP0000000DZAp&loginHost=cs4.salesforce.com&urlType=sharing\",' +
          '\"createdBy\": {' +
            '\"id\": \"00516000006ITm5AAG\",' +
            '\"name\": \"Michael Angelo\",' +
            '\"profilePhotoUrl\": \"https://onecomcast--wavedev--c.cs4.content.force.com/profilephoto/005/T\"' +
          '},' +
          '\"createdDate\": \"2016-06-20T14:00:34.000Z\",' +
          '\"description\": \"DIRECT-based reports that could be recreated in Salesforce Wave Analytics (templates are as closely mirrored as possible)\",' +
          '\"icon\": {' +
            '\"id\": \"00l160000029wX7AAI\",' +
            '\"name\": \"18.png\",' +
            '\"url\": \"/analytics/wave/web/proto/images/app/icons/18.png\"' +
          '},' +
          '\"id\": \"00l160000029wX7AAI\",' +
          '\"label\": \"Business Critical Reports for Launch\",' +
          '\"lastModifiedBy\": {' +
            '\"id\": \"00516000006ITm5AAG\",' +
            '\"name\": \"Michael Angelo\",' +
            '\"profilePhotoUrl\": \"https://onecomcast--wavedev--c.cs4.content.force.com/profilephoto/005/T\"' +
          '},' +
          '\"lastModifiedDate\": \"2016-06-28T15:03:27.000Z\",' +
          '\"name\": \"Business_Critical_Launch\",' +
          '\"permissions\": {' +
            '\"manage\": true,' +
            '\"modify\": true,' +
            '\"view\": true' +
          '},' +
          '\"shares\": [],' +
          '\"type\": \"folder\",' +
          '\"url\": \"/services/data/v36.0/wave/folders/00l160000029wX7AAI\"' +
        '}' +
      '],' +
      '\"totalSize\": 2,' +
      '\"url\": \"/services/data/v36.0/wave/folders\"' +
    '}';
  }

  // JSON returned from getLens
  private String getLens() {
    return '{' +
      '\"allowPreview\": true,' +
      '\"assetSharingUrl\": \"https://onecomcast--wavedev.cs4.my.salesforce.com/analytics/wave/lens?assetId=0FKP00000004CdhOAE&orgId=00DP0000000DZAp&loginHost=cs4.salesforce.com&urlType=sharing\",' +
      '\"createdBy\": {' +
        '\"id\": \"0051600000752yMAAQ\",' +
        '\"name\": \"Scott McCambridge\",' +
        '\"profilePhotoUrl\": \"https://onecomcast--wavedev--c.cs4.content.force.com/profilephoto/005/T\"' +
      '},' +
      '\"createdDate\": \"2016-08-17T11:55:53.000Z\",' +
      '\"dataset\": {' +
        '\"id\": \"0FbP00000006hQiKAI\",' +
        '\"name\": \"Customer_Address\",' +
        '\"url\": \"/services/data/v36.0/wave/datasets/0FbP00000006hQiKAI\"' +
      '},' +
      '\"files\": [' +
        '{' +
          '\"contentType\": \"image/png\",' +
          '\"fileLength\": 16444,' +
          '\"fileName\": \"assetPreviewThumb\",' +
          '\"id\": \"0FJP00000008OhPOAU\",' +
          '\"lastModifiedDate\": \"2016-08-17T16:57:54.000Z\",' +
          '\"url\": \"/services/data/v36.0/wave/lenses/0FKP00000004CdhOAE/files/0FJP00000008OhPOAU\"' +
        '}' +
      '],' +
      '\"filesUrl\": \"/services/data/v36.0/wave/lenses/0FKP00000004CdhOAE/files\",' +
      '\"folder\": {' +
        '\"id\": \"005P0000001F9rTIAS\"' +
      '},' +
      '\"id\": \"0FKP00000004CdhOAE\",' +
      '\"label\": \"Orange True Sample (Clone)\",' +
      '\"lastAccessedDate\": \"2016-08-24T18:10:09.000Z\",' +
      '\"lastModifiedBy\": {' +
        '\"id\": \"005P0000001F9rTIAS\",' +
        '\"name\": \"Brandon Robins\",' +
        '\"profilePhotoUrl\": \"https://onecomcast--wavedev--c.cs4.content.force.com/profilephoto/005/T\"' +
      '},' +
      '\"lastModifiedDate\": \"2016-08-17T16:57:52.000Z\",' +
      '\"name\": \"Orange_True_Sample\",' +
      '\"permissions\": {' +
        '\"manage\": true,' +
        '\"modify\": true,' +
        '\"view\": true' +
      '},' +
      '\"refreshDate\": \"2016-08-17T11:38:56.000Z\",' +
      '\"state\": {' +
        '\"query\": {' +
          '\"query\":' + '\"{&amp;quot;filters&amp;quot;:[[&amp;quot;Orange&amp;quot;,[&amp;quot;true&amp;quot;],&amp;quot;in&amp;quot;]],&amp;quot;values&amp;quot;:[&amp;quot;Account&amp;quot;,&amp;quot;Disconnect_Reason&amp;quot;,&amp;quot;Record_ID&amp;quot;,&amp;quot;Address&amp;quot;,&amp;quot;HSI_Active1&amp;quot;,&amp;quot;Disconnect_Days&amp;quot;,&amp;quot;Census_Block&amp;quot;,&amp;quot;County_Code&amp;quot;,&amp;quot;Tap_Status1&amp;quot;,&amp;quot;Write_Off_Amount&amp;quot;]}\",' +
          '\"version\": -1' +
        '}' +
      '},' +
      '\"type\": \"lens\",' +
      '\"url\": \"/services/data/v36.0/wave/lenses/0FKP00000004CdhOAE\",' +
      '\"visualizationType\": \"valuestable\"' +
    '}';
  }

  // JSON returned from getLensList
  private String getLensList() {
    return '{' +
      '\"lenses\": [' +
        '{' +
          '\"allowPreview\": true,' +
          '\"assetSharingUrl\": \"https://onecomcast--wavedev.cs4.my.salesforce.com/analytics/wave/lens?assetId=0FKP00000004CdhOAE&orgId=00DP0000000DZAp&loginHost=cs4.salesforce.com&urlType=sharing\",' +
          '\"createdBy\": {' +
            '\"id\": \"0051600000752yMAAQ\",' +
            '\"name\": \"Scott McCambridge\",' +
            '\"profilePhotoUrl\": \"https://onecomcast--wavedev--c.cs4.content.force.com/profilephoto/005/T\"' +
          '},' +
          '\"createdDate\": \"2016-08-17T11:55:53.000Z\",' +
          '\"dataset\": {' +
            '\"id\": \"0FbP00000006hQiKAI\",' +
            '\"name\": \"Customer_Address\",' +
            '\"url\": \"/services/data/v36.0/wave/datasets/0FbP00000006hQiKAI\"' +
          '},' +
          '\"files\": [' +
            '{' +
              '\"contentType\": \"image/png\",' +
              '\"fileLength\": 16444,' +
              '\"fileName\": \"assetPreviewThumb\",' +
              '\"id\": \"0FJP00000008OhPOAU\",' +
              '\"lastModifiedDate\": \"2016-08-17T16:57:54.000Z\",' +
              '\"url\": \"/services/data/v36.0/wave/lenses/0FKP00000004CdhOAE/files/0FJP00000008OhPOAU\"' +
            '}' +
          '],' +
          '\"filesUrl\": \"/services/data/v36.0/wave/lenses/0FKP00000004CdhOAE/files\",' +
          '\"folder\": {' +
            '\"id\": \"005P0000001F9rTIAS\"' +
          '},' +
          '\"id\": \"0FKP00000004CdhOAE\",' +
          '\"label\": \"Orange True Sample (Clone)\",' +
          '\"lastAccessedDate\": \"2016-08-23T21:02:06.000Z\",' +
          '\"lastModifiedBy\": {' +
            '\"id\": \"005P0000001F9rTIAS\",' +
            '\"name\": \"Brandon Robins\",' +
            '\"profilePhotoUrl\": \"https://onecomcast--wavedev--c.cs4.content.force.com/profilephoto/005/T\"' +
          '},' +
          '\"lastModifiedDate\": \"2016-08-17T16:57:52.000Z\",' +
          '\"name\": \"Orange_True_Sample\",' +
          '\"permissions\": {' +
            '\"manage\": true,' +
            '\"modify\": true,' +
            '\"view\": true' +
          '},' +
          '\"refreshDate\": \"2016-08-17T11:38:56.000Z\",' +
          '\"type\": \"lens\",' +
          '\"url\": \"/services/data/v36.0/wave/lenses/0FKP00000004CdhOAE\",' +
          '\"visualizationType\": \"valuestable\"' +
        '},' +
        '{' +
          '\"allowPreview\": true,' +
          '\"assetSharingUrl\": \"https://onecomcast--wavedev.cs4.my.salesforce.com/analytics/wave/lens?assetId=0FK16000000Caa9GAC&orgId=00DP0000000DZAp&loginHost=cs4.salesforce.com&urlType=sharing\",' +
          '\"createdBy\": {' +
            '\"id\": \"00516000006wMqtAAE\",' +
            '\"name\": \"NDW Wave\",' +
            '\"profilePhotoUrl\": \"https://onecomcast--wavedev--c.cs4.content.force.com/profilephoto/005/T\"' +
          '},' +
          '\"createdDate\": \"2016-06-17T12:38:55.000Z\",' +
          '\"dataset\": {' +
            '\"id\": \"0Fb16000000PB7SCAW\",' +
            '\"name\": \"Property_with_Oppty_and_Contract\",' +
            '\"url\": \"/services/data/v36.0/wave/datasets/0Fb16000000PB7SCAW\"' +
          '},' +
          '\"files\": [' +
            '{' +
              '\"contentType\": \"image/png\",' +
              '\"fileLength\": 15321,' +
              '\"fileName\": \"assetPreviewThumb\",' +
              '\"id\": \"0FJ16000000Cab2GAC\",' +
              '\"lastModifiedDate\": \"2016-07-27T12:31:28.000Z\",' +
              '\"url\": \"/services/data/v36.0/wave/lenses/0FK16000000Caa9GAC/files/0FJ16000000Cab2GAC\"' +
            '}' +
          '],' +
          '\"filesUrl\": \"/services/data/v36.0/wave/lenses/0FK16000000Caa9GAC/files\",' +
          '\"folder\": {' +
            '\"id\": \"00l160000029wWiAAI\",' +
            '\"label\": \"Competitive Area Properties\",' +
            '\"name\": \"Competitive_Area_Properties\",' +
            '\"url\": \"/services/data/v36.0/wave/folders/00l160000029wWiAAI\"' +
          '},' +
          '\"id\": \"0FK16000000Caa9GAC\",' +
          '\"label\": \"CA 101 - Sales Funnel and Contract Information by Location\",' +
          '\"lastAccessedDate\": \"2016-08-23T21:02:01.000Z\",' +
          '\"lastModifiedBy\": {' +
            '\"id\": \"00516000006wMqtAAE\",' +
            '\"name\": \"NDW Wave\",' +
            '\"profilePhotoUrl\": \"https://onecomcast--wavedev--c.cs4.content.force.com/profilephoto/005/T\"' +
          '},' +
          '\"lastModifiedDate\": \"2016-06-17T12:38:55.000Z\",' +
          '\"name\": \"CA_101_Sales_Funnel_and_Contract_Information_by_Location\",' +
          '\"permissions\": {' +
            '\"manage\": true,' +
            '\"modify\": true,' +
            '\"view\": true' +
          '},' +
          '\"type\": \"lens\",' +
          '\"url\": \"/services/data/v36.0/wave/lenses/0FK16000000Caa9GAC\",' +
          '\"visualizationType\": \"valuestable\"' +
        '}' +
      '],' +
      '\"nextPageUrl\": null,' +
      '\"totalSize\": 2,' +
      '\"url\": \"/services/data/v36.0/wave/lenses\"' +
    '}';
  }

  // JSON returned from getWave
  private String getWave() {
    return '{' +
      '\"dashboards\": \"/services/data/v36.0/wave/dashboards\",' +
      '\"datasets\": \"/services/data/v36.0/wave/datasets\",' +
      '\"folders\": \"/services/data/v36.0/wave/folders\",' +
      '\"lenses\": \"/services/data/v36.0/wave/lenses\",' +
      '\"query\": \"/services/data/v36.0/wave/query\"' +
    '}';
  }

  // JSON returned from postQuery
  private String postQuery() {
    List<Customer_Address__c> testAddresses = [select Id from Customer_Address__c];
    if(!testAddresses.isEmpty()){
      return '{' +
        '\"action\": \"query\",' +
        '\"responseId\": \"45sXI2LbGu08FQVeRhqm3k\",' +
        '\"results\": {' +
          '\"records\": [' +
            '{' +
              '\"Id\": \"'+testAddresses[0].Id+'\"' +
            '},' +
            '{' +
              '\"Id\": \"'+testAddresses[1].Id+'\"' +
            '}' +
          ']' +
        '},' +
        '\"query\": \"q = load \\"0FbP00000006hQiKAI/0FcP00000006geyKAA\\"; q = filter q by \'Orange\' == \\"true\\"; q = foreach q generate \'Account\' as \'Account\', \'Address\' as \'Address\', \'Census_Block\' as \'Census_Block\',\' + \'\'County_Code\' as \'County_Code\', \'Disconnect_Days\' as \'Disconnect_Days\', \'Disconnect_Reason\' as \'Disconnect_Reason\', \'HSI_Active1\' as \'HSI_Active1\', \'Record_ID\' as \'Record_ID\', \'Tap_Status1\' as \'Tap_Status1\', \'Write_Off_Amount\' as \'Write_Off_Amount\'; q = limit q 100;\",' +
        '\"responseTime\": 450' +
      '}';
    }else{
      return '{' +
        '\"action\": \"query\",' +
        '\"responseId\": \"45sXI2LbGu08FQVeRhqm3k\",' +
        '\"results\": {' +
          '\"records\": [' +
            '{' +
              '\"Id\": \"a0E1600001DK7p2EAD\"' +
            '},' +
            '{' +
              '\"Id\": \"a0E1600001DK7rsEAD\"' +
            '}' +
          ']' +
        '},' +
        '\"query\": \"q = load \\"0FbP00000006hQiKAI/0FcP00000006geyKAA\\"; q = filter q by \'Orange\' == \\"true\\"; q = foreach q generate \'Account\' as \'Account\', \'Address\' as \'Address\', \'Census_Block\' as \'Census_Block\',\' + \'\'County_Code\' as \'County_Code\', \'Disconnect_Days\' as \'Disconnect_Days\', \'Disconnect_Reason\' as \'Disconnect_Reason\', \'HSI_Active1\' as \'HSI_Active1\', \'Record_ID\' as \'Record_ID\', \'Tap_Status1\' as \'Tap_Status1\', \'Write_Off_Amount\' as \'Write_Off_Amount\'; q = limit q 100;\",' +
        '\"responseTime\": 450' +
      '}';      
    }
    
  }
}