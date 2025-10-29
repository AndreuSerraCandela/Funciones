/// <summary>
/// Codeunit Panorama (ID 7001146).
/// </summary>
Codeunit 7001114 Panorama
{
    var
        EndDate: Date;
        StartDate: Date;
        FiscalStartDate: Date;
        Control: Codeunit ControlProcesos;

    PROCEDURE CalcVeAcc(VAR GLAcc: Record Vendor; VAR AccSchedLine: Record 85; VAR ColumnLayout: Record 334; CalcAddCurr: Boolean) ColValue: Decimal;
    VAR
        GLEntry: Record "G/L Entry";
        GLBudgEntry: Record 96;
        AnalysisViewEntry: Record 365;
        AnalysisViewBudgetEntry: Record 366;
        AmountType: Option "Net Amount","Debit Amount","Credit Amount";
        TestBalance: Boolean;
        Balance: Decimal;
        UseBusUnitFilter: Boolean;
        UseDimFilter: Boolean;
        AccSchedName: Record "Acc. Schedule Name";
        AccSchedManagement: Codeunit AccSchedManagement;

    BEGIN

        //ASC 09/12/09
        if ColumnLayout.Empresa <> '' THEN begin
            if not Control.Permiso_Empresas(ColumnLayout.Empresa) then begin
                ColValue := 0;
                exit(0);
            end;
            GLEntry.CHANGECOMPANY(ColumnLayout.Empresa);
        end;
        if AccSchedLine.Company <> '' THEN begin

            if not Control.Permiso_Empresas(AccSchedLine.Company) then begin
                ColValue := 0;
                exit(0);
            end;
            GLEntry.CHANGECOMPANY(AccSchedLine.Company);
        end;
        if (ColumnLayout.Empresa <> '') AND
         (AccSchedLine.Company <> '') AND
         (AccSchedLine.Company <> ColumnLayout.Empresa) THEN
            EXIT(0);
        ColValue := 0;
        GLEntry.SETFILTER("G/L Account No.", '%1..%2|%3..%4|%5..%6|7..%8|%9..%10',
        '400000001', '400499999:', '4100', '4109:', '4030', '4039:', '4010', '4019:', '4110', '4119:');
        GLEntry.SETRANGE("Gen. Posting Type", GLEntry."Gen. Posting Type"::" ");
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
                                SETFILTER("Global Dimension 1 Code", AccSchedManagement.GetDimTotalingFilter(1, AccSchedLine."Dimension 1 Totaling"));
                                SETFILTER("Global Dimension 2 Code", AccSchedManagement.GetDimTotalingFilter(2, AccSchedLine."Dimension 2 Totaling"));
                                SETFILTER("Global Dimension 3 Code", AccSchedManagement.GetDimTotalingFilter(3, AccSchedLine."Dimension 3 Totaling"));
                                SETFILTER("Global Dimension 4 Code", AccSchedManagement.GetDimTotalingFilter(4, AccSchedLine."Dimension 4 Totaling"));
                                SETFILTER("Global Dimension 5 Code", AccSchedManagement.GetDimTotalingFilter(5, AccSchedLine."Dimension 5 Totaling"));
                                FILTERGROUP(6);
                                SETFILTER("Global Dimension 1 Code", AccSchedManagement.GetDimTotalingFilter(1, ColumnLayout."Dimension 1 Totaling"));
                                SETFILTER("Global Dimension 2 Code", AccSchedManagement.GetDimTotalingFilter(2, ColumnLayout."Dimension 2 Totaling"));
                                SETFILTER("Global Dimension 3 Code", AccSchedManagement.GetDimTotalingFilter(3, ColumnLayout."Dimension 3 Totaling"));
                                SETFILTER("Global Dimension 4 Code", AccSchedManagement.GetDimTotalingFilter(4, ColumnLayout."Dimension 4 Totaling"));
                                SETFILTER("Global Dimension 5 Code", AccSchedManagement.GetDimTotalingFilter(5, ColumnLayout."Dimension 5 Totaling"));

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
                                SETFILTER("Dimension 1 Value Code", AccSchedManagement.GetDimTotalingFilter(1, AccSchedLine."Dimension 1 Totaling"));
                                SETFILTER("Dimension 2 Value Code", AccSchedManagement.GetDimTotalingFilter(2, AccSchedLine."Dimension 2 Totaling"));
                                SETFILTER("Dimension 3 Value Code", AccSchedManagement.GetDimTotalingFilter(3, AccSchedLine."Dimension 3 Totaling"));
                                SETFILTER("Dimension 4 Value Code", AccSchedManagement.GetDimTotalingFilter(4, AccSchedLine."Dimension 4 Totaling"));
                                SETFILTER("Dimension 5 Value Code", AccSchedManagement.GetDimTotalingFilter(5, AccSchedLine."Dimension 5 Totaling"));
                                FILTERGROUP(6);
                                SETFILTER("Dimension 1 Value Code", AccSchedManagement.GetDimTotalingFilter(1, ColumnLayout."Dimension 1 Totaling"));
                                SETFILTER("Dimension 2 Value Code", AccSchedManagement.GetDimTotalingFilter(2, ColumnLayout."Dimension 2 Totaling"));
                                SETFILTER("Dimension 3 Value Code", AccSchedManagement.GetDimTotalingFilter(3, ColumnLayout."Dimension 3 Totaling"));
                                SETFILTER("Dimension 4 Value Code", AccSchedManagement.GetDimTotalingFilter(4, ColumnLayout."Dimension 4 Totaling"));
                                SETFILTER("Dimension 5 Value Code", AccSchedManagement.GetDimTotalingFilter(5, ColumnLayout."Dimension 5 Totaling"));
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

    PROCEDURE CalcCuAcc(VAR GLAcc: Record Customer; VAR AccSchedLine: Record 85; VAR ColumnLayout: Record 334; CalcAddCurr: Boolean) ColValue: Decimal;
    VAR
        GLEntry: Record "G/L Entry";
        GLBudgEntry: Record 96;
        AnalysisViewEntry: Record 365;
        AnalysisViewBudgetEntry: Record 366;
        AmountType: Option "Net Amount","Debit Amount","Credit Amount";
        TestBalance: Boolean;
        Balance: Decimal;
        UseBusUnitFilter: Boolean;
        UseDimFilter: Boolean;
        AccSchedName: Record "Acc. Schedule Name";
        AccSchedManagement: Codeunit AccSchedManagement;
    BEGIN
        //ASC 09/12/09
        if ColumnLayout.Empresa <> '' THEN begin
            if not Control.Permiso_Empresas(ColumnLayout.Empresa) then begin
                ColValue := 0;
                exit(0);
            end;

        end;
        if AccSchedLine.Company <> '' THEN begin

            if not Control.Permiso_Empresas(AccSchedLine.Company) then begin
                ColValue := 0;
                exit(0);
            end;
        end;
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
                                SETFILTER("Global Dimension 1 Code", AccSchedManagement.GetDimTotalingFilter(1, AccSchedLine."Dimension 1 Totaling"));
                                SETFILTER("Global Dimension 2 Code", AccSchedManagement.GetDimTotalingFilter(2, AccSchedLine."Dimension 2 Totaling"));
                                SETFILTER("Global Dimension 3 Code", AccSchedManagement.GetDimTotalingFilter(3, AccSchedLine."Dimension 3 Totaling"));
                                SETFILTER("Global Dimension 4 Code", AccSchedManagement.GetDimTotalingFilter(4, AccSchedLine."Dimension 4 Totaling"));
                                SETFILTER("Global Dimension 5 Code", AccSchedManagement.GetDimTotalingFilter(5, AccSchedLine."Dimension 5 Totaling"));
                                FILTERGROUP(6);
                                SETFILTER("Global Dimension 1 Code", AccSchedManagement.GetDimTotalingFilter(1, ColumnLayout."Dimension 1 Totaling"));
                                SETFILTER("Global Dimension 2 Code", AccSchedManagement.GetDimTotalingFilter(2, ColumnLayout."Dimension 2 Totaling"));
                                SETFILTER("Global Dimension 3 Code", AccSchedManagement.GetDimTotalingFilter(3, ColumnLayout."Dimension 3 Totaling"));
                                SETFILTER("Global Dimension 4 Code", AccSchedManagement.GetDimTotalingFilter(4, ColumnLayout."Dimension 4 Totaling"));
                                SETFILTER("Global Dimension 5 Code", AccSchedManagement.GetDimTotalingFilter(5, ColumnLayout."Dimension 5 Totaling"));
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
                                SETFILTER("Dimension 1 Value Code", AccSchedManagement.GetDimTotalingFilter(1, AccSchedLine."Dimension 1 Totaling"));
                                SETFILTER("Dimension 2 Value Code", AccSchedManagement.GetDimTotalingFilter(2, AccSchedLine."Dimension 2 Totaling"));
                                SETFILTER("Dimension 3 Value Code", AccSchedManagement.GetDimTotalingFilter(3, AccSchedLine."Dimension 3 Totaling"));
                                SETFILTER("Dimension 4 Value Code", AccSchedManagement.GetDimTotalingFilter(4, AccSchedLine."Dimension 4 Totaling"));
                                SETFILTER("Dimension 5 Value Code", AccSchedManagement.GetDimTotalingFilter(5, AccSchedLine."Dimension 5 Totaling"));
                                FILTERGROUP(6);
                                SETFILTER("Dimension 1 Value Code", AccSchedManagement.GetDimTotalingFilter(1, ColumnLayout."Dimension 1 Totaling"));
                                SETFILTER("Dimension 2 Value Code", AccSchedManagement.GetDimTotalingFilter(2, ColumnLayout."Dimension 2 Totaling"));
                                SETFILTER("Dimension 3 Value Code", AccSchedManagement.GetDimTotalingFilter(3, ColumnLayout."Dimension 3 Totaling"));
                                SETFILTER("Dimension 4 Value Code", AccSchedManagement.GetDimTotalingFilter(4, ColumnLayout."Dimension 4 Totaling"));
                                SETFILTER("Dimension 5 Value Code", AccSchedManagement.GetDimTotalingFilter(5, ColumnLayout."Dimension 5 Totaling"));
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
        AccountingPeriodMgt: Codeunit "Accounting Period Mgt.";
        Text005: Label 'M';
        Text006: Label 'T';
        Text007: Label 'A';
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
                FiscalStartDate2 := AccountingPeriodMgt.FindFiscalYear(ToDate);
            END ELSE
                if "Comparison Period Formula" <> '' THEN BEGIN
                    AccPeriodStartEnd("Comparison Period Formula", StartDate, FromDate, ToDate);
                    FiscalStartDate2 := AccountingPeriodMgt.FindFiscalYear(ToDate);
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
                              "Date Filter", CALCDATE('<+1D>', ToDate), AccountingPeriodMgt.FindEndOfFiscalYear(FiscalStartDate2));
                        AccSchedLine2."Row Type"::"Beginning Balance":
                            GLAcc.SETRANGE("Date Filter", 0D, ToDate);
                        AccSchedLine2."Row Type"::"Balance at Date":
                            GLAcc.SETRANGE("Date Filter", 0D, AccountingPeriodMgt.FindEndOfFiscalYear(ToDate));
                    END;
                "Column Type"::"Entire Fiscal Year":
                    CASE AccSchedLine2."Row Type" OF
                        AccSchedLine2."Row Type"::"Net Change":
                            GLAcc.SETRANGE(
                              "Date Filter",
                              FiscalStartDate2,
                              AccountingPeriodMgt.FindEndOfFiscalYear(FiscalStartDate2));
                        AccSchedLine2."Row Type"::"Beginning Balance":
                            GLAcc.SETFILTER("Date Filter", '<%1', FiscalStartDate2);  // always includes closing date
                        AccSchedLine2."Row Type"::"Balance at Date":
                            GLAcc.SETRANGE("Date Filter", 0D, AccountingPeriodMgt.FindEndOfFiscalYear(ToDate));
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
        AccountingPeriodMgt: Codeunit "Accounting Period Mgt.";
        Text005: Label 'M';
        Text006: Label 'T';
        Text007: Label 'A';
        AccScheludedMgt: Codeunit AccSchedManagement;
    BEGIN
        StartDate := AccSchedLine2.GetRangeMin("Date Filter");
        if EndDate <> AccSchedLine2.GetRangeMax("Date Filter") then begin
            EndDate := AccSchedLine2.GetRangeMax("Date Filter");
            FiscalStartDate := AccountingPeriodMgt.FindFiscalYear(EndDate);
        end;
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
                FiscalStartDate2 := AccountingPeriodMgt.FindFiscalYear(ToDate);
            END ELSE
                if "Comparison Period Formula" <> '' THEN BEGIN
                    AccPeriodStartEnd("Comparison Period Formula", StartDate, FromDate, ToDate);
                    FiscalStartDate2 := AccountingPeriodMgt.FindFiscalYear(ToDate);
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
                              "Date Filter", CALCDATE('<+1D>', ToDate), AccountingPeriodMgt.FindEndOfFiscalYear(FiscalStartDate2));
                        AccSchedLine2."Row Type"::"Beginning Balance":
                            GLAcc.SETRANGE("Date Filter", 0D, ToDate);
                        AccSchedLine2."Row Type"::"Balance at Date":
                            GLAcc.SETRANGE("Date Filter", 0D, AccountingPeriodMgt.FindEndOfFiscalYear(ToDate));
                    END;
                "Column Type"::"Entire Fiscal Year":
                    CASE AccSchedLine2."Row Type" OF
                        AccSchedLine2."Row Type"::"Net Change":
                            GLAcc.SETRANGE(
                              "Date Filter",
                              FiscalStartDate2,
                              AccountingPeriodMgt.FindEndOfFiscalYear(FiscalStartDate2));
                        AccSchedLine2."Row Type"::"Beginning Balance":
                            GLAcc.SETFILTER("Date Filter", '<%1', FiscalStartDate2);  // always includes closing date
                        AccSchedLine2."Row Type"::"Balance at Date":
                            GLAcc.SETRANGE("Date Filter", 0D, AccountingPeriodMgt.FindEndOfFiscalYear(ToDate));
                    END;
            END;
        END;
    END;

    /// <summary>
    /// AccPeriodStartEnd.
    /// </summary>
    /// <param name="Formula">Code[20].</param>
    /// <param name="Date">Date.</param>
    /// <param name="VAR StartDate">Date.</param>
    /// <param name="VAR EndDate">Date.</param>
    procedure AccPeriodStartEnd(Formula: Code[20]; Date: Date; VAR StartDate: Date; VAR EndDate: Date);
    VAR
        ColumnLayout: Record 334;
        AccountingPeriod: Record 50;
        AccountingPeriodFY: Record 50;
        Steps: Integer;
        Type: Option " ",Period,"Fiscal year","Fiscal Halfyear","Fiscal Quarter";
        CurrentPeriodNo: Integer;
        RangeFromType: Option Int,CP,LP;
        RangeToType: Option Int,CP,LP;
        RangeFromInt: Integer;
        RangeToInt: Integer;
        PeriodError: Boolean;
    BEGIN
        if Formula = '' THEN
            EXIT;

        ColumnLayout.ParsePeriodFormula(
          Formula, Steps, Type, RangeFromType, RangeToType, RangeFromInt, RangeToInt);

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

    /// <summary>
    /// AccPeriodStartOrEnd.
    /// </summary>
    /// <param name="AccountingPeriod">Record 50.</param>
    /// <param name="CurrentPeriodNo">Integer.</param>
    /// <param name="RangeType">Option Int,CP,LP.</param>
    /// <param name="RangeInt">Integer.</param>
    /// <param name="EndDate">Boolean.</param>
    /// <param name="VAR Date">Date.</param>
    procedure AccPeriodStartOrEnd(AccountingPeriod: Record 50; CurrentPeriodNo: Integer; RangeType: Option Int,CP,LP; RangeInt: Integer; EndDate: Boolean; VAR Date: Date);
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

    /// <summary>
    /// AccPeriodGetPeriod.
    /// </summary>
    /// <param name="VAR AccountingPeriod">Record 50.</param>
    /// <param name="AccPeriodNo">Integer.</param>
    /// <returns>Return value of type Date.</returns>
    procedure AccPeriodGetPeriod(VAR AccountingPeriod: Record 50; AccPeriodNo: Integer): Date;
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

    /// <summary>
    /// AccPeriodEndDate.
    /// </summary>
    /// <param name="StartDate">Date.</param>
    /// <returns>Return value of type Date.</returns>
    procedure AccPeriodEndDate(StartDate: Date): Date;
    VAR
        AccountingPeriod: Record 50;
    BEGIN
        AccountingPeriod."Starting Date" := StartDate;
        if AccountingPeriod.FIND('>') THEN
            EXIT(AccountingPeriod."Starting Date" - 1);
        EXIT(99991231D);
    END;
}