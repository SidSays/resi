/**
*   Merge multiple templates into a single email body
*   The master template should container merge fields with other template names (e.g. {!templateToMerge})
*
*   @author Sahil Grover    <sgrover@acumensolutions.com>
*/
public with sharing class TemplateMerger {

    private String masterTemplate;

    public TemplateMerger(String masterTemplate) {
        this.masterTemplate = masterTemplate;
    }

    /**
    *   Merge templates into the master template
    *
    *   @param  mergeTemplateMap    A map of template name to template body
    *
    *   @return Returns the merged template
    */
    public String mergeTemplates(Map<String, String> mergeTemplateMap) {
        String mergedTemplate = masterTemplate;
        for (String templateName : mergeTemplateMap.keySet()) {
            mergedTemplate = mergedTemplate.replace('{!' + templateName + '}', mergeTemplateMap.get(templateName));
        }
        return mergedTemplate;
    }
}