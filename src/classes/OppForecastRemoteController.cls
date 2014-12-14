/*****************************************************************************
 * Description : This is a global controller leveraged by Visual Force Page/Component for Opportunity Forecaset management
 *				
 * Author      : Fred Dai (Perficient)
 * Date        : 11/18/2014
 * Version     : 1.0
 *
 * Version History : 
 * 
 *****************************************************************************/
@RestResource(urlMapping='/OppForecast/*')
global class  OppForecastRemoteController {

      public static final Integer NINETHEEN_MONTHS = 19;

      public static List<String> allMonths;

      public static final String ASP_TYPE = 'asp';

      public static final String KU_TYPE = 'ku';

      public static final String REVENUE_TYPE = 'revenue';

      public static final String ASP_LABEL = 'ASP:';
      public static final String KU_LABEL = 'KU:';
      public static final String REVENUE_LABEL = 'Revenue:';

	@RemoteAction
	global static List<OpportunityForecast__c> getOppForecasts() {
		return [Select Id,
                               Name,
                               ContractManufacturerAccountId__c, 
                               ContractManufacturerAccountId__r.Name, 
                               DistributorAccountId__c, 
                               DistributorAccountId__r.Name, 
                               EndCustomerAccountId__c, 
                               EndCustomerAccountId__r.Name, 
                               OpportunityId__c, 
                               OpportunityId__r.Name,
                               Product2__c, 
                               (Select ASP__c, KU__c, MonthYear__c, OpportunityForecastId__c, Name, Id, Revenue__c from OpportunityForecastLineItems__r) 
                               from OpportunityForecast__c];
	}

      @RemoteAction
      global static List<String> getMonthYears(String month, String year){
            if(month == null || year == null) {
                  return getAllMonths();
            }
            List<String> filterMonths = new List<String>();
            boolean needToAdd = false;
            for(String tempMonth: getAllMonths()) {
                  if(tempMonth.substring(0,3).equals(month) && tempMonth.substring(3).equals(year)){
                        needToAdd = true;
                  }
                  if(needToAdd) {
                        filterMonths.add(tempMonth);
                  }
            }
            return filterMonths;
      }

      /**
       * mass save/update 
       */
      @RemoteAction
      global static List<OppForecastRemoteObject> updateOppForecastLineItems(String jsonUpdateString, String month, String year) {
          Map<String, OpportunityForecastLineItem__c> updateMap = new Map<String, OpportunityForecastLineItem__c>();
          Set<String> monthSet = getMonthYearSet(month, year);

          System.debug('input json string is .... :' + jsonUpdateString);
          Map<String, Object> objectMap = (Map<String, Object>) JSON.deserializeUntyped(jsonUpdateString);
          System.debug('Json map strucuture is ... :' + objectMap);
          List<Object> objectList = (List<Object>) objectMap.get('rowList');
          Set<String> forecasetIdSet = new Set<String> ();

          for(Object eachObject: objectList){
            System.debug('each object is ' + JSON.serialize(eachObject));
            String jsonObjectString = JSON.serialize(eachObject);
            Map<String, Object> resultObjectMap = (Map<String, Object>) JSON.deserializeUntyped(jsonObjectString);
            for(String selectedMonth: monthSet){
              if(resultObjectMap.get(selectedMonth) != null){
                String selectedCellValue = String.valueOf(resultObjectMap.get(selectedMonth));
                String valueType = String.ValueOf(resultObjectMap.get('recordType'));
                Map<String, Object> selectedLineItem = (Map<String, Object>) convertObject2Map(resultObjectMap.get('monthYear'));
                //ku, asp ...
                Map<String, Object> selectedLineItemType = (Map<String, Object>) convertObject2Map(selectedLineItem.get(selectedMonth));
                String targetId = String.valueOf(selectedLineItemType.get('Id'));
                String parentId = String.valueOf(selectedLineItemType.get('OpportunityForecastId__c'));
                forecasetIdSet.add(parentId);
                OpportunityForecastLineItem__c updateItem = new OpportunityForecastLineItem__c();
                if(updateMap.get(targetId) == null){
                   updateItem.id = targetId;
                      setValueByType(updateItem, selectedCellValue, valueType);
                }else{
                  updateItem = updateMap.get(targetId);
                      setValueByType(updateItem, selectedCellValue, valueType);
                }
                updateMap.put(targetId, updateItem);
              }
            }

           if(!updateMap.isEmpty()) {
            try{
              update updateMap.values();
            }catch(DmlException e) {
              System.debug(e.getCause());
            }
          }
        }
          return getRemoteObjects(forecasetIdSet, month, year);
      }

      private static void setValueByType(OpportunityForecastLineItem__c updateItem, String selectedCellValue, String valueType){
         if(valueType == 'asp'){
          updateItem.ASP__c = Decimal.valueOf(selectedCellValue);
         }else if(valueType == 'ku'){
          updateItem.KU__c = Decimal.valueOf(selectedCellValue);
         }
      }

      private static List<OppForecastRemoteObject> getRemoteObjects(Set<String> forecasetIdSet, String month, String year){
        Set<String> monthSet = getMonthYearSet(month, year);
        List<OppForecastRemoteObject> remoteObjects = new List<OppForecastRemoteObject>();
        if(!forecasetIdSet.isEmpty()) {
          List<Opportunityforecast__c> oppForecasts = [Select Id, Name, ContractManufacturerAccountId__c, ContractManufacturerAccountId__r.Name, DistributorAccountId__c, 
                                  DistributorAccountId__r.Name, EndCustomerAccountId__c, EndCustomerAccountId__r.Name, OpportunityId__c, 
                                  OpportunityId__r.Name, Product2__c, Product2__r.Name, Market_Segment__c, Project__c, 
                                  (Select ASP__c, KU__c, MonthYear__c, OpportunityForecastId__c, Name, Id, Revenue__c from OpportunityForecastLineItems__r) 
                                  from OpportunityForecast__c where Id IN: forecasetIdSet];
          
          for(OpportunityForecast__c opportunityForecast : oppForecasts) {
                  //first one is for ku
                  OppForecastRemoteObject remoteObject = new OppForecastRemoteObject();
                  remoteObject.setId(opportunityForecast.id);
                  remoteObject.setDistributor(opportunityForecast.DistributorAccountId__r.Name);
                  remoteObject.setEndCustomerAccount(opportunityForecast.EndCustomerAccountId__r.Name);
                  remoteObject.setContractManufacturer(opportunityForecast.ContractManufacturerAccountId__r.Name);
                  remoteObject.setProduct(opportunityForecast.Product2__r.Name);
                  remoteObject.setProjectName(opportunityForecast.Project__c);
                  remoteObject.setMarketSegment(opportunityForecast.Market_Segment__c);
                  remoteObject.setRecordType(ASP_TYPE);
                  remoteObject.setValues(REVENUE_LABEL);
            Map<String, OpportunityForecastLineItem__c> itemMap = new Map<String, OpportunityForecastLineItem__c>();
            if(opportunityForecast.OpportunityForecastLineItems__r != null) {
                for(OpportunityForecastLineItem__c item : opportunityForecast.OpportunityForecastLineItems__r) {
                        if(monthSet != null && !monthSet.isEmpty() && monthSet.contains(item.MonthYear__c)) {
                              itemMap.put(item.MonthYear__c, item);
                        }
                }
                remoteObject.setMonthYear(itemMap);
            }
            //asp end
            remoteObjects.add(remoteObject);
            //ku
            OppForecastRemoteObject kuRemoteObject = new OppForecastRemoteObject();
            kuRemoteObject.setRecordType(KU_TYPE);
            kuRemoteObject.setValues(KU_LABEL);
            kuRemoteObject.setMonthYear(itemMap);
            remoteObjects.add(kuRemoteObject);
            //revenue
            OppForecastRemoteObject revenueRemoteObject = new OppForecastRemoteObject();
            revenueRemoteObject.setRecordType(REVENUE_TYPE);
            revenueRemoteObject.setValues(REVENUE_LABEL);
            revenueRemoteObject.setMonthYear(itemMap);
            remoteObjects.add(revenueRemoteObject);
        }
        
        }
        return remoteObjects;
      }

      private static Map<String, Object> convertObject2Map(Object inputObject){
          return (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(inputObject));
      }

      @RemoteAction
      global static OpportunityForecastLineItem__c updateOppForecastLineItem(String value, String type, String oppForecastLineItemId) {
            if(oppForecastLineItemId == null) {
                  return null;
            }
            OpportunityForecastLineItem__c item;
            if(type == ASP_TYPE) {
                  item = new OpportunityForecastLineItem__c(Id = oppForecastLineItemId, ASP__c = Decimal.valueOf(value));
                  update item;
            }
            if(type == KU_TYPE) {
                  item = new OpportunityForecastLineItem__c(Id = oppForecastLineItemId, KU__c = Decimal.valueOf(value));
                  update item;     
            }
            item = [Select Id, ASP__c, KU__c, Revenue__c FROM OpportunityForecastLineItem__c where Id =: oppForecastLineItemId limit 1];
            return item;
      }

      public static Set<String> getMonthYearSet(String month, String year) {
            if(month == null || year == null) {
                  return null;
            }
            Set<String> filterMonthSet = new Set<String>();
            boolean needToAdd = false;
            for(String tempMonth: getAllMonths()) {
                  if(tempMonth.substring(0,3).equals(month) && tempMonth.substring(3).equals(year)){
                        needToAdd = true;
                  }
                  if(needToAdd) {
                        filterMonthSet.add(tempMonth);
                  }
            }
            return filterMonthSet;  
      }
      /**
       * using pro version of pggrid to search data from db
       * it is supported functions below:
       * copy & paste;
       * multiple grouping;
       * sorting;
       * pagination;
       *                 
       */
      @RemoteAction
      global static List<OppForecastRemoteObject> searchOppForecast(String oppId, String groupColumn, String month, String year) {
            Set<String> monthSet = getMonthYearSet(month, year);
            List<OpportunityForecast__c> oppForecasts = new List<OpportunityForecast__c>();
            String query = 'Select Id, Name, ContractManufacturerAccountId__c, ContractManufacturerAccountId__r.Name, DistributorAccountId__c, ' +
                                  'DistributorAccountId__r.Name, EndCustomerAccountId__c, EndCustomerAccountId__r.Name, OpportunityId__c, ' +
                                  'OpportunityId__r.Name, Product2__c, Product2__r.Name, Market_Segment__c, Project__c, ' +
                                  '(Select ASP__c, KU__c, MonthYear__c, OpportunityForecastId__c, Name, Id, Revenue__c from OpportunityForecastLineItems__r) ' +
                                  'from OpportunityForecast__c where Id != null ';
                   if(oppId != null && oppId.trim() != ''){
                        query +=' and OpportunityId__c =' + '\'' + oppId + '\'';
                   }       
                   System.debug('The running query is ...' + query);
                   oppForecasts = Database.query(query);


            List<OppForecastRemoteObject> remoteObjects = new List<OppForecastRemoteObject>();
            OppForecastRemoteObject remoteObjectTitle = new OppForecastRemoteObject();
            for(OpportunityForecast__c opportunityForecast : oppForecasts) {
                  //first one is for asp
                  String groupName =  opportunityForecast.EndCustomerAccountId__r.Name + '        ' +opportunityForecast.id ;
                  OppForecastRemoteObject remoteObject = new OppForecastRemoteObject();
                  remoteObject.setId(groupName);
                  remoteObject.setDistributor(opportunityForecast.DistributorAccountId__r.Name);
                  remoteObject.setEndCustomerAccount(opportunityForecast.EndCustomerAccountId__r.Name);
                  remoteObject.setContractManufacturer(opportunityForecast.ContractManufacturerAccountId__r.Name);
                  remoteObject.setProduct(opportunityForecast.Product2__r.Name);
                  remoteObject.setProjectName(opportunityForecast.Project__c);
                  remoteObject.setMarketSegment(opportunityForecast.Market_Segment__c);
                  remoteObject.setRecordType(ASP_TYPE);
                  remoteObject.setValues(ASP_LABEL);
            Map<String, OpportunityForecastLineItem__c> itemMap = new Map<String, OpportunityForecastLineItem__c>();
            if(opportunityForecast.OpportunityForecastLineItems__r != null) {
                for(OpportunityForecastLineItem__c item : opportunityForecast.OpportunityForecastLineItems__r) {
                        if(monthSet != null && !monthSet.isEmpty() && monthSet.contains(item.MonthYear__c)) {
                              itemMap.put(item.MonthYear__c, item);
                        }
                }
                remoteObject.setMonthYear(itemMap);
            }
            //asp end
            remoteObjects.add(remoteObject);
            //ku
            OppForecastRemoteObject kuRemoteObject = new OppForecastRemoteObject();
            kuRemoteObject.setRecordType(KU_TYPE);
            kuRemoteObject.setId(groupName);
            kuRemoteObject.setValues(KU_LABEL);
            kuRemoteObject.setMonthYear(itemMap);
            remoteObjects.add(kuRemoteObject);

            //revenue
            OppForecastRemoteObject revenueRemoteObject = new OppForecastRemoteObject();
            revenueRemoteObject.setRecordType(REVENUE_TYPE);
            revenueRemoteObject.setValues(REVENUE_LABEL);
            revenueRemoteObject.setId(groupName);
            revenueRemoteObject.setMonthYear(itemMap);
            remoteObjects.add(revenueRemoteObject);
        }
        return remoteObjects;
      }

      /**
       * need to build up a dynamic soql query, now re-use the normal query first
       */
      @RemoteAction
      global static List<OppForecastRemoteObject> getOppForecastDataWithGroup(String oppId, String groupColumn, String month, String year) {
            if(groupColumn == null || groupColumn.trim() == '') {
                  return getOppForecastData(oppId,month, year);
            }
            AggregateResult[] groupedResults = aggregatOppForecastsByGroup(groupColumn, oppId);
            Set<String> monthSet = getMonthYearSet(month, year);
            Set<String> groupColumnSet = new Set<String>();
            List<OpportunityForecast__c> oppForecasts = new List<OpportunityForecast__c>();
            String query = 'Select Id, Name, ContractManufacturerAccountId__c, ContractManufacturerAccountId__r.Name, DistributorAccountId__c, ' +
                                  'DistributorAccountId__r.Name, EndCustomerAccountId__c, EndCustomerAccountId__r.Name, OpportunityId__c, ' +
                                  'OpportunityId__r.Name, Product2__c, Product2__r.Name, Market_Segment__c, Project__c, ' +
                                  '(Select ASP__c, KU__c, MonthYear__c, OpportunityForecastId__c, Name, Id, Revenue__c from OpportunityForecastLineItems__r) ' +
                                  'from OpportunityForecast__c where Id != null ';
                   if(oppId != null && oppId.trim() != ''){
                        query +=' and OpportunityId__c =' + '\'' + oppId + '\'';
                   }       
                   query +=' order by ' + groupColumn + ' desc ';
                   System.debug('The running query is ...' + query);
                   oppForecasts = Database.query(query);


            List<OppForecastRemoteObject> remoteObjects = new List<OppForecastRemoteObject>();
            OppForecastRemoteObject remoteObjectTitle = new OppForecastRemoteObject();
            for(OpportunityForecast__c opportunityForecast : oppForecasts) {
                  OppForecastRemoteObject remoteObject = new OppForecastRemoteObject();
                  String targetValue = mappingValue(groupColumn,opportunityForecast);
                  if(groupColumnSet != null && !groupColumnSet.contains(targetValue)) {
                        remoteObject.setGroupColumnName(targetValue);
                        for(AggregateResult groupedResult: groupedResults){
                              if(targetValue == groupedResult.get('Name')){
                                    remoteObject.setCountNumber(Integer.valueOf(groupedResult.get('expr0')));
                              }
                        }
                        groupColumnSet.add(targetValue);
                  }
                  remoteObject.setId(opportunityForecast.id);
                  remoteObject.setDistributor(opportunityForecast.DistributorAccountId__r.Name);
                  remoteObject.setEndCustomerAccount(opportunityForecast.EndCustomerAccountId__r.Name);
                  remoteObject.setContractManufacturer(opportunityForecast.ContractManufacturerAccountId__r.Name);
                  remoteObject.setProduct(opportunityForecast.Product2__r.Name);
                  remoteObject.setProjectName(opportunityForecast.Project__c);
                  remoteObject.setMarketSegment(opportunityForecast.Market_Segment__c);
            if(opportunityForecast.OpportunityForecastLineItems__r != null) {
                Map<String, OpportunityForecastLineItem__c> itemMap = new Map<String, OpportunityForecastLineItem__c>();
                for(OpportunityForecastLineItem__c item : opportunityForecast.OpportunityForecastLineItems__r) {
                        if(monthSet != null && !monthSet.isEmpty() && monthSet.contains(item.MonthYear__c)) {
                              itemMap.put(item.MonthYear__c, item);
                        }
                }
                remoteObject.setMonthYear(itemMap);
            }
            remoteObjects.add(remoteObject);
        }
        return remoteObjects;
      }
      // for dynamic group, need to set the value from the right fields
      public static String mappingValue(String selectGroup, OpportunityForecast__c opportunityForecast) {
            if(selectGroup == null || opportunityForecast == null) {
                  return null;
            }
            if(selectGroup == 'EndCustomerAccountId__r.Name'){
                  return opportunityForecast.EndCustomerAccountId__r.Name;
              }else if(selectGroup == 'Market_Segment__c'){
                  return opportunityForecast.Market_Segment__c;
              }else if(selectGroup == 'Project__c') {
                  return opportunityForecast.Project__c;
              }else if(selectGroup == 'Product2__r.Name') {
                  return opportunityForecast.Product2__r.Name;
              }else if(selectGroup == 'ContractManufacturerAccountId__r.Name'){
                  return opportunityForecast.ContractManufacturerAccountId__r.Name;
              }else if(selectGroup == 'DistributorAccountId__r.Name') {
                  return opportunityForecast.DistributorAccountId__r.Name;
              }
            return null;
      }
      /**
       * aggregate the the data/opportunityForecasts to have count number
       */
      public static AggregateResult[] aggregatOppForecastsByGroup(String groupColumn, String oppId){
            String query = ' select count(id),' + groupColumn + ' Name ' +
                           ' from opportunityforecast__c where id !=null ';
                  if(oppId != null && oppId.trim() != ''){
                        query +=' and OpportunityId__c =' + '\'' + oppId + '\'';
                   }
                   query += ' group by ' + groupColumn;

            AggregateResult[] groupedResults = Database.query(query);
            return groupedResults;
      }

      /**
       * web service call
       */
      
    @HttpGet
    global static String getMerchandiseById() {
        return 'test123';
    }

      /**
       * remote function will retreive the data from the remote call
       * using a remote object convert the entity to be paramQuery js plugin
       */
      @RemoteAction
      global static List<OppForecastRemoteObject> getOppForecastData(String oppId, String month, String year) {
            Set<String> monthSet = getMonthYearSet(month, year);
            List<OpportunityForecast__c> oppForecasts = new List<OpportunityForecast__c>();
            oppForecasts = [Select Id,
                               Name,
                               ContractManufacturerAccountId__c, 
                               ContractManufacturerAccountId__r.Name, 
                               DistributorAccountId__c, 
                               DistributorAccountId__r.Name, 
                               EndCustomerAccountId__c, 
                               EndCustomerAccountId__r.Name, 
                               OpportunityId__c, 
                               OpportunityId__r.Name,
                               Product2__c,
                               Product2__r.Name,
                               Market_Segment__c,
                               Project__c,
                               (Select ASP__c, KU__c, MonthYear__c, OpportunityForecastId__c, Name, Id, Revenue__c from OpportunityForecastLineItems__r) 
                               from OpportunityForecast__c where OpportunityId__c =:oppId order by createdDate desc];
            List<OppForecastRemoteObject> remoteObjects = new List<OppForecastRemoteObject>();
            for(OpportunityForecast__c opportunityForecast : oppForecasts) {
                  OppForecastRemoteObject remoteObject = new OppForecastRemoteObject();
                  remoteObject.setId(opportunityForecast.id);
                  remoteObject.setDistributor(opportunityForecast.DistributorAccountId__r.Name);
                  remoteObject.setEndCustomerAccount(opportunityForecast.EndCustomerAccountId__r.Name);
                  remoteObject.setContractManufacturer(opportunityForecast.ContractManufacturerAccountId__r.Name);
                  remoteObject.setProduct(opportunityForecast.Product2__r.Name);
                  remoteObject.setProjectName(opportunityForecast.Project__c);
                  remoteObject.setMarketSegment(opportunityForecast.Market_Segment__c);
                  remoteObject.setValues('Test');
            if(opportunityForecast.OpportunityForecastLineItems__r != null) {
                Map<String, OpportunityForecastLineItem__c> itemMap = new Map<String, OpportunityForecastLineItem__c>();
                for(OpportunityForecastLineItem__c item : opportunityForecast.OpportunityForecastLineItems__r) {
                        if(monthSet != null && !monthSet.isEmpty() && monthSet.contains(item.MonthYear__c)) {
                              itemMap.put(item.MonthYear__c, item);
                        }
                }
                remoteObject.setMonthYear(itemMap);
            }
            remoteObjects.add(remoteObject);
        }
        return remoteObjects;
      }

      public static List<String> getAllMonths(){
            if(allMonths == null){
                  allMonths = new List<String>();
                  Datetime now = Datetime.now();
                  for(Integer i=0; i<=NINETHEEN_MONTHS; i++) {
                        Datetime newTime = now.addMonths(i);
                        allMonths.add(newTime.format('MMMyyyy'));
                  }
            }
            return allMonths;
      }


}