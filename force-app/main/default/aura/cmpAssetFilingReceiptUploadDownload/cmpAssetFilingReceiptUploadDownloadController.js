({
	doInit : function(component, event, helper) {
		helper.doInitHelper(component, event, helper);
	},
    handleUploadFinished: function (component, event, helper) {
        // Get the list of uploaded files
        var uploadedFiles = event.getParam("files");
        //alert("Files uploaded : " + uploadedFiles.length);
        //var uploadedFileId = '';
        // Get the file name
        //uploadedFiles.forEach(uploadedFileId=file.recordId);
        //alert(uploadedFiles[0].documentId);
        //uploadedFileId = uploadedFiles[0].documentId;
        helper.updateHelper(component, event, helper, uploadedFiles[0].documentId);
    },
    deleteFile : function(component, event, helper) {
        helper.deleteFileHelper(component, event, helper);
	},
})