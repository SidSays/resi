/**
 * Name     : GSIRootMetadata
 * Usage    : Root node class for GSI Application metadata objects
 *            that define a view for mobile iPad appliation
 *  
 * Created By      : Igor Androsov
 * Modified By     : Igor Androsov
 * Modified Date   : October 29, 2014
 */
global class GSIRootMetadata {
     global String recordId {get; set;}
     global GSI_Root_Node__c rootNode {get; set;}
     
     global GSIRootMetadata(){
     }
     
     public void toStr() {
         System.debug('******* Root Node Order: ' + rootNode.Sort_Order__c + ' Name: '+rootNode.name); 
     }
     
}