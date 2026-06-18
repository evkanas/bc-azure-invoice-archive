report 70101 "EVK SentEmailSalesInvHeader"
{
    ProcessingOnly = true;
    Caption = 'Registered invoice sending', Comment = 'lt-LT="Registruotas sąskaitos siuntimas"';
    UsageCategory = ReportsAndAnalysis;
    AdditionalSearchTerms = 'Registered invoice sending', Comment = 'lt-LT="Registruotas sąskaitos siuntimas"';
    ApplicationArea = All;

    dataset
    {
        dataitem("Sales Invoice Header"; "Sales Invoice Header")
        {
            DataItemTableView = SORTING("No.");
            RequestFilterFields = "No.", "Bill-to Customer No.", "Posting Date";
        }
    }
    requestpage
    {
        SaveValues = true;

        layout
        {
            area(content)
            {
                group(Options)
                {
                    Caption = 'Options', Comment = 'lt-LT="Parinktys"';

                    field(ShowEmailDialog; ShowDialog)
                    {
                        ApplicationArea = Suite;
                        Caption = 'Show Email Dialog', Comment = 'lt-LT="Rodyti el. pašto dialogą"';
                        ToolTip = 'Specifies if you want to hide or show email dialog.', Comment = 'lt-LT="Nurodo, ar norite slėpti, ar rodyti el. pašto dialogą."';
                    }
                    field(OnlyArchyvePadf; OnlyArchyve)
                    {
                        ApplicationArea = Suite;
                        Caption = 'Archive Invoice Without Email', Comment = 'lt-LT="Nusiųsti SF į arhyvą (nesiunčiant el. paštu)"';
                        ToolTip = 'Archives the invoice without sending it by email.', Comment = 'lt-LT="Nusiųsti SF į arhyvą (nesiunčiant el. paštu)."';
                        Visible = visibleArcive;
                    }
                }
            }
        }
    }
    trigger OnInitReport()
    begin
        visibleArcive := false;
        SalesReceivablesSetup.Get();
        if SalesReceivablesSetup."EVK Use Invoice Archiving" then visibleArcive := true;
    end;

    trigger OnPostReport()
    begin
        if (OnlyArchyve) and (SalesReceivablesSetup."EVK Use Invoice Archiving") then
            EVKInvoiceCU.SendInvoiceToArchive("Sales Invoice Header")
        else
            EVKInvoiceCU.SendEmailInvoice("Sales Invoice Header", ShowDialog);
    end;

    var
        SalesReceivablesSetup: record "Sales & Receivables Setup";
        EVKInvoiceCU: Codeunit "EVK Invoice Email Archive";
        ShowDialog: Boolean;
        OnlyArchyve: Boolean;
        visibleArcive: Boolean;
}