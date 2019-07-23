@isTest
public class BatchStatusUpdateTest {
    @testSetup
    static void testSetup() {
        // creating testItem records
        List<TestItem__c> listOfTestItems = new  List<TestItem__c>(); 
        for(Integer record=1;record<=5;record++) {
            TestItem__c testItem = new TestItem__c(Name='test'+record,Add__c=TRUE,Status__c='NOT ADDED');
            listOfTestItems.add(testItem);
        }
        for(Integer record=6;record<=10;record++) {
            TestItem__c testItem = new TestItem__c(Name='test'+record,Add__c=FALSE,Status__c='NOT ADDED');
            listOfTestItems.add(testItem);
        }
        insert listOfTestItems;
    }
    
    @isTest
    static void testt() {
        Test.startTest();
        BatchStatusUpdate batchstatusupdate = new BatchStatusUpdate();
        Id batchId = Database.executeBatch(batchstatusupdate);
        Test.stopTest();
        // assert runs after batch process ends
        // status of marked checkbox records changed to ADDED
        List<TestItem__c> listOfTestItemsWithMarkedCheckbox = [SELECT ID FROM TestItem__c WHERE Status__c='ADDED' ];
        // status of unmarked checkbox records remains unchanged
        List<TestItem__c> listOfTestItemsWithoutMarkedCheckbox = [SELECT ID FROM TestItem__c WHERE Status__c='NOT ADDED' ];
        System.assertEquals(5,listOfTestItemsWithMarkedCheckbox.size(),'Apex Batch Failed To execute some jobs');
        System.assertEquals(5,listOfTestItemsWithoutMarkedCheckbox.size(),'Apex Batch Failed To execute some jobs');
    }
}