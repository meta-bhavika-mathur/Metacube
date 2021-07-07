public class ReportsGenerationUtility {
    private static String folderId;	 
    private static String documentLink;
    public static Map<String, List<c2g__codaPeriod__c>> periodByYearMap;
    public static List<String> yearList;
	public static List<String> monthList;
    public static List<String> periodList;
	public static List<SelectOption> yearOptions;
	public static List<SelectOption> monthOptions;
    public static List<SelectOption> periodOptions;
    public static Date startDate;
	public static Date endDate;
    public static String AUDIT_FILE_COMPANY_NAME;
    public static String periodYear;
    public static String periodMonth;
    public static String selectedYear;
    public static String selectedMonth;
    
    public static List<String> listOfPeriods;   
    public static List<String> periodMonthList;
    public static List<String> periodYearList; 
    
    public static Set<String> setOfSalesIds = new Set<String>();
    public static List<SelectOption> companyOptions;
    public static List<String> listOfSelectedCompanies;
    
    // To get companies on Transaction
    public static void setCompaniesForCountry(String countryName){    
       companyOptions = new List<SelectOption>();
       List<c2g__codaCompany__c> listOfCompanies = [ SELECT 
       													Id, Name 
       												 FROM c2g__codaCompany__c 
       												 WHERE c2g__Country__c = :countryName
       												 AND c2g__Country__c != null
       											   ];
       System.debug('List of companies in Reports Utilty:' + listOfCompanies);
       
       if(listOfCompanies != null && !listOfCompanies.isEmpty()){
       	   listOfSelectedCompanies = new List<String>();
          
           System.debug('Default listOfSelectedCompanies:' + listOfSelectedCompanies);
	       for(c2g__codaCompany__c cmpny : listOfCompanies){
	       		String companyId = cmpny.Id;
	       		String companyName = cmpny.Name;
				companyOptions.add(new SelectOption(companyId, companyName));
				listOfSelectedCompanies.add(companyId);
			}
       }     
    }
    
    public static String generateDocAndAddToFolder(String fileName, String xmlFileString){        
        folderId = [
            			SELECT	Id
                        FROM	Folder
                        WHERE	Name = 'FinancialForceDocuments'
                        LIMIT	1
                   ].Id;
        String docId = createDoc(fileName + ' ' + String.valueOf(System.now()), xmlFileString, folderId);
        documentLink = '/servlet/servlet.FileDownload?file=' + docId;
        return documentLink;
    }
    
    public static String createDoc(String docName, String docBody, String folderId) {
		Document doc = new Document();
		doc.FolderId = folderId;
		doc.Body = Blob.valueOf(docBody);
		doc.Name = docName;
		doc.ContentType = 'text/xml';
		doc.Type = 'xml';
		insert doc;     
        return doc.Id;
	}
    
    public static List<SObject> getSFDCRecords(String objName, Set<String> fieldNameSet, String whereCondition){
		
		if(!fieldNameSet.isEmpty()){
			String query =	'SELECT ' + String.join(new List<String>(fieldNameSet), ',') + 
							' FROM ' + objName +
							(String.isNotBlank(whereCondition) ? ' WHERE ' + whereCondition : '');
			List<SObject> recordsList = new List<SObject>();
			recordsList = Database.query(query);
			return recordsList;
		}else{
			return null;
		}
	}
    
    public static List<sObject> getSFDCRecordsWithSubQuery(String objName, Set<String> fieldNameSet, String whereCondition,
                                Boolean hasSubquery, Map<String, Set<String>> mapOfInnerQueryObjAndFields){
             System.debug('listOfSelectedCompanies in query:' + listOfSelectedCompanies);
			 String query = '';
             List<SObject> recordsList;
             Set<String> setOfFields;
             
             try{
                     if(hasSubquery != true){
                        if(!fieldNameSet.isEmpty()){   
                             query = 'SELECT ' + String.join(new List<String>(fieldNameSet), ',') + 
                                    ' FROM ' + objName + (String.isNotBlank(whereCondition) ? ' WHERE ' + whereCondition : '');
                         }
                     }else{
                         query = 'SELECT ' + String.join(new List<String>(fieldNameSet), ',');   
                         
                         if(mapOfInnerQueryObjAndFields != null && !mapOfInnerQueryObjAndFields.isEmpty()){
                             for(String innerQueryObjName : mapOfInnerQueryObjAndFields.keySet()){
                                 setOfFields = mapOfInnerQueryObjAndFields.get(innerQueryObjName);
                                 
                                 for(String innerquerfield : setOfFields){
                                     System.debug('Inner query field:' + innerquerfield);
                                 }
                                 if(setOfFields != null && !setOfFields.isEmpty()){
                                   query += ', (SELECT ' + String.join(new List<String>(setOfFields), ',') + 
                                            ' FROM ' + innerQueryObjName + ')';  
                                 }                         	
                             }
                         }
                         query += ' FROM ' + objName + (String.isNotBlank(whereCondition) ? ' WHERE ' + whereCondition : '');           
                     } 
                     if(query != null && query != '')                 
                        recordsList = Database.query(query);
                 	System.debug('Query:' + query);
           	}catch(Exception e){
                 System.debug('Exception in query execution:' + e.getMessage() + e.getStackTraceString());    
            }             
            return recordsList;                    
	}

	public static String getValue (SObject obj, String field) {
		String value;
		if (String.isNotBlank(field)) {
			if (field.contains('.')) {
				SObject sobj;
				for (Integer i = 0; i < field.split('\\.').size() - 1; i++) {
					if (i > 0 ? sobj.getSObject(field.split('\\.')[i]) != null : obj.getSObject(field.split('\\.')[i]) != null) {
						sobj = (i > 0 ? sobj.getSObject(field.split('\\.')[i]): obj.getSObject(field.split('\\.')[i]));
					} else {
						sobj = null;
						break;
					}
				}
				value = sobj != null ? String.valueOf(sobj.get(field.split('\\.')[field.split('\\.').size() - 1])) : '';
			} else {
				value = String.valueOf(obj.get(field));
			}
				
		} else {
			value = '';
		}
		if(value != null && value.contains('&')){
			value = value.replaceAll('&', '&amp;');
		}
		return value;
	}
    
    public static void getPeriods(){
		List<c2g__codaPeriod__c> periodsList = new List<c2g__codaPeriod__c>();
		periodsList =	[
			SELECT	
					Id,
					c2g__YearName__r.Name,
					c2g__PeriodNumber__c,
					c2g__OwnerCompany__r.Name,
					c2g__StartDate__c,
					c2g__EndDate__c
			FROM	c2g__codaPeriod__c
			WHERE	c2g__Description__c = 'Trading Period'
		];

		periodByYearMap = new Map<String, List<c2g__codaPeriod__c>>();
		for(c2g__codaPeriod__c item : periodsList){
			if(periodByYearMap.get(item.c2g__YearName__r.Name) == null){
				periodByYearMap.put(item.c2g__YearName__r.Name, new List<c2g__codaPeriod__c>{item});
			}else{
				periodByYearMap.get(item.c2g__YearName__r.Name).add(item);
			}
		}

		yearList = new List<String>(periodByYearMap.keySet());
		monthList = new List<String>{'1','2','3','4','5','6','7','8','9','10','11','12'};
		
        periodList = new List<String>{'000', '001','002','003','004','005','006','007','008','009','010','011','012', '100', '101'};
		
        yearOptions = new List<SelectOption>();
		monthOptions = new List<SelectOption>();
		periodOptions  = new List<SelectOption>();
		
        for(String item : yearList){
			yearOptions.add(new SelectOption(item, item));
		}

		for(String item : monthList){
			monthOptions.add(new SelectOption(item, item));
		}
        
        for(String item : periodList){
			periodOptions.add(new SelectOption(item, item));
		}
	}
}