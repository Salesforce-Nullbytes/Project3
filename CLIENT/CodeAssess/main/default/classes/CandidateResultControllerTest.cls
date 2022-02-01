
@isTest
public class CandidateResultControllerTest
{ 
    @isTest
    public static void TestSOQL() 
	{
        Contact newCandidate = new Contact();
        newCandidate.LastName = 'Test';
        insert newCandidate;

		CandidateResult__c candr = new CandidateResult__c();
		// Add all required fields
		//candr.ID;
        candr.Contact__c = newCandidate.ID;
        //candr.Contact__r.Name = 'Test Taker';
		//candr.Name='PASS';
        //candr.PassPercentage__c = '';
	
		insert candr;


		//CandidateResultController  testCand = new CandidateResultController ();
		List<CandidateResult__c> newCand = CandidateResultController.getCandidateResults();
		
		System.assert( newCand  != null);
		
	}
}