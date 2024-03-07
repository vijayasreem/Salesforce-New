
trigger LoanDisbursementTrigger on Loan__c (after update) {
    public static void processLoanDisbursement(List<Loan__c> loans) {
        List<Loan__c> updatedLoans = new List<Loan__c>();
        
        for (Loan__c loan : loans) {
            if (loan.Status__c == 'Approved' && loan.Offer_Accepted__c) {
                // Disburse the loan amount
                loan.Disbursed_Date__c = Date.today();  // Set the disbursement date
                loan.Disbursed_Amount__c = loan.Approved_Amount__c;  // Set the disbursed amount
                
                // Determine the recipient based on the agreed arrangement
                if (loan.Recipient__c == 'Car Dealer') {
                    loan.Recipient_Account__c = loan.Car_Dealer_Account__c;
                } else {
                    loan.Recipient_Account__c = loan.Borrower_Account__c;
                }
                
                updatedLoans.add(loan);
            }
        }
        
        if (!updatedLoans.isEmpty()) {
            update updatedLoans;
            
            // Send confirmation of loan disbursement to the borrower
            LoanDisbursementHelper.sendConfirmationEmail(updatedLoans);
            
            // Communicate additional instructions or requirements to the borrower
            LoanDisbursementHelper.communicateInstructions(updatedLoans);
        }
    }
}

public class LoanDisbursementHelper {
    public static void sendConfirmationEmail(List<Loan__c> loans) {
        // Implementation to send confirmation email
    }
    
    public static void communicateInstructions(List<Loan__c> loans) {
        // Implementation to communicate instructions
    }
}
