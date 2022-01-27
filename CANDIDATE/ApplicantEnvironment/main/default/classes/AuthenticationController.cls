public without sharing class AuthenticationController {
    @AuraEnabled(cacheable=true)
    public static String SiteUrl() {
        ServerInfo__mdt server = [
            SELECT ServerUrl__c 
            FROM ServerInfo__mdt
            WHERE MasterLabel = 'Server' 
            LIMIT 1];
        return server.ServerUrl__c;
    }

    @AuraEnabled
    public static Boolean setSession(String code){
        RESTutil.Authenticate(code);
        return true;
    }
}