/* Copyright © 2021 MaxVal Group. All Rights Reserved.
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Sneha B, April 2021
 */
global class BillCreationStatusEntity {
    public class ErrorDetail
    {
        public string Code { get; set; }
        public string Description { get; set; }
    }

    public class BillCreationStatusRequest
    {
        public string ClientRequestHandle{get;set;}
        public integer Status { get; set; }
        public string RequestID { get; set; }
        public string BillNo { get; set; }
        public List<ErrorDetail> Error { get; set; }
        public List<ErrorDetail> Warning { get; set; }
    }

    global class BillCreationStatusResponse
    {
        public boolean Status{get;set;}
        public List<ErrorDetail> Error{get;set;} 
    }

    public class Error
    {
        public integer Status { get; set; }
        public List<ErrorDetail> ErrorDetails { get; set; }

        public Error()
        {
            this.ErrorDetails = new List<ErrorDetail>();
            this.Status = 0;
        }
    }
}