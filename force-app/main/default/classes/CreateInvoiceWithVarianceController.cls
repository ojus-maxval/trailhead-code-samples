/* Copyright © 2021 MaxVal Group. All Rights Reserved.
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Saranyaa C, August 2021
 */
public with sharing class CreditMemoDatatable {
    private ApexPages.StandardSetController standardController;
    Public list<String> selectedAssetIds{Set;Get;}
    list<Order_Item__c> selectedAssets = new list<Order_Item__c>(); 
   	public  static List<Order_Item__c> assets = new List<Order_Item__c>();
    Public String listviewURL{Set;Get;}
    Public String client = '';
    Public static Boolean isInvalid {Set;Get;} 
    Public static String disableSubmit {Set;Get;} 
    Public static String errorMessage{Set;Get;} 
    Public static String duplicateErrorMessage{Set;Get;}
    Public static Boolean isAlreadyAvailable{Set;Get;}
    Public string strAuditText = '';
    
 	Public CreditMemoDatatable(ApexPages.StandardSetController controller) {
        this.standardController = controller;
        GetListViewURL(); //Get return URL 
        GetSelectedAssetIds(); //Get list of ids of the selected Assets
        isInvalid = False;
        disableSubmit = '';
        duplicateErrorMessage = 'Credit Memo is already available for the asset(s) - ';
        isAlreadyAvailable = False;
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
    Public void GetSelectedAssetIds(){
        //Get list of ids of the selected Assets
        selectedAssetIds = New List <String> ();
        selectedAssets = (Order_Item__c[])this.standardController.getSelected();
        if(selectedAssets!=null && selectedAssets.size()>0)
        {     
            for(Order_Item__c orderitem : selectedAssets){
            	selectedAssetIds.add(orderitem.Id);
            }
        }
    }
    
    /*
     * Gets the details of the assets which are selected.
	*/
    public List<Order_Item__c> getAssets() {
        try{
        //Get all asset details
        assets = [SELECT Name,Credit_Memo__r.API_Status__c,Credit_Memo__c,Application_No__c,Patent_No__c,Order__r.Name,Fee_Amount_When_Instruct__c,Service_Fee_Amount_When_Instruct__c,Variance_Amount__c,CreditMemo_Amount__c,Payment_Status__c,Comments_for_Cancellation__c,CreditMemo_Comments__c,Order__r.Client__c,Credit_Memo__r.Name FROM Order_Item__c WHERE ID IN: selectedAssetIds];                
        if(assets.size() > 0)
        {
            client = assets[0].Order__r.Client__c;
            for(Order_Item__c asset : assets)
            {
                if(isAlreadyAvailable && asset.Credit_Memo__c != null){
                    duplicateErrorMessage += ', ';
                }
                if(asset.Credit_Memo__c != null && asset.Credit_Memo__r.API_Status__c != 'NotRequested' && asset.Credit_Memo__r.API_Status__c != 'ToBeRequested' ){
                    duplicateErrorMessage += asset.Name;    
                    isAlreadyAvailable = True;
                    isInvalid = True;
                }
                else{
                    //Initially populate the Amount column which the user can edit and Submit if needed.
                    if(asset.CreditMemo_Amount__c == 0.0 || asset.CreditMemo_Amount__c == null)
                    {
                        if(asset.Payment_Status__c == 'Cancelled') //Amount for cancelled assets = PTO Fee(Invoiced) - Service Fee Amount (When Instruct)
                        {
                            asset.CreditMemo_Amount__c = asset.Fee_Amount_When_Instruct__c - asset.Service_Fee_Amount_When_Instruct__c;
                        }
                        else if(asset.Payment_Status__c == 'PTO/Agent Payments Completed' || asset.Payment_Status__c == 'Asset Renewed')
                        {            
                            asset.CreditMemo_Amount__c = asset.Variance_Amount__c; //MARS-886 Capture PTO Payment Date, PTO Payment Amount, Bank Rate, Variance amount in the Renewal Asset 
                        }
                        else
                        {
                            errorMessage = 'Select assets with Payment Status - Cancelled (or) PTO/Agent Payments Completed (or) Asset Renewed';                    
                            isInvalid = True;
                            break;
                        }
                    }       
                    //Initially display the 'Cancellation Comments' in 'Comments' column which the user can edit and Submit if needed.
                     if(asset.CreditMemo_Comments__c == '' || asset.CreditMemo_Comments__c == null){
                        asset.CreditMemo_Comments__c = asset.Comments_for_Cancellation__c; 
                    }  
                    //Check if all the assets have same client id
                    if(client != asset.Order__r.Client__c)
                    {          
                        errorMessage = 'Assets of different clients cannot be selected';                    
                        isInvalid = True;
                        break;
                    }
                }                
        	}
            if(isAlreadyAvailable){
                errorMessage = duplicateErrorMessage;
            }
        }
        else{
            errorMessage = 'Select atleast one asset';
            isInvalid = True;           
        }
        }catch(Exception e)
        {
            strAuditText += 'Exception: ' + e.getMessage() + e.getLineNumber();
        }
        return assets;
    }
    
    /*
     * Triggered when the user clicks on Submit. Adds the creditmemo request to batch queue for processing.
	*/
    Public PageReference Submit() {
        Boolean canBeProceeded = True;
        //Valdiate mandatory fields
        for(Order_Item__c asset : assets){            
            if(asset.CreditMemo_Amount__c == null || asset.CreditMemo_Amount__c <= 0.0){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Amount should be greater than 0!'));
            	strAuditText += 'Amount entered is less than or equal to 0 | '; 
                canBeProceeded = False;
            }
            if(asset.CreditMemo_Comments__c == null || asset.CreditMemo_Comments__c == '' ){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Comments cannot be blank!'));
                canBeProceeded = False;
            	strAuditText += 'Comments is blank | '; 
            }
        }
        
        //If no error, proceed
        if(canBeProceeded) 
        {            
        	Decimal totalAmount = 0.0;
            //Calculate total amount
            for(Order_Item__c asset : assets){
                system.debug(asset.CreditMemo_Amount__c);
                totalAmount = totalAmount + asset.CreditMemo_Amount__c;
            }    
            strAuditText += 'Total amount calculated - '+ string.valueOf(totalAmount) +' | '; 
            
            //Insert CreditMemo
            Credit_Memo__c newCM = NEW Credit_Memo__c();
            newCM.Amount__c	 = totalAmount;
            newCM.Client__c	 = assets[0].Order__r.Client__c; // All the assets will be of same client's so take the client name of the first asset
            newCM.CreditMemo_Status__c	 = 'Todo';
            newCM.API_Status__c	 = 'ToBeRequested';            
            insert newCM;
            strAuditText += 'Inserted CreditMemo | '; 
            
            //Link the newly created CreditMemo with each Asset
            for(Order_Item__c asset : assets){
                asset.Credit_Memo__c = newCM.Id;
            }  
            update assets;
            strAuditText += 'Updated Assets | '; 
            
            //Make API call
            strAuditText += 'Adding request to BatchQueue | '; 
            List<String> creditMemos = new List<String>();
            creditMemos.add(newCM.Id);
            BatchQueueHelper.CreateBatchQueueForCreditMemoGeneration(creditMemos);
            //To get Domain URL - URL.getSalesforceBaseUrl().toExternalForm()
            String creditMemoDetailViewUrl = URL.getSalesforceBaseUrl().toExternalForm() + '/lightning/r/Credit_Memo__c/'+ newCM.Id +'/view'; 
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,'Request to generate CreditMemo has been placed! Check status ' + '<a href="'+ creditMemoDetailViewUrl +'">here</a>'));
            disableSubmit = 'this.disabled="disabled";';
        }else{
            disableSubmit = '';
        }
        AuditTrailHelper.UpdateAudit('CreditMemoDatatable',strAuditText,'');
        return null;
    }   
}