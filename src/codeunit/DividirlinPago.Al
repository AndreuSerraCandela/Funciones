/// <summary>
/// Codeunit Dividir lin. rel. pago (ID 50009).
/// </summary>
codeunit 50009 "Dividir lin. rel. pago"
{
    VAR
        Text1100000: Label 'Para un abono no se puede seleccionar %1 ya que genera efectos.';
        Text1100001: Label '%1 debe ser 1 si %2 is Sí en %3';
        Text1100002: Label 'Convertir factura %1 en efectos';
        Text1100003: Label 'Tipo IVA no realizado debe ser porcentaje en configuración grupo registro IVA.';
        Text1100004: Label 'Efecto %1/%2';
        Text1100005: Label 'La suma de %1 no puede superar 100 en los plazos de %2 %3.';
        PaymentMethod: Record 289;
        PaymentTerms: Record 3;
        recLinPag: Record "Lin. relacion pagos";
        GLSetup: Record "General Ledger Setup";
        SalesSetup: Record 311;
        PurchSetup: Record "Purchases & Payables Setup";
        Currency: Record "Currency";
        CurrencyExchRate: Record "Currency Exchange Rate";
        GenJnlPostLine: Codeunit 12;
        DueDateAdjust: Codeunit 10700;
        DocPost: Codeunit 7000006;
        DimMgt: Codeunit 408;
        Installment: Record 7000018;
        Sales: Integer;
        CurrencyFactor: Decimal;
        TotalAmount: Decimal;
        RemainingAmount: Decimal;
        InstallmentAmount: Decimal;
        NextDueDate: Date;
        CurrDocNo: Integer;
        TotalPerc: Decimal;
        ExistsVATNoReal: Boolean;
        ErrorMessage: Boolean;

    PROCEDURE DividirLinRelPagos(VAR PurchHeader: Record "Purch. Inv. Header"; VAR VendLedgEntry: Record 25; VAR recPrmLinPag: Record "Lin. relacion pagos"; VATAmount: Decimal);
    VAR
        VATPostingSetup: Record 325;
        CarteraManagement: Codeunit 7000000;
    BEGIN
        //WITH PurchHeader. DO BEGIN
        if NOT PaymentMethod.GET(PurchHeader."Payment Method Code") THEN
            EXIT;

        if PurchHeader."Currency Code" = '' THEN
            CurrencyFactor := 1
        ELSE
            CurrencyFactor := PurchHeader."Currency Factor";

        GLSetup.GET;
        PurchSetup.GET;
        PurchHeader.TESTFIELD("Payment Terms Code");
        PaymentTerms.GET(PurchHeader."Payment Terms Code");
        PaymentTerms.CALCFIELDS("No. of Installments");
        if PaymentTerms."No. of Installments" = 0 THEN
            PaymentTerms."No. of Installments" := 1;
        if PaymentMethod."Invoices to Cartera" AND (PaymentTerms."No. of Installments" > 1) THEN
            ERROR(
              Text1100001,
              PaymentTerms.FIELDCAPTION("No. of Installments"),
              PaymentMethod.FIELDCAPTION("Invoices to Cartera"),
              PaymentMethod.TABLECAPTION);
        VendLedgEntry.FINDLAST;
        VendLedgEntry.CALCFIELDS("Remaining Amount", "Remaining Amt. (LCY)");
        if VendLedgEntry."Remaining Amount" = 0 THEN
            EXIT;
        TotalAmount := -VendLedgEntry."Remaining Amount";
        RemainingAmount := -VendLedgEntry."Remaining Amount";

        if PurchHeader."Currency Code" = '' THEN BEGIN
            Currency."Invoice Rounding Precision" := GLSetup."Inv. Rounding Precision (LCY)";
            Currency."Invoice Rounding Type" := GLSetup."Inv. Rounding Type (LCY)";
            Currency."Amount Rounding Precision" := GLSetup."Amount Rounding Precision";
            if PurchSetup."Invoice Rounding" THEN
                GLSetup.TESTFIELD("Inv. Rounding Precision (LCY)")
            ELSE
                GLSetup.TESTFIELD("Amount Rounding Precision");
        END ELSE BEGIN
            Currency.GET(PurchHeader."Currency Code");
            if SalesSetup."Invoice Rounding" THEN
                Currency.TESTFIELD("Invoice Rounding Precision")
            ELSE
                Currency.TESTFIELD("Amount Rounding Precision");
        END;
        TotalAmount := RoundPayableAmt(TotalAmount);

        if PaymentTerms."No. of Installments" > 0 THEN BEGIN
            Installment.SETRANGE("Payment Terms Code", PaymentTerms.Code);
            if Installment.FIND('-') THEN;
        END;

        NextDueDate := PurchHeader."Due Date";

        recLinPag.INIT;
        recLinPag.TRANSFERFIELDS(recPrmLinPag);

        FOR CurrDocNo := 1 TO PaymentTerms."No. of Installments" DO BEGIN

            recLinPag."No. linea" := recPrmLinPag."No. linea" + (10000 * CurrDocNo);
            recLinPag."Fecha vencimiento" := NextDueDate;
            DueDateAdjust.PurchAdjustDueDate(recLinPag."Fecha vencimiento", CalcDate('-1M', recLinPag."Fecha vencimiento"),
            CalcDate('1M', recLinPag."Fecha vencimiento"), PurchHeader."Pay-to Vendor No.");
            //    recLinPag.Importe := RoundPayableAmt((TotalAmount - VATAmount));

            if CurrDocNo < PaymentTerms."No. of Installments" THEN BEGIN
                Installment.TESTFIELD("% of Total");
                if CurrDocNo = 1 THEN BEGIN
                    TotalPerc := Installment."% of Total";
                    CASE PaymentTerms."VAT distribution" OF
                        PaymentTerms."VAT distribution"::"First Installment":
                            BEGIN
                                recLinPag."Importe IVA incl." := RoundPayableAmt(
                                  (TotalAmount - VATAmount) * Installment."% of Total" / 100 + VATAmount);
                            END;
                        PaymentTerms."VAT distribution"::"Last Installment":
                            BEGIN
                                recLinPag."Importe IVA incl." := RoundPayableAmt(
                                  (TotalAmount - VATAmount) * Installment."% of Total" / 100);
                            END;
                        PaymentTerms."VAT distribution"::Proportional:
                            BEGIN
                                recLinPag."Importe IVA incl." := RoundPayableAmt(
                                 TotalAmount * Installment."% of Total" / 100);
                            END;
                    END;
                END ELSE BEGIN
                    TotalPerc := TotalPerc + Installment."% of Total";
                    if TotalPerc >= 100 THEN
                        ERROR(
                          Text1100005,
                          Installment.FIELDCAPTION("% of Total"),
                          PaymentTerms.TABLECAPTION,
                          PaymentTerms.Code);
                    CASE PaymentTerms."VAT distribution" OF
                        PaymentTerms."VAT distribution"::"First Installment",
                        PaymentTerms."VAT distribution"::"Last Installment":
                            BEGIN
                                recLinPag."Importe IVA incl." := RoundPayableAmt(
                                  (TotalAmount - VATAmount) * Installment."% of Total" / 100);
                            END;
                        PaymentTerms."VAT distribution"::Proportional:
                            BEGIN
                                recLinPag."Importe IVA incl." := RoundPayableAmt(
                                  TotalAmount * Installment."% of Total" / 100);
                            END;
                    END;
                END;
                RemainingAmount := RemainingAmount - recLinPag."Importe IVA incl.";
                Installment.TESTFIELD("Gap between Installments");
                NextDueDate := CALCDATE(Installment."Gap between Installments", NextDueDate);
                Installment.NEXT;
            END ELSE BEGIN
                recLinPag."Importe IVA incl." := RemainingAmount;
            END;
            recLinPag.INSERT;
        END;

    END;


    LOCAL PROCEDURE RoundPayableAmt(Amount: Decimal): Decimal;
    BEGIN
        if SalesSetup."Invoice Rounding" THEN
            Amount := ROUND(
              Amount,
              Currency."Invoice Rounding Precision",
              SELECTSTR(Currency."Invoice Rounding Type" + 1, '=,>,<'))
        ELSE
            Amount := ROUND(
              Amount,
              Currency."Amount Rounding Precision");

        EXIT(Amount);
    END;

    LOCAL PROCEDURE RoundPayableAmtLCY(Amount: Decimal): Decimal;
    BEGIN
        if SalesSetup."Invoice Rounding" THEN
            Amount := ROUND(
              Amount,
              GLSetup."Inv. Rounding Precision (LCY)",
              SELECTSTR(GLSetup."Inv. Rounding Type (LCY)" + 1, '=,>,<'))
        ELSE
            Amount := ROUND(
              Amount,
              GLSetup."Amount Rounding Precision");

        EXIT(Amount);
    END;

    LOCAL PROCEDURE FindVendVATSetup(VAR VATSetup: Record 325; PurchHeader2: Record 38);
    VAR
        Vendor: Record Vendor;
        PostingGroup: Code[10];
        PurchLine2: Record 39;
    BEGIN
        Vendor.GET(PurchHeader2."Buy-from Vendor No.");

        VATSetup.SETCURRENTKEY("VAT Bus. Posting Group", "VAT Prod. Posting Group");
        VATSetup.SETRANGE(VATSetup."VAT Bus. Posting Group", Vendor."VAT Bus. Posting Group");

        PurchLine2.SETCURRENTKEY("Document Type", "Document No.", "Line No.");
        PurchLine2.SETRANGE("Document Type", PurchHeader2."Document Type");
        PurchLine2.SETRANGE("Document No.", PurchHeader2."No.");
        PurchLine2.FIND('-');

        REPEAT
            CASE PurchLine2.Type OF
                PurchLine2.Type::Item:
                    BEGIN
                        PostingGroup := PurchLine2."VAT Prod. Posting Group";
                        VATSetup.SETRANGE(VATSetup."VAT Prod. Posting Group", PostingGroup);
                        if (VATSetup.FIND('-') AND (VATSetup."Unrealized VAT Type" >= VATSetup."Unrealized VAT Type"::Percentage)) THEN
                            if VATSetup."Unrealized VAT Type" > VATSetup."Unrealized VAT Type"::Percentage THEN
                                ErrorMessage := TRUE
                            ELSE
                                ExistsVATNoReal := TRUE;
                    END;
                PurchLine2.Type::"G/L Account":
                    BEGIN
                        PostingGroup := PurchLine2."VAT Prod. Posting Group";
                        VATSetup.SETRANGE(VATSetup."VAT Prod. Posting Group", PostingGroup);
                        if (VATSetup.FIND('-') AND (VATSetup."Unrealized VAT Type" >= VATSetup."Unrealized VAT Type"::Percentage)) THEN
                            if VATSetup."Unrealized VAT Type" > VATSetup."Unrealized VAT Type"::Percentage THEN
                                ErrorMessage := TRUE
                            ELSE
                                ExistsVATNoReal := TRUE;
                    END;
            END;
        UNTIL PurchLine2.NEXT = 0;
    END;

    PROCEDURE DividirPagos(VAR recPrmLinPago: Record "Lin. relacion pagos");
    VAR
        dlgVentana: Page "Petición datos Pagaré";
        recCfgConta: Record "General Ledger Setup";
        recLinPago: Record "Lin. relacion pagos";
        decImpPago: Decimal;
        decImpPagoIVA: Decimal;
        intPagos: Integer;
        intLineas: Integer;
        intLinea: Integer;
        i: Integer;
        Text0001: Label 'Indique el nº de pagos que desea: ############1';
        Text0002: Label 'No es posible dividir el pago de la factura Nº %1 por que ya ha sido generado el pagaré.';
        Text0003: Label 'Se ha divido el pago de la factura Nº %1. Recuerde que debe revisar las fechas de vencimiento y los importes.';
    BEGIN
        // $001

        recCfgConta.GET;
        recCfgConta.TESTFIELD("Amount Rounding Precision");

        // WITH recPrmLinPago. DO BEGIN

        // Ctrl. por si la línea ya está incluida en un pagaré.
        if recPrmLinPago.FIND('-') THEN
            REPEAT
                if recPrmLinPago."Pagaré generado" THEN
                    ERROR(Text0002, recPrmLinPago."Nº documento proveedor");
                recPrmLinPago.MARK(TRUE);
                intLineas += 1;
            UNTIL recPrmLinPago.NEXT = 0;

        // Nº de líneas en las que se va a desglosar.
        intPagos := 1;
        if dlgVentana.RunModal() in [Action::Cancel, Action::LookupCancel, Action::No, Action::None] Then error('Proceso Cancelado');
        ;
        intPagos := dlgVentana.Recoge_Pag();
        dlgVentana.CLOSE;
        if intPagos > 1 THEN BEGIN

            recPrmLinPago.MARKEDONLY(TRUE);
            if recPrmLinPago.FINDLAST THEN BEGIN

                intLinea := recPrmLinPago."No. linea";

                recLinPago.RESET;
                recLinPago.ASCENDING(FALSE);
                recLinPago.SETRANGE("No. relación pagos", recPrmLinPago."No. relación pagos");
                recLinPago.SETFILTER("No. linea", '>%1', recPrmLinPago."No. linea");
                if recLinPago.FIND('-') THEN
                    REPEAT
                        recLinPago.DELETE;
                        recLinPago."No. linea" += intPagos * intLineas * 10000;
                        recLinPago.INSERT;
                    UNTIL recLinPago.NEXT = 0;

                FOR i := 1 TO (intPagos - 1) DO BEGIN
                    if recPrmLinPago.FINDFIRST THEN
                        REPEAT
                            recLinPago.INIT;
                            recLinPago := recPrmLinPago;
                            intLinea += 10000;
                            recLinPago."No. linea" := intLinea;
                            recLinPago."Fecha vencimiento" := 0D;
                            //          recLinPago.Importe := ROUND(Importe / intPagos, recCfgConta."Amount Rounding Precision");
                            recLinPago."Importe IVA incl." := ROUND(recPrmLinPago."Importe IVA incl." / intPagos, recCfgConta."Amount Rounding Precision");
                            recLinPago.INSERT;
                        UNTIL recPrmLinPago.NEXT = 0;
                END;

                if recPrmLinPago.FINDFIRST THEN
                    REPEAT

                        //        Importe := ROUND(Importe / intPagos, recCfgConta."Amount Rounding Precision") +
                        //                   (Importe - (ROUND(Importe / intPagos, recCfgConta."Amount Rounding Precision") * intPagos));
                        recPrmLinPago."Importe IVA incl." := ROUND(recPrmLinPago."Importe IVA incl." / intPagos, recCfgConta."Amount Rounding Precision") +
                                               (recPrmLinPago."Importe IVA incl." - ROUND(recPrmLinPago."Importe IVA incl." / intPagos,
                                                recCfgConta."Amount Rounding Precision") * intPagos);
                        recPrmLinPago.MODIFY;
                    UNTIL recPrmLinPago.NEXT = 0;

                //END;
            END;
        END;
    END;

    //     BEGIN
    //     {
    //       $001 01/02/07 JML : Pagares 5.0
    //                           Contiene funciones para generar los pagos según la configuración del proveedor.
    //     }
    //     END.
    //   }
}