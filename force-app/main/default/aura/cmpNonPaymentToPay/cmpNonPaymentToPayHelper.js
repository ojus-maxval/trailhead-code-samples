({
	doInitHelper : function(component, event, helper) {
		//cmp.get("v.afterCreateWrapper",null);
		var action = component.get("c.getRecords");
        action.setParams({ sids : component.get("v.recordids")});
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            //alert(state);
            if (state === "SUCCESS") 
            {
                //alert("From server: " + JSON.stringify(response.getReturnValue()));
                component.set("v.isMgr",response.getReturnValue().isMngr);
                component.set("v.PaymentReceivedItems",response.getReturnValue().paymentRecievedItems);
                component.set("v.PaymentNotReceivedItems",response.getReturnValue().paymentNotRecievedItems);
                component.set("v.isLoaded",true);
            }
            else if (state === "INCOMPLETE") 
            {
                console.log('INCOMPLETE');
            }
                else if (state === "ERROR") {
                    var errors = response.getError();
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
        });
        $A.enqueueAction(action);
	},
    payToPTOHelper : function(component, event, helper) {
        alert('payToPTOHelper - INCOMPLETE');
    },
    reqToMngrHelper : function(component, event, helper) {
        alert('reqToMngrHelper - INCOMPLETE');
    },
    updateHelper : function(component, event, helper, recordsList, actionType, ismgr) {
        var action = component.get("c.updateRecords");
        action.setParams({ ois : recordsList, actiontype : actionType, mgr:ismgr});
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            //alert(state);
            if (state === "SUCCESS") 
            {
                //alert("From server: " + JSON.stringify(response.getReturnValue()));
                if(actionType == 'payToPTO')
                {
                    //alert('2');
                	component.set("v.respOnPTO",response.getReturnValue());
                    //alert('3');
                }
                if(actionType == 'reqToMngr')
                {
                    //alert('2');
                	component.set("v.respOnReq",response.getReturnValue());
                    //alert('3');
                }
            }
            else if (state === "INCOMPLETE") 
            {
                console.log('INCOMPLETE');
                
            }
                else if (state === "ERROR") {
                    
                    var errors = response.getError();
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
        });
        $A.enqueueAction(action);
    },
})