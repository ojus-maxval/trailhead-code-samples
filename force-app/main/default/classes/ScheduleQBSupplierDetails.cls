public class ScheduleQBSupplierDetails implements Schedulable{
 public void execute(SchedulableContext sc)
 {
     BatchQBSupplierDetails SupDetails =new BatchQBSupplierDetails();
     database.executeBatch(SupDetails, 200);
 }
}