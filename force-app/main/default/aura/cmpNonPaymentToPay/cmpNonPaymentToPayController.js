({
    doInit : function(component, event, helper) {
        var recIDS =  component.get("v.recordids");
        helper.doInitHelper(component, event, helper);
    },
    closeModel: function(component, event, helper) {
        component.set("v.isModalOpen", false);
    },
    
    submitDetails: function(component, event, helper) {
        component.set("v.doPayment", true);
        component.set("v.isModalOpen", false);
    },
    payToPTO: function(component, event, helper) {
        //helper.payToPTOHelper(component, event, helper);
        component.set("v.isPayToPTOSelected", true);
        //alert('1');
        helper.updateHelper(component, event, helper, component.get("v.PaymentReceivedItems"), 'payToPTO', component.get("v.isMgr"));
    },
    reqToMngr: function(component, event, helper) {
        component.set("v.isReqToApproveSelected", true);
        helper.updateHelper(component, event, helper, component.get("v.PaymentNotReceivedItems"), 'reqToMngr',component.get("v.isMgr"));
    },
})