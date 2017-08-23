/**
 * @author Salesforce Program Architect
 * @date 20170628
 * @description Setup HTTP Mocking for MetricsPerformanceData Testing
 * @Last Modified By :Tejaswini Kasar (US1137111)
 * @Description : Added "," after all the integer datatypes in JSON
 */ 
global class MetricsPerformanceDataHttpCalloutMock implements HttpCalloutMock {
  global HttpResponse respond(HTTPRequest req) {
      HttpResponse res = new HttpResponse();
      String currentEndpoint = req.getEndpoint();
        // 'wave/datasets/' - i.e. with the end '/' - signifies the inclusion of an id in the URL - i.e. get a dataset by id
        if (currentEndpoint.contains('wave/datasets/')) {
          WaveApiUtilHttpCalloutMock waveApiHttpMock = new WaveApiUtilHttpCalloutMock();
            res.setBody(waveApiHttpMock.getDataset());
          res.setStatusCode(200);
      } else if (currentEndpoint.contains('wave/query')) {
      res.setBody(getQueryResults());
      res.setStatusCode(200);
      } else if (currentEndpoint.contains('services/Soap')) {
            LoginToGetSessionIdMockServiceImpl loginSession = new LoginToGetSessionIdMockServiceImpl();
            res = loginSession.respond(req);
        } else {
      res.setStatusCode(404);
        }
        return res;
    }

    global String getQueryResults() {
        String formattedReturn = '{' + 
            '\"action\":\"query\",' +
            '\"responseId\":\"4BlTcAPuR1FjiBVUOjcLnV\",' + 
            '\"results\":{' +
              '\"records\":[' + 
                    '{' +
                        '\"AUDIT_UPDATED_TS\":\"2017-06-27\",' + 
                        '\"DIVISION_NAME\":\"West Division\",' + 
                        '\"IQ_CDV_ACTUAL_CNT\":0,' + 
                        '\"IQ_CDV_ADJUSTED_GOAL_CNT\":0,' + 
                        '\"IQ_HSD_ACTUAL_CNT\":0,' + 
                        '\"IQ_HSD_ADJUSTED_GOAL_CNT\":0,' + 
                        '\"IQ_TOTAL_ACTUAL_CNT\":0,' + 
                        '\"IQ_TOTAL_ADJUSTED_GOAL_CNT\":0,' + 
                        '\"IQ_VIDEO_ACTUAL_CNT\":0,' + 
                        '\"IQ_VIDEO_ADJUSTED_GOAL_CNT\":0,' + 
                        '\"IQ_XHS_ADJUSTED_GOAL_CNT\":0,' + 
                        '\"IQ_XH_ACTUAL_CNT\":0,' + 
                        '\"PAYROLL_END_DATE\":\"2017-04-21\",' + 
                        '\"REGION_NAME\":\"California Region\",' + 
                        '\"SALES_COMP_SALES_CHNL_DESC\":\"Indirect\",' + 
                        '\"SALES_REP_NAME\":\"Open3PL, Sacramento\",' + 
                        '\"SALES_REP_PERNR\":\"05222015\",' + 
                        '\"SITE_NAME\":\"California Indirect Sales 2015\",' + 
                        '\"SITE_NUMBER\":\"100\"' +
                    '},' +
                    '{' +
                        '\"AUDIT_UPDATED_TS\":\"2017-06-27\",' + 
                        '\"DIVISION_NAME\":\"West Division\",' + 
                        '\"IQ_CDV_ACTUAL_CNT\":6,' + 
                        '\"IQ_CDV_ADJUSTED_GOAL_CNT\":9,' + 
                        '\"IQ_HSD_ACTUAL_CNT\":148,' + 
                        '\"IQ_HSD_ADJUSTED_GOAL_CNT\":133,' + 
                        '\"IQ_TOTAL_ACTUAL_CNT\":247,' + 
                        '\"IQ_TOTAL_ADJUSTED_GOAL_CNT\":250,' + 
                        '\"IQ_VIDEO_ACTUAL_CNT\":93,' + 
                        '\"IQ_VIDEO_ADJUSTED_GOAL_CNT\":105,' + 
                        '\"IQ_XHS_ADJUSTED_GOAL_CNT\":3,' + 
                        '\"IQ_XH_ACTUAL_CNT\":0,' + 
                        '\"PAYROLL_END_DATE\":\"2017-04-21\",' + 
                        '\"REGION_NAME\":\"California Region\",' + 
                        '\"SALES_COMP_SALES_CHNL_DESC\":\"Indirect\",' + 
                        '\"SALES_REP_NAME\":\"Open, CAD\",' + 
                        '\"SALES_REP_PERNR\":\"05222015\",' + //Changed the data for SALES_REP_PERNR (US1137111)
                        '\"SITE_NAME\":\"California Indirect Sales 2015\",' + 
                        '\"SITE_NUMBER\":\"100\"' + 
                    '},' + 
                    '{' +
                        '\"AUDIT_UPDATED_TS\":\"2017-06-27\",' + 
                        '\"DIVISION_NAME\":\"West Division\",' + 
                        '\"IQ_CDV_ACTUAL_CNT\":0,' + 
                        '\"IQ_CDV_ADJUSTED_GOAL_CNT\":0,' + 
                        '\"IQ_HSD_ACTUAL_CNT\":0,' + 
                        '\"IQ_HSD_ADJUSTED_GOAL_CNT\":0,' + 
                        '\"IQ_TOTAL_ACTUAL_CNT\":0,' + 
                        '\"IQ_TOTAL_ADJUSTED_GOAL_CNT\":0,' + 
                        '\"IQ_VIDEO_ACTUAL_CNT\":0,' + 
                        '\"IQ_VIDEO_ADJUSTED_GOAL_CNT\":0,' + 
                        '\"IQ_XHS_ADJUSTED_GOAL_CNT\":0,' + 
                        '\"IQ_XH_ACTUAL_CNT\":0,' + 
                        '\"PAYROLL_END_DATE\":\"2017-04-21\",' + 
                        '\"REGION_NAME\":\"California Region\",' + 
                        '\"SALES_COMP_SALES_CHNL_DESC\":\"Indirect\",' + 
                        '\"SALES_REP_NAME\":\"Open3PL, Bay\",' + 
                        '\"SALES_REP_PERNR\":\"09152015\",' + 
                        '\"SITE_NAME\":\"California Indirect Sales 2015\",' + 
                        '\"SITE_NUMBER\":\"100\"' +
                    '},' + 
                    '{' +
                        '\"AUDIT_UPDATED_TS\":\"2017-06-27\",' + 
                        '\"DIVISION_NAME\":\"Central Division\",' + 
                        '\"IQ_CDV_ACTUAL_CNT\":47,' + 
                        '\"IQ_CDV_ADJUSTED_GOAL_CNT\":51,' + 
                        '\"IQ_HSD_ACTUAL_CNT\":164,' + 
                        '\"IQ_HSD_ADJUSTED_GOAL_CNT\":219,' + 
                        '\"IQ_TOTAL_ACTUAL_CNT\":388,' + 
                        '\"IQ_TOTAL_ADJUSTED_GOAL_CNT\":479,' + 
                        '\"IQ_VIDEO_ACTUAL_CNT\":160,' + 
                        '\"IQ_VIDEO_ADJUSTED_GOAL_CNT\":194,' + 
                        '\"IQ_XHS_ADJUSTED_GOAL_CNT\":15,' + 
                        '\"IQ_XH_ACTUAL_CNT\":17,' + 
                        '\"PAYROLL_END_DATE\":\"2017-04-21\",' + 
                        '\"REGION_NAME\":\"Heartland Region\",' + 
                        '\"SALES_COMP_SALES_CHNL_DESC\":\"Indirect\",' + 
                        '\"SALES_REP_NAME\":\"Open, Siegel\",' + 
                        '\"SALES_REP_PERNR\":\"10000001\",' + 
                        '\"SITE_NAME\":\"Heartland Indirect Sales 2015\",' + 
                        '\"SITE_NUMBER\":\"115\"' +
                    '},' + 
                    '{' +
                        '\"AUDIT_UPDATED_TS\":\"2017-06-27\",' + 
                        '\"DIVISION_NAME\":\"Central Division\",' + 
                        '\"IQ_CDV_ACTUAL_CNT\":23,' + 
                        '\"IQ_CDV_ADJUSTED_GOAL_CNT\":45,' + 
                        '\"IQ_HSD_ACTUAL_CNT\":114,' + 
                        '\"IQ_HSD_ADJUSTED_GOAL_CNT\":208,' + 
                        '\"IQ_TOTAL_ACTUAL_CNT\":251,' + 
                        '\"IQ_TOTAL_ADJUSTED_GOAL_CNT\":452,' + 
                        '\"IQ_VIDEO_ACTUAL_CNT\":101,' + 
                        '\"IQ_VIDEO_ADJUSTED_GOAL_CNT\":185,' + 
                        '\"IQ_XHS_ADJUSTED_GOAL_CNT\":14,' + 
                        '\"IQ_XH_ACTUAL_CNT\":13,' + 
                        '\"PAYROLL_END_DATE\":\"2017-04-21\",' + 
                        '\"REGION_NAME\":\"Heartland Region\",' + 
                        '\"SALES_COMP_SALES_CHNL_DESC\":\"Indirect\",' + 
                        '\"SALES_REP_NAME\":\"Open, Turnage\",' + 
                        '\"SALES_REP_PERNR\":\"10000011\",' + 
                        '\"SITE_NAME\":\"Heartland Indirect Sales 2015\",' + 
                        '\"SITE_NUMBER\":\"115\"' +
                    '},' + 
                    '{' + 
                        '\"AUDIT_UPDATED_TS\":\"2017-06-27\",' + 
                        '\"DIVISION_NAME\":\"Central Division\",' + 
                        '\"IQ_CDV_ACTUAL_CNT\":0,' + 
                        '\"IQ_CDV_ADJUSTED_GOAL_CNT\":0,' + 
                        '\"IQ_HSD_ACTUAL_CNT\":0,' + 
                        '\"IQ_HSD_ADJUSTED_GOAL_CNT\":0,' + 
                        '\"IQ_TOTAL_ACTUAL_CNT\":0,' + 
                        '\"IQ_TOTAL_ADJUSTED_GOAL_CNT\":0,' + 
                        '\"IQ_VIDEO_ACTUAL_CNT\":0,' + 
                        '\"IQ_VIDEO_ADJUSTED_GOAL_CNT\":0,' + 
                        '\"IQ_XHS_ADJUSTED_GOAL_CNT\":0,' + 
                        '\"IQ_XH_ACTUAL_CNT\":0,' + 
                        '\"PAYROLL_END_DATE\":\"2017-04-21\",' + 
                        '\"REGION_NAME\":\"Heartland Region\",' + 
                        '\"SALES_COMP_SALES_CHNL_DESC\":\"Indirect\",' + 
                        '\"SALES_REP_NAME\":\"Open, Gardner\",' + 
                        '\"SALES_REP_PERNR\":\"10000111\",' + 
                        '\"SITE_NAME\":\"Heartland Indirect Sales 2015\",' + 
                        '\"SITE_NUMBER\":\"115\"' + 
                    '},' + 
                    '{' +
                        '\"AUDIT_UPDATED_TS\":\"2017-06-27\",' + 
                        '\"DIVISION_NAME\":\"Central Division\",' + 
                        '\"IQ_CDV_ACTUAL_CNT\":18,' + 
                        '\"IQ_CDV_ADJUSTED_GOAL_CNT\":20,' + 
                        '\"IQ_HSD_ACTUAL_CNT\":133,' + 
                        '\"IQ_HSD_ADJUSTED_GOAL_CNT\":117,' + 
                        '\"IQ_TOTAL_ACTUAL_CNT\":219,' + 
                        '\"IQ_TOTAL_ADJUSTED_GOAL_CNT\":210,' + 
                        '\"IQ_VIDEO_ACTUAL_CNT\":63,' + 
                        '\"IQ_VIDEO_ADJUSTED_GOAL_CNT\":67,' + 
                        '\"IQ_XHS_ADJUSTED_GOAL_CNT\":6,' + 
                        '\"IQ_XH_ACTUAL_CNT\":5,' + 
                        '\"PAYROLL_END_DATE\":\"2017-04-21\",' + 
                        '\"REGION_NAME\":\"Florida Region\",' + 
                        '\"SALES_COMP_SALES_CHNL_DESC\":\"Indirect\",' + 
                        '\"SALES_REP_NAME\":\"Baez, Yuliska M\",' + 
                        '\"SALES_REP_PERNR\":\"10002440\",' + 
                        '\"SITE_NAME\":\"Florida Indirect Sales 2015\",' + 
                        '\"SITE_NUMBER\":\"113\"' + 
                    '},' + 
                    '{' +
                        '\"AUDIT_UPDATED_TS\":\"2017-06-27\",' + 
                        '\"DIVISION_NAME\":\"Central Division\",' + 
                        '\"IQ_CDV_ACTUAL_CNT\":33,' + 
                        '\"IQ_CDV_ADJUSTED_GOAL_CNT\":31,' + 
                        '\"IQ_HSD_ACTUAL_CNT\":228,' + 
                        '\"IQ_HSD_ADJUSTED_GOAL_CNT\":231,' + 
                        '\"IQ_TOTAL_ACTUAL_CNT\":379,' + 
                        '\"IQ_TOTAL_ADJUSTED_GOAL_CNT\":395,' + 
                        '\"IQ_VIDEO_ACTUAL_CNT\":111,' + 
                        '\"IQ_VIDEO_ADJUSTED_GOAL_CNT\":120,' + 
                        '\"IQ_XHS_ADJUSTED_GOAL_CNT\":13,' + 
                        '\"IQ_XH_ACTUAL_CNT\":7,' + 
                        '\"PAYROLL_END_DATE\":\"2017-04-21\",' + 
                        '\"REGION_NAME\":\"Chicago Region\",' + 
                        '\"SALES_COMP_SALES_CHNL_DESC\":\"Indirect\",' + 
                        '\"SALES_REP_NAME\":\"Arreola, Aurora\",' + 
                        '\"SALES_REP_PERNR\":\"10011473\",' + 
                        '\"SITE_NAME\":\"Chicago Indirect Sales 2015\",' + 
                        '\"SITE_NUMBER\":\"116\"' + 
                    '},' + 
                    '{' +
                        '\"AUDIT_UPDATED_TS\":\"2017-06-27\",' + 
                        '\"DIVISION_NAME\":\"West Division\",' + 
                        '\"IQ_CDV_ACTUAL_CNT\":281,' + 
                        '\"IQ_CDV_ADJUSTED_GOAL_CNT\":62,' + 
                        '\"IQ_HSD_ACTUAL_CNT\":300,' + 
                        '\"IQ_HSD_ADJUSTED_GOAL_CNT\":331,' + 
                        '\"IQ_TOTAL_ACTUAL_CNT\":958,' + 
                        '\"IQ_TOTAL_ADJUSTED_GOAL_CNT\":670,' + 
                        '\"IQ_VIDEO_ACTUAL_CNT\":305,' + 
                        '\"IQ_VIDEO_ADJUSTED_GOAL_CNT\":241,' + 
                        '\"IQ_XHS_ADJUSTED_GOAL_CNT\":36,' + 
                        '\"IQ_XH_ACTUAL_CNT\":72,' + 
                        '\"PAYROLL_END_DATE\":\"2017-04-21\",' + 
                        '\"REGION_NAME\":\"Washington Region\",' + 
                        '\"SALES_COMP_SALES_CHNL_DESC\":\"Indirect\",' + 
                        '\"SALES_REP_NAME\":\"Brown, Elton\",' + 
                        '\"SALES_REP_PERNR\":\"10012203\",' + 
                        '\"SITE_NAME\":\"Washington Indirect Sales 2015\",' + 
                        '\"SITE_NUMBER\":\"102\"' + 
                    '},' + 
                    '{' +
                        '\"AUDIT_UPDATED_TS\":\"2017-06-27\",' + 
                        '\"DIVISION_NAME\":\"Central Division\",' + 
                        '\"IQ_CDV_ACTUAL_CNT\":16,' + 
                        '\"IQ_CDV_ADJUSTED_GOAL_CNT\":29,' + 
                        '\"IQ_HSD_ACTUAL_CNT\":211,' + 
                        '\"IQ_HSD_ADJUSTED_GOAL_CNT\":223,' + 
                        '\"IQ_TOTAL_ACTUAL_CNT\":307,' + 
                        '\"IQ_TOTAL_ADJUSTED_GOAL_CNT\":376,' + 
                        '\"IQ_VIDEO_ACTUAL_CNT\":72,' + 
                        '\"IQ_VIDEO_ADJUSTED_GOAL_CNT\":114,' + 
                        '\"IQ_XHS_ADJUSTED_GOAL_CNT\":10,' + 
                        '\"IQ_XH_ACTUAL_CNT\":8,' + 
                        '\"PAYROLL_END_DATE\":\"2017-04-21\",' + 
                        '\"REGION_NAME\":\"Chicago Region\",' + 
                        '\"SALES_COMP_SALES_CHNL_DESC\":\"Indirect\",' + 
                        '\"SALES_REP_NAME\":\"Robles, Arlo\",' + 
                        '\"SALES_REP_PERNR\":\"10018817\",' + 
                        '\"SITE_NAME\":\"Chicago Indirect Sales 2015\",' + 
                        '\"SITE_NUMBER\":\"116\"' + 
                    '}' + 
              ']' + 
            '},' + 
            '\"query\":' + 
              '\"q = load \\\"0Fb7A000000FMviSAG/0Fc7A000000UxcxSAC\\\"; ' + 
                'q = filter q by \'SALES_COMP_SALES_CHNL_DESC\' == \\\"Indirect\\\"; '+
                'q = filter q by date(\'PAYROLL_END_DATE_Year\', \'PAYROLL_END_DATE_Month\', \'PAYROLL_END_DATE_Day\') in [dateRange([2017,3,21], [2017,4,21])]; ' +
                'q = foreach q generate ' + 
                '\'PAYROLL_END_DATE\' as \'PAYROLL_END_DATE\', ' + 
                    '\'SALES_REP_PERNR\' as \'SALES_REP_PERNR\', ' + 
                    '\'SALES_REP_NAME\' as \'SALES_REP_NAME\', ' + 
                    '\'SALES_COMP_SALES_CHNL_DESC\' as \'SALES_COMP_SALES_CHNL_DESC\', ' + 
                    '\'DIVISION_NAME\' as \'DIVISION_NAME\', ' + 
                    '\'REGION_NAME\' as \'REGION_NAME\', ' + 
                    '\'SITE_NAME\' as \'SITE_NAME\', ' + 
                    '\'SITE_NUMBER\' as \'SITE_NUMBER\', ' + 
                    '\'IQ_CDV_ACTUAL_CNT\' as \'IQ_CDV_ACTUAL_CNT\', ' + 
                    '\'IQ_CDV_ADJUSTED_GOAL_CNT\' as \'IQ_CDV_ADJUSTED_GOAL_CNT\', ' + 
                    '\'IQ_HSD_ACTUAL_CNT\' as \'IQ_HSD_ACTUAL_CNT\', ' + 
                    '\'IQ_HSD_ADJUSTED_GOAL_CNT\' as \'IQ_HSD_ADJUSTED_GOAL_CNT\', ' + 
                    '\'IQ_VIDEO_ACTUAL_CNT\' as \'IQ_VIDEO_ACTUAL_CNT\', ' + 
                    '\'IQ_VIDEO_ADJUSTED_GOAL_CNT\' as \'IQ_VIDEO_ADJUSTED_GOAL_CNT\', ' + 
                    '\'IQ_XHS_ADJUSTED_GOAL_CNT\' as \'IQ_XHS_ADJUSTED_GOAL_CNT\', ' + 
                    '\'IQ_XH_ACTUAL_CNT\' as \'IQ_XH_ACTUAL_CNT\', ' + 
                    '\'IQ_TOTAL_ACTUAL_CNT\' as \'IQ_TOTAL_ACTUAL_CNT\', ' + 
                    '\'IQ_TOTAL_ADJUSTED_GOAL_CNT\' as \'IQ_TOTAL_ADJUSTED_GOAL_CNT\', ' + 
                    '\'AUDIT_UPDATED_TS\' as \'AUDIT_UPDATED_TS\' ; ' + 
            'q = order q by (\'PAYROLL_END_DATE\' desc, \'SALES_REP_PERNR\'); ' + 
            'q = offset q 0; ' + 
            'q = limit q 10;\",' + 
            '\"responseTime\":332}';
    String unformattedReturn = '{\"action\":\"query\",\"responseId\":\"4BlTcAPuR1FjiBVUOjcLnV\",\"results\":{\"records\":[{\"AUDIT_UPDATED_TS\":\"2017-06-27\",\"DIVISION_NAME\":\"West Division\",\"IQ_CDV_ACTUAL_CNT\":0,\"IQ_CDV_ADJUSTED_GOAL_CNT\":0,\"IQ_HSD_ACTUAL_CNT\":0,\"IQ_HSD_ADJUSTED_GOAL_CNT\":0,\"IQ_TOTAL_ACTUAL_CNT\":0,\"IQ_TOTAL_ADJUSTED_GOAL_CNT\":0,\"IQ_VIDEO_ACTUAL_CNT\":0,\"IQ_VIDEO_ADJUSTED_GOAL_CNT\":0,\"IQ_XHS_ADJUSTED_GOAL_CNT\":0,\"IQ_XH_ACTUAL_CNT\":0,\"PAYROLL_END_DATE\":\"2017-04-21\",\"REGION_NAME\":\"California Region\",\"SALES_COMP_SALES_CHNL_DESC\":\"Indirect\",\"SALES_REP_NAME\":\"Open3PL, Sacramento\",\"SALES_REP_PERNR\":\"05222015\",\"SITE_NAME\":\"California Indirect Sales 2015\",\"SITE_NUMBER\":\"100\"},{\"AUDIT_UPDATED_TS\":\"2017-06-27\",\"DIVISION_NAME\":\"West Division\",\"IQ_CDV_ACTUAL_CNT\":6,\"IQ_CDV_ADJUSTED_GOAL_CNT\":9,\"IQ_HSD_ACTUAL_CNT\":148,\"IQ_HSD_ADJUSTED_GOAL_CNT\":133,\"IQ_TOTAL_ACTUAL_CNT\":247,\"IQ_TOTAL_ADJUSTED_GOAL_CNT\":250,\"IQ_VIDEO_ACTUAL_CNT\":93,\"IQ_VIDEO_ADJUSTED_GOAL_CNT\":105,\"IQ_XHS_ADJUSTED_GOAL_CNT\":3,\"IQ_XH_ACTUAL_CNT\":0,\"PAYROLL_END_DATE\":\"2017-04-21\",\"REGION_NAME\":\"California Region\",\"SALES_COMP_SALES_CHNL_DESC\":\"Indirect\",\"SALES_REP_NAME\":\"Open, CAD\",\"SALES_REP_PERNR\":\"08312015\",\"SITE_NAME\":\"California Indirect Sales 2015\",\"SITE_NUMBER\":\"100\"},{\"AUDIT_UPDATED_TS\":\"2017-06-27\",\"DIVISION_NAME\":\"West Division\",\"IQ_CDV_ACTUAL_CNT\":0,\"IQ_CDV_ADJUSTED_GOAL_CNT\":0,\"IQ_HSD_ACTUAL_CNT\":0,\"IQ_HSD_ADJUSTED_GOAL_CNT\":0,\"IQ_TOTAL_ACTUAL_CNT\":0,\"IQ_TOTAL_ADJUSTED_GOAL_CNT\":0,\"IQ_VIDEO_ACTUAL_CNT\":0,\"IQ_VIDEO_ADJUSTED_GOAL_CNT\":0,\"IQ_XHS_ADJUSTED_GOAL_CNT\":0,\"IQ_XH_ACTUAL_CNT\":0,\"PAYROLL_END_DATE\":\"2017-04-21\",\"REGION_NAME\":\"California Region\",\"SALES_COMP_SALES_CHNL_DESC\":\"Indirect\",\"SALES_REP_NAME\":\"Open3PL, Bay\",\"SALES_REP_PERNR\":\"09152015\",\"SITE_NAME\":\"California Indirect Sales 2015\",\"SITE_NUMBER\":\"100\"},{\"AUDIT_UPDATED_TS\":\"2017-06-27\",\"DIVISION_NAME\":\"Central Division\",\"IQ_CDV_ACTUAL_CNT\":47,\"IQ_CDV_ADJUSTED_GOAL_CNT\":51,\"IQ_HSD_ACTUAL_CNT\":164,\"IQ_HSD_ADJUSTED_GOAL_CNT\":219,\"IQ_TOTAL_ACTUAL_CNT\":388,\"IQ_TOTAL_ADJUSTED_GOAL_CNT\":479,\"IQ_VIDEO_ACTUAL_CNT\":160,\"IQ_VIDEO_ADJUSTED_GOAL_CNT\":194,\"IQ_XHS_ADJUSTED_GOAL_CNT\":15,\"IQ_XH_ACTUAL_CNT\":17,\"PAYROLL_END_DATE\":\"2017-04-21\",\"REGION_NAME\":\"Heartland Region\",\"SALES_COMP_SALES_CHNL_DESC\":\"Indirect\",\"SALES_REP_NAME\":\"Open, Siegel\",\"SALES_REP_PERNR\":\"10000001\",\"SITE_NAME\":\"Heartland Indirect Sales 2015\",\"SITE_NUMBER\":\"115\"},{\"AUDIT_UPDATED_TS\":\"2017-06-27\",\"DIVISION_NAME\":\"Central Division\",\"IQ_CDV_ACTUAL_CNT\":23,\"IQ_CDV_ADJUSTED_GOAL_CNT\":45,\"IQ_HSD_ACTUAL_CNT\":114,\"IQ_HSD_ADJUSTED_GOAL_CNT\":208,\"IQ_TOTAL_ACTUAL_CNT\":251,\"IQ_TOTAL_ADJUSTED_GOAL_CNT\":452,\"IQ_VIDEO_ACTUAL_CNT\":101,\"IQ_VIDEO_ADJUSTED_GOAL_CNT\":185,\"IQ_XHS_ADJUSTED_GOAL_CNT\":14,\"IQ_XH_ACTUAL_CNT\":13,\"PAYROLL_END_DATE\":\"2017-04-21\",\"REGION_NAME\":\"Heartland Region\",\"SALES_COMP_SALES_CHNL_DESC\":\"Indirect\",\"SALES_REP_NAME\":\"Open, Turnage\",\"SALES_REP_PERNR\":\"10000011\",\"SITE_NAME\":\"Heartland Indirect Sales 2015\",\"SITE_NUMBER\":\"115\"},{\"AUDIT_UPDATED_TS\":\"2017-06-27\",\"DIVISION_NAME\":\"Central Division\",\"IQ_CDV_ACTUAL_CNT\":0,\"IQ_CDV_ADJUSTED_GOAL_CNT\":0,\"IQ_HSD_ACTUAL_CNT\":0,\"IQ_HSD_ADJUSTED_GOAL_CNT\":0,\"IQ_TOTAL_ACTUAL_CNT\":0,\"IQ_TOTAL_ADJUSTED_GOAL_CNT\":0,\"IQ_VIDEO_ACTUAL_CNT\":0,\"IQ_VIDEO_ADJUSTED_GOAL_CNT\":0,\"IQ_XHS_ADJUSTED_GOAL_CNT\":0,\"IQ_XH_ACTUAL_CNT\":0,\"PAYROLL_END_DATE\":\"2017-04-21\",\"REGION_NAME\":\"Heartland Region\",\"SALES_COMP_SALES_CHNL_DESC\":\"Indirect\",\"SALES_REP_NAME\":\"Open, Gardner\",\"SALES_REP_PERNR\":\"10000111\",\"SITE_NAME\":\"Heartland Indirect Sales 2015\",\"SITE_NUMBER\":\"115\"},{\"AUDIT_UPDATED_TS\":\"2017-06-27\",\"DIVISION_NAME\":\"Central Division\",\"IQ_CDV_ACTUAL_CNT\":18,\"IQ_CDV_ADJUSTED_GOAL_CNT\":20,\"IQ_HSD_ACTUAL_CNT\":133,\"IQ_HSD_ADJUSTED_GOAL_CNT\":117,\"IQ_TOTAL_ACTUAL_CNT\":219,\"IQ_TOTAL_ADJUSTED_GOAL_CNT\":210,\"IQ_VIDEO_ACTUAL_CNT\":63,\"IQ_VIDEO_ADJUSTED_GOAL_CNT\":67,\"IQ_XHS_ADJUSTED_GOAL_CNT\":6,\"IQ_XH_ACTUAL_CNT\":5,\"PAYROLL_END_DATE\":\"2017-04-21\",\"REGION_NAME\":\"Florida Region\",\"SALES_COMP_SALES_CHNL_DESC\":\"Indirect\",\"SALES_REP_NAME\":\"Baez, Yuliska M\",\"SALES_REP_PERNR\":\"10002440\",\"SITE_NAME\":\"Florida Indirect Sales 2015\",\"SITE_NUMBER\":\"113\"},{\"AUDIT_UPDATED_TS\":\"2017-06-27\",\"DIVISION_NAME\":\"Central Division\",\"IQ_CDV_ACTUAL_CNT\":33,\"IQ_CDV_ADJUSTED_GOAL_CNT\":31,\"IQ_HSD_ACTUAL_CNT\":228,\"IQ_HSD_ADJUSTED_GOAL_CNT\":231,\"IQ_TOTAL_ACTUAL_CNT\":379,\"IQ_TOTAL_ADJUSTED_GOAL_CNT\":395,\"IQ_VIDEO_ACTUAL_CNT\":111,\"IQ_VIDEO_ADJUSTED_GOAL_CNT\":120,\"IQ_XHS_ADJUSTED_GOAL_CNT\":13,\"IQ_XH_ACTUAL_CNT\":7,\"PAYROLL_END_DATE\":\"2017-04-21\",\"REGION_NAME\":\"Chicago Region\",\"SALES_COMP_SALES_CHNL_DESC\":\"Indirect\",\"SALES_REP_NAME\":\"Arreola, Aurora\",\"SALES_REP_PERNR\":\"10011473\",\"SITE_NAME\":\"Chicago Indirect Sales 2015\",\"SITE_NUMBER\":\"116\"},{\"AUDIT_UPDATED_TS\":\"2017-06-27\",\"DIVISION_NAME\":\"West Division\",\"IQ_CDV_ACTUAL_CNT\":281,\"IQ_CDV_ADJUSTED_GOAL_CNT\":62,\"IQ_HSD_ACTUAL_CNT\":300,\"IQ_HSD_ADJUSTED_GOAL_CNT\":331,\"IQ_TOTAL_ACTUAL_CNT\":958,\"IQ_TOTAL_ADJUSTED_GOAL_CNT\":670,\"IQ_VIDEO_ACTUAL_CNT\":305,\"IQ_VIDEO_ADJUSTED_GOAL_CNT\":241,\"IQ_XHS_ADJUSTED_GOAL_CNT\":36,\"IQ_XH_ACTUAL_CNT\":72,\"PAYROLL_END_DATE\":\"2017-04-21\",\"REGION_NAME\":\"Washington Region\",\"SALES_COMP_SALES_CHNL_DESC\":\"Indirect\",\"SALES_REP_NAME\":\"Brown, Elton\",\"SALES_REP_PERNR\":\"10012203\",\"SITE_NAME\":\"Washington Indirect Sales 2015\",\"SITE_NUMBER\":\"102\"},{\"AUDIT_UPDATED_TS\":\"2017-06-27\",\"DIVISION_NAME\":\"Central Division\",\"IQ_CDV_ACTUAL_CNT\":16,\"IQ_CDV_ADJUSTED_GOAL_CNT\":29,\"IQ_HSD_ACTUAL_CNT\":211,\"IQ_HSD_ADJUSTED_GOAL_CNT\":223,\"IQ_TOTAL_ACTUAL_CNT\":307,\"IQ_TOTAL_ADJUSTED_GOAL_CNT\":376,\"IQ_VIDEO_ACTUAL_CNT\":72,\"IQ_VIDEO_ADJUSTED_GOAL_CNT\":114,\"IQ_XHS_ADJUSTED_GOAL_CNT\":10,\"IQ_XH_ACTUAL_CNT\":8,\"PAYROLL_END_DATE\":\"2017-04-21\",\"REGION_NAME\":\"Chicago Region\",\"SALES_COMP_SALES_CHNL_DESC\":\"Indirect\",\"SALES_REP_NAME\":\"Robles, Arlo\",\"SALES_REP_PERNR\":\"10018817\",\"SITE_NAME\":\"Chicago Indirect Sales 2015\",\"SITE_NUMBER\":\"116\"}]},\"query\":\"q = load \\\"0Fb7A000000FMviSAG/0Fc7A000000UxcxSAC\\\"; q = filter q by \'SALES_COMP_SALES_CHNL_DESC\' == \\\"Indirect\\\"; q = filter q by date(\'PAYROLL_END_DATE_Year\', \'PAYROLL_END_DATE_Month\', \'PAYROLL_END_DATE_Day\') in [dateRange([2017,3,21], [2017,4,21])]; q = foreach q generate \'PAYROLL_END_DATE\' as \'PAYROLL_END_DATE\', \'SALES_REP_PERNR\' as \'SALES_REP_PERNR\', \'SALES_REP_NAME\' as \'SALES_REP_NAME\', \'SALES_COMP_SALES_CHNL_DESC\' as \'SALES_COMP_SALES_CHNL_DESC\', \'DIVISION_NAME\' as \'DIVISION_NAME\', \'REGION_NAME\' as \'REGION_NAME\', \'SITE_NAME\' as \'SITE_NAME\', \'SITE_NUMBER\' as \'SITE_NUMBER\', \'IQ_CDV_ACTUAL_CNT\' as \'IQ_CDV_ACTUAL_CNT\', \'IQ_CDV_ADJUSTED_GOAL_CNT\' as \'IQ_CDV_ADJUSTED_GOAL_CNT\', \'IQ_HSD_ACTUAL_CNT\' as \'IQ_HSD_ACTUAL_CNT\', \'IQ_HSD_ADJUSTED_GOAL_CNT\' as \'IQ_HSD_ADJUSTED_GOAL_CNT\', \'IQ_VIDEO_ACTUAL_CNT\' as \'IQ_VIDEO_ACTUAL_CNT\', \'IQ_VIDEO_ADJUSTED_GOAL_CNT\' as \'IQ_VIDEO_ADJUSTED_GOAL_CNT\', \'IQ_XHS_ADJUSTED_GOAL_CNT\' as \'IQ_XHS_ADJUSTED_GOAL_CNT\', \'IQ_XH_ACTUAL_CNT\' as \'IQ_XH_ACTUAL_CNT\', \'IQ_TOTAL_ACTUAL_CNT\' as \'IQ_TOTAL_ACTUAL_CNT\', \'IQ_TOTAL_ADJUSTED_GOAL_CNT\' as \'IQ_TOTAL_ADJUSTED_GOAL_CNT\', \'AUDIT_UPDATED_TS\' as \'AUDIT_UPDATED_TS\' ; q = order q by (\'PAYROLL_END_DATE\' desc, \'SALES_REP_PERNR\'); q = offset q 0; q = limit q 10;\",\"responseTime\":332}';
      // If formattedReturn has errors, then return the unformattedReturn instead. 
        return formattedReturn;    
    }
}