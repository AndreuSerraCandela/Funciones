/// <summary>
/// Codeunit ControldeEventos (ID 50003).
/// </summary>
codeunit 50003 ControldeEventos
{
    Permissions = TableData 17 = rimd,
    tabledata 110 = rimd,
    tabledata 111 = rimd,
    tabledata 112 = rimd,
    tabledata 113 = rimd,
    tabledata 114 = rimd,
    tabledata 115 = rimd,
    tabledata 120 = rimd,
    tabledata 121 = rimd,
    tabledata 122 = rimd,
    tabledata 123 = rimd,
    tabledata 124 = rimd,
    tabledata 125 = rimd,
    tabledata 81 = rimd,
    tabledata 25 = rimd,
    tabledata 21 = rimd,
    tabledata 379 = rimd,
    tabledata 7000002 = rimd,
    tabledata 380 = rimd;

    Var
        ContoldeProcesos: Codeunit ControlProcesos;
        Panorama: Codeunit Panorama;

        ContabAlb: Codeunit ContabAlb;

    trigger OnRun()
    Var
        V: Codeunit "B2R WS";
        pType: Enum "Sales Document Type";
        Texto: Text;
        SalesInvoice: Record "Sales Invoice Header";
    begin
        SalesInvoice.SetRange("B2R Facturación electrónica", true);
        SalesInvoice.SetRange("B2R FacturaE enviada", true);
        SalesInvoice.SetRange("B2R id", '');
        if SalesInvoice.FindFirst() then
            repeat
                Texto := V.GetStatusDocumentTxt(SalesInvoice."B2r ID", SalesInvoice."No.", true);
            until SalesInvoice.Next() = 0;
        Commit();
        SalesInvoice.SetFilter("B2R id", '<>%1', '');
        SalesInvoice.SetRange("B2R FACe ID", '<>%1', '');
        SalesInvoice.SetRange("B2R FACe ID 2", '');
        if SalesInvoice.FindSet() then
            repeat
                SalesInvoice."B2R FACE ID 2" := SalesInvoice."B2R FACE ID";
                SalesInvoice.Modify();
            until SalesInvoice.Next() = 0;
        SalesInvoice.SetRange("B2R FACE ID");
        if SalesInvoice.FindFirst() then
            repeat
                Texto := V.GetStatusDocumentTxt(SalesInvoice."B2r ID", SalesInvoice."No.", true);
            until SalesInvoice.Next() = 0;
        Commit();

    end;
    #region EventSubscriber

    #region Pages
    #region pageNavigate
    [EventSubscriber(ObjectType::Page, Page::Navigate, 'OnFindRecordsOnOpenOnAfterSetDocuentFilters', '', false, false)]
    local procedure OnFindRecordsOnOpenOnAfterSetDocuentFilters(var Rec: Record "Document Entry"; var DocNoFilter: Text; var PostingDateFilter: Text; ExtDocNo: Code[250]; NewSourceRecVar: Variant)
    var
        RecRef: RecordRef;
        Contratos: Record "Sales Header";
        Pedido: Record "Purchase Header";
        PurchRcptHeader: Record "Purch. Rcpt. Header";
        PurchaseHeader: Record "Purchase Header";
        SalesHeader: Record "Sales Header";
        PurchInvHeader: Record "Purch. Inv. Header";
        PurchCrMemoHeader: Record "Purch. Cr. Memo Hdr.";
        SalesShptHeader: Record "Sales Shipment Header";
        SalesInvHeader: Record "Sales Invoice Header";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        NavigatePage: Page "Navigate";
        JobNo: Code[20];
        DocNo: Code[20];
    begin
        If NewSourceRecVar.IsRecord then begin
            RecRef.GetTable(NewSourceRecVar);
            If (RecRef.Number = Database::"Sales Header") Or (RecRef.Number = Database::Job) or (RecRef.Number = Database::"Purchase Header") then begin

                If (RecRef.Number = Database::Job) Then JobNo := RecRef.Field(1).Value;
                If (RecRef.Number = Database::"Sales Header") Then begin
                    DocNo := RecRef.Field(3).Value;
                    If Contratos.Get("Sales Document Type".FromInteger(RecRef.Field(1).Value), DocNo) then begin
                        JobNo := Contratos."Nº Proyecto";
                    end;
                end;
                If (RecRef.Number = Database::"Purchase Header") Then begin
                    DocNo := RecRef.Field(3).Value;
                    If Pedido.Get("Purchase Document Type".FromInteger(RecRef.Field(1).Value), DocNo) then begin
                        JobNo := Pedido."Nº Proyecto";
                    end;
                end;
                If JobNo <> '' Then begin

                    PostingDateFilter := '';
                    DocNoFilter := '';
                    PurchRcptHeader.SetRange("Nº Proyecto", JobNo);
                    If PurchRcptHeader.FindFirst() then
                        repeat
                            NavigatePage.MakeExtFilter(PostingDateFilter, PurchRcptHeader."Posting Date", DocNOfilter, PurchRcptHeader."No.");

                        until PurchRcptHeader.Next() = 0;
                    PurchInvHeader.SetRange("Nº Proyecto", JobNo);
                    If PurchInvHeader.FindFirst() then
                        repeat
                            NavigatePage.MakeExtFilter(PostingDateFilter, PurchInvHeader."Posting Date", DocNOfilter, PurchInvHeader."No.");

                        until PurchInvHeader.Next() = 0;
                    PurchCrMemoHeader.SetRange("Nº Proyecto", JobNo);
                    If PurchCrMemoHeader.FindFirst() then
                        repeat
                            NavigatePage.MakeExtFilter(PostingDateFilter, PurchCrMemoHeader."Posting Date", DocNOfilter, PurchCrMemoHeader."No.");

                        until PurchCrMemoHeader.Next() = 0;
                    PurchaseHeader.SetRange("Nº Proyecto", JobNo);
                    If PurchaseHeader.FindFirst() then
                        repeat
                            NavigatePage.MakeExtFilter(PostingDateFilter, PurchaseHeader."Posting Date", DocNOfilter, PurchaseHeader."No.");

                        until PurchaseHeader.Next() = 0;
                    SalesShptHeader.SetRange("Nº Proyecto", JobNo);
                    SalesShptHeader.Setrange("Albarán Venta", true);
                    If SalesShptHeader.FindFirst() then
                        repeat
                            NavigatePage.MakeExtFilter(PostingDateFilter, SalesShptHeader."Posting Date", DocNOfilter, SalesShptHeader."No.");

                        until SalesShptHeader.Next() = 0;
                    SalesInvHeader.SetRange("Nº Proyecto", JobNo);
                    If SalesInvHeader.FindFirst() then
                        repeat
                            NavigatePage.MakeExtFilter(PostingDateFilter, SalesInvHeader."Posting Date", DocNOfilter, SalesInvHeader."No.");

                        until SalesInvHeader.Next() = 0;
                    SalesCrMemoHeader.SetRange("Nº Proyecto", JobNo);
                    If SalesCrMemoHeader.FindFirst() then
                        repeat
                            NavigatePage.MakeExtFilter(PostingDateFilter, SalesCrMemoHeader."Posting Date", DocNOfilter, SalesCrMemoHeader."No.");

                        until SalesCrMemoHeader.Next() = 0;
                    SalesHeader.SetRange("Nº Proyecto", JobNo);
                    SalesHeader.SetFilter("No.", '<>%1', Contratos."No.");
                    If SalesHeader.FindFirst() then
                        repeat
                            NavigatePage.MakeExtFilter(PostingDateFilter, SalesHeader."Posting Date", DocNOfilter, SalesHeader."No.");

                        until SalesHeader.Next() = 0;

                end;
            end;

        end;
    end;

    [EventSubscriber(ObjectType::Page, Page::Navigate, 'OnAfterNavigateFindRecords', '', false, false)]
    local procedure OnAfterNavigateFindRecords(var DocumentEntry: Record "Document Entry"; DocNoFilter: Text; PostingDateFilter: Text; var NewSourceRecVar: Variant; ExtDocNo: Code[250]; HideDialog: Boolean)
    var
        Contratos: Record "Sales Header";
        Jobs: Record Job;
        Salesinvoice: Record "Sales Invoice Header";
        Recref: RecordRef;
    begin
        if NewSourceRecVar.IsRecord then begin
            RecRef.GetTable(NewSourceRecVar);
            If (RecRef.Number = Database::"Sales Invoice Header") then begin
                Contratos.SetRange("No.", RecRef.Field(50030).Value);
                if Contratos.FindFirst() then begin
                    DocumentEntry.Init();
                    DocumentEntry."Entry No." := DocumentEntry."Entry No." + 1;
                    DocumentEntry."Table ID" := Database::"Sales Header";
                    DocumentEntry."Document Type" := DocumentEntry."Document Type"::Order;
                    DocumentEntry."Table Name" := CopyStr('Contratos', 1, MaxStrLen(DocumentEntry."Table Name"));
                    DocumentEntry."No. of Records" := 1;
                    DocumentEntry.Insert();
                    If Jobs.Get(Contratos."Nº Proyecto") then begin
                        DocumentEntry.Init();
                        DocumentEntry."Entry No." := DocumentEntry."Entry No." + 1;
                        DocumentEntry."Table ID" := Database::Job;
                        DocumentEntry."Document Type" := DocumentEntry."Document Type"::" ";
                        DocumentEntry."Table Name" := CopyStr(Jobs.TableCaption, 1, MaxStrLen(DocumentEntry."Table Name"));
                        DocumentEntry."No. of Records" := 1;
                        DocumentEntry.Insert();
                    end;

                end;



            end;

        end;
    end;

    [EventSubscriber(ObjectType::Page, Page::Navigate, 'OnBeforeNavigateShowRecords', '', false, false)]
    local procedure OnBeforeNavigateShowRecords(TableID: Integer; DocNoFilter: Text; PostingDateFilter: Text; ItemTrackingSearch: Boolean; var TempDocumentEntry: Record "Document Entry" temporary; var IsHandled: Boolean; var SalesInvoiceHeader: Record "Sales Invoice Header"; var SalesCrMemoHeader: Record "Sales Cr.Memo Header"; var PurchInvHeader: Record "Purch. Inv. Header"; var PurchCrMemoHdr: Record "Purch. Cr. Memo Hdr."; var ServiceInvoiceHeader: Record "Service Invoice Header"; var ServiceCrMemoHeader: Record "Service Cr.Memo Header"; var SOSalesHeader: Record "Sales Header"; var SISalesHeader: Record "Sales Header"; var SCMSalesHeader: Record "Sales Header"; var SROSalesHeader: Record "Sales Header"; var GLEntry: Record "G/L Entry"; var VATEntry: Record "VAT Entry"; var VendLedgEntry: Record "Vendor Ledger Entry"; var WarrantyLedgerEntry: Record "Warranty Ledger Entry"; var NewSourceRecVar: Variant; var SalesShipmentHeader: Record "Sales Shipment Header"; var ReturnReceiptHeader: Record "Return Receipt Header"; var ReturnShipmentHeader: Record "Return Shipment Header"; var PurchRcptHeader: Record "Purch. Rcpt. Header"; var CustLedgerEntry: Record "Cust. Ledger Entry"; var DetailedCustLedgEntry: Record "Detailed Cust. Ledg. Entry")
    var
        Contratos: Record "Sales Header";
        RecRef: RecordRef;
        Jobs: Record Job;
    begin
        If (TableID = Database::Job) or (TableID = Database::"Sales Header") then begin
            if NewSourceRecVar.IsRecord then begin
                RecRef.GetTable(NewSourceRecVar);
                If (RecRef.Number = Database::"Sales Invoice Header") or (RecRef.Number = Database::"Sales Cr.Memo Header") or
                (RecRef.Number = Database::"Sales Shipment Header") then begin
                    Contratos.SetRange("No.", RecRef.Field(50030).Value);
                    if Contratos.FindFirst() then begin
                        If TableID = Database::Job Then begin
                            If Jobs.Get(Contratos."Nº Proyecto") then begin
                                Jobs.SetRange("No.", Contratos."Nº Proyecto");
                                Page.RunModal(0, Jobs);
                                IsHandled := true;
                            end;
                        end else begin
                            If Contratos."No. Series" <> 'CONTRATO' THEN EXIT;
                            IsHandled := true;
                            Page.RunModal(Page::"Lista Contratos Venta", Contratos);
                        end;
                    end;
                end;
                If (RecRef.Number = Database::"Purch. Inv. Header") or (RecRef.Number = Database::"Purch. Cr. Memo Hdr.") then begin
                    Contratos.SetRange("No.", RecRef.Field(51043).Value);
                    if Contratos.FindFirst() then begin
                        If TableID = Database::Job Then begin
                            If Jobs.Get(Contratos."Nº Proyecto") then begin
                                Jobs.SetRange("No.", Contratos."Nº Proyecto");
                                IsHandled := true;
                                Page.RunModal(0, Jobs);
                            end;
                        end else begin
                            If Contratos."No. Series" <> 'CONTRATO' THEN EXIT;
                            IsHandled := true;
                            Page.RunModal(Page::"Lista Contratos Venta", Contratos);
                        end;
                    end;
                end;
                If (RecRef.Number = Database::"Purch. Rcpt. Header") then begin
                    Contratos.SetRange("Nº Proyecto", RecRef.Field(50075).Value);
                    if Contratos.FindFirst() then begin
                        If TableID = Database::Job Then begin
                            If Jobs.Get(Contratos."Nº Proyecto") then begin
                                Jobs.SetRange("No.", Contratos."Nº Proyecto");
                                IsHandled := true;
                                Page.RunModal(0, Jobs);
                            end;
                        end else begin
                            If Contratos."No. Series" <> 'CONTRATO' THEN EXIT;
                            IsHandled := true;
                            Page.RunModal(Page::"Lista Contratos Venta", Contratos);
                        end;
                    end;
                end;
            end;
        end;
    end;

    [EventSubscriber(ObjectType::Page, Page::Navigate, 'OnBeforeFindRecordsSetSources', '', false, false)]
    local procedure OnBeforeFindRecordsSetSources(var DocumentEntry: Record "Document Entry"; DocNoFilter: Text; PostingDateFilter: Text; ExtDocNo: Text; var IsHandled: Boolean)
    begin
        IsHandled := StrPos(DocNoFilter, '|') > 0;
    end;
    #endregion pageNavigate

    #endregion Pages
    #region Reports
    #region report 492
    [EventSubscriber(ObjectType::Page, 5050, 'OnAfterEnableFields', '', false, false)]
    local procedure OnAfterEnableFields(var CompanyGroupEnabled: Boolean; var PersonGroupEnabled: Boolean; var CurrencyCodeEnable: Boolean; var VATRegistrationNoEnable: Boolean; var CompanyNameEnable: Boolean; var OrganizationalLevelCodeEnable: Boolean)
    begin
        VATRegistrationNoEnable := true;
    end;



    [EventSubscriber(ObjectType::Report, Report::"Copy Purchase Document", 'OnAfterOnPreReport', '', false, false)]
    local procedure OnAfterOnPreReport(PurchDocTypeFrom: Enum "Purchase Document Type From"; DocNo: Code[20]; var PurchaseHeader: Record "Purchase Header")
    begin
        PurchaseHeader."Document Date" := WorkDate();
        PurchaseHeader."Order Date" := WorkDate();
        PurchaseHeader.Modify();
    end;
    #endregion report 492
    #region report 5692
    [EventSubscriber(ObjectType::Report, Report::"Calculate Depreciation", 'OnBeforeOnInitReport', '', false, false)]
    local procedure OnBeforeOnInitReport(var DeprBookCode: Code[10])
    var
        FAJnlSetup: Record "FA Journal Setup";
        GenJnlTemplate: Record "Gen. Journal Template";
        GenJnlBatch: Record "Gen. Journal Batch";
        FAGetJnl: Codeunit "FA Get Journal";
        TemplateName: Code[10];
        BatchName: Code[10];
        GenJnlLine: Record "Gen. Journal Line";
    begin
        if DeprBookCode = '' Then begin
            FAJnlSetup.FindFirst();
            DeprBookCode := FAJnlSetup."Depreciation Book Code";
        end;
        if not FAJnlSetup.Get(DeprBookCode, UserId) then
            FAJnlSetup.Get(DeprBookCode, '');
        FAJnlSetup.TestField("Gen. Jnl. Template Name");
        FAJnlSetup.TestField("Gen. Jnl. Batch Name");
        TemplateName := FAJnlSetup."Gen. Jnl. Template Name";
        BatchName := FAJnlSetup."Gen. Jnl. Batch Name";
        GenJnlTemplate.Get(TemplateName);
        GenJnlBatch.Get(TemplateName, BatchName);
        GenJnlTemplate.Get(TemplateName);
        GenJnlBatch.Get(TemplateName, BatchName);
        GenJnlLine.SetRange("Journal Template Name", TemplateName);
        GenJnlLine.SetRange("Journal Batch Name", BatchName);
        if GenJnlLine.FindFirst() then Error('Hay líneas en el diario para esta fecha, elimínelas o regístrelas para continuar');

    end;
    #endregion report 5692
    #region report 297
    [EventSubscriber(ObjectType::Report, report::"Batch Post Sales Invoices", 'OnAfterOnOpenPage', '', false, false)]
    local procedure OnAfterOnOpenPage(var CalcInvDisc: Boolean; var ReplacePostingDate: Boolean; var ReplaceDocumentDate: Boolean; var PrintDoc: Boolean; var PrintDocVisible: Boolean; var PostingDateReq: Date; var ReplaceVATDateReq: Boolean; var VATDateReq: Date)
    begin
        ReplaceDocumentDate := true;
        ReplacePostingDate := true;
        ReplaceVATDateReq := true;
    end;

    [EventSubscriber(ObjectType::Report, report::"Batch Post Sales Invoices", 'OnBeforeSalesHeaderPreDataItem', '', false, false)]
    local procedure OnBeforeSalesHeaderPreDataItem(var SalesHeader: Record "Sales Header"; var SalesBatchPostMgt: Codeunit "Sales Batch Post Mgt."; var PrintDoc: Boolean)
    var
        SalesLine: Record 37;
        SalesSLine: Record 111;
        SalesLine2: Record 37;
        SalesLine3: Record 37 temporary;
        SalesComentLine: Record "Sales Comment Line";
        SalesComentLine2: Record "Sales Comment Line";
        SalesHeader2: Record "Sales Header";
        SalesHeader3: Record "Sales Header" temporary;
        C80: Codeunit 80;
        Contab: Codeunit ContabAlb;
        Alb: Record 110;
        Setup: Record 311;
        Cust: Record Customer;
    begin
        Setup.Get;
        //Message('1');
        if Setup."Activar Cont a 0" = false then exit;
        if SalesHeader.Count = 1 Then begin
            SalesHeader.CalcFields(Amount, "Amount Including VAT");
            SalesHeader.FindFirst();
            Message('%1', SalesHeader."Amount Including VAT");
            if (Round(SalesHeader.Amount, 0.01, '=') = 0) And
            (Round(SalesHeader."Amount Including VAT", 0.01, '=') <> 0) then
                Error('La factura/albarán es 0, pero tiene Iva');
            if ABS(SalesHeader."Amount Including VAT") < 1 Then begin
                Cust.Get(SalesHeader."Bill-to Customer No.");
                if Cust."Generar facturas a 0" Then exit;
                if not SalesHeader.Invoice then exit;
                SalesLine.SetRange(SalesLine."Document Type", SalesHeader."Document Type");
                SalesLine.SetRange(SalesLine."Document No.", SalesHeader."No.");

                if SalesLine.FindFirst() Then begin
                    SalesLine.CalcSums("Line Amount");
                    if ABS(SalesLine."Line Amount") > 1 Then exit;
                end;
                SalesLine2.SetRange(SalesLine2."Document Type", SalesLine2."Document Type"::Order);
                SalesLine2.SetRange(SalesLine2."Document No.", SalesHeader."No.");
                SalesLine2.DeleteAll();
                if SalesLine.FindFirst() Then
                    repeat
                        SalesLine2 := SalesLine;
                        SalesLine2."Document Type" := SalesLine."Document Type"::Order;
                        SalesLine2."Qty. to Invoice" := 0;
                        SalesLine2."Qty. to Ship" := SalesLine.Quantity;
                        SalesLine2."Qty. to Invoice (Base)" := SalesLine."Quantity (Base)";
                        SalesLine2."Qty. to Invoice (Base)" := 0;
                        SalesLine2."Job No." := '';
                        SalesLine2.Insert();
                        SalesLine3 := SalesLine;
                        SalesLine3.Insert();
                    until SalesLine.Next() = 0;
                SalesLine.DeleteAll();
                if SalesHeader2.get(SalesHeader2."Document Type"::Order, SalesHeader."No.") then
                    SalesHeader2.Delete();
                SalesHeader2 := SalesHeader;
                SalesHeader2."Document Type" := SalesHeader."Document Type"::Order;
                SalesHeader2.Ship := true;
                SalesHeader2.Invoice := false;
                SalesHeader2.Insert();
                SalesHeader3 := SalesHeader;
                SalesHeader3.Insert();
                SalesHeader.Delete();
                SalesHeader := SalesHeader2;
                Commit();
                SalesHeader.SetRange(SalesHeader."No.", SalesHeader."No.");
                SalesHeader.SetRange(SalesHeader."Document Type", SalesHeader."Document Type"::Order);
                if C80.Run(SalesHeader) then begin
                    alb.Get(salesheader."Last Shipping No.");
                    Alb.SetRange("No.", SalesHeader."Last Shipping No.");
                    SalesSLine.SetRange("Document No.", SalesHeader."Last Shipping No.");
                    if SalesSLine.FindFirst() Then
                        repeat
                            if SalesSLine."Line Amount" = 0 Then begin
                                SalesSLine."Line Amount" := SalessLine."Unit Price" * SalessLine.Quantity * (1 - (SalessLine."Line Discount %" / 100));
                                SalesSLine.Amount := SalessLine."Line Amount";
                                SalesSLine."Amount Including VAT" := SalessLine.Amount * (1 + SalessLine."VAT %" / 100);
                            end;
                            SalesSLine.Modify();
                        until SalesSLine.Next() = 0;
                    commit;
                    If Contab.ContaAlbVenta(SalesHeader, false) Then Begin
                        SalesLine2.SetRange(SalesLine2."Document Type", SalesLine2."Document Type"::Order);
                        SalesLine2.SetRange(SalesLine2."Document No.", SalesHeader."No.");
                        SalesLine2.DeleteAll();
                        SalesHeader.Delete();
                    end else begin
                        SalesLine.SetRange(SalesLine."Document Type", SalesHeader."Document Type");
                        SalesLine.SetRange(SalesLine."Document No.", SalesHeader."No.");
                        SalesLine.DeleteAll();
                        if SalesLine3.FindFirst() Then
                            repeat
                                SalesLine := SalesLine3;
                                SalesLine.Insert();

                            until SalesLine3.Next() = 0;
                        SalesHeader := SalesHeader3;
                        SalesHeader.Insert();
                        Commit();
                        Error(GetLastErrorText(false));
                    end;
                    Commit();
                    Error('Proceso Concluido');
                    SalesBatchPostMgt.SetPostingCodeunitId(0);
                end else begin

                    SalesLine.SetRange(SalesLine."Document Type", SalesHeader."Document Type");
                    SalesLine.SetRange(SalesLine."Document No.", SalesHeader."No.");
                    SalesLine.DeleteAll();
                    if SalesLine3.FindFirst() Then
                        repeat
                            SalesLine := SalesLine3;
                            SalesLine.Insert();

                        until SalesLine3.Next() = 0;
                    SalesHeader := SalesHeader3;
                    SalesHeader.Insert();
                    Commit();
                    Error(GetLastErrorText(false));
                    SalesBatchPostMgt.SetPostingCodeunitId(0);
                end;

            end;
        end;


    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Batch Processing Mgt.", 'OnCustomProcessing', '', false, false)]
    local procedure OnCustomProcessing(var RecRef: RecordRef; var Handled: Boolean; var KeepParameters: Boolean)
    var
        Rid: RecordId;
        SalesLine: Record 37;
        SalesSLine: Record 111;
        SalesLine2: Record 37;
        SalesLine3: Record 37 temporary;
        SalesComentLine: Record "Sales Comment Line";
        SalesComentLine2: Record "Sales Comment Line";
        SalesHeader2: Record "Sales Header";
        SalesHeader3: Record "Sales Header" temporary;
        C80: Codeunit 80;
        Contab: Codeunit ContabAlb;
        Alb: Record 110;
        Setup: Record 311;
        Cust: Record Customer;
        SalesHeader: Record "Sales Header";
    begin
        Rid := RecRef.RecordId;
        if Rid.TableNo = 36 Then begin
            RecRef.SetTable(SalesHeader);
        end else
            exit;
        Setup.Get;
        if Setup."Activar Cont a 0" = false then exit;
        if not SalesHeader.Invoice then exit;


        SalesHeader.CalcFields(Amount, "Amount Including VAT");
        if (Round(SalesHeader.Amount, 0.01, '=') = 0) And
            (Round(SalesHeader."Amount Including VAT", 0.01, '=') <> 0) then
            Error('La factura/albarán es 0, pero tiene Iva');
        if ABS(SalesHeader."Amount Including VAT") < 1 Then begin
            Handled := true;
            Cust.Get(SalesHeader."Bill-to Customer No.");
            if Cust."Generar facturas a 0" Then exit;
            SalesLine.SetRange(SalesLine."Document Type", SalesHeader."Document Type");
            SalesLine.SetRange(SalesLine."Document No.", SalesHeader."No.");
            SalesLine2.SetRange(SalesLine2."Document Type", SalesLine2."Document Type"::Order);
            SalesLine2.SetRange(SalesLine2."Document No.", SalesHeader."No.");
            SalesLine2.DeleteAll();
            if SalesLine.FindFirst() Then
                repeat
                    SalesLine2 := SalesLine;
                    SalesLine2."Document Type" := SalesLine."Document Type"::Order;
                    SalesLine2."Qty. to Invoice" := 0;
                    SalesLine2."Qty. to Ship" := SalesLine.Quantity;
                    SalesLine2."Qty. to Invoice (Base)" := SalesLine."Quantity (Base)";
                    SalesLine2."Qty. to Invoice (Base)" := 0;
                    SalesLine2."Job No." := '';
                    SalesLine2.Insert();
                    SalesLine3 := SalesLine;
                    SalesLine3.Insert();
                until SalesLine.Next() = 0;
            SalesLine.DeleteAll();
            if SalesHeader2.get(SalesHeader2."Document Type"::Order, SalesHeader."No.") then
                SalesHeader2.Delete();
            SalesHeader2 := SalesHeader;
            SalesHeader2."Document Type" := SalesHeader."Document Type"::Order;
            SalesHeader2.Ship := true;
            SalesHeader2.Invoice := false;
            SalesHeader2.Insert();
            SalesHeader3 := SalesHeader;
            SalesHeader3.Insert();
            SalesHeader.Delete();
            SalesHeader := SalesHeader2;
            Commit();
            SalesHeader.SetRange(SalesHeader."No.", SalesHeader."No.");
            SalesHeader.SetRange(SalesHeader."Document Type", SalesHeader."Document Type"::Order);
            if C80.Run(SalesHeader) then begin
                alb.Get(salesheader."Last Shipping No.");
                Alb.SetRange("No.", SalesHeader."Last Shipping No.");
                SalesSLine.SetRange("Document No.", SalesHeader."Last Shipping No.");
                if SalesSLine.FindFirst() Then
                    repeat
                        if SalesSLine."Line Amount" = 0 Then begin
                            SalesSLine."Line Amount" := SalessLine."Unit Price" * SalessLine.Quantity * (1 - (SalessLine."Line Discount %" / 100));
                            SalesSLine.Amount := SalessLine."Line Amount";
                            SalesSLine."Amount Including VAT" := SalessLine.Amount * (1 + SalessLine."VAT %" / 100);
                        end;
                        SalesSLine.Modify();
                    until SalesSLine.Next() = 0;
                commit;
                If Contab.ContaAlbVenta(SalesHeader, true) Then Begin
                    SalesLine2.SetRange(SalesLine2."Document Type", SalesLine2."Document Type"::Order);
                    SalesLine2.SetRange(SalesLine2."Document No.", SalesHeader."No.");
                    SalesLine2.DeleteAll();
                    SalesHeader.Delete();
                end else begin
                    SalesLine.SetRange(SalesLine."Document Type", SalesHeader."Document Type");
                    SalesLine.SetRange(SalesLine."Document No.", SalesHeader."No.");
                    SalesLine.DeleteAll();
                    if SalesLine3.FindFirst() Then
                        repeat
                            SalesLine := SalesLine3;
                            SalesLine.Insert();

                        until SalesLine3.Next() = 0;
                    SalesHeader := SalesHeader3;
                    SalesHeader.Insert();
                    Commit();
                    Error(GetLastErrorText(false));

                end;
                //Error('Proceso Concluido');
            end else begin

                SalesLine.SetRange(SalesLine."Document Type", SalesHeader."Document Type");
                SalesLine.SetRange(SalesLine."Document No.", SalesHeader."No.");
                SalesLine.DeleteAll();
                if SalesLine3.FindFirst() Then
                    repeat
                        SalesLine := SalesLine3;
                        SalesLine.Insert();

                    until SalesLine3.Next() = 0;
                SalesHeader := SalesHeader3;
                SalesHeader.Insert();
                Commit();
                Error(GetLastErrorText(false));
            end;

        end;



    end;
    #endregion 297
    #region 50024
    [EventSubscriber(ObjectType::Report, 50024, 'OnAfterGetPostedDocOnBeforeValidateAccountNo', '', false, false)]
    local procedure OnAfterGetPostedDocOnBeforeValidateAccountNo(var GenJournalLine: Record "Gen. Journal Line"; var PostedCarteraDoc: Record "Posted Cartera Doc."; var VATPostingSetup: Record "VAT Posting Setup"; var CustLedgerEntry: Record "Cust. Ledger Entry"; var FromJnl: Boolean; var ExistsNoRealVAT: Boolean)
    var

        Factura: Record "Sales Invoice Header";
        Contrato: Record "Sales Header";
        Borrador: Record "Sales Header";
        SalesandReceivablesSetup: Record "Sales & Receivables Setup";
    begin
        SalesandReceivablesSetup.GET;
        If SalesandReceivablesSetup."Activar Aviso Cobro" = false then exit;
        if PostedCarteraDoc."No. Borrador factura" <> '' then begin

            If Borrador.Get(Borrador."Document Type"::Invoice, PostedCarteraDoc."No. Borrador factura") then begin
                If Not Contrato.Get(Contrato."Document Type"::Order, Borrador."Nº Contrato") then Contrato.Init();
                If Contrato."Prepayment %" = 0 Then
                    EnviaCorreo(Borrador."Nº Contrato", Borrador."No.", Borrador."Salesperson Code", Borrador."Sell-to Customer Name");
            end;
            Factura.SetCurrentKey("Pre-Assigned No.");
            Factura.SetRange("Pre-Assigned No.", PostedCarteraDoc."No. Borrador factura");
            if Factura.FindFirst() then begin
                If Not Contrato.Get(Contrato."Document Type"::Order, Factura."Nº Contrato") then Contrato.Init();
                If Contrato."Prepayment %" = 0 Then
                    EnviaCorreo(Factura."Nº Contrato", Factura."No.", Factura."Salesperson Code", Factura."Sell-to Customer Name");
            end;
            exit;


        end;
    end;
    #endregion 50024
    #endregion Reports
    #endregion EventSubscriber

    local procedure EnviaCorreo(NContrato: Code[20]; No: Code[20]; SalespersonCode: Code[20]; CustomerName: Text)


    var
        Mail: Codeunit Mail;
        Salesperson2: Record "Salesperson/Purchaser";
        Body: Text;
        BigText: Text;
        REmail: Record "Email Item" temporary;
        emilesc: Enum "Email Scenario";
        rInf: Record "Company Information";
        Funciones: Codeunit "Funciones Correo PDF";
        r17: Record "G/L Entry";
        Base64: Text;
    begin
        Salesperson2.Get(SalespersonCode);
        rInf.Get();
        BigText := ('Estimad@ ' + Salesperson2.Name + ':');

        //(FORMAT(cr,0,'<CHAR>') + FORMAT(lf,0,'<CHAR>')
        BigText := BigText + '<br> </br>';
        BigText := BigText + '<br> </br>';
        //BigText:=('<br> </br>';
        BigText := BigText + ('La factura nº ' + No + ' correspondiente al contrato nº ' + NContrato);
        BigText := BigText + (' de la empresa ' + rInf.Name + ' ha sido pagada por el cliente ');
        BigText := BigText + (CustomerName);
        BigText := BigText + (' con fecha de hoy, ' + format(TODAY, 0, '<Day,2>/<Month,2>/<Year>'));
        BigText := BigText + '<br> </br>';
        BigText := BigText + '<br> </br>';
        BigText := BigText + ('Aprovechamos la ocasión para enviarte un cordial saludo');
        BigText := BigText + '<br> </br>';
        BigText := BigText + '<br> </br>';
        BigText := BigText + ('Atentamente');
        BigText := BigText + '<br> </br>';
        BigText := BigText + ('Dpto. Administración');
        BigText := BigText + '<br> </br>';

        BigText := BigText + (rInf.Name);
        //"Plaintext Formatted":=TRUE;
        // SendMsg.AppendBody(BigText);
        // CLEAR(BigText);
        Funciones.CargaPie(Base64);
        BigText := BigText + '<br> </br>';
        BigText := BigText + '<br> </br>';
        BigText := BigText + '<img src="data:image/png;base64,' + base64 + '" />';//"emailFoot.png" />';
        BigText := BigText + '<br> </br>';
        BigText := BigText + '<br> </br>';
        BigText := BigText + '<font face="Franklin Gothic Book" sice=2 color=#A6A6A6>';
        BigText := BigText + ('<b>SI NO DESEA RECIBIR MAS INFORMACION, CONTESTE ESTE E-MAIL INDICANDOLO EXPRESAMENTE</b>');
        BigText := BigText + '</font>';
        BigText := BigText + '<br> </br>';
        BigText := BigText + '<font face="Franklin Gothic Book" size=1 color=#A6A6A6>';
        BigText := BigText + ('En cumplimiento de lo establecido en el REGLAMENTO (UE) 2016/679, de 27 de abril de 2016, con plenos efectos desde el 25 de mayo de 2018, le recordamos que sus datos personales son');
        BigText := BigText + ('objeto de tratamiento por parte de MALLA S.A. Le informamos también que tiene la posibilidad de ejercer los derechos de acceso, rectificación, supresión, oposición, limitación del');
        BigText := BigText + (' tratamiento y portabilidad de sus datos, mediante comunicación escrita a la dirección de correo electrónico <a href="mailto:lopd@malla.es" rel="noreferrer" target="_blank" heap-ignore="true"><span style="color:blue">lopd@malla.es</span></a>, o bien, a nuestra dirección postal (' + rInf.Name + ')');
        BigText := BigText + (rInf.Address + '. ' + rInf."Post Code" + '. ' + rInf.City + '. España');
        BigText := BigText + '<br> </br>';
        BigText := BigText + ('Este correo y sus archivos asociados son privados y confidenciales y va dirigido exclusivamente a su destinatario. Si recibe este correo sin ser el destinatario del mismo, le rogamos proceda');
        BigText := BigText + (' a su eliminación y lo ponga en conocimiento del emisor. La difusión por cualquier medio del contenido de este correo podría ser sancionada conforme a lo previsto en las leyes españolas.');
        BigText := BigText + ('No se autoriza la utilización con fines comerciales o para su incorporación a ficheros automatizados de las direcciones del emisor o del destinatario');
        REmail.Subject := 'Pago contrato ' + NContrato;

        REmail."Send to" := Salesperson2."E-Mail";
        REmail."Send BCC" := 'andreuserra@malla.es';
        REmail.SetBodyText(BigText);
        REmail."From Name" := 'Dpto. Administración';
        // if REmail."From Address" <> '' Then
        //     REmail."Send BCC" := REmail."From Address" else
        //     REmail."Send BCC" := BCC();
        if REmail.Send(true, emilesc::Default) then begin

        end;
    end;

    /// <summary>
    /// OpenProjectCard.
    /// </summary>
    /// <param name="Notification">Notification.</param>
    procedure OpenDocumentCard(Notification: Notification)
    var
        Job: Record Job;
        ProjectNo: Text;
    begin
        ProjectNo := Notification.GetData('ProjectNo');
        if ProjectNo <> '' then begin
            Job.SetRange("No.", ProjectNo);
            if Job.FindFirst() then
                Page.Run(Page::"Job Card", Job);
        end;
    end;


}