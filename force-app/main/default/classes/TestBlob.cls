public class TestBlob {
    public TestBlob(){
        Boolean isValidReceipt = False;
        //Read data from a pdf file uploaded as Content Document
        List<ContentVersion> contentVersionList = [SELECT Title,VersionData FROM ContentVersion WHERE ContentDocumentId = '0695f000002PKhIAAW'];
        //Convert Blob to String
		String dataAsString = EncodingUtil.base64Decode(EncodingUtil.base64Encode(contentVersionList[0].VersionData)).toString();
        //Get metadata from Filename
        //String fileName = contentVersionList[0].Title;
        String fileName = 'IL_41AS-206449-IL_6th';
        String[] metadata = filename.split('_'); //Filename -> CountryCode_ApplicationNo_Term
system.debug(fileName);
        if(metadata.size()>0){
            system.debug(dataAsString);

            //Validations:
            //1.Check if the Application No is available in the receipt
            String appNo = EncodingUtil.base64Encode(Blob.valueOf(metadata[1]));
            if(dataAsString.contains(appNo))
            {
                //2.Check if the Term is correct
                if(dataAsString.contains(metadata[2])){
                    isValidReceipt = True;
                }
                else{
                            system.debug('Term incorrect');
                }
            }else{
                    system.debug('Application no not available');
        }
        }
        system.debug('IsValid? '+isValidReceipt);

    }
}