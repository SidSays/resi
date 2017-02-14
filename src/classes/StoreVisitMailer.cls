/**
*   Generate a store visit summary email
*
*   @author Sahil Grover    <sgrover@acumensolutions.com>
*/
public with sharing class StoreVisitMailer {

    private final EmailTemplate visitSummaryTemplate;
    private final Map<String, EmailTemplate> activityEmailTemplateMap;

    public StoreVisitMailer(final EmailTemplate visitSummaryTemplate, final List<EmailTemplate> activityTemplates) {
        this.visitSummaryTemplate = visitSummaryTemplate;
        Map<String, List<EmailTemplate>> emailTemplateListMap = StoreVisitUtility.buildFieldSetMap(activityTemplates, 'DeveloperName');
        // developer name is unique so we can just rebuild the map as 1 to 1
        this.activityEmailTemplateMap = new Map<String, EmailTemplate>();
        for (String templateName : emailTemplateListMap.keySet()) {
            List<EmailTemplate> templates = emailTemplateListMap.get(templateName);
            if (templates == null || templates.isEmpty()) {
                continue;
            }

            this.activityEmailTemplateMap.put(templateName, templates[0]);
        }
    }

    public String generateEmailBody(final StoreVisitSummary visitSummary) {
        Map<String, SObject> masterSobjectMap = new Map<String, SObject>{
            'Store_Visit__c' => visitSummary.StoreVisit,
            'Account' => visitSummary.Store
        };

        MergeFieldBinder masterFieldBinder = new MergeFieldBinder(this.visitSummaryTemplate.HtmlValue);
        String masterTemplate = masterFieldBinder.replaceMergeFields(masterSobjectMap);
        // we may need to change the replacement string here or make it configurable
        masterTemplate = masterTemplate.replace('<StoreActivities>', buildActivityTemplateString(visitSummary.RequiredActivities));

        TemplateMerger visitTemplateMerger = new TemplateMerger(masterTemplate);
        Map<String, String> activityTemplateMap = buildActivityTemplateBodyMap(visitSummary.RequiredActivities, this.activityEmailTemplateMap);
        return visitTemplateMerger.mergeTemplates(activityTemplateMap);
    }

    private String buildActivityTemplateString(final List<RequiredStoreActivity> requiredActivities) {
        String activityTemplateString = '';
        for (RequiredStoreActivity requiredActivity : requiredActivities) {
            for (Store_Activity__c storeActivity : requiredActivity.StoreActivities) {

                String mailCheckField = requiredActivity.StoreActivityCategory.Send_Mail_Check_Field__c;
                if ( isActivityIncludedInEmail(mailCheckField, storeActivity) ) {
                                activityTemplateString += '{!' + storeActivity.Id + '}';
                    continue;
                }

            }
        }

        return activityTemplateString;
    }

    private Map<String, String> buildActivityTemplateBodyMap(
        final List<RequiredStoreActivity> requiredActivities, 
        final Map<String, EmailTemplate> activityEmailTemplateMap
        ) {

        Map<String, String> activityTemplateBodyMap = new Map<String, String>();
        for (RequiredStoreActivity requiredActivity : requiredActivities) {
            EmailTemplate template = activityEmailTemplateMap.get(requiredActivity.StoreActivityCategory.Email_Template__c);
            if (template == null) {
                continue;
            }

            MergeFieldBinder fieldBinder = new MergeFieldBinder(template.HtmlValue);
            for (Store_Activity__c storeActivity : requiredActivity.StoreActivities) {

                String mailCheckField = requiredActivity.StoreActivityCategory.Send_Mail_Check_Field__c;
                if ( !isActivityIncludedInEmail(mailCheckField, storeActivity) ) {
                    continue;
                }

                String templateBody = fieldBinder.replaceMergeFields(
                    new Map<String, SObject>{'Store_Activity__c' => storeActivity}
                    );

                templateBody = replaceCheckboxes(templateBody);

                activityTemplateBodyMap.put(storeActivity.Id, templateBody);
            }
        }
        return activityTemplateBodyMap;
    }

    private String replaceCheckboxes(String templateBody) {
        String checkboxTrue = '<checkbox:true>';
        String checkboxFalse = '<checkbox:false>';

        String newBody = templateBody.replace(
            '<checkbox:true>',
            '<input type="checkbox" checked disabled />'
            );

        newBody = templateBody.replace(
            '<checkbox:false>',
            '<input type="checkbox" disabled />'
            );

        return newBody;
    }

    private Boolean isActivityIncludedInEmail(String mailCheckField, Store_Activity__c storeActivity) {
        //return mailCheckField == null || (Boolean)storeActivity.get(mailCheckField);
        if(mailCheckField == null){ return false;}
        else{return true;}
    }
}