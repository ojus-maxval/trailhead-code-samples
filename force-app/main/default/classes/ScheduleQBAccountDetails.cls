public class ScheduleQBAccountDetails implements Schedulable{
 public void execute(SchedulableContext sc)
 {
     BatchQBAccountDetails AccDetails =new BatchQBAccountDetails();
     database.executeBatch(AccDetails, 200);
 }
}