global with sharing class PropertyEventForStandardEventController {
	
	public Property_Events__c propertyEventInput{get;set;}
	public List<SelectOption> typeDD{get;set;}
	public List<SelectOption> billingTypeDD{get;set;}
	public List<SelectOption> propertyLifecycleDD{get;set;}
	public List<SelectOption> sponsorDD{get;set;}
	public List<SelectOption> retentionReasonDD{get;set;}
	public List<SelectOption> statusDD{get;set;}
	public List<SelectOption> salesChannelDD{get;set;}
	public String eventId{get;set;}
	
	public PropertyEventForStandardEventController(ApexPages.StandardController stdController){
        //Getting EventId from controller.
        eventId = stdController.getRecord().id;
        propertyEventInput = new Property_Events__c();
    }
    
    public List<SelectOption> getSagarika(){
        List<SelectOption> typeDD = new List<SelectOption>(); 
		Schema.DescribeFieldResult fieldResult = Property_Events__c.Type__c.getDescribe();
        List<Schema.PicklistEntry> picklistValues = fieldResult.getPicklistValues();
        SelectOption option = null;
        for(Schema.PicklistEntry entry : picklistValues)
        {
          option = new SelectOption(entry.getValue(), entry.getValue());
          typeDD.add(option); 
        }
        return typeDD;
    }
	
	  public void initializeData(){
      try{
       	
       	typeDD = new List<SelectOption>(); 
		Schema.DescribeFieldResult fieldResult = Property_Events__c.Type__c.getDescribe();
        List<Schema.PicklistEntry> picklistValues = fieldResult.getPicklistValues();
        SelectOption option = null;
        for(Schema.PicklistEntry entry : picklistValues)
        {
          option = new SelectOption(entry.getValue(), entry.getValue());
          typeDD.add(option); 
        }
        this.typeDD = typeDD;

       	billingTypeDD = new List<SelectOption>(); 
		fieldResult = Property_Events__c.Billing_Type__c.getDescribe();
        picklistValues = fieldResult.getPicklistValues();
        for(Schema.PicklistEntry entry : picklistValues)
        {
          option = new SelectOption(entry.getValue(), entry.getValue());
          billingTypeDD.add(option);
        }
        this.billingTypeDD =  billingTypeDD;
    
        propertyLifecycleDD = new List<SelectOption>(); 
		fieldResult = Property_Events__c.Property_Life_cycle__c.getDescribe();
        picklistValues = fieldResult.getPicklistValues();
        for(Schema.PicklistEntry entry : picklistValues)
        {
          option = new SelectOption(entry.getValue(), entry.getValue());	
          propertyLifecycleDD.add(option);
        }
        this.propertyLifecycleDD =  propertyLifecycleDD;
    
        sponsorDD = new List<SelectOption>(); 
		fieldResult = Property_Events__c.Sponsor__c.getDescribe();
        picklistValues = fieldResult.getPicklistValues();
        for(Schema.PicklistEntry entry : picklistValues)
        {
          option = new SelectOption(entry.getValue(), entry.getValue());
          sponsorDD.add(option);
        }
        this.sponsorDD =  sponsorDD;
    
        retentionReasonDD = new List<SelectOption>(); 
		fieldResult = Property_Events__c.Retention_Reason__c.getDescribe();
        picklistValues = fieldResult.getPicklistValues();
        for(Schema.PicklistEntry entry : picklistValues)
        {
          option = new SelectOption(entry.getValue(), entry.getValue());
          retentionReasonDD.add(option);
        }
        this.retentionReasonDD =  retentionReasonDD;
        
    	statusDD = new List<SelectOption>(); 
		fieldResult = Property_Events__c.Status__c.getDescribe();
        picklistValues = fieldResult.getPicklistValues();
        for(Schema.PicklistEntry entry : picklistValues)
        { 
          option = new SelectOption(entry.getValue(), entry.getValue());
          statusDD.add(option);
        }
        this.statusDD =  statusDD;
    
    	salesChannelDD = new List<SelectOption>(); 
		fieldResult = Property_Events__c.Sales_Channel__c.getDescribe();
        picklistValues = fieldResult.getPicklistValues();
        for(Schema.PicklistEntry entry : picklistValues)
        {
          option = new SelectOption(entry.getValue(), entry.getValue());
          salesChannelDD.add(option);
        }
        this.salesChannelDD =  salesChannelDD;
    
    }catch(Exception ex){
      ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,Label.PESomeThingWentWrong));
      } 
    }
    
    
}