public with sharing class MetadaAPIDemoController {
public void createObject(){      
        MetadataService.MetadataPort metadataservice = new MetadataService.MetadataPort();
        metadataservice.SessionHeader = new MetadataService.SessionHeader_element();
        metadataservice.SessionHeader.sessionId = UserInfo.getSessionId();
        
        MetadataService.CustomObject customObject = new MetadataService.CustomObject();
        customObject.fullName = 'Test__c';
        customObject.label = 'Test';
        customObject.pluralLabel = 'Tests';        
        customObject.nameField = new MetadataService.CustomField();
        customObject.nameField.type_x = 'Text';
        customObject.nameField.label = 'Test Record';
        customObject.deploymentStatus = 'Deployed';
        customObject.sharingModel = 'ReadWrite';
        List<MetadataService.SaveResult> results = metadataservice.createMetadata( new MetadataService.Metadata[] { customObject });
        handleSaveResults(results[0]);
    }
 
    // To create custom text field
    public void createField()
    {
        MetadataService.MetadataPort metadataservice = new MetadataService.MetadataPort();
        metadataservice.SessionHeader = new MetadataService.SessionHeader_element();
        metadataservice.SessionHeader.sessionId = UserInfo.getSessionId();

        MetadataService.CustomField customField = new MetadataService.CustomField();
        customField.fullName = 'Test__c.TestField__c';
        customField.label = 'Test Field';
        customField.type_x = 'Text';
        customField.length = 42;
        List<MetadataService.SaveResult> results =
            metadataservice.createMetadata(
                new MetadataService.Metadata[] { customField });
        handleSaveResults(results[0]);
    }
    
    // To create number field
    public void createNumberField()
    {
        MetadataService.MetadataPort metadataservice = new MetadataService.MetadataPort();
        metadataservice.SessionHeader = new MetadataService.SessionHeader_element();
        metadataservice.SessionHeader.sessionId = UserInfo.getSessionId();

        MetadataService.CustomField customField = new MetadataService.CustomField();
        customField.fullName = 'Test__c.Second_Number__c';
        customField.label = 'Second Number';
        customField.type_x = 'Number';
        customField.scale = 2;
        customField.precision = 18;
  
        List<MetadataService.SaveResult> results =
            metadataservice.createMetadata(
                new MetadataService.Metadata[] { customField });
        handleSaveResults(results[0]);
    }
    
    // To create formula field
    public void createFormulaField()
    {
        MetadataService.MetadataPort metadataservice = new MetadataService.MetadataPort();
        metadataservice.SessionHeader = new MetadataService.SessionHeader_element();
        metadataservice.SessionHeader.sessionId = UserInfo.getSessionId();
        
        MetadataService.CustomField customField = new MetadataService.CustomField();
        customField.fullName = 'Test__c.Test_Formula_Field__c';
        customField.label = 'Test Formula Field';
        customField.type_x = 'Number';
        customField.formula = 'First_Number__c - Second_Number__c';
        customField.scale = 2;
        customField.precision = 18;
        
        List<MetadataService.SaveResult> results =
            metadataservice.createMetadata(
                new MetadataService.Metadata[] { customField });
        handleSaveResults(results[0]);
    }

    public void handleSaveResults(MetadataService.SaveResult saveResult)
    {
        // Nothing to see?
        if(saveResult==null || saveResult.success)
            return;
        // Construct error message and throw an exception
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
                throw new MetadataServiceExamplesException(String.join(messages, ' '));
        }
        if(!saveResult.success)
            throw new MetadataServiceExamplesException('Request failed with no specified error.');
    }
 
    public class MetadataServiceExamplesException extends Exception { }    
}