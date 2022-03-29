@isTest public class BatchQueueHelperTest {
@isTest public static void CreateBatchQueueForOrderPlacedTest()
{
    
    
    API_Credentials__c ObjAPI11 = new API_Credentials__c();
    ObjAPI11.Password__c ='Test@1234';
    ObjAPI11.Username__c ='MaxvalAPI';
    ObjAPI11.Name = 'PTO Payment File';
    ObjAPI11.URL__c ='https://login.salesforce.com/services/oauth2/token';
        insert ObjAPI11;
    
    API_Credentials__c ObjAPI1 = new API_Credentials__c();
    ObjAPI1.Password__c ='Test@1234';
    ObjAPI1.Username__c ='MaxvalAPI';
    ObjAPI1.Name = 'PTO Payment Validate';
    ObjAPI1.URL__c ='https://login.salesforce.com/services/oauth2/token';
    insert ObjAPI1;
    
    Set<Id > ClList =new Set<Id>();
    Clients__c  Cl =new Clients__c ();
    Cl.Client_Name__c = 'Test Status';
    Insert Cl;
    ClList.add(Cl.id);
   
    List<Id> ListOrd =new List<Id>();
    Set<Id > OrdSet =new Set<Id>();
    Order__c  Ord =new Order__c ();
    Ord.Client__c =Cl.id;
    Insert Ord;
    OrdSet.add(Ord.id);
    ListOrd.add(Ord.id);
    
    Payment__c PY =new Payment__c ();
    PY.Payment_Amount__c =5800.0;
    Insert PY;
    
    Order_Item__c OI =new Order_Item__c();
    OI.Order__c =Ord.Id;
    OI.Payment__c =PY.id;
    OI.Due_Date__c = System.today();
    OI.Instructed_Date__c = System.today() + 5;
    Insert OI;
    List<Order_Item__c> OIList =new List<Order_Item__c>();
    OIList.add(OI);
    
    
    Batch_Queue__c objBatchQueue = new Batch_Queue__c();
    objBatchQueue.Name = 'Order Placed Mail Alert';
    objBatchQueue.Parent_Id__c = Cl.id;
    objBatchQueue.Status__c = 'To Do';
    INSERT objBatchQueue;
    
    Currency__c cur = new Currency__c();
    cur.Name = 'USD';
    Insert cur;
    
    Payment_Schedule__c payS = new Payment_Schedule__c();
    payS.Jurisdiction__c = 'US';
    payS.Payment_Mode__c = 'Credit Card';
    Insert payS;
    
    BatchQueueHelper.CreateBatchQueueForOrderPlaced(ClList);
    BatchQueueHelper.CreateBatchQueueForOrderReceived(OrdSet);
     BatchQueueHelper.CreateBatchQueueForOrderItem(OIList);
      BatchQueueHelper.CreateBatchQueueForInvoiceGeneration(ListOrd);
    BatchQueueHelper.CreateBatchQueueForRecordPayment(OIList,OIList);
     BatchQueueHelper.BatchQueueForOrderItemForPTOvalidation(ClList);
     BatchQueueHelper.ForOrderItemForPTOvalidationDocument(ClList);

}
}