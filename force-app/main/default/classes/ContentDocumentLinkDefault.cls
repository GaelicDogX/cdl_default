/*
 * Class to access Content Document Link default settings and apply rules to 
 * list of Content Document Link records
 * 
*/
public without sharing class ContentDocumentLinkDefault {
    @TestVisible
    private static boolean isTestRun = false;
    // Map between default metadata user type assignment and actual User Types
    private static map<string, string[]> userTypeMap = new map<string, string[]>{
        'Standard' => new string[]{'*','Internal'},
        'PowerPartner' => new string[]{'*','Partner'},
        'PowerCustomerSuccess' => new string[]{'*','Community'},
        'CustomerSuccess' => new string[]{'*','Community'},
        'Guest' => new string[]{'*','Guest'},
        'CspLitePortal' => new string[]{'*','HV'},
        'SelfService' => new string[]{'*','HV'},
        'CsnOnly' => new string[]{'*','Chatter'}
    };
    // Trigger handler
    public static void handle() {
        // Only run when not running tests, or when isTestRun is true
        if(!Test.isRunningTest()||isTestRun==true)
        	(new ContentDocumentLinkDefault(Trigger.new)).default();
    }
    
    private map<sObjectType, CdlConf> confMap = new map<sObjectType, CdlConf>{};
    private ContentDocumentLink[] cdlList;
    // Instantiate process object
    public ContentDocumentLinkDefault(ContentDocumentLink[] cdlList) {
        this.cdlList = cdlList;
        // Find all distinct linked entity object types
        map<string, sObjectType> nameMap = new map<string, sObjectType>{};
        for(ContentDocumentLink cdl: cdlList)
            if(!confMap.containsKey(cdl.LinkedEntityId.getsObjectType())) {
                string name = cdl.LinkedEntityId.getsObjectType().getDescribe().getName().toLowerCase();
                confMap.put(cdl.LinkedEntityId.getsObjectType(), new CdlConf(name));
                nameMap.put(name, cdl.LinkedEntityId.getsObjectType());
            }
        
        // Load all related configurations
        confMap.put(null, new CdlConf('*')); // Add default object configuration
        nameMap.put('*', null); // Add default object configuration
        this.loadConfig(nameMap);

    }

    // Method that assigns default values to list of COntent Document Link records
    public void default() {
        // Apply rules to each record
        for(ContentDocumentLink cdl: cdlList)
            // Try to apply specific rule, and if no matched, apply global rule
            if(confMap.containsKey(cdl.LinkedEntityId.getsObjectType()) ? confMap.get(cdl.LinkedEntityId.getsObjectType()).apply(cdl)==false : true) {
                if(confMap.containsKey(null)) // Apply global
                    confMap.get(null).apply(cdl);
            }
    }

    // Method to load all sObject related rules, include a default rule (if configured)
    private void loadConfig(map<string, sObjectType> nameObjMap) {
        // When context is trigger, include both Trigger and Non-Trigger rules, otherwise Non-trigger rules only
        boolean[] triggerContext = Trigger.isExecuting==true ? new Boolean[]{true, false}:new Boolean[]{false};
        string[] userTypes = userTypeMap.containsKey(UserInfo.getUserType()) ? userTypeMap.get(UserInfo.getUserType()):new string[]{'*'};
        // List all relevant configured rules
        for(ContentLinkDefault__mdt[] cddList: [
            Select UserType__c, TriggerContext__c, CurrentShareType__c, CurrentVisibility__c, ShareType__c, Visibility__c, sObject_API_Name__c 
            From ContentLinkDefault__mdt 
            Where 
            	Enabled__c=true 
            	And sObject_API_Name__c In:nameObjMap.keySet()
            	And TriggerContext__c In: triggerContext
            	And UserType__c In :userTypes
            	And TestData__c=:Test.isRunningTest() // Only return test records while test is running
            Order By OrderIndex__c ASC
        ]) {
            for(ContentLinkDefault__mdt cdd: cddList) {
                string soName = cdd.sObject_API_Name__c.toLowerCase();
                sObjectType soType = nameObjMap.containsKey(soName) ? nameObjMap.get(soName) : null;
                if(this.confMap.containsKey(soType)) {
                    confMap.get(soType).add(cdd);
                } else system.debug('What happened to the soType for '+soName+'?' + soType);
            }
        }
    }
	
    // Class to capture a list of rules for one object type
    // Rules are captured in order of priority
    // Apply method updates one Content Document Link record
    public without sharing class CdlConf {
        public string objectName;
        public list<CdlRule> rules = new list<CdlRule>{};
        // Instantiate configuration object
        public CdlConf(string sObjectName) {
            objectName = sObjectName;
        }
        
        // Add a new rule to list
        public void add(ContentLinkDefault__mdt cdd) {
            rules.add(new CdlRule(cdd));
        }
        
        // Iterate over all possible rules and exit at the 1st match
        public boolean apply(ContentDocumentLink cdl) {
            for(CdlRule rule: rules) {
            	if(rule.apply(cdl))
                    return true;
            }
            return false;
        }
    }
    
    // One Content Document Link modification rule
    // Apply method determines match and applies changes
	public without sharing class CdlRule {
        public string criteriaVisibility;
        public string criteriaShareType;
        public string setVisibility;
        public string setShareType;
        public CdlRule(ContentLinkDefault__mdt cdd) {
            criteriaVisibility = cdd.CurrentVisibility__c!='*'?cdd.CurrentVisibility__c:null;
            criteriaShareType = cdd.CurrentShareType__c!='*'?cdd.CurrentShareType__c:null;
            setVisibility = cdd.Visibility__c!='NA'?cdd.Visibility__c:null;
            setShareType = cdd.ShareType__c!='NA'?cdd.ShareType__c:null;
        }
        
        // Apply this rule to a Content Document Link record
        public boolean apply(ContentDocumentLink cdl) {
            if(
                (cdl.Visibility==criteriaVisibility||criteriaVisibility==null)
                && (cdl.ShareType==criteriaShareType||criteriaShareType==null)
            ) {
                cdl.Visibility = setVisibility==null ? cdl.Visibility : setVisibility;  
                cdl.ShareType = setShareType==null ? cdl.ShareType : setShareType;
                return true;
            } else
            	return false;
        }

    }
}