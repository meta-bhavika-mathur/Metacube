global class BatchStatusUpdateSchedule implements Schedulable {
    global void execute(SchedulableContext SC) {
        BatchStatusUpdate batchstatusupdate = new BatchStatusUpdate();
        database.executeBatch(batchstatusupdate,200);
    }
}