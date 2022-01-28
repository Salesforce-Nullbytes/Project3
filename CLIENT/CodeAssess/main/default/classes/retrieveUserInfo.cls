public with sharing class retrieveUserInfo {
    //Use @AuraEnabled to enable client- and server-side access to the method
    @AuraEnabled
    public static User getCurrentUser(Id userIdInfo) {
        //Use SOQL to retrive current user info
        User currentUser = [SELECT Id, Name FROM User WHERE Id = :userIdInfo];
        return currentUser;
    }
}