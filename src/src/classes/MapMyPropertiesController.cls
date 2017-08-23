/***************************************************************************************************************************************
Name: AssignedPropertiesController 
Description: This class get assigned properties data and passed it to plot Map
Author: Accenture
Date    US1037366 PL: View Properties on a Map in SF1
--------------- ------------------ ------------------------------
28 June 2017 Comcast  
*****************************************************************************************************************************************/
public class MapMyPropertiesController {

    public List<String> location {get;set;}
    /**
    * Name: getAssignedProperties
    * Description: This method is used to get assigned properies.
    * @parameters: null
    * @return: List<MDU_Property__c>
    **/
    public String locationsJson {
            get{
                List<MDU_Property__c> assignedPropertyList = new List<MDU_Property__c>();
                String[] location = new String[] {};
                
                //List of Assigned Properties
                assignedPropertyList = [SELECT Id, Name, Property_Location__Latitude__s, Property_Location__Longitude__s
                        FROM MDU_Property__c
                        WHERE Property_Location__Latitude__s != NULL AND Property_Location__Longitude__s != NULL 
                        AND Assigned_CAR__c =: UserInfo.getUserId()  LIMIT : (Limits.getLimitQueryRows()-Limits.getQueryRows())
                        ];
                
                if(!assignedPropertyList.isEmpty()){
                    for (MDU_Property__c propertyList : assignedPropertyList ) {
                            location.add(propertyList.Name+'@' + propertyList.Property_Location__Latitude__s+'@' + propertyList.Property_Location__Longitude__s);
                            }
                }
                return JSON.serialize(location);
               
            }
    }
}