public with sharing class AuditTrailHelper
{
    public static void UpdateAudit(string Name, string Description, string Status)
    {
        Audit_Trail__c objAuditTrail = new Audit_Trail__c();
        objAuditTrail.Name = Name;
        objAuditTrail.Description__c = Description;
        objAuditTrail.Status__c = 'None';
        INSERT objAuditTrail;
    }
}