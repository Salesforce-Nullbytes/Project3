public with sharing class testLWCController {
    @AuraEnabled
    public static List<String> getStatusOptions(){
        try {
            List<Schema.PicklistEntry> valuesList = CandidateResult__c.Status__c.getDescribe().getPicklistValues();
        
            List<String> returnList = new List<String>();
            for (Schema.PicklistEntry ple : valuesList) {
                returnList.add(ple.getLabel());
            }
        
            return returnList;    
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static List<CandidateResult__c> searchForRecords(String searchTerm, String passPercentage, String statusSelected){
        try {
            List<String> queryTokens = new List<String>();
            queryTokens.add('SELECT Name FROM CandidateResult__c');

            if (queryTokens[0] != '') {
                searchTerm = String.escapeSingleQuotes(searchTerm);
                queryTokens.add('Contact__c.Name LIKE \'%' + searchTerm + '\'%');
            }
            if (queryTokens[0] != '') {
                passPercentage = String.escapeSingleQuotes(passPercentage);
                queryTokens.add('PassPercentage__c > ' + passPercentage);
            }
            if (queryTokens[0] != '') {
                queryTokens.add('Status__c = ' + statusSelected);
            }
            String buildingQuery = '';
            Integer baseLength = queryTokens[0].length();
            for (Integer index = 0; index < queryTokens.size(); index++) {
                buildingQuery += queryTokens[index];
                if (index + 1 < queryTokens.size()) {
                    if (baseLength == buildingQuery.length()) {
                        buildingQuery += ' WHERE ';
                    } else {
                        buildingQuery += ' AND ';
                    }
                }
            }

            return Database.query(buildingQuery);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

}
