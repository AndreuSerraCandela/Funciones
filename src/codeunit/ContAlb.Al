/// <summary>
/// Codeunit ContabAlb (ID 7001145).
/// </summary>
Codeunit 50014 ContabAlb
{
    Permissions = TableData "G/L Entry" = rimd,
    tabledata "Sales Shipment Header" = rimd,
    tabledata "Sales Shipment Line" = rimd,
    tabledata "Sales Invoice Header" = rimd,
    tabledata "Sales Invoice Line" = rimd,
    tabledata "Sales Cr.Memo Header" = rimd,
    tabledata "Sales Cr.Memo Line" = rimd,
    tabledata "Purch. Rcpt. Header" = rimd,
    tabledata "Purch. Rcpt. Line" = rimd,
    tabledata "Purch. Inv. Header" = rimd,
    tabledata "Purch. Inv. Line" = rimd,
    tabledata "Purch. Cr. Memo Hdr." = rimd,
    tabledata "Purch. Cr. Memo Line" = rimd,
    tabledata "G/L Register" = rimd,
    tabledata "Vat Entry" = rimd,
    tabledata "Bank Account Ledger Entry" = rimd,
    tabledata "Gen. Journal Line" = rimd,
    tabledata "Vendor Ledger Entry" = rimd,
    tabledata "Cust. Ledger Entry" = rimd,
    tabledata "Detailed Cust. Ledg. Entry" = rimd,
    tabledata "Cartera Doc." = rimd,
    tabledata "Posted Cartera Doc." = rimd,
    tabledata "Closed Cartera Doc." = rimd,
    tabledata "Closed Bill Group" = rimd,
    tabledata "Posted Bill Group" = rimd,
    tabledata "Return Shipment Header" = rimd,
    tabledata "Return Shipment Line" = rimd,
    tabledata "Detailed Vendor Ledg. Entry" = rimd;

    var

        gCArrayDim: array[6] of Code[20];
        glSourceDataDoesNotExistInfoErr: Label 'Los datos de origen no existen en %1 para %2: %3.', Comment = 'Los datos de origen no existen en la Entrada del Libro de Proveedores para el Documento No.: PO000123.';
        glSourceTypeNotSupportedErr: Label 'Tipo no soportado';
        glEjecutarPorTerminos: Label 'No hay líneas seleccionadas para ejecutar por términos';
        glDefaultTxt: Label 'Default';
        glNada: Label 'NADA';
        glUnion: Label 'UNION AGRICOLA Y TURISTICA, SL';
        glUATI: Label 'UATI';
        gDTotalliDiasReservas: array[100] of Integer;
        glSinReserva: Label 'No hay reservas en el proyecto %1 para las fechas %2 %3 y el recurso %4';
        SinReservaNingunPeriodo: Label 'No hay reservas en el proyecto %1 con estos filtros: %2';
        glPedidoSinContrato: Label 'No el posible facturar por términos \';
        glPedidoSinContrato1: Label 'el pedido no tiene contrato ';
        glNoAutomatico: Label 'No es posible facturar este contrato por términos: \';
        glNoAutomatico1: Label 'sólo se puede facturar por términos, los pedidos \';
        glNoAutomatico2: Label 'que vengan entera y automáticamente de contrato';
        glTxtDividir: Label 'La línea nº %1 del proyecto, no aparece en ninguna factura de venta,\ ¿ la dividimos como la anterior ?';
        glErrorProduccion: Label 'No ha asignado producción para el recurso %1, en la empresa %2 para el proyecto %3 que en principio debería ser %4';
        glErrorAgrupado: label 'No se ha asignado recurso agrupado en las reservas para estas fechas: %4 a %5 en el recurso %1 de la empresa %2, en el proyecto %3';
        glSinDimension: Label 'El recurso %1 de la empresa %2 no tiene asignada la dimension %3';
        glNoDebeContabilizado: Label 'No debe estar contabilizado para contabilizarlo';
        glDebeContabilizado: Label 'Debe estar contabilizado para des-contabilizarlo';
        glNoDebefacturado: Label 'No debe estar facturado para contabilizarlo';
        glDebefacturado: Label 'Debe estar facturado para des-facturarlo';
        glDebedesglosado: Label 'Debe estar contabilizado para desglosarlo';
        glElmismo: Label ' el mismo';
        glErrorDesglose: Label 'Se ha producido un error al desglosar la producción. Contacte con informática';
        glDimensionEnBlanco: Label 'Dimensión %1 en blanco en el recurso nº %2';
        glPrimeraLinea: Label 'Es la primera línea, no hay línea anterior, no se puede tomar como base ninguna línea';
        glEnelProyecto: Label ' en el proyecto %4';
        glEquivalencia: Label 'No hay equivalencia entre la empresa %1 y la empresa %2 para el grupo %3';
        glCancelado: Label 'Proceso cancelado por el usuario';
        glCashFlowTxt: Label 'CashFlow';
        glCashFlowForecastTxt: Label 'Cash Flow Forecast';
        glCashFlowAbbreviationTxt: Label 'CF', Comment = 'Abbreviation of Cash Flow';
        glUpdatingMsg: Label 'Updating Cash Flow Forecast...';
        gVATPostingSetup: Record "VAT Posting Setup";
        glText004: Label 'FPR Albarán %1 - %2';
        glText006: Label 'Libro Alb. compra';
        glText007: Label 'Sección Alb. compra';
        glText008: Label 'El albarán %1 no se está contabilizando en su empresa Fiscal (%2).';
        glText032: Label 'La combinación de dimensiones utilizada en %1 %2 está bloqueada. %3';
        glText033: Label 'La combinación de dimensiones utilizada en %1 %2, nº línea %3 está bloqueada. %4';
        glText034: Label 'Las dimensiones usadas en %1 %2 son inválidas %3';
        glText035: Label 'Las dim. usadas en %1 %2, no. Lín. %3 son inválidas %4';
        glText037: Label 'No se puede contabilizar un albarán si %1 es %2.';
        glText100: Label 'ALBARAN C';
        glC: Label '''';
        gDImporteTotal: Decimal;
        gDImporteTotalDL: Decimal;
        giAsiento: Integer;
        gcGenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
        gcDimMgt: Codeunit DimensionManagement;
        gGenPostingSetup: Record "General Posting Setup";
        gGenJnlLine: Record "Gen. Journal Line";
        gTotalPurchaseLineLCY: Record "Purchase Line";
        gTotalPurchaseLine: Record "Purchase Line";
        gCurrency: Record Currency;
        gcSalesTaxCalculate: Codeunit "Sales Tax Calculate";
        gGenledgerSetup: Record "General Ledger Setup";
        gCurrExchRate: Record "Currency Exchange Rate";
        gDDiscountVATAmount: Decimal;
        gCSrcCode: Code[20];
        gPurchHeader: Record "Purchase Header";
        gPurchSetup: Record "Purchases & Payables Setup";
        gRecursoAgrupado: Boolean;



    /// <summary>
    /// SoloTraspasar.
    /// </summary>
    /// <param name="Doc">Code[20].</param>
    /// <param name="Pedido">Boolean.</param>
    /// 
    /**
     * This procedure is used to perform a inter-company operation based on the provided document and flag.
     *
     * @param Doc - The document code to be processed.
     * @param Pedido - A flag indicating whether the document is a purchase order or a return order.
     */
    procedure SoloTraspasar(pCDoc: Code[20]; pbPedido: Boolean)
    var
        lPurchRcptHdr: Record "Purch. Rcpt. Header";
        lPurchHeader: Record "Purchase Header";
        lcProy: Codeunit "Gestion Proyecto";
        lcPurchPost: Codeunit "Purch.-Post";
        lReturnShipmentHeader: Record "Return Shipment Header";
    begin
        if pCDoc = '' THEN EXIT;
        if pCDoc = ' ' THEN EXIT;
        if pbPedido THEN BEGIN
            if NOT lPurchRcptHdr.GET(pCDoc) THEN EXIT;
            lPurchHeader.GET(lPurchHeader."Document Type"::Order, lPurchRcptHdr."Order No.");
            if TestActivos(lPurchHeader) THEN EXIT;
            CLEAR(lcProy);
            if lcProy.DebeTraspasarsePC(lPurchRcptHdr) THEN
                lcProy.TrasPasaCompraaEmpresas(lPurchRcptHdr);
        END ELSE BEGIN
            lReturnShipmentHeader.GET(pCDoc);
            CLEAR(lcProy);
            lPurchHeader.GET(lPurchHeader."Document Type"::"Return Order", lReturnShipmentHeader."Return Order No.");
            if TestActivos(lPurchHeader) THEN EXIT;
            if lcProy.DebeTraspasarseDC(lReturnShipmentHeader) THEN
                lcProy.TrasPasaDevolaEmpresas(lReturnShipmentHeader);
        END;
    end;

    /// <summary>
    /// SoloContabilizar.
    /// </summary>
    /// <param name="Doc">Code[20]. The document code.</param>
    /// <param name="Pedido">Boolean. Indicates whether it is a purchase order or retrun order.</param>
    procedure SoloContabilizar(pCDoc: Code[20]; pbPedido: Boolean)
    var
        lPurchRcptHdr: Record "Purch. Rcpt. Header";
        lPurchHeader: Record "Purchase Header";
        lcProy: Codeunit "Gestion Proyecto";
        lcPurchPost: Codeunit "Purch.-Post";
        lReturnShipmentHeader: Record "Return Shipment Header";
    begin

        if pCDoc = '' THEN EXIT;
        if pCDoc = ' ' THEN EXIT;

        if pbPedido THEN BEGIN
            lPurchRcptHdr.GET(pCDoc);
            CLEAR(lcPurchPost);
            ContabilizarAlbaranes(lPurchRcptHdr);
            lPurchRcptHdr.GET(pCDoc);
            CLEAR(lcProy);
            // if lcProy.DebeTraspasarsePC(lPurchRcptHdr) THEN
            //  lcProy.TrasPasaComraaEmpresas(lPurchRcptHdr);
        END ELSE BEGIN
            lReturnShipmentHeader.GET(pCDoc);
            ContabilizarDevoluciones(lReturnShipmentHeader);
            lReturnShipmentHeader.GET(pCDoc);
            CLEAR(lcProy);
            // if lcProy.DebeTraspasarseDC(lReturnShipmentHeader) THEN
            //  lcProy.TrasPasaDevolaEmpresas(lReturnShipmentHeader);

        END;
    end;

    /**
     * PROCEDURE ContabAlbaranFPR
     * 
     * This procedure is responsible for performing the accounting process for an recept with FPR (Invoice to receive) accounts.
     * 
     * @param pCDiario - The code of the journal to be used for the accounting entries.
     * @param pCSeccion - The code of the journal section to be used for the accounting entries.
     * @param pCnAlbaran - The code of the receipt to be processed.
     * @param pCnAlbExterno - The external code of the recept.
     * @param pCProveed - The code of the vendor associated with the recept.
     */
    PROCEDURE ContabAlbaranFPR(pCDiario: Code[20]; pCSeccion: Code[20]; pCnAlbaran: Code[20]; pCnAlbExterno: Code[20]; pCProveed: Code[20])
    VAR
        lPurchRcptHeader: Record "Purch. Rcpt. Header";
        lPurchRcptLine: Record "Purch. Rcpt. Line";
        lVendorPostingGroup: Record "Vendor Posting Group";
        rConfCon: Record "General Ledger Setup";
        lCurrency: Record "Currency";
        lVendor: Record Vendor;
        lGenJnlLine: Record "Gen. Journal Line";
        lGenJnlTemplate: Record "Gen. Journal Template";
        lGenJnlBatch: Record "Gen. Journal Batch";
        lbCreadoAqui: Boolean;
        ltEmpresa: Text[30];
        lCalculo: Record "Calculo Albaranes";
        TempBuffer: Record "Invoice Posting Buffer" temporary;
        TempBuffer2: Record "Invoice Posting Buffer" temporary;
        FALineNo: Integer;
    BEGIN
        // ContabAlbaranFPR
        //

        lPurchRcptHeader.GET(pCnAlbaran);
        if lPurchRcptHeader."Posting Date" < 20190901D THEN lPurchRcptHeader."Posting Date" := 20190901D;
        // Localizamos el hotel a través del almacén si no esta grabado en la cabecera
        ///if lPurchRcptHeader."Location Code"='' THEN EXIT;
        //lPurchRcptHeader.TestField("Location Code");


        // PLB 18/11/2002 - si no se contabilizan albaranes salir sin comprobar nada
        //
        if lPurchRcptHeader.Contabilizado = TRUE THEN EXIT;
        //lPurchRcptHeader.TestField(Contabilizado, FALSE);
        // Fin PLB

        gPurchSetup.GET;

        CLEAR(ltEmpresa);




        if lPurchRcptHeader."Currency Code" <> '' THEN BEGIN
            lCurrency.GET(lPurchRcptHeader."Currency Code");
            lCurrency.TestField("Residual Gains Account");
            lCurrency.TestField("Residual Losses Account");
        END
        ELSE BEGIN
            rConfCon.GET;
            lCurrency."Amount Rounding Precision" := rConfCon."Amount Rounding Precision";
        END;

        gDImporteTotal := 0;
        gDImporteTotalDL := 0;

        // Obtenemos la Cta. F.P.R.
        lVendor.GET(pCProveed);

        // PAH 06/06/2006
        // INC-16126
        //lVendorPostingGroup.GET(lVendor."Vendor Posting Group");
        lVendorPostingGroup.GET(lPurchRcptHeader."Vendor Posting Group");

        lVendorPostingGroup.TestField(lVendorPostingGroup.FPR);

        //CopyAndCheckDocDimToTempDocDim(lPurchRcptHeader);

        // Acumulamos los importes
        // Se realiza un apunte para cada cuenta, grupos contables y combinación de dimensiones
        // Sólo se realiza FPR de las lineas de Tipo "Producto", "Cuenta", "Cargo" y "Activo"
        //
        lPurchRcptLine.SETRANGE("Document No.", pCnAlbaran);
        lPurchRcptLine.SETFILTER(lPurchRcptLine."Qty. Rcd. Not Invoiced", '<>%1', 0);
        if NOT lPurchRcptLine.FINDFIRST THEN BEGIN
            MESSAGE('El albarán está facturado');
            EXIT;
        END;
        if lPurchRcptLine.FIND('-') THEN
            REPEAT
                FillInvPostingBuffer(lPurchRcptHeader, lPurchRcptLine, TempBuffer);
                UpdInvPostingBuldFFeProduccionesgloNew(TempBuffer, FALineNo, TempBuffer2);
            UNTIL lPurchRcptLine.NEXT = 0;

        // Fin PLB

        // Creamos y registramos el diario
        //
        TempBuffer2.RESET;
        // WITH TempBuffer2 DO
        if TempBuffer2.FIND('+') THEN BEGIN
            if NOT lGenJnlTemplate.GET(pCDiario) THEN BEGIN
                CLEAR(lGenJnlTemplate);
                lGenJnlTemplate.Name := pCDiario;
                lGenJnlTemplate.Description := glText006;
                lGenJnlTemplate.INSERT;
            END;

            if NOT lGenJnlBatch.GET(pCDiario, pCSeccion) THEN BEGIN
                lGenJnlBatch."Journal Template Name" := pCDiario;
                lGenJnlBatch.Name := pCSeccion;
                lGenJnlBatch.Description := glText007;
                lGenJnlBatch.INSERT;
            END;

            // Buscamos el último nº asiento
            //
            //if TempBuffer2."Global Dimension 1 Code"='' THEN EXIT;
            lGenJnlLine.SETCURRENTKEY("Journal Template Name", "Journal Batch Name", "Posting Date", "Transaction No.");
            lGenJnlLine.SETRANGE("Journal Template Name", pCDiario);
            lGenJnlLine.SETRANGE("Journal Batch Name", pCSeccion);
            lGenJnlLine.SETRANGE("Posting Date", lPurchRcptHeader."Posting Date");
            lGenJnlLine.ASCENDING(FALSE);
            if lGenJnlLine.FIND('-') THEN
                giAsiento := lGenJnlLine."Transaction No." + 1
            ELSE
                giAsiento := 1;

            REPEAT
                lGenJnlLine.INIT;
                //BRM 06/08/04
                lGenJnlLine."Journal Template Name" := pCDiario;
                lGenJnlLine."Journal Batch Name" := pCSeccion;
                //FiN BRM
                lGenJnlLine."Posting Date" := lPurchRcptHeader."Posting Date";
                lGenJnlLine."Document Date" := lPurchRcptHeader."Document Date";

                // contabilizar descripciones
                //
                //if TempBuffer2.Description <> '' THEN
                //  lGenJnlLine.Description := TempBuffer2.Descripcion
                //ELSE
                lGenJnlLine.Description := COPYSTR(STRSUBSTNO(glText004, pCnAlbExterno, lVendor.Name), 1, 50);

                lGenJnlLine."Reason Code" := lPurchRcptHeader."Reason Code";
                lGenJnlLine."Document Type" := lGenJnlLine."Document Type"::" ";
                lGenJnlLine."Document No." := lPurchRcptHeader."No.";
                lGenJnlLine."External Document No." := lPurchRcptHeader."Vendor Shipment No.";
                if TempBuffer2.Type = TempBuffer2.Type::"Fixed Asset" THEN
                    lGenJnlLine."Account Type" := lGenJnlLine."Account Type"::"Fixed Asset"
                ELSE
                    lGenJnlLine."Account Type" := lGenJnlLine."Account Type"::"G/L Account";
                lGenJnlLine."Account No." := TempBuffer2."G/L Account";
                lGenJnlLine."System-Created Entry" := TempBuffer2."System-Created Entry";
                lGenJnlLine.Amount := ROUND(TempBuffer2.Amount);
                lGenJnlLine."Source Currency Code" := lPurchRcptHeader."Currency Code";
                lGenJnlLine."Source Currency Amount" := ROUND(TempBuffer2."Amount (ACY)", lCurrency."Amount Rounding Precision");

                gDImporteTotal += lGenJnlLine."Source Currency Amount";
                gDImporteTotalDL += lGenJnlLine.Amount;

                lGenJnlLine.Correction := lPurchRcptHeader.Correction;
                lGenJnlLine."Gen. Posting Type" := lGenJnlLine."Gen. Posting Type"::" ";
                lGenJnlLine."Gen. Bus. Posting Group" := '';
                lGenJnlLine."Gen. Prod. Posting Group" := '';
                lGenJnlLine."VAT Bus. Posting Group" := '';
                lGenJnlLine."VAT Prod. Posting Group" := '';
                lGenJnlLine."FA Posting Date" := TempBuffer2."FA Posting Date";
                case TempBuffer2."FA Posting Type" of
                    TempBuffer2."FA Posting Type"::" ":
                        lGenJnlLine."FA Posting Type" := lGenJnlLine."FA Posting Type"::" ";
                    TempBuffer2."FA Posting Type"::"Acquisition Cost":
                        lGenJnlLine."FA Posting Type" := lGenJnlLine."FA Posting Type"::"Acquisition Cost";
                    TempBuffer2."FA Posting Type"::Appreciation:
                        lGenJnlLine."FA Posting Type" := lGenJnlLine."FA Posting Type"::Appreciation;
                    TempBuffer2."FA Posting Type"::Maintenance:
                        lGenJnlLine."FA Posting Type" := lGenJnlLine."FA Posting Type"::Maintenance;
                end;
                lGenJnlLine."Depreciation Book Code" := TempBuffer2."Depreciation Book Code";
                lGenJnlLine."Tax Area Code" := TempBuffer2."Tax Area Code";
                lGenJnlLine."Tax Liable" := TempBuffer2."Tax Liable";
                lGenJnlLine."Tax Group Code" := TempBuffer2."Tax Group Code";
                lGenJnlLine."Use Tax" := TempBuffer2."Use Tax";
                lGenJnlLine.Quantity := TempBuffer2.Quantity;
                lGenJnlLine."Shortcut Dimension 1 Code" := TempBuffer2."Global Dimension 1 Code";
                lGenJnlLine."Shortcut Dimension 2 Code" := TempBuffer2."Global Dimension 2 Code";
                lGenJnlLine."Shortcut Dimension 3 Code" := TempBuffer2."Global Dimension 3 Code";
                lGenJnlLine."Shortcut Dimension 4 Code" := TempBuffer2."Global Dimension 4 Code";
                lGenJnlLine."Shortcut Dimension 5 Code" := TempBuffer2."Global Dimension 5 Code";

                lGenJnlLine."Dimension Set ID" := TempBuffer2."Dimension Set ID";
                if lGenJnlLine."Dimension Set ID" = 0 THEN EXIT;
                lGenJnlLine."Job No." := TempBuffer2."Job No.";
                lGenJnlLine."Source Code" := lGenJnlTemplate."Source Code";
                lGenJnlLine."Bill-to/Pay-to No." := lPurchRcptHeader."Buy-from Vendor No.";
                lGenJnlLine."Source Type" := lGenJnlLine."Source Type"::Vendor;
                lGenJnlLine."Source No." := lPurchRcptHeader."Pay-to Vendor No.";
                lGenJnlLine."Posting No. Series" := '';
                lGenJnlLine."Payment Terms Code" := lPurchRcptHeader."Payment Terms Code";
                lGenJnlLine."Payment Method Code" := lPurchRcptHeader."Payment Method Code";

                //lGenJnlLine."Line No." := -TempBuffer2."Nº linea diario";

                RungcGenJnlPostLine(lGenJnlLine);//,TempBuffer2."Dimension Entry No.");
            UNTIL TempBuffer2.NEXT(-1) = 0;

            if TempBuffer2.RECORDLEVELLOCKING THEN BEGIN
                if TempBuffer2.FIND('-') THEN
                    REPEAT
                        TempBuffer2.DELETE;
                    UNTIL TempBuffer2.NEXT = 0;
            END ELSE
                TempBuffer2.DELETEALL;

            // Realiza el asiento para la Contrapartida: cuenta FPR
            //
            lGenJnlLine.INIT;
            lGenJnlLine."Posting Date" := lPurchRcptHeader."Posting Date";
            lGenJnlLine."Document Date" := lPurchRcptHeader."Document Date";
            lGenJnlLine.Description := COPYSTR(STRSUBSTNO(glText004, pCnAlbExterno, lVendor.Name), 1, 50);
            lGenJnlLine."Shortcut Dimension 1 Code" := lPurchRcptHeader."Shortcut Dimension 1 Code";
            lGenJnlLine."Shortcut Dimension 2 Code" := lPurchRcptHeader."Shortcut Dimension 2 Code";
            if lPurchRcptHeader."Dimension Set ID" = 0 THEN
                lGenJnlLine."Dimension Set ID" := TempBuffer2."Dimension Set ID"
            ELSE
                lGenJnlLine."Dimension Set ID" := lPurchRcptHeader."Dimension Set ID";
            lGenJnlLine."Reason Code" := lPurchRcptHeader."Reason Code";
            lGenJnlLine."Account Type" := lGenJnlLine."Account Type"::"G/L Account";
            lGenJnlLine."Account No." := lVendorPostingGroup.FPR;
            lGenJnlLine."Document Type" := lGenJnlLine."Document Type"::" ";
            lGenJnlLine."Document No." := lPurchRcptHeader."No.";
            lGenJnlLine."External Document No." := lPurchRcptHeader."Vendor Shipment No.";
            //lGenJnlLine."Currency Code" := lPurchRcptHeader."Currency Code";
            //if lPurchRcptHeader."Currency Code" = '' THEN
            //  lGenJnlLine."Currency Factor" := 1
            //ELSE
            //  lGenJnlLine."Currency Factor" :=  lPurchRcptHeader."Currency Factor";

            lGenJnlLine.Amount := -gDImporteTotalDL;
            lGenJnlLine."Source Currency Code" := lPurchRcptHeader."Currency Code";
            lGenJnlLine."Source Currency Amount" := -gDImporteTotal;
            //gDImporteTotalDL := ROUND(rTipoCambio.ExchangeAmtFCYToLCY(lGenJnlLine."Posting Date", lGenJnlLine."Currency Code",
            //  lGenJnlLine.Amount, lGenJnlLine."Currency Factor"));
            //lGenJnlLine."Amount (LCY)" := gDImporteTotalDL;
            lGenJnlLine.Correction := lPurchRcptHeader.Correction;
            lGenJnlLine."Bill-to/Pay-to No." := lPurchRcptHeader."Buy-from Vendor No.";
            lGenJnlLine."Source Type" := lGenJnlLine."Source Type"::Vendor;
            lGenJnlLine."Source No." := lPurchRcptHeader."Pay-to Vendor No.";
            lGenJnlLine."System-Created Entry" := TRUE;
            lGenJnlLine."Payment Terms Code" := lPurchRcptHeader."Payment Terms Code";
            lGenJnlLine."Payment Method Code" := lPurchRcptHeader."Payment Method Code";
            //lGenJnlLine."Recipient Bank Account" := lPurchRcptHeader."Vendor Bank Acc. Code";
            lGenJnlLine."Source Type" := lGenJnlLine."Source Type"::Vendor;
            lGenJnlLine."Source No." := lPurchRcptHeader."Pay-to Vendor No.";
            lGenJnlLine."Source Code" := lGenJnlTemplate."Source Code";
            lGenJnlLine."Posting No. Series" := '';

            gcGenJnlPostLine.RunWithCheck(lGenJnlLine);//,TempJnlLineDim);

            // En el caso de realizar la contabilización de "extracciones y consumo" se debe hacer un traspaso
            // de la cuenta de existencias correspondiente a variación de existencias
            //

            // Marcamos el Albarán como Contabilizado
            //
        END;
        if lPurchRcptHeader.GET(pCnAlbaran) THEN BEGIN
            // PLB 10/05/2001
            // le asignamos la divisa del hotel, en caso de llegar en blanco y div. hotel <> div. central
            // Fin PLB

            lPurchRcptHeader.Contabilizado := TRUE;
            lPurchRcptHeader.MODIFY(TRUE);
            if lCalculo.Get(lPurchRcptHeader."No.") Then Begin lCalculo.Calculado := False; lCalculo.Modify(); End;
            COMMIT;
        END;
    END;

    /// <summary>
    /// Register a receipt by performing necessary accounting operations.
    /// </summary>
    /// <param name="pCnAlbaran">The receipt number to be processed.</param>
    PROCEDURE ContabilizarAlbaran(pCnAlbaran: Code[20])
    VAR
        lPurchRcptHdr: Record "Purch. Rcpt. Header";
        lGenJnlLine: Record "Gen. Journal Line";
    BEGIN
        lPurchRcptHdr.GET(pCnAlbaran);
        lGenJnlLine.SETRANGE(lGenJnlLine."Journal Template Name", 'COMPRAS');
        lGenJnlLine.SETRANGE(lGenJnlLine."Journal Batch Name", 'ALBARANES');
        ContabAlbaranFPR('COMPRAS', 'ALBARANES', pCnAlbaran, lPurchRcptHdr."Vendor Shipment No.", lPurchRcptHdr."Buy-from Vendor No.");
    END;

    /// <summary>
    /// FillInvPostingBuffer.
    /// </summary>
    /// <param name="pPurchRcptHeader">Record "Purch. Rcpt. Header".</param>
    /// <param name="pPurchRcptLine">Record "Purch. Recpt. Line".</param>
    /// <returns>Return value of type Boolean.</returns>
    procedure FillInvPostingBuffer(pPurchRcptHeader: Record "Purch. Rcpt. Header"; pPurchRcptLine: Record "Purch. Rcpt. Line"; var TempInvoiceLineBuffer: Record "Invoice Posting Buffer"): Boolean
    VAR
        lCurrExchRate: Record "Currency Exchange Rate";
        lcControldeProcesos: Codeunit ControlProcesos;
        FalineNo: Integer;
    BEGIN
        // FillInvPostingBuffer
        //
        // This procedure is responsible for Filling the gInvPostingBufferArrayTMP with the necessary data.
        // It takes two parameters: pPurchRcptHeader, which is a record of type Purch Recpt. Header, and pPurchRcptLine, which is a record Purch Rcpt. Line.
        // The function returns a Boolean value indicating whether the Filling of the Buffer was successful or not.

        // WITH pPurchRcptLine DO BEGIN
        if (pPurchRcptLine."Gen. Bus. Posting Group" <> gGenPostingSetup."Gen. Bus. Posting Group") OR
           (pPurchRcptLine."Gen. Prod. Posting Group" <> gGenPostingSetup."Gen. Prod. Posting Group")
        THEN
            if NOT gGenPostingSetup.GET(pPurchRcptLine."Gen. Bus. Posting Group", pPurchRcptLine."Gen. Prod. Posting Group") THEN EXIT(FALSE);
        CLEAR(TempInvoiceLineBuffer);
        case pPurchRcptLine.Type Of
            pPurchRcptLine.Type::"Fixed Asset":
                TempInvoiceLineBuffer.Type := TempInvoiceLineBuffer.Type::"Fixed Asset";
            pPurchRcptLine.Type::"G/L Account":
                TempInvoiceLineBuffer.Type := TempInvoiceLineBuffer.Type::"G/L Account";
            pPurchRcptLine.Type::Item:
                TempInvoiceLineBuffer.Type := TempInvoiceLineBuffer.Type::Item;
            pPurchRcptLine.Type::Resource:
                TempInvoiceLineBuffer.Type := TempInvoiceLineBuffer.Type::Resource;
        end;
        if (pPurchRcptLine.Type = pPurchRcptLine.Type::"G/L Account") OR (pPurchRcptLine.Type = pPurchRcptLine.Type::"Fixed Asset") THEN BEGIN
            TempInvoiceLineBuffer."G/L Account" := pPurchRcptLine."No.";
            if pPurchRcptLine.Type = pPurchRcptLine.Type::"Fixed Asset" THEN BEGIN
                TempInvoiceLineBuffer."FA Posting Date" := pPurchRcptLine."FA Posting Date";
                TempInvoiceLineBuffer."FA Posting Type" := pPurchRcptLine."FA Posting Type";
                TempInvoiceLineBuffer."Depreciation Book Code" := pPurchRcptLine."Depreciation Book Code";
            END;
        END
        ELSE BEGIN
            gGenPostingSetup.TestField("Purch. Account");
            TempInvoiceLineBuffer."G/L Account" := gGenPostingSetup."Purch. Account";
        END;
        TempInvoiceLineBuffer."System-Created Entry" := TRUE;

        // PLB 14/04/2004
        // no agrupar por grupos contables
        TempInvoiceLineBuffer."Gen. Bus. Posting Group" := pPurchRcptLine."Gen. Bus. Posting Group";
        TempInvoiceLineBuffer."Gen. Prod. Posting Group" := pPurchRcptLine."Gen. Prod. Posting Group";
        TempInvoiceLineBuffer."VAT Bus. Posting Group" := '';
        TempInvoiceLineBuffer."VAT Prod. Posting Group" := '';
        TempInvoiceLineBuffer."VAT Calculation Type" := TempInvoiceLineBuffer."VAT Calculation Type"::"Normal VAT";
        TempInvoiceLineBuffer."Global Dimension 1 Code" := pPurchRcptLine."Shortcut Dimension 1 Code";
        TempInvoiceLineBuffer."Global Dimension 2 Code" := pPurchRcptLine."Shortcut Dimension 2 Code";
        TempInvoiceLineBuffer."Global Dimension 3 Code" := pPurchRcptLine."Shortcut Dimension 3 Code";
        TempInvoiceLineBuffer."Global Dimension 4 Code" := pPurchRcptLine."Shortcut Dimension 4 Code";
        TempInvoiceLineBuffer."Global Dimension 5 Code" := pPurchRcptLine."Shortcut Dimension 5 Code";
        TempInvoiceLineBuffer."Dimension Set ID" := lcControldeProcesos.GetDefaultDimID2(pPurchRcptLine."Shortcut Dimension 1 Code", pPurchRcptLine."Shortcut Dimension 2 Code",
        pPurchRcptLine."Shortcut Dimension 3 Code", pPurchRcptLine."Shortcut Dimension 4 Code", pPurchRcptLine."Shortcut Dimension 5 Code");
        TempInvoiceLineBuffer."Job No." := pPurchRcptLine."Job No.";
        TempInvoiceLineBuffer.Amount := ROUND(lCurrExchRate.ExchangeAmtFCYToLCY(pPurchRcptHeader."Posting Date",
          pPurchRcptHeader."Currency Code", pPurchRcptLine."Qty. Rcd. Not Invoiced" * pPurchRcptLine."Unit Cost", pPurchRcptHeader."Currency Factor"));
        TempInvoiceLineBuffer."Amount (ACY)" := pPurchRcptLine."Qty. Rcd. Not Invoiced" * pPurchRcptLine."Unit Cost";


        // END;
    END;

    /// <summary>
    /// RungcGenJnlPostLine.
    /// </summary>
    /// <param name="VAR GenJnlLine">Record "Gen. Journal Line".</param>
    procedure RungcGenJnlPostLine(VAR pGenJnlLine: Record "Gen. Journal Line")
    BEGIN
        // RungcGenJnlPostLine
        //

        gcGenJnlPostLine.RunWithCheck(pGenJnlLine);//,TempJnlLineDim);
    END;

    Procedure Desglosar(var pSalesHeader: Record "Sales Header")
    Var
        lSalesInvoiceLineTMP: Record "Sales Invoice Line" temporary;
        lReserva: Record "Reserva";
        lSalesInvoiceLineTMPt: Record "Sales Invoice Line" temporary;
        lSalesShptLine: Record "Sales Shipment Line";
        lSalesShptHdr: Record "Sales Shipment Header";
        iNumeroReservas: Integer;
        lResource: Record "Resource";
        lSalesInvoiceLineTMPt2: Record "Sales Invoice Line" temporary;
        liDiasReserva: Integer;
        ldFI: Date;
        ldFF: Date;
        lDImporte: Decimal;
        lDImporteIvaIncluido: Decimal;
        lSalesInvLineTMPo: Record "Sales Invoice Line" temporary;
        lJob: Record "Job";
        lCJob: Code[20];
        ltComp: Text[30];
        lDimValue: Record "Dimension Value";
        lSalesLine: Record "Sales Line";
        lGenProdPostGrp: Record "Gen. Product Posting Group";
        lDimValue2: Record "Dimension Value";
        lCJob2: Text[30];
        lILinea: Integer;
        lbAgrupado: boolean;
        g: Integer;
        lClcControldeProcesos: Codeunit ControlProcesos;
        ltCompany: Text[30];
        rRel: Record "Relación Grupos";
    Begin
        WITH pSalesHeader DO BEGIN
            lSalesShptLine.SETRANGE(lSalesShptLine."Document No.", "Posting No.");
            lSalesShptLine.DELETEALL;
            if lSalesShptHdr.GET("Posting No.") THEN lSalesShptHdr.DELETE;
            //Inserto tabla temporal con las líneas originales
            lSalesLine.SETRANGE(lSalesLine."Document Type", "Document Type");
            lSalesLine.SETRANGE(lSalesLine.Type, 1, 999);
            lSalesLine.SETRANGE(lSalesLine."Document No.", "No.");
            if lSalesLine.FINDFIRST THEN
                REPEAT
                    lSalesInvLineTMPo.TransferFields(lSalesLine);
                    lSalesInvLineTMPo."Posting Date" := "Posting Date";
                    lSalesInvLineTMPo."Document No." := "Posting No.";
                    lSalesInvLineTMPo.Quantity := lSalesLine."Qty. to Invoice";
                    lSalesInvLineTMPo."Quantity (Base)" := lSalesLine."Qty. to Invoice (Base)";
                    if lSalesInvLineTMPo."Job No." = '' Then begin
                        lSalesInvLineTMPo."Job No." := pSalesHeader."Nº Proyecto";
                    end;
                    lSalesInvLineTMPo.INSERT;
                UNTIL lSalesLine.NEXT = 0;
            //Miro si el recurso es de otra empresa y le asigno recurso y proyecto de la empresa origen
            lSalesInvLineTMPo.SETRANGE(lSalesInvLineTMPo."Document No.", "Posting No.");
            if lSalesInvLineTMPo.FINDFIRST THEN
                REPEAT
                    lSalesInvoiceLineTMP := lSalesInvLineTMPo;
                    if lSalesInvLineTMPo.Type = lSalesInvLineTMPo.Type::Resource THEN BEGIN
                        if lResource.GET(lSalesInvLineTMPo."No.") THEN BEGIN
                            lSalesInvoiceLineTMP."Shortcut Dimension 1 Code" := lResource."Global Dimension 1 Code";
                            lSalesInvoiceLineTMP."Shortcut Dimension 2 Code" := lResource."Global Dimension 2 Code";
                            lSalesInvoiceLineTMP."Shortcut Dimension 3 Code" := lResource."Global Dimension 3 Code";
                            lSalesInvoiceLineTMP."Shortcut Dimension 4 Code" := lResource."Global Dimension 4 Code";
                            lSalesInvoiceLineTMP."Shortcut Dimension 5 Code" := lResource."Global Dimension 5 Code";

                            if (lResource."Empresa Origen" <> COMPANYNAME) AND (lResource."Empresa Origen" <> '') THEN BEGIN
                                lSalesInvoiceLineTMP."No." := lResource."Nº En Empresa origen";
                                lSalesInvoiceLineTMP."Empresa Origen" := lResource."Empresa Origen";
                                recuperaproyecto(lJob, lSalesInvLineTMPo."Job No.", lResource);
                                lSalesInvoiceLineTMP."Proyecto Origen" := lJob."No.";
                                lResource.CHANGECOMPANY(lResource."Empresa Origen");
                                ltCompany := lResource."Empresa Origen";
                                if NOT lResource.GET(lSalesInvoiceLineTMP."No.") THEN lResource.INIT;
                                lSalesInvoiceLineTMP."Shortcut Dimension 1 Code" := lResource."Global Dimension 1 Code";
                                lSalesInvoiceLineTMP."Shortcut Dimension 2 Code" := lResource."Global Dimension 2 Code";
                                lSalesInvoiceLineTMP."Shortcut Dimension 3 Code" := lResource."Global Dimension 3 Code";
                                lSalesInvoiceLineTMP."Shortcut Dimension 4 Code" := lResource."Global Dimension 4 Code";
                                lSalesInvoiceLineTMP."Shortcut Dimension 5 Code" := lResource."Global Dimension 5 Code";

                            END else
                                ProyectoEmpresa(lJob, lSalesInvLineTMPo."Job No.", pSalesHeader."Nº Proyecto");
                        END;
                    END;
                    lSalesInvoiceLineTMP.Recurso := lSalesInvoiceLineTMP."No.";
                    if lSalesInvoiceLineTMP."Fecha inicial recurso" = 0D THEN lSalesInvoiceLineTMP."Fecha inicial recurso" := pSalesHeader."Fecha inicial proyecto";
                    if lSalesInvoiceLineTMP."Fecha Final recurso" = 0D THEN lSalesInvoiceLineTMP."Fecha Final recurso" := pSalesHeader."Fecha Fin proyecto";
                    lSalesInvoiceLineTMP.INSERT;
                    lResource.CHANGECOMPANY(COMPANYNAME);
                    ltCompany := CompanyName;
                UNTIL lSalesInvLineTMPo.NEXT = 0;

            //Recorro la tabla de lineas de factura para buscar si tiene recursos agrupadod
            lSalesInvoiceLineTMP.SETRANGE(lSalesInvoiceLineTMP."Document No.", "Posting No.");
            liLinea := 10000;
            if lSalesInvoiceLineTMP.FINDFIRST THEN
                REPEAT
                    if lSalesInvoiceLineTMP."Empresa Origen" <> '' THEN BEGIN
                        lReserva.CHANGECOMPANY(lSalesInvoiceLineTMP."Empresa Origen");
                        lCJob := lSalesInvoiceLineTMP."Proyecto Origen";
                        lJob.ChangeCompany(lSalesInvoiceLineTMP."Empresa Origen");
                        lResource.CHANGECOMPANY(lSalesInvoiceLineTMP."Empresa Origen");
                        ltCompany := lSalesInvoiceLineTMP."Empresa Origen";
                        if NOT lResource.GET(lSalesInvoiceLineTMP."No.") THEN lResource.INIT;
                        gRecursoAgrupado := lResource."Recurso Agrupado";
                    END ELSE BEGIN
                        lReserva.CHANGECOMPANY(COMPANYNAME);
                        lJob.ChangeCompany(Companyname);
                        lResource.CHANGECOMPANY(COMPANYNAME);
                        ltCompany := CompanyName;
                        if NOT lResource.GET(lSalesInvoiceLineTMP."No.") THEN lResource.INIT;
                        gRecursoAgrupado := lResource."Recurso Agrupado";
                        lCJob := "Nº proyecto";
                    END;
                    lReserva.RESET;
                    lReserva.SETCURRENTKEY(lReserva."Nº Proyecto", lReserva."Recurso Agrupado");
                    If gRecursoAgrupado then begin
                        lReserva.SETRANGE(lReserva."Recurso Agrupado", lSalesInvoiceLineTMP."No.");
                        lReserva.SETRANGE(lReserva."Linea Agrupado", lSalesInvoiceLineTMP."Line No.");
                    end;
                    lReserva.SETRANGE(lReserva."Nº Proyecto", lCJob);
                    IF NOT lReserva.FINDFIRST THEN lReserva.SETRANGE(lReserva."Linea Agrupado");
                    lReserva.SETFILTER(lReserva."Fecha inicio", '<=%1', lSalesInvoiceLineTMP."Fecha Final recurso");
                    lReserva.SETFILTER(lReserva."Fecha Fin", '>=%1', lSalesInvoiceLineTMP."Fecha inicial recurso");
                    gDTotalliDiasReservas[1] := 0;
                    // Hay que comprobar si el contrato es de fechas flexibles

                    lJob.GET(lCJob);
                    If NOT lReserva.FINDFIRST Then lJob."Fechas Flexibles" := true;
                    if lJob."Fechas Flexibles" THEN BEGIN
                        // Hay que comprobar si el contrato es de fechas flexibles
                        lReserva.SETRANGE(lReserva."Fecha inicio");
                        lReserva.SETRANGE(lReserva."Fecha Fin");
                        lReserva.SETRANGE(lReserva."Linea Agrupado");
                    END;
                    if (gRecursoAgrupado) AND (NOT lReserva.FINDFIRST) THEN
                        ERROR(glErrorAgrupado, lResource."No.", lSalesInvoiceLineTMP."Empresa Origen", lCJob, lSalesInvoiceLineTMP."Fecha inicial recurso", lSalesInvoiceLineTMP."Fecha Final recurso");
                    if gRecursoAgrupado THEN lbAgrupado := TRUE else lbAgrupado := False;

                    //recupero las fechas
                    if (lReserva.FINDFIRST) And (gRecursoAgrupado) THEN
                        REPEAT
                            iNumeroReservas := iNumeroReservas + 1;
                            ldFI := lReserva."Fecha inicio";
                            ldFF := lReserva."Fecha Fin";
                            if ldFI <= lSalesInvoiceLineTMP."Fecha inicial recurso" THEN
                                ldFI := lSalesInvoiceLineTMP."Fecha inicial recurso";
                            ldFF := lReserva."Fecha Fin";
                            if ldFF >= lSalesInvoiceLineTMP."Fecha Final recurso" THEN
                                ldFF := lSalesInvoiceLineTMP."Fecha Final recurso";
                            liDiasReserva := ldFF - ldFI;
                            if liDiasReserva = 0 THEN liDiasReserva := 1;
                            gDTotalliDiasReservas[1] := gDTotalliDiasReservas[1] + liDiasReserva;
                        UNTIL lReserva.NEXT = 0;
                    //if lJob."Fechas Flexibles" THEN gDTotalliDiasReservas[1] := lReserva.Count;
                    iNumeroReservas := 0;
                    if gDTotalliDiasReservas[1] = 0 THEN gDTotalliDiasReservas[1] := 1;
                    if (lReserva.FINDFIRST) And (gRecursoAgrupado) THEN BEGIN
                        REPEAT
                            iNumeroReservas := iNumeroReservas + 1;
                            ldFI := lReserva."Fecha inicio";
                            ldFF := lReserva."Fecha Fin";
                            if ldFI <= lSalesInvoiceLineTMP."Fecha inicial recurso" THEN
                                ldFI := lSalesInvoiceLineTMP."Fecha inicial recurso";
                            ldFF := lReserva."Fecha Fin";
                            if ldFF >= lSalesInvoiceLineTMP."Fecha Final recurso" THEN
                                ldFF := lSalesInvoiceLineTMP."Fecha Final recurso";
                            //calculo el número de dias
                            liDiasReserva := ldFF - ldFI;
                            // if lJob."Fechas Flexibles" THEN begin
                            //     ldFF := lSalesInvoiceLineTMP."Fecha Final recurso";
                            //     ldFI := lSalesInvoiceLineTMP."Fecha inicial recurso";
                            //     liDiasReserva := ldFF - ldFI;
                            // end;
                            if liDiasReserva = 0 THEN liDiasReserva := 1;
                            lSalesInvoiceLineTMPt := lSalesInvoiceLineTMP;
                            lSalesInvoiceLineTMPt."Line No." := liLinea;//lSalesInvoiceLineTMPt."Line No."+b;
                            lSalesInvoiceLineTMPt."No." := lReserva."Nº Recurso";
                            lSalesInvoiceLineTMPt.Quantity := lSalesInvoiceLineTMP.Quantity;
                            lSalesInvoiceLineTMPt."Unit Price" := Redondear(lSalesInvoiceLineTMP."Unit Price" / gDTotalliDiasReservas[1] * liDiasReserva, TRUE, pSalesHeader);
                            lSalesInvoiceLineTMPt."Unit Cost (LCY)" := Redondear(lSalesInvoiceLineTMP."Unit Cost (LCY)" / gDTotalliDiasReservas[1] * liDiasReserva, TRUE, pSalesHeader);
                            lSalesInvoiceLineTMPt."Line Discount Amount" := Redondear(lSalesInvoiceLineTMP."Line Discount Amount" / gDTotalliDiasReservas[1] * liDiasReserva, FALSE, pSalesHeader);
                            lSalesInvoiceLineTMPt."Pmt. Discount Amount" := Redondear(lSalesInvoiceLineTMP."Pmt. Discount Amount" / gDTotalliDiasReservas[1] * liDiasReserva, FALSE, pSalesHeader);
                            lSalesInvoiceLineTMPt.Amount := Redondear(lSalesInvoiceLineTMP.Amount / gDTotalliDiasReservas[1] * liDiasReserva, FALSE, pSalesHeader);
                            lSalesInvoiceLineTMPt."Amount Including VAT" := Redondear(lSalesInvoiceLineTMP."Amount Including VAT" / gDTotalliDiasReservas[1] * liDiasReserva, FALSE, pSalesHeader);
                            lSalesInvoiceLineTMPt."Line Amount" := Redondear(lSalesInvoiceLineTMP."Line Amount" / gDTotalliDiasReservas[1] * liDiasReserva, FALSE, pSalesHeader);
                            if lSalesInvoiceLineTMP."Empresa Origen" <> '' THEN BEGIN
                                lResource.CHANGECOMPANY(lSalesInvoiceLineTMP."Empresa Origen");
                                ltCompany := lSalesInvoiceLineTMP."Empresa Origen";
                            END ELSE BEGIN
                                lResource.CHANGECOMPANY(COMPANYNAME);
                                ltCompany := CompanyName;
                            END;
                            if NOT lResource.GET(lReserva."Nº Recurso") THEN BEGIN
                                lResource.RESET;
                                lResource.CHANGECOMPANY(COMPANYNAME);
                                ltCompany := CompanyName;
                                if Not lResource.GET(lReserva."Nº Recurso") then lResource.Init();
                            END;
                            lSalesInvoiceLineTMPt."Shortcut Dimension 1 Code" := lResource."Global Dimension 1 Code";
                            lSalesInvoiceLineTMPt."Shortcut Dimension 2 Code" := lResource."Global Dimension 2 Code";
                            lSalesInvoiceLineTMPt."Shortcut Dimension 3 Code" := lResource."Global Dimension 3 Code";
                            lSalesInvoiceLineTMPt."Shortcut Dimension 4 Code" := lResource."Global Dimension 4 Code";
                            lSalesInvoiceLineTMPt."Shortcut Dimension 5 Code" := lResource."Global Dimension 5 Code";
                            If ltCompany <> CompanyName THEN BEGIN
                                rRel.SETRANGE(rRel."Empresa Origen", ltCompany);
                                rRel.SETRANGE(rRel."Grupo Contable Origen", lResource."Gen. Prod. Posting Group");
                                rRel.SETRANGE(rRel."Empresa Destino", COMPANYNAME);
                                if rRel.FINDFIRST THEN
                                    lResource."Gen. Prod. Posting Group" := rRel."Grupo Contable Destino"
                            END;
                            if lResource."Gen. Prod. Posting Group" <> '' Then
                                lSalesInvoiceLineTMPt."Gen. Prod. Posting Group" := lResource."Gen. Prod. Posting Group";
                            lSalesInvoiceLineTMPt."Dimension Set ID" := lclcControldeProcesos.GetDefaultDimID2(lResource."Global Dimension 1 Code", lResource."Global Dimension 2 Code",
                                lResource."Global Dimension 3 Code", lResource."Global Dimension 4 Code", lResource."Global Dimension 5 Code");
                            lSalesInvoiceLineTMPt."Recurso agrupado" := lbAgrupado;
                            lSalesInvoiceLineTMPt.INSERT;
                            liLinea := liLinea + 10000;
                        UNTIL lReserva.NEXT = 0;
                    END ELSE BEGIN
                        //si no es recurso agrupado inserto igualmente la línea
                        lSalesInvoiceLineTMPt := lSalesInvoiceLineTMP;
                        lSalesInvoiceLineTMPt."Line No." := liLinea;
                        if NOT lResource.GET(lSalesInvoiceLineTMPt."No.") THEN BEGIN
                            lResource.RESET;
                            lResource.CHANGECOMPANY(COMPANYNAME);
                            ltCompany := CompanyName;
                        end;
                        If lResource.GET(lSalesInvoiceLineTMPt."No.") THEN BEGIN

                            lSalesInvoiceLineTMPt."Shortcut Dimension 1 Code" := lResource."Global Dimension 1 Code";
                            lSalesInvoiceLineTMPt."Shortcut Dimension 2 Code" := lResource."Global Dimension 2 Code";
                            lSalesInvoiceLineTMPt."Shortcut Dimension 3 Code" := lResource."Global Dimension 3 Code";
                            lSalesInvoiceLineTMPt."Shortcut Dimension 4 Code" := lResource."Global Dimension 4 Code";
                            lSalesInvoiceLineTMPt."Shortcut Dimension 5 Code" := lResource."Global Dimension 5 Code";
                            If ltCompany <> CompanyName THEN BEGIN
                                rRel.SETRANGE(rRel."Empresa Origen", ltCompany);
                                rRel.SETRANGE(rRel."Grupo Contable Origen", lResource."Gen. Prod. Posting Group");
                                rRel.SETRANGE(rRel."Empresa Destino", COMPANYNAME);
                                if rRel.FINDFIRST THEN
                                    lResource."Gen. Prod. Posting Group" := rRel."Grupo Contable Destino"
                            END;
                            if lResource."Gen. Prod. Posting Group" <> '' Then
                                lSalesInvoiceLineTMPt."Gen. Prod. Posting Group" := lResource."Gen. Prod. Posting Group";
                            lSalesInvoiceLineTMPt."Dimension Set ID" := lclcControldeProcesos.GetDefaultDimID2(lResource."Global Dimension 1 Code", lResource."Global Dimension 2 Code",
                                lResource."Global Dimension 3 Code", lResource."Global Dimension 4 Code", lResource."Global Dimension 5 Code");
                        end;
                        if lSalesInvoiceLineTMPt.INSERT THEN;
                        liLinea := liLinea + 10000;
                    END;
                UNTIL lSalesInvoiceLineTMP.NEXT = 0;
            // Ahora busco si es de producción
            Produccion(lSalesInvoiceLineTMPt, lSalesInvoiceLineTMPt2, lResource, "Nº Proyecto", lbAgrupado, pSalesHeader."Currency Code");
            lSalesShptHdr.TransferFields(pSalesHeader);
            lSalesShptHdr."No." := pSalesHeader."Posting No.";
            lSalesShptHdr.INSERT;
            if lSalesInvoiceLineTMPt2.FINDFIRST THEN
                REPEAT
                    lSalesShptLine.TransferFields(lSalesInvoiceLineTMPt2);
                    lSalesShptLine."Line Amount" := lSalesInvoiceLineTMPt2."Line Amount";
                    lSalesShptLine."Line Discount Amount" := lSalesInvoiceLineTMPt2."Line Discount Amount";
                    lSalesShptLine.Amount := lSalesInvoiceLineTMPt2.Amount;
                    lSalesShptLine."Inv. Discount Amount" := lSalesInvoiceLineTMPt2."Inv. Discount Amount";
                    lSalesShptLine."Pmt. Disc. Given Amount" := lSalesInvoiceLineTMPt2."Pmt. Discount Amount";
                    lSalesShptLine."Amount Including VAT" := lSalesInvoiceLineTMPt2."Amount Including VAT";
                    lSalesShptLine."EC %" := lSalesInvoiceLineTMPt2."EC %";
                    lSalesShptLine."EC Difference" := lSalesInvoiceLineTMPt2."EC Difference";
                    gCArrayDim[1] := lSalesShptLine."Shortcut Dimension 1 Code";
                    gCArrayDim[2] := lSalesShptLine."Shortcut Dimension 2 Code";
                    gCArrayDim[3] := lSalesShptLine."Shortcut Dimension 3 Code";
                    gCArrayDim[4] := lSalesShptLine."Shortcut Dimension 4 Code";
                    gCArrayDim[5] := lSalesShptLine."Shortcut Dimension 5 Code";
                    if lSalesShptLine.Type = lSalesShptLine.Type::Resource THEN lSalesShptLine."Dimension Set ID" := CompruebaDimensionEnBlanco(gCArrayDim, lSalesShptLine."No.");
                    lSalesShptLine."Recurso Agrupado" := lSalesInvoiceLineTMPt2."Recurso Agrupado";
                    lSalesShptLine.INSERT;
                    gGenLedgerSetup.GET;
                    if NOT lDimValue.GET(gGenLedgerSetup."Shortcut Dimension 1 Code", lSalesShptLine."Shortcut Dimension 1 Code") THEN BEGIN
                        lDimValue.INIT;
                        lDimValue."Dimension Code" := gGenLedgerSetup."Shortcut Dimension 1 Code";
                        lDimValue.Code := lSalesShptLine."Shortcut Dimension 1 Code";
                        lDimValue."Global Dimension No." := 1;
                        if lDimValue.Code <> '' THEN
                            lDimValue.INSERT;
                    END;
                    if NOT lDimValue.GET(gGenLedgerSetup."Shortcut Dimension 2 Code", lSalesShptLine."Shortcut Dimension 2 Code") THEN BEGIN
                        lDimValue.INIT;
                        lDimValue."Dimension Code" := gGenLedgerSetup."Shortcut Dimension 2 Code";
                        lDimValue.Code := lSalesShptLine."Shortcut Dimension 2 Code";
                        lDimValue."Global Dimension No." := 2;
                        if lDimValue.Code <> '' THEN
                            lDimValue.INSERT;
                    END;
                    if NOT lDimValue.GET(gGenLedgerSetup."Shortcut Dimension 3 Code", lSalesShptLine."Shortcut Dimension 3 Code") THEN BEGIN
                        lDimValue.INIT;
                        lDimValue."Dimension Code" := gGenLedgerSetup."Shortcut Dimension 3 Code";
                        lDimValue.Code := lSalesShptLine."Shortcut Dimension 3 Code";
                        lDimValue."Global Dimension No." := 3;
                        if lDimValue.Code <> '' THEN
                            lDimValue.INSERT;
                    END;
                    if NOT lDimValue.GET(gGenLedgerSetup."Shortcut Dimension 4 Code", lSalesShptLine."Shortcut Dimension 4 Code") THEN BEGIN
                        lDimValue.INIT;
                        lDimValue."Dimension Code" := gGenLedgerSetup."Shortcut Dimension 4 Code";
                        lDimValue.Code := lSalesShptLine."Shortcut Dimension 4 Code";
                        lDimValue."Global Dimension No." := 4;
                        if lDimValue.Code <> '' THEN
                            lDimValue.INSERT;
                    END;
                    if NOT lDimValue.GET(gGenLedgerSetup."Shortcut Dimension 5 Code", lSalesShptLine."Shortcut Dimension 5 Code") THEN BEGIN
                        lDimValue.INIT;
                        lDimValue."Dimension Code" := gGenLedgerSetup."Shortcut Dimension 5 Code";
                        lDimValue.Code := lSalesShptLine."Shortcut Dimension 5 Code";
                        lDimValue."Global Dimension No." := 5;
                        if lDimValue.Code <> '' THEN
                            lDimValue.INSERT;
                    END;
                    if lSalesInvoiceLineTMPt2.Type.AsInteger() <> 0 THEN BEGIN
                        if lDimValue2.GET('PRINCIPAL', lSalesInvoiceLineTMPt2."Shortcut Dimension 3 Code") Then lDimValue2.Init;
                        if lDimValue2."Gen. Prod. Posting Group" <> '' THEN BEGIN
                            lGenProdPostGrp.RESET;
                            lGenProdPostGrp.CHANGECOMPANY(COMPANYNAME);
                            if NOT lGenProdPostGrp.GET(lSalesInvoiceLineTMPt2."Gen. Prod. Posting Group") THEN
                                if lDimValue2."Gen. Prod. Posting Group" <> '' Then
                                    lSalesInvoiceLineTMPt2."Gen. Prod. Posting Group" := lDimValue2."Gen. Prod. Posting Group";
                        END ELSE BEGIN
                            lGenProdPostGrp.CHANGECOMPANY(COMPANYNAME);
                            if NOT lGenProdPostGrp.GET(lSalesInvoiceLineTMPt2."Gen. Prod. Posting Group") THEN BEGIN
                                if lSalesInvoiceLineTMPt2."Empresa Origen" = '' THEN
                                    lGenProdPostGrp.CHANGECOMPANY(COMPANYNAME)
                                ELSE
                                    lGenProdPostGrp.CHANGECOMPANY(lSalesInvoiceLineTMPt2."Empresa Origen");
                                if lGenProdPostGrp.GET(lSalesInvoiceLineTMPt2."Gen. Prod. Posting Group") THEN BEGIN
                                    lGenProdPostGrp.SETRANGE(lGenProdPostGrp."Filtro Empresa Origen", lSalesInvoiceLineTMPt2."Empresa Origen");
                                    lGenProdPostGrp.SETRANGE(lGenProdPostGrp."Filtro Empresa Destino", COMPANYNAME);
                                    lGenProdPostGrp.CALCFIELDS(lGenProdPostGrp."Grupo Equivalente");
                                    if lGenProdPostGrp."Grupo Equivalente" = '' THEN
                                        ERROR(glEquivalencia,
                                        lSalesInvoiceLineTMPt2."Empresa Origen", COMPANYNAME, lSalesInvoiceLineTMPt2."Gen. Prod. Posting Group");
                                    lSalesInvoiceLineTMPt2."Gen. Prod. Posting Group" := lGenProdPostGrp."Grupo Equivalente";
                                END;
                            END;
                        END;
                    END;
                    if lSalesInvoiceLineTMPt2."Gen. Prod. Posting Group" <> '' Then
                        lSalesShptLine."Gen. Prod. Posting Group" := lSalesInvoiceLineTMPt2."Gen. Prod. Posting Group";
                    gCArrayDim[1] := lSalesShptLine."Shortcut Dimension 1 Code";
                    gCArrayDim[2] := lSalesShptLine."Shortcut Dimension 2 Code";
                    gCArrayDim[3] := lSalesShptLine."Shortcut Dimension 3 Code";
                    gCArrayDim[4] := lSalesShptLine."Shortcut Dimension 4 Code";
                    gCArrayDim[5] := lSalesShptLine."Shortcut Dimension 5 Code";
                    if lSalesShptLine.Type = lSalesShptLine.Type::Resource THEN lSalesShptLine."Dimension Set ID" := CompruebaDimensionEnBlanco(gCArrayDim, lSalesShptLine."No.");
                    lSalesShptLine."Tax Area Code" := pSalesHeader."No.";
                    lSalesShptLine.MODIFY;
                UNTIL lSalesInvoiceLineTMPt2.NEXT = 0;
            if lSalesShptHdr.GET("Posting No.") THEN BEGIN
                lSalesShptHdr.CALCFIELDS(lSalesShptHdr.Amount, lSalesShptHdr."Amount Including VAT");
                CALCFIELDS(Amount, "Amount Including VAT");
                lDImporte := Amount - lSalesShptHdr.Amount;
                if Abs(lDImporte) > Abs(lSalesShptHdr.Amount) Then Error(glErrorDesglose);
                lDImporteIvaIncluido := "Amount Including VAT" - lSalesShptHdr."Amount Including VAT";
                lSalesInvLineTMPo.SETRANGE(lSalesInvLineTMPo."Document No.", "Posting No.");
                lSalesInvLineTMPo.SETRANGE(lSalesInvLineTMPo.Type, lSalesInvLineTMPo.Type::Resource);
                if NOT lSalesInvLineTMPo.FINDFIRST THEN
                    lSalesInvLineTMPo.SETRANGE(lSalesInvLineTMPo.Type, lSalesInvLineTMPo.Type::"G/L Account");
                if lSalesInvLineTMPo.FINDFIRST THEN BEGIN
                    if (lDImporte <> 0) OR (lDImporteIvaIncluido <> 0) THEN BEGIN
                        lSalesShptLine.SETRANGE(lSalesShptLine."Document No.", "Posting No.");
                        lSalesShptLine.FINDLAST;
                        gDTotalliDiasReservas[1] := lSalesShptLine."Line No.";
                        lResource.RESET;
                        lResource.CHANGECOMPANY(COMPANYNAME);
                        ltCompany := CompanyName;
                        lResource.GET(lSalesInvLineTMPo."No.");
                        If ltCompany <> CompanyName THEN BEGIN
                            rRel.SETRANGE(rRel."Empresa Origen", ltCompany);
                            rRel.SETRANGE(rRel."Grupo Contable Origen", lResource."Gen. Prod. Posting Group");
                            rRel.SETRANGE(rRel."Empresa Destino", COMPANYNAME);
                            if rRel.FINDFIRST THEN
                                lResource."Gen. Prod. Posting Group" := rRel."Grupo Contable Destino"
                        END;
                        If not gGenPostingSetup.GET("Gen. Bus. Posting Group", lResource."Gen. Prod. Posting Group") then
                            gGenPostingSetup.Get(lSalesInvLineTMPo."Gen. Bus. Posting Group", lSalesInvLineTMPo."Gen. Prod. Posting Group");
                        lSalesShptLine."Line No." := gDTotalliDiasReservas[1] + 1;
                        lSalesShptLine.Type := lSalesShptLine.Type::"G/L Account";
                        lSalesShptLine."No." := gGenPostingSetup."Sales Account";
                        lSalesShptLine.Description := 'Redondeo factura';
                        lSalesShptLine.Quantity := 1;
                        CompruebaErrorRedondeo(lDImporte);

                        lSalesShptLine."Unit Price" := lDImporte;
                        lSalesShptLine."Line Discount %" := 0;
                        lSalesShptLine."VAT Base Amount" := lDImporte;
                        lSalesShptLine."Line Amount" := lDImporte;
                        lSalesShptLine.Amount := lDImporte;
                        CompruebaErrorRedondeo(lDImporteIvaIncluido);
                        lSalesShptLine."Amount Including VAT" := lDImporteIvaIncluido;
                        lSalesShptLine."Inv. Discount Amount" := 0;
                        lSalesShptLine."Pmt. Disc. Given Amount" := 0;
                        lSalesShptLine."Gen. Bus. Posting Group" := lSalesInvLineTMPo."Gen. Bus. Posting Group";
                        if lSalesInvLineTMPo."Gen. Prod. Posting Group" <> '' Then
                            lSalesShptLine."Gen. Prod. Posting Group" := lSalesInvLineTMPo."Gen. Prod. Posting Group";
                        lSalesShptLine."VAT Bus. Posting Group" := lSalesInvLineTMPo."VAT Bus. Posting Group";
                        lSalesShptLine."VAT Prod. Posting Group" := lSalesInvLineTMPo."VAT Prod. Posting Group";
                        gCArrayDim[1] := lSalesShptLine."Shortcut Dimension 1 Code";
                        gCArrayDim[2] := lSalesShptLine."Shortcut Dimension 2 Code";
                        gCArrayDim[3] := lSalesShptLine."Shortcut Dimension 3 Code";
                        gCArrayDim[4] := lSalesShptLine."Shortcut Dimension 4 Code";
                        gCArrayDim[5] := lSalesShptLine."Shortcut Dimension 5 Code";
                        if lSalesShptLine.Type = lSalesShptLine.Type::Resource THEN lSalesShptLine."Dimension Set ID" := CompruebaDimensionEnBlanco(gCArrayDim, lSalesShptLine."No.");
                        lSalesShptLine.INSERT;
                    END;
                END;
            END;
            // PostDim.SETRANGE(PostDim."Table ID","Sales Shipment Line");
            // PostDim.SETRANGE(PostDim."Document No.","Posting No.");
            // if PostDim.FINDFIRST THEN REPEAT
            // TempDocDimDes."Table ID":="Sales Line";
            // TempDocDimDes."Document Type":="Document Type";
            // TempDocDimDes."Document No.":="Posting No.";
            // TempDocDimDes."Line No.":=PostDim."Line No.";
            // TempDocDimDes."Dimension Code":=PostDim."Dimension Code";
            // TempDocDimDes."Dimension Value Code":=PostDim."Dimension Value Code";
            // TempDocDimDes.INSERT;
            // UNTIL PostDim.NEXT=0;
        END;
    END;

    Procedure CompruebaErrorRedondeo(pImporte: Decimal)
    Var
        lGenLedgerSetup: Record "General Ledger Setup";
    Begin
        lGenLedgerSetup.GET;
        if lGenLedgerSetup."No Comprobar Redondeo" then exit;
        if pImporte <> 0 then
            if ABS(pImporte) > 1000 Then Error('Imposible desglosar, concacte con informática');

    End;

    Procedure DesglosarCompra(var pPurchaseHeader: Record "Purchase Header")
    Var
        lPurchInvLineTMP: Record "Purch. Inv. Line" temporary;
        lReserva: Record "Reserva";
        lPurchInvLineTMPt: Record "Purch. Inv. Line" temporary;
        lPurchRcptLine: Record "Purch. Rcpt. Line";
        lPurchRcptHdr: Record "Purch. Rcpt. Header";
        iNumeroReservas: Integer;
        lResource: Record "Resource";
        lPurchInvLineTMPt2: Record "Purch. Inv. Line" temporary;
        liDiasReserva: Integer;
        ldFI: Date;
        ldFF: Date;
        lDImporte: Decimal;
        lDImporteIvaIncluido: Decimal;
        lPurchInvLineTMPo: Record "Purch. Inv. Line" temporary;
        lJob: Record "Job";
        lCJob: Code[20];
        ltComp: Text[30];
        lDimValue: Record "Dimension Value";
        lPurchaseLine: Record "Purchase Line";
        lGenProdPostGrp: Record "Gen. Product Posting Group";
        lDimValue2: Record "Dimension Value";
        lCJob2: Text[30];
        liLinea: Integer;
        lbAgrupado: boolean;
        g: Integer;
        lcControldeProcesos: Codeunit ControlProcesos;
        ltCompany: Text[30];
        rRel: Record "Relación Grupos";
    Begin
        WITH pPurchaseHeader DO BEGIN
            lPurchRcptLine.SETRANGE(lPurchRcptLine."Document No.", "Posting No.");
            lPurchRcptLine.DELETEALL;
            if lPurchRcptHdr.GET("Posting No.") THEN lPurchRcptHdr.DELETE;
            //Inserto tabla temporal con las líneas originales
            lPurchaseLine.SETRANGE(lPurchaseLine."Document Type", "Document Type");
            lPurchaseLine.SETRANGE(lPurchaseLine.Type, 1, 999);
            lPurchaseLine.SETRANGE(lPurchaseLine."Document No.", "No.");
            if lPurchaseLine.FINDFIRST THEN
                REPEAT
                    lPurchInvLineTMPo.TransferFields(lPurchaseLine);
                    lPurchInvLineTMPo."Posting Date" := "Posting Date";
                    lPurchInvLineTMPo."Document No." := "Posting No.";
                    lPurchInvLineTMPo.Quantity := lPurchaseLine."Qty. to Invoice";
                    lPurchInvLineTMPo."Quantity (Base)" := lPurchaseLine."Qty. to Invoice (Base)";
                    if lPurchInvLineTMPo."Job No." = '' Then begin
                        lPurchInvLineTMPo."Job No." := pPurchaseHeader."Nº Proyecto";
                    end;
                    lPurchInvLineTMPo.INSERT;
                UNTIL lPurchaseLine.NEXT = 0;
            //Miro si el recurso es de otra empresa y le asigno recurso y proyecto de la empresa origen
            lPurchInvLineTMPo.SETRANGE(lPurchInvLineTMPo."Document No.", "Posting No.");
            if lPurchInvLineTMPo.FINDFIRST THEN
                REPEAT
                    lPurchInvLineTMP := lPurchInvLineTMPo;
                    if lPurchInvLineTMPo.Type = lPurchInvLineTMPo.Type::Resource THEN BEGIN
                        if lResource.GET(lPurchInvLineTMPo."No.") THEN BEGIN
                            lPurchInvLineTMP."Shortcut Dimension 1 Code" := lResource."Global Dimension 1 Code";
                            lPurchInvLineTMP."Shortcut Dimension 2 Code" := lResource."Global Dimension 2 Code";
                            lPurchInvLineTMP."Shortcut Dimension 3 Code" := lResource."Global Dimension 3 Code";
                            lPurchInvLineTMP."Shortcut Dimension 4 Code" := lResource."Global Dimension 4 Code";
                            lPurchInvLineTMP."Shortcut Dimension 5 Code" := lResource."Global Dimension 5 Code";

                            if (lResource."Empresa Origen" <> COMPANYNAME) AND (lResource."Empresa Origen" <> '')
                            And (lPurchInvLineTMPo."Job No." <> '') THEN BEGIN
                                lPurchInvLineTMP."No." := lResource."Nº En Empresa origen";
                                lPurchInvLineTMP."Empresa Origen" := lResource."Empresa Origen";
                                recuperaproyecto(lJob, lPurchInvLineTMPo."Job No.", lResource);
                                lPurchInvLineTMP."Proyecto Origen" := lJob."No.";
                                lResource.CHANGECOMPANY(lResource."Empresa Origen");
                                ltCompany := lResource."Empresa Origen";
                                if NOT lResource.GET(lPurchInvLineTMP."No.") THEN lResource.INIT;
                                lPurchInvLineTMP."Shortcut Dimension 1 Code" := lResource."Global Dimension 1 Code";
                                lPurchInvLineTMP."Shortcut Dimension 2 Code" := lResource."Global Dimension 2 Code";
                                lPurchInvLineTMP."Shortcut Dimension 3 Code" := lResource."Global Dimension 3 Code";
                                lPurchInvLineTMP."Shortcut Dimension 4 Code" := lResource."Global Dimension 4 Code";
                                lPurchInvLineTMP."Shortcut Dimension 5 Code" := lResource."Global Dimension 5 Code";

                            END else
                                ProyectoEmpresa(lJob, lPurchInvLineTMPo."Job No.", pPurchaseHeader."Nº Proyecto");
                        END;
                    END;
                    lPurchInvLineTMP.Recurso := lPurchInvLineTMP."No.";
                    if lPurchInvLineTMP."Fecha inicial recurso" = 0D THEN lPurchInvLineTMP."Fecha inicial recurso" := pPurchaseHeader."Fecha inicial proyecto";
                    if lPurchInvLineTMP."Fecha Final recurso" = 0D THEN lPurchInvLineTMP."Fecha Final recurso" := pPurchaseHeader."Fecha Fin proyecto";
                    lPurchInvLineTMP.INSERT;
                    lResource.CHANGECOMPANY(COMPANYNAME);
                    ltCompany := CompanyName;
                UNTIL lPurchInvLineTMPo.NEXT = 0;

            //Recorro la tabla de liLineas de factura para buscar si tiene recursos agrupadod
            lPurchInvLineTMP.SETRANGE(lPurchInvLineTMP."Document No.", "Posting No.");
            liLinea := 10000;
            if lPurchInvLineTMP.FINDFIRST THEN
                REPEAT
                    gRecursoAgrupado := false;
                    if lPurchInvLineTMP."Empresa Origen" <> '' THEN BEGIN
                        lReserva.CHANGECOMPANY(lPurchInvLineTMP."Empresa Origen");
                        ltCompany := lPurchInvLineTMP."Empresa Origen";
                        lCJob := lPurchInvLineTMP."Proyecto Origen";
                        lJob.ChangeCompany(lPurchInvLineTMP."Empresa Origen");
                        lResource.CHANGECOMPANY(lPurchInvLineTMP."Empresa Origen");
                        if NOT lResource.GET(lPurchInvLineTMP."No.") THEN lResource.INIT;
                        gRecursoAgrupado := lResource."Recurso Agrupado";
                    END ELSE BEGIN
                        lReserva.CHANGECOMPANY(COMPANYNAME);
                        lJob.ChangeCompany(Companyname);
                        lResource.CHANGECOMPANY(COMPANYNAME);
                        ltCompany := CompanyName;
                        if NOT lResource.GET(lPurchInvLineTMP."No.") THEN lResource.INIT;
                        gRecursoAgrupado := lResource."Recurso Agrupado";
                        lCJob := "Nº Proyecto";
                    END;
                    lReserva.RESET;
                    lReserva.SETCURRENTKEY(lReserva."Nº Proyecto", lReserva."Recurso Agrupado");


                    IF NOT lReserva.FINDFIRST THEN lReserva.SETRANGE(lReserva."Linea Agrupado");
                    lReserva.SETRANGE(lReserva."Nº Proyecto", lCJob);
                    lReserva.SETFILTER(lReserva."Fecha inicio", '<=%1', lPurchInvLineTMP."Fecha Final recurso");
                    lReserva.SETFILTER(lReserva."Fecha Fin", '>=%1', lPurchInvLineTMP."Fecha inicial recurso");
                    gDTotalliDiasReservas[1] := 0;
                    lJob.Get(lCJob);
                    If NOT lReserva.FINDFIRST Then lJob."Fechas Flexibles" := true;
                    if lJob."Fechas Flexibles" THEN begin
                        lReserva.SetRange("Fecha inicio");
                        lReserva.SetRange("Fecha Fin");
                        lReserva.SETRANGE(lReserva."Linea Agrupado");
                    end;
                    if (gRecursoAgrupado) AND (NOT lReserva.FINDFIRST) THEN
                        ERROR(glErrorAgrupado, lPurchInvLineTMP."No.", lPurchInvLineTMP."Empresa Origen", lCJob, lPurchInvLineTMP."Fecha inicial recurso", lPurchInvLineTMP."Fecha Final recurso");
                    if lResource."Recurso Agrupado" THEN lbAgrupado := TRUE else lbAgrupado := False;
                    //recupero las fechas
                    if (lReserva.FINDFIRST) And (gRecursoAgrupado) THEN
                        REPEAT
                            iNumeroReservas := iNumeroReservas + 1;
                            ldFI := lReserva."Fecha inicio";
                            ldFF := lReserva."Fecha Fin";
                            if ldFI <= lPurchInvLineTMP."Fecha inicial recurso" THEN
                                ldFI := lPurchInvLineTMP."Fecha inicial recurso";
                            ldFF := lReserva."Fecha Fin";
                            if ldFF >= lPurchInvLineTMP."Fecha Final recurso" THEN
                                ldFF := lPurchInvLineTMP."Fecha Final recurso";
                            liDiasReserva := ldFF - ldFI;
                            if liDiasReserva = 0 THEN liDiasReserva := 1;
                            gDTotalliDiasReservas[1] := gDTotalliDiasReservas[1] + liDiasReserva;
                        UNTIL lReserva.NEXT = 0;
                    iNumeroReservas := 0;
                    //if lJob."Fechas Flexibles" THEN gDTotalliDiasReservas[1] := lReserva.Count;
                    if gDTotalliDiasReservas[1] = 0 Then gDTotalliDiasReservas[1] := 1;
                    if (lReserva.FINDFIRST) and (gRecursoAgrupado) THEN BEGIN
                        REPEAT
                            iNumeroReservas := iNumeroReservas + 1;
                            ldFI := lReserva."Fecha inicio";
                            ldFF := lReserva."Fecha Fin";
                            if ldFI <= lPurchInvLineTMP."Fecha inicial recurso" THEN
                                ldFI := lPurchInvLineTMP."Fecha inicial recurso";
                            ldFF := lReserva."Fecha Fin";
                            if ldFF >= lPurchInvLineTMP."Fecha Final recurso" THEN
                                ldFF := lPurchInvLineTMP."Fecha Final recurso";
                            //calculo el número de dias
                            liDiasReserva := ldFF - ldFI;
                            // if lJob."Fechas Flexibles" THEN begin
                            //     ldFI := lPurchInvLineTMP."Fecha inicial recurso";
                            //     ldFF := lPurchInvLineTMP."Fecha Final recurso";
                            //     liDiasReserva := ldFF - ldFI;
                            // end;
                            if liDiasReserva = 0 THEN liDiasReserva := 1;
                            lPurchInvLineTMPt := lPurchInvLineTMP;
                            lPurchInvLineTMPt."Line No." := liLinea;//lPurchInvLineTMPt."Line No."+b;
                            lPurchInvLineTMPt."No." := lReserva."Nº Recurso";
                            lPurchInvLineTMPt.Quantity := lPurchInvLineTMP.Quantity;
                            lPurchInvLineTMPt."Direct Unit Cost" := Redondear(lPurchInvLineTMP."Direct Unit Cost" / gDTotalliDiasReservas[1] * liDiasReserva, TRUE, pPurchaseHeader."Currency Code");
                            lPurchInvLineTMPt."Unit Cost (LCY)" := Redondear(lPurchInvLineTMP."Unit Cost (LCY)" / gDTotalliDiasReservas[1] * liDiasReserva, TRUE, pPurchaseHeader."Currency Code");
                            lPurchInvLineTMPt."Line Discount Amount" := Redondear(lPurchInvLineTMP."Line Discount Amount" / gDTotalliDiasReservas[1] * liDiasReserva, FALSE, pPurchaseHeader."Currency Code");
                            lPurchInvLineTMPt."Pmt. Discount Amount" := Redondear(lPurchInvLineTMP."Pmt. Discount Amount" / gDTotalliDiasReservas[1] * liDiasReserva, FALSE, pPurchaseHeader."Currency Code");
                            lPurchInvLineTMPt.Amount := Redondear(lPurchInvLineTMP.Amount / gDTotalliDiasReservas[1] * liDiasReserva, FALSE, pPurchaseHeader."Currency Code");
                            lPurchInvLineTMPt."Amount Including VAT" := Redondear(lPurchInvLineTMP."Amount Including VAT" / gDTotalliDiasReservas[1] * liDiasReserva, FALSE, pPurchaseHeader."Currency Code");
                            lPurchInvLineTMPt."Line Amount" := Redondear(lPurchInvLineTMP."Line Amount" / gDTotalliDiasReservas[1] * liDiasReserva, FALSE, pPurchaseHeader."Currency Code");
                            if lPurchInvLineTMP."Empresa Origen" <> '' THEN BEGIN
                                lResource.CHANGECOMPANY(lPurchInvLineTMP."Empresa Origen");
                                ltCompany := lPurchInvLineTMP."Empresa Origen";
                            END ELSE BEGIN
                                lResource.CHANGECOMPANY(COMPANYNAME);
                                ltCompany := CompanyName;
                            END;
                            if NOT lResource.GET(lReserva."Nº Recurso") THEN BEGIN
                                lResource.RESET;
                                lResource.ChangeCompany(CompanyName);
                                ltCompany := CompanyName;
                                if Not lResource.GET(lReserva."Nº Recurso") then lResource.Init();
                            END;
                            lPurchInvLineTMPt."Shortcut Dimension 1 Code" := lResource."Global Dimension 1 Code";
                            lPurchInvLineTMPt."Shortcut Dimension 2 Code" := lResource."Global Dimension 2 Code";
                            lPurchInvLineTMPt."Shortcut Dimension 3 Code" := lResource."Global Dimension 3 Code";
                            lPurchInvLineTMPt."Shortcut Dimension 4 Code" := lResource."Global Dimension 4 Code";
                            lPurchInvLineTMPt."Shortcut Dimension 5 Code" := lResource."Global Dimension 5 Code";
                            If ltCompany <> CompanyName THEN BEGIN
                                rRel.SETRANGE(rRel."Empresa Origen", ltCompany);
                                rRel.SETRANGE(rRel."Grupo Contable Origen", lResource."Gen. Prod. Posting Group");
                                rRel.SETRANGE(rRel."Empresa Destino", COMPANYNAME);
                                if rRel.FINDFIRST THEN
                                    lResource."Gen. Prod. Posting Group" := rRel."Grupo Contable Destino"
                            END;
                            if lResource."Gen. Prod. Posting Group" <> '' Then
                                lPurchInvLineTMPt."Gen. Prod. Posting Group" := lResource."Gen. Prod. Posting Group";
                            lPurchInvLineTMPt."Recurso agrupado" := lbAgrupado;
                            lPurchInvLineTMPt.INSERT;
                            liLinea := liLinea + 10000;
                        UNTIL lReserva.NEXT = 0;
                    END ELSE BEGIN
                        //si no es recurso agrupado inserto igualmente la línea
                        lPurchInvLineTMPt := lPurchInvLineTMP;
                        lPurchInvLineTMPt."Line No." := liLinea;
                        if lPurchInvLineTMPt.INSERT THEN;
                        liLinea := liLinea + 10000;
                    END;
                UNTIL lPurchInvLineTMP.NEXT = 0;
            // Ahora busco si es de producción
            Produccion(lPurchInvLineTMPt, lPurchInvLineTMPt2, lResource, "Nº Proyecto", lbAgrupado, pPurchaseHeader."Currency Code");
            lPurchRcptHdr.TransferFields(pPurchaseHeader);
            lPurchRcptHdr."No." := pPurchaseHeader."Posting No.";
            lPurchRcptHdr.INSERT;
            if lPurchInvLineTMPt2.FINDFIRST THEN
                REPEAT
                    lPurchRcptLine.TransferFields(lPurchInvLineTMPt2);
                    lPurchRcptLine."Line Amount" := lPurchInvLineTMPt2."Line Amount";
                    lPurchRcptLine."Line Discount Amount" := lPurchInvLineTMPt2."Line Discount Amount";
                    lPurchRcptLine.Amount := lPurchInvLineTMPt2.Amount;
                    lPurchRcptLine."Amount Including VAT" := lPurchInvLineTMPt2."Amount Including VAT";
                    gCArrayDim[1] := lPurchRcptLine."Shortcut Dimension 1 Code";
                    gCArrayDim[2] := lPurchRcptLine."Shortcut Dimension 2 Code";
                    gCArrayDim[3] := lPurchRcptLine."Shortcut Dimension 3 Code";
                    gCArrayDim[4] := lPurchRcptLine."Shortcut Dimension 4 Code";
                    gCArrayDim[5] := lPurchRcptLine."Shortcut Dimension 5 Code";
                    if lPurchRcptLine.Type = lPurchRcptLine.Type::Resource THEN lPurchRcptLine."Dimension Set ID" := CompruebaDimensionEnBlanco(gCArrayDim, lPurchRcptLine."No.");
                    lPurchRcptLine."Recurso Agrupado" := lPurchInvLineTMPt2."Recurso Agrupado";
                    lPurchRcptLine.INSERT;
                    gGenLedgerSetup.GET;
                    if NOT lDimValue.GET(gGenLedgerSetup."Shortcut Dimension 1 Code", lPurchRcptLine."Shortcut Dimension 1 Code") THEN BEGIN
                        lDimValue.INIT;
                        lDimValue."Dimension Code" := gGenLedgerSetup."Shortcut Dimension 1 Code";
                        lDimValue.Code := lPurchRcptLine."Shortcut Dimension 1 Code";
                        lDimValue."Global Dimension No." := 1;
                        if lDimValue.Code <> '' THEN
                            lDimValue.INSERT;
                    END;
                    if NOT lDimValue.GET(gGenLedgerSetup."Shortcut Dimension 2 Code", lPurchRcptLine."Shortcut Dimension 2 Code") THEN BEGIN
                        lDimValue.INIT;
                        lDimValue."Dimension Code" := gGenLedgerSetup."Shortcut Dimension 2 Code";
                        lDimValue.Code := lPurchRcptLine."Shortcut Dimension 2 Code";
                        lDimValue."Global Dimension No." := 2;
                        if lDimValue.Code <> '' THEN
                            lDimValue.INSERT;
                    END;
                    if NOT lDimValue.GET(gGenLedgerSetup."Shortcut Dimension 3 Code", lPurchRcptLine."Shortcut Dimension 3 Code") THEN BEGIN
                        lDimValue.INIT;
                        lDimValue."Dimension Code" := gGenLedgerSetup."Shortcut Dimension 3 Code";
                        lDimValue.Code := lPurchRcptLine."Shortcut Dimension 3 Code";
                        lDimValue."Global Dimension No." := 3;
                        if lDimValue.Code <> '' THEN
                            lDimValue.INSERT;
                    END;
                    if NOT lDimValue.GET(gGenLedgerSetup."Shortcut Dimension 4 Code", lPurchRcptLine."Shortcut Dimension 4 Code") THEN BEGIN
                        lDimValue.INIT;
                        lDimValue."Dimension Code" := gGenLedgerSetup."Shortcut Dimension 4 Code";
                        lDimValue.Code := lPurchRcptLine."Shortcut Dimension 4 Code";
                        lDimValue."Global Dimension No." := 4;
                        if lDimValue.Code <> '' THEN
                            lDimValue.INSERT;
                    END;
                    if NOT lDimValue.GET(gGenLedgerSetup."Shortcut Dimension 5 Code", lPurchRcptLine."Shortcut Dimension 5 Code") THEN BEGIN
                        lDimValue.INIT;
                        lDimValue."Dimension Code" := gGenLedgerSetup."Shortcut Dimension 5 Code";
                        lDimValue.Code := lPurchRcptLine."Shortcut Dimension 5 Code";
                        lDimValue."Global Dimension No." := 5;
                        if lDimValue.Code <> '' THEN
                            lDimValue.INSERT;
                    END;
                    if lPurchInvLineTMPt2.Type.AsInteger() <> 0 THEN BEGIN
                        if lDimValue2.GET('PRINCIPAL', lPurchInvLineTMPt2."Shortcut Dimension 3 Code") Then lDimValue2.Init;
                        if lDimValue2."Gen. Prod. Posting Group" <> '' THEN BEGIN
                            lGenProdPostGrp.RESET;
                            lGenProdPostGrp.CHANGECOMPANY(COMPANYNAME);
                            if NOT lGenProdPostGrp.GET(lPurchInvLineTMPt2."Gen. Prod. Posting Group") THEN
                                if lDimValue2."Gen. Prod. Posting Group" <> '' Then
                                    lPurchInvLineTMPt2."Gen. Prod. Posting Group" := lDimValue2."Gen. Prod. Posting Group";
                        END ELSE BEGIN
                            lGenProdPostGrp.CHANGECOMPANY(COMPANYNAME);
                            if NOT lGenProdPostGrp.GET(lPurchInvLineTMPt2."Gen. Prod. Posting Group") THEN BEGIN
                                if lPurchInvLineTMPt2."Empresa Origen" = '' THEN
                                    lGenProdPostGrp.CHANGECOMPANY(COMPANYNAME)
                                ELSE
                                    lGenProdPostGrp.CHANGECOMPANY(lPurchInvLineTMPt2."Empresa Origen");
                                if lGenProdPostGrp.GET(lPurchInvLineTMPt2."Gen. Prod. Posting Group") THEN BEGIN
                                    lGenProdPostGrp.SETRANGE(lGenProdPostGrp."Filtro Empresa Origen", lPurchInvLineTMPt2."Empresa Origen");
                                    lGenProdPostGrp.SETRANGE(lGenProdPostGrp."Filtro Empresa Destino", COMPANYNAME);
                                    lGenProdPostGrp.CALCFIELDS(lGenProdPostGrp."Grupo Equivalente");
                                    if lGenProdPostGrp."Grupo Equivalente" = '' THEN
                                        ERROR(glEquivalencia,
                                        lPurchInvLineTMPt2."Empresa Origen", COMPANYNAME, lPurchInvLineTMPt2."Gen. Prod. Posting Group");
                                    lPurchInvLineTMPt2."Gen. Prod. Posting Group" := lGenProdPostGrp."Grupo Equivalente";
                                END;
                            END;
                        END;
                    END;
                    If lPurchInvLineTMPt2."Gen. Prod. Posting Group" <> '' then
                        lPurchRcptLine."Gen. Prod. Posting Group" := lPurchInvLineTMPt2."Gen. Prod. Posting Group";
                    gCArrayDim[1] := lPurchRcptLine."Shortcut Dimension 1 Code";
                    gCArrayDim[2] := lPurchRcptLine."Shortcut Dimension 2 Code";
                    gCArrayDim[3] := lPurchRcptLine."Shortcut Dimension 3 Code";
                    gCArrayDim[4] := lPurchRcptLine."Shortcut Dimension 4 Code";
                    gCArrayDim[5] := lPurchRcptLine."Shortcut Dimension 5 Code";
                    if lPurchRcptLine.Type = lPurchRcptLine.Type::Resource THEN lPurchRcptLine."Dimension Set ID" := CompruebaDimensionEnBlanco(gCArrayDim, lPurchRcptLine."No.");
                    lPurchRcptLine.MODIFY;
                UNTIL lPurchInvLineTMPt2.NEXT = 0;
            if lPurchRcptHdr.GET("Posting No.") THEN BEGIN
                lPurchRcptHdr.CALCFIELDS(lPurchRcptHdr.Amount, lPurchRcptHdr."Amount Including VAT");
                CALCFIELDS(Amount, "Amount Including VAT");
                lDImporte := Amount - lPurchRcptHdr.Amount;
                if Abs(lDImporte) > Abs(lPurchRcptHdr.Amount) Then Error(glErrorDesglose);
                lDImporteIvaIncluido := "Amount Including VAT" - lPurchRcptHdr."Amount Including VAT";
                lPurchInvLineTMPo.SETRANGE(lPurchInvLineTMPo."Document No.", "Posting No.");
                lPurchInvLineTMPo.SETRANGE(lPurchInvLineTMPo.Type, lPurchInvLineTMPo.Type::Resource);
                if NOT lPurchInvLineTMPo.FINDFIRST THEN
                    lPurchInvLineTMPo.SETRANGE(lPurchInvLineTMPo.Type, lPurchInvLineTMPo.Type::"G/L Account");
                if lPurchInvLineTMPo.FINDFIRST THEN BEGIN
                    if (lDImporte <> 0) OR (lDImporteIvaIncluido <> 0) THEN BEGIN
                        lPurchRcptLine.SETRANGE(lPurchRcptLine."Document No.", "Posting No.");
                        lPurchRcptLine.FINDLAST;
                        gDTotalliDiasReservas[1] := lPurchRcptLine."Line No.";
                        lResource.RESET;
                        lResource.CHANGECOMPANY(COMPANYNAME);
                        lResource.GET(lPurchInvLineTMPo."No.");
                        If Not gGenPostingSetup.GET("Gen. Bus. Posting Group", lResource."Gen. Prod. Posting Group") Then
                            gGenPostingSetup.Get(lPurchInvLineTMPo."Gen. Bus. Posting Group", lpUrchInvLineTMPo."Gen. Prod. Posting Group");
                        lPurchRcptLine."Line No." := gDTotalliDiasReservas[1] + 1;
                        lPurchRcptLine.Type := lPurchRcptLine.Type::"G/L Account";
                        lPurchRcptLine."No." := gGenPostingSetup."Purch. Account";
                        lPurchRcptLine.Description := 'Redondeo factura';
                        lPurchRcptLine.Quantity := 1;
                        CompruebaErrorRedondeo(lDImporte);
                        lPurchRcptLine."Direct Unit Cost" := lDImporte;
                        lPurchRcptLine."Line Discount %" := 0;
                        lPurchRcptLine."VAT Base Amount" := lDImporte;
                        lPurchRcptLine."Line Amount" := lDImporte;
                        lPurchRcptLine.Amount := lDImporte;
                        CompruebaErrorRedondeo(lDImporteIvaIncluido);
                        lPurchRcptLine."Amount Including VAT" := lDImporteIvaIncluido;
                        lPurchRcptLine."Gen. Bus. Posting Group" := lPurchInvLineTMPo."Gen. Bus. Posting Group";
                        if lPurchInvLineTMPo."Gen. Prod. Posting Group" <> '' Then
                            lPurchRcptLine."Gen. Prod. Posting Group" := lPurchInvLineTMPo."Gen. Prod. Posting Group";
                        lPurchRcptLine."VAT Bus. Posting Group" := lPurchInvLineTMPo."VAT Bus. Posting Group";
                        lPurchRcptLine."VAT Prod. Posting Group" := lPurchInvLineTMPo."VAT Prod. Posting Group";
                        gCArrayDim[1] := lPurchRcptLine."Shortcut Dimension 1 Code";
                        gCArrayDim[2] := lPurchRcptLine."Shortcut Dimension 2 Code";
                        gCArrayDim[3] := lPurchRcptLine."Shortcut Dimension 3 Code";
                        gCArrayDim[4] := lPurchRcptLine."Shortcut Dimension 4 Code";
                        gCArrayDim[5] := lPurchRcptLine."Shortcut Dimension 5 Code";
                        if lPurchRcptLine.Type = lPurchRcptLine.Type::Resource THEN lPurchRcptLine."Dimension Set ID" := CompruebaDimensionEnBlanco(gCArrayDim, lPurchRcptLine."No.");
                        lPurchRcptLine.INSERT;
                    END;
                END;
            END;
            // PostDim.SETRANGE(PostDim."Table ID","Sales Shipment Line");
            // PostDim.SETRANGE(PostDim."Document No.","Posting No.");
            // if PostDim.FINDFIRST THEN REPEAT
            // TempDocDimDes."Table ID":="Sales Line";
            // TempDocDimDes."Document Type":="Document Type";
            // TempDocDimDes."Document No.":="Posting No.";
            // TempDocDimDes."Line No.":=PostDim."Line No.";
            // TempDocDimDes."Dimension Code":=PostDim."Dimension Code";
            // TempDocDimDes."Dimension Value Code":=PostDim."Dimension Value Code";
            // TempDocDimDes.INSERT;
            // UNTIL PostDim.NEXT=0;
        END;
    END;

    Procedure DesglosarAlbv(var pSalesHeader: Record "Sales Header")
    Var
        lSalesInvLineTMP: Record "Sales Invoice Line" temporary;
        lReserva: Record "Reserva";
        lSalesInvLineTMPt: Record "Sales Invoice Line" temporary;
        lSalesShptLine: Record "Sales Shipment Line";
        lSalesShptHdr: Record "Sales Shipment Header";
        iNumeroReservas: Integer;
        lResource: Record "Resource";
        lSalesInvLineTMPt2: Record "Sales Invoice Line" temporary;
        liDiasReserva: Integer;
        ldFI: Date;
        ldFF: Date;
        lDImporte: Decimal;
        lDImporteIvaIncluido: Decimal;
        lSalesInvLineTMPo: Record "Sales Invoice Line" temporary;
        lJob: Record "Job";
        lCJob: Code[20];
        ltComp: Text[30];
        lDimValue: Record "Dimension Value";
        lSalesLine: Record "Sales Line";
        lGenProdPostGrp: Record "Gen. Product Posting Group";
        lDimValue2: Record "Dimension Value";
        lCJob2: Text[30];
        liLinea: Integer;
        lbAgrupado: boolean;
        g: Integer;
        lcControldeProcesos: Codeunit ControlProcesos;
        ltCompany: Text[30];
        rRel: Record "Relación Grupos";
    Begin
        WITH pSalesHeader DO BEGIN
            lSalesShptLine.SETRANGE(lSalesShptLine."Document No.", 'w' + "No.");
            lSalesShptLine.DELETEALL;
            if lSalesShptHdr.GET('w' + "No.") THEN lSalesShptHdr.DELETE;
            //Inserto tabla temporal con las líneas originales
            lSalesLine.SETRANGE(lSalesLine."Document Type", "Document Type");
            lSalesLine.SETRANGE(lSalesLine.Type, 1, 999);
            lSalesLine.SETRANGE(lSalesLine."Document No.", "No.");
            if lSalesLine.FINDFIRST THEN
                REPEAT
                    lSalesInvLineTMPo.TransferFields(lSalesLine);
                    lSalesInvLineTMPo."Posting Date" := "Posting Date";
                    lSalesInvLineTMPo."Document No." := 'w' + "No.";
                    lSalesInvLineTMPo.Quantity := lSalesLine."Qty. to Invoice";
                    lSalesInvLineTMPo."Quantity (Base)" := lSalesLine."Qty. to Invoice (Base)";
                    if lSalesInvLineTMPo."Job No." = '' Then begin
                        lSalesInvLineTMPo."Job No." := pSalesHeader."Nº Proyecto";
                    end;
                    lSalesInvLineTMPo.INSERT;
                UNTIL lSalesLine.NEXT = 0;
            //Miro si el recurso es de otra empresa y le asigno recurso y proyecto de la empresa origen
            lSalesInvLineTMPo.SETRANGE(lSalesInvLineTMPo."Document No.", 'w' + "No.");
            if lSalesInvLineTMPo.FINDFIRST THEN
                REPEAT
                    lSalesInvLineTMP := lSalesInvLineTMPo;
                    if lSalesInvLineTMPo.Type = lSalesInvLineTMPo.Type::Resource THEN BEGIN
                        if lResource.GET(lSalesInvLineTMPo."No.") THEN BEGIN
                            lSalesInvLineTMP."Shortcut Dimension 1 Code" := lResource."Global Dimension 1 Code";
                            lSalesInvLineTMP."Shortcut Dimension 2 Code" := lResource."Global Dimension 2 Code";
                            lSalesInvLineTMP."Shortcut Dimension 3 Code" := lResource."Global Dimension 3 Code";
                            lSalesInvLineTMP."Shortcut Dimension 4 Code" := lResource."Global Dimension 4 Code";
                            lSalesInvLineTMP."Shortcut Dimension 5 Code" := lResource."Global Dimension 5 Code";

                            if (lResource."Empresa Origen" <> COMPANYNAME) AND (lResource."Empresa Origen" <> '') THEN BEGIN
                                lSalesInvLineTMP."No." := lResource."Nº En Empresa origen";
                                lSalesInvLineTMP."Empresa Origen" := lResource."Empresa Origen";
                                recuperaproyecto(lJob, lSalesInvLineTMPo."Job No.", lResource);
                                lSalesInvLineTMP."Proyecto Origen" := lJob."No.";
                                lResource.CHANGECOMPANY(lResource."Empresa Origen");
                                ltCompany := lResource."Empresa Origen";
                                if NOT lResource.GET(lSalesInvLineTMP."No.") THEN lResource.INIT;
                                lSalesInvLineTMP."Shortcut Dimension 1 Code" := lResource."Global Dimension 1 Code";
                                lSalesInvLineTMP."Shortcut Dimension 2 Code" := lResource."Global Dimension 2 Code";
                                lSalesInvLineTMP."Shortcut Dimension 3 Code" := lResource."Global Dimension 3 Code";
                                lSalesInvLineTMP."Shortcut Dimension 4 Code" := lResource."Global Dimension 4 Code";
                                lSalesInvLineTMP."Shortcut Dimension 5 Code" := lResource."Global Dimension 5 Code";

                            END else
                                ProyectoEmpresa(lJob, lSalesInvLineTMPo."Job No.", pSalesHeader."Nº Proyecto");
                        END;
                    END;
                    lSalesInvLineTMP.Recurso := lSalesInvLineTMP."No.";
                    if lSalesInvLineTMP."Fecha inicial recurso" = 0D THEN lSalesInvLineTMP."Fecha inicial recurso" := pSalesHeader."Fecha inicial proyecto";
                    if lSalesInvLineTMP."Fecha Final recurso" = 0D THEN lSalesInvLineTMP."Fecha Final recurso" := pSalesHeader."Fecha Fin proyecto";
                    lSalesInvLineTMP.INSERT;
                    lResource.CHANGECOMPANY(COMPANYNAME);
                    ltCompany := CompanyName;
                UNTIL lSalesInvLineTMPo.NEXT = 0;

            //Recorro la tabla de liLineas de factura para buscar si tiene recursos agrupadod
            lSalesInvLineTMP.SETRANGE(lSalesInvLineTMP."Document No.", 'w' + "No.");
            liLinea := 10000;
            if lSalesInvLineTMP.FINDFIRST THEN
                REPEAT
                    gRecursoAgrupado := false;
                    if lSalesInvLineTMP."Empresa Origen" <> '' THEN BEGIN
                        lReserva.CHANGECOMPANY(lSalesInvLineTMP."Empresa Origen");
                        lCJob := lSalesInvLineTMP."Proyecto Origen";
                        lJob.ChangeCompany(lSalesInvLineTMP."Empresa Origen");
                        lResource.CHANGECOMPANY(lSalesInvLineTMP."Empresa Origen");
                        ltCompany := lSalesInvLineTMP."Empresa Origen";
                        if NOT lResource.GET(lSalesInvLineTMP."No.") THEN lResource.INIT;
                        gRecursoAgrupado := lResource."Recurso Agrupado";
                    END ELSE BEGIN
                        lReserva.CHANGECOMPANY(COMPANYNAME);
                        lResource.CHANGECOMPANY(COMPANYNAME);
                        ltCompany := CompanyName;
                        lJob.ChangeCompany(Companyname);
                        if NOT lResource.GET(lSalesInvLineTMP."No.") THEN lResource.INIT;
                        gRecursoAgrupado := lResource."Recurso Agrupado";
                        lCJob := "Nº Proyecto";
                    END;
                    lReserva.RESET;
                    lReserva.SETCURRENTKEY(lReserva."Nº Proyecto", lReserva."Recurso Agrupado");
                    If gRecursoAgrupado then begin
                        lReserva.SETRANGE(lReserva."Recurso Agrupado", lSalesInvLineTMP."No.");
                        lReserva.SETRANGE(lReserva."Linea Agrupado", lSalesInvLineTMP."Line No.");
                    end;
                    IF NOT lReserva.FINDFIRST THEN lReserva.SETRANGE(lReserva."Linea Agrupado");
                    lReserva.SETRANGE(lReserva."Nº Proyecto", lCJob);
                    lReserva.SETFILTER(lReserva."Fecha inicio", '<=%1', lSalesInvLineTMP."Fecha Final recurso");
                    lReserva.SETFILTER(lReserva."Fecha Fin", '>=%1', lSalesInvLineTMP."Fecha inicial recurso");
                    gDTotalliDiasReservas[1] := 0;
                    If not lJob.Get(lCJob) then lJob.Init;
                    If NOT lReserva.FINDFIRST Then lJob."Fechas Flexibles" := true;
                    if lJob."Fechas Flexibles" THEN begin
                        lReserva.SetRange("Fecha inicio");
                        lReserva.SetRange("Fecha Fin");
                        lReserva.SETRANGE(lReserva."Linea Agrupado");
                    end;
                    if (gRecursoAgrupado) AND (NOT lReserva.FINDFIRST) THEN
                        ERROR(glErrorAgrupado, lSalesInvLineTMP."No.", lSalesInvLineTMP."Empresa Origen", lCJob, lSalesInvLineTMP."Fecha inicial recurso", lSalesInvLineTMP."Fecha Final recurso");
                    if gRecursoAgrupado THEN lbAgrupado := TRUE else lbAgrupado := False;
                    //recupero las fechas
                    if lReserva.FINDFIRST THEN
                        REPEAT
                            iNumeroReservas := iNumeroReservas + 1;
                            ldFI := lReserva."Fecha inicio";
                            ldFF := lReserva."Fecha Fin";
                            if ldFI <= lSalesInvLineTMP."Fecha inicial recurso" THEN
                                ldFI := lSalesInvLineTMP."Fecha inicial recurso";
                            ldFF := lReserva."Fecha Fin";
                            if ldFF >= lSalesInvLineTMP."Fecha Final recurso" THEN
                                ldFF := lSalesInvLineTMP."Fecha Final recurso";
                            liDiasReserva := ldFF - ldFI;
                            if liDiasReserva = 0 THEN liDiasReserva := 1;
                            gDTotalliDiasReservas[1] := gDTotalliDiasReservas[1] + liDiasReserva;
                        UNTIL lReserva.NEXT = 0;
                    //if lJob."Fechas Flexibles" THEN gDTotalliDiasReservas[1] := lReserva.Count;
                    iNumeroReservas := 0;
                    if gDTotalliDiasReservas[1] = 0 Then gDTotalliDiasReservas[1] := 1;
                    if (lReserva.FINDFIRST) And (gRecursoAgrupado) THEN BEGIN
                        REPEAT
                            iNumeroReservas := iNumeroReservas + 1;
                            ldFI := lReserva."Fecha inicio";
                            ldFF := lReserva."Fecha Fin";
                            if ldFI <= lSalesInvLineTMP."Fecha inicial recurso" THEN
                                ldFI := lSalesInvLineTMP."Fecha inicial recurso";
                            ldFF := lReserva."Fecha Fin";
                            if ldFF >= lSalesInvLineTMP."Fecha Final recurso" THEN
                                ldFF := lSalesInvLineTMP."Fecha Final recurso";
                            //calculo el número de dias
                            liDiasReserva := ldFF - ldFI;
                            // if lJob."Fechas Flexibles" THEN begin
                            //     ldFF := lSalesInvLineTMP."Fecha Final recurso";
                            //     ldFI := lSalesInvLineTMP."Fecha inicial recurso";
                            //     liDiasReserva := ldFF - ldFI;
                            // end;
                            if liDiasReserva = 0 THEN liDiasReserva := 1;
                            lSalesInvLineTMPt := lSalesInvLineTMP;
                            lSalesInvLineTMPt."Line No." := liLinea;//lSalesInvLineTMPt."Line No."+b;
                            lSalesInvLineTMPt."No." := lReserva."Nº Recurso";
                            lSalesInvLineTMPt.Quantity := lSalesInvLineTMP.Quantity;
                            lSalesInvLineTMPt."Unit Price" := Redondear(lSalesInvLineTMP."Unit Price" / gDTotalliDiasReservas[1] * liDiasReserva, TRUE, pSalesHeader);
                            lSalesInvLineTMPt."Unit Cost (LCY)" := Redondear(lSalesInvLineTMP."Unit Cost (LCY)" / gDTotalliDiasReservas[1] * liDiasReserva, TRUE, pSalesHeader);
                            lSalesInvLineTMPt."Line Discount Amount" := Redondear(lSalesInvLineTMP."Line Discount Amount" / gDTotalliDiasReservas[1] * liDiasReserva, FALSE, pSalesHeader);
                            lSalesInvLineTMPt."Pmt. Discount Amount" := Redondear(lSalesInvLineTMP."Pmt. Discount Amount" / gDTotalliDiasReservas[1] * liDiasReserva, FALSE, pSalesHeader);
                            lSalesInvLineTMPt.Amount := Redondear(lSalesInvLineTMP.Amount / gDTotalliDiasReservas[1] * liDiasReserva, FALSE, pSalesHeader);
                            lSalesInvLineTMPt."Amount Including VAT" := Redondear(lSalesInvLineTMP."Amount Including VAT" / gDTotalliDiasReservas[1] * liDiasReserva, FALSE, pSalesHeader);
                            lSalesInvLineTMPt."Line Amount" := Redondear(lSalesInvLineTMP."Line Amount" / gDTotalliDiasReservas[1] * liDiasReserva, FALSE, pSalesHeader);
                            if lSalesInvLineTMP."Empresa Origen" <> '' THEN BEGIN
                                lResource.CHANGECOMPANY(lSalesInvLineTMP."Empresa Origen");
                                ltCompany := lSalesInvLineTMP."Empresa Origen";
                            END ELSE BEGIN
                                lResource.CHANGECOMPANY(COMPANYNAME);
                                ltCompany := CompanyName;
                            END;
                            if NOT lResource.GET(lReserva."Nº Recurso") THEN BEGIN
                                lResource.RESET;
                                lResource.CHANGECOMPANY(COMPANYNAME);
                                ltCompany := CompanyName;
                                if Not lResource.GET(lReserva."Nº Recurso") then lResource.Init();
                            END;
                            lSalesInvLineTMPt."Shortcut Dimension 1 Code" := lResource."Global Dimension 1 Code";
                            lSalesInvLineTMPt."Shortcut Dimension 2 Code" := lResource."Global Dimension 2 Code";
                            lSalesInvLineTMPt."Shortcut Dimension 3 Code" := lResource."Global Dimension 3 Code";
                            lSalesInvLineTMPt."Shortcut Dimension 4 Code" := lResource."Global Dimension 4 Code";
                            lSalesInvLineTMPt."Shortcut Dimension 5 Code" := lResource."Global Dimension 5 Code";
                            If ltCompany <> CompanyName THEN BEGIN
                                rRel.SETRANGE(rRel."Empresa Origen", ltCompany);
                                rRel.SETRANGE(rRel."Grupo Contable Origen", lResource."Gen. Prod. Posting Group");
                                rRel.SETRANGE(rRel."Empresa Destino", COMPANYNAME);
                                if rRel.FINDFIRST THEN
                                    lResource."Gen. Prod. Posting Group" := rRel."Grupo Contable Destino"
                            END;
                            lSalesInvLineTMPt."Gen. Prod. Posting Group" := lResource."Gen. Prod. Posting Group";
                            lSalesInvLineTMPt."Recurso agrupado" := lbAgrupado;
                            lSalesInvLineTMPt.INSERT;
                            liLinea := liLinea + 10000;
                        UNTIL lReserva.NEXT = 0;
                    END ELSE BEGIN
                        //si no es recurso agrupado inserto igualmente la línea
                        lSalesInvLineTMPt := lSalesInvLineTMP;
                        lSalesInvLineTMPt."Line No." := liLinea;
                        if lSalesInvLineTMPt.INSERT THEN;
                        liLinea := liLinea + 10000;
                    END;
                UNTIL lSalesInvLineTMP.NEXT = 0;
            // Ahora busco si es de producción
            Produccion(lSalesInvLineTMPt, lSalesInvLineTMPt2, lResource, "Nº Proyecto", lbAgrupado, pSalesHeader."Currency Code");
            lSalesShptHdr.TransferFields(pSalesHeader);
            lSalesShptHdr."No." := 'w' + pSalesHeader."No.";
            lSalesShptHdr.INSERT;
            if lSalesInvLineTMPt2.FINDFIRST THEN
                REPEAT
                    lSalesShptLine.TransferFields(lSalesInvLineTMPt2);
                    lSalesShptLine."Line Amount" := lSalesInvLineTMPt2."Line Amount";
                    lSalesShptLine."Line Discount Amount" := lSalesInvLineTMPt2."Line Discount Amount";
                    lSalesShptLine.Amount := lSalesInvLineTMPt2.Amount;
                    lSalesShptLine."Inv. Discount Amount" := lSalesInvLineTMPt2."Inv. Discount Amount";
                    lSalesShptLine."Pmt. Disc. Given Amount" := lSalesInvLineTMPt2."Pmt. Discount Amount";
                    lSalesShptLine."Amount Including VAT" := lSalesInvLineTMPt2."Amount Including VAT";
                    lSalesShptLine."EC %" := lSalesInvLineTMPt2."EC %";
                    lSalesShptLine."EC Difference" := lSalesInvLineTMPt2."EC Difference";
                    gCArrayDim[1] := lSalesShptLine."Shortcut Dimension 1 Code";
                    gCArrayDim[2] := lSalesShptLine."Shortcut Dimension 2 Code";
                    gCArrayDim[3] := lSalesShptLine."Shortcut Dimension 3 Code";
                    gCArrayDim[4] := lSalesShptLine."Shortcut Dimension 4 Code";
                    gCArrayDim[5] := lSalesShptLine."Shortcut Dimension 5 Code";
                    if lSalesShptLine.Type = lSalesShptLine.Type::Resource THEN lSalesShptLine."Dimension Set ID" := CompruebaDimensionEnBlanco(gCArrayDim, lSalesShptLine."No.");
                    lSalesShptLine."Recurso Agrupado" := lSalesInvLineTMPt2."Recurso Agrupado";
                    lSalesShptLine.INSERT;
                    gGenLedgerSetup.GET;
                    if NOT lDimValue.GET(gGenLedgerSetup."Shortcut Dimension 1 Code", lSalesShptLine."Shortcut Dimension 1 Code") THEN BEGIN
                        lDimValue.INIT;
                        lDimValue."Dimension Code" := gGenLedgerSetup."Shortcut Dimension 1 Code";
                        lDimValue.Code := lSalesShptLine."Shortcut Dimension 1 Code";
                        lDimValue."Global Dimension No." := 1;
                        if lDimValue.Code <> '' THEN
                            lDimValue.INSERT;
                    END;
                    if NOT lDimValue.GET(gGenLedgerSetup."Shortcut Dimension 2 Code", lSalesShptLine."Shortcut Dimension 2 Code") THEN BEGIN
                        lDimValue.INIT;
                        lDimValue."Dimension Code" := gGenLedgerSetup."Shortcut Dimension 2 Code";
                        lDimValue.Code := lSalesShptLine."Shortcut Dimension 2 Code";
                        lDimValue."Global Dimension No." := 2;
                        if lDimValue.Code <> '' THEN
                            lDimValue.INSERT;
                    END;
                    if NOT lDimValue.GET(gGenLedgerSetup."Shortcut Dimension 3 Code", lSalesShptLine."Shortcut Dimension 3 Code") THEN BEGIN
                        lDimValue.INIT;
                        lDimValue."Dimension Code" := gGenLedgerSetup."Shortcut Dimension 3 Code";
                        lDimValue.Code := lSalesShptLine."Shortcut Dimension 3 Code";
                        lDimValue."Global Dimension No." := 3;
                        if lDimValue.Code <> '' THEN
                            lDimValue.INSERT;
                    END;
                    if NOT lDimValue.GET(gGenLedgerSetup."Shortcut Dimension 4 Code", lSalesShptLine."Shortcut Dimension 4 Code") THEN BEGIN
                        lDimValue.INIT;
                        lDimValue."Dimension Code" := gGenLedgerSetup."Shortcut Dimension 4 Code";
                        lDimValue.Code := lSalesShptLine."Shortcut Dimension 4 Code";
                        lDimValue."Global Dimension No." := 4;
                        if lDimValue.Code <> '' THEN
                            lDimValue.INSERT;
                    END;
                    if NOT lDimValue.GET(gGenLedgerSetup."Shortcut Dimension 5 Code", lSalesShptLine."Shortcut Dimension 5 Code") THEN BEGIN
                        lDimValue.INIT;
                        lDimValue."Dimension Code" := gGenLedgerSetup."Shortcut Dimension 5 Code";
                        lDimValue.Code := lSalesShptLine."Shortcut Dimension 5 Code";
                        lDimValue."Global Dimension No." := 5;
                        if lDimValue.Code <> '' THEN
                            lDimValue.INSERT;
                    END;
                    if lSalesInvLineTMPt2.Type.AsInteger() <> 0 THEN BEGIN
                        if lDimValue2.GET('PRINCIPAL', lSalesInvLineTMPt2."Shortcut Dimension 3 Code") Then lDimValue2.Init;
                        if lDimValue2."Gen. Prod. Posting Group" <> '' THEN BEGIN
                            lGenProdPostGrp.RESET;
                            lGenProdPostGrp.CHANGECOMPANY(COMPANYNAME);
                            if NOT lGenProdPostGrp.GET(lSalesInvLineTMPt2."Gen. Prod. Posting Group") THEN
                                if lDimValue2."Gen. Prod. Posting Group" <> '' Then
                                    lSalesInvLineTMPt2."Gen. Prod. Posting Group" := lDimValue2."Gen. Prod. Posting Group";
                        END ELSE BEGIN
                            lGenProdPostGrp.CHANGECOMPANY(COMPANYNAME);
                            if NOT lGenProdPostGrp.GET(lSalesInvLineTMPt2."Gen. Prod. Posting Group") THEN BEGIN
                                if lSalesInvLineTMPt2."Empresa Origen" = '' THEN
                                    lGenProdPostGrp.CHANGECOMPANY(COMPANYNAME)
                                ELSE
                                    lGenProdPostGrp.CHANGECOMPANY(lSalesInvLineTMPt2."Empresa Origen");
                                if lGenProdPostGrp.GET(lSalesInvLineTMPt2."Gen. Prod. Posting Group") THEN BEGIN
                                    lGenProdPostGrp.SETRANGE(lGenProdPostGrp."Filtro Empresa Origen", lSalesInvLineTMPt2."Empresa Origen");
                                    lGenProdPostGrp.SETRANGE(lGenProdPostGrp."Filtro Empresa Destino", COMPANYNAME);
                                    lGenProdPostGrp.CALCFIELDS(lGenProdPostGrp."Grupo Equivalente");
                                    if lGenProdPostGrp."Grupo Equivalente" = '' THEN
                                        ERROR(glEquivalencia,
                                        lSalesInvLineTMPt2."Empresa Origen", COMPANYNAME, lSalesInvLineTMPt2."Gen. Prod. Posting Group");
                                    lSalesInvLineTMPt2."Gen. Prod. Posting Group" := lGenProdPostGrp."Grupo Equivalente";
                                END;
                            END;
                        END;
                    END;
                    if lSalesInvLineTMPt2."Gen. Prod. Posting Group" <> '' Then
                        lSalesShptLine."Gen. Prod. Posting Group" := lSalesInvLineTMPt2."Gen. Prod. Posting Group";
                    gCArrayDim[1] := lSalesShptLine."Shortcut Dimension 1 Code";
                    gCArrayDim[2] := lSalesShptLine."Shortcut Dimension 2 Code";
                    gCArrayDim[3] := lSalesShptLine."Shortcut Dimension 3 Code";
                    gCArrayDim[4] := lSalesShptLine."Shortcut Dimension 4 Code";
                    gCArrayDim[5] := lSalesShptLine."Shortcut Dimension 5 Code";
                    if lSalesShptLine.Type = lSalesShptLine.Type::Resource THEN lSalesShptLine."Dimension Set ID" := CompruebaDimensionEnBlanco(gCArrayDim, lSalesShptLine."No.");
                    lSalesShptLine.MODIFY;
                UNTIL lSalesInvLineTMPt2.NEXT = 0;
            if lSalesShptHdr.GET('w' + "No.") THEN BEGIN
                lSalesShptHdr.CALCFIELDS(lSalesShptHdr.Amount, lSalesShptHdr."Amount Including VAT");
                CALCFIELDS(Amount, "Amount Including VAT");
                lDImporte := Amount - lSalesShptHdr.Amount;
                if Abs(lDImporte) > Abs(lSalesShptHdr.Amount) Then Error(glErrordesglose);
                lDImporteIvaIncluido := "Amount Including VAT" - lSalesShptHdr."Amount Including VAT";
                lSalesInvLineTMPo.SETRANGE(lSalesInvLineTMPo."Document No.", 'w' + "No.");
                lSalesInvLineTMPo.SETRANGE(lSalesInvLineTMPo.Type, lSalesInvLineTMPo.Type::Resource);
                if NOT lSalesInvLineTMPo.FINDFIRST THEN
                    lSalesInvLineTMPo.SETRANGE(lSalesInvLineTMPo.Type, lSalesInvLineTMPo.Type::"G/L Account");
                if lSalesInvLineTMPo.FINDFIRST THEN BEGIN
                    if (lDImporte <> 0) OR (lDImporteIvaIncluido <> 0) THEN BEGIN
                        lSalesShptLine.SETRANGE(lSalesShptLine."Document No.", 'w' + "No.");
                        lSalesShptLine.FINDLAST;
                        gDTotalliDiasReservas[1] := lSalesShptLine."Line No.";
                        lResource.RESET;
                        lResource.CHANGECOMPANY(COMPANYNAME);
                        lResource.GET(lSalesInvLineTMPo."No.");
                        If Not gGenPostingSetup.GET("Gen. Bus. Posting Group", lResource."Gen. Prod. Posting Group") Then
                            if lSalesInvLineTMPo."Gen. Prod. Posting Group" <> '' Then
                                gGenPostingSetup.Get(lSalesInvLineTMPo."Gen. Bus. Posting Group", lSalesInvLineTMPo."Gen. Prod. Posting Group");
                        lSalesShptLine."Line No." := gDTotalliDiasReservas[1] + 1;
                        lSalesShptLine.Type := lSalesShptLine.Type::"G/L Account";
                        lSalesShptLine."No." := gGenPostingSetup."Sales Account";
                        lSalesShptLine.Description := 'Redondeo factura';
                        lSalesShptLine.Quantity := 1;
                        CompruebaErrorRedondeo(lDImporte);
                        lSalesShptLine."Unit Price" := lDImporte;
                        lSalesShptLine."Line Discount %" := 0;
                        lSalesShptLine."VAT Base Amount" := lDImporte;
                        lSalesShptLine."Line Amount" := lDImporte;
                        lSalesShptLine.Amount := lDImporte;
                        CompruebaErrorRedondeo(lDImporteIvaIncluido);
                        lSalesShptLine."Amount Including VAT" := lDImporteIvaIncluido;
                        lSalesShptLine."Inv. Discount Amount" := 0;
                        lSalesShptLine."Pmt. Disc. Given Amount" := 0;
                        lSalesShptLine."Gen. Bus. Posting Group" := lSalesInvLineTMPo."Gen. Bus. Posting Group";
                        if lSalesInvLineTMPo."Gen. Prod. Posting Group" <> '' Then
                            lSalesShptLine."Gen. Prod. Posting Group" := lSalesInvLineTMPo."Gen. Prod. Posting Group";
                        lSalesShptLine."VAT Bus. Posting Group" := lSalesInvLineTMPo."VAT Bus. Posting Group";
                        lSalesShptLine."VAT Prod. Posting Group" := lSalesInvLineTMPo."VAT Prod. Posting Group";
                        gCArrayDim[1] := lSalesShptLine."Shortcut Dimension 1 Code";
                        gCArrayDim[2] := lSalesShptLine."Shortcut Dimension 2 Code";
                        gCArrayDim[3] := lSalesShptLine."Shortcut Dimension 3 Code";
                        gCArrayDim[4] := lSalesShptLine."Shortcut Dimension 4 Code";
                        gCArrayDim[5] := lSalesShptLine."Shortcut Dimension 5 Code";
                        if lSalesShptLine.Type = lSalesShptLine.Type::Resource THEN lSalesShptLine."Dimension Set ID" := CompruebaDimensionEnBlanco(gCArrayDim, lSalesShptLine."No.");
                        lSalesShptLine.INSERT;
                    END;
                END;
            END;
            // PostDim.SETRANGE(PostDim."Table ID","Sales Shipment Line");
            // PostDim.SETRANGE(PostDim."Document No.","Posting No.");
            // if PostDim.FINDFIRST THEN REPEAT
            // TempDocDimDes."Table ID":="Sales Line";
            // TempDocDimDes."Document Type":="Document Type";
            // TempDocDimDes."Document No.":="Posting No.";
            // TempDocDimDes."Line No.":=PostDim."Line No.";
            // TempDocDimDes."Dimension Code":=PostDim."Dimension Code";
            // TempDocDimDes."Dimension Value Code":=PostDim."Dimension Value Code";
            // TempDocDimDes.INSERT;
            // UNTIL PostDim.NEXT=0;
        END;
    END;


    /// <summary>
    /// ContaAlbVenta.
    /// </summary>
    /// <param name="SalesHeader">Record "Sales Shipment Header".</param>

    procedure ContaAlbVenta(pSalesHeader: Record "Sales Header"; pbSinMensage: boolean): Boolean
    var
        lSalesShptLineDesgl: Record "Sales Shipment Line";
        lSalesShptLineDesglSCY: Record "Sales Shipment Line";
        lcSalesPostPrepayments: Codeunit "Sales-Post Prepayments";
        lGenJnlTemplate: Record "Gen. Journal Template";
        lGenJnlBatch: Record "Gen. Journal Batch";
        lCurrency: Record Currency;
        lcControlProcesos: Codeunit ControlProcesos;
        llText012: Label 'EspeciFique Cuenta prepagos en conFig. grupos contables %1 - %2';
        liliLinecount: Integer;
        lDTotal: Decimal;
        lDTotalAcy: Decimal;
        lCust: Record Customer;
        lSalesShipMentHeader: Record "Sales Shipment Header";
        FalineNo: Integer;
        TempBuffer: Record "Invoice Posting Buffer" temporary;
        TempBuffer2: Record "Invoice Posting Buffer" temporary;
    begin

        TempBuffer.Deleteall;
        DesglosarAlbV(pSalesHeader);
        with pSalesHeader do begin
            lSalesShptLineDesgl.SETRANGE(lSalesShptLineDesgl."Document No.", 'W' + "No.");
            if lSalesShptLineDesgl.FINDFIRST THEN
                REPEAT
                    lSalesShptLineDesglSCY := lSalesShptLineDesgl;
                    //if NOT ("Document Type" IN ["Document Type"::"Return Order", "Document Type"::"Credit Memo"]) THEN BEGIN

                    lSalesShptLineDesgl."Line Amount" := -lSalesShptLineDesgl."Line Amount";
                    lSalesShptLineDesgl.Amount := -lSalesShptLineDesgl.Amount;
                    lSalesShptLineDesgl."VAT Base Amount" := -lSalesShptLineDesgl."VAT Base Amount";
                    lSalesShptLineDesgl."VAT Difference" := -lSalesShptLineDesgl."VAT Difference";
                    lSalesShptLineDesgl."Amount Including VAT" := -lSalesShptLineDesgl."Amount Including VAT";
                    lSalesShptLineDesgl."Line Discount Amount" := -lSalesShptLineDesgl."Line Discount Amount";
                    lSalesShptLineDesgl."Inv. Discount Amount" := -lSalesShptLineDesgl."Inv. Discount Amount";
                    lSalesShptLineDesgl."Pmt. Disc. Given Amount" := -lSalesShptLineDesgl."Pmt. Disc. Given Amount";
                    lSalesShptLineDesglSCY."Line Amount" := -lSalesShptLineDesglSCY."Line Amount";
                    lSalesShptLineDesglSCY.Amount := -lSalesShptLineDesglSCY.Amount;
                    lSalesShptLineDesglSCY."VAT Base Amount" := -lSalesShptLineDesglSCY."VAT Base Amount";
                    lSalesShptLineDesglSCY."VAT Difference" := -lSalesShptLineDesglSCY."VAT Difference";
                    lSalesShptLineDesglSCY."Amount Including VAT" := -lSalesShptLineDesglSCY."Amount Including VAT";
                    lSalesShptLineDesglSCY."Line Discount Amount" := -lSalesShptLineDesglSCY."Line Discount Amount";
                    lSalesShptLineDesglSCY."Inv. Discount Amount" := -lSalesShptLineDesglSCY."Inv. Discount Amount";
                    lSalesShptLineDesglSCY."Pmt. Disc. Given Amount" := -lSalesShptLineDesglSCY."Pmt. Disc. Given Amount";

                    //END;

                    FillInvPostingBufferDesgloNew(lSalesShptLineDesgl, lSalesShptLineDesglSCY, TempBuffer, pSalesHeader, FalineNo, TempBuffer2);

                UNTIL lSalesShptLineDesgl.NEXT = 0;
            TempBuffer2.RESET;
            // WITHTempBuffer2 DO
            if TempBuffer2.FIND('+') THEN
                REPEAT
                    liliLinecount := liliLinecount + 1;
                    //if GUIALLOWED THEN
                    //Window.UPDATE(3,liLinecount);

                    CASE TempBuffer2."VAT Calculation Type" OF
                        TempBuffer2."VAT Calculation Type"::"Reverse Charge VAT":
                            BEGIN
                                gVATPostingSetup.GET(
                                TempBuffer2."VAT Bus. Posting Group", TempBuffer2."VAT Prod. Posting Group");
                                TempBuffer2."VAT Amount" :=
                                ROUND(
                                    (TempBuffer2.Amount -

                                    TempBuffer2."Line Discount Amount" -

                                    TempBuffer2."Inv. Discount Amount" -
                                    TempBuffer2."Pmt. Discount Amount") *
                                    gVATPostingSetup."VAT+EC %" / 100);
                                TempBuffer2."VAT Amount (ACY)" :=
                                ROUND(
                                    (TempBuffer2."Amount (ACY)" -
                                    TempBuffer2."Line Discount Amt. (ACY)" -
                                    TempBuffer2."Inv. Discount Amt. (ACY)" -
                                    TempBuffer2."Src. Curr. Pmt. Discount Amt.") *
                                    gVATPostingSetup."VAT+EC %" / 100, gCurrency."Amount Rounding Precision");
                            END;
                        TempBuffer2."VAT Calculation Type"::"Sales Tax":
                            BEGIN
                                if TempBuffer2."Use Tax" THEN BEGIN
                                    TempBuffer2."VAT Amount" :=
                                    ROUND(
                                        gcSalesTaxCalculate.CalculateTax(
                                        TempBuffer2."Tax Area Code", TempBuffer2."Tax Group Code",
                                        TempBuffer2."Tax Liable", gPurchHeader."Posting Date",
                                        TempBuffer2.Amount -
                                        TempBuffer2."Line Discount Amount" - TempBuffer2."Inv. Discount Amount" -
                                        TempBuffer2."Pmt. Discount Amount",
                                        TempBuffer2.Quantity, 0));
                                    if gGenLedgerSetup."Additional Reporting Currency" <> '' THEN
                                        TempBuffer2."VAT Amount (ACY)" :=
                                        gCurrExchRate.ExchangeAmtLCYToFCY(
                                            gPurchHeader."Posting Date", gGenLedgerSetup."Additional Reporting Currency",
                                            TempBuffer2."VAT Amount", 0);
                                END;
                            END;
                    END;

                    if gPurchHeader."Prices Including VAT" AND (TempBuffer2."VAT %" <> 0) THEN
                        // WITH TempBuffer2 DO BEGIN
                        gDDiscountVATAmount :=
                                ROUND(TempBuffer2."Line Discount Amount" * TempBuffer2."VAT %" / (1 + TempBuffer2."VAT %" / 100) / 100);
                    TempBuffer2.Amount := TempBuffer2.Amount - gDDiscountVATAmount;
                    TempBuffer2."Line Discount Amount" := TempBuffer2."Line Discount Amount" - gDDiscountVATAmount;

                    gDDiscountVATAmount :=
                    ROUND(
                        TempBuffer2."Line Discount Amt. (ACY)" * TempBuffer2."VAT %" / (1 + TempBuffer2."VAT %" / 100) / 100,
                        gCurrency."Amount Rounding Precision");
                    TempBuffer2."Amount (ACY)" := TempBuffer2."Amount (ACY)" - gDDiscountVATAmount;
                    TempBuffer2."Line Discount Amt. (ACY)" := TempBuffer2."Line Discount Amt. (ACY)" - gDDiscountVATAmount;

                    gDDiscountVATAmount :=
                    ROUND(TempBuffer2."Inv. Discount Amount" * TempBuffer2."VAT %" / (1 + TempBuffer2."VAT %" / 100) / 100);
                    TempBuffer2.Amount := TempBuffer2.Amount - gDDiscountVATAmount;
                    TempBuffer2."Inv. Discount Amount" := TempBuffer2."Inv. Discount Amount" - gDDiscountVATAmount;

                    gDDiscountVATAmount :=
                    ROUND(
                        TempBuffer2."Src. Curr. Pmt. Discount Amt." * TempBuffer2."VAT %" / (1 + TempBuffer2."VAT %" / 100) / 100,
                        gCurrency."Amount Rounding Precision");
                    TempBuffer2."Amount (ACY)" := TempBuffer2."Amount (ACY)" - gDDiscountVATAmount;
                    TempBuffer2."Inv. Discount Amt. (ACY)" := TempBuffer2."Inv. Discount Amt. (ACY)" - gDDiscountVATAmount;

                    gDDiscountVATAmount :=
                    ROUND(
                        TempBuffer2."Inv. Discount Amt. (ACY)" * TempBuffer2."VAT %" / (1 + TempBuffer2."VAT %" / 100) / 100,
                        gCurrency."Amount Rounding Precision");
                    TempBuffer2."Amount (ACY)" := TempBuffer2."Amount (ACY)" - gDDiscountVATAmount;
                    TempBuffer2."Inv. Discount Amt. (ACY)" := TempBuffer2."Inv. Discount Amt. (ACY)" - gDDiscountVATAmount;
                    // END;

                    gGenJnlLine.INIT;
                    gGenJnlLine."Posting Date" := pSalesHeader."Posting Date";
                    gGenJnlLine."Document Date" := pSalesHeader."Document Date";
                    gGenJnlLine.Description := COPYSTR(pSalesHeader."Posting Description", 1, MAXSTRLEN(gGenJnlLine.Description));
                    //gGenJnlLine.Description := "Posting Description";
                    gGenJnlLine."Reason Code" := pSalesHeader."Reason Code";
                    gGenJnlLine."Document Type" := gGenJnlLine."Document Type"::Shipment;
                    gGenJnlLine."Document No." := pSalesHeader."Last Shipping No.";
                    //gGenJnlLine."Tax Area Code" := pSalesHeader."No.";
                    gGenJnlLine."Account No." := TempBuffer2."G/L Account";
                    gGenJnlLine."System-Created Entry" := TempBuffer2."System-Created Entry";
                    gGenJnlLine.Amount := TempBuffer2.Amount;
                    lDTotal := lDTotal + TempBuffer2.Amount;
                    gGenJnlLine."Source Currency Code" := pSalesHeader."Currency Code";
                    gGenJnlLine."Source Currency Amount" := TempBuffer2."Amount (ACY)";
                    lDTotalACY := lDTotalACY + TempBuffer2."Amount (ACY)";
                    gGenJnlLine.Correction := pSalesHeader.Correction;
                    gGenJnlLine."Gen. Posting Type" := gGenJnlLine."Gen. Posting Type"::" ";
                    gGenJnlLine."Gen. Bus. Posting Group" := '';//TempBuffer2."Gen. Bus. Posting Group";
                    gGenJnlLine."Gen. Prod. Posting Group" := '';// TempBuffer2."Gen. Prod. Posting Group";
                    gGenJnlLine."VAT Bus. Posting Group" := '';//TempBuffer2."VAT Bus. Posting Group";
                    gGenJnlLine."VAT Prod. Posting Group" := '';//TempBuffer2."VAT Prod. Posting Group";
                    gGenJnlLine."Tax Area Code" := TempBuffer2."Tax Area Code";
                    gGenJnlLine."Tax Liable" := TempBuffer2."Tax Liable";
                    gGenJnlLine."Tax Group Code" := TempBuffer2."Tax Group Code";
                    gGenJnlLine."Use Tax" := TempBuffer2."Use Tax";
                    gGenJnlLine.Quantity := TempBuffer2.Quantity;
                    gGenJnlLine."VAT Calculation Type" := TempBuffer2."VAT Calculation Type";
                    gGenJnlLine."VAT Base Amount" := TempBuffer2."VAT Base Amount";
                    gGenJnlLine."VAT Base Discount %" := pSalesHeader."VAT Base Discount %";
                    gGenJnlLine."Source Curr. VAT Base Amount" := TempBuffer2."VAT Base Amount (ACY)";
                    gGenJnlLine."VAT Amount" := TempBuffer2."VAT Amount";
                    gGenJnlLine."Source Curr. VAT Amount" := TempBuffer2."VAT Amount (ACY)";
                    gGenJnlLine."VAT Difference" := TempBuffer2."VAT Difference";
                    gGenJnlLine."VAT Posting" := gGenJnlLine."VAT Posting"::"Manual VAT Entry";
                    gGenJnlLine."Shortcut Dimension 1 Code" := TempBuffer2."Global Dimension 1 Code";
                    gGenJnlLine."Shortcut Dimension 2 Code" := TempBuffer2."Global Dimension 2 Code";
                    //ASC
                    gGenJnlLine."Shortcut Dimension 3 Code" := TempBuffer2."Global Dimension 3 Code";
                    gGenJnlLine."Shortcut Dimension 4 Code" := TempBuffer2."Global Dimension 4 Code";
                    gGenJnlLine."Shortcut Dimension 5 Code" := TempBuffer2."Global Dimension 5 Code";
                    gGenJnlLine."Dimension Set ID" := TempBuffer2."Dimension Set ID";
                    gGenJnlLine.Circuito := TRUE;
                    gGenJnlLine."Job No." := TempBuffer2."Job No.";
                    gGenJnlLine."Source Code" := gCSrcCode;
                    gGenJnlLine."Sell-to/Buy-from No." := pSalesHeader."Sell-to Customer No.";
                    gGenJnlLine."Bill-to/Pay-to No." := pSalesHeader."Bill-to Customer No.";
                    gGenJnlLine."Country/Region Code" := pSalesHeader."VAT Country/Region Code";
                    gGenJnlLine."VAT Registration No." := pSalesHeader."VAT Registration No.";
                    gGenJnlLine."Source Type" := gGenJnlLine."Source Type"::Customer;
                    gGenJnlLine."Source No." := pSalesHeader."Bill-to Customer No.";
                    gGenJnlLine."Posting No. Series" := '';
                    gGenJnlLine."IC Partner Code" := '';//"Pay-to IC Partner Code";
                    gGenJnlLine."Ship-to/Order Address Code" := pSalesHeader."Ship-to Code";

                    gGenJnlLine."Payment Terms Code" := pSalesHeader."Payment Terms Code";
                    gGenJnlLine."Payment Method Code" := pSalesHeader."Payment Method Code";
                    gGenJnlLine."Salespers./Purch. Code" := pSalesHeader."Salesperson Code";
                    gGenJnlLine."Generate AutoInvoices" := FALSE;//"Generate Autoinvoices" OR "Generate Autocredit Memo";
                    gGenJnlLine."AutoDoc. No." := '';

                    if TempBuffer2.Type = TempBuffer2.Type::"Fixed Asset" THEN BEGIN
                        gGenJnlLine."Account Type" := gGenJnlLine."Account Type"::"Fixed Asset";
                        if TempBuffer2."FA Posting Type" =
                        TempBuffer2."FA Posting Type"::"Acquisition Cost"
                        THEN
                            gGenJnlLine."FA Posting Type" := gGenJnlLine."FA Posting Type"::"Acquisition Cost";
                        if TempBuffer2."FA Posting Type" =
                        TempBuffer2."FA Posting Type"::Maintenance
                        THEN
                            gGenJnlLine."FA Posting Type" := gGenJnlLine."FA Posting Type"::Maintenance;
                        gGenJnlLine."FA Posting Date" := TempBuffer2."FA Posting Date";
                        gGenJnlLine."Depreciation Book Code" := TempBuffer2."Depreciation Book Code";
                        gGenJnlLine."Salvage Value" := TempBuffer2."Salvage Value";
                        gGenJnlLine."Depr. until FA Posting Date" := TempBuffer2."Depr. until FA Posting Date";
                        gGenJnlLine."Depr. Acquisition Cost" := TempBuffer2."Depr. Acquisition Cost";
                        gGenJnlLine."Maintenance Code" := TempBuffer2."Maintenance Code";
                        gGenJnlLine."Insurance No." := TempBuffer2."Insurance No.";
                        gGenJnlLine."Budgeted FA No." := TempBuffer2."Budgeted FA No.";
                        gGenJnlLine."Duplicate in Depreciation Book" := TempBuffer2."Duplicate in Depreciation Book";
                        gGenJnlLine."Use Duplication List" := TempBuffer2."Use Duplication List";
                    END;

                    RungcGenJnlPostLine(gGenJnlLine);//,TempBuffer2."Dimension Entry No.");
                                                     /* if FAInsertDiscountAmount(TempBuffer2,DeprBook) THEN
                                                         FAPostDiscountAmount(
                                                         gGenJnlLine,
                                                         TempBuffer2."Line Discount Amount" + TempBuffer2."Inv. Discount Amount",
                                                         TempBuffer2."Line Discount Amt. (ACY)" + TempBuffer2."Inv. Discount Amt. (ACY)",
                                                         TempBuffer2."Dimension Entry No."); */
                    gGenJnlLine."Account Type" := gGenJnlLine."Account Type"::"G/L Account";
                    gGenJnlLine.VALIDATE("FA Posting Type", gGenJnlLine."FA Posting Type"::" ");
                    /* if FAInsertDiscountAmount(TempBuffer2,DeprBook) THEN
                    PostDiscount(
                        TempBuffer2."FA Discount Account",
                        -(TempBuffer2."Line Discount Amount" + TempBuffer2."Inv. Discount Amount"),
                        -(TempBuffer2."Line Discount Amt. (ACY)" + TempBuffer2."Inv. Discount Amt. (ACY)"),
                        TempBuffer2."Dimension Entry No."); */
                    if (TempBuffer2."Line Discount Amount" <> 0) OR
                    (TempBuffer2."Line Discount Amt. (ACY)" <> 0)
                    THEN
                        PostDiscount(
                        TempBuffer2."Line Discount Account",
                        TempBuffer2."Line Discount Amount",
                        TempBuffer2."Line Discount Amt. (ACY)",
                        TempBuffer2."Dimension Entry No.", gPurchHeader);
                    if (TempBuffer2."Inv. Discount Amount" <> 0) OR
                    (TempBuffer2."Inv. Discount Amt. (ACY)" <> 0)
                    THEN
                        PostDiscount(
                        TempBuffer2."Inv. Discount Account",
                        TempBuffer2."Inv. Discount Amount",
                        TempBuffer2."Inv. Discount Amt. (ACY)",
                        TempBuffer2."Dimension Entry No.", gPurchHeader);
                    if TempBuffer2."Pmt. Discount Amount" <> 0 THEN
                        PostDiscount(
                        TempBuffer2."Pmt. Discount Account",
                        TempBuffer2."Pmt. Discount Amount",
                        TempBuffer2."Src. Curr. Pmt. Discount Amt.",
                        TempBuffer2."Dimension Entry No.", gPurchHeader);
                UNTIL TempBuffer2.Next(-1) = 0;

            TempBuffer2.DELETEALL;

            // Check External Document number
            // Post vendor entries
            //if GUIALLOWED THEN
            //Window.UPDATE(4,1);
            gGenJnlLine.INIT;
            gGenJnlLine."Posting Date" := pSalesHeader."Posting Date";
            gGenJnlLine."Document Date" := pSalesHeader."Document Date";
            gGenJnlLine.Description := COPYSTR(pSalesHeader."Posting Description", 1, MAXSTRLEN(gGenJnlLine.Description));
            gGenJnlLine."Shortcut Dimension 1 Code" := pSalesHeader."Shortcut Dimension 1 Code";
            gGenJnlLine."Shortcut Dimension 2 Code" := pSalesHeader."Shortcut Dimension 2 Code";
            //ASC
            gGenJnlLine."Shortcut Dimension 3 Code" := pSalesHeader."Shortcut Dimension 3 Code";
            gGenJnlLine."Shortcut Dimension 4 Code" := pSalesHeader."Shortcut Dimension 4 Code";
            gGenJnlLine."Shortcut Dimension 5 Code" := pSalesHeader."Shortcut Dimension 5 Code";
            gGenJnlLine."Dimension Set ID" := pSalesHeader."Dimension Set ID";
            gGenJnlLine.Circuito := TRUE;
            gGenJnlLine."Reason Code" := pSalesHeader."Reason Code";
            gGenJnlLine."Account Type" := gGenJnlLine."Account Type"::"G/L Account";
            lCust.GET(pSalesHeader."Bill-to Customer No.");
            gGenPostingSetup.RESET;
            gGenPostingSetup.FIND('-');
            //if NOT rConFig.GET(rLinFra."Gen. Bus. Posting Group", rLinFra."Gen. Prod. Posting Group") THEN
            //  ERROR(Text011, rLinFra."Gen. Bus. Posting Group", rLinFra."Gen. Prod. Posting Group");
            if gGenPostingSetup."Sales Prepayments Account" = '' THEN
                //ERROR(Text012, rLinFra."Gen. Bus. Posting Group", rLinFra."Gen. Prod. Posting Group");
                ERROR(llText012, gGenPostingSetup."Gen. Bus. Posting Group", gGenPostingSetup."Gen. Prod. Posting Group");
            gGenJnlLine."Account No." := gGenPostingSetup."Sales Prepayments Account";
            gGenJnlLine."Document Type" := gGenJnlLine."Document Type"::Shipment;
            gGenJnlLine."Document No." := pSalesHeader."Last Shipping No.";
            gGenJnlLine."Currency Code" := pSalesHeader."Currency Code";
            gGenJnlLine.Amount := -lDTotal;
            gGenJnlLine."Source Currency Code" := pSalesHeader."Currency Code";
            gGenJnlLine."Source Currency Amount" := -lDTotal;
            gGenJnlLine."Amount (LCY)" := -lDTotalACY;
            if gPurchHeader."Currency Code" = '' THEN
                gGenJnlLine."Currency Factor" := 1
            ELSE
                gGenJnlLine."Currency Factor" := gPurchHeader."Currency Factor";
            gGenJnlLine."Sales/Purch. (LCY)" := -lDTotalACY;
            gGenJnlLine.Correction := pSalesHeader.Correction;
            gGenJnlLine."Inv. Discount (LCY)" := -gTotalPurchaseLineLCY."Inv. Discount Amount";
            gGenJnlLine."Pmt. Discount Given/Rec. (LCY)" := 0;// -gTotalPurchaseLineLCY."Pmt. Discount Amount";
            gGenJnlLine."Sell-to/Buy-from No." := pSalesHeader."Sell-To Customer No.";
            gGenJnlLine."Bill-to/Pay-to No." := pSalesHeader."Bill-to Customer No.";
            gGenJnlLine."Salespers./Purch. Code" := pSalesHeader."Salesperson Code";
            gGenJnlLine."System-Created Entry" := TRUE;
            gGenJnlLine."On Hold" := pSalesHeader."On Hold";
            gGenJnlLine."Gen. Bus. Posting Group" := '';
            gGenJnlLine."Applies-to Doc. Type" := pSalesHeader."Applies-to Doc. Type";
            gGenJnlLine."Applies-to Bill No." := pSalesHeader."Applies-to Bill No.";
            gGenJnlLine."Applies-to Doc. No." := pSalesHeader."Applies-to Doc. No.";
            gGenJnlLine."Applies-to ID" := '';
            gGenJnlLine."Allow Application" := pSalesHeader."Bal. Account No." = '';
            gGenJnlLine."Payment Terms Code" := pSalesHeader."Payment Terms Code";
            gGenJnlLine."Payment Method Code" := pSalesHeader."Payment Method Code";
            gGenJnlLine."Recipient Bank Account" := pSalesHeader."Cust. Bank Acc. Code";
            gGenJnlLine."Due Date" := pSalesHeader."Due Date";
            //gGenJnlLine."Pmt. Discount Date" := "Pmt. Discount Date";
            gGenJnlLine."Payment Discount %" := pSalesHeader."Payment Discount %";
            gGenJnlLine."Source Type" := gGenJnlLine."Source Type"::Customer;
            gGenJnlLine."Source No." := pSalesHeader."Bill-to Customer No.";
            gGenJnlLine."Source Code" := gCSrcCode;
            gGenJnlLine."Posting No. Series" := '';
            gGenJnlLine."IC Partner Code" := '';//"Pay-to IC Partner Code";
            gGenJnlLine."Generate AutoInvoices" := FALSE;//"Generate Autoinvoices" OR "Generate Autocredit Memo";
            gGenJnlLine."AutoDoc. No." := '';

            /* TempJnlLineDim.DELETEALL;
            TempDocDim.RESET;
            TempDocDim.SETRANGE("Table ID",DATABASE::"Purchase Line Archive");
            lcDimMgt.CopyDocDimToJnlLineDim(TempDocDim,TempJnlLineDim); */
            if gGenJnlLine.Amount <> 0 then
                gcGenJnlPostLine.RunWithCheck(gGenJnlLine);//,TempJnlLineDim);

            //  END;
            if not pbSinMensage Then
                MESSAGE('Se ha contabilizado el albarán %1 con fecha %2', pSalesHeader."Last Shipping No.",
                FORMAT(pSalesHeader."Posting Date", 0, '<Day,2>/<Month,2>/<Year>'));
            lSalesShipMentHeader.Get(pSalesHeader."Last Shipping No.");
            lSalesShipMentHeader.Contabilizado := TRUE;
            lSalesShipMentHeader."Albarán Venta" := true;
            lSalesShipMentHeader.MODIFY;
        end;
        exit(true);
    end;

    Procedure FillInvPostingBufferDesgloNew(pSalesShptLine: Record "Sales Shipment Line"; pSalesShptLineACY: Record "Sales Shipment Line"; var pInvoicePostingBuffer: Record "Invoice Posting Buffer"; Var pSalesHeader: Record "Sales Header"; var piFALineNo: integer; var InvoicePostingBuffer: Record "Invoice Posting Buffer")
    var
        lSalesSetup: Record "Sales & Receivables Setup";
        lcControldeProcesos: Codeunit ControlProcesos;
    BEGIN
        lSalesSetup.Get();
        //WITH pSalesShptLine DO BEGIN
        if pSalesShptLine.Quantity = 0 THEN EXIT;
        if (pSalesShptLine."Gen. Bus. Posting Group" <> gGenPostingSetup."Gen. Bus. Posting Group") OR
            (pSalesShptLine."Gen. Prod. Posting Group" <> gGenPostingSetup."Gen. Prod. Posting Group")
        THEN
            gGenPostingSetup.GET(pSalesShptLine."Gen. Bus. Posting Group", pSalesShptLine."Gen. Prod. Posting Group");
        CLEAR(pInvoicePostingBuffer);
        pInvoicePostingBuffer.Type := pSalesShptLine.Type;
        pInvoicePostingBuffer.Agrupado := pSalesShptLine."Recurso Agrupado";
        if (pSalesShptLine.Type = pSalesShptLine.Type::"G/L Account") OR (pSalesShptLine.Type = pSalesShptLine.Type::"Fixed Asset") THEN
            pInvoicePostingBuffer."G/L Account" := pSalesShptLine."No."
        ELSE
            if pSalesHeader."Document Type" IN [pSalesHeader."Document Type"::"Return Order",
            pSalesHeader."Document Type"::"Credit Memo"] THEN BEGIN
                gGenPostingSetup.TestField("Sales Credit Memo Account");
                pInvoicePostingBuffer."G/L Account" := gGenPostingSetup."Sales Credit Memo Account";
            END ELSE BEGIN
                gGenPostingSetup.TestField("Sales Account");
                pInvoicePostingBuffer."G/L Account" := gGenPostingSetup."Sales Account";
            END;

        pInvoicePostingBuffer."System-Created Entry" := TRUE;
        pInvoicePostingBuffer."Gen. Bus. Posting Group" := pSalesShptLine."Gen. Bus. Posting Group";
        pInvoicePostingBuffer."Gen. Prod. Posting Group" := pSalesShptLine."Gen. Prod. Posting Group";
        pInvoicePostingBuffer."VAT Bus. Posting Group" := pSalesShptLine."VAT Bus. Posting Group";
        pInvoicePostingBuffer."VAT Prod. Posting Group" := pSalesShptLine."VAT Prod. Posting Group";
        pInvoicePostingBuffer."VAT Calculation Type" := pSalesShptLine."VAT Calculation Type";
        pInvoicePostingBuffer."Global Dimension 1 Code" := pSalesShptLine."Shortcut Dimension 1 Code";
        pInvoicePostingBuffer."Global Dimension 2 Code" := pSalesShptLine."Shortcut Dimension 2 Code";
        pInvoicePostingBuffer."Nº Contrato" := pSalesHeader."Nº Contrato";
        //ASC
        pInvoicePostingBuffer."Global Dimension 3 Code" := pSalesShptLine."Shortcut Dimension 3 Code";
        pInvoicePostingBuffer."Global Dimension 4 Code" := pSalesShptLine."Shortcut Dimension 4 Code";
        pInvoicePostingBuffer."Global Dimension 5 Code" := pSalesShptLine."Shortcut Dimension 5 Code";
        pInvoicePostingBuffer."Dimension Set ID" := lcControldeProcesos.GetDefaultDimID2(pSalesShptLine."Shortcut Dimension 1 Code", pSalesShptLine."Shortcut Dimension 2 Code",
        pSalesShptLine."Shortcut Dimension 3 Code", pSalesShptLine."Shortcut Dimension 4 Code", pSalesShptLine."Shortcut Dimension 5 Code");
        if pSalesHeader."Nº Proyecto" = '' THEN
            pInvoicePostingBuffer."Job No." := pSalesShptLine."Job No."
        else
            pInvoicePostingBuffer."Job No." := pSalesHeader."Nº Proyecto";
        pInvoicePostingBuffer.Amount := pSalesShptLine.Amount;
        pInvoicePostingBuffer."VAT Base Amount" := pSalesShptLine.Amount;
        pInvoicePostingBuffer."VAT Amount" := pSalesShptLine."Amount Including VAT" - pSalesShptLine.Amount;
        pInvoicePostingBuffer."Amount (ACY)" := pSalesShptLineACY.Amount;
        pInvoicePostingBuffer."VAT Base Amount (ACY)" := pSalesShptLineACY.Amount;
        pInvoicePostingBuffer."VAT Amount (ACY)" := pSalesShptLineACY."Amount Including VAT" - pSalesShptLineACY.Amount;
        pInvoicePostingBuffer."VAT Difference" := pSalesShptLine."VAT Difference";
        pInvoicePostingBuffer."VAT %" := pSalesShptLine."VAT %";
        if pSalesShptLine.Type = pSalesShptLine.Type::"Fixed Asset" THEN BEGIN
            pInvoicePostingBuffer."FA Posting Date" := pSalesShptLine."FA Posting Date";
            pInvoicePostingBuffer."Depreciation Book Code" := pSalesShptLine."Depreciation Book Code";
            pInvoicePostingBuffer."Depr. until FA Posting Date" := pSalesShptLine."Depr. until FA Posting Date";
            pInvoicePostingBuffer."Duplicate in Depreciation Book" := pSalesShptLine."Duplicate in Depreciation Book";
            pInvoicePostingBuffer."Use Duplication List" := pSalesShptLine."Use Duplication List";
        END;

        if pSalesShptLine."VAT Calculation Type" = pSalesShptLine."VAT Calculation Type"::"Sales Tax" THEN BEGIN
            pInvoicePostingBuffer."Tax Area Code" := pSalesShptLine."Tax Area Code";
            pInvoicePostingBuffer."Tax Group Code" := pSalesShptLine."Tax Group Code";
            pInvoicePostingBuffer."Tax Liable" := pSalesShptLine."Tax Liable";
            pInvoicePostingBuffer."Use Tax" := FALSE;
            pInvoicePostingBuffer.Quantity := pSalesShptLine."Quantity (Base)";
        END;

        if lSalesSetup."Post Invoice Discount" THEN BEGIN
            pInvoicePostingBuffer.Amount := pInvoicePostingBuffer.Amount + pSalesShptLine."Inv. Discount Amount";
            pInvoicePostingBuffer."Inv. Discount Amount" := pSalesShptLine."Inv. Discount Amount";
            pInvoicePostingBuffer."Amount (ACY)" :=
            pInvoicePostingBuffer."Amount (ACY)" + pSalesShptLineACY."Inv. Discount Amount";
            pInvoicePostingBuffer."Inv. Discount Amt. (ACY)" := pSalesShptLineACY."Inv. Discount Amount";
            if (pSalesShptLine."Inv. Discount Amount" <> 0) OR (pSalesShptLineACY."Inv. Discount Amount" <> 0) THEN BEGIN
                gGenPostingSetup.TestField("Sales Inv. Disc. Account");
                pInvoicePostingBuffer."Inv. Discount Account" := gGenPostingSetup."Sales Inv. Disc. Account";
            END;
        END;
        if lSalesSetup."Post Line Discount" THEN BEGIN
            pInvoicePostingBuffer.Amount := pInvoicePostingBuffer.Amount + pSalesShptLine."Line Discount Amount";
            pInvoicePostingBuffer."Line Discount Amount" := pSalesShptLine."Line Discount Amount";
            pInvoicePostingBuffer."Amount (ACY)" :=
            pInvoicePostingBuffer."Amount (ACY)" + pSalesShptLineACY."Line Discount Amount";
            pInvoicePostingBuffer."Line Discount Amt. (ACY)" := pSalesShptLineACY."Line Discount Amount";
            if (pSalesShptLine."Line Discount Amount" <> 0) OR (pSalesShptLineACY."Line Discount Amount" <> 0) THEN BEGIN
                gGenPostingSetup.TestField("Sales Line Disc. Account");
                pInvoicePostingBuffer."Line Discount Account" := gGenPostingSetup."Sales Line Disc. Account";
            END;
        END;
        if lSalesSetup."Post Payment Discount" THEN BEGIN
            pInvoicePostingBuffer.Amount := pInvoicePostingBuffer.Amount + pSalesShptLine."Pmt. Disc. Given Amount";
            pInvoicePostingBuffer."Pmt. Discount Amount" := pSalesShptLine."Pmt. Disc. Given Amount";
            pInvoicePostingBuffer."Amount (ACY)" :=
            pInvoicePostingBuffer."Amount (ACY)" + pSalesShptLineACY."Pmt. Disc. Given Amount";
            pInvoicePostingBuffer."Src. Curr. Pmt. Discount Amt." := pSalesShptLineACY."Pmt. Disc. Given Amount";
            if (pSalesShptLine."Pmt. Disc. Given Amount" <> 0) OR (pSalesShptLineACY."Pmt. Disc. Given Amount" <> 0) THEN BEGIN
                gGenPostingSetup.TestField("Sales Pmt. Disc. Debit Acc.");
                pInvoicePostingBuffer."Pmt. Discount Account" := gGenPostingSetup."Sales Pmt. Disc. Debit Acc.";
            END;
        END;
        UpdInvPostingBuldFFeProduccionesgloNew(pInvoicePostingBuffer, piFALineNo, InvoicePostingBuffer);
        //pInvoicePostingBuffer.Insert();
        //END;
    End;


    Procedure UpdInvPostingBuldFFeProduccionesgloNew(pInvoicePostingBuffer: Record "Invoice Posting Buffer"; var piFALineNo: Integer; var pInvPostingingBuffer2: Record "Invoice Posting Buffer")
    Begin
        if pInvoicePostingBuffer.Type = pInvoicePostingBuffer.Type::"Fixed Asset" THEN BEGIN
            piFALineNo := piFALineNo + 1;
            pInvoicePostingBuffer."Fixed Asset Line No." := piFALineNo;
        END;
        pInvoicePostingBuffer.BuildPrimaryKey();

        pInvPostingingBuffer2 := pInvoicePostingBuffer;
        if pInvPostingingBuffer2.FIND THEN BEGIN
            pInvPostingingBuffer2.Amount := pInvPostingingBuffer2.Amount + pInvoicePostingBuffer.Amount;
            pInvPostingingBuffer2."VAT Amount" :=
                pInvPostingingBuffer2."VAT Amount" + pInvoicePostingBuffer."VAT Amount";
            pInvPostingingBuffer2."Line Discount Amount" :=
                pInvPostingingBuffer2."Line Discount Amount" + pInvoicePostingBuffer."Line Discount Amount";
            if pInvoicePostingBuffer."Line Discount Account" <> '' THEN
                pInvPostingingBuffer2."Line Discount Account" := pInvoicePostingBuffer."Line Discount Account";
            pInvPostingingBuffer2."Inv. Discount Amount" :=
                pInvPostingingBuffer2."Inv. Discount Amount" + pInvoicePostingBuffer."Inv. Discount Amount";
            if pInvoicePostingBuffer."Inv. Discount Account" <> '' THEN
                pInvPostingingBuffer2."Inv. Discount Account" := pInvoicePostingBuffer."Inv. Discount Account";
            pInvPostingingBuffer2."Pmt. Discount Amount" :=
                pInvPostingingBuffer2."Pmt. Discount Amount" + pInvoicePostingBuffer."Pmt. Discount Amount";
            if pInvoicePostingBuffer."Pmt. Discount Account" <> '' THEN
                pInvPostingingBuffer2."Pmt. Discount Account" := pInvoicePostingBuffer."Pmt. Discount Account";
            pInvPostingingBuffer2."VAT Base Amount" :=
                pInvPostingingBuffer2."VAT Base Amount" + pInvoicePostingBuffer."VAT Base Amount";
            pInvPostingingBuffer2."Amount (ACY)" :=
                pInvPostingingBuffer2."Amount (ACY)" + pInvoicePostingBuffer."Amount (ACY)";
            pInvPostingingBuffer2."VAT Amount (ACY)" :=
                pInvPostingingBuffer2."VAT Amount (ACY)" + pInvoicePostingBuffer."VAT Amount (ACY)";
            pInvPostingingBuffer2."VAT Difference" :=
                pInvPostingingBuffer2."VAT Difference" + pInvoicePostingBuffer."VAT Difference";
            pInvPostingingBuffer2."Line Discount Amt. (ACY)" :=
                pInvPostingingBuffer2."Line Discount Amt. (ACY)" +
                pInvoicePostingBuffer."Line Discount Amt. (ACY)";
            pInvPostingingBuffer2."Inv. Discount Amt. (ACY)" :=
                pInvPostingingBuffer2."Inv. Discount Amt. (ACY)" +
                pInvoicePostingBuffer."Inv. Discount Amt. (ACY)";
            pInvPostingingBuffer2."Src. Curr. Pmt. Discount Amt." :=
                pInvPostingingBuffer2."Src. Curr. Pmt. Discount Amt." +
                pInvoicePostingBuffer."Src. Curr. Pmt. Discount Amt.";
            pInvPostingingBuffer2."VAT Base Amount (ACY)" :=
                pInvPostingingBuffer2."VAT Base Amount (ACY)" +
                pInvoicePostingBuffer."VAT Base Amount (ACY)";
            pInvPostingingBuffer2.Quantity :=
                pInvPostingingBuffer2.Quantity + pInvoicePostingBuffer.Quantity;
            if NOT pInvoicePostingBuffer."System-Created Entry" THEN
                pInvPostingingBuffer2."System-Created Entry" := FALSE;
            pInvPostingingBuffer2.MODIFY;
        END ELSE
            pInvPostingingBuffer2.INSERT;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Invoice Posting Buffer", 'OnAfterBuildPrimaryKey', '', false, false)]
    local procedure OnAfterBuildPrimaryKey(var InvoicePostingBuffer: Record "Invoice Posting Buffer")
    var
        GroupID: Text;
    begin
        GroupID := InvoicePostingBuffer."Group ID" + InvoicePostingBuffer.PadField(
            InvoicePostingBuffer."Global Dimension 3 Code", MaxStrLen(InvoicePostingBuffer."Global Dimension 3 Code"));
        GroupID := GroupID + InvoicePostingBuffer.PadField(
            InvoicePostingBuffer."Global Dimension 4 Code", MaxStrLen(InvoicePostingBuffer."Global Dimension 4 Code"));
        GroupID := GroupID + InvoicePostingBuffer.PadField(
            InvoicePostingBuffer."Global Dimension 5 Code", MaxStrLen(InvoicePostingBuffer."Global Dimension 5 Code"));

        InvoicePostingBuffer."Group ID" := CopyStr(GroupID, 1, MaxStrLen(InvoicePostingBuffer."Group ID"));
    end;
    /// <summary>
    /// UpdateGlobalDimFromDimSetID.
    /// </summary>
    /// <param name="piDimSetID">Integer.</param>
    /// <param name="pCGlobalDimVal1">VAR Code[20].</param>
    /// <param name="pCGlobalDimVal2">VAR Code[20].</param>
    /// <param name="pCGlobalDimVal3">VAR Code[20].</param>
    /// <param name="pCGlobalDimVal4">VAR Code[20].</param>
    /// <param name="pCGlobalDimVal5">VAR Code[20].</param>
    procedure UpdateGlobalDimFromDimSetID(piDimSetID: Integer; var pCGlobalDimVal1: Code[20]; var pCGlobalDimVal2: Code[20]; var pCGlobalDimVal3: Code[20]; var pCGlobalDimVal4: Code[20]; var pCGlobalDimVal5: Code[20])
    var
        lCShortcutDimCodeArray: array[8] of Code[20];
    begin
        GetShortcutDimensions(piDimSetID, lCShortcutDimCodeArray);
        pCGlobalDimVal1 := lCShortcutDimCodeArray[1];
        pCGlobalDimVal2 := lCShortcutDimCodeArray[2];
        pCGlobalDimVal3 := lCShortcutDimCodeArray[3];
        pCGlobalDimVal4 := lCShortcutDimCodeArray[4];
        pCGlobalDimVal5 := lCShortcutDimCodeArray[5];

    end;

    /// <summary>
    /// GetShortcutDimensions.
    /// </summary>
    /// <param name="piDimSetID">Integer.</param>
    /// <param name="ShortcutDimCode">VAR array[8] of Code[20].</param>
    procedure GetShortcutDimensions(piDimSetID: Integer; var pCShortcutDimCodeArray: array[8] of Code[20])
    var
        lcGetShortcutDimensionValues: Codeunit "Get Shortcut Dimension Values";
    begin
        lcGetShortcutDimensionValues.GetShortcutDimensions(piDimSetID, pCShortcutDimCodeArray);
    end;

    /// <summary>
    /// GetRecDefaultDimID.
    /// </summary>
    /// <param name="RecVariant">Variant.</param>
    /// <param name="piCurrFieldNo">Integer.</param>
    /// <param name="piTableIDArray">array[20] of Integer.</param>
    /// <param name="pCNoArray">array[20] of Code[20].</param>
    /// <param name="pCSourceCode">Code[20].</param>
    /// <param name="pCGlobalDim1Code">VAR Code[20].</param>
    /// <param name="pCGlobalDim2Code">VAR Code[20].</param>
    /// <param name="pCGlobalDim3Code">VAR Code[20].</param>
    /// <param name="pCGlobalDim4Code">VAR Code[20].</param>
    /// <param name="pCGlobalDim5Code">VAR Code[20].</param>
    /// <param name="InheritFromDimSetID">Integer.</param>
    /// <param name="InheritFromTableNo">Integer.</param>
    /// <returns>Return value of type Integer.</returns>
    procedure GetRecDefaultDimID(pvRecVariant: Variant; piCurrFieldNo: Integer; piTableIDArray: array[20] of Integer; pCNoArray: array[20] of Code[20]; pCSourceCode: Code[20]; var pCGlobalDim1Code: Code[20]; var pCGlobalDim2Code: Code[20]; var pCGlobalDim3Code: Code[20]; var pCGlobalDim4Code: Code[20]; var pCGlobalDim5Code: Code[20]; piInheritFromDimSetID: Integer; piInheritFromTableNo: Integer): Integer
    var
        liDefaultDimID: Integer;
    begin
        liDefaultDimID := GetDefaultDimID(piTableIDArray, pCNoArray, pCSourceCode, pCGlobalDim1Code, pCGlobalDim2Code, pCGlobalDim3Code, pCGlobalDim4Code, pCGlobalDim5Code, piInheritFromDimSetID, piInheritFromTableNo);
        exit(liDefaultDimID);
    end;



    /// <summary>
    /// GetDefaultDimID.
    /// </summary>
    /// <param name="piTableIDArray">array[20] of Integer.</param>
    /// <param name="pCNoArray">array[20] of Code[20].</param>
    /// <param name="pcSourceCode">Code[20].</param>
    /// <param name="pCGlobalDim1Code">VAR Code[20].</param>
    /// <param name="pCGlobalDim2Code">VAR Code[20].</param>
    /// <param name="pCGlobalDim3Code">VAR Code[20].</param>
    /// <param name="pCGlobalDim4Code">VAR Code[20].</param>
    /// <param name="pCGlobalDim5Code">VAR Code[20].</param>
    /// <param name="piInheritFromDimSetID">Integer.</param>
    /// <param name="piInheritFromTableNo">Integer.</param>
    /// <returns>Return value of type Integer.</returns>
    procedure GetDefaultDimID(piTableIDArray: array[20] of Integer; pcNoArray: array[20] of Code[20]; pcSourceCode: Code[20]; var pCGlobalDim1Code: Code[20]; var pCGlobalDim2Code: Code[20]; var pCGlobalDim3Code: Code[20]; var pCGlobalDim4Code: Code[20]; var pCGlobalDim5Code: Code[20]; piInheritFromDimSetID: Integer; piInheritFromTableNo: Integer): Integer
    var
        lDimValue: Record "Dimension Value";
        lDefaultDimPriority1: Record "Default Dimension Priority";
        lDefaultDimPriority2: Record "Default Dimension Priority";
        lDefaultDim: Record "Default Dimension";
        lDimBufTMP: Record "Dimension Buffer" temporary;
        lDimSetEntryTMP: Record "Dimension Set Entry" temporary;
        lDimSetEntryTMP0: Record "Dimension Set Entry" temporary;
        i: Integer;
        j: Integer;
        lCNoFilterarray: array[5] of Code[20];
        liNewDimSetID: Integer;
        IsHandled: Boolean;
        lGenLedgerSetupShortcutDimCodeArray: array[5] of Code[20];
    begin
        gGenLedgerSetup.Get;
        lGenLedgerSetupShortcutDimCodeArray[1] := gGenLedgerSetup."Global Dimension 1 Code";
        lGenLedgerSetupShortcutDimCodeArray[2] := gGenLedgerSetup."ShortCut Dimension 2 Code";
        lGenLedgerSetupShortcutDimCodeArray[3] := gGenLedgerSetup."ShortCut Dimension 3 Code";
        lGenLedgerSetupShortcutDimCodeArray[4] := gGenLedgerSetup."ShortCut Dimension 4 Code";
        lGenLedgerSetupShortcutDimCodeArray[5] := gGenLedgerSetup."ShortCut Dimension 5 Code";
        if piInheritFromDimSetID > 0 then
            GetDimensionSet(lDimSetEntryTMP0, piInheritFromDimSetID);
        if lDimSetEntryTMP0.FINDSet then
            repeat
                lDimBufTMP.Init();
                lDimBufTMP."Table ID" := piInheritFromTableNo;
                lDimBufTMP."Entry No." := 0;
                lDimBufTMP."Dimension Code" := lDimSetEntryTMP0."Dimension Code";
                lDimBufTMP."Dimension Value Code" := lDimSetEntryTMP0."Dimension Value Code";
                lDimBufTMP.Insert();
            until lDimSetEntryTMP0.Next = 0;

        lCNoFilterarray[2] := '';
        for i := 1 to ArrayLen(piTableIDArray) do
            if (piTableIDArray[i] <> 0) and (pCNoArray[i] <> '') then begin
                IsHandled := false;
                if not IsHandled then begin
                    lDefaultDim.SetRange("Table ID", piTableIDArray[i]);
                    lCNoFilterarray[1] := pCNoArray[i];
                    for j := 1 to 2 do begin
                        lDefaultDim.SetRange("No.", lCNoFilterarray[j]);
                        if lDefaultDim.FINDSet then
                            repeat
                                if lDefaultDim."Dimension Value Code" <> '' then begin
                                    lDimBufTMP.SetRange("Dimension Code", lDefaultDim."Dimension Code");
                                    if not lDimBufTMP.FINDFIRST then begin
                                        lDimBufTMP.Init();
                                        lDimBufTMP."Table ID" := lDefaultDim."Table ID";
                                        lDimBufTMP."Entry No." := 0;
                                        lDimBufTMP."Dimension Code" := lDefaultDim."Dimension Code";
                                        lDimBufTMP."Dimension Value Code" := lDefaultDim."Dimension Value Code";
                                        lDimBufTMP.Insert();
                                    end else
                                        if lDefaultDimPriority1.Get(pCSourceCode, lDefaultDim."Table ID") then
                                            if lDefaultDimPriority2.Get(pCSourceCode, lDimBufTMP."Table ID") then begin
                                                if lDefaultDimPriority1.Priority < lDefaultDimPriority2.Priority then begin
                                                    lDimBufTMP.Delete();
                                                    lDimBufTMP."Table ID" := lDefaultDim."Table ID";
                                                    lDimBufTMP."Entry No." := 0;
                                                    lDimBufTMP."Dimension Value Code" := lDefaultDim."Dimension Value Code";
                                                    lDimBufTMP.Insert();
                                                end;
                                            end else begin
                                                lDimBufTMP.Delete();
                                                lDimBufTMP."Table ID" := lDefaultDim."Table ID";
                                                lDimBufTMP."Entry No." := 0;
                                                lDimBufTMP."Dimension Value Code" := lDefaultDim."Dimension Value Code";
                                                lDimBufTMP.Insert();
                                            end;
                                    if lGenLedgerSetupShortcutDimCodeArray[1] = lDimBufTMP."Dimension Code" then
                                        pCGlobalDim1Code := lDimBufTMP."Dimension Value Code";
                                    if lGenLedgerSetupShortcutDimCodeArray[2] = lDimBufTMP."Dimension Code" then
                                        pCGlobalDim2Code := lDimBufTMP."Dimension Value Code";
                                    if lGenLedgerSetupShortcutDimCodeArray[3] = lDimBufTMP."Dimension Code" then
                                        pCGlobalDim3Code := lDimBufTMP."Dimension Value Code";
                                    if lGenLedgerSetupShortcutDimCodeArray[4] = lDimBufTMP."Dimension Code" then
                                        pCGlobalDim4Code := lDimBufTMP."Dimension Value Code";
                                    if lGenLedgerSetupShortcutDimCodeArray[5] = lDimBufTMP."Dimension Code" then
                                        pCGlobalDim5Code := lDimBufTMP."Dimension Value Code";
                                end;
                            until lDefaultDim.Next = 0;
                    end;
                end;
            end;


        lDimBufTMP.Reset();
        if lDimBufTMP.FINDSet then begin
            repeat
                if lDimValue.Get(lDimBufTMP."Dimension Code", lDimBufTMP."Dimension Value Code") Then begin
                    lDimSetEntryTMP."Dimension Code" := lDimBufTMP."Dimension Code";
                    lDimSetEntryTMP."Dimension Value Code" := lDimBufTMP."Dimension Value Code";
                    lDimSetEntryTMP."Dimension Value ID" := lDimValue."Dimension Value ID";
                    lDimSetEntryTMP.Insert();
                end;
            until lDimBufTMP.Next = 0;
            liNewDimSetID := GetDimensionSetID(lDimSetEntryTMP);
        end;
        exit(liNewDimSetID);
    end;

    /// <summary>
    /// GetDimensionSetID.
    /// </summary>
    /// <param name="DimSetEntry2">VAR Record "Dimension Set Entry".</param>
    /// <returns>Return value of type Integer.</returns>
    procedure GetDimensionSetID(var pDimSetEntry2: Record "Dimension Set Entry"): Integer
    var
        lDimSetEntry: Record "Dimension Set Entry";
    begin
        exit(lDimSetEntry.GetDimensionSetID(pDimSetEntry2));
    end;

    /// <summary>
    /// GetDimensionSet.
    /// </summary>
    /// <param name="TempDimSetEntry">Temporary VAR Record "Dimension Set Entry".</param>
    /// <param name="DimSetID">Integer.</param>
    /// <summary>
    /// GetDimensionSet.
    /// </summary>
    /// <param name="TempDimSetEntry">Temporary VAR Record "Dimension Set Entry".</param>
    /// <param name="DimSetID">Integer.</param>
    procedure GetDimensionSet(var pDimSetEntryTMP: Record "Dimension Set Entry" temporary; piDimSetID: Integer)
    var
        lDimSetEntry: Record "Dimension Set Entry";
        IsHandled: Boolean;
    begin
        IsHandled := false;

        pDimSetEntryTMP.DeleteAll();
        with lDimSetEntry do begin
            SetRange("Dimension Set ID", piDimSetID);
            if FINDSet then
                repeat
                    pDimSetEntryTMP := lDimSetEntry;
                    pDimSetEntryTMP.Insert();
                until Next = 0;
        end;
    end;


    Procedure CompruebaAlbarán(pCNoAlb: Code[20]; var pPurchHeader: Record "Purchase Header"): Boolean
    var
        lPurchRcptHdr: Record "Purch. Rcpt. Header";

    begin
        if NOT lPurchRcptHdr.GET(pCNoAlb) THEN EXIT(FALSE);
        if pPurchHeader.Invoice THEN BEGIN
            lPurchRcptHdr.Facturado := TRUE;
            lPurchRcptHdr.MODIFY;
        END;
        if lPurchRcptHdr.Contabilizado THEN BEGIN
            lPurchRcptHdr.Contabilizado := Contab(lPurchRcptHdr."No.");
        END;
        EXIT(lPurchRcptHdr.Contabilizado);
    End;

    Procedure CompruebaDevolución(pCNoAlb: Code[20]; var pPurchHeader: Record "Purchase Header"): Boolean
    var
        lReturnShptHdr: Record "Return Shipment Header";
    Begin
        if NOT lReturnShptHdr.GET(pCNoAlb) THEN EXIT(FALSE);
        if pPurchHeader.Invoice THEN BEGIN
            lReturnShptHdr.Facturado := TRUE;
            lReturnShptHdr.MODIFY;
        END;
        EXIT(lReturnShptHdr.Contabilizado);
    End;

    /// <summary>
    /// Contab.
    /// </summary>
    /// <param name="Num">Code[20].</param>
    /// <returns>Return value of type Boolean.</returns>
    procedure Contab(pCNum: Code[20]): Boolean
    var
        lGlEntry: Record "G/L Entry";
        lDImp: Decimal;
    begin
        lGlEntry.SETCURRENTKEY(lGlEntry."Document No.");
        lGlEntry.SETRANGE(lGlEntry."Document No.", pCNum);
        if lGlEntry.FINDFIRST THEN
            REPEAT
                if lGlEntry."Document Type" = lGlEntry."Document Type"::Receipt THEN BEGIN
                    if COPYSTR(lGlEntry."G/L Account No.", 1, 1) = '6' THEN lDImp := lDImp + lGlEntry.Amount;
                    if COPYSTR(lGlEntry."G/L Account No.", 1, 2) = '47' THEN lDImp := lDImp + lGlEntry.Amount;
                END;
            UNTIL lGlEntry.NEXT = 0;
        if lDImp = 0 THEN EXIT(FALSE);
        EXIT(TRUE);
    end;

    PROCEDURE TestActivos(VAR pPurchHeader: Record "Purchase Header"): Boolean
    VAR
        lPurchaseLine: Record "Purchase Line";
    BEGIN
        lPurchaseLine.SETRANGE(lPurchaseLine."Document Type", pPurchHeader."Document Type");
        lPurchaseLine.SETRANGE(lPurchaseLine."Document No.", pPurchHeader."No.");
        lPurchaseLine.SETRANGE(lPurchaseLine.Type, lPurchaseLine.Type::"Fixed Asset");
        EXIT(lPurchaseLine.FINDFIRST);
    END;

    PROCEDURE TestActivosAlb(VAR pPurchRcptHeader: Record "Purch. Rcpt. Header"): Boolean
    VAR
        lPurchRcptLine: Record "Purch. Rcpt. Line";
    BEGIN
        lPurchRcptLine.SETRANGE("Document No.", pPurchRcptHeader."No.");
        lPurchRcptLine.SETRANGE(Type, lPurchRcptLine.Type::"Fixed Asset");
        EXIT(lPurchRcptLine.FINDFIRST);
    END;

    PROCEDURE TestActivosShp(VAR pReturnShptHeader: Record "Return Shipment Header"): Boolean
    VAR
        lReturnShptLine: Record "Return Shipment Line";
    BEGIN
        lReturnShptLine.SETRANGE(lReturnShptLine."Document No.", pReturnShptHeader."No.");
        lReturnShptLine.SETRANGE(lReturnShptLine.Type, lReturnShptLine.Type::"Fixed Asset");
        EXIT(lReturnShptLine.FINDFIRST);
    END;

    PROCEDURE Dividir(VAR pPurchHeader: Record "Purchase Header"; pdFecha: Date; Ship: Boolean; Receive: Boolean; piAlbaran: Integer; piNumeroAlbaranes: Integer): Code[20];
    VAR
        lPurchaseLine: Record "Purchase Line";
        lcPurcPost: Codeunit "Purch.-Post";
    BEGIN

        lPurchaseLine.SETRANGE(lPurchaseLine."Document Type", pPurchHeader."Document Type");
        lPurchaseLine.SETRANGE(lPurchaseLine."Document No.", pPurchHeader."No.");
        lPurchaseLine.SETFILTER(lPurchaseLine.Type, '<>%1', lPurchaseLine.Type::" ");
        if lPurchaseLine.FINDFIRST THEN
            REPEAT
                if piAlbaran = 1 THEN BEGIN
                    if lPurchaseLine."Document Type" = lPurchaseLine."Document Type"::Order THEN
                        lPurchaseLine."Cantidad a dividir" := lPurchaseLine."Qty. to Receive"
                    ELSE
                        lPurchaseLine."Cantidad a dividir" := lPurchaseLine."Return Qty. to Ship";
                END;
                if lPurchaseLine."Document Type" = lPurchaseLine."Document Type"::Order THEN
                    lPurchaseLine.VALIDATE("Qty. to Receive", (lPurchaseLine."Cantidad a dividir" / piNumeroAlbaranes))
                ELSE
                    lPurchaseLine.VALIDATE("Return Qty. to Ship", (lPurchaseLine."Cantidad a dividir" / piNumeroAlbaranes));
                lPurchaseLine.MODIFY;
            UNTIL lPurchaseLine.NEXT = 0;
        pPurchHeader.Ship := Ship;
        pPurchHeader.Receive := Receive;
        pPurchHeader."Desactiva Validaciones" := TRUE;
        pPurchHeader.VALIDATE("Posting Date", pdFecha);
        pPurchHeader.MODIFY;
        COMMIT;
        CLEAR(lcPurcPost);
        lcPurcPost.RUN(pPurchHeader);
        //if Selection=4 THEN Contabilizar(PurchHeader);
        //if Selection=1 THEN Traspasar(PurchHeader);
        COMMIT;
        pPurchHeader.GET(pPurchHeader."Document Type", pPurchHeader."No.");
        if pPurchHeader."Last Return Shipment No." <> '' THEN
            pPurchHeader."Last Receiving No." := pPurchHeader."Last Return Shipment No.";
        EXIT(pPurchHeader."Last Receiving No.");
        //if Selection = 1 THEN Traspasar(PurchHeader);
    END;

    PROCEDURE DividirTerminos(VAR pPurchHeader: Record "Purchase Header"; Ship: Boolean; Receive: Boolean; piSelection: Integer)
    VAR
        lPurchaseLine: Record "Purchase Line";

        lPedidosPendientes: Record "Pedidos Pendientes";
        liEntryNo: Integer;
        ldFecha: Date;
        lCDoc: Code[20];
        lcPurchPost: Codeunit "Purch.-Post";
    BEGIN
        lPedidosPendientes.SETCURRENTKEY(lPedidosPendientes."Posting Date", lPedidosPendientes."Entry No.");
        lPedidosPendientes.SETRANGE(lPedidosPendientes."Order No.", pPurchHeader."No.");
        if lPedidosPendientes.COUNT = 0 THEN ERROR(glEjecutarporTerminos);
        // Ponemos a recibir =0;
        lPurchaseLine.SETRANGE(lPurchaseLine."Document Type", pPurchHeader."Document Type");
        lPurchaseLine.SETRANGE(lPurchaseLine."Document No.", pPurchHeader."No.");
        if lPurchaseLine.FINDFIRST THEN
            REPEAT
                lPurchaseLine."Cantidad a dividir" := lPurchaseLine."Qty. to Receive";
                lPurchaseLine.VALIDATE("Qty. to Receive", 0);
                lPurchaseLine.MODIFY
        UNTIL lPurchaseLine.NEXT = 0;

        if lPedidosPendientes.FINDFIRST() THEN BEGIN
            liEntryNo := lPedidosPendientes."Entry No.";
            ldFecha := lPedidosPendientes."Posting Date";
            lCDoc := lPedidosPendientes."Document No.";
        END;
        if lPedidosPendientes.FINDFIRST THEN
            REPEAT
                if (ldFecha <> lPedidosPendientes."Posting Date") OR (lCDoc <> lPedidosPendientes."Document No.") THEN BEGIN
                    pPurchHeader.Ship := Ship;
                    pPurchHeader.Receive := Receive;
                    pPurchHeader."Desactiva Validaciones" := TRUE;
                    pPurchHeader.VALIDATE("Posting Date", ldFecha);
                    pPurchHeader."Vendor Shipment No." := lPedidosPendientes."Document No.";
                    pPurchHeader.MODIFY;
                    COMMIT;
                    CLEAR(lcPurchPost);
                    lcPurchPost.RUN(pPurchHeader);
                    if piSelection = 1 THEN Traspasar(pPurchHeader);
                    if piSelection = 4 THEN Contabilizar(pPurchHeader);
                    lPurchaseLine.RESET;
                    lPurchaseLine.SETRANGE(lPurchaseLine."Document Type", pPurchHeader."Document Type");
                    lPurchaseLine.SETRANGE(lPurchaseLine."Document No.", pPurchHeader."No.");
                    if lPurchaseLine.FINDFIRST THEN
                        REPEAT
                            lPurchaseLine.VALIDATE("Qty. to Receive", 0);
                            lPurchaseLine.MODIFY
            UNTIL lPurchaseLine.NEXT = 0;

                END;
                liEntryNo := lPedidosPendientes."Entry No.";
                ldFecha := lPedidosPendientes."Posting Date";
                lCDoc := lPedidosPendientes."Document No.";
                lPurchaseLine.SETRANGE(lPurchaseLine."Document Type", pPurchHeader."Document Type");
                lPurchaseLine.SETRANGE(lPurchaseLine."Document No.", pPurchHeader."No.");
                lPurchaseLine.SETFILTER(lPurchaseLine.Type, '<>%1', lPurchaseLine.Type::" ");
                lPurchaseLine.SETRANGE(lPurchaseLine."No.", lPedidosPendientes."Account No.");
                lPurchaseLine.SETRANGE("Linea de proyecto", lPedidosPendientes."Entry No.");
                if lPurchaseLine.FINDFIRST THEN
                    REPEAT
                        if lPurchaseLine."Cantidad a dividir" = 0 THEN BEGIN
                            lPurchaseLine."Cantidad a dividir" := lPurchaseLine."Qty. to Receive";
                        END;
                        lPurchaseLine.VALIDATE(lPurchaseLine."Outstanding Quantity", lPurchaseLine.Quantity - lPurchaseLine."Quantity Received");
                        if (lPedidosPendientes.Amount * lPurchaseLine.Quantity) > lPurchaseLine."Outstanding Quantity" THEN
                            lPurchaseLine.VALIDATE("Qty. to Receive", lPurchaseLine."Outstanding Quantity")
                        ELSE
                            lPurchaseLine.VALIDATE("Qty. to Receive", (lPedidosPendientes.Amount) * lPurchaseLine.Quantity);
                        lPurchaseLine.MODIFY;
                    UNTIL lPurchaseLine.NEXT = 0;
            UNTIL lPedidosPendientes.NEXT = 0;
        pPurchHeader.Ship := Ship;
        pPurchHeader.Receive := Receive;
        pPurchHeader."Desactiva Validaciones" := TRUE;
        pPurchHeader.VALIDATE("Posting Date", ldFecha);
        pPurchHeader."Vendor Shipment No." := lPedidosPendientes."Document No.";
        pPurchHeader.MODIFY;
        COMMIT;
        CLEAR(lcPurchPost);
        lcPurchPost.RUN(pPurchHeader);
        //if Selection = 1 then Traspasar(PurchHeader);
        //if Selection = 2 Then Contabilizar(PurchHeader);
    END;

    PROCEDURE Traspasar(VAR pPurchHeader: Record "Purchase Header")
    VAR
        lPurchRcptHdr: Record "Purch. Rcpt. Header";
        lReturnShipmentHeader: Record "Return Shipment Header";
        lcProy: Codeunit "Gestion Proyecto";
        lcPurchPost: Codeunit "Purch.-Post";
    BEGIN
        if NOT TestActivos(pPurchHeader) THEN EXIT;
        CASE pPurchHeader."Document Type" OF
            pPurchHeader."Document Type"::Order:
                BEGIN
                    lPurchRcptHdr.GET(pPurchHeader."Last Receiving No.");
                    CLEAR(lcProy);
                    if lcProy.DebeTraspasarsePC(lPurchRcptHdr) THEN
                        lcProy.TrasPasaCompraaEmpresas(lPurchRcptHdr);
                END;
            pPurchHeader."Document Type"::"Return Order":
                BEGIN
                    lReturnShipmentHeader.GET(pPurchHeader."Last Return Shipment No.");
                    CLEAR(lcProy);
                    if lcProy.DebeTraspasarseDC(lReturnShipmentHeader) THEN
                        lcProy.TrasPasaDevolaEmpresas(lReturnShipmentHeader);

                END;
        END;
    END;

    /// <summary>
    /// Contabilizar.
    /// </summary>
    /// <param name="PurchHeader">VAR Record "Purchase Header".</param>
    procedure Contabilizar(var pPurchHeader: Record "Purchase Header")
    var
        lPurchRcptHdr: Record "Purch. Rcpt. Header";
        lReturnShipmentHeader: Record "Return Shipment Header";
        lcProy: Codeunit "Gestion Proyecto";
    begin

        CASE pPurchHeader."Document Type" OF
            pPurchHeader."Document Type"::Order:
                BEGIN
                    lPurchRcptHdr.GET(pPurchHeader."Last Receiving No.");
                    ContabilizarAlbaranes(lPurchRcptHdr);
                    lPurchRcptHdr.GET(pPurchHeader."Last Receiving No.");
                    CLEAR(lcProy);
                    if lcProy.DebeTraspasarsePC(lPurchRcptHdr) THEN
                        lcProy.TrasPasaCompraaEmpresas(lPurchRcptHdr);
                END;
            pPurchHeader."Document Type"::"Return Order":
                BEGIN
                    lReturnShipmentHeader.GET(pPurchHeader."Last Return Shipment No.");
                    ContabilizarDevoluciones(lReturnShipmentHeader);
                    lReturnShipmentHeader.GET(pPurchHeader."Last Return Shipment No.");
                    CLEAR(lcProy);
                    if lcProy.DebeTraspasarseDC(lReturnShipmentHeader) THEN
                        lcProy.TrasPasaDevolaEmpresas(lReturnShipmentHeader);

                END;
        END;
    end;

    PROCEDURE GenerarFechasAlbaran(pCContrato: Code[20]; pCPedido: Code[20])
    VAR
        lContrato: Record "Sales Header";
        lSalesLineInv: Record "Sales Line";
        lSalesHdrInv: Record "Sales Header";
        lPurchHdrOrder: Record "Purchase Header";
        lPurchaseLineOrder: Record "Purchase Line";
        lPedPdtes: Record "Pedidos Pendientes";
        lJobPlanningLine: Record "Job Planning Line";
        lpPedidos: Page "Pedidos a albaranar";
        lSalesInvLine: Record "Sales Invoice Line";
        lSalesShptLine: Record "Sales Shipment Line";
        lSalesShptHdr: Record "Sales Shipment Header";
        lSalesInvHdr: Record "Sales Invoice Header";
        liNumFacturas: Integer;
        lDTotalCant: Decimal;
        lDTotalCant2: Decimal;
        liLinea: Integer;
        liLinea2: Integer;
    BEGIN
        lPedPdtes.SETRANGE(lPedPdtes."Order No.", pCPedido);
        lPedPdtes.DELETEALL;
        lSalesLineInv.SETCURRENTKEY("Document Type", "Job No.", "No linea proyecto");

        lSalesLineInv.SETRANGE(lSalesLineInv."Document Type", lSalesLineInv."Document Type"::Invoice);
        lSalesLineInv.SETFILTER("Line Amount", '<>%1', 0);
        lSalesLineInv.SETRANGE(lSalesLineInv."Job No.", glNADA);
        if NOT lContrato.GET(lContrato."Document Type"::Order, pCContrato) THEN
            ERROR(glPedidoSinContrato + glPedidoSinContrato1);
        lPurchHdrOrder.SETRANGE(lPurchHdrOrder."Document Type", lPurchHdrOrder."Document Type"::Order);
        lPurchHdrOrder.SETRANGE(lPurchHdrOrder."No.", pCPedido);
        if lPurchHdrOrder.FINDFIRST THEN BEGIN
            lPurchaseLineOrder.SETRANGE(lPurchaseLineOrder."Document Type", lPurchaseLineOrder."Document Type"::Order);
            lPurchaseLineOrder.SETRANGE(lPurchaseLineOrder."Document No.", lPurchHdrOrder."No.");
            lPurchaseLineOrder.SETFILTER(lPurchaseLineOrder.Type, '<>%1', 0);
            lPurchaseLineOrder.SETRANGE(lPurchaseLineOrder."Linea de proyecto", 0);
            if lPurchaseLineOrder.FINDFIRST THEN
                ERROR(glNoAutomatico + glNoAutomatico1 + glNoAutomatico2);
            lPurchaseLineOrder.SETRANGE(lPurchaseLineOrder."Linea de proyecto");
            liLinea := 0;
            liLinea2 := 0;
            if lPurchaseLineOrder.FINDFIRST THEN
                REPEAT
                    lJobPlanningLine.SETRANGE(lJobPlanningLine."Job No.", lContrato."Nº Proyecto");
                    lJobPlanningLine.SETRANGE(lJobPlanningLine."Line No.", lPurchaseLineOrder."Linea de proyecto");
                    if lJobPlanningLine.FINDFIRST THEN BEGIN
                        CASE lJobPlanningLine."Crear pedidos" OF
                            lJobPlanningLine."Crear pedidos"::"De Compra Y De Venta":
                                BEGIN
                                    lSalesLineInv.SETRANGE(lSalesLineInv."Document Type", lSalesLineInv."Document Type"::Invoice);
                                    lSalesLineInv.SETRANGE(lSalesLineInv."Job No.", lContrato."Nº Proyecto");
                                    lSalesLineInv.SETRANGE("No linea proyecto", lJobPlanningLine."Line No.");
                                END;
                            lJobPlanningLine."Crear pedidos"::"De Compra":
                                BEGIN
                                    lSalesLineInv.SETRANGE(lSalesLineInv."Document Type", lSalesLineInv."Document Type"::Invoice);
                                    lSalesLineInv.SETRANGE(lSalesLineInv."Job No.", lContrato."Nº Proyecto");
                                    lSalesLineInv.SETRANGE("No linea proyecto", lJobPlanningLine."Origin Line No.");
                                END;
                        END;
                    END;
                    //
                    lDTotalCant := 0;

                    if lSalesLineInv.FINDFIRST THEN
                        REPEAT
                            if lSalesHdrInv.Get(lSalesLineInv."Document Type", lSalesLineInv."Document No.") Then
                                if lSalesHdrInv."Factura prepago" = False Then
                                    lDTotalCant := lDTotalCant + lSalesLineInv."Line Amount";
                        UNTIL lSalesLineInv.NEXT = 0;
                    lSalesInvLine.SETCURRENTKEY("Job No.", "No linea proyecto");
                    if lJobPlanningLine.FINDFIRST THEN BEGIN
                        CASE lJobPlanningLine."Crear pedidos" OF
                            lJobPlanningLine."Crear pedidos"::"De Compra Y De Venta":
                                BEGIN
                                    lSalesInvLine.SETRANGE(lSalesInvLine."Job No.", lContrato."Nº Proyecto");
                                    lSalesInvLine.SETRANGE("No linea proyecto", lJobPlanningLine."Line No.");
                                END;
                            lJobPlanningLine."Crear pedidos"::"De Compra":
                                BEGIN
                                    lSalesInvLine.SETRANGE(lSalesInvLine."Job No.", lContrato."Nº Proyecto");
                                    lSalesInvLine.SETRANGE("No linea proyecto", lJobPlanningLine."Origin Line No.");
                                END;
                        END;
                    END;
                    lSalesInvLine.SETFILTER("Amount", '<>%1', 0);
                    if lSalesInvLine.FINDFIRST THEN
                        REPEAT
                            if lSalesInvHdr.get(lSalesInvLine."Document No.") then
                                if lSalesInvHdr."Prepayment Invoice" = false then
                                    lDTotalCant := lDTotalCant + lSalesInvLine.Amount
                       UNTIL lSalesInvLine.NEXT = 0;
                    //albaranes

                    //lSalesShptLine.SETCURRENTKEY("Job No.", "No linea proyecto");
                    if lJobPlanningLine.FINDFIRST THEN BEGIN
                        CASE lJobPlanningLine."Crear pedidos" OF
                            lJobPlanningLine."Crear pedidos"::"De Compra Y De Venta":
                                BEGIN
                                    lSalesShptLine.SETRANGE(lSalesShptLine."Job No.", lContrato."Nº Proyecto");
                                    lSalesShptLine.SETRANGE("No linea proyecto", lJobPlanningLine."Line No.");
                                END;
                            lJobPlanningLine."Crear pedidos"::"De Compra":
                                BEGIN
                                    lSalesShptLine.SETRANGE(lSalesShptLine."Job No.", lContrato."Nº Proyecto");
                                    lSalesShptLine.SETRANGE("No linea proyecto", lJobPlanningLine."Origin Line No.");
                                END;
                        END;
                    END;
                    lSalesShptLine.SETFILTER("Amount", '<>%1', 0);
                    if lSalesShptLine.FINDFIRST then
                        repeat
                            if lSalesShptHdr.get(lSalesShptLine."Document No.") then
                                if lSalesShptHdr.Contabilizado = true then
                                    lDTotalCant := lDTotalCant + lSalesShptLine.Amount
                        until lSalesShptLine.NEXT = 0;
                    if lJobPlanningLine.FINDFIRST THEN;

                    if (lDTotalCant = 0) THEN BEGIN
                        if NOT CONFIRM(glTxtDividir, FALSE, lJobPlanningLine."Line No.") THEN
                            ERROR(glCancelado) ELSE BEGIN
                            ////
                            if liLinea = 0 THEN ERROR(glPrimeraLinea);
                            if lJobPlanningLine.FINDFIRST THEN BEGIN
                                CASE lJobPlanningLine."Crear pedidos" OF
                                    lJobPlanningLine."Crear pedidos"::"De Compra Y De Venta":
                                        BEGIN
                                            lSalesLineInv.SETRANGE(lSalesLineInv."Document Type", lSalesLineInv."Document Type"::Invoice);
                                            lSalesLineInv.SETRANGE(lSalesLineInv."Job No.", lContrato."Nº Proyecto");
                                            lSalesLineInv.SETRANGE("No linea proyecto", liLinea);
                                        END;
                                    lJobPlanningLine."Crear pedidos"::"De Compra":
                                        BEGIN
                                            lSalesLineInv.SETRANGE(lSalesLineInv."Document Type", lSalesLineInv."Document Type"::Invoice);
                                            lSalesLineInv.SETRANGE(lSalesLineInv."Job No.", lContrato."Nº Proyecto");
                                            lSalesLineInv.SETRANGE("No linea proyecto", liLinea2);
                                        END;
                                END;
                            END;
                            //
                            lDTotalCant := 0;
                            if lSalesLineInv.FINDFIRST THEN
                                REPEAT
                                    lSalesHdrInv.GET(lSalesLineInv."Document Type", lSalesLineInv."Document No.");
                                    if lSalesHdrInv."Factura prepago" = false then
                                        lDTotalCant := lDTotalCant + lSalesLineInv."Line Amount";
                                UNTIL lSalesLineInv.NEXT = 0;
                            if lJobPlanningLine.FINDFIRST THEN BEGIN
                                CASE lJobPlanningLine."Crear pedidos" OF
                                    lJobPlanningLine."Crear pedidos"::"De Compra Y De Venta":
                                        BEGIN
                                            lSalesInvLine.SETRANGE(lSalesInvLine."Job No.", lContrato."Nº Proyecto");
                                            lSalesInvLine.SETRANGE("No linea proyecto", liLinea);
                                        END;
                                    lJobPlanningLine."Crear pedidos"::"De Compra":
                                        BEGIN
                                            lSalesInvLine.SETRANGE(lSalesInvLine."Job No.", lContrato."Nº Proyecto");
                                            lSalesInvLine.SETRANGE("No linea proyecto", lJobPlanningLine."Origin Line No.");
                                        END;
                                END;
                            END;
                            if lSalesInvLine.FINDFIRST THEN
                                REPEAT
                                    if lSalesInvHdr.get(lSalesInvLine."Document No.") then
                                        if lSalesInvHdr."Prepayment Invoice" = false then
                                            lDTotalCant := lDTotalCant + lSalesInvLine.Amount
                               UNTIL lSalesInvLine.NEXT = 0;
                            //albaranes
                            //albaranes

                            //lSalesShptLine.SETCURRENTKEY("Job No.", "No linea proyecto");
                            if lJobPlanningLine.FINDFIRST THEN BEGIN
                                CASE lJobPlanningLine."Crear pedidos" OF
                                    lJobPlanningLine."Crear pedidos"::"De Compra Y De Venta":
                                        BEGIN
                                            lSalesShptLine.SETRANGE(lSalesShptLine."Job No.", lContrato."Nº Proyecto");
                                            lSalesShptLine.SETRANGE("No linea proyecto", liLinea);
                                        END;
                                    lJobPlanningLine."Crear pedidos"::"De Compra":
                                        BEGIN
                                            lSalesShptLine.SETRANGE(lSalesShptLine."Job No.", lContrato."Nº Proyecto");
                                            lSalesShptLine.SETRANGE("No linea proyecto", lJobPlanningLine."Origin Line No.");
                                        END;
                                END;
                            END;
                            lSalesShptLine.SETFILTER("Amount", '<>%1', 0);
                            if lSalesShptLine.FINDFIRST then
                                repeat
                                    if lSalesShptHdr.get(lSalesShptLine."Document No.") then
                                        if lSalesShptHdr.Contabilizado = true then
                                            lDTotalCant := lDTotalCant + lSalesShptLine.Amount
                                until lSalesShptLine.NEXT = 0;

                        END;
                        if lSalesLineInv.FINDFIRST THEN
                            REPEAT
                                //key(Key1; "Posting Date", "Account Type", "Location Code", "Inventory Posting Group", "Gen. Bus. Posting Group", "Gen. Prod. Posting Group", "Dimension Set ID", Negative, "Bal. Account Type")
                                if lSalesHdrInv.GET(lSalesLineInv."Document Type"::Invoice, lSalesLineInv."Document No.") THEN BEGIN
                                    if lSalesHdrInv."Factura prepago" = false Then begin
                                        if NOT lPedPdtes.GET(lSalesHdrInv."Posting Date", lPurchHdrOrder."No.", lSalesLineInv."Document No.", lPurchaseLineOrder."No.", lPurchaseLineOrder."Line No.") THEN
                                            lPedPdtes.INIT;
                                        lPedPdtes."Posting Date" := lSalesHdrInv."Posting Date";
                                        lPedPdtes."Account No." := lPurchaseLineOrder."No.";
                                        lPedPdtes."Resource No." := lPurchaseLineOrder."No.";
                                        lPedPdtes."Document No." := lSalesLineInv."Document No.";
                                        if lDTotalCant <> 0 THEN
                                            lPedPdtes.Amount := lPedPdtes.Amount + (lSalesLineInv."Line Amount" / lDTotalCant);//*lPurchaseLineOrder.Quantity;
                                        lPedPdtes."Order No." := lPurchHdrOrder."No.";

                                        lPedPdtes.Description := lPurchaseLineOrder.Description;

                                        lPedPdtes."Amount (ACY)" := lPurchaseLineOrder."Line Amount";//"Unit Cost"*lPurchaseLineOrder.Quantity;
                                        liNumFacturas += 1;
                                        lPedPdtes."Dimension Entry No." := lPurchaseLineOrder."Line No.";
                                        lPedPdtes."Entry No." := lJobPlanningLine."Line No.";//DATE2DMY(lPedPdtes."Posting Date",3)*100+DATE2DMY(lPedPdtes."Posting Date",2);
                                        if lPedPdtes.INSERT THEN lPedPdtes.MODIFY;
                                    end;
                                END;
                            UNTIL lSalesLineInv.NEXT = 0;
                        //
                        if lSalesInvLine.FINDFIRST THEN
                            REPEAT
                                //key(Key1; "Posting Date", "Account Type", "Location Code", "Inventory Posting Group", "Gen. Bus. Posting Group", "Gen. Prod. Posting Group", "Dimension Set ID", Negative, "Bal. Account Type")
                                if lSalesInvHdr.GET(lSalesInvLine."Document No.") THEN BEGIN
                                    if lSalesInvHdr."Prepayment Invoice" = false Then begin
                                        if NOT lPedPdtes.GET(lSalesInvHdr."Posting Date",
                                         lPurchHdrOrder."No.", lSalesInvLine."Document No.", lPurchaseLineOrder."No.", lPurchaseLineOrder."Line No.") THEN
                                            lPedPdtes.INIT;

                                        lPedPdtes."Posting Date" := lSalesInvHdr."Posting Date";
                                        lPedPdtes."Account No." := lPurchaseLineOrder."No.";
                                        lPedPdtes."Resource No." := lPurchaseLineOrder."No.";
                                        lPedPdtes."Document No." := lSalesInvLine."Document No.";
                                        if lDTotalCant <> 0 THEN
                                            lPedPdtes.Amount := lPedPdtes.Amount + (lSalesInvLine.Amount / lDTotalCant);//Quantity/TotalCant)*lPurchaseLineOrder.Quantity;
                                        lPedPdtes."Order No." := lPurchHdrOrder."No.";

                                        lPedPdtes.Description := COPYSTR(lPurchaseLineOrder.Description, 1, 50);


                                        lPedPdtes."Amount (ACY)" := lPurchaseLineOrder."Line Amount";//"Unit Cost"*lPurchaseLineOrder.Quantity;
                                        liNumFacturas := liNumFacturas + 1;
                                        lPedPdtes."Dimension Entry No." := lPurchaseLineOrder."Line No.";
                                        lPedPdtes."Entry No." := lJobPlanningLine."Line No.";//DATE2DMY(lPedPdtes."Posting Date",3)*100+DATE2DMY(lPedPdtes."Posting Date",2);
                                        if lPedPdtes.INSERT THEN lPedPdtes.MODIFY;
                                    end;
                                END;
                            UNTIL lSalesInvLine.NEXT = 0;
                        // lo mismo para labaranes
                        if lSalesShptLine.FINDFIRST THEN
                            REPEAT
                                //key(Key1; "Posting Date", "Account Type", "Location Code", "Inventory Posting Group", "Gen. Bus. Posting Group", "Gen. Prod. Posting Group", "Dimension Set ID", Negative, "Bal. Account Type")
                                if lSalesShptHdr.GET(lSalesShptLine."Document No.") THEN BEGIN
                                    if lSalesShptHdr.Contabilizado = true Then begin
                                        if NOT lPedPdtes.GET(lSalesShptHdr."Posting Date",
                                         lPurchHdrOrder."No.", lSalesShptLine."Document No.", lPurchaseLineOrder."No.", lPurchaseLineOrder."Line No.") THEN
                                            lPedPdtes.INIT;

                                        lPedPdtes."Posting Date" := lSalesShptHdr."Posting Date";
                                        lPedPdtes."Account No." := lPurchaseLineOrder."No.";
                                        lPedPdtes."Resource No." := lPurchaseLineOrder."No.";
                                        lPedPdtes."Document No." := lSalesShptLine."Document No.";
                                        if lDTotalCant <> 0 THEN
                                            lPedPdtes.Amount := lPedPdtes.Amount + (lSalesShptLine.Amount / lDTotalCant);//Quantity/TotalCant)*lPurchaseLineOrder.Quantity;
                                        lPedPdtes."Order No." := lPurchHdrOrder."No.";

                                        lPedPdtes.Description := COPYSTR(lPurchaseLineOrder.Description, 1, 50);
                                        lPedPdtes."Amount (ACY)" := lPurchaseLineOrder."Line Amount";//"Unit Cost"*lPurchaseLineOrder.Quantity;
                                        liNumFacturas := liNumFacturas + 1;
                                        lPedPdtes."Dimension Entry No." := lPurchaseLineOrder."Line No.";
                                        lPedPdtes."Entry No." := lJobPlanningLine."Line No.";//DATE2DMY(lPedPdtes."Posting Date",3)*100+DATE2DMY(lPedPdtes."Posting Date",2);
                                        if lPedPdtes.INSERT THEN lPedPdtes.MODIFY;
                                    end;
                                END;
                            UNTIL lSalesShptLine.NEXT = 0;
                        ////
                    END ELSE BEGIN
                        liLinea := lJobPlanningLine."Line No.";
                        liLinea2 := lJobPlanningLine."Origin Line No.";
                        if lSalesLineInv.FINDFIRST THEN
                            REPEAT
                                if lSalesHdrInv.GET(lSalesLineInv."Document Type"::Invoice, lSalesLineInv."Document No.") THEN BEGIN
                                    if lSalesHdrInv."Factura prepago" = false Then begin
                                        if NOT lPedPdtes.GET(lSalesHdrInv."Posting Date", lPurchHdrOrder."No.", lSalesLineInv."Document No.", lPurchaseLineOrder."No.", lPurchaseLineOrder."Line No.") THEN
                                            lPedPdtes.INIT;

                                        lPedPdtes."Posting Date" := lSalesHdrInv."Posting Date";
                                        lPedPdtes."Account No." := lPurchaseLineOrder."No.";
                                        lPedPdtes."Resource No." := lPurchaseLineOrder."No.";
                                        lPedPdtes."Document No." := lSalesLineInv."Document No.";
                                        if lDTotalCant <> 0 THEN
                                            lPedPdtes.Amount := lPedPdtes.Amount + (lSalesLineInv."Line Amount" / lDTotalCant);//*lPurchaseLineOrder.Quantity;
                                        lPedPdtes."Order No." := lPurchHdrOrder."No.";
                                        lPedPdtes.Description := COPYSTR(lPurchaseLineOrder.Description, 1, 50);
                                        lPedPdtes."Amount (ACY)" := lPurchaseLineOrder."Line Amount";//"Unit Cost"*lPurchaseLineOrder.Quantity;
                                        liNumFacturas := liNumFacturas + 1;
                                        lPedPdtes."Dimension Entry No." := lJobPlanningLine."Line No.";
                                        lPedPdtes."Entry No." := lJobPlanningLine."Line No.";//DATE2DMY(lPedPdtes."Posting Date",3)*100+DATE2DMY(lPedPdtes."Posting Date",2);
                                        if lPedPdtes.INSERT THEN lPedPdtes.MODIFY;
                                    end;
                                END;
                            UNTIL lSalesLineInv.NEXT = 0;
                        //
                        if lSalesInvLine.FINDFIRST THEN
                            REPEAT
                                if lSalesInvHdr.GET(lSalesInvLine."Document No.") THEN BEGIN
                                    if lSalesInvHdr."Prepayment Invoice" = false Then begin
                                        if NOT lPedPdtes.GET(lSalesInvHdr."Posting Date",
                                         lPurchHdrOrder."No.", lSalesInvLine."Document No.", lPurchaseLineOrder."No.", lJobPlanningLine."Line No.") THEN
                                            lPedPdtes.INIT;

                                        lPedPdtes."Posting Date" := lSalesInvHdr."Posting Date";
                                        lPedPdtes."Account No." := lPurchaseLineOrder."No.";
                                        lPedPdtes."Resource No." := lPurchaseLineOrder."No.";
                                        lPedPdtes."Document No." := lSalesInvLine."Document No.";
                                        if lDTotalCant <> 0 THEN
                                            lPedPdtes.Amount := lPedPdtes.Amount + (lSalesInvLine.Amount / lDTotalCant);//Quantity/TotalCant)*lPurchaseLineOrder.Quantity;
                                        lPedPdtes."Order No." := lPurchHdrOrder."No.";

                                        lPedPdtes.Description := COPYSTR(lPurchaseLineOrder.Description, 1, 50);

                                        lPedPdtes."Amount (ACY)" := lPurchaseLineOrder."Line Amount";//"Unit Cost"*lPurchaseLineOrder.Quantity;
                                        liNumFacturas := liNumFacturas + 1;
                                        lPedPdtes."Dimension Entry No." := lJobPlanningLine."Line No.";
                                        lPedPdtes."Entry No." := lJobPlanningLine."Line No.";//DATE2DMY(lPedPdtes."Posting Date",3)*100+DATE2DMY(lPedPdtes."Posting Date",2);
                                        if lPedPdtes.INSERT THEN lPedPdtes.MODIFY;
                                    end;
                                END;
                            UNTIL lSalesInvLine.NEXT = 0;
                        //
                        //Lo mismo para albaranes
                        if lSalesShptLine.FINDFIRST THEN
                            REPEAT
                                if lSalesShptHdr.GET(lSalesShptLine."Document No.") THEN BEGIN
                                    if lSalesShptHdr.Contabilizado = true Then begin
                                        if NOT lPedPdtes.GET(lSalesShptHdr."Posting Date",
                                         lPurchHdrOrder."No.", lSalesShptLine."Document No.", lPurchaseLineOrder."No.", lJobPlanningLine."Line No.") THEN
                                            lPedPdtes.INIT;

                                        lPedPdtes."Posting Date" := lSalesShptHdr."Posting Date";
                                        lPedPdtes."Account No." := lPurchaseLineOrder."No.";
                                        lPedPdtes."Resource No." := lPurchaseLineOrder."No.";
                                        lPedPdtes."Document No." := lSalesShptLine."Document No.";
                                        if lDTotalCant <> 0 THEN
                                            lPedPdtes.Amount := lPedPdtes.Amount + (lSalesShptLine.Amount / lDTotalCant);//Quantity/TotalCant)*lPurchaseLineOrder.Quantity;
                                        lPedPdtes."Order No." := lPurchHdrOrder."No.";

                                        lPedPdtes.Description := COPYSTR(lPurchaseLineOrder.Description, 1, 50);

                                        lPedPdtes."Amount (ACY)" := lPurchaseLineOrder."Line Amount";//"Unit Cost"*lPurchaseLineOrder.Quantity;
                                        liNumFacturas := liNumFacturas + 1;
                                        lPedPdtes."Dimension Entry No." := lJobPlanningLine."Line No.";
                                        lPedPdtes."Entry No." := lJobPlanningLine."Line No.";//DATE2DMY(lPedPdtes."Posting Date",3)*100+DATE2DMY(lPedPdtes."Posting Date",2);
                                        if lPedPdtes.INSERT THEN lPedPdtes.MODIFY;
                                    end;
                                END;
                            UNTIL lSalesShptLine.NEXT = 0;
                    END;
                UNTIL lPurchaseLineOrder.NEXT = 0;
        END;
        /*      {if lPedPdtes.FINDFIRST THEN REPEAT

             UNTIL lPedPdtes.NEXT=0;}
        */
        COMMIT;
        CLEAR(lpPedidos);
        lpPedidos.SETTABLEVIEW(lPedPdtes);
        if lPedPdtes.FINDFIRST THEN
            lpPedidos.RUNMODAL;
    END;

    /// <summary>
    /// ContabilizarAlbaranes.
    /// </summary>
    /// <param name="pPurcRcptHdr">VAR Record "Purch. Rcpt. Header".</param>
    procedure ContabilizarAlbaranes(var pPurcRcptHdr: Record "Purch. Rcpt. Header")
    var
        lCGenJnlLineDocNo: Code[20];
        ltGenJnlLineExtDocNo: Text[30];
        lDTotal: Decimal;
        lDTotalACY: Decimal;
        lPurchRcptLineTMP: Record "Purch. Rcpt. Line" temporary;
        lPurchArchiveLine: Record "Purchase Line Archive";
        liLinecount: Integer;
        lVendor: Record Vendor;
        lVendorPostingGroup: Record "Vendor Posting Group";
        lPurchReceipLine: Record "Purch. Rcpt. Line";
        TempBuffer: Record "Invoice Posting Buffer" temporary;
        TempBuffer2: Record "Invoice Posting Buffer" temporary;
        FaLineNo: Integer;
    begin

        //  WITH pPurcRcptHdr DO BEGIN
        gGenLedgerSetup.Get();
        if gPurchHeader.GET(gPurchHeader."Document Type"::Order, pPurcRcptHdr."Order No.") THEN;
        //if Comprobar(gPurchHeader) THEN EXIT; //TSS
        if pPurcRcptHdr.Contabilizado THEN ERROR(glNoDebeContabilizado);
        lCGenJnlLineDocNo := pPurcRcptHdr."No.";
        ltGenJnlLineExtDocNo := pPurcRcptHdr."Vendor Shipment No.";
        lDTotal := 0;
        lDTotalACY := 0;
        lPurchRcptLineTMP.SETRANGE(lPurchRcptLineTMP."Document No.", pPurcRcptHdr."No.");
        DesglosarAlbaranes(pPurcRcptHdr, lPurchRcptLineTMP);
        if lPurchRcptLineTMP.FINDFIRST THEN
            REPEAT

                if (lPurchRcptLineTMP.Type.AsInteger() >= lPurchRcptLineTMP.Type::"G/L Account".AsInteger()) AND (lPurchRcptLineTMP."Qty. Rcd. Not Invoiced" <> 0) THEN BEGIN
                    // Copy purchase to Buffer
                    //PurchLineACY.GET(lPurchRcptLineTMP."Document No.",lPurchRcptLineTMP."Line No.");
                    /* DocDim.SETRANGE(DocDim."Table ID",DATABASE::"Purchase Line Archive");
                    DocDim.SETRANGE(DocDim."Document Type",DocDim."Document Type"::Order);
                    DocDim.SETRANGE(DocDim."Document No.",lPurchRcptLineTMP."Document No.");
                    DocDim.SETRANGE(DocDim."Line No.",lPurchRcptLineTMP."Line No.");
                    if DocDim.FINDFIRST THEN REPEAT
                    TempDocDim.TransferFields(DocDim);
                    if TempDocDim.INSERT THEN;
                    UNTIL DocDim.NEXT=0; */
                    if lPurchRcptLineTMP.Type = lPurchRcptLineTMP.Type::"G/L Account" Then begin
                        lPurchReceipLine.SetRange("Document No.", lPurchRcptLineTMP."Document No.");
                        lPurchReceipLine.SetRange("Line No.", lPurchRcptLineTMP."Line No.");
                        if lPurchArchiveLine.FINDFIRST() then begin
                            if lPurchReceipLine."Shortcut Dimension 1 Code" <> '' Then
                                lPurchRcptLineTMP.Validate("Shortcut Dimension 1 Code", lPurchReceipLine."Shortcut Dimension 1 Code");
                            if lPurchReceipLine."Shortcut Dimension 2 Code" <> '' Then
                                lPurchRcptLineTMP.Validate("Shortcut Dimension 2 Code", lPurchReceipLine."Shortcut Dimension 2 Code");
                            if lPurchReceipLine."Shortcut Dimension 3 Code" <> '' Then
                                lPurchRcptLineTMP.Validate("Shortcut Dimension 3 Code", lPurchReceipLine."Shortcut Dimension 3 Code");
                            if lPurchReceipLine."Shortcut Dimension 4 Code" <> '' Then
                                lPurchRcptLineTMP.Validate("Shortcut Dimension 4 Code", lPurchReceipLine."Shortcut Dimension 4 Code");
                            if lPurchReceipLine."Shortcut Dimension 5 Code" <> '' Then
                                lPurchRcptLineTMP.Validate("Shortcut Dimension 5 Code", lPurchReceipLine."Shortcut Dimension 5 Code");
                            lPurchRcptLineTMP."Dimension Set ID" := lPurchReceipLine."Dimension Set ID";
                            lPurchRcptLineTMP.Modify();
                        end;
                    end else begin
                        lPurchArchiveLine.SetRange("Document Type", lPurchArchiveLine."Document Type"::Order);
                        lPurchArchiveLine.SetRange("Document No.", lPurchRcptLineTMP."Document No.");
                        lPurchArchiveLine.SetRange("Line No.", lPurchRcptLineTMP."Line No.");
                        if lPurchArchiveLine.FINDFIRST() then begin

                            lPurchRcptLineTMP.Validate("Shortcut Dimension 1 Code", lPurchArchiveLine."Shortcut Dimension 1 Code");
                            lPurchRcptLineTMP.Validate("Shortcut Dimension 2 Code", lPurchArchiveLine."Shortcut Dimension 2 Code");
                            lPurchRcptLineTMP.Validate("Shortcut Dimension 3 Code", lPurchArchiveLine."Shortcut Dimension 3 Code");
                            lPurchRcptLineTMP.Validate("Shortcut Dimension 4 Code", lPurchArchiveLine."Shortcut Dimension 4 Code");
                            lPurchRcptLineTMP.Validate("Shortcut Dimension 5 Code", lPurchArchiveLine."Shortcut Dimension 5 Code");
                            lPurchRcptLineTMP."Dimension Set ID" := lPurchArchiveLine."Dimension Set ID";
                            lPurchRcptLineTMP.Modify();
                        end;
                    end;
                    FillAlbPostingBuffer(lPurchRcptLineTMP, lPurchRcptLineTMP."Line No.", TempBuffer);
                    UpdInvPostingBuldFFeProduccionesgloNew(TempBuffer, FALineNo, TempBuffer2);
                    /* TempDocDim.SETRANGE("Table ID");
                    TempDocDim.SETRANGE("Line No."); */
                END;
            UNTIL lPurchRcptLineTMP.NEXT = 0;
        // Post purchase and VAT to G/L entries from Buffer
        liLinecount := 0;
        TempBuffer2.RESET;
        if TempBuffer2.FIND('+') THEN
            REPEAT
                liLinecount := liLinecount + 1;
                //if GUIALLOWED THEN
                //Window.UPDATE(3,liLinecount);

                CASE TempBuffer2."VAT Calculation Type" OF
                    TempBuffer2."VAT Calculation Type"::"Reverse Charge VAT":
                        BEGIN
                            gVATPostingSetup.GET(
                              TempBuffer2."VAT Bus. Posting Group", TempBuffer2."VAT Prod. Posting Group");
                            TempBuffer2."VAT Amount" :=
                              ROUND(
                                (TempBuffer2.Amount -

                                TempBuffer2."Line Discount Amount" -

                                TempBuffer2."Inv. Discount Amount" -
                                TempBuffer2."Pmt. Discount Amount") *
                                gVATPostingSetup."VAT+EC %" / 100);
                            TempBuffer2."VAT Amount (ACY)" :=
                              ROUND(
                                (TempBuffer2."Amount (ACY)" -
                                TempBuffer2."Line Discount Amt. (ACY)" -
                                TempBuffer2."Inv. Discount Amt. (ACY)" -
                                TempBuffer2."Src. Curr. Pmt. Discount Amt.") *
                                gVATPostingSetup."VAT+EC %" / 100, gCurrency."Amount Rounding Precision");
                        END;
                    TempBuffer2."VAT Calculation Type"::"Sales Tax":
                        BEGIN
                            if TempBuffer2."Use Tax" THEN BEGIN
                                TempBuffer2."VAT Amount" :=
                                  ROUND(
                                    gcSalesTaxCalculate.CalculateTax(
                                      TempBuffer2."Tax Area Code", TempBuffer2."Tax Group Code",
                                      TempBuffer2."Tax Liable", gPurchHeader."Posting Date",
                                      TempBuffer2.Amount -
                                      TempBuffer2."Line Discount Amount" - TempBuffer2."Inv. Discount Amount" -
                                      TempBuffer2."Pmt. Discount Amount",
                                      TempBuffer2.Quantity, 0));
                                if gGenLedgerSetup."Additional Reporting Currency" <> '' THEN
                                    TempBuffer2."VAT Amount (ACY)" :=
                                      gCurrExchRate.ExchangeAmtLCYToFCY(
                                        gPurchHeader."Posting Date", gGenLedgerSetup."Additional Reporting Currency",
                                        TempBuffer2."VAT Amount", 0);
                            END;
                        END;
                END;

                if gPurchHeader."Prices Including VAT" AND (TempBuffer2."VAT %" <> 0) THEN
                    // WITH TempBuffer2 DO BEGIN
                    gDDiscountVATAmount :=
                              ROUND(TempBuffer2."Line Discount Amount" * TempBuffer2."VAT %" / (1 + TempBuffer2."VAT %" / 100) / 100);
                TempBuffer2.Amount := TempBuffer2.Amount - gDDiscountVATAmount;
                TempBuffer2."Line Discount Amount" := TempBuffer2."Line Discount Amount" - gDDiscountVATAmount;

                gDDiscountVATAmount :=
                  ROUND(
                    TempBuffer2."Line Discount Amt. (ACY)" * TempBuffer2."VAT %" / (1 + TempBuffer2."VAT %" / 100) / 100,
                    gCurrency."Amount Rounding Precision");
                TempBuffer2."Amount (ACY)" := TempBuffer2."Amount (ACY)" - gDDiscountVATAmount;
                TempBuffer2."Line Discount Amt. (ACY)" := TempBuffer2."Line Discount Amt. (ACY)" - gDDiscountVATAmount;

                gDDiscountVATAmount :=
                  ROUND(TempBuffer2."Inv. Discount Amount" * TempBuffer2."VAT %" / (1 + TempBuffer2."VAT %" / 100) / 100);
                TempBuffer2.Amount := TempBuffer2.Amount - gDDiscountVATAmount;
                TempBuffer2."Inv. Discount Amount" := TempBuffer2."Inv. Discount Amount" - gDDiscountVATAmount;

                gDDiscountVATAmount :=
                  ROUND(
                    TempBuffer2."Src. Curr. Pmt. Discount Amt." * TempBuffer2."VAT %" / (1 + TempBuffer2."VAT %" / 100) / 100,
                    gCurrency."Amount Rounding Precision");
                TempBuffer2."Amount (ACY)" := TempBuffer2."Amount (ACY)" - gDDiscountVATAmount;
                TempBuffer2."Inv. Discount Amt. (ACY)" := TempBuffer2."Inv. Discount Amt. (ACY)" - gDDiscountVATAmount;

                gDDiscountVATAmount :=
                  ROUND(
                    TempBuffer2."Inv. Discount Amt. (ACY)" * TempBuffer2."VAT %" / (1 + TempBuffer2."VAT %" / 100) / 100,
                    gCurrency."Amount Rounding Precision");
                TempBuffer2."Amount (ACY)" := TempBuffer2."Amount (ACY)" - gDDiscountVATAmount;
                TempBuffer2."Inv. Discount Amt. (ACY)" := TempBuffer2."Inv. Discount Amt. (ACY)" - gDDiscountVATAmount;
                // END;

                gGenJnlLine.INIT;
                gGenJnlLine."Posting Date" := pPurcRcptHdr."Posting Date";
                gGenJnlLine."Document Date" := pPurcRcptHdr."Document Date";
                gGenJnlLine.Description := COPYSTR(pPurcRcptHdr."Posting Description", 1, MAXSTRLEN(gGenJnlLine.Description));
                //gGenJnlLine.Description := "Posting Description";
                gGenJnlLine."Reason Code" := pPurcRcptHdr."Reason Code";
                gGenJnlLine."Document Type" := gGenJnlLine."Document Type"::Receipt;
                gGenJnlLine."Document No." := pPurcRcptHdr."No.";
                gGenJnlLine."Tax Area Code" := pPurcRcptHdr."No.";
                gGenJnlLine."External Document No." := pPurcRcptHdr."Vendor Shipment No.";
                gGenJnlLine."Account No." := TempBuffer2."G/L Account";
                gGenJnlLine."System-Created Entry" := TempBuffer2."System-Created Entry";
                gGenJnlLine.Amount := TempBuffer2.Amount;
                lDTotal := lDTotal + TempBuffer2.Amount;
                gGenJnlLine."Source Currency Code" := pPurcRcptHdr."Currency Code";
                gGenJnlLine."Source Currency Amount" := TempBuffer2."Amount (ACY)";
                lDTotalACY := lDTotalACY + TempBuffer2."Amount (ACY)";
                gGenJnlLine.Correction := pPurcRcptHdr.Correction;
                gGenJnlLine."Gen. Posting Type" := gGenJnlLine."Gen. Posting Type"::" ";
                gGenJnlLine."Gen. Bus. Posting Group" := '';//TempBuffer2."Gen. Bus. Posting Group";
                gGenJnlLine."Gen. Prod. Posting Group" := '';// TempBuffer2."Gen. Prod. Posting Group";
                gGenJnlLine."VAT Bus. Posting Group" := '';//TempBuffer2."VAT Bus. Posting Group";
                gGenJnlLine."VAT Prod. Posting Group" := '';//TempBuffer2."VAT Prod. Posting Group";
                gGenJnlLine."Tax Area Code" := TempBuffer2."Tax Area Code";
                gGenJnlLine."Tax Liable" := TempBuffer2."Tax Liable";
                gGenJnlLine."Tax Group Code" := TempBuffer2."Tax Group Code";
                gGenJnlLine."Use Tax" := TempBuffer2."Use Tax";
                gGenJnlLine.Quantity := TempBuffer2.Quantity;
                gGenJnlLine."VAT Calculation Type" := TempBuffer2."VAT Calculation Type";
                gGenJnlLine."VAT Base Amount" := TempBuffer2."VAT Base Amount";
                gGenJnlLine."VAT Base Discount %" := pPurcRcptHdr."VAT Base Discount %";
                gGenJnlLine."Source Curr. VAT Base Amount" := TempBuffer2."VAT Base Amount (ACY)";
                gGenJnlLine."VAT Amount" := TempBuffer2."VAT Amount";
                gGenJnlLine."Source Curr. VAT Amount" := TempBuffer2."VAT Amount (ACY)";
                gGenJnlLine."VAT Difference" := TempBuffer2."VAT Difference";
                gGenJnlLine."VAT Posting" := gGenJnlLine."VAT Posting"::"Manual VAT Entry";
                gGenJnlLine."Shortcut Dimension 1 Code" := TempBuffer2."Global Dimension 1 Code";
                gGenJnlLine."Shortcut Dimension 2 Code" := TempBuffer2."Global Dimension 2 Code";
                //ASC
                gGenJnlLine."Shortcut Dimension 3 Code" := TempBuffer2."Global Dimension 3 Code";
                gGenJnlLine."Shortcut Dimension 4 Code" := TempBuffer2."Global Dimension 4 Code";
                gGenJnlLine."Shortcut Dimension 5 Code" := TempBuffer2."Global Dimension 5 Code";
                gGenJnlLine."Dimension Set ID" := TempBuffer2."Dimension Set ID";
                gGenJnlLine.Circuito := TRUE;
                gGenJnlLine."Job No." := TempBuffer2."Job No.";
                gGenJnlLine."Source Code" := gCSrcCode;
                gGenJnlLine."Sell-to/Buy-from No." := pPurcRcptHdr."Buy-from Vendor No.";
                gGenJnlLine."Bill-to/Pay-to No." := pPurcRcptHdr."Pay-to Vendor No.";
                gGenJnlLine."Country/Region Code" := pPurcRcptHdr."VAT Country/Region Code";
                gGenJnlLine."VAT Registration No." := pPurcRcptHdr."VAT Registration No.";
                gGenJnlLine."Source Type" := gGenJnlLine."Source Type"::Vendor;
                gGenJnlLine."Source No." := pPurcRcptHdr."Pay-to Vendor No.";
                gGenJnlLine."Posting No. Series" := '';
                gGenJnlLine."IC Partner Code" := '';//"Pay-to IC Partner Code";
                gGenJnlLine."Ship-to/Order Address Code" := pPurcRcptHdr."Order Address Code";

                gGenJnlLine."Payment Terms Code" := pPurcRcptHdr."Payment Terms Code";
                gGenJnlLine."Payment Method Code" := pPurcRcptHdr."Payment Method Code";

                gGenJnlLine."Generate AutoInvoices" := FALSE;//"Generate Autoinvoices" OR "Generate Autocredit Memo";
                gGenJnlLine."AutoDoc. No." := '';

                if TempBuffer2.Type = TempBuffer2.Type::"Fixed Asset" THEN BEGIN
                    gGenJnlLine."Account Type" := gGenJnlLine."Account Type"::"Fixed Asset";
                    if TempBuffer2."FA Posting Type" =
                      TempBuffer2."FA Posting Type"::"Acquisition Cost"
                    THEN
                        gGenJnlLine."FA Posting Type" := gGenJnlLine."FA Posting Type"::"Acquisition Cost";
                    if TempBuffer2."FA Posting Type" =
                      TempBuffer2."FA Posting Type"::Maintenance
                    THEN
                        gGenJnlLine."FA Posting Type" := gGenJnlLine."FA Posting Type"::Maintenance;
                    gGenJnlLine."FA Posting Date" := TempBuffer2."FA Posting Date";
                    gGenJnlLine."Depreciation Book Code" := TempBuffer2."Depreciation Book Code";
                    gGenJnlLine."Salvage Value" := TempBuffer2."Salvage Value";
                    gGenJnlLine."Depr. until FA Posting Date" := TempBuffer2."Depr. until FA Posting Date";
                    gGenJnlLine."Depr. Acquisition Cost" := TempBuffer2."Depr. Acquisition Cost";
                    gGenJnlLine."Maintenance Code" := TempBuffer2."Maintenance Code";
                    gGenJnlLine."Insurance No." := TempBuffer2."Insurance No.";
                    gGenJnlLine."Budgeted FA No." := TempBuffer2."Budgeted FA No.";
                    gGenJnlLine."Duplicate in Depreciation Book" := TempBuffer2."Duplicate in Depreciation Book";
                    gGenJnlLine."Use Duplication List" := TempBuffer2."Use Duplication List";
                END;

                RungcGenJnlPostLine(gGenJnlLine);//,TempBuffer2."Dimension Entry No.");
                                                 /* if FAInsertDiscountAmount(TempBuffer2,DeprBook) THEN
                                                   FAPostDiscountAmount(
                                                     gGenJnlLine,
                                                     TempBuffer2."Line Discount Amount" + TempBuffer2."Inv. Discount Amount",
                                                     TempBuffer2."Line Discount Amt. (ACY)" + TempBuffer2."Inv. Discount Amt. (ACY)",
                                                     TempBuffer2."Dimension Entry No."); */
                gGenJnlLine."Account Type" := gGenJnlLine."Account Type"::"G/L Account";
                gGenJnlLine.VALIDATE("FA Posting Type", gGenJnlLine."FA Posting Type"::" ");
                /* if FAInsertDiscountAmount(TempBuffer2,DeprBook) THEN
                  PostDiscount(
                    TempBuffer2."FA Discount Account",
                    -(TempBuffer2."Line Discount Amount" + TempBuffer2."Inv. Discount Amount"),
                    -(TempBuffer2."Line Discount Amt. (ACY)" + TempBuffer2."Inv. Discount Amt. (ACY)"),
                    TempBuffer2."Dimension Entry No."); */
                if (TempBuffer2."Line Discount Amount" <> 0) OR
                  (TempBuffer2."Line Discount Amt. (ACY)" <> 0)
                THEN
                    PostDiscount(
                      TempBuffer2."Line Discount Account",
                      TempBuffer2."Line Discount Amount",
                      TempBuffer2."Line Discount Amt. (ACY)",
                      TempBuffer2."Dimension Entry No.", gPurchHeader);
                if (TempBuffer2."Inv. Discount Amount" <> 0) OR
                  (TempBuffer2."Inv. Discount Amt. (ACY)" <> 0)
                THEN
                    PostDiscount(
                      TempBuffer2."Inv. Discount Account",
                      TempBuffer2."Inv. Discount Amount",
                      TempBuffer2."Inv. Discount Amt. (ACY)",
                      TempBuffer2."Dimension Entry No.", gPurchHeader);
                if TempBuffer2."Pmt. Discount Amount" <> 0 THEN
                    PostDiscount(
                      TempBuffer2."Pmt. Discount Account",
                      TempBuffer2."Pmt. Discount Amount",
                      TempBuffer2."Src. Curr. Pmt. Discount Amt.",
                      TempBuffer2."Dimension Entry No.", gPurchHeader);
            UNTIL TempBuffer2.Next(-1) = 0;

        TempBuffer2.DELETEALL;

        // Check External Document number
        // Post vendor entries
        //if GUIALLOWED THEN
        //Window.UPDATE(4,1);
        gGenJnlLine.INIT;
        gGenJnlLine."Posting Date" := pPurcRcptHdr."Posting Date";
        gGenJnlLine."Document Date" := pPurcRcptHdr."Document Date";
        gGenJnlLine.Description := COPYSTR(pPurcRcptHdr."Posting Description", 1, MAXSTRLEN(gGenJnlLine.Description));
        gGenJnlLine."Shortcut Dimension 1 Code" := pPurcRcptHdr."Shortcut Dimension 1 Code";
        gGenJnlLine."Shortcut Dimension 2 Code" := pPurcRcptHdr."Shortcut Dimension 2 Code";
        //ASC
        gGenJnlLine."Shortcut Dimension 3 Code" := pPurcRcptHdr."Shortcut Dimension 3 Code";
        gGenJnlLine."Shortcut Dimension 4 Code" := pPurcRcptHdr."Shortcut Dimension 4 Code";
        gGenJnlLine."Shortcut Dimension 5 Code" := pPurcRcptHdr."Shortcut Dimension 5 Code";
        gGenJnlLine."Dimension Set ID" := pPurcRcptHdr."Dimension Set ID";
        gGenJnlLine.Circuito := TRUE;
        gGenJnlLine."Reason Code" := pPurcRcptHdr."Reason Code";
        gGenJnlLine."Account Type" := gGenJnlLine."Account Type"::"G/L Account";
        lVendor.GET(pPurcRcptHdr."Pay-to Vendor No.");
        lVendorPostingGroup.GET(lVendor."Vendor Posting Group");
        gGenJnlLine."Account No." := lVendorPostingGroup.FPR;
        gGenJnlLine."Tax Area Code" := lCGenJnlLineDocNo;
        gGenJnlLine."Document Type" := gGenJnlLine."Document Type"::Receipt;
        gGenJnlLine."Document No." := lCGenJnlLineDocNo;
        gGenJnlLine."External Document No." := lTGenJnlLineExtDocNo;
        gGenJnlLine."Currency Code" := pPurcRcptHdr."Currency Code";
        gGenJnlLine.Amount := -lDTotal;
        gGenJnlLine."Source Currency Code" := pPurcRcptHdr."Currency Code";
        gGenJnlLine."Source Currency Amount" := -lDTotal;
        gGenJnlLine."Amount (LCY)" := -lDTotalACY;
        if gPurchHeader."Currency Code" = '' THEN
            gGenJnlLine."Currency Factor" := 1
        ELSE
            gGenJnlLine."Currency Factor" := gPurchHeader."Currency Factor";
        gGenJnlLine."Sales/Purch. (LCY)" := -lDTotalACY;
        gGenJnlLine.Correction := pPurcRcptHdr.Correction;
        gGenJnlLine."Inv. Discount (LCY)" := -gTotalPurchaseLineLCY."Inv. Discount Amount";
        gGenJnlLine."Pmt. Discount Given/Rec. (LCY)" := 0;// -gTotalPurchaseLineLCY."Pmt. Discount Amount";
        gGenJnlLine."Sell-to/Buy-from No." := pPurcRcptHdr."Buy-from Vendor No.";
        gGenJnlLine."Bill-to/Pay-to No." := pPurcRcptHdr."Pay-to Vendor No.";
        gGenJnlLine."Salespers./Purch. Code" := pPurcRcptHdr."Purchaser Code";
        gGenJnlLine."System-Created Entry" := TRUE;
        gGenJnlLine."On Hold" := pPurcRcptHdr."On Hold";
        gGenJnlLine."Applies-to Doc. Type" := pPurcRcptHdr."Applies-to Doc. Type";
        gGenJnlLine."Applies-to Bill No." := pPurcRcptHdr."Applies-to Bill No.";
        gGenJnlLine."Applies-to Doc. No." := pPurcRcptHdr."Applies-to Doc. No.";
        gGenJnlLine."Applies-to ID" := '';
        gGenJnlLine."Allow Application" := pPurcRcptHdr."Bal. Account No." = '';
        gGenJnlLine."Payment Terms Code" := pPurcRcptHdr."Payment Terms Code";
        gGenJnlLine."Payment Method Code" := pPurcRcptHdr."Payment Method Code";
#if not CLEAN22
        // TODO: - CLEAN22
#if not CLEAN27
        gGenJnlLine."Pmt. Address Code" := pPurcRcptHdr."Pay-at Code";
#endif
        // TODO: - CLEAN22
#endif
        gGenJnlLine."Recipient Bank Account" := pPurcRcptHdr."Vendor Bank Acc. Code";
        gGenJnlLine."Due Date" := pPurcRcptHdr."Due Date";
        //gGenJnlLine."Pmt. Discount Date" := "Pmt. Discount Date";
        gGenJnlLine."Payment Discount %" := pPurcRcptHdr."Payment Discount %";
        gGenJnlLine."Source Type" := gGenJnlLine."Source Type"::Vendor;
        gGenJnlLine."Source No." := pPurcRcptHdr."Pay-to Vendor No.";
        gGenJnlLine."Source Code" := gCSrcCode;
        gGenJnlLine."Posting No. Series" := '';
        gGenJnlLine."IC Partner Code" := '';//"Pay-to IC Partner Code";
        gGenJnlLine."Generate AutoInvoices" := FALSE;//"Generate Autoinvoices" OR "Generate Autocredit Memo";
        gGenJnlLine."AutoDoc. No." := '';

        /* TempJnlLineDim.DELETEALL;
        TempDocDim.RESET;
        TempDocDim.SETRANGE("Table ID",DATABASE::"Purchase Line Archive");
        lcDimMgt.CopyDocDimToJnlLineDim(TempDocDim,TempJnlLineDim); */
        gcGenJnlPostLine.RunWithCheck(gGenJnlLine);//,TempJnlLineDim);

        //  END;
        MESSAGE('Se ha contabilizado el albarán %1 con fecha %2', pPurcRcptHdr."No.",
          FORMAT(pPurcRcptHdr."Posting Date", 0, '<Day,2>/<Month,2>/<Year>'));
        pPurcRcptHdr.Contabilizado := TRUE;
        pPurcRcptHdr.Facturado := FALSE;
        pPurcRcptHdr.MODIFY;
    end;

    /// <summary>
    /// PostDiscount.
    /// </summary>
    /// <param name="GLAccNo">Code[20].</param>
    /// <param name="DiscountAmount">Decimal.</param>
    /// <param name="SrcCurrDiscountAmount">Decimal.</param>
    /// <param name="DimEntryNo">Integer.</param>
    /// <param name="PurchHeader">VAR Record "Purchase Header".</param>
    procedure PostDiscount(pCGLAccNo: Code[20]; pDDiscountAmount: Decimal; pDSrcCurrDiscountAmount: Decimal; piDimEntryNo: Integer; var pPurchHeader: Record "Purchase Header")
    VAR
        //TempJnlLineDim:  Record 356 TEMPORARY;
        lDimBufTMP: Record "Dimension Buffer" TEMPORARY;
    BEGIN
        // WITH gGenJnlLine DO BEGIN
        gGenJnlLine."Gen. Posting Type" := gGenJnlLine."Gen. Posting Type"::" "; // None
        gGenJnlLine."Gen. Bus. Posting Group" := '';
        gGenJnlLine."Gen. Prod. Posting Group" := '';
        gGenJnlLine."VAT Bus. Posting Group" := '';
        gGenJnlLine."VAT Prod. Posting Group" := '';
        gGenJnlLine."VAT Calculation Type" := gGenJnlLine."VAT Calculation Type"::"Normal VAT";
        gGenJnlLine."Bill-to/Pay-to No." := '';
        gGenJnlLine."VAT Amount" := 0;
        If pCGlAccNo = '' Then pCGLACCNo := '600000001';
        gGenJnlLine."Account No." := pCGLAccNo;
        gGenJnlLine.Amount := -pDDiscountAmount;
        gGenJnlLine."Amount (LCY)" := 0;
        gGenJnlLine."Depreciation Book Code" := '';
        gGenJnlLine."Source Currency Code" := pPurchHeader."Currency Code";
        gGenJnlLine."Source Currency Amount" := -pDSrcCurrDiscountAmount;
        gGenJnlLine."Source Curr. VAT Amount" := 0;
        gGenJnlLine."System-Created Entry" := TRUE;

        lDimBufTMP.DELETEALL;


        gcGenJnlPostLine.RunWithCheck(gGenJnlLine);
        // END;
    END;


    PROCEDURE ContabilizarDevoluciones(var pReturnShptHdr: Record "Return Shipment Header")
    VAR
        lReturnShntLine: Record "Return Shipment Line";
        lReturnShntACY: Record "Return Shipment Line";
        lVendor: Record Vendor;
        lDDiscountVATAmount: Decimal;
        lVendorPostingGroup: Record "Vendor Posting Group";
        lDTotal: Decimal;
        lDTotalACY: Decimal;
        lCGenJnlLineDocNo: Code[20];
        ltGenJnlLineExtDocNo: Text[30];
        lPurchaseLine: Record "Purchase Line";
        liLinecount: Integer;
        TempBuffer: Record "Invoice Posting Buffer" temporary;
        TempBuffer2: Record "Invoice Posting Buffer" temporary;
        FaLineNo: Integer;
    BEGIN
        //WITH pReturnShptHdr DO BEGIN
        if not gPurchHeader.Get(gPurchHeader."Document Type"::"Return Order", pReturnShptHdr."Return Order No.") Then gPurchHeader.Init();
        if pReturnShptHdr.Contabilizado THEN ERROR(glnoDebeContabilizado);
        lCGenJnlLineDocNo := pReturnShptHdr."No.";
        ltGenJnlLineExtDocNo := pReturnShptHdr."Vendor Authorization No.";
        lDTotal := 0;
        lDTotalACY := 0;
        lReturnShntLine.SETRANGE(lReturnShntLine."Document No.", pReturnShptHdr."No.");
        if lReturnShntLine.FINDFIRST THEN
            REPEAT
                if (lReturnShntLine.Type.AsInteger() >= lReturnShntLine.Type::"G/L Account".AsInteger()) AND (lReturnShntLine."Return Qty. Shipped Not Invd." <> 0) THEN BEGIN
                    // Copy purchase to Buffer
                    lReturnShntACY.GET(lReturnShntLine."Document No.", lReturnShntLine."Line No.");
                    /* DocDim.SETRANGE(DocDim."Table ID","Purchase Line");
                    DocDim.SETRANGE(DocDim."Document Type",DocDim."Document Type"::"Return Order");
                    DocDim.SETRANGE(DocDim."Document No.",lReturnShntLine."Return Order No.");
                    DocDim.SETRANGE(DocDim."Line No.",lReturnShntLine."Return Order Line No.");
                    if DocDim.FINDFIRST THEN REPEAT
                     TempDocDim:=DocDim;
                     if TempDocDim.INSERT THEN;
                    UNTIL DocDim.NEXT=0; */
                    lPurchaseLine.SetRange("Document Type", lPurchaseLine."Document Type"::"Return Order");
                    lPurchaseLine.SetRange("Document No.", lReturnShntLine."Return Order No.");
                    lPurchaseLine.SetRange("Line No.", lReturnShntLine."Return Order Line No.");
                    if lPurchaseLine.FINDFIRST() then begin
                        lReturnShntLine.Validate("Shortcut Dimension 1 Code", lPurchaseLine."Shortcut Dimension 1 Code");
                        lReturnShntLine.Validate("Shortcut Dimension 2 Code", lPurchaseLine."Shortcut Dimension 2 Code");
                        lReturnShntLine.Validate("Shortcut Dimension 3 Code", lPurchaseLine."Shortcut Dimension 3 Code");
                        lReturnShntLine.Validate("Shortcut Dimension 4 Code", lPurchaseLine."Shortcut Dimension 4 Code");
                        lReturnShntLine.Validate("Shortcut Dimension 5 Code", lPurchaseLine."Shortcut Dimension 5 Code");
                        lReturnShntLine."Dimension Set ID" := lPurchaseLine."Dimension Set ID";
                        lReturnShntLine.Modify();
                    end;

                    FillDevPostingBuffer(lReturnShntLine, lReturnShntACY, lReturnShntLine."Return Order Line No.", TempBuffer);
                    UpdInvPostingBuldFFeProduccionesgloNew(TempBuffer, FALineNo, TempBuffer2);
                    /* TempDocDim.SETRANGE("Table ID");
                    TempDocDim.SETRANGE("Line No."); */
                END;
            UNTIL lReturnShntLine.NEXT = 0;
        // Post purchase and VAT to G/L entries from Buffer
        liLinecount := 0;
        TempBuffer2.RESET;
        if TempBuffer2.FIND('+') THEN
            REPEAT
                liLinecount := liLinecount + 1;
                //if GUIALLOWED THEN
                //Window.UPDATE(3,liLinecount);

                CASE TempBuffer2."VAT Calculation Type" OF
                    TempBuffer2."VAT Calculation Type"::"Reverse Charge VAT":
                        BEGIN
                            gVATPostingSetup.GET(
                              TempBuffer2."VAT Bus. Posting Group", TempBuffer2."VAT Prod. Posting Group");
                            TempBuffer2."VAT Amount" :=
                              ROUND(
                                (TempBuffer2.Amount -
                                TempBuffer2."Line Discount Amount" -
                                TempBuffer2."Inv. Discount Amount" -
                                TempBuffer2."Pmt. Discount Amount") *
                                gVATPostingSetup."VAT+EC %" / 100);
                            TempBuffer2."VAT Amount (ACY)" :=
                              ROUND(
                                (TempBuffer2."Amount (ACY)" -
                                TempBuffer2."Line Discount Amt. (ACY)" -
                                TempBuffer2."Inv. Discount Amt. (ACY)" -
                                TempBuffer2."Src. Curr. Pmt. Discount Amt.") *
                                gVATPostingSetup."VAT+EC %" / 100, gCurrency."Amount Rounding Precision");
                        END;
                    TempBuffer2."VAT Calculation Type"::"Sales Tax":
                        BEGIN
                            if TempBuffer2."Use Tax" THEN BEGIN
                                TempBuffer2."VAT Amount" :=
                                  ROUND(
                                    gcSalesTaxCalculate.CalculateTax(
                                      TempBuffer2."Tax Area Code", TempBuffer2."Tax Group Code",
                                      TempBuffer2."Tax Liable", gPurchHeader."Posting Date",
                                      TempBuffer2.Amount -
                                      TempBuffer2."Line Discount Amount" - TempBuffer2."Inv. Discount Amount" -
                                       TempBuffer2."Pmt. Discount Amount",
                                      TempBuffer2.Quantity, 0));
                                if gGenLedgerSetup."Additional Reporting Currency" <> '' THEN
                                    TempBuffer2."VAT Amount (ACY)" :=
                                      gCurrExchRate.ExchangeAmtLCYToFCY(
                                        gPurchHeader."Posting Date", gGenLedgerSetup."Additional Reporting Currency",
                                        TempBuffer2."VAT Amount", 0);
                            END;
                        END;
                END;

                if gPurchHeader."Prices Including VAT" AND (TempBuffer2."VAT %" <> 0) THEN
                    // WITH TempBuffer2 DO BEGIN
                    lDDiscountVATAmount :=
                              ROUND(TempBuffer2."Line Discount Amount" * TempBuffer2."VAT %" / (1 + TempBuffer2."VAT %" / 100) / 100);
                TempBuffer2.Amount := TempBuffer2.Amount - lDDiscountVATAmount;
                TempBuffer2."Line Discount Amount" := TempBuffer2."Line Discount Amount" - lDDiscountVATAmount;

                lDDiscountVATAmount :=
                  ROUND(
                    TempBuffer2."Line Discount Amt. (ACY)" * TempBuffer2."VAT %" / (1 + TempBuffer2."VAT %" / 100) / 100,
                    gCurrency."Amount Rounding Precision");
                TempBuffer2."Amount (ACY)" := TempBuffer2."Amount (ACY)" - lDDiscountVATAmount;
                TempBuffer2."Line Discount Amt. (ACY)" := TempBuffer2."Line Discount Amt. (ACY)" - lDDiscountVATAmount;

                lDDiscountVATAmount :=
                  ROUND(TempBuffer2."Inv. Discount Amount" * TempBuffer2."VAT %" / (1 + TempBuffer2."VAT %" / 100) / 100);
                TempBuffer2.Amount := TempBuffer2.Amount - lDDiscountVATAmount;
                TempBuffer2."Inv. Discount Amount" := TempBuffer2."Inv. Discount Amount" - lDDiscountVATAmount;

                lDDiscountVATAmount :=
                  ROUND(
                    TempBuffer2."Src. Curr. Pmt. Discount Amt." * TempBuffer2."VAT %" / (1 + TempBuffer2."VAT %" / 100) / 100,
                    gCurrency."Amount Rounding Precision");
                TempBuffer2."Amount (ACY)" := TempBuffer2."Amount (ACY)" - lDDiscountVATAmount;
                TempBuffer2."Inv. Discount Amt. (ACY)" := TempBuffer2."Inv. Discount Amt. (ACY)" - lDDiscountVATAmount;

                lDDiscountVATAmount :=
                  ROUND(
                    TempBuffer2."Inv. Discount Amt. (ACY)" * TempBuffer2."VAT %" / (1 + TempBuffer2."VAT %" / 100) / 100,
                    gCurrency."Amount Rounding Precision");
                TempBuffer2."Amount (ACY)" := TempBuffer2."Amount (ACY)" - lDDiscountVATAmount;
                TempBuffer2."Inv. Discount Amt. (ACY)" := TempBuffer2."Inv. Discount Amt. (ACY)" - lDDiscountVATAmount;
                // END;

                gGenJnlLine.INIT;
                gGenJnlLine."Posting Date" := pReturnShptHdr."Posting Date";
                gGenJnlLine."Document Date" := pReturnShptHdr."Document Date";
                gGenJnlLine.Description := COPYSTR(pReturnShptHdr."Posting Description", 1, MAXSTRLEN(gGenJnlLine.Description));
                gGenJnlLine."Reason Code" := pReturnShptHdr."Reason Code";
                gGenJnlLine."Document Type" := gGenJnlLine."Document Type"::Receipt;
                gGenJnlLine."Document No." := pReturnShptHdr."No.";
                gGenJnlLine."Tax Area Code" := pReturnShptHdr."No.";
                gGenJnlLine."External Document No." := pReturnShptHdr."Vendor Authorization No.";
                gGenJnlLine."Account No." := TempBuffer2."G/L Account";
                gGenJnlLine."System-Created Entry" := TempBuffer2."System-Created Entry";
                TempBuffer2.Amount := ROUND(TempBuffer2.Amount, 0.01, '=');
                gGenJnlLine.Amount := -TempBuffer2.Amount;
                lDTotal := lDTotal - gGenJnlLine.Amount;//TempBuffer2.Amount;
                gGenJnlLine."Source Currency Code" := pReturnShptHdr."Currency Code";
                gGenJnlLine."Source Currency Amount" := -TempBuffer2."Amount (ACY)";
                lDTotalACY := lDTotalACY - gGenJnlLine."Source Currency Amount";//TempBuffer2."Amount (ACY)";
                gGenJnlLine.Correction := pReturnShptHdr.Correction;
                gGenJnlLine."Gen. Posting Type" := gGenJnlLine."Gen. Posting Type"::" ";
                gGenJnlLine."Gen. Bus. Posting Group" := '';// TempBuffer2."Gen. Bus. Posting Group";
                gGenJnlLine."Gen. Prod. Posting Group" := '';// TempBuffer2."Gen. Prod. Posting Group";
                gGenJnlLine."VAT Bus. Posting Group" := '';//TempBuffer2."VAT Bus. Posting Group";
                gGenJnlLine."VAT Prod. Posting Group" := '';//TempBuffer2."VAT Prod. Posting Group";
                gGenJnlLine."Tax Area Code" := TempBuffer2."Tax Area Code";
                gGenJnlLine."Tax Liable" := TempBuffer2."Tax Liable";
                gGenJnlLine."Tax Group Code" := TempBuffer2."Tax Group Code";
                gGenJnlLine."Use Tax" := TempBuffer2."Use Tax";
                gGenJnlLine.Quantity := TempBuffer2.Quantity;
                gGenJnlLine."VAT Calculation Type" := TempBuffer2."VAT Calculation Type";
                gGenJnlLine."VAT Base Amount" := -TempBuffer2."VAT Base Amount";
                gGenJnlLine."VAT Base Discount %" := pReturnShptHdr."VAT Base Discount %";
                gGenJnlLine."Source Curr. VAT Base Amount" := -TempBuffer2."VAT Base Amount (ACY)";
                gGenJnlLine."VAT Amount" := -TempBuffer2."VAT Amount";
                gGenJnlLine."Source Curr. VAT Amount" := -TempBuffer2."VAT Amount (ACY)";
                gGenJnlLine."VAT Difference" := -TempBuffer2."VAT Difference";
                gGenJnlLine."VAT Posting" := gGenJnlLine."VAT Posting"::"Manual VAT Entry";
                gGenJnlLine."Shortcut Dimension 1 Code" := TempBuffer2."Global Dimension 1 Code";
                gGenJnlLine."Shortcut Dimension 2 Code" := TempBuffer2."Global Dimension 2 Code";
                //ASC
                gGenJnlLine."Shortcut Dimension 3 Code" := TempBuffer2."Global Dimension 3 Code";
                gGenJnlLine."Shortcut Dimension 4 Code" := TempBuffer2."Global Dimension 4 Code";
                gGenJnlLine."Shortcut Dimension 5 Code" := TempBuffer2."Global Dimension 5 Code";
                gGenJnlLine."Dimension Set ID" := TempBuffer2."Dimension Set ID";
                gGenJnlLine.Circuito := TRUE;
                gGenJnlLine."Job No." := TempBuffer2."Job No.";
                gGenJnlLine."Source Code" := gCSrcCode;
                gGenJnlLine."Sell-to/Buy-from No." := pReturnShptHdr."Buy-from Vendor No.";
                gGenJnlLine."Bill-to/Pay-to No." := pReturnShptHdr."Pay-to Vendor No.";
                gGenJnlLine."Country/Region Code" := pReturnShptHdr."VAT Country/Region Code";
                gGenJnlLine."VAT Registration No." := pReturnShptHdr."VAT Registration No.";
                gGenJnlLine."Source Type" := gGenJnlLine."Source Type"::Vendor;
                gGenJnlLine."Source No." := pReturnShptHdr."Pay-to Vendor No.";
                gGenJnlLine."Posting No. Series" := '';
                gGenJnlLine."IC Partner Code" := '';//"Pay-to IC Partner Code";
                gGenJnlLine."Ship-to/Order Address Code" := pReturnShptHdr."Order Address Code";

                gGenJnlLine."Payment Terms Code" := pReturnShptHdr."Payment Terms Code";
                gGenJnlLine."Payment Method Code" := pReturnShptHdr."Payment Method Code";

                gGenJnlLine."Generate AutoInvoices" := FALSE;//"Generate Autoinvoices" OR "Generate Autocredit Memo";
                gGenJnlLine."AutoDoc. No." := '';

                if TempBuffer2.Type = TempBuffer2.Type::"Fixed Asset" THEN BEGIN
                    gGenJnlLine."Account Type" := gGenJnlLine."Account Type"::"Fixed Asset";
                    if TempBuffer2."FA Posting Type" =
                      TempBuffer2."FA Posting Type"::"Acquisition Cost"
                    THEN
                        gGenJnlLine."FA Posting Type" := gGenJnlLine."FA Posting Type"::"Acquisition Cost";
                    if TempBuffer2."FA Posting Type" =
                       TempBuffer2."FA Posting Type"::Maintenance
                    THEN
                        gGenJnlLine."FA Posting Type" := gGenJnlLine."FA Posting Type"::Maintenance;
                    gGenJnlLine."FA Posting Date" := TempBuffer2."FA Posting Date";
                    gGenJnlLine."Depreciation Book Code" := TempBuffer2."Depreciation Book Code";
                    gGenJnlLine."Salvage Value" := TempBuffer2."Salvage Value";
                    gGenJnlLine."Depr. until FA Posting Date" := TempBuffer2."Depr. until FA Posting Date";
                    gGenJnlLine."Depr. Acquisition Cost" := TempBuffer2."Depr. Acquisition Cost";
                    gGenJnlLine."Maintenance Code" := TempBuffer2."Maintenance Code";
                    gGenJnlLine."Insurance No." := TempBuffer2."Insurance No.";
                    gGenJnlLine."Budgeted FA No." := TempBuffer2."Budgeted FA No.";
                    gGenJnlLine."Duplicate in Depreciation Book" := TempBuffer2."Duplicate in Depreciation Book";
                    gGenJnlLine."Use Duplication List" := TempBuffer2."Use Duplication List";
                END;

                RungcGenJnlPostLine(gGenJnlLine);//,TempBuffer2."Dimension Entry No.");
                                                 /* if FAInsertDiscountAmount(TempBuffer2,DeprBook) THEN
                                                   FAPostDiscountAmount(
                                                     gGenJnlLine,
                                                     TempBuffer2."Line Discount Amount" + TempBuffer2."Inv. Discount Amount",
                                                     TempBuffer2."Line Discount Amt. (ACY)" + TempBuffer2."Inv. Discount Amt. (ACY)",
                                                     TempBuffer2."Dimension Entry No."); */
                gGenJnlLine."Account Type" := gGenJnlLine."Account Type"::"G/L Account";
                gGenJnlLine.VALIDATE("FA Posting Type", gGenJnlLine."FA Posting Type"::" ");
                /* if FAInsertDiscountAmount(TempBuffer2,DeprBook) THEN
                  PostDiscount(
                    TempBuffer2."FA Discount Account",
                    -(TempBuffer2."Line Discount Amount" + TempBuffer2."Inv. Discount Amount"),
                    -(TempBuffer2."Line Discount Amt. (ACY)" + TempBuffer2."Inv. Discount Amt. (ACY)"),
                    TempBuffer2."Dimension Entry No."); */
                if (TempBuffer2."Line Discount Amount" <> 0) OR
                   (TempBuffer2."Line Discount Amt. (ACY)" <> 0)
                THEN
                    PostDiscount(
                      TempBuffer2."Line Discount Account",
                      TempBuffer2."Line Discount Amount",
                      TempBuffer2."Line Discount Amt. (ACY)",
                      TempBuffer2."Dimension Entry No.", gPurchHeader);
                if (TempBuffer2."Inv. Discount Amount" <> 0) OR
                   (TempBuffer2."Inv. Discount Amt. (ACY)" <> 0)
                THEN
                    PostDiscount(
                      TempBuffer2."Inv. Discount Account",
                      TempBuffer2."Inv. Discount Amount",
                      TempBuffer2."Inv. Discount Amt. (ACY)",
                      TempBuffer2."Dimension Entry No.", gPurchHeader);
                if TempBuffer2."Pmt. Discount Amount" <> 0 THEN
                    PostDiscount(
                      TempBuffer2."Pmt. Discount Account",
                      TempBuffer2."Pmt. Discount Amount",
                      TempBuffer2."Src. Curr. Pmt. Discount Amt.",
                      TempBuffer2."Dimension Entry No.", gPurchHeader);
            UNTIL TempBuffer2.Next(-1) = 0;

        TempBuffer2.DELETEALL;

        // Check External Document number
        /* {if gPurchSetup."Ext. Doc. No. Mandatory" OR
          (gGenJnlLineExtDocNo <> '')
        THEN BEGIN
          VendLedgEntry.RESET;
          VendLedgEntry.SETCURRENTKEY("External Document No.");
          VendLedgEntry.SETRANGE("Document Type",gGenJnlLineDocType);
          VendLedgEntry.SETRANGE("External Document No.",gGenJnlLineExtDocNo);
          VendLedgEntry.SETRANGE("Vendor No.","Pay-to Vendor No.");
          if VendLedgEntry.FINDFIRST THEN
            ERROR(
              Text016,
              VendLedgEntry."Document Type",gGenJnlLineExtDocNo);
        END;} */

        // Post vendor entries
        //if GUIALLOWED THEN
        //Window.UPDATE(4,1);
        gGenJnlLine.INIT;
        gGenJnlLine."Posting Date" := pReturnShptHdr."Posting Date";
        gGenJnlLine."Document Date" := pReturnShptHdr."Document Date";
        gGenJnlLine.Description := COPYSTR(pReturnShptHdr."Posting Description", 1, MAXSTRLEN(gGenJnlLine.Description));
        gGenJnlLine."Shortcut Dimension 1 Code" := pReturnShptHdr."Shortcut Dimension 1 Code";
        gGenJnlLine."Shortcut Dimension 2 Code" := pReturnShptHdr."Shortcut Dimension 2 Code";
        //ASC
        gGenJnlLine."Shortcut Dimension 3 Code" := pReturnShptHdr."Shortcut Dimension 3 Code";
        gGenJnlLine."Shortcut Dimension 4 Code" := pReturnShptHdr."Shortcut Dimension 4 Code";
        gGenJnlLine."Shortcut Dimension 5 Code" := pReturnShptHdr."Shortcut Dimension 5 Code";
        gGenJnlLine."Dimension Set ID" := pReturnShptHdr."Dimension Set ID";
        gGenJnlLine.Circuito := TRUE;
        gGenJnlLine."Reason Code" := pReturnShptHdr."Reason Code";
        gGenJnlLine."Account Type" := gGenJnlLine."Account Type"::"G/L Account";
        lVendor.GET(pReturnShptHdr."Pay-to Vendor No.");
        lVendorPostingGroup.GET(lVendor."Vendor Posting Group");
        gGenJnlLine."Account No." := lVendorPostingGroup.FPR;
        gGenJnlLine."Document Type" := gGenJnlLine."Document Type"::Receipt;
        gGenJnlLine."Document No." := lCGenJnlLineDocNo;
        gGenJnlLine."Tax Area Code" := lCGenJnlLineDocNo;
        gGenJnlLine."External Document No." := ltGenJnlLineExtDocNo;
        gGenJnlLine."Currency Code" := pReturnShptHdr."Currency Code";
        gGenJnlLine.Amount := lDTotal;
        gGenJnlLine."Source Currency Code" := pReturnShptHdr."Currency Code";
        gGenJnlLine."Source Currency Amount" := lDTotal;
        gGenJnlLine."Amount (LCY)" := lDTotalACY;
        if gPurchHeader."Currency Code" = '' THEN
            gGenJnlLine."Currency Factor" := 1
        ELSE
            gGenJnlLine."Currency Factor" := gPurchHeader."Currency Factor";
        gGenJnlLine."Sales/Purch. (LCY)" := lDTotalACY;
        gGenJnlLine.Correction := pReturnShptHdr.Correction;
        gGenJnlLine."Inv. Discount (LCY)" := -gTotalPurchaseLineLCY."Inv. Discount Amount";
        gGenJnlLine."Pmt. Discount Given/Rec. (LCY)" := 0;// gTotalPurchaseLineLCY."Pmt. Discount Amount";
        gGenJnlLine."Sell-to/Buy-from No." := pReturnShptHdr."Buy-from Vendor No.";
        gGenJnlLine."Bill-to/Pay-to No." := pReturnShptHdr."Pay-to Vendor No.";
        gGenJnlLine."Salespers./Purch. Code" := pReturnShptHdr."Purchaser Code";
        gGenJnlLine."System-Created Entry" := TRUE;
        gGenJnlLine."On Hold" := pReturnShptHdr."On Hold";
        gGenJnlLine."Applies-to Doc. Type" := pReturnShptHdr."Applies-to Doc. Type";
        gGenJnlLine."Applies-to Bill No." := '';
        gGenJnlLine."Applies-to Doc. No." := pReturnShptHdr."Applies-to Doc. No.";
        gGenJnlLine."Applies-to ID" := '';
        gGenJnlLine."Allow Application" := pReturnShptHdr."Bal. Account No." = '';
        gGenJnlLine."Payment Terms Code" := pReturnShptHdr."Payment Terms Code";
        gGenJnlLine."Payment Method Code" := pReturnShptHdr."Payment Method Code";
#if not CLEAN22
        // TODO: - CLEAN22
#if not CLEAN27
        gGenJnlLine."Pmt. Address Code" := '';//"Pay-at Code";
                                              // TODO: - CLEAN22
#endif
#endif
        gGenJnlLine."Recipient Bank Account" := '';//"Vendor Bank Acc. Code";
        gGenJnlLine."Due Date" := pReturnShptHdr."Due Date";
        //gGenJnlLine."Pmt. Discount Date" := "Pmt. Discount Date";
        gGenJnlLine."Payment Discount %" := pReturnShptHdr."Payment Discount %";
        gGenJnlLine."Source Type" := gGenJnlLine."Source Type"::Vendor;
        gGenJnlLine."Source No." := pReturnShptHdr."Pay-to Vendor No.";
        gGenJnlLine."Source Code" := gCSrcCode;
        gGenJnlLine."Posting No. Series" := '';
        gGenJnlLine."IC Partner Code" := '';//"Pay-to IC Partner Code";
        gGenJnlLine."Generate AutoInvoices" := FALSE;//"Generate Autoinvoices" OR "Generate Autocredit Memo";
        gGenJnlLine."AutoDoc. No." := '';

        /* TempJnlLineDim.DELETEALL;
        TempDocDim.RESET;
        TempDocDim.SETRANGE("Table ID",DATABASE::"Purch. Rcpt. Header");
        gcDimMgt.CopyDocDimToJnlLineDim(TempDocDim,TempJnlLineDim); */
        gcGenJnlPostLine.RunWithCheck(gGenJnlLine);//,TempJnlLineDim);

        // END;
        MESSAGE('Se ha contabilizado el albarán %1 con fecha %2', pReturnShptHdr."No.",
          FORMAT(pReturnShptHdr."Posting Date", 0, '<Day,2>/<Month,2>/<Year>'));
        pReturnShptHdr.Contabilizado := TRUE;
        pReturnShptHdr.MODIFY;
    END;


    /// <summary>
    /// FillDevPostingBuffer.
    /// </summary>
    /// <param name="PurchLine">Record "Return Shipment Line".</param>
    /// <param name="PurchLineACY">Record "Return Shipment Line".</param>
    /// <param name="linea">Integer.</param>
    procedure FillDevPostingBuffer(pReturnShptLine: Record "Return Shipment Line"; pReturnShptLineeACY: Record "Return Shipment Line"; piLinea: Integer; var TempBuffer: Record "Invoice Posting Buffer" temporary)
    VAR
        lDAmount: Decimal;
        lDAmountLCY: Decimal;
        lLocation: Record 14;
        llVatPostingGroupinesPostGroup: Record "VAT Business Posting Group";
        FalineNo: Integer;
    BEGIN
        //  WITH PurchLine DO BEGIN
        if (pReturnShptLine."Gen. Bus. Posting Group" <> gGenPostingSetup."Gen. Bus. Posting Group") OR
           (pReturnShptLine."Gen. Prod. Posting Group" <> gGenPostingSetup."Gen. Prod. Posting Group")
        THEN
            if NOT
            gGenPostingSetup.GET(pReturnShptLine."Gen. Bus. Posting Group", pReturnShptLine."Gen. Prod. Posting Group") THEN
                gGenPostingSetup.INIT;

        CLEAR(TempBuffer);
        case pReturnShptLine.Type of
            "Purchase Line Type"::" ":
                TempBuffer.Type := TempBuffer.Type::"G/L Account";
            "Purchase Line Type"::"G/L Account":
                TempBuffer.Type := TempBuffer.Type::"G/L Account";
            "Purchase Line Type"::"Charge (Item)":
                TempBuffer.Type := TempBuffer.Type::"G/L Account";
            "Purchase Line Type"::"Fixed Asset":
                TempBuffer.Type := TempBuffer.Type::"Fixed Asset";
            "Purchase Line Type"::Item:
                TempBuffer.Type := TempBuffer.Type::Item;
            "Purchase Line Type"::Resource:
                TempBuffer.Type := TempBuffer.Type::Resource;
        end;
        //TempBuffer.Type := Type;
        if (pReturnShptLine.Type = pReturnShptLine.Type::"G/L Account") OR (pReturnShptLine.Type = pReturnShptLine.Type::"Fixed Asset") THEN
            TempBuffer."G/L Account" := pReturnShptLine."No."
        ELSE BEGIN
            if NOT lLocation.GET(pReturnShptLine."Location Code") THEN lLocation.INIT;
            if lLocation."Cta. Compras" <> '' THEN BEGIN
                TempBuffer."G/L Account" := lLocation."Cta. Compras";
            END ELSE BEGIN
                gGenPostingSetup.TestField("Purch. Account");
                TempBuffer."G/L Account" := gGenPostingSetup."Purch. Account";
            END;
        END;
        TempBuffer."System-Created Entry" := TRUE;
        TempBuffer."Gen. Bus. Posting Group" := pReturnShptLine."Gen. Bus. Posting Group";
        TempBuffer."Gen. Prod. Posting Group" := pReturnShptLine."Gen. Prod. Posting Group";
        TempBuffer."VAT Bus. Posting Group" := pReturnShptLine."VAT Bus. Posting Group";
        TempBuffer."VAT Prod. Posting Group" := pReturnShptLine."VAT Prod. Posting Group";
        TempBuffer."VAT Calculation Type" := pReturnShptLine."VAT Calculation Type";
        TempBuffer."Global Dimension 1 Code" := pReturnShptLine."Shortcut Dimension 1 Code";
        TempBuffer."Global Dimension 2 Code" := pReturnShptLine."Shortcut Dimension 2 Code";
        //ASC

        TempBuffer."Global Dimension 3 Code" := pReturnShptLine."Shortcut Dimension 3 Code";

        TempBuffer."Global Dimension 4 Code" := pReturnShptLine."Shortcut Dimension 4 Code";
        TempBuffer."Global Dimension 5 Code" := pReturnShptLine."Shortcut Dimension 5 Code";
        TempBuffer."Dimension Set ID" := pReturnShptLine."Dimension Set ID";
        TempBuffer."Job No." := pReturnShptLine."Job No.";
        if COMPANYNAME in [glUnion, glUATI] THEN
            lDAmount := (pReturnShptLine."Return Qty. Shipped Not Invd." * pReturnShptLine."Direct Unit Cost") * (1 - pReturnShptLine."Line Discount %" / 100)
        ELSE
            lDAmount := (pReturnShptLine."Return Qty. Shipped Not Invd." * pReturnShptLine."Unit Cost (LCY)");
        if pReturnShptLine."Line Discount %" = 0 THEN
            lDAmount := (pReturnShptLine."Return Qty. Shipped Not Invd." * pReturnShptLine."Direct Unit Cost");
        lDAmountLCY := ROUND(lDAmount, 0.01, '=');
        TempBuffer.Amount := ROUND(lDAmount, 0.01, '=');
        TempBuffer."VAT Base Amount" := ROUND(lDAmount, 0.01, '=');
        TempBuffer."Amount (ACY)" := lDAmountLCY;

        TempBuffer."VAT Base Amount (ACY)" := lDAmountLCY;
        TempBuffer."VAT Difference" := 0;//"VAT Difference";
        TempBuffer."VAT %" := pReturnShptLine."VAT %";
        //-SII
        gGenLedgerSetup.GET;
        if gGenLedgerSetup."Activar SII" THEN BEGIN
            if gVATPostingSetup.GET(pReturnShptLine."VAT Bus. Posting Group", pReturnShptLine."VAT Prod. Posting Group") THEN;
            if llVatPostingGroupinesPostGroup.GET(pReturnShptLine."VAT Bus. Posting Group") THEN;
            //PurchaseHeader.GET(pReturnShptLine."Document Type",pReturnShptLine."Document No.");
            TempBuffer."Tipo factura SII" := gPurchHeader."Tipo factura SII";
            TempBuffer."Clave registro SII recibidas" := llVatPostingGroupinesPostGroup."Clave registro SII recibidas";
            TempBuffer."Descripción operación" := gPurchHeader."Descripción operación";
            TempBuffer."Tipo desglose emitidas" := gVATPostingSetup."Tipo desglose emitidas";
            TempBuffer."Sujeta exenta" := gVATPostingSetup."Sujeta exenta";
            TempBuffer."Tipo de operación" := gVATPostingSetup."Tipo de operación";
            TempBuffer."Tipo factura rectificativa" := gPurchHeader."Tipo factura rectificativa";
        END;
        //+SII

        if pReturnShptLine.Type = pReturnShptLine.Type::"Fixed Asset" THEN BEGIN
            TempBuffer."FA Posting Date" := pReturnShptLine."FA Posting Date";
            TempBuffer."FA Posting Type" := pReturnShptLine."FA Posting Type";
            TempBuffer."Depreciation Book Code" := pReturnShptLine."Depreciation Book Code";
            TempBuffer."Salvage Value" := pReturnShptLine."Salvage Value";
            TempBuffer."Depr. until FA Posting Date" := pReturnShptLine."Depr. until FA Posting Date";
            TempBuffer."Depr. Acquisition Cost" := pReturnShptLine."Depr. Acquisition Cost";
            TempBuffer."Maintenance Code" := pReturnShptLine."Maintenance Code";
            TempBuffer."Insurance No." := pReturnShptLine."Insurance No.";
            TempBuffer."Budgeted FA No." := pReturnShptLine."Budgeted FA No.";
            TempBuffer."Duplicate in Depreciation Book" := pReturnShptLine."Duplicate in Depreciation Book";
            TempBuffer."Use Duplication List" := pReturnShptLine."Use Duplication List";
        END;
        CASE pReturnShptLine."VAT Calculation Type" OF
            pReturnShptLine."VAT Calculation Type"::"Normal VAT", pReturnShptLine."VAT Calculation Type"::"Full VAT":
                BEGIN
                    TempBuffer."VAT Amount" := lDAmount * (pReturnShptLine."VAT %" / 100);
                    TempBuffer."VAT Amount (ACY)" :=
                     lDAmountLCY * (pReturnShptLine."VAT %" / 100);
                END;
            pReturnShptLine."VAT Calculation Type"::"Reverse Charge VAT":
                ; // Reverse Charge VAT is calculated later, based on totals
            pReturnShptLine."VAT Calculation Type"::"Sales Tax":
                BEGIN
                    if NOT pReturnShptLine."Use Tax" THEN BEGIN  // Use Tax is calculated later, based on totals
                        TempBuffer."VAT Amount" := lDAmount * (pReturnShptLine."VAT %" / 100);
                        TempBuffer."VAT Amount (ACY)" :=
                          lDAmountLCY * (pReturnShptLine."VAT %" / 100);
                    END;
                    TempBuffer."Tax Area Code" := pReturnShptLine."Tax Area Code";
                    TempBuffer."Tax Liable" := pReturnShptLine."Tax Liable";
                    TempBuffer."Tax Group Code" := pReturnShptLine."Tax Group Code";
                    TempBuffer."Use Tax" := pReturnShptLine."Use Tax";
                    TempBuffer.Quantity := pReturnShptLine."Return Qty. Shipped Not Invd.";
                END;
        END;

        if gPurchSetup."Post Invoice Discount" THEN BEGIN
            TempBuffer.Amount := TempBuffer.Amount;// + "Inv. Discount Amount";
            TempBuffer."Inv. Discount Amount" := 0;//"Inv. Discount Amount";
            TempBuffer."Amount (ACY)" :=
              TempBuffer."Amount (ACY)";// + PurchLineACY."Inv. Discount Amount";
            TempBuffer."Inv. Discount Amt. (ACY)" := 0;//PurchLineACY."Inv. Discount Amount";
                                                       /* {if ("Inv. Discount Amount" <> 0) OR (PurchLineACY."Inv. Discount Amount" <> 0)THEN BEGIN
                                                         gGenPostingSetup.TestField("Purch. Inv. Disc. Account");
                                                         TempBuffer."Inv. Discount Account" := gGenPostingSetup."Purch. Inv. Disc. Account";
                                                       END;} */
        END;
        if gPurchSetup."Post Line Discount" THEN BEGIN
            TempBuffer.Amount := TempBuffer.Amount + TempBuffer.Amount * (pReturnShptLine."Line Discount %" / 100);
            TempBuffer."Line Discount Amount" := TempBuffer.Amount * (pReturnShptLine."Line Discount %" / 100);
            TempBuffer."Amount (ACY)" :=
              TempBuffer."Amount (ACY)" + TempBuffer."Amount (ACY)" * (pReturnShptLine."Line Discount %" / 100);
            TempBuffer."Line Discount Amt. (ACY)" := TempBuffer."Amount (ACY)" * (pReturnShptLine."Line Discount %" / 100);
            if (TempBuffer.Amount * (pReturnShptLine."Line Discount %" / 100) <> 0) OR
            (TempBuffer."Amount (ACY)" * (pReturnShptLine."Line Discount %" / 100) <> 0) THEN BEGIN
                gGenPostingSetup.TestField("Purch. Line Disc. Account");
                TempBuffer."Line Discount Account" := gGenPostingSetup."Purch. Line Disc. Account";
            END;
        END;
        if gPurchSetup."Post Payment Discount" THEN BEGIN
            TempBuffer.Amount := TempBuffer.Amount;// + "Pmt. Discount Amount";
            TempBuffer."Pmt. Discount Amount" := 0;//"Pmt. Discount Amount";
            TempBuffer."Amount (ACY)" :=
              TempBuffer."Amount (ACY)";// + PurchLineACY."Pmt. Discount Amount";
            TempBuffer."Src. Curr. Pmt. Discount Amt." := 0;//PurchLineACY."Pmt. Discount Amount";
                                                            /* {if (pReturnShptLine."Pmt. Discount Amount" <> 0) OR (PurchLineACY."Pmt. Discount Amount" <> 0) THEN BEGIN
                                                              gGenPostingSetup.TestField("Purch. Pmt. Disc. Credit Acc.");
                                                              TempBuffer."Pmt. Discount Account" := gGenPostingSetup."Purch. Pmt. Disc. Credit Acc.";
                                                            END;} */
        END;

        //  TempBuffer."FA Discount Account" := FASetDiscountAccount(PurchLine);
        /*   TempDocDim.SETRANGE("Table ID","Purchase Line");
          TempDocDim.SETRANGE("Line No.",linea); */

        // END;
    END;

    /// <summary>
    /// UpdInvPostingBuffer.
    /// </summary>


#pragma warning restore AL0432 // TODO: - Invoice Posting Buffer codunit 825
    /// <summary>
    /// FechaAlbaran.
    /// </summary>
    /// <param name="Num">Text[30].</param>
    /// <returns>Return value of type Date.</returns>
    procedure FechaAlbaran(ptNum: Text[30]): Date
    var
        lGlEntry: Record "G/L Entry";
    begin

        lGlEntry.SETCURRENTKEY(lGlEntry."Document No.", lGlEntry."Posting Date");
        lGlEntry.SETRANGE(lGlEntry."Document No.", ptNum);
        lGlEntry.SETRANGE(lGlEntry."Document Type", lGlEntry."Document Type"::Receipt);
        if NOT lGlEntry.FINDFIRST THEN EXIT(WORKDATE);
        if DATE2DMY(lGlEntry."Posting Date", 3) < DATE2DMY(WORKDATE, 3) THEN EXIT(WORKDATE);
        if DATE2DMY(lGlEntry."Posting Date", 3) = DATE2DMY(WORKDATE, 3) Then
            if DATE2DMY(lGlEntry."Posting Date", 2) < DATE2DMY(WORKDATE, 2) THEN EXIT(WORKDATE);
        EXIT(lGlEntry."Posting Date");
    end;
#pragma warning disable AL0432 // TODO: - Invoice Posting Buffer codunit 825
    internal procedure DesContabilizarAlbaranes(var pPurcRcptHdr: Record "Purch. Rcpt. Header")
    Var
        liGenJnlLineDocType: Integer;
        lCGenJnlLineDocNo: Code[20];
        ltGenJnlLineExtDocNo: Text;
        lDTotal: decimal;
        lDTotalACY: decimal;
        lPurchRcptLineTMP: Record "Purch. Rcpt. Line" temporary;
        lPurchArchiveLine: Record "Purchase Line Archive";
        liLinecount: Integer;
        lPurchHeader: Record "Purchase Header";
        lCAutoDocNo: Code[20];
        lVendorPostingGroup: Record "Vendor Posting Group";
        lVendor: Record Vendor;
        lPurchRecptLine: Record "Purch. Rcpt. Line";
        TempBuffer: Record "Invoice Posting Buffer" temporary;
        TempBuffer2: Record "Invoice Posting Buffer" temporary;
        FaLineNo: Integer;
    begin

        // WITH pPurcRcptHdr DO BEGIN
        lPurchRecptLine.SETRANGE(lPurchRecptLine."Document No.", pPurcRcptHdr."No.");
        lPurchRecptLine.SETFILTER(lPurchRecptLine."No.", '%1', '');
        lPurchRecptLine.MODIFYALL(lPurchRecptLine.Type, lPurchRecptLine.Type::" ");
        COMMIT;
        if Not lPurchHeader.Get(lPurchHeader."Document Type"::Order, pPurcRcptHdr."Order No.") Then lPurchHeader.Init();
        if NOT pPurcRcptHdr.Contabilizado THEN ERROR(glDebeContabilizado);
        liGenJnlLineDocType := 0;
        lCGenJnlLineDocNo := pPurcRcptHdr."No.";
        ltGenJnlLineExtDocNo := pPurcRcptHdr."Vendor Shipment No.";
        lDTotal := 0;
        lDTotalACY := 0;
        lPurchRcptLineTMP.SETRANGE(lPurchRcptLineTMP."Document No.", pPurcRcptHdr."No.");
        // {lGlEntry.SETCURRENTKEY(lGlEntry."Transaction No.");
        // lGlEntry.SETRANGE("Document No.", pPurcRcptHdr."No.");
        // lGlEntry.SETRANGE("Document Type",lGlEntry."Document Type"::Receipt);
        // lGlEntry.FINDLAST;
        // ReversalEntry.ReverseAlbaran(lGlEntry."Transaction No.");
        // Contabilizado:=FALSE;
        // MODIFY;
        // EXIT;           }
        //No borro lo que hay
        DesglosarAlbaranes(pPurcRcptHdr, lPurchRcptLineTMP);
        if lPurchRcptLineTMP.FINDFIRST THEN
            REPEAT
                if (lPurchRcptLineTMP.Type.AsInteger() >= lPurchRcptLineTMP.Type::"G/L Account".AsInteger()) AND (lPurchRcptLineTMP."Qty. Rcd. Not Invoiced" <> 0) THEN BEGIN
                    // Copy purchase to Buffer
                    //PurchLineACY.GET(lPurchRcptLineTMP."Document No.",lPurchRcptLineTMP."Line No.");
                    // DocDim.SETRANGE(DocDim."Table ID",DATABASE::"Purchase Line Archive");
                    // DocDim.SETRANGE(DocDim."Document Type",DocDim."Document Type"::Order);
                    // DocDim.SETRANGE(DocDim."Document No.",lPurchRcptLineTMP."Document No.");
                    // DocDim.SETRANGE(DocDim."Line No.",lPurchRcptLineTMP."Line No.");
                    // if DocDim.FINDFIRST THEN REPEAT
                    // TempDocDim.TransferFields(DocDim);
                    // if TempDocDim.INSERT THEN;
                    // UNTIL DocDim.NEXT=0;
                    lPurchArchiveLine.Setrange("Document Type", lPurchArchiveLine."Document Type"::Order);
                    lPurchArchiveLine.Setrange("Document No.", lPurchRcptLineTMP."Document No.");
                    if lPurchArchiveLine.FINDFIRST() Then Begin
                        lPurchRcptLineTMP."Shortcut Dimension 1 Code" := lPurchArchiveLine."Shortcut Dimension 1 Code";
                        lPurchRcptLineTMP."Shortcut Dimension 2 Code" := lPurchArchiveLine."Shortcut Dimension 2 Code";
                        lPurchRcptLineTMP."Shortcut Dimension 3 Code" := lPurchArchiveLine."Shortcut Dimension 3 Code";
                        lPurchRcptLineTMP."Shortcut Dimension 4 Code" := lPurchArchiveLine."Shortcut Dimension 4 Code";
                        lPurchRcptLineTMP."Shortcut Dimension 5 Code" := lPurchArchiveLine."Shortcut Dimension 5 Code";
                        lPurchRcptLineTMP."Dimension Set ID" := lPurchArchiveLine."Dimension Set ID";
                        lPurchRcptLineTMP.Modify();
                    end;
                    FillAlbPostingBuffer(lPurchRcptLineTMP, lPurchRcptLineTMP."Line No.", TempBuffer);
                    UpdInvPostingBuldFFeProduccionesgloNew(TempBuffer, FALineNo, TempBuffer2);

                    // TempDocDim.SETRANGE("Table ID");
                    // TempDocDim.SETRANGE("Line No.");
                END;
            UNTIL lPurchRcptLineTMP.NEXT = 0;

        // Post purchase and VAT to G/L entries from Buffer
        liLinecount := 0;
        TempBuffer2.RESET;
        if TempBuffer2.FIND('+') THEN
            REPEAT
                liLinecount := liLinecount + 1;
                //if GUIALLOWED THEN
                //Window.UPDATE(3,liLinecount);

                CASE TempBuffer2."VAT Calculation Type" OF
                    TempBuffer2."VAT Calculation Type"::"Reverse Charge VAT":
                        BEGIN
                            gVATPostingSetup.GET(
                                TempBuffer2."VAT Bus. Posting Group", TempBuffer2."VAT Prod. Posting Group");
                            TempBuffer2."VAT Amount" :=
                                ROUND(
                                (TempBuffer2.Amount -

                                TempBuffer2."Line Discount Amount" -

                                TempBuffer2."Inv. Discount Amount" -
                                TempBuffer2."Pmt. Discount Amount") *
                                gVATPostingSetup."VAT+EC %" / 100);
                            TempBuffer2."VAT Amount (ACY)" :=
                                ROUND(
                                (TempBuffer2."Amount (ACY)" -
                                TempBuffer2."Line Discount Amt. (ACY)" -
                                TempBuffer2."Inv. Discount Amt. (ACY)" -
                                TempBuffer2."Src. Curr. Pmt. Discount Amt.") *
                                gVATPostingSetup."VAT+EC %" / 100, gCurrency."Amount Rounding Precision");
                        END;
                    TempBuffer2."VAT Calculation Type"::"Sales Tax":
                        BEGIN
                            if TempBuffer2."Use Tax" THEN BEGIN
                                TempBuffer2."VAT Amount" :=
                                ROUND(
                                    gcSalesTaxCalculate.CalculateTax(
                                    TempBuffer2."Tax Area Code", TempBuffer2."Tax Group Code",
                                    TempBuffer2."Tax Liable", lPurchHeader."Posting Date",
                                    TempBuffer2.Amount -
                                    TempBuffer2."Line Discount Amount" - TempBuffer2."Inv. Discount Amount" -
                                    TempBuffer2."Pmt. Discount Amount",
                                    TempBuffer2.Quantity, 0));
                                if gGenLedgerSetup."Additional Reporting Currency" <> '' THEN
                                    TempBuffer2."VAT Amount (ACY)" :=
                                    gCurrExchRate.ExchangeAmtLCYToFCY(
                                        lPurchHeader."Posting Date", gGenLedgerSetup."Additional Reporting Currency",
                                        TempBuffer2."VAT Amount", 0);
                            END;
                        END;
                END;

                if lPurchHeader."Prices Including VAT" AND (TempBuffer2."VAT %" <> 0) THEN
                    WITH TempBuffer2 DO BEGIN
                        gDDiscountVATAmount :=
                        ROUND("Line Discount Amount" * "VAT %" / (1 + "VAT %" / 100) / 100);
                        Amount := Amount - gDDiscountVATAmount;
                        "Line Discount Amount" := "Line Discount Amount" - gDDiscountVATAmount;

                        gDDiscountVATAmount :=
                        ROUND(
                            "Line Discount Amt. (ACY)" * "VAT %" / (1 + "VAT %" / 100) / 100,
                            gCurrency."Amount Rounding Precision");
                        "Amount (ACY)" := "Amount (ACY)" - gDDiscountVATAmount;
                        "Line Discount Amt. (ACY)" := "Line Discount Amt. (ACY)" - gDDiscountVATAmount;

                        gDDiscountVATAmount :=
                        ROUND("Inv. Discount Amount" * "VAT %" / (1 + "VAT %" / 100) / 100);
                        Amount := Amount - gDDiscountVATAmount;
                        "Inv. Discount Amount" := "Inv. Discount Amount" - gDDiscountVATAmount;

                        gDDiscountVATAmount :=
                        ROUND(
                            "Src. Curr. Pmt. Discount Amt." * "VAT %" / (1 + "VAT %" / 100) / 100,
                            gCurrency."Amount Rounding Precision");
                        "Amount (ACY)" := "Amount (ACY)" - gDDiscountVATAmount;
                        "Inv. Discount Amt. (ACY)" := "Inv. Discount Amt. (ACY)" - gDDiscountVATAmount;

                        gDDiscountVATAmount :=
                        ROUND(
                            "Inv. Discount Amt. (ACY)" * "VAT %" / (1 + "VAT %" / 100) / 100,
                            gCurrency."Amount Rounding Precision");
                        "Amount (ACY)" := "Amount (ACY)" - gDDiscountVATAmount;
                        "Inv. Discount Amt. (ACY)" := "Inv. Discount Amt. (ACY)" - gDDiscountVATAmount;
                    END;

                gGenJnlLine.INIT;
                gGenJnlLine."Posting Date" := FechaAlbaran(pPurcRcptHdr."No.");
                gGenJnlLine."Document Date" := pPurcRcptHdr."Document Date";
                gGenJnlLine.Description := COPYSTR(pPurcRcptHdr."Posting Description", 1, MAXSTRLEN(gGenJnlLine.Description));
                gGenJnlLine."Reason Code" := pPurcRcptHdr."Reason Code";
                gGenJnlLine."Document Type" := gGenJnlLine."Document Type"::Receipt;
                gGenJnlLine."Document No." := pPurcRcptHdr."No.";
                gGenJnlLine."External Document No." := pPurcRcptHdr."Vendor Shipment No.";
                gGenJnlLine."Tax Area Code" := pPurcRcptHdr."No.";
                gGenJnlLine."Account No." := TempBuffer2."G/L Account";
                gGenJnlLine."System-Created Entry" := TempBuffer2."System-Created Entry";
                gGenJnlLine.Amount := -TempBuffer2.Amount;
                lDTotal := lDTotal + TempBuffer2.Amount;
                gGenJnlLine."Source Currency Code" := pPurcRcptHdr."Currency Code";
                gGenJnlLine."Source Currency Amount" := -TempBuffer2."Amount (ACY)";
                lDTotalACY := lDTotalACY + TempBuffer2."Amount (ACY)";
                gGenJnlLine.Correction := pPurcRcptHdr.Correction;
                gGenJnlLine."Gen. Posting Type" := gGenJnlLine."Gen. Posting Type"::" ";
                gGenJnlLine."Gen. Bus. Posting Group" := '';//TempBuffer2."Gen. Bus. Posting Group";
                gGenJnlLine."Gen. Prod. Posting Group" := '';// TempBuffer2."Gen. Prod. Posting Group";
                gGenJnlLine."VAT Bus. Posting Group" := '';//TempBuffer2."VAT Bus. Posting Group";
                gGenJnlLine."VAT Prod. Posting Group" := '';//TempBuffer2."VAT Prod. Posting Group";
                gGenJnlLine."Tax Area Code" := TempBuffer2."Tax Area Code";
                gGenJnlLine."Tax Liable" := TempBuffer2."Tax Liable";
                gGenJnlLine."Tax Group Code" := TempBuffer2."Tax Group Code";
                gGenJnlLine."Use Tax" := TempBuffer2."Use Tax";
                gGenJnlLine.Quantity := TempBuffer2.Quantity;
                gGenJnlLine."VAT Calculation Type" := TempBuffer2."VAT Calculation Type";
                gGenJnlLine."VAT Base Amount" := -TempBuffer2."VAT Base Amount";
                gGenJnlLine."VAT Base Discount %" := pPurcRcptHdr."VAT Base Discount %";
                gGenJnlLine."Source Curr. VAT Base Amount" := -TempBuffer2."VAT Base Amount (ACY)";
                gGenJnlLine."VAT Amount" := -TempBuffer2."VAT Amount";
                gGenJnlLine."Source Curr. VAT Amount" := -TempBuffer2."VAT Amount (ACY)";
                gGenJnlLine."VAT Difference" := -TempBuffer2."VAT Difference";
                gGenJnlLine."VAT Posting" := gGenJnlLine."VAT Posting"::"Manual VAT Entry";
                gGenJnlLine."Shortcut Dimension 1 Code" := TempBuffer2."Global Dimension 1 Code";
                gGenJnlLine."Shortcut Dimension 2 Code" := TempBuffer2."Global Dimension 2 Code";
                //ASC
                gGenJnlLine."Shortcut Dimension 3 Code" := TempBuffer2."Global Dimension 3 Code";
                gGenJnlLine."Shortcut Dimension 4 Code" := TempBuffer2."Global Dimension 4 Code";
                gGenJnlLine."Shortcut Dimension 5 Code" := TempBuffer2."Global Dimension 5 Code";
                gGenJnlLine."Dimension Set ID" := TempBuffer2."Dimension Set ID";
                gGenJnlLine.Circuito := TRUE;
                gGenJnlLine."Job No." := TempBuffer2."Job No.";
                gGenJnlLine."Source Code" := gCSrcCode;
                gGenJnlLine."Sell-to/Buy-from No." := pPurcRcptHdr."Buy-from Vendor No.";
                gGenJnlLine."Bill-to/Pay-to No." := pPurcRcptHdr."Pay-to Vendor No.";
                gGenJnlLine."Country/Region Code" := pPurcRcptHdr."VAT Country/Region Code";
                gGenJnlLine."VAT Registration No." := pPurcRcptHdr."VAT Registration No.";
                gGenJnlLine."Source Type" := gGenJnlLine."Source Type"::Vendor;
                gGenJnlLine."Source No." := pPurcRcptHdr."Pay-to Vendor No.";
                gGenJnlLine."Posting No. Series" := '';
                gGenJnlLine."IC Partner Code" := '';//"Pay-to IC Partner Code";
                gGenJnlLine."Ship-to/Order Address Code" := pPurcRcptHdr."Order Address Code";

                gGenJnlLine."Payment Terms Code" := pPurcRcptHdr."Payment Terms Code";
                gGenJnlLine."Payment Method Code" := pPurcRcptHdr."Payment Method Code";

                gGenJnlLine."Generate AutoInvoices" := FALSE;//"Generate Autoinvoices" OR "Generate Autocredit Memo";
                gGenJnlLine."AutoDoc. No." := lCAutoDocNo;

                if TempBuffer2.Type = TempBuffer2.Type::"Fixed Asset" THEN BEGIN
                    gGenJnlLine."Account Type" := gGenJnlLine."Account Type"::"Fixed Asset";
                    if TempBuffer2."FA Posting Type" =
                        TempBuffer2."FA Posting Type"::"Acquisition Cost"
                    THEN
                        gGenJnlLine."FA Posting Type" := gGenJnlLine."FA Posting Type"::"Acquisition Cost";
                    if TempBuffer2."FA Posting Type" =
                        TempBuffer2."FA Posting Type"::Maintenance
                    THEN
                        gGenJnlLine."FA Posting Type" := gGenJnlLine."FA Posting Type"::Maintenance;
                    gGenJnlLine."FA Posting Date" := TempBuffer2."FA Posting Date";
                    gGenJnlLine."Depreciation Book Code" := TempBuffer2."Depreciation Book Code";
                    gGenJnlLine."Salvage Value" := TempBuffer2."Salvage Value";
                    gGenJnlLine."Depr. until FA Posting Date" := TempBuffer2."Depr. until FA Posting Date";
                    gGenJnlLine."Depr. Acquisition Cost" := TempBuffer2."Depr. Acquisition Cost";
                    gGenJnlLine."Maintenance Code" := TempBuffer2."Maintenance Code";
                    gGenJnlLine."Insurance No." := TempBuffer2."Insurance No.";
                    gGenJnlLine."Budgeted FA No." := TempBuffer2."Budgeted FA No.";
                    gGenJnlLine."Duplicate in Depreciation Book" := TempBuffer2."Duplicate in Depreciation Book";
                    gGenJnlLine."Use Duplication List" := TempBuffer2."Use Duplication List";
                END;

                RungcGenJnlPostLine(gGenJnlLine);//, TempBuffer2."Dimension Entry No.");
                                                 // if FAInsertDiscountAmount(TempBuffer2, DeprBook) THEN
                                                 //     FAPostDiscountAmount(
                                                 //         gGenJnlLine,
                                                 //         TempBuffer2."Line Discount Amount" + TempBuffer2."Inv. Discount Amount",
                                                 //         TempBuffer2."Line Discount Amt. (ACY)" + TempBuffer2."Inv. Discount Amt. (ACY)",
                                                 //         TempBuffer2."Dimension Entry No.");
                gGenJnlLine."Account Type" := gGenJnlLine."Account Type"::"G/L Account";
                gGenJnlLine.VALIDATE("FA Posting Type", gGenJnlLine."FA Posting Type"::" ");
                // if FAInsertDiscountAmount(TempBuffer2, DeprBook) THEN
                //     PostDiscount(
                //         TempBuffer2."FA Discount Account",
                //         (TempBuffer2."Line Discount Amount" + TempBuffer2."Inv. Discount Amount"),
                //         (TempBuffer2."Line Discount Amt. (ACY)" + TempBuffer2."Inv. Discount Amt. (ACY)"),
                //         TempBuffer2."Dimension Entry No.");
                if (TempBuffer2."Line Discount Amount" <> 0) OR
                (TempBuffer2."Line Discount Amt. (ACY)" <> 0)
                THEN
                    PostDiscount(
                        TempBuffer2."Line Discount Account",
                        -TempBuffer2."Line Discount Amount",
                        -TempBuffer2."Line Discount Amt. (ACY)",
                        TempBuffer2."Dimension Entry No.", lPurchHeader);
                if (TempBuffer2."Inv. Discount Amount" <> 0) OR
                (TempBuffer2."Inv. Discount Amt. (ACY)" <> 0)
                THEN
                    PostDiscount(
                        TempBuffer2."Inv. Discount Account",
                        -TempBuffer2."Inv. Discount Amount",
                        -TempBuffer2."Inv. Discount Amt. (ACY)",
                        TempBuffer2."Dimension Entry No.", lPurchHeader);
                if TempBuffer2."Pmt. Discount Amount" <> 0 THEN
                    PostDiscount(
                        TempBuffer2."Pmt. Discount Account",
                        -TempBuffer2."Pmt. Discount Amount",
                        -TempBuffer2."Src. Curr. Pmt. Discount Amt.",
                        TempBuffer2."Dimension Entry No.", lPurchHeader);
            UNTIL TempBuffer2.Next(-1) = 0;

        TempBuffer2.DELETEALL;

        // Check External Document number
        // {if gPurchSetup."Ext. Doc. No. Mandatory" OR
        // (gGenJnlLineExtDocNo <> '')
        // THEN BEGIN
        // VendLedgEntry.RESET;
        // VendLedgEntry.SETCURRENTKEY("External Document No.");
        // VendLedgEntry.SETRANGE("Document Type",gGenJnlLineDocType);
        // VendLedgEntry.SETRANGE("External Document No.",gGenJnlLineExtDocNo);
        // VendLedgEntry.SETRANGE("Vendor No.","Pay-to Vendor No.");
        // if VendLedgEntry.FINDFIRST THEN
        //     ERROR(
        //     Text016,
        //     VendLedgEntry."Document Type",gGenJnlLineExtDocNo);
        // END;}

        // Post vendor entries
        //if GUIALLOWED THEN
        //Window.UPDATE(4,1);
        gGenJnlLine.INIT;
        gGenJnlLine."Posting Date" := FechaAlbaran(pPurcRcptHdr."No.");
        gGenJnlLine."Document Date" := pPurcRcptHdr."Document Date";
        gGenJnlLine.Description := COPYSTR(pPurcRcptHdr."Posting Description", 1, MAXSTRLEN(gGenJnlLine.Description));
        gGenJnlLine."Shortcut Dimension 1 Code" := pPurcRcptHdr."Shortcut Dimension 1 Code";
        gGenJnlLine."Shortcut Dimension 2 Code" := pPurcRcptHdr."Shortcut Dimension 2 Code";
        //ASC
        gGenJnlLine."Shortcut Dimension 3 Code" := pPurcRcptHdr."Shortcut Dimension 3 Code";
        gGenJnlLine."Shortcut Dimension 4 Code" := pPurcRcptHdr."Shortcut Dimension 4 Code";
        gGenJnlLine."Shortcut Dimension 5 Code" := pPurcRcptHdr."Shortcut Dimension 5 Code";
        gGenJnlLine."Dimension Set ID" := pPurcRcptHdr."Dimension Set ID";
        gGenJnlLine.Circuito := TRUE;
        gGenJnlLine."Reason Code" := pPurcRcptHdr."Reason Code";
        gGenJnlLine."Account Type" := gGenJnlLine."Account Type"::"G/L Account";
        lVendor.GET(pPurcRcptHdr."Pay-to Vendor No.");
        lVendorPostingGroup.GET(lVendor."Vendor Posting Group");
        gGenJnlLine."Account No." := lVendorPostingGroup.FPR;
        gGenJnlLine."Document Type" := gGenJnlLine."Document Type"::Receipt;
        gGenJnlLine."Document No." := lCGenJnlLineDocNo;
        gGenJnlLine."Tax Area Code" := lCGenJnlLineDocNo;
        gGenJnlLine."External Document No." := ltGenJnlLineExtDocNo;
        gGenJnlLine."Currency Code" := pPurcRcptHdr."Currency Code";
        gGenJnlLine.Amount := lDTotal;
        gGenJnlLine."Source Currency Code" := pPurcRcptHdr."Currency Code";
        gGenJnlLine."Source Currency Amount" := lDTotal;
        gGenJnlLine."Amount (LCY)" := lDTotalACY;
        if lPurchHeader."Currency Code" = '' THEN
            gGenJnlLine."Currency Factor" := 1
        ELSE
            gGenJnlLine."Currency Factor" := lPurchHeader."Currency Factor";
        gGenJnlLine."Sales/Purch. (LCY)" := lDTotalACY;
        gGenJnlLine.Correction := pPurcRcptHdr.Correction;
        gGenJnlLine."Inv. Discount (LCY)" := gTotalPurchaseLineLCY."Inv. Discount Amount";
        gGenJnlLine."Pmt. Discount Given/Rec. (LCY)" := gTotalPurchaseLineLCY."Pmt. Discount Amount";
        gGenJnlLine."Sell-to/Buy-from No." := pPurcRcptHdr."Buy-from Vendor No.";
        gGenJnlLine."Bill-to/Pay-to No." := pPurcRcptHdr."Pay-to Vendor No.";
        gGenJnlLine."Salespers./Purch. Code" := pPurcRcptHdr."Purchaser Code";
        gGenJnlLine."System-Created Entry" := TRUE;
        gGenJnlLine."On Hold" := pPurcRcptHdr."On Hold";
        gGenJnlLine."Applies-to Doc. Type" := pPurcRcptHdr."Applies-to Doc. Type";
        gGenJnlLine."Applies-to Bill No." := pPurcRcptHdr."Applies-to Bill No.";
        gGenJnlLine."Applies-to Doc. No." := pPurcRcptHdr."Applies-to Doc. No.";
        gGenJnlLine."Applies-to ID" := '';
        gGenJnlLine."Allow Application" := pPurcRcptHdr."Bal. Account No." = '';
        gGenJnlLine."Payment Terms Code" := pPurcRcptHdr."Payment Terms Code";
        gGenJnlLine."Payment Method Code" := pPurcRcptHdr."Payment Method Code";
#if not CLEAN22
        // TODO: - CLEAN22
#if not CLEAN27
        gGenJnlLine."Pmt. Address Code" := pPurcRcptHdr."Pay-at Code";
#endif
        // TODO: - CLEAN22
#endif
        gGenJnlLine."Recipient Bank Account" := pPurcRcptHdr."Vendor Bank Acc. Code";
        gGenJnlLine."Due Date" := pPurcRcptHdr."Due Date";
        //gGenJnlLine."Pmt. Discount Date" := "Pmt. Discount Date";
        gGenJnlLine."Payment Discount %" := pPurcRcptHdr."Payment Discount %";
        gGenJnlLine."Source Type" := gGenJnlLine."Source Type"::Vendor;
        gGenJnlLine."Source No." := pPurcRcptHdr."Pay-to Vendor No.";
        gGenJnlLine."Source Code" := gCSrcCode;
        gGenJnlLine."Posting No. Series" := '';
        gGenJnlLine."IC Partner Code" := '';//"Pay-to IC Partner Code";
        gGenJnlLine."Generate AutoInvoices" := FALSE;//"Generate Autoinvoices" OR "Generate Autocredit Memo";
        gGenJnlLine."AutoDoc. No." := lCAutoDocNo;

        // TempJnlLineDim.DELETEALL;
        // TempDocDim.RESET;
        // TempDocDim.SETRANGE("Table ID", DATABASE::"Purchase Line Archive");
        // gcDimMgt.CopyDocDimToJnlLineDim(TempDocDim, TempJnlLineDim);
        gcGenJnlPostLine.RunWithCheck(gGenJnlLine);

        //  END;
        MESSAGE('Se ha contabilizado el retroceso del albarán %1 con fecha %2', pPurcRcptHdr."No.",
        FORMAT(FechaAlbaran(pPurcRcptHdr."No."), 0, '<Day,2>/<Month,2>/<Year>'));
        pPurcRcptHdr.Contabilizado := FALSE;
        pPurcRcptHdr.MODIFY;
    end;

#pragma warning restore AL0432 // TODO: - Invoice Posting Buffer codunit 825
    internal procedure UpdatePurchLine2(pPurchLine: Record "Purchase Line"; pDUndoQty: Decimal; pDUndoQtyBase: Decimal)
    var
        lPurchaseLine: Record "Purchase Line";

    begin


        WITH pPurchLine DO BEGIN
            lPurchaseLine := pPurchLine;
            CASE "Document Type" OF
                "Document Type"::"Return Order":
                    BEGIN
                        "Return Qty. Shipped" := "Return Qty. Shipped" - pDUndoQty;
                        "Return Qty. Shipped (Base)" := "Return Qty. Shipped (Base)" - pDUndoQtyBase;
                        InitOutstanding;
                        InitQtyToShip;
                    END;
                "Document Type"::Order:
                    BEGIN
                        "Quantity Received" := "Quantity Received" - pDUndoQty;
                        "Qty. Received (Base)" := "Qty. Received (Base)" - pDUndoQtyBase;
                        InitOutstanding;
                        InitQtyToReceive;
                    END;
                ELSE
                    FIELDERROR("Document Type");
            END;
            MODIFY;
        END;
    end;

#pragma warning disable AL0432 // TODO: - Invoice Posting Buffer codunit 825
    internal procedure ContabilizarFacAlbaranes(pPurcRcptHdr: Record "Purch. Rcpt. Header")
    Var
        lCAutoDocNo: Code[20];
        lPurchRcptLineTMP: Record "Purch. Rcpt. Line" temporary;
        lPurchRcptLineACY: Record "Purch. Rcpt. Line";
        ItemChargeAssgntPurch: Record "Item Charge Assignment (Purch)";
        // TempJnlLineDim: Record "Journal Line Dimension";
        lVendor: Record "Vendor";
        lSalesSetup: Record "Sales & Receivables Setup";
        lDDiscountVATAmount: Decimal;
        lVendorPostingGroup: Record "Vendor Posting Group";
        lDTotal: Decimal;
        lDTotalACY: Decimal;
        lPurchHeader: Record "Purchase Header";
        liGenJnlLineDocType: Integer;
        lCGenJnlLineDocNo: Code[20];
        ltGenJnlLineExtDocNo: Code[30];
        liLinecount: Integer;
        TempBuffer: Record "Invoice Posting Buffer" temporary;
        TempBuffer2: Record "Invoice Posting Buffer" temporary;
        FALineNo: Integer;

    begin

        WITH pPurcRcptHdr DO BEGIN
            if Not lPurchHeader.Get(lPurchHeader."Document Type"::Order, "Order No.") Then lPurchHeader.Init();
            if Facturado THEN ERROR(glNoDebefacturado);
            liGenJnlLineDocType := 0;
            lCGenJnlLineDocNo := "No.";
            ltGenJnlLineExtDocNo := "Vendor Shipment No.";
            lDTotal := 0;
            lDTotalACY := 0;
            lPurchRcptLineTMP.SETRANGE(lPurchRcptLineTMP."Document No.", pPurcRcptHdr."No.");
            DesglosarAlbaranes(pPurcRcptHdr, lPurchRcptLineTMP);
            if lPurchRcptLineTMP.FINDFIRST THEN
                REPEAT
                    if (lPurchRcptLineTMP.Type.AsInteger() >= lPurchRcptLineTMP.Type::"G/L Account".AsInteger()) AND (lPurchRcptLineTMP."Qty. Rcd. Not Invoiced" <> 0) THEN BEGIN
                        // Copy purchase to Buffer
                        if NOT lPurchRcptLineACY.GET(lPurchRcptLineTMP."Document No.", lPurchRcptLineTMP."Line No.") THEN
                            lPurchRcptLineACY := lPurchRcptLineTMP;
                        // DocDim.SETRANGE(DocDim."Table ID", "Purchase Line");
                        // DocDim.SETRANGE(DocDim."Document Type", DocDim."Document Type"::Order);
                        // DocDim.SETRANGE(DocDim."Document No.", lPurchRcptLineTMP."Order No.");
                        // DocDim.SETRANGE(DocDim."Line No.", lPurchRcptLineTMP."Order Line No.");
                        // if DocDim.FINDFIRST THEN
                        //     REPEAT
                        //         TempDocDim := DocDim;
                        //         if TempDocDim.INSERT THEN;
                        //     UNTIL DocDim.NEXT = 0;

                        FillFacPostingBuffer(lPurchRcptLineTMP, lPurchRcptLineTMP."Order Line No.", TempBuffer);
                        UpdInvPostingBuldFFeProduccionesgloNew(TempBuffer, FALineNo, TempBuffer2);
                        // TempDocDim.SETRANGE("Table ID");
                        // TempDocDim.SETRANGE("Line No.");
                    END;
                UNTIL lPurchRcptLineTMP.NEXT = 0;
            // Post purchase and VAT to G/L entries from Buffer
            liLinecount := 0;
            TempBuffer2.RESET;
            if TempBuffer2.FIND('+') THEN
                REPEAT
                    liLinecount := liLinecount + 1;
                    //if GUIALLOWED THEN
                    //Window.UPDATE(3,liLinecount);

                    CASE TempBuffer2."VAT Calculation Type" OF
                        TempBuffer2."VAT Calculation Type"::"Reverse Charge VAT":
                            BEGIN
                                gVATPostingSetup.GET(
                                    TempBuffer2."VAT Bus. Posting Group", TempBuffer2."VAT Prod. Posting Group");
                                TempBuffer2."VAT Amount" :=
                                    ROUND(
                                    (TempBuffer2.Amount -
                                    TempBuffer2."Line Discount Amount" -
                                    TempBuffer2."Inv. Discount Amount" -
                                    TempBuffer2."Pmt. Discount Amount") *
                                    gVATPostingSetup."VAT+EC %" / 100);
                                TempBuffer2."VAT Amount (ACY)" :=
                                    ROUND(
                                    (TempBuffer2."Amount (ACY)" -
                                    TempBuffer2."Line Discount Amt. (ACY)" -
                                    TempBuffer2."Inv. Discount Amt. (ACY)" -
                                    TempBuffer2."Src. Curr. Pmt. Discount Amt.") *
                                    gVATPostingSetup."VAT+EC %" / 100, gCurrency."Amount Rounding Precision");
                            END;
                        TempBuffer2."VAT Calculation Type"::"Sales Tax":
                            BEGIN
                                if TempBuffer2."Use Tax" THEN BEGIN
                                    TempBuffer2."VAT Amount" :=
                                    ROUND(
                                        gcSalesTaxCalculate.CalculateTax(
                                        TempBuffer2."Tax Area Code", TempBuffer2."Tax Group Code",
                                        TempBuffer2."Tax Liable", lPurchHeader."Posting Date",
                                        TempBuffer2.Amount -
                                        TempBuffer2."Line Discount Amount" - TempBuffer2."Inv. Discount Amount" -
                                        TempBuffer2."Pmt. Discount Amount",
                                        TempBuffer2.Quantity, 0));
                                    if gGenLedgerSetup."Additional Reporting Currency" <> '' THEN
                                        TempBuffer2."VAT Amount (ACY)" :=
                                        gCurrExchRate.ExchangeAmtLCYToFCY(
                                            lPurchHeader."Posting Date", gGenLedgerSetup."Additional Reporting Currency",
                                            TempBuffer2."VAT Amount", 0);
                                END;
                            END;
                    END;

                    if lPurchHeader."Prices Including VAT" AND (TempBuffer2."VAT %" <> 0) THEN
                        WITH TempBuffer2 DO BEGIN
                            lDDiscountVATAmount :=
                            ROUND("Line Discount Amount" * "VAT %" / (1 + "VAT %" / 100) / 100);
                            Amount := Amount - lDDiscountVATAmount;
                            "Line Discount Amount" := "Line Discount Amount" - lDDiscountVATAmount;

                            lDDiscountVATAmount :=
                            ROUND(
                                "Line Discount Amt. (ACY)" * "VAT %" / (1 + "VAT %" / 100) / 100,
                                gCurrency."Amount Rounding Precision");
                            "Amount (ACY)" := "Amount (ACY)" - lDDiscountVATAmount;
                            "Line Discount Amt. (ACY)" := "Line Discount Amt. (ACY)" - lDDiscountVATAmount;

                            lDDiscountVATAmount :=
                            ROUND("Inv. Discount Amount" * "VAT %" / (1 + "VAT %" / 100) / 100);
                            Amount := Amount - lDDiscountVATAmount;
                            "Inv. Discount Amount" := "Inv. Discount Amount" - lDDiscountVATAmount;

                            lDDiscountVATAmount :=
                            ROUND(
                                "Src. Curr. Pmt. Discount Amt." * "VAT %" / (1 + "VAT %" / 100) / 100,
                                gCurrency."Amount Rounding Precision");
                            "Amount (ACY)" := "Amount (ACY)" - lDDiscountVATAmount;
                            "Inv. Discount Amt. (ACY)" := "Inv. Discount Amt. (ACY)" - lDDiscountVATAmount;

                            lDDiscountVATAmount :=
                            ROUND(
                                "Inv. Discount Amt. (ACY)" * "VAT %" / (1 + "VAT %" / 100) / 100,
                                gCurrency."Amount Rounding Precision");
                            "Amount (ACY)" := "Amount (ACY)" - lDDiscountVATAmount;
                            "Inv. Discount Amt. (ACY)" := "Inv. Discount Amt. (ACY)" - lDDiscountVATAmount;
                        END;

                    gGenJnlLine.INIT;
                    gGenJnlLine."Posting Date" := "Posting Date";
                    gGenJnlLine."Document Date" := "Document Date";
                    gGenJnlLine.Description := COPYSTR("Posting Description", 1, MAXSTRLEN(gGenJnlLine.Description));
                    gGenJnlLine."Reason Code" := "Reason Code";
                    gGenJnlLine."Document Type" := gGenJnlLine."Document Type"::Receipt;
                    gGenJnlLine."Document No." := "No.";
                    gGenJnlLine."External Document No." := pPurcRcptHdr."Vendor Shipment No.";
                    gGenJnlLine."Account No." := TempBuffer2."G/L Account";
                    gGenJnlLine."System-Created Entry" := TempBuffer2."System-Created Entry";
                    gGenJnlLine.Amount := TempBuffer2.Amount;
                    lDTotal := lDTotal + TempBuffer2.Amount;
                    gGenJnlLine."Source Currency Code" := "Currency Code";
                    gGenJnlLine."Source Currency Amount" := TempBuffer2."Amount (ACY)";
                    lDTotalACY := lDTotalACY + TempBuffer2."Amount (ACY)";
                    gGenJnlLine.Correction := Correction;
                    gGenJnlLine."Gen. Posting Type" := gGenJnlLine."Gen. Posting Type"::" ";
                    gGenJnlLine."Gen. Bus. Posting Group" := '';//TempBuffer2."Gen. Bus. Posting Group";
                    gGenJnlLine."Gen. Prod. Posting Group" := '';// TempBuffer2."Gen. Prod. Posting Group";
                    gGenJnlLine."VAT Bus. Posting Group" := '';//TempBuffer2."VAT Bus. Posting Group";
                    gGenJnlLine."VAT Prod. Posting Group" := '';//TempBuffer2."VAT Prod. Posting Group";
                    gGenJnlLine."Tax Area Code" := TempBuffer2."Tax Area Code";
                    gGenJnlLine."Tax Liable" := TempBuffer2."Tax Liable";
                    gGenJnlLine."Tax Group Code" := TempBuffer2."Tax Group Code";
                    gGenJnlLine."Use Tax" := TempBuffer2."Use Tax";
                    gGenJnlLine.Quantity := TempBuffer2.Quantity;
                    gGenJnlLine."VAT Calculation Type" := TempBuffer2."VAT Calculation Type";
                    gGenJnlLine."VAT Base Amount" := TempBuffer2."VAT Base Amount";
                    gGenJnlLine."VAT Base Discount %" := "VAT Base Discount %";
                    gGenJnlLine."Source Curr. VAT Base Amount" := TempBuffer2."VAT Base Amount (ACY)";
                    gGenJnlLine."VAT Amount" := -TempBuffer2."VAT Amount";
                    gGenJnlLine."Source Curr. VAT Amount" := TempBuffer2."VAT Amount (ACY)";
                    gGenJnlLine."VAT Difference" := TempBuffer2."VAT Difference";
                    gGenJnlLine."VAT Posting" := gGenJnlLine."VAT Posting"::"Manual VAT Entry";
                    gGenJnlLine."Shortcut Dimension 1 Code" := TempBuffer2."Global Dimension 1 Code";
                    gGenJnlLine."Shortcut Dimension 2 Code" := TempBuffer2."Global Dimension 2 Code";
                    //ASC
                    gGenJnlLine."Shortcut Dimension 3 Code" := TempBuffer2."Global Dimension 3 Code";
                    gGenJnlLine."Shortcut Dimension 4 Code" := TempBuffer2."Global Dimension 4 Code";
                    gGenJnlLine."Shortcut Dimension 5 Code" := TempBuffer2."Global Dimension 5 Code";
                    gGenJnlLine."Dimension Set ID" := TempBuffer2."Dimension Set ID";
                    gGenJnlLine.Circuito := TRUE;
                    gGenJnlLine."Job No." := TempBuffer2."Job No.";
                    gGenJnlLine."Source Code" := gCSrcCode;
                    gGenJnlLine."Sell-to/Buy-from No." := "Buy-from Vendor No.";
                    gGenJnlLine."Bill-to/Pay-to No." := "Pay-to Vendor No.";
                    gGenJnlLine."Country/Region Code" := "VAT Country/Region Code";
                    gGenJnlLine."VAT Registration No." := "VAT Registration No.";
                    gGenJnlLine."Source Type" := gGenJnlLine."Source Type"::Vendor;
                    gGenJnlLine."Source No." := "Pay-to Vendor No.";
                    gGenJnlLine."Posting No. Series" := '';
                    gGenJnlLine."IC Partner Code" := '';//"Pay-to IC Partner Code";
                    gGenJnlLine."Ship-to/Order Address Code" := "Order Address Code";

                    gGenJnlLine."Payment Terms Code" := "Payment Terms Code";
                    gGenJnlLine."Payment Method Code" := "Payment Method Code";

                    gGenJnlLine."Generate AutoInvoices" := FALSE;//"Generate Autoinvoices" OR "Generate Autocredit Memo";
                    gGenJnlLine."AutoDoc. No." := lCAutoDocNo;

                    if TempBuffer2.Type = TempBuffer2.Type::"Fixed Asset" THEN BEGIN
                        gGenJnlLine."Account Type" := gGenJnlLine."Account Type"::"Fixed Asset";
                        if TempBuffer2."FA Posting Type" =
                            TempBuffer2."FA Posting Type"::"Acquisition Cost"
                        THEN
                            gGenJnlLine."FA Posting Type" := gGenJnlLine."FA Posting Type"::"Acquisition Cost";
                        if TempBuffer2."FA Posting Type" =
                            TempBuffer2."FA Posting Type"::Maintenance
                        THEN
                            gGenJnlLine."FA Posting Type" := gGenJnlLine."FA Posting Type"::Maintenance;
                        gGenJnlLine."FA Posting Date" := TempBuffer2."FA Posting Date";
                        gGenJnlLine."Depreciation Book Code" := TempBuffer2."Depreciation Book Code";
                        gGenJnlLine."Salvage Value" := TempBuffer2."Salvage Value";
                        gGenJnlLine."Depr. until FA Posting Date" := TempBuffer2."Depr. until FA Posting Date";
                        gGenJnlLine."Depr. Acquisition Cost" := TempBuffer2."Depr. Acquisition Cost";
                        gGenJnlLine."Maintenance Code" := TempBuffer2."Maintenance Code";
                        gGenJnlLine."Insurance No." := TempBuffer2."Insurance No.";
                        gGenJnlLine."Budgeted FA No." := TempBuffer2."Budgeted FA No.";
                        gGenJnlLine."Duplicate in Depreciation Book" := TempBuffer2."Duplicate in Depreciation Book";
                        gGenJnlLine."Use Duplication List" := TempBuffer2."Use Duplication List";
                    END;

                    RungcGenJnlPostLine(gGenJnlLine);//, TempBuffer2."Dimension Entry No.");
                    // if FAInsertDiscountAmount(TempBuffer2, DeprBook) THEN
                    //     FAPostDiscountAmount(
                    //         gGenJnlLine,
                    //         TempBuffer2."Line Discount Amount" + TempBuffer2."Inv. Discount Amount",
                    //         TempBuffer2."Line Discount Amt. (ACY)" + TempBuffer2."Inv. Discount Amt. (ACY)",
                    //         TempBuffer2."Dimension Entry No.");
                    gGenJnlLine."Account Type" := gGenJnlLine."Account Type"::"G/L Account";
                    gGenJnlLine.VALIDATE("FA Posting Type", gGenJnlLine."FA Posting Type"::" ");
                    // if FAInsertDiscountAmount(TempBuffer2, DeprBook) THEN
                    //     PostDiscount(
                    //         TempBuffer2."FA Discount Account",
                    //         -(TempBuffer2."Line Discount Amount" + TempBuffer2."Inv. Discount Amount"),
                    //         -(TempBuffer2."Line Discount Amt. (ACY)" + TempBuffer2."Inv. Discount Amt. (ACY)"),
                    //         TempBuffer2."Dimension Entry No.", lPurchHeader);
                    if (TempBuffer2."Line Discount Amount" <> 0) OR
                    (TempBuffer2."Line Discount Amt. (ACY)" <> 0)
                    THEN
                        PostDiscount(
                            TempBuffer2."Line Discount Account",
                            TempBuffer2."Line Discount Amount",
                            TempBuffer2."Line Discount Amt. (ACY)",
                            TempBuffer2."Dimension Entry No.", lPurchHeader);
                    if (TempBuffer2."Inv. Discount Amount" <> 0) OR
                    (TempBuffer2."Inv. Discount Amt. (ACY)" <> 0)
                    THEN
                        PostDiscount(
                            TempBuffer2."Inv. Discount Account",
                            TempBuffer2."Inv. Discount Amount",
                            TempBuffer2."Inv. Discount Amt. (ACY)",
                            TempBuffer2."Dimension Entry No.", lPurchHeader);
                    if TempBuffer2."Pmt. Discount Amount" <> 0 THEN
                        PostDiscount(
                            TempBuffer2."Pmt. Discount Account",
                            TempBuffer2."Pmt. Discount Amount",
                            TempBuffer2."Src. Curr. Pmt. Discount Amt.",
                            TempBuffer2."Dimension Entry No.", lPurchHeader);
                UNTIL TempBuffer2.Next(-1) = 0;

            TempBuffer2.DELETEALL;

            // Check External Document number
            // {if gPurchSetup."Ext. Doc. No. Mandatory" OR
            // (gGenJnlLineExtDocNo <> '')
            // THEN BEGIN
            // VendLedgEntry.RESET;
            // VendLedgEntry.SETCURRENTKEY("External Document No.");
            // VendLedgEntry.SETRANGE("Document Type",gGenJnlLineDocType);
            // VendLedgEntry.SETRANGE("External Document No.",gGenJnlLineExtDocNo);
            // VendLedgEntry.SETRANGE("Vendor No.","Pay-to Vendor No.");
            // if VendLedgEntry.FINDFIRST THEN
            // ERROR(
            //     Text016,
            //     VendLedgEntry."Document Type",gGenJnlLineExtDocNo);
            // END;}

            // Post vendor entries
            //if GUIALLOWED THEN
            //Window.UPDATE(4,1);
            gGenJnlLine.INIT;
            gGenJnlLine."Posting Date" := "Posting Date";
            gGenJnlLine."Document Date" := "Document Date";
            gGenJnlLine.Description := COPYSTR("Posting Description", 1, MAXSTRLEN(gGenJnlLine.Description));
            gGenJnlLine."Shortcut Dimension 1 Code" := "Shortcut Dimension 1 Code";
            gGenJnlLine."Shortcut Dimension 2 Code" := "Shortcut Dimension 2 Code";
            //ASC
            gGenJnlLine."Shortcut Dimension 3 Code" := "Shortcut Dimension 3 Code";
            gGenJnlLine."Shortcut Dimension 4 Code" := "Shortcut Dimension 4 Code";
            gGenJnlLine."Shortcut Dimension 5 Code" := "Shortcut Dimension 5 Code";
            gGenJnlLine."Dimension Set ID" := "Dimension Set ID";
            gGenJnlLine."Reason Code" := "Reason Code";
            gGenJnlLine."Account Type" := gGenJnlLine."Account Type"::Vendor;
            gGenJnlLine.Circuito := TRUE;
            //   Vendor.GET("Pay-to Vendor No.");
            //    lVendorPostingGroup.GET(Vendor."Vendor Posting Group");
            gGenJnlLine."Account No." := "Pay-to Vendor No.";
            gGenJnlLine."Document Type" := gGenJnlLine."Document Type"::Receipt;
            gGenJnlLine."Document No." := lCGenJnlLineDocNo;
            gGenJnlLine."External Document No." := ltGenJnlLineExtDocNo;
            gGenJnlLine."Currency Code" := "Currency Code";
            gGenJnlLine.Amount := -lDTotal;
            gGenJnlLine."Source Currency Code" := "Currency Code";
            gGenJnlLine."Source Currency Amount" := -lDTotal;
            gGenJnlLine."Amount (LCY)" := -lDTotalACY;
            if lPurchHeader."Currency Code" = '' THEN
                gGenJnlLine."Currency Factor" := 1
            ELSE
                gGenJnlLine."Currency Factor" := lPurchHeader."Currency Factor";
            gGenJnlLine."Sales/Purch. (LCY)" := -lDTotalACY;
            gGenJnlLine.Correction := Correction;
            gGenJnlLine."Inv. Discount (LCY)" := -gTotalPurchaseLineLCY."Inv. Discount Amount";
            gGenJnlLine."Pmt. Discount Given/Rec. (LCY)" := -gTotalPurchaseLineLCY."Pmt. Discount Amount";
            gGenJnlLine."Sell-to/Buy-from No." := "Buy-from Vendor No.";
            gGenJnlLine."Bill-to/Pay-to No." := "Pay-to Vendor No.";
            gGenJnlLine."Salespers./Purch. Code" := "Purchaser Code";
            gGenJnlLine."System-Created Entry" := TRUE;
            gGenJnlLine."On Hold" := "On Hold";
            gGenJnlLine."Applies-to Doc. Type" := "Applies-to Doc. Type";
            gGenJnlLine."Applies-to Bill No." := "Applies-to Bill No.";
            gGenJnlLine."Applies-to Doc. No." := "Applies-to Doc. No.";
            gGenJnlLine."Applies-to ID" := '';
            gGenJnlLine."Allow Application" := "Bal. Account No." = '';
            gGenJnlLine."Payment Terms Code" := "Payment Terms Code";
            gGenJnlLine."Payment Method Code" := "Payment Method Code";
#if not CLEAN22
            // TODO: - CLEAN22
#if not CLEAN27
            gGenJnlLine."Pmt. Address Code" := "Pay-at Code";
#endif
            // TODO: - CLEAN22
#endif
            gGenJnlLine."Recipient Bank Account" := "Vendor Bank Acc. Code";
            gGenJnlLine."Due Date" := "Due Date";
            //gGenJnlLine."Pmt. Discount Date" := "Pmt. Discount Date";
            gGenJnlLine."Payment Discount %" := "Payment Discount %";
            gGenJnlLine."Source Type" := gGenJnlLine."Source Type"::Vendor;
            gGenJnlLine."Source No." := "Pay-to Vendor No.";
            gGenJnlLine."Source Code" := gCSrcCode;
            gGenJnlLine."Posting No. Series" := '';
            gGenJnlLine."IC Partner Code" := '';//"Pay-to IC Partner Code";
            gGenJnlLine."Generate AutoInvoices" := FALSE;//"Generate Autoinvoices" OR "Generate Autocredit Memo";
            gGenJnlLine."AutoDoc. No." := lCAutoDocNo;

            // TempJnlLineDim.DELETEALL;
            // TempDocDim.RESET;
            // TempDocDim.SETRANGE("Table ID", DATABASE::"Purch. Rcpt. Header");
            // gcDimMgt.CopyDocDimToJnlLineDim(TempDocDim, TempJnlLineDim);
            gcGenJnlPostLine.RunWithCheck(gGenJnlLine);//, TempJnlLineDim);

            lVendor.GET("Pay-to Vendor No.");
            if lVendor."Generar Cartera Albarán" THEN BEGIN
                gGenJnlLine.INIT;
                gGenJnlLine."Posting Date" := "Posting Date";
                gGenJnlLine."Document Date" := "Document Date";
                gGenJnlLine.Description := COPYSTR("Posting Description", 1, MAXSTRLEN(gGenJnlLine.Description));
                gGenJnlLine."Shortcut Dimension 1 Code" := "Shortcut Dimension 1 Code";
                gGenJnlLine."Shortcut Dimension 2 Code" := "Shortcut Dimension 2 Code";
                //ASC
                gGenJnlLine."Shortcut Dimension 3 Code" := "Shortcut Dimension 3 Code";
                gGenJnlLine."Shortcut Dimension 4 Code" := "Shortcut Dimension 4 Code";
                gGenJnlLine."Shortcut Dimension 5 Code" := "Shortcut Dimension 5 Code";
                gGenJnlLine."Dimension Set ID" := "Dimension Set ID";
                gGenJnlLine.Circuito := TRUE;
                gGenJnlLine."Reason Code" := "Reason Code";
                gGenJnlLine."Account Type" := gGenJnlLine."Account Type"::Vendor;
                //   Vendor.GET("Pay-to Vendor No.");
                //    lVendorPostingGroup.GET(Vendor."Vendor Posting Group");
                gGenJnlLine."Account No." := "Pay-to Vendor No.";
                gGenJnlLine."Document Type" := gGenJnlLine."Document Type"::Payment;
                gGenJnlLine."Document No." := lCGenJnlLineDocNo;
                gGenJnlLine."External Document No." := ltGenJnlLineExtDocNo;
                gGenJnlLine."Currency Code" := "Currency Code";
                gGenJnlLine.Amount := lDTotal;
                gGenJnlLine."Source Currency Code" := "Currency Code";
                gGenJnlLine."Source Currency Amount" := lDTotal;
                gGenJnlLine."Amount (LCY)" := lDTotalACY;
                if lPurchHeader."Currency Code" = '' THEN
                    gGenJnlLine."Currency Factor" := 1
                ELSE
                    gGenJnlLine."Currency Factor" := lPurchHeader."Currency Factor";
                gGenJnlLine."Sales/Purch. (LCY)" := lDTotalACY;
                gGenJnlLine.Correction := Correction;
                gGenJnlLine."Inv. Discount (LCY)" := gTotalPurchaseLineLCY."Inv. Discount Amount";
                gGenJnlLine."Pmt. Discount Given/Rec. (LCY)" := gTotalPurchaseLineLCY."Pmt. Discount Amount";
                gGenJnlLine."Sell-to/Buy-from No." := "Buy-from Vendor No.";
                gGenJnlLine."Bill-to/Pay-to No." := "Pay-to Vendor No.";
                gGenJnlLine."Salespers./Purch. Code" := "Purchaser Code";
                gGenJnlLine."System-Created Entry" := TRUE;
                gGenJnlLine."On Hold" := "On Hold";
                gGenJnlLine."Applies-to Doc. Type" := gGenJnlLine."Applies-to Doc. Type"::Receipt;
                gGenJnlLine."Applies-to Bill No." := '';
                gGenJnlLine."Applies-to Doc. No." := lCGenJnlLineDocNo;
                gGenJnlLine."Applies-to ID" := '';
                gGenJnlLine."Allow Application" := "Bal. Account No." = '';
                gGenJnlLine."Payment Terms Code" := "Payment Terms Code";
                gGenJnlLine."Payment Method Code" := "Payment Method Code";
#if not CLEAN22
                // TODO: - CLEAN22
#if not CLEAN27
                gGenJnlLine."Pmt. Address Code" := "Pay-at Code";
#endif
                // TODO: - CLEAN22
#endif
                gGenJnlLine."Recipient Bank Account" := "Vendor Bank Acc. Code";
                gGenJnlLine."Due Date" := "Due Date";
                //gGenJnlLine."Pmt. Discount Date" := "Pmt. Discount Date";
                gGenJnlLine."Payment Discount %" := "Payment Discount %";
                gGenJnlLine."Source Type" := gGenJnlLine."Source Type"::Vendor;
                gGenJnlLine."Source No." := "Pay-to Vendor No.";
                gGenJnlLine."Source Code" := gCSrcCode;
                gGenJnlLine."Posting No. Series" := '';
                gGenJnlLine."IC Partner Code" := '';//"Pay-to IC Partner Code";
                gGenJnlLine."Generate AutoInvoices" := FALSE;//"Generate Autoinvoices" OR "Generate Autocredit Memo";
                gGenJnlLine."AutoDoc. No." := lCAutoDocNo;
                gGenJnlLine.Banco := lVendor.Banco;
                // TempJnlLineDim.DELETEALL;
                // TempDocDim.RESET;
                // TempDocDim.SETRANGE("Table ID", DATABASE::"Purch. Rcpt. Header");
                // gcDimMgt.CopyDocDimToJnlLineDim(TempDocDim, TempJnlLineDim);
                gcGenJnlPostLine.RunWithCheck(gGenJnlLine);//, TempJnlLineDim);

                gGenJnlLine.INIT;
                gGenJnlLine."Posting Date" := "Posting Date";
                gGenJnlLine."Document Date" := "Document Date";
                gGenJnlLine.Description := COPYSTR("Posting Description", 1, MAXSTRLEN(gGenJnlLine.Description));
                gGenJnlLine."Shortcut Dimension 1 Code" := "Shortcut Dimension 1 Code";
                gGenJnlLine."Shortcut Dimension 2 Code" := "Shortcut Dimension 2 Code";
                //ASC
                gGenJnlLine."Shortcut Dimension 3 Code" := "Shortcut Dimension 3 Code";
                gGenJnlLine."Shortcut Dimension 4 Code" := "Shortcut Dimension 4 Code";
                gGenJnlLine."Shortcut Dimension 5 Code" := "Shortcut Dimension 5 Code";
                gGenJnlLine."Dimension Set ID" := "Dimension Set ID";
                gGenJnlLine.Circuito := TRUE;
                gGenJnlLine."Reason Code" := "Reason Code";
                gGenJnlLine."Account Type" := gGenJnlLine."Account Type"::Vendor;
                //   Vendor.GET("Pay-to Vendor No.");
                //    lVendorPostingGroup.GET(Vendor."Vendor Posting Group");
                gGenJnlLine."Account No." := "Pay-to Vendor No.";
                gGenJnlLine."Document Type" := gGenJnlLine."Document Type"::Bill;
                gGenJnlLine."Document No." := lCGenJnlLineDocNo;
                gGenJnlLine."Bill No." := '1';
                gGenJnlLine."External Document No." := ltGenJnlLineExtDocNo;
                gGenJnlLine."Currency Code" := "Currency Code";
                gGenJnlLine.Amount := -lDTotal;
                gGenJnlLine."Source Currency Code" := "Currency Code";
                gGenJnlLine."Source Currency Amount" := -lDTotal;
                gGenJnlLine."Amount (LCY)" := -lDTotalACY;
                if lPurchHeader."Currency Code" = '' THEN
                    gGenJnlLine."Currency Factor" := 1
                ELSE
                    gGenJnlLine."Currency Factor" := lPurchHeader."Currency Factor";
                gGenJnlLine."Sales/Purch. (LCY)" := -lDTotalACY;
                gGenJnlLine.Correction := Correction;
                gGenJnlLine."Inv. Discount (LCY)" := -gTotalPurchaseLineLCY."Inv. Discount Amount";
                gGenJnlLine."Pmt. Discount Given/Rec. (LCY)" := -gTotalPurchaseLineLCY."Pmt. Discount Amount";
                gGenJnlLine."Sell-to/Buy-from No." := "Buy-from Vendor No.";
                gGenJnlLine."Bill-to/Pay-to No." := "Pay-to Vendor No.";
                gGenJnlLine."Salespers./Purch. Code" := "Purchaser Code";
                gGenJnlLine."System-Created Entry" := TRUE;
                gGenJnlLine."On Hold" := "On Hold";
                gGenJnlLine."Applies-to Doc. Type" := gGenJnlLine."Applies-to Doc. Type"::" ";
                gGenJnlLine."Applies-to Bill No." := '';
                gGenJnlLine."Applies-to Doc. No." := '';
                gGenJnlLine."Applies-to ID" := '';
                gGenJnlLine."Allow Application" := "Bal. Account No." = '';
                gGenJnlLine."Payment Terms Code" := "Payment Terms Code";
                gGenJnlLine."Payment Method Code" := "Payment Method Code";
#if not CLEAN22
                // TODO: - CLEAN22

#if not CLEAN27
                gGenJnlLine."Pmt. Address Code" := "Pay-at Code";
#endif

                // TODO: - CLEAN22
#endif
                gGenJnlLine."Recipient Bank Account" := "Vendor Bank Acc. Code";
                gGenJnlLine."Due Date" := "Due Date";
                //gGenJnlLine."Pmt. Discount Date" := "Pmt. Discount Date";
                gGenJnlLine."Payment Discount %" := "Payment Discount %";
                gGenJnlLine."Source Type" := gGenJnlLine."Source Type"::Vendor;
                gGenJnlLine."Source No." := "Pay-to Vendor No.";
                gGenJnlLine."Source Code" := gCSrcCode;
                gGenJnlLine."Posting No. Series" := '';
                gGenJnlLine."IC Partner Code" := '';//"Pay-to IC Partner Code";
                gGenJnlLine."Generate AutoInvoices" := FALSE;//"Generate Autoinvoices" OR "Generate Autocredit Memo";
                gGenJnlLine."AutoDoc. No." := lCAutoDocNo;
                gGenJnlLine.Banco := Banco;
                // TempJnlLineDim.DELETEALL;
                // TempDocDim.RESET;
                // TempDocDim.SETRANGE("Table ID", DATABASE::"Purch. Rcpt. Header");
                // gcDimMgt.CopyDocDimToJnlLineDim(TempDocDim, TempJnlLineDim);
                gcGenJnlPostLine.RunWithCheck(gGenJnlLine);//, TempJnlLineDim);

            END;
        END;
        MESSAGE('Se ha facturado el albarán %1 con fecha %2', pPurcRcptHdr."No.",
            FORMAT(pPurcRcptHdr."Posting Date", 0, '<Day,2>/<Month,2>/<Year>'));
        // pPurcRcptHdr.Contabilizado:=TRUE;
        // pPurcRcptHdr.Facturado:=FALSE;
        // pPurcRcptHdr.MODIFY;
    end;

    internal procedure DesContabilizarFacAlbaranes(pPurcRcptHdr: Record "Purch. Rcpt. Header")
    var

        lPurchRcptLineTMP: Record "Purch. Rcpt. Line" temporary;
        lDDiscountVATAmount: Decimal;
        lVendorPostingGroup: Record "Vendor Posting Group";
        lDTotal: Decimal;
        lDTotalACY: Decimal;
        lCAutoDocNo: Code[20];
        liGenJnlLineDocType: Integer;
        lCGenJnlLineDocNo: Code[20];
        ltGenJnlLineExtDocNo: Code[30];
        lPurchHeader: Record "Purchase Header";
        liLinecount: Integer;
        TempBuffer: Record "Invoice Posting Buffer" temporary;
        TempBuffer2: Record "Invoice Posting Buffer" temporary;
        FaLineNO: Integer;
    begin

        WITH pPurcRcptHdr DO BEGIN
            if Not lPurchHeader.Get(lPurchHeader."Document Type"::Order, "Order No.") Then lPurchHeader.Init();
            if NOT Facturado THEN Error(glDebefacturado);
            liGenJnlLineDocType := 0;
            lCGenJnlLineDocNo := "No.";
            ltGenJnlLineExtDocNo := "Vendor Shipment No.";
            lDTotal := 0;
            lDTotalACY := 0;
            lPurchRcptLineTMP.SETRANGE(lPurchRcptLineTMP."Document No.", pPurcRcptHdr."No.");
            DesglosarAlbaranes(pPurcRcptHdr, lPurchRcptLineTMP);
            if lPurchRcptLineTMP.FINDFIRST THEN
                REPEAT
                    if (lPurchRcptLineTMP.Type.AsInteger() >= lPurchRcptLineTMP.Type::"G/L Account".AsInteger()) AND (lPurchRcptLineTMP."Qty. Rcd. Not Invoiced" <> 0) THEN BEGIN
                        // Copy purchase to Buffer
                        // PurchLineACY.GET(lPurchRcptLineTMP."Document No.",lPurchRcptLineTMP."Line No.");
                        // DocDim.SETRANGE(DocDim."Table ID", "Purchase Line");
                        // DocDim.SETRANGE(DocDim."Document Type", DocDim."Document Type"::Order);
                        // DocDim.SETRANGE(DocDim."Document No.", lPurchRcptLineTMP."Order No.");
                        // DocDim.SETRANGE(DocDim."Line No.", lPurchRcptLineTMP."Order Line No.");
                        // if DocDim.FINDFIRST THEN
                        //     REPEAT
                        //         TempDocDim := DocDim;
                        //         if TempDocDim.INSERT THEN;
                        //     UNTIL DocDim.NEXT = 0;

                        FillFacPostingBuffer(lPurchRcptLineTMP, lPurchRcptLineTMP."Order Line No.", TempBuffer);
                        UpdInvPostingBuldFFeProduccionesgloNew(TempBuffer, FALineNo, TempBuffer2);
                        // TempDocDim.SETRANGE("Table ID");
                        // TempDocDim.SETRANGE("Line No.");
                    END;
                UNTIL lPurchRcptLineTMP.NEXT = 0;
            // Post purchase and VAT to G/L entries from Buffer
            liLinecount := 0;
            TempBuffer2.RESET;
            if TempBuffer2.FIND('+') THEN
                REPEAT
                    liLinecount := liLinecount + 1;
                    //if GUIALLOWED THEN
                    //Window.UPDATE(3,liLinecount);

                    CASE TempBuffer2."VAT Calculation Type" OF
                        TempBuffer2."VAT Calculation Type"::"Reverse Charge VAT":
                            BEGIN
                                gVATPostingSetup.GET(
                                    TempBuffer2."VAT Bus. Posting Group", TempBuffer2."VAT Prod. Posting Group");
                                TempBuffer2."VAT Amount" :=
                                    ROUND(
                                    (TempBuffer2.Amount -
                                    TempBuffer2."Line Discount Amount" -
                                    TempBuffer2."Inv. Discount Amount" -
                                    TempBuffer2."Pmt. Discount Amount") *
                                    gVATPostingSetup."VAT+EC %" / 100);
                                TempBuffer2."VAT Amount (ACY)" :=
                                    ROUND(
                                    (TempBuffer2."Amount (ACY)" -
                                    TempBuffer2."Line Discount Amt. (ACY)" -
                                    TempBuffer2."Inv. Discount Amt. (ACY)" -
                                    TempBuffer2."Src. Curr. Pmt. Discount Amt.") *
                                    gVATPostingSetup."VAT+EC %" / 100, gCurrency."Amount Rounding Precision");
                            END;
                        TempBuffer2."VAT Calculation Type"::"Sales Tax":
                            BEGIN
                                if TempBuffer2."Use Tax" THEN BEGIN
                                    TempBuffer2."VAT Amount" :=
                                    ROUND(
                                        gcSalesTaxCalculate.CalculateTax(
                                        TempBuffer2."Tax Area Code", TempBuffer2."Tax Group Code",
                                        TempBuffer2."Tax Liable", lPurchHeader."Posting Date",
                                        TempBuffer2.Amount -
                                        TempBuffer2."Line Discount Amount" - TempBuffer2."Inv. Discount Amount" -
                                        TempBuffer2."Pmt. Discount Amount",
                                        TempBuffer2.Quantity, 0));
                                    if gGenLedgerSetup."Additional Reporting Currency" <> '' THEN
                                        TempBuffer2."VAT Amount (ACY)" :=
                                        gCurrExchRate.ExchangeAmtLCYToFCY(
                                            lPurchHeader."Posting Date", gGenLedgerSetup."Additional Reporting Currency",
                                            TempBuffer2."VAT Amount", 0);
                                END;
                            END;
                    END;

                    if lPurchHeader."Prices Including VAT" AND (TempBuffer2."VAT %" <> 0) THEN
                        WITH TempBuffer2 DO BEGIN
                            lDDiscountVATAmount :=
                            ROUND("Line Discount Amount" * "VAT %" / (1 + "VAT %" / 100) / 100);
                            Amount := Amount - lDDiscountVATAmount;
                            "Line Discount Amount" := "Line Discount Amount" - lDDiscountVATAmount;

                            lDDiscountVATAmount :=
                            ROUND(
                                "Line Discount Amt. (ACY)" * "VAT %" / (1 + "VAT %" / 100) / 100,
                                gCurrency."Amount Rounding Precision");
                            "Amount (ACY)" := "Amount (ACY)" - lDDiscountVATAmount;
                            "Line Discount Amt. (ACY)" := "Line Discount Amt. (ACY)" - lDDiscountVATAmount;

                            lDDiscountVATAmount :=
                            ROUND("Inv. Discount Amount" * "VAT %" / (1 + "VAT %" / 100) / 100);
                            Amount := Amount - lDDiscountVATAmount;
                            "Inv. Discount Amount" := "Inv. Discount Amount" - lDDiscountVATAmount;

                            lDDiscountVATAmount :=
                            ROUND(
                                "Src. Curr. Pmt. Discount Amt." * "VAT %" / (1 + "VAT %" / 100) / 100,
                                gCurrency."Amount Rounding Precision");
                            "Amount (ACY)" := "Amount (ACY)" - lDDiscountVATAmount;
                            "Inv. Discount Amt. (ACY)" := "Inv. Discount Amt. (ACY)" - lDDiscountVATAmount;

                            lDDiscountVATAmount :=
                            ROUND(
                                "Inv. Discount Amt. (ACY)" * "VAT %" / (1 + "VAT %" / 100) / 100,
                                gCurrency."Amount Rounding Precision");
                            "Amount (ACY)" := "Amount (ACY)" - lDDiscountVATAmount;
                            "Inv. Discount Amt. (ACY)" := "Inv. Discount Amt. (ACY)" - lDDiscountVATAmount;
                        END;

                    gGenJnlLine.INIT;
                    gGenJnlLine."Posting Date" := "Posting Date";
                    gGenJnlLine."Document Date" := "Document Date";
                    gGenJnlLine.Description := COPYSTR("Posting Description", 1, MAXSTRLEN(gGenJnlLine.Description));
                    gGenJnlLine."Reason Code" := "Reason Code";
                    gGenJnlLine."Document Type" := gGenJnlLine."Document Type"::Receipt;
                    gGenJnlLine."Document No." := "No.";
                    gGenJnlLine."External Document No." := pPurcRcptHdr."Vendor Shipment No.";
                    gGenJnlLine."Account No." := TempBuffer2."G/L Account";
                    gGenJnlLine."System-Created Entry" := TempBuffer2."System-Created Entry";
                    gGenJnlLine.Amount := -TempBuffer2.Amount;
                    lDTotal := lDTotal + TempBuffer2.Amount;
                    gGenJnlLine."Source Currency Code" := "Currency Code";
                    gGenJnlLine."Source Currency Amount" := -TempBuffer2."Amount (ACY)";
                    lDTotalACY := lDTotalACY + TempBuffer2."Amount (ACY)";
                    gGenJnlLine.Correction := Correction;
                    gGenJnlLine."Gen. Posting Type" := gGenJnlLine."Gen. Posting Type"::" ";
                    gGenJnlLine."Gen. Bus. Posting Group" := '';//TempBuffer2."Gen. Bus. Posting Group";
                    gGenJnlLine."Gen. Prod. Posting Group" := '';// TempBuffer2."Gen. Prod. Posting Group";
                    gGenJnlLine."VAT Bus. Posting Group" := '';//TempBuffer2."VAT Bus. Posting Group";
                    gGenJnlLine."VAT Prod. Posting Group" := '';//TempBuffer2."VAT Prod. Posting Group";
                    gGenJnlLine."Tax Area Code" := TempBuffer2."Tax Area Code";
                    gGenJnlLine."Tax Liable" := TempBuffer2."Tax Liable";
                    gGenJnlLine."Tax Group Code" := TempBuffer2."Tax Group Code";
                    gGenJnlLine."Use Tax" := TempBuffer2."Use Tax";
                    gGenJnlLine.Quantity := TempBuffer2.Quantity;
                    gGenJnlLine."VAT Calculation Type" := TempBuffer2."VAT Calculation Type";
                    gGenJnlLine."VAT Base Amount" := TempBuffer2."VAT Base Amount";
                    gGenJnlLine."VAT Base Discount %" := "VAT Base Discount %";
                    gGenJnlLine."Source Curr. VAT Base Amount" := TempBuffer2."VAT Base Amount (ACY)";
                    gGenJnlLine."VAT Amount" := -TempBuffer2."VAT Amount";
                    gGenJnlLine."Source Curr. VAT Amount" := TempBuffer2."VAT Amount (ACY)";
                    gGenJnlLine."VAT Difference" := TempBuffer2."VAT Difference";
                    gGenJnlLine."VAT Posting" := gGenJnlLine."VAT Posting"::"Manual VAT Entry";
                    gGenJnlLine."Shortcut Dimension 1 Code" := TempBuffer2."Global Dimension 1 Code";
                    gGenJnlLine."Shortcut Dimension 2 Code" := TempBuffer2."Global Dimension 2 Code";
                    //ASC
                    gGenJnlLine."Shortcut Dimension 3 Code" := TempBuffer2."Global Dimension 3 Code";
                    gGenJnlLine."Shortcut Dimension 4 Code" := TempBuffer2."Global Dimension 4 Code";
                    gGenJnlLine."Shortcut Dimension 5 Code" := TempBuffer2."Global Dimension 5 Code";
                    gGenJnlLine."Dimension Set ID" := TempBuffer2."Dimension Set ID";
                    gGenJnlLine.Circuito := TRUE;
                    gGenJnlLine."Job No." := TempBuffer2."Job No.";
                    gGenJnlLine."Source Code" := gCSrcCode;
                    gGenJnlLine."Sell-to/Buy-from No." := "Buy-from Vendor No.";
                    gGenJnlLine."Bill-to/Pay-to No." := "Pay-to Vendor No.";
                    gGenJnlLine."Country/Region Code" := "VAT Country/Region Code";
                    gGenJnlLine."VAT Registration No." := "VAT Registration No.";
                    gGenJnlLine."Source Type" := gGenJnlLine."Source Type"::Vendor;
                    gGenJnlLine."Source No." := "Pay-to Vendor No.";
                    gGenJnlLine."Posting No. Series" := '';
                    gGenJnlLine."IC Partner Code" := '';//"Pay-to IC Partner Code";
                    gGenJnlLine."Ship-to/Order Address Code" := "Order Address Code";

                    gGenJnlLine."Payment Terms Code" := "Payment Terms Code";
                    gGenJnlLine."Payment Method Code" := "Payment Method Code";

                    gGenJnlLine."Generate AutoInvoices" := FALSE;//"Generate Autoinvoices" OR "Generate Autocredit Memo";
                    gGenJnlLine."AutoDoc. No." := lCAutoDocNo;

                    if TempBuffer2.Type = TempBuffer2.Type::"Fixed Asset" THEN BEGIN
                        gGenJnlLine."Account Type" := gGenJnlLine."Account Type"::"Fixed Asset";
                        if TempBuffer2."FA Posting Type" =
                            TempBuffer2."FA Posting Type"::"Acquisition Cost"
                        THEN
                            gGenJnlLine."FA Posting Type" := gGenJnlLine."FA Posting Type"::"Acquisition Cost";
                        if TempBuffer2."FA Posting Type" =
                            TempBuffer2."FA Posting Type"::Maintenance
                        THEN
                            gGenJnlLine."FA Posting Type" := gGenJnlLine."FA Posting Type"::Maintenance;
                        gGenJnlLine."FA Posting Date" := TempBuffer2."FA Posting Date";
                        gGenJnlLine."Depreciation Book Code" := TempBuffer2."Depreciation Book Code";
                        gGenJnlLine."Salvage Value" := TempBuffer2."Salvage Value";
                        gGenJnlLine."Depr. until FA Posting Date" := TempBuffer2."Depr. until FA Posting Date";
                        gGenJnlLine."Depr. Acquisition Cost" := TempBuffer2."Depr. Acquisition Cost";
                        gGenJnlLine."Maintenance Code" := TempBuffer2."Maintenance Code";
                        gGenJnlLine."Insurance No." := TempBuffer2."Insurance No.";
                        gGenJnlLine."Budgeted FA No." := TempBuffer2."Budgeted FA No.";
                        gGenJnlLine."Duplicate in Depreciation Book" := TempBuffer2."Duplicate in Depreciation Book";
                        gGenJnlLine."Use Duplication List" := TempBuffer2."Use Duplication List";
                    END;

                    RungcGenJnlPostLine(gGenJnlLine);//, TempBuffer2."Dimension Entry No.");
                    // if FAInsertDiscountAmount(TempBuffer2, DeprBook) THEN
                    //     FAPostDiscountAmount(
                    //         gGenJnlLine,
                    //         TempBuffer2."Line Discount Amount" + TempBuffer2."Inv. Discount Amount",
                    //         TempBuffer2."Line Discount Amt. (ACY)" + TempBuffer2."Inv. Discount Amt. (ACY)",
                    //         TempBuffer2."Dimension Entry No.");
                    gGenJnlLine."Account Type" := gGenJnlLine."Account Type"::"G/L Account";
                    gGenJnlLine.VALIDATE("FA Posting Type", gGenJnlLine."FA Posting Type"::" ");
                    // if FAInsertDiscountAmount(TempBuffer2, DeprBook) THEN
                    //     PostDiscount(
                    //         TempBuffer2."FA Discount Account",
                    //         -(TempBuffer2."Line Discount Amount" + TempBuffer2."Inv. Discount Amount"),
                    //         -(TempBuffer2."Line Discount Amt. (ACY)" + TempBuffer2."Inv. Discount Amt. (ACY)"),
                    //         TempBuffer2."Dimension Entry No.");
                    if (TempBuffer2."Line Discount Amount" <> 0) OR
                    (TempBuffer2."Line Discount Amt. (ACY)" <> 0)
                    THEN
                        PostDiscount(
                            TempBuffer2."Line Discount Account",
                            TempBuffer2."Line Discount Amount",
                            TempBuffer2."Line Discount Amt. (ACY)",
                            TempBuffer2."Dimension Entry No.", lPurchHeader);
                    if (TempBuffer2."Inv. Discount Amount" <> 0) OR
                    (TempBuffer2."Inv. Discount Amt. (ACY)" <> 0)
                    THEN
                        PostDiscount(
                            TempBuffer2."Inv. Discount Account",
                            TempBuffer2."Inv. Discount Amount",
                            TempBuffer2."Inv. Discount Amt. (ACY)",
                            TempBuffer2."Dimension Entry No.", lPurchHeader);
                    if TempBuffer2."Pmt. Discount Amount" <> 0 THEN
                        PostDiscount(
                            TempBuffer2."Pmt. Discount Account",
                            TempBuffer2."Pmt. Discount Amount",
                            TempBuffer2."Src. Curr. Pmt. Discount Amt.",
                            TempBuffer2."Dimension Entry No.", lPurchHeader);
                UNTIL TempBuffer2.Next(-1) = 0;

            TempBuffer2.DELETEALL;

            // Check External Document number
            // {if gPurchSetup."Ext. Doc. No. Mandatory" OR
            // (gGenJnlLineExtDocNo <> '')
            // THEN BEGIN
            // VendLedgEntry.RESET;
            // VendLedgEntry.SETCURRENTKEY("External Document No.");
            // VendLedgEntry.SETRANGE("Document Type",gGenJnlLineDocType);
            // VendLedgEntry.SETRANGE("External Document No.",gGenJnlLineExtDocNo);
            // VendLedgEntry.SETRANGE("Vendor No.","Pay-to Vendor No.");
            // if VendLedgEntry.FINDFIRST THEN
            // ERROR(
            //     Text016,
            //     VendLedgEntry."Document Type",gGenJnlLineExtDocNo);
            // END;}

            // Post vendor entries
            //if GUIALLOWED THEN
            //Window.UPDATE(4,1);
            gGenJnlLine.INIT;
            gGenJnlLine."Posting Date" := "Posting Date";
            gGenJnlLine."Document Date" := "Document Date";
            gGenJnlLine.Description := COPYSTR("Posting Description", 1, MAXSTRLEN(gGenJnlLine.Description));
            gGenJnlLine."Shortcut Dimension 1 Code" := "Shortcut Dimension 1 Code";
            gGenJnlLine."Shortcut Dimension 2 Code" := "Shortcut Dimension 2 Code";
            //ASC
            gGenJnlLine."Shortcut Dimension 3 Code" := "Shortcut Dimension 3 Code";
            gGenJnlLine."Shortcut Dimension 4 Code" := "Shortcut Dimension 4 Code";
            gGenJnlLine."Shortcut Dimension 5 Code" := "Shortcut Dimension 5 Code";
            gGenJnlLine."Dimension Set ID" := "Dimension Set ID";
            gGenJnlLine.Circuito := TRUE;
            gGenJnlLine."Reason Code" := "Reason Code";
            gGenJnlLine."Account Type" := gGenJnlLine."Account Type"::Vendor;
            //   Vendor.GET("Pay-to Vendor No.");
            //    lVendorPostingGroup.GET(Vendor."Vendor Posting Group");
            gGenJnlLine."Account No." := "Pay-to Vendor No.";
            gGenJnlLine."Document Type" := gGenJnlLine."Document Type"::Receipt;
            gGenJnlLine."Document No." := lCGenJnlLineDocNo;
            gGenJnlLine."External Document No." := ltGenJnlLineExtDocNo;
            gGenJnlLine."Currency Code" := "Currency Code";
            gGenJnlLine.Amount := lDTotal;
            gGenJnlLine."Source Currency Code" := "Currency Code";
            gGenJnlLine."Source Currency Amount" := lDTotal;
            gGenJnlLine."Amount (LCY)" := lDTotalACY;
            if lPurchHeader."Currency Code" = '' THEN
                gGenJnlLine."Currency Factor" := 1
            ELSE
                gGenJnlLine."Currency Factor" := lPurchHeader."Currency Factor";
            gGenJnlLine."Sales/Purch. (LCY)" := lDTotalACY;
            gGenJnlLine.Correction := Correction;
            gGenJnlLine."Inv. Discount (LCY)" := gTotalPurchaseLineLCY."Inv. Discount Amount";
            gGenJnlLine."Pmt. Discount Given/Rec. (LCY)" := gTotalPurchaseLineLCY."Pmt. Discount Amount";
            gGenJnlLine."Sell-to/Buy-from No." := "Buy-from Vendor No.";
            gGenJnlLine."Bill-to/Pay-to No." := "Pay-to Vendor No.";
            gGenJnlLine."Salespers./Purch. Code" := "Purchaser Code";
            gGenJnlLine."System-Created Entry" := TRUE;
            gGenJnlLine."On Hold" := "On Hold";
            gGenJnlLine."Applies-to Doc. Type" := "Applies-to Doc. Type";
            gGenJnlLine."Applies-to Bill No." := "Applies-to Bill No.";
            gGenJnlLine."Applies-to Doc. No." := "Applies-to Doc. No.";
            gGenJnlLine."Applies-to ID" := '';
            gGenJnlLine."Allow Application" := "Bal. Account No." = '';
            gGenJnlLine."Payment Terms Code" := "Payment Terms Code";
            gGenJnlLine."Payment Method Code" := "Payment Method Code";
#if not CLEAN22
            // TODO: - CLEAN22

#if not CLEAN27
            gGenJnlLine."Pmt. Address Code" := "Pay-at Code";
#endif

            // TODO: - CLEAN22
#endif
            gGenJnlLine."Recipient Bank Account" := "Vendor Bank Acc. Code";
            gGenJnlLine."Due Date" := "Due Date";
            //gGenJnlLine."Pmt. Discount Date" := "Pmt. Discount Date";
            gGenJnlLine."Payment Discount %" := "Payment Discount %";
            gGenJnlLine."Source Type" := gGenJnlLine."Source Type"::Vendor;
            gGenJnlLine."Source No." := "Pay-to Vendor No.";
            gGenJnlLine."Source Code" := gCSrcCode;
            gGenJnlLine."Posting No. Series" := '';
            gGenJnlLine."IC Partner Code" := '';//"Pay-to IC Partner Code";
            gGenJnlLine."Generate AutoInvoices" := FALSE;//"Generate Autoinvoices" OR "Generate Autocredit Memo";
            gGenJnlLine."AutoDoc. No." := lCAutoDocNo;

            // TempJnlLineDim.DELETEALL;
            // TempDocDim.RESET;
            // TempDocDim.SETRANGE("Table ID", DATABASE::"Purch. Rcpt. Header");
            // gcDimMgt.CopyDocDimToJnlLineDim(TempDocDim, TempJnlLineDim);
            gcGenJnlPostLine.RunWithCheck(gGenJnlLine);

        END;
        MESSAGE('Se ha facturado el albarán %1 con fecha %2', pPurcRcptHdr."No.",
            FORMAT(pPurcRcptHdr."Posting Date", 0, '<Day,2>/<Month,2>/<Year>'));
        // pPurcRcptHdr.Contabilizado:=TRUE;
        // pPurcRcptHdr.Facturado:=FALSE;
        // pPurcRcptHdr.MODIFY;
    end;

    internal procedure DesContabilizarFacturasContra(lPurchRcptHdr: Record "Purch. Rcpt. Header")
    var
        lGlEntry: Record "G/L Entry";
        GlEntry2: Record "G/L Entry";
        lVendorEntry: Record "Vendor Ledger Entry";
        lDetVendorEntry: Record "Detailed Vendor Ledg. Entry";
        lCarteraDoc: Record "Cartera Doc.";
    begin

        lGlEntry.SETCURRENTKEY("Document No.", "Posting Date");
        lGlEntry.SETRANGE(lGlEntry."Source No.", lPurchRcptHdr."Pay-to Vendor No.");
        //lGlEntry.SETRANGE(lGlEntry."Document Type",lGlEntry."Document Type"::" ");
        lGlEntry.SETRANGE(lGlEntry."Document No.", lPurchRcptHdr."No.");
        if lGlEntry.FINDFIRST THEN BEGIN
            lGlEntry.SETFILTER("Transaction No.", '>%1', lGlEntry."Transaction No.");
            MESSAGE('Compruebe que las lineas mostradas corresponden al asiento a eliminar');
            COMMIT;
            Page.RUNMODAL(0, lGlEntry);
            if NOT CONFIRM('Es correcto ?', TRUE) THEN EXIT;
            lGlEntry.RESET;
            lGlEntry.SETCURRENTKEY("Document No.", "Posting Date");
            lGlEntry.SETRANGE(lGlEntry."Source No.", lPurchRcptHdr."Pay-to Vendor No.");
            //lGlEntry.SETRANGE(lGlEntry."Document Type",lGlEntry."Document Type"::" ");
            lGlEntry.SETRANGE(lGlEntry."Document No.", lPurchRcptHdr."No.");
            if lGlEntry.FINDFIRST THEN BEGIN
                lGlEntry.SETFILTER("Transaction No.", '>%1', lGlEntry."Transaction No.");

                //BorrarContabilidad

                GlEntry2.COPY(lGlEntry);
                if GlEntry2.FIND('-') THEN
                    REPEAT

                        lGlEntry := GlEntry2;

                        // LedgerEntryDim.SETRANGE("Entry No.", lGlEntry."Entry No.");
                        // LedgerEntryDim.SETFILTER(LedgerEntryDim."Table ID", '%1|%2|%3|%4', 17, 21, 23, 271);
                        // if LedgerEntryDim.FIND('-') THEN LedgerEntryDim.DELETEALL;


                        //Vendor
                        if lVendorEntry.GET(lGlEntry."Entry No.") THEN BEGIN
                            if lVendorEntry."Document Type" = lVendorEntry."Document Type"::Bill THEN
                                lVendorEntry.TestField(Open, TRUE);
                            lDetVendorEntry.SETCURRENTKEY("Vendor Ledger Entry No.", "Posting Date");
                            lDetVendorEntry.SETRANGE("Vendor Ledger Entry No.", lVendorEntry."Entry No.");
                            if lDetVendorEntry.FIND('-') THEN lDetVendorEntry.DELETEALL;
                            lVendorEntry.DELETE(TRUE);
                        END;
                        if lCarteraDoc.GET(lCarteraDoc.Type::Payable, lGlEntry."Entry No.") THEN lCarteraDoc.DELETE;

                        lGlEntry.DELETE(TRUE);

                    UNTIL GlEntry2.NEXT = 0;

            END;
        END;
    end;


    /// <summary>
    /// Comprobar.
    /// </summary>
    /// <param name="Purcheader">VAR Record "Purchase Header".</param>
    /// <returns>Return value of type Boolean.</returns>
    procedure Comprobar(var pPurcaseHeader: Record "Purchase Header"): Boolean;
    var
        lPurchaseLine: Record "Purchase Line";
        lResource: Record "Resource";
        lbRecAgr: Boolean;
    Begin
        lbRecAgr := FALSE;
        lPurchaseLine.SETRANGE(lPurchaseLine."Document Type", pPurcaseHeader."Document Type");
        lPurchaseLine.SETRANGE(lPurchaseLine."Document No.", pPurcaseHeader."No.");
        if lPurchaseLine.FINDFIRST THEN
            REPEAT
                if (lPurchaseLine.Type = lPurchaseLine.Type::Resource) OR (lPurchaseLine.Recurso <> '') THEN BEGIN
                    if lPurchaseLine."Empresa Origen" <> '' THEN
                        lResource.CHANGECOMPANY(lPurchaseLine."Empresa Origen");

                    if lPurchaseLine.Recurso <> '' THEN BEGIN
                        if lResource.GET(lPurchaseLine.Recurso) THEN begin
                            if lResource."Recurso Agrupado" THEN
                                lbRecAgr := TRUE;
                        END ELSE
                            if lResource.GET(lPurchaseLine."No.") THEN
                                if lResource."Recurso Agrupado" THEN
                                    lbRecAgr := TRUE;
                    END ELSE BEGIN
                        if lResource.GET(lPurchaseLine."No.") THEN
                            if lResource."Recurso Agrupado" THEN
                                lbRecAgr := TRUE;
                    END;
                END;
            UNTIL lPurchaseLine.NEXT = 0;
        EXIT(lbRecAgr);
    end;

    internal procedure ContabilizarAlbaranesDeslgo(pPurcRcptHdr: Record "Purch. Rcpt. Header")
    var
        lPurchRcptLineTMP: Record "Purch. Rcpt. Line" temporary;
        lPurchRcptLineACY: Record "Purch. Rcpt. Line";
        lVendor: Record "Vendor";
        lDDiscountVATAmount: Decimal;
        TrackingSpecificationExists: Boolean;
        lVendorPostingGroup: Record "Vendor Posting Group";
        lDTotal: Decimal;
        lDTotalACY: Decimal;
        lPurchHeader2: Record "Purchase Header";
        lDimBufTMP: Record "Dimension Buffer";
        lDImporte: Decimal;
        lGLEntry: Record "G/L Entry";
        lCAutoDocNo: Code[20];
        ltGenJnlLineExtDocNo: Text[30];
        lPurchHeader: Record "Purchase Header";
        liGenJnlLineDocType: Integer;
        lCGenJnlLineDocNo: Code[20];
        liLinecount: Integer;
        lSourceCodeSetup: Record "Source Code Setup";
        TempBuffer: Record "Invoice Posting Buffer" temporary;
        TempBuffer2: Record "Invoice Posting Buffer" temporary;
        FALineNo: Integer;
    begin

        WITH pPurcRcptHdr DO BEGIN
            if lPurchHeader2.GET(lPurchHeader2."Document Type"::Order, pPurcRcptHdr."Order No.") THEN
                if Comprobar(lPurchHeader2) THEN EXIT; //TSS
            if lPurchHeader.GET(lPurchHeader."Document Type"::Order, pPurcRcptHdr."Order No.") THEN lPurchHeader.Init();
            if NOT Contabilizado THEN ERROR(glDebedesglosado);
            liGenJnlLineDocType := 0;
            lCGenJnlLineDocNo := "No.";
            ltGenJnlLineExtDocNo := "Vendor Shipment No.";
            lDTotal := 0;
            lDTotalACY := 0;
            lPurchRcptLineTMP.SETRANGE(lPurchRcptLineTMP."Document No.", pPurcRcptHdr."No.");
            DesglosarAlbaranesContabDesglo(pPurcRcptHdr, lPurchRcptLineTMP);
            if lPurchRcptLineTMP.FINDFIRST THEN
                REPEAT
                    if (lPurchRcptLineTMP.Type.AsInteger() >= lPurchRcptLineTMP.Type::"G/L Account".AsInteger()) AND (lPurchRcptLineTMP.Quantity <> 0) THEN BEGIN
                        // Copy purchase to Buffer
                        //PurchLineACY.GET(lPurchRcptLineTMP."Document No.",lPurchRcptLineTMP."Line No.");
                        // DocDim.SETRANGE(DocDim."Table ID", DATABASE::"Purchase Line Archive");
                        // DocDim.SETRANGE(DocDim."Document Type", DocDim."Document Type"::Order);
                        // DocDim.SETRANGE(DocDim."Document No.", lPurchRcptLineTMP."Document No.");
                        // DocDim.SETRANGE(DocDim."Line No.", lPurchRcptLineTMP."Line No.");
                        // if DocDim.FINDFIRST THEN
                        //     REPEAT
                        //         TempDocDim.TransferFields(DocDim);
                        //         if TempDocDim.INSERT THEN;
                        //     UNTIL DocDim.NEXT = 0;
                        FillAlbPostingBufferCorreccion(lPurchRcptLineTMP, lPurchRcptLineTMP."Line No.", TempBuffer);
                        UpdInvPostingBuldFFeProduccionesgloNew(TempBuffer, FALineNo, TempBuffer2);
                        // TempDocDim.SETRANGE("Table ID");
                        // TempDocDim.SETRANGE("Line No.");
                    END;
                UNTIL lPurchRcptLineTMP.NEXT = 0;
            // Post purchase and VAT to G/L entries from Buffer
            liLinecount := 0;
            if TempBuffer2.FINDFIRST THEN;
            lGlEntry.SETRANGE(lGlEntry."Document Type", lGlEntry."Document Type"::Receipt);
            lGlEntry.SETRANGE(lGlEntry."Posting Date", "Posting Date");
            lGlEntry.SETRANGE(lGlEntry."Document No.", "No.");
            lGlEntry.SETFILTER("Reason Code", '<>%1', 'DESGLO');
            if lGlEntry.FINDFIRST THEN
                REPEAT
                    gGenJnlLine.INIT;
                    gGenJnlLine."Posting Date" := "Posting Date";
                    gGenJnlLine."Document Date" := "Document Date";
                    gGenJnlLine.Description := "Posting Description";
                    gGenJnlLine."Reason Code" := 'DESGLO';
                    gGenJnlLine."Document Type" := gGenJnlLine."Document Type"::Receipt;
                    gGenJnlLine."Document No." := "No.";
                    gGenJnlLine."External Document No." := ltGenJnlLineExtDocNo;
                    gGenJnlLine."Account No." := lGlEntry."G/L Account No.";
                    gGenJnlLine."System-Created Entry" := TempBuffer2."System-Created Entry";
                    gGenJnlLine.Amount := -lGlEntry.Amount;
                    gGenJnlLine."Source Currency Code" := "Currency Code";
                    gGenJnlLine."Source Currency Amount" := -lGlEntry.Amount;
                    gGenJnlLine.Correction := Correction;
                    gGenJnlLine."Gen. Posting Type" := gGenJnlLine."Gen. Posting Type"::" ";
                    gGenJnlLine."Gen. Bus. Posting Group" := '';// lGlEntry."Gen. Bus. Posting Group";
                    gGenJnlLine."Gen. Prod. Posting Group" := '';// lGlEntry."Gen. Prod. Posting Group";
                    gGenJnlLine."VAT Bus. Posting Group" := '';//lGlEntry."VAT Bus. Posting Group";
                    gGenJnlLine."VAT Prod. Posting Group" := '';// lGlEntry."VAT Prod. Posting Group";
                    gGenJnlLine."Tax Area Code" := lGlEntry."Tax Area Code";
                    gGenJnlLine."Tax Liable" := lGlEntry."Tax Liable";
                    gGenJnlLine."Tax Group Code" := lGlEntry."Tax Group Code";
                    gGenJnlLine."Use Tax" := lGlEntry."Use Tax";
                    gGenJnlLine.Quantity := lGlEntry.Quantity;
                    gGenJnlLine."VAT Calculation Type" := gGenJnlLine."VAT Calculation Type"::"Normal VAT";
                    gGenJnlLine."VAT Base Amount" := 0;//-lGlEntry."Amount";
                    gGenJnlLine."VAT Base Discount %" := "VAT Base Discount %";
                    gGenJnlLine."Source Curr. VAT Base Amount" := 0;// -lGlEntry."Amount";
                    gGenJnlLine."VAT Amount" := 0;// -lGlEntry."VAT Amount";
                    gGenJnlLine."Source Curr. VAT Amount" := 0;//-lGlEntry."Vat Amount";
                    gGenJnlLine."VAT Difference" := 0;// lGlEntry."VAT Difference";
                    gGenJnlLine."VAT Posting" := gGenJnlLine."VAT Posting"::"Manual VAT Entry";
                    gGenJnlLine."Shortcut Dimension 1 Code" := lGlEntry."Global Dimension 1 Code";
                    gGenJnlLine."Shortcut Dimension 2 Code" := lGlEntry."Global Dimension 2 Code";
                    //ASC
                    gGenJnlLine."Shortcut Dimension 3 Code" := lGlEntry."Global Dimension 3 Code";
                    gGenJnlLine."Shortcut Dimension 4 Code" := lGlEntry."Global Dimension 4 Code";
                    gGenJnlLine."Shortcut Dimension 5 Code" := lGlEntry."Global Dimension 5 Code";
                    gGenJnlLine."Dimension Set ID" := lGlEntry."Dimension Set ID";
                    gGenJnlLine."Job No." := lGlEntry."Job No.";
                    lSourceCodeSetup.GET;
                    gCSrcCode := lSourceCodeSetup.Sales;
                    gGenJnlLine."Source Code" := gCSrcCode;
                    gGenJnlLine."Sell-to/Buy-from No." := "Buy-from Vendor No.";
                    gGenJnlLine."Bill-to/Pay-to No." := "Pay-to Vendor No.";
                    gGenJnlLine."Country/Region Code" := "VAT Country/Region Code";
                    gGenJnlLine."VAT Registration No." := "VAT Registration No.";
                    gGenJnlLine."Source Type" := gGenJnlLine."Source Type"::Vendor;
                    gGenJnlLine."Source No." := "Pay-to Vendor No.";
                    gGenJnlLine."Posting No. Series" := "No. Series";
                    gGenJnlLine."Ship-to/Order Address Code" := "Ship-to Code";
                    gGenJnlLine."Payment Terms Code" := "Payment Terms Code";
                    gGenJnlLine."Payment Method Code" := "Payment Method Code";
                    if lGlEntry."Source Type" = lGlEntry."Source Type"::"Fixed Asset" THEN BEGIN
                        gGenJnlLine."Account Type" := gGenJnlLine."Account Type"::"Fixed Asset";
                        gGenJnlLine."FA Posting Type" := gGenJnlLine."FA Posting Type"::Disposal;
                        gGenJnlLine."FA Posting Date" := lGlEntry."Posting Date";
                        gGenJnlLine."Depreciation Book Code" := '';//lGlEntry."Depreciation Book Code";
                        gGenJnlLine."Depr. until FA Posting Date" := FALSE;//lGlEntry."Depr. until FA Posting Date";
                        gGenJnlLine."Duplicate in Depreciation Book" := '';//lGlEntry."Duplicate in Depreciation Book";
                        gGenJnlLine."Use Duplication List" := FALSE;//lGlEntry."Use Duplication List";
                    END;
                    gGenLedgerSetup.GET;
                    // TempDocDim.DELETEALL;
                    // TempDocDim."Table ID" := "Purchase Line";
                    // TempDocDim."Document Type" := TempDocDim."Document Type"::Order;
                    // TempDocDim."Document No." := "No.";
                    // TempDocDim."Dimension Code" := gGenLedgerSetup."Shortcut Dimension 1 Code";
                    // TempDocDim."Dimension Value Code" := lGlEntry."Global Dimension 1 Code";
                    // TempDocDim.INSERT;

                    // TempDocDim."Table ID" := "Purchase Line";
                    // TempDocDim."Document Type" := TempDocDim."Document Type"::Order;
                    // TempDocDim."Document No." := "No.";
                    // TempDocDim."Dimension Code" := gGenLedgerSetup."Shortcut Dimension 2 Code";
                    // TempDocDim."Dimension Value Code" := lGlEntry."Global Dimension 2 Code";
                    // TempDocDim.INSERT;

                    // TempDocDim."Table ID" := "Purchase Line";
                    // TempDocDim."Document Type" := TempDocDim."Document Type"::Order;
                    // TempDocDim."Document No." := "No.";
                    // TempDocDim."Dimension Code" := gGenLedgerSetup."Shortcut Dimension 3 Code";
                    // TempDocDim."Dimension Value Code" := lGlEntry."Global Dimension 3 Code";
                    // TempDocDim.INSERT;

                    // TempDocDim."Table ID" := "Purchase Line";
                    // TempDocDim."Document Type" := TempDocDim."Document Type"::Order;
                    // TempDocDim."Document No." := "No.";
                    // TempDocDim."Dimension Code" := gGenLedgerSetup."Shortcut Dimension 4 Code";
                    // TempDocDim."Dimension Value Code" := lGlEntry."Global Dimension 4 Code";
                    // TempDocDim.INSERT;

                    // TempDocDim."Table ID" := "Purchase Line";
                    // TempDocDim."Document Type" := TempDocDim."Document Type"::Order;
                    // TempDocDim."Document No." := "No.";
                    // TempDocDim."Dimension Code" := gGenLedgerSetup."Shortcut Dimension 5 Code";
                    // TempDocDim."Dimension Value Code" := lGlEntry."Global Dimension 5 Code";
                    // TempDocDim.INSERT;
                    // lDimBufTMP.DELETEALL;
                    // if TempDocDim.FINDSET THEN
                    //     REPEAT
                    //         lDimBufTMP."Table ID" := TempDocDim."Table ID";
                    //         lDimBufTMP."Dimension Code" := TempDocDim."Dimension Code";
                    //         lDimBufTMP."Dimension Value Code" := TempDocDim."Dimension Value Code";
                    //         lDimBufTMP.INSERT;
                    //     UNTIL TempDocDim.NEXT = 0;
                    // EntryNo := DimBufMgt.FINDDimensions(lDimBufTMP);
                    // if EntryNo = 0 THEN
                    //     EntryNo := DimBufMgt.InsertDimensions(lDimBufTMP);
                    lDImporte := lDImporte + gGenJnlLine.Amount;
                    RungcGenJnlPostLine(gGenJnlLine);
                UNTIL lGlEntry.NEXT = 0;
            if lDImporte <> 0 THEN BEGIN
                gGenJnlLine.Amount := -lDImporte;
                gGenJnlLine."Amount (LCY)" := -lDImporte;
                gGenJnlLine."Source Currency Amount" := -lDImporte;
                RungcGenJnlPostLine(gGenJnlLine);
            END;
            lGlEntry.MODIFYALL("Reason Code", 'DESGLO');
            TempBuffer2.RESET;
            if TempBuffer2.FIND('+') THEN
                REPEAT
                    liLinecount := liLinecount + 1;
                    //if GUIALLOWED THEN
                    //Window.UPDATE(3,liLinecount);

                    CASE TempBuffer2."VAT Calculation Type" OF
                        TempBuffer2."VAT Calculation Type"::"Reverse Charge VAT":
                            BEGIN
                                gVATPostingSetup.GET(
                                    TempBuffer2."VAT Bus. Posting Group", TempBuffer2."VAT Prod. Posting Group");
                                TempBuffer2."VAT Amount" :=
                                    ROUND(
                                    (TempBuffer2.Amount -
                                    TempBuffer2."Line Discount Amount" -
                                    TempBuffer2."Inv. Discount Amount" -
                                    TempBuffer2."Pmt. Discount Amount") *
                                    gVATPostingSetup."VAT+EC %" / 100);
                                TempBuffer2."VAT Amount (ACY)" :=
                                    ROUND(
                                    (TempBuffer2."Amount (ACY)" -
                                    TempBuffer2."Line Discount Amt. (ACY)" -
                                    TempBuffer2."Inv. Discount Amt. (ACY)" -
                                    TempBuffer2."Src. Curr. Pmt. Discount Amt.") *
                                    gVATPostingSetup."VAT+EC %" / 100, gCurrency."Amount Rounding Precision");
                            END;
                        TempBuffer2."VAT Calculation Type"::"Sales Tax":
                            BEGIN
                                if TempBuffer2."Use Tax" THEN BEGIN
                                    TempBuffer2."VAT Amount" :=
                                    ROUND(
                                        gcSalesTaxCalculate.CalculateTax(
                                        TempBuffer2."Tax Area Code", TempBuffer2."Tax Group Code",
                                        TempBuffer2."Tax Liable", lPurchHeader."Posting Date",
                                        TempBuffer2.Amount -
                                        TempBuffer2."Line Discount Amount" - TempBuffer2."Inv. Discount Amount" -
                                        TempBuffer2."Pmt. Discount Amount",
                                        TempBuffer2.Quantity, 0));
                                    if gGenLedgerSetup."Additional Reporting Currency" <> '' THEN
                                        TempBuffer2."VAT Amount (ACY)" :=
                                        gCurrExchRate.ExchangeAmtLCYToFCY(
                                            lPurchHeader."Posting Date", gGenLedgerSetup."Additional Reporting Currency",
                                            TempBuffer2."VAT Amount", 0);
                                END;
                            END;
                    END;

                    if lPurchHeader."Prices Including VAT" AND (TempBuffer2."VAT %" <> 0) THEN
                        WITH TempBuffer2 DO BEGIN
                            lDDiscountVATAmount :=
                            ROUND("Line Discount Amount" * "VAT %" / (1 + "VAT %" / 100) / 100);
                            Amount := Amount - lDDiscountVATAmount;
                            "Line Discount Amount" := "Line Discount Amount" - lDDiscountVATAmount;

                            lDDiscountVATAmount :=
                            ROUND(
                                "Line Discount Amt. (ACY)" * "VAT %" / (1 + "VAT %" / 100) / 100,
                                gCurrency."Amount Rounding Precision");
                            "Amount (ACY)" := "Amount (ACY)" - lDDiscountVATAmount;
                            "Line Discount Amt. (ACY)" := "Line Discount Amt. (ACY)" - lDDiscountVATAmount;

                            lDDiscountVATAmount :=
                            ROUND("Inv. Discount Amount" * "VAT %" / (1 + "VAT %" / 100) / 100);
                            Amount := Amount - lDDiscountVATAmount;
                            "Inv. Discount Amount" := "Inv. Discount Amount" - lDDiscountVATAmount;

                            lDDiscountVATAmount :=
                            ROUND(
                                "Src. Curr. Pmt. Discount Amt." * "VAT %" / (1 + "VAT %" / 100) / 100,
                                gCurrency."Amount Rounding Precision");
                            "Amount (ACY)" := "Amount (ACY)" - lDDiscountVATAmount;
                            "Inv. Discount Amt. (ACY)" := "Inv. Discount Amt. (ACY)" - lDDiscountVATAmount;

                            lDDiscountVATAmount :=
                            ROUND(
                                "Inv. Discount Amt. (ACY)" * "VAT %" / (1 + "VAT %" / 100) / 100,
                                gCurrency."Amount Rounding Precision");
                            "Amount (ACY)" := "Amount (ACY)" - lDDiscountVATAmount;
                            "Inv. Discount Amt. (ACY)" := "Inv. Discount Amt. (ACY)" - lDDiscountVATAmount;
                        END;

                    gGenJnlLine.INIT;
                    gGenJnlLine."Posting Date" := "Posting Date";
                    gGenJnlLine."Document Date" := "Document Date";
                    gGenJnlLine.Description := COPYSTR("Posting Description", 1, MAXSTRLEN(gGenJnlLine.Description));
                    //gGenJnlLine.Description := "Posting Description";
                    gGenJnlLine."Reason Code" := "Reason Code";
                    gGenJnlLine."Document Type" := gGenJnlLine."Document Type"::Receipt;
                    gGenJnlLine."Document No." := "No.";
                    gGenJnlLine."Tax Area Code" := "No.";
                    gGenJnlLine."External Document No." := pPurcRcptHdr."Vendor Shipment No.";
                    gGenJnlLine."Account No." := TempBuffer2."G/L Account";
                    gGenJnlLine."System-Created Entry" := TempBuffer2."System-Created Entry";
                    gGenJnlLine.Amount := TempBuffer2.Amount;
                    lDTotal := lDTotal + TempBuffer2.Amount;
                    gGenJnlLine."Source Currency Code" := "Currency Code";
                    gGenJnlLine."Source Currency Amount" := TempBuffer2."Amount (ACY)";
                    lDTotalACY := lDTotalACY + TempBuffer2."Amount (ACY)";
                    gGenJnlLine.Correction := Correction;
                    gGenJnlLine."Gen. Posting Type" := gGenJnlLine."Gen. Posting Type"::" ";
                    gGenJnlLine."Gen. Bus. Posting Group" := '';//TempBuffer2."Gen. Bus. Posting Group";
                    gGenJnlLine."Gen. Prod. Posting Group" := '';// TempBuffer2."Gen. Prod. Posting Group";
                    gGenJnlLine."VAT Bus. Posting Group" := '';//TempBuffer2."VAT Bus. Posting Group";
                    gGenJnlLine."VAT Prod. Posting Group" := '';//TempBuffer2."VAT Prod. Posting Group";
                    gGenJnlLine."Tax Area Code" := TempBuffer2."Tax Area Code";
                    gGenJnlLine."Tax Liable" := TempBuffer2."Tax Liable";
                    gGenJnlLine."Tax Group Code" := TempBuffer2."Tax Group Code";
                    gGenJnlLine."Use Tax" := TempBuffer2."Use Tax";
                    gGenJnlLine.Quantity := TempBuffer2.Quantity;
                    gGenJnlLine."VAT Calculation Type" := TempBuffer2."VAT Calculation Type";
                    gGenJnlLine."VAT Base Amount" := TempBuffer2."VAT Base Amount";
                    gGenJnlLine."VAT Base Discount %" := "VAT Base Discount %";
                    gGenJnlLine."Source Curr. VAT Base Amount" := TempBuffer2."VAT Base Amount (ACY)";
                    gGenJnlLine."VAT Amount" := TempBuffer2."VAT Amount";
                    gGenJnlLine."Source Curr. VAT Amount" := TempBuffer2."VAT Amount (ACY)";
                    gGenJnlLine."VAT Difference" := TempBuffer2."VAT Difference";
                    gGenJnlLine."VAT Posting" := gGenJnlLine."VAT Posting"::"Manual VAT Entry";
                    gGenJnlLine."Shortcut Dimension 1 Code" := TempBuffer2."Global Dimension 1 Code";
                    gGenJnlLine."Shortcut Dimension 2 Code" := TempBuffer2."Global Dimension 2 Code";
                    //ASC
                    gGenJnlLine."Shortcut Dimension 3 Code" := TempBuffer2."Global Dimension 3 Code";
                    gGenJnlLine."Shortcut Dimension 4 Code" := TempBuffer2."Global Dimension 4 Code";
                    gGenJnlLine."Shortcut Dimension 5 Code" := TempBuffer2."Global Dimension 5 Code";
                    gGenJnlLine."Dimension Set ID" := TempBuffer2."Dimension Set ID";
                    gGenJnlLine."Job No." := TempBuffer2."Job No.";
                    gGenJnlLine."Source Code" := gCSrcCode;
                    gGenJnlLine."Sell-to/Buy-from No." := "Buy-from Vendor No.";
                    gGenJnlLine."Bill-to/Pay-to No." := "Pay-to Vendor No.";
                    gGenJnlLine."Country/Region Code" := "VAT Country/Region Code";
                    gGenJnlLine."VAT Registration No." := "VAT Registration No.";
                    gGenJnlLine."Source Type" := gGenJnlLine."Source Type"::Vendor;
                    gGenJnlLine."Source No." := "Pay-to Vendor No.";
                    gGenJnlLine."Posting No. Series" := '';
                    gGenJnlLine."IC Partner Code" := '';//"Pay-to IC Partner Code";
                    gGenJnlLine."Ship-to/Order Address Code" := "Order Address Code";

                    gGenJnlLine."Payment Terms Code" := "Payment Terms Code";
                    gGenJnlLine."Payment Method Code" := "Payment Method Code";

                    gGenJnlLine."Generate AutoInvoices" := FALSE;//"Generate Autoinvoices" OR "Generate Autocredit Memo";
                    gGenJnlLine."AutoDoc. No." := lCAutoDocNo;

                    if TempBuffer2.Type = TempBuffer2.Type::"Fixed Asset" THEN BEGIN
                        gGenJnlLine."Account Type" := gGenJnlLine."Account Type"::"Fixed Asset";
                        if TempBuffer2."FA Posting Type" =
                            TempBuffer2."FA Posting Type"::"Acquisition Cost"
                        THEN
                            gGenJnlLine."FA Posting Type" := gGenJnlLine."FA Posting Type"::"Acquisition Cost";
                        if TempBuffer2."FA Posting Type" =
                            TempBuffer2."FA Posting Type"::Maintenance
                        THEN
                            gGenJnlLine."FA Posting Type" := gGenJnlLine."FA Posting Type"::Maintenance;
                        gGenJnlLine."FA Posting Date" := TempBuffer2."FA Posting Date";
                        gGenJnlLine."Depreciation Book Code" := TempBuffer2."Depreciation Book Code";
                        gGenJnlLine."Salvage Value" := TempBuffer2."Salvage Value";
                        gGenJnlLine."Depr. until FA Posting Date" := TempBuffer2."Depr. until FA Posting Date";
                        gGenJnlLine."Depr. Acquisition Cost" := TempBuffer2."Depr. Acquisition Cost";
                        gGenJnlLine."Maintenance Code" := TempBuffer2."Maintenance Code";
                        gGenJnlLine."Insurance No." := TempBuffer2."Insurance No.";
                        gGenJnlLine."Budgeted FA No." := TempBuffer2."Budgeted FA No.";
                        gGenJnlLine."Duplicate in Depreciation Book" := TempBuffer2."Duplicate in Depreciation Book";
                        gGenJnlLine."Use Duplication List" := TempBuffer2."Use Duplication List";
                    END;

                    RungcGenJnlPostLine(gGenJnlLine);
                    // if FAInsertDiscountAmount(TempBuffer2, DeprBook) THEN
                    //     FAPostDiscountAmount(
                    //         gGenJnlLine,
                    //         TempBuffer2."Line Discount Amount" + TempBuffer2."Inv. Discount Amount",
                    //         TempBuffer2."Line Discount Amt. (ACY)" + TempBuffer2."Inv. Discount Amt. (ACY)",
                    //         TempBuffer2."Dimension Entry No.");
                    gGenJnlLine."Account Type" := gGenJnlLine."Account Type"::"G/L Account";
                    gGenJnlLine.VALIDATE("FA Posting Type", gGenJnlLine."FA Posting Type"::" ");
                    // if FAInsertDiscountAmount(TempBuffer2, DeprBook) THEN
                    //     PostDiscount(
                    //         0,
                    //         -(TempBuffer2."Line Discount Amount" + TempBuffer2."Inv. Discount Amount"),
                    //         -(TempBuffer2."Line Discount Amt. (ACY)" + TempBuffer2."Inv. Discount Amt. (ACY)"),
                    //         TempBuffer2."Dimension Entry No.",PurchHeader);
                    if (TempBuffer2."Line Discount Amount" <> 0) OR
                    (TempBuffer2."Line Discount Amt. (ACY)" <> 0)
                    THEN
                        PostDiscount(
                            TempBuffer2."Line Discount Account",
                            TempBuffer2."Line Discount Amount",
                            TempBuffer2."Line Discount Amt. (ACY)",
                            TempBuffer2."Dimension Entry No.", lPurchHeader);
                    if (TempBuffer2."Inv. Discount Amount" <> 0) OR
                    (TempBuffer2."Inv. Discount Amt. (ACY)" <> 0)
                    THEN
                        PostDiscount(
                            TempBuffer2."Inv. Discount Account",
                            TempBuffer2."Inv. Discount Amount",
                            TempBuffer2."Inv. Discount Amt. (ACY)",
                            TempBuffer2."Dimension Entry No.", lPurchHeader);
                    if TempBuffer2."Pmt. Discount Amount" <> 0 THEN
                        PostDiscount(
                            TempBuffer2."Pmt. Discount Account",
                            TempBuffer2."Pmt. Discount Amount",
                            TempBuffer2."Src. Curr. Pmt. Discount Amt.",
                            TempBuffer2."Dimension Entry No.", lPurchHeader);
                UNTIL TempBuffer2.Next(-1) = 0;

            TempBuffer2.DELETEALL;

            // Check External Document number
            // {if gPurchSetup."Ext. Doc. No. Mandatory" OR
            // (gGenJnlLineExtDocNo <> '')
            // THEN BEGIN
            // VendLedgEntry.RESET;
            // VendLedgEntry.SETCURRENTKEY("External Document No.");
            // VendLedgEntry.SETRANGE("Document Type",gGenJnlLineDocType);
            // VendLedgEntry.SETRANGE("External Document No.",gGenJnlLineExtDocNo);
            // VendLedgEntry.SETRANGE("Vendor No.","Pay-to Vendor No.");
            // if VendLedgEntry.FINDFIRST THEN
            //     ERROR(
            //     Text016,
            //     VendLedgEntry."Document Type",gGenJnlLineExtDocNo);
            // END;}

            // Post vendor entries
            //if GUIALLOWED THEN
            //Window.UPDATE(4,1);
            gGenJnlLine.INIT;
            gGenJnlLine."Posting Date" := "Posting Date";
            gGenJnlLine."Document Date" := "Document Date";
            gGenJnlLine.Description := COPYSTR("Posting Description", 1, MAXSTRLEN(gGenJnlLine.Description));
            gGenJnlLine."Shortcut Dimension 1 Code" := "Shortcut Dimension 1 Code";
            gGenJnlLine."Shortcut Dimension 2 Code" := "Shortcut Dimension 2 Code";
            //ASC
            gGenJnlLine."Shortcut Dimension 3 Code" := "Shortcut Dimension 3 Code";
            gGenJnlLine."Shortcut Dimension 4 Code" := "Shortcut Dimension 4 Code";
            gGenJnlLine."Shortcut Dimension 5 Code" := "Shortcut Dimension 5 Code";
            gGenJnlLine."Dimension Set ID" := "Dimension Set ID";
            gGenJnlLine."Reason Code" := "Reason Code";
            gGenJnlLine."Account Type" := gGenJnlLine."Account Type"::"G/L Account";
            lVendor.GET("Pay-to Vendor No.");
            lVendorPostingGroup.GET(lVendor."Vendor Posting Group");
            gGenJnlLine."Account No." := lVendorPostingGroup.FPR;
            gGenJnlLine."Tax Area Code" := lCGenJnlLineDocNo;
            gGenJnlLine."Document Type" := gGenJnlLine."Document Type"::Receipt;
            gGenJnlLine."Document No." := lCGenJnlLineDocNo;
            gGenJnlLine."External Document No." := ltGenJnlLineExtDocNo;
            gGenJnlLine."Currency Code" := "Currency Code";
            gGenJnlLine.Amount := -lDTotal;
            gGenJnlLine."Source Currency Code" := "Currency Code";
            gGenJnlLine."Source Currency Amount" := -lDTotal;
            gGenJnlLine."Amount (LCY)" := -lDTotalACY;
            if lPurchHeader."Currency Code" = '' THEN
                gGenJnlLine."Currency Factor" := 1
            ELSE
                gGenJnlLine."Currency Factor" := lPurchHeader."Currency Factor";
            gGenJnlLine."Sales/Purch. (LCY)" := -lDTotalACY;
            gGenJnlLine.Correction := Correction;
            gGenJnlLine."Inv. Discount (LCY)" := -gTotalPurchaseLineLCY."Inv. Discount Amount";
            gGenJnlLine."Pmt. Discount Given/Rec. (LCY)" := -gTotalPurchaseLineLCY."Pmt. Discount Amount";
            gGenJnlLine."Sell-to/Buy-from No." := "Buy-from Vendor No.";
            gGenJnlLine."Bill-to/Pay-to No." := "Pay-to Vendor No.";
            gGenJnlLine."Salespers./Purch. Code" := "Purchaser Code";
            gGenJnlLine."System-Created Entry" := TRUE;
            gGenJnlLine."On Hold" := "On Hold";
            gGenJnlLine."Applies-to Doc. Type" := "Applies-to Doc. Type";
            gGenJnlLine."Applies-to Bill No." := "Applies-to Bill No.";
            gGenJnlLine."Applies-to Doc. No." := "Applies-to Doc. No.";
            gGenJnlLine."Applies-to ID" := '';
            gGenJnlLine."Allow Application" := "Bal. Account No." = '';
            gGenJnlLine."Payment Terms Code" := "Payment Terms Code";
            gGenJnlLine."Payment Method Code" := "Payment Method Code";
#if not CLEAN22
            // TODO: - CLEAN22
#if not CLEAN27
            gGenJnlLine."Pmt. Address Code" := "Pay-at Code";
#endif
            // TODO: - CLEAN22
#endif
            gGenJnlLine."Recipient Bank Account" := "Vendor Bank Acc. Code";
            gGenJnlLine."Due Date" := "Due Date";
            //gGenJnlLine."Pmt. Discount Date" := "Pmt. Discount Date";
            gGenJnlLine."Payment Discount %" := "Payment Discount %";
            gGenJnlLine."Source Type" := gGenJnlLine."Source Type"::Vendor;
            gGenJnlLine."Source No." := "Pay-to Vendor No.";
            gGenJnlLine."Source Code" := gCSrcCode;
            gGenJnlLine."Posting No. Series" := '';
            gGenJnlLine."IC Partner Code" := '';//"Pay-to IC Partner Code";
            gGenJnlLine."Generate AutoInvoices" := FALSE;//"Generate Autoinvoices" OR "Generate Autocredit Memo";
            gGenJnlLine."AutoDoc. No." := lCAutoDocNo;

            // TempJnlLineDim.DELETEALL;
            // TempDocDim.RESET;
            // TempDocDim.SETRANGE("Table ID", DATABASE::"Purchase Line Archive");
            // gcDimMgt.CopyDocDimToJnlLineDim(TempDocDim, TempJnlLineDim);
            gcGenJnlPostLine.RunWithCheck(gGenJnlLine);

        END;

        MESSAGE('Se ha contabilizado el albarán %1 con fecha %2', pPurcRcptHdr."No.",
            FORMAT(pPurcRcptHdr."Posting Date", 0, '<Day,2>/<Month,2>/<Year>'));
        pPurcRcptHdr.Contabilizado := TRUE;
        pPurcRcptHdr.Facturado := FALSE;
        pPurcRcptHdr.MODIFY;
    end;

    internal PROCEDURE DesContabilizarAlbaranesContra(var pPurcRcptHdr: Record "Purch. Rcpt. Header")
    var
        liGenJnlLineDocType: Integer;
        lCGenJnlLineDocNo: Code[20];
        ltGenJnlLineExtDocNo: Text;
        lDTotal: decimal;
        lDTotalACY: decimal;
        lPurchRcptLineTMP: Record "Purch. Rcpt. Line" temporary;
        lPurchArchiveLine: Record "Purchase Line Archive";
        liLinecount: Integer;
        lPurchHeader: Record "Purchase Header";
        lCAutoDocNo: Code[20];
        lVendorPostingGroup: Record "Vendor Posting Group";
        lVendor: Record Vendor;
        lPurchRecptLine: Record "Purch. Rcpt. Line";
        TempBuffer: Record "Invoice Posting Buffer" temporary;
        TempBuffer2: Record "Invoice Posting Buffer" temporary;
        FaLineNo: Integer;
    begin

        // WITH pPurcRcptHdr DO BEGIN
        lPurchRecptLine.SETRANGE(lPurchRecptLine."Document No.", pPurcRcptHdr."No.");
        lPurchRecptLine.SETFILTER(lPurchRecptLine."No.", '%1', '');
        lPurchRecptLine.MODIFYALL(lPurchRecptLine.Type, lPurchRecptLine.Type::" ");
        COMMIT;
        if Not lPurchHeader.Get(lPurchHeader."Document Type"::Order, pPurcRcptHdr."Order No.") Then lPurchHeader.Init();
        if NOT pPurcRcptHdr.Contabilizado THEN exit;
        liGenJnlLineDocType := 0;
        lCGenJnlLineDocNo := pPurcRcptHdr."No.";
        ltGenJnlLineExtDocNo := pPurcRcptHdr."Vendor Shipment No.";
        lDTotal := 0;
        lDTotalACY := 0;
        lPurchRcptLineTMP.SETRANGE(lPurchRcptLineTMP."Document No.", pPurcRcptHdr."No.");
        // {lGlEntry.SETCURRENTKEY(lGlEntry."Transaction No.");
        // lGlEntry.SETRANGE("Document No.", pPurcRcptHdr."No.");
        // lGlEntry.SETRANGE("Document Type",lGlEntry."Document Type"::Receipt);
        // lGlEntry.FINDLAST;
        // ReversalEntry.ReverseAlbaran(lGlEntry."Transaction No.");
        // Contabilizado:=FALSE;
        // MODIFY;
        // EXIT;           }
        //No borro lo que hay
        DesglosarAlbaranes(pPurcRcptHdr, lPurchRcptLineTMP);
        if lPurchRcptLineTMP.FINDFIRST THEN
            REPEAT
                if (lPurchRcptLineTMP.Type.AsInteger() >= lPurchRcptLineTMP.Type::"G/L Account".AsInteger()) AND (lPurchRcptLineTMP."Qty. Rcd. Not Invoiced" <> 0) THEN BEGIN
                    // Copy purchase to Buffer
                    //PurchLineACY.GET(lPurchRcptLineTMP."Document No.",lPurchRcptLineTMP."Line No.");
                    // DocDim.SETRANGE(DocDim."Table ID",DATABASE::"Purchase Line Archive");
                    // DocDim.SETRANGE(DocDim."Document Type",DocDim."Document Type"::Order);
                    // DocDim.SETRANGE(DocDim."Document No.",lPurchRcptLineTMP."Document No.");
                    // DocDim.SETRANGE(DocDim."Line No.",lPurchRcptLineTMP."Line No.");
                    // if DocDim.FINDFIRST THEN REPEAT
                    // TempDocDim.TransferFields(DocDim);
                    // if TempDocDim.INSERT THEN;
                    // UNTIL DocDim.NEXT=0;
                    lPurchArchiveLine.Setrange("Document Type", lPurchArchiveLine."Document Type"::Order);
                    lPurchArchiveLine.Setrange("Document No.", lPurchRcptLineTMP."Document No.");
                    if lPurchArchiveLine.FINDFIRST() Then Begin
                        lPurchRcptLineTMP."Shortcut Dimension 1 Code" := lPurchArchiveLine."Shortcut Dimension 1 Code";
                        lPurchRcptLineTMP."Shortcut Dimension 2 Code" := lPurchArchiveLine."Shortcut Dimension 2 Code";
                        lPurchRcptLineTMP."Shortcut Dimension 3 Code" := lPurchArchiveLine."Shortcut Dimension 3 Code";
                        lPurchRcptLineTMP."Shortcut Dimension 4 Code" := lPurchArchiveLine."Shortcut Dimension 4 Code";
                        lPurchRcptLineTMP."Shortcut Dimension 5 Code" := lPurchArchiveLine."Shortcut Dimension 5 Code";
                        lPurchRcptLineTMP."Dimension Set ID" := lPurchArchiveLine."Dimension Set ID";
                        lPurchRcptLineTMP.Modify();
                    end;
                    FillAlbPostingBuffer(lPurchRcptLineTMP, lPurchRcptLineTMP."Line No.", TempBuffer);
                    UpdInvPostingBuldFFeProduccionesgloNew(TempBuffer, FALineNo, TempBuffer2);

                    // TempDocDim.SETRANGE("Table ID");
                    // TempDocDim.SETRANGE("Line No.");
                END;
            UNTIL lPurchRcptLineTMP.NEXT = 0;

        // Post purchase and VAT to G/L entries from Buffer
        liLinecount := 0;
        TempBuffer2.RESET;
        if TempBuffer2.FIND('+') THEN
            REPEAT
                liLinecount := liLinecount + 1;
                //if GUIALLOWED THEN
                //Window.UPDATE(3,liLinecount);

                CASE TempBuffer2."VAT Calculation Type" OF
                    TempBuffer2."VAT Calculation Type"::"Reverse Charge VAT":
                        BEGIN
                            gVATPostingSetup.GET(
                                TempBuffer2."VAT Bus. Posting Group", TempBuffer2."VAT Prod. Posting Group");
                            TempBuffer2."VAT Amount" :=
                                ROUND(
                                (TempBuffer2.Amount -
                                TempBuffer2."Line Discount Amount" -
                                TempBuffer2."Inv. Discount Amount" -
                                TempBuffer2."Pmt. Discount Amount") *
                                gVATPostingSetup."VAT+EC %" / 100);
                            TempBuffer2."VAT Amount (ACY)" :=
                                ROUND(
                                (TempBuffer2."Amount (ACY)" -
                                TempBuffer2."Line Discount Amt. (ACY)" -
                                TempBuffer2."Inv. Discount Amt. (ACY)" -
                                TempBuffer2."Src. Curr. Pmt. Discount Amt.") *
                                gVATPostingSetup."VAT+EC %" / 100, gCurrency."Amount Rounding Precision");
                        END;
                    TempBuffer2."VAT Calculation Type"::"Sales Tax":
                        BEGIN
                            if TempBuffer2."Use Tax" THEN BEGIN
                                TempBuffer2."VAT Amount" :=
                                ROUND(
                                    gcSalesTaxCalculate.CalculateTax(
                                    TempBuffer2."Tax Area Code", TempBuffer2."Tax Group Code",
                                    TempBuffer2."Tax Liable", lPurchHeader."Posting Date",
                                    TempBuffer2.Amount -
                                    TempBuffer2."Line Discount Amount" - TempBuffer2."Inv. Discount Amount" -
                                    TempBuffer2."Pmt. Discount Amount",
                                    TempBuffer2.Quantity, 0));
                                if gGenLedgerSetup."Additional Reporting Currency" <> '' THEN
                                    TempBuffer2."VAT Amount (ACY)" :=
                                    gCurrExchRate.ExchangeAmtLCYToFCY(
                                        lPurchHeader."Posting Date", gGenLedgerSetup."Additional Reporting Currency",
                                        TempBuffer2."VAT Amount", 0);
                            END;
                        END;
                END;

                if lPurchHeader."Prices Including VAT" AND (TempBuffer2."VAT %" <> 0) THEN
                    WITH TempBuffer2 DO BEGIN
                        gDDiscountVATAmount :=
                        ROUND("Line Discount Amount" * "VAT %" / (1 + "VAT %" / 100) / 100);
                        Amount := Amount - gDDiscountVATAmount;
                        "Line Discount Amount" := "Line Discount Amount" - gDDiscountVATAmount;

                        gDDiscountVATAmount :=
                        ROUND(
                            "Line Discount Amt. (ACY)" * "VAT %" / (1 + "VAT %" / 100) / 100,
                            gCurrency."Amount Rounding Precision");
                        "Amount (ACY)" := "Amount (ACY)" - gDDiscountVATAmount;
                        "Line Discount Amt. (ACY)" := "Line Discount Amt. (ACY)" - gDDiscountVATAmount;

                        gDDiscountVATAmount :=
                        ROUND("Inv. Discount Amount" * "VAT %" / (1 + "VAT %" / 100) / 100);
                        Amount := Amount - gDDiscountVATAmount;
                        "Inv. Discount Amount" := "Inv. Discount Amount" - gDDiscountVATAmount;

                        gDDiscountVATAmount :=
                        ROUND(
                            "Src. Curr. Pmt. Discount Amt." * "VAT %" / (1 + "VAT %" / 100) / 100,
                            gCurrency."Amount Rounding Precision");
                        "Amount (ACY)" := "Amount (ACY)" - gDDiscountVATAmount;
                        "Inv. Discount Amt. (ACY)" := "Inv. Discount Amt. (ACY)" - gDDiscountVATAmount;

                        gDDiscountVATAmount :=
                        ROUND(
                            "Inv. Discount Amt. (ACY)" * "VAT %" / (1 + "VAT %" / 100) / 100,
                            gCurrency."Amount Rounding Precision");
                        "Amount (ACY)" := "Amount (ACY)" - gDDiscountVATAmount;
                        "Inv. Discount Amt. (ACY)" := "Inv. Discount Amt. (ACY)" - gDDiscountVATAmount;
                    END;

                gGenJnlLine.INIT;
                gGenJnlLine."Posting Date" := FechaAlbaran(pPurcRcptHdr."No.");
                gGenJnlLine."Document Date" := pPurcRcptHdr."Document Date";
                gGenJnlLine.Description := COPYSTR(pPurcRcptHdr."Posting Description", 1, MAXSTRLEN(gGenJnlLine.Description));
                gGenJnlLine."Reason Code" := pPurcRcptHdr."Reason Code";
                gGenJnlLine."Document Type" := gGenJnlLine."Document Type"::Receipt;
                gGenJnlLine."Document No." := pPurcRcptHdr."No.";
                gGenJnlLine."External Document No." := pPurcRcptHdr."Vendor Shipment No.";
                gGenJnlLine."Tax Area Code" := pPurcRcptHdr."No.";
                gGenJnlLine."Account No." := TempBuffer2."G/L Account";
                gGenJnlLine."System-Created Entry" := TempBuffer2."System-Created Entry";
                gGenJnlLine.Amount := -TempBuffer2.Amount;
                lDTotal := lDTotal + TempBuffer2.Amount;
                gGenJnlLine."Source Currency Code" := pPurcRcptHdr."Currency Code";
                gGenJnlLine."Source Currency Amount" := -TempBuffer2."Amount (ACY)";
                lDTotalACY := lDTotalACY + TempBuffer2."Amount (ACY)";
                gGenJnlLine.Correction := pPurcRcptHdr.Correction;
                gGenJnlLine."Gen. Posting Type" := gGenJnlLine."Gen. Posting Type"::" ";
                gGenJnlLine."Gen. Bus. Posting Group" := '';//TempBuffer2."Gen. Bus. Posting Group";
                gGenJnlLine."Gen. Prod. Posting Group" := '';// TempBuffer2."Gen. Prod. Posting Group";
                gGenJnlLine."VAT Bus. Posting Group" := '';//TempBuffer2."VAT Bus. Posting Group";
                gGenJnlLine."VAT Prod. Posting Group" := '';//TempBuffer2."VAT Prod. Posting Group";
                gGenJnlLine."Tax Area Code" := TempBuffer2."Tax Area Code";
                gGenJnlLine."Tax Liable" := TempBuffer2."Tax Liable";
                gGenJnlLine."Tax Group Code" := TempBuffer2."Tax Group Code";
                gGenJnlLine."Use Tax" := TempBuffer2."Use Tax";
                gGenJnlLine.Quantity := TempBuffer2.Quantity;
                gGenJnlLine."VAT Calculation Type" := TempBuffer2."VAT Calculation Type";
                gGenJnlLine."VAT Base Amount" := -TempBuffer2."VAT Base Amount";
                gGenJnlLine."VAT Base Discount %" := pPurcRcptHdr."VAT Base Discount %";
                gGenJnlLine."Source Curr. VAT Base Amount" := -TempBuffer2."VAT Base Amount (ACY)";
                gGenJnlLine."VAT Amount" := -TempBuffer2."VAT Amount";
                gGenJnlLine."Source Curr. VAT Amount" := -TempBuffer2."VAT Amount (ACY)";
                gGenJnlLine."VAT Difference" := -TempBuffer2."VAT Difference";
                gGenJnlLine."VAT Posting" := gGenJnlLine."VAT Posting"::"Manual VAT Entry";
                gGenJnlLine."Shortcut Dimension 1 Code" := TempBuffer2."Global Dimension 1 Code";
                gGenJnlLine."Shortcut Dimension 2 Code" := TempBuffer2."Global Dimension 2 Code";
                //ASC
                gGenJnlLine."Shortcut Dimension 3 Code" := TempBuffer2."Global Dimension 3 Code";
                gGenJnlLine."Shortcut Dimension 4 Code" := TempBuffer2."Global Dimension 4 Code";
                gGenJnlLine."Shortcut Dimension 5 Code" := TempBuffer2."Global Dimension 5 Code";
                gGenJnlLine."Dimension Set ID" := TempBuffer2."Dimension Set ID";
                gGenJnlLine.Circuito := TRUE;
                gGenJnlLine."Job No." := TempBuffer2."Job No.";
                gGenJnlLine."Source Code" := gCSrcCode;
                gGenJnlLine."Sell-to/Buy-from No." := pPurcRcptHdr."Buy-from Vendor No.";
                gGenJnlLine."Bill-to/Pay-to No." := pPurcRcptHdr."Pay-to Vendor No.";
                gGenJnlLine."Country/Region Code" := pPurcRcptHdr."VAT Country/Region Code";
                gGenJnlLine."VAT Registration No." := pPurcRcptHdr."VAT Registration No.";
                gGenJnlLine."Source Type" := gGenJnlLine."Source Type"::Vendor;
                gGenJnlLine."Source No." := pPurcRcptHdr."Pay-to Vendor No.";
                gGenJnlLine."Posting No. Series" := '';
                gGenJnlLine."IC Partner Code" := '';//"Pay-to IC Partner Code";
                gGenJnlLine."Ship-to/Order Address Code" := pPurcRcptHdr."Order Address Code";

                gGenJnlLine."Payment Terms Code" := pPurcRcptHdr."Payment Terms Code";
                gGenJnlLine."Payment Method Code" := pPurcRcptHdr."Payment Method Code";

                gGenJnlLine."Generate AutoInvoices" := FALSE;//"Generate Autoinvoices" OR "Generate Autocredit Memo";
                gGenJnlLine."AutoDoc. No." := lCAutoDocNo;

                if TempBuffer2.Type = TempBuffer2.Type::"Fixed Asset" THEN BEGIN
                    gGenJnlLine."Account Type" := gGenJnlLine."Account Type"::"Fixed Asset";
                    if TempBuffer2."FA Posting Type" =
                        TempBuffer2."FA Posting Type"::"Acquisition Cost"
                    THEN
                        gGenJnlLine."FA Posting Type" := gGenJnlLine."FA Posting Type"::"Acquisition Cost";
                    if TempBuffer2."FA Posting Type" =
                        TempBuffer2."FA Posting Type"::Maintenance
                    THEN
                        gGenJnlLine."FA Posting Type" := gGenJnlLine."FA Posting Type"::Maintenance;
                    gGenJnlLine."FA Posting Date" := TempBuffer2."FA Posting Date";
                    gGenJnlLine."Depreciation Book Code" := TempBuffer2."Depreciation Book Code";
                    gGenJnlLine."Salvage Value" := TempBuffer2."Salvage Value";
                    gGenJnlLine."Depr. until FA Posting Date" := TempBuffer2."Depr. until FA Posting Date";
                    gGenJnlLine."Depr. Acquisition Cost" := TempBuffer2."Depr. Acquisition Cost";
                    gGenJnlLine."Maintenance Code" := TempBuffer2."Maintenance Code";
                    gGenJnlLine."Insurance No." := TempBuffer2."Insurance No.";
                    gGenJnlLine."Budgeted FA No." := TempBuffer2."Budgeted FA No.";
                    gGenJnlLine."Duplicate in Depreciation Book" := TempBuffer2."Duplicate in Depreciation Book";
                    gGenJnlLine."Use Duplication List" := TempBuffer2."Use Duplication List";
                END;

                RungcGenJnlPostLine(gGenJnlLine);//, TempBuffer2."Dimension Entry No.");
                                                 // if FAInsertDiscountAmount(TempBuffer2, DeprBook) THEN
                                                 //     FAPostDiscountAmount(
                                                 //         gGenJnlLine,
                                                 //         TempBuffer2."Line Discount Amount" + TempBuffer2."Inv. Discount Amount",
                                                 //         TempBuffer2."Line Discount Amt. (ACY)" + TempBuffer2."Inv. Discount Amt. (ACY)",
                                                 //         TempBuffer2."Dimension Entry No.");
                gGenJnlLine."Account Type" := gGenJnlLine."Account Type"::"G/L Account";
                gGenJnlLine.VALIDATE("FA Posting Type", gGenJnlLine."FA Posting Type"::" ");
                // if FAInsertDiscountAmount(TempBuffer2, DeprBook) THEN
                //     PostDiscount(
                //         TempBuffer2."FA Discount Account",
                //         (TempBuffer2."Line Discount Amount" + TempBuffer2."Inv. Discount Amount"),
                //         (TempBuffer2."Line Discount Amt. (ACY)" + TempBuffer2."Inv. Discount Amt. (ACY)"),
                //         TempBuffer2."Dimension Entry No.");
                if (TempBuffer2."Line Discount Amount" <> 0) OR
                (TempBuffer2."Line Discount Amt. (ACY)" <> 0)
                THEN
                    PostDiscount(
                        TempBuffer2."Line Discount Account",
                        -TempBuffer2."Line Discount Amount",
                        -TempBuffer2."Line Discount Amt. (ACY)",
                        TempBuffer2."Dimension Entry No.", lPurchHeader);
                if (TempBuffer2."Inv. Discount Amount" <> 0) OR
                (TempBuffer2."Inv. Discount Amt. (ACY)" <> 0)
                THEN
                    PostDiscount(
                        TempBuffer2."Inv. Discount Account",
                        -TempBuffer2."Inv. Discount Amount",
                        -TempBuffer2."Inv. Discount Amt. (ACY)",
                        TempBuffer2."Dimension Entry No.", lPurchHeader);
                if TempBuffer2."Pmt. Discount Amount" <> 0 THEN
                    PostDiscount(
                        TempBuffer2."Pmt. Discount Account",
                        -TempBuffer2."Pmt. Discount Amount",
                        -TempBuffer2."Src. Curr. Pmt. Discount Amt.",
                        TempBuffer2."Dimension Entry No.", lPurchHeader);
            UNTIL TempBuffer2.Next(-1) = 0;

        TempBuffer2.DELETEALL;

        // Check External Document number
        // {if gPurchSetup."Ext. Doc. No. Mandatory" OR
        // (gGenJnlLineExtDocNo <> '')
        // THEN BEGIN
        // VendLedgEntry.RESET;
        // VendLedgEntry.SETCURRENTKEY("External Document No.");
        // VendLedgEntry.SETRANGE("Document Type",gGenJnlLineDocType);
        // VendLedgEntry.SETRANGE("External Document No.",gGenJnlLineExtDocNo);
        // VendLedgEntry.SETRANGE("Vendor No.","Pay-to Vendor No.");
        // if VendLedgEntry.FINDFIRST THEN
        //     ERROR(
        //     Text016,
        //     VendLedgEntry."Document Type",gGenJnlLineExtDocNo);
        // END;}

        // Post vendor entries
        //if GUIALLOWED THEN
        //Window.UPDATE(4,1);
        gGenJnlLine.INIT;
        gGenJnlLine."Posting Date" := FechaAlbaran(pPurcRcptHdr."No.");
        gGenJnlLine."Document Date" := pPurcRcptHdr."Document Date";
        gGenJnlLine.Description := COPYSTR(pPurcRcptHdr."Posting Description", 1, MAXSTRLEN(gGenJnlLine.Description));
        gGenJnlLine."Shortcut Dimension 1 Code" := pPurcRcptHdr."Shortcut Dimension 1 Code";
        gGenJnlLine."Shortcut Dimension 2 Code" := pPurcRcptHdr."Shortcut Dimension 2 Code";
        //ASC
        gGenJnlLine."Shortcut Dimension 3 Code" := pPurcRcptHdr."Shortcut Dimension 3 Code";
        gGenJnlLine."Shortcut Dimension 4 Code" := pPurcRcptHdr."Shortcut Dimension 4 Code";
        gGenJnlLine."Shortcut Dimension 5 Code" := pPurcRcptHdr."Shortcut Dimension 5 Code";
        gGenJnlLine."Dimension Set ID" := pPurcRcptHdr."Dimension Set ID";
        gGenJnlLine.Circuito := TRUE;
        gGenJnlLine."Reason Code" := pPurcRcptHdr."Reason Code";
        gGenJnlLine."Account Type" := gGenJnlLine."Account Type"::"G/L Account";
        lVendor.GET(pPurcRcptHdr."Pay-to Vendor No.");
        lVendorPostingGroup.GET(lVendor."Vendor Posting Group");
        gGenJnlLine."Account No." := lVendorPostingGroup.FPR;
        gGenJnlLine."Document Type" := gGenJnlLine."Document Type"::Receipt;
        gGenJnlLine."Document No." := lCGenJnlLineDocNo;
        gGenJnlLine."Tax Area Code" := LCGenJnlLineDocNo;
        gGenJnlLine."External Document No." := ltGenJnlLineExtDocNo;
        gGenJnlLine."Currency Code" := pPurcRcptHdr."Currency Code";
        gGenJnlLine.Amount := lDTotal;
        gGenJnlLine."Source Currency Code" := pPurcRcptHdr."Currency Code";
        gGenJnlLine."Source Currency Amount" := lDTotal;
        gGenJnlLine."Amount (LCY)" := lDTotalACY;
        if lPurchHeader."Currency Code" = '' THEN
            gGenJnlLine."Currency Factor" := 1
        ELSE
            gGenJnlLine."Currency Factor" := lPurchHeader."Currency Factor";
        gGenJnlLine."Sales/Purch. (LCY)" := lDTotalACY;
        gGenJnlLine.Correction := pPurcRcptHdr.Correction;
        gGenJnlLine."Inv. Discount (LCY)" := gTotalPurchaseLineLCY."Inv. Discount Amount";
        gGenJnlLine."Pmt. Discount Given/Rec. (LCY)" := gTotalPurchaseLineLCY."Pmt. Discount Amount";
        gGenJnlLine."Sell-to/Buy-from No." := pPurcRcptHdr."Buy-from Vendor No.";
        gGenJnlLine."Bill-to/Pay-to No." := pPurcRcptHdr."Pay-to Vendor No.";
        gGenJnlLine."Salespers./Purch. Code" := pPurcRcptHdr."Purchaser Code";
        gGenJnlLine."System-Created Entry" := TRUE;
        gGenJnlLine."On Hold" := pPurcRcptHdr."On Hold";
        gGenJnlLine."Applies-to Doc. Type" := pPurcRcptHdr."Applies-to Doc. Type";
        gGenJnlLine."Applies-to Bill No." := pPurcRcptHdr."Applies-to Bill No.";
        gGenJnlLine."Applies-to Doc. No." := pPurcRcptHdr."Applies-to Doc. No.";
        gGenJnlLine."Applies-to ID" := '';
        gGenJnlLine."Allow Application" := pPurcRcptHdr."Bal. Account No." = '';
        gGenJnlLine."Payment Terms Code" := pPurcRcptHdr."Payment Terms Code";
        gGenJnlLine."Payment Method Code" := pPurcRcptHdr."Payment Method Code";
#if not CLEAN22
        // TODO: - CLEAN22

#if not CLEAN27 
        gGenJnlLine."Pmt. Address Code" := pPurcRcptHdr."Pay-at Code";
#endif

        // TODO: - CLEAN22
#endif
        gGenJnlLine."Recipient Bank Account" := pPurcRcptHdr."Vendor Bank Acc. Code";
        gGenJnlLine."Due Date" := pPurcRcptHdr."Due Date";
        //gGenJnlLine."Pmt. Discount Date" := "Pmt. Discount Date";
        gGenJnlLine."Payment Discount %" := pPurcRcptHdr."Payment Discount %";
        gGenJnlLine."Source Type" := gGenJnlLine."Source Type"::Vendor;
        gGenJnlLine."Source No." := pPurcRcptHdr."Pay-to Vendor No.";
        gGenJnlLine."Source Code" := gCSrcCode;
        gGenJnlLine."Posting No. Series" := '';
        gGenJnlLine."IC Partner Code" := '';//"Pay-to IC Partner Code";
        gGenJnlLine."Generate AutoInvoices" := FALSE;//"Generate Autoinvoices" OR "Generate Autocredit Memo";
        gGenJnlLine."AutoDoc. No." := lCAutoDocNo;

        // TempJnlLineDim.DELETEALL;
        // TempDocDim.RESET;
        // TempDocDim.SETRANGE("Table ID", DATABASE::"Purchase Line Archive");
        // gcDimMgt.CopyDocDimToJnlLineDim(TempDocDim, TempJnlLineDim);
        gcGenJnlPostLine.RunWithCheck(gGenJnlLine);

        //  END;
        MESSAGE('Se ha contabilizado el retroceso del albarán %1 con fecha %2', pPurcRcptHdr."No.",
        FORMAT(FechaAlbaran(pPurcRcptHdr."No."), 0, '<Day,2>/<Month,2>/<Year>'));
        pPurcRcptHdr.Contabilizado := FALSE;
        pPurcRcptHdr.MODIFY;
    end;

    /// <summary>
    /// FillAlbPostingBuffer.
    /// </summary>
    /// <param name="PurchLine">Record "Purch. Recpt. Line".</param>
    /// <param name="Linea">Integer.</param>
    procedure FillAlbPostingBuffer(pPurchRcptLine: Record "Purch. Rcpt. Line"; piLinea: Integer; var TempBuffer: Record "Invoice Posting Buffer" temporary);
    VAR
        lDAmount: Decimal;
        lDAmountLCY: Decimal;
        lLocation: Record 14;
        lPurchRcptHeader: Record "Purch. Rcpt. Header";
        lVatPostingGroup: Record "VAT Business Posting Group";
        lcContoldeProcesos: Codeunit ControlProcesos;
        FalineNo: Integer;
    BEGIN
        WITH pPurchRcptLine DO BEGIN
            if Not lPurchRcptHeader.Get(pPurchRcptLine."Document No.") then lPurchRcptHeader.Init();
            if "Gen. Bus. Posting Group" = '' Then begin
                "Gen. Bus. Posting Group" := lPurchRcptHeader."Gen. Bus. Posting Group";
            end;
            if ("Gen. Bus. Posting Group" <> gGenPostingSetup."Gen. Bus. Posting Group") OR
               ("Gen. Prod. Posting Group" <> gGenPostingSetup."Gen. Prod. Posting Group")
            THEN
                if NOT gGenPostingSetup.GET("Gen. Bus. Posting Group", "Gen. Prod. Posting Group") THEN BEGIN
                    gGenPostingSetup.GET('NACIONAL', 'SOP.EXT.');
                    "Gen. Bus. Posting Group" := 'NACIONAL';
                END;
            //gGenPostingSetup.INIT;
            if (gGenPostingSetup."Gen. Bus. Posting Group" = '') Or (gGenPostingSetup."Gen. Prod. Posting Group" = '') THEN
                gGenPostingSetup.GET("Gen. Bus. Posting Group", "Gen. Prod. Posting Group");

            CLEAR(TempBuffer);
            TempBuffer.Type := Type;
            if (Type = Type::"G/L Account") OR (Type = Type::"Fixed Asset") THEN
                TempBuffer."G/L Account" := "No."
            ELSE BEGIN
                if NOT lLocation.GET("Location Code") THEN lLocation.INIT;
                if lLocation."Cta. Compras" <> '' THEN BEGIN
                    TempBuffer."G/L Account" := lLocation."Cta. Compras";
                END ELSE BEGIN
                    gGenPostingSetup.Get(pPurchRcptLine."Gen. Bus. Posting Group", pPurchRcptLine."Gen. Prod. Posting Group");
                    gGenPostingSetup.TestField("Purch. Account");
                    TempBuffer."G/L Account" := gGenPostingSetup."Purch. Account";
                END;
            END;
            TempBuffer."System-Created Entry" := TRUE;
            TempBuffer."Gen. Bus. Posting Group" := "Gen. Bus. Posting Group";
            TempBuffer."Gen. Prod. Posting Group" := "Gen. Prod. Posting Group";
            TempBuffer."VAT Bus. Posting Group" := "VAT Bus. Posting Group";
            TempBuffer."VAT Prod. Posting Group" := "VAT Prod. Posting Group";
            TempBuffer."VAT Calculation Type" := "VAT Calculation Type";
            TempBuffer."Global Dimension 1 Code" := pPurchRcptLine."Shortcut Dimension 1 Code";
            TempBuffer."Global Dimension 2 Code" := pPurchRcptLine."Shortcut Dimension 2 Code";
            //ASC
            TempBuffer."Global Dimension 3 Code" := pPurchRcptLine."Shortcut Dimension 3 Code";
            TempBuffer."Global Dimension 4 Code" := pPurchRcptLine."Shortcut Dimension 4 Code";
            TempBuffer."Global Dimension 5 Code" := pPurchRcptLine."Shortcut Dimension 5 Code";
            TempBuffer."Dimension Set ID" := lcContoldeProcesos.GetDefaultDimID2(pPurchRcptLine."Shortcut Dimension 1 Code", pPurchRcptLine."Shortcut Dimension 2 Code",
                                        pPurchRcptLine."Shortcut Dimension 3 Code", pPurchRcptLine."Shortcut Dimension 4 Code", pPurchRcptLine."Shortcut Dimension 5 Code");

            TempBuffer."Job No." := "Job No.";
            if COMPANYNAME in [glUnion, glUATI] THEN
                lDAmount := ("Qty. Rcd. Not Invoiced" * "Direct Unit Cost") * (1 - "Line Discount %" / 100)
            ELSE
                lDAmount := ("Qty. Rcd. Not Invoiced" * "Unit Cost (LCY)");
            if "Line Discount %" = 0 THEN
                lDAmount := ("Qty. Rcd. Not Invoiced" * "Direct Unit Cost");
            lDAmountLCY := ROUND(lDAmount, 0.01, '=');
            TempBuffer.Amount := ROUND(lDAmount, 0.01, '=');
            TempBuffer."VAT Base Amount" := ROUND(lDAmount, 0.01, '=');
            TempBuffer."Amount (ACY)" := lDAmountLCY;
            TempBuffer."VAT Base Amount (ACY)" := lDAmountLCY;
            TempBuffer."VAT Difference" := 0;//"VAT Difference";
            TempBuffer."VAT %" := "VAT %";
            //-SII
            gGenLedgerSetup.GET;
            if gGenLedgerSetup."Activar SII" THEN BEGIN
                if gVATPostingSetup.GET(pPurchRcptLine."VAT Bus. Posting Group", pPurchRcptLine."VAT Prod. Posting Group") THEN;
                if lVatPostingGroup.GET(pPurchRcptLine."VAT Bus. Posting Group") THEN;
                //PurchaseHeader.GET(pPurchRcptLine."Document Type",pPurchRcptLine."Document No.");
                TempBuffer."Tipo factura SII" := lPurchRcptHeader."Tipo factura SII";
                TempBuffer."Clave registro SII recibidas" := lVatPostingGroup."Clave registro SII recibidas";
                TempBuffer."Descripción operación" := lPurchRcptHeader."Descripción operación";
                TempBuffer."Tipo desglose emitidas" := gVATPostingSetup."Tipo desglose emitidas";
                TempBuffer."Sujeta exenta" := gVATPostingSetup."Sujeta exenta";
                TempBuffer."Tipo de operación" := gVATPostingSetup."Tipo de operación";
                TempBuffer."Tipo factura rectificativa" := '';// lPurchRcptHeader."Tipo factura rectificativa";
            END;
            //+SII

            if Type = Type::"Fixed Asset" THEN BEGIN
                TempBuffer."FA Posting Date" := "FA Posting Date";
                TempBuffer."FA Posting Type" := "FA Posting Type";
                TempBuffer."Depreciation Book Code" := "Depreciation Book Code";
                TempBuffer."Salvage Value" := "Salvage Value";
                TempBuffer."Depr. until FA Posting Date" := "Depr. until FA Posting Date";
                TempBuffer."Depr. Acquisition Cost" := "Depr. Acquisition Cost";
                TempBuffer."Maintenance Code" := "Maintenance Code";
                TempBuffer."Insurance No." := "Insurance No.";
                TempBuffer."Budgeted FA No." := "Budgeted FA No.";
                TempBuffer."Duplicate in Depreciation Book" := "Duplicate in Depreciation Book";
                TempBuffer."Use Duplication List" := "Use Duplication List";
            END;
            CASE "VAT Calculation Type" OF
                "VAT Calculation Type"::"Normal VAT", "VAT Calculation Type"::"Full VAT":
                    BEGIN
                        TempBuffer."VAT Amount" := lDAmount * (pPurchRcptLine."VAT %" / 100);
                        TempBuffer."VAT Amount (ACY)" :=
                         lDAmountLCY * (pPurchRcptLine."VAT %" / 100);
                    END;
                "VAT Calculation Type"::"Reverse Charge VAT":
                    ; // Reverse Charge VAT is calculated later, based on totals
                "VAT Calculation Type"::"Sales Tax":
                    BEGIN
                        if NOT "Use Tax" THEN BEGIN  // Use Tax is calculated later, based on totals
                            TempBuffer."VAT Amount" := lDAmount * (pPurchRcptLine."VAT %" / 100);
                            TempBuffer."VAT Amount (ACY)" :=
                              lDAmountLCY * (pPurchRcptLine."VAT %" / 100);
                        END;
                        TempBuffer."Tax Area Code" := "Tax Area Code";
                        TempBuffer."Tax Liable" := "Tax Liable";
                        TempBuffer."Tax Group Code" := "Tax Group Code";
                        TempBuffer."Use Tax" := "Use Tax";
                        TempBuffer.Quantity := pPurchRcptLine."Qty. Rcd. Not Invoiced";
                    END;
            END;

            if gPurchSetup."Post Invoice Discount" THEN BEGIN
                TempBuffer.Amount := TempBuffer.Amount;// + "Inv. Discount Amount";
                TempBuffer."Inv. Discount Amount" := 0;//"Inv. Discount Amount";
                TempBuffer."Amount (ACY)" :=
                  TempBuffer."Amount (ACY)";// + PurchLineACY."Inv. Discount Amount";
                TempBuffer."Inv. Discount Amt. (ACY)" := 0;//PurchLineACY."Inv. Discount Amount";
                                                           //   {if ("Inv. Discount Amount" <> 0) OR (PurchLineACY."Inv. Discount Amount" <> 0)THEN BEGIN
                                                           //     gGenPostingSetup.TestField("Purch. Inv. Disc. Account");
                                                           //     TempBuffer."Inv. Discount Account" := gGenPostingSetup."Purch. Inv. Disc. Account";
                                                           //   END;}
            END;
            if gPurchSetup."Post Line Discount" THEN BEGIN
                TempBuffer.Amount := TempBuffer.Amount + TempBuffer.Amount * (pPurchRcptLine."Line Discount %" / 100);
                TempBuffer."Line Discount Amount" := TempBuffer.Amount * (pPurchRcptLine."Line Discount %" / 100);
                TempBuffer."Amount (ACY)" :=
                  TempBuffer."Amount (ACY)" + TempBuffer."Amount (ACY)" * (pPurchRcptLine."Line Discount %" / 100);
                TempBuffer."Line Discount Amt. (ACY)" := TempBuffer."Amount (ACY)" * (pPurchRcptLine."Line Discount %" / 100);
                if (TempBuffer.Amount * (pPurchRcptLine."Line Discount %" / 100) <> 0) OR
                (TempBuffer."Amount (ACY)" * (pPurchRcptLine."Line Discount %" / 100) <> 0) THEN BEGIN
                    gGenPostingSetup.Get(pPurchRcptLine."Gen. Bus. Posting Group", pPurchRcptLine."Gen. Prod. Posting Group");
                    gGenPostingSetup.TestField("Purch. Line Disc. Account");
                    TempBuffer."Line Discount Account" := gGenPostingSetup."Purch. Line Disc. Account";
                END;
            END;
            if gPurchSetup."Post Payment Discount" THEN BEGIN
                TempBuffer.Amount := TempBuffer.Amount;// + "Pmt. Discount Amount";
                TempBuffer."Pmt. Discount Amount" := 0;//"Pmt. Discount Amount";
                TempBuffer."Amount (ACY)" :=
                  TempBuffer."Amount (ACY)";// + PurchLineACY."Pmt. Discount Amount";
                TempBuffer."Src. Curr. Pmt. Discount Amt." := 0;//PurchLineACY."Pmt. Discount Amount";
                                                                //   {if (pPurchRcptLine."Pmt. Discount Amount" <> 0) OR (PurchLineACY."Pmt. Discount Amount" <> 0) THEN BEGIN
                                                                //     gGenPostingSetup.TestField("Purch. Pmt. Disc. Credit Acc.");
                                                                //     TempBuffer."Pmt. Discount Account" := gGenPostingSetup."Purch. Pmt. Disc. Credit Acc.";
                                                                //   END;}
            END;

            //  TempBuffer."FA Discount Account" := FASetDiscountAccount(PurchLine);
            // TempDocDim.SETRANGE("Table ID",DATABASE::"Purchase Line Archive");
            // TempDocDim.SETRANGE("Line No.",Linea);

        END;
    end;

    /// <summary>
    /// DesglosarAlbaranes.
    /// </summary>
    /// <param name="VAR Albaran">Record "Purch. Rcpt. Header".</param>
    /// <param name="VAR pPurchRcptLineTMP">Record "Purch. Recpt. Line" TEMPORARY.</param>
    procedure DesglosarAlbaranes(VAR pPurchaseRcptHdr: Record "Purch. Rcpt. Header"; VAR pPurchRcptLineTMP: Record "Purch. Rcpt. Line" TEMPORARY);
    VAR
        lPurchRcptLineTMP: Record "Purch. Rcpt. Line" TEMPORARY;
        lReserva: Record Reserva;
        lPurchRcptLineTMPt: Record "Purch. Rcpt. Line" TEMPORARY;
        lPurchaseLineArch: Record "Purchase Line Archive";
        lPurchRcptHdr: Record "Purch. Rcpt. Header";
        lPurchHeaderArch: Record "Purchase Header Archive";
        iNumeroReservas: Integer;
        lResource: Record Resource;
        lPurchRcptLineTMPt2: Record "Purch. Rcpt. Line" TEMPORARY;
        liDiasReserva: Integer;
        ldFI: Date;
        ldFF: Date;
        lDImporte: Decimal;
        lDImporteIvaIncluido: Decimal;
        lGeneralPostingSetup: Record "General Posting Setup";
        lPurchRcptLineOrg: Record "Purch. Rcpt. Line";
        lJob: Record 167;
        lCJob: Code[20];
        ltCmp: Text[30];
        lDimValue: Record "Dimension Value";
        lDimValue2: Record "Dimension Value";
        lGenProdPostGrp: Record 251;
        lPurchaseHeader: Record "Purchase Header";
        liLinea: Integer;
        lCJob2: Code[20];
        lPurchaseLineArtchTMP: Record "Purchase Line Archive" TEMPORARY;
        lDImporteOri: Decimal;
        lDImporteNuevo: Decimal;
        lPurchRcptLine: Record "Purch. Rcpt. Line";
        lCCuenta: Text[20];
        lbAgrupado: Boolean;
        lDefDim: Record "Default Dimension";
        lcContoldeProcesos: Codeunit ControlProcesos;
    BEGIN
        WITH pPurchaseRcptHdr DO BEGIN
            if not lPurchaseHeader.Get(lPurchaseHeader."Document Type"::Order, pPurchaseRcptHdr."Order No.") then lPurchaseHeader.Init();
            lPurchRcptLine.SETRANGE(lPurchRcptLine."Document No.", pPurchaseRcptHdr."No.");
            if lPurchRcptLine.FINDFIRST THEN
                REPEAT
                    if COMPANYNAME in [glUnion, glUATI] THEN
                        lDImporteOri += (lPurchRcptLine."Qty. Rcd. Not Invoiced" * lPurchRcptLine."Direct Unit Cost") * (1 - lPurchRcptLine."Line Discount %" / 100)
                    ELSE
                        lDImporteOri += (lPurchRcptLine."Qty. Rcd. Not Invoiced" * lPurchRcptLine."Unit Cost (LCY)");
                UNTIL lPurchRcptLine.NEXT = 0;
            lPurchaseLineArch.SETRANGE(lPurchaseLineArch."Document Type", lPurchaseLineArch."Document Type"::Order);
            lPurchaseLineArch.SETRANGE(lPurchaseLineArch."Document No.", "No.");
            lPurchaseLineArch.DELETEALL;
            if lPurchHeaderArch.GET(lPurchHeaderArch."Document Type"::Order, "No.") THEN lPurchHeaderArch.DELETE;
            lPurchRcptLineOrg.SETRANGE(lPurchRcptLineOrg."Document No.", "No.");
            if lPurchRcptLineOrg.FINDFIRST THEN
                REPEAT
                    lPurchRcptLineOrg."Line Amount" := lPurchRcptLineOrg.Quantity * lPurchRcptLineOrg."Direct Unit Cost" * (1 - lPurchRcptLineOrg."Line Discount %" / 100);
                    lPurchRcptLineOrg.Amount := lPurchRcptLineOrg."Line Amount";
                    lPurchRcptLineOrg."Amount Including VAT" := lPurchRcptLineOrg."Line Amount" * (1 + lPurchRcptLineOrg."VAT %" / 100);
                    lPurchRcptLineOrg."Line Discount Amount" := lPurchRcptLineOrg.Quantity * lPurchRcptLineOrg."Direct Unit Cost" * (lPurchRcptLineOrg."Line Discount %" / 100);
                    if lPurchRcptLineOrg."Job No." = '' THEN lPurchRcptLineOrg."Job No." := pPurchaseRcptHdr."Nº Proyecto";
                    if lPurchRcptLineOrg."No." = '' THEN lPurchRcptLineOrg.Type := lPurchRcptLineOrg.Type::" ";
                    lPurchRcptLineOrg.MODIFY;
                    lPurchRcptLineTMP := lPurchRcptLineOrg;
                    lPurchRcptLineTMP.Recurso := lPurchRcptLineOrg."No.";
                    if (lPurchRcptLineOrg.Type = lPurchRcptLineOrg.Type::Resource)
                    OR (lPurchRcptLineOrg.Recurso <> '')
                    THEN BEGIN
                        if (lPurchRcptLineOrg."No." = '') and (lPurchRcptLineOrg.Recurso <> '') THEN BEGIN
                            lPurchRcptLineTMP.Type := lPurchRcptLineTMP.Type::Resource;
                            lPurchRcptLineTMP."No." := lPurchRcptLineOrg.Recurso;
                            lPurchRcptLineTMP.Recurso := lPurchRcptLineOrg."No.";
                            lPurchRcptLineOrg.Type := lPurchRcptLineTMP.Type::Resource;
                            lPurchRcptLineOrg."No." := lPurchRcptLineOrg.Recurso;
                            lPurchRcptLineOrg.Recurso := lPurchRcptLineTMP.Recurso;
                        END else begin
                            lPurchRcptLineTMP.Recurso := lPurchRcptLineOrg."No.";
                            lPurchRcptLineOrg.Recurso := lPurchRcptLineTMP.Recurso;
                        end;
                        if lResource.GET(lPurchRcptLineOrg."No.") THEN BEGIN
                            lDefDim.SetRange("Table ID", Database::Resource);
                            lDefDim.SetRange("No.", lResource."No.");
                            gGenLedgerSetup.Get();
                            if lDefDim.FINDFIRST() then
                                repeat
                                    if lDefDim."Dimension Code" = gGenLedgerSetup."Global Dimension 1 Code" then
                                        lPurchRcptLineTMP."Shortcut Dimension 1 Code" := lDefDim."Dimension Value Code";
                                    if lDefDim."Dimension Code" = gGenLedgerSetup."Global Dimension 2 Code" then
                                        lPurchRcptLineTMP."Shortcut Dimension 2 Code" := lDefDim."Dimension Value Code";
                                    if lDefDim."Dimension Code" = gGenLedgerSetup."Shortcut Dimension 3 Code" then
                                        lPurchRcptLineTMP."Shortcut Dimension 3 Code" := lDefDim."Dimension Value Code";
                                    if lDefDim."Dimension Code" = gGenLedgerSetup."Shortcut Dimension 4 Code" then
                                        lPurchRcptLineTMP."Shortcut Dimension 4 Code" := lDefDim."Dimension Value Code";
                                    if lDefDim."Dimension Code" = gGenLedgerSetup."Shortcut Dimension 5 Code" then
                                        lPurchRcptLineTMP."Shortcut Dimension 5 Code" := lDefDim."Dimension Value Code";
                                until lDefDim.Next() = 0;
                            // lPurchRcptLineTMP."Shortcut Dimension 1 Code" := lResource."Global Dimension 1 Code";
                            // lPurchRcptLineTMP."Shortcut Dimension 2 Code" := lResource."Global Dimension 2 Code";
                            // lPurchRcptLineTMP."Shortcut Dimension 3 Code" := lResource."Global Dimension 3 Code";
                            // lPurchRcptLineTMP."Shortcut Dimension 4 Code" := lResource."Global Dimension 4 Code";
                            // lPurchRcptLineTMP."Shortcut Dimension 5 Code" := lResource."Global Dimension 5 Code";
                            if (lResource."Empresa Origen" <> COMPANYNAME) AND (lResource."Empresa Origen" <> '') THEN BEGIN
                                lPurchRcptLineTMP."No." := lResource."Nº En Empresa origen";
                                lPurchRcptLineTMP."Empresa Origen" := lResource."Empresa Origen";
                                recuperaproyecto(lJob, lPurchRcptLineOrg."Job No.", lResource);
                                lPurchRcptLineTMP."Proyecto Origen" := lJob."No.";

                                lResource.CHANGECOMPANY(lResource."Empresa Origen");
                                if Not lResource.GET(lPurchRcptLineTMP."No.") Then begin
                                    lResource.Init();
                                end;
                                lDefDim.ChangeCompany(lResource."Empresa Origen");
                                lDefDim.SetRange("Table ID", Database::Resource);
                                lDefDim.SetRange("No.", lResource."No.");
                                gGenLedgerSetup.Get();
                                if lDefDim.FINDFIRST() then
                                    repeat
                                        if lDefDim."Dimension Code" = gGenLedgerSetup."Global Dimension 1 Code" then
                                            lPurchRcptLineTMP."Shortcut Dimension 1 Code" := lDefDim."Dimension Value Code";
                                        if lDefDim."Dimension Code" = gGenLedgerSetup."Global Dimension 2 Code" then
                                            lPurchRcptLineTMP."Shortcut Dimension 2 Code" := lDefDim."Dimension Value Code";
                                        if lDefDim."Dimension Code" = gGenLedgerSetup."Shortcut Dimension 3 Code" then
                                            lPurchRcptLineTMP."Shortcut Dimension 3 Code" := lDefDim."Dimension Value Code";
                                        if lDefDim."Dimension Code" = gGenLedgerSetup."Shortcut Dimension 4 Code" then
                                            lPurchRcptLineTMP."Shortcut Dimension 4 Code" := lDefDim."Dimension Value Code";
                                        if lDefDim."Dimension Code" = gGenLedgerSetup."Shortcut Dimension 5 Code" then
                                            lPurchRcptLineTMP."Shortcut Dimension 5 Code" := lDefDim."Dimension Value Code";
                                    until lDefDim.Next() = 0;
                                // lPurchRcptLineTMP."Shortcut Dimension 1 Code" := lResource."Global Dimension 1 Code";
                                // lPurchRcptLineTMP."Shortcut Dimension 2 Code" := lResource."Global Dimension 2 Code";
                                // lPurchRcptLineTMP."Shortcut Dimension 3 Code" := lResource."Global Dimension 3 Code";
                                // lPurchRcptLineTMP."Shortcut Dimension 4 Code" := lResource."Global Dimension 4 Code";
                                // lPurchRcptLineTMP."Shortcut Dimension 5 Code" := lResource."Global Dimension 5 Code";
                            END else
                                ProyectoEmpresa(lJob, lPurchRcptLineOrg."Job No.", pPurchaseRcptHdr."Nº Proyecto");
                        END;
                    END;
                    lPurchRcptLineTMP.Recurso := lPurchRcptLineTMP."No.";
                    if lPurchaseHeader.GET(lPurchaseHeader."Document Type"::Order, pPurchaseRcptHdr."Order No.") THEN BEGIN
                        if lPurchRcptLineTMP."Fecha inicial recurso" = 0D THEN lPurchRcptLineTMP."Fecha inicial recurso" := lPurchaseHeader."Fecha inicial proyecto";
                        if lPurchRcptLineTMP."Fecha Final recurso" = 0D THEN lPurchRcptLineTMP."Fecha Final recurso" := lPurchaseHeader."Fecha Fin proyecto";
                        if lPurchRcptLineTMP."Fecha inicial recurso" = 0D THEN lPurchRcptLineTMP."Fecha inicial recurso" := lJob."Starting Date";
                        if lPurchRcptLineTMP."Fecha Final recurso" = 0D THEN lPurchRcptLineTMP."Fecha Final recurso" := lJob."Ending Date";
                    END;
                    lPurchRcptLineTMP.INSERT;
                    lResource.CHANGECOMPANY(COMPANYNAME);
                    If Not lResource.Get(lPurchRcptLineOrg."No.") Then lResource.Init;
                    gRecursoAgrupado := lResource."Recurso Agrupado";
                UNTIL lPurchRcptLineOrg.NEXT = 0;

            //Recorro la tabla de lineas de factura para buscar si tiene recursos agrupadod
            lPurchRcptLineTMP.SETRANGE(lPurchRcptLineTMP."Document No.", "No.");
            liLinea := 10000;
            if lPurchRcptLineTMP.FINDFIRST THEN
                REPEAT
                    gRecursoAgrupado := false;
                    if lPurchRcptLineTMP."Empresa Origen" <> '' THEN BEGIN
                        lReserva.CHANGECOMPANY(lPurchRcptLineTMP."Empresa Origen");
                        lCJob := lPurchRcptLineTMP."Proyecto Origen";
                        lJob.ChangeCompany(lPurchRcptLineTMP."Empresa Origen");
                        lResource.CHANGECOMPANY(lPurchRcptLineTMP."Empresa Origen");
                        If Not lResource.Get(lPurchRcptLineTMP."No.") Then lResource.Init;
                        gRecursoAgrupado := lResource."Recurso Agrupado";
                    END ELSE BEGIN
                        lReserva.CHANGECOMPANY(COMPANYNAME);
                        lJob.ChangeCompany(Companyname);
                        lResource.ChangeCompany(CompanyName);
                        If not lResource.Get(lPurchRcptLineTMP."No.") Then lResource.Init;
                        lCJob := "Nº Proyecto";

                    END;
                    lReserva.RESET;

                    lReserva.SETCURRENTKEY(lReserva."Nº Proyecto", lReserva."Recurso Agrupado");
                    If gRecursoAgrupado then begin
                        lReserva.SETRANGE(lReserva."Recurso Agrupado", lPurchRcptLineTMP."No.");
                        lReserva.SETRANGE(lReserva."Linea Agrupado", lPurchRcptLineTMP."Line No.");
                    end;
                    IF NOT lReserva.FINDFIRST THEN lReserva.SETRANGE(lReserva."Linea Agrupado");
                    if lCJob = '' THEN
                        lReserva.SETRANGE(lReserva."Nº Proyecto", 'KKDLVK')
                    ELSE
                        lReserva.SETRANGE(lReserva."Nº Proyecto", lCJob);
                    lReserva.SETFILTER(lReserva."Fecha inicio", '<=%1', lPurchRcptLineTMP."Fecha Final recurso");
                    lReserva.SETFILTER(lReserva."Fecha Fin", '>=%1', lPurchRcptLineTMP."Fecha inicial recurso");
                    If Not lJob.Get(lCJob) Then lJob.Init;
                    If NOT lReserva.FINDFIRST Then lJob."Fechas Flexibles" := true;
                    if lJob."Fechas Flexibles" THEN begin
                        lReserva.SetRange("Fecha inicio");
                        lReserva.SetRange("Fecha Fin");
                        lReserva.SETRANGE(lReserva."Linea Agrupado");
                    end;
                    gDTotalliDiasReservas[1] := 0;
                    //recupero las fechas
                    if lReserva.FINDFIRST THEN
                        REPEAT
                            iNumeroReservas := iNumeroReservas + 1;
                            ldFI := lReserva."Fecha inicio";
                            ldFF := lReserva."Fecha Fin";
                            if lPurchRcptLineTMP."Fecha inicial recurso" = 0D then
                                lPurchRcptLineTMP."Fecha inicial recurso" := ldfI;
                            if lPurchRcptLineTMP."Fecha Final recurso" = 0D then
                                lPurchRcptLineTMP."Fecha Final recurso" := ldFF;
                            lbAgrupado := TRUE;
                            if ldFI <= lPurchRcptLineTMP."Fecha inicial recurso" THEN
                                ldFI := lPurchRcptLineTMP."Fecha inicial recurso";
                            ldFF := lReserva."Fecha Fin";
                            if ldFF >= lPurchRcptLineTMP."Fecha Final recurso" THEN
                                ldFF := lPurchRcptLineTMP."Fecha Final recurso";
                            liDiasReserva := ldFF - ldFI;
                            if liDiasReserva = 0 THEN liDiasReserva := 1;
                            gDTotalliDiasReservas[1] := gDTotalliDiasReservas[1] + liDiasReserva;
                        UNTIL lReserva.NEXT = 0;
                    iNumeroReservas := 0;
                    //if lJob."Fechas Flexibles" THEN gDTotalliDiasReservas[1] := lReserva.Count;
                    if gDTotalliDiasReservas[1] = 0 Then gDTotalliDiasReservas[1] := 1;
                    if (lReserva.FINDFIRST) And (gRecursoAgrupado) THEN BEGIN
                        REPEAT
                            iNumeroReservas := iNumeroReservas + 1;
                            ldFI := lReserva."Fecha inicio";
                            ldFF := lReserva."Fecha Fin";
                            if ldFI <= lPurchRcptLineTMP."Fecha inicial recurso" THEN
                                ldFI := lPurchRcptLineTMP."Fecha inicial recurso";
                            ldFF := lReserva."Fecha Fin";
                            if ldFF >= lPurchRcptLineTMP."Fecha Final recurso" THEN
                                ldFF := lPurchRcptLineTMP."Fecha Final recurso";
                            //calculo el número de dias
                            liDiasReserva := ldFF - ldFI;
                            // if lJob."Fechas Flexibles" THEN begin
                            //     ldFF := lPurchRcptLineTMP."Fecha Final recurso";
                            //     ldFI := lPurchRcptLineTMP."Fecha inicial recurso";
                            //     liDiasReserva := ldFF - ldFI;
                            // end;
                            if liDiasReserva = 0 THEN liDiasReserva := 1;
                            lPurchRcptLineTMPt := lPurchRcptLineTMP;
                            lPurchRcptLineTMPt."Line No." := liLinea;//lPurchRcptLineTMPt."Line No."+b;
                            lPurchRcptLineTMPt."No." := lReserva."Nº Recurso";
                            lPurchRcptLineTMPt.Quantity := lPurchRcptLineTMP.Quantity;
                            lPurchRcptLineTMPt."Qty. Rcd. Not Invoiced" := lPurchRcptLineTMP."Qty. Rcd. Not Invoiced";

                            lPurchRcptLineTMPt."Direct Unit Cost" := RedondearP(lPurchRcptLineTMP."Direct Unit Cost" / gDTotalliDiasReservas[1] * liDiasReserva, TRUE, lPurchaseHeader);
                            lPurchRcptLineTMPt."Unit Cost" := RedondearP(lPurchRcptLineTMP."Unit Cost" / gDTotalliDiasReservas[1] * liDiasReserva, TRUE, lPurchaseHeader);
                            lPurchRcptLineTMPt."Unit Cost (LCY)" := RedondearP(lPurchRcptLineTMP."Unit Cost (LCY)" / gDTotalliDiasReservas[1] * liDiasReserva, TRUE, lPurchaseHeader);
                            lPurchRcptLineTMPt."Line Discount Amount" := RedondearP(lPurchRcptLineTMP."Line Discount Amount" / gDTotalliDiasReservas[1] * liDiasReserva, FALSE, lPurchaseHeader);

                            lPurchRcptLineTMPt.Amount := RedondearP(lPurchRcptLineTMP.Amount / gDTotalliDiasReservas[1] * liDiasReserva, FALSE, lPurchaseHeader);
                            lPurchRcptLineTMPt."Amount Including VAT" := lPurchRcptLineTMPt.Amount * (1 + lPurchRcptLineTMPt."VAT %" / 100);
                            lPurchRcptLineTMPt."Line Amount" := RedondearP(lPurchRcptLineTMP."Line Amount" / gDTotalliDiasReservas[1] * liDiasReserva, FALSE, lPurchaseHeader);
                            if lPurchRcptLineTMP."Empresa Origen" <> '' THEN BEGIN
                                lResource.CHANGECOMPANY(lPurchRcptLineTMP."Empresa Origen");
                                lDefDim.ChangeCompany(lPurchRcptLineTMP."Empresa Origen");
                            END ELSE BEGIN
                                lResource.CHANGECOMPANY(COMPANYNAME);
                                lDefDim.ChangeCompany(CompanyName);
                            END;
                            if NOT lResource.GET(lReserva."Nº Recurso") THEN BEGIN
                                lResource.RESET;
                                lResource.CHANGECOMPANY(COMPANYNAME);
                                lDefDim.ChangeCompany((CompanyName));
                                if NOT lResource.GET(lReserva."Nº Recurso") then
                                    lResource.ChangeCompany(lPurchRcptLineTMP."Empresa Origen");
                                if not lResource.GET(lReserva."Nº Recurso") Then lResource.Init;
                            END;
                            lDefDim.SetRange("Table ID", Database::Resource);
                            lDefDim.SetRange("No.", lResource."No.");
                            gGenLedgerSetup.Get();
                            if lDefDim.FINDFIRST() then
                                repeat
                                    if lDefDim."Dimension Code" = gGenLedgerSetup."Global Dimension 1 Code" then
                                        lPurchRcptLineTMPt."Shortcut Dimension 1 Code" := lDefDim."Dimension Value Code";
                                    if lDefDim."Dimension Code" = gGenLedgerSetup."Global Dimension 2 Code" then
                                        lPurchRcptLineTMPt."Shortcut Dimension 2 Code" := lDefDim."Dimension Value Code";
                                    if lDefDim."Dimension Code" = gGenLedgerSetup."Shortcut Dimension 3 Code" then
                                        lPurchRcptLineTMPt."Shortcut Dimension 3 Code" := lDefDim."Dimension Value Code";
                                    if lDefDim."Dimension Code" = gGenLedgerSetup."Shortcut Dimension 4 Code" then
                                        lPurchRcptLineTMPt."Shortcut Dimension 4 Code" := lDefDim."Dimension Value Code";
                                    if lDefDim."Dimension Code" = gGenLedgerSetup."Shortcut Dimension 5 Code" then
                                        lPurchRcptLineTMPt."Shortcut Dimension 5 Code" := lDefDim."Dimension Value Code";
                                until lDefDim.Next() = 0;
                            // lPurchRcptLineTMPt."Shortcut Dimension 1 Code" := lResource."Global Dimension 1 Code";
                            // lPurchRcptLineTMPt."Shortcut Dimension 2 Code" := lResource."Global Dimension 2 Code";
                            // lPurchRcptLineTMPt."Shortcut Dimension 3 Code" := lResource."Global Dimension 3 Code";
                            // lPurchRcptLineTMPt."Shortcut Dimension 4 Code" := lResource."Global Dimension 4 Code";
                            // lPurchRcptLineTMPt."Shortcut Dimension 5 Code" := lResource."Global Dimension 5 Code";
                            // lPurchRcptLineTMPt."Gen. Prod. Posting Group" := lResource."Gen. Prod. Posting Group";
                            lPurchRcptLineTMPt."Recurso Agrupado" := lbAgrupado;
                            lPurchRcptLineTMPt.INSERT;
                            liLinea := liLinea + 10000;
                        UNTIL lReserva.NEXT = 0;
                    END ELSE BEGIN
                        //si no es recurso agrupado inserto igualmente la línea
                        lPurchRcptLineTMPt := lPurchRcptLineTMP;
                        lPurchRcptLineTMPt."Line No." := liLinea;
                        lPurchRcptLineTMPt.INSERT;
                        liLinea := liLinea + 10000;
                    END;
                UNTIL lPurchRcptLineTMP.NEXT = 0;
            // Ahora busco si es de producción
            Produccion(lPurchRcptLineTMPt, lPurchRcptLineTMPt2, lResource, "Nº Proyecto", lbAgrupado, lPurchaseHeader."Currency Code");
            if lPurchRcptHdr.GET("No.") THEN BEGIN
                lPurchHeaderArch.TransferFields(lPurchRcptHdr);
                lPurchHeaderArch."Document Type" := lPurchHeaderArch."Document Type"::Order;
                lPurchHeaderArch.INSERT;
            END;
            if lPurchRcptLineTMPt2.FINDFIRST THEN
                REPEAT
                    lPurchaseLineArch.TransferFields(lPurchRcptLineTMPt2);
                    lPurchaseLineArch."Recurso Agrupado" := lPurchRcptLineTMPt2."Recurso Agrupado";
                    lPurchaseLineArch."Document Type" := lPurchaseLineArch."Document Type"::Order;
                    lPurchaseLineArch."Line Amount" := lPurchRcptLineTMPt2."Line Amount";
                    lPurchaseLineArch."Line Discount Amount" := lPurchRcptLineTMPt2."Line Discount Amount";
                    lPurchaseLineArch.Amount := lPurchRcptLineTMPt2.Amount;
                    //lPurchaseLineArch."Inv. Discount Amount":=lPurchRcptLineTMPt2."Inv. Discount Amount";
                    lPurchaseLineArch."Amount Including VAT" := lPurchRcptLineTMPt2."Amount Including VAT";

                    gCArrayDim[1] := lPurchaseLineArch."Shortcut Dimension 1 Code";
                    gCArrayDim[2] := lPurchaseLineArch."Shortcut Dimension 2 Code";
                    gCArrayDim[3] := lPurchaseLineArch."Shortcut Dimension 3 Code";
                    gCArrayDim[4] := lPurchaseLineArch."Shortcut Dimension 4 Code";
                    gCArrayDim[5] := lPurchaseLineArch."Shortcut Dimension 5 Code";
                    if lPurchaseLineArch.Type = lPurchaseLineArch.Type::Resource THEN lPurchaseLineArch."Dimension Set ID" := CompruebaDimensionEnBlanco(gCArrayDim, lPurchaseLineArch."No.");

                    lPurchaseLineArch.INSERT;
                    gGenLedgerSetup.GET;
                    if NOT lDimValue.GET(gGenLedgerSetup."Shortcut Dimension 1 Code", lPurchaseLineArch."Shortcut Dimension 1 Code") THEN BEGIN
                        lDimValue.INIT;
                        lDimValue."Dimension Code" := gGenLedgerSetup."Shortcut Dimension 1 Code";
                        lDimValue.Code := lPurchaseLineArch."Shortcut Dimension 1 Code";
                        lDimValue."Global Dimension No." := 1;
                        if lDimValue.Code <> '' THEN
                            lDimValue.INSERT;
                    END;
                    if NOT lDimValue.GET(gGenLedgerSetup."Shortcut Dimension 2 Code", lPurchaseLineArch."Shortcut Dimension 2 Code") THEN BEGIN
                        lDimValue.INIT;
                        lDimValue."Dimension Code" := gGenLedgerSetup."Shortcut Dimension 2 Code";
                        lDimValue.Code := lPurchaseLineArch."Shortcut Dimension 2 Code";
                        lDimValue."Global Dimension No." := 2;
                        if lDimValue.Code <> '' THEN
                            lDimValue.INSERT;
                    END;
                    if NOT lDimValue.GET(gGenLedgerSetup."Shortcut Dimension 3 Code", lPurchaseLineArch."Shortcut Dimension 3 Code") THEN BEGIN
                        lDimValue.INIT;
                        lDimValue."Dimension Code" := gGenLedgerSetup."Shortcut Dimension 3 Code";
                        lDimValue.Code := lPurchaseLineArch."Shortcut Dimension 3 Code";
                        lDimValue."Global Dimension No." := 3;
                        if lDimValue.Code <> '' THEN
                            lDimValue.INSERT;
                    END;
                    if NOT lDimValue.GET(gGenLedgerSetup."Shortcut Dimension 4 Code", lPurchaseLineArch."Shortcut Dimension 4 Code") THEN BEGIN
                        lDimValue.INIT;
                        lDimValue."Dimension Code" := gGenLedgerSetup."Shortcut Dimension 4 Code";
                        lDimValue.Code := lPurchaseLineArch."Shortcut Dimension 4 Code";
                        lDimValue."Global Dimension No." := 4;
                        if lDimValue.Code <> '' THEN
                            lDimValue.INSERT;
                    END;
                    if NOT lDimValue.GET(gGenLedgerSetup."Shortcut Dimension 5 Code", lPurchaseLineArch."Shortcut Dimension 5 Code") THEN BEGIN
                        lDimValue.INIT;
                        lDimValue."Dimension Code" := gGenLedgerSetup."Shortcut Dimension 5 Code";
                        lDimValue.Code := lPurchaseLineArch."Shortcut Dimension 5 Code";
                        lDimValue."Global Dimension No." := 5;
                        if lDimValue.Code <> '' THEN
                            lDimValue.INSERT;
                    END;
                    if (lPurchRcptLineTMPt2.Type.AsInteger() <> 0) AND (lPurchRcptLineTMPt2."No." <> '') THEN BEGIN
                        if Not lDimValue2.GET(gGenLedgerSetup."Shortcut Dimension 3 Code", lPurchRcptLineTMPt2."Shortcut Dimension 3 Code") Then lDimValue2.Init;
                        if lDimValue2."Gen. Prod. Posting Group" <> '' THEN BEGIN
                            lGenProdPostGrp.RESET;
                            lGenProdPostGrp.CHANGECOMPANY(COMPANYNAME);
                            if NOT lGenProdPostGrp.GET(lPurchRcptLineTMPt2."Gen. Prod. Posting Group") THEN
                                if lDimValue2."Gen. Prod. Posting Group" <> '' Then
                                    lPurchRcptLineTMPt2."Gen. Prod. Posting Group" := lDimValue2."Gen. Prod. Posting Group";
                        END ELSE BEGIN
                            lGenProdPostGrp.CHANGECOMPANY(COMPANYNAME);
                            if NOT lGenProdPostGrp.GET(lPurchRcptLineTMPt2."Gen. Prod. Posting Group") THEN BEGIN
                                if lPurchRcptLineTMPt2."Empresa Origen" = '' THEN
                                    lGenProdPostGrp.CHANGECOMPANY(COMPANYNAME)
                                ELSE
                                    lGenProdPostGrp.CHANGECOMPANY(lPurchRcptLineTMPt2."Empresa Origen");
                                if lGenProdPostGrp.GET(lPurchRcptLineTMPt2."Gen. Prod. Posting Group") THEN BEGIN
                                    lGenProdPostGrp.SETRANGE(lGenProdPostGrp."Filtro Empresa Origen", lPurchRcptLineTMPt2."Empresa Origen");
                                    lGenProdPostGrp.SETRANGE(lGenProdPostGrp."Filtro Empresa Destino", COMPANYNAME);
                                    lGenProdPostGrp.CALCFIELDS(lGenProdPostGrp."Grupo Equivalente");
                                    if lGenProdPostGrp."Grupo Equivalente" = '' THEN
                                        Error(glEquivalencia,
                                         lPurchRcptLineTMPt2."Empresa Origen", COMPANYNAME, lPurchRcptLineTMPt2."Gen. Prod. Posting Group");
                                    lPurchRcptLineTMPt2."Gen. Prod. Posting Group" := lGenProdPostGrp."Grupo Equivalente";
                                END;
                            END;
                        END;
                    END;
                    if lPurchRcptLineTMPt2."Gen. Prod. Posting Group" <> '' Then
                        lPurchaseLineArch."Gen. Prod. Posting Group" := lPurchRcptLineTMPt2."Gen. Prod. Posting Group";
                    if lPurchaseLineArch."Shortcut Dimension 1 Code" <> '' Then
                        lPurchaseLineArch.VALIDATE("Shortcut Dimension 1 Code", lPurchaseLineArch."Shortcut Dimension 1 Code");
                    if lPurchaseLineArch."Shortcut Dimension 2 Code" <> '' Then
                        lPurchaseLineArch.VALIDATE("Shortcut Dimension 2 Code", lPurchaseLineArch."Shortcut Dimension 2 Code");
                    if lPurchaseLineArch."Shortcut Dimension 3 Code" <> '' Then
                        lPurchaseLineArch.VALIDATE("Shortcut Dimension 3 Code", lPurchaseLineArch."Shortcut Dimension 3 Code");
                    if lPurchaseLineArch."Shortcut Dimension 4 Code" <> '' Then
                        lPurchaseLineArch.VALIDATE("Shortcut Dimension 4 Code", lPurchaseLineArch."Shortcut Dimension 4 Code");
                    if lPurchaseLineArch."Shortcut Dimension 5 Code" <> '' Then
                        lPurchaseLineArch.VALIDATE("Shortcut Dimension 5 Code", lPurchaseLineArch."Shortcut Dimension 5 Code");

                    gCArrayDim[1] := lPurchaseLineArch."Shortcut Dimension 1 Code";
                    gCArrayDim[2] := lPurchaseLineArch."Shortcut Dimension 2 Code";
                    gCArrayDim[3] := lPurchaseLineArch."Shortcut Dimension 3 Code";
                    gCArrayDim[4] := lPurchaseLineArch."Shortcut Dimension 4 Code";
                    gCArrayDim[5] := lPurchaseLineArch."Shortcut Dimension 5 Code";
                    if lPurchaseLineArch.Type = lPurchaseLineArch.Type::Resource THEN lPurchaseLineArch."Dimension Set ID" := CompruebaDimensionEnBlanco(gCArrayDim, lPurchaseLineArch."No.");


                    lPurchaseLineArch.MODIFY;
                UNTIL lPurchRcptLineTMPt2.NEXT = 0;
            if lPurchHeaderArch.GET(lPurchHeaderArch."Document Type"::Order, "No.") THEN BEGIN
                lPurchHeaderArch.CALCFIELDS(lPurchHeaderArch.Amount, lPurchHeaderArch."Amount Including VAT");
                CALCFIELDS(Amount, "Amount Including VAT");
                lDImporte := Amount - lPurchHeaderArch.Amount;
                if Abs(lDImporte) > Abs(lPurchHeaderArch.Amount) Then Error(glErrorDesglose);
                lPurchaseLineArch.SETRANGE("Document Type", lPurchaseLineArch."Document Type"::Order);
                lPurchaseLineArch.SETRANGE(lPurchaseLineArch."Document No.", "No.");
                if lPurchaseLineArch.FINDFIRST THEN BEGIN
                    REPEAT
                        if lPurchaseLineArch."Unit Cost (LCY)" = 0 Then lPurchaseLineArch."Unit Cost (LCY)" := ROUND(lPurchaseLineArch."Direct Unit Cost" * (1 - lPurchaseLineArch."Line Discount %" / 100), 0.01, '=');
                        if COMPANYNAME in [glUnion, glUATI] THEN
                            lDImporteNuevo += ROUND((lPurchaseLineArch."Qty. Rcd. Not Invoiced" * lPurchaseLineArch."Direct Unit Cost") * (1 - lPurchaseLineArch."Line Discount %" / 100), 0.01, '=')
                        ELSE
                            if lPurchaseLineArch."Line Discount %" = 0 THEN
                                lDImporteNuevo += ROUND((lPurchaseLineArch."Qty. Rcd. Not Invoiced" * lPurchaseLineArch."Direct Unit Cost"), 0.01, '=')
                            ELSE
                                lDImporteNuevo += ROUND((lPurchaseLineArch."Qty. Rcd. Not Invoiced" * lPurchaseLineArch."Unit Cost (LCY)"), 0.01, '=');
                        lPurchaseLineArch.Modify();
                    UNTIL lPurchaseLineArch.NEXT = 0;
                    lDImporte := lDImporteOri - lDImporteNuevo;
                END;
                lDImporteIvaIncluido := "Amount Including VAT" - lPurchHeaderArch."Amount Including VAT";
                lPurchRcptLineOrg.SETRANGE(lPurchRcptLineOrg."Document No.", "No.");
                lPurchRcptLineOrg.SETRANGE(lPurchRcptLineOrg.Type, lPurchRcptLineOrg.Type::Resource);
                if NOT lPurchRcptLineOrg.FINDFIRST THEN
                    lPurchRcptLineOrg.SETFILTER(lPurchRcptLineOrg.Type, '<>%1', lPurchRcptLineOrg.Type::" ");
                if lPurchRcptLineOrg.FINDFIRST THEN BEGIN
                    if (lDImporte <> 0) OR (lDImporteIvaIncluido <> 0) THEN BEGIN
                        lPurchaseLineArch.SETRANGE("Document Type", lPurchaseLineArch."Document Type"::Order);
                        lPurchaseLineArch.SETRANGE(lPurchaseLineArch."Document No.", "No.");
                        lPurchaseLineArch.FINDLAST;
                        gDTotalliDiasReservas[1] := lPurchaseLineArch."Line No.";
                        lPurchaseLineArch.SETRANGE(lPurchaseLineArch.Quantity, 0.0001, 9999);
                        lPurchaseLineArch.FINDLAST;
                        lResource.RESET;
                        lResource.CHANGECOMPANY(COMPANYNAME);
                        lCCuenta := lPurchRcptLineOrg."No.";
                        if lResource.GET(lPurchRcptLineOrg."No.") THEN BEGIN
                            If Not lGeneralPostingSetup.GET("Gen. Bus. Posting Group", lResource."Gen. Prod. Posting Group") Then
                                lGeneralPostingSetup.Get(lPurchRcptLineOrg."Gen. Bus. Posting Group", lPurchRcptLineOrg."Gen. Prod. Posting Group");
                            lGeneralPostingSetup.TestField(lGeneralPostingSetup."Purch. Account");
                            lCCuenta := lGeneralPostingSetup."Purch. Account";
                        END else begin
                            if lResource.GET(lPurchRcptLineOrg.Recurso) THEN BEGIN
                                If Not lGeneralPostingSetup.GET("Gen. Bus. Posting Group", lResource."Gen. Prod. Posting Group") then
                                    lGeneralPostingSetup.get(lPurchRcptLineOrg."Gen. Bus. Posting Group", lPurchRcptLineOrg."Gen. Prod. Posting Group");
                                lGeneralPostingSetup.TestField(lGeneralPostingSetup."Purch. Account");
                                lCCuenta := lGeneralPostingSetup."Purch. Account";
                            END;
                        end;
                        lPurchaseLineArtchTMP := lPurchaseLineArch;
                        lPurchaseLineArch."Document No." := "No.";
                        lPurchaseLineArch."Document Type" := lPurchaseLineArch."Document Type"::Order;
                        lPurchaseLineArch."Line No." := gDTotalliDiasReservas[1] + 1;
                        lPurchaseLineArch.Type := lPurchaseLineArch.Type::"G/L Account";
                        lPurchaseLineArch."No." := lCCuenta;
                        lPurchaseLineArch.Description := 'Redondeo factura';
                        lPurchaseLineArch.Quantity := 1;
                        lPurchaseLineArch."Qty. to Invoice" := 1;
                        lPurchaseLineArch."Qty. to Receive" := 1;
                        lPurchaseLineArch."Qty. Rcd. Not Invoiced" := 1;
                        CompruebaErrorRedondeo(lDImporte);
                        lPurchaseLineArch."Direct Unit Cost" := lDImporte;
                        lPurchaseLineArch."Line Discount %" := 0;
                        lPurchaseLineArch."VAT Base Amount" := lDImporte;
                        lPurchaseLineArch.Amount := lDImporte;
                        CompruebaErrorRedondeo(lDImporteIvaIncluido);
                        lPurchaseLineArch."Amount Including VAT" := lDImporteIvaIncluido;
                        lPurchaseLineArch."Quantity (Base)" := 1;
                        lPurchaseLineArch."Line Amount" := lDImporte;
                        lPurchaseLineArch."Inv. Discount Amount" := 0;
                        lPurchaseLineArch."Gen. Bus. Posting Group" := lPurchRcptLineOrg."Gen. Bus. Posting Group";
                        if lPurchRcptLineOrg."Gen. Prod. Posting Group" <> '' Then
                            lPurchaseLineArch."Gen. Prod. Posting Group" := lPurchRcptLineOrg."Gen. Prod. Posting Group";
                        lPurchaseLineArch."VAT Bus. Posting Group" := lPurchRcptLineOrg."VAT Bus. Posting Group";
                        lPurchaseLineArch."VAT Prod. Posting Group" := lPurchRcptLineOrg."VAT Prod. Posting Group";
                        if lPurchaseLineArtchTMP."Shortcut Dimension 1 Code" <> '' Then
                            lPurchaseLineArch.VALIDATE("Shortcut Dimension 1 Code", lPurchaseLineArtchTMP."Shortcut Dimension 1 Code");
                        if lPurchaseLineArtchTMP."Shortcut Dimension 2 Code" <> '' Then
                            lPurchaseLineArch.VALIDATE("Shortcut Dimension 2 Code", lPurchaseLineArtchTMP."Shortcut Dimension 2 Code");
                        if lPurchaseLineArtchTMP."Shortcut Dimension 3 Code" <> '' Then
                            lPurchaseLineArch.VALIDATE("Shortcut Dimension 3 Code", lPurchaseLineArtchTMP."Shortcut Dimension 3 Code");
                        if lPurchaseLineArtchTMP."Shortcut Dimension 4 Code" <> '' Then
                            lPurchaseLineArch.VALIDATE("Shortcut Dimension 4 Code", lPurchaseLineArtchTMP."Shortcut Dimension 4 Code");
                        if lPurchaseLineArtchTMP."Shortcut Dimension 5 Code" <> '' Then
                            lPurchaseLineArch.VALIDATE("Shortcut Dimension 5 Code", lPurchaseLineArtchTMP."Shortcut Dimension 5 Code");
                        lPurchaseLineArch."Dimension Set ID" := lcContoldeProcesos.GetDefaultDimID2(lPurchaseLineArch."Shortcut Dimension 1 Code", lPurchaseLineArch."Shortcut Dimension 2 Code",
                                       lPurchaseLineArch."Shortcut Dimension 3 Code", lPurchaseLineArch."Shortcut Dimension 4 Code", lPurchaseLineArch."Shortcut Dimension 5 Code");
                        lPurchaseLineArch.INSERT;
                    END;
                END;
            END;

            COMMIT;
            lPurchaseLineArch.RESET;
            lPurchaseLineArch.SETRANGE("Document Type", lPurchaseLineArch."Document Type"::Order);
            lPurchaseLineArch.SETRANGE(lPurchaseLineArch."Document No.", "No.");
            if lPurchaseLineArch.FINDFIRST THEN
                REPEAT
                    pPurchRcptLineTMP.TransferFields(lPurchaseLineArch);
                    gCArrayDim[1] := lPurchaseLineArch."Shortcut Dimension 1 Code";
                    gCArrayDim[2] := lPurchaseLineArch."Shortcut Dimension 2 Code";
                    gCArrayDim[3] := lPurchaseLineArch."Shortcut Dimension 3 Code";
                    gCArrayDim[4] := lPurchaseLineArch."Shortcut Dimension 4 Code";
                    gCArrayDim[5] := lPurchaseLineArch."Shortcut Dimension 5 Code";
                    if lPurchaseLineArch.Type = lPurchaseLineArch.Type::Resource THEN lPurchaseLineArch."Dimension Set ID" := CompruebaDimensionEnBlanco(gCArrayDim, lPurchaseLineArch."No.");
                    pPurchRcptLineTMP."Recurso Agrupado" := lPurchaseLineArch."Recurso Agrupado";
                    if pPurchRcptLineTMP.INSERT THEN;
                UNTIL lPurchaseLineArch.NEXT = 0;
        END;
    END;

    PROCEDURE Redondear(pDImporte: Decimal; Unit: Boolean; pCCurrencyCode: Code[20]): Decimal;
    BEGIN
        if pCCurrencyCode = '' THEN
            gCurrency.InitRoundingPrecision
        ELSE
            gCurrency.GET(pCCurrencyCode);
        if Unit THEN
            EXIT(ROUND(
              pDImporte,
             gCurrency."Unit-Amount Rounding Precision"))
        ELSE
            EXIT(ROUND(
                 pDImporte,
               gCurrency."Amount Rounding Precision"));
    END;

    PROCEDURE DimFactura(pCNum: Code[20]);
    VAR
        lPurchRecptLine: Record "Sales Invoice Line";
        lDimDef: Record "Default Dimension";
        lGlEntry: Record "G/L Entry";
        lDimDef2: Record "Default Dimension";
        lcContolProcesos: Codeunit ControlProcesos;
    BEGIN
        lPurchRecptLine.SETRANGE(lPurchRecptLine."Document No.", pCNum);
        lPurchRecptLine.SETRANGE(lPurchRecptLine.Type, lPurchRecptLine.Type::Resource);
        if NOT lPurchRecptLine.FINDFIRST THEN EXIT;
        if lPurchRecptLine.FINDFIRST THEN
            REPEAT
                lDimDef.SETRANGE(lDimDef."Table ID", 156);
                lDimDef.SETRANGE(lDimDef."No.", lPurchRecptLine."No.");
                lDimDef.SETRANGE(lDimDef."Dimension Code", 'PRINCIPAL');
                if lDimDef.FINDFIRST THEN BEGIN
                    lPurchRecptLine."Shortcut Dimension 3 Code" := lDimDef."Dimension Value Code";
                    lDimDef.SETRANGE(lDimDef."Dimension Code", 'SOPORTE');
                    if NOT lDimDef.FINDFIRST THEN BEGIN

                    END ELSE BEGIN
                        lPurchRecptLine."Shortcut Dimension 5 Code" := lDimDef."Dimension Value Code";
                    END;
                    lDimDef.SETRANGE(lDimDef."Dimension Code", 'ZONA');
                    lDimDef.FINDFIRST;
                    lPurchRecptLine."Shortcut Dimension 4 Code" := lDimDef."Dimension Value Code";
                END;
                lPurchRecptLine."Dimension Set ID" := lcContolProcesos.GetDefaultDimID2(lPurchRecptLine."Shortcut Dimension 1 Code", lPurchRecptLine."Shortcut Dimension 2 Code",
                lPurchRecptLine."Shortcut Dimension 3 Code", lPurchRecptLine."Shortcut Dimension 4 Code", lPurchRecptLine."Shortcut Dimension 5 Code");
                lPurchRecptLine.Modify();
            UNTIL lPurchRecptLine.NEXT = 0;
        lGlEntry.SETCURRENTKEY(lGlEntry."Document No.");
        lGlEntry.SETRANGE(lGlEntry."Document Type", lGlEntry."Document Type"::"Credit Memo");
        lGlEntry.SETRANGE(lGlEntry."Document No.", pCNum);
        lGlEntry.SETFILTER(lGlEntry."G/L Account No.", '%1', '70*');
        if lGlEntry.FINDFIRST THEN
            REPEAT
                lPurchRecptLine.SETRANGE(lPurchRecptLine."Document No.", pCNum);
                lPurchRecptLine.FINDFIRST;
                lGlEntry."Global Dimension 1 Code" := lPurchRecptLine."Shortcut Dimension 1 Code";
                lGlEntry."Global Dimension 2 Code" := lPurchRecptLine."Shortcut Dimension 2 Code";
                lGlEntry."Global Dimension 3 Code" := lPurchRecptLine."Shortcut Dimension 3 Code";
                lGlEntry."Global Dimension 4 Code" := lPurchRecptLine."Shortcut Dimension 4 Code";
                lGlEntry."Global Dimension 5 Code" := lPurchRecptLine."Shortcut Dimension 5 Code";
                lGlEntry."Dimension Set ID" := lPurchRecptLine."Dimension Set ID";
                lGlEntry.Modify();
            UNTIL lGlEntry.NEXT = 0;
    END;

    PROCEDURE DimAbono(pCNum: Code[20]);
    VAR
        lPurchRecptLine: Record "Sales Cr.Memo Line";
        rLed: Record 355;
        // // rPost: Record 359;
        lDimDef: Record "Default Dimension";
        lGlEntry: Record "G/L Entry";
        lDimDef2: Record "Default Dimension";
        lcContoldeProcesos: Codeunit ControlProcesos;
    BEGIN
        lPurchRecptLine.SETRANGE(lPurchRecptLine."Document No.", pCNum);
        lPurchRecptLine.SETRANGE(lPurchRecptLine.Type, lPurchRecptLine.Type::Resource);
        if NOT lPurchRecptLine.FINDFIRST THEN EXIT;
        if lPurchRecptLine.FINDFIRST THEN
            REPEAT
                lDimDef.SETRANGE(lDimDef."Table ID", 156);
                lDimDef.SETRANGE(lDimDef."No.", lPurchRecptLine."No.");
                lDimDef.SETRANGE(lDimDef."Dimension Code", 'PRINCIPAL');
                if lDimDef.FINDFIRST THEN BEGIN
                    lPurchRecptLine."Shortcut Dimension 3 Code" := lDimDef."Dimension Value Code";
                    lDimDef.SETRANGE(lDimDef."Dimension Code", 'SOPORTE');
                    if NOT lDimDef.FINDFIRST THEN BEGIN

                    END ELSE BEGIN
                        lPurchRecptLine."Shortcut Dimension 5 Code" := lDimDef."Dimension Value Code";
                    END;
                    lDimDef.SETRANGE(lDimDef."Dimension Code", 'ZONA');
                    lDimDef.FINDFIRST;
                    lPurchRecptLine."Shortcut Dimension 4 Code" := lDimDef."Dimension Value Code";
                END;
                lPurchRecptLine."Dimension Set ID" := lcContoldeProcesos.GetDefaultDimID2(lPurchRecptLine."Shortcut Dimension 1 Code", lPurchRecptLine."Shortcut Dimension 2 Code",
                lPurchRecptLine."Shortcut Dimension 3 Code", lPurchRecptLine."Shortcut Dimension 4 Code", lPurchRecptLine."Shortcut Dimension 5 Code");
                lPurchRecptLine.Modify();
            UNTIL lPurchRecptLine.NEXT = 0;
        lGlEntry.SETCURRENTKEY(lGlEntry."Document No.");
        lGlEntry.SETRANGE(lGlEntry."Document Type", lGlEntry."Document Type"::"Credit Memo");
        lGlEntry.SETRANGE(lGlEntry."Document No.", pCNum);
        lGlEntry.SETFILTER(lGlEntry."G/L Account No.", '%1', '70*');
        if lGlEntry.FINDFIRST THEN
            REPEAT
                lPurchRecptLine.SETRANGE(lPurchRecptLine."Document No.", pCNum);
                lPurchRecptLine.FINDFIRST;
                lGlEntry."Global Dimension 1 Code" := lPurchRecptLine."Shortcut Dimension 1 Code";
                lGlEntry."Global Dimension 2 Code" := lPurchRecptLine."Shortcut Dimension 2 Code";
                lGlEntry."Global Dimension 3 Code" := lPurchRecptLine."Shortcut Dimension 3 Code";
                lGlEntry."Global Dimension 4 Code" := lPurchRecptLine."Shortcut Dimension 4 Code";
                lGlEntry."Global Dimension 5 Code" := lPurchRecptLine."Shortcut Dimension 5 Code";
                lGlEntry."Dimension Set ID" := lPurchRecptLine."Dimension Set ID";
                lGlEntry.MODIFY();
            UNTIL lGlEntry.NEXT = 0;
    END;

    Procedure FillAlbPostingBufferCorreccion(pPurchRcptLineTMP: Record "Purch. Rcpt. Line"; piLinea: Integer; var TempBuffer: Record "Invoice Posting Buffer" temporary)
    var
        lDAmount: Decimal;
        lDAmountLCY: Decimal;
        lLocation: Record "Location";
        lPurchHeader: Record "Purchase Header";
        lVatPostingGroup: Record "VAT Business Posting Group";
        lcContoldeProcesos: Codeunit ControlProcesos;
        FalineNo: Integer;
    Begin
        WITH pPurchRcptLineTMP DO BEGIN
            if Not lPurchHeader.Get(lPurchHeader."Document Type"::Order, "Order No.") Then lPurchHeader.Init();
            if ("Gen. Bus. Posting Group" <> gGenPostingSetup."Gen. Bus. Posting Group") OR
                ("Gen. Prod. Posting Group" <> gGenPostingSetup."Gen. Prod. Posting Group")
            THEN
                if NOT gGenPostingSetup.GET("Gen. Bus. Posting Group", "Gen. Prod. Posting Group") THEN
                    gGenPostingSetup.INIT;
            if gGenPostingSetup."Gen. Bus. Posting Group" = '' THEN
                gGenPostingSetup.GET("Gen. Bus. Posting Group", "Gen. Prod. Posting Group");

            CLEAR(TempBuffer);
            TempBuffer.Type := Type;
            if (Type = Type::"G/L Account") OR (Type = Type::"Fixed Asset") THEN
                TempBuffer."G/L Account" := "No."
            ELSE BEGIN
                if NOT lLocation.GET("Location Code") THEN lLocation.INIT;
                if lLocation."Cta. Compras" <> '' THEN BEGIN
                    TempBuffer."G/L Account" := lLocation."Cta. Compras";
                END ELSE BEGIN
                    gGenPostingSetup.TestField("Purch. Account");
                    TempBuffer."G/L Account" := gGenPostingSetup."Purch. Account";
                END;
            END;
            TempBuffer."System-Created Entry" := TRUE;
            TempBuffer."Gen. Bus. Posting Group" := "Gen. Bus. Posting Group";
            TempBuffer."Gen. Prod. Posting Group" := "Gen. Prod. Posting Group";
            TempBuffer."VAT Bus. Posting Group" := "VAT Bus. Posting Group";
            TempBuffer."VAT Prod. Posting Group" := "VAT Prod. Posting Group";
            TempBuffer."VAT Calculation Type" := "VAT Calculation Type";
            TempBuffer."Global Dimension 1 Code" := "Shortcut Dimension 1 Code";
            TempBuffer."Global Dimension 2 Code" := "Shortcut Dimension 2 Code";
            //ASC
            TempBuffer."Global Dimension 3 Code" := "Shortcut Dimension 3 Code";
            TempBuffer."Global Dimension 4 Code" := "Shortcut Dimension 4 Code";
            TempBuffer."Global Dimension 5 Code" := "Shortcut Dimension 5 Code";
            TempBuffer."Dimension Set ID" := lcContoldeProcesos.GetDefaultDimID2("Shortcut Dimension 1 Code", "Shortcut Dimension 2 Code",
                "Shortcut Dimension 3 Code", "Shortcut Dimension 4 Code", "Shortcut Dimension 5 Code");
            TempBuffer."Job No." := "Job No.";
            if COMPANYNAME in [glUnion, glUATI] THEN
                lDAmount := (Quantity * "Direct Unit Cost") * (1 - "Line Discount %" / 100)
            ELSE
                lDAmount := (Quantity * "Unit Cost (LCY)");
            if "Line Discount %" = 0 THEN
                lDAmount := (Quantity * "Direct Unit Cost");
            lDAmountLCY := ROUND(lDAmount, 0.01, '=');
            TempBuffer.Amount := ROUND(lDAmount, 0.01, '=');
            TempBuffer."VAT Base Amount" := ROUND(lDAmount, 0.01, '=');
            TempBuffer."Amount (ACY)" := lDAmountLCY;
            TempBuffer."VAT Base Amount (ACY)" := lDAmountLCY;
            TempBuffer."VAT Difference" := 0;//"VAT Difference";
            TempBuffer."VAT %" := "VAT %";
            //-SII
            gGenLedgerSetup.GET;
            if gGenLedgerSetup."Activar SII" THEN BEGIN
                if gVATPostingSetup.GET(pPurchRcptLineTMP."VAT Bus. Posting Group", pPurchRcptLineTMP."VAT Prod. Posting Group") THEN;
                if lVatPostingGroup.GET(pPurchRcptLineTMP."VAT Bus. Posting Group") THEN;
                //PurchaseHeader.GET(pPurchRcptLineTMP."Document Type",pPurchRcptLineTMP."Document No.");
                TempBuffer."Tipo factura SII" := lPurchHeader."Tipo factura SII";
                TempBuffer."Clave registro SII recibidas" := lVatPostingGroup."Clave registro SII recibidas";
                TempBuffer."Descripción operación" := lPurchHeader."Descripción operación";
                TempBuffer."Tipo desglose emitidas" := gVATPostingSetup."Tipo desglose emitidas";
                TempBuffer."Sujeta exenta" := gVATPostingSetup."Sujeta exenta";
                TempBuffer."Tipo de operación" := gVATPostingSetup."Tipo de operación";
                TempBuffer."Tipo factura rectificativa" := lPurchHeader."Tipo factura rectificativa";
            END;
            //+SII

            if Type = Type::"Fixed Asset" THEN BEGIN
                TempBuffer."FA Posting Date" := "FA Posting Date";
                TempBuffer."FA Posting Type" := "FA Posting Type";
                TempBuffer."Depreciation Book Code" := "Depreciation Book Code";
                TempBuffer."Salvage Value" := "Salvage Value";
                TempBuffer."Depr. until FA Posting Date" := "Depr. until FA Posting Date";
                TempBuffer."Depr. Acquisition Cost" := "Depr. Acquisition Cost";
                TempBuffer."Maintenance Code" := "Maintenance Code";
                TempBuffer."Insurance No." := "Insurance No.";
                TempBuffer."Budgeted FA No." := "Budgeted FA No.";
                TempBuffer."Duplicate in Depreciation Book" := "Duplicate in Depreciation Book";
                TempBuffer."Use Duplication List" := "Use Duplication List";
            END;
            CASE "VAT Calculation Type" OF
                "VAT Calculation Type"::"Normal VAT", "VAT Calculation Type"::"Full VAT":
                    BEGIN
                        TempBuffer."VAT Amount" := Amount * (pPurchRcptLineTMP."VAT %" / 100);
                        TempBuffer."VAT Amount (ACY)" :=
                        lDAmountLCY * (pPurchRcptLineTMP."VAT %" / 100);
                    END;
                "VAT Calculation Type"::"Reverse Charge VAT":
                    ; // Reverse Charge VAT is calculated later, based on totals
                "VAT Calculation Type"::"Sales Tax":
                    BEGIN
                        if NOT "Use Tax" THEN BEGIN  // Use Tax is calculated later, based on totals
                            TempBuffer."VAT Amount" := Amount * (pPurchRcptLineTMP."VAT %" / 100);
                            TempBuffer."VAT Amount (ACY)" :=
                                lDAmountLCY * (pPurchRcptLineTMP."VAT %" / 100);
                        END;
                        TempBuffer."Tax Area Code" := "Tax Area Code";
                        TempBuffer."Tax Liable" := "Tax Liable";
                        TempBuffer."Tax Group Code" := "Tax Group Code";
                        TempBuffer."Use Tax" := "Use Tax";
                        TempBuffer.Quantity := pPurchRcptLineTMP."Qty. Rcd. Not Invoiced";
                    END;
            END;

            if gPurchSetup."Post Invoice Discount" THEN BEGIN
                TempBuffer.Amount := TempBuffer.Amount;// + "Inv. Discount Amount";
                TempBuffer."Inv. Discount Amount" := 0;//"Inv. Discount Amount";
                TempBuffer."Amount (ACY)" :=
                TempBuffer."Amount (ACY)";// + PurchLineACY."Inv. Discount Amount";
                TempBuffer."Inv. Discount Amt. (ACY)" := 0;//PurchLineACY."Inv. Discount Amount";
                                                           // {if ("Inv. Discount Amount" <> 0) OR (PurchLineACY."Inv. Discount Amount" <> 0)THEN BEGIN
                                                           // gGenPostingSetup.TestField("Purch. Inv. Disc. Account");
                                                           // TempBuffer."Inv. Discount Account" := gGenPostingSetup."Purch. Inv. Disc. Account";
                                                           // END;}
            END;
            if gPurchSetup."Post Line Discount" THEN BEGIN
                TempBuffer.Amount := TempBuffer.Amount + TempBuffer.Amount * (pPurchRcptLineTMP."Line Discount %" / 100);
                TempBuffer."Line Discount Amount" := TempBuffer.Amount * (pPurchRcptLineTMP."Line Discount %" / 100);
                TempBuffer."Amount (ACY)" :=
                TempBuffer."Amount (ACY)" + TempBuffer."Amount (ACY)" * (pPurchRcptLineTMP."Line Discount %" / 100);
                TempBuffer."Line Discount Amt. (ACY)" := TempBuffer."Amount (ACY)" * (pPurchRcptLineTMP."Line Discount %" / 100);
                if (TempBuffer.Amount * (pPurchRcptLineTMP."Line Discount %" / 100) <> 0) OR
                (TempBuffer."Amount (ACY)" * (pPurchRcptLineTMP."Line Discount %" / 100) <> 0) THEN BEGIN
                    gGenPostingSetup.TestField("Purch. Line Disc. Account");
                    TempBuffer."Line Discount Account" := gGenPostingSetup."Purch. Line Disc. Account";
                END;
            END;
            if gPurchSetup."Post Payment Discount" THEN BEGIN
                TempBuffer.Amount := TempBuffer.Amount;// + "Pmt. Discount Amount";
                TempBuffer."Pmt. Discount Amount" := 0;//"Pmt. Discount Amount";
                TempBuffer."Amount (ACY)" :=
                TempBuffer."Amount (ACY)";// + PurchLineACY."Pmt. Discount Amount";
                TempBuffer."Src. Curr. Pmt. Discount Amt." := 0;//PurchLineACY."Pmt. Discount Amount";
                                                                // {if (lPurchaseLine."Pmt. Discount Amount" <> 0) OR (PurchLineACY."Pmt. Discount Amount" <> 0) THEN BEGIN
                                                                // gGenPostingSetup.TestField("Purch. Pmt. Disc. Credit Acc.");
                                                                // TempBuffer."Pmt. Discount Account" := gGenPostingSetup."Purch. Pmt. Disc. Credit Acc.";
                                                                // END;}
            END;

            //  TempBuffer."FA Discount Account" := FASetDiscountAccount(PurchLine);
            // TempDocDim.SETRANGE("Table ID", DATABASE::"Purchase Line Archive");
            // TempDocDim.SETRANGE("Line No.", Linea);

        END;
    End;

    Procedure DesglosarAlbaranesContabDesglo(var pPurchaseRcptHdr: Record "Purch. Rcpt. Header"; var pPurchRcptLineTMP: Record "Purch. Rcpt. Line" temporary)
    var
        lPurchRcptLineTMP: Record "Purch. Rcpt. Line" temporary;
        lReserva: Record "Reserva";
        lPurchRcptLineTMP1: Record "Purch. Rcpt. Line" temporary;
        //a: Integer;
        lPurchLineArchive: Record "Purchase Line Archive";
        lPurchRcptHeader: Record "Purch. Rcpt. Header";
        lPurchHeaderArchive: Record "Purchase Header Archive";
        iNumeroReservas: Integer;
        lResource: Record "Resource";
        lPurchRcptLineTMP2: Record "Purch. Rcpt. Line" temporary;
        liDiasReserva: Integer;
        ldFI: Date;
        ldFF: Date;
        lDImporte: Decimal;
        lDImporteIvaIncluido: Decimal;
        lGeneralPostingSetup: Record "General Posting Setup";
        lPurchRcptLineOrg: Record "Purch. Rcpt. Line";
        lJob: Record "Job";
        lCJob: Code[20];
        ltCmp: Text;
        lDimValue: Record "Dimension Value";
        lDimValue2: Record "Dimension Value";
        lGenProdPostGrp: Record "Gen. Product Posting Group";
        lPurchaseHeader: Record "Purchase Header";
        liLinea: Integer;
        lCJob2: Code[20];
        lPurchLineArchiveTMP: Record "Purchase Line Archive" temporary;
        g: Integer;
        lDImporteOri: Decimal;
        lDImporteNuevo: Decimal;
        lPurchRcptLine: Record "Purch. Rcpt. Line";
        lCCuenta: Text;
        lbAgrupado: boolean;
        lCAutoDocNo: Code[20];
        ltCompany: Text[30];
        rRel: Record "Relación Grupos";
    Begin

        WITH pPurchaseRcptHdr DO BEGIN
            if Not lPurchaseHeader.GET(lPurchaseHeader."Document Type"::Order, pPurchaseRcptHdr."Order No.") THEN lPurchaseHeader.Init();
            lPurchRcptLine.SETRANGE(lPurchRcptLine."Document No.", pPurchaseRcptHdr."No.");
            if lPurchRcptLine.FINDFIRST THEN
                REPEAT
                    if COMPANYNAME in [glUnion, glUATI] THEN
                        lDImporteOri += (lPurchRcptLine.Quantity * lPurchRcptLine."Direct Unit Cost") * (1 - lPurchRcptLine."Line Discount %" / 100)
                    ELSE
                        lDImporteOri += (lPurchRcptLine.Quantity * lPurchRcptLine."Unit Cost (LCY)");
                UNTIL lPurchRcptLine.NEXT = 0;
            lPurchLineArchive.SETRANGE(lPurchLineArchive."Document Type", lPurchLineArchive."Document Type"::Order);
            lPurchLineArchive.SETRANGE(lPurchLineArchive."Document No.", "No.");
            lPurchLineArchive.DELETEALL;
            if lPurchHeaderArchive.GET(lPurchHeaderArchive."Document Type"::Order, "No.") THEN lPurchHeaderArchive.DELETE;
            lPurchRcptLineOrg.SETRANGE(lPurchRcptLineOrg."Document No.", "No.");
            if lPurchRcptLineOrg.FINDFIRST THEN
                REPEAT
                    lPurchRcptLineOrg."Line Amount" := lPurchRcptLineOrg.Quantity * lPurchRcptLineOrg."Direct Unit Cost" * (1 - lPurchRcptLineOrg."Line Discount %" / 100);
                    lPurchRcptLineOrg.Amount := lPurchRcptLineOrg."Line Amount";
                    lPurchRcptLineOrg."Amount Including VAT" := lPurchRcptLineOrg."Line Amount" * (1 + lPurchRcptLineOrg."VAT %" / 100);
                    lPurchRcptLineOrg."Line Discount Amount" := lPurchRcptLineOrg.Quantity * lPurchRcptLineOrg."Direct Unit Cost" * (lPurchRcptLineOrg."Line Discount %" / 100);
                    if lPurchRcptLineOrg."Job No." = '' THEN lPurchRcptLineOrg."Job No." := pPurchaseRcptHdr."Nº Proyecto";
                    if lPurchRcptLineOrg."No." = '' THEN lPurchRcptLineOrg.Type := lPurchRcptLineOrg.Type::" ";
                    lPurchRcptLineOrg.MODIFY;
                    lPurchRcptLineTMP := lPurchRcptLineOrg;
                    if (lPurchRcptLineOrg.Type = lPurchRcptLineOrg.Type::Resource) OR (lPurchRcptLineOrg.Recurso <> '') THEN BEGIN
                        if (lPurchRcptLineOrg."No." = '') and (lPurchRcptLineOrg.Recurso <> '') THEN BEGIN
                            lPurchRcptLineTMP.Type := lPurchRcptLineTMP.Type::Resource;
                            lPurchRcptLineTMP."No." := lPurchRcptLineOrg.Recurso;
                            lPurchRcptLineTMP.Recurso := lPurchRcptLineOrg."No.";
                            lPurchRcptLineOrg.Type := lPurchRcptLineTMP.Type::Resource;
                            lPurchRcptLineOrg."No." := lPurchRcptLineOrg.Recurso;
                            lPurchRcptLineOrg.Recurso := lPurchRcptLineTMP.Recurso;
                        END else begin
                            lPurchRcptLineTMP.Recurso := lPurchRcptLineOrg."No.";
                            lPurchRcptLineOrg.Recurso := lPurchRcptLineTMP.Recurso;
                        end;
                        if lResource.GET(lPurchRcptLineOrg."No.") THEN BEGIN
                            lPurchRcptLineTMP."Shortcut Dimension 1 Code" := lResource."Global Dimension 1 Code";
                            lPurchRcptLineTMP."Shortcut Dimension 2 Code" := lResource."Global Dimension 2 Code";
                            lPurchRcptLineTMP."Shortcut Dimension 3 Code" := lResource."Global Dimension 3 Code";
                            lPurchRcptLineTMP."Shortcut Dimension 4 Code" := lResource."Global Dimension 4 Code";
                            lPurchRcptLineTMP."Shortcut Dimension 5 Code" := lResource."Global Dimension 5 Code";
                            if (lResource."Empresa Origen" <> COMPANYNAME) AND (lResource."Empresa Origen" <> '') THEN BEGIN
                                lPurchRcptLineTMP."No." := lResource."Nº En Empresa origen";
                                lPurchRcptLineTMP."Empresa Origen" := lResource."Empresa Origen";
                                recuperaproyecto(lJob, lPurchRcptLineOrg."Job No.", lResource);
                                lPurchRcptLineTMP."Proyecto Origen" := lJob."No.";

                                lResource.CHANGECOMPANY(lResource."Empresa Origen");
                                ltCompany := lResource."Empresa Origen";
                                lResource.GET(lPurchRcptLineTMP."No.");
                                lPurchRcptLineTMP."Shortcut Dimension 1 Code" := lResource."Global Dimension 1 Code";
                                lPurchRcptLineTMP."Shortcut Dimension 2 Code" := lResource."Global Dimension 2 Code";
                                lPurchRcptLineTMP."Shortcut Dimension 3 Code" := lResource."Global Dimension 3 Code";
                                lPurchRcptLineTMP."Shortcut Dimension 4 Code" := lResource."Global Dimension 4 Code";
                                lPurchRcptLineTMP."Shortcut Dimension 5 Code" := lResource."Global Dimension 5 Code";
                            END else
                                ProyectoEmpresa(lJob, lPurchRcptLineTMP."Job No.", pPurchaseRcptHdr."Nº Proyecto");
                        END;
                    END;
                    lPurchRcptLineTMP.Recurso := lPurchRcptLineTMP."No.";
                    if lPurchaseHeader.GET(lPurchaseHeader."Document Type"::Order, pPurchaseRcptHdr."Order No.") THEN BEGIN
                        if lPurchRcptLineTMP."Fecha inicial recurso" = 0D THEN lPurchRcptLineTMP."Fecha inicial recurso" := lPurchaseHeader."Fecha inicial proyecto";
                        if lPurchRcptLineTMP."Fecha Final recurso" = 0D THEN lPurchRcptLineTMP."Fecha Final recurso" := lPurchaseHeader."Fecha Fin proyecto";
                        if lPurchRcptLineTMP."Fecha inicial recurso" = 0D THEN lPurchRcptLineTMP."Fecha inicial recurso" := lJob."Starting Date";
                        if lPurchRcptLineTMP."Fecha Final recurso" = 0D THEN lPurchRcptLineTMP."Fecha Final recurso" := lJob."Ending Date";
                    END;
                    lPurchRcptLineTMP.INSERT;
                    lResource.CHANGECOMPANY(COMPANYNAME);
                    gRecursoAgrupado := lResource."Recurso Agrupado";
                    ltCompany := CompanyName;
                UNTIL lPurchRcptLineOrg.NEXT = 0;

            //Recorro la tabla de lineas de factura para buscar si tiene recursos agrupadod
            lPurchRcptLineTMP.SETRANGE(lPurchRcptLineTMP."Document No.", "No.");
            liLinea := 10000;
            if lPurchRcptLineTMP.FINDFIRST THEN
                REPEAT
                    gRecursoAgrupado := false;
                    if lPurchRcptLineTMP."Empresa Origen" <> '' THEN BEGIN
                        lReserva.CHANGECOMPANY(lPurchRcptLineTMP."Empresa Origen");
                        lCJob := lPurchRcptLineTMP."Proyecto Origen";
                        lJob.ChangeCompany(lPurchRcptLineTMP."Empresa Origen");
                        lResource.CHANGECOMPANY(lPurchRcptLineTMP."Empresa Origen");
                        If Not lResource.Get(lPurchRcptLineTMP."No.") Then lResource.Init;
                        gRecursoAgrupado := lResource."Recurso Agrupado";
                    END ELSE BEGIN
                        lReserva.CHANGECOMPANY(COMPANYNAME);
                        lCJob := "Nº Proyecto";
                        lJob.ChangeCompany(Companyname);
                        lResource.ChangeCompany(Companyname);
                        If Not lResource.Get(lPurchRcptLineTMP."No.") Then lResource.Init;
                        gRecursoAgrupado := lResource."Recurso Agrupado";
                    END;
                    lReserva.RESET;

                    lReserva.SETCURRENTKEY(lReserva."Nº Proyecto", lReserva."Recurso Agrupado");
                    If gRecursoAgrupado then begin
                        lReserva.SETRANGE(lReserva."Recurso Agrupado", lPurchRcptLineTMP."No.");
                        lReserva.SETRANGE(lReserva."Linea Agrupado", lPurchRcptLineTMP."Line No.");
                    end;
                    IF NOT lReserva.FINDFIRST THEN lReserva.SETRANGE(lReserva."Linea Agrupado");
                    if lCJob = '' THEN
                        lReserva.SETRANGE(lReserva."Nº Proyecto", 'KKDLVK')
                    ELSE
                        lReserva.SETRANGE(lReserva."Nº Proyecto", lCJob);
                    lReserva.SETFILTER(lReserva."Fecha inicio", '<=%1', lPurchRcptLineTMP."Fecha Final recurso");
                    lReserva.SETFILTER(lReserva."Fecha Fin", '>=%1', lPurchRcptLineTMP."Fecha inicial recurso");
                    gDTotalliDiasReservas[1] := 0;
                    If not lJob.Get(lCJob) then lJob.Init;
                    If NOT lReserva.FINDFIRST Then lJob."Fechas Flexibles" := true;
                    if lJob."Fechas Flexibles" THEN begin
                        lReserva.SetRange("Fecha inicio");
                        lReserva.SetRange("Fecha Fin");
                        lReserva.SETRANGE(lReserva."Linea Agrupado");
                    end;
                    //recupero las fechas
                    if lReserva.FINDFIRST THEN
                        REPEAT
                            iNumeroReservas := iNumeroReservas + 1;
                            ldFI := lReserva."Fecha inicio";
                            ldFF := lReserva."Fecha Fin";
                            lbAgrupado := TRUE;
                            if ldFI <= lPurchRcptLineTMP."Fecha inicial recurso" THEN
                                ldFI := lPurchRcptLineTMP."Fecha inicial recurso";
                            ldFF := lReserva."Fecha Fin";
                            if ldFF >= lPurchRcptLineTMP."Fecha Final recurso" THEN
                                ldFF := lPurchRcptLineTMP."Fecha Final recurso";
                            liDiasReserva := ldFF - ldFI;
                            if liDiasReserva = 0 THEN liDiasReserva := 1;
                            gDTotalliDiasReservas[1] := gDTotalliDiasReservas[1] + liDiasReserva;
                        UNTIL lReserva.NEXT = 0;
                    //if lJob."Fechas Flexibles" THEN gDTotalliDiasReservas[1] := lReserva.Count;
                    iNumeroReservas := 0;

                    if (lReserva.FINDFIRST) And (gRecursoAgrupado) THEN BEGIN
                        if gDTotalliDiasReservas[1] = 0 THEN
                            Error(glSinReserva, lCJob,
                          lPurchRcptLineTMP1."Fecha inicial recurso", lPurchRcptLineTMP1."Fecha Final recurso", lPurchRcptLineTMP."No.");
                        REPEAT
                            iNumeroReservas := iNumeroReservas + 1;
                            ldFI := lReserva."Fecha inicio";
                            ldFF := lReserva."Fecha Fin";
                            if ldFI <= lPurchRcptLineTMP."Fecha inicial recurso" THEN
                                ldFI := lPurchRcptLineTMP."Fecha inicial recurso";
                            ldFF := lReserva."Fecha Fin";
                            if ldFF >= lPurchRcptLineTMP."Fecha Final recurso" THEN
                                ldFF := lPurchRcptLineTMP."Fecha Final recurso";
                            //calculo el número de dias
                            liDiasReserva := ldFF - ldFI;
                            // if lJob."Fechas Flexibles" THEN begin
                            //     ldFI := lPurchRcptLineTMP."Fecha inicial recurso";
                            //     ldFF := lPurchRcptLineTMP."Fecha Final recurso";
                            //     liDiasReserva := ldFF - ldFI;
                            // end;
                            if liDiasReserva = 0 THEN liDiasReserva := 1;
                            lPurchRcptLineTMP1 := lPurchRcptLineTMP;
                            lPurchRcptLineTMP1."Recurso Agrupado" := lbAgrupado;
                            lPurchRcptLineTMP1."Line No." := liLinea;//lPurchRcptLineTMP1."Line No."+b;
                            lPurchRcptLineTMP1."No." := lReserva."Nº Recurso";
                            lPurchRcptLineTMP1.Quantity := lPurchRcptLineTMP.Quantity;
                            lPurchRcptLineTMP1."Direct Unit Cost" := RedondearP(lPurchRcptLineTMP."Direct Unit Cost" / gDTotalliDiasReservas[1] * liDiasReserva, TRUE, lPurchaseHeader);
                            lPurchRcptLineTMP1."Unit Cost" := RedondearP(lPurchRcptLineTMP."Unit Cost" / gDTotalliDiasReservas[1] * liDiasReserva, TRUE, lPurchaseHeader);
                            lPurchRcptLineTMP1."Unit Cost (LCY)" := RedondearP(lPurchRcptLineTMP."Unit Cost (LCY)" / gDTotalliDiasReservas[1] * liDiasReserva, TRUE, lPurchaseHeader);
                            lPurchRcptLineTMP1."Line Discount Amount" := RedondearP(lPurchRcptLineTMP."Line Discount Amount" / gDTotalliDiasReservas[1] * liDiasReserva, FALSE, lPurchaseHeader);

                            lPurchRcptLineTMP1.Amount := RedondearP(lPurchRcptLineTMP.Amount / gDTotalliDiasReservas[1] * liDiasReserva, FALSE, lPurchaseHeader);
                            lPurchRcptLineTMP1."Amount Including VAT" := lPurchRcptLineTMP1.Amount * (1 + lPurchRcptLineTMP1."VAT %" / 100);
                            lPurchRcptLineTMP1."Line Amount" := RedondearP(lPurchRcptLineTMP."Line Amount" / gDTotalliDiasReservas[1] * liDiasReserva, FALSE, lPurchaseHeader);
                            if lPurchRcptLineTMP."Empresa Origen" <> '' THEN BEGIN
                                lResource.CHANGECOMPANY(lPurchRcptLineTMP."Empresa Origen");
                                ltCompany := lPurchRcptLineTMP."Empresa Origen";
                            END ELSE BEGIN
                                lResource.CHANGECOMPANY(COMPANYNAME);
                                ltCompany := CompanyName;
                            END;
                            if NOT lResource.GET(lReserva."Nº Recurso") THEN BEGIN
                                lResource.RESET;
                                lResource.CHANGECOMPANY(COMPANYNAME);
                                ltCompany := CompanyName;
                                if lResource.GET(lReserva."Nº Recurso") THEN lResource.INIT();
                            END;
                            lPurchRcptLineTMP1."Shortcut Dimension 1 Code" := lResource."Global Dimension 1 Code";
                            lPurchRcptLineTMP1."Shortcut Dimension 2 Code" := lResource."Global Dimension 2 Code";
                            lPurchRcptLineTMP1."Shortcut Dimension 3 Code" := lResource."Global Dimension 3 Code";
                            lPurchRcptLineTMP1."Shortcut Dimension 4 Code" := lResource."Global Dimension 4 Code";
                            lPurchRcptLineTMP1."Shortcut Dimension 5 Code" := lResource."Global Dimension 5 Code";
                            If ltCompany <> CompanyName THEN BEGIN
                                rRel.SETRANGE(rRel."Empresa Origen", ltCompany);
                                rRel.SETRANGE(rRel."Grupo Contable Origen", lResource."Gen. Prod. Posting Group");
                                rRel.SETRANGE(rRel."Empresa Destino", COMPANYNAME);
                                if rRel.FINDFIRST THEN
                                    lResource."Gen. Prod. Posting Group" := rRel."Grupo Contable Destino"
                            END;
                            if lResource."Gen. Prod. Posting Group" <> '' Then
                                lPurchRcptLineTMP1."Gen. Prod. Posting Group" := lResource."Gen. Prod. Posting Group";
                            lPurchRcptLineTMP1.INSERT;
                            liLinea := liLinea + 10000;
                        UNTIL lReserva.NEXT = 0;
                    END ELSE BEGIN
                        //si no es recurso agrupado inserto igualmente la línea
                        lPurchRcptLineTMP1 := lPurchRcptLineTMP;
                        lPurchRcptLineTMP1."Line No." := liLinea;
                        lPurchRcptLineTMP1.INSERT;
                        liLinea := liLinea + 10000;
                    END;
                UNTIL lPurchRcptLineTMP.NEXT = 0;
            // Ahora busco si es de producción
            Produccion(lPurchRcptLineTMP1, lPurchRcptLineTMP2, lResource, "Nº Proyecto", lbAgrupado, lPurchaseHeader."Currency Code");
            if lPurchRcptHeader.GET("No.") THEN BEGIN
                lPurchHeaderArchive.TransferFields(lPurchRcptHeader);
                lPurchHeaderArchive."Document Type" := lPurchHeaderArchive."Document Type"::Order;
                lPurchHeaderArchive.INSERT;
            END;
            if lPurchRcptLineTMP2.FINDFIRST THEN
                REPEAT
                    lPurchLineArchive.TransferFields(lPurchRcptLineTMP2);
                    lPurchLineArchive."Recurso Agrupado" := lPurchRcptLineTMP2."Recurso Agrupado";
                    lPurchLineArchive."Document Type" := lPurchLineArchive."Document Type"::Order;
                    lPurchLineArchive."Line Amount" := lPurchRcptLineTMP2."Line Amount";
                    lPurchLineArchive."Line Discount Amount" := lPurchRcptLineTMP2."Line Discount Amount";
                    lPurchLineArchive.Amount := lPurchRcptLineTMP2.Amount;
                    //lPurchLineArchive."Inv. Discount Amount":=lPurchRcptLineTMP12."Inv. Discount Amount";
                    lPurchLineArchive."Amount Including VAT" := lPurchRcptLineTMP2."Amount Including VAT";

                    gCArrayDim[1] := lPurchLineArchive."Shortcut Dimension 1 Code";
                    gCArrayDim[2] := lPurchLineArchive."Shortcut Dimension 2 Code";
                    gCArrayDim[3] := lPurchLineArchive."Shortcut Dimension 3 Code";
                    gCArrayDim[4] := lPurchLineArchive."Shortcut Dimension 4 Code";
                    gCArrayDim[5] := lPurchLineArchive."Shortcut Dimension 5 Code";
                    if lPurchLineArchive.Type = lPurchLineArchive.Type::Resource THEN lPurchLineArchive."Dimension Set ID" := CompruebaDimensionEnBlanco(gCArrayDim, lPurchLineArchive."No.");
                    lPurchLineArchive.INSERT;
                    gGenLedgerSetup.GET;
                    if NOT lDimValue.GET(gGenLedgerSetup."Shortcut Dimension 1 Code", lPurchLineArchive."Shortcut Dimension 1 Code") THEN BEGIN
                        lDimValue.INIT;
                        lDimValue."Dimension Code" := gGenLedgerSetup."Shortcut Dimension 1 Code";
                        lDimValue.Code := lPurchLineArchive."Shortcut Dimension 1 Code";
                        lDimValue."Global Dimension No." := 1;
                        if lDimValue.Code <> '' THEN
                            lDimValue.INSERT;
                    END;
                    if NOT lDimValue.GET(gGenLedgerSetup."Shortcut Dimension 2 Code", lPurchLineArchive."Shortcut Dimension 2 Code") THEN BEGIN
                        lDimValue.INIT;
                        lDimValue."Dimension Code" := gGenLedgerSetup."Shortcut Dimension 2 Code";
                        lDimValue.Code := lPurchLineArchive."Shortcut Dimension 2 Code";
                        lDimValue."Global Dimension No." := 2;
                        if lDimValue.Code <> '' THEN
                            lDimValue.INSERT;
                    END;
                    if NOT lDimValue.GET(gGenLedgerSetup."Shortcut Dimension 3 Code", lPurchLineArchive."Shortcut Dimension 3 Code") THEN BEGIN
                        lDimValue.INIT;
                        lDimValue."Dimension Code" := gGenLedgerSetup."Shortcut Dimension 3 Code";
                        lDimValue.Code := lPurchLineArchive."Shortcut Dimension 3 Code";
                        lDimValue."Global Dimension No." := 3;
                        if lDimValue.Code <> '' THEN
                            lDimValue.INSERT;
                    END;
                    if NOT lDimValue.GET(gGenLedgerSetup."Shortcut Dimension 4 Code", lPurchLineArchive."Shortcut Dimension 4 Code") THEN BEGIN
                        lDimValue.INIT;
                        lDimValue."Dimension Code" := gGenLedgerSetup."Shortcut Dimension 4 Code";
                        lDimValue.Code := lPurchLineArchive."Shortcut Dimension 4 Code";
                        lDimValue."Global Dimension No." := 4;
                        if lDimValue.Code <> '' THEN
                            lDimValue.INSERT;
                    END;
                    if NOT lDimValue.GET(gGenLedgerSetup."Shortcut Dimension 5 Code", lPurchLineArchive."Shortcut Dimension 5 Code") THEN BEGIN
                        lDimValue.INIT;
                        lDimValue."Dimension Code" := gGenLedgerSetup."Shortcut Dimension 5 Code";
                        lDimValue.Code := lPurchLineArchive."Shortcut Dimension 5 Code";
                        lDimValue."Global Dimension No." := 5;
                        if lDimValue.Code <> '' THEN
                            lDimValue.INSERT;
                    END;
                    if (lPurchRcptLineTMP2.Type.AsInteger() <> 0) AND (lPurchRcptLineTMP2."No." <> '') THEN BEGIN
                        if Not lDimValue2.GET('PRINCIPAL', lPurchRcptLineTMP2."Shortcut Dimension 3 Code") Then lDimValue2.Init;
                        if lDimValue2."Gen. Prod. Posting Group" <> '' THEN BEGIN
                            lGenProdPostGrp.RESET;
                            lGenProdPostGrp.CHANGECOMPANY(COMPANYNAME);
                            if NOT lGenProdPostGrp.GET(lPurchRcptLineTMP2."Gen. Prod. Posting Group") THEN
                                if lDimValue2."Gen. Prod. Posting Group" <> '' Then
                                    lPurchRcptLineTMP2."Gen. Prod. Posting Group" := lDimValue2."Gen. Prod. Posting Group";
                        END ELSE BEGIN
                            lGenProdPostGrp.CHANGECOMPANY(COMPANYNAME);
                            if NOT lGenProdPostGrp.GET(lPurchRcptLineTMP2."Gen. Prod. Posting Group") THEN BEGIN
                                if lPurchRcptLineTMP2."Empresa Origen" = '' THEN
                                    lGenProdPostGrp.CHANGECOMPANY(COMPANYNAME)
                                ELSE
                                    lGenProdPostGrp.CHANGECOMPANY(lPurchRcptLineTMP2."Empresa Origen");
                                if lGenProdPostGrp.GET(lPurchRcptLineTMP2."Gen. Prod. Posting Group") THEN BEGIN
                                    lGenProdPostGrp.SETRANGE(lGenProdPostGrp."Filtro Empresa Origen", lPurchRcptLineTMP2."Empresa Origen");
                                    lGenProdPostGrp.SETRANGE(lGenProdPostGrp."Filtro Empresa Destino", COMPANYNAME);
                                    lGenProdPostGrp.CALCFIELDS(lGenProdPostGrp."Grupo Equivalente");
                                    if lGenProdPostGrp."Grupo Equivalente" = '' THEN
                                        ERROR(glEquivalencia,
                                        lPurchRcptLineTMP2."Empresa Origen", COMPANYNAME, lPurchRcptLineTMP2."Gen. Prod. Posting Group");
                                    lPurchRcptLineTMP2."Gen. Prod. Posting Group" := lGenProdPostGrp."Grupo Equivalente";
                                END;
                            END;
                        END;
                    END;
                    if lPurchRcptLineTMP2."Gen. Prod. Posting Group" <> '' Then
                        lPurchLineArchive."Gen. Prod. Posting Group" := lPurchRcptLineTMP2."Gen. Prod. Posting Group";
                    lPurchLineArchive.VALIDATE("Shortcut Dimension 1 Code", lPurchLineArchive."Shortcut Dimension 1 Code");
                    lPurchLineArchive.VALIDATE("Shortcut Dimension 2 Code", lPurchLineArchive."Shortcut Dimension 2 Code");
                    lPurchLineArchive.VALIDATE("Shortcut Dimension 3 Code", lPurchLineArchive."Shortcut Dimension 3 Code");
                    lPurchLineArchive.VALIDATE("Shortcut Dimension 4 Code", lPurchLineArchive."Shortcut Dimension 4 Code");
                    lPurchLineArchive.VALIDATE("Shortcut Dimension 5 Code", lPurchLineArchive."Shortcut Dimension 5 Code");
                    lPurchLineArchive.MODIFY;
                UNTIL lPurchRcptLineTMP2.NEXT = 0;
            if lPurchHeaderArchive.GET(lPurchHeaderArchive."Document Type"::Order, "No.") THEN BEGIN
                lPurchHeaderArchive.CALCFIELDS(lPurchHeaderArchive.Amount, lPurchHeaderArchive."Amount Including VAT");
                CALCFIELDS(Amount, "Amount Including VAT");
                lDImporte := Amount - lPurchHeaderArchive.Amount;
                if Abs(lDImporte) > Abs(lPurchHeaderArchive.Amount) Then Error(glErrorDesglose);
                lPurchLineArchive.SETRANGE("Document Type", lPurchLineArchive."Document Type"::Order);
                lPurchLineArchive.SETRANGE(lPurchLineArchive."Document No.", "No.");
                if lPurchLineArchive.FINDFIRST THEN BEGIN
                    REPEAT
                        if COMPANYNAME in [glUnion, glUATI] THEN
                            lDImporteNuevo += ROUND((lPurchLineArchive.Quantity * lPurchLineArchive."Direct Unit Cost") * (1 - lPurchLineArchive."Line Discount %" / 100), 0.01, '=')
                        ELSE
                            if lPurchLineArchive."Line Discount %" = 0 THEN
                                lDImporteNuevo += ROUND((lPurchLineArchive.Quantity * lPurchLineArchive."Direct Unit Cost"), 0.01, '=')
                            ELSE
                                lDImporteNuevo += ROUND((lPurchLineArchive.Quantity * lPurchLineArchive."Unit Cost (LCY)"), 0.01, '=');
                    UNTIL lPurchLineArchive.NEXT = 0;
                    lDImporte := lDImporteOri - lDImporteNuevo;
                END;
                lDImporteIvaIncluido := "Amount Including VAT" - lPurchHeaderArchive."Amount Including VAT";
                lPurchRcptLineOrg.SETRANGE(lPurchRcptLineOrg."Document No.", "No.");
                lPurchRcptLineOrg.SETRANGE(lPurchRcptLineOrg.Type, lPurchRcptLineOrg.Type::Resource);
                if NOT lPurchRcptLineOrg.FINDFIRST THEN
                    lPurchRcptLineOrg.SETFILTER(lPurchRcptLineOrg.Type, '<>%1', lPurchRcptLineOrg.Type::" ");
                if lPurchRcptLineOrg.FINDFIRST THEN BEGIN
                    if (lDImporte <> 0) OR (lDImporteIvaIncluido <> 0) THEN BEGIN
                        lPurchLineArchive.SETRANGE("Document Type", lPurchLineArchive."Document Type"::Order);
                        lPurchLineArchive.SETRANGE(lPurchLineArchive."Document No.", "No.");
                        lPurchLineArchive.FINDLAST;
                        gDTotalliDiasReservas[1] := lPurchLineArchive."Line No.";
                        lPurchLineArchive.SETRANGE(lPurchLineArchive.Quantity, 0.0001, 9999);
                        lPurchLineArchive.FINDLAST;
                        lResource.RESET;
                        lResource.CHANGECOMPANY(COMPANYNAME);
                        lCCuenta := lPurchRcptLineOrg."No.";
                        if lResource.GET(lPurchRcptLineOrg."No.") THEN BEGIN
                            If Not lGeneralPostingSetup.GET("Gen. Bus. Posting Group", lResource."Gen. Prod. Posting Group") Then
                                lGeneralPostingSetup.Get(lpurchRcptLineOrg."Gen. Bus. Posting Group", lpurchRcptLineOrg."Gen. Prod. Posting Group");
                            lGeneralPostingSetup.TestField(lGeneralPostingSetup."Purch. Account");
                            lCCuenta := lGeneralPostingSetup."Purch. Account";
                        END;
                        lPurchLineArchive := lPurchLineArchive;
                        lPurchLineArchiveTMP := lPurchLineArchive;
                        lPurchLineArchive."Document No." := "No.";
                        lPurchLineArchive."Document Type" := lPurchLineArchive."Document Type"::Order;
                        lPurchLineArchive."Line No." := gDTotalliDiasReservas[1] + 1;
                        lPurchLineArchive.Type := lPurchLineArchive.Type::"G/L Account";
                        lPurchLineArchive."No." := lCCuenta;
                        lPurchLineArchive.Description := 'Redondeo factura';
                        lPurchLineArchive.Quantity := 1;
                        lPurchLineArchive."Qty. to Invoice" := 1;
                        lPurchLineArchive."Qty. to Receive" := 1;
                        lPurchLineArchive."Qty. Rcd. Not Invoiced" := 1;
                        If ABS(lDImporte) > 1000 Then Error('Imposible desglosar, concacte con informática');
                        lPurchLineArchive."Direct Unit Cost" := lDImporte;
                        lPurchLineArchive."Line Discount %" := 0;
                        lPurchLineArchive."VAT Base Amount" := lDImporte;
                        lPurchLineArchive.Amount := lDImporte;
                        If ABS(lDImporteIvaIncluido) > 1000 Then Error('Imposible desglosar, concacte con informática');
                        lPurchLineArchive."Amount Including VAT" := lDImporteIvaIncluido;
                        lPurchLineArchive."Quantity (Base)" := 1;
                        lPurchLineArchive."Line Amount" := lDImporte;
                        lPurchLineArchive."Inv. Discount Amount" := 0;
                        lPurchLineArchive."Gen. Bus. Posting Group" := lPurchRcptLineOrg."Gen. Bus. Posting Group";
                        if lPurchRcptLineOrg."Gen. Prod. Posting Group" <> '' Then
                            lPurchLineArchive."Gen. Prod. Posting Group" := lPurchRcptLineOrg."Gen. Prod. Posting Group";
                        lPurchLineArchive."VAT Bus. Posting Group" := lPurchRcptLineOrg."VAT Bus. Posting Group";
                        lPurchLineArchive."VAT Prod. Posting Group" := lPurchRcptLineOrg."VAT Prod. Posting Group";
                        lPurchLineArchive.VALIDATE("Shortcut Dimension 1 Code", lPurchLineArchiveTMP."Shortcut Dimension 1 Code");
                        lPurchLineArchive.VALIDATE("Shortcut Dimension 2 Code", lPurchLineArchiveTMP."Shortcut Dimension 2 Code");
                        lPurchLineArchive.VALIDATE("Shortcut Dimension 3 Code", lPurchLineArchiveTMP."Shortcut Dimension 3 Code");
                        lPurchLineArchive.VALIDATE("Shortcut Dimension 4 Code", lPurchLineArchiveTMP."Shortcut Dimension 4 Code");
                        lPurchLineArchive.VALIDATE("Shortcut Dimension 5 Code", lPurchLineArchiveTMP."Shortcut Dimension 5 Code");
                        lPurchLineArchive.INSERT;
                    END;
                END;
            END;

            COMMIT;
            lPurchLineArchive.RESET;
            lPurchLineArchive.SETRANGE("Document Type", lPurchLineArchive."Document Type"::Order);
            lPurchLineArchive.SETRANGE(lPurchLineArchive."Document No.", "No.");
            if lPurchLineArchive.FINDFIRST THEN
                REPEAT
                    pPurchRcptLineTMP.TransferFields(lPurchLineArchive);
                    pPurchRcptLineTMP."Recurso Agrupado" := lPurchLineArchive."Recurso Agrupado";
                    if pPurchRcptLineTMP.INSERT THEN;
                UNTIL lPurchLineArchive.NEXT = 0;
        END;
    End;

    /// <summary>
    /// FillFacPostingBuffer.
    /// </summary>
    /// <param name="PurchLine">Record "Purch. Rcpt. Line".</param>
    /// <param name="piLinea">Integer.</param>
    procedure FillFacPostingBuffer(pPurchRcptLine: Record "Purch. Rcpt. Line"; piLinea: Integer; var TempBuffer: Record "Invoice Posting Buffer" temporary)
    var
        lDAmount: Decimal;
        lDAmountLCY: Decimal;
        lVendor: Record "Vendor";
        lVendorPostingGroup: Record "Vendor Posting Group";
        lPurchRcptHeader: Record "Purch. Rcpt. Header";
        lLocation: Record 14;
        lPurchHeader: Record "Purchase Header";
        lVatPostingGroup: Record "VAT Business Posting Group";
        FalineNo: Integer;

    Begin
        WITH pPurchRcptLine DO BEGIN
            lPurchRcptHeader.Get("Document No.");
            if Not lPurchHeader.GET(lPurchHeader."Document Type"::Order, lPurchRcptHeader."Order No.") Then lPurchHeader.Init();
            If lPurchHeader."Pay-to Vendor No." = '' Then lPurchHeader."Pay-to Vendor No." := lPurchRcptHeader."Pay-to Vendor No.";
            lVendor.GET(lPurchHeader."Pay-to Vendor No.");
            lVendorPostingGroup.GET(lVendor."Vendor Posting Group");

            if ("Gen. Bus. Posting Group" <> gGenPostingSetup."Gen. Bus. Posting Group") OR
                ("Gen. Prod. Posting Group" <> gGenPostingSetup."Gen. Prod. Posting Group")
            THEN
                gGenPostingSetup.GET("Gen. Bus. Posting Group", "Gen. Prod. Posting Group");
            CLEAR(TempBuffer);
            TempBuffer.Type := Type;
            if (Type = Type::"Fixed Asset") THEN
                TempBuffer."G/L Account" := "No."
            ELSE BEGIN
                //gGenPostingSetup.TestField("Purch. Account");
                TempBuffer."G/L Account" := lVendorPostingGroup.FPR;
            END;
            TempBuffer."System-Created Entry" := TRUE;
            TempBuffer."Gen. Bus. Posting Group" := "Gen. Bus. Posting Group";
            TempBuffer."Gen. Prod. Posting Group" := "Gen. Prod. Posting Group";
            TempBuffer."VAT Bus. Posting Group" := "VAT Bus. Posting Group";
            TempBuffer."VAT Prod. Posting Group" := "VAT Prod. Posting Group";
            TempBuffer."VAT Calculation Type" := "VAT Calculation Type";
            TempBuffer."Global Dimension 1 Code" := "Shortcut Dimension 1 Code";
            TempBuffer."Global Dimension 2 Code" := "Shortcut Dimension 2 Code";
            //ASC
            TempBuffer."Global Dimension 3 Code" := "Shortcut Dimension 3 Code";
            TempBuffer."Global Dimension 4 Code" := "Shortcut Dimension 4 Code";
            TempBuffer."Global Dimension 5 Code" := "Shortcut Dimension 5 Code";
            TempBuffer."Dimension Set ID" := "Dimension Set ID";
            TempBuffer."Job No." := "Job No.";
            if COMPANYNAME in [glUnion, glUATI] THEN
                lDAmount := ("Qty. Rcd. Not Invoiced" * "Direct Unit Cost") * (1 - "Line Discount %" / 100)
            ELSE
                lDAmount := ("Qty. Rcd. Not Invoiced" * "Unit Cost (LCY)");
            if "Line Discount %" = 0 THEN
                lDAmount := ("Qty. Rcd. Not Invoiced" * "Direct Unit Cost");
            lDAmountLCY := ROUND(lDAmount, 0.01, '=');
            TempBuffer."Agrupado" := "Recurso Agrupado";
            TempBuffer.Amount := ROUND(lDAmount, 0.01, '=');
            TempBuffer."VAT Base Amount" := ROUND(lDAmount, 0.01, '=');
            TempBuffer."Amount (ACY)" := lDAmountLCY;

            TempBuffer."VAT Base Amount (ACY)" := lDAmountLCY;
            TempBuffer."VAT Difference" := 0;//"VAT Difference";
            TempBuffer."VAT %" := "VAT %";
            //-SII
            gGenLedgerSetup.GET;
            if gGenLedgerSetup."Activar SII" THEN BEGIN
                if gVATPostingSetup.GET(pPurchRcptLine."VAT Bus. Posting Group", pPurchRcptLine."VAT Prod. Posting Group") THEN;
                if lVatPostingGroup.GET(pPurchRcptLine."VAT Bus. Posting Group") THEN;
                //PurchaseHeader.GET(pPurchRcptLine."Document Type",pPurchRcptLine."Document No.");
                TempBuffer."Tipo factura SII" := lPurchHeader."Tipo factura SII";
                TempBuffer."Clave registro SII recibidas" := lVatPostingGroup."Clave registro SII recibidas";
                TempBuffer."Descripción operación" := lPurchHeader."Descripción operación";
                TempBuffer."Tipo desglose emitidas" := gVATPostingSetup."Tipo desglose emitidas";
                TempBuffer."Sujeta exenta" := gVATPostingSetup."Sujeta exenta";
                TempBuffer."Tipo de operación" := gVATPostingSetup."Tipo de operación";
                TempBuffer."Tipo factura rectificativa" := lPurchHeader."Tipo factura rectificativa";
            END;
            //+SII

            if Type = Type::"Fixed Asset" THEN BEGIN
                TempBuffer."FA Posting Date" := "FA Posting Date";
                TempBuffer."FA Posting Type" := "FA Posting Type";
                TempBuffer."Depreciation Book Code" := "Depreciation Book Code";
                TempBuffer."Salvage Value" := "Salvage Value";
                TempBuffer."Depr. until FA Posting Date" := "Depr. until FA Posting Date";
                TempBuffer."Depr. Acquisition Cost" := "Depr. Acquisition Cost";
                TempBuffer."Maintenance Code" := "Maintenance Code";
                TempBuffer."Insurance No." := "Insurance No.";
                TempBuffer."Budgeted FA No." := "Budgeted FA No.";
                TempBuffer."Duplicate in Depreciation Book" := "Duplicate in Depreciation Book";
                TempBuffer."Use Duplication List" := "Use Duplication List";
            END;
            CASE "VAT Calculation Type" OF
                "VAT Calculation Type"::"Normal VAT", "VAT Calculation Type"::"Full VAT":
                    BEGIN
                        TempBuffer."VAT Amount" := Amount * (pPurchRcptLine."VAT %" / 100);
                        TempBuffer."VAT Amount (ACY)" :=
                        lDAmountLCY * (pPurchRcptLine."VAT %" / 100);
                    END;
                "VAT Calculation Type"::"Reverse Charge VAT":
                    ; // Reverse Charge VAT is calculated later, based on totals
                "VAT Calculation Type"::"Sales Tax":
                    BEGIN
                        if NOT "Use Tax" THEN BEGIN  // Use Tax is calculated later, based on totals
                            TempBuffer."VAT Amount" := Amount * (pPurchRcptLine."VAT %" / 100);
                            TempBuffer."VAT Amount (ACY)" :=
                                lDAmountLCY * (pPurchRcptLine."VAT %" / 100);
                        END;
                        TempBuffer."Tax Area Code" := "Tax Area Code";
                        TempBuffer."Tax Liable" := "Tax Liable";
                        TempBuffer."Tax Group Code" := "Tax Group Code";
                        TempBuffer."Use Tax" := "Use Tax";
                        TempBuffer.Quantity := pPurchRcptLine."Qty. Rcd. Not Invoiced";
                    END;
            END;

            if gPurchSetup."Post Invoice Discount" THEN BEGIN
                TempBuffer.Amount := TempBuffer.Amount;// + "Inv. Discount Amount";
                TempBuffer."Inv. Discount Amount" := 0;//"Inv. Discount Amount";
                TempBuffer."Amount (ACY)" :=
                TempBuffer."Amount (ACY)";// + PurchLineACY."Inv. Discount Amount";
                TempBuffer."Inv. Discount Amt. (ACY)" := 0;//PurchLineACY."Inv. Discount Amount";
                                                           // {if ("Inv. Discount Amount" <> 0) OR (PurchLineACY."Inv. Discount Amount" <> 0)THEN BEGIN
                                                           // gGenPostingSetup.TestField("Purch. Inv. Disc. Account");
                                                           // TempBuffer."Inv. Discount Account" := gGenPostingSetup."Purch. Inv. Disc. Account";
                                                           // END;}
            END;
            if gPurchSetup."Post Line Discount" THEN BEGIN
                TempBuffer.Amount := TempBuffer.Amount + TempBuffer.Amount * (pPurchRcptLine."Line Discount %" / 100);
                TempBuffer."Line Discount Amount" := TempBuffer.Amount * (pPurchRcptLine."Line Discount %" / 100);
                TempBuffer."Amount (ACY)" :=
                TempBuffer."Amount (ACY)" + TempBuffer."Amount (ACY)" * (pPurchRcptLine."Line Discount %" / 100);
                TempBuffer."Line Discount Amt. (ACY)" := TempBuffer."Amount (ACY)" * (pPurchRcptLine."Line Discount %" / 100);
                if (TempBuffer.Amount * (pPurchRcptLine."Line Discount %" / 100) <> 0) OR
                (TempBuffer."Amount (ACY)" * (pPurchRcptLine."Line Discount %" / 100) <> 0) THEN BEGIN
                    gGenPostingSetup.TestField("Purch. Line Disc. Account");
                    TempBuffer."Line Discount Account" := gGenPostingSetup."Purch. Line Disc. Account";
                END;
            END;
            if gPurchSetup."Post Payment Discount" THEN BEGIN
                TempBuffer.Amount := TempBuffer.Amount;// + "Pmt. Disc. Rcd. Amount";
                TempBuffer."Pmt. Discount Amount" := 0;//"Pmt. Disc. Rcd. Amount";
                TempBuffer."Amount (ACY)" :=
                TempBuffer."Amount (ACY)";// + PurchLineACY."Pmt. Disc. Rcd. Amount";
                TempBuffer."Src. Curr. Pmt. Discount Amt." := 0;//PurchLineACY."Pmt. Disc. Rcd. Amount";
                                                                // {if (pPurchRcptLine."Pmt. Disc. Rcd. Amount" <> 0) OR (PurchLineACY."Pmt. Disc. Rcd. Amount" <> 0) THEN BEGIN
                                                                // gGenPostingSetup.TestField("Purch. Pmt. Disc. Credit Acc.");
                                                                // TempBuffer."Pmt. Discount Account" := gGenPostingSetup."Purch. Pmt. Disc. Credit Acc.";
                                                                // END;}
            END;

            //  TempBuffer."FA Discount Account" := FASetDiscountAccount(PurchLine);
            // TempDocDim.SETRANGE("Table ID","Purchase Line");
            // TempDocDim.SETRANGE("Line No.",Linea);

        END;
    End;

    Procedure Redondear(pDImporte: Decimal; pbUnit: Boolean; var pSalesHeader: Record "Sales Header"): Decimal
    var
        lCurrency: Record Currency;
    begin

        if pSalesHeader."Currency Code" = '' THEN
            lCurrency.InitRoundingPrecision
        ELSE
            lCurrency.GET(pSalesHeader."Currency Code");
        if pbUnit THEN
            EXIT(ROUND(
            pDImporte,
            lCurrency."Unit-Amount Rounding Precision"))
        ELSE
            EXIT(ROUND(
                    pDImporte,
                lCurrency."Amount Rounding Precision"));
    end;

    Procedure RedondearP(pDImporte: Decimal; pbUnit: Boolean; var pPurchHeader: Record "Purchase Header"): Decimal
    var
        lCurrency: Record Currency;
    begin


        if pPurchHeader."Currency Code" = '' THEN
            lCurrency.InitRoundingPrecision
        ELSE
            lCurrency.GET(pPurchHeader."Currency Code");
        if pbUnit THEN
            EXIT(ROUND(
            pDImporte,
            lCurrency."Unit-Amount Rounding Precision"))
        ELSE
            EXIT(ROUND(
                    pDImporte,
                lCurrency."Amount Rounding Precision"));
    end;

    internal procedure DesContabilizaDevoluciones(var pReturnShptHdr: Record "Return Shipment Header")
    var
        pReturnShptLine: Record "Return Shipment Line";
        pReturnShptACY: Record "Return Shipment Line";
        lVendor: Record Vendor;
        ICHandledInboxTransaction: Record "Handled IC Inbox Trans.";
        ICPartner: Record "IC Partner";
        lSalesSetup: Record "Sales & Receivables Setup";
        lDDiscountVATAmount: Decimal;
        lVendorPostingGroup: Record "Vendor Posting Group";
        lDTotal: Decimal;
        lDTotalACY: Decimal;
        lCGenJnlLineDocNo: Code[20];
        ltGenJnlLineExtDocNo: Text;
        liLinecount: Integer;
        TempBuffer: Record "Invoice Posting Buffer" temporary;
        TempBuffer2: Record "Invoice Posting Buffer" temporary;
        FALineNo: Integer;
    begin

        WITH pReturnShptHdr DO BEGIN

            if NOT Contabilizado THEN ERROR(glDebeContabilizado);
            //GenJnlLineDocType := 0;
            lCGenJnlLineDocNo := "No.";
            ltGenJnlLineExtDocNo := "Vendor Authorization No.";
            lDTotal := 0;
            lDTotalACY := 0;
            pReturnShptLine.SETRANGE(pReturnShptLine."Document No.", pReturnShptHdr."No.");
            if pReturnShptLine.FINDFIRST THEN
                REPEAT
                    if (pReturnShptLine.Type.AsInteger() >= pReturnShptLine.Type::"G/L Account".AsInteger()) AND (pReturnShptLine."Return Qty. Shipped Not Invd." <> 0) THEN BEGIN
                        // Copy purchase to Buffer
                        pReturnShptACY.GET(pReturnShptLine."Document No.", pReturnShptLine."Line No.");
                        // DocDim.SETRANGE(DocDim."Table ID","Purchase Line");
                        //    lPurchRecptLine.SET// RANGE(lPurchRecptLine."Document No.", Rec."No.");
                        // REPEAT
                        // DocDim.SETRANGE(DocDim."Line No.",pReturnShptLine."Return Order Line No.");
                        // if DocDim.FINDFIRST THEN REPEAT
                        // TempDocDim:=DocDim;
                        // if TempDocDim.INSERT THEN;
                        // UNTIL DocDim.NEXT=0;

                        FillDevPostingBuffer(pReturnShptLine, pReturnShptACY, pReturnShptLine."Return Order Line No.", TempBuffer);
                        UpdInvPostingBuldFFeProduccionesgloNew(TempBuffer, FALineNo, TempBuffer2);
                        // TempDocDim.SETRANGE("Table ID");
                        // TempDocDim.SETRANGE("Line No.");
                    END;
                UNTIL pReturnShptLine.NEXT = 0;
            // Post purchase and VAT to G/L entries from Buffer
            //liLinecount := 0;
            TempBuffer2.RESET;
            if TempBuffer2.FIND('+') THEN
                REPEAT
                    liLinecount := liLinecount + 1;
                    //if GUIALLOWED THEN
                    //Window.UPDATE(3,liLinecount);

                    CASE TempBuffer2."VAT Calculation Type" OF
                        TempBuffer2."VAT Calculation Type"::"Reverse Charge VAT":
                            BEGIN
                                gVATPostingSetup.GET(
                                    TempBuffer2."VAT Bus. Posting Group", TempBuffer2."VAT Prod. Posting Group");
                                TempBuffer2."VAT Amount" :=
                                    ROUND(
                                    (TempBuffer2.Amount -
                                    TempBuffer2."Line Discount Amount" -
                                    TempBuffer2."Inv. Discount Amount" -
                                    TempBuffer2."Pmt. Discount Amount") *
                                    gVATPostingSetup."VAT+EC %" / 100);
                                TempBuffer2."VAT Amount (ACY)" :=
                                    ROUND(
                                    (TempBuffer2."Amount (ACY)" -
                                    TempBuffer2."Line Discount Amt. (ACY)" -
                                    TempBuffer2."Inv. Discount Amt. (ACY)" -
                                    TempBuffer2."Src. Curr. Pmt. Discount Amt.") *
                                    gVATPostingSetup."VAT+EC %" / 100, gCurrency."Amount Rounding Precision");
                            END;
                        TempBuffer2."VAT Calculation Type"::"Sales Tax":
                            BEGIN
                                if TempBuffer2."Use Tax" THEN BEGIN
                                    TempBuffer2."VAT Amount" :=
                                    ROUND(
                                        gcSalesTaxCalculate.CalculateTax(
                                        TempBuffer2."Tax Area Code", TempBuffer2."Tax Group Code",
                                        TempBuffer2."Tax Liable", "Posting Date",
                                        TempBuffer2.Amount -
                                        TempBuffer2."Line Discount Amount" - TempBuffer2."Inv. Discount Amount" -
                                        TempBuffer2."Pmt. Discount Amount",
                                        TempBuffer2.Quantity, 0));
                                    if gGenLedgerSetup."Additional Reporting Currency" <> '' THEN
                                        TempBuffer2."VAT Amount (ACY)" :=
                                        gCurrExchRate.ExchangeAmtLCYToFCY(
                                            "Posting Date", gGenLedgerSetup."Additional Reporting Currency",
                                            TempBuffer2."VAT Amount", 0);
                                END;
                            END;
                    END;

                    if (False) AND (TempBuffer2."VAT %" <> 0) THEN
                        WITH TempBuffer2 DO BEGIN
                            lDDiscountVATAmount :=
                            ROUND("Line Discount Amount" * "VAT %" / (1 + "VAT %" / 100) / 100);
                            Amount := Amount - lDDiscountVATAmount;
                            "Line Discount Amount" := "Line Discount Amount" - lDDiscountVATAmount;

                            lDDiscountVATAmount :=
                            ROUND(
                                "Line Discount Amt. (ACY)" * "VAT %" / (1 + "VAT %" / 100) / 100,
                                gCurrency."Amount Rounding Precision");
                            "Amount (ACY)" := "Amount (ACY)" - lDDiscountVATAmount;
                            "Line Discount Amt. (ACY)" := "Line Discount Amt. (ACY)" - lDDiscountVATAmount;

                            lDDiscountVATAmount :=
                            ROUND("Inv. Discount Amount" * "VAT %" / (1 + "VAT %" / 100) / 100);
                            Amount := Amount - lDDiscountVATAmount;
                            "Inv. Discount Amount" := "Inv. Discount Amount" - lDDiscountVATAmount;

                            lDDiscountVATAmount :=
                            ROUND(
                                "Src. Curr. Pmt. Discount Amt." * "VAT %" / (1 + "VAT %" / 100) / 100,
                                gCurrency."Amount Rounding Precision");
                            "Amount (ACY)" := "Amount (ACY)" - lDDiscountVATAmount;
                            "Inv. Discount Amt. (ACY)" := "Inv. Discount Amt. (ACY)" - lDDiscountVATAmount;

                            lDDiscountVATAmount :=
                            ROUND(
                                "Inv. Discount Amt. (ACY)" * "VAT %" / (1 + "VAT %" / 100) / 100,
                                gCurrency."Amount Rounding Precision");
                            "Amount (ACY)" := "Amount (ACY)" - lDDiscountVATAmount;
                            "Inv. Discount Amt. (ACY)" := "Inv. Discount Amt. (ACY)" - lDDiscountVATAmount;
                        END;

                    gGenJnlLine.INIT;
                    gGenJnlLine."Posting Date" := WORKDATE;
                    gGenJnlLine."Document Date" := "Document Date";
                    gGenJnlLine.Description := COPYSTR("Posting Description", 1, MAXSTRLEN(gGenJnlLine.Description));
                    gGenJnlLine."Reason Code" := "Reason Code";
                    gGenJnlLine."Document Type" := gGenJnlLine."Document Type"::Receipt;
                    gGenJnlLine."Document No." := "No.";
                    gGenJnlLine."Tax Area Code" := "No.";
                    gGenJnlLine."External Document No." := pReturnShptHdr."Vendor Authorization No.";
                    gGenJnlLine."Account No." := TempBuffer2."G/L Account";
                    gGenJnlLine."System-Created Entry" := TempBuffer2."System-Created Entry";
                    gGenJnlLine.Amount := TempBuffer2.Amount;
                    lDTotal := lDTotal + TempBuffer2.Amount;
                    gGenJnlLine."Source Currency Code" := "Currency Code";
                    gGenJnlLine."Source Currency Amount" := TempBuffer2."Amount (ACY)";
                    lDTotalACY := lDTotalACY + TempBuffer2."Amount (ACY)";
                    gGenJnlLine.Correction := Correction;
                    gGenJnlLine."Gen. Posting Type" := gGenJnlLine."Gen. Posting Type"::" ";
                    gGenJnlLine."Gen. Bus. Posting Group" := '';//TempBuffer2."Gen. Bus. Posting Group";
                    gGenJnlLine."Gen. Prod. Posting Group" := '';// TempBuffer2."Gen. Prod. Posting Group";
                    gGenJnlLine."VAT Bus. Posting Group" := '';//TempBuffer2."VAT Bus. Posting Group";
                    gGenJnlLine."VAT Prod. Posting Group" := '';//TempBuffer2."VAT Prod. Posting Group";
                    gGenJnlLine."Tax Area Code" := TempBuffer2."Tax Area Code";
                    gGenJnlLine."Tax Liable" := TempBuffer2."Tax Liable";
                    gGenJnlLine."Tax Group Code" := TempBuffer2."Tax Group Code";
                    gGenJnlLine."Use Tax" := TempBuffer2."Use Tax";
                    gGenJnlLine.Quantity := TempBuffer2.Quantity;
                    gGenJnlLine."VAT Calculation Type" := TempBuffer2."VAT Calculation Type";
                    gGenJnlLine."VAT Base Amount" := -TempBuffer2."VAT Base Amount";
                    gGenJnlLine."VAT Base Discount %" := "VAT Base Discount %";
                    gGenJnlLine."Source Curr. VAT Base Amount" := -TempBuffer2."VAT Base Amount (ACY)";
                    gGenJnlLine."VAT Amount" := -TempBuffer2."VAT Amount";
                    gGenJnlLine."Source Curr. VAT Amount" := -TempBuffer2."VAT Amount (ACY)";
                    gGenJnlLine."VAT Difference" := -TempBuffer2."VAT Difference";
                    gGenJnlLine."VAT Posting" := gGenJnlLine."VAT Posting"::"Manual VAT Entry";
                    gGenJnlLine."Shortcut Dimension 1 Code" := TempBuffer2."Global Dimension 1 Code";
                    gGenJnlLine."Shortcut Dimension 2 Code" := TempBuffer2."Global Dimension 2 Code";
                    //ASC
                    gGenJnlLine."Shortcut Dimension 3 Code" := TempBuffer2."Global Dimension 3 Code";
                    gGenJnlLine."Shortcut Dimension 4 Code" := TempBuffer2."Global Dimension 4 Code";
                    gGenJnlLine."Shortcut Dimension 5 Code" := TempBuffer2."Global Dimension 5 Code";
                    gGenJnlLine.Circuito := TRUE;
                    gGenJnlLine."Dimension Set ID" := TempBuffer2."Dimension Set ID";
                    gGenJnlLine."Job No." := TempBuffer2."Job No.";
                    gGenJnlLine."Source Code" := gCSrcCode;
                    gGenJnlLine."Sell-to/Buy-from No." := "Buy-from Vendor No.";
                    gGenJnlLine."Bill-to/Pay-to No." := "Pay-to Vendor No.";
                    gGenJnlLine."Country/Region Code" := "VAT Country/Region Code";
                    gGenJnlLine."VAT Registration No." := "VAT Registration No.";
                    gGenJnlLine."Source Type" := gGenJnlLine."Source Type"::Vendor;
                    gGenJnlLine."Source No." := "Pay-to Vendor No.";
                    gGenJnlLine."Posting No. Series" := '';
                    gGenJnlLine."IC Partner Code" := '';//"Pay-to IC Partner Code";
                    gGenJnlLine."Ship-to/Order Address Code" := "Order Address Code";

                    gGenJnlLine."Payment Terms Code" := "Payment Terms Code";
                    gGenJnlLine."Payment Method Code" := "Payment Method Code";

                    gGenJnlLine."Generate AutoInvoices" := FALSE;//"Generate Autoinvoices" OR "Generate Autocredit Memo";
                    gGenJnlLine."AutoDoc. No." := '';

                    if TempBuffer2.Type = TempBuffer2.Type::"Fixed Asset" THEN BEGIN
                        gGenJnlLine."Account Type" := gGenJnlLine."Account Type"::"Fixed Asset";
                        if TempBuffer2."FA Posting Type" =
                            TempBuffer2."FA Posting Type"::"Acquisition Cost"
                        THEN
                            gGenJnlLine."FA Posting Type" := gGenJnlLine."FA Posting Type"::"Acquisition Cost";
                        if TempBuffer2."FA Posting Type" =
                            TempBuffer2."FA Posting Type"::Maintenance
                        THEN
                            gGenJnlLine."FA Posting Type" := gGenJnlLine."FA Posting Type"::Maintenance;
                        gGenJnlLine."FA Posting Date" := TempBuffer2."FA Posting Date";
                        gGenJnlLine."Depreciation Book Code" := TempBuffer2."Depreciation Book Code";
                        gGenJnlLine."Salvage Value" := TempBuffer2."Salvage Value";
                        gGenJnlLine."Depr. until FA Posting Date" := TempBuffer2."Depr. until FA Posting Date";
                        gGenJnlLine."Depr. Acquisition Cost" := TempBuffer2."Depr. Acquisition Cost";
                        gGenJnlLine."Maintenance Code" := TempBuffer2."Maintenance Code";
                        gGenJnlLine."Insurance No." := TempBuffer2."Insurance No.";
                        gGenJnlLine."Budgeted FA No." := TempBuffer2."Budgeted FA No.";
                        gGenJnlLine."Duplicate in Depreciation Book" := TempBuffer2."Duplicate in Depreciation Book";
                        gGenJnlLine."Use Duplication List" := TempBuffer2."Use Duplication List";
                    END;

                    RungcGenJnlPostLine(gGenJnlLine);
                    // if FAInsertDiscountAmount(TempBuffer2, DeprBook) THEN
                    //     FAPostDiscountAmount(
                    //         gGenJnlLine,
                    //         TempBuffer2."Line Discount Amount" + TempBuffer2."Inv. Discount Amount",
                    //         TempBuffer2."Line Discount Amt. (ACY)" + TempBuffer2."Inv. Discount Amt. (ACY)",
                    //         TempBuffer2."Dimension Entry No.");
                    gGenJnlLine."Account Type" := gGenJnlLine."Account Type"::"G/L Account";
                    gGenJnlLine.VALIDATE("FA Posting Type", gGenJnlLine."FA Posting Type"::" ");
                // if FAInsertDiscountAmount(TempBuffer2, DeprBook) THEN
                //     PostDiscount(
                //         TempBuffer2."FA Discount Account",
                //         (TempBuffer2."Line Discount Amount" + TempBuffer2."Inv. Discount Amount"),
                //         (TempBuffer2."Line Discount Amt. (ACY)" + TempBuffer2."Inv. Discount Amt. (ACY)"),
                //         TempBuffer2."Dimension Entry No.");
                // if (TempBuffer2."Line Discount Amount" <> 0) OR
                // (TempBuffer2."Line Discount Amt. (ACY)" <> 0)
                // THEN
                //     PostDiscount(
                //         TempBuffer2."Line Discount Account",
                //         -TempBuffer2."Line Discount Amount",
                //         -TempBuffer2."Line Discount Amt. (ACY)",
                //         TempBuffer2."Dimension Entry No.");
                // if (TempBuffer2."Inv. Discount Amount" <> 0) OR
                // (TempBuffer2."Inv. Discount Amt. (ACY)" <> 0)
                // THEN
                //     PostDiscount(
                //         TempBuffer2."Inv. Discount Account",
                //         -TempBuffer2."Inv. Discount Amount",
                //         -TempBuffer2."Inv. Discount Amt. (ACY)",
                //         TempBuffer2."Dimension Entry No.");
                // if TempBuffer2."Pmt. Discount Amount" <> 0 THEN
                //     PostDiscount(
                //         TempBuffer2."Pmt. Discount Account",
                //         -TempBuffer2."Pmt. Discount Amount",
                //         -TempBuffer2."Src. Curr. Pmt. Discount Amt.",
                //         TempBuffer2."Dimension Entry No.");
                UNTIL TempBuffer2.Next(-1) = 0;

            TempBuffer2.DELETEALL;

            // Check External Document number
            // {if gPurchSetup."Ext. Doc. No. Mandatory" OR
            // (gGenJnlLineExtDocNo <> '')
            // THEN BEGIN
            // VendLedgEntry.RESET;
            // VendLedgEntry.SETCURRENTKEY("External Document No.");
            // VendLedgEntry.SETRANGE("Document Type",gGenJnlLineDocType);
            // VendLedgEntry.SETRANGE("External Document No.",gGenJnlLineExtDocNo);
            // VendLedgEntry.SETRANGE("Vendor No.","Pay-to Vendor No.");
            // if VendLedgEntry.FINDFIRST THEN
            //     ERROR(
            //     Text016,
            //     VendLedgEntry."Document Type",gGenJnlLineExtDocNo);
            // END;}

            // Post vendor entries
            //if GUIALLOWED THEN
            //Window.UPDATE(4,1);
            gGenJnlLine.INIT;
            gGenJnlLine."Posting Date" := WORKDATE;
            gGenJnlLine."Document Date" := "Document Date";
            gGenJnlLine.Description := COPYSTR("Posting Description", 1, MAXSTRLEN(gGenJnlLine.Description));
            gGenJnlLine."Shortcut Dimension 1 Code" := "Shortcut Dimension 1 Code";
            gGenJnlLine."Shortcut Dimension 2 Code" := "Shortcut Dimension 2 Code";
            //ASC
            gGenJnlLine."Shortcut Dimension 3 Code" := "Shortcut Dimension 3 Code";
            gGenJnlLine."Shortcut Dimension 4 Code" := "Shortcut Dimension 4 Code";
            gGenJnlLine."Shortcut Dimension 5 Code" := "Shortcut Dimension 5 Code";
            gGenJnlLine.Circuito := TRUE;
            gGenJnlLine."Reason Code" := "Reason Code";
            gGenJnlLine."Account Type" := gGenJnlLine."Account Type"::"G/L Account";
            lVendor.GET("Pay-to Vendor No.");
            lVendorPostingGroup.GET(lVendor."Vendor Posting Group");
            gGenJnlLine."Account No." := lVendorPostingGroup.FPR;
            gGenJnlLine."Document Type" := gGenJnlLine."Document Type"::Receipt;
            gGenJnlLine."Document No." := lCGenJnlLineDocNo;
            gGenJnlLine."Tax Area Code" := lCGenJnlLineDocNo;
            gGenJnlLine."External Document No." := LtGenJnlLineExtDocNo;
            gGenJnlLine."Currency Code" := "Currency Code";
            gGenJnlLine.Amount := -lDTotal;
            gGenJnlLine."Source Currency Code" := "Currency Code";
            gGenJnlLine."Source Currency Amount" := -lDTotal;
            gGenJnlLine."Amount (LCY)" := -lDTotalACY;

            gGenJnlLine."Sales/Purch. (LCY)" := -lDTotalACY;
            gGenJnlLine.Correction := Correction;
            gGenJnlLine."Inv. Discount (LCY)" := gTotalPurchaseLineLCY."Inv. Discount Amount";
            gGenJnlLine."Pmt. Discount Given/Rec. (LCY)" := 0;
            gGenJnlLine."Sell-to/Buy-from No." := "Buy-from Vendor No.";
            gGenJnlLine."Bill-to/Pay-to No." := "Pay-to Vendor No.";
            gGenJnlLine."Salespers./Purch. Code" := "Purchaser Code";
            gGenJnlLine."System-Created Entry" := TRUE;
            gGenJnlLine."On Hold" := "On Hold";
            gGenJnlLine."Applies-to Doc. Type" := "Applies-to Doc. Type";
            gGenJnlLine."Applies-to Bill No." := '';//Applies-to Bill No.";
            gGenJnlLine."Applies-to Doc. No." := "Applies-to Doc. No.";
            gGenJnlLine."Applies-to ID" := '';
            gGenJnlLine."Allow Application" := "Bal. Account No." = '';
            gGenJnlLine."Payment Terms Code" := "Payment Terms Code";
            gGenJnlLine."Payment Method Code" := "Payment Method Code";
#if not CLEAN22

            // TODO: - CLEAN22
#if not CLEAN27
            gGenJnlLine."Pmt. Address Code" := '';
#endif
            // TODO: - CLEAN22


#endif
            //gGenJnlLine."Cust./Vendor Bank Acc. Code" := '';//"Vendor Bank Acc. Code";
            gGenJnlLine."Due Date" := "Due Date";
            //gGenJnlLine."Pmt. Discount Date" := "Pmt. Discount Date";
            gGenJnlLine."Payment Discount %" := "Payment Discount %";
            gGenJnlLine."Source Type" := gGenJnlLine."Source Type"::Vendor;
            gGenJnlLine."Source No." := "Pay-to Vendor No.";
            gGenJnlLine."Source Code" := gCSrcCode;
            gGenJnlLine."Posting No. Series" := '';
            gGenJnlLine."IC Partner Code" := '';//"Pay-to IC Partner Code";
            gGenJnlLine."Generate AutoInvoices" := FALSE;//"Generate Autoinvoices" OR "Generate Autocredit Memo";
            //gGenJnlLine."AutoDoc. No." := lCAutoDocNo;
            gGenJnlLine."Shortcut Dimension 1 Code" := "Shortcut Dimension 1 Code";
            gGenJnlLine."Shortcut Dimension 2 Code" := "Shortcut Dimension 2 Code";
            //ASC
            gGenJnlLine."Shortcut Dimension 3 Code" := "Shortcut Dimension 3 Code";
            gGenJnlLine."Shortcut Dimension 4 Code" := "Shortcut Dimension 4 Code";
            gGenJnlLine."Shortcut Dimension 5 Code" := "Shortcut Dimension 5 Code";
            gGenJnlLine."Dimension Set ID" := "Dimension Set ID";

            gcGenJnlPostLine.RunWithCheck(gGenJnlLine);

        END;
        MESSAGE('Se ha contabilizado el retroceso del albarán %1 con fecha %2', pReturnShptHdr."No.",
        FORMAT(WORKDATE, 0, '<Day,2>/<Month,2>/<Year>'));
        pReturnShptHdr.Contabilizado := FALSE;
        pReturnShptHdr.MODIFY;
    end;
#pragma warning restore AL0432 // TODO: - Invoice Posting Buffer codunit 825

    /// <summary>
    /// Compruebadimensiones.
    /// </summary>
    /// <param name="pResource">VAR Record Resource.</param>
    /// <param name="Empresa">Text.</param>
    /// <param name="Dim1">VAR Code[20].</param>
    /// <param name="Dim2">VAR Code[20].</param>
    /// <param name="Dim3">VAR Code[20].</param>
    /// <param name="Dim4">VAR Code[20].</param>
    /// <param name="Dim5">VAR Code[20].</param>
    /// <param name="DimensionSetID">VAR integer.</param>
    /// <param name="ProdPostingGr">VAR Code[20].</param>
    /// <param name="pCJob">Code[20].</param>
    /// <param name="RecAgrupado">VAR Boolean.</param>
    /// <param name="Agrupado">boolean.</param>
    procedure Compruebadimensiones(
         var pResource: Record Resource;
         Empresa: Text;
         var pCDim1: Code[20];
         var pCDim2: Code[20];
         var pCDim3: Code[20];
         var pCDim4: Code[20];
         var pCDim5: Code[20];
         var piDimensionSetID: integer;
         var pCProdPostingGr: Code[20];
         pCJob: Code[20];
         var pbRecAgrupado: Boolean;
         pbAgrupado: boolean)
    var
        lcControldeProcesos: Codeunit ControlProcesos;
        lGenProdPosting: Record "Gen. Product Posting Group";
        lpCProdPostingGr: Code[20];
    begin
        gGenLedgerSetup.Get();
        lpCProdPostingGr := pCProdPostingGr;
        if pResource."Global Dimension 1 Code" = '' THEN
            ERROR(glSinDimension
        + glEnelProyecto, pResource."No.", Empresa, gGenLedgerSetup."Global Dimension 1 Code", pCJob);
        pCDim1 := pResource."Global Dimension 1 Code";
        if pResource."Global Dimension 2 Code" = '' THEN
            ERROR(glSinDimension
        + glEnelProyecto, pResource."No.", Empresa, gGenLedgerSetup."Global Dimension 2 Code", pCJob);
        pCDim2 := pResource."Global Dimension 2 Code";
        if pResource."Global Dimension 3 Code" = '' THEN
            ERROR(glSinDimension
        + glEnelProyecto, pResource."No.", Empresa, gGenLedgerSetup."ShortCut Dimension 3 Code", pCJob);
        pCDim3 := pResource."Global Dimension 3 Code";
        if pResource."Global Dimension 4 Code" = '' THEN
            ERROR(glSinDimension
        + glEnelProyecto, pResource."No.", Empresa, gGenLedgerSetup."ShortCut Dimension 4 Code", pCJob);
        pCDim4 := pResource."Global Dimension 4 Code";
        if pResource."Global Dimension 5 Code" = '' THEN
            ERROR(glSinDimension
        + glEnelProyecto, pResource."No.", Empresa, gGenLedgerSetup."ShortCut Dimension 5 Code", pCJob);
        if pCDim5 = '' THEN
            pCDim5 := pResource."Global Dimension 5 Code";
        pCProdPostingGr := pResource."Gen. Prod. Posting Group";
        If Not lGenProdPosting.GET(pCProdPostingGr) Then
            pCProdPostingGr := lpCProdPostingGr;
        "pbRecAgrupado" := pbAgrupado;
        piDimensionSetID := lcControldeProcesos.GetDefaultDimID2(pResource."Global Dimension 1 Code", pResource."Global Dimension 2 Code",
        pResource."Global Dimension 3 Code", pResource."Global Dimension 4 Code", pResource."Global Dimension 5 Code");
    end;


    Procedure CompruebaDimensionEnBlanco(Var pCSctArray: Array[5] of Code[20]; piNo: Code[20]): Integer
    var
        lcControldeProcesos: Codeunit ControlProcesos;

    begin
        gGenLedgerSetup.Get();

        if pCSctArray[1] = '' THEN ERROR(glDimensionEnBlanco, gGenLedgerSetup."Global Dimension 1 Code", piNo);
        if pCSctArray[2] = '' THEN ERROR(glDimensionEnBlanco, gGenLedgerSetup."Global Dimension 2 Code", piNo);
        if pCSctArray[3] = '' THEN ERROR(glDimensionEnBlanco, gGenLedgerSetup."ShortCut Dimension 3 Code", piNo);
        if pCSctArray[4] = '' THEN ERROR(glDimensionEnBlanco, gGenLedgerSetup."ShortCut Dimension 4 Code", piNo);
        if pCSctArray[5] = '' THEN ERROR(glDimensionEnBlanco, gGenLedgerSetup."ShortCut Dimension 5 Code", piNo);

        exit(
        lcControldeProcesos.GetDefaultDimID2(
            pCSctArray[1], pCSctArray[2], pCSctArray[3], pCSctArray[4], pCSctArray[5]));
    end;

    Procedure Produccion(Var pSalesInvoiceLineTMp: Record "Sales Invoice Line" temporary;
    Var pSalesInvoiceLineTMP2: Record "Sales Invoice Line" temporary;
     var pResource: Record Resource; pCJobNo: Code[20]; var pbAgrupado: Boolean; pCCurrencyCode: Code[20])
    var
        lProduccionesRelacionadas: Record "Produccines Relacionadas";
        ltCompany: Text;
        lCJobNo: Text;
        lCJobNo2: Text;
        lJob: Record Job;
        lReserva: Record Reserva;
        lDefDim: Record "Default Dimension";
        ltCmp: Text;
        liLin: Integer;
        liNumeroProducciones: Integer;
        liNumeroLinea: Integer;
        liProducciones: Integer;
        liDiasReserva: Integer;
        lbCambia: Boolean;
        ldFI: Date;
        ldFF: Date;
        lcControldeProcesos: Codeunit ControlProcesos;
        rRel: Record "Relación Grupos";
        liNumeroLineaProd: Integer;
        lTotalDiasReservas: Integer;


    begin
        // Ahora busco si es de producción				
        if pSalesInvoiceLineTMP.FINDFIRST THEN
            REPEAT
                lProduccionesRelacionadas.RESET;
                ltCompany := '';
                lCJobNo := pSalesInvoiceLineTMP."Job No.";
                liLin := pSalesInvoiceLineTMP."No Linea proyecto";
                if pSalesInvoiceLineTMP."Empresa Origen" <> '' THEN BEGIN
                    lProduccionesRelacionadas.CHANGECOMPANY(pSalesInvoiceLineTMP."Empresa Origen");
                    pResource.CHANGECOMPANY(pSalesInvoiceLineTMP."Empresa Origen");
                    lCJobNo := pSalesInvoiceLineTMP."Proyecto Origen";
                    liLin := pSalesInvoiceLineTMP."No Linea proyecto";
                    ltCompany := pSalesInvoiceLineTMP."Empresa Origen";
                END ELSE BEGIN
                    lProduccionesRelacionadas.CHANGECOMPANY(COMPANYNAME);
                    pResource.CHANGECOMPANY(COMPANYNAME);
                    ltCompany := COMPANYNAME;
                    lCJobNo := pCJobNo;
                END;
                if lCJobNo = '' THEN
                    lProduccionesRelacionadas.SETRANGE(lProduccionesRelacionadas."Job No.", 'KKDLVC')
                ELSE
                    lProduccionesRelacionadas.SETRANGE(lProduccionesRelacionadas."Job No.", lCJobNo);
                lProduccionesRelacionadas.SETRANGE(lProduccionesRelacionadas."Line No.", liLin);
                liNumeroProducciones := lProduccionesRelacionadas.COUNT;
                liProducciones := liNumeroProducciones;
                if liNumeroProducciones = 0 THEN BEGIN
                    lProduccionesRelacionadas.SETRANGE(lProduccionesRelacionadas."Line No.");
                    lProduccionesRelacionadas.SETRANGE(lProduccionesRelacionadas."No.", pSalesInvoiceLineTMP."No.");
                END;
                liNumeroProducciones := lProduccionesRelacionadas.COUNT;
                liProducciones := liNumeroProducciones;
                lbCambia := TRUE;
                if (liNumeroProducciones = 0) AND (pResource.GET(pSalesInvoiceLineTMP."No.")) THEN begin
                    if pResource.Producción THEN BEGIN
                        lProduccionesRelacionadas.RESET;
                        lProduccionesRelacionadas.CHANGECOMPANY(COMPANYNAME);
                        if pCJobNo = '' THEN
                            lProduccionesRelacionadas.SETRANGE(lProduccionesRelacionadas."Job No.", 'KKDLVC')
                        ELSE
                            lProduccionesRelacionadas.SETRANGE(lProduccionesRelacionadas."Job No.", pCJobNo);
                        lProduccionesRelacionadas.SETRANGE("Line No.", pSalesInvoiceLineTMP."No linea proyecto");
                        liNumeroProducciones := lProduccionesRelacionadas.COUNT;
                        if NOT lProduccionesRelacionadas.FINDFIRST THEN BEGIN
                            lProduccionesRelacionadas.SETRANGE(lProduccionesRelacionadas."Line No.");
                            lProduccionesRelacionadas.SETRANGE(lProduccionesRelacionadas."No.", pSalesInvoiceLineTMP.Recurso);
                        END;
                        if lProduccionesRelacionadas.FINDFIRST THEN BEGIN
                            lCJobNo2 := lProduccionesRelacionadas."Job No.2";
                            lJob.RESET;
                            lJob.CHANGECOMPANY(pSalesInvoiceLineTMP."Empresa Origen");
                            if lProduccionesRelacionadas.Empresa <> '' THEN
                                lJob.SETRANGE(lJob."Empresa Origen", lProduccionesRelacionadas.Empresa)
                            ELSE
                                lJob.SETRANGE(lJob."Empresa Origen", COMPANYNAME);
                            lJob.SETRANGE("Proyecto en empresa Origen", lCJobNo2);
                            if lJob.FINDFIRST THEN lCJobNo2 := lJob."No.";
                            if NOT lJob.FINDFIRST THEN BEGIN
                                lJob.RESET;
                                lJob.CHANGECOMPANY(COMPANYNAME);
                                lJob.SETRANGE("No.", lCJobNo2);
                                // vuelvegDTotalliDiasReservas la empresa
                                lbCambia := FALSE;
                                if lJob.FINDFIRST THEN lCJobNo2 := lJob."No.";
                            END;
                        END;
                        liNumeroProducciones := lProduccionesRelacionadas.COUNT;
                        liProducciones := liNumeroProducciones;
                        if liNumeroProducciones = 0 THEN
                            ERROR(glErrorProduccion,
                            pSalesInvoiceLineTMP."No.", ltCompany, lCJobNo, lCJobNo2);
                    END;
                END;
                If not (pResource.Get(pSalesInvoiceLineTMP."No.")) then begin
                    pResource.ChangeCompany(CompanyName);
                    ltCompany := CompanyName;
                    If Not pResource.Get(pSalesInvoiceLineTMP."No.") Then pResource.init;
                end;
                liProducciones := 0;
                if (lProduccionesRelacionadas.FINDFIRST) And (pResource.Producción) THEN begin

                    REPEAT
                        lReserva.Reset();
                        if pSalesInvoiceLineTMP."Empresa Origen" <> '' THEN BEGIN
                            if lProduccionesRelacionadas.Empresa <> '' THEN
                                lReserva.CHANGECOMPANY(lProduccionesRelacionadas.Empresa)
                            ELSE
                                lReserva.CHANGECOMPANY(pSalesInvoiceLineTMP."Empresa Origen");


                            pResource.CHANGECOMPANY(pSalesInvoiceLineTMP."Empresa Origen");
                            ltCompany := pSalesInvoiceLineTMP."Empresa Origen";
                            lCJobNo := pSalesInvoiceLineTMP."Proyecto Origen";
                            ltCmp := pSalesInvoiceLineTMP."Empresa Origen";
                        END ELSE BEGIN
                            if lProduccionesRelacionadas.Empresa <> '' THEN
                                lReserva.CHANGECOMPANY(lProduccionesRelacionadas.Empresa)
                            ELSE
                                lReserva.CHANGECOMPANY(COMPANYNAME);
                            lCJobNo := lProduccionesRelacionadas."Job No.2";
                            if lProduccionesRelacionadas.Empresa <> '' THEN
                                pResource.CHANGECOMPANY(lProduccionesRelacionadas.Empresa)
                            ELSE
                                pResource.CHANGECOMPANY(COMPANYNAME);
                            ltCmp := COMPANYNAME;
                        END;
                        if NOT pResource.GET(lProduccionesRelacionadas."No.2") THEN begin
                            pResource.CHANGECOMPANY(COMPANYNAME);
                            gRecursoAgrupado := pResource."Recurso Agrupado";
                            ltCompany := CompanyName;
                        end;
                        if pResource.GET(lProduccionesRelacionadas."No.2") THEN BEGIN
                            gRecursoAgrupado := pResource."Recurso Agrupado";
                            if (pResource."Empresa Origen" <> COMPANYNAME) AND (pResource."Empresa Origen" <> '') THEN BEGIN
                                lProduccionesRelacionadas."No.2" := pResource."Nº En Empresa origen";
                                lReserva.CHANGECOMPANY(pResource."Empresa Origen");
                                lJob.CHANGECOMPANY(pResource."Empresa Origen");
                                if lProduccionesRelacionadas.Empresa <> '' THEN
                                    lJob.SETRANGE(lJob."Empresa Origen", lProduccionesRelacionadas.Empresa)
                                ELSE
                                    lJob.SETRANGE(lJob."Empresa Origen", COMPANYNAME);
                                lJob.SETRANGE("Proyecto en empresa Origen", lProduccionesRelacionadas."Job No.2");
                                lJob.FINDFIRST;
                                lCJobNo := lJob."No.";
                                pResource.CHANGECOMPANY(pResource."Empresa Origen");
                                ltCompany := pResource."Empresa Origen";
                                ltCmp := pResource."Empresa Origen";
                            END;
                        END;
                        lReserva.SETCURRENTKEY(lReserva."Nº Proyecto", lReserva."Recurso Agrupado");
                        If gRecursoAgrupado then begin
                            lReserva.SETRANGE(lReserva."Recurso Agrupado", lProduccionesRelacionadas."No.2");
                            lReserva.SETRANGE(lReserva."Linea Agrupado", lProduccionesRelacionadas."Line No.2");
                        end;
                        IF NOT lReserva.FINDFIRST THEN lReserva.SETRANGE(lReserva."Linea Agrupado");
                        if lCJobNo = '' THEN
                            lReserva.SETRANGE(lReserva."Nº Proyecto", 'KKDLVC')
                        ELSE
                            lReserva.SETRANGE(lReserva."Nº Proyecto", lCJobNo);
                        if lProduccionesRelacionadas."Job No.2" <> '' THEN
                            lReserva.SETRANGE(lReserva."Nº Proyecto", lProduccionesRelacionadas."Job No.2");
                        pSalesInvoiceLineTMP.TestField("Fecha Final recurso");
                        // lReserva.SETFILTER(lReserva."Fecha inicio", '<=%1', pSalesInvoiceLineTMP."Fecha Final recurso");
                        // lReserva.SETFILTER(lReserva."Fecha Fin", '>=%1', pSalesInvoiceLineTMP."Fecha inicial recurso");
                        //c := 0;

                        // si es agrupado busco el número de dias
                        // if NOT lReserva.FINDFIRST THEN BEGIN
                        //     lReserva.SETRANGE(lReserva."Fecha inicio");
                        //     lReserva.SETRANGE(lReserva."Fecha Fin");
                        //     if lReserva.FINDFIRST THEN
                        //         ERROR(SinReserva, lCJobNo,
                        //         pSalesInvoiceLineTMP."Fecha inicial recurso", pSalesInvoiceLineTMP."Fecha Final recurso", lProduccionesRelacionadas."No.2");
                        // end;
                        liProducciones += 1;
                        if not lReserva.FINDFIRST then
                            lReserva.SETRANGE(lReserva."Linea Agrupado");
                        if lReserva.FINDFIRST THEN BEGIN
                            //gDTotalliDiasReservas := 0;
                            REPEAT
                                pbAgrupado := TRUE;
                                ldFI := lReserva."Fecha inicio";
                                ldFF := lReserva."Fecha Fin";
                                // if ldFI <= pSalesInvoiceLineTMP."Fecha inicial recurso" THEN
                                //     ldFI := pSalesInvoiceLineTMP."Fecha inicial recurso";
                                // ldFF := lReserva."Fecha Fin";
                                // if ldFF >= pSalesInvoiceLineTMP."Fecha Final recurso" THEN
                                //     ldFF := pSalesInvoiceLineTMP."Fecha Final recurso";
                                liDiasReserva := ldFF - ldFI;
                                if liDiasReserva <= 0 THEN liDiasReserva := 1;
                                lTotalDiasReservas += liDiasReserva;
                                gDTotalliDiasReservas[liProducciones] := gDTotalliDiasReservas[liProducciones] + liDiasReserva;
                            UNTIL lReserva.NEXT = 0;
                        END;
                        if (lTotalDiasReservas = 0) and (gRecursoAgrupado) Then
                            Error(SinReservaNingunPeriodo, lCJobNo, lReserva.GetFilters);
                    //pSalesInvoiceLineTMP."Fecha inicial recurso", pSalesInvoiceLineTMP."Fecha Final recurso", lProduccionesRelacionadas."No.2");

                    UNTIL lProduccionesRelacionadas.NEXT = 0;
                    if gDTotalliDiasReservas[1] = 0 Then gDTotalliDiasReservas[1] := 1;
                    liNumeroLineaProd := 0;
                    if (lProduccionesRelacionadas.FINDFIRST) THEN
                        REPEAT
                            liNumeroLineaProd += 1;
                            // miro si el recurso destino es agrupado
                            if pSalesInvoiceLineTMP."Empresa Origen" <> '' THEN BEGIN
                                lReserva.CHANGECOMPANY(pSalesInvoiceLineTMP."Empresa Origen");
                                pResource.CHANGECOMPANY(pSalesInvoiceLineTMP."Empresa Origen");
                                ltCompany := pSalesInvoiceLineTMP."Empresa Origen";
                                lDefDim.ChangeCompany(pSalesInvoiceLineTMP."Empresa Origen");
                                lCJobNo := pSalesInvoiceLineTMP."Proyecto Origen";
                                ltCmp := pSalesInvoiceLineTMP."Empresa Origen";
                            END ELSE BEGIN
                                if lProduccionesRelacionadas.Empresa <> '' THEN
                                    lReserva.CHANGECOMPANY(lProduccionesRelacionadas.Empresa)
                                ELSE
                                    lReserva.CHANGECOMPANY(COMPANYNAME);
                                if lProduccionesRelacionadas.Empresa <> '' THEN
                                    lDefDim.CHANGECOMPANY(lProduccionesRelacionadas.Empresa)
                                ELSE
                                    lDefDim.ChangeCompany(CompanyName);
                                lCJobNo := lProduccionesRelacionadas."Job No.2";
                                if lProduccionesRelacionadas.Empresa <> '' THEN
                                    pResource.CHANGECOMPANY(lProduccionesRelacionadas.Empresa)
                                ELSE
                                    pResource.CHANGECOMPANY(COMPANYNAME);
                                ltCmp := COMPANYNAME;
                                ltCompany := COMPANYNAME;
                            END;
                            if NOT pResource.GET(lProduccionesRelacionadas."No.2") THEN begin
                                pResource.CHANGECOMPANY(COMPANYNAME);
                                lDefDim.ChangeCompany(CompanyName);
                                ltCompany := CompanyName;
                            end;
                            if pResource.GET(lProduccionesRelacionadas."No.2") THEN BEGIN
                                if (pResource."Empresa Origen" <> COMPANYNAME) AND (pResource."Empresa Origen" <> '') THEN BEGIN
                                    lProduccionesRelacionadas."No.2" := pResource."Nº En Empresa origen";
                                    lReserva.CHANGECOMPANY(pResource."Empresa Origen");
                                    lJob.CHANGECOMPANY(pResource."Empresa Origen");
                                    lJob.SETRANGE(lJob."Empresa Origen", COMPANYNAME);
                                    lJob.SETRANGE("Proyecto en empresa Origen", lProduccionesRelacionadas."Job No.2");
                                    lJob.FINDFIRST;
                                    lCJobNo := lJob."No.";
                                    pResource.CHANGECOMPANY(pResource."Empresa Origen");
                                    lDefDim.ChangeCompany(pResource."Empresa Origen");
                                    ltCmp := pResource."Empresa Origen";
                                    ltCompany := pResource."Empresa Origen";
                                END;
                            END;



                            // pSalesInvoiceLineTMP.TestField("Fecha Final recurso");
                            // lReserva.SETFILTER(lReserva."Fecha inicio", '<=%1', pSalesInvoiceLineTMP."Fecha Final recurso");
                            // lReserva.SETFILTER(lReserva."Fecha Fin", '>=%1', pSalesInvoiceLineTMP."Fecha inicial recurso");

                            //if c = 0 THEN c := 1;
                            liNumeroLinea := pSalesInvoiceLineTMP."Line No.";
                            if gRecursoAgrupado then
                                lReserva.SETRANGE(lReserva."Linea Agrupado", lProduccionesRelacionadas."Line No.2");
                            IF NOT lReserva.FINDFIRST THEN lReserva.SETRANGE(lReserva."Linea Agrupado");

                            if (lReserva.FINDFIRST) and (gRecursoAgrupado) THEN BEGIN
                                pbAgrupado := TRUE;
                                REPEAT
                                    ldFI := lReserva."Fecha inicio";
                                    ldFF := lReserva."Fecha Fin";
                                    // if ldFI <= pSalesInvoiceLineTMP."Fecha inicial recurso" THEN
                                    //     ldFI := pSalesInvoiceLineTMP."Fecha inicial recurso";
                                    // ldFF := lReserva."Fecha Fin";
                                    // if ldFF >= pSalesInvoiceLineTMP."Fecha Final recurso" THEN
                                    //     ldFF := pSalesInvoiceLineTMP."Fecha Final recurso";
                                    liDiasReserva := ldFF - ldFI;
                                    if liDiasReserva <= 0 THEN liDiasReserva := 1;
                                    liNumeroLinea += 1;

                                    if liProducciones = 0 Then liProducciones := 1;
                                    if gDTotalliDiasReservas[liNumeroLineaProd] = 0 Then gDTotalliDiasReservas[liNumeroLineaProd] := 1;
                                    // if liProducciones <> 1 then error('No se pueden mezclar recursos agrupados con no agrupados al asignar una producción');

                                    pSalesInvoiceLineTMP2 := pSalesInvoiceLineTMP;
                                    pSalesInvoiceLineTMP2."Recurso Agrupado" := pbAgrupado;
                                    pSalesInvoiceLineTMP2."Line No." := pSalesInvoiceLineTMP."Line No." + liNumeroLinea;
                                    pSalesInvoiceLineTMP2."No." := lReserva."Nº Recurso";//antes 
                                    pSalesInvoiceLineTMP2.Quantity := pSalesInvoiceLineTMP.Quantity;
                                    pSalesInvoiceLineTMP2."Unit Price" := Redondear(pSalesInvoiceLineTMP."Unit Price" / liProducciones / gDTotalliDiasReservas[liNumeroLineaProd] * liDiasReserva, TRUE, pCCUrrencyCode);
                                    pSalesInvoiceLineTMP2."Unit Cost" := pSalesInvoiceLineTMP."Unit Cost";
                                    pSalesInvoiceLineTMP2."Unit Cost (LCY)" := Redondear(pSalesInvoiceLineTMP."Unit Cost (LCY)" / liProducciones / gDTotalliDiasReservas[liNumeroLineaProd] * liDiasReserva, TRUE, pCCUrrencyCode);
                                    pSalesInvoiceLineTMP2."Line Discount Amount" := Redondear(pSalesInvoiceLineTMP."Line Discount Amount" / liProducciones / gDTotalliDiasReservas[liNumeroLineaProd] * liDiasReserva, FALSE, pCCUrrencyCode);
                                    pSalesInvoiceLineTMP2."Pmt. Discount Amount" := Redondear(pSalesInvoiceLineTMP."Pmt. Discount Amount" / liProducciones / gDTotalliDiasReservas[liNumeroLineaProd] * liDiasReserva, FALSE, pCCUrrencyCode);
                                    pSalesInvoiceLineTMP2.Amount := Redondear(pSalesInvoiceLineTMP.Amount / liProducciones / gDTotalliDiasReservas[liNumeroLineaProd] * liDiasReserva, FALSE, pCCUrrencyCode);
                                    pSalesInvoiceLineTMP2."Amount Including VAT" := Redondear(pSalesInvoiceLineTMP."Amount Including VAT" / liProducciones / gDTotalliDiasReservas[liNumeroLineaProd] * liDiasReserva, FALSE, pCCUrrencyCode);
                                    pSalesInvoiceLineTMP2."Line Amount" := Redondear(pSalesInvoiceLineTMP."Line Amount" / liProducciones / gDTotalliDiasReservas[liNumeroLineaProd] * liDiasReserva, FALSE, pCCUrrencyCode);
                                    if Not pResource.GET(lReserva."Nº Recurso") then pResource.Init();
                                    if pResource."Nº En Empresa origen" <> '' then begin
                                        pResource.Reset();
                                        pResource.ChangeCompany(pResource."Empresa Origen");
                                        ltCompany := pResource."Empresa Origen";
                                        lDefDim.ChangeCompany(pResource."Empresa Origen");
                                        if not pResource.Get(pResource."Nº En Empresa origen") Then pResource.Init();
                                    end;
                                    lDefDim.SetRange("Table ID", Database::Resource);
                                    lDefDim.SetRange("No.", pResource."No.");
                                    gGenLedgerSetup.Get();
                                    if lDefDim.FINDFIRST() then
                                        repeat
                                            if lDefDim."Dimension Code" = gGenLedgerSetup."Global Dimension 1 Code" then
                                                if lDefDim."Dimension Value Code" <> '' Then
                                                    pResource."Global Dimension 1 Code" := lDefDim."Dimension Value Code";
                                            if lDefDim."Dimension Code" = gGenLedgerSetup."Global Dimension 2 Code" then
                                                if lDefDim."Dimension Value Code" <> '' Then
                                                    pResource."Global Dimension 2 Code" := lDefDim."Dimension Value Code";
                                            if lDefDim."Dimension Code" = gGenLedgerSetup."Shortcut Dimension 3 Code" then
                                                if lDefDim."Dimension Value Code" <> '' Then
                                                    pResource."Global Dimension 3 Code" := lDefDim."Dimension Value Code";
                                            if lDefDim."Dimension Code" = gGenLedgerSetup."Shortcut Dimension 4 Code" then
                                                if lDefDim."Dimension Value Code" <> '' Then
                                                    pResource."Global Dimension 4 Code" := lDefDim."Dimension Value Code";
                                            if lDefDim."Dimension Code" = gGenLedgerSetup."Shortcut Dimension 5 Code" then
                                                if lDefDim."Dimension Value Code" <> '' Then
                                                    pResource."Global Dimension 5 Code" := lDefDim."Dimension Value Code";
                                        until lDefDim.Next() = 0;
                                    pSalesInvoiceLineTMP2."Empresa Origen" := ltCmp;
                                    Compruebadimensiones(pResource, ltCmp,
                                    pSalesInvoiceLineTMP2."ShortCut dimension 1 Code",
                                    pSalesInvoiceLineTMP2."ShortCut dimension 2 Code",
                                    pSalesInvoiceLineTMP2."ShortCut dimension 3 Code",
                                    pSalesInvoiceLineTMP2."ShortCut dimension 4 Code",
                                    pSalesInvoiceLineTMP2."ShortCut dimension 5 Code",
                                    pSalesInvoiceLineTMP2."Dimension Set ID",
                                    pSalesInvoiceLineTMP2."Gen. Prod. Posting Group",
                                    lReserva."Nº Proyecto", pSalesInvoiceLineTMP2."Recurso Agrupado", pbAgrupado);
                                    if NOT pSalesInvoiceLineTMP2.INSERT THEN
                                        REPEAT
                                            liNumeroLinea := liNumeroLinea + 1;
                                            pSalesInvoiceLineTMP2."Line No." := pSalesInvoiceLineTMP."Line No." + liNumeroLinea;
                                        UNTIL pSalesInvoiceLineTMP2.INSERT;
                                UNTIL lReserva.NEXT = 0;
                            END ELSE BEGIN
                                liNumeroLinea := 1;
                                if liProducciones = 0 THEN liProducciones := 1;
                                // si no es agrupado
                                pSalesInvoiceLineTMP2 := pSalesInvoiceLineTMP;
                                pSalesInvoiceLineTMP2."Line No." := pSalesInvoiceLineTMP."Line No." + liNumeroLinea;
                                pSalesInvoiceLineTMP2.Quantity := pSalesInvoiceLineTMP.Quantity;
                                pSalesInvoiceLineTMP2."Unit Cost" := pSalesInvoiceLineTMp."Unit Cost";
                                pSalesInvoiceLineTMP2."Unit Price" := Redondear(pSalesInvoiceLineTMP."Unit Price" / liProducciones, TRUE, pCCUrrencyCode);
                                pSalesInvoiceLineTMP2."Unit Cost (LCY)" := Redondear(pSalesInvoiceLineTMP."Unit Cost (LCY)" / liProducciones, TRUE, pCCUrrencyCode);
                                pSalesInvoiceLineTMP2."Line Discount Amount" := Redondear(pSalesInvoiceLineTMP."Line Discount Amount" / liProducciones, FALSE, pCCUrrencyCode);
                                pSalesInvoiceLineTMP2."Pmt. Discount Amount" := Redondear(pSalesInvoiceLineTMP."Pmt. Discount Amount" / liProducciones, FALSE, pCCUrrencyCode);
                                pSalesInvoiceLineTMP2.Amount := Redondear(pSalesInvoiceLineTMP.Amount / liProducciones, FALSE, pCCUrrencyCode);
                                pSalesInvoiceLineTMP2."Amount Including VAT" := Redondear(pSalesInvoiceLineTMP."Amount Including VAT" / liProducciones, FALSE, pCCUrrencyCode);
                                pSalesInvoiceLineTMP2."Line Amount" := Redondear(pSalesInvoiceLineTMP."Line Amount" / liProducciones, FALSE, pCCUrrencyCode);
                                if lProduccionesRelacionadas.Empresa <> '' then begin
                                    pResource.ChangeCompany(lProduccionesRelacionadas.Empresa);
                                    ltCompany := lProduccionesRelacionadas.Empresa;
                                end;

                                if not pResource.GET(lProduccionesRelacionadas."No.2") Then pResource.init;
                                if pResource."Nº En Empresa origen" <> '' Then
                                    if Not pResource.Get(pResource."Nº En Empresa origen") Then begin
                                        if lProduccionesRelacionadas.Empresa <> '' then begin
                                            pResource.ChangeCompany(lProduccionesRelacionadas.Empresa);
                                            ltCompany := lProduccionesRelacionadas.Empresa;
                                        end;
                                        if not pResource.Get(lProduccionesRelacionadas."No.2") then pResource.Init();

                                    end;
                                if pResource."Nº En Empresa origen" <> '' then begin
                                    pResource.Reset();
                                    pResource.ChangeCompany(pResource."Empresa Origen");
                                    ltCompany := pResource."Empresa Origen";
                                    lDefDim.ChangeCompany(pResource."Empresa Origen");
                                    if not pResource.Get(pResource."Nº En Empresa origen") Then pResource.Init();
                                end;
                                gGenLedgerSetup.Get();
                                lDefDim.SetRange("No.", pResource."No.");
                                if lDefDim.FINDFIRST() then
                                    repeat
                                        if lDefDim."Dimension Code" = gGenLedgerSetup."Global Dimension 1 Code" then
                                            pResource."Global Dimension 1 Code" := lDefDim."Dimension Value Code";
                                        if lDefDim."Dimension Code" = gGenLedgerSetup."Global Dimension 2 Code" then
                                            pResource."Global Dimension 2 Code" := lDefDim."Dimension Value Code";
                                        if lDefDim."Dimension Code" = gGenLedgerSetup."Shortcut Dimension 3 Code" then
                                            pResource."Global Dimension 3 Code" := lDefDim."Dimension Value Code";
                                        if lDefDim."Dimension Code" = gGenLedgerSetup."Shortcut Dimension 4 Code" then
                                            pResource."Global Dimension 4 Code" := lDefDim."Dimension Value Code";
                                        if lDefDim."Dimension Code" = gGenLedgerSetup."Shortcut Dimension 5 Code" then
                                            pResource."Global Dimension 5 Code" := lDefDim."Dimension Value Code";
                                    until lDefDim.Next() = 0;

                                pSalesInvoiceLineTMP2."Empresa Origen" := ltCmp;

                                Compruebadimensiones(pResource, ltCmp,
                                   pSalesInvoiceLineTMP2."ShortCut dimension 1 Code",
                                   pSalesInvoiceLineTMP2."ShortCut dimension 2 Code",
                                   pSalesInvoiceLineTMP2."ShortCut dimension 3 Code",
                                   pSalesInvoiceLineTMP2."ShortCut dimension 4 Code",
                                   pSalesInvoiceLineTMP2."ShortCut dimension 5 Code",
                                   pSalesInvoiceLineTMP2."Dimension Set ID",
                                   pSalesInvoiceLineTMP2."Gen. Prod. Posting Group",
                                   lReserva."Nº Proyecto", pSalesInvoiceLineTMP2."Recurso Agrupado", pbAgrupado);
                                if NOT pSalesInvoiceLineTMP2.INSERT THEN
                                    REPEAT
                                        liNumeroLinea := liNumeroLinea + 1;
                                        pSalesInvoiceLineTMP2."Empresa Origen" := ltCmp;
                                        pSalesInvoiceLineTMP2."Line No." := pSalesInvoiceLineTMP."Line No." + liNumeroLinea;
                                    UNTIL pSalesInvoiceLineTMP2.INSERT;
                            END;
                        UNTIL lProduccionesRelacionadas.NEXT = 0;
                END ELSE BEGIN
                    pSalesInvoiceLineTMP2 := pSalesInvoiceLineTMP;
                    if NOT pResource.GET(pSalesInvoiceLineTMP."No.") THEN BEGIN
                        pResource.RESET;
                        pResource.CHANGECOMPANY(COMPANYNAME);
                        ltCompany := CompanyName;
                    end;
                    If pResource.GET(pSalesInvoiceLineTMP."No.") THEN BEGIN
                        pSalesInvoiceLineTMP2."Shortcut Dimension 1 Code" := pResource."Global Dimension 1 Code";
                        pSalesInvoiceLineTMP2."Shortcut Dimension 2 Code" := pResource."Global Dimension 2 Code";
                        pSalesInvoiceLineTMP2."Shortcut Dimension 3 Code" := pResource."Global Dimension 3 Code";
                        pSalesInvoiceLineTMP2."Shortcut Dimension 4 Code" := pResource."Global Dimension 4 Code";
                        pSalesInvoiceLineTMP2."Shortcut Dimension 5 Code" := pResource."Global Dimension 5 Code";
                        If ltCompany <> CompanyName THEN BEGIN
                            rRel.SETRANGE(rRel."Empresa Origen", ltCompany);
                            rRel.SETRANGE(rRel."Grupo Contable Origen", pResource."Gen. Prod. Posting Group");
                            rRel.SETRANGE(rRel."Empresa Destino", COMPANYNAME);
                            if rRel.FINDFIRST THEN
                                pResource."Gen. Prod. Posting Group" := rRel."Grupo Contable Destino"
                        END;
                        if pResource."Gen. Prod. Posting Group" <> '' Then
                            pSalesInvoiceLineTMP2."Gen. Prod. Posting Group" := pResource."Gen. Prod. Posting Group";
                        pSalesInvoiceLineTMP2."Dimension Set ID" := lcControldeProcesos.GetDefaultDimID2(pResource."Global Dimension 1 Code", pResource."Global Dimension 2 Code",
                          pResource."Global Dimension 3 Code", pResource."Global Dimension 4 Code", pResource."Global Dimension 5 Code");
                    end;
                    if NOT pSalesInvoiceLineTMP2.INSERT THEN
                        REPEAT
                            liNumeroLinea := liNumeroLinea + 1;
                            pSalesInvoiceLineTMP2."Line No." := pSalesInvoiceLineTMP."Line No." + liNumeroLinea;
                        UNTIL pSalesInvoiceLineTMP2.INSERT;
                END;


            UNTIL pSalesInvoiceLineTMP.NEXT = 0;


    end;

    Procedure Produccion(Var pPurchInvLineTMP: Record "Purch. Inv. Line" temporary;
    Var pPurchInvLineTMP2: Record "Purch. Inv. Line" temporary;
     var pResource: Record Resource; pCJobNo: Code[20]; var pbAgrupado: Boolean; pCCUrrencyCode: Code[20])
    var
        lSalesInvoiceLineTMP: Record "Sales Invoice Line" temporary;
        lSalesInvoiceLineTMP2: Record "Sales Invoice Line" temporary;

    begin

        // Ahora busco si es de producción				
        if pPurchInvLineTMP.FINDFIRST THEN
            REPEAT
                //pPurchInvLineTMP.TransferFields(lSalesInvoiceLineTMP);
                lSalesInvoiceLineTMP."Document No." := pPurchInvLineTMP."Document No.";
                lSalesInvoiceLineTMP."Line No." := pPurchInvLineTMP."Line No.";
                lSalesInvoiceLineTMP."Bill-to Customer No." := pPurchInvLineTMP."Pay-to Vendor No.";
                lSalesInvoiceLineTMP."Sell-to Customer No." := pPurchInvLineTMP."Buy-from Vendor No.";
                lSalesInvoiceLineTMP."No." := pPurchInvLineTMP."No.";
                lSalesInvoiceLineTMP."Type" := pPurchInvLineTMP."Type";
                lSalesInvoiceLineTMP."Order No." := pPurchInvLineTMP."Order No.";
                lSalesInvoiceLineTMP."Order Line No." := pPurchInvLineTMP."Order Line No.";
                lSalesInvoiceLineTMP."Shipment No." := pPurchInvLineTMP."Receipt No.";
                lSalesInvoiceLineTMP."Shipment Line No." := pPurchInvLineTMP."Receipt Line No.";
                lSalesInvoiceLineTMP."No Linea proyecto" := pPurchInvLineTMP."Linea de proyecto";
                lSalesInvoiceLineTMP."Job No." := pPurchInvLineTMP."Job No.";
                lSalesInvoiceLineTMP.Description := pPurchInvLineTMP.Description;
                lSalesInvoiceLineTMP."Description 2" := pPurchInvLineTMP."Description 2";
                lSalesInvoiceLineTMP."Job Task No." := pPurchInvLineTMP."Job Task No.";
                lSalesInvoiceLineTMP."Proyecto Origen" := pPurchInvLineTMP."Proyecto Origen";
                lSalesInvoiceLineTMP."Empresa Origen" := pPurchInvLineTMP."Empresa Origen";
                lSalesInvoiceLineTMP."Recurso Agrupado" := pPurchInvLineTMP."Recurso Agrupado";
                lSalesInvoiceLineTMP."Fecha inicial recurso" := pPurchInvLineTMP."Fecha inicial recurso";
                lSalesInvoiceLineTMP."Fecha Final recurso" := pPurchInvLineTMP."Fecha Final recurso";
                lSalesInvoiceLineTMP."Quantity" := pPurchInvLineTMP."Quantity";
                lSalesInvoiceLineTMP."Quantity (Base)" := pPurchInvLineTMP."Quantity (Base)";
                lSalesInvoiceLineTMP."Unit of Measure Code" := pPurchInvLineTMP."Unit of Measure Code";
                lSalesInvoiceLineTMP."Unit Price" := pPurchInvLineTMP."Direct Unit Cost";
                lSalesInvoiceLineTMP."Unit Cost (LCY)" := pPurchInvLineTMP."Unit Cost (LCY)";
                lSalesInvoiceLineTMP."Line Discount Amount" := pPurchInvLineTMP."Line Discount Amount";
                lSalesInvoiceLineTMP."VAT Prod. Posting Group" := pPurchInvLineTMP."VAT Prod. Posting Group";
                lSalesInvoiceLineTMP."VAT Bus. Posting Group" := pPurchInvLineTMP."VAT Bus. Posting Group";
                lSalesInvoiceLineTMP."Gen. Bus. Posting Group" := pPurchInvLineTMP."Gen. Bus. Posting Group";
                if pPurchInvLineTMP."Gen. Prod. Posting Group" <> '' Then
                    lSalesInvoiceLineTMP."Gen. Prod. Posting Group" := pPurchInvLineTMP."Gen. Prod. Posting Group";
                //lSalesInvoiceLineTMP."Pmt. Discount Amount":=pPurchInvLineTMP."Pmt. Discount Amount";
                lSalesInvoiceLineTMP."Amount" := pPurchInvLineTMP."Amount";
                lSalesInvoiceLineTMP."Amount Including VAT" := pPurchInvLineTMP."Amount Including VAT";
                lSalesInvoiceLineTMP."Line Amount" := pPurchInvLineTMP."Line Amount";
                lSalesInvoiceLineTMP."Line discount %" := pPurchInvLineTMP."Line discount %";
                lSalesInvoiceLineTMP."Order No." := pPurchInvLineTMP."Order No.";
                lSalesInvoiceLineTMP."Order Line No." := pPurchInvLineTMP."Order Line No.";
                lSalesInvoiceLineTMP."Shortcut Dimension 1 Code" := pPurchInvLineTMP."Shortcut Dimension 1 Code";
                lSalesInvoiceLineTMP."Shortcut Dimension 2 Code" := pPurchInvLineTMP."Shortcut Dimension 2 Code";
                lSalesInvoiceLineTMP."Shortcut Dimension 3 Code" := pPurchInvLineTMP."Shortcut Dimension 3 Code";
                lSalesInvoiceLineTMP."Shortcut Dimension 4 Code" := pPurchInvLineTMP."Shortcut Dimension 4 Code";
                lSalesInvoiceLineTMP."Shortcut Dimension 5 Code" := pPurchInvLineTMP."Shortcut Dimension 5 Code";
                lSalesInvoiceLineTMP.Recurso := pPurchInvLineTMP."Recurso";
                lSalesInvoiceLineTMP."Unit Price" := pPurchInvLineTMP."Direct Unit Cost";
                If lSalesInvoiceLineTMP.Insert Then;
            Until pPurchInvLineTMP.NEXT = 0;
        if pPurchInvLineTMP2.FINDFIRST THEN
            REPEAT
                lSalesInvoiceLineTMP2."Document No." := pPurchInvLineTMP2."Document No.";
                lSalesInvoiceLineTMP2."Line No." := pPurchInvLineTMP2."Line No.";
                lSalesInvoiceLineTMP2."Bill-to Customer No." := pPurchInvLineTMP2."Pay-to Vendor No.";
                lSalesInvoiceLineTMP2."Sell-to Customer No." := pPurchInvLineTMP2."Buy-from Vendor No.";
                lSalesInvoiceLineTMP2."No." := pPurchInvLineTMP2."No.";
                lSalesInvoiceLineTMP2."Type" := pPurchInvLineTMP2."Type";
                lSalesInvoiceLineTMP2.Description := pPurchInvLineTMP2.Description;
                lSalesInvoiceLineTMP2."Description 2" := pPurchInvLineTMP2."Description 2";
                lSalesInvoiceLineTMP2."No Linea proyecto" := pPurchInvLineTMP2."Linea de proyecto";
                lSalesInvoiceLineTMP2."Job No." := pPurchInvLineTMP2."Job No.";
                lSalesInvoiceLineTMP2."Job Task No." := pPurchInvLineTMP2."Job Task No.";
                lSalesInvoiceLineTMP2."Proyecto Origen" := pPurchInvLineTMP2."Proyecto Origen";
                lSalesInvoiceLineTMP2."Empresa Origen" := pPurchInvLineTMP2."Empresa Origen";
                lSalesInvoiceLineTMP2."Recurso Agrupado" := pPurchInvLineTMP2."Recurso Agrupado";
                lSalesInvoiceLineTMP2."Fecha inicial recurso" := pPurchInvLineTMP2."Fecha inicial recurso";
                lSalesInvoiceLineTMP2."Fecha Final recurso" := pPurchInvLineTMP2."Fecha Final recurso";
                lSalesInvoiceLineTMP2."Quantity" := pPurchInvLineTMP2."Quantity";
                lSalesInvoiceLineTMP2."Order No." := pPurchInvLineTMP2."Order No.";
                lSalesInvoiceLineTMP2."Order Line No." := pPurchInvLineTMP2."Order Line No.";
                lSalesInvoiceLineTMP2."Shipment No." := pPurchInvLineTMP2."Receipt No.";
                lSalesInvoiceLineTMP2."Shipment Line No." := pPurchInvLineTMP2."Receipt Line No.";
                lSalesInvoiceLineTMP2."Quantity (Base)" := pPurchInvLineTMP2."Quantity (Base)";
                lSalesInvoiceLineTMP2."Unit of Measure Code" := pPurchInvLineTMP2."Unit of Measure Code";
                lSalesInvoiceLineTMP2."Unit Price" := pPurchInvLineTMP2."Direct Unit Cost";
                lSalesInvoiceLineTMP2."Unit Cost (LCY)" := pPurchInvLineTMP2."Unit Cost (LCY)";
                lSalesInvoiceLineTMP2."Line Discount Amount" := pPurchInvLineTMP2."Line Discount Amount";
                lSalesInvoiceLineTMP2."VAT Prod. Posting Group" := pPurchInvLineTMP2."VAT Prod. Posting Group";
                lSalesInvoiceLineTMP2."VAT Bus. Posting Group" := pPurchInvLineTMP2."VAT Bus. Posting Group";
                lSalesInvoiceLineTMP2."Gen. Bus. Posting Group" := pPurchInvLineTMP2."Gen. Bus. Posting Group";
                if pPurchInvLineTMP2."Gen. Prod. Posting Group" <> '' Then
                    lSalesInvoiceLineTMP2."Gen. Prod. Posting Group" := pPurchInvLineTMP2."Gen. Prod. Posting Group";
                //lSalesInvoiceLineTMP2."Pmt. Discount Amount":=pPurchInvLineTMP2."Pmt. Discount Amount";
                lSalesInvoiceLineTMP2."Amount" := pPurchInvLineTMP2."Amount";
                lSalesInvoiceLineTMP2."Amount Including VAT" := pPurchInvLineTMP2."Amount Including VAT";
                lSalesInvoiceLineTMP2."Line Amount" := pPurchInvLineTMP2."Line Amount";
                lSalesInvoiceLineTMP2."Line discount %" := pPurchInvLineTMP2."Line discount %";
                lSalesInvoiceLineTMP2."Order No." := pPurchInvLineTMP2."Order No.";
                lSalesInvoiceLineTMP2."Order Line No." := pPurchInvLineTMP2."Order Line No.";
                lSalesInvoiceLineTMP2."Shortcut Dimension 1 Code" := pPurchInvLineTMP2."Shortcut Dimension 1 Code";
                lSalesInvoiceLineTMP2."Shortcut Dimension 2 Code" := pPurchInvLineTMP2."Shortcut Dimension 2 Code";
                lSalesInvoiceLineTMP2."Shortcut Dimension 3 Code" := pPurchInvLineTMP2."Shortcut Dimension 3 Code";
                lSalesInvoiceLineTMP2."Shortcut Dimension 4 Code" := pPurchInvLineTMP2."Shortcut Dimension 4 Code";
                lSalesInvoiceLineTMP2."Shortcut Dimension 5 Code" := pPurchInvLineTMP2."Shortcut Dimension 5 Code";
                lSalesInvoiceLineTMP2.Recurso := pPurchInvLineTMP2."Recurso";
                lSalesInvoiceLineTMP2."Unit Price" := pPurchInvLineTMP2."Direct Unit Cost";
                If lSalesInvoiceLineTMP2.Insert Then;
            Until pPurchInvLineTMP2.NEXT = 0;
        pPurchInvLineTMP.deleteAll;
        pPurchInvLineTMP2.deleteall;
        Produccion(lSalesInvoiceLineTMP, lSalesInvoiceLineTMP2, pResource, pCJobNo, pbAgrupado, pCCUrrencyCode);
        if lSalesInvoiceLineTMP.FINDFIRST THEN
            REPEAT
                pPurchInvLineTMP."Document No." := lSalesInvoiceLineTMP."Document No.";
                pPurchInvLineTMP."Line No." := lSalesInvoiceLineTMP."Line No.";
                pPurchInvLineTMP."No." := lSalesInvoiceLineTMP."No.";
                pPurchInvLineTMP."Type" := lSalesInvoiceLineTMP."Type";
                pPurchInvLineTMP.Description := lSalesInvoiceLineTMP.Description;
                pPurchInvLineTMP."Description 2" := lSalesInvoiceLineTMP."Description 2";
                pPurchInvLineTMP."Linea de proyecto" := lSalesInvoiceLineTMP."No Linea proyecto";
                pPurchInvLineTMP."Job No." := lSalesInvoiceLineTMP."Job No.";
                pPurchInvLineTMP."Pay-to Vendor No." := lSalesInvoiceLineTMP."Bill-to Customer No.";
                pPurchInvLineTMP."Buy-from Vendor No." := lSalesInvoiceLineTMP."Sell-to Customer No.";
                pPurchInvLineTMP."Job Task No." := lSalesInvoiceLineTMP."Job Task No.";
                pPurchInvLineTMP."Proyecto Origen" := lSalesInvoiceLineTMP."Proyecto Origen";
                pPurchInvLineTMP."Empresa Origen" := lSalesInvoiceLineTMP."Empresa Origen";
                pPurchInvLineTMP."Order No." := lSalesInvoiceLineTMP."Order No.";
                pPurchInvLineTMP."Order Line No." := lSalesInvoiceLineTMP."Order Line No.";
                pPurchInvLineTMP."Receipt No." := lSalesInvoiceLineTMP."Shipment No.";
                pPurchInvLineTMP."Receipt Line No." := lSalesInvoiceLineTMP."Shipment Line No.";
                pPurchInvLineTMP."Recurso Agrupado" := lSalesInvoiceLineTMP."Recurso Agrupado";
                pPurchInvLineTMP."Fecha inicial recurso" := lSalesInvoiceLineTMP."Fecha inicial recurso";
                pPurchInvLineTMP."Fecha Final recurso" := lSalesInvoiceLineTMP."Fecha Final recurso";
                pPurchInvLineTMP."Quantity" := lSalesInvoiceLineTMP."Quantity";
                pPurchInvLineTMP."Quantity (Base)" := lSalesInvoiceLineTMP."Quantity (Base)";
                pPurchInvLineTMP."Unit of Measure Code" := lSalesInvoiceLineTMP."Unit of Measure Code";
                pPurchInvLineTMP."Direct Unit Cost" := lSalesInvoiceLineTMP."Unit Price";
                pPurchInvLineTMP."Unit Cost (LCY)" := lSalesInvoiceLineTMP."Unit Cost (LCY)";
                pPurchInvLineTMP."Line Discount Amount" := lSalesInvoiceLineTMP."Line Discount Amount";
                pPurchInvLineTMP."VAT Prod. Posting Group" := lSalesInvoiceLineTMP."VAT Prod. Posting Group";
                pPurchInvLineTMP."VAT Bus. Posting Group" := lSalesInvoiceLineTMP."VAT Bus. Posting Group";
                pPurchInvLineTMP."Gen. Bus. Posting Group" := lSalesInvoiceLineTMP."Gen. Bus. Posting Group";
                if lSalesInvoiceLineTMP."Gen. Prod. Posting Group" <> '' Then
                    pPurchInvLineTMP."Gen. Prod. Posting Group" := lSalesInvoiceLineTMP."Gen. Prod. Posting Group";
                //pPurchInvLineTMP."Pmt. Discount Amount":= //lSalesInvoiceLineTMP."Pmt. Discount Amount"
                pPurchInvLineTMP."Amount" := lSalesInvoiceLineTMP."Amount";
                pPurchInvLineTMP."Amount Including VAT" := lSalesInvoiceLineTMP."Amount Including VAT";
                pPurchInvLineTMP."Line Amount" := lSalesInvoiceLineTMP."Line Amount";
                pPurchInvLineTMP."Line discount %" := lSalesInvoiceLineTMP."Line discount %";
                pPurchInvLineTMP."Order No." := lSalesInvoiceLineTMP."Order No.";
                pPurchInvLineTMP."Order Line No." := lSalesInvoiceLineTMP."Order Line No.";
                pPurchInvLineTMP."Shortcut Dimension 1 Code" := lSalesInvoiceLineTMP."Shortcut Dimension 1 Code";
                pPurchInvLineTMP."Shortcut Dimension 2 Code" := lSalesInvoiceLineTMP."Shortcut Dimension 2 Code";
                pPurchInvLineTMP."Shortcut Dimension 3 Code" := lSalesInvoiceLineTMP."Shortcut Dimension 3 Code";
                pPurchInvLineTMP."Shortcut Dimension 4 Code" := lSalesInvoiceLineTMP."Shortcut Dimension 4 Code";
                pPurchInvLineTMP."Shortcut Dimension 5 Code" := lSalesInvoiceLineTMP."Shortcut Dimension 5 Code";
                pPurchInvLineTMP."Recurso" := lSalesInvoiceLineTMP.Recurso;
                pPurchInvLineTMP."Direct Unit Cost" := lSalesInvoiceLineTMP."Unit Price";

                pPurchInvLineTMP."Unit Cost" := lSalesInvoiceLineTMP2."Unit Price";
                If pPurchInvLineTMP.Insert Then;
            Until lSalesInvoiceLineTMP.NEXT = 0;
        if lSalesInvoiceLineTMP2.FINDFIRST THEN
            REPEAT
                //lSalesInvoiceLineTMP2.TransferFields(lSalesInvoiceLineTMP2);
                pPurchInvLineTMP2."Document No." := lSalesInvoiceLineTMP2."Document No.";
                pPurchInvLineTMP2."Line No." := lSalesInvoiceLineTMP2."Line No.";
                pPurchInvLineTMP2."Pay-to Vendor No." := lSalesInvoiceLineTMP2."Bill-to Customer No.";
                pPurchInvLineTMP2."Buy-from Vendor No." := lSalesInvoiceLineTMP2."Sell-to Customer No.";
                pPurchInvLineTMP2."No." := lSalesInvoiceLineTMP2."No.";
                pPurchInvLineTMP2."Type" := lSalesInvoiceLineTMP2."Type";
                pPurchInvLineTMP2."Order No." := lSalesInvoiceLineTMP2."Order No.";
                pPurchInvLineTMP2."Order Line No." := lSalesInvoiceLineTMP2."Order Line No.";
                pPurchInvLineTMP2.Description := lSalesInvoiceLineTMP2.Description;
                pPurchInvLineTMP2."Description 2" := lSalesInvoiceLineTMP2."Description 2";
                pPurchInvLineTMP2."Linea de proyecto" := lSalesInvoiceLineTMP2."No Linea proyecto";
                pPurchInvLineTMP2."Job No." := lSalesInvoiceLineTMP2."Job No.";
                pPurchInvLineTMP2."Job Task No." := lSalesInvoiceLineTMP2."Job Task No.";
                pPurchInvLineTMP2."Proyecto Origen" := lSalesInvoiceLineTMP2."Proyecto Origen";
                pPurchInvLineTMP2."Empresa Origen" := lSalesInvoiceLineTMP2."Empresa Origen";
                pPurchInvLineTMP2."Recurso Agrupado" := lSalesInvoiceLineTMP2."Recurso Agrupado";
                pPurchInvLineTMP2."Fecha inicial recurso" := lSalesInvoiceLineTMP2."Fecha inicial recurso";
                pPurchInvLineTMP2."Fecha Final recurso" := lSalesInvoiceLineTMP2."Fecha Final recurso";
                pPurchInvLineTMP2."Quantity" := lSalesInvoiceLineTMP2."Quantity";
                pPurchInvLineTMP2."Quantity (Base)" := lSalesInvoiceLineTMP2."Quantity (Base)";
                pPurchInvLineTMP2."Unit of Measure Code" := lSalesInvoiceLineTMP2."Unit of Measure Code";
                pPurchInvLineTMP2."Direct Unit Cost" := lSalesInvoiceLineTMP2."Unit Price";
                pPurchInvLineTMP2."Unit Cost (LCY)" := lSalesInvoiceLineTMP2."Unit Cost (LCY)";
                pPurchInvLineTMP2."Order No." := lSalesInvoiceLineTMP2."Order No.";
                pPurchInvLineTMP2."Order Line No." := lSalesInvoiceLineTMP2."Order Line No.";
                pPurchInvLineTMP2."Receipt No." := lSalesInvoiceLineTMP2."Shipment No.";
                pPurchInvLineTMP2."Receipt Line No." := lSalesInvoiceLineTMP2."Shipment Line No.";
                pPurchInvLineTMP2."Line Discount Amount" := lSalesInvoiceLineTMP2."Line Discount Amount";
                pPurchInvLineTMP2."VAT Prod. Posting Group" := lSalesInvoiceLineTMP2."VAT Prod. Posting Group";
                pPurchInvLineTMP2."VAT Bus. Posting Group" := lSalesInvoiceLineTMP2."VAT Bus. Posting Group";
                pPurchInvLineTMP2."Gen. Bus. Posting Group" := lSalesInvoiceLineTMP2."Gen. Bus. Posting Group";
                if lSalesInvoiceLineTMP2."Gen. Prod. Posting Group" <> '' Then
                    pPurchInvLineTMP2."Gen. Prod. Posting Group" := lSalesInvoiceLineTMP2."Gen. Prod. Posting Group";
                //pPurchInvLineTMP2."Pmt. Discount Amount":= //lSalesInvoiceLineTMP2."Pmt. Discount Amount"
                pPurchInvLineTMP2."Amount" := lSalesInvoiceLineTMP2."Amount";
                pPurchInvLineTMP2."Amount Including VAT" := lSalesInvoiceLineTMP2."Amount Including VAT";
                pPurchInvLineTMP2."Line Amount" := lSalesInvoiceLineTMP2."Line Amount";
                pPurchInvLineTMP2."Line discount %" := lSalesInvoiceLineTMP2."Line discount %";

                pPurchInvLineTMP2."Shortcut Dimension 1 Code" := lSalesInvoiceLineTMP2."Shortcut Dimension 1 Code";
                pPurchInvLineTMP2."Shortcut Dimension 2 Code" := lSalesInvoiceLineTMP2."Shortcut Dimension 2 Code";
                pPurchInvLineTMP2."Shortcut Dimension 3 Code" := lSalesInvoiceLineTMP2."Shortcut Dimension 3 Code";
                pPurchInvLineTMP2."Shortcut Dimension 4 Code" := lSalesInvoiceLineTMP2."Shortcut Dimension 4 Code";
                pPurchInvLineTMP2."Shortcut Dimension 5 Code" := lSalesInvoiceLineTMP2."Shortcut Dimension 5 Code";
                pPurchInvLineTMP2."Recurso" := lSalesInvoiceLineTMP2.Recurso;
                pPurchInvLineTMP2."Direct Unit Cost" := lSalesInvoiceLineTMP2."Unit Price";

                pPurchInvLineTMP2."Unit Cost" := lSalesInvoiceLineTMP2."Unit Price";
                If pPurchInvLineTMP2.Insert Then;
            Until lSalesInvoiceLineTMP2.NEXT = 0;

    end;

    Procedure Produccion(Var pPurchRcptLineTMP: Record "Purch. Rcpt. Line" temporary;
    Var pPurchRcptLineTMP2: Record "Purch. Rcpt. Line" temporary;
     var pResource: Record Resource; pCJobNo: Code[20]; var pbAgrupado: Boolean; pCCUrrencyCode: Code[20])
    var
        lSalesInvoiceLineTMP: Record "Sales Invoice Line" temporary;
        lSalesInvoiceLineTMP2: Record "Sales Invoice Line" temporary;

    begin
        // Ahora busco si es de producción				
        if pPurchRcptLineTMP.FINDFIRST THEN
            REPEAT
                //pPurchRcptLineTMP.TransferFields(lSalesInvoiceLineTMP);
                lSalesInvoiceLineTMP."Document No." := pPurchRcptLineTMP."Document No.";
                lSalesInvoiceLineTMP."Line No." := pPurchRcptLineTMP."Line No.";
                lSalesInvoiceLineTMP."No." := pPurchRcptLineTMP."No.";
                lSalesInvoiceLineTMP."Bill-to Customer No." := pPurchRcptLineTMP."Pay-to Vendor No.";
                lSalesInvoiceLineTMP."Sell-to Customer No." := pPurchRcptLineTMP."Buy-from Vendor No.";
                lSalesInvoiceLineTMP.Description := pPurchRcptLineTMP.Description;
                lSalesInvoiceLineTMP."Description 2" := pPurchRcptLineTMP."Description 2";
                lSalesInvoiceLineTMP."Order No." := pPurchRcptLineTMP."Order No.";
                lSalesInvoiceLineTMP."Order Line No." := pPurchRcptLineTMP."Order Line No.";
                lSalesInvoiceLineTMP."Type" := pPurchRcptLineTMP."Type";
                lSalesInvoiceLineTMP."No Linea proyecto" := pPurchRcptLineTMP."Linea de proyecto";
                lSalesInvoiceLineTMP."Job No." := pPurchRcptLineTMP."Job No.";
                lSalesInvoiceLineTMP."Job Task No." := pPurchRcptLineTMP."Job Task No.";
                lSalesInvoiceLineTMP."Proyecto Origen" := pPurchRcptLineTMP."Proyecto Origen";
                lSalesInvoiceLineTMP."Empresa Origen" := pPurchRcptLineTMP."Empresa Origen";
                lSalesInvoiceLineTMP."Recurso Agrupado" := pPurchRcptLineTMP."Recurso Agrupado";
                lSalesInvoiceLineTMP."Fecha inicial recurso" := pPurchRcptLineTMP."Fecha inicial recurso";
                lSalesInvoiceLineTMP."Fecha Final recurso" := pPurchRcptLineTMP."Fecha Final recurso";
                lSalesInvoiceLineTMP."Quantity" := pPurchRcptLineTMP."Quantity";
                lSalesInvoiceLineTMP."Quantity (Base)" := pPurchRcptLineTMP."Quantity (Base)";
                lSalesInvoiceLineTMP."Unit of Measure Code" := pPurchRcptLineTMP."Unit of Measure Code";
                lSalesInvoiceLineTMP."Unit Cost" := pPurchRcptLineTMP."Qty. Rcd. Not Invoiced";
                lSalesInvoiceLineTMP."Unit Price" := pPurchRcptLineTMP."Direct Unit Cost";
                lSalesInvoiceLineTMP."Unit Cost (LCY)" := pPurchRcptLineTMP."Unit Cost (LCY)";
                lSalesInvoiceLineTMP."Line Discount Amount" := pPurchRcptLineTMP."Line Discount Amount";
                lSalesInvoiceLineTMP."VAT Prod. Posting Group" := pPurchRcptLineTMP."VAT Prod. Posting Group";
                lSalesInvoiceLineTMP."VAT Bus. Posting Group" := pPurchRcptLineTMP."VAT Bus. Posting Group";
                lSalesInvoiceLineTMP."Gen. Bus. Posting Group" := pPurchRcptLineTMP."Gen. Bus. Posting Group";
                if pPurchRcptLineTMP."Gen. Prod. Posting Group" <> '' Then
                    lSalesInvoiceLineTMP."Gen. Prod. Posting Group" := pPurchRcptLineTMP."Gen. Prod. Posting Group";
                lSalesInvoiceLineTMP."Qty. per Unit of Measure" := pPurchRcptLineTMP."Qty. Rcd. Not Invoiced";
                //lSalesInvoiceLineTMP."Pmt. Discount Amount":=pPurchRcptLineTMP."Pmt. Discount Amount";
                lSalesInvoiceLineTMP."Amount" := pPurchRcptLineTMP."Amount";
                lSalesInvoiceLineTMP."Amount Including VAT" := pPurchRcptLineTMP."Amount Including VAT";
                lSalesInvoiceLineTMP."Line Amount" := pPurchRcptLineTMP."Line Amount";
                lSalesInvoiceLineTMP."Line discount %" := pPurchRcptLineTMP."Line discount %";
                lSalesInvoiceLineTMP."Order No." := pPurchRcptLineTMP."Order No.";
                lSalesInvoiceLineTMP."Order Line No." := pPurchRcptLineTMP."Order Line No.";
                lSalesInvoiceLineTMP."Shortcut Dimension 1 Code" := pPurchRcptLineTMP."Shortcut Dimension 1 Code";
                lSalesInvoiceLineTMP."Shortcut Dimension 2 Code" := pPurchRcptLineTMP."Shortcut Dimension 2 Code";
                lSalesInvoiceLineTMP."Shortcut Dimension 3 Code" := pPurchRcptLineTMP."Shortcut Dimension 3 Code";
                lSalesInvoiceLineTMP."Shortcut Dimension 4 Code" := pPurchRcptLineTMP."Shortcut Dimension 4 Code";
                lSalesInvoiceLineTMP."Shortcut Dimension 5 Code" := pPurchRcptLineTMP."Shortcut Dimension 5 Code";
                lSalesInvoiceLineTMP.Recurso := pPurchRcptLineTMP."Recurso";
                lSalesInvoiceLineTMP."Unit Price" := pPurchRcptLineTMP."Direct Unit Cost";
                If lSalesInvoiceLineTMP.Insert Then;
            Until pPurchRcptLineTMP.NEXT = 0;
        if pPurchRcptLineTMP2.FINDFIRST THEN
            REPEAT
                lSalesInvoiceLineTMP2."Document No." := pPurchRcptLineTMP2."Document No.";
                lSalesInvoiceLineTMP2."Line No." := pPurchRcptLineTMP2."Line No.";
                lSalesInvoiceLineTMP2."Bill-to Customer No." := pPurchRcptLineTMP2."Pay-to Vendor No.";
                lSalesInvoiceLineTMP2."Sell-to Customer No." := pPurchRcptLineTMP2."Buy-from Vendor No.";
                lSalesInvoiceLineTMP2."Order No." := pPurchRcptLineTMP2."Order No.";
                lSalesInvoiceLineTMP2."Order Line No." := pPurchRcptLineTMP2."Order Line No.";
                lSalesInvoiceLineTMP2."No." := pPurchRcptLineTMP2."No.";
                lSalesInvoiceLineTMP2.Description := pPurchRcptLineTMP2.Description;
                lSalesInvoiceLineTMP2."Description 2" := pPurchRcptLineTMP2."Description 2";
                lSalesInvoiceLineTMP2."Type" := pPurchRcptLineTMP2."Type";
                lSalesInvoiceLineTMP2."No Linea proyecto" := pPurchRcptLineTMP2."Linea de proyecto";
                lSalesInvoiceLineTMP2."Job No." := pPurchRcptLineTMP2."Job No.";
                lSalesInvoiceLineTMP2."Job Task No." := pPurchRcptLineTMP2."Job Task No.";
                lSalesInvoiceLineTMP2."Proyecto Origen" := pPurchRcptLineTMP2."Proyecto Origen";
                lSalesInvoiceLineTMP2."Empresa Origen" := pPurchRcptLineTMP2."Empresa Origen";
                lSalesInvoiceLineTMP2."Recurso Agrupado" := pPurchRcptLineTMP2."Recurso Agrupado";
                lSalesInvoiceLineTMP2."Fecha inicial recurso" := pPurchRcptLineTMP2."Fecha inicial recurso";
                lSalesInvoiceLineTMP2."Fecha Final recurso" := pPurchRcptLineTMP2."Fecha Final recurso";
                lSalesInvoiceLineTMP2."Quantity" := pPurchRcptLineTMP2."Quantity";
                lSalesInvoiceLineTMP2."Quantity (Base)" := pPurchRcptLineTMP2."Quantity (Base)";
                lSalesInvoiceLineTMP2."Unit of Measure Code" := pPurchRcptLineTMP2."Unit of Measure Code";
                lSalesInvoiceLineTMP2."Unit Cost" := pPurchRcptLineTMP2."Qty. Rcd. Not Invoiced";
                lSalesInvoiceLineTMP2."Qty. per Unit of Measure" := pPurchRcptLineTMP2."Qty. Rcd. Not Invoiced";
                lSalesInvoiceLineTMP2."Unit Price" := pPurchRcptLineTMP2."Direct Unit Cost";
                lSalesInvoiceLineTMP2."Unit Cost (LCY)" := pPurchRcptLineTMP2."Unit Cost (LCY)";
                lSalesInvoiceLineTMP2."Line Discount Amount" := pPurchRcptLineTMP2."Line Discount Amount";
                lSalesInvoiceLineTMP2."VAT Prod. Posting Group" := pPurchRcptLineTMP2."VAT Prod. Posting Group";
                lSalesInvoiceLineTMP2."VAT Bus. Posting Group" := pPurchRcptLineTMP2."VAT Bus. Posting Group";
                lSalesInvoiceLineTMP2."Gen. Bus. Posting Group" := pPurchRcptLineTMP2."Gen. Bus. Posting Group";
                if pPurchRcptLineTMP2."Gen. Prod. Posting Group" <> '' Then
                    lSalesInvoiceLineTMP2."Gen. Prod. Posting Group" := pPurchRcptLineTMP2."Gen. Prod. Posting Group";
                //lSalesInvoiceLineTMP2."Pmt. Discount Amount":=pPurchRcptLineTMP2."Pmt. Discount Amount";
                lSalesInvoiceLineTMP2."Amount" := pPurchRcptLineTMP2."Amount";
                lSalesInvoiceLineTMP2."Amount Including VAT" := pPurchRcptLineTMP2."Amount Including VAT";
                lSalesInvoiceLineTMP2."Line Amount" := pPurchRcptLineTMP2."Line Amount";
                lSalesInvoiceLineTMP2."Line discount %" := pPurchRcptLineTMP2."Line discount %";

                lSalesInvoiceLineTMP2."Shortcut Dimension 1 Code" := pPurchRcptLineTMP2."Shortcut Dimension 1 Code";
                lSalesInvoiceLineTMP2."Shortcut Dimension 2 Code" := pPurchRcptLineTMP2."Shortcut Dimension 2 Code";
                lSalesInvoiceLineTMP2."Shortcut Dimension 3 Code" := pPurchRcptLineTMP2."Shortcut Dimension 3 Code";
                lSalesInvoiceLineTMP2."Shortcut Dimension 4 Code" := pPurchRcptLineTMP2."Shortcut Dimension 4 Code";
                lSalesInvoiceLineTMP2."Shortcut Dimension 5 Code" := pPurchRcptLineTMP2."Shortcut Dimension 5 Code";
                lSalesInvoiceLineTMP2.Recurso := pPurchRcptLineTMP2."Recurso";
                lSalesInvoiceLineTMP2."Unit Price" := pPurchRcptLineTMP2."Direct Unit Cost";
                If lSalesInvoiceLineTMP2.Insert Then;
            Until pPurchRcptLineTMP2.NEXT = 0;
        pPurchRcptLineTMP.deleteAll;
        pPurchRcptLineTMP2.deleteall;
        Produccion(lSalesInvoiceLineTMP, lSalesInvoiceLineTMP2, pResource, pCJobNo, pbAgrupado, pCCUrrencyCode);
        if lSalesInvoiceLineTMP.FINDFIRST THEN
            REPEAT
                pPurchRcptLineTMP."Document No." := lSalesInvoiceLineTMP."Document No.";
                pPurchRcptLineTMP."Line No." := lSalesInvoiceLineTMP."Line No.";
                pPurchRcptLineTMP."No." := lSalesInvoiceLineTMP."No.";
                pPurchRcptLineTMP."Pay-to Vendor No." := lSalesInvoiceLineTMP."Bill-to Customer No.";
                pPurchRcptLineTMP."Buy-from Vendor No." := lSalesInvoiceLineTMP."Sell-to Customer No.";
                pPurchRcptLineTMP."Type" := lSalesInvoiceLineTMP."Type";
                pPurchRcptLineTMP."Order No." := lSalesInvoiceLineTMP."Order No.";
                pPurchRcptLineTMP."Order Line No." := lSalesInvoiceLineTMP."Order Line No.";
                pPurchRcptLineTMP.Description := lSalesInvoiceLineTMP.Description;
                pPurchRcptLineTMP."Description 2" := lSalesInvoiceLineTMP."Description 2";
                pPurchRcptLineTMP."Linea de proyecto" := lSalesInvoiceLineTMP."No Linea proyecto";
                pPurchRcptLineTMP."Job No." := lSalesInvoiceLineTMP."Job No.";
                pPurchRcptLineTMP."Job Task No." := lSalesInvoiceLineTMP."Job Task No.";
                pPurchRcptLineTMP."Proyecto Origen" := lSalesInvoiceLineTMP."Proyecto Origen";
                pPurchRcptLineTMP."Empresa Origen" := lSalesInvoiceLineTMP."Empresa Origen";
                pPurchRcptLineTMP."Recurso Agrupado" := lSalesInvoiceLineTMP."Recurso Agrupado";
                pPurchRcptLineTMP."Fecha inicial recurso" := lSalesInvoiceLineTMP."Fecha inicial recurso";
                pPurchRcptLineTMP."Fecha Final recurso" := lSalesInvoiceLineTMP."Fecha Final recurso";
                pPurchRcptLineTMP."Quantity" := lSalesInvoiceLineTMP."Quantity";
                pPurchRcptLineTMP."Quantity (Base)" := lSalesInvoiceLineTMP."Quantity (Base)";
                pPurchRcptLineTMP."Qty. Rcd. Not Invoiced" := lSalesInvoiceLineTMP."Unit Cost";
                pPurchRcptLineTMP."Unit of Measure Code" := lSalesInvoiceLineTMP."Unit of Measure Code";
                pPurchRcptLineTMP."Direct Unit Cost" := lSalesInvoiceLineTMP."Unit Price";
                pPurchRcptLineTMP."Unit Cost (LCY)" := lSalesInvoiceLineTMP."Unit Cost (LCY)";
                pPurchRcptLineTMP."Qty. Rcd. Not Invoiced" := lSalesInvoiceLineTMP."Qty. per Unit of Measure";
                pPurchRcptLineTMP."Line Discount Amount" := lSalesInvoiceLineTMP."Line Discount Amount";
                pPurchRcptLineTMP."VAT Prod. Posting Group" := lSalesInvoiceLineTMP."VAT Prod. Posting Group";
                pPurchRcptLineTMP."VAT Bus. Posting Group" := lSalesInvoiceLineTMP."VAT Bus. Posting Group";
                pPurchRcptLineTMP."Gen. Bus. Posting Group" := lSalesInvoiceLineTMP."Gen. Bus. Posting Group";
                pPurchRcptLineTMP."Gen. Prod. Posting Group" := lSalesInvoiceLineTMP."Gen. Prod. Posting Group";
                //pPurchRcptLineTMP."Pmt. Discount Amount":= //lSalesInvoiceLineTMP."Pmt. Discount Amount"
                pPurchRcptLineTMP."Amount" := lSalesInvoiceLineTMP."Amount";
                pPurchRcptLineTMP."Amount Including VAT" := lSalesInvoiceLineTMP."Amount Including VAT";
                pPurchRcptLineTMP."Line Amount" := lSalesInvoiceLineTMP."Line Amount";
                pPurchRcptLineTMP."Line discount %" := lSalesInvoiceLineTMP."Line discount %";

                pPurchRcptLineTMP."Shortcut Dimension 1 Code" := lSalesInvoiceLineTMP."Shortcut Dimension 1 Code";
                pPurchRcptLineTMP."Shortcut Dimension 2 Code" := lSalesInvoiceLineTMP."Shortcut Dimension 2 Code";
                pPurchRcptLineTMP."Shortcut Dimension 3 Code" := lSalesInvoiceLineTMP."Shortcut Dimension 3 Code";
                pPurchRcptLineTMP."Shortcut Dimension 4 Code" := lSalesInvoiceLineTMP."Shortcut Dimension 4 Code";
                pPurchRcptLineTMP."Shortcut Dimension 5 Code" := lSalesInvoiceLineTMP."Shortcut Dimension 5 Code";
                pPurchRcptLineTMP."Recurso" := lSalesInvoiceLineTMP.Recurso;
                pPurchRcptLineTMP."Direct Unit Cost" := lSalesInvoiceLineTMP."Unit Price";

                pPurchRcptLineTMP."Unit Cost" := lSalesInvoiceLineTMP2."Unit Price";
                If pPurchRcptLineTMP.Insert Then;
            Until lSalesInvoiceLineTMP.NEXT = 0;
        if lSalesInvoiceLineTMP2.FINDFIRST THEN
            REPEAT
                //lSalesInvoiceLineTMP2.TransferFields(lSalesInvoiceLineTMP2);
                pPurchRcptLineTMP2."Document No." := lSalesInvoiceLineTMP2."Document No.";
                pPurchRcptLineTMP2."Line No." := lSalesInvoiceLineTMP2."Line No.";
                pPurchRcptLineTMP2."No." := lSalesInvoiceLineTMP2."No.";
                pPurchRcptLineTMP2."Type" := lSalesInvoiceLineTMP2."Type";
                pPurchRcptLineTMP2."Order No." := lSalesInvoiceLineTMP2."Order No.";
                pPurchRcptLineTMP2."Order Line No." := lSalesInvoiceLineTMP2."Order Line No.";
                pPurchRcptLineTMP2."Pay-to Vendor No." := lSalesInvoiceLineTMP2."Bill-to Customer No.";
                pPurchRcptLineTMP2."Buy-from Vendor No." := lSalesInvoiceLineTMP2."Sell-to Customer No.";
                pPurchRcptLineTMP2."Description 2" := lSalesInvoiceLineTMP2."Description 2";
                pPurchRcptLineTMP2."Linea de proyecto" := lSalesInvoiceLineTMP2."No Linea proyecto";
                pPurchRcptLineTMP2."Linea de proyecto" := lSalesInvoiceLineTMP2."No Linea proyecto";
                pPurchRcptLineTMP2."Job No." := lSalesInvoiceLineTMP2."Job No.";
                pPurchRcptLineTMP2."Job Task No." := lSalesInvoiceLineTMP2."Job Task No.";
                pPurchRcptLineTMP2."Proyecto Origen" := lSalesInvoiceLineTMP2."Proyecto Origen";
                pPurchRcptLineTMP2."Empresa Origen" := lSalesInvoiceLineTMP2."Empresa Origen";
                pPurchRcptLineTMP2."Recurso Agrupado" := lSalesInvoiceLineTMP2."Recurso Agrupado";
                pPurchRcptLineTMP2."Fecha inicial recurso" := lSalesInvoiceLineTMP2."Fecha inicial recurso";
                pPurchRcptLineTMP2."Fecha Final recurso" := lSalesInvoiceLineTMP2."Fecha Final recurso";
                pPurchRcptLineTMP2."Quantity" := lSalesInvoiceLineTMP2."Quantity";
                pPurchRcptLineTMP2."Quantity (Base)" := lSalesInvoiceLineTMP2."Quantity (Base)";
                pPurchRcptLineTMP2."Qty. Rcd. Not Invoiced" := lSalesInvoiceLineTMP2."Unit Cost";
                pPurchRcptLineTMP2."Unit of Measure Code" := lSalesInvoiceLineTMP2."Unit of Measure Code";
                pPurchRcptLineTMP2."Direct Unit Cost" := lSalesInvoiceLineTMP2."Unit Price";
                pPurchRcptLineTMP2."Unit Cost (LCY)" := lSalesInvoiceLineTMP2."Unit Cost (LCY)";
                pPurchRcptLineTMP2."Qty. Rcd. Not Invoiced" := lSalesInvoiceLineTMP2."Qty. per Unit of Measure";
                pPurchRcptLineTMP2."Line Discount Amount" := lSalesInvoiceLineTMP2."Line Discount Amount";
                pPurchRcptLineTMP2."VAT Prod. Posting Group" := lSalesInvoiceLineTMP2."VAT Prod. Posting Group";
                pPurchRcptLineTMP2."VAT Bus. Posting Group" := lSalesInvoiceLineTMP2."VAT Bus. Posting Group";
                pPurchRcptLineTMP2."Gen. Bus. Posting Group" := lSalesInvoiceLineTMP2."Gen. Bus. Posting Group";
                if lSalesInvoiceLineTMP2."Gen. Prod. Posting Group" <> '' Then
                    pPurchRcptLineTMP2."Gen. Prod. Posting Group" := lSalesInvoiceLineTMP2."Gen. Prod. Posting Group";
                //pPurchRcptLineTMP2."Pmt. Discount Amount":= //lSalesInvoiceLineTMP2."Pmt. Discount Amount"
                pPurchRcptLineTMP2."Amount" := lSalesInvoiceLineTMP2."Amount";
                pPurchRcptLineTMP2."Amount Including VAT" := lSalesInvoiceLineTMP2."Amount Including VAT";
                pPurchRcptLineTMP2."Line Amount" := lSalesInvoiceLineTMP2."Line Amount";
                pPurchRcptLineTMP2."Line discount %" := lSalesInvoiceLineTMP2."Line discount %";

                pPurchRcptLineTMP2."Shortcut Dimension 1 Code" := lSalesInvoiceLineTMP2."Shortcut Dimension 1 Code";
                pPurchRcptLineTMP2."Shortcut Dimension 2 Code" := lSalesInvoiceLineTMP2."Shortcut Dimension 2 Code";
                pPurchRcptLineTMP2."Shortcut Dimension 3 Code" := lSalesInvoiceLineTMP2."Shortcut Dimension 3 Code";
                pPurchRcptLineTMP2."Shortcut Dimension 4 Code" := lSalesInvoiceLineTMP2."Shortcut Dimension 4 Code";
                pPurchRcptLineTMP2."Shortcut Dimension 5 Code" := lSalesInvoiceLineTMP2."Shortcut Dimension 5 Code";
                pPurchRcptLineTMP2."Recurso" := lSalesInvoiceLineTMP2.Recurso;
                pPurchRcptLineTMP2."Direct Unit Cost" := lSalesInvoiceLineTMP2."Unit Price";

                pPurchRcptLineTMP2."Unit Cost" := lSalesInvoiceLineTMP2."Unit Price";
                If pPurchRcptLineTMP2.Insert Then;
            Until lSalesInvoiceLineTMP2.NEXT = 0;

    end;

    procedure recuperaproyecto(var lJob: Record Job; JobNo: Code[20]; lResource: Record Resource)
    begin
        If JobNo <> '' Then Begin
            if (lResource."Empresa Origen" <> COMPANYNAME) THEN BEGIN
                lJob.CHANGECOMPANY(lResource."Empresa Origen");
                If not lJob.Get(JobNo) Then begin
                    ljob.SetRange("Empresa Origen", CompanyName);
                    lJob.Setrange("Proyecto en empresa Origen", JobNo);
                    If not lJob.FindSet() THEN Error('No existe el proyecto %1 en la empresa %2 revise las asignaciones de producción', JobNo, lResource."Empresa Origen");
                end;
            END else
                If not lJob.GET(JobNo) THEN Error('No existe el proyecto %1 en la empresa %2 revise las asignaciones de producción', JobNo, lResource."Empresa Origen");
        end;
    end;

    procedure ProyectoEmpresa(var lJob: Record Job; JobNo: Code[20]; JobCabNo: Code[20])
    begin
        lJob.CHANGECOMPANY(COMPANYNAME);
        If "JobNo" <> '' Then
            If not lJob.GET(JobNo) THEN
                If not lJob.GET(JobCabNo) THEN
                    Error('No existe el proyecto %1 en la empresa %2 revise las asignaciones de producción', JobCabNo, Companyname);
    end;


}