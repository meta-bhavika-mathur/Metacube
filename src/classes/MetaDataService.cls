public with sharing class MetaDataService {
    public static String SOAP_M_URI = 'http://soap.sforce.com/2006/04/metadata';
    
    public class SessionHeader_element {
        public String sessionId;
        private String[] sessionId_type_info = new String[]{'sessionId',SOAP_M_URI,null,'1','1','false'};
            private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
                private String[] field_order_type_info = new String[]{'sessionId'};
                    }
    
    public class SaveResult {
        public MetadataService.Error[] errors;
        public String fullName;
        public Boolean success;
        private String[] errors_type_info = new String[]{'errors',SOAP_M_URI,null,'0','-1','false'};
            private String[] fullName_type_info = new String[]{'fullName',SOAP_M_URI,null,'1','1','false'};
                private String[] success_type_info = new String[]{'success',SOAP_M_URI,null,'1','1','false'};
                    private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
                        private String[] field_order_type_info = new String[]{'errors','fullName','success'};
                            }
    
    public class Error {
        public MetadataService.ExtendedErrorDetails[] extendedErrorDetails;
        public String[] fields;
        public String message;
        public String statusCode;
        private String[] extendedErrorDetails_type_info = new String[]{'extendedErrorDetails',SOAP_M_URI,null,'0','-1','false'};
            private String[] fields_type_info = new String[]{'fields',SOAP_M_URI,null,'0','-1','false'};
                private String[] message_type_info = new String[]{'message',SOAP_M_URI,null,'1','1','false'};
                    private String[] statusCode_type_info = new String[]{'statusCode',SOAP_M_URI,null,'1','1','false'};
                        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
                            private String[] field_order_type_info = new String[]{'extendedErrorDetails','fields','message','statusCode'};
                                }
    
    public class ExtendedErrorDetails {
        public String extendedErrorCode;
        private String[] extendedErrorCode_type_info = new String[]{'extendedErrorCode',SOAP_M_URI,null,'1','1','false'};
            private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
                private String[] field_order_type_info = new String[]{'extendedErrorCode'};
                    }
    
    public class createMetadata_element {
        public MetadataService.Metadata[] metadata;
        private String[] metadata_type_info = new String[]{'metadata',SOAP_M_URI,null,'0','-1','false'};
            private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
                private String[] field_order_type_info = new String[]{'metadata'};
                    }
    
    public class createMetadataResponse_element {
        public MetadataService.SaveResult[] result;
        private String[] result_type_info = new String[]{'result',SOAP_M_URI,null,'0','-1','false'};
            private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
                private String[] field_order_type_info = new String[]{'result'};
                    }
    
    public virtual class Metadata {
        public String fullName;
    }
    
    public class CustomField extends Metadata {
        public String type = 'CustomField';
        public String fullName;
        public String formula;
        public String label;
        public Integer precision;
        public Integer scale;
        public String type_x;
        private String[] label_type_info = new String[]{'label',SOAP_M_URI,null,'0','1','false'};
            private String[] formula_type_info = new String[]{'formula',SOAP_M_URI,null,'0','1','false'};
                private String[] fullName_type_info = new String[]{'fullName',SOAP_M_URI,null,'0','1','false'};    
                    private String[] precision_type_info = new String[]{'precision',SOAP_M_URI,null,'0','1','false'};
                        private String[] scale_type_info = new String[]{'scale',SOAP_M_URI,null,'0','1','false'};
                            private String[] type_x_type_info = new String[]{'type',SOAP_M_URI,null,'0','1','false'}; 
                                private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
                                    private String[] type_att_info = new String[]{'xsi:type'};
                                        private String[] field_order_type_info = new String[]{'fullName','formula','label','precision','scale','type_x'};
                                            }  
    
    
    public class MetadataPort {
        public String endpoint_x = URL.getSalesforceBaseUrl().toExternalForm() + '/services/Soap/m/42.0';
        public MetadataService.SessionHeader_element SessionHeader;
        private String SessionHeader_hns = 'SessionHeader=http://soap.sforce.com/2006/04/metadata';
        private String[] ns_map_type_info = new String[]{SOAP_M_URI, 'MetadataService'};
            public MetadataService.SaveResult[] createMetadata(MetadataService.Metadata[] metadata) {
                MetadataService.createMetadata_element request_x = new MetadataService.createMetadata_element();
                request_x.metadata = metadata;
                MetadataService.createMetadataResponse_element response_x;
                Map<String, MetadataService.createMetadataResponse_element> response_map_x = new Map<String, MetadataService.createMetadataResponse_element>();
                response_map_x.put('response_x', response_x);
                WebServiceCallout.invoke(
                    this,
                    request_x,
                    response_map_x,
                    new String[]{endpoint_x,
                        '',
                        SOAP_M_URI,
                        'createMetadata',
                        SOAP_M_URI,
                        'createMetadataResponse',
                        'MetadataService.createMetadataResponse_element'}
                );
                response_x = response_map_x.get('response_x');
                return response_x.result;
            }  
    }
}