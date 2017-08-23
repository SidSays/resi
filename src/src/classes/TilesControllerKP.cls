public with sharing class TilesControllerKP {
    
	@AuraEnabled
    public static String getTiles() {
        Id userProfileId = UserInfo.getProfileId();
        Profile profileDetails = [SELECT Name FROM Profile WHERE Id =:userProfileId] ;
        List<Tiles__c> tilesList = [SELECT Id, Name, Tile_Icon__c, Tile_URL__c, IsExternal__c  
                                    FROM Tiles__c 
                                    WHERE Profile__c =: profileDetails.Name
                                    ORDER BY Tile_Priority__c ASC LIMIT 100];
     	system.debug('profile name is $$$: ' + profileDetails.Name);
        //return stripNamespace(JSON.serialize(tilesList));
        return JSON.serialize(tilesList);
        
    }
    
    @AuraEnabled
    public static String getProfileName() {
        String profileName = '';
        Id userProfileId = UserInfo.getProfileId();
        Profile profileDetails = [SELECT Name FROM Profile WHERE Id =:userProfileId] ;
        profileName = profileDetails.Name;
        return profileName;
        
    }
    
    public static String stripNamespace(String stringWithNamespace)
	{
		ApexClass cs = [SELECT NamespacePrefix FROM ApexClass WHERE Name = 'TilesControllerKP'];
  		String NAMESPACE = cs != null && String.isNotBlank(cs.NamespacePrefix) ? cs.NamespacePrefix : '';
  		String NAMESPACE_PREFIX = String.isNotBlank(NAMESPACE) ? NAMESPACE + '__' : '';
        return stringWithNamespace.replace(NAMESPACE_PREFIX, '');
	}
}