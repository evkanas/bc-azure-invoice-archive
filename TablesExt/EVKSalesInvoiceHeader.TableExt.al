tableextension 70101 "EVK SalesInvoiceHeader" extends "Sales Invoice Header"
{
    fields
    {
        field(70100; "EVK Archyved Name"; text[300])
        {
            Caption = 'Archived Invoice File Name', Comment = 'lt-LT="Archyvuotos sąskaitos failo pavadinimas"';
            ToolTip = 'Specifies the archived invoice file name stored in Azure Blob Storage.', Comment = 'lt-LT="Nurodo archyvuotos sąskaitos failo pavadinimą, saugomą Azure Blob Storage."';
        }
    }
}