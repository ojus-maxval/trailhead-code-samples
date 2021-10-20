({
	doInitHelper : function(component, event, helper) {
		var action = component.get("c.getDetails");
        action.setParams({ sids : component.get("v.recordids")});
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            //alert(state);
            if (state === "SUCCESS") 
            {
                //alert("From server: " + JSON.stringify(response.getReturnValue()));
                component.set("v.AmountforSelectAssets",response.getReturnValue().AmtForSelectAssets);
                component.set("v.PaymentCurrencyOptions",response.getReturnValue().PaymentCurrencyPickList);
                component.set("v.PaymentTypeOptions",response.getReturnValue().PaymentMethodPickList);
                component.set("v.BankAccountOptions",response.getReturnValue().BankAccsPickList);
                component.set("v.CreditCardAccountOptions",response.getReturnValue().CCAccsPickList);
                component.set("v.OrderItemIds",response.getReturnValue().AssetIDs);
                component.set("v.data",response.getReturnValue().payAtt);
                //alert(JSON.stringify(response.getReturnValue().AssetIDs));
                if(response.getReturnValue().errorInData)
                {
                    component.set("v.isLoaded",true);
                    component.set("v.showCard",false);
                    component.set("v.message",response.getReturnValue().errorMessage);
                }
                else{
                    component.set("v.isLoaded",true);
                    component.set("v.showCard",true);
                }
            }
            if (state === "INCOMPLETE") 
            {
                console.log('INCOMPLETE');
            }
            if (state === "ERROR") {
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
    gotoURL : function(component) {
        //alert(component.get("v.recentListview"));
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
          "url": component.get("v.recentListview")
        });
        urlEvent.fire();
    },
    savePaymentHelper : function(component, event, helper, recordsList, actionType, ismgr) {
        var action = component.get("c.createPaymentConfirmation");
        action.setParams({ OIIds : component.get("v.OrderItemIds"), pc :  component.get("v.data")});
        action.setCallback(this, function(response) {
            var state = response.getState();
            //alert(state);
            if (state === "SUCCESS") 
            {
                //alert (response.getReturnValue());
                if(response.getReturnValue().startsWith('Success'))
                {
                    component.set("v.isLoaded",true);
                    component.set("v.showCard",false);
                    //component.set("v.message", response.getReturnValue());
                    sforce.one.showToast({
                        "title": "Success!",
                        "message": "The record has been created successfully.",
                        "type": "success"
                    });
                    window.location = component.get("v.recentListview");
                }
                else
                {
                    component.set("v.message", response.getReturnValue());
                    alert(response.getReturnValue());
                    sforce.one.showToast({
                        "title": "Error",
                        "message": "Something went wrong.",
                        "type": "error"
                    });
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
                            component.set("v.message", "Error message: " + errors[0].message);
                            console.log("Error message: " + errors[0].message);
                        }
                    } 
                    else {
                        console.log("Unknown error");
                    }
                    sforce.one.showToast({
                        "title": "Error",
                        "message": "Something went wrong.",
                        "type": "error"
                    });
                }
        });
        $A.enqueueAction(action);
    },
    showToast : function(component, event, helper) {
        alert(1);
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "Success!",
            "message": "The record has been updated successfully."
        });
        toastEvent.fire();
    }
})