@isTest
global class TerritoryValidationHTTPMockImpl implements HttpCalloutMock {

    global HttpResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        String currentEndpoint = req.getEndpoint();

        if (currentEndpoint.contains('wave/folders')) {
          res.setBody(getFolderList());
          res.setStatusCode(200);
        } else if (currentEndpoint.contains('wave/lenses/')) {
          res.setBody(getLens());
          res.setStatusCode(200);
        } else if (currentEndpoint.contains('wave/lenses')) {
          res.setBody(getLensList());
          res.setStatusCode(200);
        }  else {
          res.setStatusCode(404);
        }

        return res;
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
              '\"label\": \"Keystone Market Territories\",' +
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
              '\"label\": \"Freedom Market Territories\",' +
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
            '\"id\": \"00lP0000000rbbzIAA\"' +
          '},' +
          '\"id\": \"0FKP00000004CdhOAE\",' +
          '\"label\": \"TER0001\",' +
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
            '\"id\": \"00lP0000000rbbzIAA\"' +
          '},' +
          '\"id\": \"0FK16000000Caa9GAC\",' +
          '\"label\": \"TER0002\",' +
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
      '\"label\": \"TER001\",' +
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

}