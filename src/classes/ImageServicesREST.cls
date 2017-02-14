@RestResource(urlMapping='/ImageServicesREST/*')
/**
 * ImageServicesREST.cls
 * Created on: 10/8/2011
 * Author: Priyanka Pallepati
 * Contains various webservice methods for the attaching/retreiving images.
 */
global without sharing class ImageServicesREST {
	static public final String IMAGE_FILE_EXTENSION = '.jpg';
	

    //post method to add the image to the record  
    @HttpPost
    global static returnValues attachImage() {
       
        returnValues returnVal = new returnValues();
        ID recordId = RestContext.request.headers.get('recordId');
       
        String imageName = RestContext.request.headers.get('imgName');
       
        //The image is sent as a binary MIME attachment on the body or the request
        Blob b = RestContext.request.requestBody;
        
        Attachment a= new Attachment(ParentId = recordId,
                                    Body = b,
                                    ContentType = 'image/jpeg',
                                    Name = imageName+IMAGE_FILE_EXTENSION);
    try {
            insert a;
            returnVal.attachmentId = a.id;
        } catch(DMLException e) {
            System.debug('Exception found: Unable to attach Image');
        }
        return returnVal;		
    } 
    
        @HttpGet 
    global static List<Attachment> getImageData() {
    	ID recordId = RestContext.request.params.get('recordId');
      
         List<Attachment> attachmentList = new List<Attachment>();
         for(Attachment a : [SELECT a.Id, a.Name,a.ContentType,a.Description,a.Body FROM Attachment a WHERE ParentId =: recordId])
                {
                    attachmentList.add(a);
                    
                }
            return attachmentList;    
    }
    global class returnValues {

       global String attachmentId;

    }
    
}