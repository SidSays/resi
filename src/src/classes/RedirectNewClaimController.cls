public class RedirectNewClaimController {

    ApexPages.StandardController controller;

    public RedirectNewClaimController(ApexPages.StandardController stdController) {
        controller = stdController;
    }

    public PageReference RedirectAffiliateClaimsUsers(){
        PageReference pageRef;
        Profile profile = [Select Name From Profile Where Id =: UserInfo.getProfileId()];
        if(profile.Name == 'Affiliate Claims User'){
            pageRef = new PageReference('/apex/ClaimEligibleSubmission');
        } else {
            pageRef = new PageReference('/setup/ui/recordtypeselect.jsp?ent=Case&retURL=%2F500%2Fo&save_new_url=' + Case.SObjectType.GetDescribe().GetKeyPrefix() + '/e&nooverride=1');//Label.CaseCustomRecordTypeSelect);
        }
        return pageRef;
    }
}