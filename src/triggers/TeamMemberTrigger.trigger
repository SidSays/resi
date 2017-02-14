trigger TeamMemberTrigger on Team_Member__c (before insert, after update, before delete, after undelete) {
	TriggerSettings__c triggerSetting = TriggerSettings__c.getValues('TeamMemberTrigger');
	if(triggerSetting.isActive__c){
		if(trigger.isBefore){
			if(trigger.isInsert){
				TeamMemberTriggerController tmc=new TeamMemberTriggerController();
				tmc.updateAllteamMember(trigger.new,trigger.oldmap);
			}
			else if(trigger.isDelete){
				TeamMemberTriggerController tmc=new TeamMemberTriggerController();
				tmc.updateAllteamMember(trigger.new,trigger.oldmap);
			}
		}
		else {
			if(trigger.isUpdate){
				TeamMemberTriggerController tmc = new TeamMemberTriggerController();
				List<Team_Member__c> newTeamMember = new List<Team_Member__c>();
				for(Team_Member__c t: trigger.new){
					if (trigger.oldmap.get(t.id).User_name__c!=t.User_name__c){
						newTeamMember.add(t);
					}
					tmc.updateAllteamMember(newTeamMember,trigger.oldmap);
				}
			}
			else if(trigger.isUndelete){
				TeamMemberTriggerController tmc = new TeamMemberTriggerController();
				tmc.updateAllteamMember(trigger.new,trigger.oldmap);
			}
		}
	}
}