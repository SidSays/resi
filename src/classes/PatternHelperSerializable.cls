/**
 * Serializable version of PatternHelper to support passing to @future methods
 * @author: qwall@salesforce.com
 * @lastmodified: 6/14/2013
 */

public class PatternHelperSerializable {
    
        public String regexValue {set; get;}
        public String pRegEx {set; get;}
        public String substitutionValue {set; get;}
        public boolean preventPostOnMatch {set; get;}
        public Blacklisted_Word__c blacklistedWord {set; get;}
        public String origPostBody {set; get;}
		public String postId {set; get;}
        public String postCreatedById {set; get;}
		public boolean notify {set; get;}
    
    /**
     * Pass in Blacklisted word and also the regExPattern from the Pattern class
     * Serializing the Pattern.class is not supported. We just need to pass the regEx representation of it.
     */
   public PatternHelperSerializable(Blacklisted_Word__c bwc, String regExPattern, String oPostBody, String oPostCreatedById,String oPostId)
    {
        regexValue = bwc.RegexValue__c;
        pRegEx = regExPattern;
        substitutionValue =  bwc.Substitution__c;
        preventPostOnMatch = bwc.Prevent_Post_on_Breach__c;
		notify = bwc.Notify__c;
        blacklistedWord = bwc;
        origPostBody = oPostBody;
        postCreatedById = oPostCreatedById;
		postId = oPostId;
     
    }
    
  

}