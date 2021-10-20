({
	doInitHelper : function(component, event, helper) {
		//cmp.get("v.afterCreateWrapper",null);
		var action = component.get("c.getAllMessages");
        action.setParams({ recID : component.get("v.recordId")});
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            //alert(state);
            if (state === "SUCCESS") 
            {
                component.set("v.Chats",response.getReturnValue().renewalChats);
                component.set("v.mURL",response.getReturnValue().cURL);
                component.set("v.mReference",response.getReturnValue().MRefID);
                component.set("v.mCID",response.getReturnValue().cID);
                console.log('Data :'+response.getReturnValue());
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
    sendChatHelper : function(component, event, helper) {
		//cmp.get("v.afterCreateWrapper",null);
		var action = component.get("c.SendMessages");
        action.setParams({ MaRSReferenceID : component.get("v.mReference"),ChatMessage : component.get("v.vNewComments"),ClientID : component.get("v.mCID"),ClientURL : component.get("v.mURL")});
        action.setCallback(this, function(response) {
            var state = response.getState();
            //alert(state);
            if (state === "SUCCESS") 
            {
                component.set("v.vNewComments","");
                this.doInitHelper(component, event, helper);
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
})