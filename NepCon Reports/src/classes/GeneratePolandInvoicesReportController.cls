public with sharing class GeneratePolandInvoicesReportController {
    
    	private List<Poland_Invoices_File_Mapping__mdt> mappingList;
	private Map<String, List<Poland_Invoices_File_Mapping__mdt>> mappingRecordByLabelMap;
	private Map<String, Poland_Invoices_File_Mapping__mdt> mappingRecordByDeveloperNameMap;
	private String xmlFileString;
	private String folderId;
    
	public String docLink{get; set;}    
	public String fileType{get; set;}
    	public String selectedYear{get; set;}
	public String selectedMonth{get; set;}    
    	public List<SelectOption> yearOptions{get; set;}
	public List<SelectOption> periodOptions{get; set;}
	public List<SelectOption> fileTypeOptions{get; set;}
	
    	final String SALES_FA_REPORT = 'JPK_FA_SaleInv';
    	final String VAT_REPORT = 'JPK_VAT';
    	final String KR_ALL_ENTRIES = 'JPK_KR_AllEntries';
    	final String SALES_FA_REPORT_NAME = 'JPK_FA_SaleInv Report';
    	final String VAT_REPORT_NAME = 'JPK_VAT Report';
    	final String ALL_ENTRIES_REPORT_NAME = 'PolUnifiedExportksiegi_JPK_KR_AllEntries';
    	final String CUSTOM_EXCEPTION_MESSAGE = 'Please select a report type!';
    
    	public String AUDIT_FILE_COMPANY_NAME = '';
    
    	private Map<String, glaForAllEntriesWrapper> mapOfGlaInfo;
    
	private List<c2g__codaInvoice__c> listOfSalesInvoices;
	private List<c2g__codaInvoiceLineItem__c> listOfSalesLineItems;
    	private List<c2g__codaTransaction__c> listOfTransactions;
    	private List<c2g__codaCreditNote__c> listOfCreditNotes;
    	private List<c2g__codaJournal__c> listOfJournals;
    	private List<c2g__codaGeneralLedgerAccount__c> listOfGLAs;
    	private List<c2g__codaPurchaseInvoice__c> listOfPurchaseInvoicesForVATReport;
    	private List<c2g__codaCreditNoteLineItem__c> listOfCreditNotesLines = new List<c2g__codaCreditNoteLineItem__c>();
    	private List<c2g__codaPurchaseInvoiceLineItem__c> listOfPurchaseLinesForVATReport = new List<c2g__codaPurchaseInvoiceLineItem__c>();
   
   	private Map<String, String> mapOfOpeningBal;
	private Map<String, String> mapOfClosingBal;
	private Map<String, String> mapOfDebitsForReportingPeriod;
	private Map<String, String> mapOfCreditsForReportingPeriod;
	private Map<String, String> mapOfDbFromBeginingToEnd;
	private Map<String, String> mapOfCrFromBeginingToEnd;
//	private Map<String, String> mapOfDebitBal;
//	private Map<String, String> mapOfCreditBal;

	public List<String> listOfPeriods;
    	public List<String> listOfPeriodMonths;
    	public List<String> periodYearList{get; set;}
	
	public GeneratePolandInvoicesReportController(){
        try{
            getPeriods();
            initFileTypes();
            getFieldMapping();
            sortFieldMapping(mappingList); 
            AUDIT_FILE_COMPANY_NAME = mappingRecordByDeveloperNameMap.get('AuditFileCompany0').Default_Value__c;                      
        }catch(Exception e){
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, e.getMessage() + ' ' + e.getStackTraceString()));
        }
	}
	
	public void initFileTypes(){
		fileTypeOptions = new List<SelectOption>();
		fileTypeOptions.add(new SelectOption('report1', VAT_REPORT));
		fileTypeOptions.add(new SelectOption('report2', SALES_FA_REPORT));
        fileTypeOptions.add(new SelectOption('report3', KR_ALL_ENTRIES));
	}
	
    public void getPeriods(){
		ReportsGenerationUtility.getPeriods();
        yearOptions = ReportsGenerationUtility.yearOptions;
        periodOptions = ReportsGenerationUtility.periodOptions;
	}
    
	public void createXml(){
        try{	
            	if(String.isBlank(selectedYear) || String.isBlank(selectedMonth)){
                		throw new CustomException('Choose Year and Month');
                }else{
                   	if(fileType == 'report1'){
                        getSalesInvoicesCommonMethod();
                        getPurchaseInvForVATReport();
                        createInvoicesVATReport();
					}else if(fileType == 'report2'){
                        getSalesInvoicesCommonMethod();
                        createSalesInvoicesReport();
					}else if(fileType == 'report3'){
                        getSalesInvoicesCommonMethod();
                        getDataForAllEntriesReport();
                        createAllEntriesReport();
					}else{
						throw new CustomException(CUSTOM_EXCEPTION_MESSAGE);
					}   
                }		    	         
        }catch(Exception e){
            	ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, e.getMessage() + ' ' + e.getStackTraceString()));
        }
    }
    
    //To generate JPK_KR_AllEntries Report
    private void createAllEntriesReport(){
    	try{		        	
            	String bodyOfJPKTag = getKR_JPKTagBody();	            	
            	xmlFileString = '';
				xmlFileString += '<?xml version="1.0" encoding="UTF-8"?>';
            	xmlFileString += addNodeWithAttributes(mappingRecordByDeveloperNameMap.get('KR_JPK0').Namespace__c + ':' + 
            					 mappingRecordByDeveloperNameMap.get('KR_JPK0').Tag_Name__c,
                                 bodyOfJPKTag, 
                                 getMapOfAttributesAndValByLabel(mappingRecordByDeveloperNameMap.get('KR_JPK0').MasterLabel, null));
                docLink = ReportsGenerationUtility.generateDocAndAddToFolder(ALL_ENTRIES_REPORT_NAME, xmlFileString);                                
		}catch(Exception e){
			ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, e.getMessage() + ' ' + e.getStackTraceString()));
		}
    }
    
    private String getKR_JPKTagBody(){
        String str = '';
		str += getKR_Report_Naglowek();
		str += getPodmiot1();
		str += getKR_ReportZOiS(); 	
		str += getKR_ReportDziennik();
        str += getKR_ReportDziennikCtrl();
		str += getKR_ReportKontoZapis();
		str += getKR_ReportKontoZapisCtrl();
        return str;
    }
    
    private String getKR_Report_Naglowek(){
       String naglowekStr = '';  	
    	try{
    		 naglowekStr += addNode(mappingRecordByDeveloperNameMap.get('KR_JPK2').Namespace__c + ':' +
                            	mappingRecordByDeveloperNameMap.get('KR_JPK2').Tag_Name__c, 
    		 						addNodeWithAttributes(mappingRecordByDeveloperNameMap.get('KR_JPK2').Namespace__c + ':' + 
                                    mappingRecordByDeveloperNameMap.get('KR_KodFormularza0').Tag_Name__c, 
                                    mappingRecordByDeveloperNameMap.get('KR_KodFormularza0').Default_Value__c, 
                                    getMapOfAttributesAndValByLabel(mappingRecordByDeveloperNameMap.get('KR_KodFormularza0').MasterLabel, null)) +				
                                    addNode(mappingRecordByDeveloperNameMap.get('Naglowek2').Namespace__c + ':' + mappingRecordByDeveloperNameMap.get('Naglowek2').Tag_Name__c, 
                                    mappingRecordByDeveloperNameMap.get('Naglowek2').Default_Value__c) + 
                                    addNode(mappingRecordByDeveloperNameMap.get('Naglowek3').Namespace__c + ':' + mappingRecordByDeveloperNameMap.get('Naglowek3').Tag_Name__c, 
                                    mappingRecordByDeveloperNameMap.get('Naglowek3').Default_Value__c) + 
                                    addNode(mappingRecordByDeveloperNameMap.get('Naglowek4').Namespace__c + ':' + mappingRecordByDeveloperNameMap.get('Naglowek4').Tag_Name__c, 
                                    String.valueOf(System.now())) +
                                    addNode(mappingRecordByDeveloperNameMap.get('Naglowek7').Namespace__c + ':' + mappingRecordByDeveloperNameMap.get('Naglowek7').Tag_Name__c, 
                                    mappingRecordByDeveloperNameMap.get('Naglowek7').Default_Value__c) +
                                    addNode(mappingRecordByDeveloperNameMap.get('Naglowek8').Namespace__c + ':' + mappingRecordByDeveloperNameMap.get('Naglowek8').Tag_Name__c, 
                                    mappingRecordByDeveloperNameMap.get('Naglowek8').Default_Value__c)  	 					 	
    		 				); 		 
    	}catch(Exception e){
    		ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, e.getMessage() + ' ' + e.getStackTraceString()));
    	}   	
    	return naglowekStr;  
    }
    
    private string getKR_ReportZOiS(){
        String zoisStr = '';
    	String zoisStrBody = ' ';

        try{
        	if(mapOfGlaInfo != null && !mapOfGlaInfo.isEmpty()){
        		for(String glaRepCode : mapOfGlaInfo.keySet()){
        			zoisStrBody = getZoisStrBody(glaRepCode); 
	                zoisStr += addNodeWithAttributes(mappingRecordByDeveloperNameMap.get('KR_ZOiS0').Namespace__c + ':' +
	                           mappingRecordByDeveloperNameMap.get('KR_ZOiS0').Tag_Name__c, zoisStrBody,
	                           getMapOfAttributesAndValByLabel(mappingRecordByDeveloperNameMap.get('KR_ZOiS0').MasterLabel, null)); 
        		}  		
        	}            	            
        }catch(Exception e){
    		ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, e.getMessage() + ' ' + e.getStackTraceString()));
    	}   	
   		return zoisStr;
    }
    
    private String getZoisStrBody(String glaRepCode){
    	String zoisBodyStr = '';
    	String kodKonta; 
    	String opisKonta, typKonta, kodZespolu, opisZespolu, kodKategorii, opisKategorii; 
    	glaForAllEntriesWrapper gla = mapOfGlaInfo.get(glaRepCode);
    	try{
    		zoisBodyStr = addNode(mappingRecordByDeveloperNameMap.get('KR_ZOiS1').Namespace__c + ':' +
							mappingRecordByDeveloperNameMap.get('KR_ZOiS1').Tag_Name__c, gla.kodKonta != null ? gla.kodKonta : '') +
							addNode(mappingRecordByDeveloperNameMap.get('KR_ZOiS2').Namespace__c + ':' +
							mappingRecordByDeveloperNameMap.get('KR_ZOiS2').Tag_Name__c, gla.opisKonta != null ? gla.opisKonta : '') +
							addNode(mappingRecordByDeveloperNameMap.get('KR_ZOiS3').Namespace__c + ':' +
							mappingRecordByDeveloperNameMap.get('KR_ZOiS3').Tag_Name__c, gla.typKonta != null ? gla.typKonta : '') +
							addNode(mappingRecordByDeveloperNameMap.get('KR_ZOiS4').Namespace__c + ':' +
							mappingRecordByDeveloperNameMap.get('KR_ZOiS4').Tag_Name__c, gla.kodZespolu != null ? gla.kodZespolu : '') +
							addNode(mappingRecordByDeveloperNameMap.get('KR_ZOiS5').Namespace__c + ':' +
							mappingRecordByDeveloperNameMap.get('KR_ZOiS5').Tag_Name__c, gla.opisZespolu != null ? gla.opisZespolu : '') +
							addNode(mappingRecordByDeveloperNameMap.get('KR_ZOiS6').Namespace__c + ':' +
							mappingRecordByDeveloperNameMap.get('KR_ZOiS6').Tag_Name__c, gla.kodKategorii != null ? gla.kodKategorii : '') +
							addNode(mappingRecordByDeveloperNameMap.get('KR_ZOiS7').Namespace__c + ':' +
							mappingRecordByDeveloperNameMap.get('KR_ZOiS7').Tag_Name__c, gla.opisKategorii != null ? gla.opisKategorii : '') +
							
							addNode(mappingRecordByDeveloperNameMap.get('KR_ZOiS8').Namespace__c + ':' +
							mappingRecordByDeveloperNameMap.get('KR_ZOiS8').Tag_Name__c, mapOfOpeningBal.get(glaRepCode) != null ? mapOfOpeningBal.get(glaRepCode) : '') +
							addNode(mappingRecordByDeveloperNameMap.get('KR_ZOiS9').Namespace__c + ':' +
							mappingRecordByDeveloperNameMap.get('KR_ZOiS9').Tag_Name__c, mapOfClosingBal.get(glaRepCode) != null ? mapOfClosingBal.get(glaRepCode) : '') +
							addNode(mappingRecordByDeveloperNameMap.get('KR_ZOiS10').Namespace__c + ':' +
							mappingRecordByDeveloperNameMap.get('KR_ZOiS10').Tag_Name__c, mapOfDebitsForReportingPeriod.get(glaRepCode) != null ? mapOfDebitsForReportingPeriod.get(glaRepCode) : '') +
							addNode(mappingRecordByDeveloperNameMap.get('KR_ZOiS11').Namespace__c + ':' +
							mappingRecordByDeveloperNameMap.get('KR_ZOiS11').Tag_Name__c, mapOfCreditsForReportingPeriod.get(glaRepCode) != null ? mapOfCreditsForReportingPeriod.get(glaRepCode) : '') +
							addNode(mappingRecordByDeveloperNameMap.get('KR_ZOiS12').Namespace__c + ':' +
                            mappingRecordByDeveloperNameMap.get('KR_ZOiS12').Tag_Name__c, mapOfDbFromBeginingToEnd.get(glaRepCode) != null ? mapOfDbFromBeginingToEnd.get(glaRepCode) : '') + 
                            addNode(mappingRecordByDeveloperNameMap.get('KR_ZOiS13').Namespace__c + ':' +
                            mappingRecordByDeveloperNameMap.get('KR_ZOiS13').Tag_Name__c, mapOfCrFromBeginingToEnd.get(glaRepCode) != null ? mapOfCrFromBeginingToEnd.get(glaRepCode) : '') +
                            addNode(mappingRecordByDeveloperNameMap.get('KR_ZOiS14').Namespace__c + ':' +
                            mappingRecordByDeveloperNameMap.get('KR_ZOiS14').Tag_Name__c, mapOfDebitsForReportingPeriod.get(glaRepCode) != null ? mapOfDebitsForReportingPeriod.get(glaRepCode) : '') +
                            addNode(mappingRecordByDeveloperNameMap.get('KR_ZOiS15').Namespace__c + ':' +
                            mappingRecordByDeveloperNameMap.get('KR_ZOiS15').Tag_Name__c, mapOfCreditsForReportingPeriod.get(glaRepCode) != null ? mapOfCreditsForReportingPeriod.get(glaRepCode) : '');  							
    	}catch(Exception e){
    		ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, e.getMessage() + ' ' + e.getStackTraceString()));
    	}
    	return zoisBodyStr;
    }
    
    private String getKR_ReportDziennik(){
    	String dziennikStr = '';
        String dziennikStrBody = '';   
        Map<String, String> mapOfAttributesAndVal = getMapOfAttributesAndValByLabel(mappingRecordByDeveloperNameMap.get('KR_Dziennik0').MasterLabel, null);
       
        try{	
            if(listOfJournals != null){
                for(c2g__codaJournal__c jrnl : listOfJournals){
                    dziennikStrBody = getDziennikStrBody(jrnl); 
                    dziennikStr += addNodeWithAttributes(mappingRecordByDeveloperNameMap.get('KR_Dziennik0').Namespace__c + ':' +
                                         mappingRecordByDeveloperNameMap.get('KR_Dziennik0').Tag_Name__c, dziennikStrBody,
                                         mapOfAttributesAndVal); 
    			}
            }               	
        }catch(Exception e){
    		ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, e.getMessage() + ' ' + e.getStackTraceString()));
    	}    	
   		return dziennikStr;
    }
    
    private String getDziennikStrBody(c2g__codaJournal__c jrnl){
        String dziennikStr = '';
    	String attributeStr;
    	String fieldName = '';
    	String fieldVal = '';    	
        try{
            for(Integer i=1; i<=11; i++){
                attributeStr = 'KR_Dziennik' + i;
                fieldName = mappingRecordByDeveloperNameMap.get(attributeStr).SFDC_Field_Name__c;
                fieldVal = (fieldName != null) ? ReportsGenerationUtility.getValue(jrnl, fieldName) : null;
                dziennikStr += addNode(mappingRecordByDeveloperNameMap.get(attributeStr).Namespace__c + ':' +
                                       mappingRecordByDeveloperNameMap.get(attributeStr).Tag_Name__c, 
                                       fieldVal != null ? fieldVal : '');
    		}            
        }catch(Exception e){
    		ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, e.getMessage() + ' ' + e.getStackTraceString()));
    	}     	
    	return dziennikStr;
    }
    
    private String getKR_ReportDziennikCtrl(){
        String dziennikCtrl = '';
        Integer liczbaWierszyDziennika = 0;
        Decimal sumaKwotOperacji = 0.0;
    	
    	if(listOfJournals != null){
            liczbaWierszyDziennika = listOfJournals.size();
        	for(c2g__codaJournal__c jrnl : listOfJournals){
                sumaKwotOperacji += ReportsGenerationUtility.getValue(jrnl, mappingRecordByDeveloperNameMap.get('KR_Dziennik11').SFDC_Field_Name__c) != '' ?
                    				Decimal.valueOf(ReportsGenerationUtility.getValue(jrnl, mappingRecordByDeveloperNameMap.get('KR_Dziennik11').SFDC_Field_Name__c)) : 0.0;
    		}
        }               
        dziennikCtrl = addNode(mappingRecordByDeveloperNameMap.get('KR_JPK6').Namespace__c + ':' + 
                               mappingRecordByDeveloperNameMap.get('KR_JPK6').Tag_Name__c, 
                                   addNode(mappingRecordByDeveloperNameMap.get('KR_DziennikCtrl1').Namespace__c + ':' + 
                                   mappingRecordByDeveloperNameMap.get('KR_DziennikCtrl1').Tag_Name__c, String.valueOf(liczbaWierszyDziennika)) + 
                                   addNode(mappingRecordByDeveloperNameMap.get('KR_DziennikCtrl2').Namespace__c + ':' + 
                                   mappingRecordByDeveloperNameMap.get('KR_DziennikCtrl2').Tag_Name__c, String.valueOf(sumaKwotOperacji))
    				  		  );
        return dziennikCtrl;    	
    }
    
    private String getKR_ReportKontoZapis(){
        String kontoZapis = '';
        String kontoZapisBody = '';
        
        if(listOfTransactions != null){
        	for(c2g__codaTransaction__c trn : listOfTransactions){
                if(trn.c2g__TransactionLineItems__r != null){
                  for(c2g__codaTransactionLineItem__c trnLi : trn.c2g__TransactionLineItems__r){
	    			kontoZapisBody = getKontosZapisBody(trnLi); 
		    		kontoZapis += addNodeWithAttributes(mappingRecordByDeveloperNameMap.get('KR_KontoZapis0').Namespace__c + ':' +
		    				   			 mappingRecordByDeveloperNameMap.get('KR_KontoZapis0').Tag_Name__c, kontoZapisBody,
		    				   			 getMapOfAttributesAndValByLabel(mappingRecordByDeveloperNameMap.get('KR_KontoZapis0').MasterLabel, null)); 
	    			}   
                }       		   		
    		}	
        }   		
        return kontoZapis;
    }
    
    private string getKontosZapisBody(c2g__codaTransactionLineItem__c trnLi){
        String kontosZapisBody = '';
        String attributeStr = '';
        String fieldValue = '';
        final String DOC_CURR = 'SLOTY';
        
        for(Integer i=1; i<=7; i++){
    		attributeStr = 'KR_KontoZapis' + i;
    		fieldValue = ReportsGenerationUtility.getValue(trnLi, mappingRecordByDeveloperNameMap.get(attributeStr).SFDC_Field_Name__c);
    		kontosZapisBody += addNode(mappingRecordByDeveloperNameMap.get(attributeStr).Namespace__c + ':' +
    				   			 	   mappingRecordByDeveloperNameMap.get(attributeStr).Tag_Name__c, 
    				   			 	   fieldValue != null ? fieldValue : '');  		
    	}
    	
    	String documentCurrency = ReportsGenerationUtility.getValue(trnLi, mappingRecordByDeveloperNameMap.get('KR_KontoZapis9').SFDC_Field_Name__c) != null ?
    								ReportsGenerationUtility.getValue(trnLi, mappingRecordByDeveloperNameMap.get('KR_KontoZapis9').SFDC_Field_Name__c) : '';
    	String documentValue = '';
    	String docCurr = '';
    	if(documentCurrency != '' && documentCurrency != DOC_CURR){
    		documentValue = String.valueOf(ReportsGenerationUtility.getValue(trnLi, mappingRecordByDeveloperNameMap.get('KR_KontoZapis8').SFDC_Field_Name__c));
    		docCurr = documentCurrency;
    	}  	
    	kontosZapisBody += addNode(mappingRecordByDeveloperNameMap.get('KR_KontoZapis8').Namespace__c + ':' + 
    						mappingRecordByDeveloperNameMap.get('KR_KontoZapis8').Tag_Name__c, documentValue) +
    						addNode(mappingRecordByDeveloperNameMap.get('KR_KontoZapis9').Namespace__c + ':' + 
    						mappingRecordByDeveloperNameMap.get('KR_KontoZapis9').Tag_Name__c, docCurr) +
    						addNode(mappingRecordByDeveloperNameMap.get('KR_KontoZapis10').Namespace__c + ':' + 
    						mappingRecordByDeveloperNameMap.get('KR_KontoZapis10').Tag_Name__c, fieldValue != null ? fieldValue : '');
    						
        return kontosZapisBody;
    }

    private String getKR_ReportKontoZapisCtrl(){
        String kontoZapisCtrl = '';    
        String sumaWinienVal = '';   
        String sumaMaVal = '';  
        Integer liczbaWierszyKontoZapis = 0;
    	Decimal sumaWinien = 0.0;
      	Decimal sumaMa = 0.0;
        
        if(listOfTransactions != null){
        	liczbaWierszyKontoZapis = listOfTransactions.size();
        	for(c2g__codaTransaction__c trn : listOfTransactions){
        		for(c2g__codaTransactionLineItem__c trnLi : trn.c2g__TransactionLineItems__r){
        			sumaWinienVal = ReportsGenerationUtility.getValue(trnLi, mappingRecordByDeveloperNameMap.get('KR_KontoZapis4').SFDC_Field_Name__c);
	        		sumaMaVal = ReportsGenerationUtility.getValue(trnLi, mappingRecordByDeveloperNameMap.get('KR_KontoZapis7').SFDC_Field_Name__c);
	        		sumaWinien += sumaWinienVal != null ? Decimal.valueOf(sumaWinienVal) : 0.0;
	        		sumaMa += sumaMaVal != null ? Decimal.valueOf(sumaMaVal) : 0.0;
        		}      		
        	}
        }
        kontoZapisCtrl = addNode(mappingRecordByDeveloperNameMap.get('KR_JPK8').Namespace__c + ':' + 
                               mappingRecordByDeveloperNameMap.get('KR_JPK8').Tag_Name__c, 
                                   addNode(mappingRecordByDeveloperNameMap.get('KR_KontoZapisCtrl1').Namespace__c + ':' + 
                                   mappingRecordByDeveloperNameMap.get('KR_KontoZapisCtrl1').Tag_Name__c, String.valueOf(liczbaWierszyKontoZapis)) + 
                                   addNode(mappingRecordByDeveloperNameMap.get('KR_KontoZapisCtrl2').Namespace__c + ':' + 
                                   mappingRecordByDeveloperNameMap.get('KR_KontoZapisCtrl2').Tag_Name__c, String.valueOf(sumaWinien)) +
                                   addNode(mappingRecordByDeveloperNameMap.get('KR_KontoZapisCtrl3').Namespace__c + ':' + 
                                   mappingRecordByDeveloperNameMap.get('KR_KontoZapisCtrl3').Tag_Name__c, String.valueOf(sumaMa))                                  
    				  		  );
        return kontoZapisCtrl;
    }
     
    //To generate VAT All invoices report
    private void createInvoicesVATReport(){
        try{		            	
            	String bodyOfJPKTag = getVATReportJPKTagBody();	            	
            	xmlFileString = '';
				xmlFileString += '<?xml version="1.0" encoding="UTF-8"?>';
            	xmlFileString += addNodeWithAttributes(mappingRecordByDeveloperNameMap.get('VAT_JPK0').Tag_Name__c,
                                 bodyOfJPKTag, 
                                 getMapOfAttributesAndValByLabel(mappingRecordByDeveloperNameMap.get('VAT_JPK0').MasterLabel, null));
                docLink = ReportsGenerationUtility.generateDocAndAddToFolder(VAT_REPORT_NAME, xmlFileString);            
		}catch(Exception e){
			ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, e.getMessage() + ' ' + e.getStackTraceString()));
		}
    }
    
    private String getVATReportJPKTagBody(){
        String str = '';
		str += getVATReport_Naglowek();
		str += getVATReport_Podmiot1();
		str += getVATReport_SprzedazWiersz();	
		str += getVATReport_SprzedazCtrl();	
		str += getVATReport_ZakupWiersz();
		str += getVATReport_ZakupCtrl(); 
        return str;
    }
    
    private String getVATReport_Naglowek(){
       	String naglowekStr = '';  	
    	try{
    		 naglowekStr += addNode(mappingRecordByDeveloperNameMap.get('VAT_JPK2').Tag_Name__c, 
    		 					addNodeWithAttributes(mappingRecordByDeveloperNameMap.get('VAT_KodFormularza0').Tag_Name__c, 
    		 					mappingRecordByDeveloperNameMap.get('VAT_KodFormularza0').Default_Value__c, 
    		 					getMapOfAttributesAndValByLabel(mappingRecordByDeveloperNameMap.get('VAT_KodFormularza0').MasterLabel, null)) + 
    		 					addNode(mappingRecordByDeveloperNameMap.get('VAT_Naglowek2').Tag_Name__c, mappingRecordByDeveloperNameMap.get('VAT_Naglowek2').Default_Value__c) + 
    		 					addNode(mappingRecordByDeveloperNameMap.get('VAT_Naglowek3').Tag_Name__c, mappingRecordByDeveloperNameMap.get('VAT_Naglowek3').Default_Value__c) + 
    		 					addNode(mappingRecordByDeveloperNameMap.get('VAT_Naglowek4').Tag_Name__c, String.valueOf(System.now())) +
    		 					addNode(mappingRecordByDeveloperNameMap.get('VAT_Naglowek7').Tag_Name__c, mappingRecordByDeveloperNameMap.get('VAT_Naglowek7').Default_Value__c)
    		 					 	
    		 				); 		 
    	}catch(Exception e){
    		ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, e.getMessage() + ' ' + e.getStackTraceString()));
    	}   	
    	return naglowekStr; 
    }
    
    private String getVATReport_Podmiot1(){
    	String podmiot1Str = '';        
        try{
            podmiot1Str  = addNode(mappingRecordByDeveloperNameMap.get('VAT_JPK3').Tag_Name__c, 
    							addNode(mappingRecordByDeveloperNameMap.get('VAT_Podmiot1').Tag_Name__c, 
    							mappingRecordByDeveloperNameMap.get('VAT_Podmiot1').Default_Value__c) +
			    				addNode(mappingRecordByDeveloperNameMap.get('VAT_Podmiot2').Tag_Name__c, 
			    				mappingRecordByDeveloperNameMap.get('VAT_Podmiot2').Default_Value__c) +
		    				    addNode(mappingRecordByDeveloperNameMap.get('VAT_Podmiot3').Tag_Name__c, 
		    				    mappingRecordByDeveloperNameMap.get('VAT_Podmiot3').Default_Value__c)
		    				   );            
        }catch(Exception e){
    		ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, e.getMessage() + ' ' + e.getStackTraceString()));
    	}    	
		return podmiot1Str;
    }
    
    // To get sales line items
    private String getVATReport_SprzedazWiersz(){
    	String sprzedazWierszList = ' ';
    	String sprzedazWierszBody = ' ';
 		
        try{
            if(listOfSalesLineItems != null){
                for(c2g__codaInvoiceLineItem__c salesInvLine : listOfSalesLineItems){
                        sprzedazWierszBody = getSprzedazWierszBody(salesInvLine);
                        sprzedazWierszList += addNode(mappingRecordByDeveloperNameMap.get('VAT_SprzedazWiersz0').Tag_Name__c, sprzedazWierszBody);
                }  		
    		}
        }catch(Exception e){
    		ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, e.getMessage() + ' ' + e.getStackTraceString()));
    	}    	
    	return sprzedazWierszList;
    }
    
    private String getSprzedazWierszBody(c2g__codaInvoiceLineItem__c invoiceLine){
        String sprzedazWierszBody = ' ';
        String sprzedazWiersz = ' ';
        String attributeStr = ' ';
        String fieldName = ' ';
        String fieldVal = ' ';
     
        try{
            for(Integer i=1; i<=7; i++){
                attributeStr = 'VAT_SprzedazWiersz' + i;
                fieldName = mappingRecordByDeveloperNameMap.get(attributeStr).SFDC_Field_Name__c != null ?
                			mappingRecordByDeveloperNameMap.get(attributeStr).SFDC_Field_Name__c : '';
                fieldVal = ReportsGenerationUtility.getValue(invoiceLine, fieldName);
                sprzedazWierszBody += addNode(mappingRecordByDeveloperNameMap.get(attributeStr).Tag_Name__c, fieldVal != null ? fieldVal : '');        
    		}
    		sprzedazWierszBody += addNode(mappingRecordByDeveloperNameMap.get('VAT_SprzedazWiersz8').Tag_Name__c, '') + 
    								addNode(mappingRecordByDeveloperNameMap.get('VAT_SprzedazWiersz9').Tag_Name__c, '');
        }catch(Exception e){
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, e.getMessage() + ' ' + e.getStackTraceString()));
        }        
        return sprzedazWierszBody;
    }
    
    //To get sales line total
    private string getVATReport_SprzedazCtrl(){
    	String sprzedazCtrl = '';
    	Integer numOfInvLines = 0;
        Decimal totalTaxFound =  0.0;
        String fieldValue = '';
        
        if(listOfSalesLineItems != null){
            numOfInvLines = listOfSalesLineItems.size();
            for(c2g__codaInvoiceLineItem__c invLine : listOfSalesLineItems){
               totalTaxFound += ReportsGenerationUtility.getValue(invLine, mappingRecordByDeveloperNameMap.get('VAT_SprzedazWiersz9').SFDC_Field_Name__c) != '' ?
               					Decimal.valueOf(ReportsGenerationUtility.getValue(invLine, mappingRecordByDeveloperNameMap.get('VAT_SprzedazWiersz9').SFDC_Field_Name__c)) : 0.0;
            }
        }
    	String liczbaWierszySprzedazyVal = String.valueOf(numOfInvLines);
    	String podatekNaleznyVal = String.valueOf(totalTaxFound);    	
    	sprzedazCtrl = addNode(mappingRecordByDeveloperNameMap.get('VAT_JPK5').Tag_Name__c, 
    				   		   addNode(mappingRecordByDeveloperNameMap.get('VAT_SprzedazCtrl1').Tag_Name__c, liczbaWierszySprzedazyVal) + 
    				   		   addNode(mappingRecordByDeveloperNameMap.get('VAT_SprzedazCtrl2').Tag_Name__c, podatekNaleznyVal)
    				  		  );
    	return sprzedazCtrl;
    }
    
    //To get Purchase Line Items
    private String getVATReport_ZakupWiersz(){
    	String zakupWierszList = ' ';
    	String zakupWierszBody = ' ';
 
    	if(listOfPurchaseLinesForVATReport != null && !listOfPurchaseLinesForVATReport.isEmpty()){
	    	for(c2g__codaPurchaseInvoiceLineItem__c purLineItem : listOfPurchaseLinesForVATReport){  
	    		zakupWierszBody = getZakupWierszBody(purLineItem);
	    		zakupWierszList += addNode(mappingRecordByDeveloperNameMap.get('VAT_ZakupWiersz0').Tag_Name__c, zakupWierszBody);
	    	}			
    	}
    	return zakupWierszList;
    }
 
    private String getZakupWierszBody(c2g__codaPurchaseInvoiceLineItem__c purLine){
        String zakupWierszBody = ' ';
        String fieldName = ' ';
        String fieldVal = '';
        String attributeStr = '';
        
        for(Integer i=1; i<=9; i++){
    		attributeStr = 'VAT_ZakupWiersz' + i;
            fieldName = mappingRecordByDeveloperNameMap.get(attributeStr).SFDC_Field_Name__c;
            fieldVal = ReportsGenerationUtility.getValue(purLine, fieldName);
    		zakupWierszBody += addNode(mappingRecordByDeveloperNameMap.get(attributeStr).Tag_Name__c, fieldVal != null ? fieldVal : '');
    	}
        return zakupWierszBody;
    }
    
    //To get Purchase Line Items Ctrl
    private String getVATReport_ZakupCtrl(){
    	String zakupCtrl = '';
    	
        Integer numOfPurchaseLines = 0;
        Decimal totalTaxFound =  0.0;
        
        if(listOfPurchaseLinesForVATReport != null){
            numOfPurchaseLines = listOfPurchaseLinesForVATReport.size();
            for(c2g__codaPurchaseInvoiceLineItem__c invLine : listOfPurchaseLinesForVATReport){
                totalTaxFound += (invLine.c2g__TaxValueTotal__c != null) ? invLine.c2g__TaxValueTotal__c : 0.0;
            }
        }
    	String liczbaWierszySprzedazyVal = String.valueOf(numOfPurchaseLines);
    	String podatekNaleznyVal = String.valueOf(totalTaxFound);
    	
    	zakupCtrl = addNode(mappingRecordByDeveloperNameMap.get('VAT_JPK7').Tag_Name__c, 
    				   		   addNode(mappingRecordByDeveloperNameMap.get('VAT_ZakupCtrl1').Tag_Name__c, liczbaWierszySprzedazyVal) + 
    				   		   addNode(mappingRecordByDeveloperNameMap.get('VAT_ZakupCtrl2').Tag_Name__c, podatekNaleznyVal)
    				  		  );
    	return zakupCtrl;
    }
    
    //To generate sales invoices report
    private void createSalesInvoicesReport(){
		try{		        	
            	String bodyOfJPKTag = getJPKTagBody();	            	
            	xmlFileString = '';
				xmlFileString += '<?xml version="1.0" encoding="UTF-8"?>';
            	xmlFileString += addNodeWithAttributes(mappingRecordByDeveloperNameMap.get('JPK0').Namespace__c + ':' + 
            					 mappingRecordByDeveloperNameMap.get('JPK0').Tag_Name__c,
                                 bodyOfJPKTag, 
                                 getMapOfAttributesAndValByLabel(mappingRecordByDeveloperNameMap.get('JPK0').MasterLabel, null));
                docLink = ReportsGenerationUtility.generateDocAndAddToFolder(SALES_FA_REPORT_NAME, xmlFileString);                               
		}catch(Exception e){
			ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, e.getMessage() + ' ' + e.getStackTraceString()));
		}
	}
	
	private String getJPKTagBody(){		
		String str = '';
		str += getNaglowek();
		str += getPodmiot1();
		str += getFakturaList();	
		str += getFakturaCtrl();	
		str += getStawkiPodatku();
		str += getFakturaWiersz();
		str += getFakturaWierszCtrl();
        return str;
	 }
    
    private String getNaglowek(){
    	String naglowekStr = '';  	
    	try{
    		 naglowekStr += addNode(mappingRecordByDeveloperNameMap.get('Naglowek0').Namespace__c + ':' +
    		 				mappingRecordByDeveloperNameMap.get('Naglowek0').Tag_Name__c, 
    		 					addNodeWithAttributes(mappingRecordByDeveloperNameMap.get('KodFormularza0').Namespace__c + ':' +
    		 					mappingRecordByDeveloperNameMap.get('KodFormularza0').Tag_Name__c, 
    		 					mappingRecordByDeveloperNameMap.get('KodFormularza0').Default_Value__c, 
    		 					getMapOfAttributesAndValByLabel(mappingRecordByDeveloperNameMap.get('KodFormularza0').MasterLabel, null)) +     		 					
    		 					addNode(mappingRecordByDeveloperNameMap.get('Naglowek2').Namespace__c + ':' + mappingRecordByDeveloperNameMap.get('Naglowek2').Tag_Name__c, 
    		 					mappingRecordByDeveloperNameMap.get('Naglowek2').Default_Value__c) + 
    		 					addNode(mappingRecordByDeveloperNameMap.get('Naglowek3').Namespace__c + ':' + mappingRecordByDeveloperNameMap.get('Naglowek3').Tag_Name__c, 
    		 					mappingRecordByDeveloperNameMap.get('Naglowek3').Default_Value__c) + 
    		 					addNode(mappingRecordByDeveloperNameMap.get('Naglowek4').Namespace__c + ':' + mappingRecordByDeveloperNameMap.get('Naglowek4').Tag_Name__c, 
    		 					String.valueOf(System.now())) +
    		 					addNode(mappingRecordByDeveloperNameMap.get('Naglowek7').Namespace__c + ':' + mappingRecordByDeveloperNameMap.get('Naglowek7').Tag_Name__c, 
    		 					mappingRecordByDeveloperNameMap.get('Naglowek7').Default_Value__c) +
    		 					addNode(mappingRecordByDeveloperNameMap.get('Naglowek8').Namespace__c + ':' + mappingRecordByDeveloperNameMap.get('Naglowek8').Tag_Name__c, 
    		 					mappingRecordByDeveloperNameMap.get('Naglowek8').Default_Value__c)  
    		 					
    		 				); 		 
    	}catch(Exception e){
    		ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, e.getMessage() + ' ' + e.getStackTraceString()));
    	}   	
    	return naglowekStr;
    }
    
    private String getPodmiot1(){
    	
    	String podmiot1Str = '';
    	podmiot1Str += addNode(mappingRecordByDeveloperNameMap.get('Podmiot0').Namespace__c + ':' +
    				   mappingRecordByDeveloperNameMap.get('Podmiot0').Tag_Name__c, getIdentyfikatorPodmiotu() + getAdresPodmiotu());
		return podmiot1Str;
    }
    
    private String getIdentyfikatorPodmiotu(){
    	String identyfikatorPodmiotu = '';
    	String identyfikatorPodmiotuBody = '';
    	String attributeStr = '';
    	
    	for(Integer i=1; i<=3; i++){
    		attributeStr = 'IdentyfikatorPodmiotu' + i;
    		identyfikatorPodmiotuBody += addNode(mappingRecordByDeveloperNameMap.get(attributeStr).Namespace__c + ':' +
    				   			 		 		 mappingRecordByDeveloperNameMap.get(attributeStr).Tag_Name__c, 
                                            	 mappingRecordByDeveloperNameMap.get(attributeStr).Default_Value__c);
    	}  				   			    	
    	identyfikatorPodmiotu += addNode(mappingRecordByDeveloperNameMap.get('IdentyfikatorPodmiotu0').Namespace__c + ':' +
    				   			 mappingRecordByDeveloperNameMap.get('IdentyfikatorPodmiotu0').Tag_Name__c, identyfikatorPodmiotuBody);
    	return identyfikatorPodmiotu;
    }
    
    private String getAdresPodmiotu(){
    	String adresPodmiotu = '';
    	String adresPodmiotuBody = '';
    	String attributeStr = '';
    	
    	for(Integer i=1; i<=10; i++){
    		attributeStr = 'AdresPodmiotu' + i;
    		adresPodmiotuBody += addNode(mappingRecordByDeveloperNameMap.get(attributeStr).Namespace__c + ':' +
    				   			 mappingRecordByDeveloperNameMap.get(attributeStr).Tag_Name__c, 
                                 mappingRecordByDeveloperNameMap.get(attributeStr).Default_Value__c);
    	}
    	adresPodmiotu += addNode(mappingRecordByDeveloperNameMap.get('AdresPodmiotu0').Namespace__c + ':' +
    				   			 mappingRecordByDeveloperNameMap.get('AdresPodmiotu0').Tag_Name__c, adresPodmiotuBody);    	
    	return adresPodmiotu;
    }
    
    //To add information of invoices
    private String getFakturaList(){
    	String fakturaStr = '';
    	String fakturaStrBody = ' ';	

        if(listOfSalesInvoices != null){
            for(c2g__codaInvoice__c invoice : listOfSalesInvoices){
    		fakturaStrBody = getfakturaStrBody(invoice); 
    		fakturaStr += addNodeWithAttributes(mappingRecordByDeveloperNameMap.get('Faktura0').Namespace__c + ':' +
    				   			 mappingRecordByDeveloperNameMap.get('Faktura0').Tag_Name__c, fakturaStrBody,
    				   			 getMapOfAttributesAndValByLabel(mappingRecordByDeveloperNameMap.get('Faktura0').MasterLabel, null)); 
    		}	
        }
   		return fakturaStr;
    } 
	
	private String getfakturaStrBody(c2g__codaInvoice__c salesInv){
    	String fakturaBodyStr = '';
    	String attributeStr;
        String fieldName = '';
        String fieldVal = '';
        String taxCode = '';
        String taxRegNum = '';
    	
        for(Integer i=1; i<=23; i++){
    		attributeStr = 'Faktura' + i;
            if(i >= 15 && i<=22){
                fieldVal = (mappingRecordByDeveloperNameMap.get(attributeStr).Default_Value__c != null) ? 
                    		mappingRecordByDeveloperNameMap.get(attributeStr).Default_Value__c : '';
                fakturaBodyStr += addNode(mappingRecordByDeveloperNameMap.get(attributeStr).Namespace__c + ':' +
                                          mappingRecordByDeveloperNameMap.get(attributeStr).Tag_Name__c, fieldVal);
            }else{           	
            	if(attributeStr == 'Faktura7'){
            		taxCode = ReportsGenerationUtility.getValue(salesInv, (mappingRecordByDeveloperNameMap.get('Faktura7').SFDC_Field_Name__c != null) ? 
            													mappingRecordByDeveloperNameMap.get('Faktura7').SFDC_Field_Name__c : '');
            		taxRegNum = ReportsGenerationUtility.getValue(salesInv, (mappingRecordByDeveloperNameMap.get('Faktura8').SFDC_Field_Name__c != null) ?
            													mappingRecordByDeveloperNameMap.get('Faktura8').SFDC_Field_Name__c : '');
            		if(taxCode != null && taxRegNum != null)
            			fieldVal = taxCode + taxRegNum;
            	}else if(attributeStr == 'Faktura4'){
            		fieldVal = (ReportsGenerationUtility.getValue(salesInv, 'c2g__Account__r.Primary_Country__c') != null) ?
            					ReportsGenerationUtility.getValue(salesInv, 'c2g__Account__r.Primary_Country__c') : '';
                }else if(attributeStr == 'Faktura14'){
					fieldVal = ReportsGenerationUtility.getValue(salesInv, (mappingRecordByDeveloperNameMap.get('Faktura14').SFDC_Field_Name__c != null) ? 
            					mappingRecordByDeveloperNameMap.get('Faktura14').SFDC_Field_Name__c : '');          			  
                }else if(attributeStr == 'Faktura23'){
                 	fieldVal = 'VAT';
                }else{
            		fieldName = mappingRecordByDeveloperNameMap.get(attributeStr).SFDC_Field_Name__c;
		            fieldVal = (fieldName != null) ? ReportsGenerationUtility.getValue(salesInv, fieldName) : '';
            	} 
            	fakturaBodyStr += addNode(mappingRecordByDeveloperNameMap.get(attributeStr).Namespace__c + ':' +
		                                      mappingRecordByDeveloperNameMap.get(attributeStr).Tag_Name__c, 
		                                       (fieldVal != null ? fieldVal : ''));	         		            
            }          
    	}
    	return fakturaBodyStr;
    }
    
    private String getFakturaCtrl(){
    	String fakturaCtrl = '';
        Integer numOfInvoices = 0;
        Decimal totalValueOfInvoices = 0.0;
    	
        if(listOfSalesInvoices != null){
            numOfInvoices = listOfSalesInvoices.size();
            for(c2g__codaInvoice__c inv : listOfSalesInvoices){
                totalValueOfInvoices += (ReportsGenerationUtility.getValue(inv, mappingRecordByDeveloperNameMap.get('Faktura14').SFDC_Field_Name__c) != '') ?
                						Decimal.valueOf(ReportsGenerationUtility.getValue(inv, mappingRecordByDeveloperNameMap.get('Faktura14').SFDC_Field_Name__c)) : 0.0;
            }         
        } 
        String liczbaFakturVal = String.valueOf(numOfInvoices);
    	String wartoscFakturVal = String.valueOf(totalValueOfInvoices);   	
    	fakturaCtrl = addNode(mappingRecordByDeveloperNameMap.get('FakturaCtrl0').Namespace__c + ':' +
    				   		  mappingRecordByDeveloperNameMap.get('FakturaCtrl0').Tag_Name__c, 
    				   		  addNode(mappingRecordByDeveloperNameMap.get('FakturaCtrl1').Namespace__c + ':' +
    				   		  mappingRecordByDeveloperNameMap.get('FakturaCtrl1').Tag_Name__c, liczbaFakturVal) + 
    				   		  addNode(mappingRecordByDeveloperNameMap.get('FakturaCtrl2').Namespace__c + ':' +
    				   		  mappingRecordByDeveloperNameMap.get('FakturaCtrl2').Tag_Name__c, wartoscFakturVal)
    				  		);
    	return fakturaCtrl;
    }
    
    //Get sales line items - FakturaWiersz
    private string getFakturaWiersz(){
    	String fakturaWierszList = '';
    	String fakturaWierszBody = '';
    	String tagName = mappingRecordByDeveloperNameMap.get('FakturaWiersz0').Namespace__c + ':' +
    				   	 mappingRecordByDeveloperNameMap.get('FakturaWiersz0').Tag_Name__c;
    				   			 
    	if(listOfSalesLineItems != null){
    		for(c2g__codaInvoiceLineItem__c lineItem : listOfSalesLineItems){ 
	    		fakturaWierszBody = getfakturaWierszBody(lineItem);
	    		fakturaWierszList += addNodeWithAttributes(tagName, fakturaWierszBody,
	    				   			     getMapOfAttributesAndValByLabel(mappingRecordByDeveloperNameMap.get('FakturaWiersz0').MasterLabel, null)); 
	    	}	 		
    	}
    	return fakturaWierszList;
    }
    
    // Default values of tax rates applied
    private String getStawkiPodatku(){
    	String stawkiPodatkuStr = '';
        String stawkiPodatkuStrBody = '';    
    	String mappingName = '';
    	String stawkiPodatku = '';
    	String defaultValue = '';
    	
    	for(Integer i=1; i<=5; i++){
    		mappingName = 'StawkiPodatku' + i;
    		defaultValue = mappingRecordByDeveloperNameMap.get(mappingName).Default_Value__c;
    		stawkiPodatku += addNode(mappingRecordByDeveloperNameMap.get(mappingName).Namespace__c + ':' +
    				   			   		mappingRecordByDeveloperNameMap.get(mappingName).Tag_Name__c, 
    				   			   		defaultValue != null ? defaultValue : '');		
    	}
    	stawkiPodatkuStr = addNode(mappingRecordByDeveloperNameMap.get('StawkiPodatku0').Namespace__c + ':' +
    				   			   mappingRecordByDeveloperNameMap.get('StawkiPodatku0').Tag_Name__c, stawkiPodatku);
    	return stawkiPodatkuStr;
    }
    
    private String getfakturaWierszBody(c2g__codaInvoiceLineItem__c saleLineItem){
    	String fakturaWierszStr = '';
    	String attributeStr;   	
        try{
            for(Integer i=1; i<=8; i++){
                attributeStr = 'FakturaWiersz' + i;
                fakturaWierszStr += addNode(mappingRecordByDeveloperNameMap.get(attributeStr).Namespace__c + ':' +
                                            mappingRecordByDeveloperNameMap.get(attributeStr).Tag_Name__c, 
                                            ReportsGenerationUtility.getValue(saleLineItem, 
                                            mappingRecordByDeveloperNameMap.get(attributeStr).SFDC_Field_Name__c));
    		}            
        }catch(Exception e){
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, e.getMessage() + ' ' + e.getStackTraceString()));
        }     	
    	return fakturaWierszStr;
    }
    
    private String getFakturaWierszCtrl(){
    	String fakturaWierszCtrl = '';   	
        Integer numOfInvLines = 0;
        Integer numOfCreditNoteLines = 0;
        Decimal totalValueOfInvLine = 0.0;    	
        try{
            if(listOfSalesLineItems != null){
                numOfInvLines = listOfSalesLineItems.size();
                for(c2g__codaInvoiceLineItem__c invLine : listOfSalesLineItems){
                    totalValueOfInvLine += ReportsGenerationUtility.getValue(invLine, 
                 							 mappingRecordByDeveloperNameMap.get('FakturaWiersz6').SFDC_Field_Name__c) != '' ?
                                             Decimal.valueOf(ReportsGenerationUtility.getValue(invLine, 
                 							 mappingRecordByDeveloperNameMap.get('FakturaWiersz6').SFDC_Field_Name__c)) : 0.0;
                }
        	} 
            String liczbaWierszyFakturVal = String.valueOf(numOfInvLines);
            String wartoscWierszyFakturVal = String.valueOf(totalValueOfInvLine);            
            fakturaWierszCtrl = addNode(mappingRecordByDeveloperNameMap.get('FakturaWierszCtrl0').Namespace__c + ':' +
                                  mappingRecordByDeveloperNameMap.get('FakturaWierszCtrl0').Tag_Name__c, 
                                  addNode(mappingRecordByDeveloperNameMap.get('FakturaWierszCtrl1').Namespace__c + ':' +
                                  mappingRecordByDeveloperNameMap.get('FakturaWierszCtrl1').Tag_Name__c, liczbaWierszyFakturVal) + 
                                  addNode(mappingRecordByDeveloperNameMap.get('FakturaWierszCtrl2').Namespace__c + ':' +
                                  mappingRecordByDeveloperNameMap.get('FakturaWierszCtrl2').Tag_Name__c, wartoscWierszyFakturVal)
                                );                
        }catch(Exception e){
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, e.getMessage() + ' ' + e.getStackTraceString()));
        }       
    	return fakturaWierszCtrl;
    }
    
    private Map<String, String> getMapOfAttributesAndValByLabel(String label, sObject obj){    
        Map<String, String> mapOfAttributesAndLabel = new Map<String, String>();        
        try{
            if(label == 'JPK'){
            mapOfAttributesAndLabel = getJPKAttributes();
            }else if(label == 'KodFormularza'){
                mapOfAttributesAndLabel = getKodFormularzattributes();
            }else if(label == 'Faktura'){
                mapOfAttributesAndLabel.put(mappingRecordByDeveloperNameMap.get('Faktura0').Attribute_Name__c, 
                                            mappingRecordByDeveloperNameMap.get('Faktura0').Attribute_Value__c);
            }else if(label == 'FakturaWiersz'){
                mapOfAttributesAndLabel.put(mappingRecordByDeveloperNameMap.get('FakturaWiersz0').Attribute_Name__c, 
                                            mappingRecordByDeveloperNameMap.get('FakturaWiersz0').Attribute_Value__c);
            }else if(label == 'VAT_JPK'){
                mapOfAttributesAndLabel.put(mappingRecordByDeveloperNameMap.get('VAT_JPK1').Attribute_Name__c, 
                                            mappingRecordByDeveloperNameMap.get('VAT_JPK1').Attribute_Value__c);
                mapOfAttributesAndLabel.put(mappingRecordByDeveloperNameMap.get('VAT_JPK0').Attribute_Name__c, 
                                            mappingRecordByDeveloperNameMap.get('VAT_JPK0').Attribute_Value__c);
            }else if(label == 'VAT_KodFormularza'){
                mapOfAttributesAndLabel.put(mappingRecordByDeveloperNameMap.get('VAT_KodFormularza1').Attribute_Name__c,
                                            mappingRecordByDeveloperNameMap.get('VAT_KodFormularza1').Attribute_Value__c);
                mapOfAttributesAndLabel.put(mappingRecordByDeveloperNameMap.get('VAT_KodFormularza0').Attribute_Name__c,
                                            mappingRecordByDeveloperNameMap.get('VAT_KodFormularza0').Attribute_Value__c);            
            }else if(label == 'KR_JPK'){
                mapOfAttributesAndLabel.put(mappingRecordByDeveloperNameMap.get('KR_JPK1').Attribute_Name__c,
                                            mappingRecordByDeveloperNameMap.get('KR_JPK1').Attribute_Value__c);
                mapOfAttributesAndLabel.put(mappingRecordByDeveloperNameMap.get('KR_JPK0').Attribute_Name__c,
                                            mappingRecordByDeveloperNameMap.get('KR_JPK0').Attribute_Value__c);
            }else if(label == 'KR_ZOiS'){
                mapOfAttributesAndLabel.put(mappingRecordByDeveloperNameMap.get('KR_ZOiS0').Attribute_Name__c,
                                            mappingRecordByDeveloperNameMap.get('KR_ZOiS0').Attribute_Value__c);
            }else if(label == 'KR_Dziennik'){
                mapOfAttributesAndLabel.put(mappingRecordByDeveloperNameMap.get('KR_Dziennik0').Attribute_Name__c,
                                            mappingRecordByDeveloperNameMap.get('KR_Dziennik0').Attribute_Value__c);
            }else if(label == 'KR_KontoZapis'){
                mapOfAttributesAndLabel.put(mappingRecordByDeveloperNameMap.get('KR_KontoZapis0').Attribute_Name__c,
                                            mappingRecordByDeveloperNameMap.get('KR_KontoZapis0').Attribute_Value__c);
            }         
        }catch(Exception e){
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, e.getMessage() + ' ' + e.getStackTraceString()));
        }         
        return mapOfAttributesAndLabel;
    }
    
    private Map<String, String> getJPKAttributes(){       
        Map<String, String> mapOfAttributesAndValues = new Map<String, String>();
        
        try{
            mapOfAttributesAndValues.put(mappingRecordByDeveloperNameMap.get('JPK1').Attribute_Name__c,
    								 mappingRecordByDeveloperNameMap.get('JPK1').Attribute_Value__c);
        	mapOfAttributesAndValues.put(mappingRecordByDeveloperNameMap.get('JPK0').Attribute_Name__c,
    								 mappingRecordByDeveloperNameMap.get('JPK0').Attribute_Value__c);
        }catch(Exception e){
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, e.getMessage() + ' ' + e.getStackTraceString()));
        }         
    	return mapOfAttributesAndValues;
    }
    
    private Map<String, String> getKodFormularzattributes(){       
        Map<String, String> mapOfAttributesAndValues = new Map<String, String>();        
        try{
            mapOfAttributesAndValues.put(mappingRecordByDeveloperNameMap.get('KodFormularza1').Attribute_Name__c,
    								 mappingRecordByDeveloperNameMap.get('KodFormularza1').Attribute_Value__c);
        	mapOfAttributesAndValues.put(mappingRecordByDeveloperNameMap.get('KodFormularza0').Attribute_Name__c,
    								 mappingRecordByDeveloperNameMap.get('KodFormularza0').Attribute_Value__c);
        }catch(Exception e){
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, e.getMessage() + ' ' + e.getStackTraceString()));
        }        
    	return mapOfAttributesAndValues;
    }
    
    private void getSalesInvoicesCommonMethod(){
    	Boolean hasSubquery = true;
        String objectName = mappingRecordByDeveloperNameMap.get('Faktura1').Object_Name__c;
        String whereCondition = 'c2g__Transaction__c != null and c2g__Transaction__r.c2g__Period__r.c2g__PeriodNumber__c = :selectedMonth' +
                    			' AND c2g__Transaction__r.c2g__Period__r.c2g__YearName__r.Name = :selectedYear';
        
        if(String.isNotBlank(AUDIT_FILE_COMPANY_NAME)){
        	whereCondition += ' AND c2g__Transaction__r.c2g__OwnerCompany__r.Name = :AUDIT_FILE_COMPANY_NAME';
        } 
        
        // If report is VAT Report
        if(fileType == 'report1'){
           whereCondition += ' AND (c2g__TaxCode1__c != null or c2g__TaxCode2__c != null or c2g__TaxCode3__c != null)';
        }
        
        Set<String> fieldNameSet = new Set<String>();
        Set<String> setOfInnerQueryFields = new Set<String>();
        Map<String, Set<String>> innerQueryObjAndFieldsMap = new Map<String, Set<String>>();
        listOfSalesInvoices = new List<c2g__codaInvoice__c>();
        listOfSalesLineItems = new List<c2g__codaInvoiceLineItem__c>();        
        
        try{
        	if(fileType == 'report2'){
	        	fieldNameSet = getFieldNameSet(mappingRecordByDeveloperNameMap.get('Faktura1').MasterLabel);
	        	setOfInnerQueryFields = getFieldNameSet(mappingRecordByDeveloperNameMap.get('FakturaWiersz1').MasterLabel);
	            innerQueryObjAndFieldsMap.put(mappingRecordByDeveloperNameMap.get('FakturaWiersz1').Object_Name__c, setOfInnerQueryFields);              
        	}else if(fileType == 'report1'){
	        	setOfInnerQueryFields = getFieldNameSet(mappingRecordByDeveloperNameMap.get('VAT_SprzedazWiersz0').MasterLabel);
	            innerQueryObjAndFieldsMap.put(mappingRecordByDeveloperNameMap.get('VAT_SprzedazWiersz0').Object_Name__c, setOfInnerQueryFields);              
        	}
	        fieldNameSet.add('c2g__Transaction__c');
	        fieldNameSet.add('c2g__TaxCode1__c');
	        fieldNameSet.add('c2g__TaxCode2__c');
	        fieldNameSet.add('c2g__TaxCode3__c');
	        fieldNameSet.add('c2g__Account__r.Primary_Country__c');
    	
			ReportsGenerationUtility.AUDIT_FILE_COMPANY_NAME = AUDIT_FILE_COMPANY_NAME;
            ReportsGenerationUtility.selectedMonth = selectedMonth;
            ReportsGenerationUtility.selectedYear = selectedYear;
            
    		listOfSalesInvoices = (List<c2g__codaInvoice__c>)ReportsGenerationUtility.getSFDCRecordsWithSubQuery(objectName, 
                                  fieldNameSet, whereCondition, hasSubquery, innerQueryObjAndFieldsMap);     
            System.debug('List of listOfSalesInvoices:' + listOfSalesInvoices);
            if(listOfSalesInvoices != null){
            	for(c2g__codaInvoice__c inv : listOfSalesInvoices){
                    if(inv.c2g__InvoiceLineItems__r != null)
                        listOfSalesLineItems.addAll(inv.c2g__InvoiceLineItems__r);
                }
            }
        }catch(Exception e){
        	ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, e.getMessage() + ' ' + e.getStackTraceString()));
        }       
    }
       
    private void getDataForAllEntriesReport(){
        Boolean hasSubquery = false;
        Set<String> fieldNameSet = new Set<String>();
        Set<String> setOfInnerQueryFields = new Set<String>();
        String objectName = ''; 
        Map<String, Set<String>> innerQueryObjAndFieldsMap = new Map<String, Set<String>>();
        
        String whereCondition = 'c2g__Transaction__c != null and c2g__Transaction__r.c2g__Period__r.c2g__PeriodNumber__c = :selectedMonth' +
                    			' AND c2g__Transaction__r.c2g__Period__r.c2g__YearName__r.Name = :selectedYear';
        
        if(String.isNotBlank(AUDIT_FILE_COMPANY_NAME)){
        	whereCondition += ' AND c2g__Transaction__r.c2g__OwnerCompany__r.Name = :AUDIT_FILE_COMPANY_NAME';
        }
           
        try{
        	listOfPeriods = getPeriodsForQuery(selectedMonth); 
            fieldNameSet = getFieldNameSet(mappingRecordByDeveloperNameMap.get('KR_Dziennik1').MasterLabel);     
            
            ReportsGenerationUtility.AUDIT_FILE_COMPANY_NAME = AUDIT_FILE_COMPANY_NAME;
            ReportsGenerationUtility.selectedMonth = selectedMonth;
            ReportsGenerationUtility.selectedYear = selectedYear;
            
            
            listOfJournals = (List<c2g__codaJournal__c>)ReportsGenerationUtility.getSFDCRecordsWithSubQuery('c2g__codaJournal__c', 
                             fieldNameSet, whereCondition, hasSubquery, innerQueryObjAndFieldsMap);
            System.debug('List of listOfJournals:' + listOfJournals);              
            
            objectName = 'c2g__codaTransaction__c';
            fieldNameSet = new Set<String>();
            fieldNameSet.add('Name');
  
			whereCondition = 'c2g__Period__r.c2g__YearName__r.Name = :selectedYear' +
                			 ' AND c2g__Period__r.c2g__PeriodNumber__c IN :listOfPeriods';
            
            if(String.isNotBlank(AUDIT_FILE_COMPANY_NAME)){
                    whereCondition += ' AND c2g__OwnerCompany__r.Name = :AUDIT_FILE_COMPANY_NAME';
            }
			hasSubquery = true;
			setOfInnerQueryFields = getFieldNameSet(mappingRecordByDeveloperNameMap.get('KR_KontoZapis1').MasterLabel);  
			setOfInnerQueryFields.addAll(getFieldNameSet(mappingRecordByDeveloperNameMap.get('KR_ZOiS1').MasterLabel));
			setOfInnerQueryFields.add('c2g__Transaction__r.c2g__Period__r.c2g__PeriodNumber__c'); 
			setOfInnerQueryFields.add('c2g__Transaction__r.c2g__Period__r.c2g__YearName__r.Name'); 
			setOfInnerQueryFields.add('c2g__HomeValue__c');
			innerQueryObjAndFieldsMap.put(mappingRecordByDeveloperNameMap.get('KR_KontoZapis1').Object_Name__c, setOfInnerQueryFields);   
			
			ReportsGenerationUtility.AUDIT_FILE_COMPANY_NAME = AUDIT_FILE_COMPANY_NAME;
            ReportsGenerationUtility.listOfPeriods = listOfPeriods;
            ReportsGenerationUtility.selectedYear = selectedYear;
            listOfTransactions = (List<c2g__codaTransaction__c>)ReportsGenerationUtility.getSFDCRecordsWithSubQuery(objectName,
            													fieldNameSet, whereCondition, hasSubquery, innerQueryObjAndFieldsMap);
   			if(listOfTransactions != null && !listOfTransactions.isEmpty()){
	   			setGLABalancesInfo();
	    		setGLAInfo();
   			}
   
        }catch(Exception e){
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, e.getMessage() + ' ' + e.getStackTraceString()));
        }                 
    }
    
    // Can be added to Reports Generation Utility class
    private List<String> getPeriodsForQuery(String selectedPeriod){
       String period;
       Integer indexOfPeriod;
       List<String> listOfPeriodsForQuery = new List<String>();   
       listOfPeriodMonths = new List<String>();
       
        for(SelectOption selOp : periodOptions){
            listOfPeriodMonths.add(selOp.getValue());
        }
       	indexOfPeriod = listOfPeriodMonths.indexOf(selectedPeriod);
        for(Integer i=0; i<=indexOfPeriod; i++){
            period = listOfPeriodMonths.get(i);
            listOfPeriodsForQuery.add(period);
        }
        return listOfPeriodsForQuery;
   }
   
    // To get balances on GLAs
    private void setGLABalancesInfo(){
    	mapOfOpeningBal = new Map<String, String>(); 
		mapOfClosingBal = new Map<String, String>(); 
		mapOfDebitsForReportingPeriod = new Map<String, String>();
		mapOfCreditsForReportingPeriod = new Map<String, String>();
		mapOfDbFromBeginingToEnd = new Map<String, String>(); 
		mapOfCrFromBeginingToEnd = new Map<String, String>(); 
		
	    if(listOfTransactions != null){
	    	for(c2g__codaTransaction__c trn : listOfTransactions){	    	
		    	if(trn.c2g__TransactionLineItems__r != null){                    
                    for(c2g__codaTransactionLineItem__c trnLine : trn.c2g__TransactionLineItems__r){
                    	String repCode = ReportsGenerationUtility.getValue(trnLine, mappingRecordByDeveloperNameMap.get('KR_ZOiS1').SFDC_Field_Name__c);          
	                    Decimal lineItemHomeValue = Decimal.valueOf(ReportsGenerationUtility.getValue(trnLine, 'c2g__HomeValue__c'));
	                    String periodMonth = ReportsGenerationUtility.getValue(trnLine, 'c2g__Transaction__r.c2g__Period__r.c2g__PeriodNumber__c');
	                  
	                    if(periodMonth != selectedMonth){
	                    	setOpeningBalances(repCode, lineItemHomeValue);
	                    }else{
	                    	calculateCurrentPeriodBal(repCode, lineItemHomeValue);
	                    }
	                    setClosingBalances(repCode, lineItemHomeValue);              		
                    }                
		    	}	    	
	    	}
	    }  
   	}
  	
	private void setOpeningBalances(String repCode, Decimal homeVal){
        Decimal updatedHomeVal = 0.0;
   		if(String.isNotBlank(repCode)){				
   			updatedHomeVal = (mapOfOpeningBal.get(repCode) != null) ? Decimal.valueOf(mapOfOpeningBal.get(repCode)) + homeVal : homeVal;
	        mapOfOpeningBal.put(repCode, String.valueOf(updatedHomeVal));
   		}
	}
	
	private void setClosingBalances(String repCode, Decimal homeVal){
        Decimal updatedHomeVal = 0.0;
		if(String.isNotBlank(repCode)){				
   			updatedHomeVal = (mapOfClosingBal.get(repCode) != null) ? Decimal.valueOf(mapOfClosingBal.get(repCode)) + homeVal : homeVal;
	        mapOfClosingBal.put(repCode, String.valueOf(updatedHomeVal));
	        
	        if(homeVal >= 0){
	   			updatedHomeVal = (mapOfDbFromBeginingToEnd.get(repCode) != null) ? Decimal.valueOf(mapOfDbFromBeginingToEnd.get(repCode)) + homeVal : homeVal;
		        mapOfDbFromBeginingToEnd.put(repCode, String.valueOf(updatedHomeVal));	
   			}else{
   				updatedHomeVal = (mapOfCrFromBeginingToEnd.get(repCode) != null) ? Decimal.valueOf(mapOfCrFromBeginingToEnd.get(repCode)) + homeVal : homeVal;
		        mapOfCrFromBeginingToEnd.put(repCode, String.valueOf(updatedHomeVal));	
   			}
   		}
	}
	
	private void calculateCurrentPeriodBal(String repCode, Decimal homeVal){
        Decimal updatedHomeVal = 0.0;
		if(String.isNotBlank(repCode)){				
	        if(homeVal >= 0){
	   			updatedHomeVal = (mapOfDebitsForReportingPeriod.get(repCode) != null) ? Decimal.valueOf(mapOfDebitsForReportingPeriod.get(repCode)) + homeVal : homeVal;
		        mapOfDebitsForReportingPeriod.put(repCode, String.valueOf(updatedHomeVal));	
   			}else{
   				updatedHomeVal = (mapOfCreditsForReportingPeriod.get(repCode) != null) ? Decimal.valueOf(mapOfCreditsForReportingPeriod.get(repCode)) + homeVal : homeVal;
		        mapOfCreditsForReportingPeriod.put(repCode, String.valueOf(updatedHomeVal));	
   			}
   		}
	}
	
   	private void setGLAInfo(){
  		String kodKonta, opisKonta, typKonta, kodZespolu, opisZespolu, kodKategorii, opisKategorii; 
    	String fieldName = mappingRecordByDeveloperNameMap.get('KR_ZOiS1').SFDC_Field_Name__c;					
    	String glaReportingCode = '';
    	mapOfGlaInfo = new Map<String, glaForAllEntriesWrapper>();
    	
    	if(listOfTransactions !=  null){
    		for(c2g__codaTransaction__c trn : listOfTransactions){
                if(trn.c2g__TransactionLineItems__r != null){
                	for(c2g__codaTransactionLineItem__c trli : trn.c2g__TransactionLineItems__r){	
                		glaReportingCode = ReportsGenerationUtility.getValue(trli, fieldName);	
                		if(String.isNotBlank(glaReportingCode)){ 
                			kodKonta = glaReportingCode;
				    		opisKonta = ReportsGenerationUtility.getValue(trli, mappingRecordByDeveloperNameMap.get('KR_ZOiS2').SFDC_Field_Name__c);
				    		typKonta = ReportsGenerationUtility.getValue(trli, mappingRecordByDeveloperNameMap.get('KR_ZOiS3').SFDC_Field_Name__c);
				    		kodZespolu = ReportsGenerationUtility.getValue(trli, mappingRecordByDeveloperNameMap.get('KR_ZOiS4').SFDC_Field_Name__c);
				    		opisZespolu = ReportsGenerationUtility.getValue(trli, mappingRecordByDeveloperNameMap.get('KR_ZOiS5').SFDC_Field_Name__c);
				    		kodKategorii = ReportsGenerationUtility.getValue(trli, mappingRecordByDeveloperNameMap.get('KR_ZOiS6').SFDC_Field_Name__c);	
				    		opisKategorii = ReportsGenerationUtility.getValue(trli, mappingRecordByDeveloperNameMap.get('KR_ZOiS7').SFDC_Field_Name__c);
				    		
                			if(mapOfGlaInfo.get(glaReportingCode) == null){
			    				mapOfGlaInfo.put(glaReportingCode, new glaForAllEntriesWrapper(kodKonta, opisKonta, typKonta, kodZespolu, 
			    																	opisZespolu, kodKategorii, opisKategorii));
			    			}
                		} 
                	}
                }
    		}
    	}
    }
   
    //To get purchase invoices for VAT Report
    private void getPurchaseInvForVATReport(){
        Boolean hasSubquery = true;
        String whereCondition = '';
        Set<String> fieldNameSet = new Set<String>();
        Set<String> setOfInnerQueryFields = new Set<String>();
        Map<String, Set<String>> innerQueryObjAndFieldsMap = new Map<String, Set<String>>();
        
        whereCondition = 'c2g__Transaction__c != null and c2g__Transaction__r.c2g__Period__r.c2g__PeriodNumber__c = :selectedMonth' +
                    	 ' AND c2g__Transaction__r.c2g__Period__r.c2g__YearName__r.Name = :selectedYear' +
            			 ' AND (c2g__TaxCode1__c != null or c2g__TaxCode2__c != null or c2g__TaxCode3__c != null)';
        
        if(String.isNotBlank(AUDIT_FILE_COMPANY_NAME)){
        	whereCondition += ' AND c2g__Transaction__r.c2g__OwnerCompany__r.Name = :AUDIT_FILE_COMPANY_NAME';
        }       
    
        try{
            fieldNameSet.add('c2g__Transaction__c');       
            setOfInnerQueryFields = getFieldNameSet(mappingRecordByDeveloperNameMap.get('VAT_ZakupWiersz0').MasterLabel);
            innerQueryObjAndFieldsMap.put(mappingRecordByDeveloperNameMap.get('VAT_ZakupWiersz0').Object_Name__c, setOfInnerQueryFields);    
           
            ReportsGenerationUtility.AUDIT_FILE_COMPANY_NAME = AUDIT_FILE_COMPANY_NAME;
            ReportsGenerationUtility.selectedMonth = selectedMonth;
            ReportsGenerationUtility.selectedYear = selectedYear;
            listOfPurchaseInvoicesForVATReport = (List<c2g__codaPurchaseInvoice__c>)ReportsGenerationUtility.getSFDCRecordsWithSubQuery('c2g__codaPurchaseInvoice__c', 
                                            fieldNameSet, whereCondition, hasSubquery, innerQueryObjAndFieldsMap);

            if(listOfPurchaseInvoicesForVATReport != null){
                for(c2g__codaPurchaseInvoice__c purchInv : listOfPurchaseInvoicesForVATReport){
                    if(purchInv.c2g__PurchaseInvoiceLineItems__r != null)
                        listOfPurchaseLinesForVATReport.addAll(purchInv.c2g__PurchaseInvoiceLineItems__r);
                }
            }            
        }catch(Exception e){
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, e.getMessage() + ' ' + e.getStackTraceString()));
        }       
    }

	public class glaForAllEntriesWrapper{
    	public String kodKonta; //gla reporting code
    	public String opisKonta;
    	public String typKonta; 
    	public String kodZespolu;
    	public String opisZespolu; 
    	public String kodKategorii; 
    	public String opisKategorii; 
    	
    	public glaForAllEntriesWrapper(String kodKonta, String opisKonta, String typKonta, String kodZespolu,
    							 String opisZespolu, String kodKategorii, String opisKategorii) {
            this.kodKonta = kodKonta;
            this.opisKonta = opisKonta;
            this.typKonta = typKonta;
            this.kodZespolu = kodZespolu;
            this.opisZespolu = opisZespolu;
            this.kodKategorii = kodKategorii;
            this.opisKategorii = opisKategorii;
        } 	
    }
    
    private Set<String> getFieldNameSet(String parentTagName){
		Set<String> fieldNameSet = new Set<String>();
		List<Poland_Invoices_File_Mapping__mdt> mappingRecordList = mappingRecordByLabelMap.get(parentTagName);
		for(Poland_Invoices_File_Mapping__mdt item : mappingRecordList){
			if(String.isNotBlank(item.SFDC_Field_Name__c)){
				fieldNameSet.add(item.SFDC_Field_Name__c);
			}
		}
		return fieldNameSet;
	}
    
    private String addNode(String tagName, String value){
		return '<' + tagName + '>' + value + '</' + tagName + '>';
	}
	
    private String addNodeWithAttributes(String tagName, String value, Map<String, String> mapOfAttributesAndValue){  	
    	String str = '<' +  tagName;
        
        for(String key : mapOfAttributesAndValue.keySet()){
    		str += ' ' + key + '="' + mapOfAttributesAndValue.get(key) + '"';
    	}  
    	str += '>' + value + '</' + tagName + '>'; 
        return str;
    }
    
    public void getFieldMapping(){
		mappingList = new List<Poland_Invoices_File_Mapping__mdt>();          
		if(mappingList.isEmpty()){
			mappingList = [
				SELECT	
						Id,
						DeveloperName,
						MasterLabel,
						Default_Value__c,
						Object_Name__c,
						SFDC_Field_Name__c,
						Tag_Name__c,
						Attribute_Name__c ,
						Attribute_Value__c,
						Namespace__c
				FROM	Poland_Invoices_File_Mapping__mdt
				LIMIT	1000
			];
		}
	}

	private void sortFieldMapping(List<Poland_Invoices_File_Mapping__mdt> unsortedList){
		mappingRecordByLabelMap = new Map<String, List<Poland_Invoices_File_Mapping__mdt>>();
		mappingRecordByDeveloperNameMap = new Map<String, Poland_Invoices_File_Mapping__mdt>();
		if(unsortedList != null && !unsortedList.isEmpty()){
			for(Poland_Invoices_File_Mapping__mdt item : unsortedList){
				if(mappingRecordByLabelMap.get(item.MasterLabel) == null){
					mappingRecordByLabelMap.put(item.MasterLabel, new List<Poland_Invoices_File_Mapping__mdt>{item});
				}else{
					mappingRecordByLabelMap.get(item.MasterLabel).add(item);
				}
				mappingRecordByDeveloperNameMap.put(item.DeveloperName, item);
			}
        }else{
            throw new MissingCustomMDTMappingsException('Error: Cannot find mappings for Custom MDT Poland_Invoices_File_Mapping__mdt!');
        }
	}

	public class MissingCustomMDTMappingsException extends Exception{}
	public class CustomException extends Exception{}
}
