/**
 * Decorator Class for RGU Orders and Activations Chart
 *
 * @author Radhika Bansal
 * @date 28/April/2016
 */
public class IndirectOrdersChart {

@AuraEnabled
  public static Integer SeventhDayOrderCount {get;  set;}
@AuraEnabled
    public static Integer SeventhDayActivationCount {get;  set;}
  @AuraEnabled
    public static Integer SixthDayOrderCount {get;  set;}
  @AuraEnabled
    public static Integer SixthDayActivationCount {get;  set;}
  @AuraEnabled
    public  Integer FifthDayOrderCount {get;  set;}
  @AuraEnabled
    public  Integer FifthDayActivationCount {get;  set;}
  @AuraEnabled
    public static Integer FourthDayOrderCount {get;  set;}
  @AuraEnabled
    public static Integer FourthDayActivationCount {get;  set;}
  @AuraEnabled
    public static Integer ThirdDayOrderCount {get;  set;}
  @AuraEnabled
    public static Integer ThirdDayActivationCount {get;  set;}
  @AuraEnabled
    public static Integer SecondDayOrderCount {get;  set;}
  @AuraEnabled
    public static Integer SecondDayActivationCount {get;  set;}
  @AuraEnabled
    public static Integer FirstDayOrderCount {get;  set;}
  @AuraEnabled
    public  Integer FirstDayActivationCount {get; set;}
  @AuraEnabled
  public  String ACTIVITY_STATUS = 'Activated';


    public  IndirectOrdersChart(List<RGU_Order__c> orders) {    
    SeventhDayOrderCount = 0;
    SeventhDayActivationCount = 0;
    SixthDayOrderCount = 0;
    SixthDayActivationCount = 0;
    FifthDayOrderCount = 0;
    FifthDayActivationCount = 0;
    FourthDayOrderCount = 0;
    FourthDayActivationCount = 0;
    ThirdDayOrderCount = 0;
    ThirdDayActivationCount = 0;
    SecondDayOrderCount = 0;
    SecondDayActivationCount = 0;
    FirstDayOrderCount = 0;
    FirstDayActivationCount = 0;

    List<Date> dateList = pastSevenDaysList();

    for (RGU_Order__c order : orders) {
      //count Orders
      if (order.Order_Date__c == dateList.get(6)){
        SeventhDayOrderCount ++;
      }
      else if (order.Order_Date__c == dateList.get(5)) {
        SixthDayOrderCount ++;
      }
      else if (order.Order_Date__c == dateList.get(4)) {
        this.FifthDayOrderCount ++;
      }
      else if (order.Order_Date__c == dateList.get(3)) {
        FourthDayOrderCount ++;
      }
      else if (order.Order_Date__c == dateList.get(2)) {
        ThirdDayOrderCount ++;
      }
      else if (order.Order_Date__c == dateList.get(1)) {
        SecondDayOrderCount ++;
      }
      else if (order.Order_Date__c == dateList.get(0)) {
        FirstDayOrderCount ++;
      }

      //count Activations
      if (isOrderActivated(order) && order.Activation_Date__c == dateList.get(6)){
        SeventhDayActivationCount ++;
      }
      else if (isOrderActivated(order) && order.Activation_Date__c == dateList.get(5)) {
        SixthDayActivationCount ++;
      }
      else if (isOrderActivated(order) && order.Activation_Date__c == dateList.get(4)) {
        this.FifthDayActivationCount ++;
      }
      else if (isOrderActivated(order) && order.Activation_Date__c == dateList.get(3)) {
        FourthDayActivationCount ++;
      }
      else if (isOrderActivated(order) && order.Activation_Date__c == dateList.get(2)) {
        ThirdDayActivationCount ++;
      }
      else if (isOrderActivated(order) && order.Activation_Date__c == dateList.get(1)) {
        SecondDayActivationCount ++;
      }
      else if (isOrderActivated(order) && order.Activation_Date__c == dateList.get(0)) {
        FirstDayActivationCount ++;
      }
    }

  }

  @AuraEnabled
    public static List<Date> pastSevenDaysList() {
    List<Date> dateList = new List<Date>();
    for (Integer i = 1; i < 8; i++) {
      dateList.add(Date.today().addDays(-i));
    }
    System.debug('>>>>dateList'+dateList);
    return dateList;
  }

  @AuraEnabled
  public static Boolean isOrderActivated(RGU_Order__c order) {
    return order.Activity_Status__c == 'Activated';
  }


}