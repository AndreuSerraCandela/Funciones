/// <summary>
/// Codeunit LiqAccountScheduleManagement (ID 7001107).
/// </summary>
Codeunit 7001107 LiqAccountScheduleManagement
{
    TableNo = 85;

    VAR
        Text1140000: Label 'GENERICO';
        Text1140001: Label 'Previsión genér.';
        Text1140002: Label 'Columnas genér.';
        Text1140003: Label '-1A';
        Text1140004: Label 'MA';
        Text1140005: Label 'M';
        Text1140006: Label 'T';
        Text1140007: Label 'A';
        Text1140008: Label '-1D';
        Text1140009: Label '+1D';
        Text1140010: Label '+1A-1D';
        Text1140011: Label 'La aplicación no puede calcular la fórmula debido a las referencias circulares.';
        Text1140012: Label 'Ha introducido un valor incorrecto o un número de fila inexistente.';
        Text1140013: Label 'Ha introducido un valor incorrecto o un número de columna inexistente.';
        Text1140014: Label '<Precision,';
        Text1140015: Label '><Standard Format,0>';
        Text1140016: Label '<Precision,1><Standard Format,0>';
        Text1140017: Label 'Se ha producido un error al realizar el siguiente cálculo:\';
        Text1140018: Label '"Lín. esq. cta.: Nº fila = %1, Nº línea = %2, Total = %3\"';
        Text1140019: Label '"Col. esq. cta.: Nº columna = %4, Nº línea = %5, Fórmula = %6"';
        Text1140020: Label 'La conversión del total del filtro de dimensión %1 pasa a ser un filtro demasiado largo.';
        Text1140042: Label 'No se pueden tener más de %1 líneas con %2 de %3.';
        Text1140043: Label 'Las fórmulas que terminan con un signo de porcentaje requieren que %2 %1 se incluya en la línea anterior.';
        Text1140044: Label '%1 %3 en %2 debe ser igual a %4 %6 en %5 cuando se utiliza un sumatorio de dimensiones en cualquier columna.';
        LiqAccSchedName: Record "Acc. Schedule Name";
        LiqAccountSchedLine: Record "Acc. Schedule Line";

#pragma warning disable AL0432
        LiqAccSchedCellValue: Record "Acc. Sched. Cell Value" TEMPORARY;
#pragma warning restore AL0432

        LiquidityAnalysisView: Record "Analysis View";
        GLSetup: Record "General Ledger Setup";
        LiqAccScheduleLayoutName: Record "Column Layout Name";
        AnalysisViewRead: Boolean;
        StartDate: Date;
        EndDate: Date;
        FiscalStartDate: Date;
        DivisionError: Boolean;
        PeriodError: Boolean;
        CallLevel: Integer;
        CallLiqAccSchedLineID: Integer;
        CallLiqAccSchedColumnID: Integer;
        BasePercentLine: ARRAY[50] OF Integer;
        OldLiqAccSchedLineFilter: Text[250];
        OldLiqAccSchedColumnFilter: Text[250];
        OldLiqAccSchedLineName: Code[10];
        OldLiqAccSchedColumnName: Code[10];
        NormalFormatString: Text[80];
        NormalPrecision: Decimal;
        GLSetupRead: Boolean;


    PROCEDURE OpenSchedule(VAR CurrentSchedName: Code[10]; VAR LiqAccSchedLine: Record 85);
    BEGIN
        CheckTemplateName(CurrentSchedName);
        LiqAccSchedLine.FILTERGROUP(2);
        LiqAccSchedLine.SETRANGE("Schedule Name", CurrentSchedName);
        LiqAccSchedLine.FILTERGROUP(0);
    END;

    PROCEDURE CheckTemplateName(VAR CurrentSchedName: Code[10]);
    VAR
        LiqAccSchedName: Record "Acc. Schedule Name";
    BEGIN
        if NOT LiqAccSchedName.GET(CurrentSchedName) THEN BEGIN
            if NOT LiqAccSchedName.FIND('-') THEN BEGIN
                LiqAccSchedName.INIT;
                LiqAccSchedName.Name := Text1140000;
                LiqAccSchedName.Description := Text1140001;
                LiqAccSchedName.INSERT;
                COMMIT;
            END;
            CurrentSchedName := LiqAccSchedName.Name;
        END;
    END;

    PROCEDURE CheckName(CurrentSchedName: Code[10]);
    VAR
        LiqAccSchedName: Record "Acc. Schedule Name";
    BEGIN
        LiqAccSchedName.GET(CurrentSchedName);
    END;

    PROCEDURE SetName(CurrentSchedName: Code[10]; VAR LiqAccSchedLine: Record 85);
    BEGIN
        LiqAccSchedLine.FILTERGROUP(2);
        LiqAccSchedLine.SETRANGE("Schedule Name", CurrentSchedName);
        LiqAccSchedLine.FILTERGROUP(0);
        if LiqAccSchedLine.FIND('-') THEN;
    END;

    PROCEDURE LookupName(CurrentSchedName: Code[10]; VAR EntrdSchedName: Text[10]): Boolean;
    VAR
        LiqAccSchedName: Record "Acc. Schedule Name";
    BEGIN
        LiqAccSchedName.Name := CurrentSchedName;
        if Page.RUNMODAL(0, LiqAccSchedName) <> ACTION::LookupOK THEN
            EXIT(FALSE);

        EntrdSchedName := LiqAccSchedName.Name;
        EXIT(TRUE);
    END;

    PROCEDURE OpenColumns(VAR CurrentColumnName: Code[10]; VAR LiqAccSchedColumn: Record "Column Layout");
    BEGIN
        CheckColumnTemplateName(CurrentColumnName);
        LiqAccSchedColumn.FILTERGROUP(2);
        LiqAccSchedColumn.SETRANGE("Column Layout Name", CurrentColumnName);
        LiqAccSchedColumn.FILTERGROUP(0);
    END;

    PROCEDURE CheckColumnTemplateName(VAR CurrentColumnName: Code[10]);
    VAR
        LiqAccScheduleLayoutName: Record "Column Layout Name";
    BEGIN
        if NOT LiqAccScheduleLayoutName.GET(CurrentColumnName) THEN BEGIN
            if NOT LiqAccScheduleLayoutName.FIND('-') THEN BEGIN
                LiqAccScheduleLayoutName.INIT;
                LiqAccScheduleLayoutName.Name := Text1140000;
                LiqAccScheduleLayoutName.Description := Text1140002;
                LiqAccScheduleLayoutName.INSERT;
                COMMIT;
            END;
            CurrentColumnName := LiqAccScheduleLayoutName.Name;
        END;
    END;

    PROCEDURE CheckColumnName(CurrentColumnName: Code[10]);
    VAR
        LiqAccScheduleLayoutName: Record "Column Layout Name";
    BEGIN
        LiqAccScheduleLayoutName.GET(CurrentColumnName);
    END;

    PROCEDURE SetColumnName(CurrentColumnName: Code[10]; VAR LiqAccSchedColumn: Record "Column Layout");
    BEGIN
        LiqAccSchedColumn.FILTERGROUP(2);
        LiqAccSchedColumn.SETRANGE("Column Layout Name", CurrentColumnName);
        LiqAccSchedColumn.FILTERGROUP(0);
        if LiqAccSchedColumn.FIND('-') THEN;
    END;

    PROCEDURE CopyColumnsToTemp(NewColumnName: Code[10]; VAR TmpLiqAccSchedColumn: Record "Column Layout");
    VAR
        LiqAccSchedColumn: Record "Column Layout";
    BEGIN
        TmpLiqAccSchedColumn.DELETEALL;
        LiqAccSchedColumn.SETRANGE("Column Layout Name", NewColumnName);
        if LiqAccSchedColumn.FIND('-') THEN
            REPEAT
                TmpLiqAccSchedColumn := LiqAccSchedColumn;
                TmpLiqAccSchedColumn.INSERT;
            UNTIL LiqAccSchedColumn.NEXT = 0;
        if TmpLiqAccSchedColumn.FIND('-') THEN;
    END;

    PROCEDURE LookupColumnName(CurrentColumnName: Code[10]; VAR EntrdColumnName: Text[10]): Boolean;
    VAR
        LiqAccScheduleLayoutName: Record "Column Layout Name";
    BEGIN
        LiqAccScheduleLayoutName.Name := CurrentColumnName;
        if Page.RUNMODAL(0, LiqAccScheduleLayoutName) <> ACTION::LookupOK THEN
            EXIT(FALSE);

        EntrdColumnName := LiqAccScheduleLayoutName.Name;
        EXIT(TRUE);
    END;

    PROCEDURE FindFiscalYear(BalanceDate: Date): Date;
    VAR
        AccountingPeriod: Record 50;
        FiscalStartDate: Date;
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
        LiqAccountScheduleColumn: Record "Column Layout";
        AccountingPeriod: Record 50;
        AccountingPeriodFY: Record 50;
        Steps: Integer;
        ActualSteps: Integer;
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

        PeriodParse.ParsePeriodFormula(
          Formula, Steps, Type, RangeFromType, RangeToType, RangeFromInt, RangeToInt, LanguageId);

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

    PROCEDURE CalcCell(VAR LiqAccSchedLine: Record 85; VAR LiqAccSchedColumn: Record "Column Layout"): Decimal;
    VAR
        Result: Decimal;
        Calc: Codeunit "Procedures Standard";
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
        if LiqAccSchedLine."Totaling Type" in [LiqAccSchedLine."Totaling Type"::"Posting Accounts",
                                               LiqAccSchedLine."Totaling Type"::"Total Accounts"
                                               ]
        THEN
            Result := Calc.CalcCell(LiqAccSchedLine, LiqAccSchedColumn, False)
        ELSE begin
            Result := CalcCellValue(LiqAccSchedLine, LiqAccSchedColumn);
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
        end;
        EXIT(Result);
    END;

    PROCEDURE CalcCellValue(LiqAccSchedLine: Record 85; LiqAccSchedColumn: Record "Column Layout"): Decimal;
    VAR
        Result: Decimal;
        LiqAcc: Record "Cash Flow Account";

    BEGIN
        Result := 0;
        if LiqAccSchedLine.Totaling <> '' THEN
            if LiqAccSchedCellValue.GET(LiqAccSchedLine."Line No.", LiqAccSchedColumn."Line No.") THEN BEGIN
                Result := LiqAccSchedCellValue.Value;
                DivisionError := DivisionError OR LiqAccSchedCellValue."Has Error";
                PeriodError := PeriodError OR LiqAccSchedCellValue."Period Error";
            END ELSE BEGIN
                if LiqAccSchedColumn."Column Type" = LiqAccSchedColumn."Column Type"::Formula THEN
                    Result := EvaluateExpression(FALSE, LiqAccSchedColumn.Formula, LiqAccSchedLine, LiqAccSchedColumn)
                ELSE
                    if LiqAccSchedLine."Totaling Type" IN
                      [LiqAccSchedLine."Totaling Type"::Formula, LiqAccSchedLine."Totaling Type"::"Set Base For Percent"]
                    THEN
                        Result := EvaluateExpression(TRUE, LiqAccSchedLine.Totaling, LiqAccSchedLine, LiqAccSchedColumn)
                    ELSE
                        if (StartDate = 0D) OR (EndDate = 0D) OR (EndDate = 99991231D) THEN BEGIN
                            Result := 0;
                            PeriodError := TRUE;
                        END ELSE BEGIN
                            LiqAccSchedLine.COPYFILTERS(LiqAccountSchedLine);
                            SetLiqAccRowFilter(LiqAcc, LiqAccSchedLine);
                            SetLiqAccColumnFilter(LiqAcc, LiqAccSchedLine, LiqAccSchedColumn);
                            if LiqAcc.FIND('-') THEN
                                REPEAT
                                    Result := Result + CalcLiqAccount(LiqAcc, LiqAccSchedLine, LiqAccSchedColumn);
                                UNTIL LiqAcc.NEXT = 0;
                        end;
                LiqAccSchedCellValue."Row No." := LiqAccSchedLine."Line No.";
                LiqAccSchedCellValue."Column No." := LiqAccSchedColumn."Line No.";
                LiqAccSchedCellValue.Value := Result;
                LiqAccSchedCellValue."Has Error" := DivisionError;
                LiqAccSchedCellValue."Period Error" := PeriodError;
                LiqAccSchedCellValue.INSERT;
            END;
        EXIT(Result);
    END;

    PROCEDURE CalcLiqAccount(VAR LiqAcc: Record "Cash Flow Account"; VAR LiqAccountScheduleLine: Record 85; VAR LiqAccountScheduleColumn2: Record "Column Layout") ColValue: Decimal;
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
        Control: Codeunit ControlProcesos;
    BEGIN
        ColValue := 0;
        if LiqAccSchedName.Name <> LiqAccountScheduleLine."Schedule Name" THEN
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
        if LiqAccountScheduleColumn2.Empresa <> '' THEN
            if not Control.Permiso_Empresas(LiqAccountScheduleColumn2.Empresa) Then exit(0);
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
                LiqAccountScheduleColumn2."Ledger Entry Type"::Entries:
                    BEGIN
                        if LiqAccSchedName."Analysis View Name" = '' THEN
                            WITH LiquidityLedgerEntry DO BEGIN
                                SETCURRENTKEY(
                                   "Cash Flow Account No.", "Cash Flow Forecast No.", "Global Dimension 1 Code",
                                   "Global Dimension 2 Code", "Cash flow Date");
                                if LiqAcc.Totaling = '' THEN
                                    SETRANGE("Cash Flow Account No.", LiqAcc."No.")
                                ELSE
                                    SETFILTER("Cash Flow Account No.", LiqAcc.Totaling);
                                LiqAcc.COPYFILTER("Date Filter", "Cash flow Date");

                                if (LiqAcc."Source Type" in [LiqAcc."Source Type"::"Cartera Clientes", LiqAcc."Source Type"::Receivables]) AND
                                (LiqAcc."Solo Cartera") THEN BEGIN
                                    if LiqAcc.GETFILTER("Date Filter") = '' THEN
                                        LiqAcc.COPYFILTER("Date Filter", "Cash flow Date")
                                    ELSE BEGIN
                                        if LiqAcc.GETRANGEMIN("Date Filter") = LiqAcc.GETRANGEMAX("Date Filter")
                                         THEN
                                            LiqAcc.COPYFILTER("Date Filter", "Cash flow Date")
                                        ELSE
                                            SETRANGE("Cash flow Date", LiqAcc.GETRANGEMIN("Date Filter"), CALCDATE('180D', LiqAcc.GETRANGEMAX("Date Filter")));
                                    END;
                                END;
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
                                LiqAcc.COPYFILTER("Date Filter", "Posting Date");
                                LiqAccountScheduleLine.COPYFILTER("Cash Flow Forecast Filter", "Cash Flow Forecast No.");
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

    PROCEDURE SetLiqAccRowFilter(VAR LiqAcc: Record "Cash Flow Account"; VAR LiqAccSchedLine2: Record 85);
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
                "Totaling Type"::"Cash Flow Entry Accounts":
                    BEGIN
                        LiqAcc.SETFILTER("No.", Totaling);
                        LiqAcc.SETRANGE("Account Type", LiqAcc."Account Type"::Entry);
                    END;
                "Totaling Type"::"Cash Flow Total Accounts":
                    BEGIN
                        LiqAcc.SETFILTER("No.", Totaling);
                        LiqAcc.SETFILTER("Account Type", '<>%1', LiqAcc."Account Type"::Entry);
                    END;
            END;
        END;
    END;

    PROCEDURE SetLiqAccColumnFilter(VAR LiqAcc: Record "Cash Flow Account"; LiqAccSchedLine2: Record 85; VAR LiqAccountScheduleColumn2: Record "Column Layout");
    VAR
        FromDate: Date;
        ToDate: Date;
        FiscalStartDate2: Date;
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

    PROCEDURE EvaluateExpression(IsAccSchedLineExpression: Boolean; Expression: Text[80]; LiqAccSchedLine: Record 85; LiqAccSchedColumn: Record "Column Layout"): Decimal;
    VAR
        LiqAccSchedLine2: Record 85;
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
                LeftResult := EvaluateExpression(IsAccSchedLineExpression, LeftOperand, LiqAccSchedLine, LiqAccSchedColumn);
                if (RightOperand = '') AND (Operator = '%') AND NOT IsAccSchedLineExpression AND
                   (LiqAccSchedLine."Totaling Type" <> LiqAccSchedLine."Totaling Type"::"Set Base For Percent")
                THEN BEGIN
                    LiqAccSchedLine2.COPY(LiqAccSchedLine);
                    LiqAccSchedLine2."Line No." := GetBasePercentLine(LiqAccSchedLine, LiqAccSchedColumn);
                    LiqAccSchedLine2.FIND;
                    RightResult :=
                      EvaluateExpression(
                        IsAccSchedLineExpression, LeftOperand, LiqAccSchedLine2, LiqAccSchedColumn);
                END ELSE
                    RightResult :=
                      EvaluateExpression(
                        IsAccSchedLineExpression, RightOperand, LiqAccSchedLine, LiqAccSchedColumn);
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
                      EvaluateExpression(
                        IsAccSchedLineExpression,
                        COPYSTR(Expression, 2, STRLEN(Expression) - 2),
                        LiqAccSchedLine,
                        LiqAccSchedColumn)
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
                                        Result := Result + CalcCellValue(LiqAccSchedLine, LiqAccSchedColumn);
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
                                        Result := Result + CalcCellValue(LiqAccSchedLine, LiqAccSchedColumn);
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

    PROCEDURE FormatCellAsText(VAR LiqAccSchedColumn2: Record "Column Layout"; Value: Decimal): Text[30];
    VAR
        GLSetup: Record "General Ledger Setup";
        ValueAsText: Text[30];
    BEGIN
        if NormalFormatString = '' THEN BEGIN
            if NOT GLSetupRead THEN BEGIN
                GLSetup.GET;
                GLSetupRead := TRUE;
            END;
            NormalFormatString := Text1140014 + GLSetup."Amount Decimal Places" + Text1140015;
        END;
        WITH LiqAccSchedColumn2 DO
            if Value <> 0 THEN BEGIN
                CASE "Rounding Factor" OF
                    "Rounding Factor"::None:
                        ValueAsText := FORMAT(Value, 0, NormalFormatString);
                    "Rounding Factor"::"1":
                        ValueAsText := FORMAT(ROUND(Value, 1));
                    "Rounding Factor"::"1000":
                        ValueAsText := FORMAT(ROUND(Value / 1000, 0.1), 0, Text1140016);
                    "Rounding Factor"::"1000000":
                        ValueAsText := FORMAT(ROUND(Value / 1000000, 0.1), 0, Text1140016);
                END;
                if (LiqAccSchedColumn2."Column Type" = LiqAccSchedColumn2."Column Type"::Formula) AND
                   (STRPOS(LiqAccSchedColumn2.Formula, '%') > 1) THEN
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

    PROCEDURE ShowError(MessageLine: Text[100]; VAR LiqAccSchedLine: Record 85; VAR LiqAccSchedColumn: Record "Column Layout");
    BEGIN
        LiqAccSchedLine.SETRANGE("Schedule Name", LiqAccSchedLine."Schedule Name");
        LiqAccSchedLine.SETRANGE("Line No.", CallLiqAccSchedLineID);
        if LiqAccSchedLine.FIND('-') THEN;
        LiqAccSchedColumn.SETRANGE("Column Layout Name", LiqAccSchedColumn."Column Layout Name");
        LiqAccSchedColumn.SETRANGE("Line No.", CallLiqAccSchedColumnID);
        if LiqAccSchedColumn.FIND('-') THEN;
        ERROR(
          MessageLine + '\\' +
          Text1140017 +
          Text1140018 +
          Text1140019,
          LiqAccSchedLine."Row No.", LiqAccSchedLine."Line No.", LiqAccSchedLine.Totaling,
          LiqAccSchedColumn."Column No.", LiqAccSchedColumn."Line No.", LiqAccSchedColumn.Formula);
    END;

    PROCEDURE InsertLiqAccounts(VAR LiqAccSchedLine: Record 85);
    VAR
        LiqAcc: Record "Cash Flow Account";
        RecRef: RecordRef;
        LiqAccList: Page "Cash Flow Account List";
        LiqAccCounter: Integer;
        LiqAccSchedLineNo: Integer;
        i: Integer;
    BEGIN
        LiqAccList.LOOKUPMODE(TRUE);
        if LiqAccList.RUNMODAL = ACTION::LookupOK THEN BEGIN
            LiqAccList.SetSelection(LiqAcc);
            LiqAccCounter := LiqAcc.COUNT;
            if LiqAccCounter > 0 THEN BEGIN
                LiqAccSchedLineNo := LiqAccSchedLine."Line No.";
                LiqAccSchedLine.SETRANGE("Schedule Name", LiqAccSchedLine."Schedule Name");
                if LiqAccSchedLine.FIND('+') THEN
                    REPEAT
                        i := LiqAccSchedLine."Line No.";
                        if i >= LiqAccSchedLineNo THEN BEGIN
                            LiqAccSchedLine.DELETE;
                            LiqAccSchedLine."Line No." := i + 10000 * LiqAccCounter;
                            LiqAccSchedLine.INSERT;
                        END;
                    UNTIL (i <= LiqAccSchedLineNo) OR (LiqAccSchedLine.NEXT(-1) = 0);

                if LiqAccSchedLineNo = 0 THEN
                    LiqAccSchedLineNo := 10000;

                if LiqAcc.FIND('-') THEN
                    REPEAT
                        LiqAccSchedLine.INIT;
                        LiqAccSchedLine."Line No." := LiqAccSchedLineNo;
                        LiqAccSchedLineNo := LiqAccSchedLineNo + 10000;
                        LiqAccSchedLine.Description := LiqAcc.Name;

                        if LiqAcc."Account Type" IN
                           [LiqAcc."Account Type"::Entry, LiqAcc."Account Type"::Total, LiqAcc."Account Type"::"End-Total"]
                        THEN BEGIN
                            LiqAccSchedLine.Totaling := LiqAcc."No.";
                            LiqAccSchedLine."Row No." := COPYSTR(LiqAcc."No.", 1, MAXSTRLEN(LiqAccSchedLine."Row No."));
                        END;
                        if LiqAcc."Account Type" IN
                           [LiqAcc."Account Type"::Total, LiqAcc."Account Type"::"End-Total"]
                        THEN
                            LiqAccSchedLine."Totaling Type" := LiqAccSchedLine."Totaling Type"::"Cash Flow Total Accounts"
                        ELSE
                            LiqAccSchedLine."Totaling Type" := LiqAccSchedLine."Totaling Type"::"Cash Flow Entry Accounts";
                        LiqAccSchedLine.INSERT;
                        RecRef.GETTABLE(LiqAccSchedLine);
                    //ChangeLogMgt.LogInsertion(RecRef);
                    UNTIL LiqAcc.NEXT = 0;
            END;
        END;
    END;

    PROCEDURE SetAccSchedName(VAR NewAccSchedName: Record "Acc. Schedule Name");
    BEGIN
        LiqAccSchedName := NewAccSchedName;
    END;

    LOCAL PROCEDURE IncludeClosingDate(Date: Date; UseClosingDate: Boolean): Date;
    BEGIN
        if UseClosingDate THEN
            EXIT(CLOSINGDATE(Date));
        EXIT(Date);
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
                    ERROR(Text1140020, DimTotaling)
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

        CheckAnalysisView(LiqAccSchedName.Name, '', FALSE);

        CASE DimNo OF
            1:
                DimCode := LiquidityAnalysisView."Dimension 1 Code";
            2:
                DimCode := LiquidityAnalysisView."Dimension 2 Code";
            3:
                DimCode := LiquidityAnalysisView."Dimension 3 Code";
            4:
                DimCode := LiquidityAnalysisView."Dimension 4 Code";
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
                        ERROR(Text1140020, DimTotaling);
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

    PROCEDURE CheckAnalysisView(CurrentSchedName: Code[10]; CurrentColumnName: Code[10]; TestColumnName: Boolean);
    VAR
        LiqAccountScheduleColumn2: Record "Column Layout";
        AnyColumnDimensions: Boolean;
    BEGIN
        if NOT AnalysisViewRead THEN BEGIN
            AnalysisViewRead := TRUE;
            if CurrentSchedName <> LiqAccSchedName.Name THEN BEGIN
                CheckTemplateName(CurrentSchedName);
                LiqAccSchedName.GET(CurrentSchedName);
            END;
            if TestColumnName THEN
                if CurrentColumnName <> LiqAccScheduleLayoutName.Name THEN BEGIN
                    CheckColumnTemplateName(CurrentColumnName);
                    LiqAccScheduleLayoutName.GET(CurrentColumnName);
                END;
            if LiqAccSchedName."Analysis View Name" = '' THEN BEGIN
                if NOT GLSetupRead THEN
                    GLSetup.GET;
                GLSetupRead := TRUE;
                LiquidityAnalysisView.INIT;
                LiquidityAnalysisView."Dimension 1 Code" := GLSetup."Global Dimension 1 Code";
                LiquidityAnalysisView."Dimension 2 Code" := GLSetup."Global Dimension 2 Code";
            END ELSE
                LiquidityAnalysisView.GET(LiqAccSchedName."Analysis View Name");
            if (LiqAccSchedName."Analysis View Name" <> LiqAccScheduleLayoutName."Analysis View Name") THEN BEGIN
                AnyColumnDimensions := FALSE;
                LiqAccountScheduleColumn2.SETRANGE("Column Layout Name", LiqAccScheduleLayoutName.Name);
                if LiqAccountScheduleColumn2.FIND('-') THEN
                    REPEAT
                        AnyColumnDimensions :=
                          (LiqAccountScheduleColumn2."Dimension 1 Totaling" <> '') OR
                          (LiqAccountScheduleColumn2."Dimension 2 Totaling" <> '') OR
                          (LiqAccountScheduleColumn2."Dimension 3 Totaling" <> '') OR
                          (LiqAccountScheduleColumn2."Dimension 4 Totaling" <> '');
                    UNTIL AnyColumnDimensions OR (LiqAccountScheduleColumn2.NEXT = 0);
                if AnyColumnDimensions THEN
                    ERROR(
                      Text1140044,
                      LiqAccSchedName.FIELDCAPTION("Analysis View Name"),
                      LiqAccSchedName.TABLECAPTION,
                      LiqAccSchedName."Analysis View Name",
                      LiqAccScheduleLayoutName.FIELDCAPTION("Analysis View Name"),
                      LiqAccScheduleLayoutName.TABLECAPTION,
                      LiqAccScheduleLayoutName."Analysis View Name");
            END;
        END;
    END;

    LOCAL PROCEDURE InitBasePercents(LiqAccSchedLine: Record 85; LiqAccountScheduleColumn: Record "Column Layout");
    VAR
        BaseIdx: Integer;
    BEGIN
        CLEAR(BasePercentLine);
        BaseIdx := 0;

        WITH LiqAccSchedLine DO BEGIN
            SETRANGE("Schedule Name", "Schedule Name");
            if FIND('-') THEN
                REPEAT
                    if "Totaling Type" = "Totaling Type"::"Set Base For Percent" THEN BEGIN
                        BaseIdx := BaseIdx + 1;
                        if BaseIdx > ARRAYLEN(BasePercentLine) THEN
                            ShowError(
                              STRSUBSTNO(Text1140042, ARRAYLEN(BasePercentLine), FIELDCAPTION("Totaling Type"), "Totaling Type"),
                              LiqAccSchedLine, LiqAccountScheduleColumn);
                        BasePercentLine[BaseIdx] := "Line No.";
                    END;
                UNTIL NEXT = 0;
        END;

        if BaseIdx = 0 THEN BEGIN
            LiqAccSchedLine."Totaling Type" := LiqAccSchedLine."Totaling Type"::"Set Base For Percent";
            ShowError(
              STRSUBSTNO(Text1140043, LiqAccSchedLine.FIELDCAPTION("Totaling Type"), LiqAccSchedLine."Totaling Type"),
              LiqAccSchedLine, LiqAccountScheduleColumn);
        END;
    END;

    LOCAL PROCEDURE GetBasePercentLine(LiqAccSchedLine: Record 85; LiqAccountScheduleColumn: Record "Column Layout"): Integer;
    VAR
        BaseIdx: Integer;
    BEGIN
        if BasePercentLine[1] = 0 THEN
            InitBasePercents(LiqAccSchedLine, LiqAccountScheduleColumn);

        BaseIdx := ARRAYLEN(BasePercentLine);
        REPEAT
            if BasePercentLine[BaseIdx] <> 0 THEN
                if BasePercentLine[BaseIdx] < LiqAccSchedLine."Line No." THEN
                    EXIT(BasePercentLine[BaseIdx]);
            BaseIdx := BaseIdx - 1;
        UNTIL BaseIdx = 0;

        LiqAccSchedLine."Totaling Type" := LiqAccSchedLine."Totaling Type"::"Set Base For Percent";
        ShowError(
          STRSUBSTNO(Text1140043, LiqAccSchedLine.FIELDNAME("Totaling Type"), LiqAccSchedLine."Totaling Type"),
          LiqAccSchedLine, LiqAccountScheduleColumn);
    END;

    PROCEDURE CalcCellValuexDate(LiqAccSchedLine: Record 85; LiqAccSchedColumn: Record "Column Layout"; FechaD: Date; FechaH: Date): Decimal;
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

    PROCEDURE CalcCellxDate(VAR LiqAccSchedLine: Record 85; VAR LiqAccSchedColumn: Record "Column Layout"; FechaD: Date; FechaH: Date): Decimal;
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

    PROCEDURE CalcLiqAccountxDate(VAR LiqAcc: Record "Cash Flow Account"; VAR LiqAccountScheduleLine: Record 85; VAR LiqAccountScheduleColumn2: Record "Column Layout"; FechaD: Date; FechaH: Date) ColValue: Decimal;
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
    BEGIN
        ColValue := 0;
        if LiqAccSchedName.Name <> LiqAccountScheduleLine."Schedule Name" THEN
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
                LiqAccountScheduleColumn2."Ledger Entry Type"::Entries:
                    BEGIN
                        if LiqAccSchedName."Analysis View Name" = '' THEN
                            WITH LiquidityLedgerEntry DO BEGIN
                                SETCURRENTKEY(
                                   "Cash Flow Account No.", "Cash Flow Forecast No.", "Global Dimension 1 Code",
                                   "Global Dimension 2 Code", "Cash Flow Date");
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
                                LiqAccountScheduleLine.COPYFILTER("Cash Flow Forecast Filter", "Cash Flow Forecast No.");
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

    PROCEDURE ExisteFecha(Fecha: Date; VAR LiqAccSchedLine: Record 85): Boolean;
    VAR
        rLig: Record "Cash Flow Forecast Entry";
        rEmp: Record 2000000006;
        Control: Codeunit ControlProcesos;
    BEGIN
        if LiqAccSchedLine.Totaling = '' THEN EXIT(TRUE);
        rEmp.SetRange("Evaluation Company", false);
        if rEmp.FINDFIRST THEN
            REPEAT
                if Control.Permiso_Empresas(rEmp.Name) Then begin
                    rLig.CHANGECOMPANY(rEmp.Name);
                    rLig.SETFILTER(rLig."Cash Flow Account No.", LiqAccSchedLine.Totaling);
                    rLig.SETRANGE(rLig."Cash Flow Date", Fecha);
                    if rLig.FINDFIRST THEN EXIT(TRUE);
                end;
            UNTIL rEmp.NEXT = 0;
        EXIT(FALSE);
    END;

    PROCEDURE EvaluateExpressionxFecha(IsAccSchedLineExpression: Boolean; Expression: Text[80]; LiqAccSchedLine: Record 85; LiqAccSchedColumn: Record "Column Layout"; FechaD: Date; FechaH: Date): Decimal;
    VAR
        LiqAccSchedLine2: Record 85;
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


}

