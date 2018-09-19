/*
 * For linked records, default the link Sharing settings depending on:
 * - Linked Entity object type
 * - Link Visibility
 * 
 * Configure these values via Custom Metadata Type: Content Link Default
 * Object Name: * for Global default, or the sObject name
 * Current Visibility: Select the current visibility for the inserted link record or "Any"
 * Current Share Type: Select the current share type for the inserted link record or "Any"
 * Enabled: Check to activate the rule
 * Default Visibility: Select the Visibility the Link record should default to, or leave blank [1]
 * Default Share Type: Select the Share Type the Link record should default to, or leave blank [1]
 * [1] Either a Default Share Type or Default Visibility must be defined
 * 
*/
trigger ContentDocumentLink on ContentDocumentLink (before insert) {
    // When internal user and share type is viewer, change to record
	for(ContentDocumentLink cdl: Trigger.new)
        if(
            cdl.LinkedEntityId.getsObjectType()==ProfessionalServicesRequest__c.getsObjectType() ?
            cdl.Visibility=='InternalUsers'&& cdl.ShareType=='V' :
            false
        )
        	cdl.ShareType='I';
}