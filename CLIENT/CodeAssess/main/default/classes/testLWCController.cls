public without sharing class testLWCController {
    @AuraEnabled
    public static List<String> getStatusOptions(){
        List<Schema.PicklistEntry> valuesList = CandidateResult__c.Status__c.getDescribe().getPicklistValues();
        
        List<String> returnList = new List<String>();
        for (Schema.PicklistEntry ple : valuesList) {
            returnList.add(ple.getLabel());
        }
        
        return returnList;
    }

    @AuraEnabled
    public static List<CandidateResult__c> searchForRecords(String searchTerm, String passPercentage, String statusSelected){
            List<String> queryTokens = new List<String>();
            queryTokens.add('SELECT Contact__r.Name, Status__c, SubmitTime__c, StartTime__c, PassPercentage__c FROM CandidateResult__c');

            if (searchTerm != '') {
                searchTerm = String.escapeSingleQuotes(searchTerm);
                queryTokens.add('Contact__r.Name LIKE \'%' + searchTerm + '%\'');
            }
            if (passPercentage != '') {
                passPercentage = String.escapeSingleQuotes(passPercentage);
                queryTokens.add('PassPercentage__c > ' + passPercentage);
            }
            if (statusSelected != '') {
                queryTokens.add('Status__c = \'' + statusSelected + '\'');
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
    }
}
