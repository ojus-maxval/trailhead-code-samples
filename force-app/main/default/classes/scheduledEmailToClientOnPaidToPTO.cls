public class scheduledEmailToClientOnPaidToPTO implements Schedulable {
    public void execute(SchedulableContext sc) {
        batchEmailToClientOnPaidToPTO b = new batchEmailToClientOnPaidToPTO(); 
        database.executebatch(b);
    }
}