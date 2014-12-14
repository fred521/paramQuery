global class OppForecastRemoteObject {



	public String id;
	//for specific column
	public String groupNameLabel;

	public String groupColumnName;

	public Integer countNumber;

	public String groupSubTitle;
	
	public String opportunityName;

	public String contractManufacturer;

	public String distributor;

	public String endCustomerAccount;

	public String product;

	public String marketSegment;

	public String projectName;

	public String values;

	public String recordType;

	public String getRecordType() {
		return recordType;
	}

	public void setRecordType(String recordType) {
		this.recordType = recordType;
	}

	public Integer getCountNumber() {
		return countNumber;
	}

	public void setCountNumber(Integer countNumber) {
		this.countNumber = countNumber;
	}

	public String getGroupSubTitle() {
		return groupSubTitle;
	}

	public void setGroupSubTitle(String groupSubTitle) {
		this.groupSubTitle = groupSubTitle;
	}
	public String getGroupColumnName() {
		return groupColumnName;
	}

	public void setGroupColumnName(String groupColumnName) {
		this.groupColumnName = groupColumnName;
	}


	public String getGroupNameLabel() {
		return groupNameLabel;
	}

	public void setGroupNameLabel(String groupNameLabel) {
		this.groupNameLabel = groupNameLabel;
	}

	public String getMarketSegment() {
		return marketSegment;
	}

	public void setMarketSegment(String marketSegment) {
		this.marketSegment = marketSegment;
	}

	public String getProjectName() {
		return projectName;
	}

	public void setProjectName(String projectName) {
		this.projectName = projectName;
	}

	public String getValues() {
		return values;
	}

	public void setValues(String values) {
		this.values = values;
	}

	public List<OpportunityForecastLineItem__c> opportunityForecastLineItems;

	public Map<String, OpportunityForecastLineItem__c> monthYear;

	public String getId() {
		return id;
	}

	public void setId(String id) {
		this.id = id;
	}

	public Map<String, OpportunityForecastLineItem__c> getMonthYear() {
		return monthYear;
	}

	public void setMonthYear(Map<String, OpportunityForecastLineItem__c> monthYear) {
		this.monthYear = monthYear;
	}

	public String getOpportunityName() {
		return opportunityName;
	}

	public void setOpportunityName(String opportunityName) {
		this.opportunityName = opportunityName;
	}

	public String getContractManufacturer() {
		return contractManufacturer;
	}

	public void setContractManufacturer(String contractManufacturer) {
		this.contractManufacturer = contractManufacturer;
	}

	public String getDistributor() {
		return distributor;
	}

	public void setDistributor(String distributor) {
		this.distributor = distributor;
	}

	public String getEndCustomerAccount() {
		return endCustomerAccount;
	}

	public void setEndCustomerAccount(String endCustomerAccount) {
		this.endCustomerAccount = endCustomerAccount;
	}

	public String getProduct() {
		return product;
	}

	public void setProduct(String product) {
		this.product = product;
	}

	public List<OpportunityForecastLineItem__c> getOpportunityForecastLineItems() {
		return opportunityForecastLineItems;
	}

	public void setOpportunityForecastLineItems(
			List<OpportunityForecastLineItem__c> opportunityForecastLineItems) {
		this.opportunityForecastLineItems = opportunityForecastLineItems;
	}


}