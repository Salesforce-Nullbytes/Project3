@IsTest
public without sharing class PastResultsControllerTest {

    @TestSetup
    static void setUpTestData(){
        User candidate =  TESTutilCommunityUser.makeCustomerAndUser('mockTestUser1');
    }

    @IsTest
    public static void TP_GetAllCompletedCandidateResults(){
        Test.startTest();
        // Restrict to only our mock user from TestSetup
        User cUser = [
            SELECT ContactID, Name FROM USER 
            WHERE Profile.Name = 'CodeAssessCandidate' AND Name = 'mockTestUser1'
            LIMIT 1
        ]; 
        Contact c = [SELECT ID FROM Contact WHERE ID =: cUser.ContactId];

        // Make Completed candidate reuslts to view
        CandidateResult__c mockResult1 = new CandidateResult__c();
        mockResult1.Status__c = 'Completed';
        mockResult1.Contact__c = c.id;
        CandidateResult__c mockResult2 = new CandidateResult__c();
        mockResult2.Status__c = 'Completed';
        mockResult2.Contact__c = c.id;
        Insert new CandidateResult__c[]{mockResult1, mockResult2};

        System.runAs(cUser) {
            List<CandidateResult__c> results = PastResultsController.getCandidateResults();
            System.assertEquals(2, results.size());
        }
        Test.stopTest();
    }

}
