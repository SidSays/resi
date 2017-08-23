/**
*	Bind merge fields through apex code
*
*	@author	Sahil Grover	<sgrover@acumensolutions.com>
*/
public with sharing class MergeFieldBinder {

	private static final String MERGE_FIELD_PATTERN = '\\{\\!([a-zA-Z_0-9]+).([a-zA-Z_0-9]+)\\}';

	private Map<String, Set<String>> objectFieldMap;
	private final String originalMergeBody;

	public MergeFieldBinder(final String mergeBody) {
		this.originalMergeBody = mergeBody;
		this.objectFieldMap = getMergeFields(mergeBody);
	}

	private Map<String,Set<String>> getMergeFields(final String mergeBody) {
		Pattern mergePattern = Pattern.compile(MERGE_FIELD_PATTERN);
		Matcher mergeMatcher = mergePattern.matcher(mergeBody);
		Map<String, Set<String>> objectFieldMap = new Map<String, Set<String>>();
		while (mergeMatcher.find()) {
			String objectName = mergeMatcher.group(1);
			String fieldName = mergeMatcher.group(2);

			if (objectFieldMap.containsKey(objectName)) {
				objectFieldMap.get(objectName).add(fieldName);
			} else {
				objectFieldMap.put(objectName, new Set<String>{fieldName});
			}
		}
		return objectFieldMap;
	}

	/**
	*	Populate merge fields from an sobject map
	*	Throws a MergeBinderException if a field is not found on an SObject
	*	If the merge object is not found, the merge fields will not be replaced
	*	
	*	@param	sobjectMap	A map of SObject type name to the Sobject (e.g. {'Contact' => Contact, 'Account' => Account})
	*
	*	@return	Returns the merge text with merge fields populated
	*/
	public String replaceMergeFields(final Map<String, SObject> sobjectMap) {
		String newMergeBody = this.originalMergeBody;
		for (String objectName : this.objectFieldMap.keySet()) {
			SObject mergeObject = sobjectMap.get(objectName);
			if (mergeObject == null) {
				continue;
			}

			for (String fieldName : objectFieldMap.get(objectName)) {
				Object fieldValue = mergeObject.get(fieldName);
				if (fieldValue == null) {
					continue;
				}

				if (fieldValue instanceof DateTime) {	
					fieldValue = ((DateTime) fieldValue).format('EEE MM/dd/yyyy h:mma zzz');
				}

				newMergeBody = newMergeBody.replace(
					'{!' + objectName + '.' + fieldName + '}',
					String.valueOf(fieldValue)
					);
			}
		}
		return newMergeBody;
	}
}