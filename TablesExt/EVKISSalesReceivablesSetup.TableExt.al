tableextension 70102 "EVK SalesReceivablesSetup" extends "Sales & Receivables Setup"
{
    fields
    {
        field(70100; "EVK Container Name Invoice"; text[100])
        {
            Caption = 'Invoice Container', Comment = 'lt-LT="Sąskaitos konteineris"';
        }
        field(70101; "EVK Storage Account"; text[100])
        {
            Caption = 'Azure Storage Account', Comment = 'lt-LT="Azure saugyklos paskyra"';
        }
        field(70102; "EVK Shared Key"; text[100])
        {
            Caption = 'Azure Shared Key', Comment = 'lt-LT="Azure bendras raktas"';
        }
        field(70103; "EVK Use Invoice Archiving"; Boolean)
        {
            Caption = 'Use Invoice archiving', Comment = 'lt-LT="Naudoti sąskaitų archyvavimą"';
        }
    }
}