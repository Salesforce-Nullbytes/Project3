public class AsyncSendSubmissions implements Queueable{

    private soapSforceCom200608Apex.CompileAndTestResult results;
    
    public AsyncSendSubmissions(soapSforceCom200608Apex.CompileAndTestResult resultParam) {
        results = resultParam;
    }

    public void Execute(QueueableContext context) {
         //RESTcallout.sendResults? (results);
         System.debug('waiting for api team integration');
    }

    public static void enqueueSubmission(soapSforceCom200608Apex.CompileAndTestResult resultsParam) {
        System.enqueueJob(new AsyncSendSubmissions(resultsParam));
    }
}
