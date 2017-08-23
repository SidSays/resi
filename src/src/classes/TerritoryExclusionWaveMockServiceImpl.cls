@IsTEst
global class TerritoryExclusionWaveMockServiceImpl implements HttpCalloutMock {
   global HttpResponse respond(HTTPRequest req) {
      String LENS_METDATA_JSON = '{'+
      '  \"allowPreview\": true,'+
      '  \"assetSharingUrl\": \"https://onecomcast--Insightsv2.cs11.my.salesforce.com/analytics/wave/lens?assetId=0FKZ00000008OOcOAM&orgId=00DZ000000Mibvt&loginHost=cs11.salesforce.com&urlType=sharing\",'+
      '  \"createdBy\": {'+
      '    \"id\": \"005G0000004KRG3IAO\",'+
      '    \"name\": \"Anand Narasimhan\",'+
      '    \"profilePhotoUrl\": \"https://onecomcast--Insightsv2--c.cs11.content.force.com/profilephoto/005/T\"'+
      '  },'+
      '  \"createdDate\": \"2016-06-03T14:37:02.000Z\",'+
      '  \"dataset\": {'+
      '    \"id\": \"0FbZ0000000003FKAQ\",'+
      '    \"name\": \"Address49MM\",'+
      '    \"url\": \"/services/data/v36.0/wave/datasets/0FbZ0000000003FKAQ\"'+
      '  },'+
      '  \"files\": ['+
      '    {'+
      '      \"contentType\": \"image/png\",'+
      '      \"fileLength\": 11824,'+
      '      \"fileName\": \"assetPreviewThumb\",'+
      '      \"id\": \"0FJZ00000008ONPOA2\",'+
      '      \"lastModifiedDate\": \"2016-06-03T14:39:51.000Z\",'+
      '      \"url\": \"/services/data/v36.0/wave/lenses/0FKZ00000008OOcOAM/files/0FJZ00000008ONPOA2\"'+
      '    }'+
      '  ],'+
      '  \"filesUrl\": \"/services/data/v36.0/wave/lenses/0FKZ00000008OOcOAM/files\",'+
      '  \"folder\": {'+
      '    \"id\": \"005G0000004KRG3IAO\"'+
      '  },'+
      '  \"id\": \"0FKZ00000008OOcOAM\",'+
      '  \"label\": \"Bith South Non Subs\",'+
      '  \"lastAccessedDate\": \"2016-06-06T18:26:42.000Z\",'+
      '  \"lastModifiedBy\": {'+
      '    \"id\": \"005G0000004KRG3IAO\",'+
      '    \"name\": \"Anand Narasimhan\",'+
      '    \"profilePhotoUrl\": \"https://onecomcast--Insightsv2--c.cs11.content.force.com/profilephoto/005/T\"'+
      '  },'+
      '  \"lastModifiedDate\": \"2016-06-03T14:39:51.000Z\",'+
      '  \"name\": \"Bith_South_Non_Subs\",'+
      '  \"permissions\": {'+
      '    \"manage\": true,'+
      '    \"modify\": true,'+
      '    \"view\": true'+
      '  },'+
      '  \"refreshDate\": \"2014-10-28T07:08:46.000Z\",'+
      '  \"state\": {'+
      '    \"query\": {'+
      '      \"query\": \"{&amp;quot;filters&amp;quot;:[[&amp;quot;Region__c&amp;quot;,[&amp;quot;Big South&amp;quot;],&amp;quot;in&amp;quot;],[&amp;quot;Status__c&amp;quot;,[&amp;quot;Former&amp;quot;,&amp;quot;Never&amp;quot;],&amp;quot;in&amp;quot;]],&amp;quot;values&amp;quot;:[&amp;quot;Non_Marketable__c&amp;quot;,&amp;quot;Assigned_Date__c&amp;quot;,&amp;quot;City__c&amp;quot;,&amp;quot;Comcast_Division__c&amp;quot;,&amp;quot;Disconnected__c&amp;quot;,&amp;quot;HSI_Active__c&amp;quot;,&amp;quot;Installation_Status__c&amp;quot;,&amp;quot;Last_Knock_Date__c&amp;quot;,&amp;quot;Microsegment__c&amp;quot;,&amp;quot;Region__c&amp;quot;,&amp;quot;State__c&amp;quot;]}\",'+
      '      \"version\": -1'+
      '    }'+
      '  },'+
      '  \"type\": \"lens\",'+
      '  \"url\": \"/services/data/v36.0/wave/lenses/0FKZ00000008OOcOAM\",'+
      '  \"visualizationType\": \"valuestable\"'+
      '}';
String AVAILABLE_LENS_JSON = '{'+
    '  \"lenses\": ['+
    '    {'+
    '      \"allowPreview\": true,'+
    '      \"assetSharingUrl\": \"https://onecomcast--Insightsv2.cs11.my.salesforce.com/analytics/wave/lens?assetId=0FKZ00000008OOcOAM&orgId=00DZ000000Mibvt&loginHost=cs11.salesforce.com&urlType=sharing\",'+
    '      \"createdBy\": {'+
    '        \"id\": \"005G0000004KRG3IAO\",'+
    '        \"name\": \"Anand Narasimhan\",'+
    '        \"profilePhotoUrl\": \"https://onecomcast--Insightsv2--c.cs11.content.force.com/profilephoto/005/T\"'+
    '      },'+
    '      \"createdDate\": \"2016-06-03T14:37:02.000Z\",'+
    '      \"dataset\": {'+
    '        \"id\": \"0FbZ0000000003FKAQ\",'+
    '        \"name\": \"Address49MM\",'+
    '        \"url\": \"/services/data/v36.0/wave/datasets/0FbZ0000000003FKAQ\"'+
    '      },'+
    '      \"files\": ['+
    '        {'+
    '          \"contentType\": \"image/png\",'+
    '          \"fileLength\": 13008,'+
    '          \"fileName\": \"assetPreviewThumb\",'+
    '          \"id\": \"0FJZ00000008ONPOA2\",'+
    '          \"lastModifiedDate\": \"2016-06-08T16:33:08.000Z\",'+
    '          \"url\": \"/services/data/v36.0/wave/lenses/0FKZ00000008OOcOAM/files/0FJZ00000008ONPOA2\"'+
    '        }'+
    '      ],'+
    '      \"filesUrl\": \"/services/data/v36.0/wave/lenses/0FKZ00000008OOcOAM/files\",'+
    '      \"folder\": {'+
    '        \"id\": \"005G0000004KRG3IAO\"'+
    '      },'+
    '      \"id\": \"0FKZ00000008OOcOAM\",'+
    '      \"label\": \"Big South Non  Subs\",'+
    '      \"lastAccessedDate\": \"2016-06-08T19:56:41.000Z\",'+
    '      \"lastModifiedBy\": {'+
    '        \"id\": \"005G0000004KRG3IAO\",'+
    '        \"name\": \"Anand Narasimhan\",'+
    '        \"profilePhotoUrl\": \"https://onecomcast--Insightsv2--c.cs11.content.force.com/profilephoto/005/T\"'+
    '      },'+
    '      \"lastModifiedDate\": \"2016-06-08T16:33:08.000Z\",'+
    '      \"name\": \"Bith_South_Non_Subs\",'+
    '      \"permissions\": {'+
    '        \"manage\": true,'+
    '        \"modify\": true,'+
    '        \"view\": true'+
    '      },'+
    '      \"refreshDate\": \"2014-10-28T07:08:46.000Z\",'+
    '      \"type\": \"lens\",'+
    '      \"url\": \"/services/data/v36.0/wave/lenses/0FKZ00000008OOcOAM\",'+
    '      \"visualizationType\": \"valuestable\"'+
    '    }'+
    '  ],'+
    '  \"nextPageUrl\": null,'+
    '  \"totalSize\": 16,'+
    '  \"url\": \"/services/data/v36.0/wave/lenses\"'+
    '}';
      String DATASET_VERSION_JSON = '{'+
            '  "createdBy": {'+
            '    "id": "0057A000000pwsJQAQ",'+
            '    "name": "Saranjeet Singh",'+
            '    "profilePhotoUrl": "https://onecomcast--nco--c.cs44.content.force.com/profilephoto/005/T"'+
            '  },'+
            '  "createdDate": "2016-05-27T17:25:13.000Z",'+
            '  "currentVersionId": "0Fc7A0000000wISSAY",'+
            '  "currentVersionUrl": "/services/data/v36.0/wave/datasets/0Fb7A0000000ZHCSA2/versions/0Fc7A0000000wISSAY",'+
            '  "folder": {'+
            '    "id": "00l7A000000MFNAQA4",'+
            '    "label": "Shared App",'+
            '    "name": "SharedApp",'+
            '    "url": "/services/data/v36.0/wave/folders/00l7A000000MFNAQA4"'+
            '  },'+
            '  "id": "0Fb7A0000000ZHCSA2",'+
            '  "label": "Prop_Oppty",'+
            '  "lastAccessedDate": "2016-06-17T12:40:21.000Z",'+
            '  "lastModifiedBy": {'+
            '    "id": "0057A000000exouQAA",'+
            '    "name": "Integration User",'+
            '    "profilePhotoUrl": "https://onecomcast--nco--c.cs44.content.force.com/profilephoto/005/T"'+
            '  },'+
            '  "lastModifiedDate": "2016-06-15T22:54:42.000Z",'+
            '  "name": "Property_with_Oppty",'+
            '  "permissions": {'+
            '    "manage": true,'+
            '    "modify": true,'+
            '    "view": true'+
            '  },'+
            '  "type": "dataset",'+
            '  "url": "/services/data/v36.0/wave/datasets/0Fb7A0000000ZHCSA2",'+
            '  "versionsUrl": "/services/data/v36.0/wave/datasets/0Fb7A0000000ZHCSA2/versions"'+
            '}';
    String XMD_JSON = '{'+
    '  \"createdBy\": {'+
    '    \"id\": \"005Z0000002CbbCIAS\",'+
    '    \"name\": \"Integration User\",'+
    '    \"profilePhotoUrl\": \"https://onecomcast--Insightsv2--c.cs11.content.force.com/profilephoto/005/T\"'+
    '  },'+
    '  \"createdDate\": \"2014-10-28T07:31:21.000Z\",'+
    '  \"dataset\": {'+
    '    \"connector\": \"AnalyticsSampleConnector\",'+
    '    \"description\": \"address15MM_trim\",'+
    '    \"fullyQualifiedName\": \"address15MM_trim\"'+
    '  },'+
    '  \"dates\": ['+
    '    {'+
    '      \"alias\": \"Assigned_Date__c\",'+
    '      \"compact\": false,'+
    '      \"description\": \"Assigned_Date__c\",'+
    '      \"fields\": {'+
    '        \"day\": \"Assigned_Date__c_Day\",'+
    '        \"epochDay\": \"Assigned_Date__c_day_epoch\",'+
    '        \"epochSecond\": \"Assigned_Date__c_sec_epoch\",'+
    '        \"fullField\": \"Assigned_Date__c\",'+
    '        \"month\": \"Assigned_Date__c_Month\",'+
    '        \"quarter\": \"Assigned_Date__c_Quarter\",'+
    '        \"week\": \"Assigned_Date__c_Week\",'+
    '        \"year\": \"Assigned_Date__c_Year\"'+
    '      },'+
    '      \"firstDayOfWeek\": -1,'+
    '      \"fiscalMonthOffset\": 0,'+
    '      \"isYearEndFiscalYear\": true,'+
    '      \"label\": \"Assigned_Date__c\",'+
    '      \"showInExplorer\": true'+
    '    },'+
    '    {'+
    '      \"alias\": \"Last_Disconnected_Date__c\",'+
    '      \"compact\": false,'+
    '      \"description\": \"Last_Disconnected_Date__c\",'+
    '      \"fields\": {'+
    '        \"day\": \"Last_Disconnected_Date__c_Day\",'+
    '        \"epochDay\": \"Last_Disconnected_Date__c_day_epoch\",'+
    '        \"epochSecond\": \"Last_Disconnected_Date__c_sec_epoch\",'+
    '        \"fullField\": \"Last_Disconnected_Date__c\",'+
    '        \"month\": \"Last_Disconnected_Date__c_Month\",'+
    '        \"quarter\": \"Last_Disconnected_Date__c_Quarter\",'+
    '        \"week\": \"Last_Disconnected_Date__c_Week\",'+
    '        \"year\": \"Last_Disconnected_Date__c_Year\"'+
    '      },'+
    '      \"firstDayOfWeek\": -1,'+
    '      \"fiscalMonthOffset\": 0,'+
    '      \"isYearEndFiscalYear\": true,'+
    '      \"label\": \"Last_Disconnected_Date__c\",'+
    '      \"showInExplorer\": true'+
    '    }'+
    '  ],'+
    '  \"derivedDimensions\": [],'+
    '  \"derivedMeasures\": [],'+
    '  \"dimensions\": ['+
    '    {'+
    '      \"customActions\": [],'+
    '      \"customActionsEnabled\": true,'+
    '      \"description\": \"Non_Marketable__c\",'+
    '      \"field\": \"Non_Marketable__c\",'+
    '      \"fullyQualifiedName\": \"Non_Marketable__c\",'+
    '      \"isMultiValue\": false,'+
    '      \"label\": \"Non_Marketable__c\",'+
    '      \"linkTemplateEnabled\": true,'+
    '      \"members\": [],'+
    '      \"origin\": \"Non_Marketable__c\",'+
    '      \"recordDisplayFields\": [],'+
    '      \"salesforceActions\": [],'+
    '      \"salesforceActionsEnabled\": true,'+
    '      \"showInExplorer\": true'+
    '    },'+
    '    {'+
    '      \"customActions\": [],'+
    '      \"customActionsEnabled\": true,'+
    '      \"description\": \"Renewal_Status_Time__c\",'+
    '      \"field\": \"Renewal_Status_Time__c\",'+
    '      \"fullyQualifiedName\": \"Renewal_Status_Time__c\",'+
    '      \"isMultiValue\": false,'+
    '      \"label\": \"Renewal_Status_Time__c\",'+
    '      \"linkTemplateEnabled\": true,'+
    '      \"members\": [],'+
    '      \"origin\": \"Renewal_Status_Time__c\",'+
    '      \"recordDisplayFields\": [],'+
    '      \"salesforceActions\": [],'+
    '      \"salesforceActionsEnabled\": true,'+
    '      \"showInExplorer\": true'+
    '    },'+
    '    {'+
    '      \"customActions\": [],'+
    '      \"customActionsEnabled\": true,'+
    '      \"description\": \"Marital_Status__c\",'+
    '      \"field\": \"Marital_Status__c\",'+
    '      \"fullyQualifiedName\": \"Marital_Status__c\",'+
    '      \"isMultiValue\": false,'+
    '      \"label\": \"Marital_Status__c\",'+
    '      \"linkTemplateEnabled\": true,'+
    '      \"members\": [],'+
    '      \"origin\": \"Marital_Status__c\",'+
    '      \"recordDisplayFields\": [],'+
    '      \"salesforceActions\": [],'+
    '      \"salesforceActionsEnabled\": true,'+
    '      \"showInExplorer\": true'+
    '    },';
    XMD_JSON +=
    '    {'+
    '      \"customActions\": [],'+
    '      \"customActionsEnabled\": true,'+
    '      \"description\": \"Do_not_Call__c\",'+
    '      \"field\": \"Do_not_Call__c\",'+
    '      \"fullyQualifiedName\": \"Do_not_Call__c\",'+
    '      \"isMultiValue\": false,'+
    '      \"label\": \"Do_not_Call__c\",'+
    '      \"linkTemplateEnabled\": true,'+
    '      \"members\": [],'+
    '      \"origin\": \"Do_not_Call__c\",'+
    '      \"recordDisplayFields\": [],'+
    '      \"salesforceActions\": [],'+
    '      \"salesforceActionsEnabled\": true,'+
    '      \"showInExplorer\": true'+
    '    },'+
    '    {'+
    '      \"customActions\": [],'+
    '      \"customActionsEnabled\": true,'+
    '      \"description\": \"Voice_Serviceable__c\",'+
    '      \"field\": \"Voice_Serviceable__c\",'+
    '      \"fullyQualifiedName\": \"Voice_Serviceable__c\",'+
    '      \"isMultiValue\": false,'+
    '      \"label\": \"Voice_Serviceable__c\",'+
    '      \"linkTemplateEnabled\": true,'+
    '      \"members\": [],'+
    '      \"origin\": \"Voice_Serviceable__c\",'+
    '      \"recordDisplayFields\": [],'+
    '      \"salesforceActions\": [],'+
    '      \"salesforceActionsEnabled\": true,'+
    '      \"showInExplorer\": true'+
    '    },';
  XMD_JSON +=
    '    {'+
    '      \"customActions\": [],'+
    '      \"customActionsEnabled\": true,'+
    '      \"description\": \"Complex_Office__c\",'+
    '      \"field\": \"Complex_Office__c\",'+
    '      \"fullyQualifiedName\": \"Complex_Office__c\",'+
    '      \"isMultiValue\": false,'+
    '      \"label\": \"Complex_Office__c\",'+
    '      \"linkTemplateEnabled\": true,'+
    '      \"members\": [],'+
    '      \"origin\": \"Complex_Office__c\",'+
    '      \"recordDisplayFields\": [],'+
    '      \"salesforceActions\": [],'+
    '      \"salesforceActionsEnabled\": true,'+
    '      \"showInExplorer\": true'+
    '    },'+
    '    {'+
    '      \"customActions\": [],'+
    '      \"customActionsEnabled\": true,'+
    '      \"description\": \"Children__c\",'+
    '      \"field\": \"Children__c\",'+
    '      \"fullyQualifiedName\": \"Children__c\",'+
    '      \"isMultiValue\": false,'+
    '      \"label\": \"Children__c\",'+
    '      \"linkTemplateEnabled\": true,'+
    '      \"members\": [],'+
    '      \"origin\": \"Children__c\",'+
    '      \"recordDisplayFields\": [],'+
    '      \"salesforceActions\": [],'+
    '      \"salesforceActionsEnabled\": true,'+
    '      \"showInExplorer\": true'+
    '    }'+
    '  ],'+
    '  \"language\": \"en_US\",'+
    '  \"lastModifiedBy\": {'+
    '    \"id\": \"005Z0000002CbbCIAS\",'+
    '    \"name\": \"Integration User\",'+
    '    \"profilePhotoUrl\": \"https://onecomcast--Insightsv2--c.cs11.content.force.com/profilephoto/005/T\"'+
    '  },'+
    '  \"lastModifiedDate\": \"2014-10-28T07:31:21.000Z\",'+
    '  \"measures\": ['+
    '    {'+
    '      \"description\": \"Write_Off_Amount__c\",'+
    '      \"field\": \"Write_Off_Amount__c\",'+
    '      \"format\": {'+
    '        \"decimalDigits\": 2'+
    '      },'+
    '      \"fullyQualifiedName\": \"Write_Off_Amount__c\",'+
    '      \"label\": \"Write_Off_Amount__c\",'+
    '      \"origin\": \"Write_Off_Amount__c\",'+
    '      \"showInExplorer\": true'+
    '    },'+
    '    {'+
    '      \"description\": \"Corp__c\",'+
    '      \"field\": \"Corp__c\",'+
    '      \"format\": {'+
    '        \"decimalDigits\": 0'+
    '      },'+
    '      \"fullyQualifiedName\": \"Corp__c\",'+
    '      \"label\": \"Corp__c\",'+
    '      \"origin\": \"Corp__c\",'+
    '      \"showInExplorer\": true'+
    '    },'+
    '    {'+
    '      \"field\": \"Last_Disconnected_Date__c_sec_epoch\",'+
    '      \"label\": \"Last_Disconnected_Date__c_sec_epoch\",'+
    '      \"showInExplorer\": true'+
    '    }'+
    '  ],'+
    '  \"organizations\": [],'+
    '  \"showDetailsDefaultFields\": [],'+
    '  \"type\": \"main\",'+
    '  \"url\": \"/services/data/v36.0/wave/datasets/0FbZ0000000003FKAQ/versions/0FcZ000000000C7KAI/xmds/main\"'+
    '}';
    String ROWCOUNT_JSON=
        '{'+
        '  "action": "query",'+
        '  "responseId": "44Wp9Qa8PpppUBVUOjcLnV",'+
        '  "results": {'+
        '    "records": ['+
        '      {"count":1}'+
        '    ]'+
        '  },'+
        '  "query": "q = load \\"0Fb7A0000000SbtSAE/0Fc7A0000000vseSAA\\";q = filter q by \'Cntrct_Contract_Status__c\' in [\\"Active\\", \\"Expired\\", \\"Franchise\\"];q = filter q by \'Prop1_Property_Region__c\' == \\"Beltway Market\\";q = foreach q generate \'Cntrct_Contract_Status__c\' as \'Cntrct_Contract_Status__c\', \'IsExposed\' as \'IsExposed\', \'Oppty_ForecastCategory\' as \'Oppty_ForecastCategory\', \'Oppty_Type\' as \'Oppty_Type\', \'Prop1_Active_Opportunity__c\' as \'Prop1_Active_Opportunity__c\', \'Prop1_Complex_ID__c\' as \'Prop1_Complex_ID__c\', \'Prop1_County__c\' as \'Prop1_County__c\', \'Prop1_Development__c\' as \'Prop1_Development__c\', \'Prop1_Industry_Type__c\' as \'Prop1_Industry_Type__c\', \'Prop1_Name\' as \'Prop1_Name\', \'Prop1_Number_of_Units__c\' as \'Prop1_Number_of_Units__c\', \'Prop1_Property_Grade__c\' as \'Prop1_Property_Grade__c\', \'Prop1_Property_Rating__c\' as \'Prop1_Property_Rating__c\', \'Prop1_Property_Type__c\' as \'Prop1_Property_Type__c\', \'Prop1_Risk_Status__c\' as \'Prop1_Risk_Status__c\', \'Prop1_Status_SubStatus__c\' as \'Prop1_Status_SubStatus__c\';r = order q by \'Prop1_Complex_ID__c\' asc;s = offset r 0;t = limit s 5;",'+
        '  "responseTime": 220'+
        '}';
      String ADDRESSES_JSON=
        '{' +
        '  "action": "query",' +
        '  "responseId": "472IovO5qwfszQVeRhfAMV",' +
        '  "results": {' +
        '    "records": [' +
        '      { '+
        '        "Id":' + '"' + [SELECT ID FROM Customer_Address__c ORDER BY NAME ASC LIMIT 1].Id + '"'+
        '      }, '+
        '      { ' +
        '        "Id":' + '"' + [SELECT ID FROM Customer_Address__c ORDER BY NAME DESC LIMIT 1].Id + '"'+
        '      } ' +
        '   ]' +
        '  },' +
        '  "query": "q = load \'0FbP0000000DCVAKA4/0FcP0000000GJ8CKAW\'; q = filter q by \'Property_Code__c\' == \'067R\'; q = foreach q generate \'Id\' as \'Id\';q = offset q 0;q = limit q 9000",' +
        '  "responseTime": 67' +
        '}';

      System.debug('>>>>>>>>>>> endpoint:'+req.getEndpoint());
      HttpResponse res = new HttpResponse();
      res.setHeader('Content-Type', 'application/json');
      res.setStatus('200');
      if(req.getEndpoint().endsWith('/services/data/v36.0/wave/query') && req.getBody().contains('count()')){
        res.setBody(ROWCOUNT_JSON);
      }else if(req.getBody().contains('0FcP0000000GJ8CKAW')){
        res.setBody(ADDRESSES_JSON);
      }else if(req.getEndpoint().endsWith('/services/data/v36.0/wave/lenses')){
        res.setBody(AVAILABLE_LENS_JSON);
      }else if(req.getEndpoint().endsWith('/services/data/v36.0/wave/lenses/LensId')){
        res.setBody(LENS_METDATA_JSON);
      }else if(req.getEndpoint().endsWith('xmds/main')){
        res.setBody(XMD_JSON);
      }else if(req.getEndpoint().endsWith('/services/data/v36.0/wave/datasets/0FbZ0000000003FKAQ')){
        res.setBody(DATASET_VERSION_JSON);
      }
      return res;
    }
}