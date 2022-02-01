public without sharing class retrieveUserInfo {
    //Use @AuraEnabled to enable client- and server-side access to the method
    @AuraEnabled
    public static User getCurrentUser() {
        //Use SOQL to retrive current user info
        ID currentUserId = UserInfo.getUserId();
        User currentUser = [SELECT ContactId, Name FROM User WHERE Id = :currentUserId LIMIT 1];
        return currentUser;
    }
}