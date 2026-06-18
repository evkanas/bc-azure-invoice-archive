codeunit 70100 "EVK Invoice Email Archive"
{
    Permissions =
    TableData "Sales Invoice Header" = m,
    TableData "Sales Cr.Memo Header" = m;

    procedure DownloadInvoice(fileName: Text)
    begin
        SalesReceivablesSetup.Get();
        ContainerName := SalesReceivablesSetup."EVK Container Name Invoice";
        StorageAccount := SalesReceivablesSetup."EVK Storage Account";
        SharedKey := SalesReceivablesSetup."EVK Shared Key";
        AuthorizationStorageServiceAuthorization := StorageServiceAuthorization.CreateSharedKey(SharedKey);
        ABSBlobClient.Initialize(StorageAccount, ContainerName, AuthorizationStorageServiceAuthorization);
        ABSBlobClient.ListBlobs(ABSContainerContent);
        ABSContainerContent.FindFirst();
        ABSOperationResponse := ABSBlobClient.GetBlobAsFile(fileName);
    end;

    procedure SendInvoiceToArchive(var SalesInvoiceHeader: record "Sales Invoice Header")
    var
        SalesInvoiceHeaderCopy: record "Sales Invoice Header";
        SalesInvoiceHeaderModify: record "Sales Invoice Header";
    begin
        SalesReceivablesSetup.Get();
        if SalesReceivablesSetup."EVK Use Invoice Archiving" then begin
            clear(SalesInvoiceHeaderCopy);
            SalesInvoiceHeaderCopy.Reset();
            SalesInvoiceHeaderCopy.Copy(SalesInvoiceHeader);
            if SalesInvoiceHeaderCopy.FindSet() then
                repeat
                    RecRecordRef.GetTable(SalesInvoiceHeaderCopy);
                    RecRecordRef.SetRecFilter();
                    clear(TempBlob);
                    clear(InStream);
                    ReportSelections.GetPdfReportForCust(TempBlob, ReportSelections.Usage::"S.Invoice", RecRecordRef, SalesInvoiceHeaderCopy."Sell-to Customer No.");
                    TempBlob.CreateInStream(InStream);
                    ContainerName := SalesReceivablesSetup."EVK Container Name Invoice";
                    StorageAccount := SalesReceivablesSetup."EVK Storage Account";
                    SharedKey := SalesReceivablesSetup."EVK Shared Key";
                    AuthorizationStorageServiceAuthorization := StorageServiceAuthorization.CreateSharedKey(SharedKey);
                    ABSBlobClient.Initialize(StorageAccount, ContainerName, AuthorizationStorageServiceAuthorization);
                    CustomerNo := SalesInvoiceHeaderCopy."Sell-to Customer No.";
                    DocumentNo := SalesInvoiceHeaderCopy."No.";
                    EmailAddr := SalesInvoiceHeaderCopy."Sell-to E-Mail";
                    if EmailAddr = '' then begin
                        clear(Customer);
                        Customer.Reset();
                        Customer.Get(CustomerNo);
                        EmailAddr := Customer."E-Mail";
                    end;
                    if SalesInvoiceHeaderCopy."External Document No." <> '' then DocumentNo := SalesInvoiceHeaderCopy."External Document No.";
                    Filename := CustomerNo + '_' + DocumentNo + '_email_' + EmailAddr + '.pdf';
                    ABSBlobClient.PutBlobBlockBlobStream(Filename, InStream);
                    if ABSOperationResponse.IsSuccessful() then begin
                        SalesInvoiceHeaderModify.Get(SalesInvoiceHeaderCopy."No.");
                        SalesInvoiceHeaderModify."EVK Archyved Name" := Filename;
                        SalesInvoiceHeaderModify.Modify(false);
                        Commit();
                    end
                    else
                        Message(OperationErr, ABSOperationResponse.GetError());
                until SalesInvoiceHeaderCopy.Next() = 0;
        end;
    end;

    procedure SendCreditInvoiceToArchive(var SalesCrMemoHeader: Record "Sales Cr.Memo Header")
    var
        SalesCrMemoHeaderCopy: record "Sales Cr.Memo Header";
        SalesCrMemoHeaderModify: record "Sales Cr.Memo Header";
    begin
        SalesReceivablesSetup.Get();
        if SalesReceivablesSetup."EVK Use Invoice Archiving" then begin
            Clear(SalesCrMemoHeaderCopy);
            SalesCrMemoHeaderCopy.Reset();
            SalesCrMemoHeaderCopy.Copy(SalesCrMemoHeader);
            if SalesCrMemoHeaderCopy.FindSet() then
                repeat
                    RecRecordRef.GetTable(SalesCrMemoHeaderCopy);
                    RecRecordRef.SetRecFilter();
                    Clear(TempBlob);
                    Clear(InStream);
                    ReportSelections.GetPdfReportForCust(TempBlob, ReportSelections.Usage::"S.Cr.Memo", RecRecordRef, SalesCrMemoHeaderCopy."Sell-to Customer No.");
                    TempBlob.CreateInStream(InStream);
                    ContainerName := SalesReceivablesSetup."EVK Container Name Invoice";
                    StorageAccount := SalesReceivablesSetup."EVK Storage Account";
                    SharedKey := SalesReceivablesSetup."EVK Shared Key";
                    AuthorizationStorageServiceAuthorization := StorageServiceAuthorization.CreateSharedKey(SharedKey);
                    ABSBlobClient.Initialize(StorageAccount, ContainerName, AuthorizationStorageServiceAuthorization);
                    CustomerNo := SalesCrMemoHeaderCopy."Sell-to Customer No.";
                    DocumentNo := SalesCrMemoHeaderCopy."No.";
                    EmailAddr := SalesCrMemoHeaderCopy."Sell-to E-Mail";
                    if EmailAddr = '' then begin
                        Clear(Customer);
                        Customer.Reset();
                        Customer.Get(CustomerNo);
                        EmailAddr := Customer."E-Mail";
                    end;
                    if SalesCrMemoHeaderCopy."External Document No." <> '' then DocumentNo := SalesCrMemoHeaderCopy."External Document No.";
                    Filename := CustomerNo + '_' + DocumentNo + '_email_' + EmailAddr + '.pdf';
                    ABSBlobClient.PutBlobBlockBlobStream(Filename, InStream);
                    if ABSOperationResponse.IsSuccessful() then begin
                        SalesCrMemoHeaderModify.get(SalesCrMemoHeaderCopy."No.");
                        SalesCrMemoHeaderModify."EVK Archyved Name" := Filename;
                        SalesCrMemoHeaderModify.Modify(false);
                        Commit();
                    end
                    else
                        Message(OperationErr, ABSOperationResponse.GetError());
                until SalesCrMemoHeaderCopy.Next() = 0;
        end;
    end;

    procedure SendEmailInvoice(var
                                   SalesInvoiceHeaderFirst: record "Sales Invoice Header";
                                   ShowDialog: Boolean)
    var
        DocumentSendingProfile: Record "Document Sending Profile";
        DummyReportSelections: Record "Report Selections";
        SalesInvoiceHeader: record "Sales Invoice Header";
    begin
        if SalesInvoiceHeaderFirst.GetFilter("Posting Date") = '' then Error(PostingDateErr);
        if SalesInvoiceHeaderFirst.IsEmpty then Error(NotFoundErr);
        clear(SalesInvoiceHeader);
        SalesInvoiceHeader.reset();
        SalesInvoiceHeader.SetCurrentKey("Posting Date");
        SalesInvoiceHeader.CopyFilters(SalesInvoiceHeaderFirst);
        if SalesInvoiceHeader.FindSet() then
            repeat
                DocumentSendingProfile.TrySendToEMail(DummyReportSelections.Usage::EVKMASSSHIPPINIGINVOICES.AsInteger(), SalesInvoiceHeader, SalesInvoiceHeader.FIELDNO("No."), DocTxt, SalesInvoiceHeader.FIELDNO("Bill-to Customer No."), ShowDialog);
            until SalesInvoiceHeader.Next() = 0;
        Message(DoneLbl);
    end;

    procedure SendEmailCredit(var SalesCrMemoHeaderFirst: record "Sales Cr.Memo Header"; ShowDialog: Boolean)
    var
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        DocumentSendingProfile: Record "Document Sending Profile";
        DummyReportSelections: Record "Report Selections";
    begin
        if SalesCrMemoHeaderFirst.GetFilter("Posting Date") = '' then error(PostingDateErr);
        if SalesCrMemoHeaderFirst.IsEmpty then error(NotFoundErr);

        SalesCrMemoHeader.reset();
        SalesCrMemoHeader.SetCurrentKey("Posting Date");
        SalesCrMemoHeader.CopyFilters(SalesCrMemoHeaderFirst);

        if SalesCrMemoHeader.FindSet() then
            repeat
                DocumentSendingProfile.TrySendToEMail(DummyReportSelections.Usage::EVKMASSSHIPPINIGCREDIT.AsInteger(), SalesCrMemoHeader, SalesCrMemoHeader.FIELDNO("No."), DocTxt, SalesCrMemoHeader.FIELDNO("Bill-to Customer No."), ShowDialog);
                commit();

            until SalesCrMemoHeader.Next() = 0;

        Message(DoneLbl);
    end;

    [EventSubscriber(ObjectType::Codeunit, 260, 'OnAfterEmailSentSuccesfully', '', false, false)]
    local procedure C260_OnAfterEmailSentSuccesfully(var TempEmailItem: Record "Email Item" temporary; PostedDocNo: Code[20]; ReportUsage: Integer)
    var
        SalesInvoiceHeader: record "Sales Invoice Header";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        DummyReportSelections: Record "Report Selections";
    begin
        SalesReceivablesSetup.Get();
        if SalesReceivablesSetup."EVK Use Invoice Archiving" then
            case ReportUsage of
                DummyReportSelections.Usage::EVKMASSSHIPPINIGINVOICES.AsInteger():
                    begin
                        clear(SalesInvoiceHeader);
                        SalesInvoiceHeader.Reset();
                        SalesInvoiceHeader.SetRange("No.", PostedDocNo);
                        if SalesInvoiceHeader.Findfirst() then
                            SendInvoiceToArchive(SalesInvoiceHeader);
                    end;
                DummyReportSelections.Usage::EVKMASSSHIPPINIGCREDIT.AsInteger():
                    begin
                        clear(SalesCrMemoHeader);
                        SalesCrMemoHeader.Reset();
                        SalesCrMemoHeader.SetRange("No.", PostedDocNo);
                        if SalesCrMemoHeader.Findfirst() then
                            SendCreditInvoiceToArchive(SalesCrMemoHeader);
                    end;
                DummyReportSelections.Usage::"S.Invoice".AsInteger():
                    begin
                        clear(SalesInvoiceHeader);
                        SalesInvoiceHeader.Reset();
                        SalesInvoiceHeader.SetRange("No.", PostedDocNo);
                        if SalesInvoiceHeader.Findfirst() then
                            SendInvoiceToArchive(SalesInvoiceHeader);
                    end;
                DummyReportSelections.Usage::"S.Cr.Memo".AsInteger():
                    begin
                        clear(SalesCrMemoHeader);
                        SalesCrMemoHeader.Reset();
                        SalesCrMemoHeader.SetRange("No.", PostedDocNo);
                        if SalesCrMemoHeader.Findfirst() then
                            SendCreditInvoiceToArchive(SalesCrMemoHeader);
                    end;
            end;
    end;

    procedure GetBCCEmail(var BCC_Email: Text)
    var
        EmailAccountRec: Record "Email Account";
        EmailAccountAccounts: Record "Email Account";
        EmailScenarios: Codeunit "Email Scenario";
        EmailAccount: Codeunit "Email Account";
        DefaultEmail: Text;
    begin
        DefaultEmail := '';
        BCC_Email := '';
        Clear(EmailScenarios);
        Clear(EmailAccountRec);
        EmailAccountRec.Reset();

        EmailScenarios.GetEmailAccount(Enum::"Email Scenario"::Default, EmailAccountRec);
        EmailAccount.GetAllAccounts(true, EmailAccountAccounts);
        if EmailAccountAccounts.Get(EmailAccountRec."Account Id", EmailAccountRec.Connector) then
            DefaultEmail := EmailAccountAccounts."Email Address";

        clear(EmailScenarios);
        CLEAR(EmailAccountRec);
        EmailAccountRec.Reset();
        EmailScenarios.GetEmailAccount(Enum::"Email Scenario"::EVKSendingInvoiceBCCLetters, EmailAccountRec);
        EmailAccount.GetAllAccounts(true, EmailAccountAccounts);

        if EmailAccountAccounts.Get(EmailAccountRec."Account Id", EmailAccountRec.Connector) then
            BCC_Email := EmailAccountAccounts."Email Address";

        if BCC_Email = DefaultEmail then BCC_Email := '';
    end;



    [EventSubscriber(ObjectType::Codeunit, 8891, 'OnAfterFromReportSelectionUsage', '', false, false)]
    local procedure OnAfterFromReportSelectionUsag(ReportSelectionUsage: Enum "Report Selection Usage"; var EmailScenario: Enum "Email Scenario")
    begin
        if (ReportSelectionUsage = ReportSelectionUsage::EVKMASSSHIPPINIGINVOICES) or (ReportSelectionUsage = ReportSelectionUsage::EVKMASSSHIPPINIGCREDIT) THEN
            EmailScenario := EmailScenario::EVKMASSSHIPPINIGINVOICES;
    end;

    [EventSubscriber(ObjectType::Codeunit, 260, 'OnBeforeSendEmail', '', false, false)]
    local procedure OnBeforeSendEmail(var TempEmailItem: Record "Email Item" temporary; var IsFromPostedDoc: Boolean; var PostedDocNo: Code[20]; var HideDialog: Boolean; var ReportUsage: Integer; var EmailSentSuccesfully: Boolean; var IsHandled: Boolean; EmailDocName: Text[250]; SenderUserID: Code[50]; EmailScenario: Enum "Email Scenario")
    var
        ReportSelectionUsage: Enum "Report Selection Usage";
        BCC_Email: Text;
    begin

        if (Enum::"Report Selection Usage".FromInteger(ReportUsage) = ReportSelectionUsage::EVKMASSSHIPPINIGINVOICES) or
        (Enum::"Report Selection Usage".FromInteger(ReportUsage) = ReportSelectionUsage::EVKMASSSHIPPINIGCREDIT)
        then begin
            BCC_Email := '';
            GetBCCEmail(BCC_Email);
            if BCC_Email <> '' then
                TempEmailItem."Send BCC" := CopyStr(BCC_Email, 1, MaxStrLen(TempEmailItem."Send BCC"));
        end;
    end;

    var
        SalesReceivablesSetup: record "Sales & Receivables Setup";
        Customer: Record Customer;
        ReportSelections: Record "Report Selections";
        ABSContainerContent: Record "ABS Container Content";
        TempBlob: codeunit "Temp Blob";
        ABSBlobClient: codeunit "ABS Blob Client";
        ABSOperationResponse: codeunit "ABS Operation Response";
        StorageServiceAuthorization: codeunit "Storage Service Authorization";
        RecRecordRef: RecordRef;
        AuthorizationStorageServiceAuthorization: interface "Storage Service Authorization";
        InStream: InStream;
        ContainerName: text;
        StorageAccount: text;
        SharedKey: text;
        EmailAddr: text;
        Filename: text[300];
        DocumentNo: Code[35];
        CustomerNo: Code[20];
        DocTxt: Label 'Invoice', Comment = 'lt-LT="Sąskaita"';
        PostingDateErr: Label 'Invoice posting date is required!', Comment = 'lt-LT="Sąskaitos registravimo data yra privaloma!"';
        NotFoundErr: Label 'There is nothing to send!', Comment = 'lt-LT="Nėra ką siųsti!"';
        DoneLbl: Label 'Done', Comment = 'lt-LT="Atlikta"';
        OperationErr: Label 'Error %1', Comment = 'lt-LT="Klaida %1"';

}