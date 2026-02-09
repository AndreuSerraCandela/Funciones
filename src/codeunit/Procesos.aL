/// <summary>
/// Codeunit Procedures Standard (ID 50007).
/// </summary>
codeunit 50007 "Procedures Standard"
{

    TableNo = 85;

    VAR
        Contrl: Codeunit ControlProcesos;

#pragma warning disable AL0432
        LiqAccSchedCellValue: Record "Acc. Sched. Cell Value" temporary;
#pragma warning restore AL0432

        AccountingPeriodMgt: Codeunit "Accounting Period Mgt.";
        Text000: Label 'GENERICO';
        Text001: Label 'Previsión gerérica';
        Text002: Label 'Columnas geréricas';
        Text005: Label 'M';
        Text006: Label 'T';
        Text007: Label 'A';
        Text012: Label 'Ha introducido un valor incorrecto o un número de fila inexistente.';
        Text013: Label 'Ha introducido un valor incorrecto o un número de columna inexistente.';
        Text014: Label '<Precision,';
        Text015: Label '><Standard Format,0>';
        Text016: Label '<Precision,1><Standard Format,0>';
        Text017: Label 'Se ha producido un error al realizar el siguiente cálculo:\';
        Text018: Label '"Lín. esq. cta.: Nº fila = %1, Nº línea = %2, Total = %3\"';
        Text019: Label '"Col. esq. cta.: Nº columna = %4, Nº línea = %5, Fórmula  = %6"';
        Text020: Label 'El programa no puede calcular la fórmula, debido a las referencias circulares.';
        AccSchedName: Record 84;
        AccountScheduleLine: Record 85;
        ColumnLayoutName: Record 333;

#pragma warning disable AL0432
        AccSchedCellValue: Record 342 TEMPORARY;
#pragma warning restore AL0432

        CurrExchRate: Record "Currency Exchange Rate";
        GLSetup: Record "General Ledger Setup";
        AddRepCurrency: Record "Currency";
        AnalysisView: Record "Analysis View";
        AnalysisViewRead: Boolean;
        StartDate: Date;
        EndDate: Date;
        FiscalStartDate: Date;
        DivisionError: Boolean;
        PeriodError: Boolean;
        CallLevel: Integer;
        CallingAccSchedLineID: Integer;
        CallingColumnLayoutID: Integer;
        OldAccSchedLineFilters: Text[250];
        OldColumnLayoutFilters: Text[250];
        OldAccSchedLineName: Code[10];
        OldColumnLayoutName: Code[10];
        OldCalcAddCurr: Boolean;
        NormalFormatString: Text[80];
        GLSetupRead: Boolean;
        Text021: Label 'La conversión del total del filtro de dimensión %1 pasa a ser un filtro demasiado largo.';
        BasePercentLine: ARRAY[50] OF Integer;
        Text022: Label 'No se pueden tener más de %1 líneas con %2 de %3.';
        Text023: Label 'Las fórmulas que terminan con un signo de porcentaje requieren que %2 %1 se incluya en la línea anterior.';
        Text024: Label '%1 %3 en %2 debe ser igual a %4 %6 en %5 cuando se utiliza un sumatorio de dimensiones en cualquier columna.';
        Recalculate: Boolean;
        RowFormulaMsg: Label 'Row formula: %1.';
        ColumnFormulaMsg: Label 'Column formula: %1.';
        ColumnFormulaErrorMsg: Label 'Column formula: %1. \Error: %2.';
        Text1140011: Label 'La aplicación no puede calcular la fórmula debido a las referencias circulares.';
        Text1140012: Label 'Ha introducido un valor incorrecto o un número de fila inexistente.';
        Text1140013: Label 'Ha introducido un valor incorrecto o un número de columna inexistente.';
        Text1140014: Label '<Precision,';
        Text1140015: Label '><Standard Format,0>';
        Text1140016: Label '<Precision,1><Standard Format,0>';
        Text1140017: Label 'Se ha producido un error al realizar el siguiente cálculo:\';
        Text1140018: Label '"Lín. esq. cta.: Nº fila = %1, Nº línea = %2, Total = %3\"';
        Text1140019: Label '"Col. esq. cta.: Nº columna = %4, Nº línea = %5, Fórmula  = %6"';
        Text1140020: Label 'La conversión del total del filtro de dimensión %1 pasa a ser un filtro demasiado largo.';
        LiqAccountSchedLine: Record "Acc. Schedule Line";
        OldLiqAccSchedLineFilter: Text;
        OldLiqAccSchedColumnFilter: Text;
        OldLiqAccSchedLineName: Text;
        OldLiqAccSchedColumnName: Text;
        CallLiqAccSchedLineID: Integer;
        CallLiqAccSchedColumnID: Integer;

    /// <summary>
    /// CalcColumnDates.
    /// </summary>
    /// <param name="ColumnLayout">Record "Column Layout".</param>
    /// <param name="FromDate">VAR Date.</param>
    /// <param name="ToDate">VAR Date.</param>
    /// <param name="FiscalStartDate2">VAR Date.</param>
    procedure CalcColumnDates(ColumnLayout: Record "Column Layout"; var FromDate: Date; var ToDate: Date; var FiscalStartDate2: Date)
    var
        ComparisonDateFormula: DateFormula;
        ComparisonPeriodFormula: Code[20];
    begin
        ComparisonDateFormula := ColumnLayout."Comparison Date Formula";
        ComparisonPeriodFormula := ColumnLayout."Comparison Period Formula";

        if (Format(ComparisonDateFormula) <> '0') and (Format(ComparisonDateFormula) <> '') then begin
            FromDate := CalcDate(ComparisonDateFormula, StartDate);
            ToDate := CalcDate(ComparisonDateFormula, EndDate);
            if (StartDate = CalcDate('<-CM>', StartDate)) and
            (FromDate = CalcDate('<-CM>', FromDate)) and
            (EndDate = CalcDate('<CM>', EndDate))
            then
                ToDate := CalcDate('<CM>', ToDate);
            FiscalStartDate2 := AccountingPeriodMgt.FindFiscalYear(ToDate);
        end else
            if ComparisonPeriodFormula <> '' then begin
                //AccPeriodStartEnd(ColumnLayout, StartDate, FromDate, ToDate);
                AccPeriodStartEnd(ComparisonPeriodFormula, StartDate, FromDate, ToDate);
                FiscalStartDate2 := AccountingPeriodMgt.FindFiscalYear(ToDate);
            end else begin
                FromDate := StartDate;
                ToDate := EndDate;
                FiscalStartDate2 := FiscalStartDate;
            end;
    end;

    /// <summary>
    /// CalcFieldError.
    /// </summary>
    /// <param name="ErrorType">VAR Option "None","Division by Zero","Period Error",Both.</param>
    /// <param name="RowNo">Integer.</param>
    /// <param name="ColumnNo">Integer.</param>
    procedure CalcFieldError(var ErrorType: Option "None","Division by Zero","Period Error",Both; RowNo: Integer; ColumnNo: Integer)
    begin
        AccSchedCellValue.SetRange("Row No.", RowNo);
        AccSchedCellValue.SetRange("Column No.", ColumnNo);
        ErrorType := ErrorType::None;
        if AccSchedCellValue.FindFirst then
            case true of
                AccSchedCellValue."Has Error":
                    ErrorType := ErrorType::"Division by Zero";
                AccSchedCellValue."Period Error":
                    ErrorType := ErrorType::"Period Error";
                AccSchedCellValue."Has Error" and AccSchedCellValue."Period Error":
                    ErrorType := ErrorType::Both;
            end;

        AccSchedCellValue.SetRange("Row No.");
        AccSchedCellValue.SetRange("Column No.");
    end;

    /// <summary>
    /// DrillDownFromOverviewPage.
    /// </summary>
    /// <param name="TempColumnLayout">Temporary Record "Column Layout".</param>
    /// <param name="AccScheduleLine">VAR Record "Acc. Schedule Line".</param>
    /// <param name="PeriodLength">Option.</param>
    /// <param name="FiltroEli">Option " ",Sí,No.</param>
    /// <param name="DimFilter1">Text.</param>
    /// <param name="DimFilter2">Text.</param>
    /// <param name="DimFilter3">Text.</param>
    /// <param name="DimFilter4">Text.</param>
    /// <param name="DimFilter5">Text.</param>
    /// <param name="FilVend">Text.</param>
    procedure DrillDownFromOverviewPage(TempColumnLayout: Record "Column Layout" temporary;
    var AccScheduleLine: Record "Acc. Schedule Line"; PeriodLength: Option; FiltroEli: Option " ",Sí,No
    ; DimFilter1: Text; DimFilter2: Text; DimFilter3: Text; DimFilter4: Text; DimFilter5: Text; FilVend: Text)
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        if IsHandled then
            exit;

        with AccScheduleLine do begin
            if ("Totaling Type" = "Totaling Type"::Formula) and
               (TempColumnLayout."Column Type" = TempColumnLayout."Column Type"::Formula)
            then
                Message(RowFormulaMsg, TempColumnLayout.Formula)
            else
                if "Totaling Type" in ["Totaling Type"::Formula, "Totaling Type"::"Set Base For Percent"] then
                    Message(RowFormulaMsg, Totaling)
                else
                    DrillDown(TempColumnLayout, AccScheduleLine, PeriodLength, FiltroEli, DimFilter1, DimFilter2, DimFilter3, DimFilter4, DimFilter5, FilVend);
        end;
    end;

    /// <summary>
    /// DrillDown.
    /// </summary>
    /// <param name="TempColumnLayout">Temporary Record "Column Layout".</param>
    /// <param name="AccScheduleLine">VAR Record "Acc. Schedule Line".</param>
    /// <param name="PeriodLength">Option.</param>
    /// <param name="FiltroEli">Option " ",Sí,No.</param>
    /// <param name="DimFilter1">Text.</param>
    /// <param name="DimFilter2">Text.</param>
    /// <param name="DimFilter3">Text.</param>
    /// <param name="DimFilter4">Text.</param>
    /// <param name="DimFilter5">Text.</param>
    /// <param name="FilVend">Text.</param>
    procedure DrillDown(TempColumnLayout: Record "Column Layout" temporary; var AccScheduleLine: Record "Acc. Schedule Line"; PeriodLength: Option;
    FiltroEli: Option " ",Sí,No
    ; DimFilter1: Text; DimFilter2: Text; DimFilter3: Text; DimFilter4: Text; DimFilter5: Text; FilVend: Text)
    var
        AccScheduleOverview: Page "Acc. Schedule Overview";
        ErrorType: Option "None","Division by Zero","Period Error",Both;
        IsHandled: Boolean;
    begin
        IsHandled := false;
        //OnBeforeDrillDown(TempColumnLayout, AccScheduleLine, PeriodLength, IsHandled);
        if IsHandled then
            exit;

        with AccScheduleLine do begin
            if TempColumnLayout."Column Type" = TempColumnLayout."Column Type"::Formula then begin
                CalcFieldError(ErrorType, "Line No.", TempColumnLayout."Line No.");
                if ErrorType <> ErrorType::None then
                    Message(StrSubstNo(ColumnFormulaErrorMsg, TempColumnLayout.Formula, Format(ErrorType)))
                else
                    Message(ColumnFormulaMsg, TempColumnLayout.Formula);
                exit;
            end;

            if "Totaling Type" in ["Totaling Type"::Formula, "Totaling Type"::"Set Base For Percent"] then begin
                AccScheduleOverview.SetAccSchedName("Schedule Name");
                AccScheduleOverview.SetTableView(AccScheduleLine);
                AccScheduleOverview.SetRecord(AccScheduleLine);
                AccScheduleOverview.SetPeriodType(PeriodLength);
                AccScheduleOverview.Run;
                exit;
            end;

            //  OnBeforeDrillDownOnAccounts(AccScheduleLine, TempColumnLayout, PeriodLength, StartDate, EndDate);

            if Totaling = '' then
                exit;

            if "Totaling Type" in ["Totaling Type"::"Cash Flow Entry Accounts", "Totaling Type"::"Cash Flow Total Accounts"] then
                DrillDownOnCFAccount(TempColumnLayout, AccScheduleLine)
            else
                DrillDownOnGLAccount(TempColumnLayout, AccScheduleLine, FiltroEli, DimFilter1, DimFilter2, DimFilter3, DimFilter4, DimFilter5, FilVend);
        end;
    end;

    local procedure DrillDownOnGLAccount(TempColumnLayout: Record "Column Layout" temporary; var AccScheduleLine: Record "Acc. Schedule Line"; FiltroEli: Option " ",Sí,No
    ; DimFilter1: Text; DimFilter2: Text; DimFilter3: Text; DimFilter4: Text; DimFilter5: Text; FilFend: Text)
    var
        GLAcc: Record "G/L Account";
        GLAccAnalysisView: Record "G/L Account (Analysis View)";
        CostType: Record "Cost Type";
        ChartOfAccsAnalysisView: Page "Chart of Accs. (Analysis View)";
        IsHandled: Boolean;
        Text000: Label 'GENERICO';
        Text001: Label '* ERROR *';
        Text002: Label 'Fórmula columna: %1';
        Text003: Label 'Fórmula fila: %1';
        LAcc: Record 15;
        ChartofAccAnalysisView: Page 569;
        AccSchedName: Record 84;
        //HistoricGLAcc: Record 10721;
        //ChartofHistAccAnalysisView: Page 10733;
        CostTypeChart: Page "Cost Type Card";
        CostBudPerPeriod: Page "Cost Budget per Period";
        //CostType: Record "Cost Type";
        VeAcc: Record Vendor;
        CuAcc: Record Customer;
        PChar: Page "Chart of Accounts (G/L)";
    begin
        IsHandled := false;
        //OnBeforeDrillDownOnGLAccount(TempColumnLayout, AccScheduleLine, IsHandled);
        if IsHandled then
            exit;
        CASE FiltroEli OF
            FiltroEli::" ":
                AccScheduleLine.SETRANGE("Filtro Eliminaciones");
            FiltroEli::Sí:
                AccScheduleLine.SETRANGE("Filtro Eliminaciones", TRUE);
            FiltroEli::No:
                AccScheduleLine.SETRANGE("Filtro Eliminaciones", FALSE);
        END;
        if TempColumnLayout."Column Type" = TempColumnLayout."Column Type"::Formula THEN
            MESSAGE(Text002, TempColumnLayout.Formula)
        ELSE
            if AccScheduleLine."Totaling Type" IN [AccScheduleLine."Totaling Type"::Formula, AccScheduleLine."Totaling Type"::"Set Base For Percent"] THEN
                MESSAGE(Text003, AccScheduleLine.Totaling)
            // ELSE
            // if Totaling <> '' THEN BEGIN
            ELSE BEGIN
                //if AccSchedName.GET(NewCurrentSchedName) THEN
                if True Then BEGIN
                    if (AccScheduleLine.Totaling <> '') AND
                        (AccScheduleLine."Totaling Type" IN [AccScheduleLine."Totaling Type"::"Posting Accounts", AccScheduleLine."Totaling Type"::"Total Accounts"])
                    THEN BEGIN
                        AccScheduleLine.COPYFILTER("Business Unit Filter", GLAcc."Business Unit Filter");
                        AccScheduleLine.COPYFILTER("G/L Budget Filter", GLAcc."Budget Filter");
                        AccScheduleLine.COPYFILTER("Filtro Eliminaciones", GLAcc."Filtro Eliminaciones");
                        SetGLAccRowFilters(GLAcc, AccScheduleLine);

                        SetGLAccColumnFilters(GLAcc, AccScheduleLine, TempColumnLayout);
                        //AccSchedName.GET(CurrentSchedName);
                        if AccSchedName."Analysis View Name" = '' THEN BEGIN
                            AccScheduleLine.COPYFILTER("Dimension 1 Filter", GLAcc."Global Dimension 1 Filter");
                            AccScheduleLine.COPYFILTER("Dimension 2 Filter", GLAcc."Global Dimension 2 Filter");
                            AccScheduleLine.COPYFILTER("Dimension 3 Filter", GLAcc."Global Dimension 3 Filter");
                            AccScheduleLine.COPYFILTER("Dimension 4 Filter", GLAcc."Global Dimension 4 Filter");
                            AccScheduleLine.COPYFILTER("Dimension 5 Filter", GLAcc."Global Dimension 5 Filter");
                            AccScheduleLine.COPYFILTER("Business Unit Filter", GLAcc."Business Unit Filter");
                            AccScheduleLine.COPYFILTER("Salesperson Filter", GLAcc."Salesperson Filter");
                            if AccScheduleLine."Salesperson Code" <> '' THEN
                                GLAcc.SETRANGE(GLAcc."Salesperson Filter", AccScheduleLine."Salesperson Code");
                            //  GLAcc.FILTERGROUP(6);
                            GLAcc.SETFILTER(
                                "Global Dimension 1 Filter",
                                GetDimTotalingFilter(1, TempColumnLayout."Dimension 1 Totaling"));
                            GLAcc.SETFILTER(
                                "Global Dimension 2 Filter",
                                GetDimTotalingFilter(2, TempColumnLayout."Dimension 2 Totaling"));
                            GLAcc.SETFILTER(
                                "Global Dimension 3 Filter",
                                GetDimTotalingFilter(3, TempColumnLayout."Dimension 3 Totaling"));
                            GLAcc.SETFILTER(
                                "Global Dimension 4 Filter",
                                GetDimTotalingFilter(4, TempColumnLayout."Dimension 4 Totaling"));
                            GLAcc.SETFILTER(
                                "Global Dimension 5 Filter",
                                GetDimTotalingFilter(5, TempColumnLayout."Dimension 5 Totaling"));
                            // GLAcc.FILTERGROUP(2);

                            GLAcc.SETFILTER("Global Dimension 1 Filter", GetDimTotalingFilter(1, AccScheduleLine."Dimension 1 Totaling"));
                            GLAcc.SETFILTER("Global Dimension 2 Filter", GetDimTotalingFilter(2, AccScheduleLine."Dimension 2 Totaling"));
                            GLAcc.SETFILTER("Global Dimension 3 Filter", GetDimTotalingFilter(3, AccScheduleLine."Dimension 3 Totaling"));
                            GLAcc.SETFILTER("Global Dimension 4 Filter", GetDimTotalingFilter(4, AccScheduleLine."Dimension 4 Totaling"));
                            GLAcc.SETFILTER("Global Dimension 5 Filter", GetDimTotalingFilter(5, AccScheduleLine."Dimension 5 Totaling"));
                            if GLAcc."Global Dimension 1 Filter" = '' then
                                if DimFilter1 <> '' Then GLAcc.SetFilter("Global Dimension 1 Filter", DimFilter1);
                            if GLAcc."Global Dimension 2 Filter" = '' then
                                if DimFilter2 <> '' Then GLAcc.SetFilter("Global Dimension 2 Filter", DimFilter2);
                            if GLAcc."Global Dimension 3 Filter" = '' then
                                if DimFilter3 <> '' Then GLAcc.SetFilter("Global Dimension 3 Filter", DimFilter3);
                            if GLAcc."Global Dimension 4 Filter" = '' then
                                if DimFilter4 <> '' Then GLAcc.SetFilter("Global Dimension 4 Filter", DimFilter4);
                            if GLAcc."Global Dimension 5 Filter" = '' then
                                if DimFilter5 <> '' Then GLAcc.SetFilter("Global Dimension 5 Filter", DimFilter5);

                            if TempColumnLayout.GETFILTER("Salesperson Filter") <> '' THEN
                                GLAcc.SETFILTER("Salesperson Filter", TempColumnLayout."Salesperson Filter");
                            if AccScheduleLine."Salesperson Code" <> '' then
                                GLAcc.SETFILTER("Salesperson Filter", AccScheduleLine."Salesperson Code");
                            GLAcc.SETFILTER("Business Unit Filter", TempColumnLayout."Business Unit Totaling");
                            if FilFend <> '' then
                                GLAcc.SETFILTER("Salesperson Filter", FilFend);
                            //GLAcc.FILTERGROUP(0);
                            // ASc
                            if TempColumnLayout.Empresa <> '' THEN begin
                                if not Contrl.Permiso_Empresas(TempColumnLayout.Empresa) then exit;
                                GLAcc.CHANGECOMPANY(TempColumnLayout.Empresa);
                            end;
                            // Fin asc
                            Clear(PChar);
                            PChar.CambiaEmpresa(TempColumnLayout.Empresa);
                            PChar.SetTableView(GLAcc);
                            PChar.Run();
                            //Page.RUN(Page::"Chart of Accounts (G/L)", GLAcc)
                        END ELSE BEGIN
                            GLAcc.COPYFILTER("Date Filter", GLAccAnalysisView."Date Filter");
                            GLAcc.COPYFILTER("Budget Filter", GLAccAnalysisView."Budget Filter");
                            GLAcc.COPYFILTER("Business Unit Filter", GLAccAnalysisView."Business Unit Filter");
                            GLAccAnalysisView.SETRANGE("Analysis View Filter", AccSchedName."Analysis View Name");
                            AccScheduleLine.COPYFILTER("Salesperson Filter", GLAcc."Salesperson Filter");
                            AccScheduleLine.COPYFILTER("Dimension 1 Filter", GLAccAnalysisView."Dimension 1 Filter");
                            AccScheduleLine.COPYFILTER("Dimension 2 Filter", GLAccAnalysisView."Dimension 2 Filter");
                            AccScheduleLine.COPYFILTER("Dimension 3 Filter", GLAccAnalysisView."Dimension 3 Filter");
                            AccScheduleLine.COPYFILTER("Dimension 4 Filter", GLAccAnalysisView."Dimension 4 Filter");
                            AccScheduleLine.COPYFILTER("Dimension 5 Filter", GLAccAnalysisView."Dimension 5 Filter");
                            //  GLAccAnalysisView.FILTERGROUP(6);
                            GLAccAnalysisView.SETFILTER(
                                "Dimension 1 Filter",
                                GetDimTotalingFilter(1, TempColumnLayout."Dimension 1 Totaling"));
                            GLAccAnalysisView.SETFILTER(
                                "Dimension 2 Filter",
                                GetDimTotalingFilter(2, TempColumnLayout."Dimension 2 Totaling"));
                            GLAccAnalysisView.SETFILTER(
                                "Dimension 3 Filter",
                                GetDimTotalingFilter(3, TempColumnLayout."Dimension 3 Totaling"));
                            GLAccAnalysisView.SETFILTER(
                                "Dimension 4 Filter",
                                GetDimTotalingFilter(4, TempColumnLayout."Dimension 4 Totaling"));
                            GLAccAnalysisView.SETFILTER(
                                "Dimension 5 Filter",
                                GetDimTotalingFilter(5, TempColumnLayout."Dimension 5 Totaling"));
                            // GLAccAnalysisView.FILTERGROUP(2);
                            GLAccAnalysisView.SETFILTER("Dimension 1 Filter", GetDimTotalingFilter(1, AccScheduleLine."Dimension 1 Totaling"));
                            GLAccAnalysisView.SETFILTER("Dimension 2 Filter", GetDimTotalingFilter(2, AccScheduleLine."Dimension 2 Totaling"));
                            GLAccAnalysisView.SETFILTER("Dimension 3 Filter", GetDimTotalingFilter(3, AccScheduleLine."Dimension 3 Totaling"));
                            GLAccAnalysisView.SETFILTER("Dimension 4 Filter", GetDimTotalingFilter(4, AccScheduleLine."Dimension 4 Totaling"));
                            GLAccAnalysisView.SETFILTER("Dimension 5 Filter", GetDimTotalingFilter(5, AccScheduleLine."Dimension 5 Totaling"));
                            //GLAccAnalysisView.SETFILTER("Salesperson Filter",TempColumnLayout."Salesperson Filter");
                            GLAccAnalysisView.SETFILTER("Business Unit Filter", TempColumnLayout."Business Unit Totaling");
                            GLAccAnalysisView.FILTERGROUP(0);
                            CLEAR(ChartofAccAnalysisView);

                            ChartofAccAnalysisView.InsertTempGLAccAnalysisViews(GLAcc);
                            ChartofAccAnalysisView.SETTABLEVIEW(GLAccAnalysisView);
                            ChartofAccAnalysisView.RUN;
                        END;
                    END;
                END;
                //Asc
                if (AccScheduleLine.Totaling <> '') AND
                    (AccScheduleLine."Totaling Type" = AccScheduleLine."Totaling Type"::Customer)
                THEN BEGIN
                    //          COPYFILTER("Business Unit Filter",CuAcc."Business Unit Filter");
                    //          COPYFILTER("Budget Filter",CuAcc."Budget Filter");
                    SetCuAccRowFilters(CuAcc, AccScheduleLine);
                    SetCuAccColumnFilters(CuAcc, AccScheduleLine, TempColumnLayout);
                    //AccSchedName.GET(CurrentSchedName);
                    if AccSchedName."Analysis View Name" = '' THEN BEGIN
                        AccScheduleLine.COPYFILTER("Dimension 1 Filter", CuAcc."Global Dimension 1 Filter");
                        AccScheduleLine.COPYFILTER("Dimension 2 Filter", CuAcc."Global Dimension 2 Filter");
                        AccScheduleLine.COPYFILTER("Dimension 3 Filter", CuAcc."Global Dimension 3 Filter");
                        AccScheduleLine.COPYFILTER("Dimension 4 Filter", CuAcc."Global Dimension 4 Filter");
                        AccScheduleLine.COPYFILTER("Dimension 5 Filter", CuAcc."Global Dimension 5 Filter");
                        //            COPYFILTER("Business Unit Filter",CuAcc."Business Unit Filter");
                        //            CuAcc.FILTERGROUP(6);
                        CuAcc.SETFILTER(
                            "Global Dimension 1 Filter",
                            GetDimTotalingFilter(1, TempColumnLayout."Dimension 1 Totaling"));
                        CuAcc.SETFILTER(
                            "Global Dimension 2 Filter",
                            GetDimTotalingFilter(2, TempColumnLayout."Dimension 2 Totaling"));
                        CuAcc.SETFILTER(
                            "Global Dimension 3 Filter",
                            GetDimTotalingFilter(3, TempColumnLayout."Dimension 3 Totaling"));
                        CuAcc.SETFILTER(
                            "Global Dimension 4 Filter",
                            GetDimTotalingFilter(4, TempColumnLayout."Dimension 4 Totaling"));
                        CuAcc.SETFILTER(
                            "Global Dimension 5 Filter",
                            GetDimTotalingFilter(5, TempColumnLayout."Dimension 5 Totaling"));
                        //            CuAcc.FILTERGROUP(2);
                        CuAcc.SETFILTER("Global Dimension 1 Filter", GetDimTotalingFilter(1, AccScheduleLine."Dimension 1 Totaling"));
                        CuAcc.SETFILTER("Global Dimension 2 Filter", GetDimTotalingFilter(2, AccScheduleLine."Dimension 2 Totaling"));
                        CuAcc.SETFILTER("Global Dimension 3 Filter", GetDimTotalingFilter(3, AccScheduleLine."Dimension 3 Totaling"));
                        CuAcc.SETFILTER("Global Dimension 4 Filter", GetDimTotalingFilter(4, AccScheduleLine."Dimension 4 Totaling"));
                        CuAcc.SETFILTER("Global Dimension 5 Filter", GetDimTotalingFilter(5, AccScheduleLine."Dimension 5 Totaling"));
                        //            CuAcc.SETFILTER("Business Unit Filter",TempColumnLayout."Business Unit Totaling");
                        CuAcc.FILTERGROUP(0);
                        if TempColumnLayout.Empresa <> '' THEN begin
                            if not Contrl.Permiso_Empresas(TempColumnLayout.Empresa) then exit;
                            CuAcc.CHANGECOMPANY(TempColumnLayout.Empresa);
                        end;
                        Page.RUN(Page::"Customer List", CuAcc);
                    END;
                END;
                if (AccScheduleLine.Totaling <> '') AND
                    (AccScheduleLine."Totaling Type" = AccScheduleLine."Totaling Type"::Vendor)
                THEN BEGIN
                    //          COPYFILTER("Business Unit Filter",VeAcc."Business Unit Filter");
                    //          COPYFILTER("Budget Filter",VeAcc."Budget Filter");
                    SetVeAccRowFilters(VeAcc, AccScheduleLine);
                    SetVeAccColumnFilters(VeAcc, AccScheduleLine, TempColumnLayout);
                    //AccSchedName.GET(CurrentSchedName);
                    if AccSchedName."Analysis View Name" = '' THEN BEGIN
                        AccScheduleLine.COPYFILTER("Dimension 1 Filter", VeAcc."Global Dimension 1 Filter");
                        AccScheduleLine.COPYFILTER("Dimension 2 Filter", VeAcc."Global Dimension 2 Filter");
                        AccScheduleLine.COPYFILTER("Dimension 3 Filter", VeAcc."Global Dimension 3 Filter");
                        AccScheduleLine.COPYFILTER("Dimension 4 Filter", VeAcc."Global Dimension 4 Filter");
                        AccScheduleLine.COPYFILTER("Dimension 5 Filter", VeAcc."Global Dimension 5 Filter");
                        //            COPYFILTER("Business Unit Filter",VeAcc."Business Unit Filter");
                        //           VeAcc.FILTERGROUP(6);
                        VeAcc.SETFILTER(
                            "Global Dimension 1 Filter",
                            GetDimTotalingFilter(1, TempColumnLayout."Dimension 1 Totaling"));
                        VeAcc.SETFILTER(
                            "Global Dimension 2 Filter",
                            GetDimTotalingFilter(2, TempColumnLayout."Dimension 2 Totaling"));
                        VeAcc.SETFILTER(
                            "Global Dimension 3 Filter",
                            GetDimTotalingFilter(3, TempColumnLayout."Dimension 3 Totaling"));
                        VeAcc.SETFILTER(
                            "Global Dimension 4 Filter",
                            GetDimTotalingFilter(4, TempColumnLayout."Dimension 4 Totaling"));
                        VeAcc.SETFILTER(
                            "Global Dimension 5 Filter",
                            GetDimTotalingFilter(5, TempColumnLayout."Dimension 5 Totaling"));
                        //           VeAcc.FILTERGROUP(2);
                        VeAcc.SETFILTER("Global Dimension 1 Filter", GetDimTotalingFilter(1, AccScheduleLine."Dimension 1 Totaling"));
                        VeAcc.SETFILTER("Global Dimension 2 Filter", GetDimTotalingFilter(2, AccScheduleLine."Dimension 2 Totaling"));
                        VeAcc.SETFILTER("Global Dimension 3 Filter", GetDimTotalingFilter(3, AccScheduleLine."Dimension 3 Totaling"));
                        VeAcc.SETFILTER("Global Dimension 4 Filter", GetDimTotalingFilter(4, AccScheduleLine."Dimension 4 Totaling"));
                        VeAcc.SETFILTER("Global Dimension 5 Filter", GetDimTotalingFilter(5, AccScheduleLine."Dimension 5 Totaling"));
                        //            VeAcc.SETFILTER("Business Unit Filter",TempColumnLayout."Business Unit Totaling");
                        VeAcc.FILTERGROUP(0);
                        if TempColumnLayout.Empresa <> '' THEN begin
                            if not Contrl.Permiso_Empresas(TempColumnLayout.Empresa) then exit;
                            VeAcc.CHANGECOMPANY(TempColumnLayout.Empresa);
                        end;
                        Page.RUN(Page::"Vendor List", VeAcc);
                    END;
                END;
                // Fin Asc
                if (AccScheduleLine.Totaling <> '') AND
                    (AccScheduleLine."Totaling Type" IN [AccScheduleLine."Totaling Type"::"Cost Type", AccScheduleLine."Totaling Type"::"Cost Type Total"])
                THEN BEGIN
                    SetCostTypeRowFilters(CostType, AccScheduleLine, TempColumnLayout);
                    // SetCostTypeColumnFilters(CostType,TempColumnLayout);
                    SetCostTypeColumnFilters(CostType, AccScheduleLine, TempColumnLayout);
                    WITH TempColumnLayout DO BEGIN
                        CASE "Ledger Entry Type" OF
                            TempColumnLayout."Ledger Entry Type"::"Entries":
                                BEGIN
                                    CostTypeChart.SETTABLEVIEW(CostType);
                                    CostTypeChart.RUN;
                                END;
                            TempColumnLayout."Ledger Entry Type"::"Budget Entries":
                                BEGIN
                                    CostBudPerPeriod.SETTABLEVIEW(CostType);
                                    CostBudPerPeriod.RUN;
                                END;
                        END;  // Case
                    END;  // With
                END;  // Begin
            END; // else Begin
    end;


    /// <summary>
    /// SetCFAccColumnFilter.
    /// </summary>
    /// <param name="CFAccount">VAR Record "Cash Flow Account".</param>
    /// <param name="AccSchedLine2">Record "Acc. Schedule Line".</param>
    /// <param name="ColumnLayout2">VAR Record "Column Layout".</param>
    procedure SetCFAccColumnFilter(var CFAccount: Record "Cash Flow Account"; AccSchedLine2: Record "Acc. Schedule Line"; var ColumnLayout2: Record "Column Layout")
    var
        FromDate: Date;
        ToDate: Date;
        FiscalStartDate2: Date;
    begin
        with ColumnLayout2 do begin
            CalcColumnDates(ColumnLayout2, FromDate, ToDate, FiscalStartDate2);
            case "Column Type" of
                "Column Type"::"Net Change":
                    case AccSchedLine2."Row Type" of
                        AccSchedLine2."Row Type"::"Net Change":
                            CFAccount.SetRange("Date Filter", FromDate, ToDate);
                        AccSchedLine2."Row Type"::"Beginning Balance":
                            CFAccount.SetFilter("Date Filter", '..%1', ClosingDate(FromDate - 1));
                        AccSchedLine2."Row Type"::"Balance at Date":
                            CFAccount.SetRange("Date Filter", 0D, ToDate);
                    end;
                "Column Type"::"Balance at Date":
                    if AccSchedLine2."Row Type" = AccSchedLine2."Row Type"::"Beginning Balance" then
                        CFAccount.SetRange("Date Filter", 0D) // Force a zero return
                    else
                        CFAccount.SetRange("Date Filter", 0D, ToDate);
                "Column Type"::"Beginning Balance":
                    if AccSchedLine2."Row Type" = AccSchedLine2."Row Type"::"Balance at Date" then
                        CFAccount.SetRange("Date Filter", 0D) // Force a zero return
                    else
                        CFAccount.SetRange(
                          "Date Filter", 0D, CalcDate('<-1D>', FromDate));
                "Column Type"::"Year to Date":
                    case AccSchedLine2."Row Type" of
                        AccSchedLine2."Row Type"::"Net Change":
                            CFAccount.SetRange("Date Filter", FiscalStartDate2, ToDate);
                        AccSchedLine2."Row Type"::"Beginning Balance":
                            CFAccount.SetFilter("Date Filter", '..%1', FiscalStartDate2 - 1);
                        AccSchedLine2."Row Type"::"Balance at Date":
                            CFAccount.SetRange("Date Filter", 0D, ToDate);
                    end;
                "Column Type"::"Rest of Fiscal Year":
                    case AccSchedLine2."Row Type" of
                        AccSchedLine2."Row Type"::"Net Change":
                            CFAccount.SetRange(
                              "Date Filter",
                              CalcDate('<+1D>', ToDate), AccountingPeriodMgt.FindEndOfFiscalYear(FiscalStartDate2));
                        AccSchedLine2."Row Type"::"Beginning Balance":
                            CFAccount.SetRange("Date Filter", 0D, ToDate);
                        AccSchedLine2."Row Type"::"Balance at Date":
                            CFAccount.SetRange("Date Filter", 0D, AccountingPeriodMgt.FindEndOfFiscalYear(ToDate));
                    end;
                "Column Type"::"Entire Fiscal Year":
                    case AccSchedLine2."Row Type" of
                        AccSchedLine2."Row Type"::"Net Change":
                            CFAccount.SetRange(
                              "Date Filter",
                              FiscalStartDate2, AccountingPeriodMgt.FindEndOfFiscalYear(FiscalStartDate2));
                        AccSchedLine2."Row Type"::"Beginning Balance":
                            CFAccount.SetFilter("Date Filter", '..%1', ClosingDate(FiscalStartDate2 - 1));
                        AccSchedLine2."Row Type"::"Balance at Date":
                            CFAccount.SetRange("Date Filter", 0D, AccountingPeriodMgt.FindEndOfFiscalYear(ToDate));
                    end;
            end;
        end;

        //OnAfterSetCFAccColumnFilter(CFAccount, AccSchedLine2, ColumnLayout2);
    end;

    /// <summary>
    /// SetCFAccRowFilter.
    /// </summary>
    /// <param name="CFAccount">VAR Record "Cash Flow Account".</param>
    /// <param name="AccSchedLine2">VAR Record "Acc. Schedule Line".</param>
    procedure SetCFAccRowFilter(var CFAccount: Record "Cash Flow Account"; var AccSchedLine2: Record "Acc. Schedule Line")
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        //OnBeforeSetCFAccRowFilter(CFAccount, AccSchedLine2, IsHandled);
        if IsHandled then
            exit;

        with AccSchedLine2 do begin
            CopyFilter("Cash Flow Forecast Filter", CFAccount."Cash Flow Forecast Filter");

            case "Totaling Type" of
                "Totaling Type"::"Cash Flow Entry Accounts":
                    begin
                        CFAccount.SetFilter("No.", Totaling);
                        CFAccount.SetRange("Account Type", CFAccount."Account Type"::Entry);
                    end;
                "Totaling Type"::"Cash Flow Total Accounts":
                    begin
                        CFAccount.SetFilter("No.", Totaling);
                        CFAccount.SetFilter("Account Type", '<>%1', CFAccount."Account Type"::Entry);
                    end;
            end;
        end;

        //OnAfterSetCFAccRowFilter(CFAccount, AccSchedLine2);
    end;

    local procedure DrillDownOnCFAccount(TempColumnLayout: Record "Column Layout" temporary; var AccScheduleLine: Record "Acc. Schedule Line")
    var
        CFAccount: Record "Cash Flow Account";
        GLAccAnalysisView: Record "G/L Account (Analysis View)";
        ChartOfAccsAnalysisView: Page "Chart of Accs. (Analysis View)";
    begin
        with AccScheduleLine do begin
            CopyFilter("Cash Flow Forecast Filter", CFAccount."Cash Flow Forecast Filter");

            SetCFAccRowFilter(CFAccount, AccScheduleLine);
            SetCFAccColumnFilter(CFAccount, AccScheduleLine, TempColumnLayout);
            AccSchedName.Get("Schedule Name");
            if AccSchedName."Analysis View Name" = '' then begin
                CopyFilter("Dimension 1 Filter", CFAccount."Global Dimension 1 Filter");
                CopyFilter("Dimension 2 Filter", CFAccount."Global Dimension 2 Filter");
                CFAccount.FilterGroup(2);
                CFAccount.SetFilter("Global Dimension 1 Filter", GetDimTotalingFilter(1, "Dimension 1 Totaling"));
                CFAccount.SetFilter("Global Dimension 2 Filter", GetDimTotalingFilter(2, "Dimension 2 Totaling"));
                CFAccount.FilterGroup(8);
                CFAccount.SetFilter("Global Dimension 1 Filter", GetDimTotalingFilter(1, TempColumnLayout."Dimension 1 Totaling"));
                CFAccount.SetFilter("Global Dimension 2 Filter", GetDimTotalingFilter(2, TempColumnLayout."Dimension 2 Totaling"));
                CFAccount.FilterGroup(0);
                PAGE.Run(PAGE::"Chart of Cash Flow Accounts", CFAccount)
            end else begin
                CFAccount.CopyFilter("Date Filter", GLAccAnalysisView."Date Filter");
                CFAccount.CopyFilter("Cash Flow Forecast Filter", GLAccAnalysisView."Cash Flow Forecast Filter");
                GLAccAnalysisView.SetRange("Analysis View Filter", AccSchedName."Analysis View Name");
                GLAccAnalysisView.CopyDimFilters(AccScheduleLine);
                GLAccAnalysisView.FilterGroup(2);
                GLAccAnalysisView.SetDimFilters(
                  GetDimTotalingFilter(1, "Dimension 1 Totaling"),
                  GetDimTotalingFilter(2, "Dimension 2 Totaling"),
                  GetDimTotalingFilter(3, "Dimension 3 Totaling"),
                  GetDimTotalingFilter(4, "Dimension 4 Totaling"));
                GLAccAnalysisView.FilterGroup(8);
                GLAccAnalysisView.SetDimFilters(
                  GetDimTotalingFilter(1, TempColumnLayout."Dimension 1 Totaling"),
                  GetDimTotalingFilter(2, TempColumnLayout."Dimension 2 Totaling"),
                  GetDimTotalingFilter(3, TempColumnLayout."Dimension 3 Totaling"),
                  GetDimTotalingFilter(4, TempColumnLayout."Dimension 4 Totaling"));
                GLAccAnalysisView.FilterGroup(0);
                Clear(ChartOfAccsAnalysisView);
                ChartOfAccsAnalysisView.InsertTempCFAccountAnalysisVie(CFAccount);
                ChartOfAccsAnalysisView.SetTableView(GLAccAnalysisView);
                ChartOfAccsAnalysisView.Run;
            end;
        end;
    end;

    /// <summary>
    /// ForceRecalculate.
    /// </summary>
    /// <param name="NewRecalculate">Boolean.</param>
    procedure ForceRecalculate(NewRecalculate: Boolean)
    begin
        Recalculate := NewRecalculate;
    end;

    PROCEDURE OpenSchedule(VAR CurrentSchedName: Code[10]; VAR AccSchedLine: Record 85);
    BEGIN
        CheckTemplateName(CurrentSchedName);
        AccSchedLine.FILTERGROUP(2);
        AccSchedLine.SETRANGE("Schedule Name", CurrentSchedName);
        AccSchedLine.FILTERGROUP(0);
    END;

    PROCEDURE CheckTemplateName(VAR CurrentSchedName: Code[10]);
    VAR
        AccSchedName: Record 84;
    BEGIN
        if NOT AccSchedName.GET(CurrentSchedName) THEN BEGIN
            if NOT AccSchedName.FIND('-') THEN BEGIN
                AccSchedName.INIT;
                AccSchedName.Name := Text000;
                AccSchedName.Description := Text001;
                AccSchedName.INSERT;
                COMMIT;
            END;
            CurrentSchedName := AccSchedName.Name;
        END;
    END;

    PROCEDURE CheckName(CurrentSchedName: Code[10]);
    VAR
        AccSchedName: Record 84;
    BEGIN
        AccSchedName.GET(CurrentSchedName);
    END;

    PROCEDURE SetName(CurrentSchedName: Code[10]; VAR AccSchedLine: Record 85);
    BEGIN
        AccSchedLine.FILTERGROUP(2);
        AccSchedLine.SETRANGE("Schedule Name", CurrentSchedName);
        AccSchedLine.FILTERGROUP(0);
        if AccSchedLine.FIND('-') THEN;
    END;

    PROCEDURE LookupName(CurrentSchedName: Code[10]; VAR EntrdSchedName: Text[10]): Boolean;
    VAR
        AccSchedName: Record 84;
    BEGIN
        AccSchedName.Name := CurrentSchedName;
        if PAGE.RUNMODAL(0, AccSchedName) <> ACTION::LookupOK THEN
            EXIT(FALSE);

        EntrdSchedName := AccSchedName.Name;
        EXIT(TRUE);
    END;

    PROCEDURE OpenColumns(VAR CurrentColumnName: Code[10]; VAR ColumnLayout: Record 334);
    BEGIN
        CheckColumnTemplateName(CurrentColumnName);
        ColumnLayout.FILTERGROUP(2);
        ColumnLayout.SETRANGE("Column Layout Name", CurrentColumnName);
        ColumnLayout.FILTERGROUP(0);
    END;

    PROCEDURE CheckColumnTemplateName(VAR CurrentColumnName: Code[10]);
    VAR
        ColumnLayoutName: Record 333;
    BEGIN
        if NOT ColumnLayoutName.GET(CurrentColumnName) THEN BEGIN
            if NOT ColumnLayoutName.FIND('-') THEN BEGIN
                ColumnLayoutName.INIT;
                ColumnLayoutName.Name := Text000;
                ColumnLayoutName.Description := Text002;
                ColumnLayoutName.INSERT;
                COMMIT;
            END;
            CurrentColumnName := ColumnLayoutName.Name;
        END;
    END;

    PROCEDURE CheckColumnName(CurrentColumnName: Code[10]);
    VAR
        ColumnLayoutName: Record 333;
    BEGIN
        ColumnLayoutName.GET(CurrentColumnName);
    END;

    PROCEDURE SetColumnName(CurrentColumnName: Code[10]; VAR ColumnLayout: Record 334);
    BEGIN
        ColumnLayout.RESET;
        ColumnLayout.FILTERGROUP(2);
        ColumnLayout.SETRANGE("Column Layout Name", CurrentColumnName);
        ColumnLayout.FILTERGROUP(0);
        if ColumnLayout.FIND('-') THEN;
    END;

    PROCEDURE CopyColumnsToTemp(NewColumnName: Code[10]; VAR TempColumnLayout: Record 334 temporary);
    VAR
        ColumnLayout: Record 334;
    BEGIN
        TempColumnLayout.DELETEALL;
        ColumnLayout.SETRANGE("Column Layout Name", NewColumnName);
        if ColumnLayout.FIND('-') THEN
            REPEAT
                TempColumnLayout := ColumnLayout;
                TempColumnLayout.INSERT;
            UNTIL ColumnLayout.NEXT = 0;
        if TempColumnLayout.FIND('-') THEN;
    END;

    PROCEDURE LookupColumnName(CurrentColumnName: Code[10]; VAR EntrdColumnName: Text[10]): Boolean;
    VAR
        ColumnLayoutName: Record 333;
    BEGIN
        ColumnLayoutName.Name := CurrentColumnName;
        if PAGE.RUNMODAL(0, ColumnLayoutName) <> ACTION::LookupOK THEN
            EXIT(FALSE);

        EntrdColumnName := ColumnLayoutName.Name;
        EXIT(TRUE);
    END;

    PROCEDURE CheckAnalysisView(CurrentSchedName: Code[10]; CurrentColumnName: Code[10]; TestColumnName: Boolean);
    VAR
        ColumnLayout2: Record 334;
        AnyColumnDimensions: Boolean;
    BEGIN
        if NOT AnalysisViewRead THEN BEGIN
            AnalysisViewRead := TRUE;
            if CurrentSchedName <> AccSchedName.Name THEN BEGIN
                CheckTemplateName(CurrentSchedName);
                AccSchedName.GET(CurrentSchedName);
            END;
            if TestColumnName THEN
                if CurrentColumnName <> ColumnLayoutName.Name THEN BEGIN
                    CheckColumnTemplateName(CurrentColumnName);
                    ColumnLayoutName.GET(CurrentColumnName);
                END;
            if AccSchedName."Analysis View Name" = '' THEN BEGIN
                if NOT GLSetupRead THEN
                    GLSetup.GET;
                GLSetupRead := TRUE;
                AnalysisView.INIT;
                AnalysisView."Dimension 1 Code" := GLSetup."Global Dimension 1 Code";
                AnalysisView."Dimension 3 Code" := GLSetup."Shortcut Dimension 3 Code";
                AnalysisView."Dimension 4 Code" := GLSetup."Shortcut Dimension 4 Code";
                AnalysisView."Dimension 5 Totaling" := GLSetup."Shortcut Dimension 5 Code";

            END ELSE
                AnalysisView.GET(AccSchedName."Analysis View Name");
            if (AccSchedName."Analysis View Name" <> ColumnLayoutName."Analysis View Name") THEN BEGIN
                AnyColumnDimensions := FALSE;
                ColumnLayout2.SETRANGE("Column Layout Name", ColumnLayoutName.Name);
                if ColumnLayout2.FIND('-') THEN
                    REPEAT
                        AnyColumnDimensions :=
                          (ColumnLayout2."Dimension 1 Totaling" <> '') OR
                          (ColumnLayout2."Dimension 2 Totaling" <> '') OR
                          (ColumnLayout2."Dimension 3 Totaling" <> '') OR
                          (ColumnLayout2."Dimension 4 Totaling" <> '') OR
                          (ColumnLayout2."Dimension 5 Totaling" <> '');
                    UNTIL AnyColumnDimensions OR (ColumnLayout2.NEXT = 0);
                if AnyColumnDimensions THEN
                    ERROR(
                      Text024,
                      AccSchedName.FIELDCAPTION("Analysis View Name"),
                      AccSchedName.TABLECAPTION,
                      AccSchedName."Analysis View Name",
                      ColumnLayoutName.FIELDCAPTION("Analysis View Name"),
                      ColumnLayoutName.TABLECAPTION,
                      ColumnLayoutName."Analysis View Name");
            END;
        END;
    END;

    PROCEDURE FindFiscalYear(BalanceDate: Date): Date;
    VAR
        AccountingPeriod: Record 50;
    BEGIN
        AccountingPeriod.SETRANGE("New Fiscal Year", TRUE);
        AccountingPeriod.SETRANGE("Starting Date", 0D, BalanceDate);
        if AccountingPeriod.FIND('+') THEN
            EXIT(AccountingPeriod."Starting Date");
        AccountingPeriod.RESET;
        AccountingPeriod.FIND('-');
        EXIT(AccountingPeriod."Starting Date");
    END;

    LOCAL PROCEDURE FindEndOfFiscalYear(BalanceDate: Date): Date;
    VAR
        AccountingPeriod: Record 50;
    BEGIN
        AccountingPeriod.SETRANGE("New Fiscal Year", TRUE);
        AccountingPeriod.SETFILTER("Starting Date", '>%1', FindFiscalYear(BalanceDate));
        if AccountingPeriod.FIND('-') THEN
            EXIT((CALCDATE('<-1D>', AccountingPeriod."Starting Date")));
        EXIT((99991231D));
    END;

    LOCAL PROCEDURE AccPeriodStartEnd(Formula: Code[20]; Date: Date; VAR StartDate: Date; VAR EndDate: Date);
    VAR
        ColumnLayout: Record 334;
        AccountingPeriod: Record 50;
        AccountingPeriodFY: Record 50;
        Steps: Integer;
        Type: Enum "Period Type";
        CurrentPeriodNo: Integer;
        RangeFromType: Enum "Period Formula Range";
        RangeToType: Enum "Period Formula Range";
        RangeFromInt: Integer;
        RangeToInt: Integer;
        PeriodParse: Codeunit "Period Formula Parser";
        LanguageId: Integer;
    BEGIN
        if Formula = '' THEN
            EXIT;

        PeriodParse.ParsePeriodFormula(Formula, Steps, Type, RangeFromType, RangeToType, RangeFromInt, RangeToInt, LanguageId);

        // Find current period
        AccountingPeriod.SETFILTER("Starting Date", '<=%1', Date);
        if NOT AccountingPeriod.FIND('+') THEN BEGIN
            AccountingPeriod.RESET;
            if Steps < 0 THEN
                AccountingPeriod.FIND('-')
            ELSE
                AccountingPeriod.FIND('+')
        END;
        AccountingPeriod.RESET;

        CASE Type OF
            Type::Period:
                BEGIN
                    if AccountingPeriod.NEXT(Steps) <> Steps THEN
                        PeriodError := TRUE;
                    StartDate := AccountingPeriod."Starting Date";
                    EndDate := AccPeriodEndDate(StartDate);
                END;
            Type::"Fiscal year":
                BEGIN
                    AccountingPeriodFY := AccountingPeriod;
                    WHILE NOT AccountingPeriodFY."New Fiscal Year" DO
                        if AccountingPeriodFY.FIND('<') THEN
                            CurrentPeriodNo += 1
                        ELSE
                            AccountingPeriodFY."New Fiscal Year" := TRUE;
                    AccountingPeriodFY.SETRANGE("New Fiscal Year", TRUE);
                    AccountingPeriodFY.NEXT(Steps);

                    AccPeriodStartOrEnd(AccountingPeriodFY, CurrentPeriodNo, RangeFromType, RangeFromInt, FALSE, StartDate);
                    AccPeriodStartOrEnd(AccountingPeriodFY, CurrentPeriodNo, RangeToType, RangeToInt, TRUE, EndDate);
                END;
        END;
    END;

    LOCAL PROCEDURE AccPeriodEndDate(StartDate: Date): Date;
    VAR
        AccountingPeriod: Record 50;
    BEGIN
        AccountingPeriod."Starting Date" := StartDate;
        if AccountingPeriod.FIND('>') THEN
            EXIT(AccountingPeriod."Starting Date" - 1);
        EXIT(99991231D);
    END;

    LOCAL PROCEDURE AccPeriodGetPeriod(VAR AccountingPeriod: Record 50; AccPeriodNo: Integer): Date;
    BEGIN
        CASE TRUE OF
            AccPeriodNo > 0:
                BEGIN
                    AccountingPeriod.NEXT(AccPeriodNo);
                    EXIT;
                END;
            AccPeriodNo = 0:
                EXIT;
            AccPeriodNo < 0:
                BEGIN
                    AccountingPeriod.SETRANGE("New Fiscal Year", TRUE);
                    if NOT AccountingPeriod.FIND('>') THEN BEGIN
                        AccountingPeriod.RESET;
                        AccountingPeriod.FIND('+');
                        EXIT;
                    END;
                    AccountingPeriod.RESET;
                    AccountingPeriod.FIND('<');
                    EXIT;
                END;
        END;
    END;

    LOCAL PROCEDURE AccPeriodStartOrEnd(AccountingPeriod: Record 50; CurrentPeriodNo: Integer; RangeType: Enum "Period Formula Range"; RangeInt: Integer; EndDate: Boolean; VAR Date: Date);
    BEGIN
        CASE RangeType OF
            RangeType::CP:
                AccPeriodGetPeriod(AccountingPeriod, CurrentPeriodNo);
            RangeType::LP:
                AccPeriodGetPeriod(AccountingPeriod, -1);
            RangeType::Int:
                AccPeriodGetPeriod(AccountingPeriod, RangeInt - 1);
        END;
        if EndDate THEN
            Date := AccPeriodEndDate(AccountingPeriod."Starting Date")
        ELSE
            Date := AccountingPeriod."Starting Date";
    END;

    LOCAL PROCEDURE InitBasePercents(AccSchedLine: Record 85; ColumnLayout: Record 334);
    VAR
        BaseIdx: Integer;
    BEGIN
        CLEAR(BasePercentLine);
        BaseIdx := 0;

        WITH AccSchedLine DO BEGIN
            SETRANGE("Schedule Name", "Schedule Name");
            if FIND('-') THEN
                REPEAT
                    if "Totaling Type" = "Totaling Type"::"Set Base For Percent" THEN BEGIN
                        BaseIdx := BaseIdx + 1;
                        if BaseIdx > ARRAYLEN(BasePercentLine) THEN
                            ShowError(
                              STRSUBSTNO(Text022, ARRAYLEN(BasePercentLine), FIELDCAPTION("Totaling Type"), "Totaling Type"),
                              AccSchedLine, ColumnLayout);
                        BasePercentLine[BaseIdx] := "Line No.";
                    END;
                UNTIL NEXT = 0;
        END;

        if BaseIdx = 0 THEN BEGIN
            AccSchedLine."Totaling Type" := AccSchedLine."Totaling Type"::"Set Base For Percent";
            ShowError(
              STRSUBSTNO(Text023, AccSchedLine.FIELDCAPTION("Totaling Type"), AccSchedLine."Totaling Type"),
              AccSchedLine, ColumnLayout);
        END;
    END;

    LOCAL PROCEDURE GetBasePercentLine(AccSchedLine: Record 85; ColumnLayout: Record 334): Integer;
    VAR
        BaseIdx: Integer;
    BEGIN
        if BasePercentLine[1] = 0 THEN
            InitBasePercents(AccSchedLine, ColumnLayout);

        BaseIdx := ARRAYLEN(BasePercentLine);
        REPEAT
            if BasePercentLine[BaseIdx] <> 0 THEN
                if BasePercentLine[BaseIdx] < AccSchedLine."Line No." THEN
                    EXIT(BasePercentLine[BaseIdx]);
            BaseIdx := BaseIdx - 1;
        UNTIL BaseIdx = 0;

        AccSchedLine."Totaling Type" := AccSchedLine."Totaling Type"::"Set Base For Percent";
        ShowError(
          STRSUBSTNO(Text023, AccSchedLine.FIELDNAME("Totaling Type"), AccSchedLine."Totaling Type"),
          AccSchedLine, ColumnLayout);
    END;

    PROCEDURE CalcCellxDate(VAR LiqAccSchedLine: Record "Acc. Schedule Line";
    VAR LiqAccSchedColumn: Record "Column Layout"; FechaD: Date; FechaH: Date): Decimal;
    VAR
        Result: Decimal;
    BEGIN
        LiqAccountSchedLine.COPYFILTERS(LiqAccSchedLine);
        StartDate := LiqAccountSchedLine.GETRANGEMIN("Date Filter");
        if EndDate <> LiqAccountSchedLine.GETRANGEMAX("Date Filter") THEN BEGIN
            EndDate := LiqAccountSchedLine.GETRANGEMAX("Date Filter");
            FiscalStartDate := FindFiscalYear(EndDate);
        END;
        DivisionError := FALSE;
        PeriodError := FALSE;
        CallLevel := 0;
        CallLiqAccSchedLineID := LiqAccSchedLine."Line No.";
        CallLiqAccSchedColumnID := LiqAccSchedColumn."Line No.";

        if (OldLiqAccSchedLineFilter <> LiqAccSchedLine.GETFILTERS) OR
           (OldLiqAccSchedColumnFilter <> LiqAccSchedColumn.GETFILTERS) OR
           (OldLiqAccSchedLineName <> LiqAccSchedLine."Schedule Name") OR
           (OldLiqAccSchedColumnName <> LiqAccSchedColumn."Column Layout Name")
        THEN BEGIN
            LiqAccSchedCellValue.RESET;
            LiqAccSchedCellValue.DELETEALL;
            CLEAR(BasePercentLine);
            OldLiqAccSchedLineFilter := LiqAccSchedLine.GETFILTERS;
            OldLiqAccSchedColumnFilter := LiqAccSchedColumn.GETFILTERS;
            OldLiqAccSchedLineName := LiqAccSchedLine."Schedule Name";
            OldLiqAccSchedColumnName := LiqAccSchedColumn."Column Layout Name";
        END;

        Result := CalcCellValuexDate(LiqAccSchedLine, LiqAccSchedColumn, FechaD, FechaH);
        WITH LiqAccSchedColumn DO BEGIN
            CASE Show OF
                Show::"When Positive":
                    if Result < 0 THEN
                        Result := 0;
                Show::"When Negative":
                    if Result > 0 THEN
                        Result := 0;
            END;
            if "Show Opposite Sign" THEN
                Result := -Result;
        END;
        if LiqAccSchedLine."Show Opposite Sign" THEN
            Result := -Result;
        EXIT(Result);
    END;

    PROCEDURE CalcCellValuexDate(LiqAccSchedLine: Record "Acc. Schedule Line";
    LiqAccSchedColumn: Record "Column Layout"; FechaD: Date; FechaH: Date): Decimal;
    VAR
        Result: Decimal;
        LiqAcc: Record "Cash Flow Account";
    BEGIN
        //Result := 0;
        LiqAccSchedLine.SETRANGE(LiqAccSchedLine."Date Filter", FechaD, FechaH);
        if LiqAccSchedLine.Totaling <> '' THEN
            if FALSE Then Begin //{LiqAccSchedCellValue.GET(LiqAccSchedLine."Line No.",LiqAccSchedColumn."Line No.")} THEN BEGIN
                Result := LiqAccSchedCellValue.Value;
                DivisionError := DivisionError OR LiqAccSchedCellValue."Has Error";
                PeriodError := PeriodError OR LiqAccSchedCellValue."Period Error";
            END ELSE BEGIN
                if LiqAccSchedColumn."Column Type" = LiqAccSchedColumn."Column Type"::Formula THEN
                    Result := EvaluateExpressionxFecha(FALSE, LiqAccSchedColumn.Formula, LiqAccSchedLine, LiqAccSchedColumn, FechaD, FechaH)
                ELSE
                    if LiqAccSchedLine."Totaling Type" IN
                      [LiqAccSchedLine."Totaling Type"::Formula, LiqAccSchedLine."Totaling Type"::"Set Base For Percent"]
                    THEN
                        Result := EvaluateExpressionxFecha(TRUE, LiqAccSchedLine.Totaling, LiqAccSchedLine, LiqAccSchedColumn, FechaD, FechaH)
                    ELSE
                        if (StartDate = 0D) OR (EndDate = 0D) OR (EndDate = 99991231D) THEN BEGIN
                            Result := 0;
                            PeriodError := TRUE;
                        END ELSE BEGIN
                            LiqAccSchedLine.COPYFILTERS(LiqAccountSchedLine);
                            SetLiqAccRowFilter(LiqAcc, LiqAccSchedLine);
                            SetLiqAccColumnFilter(LiqAcc, LiqAccSchedLine, LiqAccSchedColumn);
                            LiqAccSchedLine.SETRANGE(LiqAccSchedLine."Date Filter", FechaD, FechaH);
                            //  {if (LiqAccSchedLine."Totaling Type" = LiqAccSchedLine."Totaling Type"::"Posting Accounts") AND
                            //     (STRLEN(LiqAccSchedLine.Totaling) <= 30)
                            //  THEN BEGIN
                            //    LiqAcc."Account Type" := LiqAcc."Account Type"::Total;
                            //    LiqAcc.Totaling := LiqAccSchedLine.Totaling;
                            //    Result := Result + CalcLiqAccountxDate(LiqAcc,LiqAccSchedLine,LiqAccSchedColumn,FechaD,FechaH);
                            //  END ELSE  }
                            if LiqAcc.FIND('-') THEN
                                REPEAT
                                    Result := Result + CalcLiqAccountxDate(LiqAcc, LiqAccSchedLine, LiqAccSchedColumn, FechaD, FechaH);
                                UNTIL LiqAcc.NEXT = 0;
                        END;

                LiqAccSchedCellValue."Row No." := LiqAccSchedLine."Line No.";
                LiqAccSchedCellValue."Column No." := LiqAccSchedColumn."Line No.";
                LiqAccSchedCellValue.Value := Result;
                LiqAccSchedCellValue."Has Error" := DivisionError;
                LiqAccSchedCellValue."Period Error" := PeriodError;
                //LiqAccSchedCellValue.INSERT;
            END;
        EXIT(Result);
    END;

    PROCEDURE EvaluateExpressionxFecha(IsAccSchedLineExpression: Boolean; Expression: Text[80]
    ; LiqAccSchedLine: Record "Acc. Schedule Line"; LiqAccSchedColumn: Record "Column Layout"; FechaD: Date; FechaH: Date): Decimal
    VAR
        LiqAccSchedLine2: Record "Acc. Schedule Line";
        Result: Decimal;
        Parantheses: Integer;
        Operator: Char;
        LeftOperand: Text[80];
        RightOperand: Text[80];
        LeftResult: Decimal;
        RightResult: Decimal;
        i: Integer;
        IsExpression: Boolean;
        IsFilter: Boolean;
        Operators: Text[8];
        OperatorNo: Integer;
        LigAccSchedLineID: Integer;
    BEGIN
        Result := 0;

        CallLevel := CallLevel + 1;
        if CallLevel > 25 THEN
            ShowError(Text1140011,
                       LiqAccSchedLine, LiqAccSchedColumn);

        Expression := DELCHR(Expression, '<>', ' ');
        if STRLEN(Expression) > 0 THEN BEGIN
            Parantheses := 0;
            IsExpression := FALSE;
            Operators := '+-*/^%';
            OperatorNo := 1;
            REPEAT
                i := STRLEN(Expression);
                REPEAT
                    if Expression[i] = '(' THEN
                        Parantheses := Parantheses + 1
                    ELSE
                        if Expression[i] = ')' THEN
                            Parantheses := Parantheses - 1;
                    if (Parantheses = 0) AND (Expression[i] = Operators[OperatorNo]) THEN
                        IsExpression := TRUE
                    ELSE
                        i := i - 1;
                UNTIL IsExpression OR (i <= 0);
                if NOT IsExpression THEN
                    OperatorNo := OperatorNo + 1;
            UNTIL (OperatorNo > STRLEN(Operators)) OR IsExpression;
            if IsExpression THEN BEGIN
                if i > 1 THEN
                    LeftOperand := COPYSTR(Expression, 1, i - 1)
                ELSE
                    LeftOperand := '';
                if i < STRLEN(Expression) THEN
                    RightOperand := COPYSTR(Expression, i + 1)
                ELSE
                    RightOperand := '';
                Operator := Expression[i];
                LeftResult := EvaluateExpressionxFecha(IsAccSchedLineExpression, LeftOperand, LiqAccSchedLine, LiqAccSchedColumn,
                FechaD, FechaH);
                if (RightOperand = '') AND (Operator = '%') AND NOT IsAccSchedLineExpression AND
                   (LiqAccSchedLine."Totaling Type" <> LiqAccSchedLine."Totaling Type"::"Set Base For Percent")
                THEN BEGIN
                    LiqAccSchedLine2.COPY(LiqAccSchedLine);
                    LiqAccSchedLine2."Line No." := GetBasePercentLine(LiqAccSchedLine, LiqAccSchedColumn);
                    LiqAccSchedLine2.FIND;
                    RightResult :=
                      EvaluateExpressionxFecha(
                        IsAccSchedLineExpression, LeftOperand, LiqAccSchedLine2, LiqAccSchedColumn, FechaD, FechaH);
                END ELSE
                    RightResult :=
                      EvaluateExpressionxFecha(
                        IsAccSchedLineExpression, RightOperand, LiqAccSchedLine, LiqAccSchedColumn, FechaD, FechaH);
                CASE Operator OF
                    '^':
                        Result := POWER(LeftResult, RightResult);
                    '%':
                        if RightResult = 0 THEN BEGIN
                            Result := 0;
                            DivisionError := TRUE;
                        END ELSE
                            Result := 100 * LeftResult / RightResult;
                    '*':
                        Result := LeftResult * RightResult;
                    '/':
                        if RightResult = 0 THEN BEGIN
                            Result := 0;
                            DivisionError := TRUE;
                        END ELSE
                            Result := LeftResult / RightResult;
                    '+':
                        Result := LeftResult + RightResult;
                    '-':
                        Result := LeftResult - RightResult;
                END;
            END ELSE
                if (Expression[1] = '(') AND (Expression[STRLEN(Expression)] = ')') THEN
                    Result :=
                      EvaluateExpressionxFecha(
                        IsAccSchedLineExpression,
                        COPYSTR(Expression, 2, STRLEN(Expression) - 2),
                        LiqAccSchedLine,
                        LiqAccSchedColumn, FechaD, FechaH)
                ELSE BEGIN
                    IsFilter :=
                       (STRPOS(Expression, '..') +
                        STRPOS(Expression, '|') +
                        STRPOS(Expression, '<') +
                        STRPOS(Expression, '>') +
                        STRPOS(Expression, '&') +
                        STRPOS(Expression, '=') > 0);
                    if (STRLEN(Expression) > 10) AND (NOT IsFilter) THEN
                        EVALUATE(Result, Expression)
                    ELSE
                        if IsAccSchedLineExpression THEN BEGIN
                            LiqAccSchedLine.SETRANGE("Schedule Name", LiqAccSchedLine."Schedule Name");
                            LiqAccSchedLine.SETFILTER("Row No.", Expression);
                            LigAccSchedLineID := LiqAccSchedLine."Line No.";
                            if LiqAccSchedLine.FIND('-') THEN
                                REPEAT
                                    if LiqAccSchedLine."Line No." <> LigAccSchedLineID THEN
                                        Result := Result + CalcCellValuexDate(LiqAccSchedLine, LiqAccSchedColumn, FechaD, FechaH);
                                UNTIL LiqAccSchedLine.NEXT = 0
                            ELSE
                                if IsFilter OR (NOT EVALUATE(Result, Expression)) THEN
                                    ShowError(Text1140012,
                                              LiqAccSchedLine, LiqAccSchedColumn);
                        END ELSE BEGIN
                            LiqAccSchedColumn.SETRANGE("Column Layout Name", LiqAccSchedColumn."Column Layout Name");
                            LiqAccSchedColumn.SETFILTER("Column No.", Expression);
                            LigAccSchedLineID := LiqAccSchedColumn."Line No.";
                            if LiqAccSchedColumn.FIND('-') THEN
                                REPEAT
                                    if LiqAccSchedColumn."Line No." <> LigAccSchedLineID THEN
                                        Result := Result + CalcCellValuexDate(LiqAccSchedLine, LiqAccSchedColumn, FechaD, FechaH);
                                UNTIL LiqAccSchedColumn.NEXT = 0
                            ELSE
                                if IsFilter OR (NOT EVALUATE(Result, Expression)) THEN
                                    ShowError(Text1140013,
                                              LiqAccSchedLine, LiqAccSchedColumn);
                        END;
                END;
        END;
        CallLevel := CallLevel - 1;
        EXIT(Result);
    END;

    PROCEDURE SetLiqAccRowFilter(VAR LiqAcc: Record "Cash Flow Account"; VAR LiqAccSchedLine2: Record "Acc. Schedule Line");
    VAR
        FromDate: Date;
        ToDate: Date;
        FiscalStartDate2: Date;
    BEGIN
        WITH LiqAccSchedLine2 DO BEGIN
            COPYFILTER("Cash Flow Forecast Filter", LiqAcc."Cash Flow Forecast Filter");

            if LiqAccSchedLine2.Banco <> '' THEN
                LiqAcc.SETRANGE(LiqAcc."Filtro banco.", LiqAccSchedLine2.Banco);
            if LiqAccSchedLine2."Payment Method Code" <> '' THEN
                LiqAcc.SETRANGE(LiqAcc."Filtro Payment Method Code.", LiqAccSchedLine2."Payment Method Code");

            CASE "Totaling Type" OF
                "Totaling Type"::"Posting Accounts":
                    BEGIN
                        LiqAcc.SETFILTER("No.", Totaling);
                        LiqAcc.SETRANGE("Account Type", LiqAcc."Account Type"::Entry);
                    END;
                "Totaling Type"::"Total Accounts":
                    BEGIN
                        LiqAcc.SETFILTER("No.", Totaling);
                        LiqAcc.SETFILTER("Account Type", '<>%1', LiqAcc."Account Type"::Entry);
                    END;
            END;
        END;
    END;

    PROCEDURE SetLiqAccColumnFilter(VAR LiqAcc: Record "Cash Flow Account"
    ; LiqAccSchedLine2: Record "Acc. Schedule Line"; VAR LiqAccountScheduleColumn2: Record "Column Layout");
    VAR
        FromDate: Date;
        ToDate: Date;
        FiscalStartDate2: Date;
        Text1140004: Label 'MA';
        Text1140005: Label 'M';
        Text1140006: Label 'T';
        Text1140007: Label 'A';
        Text1140008: Label '-1D';
        Text1140009: Label '+1D';
        Text1140010: Label '+1A-1D';

    BEGIN
        WITH LiqAccountScheduleColumn2 DO BEGIN
            if (FORMAT("Comparison Date Formula") <> '0') AND (FORMAT("Comparison Date Formula") <> '') THEN BEGIN
                FromDate := CALCDATE("Comparison Date Formula", StartDate);
                if (EndDate = CALCDATE(Text1140004, EndDate)) AND
                   ((STRPOS(FORMAT("Comparison Date Formula"), Text1140005) > 0) OR
                    (STRPOS(FORMAT("Comparison Date Formula"), Text1140006) > 0) OR
                    (STRPOS(FORMAT("Comparison Date Formula"), Text1140007) > 0))
                THEN
                    ToDate := CALCDATE(Text1140004, CALCDATE("Comparison Date Formula", EndDate))
                ELSE
                    ToDate := CALCDATE("Comparison Date Formula", EndDate);
                FiscalStartDate2 := FindFiscalYear(ToDate);
            END ELSE
                if "Comparison Period Formula" <> '' THEN BEGIN
                    AccPeriodStartEnd("Comparison Period Formula", StartDate, FromDate, ToDate);
                    FiscalStartDate2 := FindFiscalYear(ToDate);
                END ELSE BEGIN
                    FromDate := StartDate;
                    ToDate := EndDate;
                    FiscalStartDate2 := FiscalStartDate;
                END;
            LiqAcc.SETRANGE("Filtro banco.");
            LiqAcc.SETRANGE("Filtro Payment Method Code.");
            if LiqAccountScheduleColumn2.Banco <> '' THEN
                LiqAcc.SETRANGE("Filtro banco.", LiqAccountScheduleColumn2.Banco);
            if LiqAccountScheduleColumn2."Payment Method Code" <> '' THEN
                LiqAcc.SETRANGE("Filtro Payment Method Code.", LiqAccountScheduleColumn2."Payment Method Code");

            CASE "Column Type" OF
                "Column Type"::"Net Change":
                    CASE LiqAccSchedLine2."Row Type" OF
                        LiqAccSchedLine2."Row Type"::"Net Change":
                            LiqAcc.SETRANGE("Date Filter", FromDate, ToDate);
                        LiqAccSchedLine2."Row Type"::"Beginning Balance":
                            LiqAcc.SETFILTER("Date Filter", '<%1', FromDate);
                        LiqAccSchedLine2."Row Type"::"Balance at Date":
                            LiqAcc.SETRANGE("Date Filter", 0D, ToDate);
                    END;
                "Column Type"::"Balance at Date":
                    if LiqAccSchedLine2."Row Type" = LiqAccSchedLine2."Row Type"::"Beginning Balance" THEN
                        LiqAcc.SETRANGE("Date Filter", 0D)   // Force a zero return
                    ELSE
                        LiqAcc.SETRANGE("Date Filter", 0D, ToDate);
                "Column Type"::"Beginning Balance":
                    if LiqAccSchedLine2."Row Type" = LiqAccSchedLine2."Row Type"::"Balance at Date" THEN
                        LiqAcc.SETRANGE("Date Filter", 0D)   // Force a zero return
                    ELSE
                        LiqAcc.SETRANGE(
                          "Date Filter", 0D, CALCDATE('<-1D>', FromDate));
                "Column Type"::"Year to Date":
                    CASE LiqAccSchedLine2."Row Type" OF
                        LiqAccSchedLine2."Row Type"::"Net Change":
                            LiqAcc.SETRANGE("Date Filter", FiscalStartDate2, ToDate);
                        LiqAccSchedLine2."Row Type"::"Beginning Balance":
                            LiqAcc.SETFILTER("Date Filter", '<%1', FiscalStartDate2);
                        LiqAccSchedLine2."Row Type"::"Balance at Date":
                            LiqAcc.SETRANGE("Date Filter", 0D, ToDate);
                    END;
                "Column Type"::"Rest of Fiscal Year":
                    CASE LiqAccSchedLine2."Row Type" OF
                        LiqAccSchedLine2."Row Type"::"Net Change":
                            LiqAcc.SETRANGE(
                              "Date Filter",
                              CALCDATE('<+1D>', ToDate), FindEndOfFiscalYear(FiscalStartDate2));
                        LiqAccSchedLine2."Row Type"::"Beginning Balance":
                            LiqAcc.SETRANGE("Date Filter", 0D, ToDate);
                        LiqAccSchedLine2."Row Type"::"Balance at Date":
                            LiqAcc.SETRANGE("Date Filter", 0D, FindEndOfFiscalYear(ToDate));
                    END;
                "Column Type"::"Entire Fiscal Year":
                    CASE LiqAccSchedLine2."Row Type" OF
                        LiqAccSchedLine2."Row Type"::"Net Change":
                            LiqAcc.SETRANGE(
                              "Date Filter",
                              FiscalStartDate2, FindEndOfFiscalYear(FiscalStartDate2));
                        LiqAccSchedLine2."Row Type"::"Beginning Balance":
                            LiqAcc.SETFILTER("Date Filter", '<%1', FiscalStartDate2);
                        LiqAccSchedLine2."Row Type"::"Balance at Date":
                            LiqAcc.SETRANGE("Date Filter", 0D, FindEndOfFiscalYear(ToDate));
                    END;
            END;
        END;
    END;



    PROCEDURE CalcLiqAccountxDate(VAR LiqAcc: Record "Cash Flow Account"; VAR LiqAccountScheduleLine: Record "Acc. Schedule Line";
    VAR LiqAccountScheduleColumn2: Record "Column Layout"; FechaD: Date; FechaH: Date) ColValue: Decimal;
    VAR
        LiquidityLedgerEntry: Record "Cash Flow Forecast Entry";
        LiquidityAnalysisViewEntry: Record "Analysis View Entry";
        FromDate: Date;
        ToDate: Date;
        FiscalStartDate2: Date;
        AmountType: Option "Net Amount","Debit Amount","Credit Amount";
        TestBalance: Boolean;
        Balance: Decimal;
        UseBusUnitFilter: Boolean;
        UseDimFilter: Boolean;
        LiqAccSchedName: Record "Acc. Schedule Name";
    BEGIN
        ColValue := 0;
        //if LiqAccSchedName.Name <> LiqAccountScheduleLine."Schedule Name" THEN
        if LiqAccountScheduleColumn2.Empresa <> '' then
            if not Contrl.Permiso_Empresas(LiqAccountScheduleColumn2.Empresa) then exit(0);
        LiqAccSchedName.GET(LiqAccountScheduleLine."Schedule Name");
        AmountType := LiqAccountScheduleColumn2."Amount Type".AsInteger();
        CASE LiqAccountScheduleLine."Amount Type" OF
            LiqAccountScheduleLine."Amount Type"::"Debit Amount":
                CASE AmountType OF
                    AmountType::"Net Amount":
                        AmountType := AmountType::"Debit Amount";
                    AmountType::"Credit Amount":
                        EXIT(0);
                END;
            LiqAccountScheduleLine."Amount Type"::"Credit Amount":
                CASE AmountType OF
                    AmountType::"Net Amount":
                        AmountType := AmountType::"Credit Amount";
                    AmountType::"Debit Amount":
                        EXIT(0);
                END;
        END;
        TestBalance :=
          LiqAccountScheduleLine.Show IN [LiqAccountScheduleLine.Show::"When Positive Balance",
                                          LiqAccountScheduleLine.Show::"When Negative Balance"];
        if LiqAccountScheduleColumn2."Column Type" <> LiqAccountScheduleColumn2."Column Type"::Formula THEN BEGIN
            UseDimFilter :=
              (LiqAccountScheduleLine."Dimension 1 Totaling" <> '') OR
              (LiqAccountScheduleLine."Dimension 2 Totaling" <> '') OR
              (LiqAccountScheduleLine."Dimension 3 Totaling" <> '') OR
              (LiqAccountScheduleLine."Dimension 4 Totaling" <> '') OR
              (LiqAccountScheduleLine.GETFILTER("Dimension 1 Filter") <> '') OR
              (LiqAccountScheduleLine.GETFILTER("Dimension 2 Filter") <> '') OR
              (LiqAccountScheduleLine.GETFILTER("Dimension 3 Filter") <> '') OR
              (LiqAccountScheduleLine.GETFILTER("Dimension 4 Filter") <> '') OR
              (LiqAccountScheduleColumn2."Dimension 1 Totaling" <> '') OR
              (LiqAccountScheduleColumn2."Dimension 2 Totaling" <> '') OR
              (LiqAccountScheduleColumn2."Dimension 3 Totaling" <> '') OR
              (LiqAccountScheduleColumn2."Dimension 4 Totaling" <> '');
            CASE LiqAccountScheduleColumn2."Ledger Entry Type" OF
                LiqAccountScheduleColumn2."Ledger Entry Type"::"Entries":
                    BEGIN
                        if LiqAccSchedName."Analysis View Name" = '' THEN
                            WITH LiquidityLedgerEntry DO BEGIN
                                SETCURRENTKEY(
                                   "Cash Flow Account No.", "Cash Flow Forecast No.", "Global Dimension 1 Code", "Global Dimension 2 Code", "Cash Flow Date");
                                if LiqAcc.Totaling = '' THEN
                                    SETRANGE("Cash Flow Account No.", LiqAcc."No.")
                                ELSE
                                    SETFILTER("Cash Flow Account No.", LiqAcc.Totaling);
                                LiqAcc.COPYFILTER("Date Filter", "Cash Flow Date");
                                LiquidityLedgerEntry.SETRANGE("Cash Flow Date", FechaD, FechaH);
                                LiqAccountScheduleLine.COPYFILTER("Cash Flow Forecast Filter", "Cash Flow Forecast No.");
                                LiqAccountScheduleLine.COPYFILTER("Dimension 1 Filter", "Global Dimension 1 Code");
                                LiqAccountScheduleLine.COPYFILTER("Dimension 2 Filter", "Global Dimension 2 Code");
                                FILTERGROUP(2);
                                SETFILTER("Global Dimension 1 Code", LiqAccountScheduleLine."Dimension 1 Totaling");
                                SETFILTER("Global Dimension 2 Code", LiqAccountScheduleLine."Dimension 2 Totaling");
                                FILTERGROUP(6);
                                SETFILTER("Global Dimension 1 Code", GetDimTotalingFilter(1, LiqAccountScheduleColumn2."Dimension 1 Totaling"));
                                SETFILTER("Global Dimension 2 Code", GetDimTotalingFilter(2, LiqAccountScheduleColumn2."Dimension 2 Totaling"));
                                FILTERGROUP(0);
                                SETRANGE("Cod banco");
                                SETRANGE("Payment Method Code");
                                if LiqAccountScheduleColumn2.Banco <> '' THEN
                                    SETRANGE("Cod banco", LiqAccountScheduleColumn2.Banco);
                                if LiqAccountScheduleLine.Banco <> '' THEN
                                    SETRANGE("Cod banco", LiqAccountScheduleLine.Banco);
                                if LiqAccountScheduleColumn2."Payment Method Code" <> '' THEN
                                    SETRANGE("Payment Method Code", LiqAccountScheduleColumn2."Payment Method Code");
                                if LiqAccountScheduleLine."Payment Method Code" <> '' THEN
                                    SETRANGE("Payment Method Code", LiqAccountScheduleLine."Payment Method Code");

                                CASE LiqAccountScheduleColumn2."Amount Type" OF
                                    LiqAccountScheduleColumn2."Amount Type"::"Net Amount":
                                        BEGIN
                                            if LiqAccountScheduleColumn2.Empresa <> '' THEN
                                                CHANGECOMPANY(LiqAccountScheduleColumn2.Empresa);
                                            CALCSUMS("Amount (LCY)");
                                            ColValue := "Amount (LCY)";
                                        END;
                                    LiqAccountScheduleColumn2."Amount Type"::"Debit Amount":
                                        BEGIN

                                            if LiqAccountScheduleColumn2.Empresa <> '' THEN
                                                CHANGECOMPANY(LiqAccountScheduleColumn2.Empresa);

                                            ColValue := 0;
                                            if FINDFIRST THEN
                                                REPEAT
                                                    if "Amount (LCY)" > 0 THEN
                                                        ColValue := ColValue + "Amount (LCY)";
                                                UNTIL NEXT = 0;
                                        END;
                                    LiqAccountScheduleColumn2."Amount Type"::"Credit Amount":
                                        BEGIN

                                            if LiqAccountScheduleColumn2.Empresa <> '' THEN
                                                CHANGECOMPANY(LiqAccountScheduleColumn2.Empresa);

                                            ColValue := 0;
                                            if FINDFIRST THEN
                                                REPEAT
                                                    if "Amount (LCY)" < 0 THEN
                                                        ColValue := ColValue + "Amount (LCY)";
                                                UNTIL NEXT = 0;
                                        END;

                                END;
                            END
                        ELSE
                            WITH LiquidityAnalysisViewEntry DO BEGIN
                                SETRANGE("Analysis View Code", LiqAccSchedName."Analysis View Name");
                                if LiqAcc.Totaling = '' THEN
                                    SETRANGE("Account No.", LiqAcc."No.")
                                ELSE
                                    SETFILTER("Account No.", LiqAcc.Totaling);
                                LiquidityAnalysisViewEntry.SETRANGE("Posting Date", FechaD, FechaH);
                                LiqAccountScheduleLine.COPYFILTER("Cash flow Forecast Filter", "Cash Flow Forecast No.");
                                LiqAccountScheduleLine.COPYFILTER("Dimension 1 Filter", "Dimension 1 Value Code");
                                LiqAccountScheduleLine.COPYFILTER("Dimension 2 Filter", "Dimension 2 Value Code");
                                LiqAccountScheduleLine.COPYFILTER("Dimension 3 Filter", "Dimension 3 Value Code");
                                LiqAccountScheduleLine.COPYFILTER("Dimension 4 Filter", "Dimension 4 Value Code");
                                FILTERGROUP(2);
                                SETFILTER("Dimension 1 Value Code", GetDimTotalingFilter(1, LiqAccountScheduleLine."Dimension 1 Totaling"));
                                SETFILTER("Dimension 2 Value Code", GetDimTotalingFilter(2, LiqAccountScheduleLine."Dimension 2 Totaling"));
                                SETFILTER("Dimension 3 Value Code", GetDimTotalingFilter(3, LiqAccountScheduleLine."Dimension 3 Totaling"));
                                SETFILTER("Dimension 4 Value Code", GetDimTotalingFilter(4, LiqAccountScheduleLine."Dimension 4 Totaling"));
                                FILTERGROUP(6);
                                SETFILTER("Dimension 1 Value Code", GetDimTotalingFilter(1, LiqAccountScheduleColumn2."Dimension 1 Totaling"));
                                SETFILTER("Dimension 2 Value Code", GetDimTotalingFilter(2, LiqAccountScheduleColumn2."Dimension 2 Totaling"));
                                SETFILTER("Dimension 3 Value Code", GetDimTotalingFilter(3, LiqAccountScheduleColumn2."Dimension 3 Totaling"));
                                SETFILTER("Dimension 4 Value Code", GetDimTotalingFilter(4, LiqAccountScheduleColumn2."Dimension 4 Totaling"));
                                FILTERGROUP(0);

                                CASE LiqAccountScheduleColumn2."Amount Type" OF
                                    LiqAccountScheduleColumn2."Amount Type"::"Net Amount":
                                        BEGIN
                                            CALCSUMS(Amount);
                                            ColValue := Amount;
                                        END;
                                END;
                            END;
                    END;
            END;
            if TestBalance THEN BEGIN
                if LiqAccountScheduleLine.Show = LiqAccountScheduleLine.Show::"When Positive Balance" THEN
                    if Balance < 0 THEN
                        EXIT(0);
                if LiqAccountScheduleLine.Show = LiqAccountScheduleLine.Show::"When Negative Balance" THEN
                    if Balance > 0 THEN
                        EXIT(0);
            END;
        END;
        EXIT(ColValue);
    END;

    PROCEDURE ExisteFecha(Fecha: Date; VAR LiqAccSchedLine: Record "Acc. Schedule Line"; Ok: Boolean): Boolean;
    VAR
        rLig: Record "Cash Flow Forecast Entry";
        rEmp: Record Company;
        Control: Codeunit ControlProcesos;
    BEGIN
        if Ok then exit(True);
        if LiqAccSchedLine.Totaling = '' THEN EXIT(TRUE);
        rEmp.SetRange("Evaluation Company", false);
        if rEmp.FINDFIRST THEN
            REPEAT
                if Control.Permiso_Empresas(rEmp.Name) then begin
                    rLig.CHANGECOMPANY(rEmp.Name);
                    rLig.SetCurrentKey("Cash Flow Account No.", "Cash Flow Date", "Cash Flow Forecast No.");
                    rLig.SETFILTER(rLig."Cash Flow Account No.", LiqAccSchedLine.Totaling);
                    rLig.SETRANGE(rLig."Cash Flow Date", Fecha);
                    if rLig.FINDFIRST THEN EXIT(TRUE);
                end;
            UNTIL rEmp.NEXT = 0;
        EXIT(FALSE);
    END;

    PROCEDURE CalcCell(VAR AccSchedLine: Record 85; VAR ColumnLayout: Record 334; CalcAddCurr: Boolean): Decimal;
    VAR
        Result: Decimal;
    BEGIN
        AccountScheduleLine.COPYFILTERS(AccSchedLine);
        StartDate := AccountScheduleLine.GETRANGEMIN("Date Filter");
        if EndDate <> AccountScheduleLine.GETRANGEMAX("Date Filter") THEN BEGIN
            EndDate := AccountScheduleLine.GETRANGEMAX("Date Filter");
            FiscalStartDate := FindFiscalYear(EndDate);
        END;
        DivisionError := FALSE;
        PeriodError := FALSE;
        CallLevel := 0;
        CallingAccSchedLineID := AccSchedLine."Line No.";
        CallingColumnLayoutID := ColumnLayout."Line No.";

        if (OldAccSchedLineFilters <> AccSchedLine.GETFILTERS) OR
           (OldColumnLayoutFilters <> ColumnLayout.GETFILTERS) OR
           (OldAccSchedLineName <> AccSchedLine."Schedule Name") OR
           (OldColumnLayoutName <> ColumnLayout."Column Layout Name") OR
           (OldCalcAddCurr <> CalcAddCurr)
        THEN BEGIN
            AccSchedCellValue.RESET;
            AccSchedCellValue.DELETEALL;
            CLEAR(BasePercentLine);
            OldAccSchedLineFilters := AccSchedLine.GETFILTERS;
            OldColumnLayoutFilters := ColumnLayout.GETFILTERS;
            OldAccSchedLineName := AccSchedLine."Schedule Name";
            OldColumnLayoutName := ColumnLayout."Column Layout Name";
            OldCalcAddCurr := CalcAddCurr;
        END;

        Result := CalcCellValue(AccSchedLine, ColumnLayout, CalcAddCurr);
        WITH ColumnLayout DO BEGIN
            CASE Show OF
                Show::"When Positive":
                    if Result < 0 THEN
                        Result := 0;
                Show::"When Negative":
                    if Result > 0 THEN
                        Result := 0;
            END;
            if "Show Opposite Sign" THEN
                Result := -Result;
        END;
        if AccSchedLine."Show Opposite Sign" THEN
            Result := -Result;
        EXIT(Result);
    END;

    local PROCEDURE CalcCellValue(AccSchedLine: Record 85; ColumnLayout: Record 334; CalcAddCurr: Boolean): Decimal;
    VAR
        Result: Decimal;
        GLAcc: Record 15;
        CostType: Record "Cost Type";
        //HistoricGLAcc: Record 10721;
        AccSchedName: Record 84;
        VeAcc: Record Vendor;
        CuAcc: Record Customer;
    BEGIN
        Result := 0;
        if ColumnLayout.Empresa <> '' then
            if not Contrl.Permiso_Empresas(ColumnLayout.Empresa) then exit(0);
        if AccSchedLine.Totaling <> '' THEN
            if AccSchedCellValue.GET(AccSchedLine."Line No.", ColumnLayout."Line No.") THEN BEGIN
                Result := AccSchedCellValue.Value;
                DivisionError := DivisionError;// OR AccSchedCellValue.Error;
                PeriodError := PeriodError OR AccSchedCellValue."Period Error";
            END ELSE BEGIN
                if ColumnLayout."Column Type" = ColumnLayout."Column Type"::Formula THEN
                    Result :=
                      EvaluateExpression(
                        FALSE, ColumnLayout.Formula, AccSchedLine, ColumnLayout, CalcAddCurr)
                ELSE
                    if AccSchedLine."Totaling Type" IN
                      [AccSchedLine."Totaling Type"::Formula, AccSchedLine."Totaling Type"::"Set Base For Percent"]
                    THEN
                        Result :=
                          EvaluateExpression(
                            TRUE, AccSchedLine.Totaling, AccSchedLine, ColumnLayout, CalcAddCurr)
                    ELSE
                        if (StartDate = 0D) OR (EndDate = 0D) OR (EndDate = 99991231D) THEN BEGIN
                            Result := 0;
                            PeriodError := TRUE;
                        END ELSE BEGIN
                            if AccSchedLine."Totaling Type" IN
                               [AccSchedLine."Totaling Type"::"Posting Accounts", AccSchedLine."Totaling Type"::"Total Accounts"]
                            THEN BEGIN
                                AccSchedLine.COPYFILTERS(AccountScheduleLine);
                                if AccSchedName.GET(AccSchedLine."Schedule Name") THEN
                                    if True then BEGIN
                                        SetGLAccRowFilters(GLAcc, AccSchedLine);
                                        SetGLAccColumnFilters(GLAcc, AccSchedLine, ColumnLayout);
                                        if (AccSchedLine."Totaling Type" = AccSchedLine."Totaling Type"::"Posting Accounts") AND
                                           (STRLEN(AccSchedLine.Totaling) <= MAXSTRLEN(GLAcc.Totaling)) AND (STRPOS(AccSchedLine.Totaling, '*') = 0)
                                        THEN BEGIN
                                            GLAcc."Account Type" := GLAcc."Account Type"::Heading;
                                            GLAcc.Totaling := AccSchedLine.Totaling;
                                            Result := Result + CalcGLAcc(GLAcc, AccSchedLine, ColumnLayout, CalcAddCurr);
                                        END ELSE
                                            if GLAcc.FIND('-') THEN
                                                REPEAT
                                                    Result := Result + CalcGLAcc(GLAcc, AccSchedLine, ColumnLayout, CalcAddCurr);
                                                UNTIL GLAcc.NEXT = 0;
                                    END;
                            END;
                            //Asc Customer & Vendors
                            if AccSchedLine."Totaling Type" IN
                               [AccSchedLine."Totaling Type"::Vendor, AccSchedLine."Totaling Type"::Customer]
                            THEN BEGIN
                                AccSchedLine.COPYFILTERS(AccountScheduleLine);
                                if AccSchedName.GET(AccSchedLine."Schedule Name") THEN
                                    if AccSchedLine."Totaling Type" = AccSchedLine."Totaling Type"::Vendor THEN BEGIN
                                        SetVeAccRowFilters(VeAcc, AccSchedLine);
                                        SetVeAccColumnFilters(VeAcc, AccSchedLine, ColumnLayout);
                                        if ColumnLayout.Empresa <> '' THEN
                                            VeAcc.CHANGECOMPANY(ColumnLayout.Empresa);
                                        if AccSchedLine.Company <> '' THEN
                                            VeAcc.CHANGECOMPANY(AccSchedLine.Company);
                                        if (ColumnLayout.Empresa <> '') AND
                                         (AccSchedLine.Company <> '') AND
                                         (AccSchedLine.Company <> ColumnLayout.Empresa) THEN
                                            Result := Result + 0
                                        ELSE BEGIN

                                            if VeAcc.FIND('-') THEN
                                                REPEAT
                                                    if AccSchedLine."Grupo Contable" = VeAcc."Vendor Posting Group" THEN
                                                        Result := Result + CalcVeAcc(VeAcc, AccSchedLine, ColumnLayout, CalcAddCurr);
                                                UNTIL VeAcc.NEXT = 0;
                                        END;
                                    END ELSE BEGIN
                                        SetCuAccRowFilters(CuAcc, AccSchedLine);
                                        SetCuAccColumnFilters(CuAcc, AccSchedLine, ColumnLayout);
                                        if ColumnLayout.Empresa <> '' THEN
                                            CuAcc.CHANGECOMPANY(ColumnLayout.Empresa);
                                        if AccSchedLine.Company <> '' THEN
                                            CuAcc.CHANGECOMPANY(AccSchedLine.Company);
                                        if (ColumnLayout.Empresa <> '') AND
                                         (AccSchedLine.Company <> '') AND
                                         (AccSchedLine.Company <> ColumnLayout.Empresa) THEN
                                            Result := Result + 0
                                        ELSE BEGIN

                                            if CuAcc.FIND('-') THEN
                                                REPEAT
                                                    if AccSchedLine."Grupo Contable" = CuAcc."Customer Posting Group" THEN
                                                        Result := Result + CalcCuAcc(CuAcc, AccSchedLine, ColumnLayout, CalcAddCurr);
                                                UNTIL CuAcc.NEXT = 0;
                                        END;
                                    END;
                            END;

                            // Fin Asc
                            if AccSchedLine."Totaling Type" IN
                               [AccSchedLine."Totaling Type"::"Cost Type", AccSchedLine."Totaling Type"::"Cost Type Total"]
                            THEN BEGIN
                                AccSchedLine.COPYFILTERS(AccountScheduleLine);
                                SetCostTypeRowFilters(CostType, AccSchedLine, ColumnLayout);
                                SetCostTypeColumnFilters(CostType, AccSchedLine, ColumnLayout);

                                if (AccSchedLine."Totaling Type" = AccSchedLine."Totaling Type"::"Cost Type") AND
                                  (STRLEN(AccSchedLine.Totaling) <= MAXSTRLEN(GLAcc.Totaling)) AND (STRPOS(AccSchedLine.Totaling, '*') = 0)
                                THEN BEGIN
                                    CostType."Type" := CostType."Type"::Total;
                                    CostType.Totaling := AccSchedLine.Totaling;
                                    Result := Result + CalcCostType(CostType, AccSchedLine, ColumnLayout, CalcAddCurr);
                                END ELSE BEGIN
                                    if CostType.FIND('-') THEN
                                        REPEAT
                                            Result := Result + CalcCostType(CostType, AccSchedLine, ColumnLayout, CalcAddCurr);
                                        UNTIL CostType.NEXT = 0;
                                END;
                            END;
                        END;

                AccSchedCellValue."Row No." := AccSchedLine."Line No.";
                AccSchedCellValue."Column No." := ColumnLayout."Line No.";
                AccSchedCellValue.Value := Result;
                AccSchedCellValue."Has Error" := DivisionError;
                AccSchedCellValue."Period Error" := PeriodError;
                AccSchedCellValue.INSERT;
            END;
        if (AccSchedLine."Reverse Sign") AND
        (ColumnLayout."Column Type" <> ColumnLayout."Column Type"::Formula) THEN
            Result := -Result;
        if AccSchedLine."Positive Only" AND (Result < 0) THEN
            Result := 0;

        EXIT(Result);
    END;

    LOCAL PROCEDURE CalcGLAcc(VAR GLAcc: Record 15; VAR AccSchedLine: Record 85; VAR ColumnLayout: Record 334; CalcAddCurr: Boolean) ColValue: Decimal;
    VAR
        GLEntry: Record "G/L Entry";
        GLBudgEntry: Record 96;
        AnalysisViewEntry: Record "Analysis View Entry";
        AnalysisViewBudgetEntry: Record "Analysis View Budget Entry";
        AmountType: Option "Net Amount","Debit Amount","Credit Amount";
        TestBalance: Boolean;
        Balance: Decimal;
        UseBusUnitFilter: Boolean;
        UseDimFilter: Boolean;
    BEGIN
        //ASC 09/12/09
        if ColumnLayout.Empresa <> '' then
            if not Contrl.Permiso_Empresas(ColumnLayout.Empresa) then exit(0);
        if AccSchedLine.Company <> '' THEN
            if not Contrl.Permiso_Empresas(AccSchedLine.Company) then exit(0);
        if ColumnLayout.Empresa <> '' THEN BEGIN
            GLEntry.CHANGECOMPANY(ColumnLayout.Empresa);
            GLBudgEntry.CHANGECOMPANY(ColumnLayout.Empresa);
        END;
        if AccSchedLine.Company <> '' THEN BEGIN
            GLEntry.CHANGECOMPANY(AccSchedLine.Company);
            GLBudgEntry.CHANGECOMPANY(AccSchedLine.Company);
        END;
        if (ColumnLayout.Empresa <> '') AND
         (AccSchedLine.Company <> '') AND
         (AccSchedLine.Company <> ColumnLayout.Empresa) THEN
            EXIT(0);
        ColValue := 0;
        if AccSchedName.Name <> AccSchedLine."Schedule Name" THEN
            AccSchedName.GET(AccSchedLine."Schedule Name");
        AmountType := ColumnLayout."Amount Type".AsInteger();
        CASE AccSchedLine."Amount Type" OF
            AccSchedLine."Amount Type"::"Debit Amount":
                CASE AmountType OF
                    AmountType::"Net Amount":
                        AmountType := AmountType::"Debit Amount";
                    AmountType::"Credit Amount":
                        EXIT(0);
                END;
            AccSchedLine."Amount Type"::"Credit Amount":
                CASE AmountType OF
                    AmountType::"Net Amount":
                        AmountType := AmountType::"Credit Amount";
                    AmountType::"Debit Amount":
                        EXIT(0);
                END;
        END;
        TestBalance :=
          AccSchedLine.Show IN [AccSchedLine.Show::"When Positive Balance", AccSchedLine.Show::"When Negative Balance"];
        if ColumnLayout."Column Type" <> ColumnLayout."Column Type"::Formula THEN BEGIN
            UseBusUnitFilter := (AccSchedLine.GETFILTER("Business Unit Filter") <> '') OR (ColumnLayout."Business Unit Totaling" <> '');
            UseDimFilter :=
              (AccSchedLine."Dimension 1 Totaling" <> '') OR
              (AccSchedLine."Dimension 2 Totaling" <> '') OR
              (AccSchedLine."Dimension 3 Totaling" <> '') OR
              (AccSchedLine."Dimension 4 Totaling" <> '') OR
              (AccSchedLine."Dimension 5 Totaling" <> '') OR
              (AccSchedLine.GETFILTER("Dimension 1 Filter") <> '') OR
              (AccSchedLine.GETFILTER("Dimension 2 Filter") <> '') OR
              (AccSchedLine.GETFILTER("Dimension 3 Filter") <> '') OR
              (AccSchedLine.GETFILTER("Dimension 4 Filter") <> '') OR
              (AccSchedLine.GETFILTER("Dimension 5 Filter") <> '') OR
              (ColumnLayout."Dimension 1 Totaling" <> '') OR
              (ColumnLayout."Dimension 2 Totaling" <> '') OR
              (ColumnLayout."Dimension 3 Totaling" <> '') OR
              (ColumnLayout."Dimension 4 Totaling" <> '') OR
              (ColumnLayout."Dimension 5 Totaling" <> '');
            CASE ColumnLayout."Ledger Entry Type" OF
                ColumnLayout."Ledger Entry Type"::"Entries":
                    BEGIN
                        if AccSchedName."Analysis View Name" = '' THEN
                            WITH GLEntry DO BEGIN
                                if UseBusUnitFilter THEN
                                    if UseDimFilter THEN
                                        SETCURRENTKEY(
                                          "G/L Account No.", "Business Unit Code", "Global Dimension 1 Code", "Global Dimension 2 Code")
                                    ELSE
                                        SETCURRENTKEY(
                                          "G/L Account No.", "Business Unit Code", "Posting Date")
                                ELSE
                                    if UseDimFilter THEN
                                        SETCURRENTKEY("G/L Account No.", "Global Dimension 1 Code", "Global Dimension 2 Code")
                                    ELSE
                                        SETCURRENTKEY("G/L Account No.", "Posting Date");
                                if GLAcc.Totaling = '' THEN
                                    SETRANGE("G/L Account No.", GLAcc."No.")
                                ELSE
                                    SETFILTER("G/L Account No.", GLAcc.Totaling);
                                GLAcc.COPYFILTER("Date Filter", "Posting Date");
                                GLAcc.COPYFILTER("Filtro Eliminaciones", Eliminaciones);
                                AccSchedLine.COPYFILTER("Business Unit Filter", "Business Unit Code");
                                AccSchedLine.COPYFILTER("Dimension 1 Filter", "Global Dimension 1 Code");
                                AccSchedLine.COPYFILTER("Dimension 2 Filter", "Global Dimension 2 Code");
                                AccSchedLine.COPYFILTER("Dimension 3 Filter", "Global Dimension 3 Code");
                                AccSchedLine.COPYFILTER("Dimension 4 Filter", "Global Dimension 4 Code");
                                AccSchedLine.COPYFILTER("Dimension 5 Filter", "Global Dimension 5 Code");
                                AccSchedLine.COPYFILTER("Salesperson Filter", "SalesPerson Code");
                                FILTERGROUP(2);
                                SETFILTER("Global Dimension 1 Code", GetDimTotalingFilter(1, AccSchedLine."Dimension 1 Totaling"));
                                SETFILTER("Global Dimension 2 Code", GetDimTotalingFilter(2, AccSchedLine."Dimension 2 Totaling"));
                                SETFILTER("Global Dimension 3 Code", GetDimTotalingFilter(3, AccSchedLine."Dimension 3 Totaling"));
                                SETFILTER("Global Dimension 4 Code", GetDimTotalingFilter(4, AccSchedLine."Dimension 4 Totaling"));
                                SETFILTER("Global Dimension 5 Code", GetDimTotalingFilter(5, AccSchedLine."Dimension 5 Totaling"));
                                SETFILTER("SalesPerson Code", AccSchedLine."Salesperson Code");
                                FILTERGROUP(6);
                                SETFILTER("Global Dimension 1 Code", GetDimTotalingFilter(1, ColumnLayout."Dimension 1 Totaling"));
                                SETFILTER("Global Dimension 2 Code", GetDimTotalingFilter(2, ColumnLayout."Dimension 2 Totaling"));
                                SETFILTER("Global Dimension 3 Code", GetDimTotalingFilter(3, ColumnLayout."Dimension 3 Totaling"));
                                SETFILTER("Global Dimension 4 Code", GetDimTotalingFilter(4, ColumnLayout."Dimension 4 Totaling"));
                                SETFILTER("Global Dimension 5 Code", GetDimTotalingFilter(5, ColumnLayout."Dimension 5 Totaling"));
                                if ColumnLayout.GETFILTER(ColumnLayout."Salesperson Filter") <> '' THEN
                                    SETFILTER("SalesPerson Code", ColumnLayout."Salesperson Filter");
                                SETFILTER("Business Unit Code", ColumnLayout."Business Unit Totaling");
                                FILTERGROUP(0);
                                CASE AmountType OF
                                    AmountType::"Net Amount":
                                        BEGIN
                                            if CalcAddCurr THEN BEGIN
                                                CALCSUMS("Additional-Currency Amount");
                                                ColValue := "Additional-Currency Amount";
                                            END ELSE BEGIN
                                                CALCSUMS(Amount);
                                                ColValue := Amount;
                                            END;
                                            Balance := ColValue;
                                        END;
                                    AmountType::"Debit Amount":
                                        BEGIN
                                            if CalcAddCurr THEN BEGIN
                                                if TestBalance THEN BEGIN
                                                    CALCSUMS("Add.-Currency Debit Amount", "Additional-Currency Amount");
                                                    Balance := "Additional-Currency Amount";
                                                END ELSE
                                                    CALCSUMS("Add.-Currency Debit Amount");
                                                ColValue := "Add.-Currency Debit Amount";
                                            END ELSE BEGIN
                                                if TestBalance THEN BEGIN
                                                    CALCSUMS("Debit Amount", Amount);
                                                    Balance := Amount;
                                                END ELSE
                                                    CALCSUMS("Debit Amount");
                                                ColValue := "Debit Amount";
                                            END;
                                        END;
                                    AmountType::"Credit Amount":
                                        BEGIN
                                            if CalcAddCurr THEN BEGIN
                                                if TestBalance THEN BEGIN
                                                    CALCSUMS("Add.-Currency Credit Amount", "Additional-Currency Amount");
                                                    Balance := "Additional-Currency Amount";
                                                END ELSE
                                                    CALCSUMS("Add.-Currency Credit Amount");
                                                ColValue := "Add.-Currency Credit Amount";
                                            END ELSE BEGIN
                                                if TestBalance THEN BEGIN
                                                    CALCSUMS("Credit Amount", Amount);
                                                    Balance := Amount;
                                                END ELSE
                                                    CALCSUMS("Credit Amount");
                                                ColValue := "Credit Amount";
                                            END;
                                        END;
                                END;
                            END
                        ELSE
                            WITH AnalysisViewEntry DO BEGIN
                                if ColumnLayout.Empresa <> '' THEN
                                    CHANGECOMPANY(ColumnLayout.Empresa);
                                if AccSchedLine.Company <> '' THEN
                                    CHANGECOMPANY(AccSchedLine.Company);
                                if (ColumnLayout.Empresa <> '') AND
                                 (AccSchedLine.Company <> '') AND
                                 (AccSchedLine.Company <> ColumnLayout.Empresa) THEN
                                    EXIT(0);

                                SETRANGE("Analysis View Code", AccSchedName."Analysis View Name");
                                if GLAcc.Totaling = '' THEN
                                    SETRANGE("Account No.", GLAcc."No.")
                                ELSE
                                    SETFILTER("Account No.", GLAcc.Totaling);
                                GLAcc.COPYFILTER("Date Filter", "Posting Date");
                                //GLAcc.COPYFILTER("Filtro Eliminaciones",Eliminaciones);
                                AccSchedLine.COPYFILTER("Business Unit Filter", "Business Unit Code");
                                AccSchedLine.COPYFILTER("Dimension 1 Filter", "Dimension 1 Value Code");
                                AccSchedLine.COPYFILTER("Dimension 2 Filter", "Dimension 2 Value Code");
                                AccSchedLine.COPYFILTER("Dimension 3 Filter", "Dimension 3 Value Code");
                                AccSchedLine.COPYFILTER("Dimension 4 Filter", "Dimension 4 Value Code");
                                AccSchedLine.COPYFILTER("Dimension 5 Filter", "Dimension 5 Value Code");
                                //AccSchedLine.COPYFILTER(AccSchedLine."Salesperson Filter","SalesPerson Code");
                                FILTERGROUP(2);
                                SETFILTER("Dimension 1 Value Code", GetDimTotalingFilter(1, AccSchedLine."Dimension 1 Totaling"));
                                SETFILTER("Dimension 2 Value Code", GetDimTotalingFilter(2, AccSchedLine."Dimension 2 Totaling"));
                                SETFILTER("Dimension 3 Value Code", GetDimTotalingFilter(3, AccSchedLine."Dimension 3 Totaling"));
                                SETFILTER("Dimension 4 Value Code", GetDimTotalingFilter(4, AccSchedLine."Dimension 4 Totaling"));
                                SETFILTER("Dimension 5 Value Code", GetDimTotalingFilter(5, AccSchedLine."Dimension 5 Totaling"));
                                FILTERGROUP(6);
                                SETFILTER("Dimension 1 Value Code", GetDimTotalingFilter(1, ColumnLayout."Dimension 1 Totaling"));
                                SETFILTER("Dimension 2 Value Code", GetDimTotalingFilter(2, ColumnLayout."Dimension 2 Totaling"));
                                SETFILTER("Dimension 3 Value Code", GetDimTotalingFilter(3, ColumnLayout."Dimension 3 Totaling"));
                                SETFILTER("Dimension 4 Value Code", GetDimTotalingFilter(4, ColumnLayout."Dimension 4 Totaling"));
                                SETFILTER("Dimension 5 Value Code", GetDimTotalingFilter(5, ColumnLayout."Dimension 5 Totaling"));
                                SETFILTER("Business Unit Code", ColumnLayout."Business Unit Totaling");
                                //if ColumnLayout.GETFILTER(ColumnLayout."Salesperson Filter")<>'' Then
                                //SETFILTER("Sales Person Code",ColumnLayout."Salesperson Filter");

                                FILTERGROUP(0);

                                CASE AmountType OF
                                    AmountType::"Net Amount":
                                        BEGIN
                                            if CalcAddCurr THEN BEGIN
                                                CALCSUMS("Add.-Curr. Amount");
                                                ColValue := "Add.-Curr. Amount";
                                            END ELSE BEGIN
                                                CALCSUMS(Amount);
                                                ColValue := Amount;
                                            END;
                                            Balance := ColValue;
                                        END;
                                    AmountType::"Debit Amount":
                                        BEGIN
                                            if CalcAddCurr THEN BEGIN
                                                if TestBalance THEN BEGIN
                                                    CALCSUMS("Add.-Curr. Debit Amount", "Add.-Curr. Amount");
                                                    Balance := "Add.-Curr. Amount";
                                                END ELSE
                                                    CALCSUMS("Add.-Curr. Debit Amount");
                                                ColValue := "Add.-Curr. Debit Amount";
                                            END ELSE BEGIN
                                                if TestBalance THEN BEGIN
                                                    CALCSUMS("Debit Amount", Amount);
                                                    Balance := Amount;
                                                END ELSE
                                                    CALCSUMS("Debit Amount");
                                                ColValue := "Debit Amount";
                                            END;
                                        END;
                                    AmountType::"Credit Amount":
                                        BEGIN
                                            if CalcAddCurr THEN BEGIN
                                                if TestBalance THEN BEGIN
                                                    CALCSUMS("Add.-Curr. Credit Amount", "Add.-Curr. Amount");
                                                    Balance := "Add.-Curr. Amount";
                                                END ELSE
                                                    CALCSUMS("Add.-Curr. Credit Amount");
                                                ColValue := "Add.-Curr. Credit Amount";
                                            END ELSE BEGIN
                                                if TestBalance THEN BEGIN
                                                    CALCSUMS("Credit Amount", Amount);
                                                    Balance := Amount;
                                                END ELSE
                                                    CALCSUMS("Credit Amount");
                                                ColValue := "Credit Amount";
                                            END;
                                        END;
                                END;
                            END;
                    END;

                ColumnLayout."Ledger Entry Type"::"Budget Entries":
                    BEGIN
                        if AccSchedName."Analysis View Name" = '' THEN
                            WITH GLBudgEntry DO BEGIN
                                if UseBusUnitFilter OR UseDimFilter THEN
                                    SETCURRENTKEY(
                                      "Budget Name", "G/L Account No.", "Business Unit Code",
                                      "Global Dimension 1 Code", "Global Dimension 2 Code",
                                      "Budget Dimension 1 Code", "Budget Dimension 2 Code",
                                      "Budget Dimension 3 Code", "Budget Dimension 4 Code", Date)
                                ELSE
                                    SETCURRENTKEY("Budget Name", "G/L Account No.", Date);
                                if GLAcc.Totaling = '' THEN
                                    SETRANGE("G/L Account No.", GLAcc."No.")
                                ELSE
                                    SETFILTER("G/L Account No.", GLAcc.Totaling);
                                GLAcc.COPYFILTER("Date Filter", Date);
                                AccSchedLine.COPYFILTER("G/L Budget Filter", "Budget Name");
                                AccSchedLine.COPYFILTER("Business Unit Filter", "Business Unit Code");
                                GLAcc.COPYFILTER("Filtro Eliminaciones", Eliminaciones);
                                AccSchedLine.COPYFILTER("Dimension 1 Filter", "Global Dimension 1 Code");
                                AccSchedLine.COPYFILTER("Dimension 2 Filter", "Global Dimension 2 Code");
                                AccSchedLine.COPYFILTER("Dimension 3 Filter", "Global Dimension 3 Code");
                                AccSchedLine.COPYFILTER("Dimension 4 Filter", "Global Dimension 4 Code");
                                AccSchedLine.COPYFILTER("Dimension 5 Filter", "Global Dimension 5 Code");
                                FILTERGROUP(2);
                                SETFILTER("Global Dimension 1 Code", GetDimTotalingFilter(1, AccSchedLine."Dimension 1 Totaling"));
                                SETFILTER("Global Dimension 2 Code", GetDimTotalingFilter(2, AccSchedLine."Dimension 2 Totaling"));
                                SETFILTER("Global Dimension 3 Code", GetDimTotalingFilter(3, AccSchedLine."Dimension 3 Totaling"));
                                SETFILTER("Global Dimension 4 Code", GetDimTotalingFilter(4, AccSchedLine."Dimension 4 Totaling"));
                                SETFILTER("Global Dimension 5 Code", GetDimTotalingFilter(5, AccSchedLine."Dimension 5 Totaling"));
                                FILTERGROUP(6);
                                SETFILTER("Global Dimension 1 Code", GetDimTotalingFilter(1, ColumnLayout."Dimension 1 Totaling"));
                                SETFILTER("Global Dimension 2 Code", GetDimTotalingFilter(2, ColumnLayout."Dimension 2 Totaling"));
                                SETFILTER("Global Dimension 3 Code", GetDimTotalingFilter(3, ColumnLayout."Dimension 3 Totaling"));
                                SETFILTER("Global Dimension 4 Code", GetDimTotalingFilter(4, ColumnLayout."Dimension 4 Totaling"));
                                SETFILTER("Global Dimension 5 Code", GetDimTotalingFilter(5, ColumnLayout."Dimension 5 Totaling"));
                                SETFILTER("Business Unit Code", ColumnLayout."Business Unit Totaling");
                                FILTERGROUP(0);

                                CASE AmountType OF
                                    AmountType::"Net Amount":
                                        BEGIN
                                            CALCSUMS(Amount);
                                            ColValue := Amount;
                                        END;
                                    AmountType::"Debit Amount":
                                        BEGIN
                                            CALCSUMS(Amount);
                                            ColValue := Amount;
                                            if ColValue < 0 THEN
                                                ColValue := 0;
                                        END;
                                    AmountType::"Credit Amount":
                                        BEGIN
                                            CALCSUMS(Amount);
                                            ColValue := -Amount;
                                            if ColValue < 0 THEN
                                                ColValue := 0;
                                        END;
                                END;
                                Balance := Amount;
                            END
                        ELSE
                            WITH AnalysisViewBudgetEntry DO BEGIN
                                if GLAcc.Totaling = '' THEN
                                    SETRANGE("G/L Account No.", GLAcc."No.")
                                ELSE
                                    SETFILTER("G/L Account No.", GLAcc.Totaling);
                                SETRANGE("Analysis View Code", AccSchedName."Analysis View Name");
                                GLAcc.COPYFILTER("Date Filter", "Posting Date");
                                //GLAcc.COPYFILTER("Filtro Eliminaciones",Eliminaciones);
                                AccSchedLine.COPYFILTER("G/L Budget Filter", "Budget Name");
                                AccSchedLine.COPYFILTER("Business Unit Filter", "Business Unit Code");
                                AccSchedLine.COPYFILTER("Dimension 1 Filter", "Dimension 1 Value Code");
                                AccSchedLine.COPYFILTER("Dimension 2 Filter", "Dimension 2 Value Code");
                                AccSchedLine.COPYFILTER("Dimension 3 Filter", "Dimension 3 Value Code");
                                AccSchedLine.COPYFILTER("Dimension 4 Filter", "Dimension 4 Value Code");
                                AccSchedLine.COPYFILTER("Dimension 5 Filter", "Dimension 5 Value Code");
                                FILTERGROUP(2);
                                SETFILTER("Dimension 1 Value Code", GetDimTotalingFilter(1, AccSchedLine."Dimension 1 Totaling"));
                                SETFILTER("Dimension 2 Value Code", GetDimTotalingFilter(2, AccSchedLine."Dimension 2 Totaling"));
                                SETFILTER("Dimension 3 Value Code", GetDimTotalingFilter(3, AccSchedLine."Dimension 3 Totaling"));
                                SETFILTER("Dimension 4 Value Code", GetDimTotalingFilter(4, AccSchedLine."Dimension 4 Totaling"));
                                SETFILTER("Dimension 5 Value Code", GetDimTotalingFilter(5, AccSchedLine."Dimension 5 Totaling"));
                                FILTERGROUP(6);
                                SETFILTER("Dimension 1 Value Code", GetDimTotalingFilter(1, ColumnLayout."Dimension 1 Totaling"));
                                SETFILTER("Dimension 2 Value Code", GetDimTotalingFilter(2, ColumnLayout."Dimension 2 Totaling"));
                                SETFILTER("Dimension 3 Value Code", GetDimTotalingFilter(3, ColumnLayout."Dimension 3 Totaling"));
                                SETFILTER("Dimension 4 Value Code", GetDimTotalingFilter(4, ColumnLayout."Dimension 4 Totaling"));
                                SETFILTER("Dimension 5 Value Code", GetDimTotalingFilter(5, ColumnLayout."Dimension 5 Totaling"));
                                SETFILTER("Business Unit Code", ColumnLayout."Business Unit Totaling");
                                FILTERGROUP(0);

                                CASE AmountType OF
                                    AmountType::"Net Amount":
                                        BEGIN
                                            CALCSUMS(Amount);
                                            ColValue := Amount;
                                        END;
                                    AmountType::"Debit Amount":
                                        BEGIN
                                            CALCSUMS(Amount);
                                            ColValue := Amount;
                                            if ColValue < 0 THEN
                                                ColValue := 0;
                                        END;
                                    AmountType::"Credit Amount":
                                        BEGIN
                                            CALCSUMS(Amount);
                                            ColValue := -Amount;
                                            if ColValue < 0 THEN
                                                ColValue := 0;
                                        END;
                                END;
                                Balance := Amount;
                            END;
                        if CalcAddCurr THEN BEGIN
                            if NOT GLSetupRead THEN BEGIN
                                GLSetup.GET;
                                GLSetupRead := TRUE;
                                if GLSetup."Additional Reporting Currency" <> '' THEN
                                    AddRepCurrency.GET(GLSetup."Additional Reporting Currency");
                            END;
                            if GLSetup."Additional Reporting Currency" <> '' THEN
                                ColValue := ROUND(ExchangeAmtAddCurrToLCY(ColValue), AddRepCurrency."Amount Rounding Precision")
                            ELSE
                                ColValue := 0;
                        END;
                    END;
            END;
            if TestBalance THEN BEGIN
                if AccSchedLine.Show = AccSchedLine.Show::"When Positive Balance" THEN
                    if Balance < 0 THEN
                        EXIT(0);
                if AccSchedLine.Show = AccSchedLine.Show::"When Negative Balance" THEN
                    if Balance > 0 THEN
                        EXIT(0);
            END;
        END;
        EXIT(ColValue);
    END;

    PROCEDURE SetGLAccRowFilters(VAR GLAcc: Record 15; VAR AccSchedLine2: Record 85);
    BEGIN
        WITH AccSchedLine2 DO BEGIN
            COPYFILTER("Filtro Eliminaciones", GLAcc."Filtro Eliminaciones");
            CASE "Totaling Type" OF
                "Totaling Type"::"Posting Accounts":
                    BEGIN
                        GLAcc.SETFILTER("No.", Totaling);
                        GLAcc.SETRANGE("Account Type", GLAcc."Account Type"::Posting);
                    END;
                "Totaling Type"::"Total Accounts":
                    BEGIN
                        GLAcc.SETFILTER("No.", Totaling);
                        GLAcc.SETFILTER("Account Type", '<>%1', GLAcc."Account Type"::Posting);
                    END;
            END;
        END;
    END;

    PROCEDURE SetGLAccColumnFilters(VAR GLAcc: Record 15; AccSchedLine2: Record 85; VAR ColumnLayout: Record 334);
    VAR
        FromDate: Date;
        ToDate: Date;
        FiscalStartDate2: Date;
    BEGIN
        WITH ColumnLayout DO BEGIN
            if (FORMAT("Comparison Date Formula") <> '0') AND (FORMAT("Comparison Date Formula") <> '') THEN BEGIN
                FromDate := CALCDATE("Comparison Date Formula", StartDate);
                if (EndDate = CALCDATE('<CM>', EndDate)) AND
                   ((STRPOS(FORMAT("Comparison Date Formula"), Text005) > 0) OR
                    (STRPOS(FORMAT("Comparison Date Formula"), Text006) > 0) OR
                    (STRPOS(FORMAT("Comparison Date Formula"), Text007) > 0))
                THEN
                    ToDate := CALCDATE('<CM>', CALCDATE("Comparison Date Formula", EndDate))
                ELSE
                    ToDate := CALCDATE("Comparison Date Formula", EndDate);
                FiscalStartDate2 := FindFiscalYear(ToDate);
            END ELSE
                if "Comparison Period Formula" <> '' THEN BEGIN
                    AccPeriodStartEnd("Comparison Period Formula", StartDate, FromDate, ToDate);
                    FiscalStartDate2 := FindFiscalYear(ToDate);
                END ELSE BEGIN
                    FromDate := StartDate;
                    ToDate := EndDate;
                    FiscalStartDate2 := FiscalStartDate;
                END;

            CASE "Column Type" OF
                "Column Type"::"Net Change":
                    CASE AccSchedLine2."Row Type" OF
                        AccSchedLine2."Row Type"::"Net Change":
                            GLAcc.SETRANGE("Date Filter", FromDate, ToDate);
                        AccSchedLine2."Row Type"::"Beginning Balance":
                            GLAcc.SETFILTER("Date Filter", '<%1', FromDate);  // always includes closing date
                        AccSchedLine2."Row Type"::"Balance at Date":
                            GLAcc.SETRANGE("Date Filter", 0D, ToDate);
                    END;
                "Column Type"::"Balance at Date":
                    if AccSchedLine2."Row Type" = AccSchedLine2."Row Type"::"Beginning Balance" THEN
                        GLAcc.SETRANGE("Date Filter", 0D)   // Force a zero return
                    ELSE
                        GLAcc.SETRANGE("Date Filter", 0D, ToDate);
                "Column Type"::"Beginning Balance":
                    if AccSchedLine2."Row Type" = AccSchedLine2."Row Type"::"Balance at Date" THEN
                        GLAcc.SETRANGE("Date Filter", 0D)   // Force a zero return
                    ELSE
                        GLAcc.SETRANGE(
                          "Date Filter", 0D, CLOSINGDATE(FromDate - 1));
                "Column Type"::"Year to Date":
                    CASE AccSchedLine2."Row Type" OF
                        AccSchedLine2."Row Type"::"Net Change":
                            GLAcc.SETRANGE("Date Filter", FiscalStartDate2, ToDate);
                        AccSchedLine2."Row Type"::"Beginning Balance":
                            GLAcc.SETFILTER("Date Filter", '<%1', FiscalStartDate2);  // always includes closing date
                        AccSchedLine2."Row Type"::"Balance at Date":
                            GLAcc.SETRANGE("Date Filter", 0D, ToDate);
                    END;
                "Column Type"::"Rest of Fiscal Year":
                    CASE AccSchedLine2."Row Type" OF
                        AccSchedLine2."Row Type"::"Net Change":
                            GLAcc.SETRANGE(
                              "Date Filter", CALCDATE('<+1D>', ToDate), FindEndOfFiscalYear(FiscalStartDate2));
                        AccSchedLine2."Row Type"::"Beginning Balance":
                            GLAcc.SETRANGE("Date Filter", 0D, ToDate);
                        AccSchedLine2."Row Type"::"Balance at Date":
                            GLAcc.SETRANGE("Date Filter", 0D, FindEndOfFiscalYear(ToDate));
                    END;
                "Column Type"::"Entire Fiscal Year":
                    CASE AccSchedLine2."Row Type" OF
                        AccSchedLine2."Row Type"::"Net Change":
                            GLAcc.SETRANGE(
                              "Date Filter",
                              FiscalStartDate2,
                              FindEndOfFiscalYear(FiscalStartDate2));
                        AccSchedLine2."Row Type"::"Beginning Balance":
                            GLAcc.SETFILTER("Date Filter", '<%1', FiscalStartDate2);  // always includes closing date
                        AccSchedLine2."Row Type"::"Balance at Date":
                            GLAcc.SETRANGE("Date Filter", 0D, FindEndOfFiscalYear(ToDate));
                    END;
            END;
        END;
    END;

    LOCAL PROCEDURE EvaluateExpression(IsAccSchedLineExpression: Boolean; Expression: Text[80]; AccSchedLine: Record 85; ColumnLayout: Record 334; CalcAddCurr: Boolean): Decimal;
    VAR
        AccSchedLine2: Record 85;
        Result: Decimal;
        Parantheses: Integer;
        Operator: Char;
        LeftOperand: Text[80];
        RightOperand: Text[80];
        LeftResult: Decimal;
        RightResult: Decimal;
        i: Integer;
        IsExpression: Boolean;
        IsFilter: Boolean;
        Operators: Text[8];
        OperatorNo: Integer;
        AccSchedLineID: Integer;
    BEGIN
        Result := 0;

        CallLevel := CallLevel + 1;
        if CallLevel > 25 THEN
            ShowError(Text020,
                       AccSchedLine, ColumnLayout);

        Expression := DELCHR(Expression, '<>', ' ');
        if STRLEN(Expression) > 0 THEN BEGIN
            Parantheses := 0;
            IsExpression := FALSE;
            Operators := '+-*/^%[';
            OperatorNo := 1;
            REPEAT
                i := STRLEN(Expression);
                REPEAT
                    if Expression[i] = '(' THEN
                        Parantheses := Parantheses + 1
                    ELSE
                        if Expression[i] = ')' THEN
                            Parantheses := Parantheses - 1;
                    if (Parantheses = 0) AND (Expression[i] = Operators[OperatorNo]) THEN
                        IsExpression := TRUE
                    ELSE
                        i := i - 1;
                UNTIL IsExpression OR (i <= 0);
                if NOT IsExpression THEN
                    OperatorNo := OperatorNo + 1;
            UNTIL (OperatorNo > STRLEN(Operators)) OR IsExpression;
            if IsExpression THEN BEGIN
                if i > 1 THEN
                    LeftOperand := COPYSTR(Expression, 1, i - 1)
                ELSE
                    LeftOperand := '';
                if i < STRLEN(Expression) THEN
                    RightOperand := COPYSTR(Expression, i + 1)
                ELSE
                    RightOperand := '';
                Operator := Expression[i];
                LeftResult :=
                  EvaluateExpression(
                    IsAccSchedLineExpression, LeftOperand, AccSchedLine, ColumnLayout, CalcAddCurr);
                if (RightOperand = '') AND (Operator = '%') AND NOT IsAccSchedLineExpression AND
                   (AccSchedLine."Totaling Type" <> AccSchedLine."Totaling Type"::"Set Base For Percent")
                THEN BEGIN
                    AccSchedLine2.COPY(AccSchedLine);
                    AccSchedLine2."Line No." := GetBasePercentLine(AccSchedLine, ColumnLayout);
                    AccSchedLine2.FIND;
                    RightResult :=
                      EvaluateExpression(
                        IsAccSchedLineExpression, LeftOperand, AccSchedLine2, ColumnLayout, CalcAddCurr);
                END ELSE
                    RightResult :=
                      EvaluateExpression(
                        IsAccSchedLineExpression, RightOperand, AccSchedLine, ColumnLayout, CalcAddCurr);
                CASE Operator OF
                    '^':
                        Result := POWER(LeftResult, RightResult);
                    '%':
                        if RightResult = 0 THEN BEGIN
                            Result := 0;
                            DivisionError := TRUE;
                        END ELSE
                            Result := 100 * LeftResult / RightResult;
                    '*':
                        Result := LeftResult * RightResult;
                    '/':
                        if RightResult = 0 THEN BEGIN
                            Result := 0;
                            DivisionError := TRUE;
                        END ELSE
                            Result := LeftResult / RightResult;
                    '+':
                        Result := LeftResult + RightResult;
                    '-':
                        Result := LeftResult - RightResult;
                    '[':
                        if RightResult >= 0 THEN
                            Result := LeftResult + RightResult
                        ELSE
                            Result := LeftResult;
                END;
            END ELSE
                if (Expression[1] = '(') AND (Expression[STRLEN(Expression)] = ')') THEN
                    Result :=
                      EvaluateExpression(
                        IsAccSchedLineExpression, COPYSTR(Expression, 2, STRLEN(Expression) - 2),
                        AccSchedLine, ColumnLayout, CalcAddCurr)
                ELSE BEGIN
                    IsFilter :=
                       (STRPOS(Expression, '..') +
                        STRPOS(Expression, '|') +
                        STRPOS(Expression, '<') +
                        STRPOS(Expression, '>') +
                        STRPOS(Expression, '&') +
                        STRPOS(Expression, '=') > 0);
                    if (STRLEN(Expression) > 10) AND (NOT IsFilter) THEN
                        EVALUATE(Result, Expression)
                    ELSE
                        if IsAccSchedLineExpression THEN BEGIN
                            AccSchedLine.SETRANGE("Schedule Name", AccSchedLine."Schedule Name");
                            AccSchedLine.SETFILTER("Row No.", Expression);
                            AccSchedLineID := AccSchedLine."Line No.";
                            if AccSchedLine.FIND('-') THEN
                                REPEAT
                                    if AccSchedLine."Line No." <> AccSchedLineID THEN
                                        Result := Result + CalcCellValue(AccSchedLine, ColumnLayout, CalcAddCurr);
                                UNTIL AccSchedLine.NEXT = 0
                            ELSE
                                if IsFilter OR (NOT EVALUATE(Result, Expression)) THEN
                                    ShowError(Text012, AccSchedLine, ColumnLayout);
                        END ELSE BEGIN
                            ColumnLayout.SETRANGE("Column Layout Name", ColumnLayout."Column Layout Name");
                            ColumnLayout.SETFILTER("Column No.", Expression);
                            AccSchedLineID := ColumnLayout."Line No.";
                            if ColumnLayout.FIND('-') THEN
                                REPEAT
                                    if ColumnLayout."Line No." <> AccSchedLineID THEN
                                        Result := Result + CalcCellValue(AccSchedLine, ColumnLayout, CalcAddCurr);
                                UNTIL ColumnLayout.NEXT = 0
                            ELSE
                                if IsFilter OR (NOT EVALUATE(Result, Expression)) THEN
                                    ShowError(Text013, AccSchedLine, ColumnLayout);
                        END;
                END;
        END;
        CallLevel := CallLevel - 1;
        EXIT(Result);
    END;

    PROCEDURE FormatCellAsText(VAR ColumnLayout2: Record 334; Value: Decimal): Text[30];
    VAR
        GLSetup: Record "General Ledger Setup";
        ValueAsText: Text[30];
        Currency: Record "Currency";
    BEGIN
        if NormalFormatString = '' THEN BEGIN
            if NOT GLSetupRead THEN BEGIN
                GLSetup.GET;
                GLSetupRead := TRUE;
            END;
            if OldCalcAddCurr THEN BEGIN
                GLSetup.TESTFIELD(GLSetup."Additional Reporting Currency");
                Currency.SETRANGE(Currency.Code, GLSetup."Additional Reporting Currency");
                if Currency.FIND('-') THEN
                    NormalFormatString := Text014 + Currency."Amount Decimal Places" + Text015;
            END ELSE
                NormalFormatString := Text014 + GLSetup."Amount Decimal Places" + Text015;
        END;
        WITH ColumnLayout2 DO
            if Value <> 0 THEN BEGIN
                CASE "Rounding Factor" OF
                    "Rounding Factor"::None:
                        ValueAsText := FORMAT(Value, 0, NormalFormatString);
                    "Rounding Factor"::"1":
                        ValueAsText := FORMAT(ROUND(Value, 1));
                    "Rounding Factor"::"1000":
                        ValueAsText := FORMAT(ROUND(Value / 1000, 1));
                    "Rounding Factor"::"1000000":
                        ValueAsText := FORMAT(ROUND(Value / 1000000, 1));
                END;
                if (ColumnLayout2."Column Type" = ColumnLayout2."Column Type"::Formula) AND (STRPOS(ColumnLayout2.Formula, '%') > 1) THEN
                    ValueAsText := ValueAsText + '%';
            END;
        EXIT(ValueAsText);
    END;

    PROCEDURE GetDivisionError(): Boolean;
    BEGIN
        EXIT(DivisionError);
    END;

    PROCEDURE GetPeriodError(): Boolean;
    BEGIN
        EXIT(PeriodError);
    END;

    PROCEDURE ShowError(MessageLine: Text[100]; VAR AccSchedLine: Record 85; VAR ColumnLayout: Record 334);
    BEGIN
        AccSchedLine.SETRANGE("Schedule Name", AccSchedLine."Schedule Name");
        AccSchedLine.SETRANGE("Line No.", CallingAccSchedLineID);
        if AccSchedLine.FIND('-') THEN;
        ColumnLayout.SETRANGE("Column Layout Name", ColumnLayout."Column Layout Name");
        ColumnLayout.SETRANGE("Line No.", CallingColumnLayoutID);
        if ColumnLayout.FIND('-') THEN;
        ERROR(
          MessageLine + '\\' +
          Text017 +
          Text018 +
          Text019,
          AccSchedLine."Row No.", AccSchedLine."Line No.", AccSchedLine.Totaling,
          ColumnLayout."Column No.", ColumnLayout."Line No.", ColumnLayout.Formula);
    END;

    PROCEDURE InsertGLAccounts(VAR AccSchedLine: Record 85);
    VAR
        GLAcc: Record 15;
        RecRef: RecordRef;
        GLAccList: Page 18;
        GLAccCount: Integer;
        AccSchedLineNo: Integer;
        i: Integer;
    BEGIN
        GLAccList.LOOKUPMODE(TRUE);
        if GLAccList.RUNMODAL = ACTION::LookupOK THEN BEGIN
            GLAccList.SetSelection(GLAcc);
            GLAccCount := GLAcc.COUNT;
            if GLAccCount > 0 THEN BEGIN
                AccSchedLineNo := AccSchedLine."Line No.";
                AccSchedLine.SETRANGE("Schedule Name", AccSchedLine."Schedule Name");
                if AccSchedLine.FIND('+') THEN
                    REPEAT
                        i := AccSchedLine."Line No.";
                        if i >= AccSchedLineNo THEN BEGIN
                            AccSchedLine.DELETE;
                            AccSchedLine."Line No." := i + 10000 * GLAccCount;
                            AccSchedLine.INSERT;
                        END;
                    UNTIL (i <= AccSchedLineNo) OR (AccSchedLine.NEXT(-1) = 0);

                if AccSchedLineNo = 0 THEN
                    AccSchedLineNo := 10000;

                if GLAcc.FIND('-') THEN
                    REPEAT
                        AccSchedLine.INIT;
                        AccSchedLine."Line No." := AccSchedLineNo;
                        AccSchedLineNo := AccSchedLineNo + 10000;
                        AccSchedLine.Description := GLAcc.Name;
                        if GLAcc."Account Type" IN
                           [GLAcc."Account Type"::Posting, GLAcc."Account Type"::Posting, GLAcc."Account Type"::Heading]
                        THEN BEGIN
                            AccSchedLine.Totaling := GLAcc."No.";
                            AccSchedLine."Row No." := COPYSTR(GLAcc."No.", 1, MAXSTRLEN(AccSchedLine."Row No."));
                        END;
                        if GLAcc."Account Type" IN
                           [GLAcc."Account Type"::Posting, GLAcc."Account Type"::Heading]
                        THEN
                            AccSchedLine."Totaling Type" := AccSchedLine."Totaling Type"::"Total Accounts"
                        ELSE
                            AccSchedLine."Totaling Type" := AccSchedLine."Totaling Type"::"Posting Accounts";
                        AccSchedLine.INSERT;
                        RecRef.GETTABLE(AccSchedLine);
                    //ChangeLogMgt.LogInsertion(RecRef);
                    UNTIL GLAcc.NEXT = 0;
            END;
        END;
    END;

    LOCAL PROCEDURE ExchangeAmtAddCurrToLCY(AmountLCY: Decimal): Decimal;
    BEGIN
        if NOT GLSetupRead THEN BEGIN
            GLSetup.GET;
            GLSetupRead := TRUE;
        END;

        EXIT(
          CurrExchRate.ExchangeAmtLCYToFCY(
            WORKDATE, GLSetup."Additional Reporting Currency", AmountLCY,
            CurrExchRate.ExchangeRate(WORKDATE, GLSetup."Additional Reporting Currency")));
    END;

    PROCEDURE SetAccSchedName(VAR NewAccSchedName: Record 84);
    BEGIN
        AccSchedName := NewAccSchedName;
    END;

    PROCEDURE GetDimTotalingFilter(DimNo: Integer; DimTotaling: Text[80]): Text[1024];
    VAR
        DimTotaling2: Text[80];
        DimTotalPart: Text[80];
        ResultFilter: Text[1024];
        ResultFilter2: Text[1024];
        i: Integer;
    BEGIN
        if DimTotaling = '' THEN
            EXIT(DimTotaling);
        DimTotaling2 := DimTotaling;
        REPEAT
            i := STRPOS(DimTotaling2, '|');
            if i > 0 THEN BEGIN
                DimTotalPart := COPYSTR(DimTotaling2, 1, i - 1);
                if i < STRLEN(DimTotaling2) THEN
                    DimTotaling2 := COPYSTR(DimTotaling2, i + 1)
                ELSE
                    DimTotaling2 := '';
            END ELSE
                DimTotalPart := DimTotaling2;
            ResultFilter2 := ConvDimTotalingFilter(DimNo, DimTotalPart);
            if ResultFilter2 <> '' THEN
                if STRLEN(ResultFilter) + STRLEN(ResultFilter2) + 1 > MAXSTRLEN(ResultFilter) THEN
                    ERROR(Text021, DimTotaling)
                ELSE BEGIN
                    if ResultFilter <> '' THEN
                        ResultFilter := ResultFilter + '|';
                    ResultFilter := ResultFilter + ResultFilter2;
                END;
        UNTIL i <= 0;
        EXIT(ResultFilter);
    END;

    LOCAL PROCEDURE ConvDimTotalingFilter(DimNo: Integer; DimTotaling: Text[80]): Text[1024];
    VAR
        DimVal: Record 349;
        DimCode: Code[20];
        ResultFilter: Text[1024];
        DimValTotaling: Boolean;
    BEGIN
        if DimTotaling = '' THEN
            EXIT(DimTotaling);

        CheckAnalysisView(AccSchedName.Name, '', FALSE);

        CASE DimNo OF
            1:
                DimCode := AnalysisView."Dimension 1 Code";
            2:
                DimCode := AnalysisView."Dimension 2 Code";
            3:
                DimCode := AnalysisView."Dimension 3 Code";
            4:
                DimCode := AnalysisView."Dimension 4 Code";
            5:
                DimCode := AnalysisView."Dimension 5 Totaling";
        END;
        if DimCode = '' THEN
            EXIT(DimTotaling);

        DimVal.SETRANGE("Dimension Code", DimCode);
        DimVal.SETFILTER(Code, DimTotaling);
        if DimVal.FIND('-') THEN
            REPEAT
                DimValTotaling :=
                  DimVal."Dimension Value Type" IN
                  [DimVal."Dimension Value Type"::Total, DimVal."Dimension Value Type"::"End-Total"];
                if DimValTotaling AND (DimVal.Totaling <> '') THEN BEGIN
                    if STRLEN(ResultFilter) + STRLEN(DimVal.Totaling) + 1 > MAXSTRLEN(ResultFilter) THEN
                        ERROR(Text021, DimTotaling);
                    if ResultFilter <> '' THEN
                        ResultFilter := ResultFilter + '|';
                    ResultFilter := ResultFilter + DimVal.Totaling;
                END;
            UNTIL (DimVal.NEXT = 0) OR NOT (DimValTotaling);

        if DimValTotaling THEN
            EXIT(ResultFilter)
        ELSE
            EXIT(DimTotaling);
    END;

    LOCAL PROCEDURE CalcCostType(VAR CostType: Record "Cost Type"; VAR AccSchedLine: Record 85; VAR ColumnLayout: Record 334; CalcAddCurr: Boolean) ColValue: Decimal;
    VAR
        GLEntry: Record "G/L Entry";
        GLBudgEntry: Record 96;
        AnalysisViewEntry: Record "Analysis View Entry";
        AnalysisViewBudgetEntry: Record "Analysis View Entry";
        CostEntry: Record "Cost Entry";
        CostBudgEntry: Record "Cost Budget Entry";
        UseDimFilter: Boolean;
        AmountType: option "Net Amount","Debit Amount","Credit Amount";
        TestBalance: Boolean;
        Balance: Decimal;
    BEGIN
        ColValue := 0;
        if AccSchedName.Name <> AccSchedLine."Schedule Name" THEN
            AccSchedName.GET(AccSchedLine."Schedule Name");

        AmountType := ColumnLayout."Amount Type".AsInteger();
        CASE AccSchedLine."Amount Type" OF
            AccSchedLine."Amount Type"::"Debit Amount":
                CASE AmountType OF
                    AmountType::"Net Amount":
                        AmountType := AmountType::"Debit Amount";
                    AmountType::"Credit Amount":
                        EXIT(0);
                END;
            AccSchedLine."Amount Type"::"Credit Amount":
                CASE AmountType OF
                    AmountType::"Net Amount":
                        AmountType := AmountType::"Credit Amount";
                    AmountType::"Debit Amount":
                        EXIT(0);
                END;
        END;
        TestBalance :=
          AccSchedLine.Show IN [AccSchedLine.Show::"When Positive Balance", AccSchedLine.Show::"When Negative Balance"];

        if ColumnLayout."Column Type" <> ColumnLayout."Column Type"::Formula THEN BEGIN
            UseDimFilter :=
              (AccSchedLine."Dimension 1 Totaling" <> '') OR
              (AccSchedLine."Dimension 2 Totaling" <> '') OR
              (AccSchedLine."Dimension 3 Totaling" <> '') OR
              (AccSchedLine."Dimension 4 Totaling" <> '') OR
              (AccSchedLine."Dimension 5 Totaling" <> '') OR
              (AccSchedLine.GETFILTER("Dimension 1 Filter") <> '') OR
              (AccSchedLine.GETFILTER("Dimension 2 Filter") <> '') OR
              (AccSchedLine.GETFILTER("Dimension 3 Filter") <> '') OR
              (AccSchedLine.GETFILTER("Dimension 4 Filter") <> '') OR
              (AccSchedLine.GETFILTER("Dimension 5 Filter") <> '') OR
              (ColumnLayout."Dimension 1 Totaling" <> '') OR
              (ColumnLayout."Dimension 2 Totaling" <> '') OR
              (ColumnLayout."Dimension 3 Totaling" <> '') OR
              (ColumnLayout."Dimension 4 Totaling" <> '') OR
              (ColumnLayout."Dimension 5 Totaling" <> '');

            if ColumnLayout."Ledger Entry Type" = ColumnLayout."Ledger Entry Type"::"Entries" THEN BEGIN

                WITH CostEntry DO BEGIN
                    if UseDimFilter THEN
                        SETCURRENTKEY("Cost Type No.", "Cost Center Code", "Cost Object Code")
                    ELSE
                        SETCURRENTKEY("Cost Type No.", "Posting Date");

                    if CostType.Totaling = '' THEN
                        SETRANGE("Cost Type No.", CostType."No.")
                    ELSE
                        SETFILTER("Cost Type No.", CostType.Totaling);

                    CostType.COPYFILTER("Date Filter", "Posting Date");
                    AccSchedLine.COPYFILTER("Dimension 1 Filter", "Cost Center Code");
                    AccSchedLine.COPYFILTER("Dimension 2 Filter", "Cost Object Code");

                    FILTERGROUP(2);
                    SETFILTER("Cost Center Code", GetDimTotalingFilter(1, AccSchedLine."Dimension 1 Totaling"));
                    SETFILTER("Cost Object Code", GetDimTotalingFilter(2, AccSchedLine."Dimension 2 Totaling"));

                    FILTERGROUP(6);
                    SETFILTER("Cost Center Code", GetDimTotalingFilter(1, ColumnLayout."Dimension 1 Totaling"));
                    SETFILTER("Cost Object Code", GetDimTotalingFilter(2, ColumnLayout."Dimension 2 Totaling"));

                    FILTERGROUP(0);

                END;

                CASE AmountType OF
                    AmountType::"Net Amount":
                        BEGIN
                            CostEntry.CALCSUMS(Amount);
                            ColValue := CostEntry.Amount;

                            Balance := ColValue;

                        END;

                    AmountType::"Debit Amount":
                        BEGIN

                            if TestBalance THEN BEGIN
                                CostEntry.CALCSUMS("Debit Amount", Amount);
                                Balance := CostEntry.Amount;
                            END ELSE
                                CostEntry.CALCSUMS("Debit Amount");
                            ColValue := CostEntry."Debit Amount";

                        END;

                    AmountType::"Credit Amount":
                        BEGIN

                            if TestBalance THEN BEGIN
                                CostEntry.CALCSUMS("Credit Amount", Amount);
                                Balance := CostEntry.Amount;
                            END ELSE
                                CostEntry.CALCSUMS("Credit Amount");
                            ColValue := CostEntry."Credit Amount";

                        END;
                END;
            END;

            if ColumnLayout."Ledger Entry Type" = ColumnLayout."Ledger Entry Type"::"Budget Entries" THEN BEGIN
                WITH CostBudgEntry DO BEGIN
                    SETCURRENTKEY("Budget Name", "Cost Type No.", "Cost Center Code", "Cost Object Code", Date);

                    if CostType.Totaling = '' THEN
                        SETRANGE("Cost Type No.", CostType."No.")
                    ELSE
                        SETFILTER("Cost Type No.", CostType.Totaling);

                    CostType.COPYFILTER("Date Filter", Date);
                    AccSchedLine.COPYFILTER("G/L Budget Filter", "Budget Name");
                    AccSchedLine.COPYFILTER("Dimension 1 Filter", "Cost Center Code");
                    AccSchedLine.COPYFILTER("Dimension 2 Filter", "Cost Object Code");

                    FILTERGROUP(2);
                    SETFILTER("Cost Center Code", GetDimTotalingFilter(1, AccSchedLine."Dimension 1 Totaling"));
                    SETFILTER("Cost Object Code", GetDimTotalingFilter(2, AccSchedLine."Dimension 2 Totaling"));

                    FILTERGROUP(6);
                    SETFILTER("Cost Center Code", GetDimTotalingFilter(1, ColumnLayout."Dimension 1 Totaling"));
                    SETFILTER("Cost Object Code", GetDimTotalingFilter(2, ColumnLayout."Dimension 2 Totaling"));

                    FILTERGROUP(0);

                END;

                CostBudgEntry.CALCSUMS(Amount);

                CASE AmountType OF
                    AmountType::"Net Amount":
                        BEGIN
                            ColValue := CostBudgEntry.Amount;
                        END;

                    AmountType::"Debit Amount":
                        BEGIN
                            if CostBudgEntry.Amount > 0 THEN
                                ColValue := CostBudgEntry.Amount;
                        END;

                    AmountType::"Credit Amount":
                        BEGIN
                            if CostBudgEntry.Amount < 0 THEN
                                ColValue := CostBudgEntry.Amount;
                        END;
                END;

                Balance := CostBudgEntry.Amount;

            END;

            if TestBalance THEN BEGIN
                if AccSchedLine.Show = AccSchedLine.Show::"When Positive Balance" THEN
                    if Balance < 0 THEN
                        EXIT(0);
                if AccSchedLine.Show = AccSchedLine.Show::"When Negative Balance" THEN
                    if Balance > 0 THEN
                        EXIT(0);
            END;

        END;
        EXIT(ColValue);
    END;

    PROCEDURE SetCostTypeRowFilters(VAR CostType: Record "Cost Type"; VAR AccSchedLine2: Record 85; VAR ColumnLayout: Record 334);
    BEGIN
        WITH AccSchedLine2 DO BEGIN
            CASE "Totaling Type" OF
                "Totaling Type"::"Cost Type":
                    BEGIN
                        CostType.SETFILTER("No.", Totaling);
                        CostType.SETRANGE("Type", CostType."Type"::"Cost Type");
                    END;

                "Totaling Type"::"Cost Type Total":
                    BEGIN
                        CostType.SETFILTER("No.", Totaling);
                        CostType.SETFILTER("Type", '<>%1', CostType."Type"::"Cost Type");
                    END;
            END;

            if ColumnLayout."Ledger Entry Type" = ColumnLayout."Ledger Entry Type"::"Entries" THEN BEGIN
                CostType.SETFILTER("Cost Center Filter", GETFILTER("Dimension 1 Filter"));
                CostType.SETFILTER("Cost Object Filter", GETFILTER("Dimension 2 Filter"));
            END;

            if ColumnLayout."Ledger Entry Type" = ColumnLayout."Ledger Entry Type"::"Budget Entries" THEN BEGIN
                CostType.SETFILTER("Cost Center Filter", GETFILTER("Dimension 1 Filter"));
                CostType.SETFILTER("Cost Object Filter", GETFILTER("Dimension 2 Filter"));
                CostType.SETFILTER("Budget Filter", GETFILTER("G/L Budget Filter"));
            END;

        END;
    END;

    PROCEDURE SetCostTypeColumnFilters(VAR CostType: Record "Cost Type"; AccSchedLine2: Record 85; VAR ColumnLayout: Record 334);
    VAR
        FromDate: Date;
        ToDate: Date;
        FiscalStartDate2: Date;
    BEGIN

        WITH ColumnLayout DO BEGIN
            if (FORMAT("Comparison Date Formula") <> '0') AND (FORMAT("Comparison Date Formula") <> '') THEN BEGIN
                FromDate := CALCDATE("Comparison Date Formula", StartDate);
                if (EndDate = CALCDATE('<CM>', EndDate)) AND
                   ((STRPOS(FORMAT("Comparison Date Formula"), Text005) > 0) OR
                    (STRPOS(FORMAT("Comparison Date Formula"), Text006) > 0) OR
                    (STRPOS(FORMAT("Comparison Date Formula"), Text007) > 0))
                THEN
                    ToDate := CALCDATE('<CM>', CALCDATE("Comparison Date Formula", EndDate))
                ELSE
                    ToDate := CALCDATE("Comparison Date Formula", EndDate);
                FiscalStartDate2 := FindFiscalYear(ToDate);

            END ELSE
                if "Comparison Period Formula" <> '' THEN BEGIN
                    AccPeriodStartEnd("Comparison Period Formula", StartDate, FromDate, ToDate);
                    FiscalStartDate2 := FindFiscalYear(ToDate);
                END ELSE BEGIN
                    FromDate := StartDate;
                    ToDate := EndDate;
                    FiscalStartDate2 := FiscalStartDate;
                END;

            CASE "Column Type" OF
                "Column Type"::"Net Change":
                    CASE AccSchedLine2."Row Type" OF
                        AccSchedLine2."Row Type"::"Net Change":
                            CostType.SETRANGE("Date Filter", FromDate, ToDate);
                        AccSchedLine2."Row Type"::"Beginning Balance":
                            CostType.SETFILTER("Date Filter", '<%1', FromDate);
                        AccSchedLine2."Row Type"::"Balance at Date":
                            CostType.SETRANGE("Date Filter", 0D, ToDate);
                    END;
                "Column Type"::"Balance at Date":
                    if AccSchedLine2."Row Type" = AccSchedLine2."Row Type"::"Beginning Balance" THEN
                        CostType.SETRANGE("Date Filter", 0D) // Force a zero return
                    ELSE
                        CostType.SETRANGE("Date Filter", 0D, ToDate);
                "Column Type"::"Beginning Balance":
                    if AccSchedLine2."Row Type" = AccSchedLine2."Row Type"::"Balance at Date" THEN
                        CostType.SETRANGE("Date Filter", 0D) // Force a zero return
                    ELSE
                        CostType.SETRANGE(
                          "Date Filter", 0D, CALCDATE('<-1D>', FromDate));
                "Column Type"::"Year to Date":
                    CASE AccSchedLine2."Row Type" OF
                        AccSchedLine2."Row Type"::"Net Change":
                            CostType.SETRANGE("Date Filter", FiscalStartDate2, ToDate);
                        AccSchedLine2."Row Type"::"Beginning Balance":
                            CostType.SETFILTER("Date Filter", '<%1', FiscalStartDate2);
                        AccSchedLine2."Row Type"::"Balance at Date":
                            CostType.SETRANGE("Date Filter", 0D, ToDate);
                    END;
                "Column Type"::"Rest of Fiscal Year":
                    CASE AccSchedLine2."Row Type" OF
                        AccSchedLine2."Row Type"::"Net Change":
                            CostType.SETRANGE(
                              "Date Filter", CALCDATE('<+1D>', ToDate), FindEndOfFiscalYear(FiscalStartDate2));
                        AccSchedLine2."Row Type"::"Beginning Balance":
                            CostType.SETRANGE("Date Filter", 0D, ToDate);
                        AccSchedLine2."Row Type"::"Balance at Date":
                            CostType.SETRANGE("Date Filter", 0D, FindEndOfFiscalYear(ToDate));
                    END;
                "Column Type"::"Entire Fiscal Year":
                    CASE AccSchedLine2."Row Type" OF
                        AccSchedLine2."Row Type"::"Net Change":
                            CostType.SETRANGE(
                              "Date Filter", FiscalStartDate2, FindEndOfFiscalYear(FiscalStartDate2));
                        AccSchedLine2."Row Type"::"Beginning Balance":
                            CostType.SETFILTER("Date Filter", '<%1', FiscalStartDate2);
                        AccSchedLine2."Row Type"::"Balance at Date":
                            CostType.SETRANGE("Date Filter", 0D, FindEndOfFiscalYear(ToDate));
                    END;
            END;

        END;
    END;

    LOCAL PROCEDURE CalcVeAcc(VAR GLAcc: Record Vendor; VAR AccSchedLine: Record 85; VAR ColumnLayout: Record 334; CalcAddCurr: Boolean) ColValue: Decimal;
    VAR
        GLEntry: Record "G/L Entry";
        GLBudgEntry: Record 96;
        AnalysisViewEntry: Record "Analysis View Entry";
        AnalysisViewBudgetEntry: Record "Analysis View Budget Entry";
        AmountType: Option "Net Amount","Debit Amount","Credit Amount";
        TestBalance: Boolean;
        Balance: Decimal;
        UseBusUnitFilter: Boolean;
        UseDimFilter: Boolean;
    BEGIN
        //ASC 09/12/09
        if ColumnLayout.Empresa <> '' then
            if not Contrl.Permiso_Empresas(ColumnLayout.Empresa) then exit(0);
        if ColumnLayout.Empresa <> '' THEN
            GLEntry.CHANGECOMPANY(ColumnLayout.Empresa);
        if AccSchedLine.Company <> '' THEN
            GLEntry.CHANGECOMPANY(AccSchedLine.Company);
        if (ColumnLayout.Empresa <> '') AND
         (AccSchedLine.Company <> '') AND
         (AccSchedLine.Company <> ColumnLayout.Empresa) THEN
            EXIT(0);
        ColValue := 0;
        GLEntry.SETFILTER("G/L Account No.", '%1..%2|%3..%4|%5..%6|7..%8|%9..%10',
        '400000001', '400499999:', '4100', '4109:', '4030', '4039:', '4010', '4019:', '4110', '4119:');
        GLEntry.SETRANGE("Gen. Posting Type", GLEntry."Gen. Posting Type"::" ");
        if AccSchedName.Name <> AccSchedLine."Schedule Name" THEN
            AccSchedName.GET(AccSchedLine."Schedule Name");
        AmountType := ColumnLayout."Amount Type".AsInteger();
        CASE AccSchedLine."Amount Type" OF
            AccSchedLine."Amount Type"::"Debit Amount":
                CASE AmountType OF
                    AmountType::"Net Amount":
                        AmountType := AmountType::"Debit Amount";
                    AmountType::"Credit Amount":
                        EXIT(0);
                END;
            AccSchedLine."Amount Type"::"Credit Amount":
                CASE AmountType OF
                    AmountType::"Net Amount":
                        AmountType := AmountType::"Credit Amount";
                    AmountType::"Debit Amount":
                        EXIT(0);
                END;
        END;
        TestBalance :=
          AccSchedLine.Show IN [AccSchedLine.Show::"When Positive Balance", AccSchedLine.Show::"When Negative Balance"];
        if ColumnLayout."Column Type" <> ColumnLayout."Column Type"::Formula THEN BEGIN
            UseBusUnitFilter := (AccSchedLine.GETFILTER("Business Unit Filter") <> '') OR (ColumnLayout."Business Unit Totaling" <> '');
            UseDimFilter :=
              (AccSchedLine."Dimension 1 Totaling" <> '') OR
              (AccSchedLine."Dimension 2 Totaling" <> '') OR
              (AccSchedLine."Dimension 3 Totaling" <> '') OR
              (AccSchedLine."Dimension 4 Totaling" <> '') OR
              (AccSchedLine."Dimension 5 Totaling" <> '') OR
              (AccSchedLine.GETFILTER("Dimension 1 Filter") <> '') OR
              (AccSchedLine.GETFILTER("Dimension 2 Filter") <> '') OR
              (AccSchedLine.GETFILTER("Dimension 3 Filter") <> '') OR
              (AccSchedLine.GETFILTER("Dimension 4 Filter") <> '') OR
              (AccSchedLine.GETFILTER("Dimension 5 Filter") <> '') OR
              (ColumnLayout."Dimension 1 Totaling" <> '') OR
              (ColumnLayout."Dimension 2 Totaling" <> '') OR
              (ColumnLayout."Dimension 3 Totaling" <> '') OR
              (ColumnLayout."Dimension 4 Totaling" <> '') OR
              (ColumnLayout."Dimension 5 Totaling" <> '');
            CASE ColumnLayout."Ledger Entry Type" OF
                ColumnLayout."Ledger Entry Type"::"Entries":
                    BEGIN
                        if AccSchedName."Analysis View Name" = '' THEN
                            WITH GLEntry DO BEGIN
                                if UseBusUnitFilter THEN
                                    if UseDimFilter THEN
                                        SETCURRENTKEY(
                                          "G/L Account No.", "Source Type", "Source No.", "Posting Date", "Document Type", "Gen. Posting Type")
                                    ELSE
                                        SETCURRENTKEY(
                                          "G/L Account No.", "Source Type", "Source No.", "Posting Date", "Document Type", "Gen. Posting Type")
                                ELSE
                                    if UseDimFilter THEN
                                        SETCURRENTKEY("G/L Account No.", "Source Type", "Source No.", "Posting Date", "Document Type", "Gen. Posting Type")
                                    ELSE
                                        SETCURRENTKEY("G/L Account No.", "Source Type", "Source No.", "Posting Date", "Document Type", "Gen. Posting Type");
                                SETRANGE("Source No.", GLAcc."No.");
                                GLAcc.COPYFILTER("Date Filter", "Posting Date");
                                AccSchedLine.COPYFILTER("Business Unit Filter", "Business Unit Code");
                                AccSchedLine.COPYFILTER("Dimension 1 Filter", "Global Dimension 1 Code");
                                AccSchedLine.COPYFILTER("Dimension 2 Filter", "Global Dimension 2 Code");
                                AccSchedLine.COPYFILTER("Dimension 3 Filter", "Global Dimension 3 Code");
                                AccSchedLine.COPYFILTER("Dimension 5 Filter", "Global Dimension 5 Code");
                                FILTERGROUP(2);
                                SETFILTER("Global Dimension 1 Code", GetDimTotalingFilter(1, AccSchedLine."Dimension 1 Totaling"));
                                SETFILTER("Global Dimension 2 Code", GetDimTotalingFilter(2, AccSchedLine."Dimension 2 Totaling"));
                                SETFILTER("Global Dimension 3 Code", GetDimTotalingFilter(3, AccSchedLine."Dimension 3 Totaling"));
                                SETFILTER("Global Dimension 4 Code", GetDimTotalingFilter(4, AccSchedLine."Dimension 4 Totaling"));
                                SETFILTER("Global Dimension 5 Code", GetDimTotalingFilter(5, AccSchedLine."Dimension 5 Totaling"));
                                FILTERGROUP(6);
                                SETFILTER("Global Dimension 1 Code", GetDimTotalingFilter(1, ColumnLayout."Dimension 1 Totaling"));
                                SETFILTER("Global Dimension 2 Code", GetDimTotalingFilter(2, ColumnLayout."Dimension 2 Totaling"));
                                SETFILTER("Global Dimension 3 Code", GetDimTotalingFilter(3, ColumnLayout."Dimension 3 Totaling"));
                                SETFILTER("Global Dimension 4 Code", GetDimTotalingFilter(4, ColumnLayout."Dimension 4 Totaling"));
                                SETFILTER("Global Dimension 5 Code", GetDimTotalingFilter(5, ColumnLayout."Dimension 5 Totaling"));

                                SETFILTER("Business Unit Code", ColumnLayout."Business Unit Totaling");
                                FILTERGROUP(0);
                                CASE AmountType OF
                                    AmountType::"Net Amount":
                                        BEGIN
                                            if CalcAddCurr THEN BEGIN
                                                CALCSUMS("Additional-Currency Amount");
                                                ColValue := "Additional-Currency Amount";
                                            END ELSE BEGIN
                                                CALCSUMS(Amount);
                                                ColValue := Amount;
                                            END;
                                            Balance := ColValue;
                                        END;
                                    AmountType::"Debit Amount":
                                        BEGIN
                                            if CalcAddCurr THEN BEGIN
                                                if TestBalance THEN BEGIN
                                                    CALCSUMS("Add.-Currency Debit Amount", "Additional-Currency Amount");
                                                    Balance := "Additional-Currency Amount";
                                                END ELSE
                                                    CALCSUMS("Add.-Currency Debit Amount");
                                                ColValue := "Add.-Currency Debit Amount";
                                            END ELSE BEGIN
                                                if TestBalance THEN BEGIN
                                                    CALCSUMS("Debit Amount", Amount);
                                                    Balance := Amount;
                                                END ELSE
                                                    CALCSUMS("Debit Amount");
                                                ColValue := "Debit Amount";
                                            END;
                                        END;
                                    AmountType::"Credit Amount":
                                        BEGIN
                                            if CalcAddCurr THEN BEGIN
                                                if TestBalance THEN BEGIN
                                                    CALCSUMS("Add.-Currency Credit Amount", "Additional-Currency Amount");
                                                    Balance := "Additional-Currency Amount";
                                                END ELSE
                                                    CALCSUMS("Add.-Currency Credit Amount");
                                                ColValue := "Add.-Currency Credit Amount";
                                            END ELSE BEGIN
                                                if TestBalance THEN BEGIN
                                                    CALCSUMS("Credit Amount", Amount);
                                                    Balance := Amount;
                                                END ELSE
                                                    CALCSUMS("Credit Amount");
                                                ColValue := "Credit Amount";
                                            END;
                                        END;
                                END;
                            END
                        ELSE
                            WITH AnalysisViewEntry DO BEGIN
                                SETRANGE("Analysis View Code", AccSchedName."Analysis View Name");
                                SETRANGE("Account No.", GLAcc."No.");
                                GLAcc.COPYFILTER("Date Filter", "Posting Date");
                                AccSchedLine.COPYFILTER("Business Unit Filter", "Business Unit Code");
                                AccSchedLine.COPYFILTER("Dimension 1 Filter", "Dimension 1 Value Code");
                                AccSchedLine.COPYFILTER("Dimension 2 Filter", "Dimension 2 Value Code");
                                AccSchedLine.COPYFILTER("Dimension 3 Filter", "Dimension 3 Value Code");
                                AccSchedLine.COPYFILTER("Dimension 4 Filter", "Dimension 4 Value Code");
                                AccSchedLine.COPYFILTER("Dimension 5 Filter", "Dimension 5 Value Code");
                                FILTERGROUP(2);
                                SETFILTER("Dimension 1 Value Code", GetDimTotalingFilter(1, AccSchedLine."Dimension 1 Totaling"));
                                SETFILTER("Dimension 2 Value Code", GetDimTotalingFilter(2, AccSchedLine."Dimension 2 Totaling"));
                                SETFILTER("Dimension 3 Value Code", GetDimTotalingFilter(3, AccSchedLine."Dimension 3 Totaling"));
                                SETFILTER("Dimension 4 Value Code", GetDimTotalingFilter(4, AccSchedLine."Dimension 4 Totaling"));
                                SETFILTER("Dimension 5 Value Code", GetDimTotalingFilter(5, AccSchedLine."Dimension 5 Totaling"));
                                FILTERGROUP(6);
                                SETFILTER("Dimension 1 Value Code", GetDimTotalingFilter(1, ColumnLayout."Dimension 1 Totaling"));
                                SETFILTER("Dimension 2 Value Code", GetDimTotalingFilter(2, ColumnLayout."Dimension 2 Totaling"));
                                SETFILTER("Dimension 3 Value Code", GetDimTotalingFilter(3, ColumnLayout."Dimension 3 Totaling"));
                                SETFILTER("Dimension 4 Value Code", GetDimTotalingFilter(4, ColumnLayout."Dimension 4 Totaling"));
                                SETFILTER("Dimension 5 Value Code", GetDimTotalingFilter(5, ColumnLayout."Dimension 5 Totaling"));
                                SETFILTER("Business Unit Code", ColumnLayout."Business Unit Totaling");
                                FILTERGROUP(0);

                                CASE AmountType OF
                                    AmountType::"Net Amount":
                                        BEGIN
                                            if CalcAddCurr THEN BEGIN
                                                CALCSUMS("Add.-Curr. Amount");
                                                ColValue := "Add.-Curr. Amount";
                                            END ELSE BEGIN
                                                CALCSUMS(Amount);
                                                ColValue := Amount;
                                            END;
                                            Balance := ColValue;
                                        END;
                                    AmountType::"Debit Amount":
                                        BEGIN
                                            if CalcAddCurr THEN BEGIN
                                                if TestBalance THEN BEGIN
                                                    CALCSUMS("Add.-Curr. Debit Amount", "Add.-Curr. Amount");
                                                    Balance := "Add.-Curr. Amount";
                                                END ELSE
                                                    CALCSUMS("Add.-Curr. Debit Amount");
                                                ColValue := "Add.-Curr. Debit Amount";
                                            END ELSE BEGIN
                                                if TestBalance THEN BEGIN
                                                    CALCSUMS("Debit Amount", Amount);
                                                    Balance := Amount;
                                                END ELSE
                                                    CALCSUMS("Debit Amount");
                                                ColValue := "Debit Amount";
                                            END;
                                        END;
                                    AmountType::"Credit Amount":
                                        BEGIN
                                            if CalcAddCurr THEN BEGIN
                                                if TestBalance THEN BEGIN
                                                    CALCSUMS("Add.-Curr. Credit Amount", "Add.-Curr. Amount");
                                                    Balance := "Add.-Curr. Amount";
                                                END ELSE
                                                    CALCSUMS("Add.-Curr. Credit Amount");
                                                ColValue := "Add.-Curr. Credit Amount";
                                            END ELSE BEGIN
                                                if TestBalance THEN BEGIN
                                                    CALCSUMS("Credit Amount", Amount);
                                                    Balance := Amount;
                                                END ELSE
                                                    CALCSUMS("Credit Amount");
                                                ColValue := "Credit Amount";
                                            END;
                                        END;
                                END;
                            END;
                    END;

            //   {    ColumnLayout."Ledger Entry Type"::"Budget Entries" :
            //         BEGIN
            //           if AccSchedName."Analysis View Name" = '' THEN
            //             WITH GLBudgEntry DO BEGIN
            //               if UseBusUnitFilter OR UseDimFilter THEN
            //                 SETCURRENTKEY(
            //                   "Budget Name","G/L Account No.","Business Unit Code",
            //                   "Global Dimension 1 Code","Global Dimension 2 Code",
            //                   "Budget Dimension 1 Code","Budget Dimension 2 Code",
            //                   "Budget Dimension 3 Code","Budget Dimension 4 Code",Date)
            //               ELSE
            //                 SETCURRENTKEY("Budget Name","G/L Account No.",Date);
            //               if GLAcc.Totaling = '' THEN
            //                 SETRANGE("G/L Account No.",GLAcc."No.")
            //               ELSE
            //                 SETFILTER("G/L Account No.",GLAcc.Totaling);
            //               GLAcc.COPYFILTER("Date Filter",Date);
            //               AccSchedLine.COPYFILTER("Budget Filter","Budget Name");
            //               AccSchedLine.COPYFILTER("Business Unit Filter","Business Unit Code");
            //               AccSchedLine.COPYFILTER("Dimension 1 Filter","Global Dimension 1 Code");
            //               AccSchedLine.COPYFILTER("Dimension 2 Filter","Global Dimension 2 Code");
            //               AccSchedLine.COPYFILTER("Dimension 3 Filter","Global Dimension 3 Code");
            //               AccSchedLine.COPYFILTER("Dimension 4 Filter","Global Dimension 4 Code");
            //               AccSchedLine.COPYFILTER("Dimension 5 Filter","Global Dimension 5 Code");
            //               FILTERGROUP(2);
            //               SETFILTER("Global Dimension 1 Code",GetDimTotalingFilter(1,AccSchedLine."Dimension 1 Totaling"));
            //               SETFILTER("Global Dimension 2 Code",GetDimTotalingFilter(2,AccSchedLine."Dimension 2 Totaling"));
            //               SETFILTER("Global Dimension 3 Code",GetDimTotalingFilter(3,AccSchedLine."Dimension 3 Totaling"));
            //               SETFILTER("Global Dimension 4 Code",GetDimTotalingFilter(4,AccSchedLine."Dimension 4 Totaling"));
            //               SETFILTER("Global Dimension 5 Code",GetDimTotalingFilter(5,AccSchedLine."Dimension 5 Totaling"));
            //               FILTERGROUP(6);
            //               SETFILTER("Global Dimension 1 Code",GetDimTotalingFilter(1,ColumnLayout."Dimension 1 Totaling"));
            //               SETFILTER("Global Dimension 2 Code",GetDimTotalingFilter(2,ColumnLayout."Dimension 2 Totaling"));
            //               SETFILTER("Global Dimension 3 Code",GetDimTotalingFilter(3,ColumnLayout."Dimension 3 Totaling"));
            //               SETFILTER("Global Dimension 4 Code",GetDimTotalingFilter(4,ColumnLayout."Dimension 4 Totaling"));
            //               SETFILTER("Global Dimension 5 Code",GetDimTotalingFilter(5,ColumnLayout."Dimension 5 Totaling"));
            //               SETFILTER("Business Unit Code",ColumnLayout."Business Unit Totaling");
            //               FILTERGROUP(0);

            //               CASE AmountType OF
            //                 AmountType::"Net Amount" :
            //                   BEGIN
            //                     CALCSUMS(Amount);
            //                     ColValue := Amount;
            //                   END;
            //                 AmountType::"Debit Amount" :
            //                   BEGIN
            //                     CALCSUMS(Amount);
            //                     ColValue := Amount;
            //                     if ColValue < 0 THEN
            //                       ColValue := 0;
            //                   END;
            //                 AmountType::"Credit Amount" :
            //                   BEGIN
            //                     CALCSUMS(Amount);
            //                     ColValue := -Amount;
            //                     if ColValue < 0 THEN
            //                       ColValue := 0;
            //                   END;
            //               END;
            //               Balance := Amount;
            //             END
            //           ELSE
            //             WITH AnalysisViewBudgetEntry DO BEGIN
            //               if GLAcc.Totaling = '' THEN
            //                 SETRANGE("G/L Account No.",GLAcc."No.")
            //               ELSE
            //                 SETFILTER("G/L Account No.",GLAcc.Totaling);
            //               SETRANGE("Analysis View Code",AccSchedName."Analysis View Name");
            //               GLAcc.COPYFILTER("Date Filter","Posting Date");
            //               AccSchedLine.COPYFILTER("Budget Filter","Budget Name");
            //               AccSchedLine.COPYFILTER("Business Unit Filter","Business Unit Code");
            //               AccSchedLine.COPYFILTER("Dimension 1 Filter","Dimension 1 Value Code");
            //               AccSchedLine.COPYFILTER("Dimension 2 Filter","Dimension 2 Value Code");
            //               AccSchedLine.COPYFILTER("Dimension 3 Filter","Dimension 3 Value Code");
            //               AccSchedLine.COPYFILTER("Dimension 4 Filter","Dimension 4 Value Code");
            //               AccSchedLine.COPYFILTER("Dimension 5 Filter","Dimension 5 Value Code");
            //               FILTERGROUP(2);
            //               SETFILTER("Dimension 1 Value Code",GetDimTotalingFilter(1,AccSchedLine."Dimension 1 Totaling"));
            //               SETFILTER("Dimension 2 Value Code",GetDimTotalingFilter(2,AccSchedLine."Dimension 2 Totaling"));
            //               SETFILTER("Dimension 3 Value Code",GetDimTotalingFilter(3,AccSchedLine."Dimension 3 Totaling"));
            //               SETFILTER("Dimension 4 Value Code",GetDimTotalingFilter(4,AccSchedLine."Dimension 4 Totaling"));
            //               SETFILTER("Dimension 5 Value Code",GetDimTotalingFilter(5,AccSchedLine."Dimension 5 Totaling"));
            //               FILTERGROUP(6);
            //               SETFILTER("Dimension 1 Value Code",GetDimTotalingFilter(1,ColumnLayout."Dimension 1 Totaling"));
            //               SETFILTER("Dimension 2 Value Code",GetDimTotalingFilter(2,ColumnLayout."Dimension 2 Totaling"));
            //               SETFILTER("Dimension 3 Value Code",GetDimTotalingFilter(3,ColumnLayout."Dimension 3 Totaling"));
            //               SETFILTER("Dimension 4 Value Code",GetDimTotalingFilter(4,ColumnLayout."Dimension 4 Totaling"));
            //               SETFILTER("Dimension 5 Value Code",GetDimTotalingFilter(5,ColumnLayout."Dimension 5 Totaling"));
            //               SETFILTER("Business Unit Code",ColumnLayout."Business Unit Totaling");
            //               FILTERGROUP(0);

            //               CASE AmountType OF
            //                 AmountType::"Net Amount" :
            //                   BEGIN
            //                     CALCSUMS("Amount (LCY)");
            //                     ColValue := "Amount (LCY)";
            //                   END;
            //                 AmountType::"Debit Amount (LCY)" :
            //                   BEGIN
            //                     CALCSUMS("Amount (LCY)");
            //                     ColValue := "Amount (LCY)";
            //                     if ColValue < 0 THEN
            //                       ColValue := 0;
            //                   END;
            //                 AmountType::"Credit Amount (LCY)" :
            //                   BEGIN
            //                     CALCSUMS("Amount (LCY)");
            //                     ColValue := -"Amount (LCY)";
            //                     if ColValue < 0 THEN
            //                       ColValue := 0;
            //                   END;
            //               END;
            //               Balance := "Amount (LCY)";
            //             END;
            //           if CalcAddCurr THEN BEGIN
            //             if NOT GLSetupRead THEN BEGIN
            //               GLSetup.GET;
            //               GLSetupRead := TRUE;
            //               if GLSetup."Additional Reporting Currency" <> '' THEN
            //                 AddRepCurrency.GET(GLSetup."Additional Reporting Currency");
            //             END;
            //             if GLSetup."Additional Reporting Currency" <> '' THEN
            //               ColValue := ROUND(ExchangeAmtAddCurrToLCY(ColValue),AddRepCurrency."Amount Rounding Precision")
            //             ELSE
            //               ColValue := 0;
            //           END;
            //         END;}
            END;
            if TestBalance THEN BEGIN
                if AccSchedLine.Show = AccSchedLine.Show::"When Positive Balance" THEN
                    if Balance < 0 THEN
                        EXIT(0);
                if AccSchedLine.Show = AccSchedLine.Show::"When Negative Balance" THEN
                    if Balance > 0 THEN
                        EXIT(0);
            END;
        END;
        EXIT(ColValue);
    END;

    LOCAL PROCEDURE CalcCuAcc(VAR GLAcc: Record Customer; VAR AccSchedLine: Record 85; VAR ColumnLayout: Record 334; CalcAddCurr: Boolean) ColValue: Decimal;
    VAR
        GLEntry: Record "G/L Entry";
        GLBudgEntry: Record 96;
        AnalysisViewEntry: Record "Analysis View Entry";
        AnalysisViewBudgetEntry: Record "Analysis View Budget Entry";
        AmountType: Option "Net Amount","Debit Amount","Credit Amount";
        TestBalance: Boolean;
        Balance: Decimal;
        UseBusUnitFilter: Boolean;
        UseDimFilter: Boolean;
    BEGIN
        //ASC 09/12/09
        if ColumnLayout.Empresa <> '' then
            if not Contrl.Permiso_Empresas(ColumnLayout.Empresa) then exit(0);
        if ColumnLayout.Empresa <> '' THEN
            GLEntry.CHANGECOMPANY(ColumnLayout.Empresa);
        if AccSchedLine.Company <> '' THEN
            GLEntry.CHANGECOMPANY(AccSchedLine.Company);
        if (ColumnLayout.Empresa <> '') AND
         (AccSchedLine.Company <> '') AND
         (AccSchedLine.Company <> ColumnLayout.Empresa) THEN
            EXIT(0);
        ColValue := 0;
        GLEntry.SETFILTER(GLEntry."G/L Account No.", '%1..%2|%3..%4|%5..%6|%7..%8|%9..%9',
        '4300', '4305:', '431', '432:', '433', '434:', '4370', '4371:', '440', '449:');
        if AccSchedName.Name <> AccSchedLine."Schedule Name" THEN
            AccSchedName.GET(AccSchedLine."Schedule Name");
        AmountType := ColumnLayout."Amount Type".AsInteger();
        CASE AccSchedLine."Amount Type" OF
            AccSchedLine."Amount Type"::"Debit Amount":
                CASE AmountType OF
                    AmountType::"Net Amount":
                        AmountType := AmountType::"Debit Amount";
                    AmountType::"Credit Amount":
                        EXIT(0);
                END;
            AccSchedLine."Amount Type"::"Credit Amount":
                CASE AmountType OF
                    AmountType::"Net Amount":
                        AmountType := AmountType::"Credit Amount";
                    AmountType::"Debit Amount":
                        EXIT(0);
                END;
        END;
        TestBalance :=
          AccSchedLine.Show IN [AccSchedLine.Show::"When Positive Balance", AccSchedLine.Show::"When Negative Balance"];
        if ColumnLayout."Column Type" <> ColumnLayout."Column Type"::Formula THEN BEGIN
            UseBusUnitFilter := (AccSchedLine.GETFILTER("Business Unit Filter") <> '') OR (ColumnLayout."Business Unit Totaling" <> '');
            UseDimFilter :=
              (AccSchedLine."Dimension 1 Totaling" <> '') OR
              (AccSchedLine."Dimension 2 Totaling" <> '') OR
              (AccSchedLine."Dimension 3 Totaling" <> '') OR
              (AccSchedLine."Dimension 4 Totaling" <> '') OR
              (AccSchedLine."Dimension 5 Totaling" <> '') OR
              (AccSchedLine.GETFILTER("Dimension 1 Filter") <> '') OR
              (AccSchedLine.GETFILTER("Dimension 2 Filter") <> '') OR
              (AccSchedLine.GETFILTER("Dimension 3 Filter") <> '') OR
              (AccSchedLine.GETFILTER("Dimension 4 Filter") <> '') OR
              (AccSchedLine.GETFILTER("Dimension 5 Filter") <> '') OR
              (ColumnLayout."Dimension 1 Totaling" <> '') OR
              (ColumnLayout."Dimension 2 Totaling" <> '') OR
              (ColumnLayout."Dimension 3 Totaling" <> '') OR
              (ColumnLayout."Dimension 4 Totaling" <> '') OR
              (ColumnLayout."Dimension 5 Totaling" <> '');
            CASE ColumnLayout."Ledger Entry Type" OF
                ColumnLayout."Ledger Entry Type"::Entries:
                    BEGIN
                        if AccSchedName."Analysis View Name" = '' THEN
                            WITH GLEntry DO BEGIN
                                if UseBusUnitFilter THEN
                                    if UseDimFilter THEN
                                        SETCURRENTKEY(
                                          "G/L Account No.", "Source Type", "Source No.", "Posting Date", "Document Type")
                                    ELSE
                                        SETCURRENTKEY(
                                          "G/L Account No.", "Source Type", "Source No.", "Posting Date", "Document Type")
                                ELSE
                                    if UseDimFilter THEN
                                        SETCURRENTKEY("G/L Account No.", "Source Type", "Source No.", "Posting Date", "Document Type")
                                    ELSE
                                        SETCURRENTKEY("G/L Account No.", "Source Type", "Source No.", "Posting Date", "Document Type");
                                SETRANGE("Source No.", GLAcc."No.");
                                GLAcc.COPYFILTER("Date Filter", "Posting Date");
                                AccSchedLine.COPYFILTER("Business Unit Filter", "Business Unit Code");
                                AccSchedLine.COPYFILTER("Dimension 1 Filter", "Global Dimension 1 Code");
                                AccSchedLine.COPYFILTER("Dimension 2 Filter", "Global Dimension 2 Code");
                                AccSchedLine.COPYFILTER("Dimension 3 Filter", "Global Dimension 3 Code");
                                AccSchedLine.COPYFILTER("Dimension 4 Filter", "Global Dimension 4 Code");
                                AccSchedLine.COPYFILTER("Dimension 5 Filter", "Global Dimension 5 Code");
                                FILTERGROUP(2);
                                SETFILTER("Global Dimension 1 Code", GetDimTotalingFilter(1, AccSchedLine."Dimension 1 Totaling"));
                                SETFILTER("Global Dimension 2 Code", GetDimTotalingFilter(2, AccSchedLine."Dimension 2 Totaling"));
                                SETFILTER("Global Dimension 3 Code", GetDimTotalingFilter(3, AccSchedLine."Dimension 3 Totaling"));
                                SETFILTER("Global Dimension 4 Code", GetDimTotalingFilter(4, AccSchedLine."Dimension 4 Totaling"));
                                SETFILTER("Global Dimension 5 Code", GetDimTotalingFilter(5, AccSchedLine."Dimension 5 Totaling"));
                                FILTERGROUP(6);
                                SETFILTER("Global Dimension 1 Code", GetDimTotalingFilter(1, ColumnLayout."Dimension 1 Totaling"));
                                SETFILTER("Global Dimension 2 Code", GetDimTotalingFilter(2, ColumnLayout."Dimension 2 Totaling"));
                                SETFILTER("Global Dimension 3 Code", GetDimTotalingFilter(3, ColumnLayout."Dimension 3 Totaling"));
                                SETFILTER("Global Dimension 4 Code", GetDimTotalingFilter(4, ColumnLayout."Dimension 4 Totaling"));
                                SETFILTER("Global Dimension 5 Code", GetDimTotalingFilter(5, ColumnLayout."Dimension 5 Totaling"));
                                SETFILTER("Business Unit Code", ColumnLayout."Business Unit Totaling");
                                FILTERGROUP(0);
                                CASE AmountType OF
                                    AmountType::"Net Amount":
                                        BEGIN
                                            if CalcAddCurr THEN BEGIN
                                                CALCSUMS("Additional-Currency Amount");
                                                ColValue := "Additional-Currency Amount";
                                            END ELSE BEGIN
                                                CALCSUMS(Amount);
                                                ColValue := Amount;
                                            END;
                                            Balance := ColValue;
                                        END;
                                    AmountType::"Debit Amount":
                                        BEGIN
                                            if CalcAddCurr THEN BEGIN
                                                if TestBalance THEN BEGIN
                                                    CALCSUMS("Add.-Currency Debit Amount", "Additional-Currency Amount");
                                                    Balance := "Additional-Currency Amount";
                                                END ELSE
                                                    CALCSUMS("Add.-Currency Debit Amount");
                                                ColValue := "Add.-Currency Debit Amount";
                                            END ELSE BEGIN
                                                if TestBalance THEN BEGIN
                                                    CALCSUMS("Debit Amount", Amount);
                                                    Balance := Amount;
                                                END ELSE
                                                    CALCSUMS("Debit Amount");
                                                ColValue := "Debit Amount";
                                            END;
                                        END;
                                    AmountType::"Credit Amount":
                                        BEGIN
                                            if CalcAddCurr THEN BEGIN
                                                if TestBalance THEN BEGIN
                                                    CALCSUMS("Add.-Currency Credit Amount", "Additional-Currency Amount");
                                                    Balance := "Additional-Currency Amount";
                                                END ELSE
                                                    CALCSUMS("Add.-Currency Credit Amount");
                                                ColValue := "Add.-Currency Credit Amount";
                                            END ELSE BEGIN
                                                if TestBalance THEN BEGIN
                                                    CALCSUMS("Credit Amount", Amount);
                                                    Balance := Amount;
                                                END ELSE
                                                    CALCSUMS("Credit Amount");
                                                ColValue := "Credit Amount";
                                            END;
                                        END;
                                END;
                            END
                        ELSE
                            WITH AnalysisViewEntry DO BEGIN
                                SETRANGE("Analysis View Code", AccSchedName."Analysis View Name");
                                SETRANGE("Account No.", GLAcc."No.");
                                GLAcc.COPYFILTER("Date Filter", "Posting Date");
                                AccSchedLine.COPYFILTER("Business Unit Filter", "Business Unit Code");
                                AccSchedLine.COPYFILTER("Dimension 1 Filter", "Dimension 1 Value Code");
                                AccSchedLine.COPYFILTER("Dimension 2 Filter", "Dimension 2 Value Code");
                                AccSchedLine.COPYFILTER("Dimension 3 Filter", "Dimension 3 Value Code");
                                AccSchedLine.COPYFILTER("Dimension 4 Filter", "Dimension 4 Value Code");
                                AccSchedLine.COPYFILTER("Dimension 5 Filter", "Dimension 5 Value Code");
                                FILTERGROUP(2);
                                SETFILTER("Dimension 1 Value Code", GetDimTotalingFilter(1, AccSchedLine."Dimension 1 Totaling"));
                                SETFILTER("Dimension 2 Value Code", GetDimTotalingFilter(2, AccSchedLine."Dimension 2 Totaling"));
                                SETFILTER("Dimension 3 Value Code", GetDimTotalingFilter(3, AccSchedLine."Dimension 3 Totaling"));
                                SETFILTER("Dimension 4 Value Code", GetDimTotalingFilter(4, AccSchedLine."Dimension 4 Totaling"));
                                SETFILTER("Dimension 5 Value Code", GetDimTotalingFilter(5, AccSchedLine."Dimension 5 Totaling"));
                                FILTERGROUP(6);
                                SETFILTER("Dimension 1 Value Code", GetDimTotalingFilter(1, ColumnLayout."Dimension 1 Totaling"));
                                SETFILTER("Dimension 2 Value Code", GetDimTotalingFilter(2, ColumnLayout."Dimension 2 Totaling"));
                                SETFILTER("Dimension 3 Value Code", GetDimTotalingFilter(3, ColumnLayout."Dimension 3 Totaling"));
                                SETFILTER("Dimension 4 Value Code", GetDimTotalingFilter(4, ColumnLayout."Dimension 4 Totaling"));
                                SETFILTER("Dimension 5 Value Code", GetDimTotalingFilter(5, ColumnLayout."Dimension 5 Totaling"));
                                SETFILTER("Business Unit Code", ColumnLayout."Business Unit Totaling");
                                FILTERGROUP(0);

                                CASE AmountType OF
                                    AmountType::"Net Amount":
                                        BEGIN
                                            if CalcAddCurr THEN BEGIN
                                                CALCSUMS("Add.-Curr. Amount");
                                                ColValue := "Add.-Curr. Amount";
                                            END ELSE BEGIN
                                                CALCSUMS(Amount);
                                                ColValue := Amount;
                                            END;
                                            Balance := ColValue;
                                        END;
                                    AmountType::"Debit Amount":
                                        BEGIN
                                            if CalcAddCurr THEN BEGIN
                                                if TestBalance THEN BEGIN
                                                    CALCSUMS("Add.-Curr. Debit Amount", "Add.-Curr. Amount");
                                                    Balance := "Add.-Curr. Amount";
                                                END ELSE
                                                    CALCSUMS("Add.-Curr. Debit Amount");
                                                ColValue := "Add.-Curr. Debit Amount";
                                            END ELSE BEGIN
                                                if TestBalance THEN BEGIN
                                                    CALCSUMS("Debit Amount", Amount);
                                                    Balance := Amount;
                                                END ELSE
                                                    CALCSUMS("Debit Amount");
                                                ColValue := "Debit Amount";
                                            END;
                                        END;
                                    AmountType::"Credit Amount":
                                        BEGIN
                                            if CalcAddCurr THEN BEGIN
                                                if TestBalance THEN BEGIN
                                                    CALCSUMS("Add.-Curr. Credit Amount", "Add.-Curr. Amount");
                                                    Balance := "Add.-Curr. Amount";
                                                END ELSE
                                                    CALCSUMS("Add.-Curr. Credit Amount");
                                                ColValue := "Add.-Curr. Credit Amount";
                                            END ELSE BEGIN
                                                if TestBalance THEN BEGIN
                                                    CALCSUMS("Credit Amount", Amount);
                                                    Balance := Amount;
                                                END ELSE
                                                    CALCSUMS("Credit Amount");
                                                ColValue := "Credit Amount";
                                            END;
                                        END;
                                END;
                            END;
                    END;

            //   {    ColumnLayout."Ledger Entry Type"::"Budget Entries" :
            //         BEGIN
            //           if AccSchedName."Analysis View Name" = '' THEN
            //             WITH GLBudgEntry DO BEGIN
            //               if UseBusUnitFilter OR UseDimFilter THEN
            //                 SETCURRENTKEY(
            //                   "Budget Name","G/L Account No.","Business Unit Code",
            //                   "Global Dimension 1 Code","Global Dimension 2 Code",
            //                   "Budget Dimension 1 Code","Budget Dimension 2 Code",
            //                   "Budget Dimension 3 Code","Budget Dimension 4 Code",Date)
            //               ELSE
            //                 SETCURRENTKEY("Budget Name","G/L Account No.",Date);
            //               if GLAcc.Totaling = '' THEN
            //                 SETRANGE("G/L Account No.",GLAcc."No.")
            //               ELSE
            //                 SETFILTER("G/L Account No.",GLAcc.Totaling);
            //               GLAcc.COPYFILTER("Date Filter",Date);
            //               AccSchedLine.COPYFILTER("Budget Filter","Budget Name");
            //               AccSchedLine.COPYFILTER("Business Unit Filter","Business Unit Code");
            //               AccSchedLine.COPYFILTER("Dimension 1 Filter","Global Dimension 1 Code");
            //               AccSchedLine.COPYFILTER("Dimension 2 Filter","Global Dimension 2 Code");
            //               AccSchedLine.COPYFILTER("Dimension 3 Filter","Global Dimension 3 Code");
            //               AccSchedLine.COPYFILTER("Dimension 4 Filter","Global Dimension 4 Code");
            //               AccSchedLine.COPYFILTER("Dimension 5 Filter","Global Dimension 5 Code");
            //               FILTERGROUP(2);
            //               SETFILTER("Global Dimension 1 Code",GetDimTotalingFilter(1,AccSchedLine."Dimension 1 Totaling"));
            //               SETFILTER("Global Dimension 2 Code",GetDimTotalingFilter(2,AccSchedLine."Dimension 2 Totaling"));
            //               SETFILTER("Global Dimension 3 Code",GetDimTotalingFilter(3,AccSchedLine."Dimension 3 Totaling"));
            //               SETFILTER("Global Dimension 4 Code",GetDimTotalingFilter(4,AccSchedLine."Dimension 4 Totaling"));
            //               SETFILTER("Global Dimension 5 Code",GetDimTotalingFilter(5,AccSchedLine."Dimension 5 Totaling"));
            //               FILTERGROUP(6);
            //               SETFILTER("Global Dimension 1 Code",GetDimTotalingFilter(1,ColumnLayout."Dimension 1 Totaling"));
            //               SETFILTER("Global Dimension 2 Code",GetDimTotalingFilter(2,ColumnLayout."Dimension 2 Totaling"));
            //               SETFILTER("Global Dimension 3 Code",GetDimTotalingFilter(3,ColumnLayout."Dimension 3 Totaling"));
            //               SETFILTER("Global Dimension 4 Code",GetDimTotalingFilter(4,ColumnLayout."Dimension 4 Totaling"));
            //               SETFILTER("Global Dimension 5 Code",GetDimTotalingFilter(5,ColumnLayout."Dimension 5 Totaling"));
            //               SETFILTER("Business Unit Code",ColumnLayout."Business Unit Totaling");
            //               FILTERGROUP(0);

            //               CASE AmountType OF
            //                 AmountType::"Net Amount" :
            //                   BEGIN
            //                     CALCSUMS(Amount);
            //                     ColValue := Amount;
            //                   END;
            //                 AmountType::"Debit Amount" :
            //                   BEGIN
            //                     CALCSUMS(Amount);
            //                     ColValue := Amount;
            //                     if ColValue < 0 THEN
            //                       ColValue := 0;
            //                   END;
            //                 AmountType::"Credit Amount" :
            //                   BEGIN
            //                     CALCSUMS(Amount);
            //                     ColValue := -Amount;
            //                     if ColValue < 0 THEN
            //                       ColValue := 0;
            //                   END;
            //               END;
            //               Balance := Amount;
            //             END
            //           ELSE
            //             WITH AnalysisViewBudgetEntry DO BEGIN
            //               if GLAcc.Totaling = '' THEN
            //                 SETRANGE("G/L Account No.",GLAcc."No.")
            //               ELSE
            //                 SETFILTER("G/L Account No.",GLAcc.Totaling);
            //               SETRANGE("Analysis View Code",AccSchedName."Analysis View Name");
            //               GLAcc.COPYFILTER("Date Filter","Posting Date");
            //               AccSchedLine.COPYFILTER("Budget Filter","Budget Name");
            //               AccSchedLine.COPYFILTER("Business Unit Filter","Business Unit Code");
            //               AccSchedLine.COPYFILTER("Dimension 1 Filter","Dimension 1 Value Code");
            //               AccSchedLine.COPYFILTER("Dimension 2 Filter","Dimension 2 Value Code");
            //               AccSchedLine.COPYFILTER("Dimension 3 Filter","Dimension 3 Value Code");
            //               AccSchedLine.COPYFILTER("Dimension 4 Filter","Dimension 4 Value Code");
            //               AccSchedLine.COPYFILTER("Dimension 5 Filter","Dimension 5 Value Code");
            //               FILTERGROUP(2);
            //               SETFILTER("Dimension 1 Value Code",GetDimTotalingFilter(1,AccSchedLine."Dimension 1 Totaling"));
            //               SETFILTER("Dimension 2 Value Code",GetDimTotalingFilter(2,AccSchedLine."Dimension 2 Totaling"));
            //               SETFILTER("Dimension 3 Value Code",GetDimTotalingFilter(3,AccSchedLine."Dimension 3 Totaling"));
            //               SETFILTER("Dimension 4 Value Code",GetDimTotalingFilter(4,AccSchedLine."Dimension 4 Totaling"));
            //               SETFILTER("Dimension 5 Value Code",GetDimTotalingFilter(5,AccSchedLine."Dimension 5 Totaling"));
            //               FILTERGROUP(6);
            //               SETFILTER("Dimension 1 Value Code",GetDimTotalingFilter(1,ColumnLayout."Dimension 1 Totaling"));
            //               SETFILTER("Dimension 2 Value Code",GetDimTotalingFilter(2,ColumnLayout."Dimension 2 Totaling"));
            //               SETFILTER("Dimension 3 Value Code",GetDimTotalingFilter(3,ColumnLayout."Dimension 3 Totaling"));
            //               SETFILTER("Dimension 4 Value Code",GetDimTotalingFilter(4,ColumnLayout."Dimension 4 Totaling"));
            //               SETFILTER("Dimension 5 Value Code",GetDimTotalingFilter(5,ColumnLayout."Dimension 5 Totaling"));
            //               SETFILTER("Business Unit Code",ColumnLayout."Business Unit Totaling");
            //               FILTERGROUP(0);

            //               CASE AmountType OF
            //                 AmountType::"Net Amount" :
            //                   BEGIN
            //                     CALCSUMS("Amount (LCY)");
            //                     ColValue := "Amount (LCY)";
            //                   END;
            //                 AmountType::"Debit Amount (LCY)" :
            //                   BEGIN
            //                     CALCSUMS("Amount (LCY)");
            //                     ColValue := "Amount (LCY)";
            //                     if ColValue < 0 THEN
            //                       ColValue := 0;
            //                   END;
            //                 AmountType::"Credit Amount (LCY)" :
            //                   BEGIN
            //                     CALCSUMS("Amount (LCY)");
            //                     ColValue := -"Amount (LCY)";
            //                     if ColValue < 0 THEN
            //                       ColValue := 0;
            //                   END;
            //               END;
            //               Balance := "Amount (LCY)";
            //             END;
            //           if CalcAddCurr THEN BEGIN
            //             if NOT GLSetupRead THEN BEGIN
            //               GLSetup.GET;
            //               GLSetupRead := TRUE;
            //               if GLSetup."Additional Reporting Currency" <> '' THEN
            //                 AddRepCurrency.GET(GLSetup."Additional Reporting Currency");
            //             END;
            //             if GLSetup."Additional Reporting Currency" <> '' THEN
            //               ColValue := ROUND(ExchangeAmtAddCurrToLCY(ColValue),AddRepCurrency."Amount Rounding Precision")
            //             ELSE
            //               ColValue := 0;
            //           END;
            //         END;}
            END;
            if TestBalance THEN BEGIN
                if AccSchedLine.Show = AccSchedLine.Show::"When Positive Balance" THEN
                    if Balance < 0 THEN
                        EXIT(0);
                if AccSchedLine.Show = AccSchedLine.Show::"When Negative Balance" THEN
                    if Balance > 0 THEN
                        EXIT(0);
            END;
        END;
        EXIT(ColValue);
    END;

    PROCEDURE SetVeAccRowFilters(VAR GLAcc: Record Vendor; VAR AccSchedLine2: Record 85);
    BEGIN
        WITH AccSchedLine2 DO BEGIN
            GLAcc.SETFILTER("No.", Totaling);
        END;
    END;

    PROCEDURE SetVeAccColumnFilters(VAR GLAcc: Record Vendor; AccSchedLine2: Record 85; VAR ColumnLayout: Record 334);
    VAR
        FromDate: Date;
        ToDate: Date;
        FiscalStartDate2: Date;
    BEGIN
        WITH ColumnLayout DO BEGIN
            if (FORMAT("Comparison Date Formula") <> '0') AND (FORMAT("Comparison Date Formula") <> '') THEN BEGIN
                FromDate := CALCDATE("Comparison Date Formula", StartDate);
                if (EndDate = CALCDATE('<CM>', EndDate)) AND
                   ((STRPOS(FORMAT("Comparison Date Formula"), Text005) > 0) OR
                    (STRPOS(FORMAT("Comparison Date Formula"), Text006) > 0) OR
                    (STRPOS(FORMAT("Comparison Date Formula"), Text007) > 0))
                THEN
                    ToDate := CALCDATE('<CM>', CALCDATE("Comparison Date Formula", EndDate))
                ELSE
                    ToDate := CALCDATE("Comparison Date Formula", EndDate);
                FiscalStartDate2 := FindFiscalYear(ToDate);
            END ELSE
                if "Comparison Period Formula" <> '' THEN BEGIN
                    AccPeriodStartEnd("Comparison Period Formula", StartDate, FromDate, ToDate);
                    FiscalStartDate2 := FindFiscalYear(ToDate);
                END ELSE BEGIN
                    FromDate := StartDate;
                    ToDate := EndDate;
                    FiscalStartDate2 := FiscalStartDate;
                END;
            CASE "Column Type" OF
                "Column Type"::"Net Change":
                    CASE AccSchedLine2."Row Type" OF
                        AccSchedLine2."Row Type"::"Net Change":
                            GLAcc.SETRANGE("Date Filter", FromDate, ToDate);
                        AccSchedLine2."Row Type"::"Beginning Balance":
                            GLAcc.SETFILTER("Date Filter", '<%1', FromDate);  // always includes closing date
                        AccSchedLine2."Row Type"::"Balance at Date":
                            GLAcc.SETRANGE("Date Filter", 0D, ToDate);
                    END;
                "Column Type"::"Balance at Date":
                    if AccSchedLine2."Row Type" = AccSchedLine2."Row Type"::"Beginning Balance" THEN
                        GLAcc.SETRANGE("Date Filter", 0D)   // Force a zero return
                    ELSE
                        GLAcc.SETRANGE("Date Filter", 0D, ToDate);
                "Column Type"::"Beginning Balance":
                    if AccSchedLine2."Row Type" = AccSchedLine2."Row Type"::"Balance at Date" THEN
                        GLAcc.SETRANGE("Date Filter", 0D)   // Force a zero return
                    ELSE
                        GLAcc.SETRANGE(
                          "Date Filter", 0D, CLOSINGDATE(FromDate - 1));
                "Column Type"::"Year to Date":
                    CASE AccSchedLine2."Row Type" OF
                        AccSchedLine2."Row Type"::"Net Change":
                            GLAcc.SETRANGE("Date Filter", FiscalStartDate2, ToDate);
                        AccSchedLine2."Row Type"::"Beginning Balance":
                            GLAcc.SETFILTER("Date Filter", '<%1', FiscalStartDate2);  // always includes closing date
                        AccSchedLine2."Row Type"::"Balance at Date":
                            GLAcc.SETRANGE("Date Filter", 0D, ToDate);
                    END;
                "Column Type"::"Rest of Fiscal Year":
                    CASE AccSchedLine2."Row Type" OF
                        AccSchedLine2."Row Type"::"Net Change":
                            GLAcc.SETRANGE(
                              "Date Filter", CALCDATE('<+1D>', ToDate), FindEndOfFiscalYear(FiscalStartDate2));
                        AccSchedLine2."Row Type"::"Beginning Balance":
                            GLAcc.SETRANGE("Date Filter", 0D, ToDate);
                        AccSchedLine2."Row Type"::"Balance at Date":
                            GLAcc.SETRANGE("Date Filter", 0D, FindEndOfFiscalYear(ToDate));
                    END;
                "Column Type"::"Entire Fiscal Year":
                    CASE AccSchedLine2."Row Type" OF
                        AccSchedLine2."Row Type"::"Net Change":
                            GLAcc.SETRANGE(
                              "Date Filter",
                              FiscalStartDate2,
                              FindEndOfFiscalYear(FiscalStartDate2));
                        AccSchedLine2."Row Type"::"Beginning Balance":
                            GLAcc.SETFILTER("Date Filter", '<%1', FiscalStartDate2);  // always includes closing date
                        AccSchedLine2."Row Type"::"Balance at Date":
                            GLAcc.SETRANGE("Date Filter", 0D, FindEndOfFiscalYear(ToDate));
                    END;
            END;
        END;
    END;

    PROCEDURE SetCuAccRowFilters(VAR GLAcc: Record Customer; VAR AccSchedLine2: Record 85);
    BEGIN
        WITH AccSchedLine2 DO BEGIN
            GLAcc.SETFILTER("No.", Totaling);
        END;
    END;

    PROCEDURE SetCuAccColumnFilters(VAR GLAcc: Record Customer; AccSchedLine2: Record 85; VAR ColumnLayout: Record 334);
    VAR
        FromDate: Date;
        ToDate: Date;
        FiscalStartDate2: Date;
    BEGIN
        WITH ColumnLayout DO BEGIN
            if (FORMAT("Comparison Date Formula") <> '0') AND (FORMAT("Comparison Date Formula") <> '') THEN BEGIN
                FromDate := CALCDATE("Comparison Date Formula", StartDate);
                if (EndDate = CALCDATE('<CM>', EndDate)) AND
                   ((STRPOS(FORMAT("Comparison Date Formula"), Text005) > 0) OR
                    (STRPOS(FORMAT("Comparison Date Formula"), Text006) > 0) OR
                    (STRPOS(FORMAT("Comparison Date Formula"), Text007) > 0))
                THEN
                    ToDate := CALCDATE('<CM>', CALCDATE("Comparison Date Formula", EndDate))
                ELSE
                    ToDate := CALCDATE("Comparison Date Formula", EndDate);
                FiscalStartDate2 := FindFiscalYear(ToDate);
            END ELSE
                if "Comparison Period Formula" <> '' THEN BEGIN
                    AccPeriodStartEnd("Comparison Period Formula", StartDate, FromDate, ToDate);
                    FiscalStartDate2 := FindFiscalYear(ToDate);
                END ELSE BEGIN
                    FromDate := StartDate;
                    ToDate := EndDate;
                    FiscalStartDate2 := FiscalStartDate;
                END;
            CASE "Column Type" OF
                "Column Type"::"Net Change":
                    CASE AccSchedLine2."Row Type" OF
                        AccSchedLine2."Row Type"::"Net Change":
                            GLAcc.SETRANGE("Date Filter", FromDate, ToDate);
                        AccSchedLine2."Row Type"::"Beginning Balance":
                            GLAcc.SETFILTER("Date Filter", '<%1', FromDate);  // always includes closing date
                        AccSchedLine2."Row Type"::"Balance at Date":
                            GLAcc.SETRANGE("Date Filter", 0D, ToDate);
                    END;
                "Column Type"::"Balance at Date":
                    if AccSchedLine2."Row Type" = AccSchedLine2."Row Type"::"Beginning Balance" THEN
                        GLAcc.SETRANGE("Date Filter", 0D)   // Force a zero return
                    ELSE
                        GLAcc.SETRANGE("Date Filter", 0D, ToDate);
                "Column Type"::"Beginning Balance":
                    if AccSchedLine2."Row Type" = AccSchedLine2."Row Type"::"Balance at Date" THEN
                        GLAcc.SETRANGE("Date Filter", 0D)   // Force a zero return
                    ELSE
                        GLAcc.SETRANGE(
                          "Date Filter", 0D, CLOSINGDATE(FromDate - 1));
                "Column Type"::"Year to Date":
                    CASE AccSchedLine2."Row Type" OF
                        AccSchedLine2."Row Type"::"Net Change":
                            GLAcc.SETRANGE("Date Filter", FiscalStartDate2, ToDate);
                        AccSchedLine2."Row Type"::"Beginning Balance":
                            GLAcc.SETFILTER("Date Filter", '<%1', FiscalStartDate2);  // always includes closing date
                        AccSchedLine2."Row Type"::"Balance at Date":
                            GLAcc.SETRANGE("Date Filter", 0D, ToDate);
                    END;
                "Column Type"::"Rest of Fiscal Year":
                    CASE AccSchedLine2."Row Type" OF
                        AccSchedLine2."Row Type"::"Net Change":
                            GLAcc.SETRANGE(
                              "Date Filter", CALCDATE('<+1D>', ToDate), FindEndOfFiscalYear(FiscalStartDate2));
                        AccSchedLine2."Row Type"::"Beginning Balance":
                            GLAcc.SETRANGE("Date Filter", 0D, ToDate);
                        AccSchedLine2."Row Type"::"Balance at Date":
                            GLAcc.SETRANGE("Date Filter", 0D, FindEndOfFiscalYear(ToDate));
                    END;
                "Column Type"::"Entire Fiscal Year":
                    CASE AccSchedLine2."Row Type" OF
                        AccSchedLine2."Row Type"::"Net Change":
                            GLAcc.SETRANGE(
                              "Date Filter",
                              FiscalStartDate2,
                              FindEndOfFiscalYear(FiscalStartDate2));
                        AccSchedLine2."Row Type"::"Beginning Balance":
                            GLAcc.SETFILTER("Date Filter", '<%1', FiscalStartDate2);  // always includes closing date
                        AccSchedLine2."Row Type"::"Balance at Date":
                            GLAcc.SETRANGE("Date Filter", 0D, FindEndOfFiscalYear(ToDate));
                    END;
            END;
        END;
    END;




    PROCEDURE "Repara Proyecto"(Job: Text[30]);
    VAR
        JobPlanningLine: Record "Job Planning Line";
        a: Integer;
        rJob: Record Job;
        b: Integer;
        Ventana: Dialog;
        rResource: Record Resource;
        imp: Decimal;
        rFamilia: Record "Resource Group";
        rGCP: Record 251;
        rGCN: Record 250;
        rCGC: Record 252;

    BEGIN
        Ventana.OPEN('Proyecto ##########1## linea ###########2##');
        rJob.SETRANGE(rJob."No.", Job);
        rJob.SETRANGE(rJob.Status, rJob.Status::Open);
        if NOT rJob.FINDFIRST THEN EXIT;
        REPEAT
            COMMIT;
            SalesHeader.SETRANGE(SalesHeader."Document Type", SalesHeader."Document Type"::Order);
            SalesHeader.SETRANGE(SalesHeader."Nº Proyecto", rJob."No.");
            if SalesHeader.FINDFIRST THEN BEGIN
                SalesHeader.CALCFIELDS(Amount);
                Ventana.UPDATE(1, rJob."No.");
                JobPlanningLine.SETRANGE(JobPlanningLine."Job No.", rJob."No.");
                imp := 0;
                if JobPlanningLine.FINDFIRST THEN
                    REPEAT
                        imp := imp + JobPlanningLine."Total Price";
                    UNTIL JobPlanningLine.NEXT = 0;
                if ROUND(imp, 1, '=') <> ROUND(SalesHeader.Amount, 1, '=') THEN BEGIN
                    SalesLine.SETRANGE(SalesLine."Document Type", SalesLine."Document Type"::Order);
                    SalesLine.SETRANGE(SalesLine."Document No.", SalesHeader."No.");
                    SalesLine.DELETEALL;
                    Ult := 10000;
                    if JobPlanningLine.FIND('-') THEN
                        REPEAT
                            if NOT rResource.GET(JobPlanningLine."No.") THEN BEGIN
                                JobPlanningLine."No." := 'CODI';
                                JobPlanningLine.MODIFY;
                            END;
                            CLEAR(SalesLine);
                            SalesLine."Document Type" := SalesHeader."Document Type";
                            SalesLine."Document No." := SalesHeader."No.";
                            SalesLine."Line No." := Ult;
                            Ult += 10000;
                            SalesLine.INSERT;
                            SalesLine.VALIDATE("Sell-to Customer No.", SalesHeader."Sell-to Customer No.");
                            CASE JobPlanningLine.Type OF
                                JobPlanningLine.Type::"G/L Account":
                                    SalesLine.VALIDATE(Type, SalesLine.Type::"G/L Account");
                                JobPlanningLine.Type::Item:
                                    SalesLine.VALIDATE(Type, SalesLine.Type::Item);
                                JobPlanningLine.Type::Resource:
                                    SalesLine.VALIDATE(Type, SalesLine.Type::Resource);
                                JobPlanningLine.Type::Familia:
                                    SalesLine.VALIDATE(Type, SalesLine.Type::"G/L Account");
                            END;
                            if (JobPlanningLine.Type <> JobPlanningLine.Type::Familia) THEN BEGIN
                                SalesLine.VALIDATE("No.", JobPlanningLine."No.");
                                SalesLine.VALIDATE(Description, JobPlanningLine.Description);
                                if (JobPlanningLine.Type = JobPlanningLine.Type::Resource) THEN BEGIN
                                    rResource.GET(JobPlanningLine."No.");
                                    if (rResource."Enunciado Cto. Venta" <> '') THEN
                                        SalesLine.VALIDATE(Description, rResource."Enunciado Cto. Venta");
                                END;
                            END ELSE BEGIN
                                rFamilia.GET(JobPlanningLine."No.");
                                rGCP.GET(rFamilia."Grupo contable producto");
                                rGCN.GET(SalesHeader."Gen. Bus. Posting Group");
                                rCGC.GET(rGCN.Code, rGCP.Code);
                                SalesLine.VALIDATE("No.", rCGC."Sales Account");
                                SalesLine.VALIDATE("Gen. Bus. Posting Group", rGCN.Code);
                                SalesLine.VALIDATE("Gen. Prod. Posting Group", rGCP.Code);
                                SalesLine.VALIDATE(Description, JobPlanningLine.Description);
                                // En el caso de Fam. recurso supongo que debe aplicarse a una cuenta contable
                            END;
                            SalesLine.VALIDATE("Job No.", JobPlanningLine."Job No.");               //FCL-28/02/06. Muevo aquí la línea, se machacaba cód.programa.
                            SalesLine.VALIDATE("Shortcut Dimension 1 Code", JobPlanningLine."Shortcut Dimension 1 Code");
                            SalesLine.VALIDATE("Shortcut Dimension 2 Code", JobPlanningLine."Shortcut Dimension 2 Code");
                            SalesLine.VALIDATE("Shortcut Dimension 3 Code", JobPlanningLine."Shortcut Dimension 3 Code");
                            SalesLine.VALIDATE("Shortcut Dimension 4 Code", JobPlanningLine."Shortcut Dimension 4 Code");
                            SalesLine.VALIDATE("Shortcut Dimension 5 Code", JobPlanningLine."Shortcut Dimension 5 Code");
                            //SalesLine.VALIDATE("Job No.", JobPlanningLine."Job No.");               //FCL-28/02/06.
                            //   { $001
                            //   SalesLine.VALIDATE("Phase Code", JobPlanningLine."Phase Code");
                            //   SalesLine.VALIDATE("Task Code", JobPlanningLine."Task Code");
                            //   }
                            SalesLine.VALIDATE(SalesLine."Job Task No.", JobPlanningLine."Job Task No.");

                            // mig 5.0     JobPlanningLine.CALCFIELDS(Quantity);
                            SalesLine.VALIDATE(Quantity, JobPlanningLine.Quantity);
                            SalesLine.VALIDATE("Unit Price", JobPlanningLine."Unit Price");
                            SalesLine.VALIDATE("Line Discount %", JobPlanningLine."% Dto. Venta");
                            SalesLine."Dto. Tarifa" := JobPlanningLine."Dto. Tarifa";
                            SalesLine."% Dto. Venta 1" := JobPlanningLine."% Dto. Venta 1";
                            SalesLine."% Dto. Venta 2" := JobPlanningLine."% Dto. Venta 2";
                            SalesLine."Precio Tarifa" := JobPlanningLine."Precio Tarifa";
                            SalesLine."Line Discount %" := JobPlanningLine."% Dto. Venta";
                            SalesLine.Duracion := JobPlanningLine.Duracion;
                            //Tipo Duracion
                            SalesLine."Tipo Duracion" := JobPlanningLine."Tipo Duracion";
                            SalesLine."Cdad. Soportes" := JobPlanningLine."Cdad. Soportes";  // $004
                            SalesLine.VALIDATE(Reparto, JobPlanningLine.Reparto);                                      //FCL-16/02/06

                            // $003-
                            JobPlanningLine.CALCFIELDS("No. Orden Publicidad");
                            if (JobPlanningLine."No. Orden Publicidad" <> '') THEN BEGIN
                                SalesLine."No. Orden Publicidad" := JobPlanningLine."No. Orden Publicidad";
                                CLEAR(rOrden);
                                if rOrden.GET(JobPlanningLine."No. Orden Publicidad") THEN BEGIN
                                    // Primera linea para nombre medio
                                    SalesLine.VALIDATE(Description, rOrden."Nombre Soporte");
                                END;
                            END ELSE BEGIN
                                SalesLine.VALIDATE("Description 2", (STRSUBSTNO('%1', JobPlanningLine."Planning Date") + ' - ' +
                                                               STRSUBSTNO('%1', JobPlanningLine."Fecha Final")));
                                if SalesLine."Description 2" = ' - ' THEN SalesLine."Description 2" := JobPlanningLine."Description 2";
                            END;
                            // $003+
                            SalesLine.MODIFY;

                            // $002  y parte del $003
                            if (JobPlanningLine."No. Orden Publicidad" <> '') THEN BEGIN
                                CLEAR(rOrden);
                                if rOrden.GET(JobPlanningLine."No. Orden Publicidad") THEN BEGIN
                                    // Linea para el nombre del recurso
                                    rResource.GET(rOrden.Concepto);
                                    Inserta_Linea(rResource.Name);

                                    // Linea para alto/ancho
                                    if ((rOrden.Alto <> 0) AND (rOrden.Ancho <> 0)) THEN
                                        Inserta_Linea(STRSUBSTNO('(Alto x Ancho): %1 x %2', rOrden.Alto, rOrden.Ancho));

                                    // Linea para recargo si hay
                                    if (rOrden.Recargo <> 0) THEN
                                        Inserta_Linea(STRSUBSTNO('Recargo: %1', rOrden.Recargo));

                                    // Linea para tarifas y dias
                                    LINEAS_DIAS;
                                END;
                            END;
                            rTexto.SETRANGE("Nº proyecto", JobPlanningLine."Job No.");
                            rTexto.SETRANGE("Nº linea aux", JobPlanningLine."Line No.");
                            rTexto.SETFILTER("Tipo linea", '%1|%2', rTexto."Tipo linea"::Ambos, rTexto."Tipo linea"::Venta);
                            if rTexto.FINDSET THEN
                                REPEAT
                                    if (rTexto.Texto <> '') THEN BEGIN
                                        CLEAR(SalesLine);
                                        SalesLine."Document Type" := SalesHeader."Document Type";
                                        SalesLine."Document No." := SalesHeader."No.";
                                        SalesLine."Line No." := Ult;
                                        Ult += 1000;
                                        SalesLine.INSERT;
                                        SalesLine.Type := SalesLine.Type::" ";
                                        SalesLine.Description := rTexto.Texto;
                                        SalesLine.MODIFY;
                                    END;
                                UNTIL rTexto.NEXT = 0;
                        // $002+ y $003+

                        UNTIL JobPlanningLine.NEXT = 0;
                END;
            END;
        UNTIL rJob.NEXT = 0;
        Ventana.CLOSE;
    END;

    PROCEDURE "Regenera Proyecto"(Job: Text[30]);
    VAR
        JobPlanningLine: Record "Job Planning Line";
        r5003: Record "Facturas a enviar";
        rSop: Record Vendor;
        rResource: Record Resource;
    BEGIN
        error('No se puede regenerar el proyecto');
        //   JobPlanningLine.SETRANGE(JobPlanningLine."Job No.",Job);
        //   JobPlanningLine.DELETEALL;
        //   r5003.SETRANGE(r5003."Sell-to Customer No.",Job);
        //   if r5003.FINDFIRST THEN REPEAT
        //    JobPlanningLine.TRANSFERFIELDS(r5003);
        //    //if r5003.LineaMaster<>0 THEN
        //    //JobPlanningLine."Line No.":=r5003.LineaMaster*10000+r5003.Perfil;
        //    //if r5003.LineaMaster<>0 THEN
        //    JobPlanningLine."Description 2":=JobPlanningLine."No.";
        //    if NOT rResource.GET(JobPlanningLine."No.") THEN
        //     JobPlanningLine."No.":='CODI';
        //    if JobPlanningLine.Description='' THEN JobPlanningLine.Description:='';
        //   // if r5003.LineaMaster<>0 THEN BEGIN
        //    rSop.SETRANGE(Medio,JobPlanningLine."Compra a-Nº proveedor");
        //   // rSop.SETRANGE("Prueba factura",JobPlanningLine."Soporte Imp");
        //    if rSop.FINDFIRST THEN
        //    JobPlanningLine."Compra a-Nº proveedor":=rSop."No.";
        //   // END;
        //    JobPlanningLine.INSERT;
        //   UNTIL r5003.NEXT = 0;
    END;

    PROCEDURE Inserta_Linea(Descripcion: Text[50]);
    BEGIN
        CLEAR(SalesLine);
        SalesLine."Document Type" := SalesHeader."Document Type";
        SalesLine."Document No." := SalesHeader."No.";
        SalesLine."Line No." := Ult;
        Ult += 1000;
        SalesLine.INSERT;
        SalesLine.Type := SalesLine.Type::" ";
        SalesLine.Description := Descripcion;
        SalesLine.MODIFY;
    END;

    PROCEDURE LINEAS_DIAS();
    VAR
        wDescAux: Text[100];
        wDiasAux: Text[100];
    BEGIN
        CLEAR(rLinOrden);
        CLEAR(wDescAux);
        rLinOrden.SETCURRENTKEY("Tipo orden", "No. orden", "Dia tarifa", Concepto, "Fecha inicio");
        rLinOrden.SETRANGE("No. orden", rOrden.No);
        CLEAR(wDiasAux);
        if rLinOrden.FINDSET THEN
            REPEAT
                wPrimero := FALSE;
                if (rLinOrden."Dia tarifa" <> wDiasAux) THEN BEGIN
                    if (wDiasAux <> '') THEN BEGIN
                        Inserta_Linea(wDescAux);
                        CLEAR(wDescAux);
                    END;
                    wDiasAux := rLinOrden."Dia tarifa";
                    wDescAux := STRSUBSTNO('(%1): ', rLinOrden."Dia tarifa");
                    wPrimero := TRUE;
                END;
                if NOT wPrimero THEN
                    wDescAux += ',';
                wDescAux += FORMAT(rLinOrden."Fecha inicio");
                if (STRLEN(wDescAux) >= 41) THEN BEGIN
                    Inserta_Linea(wDescAux);
                    CLEAR(wDescAux);
                END;
            UNTIL rLinOrden.NEXT = 0;
        Inserta_Linea(wDescAux);
    END;

    /// <summary>
    /// CreateInvoiceLines2.
    /// </summary>
    /// <param name="Var PurchRcptLine2">Record "Purch. Rcpt. Line".</param>
    /// <param name="q">Decimal.</param>
    /// <param name="PurchHeader">VAR Record "Purchase Header".</param>
    /// <param name="PurchRcptHeader">VAR Record 120.</param>
    procedure CreateInvoiceLines2(Var PurchRcptLine2: Record "Purch. Rcpt. Line";
     q: Decimal; var PurchHeader: Record "Purchase Header"; var PurchRcptHeader: Record 120);
    var
        TransferLine: Boolean;
        PurchLine: Record "Purchase Line";
        Text000: Label 'El %1 en el %2 %3 y el %4 %5 debe ser el mismo.';
        PurchRcptLine: Record "Purch. Rcpt. Line";
        C74: Codeunit 74;
    begin
        TransferLine := TRUE;
        WITH PurchRcptLine2 DO BEGIN
            //SETFILTER("Qty. Rcd. Not Invoiced", '<>%1', 0);
            if PurchRcptLine2."Qty. Rcd. Not Invoiced" <> 0 THEN BEGIN
                PurchLine.LOCKTABLE;
                PurchLine.SETRANGE("Document Type", PurchHeader."Document Type");
                PurchLine.SETRANGE("Document No.", PurchHeader."No.");
                PurchLine."Document Type" := PurchHeader."Document Type";
                PurchLine."Document No." := PurchHeader."No.";

                REPEAT
                    if PurchRcptHeader."No." <> "Document No." THEN BEGIN
                        PurchRcptHeader.GET("Document No.");
                        TransferLine := TRUE;
                        if PurchRcptHeader."Currency Code" <> PurchHeader."Currency Code" THEN BEGIN
                            MESSAGE(
                            Text000,
                            PurchHeader.FIELDCAPTION("Currency Code"),
                            PurchHeader.TABLECAPTION, PurchHeader."No.",
                            PurchRcptHeader.TABLECAPTION, PurchRcptHeader."No.");
                            TransferLine := FALSE;
                        END;
                        if PurchRcptHeader."Pay-to Vendor No." <> PurchHeader."Pay-to Vendor No." THEN BEGIN
                            MESSAGE(
                            Text000,
                            PurchHeader.FIELDCAPTION("Pay-to Vendor No."),
                            PurchHeader.TABLECAPTION, PurchHeader."No.",
                            PurchRcptHeader.TABLECAPTION, PurchRcptHeader."No.");
                            TransferLine := FALSE;
                        END;
                    END;
                    if TransferLine THEN BEGIN
                        PurchRcptLine := PurchRcptLine2;
                        PurchRcptLine.InsertInvLineFromRcptLine4(PurchLine, q, PurchHeader, PurchRcptLine2);
                        //DimMgt.MoveTempFromDimToTempToDim(TempFromLineDim,TempToLineDim);
                    END;
                UNTIL NEXT = 0;
                c74.GetItemChargeAssgnt(PurchRcptLine2, PurchLine."Qty. to Invoice");
                //DimMgt.TransferTempToDimToDocDim(TempToLineDim);
            END;
        END;
    end;

    /// <summary>
    /// CreateCrLines2.
    /// </summary>
    /// <param name="Var PurchRcptLine2">Record "Return Shipment Line".</param>
    /// <param name="q">Decimal.</param>
    /// <param name="PurchHeader">VAR Record "Purchase Header".</param>
    /// <param name="PurchRcptHeader">VAR Record 6650.</param>
    procedure CreateCrLines2(Var PurchRcptLine2: Record "Return Shipment Line"; q: Decimal; var PurchHeader: Record "Purchase Header"; var PurchRcptHeader: Record 6650);
    var
        TransferLine: Boolean;
        PurchLine: Record "Purchase Line";
        Text000: Label 'El %1 en el %2 %3 y el %4 %5 debe ser el mismo.';
        PurchRcptLine: Record 6651;
        C74: Codeunit 6648;
    begin

        WITH PurchRcptLine2 DO BEGIN
            SETFILTER("Return Qty. Shipped Not Invd.", '<>0');
            if FIND('-') THEN BEGIN
                PurchLine.LOCKTABLE;
                PurchLine.SETRANGE("Document Type", PurchHeader."Document Type");
                PurchLine.SETRANGE("Document No.", PurchHeader."No.");
                PurchLine."Document Type" := PurchHeader."Document Type";
                PurchLine."Document No." := PurchHeader."No.";

                REPEAT
                    if PurchRcptHeader."No." <> "Document No." THEN BEGIN
                        PurchRcptHeader.GET("Document No.");
                        TransferLine := TRUE;
                        if PurchRcptHeader."Currency Code" <> PurchHeader."Currency Code" THEN BEGIN
                            MESSAGE(
                            Text000,
                            PurchHeader.FIELDCAPTION("Currency Code"),
                            PurchHeader.TABLECAPTION, PurchHeader."No.",
                            PurchRcptHeader.TABLECAPTION, PurchRcptHeader."No.");
                            TransferLine := FALSE;
                        END;
                        if PurchRcptHeader."Pay-to Vendor No." <> PurchHeader."Pay-to Vendor No." THEN BEGIN
                            MESSAGE(
                            Text000,
                            PurchHeader.FIELDCAPTION("Pay-to Vendor No."),
                            PurchHeader.TABLECAPTION, PurchHeader."No.",
                            PurchRcptHeader.TABLECAPTION, PurchRcptHeader."No.");
                            TransferLine := FALSE;
                        END;
                    END;
                    if TransferLine THEN BEGIN
                        PurchRcptLine := PurchRcptLine2;
                        PurchRcptLine.InsertInvLineFromRetShptLine2(PurchLine, q);
                        //DimMgt.MoveTempFromDimToTempToDim(TempFromLineDim,TempToLineDim);
                    END;
                UNTIL NEXT = 0;
                c74.GetItemChargeAssgnt(PurchRcptLine2, PurchLine."Qty. to Invoice");
                //DimMgt.TransferTempToDimToDocDim(TempToLineDim);
            END;
        END;
    end;

    PROCEDURE "Regenera Proyecto2"(Job: Text[30]);
    VAR
        JobPlanningLine: Record "Job Planning Line";
        //r5003 : Record 53003;
        //rSop : Record 7000104;
        rResource: Record Resource;
        rJob: Record Job;
        fi: Date;
        ff: Date;
        rFec: Record 2000000007;
    BEGIN
        error('Procedimiento obsoleto')
        //   r5003.SETRANGE(r5003."Job No.",Job);
        //   if r5003.FINDFIRST THEN REPEAT
        //   if JobPlanningLine.GET(r5003."Job No.",r5003."Job Task No.",r5003."Line No.") THEN BEGIN
        //    if r5003."Preu Mes"<>0 THEN BEGIN
        //      rJob.GET(JobPlanningLine."Job No.");
        //      if rJob."Starting Date"=0D THEN rJob."Starting Date":=rJob."Creation Date";
        //      fi:=CALCDATE('PM-1M+1D',rJob."Starting Date");
        //      ff:=CALCDATE('PM',rJob."Ending Date");
        //      rFec.SETRANGE(rFec."Period Type",rFec."Period Type"::Mes);
        //      rFec.SETRANGE(rFec."Period Start",fi,ff);
        //      JobPlanningLine.Quantity:=rFec.COUNT;
        //      JobPlanningLine."Unit Price":=r5003."Preu Mes";
        //    END ELSE BEGIN
        //     JobPlanningLine.Quantity:=r5003.Quantity;
        //     JobPlanningLine."Unit Price":=r5003."Unit Price (LCY)";
        //    END;
        //     JobPlanningLine."% Dto. Venta":=r5003."Line Discount %";
        //     JobPlanningLine.VALIDATE(JobPlanningLine."Unit Price",JobPlanningLine."Unit Price");
        //    JobPlanningLine.MODIFY;
        //    END;
        //   UNTIL r5003.NEXT = 0;
    END;

    procedure GetNextNoEmpresa(var NoSeriesLine: Record "No. Series Line"; UsageDate: Date; ModifySeries: Boolean; HideErrorsAndWarnings: Boolean; Empresa: text[30]): Code[20]
    var
        NoSeriesSingle: Interface "No. Series - Single";
        Result: Code[20];
        IsHandled: Boolean;

    begin
        if UsageDate = 0D then
            UsageDate := WorkDate();


        NoSeriesSingle := GetImplementation(NoSeriesLine);
        NoSeriesLine.ChangeCompany(Empresa);
        exit(NoSeriesSingle.GetNextNo(NoSeriesLine, UsageDate, HideErrorsAndWarnings))

    end;

    local procedure GetImplementation(var NoSeriesLine: Record "No. Series Line"): Interface "No. Series - Single"
    begin
        if NoSeriesLine.Implementation = NoSeriesLine.Implementation::Sequence THEN
            error('No se puede usar la implementación de secuencia para la facturación interna');
        exit(NoSeriesLine.Implementation);
    end;

    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        Ult: Integer;
        rLinOrden: Record "Lin. orden publicidad";
        wPrimero: Boolean;
        rTexto: Record "Texto Presupuesto";
        rOrden: Record "Cab. orden publicidad";
        rJob: Record Job;
        rEmp: Record Company;
        rSoc: Record "IC Partner";
        rSoc2: Record "IC Partner";
        GlobalNoSeries: Record "No. Series";
        LastNoSeriesLine: Record "No. Series Line";
        GlobalNoSeriesCode: Code[20];
        WarningNoSeriesCode: Code[20];
        TryNoSeriesCode: Code[20];
        TrySeriesDate: Date;
        TryNo: Code[20];
        UpdateLastUsedDate: Boolean;
        CannotAssignManuallyErr: Label 'No puede introducir números manualmente. Si desea introducir números manualmente, active %1 en %2 %3.', Comment = '%1=Configuración de números manuales,%2=Nombre de la tabla de series de números,%3=Código de serie de números';
        CannotAssignAutomaticallyErr: Label 'No se puede asignar números automáticamente. Si desea que el programa asigne números automáticamente, active %1 en %2 %3.', Comment = '%1=Configuración de números predeterminados,%2=Nombre de la tabla de series de números,%3=Código de serie de números';
        CannotAssignNewOnDateErr: Label 'No puede asignar nuevos números de la serie de números %1 en %2.', Comment = '%1=Código de serie de números,%2=Fecha';
        CannotAssignNewErr: Label 'No puede asignar nuevos números de la serie de números %1.', Comment = '%1=Código de serie de números';
        CannotAssignNewBeforeDateErr: Label 'No puede asignar nuevos números de la serie de números %1 en una fecha anterior a %2.', Comment = '%1=Código de serie de números,%2=Fecha';
        CannotAssignGreaterErr: Label 'No puede asignar números mayores que %1 de la serie de números %2.', Comment = '%1=Último número,%2=Código de serie de números';
        NumberFormatErr: Label 'El formato de número en %1 debe ser el mismo que el formato de número en %2.', Comment = '%1=Código de serie de números,%2=Código de serie de números';
        NumberLengthErr: Label 'El número %1 no puede extenderse a más de 20 caracteres.', Comment = '%1=No.';
        PostErr: Label 'Tiene uno o más documentos que deben ser contabilizados antes de contabilizar el documento n.º %1 según la configuración de series de números de su empresa.', Comment = '%1=N.º de documento.';
        UnincrementableStringErr: Label 'El valor en el campo %1 debe tener un número para que podamos asignar el siguiente número en la serie.', Comment = '%1 = Nombre del nuevo campo';



}