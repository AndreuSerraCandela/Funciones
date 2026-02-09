/// <summary>
/// Report Contrato (ID 50016).
/// </summary>
report 50016 "Contrato"
{
    DefaultLayout = RDLC;
    RDLCLayout = './src/report/layout/Contrato.rdlc';
    Caption = 'Contrato de Venta';
    PreviewMode = PrintLayout;
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;

    dataset
    {
        dataitem("Sales Invoice Header"; 36)
        {
            DataItemTableView = SORTING("No.");
            RequestFilterFields = "No.", "Sell-to Customer No.", "No. Printed";
            RequestFilterHeading = 'Contrato de venta';
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
            column(HayDto; HayDto) { }
            column(HayDto1; HayDto1) { }
            column(HayDto2; HayDto2) { }
            column(HayDtoTar; HayDtoTar) { }
            column(PrecioTar; PrecioTar) { }
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
            column(wTxtRenovado; wTxtRenovado)
            { }
            column(wContOrigen; wContOrigen)
            { }
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
                    column(CustAddr1; "Sales Invoice Header"."Sell-to Customer Name")
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
                    column(CompanyInfoHomePage; FORMAT("Sales Invoice Header"."Due Date", 0, '<Day,2>/<Month,2>/<Year>'))
                    {
                    }
                    column(TextoPieFactura; TextoPie)
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
                    column(BilltoCustNo_SalesInvHdr; "Sales Invoice Header"."Bill-to Customer No.")
                    {
                    }
                    column(PostingDate_SalesInvHdr; FORMAT("Sales Invoice Header"."Order Date", 0, 4))
                    {
                    }
                    column(VATNoText; VATNoText)
                    {
                    }
                    column(VATRegNo_SalesInvHeader; "Sales Invoice Header"."VAT Registration No.")
                    {
                    }
                    column(DueDate_SalesInvHeader; FORMAT("Sales Invoice Header"."Due Date", 0, 4))
                    {
                    }
                    column(SalesPersonText; SalesPersonText)
                    {
                    }
                    column(SalesPurchPersonName; SalesPurchPerson.Code)
                    {
                    }
                    column(No_SalesInvoiceHeader1; "Sales Invoice Header"."No.")
                    {
                    }
                    column(ReferenceText; ReferenceText)
                    {
                    }
                    column(YourReference_SalesInvHdr; "Sales Invoice Header"."Your Reference")
                    {
                    }
                    column(OrderNoText; OrderNoText)
                    {
                    }
                    column(OrderNo_SalesInvHeader; "Sales Invoice Header"."No.")
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
                    column(DocDate_SalesInvoiceHdr; FORMAT("Sales Invoice Header"."Document Date", 0, 4))
                    {
                    }
                    column(PricesInclVAT_SalesInvHdr; "Sales Invoice Header"."Prices Including VAT")
                    {
                    }
                    column(OutputNo; OutputNo)
                    {
                    }
                    column(PricesInclVATYesNo; FORMAT("Sales Invoice Header"."Prices Including VAT"))
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
                    column(BilltoCustNo_SalesInvHdrCaption; "Sales Invoice Header".FIELDCAPTION("Bill-to Customer No."))
                    {
                    }
                    column(PricesInclVAT_SalesInvHdrCaption; "Sales Invoice Header".FIELDCAPTION("Prices Including VAT"))
                    {
                    }

                    column(CACCaption; CACCaptionLbl)
                    {
                    }
                    column(PeriodoDeFactura; "Sales Invoice Header"."Posting Description")
                    { }
                    column(Fecha_Inicial_Contrato; "Sales Invoice Header"."Fecha inicial proyecto")
                    {

                    }
                    Column(Fecha_final_proyecto; "Sales Invoice Header"."Fecha fin proyecto")
                    { }
                    column(ComentarioCabecera; "Sales Invoice Header"."Comentario Cabecera") { }
                    Column(DescripCion_Contrato; "Description Contrato") { }

                    column(TextImpr; TextImpr) { }
                    column(numreg; numreg) { }
                    column(TextoLopd; TextoLopd) { }
                    Column(PayMent_Identificador; "Number") { }
                    Column(PaymentMethod_Description; PaymentMethod.Description) { }
                    Column(Forma_de_Pago_Caption; 'Forma de Pago:') { }
                    Column(Fecha_vencimiento_Caption; 'Fecha vencimiento:') { }
                    Column(Sales_Invoice_Header___Due_Date_; "Sales Invoice Header"."Due Date") { }
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
                    column(EntregaAcuentaCap; CapEntregaALaFirma)
                    { }
                    column(ImporteAlaFirma; PrepmtImporte)
                    { }
                    column(TexToPrepagoCap; TextoPrepago)
                    { }
                    column(PrimerVtoCap; CapEntregaA1)
                    { }
                    column(ImportePrimerVto; PrepmtImporte1)
                    { }
                    column(TexToPrepago1Cap; TextoPrepago1)
                    { }
                    column(ClausulaBuses; CBuses)
                    { }
                    column(ClausulaIntercambio; CItercambio)
                    { }
                    Column(wCtaBancoSwift; wCtaBancoSwift) { }
                    dataitem(DimensionLoop1; Integer)
                    {
                        DataItemLinkReference = "Sales Invoice Header";
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
                    // dataitem("Líneas Impresion"; 44)
                    // {
                    //     DataItemTableView = SORTING("Document Type", "No.", "Document Line No.", "Line No.")
                    //       WHERE("Document Type" = CONST("Detalle Factura"),
                    //             Validada = CONST(true));
                    //     DataItemLinkReference = "Sales Invoice Header";
                    //     DataItemLink = "No." = FIELD("No.");
                    //     column(Lineas_Impresion_LineNo; "Line No.") { }
                    //     Column(Lineas_Impresion_Code; Code) { }
                    //     Column(Lineas_Impresion_Comment; Comment) { }
                    //     Column(Lineas_Impresion_Precio; Precio) { }
                    //     Column(Cantidad_Precio; Cantidad * Precio) { }
                    //     Column(Lineas_Impresion_Cantidad; Cantidad) { }
                    //     trigger OnAfterGetRecord()
                    //     BEGIN
                    //         Importe := Importe - Iva;
                    //     END;

                    // }
                    dataitem("Sales Invoice Line"; 37)
                    {
                        DataItemLink = "Document Type" = FIELD("Document Type"), "Document No." = FIELD("No.");
                        DataItemLinkReference = "Sales Invoice Header";
                        DataItemTableView = SORTING("Document No.", "Line No.") where(Imprimir = const(True));
                        UseTemporary = true;
                        column(GetCarteraInvoice; GetCarteraInvoice)
                        {
                        }

                        column(LineAmt_SalesInvoiceLine; "Line Amount")
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
                        column(UOM_SalesInvoiceLine; "Unit of Measure")
                        {
                        }
                        column(UnitPrice_SalesInvLine; "Unit Price")
                        {
                            AutoFormatExpression = GetCurrencyCode;
                            AutoFormatType = 2;
                        }
                        column(LineDisc_SalesInvoiceLine; "Line Discount %")
                        {
                        }
                        column(VATIdent_SalesInvLine; "VAT Identifier")
                        {
                        }
                        column(PostedShipmentDate; FORMAT(PostedShipmentDate))
                        {
                        }
                        column(Type_SalesInvoiceLine; FORMAT(Type))
                        {
                        }
                        column(InvDiscountAmount; -"Inv. Discount Amount")
                        {
                            AutoFormatExpression = GetCurrencyCode;
                            AutoFormatType = 1;
                        }
                        column(TotalSubTotal; TotalSubTotal)
                        {
                            AutoFormatExpression = "Sales Invoice Header"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(TotalInvoiceDiscountAmount; TotalInvoiceDiscountAmount)
                        {
                            AutoFormatExpression = "Sales Invoice Header"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(TotalAmount; TotalAmount)
                        {
                            AutoFormatExpression = "Sales Invoice Header"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(TotalGivenAmount; TotalGivenAmount)
                        {
                            AutoFormatExpression = "Sales Invoice Header"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(SalesInvoiceLineAmount; Amount)
                        {
                            AutoFormatExpression = GetCurrencyCode;
                            AutoFormatType = 1;
                        }
                        column(AmountIncludingVATAmount; "Amount Including VAT" - Amount)
                        {
                            AutoFormatExpression = GetCurrencyCode;
                            AutoFormatType = 1;
                        }
                        column(Amount_SalesInvoiceLineIncludingVAT; "Amount Including VAT")
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
                            AutoFormatExpression = "Sales Invoice Header"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(TotalAmountVAT; TotalAmountVAT)
                        {
                            AutoFormatExpression = "Sales Invoice Header"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(VATBaseDisc_SalesInvHdr; "Sales Invoice Header"."VAT Base Discount %")
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
                        column(UOM_SalesInvoiceLineCaption; FIELDCAPTION("Unit of Measure"))
                        {
                        }
                        column(VATIdent_SalesInvLineCaption; FIELDCAPTION("VAT Identifier"))
                        {
                        }
                        column(IsLineWithTotals; LineNoWithTotal = "Line No.")
                        {
                        }
                        column(IsDicount; AlgunDto()) { }
                        column(Remarcar; Remarcar) { }
                        column(Fecha_Inicial; "Fecha inicial recurso")
                        {

                        }
                        Column(Fecha_final; "Fecha final recurso")
                        { }
                        column("Precio_Tarifa"; PrecioTarifa("Precio Tarifa", "Unit Price", "Dto. Tarifa"))
                        { }
                        column("Dto_Tarifa"; Descuento("Dto. Tarifa"))
                        { }
                        column("Dto_Venta_1"; Descuento("% Dto. Venta 1"))
                        { }
                        column("Dto_Venta_2"; Descuento("% Dto. Venta 2"))
                        { }
                        column("Duracion"; TextoDuracion("Tipo Duracion", Duracion, "Cdad. Soportes", Quantity, "Sales Invoice Header"."Posting Date"))
                        { }
                        column("Tipo_Duracion"; "Tipo Duracion")
                        { }
                        column(Cdad__Soportes; CandidadSoportes("Cdad. Soportes", Quantity, "Sales Invoice Header"."Posting Date"))
                        { }


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
                                if Number = 1 THEN
                                    SalesShipmentBuffer.FIND('-')
                                ELSE
                                    SalesShipmentBuffer.NEXT;
                            end;

                            trigger OnPreDataItem()
                            begin
                                //SalesShipmentBuffer.SETRANGE()
                                SalesShipmentBuffer.SETRANGE("Document No.", "Sales Invoice Line"."Document No.");
                                SalesShipmentBuffer.SETRANGE("Line No.", "Sales Invoice Line"."Line No.");

                                SETRANGE(Number, 1, SalesShipmentBuffer.COUNT);
                            end;
                        }


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

                                DimSetEntry2.SETRANGE("Dimension Set ID", "Sales Invoice Line"."Dimension Set ID");
                            end;
                        }
                        dataitem(AsmLoop; Integer)
                        {
                            DataItemTableView = SORTING(Number);
                            column(TempPostedAsmLineUOMCode; GetUOMText(TempPostedAsmLine."Unit of Measure Code"))
                            {
                                // DecimalPlaces = 0 : 5;
                            }
                            column(TempPostedAsmLineQuantity; TempPostedAsmLine.Quantity)
                            {
                                DecimalPlaces = 0 : 5;
                            }
                            column(TempPostedAsmLineVariantCode; BlanksForIndent + TempPostedAsmLine."Variant Code")
                            {
                                // DecimalPlaces = 0 : 5;
                            }
                            column(TempPostedAsmLineDescrip; BlanksForIndent + TempPostedAsmLine.Description)
                            {
                            }
                            column(TempPostedAsmLineNo; BlanksForIndent + TempPostedAsmLine."No.")
                            {
                            }

                            trigger OnAfterGetRecord()
                            var
                                ItemTranslation: Record 30;
                            begin
                                if Number = 1 THEN
                                    TempPostedAsmLine.FINDSET
                                ELSE
                                    TempPostedAsmLine.NEXT;

                                if ItemTranslation.GET(TempPostedAsmLine."No.",
                                     TempPostedAsmLine."Variant Code",
                                     "Sales Invoice Header"."Language Code")
                                THEN
                                    TempPostedAsmLine.Description := ItemTranslation.Description;
                            end;

                            trigger OnPreDataItem()
                            begin
                                CLEAR(TempPostedAsmLine);
                                if NOT DisplayAssemblyInformation THEN
                                    CurrReport.BREAK;
                                CollectAsmInformation;
                                CLEAR(TempPostedAsmLine);
                                SETRANGE(Number, 1, TempPostedAsmLine.COUNT);
                            end;
                        }

                        trigger OnAfterGetRecord()
                        var
                            TipoRecurso: Record "Tipo Recurso";
                        begin
                            PostedShipmentDate := 0D;
                            if Quantity <> 0 THEN
                                PostedShipmentDate := FindPostedShipmentDate;

                            if (Type = Type::"G/L Account") AND (NOT ShowInternalInfo) THEN
                                "No." := '';


                            CLEAR(CabeceraG);
                            if (wTarea <> "Sales Invoice Line"."Job Task No.") THEN BEGIN
                                wDescTareaAnt := wDescTarea;
                                wTarea := "Sales Invoice Line"."Job Task No.";
                                if rTarea.GET("Sales Invoice Line"."Job No.", "Sales Invoice Line"."Job Task No.") THEN
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
                            wTotTarea := wTotTarea + "Sales Invoice Line"."Line Amount";
                            if TextAmpl THEN BEGIN
                                FiltroTexto2("Sales Invoice Line", PTexto);
                            END;
                            "Unit of Measure" := '';
                            if Type = Type::Resource then begin
                                if rRecurs.Get("No.") Then begin
                                    If Not TipoRecurso.Get(rRecurs."Tipo Recurso") Then
                                        TipoRecurso.Init();
                                    If (TipoRecurso."Tiene Medidas") and (rRecurs.Medidas <> '') Then begin
                                        If Not TipoRecurso."Ocultar Tipo Recurso" Then
                                            "Unit of Measure" := rRecurs."Tipo Recurso" + ' ' + rRecurs.Medidas
                                        else
                                            "Unit of Measure" := rRecurs.Medidas;
                                    end else
                                        If Not TipoRecurso."Ocultar Tipo Recurso" Then
                                            "Unit of Measure" := rRecurs."Tipo Recurso";
                                end;
                            end;
                            if wToTal2 = wToTal2::"Solo Totales" Then begin
                                "Unit Price" := 0;
                                "Line Amount" := 0;
                                Quantity := 0;
                            end
                        end;

                        trigger OnPreDataItem()
                        var
                            SalesLine: Record "Sales Line";
                            SalesILines: Record 44;
                            a: Integer;
                        begin
                            //     DataItemTableView = SORTING("Document Type", "No.", "Document Line No.", "Line No.")
                            //       WHERE("Document Type" = CONST("Detalle Factura"),
                            //             Validada = CONST(true));
                            //     DataItemLinkReference = "Sales Invoice Header";
                            //     DataItemLink = "No." = FIELD("No.");

                            // $013
                            if not TextImpr Then begin
                                "Sales Invoice Line".DeleteAll();
                                SalesLine.SetRange("Document No.", "Sales Invoice Header"."No.");
                                SalesLine.SetRange("Document Type", "Sales Invoice Header"."Document Type");
                                if SalesLine.FindFirst() then
                                    repeat
                                        "Sales Invoice Line" := SalesLine;
                                        if "Sales Invoice Line".Insert() Then;
                                        if VATPostingSetup.GET("Sales Invoice Line"."VAT Bus. Posting Group", "Sales Invoice Line"."VAT Prod. Posting Group") THEN BEGIN
                                            VATAmountLine.INIT;
                                            VATAmountLine."VAT Identifier" := "VAT Identifier";
                                            VATAmountLine."VAT Calculation Type" := "VAT Calculation Type";
                                            VATAmountLine."Tax Group Code" := "Tax Group Code";
                                            VATAmountLine."VAT %" := VATPostingSetup."VAT %";
                                            VATAmountLine."EC %" := VATPostingSetup."EC %";
                                            VATAmountLine."VAT Base" := "Sales Invoice Line".Amount;
                                            VATAmountLine."Amount Including VAT" := "Sales Invoice Line"."Amount Including VAT";
                                            VATAmountLine."Line Amount" := "Line Amount";
                                            VATAmountLine."Pmt. Discount Amount" := "Pmt. Discount Amount";
                                            if "Allow Invoice Disc." THEN
                                                VATAmountLine."Inv. Disc. Base Amount" := "Line Amount";
                                            VATAmountLine."Invoice Discount Amount" := "Inv. Discount Amount";
                                            VATAmountLine.SetCurrencyCode("Sales Invoice Header"."Currency Code");
                                            VATAmountLine."VAT Difference" := "VAT Difference";
                                            VATAmountLine."EC Difference" := "EC Difference";
                                            if "Sales Invoice Header"."Prices Including VAT" THEN
                                                VATAmountLine."Prices Including VAT" := TRUE;
                                            VATAmountLine."VAT Clause Code" := "VAT Clause Code";
                                            // VATAmountLine.InsertLine;
                                            // MNC 020201
                                            VATAmountLine.SetCurrencyCode("Sales Invoice Header"."Currency Code");
                                            // Fi MNC

                                            //VATAmountLine.InsertLine;

                                            //$002(I)
                                            if VATAmountLine."VAT Amount" < 0 THEN BEGIN
                                                if wNo = '485000001' THEN BEGIN                                   //$012
                                                    wBaseIvaPrep := wBaseIvaPrep + VATAmountLine."VAT Base";
                                                    wImpIVaPrep := wImpIVaPrep + VATAmountLine."VAT Amount";
                                                END;                                                              //$012
                                            END;
                                            //$002(F)

                                            TotalSubTotal += "Line Amount";
                                            TotalInvoiceDiscountAmount -= "Inv. Discount Amount";
                                            TotalAmount += Amount;
                                            TotalAmountVAT += "Amount Including VAT" - Amount;
                                            TotalAmountInclVAT += "Amount Including VAT";
                                            TotalGivenAmount -= "Pmt. Discount Amount";
                                            TotalPaymentDiscountOnVAT += -("Line Amount" - "Inv. Discount Amount" - "Pmt. Discount Amount" - "Amount Including VAT");

                                        END;

                                    until SalesLine.Next() = 0;

                            end else begin
                                "Sales Invoice Line".DeleteAll();
                                SalesILines.SetCurrentKey("Document Type", "No.", "Document Line No.", "Line No.");
                                SalesILines.SetRange("Document Type", SalesILines."Document Type"::"Detalle Contrato");
                                SalesILines.SetRange(Validada, true);
                                SalesILines.SetRange("No.", "Sales Invoice Header"."No.");
                                if not SalesILines.FindFirst() Then Error('No existen lineas de impresión valoradas para este contrato');
                                if SalesILines.FindFirst() then
                                    repeat
                                        a += 10000;
                                        "Sales Invoice Line".Init;
                                        "Sales Invoice Line".Type := "Sales Invoice Line".Type::Resource;
                                        "Sales Invoice Line"."Document No." := "Sales Invoice Header"."No.";
                                        "Sales Invoice Line"."Line No." := a;
                                        "Sales Invoice Line"."No." := SalesILines."No.";
                                        "Sales Invoice Line".Description := SalesILines.Comment;
                                        "Sales Invoice Line".Quantity := SalesILines.Cantidad;
                                        "Sales Invoice Line"."Unit Price" := SalesILines.Precio;
                                        "Sales Invoice Line"."Line Amount" := SalesILines.Importe;
                                        "Sales Invoice Line".Amount := SalesILines.Importe;
                                        "Sales Invoice Line"."Amount Including VAT" := SalesILines.Importe + SalesILines.Iva;
                                        "Sales Invoice Line"."VAT %" := SalesILines."% Iva";
                                        if "Sales Invoice Line".Insert() Then;
                                        if VATPostingSetup.GET("Sales Invoice Line"."VAT Bus. Posting Group", "Sales Invoice Line"."VAT Prod. Posting Group") THEN BEGIN
                                            VATAmountLine.INIT;
                                            VATAmountLine."VAT Identifier" := "VAT Identifier";
                                            VATAmountLine."VAT Calculation Type" := "VAT Calculation Type";
                                            VATAmountLine."Tax Group Code" := "Tax Group Code";
                                            VATAmountLine."VAT %" := VATPostingSetup."VAT %";
                                            VATAmountLine."EC %" := VATPostingSetup."EC %";
                                            VATAmountLine."VAT Base" := "Sales Invoice Line".Amount;
                                            VATAmountLine."Amount Including VAT" := "Sales Invoice Line"."Amount Including VAT";
                                            VATAmountLine."Line Amount" := "Line Amount";
                                            VATAmountLine."Pmt. Discount Amount" := "Pmt. Discount Amount";
                                            if "Allow Invoice Disc." THEN
                                                VATAmountLine."Inv. Disc. Base Amount" := "Line Amount";
                                            VATAmountLine."Invoice Discount Amount" := "Inv. Discount Amount";
                                            VATAmountLine.SetCurrencyCode("Sales Invoice Header"."Currency Code");
                                            VATAmountLine."VAT Difference" := "VAT Difference";
                                            VATAmountLine."EC Difference" := "EC Difference";
                                            if "Sales Invoice Header"."Prices Including VAT" THEN
                                                VATAmountLine."Prices Including VAT" := TRUE;
                                            VATAmountLine."VAT Clause Code" := "VAT Clause Code";
                                            // VATAmountLine.InsertLine;
                                            // MNC 020201
                                            VATAmountLine.SetCurrencyCode("Sales Invoice Header"."Currency Code");
                                            // Fi MNC

                                            //VATAmountLine.InsertLine;

                                            //$002(I)
                                            if VATAmountLine."VAT Amount" < 0 THEN BEGIN
                                                if wNo = '485000001' THEN BEGIN                                   //$012
                                                    wBaseIvaPrep := wBaseIvaPrep + VATAmountLine."VAT Base";
                                                    wImpIVaPrep := wImpIVaPrep + VATAmountLine."VAT Amount";
                                                END;                                                              //$012
                                            END;
                                            //$002(F)

                                            TotalSubTotal += "Line Amount";
                                            TotalInvoiceDiscountAmount -= "Inv. Discount Amount";
                                            TotalAmount += Amount;
                                            TotalAmountVAT += "Amount Including VAT" - Amount;
                                            TotalAmountInclVAT += "Amount Including VAT";
                                            TotalGivenAmount -= "Pmt. Discount Amount";
                                            TotalPaymentDiscountOnVAT += -("Line Amount" - "Inv. Discount Amount" - "Pmt. Discount Amount" - "Amount Including VAT");

                                        END;

                                    until SalesILines.Next() = 0;
                            end;
                            VATAmountLine.DELETEALL;
                            SalesShipmentBuffer.RESET;
                            SalesShipmentBuffer.DELETEALL;
                            FirstValueEntryNo := 0;
                            MoreLines := FIND('+');
                            LineNoWithTotal := "Line No.";
                            WHILE MoreLines AND (Description = '') AND ("No." = '') AND (Quantity = 0) AND (Amount = 0) DO
                                MoreLines := NEXT(-1) <> 0;
                            if NOT MoreLines THEN
                                CurrReport.BREAK;
                            SETRANGE("Line No.", 0, "Line No.");
#pragma warning disable AL0667
                            CurrReport.CREATETOTALS("Line Amount", Amount, "Amount Including VAT", "Inv. Discount Amount", "Pmt. Discount Amount");
#pragma warning restore AL0667

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
                            AutoFormatExpression = "Sales Invoice Header"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(VATAmountLineLineAmount; VATAmountLine."Line Amount")
                        {
                            AutoFormatExpression = "Sales Invoice Header"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(VATAmtLineInvDiscBaseAmt; VATAmountLine."Inv. Disc. Base Amount")
                        {
                            AutoFormatExpression = "Sales Invoice Header"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(VATAmtLineInvDiscountAmt; VATAmountLine."Invoice Discount Amount" + VATAmountLine."Pmt. Discount Amount")
                        {
                            AutoFormatExpression = "Sales Invoice Header"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(VATAmtLineECAmount; VATAmountLine."EC Amount")
                        {
                            AutoFormatExpression = "Sales Invoice Header"."Currency Code";
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
                            AutoFormatExpression = "Sales Invoice Header"."Currency Code";
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
                            AutoFormatExpression = "Sales Invoice Header"."Currency Code";
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
                            VATClause.TranslateDescription("Sales Invoice Header"."Language Code");
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
                                "Sales Invoice Header"."Posting Date", "Sales Invoice Header"."Currency Code",
                                "Sales Invoice Header"."Currency Factor");
                            VALVATAmountLCY :=
                              VATAmountLine.GetAmountLCY(
                                "Sales Invoice Header"."Posting Date", "Sales Invoice Header"."Currency Code",
                                "Sales Invoice Header"."Currency Factor");
                        end;

                        trigger OnPreDataItem()
                        begin
                            if (NOT GLSetup."Print VAT specification in LCY") OR
                               ("Sales Invoice Header"."Currency Code" = '')
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

                            CurrExchRate.FindCurrency("Sales Invoice Header"."Posting Date", "Sales Invoice Header"."Currency Code", 1);
                            CalculatedExchRate := ROUND(1 / "Sales Invoice Header"."Currency Factor" * CurrExchRate."Exchange Rate Amount", 0.000001);
                            VALExchRate := STRSUBSTNO(Text009, CalculatedExchRate, CurrExchRate."Exchange Rate Amount");
                        end;
                    }
                    // TODO: - Revisar
#pragma warning disable AL0432
                    dataitem(PaymentReportingArgument; 1062)
#pragma warning restore AL0432
                    // TODO: - Revisar
                    {
                        DataItemTableView = SORTING(Key);
                        UseTemporary = true;
                        column(PaymentServiceLogo; Logo)
                        {
                        }
                        column(PaymentServiceURLText; "URL Caption")
                        {
                        }
                        column(PaymentServiceURL; GetTargetURL)
                        {
                        }

                        trigger OnPreDataItem()
                        var
                            PaymentServiceSetup: Record 1060;
                        begin
                            PaymentServiceSetup.CreateReportingArgs(PaymentReportingArgument, "Sales Invoice Header");
                            if ISEMPTY THEN
                                CurrReport.BREAK;
                        end;
                    }

                    dataItem("Sales Comment Line"; 44)
                    {
                        DataItemTableView = SORTING("Document Type", "No.", "Document Line No.", "Line No.")
                          WHERE("Document Type" = CONST("Posted Invoice"));
                        DataItemLinkReference = "Sales Invoice Header";
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
                        column(SelltoCustNo_SalesInvHdr; "Sales Invoice Header"."Sell-to Customer No.")
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
                        column(SelltoCustNo_SalesInvHdrCaption; "Sales Invoice Header".FIELDCAPTION("Sell-to Customer No."))
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
                var
                    RecRef: RecordRef;
                begin
                    if NOT CurrReport.PREVIEW THEN
                        CODEUNIT.RUN(CODEUNIT::"Sales-Printed", "Sales Invoice Header");
                    RecRef.GetTable("Sales Invoice Header");

                end;

                trigger OnPreDataItem()
                begin
#pragma warning disable AL0432 // TODO: - Eliminar Copias
                    NoOfLoops := ABS(NoOfCopies) + Cust."Invoice Copies" + 1;
#pragma warning restore AL0432 // TODO: - Eliminar Copias
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
                rProyecto: Record Job;
                j: Integer;
            begin
                // CurrReport.LANGUAGE := GlobalLanguage.GetLanguageID("Language Code");
                //ASC

                Prepago();
                CLEAR(rPropuestas);
                rPropuestas.RESET;
                CLEAR(aVtos);
                CLEAR(aImportes);
                rPropuestas.SETRANGE("No. Contrato", "Sales Invoice Header"."No.");
                rPropuestas.SETRANGE("Factura 1", FALSE);                      //$014
                j := 1;
                if Desglo Then begin
                    if rPropuestas.FINDSET THEN
                        REPEAT
                            aVtos[j] := rPropuestas."Fecha Vencimiento";
                            aImportes[j] := rPropuestas."Importe con IVA";
                            j += 1;
                        UNTIL (rPropuestas.NEXT = 0) OR (j = 29);
                end;
                HayDto := '';
                HayDto1 := '';
                HayDto2 := '';
                HayDtoTar := '';

                if rProyecto.GET("Sales invoice Header"."Nº Proyecto") THEN BEGIN
                    if rProyecto."Proyecto origen" <> '' THEN BEGIN
                        rContrato.RESET;
                        rContrato.SETCURRENTKEY("Nº Proyecto");
                        rContrato.SETRANGE("Nº Proyecto", rProyecto."Proyecto origen");
                        if rContrato.FINDFIRST THEN BEGIN
                            wContOrigen := rContrato."No.";
                            wTxtRenovado := 'Contrato renovado';
                        END;
                    END;
                END;
                rContrato.RESET;
                rLinV.SETCURRENTKEY("Document No.", "Line No.");
                rLinV.SETRANGE("Document No.", "Sales Invoice Header"."No.");
                rLinV.SETFILTER("Line Discount %", '<>%1', 0);
                if rLinV.FindFirst() THEN
                    HayDto := '%Dto';
                rLinV.SETRANGE("Document No.", "Sales Invoice Header"."No.");
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
                rCom.SETRANGE(rCom."Document Type", rCom."Document Type"::"Detalle Contrato");
                rCom.SETRANGE(rCom."No.", "No.");
                rCom.SETRANGE(Validada, TRUE);
                if rCom.FINDFIRST THEN
                    TextImpr := TRUE;

                Numero := "No.";
                if Empresa <> '' THEN
                    Numero := COPYSTR("No.", 2, 20);
                //Empresa := Eliminar;
                // if Empresa <> '' THEN BEGIN
                //     rContr.CHANGECOMPANY(Empresa);
                Coment.Setrange("Document Type", "Sales Invoice Header"."Document Type");
                Coment.Setrange("No.", "Sales Invoice Header"."No.");
                numreg := '';
                if Coment.FindFirst() Then
                    Repeat
                        numreg := numreg + ' ' + Coment.Comment;
                    until Coment.Next() = 0;
                // END;
                CASE wTotal2 OF
                    wTotal2::"Según Contrato":
                        if rContr.GET(rContr."Document Type"::Order, "Sales Invoice Header"."Nº Contrato") THEN
                            wTotal := rContr."Imprimir Solo Total";
                    wTotal2::"Solo Totales":
                        wTotal := TRUE;
                    wTotal2::Todo:
                        wTotal := FALSE;
                END;
                // CurrReport.LANGUAGE := GlobalLanguage.GetLanguageID("Language Code");

                if Empresa <> '' THEN
                    CompanyInfo.GET(Empresa)
                ELSE
                    CompanyInfo.GET;

                if RespCenter.GET("Responsibility Center") THEN BEGIN
                    FormatAddr.RespCenter(CompanyAddr, RespCenter);
                    CompanyInfo."Phone No." := RespCenter."Phone No.";
                    CompanyInfo."Fax No." := RespCenter."Fax No.";
                END ELSE BEGIN
                    FormatAddr.Company(CompanyAddr, CompanyInfo);
                END;

                //    PostedDocDim1.SETRANGE("Table ID",DATABASE::"Sales Invoice Header");
                //    PostedDocDim1.SETRANGE("Document No.","Sales Invoice Header"."No.");

                if Empresa <> '' THEN
                    SalesPurchPerson.CHANGECOMPANY(Empresa);
                // "Order No." := "Nº Contrato";
                // if "Order No." = '' THEN
                //     OrderNoText := ''
                // ELSE
                //     OrderNoText := FIELDCAPTION("Order No.");
                if "Salesperson Code" = '' THEN BEGIN
                    SalesPurchPerson.INIT;
                    SalesPersonText := '';
                END ELSE BEGIN
                    SalesPurchPerson.GET("Salesperson Code");
                    SalesPersonText := "Salesperson Code";
                END;
                if "Your Reference" = '' THEN
                    ReferenceText := ''
                ELSE
                    ReferenceText := FIELDCAPTION("Your Reference");
                if "Your Reference" = '' THEN begin
                    "Your Reference" := "Customer Order No.";
                    if "Your Reference" <> '' then
                        ReferenceText := FIELDCAPTION("Customer Order No.");
                end;
                if "VAT Registration No." = '' THEN
                    VATNoText := ''
                ELSE
                    VATNoText := FIELDCAPTION("VAT Registration No.");
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
                FormatAddr.SalesHeaderBillTo(CustAddr, "Sales Invoice Header");

                if Empresa <> '' THEN
                    Cust.CHANGECOMPANY(Empresa);

                if NOT Cust.GET("Bill-to Customer No.") THEN
                    CLEAR(Cust);

                // MNC 240300
                if CustAddr[1] = "Sales Invoice Header"."Sell-to Customer Name" Then CustAddr[1] := "Sales Invoice Header"."Sell-to Contact";
                if CustAddr[1] = CustAddr[2] then CustAddr[2] := '';
                CustAddr[8] := 'CIF/NIF: ' + Cust."VAT Registration No.";
                COMPRESSARRAY(CustAddr);
                // MNC 240300

                if Empresa <> '' THEN
                    PaymentTerms.CHANGECOMPANY(Empresa);

                if "Payment Terms Code" = '' THEN
                    PaymentTerms.INIT
                ELSE BEGIN
                    PaymentTerms.GET("Payment Terms Code");
                    PaymentTerms.TranslateDescription(PaymentTerms, "Language Code");
                END;

                if Empresa <> '' THEN
                    r289.CHANGECOMPANY(Empresa);

                if "Payment Method Code" = '' THEN
                    r289.INIT
                ELSE
                    r289.GET("Payment Method Code");

                PaymentMethod := r289;
                if PaymentMethod.INSERT THEN;
                if "Shipment Method Code" = '' THEN
                    ShipmentMethod.INIT
                ELSE BEGIN
                    ShipmentMethod.GET("Shipment Method Code");
                    ShipmentMethod.TranslateDescription(ShipmentMethod, "Language Code");
                END;
                //ASC 20/08/13
                rShip.SETRANGE(rShip."Customer No.", "Sales Invoice Header"."Sell-to Customer No.");
                if rShip.COUNT = 1 THEN BEGIN

                    rShip.FINDFIRST;
                    "Sales Invoice Header"."Ship-to Code" := rShip.Code;
                    "Sales Invoice Header"."Ship-to Name" := rShip.Name;
                    "Sales Invoice Header"."Ship-to Name 2" := rShip."Name 2";
                    "Sales Invoice Header"."Ship-to Address" := rShip.Address;
                    "Sales Invoice Header"."Ship-to Address 2" := rShip."Address 2";
                    "Sales Invoice Header"."Ship-to City" := rShip.City;
                    "Sales Invoice Header"."Ship-to Contact" := rShip.Contact;
                    "Sales Invoice Header"."Ship-to Post Code" := rShip."Post Code";
                    "Sales Invoice Header"."Ship-to County" := rShip.County;
                    "Sales Invoice Header"."Ship-to Country/Region Code" := rShip."Country/Region Code";

                END;
                //$009
                SalesSetup.Get;
                TextoLopd := SalesSetup."Texto 1 LOPD";// + ' ' + SalesSetup."Texto 2 LOPD" + ' ' + SalesSetup."Texto 3 LOPD" + ' ' + SalesSetup."Texto 4 LOPD" +
                //' ' + SalesSetup."Texto 5 LOPD" + ' ' + SalesSetup."Texto 6 LOPD" + ' ' + SalesSetup."Texto 7 LOPD";
                wCtaBancoIban := '';
                wCtaBancoSwift := '';
                if "Sales Invoice Header"."Nuestra Cuenta" <> '' THEN BEGIN
                    PaymentMethod."Banco transferencia" := "Sales Invoice Header"."Nuestra Cuenta";
                    //  PaymentMethod.MODIFY;
                END;
                if (PaymentMethod."Banco transferencia" = '') And ("Sales Invoice Header"."Nuestra Cuenta Prepago" <> '') THEN BEGIN
                    PaymentMethod."Banco transferencia" := "Sales Invoice Header"."Nuestra Cuenta Prepago";
                    //  PaymentMethod.MODIFY;
                END;

                if PaymentMethod."Banco transferencia" <> '' THEN BEGIN
                    if rBanco.GET(PaymentMethod."Banco transferencia") THEN BEGIN
                        wCtaBancoSwift := rBanco."SWIFT Code";
                        if rBanco.IBAN <> '' THEN
                            wCtaBancoIban := ('IBAN: ' + COPYSTR(rBanco.IBAN, 1, 4) + ' ' +
                                COPYSTR(rBanco.IBAN, 5, 4) + ' ' +
                                COPYSTR(rBanco.IBAN, 9, 4) + ' ' +
                                COPYSTR(rBanco.IBAN, 13, 4) + ' ' +
                                COPYSTR(rBanco.IBAN, 17, 4) + ' ' +
                                COPYSTR(rBanco.IBAN, 21, 4) + ' ' +
                                COPYSTR(rBanco.IBAN, 25, 4) + ' ' +
                                COPYSTR(rBanco.IBAN, 29, 4))

                        ELSE
                            wCtaBancoIban := rBanco."CCC Bank No." + '-' + rBanco."CCC Bank Branch No." + '-' +
                                        rBanco."CCC Control Digits" + '-' + rBanco."CCC Bank Account No.";
                        //SetRange(Number,1,1);
                    END;
                END
                ELSE BEGIN
                    if PaymentMethod."Domiciliacion cliente" THEN BEGIN
                        if rBcoCli.GET("Sales Invoice Header"."Bill-to Customer No.", "Sales Invoice Header"."Cust. Bank Acc. Code") THEN BEGIN
                            wCtaBancoSwift := rBcoCli."SWIFT Code";
                            if rBcoCli.IBAN <> '' THEN
                                wCtaBancoIban := ('IBAN: ' + COPYSTR(rBcoCli.IBAN, 1, 4) + ' ' +
                                    COPYSTR(rBcoCli.IBAN, 5, 4) + ' ' +
                                    COPYSTR(rBcoCli.IBAN, 9, 4) + ' ' +
                                    COPYSTR(rBcoCli.IBAN, 13, 2) + ' ' +
                                    COPYSTR(rBcoCli.IBAN, 16))
                            ELSE
                                wCtaBancoIban := rBcoCli."CCC Bank No." + '-' + rBcoCli."CCC Bank Branch No." + '-' +
                                            rBcoCli."CCC Control Digits" + '-' + rBcoCli."CCC Bank Account No.";
                            //SetRange(Number,1,1);
                        END;
                    END;
                END;
                //
                //FormatAddr.SalesInvShipTo(ShipToAddr,"Sales Invoice Header");

                // MNC 240500
                //ShipToAddr[8] := 'CIF/NIF: ' + Cust."VAT Registration No.";
                FormatAddressFields("Sales Invoice Header");
                FormatDocumentFields("Sales Invoice Header");
                if "Your Reference" = '' THEN begin
                    "Your Reference" := "Customer Order No.";
                    if "Your Reference" <> '' then
                        ReferenceText := FIELDCAPTION("Customer Order No.");
                end;
                COMPRESSARRAY(ShipToAddr);
                // MNC 240500

                ShowShippingAddr := "Sell-to Customer No." <> "Bill-to Customer No.";
                FOR i := 1 TO ARRAYLEN(ShipToAddr) DO
                    if ShipToAddr[i] <> CustAddr[i] THEN
                        ShowShippingAddr := TRUE;
                SalesSetup.Get();
                if Logotipo Then
                    TextoPie := SalesSetup."Texto empresa" + ' ' + SalesSetup."Pie 1 factura" + ' ' + SalesSetup."Pie 2 factura";

                //$002(I)
                wTotPrepago := 0;
                wPorPrepago := 0;
                wBaseIvaPrep := 0;
                wImpIVaPrep := 0;
                //$002(F)

                //$008(I)
                wFecReg := "Sales Invoice Header"."Posting Date";
                if FecEmis THEN
                    wFecReg := "Sales Invoice Header"."Document Date";
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
                    rLinVtaOrd.SETRANGE("Document No.", "Sales Invoice Header"."No.");
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
                if rContr.Get(rContr."Document Type"::Order, "Nº Contrato") then
                    "Description Contrato" := rContr."Posting Description";
                //FinASC


                if NOT Cust.GET("Bill-to Customer No.") THEN
                    CLEAR(Cust);

                DimSetEntry1.SETRANGE("Dimension Set ID", "Dimension Set ID");

                GetLineFeeNoteOnReportHist("No.");

                if LogInteraction THEN
                    if NOT CurrReport.PREVIEW THEN BEGIN
                        if "Bill-to Contact No." <> '' THEN
                            SegManagement.LogDocument(
                              4, "No.", 0, 0, DATABASE::Contact, "Bill-to Contact No.", "Salesperson Code",
                              "Campaign No.", "Posting Description", '')
                        ELSE
                            SegManagement.LogDocument(
                              4, "No.", 0, 0, DATABASE::Customer, "Bill-to Customer No.", "Salesperson Code",
                              "Campaign No.", "Posting Description", '');
                    END;
                //Prepago
                if (SalesSetup."Logo Position on Documents" = SalesSetup."Logo Position on Documents"::Center) And (Logotipo) Then begin
                    CompanyInfo1.Get();
                    CompanyInfo1.CalcFields(Picture);
                end;

            end;
        }
    }

    requestpage
    {
        // SaveValues = true;

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
                    field(ShowInternalInfo; ShowInternalInfo)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Mostrar información interna';
                        ToolTip = 'Specifies if the document shows internal information.';
                    }
                    field(LogInteraction; LogInteraction)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Log Interacción';
                        Enabled = LogInteractionEnable;
                        ToolTip = 'Specifies that interactions with the contact are logged.';
                    }
                    field(DisplayAsmInformation; Desglo)
                    {
                        ApplicationArea = All;
                        Caption = 'Ver facturas propuestas';
                    }

                    field(DisplayAdditionalFeeNote; DisplayAdditionalFeeNote)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Mostrar nota de tarifa adicional';
                        ToolTip = 'Specifies that any notes about additional fees are included on the document.';
                    }
                    field(Logotipo; Logotipo) { ApplicationArea = All; }
                    field("Imprimir Solo Totales"; wToTal2) { ApplicationArea = All; }
                    field("Imprimir fecha emisión doc."; FecEmis) { ApplicationArea = All; }
                    field("Recursos agrupados por tarea"; AgrRec) { ApplicationArea = All; }
                    field("Totales por tarea"; TotTarea) { ApplicationArea = All; }
                    field("Solo Texto Ampliado"; TextAmpl) { ApplicationArea = All; }
                    field("Solo Texto Impresión"; TextImpr) { ApplicationArea = All; }
                    field("Imprimir Dirección Envio"; ShipAd) { ApplicationArea = All; }
                    //field("Imprime desglose Fechas"; desglo) { ApplicationArea = All; }
                    field("Imprimir cláusula buses"; IClausulbuses) { ApplicationArea = All; }
                    field("Imprimir cláusula Intercambio"; IClausulInter) { ApplicationArea = All; }

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

            Desglo := true; // otra vez puesto, y lllevamos 5 veces en un año
            Logotipo := true; // otra vez puesto, y lllevamos 5 veces en un año
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
        if Logotipo Then begin
            FormatDocument.SetLogoPosition(SalesSetup."Logo Position on Documents", CompanyInfo1, CompanyInfo2, CompanyInfo3);

        end;
        TextoLopd := SalesSetup."Texto 1 LOPD";// + ' ' + SalesSetup."Texto 2 LOPD" + ' ' + SalesSetup."Texto 3 LOPD" + ' ' + SalesSetup."Texto 4 LOPD" +
                                               //                   ' ' + SalesSetup."Texto 5 LOPD" + ' ' + SalesSetup."Texto 6 LOPD" + ' ' + SalesSetup."Texto 7 LOPD";
    end;

    trigger OnPreReport()
    begin
        if NOT CurrReport.USEREQUESTPAGE THEN
            InitLogInteraction;
    end;

    var
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
#pragma warning disable AL0432
        VATAmountLine: Record "VAT Amount Line" temporary;
#pragma warning restore AL0432
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
        PaymentMethod: Record 289;
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
        PostingDateCaptionLbl: Label 'Fecha Contrato';
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
        wContOrigen: Text;
        wTxtRenovado: Text;
        CACCaptionLbl: Text;
        "Description Contrato": Text;
        CACTxt: Label 'Régimen especial del criterio de caja';
        DisplayAdditionalFeeNote: Boolean;
        LineNoWithTotal: Integer;
        "Datos Registro": Text;
        rProy: Record 167;
        rLinV: Record 37;
        rRecurs: Record 156;
        TipoCambioDivisa: Record "Currency Exchange Rate";
        rTarea: Record 1001;
        SalesInvCountPrinted: Codeunit 315;
        rContrato: Record 36;
        wFecReg: Date;
        TextoCopia: Text[30];
        HayDto: Text;
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
        wTotal2: Option "Según Contrato","Solo Totales",Todo;
        Empresa: Text[30];
        Numero: Code[20];
        numreg: Text;
        TextImpr: Boolean;
        wCtaBancoIban: Text;
        wCtaBancoSwift: Text;
        ShipAd: Boolean;
        Desglo: Boolean;
        IClausulBuses: Boolean;
        IClausulInter: Boolean;
        EC: Text[30];
        ECp: Text[30];
        aVtos: ARRAY[29] OF Date;
        aImportes: ARRAY[29] OF Decimal;
        CapEntregaALaFirma: Text;
        PrepmtImporte: Decimal;
        TextoPrepago: Text;
        CapEntregaA1: Text;
        PrepmtImporte1: Decimal;
        TextoPrepago1: Text;

    /// <summary>
    /// Prepago.
    /// </summary>
    procedure Prepago()
    var
        rLinVtaPre: Record "Sales Line";
        TempSalesLine: Record "Sales Line" temporary;
        SalesPostPrepmt: Codeunit "Sales-Post Prepayments";
#pragma warning disable AL0432
        TempVATAmountLine4: Record "VAT Amount Line" temporary;
#pragma warning restore AL0432
        PrepmtTotalAmount: Decimal;
        PrepmtVATAmount: Decimal;
        PrepmtVATAmountText: Text;
        wTotFra1: Decimal;
        rPropuestas: Record "Facturas Propuestas";
        rFacPre: Record "Sales Invoice Header";
        rLinPre: Record "Sales Invoice Line";
        wTotPre: Decimal;
        Txt002: Label 'No se permite reparto = 1ª fra si se ha generado prepago.\\Debería utilizar reparto = Fra prepago y generar de nuevo el prepago.';
    Begin

        rFacPre.SetRange("Nº Contrato", "Sales Invoice Header"."No.");
        rFacPre.SetRange("Prepayment Invoice", TRUE);
        rFacPre.SetRange("Posting Description", 'ENTREGA A CUENTA');
        If rFacPre.FINDSET THEN begin
            //If rFacPre."Due Date" <> 0D Then CapEntregaA1 := 'Fecha Vto:';
            //TextoPrepago1 := Format(rFacPre."Due Date", 0, '<Day,2>/<Month,2>/<Year4>');
            ;
            rFacPre.CalcFields("Amount Including VAT");
            PrepmtImporte := rFacPre."Amount Including VAT";
            if PrepmtImporte <> 0 Then begin
                CapEntregaALaFirma := 'Entrega a la firma (IVA incl.):';
                TextoPrepago := '(' + "Sales Invoice Header"."Forma pago prepago" + ')';
            end;
            exit;
        end;


        If "Sales Invoice Header"."Prepayment %" <> 0 then
            If "Sales Invoice Header"."Prepayment Due Date" <> 0D Then begin
                // CapEntregaA1 := 'Fecha Vto:';
                // TextoPrepago1 := Format("Sales Invoice Header"."Prepayment Due Date", 0, '<Day,2>/<Month,2>/<Year4>');
            end;

        if "Sales Invoice Header"."Prepayment %" = 100 THEN
            exit;
        TempSalesLine.DELETEALL;
        CLEAR(TempSalesLine);
        SalesPostPrepmt.GetSalesLines("Sales Invoice Header", 0, TempSalesLine);
        If TempSalesLine.FINDSET THEN BEGIN
            REPEAT
                If TempSalesLine.Reparto = TempSalesLine.Reparto::"Fra prepago" THEN BEGIN
                    TempSalesLine."Prepmt. Line Amount" := 0;
                    TempSalesLine."Prepmt. Amt. Inv." := 0;
                    TempSalesLine.Modify();
                END;
            UNTIL TempSalesLine.NEXT = 0;
        END;
        SalesPostPrepmt.SumPrepmt(
        "Sales Invoice Header", TempSalesLine, TempVATAmountLine4, PrepmtTotalAmount, PrepmtVATAmount, PrepmtVATAmountText);

        //$014(I)
        wTotFra1 := 0;
        rPropuestas.SETRANGE("No. Contrato", "Sales Invoice Header"."No.");
        rPropuestas.SETRANGE("Factura 1", TRUE);
        if rPropuestas.FINDSET THEN
            REPEAT
                wTotFra1 += rPropuestas."Importe con IVA";
            UNTIL rPropuestas.NEXT = 0;

        //Visualizo error, no se permite prepago y reparto 1ª fra
        if (PrepmtTotalAmount <> 0) AND (wTotFra1 <> 0) THEN
            Exit;

        //CurrReport.SHOWOUTPUT(PrepmtTotalAmount <> 0);
        //$014(F)

        //$012 (I)
        wTotPre := 0;
        //if CurrReport.SHOWOUTPUT THEN BEGIN
        ///if "Sales Header"."% prep incl produccion" THEN BEGIN                        //$013
        rLinVtaPre.RESET;
        rLinVtaPre.SETRANGE("Document Type", "Sales Invoice Header"."Document Type");
        rLinVtaPre.SETRANGE("Document No.", "Sales Invoice Header"."No.");
        rLinVtaPre.SETRANGE(Reparto, rLinVtaPre.Reparto::"Fra prepago");
        if rLinVtaPre.FINDSET THEN BEGIN
            REPEAT
                wTotPre := wTotPre + rLinVtaPre."Line Amount";
                wTotPre := wTotPre + ROUND(rLinVtaPre."Line Amount" * rLinVtaPre."VAT %" / 100);
            UNTIL rLinVtaPre.NEXT = 0;
        END;
        ///END;                                                                         //$013
        //$019(I)
        //if wTotFra1 <> 0 THEN
        //  CurrReport.SHOWOUTPUT(FALSE);
        TextoPrepago := '';
        if wTotFra1 = 0 THEN Begin

            PrepmtImporte := PrepmtTotalAmount + PrepmtVATAmount + wTotPre + wTotFra1;
            if PrepmtImporte <> 0 Then begin
                CapEntregaALaFirma := 'Entrega a cuenta a la firma (IVA incl.):';
                TextoPrepago := '(' + "Sales Invoice Header"."Forma pago prepago" + ')';
            end;
        end else begin

            PrepmtImporte1 := PrepmtTotalAmount + PrepmtVATAmount + wTotPre + wTotFra1;

            if PrepmtImporte1 <> 0 Then begin
                CapEntregaALaFirma := 'Importe 1ª Factura:';
                if TextoPrepago1 = '' then
                    TextoPrepago1 := '(' + "Sales Invoice Header"."Forma pago prepago" + ')';
            EnD;

        end;
        //$019(F)
        //END;
        //$012 (F)
    End;

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
        if "Sales Invoice Line"."Shipment No." <> '' THEN
            if SalesShipmentHeader.GET("Sales Invoice Line"."Shipment No.") THEN
                EXIT(SalesShipmentHeader."Posting Date");

        if "Sales Invoice Header"."No." = '' THEN
            EXIT("Sales Invoice Header"."Posting Date");

        CASE "Sales Invoice Line".Type OF
            "Sales Invoice Line".Type::Item:
                GenerateBufferFromValueEntry("Sales Invoice Line");
            "Sales Invoice Line".Type::"G/L Account", "Sales Invoice Line".Type::Resource,
          "Sales Invoice Line".Type::"Charge (Item)", "Sales Invoice Line".Type::"Fixed Asset":
                GenerateBufferFromShipment("Sales Invoice Line");
            "Sales Invoice Line".Type::" ":
                EXIT(0D);
        END;

        SalesShipmentBuffer.RESET;
        SalesShipmentBuffer.SETRANGE("Document No.", "Sales Invoice Line"."Document No.");
        SalesShipmentBuffer.SETRANGE("Line No.", "Sales Invoice Line"."Line No.");
        if SalesShipmentBuffer.FIND('-') THEN BEGIN
            SalesShipmentBuffer2 := SalesShipmentBuffer;
            if SalesShipmentBuffer.NEXT = 0 THEN BEGIN
                SalesShipmentBuffer.GET(
                  SalesShipmentBuffer2."Document No.", SalesShipmentBuffer2."Line No.", SalesShipmentBuffer2."Entry No.");
                SalesShipmentBuffer.DELETE;
                EXIT(SalesShipmentBuffer2."Posting Date");
            END;
            SalesShipmentBuffer.CALCSUMS(Quantity);
            if SalesShipmentBuffer.Quantity <> "Sales Invoice Line".Quantity THEN BEGIN
                SalesShipmentBuffer.DELETEALL;
                EXIT("Sales Invoice Header"."Posting Date");
            END;
        END ELSE
            EXIT("Sales Invoice Header"."Posting Date");
    end;

    local procedure GenerateBufferFromValueEntry(SalesInvoiceLine2: Record 37)
    var
        ValueEntry: Record 5802;
        ItemLedgerEntry: Record 32;
        TotalQuantity: Decimal;
        Quantity: Decimal;
    begin
        TotalQuantity := SalesInvoiceLine2."Quantity (Base)";
        ValueEntry.SETCURRENTKEY("Document No.");
        ValueEntry.SETRANGE("Document No.", SalesInvoiceLine2."Document No.");
        ValueEntry.SETRANGE("Posting Date", "Sales Invoice Header"."Posting Date");
        ValueEntry.SETRANGE("Item Charge No.", '');
        ValueEntry.SETFILTER("Entry No.", '%1..', FirstValueEntryNo);
        if ValueEntry.FIND('-') THEN
            REPEAT
                if ItemLedgerEntry.GET(ValueEntry."Item Ledger Entry No.") THEN BEGIN
                    if SalesInvoiceLine2."Qty. per Unit of Measure" <> 0 THEN
                        Quantity := ValueEntry."Invoiced Quantity" / SalesInvoiceLine2."Qty. per Unit of Measure"
                    ELSE
                        Quantity := ValueEntry."Invoiced Quantity";
                    AddBufferEntry(
                      SalesInvoiceLine2,
                      -Quantity,
                      ItemLedgerEntry."Posting Date");
                    TotalQuantity := TotalQuantity + ValueEntry."Invoiced Quantity";
                END;
                FirstValueEntryNo := ValueEntry."Entry No." + 1;
            UNTIL (ValueEntry.NEXT = 0) OR (TotalQuantity = 0);
    end;

    local procedure GenerateBufferFromShipment(SalesInvoiceLine: Record 37)
    var
        SalesInvoiceHeader: Record 36;
        SalesInvoiceLine2: Record 37;
        SalesShipmentHeader: Record 110;
        SalesShipmentLine: Record 111;
        TotalQuantity: Decimal;
        Quantity: Decimal;
    begin
        TotalQuantity := 0;
        // SalesInvoiceHeader.SETCURRENTKEY("Order No.");
        // SalesInvoiceHeader.SETFILTER("No.", '..%1', "Sales Invoice Header"."No.");
        // SalesInvoiceHeader.SETRANGE("Order No.", "Sales Invoice Header"."No.");
        // if SalesInvoiceHeader.FIND('-') THEN
        //     REPEAT
        //         SalesInvoiceLine2.SETRANGE("Document No.", SalesInvoiceHeader."No.");
        //         SalesInvoiceLine2.SETRANGE("Line No.", SalesInvoiceLine."Line No.");
        //         SalesInvoiceLine2.SETRANGE(Type, SalesInvoiceLine.Type);
        //         SalesInvoiceLine2.SETRANGE("No.", SalesInvoiceLine."No.");
        //         SalesInvoiceLine2.SETRANGE("Unit of Measure Code", SalesInvoiceLine."Unit of Measure Code");
        //         if SalesInvoiceLine2.FIND('-') THEN
        //             REPEAT
        //                 TotalQuantity := TotalQuantity + SalesInvoiceLine2.Quantity;
        //             UNTIL SalesInvoiceLine2.NEXT = 0;
        //     UNTIL SalesInvoiceHeader.NEXT = 0;

        // SalesShipmentLine.SETCURRENTKEY("Order No.", "Order Line No.");
        // SalesShipmentLine.SETRANGE("Order No.", "Sales Invoice Header"."No.");
        // SalesShipmentLine.SETRANGE("Order Line No.", SalesInvoiceLine."Line No.");
        // SalesShipmentLine.SETRANGE("Line No.", SalesInvoiceLine."Line No.");
        // SalesShipmentLine.SETRANGE(Type, SalesInvoiceLine.Type);
        // SalesShipmentLine.SETRANGE("No.", SalesInvoiceLine."No.");
        // SalesShipmentLine.SETRANGE("Unit of Measure Code", SalesInvoiceLine."Unit of Measure Code");
        // SalesShipmentLine.SETFILTER(Quantity, '<>%1', 0);

        // if SalesShipmentLine.FIND('-') THEN
        //     REPEAT
        //         if "Sales Invoice Header"."Get Shipment Used" THEN
        //             CorrectShipment(SalesShipmentLine);
        //         if ABS(SalesShipmentLine.Quantity) <= ABS(TotalQuantity - SalesInvoiceLine.Quantity) THEN
        //             TotalQuantity := TotalQuantity - SalesShipmentLine.Quantity
        //         ELSE BEGIN
        //             if ABS(SalesShipmentLine.Quantity) > ABS(TotalQuantity) THEN
        //                 SalesShipmentLine.Quantity := TotalQuantity;
        //             Quantity :=
        //               SalesShipmentLine.Quantity - (TotalQuantity - SalesInvoiceLine.Quantity);

        //             TotalQuantity := TotalQuantity - SalesShipmentLine.Quantity;
        //             SalesInvoiceLine.Quantity := SalesInvoiceLine.Quantity - Quantity;

        //             if SalesShipmentHeader.GET(SalesShipmentLine."Document No.") THEN
        //                 AddBufferEntry(
        //                   SalesInvoiceLine,
        //                   Quantity,
        //                   SalesShipmentHeader."Posting Date");
        //         END;
        //     UNTIL (SalesShipmentLine.NEXT = 0) OR (TotalQuantity = 0);
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

    local procedure AddBufferEntry(SalesInvoiceLine: Record 37; QtyOnShipment: Decimal; PostingDate: Date)
    begin
        SalesShipmentBuffer.SETRANGE("Document No.", SalesInvoiceLine."Document No.");
        SalesShipmentBuffer.SETRANGE("Line No.", SalesInvoiceLine."Line No.");
        SalesShipmentBuffer.SETRANGE("Posting Date", PostingDate);
        if SalesShipmentBuffer.FIND('-') THEN BEGIN
            SalesShipmentBuffer.Quantity := SalesShipmentBuffer.Quantity + QtyOnShipment;
            SalesShipmentBuffer.MODIFY;
            EXIT;
        END;

        // WITH SalesShipmentBuffer. DO BEGIN
        SalesShipmentBuffer."Document No." := SalesInvoiceLine."Document No.";
        SalesShipmentBuffer."Line No." := SalesInvoiceLine."Line No.";
        SalesShipmentBuffer."Entry No." := NextEntryNo;
        SalesShipmentBuffer.Type := SalesInvoiceLine.Type;
        SalesShipmentBuffer."No." := SalesInvoiceLine."No.";
        SalesShipmentBuffer.Quantity := QtyOnShipment;
        SalesShipmentBuffer."Posting Date" := PostingDate;
        SalesShipmentBuffer.INSERT;
        NextEntryNo := NextEntryNo + 1
        // END;
    end;

    local procedure DocumentCaption(): Text
    begin
        //if "Sales Invoice Header"."No." THEN
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
        // WITH CustLedgEntry. DO BEGIN
        CustLedgEntry.SETCURRENTKEY("Document No.", "Document Type", "Customer No.");
        CustLedgEntry.SETRANGE("Document Type", CustLedgEntry."Document Type"::Invoice);
        CustLedgEntry.SETRANGE("Document No.", "Sales Invoice Header"."No.");
        CustLedgEntry.SETRANGE("Customer No.", "Sales Invoice Header"."Bill-to Customer No.");
        CustLedgEntry.SETRANGE("Posting Date", "Sales Invoice Header"."Posting Date");
        if CustLedgEntry.FINDFIRST THEN
            if CustLedgEntry."Document Situation" = CustLedgEntry."Document Situation"::" " THEN
                EXIT(FALSE)
            ELSE
                EXIT(TRUE)
        ELSE
            EXIT(FALSE);
        // END;
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
    /// AlgunDto.
    /// </summary>
    /// <returns>Return value of type Decimal.</returns>
    procedure AlgunDto(): Decimal
    var
        rLinv: Record "Sales Line";
    begin
        rLinV.SETCURRENTKEY("Document No.", "Line No.");
        rLinV.SETRANGE("Document No.", "Sales Invoice Header"."No.");
        rLinV.SETFILTER("Line Discount %", '<>%1', 0);
        if rLinV.FindFirst() THEN
            exit(rlinv."Line Discount %");
        exit(0);
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

    local procedure FormatDocumentFields(SalesInvoiceHeader: Record 36)
    begin
        // WITH SalesInvoiceHeader. DO BEGIN
        FormatDocument.SetTotalLabels(SalesInvoiceHeader."Currency Code", TotalText, TotalInclVATText, TotalExclVATText);
        FormatDocument.SetSalesPerson(SalesPurchPerson, SalesInvoiceHeader."Salesperson Code", SalesPersonText);
        FormatDocument.SetPaymentTerms(PaymentTerms, SalesInvoiceHeader."Payment Terms Code", SalesInvoiceHeader."Language Code");
        FormatDocument.SetShipmentMethod(ShipmentMethod, SalesInvoiceHeader."Shipment Method Code", SalesInvoiceHeader."Language Code");
        if SalesInvoiceHeader."Payment Method Code" = '' THEN
            PaymentMethod.INIT
        ELSE
            PaymentMethod.GET(SalesInvoiceHeader."Payment Method Code");

        //OrderNoText := FormatDocument.SetText(SalesInvoiceHeader."Order No." <> '', SalesInvoiceHeader.FIELDCAPTION("Order No."));
        ReferenceText := FormatDocument.SetText(SalesInvoiceHeader."Your Reference" <> '', SalesInvoiceHeader.FIELDCAPTION("Your Reference"));
        VATNoText := FormatDocument.SetText(SalesInvoiceHeader."VAT Registration No." <> '', SalesInvoiceHeader.FIELDCAPTION("VAT Registration No."));
        // END;
    end;

    local procedure FormatAddressFields(SalesInvoiceHeader: Record 36)
    begin
        FormatAddr.GetCompanyAddr(SalesInvoiceHeader."Responsibility Center", RespCenter, CompanyInfo, CompanyAddr);
        FormatAddr.SalesHeaderBillTo(CustAddr, SalesInvoiceHeader);
        ShowShippingAddr := FormatAddr.SalesHeaderShipTo(ShipToAddr, CustAddr, SalesInvoiceHeader);
    end;

    local procedure CollectAsmInformation()
    var
        ValueEntry: Record 5802;
        ItemLedgerEntry: Record 32;
        PostedAsmHeader: Record 910;
        PostedAsmLine: Record 911;
        SalesShipmentLine: Record 111;
    begin
        TempPostedAsmLine.DELETEALL;
        if "Sales Invoice Line".Type <> "Sales Invoice Line".Type::Item THEN
            EXIT;
        // WITH ValueEntry. DO BEGIN
        ValueEntry.SETCURRENTKEY("Document No.");
        ValueEntry.SETRANGE("Document No.", "Sales Invoice Line"."Document No.");
        ValueEntry.SETRANGE("Document Type", ValueEntry."Document Type"::"Sales Invoice");
        ValueEntry.SETRANGE("Document Line No.", "Sales Invoice Line"."Line No.");
        ValueEntry.SETRANGE(Adjustment, FALSE);
        if NOT ValueEntry.FINDSET THEN
            EXIT;
        // END;
        REPEAT
            if ItemLedgerEntry.GET(ValueEntry."Item Ledger Entry No.") THEN
                if ItemLedgerEntry."Document Type" = ItemLedgerEntry."Document Type"::"Sales Shipment" THEN BEGIN
                    SalesShipmentLine.GET(ItemLedgerEntry."Document No.", ItemLedgerEntry."Document Line No.");
                    if SalesShipmentLine.AsmToShipmentExists(PostedAsmHeader) THEN BEGIN
                        PostedAsmLine.SETRANGE("Document No.", PostedAsmHeader."No.");
                        if PostedAsmLine.FINDSET THEN
                            REPEAT
                                TreatAsmLineBuffer(PostedAsmLine);
                            UNTIL PostedAsmLine.NEXT = 0;
                    END;
                END;
        UNTIL ValueEntry.NEXT = 0;
    end;

    local procedure TreatAsmLineBuffer(PostedAsmLine: Record 911)
    begin
        CLEAR(TempPostedAsmLine);
        TempPostedAsmLine.SETRANGE(Type, PostedAsmLine.Type);
        TempPostedAsmLine.SETRANGE("No.", PostedAsmLine."No.");
        TempPostedAsmLine.SETRANGE("Variant Code", PostedAsmLine."Variant Code");
        TempPostedAsmLine.SETRANGE(Description, PostedAsmLine.Description);
        TempPostedAsmLine.SETRANGE("Unit of Measure Code", PostedAsmLine."Unit of Measure Code");
        if TempPostedAsmLine.FINDFIRST THEN BEGIN
            TempPostedAsmLine.Quantity += PostedAsmLine.Quantity;
            TempPostedAsmLine.MODIFY;
        END ELSE BEGIN
            CLEAR(TempPostedAsmLine);
            TempPostedAsmLine := PostedAsmLine;
            TempPostedAsmLine.INSERT;
        END;
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

    local procedure GetLineFeeNoteOnReportHist(SalesInvoiceHeaderNo: Code[20])
    var
        LineFeeNoteOnReportHist: Record 1053;
        CustLedgerEntry: Record 21;
        Customer: Record Customer;
    begin
        TempLineFeeNoteOnReportHist.DELETEALL;
        CustLedgerEntry.SETRANGE("Document Type", CustLedgerEntry."Document Type"::Invoice);
        CustLedgerEntry.SETRANGE("Document No.", SalesInvoiceHeaderNo);
        if NOT CustLedgerEntry.FINDFIRST THEN
            EXIT;

        if NOT Customer.GET(CustLedgerEntry."Customer No.") THEN
            EXIT;

        LineFeeNoteOnReportHist.SETRANGE("Cust. Ledger Entry No", CustLedgerEntry."Entry No.");
        LineFeeNoteOnReportHist.SETRANGE("Language Code", Customer."Language Code");
        if LineFeeNoteOnReportHist.FINDSET THEN BEGIN
            REPEAT
                TempLineFeeNoteOnReportHist.INIT;
                TempLineFeeNoteOnReportHist.COPY(LineFeeNoteOnReportHist);
                TempLineFeeNoteOnReportHist.INSERT;
            UNTIL LineFeeNoteOnReportHist.NEXT = 0;
        END ELSE BEGIN
            //LineFeeNoteOnReportHist.SETRANGE("Language Code", Language. .GetUserLanguage);
            if LineFeeNoteOnReportHist.FINDSET THEN
                REPEAT
                    TempLineFeeNoteOnReportHist.INIT;
                    TempLineFeeNoteOnReportHist.COPY(LineFeeNoteOnReportHist);
                    TempLineFeeNoteOnReportHist.INSERT;
                UNTIL LineFeeNoteOnReportHist.NEXT = 0;
        END;
    end;

    local procedure TextoDuracion(TipoDuracion: Enum Duracion; Duracion: Decimal; Cs: Decimal; Canatidad: Decimal; Fecha: Date): Text
    begin
        if Fecha < 20240201D Then begin
            exit('');

        end;
        cs := CandidadSoportes(cs, Canatidad, Fecha);
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

    local procedure PrecioTarifa(PrecioTarifa: Decimal; UnitPrice: Decimal; DtoTarifa: Decimal): Decimal
    begin
        if DtoTarifa <> 0 then
            exit(PrecioTarifa);
        If UnitPrice = PrecioTarifa Then
            exit(0);
        exit(PrecioTarifa);
    end;

    procedure Descuento(Dto: Decimal): Text;
    begin
        if Dto = 0 then exit('');
        exit(Format(Dto, 0, '<Precision,0:2><Standard Format,0>') + '%');
    end;

    procedure CandidadSoportes(CS: decimal; Cantidad: Decimal; Fecha: Date): Decimal;
    begin
        if Fecha < 20240201D Then begin
            exit(Cantidad);
        end;
        If cs = 0 Then Exit(1);
        exit(Cs);
    end;

    PROCEDURE Importe(Preu: Decimal): Decimal;
    BEGIN
        if wTotal THEN EXIT(0);
        EXIT(Preu);
    END;

    PROCEDURE FiltroTexto2(r113: Record 37; VAR rTexto: Record "Texto Presupuesto");
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

        exit("Sales Invoice Header"."Currency Code");
    end;

    /// <summary>
    /// CBuses.
    /// </summary>
    /// <returns>Return value of type Text.</returns>
    procedure CBuses(): Text
    var
        JSetProy: Record "Jobs Setup";
    begin
        if Not IClausulbuses Then exit('');
        JSetProy.Get();
        exit(JSetProy."Clausula Buses");
    end;

    /// <summary>
    /// CItercambio.
    /// </summary>
    /// <returns>Return value of type Text.</returns>
    procedure CItercambio(): Text
    var
        JSetProy: Record "Jobs Setup";
    begin
        if Not IClausulInter Then exit('');
        JSetProy.Get();
        exit(JSetProy."Clausula Intercambio");
    end;

}

