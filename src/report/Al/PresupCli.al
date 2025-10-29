/// <summary>
/// Report Presupuesto proyecto para cli (ID 50008).
/// </summary>
Report 50007 "Presupuesto proyecto para cli"
{
    DefaultLayout = RDLC;
    RDLCLayout = './src/report/layout/Presupuestoproyecto.rdlc';
    Caption = 'Presupuesto proyecto para cli';
    PreviewMode = PrintLayout;
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;

    dataset
    {
        dataitem(Job; Job)
        {
            DataItemTableView = SORTING("No.");
            RequestFilterFields = "No.", "Bill-to Customer No.";
            RequestFilterHeading = 'Presupuesto Proyecto';
            column(No_SalesInvHdr; "No.")
            {
            }
            column(PaymentTermsDescription; PaymentTerms.Description)
            {
            }
            column(ShipmentMethodDescription; ShipmentMethod.Description)
            {
            }
            column(PaymentMethodDescription; PaymentMethod.Description)
            {
            }
            column(PmtTermsDescCaption; PmtTermsDescCaptionLbl)
            {
            }
            column(ShpMethodDescCaption; ShpMethodDescCaptionLbl)
            {
            }
            column(PmtMethodDescCaption; PmtMethodDescCaptionLbl)
            {
            }
            column(DocDateCaption; DocDateCaptionLbl)
            {
            }
            column(HomePageCaption; 'Fecha Vencimiento')
            {
            }
            column(EmailCaption; EmailCaptionLbl)
            {
            }
            column(DisplayAdditionalFeeNote; DisplayAdditionalFeeNote)
            {
            }
            column(HayDto; HayDto) { }
            column(HayDto1; HayDto1) { }
            column(HayDto2; HayDto2) { }
            column(HayDtoTar; HayDtoTar) { }
            column(PrecioTar; PrecioTar) { }
            dataitem(CopyLoop; Integer)
            {
                DataItemTableView = SORTING(Number);
                dataitem(PageLoop; Integer)
                {
                    DataItemTableView = SORTING(Number)
                                        WHERE(Number = CONST(1));
                    column(CompanyInfo2Picture; CompanyInfo2.Picture)
                    {
                    }
                    column(CompanyInfo1Picture; CompanyInfo1.Picture)
                    {
                    }
                    column(CompanyInfo3Picture; CompanyInfo3.Picture)
                    {
                    }
                    column(DocumentCaption; STRSUBSTNO(DocumentCaption, CopyText))
                    {
                    }
                    column(CustAddr1; Job."Bill-to Name")
                    {
                    }
                    column(CompanyAddr1; CompanyAddr[1])
                    {
                    }
                    column(CustAddr2; CustAddr[1])
                    {
                    }
                    column(CompanyAddr2; CompanyAddr[2])
                    {
                    }
                    column(CustAddr3; CustAddr[2])
                    {
                    }
                    column(CompanyAddr3; CompanyAddr[3])
                    {
                    }
                    column(CustAddr4; CustAddr[3])
                    {
                    }
                    column(CompanyAddr4; CompanyAddr[4])
                    {
                    }
                    column(CustAddr5; CustAddr[4])
                    {
                    }
                    column(CompanyInfoPhoneNo; CompanyInfo."Phone No.")
                    {
                    }
                    column(CustAddr6; CustAddr[5])
                    {
                    }
                    column(CompanyInfoVATRegistrationNo; CompanyInfo."VAT Registration No.")
                    {
                    }
                    column(CompanyInfoHomePage; FORMAT(Job."Starting Date", 0, '<Day,2>/<Month,2>/<Year>'))
                    {
                    }
                    column(CompanyInfoEmail; TextoPie)
                    {
                    }
                    column(CompanyInfoGiroNo; CompanyInfo."Giro No.")
                    {
                    }
                    column(CompanyInfoBankName; CompanyInfo."Bank Name")
                    {
                    }
                    column(CompanyInfoBankAccountNo; CompanyInfo."Bank Account No.")
                    {
                    }
                    column(BilltoCustNo_SalesInvHdr; Job."Bill-to Customer No.")
                    {
                    }
                    column(PostingDate_SalesInvHdr; FORMAT(Job."Creation Date", 0, 4))
                    {
                    }
                    column(VATNoText; VATNoText)
                    {
                    }
                    column(VATRegNo_SalesInvHeader; Vat(Job."Bill-to Customer No."))
                    {
                    }
                    column(DueDate_SalesInvHeader; FORMAT(Job."Creation Date", 0, 4))
                    {
                    }
                    column(SalesPersonText; SalesPersonText)
                    {
                    }
                    column(SalesPurchPersonName; SalesPurchPerson.Name)
                    {
                    }
                    column(No_SalesInvoiceHeader1; Job."No.")
                    {
                    }
                    column(ReferenceText; ReferenceText)
                    {
                    }
                    column(YourReference_SalesInvHdr; Contrato)
                    {
                    }
                    column(OrderNoText; OrderNoText)
                    {
                    }
                    column(OrderNo_SalesInvHeader; Job."No.")
                    {
                    }
                    column(CustAddr7; CustAddr[6])
                    {
                    }
                    column(CustAddr8; CustAddr[7])
                    {
                    }
                    column(CompanyAddr5; CompanyAddr[5])
                    {
                    }
                    column(CompanyAddr6; CompanyAddr[6])
                    {
                    }
                    column(DocDate_SalesInvoiceHdr; FORMAT(Job."Starting Date", 0, 4))
                    {
                    }
                    column(PricesInclVAT_SalesInvHdr; false)
                    {
                    }
                    column(OutputNo; OutputNo)
                    {
                    }
                    column(PricesInclVATYesNo; FORMAT(false))
                    {
                    }
                    column(PageCaption; PageCaptionCap)
                    {
                    }
                    column(PhoneNoCaption; PhoneNoCaptionLbl)
                    {
                    }
                    column(VATRegNoCaption; VATRegNoCaptionLbl)
                    {
                    }
                    column(GiroNoCaption; GiroNoCaptionLbl)
                    {
                    }
                    column(BankNameCaption; BankNameCaptionLbl)
                    {
                    }
                    column(BankAccNoCaption; BankAccNoCaptionLbl)
                    {
                    }
                    column(DueDateCaption; DueDateCaptionLbl)
                    {
                    }
                    column(InvoiceNoCaption; InvoiceNoCaptionLbl)
                    {
                    }
                    column(PostingDateCaption; PostingDateCaptionLbl)
                    {
                    }
                    column(BilltoCustNo_SalesInvHdrCaption; Job.FIELDCAPTION("Bill-to Customer No."))
                    {
                    }
                    column(PricesInclVAT_SalesInvHdrCaption; 'Precios Iva Incluido')
                    {
                    }

                    column(CACCaption; CACCaptionLbl)
                    {
                    }
                    column(PeriodoDeFactura; Job."Global Dimension 1 Code")
                    { }
                    column(Fecha_Inicial_Contrato; Job."Starting Date")
                    {

                    }
                    Column(Fecha_final_proyecto; Job."Ending Date")
                    { }
                    column(ComentarioCabecera; '') { }
                    Column(DescripCion_Contrato; "Description Contrato") { }

                    column(TextImpr; TextImpr) { }
                    column(numreg; numreg) { }
                    column(TextoLopd; TextoLopd) { }
                    Column(PayMent_Identificador; "Number") { }
                    Column(PaymentMethod_Description; PaymentMethod.Description) { }
                    Column(Forma_de_Pago_Caption; 'Forma de Pago:') { }
                    Column(Fecha_vencimiento_Caption; '') { }
                    Column(Sales_Invoice_Header___Due_Date_; PaymentTerms.Description) { }
                    //Column(SalesSetup__Texto_1_LOPD_; TextoLopd) { }
                    Column(Cuenta_bancaria_Caption; 'Cuenta bancaria:') { }
                    Column(wCtaBancoIban; wCtaBancoIban) { }
                    column(vto1; aVtos[1])
                    { }
                    column(Importevto1; aImportes[1])
                    { }
                    column(vto2; aVtos[2])
                    { }
                    column(Importevto2; aImportes[2])
                    { }
                    column(vto3; aVtos[3])
                    { }
                    column(Importevto3; aImportes[3])
                    { }
                    column(vto4; aVtos[4])
                    { }
                    column(Importevto4; aImportes[4])
                    { }
                    column(vto5; aVtos[5])
                    { }
                    column(Importevto5; aImportes[5])
                    { }
                    column(vto6; aVtos[6])
                    { }
                    column(Importevto6; aImportes[6])
                    { }
                    column(vto7; aVtos[7])
                    { }
                    column(Importevto7; aImportes[7])
                    { }
                    column(vto8; aVtos[8])
                    { }
                    column(Importevto8; aImportes[8])
                    { }
                    column(vto9; aVtos[9])
                    { }
                    column(Importevto9; aImportes[9])
                    { }
                    column(vto10; aVtos[10])
                    { }
                    column(Importevto10; aImportes[10])
                    { }
                    column(vto11; aVtos[11])
                    { }
                    column(Importevto11; aImportes[11])
                    { }
                    column(vto12; aVtos[12])
                    { }
                    column(Importevto12; aImportes[12])
                    { }
                    column(vto13; aVtos[13])
                    { }
                    column(Importevto13; aImportes[13])
                    { }
                    column(vto14; aVtos[14])
                    { }
                    column(Importevto14; aImportes[14])
                    { }
                    column(vto15; aVtos[15])
                    { }
                    column(Importevto15; aImportes[15])
                    { }
                    column(vto16; aVtos[16])
                    { }
                    column(Importevto16; aImportes[16])
                    { }
                    column(vto17; aVtos[17])
                    { }
                    column(Importevto17; aImportes[17])
                    { }
                    column(vto18; aVtos[18])
                    { }
                    column(Importevto18; aImportes[18])
                    { }
                    column(vto19; aVtos[19])
                    { }
                    column(Importevto19; aImportes[19])
                    { }
                    column(vto20; aVtos[20])
                    { }
                    column(Importevto20; aImportes[20])
                    { }
                    column(vto21; aVtos[21])
                    { }
                    column(Importevto21; aImportes[21])
                    { }
                    column(vto22; aVtos[22])
                    { }
                    column(Importevto22; aImportes[22])
                    { }
                    column(vto23; aVtos[23])
                    { }
                    column(Importevto23; aImportes[23])
                    { }
                    column(vto24; aVtos[24])
                    { }
                    column(Importevto24; aImportes[24])
                    { }
                    column(vto25; aVtos[25])
                    { }
                    column(Importevto25; aImportes[25])
                    { }
                    column(vto26; aVtos[26])
                    { }
                    column(Importevto26; aImportes[26])
                    { }
                    column(vto27; aVtos[27])
                    { }
                    column(Importevto27; aImportes[27])
                    { }
                    column(vto28; aVtos[28])
                    { }
                    column(Importevto28; aImportes[28])
                    { }
                    column(vto29; aVtos[29])
                    { }
                    column(Importevto29; aImportes[29])
                    { }

                    dataitem(DimensionLoop1; Integer)
                    {
                        DataItemLinkReference = Job;
                        DataItemTableView = SORTING(Number)
                                            WHERE(Number = FILTER(1 ..));
                        column(DimText; DimText)
                        {
                        }
                        column(Number_DimensionLoop1; Number)
                        {
                        }
                        column(HdrDimsCaption; HdrDimsCaptionLbl)
                        {
                        }

                        trigger OnAfterGetRecord()
                        begin
                            if Number = 1 THEN BEGIN
                                if NOT DimSetEntry1.FINDSET THEN
                                    CurrReport.BREAK;
                            END ELSE
                                if NOT Continuar THEN
                                    CurrReport.BREAK;

                            CLEAR(DimText);
                            Continuar := FALSE;
                            REPEAT
                                OldDimText := DimText;
                                if DimText = '' THEN
                                    DimText := STRSUBSTNO('%1 %2', DimSetEntry1."Dimension Code", DimSetEntry1."Dimension Value Code")
                                ELSE
                                    DimText :=
                                      STRSUBSTNO(
                                        '%1, %2 %3', DimText,
                                        DimSetEntry1."Dimension Code", DimSetEntry1."Dimension Value Code");
                                if STRLEN(DimText) > MAXSTRLEN(OldDimText) THEN BEGIN
                                    DimText := OldDimText;
                                    Continuar := TRUE;
                                    EXIT;
                                END;
                            UNTIL DimSetEntry1.NEXT = 0;
                        end;

                        trigger OnPreDataItem()
                        begin
                            if NOT ShowInternalInfo THEN
                                CurrReport.BREAK;
                        end;
                    }
                    dataitem("Líneas Impresion"; 44)
                    {
                        DataItemTableView = SORTING("Document Type", "No.", "Document Line No.", "Line No.")
                          WHERE("Document Type" = CONST(Order),
                                Validada = CONST(true));
                        MaxIteration = 0;
                        DataItemLinkReference = Job;
                        DataItemLink = "No." = FIELD("No.");
                        column(Lineas_Impresion_LineNo; "Line No.") { }
                        Column(Lineas_Impresion_Code; Code) { }
                        Column(Lineas_Impresion_Comment; Comment) { }
                        Column(Lineas_Impresion_Precio; Precio) { }
                        Column(Cantidad_Precio; Cantidad * Precio) { }
                        Column(Lineas_Impresion_Cantidad; Cantidad) { }
                        trigger OnAfterGetRecord()
                        BEGIN
                            Importe := Importe - Iva;
                        END;

                    }
                    dataitem("Job Plannig Line"; 1003)
                    {
                        UseTemporary = true;
                        DataItemLink = "Job No." = FIELD("No.");
                        DataItemLinkReference = Job;
                        DataItemTableView = SORTING("Document No.", "Line No.");
                        column(GetCarteraInvoice; GetCarteraInvoice)
                        {
                        }
                        column(LineAmt_SalesInvoiceLine; "Total Venta")
                        {
                            AutoFormatExpression = GetCurrencyCode;
                            AutoFormatType = 1;
                        }
                        column(Description_SalesInvLine; Description)
                        {
                        }
                        column(No_SalesInvoiceLine; "No.")
                        {
                        }
                        column(Quantity_SalesInvoiceLine; Quantity)
                        {
                        }
                        column("Precio_Tarifa"; "Precio Tarifa")
                        { }
                        column("Dto_Tarifa"; Descuento("Dto. Tarifa"))
                        { }
                        column("Dto_Venta_1"; Descuento("% Dto. Venta 1"))
                        { }
                        column("Dto_Venta_2"; Descuento("% Dto. Venta 2"))
                        { }
                        column("Duracion"; TextoDuracion("Tipo Duracion", Duracion, "Cdad. Soportes"))
                        { }
                        column("Tipo_Duracion"; "Tipo Duracion")
                        { }
                        column(Cdad__Soportes; CandidadSoportes("Cdad. Soportes"))
                        { }
                        column(UOM_SalesInvoiceLine; "Job Plannig Line"."Unit of Measure Code")
                        {
                        }
                        column(UnitPrice_SalesInvLine; "Unit Price")
                        {
                            AutoFormatExpression = GetCurrencyCode;
                            AutoFormatType = 2;
                        }
                        column(LineDisc_SalesInvoiceLine; "% Dto. Venta")
                        {
                        }
                        column(VATIdent_SalesInvLine; '')
                        {
                        }
                        column(PostedShipmentDate; FORMAT(PostedShipmentDate))
                        {
                        }
                        column(Type_SalesInvoiceLine; FORMAT(Type))
                        {
                        }
                        column(InvDiscountAmount; -0)
                        {
                            AutoFormatExpression = GetCurrencyCode;
                            AutoFormatType = 1;
                        }
                        column(TotalSubTotal; TotalSubTotal)
                        {
                            AutoFormatExpression = Job."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(TotalInvoiceDiscountAmount; TotalInvoiceDiscountAmount)
                        {
                            AutoFormatExpression = Job."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(TotalAmount; TotalAmount)
                        {
                            AutoFormatExpression = Job."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(TotalGivenAmount; TotalGivenAmount)
                        {
                        }
                        column(SalesInvoiceLineAmount; "Job Plannig Line"."Line Amount")
                        {
                            AutoFormatExpression = GetCurrencyCode;
                            AutoFormatType = 1;
                        }
                        column(AmountIncludingVATAmount; "Job Plannig Line"."VAT Line Amount")
                        {
                            AutoFormatExpression = GetCurrencyCode;
                            AutoFormatType = 1;
                        }
                        column(Amount_SalesInvoiceLineIncludingVAT; "line Amount" + "Vat Line Amount")
                        {
                            AutoFormatExpression = GetCurrencyCode;
                            AutoFormatType = 1;
                        }
                        column(VATAmtLineVATAmtText; VATAmountLine.VATAmountText)
                        {
                        }
                        column(TotalExclVATText; TotalExclVATText)
                        {
                        }
                        column(TotalInclVATText; TotalInclVATText)
                        {
                        }
                        column(TotalAmountInclVAT; TotalAmountInclVAT)
                        {
                            AutoFormatExpression = Job."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(TotalAmountVAT; TotalAmountVAT)
                        {
                            AutoFormatExpression = Job."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(VATBaseDisc_SalesInvHdr; 0)
                        {
                            AutoFormatType = 1;
                        }
                        column(TotalPaymentDiscountOnVAT; TotalPaymentDiscountOnVAT)
                        {
                            AutoFormatType = 1;
                        }
                        column(VATAmtLineVATCalcType; VATAmountLine."VAT Calculation Type")
                        {
                        }
                        column(LineNo_SalesInvoiceLine; "Line No.")
                        {
                        }
                        column(PmtinvfromdebtpaidtoFactCompCaption; PmtinvfromdebtpaidtoFactCompCaptionLbl)
                        {
                        }
                        column(UnitPriceCaption; UnitPriceCaptionLbl)
                        {
                        }
                        column(DiscountCaption; DiscountCaptionLbl)
                        {
                        }
                        column(AmtCaption; AmtCaptionLbl)
                        {
                        }
                        column(PostedShpDateCaption; PostedShpDateCaptionLbl)
                        {
                        }
                        column(InvDiscAmtCaption; InvDiscAmtCaptionLbl)
                        {
                        }
                        column(SubtotalCaption; SubtotalCaptionLbl)
                        {
                        }
                        column(PmtDiscGivenAmtCaption; PmtDiscGivenAmtCaptionLbl)
                        {
                        }
                        column(PmtDiscVATCaption; PmtDiscVATCaptionLbl)
                        {
                        }
                        column(Description_SalesInvLineCaption; FIELDCAPTION(Description))
                        {
                        }
                        column(No_SalesInvoiceLineCaption; FIELDCAPTION("No."))
                        {
                        }
                        column(Quantity_SalesInvoiceLineCaption; FIELDCAPTION(Quantity))
                        {
                        }
                        column(UOM_SalesInvoiceLineCaption; FIELDCAPTION("Unit of Measure Code"))
                        {
                        }
                        column(VATIdent_SalesInvLineCaption; '')
                        {
                        }
                        column(IsLineWithTotals; LineNoWithTotal = "Line No.")
                        {
                        }

                        dataitem("Sales Shipment Buffer"; Integer)
                        {
                            DataItemTableView = SORTING(Number);
                            column(PostingDate_SalesShipmentBuffer; FORMAT(SalesShipmentBuffer."Posting Date"))
                            {
                            }
                            column(Quantity_SalesShipmentBuffer; SalesShipmentBuffer.Quantity)
                            {
                                DecimalPlaces = 0 : 5;
                            }
                            column(ShpCaption; ShpCaptionLbl)
                            {
                            }

                            trigger OnAfterGetRecord()
                            begin
                                // if Number = 1 THEN
                                //     SalesShipmentBuffer.FIND('-')
                                // ELSE
                                //     SalesShipmentBuffer.NEXT;
                            end;

                            trigger OnPreDataItem()
                            begin
                                //SalesShipmentBuffer.SETRANGE()

                                SETRANGE(Number, 0, 1);
                            end;
                        }
                        // dataItem(Textos; Integer)
                        // {
                        //     DataItemTableView = SORTING(Number);
                        //     Column(PTexto_Texto; PTexto.Texto) { }
                        //     trigger OnPreDataItem()
                        //     BEGIN
                        //         if NOT TextAmpl THEN
                        //             Textos.SETRANGE(Number, 1, 0)
                        //         ELSE
                        //             Textos.SETRANGE(Number, 0, PTexto.COUNT);
                        //         if NOT PTexto.FINDFIRST THEN
                        //             PTexto.INIT;
                        //     END;

                        //     trigger OnAfterGetRecord()
                        //     BEGIN
                        //         if Number > 0 THEN
                        //             if PTexto.NEXT = 0 THEN PTexto.INIT;
                        //     END;
                        // }

                        dataitem(DimensionLoop2; Integer)
                        {
                            DataItemTableView = SORTING(Number)
                                                WHERE(Number = FILTER(1 ..));
                            column(DimText1; DimText)
                            {
                            }
                            column(LineDimsCaption; LineDimsCaptionLbl)
                            {
                            }

                            trigger OnAfterGetRecord()
                            begin
                                if Number = 1 THEN BEGIN
                                    if NOT DimSetEntry2.FINDSET THEN
                                        CurrReport.BREAK;
                                END ELSE
                                    if NOT Continuar THEN
                                        CurrReport.BREAK;

                                CLEAR(DimText);
                                Continuar := FALSE;
                                REPEAT
                                    OldDimText := DimText;
                                    if DimText = '' THEN
                                        DimText := STRSUBSTNO('%1 %2', DimSetEntry2."Dimension Code", DimSetEntry2."Dimension Value Code")
                                    ELSE
                                        DimText :=
                                          STRSUBSTNO(
                                            '%1, %2 %3', DimText,
                                            DimSetEntry2."Dimension Code", DimSetEntry2."Dimension Value Code");
                                    if STRLEN(DimText) > MAXSTRLEN(OldDimText) THEN BEGIN
                                        DimText := OldDimText;
                                        Continuar := TRUE;
                                        EXIT;
                                    END;
                                UNTIL DimSetEntry2.NEXT = 0;
                            end;

                            trigger OnPreDataItem()
                            begin
                                if NOT ShowInternalInfo THEN
                                    CurrReport.BREAK;

                                DimSetEntry2.SETRANGE("Dimension Set ID", "Job Plannig Line"."Dimension Set ID");
                            end;
                        }
                        dataitem(AsmLoop; "Texto Presupuesto")
                        {
                            DataItemLink = "Nº proyecto" = FIELD("Job No."), "Cód. tarea" = FIELD("Job Task No."), Tipo = FIELD(Type), "Nº" = FIELD("No."), "Nº linea aux" = FIELD("Line No.");
                            column(TempPostedAsmLineUOMCode; '')
                            {
                                // DecimalPlaces = 0 : 5;
                            }
                            column(TempPostedAsmLineQuantity; 0)
                            {
                                //DecimalPlaces = 0 : 5;
                            }
                            column(TempPostedAsmLineVariantCode; '')
                            {
                                // DecimalPlaces = 0 : 5;
                            }
                            column(TempPostedAsmLineDescrip; AsmLoop.Texto)
                            {
                            }
                            column(TempPostedAsmLineNo; '')
                            {
                            }

                            trigger OnAfterGetRecord()
                            var
                                ItemTranslation: Record 30;
                            begin
                                // if Number = 1 THEN
                                //     TempPostedAsmLine.FINDSET
                                // ELSE
                                //     TempPostedAsmLine.NEXT;

                                // if ItemTranslation.GET(TempPostedAsmLine."No.",
                                //      TempPostedAsmLine."Variant Code",
                                //      Job."Language Code")
                                // THEN
                                //     TempPostedAsmLine.Description := ItemTranslation.Description;
                            end;

                            trigger OnPreDataItem()
                            begin
                                CLEAR(TempPostedAsmLine);
                                if NOT DisplayAssemblyInformation THEN
                                    CurrReport.BREAK;
                                //CollectAsmInformation;
                                // CLEAR(TempPostedAsmLine);
                                // SETRANGE(Number, 0, 1);
                            end;
                        }

                        trigger OnAfterGetRecord()
                        var
                            Res: Record Resource;
                            Gl: Record 15;
                            VtB: Code[20];
                            Vtp: Code[20];
                            Cust: Record Customer;
                        begin
                            PostedShipmentDate := 0D;
                            if Quantity <> 0 THEN
                                PostedShipmentDate := FindPostedShipmentDate;
                            if Cust.Get(Job."Bill-to Customer No.") Then VtB := Cust."VAT Bus. Posting Group";
                            if (Type = Type::"G/L Account") AND (NOT ShowInternalInfo) THEN begin
                                if Gl.Get("No.") Then Vtp := Gl."VAT Prod. Posting Group";
                                "No." := '';
                            End else
                                if Res.Get("No.") then Vtp := Res."VAT Prod. Posting Group";

                            if VATPostingSetup.GET(Vtb, Vtp) THEN BEGIN
                                VATAmountLine.INIT;
                                VATAmountLine."VAT Identifier" := VATPostingSetup."VAT Identifier";
                                VATAmountLine."VAT Calculation Type" := VATPostingSetup."VAT Calculation Type";
                                VATAmountLine."Tax Group Code" := '';
                                VATAmountLine."VAT %" := VATPostingSetup."VAT %";
                                VATAmountLine."EC %" := VATPostingSetup."EC %";
                                VATAmountLine."VAT Base" := "Job Plannig Line"."Line Amount";
                                VATAmountLine."Amount Including VAT" := "Job Plannig Line"."Line Amount" + "Job Plannig Line"."VAT Line Amount";
                                VATAmountLine."Line Amount" := "Line Amount";
                                VATAmountLine."Pmt. Discount Amount" := 0;
                                VATAmountLine."Invoice Discount Amount" := 0;
                                VATAmountLine.SetCurrencyCode(Job."Currency Code");
                                VATAmountLine."VAT Difference" := 0;
                                VATAmountLine."EC Difference" := 0;
                                VATAmountLine."VAT Clause Code" := VATPostingSetup."VAT Clause Code";
                                VATAmountLine.InsertLine;
                                // MNC 020201
                                VATAmountLine.SetCurrencyCode(Job."Currency Code");
                                // Fi MNC

                                VATAmountLine.InsertLine;

                                //$002(I)
                                if VATAmountLine."VAT Amount" < 0 THEN BEGIN
                                    if wNo = '485000001' THEN BEGIN                                   //$012
                                        wBaseIvaPrep := wBaseIvaPrep + VATAmountLine."VAT Base";
                                        wImpIVaPrep := wImpIVaPrep + VATAmountLine."VAT Amount";
                                    END;                                                              //$012
                                END;
                                //$002(F)

                                TotalSubTotal += "Total Venta";
                                TotalInvoiceDiscountAmount -= 0;
                                TotalAmount += "Total Venta";
                                "VAT Line Amount" := "Total venta" * ("Vat %" / 100);
                                TotalAmountVAT += "VAT Line Amount";
                                if "Vat Line Amount" = 0 Then "VAT Line Amount" := "Total venta" * ("Vat %" / 100);
                                TotalAmountInclVAT += "Total Venta" + "VAT Line Amount";
                                if wTotal2 = wTotal2::"Imprimir Total Sin IVA" then
                                    TotalAmountInclVAT := 0;
                                TotalGivenAmount -= 0;
                                TotalPaymentDiscountOnVAT += -("Vat Line Amount");// - "Inv. Discount Amount" - "Pmt. Discount Amount" - "Amount Including VAT");
                            END;
                            // $013
                            CLEAR(CabeceraG);
                            if (wTarea <> "Job Plannig Line"."Job Task No.") THEN BEGIN
                                wDescTareaAnt := wDescTarea;
                                wTarea := "Job Plannig Line"."Job Task No.";
                                if rTarea.GET("Job Plannig Line"."Job No.", "Job Plannig Line"."Job Task No.") THEN
                                    wDescTarea := rTarea.Description
                                ELSE
                                    wDescTarea := 'Tarea';
                                if AgrRec THEN
                                    wDescTarea := wDescTarea + ' ' + rTarea."Descripcion 2";
                                CabeceraG := TRUE;
                                wTotTareaPie := wTotTarea;
                                wTotTarea := 0;
                            END ELSE BEGIN
                                CabeceraG := FALSE;
                            END;
                            wTotTarea := wTotTarea + "Job Plannig Line"."Line Amount";
                            if TextAmpl THEN BEGIN
                                FiltroTexto2("Job Plannig Line", PTexto);
                            END;
                            "Unit of Measure Code" := '';
                            if Type = Type::Resource then begin
                                if rRecurs.Get("No.") Then "Unit of Measure Code" := Copystr(rRecurs.Medidas, 1, MaxStrLen("Unit of measure Code"));
                            end;
                        end;

                        trigger OnPreDataItem()
                        begin
                            VATAmountLine.DELETEALL;
                            FirstValueEntryNo := 0;
                            MoreLines := FIND('+');
                            LineNoWithTotal := "Line No.";
                            WHILE MoreLines AND (Description = '') AND ("No." = '') AND (Quantity = 0) AND ("Line Amount" = 0) DO
                                MoreLines := NEXT(-1) <> 0;
                            if NOT MoreLines THEN
                                CurrReport.BREAK;
                            SETRANGE("Line No.", 0, "Line No.");

                        end;
                    }


                    dataitem(VATCounter; Integer)
                    {
                        DataItemTableView = SORTING(Number);
                        column(VATAmountLineVATBase; VATAmountLine."VAT Base")
                        {
                            AutoFormatExpression = GetCurrencyCode;
                            AutoFormatType = 1;
                        }
                        column(VATAmountLineVATAmount; VATAmountLine."VAT Amount")
                        {
                            AutoFormatExpression = Job."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(VATAmountLineLineAmount; VATAmountLine."Line Amount")
                        {
                            AutoFormatExpression = Job."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(VATAmtLineInvDiscBaseAmt; VATAmountLine."Inv. Disc. Base Amount")
                        {
                            AutoFormatExpression = Job."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(VATAmtLineInvDiscountAmt; VATAmountLine."Invoice Discount Amount" + VATAmountLine."Pmt. Discount Amount")
                        {
                            AutoFormatExpression = Job."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(VATAmtLineECAmount; VATAmountLine."EC Amount")
                        {
                            AutoFormatExpression = Job."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(VATAmountLineVAT; VATAmountLine."VAT %")
                        {
                            DecimalPlaces = 0 : 6;
                        }
                        column(VATAmtLineVATIdentifier; VATAmountLine."VAT Identifier")
                        {
                        }
                        column(VATAmountLineEC; VATAmountLine."EC %")
                        {
                            AutoFormatExpression = Job."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(VATAmtLineVATCaption; VATAmtLineVATCaptionLbl)
                        {
                        }
                        column(VATECBaseCaption; VATECBaseCaptionLbl)
                        {
                        }
                        column(VATAmountCaption; VATAmountCaptionLbl)
                        {
                        }
                        column(VATAmtSpecCaption; VATAmtSpecCaptionLbl)
                        {
                        }
                        column(VATIdentCaption; VATIdentCaptionLbl)
                        {
                        }
                        column(InvDiscBaseAmtCaption; InvDiscBaseAmtCaptionLbl)
                        {
                        }
                        column(LineAmtCaption1; LineAmtCaption1Lbl)
                        {
                        }
                        column(InvPmtDiscCaption; InvPmtDiscCaptionLbl)
                        {
                        }
                        column(ECAmtCaption; ECAmtCaptionLbl)
                        {
                        }
                        column(ECCaption; ECCaptionLbl)
                        {
                        }
                        column(TotalCaption; TotalCaptionLbl)
                        {
                        }

                        trigger OnAfterGetRecord()
                        begin
                            VATAmountLine.GetLine(Number);
                            if VATAmountLine."VAT Amount" = 0 THEN
                                VATAmountLine."VAT %" := 0;
                            if VATAmountLine."EC Amount" = 0 THEN
                                VATAmountLine."EC %" := 0;
                        end;

                        trigger OnPreDataItem()
                        begin
                            SETRANGE(Number, 1, VATAmountLine.COUNT);
#pragma warning disable AL0667
                            CurrReport.CREATETOTALS(
                              VATAmountLine."Line Amount", VATAmountLine."Inv. Disc. Base Amount",
                              VATAmountLine."Invoice Discount Amount", VATAmountLine."VAT Base", VATAmountLine."VAT Amount",
                              VATAmountLine."EC Amount", VATAmountLine."Pmt. Discount Amount");
#pragma warning restore AL0667
                        end;
                    }
                    dataitem(VATClauseEntryCounter; Integer)
                    {
                        DataItemTableView = SORTING(Number);
                        column(VATClauseVATIdentifier; VATAmountLine."VAT Identifier")
                        {
                        }
                        column(VATClauseCode; VATAmountLine."VAT Clause Code")
                        {
                        }
                        column(VATClauseDescription; VATClause.Description)
                        {
                        }
                        column(VATClauseDescription2; VATClause."Description 2")
                        {
                        }
                        column(VATClauseAmount; VATAmountLine."VAT Amount")
                        {
                            AutoFormatExpression = Job."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(VATClausesCaption; VATClausesCap)
                        {
                        }
                        column(VATClauseVATIdentifierCaption; VATIdentifierCaptionLbl)
                        {
                        }
                        column(VATClauseVATAmtCaption; VATAmtCaptionLbl)
                        {
                        }

                        trigger OnAfterGetRecord()
                        begin
                            VATAmountLine.GetLine(Number);
                            if NOT VATClause.GET(VATAmountLine."VAT Clause Code") THEN
                                CurrReport.SKIP;
                            VATClause.TranslateDescription(Job."Language Code");
                        end;

                        trigger OnPreDataItem()
                        begin
                            CLEAR(VATClause);
                            SETRANGE(Number, 1, VATAmountLine.COUNT);
#pragma warning disable AL0667
                            CurrReport.CREATETOTALS(VATAmountLine."VAT Amount");
#pragma warning restore AL0667
                        end;
                    }
                    dataitem(VatCounterLCY; Integer)
                    {
                        DataItemTableView = SORTING(Number);
                        column(VALSpecLCYHeader; VALSpecLCYHeader)
                        {
                        }
                        column(VALExchRate; VALExchRate)
                        {
                        }
                        column(VALVATBaseLCY; VALVATBaseLCY)
                        {
                            AutoFormatType = 1;
                        }
                        column(VALVATAmountLCY; VALVATAmountLCY)
                        {
                            AutoFormatType = 1;
                        }
                        column(VATAmountLineVAT1; VATAmountLine."VAT %")
                        {
                            DecimalPlaces = 0 : 5;
                        }
                        column(VATAmtLineVATIdentifier1; VATAmountLine."VAT Identifier")
                        {
                        }
                        column(VALVATBaseLCYCaption1; VALVATBaseLCYCaption1Lbl)
                        {
                        }

                        trigger OnAfterGetRecord()
                        begin
                            VATAmountLine.GetLine(Number);
                            VALVATBaseLCY :=
                              VATAmountLine.GetBaseLCY(
                                Job."Starting Date", Job."Currency Code",
                                1);
                            VALVATAmountLCY :=
                              VATAmountLine.GetAmountLCY(
                                Job."Starting Date", Job."Currency Code",
                                1);
                        end;

                        trigger OnPreDataItem()
                        begin
                            if (NOT GLSetup."Print VAT specification in LCY") OR
                               (Job."Currency Code" = '')
                            THEN
                                CurrReport.BREAK;

                            SETRANGE(Number, 1, VATAmountLine.COUNT);
#pragma warning disable AL0667
                            CurrReport.CREATETOTALS(VALVATBaseLCY, VALVATAmountLCY);
#pragma warning restore AL0667

                            if GLSetup."LCY Code" = '' THEN
                                VALSpecLCYHeader := Text007 + Text008
                            ELSE
                                VALSpecLCYHeader := Text007 + FORMAT(GLSetup."LCY Code");

                            CurrExchRate.FindCurrency(Job."Starting Date", Job."Currency Code", 1);
                            CalculatedExchRate := ROUND(1 / 1 * CurrExchRate."Exchange Rate Amount", 0.000001);
                            VALExchRate := STRSUBSTNO(Text009, CalculatedExchRate, CurrExchRate."Exchange Rate Amount");
                        end;
                    }
                    // dataitem(PaymentReportingArgument; 1062)
                    // {
                    //     DataItemTableView = SORTING(Key);
                    //     UseTemporary = true;
                    //     column(PaymentServiceLogo; Logo)
                    //     {
                    //     }
                    //     column(PaymentServiceURLText; "URL Caption")
                    //     {
                    //     }
                    //     column(PaymentServiceURL; GetTargetURL)
                    //     {
                    //     }

                    //     trigger OnPreDataItem()
                    //     var
                    //         PaymentServiceSetup: Record 1060;
                    //     begin
                    //         PaymentServiceSetup.CreateReportingArgs(PaymentReportingArgument, Job);
                    //         if ISEMPTY THEN
                    //             CurrReport.BREAK;
                    //     end;
                    // }

                    dataItem("Sales Comment Line"; 44)
                    {
                        DataItemTableView = SORTING("Document Type", "No.", "Document Line No.", "Line No.")
                          WHERE("Document Type" = CONST("Posted Invoice"));
                        DataItemLinkReference = Job;
                        DataItemLink = "No." = FIELD("No.");
                        Column(Sales_Comment_Line_Comment; Comment)
                        { }

                    }
                    dataitem(Total; Integer)
                    {
                        DataItemTableView = SORTING(Number)
                                            WHERE(Number = CONST(1));
                    }
                    dataitem(Total2; Integer)
                    {
                        DataItemTableView = SORTING(Number)
                                            WHERE(Number = CONST(1));
                        column(SelltoCustNo_SalesInvHdr; Job."Bill-to Customer No.")
                        {
                        }
                        column(ShipToAddr1; ShipToAddr[1])
                        {
                        }
                        column(ShipToAddr2; ShipToAddr[2])
                        {
                        }
                        column(ShipToAddr3; ShipToAddr[3])
                        {
                        }
                        column(ShipToAddr4; ShipToAddr[4])
                        {
                        }
                        column(ShipToAddr5; ShipToAddr[5])
                        {
                        }
                        column(ShipToAddr6; ShipToAddr[6])
                        {
                        }
                        column(ShipToAddr7; ShipToAddr[7])
                        {
                        }
                        column(ShipToAddr8; ShipToAddr[8])
                        {
                        }
                        column(ShiptoAddressCaption; ShiptoAddressCaptionLbl)
                        {
                        }
                        column(SelltoCustNo_SalesInvHdrCaption; Job.FIELDCAPTION("Bill-to Customer No."))
                        {
                        }

                        trigger OnPreDataItem()
                        begin
                            if NOT ShowShippingAddr THEN
                                CurrReport.BREAK;
                        end;
                    }
                    dataitem(LineFee; Integer)
                    {
                        DataItemTableView = SORTING(Number)
                                            ORDER(Ascending)
                                            WHERE(Number = FILTER(1 ..));
                        column(LineFeeCaptionLbl; TempLineFeeNoteOnReportHist.ReportText)
                        {
                        }

                        trigger OnAfterGetRecord()
                        begin
                            if NOT DisplayAdditionalFeeNote THEN
                                CurrReport.BREAK;

                            if Number = 1 THEN BEGIN
                                if NOT TempLineFeeNoteOnReportHist.FINDSET THEN
                                    CurrReport.BREAK
                            END ELSE
                                if TempLineFeeNoteOnReportHist.NEXT = 0 THEN
                                    CurrReport.BREAK;
                        end;
                    }
                }

                trigger OnAfterGetRecord()
                begin
                    if Number > 1 THEN BEGIN
                        CopyText := FormatDocument.GetCOPYText;
                        OutputNo += 1;
                    END;
#pragma warning disable AL0667
                    CurrReport.PAGENO := 1;
#pragma warning restore AL0667

                    TotalSubTotal := 0;
                    TotalInvoiceDiscountAmount := 0;
                    TotalAmount := 0;
                    TotalAmountVAT := 0;
                    TotalAmountInclVAT := 0;
                    TotalGivenAmount := 0;
                    TotalPaymentDiscountOnVAT := 0;
                end;

                trigger OnPostDataItem()
                begin
                    //if NOT CurrReport.PREVIEW THEN
                    //  CODEUNIT.RUN(CODEUNIT::"Sales-Printed", Job);
                end;

                trigger OnPreDataItem()
                begin
                    NoOfLoops := ABS(NoOfCopies) + Cust."Invoice Copies" + 1;
                    if NoOfLoops <= 0 THEN
                        NoOfLoops := 1;
                    CopyText := '';
                    SETRANGE(Number, 1, NoOfLoops);
                    OutputNo := 1;
                end;
            }

            trigger OnAfterGetRecord()
            Var
                rLinVtaOrd: Record 113;
                wTarea: Code[20];
                rContr: Record 36;
                r289: Record 289;
                rShip: Record 222;
                rCom: Record 44;
                rBanco: Record 270;
                rBcoCli: Record "Customer Bank Account";
                Coment: Record "Sales Comment Line";
                rPropuestas: Record "Facturas Propuestas";
                j: Integer;
                JobPlL: Record "Job Planning Line";
                rLinV: Record "Job Planning Line";
                Texto: Record "Texto Presupuesto";
                a: Integer;
            begin
                HayDto := '';
                HayDto1 := '';
                HayDto2 := '';
                HayDtoTar := '';
                JobPlL.SetRange("Job No.", Job."No.");
                rLinV.SetRange("Job No.", Job."No.");
                rLinV.SETFILTER("Line Discount %", '<>%1', 0);
                if rLinV.FindFirst() THEN
                    HayDto := '%Dto';
                rLinV.SetRange("Line Discount %");
                rLinV.SETFILTER("% Dto. Venta 1", '<>%1', 0);
                if rLinV.FindFirst() THEN
                    HayDto1 := 'Dto. Vta. 1';
                rLinV.SetRange("% Dto. Venta 1");
                rLinV.SETFILTER("% Dto. Venta 2", '<>%1', 0);
                if rLinV.FindFirst() THEN
                    HayDto2 := 'Dto. Vta. 2';
                rLinV.SetRange("% Dto. Venta 2");
                rLinV.SETFILTER("Dto. Tarifa", '<>%1', 0);
                if rLinV.FindFirst() THEN
                    HayDtoTar := 'Dto. Tarifa';
                rLinV.SetRange("Dto. Tarifa");
                If HayDtoTAr <> '' then
                    PrecioTAr := 'Precio Tarifa' else begin
                    PrecioTAr := '';
                    If rlinv.findSet() then
                        repeat
                            If (rlinv."Precio Tarifa" <> rLinV."Unit Price") then
                                if rlinv."Precio Tarifa" <> 0 then
                                    PrecioTAr := 'Precio Tarifa';
                            if PrecioTar <> '' then
                                rLinV.FindLast();
                        until rLinv.Next() = 0;
                end;
                JobPlL.SetRange("Job No.", Job."No.");
                JobPlL.SetRange("Imprmir en Contrato/Factura", TRUE);
                if JobPlL.FindFirst() Then
                    repeat
                        a += 1;
                        "Job Plannig Line" := JobPlL;
                        "Job Plannig Line"."Line No." := a;

                        "Job Plannig Line".Insert();
                        Texto.SetRange("Nº Proyecto", Job."No.");
                        Texto.SetRange("Nº linea aux", JobPlL."Line No.");
                        texto.SetRange("Cód. tarea", JobPlL."Job Task No.");

                        Texto.SetFilter("Tipo linea", '%1|%2', Texto."Tipo linea"::Venta, Texto."Tipo linea"::Ambos);
                        if Texto.FindFirst() Then
                            repeat
                                a += 1;
                                "Job Plannig Line".Init();
                                "Job Plannig Line".Type := "Job Plannig Line".Type::text;
                                "Job Plannig Line"."Job No." := Job."No.";
                                "Job Plannig Line"."Line No." := a;
                                "Job Plannig Line".Description := Texto.Texto;
                                "Job Plannig Line".Insert();
                            until Texto.Next() = 0;
                    until JobPlL.Next() = 0;
                // CurrReport.LANGUAGE := GlobalLanguage.GetLanguageID("Language Code");
                //ASC

                Customer.Get("Bill-to Customer No.");
                rContr.SetRange("Nº Proyecto", "No.");
                rContr.SetRange("Document Type", rContr."Document Type"::Order);
                if rContr.FindFirst() Then Contrato := rContr."No.";
                rContr.Reset;
                CLEAR(rPropuestas);
                rPropuestas.RESET;
                if Empresa <> '' THEN
                    Numero := COPYSTR("No.", 2, 20);
                if Empresa <> '' THEN
                    CompanyInfo.GET(Empresa)
                ELSE
                    CompanyInfo.GET;
                CompanyInfo1.Get();
                CompanyInfo1.CalcFields(Picture);
                FormatAddr.Company(CompanyAddr, CompanyInfo);

                if Empresa <> '' THEN
                    SalesPurchPerson.CHANGECOMPANY(Empresa);
                if Job."Cód. vendedor" = '' THEN BEGIN
                    SalesPurchPerson.INIT;
                    SalesPersonText := '';
                END ELSE BEGIN
                    SalesPurchPerson.GET("Cód. vendedor");
                    SalesPersonText := "Cód. vendedor";
                END;
                ReferenceText := '';
                if Customer."VAT Registration No." = '' THEN
                    VATNoText := ''
                ELSE
                    VATNoText := 'C.I.F.';
                if "Currency Code" = '' THEN BEGIN
                    GLSetup.TESTFIELD("LCY Code");
                    TotalText := STRSUBSTNO(Text001, GLSetup."LCY Code");
                    TotalInclVATText := STRSUBSTNO(Text102, GLSetup."LCY Code");  //FCL-text002 es text102
                    TotalExclVATText := STRSUBSTNO(Text106, GLSetup."LCY Code");  //FCL-text006 es text106
                    auxDivisa := GLSetup."LCY Code";                             //FCL-09/03/04. Migración.
                    auxDA := GLSetup."Additional Reporting Currency";            //FCL-09/03/04. Migración.
                END ELSE BEGIN
                    TotalText := STRSUBSTNO(Text001, "Currency Code");
                    TotalInclVATText := STRSUBSTNO(Text102, "Currency Code");     //FCL-text002 es text102
                    TotalExclVATText := STRSUBSTNO(Text106, "Currency Code");     //FCL-text006 es text106
                    auxDivisa := "Currency Code";                                //FCL-09/03/04. Migración.
                    auxDA := GLSetup."Additional Reporting Currency";            //FCL-09/03/04. Migración.
                END;
                FormatAddr.Customer(CustAddr, Customer);

                if Empresa <> '' THEN
                    Cust.CHANGECOMPANY(Empresa);

                if NOT Cust.GET("Bill-to Customer No.") THEN
                    CLEAR(Cust);

                // MNC 240300
                if CustAddr[1] = Customer."Name" Then CustAddr[1] := '';
                CustAddr[8] := 'CIF/NIF: ' + Cust."VAT Registration No.";
                COMPRESSARRAY(CustAddr);
                // MNC 240300

                if Empresa <> '' THEN
                    PaymentTerms.CHANGECOMPANY(Empresa);

                if Customer."Payment Terms Code" = '' THEN
                    PaymentTerms.INIT
                ELSE BEGIN
                    PaymentTerms.GET(Customer."Payment Terms Code");
                    PaymentTerms.TranslateDescription(PaymentTerms, "Language Code");
                END;

                if Empresa <> '' THEN
                    r289.CHANGECOMPANY(Empresa);

                if Job."Payment Method Code" = '' THEN begin
                    job."Payment Method Code" := Cust."Payment Method Code";
                    if not r289.GET(Job."Payment Method Code") Then
                        r289.INIT
                end ELSE
                    r289.GET(Job."Payment Method Code");

                PaymentMethod := r289;
                if PaymentMethod.INSERT THEN;
                if PaymentMethod.Description = '' Then PaymentMethod.Description := Cust."Payment Method Code";
                // if "Shipment Method Code" = '' THEN
                //     ShipmentMethod.INIT
                // ELSE BEGIN
                //     ShipmentMethod.GET("Shipment Method Code");
                //     ShipmentMethod.TranslateDescription(ShipmentMethod, "Language Code");
                // END;
                // //ASC 20/08/13
                // rShip.SETRANGE(rShip."Customer No.", Job."Sell-to Customer No.");
                // if rShip.COUNT = 1 THEN BEGIN

                //     rShip.FINDFIRST;
                //     Job."Ship-to Code" := rShip.Code;
                //     Job."Ship-to Name" := rShip.Name;
                //     Job."Ship-to Name 2" := rShip."Name 2";
                //     Job."Ship-to Address" := rShip.Address;
                //     Job."Ship-to Address 2" := rShip."Address 2";
                //     Job."Ship-to City" := rShip.City;
                //     Job."Ship-to Contact" := rShip.Contact;
                //     Job."Ship-to Post Code" := rShip."Post Code";
                //     Job."Ship-to County" := rShip.County;
                //     Job."Ship-to Country/Region Code" := rShip."Country/Region Code";

                // END;
                //$009
                SalesSetup.Get;
                TextoLopd := SalesSetup."Texto 1 LOPD";//+ ' ' + SalesSetup."Texto 2 LOPD" + ' ' + SalesSetup."Texto 3 LOPD" + ' ' + SalesSetup."Texto 4 LOPD" +
                                                       //' ' + SalesSetup."Texto 5 LOPD" + ' ' + SalesSetup."Texto 6 LOPD" + ' ' + SalesSetup."Texto 7 LOPD";
                wCtaBancoIban := '';
                // if Job."Nuestra Cuenta" <> '' THEN BEGIN
                //     PaymentMethod."Banco transferencia" := Job."Nuestra Cuenta";
                //     //  PaymentMethod.MODIFY;
                // END;

                // if PaymentMethod."Banco transferencia" <> '' THEN BEGIN
                //     if rBanco.GET(PaymentMethod."Banco transferencia") THEN BEGIN
                //         if rBanco.IBAN <> '' THEN
                //             wCtaBancoIban := ('IBAN: ' + COPYSTR(rBanco.IBAN, 1, 4) + ' ' +
                //                 COPYSTR(rBanco.IBAN, 5, 4) + ' ' +
                //                 COPYSTR(rBanco.IBAN, 9, 4) + ' ' +
                //                 COPYSTR(rBanco.IBAN, 13, 4) + ' ' +
                //                 COPYSTR(rBanco.IBAN, 17, 4) + ' ' +
                //                 COPYSTR(rBanco.IBAN, 21, 4) + ' ' +
                //                 COPYSTR(rBanco.IBAN, 25, 4) + ' ' +
                //                 COPYSTR(rBanco.IBAN, 29, 4))

                //         ELSE
                //             wCtaBancoIban := rBanco."CCC Bank No." + '-' + rBanco."CCC Bank Branch No." + '-' +
                //                         rBanco."CCC Control Digits" + '-' + rBanco."CCC Bank Account No.";
                //         //SetRange(Number,1,1);
                //     END;
                // END
                // ELSE BEGIN
                //     if PaymentMethod."Domiciliacion cliente" THEN BEGIN
                //         if rBcoCli.GET(Job."Bill-to Customer No.", Job."Cust. Bank Acc. Code") THEN BEGIN
                //             if rBcoCli.IBAN <> '' THEN
                //                 wCtaBancoIban := ('IBAN: ' + COPYSTR(rBcoCli.IBAN, 1, 4) + ' ' +
                //                     COPYSTR(rBcoCli.IBAN, 5, 4) + ' ' +
                //                     COPYSTR(rBcoCli.IBAN, 9, 4) + ' ' +
                //                     COPYSTR(rBcoCli.IBAN, 13, 2) + ' ' +
                //                     COPYSTR(rBcoCli.IBAN, 16))
                //             ELSE
                //                 wCtaBancoIban := rBcoCli."CCC Bank No." + '-' + rBcoCli."CCC Bank Branch No." + '-' +
                //                             rBcoCli."CCC Control Digits" + '-' + rBcoCli."CCC Bank Account No.";
                //             //SetRange(Number,1,1);
                //         END;
                //     END;
                //END;
                //
                //FormatAddr.SalesInvShipTo(ShipToAddr,Job);

                // MNC 240500
                //ShipToAddr[8] := 'CIF/NIF: ' + Cust."VAT Registration No.";
                FormatAddressFields(Job);
                FormatDocumentFields(Job);
                COMPRESSARRAY(ShipToAddr);
                // MNC 240500

                ShowShippingAddr := "Bill-to Customer No." <> "Bill-to Customer No.";
                FOR i := 1 TO ARRAYLEN(ShipToAddr) DO
                    if ShipToAddr[i] <> CustAddr[i] THEN
                        ShowShippingAddr := TRUE;


                //$002(I)
                wTotPrepago := 0;
                wPorPrepago := 0;
                wBaseIvaPrep := 0;
                wImpIVaPrep := 0;
                //$002(F)

                //$008(I)
                wFecReg := Job."Starting Date";
                if FecEmis THEN
                    wFecReg := Job."Creation Date";
                //$008(F)

                //$013(I). Si se tiene que ordenar por tarea la grabaré en el campo Cod Ordenacion.
                wPriVez := TRUE;
                wPriVez2 := TRUE;
                CLEAR(wTotTarea);
                CLEAR(wTotTareaPie);
                if Empresa <> '' THEN
                    rLinVtaOrd.CHANGECOMPANY(Empresa);
                if (AgrRec) OR (TotTarea) THEN BEGIN
                    rLinVtaOrd.RESET;
                    rLinVtaOrd.SETRANGE("Document No.", Job."No.");
                    if rLinVtaOrd.FINDSET THEN BEGIN
                        REPEAT
                            if rLinVtaOrd.Type.AsInteger() <> 0 THEN BEGIN
                                if rLinVtaOrd.Type <> rLinVtaOrd.Type::"G/L Account" THEN BEGIN
                                    wTarea := rLinVtaOrd."Job Task No.";
                                    rLinVtaOrd."Cod ordenacion" := rLinVtaOrd."Job Task No.";
                                END
                                ELSE BEGIN
                                    wTarea := rLinVtaOrd."No.";
                                    rLinVtaOrd."Cod ordenacion" := rLinVtaOrd."No.";
                                END;
                            END
                            ELSE BEGIN
                                rLinVtaOrd."Cod ordenacion" := wTarea;
                            END;
                            rLinVtaOrd.MODIFY;
                        UNTIL rLinVtaOrd.NEXT = 0;
                    END;
                END;
                //$013(F).
                if rContr.Get(rContr."Document Type"::Order, Contrato) then
                    "Description Contrato" := rContr."Posting Description";
                //FinASC
                if "Description Contrato" = '' Then "Description Contrato" := Description;

                if NOT Cust.GET("Bill-to Customer No.") THEN
                    CLEAR(Cust);

                DimSetEntry1.SETRANGE("Dimension Set ID", 0);// "Dimension Set ID");

                //GetLineFeeNoteOnReportHist("No.");

                // if LogInteraction THEN
                //     if NOT CurrReport.PREVIEW THEN BEGIN
                //         if "Bill-to Contact No." <> '' THEN
                //             SegManagement.LogDocument(
                //               4, "No.", 0, 0, DATABASE::Contact, "Bill-to Contact No.", "Salesperson Code",
                //               "Campaign No.", "Posting Description", '')
                //         ELSE
                //             SegManagement.LogDocument(
                //               4, "No.", 0, 0, DATABASE::Customer, "Bill-to Customer No.", "Salesperson Code",
                //               "Campaign No.", "Posting Description", '');
                //     END;
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
                        ToolTip = 'Specifies how many copies of the document to print.';
                    }
                    // field(ShowInternalInfo; ShowInternalInfo)
                    // {
                    //     ApplicationArea = Basic, Suite;
                    //     Caption = 'Mostrar información interna';
                    //     ToolTip = 'Specifies if the document shows internal information.';
                    // }
                    // field(LogInteraction; LogInteraction)
                    // {
                    //     ApplicationArea = Basic, Suite;
                    //     Caption = 'Log Interacción';
                    //     Enabled = LogInteractionEnable;
                    //     ToolTip = 'Specifies that interactions with the contact are logged.';
                    // }
                    // field(DisplayAsmInformation; DisplayAssemblyInformation)
                    // {
                    //     ApplicationArea = All;
                    //     Caption = 'Ver facturas propuestas';
                    // }

                    // field(DisplayAdditionalFeeNote; DisplayAdditionalFeeNote)
                    // {
                    //     ApplicationArea = Basic, Suite;
                    //     Caption = 'Mostrar nota de tarifa adicional';
                    //     ToolTip = 'Specifies that any notes about additional fees are included on the document.';
                    // }
                    field(Logotipo; Logotipo) { ApplicationArea = All; }
                    field("Imprimir Solo Totales"; wToTal2) { ApplicationArea = All; }
                    field("Imprimir fecha emisión doc."; FecEmis) { ApplicationArea = All; }
                    field("Recursos agrupados por tarea"; AgrRec) { ApplicationArea = All; }
                    field("Totales por tarea"; TotTarea) { ApplicationArea = All; }
                    field("Solo Texto Ampliado"; TextAmpl) { ApplicationArea = All; }
                    field("Solo Texto Impresión"; TextImpr) { ApplicationArea = All; }
                    field("Imprimir Texto ampliado línea"; DisplayAssemblyInformation) { ApplicationArea = All; }
                    field("Imprimir Dirección Envio"; ShipAd) { ApplicationArea = All; }


                }
            }
        }

        actions
        {
        }

        trigger OnInit()
        begin
            LogInteractionEnable := TRUE;
        end;

        trigger OnOpenPage()
        begin
            InitLogInteraction;
            LogInteractionEnable := LogInteraction;
        end;
    }

    labels
    {
    }

    trigger OnInitReport()
    begin
        GLSetup.GET;
        SalesSetup.GET;
        CompanyInfo.GET;
        if Logotipo Then
            FormatDocument.SetLogoPosition(SalesSetup."Logo Position on Documents", CompanyInfo1, CompanyInfo2, CompanyInfo3);
        TextoPie := SalesSetup."Texto empresa" + ' ' + SalesSetup."Pie 1 factura";
        TextoLopd := SalesSetup."Texto 1 LOPD";//+ ' ' + SalesSetup."Texto 2 LOPD" + ' ' + SalesSetup."Texto 3 LOPD" + ' ' + SalesSetup."Texto 4 LOPD" +
                                               //                   ' ' + SalesSetup."Texto 5 LOPD" + ' ' + SalesSetup."Texto 6 LOPD" + ' ' + SalesSetup."Texto 7 LOPD";
    end;

    trigger OnPreReport()
    begin
        if NOT CurrReport.USEREQUESTPAGE THEN
            InitLogInteraction;
    end;

    var
        Contratos: Record 36;
        Contrato: Text;
        Customer: Record Customer;
        Text000: Label 'Vendedor';

        Text001: Label 'Total %1';
        Text002: Label 'Total %1 IVA+RE incl.';
        Text003: Label 'COPIA';
        Text005: Label 'Pág. %1';
        Text006: Label 'Total %1 IVA+RE excl.';

        TextoLopd: Text;
        TextoPie: Text;
        Text004: Label 'Contrato nº %1', Comment = '%1 = Document No.';
        PageCaptionCap: Label 'Pág %1 of %2';
        GLSetup: Record "General Ledger Setup";
        ShipmentMethod: Record 10;
        PaymentTerms: Record 3;
        SalesPurchPerson: Record 13;
        CompanyInfo: Record 79;
        CompanyInfo1: Record 79;
        CompanyInfo2: Record 79;
        CompanyInfo3: Record 79;
        SalesSetup: Record 311;
        SalesShipmentBuffer: Record 7190 temporary;
        Cust: Record Customer;
        VATAmountLine: Record 290 temporary;
        DimSetEntry1: Record 480;
        DimSetEntry2: Record 480;
        RespCenter: Record 5714;
        GlobalLanguage: Codeunit Language;
        CurrExchRate: Record "Currency Exchange Rate";
        TempPostedAsmLine: Record 911 temporary;
        VATClause: Record 560;
        TempLineFeeNoteOnReportHist: Record 1053 temporary;
        FormatAddr: Codeunit 365;
        FormatDocument: Codeunit 368;
        SegManagement: Codeunit 5051;
        PostedShipmentDate: Date;
        CustAddr: array[8] of Text[100];
        ShipToAddr: array[8] of Text[100];
        CompanyAddr: array[8] of Text[100];
        OrderNoText: Text[80];
        SalesPersonText: Text[30];
        VATNoText: Text[80];
        ReferenceText: Text[80];
        TotalText: Text[50];
        TotalExclVATText: Text[50];
        TotalInclVATText: Text[50];
        MoreLines: Boolean;
        NoOfCopies: Integer;
        NoOfLoops: Integer;
        CopyText: Text[30];
        ShowShippingAddr: Boolean;
        NextEntryNo: Integer;
        FirstValueEntryNo: Integer;
        DimText: Text[120];
        OldDimText: Text[75];
        ShowInternalInfo: Boolean;
        Continuar: Boolean;
        LogInteraction: Boolean;
        VALVATBaseLCY: Decimal;
        VALVATAmountLCY: Decimal;
        VALSpecLCYHeader: Text[80];
        Text007: Label 'Especificación iva ';
        Text008: Label 'Moneda local';
        VALExchRate: Text[50];
        Text009: Label 'Exchange rate: %1/%2';
        CalculatedExchRate: Decimal;
        Text010: Label 'Factura Prepago %1';
        OutputNo: Integer;
        TotalSubTotal: Decimal;
        TotalAmount: Decimal;
        TotalAmountInclVAT: Decimal;
        TotalAmountVAT: Decimal;
        TotalInvoiceDiscountAmount: Decimal;
        TotalPaymentDiscountOnVAT: Decimal;
        VATPostingSetup: Record 325;
        PaymentMethod: Record 289 temporary;
        TotalGivenAmount: Decimal;

        LogInteractionEnable: Boolean;
        DisplayAssemblyInformation: Boolean;
        PhoneNoCaptionLbl: Label 'Teléfono';
        VATRegNoCaptionLbl: Label 'C.I.F:';
        GiroNoCaptionLbl: Label 'Giro No.';
        BankNameCaptionLbl: Label 'Banco';
        BankAccNoCaptionLbl: Label 'Cuenta';
        DueDateCaptionLbl: Label 'Fec. Vto.';
        InvoiceNoCaptionLbl: Label 'Nº Contrato';
        PostingDateCaptionLbl: Label 'Fecha Registro';
        HdrDimsCaptionLbl: Label 'Dimensiones';
        PmtinvfromdebtpaidtoFactCompCaptionLbl: Label 'The payment of this invoice, in order to be released from the debt, has to be paid to the Factoring Company.';
        UnitPriceCaptionLbl: Label 'Precio unitario';
        DiscountCaptionLbl: Label '% descuento';
        AmtCaptionLbl: Label 'Importe';
        VATClausesCap: Label 'Iva';
        PostedShpDateCaptionLbl: Label 'Fecha envío';
        InvDiscAmtCaptionLbl: Label 'Descuento factura';
        SubtotalCaptionLbl: Label 'Subtotal';
        PmtDiscGivenAmtCaptionLbl: Label 'Descuento pronto pago';
        PmtDiscVATCaptionLbl: Label 'Payment Discount on VAT';
        ShpCaptionLbl: Label 'Envío';
        LineDimsCaptionLbl: Label 'Descuentos línea';
        VATAmtLineVATCaptionLbl: Label '% Iva';
        VATECBaseCaptionLbl: Label 'Base Iva';
        VATAmountCaptionLbl: Label 'Importe Iva';
        VATAmtSpecCaptionLbl: Label 'Epecificación importe iva';
        VATIdentCaptionLbl: Label 'Identificador IVA';
        InvDiscBaseAmtCaptionLbl: Label 'Base descuento factura';
        LineAmtCaption1Lbl: Label 'Importe Línea';
        InvPmtDiscCaptionLbl: Label 'Descuentos factura';
        ECAmtCaptionLbl: Label 'Importe Rec.';
        ECCaptionLbl: Label '% Rec.';
        TotalCaptionLbl: Label 'Total';
        VALVATBaseLCYCaption1Lbl: Label 'Base IVA';
        VATAmtCaptionLbl: Label 'Importe IVA';
        VATIdentifierCaptionLbl: Label 'Identificador IVA';
        ShiptoAddressCaptionLbl: Label 'Dirección envío';
        PmtTermsDescCaptionLbl: Label 'Términos pago';
        ShpMethodDescCaptionLbl: Label 'Método envío';
        PmtMethodDescCaptionLbl: Label 'Forma de pago';
        DocDateCaptionLbl: Label 'Fecha documento';
        HomePageCaptionLbl: Label 'Home Page';
        EmailCaptionLbl: Label 'Email';
        CACCaptionLbl: Text;
        "Description Contrato": Text;
        CACTxt: Label 'Régimen especial del criterio de caja';
        DisplayAdditionalFeeNote: Boolean;
        LineNoWithTotal: Integer;
        "Datos Registro": Text;
        rProy: Record 167;
        rLinV: Record 113;
        rRecurs: Record 156;
        TipoCambioDivisa: Record "Currency Exchange Rate";
        rTarea: Record 1001;
        SalesInvCountPrinted: Codeunit 315;
        rContrato: Record 36;
        wFecReg: Date;
        TextoCopia: Text[30];
        HayDto: Text[10];
        HayDto1: Text;
        HayDto2: Text;
        HayDtoTAr: Text;
        PrecioTAr: Text;

        wTexto: Text[30];
        i: Integer;
        VALECAmountLCY: Decimal;
        wDescTarea: Text[150];
        wDescTareaAnt: Text[150];
        Text1100000: Label 'Total %1 IVA+RE incl.';
        Text1100001: Label 'Total %1 IVA+RE excl.';
        wTotPrepago: Decimal;
        wPorPrepago: Decimal;
        wBaseIvaPrep: Decimal;
        wImpIVaPrep: Decimal;
        wTotTarea: Decimal;
        wTotTareaPie: Decimal;
        Logotipo: Boolean;
        auxDivisa: Code[10];
        auxDA: Code[10];
        Text102: Label 'Total %1';
        Text106: Label 'Base Imponible %1';
        wNo: Code[20];
        wTarea: Code[20];
        wTotal: Boolean;
        FecEmis: Boolean;
        AgrRec: Boolean;
        TotTarea: Boolean;
        wPriVez: Boolean;
        wPriVez2: Boolean;
        CabeceraG: Boolean;
        wNoTotal: Boolean;
        TextAmpl: Boolean;
        PTexto: Record "Texto Presupuesto";
        wTotal2: Option "Imprimir Total Sin IVA","Imprimir IVA y Total";
        Empresa: Text[30];
        Numero: Code[20];
        numreg: Text[250];
        TextImpr: Boolean;
        wCtaBancoIban: Text[250];
        ShipAd: Boolean;
        EC: Text[30];
        ECp: Text[30];
        aVtos: ARRAY[29] OF Date;
        aImportes: ARRAY[29] OF Decimal;
        IClausulbuses: Boolean;
        IClausulInter: Boolean;


    /// <summary>
    /// InitLogInteraction.
    /// </summary>
    procedure InitLogInteraction()
    var
        "Interaction Log Entry Document Type": Enum "Interaction Log Entry Document Type";
    begin
        LogInteraction := SegManagement.FindInteractionTemplateCode("Interaction Log Entry Document Type"::"Sales Inv.") <> '';
        //LogInteraction := SegManagement.FindInteractTmplCode(4) <> '';
    end;

    local procedure FindPostedShipmentDate(): Date
    var
        SalesShipmentHeader: Record 110;
        SalesShipmentBuffer2: Record 7190 temporary;
    begin
        NextEntryNo := 1;
        // if "Job Plannig Line"."Shipment No." <> '' THEN
        //     if SalesShipmentHeader.GET("Job Plannig Line"."Shipment No.") THEN
        //         EXIT(SalesShipmentHeader."Posting Date");

        // if Job."No." = '' THEN
        //     EXIT(Job."Posting Date");

        // CASE "Job Plannig Line".Type OF
        //     "Job Plannig Line".Type::Item:
        //         GenerateBufferFromValueEntry("Job Plannig Line");
        //     "Job Plannig Line".Type::"G/L Account", "Job Plannig Line".Type::Resource,
        //   "Job Plannig Line".Type::"Charge (Item)", "Job Plannig Line".Type::"Fixed Asset":
        //         GenerateBufferFromShipment("Job Plannig Line");
        //     "Job Plannig Line".Type::" ":
        //         EXIT(0D);
        // END;

        // SalesShipmentBuffer.RESET;
        // SalesShipmentBuffer.SETRANGE("Document No.", "Job Plannig Line"."Document No.");
        // SalesShipmentBuffer.SETRANGE("Line No.", "Job Plannig Line"."Line No.");
        // if SalesShipmentBuffer.FIND('-') THEN BEGIN
        //     SalesShipmentBuffer2 := SalesShipmentBuffer;
        //     if SalesShipmentBuffer.NEXT = 0 THEN BEGIN
        //         SalesShipmentBuffer.GET(
        //           SalesShipmentBuffer2."Document No.", SalesShipmentBuffer2."Line No.", SalesShipmentBuffer2."Entry No.");
        //         SalesShipmentBuffer.DELETE;
        //         EXIT(SalesShipmentBuffer2."Posting Date");
        //     END;
        //     SalesShipmentBuffer.CALCSUMS(Quantity);
        //     if SalesShipmentBuffer.Quantity <> "Job Plannig Line".Quantity THEN BEGIN
        //         SalesShipmentBuffer.DELETEALL;
        //         EXIT(Job."Posting Date");
        //     END;
        // END ELSE
        //     EXIT(Job."Posting Date");
    end;


    local procedure CorrectShipment(var SalesShipmentLine: Record 111)
    var
        SalesInvoiceLine: Record 113;
    begin
        SalesInvoiceLine.SETCURRENTKEY("Shipment No.", "Shipment Line No.");
        SalesInvoiceLine.SETRANGE("Shipment No.", SalesShipmentLine."Document No.");
        SalesInvoiceLine.SETRANGE("Shipment Line No.", SalesShipmentLine."Line No.");
        if SalesInvoiceLine.FIND('-') THEN
            REPEAT
                SalesShipmentLine.Quantity := SalesShipmentLine.Quantity - SalesInvoiceLine.Quantity;
            UNTIL SalesInvoiceLine.NEXT = 0;
    end;

    local procedure DocumentCaption(): Text[250]
    begin
        //if Job."No." THEN
        //  EXIT(Text010);
        EXIT(Text004);
    end;


    /// <summary>
    /// GetCarteraInvoice.
    /// </summary>
    /// <returns>Return value of type Boolean.</returns>
    procedure GetCarteraInvoice(): Boolean
    var
        CustLedgEntry: Record 21;
    begin
        // // WITH CustLedgEntry. DO BEGIN
        // CustLedgEntry.SETCURRENTKEY("Document No.", "Document Type", "Customer No.");
        // CustLedgEntry.SETRANGE("Document Type", CustLedgEntry."Document Type"::Invoice);
        // CustLedgEntry.SETRANGE("Document No.", Job."No.");
        // CustLedgEntry.SETRANGE("Customer No.", Job."Bill-to Customer No.");
        // CustLedgEntry.SETRANGE("Posting Date", Job."Posting Date");
        // if CustLedgEntry.FINDFIRST THEN
        //     if CustLedgEntry."Document Situation" = CustLedgEntry."Document Situation"::" " THEN
        //         EXIT(FALSE)
        //     ELSE
        //         EXIT(TRUE)
        // ELSE
        //     EXIT(FALSE);
        // // END;
    end;


    /// <summary>
    /// ShowCashAccountingCriteria.
    /// </summary>
    /// <param name="SalesInvoiceHeader">Record 112.</param>
    /// <returns>Return value of type Text.</returns>
    procedure ShowCashAccountingCriteria(SalesInvoiceHeader: Record 112): Text
    var
        VATEntry: Record 254;
    begin
        GLSetup.GET;
        if NOT GLSetup."Unrealized VAT" THEN
            EXIT;
        CACCaptionLbl := '';
        VATEntry.SETRANGE("Document No.", SalesInvoiceHeader."No.");
        VATEntry.SETRANGE("Document Type", VATEntry."Document Type"::Invoice);
        if VATEntry.FINDSET THEN
            REPEAT
                if VATEntry."VAT Cash Regime" THEN
                    CACCaptionLbl := CACTxt;
            UNTIL (VATEntry.NEXT = 0) OR (CACCaptionLbl <> '');
        EXIT(CACCaptionLbl);
    end;


    /// <summary>
    /// InitializeRequest.
    /// </summary>
    /// <param name="NewNoOfCopies">Integer.</param>
    /// <param name="NewShowInternalInfo">Boolean.</param>
    /// <param name="NewLogInteraction">Boolean.</param>
    /// <param name="DisplayAsmInfo">Boolean.</param>
    procedure InitializeRequest(NewNoOfCopies: Integer; NewShowInternalInfo: Boolean; NewLogInteraction: Boolean; DisplayAsmInfo: Boolean)
    begin
        NoOfCopies := NewNoOfCopies;
        ShowInternalInfo := NewShowInternalInfo;
        LogInteraction := NewLogInteraction;
        DisplayAssemblyInformation := DisplayAsmInfo;
    end;

    local procedure FormatDocumentFields(SalesInvoiceHeader: Record Job)
    begin
        // WITH SalesInvoiceHeader. DO BEGIN
        FormatDocument.SetTotalLabels(SalesInvoiceHeader."Currency Code", TotalText, TotalInclVATText, TotalExclVATText);
        FormatDocument.SetSalesPerson(SalesPurchPerson, SalesInvoiceHeader."Cód. vendedor", SalesPersonText);
        FormatDocument.SetPaymentTerms(PaymentTerms, '', SalesInvoiceHeader."Language Code");
        FormatDocument.SetShipmentMethod(ShipmentMethod, '', SalesInvoiceHeader."Language Code");
        //PaymentMethod.INIT;
        if wTotal2 = wTotal2::"Imprimir Total Sin IVA" Then TotalInclVATText := '';
        //OrderNoText := FormatDocument.SetText(SalesInvoiceHeader."Order No." <> '', SalesInvoiceHeader.FIELDCAPTION("Order No."));
        ReferenceText := '';//FormatDocument.SetText(SalesInvoiceHeader."Your Reference" <> '', SalesInvoiceHeader.FIELDCAPTION("Your Reference"));
        VATNoText := FormatDocument.SetText(Customer."VAT Registration No." <> '', 'C.I.F');
        // END;
    end;

    local procedure FormatAddressFields(SalesInvoiceHeader: Record Job)
    begin
        FormatAddr.GetCompanyAddr('', RespCenter, CompanyInfo, CompanyAddr);
        FormatAddr.Customer(CustAddr, Customer);
        ShowShippingAddr := false;//FormatAddr.SalesHeaderShipTo(ShipToAddr, CustAddr, SalesInvoiceHeader);
    end;


    local procedure GetUOMText(UOMCode: Code[10]): Text[10]
    var
        UnitOfMeasure: Record 204;
    begin
        if NOT UnitOfMeasure.GET(UOMCode) THEN
            EXIT(UOMCode);
        EXIT(UnitOfMeasure.Description);
    end;


    /// <summary>
    /// BlanksForIndent.
    /// </summary>
    /// <returns>Return value of type Text[10].</returns>
    procedure BlanksForIndent(): Text[10]
    begin
        EXIT(PADSTR('', 2, ' '));
    end;


    PROCEDURE Importe(Preu: Decimal): Decimal;
    BEGIN
        if wTotal THEN EXIT(0);
        EXIT(Preu);
    END;

    PROCEDURE FiltroTexto2(r113: Record 1003; VAR rTexto: Record "Texto Presupuesto");
    BEGIN
        if (r113.Type = r113.Type::Resource) THEN
            rTexto.SETRANGE("Nº", r113."No.");
        rTexto.SETRANGE("Nº proyecto", r113."Job No.");
        rTexto.SETRANGE("Cód. tarea", r113."Job Task No.");
        rTexto.SETRANGE("Nº linea aux", r113."Line No.");
        rTexto.SETRANGE("Cód. variante", r113."Variant Code");
        rTexto.SETFILTER(rTexto."Tipo linea", '%1|%2',
                         rTexto."Tipo linea"::Venta, rTexto."Tipo linea"::Ambos);
    END;

    PROCEDURE Cantidad(Preu: Decimal): Decimal;
    BEGIN
        if wTotal THEN EXIT(0);
        EXIT(Preu);
    END;

    /// <summary>
    /// GetCurrencyCode.
    /// </summary>
    /// <returns>Return value of type Text.</returns>
    procedure GetCurrencyCode(): Text
    begin

        exit(Job."Currency Code");
    end;

    /// <summary>
    /// Vat.
    /// </summary>
    /// <param name="Cli">Code[20].</param>
    /// <returns>Return value of type Text.</returns>
    procedure Vat(Cli: Code[20]): Text
    var
        Cust: Record Customer;
    begin
        if Cust.Get(Cli) Then Exit(Cust."VAT Registration No.");
    end;

    local procedure TextoDuracion(TipoDuracion: Enum Duracion; Duracion: Decimal; Cs: Decimal): Text
    begin
        cs := CandidadSoportes(cs);
        Case TipoDuracion of
            TipoDuracion::" ":
                exit('');
            TipoDuracion::Catorzenas:
                begin
                    exit(Format(Duracion, 0, '<Precision,0:2><Standard Format,0>') + ' cat.');
                end;
            TipoDuracion::Días:
                begin
                    exit(Format(Duracion, 0, '<Precision,0:2><Standard Format,0>') + ' dias');
                end;
            TipoDuracion::Semanas:
                begin
                    exit(Format(Duracion, 0, '<Precision,0:2><Standard Format,0>') + ' sem.');
                end;

            TipoDuracion::Meses:
                exit(Format(Duracion, 0, '<Precision,0:2><Standard Format,0>') + ' mes.');


            TipoDuracion::Quincenas:
                exit(Format(Duracion, 0, '<Precision,0:2><Standard Format,0>') + ' qui.');



        End;
    end;

    procedure Descuento(Dto: Decimal): Text;
    begin
        if Dto = 0 then exit('');
        exit(Format(Dto, 0, '<Precision,0:2><Standard Format,0>') + '%');
    end;

    procedure CandidadSoportes(CS: decimal): Decimal;
    begin
        If cs = 0 Then Exit(1);
        exit(Cs);
    end;

}


