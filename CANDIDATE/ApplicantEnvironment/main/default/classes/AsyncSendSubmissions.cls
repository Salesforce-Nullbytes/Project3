public class AsyncSendSubmissions{


    @Future(callout=true)
    public static void sendSubmission(String results) {
        System.debug(results);
         RESTcallout.postSubmission(results);
    }

    @AuraEnabled
    public static void enqueueSubmission(String resultsParam) {
        try {
            sendSubmission(resultsParam);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}
