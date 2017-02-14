global class Address {
	public Customer_Address__c custAddress{ get; set; }
	public String customerName{ get; set; }
	public List<Accounts> accList {get; set; }
    public boolean ExceedsAddressLimit{get;set;}
    public boolean hasNext{get;set;}
}