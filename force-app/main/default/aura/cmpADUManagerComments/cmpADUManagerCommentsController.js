({
	doInit : function(component, event, helper) {
        helper.doInitHelper(component, event, helper);
	},
    editCtrl : function(component, event, helper) {
		component.set("v.isOpen", true);
	},
    SaveRec: function(component, event, helper) {
        
        if( component.get("v.vNewComments") !== null && component.get("v.vNewComments") !== '')
        {
            helper.updateHelper(component, event, helper);
            component.set("v.isOpen", false);
            component.set("v.showErrorMsg", false);
        }
        else
        {
            component.set("v.showErrorMsg", true);
        }
    },
    closeModel: function(component, event, helper) {
        //console.log('Helper closeModel');
        component.set("v.vNewComments",'');
        // for Hide/Close Model,set the "isOpen" attribute to "Fasle"  
        component.set("v.isOpen", false);
        component.set("v.showErrorMsg", false);
    },
})