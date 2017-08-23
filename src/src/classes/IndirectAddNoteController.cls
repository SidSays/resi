public class IndirectAddNoteController {
    @AuraEnabled
     public static ContentNote saveNote(ContentNote noteObj,String titleVar , String contentVar, Id LinkedEntityId){
        ContentNote c= new ContentNote();
         
        c.Title = titleVar;
        c.Content = Blob.valueOf(contentVar); 
        Database.SaveResult saveRes = database.insert(c,false);
        ContentDocumentLink cdl;
         
             if(saveRes.getId() != null){
                 cdl = new ContentDocumentLink();
                 cdl.LinkedEntityId = LinkedEntityId;
                 cdl.ContentDocumentId = saveRes.getId();
                 cdl.ShareType = 'V';
             }
         
       //System.debug('before insert*****'+cdl);   
       Database.SaveResult saveRes1 = database.insert(cdl,false);
      // System.debug('saveRes1*****'+saveRes1);  
        return c;
    } 
}