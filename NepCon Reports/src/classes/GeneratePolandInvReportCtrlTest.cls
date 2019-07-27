@isTest
public class GeneratePolandInvReportCtrlTest {
    @TestSetup
    private static void setupGeneralTestData() {
    	try{
               GenerateReportsTestMethodsUtility.testSetup(); 
               c2g__codaCompany__c cmpny = [SELECT Id, Name, c2g__Country__c FROM c2g__codaCompany__c LIMIT 1];
               cmpny.c2g__Country__c = 'Poland';
               update cmpny;
        }catch(Exception e){
            System.debug('Exception Message:' + e.getMessage());
        }
	}
    
    @isTest
    private static void polandAuditFile_VATReportTest(){
        try{
            Test.startTest();
            
            Test.startTest();            
            Integer lim = 10;
            CreateTestData.postInvoices(lim);
            CreateTestData.postPInvoices(lim);
            GeneratePolandInvoicesReportController generatePolandReportController = new GeneratePolandInvoicesReportController();
            generatePolandReportController.selectedYear = String.valueOf(Date.today().year());
            generatePolandReportController.selectedMonth = '123'; 
            generatePolandReportController.fileType = 'report1';
            generatePolandReportController.createXml();
            
        	Test.stopTest();
        }catch(Exception e){
            System.debug('Exception in test class:' + e.getStackTraceString());
        }
    } 
    
    @isTest
    private static void polandAuditFile_FASalesReportTest(){
        try{
            Test.startTest();
            
            Integer lim = 10;
            CreateTestData.postInvoices(lim);
            CreateTestData.postPInvoices(lim);
            GeneratePolandInvoicesReportController generatePolandReportController = new GeneratePolandInvoicesReportController();
            generatePolandReportController.selectedYear = String.valueOf(Date.today().year());
            generatePolandReportController.selectedMonth = '123'; 
            generatePolandReportController.fileType = 'report2';
            generatePolandReportController.createXml();
            
        	Test.stopTest();
        }catch(Exception e){
            System.debug('Exception in test class:' + e.getStackTraceString());
        }
    } 
    
    @isTest
    private static void polandAuditFile_KRAllEntriesReportTest(){
        try{
            Test.startTest();
            
            Integer lim = 10;
            CreateTestData.postInvoices(lim);
            CreateTestData.postPInvoices(lim);
            GeneratePolandInvoicesReportController generatePolandReportController = new GeneratePolandInvoicesReportController();
            generatePolandReportController.periodOptions.add(0,  new SelectOption('123', '123'));
            generatePolandReportController.periodYearList = new List<String>{'2018', '2019', '2020', '2021'};
            generatePolandReportController.fileType = 'report3';
            generatePolandReportController.selectedYear = String.valueOf(Date.today().year());
            generatePolandReportController.selectedMonth = '123'; 
            generatePolandReportController.createXml();
            
        	Test.stopTest();
        }catch(Exception e){
            System.debug('Exception in test class:' + e.getStackTraceString());
        }
    }
}