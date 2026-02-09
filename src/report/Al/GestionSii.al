/// <summary>
/// Report Gestión SII (ID 50014).
/// </summary>
report 50011 "Gestión SII"
{
    // 001 28/04/17 jbakach: Desarrollos.
    // C2 15/06/17 jbakach: Correcciones de diarios generales...
    // SII1 19/06/17 jbakach: Más correcciones
    // SII2 28/06/17 jbakach:  corrección.
    // SII3 28/06/17 jbakach: Correccion.
    // SII4.0 29/06/17 jbakach: Aplicar correcciones.
    // SII5 29/06/17 jbakach: corregir agrupación de IVA al regenerar el documento... Debe hacerlo por VAT ID.
    // SII6 29/06/17 jbakach: Corrección al registrar diarios que no comprobaba que fuera de criterio caja.
    // SII7 03/07/17 dsancho: Correcciones IVA de reversión.
    // SII9 04/07/17 jbakach: Corregir facturas de compra en diarios.
    // SII10 05/07/17
    // SII11 06/07/17
    // SII12 11/07/17 : correcciones para los importes de art 7,14 y reglas localización, dividir en vez de multiplicar abonos de compra
    // SII13 01/08/17 jorta/dcalvache : correciones para facturas con lineas a 0  ( 100% o precio 0)
    //                Hay que añadir las funciones SetCalledFromSII en tabla 113 y 290
    // SII14 17/08/17 jbakach: Parchear agrupación de IVAS, no es necesario, ya que el fichero es correcto aunque tenga 2 líneas con el mismo iva. Esto entra en conflicto cuando hay una línea obviar SII y otras
    //                         y no hay manera posible de controlar a través de la función cuando una línea de VATAmountLine es obviar SII, por falta de campos... De esta manera nos evitamos estos conflictos
    //                         y es igual de correcto.
    // 002 21/09/17 jbakach: Parcheamos la busqueda de la fecha desde los albaranes. Cuando haya importes negativos, no separar la línea (siempre positivo).
    // EXP01 20/10/17 jbakach: Desarrollos para exportación primer semestre...

    Permissions = TableData 112 = rimd,
                  TableData 114 = rimd,
                  TableData 122 = rimd,
                  TableData 124 = rimd,
                  TableData 254 = rimd,
                  TableData 5992 = rimd,
                  TableData 5994 = rimd,
                  tabledata Ficheros = rimd;
    ProcessingOnly = true;

    dataset
    {
        dataitem(VendorLedgerEntry; 25)
        {
            DataItemTableView = SORTING("Entry No.")
                                WHERE("Document Type" = FILTER("Credit Memo" | Invoice));
            RequestFilterFields = "Document No.", "External Document No.", "Posting Date", "Vendor No.";

            trigger OnPreDataItem()
            begin
                //-EXP01
                CurrReport.BREAK;
                //+EXP01
            end;
        }
        dataitem(CustLedgerEntry; "Cust. Ledger Entry")
        {
            DataItemTableView = SORTING("Entry No.")
                                WHERE("Document Type" = FILTER("Credit Memo" | Invoice));
            RequestFilterFields = "Document No.", "Posting Date", "Customer No.";

            trigger OnPreDataItem()
            begin
                //-EXP01
                CurrReport.BREAK;
                //+EXP01
            end;
        }
    }

    requestpage
    {

        layout
        {
            area(content)
            {
                group(Opciones)
                {
                    Caption = 'Opciones';
                    field(ExportOptions; ExportOptions)
                    {
                        ApplicationArea = All;
                        Caption = 'Tipo Exportación';
                    }
                    field(ClaveRegExp; ClaveRegExp)
                    {
                        ApplicationArea = All;
                        Caption = 'Clave registro expedidas';
                    }
                    field(ClaveRegRec; ClaveRegRec)
                    {
                        ApplicationArea = All;
                        Caption = 'Clave registro recibidas';
                    }
                    field(TipoDesglExp; TipoDesglExp)
                    {
                        ApplicationArea = All;
                        Caption = 'Tipo desglose expedidas';
                    }
                    field(SendingProfile; SendingProfile)
                    {
                        ApplicationArea = All;
                        Caption = 'Tipo de envío';
                    }
                    field(TipoDesglRec; TipoDesglRec)
                    {
                        ApplicationArea = All;
                        Caption = 'Tipo desglose recibidas';
                    }
                    field(SujExenta; SujExenta)
                    {
                        ApplicationArea = All;
                        Caption = 'Sujeta Exenta';
                    }
                    field(TipoOper; TipoOper)
                    {
                        ApplicationArea = All;
                        Caption = 'Tipo de operación';
                    }
                    field(DescOper; DescOper)
                    {
                        ApplicationArea = All;
                        Caption = 'Descripción operación';
                    }
                    field(CreateFilePerDocument; CreateFilePerDocument)
                    {
                        ApplicationArea = All;
                        Caption = 'Crear fichero por documento';
                    }
                }
            }
        }

        actions
        {
        }

        trigger OnOpenPage()
        begin
            //-EXP01
            Export := TRUE;
            //+EXP01
        end;
    }

    labels
    {
    }

    trigger OnPreReport()
    begin
        //-SII1
        //-EXP01
        //RegenerarFichero(TipoRegeneracion,DocNumber,DocumType,PostDate,CurreCode);
        //+EXP01
        //+SII1
        //-EXP01
        if Export THEN BEGIN
            GetGLSetup;
            if GLSetup."Activar SII" THEN BEGIN
                if VendorLedgerEntry."Posting Date" <> 0D THEN
                    if (VendorLedgerEntry.GETRANGEMIN("Posting Date") < 20170101D) OR (VendorLedgerEntry.GETRANGEMAX("Posting Date") > 20170630D) THEN
                        ERROR(Text013);
                if CustLedgerEntry."Posting Date" <> 0D THEN
                    if (CustLedgerEntry.GETRANGEMIN("Posting Date") < 20170101D) OR (CustLedgerEntry.GETRANGEMAX("Posting Date") > 20170630D) THEN
                        ERROR(Text013);
                FillTempRecord(TempSelectedRecords);
                if PAGE.RUNMODAL(PAGE::"Customer/Vendor Warnings 349", TempSelectedRecords) = ACTION::LookupOK THEN
                    WriteSelectedDocs(TempSelectedRecords);
            END;
        END;
        //+EXP01
    end;

    var
        RutaFichero: Text[250];
        ins: InStream;
        outs: OutStream;
        TempBLOB: codeunit "Temp Blob";
        HasVAT: Boolean;
        ExistsFile: Boolean;
        GLSetup: Record "General Ledger Setup";
        GLSetupRead: Boolean;
        Text001: Label 'Fichero modificado creado satisfactoriamente.';
        Text002: Label 'Fichero dado de baja creado satisfactoriamente.';
        TipoRegeneracion: Integer;
        DocNumber: Code[20];
        DocumType: Enum "Document Type Kuara";
        PostDate: Date;
        CurreCode: Code[10];
        ClaveRegExp: Code[3];
        ClaveRegRec: Code[3];
        TipoDesglExp: Code[3];
        TipoDesglRec: Code[3];
        TipoOper: Code[3];
        DescOper: Text[250];
        SujExenta: Code[3];
        FromVATPostStp: Boolean;
        IsCust: Boolean;
        Text003: Label 'Se debe informar el campo Clave registro expedidas';
        Text004: Label 'Se debe informar el campo Tipo desglose expedidas';
        Text005: Label 'Se debe informar el campo tipo de operación';
        Text006: Label 'Se debe informar el campo descripción operación';
        Text007: Label 'Se debe informar el campo Clave registro recibidas';
        Text008: Label 'Se debe informar el campo Tipo desglose recibidas';
        Text009: Label 'Se debe informar el campo Sujeta exenta';
        Text010: Label 'Fichero dado de alta creado satisfactoriamente.';
        recTempInmueble: Record "Temp. situación inmueble SII" temporary;
        decBaseACoste: Decimal;
        TextBaseACoste: Text[1024];
        Salir: Boolean;
        Regenerar: Boolean;
        CountryType: Option " ",National,CEE,"3Country";
        "-SII10": Integer;
        g_codeTipoFichero: Code[10];
        "+SII10": Integer;
        "//-EXP01": Integer;
        Export: Boolean;
        ExportOptions: Option Ventas,Compras;
        SendingProfile: Option Alta,"Modificación";
        CreateFilePerDocument: Boolean;
        TempSelectedRecords: Record 10732 temporary;
        "//+EXP01": Integer;
        Text011: Label 'Registro del primer semestre';
        Text012: Label 'Exportación completada con éxito.';
        Text013: Label 'Asegúrese de introducir una fecha de registro dentro del primer semestre.';
        Lenght: Integer;
        a: Integer;
        Ficheros: Record Ficheros temporary;

    local procedure OpenOrCreateFile(TipoFactura: Code[3]; Delete: Boolean): Text[250]
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
        FileToUse: OutStream;
        i: Integer;
        Pos: Integer;
        "año": Text;
        mes: Text;
        dia: Text;
        hora: Text;
        "min": Text;
        sec: Text;
        mili: Text;
    begin
        //-001
        GeneralLedgerSetup.GET;
        GeneralLedgerSetup.TESTFIELD("Ruta fichero SII");
        RutaFichero := GeneralLedgerSetup."Ruta fichero SII";
        i := 1;
        WHILE i < STRLEN(RutaFichero) DO BEGIN
            if RutaFichero[i] = '\' THEN
                Pos := i;
            i += 1;
        END;
        if Pos <> STRLEN(RutaFichero) THEN
            RutaFichero += '\';
        DevolverAnoMesDia(WORKDATE, año, mes, dia);
        SLEEP(100);
        FormatTime(hora, min, sec, mili);
        RutaFichero += COMPANYNAME + '_' + TipoFactura + '_' + dia + mes +
                  COPYSTR(FORMAT(DATE2DMY(WORKDATE, 3)), STRLEN(FORMAT(DATE2DMY(WORKDATE, 3))) - 1, 2) + '_' + hora + min + sec + mili + '.txt';
        // if NOT FileToUse.OPEN(RutaFichero) THEN
        //     FileToUse.CREATE(RutaFichero)
        // ELSE
        //     ExistsFile := TRUE;
        // FileToUse.CLOSE;
        // if Delete THEN
        //     if NOT ExistsFile THEN
        //         ERASE(RutaFichero);
        EXIT(RutaFichero);
        //+001
    end;


    /// <summary>
    /// CreateOrUpdateFileSales.
    /// </summary>
    /// <param name="SalesInvoiceHeader">VAR Record 112.</param>
    /// <param name="SalesCrMemoHeader">VAR Record 114.</param>
    /// <param name="WriteIMPDOC">Boolean.</param>
    procedure CreateOrUpdateFileSales(var SalesInvoiceHeader: Record 112; var SalesCrMemoHeader: Record 114; WriteIMPDOC: Boolean)
    var
        Fichero: OutStream;
        RutaFichero: Text[250];
        TipoIDreceptor: Code[3];
        IDreceptor: Code[20];
        Paisreceptor: Code[10];
        CompanyInformation: Record 79;
        "Año": Text;
        Mes: Text;
        Dia: Text;
        NifReceptor: Code[20];
#pragma warning disable AL0432
        TempVATAmountLines: Record "VAT Amount Line" temporary;
#pragma warning restore AL0432
        TempVatPostStp: Record 325 temporary;
        VatPostStp: Record 325;
        VATBusPostGrp: Record 323;
        IVACaja: Boolean;
        custName: Text[100];
        FechaImputacion: Date;
        AñoImputacion: Text;
        MesImputacion: Text;
        DiaImputacion: Text;
        SalesInvoiceLine: Record 113;
        SalesCrMemoLine: Record 115;
        decImporteIVAincl: Decimal;
        decImporte: Decimal;
        //-EXP01: Integer;
        Description: Text[250];
        Customer: Record Customer;
        Vendor: Record Vendor;
    //+EXP01: Integer;
    begin
        Customer.Init();
        Vendor.Init;
        //-EXP01
        if Export THEN BEGIN
            Description := Text011;
            if CreateFilePerDocument THEN BEGIN
                if SalesInvoiceHeader."No." <> '' THEN
                    DocNumber := SalesInvoiceHeader."No."
                ELSE
                    DocNumber := SalesCrMemoHeader."No.";
            END;
        END;
        //+EXP01
        //-001
        /*if NOT HasVAT THEN
          EXIT;*/
        ExistsFile := FALSE;
        /*if SalesInvoiceHeader."No." <> '' THEN
          IVACaja := CriterioCaja(SalesInvoiceHeader."No.",SalesInvoiceHeader."Posting Date")
        ELSE
          IVACaja := CriterioCaja(SalesCrMemoHeader."No.",SalesCrMemoHeader."Posting Date");
        if IVACaja THEN
          EXIT;*/
        //-jb
        //-SII1
        //-SII10
        if g_codeTipoFichero = '' THEN
            g_codeTipoFichero := 'A0';
        //+SII10
        GetGLSetup;
        //-EXP01
        if NOT Export THEN
            //+EXP01
            if (GLSetup."Exportar SII desde fecha" <> 0D) THEN
                if SalesInvoiceHeader."No." <> '' THEN BEGIN
                    if (SalesInvoiceHeader."Posting Date" < GLSetup."Exportar SII desde fecha") THEN
                        EXIT;
                END ELSE
                    if SalesCrMemoHeader."No." <> '' THEN BEGIN
                        if (SalesCrMemoHeader."Posting Date" < GLSetup."Exportar SII desde fecha") THEN
                            EXIT;
                    END;
        //+SII1
        if (SalesInvoiceHeader."No." <> '') OR (SalesCrMemoHeader."No." <> '') THEN BEGIN
            if SalesInvoiceHeader."No." <> '' Then
                OpenFile(OpenOrCreateFile('FE', FALSE), Fichero, SalesInvoiceHeader."No.", false)
            else
                OpenFile(OpenOrCreateFile('FE', FALSE), Fichero, SalesCrmemoHeader."No.", false);
            GetGLSetup;
            CompanyInformation.GET;
            if Lenght = 0 THEN
                //-SII10
                //WriteNewFile(Fichero,GLSetup,'FE','A0');
                WriteNewFile(Fichero, GLSetup, 'FE', g_codeTipoFichero);
            //+SII10


        END;
        //+jb
        if SalesInvoiceHeader."No." <> '' THEN BEGIN
            /*Si se factura una factura de venta...*/
            //-EXP01
            if SalesInvoiceHeader."Descripción operación" = '' Then SalesInvoiceHeader."Descripción operación" := SalesInvoiceHeader."Posting Description";
            if SalesInvoiceHeader."Tipo factura SII" = '' then
                SalesInvoiceHeader."Tipo factura SII" := 'F1';
            if NOT Export THEN
                Description := SalesInvoiceHeader."Descripción operación";
            if SalesInvoiceHeader."Descripción operación" = '' Then SalesInvoiceHeader."Descripción operación" := SalesInvoiceHeader."Posting Description";
            if SalesInvoiceHeader."Tipo factura SII" = '' then
                SalesInvoiceHeader."Tipo factura SII" := 'F1';
            //+EXP01
            DevolverAnoMesDia(SalesInvoiceHeader."Document Date", Año, Mes, Dia);
            SetTipoIDRecIDRecPaisRecNIFRec(SalesInvoiceHeader."Bill-to Customer No.", TipoIDreceptor, IDreceptor, Paisreceptor,
                                          NifReceptor, custName,
                                          SalesInvoiceHeader."VAT Registration No.", SalesInvoiceHeader."Bill-to Name",
                                          SalesInvoiceHeader."Bill-to Country/Region Code");
            if TipoIDreceptor = '07' THEN BEGIN
                SalesInvoiceHeader."Tipo factura SII" := 'F2';
                NifReceptor := '';
                Paisreceptor := '';
                IDreceptor := '';
            END;
            FechaImputacion := DevolverFechaImp(SalesInvoiceHeader."VAT Bus. Posting Group", SalesInvoiceHeader."Posting Date",
                               SalesInvoiceHeader."Due Date", SalesInvoiceHeader."Document Date", 0, SalesInvoiceHeader."No.");
            DevolverAnoMesDia(FechaImputacion, AñoImputacion, MesImputacion, DiaImputacion);
            Customer.Get(SalesInvoiceHeader."Bill-to Customer No.");
            if TipoIDreceptor = '07' THEN SalesInvoiceHeader."Tipo factura SII" := 'F2';
            WriteNewDoc(Fichero, AñoImputacion, MesImputacion, SalesInvoiceHeader."Tipo factura SII",
                        SalesInvoiceHeader."No.", Año + Mes + Dia, CompanyInformation."VAT Registration No.", CompanyInformation.Name,
                        '', '', '', NifReceptor, custName, TipoIDreceptor, IDreceptor, Paisreceptor, Vendor, Customer);
            SalesInvoiceHeader.CALCFIELDS("Amount Including VAT");
            SalesInvoiceHeader.CALCFIELDS(Amount);
            CLEAR(decImporteIVAincl);
            CLEAR(decImporte);

            SalesInvoiceLine.RESET;
            SalesInvoiceLine.SETRANGE("Document No.", SalesInvoiceHeader."No.");
            if SalesInvoiceLine.FINDFIRST THEN
                REPEAT
                    if (VatPostStp.GET(SalesInvoiceLine."VAT Bus. Posting Group",
                        SalesInvoiceLine."VAT Prod. Posting Group") AND (NOT (VatPostStp."Obviar SII"))) THEN BEGIN
                        decImporteIVAincl += SalesInvoiceLine."Amount Including VAT";
                        decImporte += SalesInvoiceLine.Amount;
                    END;
                    //-SII1
                    if SalesInvoiceLine."Tipo sit. inmueble SII" <> '' THEN BEGIN
                        recTempInmueble.INIT;
                        recTempInmueble."Situación inmueble" := SalesInvoiceLine."Tipo sit. inmueble SII";
                        recTempInmueble."Ref. catastral" := SalesInvoiceLine."Ref. catastral inmueble SII";
                        if recTempInmueble.INSERT THEN;
                    END;
                //+SII1
                UNTIL SalesInvoiceLine.NEXT = 0;
            //-SII1
            if SalesInvoiceHeader."Currency Factor" <> 0 THEN BEGIN
                decImporteIVAincl /= SalesInvoiceHeader."Currency Factor";
                decImporte /= SalesInvoiceHeader."Currency Factor";
            END;
            //+SII1
            VATBusPostGrp.GET(SalesInvoiceHeader."VAT Bus. Posting Group");
            //-EXP01
            if Export THEN BEGIN
                if NOT (VATBusPostGrp."Clave registro SII expedidas" IN ['11', '12', '13']) THEN
                    VATBusPostGrp."Clave registro SII expedidas" := '16';
                if TempSelectedRecords."Situación inmueble" <> '' THEN BEGIN
                    recTempInmueble.INIT;
                    recTempInmueble."Situación inmueble" := TempSelectedRecords."Situación inmueble";
                    recTempInmueble."Ref. catastral" := TempSelectedRecords."Ref. catastral";
                    if recTempInmueble.INSERT THEN;
                END;
            END;
            //+EXP01
            WriteNewINVDOC(Fichero, VATBusPostGrp."Clave registro SII expedidas",
                           //-EXP01
                           //                SalesInvoiceHeader."Descripción operación",AñoImputacion+MesImputacion+DiaImputacion,'',
                           Description, AñoImputacion + MesImputacion + DiaImputacion, '',
                           //+EXP01
                           //ChangeCommaForDot(FORMAT(SalesInvoiceHeader."Amount Including VAT",0,'<Integer><Decimals,3>')),
                           //ChangeCommaForDot(FORMAT(SalesInvoiceHeader.Amount,0,'<Integer><Decimals,3>')));
                           ChangeCommaForDot(FORMAT(decImporteIVAincl, 0, DevolverFormato(SalesInvoiceHeader."Currency Code"))),
                           ChangeCommaForDot(FORMAT(decImporte, 0, DevolverFormato(SalesInvoiceHeader."Currency Code"))));
            CalcVATAmtLines(0, SalesInvoiceHeader."No.", TempVATAmountLines, TempVatPostStp);
            //-SII1
            //aplicamos divisas
            ApplyCurrencyFactor(TempVATAmountLines, SalesInvoiceHeader."Currency Factor");
            decBaseACoste := CalcBaseACoste(TempVATAmountLines);
            TextBaseACoste := ChangeCommaForDot(FORMAT(decBaseACoste, 0, DevolverFormato(SalesInvoiceHeader."Currency Code")));
            if recTempInmueble.FINDFIRST THEN BEGIN
                REPEAT
                    WriteNewIMBDOC(Fichero, recTempInmueble);
                UNTIL recTempInmueble.NEXT = 0;
            END;
            //+SII1
            WriteNewIMPDOC(Fichero, TempVATAmountLines, FALSE, TempVatPostStp, TRUE, 'FE', SalesInvoiceHeader."Currency Code");
            //-SII1
            if WriteIMPDOC THEN
                WriteNewRECDOC(Fichero, TempVATAmountLines, SalesInvoiceHeader."Tipo factura rectificativa", SalesInvoiceHeader."Currency Code");
            //+SII1
            SalesInvoiceHeader."Reportado SII" := TRUE;
            SalesInvoiceHeader."Nombre fichero SII" := RutaFichero;
            SalesInvoiceHeader."Fecha/hora subida fichero SII" := CURRENTDATETIME;
            //-EXP01
            if Export THEN BEGIN
                SalesInvoiceHeader."Reportado SII primer semestre" := TRUE;
                SalesInvoiceHeader."Descripción operación" := Description;
            END;
            //+EXP01
            SalesInvoiceHeader.MODIFY;
            //-jb
            FicheroCLOSE(Fichero);
            //+jb
        END;
        if SalesCrMemoHeader."No." <> '' THEN BEGIN
            /*Si se factura un abono...*/
            //-EXP01
            if SalesCrMemoHeader."Descripción operación" = '' Then SalesCrMemoHeader."Descripción operación" := SalesCrMemoHeader."Posting Description";
            if SalesCrMemoHeader."Tipo factura SII" = '' then
                SalesCrMemoHeader."Tipo factura SII" := 'F1';
            if NOT Export THEN
                Description := SalesCrMemoHeader."Descripción operación"
            ELSE
                SalesCrMemoHeader."Tipo factura SII" := 'F1';
            //+EXP01
            DevolverAnoMesDia(SalesCrMemoHeader."Document Date", Año, Mes, Dia);
            SetTipoIDRecIDRecPaisRecNIFRec(SalesCrMemoHeader."Bill-to Customer No.", TipoIDreceptor, IDreceptor, Paisreceptor,
                                          NifReceptor, custName,
                                          SalesCrMemoHeader."VAT Registration No.", SalesCrMemoHeader."Bill-to Name",
                                          SalesCrMemoHeader."Bill-to Country/Region Code");
            if TipoIDreceptor = '07' THEN BEGIN
                SalesCrMemoHeader."Tipo factura SII" := 'F2';
                NifReceptor := '';
                Paisreceptor := '';
                IDreceptor := '';
            END;
            FechaImputacion := DevolverFechaImp(SalesCrMemoHeader."VAT Bus. Posting Group",
                                SalesCrMemoHeader."Posting Date", SalesCrMemoHeader."Due Date",
                                  SalesCrMemoHeader."Document Date", 1, SalesCrMemoHeader."No.");
            DevolverAnoMesDia(FechaImputacion, AñoImputacion, MesImputacion, DiaImputacion);
            if TipoIDreceptor = '07' THEN SalesCrMemoHeader."Tipo factura SII" := 'F2';
            Customer.Get(SalesCrMemoHeader."Bill-to Customer No.");
            WriteNewDoc(Fichero, AñoImputacion, MesImputacion, SalesCrMemoHeader."Tipo factura SII",
                        SalesCrMemoHeader."No.", Año + Mes + Dia, CompanyInformation."VAT Registration No.", CompanyInformation.Name,
                        '', '', '', NifReceptor, custName, TipoIDreceptor, IDreceptor, Paisreceptor, Vendor, Customer);
            SalesCrMemoHeader.CALCFIELDS("Amount Including VAT");
            SalesCrMemoHeader.CALCFIELDS(Amount);
            CLEAR(decImporteIVAincl);
            CLEAR(decImporte);

            SalesCrMemoLine.RESET;
            SalesCrMemoLine.SETRANGE("Document No.", SalesCrMemoHeader."No.");
            if SalesCrMemoLine.FINDFIRST THEN
                REPEAT
                    if (VatPostStp.GET(SalesCrMemoLine."VAT Bus. Posting Group",
                        SalesCrMemoLine."VAT Prod. Posting Group") AND (NOT (VatPostStp."Obviar SII"))) THEN BEGIN
                        decImporteIVAincl += SalesCrMemoLine."Amount Including VAT";
                        decImporte += SalesCrMemoLine.Amount;
                    END;
                    if decImporteIVAincl = 0 THEN decImporteIVAincl := -0.1;
                    if decImporte = 0 THEN decImporte := -0.1;
                    if SalesCrMemoLine."Tipo sit. inmueble SII" <> '' THEN BEGIN
                        recTempInmueble.INIT;
                        recTempInmueble."Situación inmueble" := SalesCrMemoLine."Tipo sit. inmueble SII";
                        recTempInmueble."Ref. catastral" := SalesCrMemoLine."Ref. catastral inmueble SII";
                        if recTempInmueble.INSERT THEN;
                    END;
                UNTIL SalesCrMemoLine.NEXT = 0;
            //-SII1
            if SalesCrMemoHeader."Currency Factor" <> 0 THEN BEGIN
                decImporteIVAincl /= SalesCrMemoHeader."Currency Factor";
                decImporte /= SalesCrMemoHeader."Currency Factor";
            END;
            //+SII1
            VATBusPostGrp.GET(SalesCrMemoHeader."VAT Bus. Posting Group");
            //-EXP01
            if Export THEN BEGIN
                if NOT (VATBusPostGrp."Clave registro SII expedidas" IN ['11', '12', '13']) THEN
                    VATBusPostGrp."Clave registro SII expedidas" := '16';
                if TempSelectedRecords."Situación inmueble" <> '' THEN BEGIN
                    recTempInmueble.INIT;
                    recTempInmueble."Situación inmueble" := TempSelectedRecords."Situación inmueble";
                    recTempInmueble."Ref. catastral" := TempSelectedRecords."Ref. catastral";
                    if recTempInmueble.INSERT THEN;
                END;
            END;
            //+EXP01
            WriteNewINVDOC(Fichero, VATBusPostGrp."Clave registro SII expedidas",
                           //-EXP01
                           //               SalesCrMemoHeader."Descripción operación",AñoImputacion+MesImputacion+DiaImputacion,'',
                           Description, AñoImputacion + MesImputacion + DiaImputacion, '',
                           //+EXP01
                           //ChangeCommaForDot(FORMAT(-SalesCrMemoHeader."Amount Including VAT",0,'<Sign,1><Integer><Decimals,3>')),
                           //ChangeCommaForDot(FORMAT(-SalesCrMemoHeader.Amount,0,'<Sign,1><Integer><Decimals,3>')));
                           ChangeCommaForDot(FORMAT(-decImporteIVAincl, 0, DevolverFormato(SalesCrMemoHeader."Currency Code"))),
                           ChangeCommaForDot(FORMAT(-decImporte, 0, DevolverFormato(SalesCrMemoHeader."Currency Code"))));
            CalcVATAmtLines(2, SalesCrMemoHeader."No.", TempVATAmountLines, TempVatPostStp);
            //*llamar
            //-SII1
            //aplicamos divisas
            ApplyCurrencyFactor(TempVATAmountLines, SalesCrMemoHeader."Currency Factor");
            decBaseACoste := CalcBaseACoste(TempVATAmountLines);
            TextBaseACoste := ChangeCommaForDot(FORMAT(decBaseACoste, 0, DevolverFormato(SalesInvoiceHeader."Currency Code")));
            if recTempInmueble.FINDFIRST THEN BEGIN
                REPEAT
                    WriteNewIMBDOC(Fichero, recTempInmueble);
                UNTIL recTempInmueble.NEXT = 0;
            END;
            //+SII1
            WriteNewIMPDOC(Fichero, TempVATAmountLines, TRUE, TempVatPostStp, TRUE, 'FE', SalesCrMemoHeader."Currency Code");
            //if SalesCrMemoHeader."Corrected Invoice No." <> '' THEN
            WriteNewRECDOC(Fichero, TempVATAmountLines, SalesCrMemoHeader."Tipo factura rectificativa", SalesCrMemoHeader."Currency Code");

            SalesCrMemoHeader."Reportado SII" := TRUE;
            SalesCrMemoHeader."Nombre fichero SII" := RutaFichero;
            SalesCrMemoHeader."Fecha/hora subida fichero SII" := CURRENTDATETIME;
            //-EXP01
            if Export THEN BEGIN
                SalesCrMemoHeader."Reportado SII primer semestre" := TRUE;
                SalesCrMemoHeader."Descripción operación" := Description;
            END;
            //+EXP01
            SalesCrMemoHeader.MODIFY;
            //-jb
            FicheroCLOSE(Fichero);
            //+jb
        END;
        //+001

    end;

    local procedure WriteNewFile(var Fichero: OutStream; var GLSetup: Record "General Ledger Setup"; TipoFactura: Code[3]; TipoEmision: Text)
    begin
        Lenght := 1;
        //-001
        Fichero.WriteText('remesa_sii');
        Fichero.WriteText();
        Fichero.WriteText('TIP|' + TipoFactura + '|' + TipoEmision + '|' + GLSetup."Nif Titular Registro" + '|' + GLSetup."Nombre Titular Registro");
        //+001: 
    end;

    local procedure WriteNewDoc(var Fichero: OutStream; Ejercicio: Text; Periodo: Text; TipoFac: Code[3]; NumFac: Code[60];
    FechaFac: Text; NifEmisor: Code[20]; NombreEmisor: Text; TipoIdemisor: Code[3]; IDEmisor: Code[20]; PaisEmisor: Code[10];
    NifReceptor: Code[20]; NombreReceptor: Text; TipoIdReceptor: Code[3]; IDReceptor: Code[20]; PaisReceptor: Code[10]; Var Proveedor: Record Vendor; Var Cliente: Record Customer)
    begin
        //-001
        if NifReceptor <> '' THEN
            IDReceptor := '';
        Lenght := 1;
        if (NifReceptor = '') and (IDReceptor = '') Then begin
            if Proveedor."VAT Registration No." <> '' Then NifReceptor := Proveedor."VAT Registration No.";
            if NifReceptor = '' Then if Proveedor."ID emisor" <> '' Then IDReceptor := Proveedor."ID emisor";
        end;
        if (NifEmisor = '') and (IDEmisor = '') Then begin
            if Proveedor."VAT Registration No." <> '' Then NifEmisor := Proveedor."VAT Registration No.";
            if NifEmisor = '' Then if Proveedor."ID emisor" <> '' Then IDEmisor := Proveedor."ID emisor";
        end;
        Fichero.WriteText();
        Fichero.WriteText('DOC|' + Ejercicio + '|' + Periodo +
                      '|' + TipoFac + '|' + NumFac + '||' + FechaFac + '|' + NifEmisor + '|' + NombreEmisor + '|' + /*nif_representante_emisor*/'|' +
                      TipoIdemisor + '|' + IDEmisor + '|' + PaisEmisor + '|' + NifReceptor + '|' + NombreReceptor + '|'
                      /*nif_representante_receptor*/ + '|' +
                      TipoIdReceptor + '|' + IDReceptor + '|' + PaisReceptor);
        //+001

    end;

    local procedure DevolverAnoMesDia(Fecha: Date; var "Año": Text; var Mes: Text; var Dia: Text)
    begin
        //-001
        Año := FORMAT(DATE2DMY(Fecha, 3));
        Mes := FORMAT(DATE2DMY(Fecha, 2));
        if DATE2DMY(Fecha, 2) < 10 THEN
            Mes := '0' + Mes;
        Dia := FORMAT(DATE2DMY(Fecha, 1));
        if DATE2DMY(Fecha, 1) < 10 THEN
            Dia := '0' + Dia;
        //+001
    end;

    local procedure WriteNewINVDOC(var Fichero: OutStream; ClaveReg: Text; DescripcionOper: Text; Fecha: Text; CuotaDeducible: Text; ImporteInclIva: Text; BaseImp: Text)
    var
        "//-EXP01": Integer;
        ClaveAd: Text[100];
        "//+EXP01": Integer;
    begin
        //-001
        if ClaveReg <> '06' THEN
            BaseImp := '';
        //-EXP01
        if Export THEN BEGIN
            if TempSelectedRecords."Clave registro" <> '' THEN
                ClaveReg := TempSelectedRecords."Clave registro";
            if ExportOptions = ExportOptions::Compras THEN BEGIN
                if ClaveReg <> '12' THEN
                    //ClaveAd := '|||14'
                    //ELSE
                    ClaveReg := '14';
            END ELSE
                if NOT (ClaveReg IN ['11', '12', '13']) THEN
                    ClaveReg := '16';
        END;
        Fichero.WriteText();
        Lenght := 1;
        //+EXP01
        Fichero.WriteText('INVDOC|' + ClaveReg + '|' + DescripcionOper + '|' + Fecha + '|' + CuotaDeducible + '|'
                        //-EXP01
                        //+ ImporteInclIva +'|' + BaseImp);
                        + ImporteInclIva + '|' + BaseImp + ClaveAd);
        //+EXP01
        //+001
    end;
#pragma warning disable AL0432
    local procedure WriteNewIMPDOC(var Fichero: OutStream; var VATAmountLines: Record "VAT Amount Line" temporary; ImporteEnNegativo: Boolean; var TempVatPostStp: Record 325 temporary; Sale: Boolean; TipoFactura: Text; CurrCode: Code[10])
#pragma warning restore AL0432
    var
        VATPostingSetup: Record 325;
        importe_art_otros: Decimal;
        importe_reglas_loc: Decimal;
        Formato: Text;
        PorcEc: Text;
        EcAmt: Text;
        Barrita: Text;
        TipoDesgl: Code[3];
        TipoOperacion: Code[3];
        DescOperacion: Text[250];
        SujetaExenta: Code[3];
        importe_art_otrostxt: Text;
        importe_reglas_loctxt: Text;
        Sign: Integer;
        Precision: Decimal;
    begin
        //-001
        VATAmountLines.RESET;
        if VATAmountLines.FINDSET THEN BEGIN
            REPEAT
                TempVatPostStp.SETRANGE("VAT Identifier", VATAmountLines."VAT Identifier");
                if TempVatPostStp.FINDFIRST THEN;
                if TempVatPostStp."VAT Cash Regime" AND ((TipoFactura = 'CE') OR (TipoFactura = 'PR')) THEN
                    EXIT;
                if NOT TempVatPostStp."Obviar SII" THEN BEGIN
                    //-SII1
                    //if TipoFactura = 'FR' THEN BEGIN
                    //TempVatPostStp."Tipo de operación" := '';
                    //TempVatPostStp."Sujeta exenta" := '';
                    //END;
                    if FromVATPostStp OR (NOT Regenerar) THEN BEGIN
                        if Sale THEN
                            TipoDesgl := TempVatPostStp."Tipo desglose emitidas"
                        ELSE
                            TipoDesgl := TempVatPostStp."Tipo desglose recibidas";
                        TipoOperacion := TempVatPostStp."Tipo de operación";
                        SujetaExenta := TempVatPostStp."Sujeta exenta";
                    END ELSE BEGIN
                        if Sale THEN BEGIN
                            TipoDesgl := TipoDesglExp;
                            TipoDesglRec := ''
                        END ELSE BEGIN
                            TipoDesgl := TipoDesglRec;
                            TipoDesglExp := '';
                        END;
                        TipoOperacion := TipoOper;
                        SujetaExenta := SujExenta;
                    END;
                    /*mirar que esto este ok*/
                    if TipoDesgl = '' THEN
                        if Sale THEN
                            TipoDesgl := TempVatPostStp."Tipo desglose emitidas"
                        ELSE
                            TipoDesgl := TempVatPostStp."Tipo desglose recibidas";
                    if TipoOperacion = '' THEN
                        TipoOperacion := TempVatPostStp."Tipo de operación";
                    if SujetaExenta = '' THEN
                        SujetaExenta := TempVatPostStp."Sujeta exenta";
                    /*hasta aqui*/
                    if TipoFactura = 'FR' THEN BEGIN
                        TipoOperacion := '';
                        SujetaExenta := '';
                    END;
                    //+SII1
                    //-EXP01
                    //todas las no exentas las pasamos como S1...
                    if Export THEN
                        if TipoFactura = 'FE' THEN BEGIN
                            SujetaExenta := 'NE';
                            TipoOperacion := 'S1';
                        END;
                    //+EXP01
                    Formato := DevolverFormato(CurrCode);
                    CLEAR(PorcEc);
                    CLEAR(EcAmt);
                    if VATAmountLines."EC %" <> 0 THEN BEGIN
                        Barrita := '|';
                        if NOT ImporteEnNegativo THEN BEGIN
                            PorcEc := FORMAT(VATAmountLines."EC %", 0, Formato);
                            EcAmt := FORMAT(VATAmountLines."EC Amount", 0, Formato);
                        END ELSE BEGIN
                            //-SII2
                            //PorcEc := FORMAT(-VATAmountLines."EC %",0,Formato);
                            PorcEc := FORMAT(VATAmountLines."EC %", 0, Formato);
                            //+SII2
                            EcAmt := FORMAT(-VATAmountLines."EC Amount", 0, Formato);
                        END;
                    END;

                    if TipoFactura = 'FE' THEN BEGIN
                        //-SII1
                        //if TempVatPostStp."Sujeta exenta" = 'E' THEN BEGIN

                        if SujetaExenta = 'E' THEN BEGIN
                            //+SII1
                            Fichero.WriteText();
                            Lenght := 1;
                            if NOT ImporteEnNegativo THEN
                                //-SII1
                                //Fichero.AddText('IMPDOC|' + TempVatPostStp."Tipo desglose emitidas" + '|' + TempVatPostStp."Sujeta exenta" + '|' +

                                Fichero.WriteText('IMPDOC|' + TipoDesgl + '|' + SujetaExenta + '|' +
                                  //              TempVatPostStp."Tipo de operación" + '|' +
                                  TipoOperacion + '|' +
                                  //+SII1
                                  ChangeCommaForDot(FORMAT(VATAmountLines."VAT Base", 0, Formato)) + '|'
                                  + Barrita + PorcEc + Barrita +
                                  ChangeCommaForDot(EcAmt))
                            ELSE
                                //-SII1
                                //Fichero.AddText('IMPDOC|' + TempVatPostStp."Tipo desglose emitidas" + '|' + TempVatPostStp."Sujeta exenta"
                                Fichero.WriteText('IMPDOC|' + TipoDesgl + '|' + SujetaExenta
                                  //              + '|' + TempVatPostStp."Tipo de operación" + '|' +
                                  + '|' + TipoOperacion + '|' +
                                  //+SII1
                                  ChangeCommaForDot(FORMAT(-VATAmountLines."VAT Base", 0, Formato))
                                  + Barrita + PorcEc + Barrita +
                                  ChangeCommaForDot(EcAmt));
                            //-SII1
                            //END ELSE if TempVatPostStp."Sujeta exenta" = 'NS' THEN BEGIN
                        END ELSE
                            if SujetaExenta = 'NS' THEN BEGIN
                                //-SII12
                                if ImporteEnNegativo THEN
                                    Sign := -1
                                ELSE
                                    Sign := 1;
                                //+SII12
                                if TipoOperacion = 'N1' THEN
                                    importe_art_otros := VATAmountLines."VAT Base";
                                if TipoOperacion = 'N2' THEN
                                    importe_reglas_loc := VATAmountLines."VAT Base";
                                if importe_art_otros <> 0 THEN
                                    //-SII12
                                    //importe_art_otrostxt := ChangeCommaForDot(FORMAT(importe_art_otros,0,Formato));
                                    importe_art_otrostxt := ChangeCommaForDot(FORMAT(importe_art_otros * Sign, 0, Formato));
                                //+SII12
                                if importe_reglas_loc <> 0 THEN
                                    //-SII12
                                    //importe_reglas_loctxt := ChangeCommaForDot(FORMAT(importe_reglas_loc,0,Formato));
                                    importe_reglas_loctxt := ChangeCommaForDot(FORMAT(importe_reglas_loc * Sign, 0, Formato));
                                //+SII12
                                //+SII1
                                Fichero.WriteText();
                                Lenght := 1;
                                if NOT ImporteEnNegativo THEN
                                    //-SII1
                                    //Fichero.AddText('IMPDOC|' + TempVatPostStp."Tipo desglose emitidas" + '|' + TempVatPostStp."Sujeta exenta" + '||||'+
                                    Fichero.WriteText('IMPDOC|' + TipoDesgl + '|' + SujetaExenta + '||||' +
                                  //+SII1
                                  FORMAT(PorcEc)
                                  + '|' + ChangeCommaForDot(EcAmt)
                                  //-SII12
                                  //+ '|||||'+ importe_art_otrostxt  +
                                  + '||||' + importe_art_otrostxt + '|' +
                                  //+SII12
                                  importe_reglas_loctxt)
                                ELSE
                                    //-SII1
                                    //Fichero.AddText('IMPDOC|' + TempVatPostStp."Tipo desglose emitidas" + '|' + TempVatPostStp."Sujeta exenta" + '||||'+
                                    Fichero.WriteText('IMPDOC|' + TipoDesgl + '|' + SujetaExenta + '||||' +
                                  //+SII1
                                  FORMAT(PorcEc)
                                  + '|' + ChangeCommaForDot(EcAmt)
                                  //-SII12
                                  //+ '|||||'+ importe_art_otrostxt +
                                  + '||||' + importe_art_otrostxt + '|' +
                                  //+SII12
                                  importe_reglas_loctxt)
                            END;
                    END;
                    if (TipoFactura = 'FE') OR (TipoFactura = 'FR') THEN BEGIN
                        //-SII1

                        //if (TempVatPostStp."Sujeta exenta" = 'NE') OR (TipoFactura = 'FR') THEN BEGIN
                        if (SujetaExenta = 'NE') OR (TipoFactura = 'FR') THEN BEGIN
                            //+SII1
                            Fichero.WriteText();
                            Lenght := 1;
                            Precision := 1;
                            if Round(VATAmountLines."VAT %", Precision) = VATAmountLines."VAT %" THEN
                                Precision := 0.01;
                            if NOT ImporteEnNegativo THEN
                                //-SII1
                                //Fichero.AddText('IMPDOC|' + TempVatPostStp."Tipo desglose emitidas" + '|' + TempVatPostStp."Sujeta exenta" + '|' +
                                Fichero.WriteText('IMPDOC|' + TipoDesgl + '|' + SujetaExenta + '|' +
                                  //              TempVatPostStp."Tipo de operación"
                                  TipoOperacion
                                  //+SII1
                                  + '|' + ChangeCommaForDot(FORMAT(VATAmountLines."VAT Base", 0, Formato)) + '|' +
                                  ChangeCommaForDot(FORMAT(VATAmountLines."VAT Amount", 0, Formato)) +
                                  '|' + FORMAT(ROUND(VATAmountLines."VAT %", Precision)) + Barrita + PorcEc + Barrita +
                                   ChangeCommaForDot(EcAmt))
                            ELSE
                                //-SII1
                                //Fichero.AddText('IMPDOC|' + TempVatPostStp."Tipo desglose emitidas" + '|' + TempVatPostStp."Sujeta exenta" + '|' +
                                Fichero.WriteText('IMPDOC|' + TipoDesgl + '|' + SujetaExenta + '|' +
                                 //              TempVatPostStp."Tipo de operación" + '|' +
                                 TipoOperacion + '|' +
                                 //+SII1
                                 ChangeCommaForDot(FORMAT(-VATAmountLines."VAT Base", 0, Formato)) +
                                 '|' + ChangeCommaForDot(FORMAT(-VATAmountLines."VAT Amount", 0, Formato)) +
                                 '|' + FORMAT(ROUND(VATAmountLines."VAT %", Precision)) + Barrita + FORMAT(PorcEc) + Barrita +
                                 ChangeCommaForDot(EcAmt));
                        END;
                    END;
                END;
            UNTIL VATAmountLines.NEXT = 0;
        END ELSE BEGIN
            Fichero.WriteText();
            Lenght := 1;
            Fichero.WriteText('IMPDOC|PS|NE|S1|0.00|0.00|10');

        END;
        //+001

    end;

#pragma warning disable AL0432
    local procedure WriteNewRECDOC(var Fichero: OutStream; var VATAmountLines: Record "VAT Amount Line" Temporary; TipoFacturaRectificativa: Code[3]; CurrCode: Code[10])
#pragma warning restore AL0432
    var
        VATBase: Decimal;
        LineAmt: Decimal;
    begin
        VATAmountLines.RESET;
        if VATAmountLines.FINDSET THEN
            REPEAT
                VATBase += VATAmountLines."VAT Base";
                //if VATAmountLines."Line Amount" = 0 THEN
                //-SII1
                //  LineAmt += VATAmountLines."VAT Amount";
                LineAmt += VATAmountLines."VAT Amount" + VATAmountLines."EC Amount";
            //+SII1
            //ELSE
            //  LineAmt += VATAmountLines."Line Amount";
            UNTIL VATAmountLines.NEXT = 0;
        //-SII1
        //if TipoFacturaRectificativa = 'S' THEN BEGIN
        if TipoFacturaRectificativa = 'I' THEN BEGIN
            //+SII1
            VATBase := 0;
            LineAmt := 0;
        END;
        Fichero.WriteText();
        Lenght := 1;
        Fichero.WriteText('RECDOC|' + TipoFacturaRectificativa + '|' + ChangeCommaForDot(FORMAT(VATBase, 0, DevolverFormato(CurrCode))) + '|'
                            + ChangeCommaForDot(FORMAT(LineAmt, 0, DevolverFormato(CurrCode))));
    end;

#pragma warning disable AL0432
    local procedure CalcVATAmtLines(DocType: Option "Factura venta","Factura compra","Abono venta","Abono compra","Factura servicio","Abono servicio"; DocNo: Code[20]; var VATAmountLines: Record "VAT Amount Line" Temporary; var TempVatPostStp: Record 325 temporary)
#pragma warning restore AL0432
    var
        SalesInvoiceLine: Record 113;
        SalesInvoiceHeader: Record 112;
        PurchInvLine: Record 123;
        PurchInvHeader: Record "Purch. Inv. Header";
        SalesCrMemoHeader: Record 114;
        SalesCrMemoLine: Record 115;
        PurchCrMemoHdr: Record "Purch. Cr. Memo Hdr.";
        PurchCrMemoLine: Record 125;
        GenJournalLine: Record "Gen. Journal Line";
        VATPostingSetup: Record 325;
        ServiceInvoiceLine: Record 5993;
        ServiceInvoiceHeader: Record 5992;
        ServiceCrMemoHeader: Record 5994;
        ServiceCrMemoLine: Record 5995;
        Empty: Text[250];
    begin
        //-001
        //-002
        //VATAmountLines.AlwaysPositive;
        //+002
        CASE DocType OF
            DocType::"Factura venta":
                BEGIN
                    SalesInvoiceLine.SETRANGE("Document No.", DocNo);
                    SalesInvoiceHeader.GET(DocNo);
                    SalesInvoiceLine.CalcVATAmountLines(SalesInvoiceHeader, VATAmountLines);
                    if SalesInvoiceLine.FINDSET THEN
                        REPEAT
                            if VATPostingSetup.GET(SalesInvoiceHeader."VAT Bus. Posting Group", SalesInvoiceLine."VAT Prod. Posting Group") THEN;
                            //-002
                            SalesInvoiceHeader.CALCFIELDS("Amount Including VAT");
                            if SalesInvoiceHeader."Amount Including VAT" = 0 THEN BEGIN
                                VATAmountLines.SETRANGE("VAT Identifier", VATPostingSetup."VAT Identifier");
                                if NOT VATAmountLines.FINDFIRST THEN BEGIN
                                    VATAmountLines."VAT Identifier" := VATPostingSetup."VAT Identifier";
                                    VATAmountLines."VAT %" := VATPostingSetup."VAT %";
                                    VATAmountLines."VAT Base" := SalesInvoiceLine.Amount;
                                    VATAmountLines."VAT Amount" := VATAmountLines."VAT Base" * (VATAmountLines."VAT %" / 100);
                                    VATAmountLines."VAT Calculation Type" := VATPostingSetup."VAT Calculation Type";
                                    VATAmountLines.INSERT;
                                END;
                            END;
                            //+002
                            //-EXP01
                            if Export THEN
                                NoConflictInDocument(TRUE, SalesInvoiceLine."Document No.", SalesInvoiceLine."VAT Bus. Posting Group",
                                                     SalesInvoiceLine."VAT Prod. Posting Group", Empty);
                            //+EXP01
                            TempVatPostStp := VATPostingSetup;
                            if TempVatPostStp.INSERT THEN;
                        UNTIL SalesInvoiceLine.NEXT = 0;
                END;
            DocType::"Factura compra":
                BEGIN
                    PurchInvLine.SETRANGE("Document No.", DocNo);
                    PurchInvHeader.GET(DocNo);
                    PurchInvLine.CalcVATAmountLines(PurchInvHeader, VATAmountLines);
                    if PurchInvLine.FINDSET THEN
                        REPEAT
                            //-EXP01
                            if Export THEN
                                NoConflictInDocument(TRUE, PurchInvLine."Document No.", PurchInvLine."VAT Bus. Posting Group",
                                                      PurchInvLine."VAT Prod. Posting Group", Empty);
                            //+EXP01
                            if VATPostingSetup.GET(PurchInvHeader."VAT Bus. Posting Group", PurchInvLine."VAT Prod. Posting Group") THEN BEGIN
                                //-SII10
                                if VATPostingSetup."VAT Calculation Type" = VATPostingSetup."VAT Calculation Type"::"Reverse Charge VAT" THEN BEGIN
                                    VATAmountLines.SETRANGE("VAT Identifier", VATPostingSetup."VAT Identifier");
                                    if VATAmountLines.FINDFIRST THEN
                                        REPEAT
                                            //if VATAmountLines."VAT Calculation Type" = VATAmountLines."VAT Calculation Type"::"Reverse Charge VAT" then
                                            //  VATAmountLines."VAT %" := 0 else
                                            VATAmountLines."VAT %" := VATPostingSetup."VAT %";
                                            VATAmountLines."VAT Amount" := VATAmountLines."VAT Base" * (VATAmountLines."VAT %" / 100);
                                            //if VATPostingSetup."Grupo prorrateo" <> '' THEN
                                            //  VATAmountLines.Deducible := VATAmountLines."VAT Amount" * (VATAmountLines."% Prorrateo"/100)
                                            //ELSE
                                            //  VATAmountLines.Deducible := VATAmountLines."VAT Amount";
                                            VATAmountLines.MODIFY;
                                        UNTIL VATAmountLines.NEXT = 0;
                                END;
                                //-002
                                PurchInvHeader.CALCFIELDS("Amount Including VAT");
                                if PurchInvHeader."Amount Including VAT" = 0 THEN BEGIN
                                    VATAmountLines.SETRANGE("VAT Identifier", VATPostingSetup."VAT Identifier");
                                    if NOT VATAmountLines.FINDFIRST THEN BEGIN
                                        VATAmountLines."VAT Identifier" := VATPostingSetup."VAT Identifier";
                                        VATAmountLines."VAT %" := VATPostingSetup."VAT %";
                                        VATAmountLines."VAT Base" := SalesInvoiceLine.Amount;
                                        VATAmountLines."VAT Amount" := VATAmountLines."VAT Base" * (VATAmountLines."VAT %" / 100);
                                        VATAmountLines."VAT Calculation Type" := VATPostingSetup."VAT Calculation Type";
                                        VATAmountLines.INSERT;
                                    END;
                                END;
                                //+002
                                VATAmountLines.RESET;
                                //+SII10
                            END;
                            TempVatPostStp := VATPostingSetup;
                            if TempVatPostStp.INSERT THEN;
                        UNTIL PurchInvLine.NEXT = 0;
                END;
            DocType::"Abono venta":
                BEGIN
                    SalesCrMemoLine.SETRANGE("Document No.", DocNo);
                    SalesCrMemoHeader.GET(DocNo);
                    SalesCrMemoLine.CalcVATAmountLines(SalesCrMemoHeader, VATAmountLines);
                    if SalesCrMemoLine.FINDSET THEN
                        REPEAT
                            //-EXP01
                            if Export THEN
                                NoConflictInDocument(TRUE, SalesCrMemoLine."Document No.", SalesCrMemoLine."VAT Bus. Posting Group",
                                                      SalesCrMemoLine."VAT Prod. Posting Group", Empty);
                            //+EXP01
                            if VATPostingSetup.GET(SalesCrMemoHeader."VAT Bus. Posting Group", SalesCrMemoLine."VAT Prod. Posting Group") THEN;
                            TempVatPostStp := VATPostingSetup;
                            if TempVatPostStp.INSERT THEN;
                        UNTIL SalesCrMemoLine.NEXT = 0;
                END;
            DocType::"Abono compra":
                BEGIN
                    PurchCrMemoLine.SETRANGE("Document No.", DocNo);
                    PurchCrMemoHdr.GET(DocNo);
                    PurchCrMemoLine.CalcVATAmountLines(PurchCrMemoHdr, VATAmountLines);
                    if PurchCrMemoLine.FINDSET THEN
                        REPEAT
                            //-EXP01
                            if Export THEN
                                NoConflictInDocument(TRUE, PurchCrMemoLine."Document No.", PurchCrMemoLine."VAT Bus. Posting Group",
                                                      PurchCrMemoLine."VAT Prod. Posting Group", Empty);
                            //+EXP01
                            //-SII10
                            //if VATPostingSetup.GET(PurchCrMemoHdr."VAT Bus. Posting Group",PurchCrMemoLine."VAT Prod. Posting Group") THEN ;
                            if VATPostingSetup.GET(PurchCrMemoHdr."VAT Bus. Posting Group", PurchCrMemoLine."VAT Prod. Posting Group") THEN BEGIN
                                if VATPostingSetup."VAT Calculation Type" = VATPostingSetup."VAT Calculation Type"::"Reverse Charge VAT" THEN BEGIN
                                    VATAmountLines.SETRANGE("VAT Identifier", VATPostingSetup."VAT Identifier");
                                    if VATAmountLines.FINDFIRST THEN
                                        REPEAT
                                            // if VATAmountLines."VAT Calculation Type" = VATAmountLines."VAT Calculation Type"::"Reverse Charge VAT" then
                                            //   VATAmountLines."VAT %" := 0 else
                                            VATAmountLines."VAT %" := VATPostingSetup."VAT %";
                                            VATAmountLines."VAT Amount" := VATAmountLines."VAT Base" * (VATAmountLines."VAT %" / 100);
                                            //if VATPostingSetup."Grupo prorrateo" <> '' THEN
                                            //  VATAmountLines.Deducible := VATAmountLines."VAT Amount" * (VATAmountLines."% Prorrateo"/100)
                                            //ELSE
                                            //  VATAmountLines.Deducible := VATAmountLines."VAT Amount";
                                            VATAmountLines.MODIFY;
                                        UNTIL VATAmountLines.NEXT = 0;
                                END;
                                VATAmountLines.RESET;
                            END;
                            //+SII10
                            TempVatPostStp := VATPostingSetup;
                            if TempVatPostStp.INSERT THEN;
                        UNTIL PurchCrMemoLine.NEXT = 0;
                END;
            DocType::"Factura servicio":
                BEGIN
                    ServiceInvoiceLine.SETRANGE("Document No.", DocNo);
                    ServiceInvoiceHeader.GET(DocNo);
                    ServiceInvoiceLine.CalcVATAmountLines(ServiceInvoiceHeader, VATAmountLines);
                    if ServiceInvoiceLine.FINDSET THEN
                        REPEAT
                            //-EXP01
                            if Export THEN
                                NoConflictInDocument(TRUE, ServiceInvoiceLine."Document No.", ServiceInvoiceLine."VAT Bus. Posting Group",
                                                      ServiceInvoiceLine."VAT Prod. Posting Group", Empty);
                            //+EXP01
                            if VATPostingSetup.GET(ServiceInvoiceHeader."VAT Bus. Posting Group", ServiceInvoiceLine."VAT Prod. Posting Group") THEN;
                            //-002
                            if ServiceInvoiceLine."Amount Including VAT" = 0 THEN BEGIN
                                VATAmountLines.SETRANGE("VAT Identifier", VATPostingSetup."VAT Identifier");
                                if NOT VATAmountLines.FINDFIRST THEN BEGIN
                                    VATAmountLines."VAT Identifier" := VATPostingSetup."VAT Identifier";
                                    VATAmountLines."VAT %" := VATPostingSetup."VAT %";
                                    VATAmountLines."VAT Base" := ServiceInvoiceLine.Amount;
                                    VATAmountLines."VAT Amount" := VATAmountLines."VAT Base" * (VATAmountLines."VAT %" / 100);
                                    VATAmountLines."VAT Calculation Type" := VATPostingSetup."VAT Calculation Type";
                                    VATAmountLines.INSERT;
                                END;
                            END;
                            //+002
                            TempVatPostStp := VATPostingSetup;
                            if TempVatPostStp.INSERT THEN;
                        UNTIL ServiceInvoiceLine.NEXT = 0;
                END;
            DocType::"Abono servicio":
                BEGIN
                    ServiceCrMemoLine.SETRANGE("Document No.", DocNo);
                    ServiceCrMemoHeader.GET(DocNo);
                    ServiceCrMemoLine.CalcVATAmountLines(ServiceCrMemoHeader, VATAmountLines);
                    if ServiceCrMemoLine.FINDSET THEN
                        REPEAT
                            //-EXP01
                            if Export THEN
                                NoConflictInDocument(TRUE, ServiceCrMemoLine."Document No.", ServiceCrMemoLine."VAT Bus. Posting Group",
                                                      ServiceCrMemoLine."VAT Prod. Posting Group", Empty);
                            //+EXP01
                            if VATPostingSetup.GET(ServiceCrMemoHeader."VAT Bus. Posting Group", ServiceCrMemoLine."VAT Prod. Posting Group") THEN;
                            TempVatPostStp := VATPostingSetup;
                            if TempVatPostStp.INSERT THEN;
                        UNTIL ServiceCrMemoLine.NEXT = 0;
                END;
        END;
        //+001
    end;

    local procedure GetGLSetup()
    begin
        if NOT GLSetupRead THEN
            GLSetup.GET;
        GLSetupRead := TRUE;
    end;


    /// <summary>
    /// CheckSalesRequiredFields.
    /// </summary>
    /// <param name="SalesHeader">VAR Record 36.</param>
    /// <param name="ModifyHdr">VAR Boolean.</param>
    /// <summary>
    /// CheckSalesRequiredFields.
    /// </summary>
    /// <param name="SalesHeader">VAR Record 36.</param>
    /// <param name="ModifyHdr">VAR Boolean.</param>
    procedure CheckSalesRequiredFields(var SalesHeader: Record 36; var ModifyHdr: Boolean)
    var
        SalesLine: Record 37;
        VATPostingSetup: Record 325;
        IVACaja: Boolean;
        VATBusPostGrp: Record 323;
    begin
        //-001
        HasVAT := FALSE;
        GetGLSetup;
        //-SII1
        if (GLSetup."Exportar SII desde fecha" <> 0D) THEN
            if (SalesHeader."Posting Date" < GLSetup."Exportar SII desde fecha") THEN
                EXIT;
        //+SII1
        SalesLine.SETRANGE("Document No.", SalesHeader."No.");
        SalesLine.SETRANGE("Document Type", SalesHeader."Document Type");
        SalesLine.FINDSET;
        REPEAT
            if SalesLine.Type <> SalesLine.Type::" " THEN BEGIN
                VATPostingSetup.GET(SalesLine."VAT Bus. Posting Group", SalesLine."VAT Prod. Posting Group");
                VATBusPostGrp.GET(VATPostingSetup."VAT Bus. Posting Group");
                HasVAT := PreviousSalesChecks(VATPostingSetup, SalesHeader, VATBusPostGrp);
            END;
        UNTIL (SalesLine.NEXT = 0);
        /*if NOT HasVAT THEN
          EXIT;*/
        //-SII1
        ModifyHdr := SalesHeader.UpdateFieldsSII;
        //+SII1
        IVACaja := CriterioCaja(SalesHeader."No.", SalesHeader."Posting Date");
        if NOT IVACaja THEN BEGIN
            SalesHeader.TESTFIELD("Descripción operación");
            VATBusPostGrp.TESTFIELD("Clave registro SII expedidas");
        END;
        PreviousSalesHdrChecks(SalesHeader, IVACaja);
        //+001

    end;


    /// <summary>
    /// PreviousSalesChecks.
    /// </summary>
    /// <param name="VATPostingSetup">VAR Record 325.</param>
    /// <param name="SalesHeader">VAR Record 36.</param>
    /// <param name="VATBusPostGrp">VAR Record 323.</param>
    /// <returns>Return value of type Boolean.</returns>
    procedure PreviousSalesChecks(var VATPostingSetup: Record 325; var SalesHeader: Record 36; var VATBusPostGrp: Record 323): Boolean
    begin
        //-001
        //if VATPostingSetup."VAT Calculation Type" <> VATPostingSetup."VAT Calculation Type"::"No Taxable VAT" THEN BEGIN
        VATPostingSetup.TESTFIELD("Sujeta exenta");
        if VATPostingSetup."Tipo de operación" <> 'NS' THEN
            VATPostingSetup.TESTFIELD("Tipo de operación");
        VATPostingSetup.TESTFIELD("Tipo desglose emitidas");
        EXIT(TRUE);
        //END;
        //EXIT(FALSE);
        //+001
    end;


    /// <summary>
    /// GetHasVAT.
    /// </summary>
    /// <returns>Return value of type Boolean.</returns>
    procedure GetHasVAT(): Boolean
    begin
        EXIT(HasVAT);
    end;


    /// <summary>
    /// CreateOrUpdateFilePurch.
    /// </summary>
    /// <param name="PurchInvHeader">VAR Record 122.</param>
    /// <param name="PurchCrMemoHeader">VAR Record 124.</param>
    /// <param name="WriteIMPDOC">Boolean.</param>
    procedure CreateOrUpdateFilePurch(var PurchInvHeader: Record "Purch. Inv. Header"; var PurchCrMemoHeader: Record "Purch. Cr. Memo Hdr."; WriteIMPDOC: Boolean)
    var
        Fichero: OutStream;
        RutaFichero: Text[250];
        TipoIDEmisor: Code[3];
        IDEmisor: Code[20];
        PaisEmisor: Code[10];
        CompanyInformation: Record 79;
        "Año": Text;
        Mes: Text;
        Dia: Text;
        NifReceptor: Code[20];
#pragma warning disable AL0432
        TempVATAmountLines: Record "VAT Amount Line" Temporary;
#pragma warning restore AL0432
        TempVatPostStp: Record 325 temporary;
        VATBusPostGrp: Record 323;
        CuotaDeducible: Decimal;
        TextCuotaDeducible: Text;
        IVACaja: Boolean;
        VendName: Text[100];
        VatNo: Text;
        FechaImputacion: Date;
        "AñoImputacion": Text;
        MesImputacion: Text;
        DiaImputacion: Text;
        decImporteIVAincl: Decimal;
        decImporte: Decimal;
        PurchInvoiceLine: Record 123;
        PurchCrMemoLine: Record 125;
        VatPostStp: Record 325;
        "AñoOperacion": Text;
        MesOperacion: Text;
        DiaOperacion: Text;
        "-SII10": Integer;
        txtDescOperacion: Text;
        "+SII10": Integer;
        "//-EXP01": Integer;
        Description: Text[250];
        "//+EXP01": Integer;
        Customer: Record Customer;
        Vendor: Record Vendor;
    begin
        Vendor.Init;
        Customer.Init;
        //-001
        //-EXP01
        if Export THEN BEGIN
            Description := Text011;
            if CreateFilePerDocument THEN BEGIN
                if (PurchInvHeader."No." <> '') THEN
                    DocNumber := PurchInvHeader."No."
                ELSE
                    DocNumber := PurchCrMemoHeader."No.";
            END;
        END;
        //+EXP01
        ExistsFile := FALSE;
        //-SII1
        // -SII10
        if g_codeTipoFichero = '' THEN
            g_codeTipoFichero := 'A0';
        // + SII10
        GetGLSetup;
        //-EXP01
        if NOT Export THEN
            //+EXP01
            if (GLSetup."Exportar SII desde fecha" <> 0D) THEN
                if PurchInvHeader."No." <> '' THEN BEGIN
                    if (PurchInvHeader."Posting Date" < GLSetup."Exportar SII desde fecha") THEN
                        EXIT;
                END ELSE
                    if PurchCrMemoHeader."No." <> '' THEN BEGIN
                        if (PurchCrMemoHeader."Posting Date" < GLSetup."Exportar SII desde fecha") THEN
                            EXIT;
                    END;
        //+SII1
        if (PurchInvHeader."No." <> '') THEN BEGIN

            OpenFile(OpenOrCreateFile('FR', FALSE), Fichero, PurchInvHeader."No.", false);
            GetGLSetup;
            CompanyInformation.GET;
            // if Fichero.Length <> 0 THEN
            //-SII10
            //WriteNewFile(Fichero,GLSetup,'FR','A0');
            WriteNewFile(Fichero, GLSetup, 'FR', g_codeTipoFichero);
            //+SII10
        END;
        if (PurchCrMemoHeader."No." <> '') THEN BEGIN
            OpenFile(OpenOrCreateFile('FR', FALSE), Fichero, PurchCrMemoHeader."No.", false);
            GetGLSetup;
            CompanyInformation.GET;
            // if Fichero.Length <> 0 THEN
            //-SII10
            //WriteNewFile(Fichero,GLSetup,'FR','A0');
            WriteNewFile(Fichero, GLSetup, 'FR', g_codeTipoFichero);
            //+SII10
        END;

        if PurchInvHeader."No." <> '' THEN BEGIN
            //-c1
            //-SII1
            //DevolverAnoMesDia(TODAY,Año,Mes,Dia);
            DevolverAnoMesDia(PurchInvHeader."Document Date", Año, Mes, Dia);
            DevolverAnoMesDia(TODAY, AñoOperacion, MesOperacion, DiaOperacion);
            //+SII1
            //+c1
            SetTipoIDEMIDEmPaisEMNIFEm(PurchInvHeader."Buy-from Vendor No.", TipoIDEmisor, IDEmisor, PaisEmisor, NifReceptor, VendName);
            FechaImputacion := DevolverFechaImp(PurchInvHeader."VAT Bus. Posting Group", PurchInvHeader."Posting Date",
                                PurchInvHeader."Due Date", PurchInvHeader."Document Date", 10, PurchInvHeader."No.");
            //-EXP01
            if Export THEN BEGIN
                //FechaImputacion := TODAY;
                PurchInvHeader."Tipo factura SII" := 'F1';
            END;
            //+EXP01
            DevolverAnoMesDia(FechaImputacion, AñoImputacion, MesImputacion, DiaImputacion);
            //WriteNewDoc(Fichero,AñoImputacion,MesImputacion,PurchInvHeader."Tipo factura SII",PurchInvHeader."No.",Año+Mes+Dia,
            //PurchInvHeader."VAT Registration No.", VendName,
            //            TipoIDEmisor,IDEmisor,PaisEmisor,CompanyInformation."VAT Registration No.", CompanyInformation.Name, '','','');
            Vendor.Get(PurchInvHeader."Pay-to Vendor No.");
            WriteNewDoc(Fichero, AñoImputacion, MesImputacion, PurchInvHeader."Tipo factura SII",
                        //-SII1
                        //PurchInvHeader."No.",Año+Mes+Dia,PurchInvHeader."VAT Registration No.", VendName,
                        PurchInvHeader."Vendor Invoice No.", Año + Mes + Dia, NifReceptor, VendName,
          //TipoIDEmisor,IDEmisor,PaisEmisor,PurchInvHeader."VAT Registration No.", VendName, TipoIDEmisor,IDEmisor,PaisEmisor);
          //TipoIDEmisor,IDEmisor,PaisEmisor,PurchInvHeader."VAT Registration No.", VendName, '',''{CompanyInformation."VAT Registration No."},PaisEmisor);
          TipoIDEmisor, IDEmisor, PaisEmisor, NifReceptor, VendName, TipoIDEmisor, IDEmisor/*CompanyInformation."VAT Registration No."*/, PaisEmisor, Vendor, Customer);

            PurchInvHeader.CALCFIELDS("Amount Including VAT");
            PurchInvHeader.CALCFIELDS(Amount);
            CLEAR(decImporteIVAincl);
            CLEAR(decImporte);

            PurchInvoiceLine.RESET;
            PurchInvoiceLine.SETRANGE("Document No.", PurchInvHeader."No.");
            if PurchInvoiceLine.FINDFIRST THEN
                REPEAT
                    if VatPostStp.GET(PurchInvoiceLine."VAT Bus. Posting Group", PurchInvoiceLine."VAT Prod. Posting Group") THEN BEGIN
                        if (NOT (VatPostStp."Obviar SII")) THEN BEGIN
                            decImporteIVAincl += PurchInvoiceLine."Amount Including VAT";
                            decImporte += PurchInvoiceLine.Amount;
                        END;
                    END;
                UNTIL PurchInvoiceLine.NEXT = 0;
            //-SII1
            if PurchInvHeader."Currency Factor" <> 0 THEN BEGIN
                decImporteIVAincl /= PurchInvHeader."Currency Factor";
                decImporte /= PurchInvHeader."Currency Factor";
            END;
            //+SII1
            CalcVATAmtLines(1, PurchInvHeader."No.", TempVATAmountLines, TempVatPostStp);
            //llamar
            //-SII1
            //aplicamos divisas...
            ApplyCurrencyFactor(TempVATAmountLines, PurchInvHeader."Currency Factor");
            //+SII1
            VATBusPostGrp.GET(PurchInvHeader."VAT Bus. Posting Group");
            CuotaDeducible := CalcCuotaDeducible(TempVATAmountLines);
            if PurchInvHeader."Descripción operación" = '' Then PurchInvHeader."Descripción operación" := PurchInvHeader."Posting Description";
            if PurchInvHeader."Tipo factura SII" = '' then
                PurchInvHeader."Tipo factura SII" := 'F1';
            //-SII10
            if PurchInvHeader."Descripción operación" <> '' THEN
                txtDescOperacion := PurchInvHeader."Descripción operación"
            ELSE
                txtDescOperacion := STRSUBSTNO('Factura %1', PurchInvHeader."No.");
            //+SII10
            //-EXP01
            if NOT Export THEN
                Description := txtDescOperacion;
            //+EXP01
            //if CuotaDeducible <> 0 THEN

            TextCuotaDeducible := ChangeCommaForDot(FORMAT(CuotaDeducible, 0, DevolverFormato(PurchInvHeader."Currency Code")));
            //-SII10
            //WriteNewINVDOC(Fichero,VATBusPostGrp."Clave registro SII recibidas",PurchInvHeader."Descripción operación",
            //-EXP01
            //WriteNewINVDOC(Fichero,VATBusPostGrp."Clave registro SII recibidas",txtDescOperacion,
            WriteNewINVDOC(Fichero, VATBusPostGrp."Clave registro SII recibidas", Description,
                          //+EXP01
                          //+SII10
                          //-SII1
                          // AñoImputacion+MesImputacion+DiaImputacion,TextCuotaDeducible,
                          AñoOperacion + MesOperacion + DiaOperacion, TextCuotaDeducible,
                          //+SII1
                          //ChangeCommaForDot(FORMAT(PurchInvHeader."Amount Including VAT",0,'<Sign><Integer><Decimals,3>')),
                          //ChangeCommaForDot(FORMAT(PurchInvHeader.Amount,0,'<Sign><Integer><Decimals,3>')));
                          ChangeCommaForDot(FORMAT(decImporteIVAincl, 0, DevolverFormato(PurchInvHeader."Currency Code"))),
                          ChangeCommaForDot(FORMAT(decImporte, 0, DevolverFormato(PurchInvHeader."Currency Code"))));
            WriteNewIMPDOC(Fichero, TempVATAmountLines, FALSE, TempVatPostStp, FALSE, 'FR', PurchInvHeader."Currency Code");
            //-SII1
            if WriteIMPDOC THEN
                WriteNewRECDOC(Fichero, TempVATAmountLines, PurchInvHeader."Tipo factura rectificativa", PurchInvHeader."Currency Code");
            //+SII1
            PurchInvHeader."Reportado SII" := TRUE;
            PurchInvHeader."Nombre fichero SII" := RutaFichero;
            PurchInvHeader."Fecha/hora subida fichero SII" := CURRENTDATETIME;
            //-EXP01
            if Export THEN BEGIN
                PurchInvHeader."Reportado SII primer semestre" := TRUE;
                PurchInvHeader."Descripción operación" := Description;
            END;
            //+EXP01
            PurchInvHeader.MODIFY;
            //-jb
            FicheroCLOSE(Fichero);
            //+jb
        END;
        if PurchCrMemoHeader."No." <> '' THEN BEGIN
            //-c1
            //-SII1
            //DevolverAnoMesDia(TODAY,Año,Mes,Dia);
            DevolverAnoMesDia(PurchCrMemoHeader."Document Date", Año, Mes, Dia);
            DevolverAnoMesDia(TODAY, AñoOperacion, MesOperacion, DiaOperacion);
            //+SII1
            //+c1
            SetTipoIDEMIDEmPaisEMNIFEm(PurchCrMemoHeader."Buy-from Vendor No.", TipoIDEmisor, IDEmisor, PaisEmisor, NifReceptor, VendName);
            //calculo de cuota deducible: base factura * IVA.
            FechaImputacion := DevolverFechaImp(PurchCrMemoHeader."VAT Bus. Posting Group", PurchCrMemoHeader."Posting Date",
                               PurchCrMemoHeader."Due Date", PurchCrMemoHeader."Document Date", 10, PurchCrMemoHeader."No.");
            //-EXP01
            if PurchCrMemoHeader."Descripción operación" = '' Then PurchCrMemoHeader."Descripción operación" := PurchCrMemoHeader."Posting Description";
            if PurchCrMemoHeader."Tipo factura SII" = '' then
                PurchCrMemoHeader."Tipo factura SII" := 'F1';
            if Export THEN BEGIN
                //FechaImputacion := TODAY;
                PurchCrMemoHeader."Tipo factura SII" := 'F1';
            END;
            //+EXP01
            DevolverAnoMesDia(FechaImputacion, AñoImputacion, MesImputacion, DiaImputacion);
            //WriteNewDoc(Fichero,AñoImputacion,MesImputacion,PurchCrMemoHeader."Tipo factura SII",
            //PurchCrMemoHeader."No.",Año+Mes+Dia,PurchCrMemoHeader."VAT Registration No.", VendName,
            //            TipoIDEmisor,IDEmisor,PaisEmisor,CompanyInformation."VAT Registration No.", CompanyInformation.Name, '','','');
            Vendor.Get(PurchCrMemoHeader."Pay-to Vendor No.");
            WriteNewDoc(Fichero, AñoImputacion, MesImputacion, PurchCrMemoHeader."Tipo factura SII",
                        //-SII1
                        //PurchCrMemoHeader."No.",Año+Mes+Dia,PurchCrMemoHeader."VAT Registration No.", VendName,
                        PurchCrMemoHeader."Vendor Cr. Memo No.", Año + Mes + Dia, NifReceptor, VendName,
          //TipoIDEmisor,IDEmisor,PaisEmisor,PurchCrMemoHeader."VAT Registration No.", VendName,TipoIDEmisor, IDEmisor,PaisEmisor);
          //TipoIDEmisor,IDEmisor,PaisEmisor,PurchCrMemoHeader."VAT Registration No.", VendName, '',''{CompanyInformation."VAT Registration No."},PaisEmisor);
          TipoIDEmisor, IDEmisor, PaisEmisor, NifReceptor, VendName, TipoIDEmisor, IDEmisor/*CompanyInformation."VAT Registration No."*/, PaisEmisor, Vendor, Customer);

            //+SII1
            PurchCrMemoHeader.CALCFIELDS("Amount Including VAT");
            PurchCrMemoHeader.CALCFIELDS(Amount);
            CLEAR(decImporteIVAincl);
            CLEAR(decImporte);

            PurchCrMemoLine.RESET;
            PurchCrMemoLine.SETRANGE("Document No.", PurchCrMemoHeader."No.");
            if PurchCrMemoLine.FINDFIRST THEN
                REPEAT
                    if (VatPostStp.GET(PurchCrMemoLine."VAT Bus. Posting Group", PurchCrMemoLine."VAT Prod. Posting Group")
                        AND (NOT (VatPostStp."Obviar SII"))) THEN BEGIN
                        decImporteIVAincl += PurchCrMemoLine."Amount Including VAT";
                        decImporte += PurchCrMemoLine.Amount;
                    END;
                UNTIL PurchCrMemoLine.NEXT = 0;
            //-SII1
            if PurchCrMemoHeader."Currency Factor" <> 0 THEN BEGIN
                //-SII12
                //decImporteIVAincl *= PurchCrMemoHeader."Currency Factor";
                //decImporte *= PurchCrMemoHeader."Currency Factor";
                decImporteIVAincl /= PurchCrMemoHeader."Currency Factor";
                decImporte /= PurchCrMemoHeader."Currency Factor";
                //+SII12
            END;
            //+SII1
            CalcVATAmtLines(3, PurchCrMemoHeader."No.", TempVATAmountLines, TempVatPostStp);
            //llamar
            //-SII1
            ApplyCurrencyFactor(TempVATAmountLines, PurchCrMemoHeader."Currency Factor");
            //+SII1
            VATBusPostGrp.GET(PurchCrMemoHeader."VAT Bus. Posting Group");
            CuotaDeducible := CalcCuotaDeducible(TempVATAmountLines);
            //if CuotaDeducible <> 0 THEN
            TextCuotaDeducible := ChangeCommaForDot(FORMAT(-CuotaDeducible, 0, DevolverFormato(PurchCrMemoHeader."Currency Code")));
            //-SII10
            //WriteNewINVDOC(Fichero,VATBusPostGrp."Clave registro SII recibidas",PurchInvHeader."Descripción operación",
            if PurchCrMemoHeader."Descripción operación" = '' Then PurchCrMemoHeader."Descripción operación" := PurchCrMemoHeader."Posting Description";
            if PurchCrMemoHeader."Tipo factura SII" = '' then
                PurchCrmemoHeader."Tipo factura SII" := 'F1';
            if PurchCrMemoHeader."Descripción operación" <> '' THEN
                txtDescOperacion := PurchCrMemoHeader."Descripción operación"
            ELSE
                txtDescOperacion := STRSUBSTNO('Factura %1', PurchCrMemoHeader."No.");
            //-EXP01
            if NOT Export THEN
                Description := txtDescOperacion;
            //WriteNewINVDOC(Fichero,VATBusPostGrp."Clave registro SII recibidas",txtDescOperacion,
            WriteNewINVDOC(Fichero, VATBusPostGrp."Clave registro SII recibidas", Description,
                          //+EXP01
                          //+SII10
                          //-SII1
                          //AñoImputacion+MesImputacion+DiaImputacion,TextCuotaDeducible,
                          AñoOperacion + MesOperacion + DiaOperacion, TextCuotaDeducible,
                          //+SII1
                          //ChangeCommaForDot(FORMAT(-PurchCrMemoHeader."Amount Including VAT",0,'<Sign,1><Integer><Decimals,3>')),
                          //ChangeCommaForDot(FORMAT(-PurchCrMemoHeader.Amount,0,'<Sign,1><Integer><Decimals,3>')));
                          ChangeCommaForDot(FORMAT(-decImporteIVAincl, 0, DevolverFormato(PurchCrMemoHeader."Currency Code"))),
                          ChangeCommaForDot(FORMAT(-decImporte, 0, DevolverFormato(PurchCrMemoHeader."Currency Code"))));
            WriteNewIMPDOC(Fichero, TempVATAmountLines, TRUE, TempVatPostStp, FALSE, 'FR', PurchCrMemoHeader."Currency Code");
            //if PurchCrMemoHeader."Corrected Invoice No." <> '' THEN
            WriteNewRECDOC(Fichero, TempVATAmountLines, PurchCrMemoHeader."Tipo factura rectificativa", PurchCrMemoHeader."Currency Code");
            PurchCrMemoHeader."Reportado SII" := TRUE;
            PurchCrMemoHeader."Nombre fichero SII" := RutaFichero;
            PurchCrMemoHeader."Fecha/hora subida fichero SII" := CURRENTDATETIME;
            //-EXP01
            if Export THEN BEGIN
                PurchCrMemoHeader."Reportado SII primer semestre" := TRUE;
                PurchCrMemoHeader."Descripción operación" := Description;
            END;
            //+EXP01
            PurchCrMemoHeader.MODIFY;
            //-jb
            FicheroCLOSE(Fichero);
            //+jb
        END;
        //+001

    end;


    /// <summary>
    /// CheckPurchRequiredFields.
    /// </summary>
    /// <param name="PurchaseHeader">VAR Record 38.</param>
    /// <param name="ModifyHdr">VAR Boolean.</param>
    /// <summary>
    /// CheckPurchRequiredFields.
    /// </summary>
    /// <param name="PurchaseHeader">VAR Record 38.</param>
    /// <param name="ModifyHdr">VAR Boolean.</param>
    procedure CheckPurchRequiredFields(var PurchaseHeader: Record 38; var ModifyHdr: Boolean)
    var
        PurchaseLine: Record 39;
        VATPostingSetup: Record 325;
        IVACaja: Boolean;
        VATBusPostGrp: Record 323;
    begin
        //-001
        HasVAT := FALSE;
        GetGLSetup;
        //-SII1
        if (GLSetup."Exportar SII desde fecha" <> 0D) THEN
            if (PurchaseHeader."Posting Date" < GLSetup."Exportar SII desde fecha") THEN
                EXIT;
        //+SII1
        PurchaseLine.SETRANGE("Document Type", PurchaseHeader."Document Type");
        PurchaseLine.SETRANGE("Document No.", PurchaseHeader."No.");
        PurchaseLine.FINDSET;
        REPEAT
            if PurchaseLine.Type <> PurchaseLine.Type::" " THEN BEGIN
                VATPostingSetup.GET(PurchaseHeader."VAT Bus. Posting Group", PurchaseLine."VAT Prod. Posting Group");
                VATBusPostGrp.GET(VATPostingSetup."VAT Bus. Posting Group");
                HasVAT := PreviousPurchChecks(VATPostingSetup, PurchaseHeader, VATBusPostGrp);
            END;
        UNTIL (PurchaseLine.NEXT = 0);
        /*if NOT HasVAT THEN
          EXIT;*/
        //-SII1
        ModifyHdr := PurchaseHeader.UpdateFieldsSII;
        //+SII1
        IVACaja := CriterioCaja(PurchaseHeader."No.", PurchaseHeader."Posting Date");
        if NOT IVACaja THEN BEGIN
            PurchaseHeader.TESTFIELD("Descripción operación");
            VATBusPostGrp.TESTFIELD("Clave registro SII recibidas");
        END;
        PreviousPurchHdrChecks(PurchaseHeader, IVACaja);
        //+001

    end;


    /// <summary>
    /// PreviousPurchChecks.
    /// </summary>
    /// <param name="VATPostingSetup">VAR Record 325.</param>
    /// <param name="PurchaseHeader">VAR Record 38.</param>
    /// <param name="VATBusPostGrp">VAR Record 323.</param>
    /// <returns>Return value of type Boolean.</returns>
    /// <summary>
    /// PreviousPurchChecks.
    /// </summary>
    /// <param name="VATPostingSetup">VAR Record 325.</param>
    /// <param name="PurchaseHeader">VAR Record 38.</param>
    /// <param name="VATBusPostGrp">VAR Record 323.</param>
    /// <returns>Return value of type Boolean.</returns>
    procedure PreviousPurchChecks(var VATPostingSetup: Record 325; var PurchaseHeader: Record 38; var VATBusPostGrp: Record 323): Boolean
    begin
        //-001
        //if VATPostingSetup."VAT Calculation Type" <> VATPostingSetup."VAT Calculation Type"::"No Taxable VAT" THEN BEGIN
        //-SII1
        //VATPostingSetup.TESTFIELD("Tipo desglose emitidas");
        VATPostingSetup.TESTFIELD("Tipo desglose recibidas");
        //+SII1
        EXIT(TRUE);
        //END;
        //EXIT(FALSE);
        //+001
    end;

    local procedure ChangeCommaForDot(Value: Text): Text
    var
        i: Integer;
        Changed: Boolean;
    begin
        i := 1;
        if STRPOS(Value, ',') = 0 THEN
            EXIT(Value);
        WHILE (i < STRLEN(Value)) OR (NOT Changed) DO BEGIN
            if Value[i] = ',' THEN BEGIN
                Value[i] := '.';
                EXIT(Value);
            END;
            i += 1;
        END;
    end;

#pragma warning disable AL0432
    local procedure CalcCuotaDeducible(var VATAmountLines: Record "VAT Amount Line" Temporary): Decimal
#pragma warning restore AL0432
    var
        CuotaDeducible: Decimal;
        VatSet: Record 325;
    begin
        //-EXP01
        if Export THEN
            EXIT(0);
        //+EXP01
        VATAmountLines.RESET;
        if VATAmountLines.FINDSET THEN
            REPEAT
                if VATAmountLines."VAT Calculation Type" = VATAmountLines."VAT Calculation Type"::"Reverse Charge VAT" THEN BEGIN
                    VatSet.SETRANGE(VatSet."VAT Calculation Type", VATAmountLines."VAT Calculation Type");
                    VatSet.SETRANGE(VatSet."VAT Identifier", VATAmountLines."VAT Identifier");
                    VatSet.FINDFIRST;
                    //revisar aqúi
                    //VATAmountLines."VAT %" := 0;//VatSet."VAT %";
                    VATAmountLines."VAT Amount" := VATAmountLines."Line Amount" * (VATAmountLines."VAT %" / 100);
                    VATAmountLines.MODIFY;
                END;
                CuotaDeducible += VATAmountLines."VAT Amount";
            UNTIL VATAmountLines.NEXT = 0;
        EXIT(CuotaDeducible);
    end;


    /// <summary>
    /// CheckGenJnlLineFields.
    /// </summary>
    /// <param name="GenJournalLine">VAR Record 81.</param>
    /// <param name="VATBusCode">Code[20].</param>
    /// <param name="VATProdCode">Code[20].</param>
    procedure CheckGenJnlLineFields(var GenJournalLine: Record "Gen. Journal Line"; VATBusCode: Code[20]; VATProdCode: Code[20])
    var
        VATPostingSetup: Record 325;
        PaymentMethod: Record 289;
        PostingDate: Date;
        DiarioPago: Boolean;
        Tipofactura: Code[10];
    begin
        //-001
        //parcheamos todooooo!
        /*if NOT FromGenJnl THEN
          EXIT;*/
        /*if (NOT (GenJournalLine."Bal. Account Type" IN [GenJournalLine."Bal. Account Type"::Customer
            ,GenJournalLine."Bal. Account Type"::Vendor]))  THEN BEGIN
          if NOT (GenJournalLine."Account Type" IN [GenJournalLine."Account Type"::Customer,GenJournalLine."Account Type"::Vendor]) THEN
            EXIT;
          DiarioPago := TRUE;
        END ELSE
          if (NOT (GenJournalLine."Bal. Account Type" IN [GenJournalLine."Bal. Account Type"::Customer,
               GenJournalLine."Bal. Account Type"::Vendor]))
              OR (NOT (GenJournalLine."Document Type" IN [GenJournalLine."Document Type"::Invoice,
              GenJournalLine."Document Type"::"Credit Memo",GenJournalLine."Document Type"::Payment
              ,GenJournalLine."Document Type"::Refund,GenJournalLine."Document Type"::Bill])) THEN
            EXIT;*/

        /*if NOT (GenJournalLine."Bal. Account Type" IN [GenJournalLine."Bal. Account Type"::Customer,
          GenJournalLine."Bal. Account Type"::Vendor]) THEN
          EXIT;*/
        //hasta aqui.
        if (GenJournalLine."Document Type" IN [GenJournalLine."Document Type"::"Credit Memo",
          GenJournalLine."Document Type"::Invoice]) THEN BEGIN
            HasVAT := FALSE;
            GetGLSetup;
            //-SII1
            if (GLSetup."Exportar SII desde fecha" <> 0D) THEN
                if (GLSetup."Exportar SII desde fecha" < GenJournalLine."Posting Date") THEN
                    EXIT;
            //+SII1
            if VATPostingSetup.GET(VATBusCode, VATProdCode) THEN
                HasVAT := PreviousGenJnlLineChecks(VATPostingSetup, GenJournalLine);
            /*if NOT HasVAT THEN
              EXIT;*/
            //-C2
            if (GenJournalLine."Gen. Posting Type" = GenJournalLine."Gen. Posting Type"::Sale) THEN
                OpenOrCreateFile('FE', TRUE)
            ELSE
                if (GenJournalLine."Gen. Posting Type" = GenJournalLine."Gen. Posting Type"::Purchase) THEN
                    OpenOrCreateFile('FR', TRUE);
            //+C2
        END ELSE
            if (GenJournalLine."Document Type" IN [GenJournalLine."Document Type"::Payment,
     GenJournalLine."Document Type"::Bill, GenJournalLine."Document Type"::Refund]) THEN BEGIN
                if GenJournalLine."Account Type" = GenJournalLine."Account Type"::Customer THEN
                    PostingDate := GetPostingDateByDocType(0, GenJournalLine)
                ELSE
                    if GenJournalLine."Account Type" = GenJournalLine."Account Type"::Vendor THEN
                        PostingDate := GetPostingDateByDocType(1, GenJournalLine);
                if CriterioCaja(GenJournalLine."Applies-to Doc. No.", PostingDate) THEN BEGIN
                    PaymentMethod.GET(GenJournalLine."Payment Method Code");
                    PaymentMethod.TESTFIELD("Medio pago SII");
                    if GenJournalLine."Account Type" = GenJournalLine."Account Type"::Customer THEN
                        OpenOrCreateFile('CE', TRUE)
                    ELSE
                        if GenJournalLine."Account Type" = GenJournalLine."Account Type"::Vendor THEN
                            OpenOrCreateFile('PR', TRUE);
                END;
            END;

        //+001

    end;


    /// <summary>
    /// CheckGenJnlLineFieldsOLD.
    /// </summary>
    /// <param name="GenJournalLine">VAR Record 81.</param>
    /// <param name="FromGenJnl">Boolean.</param>
    /// <summary>
    /// CheckGenJnlLineFieldsOLD.
    /// </summary>
    /// <param name="GenJournalLine">VAR Record 81.</param>
    /// <param name="FromGenJnl">Boolean.</param>
    procedure CheckGenJnlLineFieldsOLD(var GenJournalLine: Record "Gen. Journal Line"; FromGenJnl: Boolean)
    var
        VATPostingSetup: Record 325;
        PaymentMethod: Record 289;
        PostingDate: Date;
        DiarioPago: Boolean;
    begin
        //-001
        if NOT FromGenJnl THEN
            EXIT;
        /*if (NOT (GenJournalLine."Bal. Account Type" IN [GenJournalLine."Bal. Account Type"::Customer
            ,GenJournalLine."Bal. Account Type"::Vendor]))  THEN BEGIN
          if NOT (GenJournalLine."Account Type" IN [GenJournalLine."Account Type"::Customer,GenJournalLine."Account Type"::Vendor]) THEN
            EXIT;
          DiarioPago := TRUE;
        END ELSE
          if (NOT (GenJournalLine."Bal. Account Type" IN [GenJournalLine."Bal. Account Type"::Customer,
               GenJournalLine."Bal. Account Type"::Vendor]))
              OR (NOT (GenJournalLine."Document Type" IN [GenJournalLine."Document Type"::Invoice,
              GenJournalLine."Document Type"::"Credit Memo",GenJournalLine."Document Type"::Payment
              ,GenJournalLine."Document Type"::Refund,GenJournalLine."Document Type"::Bill])) THEN
            EXIT;*/

        /*if NOT (GenJournalLine."Bal. Account Type" IN [GenJournalLine."Bal. Account Type"::Customer,
          GenJournalLine."Bal. Account Type"::Vendor]) THEN
          EXIT;*/
        //hasta aqui.
        if (GenJournalLine."Document Type" IN [GenJournalLine."Document Type"::"Credit Memo",
          GenJournalLine."Document Type"::Invoice]) THEN BEGIN
            HasVAT := FALSE;
            GetGLSetup;
            //-SII1
            if (GLSetup."Exportar SII desde fecha" <> 0D) THEN
                if (GLSetup."Exportar SII desde fecha" < GenJournalLine."Posting Date") THEN
                    EXIT;
            //+SII1
            if VATPostingSetup.GET(GenJournalLine."VAT Bus. Posting Group", GenJournalLine."VAT Prod. Posting Group") THEN
                HasVAT := PreviousGenJnlLineChecks(VATPostingSetup, GenJournalLine);
            /*if NOT HasVAT THEN
              EXIT;*/
            //-C2
            if (GenJournalLine."Gen. Posting Type" = GenJournalLine."Gen. Posting Type"::Sale) THEN
                OpenOrCreateFile('FE', TRUE)
            ELSE
                if (GenJournalLine."Gen. Posting Type" = GenJournalLine."Gen. Posting Type"::Purchase) THEN
                    OpenOrCreateFile('FR', TRUE);
            //+C2
        END ELSE
            if (GenJournalLine."Document Type" IN [GenJournalLine."Document Type"::Payment,
     GenJournalLine."Document Type"::Bill, GenJournalLine."Document Type"::Refund]) THEN BEGIN
                if GenJournalLine."Account Type" = GenJournalLine."Account Type"::Customer THEN
                    PostingDate := GetPostingDateByDocType(0, GenJournalLine)
                ELSE
                    if GenJournalLine."Account Type" = GenJournalLine."Account Type"::Vendor THEN
                        PostingDate := GetPostingDateByDocType(1, GenJournalLine);
                if CriterioCaja(GenJournalLine."Applies-to Doc. No.", PostingDate) THEN BEGIN
                    PaymentMethod.GET(GenJournalLine."Payment Method Code");
                    PaymentMethod.TESTFIELD("Medio pago SII");
                    if GenJournalLine."Account Type" = GenJournalLine."Account Type"::Customer THEN
                        OpenOrCreateFile('CE', TRUE)
                    ELSE
                        if GenJournalLine."Account Type" = GenJournalLine."Account Type"::Vendor THEN
                            OpenOrCreateFile('PR', TRUE);
                END;
            END;

        //+001

    end;


    /// <summary>
    /// PreviousGenJnlLineChecks.
    /// </summary>
    /// <param name="VATPostingSetup">VAR Record 325.</param>
    /// <param name="GenJournalLine">VAR Record 81.</param>
    /// <returns>Return value of type Boolean.</returns>
    procedure PreviousGenJnlLineChecks(var VATPostingSetup: Record 325; var GenJournalLine: Record 81): Boolean
    var
        Number: Integer;
        CompanyInformation: Record 79;
        Customer: Record Customer;
        VATBusPostGrp: Record 323;
        Vendor: Record Vendor;
        Text001: Label 'El valor del campo tipo factura SII debe ser numerico';
        Text002: Label 'El valor del campo tipo factura rectificativa debe ser numerico';
        GenJnlAux: Record "Gen. Journal Line";
        BillTo: Code[20];
    begin
        //-001
        //if VATPostingSetup."VAT Calculation Type" <> VATPostingSetup."VAT Calculation Type"::"No Taxable VAT" THEN BEGIN
        //-jb
        /*if NOT EVALUATE(Number,GenJournalLine."Tipo factura SII") THEN
          ERROR(Text002);*/
        //+jb
        //-SII1
        //if GenJournalLine."Document Type" = GenJournalLine."Document Type"::Invoice THEN
        //-jb
        //if IsNumeric(FORMAT(GenJournalLine."Tipo factura SII"[1])) THEN
        //+jb
        //  GenJournalLine."Tipo factura SII" := INSSTR(GenJournalLine."Tipo factura SII",'F',1);
        //+SII1
        VATBusPostGrp.GET(VATPostingSetup."VAT Bus. Posting Group");
        if (GenJournalLine."Gen. Posting Type" = GenJournalLine."Gen. Posting Type"::Sale)
           OR (GenJournalLine."Account Type" = GenJournalLine."Account Type"::Customer) THEN BEGIN
            VATBusPostGrp.TESTFIELD("Clave registro SII expedidas");
            GenJournalLine.TESTFIELD("Clave registro SII expedidas");
            //-SII1
            VATPostingSetup.TESTFIELD("Tipo desglose emitidas");
            //+SII
        END ELSE
            if (GenJournalLine."Gen. Posting Type" = GenJournalLine."Gen. Posting Type"::Purchase)
     OR (GenJournalLine."Account Type" = GenJournalLine."Account Type"::Vendor) THEN BEGIN
                VATBusPostGrp.TESTFIELD("Clave registro SII recibidas");
                GenJournalLine.TESTFIELD("Clave registro SII recibidas");
                //-SII1
                VATPostingSetup.TESTFIELD("Tipo desglose recibidas");
                //+SII1
            END;
        //-SII 3.0
        if GenJournalLine."Document Type" = GenJournalLine."Document Type"::"Credit Memo" THEN
            GenJournalLine.TESTFIELD("Tipo factura rectificativa");
        //+SII 3.0
        //desde diarios no se corrigen facturas...
        //if GenJournalLine."Document Type" = GenJournalLine."Document Type"::"Credit Memo" THEN BEGIN
        //  GenJournalLine."Tipo factura SII" := INSSTR(GenJournalLine."Tipo factura SII",'R',1);
        //  GenJournalLine.TESTFIELD("Tipo factura rectificativa");
        //END;
        //if GenJournalLine."Account Type" = GenJournalLine."Account Type"::Customer THEN BEGIN
        VATPostingSetup.TESTFIELD("Sujeta exenta");
        if VATPostingSetup."Sujeta exenta" <> 'NS' THEN
            VATPostingSetup.TESTFIELD("Tipo de operación");
        //END;
        //-SII1
        //VATPostingSetup.TESTFIELD("Tipo desglose emitidas");
        //+SII1
        GenJournalLine.TESTFIELD(Banco);
        GenJournalLine.TESTFIELD("Descripción operación");
        CompanyInformation.GET;
        CompanyInformation.TESTFIELD("VAT Registration No.");
        CompanyInformation.TESTFIELD(Name);
        //-c2
        //if GenJournalLine."Bal. Account Type" = GenJournalLine."Bal. Account Type"::Customer THEN BEGIN
        if GenJournalLine."Bill-to/Pay-to No." = '' THEN BEGIN
            GenJnlAux := GenJournalLine;
            GenJnlAux.NEXT(-1);
            BillTo := GenJnlAux."Bill-to/Pay-to No.";
        END ELSE
            BillTo := GenJournalLine."Bill-to/Pay-to No.";
        if Customer.GET(BillTo) THEN BEGIN
            //Customer.GET(GenJournalLine."Bal. Account No.");
            //+c2
            Customer.TESTFIELD(Name);
            if Customer."VAT Registration No." = '' THEN BEGIN
                Customer.TESTFIELD("Tipo ID receptor");
                Customer.TESTFIELD("ID receptor");
                Customer.TESTFIELD("Country/Region Code");
            END;
            //-c2
            //END;
        END ELSE BEGIN
            //if GenJournalLine."Account Type" = GenJournalLine."Account Type"::Vendor THEN BEGIN
            Vendor.GET(BillTo);
            //+c2
            Vendor.TESTFIELD(Name);
            if Vendor."VAT Registration No." = '' THEN BEGIN
                Vendor.TESTFIELD("Tipo ID emisor");
                Vendor.TESTFIELD("ID emisor");
                Vendor.TESTFIELD("Country/Region Code");
            END;
        END;
        GLSetup.TESTFIELD("Nif Titular Registro");
        GLSetup.TESTFIELD("Nombre Titular Registro");
        GLSetup.TESTFIELD("Ruta fichero SII");
        //-SII1
        //GenJournalLine.MODIFY;
        //+SII1
        EXIT(TRUE);

        //END;
        //EXIT(FALSE);
        //+001

    end;


    /// <summary>
    /// CreateOrUpdateFileGenJnlLine.
    /// </summary>
    /// <param name="GenJournalLine">VAR Record 81.</param>
    /// <param name="VATBusCode">Code[20].</param>
    /// <param name="VATProdCode">Code[20].</param>
    /// <summary>
    /// CreateOrUpdateFileGenJnlLine.
    /// </summary>
    /// <param name="GenJournalLine">VAR Record 81.</param>
    /// <param name="VATBusCode">Code[20].</param>
    /// <param name="VATProdCode">Code[20].</param>
    procedure CreateOrUpdateFileGenJnlLine(var GenJournalLine: Record "Gen. Journal Line"; VATBusCode: Code[20]; VATProdCode: Code[20])
    var
        Fichero: OutStream;
        RutaFichero: Text[250];
        TipoIDreceptor: Code[3];
        IDreceptor: Code[20];
        Paisreceptor: Code[10];
        CompanyInformation: Record 79;
        "Año": Text;
        Mes: Text;
        Dia: Text;
        NifReceptor: Code[20];
        TipoFactura: Text;
        TempVATPostingSetup: Record 325 temporary;
#pragma warning disable AL0432
        TempVATAmountLines: Record "VAT Amount Line" Temporary;
#pragma warning restore AL0432
        TipoIDEmisor: Code[3];
        IDEmisor: Code[20];
        PaisEmisor: Code[10];
        VATBusPost: Record 323;
        SalesInvoiceHeader: Record 112;
        SalesCrMemoHeader: Record 114;
        PostingDate: Date;
        PaymentMethod: Record 289;
        Medio: Code[3];
        CuentaMedio: Code[34];
        BankAccount: Record 270;
        TipoFacturaSII: Code[3];
        DocNo: Code[20];
        CustName: Text[100];
        VendName: Text[100];
        VATPostingSetup: Record 325;
        Amt: Decimal;
        AmtInclVAT: Decimal;
        "AñoOperacion": Text;
        MesOperacion: Text;
        DiaOperacion: Text;
        GenJnlAux: Record "Gen. Journal Line";
        Customer: Record Customer;
        Vendor: Record Vendor;
        Dk: Enum "Document Type Kuara";
    begin
        //-001
        Customer.Init;
        Vendor.Init;
        ExistsFile := FALSE;
        //-c2
        /*if (NOT (GenJournalLine."Account Type" IN [GenJournalLine."Account Type"::Customer,
            GenJournalLine."Account Type"::Vendor]))THEN
          EXIT;*/
        //+c2
        //-SII6
        if GenJournalLine."Document Type" IN [GenJournalLine."Document Type"::Bill,
                                             GenJournalLine."Document Type"::Payment,
                                             GenJournalLine."Document Type"::Bill] THEN
            /*si no tiene criterio de caja desparchear este exit, OJO!!!!!*/
            //EXIT;
            if NOT CriterioCaja(GenJournalLine."Applies-to Doc. No.", GenJournalLine."Posting Date") THEN
                EXIT;
        //+SII6
        if NOT (GenJournalLine."Document Type" IN [GenJournalLine."Document Type"::"Credit Memo",
                                          GenJournalLine."Document Type"::Invoice,
                                          GenJournalLine."Document Type"::Payment,
                                          GenJournalLine."Document Type"::Bill]) THEN
            EXIT;
        //-SII1
        GetGLSetup;
        if (GLSetup."Exportar SII desde fecha" <> 0D) THEN
            if (GenJournalLine."Posting Date" < GLSetup."Exportar SII desde fecha") THEN
                EXIT;
        //+SII1
        if GenJournalLine."Document Type" IN [GenJournalLine."Document Type"::"Credit Memo", GenJournalLine."Document Type"::Invoice] THEN BEGIN
            //-c2
            if (GenJournalLine."Account Type" = GenJournalLine."Account Type"::Customer)
                                  OR (GenJournalLine."Gen. Posting Type" = GenJournalLine."Gen. Posting Type"::Sale) THEN
                //+c2
                TipoFactura := 'FE'
            //-c2
            ELSE
                if (GenJournalLine."Account Type" = GenJournalLine."Account Type"::Vendor) OR
                   (GenJournalLine."Gen. Posting Type" = GenJournalLine."Gen. Posting Type"::Purchase) THEN
                    //+c2
                    TipoFactura := 'FR';
            //-c2
            //END ELSE if (FromGenJnlLine) AND (GenJournalLine."Document Type" IN [GenJournalLine."Document Type"::Payment,
            //+c2
        END ELSE
            if (GenJournalLine."Document Type" IN [GenJournalLine."Document Type"::Payment,
        GenJournalLine."Document Type"::Bill, GenJournalLine."Document Type"::Refund]) THEN BEGIN
                if GenJournalLine."Account Type" = GenJournalLine."Account Type"::Customer THEN
                    PostingDate := GetPostingDateByDocType(0, GenJournalLine)
                ELSE
                    if GenJournalLine."Account Type" = GenJournalLine."Account Type"::Vendor THEN
                        PostingDate := GetPostingDateByDocType(1, GenJournalLine);
                if VATCashRegime(GenJournalLine."Document No.", GenJournalLine."Posting Date") THEN BEGIN
                    if GenJournalLine."Account Type" = GenJournalLine."Account Type"::Customer THEN
                        TipoFactura := 'CE'
                    ELSE
                        if GenJournalLine."Account Type" = GenJournalLine."Account Type"::Vendor THEN
                            TipoFactura := 'PR';
                END ELSE
                    EXIT;
            END;
        //-SII1
        if (TipoFactura = 'CE') OR (TipoFactura = 'PR') THEN
            if GenJournalLine."Applies-to Doc. No." = '' THEN
                EXIT;
        //+SII1
        //-SII10
        if g_codeTipoFichero = '' THEN
            g_codeTipoFichero := 'A0';
        //+SII10
        OpenFile(OpenOrCreateFile(TipoFactura, FALSE), Fichero, GenJournalLine."Document No.", false);
        GetGLSetup;
        Case GenJournalLine."Document Type" Of

            GenJournalLine."Document Type"::" ", GenJournalLine."Document Type"::Advance:
                Dk := Dk::" ";
            GenJournalLine."Document Type"::Bill:
                Dk := Dk::Bill;
            GenJournalLine."Document Type"::"Credit Memo":
                Dk := Dk::"Credit Memo";
            GenJournalLine."Document Type"::"Finance Charge Memo":
                Dk := Dk::"Finance Charge Memo";
            GenJournalLine."Document Type"::Invoice:
                Dk := Dk::Invoice;
            GenJournalLine."Document Type"::Payment:
                Dk := Dk::Payment;
            GenJournalLine."Document Type"::Receipt:
                Dk := Dk::Albaran;
            GenJournalLine."Document Type"::Refund:
                Dk := Dk::Refund;
            GenJournalLine."Document Type"::Reminder:
                Dk := Dk::Reminder;

        End;
        CompanyInformation.GET;
        if Lenght = 0 THEN
            //-SII10
            //WriteNewFile(Fichero,GLSetup,TipoFactura,'A0');
            WriteNewFile(Fichero, GLSetup, TipoFactura, g_codeTipoFichero);
        //+SII10
        DevolverAnoMesDia(GenJournalLine."Document Date", Año, Mes, Dia);
        //-C1
        if (TipoFactura = 'FR') OR (TipoFactura = 'PR') THEN BEGIN
            //-SII1
            //DevolverAnoMesDia(TODAY,Año,Mes,Dia);
            DevolverAnoMesDia(GenJournalLine."Document Date", Año, Mes, Dia);
            DevolverAnoMesDia(TODAY, AñoOperacion, MesOperacion, DiaOperacion);
            //+SII1
        END;
        //+C1
        //-c2


        if (GenJournalLine."Document Type" IN [GenJournalLine."Document Type"::Payment, GenJournalLine."Document Type"::Bill]) THEN
            //+c2
            CalcVatLinesGenJnlLine(GenJournalLine."Document No.", GenJournalLine."Posting Date", Dk,
                                 TempVATAmountLines, TempVATPostingSetup)
        //-c2
        //-SII9
        //ELSE
        ELSE BEGIN
            //+SII9
            CalcVatLinesGenJnlLine(GenJournalLine."Document No.", GenJournalLine."Posting Date", DK,
                                   TempVATAmountLines, TempVATPostingSetup)
            //CalcVatGenJnlLine(GenJournalLine,VATBusCode,VATProdCode,TempVATAmountLines,TempVATPostingSetup);
            //-SII9
            //ApplyCurrencyFactor(TempVATAmountLines,GenJournalLine."Currency Factor");
        END;
        //+SII9
        //+c2
        //llamar
        //-SII1
        //aplicamos divisas
        //-SII9
        //ApplyCurrencyFactor(TempVATAmountLines,GenJournalLine."Currency Factor");
        //+SII9
        //+SII1
        CalcAmts(TempVATAmountLines, AmtInclVAT, Amt);
        TempVATPostingSetup.FINDFIRST;
        if VATBusPost.GET(TempVATPostingSetup."VAT Bus. Posting Group") THEN;
        if (GenJournalLine."Account Type" = GenJournalLine."Account Type"::Customer) OR
                              (GenJournalLine."Gen. Posting Type" = GenJournalLine."Gen. Posting Type"::Sale) THEN BEGIN
            //-c2
            //SetTipoIDRecIDRecPaisRecNIFRec(GenJournalLine."Account No.",TipoIDreceptor,IDreceptor,
            SetTipoIDRecIDRecPaisRecNIFRec(GenJournalLine."Bill-to/Pay-to No.", TipoIDreceptor, IDreceptor,
                                           GenJournalLine."Country/Region Code", NifReceptor, CustName,
                                          '', '', '');

            /*Factura FE desde diario general...*/
            if (TipoFactura = 'FE') THEN BEGIN
                TipoFacturaSII := GenJournalLine.Banco;
                DocNo := GenJournalLine."Document No.";
                //-SII1
                //END ELSE
            END ELSE BEGIN
                //+SII1
                DocNo := GenJournalLine."Applies-to Doc. No.";
                //-SII1
                TipoFacturaSII := 'F1';
            END;
            Customer.Get(GenJournalLine."Bill-to/Pay-to No.");
            //+SII1
            WriteNewDoc(Fichero, Año, Mes, TipoFacturaSII, DocNo, Año + Mes + Dia, CompanyInformation."VAT Registration No.", CompanyInformation.Name,
                      '', '', '', NifReceptor, CustName, TipoIDreceptor, IDreceptor, Paisreceptor, Vendor, Customer);
            if GenJournalLine."Document Type" = GenJournalLine."Document Type"::Invoice THEN BEGIN
                WriteNewINVDOC(Fichero, VATBusPost."Clave registro SII expedidas", GenJournalLine."Descripción operación", Año + Mes + Dia, '',
                              ChangeCommaForDot(FORMAT(AmtInclVAT, 0, DevolverFormato(GenJournalLine."Currency Code"))),
                               ChangeCommaForDot(FORMAT(Amt, 0, DevolverFormato(GenJournalLine."Currency Code"))));
                WriteNewIMPDOC(Fichero, TempVATAmountLines, FALSE, TempVATPostingSetup, TRUE, TipoFactura, GenJournalLine."Currency Code");
            END ELSE
                if GenJournalLine."Document Type" = GenJournalLine."Document Type"::"Credit Memo" THEN BEGIN
                    WriteNewINVDOC(Fichero, VATBusPost."Clave registro SII expedidas", GenJournalLine."Descripción operación", Año + Mes + Dia, '',
                                      //ChangeCommaForDot(FORMAT((AmtInclVAT),0,DevolverFormato(GenJournalLine."Currency Code"))),
                                      //ChangeCommaForDot(FORMAT(Amt,0,DevolverFormato(GenJournalLine."Currency Code"))));
                                      //-SII 3.0
                                      ChangeCommaForDot(FORMAT((-AmtInclVAT), 0, DevolverFormato(GenJournalLine."Currency Code"))),
                                      ChangeCommaForDot(FORMAT(-Amt, 0, DevolverFormato(GenJournalLine."Currency Code"))));
                    //+SII 3.0
                    WriteNewIMPDOC(Fichero, TempVATAmountLines, TRUE, TempVATPostingSetup, TRUE, TipoFactura, GenJournalLine."Currency Code");
                    //-SII 3.0
                    WriteNewRECDOC(Fichero, TempVATAmountLines, GenJournalLine."Tipo factura rectificativa", GenJournalLine."Currency Code");
                    //+SII 3.0
                END;
            /*factura CE desde diario de pago..*/
            if TipoFactura = 'CE' THEN BEGIN
                WriteCE(Fichero, NOT (GenJournalLine."Document Type" IN [GenJournalLine."Document Type"::"Credit Memo",
                         GenJournalLine."Document Type"::Refund]), GenJournalLine."Document No.", DK
                        , GenJournalLine."Posting Date", GenJournalLine."Currency Code");
            END;
            //-SII9
            //END ELSE if (GenJournalLine."Account Type" = GenJournalLine."Account Type"::Vendor)
        END ELSE
            if (GenJournalLine."Account Type" = GenJournalLine."Account Type"::Vendor) OR
               (GenJournalLine."Gen. Posting Type" = GenJournalLine."Gen. Posting Type"::Purchase) THEN BEGIN
                GenJnlAux.SETRANGE("Document No.", GenJournalLine."Document No.");
                GenJnlAux.SETRANGE("Document Type", GenJournalLine."Document Type");
                GenJnlAux.SETFILTER("Bill-to/Pay-to No.", '<> %1', '');
                if GenJnlAux.FINDFIRST THEN;
                //SetTipoIDEMIDEmPaisEMNIFEm(GenJournalLine."Account No.",TipoIDEmisor,IDEmisor,PaisEmisor,NifReceptor,VendName);
                SetTipoIDEMIDEmPaisEMNIFEm(GenJnlAux."Bill-to/Pay-to No.", TipoIDEmisor, IDEmisor, PaisEmisor, NifReceptor, VendName);
                //+SII9
                if (TipoFactura = 'FR') THEN BEGIN
                    TipoFacturaSII := GenJournalLine.Banco;
                    //-SII1
                    //DocNo := GenJournalLine."Document No.";
                    DocNo := GenJournalLine."External Document No.";
                    //+SII1
                    //-SII1
                    //END ELSE
                END ELSE BEGIN
                    //DocNo := GenJournalLine."Applies-to Doc. No.";


                    Case GenJournalLine."Applies-to Doc. Type" Of

                        GenJournalLine."Applies-to Doc. Type"::" ", GenJournalLine."Applies-to Doc. Type"::Advance:
                            Dk := Dk::" ";
                        GenJournalLine."Applies-to Doc. Type"::Bill:
                            Dk := Dk::Bill;
                        GenJournalLine."Applies-to Doc. Type"::"Credit Memo":
                            Dk := Dk::"Credit Memo";
                        GenJournalLine."Applies-to Doc. Type"::"Finance Charge Memo":
                            Dk := Dk::"Finance Charge Memo";
                        GenJournalLine."Applies-to Doc. Type"::Invoice:
                            Dk := Dk::Invoice;
                        GenJournalLine."Applies-to Doc. Type"::Payment:
                            Dk := Dk::Payment;
                        GenJournalLine."Applies-to Doc. Type"::Receipt:
                            Dk := Dk::Albaran;
                        GenJournalLine."Applies-to Doc. Type"::Refund:
                            Dk := Dk::Refund;
                        GenJournalLine."Applies-to Doc. Type"::Reminder:
                            Dk := Dk::Reminder;

                    End;
                    DocNo := FindDocNoToPay(GenJournalLine."Applies-to Doc. No.", DK, GetPostingDateByDocType(1, GenJournalLine), FALSE);
                    //+SII1
                    TipoFacturaSII := 'F1';
                    //-SII1
                END;
                //+SII1
                /*factura FR desde diario general...*/
                //-SII4.00
                //WriteNewDoc(Fichero,Año,Mes,TipoFacturaSII,DocNo,Año+Mes+Dia,GenJournalLine."VAT Registration No.", VendName,
                Vendor.Get(GenJournalLine."Bill-to/Pay-to No.");
                WriteNewDoc(Fichero, Año, Mes, TipoFacturaSII, DocNo, Año + Mes + Dia, NifReceptor, VendName,
                            //+SII4.00
                            // TipoIDEmisor,IDEmisor,PaisEmisor,CompanyInformation."VAT Registration No.", CompanyInformation.Name, '','','');
                            //-SII1
                            //TipoIDEmisor,IDEmisor,PaisEmisor,GenJournalLine."VAT Registration No.", VendName, TipoIDEmisor,IDEmisor,PaisEmisor);
                            //-SII4.0
                            //TipoIDEmisor,IDEmisor,PaisEmisor,GenJournalLine."VAT Registration No.", VendName, '',CompanyInformation."VAT Registration No.",PaisEmisor);
                            TipoIDEmisor, IDEmisor, PaisEmisor, NifReceptor, VendName, TipoIDEmisor, IDEmisor, PaisEmisor, Vendor, Customer);
                //+SII4.00
                //+SII1
                if GenJournalLine."Document Type" = GenJournalLine."Document Type"::Invoice THEN BEGIN
                    /*si es factura...*/
                    WriteNewINVDOC(Fichero, VATBusPost."Clave registro SII recibidas", GenJournalLine."Descripción operación",
                                  //-SII1
                                  //Año+Mes+Dia,ChangeCommaForDot(FORMAT(ABS(CalcCuotaDeducible(TempVATAmountLines))
                                  AñoOperacion + MesOperacion + DiaOperacion, ChangeCommaForDot(FORMAT(ABS(CalcCuotaDeducible(TempVATAmountLines))
                                  //+SII1
                                  , 0, DevolverFormato(GenJournalLine."Currency Code"))),
                                  ChangeCommaForDot(FORMAT(ABS(AmtInclVAT), 0, DevolverFormato(GenJournalLine."Currency Code"))),
                                   ChangeCommaForDot(FORMAT(ABS(Amt), 0, DevolverFormato(GenJournalLine."Currency Code"))));
                    WriteNewIMPDOC(Fichero, TempVATAmountLines, FALSE, TempVATPostingSetup, FALSE, TipoFactura, GenJournalLine."Currency Code");
                END ELSE
                    if GenJournalLine."Document Type" = GenJournalLine."Document Type"::"Credit Memo" THEN BEGIN
                        /*si es abono...*/
                        //-SII1
                        //WriteNewINVDOC(Fichero,VATBusPost."Clave registro SII recibidas",GenJournalLine."Descripción operación",Año+Mes+Dia,
                        WriteNewINVDOC(Fichero, VATBusPost."Clave registro SII recibidas", GenJournalLine."Descripción operación", AñoOperacion + MesOperacion + DiaOperacion,
                                      //+SII1
                                      ChangeCommaForDot(FORMAT(-CalcCuotaDeducible(TempVATAmountLines), 0, DevolverFormato(GenJournalLine."Currency Code"))),
                                      ChangeCommaForDot(FORMAT(-(AmtInclVAT), 0, DevolverFormato(GenJournalLine."Currency Code"))),
                                       ChangeCommaForDot(FORMAT(-Amt, 0, DevolverFormato(GenJournalLine."Currency Code"))));
                        WriteNewIMPDOC(Fichero, TempVATAmountLines, TRUE, TempVATPostingSetup, FALSE, TipoFactura, GenJournalLine."Currency Code");
                        //-SII 3.0
                        WriteNewRECDOC(Fichero, TempVATAmountLines, GenJournalLine."Tipo factura rectificativa", GenJournalLine."Currency Code");
                        //+SII 3.0
                    END;
                /*si es factura PR desde diario de pago*/
                if TipoFactura = 'PR' THEN BEGIN
                    Case GenJournalLine."Document Type" Of

                        GenJournalLine."Document Type"::" ", GenJournalLine."Document Type"::Advance:
                            Dk := Dk::" ";
                        GenJournalLine."Document Type"::Bill:
                            Dk := Dk::Bill;
                        GenJournalLine."Document Type"::"Credit Memo":
                            Dk := Dk::"Credit Memo";
                        GenJournalLine."Document Type"::"Finance Charge Memo":
                            Dk := Dk::"Finance Charge Memo";
                        GenJournalLine."Document Type"::Invoice:
                            Dk := Dk::Invoice;
                        GenJournalLine."Document Type"::Payment:
                            Dk := Dk::Payment;
                        GenJournalLine."Document Type"::Receipt:
                            Dk := Dk::Albaran;
                        GenJournalLine."Document Type"::Refund:
                            Dk := Dk::Refund;
                        GenJournalLine."Document Type"::Reminder:
                            Dk := Dk::Reminder;

                    End;
                    WritePR(Fichero, NOT (GenJournalLine."Document Type" IN [GenJournalLine."Document Type"::"Credit Memo",
                            GenJournalLine."Document Type"::Refund]), GenJournalLine."Document No.", Dk
                            , GenJournalLine."Posting Date", GenJournalLine."Currency Code");
                END;
            END;
        FicheroCLOSE(Fichero);
        //+001

    end;

#pragma warning disable AL0432
    local procedure CalcVatLinesGenJnlLine(DocNo: Code[20]; PostingDate: Date; DocType: Enum "Document Type Kuara"; var TempVATAmountLines: Record "VAT Amount Line" Temporary; var TempVATPostingSetup: Record 325 temporary)
#pragma warning restore AL0432
    var
        VATEntry: Record 254;
        VATPostingSetup: Record 325;
        tipofac: Code[3];
        "//-EXP01": Integer;
        EmptyString: Text;
        "//+EXP01": Integer;
    begin
        //-SII1
        //if NOT (DocType IN [DocType::Payment,DocType::Bill]) THEN
        //  EXIT;
        VATEntry.SETRANGE("Document No.", DocNo);
        //comprobar que no de problemas!!!
        //VATEntry.SETRANGE("Document Date",GenJournalLine."Document Date");
        VATEntry.SETRANGE("Posting Date", PostingDate);
        //-SII1
        //VATEntry.SETRANGE("Document Type",DocType);
        //+SII1
        //VATEntry.SETRANGE("VAT Registration No.",GenJournalLine."VAT Registration No.");
        if VATEntry.FINDSET THEN
            REPEAT
                VATPostingSetup.GET(VATEntry."VAT Bus. Posting Group", VATEntry."VAT Prod. Posting Group");
                //-EXP01
                if Export THEN
                    NoConflictInDocument(TRUE, VATEntry."Document No.", VATEntry."VAT Bus. Posting Group",
                                         VATEntry."VAT Prod. Posting Group", EmptyString);
                //+EXP01
                if NOT VATPostingSetup."Obviar SII" THEN BEGIN
                    TempVATAmountLines.SETRANGE("VAT Identifier", VATEntry."VAT Prod. Posting Group");
                    if NOT TempVATAmountLines.FINDFIRST THEN BEGIN
                        TempVATAmountLines."VAT %" := VATEntry."VAT %";
                        if (CriterioCaja(DocNo, PostingDate)) THEN BEGIN
                            TempVATAmountLines."VAT Base" := ABS(VATEntry."Unrealized Base");
                            TempVATAmountLines."VAT Amount" := ABS(VATEntry."Unrealized Amount");
                            TempVATAmountLines."Amount Including VAT" := ABS(VATEntry."Unrealized Base" + VATEntry."Unrealized Amount");
                        END ELSE BEGIN
                            TempVATAmountLines."VAT Base" := ABS(VATEntry.Base);
                            TempVATAmountLines."VAT Amount" := ABS(VATEntry.Amount);
                            TempVATAmountLines."Amount Including VAT" := ABS(VATEntry.Base + VATEntry.Amount);
                        END;
                        TempVATAmountLines."VAT Identifier" := VATEntry."VAT Prod. Posting Group";
                        TempVATAmountLines."EC %" := VATEntry."EC %";
                        TempVATAmountLines."EC Amount" := ABS((VATEntry."EC %" * TempVATAmountLines."VAT Base") / 100);
                        //-SII1
                        TempVATAmountLines."VAT Amount" -= TempVATAmountLines."EC Amount";
                        //+SII1
                        //-c2
                        //TempVATAmountLines."VAT Amount" -= TempVATAmountLines."EC Amount";
                        //+c2
                        //TempVATAmountLines."Amount Including VAT" += TempVATAmountLines."EC Amount";
                        TempVATAmountLines.INSERT;
                    END ELSE BEGIN
                        if (CriterioCaja(DocNo, PostingDate)) THEN BEGIN
                            TempVATAmountLines."VAT Base" += ABS(VATEntry."Unrealized Base");
                            TempVATAmountLines."VAT Amount" += ABS(VATEntry."Unrealized Amount");
                            TempVATAmountLines."Amount Including VAT" += ABS(VATEntry."Unrealized Base" + VATEntry."Unrealized Amount");
                        END ELSE BEGIN
                            TempVATAmountLines."VAT Base" += ABS(VATEntry.Base);
                            TempVATAmountLines."VAT Amount" += ABS(VATEntry.Amount);
                            TempVATAmountLines."Amount Including VAT" += ABS(VATEntry.Base + VATEntry.Amount);
                        END;
                        TempVATAmountLines."EC Amount" += ABS((VATEntry."EC %" * TempVATAmountLines."VAT Base") / 100);
                        //-SII1
                        TempVATAmountLines."VAT Amount" -= TempVATAmountLines."EC Amount";
                        //+SII1
                        //-c2
                        //TempVATAmountLines."VAT Amount" -= TempVATAmountLines."EC Amount";
                        //+c2
                        //TempVATAmountLines."Amount Including VAT" += TempVATAmountLines."EC Amount";
                        TempVATAmountLines.MODIFY;
                    END;
                    if VATPostingSetup.GET(VATEntry."VAT Bus. Posting Group", VATEntry."VAT Prod. Posting Group") THEN BEGIN
                        TempVATPostingSetup := VATPostingSetup;
                        if TempVATPostingSetup.INSERT THEN;
                    END;
                END;
            UNTIL VATEntry.NEXT = 0;
    end;

    local procedure PreviousSalesHdrChecks(var SalesHeader: Record 36; IVACaja: Boolean)
    var
        Number: Integer;
        CompanyInformation: Record 79;
        Customer: Record Customer;
        Text001: Label 'El valor del campo tipo factura SII debe ser numerico';
        Text002: Label 'El valor del campo tipo factura rectificativa debe ser numerico';
    begin
        /*if NOT HasVAT THEN
          EXIT;*/
        /*if IVACaja THEN
          OpenOrCreateFile('CE',TRUE)
        ELSE*/
        OpenOrCreateFile('FE', TRUE);

        SalesHeader.TESTFIELD("Tipo factura SII");
        //-jb
        /*if NOT EVALUATE(Number,SalesHeader."Tipo factura SII") THEN
          ERROR(Text001);*/
        //+jb
        //-SII1
        //if (SalesHeader."Document Type" = SalesHeader."Document Type"::"Credit Memo") OR
        //    (SalesHeader."Document Type" = SalesHeader."Document Type"::"Return Order") THEN BEGIN
        //if SalesHeader."Corrected Invoice No." <> '' THEN BEGIN

        //SalesHeader.TESTFIELD("Tipo factura rectificativa");
        //-jb
        //if IsNumeric(FORMAT(SalesHeader."Tipo factura SII"[1])) THEN
        //+jb
        //  SalesHeader."Tipo factura SII" := INSSTR(SalesHeader."Tipo factura SII",'R',1);
        //+SII1
        //END;
        //+SII1
        //ELSE
        //-jb
        //if IsNumeric(FORMAT(SalesHeader."Tipo factura SII"[1])) THEN
        //+jb
        //  SalesHeader."Tipo factura SII" := INSSTR(SalesHeader."Tipo factura SII",'F',1);
        //+SII1
        CompanyInformation.GET;
        CompanyInformation.TESTFIELD("VAT Registration No.");
        CompanyInformation.TESTFIELD(Name);
        Customer.GET(SalesHeader."Bill-to Customer No.");
        if Customer."Tipo ID receptor" = '07' THEN EXIT;
        Customer.TESTFIELD(Name);
        if Customer."VAT Registration No." = '' THEN BEGIN
            Customer.TESTFIELD("Tipo ID receptor");
            // if NOT (Customer."Cliente Directo") AND NOT (Customer."Cliente Contado") THEN
            Customer.TESTFIELD("ID receptor");
            Customer.TESTFIELD("Country/Region Code");
        END;
        GLSetup.TESTFIELD("Nif Titular Registro");
        GLSetup.TESTFIELD("Nombre Titular Registro");
        GLSetup.TESTFIELD("Ruta fichero SII");

    end;

    local procedure PreviousPurchHdrChecks(var PurchaseHeader: Record 38; IVACaja: Boolean)
    var
        CompanyInformation: Record 79;
        Number: Integer;
        Vendor: Record Vendor;
        Text001: Label 'El valor del campo tipo factura SII debe ser numerico';
        Text002: Label 'El valor del campo tipo factura rectificativa debe ser numerico';
    begin
        /*if NOT HasVAT THEN
          EXIT;*/
        /*if IVACaja THEN
          OpenOrCreateFile('PR',TRUE)
        ELSE*/
        OpenOrCreateFile('FR', TRUE);
        //-jb
        /*if NOT EVALUATE(Number,PurchaseHeader."Tipo factura SII") THEN
          ERROR(Text001);*/
        //+jb
        //-SII1
        //if (PurchaseHeader."Document Type" = PurchaseHeader."Document Type"::"Credit Memo") OR
        //    (PurchaseHeader."Document Type" = PurchaseHeader."Document Type"::"Return Order")THEN BEGIN
        //    PurchaseHeader.TESTFIELD("Tipo factura rectificativa");
        //-jb
        //if IsNumeric(FORMAT(PurchaseHeader."Tipo factura SII"[1])) THEN
        //+jb
        //  PurchaseHeader."Tipo factura SII" := INSSTR(PurchaseHeader."Tipo factura SII",'R',1);
        //+SII1
        //END;
        //-SII1
        // ELSE
        //-jb
        //if IsNumeric(FORMAT(PurchaseHeader."Tipo factura SII"[1])) THEN
        //+jb
        //  PurchaseHeader."Tipo factura SII" := INSSTR(PurchaseHeader."Tipo factura SII",'F',1);
        //+SII1
        PurchaseHeader.TESTFIELD("Tipo factura SII");
        CompanyInformation.GET;
        CompanyInformation.TESTFIELD("VAT Registration No.");
        CompanyInformation.TESTFIELD(Name);
        Vendor.GET(PurchaseHeader."Buy-from Vendor No.");
        Vendor.TESTFIELD(Name);
        if Vendor."VAT Registration No." = '' THEN BEGIN
            Vendor.TESTFIELD("Tipo ID emisor");
            Vendor.TESTFIELD("ID emisor");
            Vendor.TESTFIELD("Country/Region Code");
        END;
        GLSetup.TESTFIELD("Nif Titular Registro");
        GLSetup.TESTFIELD("Nombre Titular Registro");
        GLSetup.TESTFIELD("Ruta fichero SII");

    end;

    local procedure CriterioCaja(NoDoc: Code[20]; PostingDate: Date): Boolean
    var
        VATEntry: Record 254;
        VATCashRegime: Boolean;
        NotPaid: Boolean;
    begin
        VATEntry.SETRANGE("Document No.", NoDoc);
        //posting date es incorrecto.
        VATEntry.SETRANGE("Posting Date", PostingDate);
        VATEntry.SETRANGE("VAT Cash Regime", TRUE);
        VATCashRegime := VATEntry.FINDFIRST;
        //comprobamos que no se haya hecho la contrapartida al momento de registrar y que sea criterio caja...
        //VATEntry.SETFILTER("Document Type",'%1|%2|%3',VATEntry."Document Type"::Payment,
        //VATEntry."Document Type"::Refund,VATEntry."Document Type"::Bill);
        //falta que al registrar los diarios de pago, se genere correctamente el fichero ya
        //que falta el impdoc al registrarlo, corregir linea de abajo o probar. nose si sta bn
        VATEntry.SETFILTER("Remaining Unrealized Base", '<> %1', 0);
        NotPaid := VATEntry.FINDFIRST;
        EXIT((VATCashRegime AND NotPaid));
    end;

    local procedure OpenFile(RutaFichero: Text; var Fichero: OutStream; Doc: Code[20]; Nuevo: Boolean)
    var
        tFicheros: Record Ficheros;
    begin

        // Ficheros.Reset;
        if Ficheros.FindLast() then
            a := Ficheros.Secuencia + 1
        else
            a := 1;
        Ficheros.Init();
        Ficheros.Nueva := Nuevo;
        Ficheros.Secuencia := a;
        Ficheros."Nombre fichero" := RutaFichero;
        Ficheros.Procesado := false;
        Ficheros.Proceso := 'SII';
        Ficheros."Fecha Caducidad" := CalcDate('PM+2M', WorkDate());
        Ficheros.Id_Url := 0;
        Ficheros.Insert(True);
        Ficheros.CalcFields(Fichero);
        Ficheros.Fichero.CreateOutStream(Fichero);
        // Fichero.TEXTMODE := TRUE;
        // Fichero.AddTextMODE := TRUE;
        // Fichero.OPEN(RutaFichero, TEXTENCODING::Windows);
        // Fichero.SEEK(Fichero.Length);
    end;

    local procedure SetMedioCuentaMedio(BalAccNo: Code[20]; PayMethodCode: Code[10]; var Medio: Code[3]; var CuentaMedio: Code[34])
    var
        PaymentMethod: Record 289;
        BankAccount: Record 270;
    begin
        PaymentMethod.GET(PayMethodCode);
        if BalAccNo <> '' THEN BEGIN
            BankAccount.GET(BalAccNo);
            CuentaMedio := BankAccount.IBAN;
        END;
        Medio := PaymentMethod."Medio pago SII";
    end;

    local procedure GetPostingDateByDocType(AccountType: Option Customer,Vendor; GenJournalLine: Record 81) PostingDate: Date
    var
        SalesInvoiceHeader: Record 112;
        SalesCrMemoHeader: Record 114;
        PurchInvHeader: Record "Purch. Inv. Header";
        PurchCrMemoHdr: Record "Purch. Cr. Memo Hdr.";
        CustLedgerEntry: Record 21;
        VendorLedgerEntry: Record 25;
    begin
        if AccountType = AccountType::Customer THEN BEGIN
            if GenJournalLine."Applies-to Doc. Type" = GenJournalLine."Applies-to Doc. Type"::Invoice THEN BEGIN
                if NOT SalesInvoiceHeader.GET(GenJournalLine."Applies-to Doc. No.") THEN BEGIN
                    CustLedgerEntry.SETRANGE("Document Type", CustLedgerEntry."Document Type"::Invoice);
                    PostingDate := GetPostingDateCustVend(0, CustLedgerEntry, VendorLedgerEntry, GenJournalLine."Applies-to Doc. No.");
                END ELSE
                    PostingDate := SalesInvoiceHeader."Posting Date";
            END ELSE
                if GenJournalLine."Applies-to Doc. Type" = GenJournalLine."Applies-to Doc. Type"::"Credit Memo" THEN BEGIN
                    if NOT SalesCrMemoHeader.GET(GenJournalLine."Applies-to Doc. No.") THEN BEGIN
                        CustLedgerEntry.SETRANGE("Document Type", CustLedgerEntry."Document Type"::"Credit Memo");
                        PostingDate := GetPostingDateCustVend(0, CustLedgerEntry, VendorLedgerEntry, GenJournalLine."Applies-to Doc. No.");
                    END ELSE
                        PostingDate := SalesCrMemoHeader."Posting Date";
                END;
        END ELSE BEGIN
            if GenJournalLine."Applies-to Doc. Type" = GenJournalLine."Applies-to Doc. Type"::Invoice THEN BEGIN
                if NOT PurchInvHeader.GET(GenJournalLine."Applies-to Doc. No.") THEN BEGIN
                    VendorLedgerEntry.SETRANGE("Document Type", VendorLedgerEntry."Document Type"::Invoice);
                    PostingDate := GetPostingDateCustVend(1, CustLedgerEntry, VendorLedgerEntry, GenJournalLine."Applies-to Doc. No.");
                END ELSE
                    PostingDate := PurchInvHeader."Posting Date";
            END ELSE
                if GenJournalLine."Applies-to Doc. Type" = GenJournalLine."Applies-to Doc. Type"::"Credit Memo" THEN BEGIN
                    if NOT PurchCrMemoHdr.GET(GenJournalLine."Applies-to Doc. No.") THEN BEGIN
                        VendorLedgerEntry.SETRANGE("Document Type", VendorLedgerEntry."Document Type"::"Credit Memo");
                        PostingDate := GetPostingDateCustVend(1, CustLedgerEntry, VendorLedgerEntry, GenJournalLine."Applies-to Doc. No.");
                    END ELSE
                        PostingDate := PurchCrMemoHdr."Posting Date";
                END;
        END;
    end;

    local procedure GetPostingDateCustVend(AccountType: Option Customer,Vendor; var CustLedgerEntry: Record 21; var VendorLedgerEntry: Record 25; DocNo: Code[20]) PostingDate: Date
    begin
        if AccountType = AccountType::Customer THEN BEGIN
            CustLedgerEntry.SETRANGE("Document No.", DocNo);
            //si no existe el documento es normal que dé error.
            CustLedgerEntry.FINDFIRST;
            PostingDate := CustLedgerEntry."Posting Date";
        END ELSE BEGIN
            VendorLedgerEntry.SETRANGE("Document No.", DocNo);
            //si no existe el documento es normal que dé error.
            VendorLedgerEntry.FINDFIRST;
            PostingDate := VendorLedgerEntry."Posting Date";
        END;
    end;


    /// <summary>
    /// CheckServiceRequiredFields.
    /// </summary>
    /// <param name="ServiceHeader">VAR Record 5900.</param>
    /// <param name="ModifyHdr">VAR Boolean.</param>
    procedure CheckServiceRequiredFields(var ServiceHeader: Record 5900; var ModifyHdr: Boolean)
    var
        ServiceLine: Record 5902;
        VATPostingSetup: Record 325;
        IVACaja: Boolean;
        VATBusPostGrp: Record 323;
    begin
        //-001
        HasVAT := FALSE;
        GetGLSetup;
        //-SII1
        if (GLSetup."Exportar SII desde fecha" <> 0D) THEN
            if (ServiceHeader."Posting Date" < GLSetup."Exportar SII desde fecha") THEN
                EXIT;
        //+SII1
        ServiceLine.SETRANGE("Document No.", ServiceHeader."No.");
        ServiceLine.SETRANGE("Document Type", ServiceHeader."Document Type");
        ServiceLine.FINDSET;
        REPEAT
            if ServiceLine.Type <> ServiceLine.Type::" " THEN BEGIN
                VATPostingSetup.GET(ServiceLine."VAT Bus. Posting Group", ServiceLine."VAT Prod. Posting Group");
                VATBusPostGrp.GET(VATPostingSetup."VAT Bus. Posting Group");
                HasVAT := PreviousServiceChecks(VATPostingSetup, ServiceHeader, VATBusPostGrp);
            END;
        UNTIL (ServiceLine.NEXT = 0);
        /*if NOT HasVAT THEN
          EXIT;*/
        //-SII1
        //ModifyHdr := ServiceHeader.UpdateFieldsSII;
        //+SII1
        IVACaja := CriterioCaja(ServiceHeader."No.", ServiceHeader."Posting Date");
        if NOT IVACaja THEN BEGIN
            ServiceHeader.TESTFIELD("Descripción operación");
            VATBusPostGrp.TESTFIELD("Clave registro SII expedidas");
        END;

        PreviousServiceHdrChecks(ServiceHeader, IVACaja);
        //+001

    end;


    /// <summary>
    /// PreviousServiceChecks.
    /// </summary>
    /// <param name="VATPostingSetup">VAR Record 325.</param>
    /// <param name="ServiceHeader">VAR Record 5900.</param>
    /// <param name="VATBusPostGrp">VAR Record 323.</param>
    /// <returns>Return value of type Boolean.</returns>
    procedure PreviousServiceChecks(var VATPostingSetup: Record 325; var ServiceHeader: Record 5900; var VATBusPostGrp: Record 323): Boolean
    begin
        //-001
        //if VATPostingSetup."VAT Calculation Type" <> VATPostingSetup."VAT Calculation Type"::"No Taxable VAT" THEN BEGIN
        VATPostingSetup.TESTFIELD("Sujeta exenta");
        if VATPostingSetup."Sujeta exenta" <> 'NS' THEN
            VATPostingSetup.TESTFIELD("Tipo de operación");
        VATPostingSetup.TESTFIELD("Tipo desglose emitidas");
        EXIT(TRUE);
        //END;
        //EXIT(FALSE);
        //+001
    end;

    local procedure PreviousServiceHdrChecks(var ServiceHeader: Record 5900; IVACaja: Boolean)
    var
        Number: Integer;
        CompanyInformation: Record 79;
        Customer: Record Customer;
        Text001: Label 'El valor del campo tipo factura SII debe ser numerico';
        Text002: Label 'El valor del campo tipo factura rectificativa debe ser numerico';
    begin
        /*if NOT HasVAT THEN
          EXIT;*/
        /*if IVACaja THEN
          OpenOrCreateFile('CE',TRUE)
        ELSE*/
        OpenOrCreateFile('FE', TRUE);

        ServiceHeader.TESTFIELD("Tipo factura SII");
        //-jb
        /*if NOT EVALUATE(Number,ServiceHeader."Tipo factura SII") THEN
          ERROR(Text001);*/
        //+jb
        //-SII1
        //if (ServiceHeader."Document Type" = ServiceHeader."Document Type"::"Credit Memo") THEN BEGIN
        //ServiceHeader.TESTFIELD("Tipo factura rectificativa");
        //-jb
        //if IsNumeric(FORMAT(ServiceHeader."Tipo factura SII"[1])) THEN
        //+jb
        //  ServiceHeader."Tipo factura SII" := INSSTR(ServiceHeader."Tipo factura SII",'R',1);
        //+SII1
        //END ELSE
        //-SII1
        //-jb
        //if IsNumeric(FORMAT(ServiceHeader."Tipo factura SII"[1])) THEN
        //+jb
        //  ServiceHeader."Tipo factura SII" := INSSTR(ServiceHeader."Tipo factura SII",'F',1);
        //+SII1
        CompanyInformation.GET;
        CompanyInformation.TESTFIELD("VAT Registration No.");
        CompanyInformation.TESTFIELD(Name);
        Customer.GET(ServiceHeader."Bill-to Customer No.");
        Customer.TESTFIELD(Name);
        if Customer."VAT Registration No." = '' THEN BEGIN
            Customer.TESTFIELD("Tipo ID receptor");
            Customer.TESTFIELD("ID receptor");
            Customer.TESTFIELD("Country/Region Code");
        END;
        GLSetup.TESTFIELD("Nif Titular Registro");
        GLSetup.TESTFIELD("Nombre Titular Registro");
        GLSetup.TESTFIELD("Ruta fichero SII");

    end;


    /// <summary>
    /// CreateOrUpdateFileService.
    /// </summary>
    /// <param name="ServiceInvoiceHeaderNo">Code[20].</param>
    /// <param name="ServiceCrMemoHeaderNo">Code[20].</param>
    /// <param name="WriteIMPDOC">Boolean.</param>
    procedure CreateOrUpdateFileService(ServiceInvoiceHeaderNo: Code[20]; ServiceCrMemoHeaderNo: Code[20]; WriteIMPDOC: Boolean)
    var
        Fichero: OutStream;
        RutaFichero: Text[250];
        TipoIDreceptor: Code[3];
        IDreceptor: Code[20];
        Paisreceptor: Code[10];
        CompanyInformation: Record 79;
        "Año": Text;
        Mes: Text;
        Dia: Text;
        NifReceptor: Code[20];
#pragma warning disable AL0432
        TempVATAmountLines: Record "VAT Amount Line" Temporary;
#pragma warning restore AL0432
        TempVatPostStp: Record 325 temporary;
        VATBusPostGrp: Record 323;
        IVACaja: Boolean;
        ServiceInvoiceHeader: Record 5992;
        ServiceCrMemoHeader: Record 5994;
        CustName: Text[100];
        AmtIncVAT: Decimal;
        Amt: Decimal;
        "//-EXP01": Integer;
        Description: Text;
        "//+EXP01": Integer;
        Customer: Record Customer;
        Vendor: Record Vendor;
    begin
        Customer.Init;
        Vendor.Init;
        //-EXP01
        if Export THEN BEGIN
            Description := Text011;
            if CreateFilePerDocument THEN BEGIN
                if ServiceInvoiceHeaderNo <> '' THEN
                    DocNumber := ServiceInvoiceHeaderNo
                ELSE
                    DocNumber := ServiceCrMemoHeaderNo;
            END;
        END;
        if ServiceInvoiceHeaderNo <> '' THEN
            ServiceInvoiceHeader.GET(ServiceInvoiceHeaderNo);
        if ServiceCrMemoHeaderNo <> '' THEN
            ServiceCrMemoHeader.GET(ServiceCrMemoHeaderNo);
        //+EXP01
        //-001
        /*if NOT HasVAT THEN
          EXIT;*/
        /*if ServiceInvoiceHeaderNo = '' THEN
          IVACaja := CriterioCaja(ServiceCrMemoHeaderNo,ServiceInvoiceHeader."Posting Date")
        ELSE
          IVACaja := CriterioCaja(ServiceInvoiceHeader."No.",ServiceInvoiceHeader."Posting Date");*/
        /*if IVACaja THEN
          EXIT;*/
        //-SII1
        // -SII10
        if g_codeTipoFichero = '' THEN
            g_codeTipoFichero := 'A0';
        // +SII10
        GetGLSetup;
        if (GLSetup."Exportar SII desde fecha" <> 0D) THEN
            if ServiceInvoiceHeaderNo <> '' THEN BEGIN
                ServiceInvoiceHeader.GET(ServiceInvoiceHeaderNo);
                if (ServiceInvoiceHeader."Posting Date" < GLSetup."Exportar SII desde fecha") THEN
                    //-EXP01
                    if NOT Export THEN
                        //+EXP01
                        EXIT;
            END ELSE
                if ServiceCrMemoHeaderNo <> '' THEN BEGIN
                    ServiceCrMemoHeader.GET(ServiceCrMemoHeaderNo);
                    if (ServiceCrMemoHeader."Posting Date" < GLSetup."Exportar SII desde fecha") THEN
                        //-EXP01
                        if NOT Export THEN
                            //+EXP01
                            EXIT;
                END;
        //+SII1
        if (ServiceInvoiceHeaderNo <> '') OR (ServiceCrMemoHeaderNo <> '') THEN BEGIN
            ExistsFile := FALSE;
            if ServiceInvoiceHeader."No." <> '' Then
                OpenFile(OpenOrCreateFile('FE', FALSE), Fichero, ServiceInvoiceHeader."No.", false)
            else
                OpenFile(OpenOrCreateFile('FE', FALSE), Fichero, ServiceCrmemoHeader."No.", false);
            GetGLSetup;
            CompanyInformation.GET;
            if Lenght = 0 THEN
                //-SII10
                //WriteNewFile(Fichero,GLSetup,'FE','A0');
                WriteNewFile(Fichero, GLSetup, 'FE', g_codeTipoFichero);
            //+SII10
        END;
        if ServiceInvoiceHeaderNo <> '' THEN BEGIN
            /*Si se factura una factura de venta...*/
            //-SII1
            //ServiceInvoiceHeader.GET(ServiceInvoiceHeaderNo);
            //+SII1
            //-EXP01
            if NOT Export THEN
                Description := ServiceInvoiceHeader."Descripción operación"
            ELSE
                ServiceInvoiceHeader."Tipo factura SII" := 'F1';
            //+EXP01
            Customer.Get(ServiceInvoiceHeader."Bill-to Customer No.");
            DevolverAnoMesDia(ServiceInvoiceHeader."Document Date", Año, Mes, Dia);
            SetTipoIDRecIDRecPaisRecNIFRec(ServiceInvoiceHeader."Bill-to Customer No.", TipoIDreceptor, IDreceptor,
                                          Paisreceptor, NifReceptor, CustName, '', '', '');
            WriteNewDoc(Fichero, Año, Mes, ServiceInvoiceHeader."Tipo factura SII", ServiceInvoiceHeader."No.", Año + Mes + Dia,
                        CompanyInformation."VAT Registration No.", CompanyInformation.Name,
                        '', '', '', NifReceptor, CustName, TipoIDreceptor, IDreceptor, Paisreceptor, Vendor, Customer);
            VATBusPostGrp.GET(ServiceInvoiceHeader."VAT Bus. Posting Group");
            //-EXP01
            if Export THEN
                if NOT (VATBusPostGrp."Clave registro SII expedidas" IN ['11', '12', '13']) THEN
                    VATBusPostGrp."Clave registro SII expedidas" := '16';
            //+EXP01
            CalcServiceAmount(ServiceInvoiceHeader."No.", 0, AmtIncVAT, Amt);
            //-EXP01
            //WriteNewINVDOC(Fichero,VATBusPostGrp."Clave registro SII expedidas",ServiceInvoiceHeader."Descripción operación",Año+Mes+Dia,'',
            WriteNewINVDOC(Fichero, VATBusPostGrp."Clave registro SII expedidas", Description, Año + Mes + Dia, '',
                           //+EXP01
                           ChangeCommaForDot(FORMAT(AmtIncVAT, 0, DevolverFormato(ServiceInvoiceHeader."Currency Code"))),
                           ChangeCommaForDot(FORMAT(Amt, 0, DevolverFormato(ServiceInvoiceHeader."Currency Code"))));
            CalcVATAmtLines(4, ServiceInvoiceHeader."No.", TempVATAmountLines, TempVatPostStp);
            //llamar
            //-SII1
            //aplicamos divisas
            ApplyCurrencyFactor(TempVATAmountLines, ServiceInvoiceHeader."Currency Factor");
            //+SII1
            WriteNewIMPDOC(Fichero, TempVATAmountLines, FALSE, TempVatPostStp, TRUE, 'FE', ServiceInvoiceHeader."Currency Code");
            //-SII1
            if WriteIMPDOC THEN
                WriteNewRECDOC(Fichero, TempVATAmountLines, ServiceInvoiceHeader."Tipo factura rectificativa", ServiceInvoiceHeader."Currency Code");
            //+SII1
            ServiceInvoiceHeader."Reportado SII" := TRUE;
            ServiceInvoiceHeader."Nombre fichero SII" := RutaFichero;
            ServiceInvoiceHeader."Fecha/hora subida fichero SII" := CURRENTDATETIME;
            //-EXP01
            if Export THEN BEGIN
                ServiceInvoiceHeader."Reportado SII primer semestre" := TRUE;
                ServiceInvoiceHeader."Descripción operación" := Description;
            END;
            //+EXP01
            ServiceInvoiceHeader.MODIFY;
            //-jb
            FicheroCLOSE(Fichero);//+jbç
                                  //-SII1
                                  //END ELSE BEGIN
        END;
        if ServiceCrMemoHeaderNo <> '' THEN BEGIN
            //+SII1
            //-EXP01
            if NOT Export THEN
                Description := ServiceCrMemoHeader."Descripción operación"
            ELSE
                ServiceCrMemoHeader."Tipo factura SII" := 'F1';
            //+EXP01
            /*Si se factura un abono...*/
            //-SII1
            //ServiceCrMemoHeader.GET(ServiceCrMemoHeaderNo);
            //+SII1
            Customer.Get(ServiceCrMemoHeader."Bill-to Customer No.");
            DevolverAnoMesDia(ServiceCrMemoHeader."Document Date", Año, Mes, Dia);
            SetTipoIDRecIDRecPaisRecNIFRec(ServiceCrMemoHeader."Bill-to Customer No.", TipoIDreceptor, IDreceptor, Paisreceptor, NifReceptor, CustName, '', '', '');
            WriteNewDoc(Fichero, Año, Mes, ServiceCrMemoHeader."Tipo factura SII", ServiceCrMemoHeader."No.", Año + Mes + Dia,
                        CompanyInformation."VAT Registration No.", CompanyInformation.Name,
                        '', '', '', NifReceptor, CustName, TipoIDreceptor, IDreceptor, Paisreceptor, Vendor, Customer);
            VATBusPostGrp.GET(ServiceCrMemoHeader."VAT Bus. Posting Group");
            //-EXP01
            if Export THEN
                if NOT (VATBusPostGrp."Clave registro SII expedidas" IN ['11', '12', '13']) THEN
                    VATBusPostGrp."Clave registro SII expedidas" := '16';
            //+EXP01
            CalcServiceAmount(ServiceCrMemoHeader."No.", 1, AmtIncVAT, Amt);
            //-EXP01
            //WriteNewINVDOC(Fichero,VATBusPostGrp."Clave registro SII expedidas",ServiceCrMemoHeader."Descripción operación",Año+Mes+Dia,'',
            WriteNewINVDOC(Fichero, VATBusPostGrp."Clave registro SII expedidas", Description, Año + Mes + Dia, '',
                           //+EXP01
                           ChangeCommaForDot(FORMAT(-AmtIncVAT, 0, DevolverFormato(ServiceCrMemoHeader."Currency Code"))),
                           ChangeCommaForDot(FORMAT(-Amt, 0, DevolverFormato(ServiceCrMemoHeader."Currency Code"))));
            CalcVATAmtLines(5, ServiceCrMemoHeader."No.", TempVATAmountLines, TempVatPostStp);
            //llamar
            //-SII1
            //aplicamos divisas
            ApplyCurrencyFactor(TempVATAmountLines, ServiceCrMemoHeader."Currency Factor");
            //+SII1
            WriteNewIMPDOC(Fichero, TempVATAmountLines, TRUE, TempVatPostStp, TRUE, 'FE', ServiceCrMemoHeader."Currency Code");
            //if ServiceCrMemoHeader."Corrected Invoice No." <> '' THEN
            WriteNewRECDOC(Fichero, TempVATAmountLines, ServiceCrMemoHeader."Tipo factura rectificativa", ServiceCrMemoHeader."Currency Code");
            ServiceCrMemoHeader."Reportado SII" := TRUE;
            ServiceCrMemoHeader."Nombre fichero SII" := RutaFichero;
            ServiceCrMemoHeader."Fecha/hora subida fichero SII" := CURRENTDATETIME;
            //-EPX01
            if Export THEN BEGIN
                ServiceCrMemoHeader."Reportado SII primer semestre" := TRUE;
                ServiceCrMemoHeader."Descripción operación" := Description;
            END;
            //+EXP01
            ServiceCrMemoHeader.MODIFY;
            //-jb
            FicheroCLOSE(Fichero);
            //+jb
        END;
        //+001

    end;

    local procedure CalcServiceAmount(var No: Code[20]; DocType: Option Factura,Abono; var AmtInclVAT: Decimal; var Amt: Decimal)
    var
        ServiceInvoiceLine: Record 5993;
        ServiceCrMemoLine: Record 5995;
        VATPostingSetup: Record 325;
        ServiceInvoiceHeader: Record 5992;
        ServiceCrMemoHeader: Record 5994;
    begin
        CASE DocType OF
            DocType::Factura:
                BEGIN
                    ServiceInvoiceLine.SETRANGE("Document No.", No);
                    ServiceInvoiceLine.FINDSET;
                    REPEAT
                        if VATPostingSetup.GET(ServiceInvoiceLine."VAT Bus. Posting Group", ServiceInvoiceLine."VAT Prod. Posting Group") THEN
                            if NOT (VATPostingSetup."Obviar SII") THEN BEGIN
                                Amt += ServiceInvoiceLine.Amount;
                                AmtInclVAT += ServiceInvoiceLine."Amount Including VAT";
                            END;
                    UNTIL ServiceInvoiceLine.NEXT = 0;
                    //-SII1
                    ServiceInvoiceHeader.GET(No);
                    if ServiceInvoiceHeader."Currency Factor" <> 0 THEN BEGIN
                        Amt /= ServiceInvoiceHeader."Currency Factor";
                        AmtInclVAT /= ServiceInvoiceHeader."Currency Factor";
                    END;
                    //+SII1
                END;
            DocType::Abono:
                BEGIN
                    ServiceCrMemoLine.SETRANGE("Document No.", No);
                    ServiceCrMemoLine.FINDSET;
                    REPEAT
                        if VATPostingSetup.GET(ServiceCrMemoLine."VAT Bus. Posting Group", ServiceCrMemoLine."VAT Prod. Posting Group") THEN
                            if NOT (VATPostingSetup."Obviar SII") THEN BEGIN
                                Amt += ServiceCrMemoLine.Amount;
                                AmtInclVAT += ServiceCrMemoLine."Amount Including VAT";
                            END;
                    UNTIL ServiceCrMemoLine.NEXT = 0;
                    //-SII1
                    ServiceCrMemoHeader.GET(No);
                    if ServiceCrMemoHeader."Currency Factor" <> 0 THEN BEGIN
                        Amt /= ServiceCrMemoHeader."Currency Factor";
                        AmtInclVAT /= ServiceCrMemoHeader."Currency Factor";
                    END;
                    //+SII1
                END;
        END;
    end;

    local procedure SetTipoIDRecIDRecPaisRecNIFRec(BillTo: Code[20]; var TipoIDreceptor: Code[3]; var IDreceptor: Code[20]; var CountryCode: Code[10]; var NifReceptor: Code[20]; var Name: Text[100]; Cif: Text; Nom: Text; Pais: Text)
    var
        Customer: Record Customer;
        CustCountryType: Integer;
        rPais: Record 9;
    begin
        Customer.GET(BillTo);
        if Cif = BillTo THEN Cif := '';
        if (COPYSTR(Name, 1, 5) = 'CONTA') OR (Cif = 'X') OR (Cif = 'x') THEN BEGIN
            // Customer."Cliente Directo" := FALSE;
            // Customer."Cliente Contado" := TRUE;
            Pais := '';
            Customer."Country/Region Code" := '';

        END else
            Pais := Customer."Country/Region Code";
        if Pais = '' Then Pais := 'ES';
        if Pais = 'EN' THEN Pais := 'GB';
        // if (Customer."Cliente Directo") AND (Pais = 'ES') THEN Pais := '';
        // -SII1
        //if Customer."VAT Registration No." = '' THEN BEGIN
        // +SII1
        //  TipoIDreceptor := Customer."Tipo ID receptor";
        //  IDreceptor := Customer."ID receptor";
        //  CountryCode := Customer."Country/Region Code";
        //END ELSE
        //  NifReceptor := Customer."VAT Registration No.";
        if Pais <> '' THEN Pais := COPYSTR(Pais, 1, 2);
        if Pais = 'D' THEN Pais := 'DE';
        if Pais = 'UK' THEN Pais := 'GB';
        if Pais = 'DN' THEN Pais := 'DK';
        if CountryCode = 'DN' THEN CountryCode := 'DK';
        if CountryCode = 'D' THEN CountryCode := 'DE';
        if CountryCode = 'UK' THEN CountryCode := 'GB';

        // if (Customer."Cliente Directo") AND (Cif <> '') THEN BEGIN
        //     if Pais = 'ES' THEN Pais := 'DE';
        //     if Pais = '' THEN Pais := 'DE';
        //     if Pais = 'SW' THEN Pais := 'SE';
        //     Customer."Country/Region Code" := Pais;

        // END;

        CustCountryType := GetCountryType(Customer."Country/Region Code");
        if rPais.GET(Customer."Country/Region Code") THEN
            Customer."Country/Region Code" := rPais."EU Country/Region Code";
        if rPais.GET(Pais) THEN
            Pais := rPais."EU Country/Region Code";
        CASE CustCountryType OF
            CountryType::National:
                BEGIN
                    CLEAR(TipoIDreceptor);
                    CLEAR(IDreceptor);
                    CLEAR(CountryCode);
                    NifReceptor := Customer."VAT Registration No.";
                END;
            CountryType::CEE,
            CountryType::"3Country":
                BEGIN
                    TipoIDreceptor := Customer."Tipo ID receptor";
                    if Customer."ID receptor" <> '' THEN
                        IDreceptor := Customer."ID receptor"
                    ELSE
                        IDreceptor := Customer."VAT Registration No.";
                    CountryCode := Customer."Country/Region Code";
                    CLEAR(NifReceptor);
                END;
        END;
        // +SII1
        Name := Customer.Name;
        // if (Customer."Cliente Directo") AND (Cif <> '') THEN
        //     NifReceptor := '';
        // if (Customer."Cliente Directo") AND (Cif <> '') THEN
        //     IDreceptor := '';
        if (NifReceptor = '') AND (IDreceptor = '') THEN BEGIN
            if Cif <> '' THEN IDreceptor := Cif;
            if Cif = '' THEN
                TipoIDreceptor := '07' ELSE
                TipoIDreceptor := '03';
            //if Cif<> '' THEN IDreceptor :=Cif;
        END;
        // if (Customer."Cliente Directo") AND (Nom <> '') THEN BEGIN
        //     Name := Nom;
        //     if Pais <> '' THEN CountryCode := COPYSTR(Pais, 1, 2);
        //     if Pais = 'ES' THEN Pais := 'DE';
        //     if Pais = 'UK' THEN Pais := 'GB';
        //     if Pais = 'SW' THEN Pais := 'SE';
        //     if Pais = 'DN' THEN Pais := 'DK';
        // END;
        if TipoIDreceptor = '07' THEN BEGIN
            IDreceptor := '';//Customer."ID receptor";
            NifReceptor := '';
            // if IDreceptor ='' THEN IDreceptor := Customer."VAT Registration No.";
            CountryCode := '';
        END;
        if TipoIDreceptor = '03' THEN
            if CountryCode = 'ES' THEN CountryCode := 'DE';
        // if Customer."Cliente Contado" THEN BEGIN
        //     Cif := '';
        //     TipoIDreceptor := '07';
        //     Pais := '';
        //     CountryCode := '';
        //     NifReceptor := '';
        //     IDreceptor := '';
        // END;
    end;

    local procedure SetTipoIDEMIDEmPaisEMNIFEm(BillTo: Code[20]; var TipoIDreceptor: Code[3]; var IDreceptor: Code[20]; var CountryCode: Code[10]; var NifReceptor: Code[20]; var Name: Text[100])
    var
        Vendor: Record Vendor;
        CompanyInformation: Record 79;
        VendCountryType: Integer;
        Country: Record 9;
    begin
        Vendor.GET(BillTo);
        // -SII1
        //if Vendor."VAT Registration No." = '' THEN BEGIN
        //  TipoIDreceptor := Vendor."Tipo ID emisor";
        //  IDreceptor := Vendor."ID emisor";
        //  CountryCode := Vendor."Country/Region Code";
        //  NifReceptor := Vendor."VAT Registration No.";
        //END;
        VendCountryType := GetCountryType(Vendor."Country/Region Code");
        if Vendor."Tipo ID emisor" = '03' THEN VendCountryType := 2;
        CASE VendCountryType OF
            CountryType::National:
                BEGIN
                    CLEAR(TipoIDreceptor);
                    CLEAR(IDreceptor);
                    CLEAR(CountryCode);
                    NifReceptor := Vendor."VAT Registration No.";
                END;
            CountryType::CEE,
            CountryType::"3Country":
                BEGIN
                    TipoIDreceptor := Vendor."Tipo ID emisor";
                    if Vendor."ID emisor" <> '' THEN
                        IDreceptor := Vendor."ID emisor"
                    ELSE
                        IDreceptor := Vendor."VAT Registration No.";
                    if Country.GET(Vendor."Country/Region Code") THEN
                        CountryCode := Country."EU Country/Region Code"
                    ELSE
                        CountryCode := Vendor."Country/Region Code";
                    CLEAR(NifReceptor);
                END;
        END;
        // +SII1
        if Vendor."Tipo ID emisor" = '03' THEN BEGIN
            TipoIDreceptor := Vendor."Tipo ID emisor";
            if Vendor."ID emisor" <> '' THEN
                IDreceptor := Vendor."ID emisor"
            ELSE
                IDreceptor := Vendor."VAT Registration No.";
            if Country.GET(Vendor."Country/Region Code") THEN
                CountryCode := Country."EU Country/Region Code"
            ELSE
                CountryCode := Vendor."Country/Region Code";
            CLEAR(NifReceptor);
        END;
        Name := Vendor.Name;
        Name := Vendor.Name;
    end;

    local procedure WritePCSDOC(var Fichero: OutStream; PayMethodCode: Code[10]; BalAccNo: Code[20]; Fecha: Text; ImporteTotal: Text)
    var
        PaymentMethod: Record 289;
        Medio: Code[3];
        CuentaMedio: Code[34];
        CustLedgEntry: Record 21;
        VendorLedgerEntry: Record 25;
    begin
        SetMedioCuentaMedio(BalAccNo, PayMethodCode, Medio, CuentaMedio);
        Fichero.WriteText();
        Lenght := 1;
        Fichero.WriteText('PCSDOC|' + Fecha + '|' + ImporteTotal + '|' + Medio + '|' + CuentaMedio)
    end;

    local procedure FormatTime(var Hour: Text; var "Min": Text; var sec: Text; var Mili: Text)
    var
        Hours: Integer;
        Minutes: Integer;
        Seconds: Integer;
        Milliseconds: Integer;
    begin
        Milliseconds := TIME - 000000T;

        Hours := Milliseconds DIV 1000 DIV 60 DIV 60;
        Milliseconds -= Hours * 1000 * 60 * 60;

        Minutes := Milliseconds DIV 1000 DIV 60;
        Milliseconds -= Minutes * 1000 * 60;

        Seconds := Milliseconds DIV 1000;
        Milliseconds -= Seconds * 1000;

        Hour := FORMAT(Hours);
        Min := FORMAT(Minutes);
        sec := FORMAT(Seconds);
        Mili := FORMAT(Milliseconds);
    end;

    local procedure DevolverFechaImp(VATBusCode: Code[10]; FechaRegistro: Date; FechaVencimiento: Date; FechaEmision: Date; DocType: Option "Factura venta","Abono venta","Factura compra","Abono compra"; DocNo: Code[20]) Fecha: Date
    var
        VATBusinessPostingGroup: Record 323;
        SalesInvoiceLine: Record 113;
        ShptCode: Code[20];
        Skip: Boolean;
        SalesShipmentHeader: Record 110;
        ReturnShipmentHeader: Record 6650;
        ReturnReceiptHeader: Record 6660;
        SalesCrMemoLine: Record 115;
        SalesInvoiceHeader: Record 112;
        PurchInvHeader: Record "Purch. Inv. Header";
        PurchCrMemoHdr: Record "Purch. Cr. Memo Hdr.";
        SalesCrMemoHeader: Record 114;
    begin
        if VATBusCode = '' THEN
            EXIT;

        CASE DocType OF
            DocType::"Factura compra":
                BEGIN
                    if FechaVencimiento = 0D THEN BEGIN
                        if PurchInvHeader.GET(DocNo) THEN
                            FechaVencimiento := PurchInvHeader."Due Date";
                    END;
                    /*PurchInvLine.SETRANGE("Document No.",DocNo);
                    PurchInvLine.SETFILTER("Receipt No.",'<> %1','');
                    if PurchInvLine.FINDSET THEN BEGIN
                      REPEAT
                        if ShptCode = '' THEN
                          ShptCode := PurchInvLine."Receipt No.";
                        if (ShptCode <> PurchInvLine."Receipt No.") AND (ShptCode <> '') THEN
                          Skip := TRUE;
                      UNTIL PurchInvLine.NEXT = 0;
                      if NOT Skip THEN BEGIN
                        PurchRcptHeader.GET(PurchInvLine."Receipt No.");
                        Fecha := PurchRcptHeader."Posting Date";
                        EXIT(Fecha);
                      END;
                    END;*/
                END;
            DocType::"Factura venta":
                BEGIN
                    if FechaVencimiento = 0D THEN BEGIN
                        if SalesInvoiceHeader.GET(DocNo) THEN
                            FechaVencimiento := SalesInvoiceHeader."Due Date";
                    END;
                    //-002 Revisar Estas lÝneas no estaban comentadas
                    //SalesInvoiceLine.SETRANGE("Document No.",DocNo);
                    //SalesInvoiceLine.SETFILTER("Shipment No.",'<> %1','');
                    //if SalesInvoiceLine.FINDSET THEN BEGIN
                    //  REPEAT
                    //    if ShptCode = '' THEN
                    //      ShptCode := SalesInvoiceLine."Shipment No.";
                    //    if (ShptCode <> SalesInvoiceLine."Shipment No.") AND (ShptCode <> '') THEN
                    //      Skip := TRUE;
                    //  UNTIL SalesInvoiceLine.NEXT = 0;
                    //  if NOT Skip THEN BEGIN
                    //    SalesShipmentHeader.GET(SalesInvoiceLine."Shipment No.");
                    //    Fecha := SalesShipmentHeader."Posting Date";
                    //    EXIT(Fecha);
                    //  END;
                    //END;
                    //+002
                END;
            DocType::"Abono compra":
                BEGIN
                    if FechaVencimiento = 0D THEN BEGIN
                        if PurchCrMemoHdr.GET(DocNo) THEN
                            FechaVencimiento := PurchCrMemoHdr."Due Date";
                    END;
                    /*PurchCrMemoLine.SETRANGE("Document No.",DocNo);
                    PurchCrMemoLine.SETFILTER("Return Shipment No.",'<> %1','');
                    if PurchCrMemoLine.FINDSET THEN BEGIN
                      REPEAT
                        if ShptCode = '' THEN
                          ShptCode := PurchCrMemoLine."Return Shipment No.";
                        if (ShptCode <> PurchCrMemoLine."Return Shipment No.") AND (ShptCode <> '') THEN
                          Skip := TRUE;
                      UNTIL PurchCrMemoLine.NEXT = 0;
                      if NOT Skip THEN BEGIN
                        ReturnShipmentHeader.GET(PurchCrMemoLine."Return Shipment No.");
                        Fecha := ReturnShipmentHeader."Posting Date";
                        EXIT(Fecha);
                      END;
                    END;*/
                END;
            DocType::"Abono venta":
                BEGIN
                    if FechaVencimiento = 0D THEN BEGIN
                        if SalesCrMemoHeader.GET(DocNo) THEN
                            FechaVencimiento := SalesCrMemoHeader."Due Date";
                    END;
                    //-002 Revisar Estas lÝneas no estaban comentadas
                    //SalesCrMemoLine.SETRANGE("Document No.",DocNo);
                    //SalesCrMemoLine.SETFILTER("Return Receipt No.",'<> %1','');
                    //if SalesCrMemoLine.FINDSET THEN BEGIN
                    //  REPEAT
                    //    if ShptCode = '' THEN
                    //      ShptCode := SalesCrMemoLine."Return Receipt No.";
                    //    if (ShptCode <> SalesCrMemoLine."Return Receipt No.") AND (ShptCode <> '') THEN
                    //      Skip := TRUE;
                    //  UNTIL SalesCrMemoLine.NEXT = 0;
                    //  if NOT Skip THEN BEGIN
                    //    ReturnReceiptHeader.GET(SalesCrMemoLine."Return Receipt No.");
                    //    Fecha := ReturnReceiptHeader."Posting Date";
                    //    EXIT(Fecha);
                    //  END;
                    //END;
                    //+002
                END;
        END;
        VATBusinessPostingGroup.GET(VATBusCode);
        CASE VATBusinessPostingGroup."Devengo SII" OF
            VATBusinessPostingGroup."Devengo SII"::"Fecha registro":
                Fecha := FechaRegistro;
            VATBusinessPostingGroup."Devengo SII"::"Fecha emisión":
                Fecha := FechaEmision;
            VATBusinessPostingGroup."Devengo SII"::"Fecha vencimiento":
                Fecha := FechaVencimiento;
        END;
        if Fecha = 0D THEN
            Fecha := FechaRegistro;

    end;


    /// <summary>
    /// RegenerarFichero.
    /// </summary>
    /// <param name="TipoAccion">Option "Modificación",Baja,Alta.</param>
    /// <param name="DocNo">Code[20].</param>
    /// <param name="DocType">enum "Document Type Kuara".</param>
    /// <param name="FechaRegistro">Date.</param>
    /// <param name="CurrCode">Text.</param>
    procedure RegenerarFichero(TipoAccion: Option "Modificación",Baja,Alta; DocNo: Code[20]; DocType: enum "Document Type Kuara"; FechaRegistro: Date; CurrCode: Text)
    var
        VATEntry: Record 254;
        TipoEmision: Text;
        "Año": Text;
        Mes: Text;
        Dia: Text;
        TipoIDreceptor: Code[3];
        IDreceptor: Code[20];
        Paisreceptor: Code[10];
        NifReceptor: Code[20];
        custName: Text[100];
        FechaImputacion: Date;
        "AñoImputacion": Text;
        MesImputacion: Text;
        DiaImputacion: Text;
        CompanyInformation: Record 79;
        Fichero: OutStream;
        RutaFichero: Text[250];
        TipoFactura: Text;
        TipoIDEmisor: Code[20];
        IDEmisor: Code[20];
        PaisEmisor: Code[10];
        VendName: Text[100];
        VATBusPostGrp: Record 323;
        AmountInclVat: Decimal;
        Amount: Decimal;
#pragma warning disable AL0432
        TempVATAmountLines: Record "VAT Amount Line" Temporary;
#pragma warning restore AL0432
        TempVatPostStp: Record 325 temporary;
        WriteHeader: Boolean;
        Negativo: Boolean;
        Sale: Boolean;
        CuotaDeducible: Decimal;
        TextCuotaDeducible: Text;
        FactSII: Code[3];
        DocNoAux: Code[20];
        Service: Boolean;
        ClaveRegExpedidas: Code[3];
        ClaveRegRecibidas: Code[3];
        TipoDesglExpedidas: Code[3];
        TipoDesglRecibidas: Code[3];
        TipoOperacion: Code[3];
        DescOperacion: Text[250];
        "AñoOperacion": Text;
        MesOperacion: Text;
        DiaOperacion: Text;
        "-SII10": Integer;
        recPUrchaseheader: Record "Purch. Inv. Header";
        recPUrchaseheaderAbo: Record "Purch. Cr. Memo Hdr.";
        recCabFactVenta: Record 112;
        recCabAboVenta: Record 114;
        recCabFactCompra: Record "Purch. Inv. Header";
        recCabAboCompra: Record "Purch. Cr. Memo Hdr.";
        "+SII10": Integer;
        "//-EXP01": Integer;
        ServiceInvoiceHeader: Record 5992;
        ServiceCrMemoHeader: Record 5994;
        "//+EXP01": Integer;
        SalesInvoiceHeader: Record 112;
        SalesCrMemoHeader: Record 114;
        PurchInvoiceHeader: Record "Purch. Inv. Header";
        PurchCrMemoHeader: Record "Purch. Cr. Memo Hdr.";
        PurchInvoiceHeader1: Record "Purch. Inv. Header";
        PurchCrMemoHeader1: Record "Purch. Cr. Memo Hdr.";
        Customer: Record Customer;
        Vendor: Record Vendor;
        DK: Enum "Document Type Kuara";
    begin
        Customer.Init();
        Vendor.Init();
        //-SII1
        if Salir THEN
            EXIT;
        //+SII1
        //-SII10
        if TipoAccion = TipoAccion::Modificación THEN
            g_codeTipoFichero := 'A1'
        ELSE
            if TipoAccion = TipoAccion::Baja THEN
                g_codeTipoFichero := 'B1'
            ELSE
                g_codeTipoFichero := 'A0';

        if recCabFactVenta.GET(DocNo) OR recCabAboVenta.GET(DocNo) THEN BEGIN
            CreateOrUpdateFileSales(recCabFactVenta, recCabAboVenta,
              (recCabAboVenta."Corrected Invoice No." <> ''));
        END ELSE BEGIN
            //-EXP01
            if ServiceInvoiceHeader.GET(DocNo) OR ServiceCrMemoHeader.GET(DocNo) THEN BEGIN
                CreateOrUpdateFileService(ServiceInvoiceHeader."No.", ServiceCrMemoHeader."No.", (ServiceCrMemoHeader."Corrected Invoice No." <> ''));
            END ELSE
                //+EXP01

                if recCabFactCompra.GET(DocNo) OR recCabAboCompra.GET(DocNo) THEN BEGIN
                    //-SII11
                    //CreateOrUpdateFilePurch(recCabFactCompra,recCabAboCompra,(recCabAboVenta."Corrected Invoice No."<>''));
                    PurchInvoiceHeader1.INIT;
                    PurchCrMemoHeader1.INIT;
                    if (DocType = DocType::Invoice) THEN
                        PurchInvoiceHeader1.GET(DocNo);
                    if (DocType = DocType::"Credit Memo") THEN
                        PurchCrMemoHeader1.GET(DocNo);


                    CreateOrUpdateFilePurch(PurchInvoiceHeader1, PurchCrMemoHeader1, (PurchCrMemoHeader1."Corrected Invoice No." <> ''));
                    //+SII11
                END ELSE BEGIN
                    //+SII10
                    GLSetup.GET;
                    if GLSetup."Activar SII" THEN BEGIN
                        if TipoAccion = TipoAccion::Modificación THEN
                            TipoEmision := 'A1'
                        ELSE
                            if TipoAccion = TipoAccion::Baja THEN
                                TipoEmision := 'B1'
                            ELSE
                                TipoEmision := 'A0';
                        //-EXP01
                        if NOT Export THEN
                            //+EXP01
                            if NOT (DocType IN [DocType::Invoice, DocType::"Credit Memo", DocType::Payment, DocType::Refund]) THEN
                                EXIT;
                        VATEntry.SETRANGE("Document No.", DocNo);
                        VATEntry.SETRANGE("Posting Date", FechaRegistro);
                        //-EXP01
                        if NOT Export THEN
                            //+EXP01
                            VATEntry.SETRANGE("Document Type", DocType);
                        //-SII1
                        if VATEntry.COUNT > 1 THEN
                            FromVATPostStp := TRUE;
                        //+SII1
                        CompanyInformation.GET;
                        GetGLSetup;
                        if VATEntry.FINDFIRST THEN BEGIN
                            //-c1
                            //DevolverAnoMesDia(VATEntry."Document Date",Año,Mes,Dia);
                            //+c1
                            //-EXP01
                            if Export THEN
                                if NOT (VATEntry."Document Type" IN [VATEntry."Document Type"::Invoice, VATEntry."Document Type"::"Credit Memo"]) THEN
                                    EXIT;
                            //+EXP01
                            if VATEntry.Type = VATEntry.Type::Sale THEN BEGIN
                                Sale := TRUE;
                                Customer.Get(VATEntry."Bill-to/Pay-to No.");
                                if SalesInvoiceHeader.GET(VATEntry."Document No.") THEN
                                    SetTipoIDRecIDRecPaisRecNIFRec(SalesInvoiceHeader."Bill-to Customer No.", TipoIDreceptor, IDreceptor, Paisreceptor,
                                                         NifReceptor, custName,
                                                         SalesInvoiceHeader."VAT Registration No.", SalesInvoiceHeader."Bill-to Name",
                                                         SalesInvoiceHeader."Bill-to Country/Region Code")

                                ELSE
                                    if SalesCrMemoHeader.GET(VATEntry."Document No.") THEN
                                        SetTipoIDRecIDRecPaisRecNIFRec(SalesCrMemoHeader."Bill-to Customer No.", TipoIDreceptor, IDreceptor, Paisreceptor,
                                                               NifReceptor, custName,
                                                               SalesCrMemoHeader."VAT Registration No.", SalesCrMemoHeader."Bill-to Name",
                                                               SalesCrMemoHeader."Bill-to Country/Region Code")

                                    ELSE
                                        SetTipoIDRecIDRecPaisRecNIFRec(VATEntry."Bill-to/Pay-to No.", TipoIDreceptor, IDreceptor,
                                                                        Paisreceptor, NifReceptor, custName, '', '', '');
                                TipoFactura := 'FE';
                                if VATEntry."Document Type" = VATEntry."Document Type"::Invoice THEN BEGIN
                                    FechaImputacion := DevolverFechaImp(VATEntry."VAT Bus. Posting Group", VATEntry."Posting Date", 0D,
                                                        VATEntry."Document Date", 0, VATEntry."Document No.");
                                    WriteHeader := TRUE;
                                END ELSE
                                    if VATEntry."Document Type" = VATEntry."Document Type"::"Credit Memo" THEN BEGIN
                                        FechaImputacion := DevolverFechaImp(VATEntry."VAT Bus. Posting Group", VATEntry."Posting Date", 0D,
                                                                            VATEntry."Document Date", 1, VATEntry."Document No.");
                                        WriteHeader := TRUE;
                                    END ELSE
                                        if ((VATEntry."Document Type" IN [VATEntry."Document Type"::Payment, VATEntry."Document Type"::Refund])
                                                                      AND (VATEntry."VAT Cash Regime")) THEN BEGIN
                                            FechaImputacion := VATEntry."Posting Date";
                                            TipoFactura := 'CE';
                                            WriteHeader := TRUE;
                                        END;
                            END ELSE
                                if VATEntry.Type = VATEntry.Type::Purchase THEN BEGIN
                                    Vendor.Get(VATEntry."Bill-to/Pay-to No.");
                                    SetTipoIDEMIDEmPaisEMNIFEm(VATEntry."Bill-to/Pay-to No.", TipoIDEmisor, IDEmisor, PaisEmisor, NifReceptor, VendName);
                                    TipoFactura := 'FR';
                                    if VATEntry."Document Type" = VATEntry."Document Type"::Invoice THEN BEGIN
                                        FechaImputacion := DevolverFechaImp(VATEntry."VAT Bus. Posting Group", VATEntry."Posting Date", 0D,
                                                                            VATEntry."Document Date", 2, VATEntry."Document No.");
                                        WriteHeader := TRUE;
                                    END ELSE
                                        if VATEntry."Document Type" = VATEntry."Document Type"::"Credit Memo" THEN BEGIN
                                            FechaImputacion := DevolverFechaImp(VATEntry."VAT Bus. Posting Group", VATEntry."Posting Date", 0D,
                                                                                VATEntry."Document Date", 3, VATEntry."Document No.");
                                            WriteHeader := TRUE;
                                        END ELSE
                                            if ((VATEntry."Document Type" IN [VATEntry."Document Type"::Payment, VATEntry."Document Type"::Refund])
                                                                          AND (VATEntry."VAT Cash Regime")) THEN BEGIN
                                                FechaImputacion := VATEntry."Posting Date";
                                                TipoFactura := 'PR';
                                                WriteHeader := TRUE;
                                            END;
                                END;
                            if WriteHeader THEN BEGIN
                                OpenFile(OpenOrCreateFile(TipoFactura, FALSE), Fichero, VATEntry."Document No.", true);
                                if Lenght = 0 THEN
                                    WriteNewFile(Fichero, GLSetup, TipoFactura, TipoEmision);
                                DevolverAnoMesDia(FechaImputacion, AñoImputacion, MesImputacion, DiaImputacion);
                                VATBusPostGrp.GET(VATEntry."VAT Bus. Posting Group");
                                //-SII1
                                if FromVATPostStp THEN BEGIN
                                    ClaveRegExpedidas := VATBusPostGrp."Clave registro SII expedidas";
                                    ClaveRegRecibidas := VATBusPostGrp."Clave registro SII recibidas";
                                    DescOperacion := VATEntry."Descripción operación";
                                END ELSE BEGIN
                                    ClaveRegExpedidas := ClaveRegExp;
                                    ClaveRegRecibidas := ClaveRegRec;
                                    DescOperacion := DescOper;
                                END;
                                if DescOperacion = '' THEN
                                    DescOperacion := VATEntry."Descripción operación";
                                if ClaveRegExpedidas = '' THEN
                                    ClaveRegExpedidas := VATBusPostGrp."Clave registro SII expedidas";
                                if ClaveRegRecibidas = '' THEN
                                    ClaveRegRecibidas := VATBusPostGrp."Clave registro SII recibidas";
                                if Sale THEN BEGIN
                                    if SalesInvoiceHeader.GET(VATEntry."Document No.") THEN
                                        DescOperacion := SalesInvoiceHeader."Posting Description"
                                    ELSE
                                        if SalesCrMemoHeader.GET(VATEntry."Document No.") THEN
                                            DescOperacion := SalesCrMemoHeader."Posting Description";
                                END ELSE BEGIN
                                    if PurchInvoiceHeader.GET(VATEntry."Document No.") THEN
                                        DescOperacion := PurchInvoiceHeader."Posting Description"
                                    ELSE
                                        if PurchCrMemoHeader.GET(VATEntry."Document No.") THEN
                                            DescOperacion := PurchCrMemoHeader."Posting Description";

                                END;
                                Case VATEntry."Document Type" Of

                                    VATEntry."Document Type"::" ", VATEntry."Document Type"::Advance:
                                        Dk := Dk::" ";
                                    VATEntry."Document Type"::Bill:
                                        Dk := Dk::Bill;
                                    VATEntry."Document Type"::"Credit Memo":
                                        Dk := Dk::"Credit Memo";
                                    VATEntry."Document Type"::"Finance Charge Memo":
                                        Dk := Dk::"Finance Charge Memo";
                                    VATEntry."Document Type"::Invoice:
                                        Dk := Dk::Invoice;
                                    VATEntry."Document Type"::Payment:
                                        Dk := Dk::Payment;
                                    VATEntry."Document Type"::Receipt:
                                        Dk := Dk::Albaran;
                                    VATEntry."Document Type"::Refund:
                                        Dk := Dk::Refund;
                                    VATEntry."Document Type"::Reminder:
                                        Dk := Dk::Reminder;

                                End;
                                //+SII1
                                CalcVatLinesGenJnlLine(VATEntry."Document No.", VATEntry."Posting Date", DK,
                                                      TempVATAmountLines, TempVatPostStp);
                                //-EXP01
                                //OpenFile(OpenOrCreateFile(TipoFactura, FALSE), Fichero, VATEntry."Document No.",true);
                                if Lenght = 0 THEN
                                    WriteNewFile(Fichero, GLSetup, TipoFactura, TipoEmision);
                                //+EXP01
                                CalcAmts(TempVATAmountLines, AmountInclVat, Amount);
                                //-c1
                                DevolverAnoMesDia(VATEntry."Document Date", Año, Mes, Dia);
                                //-SII1
                                //if (TipoFactura = 'FR') OR (TipoFactura = 'PR') THEN
                                if (TipoFactura = 'FR') OR (TipoFactura = 'PR') THEN BEGIN
                                    //DevolverAnoMesDia(TODAY,Año,Mes,Dia);
                                    DevolverAnoMesDia(VATEntry."Document Date", Año, Mes, Dia);
                                    if TipoAccion = TipoAccion::Alta THEN
                                        DevolverAnoMesDia(GetDateFromPurchInv(VATEntry."Document No."), AñoOperacion, MesOperacion, DiaOperacion)
                                    ELSE
                                        DevolverAnoMesDia(TODAY, AñoOperacion, MesOperacion, DiaOperacion);
                                END;
                                //+SII1
                                //+c1
                                if (VATEntry."Document Type" = VATEntry."Document Type"::"Credit Memo") OR (VATEntry."Document Type" =
                                                                                          VATEntry."Document Type"::Refund) THEN
                                    AmountInclVat := -ABS(AmountInclVat);
                                //-SII1
                                if (TipoFactura = 'CE') OR (TipoFactura = 'PR') THEN
                                    DocNoAux := FindDocNoToPay(DocNo, DocType, FechaRegistro, Sale)
                                ELSE
                                    if TipoFactura = 'FR' THEN
                                        DocNoAux := FindDocNoToPay(DocNo, DocType, FechaRegistro, FALSE)
                                    ELSE
                                        DocNoAux := VATEntry."Document No.";
                                //+SII1
                                if NOT Sale THEN BEGIN
                                    CuotaDeducible := CalcCuotaDeducible(TempVATAmountLines);
                                    //if CuotaDeducible <> 0 THEN
                                    TextCuotaDeducible := ChangeCommaForDot(FORMAT(CuotaDeducible, 0, DevolverFormato(CurrCode)));
                                    WriteNewDoc(Fichero, AñoImputacion, MesImputacion, VATEntry."Tipo factura SII",
                                                //-SII1
                                                //FindDocNoToPay(DocNo,DocType,FechaRegistro,FALSE)
                                                DocNoAux
                                                //+SII1
                                                , Año + Mes + Dia, VATEntry."VAT Registration No.", VendName,
                                              //-SII1
                                              //TipoIDEmisor,IDEmisor,PaisEmisor,VATEntry."VAT Registration No.", VendName, TipoIDEmisor,IDEmisor,PaisEmisor);
                                              TipoIDEmisor, IDEmisor, PaisEmisor, VATEntry."VAT Registration No.", VendName, '', ''/*CompanyInformation."VAT Registration No."*/, PaisEmisor, Vendor, Customer);
                                    //+SII1
                                END ELSE BEGIN
                                    if TipoIDreceptor = '07' THEN VATEntry."Tipo factura SII" := 'F2';

                                    WriteNewDoc(Fichero, AñoImputacion, MesImputacion, VATEntry."Tipo factura SII",
                                                //-SII1
                                                //FindDocNoToPay(DocNo,DocType,FechaRegistro,TRUE),
                                                DocNoAux,
                                                //+SII1
                                                Año + Mes + Dia, CompanyInformation."VAT Registration No.", CompanyInformation.Name,
                                                    TipoIDEmisor, IDEmisor, PaisEmisor, NifReceptor, custName, TipoIDreceptor, IDreceptor, Paisreceptor, Vendor, Customer);
                                END;
                                //if NOT VATEntry."VAT Cash Regime" AND (NOT PaidNow(VATEntry."Document No.",VATEntry."Posting Date",FactSII))THEN BEGIN
                                if AmountInclVat = 0 THEN AmountInclVat := 0.1;
                                if Amount = 0 THEN Amount := 0.1;
                                if (TipoFactura = 'FE') OR (TipoFactura = 'FR') THEN BEGIN
                                    if Sale THEN BEGIN
                                        //-SII1
                                        //WriteNewINVDOC(Fichero,VATBusPostGrp."Clave registro SII expedidas",VATEntry."Descripción operación",
                                        WriteNewINVDOC(Fichero, ClaveRegExpedidas, DescOperacion,
                                                        //+SII1
                                                        AñoImputacion + MesImputacion + DiaImputacion, TextCuotaDeducible,
                                                        ChangeCommaForDot(FORMAT(AmountInclVat, 0, DevolverFormato(CurrCode))),
                                                        ChangeCommaForDot(FORMAT(Amount, 0, DevolverFormato(CurrCode))));
                                    END ELSE BEGIN
                                        //-SII1
                                        //WriteNewINVDOC(Fichero,VATBusPostGrp."Clave registro SII recibidas",VATEntry."Descripción operación",
                                        WriteNewINVDOC(Fichero, ClaveRegRecibidas, DescOperacion,
                                                        //AñoImputacion+MesImputacion+DiaImputacion,TextCuotaDeducible,
                                                        AñoOperacion + MesOperacion + DiaOperacion, TextCuotaDeducible,
                                                        //+SII1
                                                        ChangeCommaForDot(FORMAT(AmountInclVat, 0, DevolverFormato(CurrCode))),
                                                        ChangeCommaForDot(FORMAT(Amount, 0, DevolverFormato(CurrCode))));
                                    END;
                                    WriteNewIMPDOC(Fichero, TempVATAmountLines, VATEntry."Document Type" IN [VATEntry."Document Type"::Refund,
                                                  VATEntry."Document Type"::"Credit Memo"],
                                                TempVatPostStp, (Sale), TipoFactura, CurrCode);
                                    //-SII
                                    //if FacturaCorrectiva(VATEntry."Document No.",Sale,DocNoAux,Service) THEN
                                    if (VATEntry."Document Type" IN [VATEntry."Document Type"::"Credit Memo"]) OR (VATEntry."Tipo factura SII"[1] = 'R') THEN
                                        WriteNewRECDOC(Fichero, TempVATAmountLines, VATEntry."Tipo factura rectificativa", CurrCode);
                                END ELSE BEGIN
                                    //-SII1
                                    //if (Sale AND CriterioCaja(VATEntry."Document No.",VATEntry."Posting Date")) THEN BEGIN
                                    if TipoFactura = 'CE' THEN BEGIN
                                        //+SII1
                                        WriteCE(Fichero, NOT (VATEntry."Document Type" IN [VATEntry."Document Type"::"Credit Memo",
                                                VATEntry."Document Type"::Refund]),
                                                //FindDocNoToPay(DocNo,DocType,FechaRegistro,TRUE),DocType,FechaRegistro,CurrCode,Año+Mes+Dia);
                                                DocNo, DocType, FechaRegistro, CurrCode);
                                        //-SII1
                                        //END ELSE if (NOT Sale AND CriterioCaja(VATEntry."Document No.",VATEntry."Posting Date")) THEN BEGIN
                                    END ELSE
                                        if TipoFactura = 'PR' THEN BEGIN
                                            //+SII1
                                            WritePR(Fichero, NOT (VATEntry."Document Type" IN [VATEntry."Document Type"::"Credit Memo",
                                                    VATEntry."Document Type"::Refund]),
                                                    //FindDocNoToPay(DocNo,DocType,FechaRegistro,FALSE),DocType,FechaRegistro,CurrCode,Año+Mes+Dia);
                                                    DocNo, DocType, FechaRegistro, CurrCode);
                                        END;
                                END;
                                //-EXP01
                                if NOT Export THEN BEGIN
                                    //+EXP01
                                    if TipoAccion <> TipoAccion::Baja THEN
                                        ModifyVATEntry(DocNo, DocType, FechaRegistro);
                                    if TipoAccion = TipoAccion::Modificación THEN
                                        MESSAGE(Text001)
                                    ELSE
                                        if TipoAccion = TipoAccion::Baja THEN
                                            MESSAGE(Text002)
                                        ELSE
                                            MESSAGE(Text010);
                                    //-EXP01
                                END;
                                //+EXP01
                            END;
                        END;
                    END;
                    //-SII10 Puede que no complile
                END;
        END;
        //+SII10

    end;

    local procedure FacturaCorrectiva(DocNo: Code[20]; Sale: Boolean; var DocNoAux: Code[20]; var Service: Boolean): Boolean
    var
        SalesCrMemoHeader: Record 114;
        PurchCrMemoHdr: Record "Purch. Cr. Memo Hdr.";
        ServiceCrMemoHeader: Record 5994;
    begin
        //-jb
        if DocNo <> '' THEN BEGIN
            if Sale THEN
                if SalesCrMemoHeader.GET(DocNo) THEN BEGIN
                    DocNoAux := SalesCrMemoHeader."Corrected Invoice No.";
                    EXIT(SalesCrMemoHeader."Corrected Invoice No." <> '');
                END ELSE BEGIN
                    if ServiceCrMemoHeader.GET(DocNo) THEN BEGIN
                        DocNoAux := ServiceCrMemoHeader."Corrected Invoice No.";
                        Service := TRUE;
                        EXIT(ServiceCrMemoHeader."Corrected Invoice No." <> '');
                    END;
                END;
            if PurchCrMemoHdr.GET(DocNo) THEN BEGIN
                DocNoAux := PurchCrMemoHdr."Corrected Invoice No.";
                EXIT(PurchCrMemoHdr."Corrected Invoice No." <> '');
            END;
        END;
    end;

    local procedure ModifyVATEntry(DocNo: Code[20]; DocType: Enum "Document Type Kuara"; FechaRegistro: Date)
    var
        VATEntry: Record 254;
        VATPostingSetup: Record 325;
        VATBusinessPostingGroup: Record 323;
        Modificar: Boolean;
    begin
        VATEntry.SETRANGE("Document No.", DocNo);
        VATEntry.SETRANGE("Posting Date", FechaRegistro);
        VATEntry.SETRANGE("Document Type", DocType);
        if VATEntry.FINDSET THEN
            REPEAT
                //-SII4.00
                //-SII1
                /*if NOT FromVATPostStp THEN BEGIN
                  if VATEntry.Type = VATEntry.Type::Sale THEN BEGIN
                    VATEntry."Tipo desglose emitidas" := TipoDesglExp;
                    VATEntry."Clave registro SII expedidas" := ClaveRegExp;
                  END ELSE BEGIN
                    VATEntry."Tipo desglose recibidas" := TipoDesglRec;
                    VATEntry."Clave registro SII recibidas" := ClaveRegRec;
                  END;
                  VATEntry."Sujeta exenta" := SujExenta;
                  VATEntry."Descripción operación" := DescOper;
                  VATEntry."Tipo de operación" := TipoOper;
                  Modificar := TRUE;
                END ELSE BEGIN*/
                //+SII4.00
                //+SII1
                if VATPostingSetup.GET(VATEntry."VAT Bus. Posting Group", VATEntry."VAT Prod. Posting Group") THEN BEGIN
                    //VATEntry."Tipo desglose emitidas" := VATPostingSetup."Tipo desglose emitidas";
                    VATEntry."Tipo de operación" := VATPostingSetup."Tipo de operación";
                    VATEntry."Sujeta exenta" := VATPostingSetup."Sujeta exenta";
                    //-SII1
                    VATEntry."Tipo de operación" := VATPostingSetup."Tipo de operación";
                    //+SII1
                    Modificar := TRUE;
                END;
                if VATBusinessPostingGroup.GET(VATEntry."VAT Bus. Posting Group") THEN BEGIN
                    //-SII1
                    //if VATEntry.Type = VATEntry.Type::Sale THEN
                    if VATEntry.Type = VATEntry.Type::Sale THEN BEGIN
                        VATEntry."Tipo desglose emitidas" := VATPostingSetup."Tipo desglose emitidas";
                        //+SII1
                        VATEntry."Clave registro SII expedidas" := VATBusinessPostingGroup."Clave registro SII expedidas";
                        //-SII1
                        //ELSE if VATEntry.Type = VATEntry.Type::Purchase THEN
                    END ELSE
                        if VATEntry.Type = VATEntry.Type::Purchase THEN BEGIN
                            VATEntry."Tipo desglose recibidas" := VATPostingSetup."Tipo desglose recibidas";
                            //+SII1
                            VATEntry."Clave registro SII recibidas" := VATBusinessPostingGroup."Clave registro SII recibidas";
                            //-SII1
                        END;
                    //+SII1
                    Modificar := TRUE;
                END;
                //-SII1
                //-SII4.00
                //END;
                //+SII4.00
                //+SII1
                if Modificar THEN
                    VATEntry.MODIFY;
            UNTIL VATEntry.NEXT = 0;

    end;

#pragma warning disable AL0432
    local procedure CalcAmts(var TempVatAmtLine: Record "VAT Amount Line" Temporary; var AmtInclVAT: Decimal; var Amt: Decimal)
#pragma warning restore AL0432
    begin
        TempVatAmtLine.RESET;
        if TempVatAmtLine.FINDSET THEN
            REPEAT
                AmtInclVAT += (TempVatAmtLine."VAT Base" + TempVatAmtLine."VAT Amount") + TempVatAmtLine."EC Amount";
                Amt += TempVatAmtLine."VAT Base";
            UNTIL TempVatAmtLine.NEXT = 0;
    end;

    local procedure AmtDecimalPlaces("Currency Code": Code[10]): Text
    var
        Currency: Record "Currency";
    begin
        if "Currency Code" = '' THEN BEGIN
            GetGLSetup;
            EXIT(GLSetup."Amount Decimal Places");
        END;
        Currency.GET("Currency Code");
        EXIT(Currency."Amount Decimal Places");
    end;

    local procedure DevolverFormato(CurrCode: Code[10]): Text[40]
    begin
        EXIT('<Precision,' + AmtDecimalPlaces(CurrCode) + '><Standard Format,2>');
    end;

    local procedure FindAppliedCustEntries(var Rec: Record 21)
    var
        CreateCustLedgEntry: Record 21;
    begin
        //WITH Rec DO BEGIN
        Rec.RESET;
        if Rec."Entry No." <> 0 THEN BEGIN
            CreateCustLedgEntry := Rec;
            FindCustApplnEntriesDtldtLedgEntry(Rec, CreateCustLedgEntry);
            Rec.SETCURRENTKEY("Entry No.");
            Rec.SETRANGE("Entry No.");

            if CreateCustLedgEntry."Closed by Entry No." <> 0 THEN BEGIN
                Rec."Entry No." := CreateCustLedgEntry."Closed by Entry No.";
                Rec.MARK(TRUE);
            END;

            Rec.SETCURRENTKEY("Closed by Entry No.");
            Rec.SETRANGE("Closed by Entry No.", CreateCustLedgEntry."Entry No.");
            if Rec.FIND('-') THEN
                REPEAT
                    Rec.MARK(TRUE);
                UNTIL Rec.NEXT = 0;

            Rec.SETCURRENTKEY("Entry No.");
            Rec.SETRANGE("Closed by Entry No.");
        END;

        Rec.MARKEDONLY(TRUE);
        //END;
    end;

    local procedure FindCustApplnEntriesDtldtLedgEntry(var Rec: Record 21; var CreateCustLedgEntry: Record 21)
    var
        DtldCustLedgEntry1: Record 379;
        DtldCustLedgEntry2: Record 379;
    begin
        CreateCustLedgEntry := Rec;
        DtldCustLedgEntry1.SETCURRENTKEY("Cust. Ledger Entry No.");
        DtldCustLedgEntry1.SETRANGE("Cust. Ledger Entry No.", CreateCustLedgEntry."Entry No.");
        DtldCustLedgEntry1.SETRANGE(Unapplied, FALSE);
        //WITH Rec DO BEGIN
        if DtldCustLedgEntry1.FIND('-') THEN
            REPEAT
                if DtldCustLedgEntry1."Cust. Ledger Entry No." =
                   DtldCustLedgEntry1."Applied Cust. Ledger Entry No."
                THEN BEGIN
                    DtldCustLedgEntry2.INIT;
                    DtldCustLedgEntry2.SETCURRENTKEY("Applied Cust. Ledger Entry No.", "Entry Type");
                    DtldCustLedgEntry2.SETRANGE(
                      "Applied Cust. Ledger Entry No.", DtldCustLedgEntry1."Applied Cust. Ledger Entry No.");
                    DtldCustLedgEntry2.SETRANGE("Entry Type", DtldCustLedgEntry2."Entry Type"::Application);
                    DtldCustLedgEntry2.SETRANGE(Unapplied, FALSE);
                    if DtldCustLedgEntry2.FIND('-') THEN
                        REPEAT
                            if DtldCustLedgEntry2."Cust. Ledger Entry No." <>
                               DtldCustLedgEntry2."Applied Cust. Ledger Entry No."
                            THEN BEGIN
                                Rec.SETCURRENTKEY("Entry No.");
                                Rec.SETRANGE("Entry No.", DtldCustLedgEntry2."Cust. Ledger Entry No.");
                                if Rec.FIND('-') THEN
                                    Rec.MARK(TRUE);
                            END;
                        UNTIL DtldCustLedgEntry2.NEXT = 0;
                END ELSE BEGIN
                    Rec.SETCURRENTKEY("Entry No.");
                    Rec.SETRANGE("Entry No.", DtldCustLedgEntry1."Applied Cust. Ledger Entry No.");
                    if Rec.FIND('-') THEN
                        Rec.MARK(TRUE);
                END;
            UNTIL DtldCustLedgEntry1.NEXT = 0;
        //END;
    end;

    local procedure FindVendApplnEntriesDtldtLedgEntry(var Rec: Record 25; var CreateVendLedgEntry: Record 25)
    var
        DtldVendLedgEntry1: Record 380;
        DtldVendLedgEntry2: Record 380;
    begin
        // WITH Rec DO BEGIN
        DtldVendLedgEntry1.SETCURRENTKEY("Vendor Ledger Entry No.");
        DtldVendLedgEntry1.SETRANGE("Vendor Ledger Entry No.", CreateVendLedgEntry."Entry No.");
        DtldVendLedgEntry1.SETRANGE(Unapplied, FALSE);
        if DtldVendLedgEntry1.FIND('-') THEN
            REPEAT
                if DtldVendLedgEntry1."Vendor Ledger Entry No." =
                   DtldVendLedgEntry1."Applied Vend. Ledger Entry No."
                THEN BEGIN
                    DtldVendLedgEntry2.INIT;
                    DtldVendLedgEntry2.SETCURRENTKEY("Applied Vend. Ledger Entry No.", "Entry Type");
                    DtldVendLedgEntry2.SETRANGE(
                      "Applied Vend. Ledger Entry No.", DtldVendLedgEntry1."Applied Vend. Ledger Entry No.");
                    DtldVendLedgEntry2.SETRANGE("Entry Type", DtldVendLedgEntry2."Entry Type"::Application);
                    DtldVendLedgEntry2.SETRANGE(Unapplied, FALSE);
                    if DtldVendLedgEntry2.FIND('-') THEN
                        REPEAT
                            if DtldVendLedgEntry2."Vendor Ledger Entry No." <>
                               DtldVendLedgEntry2."Applied Vend. Ledger Entry No."
                            THEN BEGIN
                                Rec.SETCURRENTKEY("Entry No.");
                                Rec.SETRANGE("Entry No.", DtldVendLedgEntry2."Vendor Ledger Entry No.");
                                if Rec.FIND('-') THEN
                                    Rec.MARK(TRUE);
                            END;
                        UNTIL DtldVendLedgEntry2.NEXT = 0;
                END ELSE BEGIN
                    Rec.SETCURRENTKEY("Entry No.");
                    Rec.SETRANGE("Entry No.", DtldVendLedgEntry1."Applied Vend. Ledger Entry No.");
                    if Rec.FIND('-') THEN
                        Rec.MARK(TRUE);
                END;
            UNTIL DtldVendLedgEntry1.NEXT = 0;
        // END;
    end;

    local procedure FindCustLedEntry(DocNo: Code[20]; DocType: Enum "Document Type Kuara"; FechaRegistro: Date; var CustLedgEntry: Record 21)
    begin
        CustLedgEntry.SETRANGE("Document No.", DocNo);
        CustLedgEntry.SETRANGE("Document Type", DocType);
        CustLedgEntry.SETRANGE("Posting Date", FechaRegistro);
    end;

    local procedure FindVendLedEntry(DocNo: Code[20]; DocType: Enum "Document Type Kuara"; FechaRegistro: Date; var VendorLedgerEntry: Record 25)
    begin
        VendorLedgerEntry.SETRANGE("Document No.", DocNo);
        VendorLedgerEntry.SETRANGE("Document Type", DocType);
        VendorLedgerEntry.SETRANGE("Posting Date", FechaRegistro);
    end;

    local procedure FindAppliedVendEntries(var Rec: Record 25)
    var
        CreateVendLedgEntry: Record 25;
    begin
        // WITH Rec DO BEGIN
        Rec.RESET;

        if Rec."Entry No." <> 0 THEN BEGIN
            CreateVendLedgEntry := Rec;

            FindVendApplnEntriesDtldtLedgEntry(Rec, CreateVendLedgEntry);
            Rec.SETCURRENTKEY("Entry No.");
            Rec.SETRANGE("Entry No.");

            if CreateVendLedgEntry."Closed by Entry No." <> 0 THEN BEGIN
                Rec."Entry No." := CreateVendLedgEntry."Closed by Entry No.";
                Rec.MARK(TRUE);
            END;

            Rec.SETCURRENTKEY("Closed by Entry No.");
            Rec.SETRANGE("Closed by Entry No.", CreateVendLedgEntry."Entry No.");
            if Rec.FIND('-') THEN
                REPEAT
                    Rec.MARK(TRUE);
                UNTIL Rec.NEXT = 0;

            Rec.SETCURRENTKEY("Entry No.");
            Rec.SETRANGE("Closed by Entry No.");
        END;

        Rec.MARKEDONLY(TRUE);
        // END;
    end;

    local procedure WritePR(var Fichero: OutStream; Positivo: Boolean; DocNo: Code[20]; DocType: Enum "Document Type Kuara"; FechaRegistro: Date; CurrCode: Code[10])
    var
        VendorLedgerEntry: Record 25;
        VendorLedgerEntryAUX: Record 25;
        "AñoOperacion": Text;
        MesOperacion: Text;
        DiaOperacion: Text;
    begin
        FindVendLedEntry(DocNo, DocType, FechaRegistro, VendorLedgerEntry);
        //-SII1
        DevolverAnoMesDia(FechaRegistro, AñoOperacion, MesOperacion, DiaOperacion);
        //+SII1
        if VendorLedgerEntry.FINDSET THEN
            REPEAT
                VendorLedgerEntryAUX := VendorLedgerEntry;
                FindAppliedVendEntries(VendorLedgerEntryAUX);
                if VendorLedgerEntryAUX.FINDSET THEN
                    REPEAT
                        //VendorLedgerEntryAUX.CALCFIELDS(Amount);
                        VendorLedgerEntry.CALCFIELDS(Amount);
                        if Positivo THEN BEGIN
                            //-SII1
                            //WriteNewINVDOC(Fichero,'','',Fecha,'',ChangeCommaForDot(FORMAT(ABS(VendorLedgerEntry.Amount),0,
                            WriteNewINVDOC(Fichero, '', '', AñoOperacion + MesOperacion + DiaOperacion, '', ChangeCommaForDot(FORMAT(ABS(VendorLedgerEntry.Amount), 0,
                                            //+SII1
                                            DevolverFormato(CurrCode))), '');
                            WritePCSDOC(Fichero, VendorLedgerEntryAUX."Payment Method Code", FindBankAcc(VendorLedgerEntry."Transaction No."),
                                        //-SII1
                                        //Fecha,ChangeCommaForDot(FORMAT(ABS(VendorLedgerEntry.Amount),0,
                                        AñoOperacion + MesOperacion + DiaOperacion, ChangeCommaForDot(FORMAT(ABS(VendorLedgerEntry.Amount), 0,
                                        //+SII1
                                        DevolverFormato(CurrCode))));
                        END ELSE BEGIN
                            //-SII1
                            //WriteNewINVDOC(Fichero,'','',Fecha,'',ChangeCommaForDot(FORMAT(-ABS(VendorLedgerEntry.Amount),
                            WriteNewINVDOC(Fichero, '', '', AñoOperacion + MesOperacion + DiaOperacion, '', ChangeCommaForDot(FORMAT(-ABS(VendorLedgerEntry.Amount),
                                          //+SII1
                                          0, DevolverFormato(CurrCode))), '');
                            WritePCSDOC(Fichero, VendorLedgerEntryAUX."Payment Method Code", FindBankAcc(VendorLedgerEntry."Transaction No."),
                                        //-SII1
                                        //Fecha,ChangeCommaForDot(FORMAT(-ABS(VendorLedgerEntry.Amount),0,
                                        AñoOperacion + MesOperacion + DiaOperacion, ChangeCommaForDot(FORMAT(-ABS(VendorLedgerEntry.Amount), 0,
                                        //+SII1
                                        DevolverFormato(CurrCode))));
                        END;
                    UNTIL VendorLedgerEntryAUX.NEXT = 0;
            UNTIL VendorLedgerEntry.NEXT = 0;
    end;

    local procedure WriteCE(var Fichero: OutStream; Positivo: Boolean; DocNo: Code[20]; DocType: Enum "Document Type Kuara"; FechaRegistro: Date; CurrCode: Code[10])
    var
        CustLedgEntry: Record 21;
        CustLedgEntryAUX: Record 21;
        "AñoOperacion": Text;
        MesOperacion: Text;
        DiaOperacion: Text;
    begin
        FindCustLedEntry(DocNo, DocType, FechaRegistro, CustLedgEntry);
        //-SII1
        DevolverAnoMesDia(FechaRegistro, AñoOperacion, MesOperacion, DiaOperacion);
        //+SII1
        if CustLedgEntry.FINDSET THEN
            REPEAT
                CustLedgEntryAUX := CustLedgEntry;
                FindAppliedCustEntries(CustLedgEntryAUX);
                if CustLedgEntryAUX.FINDSET THEN
                    REPEAT
                        //CustLedgEntryAUX.CALCFIELDS(Amount);
                        CustLedgEntry.CALCFIELDS(Amount);
                        if Positivo THEN BEGIN
                            //-SII1
                            //WriteNewINVDOC(Fichero,'','',Fecha,'',ChangeCommaForDot(FORMAT(ABS(CustLedgEntry.Amount),0,
                            WriteNewINVDOC(Fichero, '', '', AñoOperacion + MesOperacion + DiaOperacion, '', ChangeCommaForDot(FORMAT(ABS(CustLedgEntry.Amount), 0,
                                          //+SII1
                                          DevolverFormato(CurrCode))), '');
                            WritePCSDOC(Fichero, CustLedgEntryAUX."Payment Method Code", FindBankAcc(CustLedgEntry."Transaction No."),
                                        //-SII1
                                        //Fecha,ChangeCommaForDot(FORMAT(ABS(CustLedgEntry.Amount),0,
                                        AñoOperacion + MesOperacion + DiaOperacion, ChangeCommaForDot(FORMAT(ABS(CustLedgEntry.Amount), 0,
                                        //+SII1
                                        DevolverFormato(CurrCode))));
                        END ELSE BEGIN
                            //-SII1
                            //WriteNewINVDOC(Fichero,'','',Fecha,'',ChangeCommaForDot(FORMAT(-ABS(CustLedgEntry.Amount),0,DevolverFormato(CurrCode))),'');
                            WriteNewINVDOC(Fichero, '', '', AñoOperacion + MesOperacion + DiaOperacion, '', ChangeCommaForDot(FORMAT(-ABS(CustLedgEntry.Amount), 0, DevolverFormato(CurrCode))), '');
                            //+SII1
                            WritePCSDOC(Fichero, CustLedgEntryAUX."Payment Method Code", FindBankAcc(CustLedgEntry."Transaction No."),
                                        //-SII1
                                        //Fecha,ChangeCommaForDot(FORMAT(-ABS(CustLedgEntry.Amount),0,
                                        AñoOperacion + MesOperacion + DiaOperacion, ChangeCommaForDot(FORMAT(-ABS(CustLedgEntry.Amount), 0,
                                        //+SII1
                                        DevolverFormato(CurrCode))));
                        END;
                    UNTIL CustLedgEntryAUX.NEXT = 0;
            UNTIL CustLedgEntry.NEXT = 0;
    end;

    local procedure FindBankAcc(TransNo: Integer): Code[20]
    var
        BankAccountLedgerEntry: Record 271;
        Bankacc: Code[20];
        NotSameBank: Boolean;
    begin
        BankAccountLedgerEntry.SETRANGE("Transaction No.", TransNo);
        if BankAccountLedgerEntry.FINDSET THEN
            REPEAT
                if (Bankacc <> BankAccountLedgerEntry."Bank Account No.") AND (Bankacc <> '') THEN
                    NotSameBank := TRUE;
                Bankacc := BankAccountLedgerEntry."Bank Account No.";
            UNTIL BankAccountLedgerEntry.NEXT = 0;
        if NotSameBank THEN
            EXIT('');
        EXIT(Bankacc);
    end;

    local procedure FindDocNoToPay(DocNo: Code[20]; DocType: enum "Document Type Kuara"; FechaRegistro: Date; Sale: Boolean): Code[20]
    var
        CustLedgEntry: Record 21;
        CustLedgEntryAUX: Record 21;
        DocNoAux: Code[20];
        NotSame: Boolean;
        VendorLedgerEntry: Record 25;
        VendorLedgerEntryAUX: Record 25;
    begin
        if Sale THEN BEGIN
            FindCustLedEntry(DocNo, DocType, FechaRegistro, CustLedgEntry);
            if CustLedgEntry.FINDSET THEN
                REPEAT
                    CustLedgEntryAUX := CustLedgEntry;
                    FindAppliedCustEntries(CustLedgEntryAUX);
                    if CustLedgEntryAUX.FINDSET THEN
                        REPEAT
                            if (DocNoAux <> CustLedgEntryAUX."Document No.") AND (DocNoAux <> '') THEN
                                NotSame := TRUE;
                            DocNoAux := CustLedgEntryAUX."Document No.";
                        UNTIL CustLedgEntryAUX.NEXT = 0;
                UNTIL CustLedgEntry.NEXT = 0;
        END ELSE BEGIN
            FindVendLedEntry(DocNo, DocType, FechaRegistro, VendorLedgerEntry);
            if VendorLedgerEntry.FINDSET THEN
                REPEAT
                    VendorLedgerEntryAUX := VendorLedgerEntry;
                    FindAppliedVendEntries(VendorLedgerEntryAUX);
                    if VendorLedgerEntryAUX.FINDSET THEN
                        REPEAT
                            if (DocNoAux <> VendorLedgerEntryAUX."Document No.") AND (DocNoAux <> '') THEN
                                NotSame := TRUE;
                            //-SII1
                            //DocNoAux := VendorLedgerEntryAUX."Document No.";
                            DocNoAux := VendorLedgerEntryAUX."Applies-to Ext. Doc. No.";
                            if VendorLedgerEntryAUX."Applies-to Ext. Doc. No." = '' THEN
                                DocNoAux := VendorLedgerEntryAUX."External Document No.";
                        //+SII1
                        UNTIL VendorLedgerEntryAUX.NEXT = 0;
                UNTIL VendorLedgerEntry.NEXT = 0;
        END;
        if (NotSame) OR (DocNoAux = '') THEN
            EXIT(DocNo);
        EXIT(DocNoAux);
    end;

    local procedure IsNumeric(TipoFacSII: Text): Boolean
    var
        Number: Integer;
    begin
        EXIT(EVALUATE(Number, TipoFacSII));
    end;

#pragma warning disable AL0432
    local procedure CalcVatAmounts(var TempVatAmtAux: Record "VAT Amount Line" Temporary; var VatAmt: Decimal; var Vatbase: Decimal)
#pragma warning restore AL0432
    begin
        TempVatAmtAux.RESET;
        if TempVatAmtAux.FINDSET THEN
            REPEAT
                VatAmt += TempVatAmtAux."VAT Amount";
                Vatbase += TempVatAmtAux."VAT Base";
            UNTIL TempVatAmtAux.NEXT = 0;
    end;

#pragma warning disable AL0432
    local procedure CalcVatGenJnlLine(GenJournalLine: Record "Gen. Journal Line"; VATBusCode: Code[20]; VATProdCode: Code[20]; var TempVATAmountLines: Record "VAT Amount Line" Temporary; var TempVATPostingSetup: Record 325 temporary)
#pragma warning restore AL0432
    var
        VATPostingSetup: Record 325;
        tipofac: Code[3];
    begin
        //-C2
        VATPostingSetup.GET(VATBusCode, VATProdCode);
        if NOT VATPostingSetup."Obviar SII" THEN BEGIN
            TempVATAmountLines."VAT Identifier" := VATPostingSetup."VAT Identifier";
            TempVATAmountLines."VAT %" := VATPostingSetup."VAT %";
            //TempVATAmountLines."Vat+EC Base" := ABS(GenJournalLine."VAT Base Amount");
            TempVATAmountLines."VAT Amount" := ABS((GenJournalLine.Amount * VATPostingSetup."VAT %") / 100);
            TempVATAmountLines."Amount Including VAT" := ABS(GenJournalLine.Amount);
            TempVATAmountLines."EC %" := VATPostingSetup."EC %";
            TempVATAmountLines."EC Amount" := ABS((VATPostingSetup."EC %" * ABS(GenJournalLine.Amount)) / 100);
            TempVATAmountLines."VAT Base" := ABS(ABS(GenJournalLine.Amount) - ABS(TempVATAmountLines."EC Amount") - (TempVATAmountLines."VAT Amount"));
            TempVATAmountLines.INSERT;
            TempVATPostingSetup := VATPostingSetup;
            if TempVATPostingSetup.INSERT THEN;
        END;
        //+C2
    end;

    local procedure VATCashRegime(DocNo: Code[20]; PostingDate: Date): Boolean
    var
        VATEntry: Record 254;
    begin
        VATEntry.SETRANGE("Document No.", DocNo);
        VATEntry.SETRANGE("Posting Date", PostingDate);
        VATEntry.SETRANGE("VAT Cash Regime", TRUE);
        EXIT(VATEntry.FINDFIRST);
    end;


    /// <summary>
    /// SetRegeneracion.
    /// </summary>
    /// <param name="Tipo">Integer.</param>
    /// <param name="DocNo">Code[20].</param>
    /// <param name="DocuType">Enum "Document Type Kuara".</param>
    /// <param name="PostingDate">Date.</param>
    /// <param name="CurrCode">Code[10].</param>
    /// <param name="Customer">Boolean.</param>
    procedure SetRegeneracion(Tipo: Integer; DocNo: Code[20]; DocuType: Enum "Document Type Kuara"; PostingDate: Date; CurrCode: Code[10]; Customer: Boolean)
    begin
        //-EXP01
        //EXIT;
        //+EXP01
        TipoRegeneracion := Tipo;
        DocNumber := DocNo;
        DocumType := DocuType;
        PostDate := PostingDate;
        CurreCode := CurrCode;
        IsCust := Customer;
        Regenerar := TRUE;
    end;

#pragma warning disable AL0432
    local procedure CalcBaseACoste(var VATAmountLines: Record "VAT Amount Line" Temporary): Decimal
#pragma warning restore AL0432
    var
        decBaseACoste: Decimal;
    begin
        VATAmountLines.RESET;
        if VATAmountLines.FINDSET THEN
            REPEAT
                if VATAmountLines."VAT %" <> 0 THEN
                    decBaseACoste += (VATAmountLines."VAT Amount") / (VATAmountLines."VAT %" / 100)
                ELSE
                    decBaseACoste += VATAmountLines."VAT Amount";
            UNTIL VATAmountLines.NEXT = 0;
        EXIT(decBaseACoste);
    end;

    local procedure WriteNewIMBDOC(var Fichero: OutStream; var recTempInmueble: Record "Temp. situación inmueble SII" temporary)
    begin
        Fichero.WriteText();
        Lenght := 1;
        Fichero.WriteText('IMBDOC|' + recTempInmueble."Situación inmueble" + '|' + recTempInmueble."Ref. catastral");
    end;


    /// <summary>
    /// GetCountryType.
    /// </summary>
    /// <param name="CountryCode">Code[10].</param>
    /// <returns>Return value of type Integer.</returns>
    procedure GetCountryType(CountryCode: Code[10]): Integer
    var
        CountryRegion: Record 9;
        CompanyInfo: Record 79;
    begin
        // -SII1
        if CountryCode = '' THEN
            CountryType := CountryType::" "
        ELSE BEGIN
            CompanyInfo.GET;
            CountryRegion.GET(CountryCode);
            if CountryCode = CompanyInfo."Country/Region Code" THEN
                CountryType := CountryType::National
            ELSE
                if CountryRegion."EU Country/Region Code" = '' THEN
                    CountryType := CountryType::"3Country"
                ELSE
                    CountryType := CountryType::CEE;
        END;
        EXIT(CountryType);
        // +SII1
    end;

    local procedure GetDateFromPurchInv(DocNo: Code[20]): Date
    var
        PurchInvHeader: Record "Purch. Inv. Header";
    begin
        if PurchInvHeader.GET(DocNo) THEN
            if PurchInvHeader."Reportado SII" THEN
                EXIT(DT2DATE(PurchInvHeader."Fecha/hora subida fichero SII"))
            ELSE
                EXIT(PurchInvHeader."Posting Date");
        EXIT(TODAY);
    end;
#pragma warning disable AL0432
    local procedure ApplyCurrencyFactor(var VATAmountLines: Record "VAT Amount Line" Temporary; CurrencyFactor: Decimal)
#pragma warning restore AL0432
    begin
        //-SII1
        if CurrencyFactor = 0 THEN
            EXIT;
        if VATAmountLines.FINDSET THEN BEGIN
            REPEAT
                VATAmountLines."Amount Including VAT" /= CurrencyFactor;
                VATAmountLines."VAT Base" /= CurrencyFactor;
                VATAmountLines."VAT Amount" /= CurrencyFactor;
                VATAmountLines.MODIFY;
            UNTIL VATAmountLines.NEXT = 0;
        END;
        //+SII1
    end;

#pragma warning disable AL0432
    local procedure AgruparVatAmtLines(var recPrmTempVATAmtLines: Record "VAT Amount Line" Temporary)
#pragma warning restore AL0432
    var
#pragma warning disable AL0432
        recTempVATAmtDef: Record "VAT Amount Line" Temporary;
#pragma warning restore AL0432
    begin
        //-SII10
        //PRORRATA 2
        if recPrmTempVATAmtLines.FINDFIRST THEN BEGIN
            REPEAT
                recTempVATAmtDef.RESET;
                recTempVATAmtDef.SETRANGE("VAT %", recPrmTempVATAmtLines."VAT %");
                if recTempVATAmtDef.FINDFIRST THEN BEGIN
                    recTempVATAmtDef."VAT Base" += recPrmTempVATAmtLines."VAT Base";
                    recTempVATAmtDef."VAT Amount" += recPrmTempVATAmtLines."VAT Amount";
                    recTempVATAmtDef."Amount Including VAT" += recPrmTempVATAmtLines."Amount Including VAT";
                    recTempVATAmtDef."Line Amount" += recPrmTempVATAmtLines."Line Amount";
                    recTempVATAmtDef."Inv. Disc. Base Amount" += recPrmTempVATAmtLines."Inv. Disc. Base Amount";
                    recTempVATAmtDef."Invoice Discount Amount" += recPrmTempVATAmtLines."Invoice Discount Amount";
                    recTempVATAmtDef.Quantity += recPrmTempVATAmtLines.Quantity;
                    recTempVATAmtDef."Calculated VAT Amount" += recPrmTempVATAmtLines."Calculated VAT Amount";
                    recTempVATAmtDef."VAT Difference" += recPrmTempVATAmtLines."VAT Difference";
                    recTempVATAmtDef."EC Amount" += recPrmTempVATAmtLines."EC Amount";
                    recTempVATAmtDef."Pmt. Discount Amount" += recPrmTempVATAmtLines."Pmt. Discount Amount";
                    recTempVATAmtDef."Line Discount Amount" += recPrmTempVATAmtLines."Line Discount Amount";
                    recTempVATAmtDef."Calculated EC Amount" += recPrmTempVATAmtLines."Calculated EC Amount";
                    recTempVATAmtDef."EC Difference" += recPrmTempVATAmtLines."EC Difference";
                    //recTempVATAmtDef.Deducible += recPrmTempVATAmtLines.Deducible;
                    //recTempVATAmtDef."No deducible" += recPrmTempVATAmtLines."No deducible";
                    recTempVATAmtDef.MODIFY;
                END ELSE BEGIN
                    recTempVATAmtDef.INIT;
                    recTempVATAmtDef.TRANSFERFIELDS(recPrmTempVATAmtLines);
                    recTempVATAmtDef.INSERT;
                END;
            UNTIL recPrmTempVATAmtLines.NEXT = 0;
        END;

        recPrmTempVATAmtLines.DELETEALL;

        recTempVATAmtDef.RESET;
        if recTempVATAmtDef.FINDFIRST THEN
            REPEAT
                recPrmTempVATAmtLines.INIT;
                recPrmTempVATAmtLines.TRANSFERFIELDS(recTempVATAmtDef);
                recPrmTempVATAmtLines.INSERT;
            UNTIL recTempVATAmtDef.NEXT = 0;
        //PRORRATA 2
        //+SII10
    end;

    local procedure FillTempRecord(var TempSelectedRecords: Record 10732 temporary)
    begin
        //-EXP01
        CASE ExportOptions OF
            ExportOptions::Compras:
                FillTempPurchases(TempSelectedRecords);
            ExportOptions::Ventas:
                FillTempSales(TempSelectedRecords);
        END;
        //+EXP01
    end;

    local procedure FillTempPurchases(var TempSelectedRecords: Record 10732 temporary)
    var
        PurchInvHeader: Record "Purch. Inv. Header";
        PurchCrMemoHdr: Record "Purch. Cr. Memo Hdr.";
        PurchInvLine: Record 123;
        ExportRecord: Boolean;
        TextoError: Text[250];
        PurchCrMemoLine: Record 125;
        FoundPostedDoc: Boolean;
        Vendor: Record Vendor;
        InitDate: Date;
        LastDate: Date;
    begin
        //-EXP01
        InitDate := 20170101D;
        LastDate := 20170630D;
        if VendorLedgerEntry.GETFILTER("Posting Date") = '' THEN
            VendorLedgerEntry.SETRANGE("Posting Date", InitDate, LastDate);
        if VendorLedgerEntry.FINDSET THEN
            REPEAT
                TextoError := '';
                FoundPostedDoc := FALSE;
                if (PurchInvHeader.GET(VendorLedgerEntry."Document No.")) AND (VendorLedgerEntry."Document Type" = VendorLedgerEntry."Document Type"::Invoice) THEN BEGIN
                    PurchInvHeader.CALCFIELDS("Amount Including VAT");
                    PurchInvLine.SETRANGE("Document No.", PurchInvHeader."No.");
                    PurchInvLine.SETFILTER("VAT Bus. Posting Group", '<>%1', '');
                    PurchInvLine.SETFILTER("VAT Prod. Posting Group", '<>%1', '');
                    ExportRecord := TRUE;
                    if PurchInvLine.FINDSET THEN
                        REPEAT
                            ExportRecord := NoConflictInDocument(FALSE, PurchInvLine."Document No.", PurchInvLine."VAT Bus. Posting Group",
                                                                 PurchInvLine."VAT Prod. Posting Group", TextoError);
                        UNTIL (PurchInvLine.NEXT = 0) OR (NOT ExportRecord);
                    FillRecordsToBeExported(TempSelectedRecords, FALSE, PurchInvHeader."Buy-from Vendor No.", PurchInvHeader."Buy-from Vendor Name",
                                            PurchInvHeader."Posting Date", PurchInvHeader."No.",
                                            PurchInvHeader."Amount Including VAT", ExportRecord, TextoError, PurchInvHeader."VAT Bus. Posting Group",
                                            VendorLedgerEntry."Document Type");
                    FoundPostedDoc := TRUE
                END;
                if (PurchCrMemoHdr.GET(VendorLedgerEntry."Document No.")) AND (VendorLedgerEntry."Document Type" = VendorLedgerEntry."Document Type"::"Credit Memo") THEN BEGIN
                    PurchCrMemoHdr.CALCFIELDS("Amount Including VAT");
                    PurchCrMemoLine.SETRANGE("Document No.", PurchCrMemoHdr."No.");
                    PurchCrMemoLine.SETFILTER("VAT Bus. Posting Group", '<>%1', '');
                    PurchCrMemoLine.SETFILTER("VAT Prod. Posting Group", '<>%1', '');
                    ExportRecord := TRUE;
                    if PurchCrMemoLine.FINDSET THEN
                        REPEAT
                            ExportRecord := NoConflictInDocument(FALSE, PurchCrMemoLine."Document No.", PurchCrMemoLine."VAT Bus. Posting Group",
                                                                 PurchCrMemoLine."VAT Prod. Posting Group", TextoError);
                        UNTIL (PurchCrMemoLine.NEXT = 0) OR (NOT ExportRecord);
                    FillRecordsToBeExported(TempSelectedRecords, FALSE, PurchCrMemoHdr."Buy-from Vendor No.", PurchCrMemoHdr."Buy-from Vendor Name",
                                            PurchCrMemoHdr."Posting Date", PurchCrMemoHdr."No.",
                                            PurchCrMemoHdr."Amount Including VAT", ExportRecord, TextoError, PurchCrMemoHdr."VAT Bus. Posting Group",
                                            VendorLedgerEntry."Document Type");
                    FoundPostedDoc := TRUE
                END;
                if NOT FoundPostedDoc THEN BEGIN
                    VendorLedgerEntry.CALCFIELDS(Amount);
                    Vendor.GET(VendorLedgerEntry."Buy-from Vendor No.");
                    CheckConflictInVATEntries(VendorLedgerEntry."Document No.", VendorLedgerEntry."Posting Date", ExportRecord, TextoError);
                    FillRecordsToBeExported(TempSelectedRecords, FALSE, VendorLedgerEntry."Buy-from Vendor No.", Vendor.Name,
                                      VendorLedgerEntry."Posting Date", VendorLedgerEntry."Document No.",
                                      ABS(VendorLedgerEntry.Amount), ExportRecord, TextoError,
                                      GetVATBusVATEntry(VendorLedgerEntry."Document No.", VendorLedgerEntry."Posting Date"), VendorLedgerEntry."Document Type");
                END;
            UNTIL VendorLedgerEntry.NEXT = 0;
        //+EXP01
    end;

    local procedure FillTempSales(var TempSelectedRecords: Record 10732 temporary)
    var
        SalesInvoiceHeader: Record 112;
        SalesInvoiceLine: Record 113;
        SalesCrMemoHeader: Record 114;
        SalesCrMemoLine: Record 115;
        ExportRecord: Boolean;
        TextoError: Text[250];
        ServiceInvoiceHeader: Record 5992;
        ServiceInvoiceLine: Record 5993;
        ServiceCrMemoHeader: Record 5994;
        ServiceCrMemoLine: Record 5995;
        AmountIncludingVAT: Decimal;
        FoundPostedDoc: Boolean;
        Customer: Record Customer;
        InitDate: Date;
        LastDate: Date;
    begin
        //-EXP01
        InitDate := 20170101D;
        LastDate := 20170630D;
        if CustLedgerEntry.GETFILTER("Posting Date") = '' THEN
            CustLedgerEntry.SETRANGE("Posting Date", InitDate, LastDate);
        if CustLedgerEntry.FINDSET THEN
            REPEAT
                TextoError := '';
                FoundPostedDoc := FALSE;
                if SalesInvoiceHeader.GET(CustLedgerEntry."Document No.") THEN BEGIN
                    FoundPostedDoc := TRUE;
                    SalesInvoiceHeader.CALCFIELDS("Amount Including VAT");
                    SalesInvoiceLine.SETRANGE("Document No.", SalesInvoiceHeader."No.");
                    SalesInvoiceLine.SETFILTER("VAT Bus. Posting Group", '<>%1', '');
                    SalesInvoiceLine.SETFILTER("VAT Prod. Posting Group", '<>%1', '');
                    ExportRecord := TRUE;
                    if SalesInvoiceLine.FINDSET THEN
                        REPEAT
                            ExportRecord := NoConflictInDocument(FALSE, SalesInvoiceLine."Document No.", SalesInvoiceLine."VAT Bus. Posting Group",
                                                                 SalesInvoiceLine."VAT Prod. Posting Group", TextoError);
                        UNTIL (SalesInvoiceLine.NEXT = 0) OR (NOT ExportRecord);
                    FillRecordsToBeExported(TempSelectedRecords, TRUE, SalesInvoiceHeader."Bill-to Customer No.", SalesInvoiceHeader."Bill-to Name",
                                            SalesInvoiceHeader."Posting Date", SalesInvoiceHeader."No.",
                                            SalesInvoiceHeader."Amount Including VAT", ExportRecord, TextoError, SalesInvoiceHeader."VAT Bus. Posting Group",
                                            CustLedgerEntry."Document Type");
                END;

                if SalesCrMemoHeader.GET(CustLedgerEntry."Document No.") THEN BEGIN
                    FoundPostedDoc := TRUE;
                    SalesCrMemoHeader.CALCFIELDS("Amount Including VAT");
                    SalesCrMemoLine.SETRANGE("Document No.", SalesCrMemoHeader."No.");
                    SalesCrMemoLine.SETFILTER("VAT Bus. Posting Group", '<>%1', '');
                    SalesCrMemoLine.SETFILTER("VAT Prod. Posting Group", '<>%1', '');
                    ExportRecord := TRUE;
                    if SalesCrMemoLine.FINDSET THEN
                        REPEAT
                            ExportRecord := NoConflictInDocument(FALSE, SalesCrMemoLine."Document No.", SalesCrMemoLine."VAT Bus. Posting Group",
                                                                 SalesCrMemoLine."VAT Prod. Posting Group", TextoError);
                        UNTIL (SalesCrMemoLine.NEXT = 0) OR (NOT ExportRecord);
                    FillRecordsToBeExported(TempSelectedRecords, TRUE, SalesCrMemoHeader."Bill-to Customer No.", SalesCrMemoHeader."Bill-to Name",
                                            SalesCrMemoHeader."Posting Date", SalesCrMemoHeader."No.",
                                            SalesCrMemoHeader."Amount Including VAT", ExportRecord, TextoError, SalesCrMemoHeader."VAT Bus. Posting Group",
                                            CustLedgerEntry."Document Type");
                END;

                if ServiceInvoiceHeader.GET(CustLedgerEntry."Document No.") THEN BEGIN
                    FoundPostedDoc := TRUE;
                    ServiceInvoiceLine.SETRANGE("Document No.", ServiceInvoiceHeader."No.");
                    ServiceInvoiceLine.SETFILTER("VAT Bus. Posting Group", '<>%1', '');
                    ServiceInvoiceLine.SETFILTER("VAT Prod. Posting Group", '<>%1', '');
                    ExportRecord := TRUE;
                    if ServiceInvoiceLine.FINDSET THEN
                        REPEAT
                            ExportRecord := NoConflictInDocument(FALSE, ServiceInvoiceLine."Document No.", ServiceInvoiceLine."VAT Bus. Posting Group",
                                                                 ServiceInvoiceLine."VAT Prod. Posting Group", TextoError);
                        UNTIL (ServiceInvoiceLine.NEXT = 0) OR (NOT ExportRecord);
                    AmountIncludingVAT := 0;
                    ServiceInvoiceLine.RESET;
                    ServiceInvoiceLine.SETRANGE("Document No.", ServiceInvoiceHeader."No.");
                    if ServiceInvoiceLine.FINDSET THEN
                        REPEAT
                            AmountIncludingVAT += ServiceInvoiceLine."Amount Including VAT";
                        UNTIL ServiceInvoiceLine.NEXT = 0;
                    FillRecordsToBeExported(TempSelectedRecords, TRUE, ServiceInvoiceHeader."Bill-to Customer No.", ServiceInvoiceHeader."Bill-to Name",
                                            ServiceInvoiceHeader."Posting Date", ServiceInvoiceHeader."No.",
                                            AmountIncludingVAT, ExportRecord, TextoError, ServiceInvoiceHeader."VAT Bus. Posting Group",
                                            CustLedgerEntry."Document Type");
                END;

                if ServiceCrMemoHeader.GET(CustLedgerEntry."Document No.") THEN BEGIN
                    FoundPostedDoc := TRUE;
                    ServiceCrMemoLine.SETRANGE("Document No.", ServiceCrMemoHeader."No.");
                    ServiceCrMemoLine.SETFILTER("VAT Bus. Posting Group", '<>%1', '');
                    ServiceCrMemoLine.SETFILTER("VAT Prod. Posting Group", '<>%1', '');
                    ExportRecord := TRUE;
                    if ServiceCrMemoLine.FINDSET THEN
                        REPEAT
                            ExportRecord := NoConflictInDocument(FALSE, ServiceCrMemoLine."Document No.", ServiceCrMemoLine."VAT Bus. Posting Group",
                                                                 ServiceCrMemoLine."VAT Prod. Posting Group", TextoError);
                        UNTIL (ServiceCrMemoLine.NEXT = 0) OR (NOT ExportRecord);
                    AmountIncludingVAT := 0;
                    ServiceCrMemoLine.RESET;
                    ServiceCrMemoLine.SETRANGE("Document No.", ServiceCrMemoHeader."No.");
                    if ServiceCrMemoLine.FINDSET THEN
                        REPEAT
                            AmountIncludingVAT += ServiceCrMemoLine."Amount Including VAT";
                        UNTIL ServiceCrMemoLine.NEXT = 0;
                    FillRecordsToBeExported(TempSelectedRecords, TRUE, ServiceCrMemoHeader."Bill-to Customer No.", ServiceCrMemoHeader."Bill-to Name",
                                            ServiceCrMemoHeader."Posting Date", ServiceCrMemoHeader."No.",
                                            AmountIncludingVAT, ExportRecord, TextoError, ServiceCrMemoHeader."VAT Bus. Posting Group",
                                            CustLedgerEntry."Document Type");
                END;
                if NOT FoundPostedDoc THEN BEGIN
                    CustLedgerEntry.CALCFIELDS(Amount);
                    Customer.GET(CustLedgerEntry."Sell-to Customer No.");
                    CheckConflictInVATEntries(CustLedgerEntry."Document No.", CustLedgerEntry."Posting Date", ExportRecord, TextoError);
                    FillRecordsToBeExported(TempSelectedRecords, TRUE, CustLedgerEntry."Sell-to Customer No.", Customer.Name,
                                      CustLedgerEntry."Posting Date", CustLedgerEntry."Document No.",
                                          CustLedgerEntry.Amount, ExportRecord, TextoError,
                                          GetVATBusVATEntry(CustLedgerEntry."Document No.", CustLedgerEntry."Posting Date"),
                                          CustLedgerEntry."Document Type");
                END;
            UNTIL CustLedgerEntry.NEXT = 0;
        //+EXP01
    end;

    local procedure FillRecordsToBeExported(var TempSelectedRecords: Record 10732 temporary; Sale: Boolean; CustVendNo: Code[20]; CustVendName: Text[100]; PostingDate: Date; DocumentNo: Code[20]; AmountInclVAT: Decimal; ExportRecord: Boolean; TextoError: Text[250]; VATBusCode: Code[20]; DocumType: Enum "Gen. Journal Document Type")
    var
        VATBusinessPostingGroup: Record 323;
    begin
        //-EXP01
        if VATBusinessPostingGroup.GET(VATBusCode) THEN;
        // WITH TempSelectedRecords DO BEGIN
        TempSelectedRecords.INIT;
        TempSelectedRecords."Entry No." += 1;
        if Sale THEN
            TempSelectedRecords.Type := TempSelectedRecords.Type::Sale
        ELSE
            TempSelectedRecords.Type := TempSelectedRecords.Type::Purchase;
        TempSelectedRecords."Customer/Vendor No." := CustVendNo;
        TempSelectedRecords."Customer/Vendor Name" := CustVendName;
        TempSelectedRecords."Posting Date" := PostingDate;
        TempSelectedRecords."Document No." := DocumentNo;
        TempSelectedRecords."Previous Declared Amount" := AmountInclVAT;
        TempSelectedRecords.Exported := ExportRecord;
        TempSelectedRecords."Texto Error" := TextoError;
        Case DocumType Of
            DocumType::" ", DocumType::Advance:
                TempSelectedRecords."Document Type" := TempSelectedRecords."Document Type"::" ";
            DocumType::Bill:
                TempSelectedRecords."Document Type" := TempSelectedRecords."Document Type"::Bill;
            DocumType::"Credit Memo":
                TempSelectedRecords."Document Type" := TempSelectedRecords."Document Type"::"Credit Memo";
            DocumType::"Finance Charge Memo":
                TempSelectedRecords."Document Type" := TempSelectedRecords."Document Type"::"Finance Charge Memo";
            DocumType::Invoice:
                TempSelectedRecords."Document Type" := TempSelectedRecords."Document Type"::Invoice;
            DocumType::Payment:
                TempSelectedRecords."Document Type" := TempSelectedRecords."Document Type"::Payment;
            DocumType::Receipt:
                TempSelectedRecords."Document Type" := TempSelectedRecords."Document Type"::Albaran;
            DocumType::Refund:
                TempSelectedRecords."Document Type" := TempSelectedRecords."Document Type"::Refund;
            DocumType::Reminder:
                TempSelectedRecords."Document Type" := TempSelectedRecords."Document Type"::Reminder;
        End;
        if Sale THEN
            TempSelectedRecords."Clave registro" := VATBusinessPostingGroup."Clave registro SII expedidas"
        ELSE
            TempSelectedRecords."Clave registro" := VATBusinessPostingGroup."Clave registro SII recibidas";
        TempSelectedRecords.INSERT;
        // END;
        //+EXP01
    end;

    local procedure NoConflictInDocument(GiveError: Boolean; DocNo: Code[20]; VATBusCode: Code[10]; VATProdCode: Code[10]; var TextoError: Text[250]): Boolean
    var
        VATPostingSetup: Record 325;
        Text50000: Label 'La combinación de IVA %1 %2 no existe para el documento %3';
        VATBusinessPostingGroup: Record 323;
        Text50001: Label 'La grupo registro IVA negocio %1 no existe para el documento %2';
        Text50002: Label 'Sujeta exenta en %1 %2 no está informado';
        Text50003: Label 'Tipo desglose emitidas en %1 %2 no está informado';
        Text50004: Label 'Tipo desglose recibidas en %1 %2 no está informado';
        Text50005: Label 'Tipo operación en %1 %2 no está informado';
        Text50006: Label 'Clave registro expedidas en grupo registro IVA negocio %1 no está informado';
        Text50007: Label 'Clave registro recibidas en grupo registro IVA negocio %1 no está informado';
    begin
        //-EXP01
        //si se le pasa el giveerror como true, petará si seleccionan a exportar la factura que daba problemas...
        if (VATBusCode = '') AND (VATProdCode = '') THEN
            EXIT;
        if NOT VATBusinessPostingGroup.GET(VATBusCode) THEN BEGIN
            if GiveError THEN
                ERROR(STRSUBSTNO(Text50001, VATBusCode, DocNo));
            TextoError := STRSUBSTNO(Text50001, VATBusCode, VATProdCode, DocNo);
            EXIT(FALSE);
        END;
        if NOT VATPostingSetup.GET(VATBusCode, VATProdCode) THEN BEGIN
            if GiveError THEN
                ERROR(STRSUBSTNO(Text50000, VATBusCode, VATProdCode, DocNo));
            TextoError := STRSUBSTNO(Text50000, VATBusCode, VATProdCode, DocNo);
            EXIT(FALSE);
        END;
        if GiveError THEN BEGIN
            if ExportOptions IN [ExportOptions::Ventas] THEN BEGIN
                VATBusinessPostingGroup.TESTFIELD("Clave registro SII expedidas");
                VATPostingSetup.TESTFIELD("Tipo desglose emitidas");
                VATPostingSetup.TESTFIELD("Sujeta exenta");
                VATPostingSetup.TESTFIELD("Tipo de operación");
            END ELSE BEGIN
                VATBusinessPostingGroup.TESTFIELD("Clave registro SII recibidas");
                VATPostingSetup.TESTFIELD("Tipo desglose recibidas");
            END;
        END ELSE BEGIN
            if ExportOptions IN [ExportOptions::Ventas] THEN BEGIN
                if VATBusinessPostingGroup."Clave registro SII expedidas" = '' THEN
                    TextoError := STRSUBSTNO(Text50006, VATBusCode);
                if VATPostingSetup."Tipo desglose emitidas" = '' THEN
                    FillTxt(TextoError, STRSUBSTNO(Text50003, VATBusCode, VATProdCode));
                if VATPostingSetup."Sujeta exenta" = '' THEN
                    FillTxt(TextoError, STRSUBSTNO(Text50002, VATBusCode, VATProdCode));
                if VATPostingSetup."Tipo de operación" = '' THEN
                    FillTxt(TextoError, STRSUBSTNO(Text50005, VATBusCode, VATProdCode));
            END ELSE BEGIN
                if VATBusinessPostingGroup."Clave registro SII recibidas" = '' THEN
                    FillTxt(TextoError, STRSUBSTNO(Text50007, VATBusCode));
                if VATPostingSetup."Tipo desglose recibidas" = '' THEN
                    FillTxt(TextoError, STRSUBSTNO(Text50004, VATBusCode, VATProdCode));
            END;
        END;
        if TextoError <> '' THEN
            EXIT(FALSE);
        EXIT(TRUE);
        //+EXP01
    end;

    local procedure WriteSelectedDocs(var TempSelectedRecords: Record 10732 temporary)
    var
        PurchInvHeader: Record "Purch. Inv. Header";
        PurchCrMemoHdr: Record "Purch. Cr. Memo Hdr.";
        SalesInvoiceHeader: Record 112;
        SalesCrMemoHeader: Record 114;
        ServiceInvoiceHeader: Record 5992;
        ServiceCrMemoHeader: Record 5994;
    begin
        //-EXP01
        TempSelectedRecords.RESET;
        TempSelectedRecords.SETRANGE(Exported, TRUE);
        if TempSelectedRecords.FINDSET THEN BEGIN
            REPEAT
                if SendingProfile = SendingProfile::Alta THEN
                    RegenerarFichero(2, TempSelectedRecords."Document No.", TempSelectedRecords."Document Type", TempSelectedRecords."Posting Date", '')
                ELSE
                    RegenerarFichero(0, TempSelectedRecords."Document No.", TempSelectedRecords."Document Type"::" ", TempSelectedRecords."Posting Date", '');
            UNTIL TempSelectedRecords.NEXT = 0;
            MESSAGE(Text012);
        END;
        //+EXP01
    end;

    local procedure FillTxt(var Txt: Text[250]; Value: Text[250])
    begin
        //-EXP01
        if Txt <> '' THEN
            Txt += ', ' + Value
        ELSE
            Txt := Value;
        //+EXP01
    end;

    local procedure CheckConflictInVATEntries(DocNo: Code[20]; PostingDate: Date; var ExportRecord: Boolean; var TextoError: Text[250])
    var
        VATEntry: Record 254;
    begin
        //-EXP01
        ExportRecord := TRUE;
        VATEntry.SETRANGE("Document No.", DocNo);
        VATEntry.SETRANGE("Posting Date", PostingDate);
        if VATEntry.FINDSET THEN
            REPEAT
                ExportRecord := NoConflictInDocument(FALSE, VATEntry."Document No.", VATEntry."VAT Bus. Posting Group",
                                                      VATEntry."VAT Prod. Posting Group", TextoError);
            UNTIL (VATEntry.NEXT = 0) OR (NOT ExportRecord);
        //+EXP01
    end;

    local procedure GetVATBusVATEntry(DocNo: Code[20]; PostingDate: Date): Code[10]
    var
        VATEntry: Record 254;
    begin
        //-EXP01
        VATEntry.SETRANGE("Posting Date", PostingDate);
        VATEntry.SETRANGE("Document No.", DocNo);
        if VATEntry.FINDFIRST THEN
            EXIT(VATEntry."VAT Bus. Posting Group");
        //+EXP01
    end;

    local procedure PaidNow(DocNo: Code[20]; PostingDate: Date; var TipoFacturaSII: Code[3]): Boolean
    var
        Paid: Boolean;
        VATEntry: Record 254;
        VATCashRegime: Boolean;
        DocType: Enum "Document Type Kuara";
    begin
        VATEntry.SETRANGE("Document No.", DocNo);
        //posting date es incorrecto.
        VATEntry.SETRANGE("Posting Date", PostingDate);
        VATEntry.SETRANGE("VAT Cash Regime", TRUE);
        VATCashRegime := VATEntry.FINDFIRST;
        //comprobamos que no se haya hecho la contrapartida al momento de registrar y que sea criterio caja...
        //VATEntry.SETFILTER("Document Type",'%1|%2|%3',DocType::Payment,DocType."Document Type"::Refund,DocType."Document Type"::Bill);
        VATEntry.SETFILTER("Document Type", '%1|%2|%3', DocType::Payment, DocType::Refund, DocType::Bill);
        //falta que al registrar los diarios de pago, se genere correctamente el fichero ya que falta el impdoc al
        // registrarlo, corregir linea de abajo o probar. nose si sta bn
        Paid := VATEntry.FINDFIRST;
        TipoFacturaSII := VATEntry."Tipo factura SII";
        EXIT(Paid);
    end;


    /// <summary>
    /// CreateOrUpdateFilePurchB1.
    /// </summary>
    /// <param name="PurchInvHeader">VAR Record 122.</param>
    /// <param name="PurchCrMemoHeader">VAR Record 124.</param>
    /// <param name="WriteIMPDOC">Boolean.</param>
    procedure CreateOrUpdateFilePurchB1(var PurchInvHeader: Record "Purch. Inv. Header"; var PurchCrMemoHeader: Record "Purch. Cr. Memo Hdr."; WriteIMPDOC: Boolean)
    var
        Fichero: OutStream;
        RutaFichero: Text[250];
        TipoIDEmisor: Code[3];
        IDEmisor: Code[20];
        PaisEmisor: Code[10];
        CompanyInformation: Record 79;
        "Año": Text;
        Mes: Text;
        Dia: Text;
        NifReceptor: Code[20];
#pragma warning disable AL0432
        TempVATAmountLines: Record "VAT Amount Line" Temporary;
#pragma warning restore AL0432
        TempVatPostStp: Record 325 temporary;
        VATBusPostGrp: Record 323;
        CuotaDeducible: Decimal;
        TextCuotaDeducible: Text;
        IVACaja: Boolean;
        VendName: Text[100];
        VatNo: Text;
        FechaImputacion: Date;
        "AñoImputacion": Text;
        MesImputacion: Text;
        DiaImputacion: Text;
        decImporteIVAincl: Decimal;
        decImporte: Decimal;
        PurchInvoiceLine: Record 123;
        PurchCrMemoLine: Record 125;
        VatPostStp: Record 325;
        "AñoOperacion": Text;
        MesOperacion: Text;
        DiaOperacion: Text;
        Vendor: Record Vendor;
        Customer: Record Customer;
    begin
        Vendor.Init;
        Customer.Init();
        //-001
        /*if NOT HasVAT THEN
          EXIT;*/
        ExistsFile := FALSE;
        /*if PurchInvHeader."No." <> '' THEN
          IVACaja := CriterioCaja(PurchInvHeader."No.",PurchInvHeader."Posting Date")
        ELSE
          IVACaja := CriterioCaja(PurchCrMemoHeader."No.",PurchCrMemoHeader."Posting Date");
        if IVACaja THEN
          EXIT;*/
        //-SII1
        GetGLSetup;
        if (GLSetup."Exportar SII desde fecha" <> 0D) THEN
            if PurchInvHeader."No." <> '' THEN BEGIN
                Vendor.Get(PurchInvHeader."Pay-to Vendor No.");
                if (PurchInvHeader."Posting Date" < GLSetup."Exportar SII desde fecha") THEN
                    EXIT;
            END ELSE
                if PurchCrMemoHeader."No." <> '' THEN BEGIN
                    Vendor.Get(PurchCrMemoHeader."Pay-to Vendor No.");
                    if (PurchCrMemoHeader."Posting Date" < GLSetup."Exportar SII desde fecha") THEN
                        EXIT;
                END;
        //+SII1
        if (PurchInvHeader."No." <> '') OR (PurchCrMemoHeader."No." <> '') THEN BEGIN
            if PurchInvHeader."No." <> '' Then
                OpenFile(OpenOrCreateFile('FR', FALSE), Fichero, PurchInvHeader."No.", true)
            else
                OpenFile(OpenOrCreateFile('FR', FALSE), Fichero, PurchCrmemoHeader."No.", true);
            GetGLSetup;
            CompanyInformation.GET;
            if Lenght = 0 THEN
                WriteNewFile(Fichero, GLSetup, 'FR', 'B1');
        END;
        if PurchInvHeader."No." <> '' THEN BEGIN
            //-c1
            //-SII1
            //DevolverAnoMesDia(TODAY,Año,Mes,Dia);
            Vendor.Get(PurchInvHeader."Pay-to Vendor No.");
            DevolverAnoMesDia(PurchInvHeader."Document Date", Año, Mes, Dia);
            DevolverAnoMesDia(TODAY, AñoOperacion, MesOperacion, DiaOperacion);
            //+SII1
            //+c1
            SetTipoIDEMIDEmPaisEMNIFEm(PurchInvHeader."Buy-from Vendor No.", TipoIDEmisor, IDEmisor, PaisEmisor, NifReceptor, VendName);
            FechaImputacion := DevolverFechaImp(PurchInvHeader."VAT Bus. Posting Group", PurchInvHeader."Posting Date",
                                PurchInvHeader."Due Date", PurchInvHeader."Document Date", 10, PurchInvHeader."No.");
            DevolverAnoMesDia(FechaImputacion, AñoImputacion, MesImputacion, DiaImputacion);
            //WriteNewDoc(Fichero,AñoImputacion,MesImputacion,PurchInvHeader."Tipo factura SII",PurchInvHeader."No.",Año+Mes+Dia,
            //PurchInvHeader."VAT Registration No.", VendName,
            //            TipoIDEmisor,IDEmisor,PaisEmisor,CompanyInformation."VAT Registration No.", CompanyInformation.Name, '','','');
            WriteNewDoc(Fichero, AñoImputacion, MesImputacion, PurchInvHeader."Tipo factura SII",
                        //-SII1
                        //PurchInvHeader."No.",Año+Mes+Dia,PurchInvHeader."VAT Registration No.", VendName,
                        PurchInvHeader."Vendor Invoice No.", Año + Mes + Dia, NifReceptor, VendName,
          //TipoIDEmisor,IDEmisor,PaisEmisor,PurchInvHeader."VAT Registration No.", VendName, TipoIDEmisor,IDEmisor,PaisEmisor);
          //TipoIDEmisor,IDEmisor,PaisEmisor,PurchInvHeader."VAT Registration No.", VendName, '',''{CompanyInformation."VAT Registration No."},PaisEmisor);
          TipoIDEmisor, IDEmisor, PaisEmisor, NifReceptor, VendName, TipoIDEmisor, IDEmisor/*CompanyInformation."VAT Registration No."*/, PaisEmisor, Vendor, Customer);

            PurchInvHeader.CALCFIELDS("Amount Including VAT");
            PurchInvHeader.CALCFIELDS(Amount);
            CLEAR(decImporteIVAincl);
            CLEAR(decImporte);

            PurchInvoiceLine.RESET;
            PurchInvoiceLine.SETRANGE("Document No.", PurchInvHeader."No.");
            if PurchInvoiceLine.FINDFIRST THEN
                REPEAT
                    if VatPostStp.GET(PurchInvoiceLine."VAT Bus. Posting Group", PurchInvoiceLine."VAT Prod. Posting Group") THEN BEGIN
                        if (NOT (VatPostStp."Obviar SII")) THEN BEGIN
                            decImporteIVAincl += PurchInvoiceLine."Amount Including VAT";
                            decImporte += PurchInvoiceLine.Amount;
                        END;
                    END;
                UNTIL PurchInvoiceLine.NEXT = 0;
            //-SII1
            if PurchInvHeader."Currency Factor" <> 0 THEN BEGIN
                decImporteIVAincl /= PurchInvHeader."Currency Factor";
                decImporte /= PurchInvHeader."Currency Factor";
            END;
            //+SII1
            CalcVATAmtLines(1, PurchInvHeader."No.", TempVATAmountLines, TempVatPostStp);
            //llamar
            //-SII1
            //aplicamos divisas...
            ApplyCurrencyFactor(TempVATAmountLines, PurchInvHeader."Currency Factor");
            //+SII1
            VATBusPostGrp.GET(PurchInvHeader."VAT Bus. Posting Group");
            CuotaDeducible := CalcCuotaDeducible(TempVATAmountLines);
            //if CuotaDeducible <> 0 THEN
            TextCuotaDeducible := ChangeCommaForDot(FORMAT(CuotaDeducible, 0, DevolverFormato(PurchInvHeader."Currency Code")));
            WriteNewINVDOC(Fichero, VATBusPostGrp."Clave registro SII recibidas", PurchInvHeader."Descripción operación",
                          //-SII1
                          // AñoImputacion+MesImputacion+DiaImputacion,TextCuotaDeducible,
                          AñoOperacion + MesOperacion + DiaOperacion, TextCuotaDeducible,
                          //+SII1
                          //ChangeCommaForDot(FORMAT(PurchInvHeader."Amount Including VAT",0,'<Sign><Integer><Decimals,3>')),
                          //ChangeCommaForDot(FORMAT(PurchInvHeader.Amount,0,'<Sign><Integer><Decimals,3>')));
                          ChangeCommaForDot(FORMAT(decImporteIVAincl, 0, DevolverFormato(PurchInvHeader."Currency Code"))),
                          ChangeCommaForDot(FORMAT(decImporte, 0, DevolverFormato(PurchInvHeader."Currency Code"))));
            WriteNewIMPDOC(Fichero, TempVATAmountLines, FALSE, TempVatPostStp, FALSE, 'FR', PurchInvHeader."Currency Code");
            //-SII1
            if WriteIMPDOC THEN
                WriteNewRECDOC(Fichero, TempVATAmountLines, PurchInvHeader."Tipo factura rectificativa", PurchInvHeader."Currency Code");
            //+SII1
            PurchInvHeader."Reportado SII" := TRUE;
            PurchInvHeader."Nombre fichero SII" := RutaFichero;
            PurchInvHeader."Fecha/hora subida fichero SII" := CURRENTDATETIME;
            PurchInvHeader.MODIFY;
            //-jb
            FicheroCLOSE(Fichero);
            //+jb
        END;
        if PurchCrMemoHeader."No." <> '' THEN BEGIN
            //-c1
            //-SII1
            //DevolverAnoMesDia(TODAY,Año,Mes,Dia);
            Vendor.Get(PurchCrMemoHeader."Pay-to Vendor No.");
            DevolverAnoMesDia(PurchCrMemoHeader."Document Date", Año, Mes, Dia);
            DevolverAnoMesDia(TODAY, AñoOperacion, MesOperacion, DiaOperacion);
            //+SII1
            //+c1
            SetTipoIDEMIDEmPaisEMNIFEm(PurchCrMemoHeader."Buy-from Vendor No.", TipoIDEmisor, IDEmisor, PaisEmisor, NifReceptor, VendName);
            //calculo de cuota deducible: base factura * IVA.
            FechaImputacion := DevolverFechaImp(PurchCrMemoHeader."VAT Bus. Posting Group", PurchCrMemoHeader."Posting Date",
                               PurchCrMemoHeader."Due Date", PurchCrMemoHeader."Document Date", 10, PurchCrMemoHeader."No.");
            DevolverAnoMesDia(FechaImputacion, AñoImputacion, MesImputacion, DiaImputacion);
            //WriteNewDoc(Fichero,AñoImputacion,MesImputacion,PurchCrMemoHeader."Tipo factura SII",
            //PurchCrMemoHeader."No.",Año+Mes+Dia,PurchCrMemoHeader."VAT Registration No.", VendName,
            //            TipoIDEmisor,IDEmisor,PaisEmisor,CompanyInformation."VAT Registration No.", CompanyInformation.Name, '','','');
            WriteNewDoc(Fichero, AñoImputacion, MesImputacion, PurchCrMemoHeader."Tipo factura SII",
                        //-SII1
                        //PurchCrMemoHeader."No.",Año+Mes+Dia,PurchCrMemoHeader."VAT Registration No.", VendName,
                        PurchCrMemoHeader."Vendor Cr. Memo No.", Año + Mes + Dia, NifReceptor, VendName,
          //TipoIDEmisor,IDEmisor,PaisEmisor,PurchCrMemoHeader."VAT Registration No.", VendName,TipoIDEmisor, IDEmisor,PaisEmisor);
          //TipoIDEmisor,IDEmisor,PaisEmisor,PurchInvHeader."VAT Registration No.", VendName, '',''{CompanyInformation."VAT Registration No."},PaisEmisor);
          TipoIDEmisor, IDEmisor, PaisEmisor, NifReceptor, VendName, TipoIDEmisor, IDEmisor/*CompanyInformation."VAT Registration No."*/, PaisEmisor, Vendor, Customer);

            //+SII1
            PurchCrMemoHeader.CALCFIELDS("Amount Including VAT");
            PurchCrMemoHeader.CALCFIELDS(Amount);
            CLEAR(decImporteIVAincl);
            CLEAR(decImporte);

            PurchCrMemoLine.RESET;
            PurchCrMemoLine.SETRANGE("Document No.", PurchCrMemoHeader."No.");
            if PurchCrMemoLine.FINDFIRST THEN
                REPEAT
                    if (VatPostStp.GET(PurchCrMemoLine."VAT Bus. Posting Group", PurchCrMemoLine."VAT Prod. Posting Group")
                        AND (NOT (VatPostStp."Obviar SII"))) THEN BEGIN
                        decImporteIVAincl += PurchCrMemoLine."Amount Including VAT";
                        decImporte += PurchCrMemoLine.Amount;
                    END;
                UNTIL PurchCrMemoLine.NEXT = 0;
            //-SII1
            if PurchCrMemoHeader."Currency Factor" <> 0 THEN BEGIN
                decImporteIVAincl *= PurchCrMemoHeader."Currency Factor";
                decImporte *= PurchCrMemoHeader."Currency Factor";
            END;
            //+SII1
            CalcVATAmtLines(3, PurchCrMemoHeader."No.", TempVATAmountLines, TempVatPostStp);
            //llamar
            //-SII1
            ApplyCurrencyFactor(TempVATAmountLines, PurchCrMemoHeader."Currency Factor");
            //+SII1
            VATBusPostGrp.GET(PurchCrMemoHeader."VAT Bus. Posting Group");
            CuotaDeducible := CalcCuotaDeducible(TempVATAmountLines);
            //if CuotaDeducible <> 0 THEN
            TextCuotaDeducible := ChangeCommaForDot(FORMAT(-CuotaDeducible, 0, DevolverFormato(PurchCrMemoHeader."Currency Code")));
            WriteNewINVDOC(Fichero, VATBusPostGrp."Clave registro SII recibidas", PurchCrMemoHeader."Descripción operación",
                          //-SII1
                          //AñoImputacion+MesImputacion+DiaImputacion,TextCuotaDeducible,
                          AñoOperacion + MesOperacion + DiaOperacion, TextCuotaDeducible,
                          //+SII1
                          //ChangeCommaForDot(FORMAT(-PurchCrMemoHeader."Amount Including VAT",0,'<Sign,1><Integer><Decimals,3>')),
                          //ChangeCommaForDot(FORMAT(-PurchCrMemoHeader.Amount,0,'<Sign,1><Integer><Decimals,3>')));
                          ChangeCommaForDot(FORMAT(-decImporteIVAincl, 0, DevolverFormato(PurchCrMemoHeader."Currency Code"))),
                          ChangeCommaForDot(FORMAT(-decImporte, 0, DevolverFormato(PurchCrMemoHeader."Currency Code"))));
            WriteNewIMPDOC(Fichero, TempVATAmountLines, TRUE, TempVatPostStp, FALSE, 'FR', PurchCrMemoHeader."Currency Code");
            //if PurchCrMemoHeader."Corrected Invoice No." <> '' THEN
            WriteNewRECDOC(Fichero, TempVATAmountLines, PurchCrMemoHeader."Tipo factura rectificativa", PurchCrMemoHeader."Currency Code");
            PurchCrMemoHeader."Reportado SII" := TRUE;
            PurchCrMemoHeader."Nombre fichero SII" := RutaFichero;
            PurchCrMemoHeader."Fecha/hora subida fichero SII" := CURRENTDATETIME;
            PurchCrMemoHeader.MODIFY;
            //-jb
            FicheroCLOSE(Fichero);
            //+jb
        END;
        //+001

    end;


    /// <summary>
    /// CreateOrUpdateFileSalesA1.
    /// </summary>
    /// <param name="SalesInvoiceHeader">VAR Record 112.</param>
    /// <param name="SalesCrMemoHeader">VAR Record 114.</param>
    /// <param name="WriteIMPDOC">Boolean.</param>
    /// <summary>
    /// CreateOrUpdateFileSalesA1.
    /// </summary>
    /// <param name="SalesInvoiceHeader">VAR Record 112.</param>
    /// <param name="SalesCrMemoHeader">VAR Record 114.</param>
    /// <param name="WriteIMPDOC">Boolean.</param>
    procedure CreateOrUpdateFileSalesA1(var SalesInvoiceHeader: Record 112; var SalesCrMemoHeader: Record 114; WriteIMPDOC: Boolean)
    var
        Fichero: OutStream;
        RutaFichero: Text[250];
        TipoIDreceptor: Code[3];
        IDreceptor: Code[20];
        Paisreceptor: Code[10];
        CompanyInformation: Record 79;
        "Año": Text;
        Mes: Text;
        Dia: Text;
        NifReceptor: Code[20];
#pragma warning disable AL0432
        TempVATAmountLines: Record "VAT Amount Line" Temporary;
#pragma warning restore AL0432
        TempVatPostStp: Record 325 temporary;
        VatPostStp: Record 325;
        VATBusPostGrp: Record 323;
        IVACaja: Boolean;
        custName: Text[100];
        FechaImputacion: Date;
        AñoImputacion: Text;
        MesImputacion: Text;
        DiaImputacion: Text;
        SalesInvoiceLine: Record 113;
        SalesCrMemoLine: Record 115;
        decImporteIVAincl: Decimal;
        decImporte: Decimal;
        Vendor: Record Vendor;
        Customer: Record Customer;
    begin
        Vendor.Init();
        Customer.Init();
        //-001
        /*if NOT HasVAT THEN
          EXIT;*/
        ExistsFile := FALSE;
        /*if SalesInvoiceHeader."No." <> '' THEN
          IVACaja := CriterioCaja(SalesInvoiceHeader."No.",SalesInvoiceHeader."Posting Date")
        ELSE
          IVACaja := CriterioCaja(SalesCrMemoHeader."No.",SalesCrMemoHeader."Posting Date");
        if IVACaja THEN
          EXIT;*/
        //-jb
        //-SII1
        GetGLSetup;
        if (GLSetup."Exportar SII desde fecha" <> 0D) THEN
            if SalesInvoiceHeader."No." <> '' THEN BEGIN
                if (SalesInvoiceHeader."Posting Date" < GLSetup."Exportar SII desde fecha") THEN
                    EXIT;
            END ELSE
                if SalesCrMemoHeader."No." <> '' THEN BEGIN
                    if (SalesCrMemoHeader."Posting Date" < GLSetup."Exportar SII desde fecha") THEN
                        EXIT;
                END;
        //+SII1
        if (SalesInvoiceHeader."No." <> '') OR (SalesCrMemoHeader."No." <> '') THEN BEGIN
            if SalesInvoiceHeader."No." <> '' Then
                OpenFile(OpenOrCreateFile('FE', FALSE), Fichero, SalesInvoiceHeader."No.", true)
            else
                OpenFile(OpenOrCreateFile('FE', FALSE), Fichero, SalesCrmemoHeader."No.", true);

            GetGLSetup;
            CompanyInformation.GET;
            if Lenght = 0 THEN
                WriteNewFile(Fichero, GLSetup, 'FE', 'A1');
        END;
        //+jb
        if SalesInvoiceHeader."No." <> '' THEN BEGIN
            /*Si se factura una factura de venta...*/
            DevolverAnoMesDia(SalesInvoiceHeader."Document Date", Año, Mes, Dia);
            SetTipoIDRecIDRecPaisRecNIFRec(SalesInvoiceHeader."Bill-to Customer No.", TipoIDreceptor, IDreceptor, Paisreceptor,
                                          NifReceptor, custName,
                                          SalesInvoiceHeader."VAT Registration No.", SalesInvoiceHeader."Bill-to Name",
                                          SalesInvoiceHeader."Bill-to Country/Region Code");
            FechaImputacion := DevolverFechaImp(SalesInvoiceHeader."VAT Bus. Posting Group", SalesInvoiceHeader."Posting Date",
                               SalesInvoiceHeader."Due Date", SalesInvoiceHeader."Document Date", 0, SalesInvoiceHeader."No.");
            DevolverAnoMesDia(FechaImputacion, AñoImputacion, MesImputacion, DiaImputacion);
            if TipoIDreceptor = '07' THEN SalesInvoiceHeader."Tipo factura SII" := 'F2';
            Customer.Get(SalesInvoiceHeader."Bill-to Customer No.");
            WriteNewDoc(Fichero, AñoImputacion, MesImputacion, SalesInvoiceHeader."Tipo factura SII",
                        SalesInvoiceHeader."No.", Año + Mes + Dia, CompanyInformation."VAT Registration No.", CompanyInformation.Name,
                        '', '', '', NifReceptor, custName, TipoIDreceptor, IDreceptor, Paisreceptor, Vendor, Customer);
            SalesInvoiceHeader.CALCFIELDS("Amount Including VAT");
            SalesInvoiceHeader.CALCFIELDS(Amount);
            CLEAR(decImporteIVAincl);
            CLEAR(decImporte);

            SalesInvoiceLine.RESET;
            SalesInvoiceLine.SETRANGE("Document No.", SalesInvoiceHeader."No.");
            if SalesInvoiceLine.FINDFIRST THEN
                REPEAT
                    if (VatPostStp.GET(SalesInvoiceLine."VAT Bus. Posting Group",
                        SalesInvoiceLine."VAT Prod. Posting Group") AND (NOT (VatPostStp."Obviar SII"))) THEN BEGIN
                        decImporteIVAincl += SalesInvoiceLine."Amount Including VAT";
                        decImporte += SalesInvoiceLine.Amount;
                    END;
                    //-SII1
                    if SalesInvoiceLine."Tipo sit. inmueble SII" <> '' THEN BEGIN
                        recTempInmueble.INIT;
                        recTempInmueble."Situación inmueble" := SalesInvoiceLine."Tipo sit. inmueble SII";
                        recTempInmueble."Ref. catastral" := SalesInvoiceLine."Ref. catastral inmueble SII";
                        if recTempInmueble.INSERT THEN;
                    END;
                //+SII1
                UNTIL SalesInvoiceLine.NEXT = 0;
            //-SII1
            if SalesInvoiceHeader."Currency Factor" <> 0 THEN BEGIN
                decImporteIVAincl /= SalesInvoiceHeader."Currency Factor";
                decImporte /= SalesInvoiceHeader."Currency Factor";
            END;
            //+SII1
            VATBusPostGrp.GET(SalesInvoiceHeader."VAT Bus. Posting Group");
            WriteNewINVDOC(Fichero, VATBusPostGrp."Clave registro SII expedidas",
                            SalesInvoiceHeader."Descripción operación", AñoImputacion + MesImputacion + DiaImputacion, '',
                           //ChangeCommaForDot(FORMAT(SalesInvoiceHeader."Amount Including VAT",0,'<Integer><Decimals,3>')),
                           //ChangeCommaForDot(FORMAT(SalesInvoiceHeader.Amount,0,'<Integer><Decimals,3>')));
                           ChangeCommaForDot(FORMAT(decImporteIVAincl, 0, DevolverFormato(SalesInvoiceHeader."Currency Code"))),
                           ChangeCommaForDot(FORMAT(decImporte, 0, DevolverFormato(SalesInvoiceHeader."Currency Code"))));
            CalcVATAmtLines(0, SalesInvoiceHeader."No.", TempVATAmountLines, TempVatPostStp);
            //-SII1
            //aplicamos divisas
            ApplyCurrencyFactor(TempVATAmountLines, SalesInvoiceHeader."Currency Factor");
            decBaseACoste := CalcBaseACoste(TempVATAmountLines);
            TextBaseACoste := ChangeCommaForDot(FORMAT(decBaseACoste, 0, DevolverFormato(SalesInvoiceHeader."Currency Code")));
            if recTempInmueble.FINDFIRST THEN BEGIN
                REPEAT
                    WriteNewIMBDOC(Fichero, recTempInmueble);
                UNTIL recTempInmueble.NEXT = 0;
            END;
            //+SII1
            WriteNewIMPDOC(Fichero, TempVATAmountLines, FALSE, TempVatPostStp, TRUE, 'FE', SalesInvoiceHeader."Currency Code");
            //-SII1
            if WriteIMPDOC THEN
                WriteNewRECDOC(Fichero, TempVATAmountLines, SalesInvoiceHeader."Tipo factura rectificativa", SalesInvoiceHeader."Currency Code");
            //+SII1
            SalesInvoiceHeader."Reportado SII" := TRUE;
            SalesInvoiceHeader."Nombre fichero SII" := RutaFichero;
            SalesInvoiceHeader."Fecha/hora subida fichero SII" := CURRENTDATETIME;
            SalesInvoiceHeader.MODIFY;
            //-jb
            FicheroCLOSE(Fichero);
            //+jb
        END;
        if SalesCrMemoHeader."No." <> '' THEN BEGIN
            /*Si se factura un abono...*/
            DevolverAnoMesDia(SalesCrMemoHeader."Document Date", Año, Mes, Dia);
            SetTipoIDRecIDRecPaisRecNIFRec(SalesCrMemoHeader."Bill-to Customer No.", TipoIDreceptor, IDreceptor, Paisreceptor,
                                          NifReceptor, custName,
                                          SalesCrMemoHeader."VAT Registration No.", SalesCrMemoHeader."Bill-to Name",
                                          SalesCrMemoHeader."Bill-to Country/Region Code");

            FechaImputacion := DevolverFechaImp(SalesCrMemoHeader."VAT Bus. Posting Group",
                                SalesCrMemoHeader."Posting Date", SalesCrMemoHeader."Due Date",
                                  SalesCrMemoHeader."Document Date", 1, SalesCrMemoHeader."No.");
            DevolverAnoMesDia(FechaImputacion, AñoImputacion, MesImputacion, DiaImputacion);
            if TipoIDreceptor = '07' THEN SalesCrMemoHeader."Tipo factura SII" := 'F2';
            Customer.Get(SalesCrMemoHeader."Bill-to Customer No.");
            WriteNewDoc(Fichero, AñoImputacion, MesImputacion, SalesCrMemoHeader."Tipo factura SII",
                        SalesCrMemoHeader."No.", Año + Mes + Dia, CompanyInformation."VAT Registration No.", CompanyInformation.Name,
                        '', '', '', NifReceptor, custName, TipoIDreceptor, IDreceptor, Paisreceptor, Vendor, Customer);
            SalesCrMemoHeader.CALCFIELDS("Amount Including VAT");
            SalesCrMemoHeader.CALCFIELDS(Amount);
            CLEAR(decImporteIVAincl);
            CLEAR(decImporte);

            SalesCrMemoLine.RESET;
            SalesCrMemoLine.SETRANGE("Document No.", SalesCrMemoHeader."No.");
            if SalesCrMemoLine.FINDFIRST THEN
                REPEAT
                    if (VatPostStp.GET(SalesCrMemoLine."VAT Bus. Posting Group",
                        SalesCrMemoLine."VAT Prod. Posting Group") AND (NOT (VatPostStp."Obviar SII"))) THEN BEGIN
                        decImporteIVAincl += SalesCrMemoLine."Amount Including VAT";
                        decImporte += SalesCrMemoLine.Amount;
                    END;
                    if decImporteIVAincl = 0 THEN decImporteIVAincl := -0.1;
                    if decImporte = 0 THEN decImporte := -0.1;
                    if SalesCrMemoLine."Tipo sit. inmueble SII" <> '' THEN BEGIN
                        recTempInmueble.INIT;
                        recTempInmueble."Situación inmueble" := SalesCrMemoLine."Tipo sit. inmueble SII";
                        recTempInmueble."Ref. catastral" := SalesCrMemoLine."Ref. catastral inmueble SII";
                        if recTempInmueble.INSERT THEN;
                    END;
                UNTIL SalesCrMemoLine.NEXT = 0;
            //-SII1
            if SalesCrMemoHeader."Currency Factor" <> 0 THEN BEGIN
                decImporteIVAincl /= SalesCrMemoHeader."Currency Factor";
                decImporte /= SalesCrMemoHeader."Currency Factor";
            END;
            //+SII1
            VATBusPostGrp.GET(SalesCrMemoHeader."VAT Bus. Posting Group");
            WriteNewINVDOC(Fichero, VATBusPostGrp."Clave registro SII expedidas",
                           SalesCrMemoHeader."Descripción operación", AñoImputacion + MesImputacion + DiaImputacion, '',
                           //ChangeCommaForDot(FORMAT(-SalesCrMemoHeader."Amount Including VAT",0,'<Sign,1><Integer><Decimals,3>')),
                           //ChangeCommaForDot(FORMAT(-SalesCrMemoHeader.Amount,0,'<Sign,1><Integer><Decimals,3>')));
                           ChangeCommaForDot(FORMAT(-decImporteIVAincl, 0, DevolverFormato(SalesCrMemoHeader."Currency Code"))),
                           ChangeCommaForDot(FORMAT(-decImporte, 0, DevolverFormato(SalesCrMemoHeader."Currency Code"))));
            CalcVATAmtLines(2, SalesCrMemoHeader."No.", TempVATAmountLines, TempVatPostStp);
            //*llamar
            //-SII1
            //aplicamos divisas
            ApplyCurrencyFactor(TempVATAmountLines, SalesCrMemoHeader."Currency Factor");
            decBaseACoste := CalcBaseACoste(TempVATAmountLines);
            TextBaseACoste := ChangeCommaForDot(FORMAT(decBaseACoste, 0, DevolverFormato(SalesInvoiceHeader."Currency Code")));
            if recTempInmueble.FINDFIRST THEN BEGIN
                REPEAT
                    WriteNewIMBDOC(Fichero, recTempInmueble);
                UNTIL recTempInmueble.NEXT = 0;
            END;
            //+SII1
            WriteNewIMPDOC(Fichero, TempVATAmountLines, TRUE, TempVatPostStp, TRUE, 'FE', SalesCrMemoHeader."Currency Code");
            //if SalesCrMemoHeader."Corrected Invoice No." <> '' THEN
            WriteNewRECDOC(Fichero, TempVATAmountLines, SalesCrMemoHeader."Tipo factura rectificativa", SalesCrMemoHeader."Currency Code");

            SalesCrMemoHeader."Reportado SII" := TRUE;
            SalesCrMemoHeader."Nombre fichero SII" := RutaFichero;
            SalesCrMemoHeader."Fecha/hora subida fichero SII" := CURRENTDATETIME;
            SalesCrMemoHeader.MODIFY;
            //-jb
            FicheroCLOSE(Fichero);
            //+jb
        END;
        //+001

    end;


    /// <summary>
    /// CreateOrUpdateFilePurchA1.
    /// </summary>
    /// <param name="PurchInvHeader">VAR Record 122.</param>
    /// <param name="PurchCrMemoHeader">VAR Record 124.</param>
    /// <param name="WriteIMPDOC">Boolean.</param>
    procedure CreateOrUpdateFilePurchA1(var PurchInvHeader: Record "Purch. Inv. Header"; var PurchCrMemoHeader: Record "Purch. Cr. Memo Hdr."; WriteIMPDOC: Boolean)
    var
        Fichero: OutStream;
        RutaFichero: Text[250];
        TipoIDEmisor: Code[3];
        IDEmisor: Code[20];
        PaisEmisor: Code[10];
        CompanyInformation: Record 79;
        "Año": Text;
        Mes: Text;
        Dia: Text;
        NifReceptor: Code[20];
#pragma warning disable AL0432
        TempVATAmountLines: Record "VAT Amount Line" Temporary;
#pragma warning restore AL0432
        TempVatPostStp: Record 325 temporary;
        VATBusPostGrp: Record 323;
        CuotaDeducible: Decimal;
        TextCuotaDeducible: Text;
        IVACaja: Boolean;
        VendName: Text[100];
        VatNo: Text;
        FechaImputacion: Date;
        "AñoImputacion": Text;
        MesImputacion: Text;
        DiaImputacion: Text;
        decImporteIVAincl: Decimal;
        decImporte: Decimal;
        PurchInvoiceLine: Record 123;
        PurchCrMemoLine: Record 125;
        VatPostStp: Record 325;
        "AñoOperacion": Text;
        MesOperacion: Text;
        DiaOperacion: Text;
        Customer: Record Customer;
        Vendor: Record Vendor;
    begin
        Customer.Init();
        Vendor.Init();
        //-001
        /*if NOT HasVAT THEN
          EXIT;*/
        ExistsFile := FALSE;
        /*if PurchInvHeader."No." <> '' THEN
          IVACaja := CriterioCaja(PurchInvHeader."No.",PurchInvHeader."Posting Date")
        ELSE
          IVACaja := CriterioCaja(PurchCrMemoHeader."No.",PurchCrMemoHeader."Posting Date");
        if IVACaja THEN
          EXIT;*/
        //-SII1
        GetGLSetup;
        if (GLSetup."Exportar SII desde fecha" <> 0D) THEN
            if PurchInvHeader."No." <> '' THEN BEGIN
                if (PurchInvHeader."Posting Date" < GLSetup."Exportar SII desde fecha") THEN
                    EXIT;
            END ELSE
                if PurchCrMemoHeader."No." <> '' THEN BEGIN
                    if (PurchCrMemoHeader."Posting Date" < GLSetup."Exportar SII desde fecha") THEN
                        EXIT;
                END;
        //+SII1
        if (PurchInvHeader."No." <> '') OR (PurchCrMemoHeader."No." <> '') THEN BEGIN
            if PurchInvHeader."No." <> '' Then
                OpenFile(OpenOrCreateFile('FR', FALSE), Fichero, PurchInvHeader."No.", true)
            else
                OpenFile(OpenOrCreateFile('FR', FALSE), Fichero, PurchCrmemoHeader."No.", true);
            GetGLSetup;
            CompanyInformation.GET;
            if Lenght = 0 THEN
                WriteNewFile(Fichero, GLSetup, 'FR', 'A1');
        END;
        if PurchInvHeader."No." <> '' THEN BEGIN
            //-c1
            //-SII1
            //DevolverAnoMesDia(TODAY,Año,Mes,Dia);
            if PurchInvHeader."Descripción operación" = '' Then PurchInvHeader."Descripción operación" := PurchInvHeader."Posting Description";
            if PurchInvHeader."Tipo factura SII" = '' then
                PurchInvHeader."Tipo factura SII" := 'F1';
            DevolverAnoMesDia(PurchInvHeader."Document Date", Año, Mes, Dia);
            DevolverAnoMesDia(TODAY, AñoOperacion, MesOperacion, DiaOperacion);
            //+SII1
            //+c1
            SetTipoIDEMIDEmPaisEMNIFEm(PurchInvHeader."Buy-from Vendor No.", TipoIDEmisor, IDEmisor, PaisEmisor, NifReceptor, VendName);
            FechaImputacion := DevolverFechaImp(PurchInvHeader."VAT Bus. Posting Group", PurchInvHeader."Posting Date",
                                PurchInvHeader."Due Date", PurchInvHeader."Document Date", 10, PurchInvHeader."No.");
            DevolverAnoMesDia(FechaImputacion, AñoImputacion, MesImputacion, DiaImputacion);
            //WriteNewDoc(Fichero,AñoImputacion,MesImputacion,PurchInvHeader."Tipo factura SII",PurchInvHeader."No.",Año+Mes+Dia,
            //PurchInvHeader."VAT Registration No.", VendName,
            //            TipoIDEmisor,IDEmisor,PaisEmisor,CompanyInformation."VAT Registration No.", CompanyInformation.Name, '','','');
            Vendor.get(PurchInvHeader."Pay-to Vendor No.");
            WriteNewDoc(Fichero, AñoImputacion, MesImputacion, PurchInvHeader."Tipo factura SII",
                        //-SII1
                        //PurchInvHeader."No.",Año+Mes+Dia,PurchInvHeader."VAT Registration No.", VendName,
                        PurchInvHeader."Vendor Invoice No.", Año + Mes + Dia, NifReceptor, VendName,
          //TipoIDEmisor,IDEmisor,PaisEmisor,PurchInvHeader."VAT Registration No.", VendName, TipoIDEmisor,IDEmisor,PaisEmisor);
          //TipoIDEmisor,IDEmisor,PaisEmisor,PurchInvHeader."VAT Registration No.", VendName, '',''{CompanyInformation."VAT Registration No."},PaisEmisor);
          TipoIDEmisor, IDEmisor, PaisEmisor, NifReceptor, VendName, TipoIDEmisor, IDEmisor/*CompanyInformation."VAT Registration No."*/, PaisEmisor, Vendor, Customer);

            PurchInvHeader.CALCFIELDS("Amount Including VAT");
            PurchInvHeader.CALCFIELDS(Amount);
            CLEAR(decImporteIVAincl);
            CLEAR(decImporte);

            PurchInvoiceLine.RESET;
            PurchInvoiceLine.SETRANGE("Document No.", PurchInvHeader."No.");
            if PurchInvoiceLine.FINDFIRST THEN
                REPEAT
                    if VatPostStp.GET(PurchInvoiceLine."VAT Bus. Posting Group", PurchInvoiceLine."VAT Prod. Posting Group") THEN BEGIN
                        if (NOT (VatPostStp."Obviar SII")) THEN BEGIN
                            decImporteIVAincl += PurchInvoiceLine."Amount Including VAT";
                            decImporte += PurchInvoiceLine.Amount;
                        END;
                    END;
                UNTIL PurchInvoiceLine.NEXT = 0;
            //-SII1
            if PurchInvHeader."Currency Factor" <> 0 THEN BEGIN
                decImporteIVAincl /= PurchInvHeader."Currency Factor";
                decImporte /= PurchInvHeader."Currency Factor";
            END;
            //+SII1
            CalcVATAmtLines(1, PurchInvHeader."No.", TempVATAmountLines, TempVatPostStp);
            //llamar
            //-SII1
            //aplicamos divisas...
            ApplyCurrencyFactor(TempVATAmountLines, PurchInvHeader."Currency Factor");
            //+SII1
            VATBusPostGrp.GET(PurchInvHeader."VAT Bus. Posting Group");
            CuotaDeducible := CalcCuotaDeducible(TempVATAmountLines);
            //if CuotaDeducible <> 0 THEN
            TextCuotaDeducible := ChangeCommaForDot(FORMAT(CuotaDeducible, 0, DevolverFormato(PurchInvHeader."Currency Code")));
            WriteNewINVDOC(Fichero, VATBusPostGrp."Clave registro SII recibidas", PurchInvHeader."Descripción operación",
                          //-SII1
                          // AñoImputacion+MesImputacion+DiaImputacion,TextCuotaDeducible,
                          AñoOperacion + MesOperacion + DiaOperacion, TextCuotaDeducible,
                          //+SII1
                          //ChangeCommaForDot(FORMAT(PurchInvHeader."Amount Including VAT",0,'<Sign><Integer><Decimals,3>')),
                          //ChangeCommaForDot(FORMAT(PurchInvHeader.Amount,0,'<Sign><Integer><Decimals,3>')));
                          ChangeCommaForDot(FORMAT(decImporteIVAincl, 0, DevolverFormato(PurchInvHeader."Currency Code"))),
                          ChangeCommaForDot(FORMAT(decImporte, 0, DevolverFormato(PurchInvHeader."Currency Code"))));
            WriteNewIMPDOC(Fichero, TempVATAmountLines, FALSE, TempVatPostStp, FALSE, 'FR', PurchInvHeader."Currency Code");
            //-SII1
            if WriteIMPDOC THEN
                WriteNewRECDOC(Fichero, TempVATAmountLines, PurchInvHeader."Tipo factura rectificativa", PurchInvHeader."Currency Code");
            //+SII1
            PurchInvHeader."Reportado SII" := TRUE;
            PurchInvHeader."Nombre fichero SII" := RutaFichero;
            PurchInvHeader."Fecha/hora subida fichero SII" := CURRENTDATETIME;
            PurchInvHeader.MODIFY;
            //-jb
            FicheroCLOSE(Fichero);
            //+jb
        END;
        if PurchCrMemoHeader."No." <> '' THEN BEGIN
            //-c1
            //-SII1
            //DevolverAnoMesDia(TODAY,Año,Mes,Dia);
            if PurchCrMemoHeader."Descripción operación" = '' Then PurchCrMemoHeader."Descripción operación" := PurchCrMemoHeader."Posting Description";
            if PurchCrmemoHeader."Tipo factura SII" = '' then
                PurchCrMemoHeader."Tipo factura SII" := 'F1';
            DevolverAnoMesDia(PurchCrMemoHeader."Document Date", Año, Mes, Dia);
            DevolverAnoMesDia(TODAY, AñoOperacion, MesOperacion, DiaOperacion);
            //+SII1
            //+c1
            SetTipoIDEMIDEmPaisEMNIFEm(PurchCrMemoHeader."Buy-from Vendor No.", TipoIDEmisor, IDEmisor, PaisEmisor, NifReceptor, VendName);
            //calculo de cuota deducible: base factura * IVA.
            FechaImputacion := DevolverFechaImp(PurchCrMemoHeader."VAT Bus. Posting Group", PurchCrMemoHeader."Posting Date",
                               PurchCrMemoHeader."Due Date", PurchCrMemoHeader."Document Date", 10, PurchCrMemoHeader."No.");
            DevolverAnoMesDia(FechaImputacion, AñoImputacion, MesImputacion, DiaImputacion);
            Vendor.Get(PurchCrMemoHeader."Pay-to Vendor No.");
            //WriteNewDoc(Fichero,AñoImputacion,MesImputacion,PurchCrMemoHeader."Tipo factura SII",
            //PurchCrMemoHeader."No.",Año+Mes+Dia,PurchCrMemoHeader."VAT Registration No.", VendName,
            //            TipoIDEmisor,IDEmisor,PaisEmisor,CompanyInformation."VAT Registration No.", CompanyInformation.Name, '','','');
            WriteNewDoc(Fichero, AñoImputacion, MesImputacion, PurchCrMemoHeader."Tipo factura SII",
                        //-SII1
                        //PurchCrMemoHeader."No.",Año+Mes+Dia,PurchCrMemoHeader."VAT Registration No.", VendName,
                        PurchCrMemoHeader."Vendor Cr. Memo No.", Año + Mes + Dia, NifReceptor, VendName,
          //TipoIDEmisor,IDEmisor,PaisEmisor,PurchCrMemoHeader."VAT Registration No.", VendName,TipoIDEmisor, IDEmisor,PaisEmisor);
          //TipoIDEmisor,IDEmisor,PaisEmisor,PurchInvHeader."VAT Registration No.", VendName, '',''{CompanyInformation."VAT Registration No."},PaisEmisor);
          TipoIDEmisor, IDEmisor, PaisEmisor, NifReceptor, VendName, TipoIDEmisor, IDEmisor/*CompanyInformation."VAT Registration No."*/, PaisEmisor, Vendor, Customer);

            //+SII1
            PurchCrMemoHeader.CALCFIELDS("Amount Including VAT");
            PurchCrMemoHeader.CALCFIELDS(Amount);
            CLEAR(decImporteIVAincl);
            CLEAR(decImporte);

            PurchCrMemoLine.RESET;
            PurchCrMemoLine.SETRANGE("Document No.", PurchCrMemoHeader."No.");
            if PurchCrMemoLine.FINDFIRST THEN
                REPEAT
                    if (VatPostStp.GET(PurchCrMemoLine."VAT Bus. Posting Group", PurchCrMemoLine."VAT Prod. Posting Group")
                        AND (NOT (VatPostStp."Obviar SII"))) THEN BEGIN
                        decImporteIVAincl += PurchCrMemoLine."Amount Including VAT";
                        decImporte += PurchCrMemoLine.Amount;
                    END;
                UNTIL PurchCrMemoLine.NEXT = 0;
            //-SII1
            if PurchCrMemoHeader."Currency Factor" <> 0 THEN BEGIN
                decImporteIVAincl *= PurchCrMemoHeader."Currency Factor";
                decImporte *= PurchCrMemoHeader."Currency Factor";
            END;
            //+SII1
            CalcVATAmtLines(3, PurchCrMemoHeader."No.", TempVATAmountLines, TempVatPostStp);
            //llamar
            //-SII1
            ApplyCurrencyFactor(TempVATAmountLines, PurchCrMemoHeader."Currency Factor");
            //+SII1
            VATBusPostGrp.GET(PurchCrMemoHeader."VAT Bus. Posting Group");
            CuotaDeducible := CalcCuotaDeducible(TempVATAmountLines);
            //if CuotaDeducible <> 0 THEN
            TextCuotaDeducible := ChangeCommaForDot(FORMAT(-CuotaDeducible, 0, DevolverFormato(PurchCrMemoHeader."Currency Code")));
            WriteNewINVDOC(Fichero, VATBusPostGrp."Clave registro SII recibidas", PurchCrMemoHeader."Descripción operación",
                          //-SII1
                          //AñoImputacion+MesImputacion+DiaImputacion,TextCuotaDeducible,
                          AñoOperacion + MesOperacion + DiaOperacion, TextCuotaDeducible,
                          //+SII1
                          //ChangeCommaForDot(FORMAT(-PurchCrMemoHeader."Amount Including VAT",0,'<Sign,1><Integer><Decimals,3>')),
                          //ChangeCommaForDot(FORMAT(-PurchCrMemoHeader.Amount,0,'<Sign,1><Integer><Decimals,3>')));
                          ChangeCommaForDot(FORMAT(-decImporteIVAincl, 0, DevolverFormato(PurchCrMemoHeader."Currency Code"))),
                          ChangeCommaForDot(FORMAT(-decImporte, 0, DevolverFormato(PurchCrMemoHeader."Currency Code"))));
            WriteNewIMPDOC(Fichero, TempVATAmountLines, TRUE, TempVatPostStp, FALSE, 'FR', PurchCrMemoHeader."Currency Code");
            //if PurchCrMemoHeader."Corrected Invoice No." <> '' THEN
            WriteNewRECDOC(Fichero, TempVATAmountLines, PurchCrMemoHeader."Tipo factura rectificativa", PurchCrMemoHeader."Currency Code");
            PurchCrMemoHeader."Reportado SII" := TRUE;
            PurchCrMemoHeader."Nombre fichero SII" := RutaFichero;
            PurchCrMemoHeader."Fecha/hora subida fichero SII" := CURRENTDATETIME;
            PurchCrMemoHeader.MODIFY;
            //-jb
            FicheroCLOSE(Fichero);
            //+jb
        END;
        //+001

    end;


    /// <summary>
    /// CreateOrUpdateFileSalesB1.
    /// </summary>
    /// <param name="SalesInvoiceHeader">VAR Record 112.</param>
    /// <param name="SalesCrMemoHeader">VAR Record 114.</param>
    /// <param name="WriteIMPDOC">Boolean.</param>
    procedure CreateOrUpdateFileSalesB1(var SalesInvoiceHeader: Record 112; var SalesCrMemoHeader: Record 114; WriteIMPDOC: Boolean)
    var
        Fichero: OutStream;
        RutaFichero: Text[250];
        TipoIDreceptor: Code[3];
        IDreceptor: Code[20];
        Paisreceptor: Code[10];
        CompanyInformation: Record 79;
        "Año": Text;
        Mes: Text;
        Dia: Text;
        NifReceptor: Code[20];
#pragma warning disable AL0432
        TempVATAmountLines: Record "VAT Amount Line" Temporary;
#pragma warning restore AL0432
        TempVatPostStp: Record 325 temporary;
        VatPostStp: Record 325;
        VATBusPostGrp: Record 323;
        IVACaja: Boolean;
        custName: Text[100];
        FechaImputacion: Date;
        "AñoImputacion": Text;
        MesImputacion: Text;
        DiaImputacion: Text;
        SalesInvoiceLine: Record 113;
        SalesCrMemoLine: Record 115;
        decImporteIVAincl: Decimal;
        decImporte: Decimal;
        Customer: Record Customer;
        Vendor: Record Vendor;
    begin
        //-001
        /*if NOT HasVAT THEN
          EXIT;*/
        ExistsFile := FALSE;
        /*if SalesInvoiceHeader."No." <> '' THEN
          IVACaja := CriterioCaja(SalesInvoiceHeader."No.",SalesInvoiceHeader."Posting Date")
        ELSE
          IVACaja := CriterioCaja(SalesCrMemoHeader."No.",SalesCrMemoHeader."Posting Date");
        if IVACaja THEN
          EXIT;*/
        //-jb
        //-SII1
        Customer.Init;
        Vendor.Init;
        GetGLSetup;
        if (GLSetup."Exportar SII desde fecha" <> 0D) THEN
            if SalesInvoiceHeader."No." <> '' THEN BEGIN
                if (SalesInvoiceHeader."Posting Date" < GLSetup."Exportar SII desde fecha") THEN
                    EXIT;
            END ELSE
                if SalesCrMemoHeader."No." <> '' THEN BEGIN
                    if (SalesCrMemoHeader."Posting Date" < GLSetup."Exportar SII desde fecha") THEN
                        EXIT;
                END;
        //+SII1
        if (SalesInvoiceHeader."No." <> '') OR (SalesCrMemoHeader."No." <> '') THEN BEGIN
            if SalesInvoiceHeader."No." <> '' Then
                OpenFile(OpenOrCreateFile('FE', FALSE), Fichero, SalesInvoiceHeader."No.", true)
            else
                OpenFile(OpenOrCreateFile('FE', FALSE), Fichero, SalesCrmemoHeader."No.", true);

            GetGLSetup;
            CompanyInformation.GET;
            if Lenght = 0 THEN
                WriteNewFile(Fichero, GLSetup, 'FE', 'B1');
        END;
        //+jb
        if SalesInvoiceHeader."No." <> '' THEN BEGIN
            if SalesInvoiceHeader."Descripción operación" = '' Then SalesInvoiceHeader."Descripción operación" := SalesInvoiceHeader."Posting Description";
            if SalesInvoiceHeader."Tipo factura SII" = '' then
                SalesInvoiceHeader."Tipo factura SII" := 'F1';
            /*Si se factura una factura de venta...*/
            DevolverAnoMesDia(SalesInvoiceHeader."Document Date", Año, Mes, Dia);
            SetTipoIDRecIDRecPaisRecNIFRec(SalesInvoiceHeader."Bill-to Customer No.", TipoIDreceptor, IDreceptor, Paisreceptor,
                                          NifReceptor, custName,
                                          SalesInvoiceHeader."VAT Registration No.", SalesInvoiceHeader."Bill-to Name",
                                          SalesInvoiceHeader."Bill-to Country/Region Code");
            FechaImputacion := DevolverFechaImp(SalesInvoiceHeader."VAT Bus. Posting Group", SalesInvoiceHeader."Posting Date",
                               SalesInvoiceHeader."Due Date", SalesInvoiceHeader."Document Date", 0, SalesInvoiceHeader."No.");
            DevolverAnoMesDia(FechaImputacion, AñoImputacion, MesImputacion, DiaImputacion);
            if TipoIDreceptor = '07' THEN SalesInvoiceHeader."Tipo factura SII" := 'F2';
            Customer.GET(SalesInvoiceHeader."Bill-to Customer No.");
            WriteNewDoc(Fichero, AñoImputacion, MesImputacion, SalesInvoiceHeader."Tipo factura SII",
                        SalesInvoiceHeader."No.", Año + Mes + Dia, CompanyInformation."VAT Registration No.", CompanyInformation.Name,
                        '', '', '', NifReceptor, custName, TipoIDreceptor, IDreceptor, Paisreceptor, Vendor, Customer);
            SalesInvoiceHeader.CALCFIELDS("Amount Including VAT");
            SalesInvoiceHeader.CALCFIELDS(Amount);
            CLEAR(decImporteIVAincl);
            CLEAR(decImporte);

            SalesInvoiceLine.RESET;
            SalesInvoiceLine.SETRANGE("Document No.", SalesInvoiceHeader."No.");
            if SalesInvoiceLine.FINDFIRST THEN
                REPEAT
                    if (VatPostStp.GET(SalesInvoiceLine."VAT Bus. Posting Group",
                        SalesInvoiceLine."VAT Prod. Posting Group") AND (NOT (VatPostStp."Obviar SII"))) THEN BEGIN
                        decImporteIVAincl += SalesInvoiceLine."Amount Including VAT";
                        decImporte += SalesInvoiceLine.Amount;
                    END;
                    //-SII1
                    if SalesInvoiceLine."Tipo sit. inmueble SII" <> '' THEN BEGIN
                        recTempInmueble.INIT;
                        recTempInmueble."Situación inmueble" := SalesInvoiceLine."Tipo sit. inmueble SII";
                        recTempInmueble."Ref. catastral" := SalesInvoiceLine."Ref. catastral inmueble SII";
                        if recTempInmueble.INSERT THEN;
                    END;
                //+SII1
                UNTIL SalesInvoiceLine.NEXT = 0;
            //-SII1
            if SalesInvoiceHeader."Currency Factor" <> 0 THEN BEGIN
                decImporteIVAincl /= SalesInvoiceHeader."Currency Factor";
                decImporte /= SalesInvoiceHeader."Currency Factor";
            END;
            //+SII1
            VATBusPostGrp.GET(SalesInvoiceHeader."VAT Bus. Posting Group");
            WriteNewINVDOC(Fichero, VATBusPostGrp."Clave registro SII expedidas",
                            SalesInvoiceHeader."Descripción operación", AñoImputacion + MesImputacion + DiaImputacion, '',
                           //ChangeCommaForDot(FORMAT(SalesInvoiceHeader."Amount Including VAT",0,'<Integer><Decimals,3>')),
                           //ChangeCommaForDot(FORMAT(SalesInvoiceHeader.Amount,0,'<Integer><Decimals,3>')));
                           ChangeCommaForDot(FORMAT(decImporteIVAincl, 0, DevolverFormato(SalesInvoiceHeader."Currency Code"))),
                           ChangeCommaForDot(FORMAT(decImporte, 0, DevolverFormato(SalesInvoiceHeader."Currency Code"))));
            CalcVATAmtLines(0, SalesInvoiceHeader."No.", TempVATAmountLines, TempVatPostStp);
            //-SII1
            //aplicamos divisas
            ApplyCurrencyFactor(TempVATAmountLines, SalesInvoiceHeader."Currency Factor");
            decBaseACoste := CalcBaseACoste(TempVATAmountLines);
            TextBaseACoste := ChangeCommaForDot(FORMAT(decBaseACoste, 0, DevolverFormato(SalesInvoiceHeader."Currency Code")));
            if recTempInmueble.FINDFIRST THEN BEGIN
                REPEAT
                    WriteNewIMBDOC(Fichero, recTempInmueble);
                UNTIL recTempInmueble.NEXT = 0;
            END;
            //+SII1
            WriteNewIMPDOC(Fichero, TempVATAmountLines, FALSE, TempVatPostStp, TRUE, 'FE', SalesInvoiceHeader."Currency Code");
            //-SII1
            if WriteIMPDOC THEN
                WriteNewRECDOC(Fichero, TempVATAmountLines, SalesInvoiceHeader."Tipo factura rectificativa", SalesInvoiceHeader."Currency Code");
            //+SII1
            SalesInvoiceHeader."Reportado SII" := TRUE;
            SalesInvoiceHeader."Nombre fichero SII" := RutaFichero;
            SalesInvoiceHeader."Fecha/hora subida fichero SII" := CURRENTDATETIME;
            SalesInvoiceHeader.MODIFY;
            //-jb
            FicheroCLOSE(Fichero);
            //+jb
        END;
        if SalesCrMemoHeader."No." <> '' THEN BEGIN
            /*Si se factura un abono...*/
            if SalesCrMemoHeader."Descripción operación" = '' Then SalesCrMemoHeader."Descripción operación" := SalesCrMemoHeader."Posting Description";
            if SalesCrMemoHeader."Tipo factura SII" = '' then
                SalesCrMemoHeader."Tipo factura SII" := 'F1';
            DevolverAnoMesDia(SalesCrMemoHeader."Document Date", Año, Mes, Dia);
            SetTipoIDRecIDRecPaisRecNIFRec(SalesCrMemoHeader."Bill-to Customer No.", TipoIDreceptor, IDreceptor, Paisreceptor,
                                          NifReceptor, custName,
                                          SalesCrMemoHeader."VAT Registration No.", SalesCrMemoHeader."Bill-to Name",
                                          SalesCrMemoHeader."Bill-to Country/Region Code");

            FechaImputacion := DevolverFechaImp(SalesCrMemoHeader."VAT Bus. Posting Group",
                                SalesCrMemoHeader."Posting Date", SalesCrMemoHeader."Due Date",
                                  SalesCrMemoHeader."Document Date", 1, SalesCrMemoHeader."No.");
            DevolverAnoMesDia(FechaImputacion, AñoImputacion, MesImputacion, DiaImputacion);
            if TipoIDreceptor = '07' THEN SalesCrMemoHeader."Tipo factura SII" := 'F2';
            Customer.GET(SalesCrMemoHeader."Bill-to Customer No.");
            WriteNewDoc(Fichero, AñoImputacion, MesImputacion, SalesCrMemoHeader."Tipo factura SII",
                        SalesCrMemoHeader."No.", Año + Mes + Dia, CompanyInformation."VAT Registration No.", CompanyInformation.Name,
                        '', '', '', NifReceptor, custName, TipoIDreceptor, IDreceptor, Paisreceptor, Vendor, Customer);
            SalesCrMemoHeader.CALCFIELDS("Amount Including VAT");
            SalesCrMemoHeader.CALCFIELDS(Amount);
            CLEAR(decImporteIVAincl);
            CLEAR(decImporte);

            SalesCrMemoLine.RESET;
            SalesCrMemoLine.SETRANGE("Document No.", SalesCrMemoHeader."No.");
            if SalesCrMemoLine.FINDFIRST THEN
                REPEAT
                    if (VatPostStp.GET(SalesCrMemoLine."VAT Bus. Posting Group",
                        SalesCrMemoLine."VAT Prod. Posting Group") AND (NOT (VatPostStp."Obviar SII"))) THEN BEGIN
                        decImporteIVAincl += SalesCrMemoLine."Amount Including VAT";
                        decImporte += SalesCrMemoLine.Amount;
                    END;
                    if decImporteIVAincl = 0 THEN decImporteIVAincl := -0.1;
                    if decImporte = 0 THEN decImporte := -0.1;
                    if SalesCrMemoLine."Tipo sit. inmueble SII" <> '' THEN BEGIN
                        recTempInmueble.INIT;
                        recTempInmueble."Situación inmueble" := SalesCrMemoLine."Tipo sit. inmueble SII";
                        recTempInmueble."Ref. catastral" := SalesCrMemoLine."Ref. catastral inmueble SII";
                        if recTempInmueble.INSERT THEN;
                    END;
                UNTIL SalesCrMemoLine.NEXT = 0;
            //-SII1
            if SalesCrMemoHeader."Currency Factor" <> 0 THEN BEGIN
                decImporteIVAincl /= SalesCrMemoHeader."Currency Factor";
                decImporte /= SalesCrMemoHeader."Currency Factor";
            END;
            //+SII1
            VATBusPostGrp.GET(SalesCrMemoHeader."VAT Bus. Posting Group");
            WriteNewINVDOC(Fichero, VATBusPostGrp."Clave registro SII expedidas",
                           SalesCrMemoHeader."Descripción operación", AñoImputacion + MesImputacion + DiaImputacion, '',
                           //ChangeCommaForDot(FORMAT(-SalesCrMemoHeader."Amount Including VAT",0,'<Sign,1><Integer><Decimals,3>')),
                           //ChangeCommaForDot(FORMAT(-SalesCrMemoHeader.Amount,0,'<Sign,1><Integer><Decimals,3>')));
                           ChangeCommaForDot(FORMAT(-decImporteIVAincl, 0, DevolverFormato(SalesCrMemoHeader."Currency Code"))),
                           ChangeCommaForDot(FORMAT(-decImporte, 0, DevolverFormato(SalesCrMemoHeader."Currency Code"))));
            CalcVATAmtLines(2, SalesCrMemoHeader."No.", TempVATAmountLines, TempVatPostStp);
            //*llamar
            //-SII1
            //aplicamos divisas
            ApplyCurrencyFactor(TempVATAmountLines, SalesCrMemoHeader."Currency Factor");
            decBaseACoste := CalcBaseACoste(TempVATAmountLines);
            TextBaseACoste := ChangeCommaForDot(FORMAT(decBaseACoste, 0, DevolverFormato(SalesInvoiceHeader."Currency Code")));
            if recTempInmueble.FINDFIRST THEN BEGIN
                REPEAT
                    WriteNewIMBDOC(Fichero, recTempInmueble);
                UNTIL recTempInmueble.NEXT = 0;
            END;
            //+SII1
            WriteNewIMPDOC(Fichero, TempVATAmountLines, TRUE, TempVatPostStp, TRUE, 'FE', SalesCrMemoHeader."Currency Code");
            //if SalesCrMemoHeader."Corrected Invoice No." <> '' THEN
            WriteNewRECDOC(Fichero, TempVATAmountLines, SalesCrMemoHeader."Tipo factura rectificativa", SalesCrMemoHeader."Currency Code");

            SalesCrMemoHeader."Reportado SII" := TRUE;
            SalesCrMemoHeader."Nombre fichero SII" := RutaFichero;
            SalesCrMemoHeader."Fecha/hora subida fichero SII" := CURRENTDATETIME;
            SalesCrMemoHeader.MODIFY;
            //-jb
            FicheroCLOSE(Fichero);
            //+jb
        END;
        //+001

    end;


    /// <summary>
    /// CreateOrUpdateFileSalesB2.
    /// </summary>
    /// <param name="SalesInvoiceHeader">VAR Record 112.</param>
    /// <param name="SalesCrMemoHeader">VAR Record 114.</param>
    /// <param name="WriteIMPDOC">Boolean.</param>
    /// <param name="NewDoc">Code[20].</param>
    procedure CreateOrUpdateFileSalesB2(var SalesInvoiceHeader: Record 112; var SalesCrMemoHeader: Record 114; WriteIMPDOC: Boolean; NewDoc: Code[20])
    var
        Fichero: OutStream;
        RutaFichero: Text[250];
        TipoIDreceptor: Code[3];
        IDreceptor: Code[20];
        Paisreceptor: Code[10];
        CompanyInformation: Record 79;
        "Año": Text;
        Mes: Text;
        Dia: Text;
        NifReceptor: Code[20];
#pragma warning disable AL0432
        TempVATAmountLines: Record "VAT Amount Line" Temporary;
#pragma warning restore AL0432
        TempVatPostStp: Record 325 temporary;
        VatPostStp: Record 325;
        VATBusPostGrp: Record 323;
        IVACaja: Boolean;
        custName: Text[100];
        FechaImputacion: Date;
        "AñoImputacion": Text;
        MesImputacion: Text;
        DiaImputacion: Text;
        SalesInvoiceLine: Record 113;
        SalesCrMemoLine: Record 115;
        decImporteIVAincl: Decimal;
        decImporte: Decimal;
        Customer: Record Customer;
        Vendor: Record Vendor;
    begin
        Customer.Init();
        Vendor.Init();
        //-001
        /*if NOT HasVAT THEN
          EXIT;*/
        ExistsFile := FALSE;
        /*if SalesInvoiceHeader."No." <> '' THEN
          IVACaja := CriterioCaja(SalesInvoiceHeader."No.",SalesInvoiceHeader."Posting Date")
        ELSE
          IVACaja := CriterioCaja(SalesCrMemoHeader."No.",SalesCrMemoHeader."Posting Date");
        if IVACaja THEN
          EXIT;*/
        //-jb
        //-SII1
        GetGLSetup;
        if (GLSetup."Exportar SII desde fecha" <> 0D) THEN
            if SalesInvoiceHeader."No." <> '' THEN BEGIN
                if (SalesInvoiceHeader."Posting Date" < GLSetup."Exportar SII desde fecha") THEN
                    EXIT;
            END ELSE
                if SalesCrMemoHeader."No." <> '' THEN BEGIN
                    if (SalesCrMemoHeader."Posting Date" < GLSetup."Exportar SII desde fecha") THEN
                        EXIT;
                END;
        //+SII1
        if (SalesInvoiceHeader."No." <> '') OR (SalesCrMemoHeader."No." <> '') THEN BEGIN
            if SalesInvoiceHeader."No." <> '' Then
                OpenFile(OpenOrCreateFile('FE', FALSE), Fichero, SalesInvoiceHeader."No.", true)
            else
                OpenFile(OpenOrCreateFile('FE', FALSE), Fichero, SalesCrmemoHeader."No.", true);
            GetGLSetup;
            CompanyInformation.GET;
            if Lenght = 0 THEN
                WriteNewFile(Fichero, GLSetup, 'FE', 'B1');
        END;
        //+jb
        if SalesInvoiceHeader."No." <> '' THEN BEGIN
            if SalesInvoiceHeader."Descripción operación" = '' Then SalesInvoiceHeader."Descripción operación" := SalesInvoiceHeader."Posting Description";
            if SalesInvoiceHeader."Tipo factura SII" = '' then
                SalesInvoiceHeader."Tipo factura SII" := 'F1';
            /*Si se factura una factura de venta...*/
            DevolverAnoMesDia(SalesInvoiceHeader."Document Date", Año, Mes, Dia);
            SetTipoIDRecIDRecPaisRecNIFRec(SalesInvoiceHeader."Bill-to Customer No.", TipoIDreceptor, IDreceptor, Paisreceptor,
                                          NifReceptor, custName,
                                          SalesInvoiceHeader."VAT Registration No.", SalesInvoiceHeader."Bill-to Name",
                                          SalesInvoiceHeader."Bill-to Country/Region Code");
            FechaImputacion := DevolverFechaImp(SalesInvoiceHeader."VAT Bus. Posting Group", SalesInvoiceHeader."Posting Date",
                               SalesInvoiceHeader."Due Date", SalesInvoiceHeader."Document Date", 0, SalesInvoiceHeader."No.");
            DevolverAnoMesDia(FechaImputacion, AñoImputacion, MesImputacion, DiaImputacion);
            Customer.Get(SalesInvoiceHeader."Bill-to Customer No.");
            if TipoIDreceptor = '07' THEN SalesInvoiceHeader."Tipo factura SII" := 'F2';
            WriteNewDoc(Fichero, AñoImputacion, MesImputacion, SalesInvoiceHeader."Tipo factura SII",
                        NewDoc, Año + Mes + Dia, CompanyInformation."VAT Registration No.", CompanyInformation.Name,
                        '', '', '', NifReceptor, custName, TipoIDreceptor, IDreceptor, Paisreceptor, Vendor, Customer);
            SalesInvoiceHeader.CALCFIELDS("Amount Including VAT");
            SalesInvoiceHeader.CALCFIELDS(Amount);
            CLEAR(decImporteIVAincl);
            CLEAR(decImporte);

            SalesInvoiceLine.RESET;
            SalesInvoiceLine.SETRANGE("Document No.", SalesInvoiceHeader."No.");
            if SalesInvoiceLine.FINDFIRST THEN
                REPEAT
                    if (VatPostStp.GET(SalesInvoiceLine."VAT Bus. Posting Group",
                        SalesInvoiceLine."VAT Prod. Posting Group") AND (NOT (VatPostStp."Obviar SII"))) THEN BEGIN
                        decImporteIVAincl += SalesInvoiceLine."Amount Including VAT";
                        decImporte += SalesInvoiceLine.Amount;
                    END;
                    //-SII1
                    if SalesInvoiceLine."Tipo sit. inmueble SII" <> '' THEN BEGIN
                        recTempInmueble.INIT;
                        recTempInmueble."Situación inmueble" := SalesInvoiceLine."Tipo sit. inmueble SII";
                        recTempInmueble."Ref. catastral" := SalesInvoiceLine."Ref. catastral inmueble SII";
                        if recTempInmueble.INSERT THEN;
                    END;
                //+SII1
                UNTIL SalesInvoiceLine.NEXT = 0;
            //-SII1
            if SalesInvoiceHeader."Currency Factor" <> 0 THEN BEGIN
                decImporteIVAincl /= SalesInvoiceHeader."Currency Factor";
                decImporte /= SalesInvoiceHeader."Currency Factor";
            END;
            //+SII1
            VATBusPostGrp.GET(SalesInvoiceHeader."VAT Bus. Posting Group");
            WriteNewINVDOC(Fichero, VATBusPostGrp."Clave registro SII expedidas",
                            SalesInvoiceHeader."Descripción operación", AñoImputacion + MesImputacion + DiaImputacion, '',
                           //ChangeCommaForDot(FORMAT(SalesInvoiceHeader."Amount Including VAT",0,'<Integer><Decimals,3>')),
                           //ChangeCommaForDot(FORMAT(SalesInvoiceHeader.Amount,0,'<Integer><Decimals,3>')));
                           ChangeCommaForDot(FORMAT(decImporteIVAincl, 0, DevolverFormato(SalesInvoiceHeader."Currency Code"))),
                           ChangeCommaForDot(FORMAT(decImporte, 0, DevolverFormato(SalesInvoiceHeader."Currency Code"))));
            CalcVATAmtLines(0, SalesInvoiceHeader."No.", TempVATAmountLines, TempVatPostStp);
            //-SII1
            //aplicamos divisas
            ApplyCurrencyFactor(TempVATAmountLines, SalesInvoiceHeader."Currency Factor");
            decBaseACoste := CalcBaseACoste(TempVATAmountLines);
            TextBaseACoste := ChangeCommaForDot(FORMAT(decBaseACoste, 0, DevolverFormato(SalesInvoiceHeader."Currency Code")));
            if recTempInmueble.FINDFIRST THEN BEGIN
                REPEAT
                    WriteNewIMBDOC(Fichero, recTempInmueble);
                UNTIL recTempInmueble.NEXT = 0;
            END;
            //+SII1
            WriteNewIMPDOC(Fichero, TempVATAmountLines, FALSE, TempVatPostStp, TRUE, 'FE', SalesInvoiceHeader."Currency Code");
            //-SII1
            if WriteIMPDOC THEN
                WriteNewRECDOC(Fichero, TempVATAmountLines, SalesInvoiceHeader."Tipo factura rectificativa", SalesInvoiceHeader."Currency Code");
            //+SII1
            SalesInvoiceHeader."Reportado SII" := TRUE;
            SalesInvoiceHeader."Nombre fichero SII" := RutaFichero;
            SalesInvoiceHeader."Fecha/hora subida fichero SII" := CURRENTDATETIME;
            SalesInvoiceHeader.MODIFY;
            //-jb
            FicheroCLOSE(Fichero);
            //+jb
        END;
        if SalesCrMemoHeader."No." <> '' THEN BEGIN
            if SalesCrMemoHeader."Descripción operación" = '' Then SalesCrMemoHeader."Descripción operación" := SalesCrMemoHeader."Posting Description";
            if SalesCrMemoHeader."Tipo factura SII" = '' then
                SalesCrMemoHeader."Tipo factura SII" := 'F1';
            /*Si se factura un abono...*/
            DevolverAnoMesDia(SalesCrMemoHeader."Document Date", Año, Mes, Dia);
            SetTipoIDRecIDRecPaisRecNIFRec(SalesCrMemoHeader."Bill-to Customer No.", TipoIDreceptor, IDreceptor, Paisreceptor,
                                          NifReceptor, custName,
                                          SalesCrMemoHeader."VAT Registration No.", SalesCrMemoHeader."Bill-to Name",
                                          SalesCrMemoHeader."Bill-to Country/Region Code");

            FechaImputacion := DevolverFechaImp(SalesCrMemoHeader."VAT Bus. Posting Group",
                                SalesCrMemoHeader."Posting Date", SalesCrMemoHeader."Due Date",
                                  SalesCrMemoHeader."Document Date", 1, SalesCrMemoHeader."No.");
            DevolverAnoMesDia(FechaImputacion, AñoImputacion, MesImputacion, DiaImputacion);
            if TipoIDreceptor = '07' THEN SalesCrMemoHeader."Tipo factura SII" := 'F2';
            Customer.Get(SalesCrMemoHeader."Bill-to Customer No.");
            WriteNewDoc(Fichero, AñoImputacion, MesImputacion, SalesCrMemoHeader."Tipo factura SII",
                        NewDoc, Año + Mes + Dia, CompanyInformation."VAT Registration No.", CompanyInformation.Name,
                        '', '', '', NifReceptor, custName, TipoIDreceptor, IDreceptor, Paisreceptor, Vendor, Customer);
            SalesCrMemoHeader.CALCFIELDS("Amount Including VAT");
            SalesCrMemoHeader.CALCFIELDS(Amount);
            CLEAR(decImporteIVAincl);
            CLEAR(decImporte);

            SalesCrMemoLine.RESET;
            SalesCrMemoLine.SETRANGE("Document No.", SalesCrMemoHeader."No.");
            if SalesCrMemoLine.FINDFIRST THEN
                REPEAT
                    if (VatPostStp.GET(SalesCrMemoLine."VAT Bus. Posting Group",
                        SalesCrMemoLine."VAT Prod. Posting Group") AND (NOT (VatPostStp."Obviar SII"))) THEN BEGIN
                        decImporteIVAincl += SalesCrMemoLine."Amount Including VAT";
                        decImporte += SalesCrMemoLine.Amount;
                    END;
                    if decImporteIVAincl = 0 THEN decImporteIVAincl := -0.1;
                    if decImporte = 0 THEN decImporte := -0.1;
                    if SalesCrMemoLine."Tipo sit. inmueble SII" <> '' THEN BEGIN
                        recTempInmueble.INIT;
                        recTempInmueble."Situación inmueble" := SalesCrMemoLine."Tipo sit. inmueble SII";
                        recTempInmueble."Ref. catastral" := SalesCrMemoLine."Ref. catastral inmueble SII";
                        if recTempInmueble.INSERT THEN;
                    END;
                UNTIL SalesCrMemoLine.NEXT = 0;
            //-SII1
            if SalesCrMemoHeader."Currency Factor" <> 0 THEN BEGIN
                decImporteIVAincl /= SalesCrMemoHeader."Currency Factor";
                decImporte /= SalesCrMemoHeader."Currency Factor";
            END;
            //+SII1
            VATBusPostGrp.GET(SalesCrMemoHeader."VAT Bus. Posting Group");
            WriteNewINVDOC(Fichero, VATBusPostGrp."Clave registro SII expedidas",
                           SalesCrMemoHeader."Descripción operación", AñoImputacion + MesImputacion + DiaImputacion, '',
                           //ChangeCommaForDot(FORMAT(-SalesCrMemoHeader."Amount Including VAT",0,'<Sign,1><Integer><Decimals,3>')),
                           //ChangeCommaForDot(FORMAT(-SalesCrMemoHeader.Amount,0,'<Sign,1><Integer><Decimals,3>')));
                           ChangeCommaForDot(FORMAT(-decImporteIVAincl, 0, DevolverFormato(SalesCrMemoHeader."Currency Code"))),
                           ChangeCommaForDot(FORMAT(-decImporte, 0, DevolverFormato(SalesCrMemoHeader."Currency Code"))));
            CalcVATAmtLines(2, SalesCrMemoHeader."No.", TempVATAmountLines, TempVatPostStp);
            //*llamar
            //-SII1
            //aplicamos divisas
            ApplyCurrencyFactor(TempVATAmountLines, SalesCrMemoHeader."Currency Factor");
            decBaseACoste := CalcBaseACoste(TempVATAmountLines);
            TextBaseACoste := ChangeCommaForDot(FORMAT(decBaseACoste, 0, DevolverFormato(SalesInvoiceHeader."Currency Code")));
            if recTempInmueble.FINDFIRST THEN BEGIN
                REPEAT
                    WriteNewIMBDOC(Fichero, recTempInmueble);
                UNTIL recTempInmueble.NEXT = 0;
            END;
            //+SII1
            WriteNewIMPDOC(Fichero, TempVATAmountLines, TRUE, TempVatPostStp, TRUE, 'FE', SalesCrMemoHeader."Currency Code");
            //if SalesCrMemoHeader."Corrected Invoice No." <> '' THEN
            WriteNewRECDOC(Fichero, TempVATAmountLines, SalesCrMemoHeader."Tipo factura rectificativa", SalesCrMemoHeader."Currency Code");

            SalesCrMemoHeader."Reportado SII" := TRUE;
            SalesCrMemoHeader."Nombre fichero SII" := RutaFichero;
            SalesCrMemoHeader."Fecha/hora subida fichero SII" := CURRENTDATETIME;
            SalesCrMemoHeader.MODIFY;
            //-jb
            FicheroCLOSE(Fichero);
            //+jb
        END;
        //+001

    end;

    /// <summary>
    /// FicheroClose.
    /// </summary>
    /// <param name="Fichero">VAR OutStream.</param>
    procedure FicheroClose(var Fichero: OutStream)
    var
        tFicheros: Record Ficheros;
        a: Integer;
    begin
        //TempBLOB.CreateOutStream(outs);
        // if Ficheros.Nueva Then begin
        if tFicheros.FindLast() then a := tFicheros.Secuencia;
        tFicheros := Ficheros;
        tFicheros.Secuencia := a + 1;
        tFicheros.Insert(true);
        //end else begin
        //     tFicheros.SetRange(Factura, Ficheros.Factura);
        //     if Not tFicheros.FindFirst() Then begin
        //         tFicheros.Reset;
        //         if tFicheros.FindLast() then a := tFicheros.Secuencia;
        //         tFicheros := Ficheros;
        //         tFicheros.Secuencia := a + 1;
        //         tFicheros.Insert(true);
        //     end;
        // end;
        // TempBLOB.CreateInStream(ins);
        // DownloadFromStream(
        //     ins,  // InStream to save
        //     '',   // Not used in cloud
        //     '',   // Not used in cloud
        //     '',   // Not used in cloud
        //     RutaFichero);
    end;
}



