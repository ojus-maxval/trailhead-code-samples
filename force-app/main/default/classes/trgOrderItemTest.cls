@isTest
public class trgOrderItemTest {
    
    @testSetup static void setup() {
        
        //usr.Profile.Name = 'ADU';
        //usr.Is_ADU_Manager__c = true;
        //update usr;
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
        candor.PoNumber__c = 'ABC1';
        candor.Payment_Status__c = 'Waiting to Invoice';
        //candor.Is_Renewed_Externally__c = false;
        //candor.Invoice__c = null;
        candor.Payment_Received_from_Client__c = false;
        candor.Send_for_approval_to_pay_PTO_fee__c = true;
        candor.Renewal_Instruction__c = 'Renew';
        candor.Is_PTO_Fee_Paid__c = false;
        
        insert candor;
        system.debug('OI 1: '+ candor);
        candior.add(new Order_Item__c(Order__c = cand.Id, Amount__c = 100, PoNumber__c = 'ABC1' ));
        insert candior;
        
       
        
        
        
        /*candor.Order__c = cand.Id;
candor.Amount__c = 101;
candior.add(new Order_Item__c(Order__c = cand.Id, Amount__c = 101));
upsert candior;*/
        
    }
    
    @isTest public static void TestMethod1()
    { 
        test.startTest();
        
        List<Order__c> cand = [SELECT Client__c FROM Order__c];
            
        /* Invoice__c inv = new Invoice__c();
         Inv.Invoice_Amount__c = 2000.0;
            Inv.Order__c = cand[0].id;
            Inv.Invoice_Currency__c ='USD';
        insert inv; */
        
            List<Order_Item__c> candor = [SELECT Order__c, Amount__c, PoNumber__c, Payment_Status__c, Payment_Received_from_Client__c,Send_for_approval_to_pay_PTO_fee__c,Renewal_Instruction__c, Is_PTO_Fee_Paid__c  FROM Order_Item__c WHERE Amount__c = 100];
            for(Order_Item__c obj : candor )
            {
                obj.Payment_Status__c = 'Payment Requested';
                obj.PoNumber__c = 'ABC2';
                obj.Amount__c = 101;
                obj.Is_PTO_Fee_Paid__c = true;
                //obj.Is_Renewed_Externally__c = true;
              //  obj.Invoice__c = inv.Id;
            }
            if(candor.size() > 0)
            {
                update candor;
            }
            system.debug('Update OI: '+candor);
            test.stopTest();
         System.assertEquals('Payment Requested', candor[0].Payment_Status__c);
         System.assertEquals('ABC2', candor[0].PoNumber__c);
         System.assertEquals(101, candor[0].Amount__c);
       // System.assertEquals(true, candor[0].Is_Renewed_Externally__c);
           // System.assertEquals(inv.Id, candor[0].Invoice__c);
           System.assertEquals(true, candor[0].Is_PTO_Fee_Paid__c);
           
        
    }
}