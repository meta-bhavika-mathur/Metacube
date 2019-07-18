@isTest
public class GenerateLTReportXMLControllerTest {
	
    @TestSetup
    private static void setupGeneralTestData() {
        try{
           GenerateReportsTestMethodsUtility.testSetup(); 
           c2g__codaCompany__c cmpny = [SELECT Id, Name, c2g__Country__c FROM c2g__codaCompany__c LIMIT 1];
           cmpny.c2g__Country__c = 'Lithuania';
           update cmpny;
        }catch(Exception e){
            System.debug('Exception in test setup:' +  e.getMessage() + e.getStackTraceString());
        }     
    }
	
	@isTest
    private static void lituaniaFileGenerationTest(){
        try{
            Test.startTest();
            
            Integer lim = 10;
            CreateTestData.postInvoices(lim);
            CreateTestData.postPInvoices(lim);
            List<c2g__codaTransaction__c> trnList = [select Name, c2g__OwnerCompany__r.Name, c2g__TransactionType__c, c2g__Period__r.c2g__YearName__r.Name, c2g__Period__r.c2g__PeriodNumber__c from c2g__codaTransaction__c];
            
            GenerateLTReportXMLController generateLTReportController = new GenerateLTReportXMLController();
            generateLTReportController.periodYearList = new List<String>{'2018', '2019', '2020', '2021'};
            generateLTReportController.periodMonthList = new List<String>{'123', '000', '001','002','003','004','005','006','007','008','009','010','011','012', '100', '101'};
            generateLTReportController.fileType = 'report1';
            generateLTReportController.createXml();
            
        	Test.stopTest();
        }catch(Exception e){
            System.debug('Exception in test class:' + e.getStackTraceString());
        }
    } 
    
    @isTest
    private static void saftFileGenerationTest(){
        try{
            Test.startTest();
            
            Integer lim = 10;           
            CreateTestData.postInvoices(lim);
            CreateTestData.postPInvoices(lim);
            List<c2g__codaTransaction__c> trnList = [select Name, c2g__OwnerCompany__r.Name, c2g__TransactionType__c, c2g__Period__r.c2g__YearName__r.Name, c2g__Period__r.c2g__PeriodNumber__c from c2g__codaTransaction__c];

            GenerateLTReportXMLController generateLTReportController = new GenerateLTReportXMLController();
            generateLTReportController.periodOptions.add(0,  new SelectOption('123', '123'));
            generateLTReportController.selectedYear = String.valueOf(Date.today().year());
            generateLTReportController.selectedMonth = '123';   
            generateLTReportController.fileType = 'report2';
            generateLTReportController.createXml();
            
        	Test.stopTest();
        }catch(Exception e){
            System.debug('Exception in test class:' + e.getStackTraceString() + e.getMessage());
        }
    } 
    
    @isTest
    private static void saftSetGLABalancesInfoTest(){
        try{
            Test.startTest();
            
            Integer lim = 10;           
            CreateTestData.postInvoices(lim);
            CreateTestData.postPInvoices(lim);
            GenerateLTReportXMLController generateLTReportController = new GenerateLTReportXMLController();
            generateLTReportController.periodOptions.add(0, new SelectOption('123', '123'));
            generateLTReportController.selectedYear = String.valueOf(Date.today().year());
            generateLTReportController.selectedMonth = '007';   
            generateLTReportController.fileType = 'report2';
            generateLTReportController.createXml();
            
        	Test.stopTest();
        }catch(Exception e){
            System.debug('Exception in test class:' + e.getStackTraceString() + e.getMessage());
        }
    } 
    
    @isTest
    private static void customerAccountTest(){
        try{
                Test.startTest();           
                Integer lim = 10;
                CreateTestData.postInvoices(lim);
            	CreateTestData.postPInvoices(lim);
                GenerateLTReportXMLController generateLTReportController = new GenerateLTReportXMLController();
                generateLTReportController.periodYearList = new List<String>{'2018', '2019', '2020', '2021'};
            	generateLTReportController.periodMonthList = new List<String>{'123', '000', '001','002','003','004','005','006','007','008','009','010','011','012', '100', '101'};   
            	generateLTReportController.fileType = 'report1';
                generateLTReportController.createXml();
                
                c2g__codaInvoice__c salesInvoice = [SELECT Id, c2g__Account__c FROM c2g__codaInvoice__c LIMIT 1];
                String expectedValue = salesInvoice.c2g__Account__c;            
                GenerateLTReportXMLController.wrapCustomerAccount customerAccount = generateLTReportController.mapOfCustomerAccount.get(expectedValue);
                String actualValue = customerAccount.accountId; 
            
                System.assertEquals(expectedValue, actualValue);                    
                Test.stopTest();
        }catch(Exception e){
            	System.debug('Exception in test class:' + e.getMessage());
        }
    }
    
    @isTest
    private static void supplierAccountTest(){
        try{
                Test.startTest();           
                Integer lim = 10;
                CreateTestData.postInvoices(lim);
            	CreateTestData.postPInvoices(lim);
                GenerateLTReportXMLController generateLTReportController = new GenerateLTReportXMLController();
                generateLTReportController.periodYearList = new List<String>{'2018', '2019', '2020', '2021'};
            	generateLTReportController.periodMonthList = new List<String>{'123', '000', '001','002','003','004','005','006','007','008','009','010','011','012', '100', '101'};   
            	generateLTReportController.fileType = 'report1';
                generateLTReportController.createXml();
                
                c2g__codaPurchaseInvoice__c purchaseInvoice = [SELECT Id, c2g__Account__c FROM c2g__codaPurchaseInvoice__c LIMIT 1];
                String expectedValue = purchaseInvoice.c2g__Account__c;            
                GenerateLTReportXMLController.wrapSupplierAccount supplierAccount = generateLTReportController.mapOfSupplierAccount.get(expectedValue);
                String actualValue = supplierAccount.accountId;
            	
          	 	System.assertEquals(expectedValue, actualValue); 
                Test.stopTest();
        }catch(Exception e){
            	System.debug('Exception in test class:' + e.getMessage());
        }
    }
}