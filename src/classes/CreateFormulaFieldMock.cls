@isTest
global class CreateFormulaFieldMock implements WebServiceMock {
    public void doInvoke(Object stub,Object request,Map<String, Object> response,String endpoint,String soapAction,String requestName,String responseNS,String responseName,String responseType) {
        MetadataService.createMetadataResponse_element response_x = new MetadataService.createMetadataResponse_element();
        MetadataService.SaveResult saveresult = new MetadataService.SaveResult();
        String requests=String.valueOf(request);
        if(requests.contains('formula=SCMC_Total_Cost__c - SCMC_Amount_Vouchered__c')) {
            List< MetadataService.SaveResult> listOfResults = new List< MetadataService.SaveResult>();
            saveresult.errors=null;
            saveresult.fullName='TestObject__c.Uninvoiced__c';
            saveresult.success=true; 
            listOfResults.add(saveresult);
            response_x.result=listOfResults;
            response.put('response_x', response_x); 
        }
        else {
            List< MetadataService.SaveResult> listOfResults = new List< MetadataService.SaveResult>();
            Integer startIndex=requests.indexOf(', fullName=');
            String subrequest= requests.substring(startIndex, requests.length());
            Integer endIndex= subrequest.indexOf('__c,');
            String fieldName=requests.substring(startIndex+11,startIndex+endIndex+3);
            saveresult.errors=null;
            saveresult.fullName=fieldName;
            saveresult.success=true; 
            listOfResults.add(saveresult);
            response_x.result=listOfResults;
            response.put('response_x', response_x); 
        }
    }
}