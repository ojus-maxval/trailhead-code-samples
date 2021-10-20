global class scheduledbatchEmailToADURenewalToBePaid implements Schedulable {
    global void execute(SchedulableContext sc) {
        batchEmailToADURenewalToBePaid b = new batchEmailToADURenewalToBePaid(); 
        database.executebatch(b);
    }
}