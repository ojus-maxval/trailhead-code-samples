/* Copyright © 2021 MaxVal Group. All Rights Reserved.
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Sneha B, Dec 2021
 */
public class ScheduleBatchValidateWithPTO implements Schedulable
{
    public void execute(SchedulableContext sc)
    {
        batchValidateWithPTO ptovalidate =new batchValidateWithPTO();
        database.executeBatch(ptovalidate, 1);
    }
}