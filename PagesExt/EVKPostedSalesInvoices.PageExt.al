pageextension 70100 "EVK Posted Sales Invoices" extends "Posted Sales Invoices"
{
    layout
    {
        addafter("Bill-to Name")
        {
            field(EVKICArchyveAddress; Rec."EVK Archyved Name")
            {
                ApplicationArea = Basic, Suite;
            }
        }
    }
    actions
    {
        addafter(Email)
        {

            action(EVKICSendingEmails)
            {
                Caption = 'Send Invoice To Customer', Comment = 'lt-LT="Siųsti sąskaitą klientui",';
                ToolTip = 'Specifies which customer gets invoice pdf by email.', Comment = 'lt-LT="Nurodo, kuris klientas gauna sąskaitos PDF el. paštu."';
                ApplicationArea = Basic, Suite;
                Image = Email;
                Promoted = true;
                PromotedCategory = Category7;
                trigger OnAction()
                begin
                    clear(EVKSentEmailSalesInvHeaderReport);
                    EVKSentEmailSalesInvHeaderReport.SetTableView(Rec);
                    EVKSentEmailSalesInvHeaderReport.Run();
                end;
            }
            action("EVK Download Invoice from Archive")
            {
                Caption = 'Download Invoice from Archive', Comment = 'lt-LT="Atsisiųsti sąskaitą iš archyvo"';
                ToolTip = 'Downloads the invoice file from Azure Blob Storage archive.', Comment = 'lt-LT="Atsisiunčia sąskaitos failą iš Azure Blob Storage archyvo."';
                ApplicationArea = Basic, Suite;
                Image = Invoice;
                Promoted = true;
                PromotedCategory = Category7;
                Visible = visibleArcive;
                trigger OnAction()
                begin
                    EVKInvoiceEmailArchive.DownloadInvoice(Rec."EVK Archyved Name");
                end;
            }
        }
    }
    trigger OnOpenPage()
    begin
        visibleArcive := false;
        SalesReceivablesSetup.Get();
        if SalesReceivablesSetup."EVK Use Invoice Archiving" then visibleArcive := true;
    end;

    var
        SalesReceivablesSetup: record "Sales & Receivables Setup";
        EVKSentEmailSalesInvHeaderReport: Report "EVK SentEmailSalesInvHeader";
        EVKInvoiceEmailArchive: Codeunit "EVK Invoice Email Archive";
        visibleArcive: Boolean;
}