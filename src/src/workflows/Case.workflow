<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Advisor_Case_Email_alert</fullName>
        <description>Advisor Case Email alert</description>
        <protected>false</protected>
        <recipients>
            <recipient>alicia_petruszka@cable.comcast.com</recipient>
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
            <recipient>jai_nalwa@comcast.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>michael_angelo@cable.comcast.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>michael_whitenack@cable.comcast.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>minh_wong@cable.comcast.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>timothy_unrath@cable.comcast.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>william_mcginly@comcast.com</recipient>
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
        <ccEmails>Indirect_Sales_Portal_Support@cable.comcast.com</ccEmails>
        <ccEmails>Marietta_lehman@comcast.com</ccEmails>
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
        <fullName>Central_Order_Lab_Case_Email_Alert</fullName>
        <ccEmails>Elizabeth_Haworth@comcast.com</ccEmails>
        <ccEmails>Nicholas_Eagan@cable.comcast.com</ccEmails>
        <ccEmails>Jeremy_Segal@cable.comcast.com</ccEmails>
        <ccEmails>Jessica_Rowland@cable.comcast.com</ccEmails>
        <ccEmails>Cheryl_Amundson@cable.comcast.com</ccEmails>
        <description>Central Order Lab Case Email Alert</description>
        <protected>false</protected>
        <recipients>
            <recipient>jeremy_segal@cable.comcast.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>jessica_rowland@cable.comcast.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>nicholas_eagan@cable.comcast.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Direct_Sales_Email_Templates/New_Case</template>
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
        <ccEmails>Indirect_Sales_Portal_Support@cable.comcast.com</ccEmails>
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
            <recipient>marietta_lehman@comcast.com</recipient>
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
        <template>Cases_Email_Templates/Case_Status_Change</template>
    </alerts>
    <alerts>
        <fullName>Direct_and_Communities_Product_Queue</fullName>
        <description>Direct and Communities - Product Queue</description>
        <protected>false</protected>
        <recipients>
            <recipient>sandra_valenti@cable.comcast.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Direct_Sales_Email_Templates/New_Case_Admin</template>
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
        <ccEmails>comcast_resi_support@comcast.com</ccEmails>
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
            <recipient>sandra_valenti@cable.comcast.com</recipient>
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
        <recipients>
            <recipient>jane_morgenstern@comcast.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>marietta_lehman@comcast.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Cases_Email_Templates/New_Case_Update</template>
    </alerts>
    <alerts>
        <fullName>New_Case_Email_Alert</fullName>
        <description>New Case Email Alert</description>
        <protected>false</protected>
        <recipients>
            <recipient>pam_nanavaty@cable.comcast.com</recipient>
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
        <ccEmails>comcast_resi_support@comcast.com</ccEmails>
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
        <ccEmails>comcast_resi_support@comcast.com</ccEmails>
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
        <ccEmails>comcast_resi_support@comcast.com</ccEmails>
        <description>Notify California RSA when new case submitted</description>
        <protected>false</protected>
        <recipients>
            <recipient>mark_babel@cable.comcast.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>mary_leland@cable.comcast.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>meriko_robert@cable.comcast.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>necole_porter@cable.comcast.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>raye_kilinski-williamson@cable.comcast.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Direct_Sales_Email_Templates/New_Case</template>
    </alerts>
    <alerts>
        <fullName>Notify_Chicago_RSA_when_new_case_submitted</fullName>
        <ccEmails>comcast_resi_support@comcast.com</ccEmails>
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
        <ccEmails>comcast_resi_support@comcast.com</ccEmails>
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
        <ccEmails>comcast_resi_support@comcast.com</ccEmails>
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
        <ccEmails>comcast_resi_support@comcast.com</ccEmails>
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
        <ccEmails>comcast_resi_support@comcast.com</ccEmails>
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
        <ccEmails>comcast_resi_support@comcast.com</ccEmails>
        <description>Notify Houston RSA when new case submitted</description>
        <protected>false</protected>
        <recipients>
            <recipient>amy_smith4@cable.comcast.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>cara_kinnen@cable.comcast.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>james_thomas3@cable.comcast.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Direct_Sales_Email_Templates/New_Case</template>
    </alerts>
    <alerts>
        <fullName>Notify_Keystone_RSA_when_new_case_submitted</fullName>
        <ccEmails>comcast_resi_support@comcast.com</ccEmails>
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
        <ccEmails>comcast_resi_support@comcast.com</ccEmails>
        <description>Notify Mile High RSA when new case submitted</description>
        <protected>false</protected>
        <recipients>
            <recipient>Mountain_West_Region_RSA</recipient>
            <type>group</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Direct_Sales_Email_Templates/New_Case</template>
    </alerts>
    <alerts>
        <fullName>Notify_Mountain_RSA_when_new_case_submitted</fullName>
        <ccEmails>comcast_resi_support@comcast.com</ccEmails>
        <description>Notify Mountain RSA when new case submitted</description>
        <protected>false</protected>
        <recipients>
            <recipient>alicia_maes@cable.comcast.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>edward_goettig@cable.comcast.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Direct_Sales_Email_Templates/New_Case</template>
    </alerts>
    <alerts>
        <fullName>Notify_Portland_RSA_when_new_case_submitted</fullName>
        <ccEmails>comcast_resi_support@comcast.com</ccEmails>
        <description>Notify Portland RSA when new case submitted</description>
        <protected>false</protected>
        <recipients>
            <recipient>donald_brown4@cable.comcast.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>twyla_sirrine@cable.comcast.com</recipient>
            <type>user</type>
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
        <ccEmails>comcast_resi_support@comcast.com</ccEmails>
        <description>Notify Seattle RSA when new case submitted</description>
        <protected>false</protected>
        <recipients>
            <recipient>edna_zacharczyk@cable.comcast.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>travis_whetman@cable.comcast.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>vanessa_patao@cable.comcast.com</recipient>
            <type>user</type>
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
        <ccEmails>comcast_resi_support@comcast.com</ccEmails>
        <description>Notify Twin Cities RSA when new case submitted</description>
        <protected>false</protected>
        <recipients>
            <recipient>blake_holland@cable.comcast.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>travis_stiller@cable.comcast.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Direct_Sales_Email_Templates/New_Case</template>
    </alerts>
    <alerts>
        <fullName>Notify_WNE_RSA_when_new_case_submitted</fullName>
        <ccEmails>comcast_resi_support@comcast.com</ccEmails>
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
            <recipient>alicia_petruszka@cable.comcast.com</recipient>
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
        <fullName>Wave_Only_Case_Auto_Response</fullName>
        <description>Wave Only Case Auto Response</description>
        <protected>false</protected>
        <recipients>
            <field>SuppliedEmail</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Cases_Email_Templates/Wave_Only_Case_Reply</template>
    </alerts>
    <alerts>
        <fullName>Wave_Only_Email_Alert_to_Wave_Support</fullName>
        <description>Wave Only Email Alert to Wave Support</description>
        <protected>false</protected>
        <recipients>
            <recipient>Wave_Only_Case_Support</recipient>
            <type>group</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Cases_Email_Templates/Wave_Only_Case_Support</template>
    </alerts>
    <alerts>
        <fullName>XR_Case_Reassignment</fullName>
        <description>XR Case Reassignment</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Cases_Email_Templates/XR_Case_Reassignment</template>
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
        <lookupValue>pam_nanavaty@cable.comcast.com</lookupValue>
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
        <fullName>SFPS_GNC_Set_Default_GNC_Priority_Date</fullName>
        <field>SFPS_GNC_PriorityDate__c</field>
        <formula>CreatedDate</formula>
        <name>SFPS GNC Set Default GNC Priority Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
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
        <lookupValue>Wave_Only_Email_to_Case_Support</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>WAVE reassign to Mike Angelo</name>
        <notifyAssignee>true</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>XR_Case_Status_Update</fullName>
        <description>XR Case Status Update</description>
        <field>Status</field>
        <literalValue>In Progress</literalValue>
        <name>XR Case Status Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>XR_New_Case_Create_Field_Update</fullName>
        <field>Last_Message_Sent__c</field>
        <formula>&quot;New Case&quot;</formula>
        <name>XR New Case Create Field Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>XR_Send_To_Q_Flag</fullName>
        <field>XR_Send_Case_to_Queue__c</field>
        <literalValue>1</literalValue>
        <name>XR Send To Q Flag</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>XR_Sent_to_Queue</fullName>
        <field>OwnerId</field>
        <lookupValue>Xfinity_Responds</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>XR Sent to Queue</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>XR_Set_Close_Reason</fullName>
        <field>Closed_Reason__c</field>
        <literalValue>System Closed</literalValue>
        <name>XR Set Close Reason</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>XR_Set_Close_Reason_agent</fullName>
        <field>Closed_Reason__c</field>
        <literalValue>Agent Closed</literalValue>
        <name>XR Set Close Reason agent</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>XR_Set_Customer_Action_Date</fullName>
        <field>Customer_Action_Date__c</field>
        <formula>NOW()</formula>
        <name>XR Set Customer Action Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>XR_Set_Customer_Action_Date_NULL</fullName>
        <field>Customer_Action_Date__c</field>
        <name>XR Set Customer Action Date NULL</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>XR_Set_Last_Message_1</fullName>
        <field>Last_Message_Sent__c</field>
        <formula>TEXT( Status )</formula>
        <name>XR Set Last Message 1</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>XR_Set_Last_Message_2</fullName>
        <field>Last_Message_Sent__c</field>
        <formula>&quot;Follow-up 1&quot;</formula>
        <name>XR Set Last Message 2</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>XR_Set_Last_Message_3</fullName>
        <field>Last_Message_Sent__c</field>
        <formula>&quot;Follow-up 2&quot;</formula>
        <name>XR Set Last Message 3</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>XR_Set_Last_Message_4</fullName>
        <field>Last_Message_Sent__c</field>
        <formula>&quot;Follow-up 3&quot;</formula>
        <name>XR Set Last Message 4</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>XR_Set_Last_Message_Closed</fullName>
        <field>Last_Message_Sent__c</field>
        <formula>&quot;Agent Closed&quot;</formula>
        <name>XR Set Last Message Closed</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>XR_Set_SLA_Date</fullName>
        <field>SLA_Due_Date__c</field>
        <name>XR Set SLA Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>XR_Set_Send_to_Q_Flag</fullName>
        <field>XR_Send_Case_to_Queue__c</field>
        <literalValue>1</literalValue>
        <name>XR Set Send to Q Flag</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>XR_Set_Status_Closed</fullName>
        <field>Status</field>
        <literalValue>Closed</literalValue>
        <name>XR Set Status Closed</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>XR_Update_Followup_Count</fullName>
        <field>Followup_Count__c</field>
        <formula>Followup_Count__c +1</formula>
        <name>XR Update Followup Count</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>XR_Update_Status</fullName>
        <description>If the SLA Due Date field = NOW() and the status is &quot;Awaiting Internal&quot;, then the System will set the Status to “Back from Internal”</description>
        <field>Status</field>
        <literalValue>Back from Internal</literalValue>
        <name>XR Update Status</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>XR_Update_Status_Followup</fullName>
        <field>Status</field>
        <literalValue>Follow-up</literalValue>
        <name>XR Update Status Followup</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <outboundMessages>
        <fullName>XR_New_Case_Outbound_Message</fullName>
        <apiVersion>37.0</apiVersion>
        <endpointUrl>https://capi-tkt-west.azurewebsites.net/api/ticketing/events/ticket/created</endpointUrl>
        <fields>AccountNumber__c</fields>
        <fields>CaseNumber</fields>
        <fields>CreatedDate</fields>
        <fields>Customer_Category__c</fields>
        <fields>Customer_Status__c</fields>
        <fields>Id</fields>
        <fields>SuppliedEmail</fields>
        <includeSessionId>false</includeSessionId>
        <integrationUser>!bizsalesforceapi@comcast.prod</integrationUser>
        <name>XR New Case Outbound Message</name>
        <protected>false</protected>
        <useDeadLetterQueue>false</useDeadLetterQueue>
    </outboundMessages>
    <outboundMessages>
        <fullName>XR_OB_Closed</fullName>
        <apiVersion>37.0</apiVersion>
        <endpointUrl>https://capi-tkt-west.azurewebsites.net/api/ticketing/events/ticket/closed</endpointUrl>
        <fields>AccountNumber__c</fields>
        <fields>CaseNumber</fields>
        <fields>CreatedDate</fields>
        <fields>Customer_Category__c</fields>
        <fields>Customer_Status__c</fields>
        <fields>Id</fields>
        <fields>SuppliedEmail</fields>
        <includeSessionId>false</includeSessionId>
        <integrationUser>!bizsalesforceapi@comcast.prod</integrationUser>
        <name>XR OB Closed</name>
        <protected>false</protected>
        <useDeadLetterQueue>false</useDeadLetterQueue>
    </outboundMessages>
    <outboundMessages>
        <fullName>XR_OB_Reminder_1</fullName>
        <apiVersion>37.0</apiVersion>
        <endpointUrl>https://capi-tkt-west.azurewebsites.net/api/ticketing/events/ticket/reminder/1</endpointUrl>
        <fields>AccountNumber__c</fields>
        <fields>CaseNumber</fields>
        <fields>CreatedDate</fields>
        <fields>Customer_Category__c</fields>
        <fields>Customer_Status__c</fields>
        <fields>Id</fields>
        <fields>SuppliedEmail</fields>
        <includeSessionId>false</includeSessionId>
        <integrationUser>!bizsalesforceapi@comcast.prod</integrationUser>
        <name>XR OB Reminder 1</name>
        <protected>false</protected>
        <useDeadLetterQueue>false</useDeadLetterQueue>
    </outboundMessages>
    <outboundMessages>
        <fullName>XR_OB_Reminder_2</fullName>
        <apiVersion>37.0</apiVersion>
        <endpointUrl>https://capi-tkt-west.azurewebsites.net/api/ticketing/events/ticket/reminder/2</endpointUrl>
        <fields>AccountNumber__c</fields>
        <fields>CaseNumber</fields>
        <fields>CreatedDate</fields>
        <fields>Customer_Category__c</fields>
        <fields>Customer_Status__c</fields>
        <fields>Id</fields>
        <fields>SuppliedEmail</fields>
        <includeSessionId>false</includeSessionId>
        <integrationUser>!bizsalesforceapi@comcast.prod</integrationUser>
        <name>XR OB Reminder 2</name>
        <protected>false</protected>
        <useDeadLetterQueue>false</useDeadLetterQueue>
    </outboundMessages>
    <outboundMessages>
        <fullName>XR_OB_Reminder_3</fullName>
        <apiVersion>37.0</apiVersion>
        <endpointUrl>https://capi-tkt-west.azurewebsites.net/api/ticketing/events/ticket/reminder/3</endpointUrl>
        <fields>AccountNumber__c</fields>
        <fields>CaseNumber</fields>
        <fields>CreatedDate</fields>
        <fields>Customer_Category__c</fields>
        <fields>Customer_Status__c</fields>
        <fields>Id</fields>
        <fields>SuppliedEmail</fields>
        <includeSessionId>false</includeSessionId>
        <integrationUser>!bizsalesforceapi@comcast.prod</integrationUser>
        <name>XR OB Reminder 3</name>
        <protected>false</protected>
        <useDeadLetterQueue>false</useDeadLetterQueue>
    </outboundMessages>
    <outboundMessages>
        <fullName>XR_updated_event</fullName>
        <apiVersion>37.0</apiVersion>
        <endpointUrl>https://capi-tkt-west.azurewebsites.net/api/ticketing/events/ticket/updated</endpointUrl>
        <fields>AccountNumber__c</fields>
        <fields>CaseNumber</fields>
        <fields>CreatedDate</fields>
        <fields>Customer_Category__c</fields>
        <fields>Customer_Status__c</fields>
        <fields>Id</fields>
        <fields>SuppliedEmail</fields>
        <includeSessionId>false</includeSessionId>
        <integrationUser>!bizsalesforceapi@comcast.prod</integrationUser>
        <name>XR updated event</name>
        <protected>false</protected>
        <useDeadLetterQueue>false</useDeadLetterQueue>
    </outboundMessages>
    <rules>
        <fullName>Advisor Case Workflow</fullName>
        <actions>
            <name>Advisor_Case_Email_alert</name>
            <type>Alert</type>
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
        <formula>AND( ISCHANGED(Customer_Name__c)|| ISCHANGED(Street__c)|| ISCHANGED(State__c) || ISCHANGED(Zip__c) || ISCHANGED(City__c) || ISCHANGED(Customer_Phone_Number__c) || ISCHANGED(AccountNumber__c) || ISCHANGED(OrderID__c) || ISCHANGED(Status) || ISCHANGED(Session_ID__c) || ISCHANGED(AffiliateNotes__c)|| ISCHANGED(ComcastNotes__c), ISPICKVAL(Channel__c, &apos;Order Lab/Sales Portal&apos;), RecordType.DeveloperName =&apos;SalesSpace_Order_Lab&apos; ||RecordType.DeveloperName =&apos;Post_Order_Escalation&apos; || RecordType.DeveloperName =&apos;Pre_Order_Escalation&apos;)</formula>
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
        <formula>AND(  ISCHANGED(Status),  OR(RecordType.DeveloperName=&apos;SalesSpace_Chatter&apos;,RecordType.DeveloperName=&apos;	SalesSpace_Coach_Huddle_Forum&apos; ,RecordType.DeveloperName=&apos;SalesSpace_Communities&apos;,RecordType.DeveloperName=&apos;SalesSpace_Direct_Sales&apos;,RecordType.DeveloperName=&apos;SalesSpace_Retail_Sales&apos;,RecordType.DeveloperName=&apos;SalesSpace_Property_Lab&apos;) )</formula>
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
        <fullName>Direct or Communities Cases Routed to Product Queue</fullName>
        <actions>
            <name>Direct_and_Communities_Product_Queue</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.OwnerId</field>
            <operation>equals</operation>
            <value>Product Queue</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>SalesSpace Communities,SalesSpace Direct Sales</value>
        </criteriaItems>
        <description>When an enhancement requests for Communities and Direct Sales is sent, a new case alert is sent</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
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
        <fullName>Email NSO Group for new NSO Cases</fullName>
        <actions>
            <name>NSO_Group_Alert</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>SalesSpace NSO</value>
        </criteriaItems>
        <description>Email Alert to NSO Group for new NSO Cases</description>
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
        <formula>AND(ISCHANGED(Status),TEXT(Ticket_Category__c) =&apos;Enhancement&apos;,OR(RecordType.Name=&apos;SalesSpace Direct Sales&apos;,RecordType.Name=&apos;SalesSpace Indirect (Retail)&apos;,RecordType.Name=&apos;SalesSpace Property Lab&apos;,RecordType.Name=&apos;SalesSpace Communities&apos;,RecordType.Name=&apos;SalesSpace Chatter&apos;,RecordType.Name=&apos;SalesSpace Order Lab/Sales Portal&apos;))</formula>
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
        <fullName>Order Lab Central Case Workflow</fullName>
        <actions>
            <name>Central_Order_Lab_Case_Email_Alert</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Channel__c</field>
            <operation>equals</operation>
            <value>Order Lab/Sales Portal</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Region__c</field>
            <operation>equals</operation>
            <value>Greater Chicago Market,Big South Region,Heartland Region,Florida Region</value>
        </criteriaItems>
        <description>Send an email every time a case is created</description>
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
        <formula>AND( ISCHANGED( OwnerId ) , OR((RecordType.Name = &apos;SalesSpace Communities&apos;), (RecordType.Name = &apos;SalesSpace Direct Sales&apos;), (RecordType.Name = &apos;SalesSpace Order Lab/Sales Portal&apos;),(RecordType.Name = &apos;SalesSpace Property Lab&apos;),  (RecordType.Name = &apos;SalesSpace Indirect (Retail)&apos;),(RecordType.Name = &apos;SalesSpace Chatter&apos;),(RecordType.Name = &apos;SalesSpace Coach Huddle/Forum&apos;)))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Reply to submitter of Wave Case</fullName>
        <actions>
            <name>Wave_Only_Case_Auto_Response</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Wave Only User</value>
        </criteriaItems>
        <description>Autoreply to Wave Only email-to-case</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>SFPS_GNC Priority Date is NULL</fullName>
        <actions>
            <name>SFPS_GNC_Set_Default_GNC_Priority_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.SFPS_GNC_PriorityDate__c</field>
            <operation>equals</operation>
        </criteriaItems>
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
            <value>SalesSpace Communities,SalesSpace Direct Sales,SalesSpace Indirect (Retail)</value>
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
        <description>This will auto assign certain case ticket categories to Mike Angelo for Wave issues</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Wave Only Email-to-Case Alert to Wave Support Team</fullName>
        <actions>
            <name>Wave_Only_Email_Alert_to_Wave_Support</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Wave Only User</value>
        </criteriaItems>
        <description>This workflow sends an email to the Wave Support Group for all new Wave Only email-to-cases</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>XR New Case Create</fullName>
        <actions>
            <name>XR_New_Case_Create_Field_Update</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>XR_New_Case_Outbound_Message</name>
            <type>OutboundMessage</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Residential</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Origin</field>
            <operation>equals</operation>
            <value>Web-XR</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>New</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>XR New Case Owner Field Update</fullName>
        <actions>
            <name>XR_Case_Status_Update</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.OwnerId</field>
            <operation>notEqual</operation>
            <value>Xfinity Responds</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>New</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Origin</field>
            <operation>equals</operation>
            <value>Web-XR</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Residential</value>
        </criteriaItems>
        <description>XR New Case Owner Field Update</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>XR Return to Queue</fullName>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Residential</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Origin</field>
            <operation>equals</operation>
            <value>Web-XR</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Back from Internal,Customer Response,In Progress</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>XR_Send_To_Q_Flag</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>Case.SLA_Due_Date__c</offsetFromField>
            <timeLength>0</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>XR SLA Due in Past</fullName>
        <active>true</active>
        <formula>RecordType.Name = &quot;Residential&quot; &amp;&amp; TEXT(Origin) = &quot;Web-XR&quot; &amp;&amp; TEXT(Status) = &quot;Awaiting Internal&quot;</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>XR_Update_Status</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>Case.SLA_Due_Date__c</offsetFromField>
            <timeLength>0</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>XR Status Closed</fullName>
        <actions>
            <name>XR_Set_Customer_Action_Date_NULL</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>XR_Set_SLA_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Residential</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Origin</field>
            <operation>equals</operation>
            <value>Web-XR</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Closed</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>XR Status Closed by Agent</fullName>
        <actions>
            <name>XR_Set_Close_Reason_agent</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>XR_Set_Last_Message_Closed</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>XR_OB_Closed</name>
            <type>OutboundMessage</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Residential</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Origin</field>
            <operation>equals</operation>
            <value>Web-XR</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Closed</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Closed_Reason__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>XR Status Notification</fullName>
        <actions>
            <name>XR_Set_Last_Message_1</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>XR_updated_event</name>
            <type>OutboundMessage</type>
        </actions>
        <active>true</active>
        <description>Notify the customer when the case status changes to Awaiting Internal or Escalated</description>
        <formula>RecordType.Name = &apos;Residential&apos; &amp;&amp;  ISPICKVAL(Origin, &apos;Web-XR&apos;) &amp;&amp;   ISCHANGED( Status ) &amp;&amp; (    ISPICKVAL(Status, &apos;Awaiting Internal&apos;) ||    ISPICKVAL(Status, &apos;Escalated&apos;)  )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>XR followup</fullName>
        <actions>
            <name>XR_Set_Customer_Action_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>XR_Set_Last_Message_1</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>XR_updated_event</name>
            <type>OutboundMessage</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Residential</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Origin</field>
            <operation>equals</operation>
            <value>Web-XR</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Needs Info,Awaiting Confirmation,Follow-up</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>XR_Set_Last_Message_3</name>
                <type>FieldUpdate</type>
            </actions>
            <actions>
                <name>XR_Update_Followup_Count</name>
                <type>FieldUpdate</type>
            </actions>
            <actions>
                <name>XR_OB_Reminder_2</name>
                <type>OutboundMessage</type>
            </actions>
            <offsetFromField>Case.Customer_Action_Date__c</offsetFromField>
            <timeLength>24</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>XR_Set_Last_Message_2</name>
                <type>FieldUpdate</type>
            </actions>
            <actions>
                <name>XR_Update_Followup_Count</name>
                <type>FieldUpdate</type>
            </actions>
            <actions>
                <name>XR_Update_Status_Followup</name>
                <type>FieldUpdate</type>
            </actions>
            <actions>
                <name>XR_OB_Reminder_1</name>
                <type>OutboundMessage</type>
            </actions>
            <offsetFromField>Case.Customer_Action_Date__c</offsetFromField>
            <timeLength>12</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>XR_Set_Close_Reason</name>
                <type>FieldUpdate</type>
            </actions>
            <actions>
                <name>XR_Set_Last_Message_4</name>
                <type>FieldUpdate</type>
            </actions>
            <actions>
                <name>XR_Set_Status_Closed</name>
                <type>FieldUpdate</type>
            </actions>
            <actions>
                <name>XR_Update_Followup_Count</name>
                <type>FieldUpdate</type>
            </actions>
            <actions>
                <name>XR_OB_Reminder_3</name>
                <type>OutboundMessage</type>
            </actions>
            <offsetFromField>Case.Customer_Action_Date__c</offsetFromField>
            <timeLength>36</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
</Workflow>
