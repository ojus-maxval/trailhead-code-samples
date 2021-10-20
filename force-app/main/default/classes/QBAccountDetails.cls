public class QBAccountDetails {
    public   String accesstoken{get;set;}
    public API_Credentials__c credentials{set;get;}
     public List<String> AuthReferenceList{get;set;}
    public List<Account> ListAllAccountRcd{get;set;}
    public QBAccountDetails()
    {
        
        accesstoken = MaxValAPIAuthenticaionHelper.MaxValAPIAuthenticaionHelper();
        System.debug('accesstoken'+ accesstoken);
    }
    public list<Account> getAccountDetails(String accesstoken)
    {
        ListAllAccountRcd = new list<Account>();
        AuthReferenceList =new List<String>();
        string strAuditTrail = '';
        credentials = [SELECT Id,Name,URL__c,Username__c,Password__c FROM API_Credentials__c WHERE Name=: 'QB Accounts - Create'];
        List<API_Auth_Detail__c> ListOfAuthReference = [SELECT Name FROM API_Auth_Detail__c];
        for(API_Auth_Detail__c Auth:ListOfAuthReference)
        {
            AuthReferenceList.add(Auth.Name);
                
        }
        System.debug('AuthReferenceList'+AuthReferenceList);
        List<WrapperAccountDetails> CustomerList =new List<WrapperAccountDetails>();
        for(String AuthReference: AuthReferenceList)
        {
        Http hp = new Http();
        HttpRequest req =new HttpRequest();
        req.setHeader('Authorization', 'Bearer ' + accesstoken);
        req.setHeader('Content-Type','application/json;charset=UTF-8');
        req.setTimeout(120000);
        req.setMethod('GET');
        //req.setEndpoint(credentials.URL__c);
        String URLWithRef =credentials.URL__c;
        String AfterReplacingAuth = URLWithRef.replace('{authreference}', AuthReference);
        System.debug('AfterReplacingAuth'+AfterReplacingAuth);
        req.setEndpoint(AfterReplacingAuth);
        HttpResponse res = hp.send(req);
        if (res.getStatusCode() == 200) {
        //JSONParser parser = JSON.createParser(res.getBody());
        String jsonStr =  res.getBody();
        
        // Parse entire JSON response.
        WrapperAccountDetails WC =new WrapperAccountDetails();
        system.debug((WrapperAccountDetails) System.JSON.deserialize(jsonStr, WrapperAccountDetails.class));
        WrapperAccountDetails myObj =(WrapperAccountDetails) System.JSON.deserialize(jsonStr, WrapperAccountDetails.class);
        System.debug('MyObj'+myObj.Error);
        list<Account> lst =myObj.Data.Account;
        ListAllAccountRcd.addAll(myObj.Data.Account);
        System.debug('lst'+lst);
        }
        }
        return ListAllAccountRcd;
            
    } 
     public class WrapperAccountDetails
    {
        public Integer Status;
        public List<Error> Error;
        public List<Warning> Warning;
        public Data Data;
    }
     public class Warning {
        public String Code;
        public String Description;
    }
    public class Data 
    {
		public List<Account> Account;
	}
    public class Account {
		public String Name;
		public Boolean SubAccount;
		public String FullyQualifiedName;
		public Boolean Active;
		public String Classification;
		public String AccountType;
		public String AccountSubType;
		public decimal CurrentBalance;
		public decimal CurrentBalanceWithSubAccounts;
		public CurrencyRef CurrencyRef;
		public String domain;
		public Boolean sparse;
		public String Id;
		public String SyncToken;
		public MetaData MetaData;
	}

	public class CurrencyRef {
		public String value;
		public String name;
	}
	public class MetaData {
		public String CreateTime;
		public String LastUpdatedTime;
	}

	public class Error {
		public String Code;
		public String Description;
	}
}