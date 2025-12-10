/// <summary>
/// Report Carta Bancaria (ID 50012).
/// </summary>
report 50009 "Carta Bancaria"
{
    DefaultLayout = RDLC;
    RDLCLayout = './src/report/layout/CartaBancaria.rdlc';
    Caption = 'Autorización Domiciliación bancaria';
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
            column(Autorizaciondomiciliacion; Autrizacion("Sales Invoice Header"))
            {
            }
            column(AutorizaClausula; Autoriza("Sales Invoice Header"."Nº Contrato"))
            {
            }
            column(FirmaRepresentante; Firma(WorkDate()))
            {
            }
            column(Fecha; CabFecha(WorkDate()))
            { }
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

            dataitem(CopyLoop; Integer)
            {
                DataItemTableView = SORTING(Number);
                dataitem(PageLoop; Integer)
                {
                    DataItemTableView = SORTING(Number)
                                        WHERE(Number = CONST(1));
                    Column(Cuenta_bancaria_Caption; 'Cuenta bancaria:') { }
                    Column(wCtaBancoIban; wCtaBancoIban) { }
                    Column(Shift; Swift) { }
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
                    column(BankName; BankNameCaptionLbl)
                    { }


                }

                trigger OnAfterGetRecord()
                begin
                    if Number > 1 THEN BEGIN
                        CopyText := FormatDocument.GetCOPYText;
                        OutputNo += 1;
                    END;

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
                    if NOT CurrReport.PREVIEW THEN
                        CODEUNIT.RUN(CODEUNIT::"Sales-Printed", "Sales Invoice Header");
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
                if rPropuestas.FINDSET THEN
                    REPEAT
                        aVtos[j] := rPropuestas."Fecha Vencimiento";
                        aImportes[j] := rPropuestas."Importe con IVA";
                        j += 1;
                    UNTIL (rPropuestas.NEXT = 0) OR (j = 29);
                HayDto := '';

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
                if rLinV.FIND('-') THEN
                    HayDto := '%Dto';
                rCom.SETRANGE(rCom."Document Type", rCom."Document Type"::"Detalle Fac. Reg");
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
                TextoLopd := SalesSetup."Texto 1 LOPD";//+ ' ' + SalesSetup."Texto 2 LOPD" + ' ' + SalesSetup."Texto 3 LOPD" + ' ' + SalesSetup."Texto 4 LOPD" +
                //' ' + SalesSetup."Texto 5 LOPD" + ' ' + SalesSetup."Texto 6 LOPD" + ' ' + SalesSetup."Texto 7 LOPD";
                wCtaBancoIban := '';
                if "Sales Invoice Header"."Nuestra Cuenta" <> '' THEN BEGIN
                    PaymentMethod."Banco transferencia" := "Sales Invoice Header"."Nuestra Cuenta";
                    //  PaymentMethod.MODIFY;
                END;

                //if PaymentMethod."Banco transferencia" <> '' THEN BEGIN
                // if rBanco.GET(PaymentMethod."Banco transferencia") THEN BEGIN
                //     if rBanco.IBAN <> '' THEN
                //         wCtaBancoIban := ('IBAN: ' + COPYSTR(rBanco.IBAN, 1, 4) + ' ' +
                //             COPYSTR(rBanco.IBAN, 5, 4) + ' ' +
                //             COPYSTR(rBanco.IBAN, 9, 4) + ' ' +
                //             COPYSTR(rBanco.IBAN, 13, 4) + ' ' +
                //             COPYSTR(rBanco.IBAN, 17, 4) + ' ' +
                //             COPYSTR(rBanco.IBAN, 21, 4) + ' ' +
                //             COPYSTR(rBanco.IBAN, 25, 4) + ' ' +
                //             COPYSTR(rBanco.IBAN, 29, 4))

                //     ELSE
                //         wCtaBancoIban := rBanco."CCC Bank No." + '-' + rBanco."CCC Bank Branch No." + '-' +
                //                     rBanco."CCC Control Digits" + '-' + rBanco."CCC Bank Account No.";
                //     //SetRange(Number,1,1);
                // END;
                // END
                // ELSE BEGIN
                //     if PaymentMethod."Domiciliacion cliente" THEN BEGIN
                Cust.Get("Sales Invoice Header"."Bill-to Customer No.");
                if Not rBcoCli.GET("Sales Invoice Header"."Bill-to Customer No.", Cust."Preferred Bank Account Code") Then begin
                    rBcoCli.SetRange("Customer No.", "Sales Invoice Header"."Bill-to Customer No.");
                    rBcoCli.FindFirst();
                end;
                //THEN BEGIN
                if rBcoCli.IBAN <> '' THEN
                    wCtaBancoIban := ('IBAN: ' + COPYSTR(rBcoCli.IBAN, 1, 4) + ' ' +
                        COPYSTR(rBcoCli.IBAN, 5, 4) + ' ' +
                        COPYSTR(rBcoCli.IBAN, 9, 4) + ' ' +
                        COPYSTR(rBcoCli.IBAN, 13, 2) + ' ' +
                        COPYSTR(rBcoCli.IBAN, 15))
                ELSE
                    wCtaBancoIban := rBcoCli."CCC Bank No." + '-' + rBcoCli."CCC Bank Branch No." + '-' +
                                rBcoCli."CCC Control Digits" + '-' + rBcoCli."CCC Bank Account No.";
                //SetRange(Number,1,1);
                Swift := rBcoCli."SWIFT Code";
                BankNameCaptionLbl := rBcoCli.Name;
                //END;
                //   END;
                //END;
                //
                //FormatAddr.SalesInvShipTo(ShipToAddr,"Sales Invoice Header");

                // MNC 240500
                //ShipToAddr[8] := 'CIF/NIF: ' + Cust."VAT Registration No.";
                FormatAddressFields("Sales Invoice Header");
                FormatDocumentFields("Sales Invoice Header");
                COMPRESSARRAY(ShipToAddr);
                // MNC 240500

                ShowShippingAddr := "Sell-to Customer No." <> "Bill-to Customer No.";
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
                    field(DisplayAsmInformation; DisplayAssemblyInformation)
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
        if Logotipo Then begin
            FormatDocument.SetLogoPosition(SalesSetup."Logo Position on Documents", CompanyInfo1, CompanyInfo2, CompanyInfo3);
            TextoPie := SalesSetup."Texto empresa" + ' ' + SalesSetup."Pie 1 factura";
        end;
        TextoLopd := SalesSetup."Texto 1 LOPD";//+ ' ' + SalesSetup."Texto 2 LOPD" + ' ' + SalesSetup."Texto 3 LOPD" + ' ' + SalesSetup."Texto 4 LOPD" +
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
        CompanyAddr: array[8] of Text[50];
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
        BankNameCaptionLbl: Text;
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
        rLinV: Record 113;
        rRecurs: Record 156;
        TipoCambioDivisa: Record "Currency Exchange Rate";
        rTarea: Record 1001;
        SalesInvCountPrinted: Codeunit 315;
        rContrato: Record 36;
        wFecReg: Date;
        TextoCopia: Text[30];
        HayDto: Text[4];
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
        Swift: Text;
        ShipAd: Boolean;
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
        wTotPre: Decimal;
        Txt002: Label 'No se permite reparto = 1ª fra si se ha generado prepago.\\Debería utilizar reparto = Fra prepago y generar de nuevo el prepago.';
    Begin
        TempSalesLine.DELETEALL;
        CLEAR(TempSalesLine);
        SalesPostPrepmt.GetSalesLines("Sales Invoice Header", 0, TempSalesLine);
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

    local procedure Autrizacion(Var Contrato: Record "Sales Header"): Text
    var
        Nombre: Text;
        DNI: Text;
        Cargo: Text;
        Empresa: Text;
        Direccion: Text;
        CIF: Text;
        Rel: Record "Contact Business Relation";
        Firmante: Record Contact;
    begin
        Rel.SetRange("Link to Table", Rel."Link to Table"::Customer);
        Rel.SetRange("No.", Contrato."Sell-to Customer No.");
        If Not Rel.FindFirst() then begin
            Nombre := '..................................................';
            DNI := '.............';
            Cargo := '.................';
            Empresa := Contrato."Sell-to Customer Name";
            Direccion := Contrato."Sell-to Address";
            Cif := Contrato."VAT Registration No.";
            exit(StrSubstNo('Don/Dña %1 provisto con D.N.I número %2   ,' +
            ' en calidad de %3 de la sociedad %4, con domicilio en %5 y provista de N.I.F. número %6', Nombre, DNI, Cargo, Empresa, Direccion, Cif));
        end;
        Firmante.SetRange("Company No.", Rel."Contact No.");
        Firmante.SetRange(Type, Firmante.Type::Person);
        Firmante.SetRange("Firmante Sepa", TRUE);
        If Firmante.FindFirst() Then begin
            Nombre := Firmante."First Name" + ' ' + Firmante."Middle Name" + ' ' + Firmante.Surname;
            DNI := Firmante."VAT Registration No.";
            Cargo := Firmante."Job Title";
            Empresa := Contrato."Sell-to Customer Name";
            Direccion := Contrato."Sell-to Address";
            Cif := Contrato."VAT Registration No.";
        end else begin
            Nombre := '..................................................';
            DNI := '.............';
            Cargo := '.................';
            Empresa := Contrato."Sell-to Customer Name";
            Direccion := Contrato."Sell-to Address";
            Cif := Contrato."VAT Registration No.";
        end;
        exit(StrSubstNo('Don/Dña %1 provisto con D.N.I número %2   ,' +
        ' en calidad de %3 de la sociedad %4, con domicilio en %5 y provista de N.I.F. número %6', Nombre, DNI, Cargo, Empresa, Direccion, Cif));

    end;

    local procedure Autoriza(Contrato: Text): Text
    var
        Inf: Record "Company Information";
    begin
        Inf.Get();
        exit(StrSubstNo('A la sociedad %1, provista de N.I.F. %2 y con domicilio en %3, en el periodo detallado' +
        ' a continuación, a que gire en el número de cuenta bancaria especificada en el presente documento, todos ' +
        'lo recibos correspondientes al contrato %4 cuyo detalle se relaciona, según lo exigido por la Ley ' +
        '16/2009, de Servicios de Pago', Inf.Name, Inf."VAT Registration No.", Inf.Address, "Sales Invoice Header"."No."));
    end;

    local procedure Firma(Fecha: date): Text
    begin
        exit(StrSubstNo('Confirma el firmante que tiene los poderes suficientes para la firma de ' +
        'la presente autorización.'));

    end;

    local procedure CabFecha(WorkDate: Date): Text
    begin
        exit(StrSubstNo('Palma de Mallorca, a %1', Format(WorkDate, 0, '<Day,2> de <Month Text> de <Year4>')));
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

}

