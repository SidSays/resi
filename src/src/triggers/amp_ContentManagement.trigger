/*******************************************************************************
* @Name 		: amp_ContentManagement
* @Author 	:	Neeraj Gupta
* @Date 		:	01/05/2012
* @Task 		: T-45292
* @Purpose 	:	Content Trigger to create Content Detail Records and link 
							content version with content detail
							
*******************************************************************************/
trigger amp_ContentManagement on ContentVersion (before insert, after insert, after update) {
	if(Trigger.isBefore) {
		
		if(Trigger.isInsert) {
			amp_ContentManagement.beforeContentInsert(Trigger.new);
		}
		
	} else if(Trigger.isAfter) {
		
		if(trigger.isInsert) {
			
			amp_ContentManagement.afterContentInsert(Trigger.new);
			
		} else if(trigger.isUpdate) {
			
			amp_ContentManagement.afterContentUpdate(Trigger.new); 
			
		}
		
	}
	
}