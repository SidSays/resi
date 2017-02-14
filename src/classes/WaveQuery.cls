public class WaveQuery {
	public String action {get;set;} 
	public String responseId  {get;set;} 
	public Object results {get;set;}
    public String query {get;set;}
    public Integer responseTime {get;set;}
    
	public static void consumeObject(JSONParser parser) {
		Integer depth = 0;
		do {
			JSONToken curr = parser.getCurrentToken();
			if (curr == JSONToken.START_OBJECT || 
				curr == JSONToken.START_ARRAY) {
				depth++;
			} else if (curr == JSONToken.END_OBJECT ||
				curr == JSONToken.END_ARRAY) {
				depth--;
			}
		} while (depth > 0 && parser.nextToken() != null);
	}
    
    public static WaveQuery parse(String json) {
		return new WaveQuery(System.JSON.createParser(json));
	}
    
    public WaveQuery(JSONParser parser) {
		while (parser.nextToken() != JSONToken.END_OBJECT) {
			if (parser.getCurrentToken() == JSONToken.FIELD_NAME) {
				String text = parser.getText();
				if (parser.nextToken() != JSONToken.VALUE_NULL) {
					if (text == 'action') {
						action = parser.getText();
					} else if (text == 'responseId') {
						responseId = parser.getText();
					} else if (text == 'results') {
						results = parser.getText();
					} else if (text == 'query') {
						query = parser.getText();
					} else if (text == 'responseTime') {
						responseTime = parser.getIntegerValue();
					} else {
						System.debug(LoggingLevel.WARN, 'Root consuming unrecognized property: '+text);
						consumeObject(parser);
					}
				}
			}
		}
	}
}