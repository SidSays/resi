/* Change by : Ashish Sonawane on 23/7/2015 , Replaces Account_Manager__c field by Assigned_CAR__c */
public class SharePropertyWithCAR {
    
    public static void sharePropertyWithCAR(List<MDU_Property__c> beforeList,List<MDU_Property__c> afterList,Boolean isUpdate){
        List<MDU_Property__Share> sharesToCreate = new List<MDU_Property__Share>();
        List<MDU_Property__Share> shareToDelete = new List<MDU_Property__Share>();
        set<String> oldManagerIds = new set<String>();
        set<String> updatedPropertyIds = new set<String>();
        
        if(isUpdate){
            for(Integer idx=0;idx<beforeList.size();idx++){
                if(beforeList[idx].Assigned_CAR__c  != afterlist[idx].Assigned_CAR__c){
                    //Capture the account manager ID and property id for old manager to fetch
                    //the existing sharing record for user and delete it
                    oldManagerIds.add(beforeList[idx].Assigned_CAR__c);
                    updatedPropertyIds.add(beforeList[idx].Id);
                    
                    //create sharing for new manager only if field is not null after update
                    if(afterlist[idx].Assigned_CAR__c  !=null){
                        //Create a new share record 
                        
                        sharesToCreate.add(new MDU_Property__Share(AccessLevel='Edit',
                                                                               UserOrGroupId=afterList[idx].Assigned_CAR__c ,
                                                                               ParentId=beforeList[idx].Id,
                                                                               RowCause=Schema.MDU_Property__Share.rowCause.Assigned_CAR__c)
                                          );
                         
                    }
                }   
            }
            
            if(oldManagerIds != null && oldManagerIds.size() > 0 && updatedPropertyIds != null && updatedPropertyIds.size() > 0){
                shareToDelete = [select Id from MDU_Property__Share where UserOrGroupId IN :oldManagerIds and ParentId IN :updatedPropertyIds and RowCause= :Schema.MDU_Property__Share.rowCause.Assigned_CAR__c];              
            }
        }else{
            
            for(MDU_Property__c prop: afterList){
                if(prop.Assigned_CAR__c !=null){
                    sharesToCreate.add(new MDU_Property__Share(AccessLevel='Edit',
                                                               UserOrGroupId=prop.Assigned_CAR__c ,
                                                               ParentId=prop.Id,
                                                               RowCause=Schema.MDU_Property__Share.rowCause.Assigned_CAR__c)
                                       );
                }
                
            }
        }
        
        if(sharesToCreate != null && sharesToCreate.size() > 0){
            insert sharesToCreate;
        }
        
        ////Delete the previous share record
        if(shareToDelete != null && shareToDelete.size() > 0){
            delete shareToDelete;
        }
        
    }
    
    public static void removeSharing(){
        
    }
}