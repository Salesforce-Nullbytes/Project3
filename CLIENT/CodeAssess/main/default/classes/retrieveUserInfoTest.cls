@isTest
public class retrieveUserInfoTest {
    @isTest 
    public static void NP_getCurrentUser() {
        User currentUser = retrieveUserInfo.getCurrentUser();
        System.assert( currentUser  != null);
    }
}
