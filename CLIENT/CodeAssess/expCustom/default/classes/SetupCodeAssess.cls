public without sharing class SetupCodeAssess {
    public static void RegistrationAccount() {
        Account setupAccount = new Account(name = 'SETUPCODEASSESS');
        Insert setupAccount;

        User[] admin = [SELECT id FROM User WHERE Profile.name = 'System Administrator'];
        UserRole ownerRole = [SELECT id, name FROM UserRole WHERE Name = 'CodeAssess Owner' LIMIT 1];

        updateUserRole(admin[0].id, ownerRole.id);
    }
    
    // Future to avoid Mixed DML Operation Exception
    @future
    public static void updateUserRole(ID user, ID role) {
        User admin = [SELECT id FROM User WHERE id = :user];
        admin.UserRoleId = role;
        update admin;
    }
}
