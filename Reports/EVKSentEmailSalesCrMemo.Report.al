report 70100 EVKISSentEmailSalesCrMemo
{
    ProcessingOnly = true;
    Caption = 'Invoice sending', Comment = 'lt-LT="Sąskaitos siuntimas"';
    dataset
    {
        dataitem("Sales Cr.Memo Header"; "Sales Cr.Memo Header")
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
                        Visible = true;
                    }
                }
            }
        }
    }

    trigger OnPostReport()
    begin
        if OnlyArchyve then
            EVKInvoiceCU.SendCreditInvoiceToArchive("Sales Cr.Memo Header")
        else
            EVKInvoiceCU.sendEmailCredit("Sales Cr.Memo Header", ShowDialog);
    end;

    var
        EVKInvoiceCU: Codeunit "EVK Invoice Email Archive";
        ShowDialog: Boolean;
        OnlyArchyve: Boolean;

}
