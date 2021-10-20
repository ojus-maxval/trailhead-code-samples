({
	loadFilingReceiptController : function(component, event, helper) 
    {
        var recordId = component.get('v.recordId');
        component.set('v.recordId', recordId);
	}
})