/**
 * Test class for TemplateMerger class
 *
 * @author Ryan Sayles <rsayles@acumensolutions.com>
 * @date 10/9/14
 */

@isTest
private class TemplateMergerTest {
	
	static testMethod void mergeTemplateTest(){
		String masterTemplate = '{!MasterTemplate}';
		Map<String,String> mergeTemplateMap = new Map<String,String>();
		mergeTemplateMap.put('MergeTemplate1', 'MergeTemplate1 body');
		mergeTemplateMap.put('MergeTemplate2', 'MegerTemplate2 body');

		String mergedTemplate; 

		Test.startTest();
			TemplateMerger merger = new TemplateMerger(masterTemplate);
			mergedTemplate = merger.mergeTemplates(mergeTemplateMap);
		Test.stopTest();

		System.assertEquals('{!MasterTemplate}', mergedTemplate, 'Templates should match');
	}
	
}