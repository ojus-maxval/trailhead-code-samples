global class QBCustomerDetails {
    global   String accesstoken{get;set;}
    public API_Credentials__c credentials{set;get;}
    //public String AuthReference{get;set;}
    public List<String> AuthReferenceList{get;set;}
    public List<Customer> ListAllCustomerRcd{get;set;}
    public QBCustomerDetails()
    {
        
        accesstoken = MaxValAPIAuthenticaionHelper.MaxValAPIAuthenticaionHelper();
        System.debug('accesstoken'+ accesstoken);
    }
    public list<Customer> getCustomerDetails(String accesstoken)
    {
        ListAllCustomerRcd = new list<Customer>();
        AuthReferenceList =new List<String>();
        string strAuditTrail = '';
        credentials = [SELECT Id,Name,URL__c,Username__c,Password__c FROM API_Credentials__c WHERE Name=: 'QB Customers - Create'];
        List<API_Auth_Detail__c> ListOfAuthReference = [SELECT Name FROM API_Auth_Detail__c];
        for(API_Auth_Detail__c Auth:ListOfAuthReference)
        {
            AuthReferenceList.add(Auth.Name);
                
        }
        System.debug('AuthReferenceList'+AuthReferenceList);
       List<JSON2Apex> CustomerList =new List<JSON2Apex>();
       // AuthReference = 'API-003';//QB Credentials
        if(AuthReferenceList.size() > 0)
        {
            for(String AuthReference: AuthReferenceList)
            {
                System.debug('AuthReference'+AuthReference);
                Http hp = new Http();
                HttpRequest req =new HttpRequest();
                req.setHeader('Authorization', 'Bearer ' + accesstoken);
                req.setHeader('Content-Type','application/json;charset=UTF-8');
                req.setMethod('GET');
                req.setTimeout(120000);
                String URLWithRef =credentials.URL__c;
                String AfterReplacingAuth = URLWithRef.replace('{authreference}', AuthReference);
                System.debug('AfterReplacingAuth'+AfterReplacingAuth);
                req.setEndpoint(AfterReplacingAuth);
                HttpResponse res = hp.send(req);
                if (res.getStatusCode() == 200) {
                JSONParser parser = JSON.createParser(res.getBody());
                string jsonStr = res.getBody();
                System.debug(jsonStr);
                
                system.debug((JSON2Apex) System.JSON.deserialize(jsonStr, JSON2Apex.class));
                JSON2Apex myObj =(JSON2Apex) System.JSON.deserialize(jsonStr, JSON2Apex.class);
                //System.debug('MyObj'+myObj.Status);
                //System.debug('MyObj'+myObj.Error);
                list<Customer> lst =myObj.Data.Customer;
                //System.debug('lst'+lst);
                ListAllCustomerRcd.addAll(myObj.Data.Customer);
            }
            }
            System.debug('ListAllCustomerRcd'+ListAllCustomerRcd.size());
        }
       
        
        return ListAllCustomerRcd;
            
    }  
    public class JSON2Apex{
        public Integer Status;
        public List<Error> Error;
        public List<Warning> Warning;
        public Data Data;
    } 
    public class BillAddr {
        public String Id;
        public String Line1;
        public String City;
        public String Country;
        public String CountrySubDivisionCode;
        public String PostalCode;
    }
    
    public class CurrencyRef {
        public String value;
        public String name;
    }
    public class ParentRef {
        public String value;
    }
    
    
    public class PrimaryPhone {
        public String FreeFormNumber;
    }
    
    public class Customer {
        public Boolean Taxable;
        public BillAddr BillAddr;
        public String Notes;
        public Boolean Job;
        public Boolean BillWithParent;
        public decimal Balance;
        public decimal BalanceWithJobs;
        public ParentRef ParentRef;
        public CurrencyRef CurrencyRef;
        public String PreferredDeliveryMethod;
        public Boolean IsProject;
        public String ClientEntityId;
        public String domain;
        public Boolean sparse;
        public String Id;
        public String SyncToken;
        public MetaData MetaData;
        public String Title;
        public String GivenName;
        public String MiddleName;
        public String FamilyName;
        public String Suffix;
        public String FullyQualifiedName;
        public String CompanyName;
        public String DisplayName;
        public String PrintOnCheckName;
        public Boolean Active;
        public PrimaryPhone PrimaryPhone;
        public PrimaryEmailAddr PrimaryEmailAddr;
        public BillAddr_Z ShipAddr;
        public String GSTRegistrationType;
    }
    
    public class MetaData {
        public String CreateTime;
        public String LastUpdatedTime;
    }
    
    public class BillAddr_Z {
        public String Id;
        public String Line1;
        public String City;
        public String CountrySubDivisionCode;
    }
    
    public class Error {
        public String Code;
        public String Description;
    }
     public class Warning {
        public String Code;
        public String Description;
    }
    
    public class Data {
        public List<Customer> Customer;
    }
    
    public class PrimaryEmailAddr {
        public String Address;
    }
   }