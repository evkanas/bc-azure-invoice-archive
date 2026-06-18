pageextension 70102 "EVK Sales & Receivables Setup" extends "Sales & Receivables Setup"
{
    layout
    {
        addafter(Archiving)
        {
            group(Azure)
            {
                field(EVKISUSEINVOICE; Rec."EVK Use Invoice Archiving")
                {
                    ToolTip = 'Specifies Invoice archiving in Azure.', Comment = 'lt-LT="Nurodo sąskaitų archyvavimą Azure"';
                    ApplicationArea = Basic, Suite;
                }
                field(EVKISSharedKey; Rec."EVK Shared Key")
                {
                    ToolTip = 'Specifies shared key.', Comment = 'lt-LT="Nurodo Azure bendrą raktą"';
                    ApplicationArea = Basic, Suite;
                }
                field(EVKISStorageAccount; Rec."EVK Storage Account")
                {
                    ToolTip = 'Specifies Azure storage account.', Comment = 'lt-LT="Nurodo Azure saugyklos paskyrą"';
                    ApplicationArea = Basic, Suite;
                }
                field(EVKISContainerNameInvoice; Rec."EVK Container Name Invoice")
                {
                    ToolTip = 'Specifies container name for invoice Storage.', Comment = 'lt-LT="Nurodo konteinerio pavadinimą sąskaitų saugojimui"';
                    ApplicationArea = Basic, Suite;
                }
            }
        }
    }
}