/// <summary>
/// Report Customer Annual Decl Ces (ID 7001101).
/// </summary>
report 50036 "Customer Annual Decl Ces"
{
    DefaultLayout = RDLC;
    RDLCLayout = './src/report/layout/CustomerAnnualDeclaration.rdlc';
    Caption = 'Cliente - Declaración anul Malla';
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;

    dataset
    {
        dataitem(Customer; 18)
        {
            DataItemTableView = sorting("VAT Registration No.");
            CalcFields = "Inv. Amounts (LCY)", "Cr. Memo Amounts (LCY)";
            RequestFilterFields = "No.", "Customer Posting Group", "Date Filter", "Omitir 347";

            column(FORMAT_TODAY_0_4_; FORMAT(TODAY, 0, 4))
            {
            }
            column(COMPANYNAME; COMPANYNAME)
            {
            }
            // column(CurrReport_PAGENO; CurrReport.PAGENO)
            //    {
            // }
            column(USERID; USERID)
            {
            }
            column(Customer_TABLECAPTION__________CustFilter; Customer.TABLECAPTION + ': ' + CustFilter)
            {
            }
            column(CustFilter; CustFilter)
            {
            }
            column(Text1100000___FORMAT_MinAmount_; Text1100000 + FORMAT(MinAmount))
            {
            }
            column(GroupNo; GroupNo)
            {
            }
            column(Customer__No__; "No.")
            {
            }
            column(CustAddr_1_; CustAddr[1])
            {
            }
            column(CustAddr_2_; CustAddr[2])
            {
            }
            column(CustAddr_3_; CustAddr[3])
            {
            }
            column(CustAddr_4_; CustAddr[4])
            {
            }
            column(CustAddr_5_; CustAddr[5])
            {
            }
            column(CustAddr_6_; CustAddr[6])
            {
            }
            column(CustAddr_7_; CustAddr[7])
            {
            }
            column(Customer__VAT_Registration_No__; "VAT Registration No.")
            {
            }
            column(SalesAmt1; SalesAmt1)
            {
            }
            column(SalesAmt2; SalesAmt2)
            {
            }
            column(SalesAmt3; SalesAmt3)
            {
            }
            column(SalesAmt4; SalesAmt4)
            {
            }
            column(SalesAmt; SalesAmt)
            {
                DecimalPlaces = 0 : 2;
            }
            column(CustAddr_8_; CustAddr[8])
            {
            }
            column(AcumSalesAmount; AcumSalesAmount)
            {
                DecimalPlaces = 0 : 2;
            }
            column(Customers___Annual_DeclarationCaption; Customers___Annual_DeclarationCaptionLbl)
            {
            }
            column(CurrReport_PAGENOCaption; CurrReport_PAGENOCaptionLbl)
            {
            }
            column(Customer__No__Caption; FIELDCAPTION("No."))
            {
            }
            column(Customer__VAT_Registration_No__Caption; FIELDCAPTION("VAT Registration No."))
            {
            }
            column(Name_and_AddressCaption; Name_and_AddressCaptionLbl)
            {
            }
            column(SalesAmtCaption; SalesAmtCaptionLbl)
            {
            }

            trigger OnAfterGetRecord()
            var
                IgnoreAmt: Decimal;
                InvoiceAmt: Decimal;
                CrMemoAmt: Decimal;
            begin
                IgnoreAmt := 0;
                SalesAmt := 0;
                SalesAmt1 := 0;
                SalesAmt2 := 0;
                SalesAmt3 := 0;
                SalesAmt4 := 0;
                InvoiceAmt := 0;
                CrMemoAmt := 0;

                CustEntries.SETCURRENTKEY("Document Type", "Customer No.", "Document Date", "Currency Code");

                CustEntries.SETRANGE("Document Type", CustEntries."Document Type"::Invoice, CustEntries."Document Type"::"Credit Memo");
                CustEntries.SETRANGE("Customer No.", "No.");
                CustEntries.SETRANGE("Document Date", GETRANGEMIN("Date Filter"), GETRANGEMAX("Date Filter"));
                if CustEntries.FIND('-') THEN
                    REPEAT
                        CASE CustEntries."Document Type" OF
                            CustEntries."Document Type"::Invoice:
                                BEGIN
                                    InvoiceAmt := InvoiceAmt + CalcTotalSalesAmt(CustEntries."Entry No.");
                                    CASE GetQuarterIndex(CustEntries."Posting Date") OF
                                        1:
                                            SalesAmt1 += CalcTotalSalesAmt(CustEntries."Entry No.");
                                        2:
                                            SalesAmt2 += CalcTotalSalesAmt(CustEntries."Entry No.");
                                        3:
                                            SalesAmt3 += CalcTotalSalesAmt(CustEntries."Entry No.");
                                        4:
                                            SalesAmt4 += CalcTotalSalesAmt(CustEntries."Entry No.");
                                    END;
                                END;
                            CustEntries."Document Type"::"Credit Memo":
                                BEGIN
                                    CrMemoAmt := CrMemoAmt - CalcTotalSalesAmt(CustEntries."Entry No.");
                                    CASE GetQuarterIndex(CustEntries."Posting Date") OF
                                        1:
                                            SalesAmt1 += CalcTotalSalesAmt(CustEntries."Entry No.");
                                        2:
                                            SalesAmt2 += CalcTotalSalesAmt(CustEntries."Entry No.");
                                        3:
                                            SalesAmt3 += CalcTotalSalesAmt(CustEntries."Entry No.");
                                        4:
                                            SalesAmt4 += CalcTotalSalesAmt(CustEntries."Entry No.");
                                    END;

                                END;
                        END;
                        GLEntries.SETCURRENTKEY("Document No.", "Document Date");
                        GLEntries.SETRANGE("Document No.", CustEntries."Document No.");
                        GLEntries.SETRANGE("Document Date", CustEntries."Document Date");
                        GLEntries.SETRANGE("Gen. Posting Type", GLEntries."Gen. Posting Type"::Sale);
                        if GLEntries.FIND('-') THEN
                            REPEAT
                                Account.GET(GLEntries."G/L Account No.");
                                if Account."Ignore in 347 Report" THEN
                                    IgnoreAmt := IgnoreAmt + GLEntries.Amount + GLEntries."VAT Amount";
                            UNTIL GLEntries.NEXT = 0;
                    UNTIL CustEntries.NEXT = 0;
                SalesAmt := InvoiceAmt - CrMemoAmt;

                if SalesAmt <= MinAmount THEN
                    CurrReport.SKIP;

                SalesAmt := SalesAmt + IgnoreAmt;

                AcumSalesAmount := AcumSalesAmount + SalesAmt;

                FormatAddress.FormatAddr(
                  CustAddr, Name, "Name 2", '', Address, "Address 2",
                  City, "Post Code", County, "Country/Region Code");

                if (GroupNo = 0) AND (Counter = 0) THEN
                    Counter := Counter + 1;
                if Counter = BlocksPerPage THEN BEGIN
                    GroupNo := GroupNo + 1;
                    Counter := 0;
                END;
                Counter := Counter + 1;
            end;

            trigger OnPreDataItem()
            begin
                BlocksPerPage := 6;
                Counter := 0;
                GroupNo := 0;
            end;
        }
    }

    requestpage
    {
        SaveValues = true;

        layout
        {
            area(content)
            {
                group(Options)
                {
                    Caption = 'Opciones';
                    field(MinAmount; MinAmount)
                    {
                        ApplicationArea = All;
                        Caption = 'Importes mayores que';
                    }
                }
            }
        }

        actions
        {
        }
    }

    labels
    {
    }

    trigger OnPreReport()
    begin
        CustFilter := Customer.GETFILTERS;
    end;

    var
        Text1100000: Label 'Importes mayores que ';
        CustEntries: Record 21;
        GLEntries: Record "G/L Entry";
        FormatAddress: Codeunit "Format Address";
        CustFilter: Text[250];
        CustAddr: array[8] of Text[100];
        SalesAmt: Decimal;
        MinAmount: Decimal;
        Account: Record 15;
        AcumSalesAmount: Decimal;
        GroupNo: Integer;
        Counter: Integer;
        BlocksPerPage: Integer;
        Customers___Annual_DeclarationCaptionLbl: Label 'Clientes - Declaración Anual';
        CurrReport_PAGENOCaptionLbl: Label 'Pág:';
        Name_and_AddressCaptionLbl: Label 'Nombre y dirección';
        SalesAmtCaptionLbl: Label 'Importe Euros';
        SalesAmt1: Decimal;
        SalesAmt2: Decimal;
        SalesAmt3: Decimal;
        SalesAmt4: Decimal;


    /// <summary>
    /// CalcTotalSalesAmt.
    /// </summary>
    /// <param name="EntryNo">Integer.</param>
    /// <returns>Return variable TotalSalesAmt of type Decimal.</returns>
    procedure CalcTotalSalesAmt(EntryNo: Integer) TotalSalesAmt: Decimal
    var
        DtldCustLedgEntry: Record 379;
    begin
        DtldCustLedgEntry.RESET;
        DtldCustLedgEntry.SETCURRENTKEY("Cust. Ledger Entry No.", "Entry Type");
        DtldCustLedgEntry.SETRANGE("Cust. Ledger Entry No.", EntryNo);
        DtldCustLedgEntry.SETRANGE("Entry Type", DtldCustLedgEntry."Entry Type"::"Initial Entry");
        DtldCustLedgEntry.CALCSUMS("Amount (LCY)");
        //if DtldCustLedgEntry."Document Type" = DtldCustLedgEntry."Document Type"::"Credit Memo" THEN //TSS
        //  EXIT(DtldCustLedgEntry."Amount (LCY)" * -1)
        //ELSE
        EXIT(DtldCustLedgEntry."Amount (LCY)");
    end;

    local procedure GetQuarterIndex(Date: Date): Integer
    begin
        EXIT(ROUND((DATE2DMY(Date, 2) - 1) / 3, 1, '<') + 1);
    end;
}

