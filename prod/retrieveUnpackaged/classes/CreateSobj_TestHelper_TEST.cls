/****************************
* Unit tests for asset Autogenerate sobjects for APEX test classes
* https://appirio.my.salesforce.com/apex/CMC_AssetView?id=a3E50000000PDVg&sfdc.override=1
* Created by: David Jordan djordan@appirio.com
* 25th Septemeber 2012
*****************************/


@isTest
private class CreateSobj_TestHelper_TEST {

	// EXAMPLE HOW TO USE createSobjs()
    static testMethod void testCreateSObjs() {
    	Integer numRecords = 2;
    	// Try to include as many types in here as possible
        list<String> fieldList = new String[]{'id', 'whoId', 'SUBJECT', 'DescrIPTION', 'ActivityDate', 'Industry', 'IsVisibleInSelfService', 'CallDurationInSeconds'};
        
        // Note that the return from createSobjs should be manually cast to the correct type in order to be able to use the "t.whoId" etc format
        // If you don't cast the return value, then you can use t.get('whoId') instead
        list<task> tasks = (list<task>)CreateSobj_TestHelper.createSobjs(numRecords, 'Task', fieldList);
        system.debug('createSobjs output = '+tasks);
        
        system.assert(tasks.size()==numRecords);
        // Don't try to insert the records yet just in case there are field validation rules
        
        for(integer i=0; i<numRecords; i++) {
        	task t = tasks.get(i);
        	
        	// Using assert inside this test method. If you business logic requires any specific values, e.g. whoId, then put them in here...
        	// x-ref fields should not be populated, even if they are in the fieldList
        	system.assert(t.id==null);
        	system.assert(t.whoId==null); 
        	system.assert(t.Type==null); // Not creatable or updateable
        	        	
        	system.assert(t.subject!=null); // String
        	system.assert(t.description!=null); // Long string 
        	system.assert(t.ActivityDate!=null);  // Date

        	system.assert(t.CallDurationInSeconds!=null); // One of the vew few (only?) true integer fields in SFDC 
        	// Missing double, time and dateTime here so go for another object which has these as standard types
        }     
    } // End of method
    
    
	static testMethod void createTestAccount() {
	    String fieldsForInsert = 'id, name, Site, Industry, Phone, Website, AnnualRevenue, OwnerId, Description, NumberOfEmployees';
	    fieldsForInsert = fieldsForInsert.toUpperCase();
	    list<string> fieldsForInsertArr = fieldsForInsert.split(',');
	
	    list<Account> recsForInsert = (list<Account>)CreateSobj_TestHelper.createSobjs(1, 'Account', fieldsForInsertArr);
	    system.assert(recsForInsert.size()==1);
	    insert recsForInsert;
	} // End of method createTestAccount
	
	static testMethod void createTestContact() {
	    String fieldsForInsert = 'id, lastName, DoNotCall, Birthdate, Email, FieldNotInObject';
	    fieldsForInsert = fieldsForInsert.toUpperCase();
	    list<string> fieldsForInsertArr = fieldsForInsert.split(',');
	
	    list<Contact> recsForInsert = (list<Contact>)CreateSobj_TestHelper.createSobjs(2, 'Contact', fieldsForInsertArr);
	    system.assert(recsForInsert.size()==2);
	    insert recsForInsert;
	} // End of method createTestContact
	
	static testMethod void createTestEvent() {
	    String fieldsForInsert = 'id, ActivityDateTime, DurationInMinutes, DoNotCall, Birthdate, Email, FieldNotInObject';
	    fieldsForInsert = fieldsForInsert.toUpperCase();
	    list<string> fieldsForInsertArr = fieldsForInsert.split(',');
	
	    list<Event> recsForInsert = (list<Event>)CreateSobj_TestHelper.createSobjs(2, 'Event', fieldsForInsertArr);
	    system.assert(recsForInsert.size()==2);
	    insert recsForInsert;
	} // End of method createTestEvent
	
	static testMethod void createTestContactFeed() {
	    String fieldsForInsert = 'id';
	    fieldsForInsert = fieldsForInsert.toUpperCase();
	    list<string> fieldsForInsertArr = fieldsForInsert.split(',');
	
		// ContactFeed is not insertable
	    list<ContactFeed> recsForInsert = (list<ContactFeed>)CreateSobj_TestHelper.createSobjs(1, 'ContactFeed', fieldsForInsertArr);
	    system.assert(recsForInsert==null);
	} // End of method createTestContactFeed
	
} // End of class