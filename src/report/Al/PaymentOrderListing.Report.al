/// <summary>
/// Report Pay Order Listing Ces (ID 80210).
/// </summary>
report 50034 "Pay Order Listing Ces"
{
    DefaultLayout = RDLC;
    RDLCLayout = './src/report/layout/PaymentOrderListing.rdlc';
    Caption = 'Listado orden de pago';
    Permissions = TableData 7000020 = r;
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;

    dataset
    {
        dataitem(PmtOrd; 7000020)
        {
            DataItemTableView = SORTING("No.");
            PrintOnlyIfDetail = true;
            RequestFilterFields = "No.";
            column(PmtOrd_No_; "No.")
            {
            }
            dataitem(CopyLoop; Integer)
            {
                DataItemTableView = SORTING(Number);
                dataitem(PageLoop; Integer)
                {
                    DataItemTableView = SORTING(Number)
                                        WHERE(Number = CONST(1));
                    column(PmtOrd__No__; PmtOrd."No.")
                    {
                    }
                    column(STRSUBSTNO_Text1100001_CopyText_; STRSUBSTNO(Text1100001, CopyText))
                    {
                    }
#pragma warning disable AL0667
                    column(STRSUBSTNO_Text1100002_FORMAT_CurrReport_PAGENO__; STRSUBSTNO(Text1100002, FORMAT(CurrReport.PAGENO)))
#pragma warning restore AL0667
                    {
                    }
                    column(CompanyAddr_1_; CompanyAddr[1])
                    {
                    }
                    column(CompanyAddr_2_; CompanyAddr[2])
                    {
                    }
                    column(CompanyAddr_3_; CompanyAddr[3])
                    {
                    }
                    column(CompanyAddr_4_; CompanyAddr[4])
                    {
                    }
                    column(CompanyAddr_5_; CompanyAddr[5])
                    {
                    }
                    column(CompanyAddr_6_; CompanyAddr[6])
                    {
                    }
                    column(CompanyInfo__Phone_No__; CompanyInfo."Phone No.")
                    {
                    }
                    column(CompanyInfo__Fax_No__; CompanyInfo."Fax No.")
                    {
                    }
                    column(CompanyInfo__VAT_Registration_No__; CompanyInfo."VAT Registration No.")
                    {
                    }
                    column(PmtOrd__Posting_Date_; FORMAT(PmtOrd."Posting Date"))
                    {
                    }
                    column(BankAccAddr_4_; BankAccAddr[4])
                    {
                    }
                    column(BankAccAddr_5_; BankAccAddr[5])
                    {
                    }
                    column(BankAccAddr_6_; BankAccAddr[6])
                    {
                    }
                    column(BankAccAddr_7_; BankAccAddr[7])
                    {
                    }
                    column(BankAccAddr_3_; BankAccAddr[3])
                    {
                    }
                    column(BankAccAddr_2_; BankAccAddr[2])
                    {
                    }
                    column(BankAccAddr_1_; BankAccAddr[1])
                    {
                    }
                    column(PmtOrd__Currency_Code_; PmtOrd."Currency Code")
                    {
                    }
                    column(PrintAmountsInLCY; PrintAmountsInLCY)
                    {
                    }
                    column(OutputNo; OutputNo)
                    {
                    }
                    column(PageLoop_Number; Number)
                    {
                    }
                    column(PmtOrd__No__Caption; PmtOrd__No__CaptionLbl)
                    {
                    }
                    column(CompanyInfo__Phone_No__Caption; CompanyInfo__Phone_No__CaptionLbl)
                    {
                    }
                    column(CompanyInfo__Fax_No__Caption; CompanyInfo__Fax_No__CaptionLbl)
                    {
                    }
                    column(CompanyInfo__VAT_Registration_No__Caption; CompanyInfo__VAT_Registration_No__CaptionLbl)
                    {
                    }
                    column(PmtOrd__Posting_Date_Caption; PmtOrd__Posting_Date_CaptionLbl)
                    {
                    }
                    column(PmtOrd__Currency_Code_Caption; PmtOrd__Currency_Code_CaptionLbl)
                    {
                    }
                    column(PageCaption; PageCaptionLbl)
                    {
                    }
                    dataitem("Cartera Doc."; 7000002)
                    {
                        DataItemLink = "Bill Gr./Pmt. Order No." = FIELD("No.");
                        DataItemLinkReference = PmtOrd;
                        DataItemTableView = SORTING(Type, "Collection Agent", "Bill Gr./Pmt. Order No.")
                                            WHERE("Collection Agent" = CONST(Bank),
                                                  Type = CONST(Payable));
                        column(PmtOrdAmount; PmtOrdAmount)
                        {
                            AutoFormatExpression = GetCurrencyCode;
                            AutoFormatType = 1;
                        }
                        column(PmtOrdAmount_Control23; PmtOrdAmount)
                        {
                            AutoFormatExpression = GetCurrencyCode;
                            AutoFormatType = 1;
                        }
                        column(Vend_City; Vend.City)
                        {
                        }
                        column(Vend_County; Vend.County)
                        {
                        }
                        column(Vend__Post_Code_; Vend."Post Code")
                        {
                        }
                        column(Vend_Name; Vend.Name)
                        {
                        }
                        column(Cartera_Doc___Account_No__; "Account No.")
                        {
                        }
                        column(Cartera_Doc___Document_No__; "Document No.")
                        {
                        }
                        column(Cartera_Doc___Due_Date_; FORMAT("Due Date"))
                        {
                        }
                        column(Cartera_Doc___Document_Type_; "Document Type")
                        {
                        }
                        column(Cartera_Doc____Document_Type______Cartera_Doc____Document_Type___Bill; "Document Type" <> "Document Type"::Bill)
                        {
                        }
                        column(Vend_Name_Control28; Vend.Name)
                        {
                        }
                        column(Vend_City_Control30; Vend.City)
                        {
                        }
                        column(PmtOrdAmount_Control31; PmtOrdAmount)
                        {
                            AutoFormatExpression = GetCurrencyCode;
                            AutoFormatType = 1;
                        }
                        column(Vend_County_Control35; Vend.County)
                        {
                        }
                        column(Cartera_Doc___Document_No___Control3; "Document No.")
                        {
                        }
                        column(Cartera_Doc___No__; "No.")
                        {
                        }
                        column(Vend__Post_Code__Control9; Vend."Post Code")
                        {
                        }
                        column(Cartera_Doc___Due_Date__Control8; FORMAT("Due Date"))
                        {
                        }
                        column(Cartera_Doc___Account_No___Control1; "Account No.")
                        {
                        }
                        column(Cartera_Doc___Document_Type__Control66; "Document Type")
                        {
                        }
                        column(Cartera_Doc____Document_Type_____Cartera_Doc____Document_Type___Bill; "Document Type" = "Document Type"::Bill)
                        {
                        }
                        column(PmtOrdAmount_Control36; PmtOrdAmount)
                        {
                            AutoFormatExpression = GetCurrencyCode;
                            AutoFormatType = 1;
                        }
                        column(PmtOrdAmount_Control39; PmtOrdAmount)
                        {
                            AutoFormatExpression = GetCurrencyCode;
                            AutoFormatType = 1;
                        }
                        column(Cartera_Doc__Type; Type)
                        {
                        }
                        column(Cartera_Doc__Entry_No_; "Entry No.")
                        {
                        }
                        column(Cartera_Doc__Bill_Gr__Pmt__Order_No_; "Bill Gr./Pmt. Order No.")
                        {
                        }
                        column(All_amounts_are_in_LCYCaption; All_amounts_are_in_LCYCaptionLbl)
                        {
                        }
                        column(VendorNoCaption; VendorNoCaptionLbl)
                        {
                        }
                        column(Vend_Name_Control28Caption; Vend_Name_Control28CaptionLbl)
                        {
                        }
                        column(Vend__Post_Code__Control9Caption; Vend__Post_Code__Control9CaptionLbl)
                        {
                        }
                        column(Vend_City_Control30Caption; Vend_City_Control30CaptionLbl)
                        {
                        }
                        column(PmtOrdAmount_Control31Caption; PmtOrdAmount_Control31CaptionLbl)
                        {
                        }
                        column(Vend_County_Control35Caption; Vend_County_Control35CaptionLbl)
                        {
                        }
                        column(Cartera_Doc___Due_Date__Control8Caption; Cartera_Doc___Due_Date__Control8CaptionLbl)
                        {
                        }
                        column(Bill_No_Caption; Bill_No_CaptionLbl)
                        {
                        }
                        column(Document_No_Caption; Document_No_CaptionLbl)
                        {
                        }
                        column(Cartera_Doc___Document_Type__Control66Caption; FIELDCAPTION("Document Type"))
                        {
                        }
                        column(ContinuedCaption; ContinuedCaptionLbl)
                        {
                        }
                        column(EmptyStringCaption; EmptyStringCaptionLbl)
                        {
                        }
                        column(ContinuedCaption_Control15; ContinuedCaption_Control15Lbl)
                        {
                        }
                        column(TotalCaption; TotalCaptionLbl)
                        {
                        }

                        trigger OnAfterGetRecord()
                        begin
                            Vend.GET("Account No.");

                            if PrintAmountsInLCY THEN
                                PmtOrdAmount := "Remaining Amt. (LCY)"
                            ELSE
                                PmtOrdAmount := "Remaining Amount";
                        end;

                        trigger OnPreDataItem()
                        begin
#pragma warning disable AL0667
                            CurrReport.CREATETOTALS(PmtOrdAmount);
#pragma warning restore AL0667
                        end;
                    }
                }

                trigger OnAfterGetRecord()
                begin
                    if Number > 1 THEN BEGIN
                        CopyText := Text1100000;
                        OutputNo += 1;
                    END;
#pragma warning disable AL0667
                    CurrReport.PAGENO := 1;
#pragma warning restore AL0667
                end;

                trigger OnPreDataItem()
                begin
                    NoOfLoops := ABS(NoOfCopies) + 1;
                    CopyText := '';
                    SETRANGE(Number, 1, 1);
                    OutputNo := 1;
                end;
            }

            trigger OnAfterGetRecord()
            begin
                //WITH BankAcc. DO BEGIN
                GET(PmtOrd."Bank Account No.");
                FormatAddress.FormatAddr(
                  BankAccAddr, Name, BankAcc."Name 2", '', BankAcc.Address, BankAcc."Address 2",
                  City, BankAcc."Post Code", County, BankAcc."Country/Region Code");
                //END;

                if NOT CurrReport.PREVIEW THEN
                    PrintCounter.PrintCounter(DATABASE::"Payment Order", "No.");
            end;

            trigger OnPreDataItem()
            begin
                CompanyInfo.GET;
                FormatAddress.Company(CompanyAddr, CompanyInfo);
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
                    field(NoOfCopies; NoOfCopies)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Nº de copias';
                    }
                    field(PrintAmountsInLCY; PrintAmountsInLCY)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Mostrar importes en euros';
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

    var
        Text1100000: Label 'COPIA';
        Text1100001: Label 'Orden de pago %1';
        Text1100002: Label 'Pág: %1';
        CompanyInfo: Record 79;
        BankAcc: Record 270;
        Vend: Record Vendor;
        FormatAddress: Codeunit "Format Address";
        PrintCounter: Codeunit 7000003;
        BankAccAddr: array[8] of Text[100];
        CompanyAddr: array[8] of Text[100];
        NoOfLoops: Integer;
        NoOfCopies: Integer;
        CopyText: Text[30];
        City: Text[30];
        County: Text[30];
        Name: Text[100];
        PrintAmountsInLCY: Boolean;
        PmtOrdAmount: Decimal;
        OutputNo: Integer;
        PmtOrd__No__CaptionLbl: Label 'Orden de pago nº';
        CompanyInfo__Phone_No__CaptionLbl: Label 'Teléfono';
        CompanyInfo__Fax_No__CaptionLbl: Label 'Fax';
        CompanyInfo__VAT_Registration_No__CaptionLbl: Label 'Cif.';
        PmtOrd__Posting_Date_CaptionLbl: Label 'Fecha';
        PmtOrd__Currency_Code_CaptionLbl: Label 'Divisa';
        PageCaptionLbl: Label 'Pág:';
        All_amounts_are_in_LCYCaptionLbl: Label 'Todos los importes en euros';
        VendorNoCaptionLbl: Label 'Vendor No.';
        Vend_Name_Control28CaptionLbl: Label 'Nombre';
        Vend__Post_Code__Control9CaptionLbl: Label 'Cód. Postal';
        Vend_City_Control30CaptionLbl: Label 'Población /';
        PmtOrdAmount_Control31CaptionLbl: Label 'Importe Pendiente';
        Vend_County_Control35CaptionLbl: Label 'Provincia';
        Cartera_Doc___Due_Date__Control8CaptionLbl: Label 'Fec. Vto.';
        Bill_No_CaptionLbl: Label 'Nº Efecto';
        Document_No_CaptionLbl: Label 'Nº Documento';
        ContinuedCaptionLbl: Label 'Continuado';
        EmptyStringCaptionLbl: Label '/', Locked = true;
        ContinuedCaption_Control15Lbl: Label 'Continuado';
        TotalCaptionLbl: Label 'Total';


    /// <summary>
    /// GetCurrencyCode.
    /// </summary>
    /// <returns>Return value of type Code[10].</returns>
    procedure GetCurrencyCode(): Code[10]
    begin
        if PrintAmountsInLCY THEN
            EXIT('');

        EXIT("Cartera Doc."."Currency Code");
    end;
}

