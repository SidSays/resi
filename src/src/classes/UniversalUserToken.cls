public class UniversalUserToken {
        public List<String> scope {get; set;}
        public String client_id {get; set;}
        public String COMCAST_LNAME {get; set;}
        public String COMCAST_USERNAME {get; set;}
        public String COMCAST_EMAIL {get; set;}
        public String COMCAST_FNAME {get; set;}
        public String COMCAST_OBJGUID {get; set;}
        public String COMCAST_OBJGUID_BASE64 {get; set;}
        public String COMCAST_GUID {get; set;}
        public Integer exp {get; set;}
    
    public static UniversalUserToken parse(String json) {
        return (UniversalUserToken) System.JSON.deserialize(json, UniversalUserToken.class);
    }
}