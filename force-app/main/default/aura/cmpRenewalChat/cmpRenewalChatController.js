({
	doInit : function(component, event, helper) {
        helper.doInitHelper(component, event, helper);
        setInterval(function(){helper.doInitHelper(component, event, helper);}, 10000);
	},
    sendChat : function(component, event, helper) {
        //alert('In progress...');
        helper.sendChatHelper(component, event, helper);
	},
})