public with sharing class CreateInvoiceWithVarianceController {
    private ApexPages.StandardSetController standardController;
    Public list<String> selectedOrderIds{Set;Get;}
    list<Order__c> selectedOrders = new list<Order__c>(); 
   	public  static List<Order_Item__c> assets = new List<Order_Item__c>();
    Public String listviewURL{Set;Get;}
    Public String client = '';
    Public static Boolean isInvalid {Set;Get;} 
    Public static String disableSubmit {Set;Get;} 
    Public static String errorMessage{Set;Get;} 
    Public string strAuditText = '';
    
 	Public CreateInvoiceWithVarianceController(ApexPages.StandardSetController controller) {
        this.standardController = controller;
        GetListViewURL(); //Get return URL 
        GetSelectedOrderIds(); //Get list of ids of the selected Orders
        isInvalid = False;
        disableSubmit = '';
    }
    
    /*
     * Gets the Listview URL from where the assets are selected.
	*/
     Public void GetListViewURL(){
        //Get the return url if it's in Lightning view
        listviewURL = ApexPages.currentPage().getParameters().get('vfRetURLInSFX');
        If(listviewURL == null || listviewURL == '')
        {
            //Get the return url if it's in classic view
            listviewURL = ApexPages.currentPage().getParameters().get('retURL');
        }
    }
    
        /*
     * Gets all the selected asset ids.
	*/
    Public void GetSelectedOrderIds(){
        //Get list of ids of the selected Orders
        selectedOrderIds = New List <String> ();
        selectedOrders = (Order__c[])this.standardController.getSelected();
        if(selectedOrders!=null && selectedOrders.size()>0)
        {     
            for(Order__c orderitem : selectedOrders){
            	selectedOrderIds.add(orderitem.Id);
            }
        }
    }
    
     public List<Order_Item__c> getAssets() {
         try
         {
             if(selectedOrderIds.size() == 0){
                 errorMessage = 'Select atleast one order';
                 isInvalid = True;
             }else{
                 //Get all asset details
                assets = [SELECT Name,Application_No__c,Patent_No__c,Order__r.Name,Order__r.Client__c,Fee_Amount_When_Instruct__c,PTO_Payment_Amount__c,Service_Fee_Amount_When_Instruct__c,Variance_Amount__c,Payment_Status__c,Billing_Amount__c,Variance__c FROM Order_Item__c WHERE Order__c IN: selectedOrderIds AND Variance__c > 0];                
                selectedOrderIds = new list<Id>();
                 for(Order_Item__c asset : assets){
                     selectedOrderIds.add(asset.Order__c);
                 }
                 selectedOrders = new List<Order__c>();
                 selectedOrders = [SELECT Id FROM Order__c WHERE Id IN: selectedOrderIds];
                if(assets.size() > 0)
                {            
                    client = assets[0].Order__r.Client__c;
                    for(Order_Item__c asset : assets)
                    {                    
                        //Check if all the orders have same client id
                        if(client != asset.Order__r.Client__c)
                        {          
                            errorMessage = 'Orders of different clients cannot be selected';                    
                            isInvalid = True;
                            break;
                        }
                    }  
                }
                else{
                    errorMessage = 'The selected orders have no asset with positive variance';
                    isInvalid = True;           
                }
             }
            
        }
        catch(Exception e)
        {
            AuditTrailHelper.UpdateAudit('CreateInvoiceWithVarianceController','Exception: ' + e.getMessage() + e.getLineNumber(),'None');
        }
        return assets;
    }
    
    Public PageReference Submit() {
        for(Order__c order : selectedOrders){
            order.Payment_Status__c = 'Invoiced Variance Amount';
        }  
        update selectedOrders;
        AuditTrailHelper.UpdateAudit('CreateInvoiceWithVarianceController','updated','None');
        if (selectedOrderIds != null && selectedOrderIds.size() > 0)
        {
            AuditTrailHelper.UpdateAudit('CreateInvoiceWithVarianceController',' Invoices to be modified for the order(s):' + selectedOrderIds,'None');
            BatchQueueHelper.CreateBatchQueueForInvoiceGeneration(selectedOrderIds);
        }
        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,'Request to generate Invoice has been placed!'));
        return null;
    }
}