@isTest
public class CreateFormulaFiledTest {
    @isTest static void testCreateFormulaField() {
        Test.setMock(WebServiceMock.class, new CreateFormulaFieldMock());
        String testSObject='TestObject__c';
        CreateFormulafieldController.createFormulaField(testSObject);
        MetadataService.SaveResult result=CreateFormulafieldController.listOfSavedResults[0];
        String expectedResponse='SaveResult:[apex_schema_type_info=(http://soap.sforce.com/2006/04/metadata, true, false), errors=null, errors_type_info=(errors, http://soap.sforce.com/2006/04/metadata, null, 0, -1, false), field_order_type_info=(errors, fullName, success), fullName=TestObject__c.Uninvoiced__c, fullName_type_info=(fullName, http://soap.sforce.com/2006/04/metadata, null, 1, 1, false), success=true, success_type_info=(success, http://soap.sforce.com/2006/04/metadata, null, 1, 1, false)]';
        String actualResponse=String.valueOf(result);
        System.assertEquals(null,result.errors,'Errors in Response');
        System.assertEquals('TestObject__c.Uninvoiced__c',result.fullName,'Field name does not match');
        System.assertEquals(true,result.success,'Error occured. Check error list in result');
        System.assertEquals(expectedResponse, actualResponse);
    }
    
    @isTest static void testCreateNumberfield() {
        Test.setMock(WebServiceMock.class, new CreateFormulaFieldMock());
        String testSObject='TestObject__c';
        String fieldname='Hello coder';
        CreateFormulafieldController.createNumberField(testSObject,fieldname);
        MetadataService.SaveResult result=CreateFormulafieldController.listOfSavedResults[0];
        String expectedResponse='SaveResult:[apex_schema_type_info=(http://soap.sforce.com/2006/04/metadata, true, false), errors=null, errors_type_info=(errors, http://soap.sforce.com/2006/04/metadata, null, 0, -1, false), field_order_type_info=(errors, fullName, success), fullName=TestObject__c.Hello_coder__c, fullName_type_info=(fullName, http://soap.sforce.com/2006/04/metadata, null, 1, 1, false), success=true, success_type_info=(success, http://soap.sforce.com/2006/04/metadata, null, 1, 1, false)]';
        String actualResponse=String.valueOf(result);
        System.assertEquals(null,result.errors,'Errors in Response');
        System.assertEquals('TestObject__c.Hello_coder__c',result.fullName,'Field name does not match');
        System.assertEquals(true,result.success,'Error occured. Check error list in result');
        System.assertEquals(expectedResponse, actualResponse);
    } 
    
    @isTest static void errorCheck() {
        Test.setMock(WebServiceMock.class, new CreateFormulaFieldMock());
        String testSObject='TestObject__c';
        String fieldname='Test Error';
        CreateFormulafieldController.createNumberField(testSObject,fieldname);
        MetadataService.SaveResult result=CreateFormulafieldController.listOfSavedResults[0];
        System.assertEquals(false,result.success,'Problem in Error code segment');
        System.assertEquals('TEST_ERROR',result.errors[0].extendedErrorDetails[0].extendedErrorCode,'Error not raised');
    } 
}