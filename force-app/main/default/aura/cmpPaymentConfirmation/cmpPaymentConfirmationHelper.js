({
    getPicklistValues: function(component, event, helper) {
        var action = component.get("c.getPickListValuesIntoList");
        action.setParams({ 'pcId' : component.get("v.recordId") });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === 'SUCCESS'){
                var list = response.getReturnValue();
                //alert(JSON.stringify(list));
                component.set("v.paymentMethods", list.paymentmethodOptions);
                component.set("v.newPC", list.pc);
                component.set("v.wtitle", list.wiredTitle);
                component.set("v.wcvId", list.wiredcv);
                component.set("v.ptitle", list.paymentTitle);
                component.set("v.pcvId", list.paymentcv);
                component.set("v.disableds",true);
                //alert(JSON.stringify(list.pc));
            }
            else if(state === 'ERROR'){
                //var list = response.getReturnValue();
                //component.set("v.picvalue", list);
                alert('ERROR OCCURED.');
            }
        });
        $A.enqueueAction(action);
    },
    updateHelper : function(component, event, helper,recid) {
        var action = component.get("c.updateRecord");
        action.setParams({ paymentid : recid,rec: component.get("v.newPC"), wireconfirmationid : component.get("v.wrFileId"), paymentconfimationid : component.get("v.pcFileId")});
        action.setCallback(this, function(response) {
            var state = response.getState();
            var toastEvent = $A.get("e.force:showToast");
            if (state === "SUCCESS") 
            {
                toastEvent.setParams({
                    "type": "success",
                    "title": "Success!",
                    "message": "The record has been updated successfully."
                });
                //component.set("v.showSpinner",false);
                //component.set("v.recordData",response.getReturnValue());
                //this.doInitHelper(component, event, helper);
                //window.open('/'+recid,'_top');
				this.gotoRecord(component,recid);
            }
            else if (state === "INCOMPLETE") 
            {
                console.log('INCOMPLETE');
                
            }
                else if (state === "ERROR") {
                    
                    var errors = response.getError();
                    toastEvent.setParams({
                        "type": "error",
                        "title": "Error",
                        "message": response.getReturnValue()
                    });
                    if(actionType)
                    {
                        //component.set("v.respOnPTO",errors[0].message);
                    }
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " + 
                                        errors[0].message);
                        }
                    } 
                    else {
                        console.log("Unknown error");
                    }
                }
            toastEvent.fire();
            $A.get('e.force:refreshView').fire();   
        });
        $A.enqueueAction(action);
    },
    deleteFileHelper : function(component, event, helper,recid, docid,rectype) {
        var action = component.get("c.deleteFileRecord");
        action.setParams({ pcId : recid, fileDocId : docid, typeof : rectype});
        action.setCallback(this, function(response) {
            var state = response.getState();
            var toastEvent = $A.get("e.force:showToast");
            if (state === "SUCCESS") 
            {
                if(rectype == 'wired')
                {
                    component.set("v.newPC.WiredConfirmationId__c", null);
                    component.set("v.wtitle",null);
                    component.set("v.newPC.WiredConfirmationUploaded__c",false);
                }
                if(rectype == 'payment')
                {
                    component.set("v.newPC.PaymentConfirmationId__c", null);
                    component.set("v.ptitle",null);
                    component.set("v.newPC.PaymentConfirmationUploaded__c",false);
                }
                toastEvent.setParams({
                    "type": "success",
                    "title": "Success!",
                    "message": "The record has been updated successfully."
                });
            }
            else if (state === "INCOMPLETE") 
            {
                console.log('INCOMPLETE');
                
            }
                else if (state === "ERROR") {
                    
                    var errors = response.getError();
                    toastEvent.setParams({
                        "type": "error",
                        "title": "Error",
                        "message": response.getReturnValue()
                    });
                    if(actionType)
                    {
                        //component.set("v.respOnPTO",errors[0].message);
                    }
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " + 
                                        errors[0].message);
                        }
                    } 
                    else {
                        console.log("Unknown error");
                    }
                }
            toastEvent.fire();
        });
        $A.enqueueAction(action);
    },
    gotoRecord: function(component, recid) {
        //window.open('/'+recid,'_top');
        component.set("v.isDetail",true);
        $A.get('e.force:refreshView').fire();
    }
})