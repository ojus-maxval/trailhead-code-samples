trigger trgOrderItem on Order_Item__c(before insert, before update, after insert, after update) {
    //ACTION: Read Old Values
    Map < Id, Order_Item__c > mapOldOrderItems = new Map < Id, Order_Item__c > ();
    set<id> Inv_ID=new set<id>();
    if (Trigger.isUpdate) {
        for (Order_Item__c objOrderItem: Trigger.Old) {
            if (mapOldOrderItems.containsKey(objOrderItem.Id) == false)
                mapOldOrderItems.put(objOrderItem.Id, objOrderItem);
        }
    }
    //EVENT: Before
    if (Trigger.isBefore) {
        /*Harsha added for validation*/
        String UserId = UserInfo.getUserId();
        User usr = [select id, Is_ADU_Manager__c, Profile.Name from User where id =: UserId];
        boolean isADU = false;
        boolean isADUManager = false;
        if(usr.Profile.Name == 'ADU')
        {
            isADU = true;
        }
        if(usr.Is_ADU_Manager__c == true)
        {
            isADUManager = true;
        }
        if (trigger.isInsert) {
            for (Order_Item__c objOrderItem: Trigger.new) {
                /*objOrderItem.Is_send_to_Validate_with_PTO__c=true;//Thulasi
                objOrderItem.PTO_Validation_Status__c ='Request to Validate';//Thulasi
                */
                
                if (usr.Is_ADU_Manager__c == false && objOrderItem.Payment_Approval_Status__c == 'Approved')
                    objOrderItem.Payment_Approval_Status__c.addError('Approver can approve.');
                if (usr.Is_ADU_Manager__c == false && objOrderItem.Payment_Approval_Status__c == 'Declined')
                    objOrderItem.Payment_Approval_Status__c.addError('Approver can decline.');
                if (usr.Is_ADU_Manager__c == True && objOrderItem.Payment_Approval_Status__c == 'Requested to Approve')
                    objOrderItem.Payment_Approval_Status__c.addError('ADU can Request.');
            }
        }
        //-----------------------------
        if (Trigger.isUpdate) {            
            List <string> ExternallyRenewedAssets = new List <string>();
            for (Order_Item__c objNewOrderItem: Trigger.new) {
                boolean isPaymentConfirmationAttached = false;
                Order_Item__c oldOiObj = Trigger.oldMap.get(objNewOrderItem.Id);
                  //Update Bulk PO Number //&& usr.Is_ADU_Manager__c == true) 
                If( (oldOiObj.PoNumber__c != objNewOrderItem.PoNumber__c && objNewOrderItem.PoNumber__c != null && objNewOrderItem.Payment_Status__c != 'Waiting to Invoice'  &&
                     objNewOrderItem.Invoice__c != null) 
                    )                   
                {
                    system.debug('Update Bulk PO Number');
                     objNewOrderItem.adderror('1This action is not allowed at this time.' );
                }
                
                //MARS-291 MaRS - Ability to mark an Asset as Renewed Externally
                if(oldOiObj.Is_Renewed_Externally__c == false && objNewOrderItem.Is_Renewed_Externally__c == true){
                    if(objNewOrderItem.Payment_Status__c == 'Asset Renewed'){
						objNewOrderItem.adderror('Asset has already been renewed!');   
                    }
                    else{
                        //Update status in MaRS
                        objNewOrderItem.Payment_Status__c = 'Renewed Externally';
                        //Send updated status to Symphony
                        ExternallyRenewedAssets.add(objNewOrderItem.id);
                    }
                }
                
                //OUTSTANDING PAYMENT
                If(oldOiObj.Payment_Received_from_Client__c == False && 
                   objNewOrderItem.Payment_Received_from_Client__c== false && 
                   oldOiObj.Send_for_approval_to_pay_PTO_fee__c == TRUE &&  
                   objNewOrderItem.Send_for_approval_to_pay_PTO_fee__c == TRUE && 
                   oldOiObj.Payment_Approval_Status__c == 'Approved' &&  
                   (oldOiObj.Payment_Confirmation__c != objNewOrderItem.Payment_Confirmation__c && objNewOrderItem.Payment_Confirmation__c != null) && 
                   oldOiObj.Suggested_Open_Date_To_Pay__c < date.today().addDays(1)
                  //|| (oldOiObj.Suggested_Open_Date_To_Pay__c > date.today().addDays(3))
                  )
                  
                {
                    system.debug('OUTSTANDING PAYMENT');
                    objNewOrderItem.adderror('2This action is not allowed at this time.');
                }
                // *INSTRUCTED  ASSETS LIST VIEW VALIDATIOn*
                if (objNewOrderItem.Payment_Status__c == 'Waiting to Invoice' && objNewOrderItem.Renewal_Instruction__c == 'Renew' &&
                    ((oldOiObj.Is_PTO_Fee_Paid__c != objNewOrderItem.Is_PTO_Fee_Paid__c && objNewOrderItem.Is_PTO_Fee_Paid__c == True) ||
                     (oldOiObj.Is_it_renewed_in_PTO__c != objNewOrderItem.Is_it_renewed_in_PTO__c && objNewOrderItem.Is_it_renewed_in_PTO__c == True) ||
                     (oldOiObj.Payment__c != objNewOrderItem.Payment__c && objNewOrderItem.Payment__c != null) ||
                     (oldOiObj.Payment__c != objNewOrderItem.Payment__c && objNewOrderItem.Payment__c != null) ||
                     (oldOiObj.Special_Instruction__c != objNewOrderItem.Special_Instruction__c && objNewOrderItem.Special_Instruction__c != null) ||
                     (oldOiObj.Payment_Confirmation__c != objNewOrderItem.Payment_Confirmation__c && objNewOrderItem.Payment_Confirmation__c != null) ||
                     (oldOiObj.Send_for_approval_to_pay_PTO_fee__c != objNewOrderItem.Send_for_approval_to_pay_PTO_fee__c && objNewOrderItem.Send_for_approval_to_pay_PTO_fee__c == true) || (oldOiObj.Is_send_to_Validate_with_PTO__c != objNewOrderItem.Is_send_to_Validate_with_PTO__c && objNewOrderItem.Is_send_to_Validate_with_PTO__c == true)
                    )) {
                        system.debug('INSTRUCTED  ASSETS LIST VIEW VALIDATIO');
                        objNewOrderItem.adderror('3This action is not allowed at this time.');
                    }
                // *RECORD PAYMENTS LIST VIEW VALIDATIOn*
                if ((objNewOrderItem.Payment_Status__c == 'Payment Requested' &&
                     objNewOrderItem.Renewal_Instruction__c == 'Renew' &&
                     ((objNewOrderItem.Send_for_approval_to_pay_PTO_fee__c == False &&
                       objNewOrderItem.Payment_Approval_Status__c == Null) || (objNewOrderItem.Payment_Approval_Status__c == 'Declined'))) &&
                    ((oldOiObj.Is_it_renewed_in_PTO__c != objNewOrderItem.Is_it_renewed_in_PTO__c && objNewOrderItem.Is_it_renewed_in_PTO__c == True) ||
                     (oldOiObj.Payment_Confirmation__c != objNewOrderItem.Payment_Confirmation__c && objNewOrderItem.Payment_Confirmation__c != null) ||
                     (oldOiObj.Special_Instruction__c != objNewOrderItem.Special_Instruction__c && objNewOrderItem.Special_Instruction__c != null) ||
                     (oldOiObj.Is_PTO_Fee_Paid__c != objNewOrderItem.Is_it_renewed_in_PTO__c && objNewOrderItem.Is_it_renewed_in_PTO__c == True) ||
                     (oldOiObj.Is_send_to_Validate_with_PTO__c != objNewOrderItem.Is_send_to_Validate_with_PTO__c && objNewOrderItem.Is_send_to_Validate_with_PTO__c == true) //|| (oldOiObj.Is_send_to_Validate_with_PTO__c != objNewOrderItem.Is_send_to_Validate_with_PTO__c && objNewOrderItem.Is_send_to_Validate_with_PTO__c == true)
                    )) 
                {
                    system.debug('RECORD PAYMENTS LIST VIEW VALIDATIOn');
                    objNewOrderItem.adderror('4This action is not allowed at this time.');
                }
                // * PAYMENT LIST VIEW VALIDATION* i               
                /*if (((objNewOrderItem.Payment_Status__c == 'Payment Received' &&
                      objNewOrderItem.Renewal_Instruction__c == 'Renew' &&
                      (objNewOrderItem.Payment_Mode__c == 'Wire' || objNewOrderItem.Payment_Mode__c == 'Credit Card' || objNewOrderItem.Payment_Mode__c == 'Agent'))||
                     (objNewOrderItem.Payment_Approval_Status__c == 'Approved' && objNewOrderItem.Payment_Status__c == 'Payment Requested')
                    )
                    
                    &&
                    (
                        (oldOiObj.Payment__c != objNewOrderItem.Payment__c && objNewOrderItem.Payment__c != null) ||
                        (oldOiObj.Send_for_approval_to_pay_PTO_fee__c != objNewOrderItem.Send_for_approval_to_pay_PTO_fee__c && objNewOrderItem.Send_for_approval_to_pay_PTO_fee__c == true) ||
                        (oldOiObj.Is_it_renewed_in_PTO__c != objNewOrderItem.Is_it_renewed_in_PTO__c && objNewOrderItem.Is_it_renewed_in_PTO__c == True)
                    )
                   ) {
                       system.debug('yes');
                       objNewOrderItem.adderror('This action is not allowed at this time.');
                       
                   }*/
                // *PTO/AGENTS PAYMENT VALIDAION*
                if (objNewOrderItem.Payment_Status__c == 'PTO/Agent Payments Completed' && objNewOrderItem.Renewal_Instruction__c == 'Renew' && ((oldOiObj.Payment__c != objNewOrderItem.Payment__c && objNewOrderItem.Payment__c != null) ||
                                                                                                                                                 (oldOiObj.Send_for_approval_to_pay_PTO_fee__c != objNewOrderItem.Send_for_approval_to_pay_PTO_fee__c && objNewOrderItem.Send_for_approval_to_pay_PTO_fee__c == true) ||
                                                                                                                                                 (oldOiObj.Is_send_to_Validate_with_PTO__c != objNewOrderItem.Is_send_to_Validate_with_PTO__c && objNewOrderItem.Is_send_to_Validate_with_PTO__c == true) ||
                                                                                                                                                 (oldOiObj.Payment_Confirmation__c != objNewOrderItem.Payment_Confirmation__c && objNewOrderItem.Payment_Confirmation__c != null) ||
                                                                                                                                                 (oldOiObj.Special_Instruction__c != objNewOrderItem.Special_Instruction__c && objNewOrderItem.Special_Instruction__c != null) ||
                                                                                                                                                 (oldOiObj.Is_PTO_Fee_Paid__c != objNewOrderItem.Is_PTO_Fee_Paid__c && objNewOrderItem.Is_PTO_Fee_Paid__c == true)
                                                                                                                                                )) {
                                                                                                                                                    system.debug('PTO/AGENTS PAYMENT ');
                                                                                                                                                    objNewOrderItem.adderror('This action is not allowed at this time.');
                                                                                                                                                }
                //*CANCELLATION LIST VIEW VALIDATION*
                if ((objNewOrderItem.Cancellation_Approval__c == 'Requested' || objNewOrderItem.Cancellation_Approval__c == 'Approved') &&
                    ((objNewOrderItem.Payment_Status__c == 'Waiting to Invoice') || (objNewOrderItem.Payment_Status__c == 'Payment Requested') || (objNewOrderItem.Payment_Status__c == 'Payment Received')) && objNewOrderItem.Renewal_Instruction__c == 'Renew' &&
                    ((oldOiObj.Payment__c != objNewOrderItem.Payment__c && objNewOrderItem.Payment__c != null) ||
                     (oldOiObj.Send_for_approval_to_pay_PTO_fee__c != objNewOrderItem.Send_for_approval_to_pay_PTO_fee__c && objNewOrderItem.Send_for_approval_to_pay_PTO_fee__c == true) ||
                     (oldOiObj.Is_send_to_Validate_with_PTO__c != objNewOrderItem.Is_send_to_Validate_with_PTO__c && objNewOrderItem.Is_send_to_Validate_with_PTO__c == true) ||
                     (oldOiObj.Payment_Confirmation__c != objNewOrderItem.Payment_Confirmation__c && objNewOrderItem.Payment_Confirmation__c != null) ||
                     (oldOiObj.Special_Instruction__c != objNewOrderItem.Special_Instruction__c && objNewOrderItem.Special_Instruction__c != null) ||
                     (oldOiObj.Is_PTO_Fee_Paid__c != objNewOrderItem.Is_PTO_Fee_Paid__c && objNewOrderItem.Is_PTO_Fee_Paid__c == true) ||
                     (oldOiObj.Is_it_renewed_in_PTO__c != objNewOrderItem.Is_it_renewed_in_PTO__c && objNewOrderItem.Is_it_renewed_in_PTO__c == True)
                    )) {
                        // objNewOrderItem.adderror('This action is not allowed at this time.');
                    }
                //*REQUSTED APPRVAL TO PAY PTO FEE *
                if (objNewOrderItem.Payment_Status__c == 'Payment Requested' && objNewOrderItem.Payment_Approval_Status__c == 'Requested to Approve' && objNewOrderItem.Send_for_approval_to_pay_PTO_fee__c == True &&
                    ((oldOiObj.Is_send_to_Validate_with_PTO__c != objNewOrderItem.Is_send_to_Validate_with_PTO__c && objNewOrderItem.Is_send_to_Validate_with_PTO__c == true)
                     // ||(oldOiObj.Send_for_approval_to_pay_PTO_fee__c!= objNewOrderItem .Send_for_approval_to_pay_PTO_fee__c&& objNewOrderItem .Send_for_approval_to_pay_PTO_fee__c==true)
                     ||
                     (oldOiObj.Payment_Confirmation__c != objNewOrderItem.Payment_Confirmation__c && objNewOrderItem.Payment_Confirmation__c != null) ||
                     (oldOiObj.Special_Instruction__c != objNewOrderItem.Special_Instruction__c && objNewOrderItem.Special_Instruction__c != null) ||
                     (oldOiObj.Is_PTO_Fee_Paid__c != objNewOrderItem.Is_PTO_Fee_Paid__c && objNewOrderItem.Is_PTO_Fee_Paid__c == true) ||
                     (oldOiObj.Is_it_renewed_in_PTO__c != objNewOrderItem.Is_it_renewed_in_PTO__c && objNewOrderItem.Is_it_renewed_in_PTO__c == True)
                    )) {
                        system.debug('REQUSTED APPRVAL TO PAY PTO FEE');
                        objNewOrderItem.adderror('5This action is not allowed at this time.');
                    }
                //*DECLINED/APPROVE TO PAY PTO*
                if (objNewOrderItem.Payment_Status__c == 'Payment Requested' && objNewOrderItem.Payment_Approval_Status__c == 'Requested to Approve' && objNewOrderItem.Send_for_approval_to_pay_PTO_fee__c == True &&
                    ((oldOiObj.Payment__c != objNewOrderItem.Payment__c && objNewOrderItem.Payment__c != null)
                     //||(oldOiObj.Send_for_approval_to_pay_PTO_fee__c!= objNewOrderItem .Send_for_approval_to_pay_PTO_fee__c&& objNewOrderItem .Send_for_approval_to_pay_PTO_fee__c==true)
                     ||
                     (oldOiObj.Is_send_to_Validate_with_PTO__c != objNewOrderItem.Is_send_to_Validate_with_PTO__c && objNewOrderItem.Is_send_to_Validate_with_PTO__c == true) ||
                     (oldOiObj.Payment_Confirmation__c != objNewOrderItem.Payment_Confirmation__c && objNewOrderItem.Payment_Confirmation__c != null) ||
                     (oldOiObj.Special_Instruction__c != objNewOrderItem.Special_Instruction__c && objNewOrderItem.Special_Instruction__c != null) ||
                     (oldOiObj.Is_PTO_Fee_Paid__c != objNewOrderItem.Is_PTO_Fee_Paid__c && objNewOrderItem.Is_PTO_Fee_Paid__c == true) ||
                     (oldOiObj.Is_it_renewed_in_PTO__c != objNewOrderItem.Is_it_renewed_in_PTO__c && objNewOrderItem.Is_it_renewed_in_PTO__c == True)
                    )) {
                        system.debug('DECLINED/APPROVE TO PAY PTO-1');
                        objNewOrderItem.adderror('6This action is not allowed at this time.');
                    }
                //*DECLINED/APPROVE TO PAY PTO*
                if (objNewOrderItem.Payment_Status__c == 'Payment Received' && objNewOrderItem.Payment_Received_from_Client__c == False &&
                    ((oldOiObj.Payment__c != objNewOrderItem.Payment__c && objNewOrderItem.Payment__c != null) ||
                     (oldOiObj.Send_for_approval_to_pay_PTO_fee__c != objNewOrderItem.Send_for_approval_to_pay_PTO_fee__c && objNewOrderItem.Send_for_approval_to_pay_PTO_fee__c == true) ||
                     (oldOiObj.Is_send_to_Validate_with_PTO__c != objNewOrderItem.Is_send_to_Validate_with_PTO__c && objNewOrderItem.Is_send_to_Validate_with_PTO__c == true) ||
                     (oldOiObj.Payment_Confirmation__c != objNewOrderItem.Payment_Confirmation__c && objNewOrderItem.Payment_Confirmation__c != null) ||
                     (oldOiObj.Special_Instruction__c != objNewOrderItem.Special_Instruction__c && objNewOrderItem.Special_Instruction__c != null) ||
                     (oldOiObj.Is_PTO_Fee_Paid__c != objNewOrderItem.Is_PTO_Fee_Paid__c && objNewOrderItem.Is_PTO_Fee_Paid__c == true) ||
                     (oldOiObj.Is_it_renewed_in_PTO__c != objNewOrderItem.Is_it_renewed_in_PTO__c && objNewOrderItem.Is_it_renewed_in_PTO__c == True) 
                     && ((oldOiObj.Suggested_Open_Date_To_Pay__c < date.today().addDays(1)) 
                         //|| (oldOiObj.Suggested_Open_Date_To_Pay__c > date.today().addDays(3))
                        )
                    )) 
                {
                    system.debug('DECLINED/APPROVE TO PAY PTO-2');
                    objNewOrderItem.adderror('7This action is not allowed at this time.');
                }
                    /*   if (objNewOrderItem.Payment_Status__c == 'PTO/Agent Payments Completed' && objNewOrderItem.Renewal_Instruction__c == 'Renew' 
                    && objNewOrderItem.Is_it_renewed_in_PTO__c  == false    ){
                    
                    objNewOrderItem.adderror('Please confirm Is it renewed in PTO');
                    }   */ 
                Order_Item__c objOldOrderItem = null;
                if (mapOldOrderItems.containsKey(objNewOrderItem.Id) == true)
                    objOldOrderItem = mapOldOrderItems.get(objNewOrderItem.Id);
                if(
                    objOldOrderItem!=null 
                    && objOldOrderItem.Is_send_to_Validate_with_PTO__c == false  
                    && objNewOrderItem.Is_send_to_Validate_with_PTO__c == true 
                    && objNewOrderItem.Renewal_Instruction__c == 'Renew'
                    && 
                    (
                        (
                            objNewOrderItem.Invoice__c == null
                        )
                        ||
                        (
                            (objNewOrderItem.Payment__c == null && objNewOrderItem.Payment_Approval_Status__c != 'Approved') || objNewOrderItem.Payment__c == null
                        )
                    )
                )
                {
                    objNewOrderItem.Is_send_to_Validate_with_PTO__c.addError('Payment from Client/Invoice is not received');
                }
                if(
                    objOldOrderItem!=null 
                    && objOldOrderItem.Is_send_to_Validate_with_PTO__c == false  
                    && objNewOrderItem.Is_send_to_Validate_with_PTO__c == true 
                    && objNewOrderItem.Renewal_Instruction__c == 'Renew'
                    && ((objNewOrderItem.Payment__c == null && objNewOrderItem.Payment_Approval_Status__c == 'Approved') || objNewOrderItem.Payment__c != null)
                    && (objNewOrderItem.Payment_Confirmation__c != null || objNewOrderItem.Renewal_Status__c == 'Asset Renewed' || objNewOrderItem.Payment_Status__c == 'Asset Renewed')
                )
                {
                    objNewOrderItem.adderror('8This action is not allowed at this time.');
                }  
                
                //---------Harsha added for validation on 30-11-20------------
                if //Make Payments > Validate with PTO isADU
                (
                    objOldOrderItem!=null && 
                    objNewOrderItem.Renewal_Instruction__c == 'Renew' 
                    && objNewOrderItem.Invoice__c == null && (objNewOrderItem.Payment__c == null && objNewOrderItem.Payment_Approval_Status__c != 'Approved') 
                    && objOldOrderItem.Is_send_to_Validate_with_PTO__c == false && objNewOrderItem.Is_send_to_Validate_with_PTO__c == true && isADU != true
                ){
                    //objNewOrderItem.addError('ADU only can perform this action');
                    //break;
                }
                /*if //Record Payments > Record Customer Payment
                (
                    objOldOrderItem!=null && 
                    objNewOrderItem.Renewal_Instruction__c == 'Renew' 
                    && objNewOrderItem.Invoice__c == null && objOldOrderItem.Payment__c == null && objNewOrderItem.Payment__c != null
                ){
                    objNewOrderItem.addError('Not yet invoiced');
                    //break;
                }
                if //Record Payments > Request Manager to Pay PTO Fee
                (
                    objOldOrderItem!=null && 
                    objNewOrderItem.Renewal_Instruction__c == 'Renew' 
                    && objNewOrderItem.Invoice__c == null 
                    && objOldOrderItem.Send_for_approval_to_pay_PTO_fee__c == false && objNewOrderItem.Send_for_approval_to_pay_PTO_fee__c ==true
                ){
                    objNewOrderItem.addError('Not yet invoiced');
                    //break;
                }
                if //Make Payments > Validate with PTO
                (
                    objOldOrderItem!=null && 
                    objNewOrderItem.Renewal_Instruction__c == 'Renew' 
                    && objNewOrderItem.Invoice__c == null && (objNewOrderItem.Payment__c == null && objNewOrderItem.Payment_Approval_Status__c != 'Approved') 
                    && objOldOrderItem.Is_send_to_Validate_with_PTO__c == false && objNewOrderItem.Is_send_to_Validate_with_PTO__c == true
                ){
                    objNewOrderItem.addError('Action can not perform due to no Invoice/Payment Received');
                    //break;
                }
                if //Make Payments > Attach Payment Confirmation
                (
                    objOldOrderItem!=null && 
                    objNewOrderItem.Renewal_Instruction__c == 'Renew' 
                    && (objNewOrderItem.Invoice__c == null || (objNewOrderItem.Payment__c == null && objNewOrderItem.Payment_Approval_Status__c != 'Approved') )
                    && objOldOrderItem.Payment_Confirmation__c == null && objNewOrderItem.Payment_Confirmation__c != null
                ){
                    objNewOrderItem.addError('Action can not perform due to no Invoice/Payment Received');
                    //break;
                }
                //PTO/Agent Payments Completed > Mark as Renewed
                if 
                (
                    objOldOrderItem!=null && 
                    objNewOrderItem.Renewal_Instruction__c == 'Renew' 
                    && (objNewOrderItem.Invoice__c == null || (objNewOrderItem.Payment_Approval_Status__c == null && objNewOrderItem.Payment_Approval_Status__c != 'Approved')  || objNewOrderItem.Payment_Confirmation__c == null) 
                    && (objOldOrderItem.Is_it_renewed_in_PTO__c == false && objNewOrderItem.Is_it_renewed_in_PTO__c == true)
                ){
                    system.debug('>>> Action can not perform due to no Invoice/Payment Received/Payment Made');                
                    objNewOrderItem.addError('Action can not perform due to no Invoice/Payment Received/Payment Made');
                    //break;
                }*/
                //--------------------------------------------------
                //EVENT: Cancellation
                if (
                    objOldOrderItem != null &&
                    objOldOrderItem.Cancellation_Approval__c == 'Requested' &&
                    objNewOrderItem.Cancellation_Approval__c == 'Approved'
                ) {
                    //Accept
                    //objNewOrderItem.Cancellation_Approval__c = null;
                    objNewOrderItem.Renewal_Instruction__c = 'Cancel';
                    objNewOrderItem.Payment_Status__c = 'Cancelled';
                    //objNewOrderItem.Fee__c = 0;
                    //objNewOrderItem.Surcharge__c = 0;
                    //objNewOrderItem.Claim_Fee__c = 0;
                }
                //BUTTON: Record Payment for renewals
                if (
                    objOldOrderItem != null &&
                    objOldOrderItem.Payment__c == null &&
                    objNewOrderItem.Payment__c != null
                ) {
                    if (
                        objNewOrderItem.Payment_Status__c == 'Payment Requested' ||
                        (objNewOrderItem.Payment_Status__c != 'Payment Requested' && objNewOrderItem.Payment_Approval_Status__c == 'Approved')
                    ){
                        objNewOrderItem.Payment_Status__c = 'Payment Received';
                    } else {
                        objNewOrderItem.Patent_No__c.addError('You are allowed to record the payment only if meet the following criteria.[1] Payment requested from Client');
                    }
                }
                
                //BUTTON: Request to Approval to Pay PTO
                //Requesting approval to pay PTO even if the payment not yet received
                if (
                    objOldOrderItem != null &&
                    objOldOrderItem.Send_for_approval_to_pay_PTO_fee__c == false &&
                    objNewOrderItem.Send_for_approval_to_pay_PTO_fee__c == true
                ) {
                    if (objNewOrderItem.Payment_Status__c != 'Payment Requested') {
                        objNewOrderItem.Send_for_approval_to_pay_PTO_fee__c = false;
                        objNewOrderItem.Patent_No__c.addError('Request has to be sent only if payment not yet received from Client');
                    }
                }
                
                //ACTION: Approved by Manager
                //Approved by Manager
                if (
                    objOldOrderItem != null &&
                    objOldOrderItem.Payment_Approval_Status__c == null &&
                    objNewOrderItem.Payment_Approval_Status__c == 'Approved'
                ) {
                    if (objNewOrderItem.Payment_Status__c == 'Payment Requested') {
                        objNewOrderItem.Payment_Status__c = 'Payment Received';
                        objNewOrderItem.Send_for_approval_to_pay_PTO_fee__c = false;
                        //objNewOrderItem.addError('Approval has to be sent only when the payment not yet received from Client');
                    } else {
                        objNewOrderItem.addError('Something went wrong');
                    }
                }
                
                //ACTION: Declined by Manager
                //Approved by Manager
                if (
                    objOldOrderItem != null &&
                    objOldOrderItem.Payment_Approval_Status__c == null &&
                    objNewOrderItem.Payment_Approval_Status__c == 'Declined'
                ) {
                    if (objNewOrderItem.Payment_Status__c == 'Payment Requested') {
                        objNewOrderItem.Send_for_approval_to_pay_PTO_fee__c = false;
                    } else {
                        objNewOrderItem.addError('Something went wrong');
                    }
                }
                
                
                //BUTTON: Mark as Paid
                if(objNewOrderItem.Is_Agent_fee_paid__c == true && objNewOrderItem.Is_PTO_Fee_Paid__c == true)
                {
                    objNewOrderItem.addError('Payments can\'t made for two');
                }
                /*MARS-787 Error Message should be added when user click on "Mark As Paid" without attaching Payment Confirmation
                * Added by Saranyaa */
                if(objNewOrderItem.Is_Agent_fee_paid__c == true || objNewOrderItem.Is_PTO_Fee_Paid__c == true)
                   {
                       if(objNewOrderItem.Payment_Confirmation__c == null)
                       {
                           isPaymentConfirmationAttached = false;
                           objNewOrderItem.addError('Attach Payment Confirmation is not Attached');
                       }
                       else{
                           isPaymentConfirmationAttached = true;
                       }
                   }
                //Mark the renewal as paid
                if (isPaymentConfirmationAttached &&
                    objOldOrderItem != null &&
                    objOldOrderItem.Is_PTO_Fee_Paid__c == false &&
                    objNewOrderItem.Is_PTO_Fee_Paid__c == true
                ) {
                    if (
                        objNewOrderItem.Payment_Status__c == 'Payment Received' ||
                        (objNewOrderItem.Payment_Status__c == 'Payment Requested' && objNewOrderItem.Payment_Approval_Status__c == 'Approved')
                    ) {
                        objNewOrderItem.Payment_Status__c = 'PTO/Agent Payments Completed';
                        objNewOrderItem.Agent_Status__c = 'PTO/Agents Payments Completed';
                    } else {
                        objNewOrderItem.Is_PTO_Fee_Paid__c = false;
                        objNewOrderItem.addError('Payment from client not yet received');
                    }
                }
                //Mark the renewal as paid - To Agent
                if (isPaymentConfirmationAttached &&
                    objOldOrderItem != null &&
                    objOldOrderItem.Is_Agent_fee_paid__c == false &&
                    objNewOrderItem.Is_Agent_fee_paid__c == true
                ) {
                    if (
                        objNewOrderItem.Payment_Status__c == 'Payment Received' ||
                        (objNewOrderItem.Payment_Status__c == 'Payment Requested' && objNewOrderItem.Payment_Approval_Status__c == 'Approved')
                    ) {
                        objNewOrderItem.Payment_Status__c = 'PTO/Agent Payments Completed';
                        objNewOrderItem.Agent_Status__c = 'PTO/Agents Payments Completed';
                    } else {
                        objNewOrderItem.Is_Agent_fee_paid__c = false;
                        objNewOrderItem.addError('Payment from client not yet received');
                    }
                }
                
                //BUTTON: Mark as Renewed
                //Mark the renewals as 'Asset Renewed'
                if (
                    objOldOrderItem != null &&
                    objOldOrderItem.Is_it_renewed_in_PTO__c == false &&
                    objNewOrderItem.Is_it_renewed_in_PTO__c == true
                    
                ) {
                    if (objNewOrderItem.Payment_Status__c == 'PTO/Agent Payments Completed') {
                        objNewOrderItem.Payment_Status__c = 'Asset Renewed';
                        objNewOrderItem.Agent_Status__c = 'Asset Renewed';
                        objNewOrderItem.Renewal_Status__c = 'Asset Renewed';
                        
                    } else {
                        objNewOrderItem.Is_it_renewed_in_PTO__c = false;
                        objNewOrderItem.addError('PTO/Agent Payment not yet completed');
                    }
                }
                
                // if 
                //(
                //    objNewOrderItem.Payment__c != null && objNewOrderItem.Payment_Status__c == 'Waiting to Invoice'
                //)
                //{
                //    objNewOrderItem.Payment_Status__c = 'Payment Received';
                //}
                //BUTTON: Mark as Renewed
                //Mark the renewals as 'Asset Renewed'
                //Harsha added on 21/10/20
                if (objOldOrderItem != null && objOldOrderItem.Payment_Status__c == objNewOrderItem.Payment_Status__c && objNewOrderItem.Payment_Status__c == 'Waiting to Invoice') {
                    if (
                        (objNewOrderItem.Payment_Approval_Status__c != null && objNewOrderItem.Payment_Approval_Status__c != '') ||
                        (objNewOrderItem.Payment_Approve_Requested_From__c != null) ||
                        (objNewOrderItem.Send_for_approval_to_pay_PTO_fee__c != false)
                    ) {
                        objNewOrderItem.addError('You can\'t take this action on non invoiced records');
                    }
                }
                //Harsha added on 25-08-2020
                if (
                    objOldOrderItem != null &&
                    objOldOrderItem.Is_send_to_Validate_with_PTO__c == false &&
                    objNewOrderItem.Is_send_to_Validate_with_PTO__c == true
                    
                ) {
                    if (objNewOrderItem.Payment_Status__c == 'Payment Received' && (objNewOrderItem.PTO_Validation_Status__c == null || objNewOrderItem.PTO_Validation_Status__c == '')) {
                        objNewOrderItem.PTO_Validation_Status__c = 'Request to Validate';
                    }
                    if (objNewOrderItem.Payment_Status__c == 'Payment Requested' && objNewOrderItem.Payment_Approval_Status__c == 'Approved') {
                        objNewOrderItem.PTO_Validation_Status__c = 'Request to Validate';
                    }
                }
                /*Harsha added for validation*/
                if (usr.Is_ADU_Manager__c != true && objOldOrderItem.Send_for_approval_to_pay_PTO_fee__c == false && objNewOrderItem.Send_for_approval_to_pay_PTO_fee__c == true) {
                    objNewOrderItem.Payment_Approval_Status__c = 'Requested to Approve';
                    //if(objNewOrderItem.Invoice__c!=null)
                    // Inv_ID.add(objNewOrderItem.Invoice__c);
                    
                }
                if (usr.Is_ADU_Manager__c != true && objOldOrderItem.Payment_Approval_Status__c != 'Approved' && objOldOrderItem.Payment_Approval_Status__c != objNewOrderItem.Payment_Approval_Status__c && (objNewOrderItem.Payment_Approval_Status__c == null || objNewOrderItem.Payment_Approval_Status__c == '')) {
                    objNewOrderItem.Send_for_approval_to_pay_PTO_fee__c = false;
                }
                if (usr.Is_ADU_Manager__c != True && objOldOrderItem.Payment_Approval_Status__c != 'Requested to Approve' && objNewOrderItem.Payment_Approval_Status__c == 'Requested to Approve')
                    objNewOrderItem.Payment_Approve_Requested_From__c = UserInfo.getUserId();
                if ((usr.Is_ADU_Manager__c == True && usr.Profile.Name != 'System Administrator') && objOldOrderItem.Payment_Approve_Requested_From__c != objNewOrderItem.Payment_Approve_Requested_From__c) {
                    objNewOrderItem.Payment_Approve_Requested_From__c.addError('ADU only can request.');
                }
                if ((usr.Is_ADU_Manager__c != True && usr.Profile.Name != 'System Administrator') && objOldOrderItem.Payment_Approve_Requested_From__c != null && objOldOrderItem.Payment_Approve_Requested_From__c != objNewOrderItem.Payment_Approve_Requested_From__c && objOldOrderItem.Payment_Approval_Status__c != 'Approved' && objOldOrderItem.Payment_Approval_Status__c != 'Declined') {
                    objNewOrderItem.Payment_Approve_Requested_From__c.addError('ADU only can request.');
                }
                /*if (objOldOrderItem.Is_send_to_Validate_with_PTO__c != objNewOrderItem.Is_send_to_Validate_with_PTO__c && objNewOrderItem.Jurisdiction__c != 'US') {
                    objNewOrderItem.Is_send_to_Validate_with_PTO__c.addError('Validation is only for US records');
                }*/
                if (objOldOrderItem.Payment_Approval_Status__c != objNewOrderItem.Payment_Approval_Status__c && objNewOrderItem.Payment_Approval_Status__c == 'Declined') {
                    objNewOrderItem.Send_for_approval_to_pay_PTO_fee__c = false;
                    objNewOrderItem.Payment_Approve_Requested_From__c = null;
                }
                if ((usr.Is_ADU_Manager__c != True && usr.Profile.Name != 'System Administrator') && objOldOrderItem.Payment_Approval_Status__c != objNewOrderItem.Payment_Approval_Status__c && (objNewOrderItem.Payment_Approval_Status__c == 'Declined' || objNewOrderItem.Payment_Approval_Status__c == 'Approved'))
                    objNewOrderItem.Payment_Approval_Status__c.addError('ADU Manager/System Admin can Approve or Decline');
                /*Sanjay added for validation*/
                if (usr.Is_ADU_Manager__c == True && objOldOrderItem.Payment_Approval_Status__c != 'Requested to Approve' && objNewOrderItem.Payment_Approval_Status__c == 'Requested to Approve')
                    objNewOrderItem.Payment_Approval_Status__c.addError('ADU can Request.');
                //-----------------------------
            }
            /* for(Order_Item__c  ObjOdrItem: Trigger.new)
            {
            Order_Item__c  oldObj = Trigger.oldMap.get(ObjOdrItem.Id);
            system.debug('oldObj '+ oldObj );
            if(oldObj.Is_it_renewed_in_PTO__c == True && ObjOdrItem.Is_it_renewed_in_PTO__c== True   )
            {
            ObjOdrItem.addError('You can not make asset renewed again');
            }
            } */         
            
            //MARS-291 MaRS - Ability to mark an Asset as Renewed Externally
        	if(ExternallyRenewedAssets.size() > 0)
            {
                //Send payment status to Symphony
                batchInstructionStatusUpdate CA= NEW batchInstructionStatusUpdate(ExternallyRenewedAssets,'Renewed Externally');
                database.executebatch(CA, 1);
            }
        
        }   
    }    
    
    //EVENT: After
    if (trigger.isAfter) {
        
        if (trigger.isInsert || trigger.isUpdate) {
            if (Trigger.isInsert) {
                BatchQueueHelper.CreateBatchQueueForOrderItem(Trigger.New);
                set < id > requestedToPTOAutomate = NEW set < id > (); //Thulasi
                for( Order_Item__c objOrderItem: trigger.new ){//Thulasi
                   // if(objOrderItem.Is_send_to_Validate_with_PTO__c==true &&objOrderItem.PTO_Validation_Status__c =='Request to Validate' && objOrderItem.Order__r.Client__c!=null){
                        //requestedToPTOAutomate.add(objOrderItem.Order__r.Client__c); 
                        requestedToPTOAutomate.add(objOrderItem.id);
                    //}
                }
                
                if (requestedToPTOAutomate.size() > 0) {
                    BatchQueueHelper.BatchQueueForOrderItemForPTOvalidation(requestedToPTOAutomate);//Thulasi
                }
                
            }
            if (Trigger.isUpdate) {
                BatchQueueHelper.CreateBatchQueueForRecordPayment(Trigger.old, Trigger.New);
                
                for(Order_Item__c objNewOrderItem:trigger.new  ){
                    Order_Item__c  objOldOrderItem= Trigger.oldMap.get(objNewOrderItem.ID);
                    
                    if(objOldOrderItem.Send_for_approval_to_pay_PTO_fee__c == false && objNewOrderItem.Send_for_approval_to_pay_PTO_fee__c == true){
                        if(objNewOrderItem.Invoice__c!=null)
                            Inv_ID.add(objNewOrderItem.Invoice__c);
                        system.debug('Inv_IDInv_ID'+Inv_ID);
                        
                    }
                    
                    
                }
                if(Inv_ID.size()>0){
                    list<Invoice__c > listinv=[select id,Invoice_Currency__c,Invoice_Amount__c,Invoice_No__c from Invoice__c where id in:Inv_ID];
                    system.debug('listinv'+listinv);
                    list<string> Listcurrency=new list<string>();
                    if(listinv.size()>0){
                        for(Invoice__c Objinvoice : listinv)
                        {
                            If(Objinvoice.Invoice_Currency__c !='USD')
                            {
                                Listcurrency.add(Objinvoice.Invoice_Currency__c);
                                system.debug('Listcurrency'+Listcurrency);
                            }
                        }
                        Map<string, decimal> MapCurrency=new Map<string, decimal>();
                        If(Listcurrency.size()>0)
                        {
                            List<Currency__c> ObjCurrencyList=[SELECT id ,name,Exchange_Rate__c FROM Currency__c WHERE name =: Listcurrency ] ;
                            //Map<string, decimal> MapCurrency=new Map<string, decimal>();
                            if(ObjCurrencyList.size()>0)
                                for(Currency__c ObjCurrency : ObjCurrencyList )
                            {
                                MapCurrency.put(ObjCurrency.Name, ObjCurrency.Exchange_Rate__c);
                                system.debug('MapCurrency'+MapCurrency);
                            }
                        }
                        if(Listcurrency.size()>0){
                            List<Invoice__c >ObjInvoiceListinsert = new List<Invoice__c >();
                            List<Invoice__c >ObjInvoiceListupdate = new List<Invoice__c >(); 
                            for(Invoice__c Objinv : listinv)
                            {
                                //Decimal myNumber = MapCurrency.get(Objinv.Invoice_Currency__c);
                                //system.debug('myNumber '+myNumber );
                                //Decimal D= Decimal.valueOf(myNumber );
                                Decimal D = MapCurrency.get(Objinv.Invoice_Currency__c);
                                system.debug('D '+D );
                                Invoice__c Objnewinvoice= new  Invoice__c ();
                                //Objnewinvoice.Invoice_Amount__c=Objnewinvoice.Invoice_Amount__c!=null?Objnewinvoice.Invoice_Amount__c/D:0;
                                Objnewinvoice.Invoice_Amount__c=Objinv.Invoice_Amount__c!=null?Objinv.Invoice_Amount__c/D:0;
                                system.debug('Objnewinvoice.Invoice_Amount__c'+Objnewinvoice.Invoice_Amount__c);                      
                                system.debug('Objnewinvoice.Invoice_Amount__c/D'+Objnewinvoice.Invoice_Amount__c!=null?Objnewinvoice.Invoice_Amount__c/D:0);
                                Objnewinvoice.Invoice_No__c=Objinv.Invoice_No__c;
                                Objnewinvoice.Parent__c=Objinv.id;
                                system.debug('ObjInvoiceListupdate'+Objinv.id);
                                Objnewinvoice.Is_Active__c=True;
                                Objinv.Is_Active__c=false;
                                ObjInvoiceListupdate.add(Objinv);
                                system.debug('ObjInvoiceListupdate'+ObjInvoiceListupdate);
                                ObjInvoiceListinsert.add(Objnewinvoice);
                                system.debug('ObjInvoiceListinsert'+ObjInvoiceListinsert);
                                
                            }
                            If(ObjInvoiceListinsert.size()>0)
                            {
                                INSERT ObjInvoiceListinsert;
                            }
                            If(ObjInvoiceListupdate.size()>0)
                            {
                                update ObjInvoiceListupdate;
                            }
                        }
                    }
                }
                
            }
            system.debug('From trigger');
            string orgURL = string.valueOf(URL.getSalesforceBaseUrl().toExternalForm());
            boolean sendPaymentApprovedMail = false;
            list < string > listApplicationApprovedNos = NEW list < string > ();
            list < string > requestForGetFilingRecipt = NEW List < string > ();
            list < string > CancellationApprovedID = NEW List < string > ();
            list < string > AssetRenewedID = NEW List < string > ();
            list < string > InvoicedAssets = NEW List < string > ();
            list < string > CancellationDeclinedID = NEW List < string > ();
            list < string > CancellationRequestedID = NEW List < string > ();
            list < string > listInstructFailedIds = NEW List < string > ();
            Map < string, string > mapDecisionOnAppNo = NEW Map < string, string > ();
            Map < string, id > mapPTOValReqIDWWithOI = NEW Map < string, id > ();
            Map < Id, Id > mapOrderIds = new Map < Id, Id > ();
            set < id > requestedToPTO = NEW set < id > ();
            List <string> PaymentCompletedId = new List <string>();
            List <string> PaymentReceivedId = new List <string>();
			List <string> PaymentNotReceivedId = new List <string>();
            //Harsha added on 25-08-2020
            List < Order_Item__c > objOrderItemToApprove = NEW List < Order_Item__c > ();
            for (Order_Item__c objOrderItem: [SELECT Id, Invoice__c,Send_for_approval_to_pay_PTO_fee__c, Order__c, Application_No__c,Payment__c, Payment_Approval_Status__c, Is_send_to_Validate_with_PTO__c, PTO_Validation_Status__c, client__c, Order__r.Client__c, PTO_Validation_Request_ID__c, Filing_Receipt_File_Id__c, Cancellation_Approval__c, Payment_Status__c FROM Order_Item__c WHERE id IN: trigger.new]) {
                if (mapOrderIds.containsKey(objOrderItem.Order__c) == false) {
                    mapOrderIds.put(objOrderItem.Order__c, objOrderItem.Order__c);
                }
                system.debug('objOrderItem.Payment_Approval_Status__c' + objOrderItem.Payment_Approval_Status__c);
                if (trigger.isInsert) {
                    if (objOrderItem.Payment_Approval_Status__c == 'Approved' || objOrderItem.Payment_Approval_Status__c == 'Declined') {
                        listApplicationApprovedNos.add('<a href=' + orgURL + '/' + objOrderItem.id + '>' + objOrderItem.Application_No__c + '</a>');
                        String appNos = mapDecisionOnAppNo.get(objOrderItem.Payment_Approval_Status__c);
                        if (appNos == null) {
                            mapDecisionOnAppNo.put(objOrderItem.Payment_Approval_Status__c, '<a href=' + orgURL + '/' + objOrderItem.id + '>' + objOrderItem.Application_No__c + '</a>');
                        } else {
                            appNos += '<br/><a href=' + orgURL + '/' + objOrderItem.id + '>' + objOrderItem.Application_No__c + '</a>';
                        }
                    }
                }
                if (trigger.isUpdate) {
                    Order_Item__c oldoi = Trigger.oldMap.get(objOrderItem.Id);  
                    //----
                    if (oldoi.Payment_Approval_Status__c != 'Requested to Approve' && objOrderItem.Payment_Approval_Status__c == 'Requested to Approve') {
                        objOrderItemToApprove.add(objOrderItem);
                    }
                    //-----
                    if ((oldoi.Payment_Approval_Status__c != 'Approved' && objOrderItem.Payment_Approval_Status__c == 'Approved') || (oldoi.Payment_Approval_Status__c != 'Declined' && objOrderItem.Payment_Approval_Status__c == 'Declined')) {
                        listApplicationApprovedNos.add('<a href=' + orgURL + '/' + objOrderItem.id + '>' + objOrderItem.Application_No__c + '</a>');
                        String appNos = mapDecisionOnAppNo.get(objOrderItem.Payment_Approval_Status__c);
                        if (appNos == null) {
                            mapDecisionOnAppNo.put(objOrderItem.Payment_Approval_Status__c, '<a href=' + orgURL + '/' + objOrderItem.id + '>' + objOrderItem.Application_No__c + '</a>');
                        } else {
                            appNos += '<br/><a href=' + orgURL + '/' + objOrderItem.id + '>' + objOrderItem.Application_No__c + '</a>';
                            mapDecisionOnAppNo.put(objOrderItem.Payment_Approval_Status__c, appNos);
                        }
                    }
                    //Harsha added on 25-08-2020
                    if (oldoi.Is_send_to_Validate_with_PTO__c == false && objOrderItem.Is_send_to_Validate_with_PTO__c == true) {
                        //requestedToPTO.add(objOrderItem.Order__r.Client__c);
                        requestedToPTO.add(objOrderItem.id);
                    }
                    /*if((oldoi.PTO_Validation_Request_ID__c == null ||oldoi.PTO_Validation_Request_ID__c == '')  && objOrderItem.PTO_Validation_Request_ID__c != null)
                    {
                    mapPTOValReqIDWWithOI.put(objOrderItem.PTO_Validation_Request_ID__c,objOrderItem.id);
                    }*/
                    if (objOrderItem.Filing_Receipt_File_Id__c != oldoi.Filing_Receipt_File_Id__c && objOrderItem.Filing_Receipt_File_Id__c != null && objOrderItem.Filing_Receipt_File_Id__c != '') {
                        requestForGetFilingRecipt.add(objOrderItem.id);
                    }
                    if (objOrderItem.Invoice__c != oldoi.Invoice__c && objOrderItem.Invoice__c != null) {
                        InvoicedAssets.add(objOrderItem.id);
                    }
                    
                    
                    if (objOrderItem.Cancellation_Approval__c != oldoi.Cancellation_Approval__c && objOrderItem.Cancellation_Approval__c != null && objOrderItem.Cancellation_Approval__c == 'Approved') 
                    	CancellationApprovedID.add(objOrderItem.id);
                    
                    //MARS-735 - Renewal Status update to symphony - Added by Sneha    
                    if (objOrderItem.payment_status__c!= oldoi.payment_status__c&& objOrderItem.payment_status__c!= null && objOrderItem.payment_status__c== 'PTO/Agent Payments Completed') {
                        PaymentCompletedId.add(objOrderItem.id);
                    } 
                    
                    if (objOrderItem.payment_status__c!= oldoi.payment_status__c&& objOrderItem.payment_status__c!= null && objOrderItem.payment_status__c== 'Payment Received') {
                        PaymentReceivedId.add(objOrderItem.id);
                    }
                    if (objOrderItem.payment_status__c!= null && objOrderItem.payment_status__c== 'Payment Requested' && objOrderItem.Send_for_approval_to_pay_PTO_fee__c== true && objOrderItem.Payment_Approval_Status__c=='Approved' ) {
                        PaymentNotReceivedId.add(objOrderItem.id);
                    }

                    if (objOrderItem.payment_status__c!= oldoi.payment_status__c&& objOrderItem.payment_status__c!= null && objOrderItem.payment_status__c== 'Asset Renewed') {
                        AssetRenewedID.add(objOrderItem.id);
                    }    
                    
                    if (objOrderItem.Cancellation_Approval__c != oldoi.Cancellation_Approval__c && objOrderItem.Cancellation_Approval__c != null && objOrderItem.Cancellation_Approval__c == 'Declined') {
                        CancellationDeclinedID.add(objOrderItem.id);
                    }
                    if (objOrderItem.Cancellation_Approval__c != oldoi.Cancellation_Approval__c && objOrderItem.Cancellation_Approval__c != null && objOrderItem.Cancellation_Approval__c == 'Requested') {
                        CancellationRequestedID.add(objOrderItem.id);
                    }
                    if (objOrderItem.Payment_Status__c != oldoi.Payment_Status__c && objOrderItem.Payment_Status__c != null && objOrderItem.Payment_Status__c == 'Instruct Failed') {
                        listInstructFailedIds.add(objOrderItem.id);
                    }
                }
            }
            //Harsha added on 25-08-2020
            if (requestedToPTO.size() > 0) {
                BatchQueueHelper.BatchQueueForOrderItemForPTOvalidation(requestedToPTO);
            }
            /*if(mapPTOValReqIDWWithOI.size()>0)
            {
            BatchQueueHelper.ForOrderItemForPTOvalidationDocument(new set<id>(mapPTOValReqIDWWithOI.values()));
            }*/
            if (requestForGetFilingRecipt.size() > 0) {
                batchFilingReceiptContentDetailsToSymp bs = NEW batchFilingReceiptContentDetailsToSymp(requestForGetFilingRecipt);
                database.executebatch(bs, 1);
            }
            //MARS-735 - Renewal Status update to symphony - Added by Sneha
           if (PaymentCompletedId.size() > 0) {
               batchInstructionStatusUpdate CA= NEW batchInstructionStatusUpdate(PaymentCompletedId,'PTO Payment Completed');
               database.executebatch(CA, 1);
           }
           if (PaymentReceivedId.size() > 0) {
               batchInstructionStatusUpdate CA= NEW batchInstructionStatusUpdate(PaymentReceivedId,'Payment Received');
               database.executebatch(CA, 1);
           }
           
           if (PaymentNotReceivedId.size() > 0) {
               batchInstructionStatusUpdate CA= NEW batchInstructionStatusUpdate(PaymentNotReceivedId,'Payment not Received/PTO Payment in Progress');
               database.executebatch(CA, 1);
           }
            
           if (AssetRenewedID.size() > 0) {
               AssetRenewedStatusUpdate CA= NEW AssetRenewedStatusUpdate(AssetRenewedID);
               database.executebatch(CA, 1);
           }
         
           
            if (CancellationApprovedID.size() > 0) 
            {
                batchInstructionStatusUpdate CA = NEW batchInstructionStatusUpdate(CancellationApprovedID, 'Approved');
                database.executebatch(CA, 1);
                //CancellationApprovalToRenew CA = NEW CancellationApprovalToRenew (CancellationApprovedID);
                // database.executebatch(CA ,1);
            }
            if (CancellationDeclinedID.size() > 0) {
                batchInstructionStatusUpdate CA = NEW batchInstructionStatusUpdate(CancellationDeclinedID, 'Rejected');
                database.executebatch(CA, 1);
            }
            //if (CancellationRequestedID.size() > 0) {
                //batchInstructionStatusUpdate CA = NEW batchInstructionStatusUpdate(CancellationRequestedID, 'Cancel');
                //database.executebatch(CA, 1);
            //}
            if (listInstructFailedIds.size() > 0) {
                batchFailedInstructionStatusUpdate bc = NEW batchFailedInstructionStatusUpdate(listInstructFailedIds);
                database.executebatch(bc, 1);
            }
            /*if (InvoicedAssets.size() > 0) {
                batchInstructionStatusUpdate CA = NEW batchInstructionStatusUpdate(InvoicedAssets, 'Invoiced');
                database.executebatch(CA, 1);
            }*/
            if (trigger.isInsert) {
                //OrderItemHelper.UpdateOrderAmount(mapOrderIds.keySet());
            }
            if (objOrderItemToApprove.size() > 0) {
                List < string > groupMbrMails = updateOrderItemsOnPayToPTO.getEmailAddresses();
                if (groupMbrMails.size() > 0) {
                    try {
                        updateOrderItemsOnPayToPTO.sendEmailtoMgr(groupMbrMails, objOrderItemToApprove);
                    } catch (exception e) {
                        AuditTrailHelper.UpdateAudit('Trigger Assets', 'Error: ' + e.getmessage(), 'Fail');
                    }
                }
            }
            if (listApplicationApprovedNos.size() > 0) {
                List < User > ADUUsers = [SELECT Id, Email, Name FROM User WHERE Profile.Name = 'ADU'
                                          and isActive = true and Is_ADU_Manager__c = false
                                         ];
                if (ADUUsers.size() > 0) {
                    List < EmailTemplate > emailTemplate = [select Id, Name, Subject, HtmlValue, Body from EmailTemplate where Name = 'Notify the ADU that Manager Approve/Decline to Pay Non Payment'
                                                            Limit 1
                                                           ];
                    List < Messaging.SingleEmailMessage > allMails = new List < Messaging.SingleEmailMessage > ();
                    string MgrUserName = UserInfo.getName();
                    for (User usr: aduusers) {
                        string mailTableStart = '<table border="1"><tr><th>Status</th><th>Application No.</th></tr>';
                        string mailTableRows = '';
                        string mailTableEnd = '</table>';
                        /*for(string appNo : listApplicationApprovedNos)
                        {
                        mailTableRows+='<tr><td>'+appNo+'</td></tr>';
                        }*/
                        for (string status: mapDecisionOnAppNo.keyset()) {
                            mailTableRows += '<tr><td>' + status + '</td><td>' + mapDecisionOnAppNo.get(status) + '</tr>';
                        }
                        List < String > toAddresses = new List < String > ();
                        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                        toAddresses.add(usr.email);
                        //toAddresses.add('harsha@maxval.com');
                        mail.setToAddresses(toAddresses);
                        String subject = emailTemplate[0].Subject;
                        if (subject.contains('{day}'))
                            subject = subject.replace('{day}', '');
                        String htmlBody = emailTemplate[0].HtmlValue;
                        htmlBody = htmlBody.replace('{ADU}', usr.Name); //
                        htmlBody = htmlBody.replace('{user}', MgrUserName);
                        htmlBody = htmlBody.replace('mailTableStart', mailTableStart);
                        htmlBody = htmlBody.replace('mailTableRows', mailTableRows);
                        htmlBody = htmlBody.replace('mailTableEnd', mailTableEnd);
                        htmlBody = htmlBody.replace('<![CDATA[', '');
                        htmlBody = htmlBody.replace(']]>', '</div>');
                        mail.setSubject(subject);
                        mail.setHtmlBody(htmlBody);
                        /*if ( owea.size() > 0 ) {
                        mail.setOrgWideEmailAddressId(owea.get(0).Id);
                        }*/
                        allMails.add(mail);
                    }
                    system.debug(allMails.size());
                    if (!test.isRunningTest() && allMails.size() > 0) {
                        try {
                            Messaging.sendEmail(allMails);
                        } catch (exception e) {
                            AuditTrailHelper.UpdateAudit('Trigger Assets', 'Error: ' + e.getmessage(), 'Fail');
                        }
                    }
                }
            }
        }
    } 
}