global class BatchQBCustomerDetails implements Database.Batchable<QBCustomerDetails.Customer>,Database.Stateful,Database.AllowsCallouts { 
    public List<String> EmployeeIdsList{get;set;}
    public List<QBCustomerDetails.Customer> CustomerDataList{get;set;}
    public string  AccessToken{get;set;}
    public map<string, string> MapOfQBCustomerid = new map<string, string>();
    public Set<String> UniqueKeyParam = new Set<String>();
   
    public Iterable<QBCustomerDetails.Customer> start(Database.BatchableContext BC)
    {       
        QBCustomerDetails QB=new QBCustomerDetails();
        AccessToken=QB.accesstoken;
        CustomerDataList = QB.getCustomerDetails(AccessToken);
        System.debug(CustomerDataList.size());
        for(QBCustomerDetails.Customer Rcd :CustomerDataList)
        {
            UniqueKeyParam.add(Rcd.Id);
            MapOfQBCustomerid.put(Rcd.Id,Rcd.Id);
           //
        }
         System.debug('UniqueKeyParam'+UniqueKeyParam);
        return CustomerDataList;
        
    } 
    public void execute(Database.BatchableContext BC,List<QBCustomerDetails.Customer> CustomerDetail) 
    {
        map<string, string> ExistingRecordsCustomerid = new map<string, string>();
        
        Set<String> SetOfDeletedRcdIds = new Set<String>();
        set<string> AddedToList = new set<string>();
        
        list<QB_Customer__c> ListOfDeletedRecordsInQB = new List<QB_Customer__c>();
        list<QB_Customer__c> ListOfQBCustomer =new List<QB_Customer__c>();
        string strAuditTrail = '';
        string status = 'Success';
        strAuditTrail += 'QB Customer Record Creation: ';
        strAuditTrail += CustomerDetail;
        try
        { 
           
            
            List<QB_Customer__c> ListOfExistingQBCustomer = [SELECT Id,Name,QB_Customer_Id__c FROM QB_Customer__c WHERE QB_Customer_Id__c IN:UniqueKeyParam AND IsDeleted_In_QB__c =false];
            for(QB_Customer__c CustRcd :ListOfExistingQBCustomer)
            {
                ExistingRecordsCustomerid.put(CustRcd.QB_Customer_Id__c, CustRcd.Id);
              
            }
           List<QB_Customer__c> ListOfDeletedQBCustomerRcds = [SELECT Id,Name,QB_Customer_Id__c FROM QB_Customer__c WHERE QB_Customer_Id__c NOT IN:UniqueKeyParam AND IsDeleted_In_QB__c =false];
           for(QB_Customer__c CustRcd :ListOfDeletedQBCustomerRcds)
            {
                
               SetOfDeletedRcdIds.add(CustRcd.id);
               System.debug('SetOfDeletedRcdIds'+SetOfDeletedRcdIds);
                //System.debug('ExistingRecordsCustomerid'+ExistingRecordsCustomerid);
            }
            for(QBCustomerDetails.Customer Rcd :CustomerDetail)
            {
                
                Boolean addToList = False;
                QB_Customer__c CustomerRecord =new QB_Customer__c();
                CustomerRecord.QB_Customer_Id__c = Rcd.Id;
                CustomerRecord.Name =Rcd.DisplayName;
                CustomerRecord.Active__c =Rcd.Active;
                CustomerRecord.Currency_Reference__c =Rcd.CurrencyRef.value;
                String formatedDt = Rcd.MetaData.CreateTime;
                DateTime date1 = (DateTime)Json.deserialize('"'+formatedDt+'"', DateTime.class);
                CustomerRecord.Record_Create_Time__c = date1;
                CustomerRecord.Qualified_Name__c = Rcd.FullyQualifiedName;
                CustomerRecord.LastUpdatedTime__c =(DateTime)Json.deserialize('"'+Rcd.MetaData.LastUpdatedTime+'"', DateTime.class);  
                System.debug(date1);
                
                if(Rcd.PrimaryEmailAddr != null )
                {
                    if(Rcd.PrimaryEmailAddr.Address != null )
                    CustomerRecord.Primary_Email__c = Rcd.PrimaryEmailAddr.Address;
                }
				else
                {
                    CustomerRecord.Primary_Email__c  = '';
                }
                if(Rcd.PrimaryPhone != null )
                {
                    if(Rcd.PrimaryPhone.FreeFormNumber != null )
                    CustomerRecord.Phone_Number__c = Rcd.PrimaryPhone.FreeFormNumber;
                }
                else
                {
                    CustomerRecord.Phone_Number__c =  '';
                }
                if(Rcd.ParentRef != null )
                {
                    if(Rcd.ParentRef.value != null )
                    CustomerRecord.Sub_Customer__c =decimal.valueOf(Rcd.ParentRef.value);
                }
                else
                {
                    CustomerRecord.Sub_Customer__c   = null;
                }
                System.debug(ExistingRecordsCustomerid.get(Rcd.Id));
                if(ExistingRecordsCustomerid.get(Rcd.Id) !=  null)//Rcd.Id is the unique name which stored in name field
                {
                    CustomerRecord.Id = ExistingRecordsCustomerid.get(Rcd.Id);
                    System.debug(ExistingRecordsCustomerid.get(Rcd.Id));
                }
                if(CustomerRecord.Id != null)
                {
                    if(AddedToList.contains(CustomerRecord.Id))
                    {
                        addToList = False;
                    }
                    else
                    {
                        addToList = True;
                        AddedToList.add(CustomerRecord.Id);
                    }
                }
                else
                {
                    addToList = True;
                }
                if(addToList == True)
                {
                    ListOfQBCustomer.add(CustomerRecord);
                }
            }
            
            if(ListOfQBCustomer.size() > 0)
            {
                System.debug('ListOfQBCustomer>>>>>>'+ListOfQBCustomer);
                upsert ListOfQBCustomer;
            }
            if(SetOfDeletedRcdIds.size() > 0)
            {
                List<QB_Customer__c> ListOfDeletedQBCustomer = [SELECT Id,IsDeleted_In_QB__c FROM QB_Customer__c WHERE Id IN:SetOfDeletedRcdIds AND IsDeleted_In_QB__c =false];
                for(QB_Customer__c Cust: ListOfDeletedQBCustomer)
                {
                    Cust.IsDeleted_In_QB__c = true;
                    ListOfDeletedRecordsInQB.add(Cust);
                }
                if(ListOfDeletedRecordsInQB.size() > 0)
                {
                    update ListOfDeletedRecordsInQB;
                } 
            }
           
        }
        catch(Exception e)
        {
            strAuditTrail += ' || Error :'+e.getMessage();
            status = 'Fail';
        }
        finally
        {
            //system.debug(strAuditTrail);
            AuditTrailHelper.UpdateAudit('batchQBCustomerDetails',strAuditTrail,status);
        }
    }
    public void finish(Database.BatchableContext bc){
        // execute any post-processing operations
         //List<QB_Customer__c> ListOfDeletedQBCustomerRcds = [SELECT Id,Name,QB_Customer_Id__c FROM QB_Customer__c ]; 
        
    }  
    
    
}