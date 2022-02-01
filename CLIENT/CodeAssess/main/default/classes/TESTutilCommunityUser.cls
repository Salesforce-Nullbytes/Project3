@isTest
public class TESTutilCommunityUser {
    // Returns a community user w/ ContactID
    public static User makeCustomerAndUser(String someName) {
        // Process learned from Salesforce documentations
        // https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_testing_tools_runas.htm
        // and Lee Campbell at https://developer.salesforce.com/forums/?id=906F00000009266IAA
        // Process was modified from each source and customized for use in Project 2, then copied here

        UserRole role = new UserRole(name='test role', PortalType = 'None' );
        Insert role;

        Profile pInternal = [SELECT id, name FROM Profile WHERE name = 'System Administrator' LIMIT 1];
        Profile pExternal = [SELECT id, name FROM Profile WHERE name = 'CodeAssessCandidate' LIMIT 1];
       
        String usernameInternal = DateTime.now().getTime() + '@testinternal.com';
        String usernameExternal = DateTime.now().getTime() + '@testexternal.com';

        User creator = new User(
            UserRoleId = role.Id,
            ProfileId = pInternal.Id,
            Username = usernameInternal,
            Alias = 'creator',
            Email='internaluser@test.com',
            EmailEncodingKey='UTF-8',
            Lastname='Testname',
            LanguageLocaleKey='en_US',
            LocaleSidKey='en_US',
            TimeZoneSidKey='America/Los_Angeles'
        );
        Insert creator;

        User result;
        System.runAs (creator) {
            Account customerAcct = new Account(
                Name = someName,
                OwnerId = creator.Id
            );
            Database.insert(customerAcct);
            
            Contact c = new Contact(lastName=someName);
            c.email = 'contact'+usernameExternal;
            c.AccountId = customerAcct.Id;
            Insert c;

            User customer = new User(
                ProfileId = pExternal.Id,
                Username = usernameExternal, 
                Alias = 'cstmr', 
                Email='externaluser@test.com',
                EmailEncodingKey='UTF-8', 
                LastName=someName, 
                LanguageLocaleKey='en_US',
                LocaleSidKey='en_US', 
                TimeZoneSidKey='America/Los_Angeles',
                CommunityNickname= someName.replaceAll( '\\s+', ''),
                ContactId = c.id
            );
            Insert customer;

            result = customer;
        }

        return result;
    }
}
