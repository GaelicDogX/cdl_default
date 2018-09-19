# Overwrite Content Document Link default values
Linking Salesforce files to records, groups etc. assumes sharing defaults that often get in the way of managing linked files.

With cdl_default, you are able to define overrides for ShareType and Visibility. Not only can you override the default values, you have a fair amount of control when the override takes effect. Controlling parameters include:
- Current User Type (optional)
- SObject type (optional)
- Initial ShareType (optional)
- Initial Visibility (optional)

When a Content Document Link record matches the control parameters of an override rule, the override values are assigned.

A word of caution. While this sounds like a boat load of fun for any control challenged individual, apply rules only after thoroughly testing the impact of these rules and potentially consulting the SFDC documentation. Salesforce is very particular about what you can and cannot do with Content Document Link records.

# Execution
A Content Document Link trigger executes on the before insert event. At that time, the document's related entity determines what rules will be applied. When a CDL record is processed, the 1st rule that the CDL record matches to is executed. To control which rule is attempted 1st, leverage the Rule Order Index value. Once all sObject specific rules are exhausted, global rules (sObject Name = * ) are attempted. If no rule matches or no rule exists, no changes are made.

#  Via APEX
You may call the default assignment method via APEX:
...
ContentDocumentLink[] cdlList = new ContentDocumentLink[]{};
cdlList.add(cdl);
(new ContentDocumentLinkDefault(cdlList)).default();
update cdlList;
...

The list of ContentDocumentLink records will NOT be saved, but the revised values will have been applied.

# Managing Rules
At the initial release, you manage rules directly in Customer Metadata. Here is how it is done.

1. After installing the package in your org, navigate to Setup - Custom Metadata Types - Content Link Default
2. Assign the following values
  - Label: A rule name that indicates the intent of the rule
  - Content Link Default Name: A Metadata record API name (no spaces and special characters allowed)
  - Enabled: Check to activate the rule
  - Rule Order Index: Numeric value the represents the order in which the rule should be applied
                      Lower number is applied before higher numbers
  - sObject API Name: The API name of the sObject that the CDL record would be linked to (or * for any sObject type)
  - User Type: Select the user type that executes the insert of the CDL record. Select "Any" to apply to all user types.
  - Trigger Context Only: Only apply this filter when the default assignment process is called during a Trigger execution.
                          You can call the default assignment method via APEX.
  - Current Visibility: Select the Visibility type the CDL should have before assigning the rule overrides, or select "Any"
  - Current Share Type: Select the Share Type the CDL should have before assigning the rule overrides, or select "Any"
  - Visibility: Select the Visibility that the CDL will have after applying the rule. Or select "Do NOT change" to retain the original value
  - Share Type: Select the Share Type that the CDL will have after applying the rule. Or select "Do NOT change" to retain the original value
3. Click on Save

You can have multiple rules for the same sObject with different selection criteria. 

#  Deactivate Rules
You can simply dsiable rules. To do so:
1. Navigate to Setup - Custom Metadata Types - Content Link Default
2. Locate the rule you intend to deactivate
3. Edit the rule
4. Uncheck the Enabled box
5. Click on Save
