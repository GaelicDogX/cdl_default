@isTest
public class ContentDocumentLinkDefaultTest {
    // Test util class
    @isTest
    public static void testContentDocumentLinkDefault() {
        Account a = new Account(Name='Test account');
        insert a;
        ContentVersion contentVersion = new ContentVersion(
  			Title = 'cdl_default_override',
            PathOnClient = 'cdl_default_override.jpg',
            VersionData = Blob.valueOf('Test cdl_default_override'),
            IsMajorVersion = true
        );
        insert contentVersion;
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument Where LatestPublishedVersionId=:contentVersion.Id];
		Test.startTest();
        //create ContentDocumentLink  record 
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = a.id;
        cdl.ContentDocumentId = documents[0].Id;
        cdl.shareType = 'V';
        insert cdl;
        // Test default assignment method
        ContentDocumentLinkDefault ctrl = new ContentDocumentLinkDefault(new List<ContentDocumentLink>{cdl});
        ctrl.default();
        system.assertEquals('I', cdl.ShareType);
        
        Test.stopTest();
    }
    
    // Test trigger
    @isTest
    public static void testContentDocumentLinkTrigger() {
        Account a = new Account(Name='Test account');
        insert a;
        ContentVersion contentVersion = new ContentVersion(
  			Title = 'cdl_default_override',
            PathOnClient = 'cdl_default_override.jpg',
            VersionData = Blob.valueOf('Test cdl_default_override'),
            IsMajorVersion = true
        );
        insert contentVersion;
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument Where LatestPublishedVersionId=:contentVersion.Id];
		Test.startTest();
        // Set trigger test flag
        ContentDocumentLinkDefault.isTestRun = true;
       //create ContentDocumentLink  record 
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = a.id;
        cdl.ContentDocumentId = documents[0].Id;
        cdl.shareType = 'V';
        insert cdl;
        for(ContentDocumentLink cdlTest : [Select Id, ShareType From ContentDocumentLink Where Id=:cdl.Id]){
            system.assertEquals('I', cdlTest.ShareType);
        }
        
        Test.stopTest();
    }
}