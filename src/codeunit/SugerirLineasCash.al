/// <summary>
/// Codeunit Suggest Worksheet Lines New (ID 7001138).
/// </summary>
codeunit 7001117 "Suggest Worksheet Lines New"
{
    var
        gCashFlowForecast: Record "Cash Flow Forecast";
        gCustomer: Record Customer;
        gPurchHeader: Record "Purchase Header";
        gSalesHeader: Record "Sales Header";
        gFASetup: Record "FA Setup";
        gcCashFlowForecastHandler: Codeunit "Cash Flow Forecast Handler";
        gBAtrasado: Boolean;
        gLiqAccT: Record "Cash Flow Account";

        glText013: Label '%1 Saldo=%2';
        glText025: Label '%1 %2 %3';
        glText027: Label '%1 AC= %2';
        glText030: Label '%1 presupuesto %2 ';
        gCFSetup: Record "Cash Flow Setup";
        gSelectionCashFlowForecast: Record "Cash Flow Forecast";
        gLiqAcc: Record "Cash Flow Account";
        gTempCFWorksheetLine: Record "Cash Flow Worksheet Line" temporary;
        gCFWorksheetLine2: Record "Cash Flow Worksheet Line";
        gServiceHeader: Record "Service Header";
        gFADeprBook: Record "FA Depreciation Book";
        gGLBudgEntry: Record "G/L Budget Entry";
        gGLSetup: Record "General Ledger Setup";
        gCurrency: Record Currency;
        gCurrExchRate: Record "Currency Exchange Rate";
        gPaymentMethod: Record "Payment Method";
        gSalesSetup: Record "Sales & Receivables Setup";
        gPurchSetup: Record "Purchases & Payables Setup";
        gServSetup: Record "Service Mgt. Setup";
        gPaymentTerms: Record "Payment Terms";
        gCarteraSetup: Record "Cartera Setup";
        gcApplicationAreaMgmtFacade: Codeunit "Application Area Mgmt. Facade";
        gcCashFlowManagement: Codeunit "Cash Flow Management";
        gBArrayConsiderSource: array[23] of Boolean;
        gESourceType: Enum "Cash Flow Source Type";
        gCCashFlowNo: Code[20];
        giLineNo: Integer;
        gdDateLastExecution: Date;
        gCGLBudgName: Code[10];
        gDTotalAmt: Decimal;
        gBMultiSalesLines: Boolean;
        gBSummarized: Boolean;
        glText1100000: Label 'No puede seleccionar movimeintos basado en efectos para los abonos.';
        glText1100001: Label '%1 debe ser 1 si %2 es Sí en %3.';
        glCannotCreateCarteraDocErr: Label 'No tiene permisos para crer Documentpos de Cartera.\Por favor, cambie el método de pago.';
        glText1100004: Label 'Pedido venta efecto nº %1 de %2.';
        glText1100005: Label 'La suma de %1 no puede ser mayor que 100 en las cuotas para %2 %3.';
        glText1100006: Label 'Pedido compra efecto nº %1 de %2.';
        glText1100007: Label 'Pedido de servicio efecto nº %1 de %2';
        gBNeedsManualPmtUpdate: Boolean;
        glManualPmtRevEglXPNeedsUpdateMsg: Label 'Hay gatos/ingresos manuales recurrentrs.\Pero so se puede aplicar la recurrencia porque la fecha hasta de pagos manuales en la prevision %1 esta en blanco.\Rellene esta fecha para poder crear múltiples líneas.';
        glSalesDocumentDescriptionTxt: Label 'Venta %1 - %2 %3', Comment = '%1 = Source Document Type (e.g. Invoice), %2 = Due Date, %3 = Source Name (e.g. Customer Name). Example: Sales Invoice - 04-05-18 The Cannon Group PLC';
        glPurchaseDocumentDescriptionTxt: Label 'Compra %1 - %2 %3', Comment = '%1 = Source Document Type (e.g. Invoice), %2 = Due Date, %3 = Source Name (e.g. Vendor Name). Example: Purchase Invoice - 04-05-18 The Cannon Group PLC';
        glServiceDocumentDescriptionTxt: Label 'Servicio %1 - %2 %3', Comment = '%1 = Source Document Type (e.g. Invoice), %2 = Due Date, %3 = Source Name (e.g. Customer Name). Example: Service Invoice - 04-05-18 The Cannon Group PLC';
        glTaxForMsg: Label 'Impuestos desde %1', Comment = '%1 = The description of the source tyoe based on which taxes are calculated.';
        gdDummyDate: Date;
        giTaxLastSourceTableNumProcessed: Integer;
        gdTaxLastPayableDateProcessed: Date;
        glAzureAIForecastDescriptionTxt: Label '%1 previsto en el período que comienza el %2 con una precisión de +/-  %3.', Comment = '%1 =RECEIVABLES or PAYABLES or PAYABLES TAX or RECEIVABLES TAX, %2 = Date; %3 Percentage';
        glAzureAIForecastTaxDescriptionTxt: Label 'Impuesto previsto sobre %1 en el período que comienza en %2 con precisión de +/-  %3.', Comment = '%1 =RECEIVABLES or PAYABLES, %2 = Date; %3 Percentage';
        glAzureAICorrectionDescriptionTxt: Label 'Corrección vencido a registro %1', Comment = '%1 = SALES ORDERS or PURCHASE ORDERS';
        glAzureAICorrectionTaxDescriptionTxt: Label 'Corrección del importe del impuesto adeudado %1', Comment = '%1 = RECEIVABLES or PAYABLES';
        glAzureAIOrdersCorrectionDescriptionTxt: Label 'Corrección vencido a %1', Comment = '%1 = SALES or PURCHASE';
        glAzureAIOrdersTaxCorrectionDescriptionTxt: Label 'Corrección del monto del impuesto debido a %1', Comment = '%1 = SALES ORDERS or PURCHASE ORDERS';
        glXRECEIVABLESTxt: Label 'COBROS', Locked = true;
        glXPAYABLESTxt: Label 'PAGOS', Locked = true;
        glXPAYABLESCORRECTIONTxt: Label 'Corrección Cobros';
        glXRECEIVABLESCORRECTIONTxt: Label 'Corrección Pagos';
        glXSALESORDERSTxt: Label 'Pedidos Venta';
        glXPURCHORDERSTxt: Label 'Pedidos Compra';
        glXTAglXPAYABLESTxt: Label 'Impuestos a devolver', Locked = true;
        glXTAglXRECEIVABLESTxt: Label 'Impuestos a pagar', Locked = true;
        glXTAglXPAYABLESCORRECTIONTxt: Label 'Impuestos de movimientos de compra';
        glXTAglXRECEIVABLESCORRECTIONTxt: Label 'Impuestos de movimientos de venta';
        glXTAglXSALESORDERSTxt: Label 'Impuestos de pedidos de venta';
        glXTAglXPURCHORDERSTxt: Label 'Impuestos de pedidos de compra';
        gdDueDateD: Date;
        gdDueDateF: Date;
        gTempCashFlowForecast: Record "Cash Flow Forecast" temporary;
        gPurchaseHeader: Record "Purchase Header";
        gVatEntry: Record "VAT Entry";

    trigger OnRun()
    // carga inicial;
    var
        lGLBudgetEntry: Record "G/L Budget Entry";
        lInvestmentFixedAsset: Record "Fixed Asset";
        lSaleFixedAsset: Record "Fixed Asset";
        lPurchaseLine: Record "Purchase Line";
        lSalesLine: Record "Sales Line";
        lServiceLine: Record "Sales Line";
        lJobPlanningLine: Record "Job Planning Line";
        lCashFlowAzureAIBuffer: Record "Cash Flow Azure AI Buffer";
        lCashEntry: Record "Cash Flow Forecast Entry";
        lCashFlowWorksheetLine: Record "Cash Flow Worksheet Line";
    begin


        gCFSetup.Get();
        gGLSetup.Get();
        gSalesSetup.Get();
        gPurchSetup.Get();
        gServSetup.Get();
        gdDuedateD := CalcDate('PM+1D-1M', Today);
        gBArrayConsiderSource[gESourceType::"Liquid Funds".AsInteger()] := true;
        gBArrayConsiderSource[gESourceType::Receivables.AsInteger()] := true;
        gBArrayConsiderSource[gESourceType::Payables.AsInteger()] := true;
        if gBArrayConsiderSource[gESourceType::"Purchase Orders".AsInteger()] then
            gBArrayConsiderSource[gESourceType::"Purchase Orders".AsInteger()] := lPurchaseLine.ReadPermission;
        if gBArrayConsiderSource[gESourceType::"Sales Orders".AsInteger()] then
            gBArrayConsiderSource[gESourceType::"Sales Orders".AsInteger()] := lSalesLine.ReadPermission;
        gBArrayConsiderSource[gESourceType::"Cash Flow Manual EXPense".AsInteger()] := true;
        gBArrayConsiderSource[gESourceType::"Cash Flow Manual Revenue".AsInteger()] := true;
        if gBArrayConsiderSource[gESourceType::"Fixed Assets Budget".AsInteger()] then
            gBArrayConsiderSource[gESourceType::"Fixed Assets Budget".AsInteger()] := lInvestmentFixedAsset.ReadPermission;
        if gBArrayConsiderSource[gESourceType::"Fixed Assets Disposal".AsInteger()] then
            gBArrayConsiderSource[gESourceType::"Fixed Assets Disposal".AsInteger()] := lSaleFixedAsset.ReadPermission;
        if gBArrayConsiderSource[gESourceType::"G/L Budget".AsInteger()] then
            gBArrayConsiderSource[gESourceType::"G/L Budget".AsInteger()] := lGLBudgetEntry.ReadPermission;
        if gBArrayConsiderSource[gESourceType::"Service Orders".AsInteger()] then
            gBArrayConsiderSource[gESourceType::"Service Orders".AsInteger()] := lServiceLine.ReadPermission;
        if gBArrayConsiderSource[gESourceType::Job.AsInteger()] then
            gBArrayConsiderSource[gESourceType::Job.AsInteger()] := lJobPlanningLine.ReadPermission;
        if gBArrayConsiderSource[gESourceType::Tax.AsInteger()] then
            gBArrayConsiderSource[gESourceType::Tax.AsInteger()] := gSalesHeader.ReadPermission and
                gPurchaseHeader.ReadPermission and gVATEntry.ReadPermission;
        if gBArrayConsiderSource[gESourceType::"Azure AI".AsInteger()] then
            gBArrayConsiderSource[gESourceType::"Azure AI".AsInteger()] := lCashFlowAzureAIBuffer.ReadPermission;
        gBArrayConsiderSource[gESourceType::"Cartera Clientes".AsInteger()] := true;
        gBArrayConsiderSource[gESourceType::"Cartera Clientes Registrada".AsInteger()] := true;
        gBArrayConsiderSource[gESourceType::"Cartera Proveedores".AsInteger()] := true;
        gBArrayConsiderSource[gESourceType::"Cartera Proveedores Registrada".AsInteger()] := true;
        gBArrayConsiderSource[gESourceType::"Detalle Préstamos".AsInteger()] := true;
        gBArrayConsiderSource[gESourceType::"Rentings".AsInteger()] := true;
        gBArrayConsiderSource[gESourceType::"Movimientos emplazamientos".AsInteger()] := true;
        ////
        gdDummyDate := Today;
        gdDuedateD := CalcDate('PM+1D-1M', Today);
        gdDuedateF := CalcDate('PA', Today);
        //"Cash Flow Forecast".SetRange("No.", gCCashFlowNo);
        giLineNo := 0;
        gBNeedsManualPmtUpdate := false;
        gCashFlowForecast.FindFirst();
        gCCashFlowNo := gCashFlowForecast."No.";
        if gBArrayConsiderSource[gESourceType::"Liquid Funds".AsInteger()] then
            CashFlowAcount();
        if gBArrayConsiderSource[gESourceType::"Cartera Clientes".AsInteger()] then begin
            CarteraDoc();
            Commit();
        end;
        if gBArrayConsiderSource[gESourceType::"Cartera Clientes Registrada".AsInteger()] then begin
            PostedCarteraDoc();
            Commit;
        end;
        if gBArrayConsiderSource[gESourceType::Receivables.AsInteger()] then begin
            CustEntries();
            Commit();
        end;
        if gBArrayConsiderSource[gESourceType::"Cartera Proveedores".AsInteger()] then begin
            CarteraProv();
            Commit();
        end;
        if gBArrayConsiderSource[gESourceType::"Cartera Proveedores Registrada".AsInteger()] then begin
            PostedCarteraDocProv();
            Commit();
        end;
        if gBArrayConsiderSource[gESourceType::Payables.AsInteger()] then begin
            VendorEntries();
            Commit();
        end;
        if (gBArrayConsiderSource[gESourceType::"Purchase Orders".AsInteger()]) and
        (gcApplicationAreaMgmtFacade.IsSuiteEnabled) and
         (not gcApplicationAreaMgmtFacade.IsAllDisabled) then
            PurchaseLines();
        if gBArrayConsiderSource[gESourceType::"Sales Orders".AsInteger()] then
            SalesLines();
        if gBArrayConsiderSource[gESourceType::"Fixed Assets Budget".AsInteger()] then
            if gBArrayConsiderSource[gESourceType::"Fixed Assets Disposal".AsInteger()] then
                SaleFixedAsset();
        if gBArrayConsiderSource[gESourceType::"Cash Flow Manual EXPense".AsInteger()] then
            CashFlowManualExpense();
        if gBArrayConsiderSource[gESourceType::"Cash Flow Manual Revenue".AsInteger()] then
            CashFlowManualRevenue();
        if gBArrayConsiderSource[gESourceType::"G/L Budget".AsInteger()] then
            CFAccountForBudget();
        if gBArrayConsiderSource[gESourceType::"Service Orders".AsInteger()] then
            ServiceLines();
        if (gBArrayConsiderSource[gESourceType::Job.AsInteger()]) and (gcApplicationAreaMgmtFacade.IsJobsEnabled) and (gcApplicationAreaMgmtFacade.IsAllDisabled) then
            CJobPlanningLines();
        if (gBArrayConsiderSource[gESourceType::Tax.AsInteger()]) and (gcApplicationAreaMgmtFacade.IsSuiteEnabled) and (gcApplicationAreaMgmtFacade.IsAllDisabled) then begin
            gcCashFlowManagement.SetViewOnPurchaseHeaderForTaxCalc(gPurchaseHeader, gdDummyDate);
            PurchaseVatHeader();
        end;
        if gBArrayConsiderSource[gESourceType::Tax.AsInteger()] then begin
            gcCashFlowManagement.SetViewOnSalesHeaderForTaxCalc(gSalesHeader, gdDummyDate);
            SalesVatHeader();
        end;
        if gBArrayConsiderSource[gESourceType::Tax.AsInteger()] then begin
            gcCashFlowManagement.SetViewOnVATEntryForTaxCalc(gVATEntry, gdDummyDate);
            VatEntry();
        end;
        if gBArrayConsiderSource[gESourceType::"Azure AI".AsInteger()] then
            if gcCashFlowForecastHandler.CalculateForecast then
                Azure();
        if gBArrayConsiderSource[gESourceType::"Detalle Préstamos".AsInteger()] then
            DetallePrestamos();
        if gBArrayConsiderSource[gESourceType::Rentings.AsInteger()] then
            DetalleRenting();
        if gBArrayConsiderSource[gESourceType::"Detalle Préstamos".AsInteger()] then
            MovEmplazamientos();
        InsertWorksheetLines(gTempCashFlowForecast);
        DeleteEntries(gTempCashFlowForecast);
        if gBNeedsManualPmtUpdate then
            Message(glManualPmtRevEglXPNeedsUpdateMsg, gTempCashFlowForecast."No.");
        commit;
        lCashEntry.DeleteAll();
        lCashFlowWorksheetLine.Reset;
        // CODEUNIT.Run(CODEUNIT::"Cash Flow Wksh. - Register", "Cash Flow Worksheet Line");
        CODEUNIT.Run(CODEUNIT::"Cash Flow Wksh.-Register Batch", lCashFlowWorksheetLine);
    end;

    /// <summary>
    /// CashFlowAcount.
    /// </summary>
    procedure CashFlowAcount()
    var
        lGLAcc: Record "G/L Account";
        lTempGLAccount: Record "G/L Account" temporary;
        ldvtoanterior: Date;
        ldDesdeFecha2: Date;
        ldDesdeFecha: Date;
        lfDiaPago: DateFormula;
        lGlEntry: Record "G/L Entry";
        ldHastaFecha: Date;
        ldvtoDummyDate: Date;
        liDia: Integer;
        lBank: Record "Bank Account";
        lCf: Record "Cash Flow Account";
        llText1140013: Label 'Saldo %1=%2';
        lbSalta: Boolean;
        lCasFlowAccount: Record "Cash Flow Account";
    begin
        lCasFlowAccount.SetFilter("G/L Integration", '%1|%2', lCasFlowAccount."G/L Integration"::Balance, lCasFlowAccount."G/L Integration"::Both);
        lCasFlowAccount.Setfilter("G/L Account Filter", '<>%1', '');

        if lCasFlowAccount.FindFirst() Then
            Repeat

                gLiqAccT.GET(lCasFlowAccount."No.");
                if True Then begin
                    //gLiqAcc."G/L Integration" IN [gLiqAcc."G/L Integration"::Balance, gLiqAcc."G/L Integration"::Both] THEN BEGIN
                    lTempGLAccount.DeleteAll();
                    lGLAcc.SetFilter("No.", lCasFlowAccount."G/L Account Filter");
                    GetSubPostingGLAccounts(lGLAcc, lTempGLAccount);

                    if lTempGLAccount.FindSet() then
                        repeat
                            lBSalta := false;
                            lTempGLAccount.SETRANGE("Date Filter", 0D, 29991231D);
                            if lCasFlowAccount."Calcular vto. Cuenta" = 'M' THEN
                                lTempGLAccount.SETRANGE("Date Filter", CALCDATE('PM+1D-2M', gdDummyDate), CALCDATE('PM+1D-2M+PM', gdDummyDate));
                            // Calcula del del 1 del mes anterior a gdDummyDate Hasta Final del Mes anterior a Post date
                            if lCasFlowAccount."Calcular vto. Cuenta" = 'T' THEN
                                lTempGLAccount.SETRANGE("Date Filter", CALCDATE('PT+1D-2T', gdDummyDate), CALCDATE('PT+1D-2T+PT', gdDummyDate));
                            // Calcula del del 1 del trimeste anterior a gdDummyDate Hasta Final del Trimestre anterior a Post date
                            lTempGLAccount.CALCFIELDS("Net Change", Balance);
                            //TempGLAccount.CalcFields(Balance);
                            lGlEntry.Reset();
                            lGlEntry.SETCURRENTKEY("G/L Account No.", "Posting Date");
                            lGlEntry.SETFILTER(lGlEntry."G/L Account No.", '%1', lTempGLAccount."No." + '*');
                            //Window.Update(2, Text004);
                            //Window.Update(3, TempGLAccount."No.");

                            WITH gCFWorksheetLine2 DO BEGIN
                                INIT;
                                liDia := 0;
                                ldvtoDummyDate := gdDummyDate;
                                ldHastaFecha := gdDummyDate;
                                if lCasFlowAccount."Calcular vto. Cuenta" <> '' THEN BEGIN
                                    if lCasFlowAccount."Calcular vto. Cuenta" = 'T' THEN BEGIN
                                        ldHastaFecha := CALCDATE('PT+1D-2T+PT', gdDummyDate);
                                        // Final Trimestre anterior
                                        ldDesdeFecha := CALCDATE('-1T+PM+1D', ldHastaFecha);
                                        // Principo trimestre anterior
                                        if DATE2DMY(ldHastaFecha, 2) = 12 THEN
                                            ldvtoDummyDate := CALCDATE(lCasFlowAccount."Vto enero", CALCDATE('1D', ldHastaFecha))
                                        // En diciembre el vencimiento es 1 dia más que el calculado como vto enero
                                        ELSE
                                            ldvtoDummyDate := CALCDATE(lCasFlowAccount."Vto Resto Año", CALCDATE('1D', ldHastaFecha));
                                        // El resto del año el vencimiento es 1 dia más que el calculado como vto resto año
                                    END;
                                    if lCasFlowAccount."Calcular vto. Cuenta" = 'M' THEN BEGIN
                                        ldHastaFecha := CALCDATE('PM+1D-2M+PM', gdDummyDate);
                                        //Final mes anterior
                                        ldDesdeFecha := CALCDATE('-1M+PM+1D', ldHastaFecha);
                                        //Principio mes anterior
                                        //        ldDesdeFecha:=CALCDATE('-1M+PM',ldHastaFecha);
                                        if DATE2DMY(ldHastaFecha, 2) = 12 THEN
                                            ldvtoDummyDate := CALCDATE(lCasFlowAccount."Vto enero", CALCDATE('1D', ldHastaFecha))
                                        // En diciembre el vencimiento es 1 dia más que el calculado como vto enero
                                        ELSE
                                            ldvtoDummyDate := CALCDATE(lCasFlowAccount."Vto Resto Año", CALCDATE('1D', ldHastaFecha));
                                        // El resto del año el vencimiento es 1 dia más que el calculado como vto resto año
                                    END;
                                END;
                                ldvtoanterior := ldvtoDummyDate;

                                if gdDummyDate > ldvtoDummyDate THEN BEGIN
                                    lGlEntry.SETRANGE("Posting Date", CALCDATE(lCasFlowAccount."Vto enero", gdDummyDate), 99991231D);
                                    if lCasFlowAccount."Calcular vto. Cuenta" = 'T' THEN
                                        lGlEntry.SETRANGE("Posting Date", CALCDATE('PT+1D-1T', gdDummyDate), 99991231D);
                                    if lCasFlowAccount."Calcular vto. Cuenta" = 'M' THEN
                                        lGlEntry.SETRANGE("Posting Date", CALCDATE('PM+1D-1M', gdDummyDate), 99991231D);
                                    lGlEntry.SETRANGE("Pago Impuestos", TRUE);
                                    if NOT lGlEntry.FINDLAST THEN BEGIN
                                        ldvtoDummyDate := gdDummyDate;
                                    END;
                                END;

                                if gdDummyDate > ldvtoDummyDate THEN BEGIN
                                    lGlEntry.SETRANGE("Posting Date", CALCDATE(lCasFlowAccount."Vto enero", gdDummyDate), 99991231D);
                                    lGlEntry.SETRANGE("Pago Impuestos", TRUE);
                                    if lGlEntry.FINDLAST THEN lBSalta := true;// Exit;
                                                                              // Si la fecha de calculo es mayor que la fecha de vencimientio se va al trimestre o mes en curso
                                    if lCasFlowAccount."Calcular vto. Cuenta" <> '' THEN BEGIN
                                        if lCasFlowAccount."Calcular vto. Cuenta" = 'T' THEN BEGIN
                                            ldHastaFecha := CALCDATE('PT+1D-1T+PT', gdDummyDate);
                                            // Final Trimestre
                                            ldDesdeFecha := CALCDATE('-1T+PM+1D', ldHastaFecha);
                                            // Principo Trimestre
                                            if DATE2DMY(ldHastaFecha, 2) = 12 THEN
                                                ldvtoDummyDate := CALCDATE(lCasFlowAccount."Vto enero", CALCDATE('1D', ldHastaFecha))
                                            ELSE
                                                ldvtoDummyDate := CALCDATE(lCasFlowAccount."Vto Resto Año", CALCDATE('1D', ldHastaFecha));
                                        END;

                                    END;
                                    if lCasFlowAccount."Calcular vto. Cuenta" = 'M' THEN BEGIN
                                        ldHastaFecha := CALCDATE('PM+1D-1M+PM', gdDummyDate);
                                        //Fin mes
                                        ldDesdeFecha := CALCDATE('-1M+PM+1D', ldHastaFecha);
                                        //Principio mes
                                        if DATE2DMY(ldHastaFecha, 2) = 12 THEN
                                            ldvtoDummyDate := CALCDATE(lCasFlowAccount."Vto enero", CALCDATE('1D', ldHastaFecha))
                                        ELSE
                                            ldvtoDummyDate := CALCDATE(lCasFlowAccount."Vto Resto Año", CALCDATE('1D', ldHastaFecha));
                                    END;
                                    ldvtoanterior := ldvtoDummyDate;
                                END ELSE BEGIN
                                    ldDesdeFecha2 := ldDesdeFecha;
                                    if (lCasFlowAccount."Calcular vto. Cuenta" <> '') THEN BEGIN
                                        if lCasFlowAccount."Calcular vto. Cuenta" = 'T' THEN
                                            ldDesdeFecha2 := CALCDATE('PT+1D-1T+5D', gdDummyDate)
                                        ELSE
                                            ldDesdeFecha2 := CALCDATE('PM+1D-1M+5D', gdDummyDate);
                                    END;
                                    lGlEntry.SETRANGE("Posting Date", ldDesdeFecha2, gdDummyDate);
                                    lGlEntry.SETRANGE("Pago Impuestos", TRUE);
                                    // Si la fecha de calculo es mayor que la fecha de vencimientio se va al trimestre o mes en curso
                                    if (lCasFlowAccount."Calcular vto. Cuenta" <> '') AND (lGlEntry.FINDLAST) THEN BEGIN
                                        if lCasFlowAccount."Calcular vto. Cuenta" = 'T' THEN BEGIN
                                            ldHastaFecha := CALCDATE('PT', gdDummyDate);
                                            // Final Trimestre
                                            ldDesdeFecha := CALCDATE('-1T+PT+1D', ldHastaFecha);
                                            // Principo Trimestre
                                            if DATE2DMY(ldHastaFecha, 2) = 12 THEN
                                                ldvtoDummyDate := CALCDATE(lCasFlowAccount."Vto enero", CALCDATE('1D', ldHastaFecha))
                                            ELSE
                                                ldvtoDummyDate := CALCDATE(lCasFlowAccount."Vto Resto Año", CALCDATE('1D', ldHastaFecha));
                                        END;
                                        if lCasFlowAccount."Calcular vto. Cuenta" = 'M' THEN BEGIN
                                            ldHastaFecha := CALCDATE('PM', gdDummyDate);
                                            //Fin mes
                                            ldDesdeFecha := CALCDATE('-1M+PM+1D', ldHastaFecha);
                                            //Principio mes
                                            if DATE2DMY(ldHastaFecha, 2) = 12 THEN
                                                ldvtoDummyDate := CALCDATE(lCasFlowAccount."Vto enero", CALCDATE('1D', ldHastaFecha))
                                            ELSE
                                                ldvtoDummyDate := CALCDATE(lCasFlowAccount."Vto Resto Año", CALCDATE('1D', ldHastaFecha));
                                        END;
                                        ldvtoanterior := ldvtoDummyDate;
                                    END;


                                    //    if "No."='476000001' THEN ERROR('%1 %2 %3 %4',DummyDate,ldvtoDummyDate,ldHastaFecha,ldDesdeFecha);
                                    lGlEntry.SETRANGE("Posting Date", ldDesdeFecha, ldHastaFecha);
                                    lGlEntry.SETRANGE("Pago Impuestos");
                                    lGlEntry.SETRANGE("Posting Date", 0D, ldHastaFecha);
                                    lGlEntry.SETFILTER(Banco, '<>%1', '');
                                    lCasFlowAccount."Source Type" := lCasFlowAccount."Source Type"::" ";
                                    lCasFlowAccount."Account Type" := lCasFlowAccount."Account Type"::Entry;
                                    gCFWorksheetLine2."Source Type" := gCFWorksheetLine2."Source Type"::"Liquid Funds";
                                    gCFWorksheetLine2."Source No." := lTempGLAccount."No.";
                                    "Document No." := lTempGLAccount."No.";
                                    gCFWorksheetLine2."Cash Flow Account No." := lCasFlowAccount."No.";
                                    //lCasFlowAccount.RESET;
                                    if lGlEntry.FINDLAST THEN
                                        lCasFlowAccount."Cod banco" := lGlEntry.Banco;
                                    gLiqAcc.Reset();
                                    if gLiqAcc.GET(lCasFlowAccount."No.") THEN BEGIN
                                        if TRUE THEN BEGIN
                                            gLiqAcc.SETRANGE(gLiqAcc."Vinculado a noº", lCasFlowAccount."No.");
                                            gLiqAcc.SETFILTER(gLiqAcc."Cod banco", '%1', lCasFlowAccount."Cod banco");
                                            gLiqAcc.SETFILTER(gLiqAcc."Banco Informes", '%1', NBanco(lCasFlowAccount."Cod banco"));
                                            if NOT gLiqAcc.FINDFIRST THEN BEGIN
                                                gLiqAcc.SETFILTER(gLiqAcc."Banco Informes", '%1', '');
                                                if NOT gLiqAcc.FINDFIRST THEN BEGIN
                                                    gLiqAcc.SETRANGE(gLiqAcc."Cod banco");
                                                    gLiqAcc.SETFILTER(gLiqAcc."Banco Informes", '%1', NBanco(lCasFlowAccount."Cod banco"));
                                                    if NOT gLiqAcc.FINDFIRST THEN BEGIN
                                                        gLiqAcc.SETRANGE(gLiqAcc."Banco Informes");
                                                        gLiqAcc.SETRANGE(gLiqAcc."No.", lCasFlowAccount."No.");
                                                    END;
                                                END;
                                            END;
                                            if gLiqAcc.FINDFIRST THEN
                                                "Cash Flow Account No." := gLiqAcc."No.";
                                            if gLiqAcc."Banco Informes" <> '' THEN
                                                "Nombre Banco" := gLiqAcc."Banco Informes"
                                            ELSE
                                                "Nombre Banco" := NBanco(lCasFlowAccount."Cod banco");
                                        END;
                                        gLiqAcc.RESET;
                                    END;
                                    //"Cod banco":=gLiqAcc."Cod banco";
                                    //ELSE
                                    ldvtoDummyDate := ldvtoanterior;
                                    Description := COPYSTR(STRSUBSTNO('%1  %2 De %3 a %4', FORMAT(lCasFlowAccount."Tipo Saldo"), lTempGLAccount."No.", FORMAT(ldDesdeFecha),
                                                        FORMAT(ldHastaFecha)), 1, MAXSTRLEN(gCFWorksheetLine2.Description));
                                    if (lCasFlowAccount."Dia de pago" <> lfDiaPago) AND (gLiqAccT."Vto Resto Año" = lfDiaPago) AND (gLiqAccT."Vto enero" = lfDiaPago) THEN
                                        "Due Date" := CALCDATE(gLiqAcc."Dia de pago", ldvtoDummyDate)
                                    ELSE
                                        "Due Date" := ldvtoDummyDate;//WORKDATE;
                                    "Cash Flow Date" := "Due Date";//WORKDATE;
                                    "Fecha Registro" := gdDummyDate;
                                    if (ldHastaFecha <> 0D) AND (lCasFlowAccount."Tipo Saldo" = lCasFlowAccount."Tipo Saldo"::"Saldo a la fecha") THEN BEGIN
                                        lTempGLAccount.SETRANGE("Date Filter", 0D, ldHastaFecha);
                                        lTempGLAccount.CALCFIELDS("Balance at Date");
                                        "Amount (LCY)" := lTempGLAccount."Balance at Date";
                                        //"Amount (Currency)" := "G/L Account"."Balance at Date";

                                    END ELSE BEGIN
                                        lTempGLAccount.CALCFIELDS("Net Change");
                                        "Amount (LCY)" := lTempGLAccount."Net Change";
                                        //"Amount (Currency)" := "G/L Account"."Net Change";
                                    END;
                                    lTempGLAccount.SETRANGE(lTempGLAccount."Date Filter");
                                    "Shortcut Dimension 2 Code" := lTempGLAccount."Global Dimension 2 Code";
                                    "Shortcut Dimension 1 Code" := lTempGLAccount."Global Dimension 1 Code";

                                    //"Gen. Bus. Posting Group" := TempGLAccount."Gen. Bus. Posting Group";
                                    //"Gen. Prod. Posting Group" := TempGLAccount."Gen. Prod. Posting Group";
                                    if "Amount (LCY)" <> 0 THEN BEGIN
                                        if not lbSalta Then
                                            InsertLiqLine();
                                        // Transfer Dimensions
                                        // DefaultDim.RESET;
                                        // DefaultDim.SETRANGE("Table ID",DATABASE::"G/L Account");
                                        // DefaultDim.SETRANGE("No.","G/L Account"."No.");
                                        // LiqDimMgt.MoveDefaultDimToJnlLineDim(DefaultDim,JnlLineDim,DATABASE::"Liq. Journal Line",LiqLine."Journal Template Name",
                                        //                                     LiqLine."Journal Batch Name",LiqLine."Line No.",0);
                                    END;
                                    //InsertCFLineForGLAccount(TempGLAccount);
                                end;
                            end;
                        until lTempGLAccount.Next() = 0;
                end;
            until lCasFlowAccount.Next() = 0;
        lCasFlowAccount.SetRange("G/L Account Filter");
        lCasFlowAccount.Setrange("Source Type", lCasFlowAccount."Source Type"::"Liquid Funds");
        if lCasFlowAccount.FindFirst() then
            repeat
                //if lCasFlowAccount."Source Type" = lCasFlowAccount."Source Type"::"Liquid Funds" then begin
                if lCasFlowAccount."Banco Informes" <> '' Then begin
                    lBank.Reset();
                    lBank.SetRange("Name 2", lCasFlowAccount."Banco Informes");
                end else begin
                    lBank.Reset();
                    lBank.SetFilter("No.", lCasFlowAccount."Cod banco");
                    // if Bank.FindFirst() Then begin
                    //     Cf.SetRange("Source Type", Cf."Source Type"::"Liquid Funds");
                    //     Cf.SetRange("Banco Informes", Bank."Name 2");
                    //     if Cf.FindFirst() then begin
                    //         Bank.SetRange("No.", '-1');
                    //     end;
                    // end;
                end;
                if lBank.FindFirst() Then begin

                    lBank.CALCFIELDS(Balance);


                    WITH gCFWorksheetLine2 DO BEGIN
                        INIT;
                        "Source Type" := "Source Type"::"Liquid Funds";
                        //"Source Type" := "Source Type"::
                        "Source No." := lBank."No.";
                        "Document No." := lBank."No.";
                        "Cod banco" := lBank."No.";
                        "Associated Entry No." := 0;
                        if lCasFlowAccount."Banco Informes" <> '' THEN
                            "Nombre Banco" := lCasFlowAccount."Banco Informes"
                        ELSE
                            "Nombre Banco" := NBanco("Cod banco");
                        "Es Cartera" := TRUE;
                        "Cash Flow Account No." := lCasFlowAccount."No.";
                        Description := COPYSTR(STRSUBSTNO(llText1140013, lBank.Name, FORMAT(lBank.Balance)),
                                            1, MAXSTRLEN(gCFWorksheetLine2.Description));
                        "Due Date" := gdDummyDate;//WORKDATE;
                        gCFWorksheetLine2."Cash Flow Date" := gdDummyDate;//WORKDATE;
                        "Amount (LCY)" := lBank.Balance;
                        //"Amount (Currency)" := Bank.Balance;
                        "Shortcut Dimension 2 Code" := lBank."Global Dimension 2 Code";
                        "Shortcut Dimension 1 Code" := lBank."Global Dimension 1 Code";
                        //"Gen. Bus. Posting Group" := '';//"G/L Account"."Gen. Bus. Posting Group";
                        //"Gen. Prod. Posting Group" :='';// "G/L Account"."Gen. Prod. Posting Group";
                        if "Amount (LCY)" <> 0 THEN BEGIN
                            InsertLiqLine();
                            // Transfer Dimensions
                            // DefaultDim.RESET;
                            // DefaultDim.SETRANGE("Table ID",DATABASE::Bank);
                            // DefaultDim.SETRANGE("No.",Bank."No.");
                            // LiqDimMgt.MoveDefaultDimToJnlLineDim(DefaultDim,JnlLineDim,DATABASE::"Liq. Journal Line",LiqLine."Journal Template Name",
                            //                                     LiqLine."Journal Batch Name",LiqLine."Line No.",0);
                        END;

                    end;
                end;
            // end;
            until lCasFlowAccount.next() = 0;


    end;

    /// <summary>
    /// CarteraDoc.
    /// </summary>
    /// <summary>
    /// CarteraDoc.
    /// </summary>
    procedure CarteraDoc()
    var
        lCarteraDoc: Record "Cartera Doc.";
    begin
        lCarteraDoc.SetFilter("Remaining Amount", '<>%1', 0);
        lCarteraDoc.SetRange(Type, lCarteraDoc.Type::Receivable);
        if lCarteraDoc.FindFirst() then
            repeat
                if lCarteraDoc."Account No." <> '' THEN
                    gCustomer.GET(lCarteraDoc."Account No.")
                ELSE
                    gCustomer.INIT;


                if gdDuedateF <> 0D THEN
                    if not (lCarteraDoc."Due Date" > CALCDATE('181D', WORKDATE)) THEN
                        InsertCFLineForCartera(lCarteraDoc);
            until lCarteraDoc.Next() = 0;

    end;

    /// <summary>
    /// PostedCarteraDoc.
    /// </summary>
    procedure PostedCarteraDoc()
    var
        lPostedCarteraDoc: Record "Posted Cartera Doc.";

    begin
        lPostedCarteraDoc.SetFilter("Remaining Amount", '<>%1', 0);
        lPostedCarteraDoc.SetRange(Type, lPostedCarteraDoc.Type::Receivable);
        if lPostedCarteraDoc.FindFirst() then
            repeat

                if lPostedCarteraDoc."Account No." <> '' THEN
                    gCustomer.GET(lPostedCarteraDoc."Account No.")
                ELSE
                    gCustomer.INIT;


                if gdDuedateF <> 0D THEN
                    if not (lPostedCarteraDoc."Due Date" > CALCDATE('181D', WORKDATE)) THEN
                        InsertCFLineForPostedCartera(lPostedCarteraDoc);
            until lPostedCarteraDoc.Next() = 0;

    end;

    /// <summary>
    /// CustEntries.
    /// </summary>
    procedure CustEntries()
    var
        lCustLedgerEntry: Record "Cust. Ledger Entry";
    begin
        lCustLedgerEntry.SetRange(Open, true);
        lCustLedgerEntry.SetFilter("Remaining Amount", '<>%1', 0);
        if lCustLedgerEntry.FindFirst() then
            repeat
                if (lCustLedgerEntry."Nº Factura Borrador" = '')
                Or (lCustLedgerEntry."Document Type" = lCustLedgerEntry."Document Type"::Payment) THEN begin
                    if lCustLedgerEntry."Customer No." <> '' then
                        gCustomer.Get(lCustLedgerEntry."Customer No.")
                    else
                        gCustomer.Init();

                    if lCustLedgerEntry."Due Date" < gdDuedateD THEN gbAtrasado := TRUE ELSE gbAtrasado := FALSE;
                    if gdDuedateF <> 0D THEN
                        if not (lCustLedgerEntry."Due Date" > CALCDATE('181D', WORKDATE)) THEN begin
                            lCustLedgerEntry.CalcFields("Remaining Amt. (LCY)", "Remaining Amount");

                            InsertCFLineForCustLedgerEntry(lCustLedgerEntry);
                        end;
                end;
            until lCustLedgerEntry.Next() = 0;


    end;

    Procedure CarteraProv()
    var
        lCarteraDoc: Record "Cartera Doc.";
    begin
        lCarteraDoc.SetFilter("Remaining Amount", '<>%1', 0);
        lCarteraDoc.Setrange(Type, lCarteraDoc.Type::Payable);
        if lCarteraDoc.FindFirst() Then
            repeat



                if gdDuedateF <> 0D THEN
                    if Not (lCarteraDoc."Due Date" > CALCDATE('181D', WORKDATE)) THEN
                        InsertPFLineForCartera(lCarteraDoc);
            until lCarteraDoc.next = 0;
    end;

    Procedure PostedCarteraDocProv()
    var
        lPostedCarteraDoc: Record "Posted Cartera Doc.";
    begin
        lPostedCarteraDoc.SetFilter("Remaining Amount", '<>%1', 0);
        lPostedCarteraDoc.Setrange(Type, lPostedCarteraDoc.Type::Payable);
        if lPostedCarteraDoc.FindFirst() Then
            repeat


                if gdDuedateF <> 0D THEN
                    if not (lPostedCarteraDoc."Due Date" > CALCDATE('181D', WORKDATE)) THEN
                        InsertPFLineForPostedCartera(lPostedCarteraDoc);
            until lPostedCarteraDoc.Next = 0;
    end;

    Procedure VendorEntries()
    var
        lVendorLedgerEntry: Record "Vendor Ledger Entry";
    begin
        lVendorLedgerEntry.Setrange(Open, true);
        lVendorLedgerEntry.setfilter("Remaining Amount", '<>%1', 0);
        if lVendorLedgerEntry.FindFirst() Then
            repeat
                if gdDuedateF <> 0D THEN
                    if not (lVendorLedgerEntry."Due Date" > gdDuedateF) THEN Begin
                        if lVendorLedgerEntry."Due Date" < gdDuedateD THEN gbAtrasado := TRUE ELSE gbAtrasado := FALSE;

                        lVendorLedgerEntry.CalcFields("Remaining Amt. (LCY)", "Remaining Amount");

                        InsertCFLineForVendorLedgEntry(lVendorLedgerEntry);
                    end;
            until lVendorLedgerEntry.next() = 0;
    end;

    Procedure PurchaseLines()
    var
        lPurchaseLine: Record "Purchase Line";
    begin
        lPurchaseLine.SetRange("Document Type", lPurchaseLine."Document Type"::Order);
        if lPurchaseLine.FindFirst() Then
            Repeat

                gPurchHeader.Get(lPurchaseLine."Document Type", lPurchaseLine."Document No.");


                InsertCFLineForPurchaseLine(lPurchaseLine);
            until lPurchaseLine.next() = 0;
    end;

    Procedure SalesLines()
    var
        lSalesLine: Record "Sales Line";
    begin
        lSalesLine.SetRange("Document Type", lSalesLine."Document Type"::Order);
        if lSalesLine.FindFirst() Then
            Repeat

                gSalesHeader.Get(lSalesLine."Document Type", lSalesLine."Document No.");
                if gSalesHeader."Sell-to Customer No." <> '' then
                    gCustomer.Get(gSalesHeader."Bill-to Customer No.")
                else
                    gCustomer.Init();

                InsertCFLineForSalesLine(lSalesLine);
            until lSalesLine.Next() = 0;
    end;

    Procedure FixedAsset()
    var
        lInvestmentFixedAsset: Record "Fixed Asset";
    Begin
        gFASetup.Get();
        lInvestmentFixedAsset.Setrange("Budgeted Asset", true);
        if lInvestmentFixedAsset.findfirst then
            repeat
                if gFADeprBook.Get(lInvestmentFixedAsset."No.", gFASetup."Default Depr. Book") then begin
                    gFADeprBook.CalcFields("Acquisition Cost");
                    InsertCFLineForFixedAssetsBudget(lInvestmentFixedAsset);
                end;
            until lInvestmentFixedAsset.Next = 0;
    end;

    Procedure SaleFixedAsset()
    var
        lSaleFixedAsset: Record "Fixed Asset";
    begin
        gFASetup.Get();
        lSaleFixedAsset.Setrange("Budgeted Asset", false);
        if lSaleFixedAsset.FindFirst then
            Repeat
                if gFADeprBook.Get(lSaleFixedAsset."No.", gFASetup."Default Depr. Book") then
                    if (gFADeprBook."Disposal Date" = 0D) and
                        (gFADeprBook."Projected Disposal Date" <> 0D) and
                        (gFADeprBook."Projected Proceeds on Disposal" <> 0)
                    then begin

                        InsertCFLineForFixedAssetsDisposal(lSaleFixedAsset);
                    end;
            until lSaleFixedAsset.Next() = 0;
    end;

    /// <summary>
    /// CashFlowManualExpense.
    /// </summary>
    procedure CashFlowManualExpense()
    var
        lCashFlowManualExpense: Record "Cash Flow Manual EXPense";
    begin
        if lCashFlowManualExpense.FindFirst Then
            Repeat

                InsertCFLineForManualExpense(lCashFlowManualExpense);
            until lCashFlowManualExpense.Next = 0;
    end;

    /// <summary>
    /// CashFlowManualRevenue.
    /// </summary>
    procedure CashFlowManualRevenue()
    var
        lCashFlowManualRevenue: Record "Cash Flow Manual Revenue";
    begin
        if lCashFlowManualRevenue.Findfirst Then
            Repeat

                InsertCFLineForManualRevenue(lCashFlowManualRevenue);
            until lCashFlowManualRevenue.Next = 0;
    end;

    Procedure CFAccountForBudget()
    var
        lCFAccountForBudget: Record "Cash Flow Account";
        lGLAcc: Record "G/L Account";
    begin
        lCFAccountForBudget.Setfilter("G/L Integration", '%1|%2', lCFAccountForBudget."G/L Integration"::Budget, lCFAccountForBudget."G/L Integration"::Both);
        lCFAccountForBudget.Setfilter("G/L Account Filter", '<>51', '');
        if lCFAccountForBudget.FindFirst() Then
            Repeat
                lGLAcc.SetFilter("No.", lCFAccountForBudget."G/L Account Filter");
                if lGLAcc.FindSet() then
                    repeat
                        gGLBudgEntry.SetRange("Budget Name", gCGLBudgName);
                        gGLBudgEntry.SetRange("G/L Account No.", lGLAcc."No.");
                        gGLBudgEntry.SetRange(Date, gCashFlowForecast."G/L Budget From", gCashFlowForecast."G/L Budget To");
                        if gGLBudgEntry.FindSet() then
                            repeat
                                InsertCFLineForGLBudget(lGLAcc, lCFAccountForBudget);
                            until gGLBudgEntry.Next = 0;
                    until lGLAcc.Next = 0;
            until lCFAccountForBudget.Next = 0;
    end;

    /// <summary>
    /// ServiceLines.
    /// </summary>
    procedure ServiceLines()
    var
        lServiceLine: Record "Service Line";
    begin
        lServiceLine.Setrange("Document Type", lServiceLine."Document Type"::Order);

        if lServiceLine.FindFirst Then
            Repeat

                gServiceHeader.Get(lServiceLine."Document Type", lServiceLine."Document No.");
                if gServiceHeader."Bill-to Customer No." <> '' then
                    gCustomer.Get(gServiceHeader."Bill-to Customer No.")
                else
                    gCustomer.Init();

                InsertCFLineForServiceLine(lServiceLine);
            until lServiceLine.Next() = 0;
    end;

    Procedure CJobPlanningLines()
    var
        lJobPlanningLine: Record "Job Planning Line";
    begin
        if lJobPlanningLine.FindFirst Then
            Repeat

                if (lJobPlanningLine."Line Type" in [lJobPlanningLine."Line Type"::Billable, lJobPlanningLine."Line Type"::"Both Budget and Billable"]) then
                    InsertCFLineForJobPlanningLine(lJobPlanningLine);
            until lJobPlanningLine.Next = 0;
    end;

    Procedure PurchaseVatHeader()
    var
        lPurcaseHeader: Record "Purchase Header";

    begin
        lPurcaseHeader.Setrange("Document Type", lPurcaseHeader."Document Type"::Order);
        if lPurcaseHeader.Findfirst Then
            Repeat

                InsertCFLineForTax(DATABASE::"Purchase Header");//,"Purchase Header");
            until lPurcaseHeader.next >= 0;
    end;

    Procedure SalesVatHeader()
    var
        lSalesHeader: Record "Sales Header";

    begin
        lSalesHeader.Setrange("Document Type", lSalesHeader."Document Type"::Order);

        if lSalesHeader.findfirst then
            repeat

                InsertCFLineForTax(DATABASE::"Sales Header");//,"Salles Header");
            until lSalesHeader.next() = 0;
    end;

    Procedure VatEntry()
    Var
        lVatEntry: Record "VAT Entry";

    begin
        if lVatEntry.FindFirst() Then
            Repeat

                InsertCFLineForTax(DATABASE::"VAT Entry");//,lVatEntry);
            until lVatEntry.next = 0;
    end;

    /// <summary>
    /// Azure.
    /// </summary>
    procedure Azure()
    var
        lCashFlowAzureAIBuffer: Record "Cash Flow Azure AI Buffer";
    begin
        lCashFlowAzureAIBuffer.SetRange(Type, lCashFlowAzureAIBuffer.Type::Forecast, lCashFlowAzureAIBuffer.Type::Correction);
        if lCashFlowAzureAIBuffer.FindSet() Then
            Repeat
                InsertCFLineForAzureAIForecast(DATABASE::"Cash Flow Azure AI Buffer", lCashFlowAzureAIBuffer);
            until lCashFlowAzureAIBuffer.Next() = 0;
    end;

    Procedure DetallePrestamos()
    var
        lDetallePrestamo: Record "Detalle Prestamo";

    begin
        lDetallePrestamo.Setrange(Renting, false);
        if lDetallePrestamo.Findfirst Then
            Repeat
                InsertCfLineForPrestamos(lDetallePrestamo);
            until lDetallePrestamo.Next() = 0;
    end;

    /// <summary>
    /// DetalleRenting.
    /// </summary>
    procedure DetalleRenting()
    var
        lDetalleRenting: Record "Detalle Prestamo";

    begin
        lDetalleRenting.Setrange(Renting, true);
        if lDetalleRenting.FindFirst() Then
            repeat
                InsertCfLineForRenting(lDetalleRenting);
            until lDetalleRenting.Next() = 0;
    end;

    Procedure MovEmplazamientos()
    var
        lMovimientosEmplazamiento: Record "Mov. emplazamientos";

    begin
        if lMovimientosEmplazamiento.FindFirst() then
            repeat
                InsertCfLineForEmplazaMientos(lMovimientosEmplazamiento);
            until lMovimientosEmplazamiento.Next() = 0;
    end;




    local procedure InsertConditionMet(): Boolean
    begin
        exit(gTempCFWorksheetLine."Amount (LCY)" <> 0);
    end;

    local procedure InsertTempCFWorksheetLine(MaglXPmtTolerance: Decimal)
    begin
        with gTempCFWorksheetLine do begin
            giLineNo := giLineNo + 100;
            TransferFields(gCFWorksheetLine2);
            "Cash Flow Forecast No." := gCashFlowForecast."No.";
            "Line No." := giLineNo;
            CalculateCFAmountAndCFDate;
            SetCashFlowDate(gTempCFWorksheetLine, "Cash Flow Date");

            if Abs("Amount (LCY)") < Abs(MaglXPmtTolerance) then
                "Amount (LCY)" := 0
            else
                "Amount (LCY)" := "Amount (LCY)" - MaglXPmtTolerance;

            if InsertConditionMet then
                Insert
        end;
    end;

    local procedure InsertWorksheetLines(var TempCashFlowForecast: Record "Cash Flow Forecast" temporary)
    var
        lCFWorksheetLine: Record "Cash Flow Worksheet Line";
        lCLastCFForecastNo: Code[20];
    begin
        lCFWorksheetLine.LockTable();

        lCFWorksheetLine.Reset();
        lCFWorksheetLine.DeleteAll();

        gTempCFWorksheetLine.Reset();
        gTempCFWorksheetLine.SetCurrentKey("Cash Flow Forecast No.");
        if gTempCFWorksheetLine.FindSet() then
            repeat
                //    CFWorksheetLine.SetRange("Associated Entry No.", gTempCFWorksheetLine."Associated Entry No.");
                //if (Not CFWorksheetLine.FindFirst()) or (gTempCFWorksheetLine."Associated Entry No." = 0) Then begin
                lCFWorksheetLine := gTempCFWorksheetLine;
                lCFWorksheetLine.Insert(true);

                if lCLastCFForecastNo <> lCFWorksheetLine."Cash Flow Forecast No." then begin
                    TempCashFlowForecast."No." := lCFWorksheetLine."Cash Flow Forecast No.";
                    TempCashFlowForecast.Insert();
                    lCLastCFForecastNo := lCFWorksheetLine."Cash Flow Forecast No.";
                end;
            //        end;
            until gTempCFWorksheetLine.Next = 0;

        gTempCFWorksheetLine.DeleteAll();
    end;

    local procedure DeleteEntries(var TempCashFlowForecast: Record "Cash Flow Forecast" temporary)
    var
        lCFForecastEntry: Record "Cash Flow Forecast Entry";
    begin
        TempCashFlowForecast.Reset();
        if TempCashFlowForecast.FindSet() then begin
            lCFForecastEntry.LockTable();
            lCFForecastEntry.Reset();
            repeat
                lCFForecastEntry.SetRange("Cash Flow Forecast No.", TempCashFlowForecast."No.");
                lCFForecastEntry.DeleteAll();
            until TempCashFlowForecast.Next = 0;
        end;
        TempCashFlowForecast.DeleteAll();
    end;

    local procedure InsertCFLineForGLAccount(GLAcc: Record "G/L Account"; var pCashFlowAccount: Record "Cash Flow Account")
    begin
        with gCFWorksheetLine2 do begin
            Init();
            "Source Type" := "Source Type"::"Liquid Funds";
            "Source No." := GLAcc."No.";
            "Document No." := GLAcc."No.";
            "Cash Flow Account No." := pCashFlowAccount."No.";
            Description :=
              CopyStr(
                StrSubstNo(glText013, GLAcc.Name, Format(GLAcc.Balance)),
                1, MAXSTRLEN(Description));
            SetCashFlowDate(gCFWorksheetLine2, WorkDate);
            "Amount (LCY)" := GLAcc.Balance;
            "Shortcut Dimension 2 Code" := GLAcc."Global Dimension 2 Code";
            "Shortcut Dimension 1 Code" := GLAcc."Global Dimension 1 Code";
            MoveDefualtDimToJnlLineDim(DATABASE::"G/L Account", GLAcc."No.", "Dimension Set ID");
            InsertTempCFWorksheetLine(0);
        end;
    end;

    local procedure InsertCFLineForCustLedgerEntry(var pCustLedgerEntry: Record "Cust. Ledger Entry")
    var
        MaglXPmtTolerance: Decimal;
        Ct: Text;
        Fasctura: Record "Sales Invoice Header";
        Contrato: Record "Sales Header";
        Abono: Record "Sales Cr.Memo Header";
        Text1140019: Label '%1 %2 %3';
        EntryType: Text;
        Text1140014: Label 'Pago clte.';
        Text1140015: Label 'F.cl.';
        Text1140016: Label 'A.cl.';
        Text1140017: Label 'Doc. interés clte.';
        Text1140018: Label 'Recordatorio clte.';
        Text1140100: Label 'Efecto Cliente';
        Documentos: Record "Cartera Doc.";
        Remesas: Record "Bill Group";
        DocuemtosReg: Record "Posted Cartera Doc.";
        RemesasReg: Record "Posted Bill Group";

    begin

        if pCustLedgerEntry."Customer No." <> '' THEN
            gCustomer.GET(pCustLedgerEntry."Customer No.")
        ELSE
            gCustomer.INIT;
        if pCustLedgerEntry."Due Date" < gdDuedateD THEN gbAtrasado := TRUE ELSE gbAtrasado := FALSE;
        if gdDuedateF <> 0D THEN
            if pCustLedgerEntry."Due Date" > CALCDATE('181D', WORKDATE) THEN Exit;
        pCustLedgerEntry.CalcFields("Remaining Amt. (LCY)", "Remaining Amount");
        CASE pCustLedgerEntry."Document Type" OF
            pCustLedgerEntry."Document Type"::Payment:
                EntryType := Text1140014;
            pCustLedgerEntry."Document Type"::Invoice:
                EntryType := Text1140015;
            pCustLedgerEntry."Document Type"::"Credit Memo":
                EntryType := Text1140016;
            pCustLedgerEntry."Document Type"::"Finance Charge Memo":
                EntryType := Text1140017;
            pCustLedgerEntry."Document Type"::Reminder:
                EntryType := Text1140018;
            pCustLedgerEntry."Document Type"::Bill:
                EntryType := Text1140100;
            ELSE
                EntryType := '';
        END;
        with gCFWorksheetLine2 do begin
            INIT;
            "Source Type" := "Source Type"::Receivables;
            "Shortcut Dimension 2 Code" := pCustLedgerEntry."Global Dimension 2 Code";
            "Shortcut Dimension 1 Code" := pCustLedgerEntry."Global Dimension 1 Code";
            //"Gen. Bus. Posting Group" := gCustomer."Gen. Bus. Posting Group";
            Anotaciones(pCustLedgerEntry."Customer No.", False, "Anotación", "Fecha Anotacion");
            "Source No." := pCustLedgerEntry."Customer No.";
            "Document No." := pCustLedgerEntry."Document No.";
            "Document Type" := pCustLedgerEntry."Document Type";
            //"Source Code" := pCustLedgerEntry."Source Code";
            //"Account Type" := gCFWorksheetLine2."Account Type"::Customer;
            //"Account Number" := pCustLedgerEntry."Customer No.";
            "Shortcut Dimension 2 Code" := pCustLedgerEntry."Global Dimension 2 Code";
            "Shortcut Dimension 1 Code" := pCustLedgerEntry."Global Dimension 1 Code";
            "Dimension Set ID" := pCustLedgerEntry."Dimension Set ID";
            gCFSetup.Get();
            "Cash Flow Account No." := gCFSetup."Receivables CF Account No.";
            //"Cash Flow Account No." := LiqSetup."Receivables Liq. Account No.";
            gLiqAcc.GET("Cash Flow Account No.");
            Ct := '';
            if Fasctura.GET("Document No.") THEN BEGIN
                if Contrato.GET(Contrato."Document Type"::Order, Fasctura."Nº Contrato") THEN
                    Ct := Contrato."No.";
            END;
            if Abono.GET("Document No.") THEN BEGIN
                if Contrato.GET(Contrato."Document Type"::Order, Abono."Nº Contrato") THEN
                    Ct := Contrato."No.";

            END;
            gCFWorksheetLine2.Description := COPYSTR(STRSUBSTNO(Text1140019, EntryType + ' ' + Ct,
                                                     FORMAT(pCustLedgerEntry."Posting Date"),
                                                     gCustomer.Name), 1, MAXSTRLEN(gCFWorksheetLine2.Description));
            "Due Date" := CalcFecha(pCustLedgerEntry."Due Date");
            "Fecha Registro" := CalcFechaL(pCustLedgerEntry."Due Date");
            "Cash Flow Date" := "Due Date";
            if pCustLedgerEntry."Due Date" <= TODAY THEN BEGIN
                //"Due Date" := TODAY;
                //"Cash Flow Date" := TODAY;
            END;
            if gCashFlowForecast."Consider CF Payment Terms" THEN BEGIN
                if gCustomer."Cash Flow Payment Terms Code" <> '' THEN BEGIN
                    gPaymentTerms.GET(gCustomer."Cash Flow Payment Terms Code");
                    "Fecha Registro" := CALCDATE(gPaymentTerms."Due Date Calculation", "Document Date");
                END;
            END;
            "Document No." := pCustLedgerEntry."Document No.";

            if gCashFlowForecast."Consider Discount" THEN BEGIN
                if pCustLedgerEntry."Currency Code" <> '' THEN
                    "Payment Discount" := ROUND(gCurrExchRate.ExchangeAmtFCYToLCYAdjmt(pCustLedgerEntry."Posting Date",
                                        pCustLedgerEntry."Currency Code", pCustLedgerEntry."Original Pmt. Disc. Possible",
                                        pCustLedgerEntry."Original Currency Factor"))
                ELSE
                    "Payment Discount" := pCustLedgerEntry."Original Pmt. Disc. Possible";
                "Amount (LCY)" := pCustLedgerEntry."Remaining Amt. (LCY)" - "Payment Discount";
                //"Amount (Currency)" := pCustLedgerEntry."Remaining Amount" - pCustLedgerEntry."Original Pmt. Disc. Possible";
                if pCustLedgerEntry."Pmt. Discount Date" <> 0D THEN BEGIN
                    "Fecha Registro" := pCustLedgerEntry."Pmt. Discount Date";
                    if gCashFlowForecast."Consider Pmt. Disc. Tol. Date" THEN
                        "Fecha Registro" := pCustLedgerEntry."Pmt. Disc. Tolerance Date";
                END;
                if gCashFlowForecast."Consider CF Payment Terms" THEN BEGIN
                    if gCustomer."Cash Flow Payment Terms Code" <> '' THEN BEGIN
                        gPaymentTerms.GET(gCustomer."Cash Flow Payment Terms Code");
                        "Fecha registro" := CALCDATE(gPaymentTerms."Discount Date Calculation", "Document Date");
                        if gCashFlowForecast."Consider Pmt. Disc. Tol. Date" THEN
                            "Fecha Registro" := CALCDATE(gGLSetup."Payment Discount Grace Period", "Cash Flow Date");
                        if pCustLedgerEntry."Currency Code" <> '' THEN BEGIN
                            "Payment Discount" := ROUND(pCustLedgerEntry."Remaining Amount" * gPaymentTerms."Discount %" / 100);
                            //"Amount (Currency)" := pCustLedgerEntry."Remaining Amount" - "Payment Discount";
                        END ELSE BEGIN
                            "Payment Discount" := ROUND(pCustLedgerEntry."Remaining Amt. (LCY)" * gPaymentTerms."Discount %" / 100);
                            "Amount (LCY)" := pCustLedgerEntry."Remaining Amt. (LCY)" - "Payment Discount";
                        END;
                    END;
                END;
            END ELSE BEGIN
                "Amount (LCY)" := pCustLedgerEntry."Remaining Amt. (LCY)";
                //"Amount (Currency)" := pCustLedgerEntry."Remaining Amount";
            END;

            if gCashFlowForecast."Consider Pmt. Tol. Amount" THEN BEGIN
                "Amount (LCY)" := "Amount (LCY)" - pCustLedgerEntry."Max. Payment Tolerance";
                if pCustLedgerEntry."Currency Code" <> '' Then
                    "Amount (LCY)" := "Amount (LCY)" -
                                        ROUND(gCurrExchRate.ExchangeAmtFCYToLCYAdjmt(pCustLedgerEntry."Posting Date",
                                        pCustLedgerEntry."Currency Code", pCustLedgerEntry."Max. Payment Tolerance",
                                        pCustLedgerEntry."Original Currency Factor"))
            END;
            "Es Cartera" := FALSE;
            //"Currency Code" := pCustLedgerEntry."Currency Code";
            //
            if pCustLedgerEntry.Banco <> '' THEN
                "Cod banco" := pCustLedgerEntry.Banco
            ELSE
                "Cod banco" := 'SIN BANCO';
            if Fasctura.GET(pCustLedgerEntry."Document No.") THEN BEGIN
                if Fasctura."Nuestra Cuenta" <> '' THEN
                    "Cod banco" := Fasctura."Nuestra Cuenta";
                if Fasctura."Nuestra Cuenta Prepago" <> '' THEN
                    "Cod banco" := Fasctura."Nuestra Cuenta Prepago";

            END;
            if Abono.GET(pCustLedgerEntry."Document No.") THEN BEGIN
                if Contrato.GET(Contrato."Document Type"::Order, Abono."Nº Contrato") THEN begin
                    if Contrato."Nuestra Cuenta" <> '' THEN
                        "Cod banco" := Contrato."Nuestra Cuenta";
                    if Contrato."Nuestra Cuenta Prepago" <> '' THEN
                        "Cod banco" := Contrato."Nuestra Cuenta Prepago";
                end;
            END;
            if pCustLedgerEntry.Banco <> '' THEN BEGIN
                "Cod banco" := pCustLedgerEntry.Banco;
            END;
            if Documentos.GET(Documentos.Type::Receivable, pCustLedgerEntry."Entry No.") THEN BEGIN
                if Remesas.GET(Documentos."Bill Gr./Pmt. Order No.") THEN BEGIN
                    "Cod banco" := Remesas."Bank Account No.";
                    "Es Cartera" := TRUE;
                END;
            END;
            if DocuemtosReg.GET(DocuemtosReg.Type::Receivable, pCustLedgerEntry."Entry No.") THEN BEGIN
                if RemesasReg.GET(DocuemtosReg."Bill Gr./Pmt. Order No.") THEN BEGIN
                    "Cod banco" := RemesasReg."Bank Account No.";
                    "Es Cartera" := TRUE;
                END;

            END;

            // {if gLiqAcc."Banco Informes"<>'' THEN
            // "Nombre Banco":=gLiqAcc."Banco Informes"
            // ELSE
            // }
            // //

            "Associated Entry No." := pCustLedgerEntry."Entry No.";
            "Payment Method Code" := pCustLedgerEntry."Payment Method Code";
            if pCustLedgerEntry."Due Date" < gdDuedateD THEN gbAtrasado := TRUE ELSE gbAtrasado := FALSE;
            // if ("Cod banco" = '') Or ("Cod banco" = 'SIN BANCO') then
            //   if gCustomer."Banco transferencia" <> '' then "Cod banco" := gCustomer."Banco transferencia";
            if "Cod banco" <> 'SIN BANCO' then
                "Nombre Banco" := NBanco("Cod banco");
            gESourceType := gESourceType::Receivables;
            BuscarLiq(gLiqAcc, gESourceType, FALSE, gbAtrasado, "Payment Method Code", "Cod banco", '', pCustLedgerEntry.Amount, "Due Date",
            pCustLedgerEntry."Customer No.");

            "Cash Flow Account No." := gLiqAcc."No.";

            // {gLiqAcc.GET("Cash Flow Account No.");
            // if gLiqAcc."Cod banco"<>'' THEN
            // if gLiqAcc."Cod banco"<>"Cod banco" THEN Amount:=0;
            // if gLiqAcc."Banco Informes"<>'' THEN BEGIN
            // if gLiqAcc."Banco Informes"<>NBanco("Cod banco") THEN Amount:=0;
            // END;
            // if (pCustLedgerEntry."Document Type"=pCustLedgerEntry."Document Type"::Payment)
            // AND (pCustLedgerEntry."Nº Factura Borrador"<>'') THEN Amount:=0;       

            // }
            //if gLiqAcc."Solo Atrasados" THEN
            if ExisteMov("Associated Entry No.") THEN "Amount (LCY)" := 0;
            "Due Date" := pCustLedgerEntry."Due Date";
            "Fecha Registro" := CalcFechaL(pCustLedgerEntry."Due Date");
            "Cash Flow Date" := pCustLedgerEntry."Due Date";
            //
            if ("Amount (LCY)" <> 0) AND (ComprobarCliente(pCustLedgerEntry."Customer No.", gLiqAcc."Cód. Cliente")) THEN BEGIN
                if InsertLiqLine() THEN;
                // Transfer Dimensions
                // LedgEntryDim.RESET;
                // LedgEntryDim.SETRANGE("Table ID",DATABASE::pCustLedgerEntry);
                // LedgEntryDim.SETRANGE("Entry No.",pCustLedgerEntry."Entry No.");
                // DimMgt.MoveLedgEntryDimToJnlLineDimLi(LedgEntryDim,JnlLineDim,DATABASE::"Liq. Journal Line",LiqLine."Journal Template Name",
                //                             LiqLine."Journal Batch Name",LiqLine."Line No.",0);
            end;
        end;
    end;

    local procedure InsertCFLineForCartera(var pCarteraDoc: Record "Cartera Doc.")
    var
        MaglXPmtTolerance: Decimal;
        Ct: Text;
        Fasctura: Record "Sales Invoice Header";
        Contrato: Record "Sales Header";
        Abono: Record "Sales Cr.Memo Header";
        Text1140019: Label '%1 %2 %3';
        EntryType: Text;
        Text1140014: Label 'Pago clte.';
        Text1140015: Label 'F.cl.';
        Text1140016: Label 'A.cl.';
        Text1140017: Label 'Doc. interés clte.';
        Text1140018: Label 'Recordatorio clte.';
        Text1140100: Label 'Efecto Cliente';
        Documentos: Record "Cartera Doc.";
        Remesas: Record "Bill Group";
        DocuemtosReg: Record "Posted Cartera Doc.";
        RemesasReg: Record "Posted Bill Group";

    begin


        if pCarteraDoc."Account No." <> '' THEN
            gCustomer.GET(pCarteraDoc."Account No.")
        ELSE
            gCustomer.INIT;

        CASE pCarteraDoc."Document Type" OF
            pCarteraDoc."Document Type"::Invoice:
                EntryType := Text1140015;
            pCarteraDoc."Document Type"::Bill:
                EntryType := Text1140100;
            ELSE
                EntryType := '';
        END;

        if gdDuedateF <> 0D THEN
            if pCarteraDoc."Due Date" > CALCDATE('181D', WORKDATE) THEN exit;

        //if gdDuedateF<>0D THEN
        //if "Due Date">gdDuedateF THEN Exit;

        //if gdDuedateD<>0D THEN
        //if "Due Date"<gdDuedateD THEN Exit;
        if pCarteraDoc."Due Date" < gdDuedateD THEN gbAtrasado := TRUE ELSE gbAtrasado := FALSE;
        with gCFWorksheetLine2 do begin


            INIT;
            "Source Type" := "Source Type"::"Cartera Clientes";// ::Receivables;
            "Shortcut Dimension 2 Code" := pCarteraDoc."Global Dimension 2 Code";
            "Shortcut Dimension 1 Code" := pCarteraDoc."Global Dimension 1 Code";
            //"Gen. Bus. Posting Group" := gCustomer."Gen. Bus. Posting Group";
            Anotaciones(pCarteraDoc."Account No.", False, "Anotación", "Fecha Anotacion");
            //"Reason Code" := '';
            //gCFWorksheetLine2. := 'CARTERA';
            //"Account Type" := LiqLine2."Account Type"::Customer;
            "Source No." := pCarteraDoc."Account No.";
            case pCarteraDoc."Document Type" of
                pCarteraDoc."Document Type"::Invoice:
                    "Document Type" := "Document Type"::Invoice;
                pCarteraDoc."Document Type"::Bill:
                    "Document Type" := "Document Type"::Bill;
            End;
            gCFSetup.Get();
            "Cash Flow Account No." := gCFSetup."Receivables CF Account No.";
            gLiqAcc.GET("Cash Flow Account No.");
            Description := COPYSTR(STRSUBSTNO(Text1140019, EntryType,
                                                    FORMAT(pCarteraDoc."Due Date"),
                                                    gCustomer.Name), 1, MAXSTRLEN(Description));
            gCFWorksheetLine2."Due Date" := CalcFecha(pCarteraDoc."Due Date");
            "Cash Flow Date" := CalcFecha(pCarteraDoc."Due Date");
            "Fecha Registro" := CalcFechaL(pCarteraDoc."Due Date");

            if gCashFlowForecast."Consider CF Payment Terms" THEN BEGIN
                if gCustomer."Cash Flow Payment Terms Code" <> '' THEN BEGIN
                    gPaymentTerms.GET(gCustomer."Cash Flow Payment Terms Code");
                    "Fecha Registro" := CALCDATE(gPaymentTerms."Due Date Calculation",
                    pCarteraDoc."Posting Date");
                END;
            END;
            "Document No." := pCarteraDoc."Document No.";

            if gCashFlowForecast."Consider Discount" THEN BEGIN
                // if "Currency Code" <> '' THEN
                // "Payment Discount" := ROUND(Conversion.ExchangeAmtFCYToLCYAdjmt(pCarteraDoc."Posting Date",
                //                     "Currency Code",0,
                //                     1))
                // ELSE
                "Payment Discount" := 0;
                "Amount (LCY)" := pCarteraDoc."Remaining Amt. (LCY)" - "Payment Discount";
                //"Amount (Currency)" := "Remaining Amount" - 0;
                if gCashFlowForecast.Comment THEN BEGIN
                    if gCustomer."Cash Flow Payment Terms Code" <> '' THEN BEGIN
                        gPaymentTerms.GET(gCustomer."Cash Flow Payment Terms Code");
                        "Fecha Registro" := CALCDATE(gPaymentTerms."Discount Date Calculation", pCarteraDoc."Posting Date");
                        if gCashFlowForecast."Consider Pmt. Disc. Tol. Date" THEN
                            "Fecha Registro" := CALCDATE(gGLSetup."Payment Discount Grace Period", "Cash Flow Date");
                        // if "Currency Code" <> '' THEN BEGIN
                        // "Payment Discount" := ROUND("Remaining Amount" * gPaymentTerms."Discount %" / 100);
                        // "Amount (Currency)" := "Remaining Amount" - "Payment Discount";
                        // END ELSE BEGIN
                        "Payment Discount" := ROUND(pCarteraDoc."Remaining Amt. (LCY)" * gPaymentTerms."Discount %" / 100);
                        "Amount (LCY)" := pCarteraDoc."Remaining Amt. (LCY)" - "Payment Discount";
                        //END;
                    END;
                END;
            END ELSE BEGIN
                "Amount (LCY)" := pCarteraDoc."Remaining Amt. (LCY)";
                //"Amount (Currency)" := "Remaining Amount";
            END;

            if gCashFlowForecast."Consider Pmt. Tol. Amount" THEN BEGIN
                "Amount (LCY)" := "Amount (LCY)" - 0;
                //"Amount (Currency)" := "Amount (Currency)" -
                //                  ROUND(Conversion.ExchangeAmtFCYToLCYAdjmt("Posting Date",
                //                "Currency Code",0,
                //              0))
            END;

            //"Currency Code" := pCarteraDoc."Currency Code";
            //
            "Es Cartera" := TRUE;
            "Cod banco" := pCarteraDoc.Banco;//'SIN BANCO';
            if "Cod banco" = '' THEN
                "Cod banco" := 'SIN BANCO';

            if Remesas.GET(pCarteraDoc."Bill Gr./Pmt. Order No.") THEN BEGIN
                "Cod banco" := Remesas."Bank Account No.";
            END;
            "Associated Entry No." := pCarteraDoc."Entry No.";
            "Payment Method Code" := pCarteraDoc."Payment Method Code";
            if pCarteraDoc."Due Date" < gdDuedateD THEN gbAtrasado := TRUE ELSE gbAtrasado := FALSE;
            //if ("Cod banco" = '') Or ("Cod banco" = 'SIN BANCO') then
            //  if gCustomer."Banco transferencia" <> '' then "Cod banco" := gCustomer."Banco transferencia";
            if "Cod banco" <> 'SIN BANCO' THEN
                "Nombre Banco" := NBanco("Cod banco");
            // Buscamos Con Todos los datos
            gESourceType := gESourceType::"Cartera Clientes"; //Receivables;
            BuscarLiq(gLiqAcc, gESourceType, TRUE, gbAtrasado, "Payment Method Code", "Cod banco", '', "Amount (LCY)", "Due Date", pCarteraDoc."Account No.");

            if gLiqAcc."Banco Informes" <> '' THEN
                "Nombre Banco" := gLiqAcc."Banco Informes"
            ELSE
                "Nombre Banco" := NBanco("Cod banco");
            "Cash Flow Account No." := gLiqAcc."No.";
            // {if gLiqAcc."Cod banco"<>'' THEN
            // if gLiqAcc."Cod banco"<>"Cod banco" THEN Amount:=0;
            // if gLiqAcc."Banco Informes"<>'' THEN BEGIN
            // if Remesas.GET("Bill Gr./Pmt. Order No.") THEN BEGIN
            // if NBanco(Remesas."Bank Account No.")<>gLiqAcc."Banco Informes" THEN Amount:=0;
            // END ELSE
            // if gLiqAcc."Banco Informes"<>NBanco("Cod banco") THEN Amount:=0;
            // END;  }
            if ExisteMov("Associated Entry No.") THEN "Amount (LCY)" := 0;
            //if gLiqAcc."Solo Atrasados" THEN
            "Due Date" := pCarteraDoc."Due Date";
            "Cash Flow Date" := pCarteraDoc."Due Date";
            if ("Amount (LCY)" <> 0) AND (ComprobarCliente(pCarteraDoc."Account No.", gLiqAcc."Cód. Cliente")) THEN BEGIN
                InsertLiqLine();
                // Transfer Dimensions
                // LedgEntryDim.RESET;
                // LedgEntryDim.SETRANGE("Table ID",DATABASE::"Cust. Ledger Entry");
                // LedgEntryDim.SETRANGE("Entry No.","Entry No.");
                // DimMgt.MoveLedgEntryDimToJnlLineDimLi(LedgEntryDim,JnlLineDim,DATABASE::"Liq. Journal Line",LiqLine."Journal Template Name",
                //                             LiqLine."Journal Batch Name",LiqLine."Line No.",0);
            END;
        end;

    end;

    local procedure InsertCFLineForPostedCartera(var pPostedCarteraDoc: Record "Posted Cartera Doc.")
    var
        MaglXPmtTolerance: Decimal;
        Ct: Text;
        Fasctura: Record "Sales Invoice Header";
        Contrato: Record "Sales Header";
        Abono: Record "Sales Cr.Memo Header";
        Text1140019: Label '%1 %2 %3';
        EntryType: Text;
        Text1140014: Label 'Pago clte.';
        Text1140015: Label 'F.cl.';
        Text1140016: Label 'A.cl.';
        Text1140017: Label 'Doc. interés clte.';
        Text1140018: Label 'Recordatorio clte.';
        Text1140100: Label 'Efecto Cliente';
        Documentos: Record "Posted Cartera Doc.";
        Remesas: Record "Posted Bill Group";
        DocuemtosReg: Record "Posted Cartera Doc.";
        RemesasReg: Record "Posted Bill Group";

    begin


        if pPostedCarteraDoc."Account No." <> '' THEN
            gCustomer.GET(pPostedCarteraDoc."Account No.")
        ELSE
            gCustomer.INIT;

        CASE pPostedCarteraDoc."Document Type" OF
            pPostedCarteraDoc."Document Type"::Invoice:
                EntryType := Text1140015;
            pPostedCarteraDoc."Document Type"::Bill:
                EntryType := Text1140100;
            ELSE
                EntryType := '';
        END;

        if gdDuedateF <> 0D THEN
            if pPostedCarteraDoc."Due Date" > CALCDATE('181D', WORKDATE) THEN exit;

        //if gdDuedateF<>0D THEN
        //if "Due Date">gdDuedateF THEN Exit;

        //if gdDuedateD<>0D THEN
        //if "Due Date"<gdDuedateD THEN Exit;
        if pPostedCarteraDoc."Due Date" < gdDuedateD THEN gbAtrasado := TRUE ELSE gbAtrasado := FALSE;
        with gCFWorksheetLine2 do begin
            // Init();
            // "Source Type" := "Source Type"::Receivables;
            // "Source No." := "Cust. Ledger Entry"."Document No.";
            // "Document Type" := "Cust. Ledger Entry"."Document Type";
            // "Document Date" := "Cust. Ledger Entry"."Document Date";
            // "Shortcut Dimension 2 Code" := "Cust. Ledger Entry"."Global Dimension 2 Code";
            // "Shortcut Dimension 1 Code" := "Cust. Ledger Entry"."Global Dimension 1 Code";
            // "Dimension Set ID" := "Cust. Ledger Entry"."Dimension Set ID";
            // "Cash Flow Account No." := gCFSetup."Receivables CF Account No.";
            // Description := CopyStr(
            //     StrSubstNo(PostedSalesDocumentDescriptionTxt,
            //       Format("Document Type"),
            //       Format("Cust. Ledger Entry"."Due Date"),
            //       gCustomer.Name),
            //     1, MAXSTRLEN(Description));
            // "Document No." := "Cust. Ledger Entry"."Document No.";
            // SetCashFlowDate(CFWorksheetLine2, "Cust. Ledger Entry"."Due Date");
            // "Amount (LCY)" := "Cust. Ledger Entry"."Remaining Amt. (LCY)";
            // "Pmt. Discount Date" := "Cust. Ledger Entry"."Pmt. Discount Date";
            // "Pmt. Disc. Tolerance Date" := "Cust. Ledger Entry"."Pmt. Disc. Tolerance Date";

            // if "Cust. Ledger Entry"."Currency Code" <> '' then
            //     gCurrency.Get("Cust. Ledger Entry"."Currency Code")
            // else
            //     gCurrency.InitRoundingPrecision;

            // "Payment Discount" := Round("Cust. Ledger Entry"."Remaining Pmt. Disc. Possible" /
            //     "Cust. Ledger Entry"."Adjusted Currency Factor", gCurrency."Amount Rounding Precision");

            // if gCashFlowForecast."Consider Pmt. Tol. Amount" then
            //     MaglXPmtTolerance := Round("Cust. Ledger Entry"."Max. Payment Tolerance" /
            //         "Cust. Ledger Entry"."Adjusted Currency Factor", gCurrency."Amount Rounding Precision")
            // else
            //     MaglXPmtTolerance := 0;

            // if gCashFlowForecast."Consider CF Payment Terms" and (gCustomer."Cash Flow Payment Terms Code" <> '') then
            //     "Payment Terms Code" := gCustomer."Cash Flow Payment Terms Code"
            // else
            //     "Payment Terms Code" := '';

            // InsertTempCFWorksheetLine(MaglXPmtTolerance);
            //ASC

            INIT;
            "Source Type" := "Source Type"::"Cartera Clientes Registrada";// Receivables;
            "Shortcut Dimension 2 Code" := pPostedCarteraDoc."Global Dimension 2 Code";
            "Shortcut Dimension 1 Code" := pPostedCarteraDoc."Global Dimension 1 Code";
            //"Gen. Bus. Posting Group" := gCustomer."Gen. Bus. Posting Group";
            Anotaciones(pPostedCarteraDoc."Account No.", False, "Anotación", "Fecha Anotacion");
            //"Reason Code" := '';
            //gCFWorksheetLine2. := 'CARTERA';
            //"Account Type" := LiqLine2."Account Type"::Customer;
            "Source No." := pPostedCarteraDoc."Account No.";
            case pPostedCarteraDoc."Document Type" of
                pPostedCarteraDoc."Document Type"::Invoice:
                    "Document Type" := "Document Type"::Invoice;
                pPostedCarteraDoc."Document Type"::Bill:
                    "Document Type" := "Document Type"::Bill;
            End;
            gCFSetup.Get();
            "Cash Flow Account No." := gCFSetup."Receivables CF Account No.";
            gLiqAcc.GET("Cash Flow Account No.");
            Description := COPYSTR(STRSUBSTNO(Text1140019, EntryType,
                                                    FORMAT(pPostedCarteraDoc."Due Date"),
                                                    gCustomer.Name), 1, MAXSTRLEN(Description));
            "Due Date" := CalcFecha(pPostedCarteraDoc."Due Date");
            "Cash Flow Date" := CalcFecha(pPostedCarteraDoc."Due Date");
            "Fecha Registro" := CalcFechaL(pPostedCarteraDoc."Due Date");

            if gCashFlowForecast."Consider CF Payment Terms" THEN BEGIN
                if gCustomer."Cash Flow Payment Terms Code" <> '' THEN BEGIN
                    gPaymentTerms.GET(gCustomer."Cash Flow Payment Terms Code");
                    "Fecha Registro" := CALCDATE(gPaymentTerms."Due Date Calculation",
                    pPostedCarteraDoc."Posting Date");
                END;
            END;
            "Document No." := pPostedCarteraDoc."Document No.";

            if gCashFlowForecast."Consider Discount" THEN BEGIN
                // if "Currency Code" <> '' THEN
                // "Payment Discount" := ROUND(Conversion.ExchangeAmtFCYToLCYAdjmt(pPostedCarteraDoc."Posting Date",
                //                     "Currency Code",0,
                //                     1))
                // ELSE
                "Payment Discount" := 0;
                "Amount (LCY)" := pPostedCarteraDoc."Remaining Amt. (LCY)" - "Payment Discount";
                //"Amount (Currency)" := "Remaining Amount" - 0;
                if gCashFlowForecast.Comment THEN BEGIN
                    if gCustomer."Cash Flow Payment Terms Code" <> '' THEN BEGIN
                        gPaymentTerms.GET(gCustomer."Cash Flow Payment Terms Code");
                        "Fecha Registro" := CALCDATE(gPaymentTerms."Discount Date Calculation", pPostedCarteraDoc."Posting Date");
                        if gCashFlowForecast."Consider Pmt. Disc. Tol. Date" THEN
                            "Fecha Registro" := CALCDATE(gGLSetup."Payment Discount Grace Period", "Cash Flow Date");
                        // if "Currency Code" <> '' THEN BEGIN
                        // "Payment Discount" := ROUND("Remaining Amount" * gPaymentTerms."Discount %" / 100);
                        // "Amount (Currency)" := "Remaining Amount" - "Payment Discount";
                        // END ELSE BEGIN
                        "Payment Discount" := ROUND(pPostedCarteraDoc."Remaining Amt. (LCY)" * gPaymentTerms."Discount %" / 100);
                        "Amount (LCY)" := pPostedCarteraDoc."Remaining Amt. (LCY)" - "Payment Discount";
                        //END;
                    END;
                END;
            END ELSE BEGIN
                "Amount (LCY)" := pPostedCarteraDoc."Remaining Amt. (LCY)";
                //"Amount (Currency)" := "Remaining Amount";
            END;

            if gCashFlowForecast."Consider Pmt. Tol. Amount" THEN BEGIN
                "Amount (LCY)" := "Amount (LCY)" - 0;
                //"Amount (Currency)" := "Amount (Currency)" -
                //                  ROUND(Conversion.ExchangeAmtFCYToLCYAdjmt("Posting Date",
                //                "Currency Code",0,
                //              0))
            END;

            //"Currency Code" := pPostedCarteraDoc."Currency Code";
            //
            "Es Cartera" := TRUE;
            "Cod banco" := pPostedCarteraDoc.Banco;//'SIN BANCO';
            if "Cod banco" = '' THEN
                "Cod banco" := 'SIN BANCO';

            if Remesas.GET(pPostedCarteraDoc."Bill Gr./Pmt. Order No.") THEN BEGIN
                "Cod banco" := Remesas."Bank Account No.";
            END;
            "Associated Entry No." := pPostedCarteraDoc."Entry No.";
            "Payment Method Code" := pPostedCarteraDoc."Payment Method Code";
            if pPostedCarteraDoc."Due Date" < gdDuedateD THEN gbAtrasado := TRUE ELSE gbAtrasado := FALSE;
            //if ("Cod banco" = '') Or ("Cod banco" = 'SIN BANCO') then
            //  if gCustomer."Banco transferencia" <> '' then "Cod banco" := gCustomer."Banco transferencia";
            if "Cod banco" <> 'SIN BANCO' THEN
                "Nombre Banco" := NBanco("Cod banco");
            // Buscamos Con Todos los datos
            gESourceType := gESourceType::"Cartera Clientes";// Receivables;
            BuscarLiq(gLiqAcc, gESourceType, TRUE, gbAtrasado, "Payment Method Code", "Cod banco", '', "Amount (LCY)", "Due Date", pPostedCarteraDoc."Account No.");

            if gLiqAcc."Banco Informes" <> '' THEN
                "Nombre Banco" := gLiqAcc."Banco Informes"
            ELSE
                "Nombre Banco" := NBanco("Cod banco");
            "Cash Flow Account No." := gLiqAcc."No.";
            // {if gLiqAcc."Cod banco"<>'' THEN
            // if gLiqAcc."Cod banco"<>"Cod banco" THEN Amount:=0;
            // if gLiqAcc."Banco Informes"<>'' THEN BEGIN
            // if Remesas.GET("Bill Gr./Pmt. Order No.") THEN BEGIN
            // if NBanco(Remesas."Bank Account No.")<>gLiqAcc."Banco Informes" THEN Amount:=0;
            // END ELSE
            // if gLiqAcc."Banco Informes"<>NBanco("Cod banco") THEN Amount:=0;
            // END;  }
            if ExisteMov("Associated Entry No.") THEN "Amount (LCY)" := 0;
            //if gLiqAcc."Solo Atrasados" THEN
            "Due Date" := pPostedCarteraDoc."Due Date";
            "Cash Flow Date" := pPostedCarteraDoc."Due Date";

            if ("Amount (LCY)" <> 0) AND (ComprobarCliente(pPostedCarteraDoc."Account No.", gLiqAcc."Cód. Cliente")) THEN BEGIN
                InsertLiqLine();
                // Transfer Dimensions
                // LedgEntryDim.RESET;
                // LedgEntryDim.SETRANGE("Table ID",DATABASE::"Cust. Ledger Entry");
                // LedgEntryDim.SETRANGE("Entry No.","Entry No.");
                // DimMgt.MoveLedgEntryDimToJnlLineDimLi(LedgEntryDim,JnlLineDim,DATABASE::"Liq. Journal Line",LiqLine."Journal Template Name",
                //                             LiqLine."Journal Batch Name",LiqLine."Line No.",0);
            END;
        end;

    end;

    local procedure InsertPFLineForCartera(var pCarteraDoc: Record "Cartera Doc.")
    var
        MaglXPmtTolerance: Decimal;
        Ct: Text;
        Text1140019: Label '%1 %2 %3';
        EntryType: Text;
        Text1140020: Label 'Pago prov.';
        Text1140021: Label 'Factura prov.';
        Text1140022: Label 'Abono prov.';
        Text1140023: Label 'Doc. interés prov.';
        Text1140024: Label 'Recordatorio prov.';
        Text1140101: Label 'Efecto Proveedor';
        Documentos: Record "Cartera Doc.";
        Remesas: Record "Payment Order";
        DocuemtosReg: Record "Posted Cartera Doc.";
        RemesasReg: Record "Posted Payment Order";
        VendorLedGerEntry: Record "Vendor Ledger Entry";
        gVendor: Record Vendor;
    begin



        if pCarteraDoc."Account No." <> '' THEN
            gVendor.GET(pCarteraDoc."Account No.")
        ELSE
            gVendor.INIT;

        CASE pCarteraDoc."Document Type" OF
            pCarteraDoc."Document Type"::Bill:
                EntryType := Text1140101;
            ELSE
                EntryType := '';
        END;

        if gdDuedateF <> 0D THEN
            if pCarteraDoc."Due Date" > CALCDATE('181D', WORKDATE) THEN exit;

        //if gdDuedateF<>0D THEN
        //if "Due Date">gdDuedateF THEN Exit;

        //if gdDuedateD<>0D THEN
        //if "Due Date"<gdDuedateD THEN Exit;
        if pCarteraDoc."Due Date" < gdDuedateD THEN gbAtrasado := TRUE ELSE gbAtrasado := FALSE;
        with gCFWorksheetLine2 do begin
            // Init();
            // "Source Type" := "Source Type"::Receivables;
            // "Source No." := "Cust. Ledger Entry"."Document No.";
            // "Document Type" := "Cust. Ledger Entry"."Document Type";
            // "Document Date" := "Cust. Ledger Entry"."Document Date";
            // "Shortcut Dimension 2 Code" := "Cust. Ledger Entry"."Global Dimension 2 Code";
            // "Shortcut Dimension 1 Code" := "Cust. Ledger Entry"."Global Dimension 1 Code";
            // "Dimension Set ID" := "Cust. Ledger Entry"."Dimension Set ID";
            // "Cash Flow Account No." := gCFSetup."Receivables CF Account No.";
            // Description := CopyStr(
            //     StrSubstNo(PostedSalesDocumentDescriptionTxt,
            //       Format("Document Type"),
            //       Format("Cust. Ledger Entry"."Due Date"),
            //       gCustomer.Name),
            //     1, MAXSTRLEN(Description));
            // "Document No." := "Cust. Ledger Entry"."Document No.";
            // SetCashFlowDate(CFWorksheetLine2, "Cust. Ledger Entry"."Due Date");
            // "Amount (LCY)" := "Cust. Ledger Entry"."Remaining Amt. (LCY)";
            // "Pmt. Discount Date" := "Cust. Ledger Entry"."Pmt. Discount Date";
            // "Pmt. Disc. Tolerance Date" := "Cust. Ledger Entry"."Pmt. Disc. Tolerance Date";

            // if "Cust. Ledger Entry"."Currency Code" <> '' then
            //     gCurrency.Get("Cust. Ledger Entry"."Currency Code")
            // else
            //     gCurrency.InitRoundingPrecision;

            // "Payment Discount" := Round("Cust. Ledger Entry"."Remaining Pmt. Disc. Possible" /
            //     "Cust. Ledger Entry"."Adjusted Currency Factor", gCurrency."Amount Rounding Precision");

            // if gCashFlowForecast."Consider Pmt. Tol. Amount" then
            //     MaglXPmtTolerance := Round("Cust. Ledger Entry"."Max. Payment Tolerance" /
            //         "Cust. Ledger Entry"."Adjusted Currency Factor", gCurrency."Amount Rounding Precision")
            // else
            //     MaglXPmtTolerance := 0;

            // if gCashFlowForecast."Consider CF Payment Terms" and (gCustomer."Cash Flow Payment Terms Code" <> '') then
            //     "Payment Terms Code" := gCustomer."Cash Flow Payment Terms Code"
            // else
            //     "Payment Terms Code" := '';

            // InsertTempCFWorksheetLine(MaglXPmtTolerance);
            //ASC

            INIT;
            "Source Type" := "Source Type"::"Cartera Proveedores";//Payables;
            "Shortcut Dimension 2 Code" := pCarteraDoc."Global Dimension 2 Code";
            "Shortcut Dimension 1 Code" := pCarteraDoc."Global Dimension 1 Code";
            //"Gen. Bus. Posting Group" := gCustomer."Gen. Bus. Posting Group";
            Anotaciones(pCarteraDoc."Account No.", true, "Anotación", "Fecha Anotacion");
            //"Reason Code" := '';
            //gCFWorksheetLine2. := 'CARTERA';
            //"Account Type" := LiqLine2."Account Type"::Customer;
            "Source No." := pCarteraDoc."Account No.";
            case pCarteraDoc."Document Type" of
                pCarteraDoc."Document Type"::Invoice:
                    "Document Type" := "Document Type"::Invoice;
                pCarteraDoc."Document Type"::Bill:
                    "Document Type" := "Document Type"::Bill;
            End;
            gCFSetup.Get();
            "Cash Flow Account No." := gCFSetup."Payables CF Account No.";
            gLiqAcc.GET("Cash Flow Account No.");
            Description := COPYSTR(STRSUBSTNO(Text1140019, EntryType,
                                                    FORMAT(pCarteraDoc."Due Date"),
                                                    gVendor.Name), 1, MAXSTRLEN(Description));
            "Due Date" := CalcFecha(pCarteraDoc."Due Date");
            "Fecha Registro" := CalcFechaL(pCarteraDoc."Due Date");
            "Cash Flow Date" := "Due Date";
            if gCashFlowForecast."Consider CF Payment Terms" THEN BEGIN
                if gVendor."Cash Flow Payment Terms Code" <> '' THEN BEGIN
                    gPaymentTerms.GET(gVendor."Cash Flow Payment Terms Code");
                    "Fecha registro" := CALCDATE(gPaymentTerms."Due Date Calculation",
                    pCarteraDoc."Posting Date");
                END;
            END;
            "Document No." := pCarteraDoc."Document No.";

            if gCashFlowForecast."Consider Discount" THEN BEGIN
                // if "Currency Code" <> '' THEN
                // "Payment Discount" := ROUND(Conversion.ExchangeAmtFCYToLCYAdjmt("Cartera Doc."."Posting Date",
                //                     "Currency Code",0,
                //                     1))
                // ELSE
                "Payment Discount" := 0;
                "Amount (LCY)" := pCarteraDoc."Remaining Amt. (LCY)" - "Payment Discount";
                //"Amount (Currency)" := "Remaining Amount" - 0;
                if gCashFlowForecast.Comment THEN BEGIN
                    if gVendor."Cash Flow Payment Terms Code" <> '' THEN BEGIN
                        gPaymentTerms.GET(gVendor."Cash Flow Payment Terms Code");
                        "Fecha Registro" := CALCDATE(gPaymentTerms."Discount Date Calculation", pCarteraDoc."Posting Date");
                        if gCashFlowForecast."Consider Pmt. Disc. Tol. Date" THEN
                            "Fecha Registro" := CALCDATE(gGLSetup."Payment Discount Grace Period", "Cash Flow Date");
                        // if "Currency Code" <> '' THEN BEGIN
                        // "Payment Discount" := ROUND("Remaining Amount" * gPaymentTerms."Discount %" / 100);
                        // "Amount (Currency)" := "Remaining Amount" - "Payment Discount";
                        // END ELSE BEGIN
                        "Payment Discount" := ROUND(pCarteraDoc."Remaining Amt. (LCY)" * gPaymentTerms."Discount %" / 100);
                        "Amount (LCY)" := -pCarteraDoc."Remaining Amt. (LCY)" + "Payment Discount";
                        //END;
                    END;
                END;
            END ELSE BEGIN
                "Amount (LCY)" := -pCarteraDoc."Remaining Amt. (LCY)";
                //"Amount (Currency)" := "Remaining Amount";
            END;

            if gCashFlowForecast."Consider Pmt. Tol. Amount" THEN BEGIN
                "Amount (LCY)" := "Amount (LCY)" - 0;
                //"Amount (Currency)" := "Amount (Currency)" -
                //                  ROUND(Conversion.ExchangeAmtFCYToLCYAdjmt("Posting Date",
                //                "Currency Code",0,
                //              0))
            END;

            //"Currency Code" := "Cartera Doc."."Currency Code";
            //
            "Es Cartera" := TRUE;
            "Cod banco" := pCarteraDoc.Banco;//'SIN BANCO';
            //if "Cod banco"='' Then "Cod banco":= pCarteraDoc."Bank Account No.";
            if "Cod banco" = '' THEN
                "Cod banco" := 'SIN BANCO';

            if Remesas.GET(pCarteraDoc."Bill Gr./Pmt. Order No.") THEN BEGIN
                "Cod banco" := Remesas."Bank Account No.";
            END;
            "Associated Entry No." := pCarteraDoc."Entry No.";
            "Payment Method Code" := pCarteraDoc."Payment Method Code";
            if pCarteraDoc."Due Date" < gdDuedateD THEN gbAtrasado := TRUE ELSE gbAtrasado := FALSE;
            if ("Cod banco" = '') OR ("Cod banco" = 'SIN BANCO') Then
                if VendorLedGerEntry.Get(pCarteraDoc."Entry No.") Then
                    if VendorLedGerEntry.Banco <> '' then "Cod banco" := VendorLedGerEntry.Banco;
            if ("Cod banco" = '') OR ("Cod banco" = 'SIN BANCO') Then
                if gVendor.Banco <> '' then "Cod banco" := gVendor.Banco;
            if "Cod banco" <> 'SIN BANCO' THEN
                "Nombre Banco" := NBanco("Cod banco");
            // Buscamos Con Todos los datos
            gESourceType := gESourceType::"Cartera Proveedores";//Payables;
            BuscarLiq(gLiqAcc, gESourceType, TRUE, gbAtrasado, "Payment Method Code", "Cod banco", pCarteraDoc."Account No.", "Amount (LCY)", "Due Date", '');

            if gLiqAcc."Banco Informes" <> '' THEN
                "Nombre Banco" := gLiqAcc."Banco Informes"
            ELSE
                "Nombre Banco" := NBanco("Cod banco");
            "Cash Flow Account No." := gLiqAcc."No.";
            // {if gLiqAcc."Cod banco"<>'' THEN
            // if gLiqAcc."Cod banco"<>"Cod banco" THEN Amount:=0;
            // if gLiqAcc."Banco Informes"<>'' THEN BEGIN
            // if Remesas.GET("Bill Gr./Pmt. Order No.") THEN BEGIN
            // if NBanco(Remesas."Bank Account No.")<>gLiqAcc."Banco Informes" THEN Amount:=0;
            // END ELSE
            // if gLiqAcc."Banco Informes"<>NBanco("Cod banco") THEN Amount:=0;
            // END;  }
            if ExisteMov("Associated Entry No.") THEN "Amount (LCY)" := 0;
            //if gLiqAcc."Solo Atrasados" THEN
            "Due Date" := pCarteraDoc."Due Date";
            "Cash Flow Date" := "Due Date";
            if ("Amount (LCY)" <> 0) AND (ComprobarProveedor(pCarteraDoc."Account No.", gLiqAcc."Cód. Proveedor")) THEN BEGIN
                InsertLiqLine();
                // Transfer Dimensions
                // LedgEntryDim.RESET;
                // LedgEntryDim.SETRANGE("Table ID",DATABASE::"Cust. Ledger Entry");
                // LedgEntryDim.SETRANGE("Entry No.","Entry No.");
                // DimMgt.MoveLedgEntryDimToJnlLineDimLi(LedgEntryDim,JnlLineDim,DATABASE::"Liq. Journal Line",LiqLine."Journal Template Name",
                //                             LiqLine."Journal Batch Name",LiqLine."Line No.",0);
            END;
        end;

    end;

    local procedure InsertPFLineForPostedCartera(var pPostedCarteraDoc: Record "Posted Cartera Doc.")
    var
        MaglXPmtTolerance: Decimal;
        Ct: Text;
        Text1140019: Label '%1 %2 %3';
        EntryType: Text;
        Text1140020: Label 'Pago prov.';
        Text1140021: Label 'Factura prov.';
        Text1140022: Label 'Abono prov.';
        Text1140023: Label 'Doc. interés prov.';
        Text1140024: Label 'Recordatorio prov.';
        Text1140101: Label 'Efecto Proveedor';
        DocuemtosReg: Record "Posted Cartera Doc.";
        RemesasReg: Record "Posted Payment Order";
        gVendor: Record Vendor;
        VendorLedGerEntry: Record "Vendor Ledger Entry";
    begin


        if pPostedCarteraDoc."Account No." <> '' THEN
            gVendor.GET(pPostedCarteraDoc."Account No.")
        ELSE
            gVendor.INIT;

        CASE pPostedCarteraDoc."Document Type" OF
            pPostedCarteraDoc."Document Type"::Bill:
                EntryType := Text1140101;
            ELSE
                EntryType := '';
        END;

        if gdDuedateF <> 0D THEN
            if pPostedCarteraDoc."Due Date" > CALCDATE('181D', WORKDATE) THEN Exit;

        //if gdDuedateF<>0D THEN
        //if "Due Date">gdDuedateF THEN Exit;

        //if gdDuedateD<>0D THEN
        //if "Due Date"<gdDuedateD THEN Exit;
        if pPostedCarteraDoc."Due Date" < gdDuedateD THEN gbAtrasado := TRUE ELSE gbAtrasado := FALSE;
        with gCFWorksheetLine2 do begin
            // Init();
            // "Source Type" := "Source Type"::Receivables;
            // "Source No." := "Cust. Ledger Entry"."Document No.";
            // "Document Type" := "Cust. Ledger Entry"."Document Type";
            // "Document Date" := "Cust. Ledger Entry"."Document Date";
            // "Shortcut Dimension 2 Code" := "Cust. Ledger Entry"."Global Dimension 2 Code";
            // "Shortcut Dimension 1 Code" := "Cust. Ledger Entry"."Global Dimension 1 Code";
            // "Dimension Set ID" := "Cust. Ledger Entry"."Dimension Set ID";
            // "Cash Flow Account No." := gCFSetup."Receivables CF Account No.";
            // Description := CopyStr(
            //     StrSubstNo(PostedSalesDocumentDescriptionTxt,
            //       Format("Document Type"),
            //       Format("Cust. Ledger Entry"."Due Date"),
            //       gCustomer.Name),
            //     1, MAXSTRLEN(Description));
            // "Document No." := "Cust. Ledger Entry"."Document No.";
            // SetCashFlowDate(CFWorksheetLine2, "Cust. Ledger Entry"."Due Date");
            // "Amount (LCY)" := "Cust. Ledger Entry"."Remaining Amt. (LCY)";
            // "Pmt. Discount Date" := "Cust. Ledger Entry"."Pmt. Discount Date";
            // "Pmt. Disc. Tolerance Date" := "Cust. Ledger Entry"."Pmt. Disc. Tolerance Date";

            // if "Cust. Ledger Entry"."Currency Code" <> '' then
            //     gCurrency.Get("Cust. Ledger Entry"."Currency Code")
            // else
            //     gCurrency.InitRoundingPrecision;

            // "Payment Discount" := Round("Cust. Ledger Entry"."Remaining Pmt. Disc. Possible" /
            //     "Cust. Ledger Entry"."Adjusted Currency Factor", gCurrency."Amount Rounding Precision");

            // if gCashFlowForecast."Consider Pmt. Tol. Amount" then
            //     MaglXPmtTolerance := Round("Cust. Ledger Entry"."Max. Payment Tolerance" /
            //         "Cust. Ledger Entry"."Adjusted Currency Factor", gCurrency."Amount Rounding Precision")
            // else
            //     MaglXPmtTolerance := 0;

            // if gCashFlowForecast."Consider CF Payment Terms" and (gCustomer."Cash Flow Payment Terms Code" <> '') then
            //     "Payment Terms Code" := gCustomer."Cash Flow Payment Terms Code"
            // else
            //     "Payment Terms Code" := '';

            // InsertTempCFWorksheetLine(MaglXPmtTolerance);
            //ASC

            INIT;
            "Source Type" := "Source Type"::"Cartera Proveedores Registrada";//Payables;
            "Shortcut Dimension 2 Code" := pPostedCarteraDoc."Global Dimension 2 Code";
            "Shortcut Dimension 1 Code" := pPostedCarteraDoc."Global Dimension 1 Code";
            //"Gen. Bus. Posting Group" := gCustomer."Gen. Bus. Posting Group";
            Anotaciones(pPostedCarteraDoc."Account No.", true, "Anotación", "Fecha Anotacion");
            //"Reason Code" := '';
            //gCFWorksheetLine2. := 'CARTERA';
            //"Account Type" := LiqLine2."Account Type"::Customer;
            "Source No." := pPostedCarteraDoc."Account No.";
            case pPostedCarteraDoc."Document Type" of
                pPostedCarteraDoc."Document Type"::Invoice:
                    "Document Type" := "Document Type"::Invoice;
                pPostedCarteraDoc."Document Type"::Bill:
                    "Document Type" := "Document Type"::Bill;
            End;

            "Cash Flow Account No." := gCFSetup."Payables CF Account No.";
            gLiqAcc.GET("Cash Flow Account No.");
            Description := COPYSTR(STRSUBSTNO(Text1140019, EntryType,
                                                    FORMAT(pPostedCarteraDoc."Due Date"),
                                                    gVendor.Name), 1, MAXSTRLEN(Description));
            "Due Date" := (pPostedCarteraDoc."Due Date");
            "Fecha Registro" := CalcFechaL(pPostedCarteraDoc."Due Date");
            "Cash Flow Date" := pPostedCarteraDoc."Due Date";
            if gCashFlowForecast."Consider CF Payment Terms" THEN BEGIN
                if gVendor."Cash Flow Payment Terms Code" <> '' THEN BEGIN
                    gPaymentTerms.GET(gCustomer."Cash Flow Payment Terms Code");
                    "Fecha Registro" := CALCDATE(gPaymentTerms."Due Date Calculation",
                    pPostedCarteraDoc."Posting Date");
                END;
            END;
            "Document No." := pPostedCarteraDoc."Document No.";

            if gCashFlowForecast."Consider Discount" THEN BEGIN
                // if "Currency Code" <> '' THEN
                // "Payment Discount" := ROUND(Conversion.ExchangeAmtFCYToLCYAdjmt(pPostedCarteraDoc."Posting Date",
                //                     "Currency Code",0,
                //                     1))
                // ELSE
                "Payment Discount" := 0;
                "Amount (LCY)" := pPostedCarteraDoc."Remaining Amt. (LCY)" - "Payment Discount";
                //"Amount (Currency)" := "Remaining Amount" - 0;
                if gCashFlowForecast.Comment THEN BEGIN
                    if gVendor."Cash Flow Payment Terms Code" <> '' THEN BEGIN
                        gPaymentTerms.GET(gCustomer."Cash Flow Payment Terms Code");
                        "Fecha Registro" := CALCDATE(gPaymentTerms."Discount Date Calculation", pPostedCarteraDoc."Posting Date");
                        if gCashFlowForecast."Consider Pmt. Disc. Tol. Date" THEN
                            "Fecha Registro" := CALCDATE(gGLSetup."Payment Discount Grace Period", "Cash Flow Date");
                        // if "Currency Code" <> '' THEN BEGIN
                        // "Payment Discount" := ROUND("Remaining Amount" * gPaymentTerms."Discount %" / 100);
                        // "Amount (Currency)" := "Remaining Amount" - "Payment Discount";
                        // END ELSE BEGIN
                        "Payment Discount" := ROUND(pPostedCarteraDoc."Remaining Amt. (LCY)" * gPaymentTerms."Discount %" / 100);
                        "Amount (LCY)" := -pPostedCarteraDoc."Remaining Amt. (LCY)" + "Payment Discount";
                        //END;
                    END;
                END;
            END ELSE BEGIN
                "Amount (LCY)" := -pPostedCarteraDoc."Remaining Amt. (LCY)";
                //"Amount (Currency)" := "Remaining Amount";
            END;

            if gCashFlowForecast."Consider Pmt. Tol. Amount" THEN BEGIN
                "Amount (LCY)" := "Amount (LCY)" - 0;
                //"Amount (Currency)" := "Amount (Currency)" -
                //                  ROUND(Conversion.ExchangeAmtFCYToLCYAdjmt("Posting Date",
                //                "Currency Code",0,
                //              0))
            END;

            //"Currency Code" := pPostedCarteraDoc."Currency Code";
            //
            "Es Cartera" := TRUE;
            "Cod banco" := pPostedCarteraDoc.Banco;//'SIN BANCO';
            if "Cod banco" = '' Then "Cod banco" := pPostedCarteraDoc."Bank Account No.";
            if "Cod banco" = '' THEN
                "Cod banco" := 'SIN BANCO';

            if RemesasReg.GET(pPostedCarteraDoc."Bill Gr./Pmt. Order No.") THEN BEGIN
                "Cod banco" := RemesasReg."Bank Account No.";
            END;
            "Associated Entry No." := pPostedCarteraDoc."Entry No.";
            "Payment Method Code" := pPostedCarteraDoc."Payment Method Code";
            if pPostedCarteraDoc."Due Date" < gdDuedateD THEN gbAtrasado := TRUE ELSE gbAtrasado := FALSE;
            if ("Cod banco" = '') OR ("Cod banco" = 'SIN BANCO') Then
                if VendorLedGerEntry.Get(pPostedCarteraDoc."Entry No.") Then
                    if VendorLedGerEntry.Banco <> '' then "Cod banco" := VendorLedGerEntry.Banco;
            if ("Cod banco" = '') OR ("Cod banco" = 'SIN BANCO') Then
                if gVendor.Banco <> '' then "Cod banco" := gVendor.Banco;
            if "Cod banco" <> 'SIN BANCO' THEN
                "Nombre Banco" := NBanco("Cod banco");
            // Buscamos Con Todos los datos
            gESourceType := gESourceType::"Cartera Proveedores Registrada";//Payables;
            BuscarLiq(gLiqAcc, gESourceType, TRUE, gbAtrasado, "Payment Method Code", "Cod banco", pPostedCarteraDoc."Account No.", "Amount (LCY)", "Due Date", '');

            if gLiqAcc."Banco Informes" <> '' THEN
                "Nombre Banco" := gLiqAcc."Banco Informes"
            ELSE
                "Nombre Banco" := NBanco("Cod banco");
            "Cash Flow Account No." := gLiqAcc."No.";
            // {if gLiqAcc."Cod banco"<>'' THEN
            // if gLiqAcc."Cod banco"<>"Cod banco" THEN Amount:=0;
            // if gLiqAcc."Banco Informes"<>'' THEN BEGIN
            // if Remesas.GET("Bill Gr./Pmt. Order No.") THEN BEGIN
            // if NBanco(Remesas."Bank Account No.")<>gLiqAcc."Banco Informes" THEN Amount:=0;
            // END ELSE
            // if gLiqAcc."Banco Informes"<>NBanco("Cod banco") THEN Amount:=0;
            // END;  }
            if ExisteMov("Associated Entry No.") THEN "Amount (LCY)" := 0;
            //if gLiqAcc."Solo Atrasados" THEN
            "Due Date" := (pPostedCarteraDoc."Due Date");
            "Fecha Registro" := CalcFechaL(pPostedCarteraDoc."Due Date");
            "Cash Flow Date" := pPostedCarteraDoc."Due Date";
            if ("Amount (LCY)" <> 0) AND (ComprobarProveedor(pPostedCarteraDoc."Account No.", gLiqAcc."Cód. Proveedor")) THEN BEGIN
                InsertLiqLine();
                // Transfer Dimensions
                // LedgEntryDim.RESET;
                // LedgEntryDim.SETRANGE("Table ID",DATABASE::"Cust. Ledger Entry");
                // LedgEntryDim.SETRANGE("Entry No.","Entry No.");
                // DimMgt.MoveLedgEntryDimToJnlLineDimLi(LedgEntryDim,JnlLineDim,DATABASE::"Liq. Journal Line",LiqLine."Journal Template Name",
                //                             LiqLine."Journal Batch Name",LiqLine."Line No.",0);
            END;
        end;

    end;

    local procedure InsertCFLineForVendorLedgEntry(var pVendorLedgerEntry: Record "Vendor Ledger Entry")
    var
        MaglXPmtTolerance: Decimal;
        Ct: Text;
        Fasctura: Record "Purch. Inv. Header";
        Contrato: Record "Sales Header";
        Abono: Record "Purch. Cr. Memo Hdr.";
        Text1140019: Label '%1 %2 %3';
        EntryType: Text;
        Text1140020: Label 'Pago prov.';
        Text1140021: Label 'Factura prov.';
        Text1140022: Label 'Abono prov.';
        Text1140023: Label 'Doc. interés prov.';
        Text1140024: Label 'Recordatorio prov.';
        Text1140101: Label 'Efecto Proveedor';
        Documentos: Record "Cartera Doc.";
        Remesas: Record "Payment Order";
        DocuemtosReg: Record "Posted Cartera Doc.";
        RemesasReg: Record "Posted Payment Order";
        gVendor: Record Vendor;
    begin

        if pVendorLedgerEntry."Vendor No." <> '' THEN
            gVendor.GET(pVendorLedgerEntry."Vendor No.")
        ELSE
            gVendor.INIT;
        if pVendorLedgerEntry."Due Date" < gdDuedateD THEN gbAtrasado := TRUE ELSE gbAtrasado := FALSE;

        CASE pVendorLedgerEntry."Document Type" OF
            pVendorLedgerEntry."Document Type"::Payment:
                EntryType := Text1140020;
            pVendorLedgerEntry."Document Type"::Invoice:
                EntryType := Text1140021;
            pVendorLedgerEntry."Document Type"::"Credit Memo":
                EntryType := Text1140022;
            pVendorLedgerEntry."Document Type"::"Finance Charge Memo":
                EntryType := Text1140023;
            pVendorLedgerEntry."Document Type"::Reminder:
                EntryType := Text1140024;
            pVendorLedgerEntry."Document Type"::Bill:
                EntryType := Text1140101;
            ELSE
                EntryType := '';
        END;

        pVendorLedgerEntry.CALCFIELDS("Remaining Amt. (LCY)", "Remaining Amount");
        with gCFWorksheetLine2 do begin

            INIT;
            "Source Type" := "Source Type"::Payables;
            "Shortcut Dimension 2 Code" := pVendorLedgerEntry."Global Dimension 2 Code";
            "Shortcut Dimension 1 Code" := pVendorLedgerEntry."Global Dimension 1 Code";
            //"Gen. Bus. Posting Group" := gCustomer."Gen. Bus. Posting Group";
            Anotaciones(pVendorLedgerEntry."Vendor No.", True, "Anotación", "Fecha Anotacion");
            "Source No." := pVendorLedgerEntry."Vendor No.";
            "Document No." := pVendorLedgerEntry."Document No.";
            "Document Type" := pVendorLedgerEntry."Document Type";
            //"Source Code" := pVendorLedgerEntry."Source Code";
            //"Account Type" := gCFWorksheetLine2."Account Type"::Customer;
            //"Account Number" := pVendorLedgerEntry."Customer No.";
            "Shortcut Dimension 2 Code" := pVendorLedgerEntry."Global Dimension 2 Code";
            "Shortcut Dimension 1 Code" := pVendorLedgerEntry."Global Dimension 1 Code";
            "Dimension Set ID" := pVendorLedgerEntry."Dimension Set ID";
            "Cash Flow Account No." := gCFSetup."Payables CF Account No.";
            //"Cash Flow Account No." := LiqSetup."Receivables Liq. Account No.";
            gLiqAcc.GET("Cash Flow Account No.");
            Ct := '';

            if pVendorLedgerEntry."Document Type" = pVendorLedgerEntry."Document Type"::Bill THEN
                Description := COPYSTR(STRSUBSTNO(Text1140019, EntryType,
                                                        FORMAT(pVendorLedgerEntry."Due Date"),
                                                        gVendor.Name), 1, MAXSTRLEN(gCFWorksheetLine2.Description))
            ELSE
                Description := COPYSTR(STRSUBSTNO(Text1140019, EntryType,
                                                        FORMAT(pVendorLedgerEntry."Posting Date"),
                                                        gVendor.Name), 1, MAXSTRLEN(gCFWorksheetLine2.Description));

            "Due Date" := CalcFecha(pVendorLedgerEntry."Due Date");

            "Fecha Registro" := CalcFechaL(pVendorLedgerEntry."Due Date");
            "Cash Flow Date" := Calcfecha(pVendorLedgerEntry."Due Date");
            if pVendorLedgerEntry."Due Date" <= TODAY THEN BEGIN
                //"Due Date" := TODAY;
                //"Cash Flow Date" := TODAY;
            END;
            if gCashFlowForecast."Consider CF Payment Terms" THEN BEGIN
                if gVendor."Cash Flow Payment Terms Code" <> '' THEN BEGIN
                    gPaymentTerms.GET(gVendor."Cash Flow Payment Terms Code");
                    "Fecha Registro" := CALCDATE(gPaymentTerms."Due Date Calculation", "Document Date");
                END;
            END;
            "Document No." := pVendorLedgerEntry."Document No.";

            if gCashFlowForecast."Consider Discount" THEN BEGIN
                if pVendorLedgerEntry."Currency Code" <> '' THEN
                    "Payment Discount" := ROUND(gCurrExchRate.ExchangeAmtFCYToLCYAdjmt(pVendorLedgerEntry."Posting Date",
                                        pVendorLedgerEntry."Currency Code", pVendorLedgerEntry."Original Pmt. Disc. Possible",
                                        pVendorLedgerEntry."Original Currency Factor"))
                ELSE
                    "Payment Discount" := pVendorLedgerEntry."Original Pmt. Disc. Possible";
                "Amount (LCY)" := pVendorLedgerEntry."Remaining Amt. (LCY)" - "Payment Discount";
                //"Amount (Currency)" := pVendorLedgerEntry."Remaining Amount" - pVendorLedgerEntry."Original Pmt. Disc. Possible";
                if pVendorLedgerEntry."Pmt. Discount Date" <> 0D THEN BEGIN
                    "Fecha Registro" := pVendorLedgerEntry."Pmt. Discount Date";
                    if gCashFlowForecast."Consider Pmt. Disc. Tol. Date" THEN
                        "Fecha Registro" := pVendorLedgerEntry."Pmt. Disc. Tolerance Date";
                END;
                if gCashFlowForecast."Consider CF Payment Terms" THEN BEGIN
                    if gVendor."Cash Flow Payment Terms Code" <> '' THEN BEGIN
                        gPaymentTerms.GET(gVendor."Cash Flow Payment Terms Code");
                        "Fecha Registro" := CALCDATE(gPaymentTerms."Discount Date Calculation", "Document Date");
                        if gCashFlowForecast."Consider Pmt. Disc. Tol. Date" THEN
                            "Fecha Registro" := CALCDATE(gGLSetup."Payment Discount Grace Period", "Cash Flow Date");
                        if pVendorLedgerEntry."Currency Code" <> '' THEN BEGIN
                            "Payment Discount" := ROUND(pVendorLedgerEntry."Remaining Amount" * gPaymentTerms."Discount %" / 100);
                            //"Amount (Currency)" := pVendorLedgerEntry."Remaining Amount" - "Payment Discount";
                        END ELSE BEGIN
                            "Payment Discount" := ROUND(pVendorLedgerEntry."Remaining Amt. (LCY)" * gPaymentTerms."Discount %" / 100);
                            "Amount (LCY)" := pVendorLedgerEntry."Remaining Amt. (LCY)" - "Payment Discount";
                        END;
                    END;
                END;
            END ELSE BEGIN
                "Amount (LCY)" := pVendorLedgerEntry."Remaining Amt. (LCY)";
                //"Amount (Currency)" := pVendorLedgerEntry."Remaining Amount";
            END;

            if gCashFlowForecast."Consider Pmt. Tol. Amount" THEN BEGIN
                "Amount (LCY)" := "Amount (LCY)" - pVendorLedgerEntry."Max. Payment Tolerance";
                if pVendorLedgerEntry."Currency Code" <> '' Then
                    "Amount (LCY)" := "Amount (LCY)" -
                                        ROUND(gCurrExchRate.ExchangeAmtFCYToLCYAdjmt(pVendorLedgerEntry."Posting Date",
                                        pVendorLedgerEntry."Currency Code", pVendorLedgerEntry."Max. Payment Tolerance",
                                        pVendorLedgerEntry."Original Currency Factor"))
            END;

            //"Currency Code" := pVendorLedgerEntry."Currency Code";
            //
            "Es Cartera" := false;
            if pVendorLedgerEntry.Banco <> '' THEN
                "Cod banco" := pVendorLedgerEntry.Banco
            ELSE
                "Cod banco" := 'SIN BANCO';
            if ("Cod banco" = '') OR ("Cod banco" = 'SIN BANCO') Then
                if gVendor.Banco <> '' then "Cod banco" := gVendor.Banco;
            if Documentos.GET(Documentos.Type::Payable, pVendorLedgerEntry."Entry No.") THEN BEGIN
                if Remesas.GET(Documentos."Bill Gr./Pmt. Order No.") THEN BEGIN
                    "Cod banco" := Remesas."Bank Account No.";
                    "Es Cartera" := TRUE;
                END;
                "Cash Flow Date" := Documentos."Due Date";
            END;
            if DocuemtosReg.GET(DocuemtosReg.Type::Payable, pVendorLedgerEntry."Entry No.") THEN BEGIN
                if RemesasReg.GET(DocuemtosReg."Bill Gr./Pmt. Order No.") THEN BEGIN
                    "Cod banco" := RemesasReg."Bank Account No.";
                    "Es Cartera" := TRUE;
                END;
                "Cash Flow Date" := DocuemtosReg."Due Date";

            END;

            // {if gLiqAcc."Banco Informes"<>'' THEN
            // "Nombre Banco":=gLiqAcc."Banco Informes"
            // ELSE
            // }
            // //
            //"Es Cartera" := FALSE;
            "Associated Entry No." := pVendorLedgerEntry."Entry No.";
            "Payment Method Code" := pVendorLedgerEntry."Payment Method Code";
            if pVendorLedgerEntry."Due Date" < gdDuedateD THEN gbAtrasado := TRUE ELSE gbAtrasado := FALSE;
            if "Cod banco" <> 'SIN BANCO' then
                "Nombre Banco" := NBanco("Cod banco");
            "Source Type" := gESourceType::Payables;
            gESourceType := gESourceType::Payables;
            BuscarLiq(gLiqAcc, gESourceType, FALSE, gbAtrasado, "Payment Method Code", "Cod banco", pVendorLedgerEntry."Vendor No.", pVendorLedgerEntry.Amount, "Due Date",
            '');

            "Cash Flow Account No." := gLiqAcc."No.";

            // {gLiqAcc.GET("Cash Flow Account No.");
            // if gLiqAcc."Cod banco"<>'' THEN
            // if gLiqAcc."Cod banco"<>"Cod banco" THEN Amount:=0;
            // if gLiqAcc."Banco Informes"<>'' THEN BEGIN
            // if gLiqAcc."Banco Informes"<>NBanco("Cod banco") THEN Amount:=0;
            // END;
            // if (pVendorLedgerEntry."Document Type"=pVendorLedgerEntry."Document Type"::Payment)
            // AND (pVendorLedgerEntry."Nº Factura Borrador"<>'') THEN Amount:=0;       

            // }
            //if gLiqAcc."Solo Atrasados" THEN
            if ExisteMov("Associated Entry No.") THEN "Amount (LCY)" := 0;
            //"Due Date" := pVendorLedgerEntry."Due Date";
            //"Cash Flow Date" := pVendorLedgerEntry."Due Date";
            //
            if ("Amount (LCY)" <> 0) AND (ComprobarProveedor(pVendorLedgerEntry."Vendor No.", gLiqAcc."Cód. Proveedor")) THEN BEGIN
                if InsertLiqLine() THEN;
                // Transfer Dimensions
                // LedgEntryDim.RESET;
                // LedgEntryDim.SETRANGE("Table ID",DATABASE::pVendorLedgerEntry);
                // LedgEntryDim.SETRANGE("Entry No.","Cust. Ledger Entry"."Entry No.");
                // DimMgt.MoveLedgEntryDimToJnlLineDimLi(LedgEntryDim,JnlLineDim,DATABASE::"Liq. Journal Line",LiqLine."Journal Template Name",
                //                             LiqLine."Journal Batch Name",LiqLine."Line No.",0);
            end;
        end;
    end;

    local procedure InsertCFLineForPurchaseLine(var pPurchaseLine: Record "Purchase Line")
    var
        PurchLine2: Record "Purchase Line";
        gVendor: Record Vendor;
    begin
        PurchLine2 := pPurchaseLine;
        if gBSummarized and (PurchLine2.Next <> 0) and (PurchLine2."Buy-from Vendor No." <> '') and
           (PurchLine2."Document No." = pPurchaseLine."Document No.")
        then begin
            gDTotalAmt += CalculateLineAmountForPurchaseLine(gPurchHeader, pPurchaseLine);
            gBMultiSalesLines := true;
        end else
            with gCFWorksheetLine2 do begin
                Init();
                "Source Type" := "Source Type"::"Purchase Orders";
                "Source No." := pPurchaseLine."Document No.";
                "Source Line No." := pPurchaseLine."Line No.";
                "Document Type" := "Document Type"::Invoice;
                "Document Date" := gPurchHeader."Document Date";
                "Shortcut Dimension 1 Code" := gPurchHeader."Shortcut Dimension 1 Code";
                "Shortcut Dimension 2 Code" := gPurchHeader."Shortcut Dimension 2 Code";
                "Dimension Set ID" := gPurchHeader."Dimension Set ID";
                "Cash Flow Account No." := gCFSetup."Purch. Order CF Account No.";
                Description :=
                  CopyStr(
                    StrSubstNo(
                      glPurchaseDocumentDescriptionTxt,
                      gPurchHeader."Document Type",
                      Format(gPurchHeader."Order Date"),
                      gPurchHeader."Buy-from Vendor Name"),
                    1, MAXSTRLEN(Description));
                SetCashFlowDate(gCFWorksheetLine2, gPurchHeader."Due Date");
                "Document No." := pPurchaseLine."Document No.";
                "Amount (LCY)" := CalculateLineAmountForPurchaseLine(gPurchHeader, pPurchaseLine);

                if gbSummarized and gbMultiSalesLines then begin
                    "Amount (LCY)" := "Amount (LCY)" + gDTotalAmt;
                    gbMultiSalesLines := false;
                    gDTotalAmt := 0;
                end;

                if gPaymentMethod.Get(gPurchHeader."Payment Method Code") then
                    if (gPaymentMethod."Create Bills" or gPaymentMethod."Invoices to Cartera") and
                       (not gCarteraSetup.ReadPermission)
                    then
                        Error(glCannotCreateCarteraDocErr);

                if not (pPurchaseLine."Document Type" in
                        [pPurchaseLine."Document Type"::"Credit Memo", pPurchaseLine."Document Type"::"Return Order"]) and
                   gCarteraSetup.ReadPermission and gPaymentMethod."Create Bills"
                then
                    SplitPurchInv(
                      gPurchHeader, gCFWorksheetLine2, "Amount (LCY)", -(-"Amount (LCY)" - pPurchaseLine."Line Amount"));

                if gCashFlowForecast."Consider CF Payment Terms" and (gVendor."Cash Flow Payment Terms Code" <> '') then
                    "Payment Terms Code" := gVendor."Cash Flow Payment Terms Code"
                else
                    "Payment Terms Code" := gPurchHeader."Payment Terms Code";

                if ("Amount (LCY)" <> 0) and not gPaymentMethod."Create Bills" then
                    InsertTempCFWorksheetLine(0);
            end;
    end;

    local procedure InsertCFLineForSalesLine(var pSalesLine: Record "Sales Line")
    var
        SalesLine2: Record "Sales Line";
    begin
        SalesLine2 := pSalesLine;
        if gbSummarized and (SalesLine2.Next <> 0) and (SalesLine2."Sell-to Customer No." <> '') and
           (SalesLine2."Document No." = pSalesLine."Document No.")
        then begin
            gDTotalAmt += CalculateLineAmountForSalesLine(gSalesHeader, pSalesLine);
            gbMultiSalesLines := true;
        end else
            with gCFWorksheetLine2 do begin
                Init();
                "Document Type" := "Document Type"::Invoice;
                "Document Date" := gSalesHeader."Document Date";
                "Source Type" := "Source Type"::"Sales Orders";
                "Source No." := pSalesLine."Document No.";
                "Source Line No." := pSalesLine."Line No.";
                "Shortcut Dimension 1 Code" := gSalesHeader."Shortcut Dimension 1 Code";
                "Shortcut Dimension 2 Code" := gSalesHeader."Shortcut Dimension 2 Code";
                "Dimension Set ID" := gSalesHeader."Dimension Set ID";
                "Cash Flow Account No." := gCFSetup."Sales Order CF Account No.";
                Description :=
                  CopyStr(
                    StrSubstNo(
                      glSalesDocumentDescriptionTxt,
                      gSalesHeader."Document Type",
                      Format(gSalesHeader."Order Date"),
                      gSalesHeader."Sell-to Customer Name"),
                    1, MAXSTRLEN(Description));
                SetCashFlowDate(gCFWorksheetLine2, gSalesHeader."Due Date");
                "Document No." := pSalesLine."Document No.";
                "Amount (LCY)" := CalculateLineAmountForSalesLine(gSalesHeader, pSalesLine);

                if gbSummarized and gbMultiSalesLines then begin
                    "Amount (LCY)" := "Amount (LCY)" + gDTotalAmt;
                    gbMultiSalesLines := false;
                    gDTotalAmt := 0;
                end;

                if gPaymentMethod.Get(gSalesHeader."Payment Method Code") then
                    if (gPaymentMethod."Create Bills" or gPaymentMethod."Invoices to Cartera") and
                       (not gCarteraSetup.ReadPermission)
                    then
                        Error(glCannotCreateCarteraDocErr);

                if not (pSalesLine."Document Type" in
                        [pSalesLine."Document Type"::"Credit Memo", pSalesLine."Document Type"::"Return Order"]) and
                   gCarteraSetup.ReadPermission and gPaymentMethod."Create Bills"
                then
                    SplitSalesInv(
                      gSalesHeader, gCFWorksheetLine2, "Amount (LCY)", "Amount (LCY)" - pSalesLine."Line Amount");

                if gCashFlowForecast."Consider CF Payment Terms" and (gCustomer."Cash Flow Payment Terms Code" <> '') then
                    "Payment Terms Code" := gCustomer."Cash Flow Payment Terms Code"
                else
                    "Payment Terms Code" := gSalesHeader."Payment Terms Code";

                if ("Amount (LCY)" <> 0) and not gPaymentMethod."Create Bills" then
                    InsertTempCFWorksheetLine(0);
            end;
    end;

    local procedure InsertCFLineForFixedAssetsBudget(var InvestmentFixedAsset: Record "Fixed Asset")
    begin
        with gCFWorksheetLine2 do begin
            Init();
            "Source Type" := "Source Type"::"Fixed Assets Budget";
            "Source No." := InvestmentFixedAsset."No.";
            "Document No." := InvestmentFixedAsset."No.";
            "Cash Flow Account No." := gCFSetup."FA Budget CF Account No.";
            Description :=
              CopyStr(
                StrSubstNo(
                  glText027, InvestmentFixedAsset."No.", Format(-gFADeprBook."Acquisition Cost")),
                1, MAXSTRLEN(Description));
            SetCashFlowDate(gCFWorksheetLine2, gFADeprBook."Acquisition Date");
            "Amount (LCY)" := -gFADeprBook."Acquisition Cost";
            "Shortcut Dimension 2 Code" := InvestmentFixedAsset."Global Dimension 2 Code";
            "Shortcut Dimension 1 Code" := InvestmentFixedAsset."Global Dimension 1 Code";
            MoveDefualtDimToJnlLineDim(DATABASE::"Fixed Asset", InvestmentFixedAsset."No.", "Dimension Set ID");
            InsertTempCFWorksheetLine(0);
        end;
    end;

    local procedure InsertCFLineForFixedAssetsDisposal(var SaleFixedAsset: Record "Fixed Asset")
    begin
        with gCFWorksheetLine2 do begin
            Init();
            "Source Type" := "Source Type"::"Fixed Assets Disposal";
            "Source No." := SaleFixedAsset."No.";
            "Document No." := SaleFixedAsset."No.";
            "Cash Flow Account No." := gCFSetup."FA Disposal CF Account No.";
            Description :=
              CopyStr(
                StrSubstNo(
                  glText027, SaleFixedAsset."No.", Format(gFADeprBook."Projected Proceeds on Disposal")),
                1, MAXSTRLEN(Description));
            SetCashFlowDate(gCFWorksheetLine2, gFADeprBook."Projected Disposal Date");
            "Amount (LCY)" := gFADeprBook."Projected Proceeds on Disposal";
            "Shortcut Dimension 2 Code" := SaleFixedAsset."Global Dimension 2 Code";
            "Shortcut Dimension 1 Code" := SaleFixedAsset."Global Dimension 1 Code";
            MoveDefualtDimToJnlLineDim(DATABASE::"Fixed Asset", SaleFixedAsset."No.", "Dimension Set ID");
            InsertTempCFWorksheetLine(0);
        end;
    end;

    local procedure InsertCFLineForManualExpense(pCashFlowManualExpense: Record "Cash Flow Manual Expense")
    var
        "Execution Date": Date;
        a: Integer;
        Text1140028: Label '%1 gastos neutr.';
    begin
        with gCFWorksheetLine2 do begin
            //     pCashFlowManualExpense.TestField("Starting Date");
            //     Init();
            //     "Source Type" := "Source Type"::pCashFlowManualExpense;
            //     "Source No." := pCashFlowManualExpense.Code;
            //     "Document No." := pCashFlowManualExpense.Code;
            //     "Cash Flow Account No." := pCashFlowManualExpense."Cash Flow Account No.";
            //     "Shortcut Dimension 1 Code" := pCashFlowManualExpense."Global Dimension 1 Code";
            //     "Shortcut Dimension 2 Code" := pCashFlowManualExpense."Global Dimension 2 Code";
            //     MoveDefualtDimToJnlLineDim(DATABASE::pCashFlowManualExpense, pCashFlowManualExpense.Code, "Dimension Set ID");
            //     Description := CopyStr(StrSubstNo(Text028, pCashFlowManualExpense.Description), 1, MAXSTRLEN(Description));
            //     gdDateLastExecution := gCashFlowForecast."Manual Payments To";
            //     if (pCashFlowManualExpense."Ending Date" <> 0D) and
            //        (pCashFlowManualExpense."Ending Date" < gCashFlowForecast."Manual Payments To")
            //     then
            //         gdDateLastExecution := pCashFlowManualExpense."Ending Date";
            //     ExecutionDate := pCashFlowManualExpense."Starting Date";
            //     if Format(pCashFlowManualExpense."Recurring Frequency") <> '' then begin
            //         if gdDateLastExecution = 0D then begin
            //             NeedsManualPmtUpdate := true;
            //             InsertManualData(
            //               ExecutionDate, gCashFlowForecast, -pCashFlowManualExpense.Amount);
            //         end else
            //             while ExecutionDate <= gdDateLastExecution do begin
            //                 InsertManualData(
            //                   ExecutionDate, gCashFlowForecast, -pCashFlowManualExpense.Amount);
            //                 ExecutionDate := CalcDate(pCashFlowManualExpense."Recurring Frequency", ExecutionDate);
            //             end;
            //     end else
            //         InsertManualData(ExecutionDate, gCashFlowForecast, -pCashFlowManualExpense.Amount);
            // end;

            if pCashFlowManualExpense."Starting Date" = 0D THEN
                pCashFlowManualExpense."Starting Date" := gdDummyDate;// PostDate;
            if pCashFlowManualExpense."Ending Date" = 0D THEN
                pCashFlowManualExpense."Ending Date" := gdDummyDate;
            if (Format(pCashFlowManualExpense."Recurring Frequency") = '') AND (pCashFlowManualExpense."Una Sola Vez") THEN
                Evaluate(pCashFlowManualExpense."Recurring Frequency", '99A');
            INIT;
            "Source Type" := "Source Type"::"Cash Flow Manual Expense";
            "Document No." := pCashFlowManualExpense.Code;
            "Cash Flow Account No." := pCashFlowManualExpense."Cash Flow Account No.";
            "Shortcut Dimension 1 Code" := pCashFlowManualExpense."Global Dimension 1 Code";
            "Shortcut Dimension 2 Code" := pCashFlowManualExpense."Global Dimension 2 Code";
            "Cod banco" := pCashFlowManualExpense.Banco;

            if gLiqAcc."Banco Informes" <> '' THEN
                "Nombre Banco" := gLiqAcc."Banco Informes"
            ELSE
                "Nombre Banco" := NBanco("Cod banco");
            Description := COPYSTR(STRSUBSTNO(Text1140028, pCashFlowManualExpense.Description), 1, MAXSTRLEN(gCFWorksheetLine2.Description));
            gdDateLastExecution := gCashFlowForecast."Manual Payments To";
            if (pCashFlowManualExpense."Ending Date" <> 0D) AND (pCashFlowManualExpense."Ending Date" < gCashFlowForecast."Manual Payments To") THEN
                gdDateLastExecution := pCashFlowManualExpense."Ending Date";
            gdDateLastExecution := pCashFlowManualExpense."Ending Date";
            "Execution Date" := pCashFlowManualExpense."Starting Date";
            //if (pCashFlowManualExpense."First Execution" <> 0D) AND
            // (pCashFlowManualExpense."First Execution" < Liquidity."Neutral Payments From") THEN
            //"Execution Date" := Liquidity."Neutral Payments From";
            if pCashFlowManualExpense."Una Sola Vez" THEN BEGIN
                if Format(pCashFlowManualExpense."Recurring Frequency") = '' THEN
                    "Execution Date" := CALCDATE(pCashFlowManualExpense."Recurring Frequency", gdDummyDate);
                gdDateLastExecution := "Execution Date";
                if Format(pCashFlowManualExpense."Recurring Frequency") = '' THEN
                    EVALUATE(pCashFlowManualExpense."Recurring Frequency", '1M');
            END;

            WHILE ("Execution Date" <= gdDateLastExecution) AND (a < 1000) DO BEGIN
                a += 1;

                "Due Date" := "Execution Date";
                "Cash Flow Date" := "Execution Date";
                "Fecha Registro" := gdDummyDate;
                "Amount (LCY)" := -pCashFlowManualExpense.Amount;
                //"Amount (Currency)" := -pCashFlowManualExpense.Amount;
                if ("Amount (LCY)" <> 0)

                AND (("Execution Date" >= gdDuedateD) AND
                ("Execution Date" <= gdDuedateF)) THEN BEGIN

                    InsertLiqLine();
                    // Transfer Dimensions
                    if (Format(pCashFlowManualExpense."Recurring Frequency") = '99A') Or (Format(pCashFlowManualExpense."Recurring Frequency") = '99A') THEN BEGIN
                        "Execution Date" := gdDateLastExecution + 1;
                    END;
                END;
                if (Format(pCashFlowManualExpense."Recurring Frequency") = '99A') Or (Format(pCashFlowManualExpense."Recurring Frequency") = '99A') THEN
                    "Execution Date" := pCashFlowManualExpense."Starting Date" + 1
                ELSE
                    "Execution Date" := CALCDATE(pCashFlowManualExpense."Recurring Frequency", "Execution Date");

            END;
        end;
    end;

    local procedure InsertCFLineForManualRevenue(pCashFlowManualRevenue: Record "Cash Flow Manual Revenue")
    var
        "Execution Date": Date;
        a: Integer;
        Text1140028: Label '%1 ingresos neutr.';
    begin
        with gCFWorksheetLine2 do begin
            if pCashFlowManualRevenue."Starting Date" = 0D THEN
                pCashFlowManualRevenue."Starting Date" := gdDummyDate;// PostDate;
            if pCashFlowManualRevenue."Ending Date" = 0D THEN
                pCashFlowManualRevenue."Ending Date" := gdDummyDate;
            if (Format(pCashFlowManualRevenue."Recurring Frequency") = '') AND (pCashFlowManualRevenue."Una Sola Vez") THEN
                Evaluate(pCashFlowManualRevenue."Recurring Frequency", '99A');
            INIT;
            "Source Type" := "Source Type"::"Cash Flow Manual Revenue";
            "Document No." := pCashFlowManualRevenue.Code;
            "Cash Flow Account No." := pCashFlowManualRevenue."Cash Flow Account No.";
            "Shortcut Dimension 1 Code" := pCashFlowManualRevenue."Global Dimension 1 Code";
            "Shortcut Dimension 2 Code" := pCashFlowManualRevenue."Global Dimension 2 Code";
            "Cod banco" := pCashFlowManualRevenue.Banco;

            if gLiqAcc."Banco Informes" <> '' THEN
                "Nombre Banco" := gLiqAcc."Banco Informes"
            ELSE
                "Nombre Banco" := NBanco("Cod banco");
            Description := COPYSTR(STRSUBSTNO(Text1140028, pCashFlowManualRevenue.Description), 1, MAXSTRLEN(gCFWorksheetLine2.Description));
            //gdDateLastExecution := gCashFlowForecast."Manual Payments To";
            //if (pCashFlowManualRevenue."Ending Date" <> 0D) AND (pCashFlowManualRevenue."Ending Date" < gCashFlowForecast."Manual Payments To") THEN
            //    gdDateLastExecution := pCashFlowManualRevenue."Ending Date";
            gdDateLastExecution := pCashFlowManualRevenue."Ending Date";
            "Execution Date" := pCashFlowManualRevenue."Starting Date";
            //if (pCashFlowManualExpense."First Execution" <> 0D) AND
            // (pCashFlowManualExpense."First Execution" < Liquidity."Neutral Payments From") THEN
            //"Execution Date" := Liquidity."Neutral Payments From";
            if pCashFlowManualRevenue."Una Sola Vez" THEN BEGIN
                "Execution Date" := CALCDATE(pCashFlowManualRevenue."Recurring Frequency", gdDummyDate);
                gdDateLastExecution := "Execution Date";
                EVALUATE(pCashFlowManualRevenue."Recurring Frequency", '1M');
            END;

            WHILE ("Execution Date" <= gdDateLastExecution) AND (a < 1000) DO BEGIN
                a += 1;

                "Due Date" := "Execution Date";
                "Cash Flow Date" := "Execution Date";
                "Fecha Registro" := gdDummyDate;
                "Amount (LCY)" := pCashFlowManualRevenue.Amount;
                //"Amount (Currency)" := -pCashFlowManualExpense.Amount;
                if ("Amount (LCY)" <> 0)

                AND (("Execution Date" >= gdDuedateD) AND
                ("Execution Date" <= gdDuedateF)) THEN BEGIN

                    InsertLiqLine();
                    // Transfer Dimensions
                    if (Format(pCashFlowManualRevenue."Recurring Frequency") = '99A') Or (Format(pCashFlowManualRevenue."Recurring Frequency") = '') THEN BEGIN
                        "Execution Date" := gdDateLastExecution + 1;
                    END;
                END;
                if (Format(pCashFlowManualRevenue."Recurring Frequency") = '99A') Or (Format(pCashFlowManualRevenue."Recurring Frequency") = '') THEN
                    "Execution Date" := pCashFlowManualRevenue."Starting Date" + 1
                ELSE
                    "Execution Date" := CALCDATE(pCashFlowManualRevenue."Recurring Frequency", "Execution Date");

            END;
        end;
    end;

    local procedure InsertCFLineForGLBudget(GLAcc: Record "G/L Account"; var CFAccountForBudget: record "Cash Flow Account")
    begin
        with gCFWorksheetLine2 do begin
            Init();
            "Source Type" := "Source Type"::"G/L Budget";
            "Source No." := GLAcc."No.";
            "G/L Budget Name" := gGLBudgEntry."Budget Name";
            "Document No." := Format(gGLBudgEntry."Entry No.");
            "Cash Flow Account No." := CFAccountForBudget."No.";
            Description :=
              CopyStr(
                StrSubstNo(
                  glText030, GLAcc.Name, Format(gGLBudgEntry.Description)),
                1, MAXSTRLEN(Description));
            SetCashFlowDate(gCFWorksheetLine2, gGLBudgEntry.Date);
            "Amount (LCY)" := -gGLBudgEntry.Amount;
            "Shortcut Dimension 1 Code" := gGLBudgEntry."Global Dimension 1 Code";
            "Shortcut Dimension 2 Code" := gGLBudgEntry."Global Dimension 2 Code";
            "Dimension Set ID" := gGLBudgEntry."Dimension Set ID";
            InsertTempCFWorksheetLine(0);
        end;
    end;

    local procedure InsertCFLineForServiceLine(var pServiceLine: Record "Service Line")
    var
        ServiceLine2: Record "Service Line";
    begin
        ServiceLine2 := pServiceLine;
        if gbSummarized and (ServiceLine2.Next <> 0) and (ServiceLine2."Customer No." <> '') and
           (ServiceLine2."Document No." = pServiceLine."Document No.")
        then begin
            gDTotalAmt += CalculateLineAmountForServiceLine(pServiceLine);

            gbMultiSalesLines := true;
        end else
            with gCFWorksheetLine2 do begin
                Init();
                "Source Type" := "Source Type"::"Service Orders";
                "Source No." := pServiceLine."Document No.";
                "Source Line No." := pServiceLine."Line No.";
                "Document Type" := "Document Type"::Invoice;
                "Document Date" := gServiceHeader."Document Date";
                "Shortcut Dimension 1 Code" := gServiceHeader."Shortcut Dimension 1 Code";
                "Shortcut Dimension 2 Code" := gServiceHeader."Shortcut Dimension 2 Code";
                "Dimension Set ID" := gServiceHeader."Dimension Set ID";
                "Cash Flow Account No." := gCFSetup."Service CF Account No.";
                Description :=
                  CopyStr(
                    StrSubstNo(
                      glServiceDocumentDescriptionTxt,
                      gServiceHeader."Document Type",
                      gServiceHeader.Name,
                      Format(gServiceHeader."Order Date")),
                    1, MAXSTRLEN(Description));
                SetCashFlowDate(gCFWorksheetLine2, gServiceHeader."Due Date");
                "Document No." := pServiceLine."Document No.";
                "Amount (LCY)" := CalculateLineAmountForServiceLine(pServiceLine);

                if gbSummarized and gbMultiSalesLines then begin
                    "Amount (LCY)" := "Amount (LCY)" + gDTotalAmt;
                    gbMultiSalesLines := false;
                    gDTotalAmt := 0;
                end;

                if gPaymentMethod.Get(gPurchHeader."Payment Method Code") then
                    if (gPaymentMethod."Create Bills" or gPaymentMethod."Invoices to Cartera") and
                       (not gCarteraSetup.ReadPermission)
                    then
                        Error(glCannotCreateCarteraDocErr);

                if (pServiceLine."Document Type" <> pServiceLine."Document Type"::"Credit Memo") and
                   gCarteraSetup.ReadPermission and gPaymentMethod."Create Bills"
                then
                    SplitServInv(
                      gServiceHeader, gCFWorksheetLine2, "Amount (LCY)", "Amount (LCY)" - pServiceLine."Line Amount");

                if gCashFlowForecast."Consider CF Payment Terms" and (gCustomer."Cash Flow Payment Terms Code" <> '') then
                    "Payment Terms Code" := gCustomer."Cash Flow Payment Terms Code"
                else
                    "Payment Terms Code" := gServiceHeader."Payment Terms Code";

                if ("Amount (LCY)" <> 0) and not gPaymentMethod."Create Bills" then
                    InsertTempCFWorksheetLine(0);
            end;
    end;

    local procedure InsertCFLineForJobPlanningLine(var pJobPlanningLine: Record "Job Planning Line")
    var
        Job: Record Job;
        InsertConditionHasBeenMetAlready: Boolean;
    begin
        if Job.Get(pJobPlanningLine."Job No.") Then begin
            if (gTempCFWorksheetLine."Source Type" = gTempCFWorksheetLine."Source Type"::Job) and
               (pJobPlanningLine."Job No." = gTempCFWorksheetLine."Source No.") and
               (pJobPlanningLine."Planning Date" = gTempCFWorksheetLine."Document Date") and
               (pJobPlanningLine."Document No." = gTempCFWorksheetLine."Document No.")
            then begin
                InsertConditionHasBeenMetAlready := InsertConditionMet;
                gTempCFWorksheetLine."Amount (LCY)" += GetJobPlanningAmountForCFLine(pJobPlanningLine);
                InsertOrModifyCFLine(InsertConditionHasBeenMetAlready);
            end else
                with gCFWorksheetLine2 do begin
                    Init();
                    "Source Type" := "Source Type"::Job;
                    "Source No." := pJobPlanningLine."Job No.";
                    "Document Type" := "Document Type"::Invoice;
                    "Document Date" := pJobPlanningLine."Planning Date";
                    "Cash Flow Date" := "Document Date";
                    "Due Date" := "Document Date";
                    "Fecha Registro" := gdDummyDate;
                    Job.Get(pJobPlanningLine."Job No.");
                    "Shortcut Dimension 1 Code" := Job."Global Dimension 1 Code";
                    "Shortcut Dimension 2 Code" := Job."Global Dimension 2 Code";
                    "Cash Flow Account No." := gCFSetup."Job CF Account No.";
                    Description :=
                      CopyStr(
                        StrSubstNo(
                          glText025,
                          Job.TableCaption,
                          Job.Description,
                          Format(pJobPlanningLine."Document Date")),
                        1, MAXSTRLEN(Description));
                    SetCashFlowDate(gCFWorksheetLine2, pJobPlanningLine."Planning Date");
                    "Document No." := pJobPlanningLine."Document No.";
                    "Amount (LCY)" := GetJobPlanningAmountForCFLine(pJobPlanningLine);

                    InsertTempCFWorksheetLine(0);
                end;
        end;
    end;

    local procedure InsertCfLineForPrestamos(var pDetallePrestamo: Record "Detalle Prestamo")
    var
        InsertConditionHasBeenMetAlready: Boolean;
        rCab: Record "Cabecera Prestamo";
        PresLine2: Record "Detalle Prestamo";
        rBanc: Record "Bank Account";
        Factor: Decimal;
        gDTotalAmtCurrency: Decimal;
        TotalLineAmount: Decimal;
    begin
        if NOT rCab.GET(pDetallePrestamo."Código Del Prestamo") THEN
            Exit;
        if rCab.Renting = true Then Exit;
        if rCab.Empresa <> '' THEN Exit;
        PresLine2 := pDetallePrestamo;

        if gbSummarized AND (PresLine2.NEXT <> 0) AND (PresLine2."Código Del Prestamo" =
        pDetallePrestamo."Código Del Prestamo") THEN BEGIN
            gCurrExchRate.SETRANGE("Currency Code", '');
            gCurrExchRate.SETRANGE("Starting Date", 0D, pDetallePrestamo.Fecha);
            if gCurrExchRate.FIND('+') THEN
                Factor := gCurrExchRate."Exchange Rate Amount"
            ELSE
                Factor := 1;
            gDTotalAmt := gDTotalAmt + ROUND(gCurrExchRate.ExchangeAmtFCYToLCYAdjmt(pDetallePrestamo.Fecha,
                                    '', pDetallePrestamo."A Pagar", Factor));
            gDTotalAmtCurrency := gDTotalAmtCurrency + pDetallePrestamo."A Pagar";
            TotalLineAmount := TotalLineAmount + pDetallePrestamo."A Pagar";
            gbMultiSalesLines := TRUE;
        END ELSE BEGIN

            WITH gCFWorksheetLine2 DO BEGIN
                INIT;
                "Source Type" := gCFWorksheetLine2."Source Type"::"Detalle Préstamos";
                "Shortcut Dimension 2 Code" := rCab."Global Dimension 1 Code";
                "Shortcut Dimension 1 Code" := rCab."Global Dimension 2 Code";
                // "Gen. Bus. Posting Group" := '';
                //"Account Type" := gCFWorksheetLine2."Account Type"::Credit;
                "Source No." := Copystr(rCab."Código Del Prestamo", 1, 20);
                "Cod banco" := rCab.Banco;
                gLiqAcc.RESET;
                gLiqAcc.SETRANGE(gLiqAcc."Banco Informes");
                gLiqAcc.SETRANGE(gLiqAcc."Source Type", gLiqAcc."Source Type"::"Detalle Préstamos");
                gLiqAcc.SETRANGE(gLiqAcc."Cód Prestamo", pDetallePrestamo."Código Del Prestamo");
                if NOT gLiqAcc.FINDFIRST THEN BEGIN
                    gLiqAcc.SETRANGE(gLiqAcc."Cód Prestamo");
                    gLiqAcc.SETRANGE(gLiqAcc."Cod banco", rCab.Banco);
                    if NOT gLiqAcc.FINDFIRST THEN BEGIN
                        gLiqAcc.SETRANGE(gLiqAcc."Cod banco");
                        if rBanc.GET(rCab.Banco) THEN BEGIN
                            if rBanc."Name 2" = '' THEN rBanc."Name 2" := 'ZZZZZ';
                            gLiqAcc.SETRANGE(gLiqAcc."Banco Informes", rBanc."Name 2");
                        END ELSE
                            Exit;
                    END;
                END;
                if NOT gLiqAcc.FINDFIRST THEN
                    Exit;
                "Cash flow Account No." := gLiqAcc."No.";
                Description := COPYSTR(STRSUBSTNO('Cuota Prestamo %1 %2', rCab."Código Del Prestamo",
                                        FORMAT(pDetallePrestamo.Fecha)), 1, MAXSTRLEN(gCFWorksheetLine2.Description));
                "Due Date" := pDetallePrestamo.Fecha;
                "Cash flow Date" := pDetallePrestamo.Fecha;
                "Fecha Registro" := gdDummyDate;
                "Document No." := COPYSTR(pDetallePrestamo."Código Del Prestamo", 1,
                MAXSTRLEN("Document No."));


                "Amount (LCY)" := pDetallePrestamo."A Pagar";
                gCurrExchRate.SETRANGE("Currency Code", '');
                gCurrExchRate.SETRANGE("Starting Date", 0D, pDetallePrestamo.Fecha);
                if gCurrExchRate.FIND('+') THEN
                    Factor := gCurrExchRate."Exchange Rate Amount"
                ELSE
                    Factor := 1;
                "Amount (LCY)" := ROUND(gCurrExchRate.ExchangeAmtFCYToLCYAdjmt(pDetallePrestamo.Fecha,
                        '', pDetallePrestamo."A Pagar", Factor));
                "Payment Discount" := 0;
                // if gCashFlowForecast."Consider Discount" THEN BEGIN
                // Amount := ROUND(Amount - Amount * "Payment Discount");
                // "Amount (Currency)" := ROUND("Amount (Currency)" - "Amount (Currency)" * "Payment Discount");
                // END;

                if gbSummarized AND gbMultiSalesLines THEN BEGIN
                    "Amount (LCY)" := "Amount (LCY)" + gDTotalAmt;
                    //"Amount (Currency)" := "Amount (Currency)" + gDTotalAmtCurrency;
                    pDetallePrestamo."A Pagar" := pDetallePrestamo."A Pagar" + TotalLineAmount;
                    gbMultiSalesLines := FALSE;
                    gDTotalAmt := 0;
                    gDTotalAmtCurrency := 0;
                    TotalLineAmount := 0;
                END;



                //"Currency Code" := '';

                if gLiqAcc."Banco Informes" <> '' THEN
                    "Nombre Banco" := gLiqAcc."Banco Informes"
                ELSE
                    "Nombre Banco" := NBanco("Cod banco");
                "Amount (LCY)" := -"Amount (LCY)";
                if ("Amount (LCY)" <> 0)
                AND ((pDetallePrestamo.Fecha >= gdDuedateD) AND
                (pDetallePrestamo.Fecha <= gdDuedateF)) THEN BEGIN
                    if pDetallePrestamo.Liquidado = FALSE THEN
                        InsertLiqLine();
                    // DocDim.RESET;
                    // DocDim.SETRANGE("Table ID",DATABASE::"Cabecera Prestamo");
                    // DocDim.SETRANGE("Document No.",
                    // COPYSTR("Código Del Prestamo",1,MAXSTRLEN("Document No.")));
                    // LiqDimMgt.MoveDocDimToJnlLineDim(DocDim,JnlLineDim,DATABASE::"Liq. Journal Line", LiqLine."Journal Template Name",
                    //                                 LiqLine."Journal Batch Name",LiqLine."Line No.",0);
                    gCFWorksheetLine2.Validate("Shortcut Dimension 1 Code", rCab."Global Dimension 1 Code");
                    gCFWorksheetLine2.Validate("Shortcut Dimension 2 Code", rCab."Global Dimension 2 Code");
                    gCFWorksheetLine2.Validate("Shortcut Dimension 3 Code", rCab."Global Dimension 3 Code");
                    gCFWorksheetLine2.Validate("Shortcut Dimension 4 Code", rCab."Global Dimension 4 Code");
                    gCFWorksheetLine2.Validate("Shortcut Dimension 5 Code", rCab."Global Dimension 5 Code");


                END;
            END;
        END;
    end;

    local procedure InsertCfLineForRenting(var pDetalleRenting: record "Detalle Prestamo")
    var
        InsertConditionHasBeenMetAlready: Boolean;
        rCab: Record "Cabecera Prestamo";
        PresLine2: Record "Detalle Prestamo";
        rBanc: Record "Bank Account";
        Factor: Decimal;
        gDTotalAmtCurrency: Decimal;
        TotalLineAmount: Decimal;
    begin
        if NOT rCab.GET(pDetalleRenting."Código Del Prestamo") THEN
            Exit;
        if rCab.Renting = false Then Exit;
        if rCab.Empresa <> '' THEN Exit;
        PresLine2 := pDetalleRenting;

        if gbSummarized AND (PresLine2.NEXT <> 0) AND (PresLine2."Código Del Prestamo" =
        pDetalleRenting."Código Del Prestamo") THEN BEGIN
            gCurrExchRate.SETRANGE("Currency Code", '');
            gCurrExchRate.SETRANGE("Starting Date", 0D, pDetalleRenting.Fecha);
            if gCurrExchRate.FIND('+') THEN
                Factor := gCurrExchRate."Exchange Rate Amount"
            ELSE
                Factor := 1;
            gDTotalAmt := gDTotalAmt + ROUND(gCurrExchRate.ExchangeAmtFCYToLCYAdjmt(pDetalleRenting.Fecha,
                                    '', pDetalleRenting."A Pagar", Factor));
            gDTotalAmtCurrency := gDTotalAmtCurrency + pDetalleRenting."A Pagar";
            TotalLineAmount := TotalLineAmount + pDetalleRenting."A Pagar";
            gbMultiSalesLines := TRUE;
        END ELSE BEGIN

            WITH gCFWorksheetLine2 DO BEGIN
                INIT;
                "Source Type" := gCFWorksheetLine2."Source Type"::Rentings;
                "Shortcut Dimension 2 Code" := rCab."Global Dimension 1 Code";
                "Shortcut Dimension 1 Code" := rCab."Global Dimension 2 Code";
                // "Gen. Bus. Posting Group" := '';
                //"Account Type" := gCFWorksheetLine2."Account Type"::Credit;
                "Source No." := Copystr(rCab."Código Del Prestamo", 1, 20);
                "Cod banco" := rCab.Banco;
                gLiqAcc.RESET;
                gLiqAcc.SETRANGE(gLiqAcc."Banco Informes");
                gLiqAcc.SETRANGE(gLiqAcc."Source Type", gLiqAcc."Source Type"::Rentings);
                gLiqAcc.SETRANGE(gLiqAcc."Cód Prestamo", pDetalleRenting."Código Del Prestamo");
                if NOT gLiqAcc.FINDFIRST THEN BEGIN
                    gLiqAcc.SETRANGE(gLiqAcc."Cód Prestamo");
                    gLiqAcc.SETRANGE(gLiqAcc."Cod banco", rCab.Banco);
                    if NOT gLiqAcc.FINDFIRST THEN BEGIN
                        gLiqAcc.SETRANGE(gLiqAcc."Cod banco");
                        if rBanc.GET(rCab.Banco) THEN BEGIN
                            if rBanc."Name 2" = '' THEN rBanc."Name 2" := 'ZZZZZ';
                            gLiqAcc.SETRANGE(gLiqAcc."Banco Informes", rBanc."Name 2");
                        END ELSE
                            Exit;
                    END;
                END;
                if NOT gLiqAcc.FINDFIRST THEN
                    Exit;
                "Cash flow Account No." := gLiqAcc."No.";
                Description := COPYSTR(STRSUBSTNO('Cuota Renting %1 %2', rCab."Código Del Prestamo",
                                        FORMAT(pDetalleRenting.Fecha)), 1, MAXSTRLEN(gCFWorksheetLine2.Description));
                "Due Date" := pDetalleRenting.Fecha;
                "Cash flow Date" := pDetalleRenting.Fecha;
                "Fecha Registro" := gdDummyDate;
                "Document No." := COPYSTR(pDetalleRenting."Código Del Prestamo", 1,
                MAXSTRLEN("Document No."));


                "Amount (LCY)" := pDetalleRenting."A Pagar";
                gCurrExchRate.SETRANGE("Currency Code", '');
                gCurrExchRate.SETRANGE("Starting Date", 0D, pDetalleRenting.Fecha);
                if gCurrExchRate.FIND('+') THEN
                    Factor := gCurrExchRate."Exchange Rate Amount"
                ELSE
                    Factor := 1;
                "Amount (LCY)" := ROUND(gCurrExchRate.ExchangeAmtFCYToLCYAdjmt(pDetalleRenting.Fecha,
                        '', pDetalleRenting."A Pagar", Factor));
                "Payment Discount" := 0;
                // if gCashFlowForecast."Consider Discount" THEN BEGIN
                // Amount := ROUND(Amount - Amount * "Payment Discount");
                // "Amount (Currency)" := ROUND("Amount (Currency)" - "Amount (Currency)" * "Payment Discount");
                // END;

                if gbSummarized AND gbMultiSalesLines THEN BEGIN
                    "Amount (LCY)" := "Amount (LCY)" + gDTotalAmt;
                    //"Amount (Currency)" := "Amount (Currency)" + gDTotalAmtCurrency;
                    pDetalleRenting."A Pagar" := pDetalleRenting."A Pagar" + TotalLineAmount;
                    gbMultiSalesLines := FALSE;
                    gDTotalAmt := 0;
                    gDTotalAmtCurrency := 0;
                    TotalLineAmount := 0;
                END;



                //"Currency Code" := '';

                if gLiqAcc."Banco Informes" <> '' THEN
                    "Nombre Banco" := gLiqAcc."Banco Informes"
                ELSE
                    "Nombre Banco" := NBanco("Cod banco");
                "Amount (LCY)" := -"Amount (LCY)";
                if ("Amount (LCY)" <> 0)
                AND ((pDetalleRenting.Fecha >= gdDuedateD) AND
                (pDetalleRenting.Fecha <= gdDuedateF)) THEN BEGIN
                    if pDetalleRenting.Facturado = FALSE THEN
                        InsertLiqLine();
                    // DocDim.RESET;
                    // DocDim.SETRANGE("Table ID",DATABASE::"Cabecera Prestamo");
                    // DocDim.SETRANGE("Document No.",
                    // COPYSTR("Código Del Prestamo",1,MAXSTRLEN("Document No.")));
                    // LiqDimMgt.MoveDocDimToJnlLineDim(DocDim,JnlLineDim,DATABASE::"Liq. Journal Line", LiqLine."Journal Template Name",
                    //                                 LiqLine."Journal Batch Name",LiqLine."Line No.",0);
                    gCFWorksheetLine2.Validate("Shortcut Dimension 1 Code", rCab."Global Dimension 1 Code");
                    gCFWorksheetLine2.Validate("Shortcut Dimension 2 Code", rCab."Global Dimension 2 Code");
                    gCFWorksheetLine2.Validate("Shortcut Dimension 3 Code", rCab."Global Dimension 3 Code");
                    gCFWorksheetLine2.Validate("Shortcut Dimension 4 Code", rCab."Global Dimension 4 Code");
                    gCFWorksheetLine2.Validate("Shortcut Dimension 5 Code", rCab."Global Dimension 5 Code");


                END;
            END;
        END;
    end;

    local procedure InsertCfLineForEmplazaMientos(var lMovimientosEmplazamiento: Record "Mov. emplazamientos")
    var
        InsertConditionHasBeenMetAlready: Boolean;
        rCab: Record "Cabecera Prestamo";
        rBanc: Record "Bank Account";
        Factor: Decimal;
        gDTotalAmtCurrency: Decimal;
        TotalLineAmount: Decimal;
        PresLine2: Record "Mov. emplazamientos";
        PaymenthMetohod: Record "Payment Method";
        Text1140039: Label 'Vto emplaz. %1 %2';
    begin

        if lMovimientosEmplazamiento."Nº Factura definitivo" <> '' THEN Exit;
        PresLine2 := lMovimientosEmplazamiento;


        WITH gCFWorksheetLine2 DO BEGIN
            INIT;
            "Source Type" := gCFWorksheetLine2."Source Type"::"Movimientos emplazamientos";
            "Shortcut Dimension 2 Code" := '';//rCab."Global Dimension 1 Code";
            "Shortcut Dimension 1 Code" := '';//rCab."Global Dimension 2 Code";
            "Source No." := lMovimientosEmplazamiento."Nº proveedor";
            "Associated Entry No." := lMovimientosEmplazamiento."Nº mov.";
            "Cod banco" := lMovimientosEmplazamiento.Banco;//rCab.Banco;
            if lMovimientosEmplazamiento."Fecha prevista pago" < gdDuedateD THEN Atrasados := TRUE ELSE Atrasados := FALSE;
            gLiqAcc.SETRANGE(gLiqAcc."Source Type", gLiqAcc."Source Type"::"Movimientos emplazamientos");
            PaymenthMetohod.SETRANGE(PaymenthMetohod."Forma de Pago Emplazamiento", lMovimientosEmplazamiento."Cod. Pago");
            if NOT PaymenthMetohod.FINDFIRST THEN PaymenthMetohod.INIT;
            gLiqAcc.SETRANGE(gLiqAcc."Payment Method Code", PaymenthMetohod.Code);
            if Atrasados THEN
                gLiqAcc.SETRANGE(gLiqAcc."Solo Atrasados", TRUE);
            if NOT gLiqAcc.FINDFIRST THEN
                gLiqAcc.SETRANGE(gLiqAcc."Payment Method Code");
            if NOT gLiqAcc.FINDFIRST THEN
                Exit;
            "Cash Flow Account No." := gLiqAcc."No.";
            Description := COPYSTR(STRSUBSTNO(Text1140039, lMovimientosEmplazamiento."Nº emplazamiento",
                                    FORMAT(lMovimientosEmplazamiento."Fecha vencimiento")), 1, MAXSTRLEN(gCFWorksheetLine2.Description));
            "Due Date" := lMovimientosEmplazamiento."Fecha prevista pago";
            "Cash Flow Date" := lMovimientosEmplazamiento."Fecha prevista pago";
            "Fecha Registro" := gdDummyDate;
            "Document No." := lMovimientosEmplazamiento."Nº emplazamiento";
            "Amount (LCY)" := lMovimientosEmplazamiento."Importe pendiente";//+PresLine2."Importe pagado";
            Factor := 1;
            //Amount :="Mov. emplazamientos"."Importe pendiente";//,Factor));
            "Payment Discount" := 0;//"Amount (LCY)"* lMovimientosEmplazamiento."Discount %" / 100;
            if gbSummarized AND gbMultiSalesLines THEN BEGIN
                "Amount (LCY)" := "Amount (LCY)" + gDTotalAmt;
                //"Amount (Currency)" := "Amount (Currency)" + gDTotalAmtCurrency;
                //"Importe pendiente" := "Importe pendiente" + TotalLineAmount;
                gbMultiSalesLines := FALSE;
                gDTotalAmt := 0;
                gDTotalAmtCurrency := 0;
                TotalLineAmount := 0;
            END;
            //"Currency Code" := '';
            if gLiqAcc."Banco Informes" <> '' THEN
                "Nombre Banco" := gLiqAcc."Banco Informes"
            ELSE
                "Nombre Banco" := NBanco("Cod banco");
            PaymenthMetohod.SETRANGE(PaymenthMetohod."Forma de Pago Emplazamiento", lMovimientosEmplazamiento."Cod. Pago");
            if NOT PaymenthMetohod.FINDFIRST THEN PaymenthMetohod.INIT;

            if gLiqAcc."Payment Method Code" <> '' THEN
                if gLiqAcc."Payment Method Code" <> PaymenthMetohod.Code THEN "Amount (LCY)" := 0;
            "Amount (LCY)" := -"Amount (LCY)";
            if (("Amount (LCY)" <> 0) AND (lMovimientosEmplazamiento."Nº Factura definitivo" = ''))
            // AND (("Fecha vencimiento">=gdDuedateD) AND
            //  ("Fecha vencimiento"<=gdDuedateF))  
            THEN BEGIN
                InsertLiqLine();
            END;
        END;
        //END;
    end;

    local procedure InsertCFLineForTax(SourceTableNum: Integer)
    var
        TaglXPayableDate: Date;
        SourceNo: Code[20];
        InsertConditionHasBeenMetAlready: Boolean;
    begin
        TaglXPayableDate := GetTaglXPayableDateFromSource(SourceTableNum);
        if IsDateBeforeStartOfCurrentPeriod(TaglXPayableDate) or HasTaxBeenPaidOn(TaglXPayableDate) then
            exit;
        SourceNo := Format(SourceTableNum);
        if gbSummarized and (giTaxLastSourceTableNumProcessed <> SourceTableNum) and
           (gDTaxLastPayableDateProcessed <> TaglXPayableDate)
        then begin
            gDTotalAmt += GetTaxAmountFromSource(SourceTableNum);
            gbMultiSalesLines := true;
        end else
            if (gTempCFWorksheetLine."Source Type" = gTempCFWorksheetLine."Source Type"::Tax) and
               (gTempCFWorksheetLine."Source No." = SourceNo) and
               (gTempCFWorksheetLine."Document Date" = TaglXPayableDate)
            then begin
                InsertConditionHasBeenMetAlready := InsertConditionMet;
                gTempCFWorksheetLine."Amount (LCY)" += GetTaxAmountFromSource(SourceTableNum);
                InsertOrModifyCFLine(InsertConditionHasBeenMetAlready);
            end else
                with gCFWorksheetLine2 do begin
                    Init();
                    "Source Type" := "Source Type"::Tax;
                    "Source No." := SourceNo;
                    "Document Type" := "Document Type"::" ";
                    "Document Date" := TaglXPayableDate;

                    "Shortcut Dimension 1 Code" := '';
                    "Shortcut Dimension 2 Code" := '';
                    "Cash Flow Account No." := gCFSetup."Tax CF Account No.";
                    Description := GetDescriptionForTaxCashFlowLine(SourceTableNum);
                    SetCashFlowDate(gCFWorksheetLine2, "Document Date");
                    "Document No." := '';
                    "Amount (LCY)" := GetTaxAmountFromSource(SourceTableNum);

                    if gbSummarized and gbMultiSalesLines and (giTaxLastSourceTableNumProcessed = SourceTableNum) then begin
                        "Amount (LCY)" := "Amount (LCY)" + gDTotalAmt;
                        gbMultiSalesLines := false;
                        gDTotalAmt := 0;
                    end;

                    InsertTempCFWorksheetLine(0);
                end;

        giTaxLastSourceTableNumProcessed := SourceTableNum;
        gdTaxLastPayableDateProcessed := TaglXPayableDate;
    end;


    local procedure InsertCFLineForAzureAIForecast(SourceTableNum: Integer; var pCashFlowAzureAIBuffer: Record "Cash Flow Azure AI Buffer")
    begin
        if pCashFlowAzureAIBuffer."Delta %" > gCFSetup."Variance %" then
            exit;

        with gCFWorksheetLine2 do begin
            Init();
            "Source Type" := "Source Type"::"Azure AI";
            "Source No." := Format(SourceTableNum);
            "Document Type" := "Document Type"::" ";
            "Document Date" := pCashFlowAzureAIBuffer."Period Start";
            SetCashFlowDate(gCFWorksheetLine2, "Document Date");
            "Amount (LCY)" := pCashFlowAzureAIBuffer.Amount;

            case pCashFlowAzureAIBuffer."Group Id" of
                glXRECEIVABLESTxt:
                    begin
                        "Cash Flow Account No." := gCFSetup."Receivables CF Account No.";
                        Description :=
                          StrSubstNo(
                            glAzureAIForecastDescriptionTxt, LowerCase(glXRECEIVABLESTxt), pCashFlowAzureAIBuffer."Period Start",
                            Round(pCashFlowAzureAIBuffer.Delta));
                    end;
                glXPAYABLESTxt:
                    begin
                        "Cash Flow Account No." := gCFSetup."Payables CF Account No.";
                        Description :=
                          StrSubstNo(
                            glAzureAIForecastDescriptionTxt, LowerCase(glXPAYABLESTxt), pCashFlowAzureAIBuffer."Period Start",
                            Round(pCashFlowAzureAIBuffer.Delta));
                    end;
                glXPAYABLESCORRECTIONTxt:
                    if gBArrayConsiderSource["Source Type"::Payables.AsInteger()] then begin
                        "Cash Flow Account No." := gCFSetup."Payables CF Account No.";
                        Description := StrSubstNo(glAzureAICorrectionDescriptionTxt, LowerCase(glXPAYABLESTxt));
                    end else
                        exit;
                glXRECEIVABLESCORRECTIONTxt:
                    if gBArrayConsiderSource["Source Type"::Receivables.AsInteger()] then begin
                        "Cash Flow Account No." := gCFSetup."Receivables CF Account No.";
                        Description := StrSubstNo(glAzureAICorrectionDescriptionTxt, LowerCase(glXRECEIVABLESTxt))
                    end else
                        exit;
                glXPURCHORDERSTxt:
                    if gBArrayConsiderSource["Source Type"::"Purchase Orders".AsInteger()] then begin
                        "Cash Flow Account No." := gCFSetup."Purch. Order CF Account No.";
                        Description := StrSubstNo(glAzureAIOrdersCorrectionDescriptionTxt, LowerCase(glXPURCHORDERSTxt))
                    end else
                        exit;
                glXSALESORDERSTxt:
                    if gBArrayConsiderSource["Source Type"::"Sales Orders".AsInteger()] then begin
                        "Cash Flow Account No." := gCFSetup."Sales Order CF Account No.";
                        Description := StrSubstNo(glAzureAIOrdersCorrectionDescriptionTxt, LowerCase(glXSALESORDERSTxt))
                    end else
                        exit;
                glXTAglXRECEIVABLESTxt:
                    if gBArrayConsiderSource["Source Type"::Tax.AsInteger()] then begin
                        "Cash Flow Account No." := gCFSetup."Tax CF Account No.";
                        Description :=
                          StrSubstNo(
                            glAzureAIForecastTaxDescriptionTxt, LowerCase(glXRECEIVABLESTxt), pCashFlowAzureAIBuffer."Period Start",
                            Round(pCashFlowAzureAIBuffer.Delta))
                    end else
                        exit;
                glXTAglXPAYABLESTxt:
                    if gBArrayConsiderSource["Source Type"::Tax.AsInteger()] then begin
                        "Cash Flow Account No." := gCFSetup."Tax CF Account No.";
                        Description :=
                          StrSubstNo(
                            glAzureAIForecastTaxDescriptionTxt, LowerCase(glXPAYABLESTxt), pCashFlowAzureAIBuffer."Period Start",
                            Round(pCashFlowAzureAIBuffer.Delta));
                    end else
                        exit;
                glXTAglXPAYABLESCORRECTIONTxt:
                    if gBArrayConsiderSource["Source Type"::Tax.AsInteger()] then begin
                        "Cash Flow Account No." := gCFSetup."Tax CF Account No.";
                        Description := StrSubstNo(glAzureAICorrectionTaxDescriptionTxt, LowerCase(glXPAYABLESTxt));
                    end else
                        exit;
                glXTAglXRECEIVABLESCORRECTIONTxt:
                    if gBArrayConsiderSource["Source Type"::Tax.AsInteger()] then begin
                        "Cash Flow Account No." := gCFSetup."Tax CF Account No.";
                        Description := StrSubstNo(glAzureAICorrectionTaxDescriptionTxt, LowerCase(glXRECEIVABLESTxt))
                    end else
                        exit;
                glXTAglXPURCHORDERSTxt:
                    if gBArrayConsiderSource["Source Type"::Tax.AsInteger()] then begin
                        "Cash Flow Account No." := gCFSetup."Tax CF Account No.";
                        Description := StrSubstNo(glAzureAIOrdersTaxCorrectionDescriptionTxt, LowerCase(glXPURCHORDERSTxt))
                    end else
                        exit;
                glXTAglXSALESORDERSTxt:
                    if gBArrayConsiderSource["Source Type"::Tax.AsInteger()] then begin
                        "Cash Flow Account No." := gCFSetup."Tax CF Account No.";
                        Description := StrSubstNo(glAzureAIOrdersTaxCorrectionDescriptionTxt, LowerCase(glXSALESORDERSTxt))
                    end else
                        exit;
            end;
        end;

        InsertTempCFWorksheetLine(0);
    end;

    local procedure InsertOrModifyCFLine(InsertConditionHasBeenMetAlready: Boolean)
    begin
        gCFWorksheetLine2."Amount (LCY)" += gTempCFWorksheetLine."Amount (LCY)";
        if InsertConditionHasBeenMetAlready then
            gTempCFWorksheetLine.Modify
        else
            InsertTempCFWorksheetLine(0);
    end;

    local procedure GetSubPostingGLAccounts(var GLAccount: Record "G/L Account"; var TempGLAccount: Record "G/L Account" temporary)
    var
        SubGLAccount: Record "G/L Account";
    begin
        if not GLAccount.FindSet() then
            exit;

        repeat
            case GLAccount."Account Type" of
                GLAccount."Account Type"::Posting:
                    begin
                        TempGLAccount.Init();
                        TempGLAccount.TransferFields(GLAccount);
                        if TempGLAccount.Insert() then;
                    end;
                GLAccount."Account Type"::Heading:
                    begin
                        SubGLAccount.SetFilter("No.", GLAccount.Totaling);
                        SubGLAccount.FilterGroup := 2;
                        SubGLAccount.SetFilter("No.", '<>%1', GLAccount."No.");
                        SubGLAccount.FilterGroup := 0;
                        GetSubPostingGLAccounts(SubGLAccount, TempGLAccount);
                    end;
            end;
        until GLAccount.Next = 0;
    end;

    local procedure SetCashFlowDate(var CashFlowWorksheetLine: Record "Cash Flow Worksheet Line"; CashFlowDate: Date)
    begin
        CashFlowWorksheetLine."Cash Flow Date" := CashFlowDate;
        if CashFlowDate < WorkDate then begin
            if gSelectionCashFlowForecast."Overdue CF Dates to Work Date" then
                CashFlowWorksheetLine."Cash Flow Date" := WorkDate;
            CashFlowWorksheetLine.Overdue := true;
        end
    end;

    local procedure CalculateLineAmountForPurchaseLine(PurchHeader2: Record "Purchase Header"; PurchaseLine: Record "Purchase Line"): Decimal
    var
        PrepmtAmtInvLCY: Decimal;
    begin
        if PurchHeader2."Currency Code" <> '' then begin
            gCurrency.Get(PurchHeader2."Currency Code");
            PrepmtAmtInvLCY :=
              Round(
                gCurrExchRate.ExchangeAmtFCYToLCY(
                  PurchHeader2."Posting Date", PurchHeader2."Currency Code",
                  PurchaseLine."Prepmt. Amt. Inv.", PurchHeader2."Currency Factor"),
                gCurrency."Amount Rounding Precision");
        end else
            PrepmtAmtInvLCY := PurchaseLine."Prepmt. Amt. Inv.";

        gCurrency.InitRoundingPrecision;
        if PurchHeader2."Prices Including VAT" then
            exit(-(GetPurchaseAmountForCFLine(PurchaseLine) - PrepmtAmtInvLCY));
        exit(
          -(GetPurchaseAmountForCFLine(PurchaseLine) -
            (PrepmtAmtInvLCY +
             Round(PrepmtAmtInvLCY * PurchaseLine."VAT %" / 100, gCurrency."Amount Rounding Precision", gCurrency.VATRoundingDirection))));
    end;

    local procedure CalculateLineAmountForSalesLine(SalesHeader2: Record "Sales Header"; SalesLine: Record "Sales Line"): Decimal
    var
        PrepmtAmtInvLCY: Decimal;
    begin
        if SalesHeader2."Currency Code" <> '' then begin
            gCurrency.Get(SalesHeader2."Currency Code");
            PrepmtAmtInvLCY :=
              Round(
                gCurrExchRate.ExchangeAmtFCYToLCY(
                  SalesHeader2."Posting Date", SalesHeader2."Currency Code",
                  SalesLine."Prepmt. Amt. Inv.", SalesHeader2."Currency Factor"),
                gCurrency."Amount Rounding Precision");
        end else
            PrepmtAmtInvLCY := SalesLine."Prepmt. Amt. Inv.";

        gCurrency.InitRoundingPrecision;
        if SalesHeader2."Prices Including VAT" then
            exit(GetSalesAmountForCFLine(SalesLine) - PrepmtAmtInvLCY);
        exit(
          GetSalesAmountForCFLine(SalesLine) -
          (PrepmtAmtInvLCY +
           Round(PrepmtAmtInvLCY * SalesLine."VAT %" / 100, gCurrency."Amount Rounding Precision", gCurrency.VATRoundingDirection)));
    end;

    local procedure CalculateLineAmountForServiceLine(ServiceLine: Record "Service Line"): Decimal
    begin
        exit(GetServiceAmountForCFLine(ServiceLine));
    end;

    local procedure NoOptionsChosen(): Boolean
    var
        gESourceType: Integer;
    begin
        for gESourceType := 1 to ArrayLen(gBArrayConsiderSource) do
            if gBArrayConsiderSource[gESourceType] then
                exit(false);
        exit(true);
    end;

    /// <summary>
    /// InitializeRequest.
    /// </summary>
    /// <param name="NewgBArrayConsiderSource">array[23] of Boolean.</param>
    /// <param name="CFNo">Code[20].</param>
    /// <param name="NewGLBudgetName">Code[10].</param>
    /// <param name="GroupByDocumentType">Boolean.</param>
    procedure InitializeRequest(NewgBArrayConsiderSource: array[23] of Boolean; CFNo: Code[20]; NewGLBudgetName: Code[10]; GroupByDocumentType: Boolean)
    begin
        CopyArray(gBArrayConsiderSource, NewgBArrayConsiderSource, 1);
        gCCashFlowNo := CFNo;
        gCGLBudgName := NewGLBudgetName;
        gbSummarized := GroupByDocumentType;
    end;

    local procedure InsertManualData(ExecutionDate: Date; CashFlowForecast: Record "Cash Flow Forecast"; ManualAmount: Decimal)
    begin
        if ((CashFlowForecast."Manual Payments From" <> 0D) and
            (ExecutionDate < CashFlowForecast."Manual Payments From")) or
           ((CashFlowForecast."Manual Payments To" <> 0D) and
            (ExecutionDate > CashFlowForecast."Manual Payments To"))
        then
            exit;

        with gCFWorksheetLine2 do begin
            SetCashFlowDate(gCFWorksheetLine2, ExecutionDate);
            "Amount (LCY)" := ManualAmount;
            InsertTempCFWorksheetLine(0);
        end;
    end;

    local procedure SplitSalesInv(var SalesHeader: Record "Sales Header"; var CFJournalLine3: Record "Cash Flow Worksheet Line"; TotalAmount: Decimal; VATAmount: Decimal)
    var
        Installment: Record Installment;
        DueDateAdjust: Codeunit "Due Date-Adjust";
        CurrDocNo: Integer;
        CurrencyFactor: Decimal;
        RemainingAmount: Decimal;
        TotalPerc: Decimal;
        NextDueDate: Date;
    begin
        with SalesHeader do begin
            if not gPaymentMethod.Get("Payment Method Code") then
                exit;
            if (not gPaymentMethod."Create Bills") and (not gPaymentMethod."Invoices to Cartera") then
                exit;
            if gPaymentMethod."Create Bills" and ("Document Type" = "Document Type"::"Credit Memo") then
                Error(
                  glText1100000,
                  FieldCaption("Payment Method Code"));

            if "Currency Code" = '' then
                CurrencyFactor := 1
            else
                CurrencyFactor := "Currency Factor";

            gSalesSetup.Get();
            TestField("Payment Terms Code");
            gPaymentTerms.Get("Payment Terms Code");
            gPaymentTerms.CalcFields("No. of Installments");
            if gPaymentTerms."No. of Installments" = 0 then
                gPaymentTerms."No. of Installments" := 1;
            if gPaymentMethod."Invoices to Cartera" and (gPaymentTerms."No. of Installments" > 1) then
                Error(
                  glText1100001,
                  gPaymentTerms.FieldCaption("No. of Installments"),
                  gPaymentMethod.FieldCaption("Invoices to Cartera"),
                  gPaymentMethod.TableCaption);

            RemainingAmount := TotalAmount;

            // create bills
            if "Currency Code" = '' then begin
                gCurrency."Invoice Rounding Precision" := gGLSetup."Inv. Rounding Precision (LCY)";
                gCurrency."Invoice Rounding Type" := gGLSetup."Inv. Rounding Type (LCY)";
                gCurrency."Amount Rounding Precision" := gGLSetup."Amount Rounding Precision";
                if gSalesSetup."Invoice Rounding" then
                    gGLSetup.TestField("Inv. Rounding Precision (LCY)")
                else
                    gGLSetup.TestField("Amount Rounding Precision");
            end else begin
                gCurrency.Get("Currency Code");
                if gSalesSetup."Invoice Rounding" then
                    gCurrency.TestField("Invoice Rounding Precision")
                else
                    gCurrency.TestField("Amount Rounding Precision");
            end;
            TotalAmount := RoundAmt(TotalAmount);

            Installment.SetRange("Payment Terms Code", gPaymentTerms.Code);
            if Installment.Find('-') then;

            NextDueDate := "Due Date";

            for CurrDocNo := 1 to gPaymentTerms."No. of Installments" do begin
                CFJournalLine3."Cash Flow Date" := NextDueDate;
                CFJournalLine3.Description :=
                  CopyStr(StrSubstNo(glText1100004, Format(CFJournalLine3."Cash Flow Date"),
                      "Sell-to Customer Name"), 1, MAXSTRLEN(CFJournalLine3.Description));
                DueDateAdjust.SalesAdjustDueDate(
                  CFJournalLine3."Cash Flow Date", "Document Date", gPaymentTerms.CalculateMaxDueDate("Document Date"), "Bill-to Customer No.");
                if CurrDocNo < gPaymentTerms."No. of Installments" then begin
                    Installment.TestField("% of Total");
                    if CurrDocNo = 1 then begin
                        TotalPerc := Installment."% of Total";
                        case gPaymentTerms."VAT distribution" of
                            gPaymentTerms."VAT distribution"::"First Installment":
                                CFJournalLine3."Amount (LCY)" := RoundAmt(
                                    (TotalAmount - VATAmount) * Installment."% of Total" / 100 + VATAmount);
                            gPaymentTerms."VAT distribution"::"Last Installment":
                                CFJournalLine3."Amount (LCY)" := RoundAmt(
                                    (TotalAmount - VATAmount) * Installment."% of Total" / 100);
                            gPaymentTerms."VAT distribution"::Proportional:
                                CFJournalLine3."Amount (LCY)" := RoundAmt(
                                    TotalAmount * Installment."% of Total" / 100);
                        end;
                    end else begin
                        TotalPerc := TotalPerc + Installment."% of Total";
                        if TotalPerc >= 100 then
                            Error(
                              glText1100005,
                              Installment.FieldCaption("% of Total"),
                              gPaymentTerms.TableCaption,
                              gPaymentTerms.Code);
                        case gPaymentTerms."VAT distribution" of
                            gPaymentTerms."VAT distribution"::"First Installment",
                          gPaymentTerms."VAT distribution"::"Last Installment":
                                CFJournalLine3."Amount (LCY)" := RoundAmt(
                                    (TotalAmount - VATAmount) * Installment."% of Total" / 100);
                            gPaymentTerms."VAT distribution"::Proportional:
                                CFJournalLine3."Amount (LCY)" := RoundAmt(
                                    TotalAmount * Installment."% of Total" / 100);
                        end;
                    end;
                    RemainingAmount := RemainingAmount - CFJournalLine3."Amount (LCY)";

                    Installment.TestField("Gap between Installments");
                    NextDueDate := CalcDate(Installment."Gap between Installments", NextDueDate);
                    Installment.Next;
                end else
                    CFJournalLine3."Amount (LCY)" := RemainingAmount;

                if gPaymentMethod."Create Bills" and (CFJournalLine3."Amount (LCY)" <> 0) then
                    InsertTempCFWorksheetLine(0);
            end;
        end;
    end;

    /// <summary>
    /// SplitPurchInv.
    /// </summary>
    /// <param name="PurchHeader">VAR Record "Purchase Header".</param>
    /// <param name="CFJournalLine3">VAR Record "Cash Flow Worksheet Line".</param>
    /// <param name="TotalAmount">Decimal.</param>
    /// <param name="VATAmount">Decimal.</param>
    //[Scope('OnPrem')]
    procedure SplitPurchInv(var PurchHeader: Record "Purchase Header"; var CFJournalLine3: Record "Cash Flow Worksheet Line"; TotalAmount: Decimal; VATAmount: Decimal)
    var
        Installment: Record Installment;
        DueDateAdjust: Codeunit "Due Date-Adjust";
        CurrDocNo: Integer;
        CurrencyFactor: Decimal;
        RemainingAmount: Decimal;
        TotalPerc: Decimal;
        NextDueDate: Date;
    begin
        with PurchHeader do begin
            if not gPaymentMethod.Get("Payment Method Code") then
                exit;
            if (not gPaymentMethod."Create Bills") and (not gPaymentMethod."Invoices to Cartera") then
                exit;
            if gPaymentMethod."Create Bills" and ("Document Type" = "Document Type"::"Credit Memo") then
                Error(
                  glText1100000,
                  FieldCaption("Payment Method Code"));

            if "Currency Code" = '' then
                CurrencyFactor := 1
            else
                CurrencyFactor := "Currency Factor";

            TestField("Payment Terms Code");
            gPaymentTerms.Get("Payment Terms Code");
            gPaymentTerms.CalcFields("No. of Installments");
            if gPaymentTerms."No. of Installments" = 0 then
                gPaymentTerms."No. of Installments" := 1;
            if gPaymentMethod."Invoices to Cartera" and (gPaymentTerms."No. of Installments" > 1) then
                Error(
                  glText1100001,
                  gPaymentTerms.FieldCaption("No. of Installments"),
                  gPaymentMethod.FieldCaption("Invoices to Cartera"),
                  gPaymentMethod.TableCaption);

            RemainingAmount := TotalAmount;

            // create bills
            if "Currency Code" = '' then begin
                gCurrency."Invoice Rounding Precision" := gGLSetup."Inv. Rounding Precision (LCY)";
                gCurrency."Invoice Rounding Type" := gGLSetup."Inv. Rounding Type (LCY)";
                gCurrency."Amount Rounding Precision" := gGLSetup."Amount Rounding Precision";
                if gPurchSetup."Invoice Rounding" then
                    gGLSetup.TestField("Inv. Rounding Precision (LCY)")
                else
                    gGLSetup.TestField("Amount Rounding Precision");
            end else begin
                gCurrency.Get("Currency Code");
                if gSalesSetup."Invoice Rounding" then
                    gCurrency.TestField("Invoice Rounding Precision")
                else
                    gCurrency.TestField("Amount Rounding Precision");
            end;
            TotalAmount := RoundAmt(TotalAmount);

            if gPaymentTerms."No. of Installments" > 0 then begin
                Installment.SetRange("Payment Terms Code", gPaymentTerms.Code);
                if Installment.Find('-') then;
            end;

            NextDueDate := "Due Date";

            for CurrDocNo := 1 to gPaymentTerms."No. of Installments" do begin
                CFJournalLine3."Cash Flow Date" := NextDueDate;
                CFJournalLine3.Description :=
                  CopyStr(StrSubstNo(glText1100006, Format(CFJournalLine3."Cash Flow Date"),
                      "Buy-from Vendor Name"), 1, MAXSTRLEN(CFJournalLine3.Description));
                DueDateAdjust.PurchAdjustDueDate(
                  CFJournalLine3."Cash Flow Date", "Document Date", gPaymentTerms.CalculateMaxDueDate("Document Date"), "Pay-to Vendor No.");
                if CurrDocNo < gPaymentTerms."No. of Installments" then begin
                    Installment.TestField("% of Total");
                    if CurrDocNo = 1 then begin
                        TotalPerc := Installment."% of Total";
                        case gPaymentTerms."VAT distribution" of
                            gPaymentTerms."VAT distribution"::"First Installment":
                                CFJournalLine3."Amount (LCY)" := Round(
                                    (TotalAmount - VATAmount) * Installment."% of Total" / 100 + VATAmount);
                            gPaymentTerms."VAT distribution"::"Last Installment":
                                CFJournalLine3."Amount (LCY)" := Round(
                                    (TotalAmount - VATAmount) * Installment."% of Total" / 100);
                            gPaymentTerms."VAT distribution"::Proportional:
                                CFJournalLine3."Amount (LCY)" := Round(
                                    TotalAmount * Installment."% of Total" / 100);
                        end;
                    end else begin
                        TotalPerc := TotalPerc + Installment."% of Total";
                        if TotalPerc >= 100 then
                            Error(
                              glText1100005,
                              Installment.FieldCaption("% of Total"),
                              gPaymentTerms.TableCaption,
                              gPaymentTerms.Code);
                        case gPaymentTerms."VAT distribution" of
                            gPaymentTerms."VAT distribution"::"First Installment",
                          gPaymentTerms."VAT distribution"::"Last Installment":
                                CFJournalLine3."Amount (LCY)" := Round(
                                    (TotalAmount - VATAmount) * Installment."% of Total" / 100);
                            gPaymentTerms."VAT distribution"::Proportional:
                                CFJournalLine3."Amount (LCY)" := Round(
                                    TotalAmount * Installment."% of Total" / 100);
                        end;
                    end;
                    RemainingAmount := RemainingAmount - CFJournalLine3."Amount (LCY)";
                    Installment.TestField("Gap between Installments");
                    NextDueDate := CalcDate(Installment."Gap between Installments", NextDueDate);
                    Installment.Next;
                end else
                    CFJournalLine3."Amount (LCY)" := RemainingAmount;

                if gPaymentMethod."Create Bills" and (CFJournalLine3."Amount (LCY)" <> 0) then
                    InsertTempCFWorksheetLine(0);
            end;
        end;
    end;

    /// <summary>
    /// SplitServInv.
    /// </summary>
    /// <param name="ServHeader">VAR Record "Service Header".</param>
    /// <param name="CFJournalLine3">VAR Record "Cash Flow Worksheet Line".</param>
    /// <param name="TotalAmount">Decimal.</param>
    /// <param name="VATAmount">Decimal.</param>
    //[Scope('OnPrem')]
    procedure SplitServInv(var ServHeader: Record "Service Header"; var CFJournalLine3: Record "Cash Flow Worksheet Line"; TotalAmount: Decimal; VATAmount: Decimal)
    var
        Installment: Record Installment;
        DueDateAdjust: Codeunit "Due Date-Adjust";
        CurrDocNo: Integer;
        CurrencyFactor: Decimal;
        RemainingAmount: Decimal;
        TotalPerc: Decimal;
        NextDueDate: Date;
    begin
        with ServHeader do begin
            if not gPaymentMethod.Get("Payment Method Code") then
                exit;
            if (not gPaymentMethod."Create Bills") and (not gPaymentMethod."Invoices to Cartera") then
                exit;
            if gPaymentMethod."Create Bills" and ("Document Type" = "Document Type"::"Credit Memo") then
                Error(
                  glText1100000,
                  FieldCaption("Payment Method Code"));

            if gServiceHeader."Currency Code" = '' then
                CurrencyFactor := 1
            else
                CurrencyFactor := gServiceHeader."Currency Factor";

            TestField("Payment Terms Code");
            gPaymentTerms.Get("Payment Terms Code");
            gPaymentTerms.CalcFields("No. of Installments");
            if gPaymentTerms."No. of Installments" = 0 then
                gPaymentTerms."No. of Installments" := 1;
            if gPaymentMethod."Invoices to Cartera" and (gPaymentTerms."No. of Installments" > 1) then
                Error(
                  glText1100001,
                  gPaymentTerms.FieldCaption("No. of Installments"),
                  gPaymentMethod.FieldCaption("Invoices to Cartera"),
                  gPaymentMethod.TableCaption);

            RemainingAmount := TotalAmount;

            // create bills
            if "Currency Code" = '' then begin
                gCurrency."Invoice Rounding Precision" := gGLSetup."Inv. Rounding Precision (LCY)";
                gCurrency."Invoice Rounding Type" := gGLSetup."Inv. Rounding Type (LCY)";
                gCurrency."Amount Rounding Precision" := gGLSetup."Amount Rounding Precision";
            end else
                gCurrency.Get("Currency Code");
            TotalAmount := RoundAmt(TotalAmount);

            if gPaymentTerms."No. of Installments" > 0 then begin
                Installment.SetRange("Payment Terms Code", gPaymentTerms.Code);
                if Installment.Find('-') then;
            end;

            NextDueDate := "Due Date";

            for CurrDocNo := 1 to gPaymentTerms."No. of Installments" do begin
                CFJournalLine3."Cash Flow Date" := NextDueDate;
                CFJournalLine3.Description :=
                  CopyStr(StrSubstNo(glText1100007, Format(CFJournalLine3."Cash Flow Date"),
                      Name), 1, MAXSTRLEN(CFJournalLine3.Description));
                DueDateAdjust.SalesAdjustDueDate(
                  CFJournalLine3."Cash Flow Date", "Document Date", gPaymentTerms.CalculateMaxDueDate("Document Date"), "Bill-to Customer No.");
                if CurrDocNo < gPaymentTerms."No. of Installments" then begin
                    Installment.TestField("% of Total");
                    if CurrDocNo = 1 then begin
                        TotalPerc := Installment."% of Total";
                        case gPaymentTerms."VAT distribution" of
                            gPaymentTerms."VAT distribution"::"First Installment":
                                CFJournalLine3."Amount (LCY)" := Round(
                                    (TotalAmount - VATAmount) * Installment."% of Total" / 100 + VATAmount);
                            gPaymentTerms."VAT distribution"::"Last Installment":
                                CFJournalLine3."Amount (LCY)" := Round(
                                    (TotalAmount - VATAmount) * Installment."% of Total" / 100);
                            gPaymentTerms."VAT distribution"::Proportional:
                                CFJournalLine3."Amount (LCY)" := Round(
                                    TotalAmount * Installment."% of Total" / 100);
                        end;
                    end else begin
                        TotalPerc := TotalPerc + Installment."% of Total";
                        if TotalPerc >= 100 then
                            Error(
                              glText1100005,
                              Installment.FieldCaption("% of Total"),
                              gPaymentTerms.TableCaption,
                              gPaymentTerms.Code);
                        case gPaymentTerms."VAT distribution" of
                            gPaymentTerms."VAT distribution"::"First Installment",
                          gPaymentTerms."VAT distribution"::"Last Installment":
                                CFJournalLine3."Amount (LCY)" := Round(
                                    (TotalAmount - VATAmount) * Installment."% of Total" / 100);
                            gPaymentTerms."VAT distribution"::Proportional:
                                CFJournalLine3."Amount (LCY)" := Round(
                                    TotalAmount * Installment."% of Total" / 100);
                        end;
                    end;
                    RemainingAmount := RemainingAmount - CFJournalLine3."Amount (LCY)";
                    Installment.TestField("Gap between Installments");
                    NextDueDate := CalcDate(Installment."Gap between Installments", NextDueDate);
                    Installment.Next;
                end else
                    CFJournalLine3."Amount (LCY)" := RemainingAmount;

                if gPaymentMethod."Create Bills" and (CFJournalLine3."Amount (LCY)" <> 0) then
                    InsertTempCFWorksheetLine(0);
            end;
        end;
    end;

    /// <summary>
    /// RoundAmt.
    /// </summary>
    /// <param name="Amount">Decimal.</param>
    /// <returns>Return value of type Decimal.</returns>
    //[Scope('OnPrem')]
    procedure RoundAmt(Amount: Decimal): Decimal
    begin
        if gSalesSetup."Invoice Rounding" then
            Amount := Round(
                Amount,
                gCurrency."Invoice Rounding Precision",
                SelectStr(gCurrency."Invoice Rounding Type" + 1, '=,>,<'))
        else
            Amount := Round(
                Amount,
                gCurrency."Amount Rounding Precision");

        exit(Amount);
    end;

    local procedure GetPurchaseAmountForCFLine(PurchaseLine: Record "Purchase Line"): Decimal
    begin
        exit(PurchaseLine."Outstanding Amount (LCY)" + PurchaseLine."Amt. Rcd. Not Invoiced (LCY)");
    end;

    local procedure GetSalesAmountForCFLine(SalesLine: Record "Sales Line"): Decimal
    begin
        exit(SalesLine."Outstanding Amount (LCY)" + SalesLine."Shipped Not Invoiced (LCY)");
    end;

    local procedure GetServiceAmountForCFLine(ServiceLine: Record "Service Line"): Decimal
    begin
        exit(ServiceLine."Outstanding Amount (LCY)" + ServiceLine."Shipped Not Invoiced (LCY)");
    end;

    local procedure GetJobPlanningAmountForCFLine(JobPlanningLine: Record "Job Planning Line"): Decimal
    begin
        JobPlanningLine.CalcFields("Invoiced Amount (LCY)");
        exit(JobPlanningLine."Line Amount (LCY)" - JobPlanningLine."Invoiced Amount (LCY)");
    end;

    local procedure GetTaglXPayableDateFromSource(SourceTableNum: Integer): Date
    var
        CashFlowSetup: Record "Cash Flow Setup";
        DocumentDate: Date;
    begin
        case SourceTableNum of
            DATABASE::"Sales Header":
                DocumentDate := gSalesHeader."Document Date";
            DATABASE::"Purchase Header":
                DocumentDate := gPurchaseHeader."Document Date";
            DATABASE::"VAT Entry":
                DocumentDate := gVATEntry."Document Date";
        end;

        exit(CashFlowSetup.GetTaxpaymentDueDate(DocumentDate));
    end;

    local procedure HasTaxBeenPaidOn(PaymentDate: Date): Boolean
    var
        CashFlowSetup: Record "Cash Flow Setup";
        BankAccountLedgerEntry: Record "Bank Account Ledger Entry";
        TaglXPaymentStartDate: Date;
        BalanceAccountType: Enum "Gen. Journal Account Type";
    begin
        TaglXPaymentStartDate := CashFlowSetup.GetTaxpaymentStartDate(PaymentDate);
        case CashFlowSetup."Tax Bal. Account Type" of
            CashFlowSetup."Tax Bal. Account Type"::" ":
                exit(false);
            CashFlowSetup."Tax Bal. Account Type"::Vendor:
                BalanceAccountType := BankAccountLedgerEntry."Bal. Account Type"::Vendor;
            CashFlowSetup."Tax Bal. Account Type"::"G/L Account":
                BalanceAccountType := BankAccountLedgerEntry."Bal. Account Type"::"G/L Account";
        end;
        BankAccountLedgerEntry.SetRange("Bal. Account Type", BalanceAccountType);
        BankAccountLedgerEntry.SetFilter("Posting Date", '%1..%2', TaglXPaymentStartDate, PaymentDate);
        BankAccountLedgerEntry.SetRange("Bal. Account No.", CashFlowSetup."Tax Bal. Account No.");
        exit(not BankAccountLedgerEntry.IsEmpty);
    end;

    local procedure GetDescriptionForTaxCashFlowLine(SourceTableNum: Integer): Text[250]
    var
        PurchaseOrders: Page "Purchase Orders";
        SalesOrders: Page "Sales Orders";
        VATEntries: Page "VAT Entries";
    begin
        case SourceTableNum of
            DATABASE::"Purchase Header":
                exit(StrSubstNo(glTaxForMsg, PurchaseOrders.Caption));
            DATABASE::"Sales Header":
                exit(StrSubstNo(glTaxForMsg, SalesOrders.Caption));
            DATABASE::"VAT Entry":
                exit(StrSubstNo(glTaxForMsg, VATEntries.Caption));
        end;
    end;

    local procedure GetTaxAmountFromSource(SourceTableNum: Integer): Decimal
    var
        gcCashFlowManagement: Codeunit "Cash Flow Management";
    begin
        case SourceTableNum of
            DATABASE::"Sales Header":
                exit(gcCashFlowManagement.GetTaxAmountFromSalesOrder(gSalesHeader));
            DATABASE::"Purchase Header":
                exit(gcCashFlowManagement.GetTaxAmountFromPurchaseOrder(gPurchaseHeader));
            DATABASE::"VAT Entry":
                exit(gVATEntry.Amount);
        end;
    end;

    local procedure IsDateBeforeStartOfCurrentPeriod(Date: Date): Boolean
    var
        CashFlowSetup: Record "Cash Flow Setup";
    begin
        exit(Date < CashFlowSetup.GetCurrentPeriodStartDate);
    end;

    local procedure NBanco(CodB: Code[20]): Text[100]
    var
        r270: Record 270;
    begin

        if NOT r270.GET(CodB) THEN EXIT('');
        EXIT(r270."Name 2");

    end;

    /// <summary>
    /// InsertLiqLine.
    /// </summary>
    /// <returns>Return value of type Boolean.</returns>
    procedure InsertLiqLine(): Boolean
    begin

        WITH gTempCFWorksheetLine DO BEGIN
            giLineNo := giLineNo + 10000;
            TRANSFERFIELDS(gCFWorksheetLine2);
            "Anotación" := gCFWorksheetLine2."Anotación";
            "Fecha Anotacion" := gCFWorksheetLine2."Fecha Anotacion";
            "Cash Flow Forecast No." := gCashFlowForecast."No.";
            "Line No." := giLineNo;
            if "Cash Flow Date" = 0D Then "Cash Flow Date" := gdDummyDate;
            gLiqAcc.RESET;
            if gLiqAcc.GET("Cash Flow Account No.") THEN
                Concepto := gLiqAcc.Name;
            gCFWorksheetLine2.SETCURRENTKEY("Associated Entry No.");
            if "Associated Entry No." = 0 THEN
                INSERT
            ELSE BEGIN
                gCFWorksheetLine2.SETRANGE(gCFWorksheetLine2."Associated Entry No.", "Associated Entry No.");
                if NOT gCFWorksheetLine2.FINDFIRST THEN
                    INSERT
                ELSE
                    EXIT(FALSE);
            END;
        END;
        EXIT(TRUE);
    end;

    local procedure Anotaciones(No: Code[20]; Proveedor: Boolean; Var Anotacion: Text[250]; var FechaAnotacion: Date)
    var
        Anot: Record "Comment Line";
    begin

        Anot.SETRANGE(Anot."Table Name", Anot."Table Name"::Anotaciones);
        Anot.SETRANGE(Anot."No.", No);
        Anot.Setrange(Proveedor, Proveedor);
        if Anot.FINDLAST THEN begin
            Anotacion := Anot."Comment";
            FechaAnotacion := Anot."Date";

        end;
    end;

    local procedure CalcFecha(Fec: Date): Date
    begin
        if Fec = 0D THEN EXIT(gdDummyDate);
        EXIT(Fec);
    end;

    local procedure CalcFechaL(Fec: Date): Date
    begin

        if Fec = 0D THEN EXIT(gdDummyDate);
        if Fec >= gdDuedateD THEN EXIT(Fec);
        if (DATE2DMY(Fec, 2) = DATE2DMY(gdDuedateD, 2)) AND ((DATE2DMY(Fec, 3) = DATE2DMY(gdDuedateD, 3))) THEN EXIT(gdDuedateD);
        EXIT(CALCDATE('PM+1D-2M+PM', gdDuedateD));
    end;

    local procedure BuscarLiq(var LiqAcc: Record "Cash Flow Account"; PgESourceType: Enum "Cash Flow Source Type";
    pCartera: Boolean; pAtrasados: Boolean; pFormaPago: Code[10]; pBanco: Code[20]; pProveedor: Text; Importe: Decimal; DueDate: Date; pCliente: Code[20])
    var
        LiqAcct: Record "Temp Cash Flow Account" temporary;
        Odatef: DateFormula;
        Vtoh: Date;
        Vtod: Date;
    begin
        Case PgESourceType of
            PgESourceType::"Cartera Clientes":
                PgESourceType := PgESourceType::Receivables;
            PgESourceType::"Cartera Clientes Registrada":
                PgESourceType := PgESourceType::Receivables;
            PgESourceType::"Cartera Proveedores":
                PgESourceType := PgESourceType::Payables;
            PgESourceType::"Cartera Proveedores Registrada":
                PgESourceType := PgESourceType::Payables;
        End;
        // Buscamos Con Todos los datos
        gLiqAcc.RESET;
        gLiqAcc.SETRANGE(gLiqAcc."Source Type", PgESourceType);
        if pProveedor <> '' THEN
            gLiqAcc.SETRANGE(gLiqAcc."Cód. Proveedor", pProveedor);
        if pCliente <> '' THEN
            gLiqAcc.SETRANGE(gLiqAcc."Cód. Cliente", pCliente);
        if gLiqAcc.FINDFIRST THEN BEGIN
            REPEAT
                LiqAcct.TransferFields(LiqAcc);
                LiqAcct."Cód Prestamo" := gLiqAcc."Cód Prestamo";
                LiqAcct."Banco Informes" := gLiqAcc."Banco Informes";
                LiqAcct."Solo Cartera" := gLiqAcc."Solo Atrasados";
                LiqAcct."Empresa" := gLiqAcc.Empresa;
                LiqAcct."Cód. Proveedor" := gLiqAcc."Cód. Proveedor";
                LiqAcct."Cód. Cliente" := gLiqAcc."Cód. Cliente";
                LiqAcct."Calcular vto Cuenta" := gLiqAcc."Calcular vto. Cuenta";
                LiqAcct."Dias Liquidación HASTA" := gLiqAcc."Dias Liquidación HASTA";
                LiqAcct."Debe/Haber" := gLiqAcc."Debe/Haber";
                LiqAcct."Solo Atrasados" := gLiqAcc."Solo Atrasados";
                LiqAcct."Dias Liquidación DESDE" := gLiqAcc."Dias Liquidación DESDE";
                LiqAcct."Desglosar" := gLiqAcc.Desglosar;
                LiqAcct."Vinculado a noº" := gLiqAcc."Vinculado a noº";
                LiqAcct."Dia de pago" := gLiqAcc."Dia de pago";
                LiqAcct."Tipo Saldo" := gLiqAcc."Tipo Saldo";
                LiqAcct."Vto Resto Año" := gLiqAcc."Vto Resto Año";
                LiqAcct."Vto enero" := gLiqAcc."Vto enero";
                LiqAcct."Pago Impuestos" := gLiqAcc."Pago Impuestos";


                LiqAcct.Valoracion := 0;

                if gLiqAcc."Payment Method Code" = pFormaPago THEN
                    LiqAcct.Valoracion += 2;
                if pBanco <> '' Then
                    if gLiqAcc."Cod banco" = pBanco THEN
                        LiqAcct.Valoracion += 1;
                if pBanco <> '' Then
                    if NBanco(pBanco) = gLiqAcc."Banco Informes" THEN
                        LiqAcct.Valoracion += 1;
                if LiqAcct."Solo Cartera" = pCartera THEN
                    LiqAcct.Valoracion += 1;
                if (gLiqAcc."Debe/Haber" = gLiqAcc."Debe/Haber"::Debe) AND
                (Importe > 0) THEN
                    LiqAcct.Valoracion += 1;
                if (gLiqAcc."Debe/Haber" = gLiqAcc."Debe/Haber"::Haber) AND
                (Importe < 0) THEN
                    LiqAcct.Valoracion += 1;
                if (gLiqAcc."Debe/Haber" = gLiqAcc."Debe/Haber"::Ambos) THEN
                    LiqAcct.Valoracion += 1;
                if gLiqAcc."Solo Atrasados" = pAtrasados THEN
                    LiqAcct.Valoracion += 1;
                if gLiqAcc."Dias Liquidación HASTA" <> Odatef THEN BEGIN
                    Vtoh := CALCDATE(gLiqAcc."Dias Liquidación HASTA", WORKDATE);
                    Vtod := CALCDATE(gLiqAcc."Dias Liquidación DESDE", WORKDATE);
                    if gLiqAcc."Dias Liquidación DESDE" = Odatef THEN Vtod := 19800101D;
                    if (DueDate <= Vtoh) AND (DueDate >= Vtod) THEN LiqAcct.Valoracion += 1;
                END;
                LiqAcct.INSERT;
            UNTIL gLiqAcc.NEXT = 0;
            LiqAcct.SETCURRENTKEY(Valoracion);
            LiqAcct.FINDLAST;
            gLiqAcc.GET(LiqAcct."No.");
            EXIT;
        END ELSE BEGIN
            gLiqAcc.SETRANGE(gLiqAcc."Cód. Proveedor");
            gLiqAcc.SETRANGE(gLiqAcc."Cód. Cliente");
        END;
        if gLiqAcc.FINDFIRST THEN BEGIN
            REPEAT
                LiqAcct.TransferFields(LiqAcc);
                LiqAcct."Cód Prestamo" := gLiqAcc."Cód Prestamo";
                LiqAcct."Banco Informes" := gLiqAcc."Banco Informes";
                LiqAcct."Solo Cartera" := gLiqAcc."Solo Atrasados";
                LiqAcct."Empresa" := gLiqAcc.Empresa;
                LiqAcct."Cód. Proveedor" := gLiqAcc."Cód. Proveedor";
                LiqAcct."Cód. Cliente" := gLiqAcc."Cód. Cliente";
                LiqAcct."Calcular vto Cuenta" := gLiqAcc."Calcular vto. Cuenta";
                LiqAcct."Dias Liquidación HASTA" := gLiqAcc."Dias Liquidación HASTA";
                LiqAcct."Debe/Haber" := gLiqAcc."Debe/Haber";
                LiqAcct."Solo Atrasados" := gLiqAcc."Solo Atrasados";
                LiqAcct."Dias Liquidación DESDE" := gLiqAcc."Dias Liquidación DESDE";
                LiqAcct."Desglosar" := gLiqAcc.Desglosar;
                LiqAcct."Vinculado a noº" := gLiqAcc."Vinculado a noº";
                LiqAcct."Dia de pago" := gLiqAcc."Dia de pago";
                LiqAcct."Tipo Saldo" := gLiqAcc."Tipo Saldo";
                LiqAcct."Vto Resto Año" := gLiqAcc."Vto Resto Año";
                LiqAcct."Vto enero" := gLiqAcc."Vto enero";
                LiqAcct."Pago Impuestos" := gLiqAcc."Pago Impuestos";
                LiqAcct.Valoracion := 0;
                if gLiqAcc."Payment Method Code" = pFormaPago THEN
                    LiqAcct.Valoracion += 2;
                if pBanco <> '' Then
                    if gLiqAcc."Cod banco" = pBanco THEN
                        LiqAcct.Valoracion += 1;
                if pBanco <> '' Then
                    if NBanco(pBanco) = gLiqAcc."Banco Informes" THEN
                        LiqAcct.Valoracion += 1;
                if LiqAcct."Solo Cartera" = pCartera THEN
                    LiqAcct.Valoracion += 1;
                if (gLiqAcc."Debe/Haber" = gLiqAcc."Debe/Haber"::Debe) AND
                (Importe > 0) THEN
                    LiqAcct.Valoracion += 1;
                if (gLiqAcc."Debe/Haber" = gLiqAcc."Debe/Haber"::Haber) AND
                (Importe < 0) THEN
                    LiqAcct.Valoracion += 1;
                if (gLiqAcc."Debe/Haber" = gLiqAcc."Debe/Haber"::Ambos) THEN
                    LiqAcct.Valoracion += 1;
                if gLiqAcc."Solo Atrasados" = pAtrasados THEN
                    LiqAcct.Valoracion += 1
                else
                    LiqAcct.Valoracion -= 1;
                if gLiqAcc."Dias Liquidación HASTA" <> Odatef THEN BEGIN
                    Vtoh := CALCDATE(gLiqAcc."Dias Liquidación HASTA", WORKDATE);
                    Vtod := CALCDATE(gLiqAcc."Dias Liquidación DESDE", WORKDATE);
                    if gLiqAcc."Dias Liquidación DESDE" = Odatef THEN Vtod := 19800101D;
                    if (DueDate <= Vtoh) AND (DueDate >= Vtod) THEN LiqAcct.Valoracion += 1;
                END;

                if LiqAcct.INSERT Then;
            UNTIL gLiqAcc.NEXT = 0;
            LiqAcct.SETCURRENTKEY(Valoracion);
            LiqAcct.FINDLAST;
            gLiqAcc.GET(LiqAcct."No.");
            EXIT;
        END;
    end;

    local procedure ExisteMov(Num: Integer): Boolean
    begin

        if Num = 0 THEN EXIT(FALSE);
        gTempCFWorksheetLine.SETRANGE("Associated Entry No.", Num);
        EXIT(gTempCFWorksheetLine.FINDFIRST);
    end;

    local procedure ComprobarCliente(Cta: Code[20]; Liq: Code[20]): Boolean
    var
        r18: Record Customer;
        LiqAcount: Record "Cash Flow Account";
    begin

        if r18.GET(Cta) THEN
            if (r18."IC Partner Code" <> '') THEN EXIT(FALSE);

        if (Liq <> '') THEN
            EXIT(Cta = Liq);
        LiqAcount.SETRANGE(LiqAcount."Cód. Cliente", Cta);
        EXIT(NOT LiqAcount.FINDFIRST);
    end;

    local procedure ComprobarProveedor(Cta: Code[20]; Liq: Code[20]): Boolean
    var
        r23: Record Vendor;
        LiqAcount: Record "Cash Flow Account";
    begin

        if r23.GET(Cta) THEN
            if (r23."IC Partner Code" <> '') THEN EXIT(FALSE);

        if (Liq <> '') THEN
            EXIT(Cta = Liq);
        LiqAcount.SETRANGE(LiqAcount."Cód. Proveedor", Cta);
        EXIT(NOT LiqAcount.FINDFIRST);
    end;

}