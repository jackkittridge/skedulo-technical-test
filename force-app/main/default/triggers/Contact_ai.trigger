trigger Contact_ai on Contact (after insert)
{
    List<Approval.ProcessSubmitRequest> requests = new List<Approval.ProcessSubmitRequest> ();
    for (Contact con : trigger.new) 
    {
        if (null != con.AccountId)
        {
            Approval.ProcessSubmitRequest psr = new Approval.ProcessSubmitRequest();
            psr.setComments('Contact submitted for approval');
            psr.setObjectId(con.Id);
            psr.setProcessDefinitionNameOrId(ApprovalConstants.APPROVE_CONTACT);
            
            requests.add(psr);
        }
    }

    if (!requests.isEmpty())
    {
        try 
        {
            Approval.process(requests, true);
        }
        catch (System.DmlException dml_exc)
        {
            // Should probably do something more valuable with this
            // perhaps send an email to the designated approver
            System.debug('Failed to submit contacts for approval: ' + dml_exc.getCause());
        }
    }
}