/****************************
* Asset Autogenerate sobjects for APEX test classes
* https://appirio.my.salesforce.com/apex/CMC_AssetView?id=a3E50000000PDVg&sfdc.override=1
* Created by: David Jordan djordan@appirio.com
* 25th Septemeber 2012
*****************************/

public with sharing class CreateSobj_TestHelper {

    private static Map<String, Schema.SObjectType> globalDescribeResult; 

/*********
  * HELPER METHOD TO CREATE FAT SOBJECTs
  * Returns list of numRecords sobjects of objTypeType, with fields in fieldList popualted. Just cast into the type you want
  * OR returns NULL if object type is not insertable
  * Does not insert recs into SFDC
  **********/
public static list<sobject> createSobjs(Integer numRecords, String sobjType, list<string>fieldList) {
    list<sobject>retVal = new list<sobject>(); // Return param
    
    if(globalDescribeResult==null)
        globalDescribeResult = Schema.getGlobalDescribe(); // Cache this for use further on

    Schema.SObjectType targetType = globalDescribeResult.get(sobjType);
    Schema.DescribeSObjectResult dsor = targetType.getDescribe();
    if(!dsor.isCreateable()) // Sanity check!
        return null;    

    // A bit of data massaging to stop case seneitivity issues with .containsKey() later on
    list<string> fieldListTrimmed = new list<string>();
    for(string s:fieldList) {
        fieldListTrimmed.add(s.trim().toUpperCase());
    }
    fieldList = fieldListTrimmed;
    
    Map<String,Schema.DescribeFieldResult> describeMap = new Map<String, Schema.DescribeFieldResult>();
    Map<String, Schema.SObjectField> objectFields = dsor.fields.getMap();
    
// Keys are case sensitive. Need to change keys to UPPER
    Map<String, Schema.SObjectField> objectFieldsUpper = new map<String, Schema.SObjectField>(); 
    for(string f:objectFields.keySet()) {
        objectFieldsUpper.put(f.trim().toUpperCase(), objectFields.get(f));
    }
    
// iterate over the requested fields and get the describe info for each one. Add it to a map with field name as key
    for(String field : fieldList) {
// skip fields that are not part of the object
        if (objectFieldsUpper.containsKey(field)) { 
                Schema.DescribeFieldResult dr = objectFieldsUpper.get(field).getDescribe();
                // add the results to the map to be returned
                describeMap.put(field, dr);
        }
        else
        	System.debug(LoggingLevel.INFO, 'Not including field '+field+' as it is not in this object type');
    }
 
 // Now go and create the sobjects
    for(Integer i=0; i<numRecords; i++) {
        sObject o = globalDescribeResult.get(sobjType).newSobject();
        for(string fieldName:fieldList) {
            if(!fieldName.contains('.') && !fieldName.contains('__r')) { // Sanity check for x-ref fields
                String fName = fieldName.trim();
                Schema.DescribeFieldResult fieldDescr = describeMap.get(fName);
                if(fieldDescr!=null && fieldDescr.isCreateable() && fieldDescr.isUpdateable()) { // SANITY CHECK 2
                	
                	// Get some randomish data, based on the field type
                	Schema.DisplayType ftype = fieldDescr.getType();
                 	if(fType == Schema.DisplayType.BOOLEAN) {
                        if(i==0) // Create a mix of true & false if more than 1 object
                            o.put(fName, true);
                        else
                            o.put(fName, false);
                    }
                	else if (fType == Schema.DisplayType.COMBOBOX)
                		o.put(fName, fName+' '+i);
                	else if (fType == Schema.DisplayType.CURRENCY)
                		o.put(fName, Math.random() * 1000);
                	else if (fType == Schema.DisplayType.DATE)
                		o.put(fName, Date.today().addDays(-i));
                	else if (fType == Schema.DisplayType.DATETIME)
                		o.put(fName, DateTime.now().addDays(-i));
                	else if (fType == Schema.DisplayType.DOUBLE)
                		o.put(fName, Math.random() * 1000);
                	else if (fType == Schema.DisplayType.EMAIL)
                		o.put(fName, 'foo@'+fName+'.com');
                	else if (fType == Schema.DisplayType.INTEGER)
                		o.put(fName, (Math.random() * 1000).intValue());
                	else if (fType == Schema.DisplayType.MultiPicklist) {
                		if(Limits.getLimitPicklistDescribes() > Limits.getPicklistDescribes())
                			o.put(fName, fieldDescr.getPicklistValues()[0].getValue());
                	}
                	else if (fType == Schema.DisplayType.PERCENT)
                		o.put(fName, Math.random() * 100);
                	else if (fType == Schema.DisplayType.PHONE)
                		o.put(fName, '+1-234-567-00'+i);
                	else if (fType == Schema.DisplayType.PICKLIST) {
                		if(Limits.getLimitPicklistDescribes() > Limits.getPicklistDescribes())
                			o.put(fName, fieldDescr.getPicklistValues()[0].getValue());
                	}
                	else if (fType == Schema.DisplayType.TEXTAREA || fType == Schema.DisplayType.STRING)
                		o.put(fName, fName+' '+i);
                	else if (fType == Schema.DisplayType.TIME)
                		o.put(fName, Time.newInstance(1,2,3,4)); // 1 hour, 2 mins, 3 secs, 4 milisecs
                	else if (fType == Schema.DisplayType.URL)
                		o.put(fName, EncodingUtil.urlEncode(fName+i+'.com', 'UTF-8'));
                	else
                	// UNSUPPORTED TYPES: ID, Reference, base64, anytype, DataCategoryGroupReference, EncryptedString
                		System.debug(LoggingLevel.INFO, 'Unsupported data type '+fType+' for field '+fName);
                    } // End of sanity check 2
                } // End of sanity check 1
            } // End of field Iteration
            retVal.add(o);
        } // End of numRecords iteration
        
        system.debug('retVal ='+retVal);
    return retVal;
}

// SEE UNIT TEST CreateSobject_TestHelper_TEST.cls for examples how to use this class

} // End of class