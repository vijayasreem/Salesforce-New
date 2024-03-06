
trigger LoanOfferAcceptanceTrigger on Loan_Offer__c (after update) {
    // Check if the loan offer has been accepted
    List<Loan_Offer__c> acceptedOffers = new List<Loan_Offer__c>();
    for (Loan_Offer__c offer : Trigger.new) {
        if (offer.Accepted__c && !Trigger.oldMap.get(offer.Id).Accepted__c) {
            acceptedOffers.add(offer);
        }
    }
    
    if (!acceptedOffers.isEmpty()) {
        // Update loan status and send confirmation
        List<Loan__c> loansToUpdate = new List<Loan__c>();
        List<Messaging.SingleEmailMessage> emailsToSend = new List<Messaging.SingleEmailMessage>();
        
        for (Loan_Offer__c acceptedOffer : acceptedOffers) {
            Loan__c loan = new Loan__c(Id = acceptedOffer.Loan__c);
            
            // Update loan status to Accepted
            loan.Status__c = 'Accepted';
            loansToUpdate.add(loan);

            // Send confirmation email
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setToAddresses(new List<String>{ acceptedOffer.Applicant__r.Email });
            email.setSubject('Loan Offer Accepted');
            email.setPlainTextBody('Dear ' + acceptedOffer.Applicant__r.Name + ',\n\n' +
                'We are pleased to inform you that your loan offer has been accepted.\n\n' +
                'Loan Details:\n' +
                'Loan Amount: $' + String.valueOf(acceptedOffer.Loan_Amount__c) + '\n' +
                'Interest Rate: ' + String.valueOf(acceptedOffer.Interest_Rate__c) + '%\n' +
                'Repayment Period: ' + String.valueOf(acceptedOffer.Repayment_Period__c) + ' months\n\n' +
                'Please let us know if you have any questions or require further assistance.\n\n' +
                'Best regards,\n' +
                'Your Bank');
            emailsToSend.add(email);
        }
        
        // Update loans and send emails
        if (!loansToUpdate.isEmpty()) {
            update loansToUpdate;
        }
        if (!emailsToSend.isEmpty()) {
            Messaging.sendEmail(emailsToSend);
        }
    }
}
