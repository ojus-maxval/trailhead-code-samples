global class scheduledEmailToADUToBePaidRemainder implements Schedulable {
    global void execute(SchedulableContext sc) {
        batchEmailToADUToBePaidRemainder b = new batchEmailToADUToBePaidRemainder(); 
        database.executebatch(b);
    }
}