public with sharing class CreateFormulafieldController {
    public static final String FIRST_FIELD = 'SCMC_Total_Cost__c';
    public static final String SECOND_FIELD = 'SCMC_Amount_Vouchered__c';
    public static final String FIELD_NAME = 'Uninvoiced';
    public static final String FIELD_LABEL = 'Uninvoiced';
    public static final String FIELD_API_NAME = 'Uninvoiced__c';
    public static final Integer DECIMAL_PLACES = 9;
    public static List<MetadataService.SaveResult> listOfSavedResults = new List<MetadataService.SaveResult>();
    public static void createFormulaField(String objectNameParam) {
        try {
            Boolean isObjectAvailable = false;
            for(Schema.SObjectType sObjectType : Schema.getGlobalDescribe().values() ) {
                String sobjName = String.valueOf(sObjectType);
                if (sobjName.contains(objectNameParam)) {
                    isObjectAvailable = true;
                    break;
                }  
            }    
            if(isObjectAvailable == true) {
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
                
                List<MetadataService.SaveResult> results =metadataservice.createMetadata(new MetadataService.Metadata[] { customField });
                listOfSavedResults.add(results[0]);
                handleSaveResults(results[0]);    
            }
            else {
                System.debug('SObject does not exists');
            }
        }
        catch(Exception e) {
            System.debug('Error while creating formula field!' + e.getMessage());
        }     
    }
    
    //   Generic numberfield creation
    public static void createNumberField(String objectNameParam, String fieldname) {   
        try {
            Boolean isObjectAvailable = false;
            for(Schema.SObjectType sObjectType : Schema.getGlobalDescribe().values() ) {
                String sobjName = String.valueOf(sObjectType);
                if (sobjName.contains(objectNameParam)) {
                    isObjectAvailable = true;
                    break;
                }    
            } 
            if(isObjectAvailable == true){   
                String standardFieldName;
                MetadataService.MetadataPort metadataservice = new MetadataService.MetadataPort();
                metadataservice.SessionHeader = new MetadataService.SessionHeader_element();
                metadataservice.SessionHeader.sessionId = UserInfo.getSessionId();
                // remove leading and trailing white spaces
                fieldname=fieldname.trim();
                // replace spaces with '_'
                standardFieldName=fieldname.replaceAll('\\s+','_');
                MetadataService.CustomField customField = new MetadataService.CustomField();
                customField.fullName = objectNameParam +'.'+ standardFieldName + '__c';
                customField.label = fieldname;
                customField.type_x = 'Number';
                customField.scale = 2;
                customField.precision = 18;
                
                List<MetadataService.SaveResult> results =
                    metadataservice.createMetadata(
                        new MetadataService.Metadata[] { customField });
                 listOfSavedResults.add(results[0]);
                handleSaveResults(results[0]);
            }
            else {
                System.debug('SObject does not exists');
            }
        }
        catch(Exception e){
            System.debug('Error while creating number field!' + e.getMessage());
        } 
    }    
    
    public static void handleSaveResults(MetadataService.SaveResult saveResult) {
        if(saveResult==null || saveResult.success)
            return;
        if(saveResult.errors!=null) {
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