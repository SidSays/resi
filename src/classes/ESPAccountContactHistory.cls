global class ESPAccountContactHistory
{
    public String billingAccountNumber;
    public String customerStatus;
    public String lastInstallDate;
    public String balance;
    public String monthlyRateTotal;
    public String installationStatus;
    public String disconnectedDate;
    public String writeOffAmount;    
    public String accountName;
    public String FirstName;
    public String LastName;
    Public List<Email> eMail;  
    Public List<Phone> phone;
    public string error;
      
    global class Email{
                 public String emailContactType;
                 public String email;
                 }
    global class Phone{
                 public String contactType;
                 public List<Telephone> telephoneNumber;
                 }
     global class Telephone{
                 public String areaCode;
                 public String phoneNumber;
                 public String extension;
                 }
}