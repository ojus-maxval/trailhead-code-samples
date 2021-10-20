public class schBatchEmailToClientPaymentReminder implements Schedulable {
    public void execute(SchedulableContext sc) {
        batchEmailToClientPaymentReminder b = new batchEmailToClientPaymentReminder(); 
        database.executebatch(b,1);
    }
}