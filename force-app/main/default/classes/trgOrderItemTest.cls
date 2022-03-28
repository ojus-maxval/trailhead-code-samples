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
        
        Payment__c pay = new Payment__c();
        pay.Name = 'Maxval123';
        insert pay;
        
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
        candor.Payment__c = pay.Id;
        candor.Payment_Approval_Status__c = 'Requested to Approve';
        candor.Is_send_to_Validate_with_PTO__c = false;
        candor.Is_it_renewed_in_PTO__c = false;
        candor.Filing_Receipt_File_Id__c = 'ID101';
        candor.Suggested_Open_Date_To_Pay__c = date.today();
        
        insert candor;
        
        Order_Item__c candor1 = new Order_Item__c();
        candor1.Order__c = cand.Id;
        candor1.Amount__c = 100;
        candor1.PoNumber__c = 'ABC3';
        candor1.Payment_Status__c = 'Waiting to Invoice';
        candor1.Payment_Received_from_Client__c = false;
        candor1.Send_for_approval_to_pay_PTO_fee__c = false;
        candor1.Renewal_Instruction__c = 'Renew';
        candor1.Is_PTO_Fee_Paid__c = false;
        candor1.Payment_Approval_Status__c = null;
        candor1.Payment__c = null;
        candor1.Is_Agent_fee_paid__c = false;
        candor1.Is_it_renewed_in_PTO__c = false;
        insert candor1;
        
        Order_Item__c candor2 = new Order_Item__c();
        candor2.Order__c = cand.Id;
        candor2.Amount__c = 102;
        candor2.PoNumber__c = 'ABC1';
        candor2.Payment_Status__c = 'Waiting to Invoice';
        candor2.Payment_Received_from_Client__c = false;
        candor2.Send_for_approval_to_pay_PTO_fee__c = true;
        candor2.Renewal_Instruction__c = 'Renew';
        candor2.Is_PTO_Fee_Paid__c = false;
        candor2.Payment__c = pay.Id;
        candor2.Payment_Approval_Status__c = 'Requested to Approve';
        candor2.Is_send_to_Validate_with_PTO__c = false;
        candor2.Cancellation_Approval__c = 'Requested';
        insert candor2;
        
    }
    
    @isTest public static void TestMethod1()
    { 
        test.startTest();
        
        List<Order__c> cand = [SELECT Client__c FROM Order__c];
        
        List<Order_Item__c> candor = [SELECT Order__c, Amount__c, PoNumber__c, Payment_Status__c, Payment_Received_from_Client__c,Send_for_approval_to_pay_PTO_fee__c,Renewal_Instruction__c, Is_PTO_Fee_Paid__c, Payment__c, Payment_Approval_Status__c  FROM Order_Item__c WHERE Amount__c = 100];
        for(Order_Item__c obj : candor )
        {
            obj.Payment_Status__c = 'Payment Requested';
            obj.PoNumber__c = 'ABC2';
            obj.Amount__c = 101;
            obj.Payment_Approval_Status__c = 'Approved';
            obj.Is_PTO_Fee_Paid__c = true;
            obj.Filing_Receipt_File_Id__c = 'ID102';
        }
        if(candor.size() > 0)
        {
            update candor;
        }
        system.debug('Update OI: '+candor);
        test.stopTest();
        System.assertEquals('Approved', candor[0].Payment_Approval_Status__c);
        System.assertEquals('Payment Requested', candor[0].Payment_Status__c);
        System.assertEquals('ABC2', candor[0].PoNumber__c);
        System.assertEquals(101, candor[0].Amount__c);
        System.assertEquals('ID102', candor[0].Filing_Receipt_File_Id__c);
        System.assertEquals(true, candor[0].Is_PTO_Fee_Paid__c);
        
        
    }
    @isTest public static void TestMethod2()
    { 
        test.startTest();
        
        List<Order__c> cand = [SELECT Client__c FROM Order__c];
        
        List<Order_Item__c> candor = [SELECT Order__c, Amount__c, PoNumber__c, Payment_Status__c, Payment_Received_from_Client__c,Send_for_approval_to_pay_PTO_fee__c,Renewal_Instruction__c, Is_PTO_Fee_Paid__c, Payment__c, Payment_Approval_Status__c  FROM Order_Item__c WHERE Amount__c = 100];
        for(Order_Item__c obj : candor )
        {
            obj.Payment_Status__c = 'PTO/Agent Payments Completed';
            obj.PoNumber__c = 'ABC2';
            obj.Amount__c = 101;
            obj.Is_PTO_Fee_Paid__c = true;
            obj.Send_for_approval_to_pay_PTO_fee__c = true;
            obj.Is_it_renewed_in_PTO__c = true;
        }
        if(candor.size() > 0)
        {
            update candor;
        }
        test.stopTest();
        System.assertEquals('PTO/Agent Payments Completed', candor[0].Payment_Status__c);
        System.assertEquals('ABC2', candor[0].PoNumber__c);
        System.assertEquals(101, candor[0].Amount__c);
        System.assertEquals(true, candor[0].Is_PTO_Fee_Paid__c);
        System.assertEquals(true, candor[0].Send_for_approval_to_pay_PTO_fee__c);
        System.assertEquals(true, candor[0].Is_it_renewed_in_PTO__c);
        
        
    }
    @isTest public static void TestMethod3()
    { 
        test.startTest();
        
        List<Order__c> cand = [SELECT Client__c FROM Order__c];
        
        List<Order_Item__c> candor = [SELECT Order__c, Amount__c, PoNumber__c, Payment_Status__c, Payment_Received_from_Client__c,Send_for_approval_to_pay_PTO_fee__c,Renewal_Instruction__c, Is_PTO_Fee_Paid__c, Payment__c, Payment_Approval_Status__c, Cancellation_Approval__c  FROM Order_Item__c WHERE Amount__c = 100];
        for(Order_Item__c obj : candor )
        {
            obj.Cancellation_Approval__c = 'Requested';
            obj.Renewal_Instruction__c = 'Renew';
            obj.Send_for_approval_to_pay_PTO_fee__c = true;
        }
        if(candor.size() > 0)
        {
            update candor;
        }
        test.stopTest();
        System.assertEquals('Requested', candor[0].Cancellation_Approval__c);
        System.assertEquals('Renew', candor[0].Renewal_Instruction__c);
        System.assertEquals(true, candor[0].Send_for_approval_to_pay_PTO_fee__c);
        
    }
    @isTest public static void TestMethod4()
    { 
        test.startTest();
        
        List<Order__c> cand = [SELECT Client__c FROM Order__c];
        
        List<Order_Item__c> candor = [SELECT Order__c, Amount__c, PoNumber__c, Payment_Status__c, Payment_Received_from_Client__c,Send_for_approval_to_pay_PTO_fee__c,Renewal_Instruction__c, Is_PTO_Fee_Paid__c, Payment__c, Payment_Approval_Status__c, Cancellation_Approval__c  FROM Order_Item__c WHERE Amount__c = 100];
        for(Order_Item__c obj : candor )
        {
            obj.Payment_Status__c = 'Payment Received';
            obj.Send_for_approval_to_pay_PTO_fee__c = true;
        }
        if(candor.size() > 0)
        {
            update candor;
        }
        test.stopTest();
        System.assertEquals('Payment Received', candor[0].Payment_Status__c);
        System.assertEquals(true, candor[0].Send_for_approval_to_pay_PTO_fee__c);
        
    }
    @isTest public static void TestMethod5()
    { 
        test.startTest();
        
        List<Order__c> cand = [SELECT Client__c FROM Order__c];
        
        List<Order_Item__c> candor = [SELECT Order__c, Amount__c, PoNumber__c, Payment_Status__c, Payment_Received_from_Client__c,Send_for_approval_to_pay_PTO_fee__c,Renewal_Instruction__c, Is_PTO_Fee_Paid__c, Payment__c, Payment_Approval_Status__c, Cancellation_Approval__c, Is_send_to_Validate_with_PTO__c  FROM Order_Item__c WHERE Amount__c = 100];
        for(Order_Item__c obj : candor )
        {
            obj.Is_send_to_Validate_with_PTO__c = true;
            obj.Send_for_approval_to_pay_PTO_fee__c = true;
            obj.Renewal_Instruction__c = 'Renew';
        }
        if(candor.size() > 0)
        {
            update candor;
        }
        test.stopTest();
        System.assertEquals(true, candor[0].Send_for_approval_to_pay_PTO_fee__c);
        System.assertEquals('Renew', candor[0].Renewal_Instruction__c);
        System.assertEquals(true, candor[0].Is_send_to_Validate_with_PTO__c);
        
    }
    @isTest public static void TestMethod6()
    { 
        test.startTest();
        
        Payment__c pay = new Payment__c();
        pay.Name = 'Max123';
        insert pay;
        
        Payment_Confirmation__c payc = new Payment_Confirmation__c();
        payc.Name = 'Confirmation check';
        insert payc;
        
        List<Order__c> cand = [SELECT Client__c FROM Order__c];
        
        List<Order_Item__c> candor = [SELECT Order__c, Amount__c,Payment_Confirmation__c, PoNumber__c,Is_Agent_fee_paid__c, Payment_Status__c, Payment_Received_from_Client__c,Send_for_approval_to_pay_PTO_fee__c,Renewal_Instruction__c, Is_PTO_Fee_Paid__c, Payment__c, Payment_Approval_Status__c, Cancellation_Approval__c  FROM Order_Item__c WHERE PoNumber__c = 'ABC3'];
        for(Order_Item__c obj : candor )
        {
            obj.Payment_Status__c = 'Payment Received';
            obj.Payment__c = pay.Id;
            obj.Send_for_approval_to_pay_PTO_fee__c = true;
            obj.Is_Agent_fee_paid__c = true;
            obj.Payment_Confirmation__c = payc.Id;
            obj.Is_PTO_Fee_Paid__c = true;
        }
        if(candor.size() > 0)
        {
            update candor;
        }
        test.stopTest();
        System.assertEquals('Payment Received', candor[0].Payment_Status__c);
        System.assertEquals(pay.Id, candor[0].Payment__c);
        System.assertEquals(true, candor[0].Send_for_approval_to_pay_PTO_fee__c);
        System.assertEquals(true, candor[0].Is_Agent_fee_paid__c);
        System.assertEquals(payc.Id, candor[0].Payment_Confirmation__c);
        System.assertEquals(true, candor[0].Is_PTO_Fee_Paid__c);
        
    }
    
    @isTest public static void TestMethod7()
    { 
        test.startTest();
        
        Payment__c pay = new Payment__c();
        pay.Name = 'Max123';
        insert pay;
        
        Payment_Confirmation__c payc = new Payment_Confirmation__c();
        payc.Name = 'Confirmation check';
        insert payc;
        
        List<Order__c> cand = [SELECT Client__c FROM Order__c];
        
        List<Order_Item__c> candor = [SELECT Order__c, Amount__c,Payment_Confirmation__c, PoNumber__c,Is_Agent_fee_paid__c, Payment_Status__c, Payment_Received_from_Client__c,Send_for_approval_to_pay_PTO_fee__c,Renewal_Instruction__c, Is_PTO_Fee_Paid__c, Payment__c, Payment_Approval_Status__c, Cancellation_Approval__c  FROM Order_Item__c WHERE PoNumber__c = 'ABC3'];
        for(Order_Item__c obj : candor )
        {
            obj.Payment_Status__c = 'PTO/Agent Payments Completed';
            obj.Payment__c = pay.Id;
            obj.Is_it_renewed_in_PTO__c = true;
            obj.Send_for_approval_to_pay_PTO_fee__c = true;
            obj.Is_Agent_fee_paid__c = true;
            obj.Payment_Confirmation__c = payc.Id;
            obj.Is_PTO_Fee_Paid__c = true;
        }
        if(candor.size() > 0)
        {
            update candor;
        }
        test.stopTest();
        System.assertEquals(pay.Id, candor[0].Payment__c);
        System.assertEquals(true, candor[0].Is_it_renewed_in_PTO__c);
        System.assertEquals('PTO/Agent Payments Completed', candor[0].Payment_Status__c);
        System.assertEquals(true, candor[0].Send_for_approval_to_pay_PTO_fee__c);
        System.assertEquals(true, candor[0].Is_Agent_fee_paid__c);
        System.assertEquals(payc.Id, candor[0].Payment_Confirmation__c);
        System.assertEquals(true, candor[0].Is_PTO_Fee_Paid__c);
        
    }
    @isTest public static void TestMethod8()
    { 
        test.startTest();
        
        List<Order__c> cand = [SELECT Client__c FROM Order__c];
        
        List<Order_Item__c> candor = [SELECT Order__c, Amount__c, PoNumber__c,Is_send_to_Validate_with_PTO__c, Payment_Status__c, Payment_Received_from_Client__c,Send_for_approval_to_pay_PTO_fee__c,Renewal_Instruction__c, Is_PTO_Fee_Paid__c, Payment__c, Payment_Approval_Status__c  FROM Order_Item__c WHERE Amount__c = 100];
        for(Order_Item__c obj : candor )
        {
            obj.Payment_Status__c = 'Payment Requested';
            obj.PoNumber__c = 'ABC2';
            obj.Amount__c = 101;
            obj.Payment_Approval_Status__c = 'Requested to Approve';
            obj.Is_PTO_Fee_Paid__c = true;
            obj.Filing_Receipt_File_Id__c = 'ID102';
            obj.Is_send_to_Validate_with_PTO__c = true;
        }
        if(candor.size() > 0)
        {
            update candor;
        }
        system.debug('Update OI: '+candor);
        test.stopTest();
        System.assertEquals('Requested to Approve', candor[0].Payment_Approval_Status__c);
        System.assertEquals('Payment Requested', candor[0].Payment_Status__c);
        System.assertEquals('ABC2', candor[0].PoNumber__c);
        System.assertEquals(101, candor[0].Amount__c);
        System.assertEquals('ID102', candor[0].Filing_Receipt_File_Id__c);
        System.assertEquals(true, candor[0].Is_PTO_Fee_Paid__c);
        
        
    }
    @isTest public static void TestMethod9()
    { 
        test.startTest();
        
        List<Order__c> cand = [SELECT Client__c FROM Order__c];
        
        List<Order_Item__c> candor = [SELECT Order__c, Amount__c, PoNumber__c, Payment_Status__c, Payment_Received_from_Client__c,Send_for_approval_to_pay_PTO_fee__c,Renewal_Instruction__c, Is_PTO_Fee_Paid__c, Payment__c, Payment_Approval_Status__c  FROM Order_Item__c WHERE Amount__c = 100];
        for(Order_Item__c obj : candor )
        {
            obj.Payment_Status__c = 'Payment Requested';
            obj.PoNumber__c = 'ABC2';
            obj.Amount__c = 101;
            obj.Payment_Approval_Status__c = 'Declined';
            obj.Is_PTO_Fee_Paid__c = true;
            obj.Filing_Receipt_File_Id__c = 'ID102';
        }
        if(candor.size() > 0)
        {
            update candor;
        }
        system.debug('Update OI: '+candor);
        test.stopTest();
        System.assertEquals('Requested to Approve', candor[0].Payment_Approval_Status__c);
        System.assertEquals('Payment Requested', candor[0].Payment_Status__c);
        System.assertEquals('ABC2', candor[0].PoNumber__c);
        System.assertEquals(101, candor[0].Amount__c);
        System.assertEquals('ID102', candor[0].Filing_Receipt_File_Id__c);
        System.assertEquals(true, candor[0].Is_PTO_Fee_Paid__c);
        
        
    }
    
}