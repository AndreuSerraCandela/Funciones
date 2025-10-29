/// <summary>
/// Codeunit Albaranes (ID 7001148).
/// </summary>
codeunit 50012 Albaranes
{
    Permissions = TableData "G/L Entry" = rimd,
    tabledata "Sales Shipment Header" = rimd,
    tabledata "Sales Shipment line" = rimd,
    tabledata "Sales Invoice Header" = rimd,
    tabledata "Sales Invoice line" = rimd,
    tabledata "Sales Cr.Memo Header" = rimd,
    tabledata "Sales Cr.Memo line" = rimd,
    tabledata "Purch. Rcpt. Header" = rimd,
    tabledata "Purch. Rcpt. line" = rimd,
    tabledata "Purch. Inv. Header" = rimd,
    tabledata "Purch. Inv. line" = rimd,
    tabledata "Purch. Cr. Memo Hdr." = rimd,
    tabledata "Purch. Cr. Memo line" = rimd,
    tabledata "G/L Register" = rimd,
    tabledata "VAT Entry" = rimd,
    tabledata "Bank Account Ledger Entry" = rimd,
    tabledata "Gen. Journal line" = rimd,
    tabledata "Vendor Ledger Entry" = rimd,
    tabledata "Cust. Ledger Entry" = rimd,
    tabledata "Detailed Cust. Ledg. Entry" = rimd,
    tabledata "Cartera Doc." = rimd,
    tabledata "Posted Cartera Doc." = rimd,
    tabledata "Closed Cartera Doc." = rimd,
    tabledata "Closed Bill Group" = rimd,
    tabledata "Posted Bill Group" = rimd,
    tabledata "Return Shipment Header" = rimd,
    tabledata "Return Shipment line" = rimd,
    tabledata "Detailed Vendor Ledg. Entry" = rimd;

    var
        gCControl: Codeunit ControlProcesos;
        glcontabilizado: Label 'Ya está contabilizado';
        glFacturado: Label 'Ya está facturado';

    /**
     * Procedure to unmark a record as registered.
     * 
     * @param Rec The record to be unmarked.
     */
    internal procedure DesmarcaComoCont(var pRec: Record "Purch. Rcpt. Header")
    Var
        ltContra: Text[30];
        lVentana: Page "Dialogo";
        lcCalculo: Record "Calculo Albaranes";
    BEGIN
        lVentana.SetTexto('Teclee contraseña');
        lVentana.RunModal();
        lVentana.GetTexto(ltContra);
        if ltContra = '6343' THEN BEGIN
            pRec.Contabilizado := FALSE;
            if lcCalculo.Get(pRec."No.") Then Begin lcCalculo.Calculado := False; lcCalculo.Modify(); End;
            pRec.MODIFY;
        END;
        //LVentana.CLOSE;
    END;

    /**
     * This internal procedure is used to unregister the associated cartera doc for a given purchase receipt header record.
     *
     * @param Rec: The purchase receipt header record.
     */
    internal procedure DescontabilizaAsCarte(pRec: Record "Purch. Rcpt. Header")
    Var
        lPurchRcptHdr: Record "Purch. Rcpt. Header";
        lPurchRcptline: Record "Purch. Rcpt. line";
        lPurchline: Record "Purchase line";
        lcContabAlb: Codeunit ContabAlb;
        lcCalculo: Record "Calculo Albaranes";
    BEGIN

        lPurchRcptHdr.GET(pRec."No.");
        //if lPurchRcptHdr.FINDFIRST THEN REPEAT
        lPurchRcptline.SETRANGE(lPurchRcptline."Document No.", lPurchRcptHdr."No.");
        if lPurchRcptline.FINDFIRST THEN
            REPEAT
                lPurchRcptline."Qty. Rcd. Not Invoiced" := lPurchRcptline.Quantity;
                lPurchRcptline."Quantity Invoiced" := 0;
                lPurchRcptline."Qty. Invoiced (Base)" := 0;
                if lPurchline.GET(lPurchline."Document Type"::Order, lPurchRcptline."Order No.", lPurchRcptline."Order line No.") THEN BEGIN
                    lPurchline."Qty. to Invoice" := lPurchline.Quantity;
                    lPurchline."Qty. Rcd. Not Invoiced" := lPurchline.Quantity;
                    lPurchline."Amt. Rcd. Not Invoiced" := lPurchline.Amount;
                    lPurchline."Quantity Invoiced" := 0;
                    lPurchline."Qty. to Invoice (Base)" := 0;
                    lPurchline."Qty. Rcd. Not Invoiced (Base)" := lPurchline."Quantity Received";
                    lPurchline."Qty. Invoiced (Base)" := 0;
                    lPurchline.MODIFY;
                END;
                lPurchRcptline.MODIFY;
            UNTIL lPurchRcptline.NEXT = 0;
        CLEAR(lcContabAlb);
        lcContabAlb.DesContabilizarFacturasContra(lPurchRcptHdr);

        lPurchRcptHdr.Facturado := FALSE;
        lPurchRcptHdr.Contabilizado := TRUE;
        if lcCalculo.Get(lPurchRcptHdr."No.") Then Begin lcCalculo.Calculado := False; lcCalculo.Modify(); End;
        lPurchRcptHdr.MODIFY;
    END;

    internal procedure BorrarAlbaran(pRec: Record "Purch. Rcpt. Header")
    Var
        lPurchRcptline: Record "Purch. Rcpt. line";
        lGlEntry: Record "G/L Entry";
        lcContabAlb: Codeunit ContabAlb;
        lPurchline: Record "Purchase line";
        lcCalculo: Record "Calculo Albaranes";
    BEGIN
        lPurchRcptline.SETRANGE(lPurchRcptline."Document No.", pRec."No.");
        if pRec.Contabilizado THEN ERROR(glcontabilizado);
        if lPurchRcptline.FINDFIRST THEN
            REPEAT
                CLEAR(lcContabAlb);
                if (lPurchRcptline.Quantity <> 0) THEN BEGIN
                    if lPurchline.GET(lPurchline."Document Type"::Order, lPurchRcptline."Order No.", lPurchRcptline."Order line No.") THEN
                        lcContabAlb.UpdatePurchline2(lPurchline, lPurchRcptline.Quantity, lPurchRcptline."Quantity (Base)");
                END;
            UNTIL lPurchRcptline.NEXT = 0;
        lPurchRcptline.SETRANGE(lPurchRcptline."line No.");
        lPurchRcptline.SETFILTER(lPurchRcptline."Quantity Invoiced", '<>%1', 0);
        if lPurchRcptline.FINDFIRST THEN error(glFacturado);
        lPurchRcptline.SETRANGE(lPurchRcptline."Quantity Invoiced");
        lPurchRcptline.DELETEALL;
        pRec.DELETE;
        if lcCalculo.Get(pRec."No.") Then lcCalculo.Delete;
    END;

    internal procedure BorrarDevolucion(pRec: Record "Return Shipment Header")
    Var
        lPurchRcptline: Record "Return Shipment line";
        lGlEntry: Record "G/L Entry";
        lcContabAlb: Codeunit ContabAlb;
        lPurchline: Record "Purchase line";
        lcCalculo: Record "Calculo Albaranes";
    BEGIN
        lPurchRcptline.SETRANGE(lPurchRcptline."Document No.", pRec."No.");
        if pRec.Contabilizado THEN ERROR(glcontabilizado);
        if lPurchRcptline.FINDFIRST THEN
            REPEAT
                CLEAR(lcContabAlb);
                if (lPurchRcptline.Quantity <> 0) THEN BEGIN
                    if lPurchline.GET(lPurchline."Document Type"::"Return Order", lPurchRcptline."Return Order No.", lPurchRcptline."Return Order line No.") THEN
                        lcContabAlb.UpdatePurchline2(lPurchline, lPurchRcptline.Quantity, lPurchRcptline."Quantity (Base)");
                END;
            UNTIL lPurchRcptline.NEXT = 0;
        lPurchRcptline.SETRANGE(lPurchRcptline."line No.");
        lPurchRcptline.SETFILTER(lPurchRcptline."Quantity Invoiced", '<>%1', 0);
        if lPurchRcptline.FINDFIRST THEN ERROR(glFacturado);
        lPurchRcptline.SETRANGE(lPurchRcptline."Quantity Invoiced");
        lPurchRcptline.DELETEALL;
        pRec.DELETE;
        if lcCalculo.Get(pRec."No.") Then lcCalculo.Delete;
    END;

    internal procedure DesContabilizarDevoluciones(var pRec: Record "Return Shipment Header")
    var
        lPurchRcptline: Record "Return Shipment line";
        lcContabAlb: Codeunit ContabAlb;
        liDesde: Integer;
        liHasta: Integer;
        lGlEntry: Record "G/L Entry";
        lReverSalEntry: Record "Reversal Entry";
    begin
        lPurchRcptline.SETRANGE(lPurchRcptline."Document No.", pRec."No.");
        lPurchRcptline.SETFILTER(lPurchRcptline."No.", '%1', '');
        lPurchRcptline.MODIFYALL(lPurchRcptline.Type, lPurchRcptline.Type::" ");
        COMMIT;
        CLEAR(lcContabAlb);
        lPurchRcptline.SetRange(lPurchRcptline."No.");
        lPurchRcptline.SetFilter("Quantity Invoiced", '<>%1', 0);
        if lPurchRcptline.FindFirst() Then
            lcContabAlb.DesContabilizaDevoluciones(pRec)
        else begin
            lGlEntry.SETCURRENTKEY(lGlEntry."Transaction No.");
            lGlEntry.SETRANGE("Document No.", pRec."No.");
            lGlEntry.SETRANGE("Document Type", lGlEntry."Document Type"::Receipt);
            lGlEntry.FINDLAST;
            liHasta := lGlEntry."Entry No.";
            lGlEntry.FindFirst();
            liDesde := lGlEntry."Entry No.";
            lReverSalEntry.ReverseAlbaran(lGlEntry."Transaction No.", liDesde, liHasta);
            pRec.Contabilizado := FALSE;
            pRec.MODIFY;
        end;
    END;



    internal procedure Descontabilizar(var pRec: Record "Purch. Rcpt. Header")
    Var
        lcContabAlb: Codeunit ContabAlb;
        lPurchRcptline: Record "Purch. Rcpt. line";
        liDesde: Integer;
        liHasta: Integer;
        lGlEntry: Record "G/L Entry";
        lReverSalEntry: Record "Reversal Entry";
        lcCalculo: Record "Calculo Albaranes";
    BEGIN
        lPurchRcptline.SETRANGE(lPurchRcptline."Document No.", pRec."No.");
        lPurchRcptline.SETFILTER(lPurchRcptline."No.", '%1', '');
        lPurchRcptline.MODIFYALL(lPurchRcptline.Type, lPurchRcptline.Type::" ");
        COMMIT;
        CLEAR(lcContabAlb);
        lPurchRcptline.SetRange(lPurchRcptline."No.");
        lPurchRcptline.SetFilter("Quantity Invoiced", '<>%1', 0);
        if lPurchRcptline.FindFirst() Then
            lcContabAlb.DesContabilizarAlbaranes(pRec)
        else begin
            lGlEntry.SETCURRENTKEY(lGlEntry."Transaction No.");
            lGlEntry.SETRANGE("Document No.", pRec."No.");
            lGlEntry.SETRANGE("Document Type", lGlEntry."Document Type"::Receipt);
            lGlEntry.FINDLAST;
            liHasta := lGlEntry."Entry No.";
            lGlEntry.FindFirst();
            liDesde := lGlEntry."Entry No.";
            lReverSalEntry.ReverseAlbaran(lGlEntry."Transaction No.", liDesde, liHasta);
            pRec.Contabilizado := FALSE;
            pRec.MODIFY;
        end;
        if lcCalculo.Get(pRec."No.") Then Begin lcCalculo.Calculado := False; lcCalculo.Modify(); End;
    END;


    /// <summary>
    /// MarcarComoFacturado.
    /// </summary>
    /// <param name="Rec">var pRecord "Purch. Rcpt. Header".</param>
    /**
     * Marks the selected record as invoiced and updates related records.
     *
     * @param Rec The record to be marked as invoiced.
     */
    procedure MarcarComoFacturado(var pRec: record "Purch. Rcpt. Header")
    Var
        lPurchRcptHdr: Record "Purch. Rcpt. Header";
        lPurchRcptline: Record "Purch. Rcpt. line";
        lPurchline: Record "Purchase line";
        lcCalculo: Record "Calculo Albaranes";
    BEGIN
        gCControl.MarcaAlb();
        lPurchRcptHdr.GET(pRec."No.");
        //if lPurchRcptHdr.FINDFIRST THEN REPEAT
        lPurchRcptline.SETRANGE(lPurchRcptline."Document No.", lPurchRcptHdr."No.");
        if lPurchRcptline.FINDFIRST THEN
            REPEAT
                lPurchRcptline."Qty. Rcd. Not Invoiced" := 0;
                lPurchRcptline."Quantity Invoiced" := lPurchRcptline.Quantity;
                lPurchRcptline."Qty. Invoiced (Base)" := lPurchRcptline."Quantity (Base)";
                if lPurchline.GET(lPurchline."Document Type"::Order, lPurchRcptline."Order No.", lPurchRcptline."Order line No.") THEN BEGIN
                    lPurchline."Qty. to Invoice" := lPurchline."Qty. to Receive";
                    lPurchline."Qty. Rcd. Not Invoiced" := 0;
                    lPurchline."Amt. Rcd. Not Invoiced" := 0;
                    lPurchline."Quantity Invoiced" := lPurchRcptline."Quantity Invoiced";
                    lPurchline."Qty. to Invoice (Base)" := 0;
                    lPurchline."Qty. Rcd. Not Invoiced (Base)" := 0;
                    lPurchline."Qty. Invoiced (Base)" := lPurchRcptline."Qty. Invoiced (Base)";
                    lPurchline.MODIFY;
                END;
                lPurchRcptline.MODIFY;
            UNTIL lPurchRcptline.NEXT = 0;
        lPurchRcptHdr.Facturado := TRUE;
        lPurchRcptHdr.Contabilizado := TRUE;
        if lcCalculo.Get(lPurchRcptHdr."No.") Then Begin lcCalculo.Calculado := False; lcCalculo.Modify(); End;
        lPurchRcptHdr.MODIFY;
        //UNTIL lPurchRcptHdr.NEXT=0;
    END;

    internal procedure GeneraPedido(var pRec: Record "Purch. Rcpt. Header")
    Var
        lPurchHeader: Record "Purchase Header";
        lPurchline: Record "Purchase line";
        lPurchRcptline: Record "Purch. Rcpt. line";
    BEGIN
        lPurchHeader.TRANSFERFIELDS(pRec);
        lPurchHeader."Document Type" := lPurchHeader."Document Type"::Order;
        lPurchHeader."No." := pRec."Order No.";
        lPurchHeader.INSERT;
        lPurchRcptline.SETRANGE(lPurchRcptline."Document No.", pRec."No.");
        if lPurchRcptline.FINDFIRST THEN
            REPEAT
                lPurchline.TRANSFERFIELDS(lPurchRcptline);
                lPurchline."Document Type" := lPurchline."Document Type"::Order;
                lPurchline."Document No." := lPurchHeader."No.";
                lPurchline.INSERT;
            UNTIL lPurchRcptline.NEXT = 0;
    END;

    internal procedure RecalcularIva(var pRec: Record "Purch. Rcpt. Header")
    Var
        lPurchRcptline: Record "Purch. Rcpt. line";
        lGlAccount: Record "G/L Account";
        lResource: Record Resource;
        lVatPostingSetup: Record "Vat Posting Setup";
    BEGIN
        lPurchRcptline.SETRANGE(lPurchRcptline."Document No.", pRec."No.");
        if lPurchRcptline.FINDFIRST THEN
            REPEAT
                CASE lPurchRcptline.Type OF
                    lPurchRcptline.Type::"G/L Account":
                        BEGIN
                            if lGlAccount.GET(lPurchRcptline."No.") THEN BEGIN
                                lPurchRcptline."VAT Prod. Posting Group" := lGlAccount."VAT Prod. Posting Group";
                                lVatPostingSetup.GET(pRec."VAT Bus. Posting Group", lGlAccount."VAT Prod. Posting Group");
                                lPurchRcptline."VAT %" := lVatPostingSetup."VAT %";
                                lPurchRcptline."Amount Including VAT" := lPurchRcptline.Amount * (1 + lVatPostingSetup."VAT %" / 100);
                                lPurchRcptline.MODIFY;
                            END;
                        END;
                    lPurchRcptline.Type::Resource:
                        BEGIN
                            if lResource.GET(lPurchRcptline."No.") THEN BEGIN
                                lPurchRcptline."VAT Prod. Posting Group" := lResource."VAT Prod. Posting Group";
                                lVatPostingSetup.GET(pRec."VAT Bus. Posting Group", lResource."VAT Prod. Posting Group");
                                lPurchRcptline."VAT %" := lVatPostingSetup."VAT %";
                                lPurchRcptline."Amount Including VAT" := lPurchRcptline.Amount * (1 + lVatPostingSetup."VAT %" / 100);
                                lPurchRcptline.MODIFY;
                            END;
                        END;
                END;
            UNTIL lPurchRcptline.NEXT = 0;
    END;



    internal procedure RecalcularCantidadFacturada(pCDoc: Code[20])
    Var
        lPurchRcptline: Record "Purch. Rcpt. line";
        lPurchInvLine: Record "Purch. Inv. Line";
    BEGIN
        lPurchRcptline.SETRANGE(lPurchRcptline."Document No.", pCDoc);
        if lPurchRcptline.FINDFIRST THEN
            REPEAT
                lPurchRcptline."Qty. Rcd. Not Invoiced" := lPurchRcptline.Quantity;
                lPurchRcptline."Quantity Invoiced" := 0;
                lPurchRcptline."Qty. Invoiced (Base)" := 0;
                lPurchInvLine.SETRANGE(lPurchInvLine."Receipt No.", lPurchRcptline."Document No.");
                lPurchInvLine.SETRANGE("Receipt line No.", lPurchRcptline."line No.");
                if lPurchInvLine.FINDFIRST THEN
                    REPEAT
                        lPurchRcptline."Quantity Invoiced" := lPurchRcptline."Quantity Invoiced" + lPurchInvLine.Quantity;
                        lPurchRcptline."Qty. Invoiced (Base)" := lPurchRcptline."Qty. Invoiced (Base)" + lPurchInvLine."Quantity (Base)";
                    UNTIL lPurchInvLine.NEXT = 0;
                lPurchRcptline."Qty. Rcd. Not Invoiced" := lPurchRcptline.Quantity - lPurchRcptline."Quantity Invoiced";
                lPurchRcptline.MODIFY;
            UNTIL lPurchRcptline.NEXT = 0;
    END;

    internal procedure RegeneraAsiento(var pRec: Record "Purch. Rcpt. Header")
    Var
        lGlEntry: Record "G/L Entry";
        lPurchRcptHdr: Record "Purch. Rcpt. Header";
        lPurchRcptline: Record "Purch. Rcpt. line";
        lVendorPostingGroup: Record "Vendor Posting Group";
        lcContabAlb: Codeunit ContabAlb;
        lcCalculo: Record "Calculo Albaranes";
    BEGIN
        pRec.Contabilizado := FALSE;
        pRec.MODIFY;
        if lcCalculo.Get((pRec."No.")) Then Begin lcCalculo.Calculado := False; lcCalculo.Modify() End;
        COMMIT;
        lPurchRcptHdr.GET(pRec."No.");
        lPurchRcptline.SETRANGE(lPurchRcptline."Document No.", lPurchRcptHdr."No.");
        if lPurchRcptline.FINDFIRST THEN
            REPEAT
                lPurchRcptline."Qty. Rcd. Not Invoiced" := lPurchRcptline.Quantity;
                lPurchRcptline."Quantity Invoiced" := 0;
                lPurchRcptline."Qty. Invoiced (Base)" := 0;
                lPurchRcptline.MODIFY;
            UNTIL lPurchRcptline.NEXT = 0;
        lPurchRcptHdr.Facturado := FALSE;
        lPurchRcptHdr.MODIFY;
        lGlEntry.SETCURRENTKEY("G/L Account No.", "Document No.", "Posting Date", "Tax Area Code");
        lGlEntry.SETRANGE(lGlEntry."G/L Account No.", '6', '8');
        lGlEntry.SETRANGE(lGlEntry."Tax Area Code", pRec."No.");
        lVendorPostingGroup.GET(pRec."Vendor Posting Group");
        lGlEntry.MODIFYALL(lGlEntry."G/L Account No.", lVendorPostingGroup.FPR);
        COMMIT;
        lPurchRcptHdr.GET(pRec."No.");
        CLEAR(lcContabAlb);
        lcContabAlb.ContabilizarAlbaranes(lPurchRcptHdr);
        COMMIT;
        lPurchRcptHdr.GET(pRec."No.");
        lPurchRcptline.SETRANGE(lPurchRcptline."Document No.", lPurchRcptHdr."No.");
        if lPurchRcptline.FINDFIRST THEN
            REPEAT
                lPurchRcptline."Qty. Rcd. Not Invoiced" := 0;
                lPurchRcptline."Quantity Invoiced" := lPurchRcptline.Quantity;
                lPurchRcptline."Qty. Invoiced (Base)" := lPurchRcptline.Quantity;
                lPurchRcptline.MODIFY;
            UNTIL lPurchRcptline.NEXT = 0;
        lPurchRcptHdr.Facturado := TRUE;
        lPurchRcptHdr.MODIFY;
        lGlEntry.RESET;
        lGlEntry.SETCURRENTKEY("Document No.");
        lGlEntry.SETRANGE("Document No.", pRec."No.");
        lGlEntry.SETRANGE(lGlEntry."Document Type", lGlEntry."Document Type"::Receipt);
        lGlEntry.MODIFYALL(lGlEntry."Tax Area Code", pRec."No.");
    END;

    internal procedure AsignaDatosAlbaran(var pRec: Record "Purch. Rcpt. Header")
    Var
        lSalesInvoiceline: Record "Sales Invoice line";
        lPurchRcptline2: Record "Purch. Rcpt. line";
        ltEmpresa: Text[30];
        licPartner: Record "IC Partner";
        lVendor: Record Vendor;
        lPurchline: Record "Purchase line";
        lPurchRcptline: Record "Purch. Rcpt. line";
        lPurchHeader: Record "Purchase Header";
        lJobPlanningline: Record "Job Planning line";
    BEGIN
        lVendor.GET(pRec."Pay-to Vendor No.");
        if licPartner.GET(lVendor."IC Partner Code") THEN BEGIN
            lPurchHeader.GET(lPurchHeader."Document Type"::Order, pRec."Order No.");
            pRec."Nº Proyecto" := lPurchHeader."Nº Proyecto";
            pRec.Modify();
            ltEmpresa := licPartner."Inbox Details";
            lPurchRcptline2.SETRANGE(lPurchRcptline2."Document No.", pRec."No.");
            lPurchRcptline2.SETFILTER(lPurchRcptline2.Type, '<>%1', 0);
            if lPurchRcptline2.FINDFIRST THEN
                REPEAT
                    EXIT;
                    lPurchline.GET(lPurchline."Document Type"::Order, lPurchRcptline2."Order No.", lPurchRcptline2."line No.");
                    lSalesInvoiceline.CHANGECOMPANY(ltEmpresa);
                    //lSalesInvoiceline.SETRANGE(lSalesInvoiceline."Document No.","Vendor Invoice No.");
                    lSalesInvoiceline.SETRANGE(lSalesInvoiceline."No linea proyecto", lPurchline."linea de proyecto");
                    if lSalesInvoiceline.FINDFIRST THEN BEGIN
                        REPEAT
                            if lSalesInvoiceline.Type = lSalesInvoiceline.Type::Resource THEN BEGIN
                                lPurchRcptline2."Fecha inicial recurso" := lSalesInvoiceline."Fecha inicial recurso";
                                lPurchRcptline2."Fecha final recurso" := lSalesInvoiceline."Fecha final recurso";
                                lPurchRcptline2.Recurso := lSalesInvoiceline."No.";
                            END;
                            lPurchRcptline2."Empresa Origen" := ltEmpresa;
                            lPurchRcptline2."Proyecto Origen" := lSalesInvoiceline."Job No.";
                            lPurchRcptline2."linea de proyecto" := lSalesInvoiceline."No linea proyecto";
                            lPurchRcptline2.MODIFY;

                        UNTIL lSalesInvoiceline.NEXT = 0;

                    END;
                UNTIL lPurchRcptline2.NEXT = 0;
        END ELSE BEGIN
            lPurchRcptline2.SETRANGE(lPurchRcptline2."Document No.", pRec."No.");
            lPurchRcptline2.SETFILTER(lPurchRcptline2.Type, '<>%1', 0);
            lPurchHeader.GET(lPurchHeader."Document Type"::Order, pRec."Order No.");
            pRec."Nº Proyecto" := lPurchHeader."Nº Proyecto";
            pRec.Modify();
            if lPurchRcptline2.FINDFIRST THEN
                REPEAT
                    lPurchline.GET(lPurchline."Document Type"::Order, lPurchRcptline2."Order No.", lPurchRcptline2."line No.");
                    lPurchRcptline2."Job No." := lPurchline."Job No.";
                    lPurchRcptline2."linea de proyecto" := lPurchline."linea de proyecto";
                    if lPurchRcptline2."Job No." = '' THEN BEGIN
                        lPurchHeader.GET(lPurchHeader."Document Type"::Order, lPurchline."Document No.");
                        lPurchRcptline2."Job No." := lPurchHeader."Nº Proyecto";
                    END;
                    if lPurchRcptline2."linea de proyecto" = 0 THEN BEGIN
                        lJobPlanningline.SETRANGE(lJobPlanningline."Job No.", lPurchRcptline2."Job No.");
                        lJobPlanningline.SETRANGE(lJobPlanningline."No.", lPurchRcptline2."No.");
                        if lJobPlanningline.FINDFIRST THEN BEGIN
                            lPurchRcptline2."linea de proyecto" := lJobPlanningline."line No.";
                        END;
                    END;
                    lPurchRcptline2.MODIFY;
                UNTIL lPurchRcptline2.NEXT = 0;
        END;
    END;

    internal procedure Finalizar(var pRec: Record "Purch. Rcpt. Header")
    BEGIN
        pRec.Finalizado := NOT pRec.Finalizado;
        pRec.MODIFY;
    END;
    //Crear un procedimiento interno para descontabilizar el albarán


    internal procedure DescontablilizarAlbAlb(var pRec: Record "Purch. Rcpt. Header")
    Var
        lPurchRcptHdr: Record "Purch. Rcpt. Header";
        lPurchRcptline: Record "Purch. Rcpt. line";
        lPurchline: Record "Purchase line";
        lcContabAlb: Codeunit ContabAlb;
    BEGIN

        lPurchRcptHdr.GET(pRec."No.");
        //if lPurchRcptHdr.FINDFIRST THEN REPEAT
        lPurchRcptline.SETRANGE(lPurchRcptline."Document No.", lPurchRcptHdr."No.");
        if lPurchRcptline.FINDFIRST THEN
            REPEAT
                lPurchRcptline."Qty. Rcd. Not Invoiced" := lPurchRcptline.Quantity;
                lPurchRcptline."Quantity Invoiced" := 0;
                lPurchRcptline."Qty. Invoiced (Base)" := 0;
                if lPurchline.GET(lPurchline."Document Type"::Order, lPurchRcptline."Order No.", lPurchRcptline."Order line No.") THEN BEGIN
                    lPurchline."Qty. to Invoice" := lPurchline.Quantity;
                    lPurchline."Qty. Rcd. Not Invoiced" := lPurchline.Quantity;
                    lPurchline."Amt. Rcd. Not Invoiced" := lPurchline.Amount;
                    lPurchline."Quantity Invoiced" := 0;
                    lPurchline."Qty. to Invoice (Base)" := 0;
                    lPurchline."Qty. Rcd. Not Invoiced (Base)" := lPurchline."Quantity Received";
                    lPurchline."Qty. Invoiced (Base)" := 0;
                    lPurchline.MODIFY;
                END;
                lPurchRcptline.MODIFY;
            UNTIL lPurchRcptline.NEXT = 0;
        CLEAR(lcContabAlb);
        lcContabAlb.DesContabilizarFacturasContra(lPurchRcptHdr);

        lPurchRcptHdr.Facturado := FALSE;
        lPurchRcptHdr.Contabilizado := TRUE;
        lPurchRcptHdr.MODIFY;
    END;

    internal procedure AjustarAlbaran(var pRec: Record "Purch. Rcpt. Header"; pdeFacturado2: Decimal; pdeFacturado: Decimal)
    Var
        lGenJnlline: Record "Gen. Journal line";
        lGlEntry: Record "G/L Entry";
        lCcuenta: Text[30];
        lCDim1: Code[20];
        lCDim2: Code[20];
        //rDefDim : Record 352;
        //TempDocDim : TEMPORARY Record 357;
        //TempJnllineDim : TEMPORARY Record 356;
        lcDimMgt: Codeunit DimensionManagement;
        lcGenJnlPostline: Codeunit "Gen. Jnl.-Post line";
        lDeprBook: Record "Depreciation Book";
        lCcuenta2: Text[30];
        lCDim3: Code[20];
        lCDim4: Code[20];
        lCDim5: Code[20];
        lCDim: Integer;
        llRevisarAlbarán: Label 'Revise el albarán, no se a que lcuenta contabilizarlo, no encuentro una lcuenta de ';
        llGasto: Label 'gasto';
        llfpr: Label 'fpr';
    BEGIN

        lGenJnlline.INIT;
        if DATE2DMY(pRec."Posting Date", 3) < DATE2DMY(WORKDATE, 3) THEN
            lGenJnlline."Posting Date" := WORKDATE
        ELSE
            lGenJnlline."Posting Date" := pRec."Posting Date";
        lGenJnlline."Document Date" := pRec."Document Date";
        lGenJnlline.Description := COPYSTR(pRec."Posting Description", 1, MAXSTRLEN(lGenJnlline.Description));
        //lGenJnlline.Description := "Posting Description";
        lGenJnlline."Reason Code" := pRec."Reason Code";
        lGenJnlline."Document Type" := lGenJnlline."Document Type"::Receipt;
        lGenJnlline."Document No." := pRec."No.";
        lGenJnlline."Tax Area Code" := pRec."No.";
        lGenJnlline."External Document No." := pRec."Vendor Shipment No.";
        lGlEntry.SETCURRENTKEY(lGlEntry."Document No.");
        lGlEntry.SETRANGE(lGlEntry."Document No.", pRec."No.");
        lCcuenta := '';
        if lGlEntry.FINDFIRST THEN
            REPEAT
                if COPYSTR(lGlEntry."G/L Account No.", 1, 1) = '6' THEN BEGIN
                    lCcuenta := lGlEntry."G/L Account No.";
                    lCDim1 := lGlEntry."Global Dimension 1 Code";
                    lCDim2 := lGlEntry."Global Dimension 2 Code";
                    lCDim3 := lGlEntry."Global Dimension 3 Code";
                    lCDim4 := lGlEntry."Global Dimension 4 Code";
                    lCDim5 := lGlEntry."Global Dimension 5 Code";
                    lCDim := lGlEntry."Dimension Set ID";
                END;
                if (COPYSTR(lGlEntry."G/L Account No.", 1, 4) = '4009') OR (COPYSTR(lGlEntry."G/L Account No.", 1, 4) = '4109') THEN
                    lCcuenta2 := lGlEntry."G/L Account No.";
            UNTIL lGlEntry.NEXT = 0;
        if lCcuenta = '' THEN ERROR("llRevisarAlbarán" + "llgasto");
        if lCcuenta2 = '' THEN ERROR("llRevisarAlbarán" + "llfpr");
        lGenJnlline."Account No." := lCcuenta;
        lGenJnlline."System-Created Entry" := TRUE;
        lGenJnlline.Amount := pdeFacturado2 - pdeFacturado;
        lGenJnlline."Source Currency Code" := pRec."Currency Code";
        lGenJnlline."Source Currency Amount" := lGenJnlline.Amount;
        lGenJnlline.Correction := pRec.Correction;
        lGenJnlline."Gen. Posting Type" := lGenJnlline."Gen. Posting Type"::" ";
        lGenJnlline."Gen. Bus. Posting Group" := '';//InvPostingBuffer[1]."Gen. Bus. Posting Group";
        lGenJnlline."Gen. Prod. Posting Group" := '';// InvPostingBuffer[1]."Gen. Prod. Posting Group";
        lGenJnlline."VAT Bus. Posting Group" := '';//InvPostingBuffer[1]."VAT Bus. Posting Group";
        lGenJnlline."VAT Prod. Posting Group" := '';//InvPostingBuffer[1]."VAT Prod. Posting Group";
        lGenJnlline."Tax Area Code" := '';
        lGenJnlline."Tax liable" := FALSE;
        lGenJnlline."Tax Group Code" := '';
        lGenJnlline."Use Tax" := FALSE;
        lGenJnlline.Quantity := 1;
        lGenJnlline."VAT Calculation Type" := lGenJnlline."VAT Calculation Type"::"Normal VAT";
        lGenJnlline."VAT Base Amount" := 0;
        lGenJnlline."VAT Base Discount %" := pRec."VAT Base Discount %";
        lGenJnlline."Source Curr. VAT Base Amount" := 0;
        lGenJnlline."VAT Amount" := 0;
        lGenJnlline."Source Curr. VAT Amount" := 0;
        lGenJnlline."VAT Difference" := 0;
        lGenJnlline."VAT Posting" := lGenJnlline."VAT Posting"::"Manual VAT Entry";
        lGenJnlline."Shortcut Dimension 1 Code" := lCDim1;
        lGenJnlline."Shortcut Dimension 2 Code" := lCDim2;
        lGenJnlline."Shortcut Dimension 3 Code" := lCDim3;
        lGenJnlline."Shortcut Dimension 4 Code" := lCDim4;
        lGenJnlline."Shortcut Dimension 5 Code" := lCDim5;
        lGenJnlline."Dimension Set ID" := lCDim;
        lGenJnlline."Job No." := lGlEntry."Job No.";
        lGenJnlline."Source Code" := lGlEntry."Source Code";
        lGenJnlline."Sell-to/Buy-from No." := pRec."Buy-from Vendor No.";
        lGenJnlline."Bill-to/Pay-to No." := pRec."Pay-to Vendor No.";
        lGenJnlline."Country/Region Code" := pRec."VAT Country/Region Code";
        lGenJnlline."VAT Registration No." := pRec."VAT Registration No.";
        lGenJnlline."Source Type" := lGenJnlline."Source Type"::Vendor;
        lGenJnlline."Source No." := pRec."Pay-to Vendor No.";
        lGenJnlline."Posting No. Series" := '';
        lGenJnlline."IC Partner Code" := '';//"Pay-to IC Partner Code";
        lGenJnlline."Ship-to/Order Address Code" := pRec."Order Address Code";
        lGenJnlline."Bal. Account No." := lCcuenta2;
        lGenJnlline."Payment Terms Code" := pRec."Payment Terms Code";
        lGenJnlline."Payment Method Code" := pRec."Payment Method Code";

        lGenJnlline."Generate AutoInvoices" := FALSE;//"Generate Autoinvoices" OR "Generate Autocredit Memo";
        lGenJnlline."AutoDoc. No." := '';
        lcGenJnlPostline.RunWithCheck(lGenJnlline);


        MESSAGE('Se ha contabilizado el albarán %1 con fecha %2', pRec."No.",
            FORMAT(pRec."Posting Date", 0, '<Day,2>/<Month,2>/<Year>'));
        pRec.Contabilizado := TRUE;
        pRec.MODIFY;
    END;

    internal procedure TrasladaDimensionesPed(var pRec: Record "Purch. Rcpt. Header")
    Var
        lGlEntry: Record "G/L Entry";
        lPurchHeader: Record "Purchase Header";

    BEGIN
        If lPurchHeader.Get(lPurchHeader."Document Type"::Order, pRec."Order No.") Then begin
            pRec."Shortcut Dimension 1 Code" := lPurchHeader."Shortcut Dimension 1 Code";
            pRec."Shortcut Dimension 2 Code" := lPurchHeader."Shortcut Dimension 2 Code";
            pRec."Shortcut Dimension 3 Code" := lPurchHeader."Shortcut Dimension 3 Code";
            pRec."Shortcut Dimension 4 Code" := lPurchHeader."Shortcut Dimension 4 Code";
            pRec."Shortcut Dimension 5 Code" := lPurchHeader."Shortcut Dimension 5 Code";
            pRec."Dimension Set ID" := lPurchHeader."Dimension Set ID";
            pRec.Modify();
        end;
    END;



    internal procedure TrasladaDimensionesAlb(var pRec: Record "Purch. Rcpt. Header")
    Var
        lGlEntry: Record "G/L Entry";
        lPurchRcptline: Record "Purch. Rcpt. line";
        lPurchHeader: Record "Purchase Header";
        lPurchline: Record "Purchase line";
        lCRecu: Code[20];
        lJobPlanningline: Record "Job Planning line";
        lResource: Record Resource;

    BEGIN
        lPurchRcptline.SETRANGE(lPurchRcptline."Document No.", pRec."No.");
        lPurchRcptline.SETRANGE(lPurchRcptline.Type, lPurchRcptline.Type::Resource);
        if NOT lPurchRcptline.FINDFIRST THEN BEGIN
            lPurchRcptline.SETRANGE(lPurchRcptline.Type, lPurchRcptline.Type::"G/L Account");
            lPurchRcptline.FINDFIRST;
            lPurchHeader.GET(lPurchHeader."Document Type"::Order, lPurchRcptline."Order No.");
            lPurchline.GET(lPurchline."Document Type"::Order, lPurchRcptline."Order No.", lPurchRcptline."Order line No.");
            lJobPlanningline.SETRANGE(lJobPlanningline."Job No.", lPurchHeader."Nº Proyecto");
            lJobPlanningline.SETRANGE(lJobPlanningline.Type, lJobPlanningline.Type::Resource);
            if lPurchline."linea de proyecto" <> 0 THEN
                lJobPlanningline.SETRANGE(lJobPlanningline."line No.", lPurchline."linea de proyecto");
            if lJobPlanningline.FINDFIRST THEN BEGIN
                lCRecu := lJobPlanningline."No.";
                if Not lResource.Get(lCRecu) Then lResource.Init();
                lPurchRcptline."Shortcut Dimension 1 Code" := lResource."Global Dimension 1 Code";
                lPurchRcptline."Shortcut Dimension 2 Code" := lResource."Global Dimension 2 Code";
                lPurchRcptline."Shortcut Dimension 3 Code" := lResource."Global Dimension 3 Code";
                lPurchRcptline."Shortcut Dimension 4 Code" := lResource."Global Dimension 4 Code";
                lPurchRcptline."Shortcut Dimension 5 Code" := lResource."Global Dimension 5 Code";
                lPurchRcptline."Dimension Set ID" := gCControl.GetDefaultDimID2(lPurchRcptline."Shortcut Dimension 1 Code", lPurchRcptline."Shortcut Dimension 2 Code",
                lPurchRcptline."Shortcut Dimension 3 Code", lPurchRcptline."Shortcut Dimension 4 Code", lPurchRcptline."Shortcut Dimension 5 Code");
                lPurchRcptline.Modify();
                lGlEntry.SETCURRENTKEY(lGlEntry."Document No.");
                lGlEntry.SETRANGE(lGlEntry."Document Type", lGlEntry."Document Type"::Receipt);
                lGlEntry.SETRANGE(lGlEntry."Document No.", pRec."No.");
                lGlEntry.SETFILTER(lGlEntry."G/L Account No.", '%1', '600*');
                if lGlEntry.FINDFIRST THEN
                    REPEAT
                        lGlEntry."Global Dimension 1 Code" := lPurchRcptline."Shortcut Dimension 1 Code";
                        lGlEntry."Global Dimension 2 Code" := lPurchRcptline."Shortcut Dimension 2 Code";
                        lGlEntry."Shortcut Dimension 3 Code" := lPurchRcptline."Shortcut Dimension 3 Code";
                        lGlEntry."Shortcut Dimension 4 Code" := lPurchRcptline."Shortcut Dimension 4 Code";
                        lGlEntry."Shortcut Dimension 5 Code" := lPurchRcptline."Shortcut Dimension 5 Code";
                        lGlEntry."Dimension Set Id" := lPurchRcptline."Dimension Set ID";
                        lGlEntry.Modify();
                    UNTIL lGlEntry.NEXT = 0;
            END;
        END ELSE begin
            REPEAT
                if Not lResource.Get(lPurchRcptline."No.") Then lResource.Init();
                lPurchRcptline."Shortcut Dimension 1 Code" := lResource."Global Dimension 1 Code";
                lPurchRcptline."Shortcut Dimension 2 Code" := lResource."Global Dimension 2 Code";
                lPurchRcptline."Shortcut Dimension 3 Code" := lResource."Global Dimension 3 Code";
                lPurchRcptline."Shortcut Dimension 4 Code" := lResource."Global Dimension 4 Code";
                lPurchRcptline."Shortcut Dimension 5 Code" := lResource."Global Dimension 5 Code";
                lPurchRcptline."Dimension Set ID" := gCControl.GetDefaultDimID2(lPurchRcptline."Shortcut Dimension 1 Code", lPurchRcptline."Shortcut Dimension 2 Code",
                lPurchRcptline."Shortcut Dimension 3 Code", lPurchRcptline."Shortcut Dimension 4 Code", lPurchRcptline."Shortcut Dimension 5 Code");
                lPurchRcptline.Modify();
                lGlEntry.SETCURRENTKEY(lGlEntry."Document No.");
                lGlEntry.SETRANGE(lGlEntry."Document Type", lGlEntry."Document Type"::Receipt);
                lGlEntry.SETRANGE(lGlEntry."Document No.", pRec."No.");
                lGlEntry.SETFILTER(lGlEntry."G/L Account No.", '%1', '600*');


            UNTIL lPurchRcptline.NEXT = 0;
            lGlEntry.SETCURRENTKEY(lGlEntry."Document No.");
            lGlEntry.SETRANGE(lGlEntry."Document Type", lGlEntry."Document Type"::Receipt);
            lGlEntry.SETRANGE(lGlEntry."Document No.", pRec."No.");
            lGlEntry.SETFILTER(lGlEntry."G/L Account No.", '%1', '600*');
            if lGlEntry.FINDFIRST THEN
                REPEAT
                    lGlEntry."Global Dimension 1 Code" := lPurchRcptline."Shortcut Dimension 1 Code";
                    lGlEntry."Global Dimension 2 Code" := lPurchRcptline."Shortcut Dimension 2 Code";
                    lGlEntry."Shortcut Dimension 3 Code" := lPurchRcptline."Shortcut Dimension 3 Code";
                    lGlEntry."Shortcut Dimension 4 Code" := lPurchRcptline."Shortcut Dimension 4 Code";
                    lGlEntry."Shortcut Dimension 5 Code" := lPurchRcptline."Shortcut Dimension 5 Code";
                    lGlEntry."Dimension Set Id" := lPurchRcptline."Dimension Set ID";
                    lGlEntry.Modify();
                UNTIL lGlEntry.NEXT = 0;
        END;
    END;

    internal procedure DesmarcarAsientoProv(var pRec: Record "Purch. Rcpt. Header")
    Var
        lcContabAlb: Codeunit ContabAlb;
        lPurchRcptHdr: Record "Purch. Rcpt. Header";
        lPurchRcptline: Record "Purch. Rcpt. line";
        lPurchline: Record "Purchase line";
        lGlEntry: Record "G/L Entry";
        lDHasta: Date;
        liAsiento: Integer;
        lcGenJnlcheckline: Codeunit 11;
        liEntryNoDesde: Integer;
        liEntryNoHasta: Integer;
        lReverSalEntry: Record "Reversal Entry";
        lcCalculo: Record "Calculo Albaranes";
    BEGIN

        lPurchRcptHdr.GET(pRec."No.");
        //if lPurchRcptHdr.FINDFIRST THEN REPEAT
        lPurchRcptline.SETRANGE(lPurchRcptline."Document No.", lPurchRcptHdr."No.");
        if lPurchRcptline.FINDFIRST THEN
            REPEAT
                lPurchRcptline."Qty. Rcd. Not Invoiced" := lPurchRcptline.Quantity;
                lPurchRcptline."Quantity Invoiced" := 0;
                lPurchRcptline."Qty. Invoiced (Base)" := 0;
                if lPurchline.GET(lPurchline."Document Type"::Order, lPurchRcptline."Order No.", lPurchRcptline."Order line No.") THEN BEGIN
                    lPurchline."Qty. to Invoice" := lPurchline.Quantity;
                    lPurchline."Qty. Rcd. Not Invoiced" := lPurchline.Quantity;
                    lPurchline."Amt. Rcd. Not Invoiced" := lPurchline.Amount;
                    lPurchline."Quantity Invoiced" := 0;
                    lPurchline."Qty. to Invoice (Base)" := 0;
                    lPurchline."Qty. Rcd. Not Invoiced (Base)" := lPurchline."Quantity Received";
                    lPurchline."Qty. Invoiced (Base)" := 0;
                    lPurchline.MODIFY;
                END;
                lPurchRcptline.MODIFY;
            UNTIL lPurchRcptline.NEXT = 0;
        CLEAR(lcContabAlb);
        lGlEntry.SETCURRENTKEY(lGlEntry."Transaction No.");
        lGlEntry.SETRANGE("Document No.", pRec."No.");
        lGlEntry.SETRANGE("Document Type", lGlEntry."Document Type"::Bill);
        lGlEntry.FINDLAST;
        lDHasta := lGlEntry."Posting Date";
        liAsiento := lGlEntry."Transaction No.";
        If Not lcGenJnlcheckline.DateNotAllowed(lDHasta) Then
            lcContabAlb.DesContabilizarFacAlbaranes(lPurchRcptHdr)
        else begin
            lGlEntry.SETCURRENTKEY(lGlEntry."Transaction No.");
            lGlEntry.SETRANGE("Transaction No.", liAsiento);
            lGlEntry.FINDLAST;
            liEntryNoHasta := lGlEntry."Entry No.";
            lGlEntry.FindFirst();
            liEntryNoDesde := lGlEntry."Entry No.";
            lReverSalEntry.ReverseAlbaran(lGlEntry."Transaction No.", liEntryNoDesde, liEntryNoHasta);

        end;
        if lcCalculo.Get(pRec."No.") Then Begin lcCalculo.Calculado := False; lcCalculo.Modify(); End;


        lPurchRcptHdr.Facturado := FALSE;
        lPurchRcptHdr.Contabilizado := TRUE;
        lPurchRcptHdr.MODIFY;
    END;

    internal procedure ContabilizarAsientoProv(var pRec: Record "Purch. Rcpt. Header")
    Var
        lcContabAlb: Codeunit ContabAlb;
        lPurchRcptHdr: Record "Purch. Rcpt. Header";
        lPurchRcptline: Record "Purch. Rcpt. line";
        lPurchline: Record "Purchase line";
    BEGIN
        CLEAR(lcContabAlb);
        lcContabAlb.ContabilizarFacAlbaranes(pRec);

        lPurchRcptHdr.GET(pRec."No.");
        //if lPurchRcptHdr.FINDFIRST THEN REPEAT
        lPurchRcptline.SETRANGE(lPurchRcptline."Document No.", lPurchRcptHdr."No.");
        if lPurchRcptline.FINDFIRST THEN
            REPEAT
                lPurchRcptline."Qty. Rcd. Not Invoiced" := 0;
                lPurchRcptline."Quantity Invoiced" := lPurchRcptline.Quantity;
                lPurchRcptline."Qty. Invoiced (Base)" := lPurchRcptline."Quantity (Base)";
                if lPurchline.GET(lPurchline."Document Type"::Order, lPurchRcptline."Order No.", lPurchRcptline."Order line No.") THEN BEGIN
                    lPurchline."Qty. to Invoice" := lPurchline."Qty. to Receive";
                    lPurchline."Qty. Rcd. Not Invoiced" := 0;
                    lPurchline."Amt. Rcd. Not Invoiced" := 0;
                    lPurchline."Quantity Invoiced" := lPurchRcptline."Quantity Invoiced";
                    lPurchline."Qty. to Invoice (Base)" := 0;
                    lPurchline."Qty. Rcd. Not Invoiced (Base)" := 0;
                    lPurchline."Qty. Invoiced (Base)" := lPurchRcptline."Qty. Invoiced (Base)";
                    lPurchline.MODIFY;
                END;
                lPurchRcptline.MODIFY;
            UNTIL lPurchRcptline.NEXT = 0;
        lPurchRcptHdr.Facturado := TRUE;
        lPurchRcptHdr.Contabilizado := TRUE;
        lPurchRcptHdr.MODIFY;
        //UNTIL lPurchRcptHdr.NEXT=0;
    END;

    internal procedure DesmMarCarComoFacurado(var pRec: Record "Purch. Rcpt. Header")
    Var
        lPurchRcptHdr: Record "Purch. Rcpt. Header";
        lPurchRcptline: Record "Purch. Rcpt. line";
        lPurchline: Record "Purchase line";
    BEGIN
        lPurchRcptHdr.GET(pRec."No.");
        lPurchRcptline.SETRANGE(lPurchRcptline."Document No.", lPurchRcptHdr."No.");
        if lPurchRcptline.FINDFIRST THEN
            REPEAT
                lPurchRcptline."Qty. Rcd. Not Invoiced" := lPurchRcptline.Quantity;
                lPurchRcptline."Quantity Invoiced" := 0;
                lPurchRcptline."Qty. Invoiced (Base)" := 0;
                lPurchRcptline.MODIFY;
            UNTIL lPurchRcptline.NEXT = 0;
        lPurchRcptHdr.Facturado := FALSE;
        lPurchRcptHdr.Contabilizado := TRUE;
        lPurchRcptHdr.MODIFY;
    END;

    internal procedure MarcarComoContabilizado(var pRec: record "Purch. Rcpt. Header"; pMarca: Boolean)
    Begin
        pRec.Contabilizado := pMarca;
        pRec.Modify();
    End;

    internal procedure ConvertirEnAlbaran(pRec: Record "Return Shipment Header")
    var
        lPurchReciptHeader: Record "Purch. Rcpt. Header";
        lPurchReciptline: Record "Purch. Rcpt. line";
        lReturShipmentline: Record "Return Shipment line";
        lPurchHeader: Record "Purchase Header";
        lPurchline: Record "Purchase line";
        lPurchHeaderN: Record "Purchase Header";
        lPurchlineN: Record "Purchase line";
    begin
        lPurchReciptHeader.TransferFields(pRec);
        lPurchReciptHeader."Order No." := pRec."Return Order No.";
        lPurchReciptHeader.Insert();
        lReturShipmentline.SetRange("Document No.", pRec."No.");
        if lReturShipmentline.FindSet then
            repeat
                lPurchReciptline.TransferFields(lReturShipmentline);
                lPurchReciptline.Quantity := -lPurchReciptline.Quantity;
                lPurchReciptline."Quantity (Base)" := -lPurchReciptline."Quantity (Base)";
                lPurchReciptline."Qty. Rcd. Not Invoiced" := -lPurchReciptline."Qty. Rcd. Not Invoiced";
                lPurchReciptline."Quantity Invoiced" := -lPurchReciptline."Quantity Invoiced";
                lPurchReciptline."Qty. Invoiced (Base)" := -lPurchReciptline."Qty. Invoiced (Base)";
                lPurchReciptline.Amount := -lPurchReciptline.Amount;
                lPurchReciptline."Amount Including VAT" := -lPurchReciptline."Amount Including VAT";
                lPurchReciptline."Order No." := lReturShipmentline."Return Order No.";
                lPurchReciptline."Order line No." := lReturShipmentline."Return Order line No.";
                lPurchReciptline.Insert;
                lReturShipmentline.Delete;
            until lReturShipmentline.Next = 0;
        lPurchHeader.GET(lPurchHeader."Document Type"::"Return Order", pRec."Return Order No.");
        lPurchHeaderN := lPurchHeader;
        lPurchHeaderN."Document Type" := lPurchHeaderN."Document Type"::Order;
        lPurchHeaderN.Insert;
        lPurchHeader.Delete();
        lPurchline.SetRange("Document No.", pRec."Return Order No.");
        if lPurchline.FindSet then
            repeat
                lPurchlineN := lPurchline;
                lPurchlineN."Document Type" := lPurchHeaderN."Document Type"::Order;

                lPurchlineN."Qty. Assigned" := -lPurchlineN."Qty. Assigned";

                lPurchlineN."Qty. to Receive (Base)" := -lPurchlineN."Return Qty. to Ship (Base)";
                lPurchlineN."Qty. to Receive" := -lPurchlineN."Return Qty. to Ship";
                lPurchlineN."Return Qty. to Ship (Base)" := 0;
                lPurchlineN."Return Qty. to Ship" := 0;

                lPurchlineN."Qty. Rcd. Not Invoiced" := -lPurchlineN."Return Qty. Shipped Not Invd.";
                lPurchlineN."Qty. Rcd. Not Invoiced (Base)" := -lPurchlineN."Ret. Qty. Shpd Not Invd.(Base)";
                lPurchlineN."Ret. Qty. Shpd Not Invd.(Base)" := 0;
                lPurchlineN."Return Qty. Shipped Not Invd." := 0;

                lPurchlineN."Quantity Received" := -lPurchlineN."Return Qty. Shipped";
                lPurchlineN."Qty. Received (Base)" := -lPurchlineN."Return Qty. Shipped (Base)";
                lPurchlineN."Return Qty. Shipped (Base)" := 0;
                lPurchlineN."Return Qty. Shipped" := 0;


                lPurchlineN."Qty. to Invoice" := -lPurchlineN."Qty. to Invoice";
                lPurchlineN."Qty. to Invoice (Base)" := -lPurchlineN."Qty. to Invoice (Base)";

                lPurchlineN."Quantity Invoiced" := -lPurchlineN."Quantity Invoiced";
                lPurchlineN."Qty. Invoiced (Base)" := -lPurchlineN."Qty. Invoiced (Base)";


                lPurchlineN.Quantity := -lPurchlineN.Quantity;
                lPurchlineN."Quantity (Base)" := -lPurchlineN."Quantity (Base)";

                lPurchlineN."Amount" := -lPurchlineN."Amount";
                lPurchlineN."Amount Including VAT" := -lPurchlineN."Amount Including VAT";
                lPurchlineN."line Amount" := -lPurchlineN."line Amount";
                lPurchlineN."A. Rcd. Not Inv. Ex. VAT (lcY)" := -lPurchlineN."A. Rcd. Not Inv. Ex. VAT (lcY)";
                lPurchlineN."A. Rcd. Not Inv. Ex. VAT (lcY)" := 0;
                lPurchlineN."Amt. Rcd. Not Invoiced" := -lPurchlineN."Return Shpd. Not Invd.";
                lPurchlineN."Amt. Rcd. Not Invoiced (lcY)" := -lPurchlineN."Return Shpd. Not Invd. (lcY)";
                lPurchlineN."Return Shpd. Not Invd." := 0;
                lPurchlineN."Return Shpd. Not Invd. (lcY)" := 0;
                lPurchlineN.Insert;
                lPurchline.Delete;
            until lPurchline.Next = 0;
        pRec.Delete();
    end;

    internal procedure RecalcularFechas(pRec: Record "Purch. Rcpt. line")
    var
        lPurchline: Record "Purchase line";
    begin
        If lPurchline.Get(lPurchline."Document Type"::Order, pRec."Order No.", pRec."Order line No.") Then begin
            pRec."Fecha final recurso" := lPurchline."Fecha final recurso";
            pRec."Fecha inicial recurso" := lPurchline."Fecha inicial recurso";
            pRec.Modify();
        end;
    end;


}