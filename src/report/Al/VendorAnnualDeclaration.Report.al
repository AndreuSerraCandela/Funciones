/// <summary>
/// Report Vendor-Annual Declaration Ces (ID 7001100).
/// </summary>
report 50035 "Vendor-Annual Declaration Ces"
{
    DefaultLayout = RDLC;
    RDLCLayout = './src/report/layout/VendorAnnualDeclaration.rdlc';
    Caption = 'Proveedor - Declaración Anual Malla';
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;
    dataset
    {
        dataitem(Vendor; 23)
        {
            DataItemTableView = sorting("VAT Registration No.");
            CalcFields = "Inv. Amounts (LCY)", "Cr. Memo Amounts (LCY)";
            RequestFilterFields = "No.", "Vendor Posting Group", "Date Filter", "Omitir 347";
            column(FORMAT_TODAY_0_4_; FORMAT(TODAY, 0, 4))
            {
            }
            column(COMPANYNAME; COMPANYNAME)
            {
            }
#pragma warning disable AL0667
            column(CurrReport_PAGENO; CurrReport.PAGENO)
#pragma warning restore AL0667
            {
            }
            column(USERID; USERID)
            {
            }
            column(Vendor_TABLECAPTION__________VendFilter; Vendor.TABLECAPTION + ': ' + VendFilter)
            {
            }
            column(VendFilter; VendFilter)
            {
            }
            column(Text1100000___FORMAT_MinAmount_; Text1100000 + FORMAT(MinAmount))
            {
            }
            column(GroupNo; GroupNo)
            {
            }
            column(Vendor__No__; "No.")
            {
            }
            column(VendAddr_1_; VendAddr[1])
            {
            }
            column(VendAddr_2_; VendAddr[2])
            {
            }
            column(VendAddr_3_; VendAddr[3])
            {
            }
            column(VendAddr_4_; VendAddr[4])
            {
            }
            column(VendAddr_5_; VendAddr[5])
            {
            }
            column(VendAddr_6_; VendAddr[6])
            {
            }
            column(VendAddr_7_; VendAddr[7])
            {
            }
            column(Vendor__VAT_Registration_No__; "VAT Registration No.")
            {
            }
            column(PurchaseAmt; PurchaseAmt)
            {
                DecimalPlaces = 0 : 2;
            }
            column(PurchaseAmt1; PurchaseAmt1)
            {
                DecimalPlaces = 0 : 2;
            }
            column(PurchaseAmt2; PurchaseAmt2)
            {
                DecimalPlaces = 0 : 2;
            }
            column(PurchaseAmt3; PurchaseAmt3)
            {
                DecimalPlaces = 0 : 2;
            }
            column(PurchaseAmt4; PurchaseAmt4)
            {
                DecimalPlaces = 0 : 2;
            }
            column(VendAddr_8_; VendAddr[8])
            {
            }
            column(AcumPurchasesAmount; AcumPurchasesAmount)
            {
                DecimalPlaces = 0 : 2;
            }
            column(Vendors___Annual_DeclarationCaption; Vendors___Annual_DeclarationCaptionLbl)
            {
            }
            column(CurrReport_PAGENOCaption; CurrReport_PAGENOCaptionLbl)
            {
            }
            column(Vendor__No__Caption; FIELDCAPTION("No."))
            {
            }
            column(Vendor__VAT_Registration_No__Caption; FIELDCAPTION("VAT Registration No."))
            {
            }
            column(Name_and_AddressCaption; Name_and_AddressCaptionLbl)
            {
            }
            column(PurchaseAmtCaption; PurchaseAmtCaptionLbl)
            {
            }

            trigger OnAfterGetRecord()
            var
                IgnoreAmt: Decimal;
                InvoiceAmt: Decimal;
                CrMemoAmt: Decimal;
            begin
                IgnoreAmt := 0;
                PurchaseAmt := 0;
                PurchaseAmt1 := 0;
                PurchaseAmt2 := 0;
                PurchaseAmt3 := 0;
                PurchaseAmt4 := 0;
                InvoiceAmt := 0;
                CrMemoAmt := 0;
                VendEntries.SETCURRENTKEY("Document Type", "Vendor No.", "Posting Date", "Currency Code");
                //Document Type,Vendor No.,Posting Date,Currency Code

                VendEntries.SETRANGE("Document Type", VendEntries."Document Type"::Invoice, VendEntries."Document Type"::"Credit Memo");
                VendEntries.SETRANGE("Vendor No.", "No.");
                VendEntries.SETRANGE("Posting Date", GETRANGEMIN("Date Filter"), GETRANGEMAX("Date Filter"));
                if VendEntries.FIND('-') THEN
                    REPEAT
                        CASE VendEntries."Document Type" OF
                            VendEntries."Document Type"::Invoice:
                                BEGIN
                                    InvoiceAmt := InvoiceAmt - CalcTotalPurchAmt(VendEntries."Entry No.");
                                    CASE GetQuarterIndex(VendEntries."Posting Date") OF
                                        1:
                                            PurchaseAmt1 += CalcTotalPurchAmt(VendEntries."Entry No.");
                                        2:
                                            PurchaseAmt2 += CalcTotalPurchAmt(VendEntries."Entry No.");
                                        3:
                                            PurchaseAmt3 += CalcTotalPurchAmt(VendEntries."Entry No.");
                                        4:
                                            PurchaseAmt4 += CalcTotalPurchAmt(VendEntries."Entry No.");
                                    END;
                                END;
                            VendEntries."Document Type"::"Credit Memo":
                                BEGIN
                                    CrMemoAmt := CrMemoAmt + CalcTotalPurchAmt(VendEntries."Entry No.");
                                    CASE GetQuarterIndex(VendEntries."Posting Date") OF
                                        1:
                                            PurchaseAmt1 += CalcTotalPurchAmt(VendEntries."Entry No.");    //TSS cambiado -= por +=
                                        2:
                                            PurchaseAmt2 += CalcTotalPurchAmt(VendEntries."Entry No.");
                                        3:
                                            PurchaseAmt3 += CalcTotalPurchAmt(VendEntries."Entry No.");
                                        4:
                                            PurchaseAmt4 += CalcTotalPurchAmt(VendEntries."Entry No.");
                                    END;
                                END;

                        END;
                        GLEntries.SETCURRENTKEY("Document No.", "Posting Date");
                        GLEntries.SETRANGE("Document No.", VendEntries."Document No.");
                        GLEntries.SETRANGE("Posting Date", VendEntries."Posting Date");
                        GLEntries.SETRANGE("Gen. Posting Type", GLEntries."Gen. Posting Type"::Purchase);
                        if GLEntries.FIND('-') THEN
                            REPEAT
                                Account.GET(GLEntries."G/L Account No.");
                                if Account."Ignore in 347 Report" THEN
                                    IgnoreAmt := IgnoreAmt + GLEntries.Amount + GLEntries."VAT Amount";
                            UNTIL GLEntries.NEXT = 0;
                    UNTIL VendEntries.NEXT = 0;
                PurchaseAmt := InvoiceAmt - CrMemoAmt;

                //TSS
                PurchaseAmt1 := -PurchaseAmt1;
                PurchaseAmt2 := -PurchaseAmt2;
                PurchaseAmt3 := -PurchaseAmt3;
                PurchaseAmt4 := -PurchaseAmt4;
                PurchaseAmt := 0;
                PurchaseAmt := PurchaseAmt1 + PurchaseAmt2 + PurchaseAmt3 + PurchaseAmt4;
                //TSS
                if PurchaseAmt <= MinAmount THEN
                    CurrReport.SKIP;

                PurchaseAmt := PurchaseAmt - IgnoreAmt;

                AcumPurchasesAmount := AcumPurchasesAmount + PurchaseAmt;
                FormatAddress.FormatAddr(
                  VendAddr, Name, "Name 2", '', Address, "Address 2",
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
        VendFilter := Vendor.GETFILTERS;
    end;

    var
        Text1100000: Label 'Importes mayores que ';
        VendEntries: Record 25;
        GLEntries: Record "G/L Entry";
        Account: Record 15;
        FormatAddress: Codeunit "Format Address";
        VendFilter: Text[250];
        VendAddr: array[8] of Text[100];
        PurchaseAmt: Decimal;
        MinAmount: Decimal;
        AcumPurchasesAmount: Decimal;
        GroupNo: Integer;
        Counter: Integer;
        BlocksPerPage: Integer;
        Vendors___Annual_DeclarationCaptionLbl: Label 'Proveedor - Declaración Anual';
        CurrReport_PAGENOCaptionLbl: Label 'Pág:';
        Name_and_AddressCaptionLbl: Label 'Nombre y dirección';
        PurchaseAmtCaptionLbl: Label 'Importe Euros';
        PurchaseAmt1: Decimal;
        PurchaseAmt2: Decimal;
        PurchaseAmt3: Decimal;
        PurchaseAmt4: Decimal;


    /// <summary>
    /// CalcTotalPurchAmt.
    /// </summary>
    /// <param name="EntryNo">Integer.</param>
    /// <returns>Return variable TotalPurchAmt of type Decimal.</returns>
    procedure CalcTotalPurchAmt(EntryNo: Integer) TotalPurchAmt: Decimal
    var
        DtldVendLedgEntry: Record 380;
    begin
        DtldVendLedgEntry.RESET;
        DtldVendLedgEntry.SETCURRENTKEY("Vendor Ledger Entry No.", "Entry Type");
        DtldVendLedgEntry.SETRANGE("Vendor Ledger Entry No.", EntryNo);
        DtldVendLedgEntry.SETRANGE("Entry Type", DtldVendLedgEntry."Entry Type"::"Initial Entry");
        DtldVendLedgEntry.CALCSUMS("Amount (LCY)");
        EXIT(DtldVendLedgEntry."Amount (LCY)");
    end;

    local procedure GetQuarterIndex(Date: Date): Integer
    begin
        EXIT(ROUND((DATE2DMY(Date, 2) - 1) / 3, 1, '<') + 1);
    end;
}

