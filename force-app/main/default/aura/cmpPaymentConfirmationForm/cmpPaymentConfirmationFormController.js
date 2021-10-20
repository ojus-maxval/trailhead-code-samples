({
	doInit : function(component, event, helper) {
        //alert(component.get("v.recentListview"));
        helper.doInitHelper(component, event, helper);
        //var today = $A.localizationService.formatDate(new Date(), "YYYY-MM-DD");
        //component.set('v.PaymentDate', today);
	},
    gotoURL : function(component, event, helper) {
        window.location = component.get("v.recentListview");
        //helper.gotoURL(component);
    },
    calcExchange : function(component, event, helper) {
        component.set("v.data.exgRate",component.get("v.data.AmtPaid")/component.get("v.data.AmtForSelected"));
         /*MARS-749 Attach Payment Confirmation - Exchange Rate value should be shown based on Payment Currency
        Modified by Saranyaa*/
        component.set("v.data.pcMemo","Bank Rate: "+ (component.get("v.data.AmtPaid")/component.get("v.data.AmtForSelected")).toFixed(6));
    }, 
    payTypeChange : function(component, event, helper) {
        var selectedValueKey = event.getSource().get("v.value");
        if(selectedValueKey !='')
        {
            if(selectedValueKey =='Wire Transfer')
            {    
                component.set("v.isBA",true);
                component.set("v.isCCA",false);
            }
            if(selectedValueKey =='Credit Card')
            {
                component.set("v.isBA",false);
                component.set("v.isCCA",true);
            }
        }
        else
        {
            component.set("v.isBA",false);
            component.set("v.isCCA",false);
        }
        component.set("v.BankAccount","");
        component.set("v.CreditCardAccount","");
	},
    optionChange : function(component, event, helper) {
        var selectedValueKey = event.getSource().get("v.value");
        if(component.get("v.isBA"))
        {
            
            component.set("v.WireBankFee",false);
            component.set("v.isCCA",false);
            component.set("v.CreditCardAccount","");
        }
        if(component.get("v.isCCA"))
        {
            component.set("v.isBA",false);
            component.set("v.BankAccount","");
        }
	},
    saveChange : function(component, event, helper) {
        var err = "";
        if(component.get("v.data.Name") == "")
        {
            err = 'Please add Ref No.';
        }
        else if(component.get("v.data.payCurrency") == "")
        {
            err = 'Please select Payment Currency';
        }
        else if(component.get("v.data.AmtPaid") == 0)
        {
            err = 'Please add Total Official Fee Paid';
        }
        else if(component.get("v.data.payType") == "")
        {
            err = 'Please select Payment Type';
        }
        else if(component.get("v.isBA") && component.get("v.data.BAcc") == "")
        {
            err = 'Please select Bank Account';
        }
        else if(component.get("v.isCCA") && component.get("v.data.CCAcc") == "")
        {
            err = 'Please select Credit Card Account';
        }
        else if(component.get("v.data.pdate") == null)
        {
            err = 'Please provide Payment Date';
        }
        if(err != '')
        {
        	component.set("v.message",err);
        }
        else
        {
            component.set("v.message","");
            helper.savePaymentHelper(component, event, helper);
        }
    }
})