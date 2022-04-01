global class InvoiceStatusRequestToMaxval implements Database.Batchable<sObject>,  Database.AllowsCallouts
{
 String strStatus ='In progress';
 public String query = 'SELECT id,name,Invoice_Status__c FROM Invoice__c WHERE Invoice_Status__c=\''+strStatus+'\'';
 global Database.QueryLocator start(Database.BatchableContext BC) 
 {
     system.debug('query@@@@@@@@'+query  );
    return Database.getQueryLocator(query);
 }
     global void execute(Database.BatchableContext BC, List<Invoice__c> records) 
     {         
            String endpoint='https://08117cf11e91b5fa8da35ae21a40835a.m.pipedream.net';
            string InvDetails; 
            id invid; 
            for(Invoice__c Objinvoice :records)
        {        
            invid=Objinvoice.id;
            JSONGenerator gen = JSON.createGenerator(true);
            gen.writeStartObject();
            gen.writeStringField('status',Objinvoice.Invoice_Status__c);
            gen.writeStringField('InvoiceRef',Objinvoice.name );
            gen.writeEndObject();
            InvDetails=gen.getAsString();
        }
         //try {   
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint('https://08117cf11e91b5fa8da35ae21a40835a.m.pipedream.net');
            request.setMethod('POST');
            request.setHeader('Content-Type', 'application/json;charset=UTF-8');   
            request.setBody(InvDetails);
            HttpResponse response = http.send(request);
            system.debug('response'+response );     
            // Parse the JSON response
        if (response.getStatusCode() == 200) 
        {
                System.debug('The status code returned was not expected: ' +
                response.getStatusCode() + ' ' + response.getStatus());
                Invoice__c ObjInvoiceUpdate = new Invoice__c ();
                ObjInvoiceUpdate.id=invid;
                datetime datee=system.now();
                ObjInvoiceUpdate.Invoice_Status__c='Completed';
                UPDATE ObjInvoiceUpdate ;
        }
        else 
        {
            System.debug(response.getBody());
        }
     
    }   
    global void finish(Database.BatchableContext BC)
    {    
    }
}