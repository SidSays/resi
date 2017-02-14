<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Advisor_Case_Email_alert</fullName>
        <description>Advisor Case Email alert</description>
        <protected>false</protected>
        <recipients>
            <recipient>allison_starr@cable.comcast.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Direct_Sales_Email_Templates/New_Case_Admin</template>
    </alerts>
    <alerts>
        <fullName>Affiliate_case_update_by_non_Affiliate_User</fullName>
        <description>Affiliate case update by non-Affiliate User</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Affiliate_case_update</template>
    </alerts>
    <alerts>
        <fullName>Alert_Wave_Team_on_New_Cases</fullName>
        <description>Alert Wave Team on New Cases</description>
        <protected>false</protected>
        <recipients>
            <recipient>david_krauza@cable.comcast.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>michael_angelo@cable.comcast.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>scott_bersak@cable.comcast.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Cases_Email_Templates/New_Case_Update</template>
    </alerts>
    <alerts>
        <fullName>Auto_Response_Mail</fullName>
        <description>Auto Response Mail</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Cases_Email_Templates/Sales_Portal_Auto_Response_Template</template>
    </alerts>
    <alerts>
        <fullName>Case_Field_Modification_Email_Alert_Sales_Portal</fullName>
        <description>Case Field Modification Email Alert - Sales Portal</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <recipients>
            <field>Preferred_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <recipient>elizabeth_haworth@comcast.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <field>Requested_For__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Cases_Email_Templates/Field_Modification_Email_Template</template>
    </alerts>
    <alerts>
        <fullName>Claim_submitted_for_Review</fullName>
        <description>Claim submitted for Review</description>
        <protected>false</protected>
        <recipients>
            <recipient>Claim_Approval_Group</recipient>
            <type>group</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Turnpike_Email_Templates/Claim_Assignment_Above_Threshold</template>
    </alerts>
    <alerts>
        <fullName>Close_Case_Email_Notification</fullName>
        <description>Close Case Email Notification</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <recipient>elizabeth_haworth@comcast.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>meredith_williams@cable.comcast.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>sean_solomon@cable.comcast.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <field>Requested_For__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Cases_Email_Templates/Case_Closed_Notification</template>
    </alerts>
    <alerts>
        <fullName>Defect_Management_Case_Closed</fullName>
        <description>Defect Management:  Case Closed</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Cases_Email_Templates/Case_Status_change</template>
    </alerts>
    <alerts>
        <fullName>Email_Affliate_Claims_User_on_Final_Claims_status</fullName>
        <description>​Email Affliate Claims User on Final Claims status</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Cases_Email_Templates/Final_Claim_Status</template>
    </alerts>
    <alerts>
        <fullName>Email_Alert_to_Breta_Martinez_and_Gwen_Mooney</fullName>
        <description>Email Alert to Breta Martinez and Gwen Mooney</description>
        <protected>false</protected>
        <recipients>
            <recipient>breta_martinez@cable.comcast.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>gwendolyn_mooney@cable.comcast.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Direct_Sales_Email_Templates/New_Case_Admin</template>
    </alerts>
    <alerts>
        <fullName>Email_Tier_2_when_case_is_assigned</fullName>
        <description>Email Tier 2 when case is assigned</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Direct_Sales_Email_Templates/New_Case_Admin</template>
    </alerts>
    <alerts>
        <fullName>Email_for_Direct_Sales_Cases</fullName>
        <description>Email for Direct Sales Cases</description>
        <protected>false</protected>
        <recipients>
            <recipient>robert_deford@cable.comcast.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>sandra_valenti@cable.comcast.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>zach_street@cable.comcast.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Direct_Sales_Email_Templates/New_Case_Admin</template>
    </alerts>
    <alerts>
        <fullName>Email_to_Joe_Terese_Marjorie_Jeremy</fullName>
        <description>Email to Joe,Terese,Marjorie &amp; Jeremy</description>
        <protected>false</protected>
        <recipients>
            <recipient>jeremy_segal@cable.comcast.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>joe_zullo2@cable.comcast.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>marjorie_fox@cable.comcast.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>terese_cox@cable.comcast.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Direct_Sales_Email_Templates/New_Case_with_TC1_and_TC2</template>
    </alerts>
    <alerts>
        <fullName>Enhancement_added_to_backlog</fullName>
        <description>Enhancement Email</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <recipients>
            <field>Preferred_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>Requested_For__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Cases_Email_Templates/Status_change_through_Rally</template>
    </alerts>
    <alerts>
        <fullName>NSO_Group_Alert</fullName>
        <description>NSO Group Alert</description>
        <protected>false</protected>
        <recipients>
            <recipient>NSO_Group</recipient>
            <type>group</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Direct_Sales_Email_Templates/New_Case</template>
    </alerts>
    <alerts>
        <fullName>New_Case_Creation_Email</fullName>
        <description>New Case Creation Email</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Cases_Email_Templates/New_Case_Update</template>
    </alerts>
    <alerts>
        <fullName>New_Case_Email_Alert</fullName>
        <description>New Case Email Alert</description>
        <protected>false</protected>
        <recipients>
            <recipient>sandra_houser@cable.comcast.com.prod</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Direct_Sales_Email_Templates/New_Case_Admin</template>
    </alerts>
    <alerts>
        <fullName>Notify_Affiliate_on_Status_Cplosed</fullName>
        <description>Notify Affiliate on Status Closed</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Turnpike_Email_Templates/Claim_Claim_Status_Closed</template>
    </alerts>
    <alerts>
        <fullName>Notify_Beltway_RSA_when_new_case_submitted</fullName>
        <ccEmails>shivani.gautam@accenture.com</ccEmails>
        <description>Notify Beltway RSA when new case submitted</description>
        <protected>false</protected>
        <recipients>
            <recipient>Beltway_RSA</recipient>
            <type>group</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Direct_Sales_Email_Templates/New_Case</template>
    </alerts>
    <alerts>
        <fullName>Notify_Big_South_RSA_when_new_case_submitted</fullName>
        <description>Notify Big South RSA when new case submitted</description>
        <protected>false</protected>
        <recipients>
            <recipient>Big_South_RSA</recipient>
            <type>group</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Direct_Sales_Email_Templates/New_Case</template>
    </alerts>
    <alerts>
        <fullName>Notify_California_RSA_when_new_case_submitted</fullName>
        <description>Notify California RSA when new case submitted</description>
        <protected>false</protected>
        <recipients>
            <recipient>California_RSA</recipient>
            <type>group</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Direct_Sales_Email_Templates/New_Case</template>
    </alerts>
    <alerts>
        <fullName>Notify_Chicago_RSA_when_new_case_submitted</fullName>
        <description>Notify Chicago RSA when new case submitted</description>
        <protected>false</protected>
        <recipients>
            <recipient>Chicago_RSA</recipient>
            <type>group</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Direct_Sales_Email_Templates/New_Case</template>
    </alerts>
    <alerts>
        <fullName>Notify_Claim_Investigation_Queue_on_Claim_Submission</fullName>
        <description>Notify Claim Investigation Queue on Claim Submission</description>
        <protected>false</protected>
        <recipients>
            <recipient>Claim_Investigation_Group</recipient>
            <type>group</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Turnpike_Email_Templates/Claim_Submitted_by_Affiliate</template>
    </alerts>
    <alerts>
        <fullName>Notify_Florida_RSA_when_new_case_submitted</fullName>
        <description>Notify Florida RSA when new case submitted</description>
        <protected>false</protected>
        <recipients>
            <recipient>Florida_RSA</recipient>
            <type>group</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Direct_Sales_Email_Templates/New_Case</template>
    </alerts>
    <alerts>
        <fullName>Notify_Freedom_RSA_when_new_case_submitted</fullName>
        <description>Notify Freedom RSA when new case submitted</description>
        <protected>false</protected>
        <recipients>
            <recipient>Freedom_RSA</recipient>
            <type>group</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Direct_Sales_Email_Templates/New_Case</template>
    </alerts>
    <alerts>
        <fullName>Notify_GBR_RSA_when_new_case_submitted</fullName>
        <description>Notify GBR RSA when new case submitted</description>
        <protected>false</protected>
        <recipients>
            <recipient>Greater_Boston_RSA</recipient>
            <type>group</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Direct_Sales_Email_Templates/New_Case</template>
    </alerts>
    <alerts>
        <fullName>Notify_Heartland_RSA_when_new_case_submitted</fullName>
        <description>Notify Heartland RSA when new case submitted</description>
        <protected>false</protected>
        <recipients>
            <recipient>Heartland_RSA</recipient>
            <type>group</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Direct_Sales_Email_Templates/New_Case</template>
    </alerts>
    <alerts>
        <fullName>Notify_Houston_RSA_when_new_case_submitted</fullName>
        <description>Notify Houston RSA when new case submitted</description>
        <protected>false</protected>
        <recipients>
            <recipient>Houston_RSA</recipient>
            <type>group</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Direct_Sales_Email_Templates/New_Case</template>
    </alerts>
    <alerts>
        <fullName>Notify_Keystone_RSA_when_new_case_submitted</fullName>
        <description>Notify Keystone RSA when new case submitted</description>
        <protected>false</protected>
        <recipients>
            <recipient>Keystone_RSA</recipient>
            <type>group</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Direct_Sales_Email_Templates/New_Case</template>
    </alerts>
    <alerts>
        <fullName>Notify_Mile_High_RSA_when_new_case_submitted</fullName>
        <description>Notify Mile High RSA when new case submitted</description>
        <protected>false</protected>
        <recipients>
            <recipient>Mile_High_RSA</recipient>
            <type>group</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Direct_Sales_Email_Templates/New_Case</template>
    </alerts>
    <alerts>
        <fullName>Notify_Mountain_RSA_when_new_case_submitted</fullName>
        <description>Notify Mountain RSA when new case submitted</description>
        <protected>false</protected>
        <recipients>
            <recipient>Mountain_RSA</recipient>
            <type>group</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Direct_Sales_Email_Templates/New_Case</template>
    </alerts>
    <alerts>
        <fullName>Notify_Portland_RSA_when_new_case_submitted</fullName>
        <description>Notify Portland RSA when new case submitted</description>
        <protected>false</protected>
        <recipients>
            <recipient>Portland_RSA</recipient>
            <type>group</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Direct_Sales_Email_Templates/New_Case</template>
    </alerts>
    <alerts>
        <fullName>Notify_Queues_on_Claim_Cancellation</fullName>
        <description>Notify Queues on Claim Cancellation</description>
        <protected>false</protected>
        <recipients>
            <recipient>Claim_Approval_Group</recipient>
            <type>group</type>
        </recipients>
        <recipients>
            <recipient>Claim_Investigation_Group</recipient>
            <type>group</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Turnpike_Email_Templates/Claim_Cancelled_by_Affiliate</template>
    </alerts>
    <alerts>
        <fullName>Notify_Requested_For_After_case_creation</fullName>
        <description>Notify Requested For After case creation</description>
        <protected>false</protected>
        <recipients>
            <field>Requested_For__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Direct_Sales_Email_Templates/New_Case</template>
    </alerts>
    <alerts>
        <fullName>Notify_Seattle_RSA_when_new_case_submitted</fullName>
        <description>Notify Seattle RSA when new case submitted</description>
        <protected>false</protected>
        <recipients>
            <recipient>Seattle_RSA</recipient>
            <type>group</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Direct_Sales_Email_Templates/New_Case</template>
    </alerts>
    <alerts>
        <fullName>Notify_Threshold_Escalation_Queue_on_Open_Claims</fullName>
        <description>Notify Threshold Escalation Queue on Open Claims</description>
        <protected>false</protected>
        <recipients>
            <recipient>Claim_Approval_Group</recipient>
            <type>group</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Turnpike_Email_Templates/Claim_Untouched_by_Investigation_Queue</template>
    </alerts>
    <alerts>
        <fullName>Notify_Twin_Cities_RSA_when_new_case_submitted</fullName>
        <description>Notify Twin Cities RSA when new case submitted</description>
        <protected>false</protected>
        <recipients>
            <recipient>Twin_Cities_RSA</recipient>
            <type>group</type>
        </recipients>
        <recipients>
            <recipient>animesh.datta@accenture.com.chatter</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>s.vishwanath.kadwade@accenture.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Direct_Sales_Email_Templates/New_Case</template>
    </alerts>
    <alerts>
        <fullName>Notify_WNE_RSA_when_new_case_submitted</fullName>
        <description>Notify WNE RSA when new case submitted</description>
        <protected>false</protected>
        <recipients>
            <recipient>Western_New_England_RSA</recipient>
            <type>group</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Direct_Sales_Email_Templates/New_Case</template>
    </alerts>
    <alerts>
        <fullName>Owner_change_mail</fullName>
        <description>Owner_change_mail</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Cases_Email_Templates/New_Case_Update</template>
    </alerts>
    <alerts>
        <fullName>Send_Email_to_Allison</fullName>
        <description>Send Email to Allison</description>
        <protected>false</protected>
        <recipients>
            <recipient>allison_starr@cable.comcast.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Direct_Sales_Email_Templates/New_Case_with_TC1_and_TC2</template>
    </alerts>
    <alerts>
        <fullName>Send_mail_to_Request_For_upon_change_in_Case_Status</fullName>
        <description>Send mail to Request For upon change in Case Status</description>
        <protected>false</protected>
        <recipients>
            <field>Requested_For__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Cases_Email_Templates/Status_change_through_Rally</template>
    </alerts>
    <alerts>
        <fullName>email_allconnect</fullName>
        <description>email allconnect</description>
        <protected>false</protected>
        <recipients>
            <recipient>AllconnectPartnerUser</recipient>
            <type>portalRole</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Turnpike_Email_Templates/Claim_closed</template>
    </alerts>
    <alerts>
        <fullName>email_bridgevine</fullName>
        <description>email bridgevine</description>
        <protected>false</protected>
        <recipients>
            <recipient>BridgevinePartnerUser</recipient>
            <type>portalRole</type>
        </recipients>
        <senderType>DefaultWorkflowUser</senderType>
        <template>Turnpike_Email_Templates/Claim_closed</template>
    </alerts>
    <alerts>
        <fullName>email_dgs</fullName>
        <description>email dgs</description>
        <protected>false</protected>
        <recipients>
            <recipient>DGSPartnerUser</recipient>
            <type>portalRole</type>
        </recipients>
        <senderType>DefaultWorkflowUser</senderType>
        <template>Turnpike_Email_Templates/Claim_closed</template>
    </alerts>
    <alerts>
        <fullName>email_hhgregg</fullName>
        <description>email hhgregg</description>
        <protected>false</protected>
        <recipients>
            <recipient>hhgreggPartnerUser</recipient>
            <type>portalRole</type>
        </recipients>
        <senderType>DefaultWorkflowUser</senderType>
        <template>Turnpike_Email_Templates/Claim_closed</template>
    </alerts>
    <alerts>
        <fullName>email_leapfrog</fullName>
        <description>email leapfrog</description>
        <protected>false</protected>
        <recipients>
            <recipient>LeapfrogPartnerUser</recipient>
            <type>portalRole</type>
        </recipients>
        <senderType>DefaultWorkflowUser</senderType>
        <template>Turnpike_Email_Templates/Claim_closed</template>
    </alerts>
    <alerts>
        <fullName>email_saveology</fullName>
        <description>email saveology</description>
        <protected>false</protected>
        <recipients>
            <recipient>SaveologyPartnerUser</recipient>
            <type>portalRole</type>
        </recipients>
        <senderType>DefaultWorkflowUser</senderType>
        <template>Turnpike_Email_Templates/Claim_closed</template>
    </alerts>
    <alerts>
        <fullName>email_verizon</fullName>
        <description>email verizon</description>
        <protected>false</protected>
        <recipients>
            <recipient>VerizonPartnerUser</recipient>
            <type>portalRole</type>
        </recipients>
        <senderType>DefaultWorkflowUser</senderType>
        <template>Turnpike_Email_Templates/Claim_closed</template>
    </alerts>
    <fieldUpdates>
        <fullName>Advisor_Case_Owner_Update</fullName>
        <field>OwnerId</field>
        <lookupValue>allison_starr@cable.comcast.com</lookupValue>
        <lookupValueType>User</lookupValueType>
        <name>Advisor Case Owner Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CASES_update_case_owner_to_RSA</fullName>
        <description>This will update the owner of the case to be the RSA queue</description>
        <field>OwnerId</field>
        <lookupValue>RSA_Ticket_Queue</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>CASES: update case owner to RSA</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Case_Owner_Change_for_SalesSpace_Coach</fullName>
        <field>OwnerId</field>
        <lookupValue>SR_Ticket_Management</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>Case Owner Change for SalesSpace Coach</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Case_Set_Case_Origin</fullName>
        <field>Origin</field>
        <literalValue>Direct Sales Mobile</literalValue>
        <name>Case-Set Case Origin</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Case_Set_Case_Origin_to_Web</fullName>
        <field>Origin</field>
        <literalValue>Web</literalValue>
        <name>Case-Set Case Origin to Web</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Change_OwnerSalesSpaceCoach_Huddle_Forum</fullName>
        <field>OwnerId</field>
        <lookupValue>SR_Ticket_Management</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>Change OwnerSalesSpaceCoach Huddle/Forum</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Chatter_Case_Owner_Update</fullName>
        <field>OwnerId</field>
        <lookupValue>alicia_petruszka@cable.comcast.com</lookupValue>
        <lookupValueType>User</lookupValueType>
        <name>Chatter Case Owner Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Chatter_Case_Owner_Update_1</fullName>
        <field>OwnerId</field>
        <lookupValue>alicia_petruszka@cable.comcast.com</lookupValue>
        <lookupValueType>User</lookupValueType>
        <name>Chatter Case Owner Update_1</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>New_Case_Owner_Update</fullName>
        <field>OwnerId</field>
        <lookupValue>sandra_houser@cable.comcast.com.prod</lookupValue>
        <lookupValueType>User</lookupValueType>
        <name>New Case Owner Update</name>
        <notifyAssignee>true</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Owner_update</fullName>
        <field>OwnerId</field>
        <lookupValue>Order_Lab_Sales_Portal_Queue</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>Owner update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Reminder_Check</fullName>
        <field>Final_Time_Reminder_Check__c</field>
        <literalValue>1</literalValue>
        <name>Reminder Check</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Case_Owner_to_SFA_Project_Team</fullName>
        <field>OwnerId</field>
        <lookupValue>sfapt@cable.comcast.com.prod</lookupValue>
        <lookupValueType>User</lookupValueType>
        <name>Update Case Owner to SFA Project Team</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Name_for_rally_field</fullName>
        <description>This field updates the &apos;Name for Rally&apos; field on case object.</description>
        <field>Name_For_Rally__c</field>
        <formula>LEFT(Description,30)</formula>
        <name>Update Name for rally field</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>WAVE_reassign_to_Mike_Angelo</fullName>
        <description>Assign case to Mike Angelo</description>
        <field>OwnerId</field>
        <lookupValue>michael_angelo@cable.comcast.com</lookupValue>
        <lookupValueType>User</lookupValueType>
        <name>WAVE reassign to Mike Angelo</name>
        <notifyAssignee>true</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Advisor Case Workflow</fullName>
        <actions>
            <name>Advisor_Case_Email_alert</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Advisor_Case_Owner_Update</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>SalesSpace Direct Sales</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Channel__c</field>
            <operation>equals</operation>
            <value>Direct Sales</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Request_Type__c</field>
            <operation>equals</operation>
            <value>Advisor</value>
        </criteriaItems>
        <description>Change the ownership of the Advisor case and send notification</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Assign Case to SFA Project Team</fullName>
        <actions>
            <name>Update_Case_Owner_to_SFA_Project_Team</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <booleanFilter>(1 AND 2) OR 3 OR 4</booleanFilter>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>SalesSpace Direct Sales</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Request_Type__c</field>
            <operation>notEqual</operation>
            <value>SalesSpace Coach</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>SalesSpace Property Lab</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>SalesSpace Indirect (Retail)</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>CASES%3A new case routed to RSA</fullName>
        <actions>
            <name>CASES_update_case_owner_to_RSA</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>This will route new cases that meet criteria to the RSA queue</description>
        <formula>AND(
      NOT(ISPICKVAL( Ticket_Category__c , &quot;Enhancement&quot;)),     
    OR(
        AND(
           ISPICKVAL( Request_Type__c , &quot;Wave&quot;),
           ISPICKVAL( Ticket_Category__c , &quot;Access/Permission&quot;)
          ),
        AND(
            ISPICKVAL( Request_Type__c , &quot;Communities&quot;),
            NOT(ISPICKVAL( Ticket_Category__c , &quot;Enhancement&quot;)),
            NOT(ISPICKVAL( Ticket_Category__c , &quot;Franchise/Legal Entity Database&quot;))
           ),
        ISPICKVAL( Request_Type__c , &quot;SalesSpace Home&quot;),
        ISPICKVAL( Request_Type__c , &quot;Airwatch&quot;),
        ISPICKVAL( Request_Type__c , &quot;Direct Sales Mobile App&quot;),
        ISPICKVAL( Request_Type__c , &quot;Salesforce.com&quot;),
        ISPICKVAL( Request_Type__c , &quot;SalesSpace Coach&quot;),
        ISPICKVAL( Request_Type__c , &quot;eSOF&quot;),
        ISPICKVAL( Request_Type__c , &quot;Property Lab&quot;),
        ISPICKVAL( Request_Type__c , &quot;Chatter&quot;),
        ISPICKVAL( Request_Type__c , &quot;Retail One&quot;)
  )
)</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Case Closed Email</fullName>
        <actions>
            <name>Close_Case_Email_Notification</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Closed</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Channel__c</field>
            <operation>equals</operation>
            <value>Order Lab/Sales Portal</value>
        </criteriaItems>
        <description>Send an email when a case is created</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Case Field Modification Email Alert</fullName>
        <actions>
            <name>Case_Field_Modification_Email_Alert_Sales_Portal</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <formula>AND( ISCHANGED(Customer_Name__c)|| ISCHANGED(Street__c)|| ISCHANGED(State__c) || ISCHANGED(Zip__c) || ISCHANGED(City__c) || ISCHANGED(Customer_Phone_Number__c) || ISCHANGED(AccountNumber__c) || ISCHANGED(OrderID__c) || ISCHANGED(Session_ID__c) || ISCHANGED(AffiliateNotes__c), ISPICKVAL(Status, &apos;In Progress&apos;) || ISPICKVAL(Status, &apos;New&apos;),ISPICKVAL(Channel__c, &apos;Order Lab/Sales Portal&apos;), RecordType.DeveloperName =&apos;SalesSpace_Order_Lab&apos; ||RecordType.DeveloperName =&apos;Post_Order_Escalation&apos; || RecordType.DeveloperName =&apos;Pre_Order_Escalation&apos;)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Case-Set Case Origin</fullName>
        <actions>
            <name>Case_Set_Case_Origin</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND (2 OR 3 OR 4 OR 5 OR 6 OR 7 OR 8 OR 9 OR 10 OR 11 OR 12 OR 13 OR 14)</booleanFilter>
        <criteriaItems>
            <field>Case.CreatedById</field>
            <operation>equals</operation>
            <value>Submit Case Site Guest User</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Closed Claim</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Open Accepted Claim</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Open Assigned Claim</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Post-Order Escalation</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Pre-Order Escalation</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Defect Management</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>SalesSpace Coach Huddle/Forum</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>SalesSpace Direct Sales</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>SalesSpace Indirect (Retail)</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>SalesSpace Property Lab</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>SalesSpace Communities</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>SalesSpace Chatter</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>SalesSpace Order Lab/Sales Portal</value>
        </criteriaItems>
        <description>Sets case origin</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Case-Set Case Origin to Web</fullName>
        <actions>
            <name>Case_Set_Case_Origin_to_Web</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND (2 OR 3 OR 4 OR 5 OR 6 OR 7 OR 8 OR 9 OR 10 OR 11 OR 12 OR 13 OR 14)</booleanFilter>
        <criteriaItems>
            <field>Case.CreatedById</field>
            <operation>notEqual</operation>
            <value>Submit Case Site Guest User</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Closed Claim</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Open Accepted Claim</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Open Assigned Claim</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Post-Order Escalation</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Pre-Order Escalation</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Defect Management</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>SalesSpace Coach Huddle/Forum</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>SalesSpace Direct Sales</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>SalesSpace Indirect (Retail)</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>SalesSpace Property Lab</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>SalesSpace Communities</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>SalesSpace Chatter</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>SalesSpace Order Lab/Sales Portal</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Chatter Case Workflow</fullName>
        <active>false</active>
        <booleanFilter>1</booleanFilter>
        <criteriaItems>
            <field>Case.Channel__c</field>
            <operation>equals</operation>
            <value>Chatter</value>
        </criteriaItems>
        <description>case workflow for channel = chatter</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Chatter Case Workflow_1</fullName>
        <actions>
            <name>Chatter_Case_Owner_Update_1</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <booleanFilter>1</booleanFilter>
        <criteriaItems>
            <field>Case.Channel__c</field>
            <operation>equals</operation>
            <value>Chatter</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Claim %3A Claim submission Notification</fullName>
        <actions>
            <name>Notify_Claim_Investigation_Queue_on_Claim_Submission</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Case.Claimed_Amount__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>New</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Notify_Threshold_Escalation_Queue_on_Open_Claims</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Case.Open_Claim_Notification__c</offsetFromField>
            <timeLength>20</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>Notify_Threshold_Escalation_Queue_on_Open_Claims</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Case.Open_Claim_Notification__c</offsetFromField>
            <timeLength>0</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>Notify_Threshold_Escalation_Queue_on_Open_Claims</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Case.Open_Claim_Notification__c</offsetFromField>
            <timeLength>5</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>Notify_Threshold_Escalation_Queue_on_Open_Claims</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Case.Open_Claim_Notification__c</offsetFromField>
            <timeLength>10</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>Notify_Threshold_Escalation_Queue_on_Open_Claims</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Case.Open_Claim_Notification__c</offsetFromField>
            <timeLength>30</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>Notify_Threshold_Escalation_Queue_on_Open_Claims</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Case.Open_Claim_Notification__c</offsetFromField>
            <timeLength>15</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>Notify_Threshold_Escalation_Queue_on_Open_Claims</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Case.Open_Claim_Notification__c</offsetFromField>
            <timeLength>40</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>Notify_Threshold_Escalation_Queue_on_Open_Claims</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Case.Open_Claim_Notification__c</offsetFromField>
            <timeLength>25</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>Notify_Threshold_Escalation_Queue_on_Open_Claims</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Case.Open_Claim_Notification__c</offsetFromField>
            <timeLength>35</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>Notify_Threshold_Escalation_Queue_on_Open_Claims</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Case.Open_Claim_Notification__c</offsetFromField>
            <timeLength>45</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Claim %3A Submit for Management Review</fullName>
        <actions>
            <name>Claim_submitted_for_Review</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Management Review</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Claim %3A Update Cancelled Claim to Closed Case Record Type</fullName>
        <active>false</active>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Cancelled</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Claim %3AUpdate Cancelled Claim to Closed Case Record Type</fullName>
        <active>false</active>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Closed</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>notEqual</operation>
            <value>Defect Management</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Defect Status Update</fullName>
        <actions>
            <name>Defect_Management_Case_Closed</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <formula>AND( 
ISCHANGED(Status), 
OR(RecordType.DeveloperName=&apos;SalesSpace_Chatter&apos;,RecordType.DeveloperName=&apos;	SalesSpace_Coach_Huddle_Forum&apos; ,RecordType.DeveloperName=&apos;SalesSpace_Communities&apos;,RecordType.DeveloperName=&apos;SalesSpace_Direct_Sales&apos;,RecordType.DeveloperName=&apos;SalesSpace_Retail_Sales&apos;,RecordType.DeveloperName=&apos;SalesSpace_Property_Lab&apos;)
)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Direct Sales Case Notification</fullName>
        <actions>
            <name>Email_for_Direct_Sales_Cases</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <booleanFilter>(1 AND 2 ) AND 3</booleanFilter>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>SalesSpace Direct Sales</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>New</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Channel__c</field>
            <operation>equals</operation>
            <value>Direct Sales</value>
        </criteriaItems>
        <description>This workflow rule is created to send an email notifications to Bob Deford and Zach Street for any new cases that is getting logged for Channel Direct Sales.</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>DirectSales SalesSpaceCoachCase Workflow</fullName>
        <actions>
            <name>Case_Owner_Change_for_SalesSpace_Coach</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <booleanFilter>1 AND 2</booleanFilter>
        <criteriaItems>
            <field>Case.Channel__c</field>
            <operation>equals</operation>
            <value>Direct Sales</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Request_Type__c</field>
            <operation>equals</operation>
            <value>SalesSpace Coach</value>
        </criteriaItems>
        <description>workflow for channel = direct sales, product type = sales space coach and record type = sr/ticket management</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Email Alert to Breta Martinez and Gwen Mooney for XC%2C PL and Coach Cases</fullName>
        <actions>
            <name>Email_Alert_to_Breta_Martinez_and_Gwen_Mooney</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>SalesSpace Communities,SalesSpace Property Lab</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Region__c</field>
            <operation>equals</operation>
            <value>Corporate</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Division__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Email Beltway On New Case</fullName>
        <actions>
            <name>Notify_Beltway_RSA_when_new_case_submitted</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <booleanFilter>1 AND 2 AND (3 OR 4 OR 5 OR 6 OR 7)</booleanFilter>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>New</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Region__c</field>
            <operation>contains</operation>
            <value>Beltway</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>SalesSpace Communities</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>SalesSpace Direct Sales</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>SalesSpace Indirect (Retail)</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>SalesSpace Property Lab</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>SalesSpace Coach Huddle/Forum</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Email Big South On New Case</fullName>
        <actions>
            <name>Notify_Big_South_RSA_when_new_case_submitted</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <booleanFilter>1 AND 2 AND (3 OR 4 OR 5 OR 6 OR 7)</booleanFilter>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>New</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Region__c</field>
            <operation>contains</operation>
            <value>Big South</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>SalesSpace Communities</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>SalesSpace Direct Sales</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>SalesSpace Indirect (Retail)</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>SalesSpace Property Lab</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>SalesSpace Coach Huddle/Forum</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Email California On New Case</fullName>
        <actions>
            <name>Notify_California_RSA_when_new_case_submitted</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <booleanFilter>1 AND 2 AND (3 OR 4 OR 5 OR 6 OR 7)</booleanFilter>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>New</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Region__c</field>
            <operation>contains</operation>
            <value>California</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>SalesSpace Communities</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>SalesSpace Direct Sales</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>SalesSpace Indirect (Retail)</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>SalesSpace Property Lab</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>SalesSpace Coach Huddle/Forum</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Email Chicago On New Case</fullName>
        <actions>
            <name>Notify_Chicago_RSA_when_new_case_submitted</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <booleanFilter>1 AND 2 AND (3 OR 4 OR 5 OR 6 OR 7)</booleanFilter>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>New</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Region__c</field>
            <operation>contains</operation>
            <value>Chicago</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>SalesSpace Communities</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>SalesSpace Direct Sales</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>SalesSpace Indirect (Retail)</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>SalesSpace Property Lab</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>SalesSpace Coach Huddle/Forum</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Email Florida On New Case</fullName>
        <actions>
            <name>Notify_Florida_RSA_when_new_case_submitted</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <booleanFilter>1 AND 2 AND (3 OR 4 OR 5 OR 6 OR 7)</booleanFilter>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>New</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Region__c</field>
            <operation>contains</operation>
            <value>Florida</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>SalesSpace Communities</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>SalesSpace Direct Sales</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>SalesSpace Indirect (Retail)</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>SalesSpace Property Lab</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>SalesSpace Coach Huddle/Forum</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Email Freedom On New Case</fullName>
        <actions>
            <name>Notify_Freedom_RSA_when_new_case_submitted</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <booleanFilter>1 AND 2 AND (3 OR 4 OR 5 OR 6 OR 7)</booleanFilter>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>New</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Region__c</field>
            <operation>contains</operation>
            <value>Freedom</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>SalesSpace Communities</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>SalesSpace Direct Sales</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>SalesSpace Indirect (Retail)</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>SalesSpace Property Lab</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>SalesSpace Coach Huddle/Forum</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Email Greater Boston On New Case</fullName>
        <actions>
            <name>Notify_GBR_RSA_when_new_case_submitted</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <booleanFilter>1 AND 2 AND (3 OR 4 OR 5 OR 6 OR 7)</booleanFilter>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>New</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Region__c</field>
            <operation>contains</operation>
            <value>Boston</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>SalesSpace Communities</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>SalesSpace Direct Sales</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>SalesSpace Indirect (Retail)</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>SalesSpace Property Lab</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>SalesSpace Coach Huddle/Forum</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Email Heartland On New Case</fullName>
        <actions>
            <name>Notify_Heartland_RSA_when_new_case_submitted</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <booleanFilter>1 AND 2 AND (3 OR 4 OR 5 OR 6 OR 7)</booleanFilter>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>New</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Region__c</field>
            <operation>contains</operation>
            <value>Heartland</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>SalesSpace Communities</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>SalesSpace Direct Sales</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>SalesSpace Indirect (Retail)</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>SalesSpace Property Lab</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>SalesSpace Coach Huddle/Forum</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Email Houston On New Case</fullName>
        <actions>
            <name>Notify_Houston_RSA_when_new_case_submitted</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <booleanFilter>1 AND 2 AND (3 OR 4 OR 5 OR 6 OR 7)</booleanFilter>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>New</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Region__c</field>
            <operation>contains</operation>
            <value>Houston</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>SalesSpace Communities</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>SalesSpace Direct Sales</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>SalesSpace Indirect (Retail)</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>SalesSpace Property Lab</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>SalesSpace Coach Huddle/Forum</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Email Keystone On New Case</fullName>
        <actions>
            <name>Notify_Keystone_RSA_when_new_case_submitted</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <booleanFilter>1 AND 2 AND (3 OR 4 OR 5 OR 6 OR 7)</booleanFilter>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>New</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Region__c</field>
            <operation>contains</operation>
            <value>Keystone</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>SalesSpace Communities</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>SalesSpace Direct Sales</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>SalesSpace Indirect (Retail)</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>SalesSpace Property Lab</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>SalesSpace Coach Huddle/Forum</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Email Mile High On New Case</fullName>
        <actions>
            <name>Notify_Mile_High_RSA_when_new_case_submitted</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <booleanFilter>1 AND 2 AND (3 OR 4 OR 5 OR 6 OR 7)</booleanFilter>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>New</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Region__c</field>
            <operation>contains</operation>
            <value>Mile High</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>SalesSpace Communities</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>SalesSpace Direct Sales</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>SalesSpace Indirect (Retail)</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>SalesSpace Property Lab</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>SalesSpace Coach Huddle/Forum</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Email Mountain On New Case</fullName>
        <actions>
            <name>Notify_Mountain_RSA_when_new_case_submitted</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <booleanFilter>1 AND 2 AND (3 OR 4 OR 5 OR 6 OR 7)</booleanFilter>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>New</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Region__c</field>
            <operation>contains</operation>
            <value>Salt Lake City</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>SalesSpace Communities</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>SalesSpace Direct Sales</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>SalesSpace Indirect (Retail)</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>SalesSpace Property Lab</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>SalesSpace Coach Huddle/Forum</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Email Portland On New Case</fullName>
        <actions>
            <name>Notify_Portland_RSA_when_new_case_submitted</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <booleanFilter>1 AND 2 AND (3 OR 4 OR 5 OR 6 OR 7)</booleanFilter>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>New</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Region__c</field>
            <operation>contains</operation>
            <value>Portland/Salem</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>SalesSpace Communities</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>SalesSpace Direct Sales</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>SalesSpace Indirect (Retail)</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>SalesSpace Property Lab</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>SalesSpace Coach Huddle/Forum</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Email Seattle On New Case</fullName>
        <actions>
            <name>Notify_Seattle_RSA_when_new_case_submitted</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <booleanFilter>1 AND 2 AND (3 OR 4 OR 5 OR 6 OR 7)</booleanFilter>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>New</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Region__c</field>
            <operation>contains</operation>
            <value>Seattle</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>SalesSpace Communities</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>SalesSpace Direct Sales</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>SalesSpace Indirect (Retail)</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>SalesSpace Property Lab</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>SalesSpace Coach Huddle/Forum</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Email Tier 2 when case is assigned</fullName>
        <actions>
            <name>Email_Tier_2_when_case_is_assigned</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <booleanFilter>1 AND (2 OR 3 OR 4 OR 5 OR 6 OR 7 OR 8 OR 9 OR 10 OR 11 OR 12 OR 13 OR 14)</booleanFilter>
        <criteriaItems>
            <field>Case.OwnerId</field>
            <operation>equals</operation>
            <value>SR/Ticket Management</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Closed Claim</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Open Accepted Claim</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Open Assigned Claim</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Post-Order Escalation</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Pre-Order Escalation</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Defect Management</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>SalesSpace Coach Huddle/Forum</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>SalesSpace Direct Sales</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>SalesSpace Indirect (Retail)</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>SalesSpace Property Lab</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>SalesSpace Communities</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>SalesSpace Chatter</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>SalesSpace Order Lab/Sales Portal</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Email Twin Cities On New Case</fullName>
        <actions>
            <name>Notify_Twin_Cities_RSA_when_new_case_submitted</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <booleanFilter>1 AND 2 AND (3 OR 4 OR 5 OR 6)</booleanFilter>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>New</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Region__c</field>
            <operation>contains</operation>
            <value>Twin Cities</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>SalesSpace Communities</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>SalesSpace Direct Sales</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>SalesSpace Indirect (Retail)</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>SalesSpace Property Lab</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Email Western New England On New Case</fullName>
        <actions>
            <name>Notify_WNE_RSA_when_new_case_submitted</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <booleanFilter>1 AND 2 AND (3 OR 4 OR 5 OR 6)</booleanFilter>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>New</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Region__c</field>
            <operation>contains</operation>
            <value>Western New England</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>SalesSpace Communities</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>SalesSpace Direct Sales</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>SalesSpace Indirect (Retail)</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>SalesSpace Property Lab</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Email allconnect commission</fullName>
        <actions>
            <name>email_allconnect</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <formula>AND( Affiliate_Account__r.Id = &apos;001G000000xCpz2&apos;,  ISPICKVAL( Status , &apos;Closed&apos;) , ( RecordType.Name=&apos;Open Accepted Claim&apos; || RecordType.Name=&apos;Open Assigned Claim&apos; || RecordType.Name= &apos;Closed Claim&apos;))</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Email bridgevine commission</fullName>
        <actions>
            <name>email_bridgevine</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <formula>AND( Affiliate_Account__r.Id = &apos;001G000000xCpzH&apos;,  ISPICKVAL( Status , &apos;Closed&apos;) , ( RecordType.Name=&apos;Open Accepted Claim&apos; || RecordType.Name=&apos;Open Assigned Claim&apos; || RecordType.Name= &apos;Closed Claim&apos;))</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Email dgs commission</fullName>
        <actions>
            <name>email_dgs</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <formula>AND( Affiliate_Account__r.Id = &apos;001G000000xCpzq&apos;,  ISPICKVAL( Status , &apos;Closed&apos;) , ( RecordType.Name=&apos;Open Accepted Claim&apos; || RecordType.Name=&apos;Open Assigned Claim&apos; || RecordType.Name= &apos;Closed Claim&apos;))</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Email hhgregg commission</fullName>
        <actions>
            <name>email_hhgregg</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <formula>AND( Affiliate_Account__r.Id = &apos;001G000000xDXRr&apos;,  ISPICKVAL( Status , &apos;Closed&apos;) , ( RecordType.Name=&apos;Open Accepted Claim&apos; || RecordType.Name=&apos;Open Assigned Claim&apos; || RecordType.Name= &apos;Closed Claim&apos;))</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Email leapfrog commission</fullName>
        <actions>
            <name>email_leapfrog</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <formula>AND( Affiliate_Account__r.Id = &apos;001G000000xCq00&apos;,  ISPICKVAL( Status , &apos;Closed&apos;) , ( RecordType.Name=&apos;Open Accepted Claim&apos; || RecordType.Name=&apos;Open Assigned Claim&apos; || RecordType.Name= &apos;Closed Claim&apos;))</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Email saveology commission</fullName>
        <actions>
            <name>email_saveology</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <formula>AND( Affiliate_Account__r.Id = &apos;001G000000vEYqW&apos;,  ISPICKVAL( Status , &apos;Closed&apos;) , ( RecordType.Name=&apos;Open Accepted Claim&apos; || RecordType.Name=&apos;Open Assigned Claim&apos; || RecordType.Name= &apos;Closed Claim&apos;))</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Email verizon commission</fullName>
        <actions>
            <name>email_verizon</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <formula>AND( Affiliate_Account__r.Id = &apos;001G000000vDxAd&apos;,  ISPICKVAL( Status , &apos;Closed&apos;) , ( RecordType.Name=&apos;Open Accepted Claim&apos; || RecordType.Name=&apos;Open Assigned Claim&apos; || RecordType.Name= &apos;Closed Claim&apos;))</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Enhancement Status update Alerts</fullName>
        <actions>
            <name>Enhancement_added_to_backlog</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <formula>OR( RALLYSM__Rally_Association__c  = &apos;Yes&apos;  &amp;&amp; ( ISPICKVAL( Status , &apos;In Progress&apos;)  ||  ISPICKVAL( Status , &apos;Added to Release Plan&apos;)  ||  ISPICKVAL( Status , &apos;Approved and Added to Backlog&apos;))  &amp;&amp;   ISCHANGED( Status ) ,AND(ISCHANGED(Status),TEXT(Ticket_Category__c) =&apos;Enhancement&apos;,OR(RecordType.Name=&apos;SalesSpace Direct Sales&apos;,RecordType.Name=&apos;SalesSpace Indirect (Retail)&apos;,RecordType.Name=&apos;SalesSpace Property Lab&apos;,RecordType.Name=&apos;SalesSpace Communities&apos;,RecordType.Name=&apos;SalesSpace Chatter&apos;,RecordType.Name=&apos;SalesSpace Order Lab/Sales Portal&apos;)))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Franchise%2FLegal Entity Database Case Routing</fullName>
        <actions>
            <name>New_Case_Email_Alert</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>New_Case_Owner_Update</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>SalesSpace Communities</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Ticket_Category__c</field>
            <operation>equals</operation>
            <value>Franchise/Legal Entity Database</value>
        </criteriaItems>
        <description>Franchise/Legal Entity Database Cases Routed to Sandra Houser</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>New Email Reminder</fullName>
        <actions>
            <name>Reminder_Check</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND (2 OR 3) AND (4 OR 5 OR 6 OR 7 OR 8 OR 9 OR 10 OR 11 OR 12 OR 13 OR 14 OR 15 OR 16)</booleanFilter>
        <criteriaItems>
            <field>Case.Number_Of_Reminders__c</field>
            <operation>equals</operation>
            <value>3</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Pending User Clarification</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Pending User Confirmation</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Closed Claim</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Open Accepted Claim</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Open Assigned Claim</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Post-Order Escalation</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Defect Management</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>SalesSpace Coach Huddle/Forum</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>SalesSpace Direct Sales</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>SalesSpace Indirect (Retail)</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>SalesSpace Property Lab</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>SalesSpace Communities</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Pre-Order Escalation</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>SalesSpace Chatter</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>SalesSpace Order Lab/Sales Portal</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Non-Affiliate Modified</fullName>
        <actions>
            <name>Affiliate_case_update_by_non_Affiliate_User</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Post-Order Escalation,Pre-Order Escalation,SalesSpace Order Lab/Sales Portal</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.CreatedById</field>
            <operation>notEqual</operation>
            <value>LastModifiedById</value>
        </criteriaItems>
        <description>Notifies Affiliate case owner when can has been modified by a non Affiliate user</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Notify Requested For After Case Creation</fullName>
        <actions>
            <name>Notify_Requested_For_After_case_creation</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>SalesSpace Coach Huddle/Forum,SalesSpace Chatter,SalesSpace Communities,SalesSpace Direct Sales,SalesSpace Order Lab/Sales Portal,SalesSpace Property Lab,SalesSpace Indirect (Retail),SalesSpace NSO</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Region__c</field>
            <operation>equals</operation>
            <value>Corporate</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Ticket_Category__c</field>
            <operation>equals</operation>
            <value>Enhancement</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Order Lab%2FSales Portal Case workflow</fullName>
        <actions>
            <name>Auto_Response_Mail</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>New_Case_Creation_Email</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Owner_update</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Channel__c</field>
            <operation>equals</operation>
            <value>Order Lab/Sales Portal</value>
        </criteriaItems>
        <description>Send an email every time a case is created</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Owner Update Mail Notification Rule</fullName>
        <actions>
            <name>Owner_change_mail</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Changes in Case support setting to  default template, hence rule is created to sent mail when owner is changed.</description>
        <formula>AND( ISCHANGED( OwnerId ) , OR((RecordType.Name = &apos;SalesSpace Communities&apos;), (RecordType.Name = &apos;SalesSpace Direct Sales&apos;),
(RecordType.Name = &apos;SalesSpace Order Lab/Sales Portal&apos;),(RecordType.Name = &apos;SalesSpace Property Lab&apos;), 
(RecordType.Name = &apos;SalesSpace Indirect (Retail)&apos;),(RecordType.Name = &apos;SalesSpace Chatter&apos;),(RecordType.Name = &apos;SalesSpace Coach Huddle/Forum&apos;)))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>SalesSpace Coach Huddle%2FForum</fullName>
        <actions>
            <name>Change_OwnerSalesSpaceCoach_Huddle_Forum</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <booleanFilter>1 AND 2 AND 3</booleanFilter>
        <criteriaItems>
            <field>Case.Channel__c</field>
            <operation>equals</operation>
            <value>Direct Sales</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Request_Type__c</field>
            <operation>equals</operation>
            <value>SalesSpace Coach</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>SalesSpace Coach Huddle/Forum</value>
        </criteriaItems>
        <description>This workflow is for SalesSpace Coach Huddle/Forum</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Update Rally Name</fullName>
        <actions>
            <name>Update_Name_for_rally_field</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>true</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>WAVE assignment of new case</fullName>
        <actions>
            <name>Alert_Wave_Team_on_New_Cases</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>WAVE_reassign_to_Mike_Angelo</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>SalesSpace Communities</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Request_Type__c</field>
            <operation>equals</operation>
            <value>Wave</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Ticket_Category__c</field>
            <operation>equals</operation>
            <value>Reporting</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Ticket_Category_II__c</field>
            <operation>equals</operation>
            <value>Access Adjustment,Dataset Creation,Incorrect Data,New Lens/Dashboard request,Other,Wave Access</value>
        </criteriaItems>
        <description>This will auto assign certain case ticket categories to Mike Angelo for Wave issues</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
