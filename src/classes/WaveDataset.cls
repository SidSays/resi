//
// Generated by JSON2Apex http://json2apex.herokuapp.com/
//
// The supplied json has fields with names that are reserved words in apex
// and so can only be parsed with explicitly generated code, this option
// was auto selected for you.

public class WaveDataset {
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

	public class CreatedBy {
		public String id {get;set;} 
		public String name {get;set;} 
		public String profilePhotoUrl {get;set;} 

		public CreatedBy(JSONParser parser) {
			while (parser.nextToken() != JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != JSONToken.VALUE_NULL) {
						if (text == 'id') {
							id = parser.getText();
						} else if (text == 'name') {
							name = parser.getText();
						} else if (text == 'profilePhotoUrl') {
							profilePhotoUrl = parser.getText();
						} else {
							System.debug(LoggingLevel.WARN, 'CreatedBy consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public CreatedBy createdBy {get;set;} 
	public String createdDate {get;set;} 
	public String currentVersionId {get;set;} 
	public String currentVersionUrl {get;set;} 
	public Folder folder {get;set;} 
	public String id {get;set;} 
	public String label {get;set;} 
	public String lastAccessedDate {get;set;} 
	public CreatedBy lastModifiedBy {get;set;} 
	public String lastModifiedDate {get;set;} 
	public String name {get;set;} 
	public Permissions permissions {get;set;} 
	public String type_Z {get;set;} // in json: type
	public String url {get;set;} 
	public String versionsUrl {get;set;} 

	public WaveDataset(JSONParser parser) {
		while (parser.nextToken() != JSONToken.END_OBJECT) {
			if (parser.getCurrentToken() == JSONToken.FIELD_NAME) {
				String text = parser.getText();
				if (parser.nextToken() != JSONToken.VALUE_NULL) {
					if (text == 'createdBy') {
						createdBy = new CreatedBy(parser);
					} else if (text == 'createdDate') {
						createdDate = parser.getText();
					} else if (text == 'currentVersionId') {
						currentVersionId = parser.getText();
					} else if (text == 'currentVersionUrl') {
						currentVersionUrl = parser.getText();
					} else if (text == 'folder') {
						folder = new Folder(parser);
					} else if (text == 'id') {
						id = parser.getText();
					} else if (text == 'label') {
						label = parser.getText();
					} else if (text == 'lastAccessedDate') {
						lastAccessedDate = parser.getText();
					} else if (text == 'lastModifiedBy') {
						lastModifiedBy = new CreatedBy(parser);
					} else if (text == 'lastModifiedDate') {
						lastModifiedDate = parser.getText();
					} else if (text == 'name') {
						name = parser.getText();
					} else if (text == 'permissions') {
						permissions = new Permissions(parser);
					} else if (text == 'type') {
						type_Z = parser.getText();
					} else if (text == 'url') {
						url = parser.getText();
					} else if (text == 'versionsUrl') {
						versionsUrl = parser.getText();
					} else {
						System.debug(LoggingLevel.WARN, 'Root consuming unrecognized property: '+text);
						consumeObject(parser);
					}
				}
			}
		}
	}
	
	public class Permissions {
		public Boolean manage {get;set;} 
		public Boolean modify {get;set;} 
		public Boolean view {get;set;} 

		public Permissions(JSONParser parser) {
			while (parser.nextToken() != JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != JSONToken.VALUE_NULL) {
						if (text == 'manage') {
							manage = parser.getBooleanValue();
						} else if (text == 'modify') {
							modify = parser.getBooleanValue();
						} else if (text == 'view') {
							view = parser.getBooleanValue();
						} else {
							System.debug(LoggingLevel.WARN, 'Permissions consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public class Folder {
		public String id {get;set;} 
		public String label {get;set;} 
		public String name {get;set;} 
		public String url {get;set;} 

		public Folder(JSONParser parser) {
			while (parser.nextToken() != JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != JSONToken.VALUE_NULL) {
						if (text == 'id') {
							id = parser.getText();
						} else if (text == 'label') {
							label = parser.getText();
						} else if (text == 'name') {
							name = parser.getText();
						} else if (text == 'url') {
							url = parser.getText();
						} else {
							System.debug(LoggingLevel.WARN, 'Folder consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	
	public static WaveDataset parse(String json) {
		return new WaveDataset(System.JSON.createParser(json));
	}
}