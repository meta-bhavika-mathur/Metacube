public with sharing class CreateFormulafieldController {
public static final String FIRST_FIELD = 'SCMC_Total_Cost__c';
    public static final String SECOND_FIELD = 'SCMC_Amount_Vouchered__c';
    public static final String FIELD_NAME = 'Uninvoiced';
    public static final String FIELD_LABEL = 'Uninvoiced';
    public static final String FIELD_API_NAME = 'Uninvoiced__c';
    public static final Integer DECIMAL_PLACES = 9;
    
    public static void createFormulaField(String objectNameParam)
    {
        try{
                Boolean isObjectAvailable = false;
                for(Schema.SObjectType sObjectType : Schema.getGlobalDescribe().values() ) {
                    String sobjName = String.valueOf(sObjectType);
                    if (sobjName.contains(objectNameParam)) {
                        isObjectAvailable = true;
                        break;
                    }    
                }    
                if(isObjectAvailable == true){
                    MetadataService.MetadataPort metadataservice = new MetadataService.MetadataPort();
                    metadataservice.SessionHeader = new MetadataService.SessionHeader_element();
                    metadataservice.SessionHeader.sessionId = UserInfo.getSessionId();
                    
                    MetadataService.CustomField customField = new MetadataService.CustomField();
                    customField.fullName = objectNameParam + '.' + FIELD_API_NAME;
                    customField.label = FIELD_LABEL;
                    customField.type_x = 'Number';
                    customField.formula = FIRST_FIELD + ' - ' + SECOND_FIELD;
                    customField.scale = DECIMAL_PLACES;
                    customField.precision = 18;
                    
                    List<MetadataService.SaveResult> results =
                        metadataservice.createMetadata(
                            new MetadataService.Metadata[] { customField });
                    handleSaveResults(results[0]);    
                }      
        }catch(Exception e){
            System.debug('Error while creating formula field!' + e.getMessage());
        }     
    }
    
     public static void createNumberField()
    {
        MetadataService.MetadataPort metadataservice = new MetadataService.MetadataPort();
        metadataservice.SessionHeader = new MetadataService.SessionHeader_element();
        metadataservice.SessionHeader.sessionId = UserInfo.getSessionId();

        MetadataService.CustomField customField = new MetadataService.CustomField();
        customField.fullName = 'Test__c.SCMC_Total_Cost__c';
        customField.label = 'SCMC Total Cost';
        customField.type_x = 'Number';
        customField.scale = 2;
        customField.precision = 18;
  
        List<MetadataService.SaveResult> results =
            metadataservice.createMetadata(
                new MetadataService.Metadata[] { customField });
        handleSaveResults(results[0]);
    }
 
    public static void handleSaveResults(MetadataService.SaveResult saveResult)
    {
        if(saveResult==null || saveResult.success)
            return;
        if(saveResult.errors!=null)
        {
            List<String> messages = new List<String>();
            messages.add(
                (saveResult.errors.size()==1 ? 'Error ' : 'Errors ') +
                    'occured processing component ' + saveResult.fullName + '.');
            for(MetadataService.Error error : saveResult.errors)
                messages.add(
                    error.message + ' (' + error.statusCode + ').' +
                    ( error.fields!=null && error.fields.size()>0 ?
                        ' Fields ' + String.join(error.fields, ',') + '.' : '' ) );
            if(messages.size()>0)
                throw new MetadataServiceException(String.join(messages, ' '));
        }
        if(!saveResult.success)
            throw new MetadataServiceException('Request failed with no specified error.');
    }
 
    public class MetadataServiceException extends Exception { }    
}