@isTest
public class trgOrderItemTest {
    
    @testSetup static void setup() {
       
        String UserId = UserInfo.getUserId();
        User usr = [select id, Is_ADU_Manager__c, Profile.Name from User where id =: UserId];
        
    usr.Profile.Name = 'ADU';
    usr.Is_ADU_Manager__c = true;
    update usr;
        //System.assertEquals('ADU', usr.Profile.Name);
   //System.assertEquals(true, usr.Is_ADU_Manager__c);
        
        List<Clients__c> testC = new List<Clients__c>();
        Clients__c clients = new Clients__c();
        insert clients;
        testC.add(new Clients__c());
        
        List<Order__c> testCand = new List<Order__c>();
       	
        	Order__c cand = new Order__c();
        	cand.Client__c = clients.Id;
        insert cand;
            testCand.add(new Order__c(Client__c = clients.Id));
        
        insert testCand;  
        
        List<Order_Item__c> candior = new List<Order_Item__c>();
        Order_Item__c candor = new Order_Item__c();
        candor.Order__c = cand.Id;
        candor.Amount__c = 100;
        insert candor;
        candior.add(new Order_Item__c(Order__c = cand.Id, Amount__c = 100 ));
        insert candior;
        
        /*candor.Order__c = cand.Id;
        candor.Amount__c = 101;
        candior.add(new Order_Item__c(Order__c = cand.Id, Amount__c = 101));
        upsert candior;*/
      
    }
    
@isTest public static void TestMethod1()
{
    String UserId = UserInfo.getUserId();
        User usr = [select id, Is_ADU_Manager__c, Profile.Name from User where id =: UserId];
        
    System.runAs(usr) {
     test.startTest();
    
    List<Order_Item__c> candor = [SELECT Order__c, Amount__c FROM Order_Item__c WHERE Amount__c = 100];
     for(Order_Item__c obj : candor )
        {
            obj.Amount__c = 101;
        }
        if(candor.size() > 0)
        {
            update candor;
        }
    
    /**/
        test.stopTest();
    //System.assertEquals(101, Order_Item__r.Amount__c);
    }
}
}