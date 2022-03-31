@isTest
private class APIMessageControllerTest{
    @isTest 
    static void myTest1() {
    
    APIMessage__c testM=new APIMessage__c();
    testM.name='test';
    insert testM;
    APIMessageController.GetAllMessages();
       
    }
}