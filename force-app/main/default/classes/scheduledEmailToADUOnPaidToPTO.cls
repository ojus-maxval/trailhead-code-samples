public class scheduledEmailToADUOnPaidToPTO implements Schedulable {
    public void execute(SchedulableContext sc) {
        batchEmailToADUOnPaidToPTO b = new batchEmailToADUOnPaidToPTO(); 
        database.executebatch(b);
    }
}