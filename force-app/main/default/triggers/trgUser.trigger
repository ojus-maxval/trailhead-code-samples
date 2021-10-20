trigger trgUser on User (after insert,after update) 
{
    if(trigger.isInsert)
    {
        string MgrGroupID = '';
        List<Group> grps = [Select id,Name From Group Where Name = 'ADU Managers' Limit 1];
        if(grps.size()>0)
        {
            MgrGroupID = grps[0].id;        
        }
        else
        {
            Group grp = new Group(); 
            grp.Name = 'ADU Managers'; 
            grp.Type = 'Regular'; 
            insert grp;
            MgrGroupID = grp.id;
        }
        
        list<groupMember> groupMbrToInsert = new list<groupMember>();
        for(User u : [select id,Name,Is_ADU_Manager__c,profile.name from User WHERE id IN: trigger.new AND Is_ADU_Manager__c=true])
        {
            if((u.profile.name == 'ADU' || u.profile.name == 'System Administrator') && u.Is_ADU_Manager__c)
            {
                GroupMember GrpMem = new GroupMember();
                GrpMem.GroupId = MgrGroupID;
                GrpMem.UserOrGroupId = u.Id;
                groupMbrToInsert.add(GrpMem);
            }
        }
        if(groupMbrToInsert.size()>0)
            insert groupMbrToInsert;
    }
    if(trigger.isUpdate)
    {
        string MgrGroupID = '';
        List<Group> grps = [Select id,Name From Group Where Name = 'ADU Managers' Limit 1];
        if(grps.size()>0)
        {
            MgrGroupID = grps[0].id;        
        }
        else
        {
            Group grp = new Group(); 
            grp.Name = 'ADU Managers'; 
            grp.Type = 'Regular'; 
            insert grp;
            MgrGroupID = grp.id;
        }
        List<string> ursToRemoveFromGroup = NEW List<string>();
        list<groupMember> groupMbrToInsert = new list<groupMember>();
        for(User u : [select id,Name,Is_ADU_Manager__c,profile.name from User WHERE id IN: trigger.new])
        {
            User oldUser = Trigger.oldMap.get(u.Id);
            if((u.profile.name == 'ADU' || u.profile.name == 'System Administrator') && oldUser.Is_ADU_Manager__c == false && u.Is_ADU_Manager__c == true)
            {
                GroupMember GrpMem = new GroupMember();
                GrpMem.GroupId = MgrGroupID;
                GrpMem.UserOrGroupId = u.Id;
                groupMbrToInsert.add(GrpMem);
            }
            if((u.profile.name == 'ADU' || u.profile.name == 'System Administrator') && oldUser.Is_ADU_Manager__c == true && u.Is_ADU_Manager__c == false)
            {
                ursToRemoveFromGroup.add(u.id);
            }
        }
        if(groupMbrToInsert.size()>0)
            insert groupMbrToInsert;
        if(ursToRemoveFromGroup.size()>0)
        {
            List<groupMember> groupMebersToDelete = [Select id from groupMember where GroupId =: MgrGroupID AND UserOrGroupId IN: ursToRemoveFromGroup];
            if(groupMebersToDelete.size()>0)
                delete groupMebersToDelete;
        }
    }
}