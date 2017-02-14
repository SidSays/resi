global class Accounts {
public Account custAccount { get; set;}

List<Orders> orderList;

 public void setorderList(List<Orders> ordList) { 
        orderList = ordList;
    }

}