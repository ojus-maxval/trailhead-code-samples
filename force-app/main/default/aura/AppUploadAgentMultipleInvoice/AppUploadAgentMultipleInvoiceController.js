({
    onload : function(component, event, helper) {
        
		if(component.get('v.listofids') == '[]')
        {
            component.set("v.ErrorScreen",true);
           
        }
        else
        {
            var action = component.get('c.ValidationCheck');
            action.setParams({ 'listofids' : component.get('v.listofids') });
            action.setCallback
            (
                this,
                $A.getCallback
                (
                    function (response) 
                    {
                        var state = response.getState();
                        if (state === "SUCCESS") 
                        {
                            var result = response.getReturnValue();
                            //alert(result);
                            component.set('v.ErrorScreen', result.ValidationOnAgentStatus);
                             component.set('v.ListViewName', result.ListViewName);
                            component.set('v.ErrorText', '	This action is not allowed at this time.');
                           
                        } 
                        else if (state === "ERROR") 
                        {
                            var errors = response.getError();
                            alert(JSON.stringify(errors));
                            console.error(errors);
                        }
                    }
                )
            );
            $A.enqueueAction(action);
            
        }
	},
    handleFilesChange: function(component, event, helper) {
        
        var fileName = "No File Selected..";
        var fileCount=component.find("fileId").get("v.files").length;
        var files='';
        var uploadedFileList = event.getSource().get("v.files");
        var existingFileList = component.get("v.fileList");        
        var fileList = [];
        for (var i = 0; i < existingFileList.length; i++) {
            fileList.push(existingFileList[i]);
            if (fileCount > 0) {
                if(files == '')
                {
                    files=existingFileList[i].name;
                }
                else
                {
                    files=files+','+existingFileList[i].name;
                }
            }
            else
            {
                files=fileName;
            }
        }
        for (var i = 0; i < uploadedFileList.length; i++) {
            fileList.push(uploadedFileList[i]);
            //alert(uploadedFileList[i].name);
            if (fileCount > 0) {
                if(files == '')
                {
                    files=uploadedFileList[i].name;
                }
                else
                {
                    files=files+','+uploadedFileList[i].name;
                }
            }
            else
            {
                files=fileName;
            }
        } 
        component.set("v.fileList", fileList);    
       /* var FileList = [];
        *  if (fileCount > 0) {
            for (var i = 0; i < fileCount; i++) 
            {
                FileList.push(component.find("fileId").get("v.files")[i]);
            }
        }
        alert(FileList);*/
            
            
            
            
       /* alert(fileCount);
        var files='';
        if (fileCount > 0) {
            for (var i = 0; i < fileCount; i++) 
            {
                fileName = component.find("fileId").get("v.files")[i]["name"];
                if(files == '')
                {
                    files=fileName;
                }
                else
                {
                    files=files+','+fileName;
                }
               
            }
        }
       
        else
        {
            files=fileName;
        }*/
        component.set("v.fileName", files);
    },
     doCancel: function(component, event, helper) {
       
      // window.open('https://symphonymars.lightning.force.com/lightning/o/Order_Item__c/list?filterName=00B4W00000FAI98UAH','_self');
        /*     var navEvent = $A.get("e.force:navigateToList");
             navEvent.setParams({
                 "listViewId": component.get('v.ListViewName'),
                 "listViewName": null,
                 "scope": "Order_Item__c"
             });
             navEvent.fire();
        */
         window.history.back();
     },
    uploadFiles: function(component, event, helper) {
        if(component.find("fileId").get("v.files")==undefined)
        {
            helper.showMessage('Select files',false);
            return;
        }
        if (component.find("fileId").get("v.files").length > 0) {
            var s = component.get("v.FilesUploaded");
            var fileName = "";
            var fileType = "";
            var fileCount=component.find("fileId").get("v.files").length;
            component.set('v.FileCountAtt',fileCount);
           
            if (fileCount > 0) {
                for (var i = 0; i < component.get("v.fileList").length; i++) 
                {
                    //alert(i+'>>>>>>>>>>>Filess'+component.get("v.fileList").length)
                    //helper.uploadHelper(component, event,component.find("fileId").get("v.files")[i]);
                    helper.uploadHelper(component, event,component.get("v.fileList")[i]);
                    if(i==component.get("v.fileList").length-1)
                    {
                        
                        component.set("v.showLoadingSpinner", false);
                        alert('Successfully Uploaded..');
                       // window.open('https://symphonymars.lightning.force.com/lightning/o/Order_Item__c/list?filterName=00B4W00000FAI98UAH','_self');
                  		 window.history.back();
                    }
                }
                                    
         }
        } else {
            helper.showMessage("Please Select a Valid File",false);
        }
    }
});