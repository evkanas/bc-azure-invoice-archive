pageextension 70101 "EVK Posted Sales Credit Memos" extends "Posted Sales Credit Memos"
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
        addafter(Send)
        {

            action(EVKICSendingEmails)
            {
                Caption = 'Send Credit Invoice To Customer', Comment = 'lt-LT="Siųsti kredito sąskaitą klientui",';
                ToolTip = 'Specifies which customer gets invoice pdf by email.', Comment = 'lt-LT="Nurodo, kuris klientas gauna sąskaitos PDF el. paštu."';
                ApplicationArea = Basic, Suite;
                Image = Email;
                Promoted = true;
                PromotedCategory = Category7;
                trigger OnAction()
                begin
                    clear(EVKISSentEmailSalesCrMemoReport);
                    EVKISSentEmailSalesCrMemoReport.SetTableView(Rec);
                    EVKISSentEmailSalesCrMemoReport.Run();
                end;
            }

            action("EVK Download Invoice From Archive")
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
                    EVKInvoiceEmailArchive.downloadInvoice(Rec."EVK Archyved Name");
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
        EVKISSentEmailSalesCrMemoReport: Report EVKISSentEmailSalesCrMemo;
        EVKInvoiceEmailArchive: Codeunit "EVK Invoice Email Archive";
        visibleArcive: Boolean;
}