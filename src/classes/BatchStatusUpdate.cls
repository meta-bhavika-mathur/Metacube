global class BatchStatusUpdate implements Database.Batchable<SObject>,Database.Stateful {
    global Integer recordsProcessed=0;
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query='SELECT Status__c FROM TestItem__c WHERE Add__c=TRUE';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC,List<TestItem__c> listOfTestItem) {
        for(TestItem__c testItem: listOfTestItem) {
            testItem.Status__c='ADDED';
            recordsProcessed+=1;
        }
        update listOfTestItem;
    }
    
    global void finish(Database.BatchableContext BC) {
        System.debug('Total Records Processed :'+recordsProcessed);
        AsyncApexJob job = [SELECT Id, Status, NumberOfErrors, 
            JobItemsProcessed,
            TotalJobItems, CreatedBy.Email
            FROM AsyncApexJob
            WHERE Id = :bc.getJobId()];
        System.debug('No of Errors in Job Process'+job.NumberOfErrors);
    }
}