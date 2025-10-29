/// <summary>
/// Report Trial Balance Ces (ID 50036).
/// </summary>
report 50026 "Trial Balance Ces"
{
    DefaultLayout = RDLC;
    RDLCLayout = './src/report/layout/TrialBalance.rdlc';
    Caption = 'Balance Malla';
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;
    dataset
    {
        dataitem("G/L Account"; 15)
        {
            DataItemTableView = SORTING("No.");
            RequestFilterFields = "No.", "Account Type", "Date Filter", "Global Dimension 1 Filter", "Global Dimension 2 Filter";

            column(WorkDateFormatted; FORMAT(WORKDATE, 0, 4))
            {
            }
            column(PeriodText1; Text1100003 + PeriodText)
            {
            }
            column(CompanyName; COMPANYNAME)
            {
            }
            column(PeriodText; PeriodText)
            {
            }
            column(HeaderText; HeaderText)
            {
            }
            column(IncludeEntries; IncludeEntries)
            {
            }
            column(GLFilter_GLAccount; "G/L Account".TABLECAPTION + ': ' + "G/L Account".GETFILTERS)
            {
            }
            column(GLFilter; GLFilter)
            {
            }
            column(AcumBalance; AcumBalance)
            {
            }
            column(TotalDebitAmtAtEnd; TotalDebitAmtAtEnd)
            {
            }
            column(TotalCreditAmtAtEnd; TotalCreditAmtAtEnd)
            {
            }
            column(TotalBalanceAtEnd; TotalBalanceAtEnd)
            {
            }
            column(TotalPeriodDebitAmt; TotalPeriodDebitAmt)
            {
            }
            column(TotalPeriodCreditAmt; TotalPeriodCreditAmt)
            {
            }
            column(No1_GLAccount; "No.")
            {
            }
            column(TrialBalanceCaption; TrialBalanceCaptionLbl)
            {
            }
            column(PageCaption; PageCaptionLbl)
            {
            }
            column(AccinPeriodCaption; AccinPeriodCaptionLbl)
            {
            }
            column(AccPeriodatDateCaption; AccPeriodatDateCaptionLbl)
            {
            }
            column(AccountCaption; AccountCaptionLbl)
            {
            }
            column(NameCaption; NameCaptionLbl)
            {
            }
            column(DebitCaption; DebitCaptionLbl)
            {
            }
            column(CreditCaption; CreditCaptionLbl)
            {
            }
            column(BalanceatDateCaption; BalanceatDateCaptionLbl)
            {
            }
            column(AcumBalanceatDateCaption; AcumBalanceatDateCaptionLbl)
            {
            }
            column(TotalCaption; TotalCaptionLbl)
            {
            }
            dataitem(DataItem5444; Integer)
            {
                DataItemTableView = SORTING(Number)
                                    WHERE(Number = CONST(1));
                column(No_GLAccount; "G/L Account"."No.")
                {
                }
                column(IndentName_GLAccount; PADSTR('', "G/L Account".Indentation * 2) + "G/L Account".Name)
                {
                }
                column(DebitAmount_GLAccount; "G/L Account"."Debit Amount" + OpenDebitAmt + CloseDebitAmt)
                {
                }
                column(CreditAmount_GLAccount; "G/L Account"."Credit Amount" + OpenCreditAmt + CloseCreditAmt)
                {
                }
                column(DebitAmount2_GLAccount; GLAcc2."Debit Amount" + OpenDebitAmtEnd + CloseDebitAmt)
                {
                }
                column(CreditAmount2_GLAccount; GLAcc2."Credit Amount" + OpenCreditAmtEnd + CloseCreditAmt)
                {
                }
                column(BalanceType; BalanceType)
                {
                }
                column(CreditAmount3_GLAccount; GLAcc2."Add.-Currency Credit Amount" + OpenCreditAmtEnd + CloseCreditAmt)
                {
                }
                column(DebitAmount3_GLAccount; GLAcc2."Add.-Currency Debit Amount" + OpenDebitAmtEnd + CloseDebitAmt)
                {
                }
                column(CreditAmount4_GLAccount; "G/L Account"."Add.-Currency Credit Amount" + OpenCreditAmt + CloseCreditAmt)
                {
                }
                column(DebitAmount4_GLAccount; "G/L Account"."Add.-Currency Debit Amount" + OpenDebitAmt + CloseDebitAmt)
                {
                }
                column(AccountType_GLAccount; FORMAT("G/L Account"."Account Type", 0, 2))
                {
                }
                column(GLFilterOption; FORMAT(GLFilterOption, 0, 2))
                {
                }
                column(NoofBlankLines_GLAccount; "G/L Account"."No. of Blank Lines")
                {
                }
                column(PrintAmountsInAddCurrency; PrintAmountsInAddCurrency)
                {
                }
                column(PageGroupNo; PageGroupNo)
                {
                }
                column(AccountType_GLAcc; "G/L Account"."Account Type")
                {
                }
                dataitem(BlankLineRepeater; Integer)
                {
                    column(BlankLineNo; BlankLineNo)
                    {
                    }

                    trigger OnAfterGetRecord()
                    begin
                        if BlankLineNo = 0 THEN
                            CurrReport.BREAK;

                        BlankLineNo -= 1;
                    end;
                }

                trigger OnAfterGetRecord()
                begin
                    BlankLineNo := "G/L Account"."No. of Blank Lines" + 1;
                end;
            }

            trigger OnAfterGetRecord()
            begin
                Accumulate := FALSE;
                CALCFIELDS("Debit Amount", "Credit Amount", "Balance at Date", "Add.-Currency Debit Amount",
                           "Add.-Currency Credit Amount", "Add.-Currency Balance at Date", "Net Change", "Balance at Date");
                GLAcc2 := "G/L Account";
                SetGLAccDateFilter;
                if GlobalDim1 <> '' THEN
                    "G/L Account".COPYFILTER("G/L Account"."Global Dimension 1 Filter", GLAcc2."Global Dimension 1 Filter");
                if GlobalDim2 <> '' THEN
                    "G/L Account".COPYFILTER("G/L Account"."Global Dimension 2 Filter", GLAcc2."Global Dimension 2 Filter");
                GLAcc2.CALCFIELDS("Additional-Currency Net Change", "Net Change", "Debit Amount", "Credit Amount",
                                  "Add.-Currency Debit Amount", "Add.-Currency Credit Amount", "Balance at Date");
                if PrintAmountsInAddCurrency THEN BEGIN
                    PreviousBalance := GLAcc2."Additional-Currency Net Change";
                    BalanceType := GLAcc2."Additional-Currency Net Change";
                    if AcumBalance THEN
                        BalanceType := GLAcc2."Add.-Currency Balance at Date";
                END ELSE BEGIN
                    PreviousBalance := GLAcc2."Net Change";
                    BalanceType := GLAcc2."Net Change";
                    if AcumBalance THEN
                        BalanceType := GLAcc2."Balance at Date";
                END;
                OpenCreditAmt := 0;
                OpenDebitAmt := 0;
                OpenCreditAmtEnd := 0;
                OpenDebitAmtEnd := 0;
                if OpenEntries THEN BEGIN
                    if "Account Type" = "Account Type"::Heading THEN
                        CalcOpenEntriesHeading
                    ELSE
                        CalcOpenEntries;
                    if NOT AcumBalance THEN
                        BalanceType := BalanceType + OpenDebitAmtEnd - OpenCreditAmtEnd;
                END;
                CloseDebitAmt := 0;
                CloseCreditAmt := 0;
                if CloseEntries THEN BEGIN
                    if "Account Type" = "Account Type"::Heading THEN
                        CalcCloseEntriesHeading
                    ELSE
                        CalcCloseEntries;
                    if NOT AcumBalance THEN
                        BalanceType := BalanceType + CloseDebitAmt - CloseCreditAmt
                    ELSE
                        BalanceType := GLAcc2."Net Change" - BalanceType;
                END;

                if AcumBalance AND (NOT OpenEntries) AND (NOT CloseEntries) THEN
                    BalanceType := GLAcc2."Net Change";

                PreviousDebit := 0;
                PreviousCredit := 0;
                if PreviousBalance > 0 THEN
                    PreviousDebit := PreviousBalance
                ELSE
                    PreviousCredit := ABS(PreviousBalance);
                GLAcc.SETRANGE("Date Filter", FromFec, ToFec);
                if GlobalDim1 <> '' THEN
                    "G/L Account".COPYFILTER("G/L Account"."Global Dimension 1 Filter", GLAcc2."Global Dimension 1 Filter");
                if GlobalDim2 <> '' THEN
                    "G/L Account".COPYFILTER("G/L Account"."Global Dimension 2 Filter", GLAcc2."Global Dimension 2 Filter");
                GLAcc.CALCFIELDS("Debit Amount", "Credit Amount", "Add.-Currency Debit Amount", "Add.-Currency Credit Amount",
                  "Net Change", "Balance at Date");
                if NOT PrintAmountsInAddCurrency THEN BEGIN
                    PeriodDebitAmt := GLAcc."Debit Amount";
                    PeriodCreditAmt := GLAcc."Credit Amount";
                    BalanceAtEnd := BalanceAtEnd + PreviousBalance;
                    DebitAmtAtEnd := GLAcc2."Debit Amount";
                    CreditAmtAtEnd := GLAcc2."Credit Amount";
                    I := I + 1;
                    if I = 1 THEN
                        FixedLevel := STRLEN("No.");
                    if (COPYSTR("No.", 1, 1) <> PrevAccount) AND (STRLEN("No.") >= FixedLevel) THEN BEGIN
                        Accumulate := TRUE;
                        FirstLevel := STRLEN("No.");
                    END ELSE
                        if (STRLEN("No.") <= PreviousLevel) AND (STRLEN("No.") <= FirstLevel) AND (STRLEN("No.") >= FixedLevel) THEN
                            Accumulate := TRUE
                        ELSE
                            Accumulate := FALSE;
                    if Accumulate OR (GLFilterOption = GLFilterOption::Posting) THEN BEGIN
                        TotalPeriodDebitAmt := TotalPeriodDebitAmt + "Debit Amount" + CloseDebitAmt;
                        TotalPeriodCreditAmt := TotalPeriodCreditAmt + "Credit Amount" + CloseCreditAmt;
                        if IsOpenDate THEN BEGIN
                            TotalPeriodDebitAmt := TotalPeriodDebitAmt + OpenDebitAmt;
                            TotalPeriodCreditAmt := TotalPeriodCreditAmt + OpenCreditAmt;
                        END;
                        TotalDebitAmtAtEnd := TotalDebitAmtAtEnd + DebitAmtAtEnd + OpenDebitAmtEnd + CloseDebitAmt;
                        TotalCreditAmtAtEnd := TotalCreditAmtAtEnd + CreditAmtAtEnd + OpenCreditAmtEnd + CloseCreditAmt;
                        if OpenEntries OR CloseEntries THEN
                            TotalBalanceAtEnd := TotalBalanceAtEnd + BalanceType
                        ELSE
                            TotalBalanceAtEnd := TotalBalanceAtEnd + BalanceAtEnd;
                    END;
                END ELSE BEGIN
                    PeriodDebitAmt := GLAcc."Add.-Currency Debit Amount";
                    PeriodCreditAmt := GLAcc."Add.-Currency Credit Amount";
                    BalanceAtEnd := BalanceAtEnd + PreviousBalance;
                    DebitAmtAtEnd := GLAcc2."Add.-Currency Debit Amount";
                    CreditAmtAtEnd := GLAcc2."Add.-Currency Credit Amount";
                    if COPYSTR("No.", 1, 1) <> PrevAccount THEN BEGIN
                        Accumulate := TRUE;
                        FirstLevel := STRLEN("No.");
                    END ELSE
                        if (STRLEN("No.") <= PreviousLevel) AND (STRLEN("No.") <= FirstLevel) THEN
                            Accumulate := TRUE
                        ELSE
                            Accumulate := FALSE;
                    if Accumulate OR (GLFilterOption = GLFilterOption::Posting) THEN BEGIN
                        TotalPeriodDebitAmt := TotalPeriodDebitAmt + "Add.-Currency Debit Amount" + CloseDebitAmt;
                        TotalPeriodCreditAmt := TotalPeriodCreditAmt + "Add.-Currency Credit Amount" + CloseCreditAmt;
                        if IsOpenDate THEN BEGIN
                            TotalPeriodDebitAmt := TotalPeriodDebitAmt + OpenDebitAmt;
                            TotalPeriodCreditAmt := TotalPeriodCreditAmt + OpenCreditAmt;
                        END;
                        TotalDebitAmtAtEnd := TotalDebitAmtAtEnd + DebitAmtAtEnd + OpenDebitAmtEnd + CloseDebitAmt;
                        TotalCreditAmtAtEnd := TotalCreditAmtAtEnd + CreditAmtAtEnd + OpenCreditAmtEnd + CloseCreditAmt;
                        if OpenEntries OR CloseEntries THEN
                            TotalBalanceAtEnd := TotalBalanceAtEnd + BalanceType
                        ELSE
                            TotalBalanceAtEnd := TotalBalanceAtEnd + BalanceAtEnd;
                    END;
                END;

                if (STRLEN("No.") >= FixedLevel) THEN BEGIN
                    PreviousLevel := STRLEN("No.");
                    PrevAccount := COPYSTR("No.", 1, 1);
                END;

                if PrintAllHavingBal AND ("Balance at Date" = 0) THEN //--AND ("Debit Amount" = 0) AND ("Credit Amount" = 0) THEN
                    CurrReport.SKIP;

                if GlobalNo < 1 THEN BEGIN
                    GLSetup.GET;
                    if PrintAmountsInAddCurrency THEN
                        HeaderText := STRSUBSTNO(Text1100004, GLSetup."Additional Reporting Currency")
                    ELSE BEGIN
                        GLSetup.TESTFIELD("LCY Code");
                        HeaderText := STRSUBSTNO(Text1100004, GLSetup."LCY Code");
                    END;
                    if OpenEntries AND NOT CloseEntries THEN
                        IncludeEntries := Text1100005;
                    if CloseEntries AND NOT OpenEntries THEN
                        IncludeEntries := Text1100006;
                    if CloseEntries AND OpenEntries THEN
                        IncludeEntries := Text1100007;
                    GlobalNo := GlobalNo + 1;
                END;

                PageGroupNo := NextPageGroupNo;
                if "New Page" THEN
                    NextPageGroupNo := PageGroupNo + 1;
            end;

            trigger OnPostDataItem()
            begin
                "G/L Account".SETRANGE("Date Filter");
                "G/L Account".SETRANGE("Global Dimension 1 Filter");
                "G/L Account".SETRANGE("Global Dimension 2 Filter");
                /*CurrReport.SHOWOUTPUT(Cuenta.GETFILTERS = '');*/

            end;

            trigger OnPreDataItem()
            var
                UndefinedValue: Integer;
            begin
                UndefinedValue := -1;
                FromFec := 0D;
                if GETFILTER("Date Filter") = '' THEN
                    ToFec := 99991231D
                ELSE BEGIN
                    FromFec := GETRANGEMIN("Date Filter");
                    ToFec := GETRANGEMAX("Date Filter");
                END;
#pragma warning disable AL0667
                CurrReport.CREATETOTALS(PeriodDebitAmt, PeriodCreditAmt, DebitAmtAtEnd, CreditAmtAtEnd, BalanceAtEnd);
#pragma warning restore AL0667
                GLFilter := "G/L Account".GETFILTER("G/L Account"."Account Type");
                if GLFilter <> '' THEN BEGIN
                    // Only accept single account type filter, to display both 2 types user should leave this filter blank.
                    GLFilterValue := GetRangeMin("Account Type");
                    GLFilterOption := GLFilterValue.AsInteger();
                    SETRANGE("Account Type", GLFilterOption);
                END ELSE
                    GLFilterOption := UndefinedValue;

                if CloseEntries THEN
                    if ToFec <> NORMALDATE(ToFec) THEN
                        IsClosingDate(ToFec)
                    ELSE
                        ERROR(Text1100002, ToFec);
                if OpenEntries THEN
                    IsOpenDate := IsOpeningDate(FromFec);
                I := 0;

                PageGroupNo := 1;
                NextPageGroupNo := 1;
            end;
        }
    }

    requestpage
    {
        SaveValues = True;

        layout
        {
            area(content)
            {
                group(Options)
                {
                    Caption = 'Opciones';
                    field(OnlyGLAccountsWithBalanceAtDate; PrintAllHavingBal)
                    {
                        ApplicationArea = All;
                        Caption = 'Solo cuentas con saldo a la fecha';
                        MultiLine = true;
                    }
                    field(ShowAmountsInAddCurrency; PrintAmountsInAddCurrency)
                    {
                        ApplicationArea = All;
                        Caption = 'Muestra importes en divisa adic.';
                    }
                    field(AcumBalanceAtDate; AcumBalance)
                    {
                        ApplicationArea = All;
                        Caption = 'Saldoa cumulado a fecha';
                    }
                    field(IncludeOpeningEntries; OpenEntries)
                    {
                        ApplicationArea = All;
                        Caption = 'Incluir Apertura';
                    }
                    field(IncludeClosingEntries; CloseEntries)
                    {
                        ApplicationArea = All;
                        Caption = 'Incluir Cierre';
                    }
                }
            }
        }

        actions
        {
        }

        trigger OnOpenPage()
        begin
            PrintAllHavingBal := TRUE;
        end;
    }

    labels
    {
    }

    trigger OnPreReport()
    begin
        PeriodText := "G/L Account".GETFILTER("Date Filter");
        GlobalDim1 := "G/L Account".GETFILTER("G/L Account"."Global Dimension 1 Filter");
        GlobalDim2 := "G/L Account".GETFILTER("G/L Account"."Global Dimension 2 Filter");
    end;

    var
        Text1100002: Label 'The date %1 is not a Closing Date';
        Text1100003: Label 'Period: ';
        Text1100004: Label 'All Amounts in %1';
        Text1100005: Label 'Include Opening Entries';
        Text1100006: Label 'Include Closing Entries';
        Text1100007: Label 'Include Closing/Opening Entries';
        Text1100008: Label 'The fiscal year does not exist';
        GLSetup: Record "General Ledger Setup";
        GLAcc: Record 15;
        GLAcc2: Record 15;
        HeaderText: Text[30];
        PeriodText: Text[30];
        FromFec: Date;
        ToFec: Date;
        PrintAllHavingBal: Boolean;
        IncludeEntries: Text[40];
        GLFilter: Text[30];
        GLFilterOption: Option Posting,Heading;
        GLFilterValue: Enum "G/L Account Type";
        PreviousBalance: Decimal;
        PreviousDebit: Decimal;
        PreviousCredit: Decimal;
        IsOpenDate: Boolean;
        PrintAmountsInAddCurrency: Boolean;
        PeriodDebitAmt: Decimal;
        PeriodCreditAmt: Decimal;
        BalanceAtEnd: Decimal;
        DebitAmtAtEnd: Decimal;
        CreditAmtAtEnd: Decimal;
        TotalPeriodDebitAmt: Decimal;
        TotalPeriodCreditAmt: Decimal;
        TotalBalanceAtEnd: Decimal;
        TotalDebitAmtAtEnd: Decimal;
        TotalCreditAmtAtEnd: Decimal;
        BalanceType: Decimal;
        AcumBalance: Boolean;
        CloseEntries: Boolean;
        OpenEntries: Boolean;
        OpenCreditAmt: Decimal;
        OpenDebitAmt: Decimal;
        CloseCreditAmt: Decimal;
        CloseDebitAmt: Decimal;
        OpenCreditAmtEnd: Decimal;
        OpenDebitAmtEnd: Decimal;
        PreviousLevel: Integer;
        PrevAccount: Code[1];
        FirstLevel: Integer;
        Accumulate: Boolean;
        GlobalDim1: Text[30];
        GlobalDim2: Text[30];
        I: Integer;
        FixedLevel: Integer;
        GlobalNo: Integer;
        PageGroupNo: Integer;
        NextPageGroupNo: Integer;
        TrialBalanceCaptionLbl: Label 'Trial Balance';
        PageCaptionLbl: Label 'Pág:';
        AccinPeriodCaptionLbl: Label 'Acc. in Period';
        AccPeriodatDateCaptionLbl: Label 'Acc. Period at Date';
        AccountCaptionLbl: Label 'Account';
        NameCaptionLbl: Label 'Nombre';
        DebitCaptionLbl: Label 'Debe';
        CreditCaptionLbl: Label 'Haber';
        BalanceatDateCaptionLbl: Label 'Balance at Date';
        AcumBalanceatDateCaptionLbl: Label 'Saldoa cumulado a fecha';
        TotalCaptionLbl: Label 'Total. . . . . . . . ';
        BlankLineNo: Integer;
        Filtros: Record "Table Filter user";

    trigger OnPostReport()
    begin
        //   Filtros.SetSourceTable("G/L Account".GetFilters, 15, "G/L Account".TableCaption);
    end;
    /// <summary>
    /// StartingPeriod.
    /// </summary>
    /// <param name="Date">Date.</param>
    /// <returns>Return value of type Date.</returns>

    procedure StartingPeriod(Date: Date): Date
    var
        AccPeriod: Record 50;
    begin
        AccPeriod.SETRANGE("New Fiscal Year", TRUE);
        AccPeriod.SETFILTER("Starting Date", '<= %1', Date);
        if AccPeriod.FIND('+') THEN
            EXIT(AccPeriod."Starting Date")
        ELSE
            ERROR(Text1100008);
    end;


    /// <summary>
    /// IsOpeningDate.
    /// </summary>
    /// <param name="Date">Date.</param>
    /// <returns>Return value of type Boolean.</returns>
    procedure IsOpeningDate(Date: Date): Boolean
    var
        AccPeriod5: Record 50;
    begin
        AccPeriod5.SETRANGE(AccPeriod5."New Fiscal Year", TRUE);
        AccPeriod5.SETRANGE(AccPeriod5."Starting Date", Date);
        if AccPeriod5.FIND('-') THEN
            EXIT(TRUE)
        ELSE
            EXIT(FALSE);
    end;


    /// <summary>
    /// IsClosingDate.
    /// </summary>
    /// <param name="ToFec">Date.</param>
    procedure IsClosingDate(ToFec: Date)
    var
        AccPeriod2: Record 50;
    begin
        AccPeriod2.SETRANGE(AccPeriod2."New Fiscal Year", TRUE);
        if AccPeriod2.GET(NORMALDATE(ToFec) + 1) THEN
            EXIT
        ELSE
            ERROR(Text1100002, ToFec);
    end;


    /// <summary>
    /// CalcOpenEntries.
    /// </summary>
    procedure CalcOpenEntries()
    var
        GlAccount3: Record 15;
        AccPeriod3: Record 50;
    begin
        AccPeriod3.SETRANGE(AccPeriod3."New Fiscal Year", TRUE);
        AccPeriod3.SETFILTER(AccPeriod3."Starting Date", '<= %1', FromFec);
        if AccPeriod3.FIND('+') THEN BEGIN
            GlAccount3.GET("G/L Account"."No.");
            GlAccount3.SETRANGE(GlAccount3."Date Filter", 0D, CLOSINGDATE((AccPeriod3."Starting Date" - 1)));
            if GlobalDim1 <> '' THEN
                GlAccount3.SETFILTER("Global Dimension 1 Filter", GlobalDim1);
            if GlobalDim2 <> '' THEN
                GlAccount3.SETFILTER("Global Dimension 2 Filter", GlobalDim2);
            GlAccount3.CALCFIELDS("Additional-Currency Net Change", "Net Change");
            if PrintAmountsInAddCurrency THEN BEGIN
                if GlAccount3."Additional-Currency Net Change" > 0 THEN
                    OpenDebitAmtEnd := GlAccount3."Additional-Currency Net Change"
                ELSE
                    OpenCreditAmtEnd := ABS(GlAccount3."Additional-Currency Net Change");
            END ELSE BEGIN
                if GlAccount3."Net Change" > 0 THEN
                    OpenDebitAmtEnd := GlAccount3."Net Change"
                ELSE
                    OpenCreditAmtEnd := ABS(GlAccount3."Net Change");
            END;
            if IsOpenDate THEN BEGIN
                OpenDebitAmt := OpenDebitAmtEnd;
                OpenCreditAmt := OpenCreditAmtEnd;
            END;
        END;
    end;


    /// <summary>
    /// CalcCloseEntries.
    /// </summary>
    procedure CalcCloseEntries()
    var
        GlAccount4: Record 15;
        AccPeriod4: Record 50;
    begin
        AccPeriod4.SETRANGE(AccPeriod4."New Fiscal Year", TRUE);
        AccPeriod4.GET((NORMALDATE(ToFec) + 1));
        GlAccount4.GET("G/L Account"."No.");
        GlAccount4.SETRANGE(GlAccount4."Date Filter", 0D, ToFec);
        if GlobalDim1 <> '' THEN
            GlAccount4.SETFILTER("Global Dimension 1 Filter", GlobalDim1);
        if GlobalDim2 <> '' THEN
            GlAccount4.SETFILTER("Global Dimension 2 Filter", GlobalDim2);
        GlAccount4.CALCFIELDS("Additional-Currency Net Change", "Net Change");
        if PrintAmountsInAddCurrency THEN BEGIN
            if GlAccount4."Additional-Currency Net Change" > 0 THEN
                CloseCreditAmt := ABS(GlAccount4."Additional-Currency Net Change")
            ELSE
                CloseDebitAmt := ABS(GlAccount4."Additional-Currency Net Change");
        END ELSE BEGIN
            if GlAccount4."Net Change" > 0 THEN
                CloseCreditAmt := ABS(GlAccount4."Net Change")
            ELSE
                CloseDebitAmt := ABS(GlAccount4."Net Change");
        END;
    end;


    /// <summary>
    /// CalcCloseEntriesHeading.
    /// </summary>
    procedure CalcCloseEntriesHeading()
    var
        GLAcc: Record 15;
        long: Integer;
    begin
        GLAcc.SETRANGE("Date Filter", 0D, ToFec);
        GLAcc.SETFILTER("No.", "G/L Account".Totaling);
        GLAcc.SETRANGE("Account Type", GLAcc."Account Type"::Posting);
        if GlobalDim1 <> '' THEN
            GLAcc.SETFILTER("Global Dimension 1 Filter", GlobalDim1);
        if GlobalDim2 <> '' THEN
            GLAcc.SETFILTER("Global Dimension 2 Filter", GlobalDim2);

        if GLAcc.FIND('-') THEN BEGIN
            REPEAT
                GLAcc.CALCFIELDS("Additional-Currency Net Change", "Net Change");
                if PrintAmountsInAddCurrency THEN BEGIN
                    if GLAcc."Additional-Currency Net Change" > 0 THEN
                        CloseCreditAmt := CloseCreditAmt + ABS(GLAcc."Additional-Currency Net Change")
                    ELSE
                        CloseDebitAmt := CloseDebitAmt + ABS(GLAcc."Additional-Currency Net Change");
                END ELSE BEGIN
                    if GLAcc."Net Change" > 0 THEN
                        CloseCreditAmt := CloseCreditAmt + ABS(GLAcc."Net Change")
                    ELSE
                        CloseDebitAmt := CloseDebitAmt + ABS(GLAcc."Net Change");
                END;
            UNTIL GLAcc.NEXT = 0;
        END;
    end;


    /// <summary>
    /// CalcOpenEntriesHeading.
    /// </summary>
    procedure CalcOpenEntriesHeading()
    var
        GLAcc: Record 15;
        long: Integer;
        AccPeriod3: Record 50;
    begin
        AccPeriod3.SETRANGE(AccPeriod3."New Fiscal Year", TRUE);
        AccPeriod3.SETFILTER(AccPeriod3."Starting Date", '<= %1', FromFec);
        if AccPeriod3.FIND('+') THEN BEGIN
            GLAcc.SETRANGE("Date Filter", 0D, CLOSINGDATE((AccPeriod3."Starting Date" - 1)));
            GLAcc.SETFILTER("No.", "G/L Account".Totaling);
            GLAcc.SETRANGE("Account Type", GLAcc."Account Type"::Posting);
            if GlobalDim1 <> '' THEN
                GLAcc.SETFILTER("Global Dimension 1 Filter", GlobalDim1);
            if GlobalDim2 <> '' THEN
                GLAcc.SETFILTER("Global Dimension 2 Filter", GlobalDim2);
            if GLAcc.FIND('-') THEN BEGIN
                REPEAT
                    GLAcc.CALCFIELDS("Additional-Currency Net Change", "Net Change");
                    if PrintAmountsInAddCurrency THEN BEGIN
                        if GLAcc."Additional-Currency Net Change" > 0 THEN
                            OpenDebitAmtEnd := OpenDebitAmtEnd + ABS(GLAcc."Additional-Currency Net Change")
                        ELSE
                            OpenCreditAmtEnd := OpenCreditAmtEnd + ABS(GLAcc."Additional-Currency Net Change");
                    END ELSE BEGIN
                        if GLAcc."Net Change" > 0 THEN
                            OpenDebitAmtEnd := OpenDebitAmtEnd + ABS(GLAcc."Net Change")
                        ELSE
                            OpenCreditAmtEnd := OpenCreditAmtEnd + ABS(GLAcc."Net Change");
                    END;
                UNTIL GLAcc.NEXT = 0;
            END;
            if IsOpenDate THEN BEGIN
                OpenDebitAmt := OpenDebitAmtEnd;
                OpenCreditAmt := OpenCreditAmtEnd;
            END;
        END;
    end;

    local procedure SetGLAccDateFilter()
    begin
        if AcumBalance THEN
            GLAcc2.SETRANGE("Date Filter", 0D, ToFec)
        ELSE
            GLAcc2.SETRANGE("Date Filter", StartingPeriod(FromFec), ToFec);
    end;
}

