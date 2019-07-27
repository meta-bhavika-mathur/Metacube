@isTest
public class GenerateLatvianAuditFileControllerTest {
	
    @TestSetup
    private static void setupGeneralTestData() {
        try{
           GenerateReportsTestMethodsUtility.testSetup(); 
           GenerateReportsTestMethodsUtility.testSetup();
           setupReportTestData();           
        }catch(Exception e){
            System.debug('Exception in test setup:' + e.getStackTraceString());
            System.debug('Exception in test setup:' + e.getStackTraceString() + e.getMessage());
        }       
    }
	
    private static void setupReportTestData(){
        //Update company
        c2g__codaCompany__c cmpny = [SELECT Id, Name, c2g__Country__c FROM c2g__codaCompany__c LIMIT 1];
        cmpny.c2g__Country__c = 'Latvia';
        update cmpny;       
    }
    
	@isTest
    private static void latvianFileGenerationTest(){
        try{
            Test.startTest();
            
            Integer lim = 10;
            CreateTestData.postInvoices(lim);
            CreateTestData.postPInvoices(lim);
            GenerateLatvianAuditFileController generateLatvianReportController = new GenerateLatvianAuditFileController();    
            generateLatvianReportController.periodMonth = String.valueOf(Date.today().month());
            generateLatvianReportController.periodYear = String.valueOf(Date.today().year());
        
            generateLatvianReportController.selectedMonth = '123';
            generateLatvianReportController.selectedYear = String.valueOf(Date.today().year());        
            generateLatvianReportController.createXml();
            c2g__codaInvoice__c salesInvoice = [SELECT Id, c2g__Account__r.Name FROM c2g__codaInvoice__c LIMIT 1];
            String expectedValue = salesInvoice.c2g__Account__r.Name;  

           c2g__codaPurchaseInvoice__c purInv = [SELECT Id, c2g__Account__r.Name FROM c2g__codaPurchaseInvoice__c LIMIT 1];         
            String expectedValue = purInv.c2g__Account__r.Name; 
            Boolean containsVal = false;
            for(GenerateLatvianAuditFileController.transactionSalesInvWrapper salesTrn : generateLatvianReportController.listOfTrnsctnSalesInv){
                if(salesTrn.accName == expectedValue){

            for(GenerateLatvianAuditFileController.transactionPurInvWrapper purTrn : generateLatvianReportController.listOfTrnsctnPurchaseInv){
                if(purTrn.accName == expectedValue){
                    containsVal = true;
                }
            }
            System.assert(containsVal);
        	Test.stopTest();
        }catch(Exception e){
            System.debug('Exception in test class:' + e.getStackTraceString());
        }
    }  
}