//
// Generated by JSON2Apex http://json2apex.herokuapp.com/
//
// The supplied json has fields with names that are reserved words in apex
// and so can only be parsed with explicitly generated code, this option
// was auto selected for you.

global class WaveXmd {
	global static void consumeObject(JSONParser parser) {
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

	global class CreatedBy {
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
	
	global class Fields {
		public String day {get;set;} 
		public String epochDay {get;set;} 
		public String epochSecond {get;set;} 
		public String fullField {get;set;} 
		public String month {get;set;} 
		public String quarter {get;set;} 
		public String week {get;set;} 
		public String year {get;set;} 

		public Fields(JSONParser parser) {
			while (parser.nextToken() != JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != JSONToken.VALUE_NULL) {
						if (text == 'day') {
							day = parser.getText();
						} else if (text == 'epochDay') {
							epochDay = parser.getText();
						} else if (text == 'epochSecond') {
							epochSecond = parser.getText();
						} else if (text == 'fullField') {
							fullField = parser.getText();
						} else if (text == 'month') {
							month = parser.getText();
						} else if (text == 'quarter') {
							quarter = parser.getText();
						} else if (text == 'week') {
							week = parser.getText();
						} else if (text == 'year') {
							year = parser.getText();
						} else {
							System.debug(LoggingLevel.WARN, 'Fields consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	global class Format {
		public Integer decimalDigits {get;set;} 

		public Format(JSONParser parser) {
			while (parser.nextToken() != JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != JSONToken.VALUE_NULL) {
						if (text == 'decimalDigits') {
							decimalDigits = parser.getIntegerValue();
						} else {
							System.debug(LoggingLevel.WARN, 'Format consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	global class Measures {
		public String description {get;set;} 
		public String field {get;set;} 
		public Format format {get;set;} 
		public String fullyQualifiedName {get;set;} 
		public String label {get;set;} 
		public String origin {get;set;} 
		public Boolean showInExplorer {get;set;} 

		public Measures(JSONParser parser) {
			while (parser.nextToken() != JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != JSONToken.VALUE_NULL) {
						if (text == 'description') {
							description = parser.getText();
						} else if (text == 'field') {
							field = parser.getText();
						} else if (text == 'format') {
							format = new Format(parser);
						} else if (text == 'fullyQualifiedName') {
							fullyQualifiedName = parser.getText();
						} else if (text == 'label') {
							label = parser.getText();
						} else if (text == 'origin') {
							origin = parser.getText();
						} else if (text == 'showInExplorer') {
							showInExplorer = parser.getBooleanValue();
						} else {
							System.debug(LoggingLevel.WARN, 'Measures consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public CreatedBy createdBy {get;set;} 
	public String createdDate {get;set;} 
	public Dataset dataset {get;set;} 
	public List<Dates> dates {get;set;} 
	public List<DerivedDimensions> derivedDimensions {get;set;} 
	public List<DerivedDimensions> derivedMeasures {get;set;} 
	public List<Dimensions> dimensions {get;set;} 
	public String language {get;set;} 
	public CreatedBy lastModifiedBy {get;set;} 
	public String lastModifiedDate {get;set;} 
	public List<Measures> measures {get;set;} 
	public List<DerivedDimensions> organizations {get;set;} 
	public List<DerivedDimensions> showDetailsDefaultFields {get;set;} 
	public String type_Z {get;set;} // in json: type
	public String url {get;set;} 
	public String versionId {get; set;}

	public WaveXmd(JSONParser parser) {
		while (parser.nextToken() != JSONToken.END_OBJECT) {
			if (parser.getCurrentToken() == JSONToken.FIELD_NAME) {
				String text = parser.getText();
				if (parser.nextToken() != JSONToken.VALUE_NULL) {
					if (text == 'createdBy') {
						createdBy = new CreatedBy(parser);
					} else if (text == 'createdDate') {
						createdDate = parser.getText();
					} else if (text == 'dataset') {
						dataset = new Dataset(parser);
					} else if (text == 'dates') {
						dates = new List<Dates>();
						while (parser.nextToken() != JSONToken.END_ARRAY) {
							dates.add(new Dates(parser));
						}
					} else if (text == 'derivedDimensions') {
						derivedDimensions = new List<DerivedDimensions>();
						while (parser.nextToken() != JSONToken.END_ARRAY) {
							derivedDimensions.add(new DerivedDimensions(parser));
						}
					} else if (text == 'derivedMeasures') {
						derivedMeasures = new List<DerivedDimensions>();
						while (parser.nextToken() != JSONToken.END_ARRAY) {
							derivedMeasures.add(new DerivedDimensions(parser));
						}
					} else if (text == 'dimensions') {
						dimensions = new List<Dimensions>();
						while (parser.nextToken() != JSONToken.END_ARRAY) {
							dimensions.add(new Dimensions(parser));
						}
					} else if (text == 'language') {
						language = parser.getText();
					} else if (text == 'lastModifiedBy') {
						lastModifiedBy = new CreatedBy(parser);
					} else if (text == 'lastModifiedDate') {
						lastModifiedDate = parser.getText();
					} else if (text == 'measures') {
						measures = new List<Measures>();
						while (parser.nextToken() != JSONToken.END_ARRAY) {
							measures.add(new Measures(parser));
						}
					} else if (text == 'organizations') {
						organizations = new List<DerivedDimensions>();
						while (parser.nextToken() != JSONToken.END_ARRAY) {
							organizations.add(new DerivedDimensions(parser));
						}
					} else if (text == 'showDetailsDefaultFields') {
						showDetailsDefaultFields = new List<DerivedDimensions>();
						while (parser.nextToken() != JSONToken.END_ARRAY) {
							showDetailsDefaultFields.add(new DerivedDimensions(parser));
						}
					} else if (text == 'type') {
						type_Z = parser.getText();
					} else if (text == 'url') {
						url = parser.getText();
					} else {
						System.debug(LoggingLevel.WARN, 'Root consuming unrecognized property: '+text);
						consumeObject(parser);
					}
				}
			}
		}
	}
	
	global class Dataset {
		public String connector {get;set;} 
		public String description {get;set;} 
		public String fullyQualifiedName {get;set;} 

		public Dataset(JSONParser parser) {
			while (parser.nextToken() != JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != JSONToken.VALUE_NULL) {
						if (text == 'connector') {
							connector = parser.getText();
						} else if (text == 'description') {
							description = parser.getText();
						} else if (text == 'fullyQualifiedName') {
							fullyQualifiedName = parser.getText();
						} else {
							System.debug(LoggingLevel.WARN, 'Dataset consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	global class DerivedDimensions {

		public DerivedDimensions(JSONParser parser) {
			while (parser.nextToken() != JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != JSONToken.VALUE_NULL) {
						{
							System.debug(LoggingLevel.WARN, 'DerivedDimensions consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	global class Dates {
		public String alias {get;set;} 
		public Boolean compact {get;set;} 
		public String description {get;set;} 
		public Fields fields {get;set;} 
		public Integer firstDayOfWeek {get;set;} 
		public Integer fiscalMonthOffset {get;set;} 
		public Boolean isYearEndFiscalYear {get;set;} 
		public String label {get;set;} 
		public Boolean showInExplorer {get;set;} 

		public Dates(JSONParser parser) {
			while (parser.nextToken() != JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != JSONToken.VALUE_NULL) {
						if (text == 'alias') {
							alias = parser.getText();
						} else if (text == 'compact') {
							compact = parser.getBooleanValue();
						} else if (text == 'description') {
							description = parser.getText();
						} else if (text == 'fields') {
							fields = new Fields(parser);
						} else if (text == 'firstDayOfWeek') {
							firstDayOfWeek = parser.getIntegerValue();
						} else if (text == 'fiscalMonthOffset') {
							fiscalMonthOffset = parser.getIntegerValue();
						} else if (text == 'isYearEndFiscalYear') {
							isYearEndFiscalYear = parser.getBooleanValue();
						} else if (text == 'label') {
							label = parser.getText();
						} else if (text == 'showInExplorer') {
							showInExplorer = parser.getBooleanValue();
						} else {
							System.debug(LoggingLevel.WARN, 'Dates consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	global class Dimensions {
		public List<DerivedDimensions> customActions {get;set;} 
		public Boolean customActionsEnabled {get;set;} 
		public String description {get;set;} 
		public String field {get;set;} 
		public String fullyQualifiedName {get;set;} 
		public Boolean isMultiValue {get;set;} 
		public String label {get;set;} 
		public Boolean linkTemplateEnabled {get;set;} 
		public List<DerivedDimensions> members {get;set;} 
		public String origin {get;set;} 
		public List<DerivedDimensions> recordDisplayFields {get;set;} 
		public List<DerivedDimensions> salesforceActions {get;set;} 
		public Boolean salesforceActionsEnabled {get;set;} 
		public Boolean showInExplorer {get;set;} 

		public Dimensions(JSONParser parser) {
			while (parser.nextToken() != JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != JSONToken.VALUE_NULL) {
						if (text == 'customActions') {
							customActions = new List<DerivedDimensions>();
							while (parser.nextToken() != JSONToken.END_ARRAY) {
								customActions.add(new DerivedDimensions(parser));
							}
						} else if (text == 'customActionsEnabled') {
							customActionsEnabled = parser.getBooleanValue();
						} else if (text == 'description') {
							description = parser.getText();
						} else if (text == 'field') {
							field = parser.getText();
						} else if (text == 'fullyQualifiedName') {
							fullyQualifiedName = parser.getText();
						} else if (text == 'isMultiValue') {
							isMultiValue = parser.getBooleanValue();
						} else if (text == 'label') {
							label = parser.getText();
						} else if (text == 'linkTemplateEnabled') {
							linkTemplateEnabled = parser.getBooleanValue();
						} else if (text == 'members') {
							members = new List<DerivedDimensions>();
							while (parser.nextToken() != JSONToken.END_ARRAY) {
								members.add(new DerivedDimensions(parser));
							}
						} else if (text == 'origin') {
							origin = parser.getText();
						} else if (text == 'recordDisplayFields') {
							recordDisplayFields = new List<DerivedDimensions>();
							while (parser.nextToken() != JSONToken.END_ARRAY) {
								recordDisplayFields.add(new DerivedDimensions(parser));
							}
						} else if (text == 'salesforceActions') {
							salesforceActions = new List<DerivedDimensions>();
							while (parser.nextToken() != JSONToken.END_ARRAY) {
								salesforceActions.add(new DerivedDimensions(parser));
							}
						} else if (text == 'salesforceActionsEnabled') {
							salesforceActionsEnabled = parser.getBooleanValue();
						} else if (text == 'showInExplorer') {
							showInExplorer = parser.getBooleanValue();
						} else {
							System.debug(LoggingLevel.WARN, 'Dimensions consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	
	global static WaveXmd parse(String json) {
		return new WaveXmd(System.JSON.createParser(json));
	}
}