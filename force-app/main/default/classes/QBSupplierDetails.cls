public class QBSupplierDetails {
    public   String accesstoken{get;set;}
    public API_Credentials__c credentials{set;get;}
    public List<String> AuthReferenceList{get;set;}
    public QBSupplierDetails()
    {
        accesstoken = MaxValAPIAuthenticaionHelper.MaxValAPIAuthenticaionHelper();
        System.debug('accesstoken'+ accesstoken);
    }
    public list<Vendor> getSupplierDetails(String accesstoken)
    {
        list<Vendor> lst =new list<Vendor>();
        AuthReferenceList =new List<String>();
        string strAuditTrail = '';
        credentials = [SELECT Id,Name,URL__c,Username__c,Password__c FROM API_Credentials__c WHERE Name=: 'QB Suppliers - Create'];
        List<API_Auth_Detail__c> ListOfAuthReference = [SELECT Name FROM API_Auth_Detail__c];
        for(API_Auth_Detail__c Auth:ListOfAuthReference)
        {
            AuthReferenceList.add(Auth.Name);
            
        }
        System.debug('AuthReferenceList'+AuthReferenceList);
        List<WrapperSupplierDetails> CustomerList =new List<WrapperSupplierDetails>();
        for(String AuthReference: AuthReferenceList)
        {
        Http hp = new Http();
        HttpRequest req =new HttpRequest();
        req.setHeader('Authorization', 'Bearer ' + accesstoken);
        req.setHeader('Content-Type','application/json;charset=UTF-8');
        req.setMethod('GET');
        req.setTimeout(120000);
        //req.setEndpoint(credentials.URL__c);
        String URLWithRef =credentials.URL__c;
        String AfterReplacingAuth = URLWithRef.replace('{authreference}', AuthReference);
        System.debug('AfterReplacingAuth'+AfterReplacingAuth);
        req.setEndpoint(AfterReplacingAuth);
        HttpResponse res = hp.send(req);
        
        if (res.getStatusCode() == 200) {
         String jsonStr = res.getBody();
        System.debug('Response final'+jsonStr); 
        
        // Parse entire JSON response.
        WrapperSupplierDetails WC =new WrapperSupplierDetails();
        system.debug((WrapperSupplierDetails) System.JSON.deserialize(jsonStr, WrapperSupplierDetails.class));
        WrapperSupplierDetails myObj =(WrapperSupplierDetails) System.JSON.deserialize(jsonStr, WrapperSupplierDetails.class);
        System.debug('MyObj'+myObj.Status);
        System.debug('MyObj'+myObj.Error);
        lst =myObj.Data.Vendor;
        System.debug('lst'+lst);
        
        }
        else
        {
            System.debug('ERROR OCCURED>>>'+res.getStatus()); 
            System.debug('ERROR CODE>>>'+res.getStatusCode());
        }
        }
        return lst;
    }
    public class WrapperSupplierDetails
    {
        public Integer Status;
        public List<Error> Error;
        public List<Warning> Warning;
        public Data Data;
    }
      public class BillAddr {
		public String Id;
		public String Line1;
		public String Line2;
		public String Line3;
		public String City;
		public String Country;
		public String CountrySubDivisionCode;
		public String PostalCode;
	}

	public class CurrencyRef {
		public String value;
		public String name;
	}
     public class Warning {
        public String Code;
        public String Description;
    }
	

	public class PrimaryPhone {
		public String FreeFormNumber;
	}

	public class MetaData {
		public String CreateTime;
		public String LastUpdatedTime;
	}

	public class Error {
		public String Code;
		public String Description;
	}

	public class Data {
		public List<Vendor> Vendor;
		public Integer startPosition;
		public Integer maxResults;
	}

	public class Vendor {
		public BillAddr BillAddr;
		public String TaxIdentifier;
		public decimal Balance;
		public String AcctNum;
		public Boolean Vendor1099;
		public CurrencyRef CurrencyRef;
		public String domain;
		public Boolean sparse;
		public String Id;
		public String SyncToken;
		public MetaData MetaData;
		public String Title;
		public String GivenName;
		public String FamilyName;
		public String Suffix;
		public String CompanyName;
		public String DisplayName;
		public String PrintOnCheckName;
		public Boolean Active;
		public PrimaryPhone PrimaryPhone;
		public PrimaryPhone Mobile;
		public PrimaryEmailAddr PrimaryEmailAddr;
		public WebAddr WebAddr;
	}

	public class PrimaryEmailAddr {
		public String Address;
	}

	public class WebAddr {
		public String URI;
	}

}