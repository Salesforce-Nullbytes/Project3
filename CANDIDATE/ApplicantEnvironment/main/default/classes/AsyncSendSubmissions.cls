public class AsyncSendSubmissions implements Queueable{

    private Object results;
    
    public AsyncSendSubmissions(Object resultParam) {
        results = resultParam;
    }

    public void Execute(QueueableContext context) {
         //RESTcallout.sendResults? (results);
         System.debug('waiting for api team integration');
    }

    @AuraEnabled
    public static void enqueueSubmission(Object resultsParam) {
        try {
            System.enqueueJob(new AsyncSendSubmissions(resultsParam));
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}
