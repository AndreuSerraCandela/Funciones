/// <summary>
/// Codeunit Utilitis (ID 7001112).
/// </summary>
codeunit 7001112 Utilitis
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
    tabledata 45 = rimd,
    tabledata 254 = rimd,
    tabledata 271 = rimd,
    tabledata 81 = rimd,
    tabledata 25 = rimd,
    tabledata 21 = rimd,
    tabledata 379 = rimd,
    tabledata 7000002 = rimd,
    tabledata 7000003 = rimd,
    tabledata 7000004 = rimd,
    tabledata "Closed Bill Group" = rimd,
    tabledata "Posted Bill Group" = rimd,
    tabledata "Return Shipment Header" = rimd,
    tabledata "Return Shipment Line" = rimd,
    tabledata 380 = rimd;

    var
        Procesos: Codeunit ControlProcesos;
        SourceDataDoesNotExistErr: Label 'Source data does not exist for %1: %2.', Comment = 'Source data doesn''t exist for G/L Account: 8210.';
        SourceDataDoesNotExistInfoErr: Label 'Source data does not exist in %1 for %2: %3.', Comment = 'Source data doesn''t exist in Vendor Ledger Entry for Document No.: PO000123.';
        SourceTypeNotSupportedErr: Label 'Source type is not supported.';
        DefaultTxt: Label 'Default';
        DummyDate: Date;
        CashFlowTxt: Label 'CashFlow';
        CashFlowForecastTxt: Label 'Cash Flow Forecast';
        CashFlowAbbreviationTxt: Label 'CF', Comment = 'Abbreviation of Cash Flow';
        UpdatingMsg: Label 'Updating Cash Flow Forecast...';
        JobQueueEntryDescTxt: Label 'Auto-created for updating of cash flow figures. Can be deleted if not used. Will be recreated when the feature is activated.';
        rField: Record 2000000041;
        VATPostingSetup: Record 325;
        Text004: Label 'FPR Albarán %1 - %2';
        Text006: Label 'Libro Alb. compra';
        Text007: Label 'Sección Alb. compra';
        Text008: Label 'El albarán %1 no se está contabilizando en su empresa fiscal (%2).';
        Text032: Label 'La combinación de dimensiones utilizada en %1 %2 está bloqueada. %3';
        Text033: Label 'La combinación de dimensiones utilizada en %1 %2, nº línea %3 está bloqueada. %4';
        Text034: Label 'Las dimensiones usadas en %1 %2 son inválidas %3';
        Text035: Label 'Las dim. usadas en %1 %2, no. Lín. %3 son inválidas %4';
        Text036: Label 'No se puede contabilizar un albarán si %1 es %2.';
        Text100: Label 'ALBARAN C';
        C: Label '''';
        wImporteTotal: Decimal;
        wImporteTotalDL: Decimal;
        wnAsiento: Integer;
        GenJnlPostLine: Codeunit 12;
        DimMgt: Codeunit 408;
        DimBufMgt: Codeunit 411;
        GenPostingSetup: Record 252;
        a: Integer;
        GenJnlLine: Record "Gen. Journal Line";
        TotalPurchLineLCY: Record 39;
        TotalPurchLine: Record 39;
        Currency: Record Currency;
        SalesTaxCalculate: Codeunit "Sales Tax Calculate";
        GlSetup: Record "General Ledger Setup";
        CurrExchRate: Record "Currency Exchange Rate";
        DiscountVATAmount: Decimal;
        SrcCode: Code[20];
        pPurchHeader: Record "Purchase Header";
        PurchSetup: Record "Purchases & Payables Setup";
        TempSalesLine: Record 37;
        TempSalesLineACY: Record 37;

        RoundingLineNo: Integer;
        RoundingLineInserted: Boolean;
        LastLineRetrieved: Boolean;
        Utilidades: Codeunit Utilitis;

    /// <summary>
    /// ArregloBanco.
    /// </summary>
    /// <param name="Num">Code[20].</param>
    procedure ArregloBanco(Num: Code[20])
    var
        r17: Record "G/L Entry";
        MovBanco: Record "Bank Account Ledger Entry";
        Banck: Record "Bank Account";
        Ventana: Dialog;
        a: Integer;
    begin

        Ventana.OPEN('#########1## de ###########2##');
        r17.SETCURRENTKEY(r17."G/L Account No.", r17."Posting Date");
        r17.SETRANGE(r17."G/L Account No.", Num);
        MovBanco.SETCURRENTKEY(MovBanco."Bank Account No.");
        MovBanco.SETRANGE(MovBanco."Bank Account No.", Num);
        MovBanco.DELETEALL;
        Ventana.UPDATE(2, r17.COUNT);
        if r17.FINDFIRST THEN
            REPEAT
                r17."Source Type" := r17."Source Type"::"Bank Account";
                r17."Source No." := Num;
                r17.MODIFY;
                a := a + 1;
                Ventana.UPDATE(1, a);
                if MovBanco.GET(r17."Entry No.") THEN BEGIN
                    MovBanco."Bank Account No." := r17."Source No.";
                    MovBanco.Amount := r17.Amount;
                    MovBanco."Remaining Amount" := r17.Amount;
                    MovBanco."Amount (LCY)" := r17.Amount;
                    MovBanco."Debit Amount" := r17."Debit Amount";
                    MovBanco."Credit Amount" := r17."Credit Amount";
                    MovBanco."Debit Amount (LCY)" := r17."Debit Amount";
                    MovBanco."Credit Amount (LCY)" := r17."Credit Amount";
                    if MovBanco.MODIFY THEN;

                END ELSE BEGIN
                    MovBanco.INIT;
                    MovBanco."Bank Account No." := r17."Source No.";
                    MovBanco."Posting Date" := r17."Posting Date";
                    MovBanco."Document Date" := r17."Document Date";
                    MovBanco."Document Type" := r17."Document Type";
                    MovBanco."Document No." := r17."Document No.";
                    MovBanco."External Document No." := r17."External Document No.";
                    MovBanco.Description := r17.Description;
                    MovBanco."Currency Code" := '';
                    Banck.GET(r17."Source No.");
                    MovBanco."Bank Acc. Posting Group" := Banck."Bank Acc. Posting Group";
                    MovBanco."Global Dimension 1 Code" := r17."Global Dimension 1 Code";
                    MovBanco."Global Dimension 2 Code" := r17."Global Dimension 2 Code";
                    MovBanco."Source Code" := r17."Source Code";
                    MovBanco."Journal Batch Name" := r17."Journal Batch Name";
                    MovBanco."Reason Code" := r17."Reason Code";
                    MovBanco."Entry No." := r17."Entry No.";
                    MovBanco."Transaction No." := r17."Transaction No.";
                    MovBanco."User ID" := USERID;
                    MovBanco."Bal. Account Type" := r17."Bal. Account Type";
                    MovBanco."Bal. Account No." := r17."Bal. Account No.";
                    MovBanco.Amount := r17.Amount;
                    MovBanco."Remaining Amount" := r17.Amount;
                    MovBanco."Amount (LCY)" := r17.Amount;
                    MovBanco."Debit Amount" := r17."Debit Amount";
                    MovBanco."Credit Amount" := r17."Credit Amount";
                    MovBanco."Debit Amount (LCY)" := r17."Debit Amount";
                    MovBanco."Credit Amount (LCY)" := r17."Credit Amount";
                    MovBanco.INSERT;
                END;
            UNTIL r17.NEXT = 0;
        Ventana.CLOSE;
    end;

    internal procedure MoveraOtroProyecto(var r17: Record "G/L Entry"; r15: Record Job)
    begin
        r17.MODIFYALL(r17."Job No.", r15."No.", TRUE);
    end;


    PROCEDURE MarcarComofacturado(No: Code[20])
    VAR
        rCab: Record "Purch. Rcpt. Header";
        rLin: Record "Purch. Rcpt. Line";
        r39: Record 39;
    BEGIN
        rCab.GET(No);
        //if rCab.FINDFIRST THEN REPEAT
        rLin.SETRANGE(rLin."Document No.", rCab."No.");
        if rLin.FINDFIRST THEN
            REPEAT
                rLin."Qty. Rcd. Not Invoiced" := 0;
                rLin."Quantity Invoiced" := rLin.Quantity;
                rLin."Qty. Invoiced (Base)" := rLin."Quantity (Base)";
                if r39.GET(r39."Document Type"::Order, rLin."Order No.", rLin."Order Line No.") THEN BEGIN
                    r39."Qty. to Invoice" := r39."Qty. to Receive";
                    r39."Qty. Rcd. Not Invoiced" := 0;
                    r39."Amt. Rcd. Not Invoiced" := 0;
                    r39."Quantity Invoiced" := rLin."Quantity Invoiced";
                    r39."Qty. to Invoice (Base)" := 0;
                    r39."Qty. Rcd. Not Invoiced (Base)" := 0;
                    r39."Qty. Invoiced (Base)" := rLin."Qty. Invoiced (Base)";
                    r39.MODIFY;
                END;
                rLin.MODIFY;
            UNTIL rLin.NEXT = 0;
    END;

    PROCEDURE MarcarComofacturadoDev(No: Code[20])
    VAR
        rCab: Record "Return Shipment Header";
        rLin: Record "Return Shipment Line";
        r39: Record 39;
    BEGIN
        rCab.GET(No);
        //if rCab.FINDFIRST THEN REPEAT

        rCab.Facturado := NOT rCab.Facturado;
        if rCab.Facturado THEN BEGIN
            rLin.SETRANGE(rLin."Document No.", rCab."No.");
            if rLin.FINDFIRST THEN
                REPEAT
                    rLin."Quantity Invoiced" := rLin.Quantity;
                    rLin."Qty. Invoiced (Base)" := rLin."Quantity (Base)";
                    rLin."Return Qty. Shipped Not Invd." := 0;
                    rLin.MODIFY;
                UNTIL rLin.NEXT = 0;
        END ELSE BEGIN
            rLin.SETRANGE(rLin."Document No.", rCab."No.");
            if rLin.FINDFIRST THEN
                REPEAT
                    rLin."Quantity Invoiced" := 0;
                    rLin."Qty. Invoiced (Base)" := 0;
                    rLin."Return Qty. Shipped Not Invd." := rLin.Quantity;
                    rLin.MODIFY;
                UNTIL rLin.NEXT = 0;

        END;
        rCab.MODIFY;
    END;

    internal procedure RevisaDp(Var Job: Record Job)
    var
        rLin5: Record "Job Planning Line";
    begin

        // FCL-24/02/04. Migración de 2.0. a 3.70.
        //Revisamos si se corresponde el tipo de línea con los datos entrados

        if ((Job."Global Dimension 1 Code" = '') OR (Job."Global Dimension 2 Code" = '')) THEN BEGIN
            CLEAR(rLin5);
            rLin5.RESET;
            rLin5.SETRANGE("Job No.", Job."No.");
            if rLin5.FIND('-') THEN
                REPEAT
                    if (Job."Global Dimension 1 Code" = '') THEN
                        rLin5.TESTFIELD("Shortcut Dimension 1 Code");
                    if (Job."Global Dimension 2 Code" = '') THEN
                        rLin5.TESTFIELD("Shortcut Dimension 2 Code");
                    Case rLin5."Crear pedidos" of
                        rLin5."Crear pedidos"::"De Compra Y De Venta":
                            begin
                                If (rLin5."Unit Price" = 0) and (rLin5."Precio Tarifa" = 0) then
                                    error('El precio de venta y el precio tarifa no pueden ser 0 si la línea es de compra y venta');
                                if (rLin5."Unit Cost" = 0) Then
                                    Error('El precio de compra no puede ser 0 si la línea es de compra y venta');
                            end;
                        rLin5."Crear pedidos"::"De Compra":
                            if (rLin5."Unit Cost" = 0) Then
                                Error('El precio de compra no puede ser 0 si la línea es de compra');
                        rLin5."Crear pedidos"::"De Venta":
                            if (rLin5."Unit Price" = 0) and (rLin5."Precio Tarifa" = 0) Then
                                Error('El precio de venta no puede ser 0 si la línea es de venta');
                    END;
                UNTIL rLin5.NEXT = 0;
        END;

    end;



    PROCEDURE ArchivePurchDocumentPer(VAR PurchHeader: Record 38);
    BEGIN
        StorePurchDocumentPer(PurchHeader, FALSE);
    END;

    /// <summary>
    /// StorePurchDocumentComments.
    /// </summary>
    /// <param name="DocType">Option.</param>
    /// <param name="DocNo">Code[20].</param>
    /// <param name="DocNoOccurrence">Integer.</param>
    /// <param name="VersionNo">Integer.</param>
    procedure StorePurchDocumentComments(DocType: Option; DocNo: Code[20]; DocNoOccurrence: Integer; VersionNo: Integer)
    var
        PurchCommentLine: Record "Purch. Comment Line";
        PurchCommentLineArch: Record "Purch. Comment Line Archive";
    begin
        PurchCommentLine.SetRange("Document Type", DocType);
        PurchCommentLine.SetRange("No.", DocNo);
        if PurchCommentLine.FindSet then
            repeat
                PurchCommentLineArch.Init();
                PurchCommentLineArch.TransferFields(PurchCommentLine);
                PurchCommentLineArch."Doc. No. Occurrence" := DocNoOccurrence;
                PurchCommentLineArch."Version No." := VersionNo;
                PurchCommentLineArch.Insert();
            until PurchCommentLine.Next = 0;
    end;

    PROCEDURE StorePurchDocumentPer(VAR PurchHeader: Record 38; InteractionExist: Boolean);
    VAR
        PurchLine: Record 39;
        PurchHeaderArchive: Record 5109;
        PurchLineArchive: Record 5110;
        PurchLineArchive2: Record 5110;
        Cant: Decimal;
        Grabar: Boolean;
        ArchiveManagement: Codeunit 5063;
    BEGIN
        PurchHeaderArchive.INIT;
        PurchHeaderArchive.TRANSFERFIELDS(PurchHeader);
        PurchHeaderArchive."Archived By" := USERID;
        PurchHeaderArchive."Date Archived" := WORKDATE;
        PurchHeaderArchive."Time Archived" := TIME;
        PurchHeaderArchive."Pedido Periodo" := TRUE;
        PurchHeaderArchive."Version No." := ArchiveManagement.GetNextVersionNo(
          DATABASE::"Purchase Header", PurchHeader."Document Type".AsInteger(), PurchHeader."No.", PurchHeader."Doc. No. Occurrence");
        PurchHeaderArchive."Interaction Exist" := InteractionExist;
        PurchHeaderArchive.INSERT;

        //   ArchiveManagement.StoreDocDim(
        //     DATABASE::"Purchase Header",PurchHeader."Document Type",
        //     PurchHeader."No.",0,PurchHeader."Doc. No. Occurrence",PurchHeaderArchive."Version No.",
        //      DATABASE::"Purchase Header Archive");

        StorePurchDocumentComments(
          PurchHeader."Document Type".AsInteger(), PurchHeader."No.",
          PurchHeader."Doc. No. Occurrence", PurchHeaderArchive."Version No.");

        PurchLine.SETRANGE("Document Type", PurchHeader."Document Type");
        PurchLine.SETRANGE("Document No.", PurchHeader."No.");
        Grabar := TRUE;
        if PurchLine.FINDSET THEN
            REPEAT
                WITH PurchLineArchive DO BEGIN
                    INIT;
                    TRANSFERFIELDS(PurchLine);
                    "Doc. No. Occurrence" := PurchHeader."Doc. No. Occurrence";
                    "Version No." := PurchHeaderArchive."Version No.";
                    "Pedido Periodo" := TRUE;
                    if PurchLine.Type.AsInteger() > 0 THEN BEGIN
                        Grabar := FALSE;
                        PurchLineArchive2.SETRANGE(PurchLineArchive2."Document Type", PurchHeaderArchive."Document Type");
                        PurchLineArchive2.SETRANGE(PurchLineArchive2."Document No.", PurchHeaderArchive."No.");
                        PurchLineArchive2.SETRANGE(PurchLineArchive2."Line No.", PurchLine."Line No.");
                        PurchLineArchive2.SETFILTER(PurchLineArchive2."Version No.", '<>%1', PurchHeaderArchive."Version No.");
                        Cant := 0;
                        if PurchLineArchive2.FINDFIRST THEN
                            REPEAT
                                Cant := Cant + PurchLineArchive2.Quantity;
                                PurchLineArchive.Quantity := PurchLine.Quantity - Cant;
                            UNTIL PurchLineArchive2.NEXT = 0;
                        if Cant <> PurchLine.Quantity THEN BEGIN
                            Grabar := TRUE;
                        END;
                    END;
                    if Grabar THEN BEGIN
                        INSERT;
                        //  StoreDocDim(
                        //    DATABASE::"Purchase Line",PurchLine."Document Type",PurchLine."Document No.",
                        //    PurchLine."Line No.",PurchHeader."Doc. No. Occurrence","Version No.",
                        //     DATABASE::"Purchase Line Archive");
                    END;
                END
            UNTIL PurchLine.NEXT = 0;
    END;

    Procedure ModificaFecha(var Rec: Record "Cartera Doc.")
    var
        Dialogo: Page "Date-Time Dialog";
    Begin
        Dialogo.SetDate(Rec."Due Date");
        if Dialogo.RunModal() in [Action::Cancel, Action::LookupCancel, Action::No, Action::None] Then error('Proceso Cancelado');
        Rec."Due Date" := Dialogo.GetDate();
        Rec.Modify();

    End;



    Procedure LiquidarFactura(var pGenJnlLine: Record "Gen. Journal Line"; var pCustLedgEntry: Record "Cust. Ledger Entry")
    var
        Importe2: decimal;
        rMovCliDet: record "Detailed Cust. Ledg. Entry";
        wNumMov: Integer;
        r21: Record 21;
        Importe: Decimal;

    Begin
        //$005. Grabo un movimiento detallado de cliente para que la factura quede liquidada.
        //Se trata de gestión de remesas sin factura. La factura se registra cuando se ha creado
        //y liquidado (no siempre) el efecto.
        pCustLedgEntry.CALCFIELDS("Remaining Amount", "Remaining Amt. (LCY)");
        Importe2 := pGenJnlLine.Amount;// pCustLedgEntry."Remaining Amount";

        WITH pGenJnlLine DO BEGIN
            rMovCliDet.RESET;
            if rMovCliDet.FINDLAST THEN BEGIN
                wNumMov := rMovCliDet."Entry No.";
            END
            ELSE BEGIN
                wNumMov := 0;
            END;
            r21.SETCURRENTKEY(r21."Nº Factura Borrador");
            r21.SETRANGE(r21."Nº Factura Borrador", pGenJnlLine."No. Borrador factura");
            r21.SETFILTER(r21."Entry No.", '<>%1', pCustLedgEntry."Entry No.");
            r21.SetRange("Customer No.", pCustLedgEntry."Customer No.");
            r21.SETFILTER("Remaining Amount", '<>%1', 0);
            if NOT r21.FINDLAST THEN EXIT;
            r21.CALCFIELDS("Remaining Amount", "Remaining Amt. (LCY)");
            Importe := -r21."Remaining Amount";
            if ABS(Importe2) < ABS(Importe) THEN BEGIN
                Importe := Importe2;
                Importe2 := pCustLedgEntry."Remaining Amt. (LCY)"
            END ELSE
                Importe2 := -r21."Remaining Amt. (LCY)";
            if "Source No." <> pCustLedgEntry."Customer No." THEN EXIT;
            rMovCliDet.INIT;
            rMovCliDet."Entry No." := wNumMov + 1;
            rMovCliDet."Cust. Ledger Entry No." := pCustLedgEntry."Entry No.";
            rMovCliDet."Entry Type" := rMovCliDet."Entry Type"::Application;
            rMovCliDet."Posting Date" := "Posting Date";
            rMovCliDet."Document Type" := "Document Type";
            rMovCliDet."Document No." := "Document No.";
            rMovCliDet.Amount := -Importe;
            rMovCliDet."Amount (LCY)" := -Importe2;
            rMovCliDet."Customer No." := "Account No.";
            rMovCliDet."Currency Code" := "Currency Code";
            rMovCliDet."User ID" := USERID;
            rMovCliDet."Source Code" := pCustLedgEntry."Source Code";
            rMovCliDet."Transaction No." := pCustLedgEntry."Transaction No.";
            rMovCliDet."Initial Entry Due Date" := "Due Date";
            rMovCliDet."Initial Entry Global Dim. 1" := "Shortcut Dimension 1 Code";
            rMovCliDet."Initial Entry Global Dim. 2" := "Shortcut Dimension 2 Code";
            //ASC
            rMovCliDet."Initial Entry Global Dim. 3" := "Shortcut Dimension 3 Code";
            rMovCliDet."Initial Entry Global Dim. 4" := "Shortcut Dimension 4 Code";
            rMovCliDet."Initial Entry Global Dim. 5" := "Shortcut Dimension 5 Code";

            rMovCliDet."Initial Document Type" := "Document Type";
            rMovCliDet."Applied Cust. Ledger Entry No." := r21."Entry No.";
            rMovCliDet.INSERT;
            rMovCliDet.INIT;
            rMovCliDet."Entry No." := wNumMov + 2;
            rMovCliDet."Cust. Ledger Entry No." := r21."Entry No.";
            rMovCliDet."Entry Type" := rMovCliDet."Entry Type"::Application;
            rMovCliDet."Posting Date" := "Posting Date";
            rMovCliDet."Document Type" := "Document Type";
            rMovCliDet."Document No." := r21."Document No.";
            // r21.CALCFIELDS(r21.Amount,r21."Amount (LCY)");
            rMovCliDet.Amount := Importe;
            rMovCliDet."Amount (LCY)" := Importe2;
            rMovCliDet."Customer No." := "Account No.";
            rMovCliDet."Currency Code" := "Currency Code";
            rMovCliDet."User ID" := USERID;
            rMovCliDet."Source Code" := r21."Source Code";
            rMovCliDet."Transaction No." := r21."Transaction No.";
            rMovCliDet."Initial Entry Due Date" := r21."Due Date";
            rMovCliDet."Initial Entry Global Dim. 1" := r21."Global Dimension 1 Code";
            rMovCliDet."Initial Entry Global Dim. 2" := r21."Global Dimension 2 Code";
            //ASC
            rMovCliDet."Initial Entry Global Dim. 3" := r21."Global Dimension 3 Code";
            rMovCliDet."Initial Entry Global Dim. 4" := r21."Global Dimension 4 Code";
            rMovCliDet."Initial Entry Global Dim. 5" := r21."Global Dimension 5 Code";

            rMovCliDet."Initial Document Type" := r21."Document Type";
            rMovCliDet."Applied Cust. Ledger Entry No." := pCustLedgEntry."Entry No.";
            rMovCliDet.INSERT;
        END;
    End;

    Procedure EsRemesa(pNumDoc: Code[20]): Boolean
    Var
        rRemReg: Record "Posted Bill Group";
    Begin
        //$004. Compruebo si la remesa tiene la marca de Remesa al descuento.
        EXIT(rRemReg.GET(pNumDoc));
    End;

    Procedure LiquidarFacturaCon(pGenJnlLine: Record "Gen. Journal Line"; pCustLedgEntry: Record "Cust. Ledger Entry")
    var
        Importe2: decimal;
        rMovCliDet: record "Detailed Cust. Ledg. Entry";
        wNumMov: Integer;
        r21: Record 21;
        Importe: Decimal;
        r112: Record 112;
        Salir: boolean;
    Begin
        //$005. Grabo un movimiento detallado de cliente para que la factura quede liquidada.
        //Se trata de gestión de remesas sin factura. La factura se registra cuando se ha creado
        //y liquidado (no siempre) el efecto.
        // Ojo Con los importes
        pCustLedgEntry.CALCFIELDS("Remaining Amount", "Remaining Amt. (LCY)");
        Importe2 := pCustLedgEntry."Remaining Amount";
        WITH GenJnlLine DO BEGIN
            rMovCliDet.RESET;
            if rMovCliDet.FINDLAST THEN BEGIN
                wNumMov := rMovCliDet."Entry No.";
            END
            ELSE BEGIN
                wNumMov := 0;
            END;
            if r112."Nº Contrato" = '' THEN EXIT;
            r112.GET(GenJnlLine."Document No.");
            r21.SETCURRENTKEY(r21."Nº Factura Borrador");
            r21.SETRANGE(r21."Applies-to ID", r112."Nº Contrato");
            r21.SETFILTER(r21."Entry No.", '<>%1', pCustLedgEntry."Entry No.");
            if NOT r21.FINDLAST THEN EXIT;
            if "Account No." <> pCustLedgEntry."Customer No." THEN EXIT;
            Salir := TRUE;
            if r21.FINDFIRST THEN
                REPEAT
                    r21.CALCFIELDS(r21."Remaining Amount", r21."Remaining Amt. (LCY)");
                    if r21."Remaining Amount" < 0 THEN Salir := FALSE;
                UNTIL (r21.NEXT = 0) OR (Salir = FALSE);
            if Salir THEN EXIT;
            Importe := r21."Remaining Amount";
            if ABS(Importe2) < ABS(Importe) THEN BEGIN
                Importe := -Importe2;
                Importe2 := -pCustLedgEntry."Remaining Amt. (LCY)"
            END ELSE
                Importe2 := r21."Remaining Amt. (LCY)";
            //if r21.FINDFIRST THEN;
            rMovCliDet.INIT;
            rMovCliDet."Entry No." := wNumMov + 1;
            rMovCliDet."Cust. Ledger Entry No." := pCustLedgEntry."Entry No.";
            rMovCliDet."Entry Type" := rMovCliDet."Entry Type"::Application;
            rMovCliDet."Posting Date" := "Posting Date";
            rMovCliDet."Document Type" := "Document Type";
            rMovCliDet."Document No." := "Document No.";
            rMovCliDet.Amount := Importe;
            rMovCliDet."Amount (LCY)" := Importe2;
            rMovCliDet."Customer No." := "Account No.";
            rMovCliDet."Currency Code" := "Currency Code";
            rMovCliDet."User ID" := USERID;
            rMovCliDet."Source Code" := pCustLedgEntry."Source Code";
            rMovCliDet."Transaction No." := pCustLedgEntry."Transaction No.";
            rMovCliDet."Initial Entry Due Date" := "Due Date";
            rMovCliDet."Initial Entry Global Dim. 1" := "Shortcut Dimension 1 Code";
            rMovCliDet."Initial Entry Global Dim. 2" := "Shortcut Dimension 2 Code";
            //ASC
            rMovCliDet."Initial Entry Global Dim. 3" := "Shortcut Dimension 3 Code";
            rMovCliDet."Initial Entry Global Dim. 4" := "Shortcut Dimension 4 Code";
            rMovCliDet."Initial Entry Global Dim. 5" := "Shortcut Dimension 5 Code";

            rMovCliDet."Initial Document Type" := "Document Type";
            rMovCliDet."Applied Cust. Ledger Entry No." := r21."Entry No.";
            rMovCliDet.INSERT;
            rMovCliDet.INIT;
            rMovCliDet."Entry No." := wNumMov + 2;
            rMovCliDet."Cust. Ledger Entry No." := r21."Entry No.";
            rMovCliDet."Entry Type" := rMovCliDet."Entry Type"::Application;
            rMovCliDet."Posting Date" := "Posting Date";
            rMovCliDet."Document Type" := "Document Type";
            rMovCliDet."Document No." := r21."Document No.";
            //  r21.CALCFIELDS(r21.Amount,r21."Amount (LCY)");
            rMovCliDet.Amount := -Importe;
            rMovCliDet."Amount (LCY)" := -Importe2;
            rMovCliDet."Customer No." := "Account No.";
            rMovCliDet."Currency Code" := "Currency Code";
            rMovCliDet."User ID" := USERID;
            rMovCliDet."Source Code" := r21."Source Code";
            rMovCliDet."Transaction No." := r21."Transaction No.";
            rMovCliDet."Initial Entry Due Date" := r21."Due Date";
            rMovCliDet."Initial Entry Global Dim. 1" := r21."Global Dimension 1 Code";
            rMovCliDet."Initial Entry Global Dim. 2" := r21."Global Dimension 2 Code";
            //ASC
            rMovCliDet."Initial Entry Global Dim. 3" := r21."Global Dimension 3 Code";
            rMovCliDet."Initial Entry Global Dim. 4" := r21."Global Dimension 4 Code";
            rMovCliDet."Initial Entry Global Dim. 5" := r21."Global Dimension 5 Code";

            rMovCliDet."Initial Document Type" := r21."Document Type";
            rMovCliDet."Applied Cust. Ledger Entry No." := pCustLedgEntry."Entry No.";
            rMovCliDet.INSERT;
        END;
    End;



    internal procedure QuitaMarca(var Rec: Record "G/L Entry")
    Begin
        if Utilidades.PermisoAdm() THEN BEGIN
            Rec."Reason Code" := '';
            Rec.MODIFY;
        END;
    End;

    internal procedure AñadirMarca(var Rec: Record "G/L Entry")
    Begin
        if Utilidades.PermisoAdm() THEN BEGIN
            Rec."Reason Code" := Format(WorkDate());
            Rec.MODIFY;
        END;
    End;

    internal procedure AsignaPrevComoNoDoc(var r17: Record "G/L Entry")
    Var
        r17R: Record "G/L Entry";
    BEGIN
        if r17.FINDFIRST THEN
            REPEAT
                r17."Periodo de Pago" := r17."Document No.";
                r17.MODIFY;
                r17R.SETCURRENTKEY(r17R."Transaction No.");
                r17R.SETRANGE(r17R."Transaction No.", r17."Transaction No.");
                if r17R.FINDFIRST THEN
                    REPEAT
                        r17R."Periodo de Pago" := r17R."Document No.";
                        r17R.MODIFY;
                    UNTIL r17R.NEXT = 0;
            UNTIL r17.NEXT = 0;
    END;

    internal procedure AsignaPeriodo(var r17: Record "G/L Entry")
    Var
        r17R: Record "G/L Entry";
    BEGIN
        if r17.FINDFIRST THEN
            REPEAT
                r17."Periodo de Pago" := r17."Document No.";
                r17.MODIFY;
                r17R.SETCURRENTKEY(r17R."Transaction No.");
                r17R.SETRANGE(r17R."Transaction No.", r17."Transaction No.");
                if r17R.FINDFIRST THEN
                    REPEAT
                        r17R."Periodo de Pago" := r17R."Document No.";
                        r17R.MODIFY;
                    UNTIL r17R.NEXT = 0;
            UNTIL r17.NEXT = 0;
    END;








    internal procedure CambiAlbaran(var GlEntries: Record "G/L Entry"; var Albt: Record "Purch. Rcpt. Header" temporary)
    var
        Alb: Record "Purch. Rcpt. Header";
        Calculo: Record "Calculo Albaranes";
    begin
        if Albt.Count = 1 then
            GlEntries.ModifyAll(GlEntries."Tax Area Code", Albt."No.")
        else begin
            if Albt."Buy-from Vendor No." <> '' Then Alb.SetRange("Buy-from Vendor No.", Albt."Buy-from Vendor No.");
            if Page.RunModal(0, Alb) in [Action::LookupOK, Action::OK] then
                GlEntries.ModifyAll(GlEntries."Tax Area Code", Alb."No.")
        end;
        if Calculo.Get((Albt."No.")) Then Begin Calculo.Calculado := False; Calculo.Modify() End;
        if Calculo.Get((Alb."No.")) Then Begin Calculo.Calculado := False; Calculo.Modify() End;

    end;

    internal procedure AsignaPeriododePago(var r17: Record "G/L Entry"; PerPago: Text)
    Var
        r17R: Record "G/L Entry";
        rPer: Record "Periodos pago emplazamientos";
    BEGIN
        if r17.FINDFIRST THEN
            REPEAT
                r17."Periodo de Pago" := PerPago;
                r17.MODIFY;
            // { r17R.SETCURRENTKEY(r17R."Transaction No.");
            // r17R.SETRANGE(r17R."Transaction No.",r17."Transaction No.");
            // if r17R.FINDFIRST THEN REPEAT
            // r17R."Periodo de Pago":=rPer."Cód. Periodo Pago";
            // r17R.MODIFY;
            // UNTIL r17R.NEXT=0; }
            UNTIL r17.NEXT = 0;
    END;

    internal procedure AsignaContrato(Var r17: Record "G/L Entry")
    Var
        r17R: Record "G/L Entry";
        rPer: Record "Periodos pago emplazamientos";
    BEGIN
        if r17.FINDFIRST THEN
            REPEAT
                r17."Job No." := Proyecto(r17);
                r17.MODIFY;
            UNTIL r17.NEXT = 0;

    END;

    PROCEDURE Proyecto(VAR r17: Record "G/L Entry"): Code[20];
    VAR
        r120: Record "Purch. Rcpt. Header";
        r112: Record 112;
        r114: Record 114;
    BEGIN
        WITH r17 DO BEGIN
            if ("Núm. Contrato" <> '') AND ("Núm. Contrato" <> '--') THEN EXIT("Job No.");
            if STRLEN("Document No.") > 20 THEN EXIT('--');
            if r112.GET("Document No.") THEN EXIT(r112."Nº Proyecto");
            if r114.GET("Document No.") THEN EXIT(r114."Nº Proyecto");
            CALCFIELDS("Núm. Contrato");
            if ("Núm. Contrato" = '--') OR ("Job No." = '') THEN BEGIN
                if r120.GET(COPYSTR("Document No.", 1, MAXSTRLEN(r120."No."))) THEN BEGIN
                    r120.CALCFIELDS(r120."Nº Contrato Venta");
                    EXIT(r120."Nº Proyecto");
                END;
            END;
            if "Job No." = '' THEN EXIT('--');
            EXIT("Job No.");
        END;
    END;

    PROCEDURE Mirar_Estado(var JobPlanningLine: Record "Job Planning Line");
    var
        Res: Record "Resource";
        Job: Record "Job";
        rDia: Record "Diario Reserva";
        Tipo: Record "Tipo Recurso";
    BEGIN
        //$001
        if ((JobPlanningLine.Type = JobPlanningLine.Type::Resource) AND (JobPlanningLine."No." <> '')) THEN BEGIN
            if Res.GET(JobPlanningLine."No.") THEN
                Res.TESTFIELD(Blocked, FALSE);
            If Not Tipo.GET(Res."Tipo Recurso") THEN
                Tipo.Init();
            If Not ((Res."Recurso Agrupado") Or (Tipo."Crea Reservas")) THEN
                JobPlanningLine."Sin Producción" := TRUE;
            if JobPlanningLine."Recurso Agrupado" then exit;
            if Res."Producción" then exit;
            if Not Tipo."Crea Reservas" then exit;
            if JobPlanningLine."Planning Date" = 0D then exit;
            if JobPlanningLine."Fecha Final" = 0D then exit;
            rDia.RESET;
            CLEAR(rDia);
            rDia.SETCURRENTKEY("Nº Recurso", Fecha);
            rDia.SETRANGE("Nº Recurso", JobPlanningLine."No.");
            rDia.SETRANGE(Fecha, JobPlanningLine."Planning Date", JobPlanningLine."Fecha Final");
            if rDia.FINDFIRST THEN BEGIN
                Job.GET(rDia."Nº Proyecto");
                MESSAGE('Este recurso ya está %1 en el proyecto %2 \' +
                        'Campaña: %3\' +
                        'No se permitirá la creación de nuevas reservas en del %4 al %5. \' +
                        'Téngalo en cuenta.', rDia.Estado, rDia."Nº Proyecto", Job.Description, Format(JobPlanningLine."Planning Date", 0, '<Day,2> de <Month,2> de <Year>'), Format(JobPlanningLine."Fecha Final", 0, '<Day,2> de <Month,2> de <Year>'));
            END;
        END;
    END;

    internal procedure CambiarBancoLiquidez(Var Rec: Record "G/L Entry")
    Var
        r17: Record "G/L Entry";
        Banck: Record 270;
    BEGIN
        if Page.RUNMODAL(0, Banck) = ACTION::LookupOK THEN BEGIN
            Rec.Banco := Banck."No.";
            Rec.MODIFY;
        END;
    END;

    internal procedure PagoImpuestos(Var Rec: Record "G/L Entry")
    Var
        r17: Record "G/L Entry";
        Banck: Record 270;
    BEGIN
        Rec."Pago Impuestos" := NOT Rec."Pago Impuestos";
        Rec.MODIFY;
    END;

    internal procedure DejarBancoEnBlanco(Var Rec: Record "G/L Entry")
    Var
        r17: Record "G/L Entry";
        Banck: Record 270;
    BEGIN
        Rec.Banco := '';
        Rec.MODIFY;

    END;


    internal procedure MarcaComoAlbaran(var r17: Record "G/L Entry")
    Var
        r25: Record 25;
    BEGIN
        if r17.FINDFIRST THEN
            REPEAT
                if r25.GET(r17."Entry No.") THEN BEGIN
                    r25."Document Type" := r25."Document Type"::Receipt;
                    r25.MODIFY;
                END;
            UNTIL r17.NEXT = 0;
        r17.MODIFYALL(r17."Document Type", r17."Document Type"::Receipt);
    END;

    internal procedure DesMarcaComoAlbaran(var r17: Record "G/L Entry")
    Var
        r25: Record 25;
    BEGIN
        if r17.FINDFIRST THEN
            REPEAT
                if r25.GET(r17."Entry No.") THEN BEGIN
                    r25."Document Type" := r25."Document Type"::" ";
                    r25.MODIFY;
                END;
            UNTIL r17.NEXT = 0;
        r17.MODIFYALL(r17."Document Type", r17."Document Type"::" ");
    END;

    internal procedure CambiarVto(Var rCar: Record "Cartera Doc.")
    Var
        Fecha: Date;
        Ventana: page "Date-Time Dialog";
        r17R: Record "G/L Entry";
        r254: Record 254;
        r25: Record 25;
        r21: Record 21;
        r379: Record 379;
        r380: Record 380;
        r271: Record 271;
        r45: Record 45;
        C11: Codeunit 11;
        FechaHora: DateTime;
    BEGIN
        //Ventana.OPEN('Introduzca Fecha ########1##');
        //Ventana.INPUT(1,Fecha);
        //Ventana.CLOSE;
        FechaHora := CurrentDateTime;
        Ventana.SetDateTime(FechaHora);
        if Ventana.RunModal() in [Action::Cancel, Action::LookupCancel] Then error('Proceso Cancelado');
        FechaHora := Ventana.GetDateTime();
        Fecha := Variant2Date(FechaHora);
        CLEAR(C11);
        rCar."Due Date" := Fecha;
        rCar.Modify();
        if r25.GET(rCar."Entry No.") THEN BEGIN
            r25."Due Date" := Fecha;
            r25.MODIFY;
            r380.SETRANGE("Vendor Ledger Entry No.", rCar."Entry No.");
            // r380.MODIFYALL("Due Date", Fecha);
        END;
        if r21.GET(rCar."Entry No.") THEN BEGIN
            r21."Due Date" := Fecha;
            r21.MODIFY;
            r379.SETRANGE("Cust. Ledger Entry No.", rCar."Entry No.");
            //r379.MODIFYALL("Due Date", Fecha);
        END;

    END;

    procedure PermisoAdm(): Boolean
    var
        Control: Codeunit ControlProcesos;
    begin
        exit(Control.compruebaPermisos(UserSecurityId, 'ADMMALLA', Companyname));

    end;

}