@isTest
public class SetupCodeAssessTest {
    @isTest
    public static void TP_AdjustmentsMade() {
        Test.startTest();
        SetupCodeAssess.RegistrationAccount();
        Test.stopTest();
        Account[] setupAccts = [SELECT id FROM Account WHERE name = 'SETUPCODEASSESS'];
        System.assertEquals(1, setupAccts.size());
    }
}
