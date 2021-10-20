({
    doInit: function(component, event, helper) {
        helper.getPicklistValues(component, event, helper);
    },
    handleOnload: function(component, event, helper) {
    },
    handleUploadWC: function (component, event, helper) {
        var uploadedFiles = event.getParam("files");
        component.set("v.wrFileId", uploadedFiles[0].documentId);
        component.set("v.newPC.WiredConfirmationId__c", uploadedFiles[0].documentId);
        component.set("v.wtitle",uploadedFiles[0].name);
        component.set("v.newPC.WiredConfirmationUploaded__c",true);
    },
    handleUploadPC: function (component, event, helper) {
        var uploadedPCFiles = event.getParam("files");
        //alert(JSON.stringify(uploadedPCFiles[0]));
        component.set("v.pcFileId", uploadedPCFiles[0].documentId);
        component.set("v.newPC.PaymentConfirmationId__c", uploadedPCFiles[0].documentId);
        component.set("v.ptitle",uploadedPCFiles[0].name);
        component.set("v.newPC.PaymentConfirmationUploaded__c",true);
    },
    handleOnSubmit : function(component, event, helper) {
        event.preventDefault();
        var fields = event.getParam("fields");
        //fields["AccountId"] = component.get("v.parentId");
        helper.updateHelper(component, event, helper,component.get("v.recordId"));
        component.find("form").submit(fields);
    },
    deleteFilew : function(component, event, helper) {
        //alert('deleteFilew');
        helper.deleteFileHelper(component, event, helper,component.get("v.recordId"),component.get("v.newPC.WiredConfirmationId__c"),'wired');
    },
    deleteFilep : function(component, event, helper) {
        helper.deleteFileHelper(component, event, helper,component.get("v.recordId"),component.get("v.newPC.PaymentConfirmationId__c"),'payment');
    },
    handleSavePC : function(component, event, helper) {
        helper.updateHelper(component, event, helper,component.get("v.recordId"));
    },
    cancelAction: function (component, event, helper) {
        //helper.gotoRecord(component, component.get("v.recordId"));
        component.set("v.isDetail",true);
    },
    editPC: function (component, event, helper) {
        component.set("v.isDetail",false);
    },
    
})