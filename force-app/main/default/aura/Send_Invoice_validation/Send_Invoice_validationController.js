({
	Send_invoice_js : function(component, event, helper) {
		var action = component.get("c.Send_invoice");
        action.setParams({ parentRecId : component.get("v.recordId") });
        
        action.setCallback(this, function(response){ 
            var state = response.getState();
            var responseMsg = JSON.parse(JSON.stringify(response.getReturnValue()));
            if (state === "SUCCESS") {
                
               if(responseMsg.startsWith("ERROR:")){
                	component.set("v.recordError", responseMsg.replace("ERROR:",""));
                }
                else{
                    component.set("v.SaveMsg", responseMsg);
                    $A.get('e.force:refreshView').fire();
                }
            } 
        });
        $A.enqueueAction(action);
	}
})