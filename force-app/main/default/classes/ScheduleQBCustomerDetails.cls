public class ScheduleQBCustomerDetails implements Schedulable{
    
 public void execute(SchedulableContext sc)
 {
     BatchQBCustomerDetails CustDetails =new BatchQBCustomerDetails();
     database.executeBatch(CustDetails, 200);
 }
}