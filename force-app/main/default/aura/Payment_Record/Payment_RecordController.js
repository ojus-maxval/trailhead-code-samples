({
    //Open URL in New Browser Tab
    handleOpenInNewWindow : function(component, event, helper) {
        window.open("https://marsff-dev-ed.lightning.force.com/lightning/o/Payment__c/new?count=1&nooverride=1&useRecordTypeCheck=1&navigationLocation=MRU_LIST&backgroundContext=%2Flightning%2Fo%2FPayment__c%2Flist%3FfilterName%3DRecent");
    },
     
    //Open URL in New Browser Tab With Record Id
    handleOpenNewWindowWithRecordId : function(component, event, helper) {
        var recordId = component.get('v.recordId');
        window.open('/' + recordId,'_blank');
    }
})