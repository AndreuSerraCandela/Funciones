
/// <summary>
/// Codeunit ControlProcesos (ID 50019).
/// </summary>
codeunit 50019 ControlProcesos
{
    Permissions = TableData "G/L Entry" = rimd,
    tabledata "Sales Shipment Header" = rimd,
    tabledata "Sales Shipment Line" = rimd,
    tabledata "Sales Invoice Header" = rimd,
    tabledata "Sales Invoice Line" = rimd,
    tabledata "Sales Cr.Memo Header" = rimd,
    tabledata "Sales Cr.Memo Line" = rimd,
    tabledata "Purch. Rcpt. Header" = rimd,
    tabledata "Purch. Rcpt. Line" = rimd,
    tabledata "Purch. Inv. Header" = rimd,
    tabledata "Purch. Inv. Line" = rimd,
    tabledata "Purch. Cr. Memo Hdr." = rimd,
    tabledata "Purch. Cr. Memo Line" = rimd,
    tabledata "G/L Register" = rimd,
    tabledata "VAT Entry" = rimd,
    tabledata "Bank Account Ledger Entry" = rimd,
    tabledata "Gen. Journal Line" = rimd,
    tabledata "Vendor Ledger Entry" = rimd,
    tabledata "Cust. Ledger Entry" = rimd,
    tabledata "Detailed Cust. Ledg. Entry" = rimd,
    tabledata "Cartera Doc." = rimd,
    tabledata "Posted Cartera Doc." = rimd,
    tabledata "Closed Cartera Doc." = rimd,
    tabledata "Closed Bill Group" = rimd,
    tabledata "Posted Bill Group" = rimd,
    tabledata "Posted Payment Order" = rimd,
    tabledata "Closed Payment Order" = rimd,
    tabledata "Payment Order" = rimd,
    tabledata "Return Shipment Header" = rimd,
    tabledata "Return Shipment Line" = rimd,
    tabledata "Detailed Vendor Ledg. Entry" = rimd;
    TableNo = "G/L Entry";
    trigger OnRun()
    Begin
        Rec.Modify();
    End;

    var
        glSourceDataDoesNotExistErr: Label 'Source data does not exist for %1: %2.', Comment = 'Source data doesn''t exist for G/L Account: 8210.';
        gLSourceDataDoesNotExistInfoErr: Label 'Source data does not exist in %1 for %2: %3.', Comment = 'Source data doesn''t exist in Vendor Ledger Entry for Document No.: PO000123.';
        gLSourceTypeNotSupportedErr: Label 'Source type is not supported.';
        gLDefaultTxt: Label 'Default';
        gDDummyDate: Date;
        //InvPostingBuffer: ARRAY[2] OF Record 49 TEMPORARY;
        gCurrency: Record Currency;
        gSalesLineTMP: Record 37;
        gSalesLineTMPACY: Record 37;

        giRoundingLineNo: Integer;
        gbRoundingLineInserted: Boolean;
        gbLastLineRetrieved: Boolean;

    Procedure FindResourcePriceOld(pCCustPriceGrCode: Code[10]; pdStartingDate: Date; pDIva: Decimal): Decimal
    var

        //TODO Eliminar esta variable en la próxima versión
#pragma warning disable AL0432
        lFromSalesPrice: Record "Sales Price";
#pragma warning restore AL0432

    begin

        WITH lFromSalesPrice DO BEGIN
            if pdStartingDate = 0D THEN pdStartingDate := WORKDATE;
            SETFILTER("Ending Date", '%1|>=%2', 0D, pdStartingDate);
            SETRANGE("Starting Date", 0D, pdStartingDate);
            SETRANGE("Sales Type", "Sales Type"::"Customer Price Group");
            SETRANGE("Sales Code", pCCustPriceGrCode);
            if FINDLAST THEN BEGIN
                if lFromSalesPrice."Price Includes VAT" THEN BEGIN
                    //Esto es un arreglo momentaneo. Debe corregirse
                    "Unit Price" := "Unit Price" / (1 + pDIva / 100);
                END;
                EXIT("Unit Price");
            END
        END;
    end;

    local procedure IsInMinQty(pDMinQty: Decimal; pDQty: Decimal): Boolean
    begin
        exit(pDMinQty <= pDQty);

    end;

    local procedure IsInDur(pDMinDur: Decimal; pDDur: Decimal): Boolean
    begin
        exit(pDMinDur <= pDDur);

    end;

    procedure CalcBestUnitPrice(var SalesPrice: Record "Price List Line"; Cantidad: decimal; TipoDur: enum Duracion; Dur: Decimal; FoundSalesPrice: boolean) BestSalesPrice: Record "Price List Line";
    var

        BestSalesPriceFound: Boolean;

    begin


        with SalesPrice do begin
            FoundSalesPrice := FindSet();
            if FoundSalesPrice then
                repeat

                    if IsInMinQty("Minimum Quantity", Cantidad) then begin
                        If TipoDur = "Tipo Duracion" then begin
                            if IsInDur(Duracion, Dur) Then begin
                                //CalcBestUnitPriceConvertPrice(SalesPrice);

                                case true of
                                    ((BestSalesPrice."Currency Code" = '') and ("Currency Code" <> '')) or
                                    ((BestSalesPrice."Variant Code" = '') and ("Variant Code" <> '')):
                                        begin
                                            BestSalesPrice := SalesPrice;
                                            BestSalesPriceFound := true;
                                        end;
                                    ((BestSalesPrice."Currency Code" = '') or ("Currency Code" <> '')) and
                                  ((BestSalesPrice."Variant Code" = '') or ("Variant Code" <> '')):
                                        if (BestSalesPrice."Unit Price" = 0) or
                                           (BestSalesPrice."Unit Price" > SalesPrice."Unit Price")
                                        then begin
                                            BestSalesPrice := SalesPrice;
                                            BestSalesPriceFound := true;
                                        end;
                                end;
                            end;
                        end;
                    end;
                until Next() = 0;
        end;



        // No price found in agreement
        if not BestSalesPriceFound then begin


            Clear(BestSalesPrice);
            BestSalesPrice."Unit Price" := 0;



        end;

        SalesPrice := BestSalesPrice;
    end;

    // Procedure FindResourcePrice(Agencia: Boolean; ItemDiscGroup: Code[20]; pdStartingDate: Date; pDIva: Decimal; var Proyecto: Record Job; Resno: Code[20];Cantidad: decimal;Duracion: Decimal;TipoDuracion: Enum Duracion): Decimal
    // var
    //     FromSalesPrice: Record "Price List Line";
    //     TempTargetCampaignGr: Record "Campaign Target Group";
    //     Customer: Record Customer;
    //     Recursos: Record Resource;
    //     FoundSalesPrice: Boolean;
    // begin
    //     WITH FromSalesPrice DO BEGIN
    //         if pdStartingDate = 0D THEN pdStartingDate := WORKDATE;
    //         SETFILTER("Ending Date", '%1|>=%2', 0D, pdStartingDate);
    //         SetRange("Minimum Quantity",0,Cantidad);

    //         SetRange("Tipo Duracion",TipoDuracion);
    //         SetRange("Duracion",0,Duracion);
    //         SETRANGE("Starting Date", 0D, pdStartingDate);
    //         SetRange(Agencia, Agencia);
    //         //SETRANGE("Source Type", "Source Type"::"Customer Price Group");
    //         SetRange("Asset Type", "Asset Type"::"Item Discount Group");
    //         SetRange("Asset No.", ItemDiscGroup);
    //         If Not FINDLAST then begin
    //             SetRange(duracion);
    //             SetRange("Tipo Duracion");
    //         end;
    //         CalcBestUnitPrice(FromSalesPrice,Cantidad,TipoDuracion,Duracion,FoundsalesPrice);
    //         if not FoundSalesPrice then exit(0);
    //         //SETRANGE("Source No.", pCCustPriceGrCode);
    //         if not customer.Get(Proyecto."Bill-to Customer No.") then
    //             Customer.Init();
    //         if Proyecto."Ending Date" = 0D THEN Proyecto."Ending Date" := WORKDATE;
    //         if Proyecto."Starting Date" = 0D THEN Proyecto."Starting Date" := WORKDATE;
    //         //Duracion := Proyecto."Ending Date" - Proyecto."Starting Date";
    //         //Duracion := ROUND(Duracion / 30.42, 1);
    //         if not Recursos.Get(Resno) then
    //             Recursos.Init();
    //         // if "Local - Alquiler 7 Meses" = 0 Then "Local - Alquiler 7 Meses" := Recursos."Local - Alquiler 7 Meses";
    //         // if "Nacional - Alquiler 7 Meses" = 0 Then "Nacional - Alquiler 7 Meses" := Recursos."Nacional - Alquiler 7 Meses";
    //         // if "Nacional - Alquiler Anual" = 0 Then "Nacional - Alquiler Anual" := Recursos."Nacional - Alquiler Anual";
    //         // if "Nacional - Alquiler 1 Mes" = 0 then
    //         //     "Nacional - Alquiler 1 Mes" := "Nacional - Alquiler 7 Meses" / 7;
    //         // if "Local - Alquiler 1 Mes" = 0 then
    //         //     "Local - Alquiler 1 Mes" := "Local - Alquiler 7 Meses" / 7;
    //         //if FINDLAST THEN BEGIN
    //             // if Customer."Tipo Cliente" = Customer."Tipo Cliente"::Agencia then begin
    //             //     if Duracion < 7 Then "Unit Price" := "Nacional - Alquiler 1 Mes";//*Duracion;
    //             //     if Duracion = 7 Then "Unit Price" := "Nacional - Alquiler 7 Meses";// *Duracion;
    //             //     if Duracion > 7 Then "Unit Price" := "Nacional - Alquiler Anual";// *Duracion;
    //             // end else begin
    //             //     // lo mismo para local
    //             //     if Duracion < 7 Then "Unit Price" := "Local - Alquiler 1 Mes";//*Duracion;
    //             //     if Duracion = 7 Then "Unit Price" := "Local - Alquiler 7 Meses";// *Duracion;
    //             //     if Duracion > 7 Then "Unit Price" := "Unit Price";// *Duracion;
    //             //end;
    //             if FromSalesPrice."Price Includes VAT" THEN BEGIN
    //                 //Esto es un arreglo momentaneo. Debe corregirse

    //                 "Unit Price" := "Unit Price" / (1 + pDIva / 100);
    //             END;
    //             If "Unit Price" = 0 Then Exit(FindResourcePriceNew(Agencia, ItemDiscGroup, pdStartingDate, pDIva, Proyecto, Resno));
    //             EXIT("Unit Price");
    //         END
    //     END;



    Procedure FindResourcePriceNew(Agencia: Boolean; ItemDiscGroup: Code[20]; pdStartingDate: Date; pDIva: Decimal; var Proyecto: Record Job; Resno: Code[20]; Cantidad: decimal; Duracion: Decimal; TipoDuracion: Enum Duracion): Decimal
    var
        FromSalesPrice: Record "Price List Line";
        TempTargetCampaignGr: Record "Campaign Target Group";
        Customer: Record Customer;
        Recursos: Record Resource;
        FoundsalesPrice: Boolean;
    begin
        WITH FromSalesPrice DO BEGIN
            if pdStartingDate = 0D THEN pdStartingDate := WORKDATE;
            SETFILTER("Ending Date", '%1|>=%2', 0D, pdStartingDate);
            SETRANGE("Starting Date", 0D, pdStartingDate);
            SETRANGE(Agencia, Agencia);
            SetRange("Asset Type", "Asset Type"::"Item Discount Group");
            SetRange("Asset No.", ItemDiscGroup);
            SetRange("Tipo Duracion", TipoDuracion);
            SetRange("Duracion", 0, Duracion);
            SETRANGE("Starting Date", 0D, pdStartingDate);
            SetRange(Agencia, Agencia);
            //SETRANGE("Source Type", "Source Type"::"Customer Price Group");
            SetRange("Asset Type", "Asset Type"::"Item Discount Group");
            SetRange("Asset No.", ItemDiscGroup);
            If Not FINDLAST then begin
                SetRange(duracion);
                SetRange("Tipo Duracion");
            end;
            CalcBestUnitPrice(FromSalesPrice, Cantidad, TipoDuracion, Duracion, FoundsalesPrice);
            if not FoundSalesPrice then exit(0);
            //SETRANGE("Source No.", pCCustPriceGrCode);

            if not customer.Get(Proyecto."Bill-to Customer No.") then
                Customer.Init();
            if Proyecto."Ending Date" = 0D THEN Proyecto."Ending Date" := WORKDATE;
            if Proyecto."Starting Date" = 0D THEN Proyecto."Starting Date" := WORKDATE;
            Duracion := Proyecto."Ending Date" - Proyecto."Starting Date";
            Duracion := ROUND(Duracion / 30.42, 1);
            SetFilter("Minimum Quantity", '<=%1', Duracion);
            if Not FINDLAST then
                SetFilter("Source No.", '<>1%', 'AGENCIA');
            if FINDLAST THEN BEGIN

                if FromSalesPrice."Price Includes VAT" THEN BEGIN
                    //Esto es un arreglo momentaneo. Debe corregirse

                    "Unit Price" := "Unit Price" / (1 + pDIva / 100);
                END;
                EXIT("Unit Price");
            END
        END;
    end;


    Procedure CambiarDocExterno("No.": Text; Fac: Text)
    var
        r38: Record 38;
        r39: Record 39;
        r120: Record "Purch. Rcpt. Header";
        r121: Record "Purch. Rcpt. Line";
        r122: Record "Purch. Inv. Header";
        r123: Record 123;
        r17: Record "G/L Entry";
        r25: Record 25;
        r380: Record 380;
        Vend2: Record Vendor;
        r254: Record 254;
        r70002: Record 7000002;
        r70003: Record 7000003;
        r70004: Record 7000004;
    begin
        r122.GET("No.");
        r122."Vendor Invoice No." := Fac;
        r122.MODIFY;
        r17.SETCURRENTKEY("Document No.");
        r17.SETRANGE(r17."Document No.", "No.");
        //r17.SETRANGE(r17."Document Type",r17."Document Type"::Invoice);
        r17.MODIFYALL("External Document No.", Fac);
        r25.SETCURRENTKEY("Document No.");
        r25.SETRANGE(r25."Document No.", "No.");
        //r25.SETRANGE(r25."Document Type",r25."Document Type"::Invoice);
        r25.MODIFYALL("External Document No.", Fac);
        //r25.MODIFYALL(r25."Buy-from Vendor No.",Vend."No.");
        r380.SETCURRENTKEY("Document No.");
        r380.SETRANGE(r380."Document No.", "No.");
        //r380.SETRANGE(r380."Document Type",r380."Document Type"::Invoice);
        //r380.MODIFYALL("External Document No.",Fac);
        r254.SETCURRENTKEY("Document No.");
        r254.SETRANGE(r254."Document No.", "No.");
        r254.SETRANGE(r254."Document Type", r254."Document Type"::Invoice);
        r254.MODIFYALL("External Document No.", Fac);
    end;




    PROCEDURE Baja(Activo: Code[20]; Recurso: Code[20]);
    VAR
        Acti: Record "Fixed Asset";
        Lib: Record 5612;
        r56002: Record "Fixed Asset";
        Importe: Decimal;
        r81: Record "Gen. Journal Line";
        Linea: Integer;
    BEGIN
        if Activo = '' THEN EXIT;
        r56002.RESET;
        r56002.SETRANGE(r56002."No.", Activo);
        if r56002.FINDFIRST THEN
            REPEAT
                if NOT r56002."Baja 143" THEN BEGIN
                    Lib.SETRANGE(Lib."FA No.", r56002."No.");
                    Lib.FINDFIRST;
                    if Lib."Disposal Date" = 0D THEN BEGIN

                        r56002."Baja 143" := TRUE;
                        r56002.MODIFY;
                        r56002.CALCFIELDS(Coste);
                        Importe := r56002.Coste;
                        r81.SETRANGE(r81."Journal Template Name", 'ACTIVOS');
                        r81.SETRANGE(r81."Journal Batch Name", 'GENERICO');
                        if r81.FINDLAST THEN Linea := r81."Line No.";
                        r81.INIT;
                        r81."Journal Template Name" := 'ACTIVOS';
                        r81."Journal Batch Name" := 'GENERICO';
                        r81."Document No." := Activo;
                        r81."Line No." := Linea + 10000;
                        r81."Account Type" := r81."Account Type"::"G/L Account";
                        r81."Posting Date" := WORKDATE;
                        r81.VALIDATE("Account No.", '771000001');
                        r81."Document No." := r56002."No.";
                        //r81."FA Posting Type":=r81."FA Posting Type"::Disposal;
                        r81.VALIDATE("Credit Amount", Importe);
                        r81."Bal. Account No." := '143000060';
                        r81.INSERT;

                        Importe := 0;
                        r81.SETRANGE(r81."Journal Template Name", 'ACTIVOS');
                        r81.SETRANGE(r81."Journal Batch Name", 'GENERICO');
                        if r81.FINDLAST THEN Linea := r81."Line No.";
                        r81.INIT;
                        r81."Journal Template Name" := 'ACTIVOS';
                        r81."Journal Batch Name" := 'GENERICO';
                        r81."Document No." := Activo;
                        r81."Line No." := Linea + 10000;
                        r81."Account Type" := r81."Account Type"::"Fixed Asset";
                        r81."Posting Date" := WORKDATE;
                        r81.VALIDATE("Account No.", r56002."No.");
                        r81."Document No." := r56002."No.";
                        r81."FA Posting Type" := r81."FA Posting Type"::Disposal;
                        r81.VALIDATE("Debit Amount", Importe);
                        // r81."Bal. Account No.":='143000060';
                        r81.INSERT;
                    END;
                END;
            UNTIL r56002.NEXT = 0;
        //EnviarMailAz(Recurso);
    END;

    /// <summary>
    /// DevuelveNombreDimension.
    /// </summary>
    /// <param name="Id">Integer.</param>
    /// <returns>Return value of type Code[20].</returns>
    procedure DevuelveNombreDimension(Id: Integer): Code[20]
    var
        GLSetup: Record "General Ledger Setup";
    begin
        GLSetup.Get();
        case Id of
            1:
                exit(GLSetup."Global Dimension 1 Code");
            2:
                exit(GLSetup."Global Dimension 2 Code");
            3:
                exit(GLSetup."Shortcut Dimension 3 Code");
            4:
                exit(GLSetup."Shortcut Dimension 4 Code");
            5:
                exit(GLSetup."Shortcut Dimension 5 Code");
            6:
                exit(GLSetup."Shortcut Dimension 6 Code");
            7:
                exit(GLSetup."Shortcut Dimension 7 Code");
            8:
                exit(GLSetup."Shortcut Dimension 8 Code");

        end;
    end;

    PROCEDURE DelResEntries(Num: Code[20])
    VAR
        ResLedgEntry: Record 203;
    BEGIN
        ResLedgEntry.RESET;
        ResLedgEntry.SETCURRENTKEY("Job No.");
        ResLedgEntry.SETRANGE("Job No.", Num);
        ResLedgEntry.DELETEALL;
    END;

    PROCEDURE DelJobEntries(Job: Record 167)
    VAR
        JobLedgEntry: Record 169;
        Text006: Label 'No se puede borrar %1 nº %2';
        PurchOrderLine: Record 39;
        ServLedgEntry: Record 5907;
    BEGIN
        JobLedgEntry.SETCURRENTKEY("Job No.");
        JobLedgEntry.SETRANGE("Job No.", Job."No.");

        JobLedgEntry.LOCKTABLE;
        if JobLedgEntry.FIND('-') THEN
            REPEAT
                if JobLedgEntry."Amt. Posted to G/L" <> 0 THEN
                    ERROR(
                      Text006,
                      Job.TABLECAPTION, Job."No.");
            UNTIL JobLedgEntry.NEXT(1) = 0;

        PurchOrderLine.SETCURRENTKEY("Document Type");
        PurchOrderLine.SETFILTER(
          "Document Type", '%1|%2',
          PurchOrderLine."Document Type"::Order,
          PurchOrderLine."Document Type"::"Return Order");
        PurchOrderLine.SETRANGE("Job No.", Job."No.");
        PurchOrderLine.DELETEALL;

        JobLedgEntry.DELETEALL;

        ServLedgEntry.LOCKTABLE;

        ServLedgEntry.RESET;
        ServLedgEntry.SETRANGE("Job No.", Job."No.");
        ServLedgEntry.DELETEALL;
        DelResEntries(Job."No.");
    END;

    PROCEDURE GenerarContratoCompra(VAR SalesHeader: Record 36)
    VAR
        Gest_dll: Codeunit "Gestion Reservas";
        JobSetup: Record 315;
        rProy: Record 167;
    BEGIN
        JobSetup.GET;
        if JobSetup."Correlación de ingresos-gastos" = FALSE THEN EXIT;
        if SalesHeader."Pedido compra creado" THEN ERROR('Ya se ha creado el pedido de compra');
        SalesHeader."Pedido compra creado" := TRUE;
        SalesHeader.MODIFY;
        rProy.GET(SalesHeader."Nº Proyecto");
        //ASC 01/08/2010 Genero contrato de compra
        SalesHeader.CALCFIELDS("Borradores de Factura", "Borradores de Abono");
        //if ("Borradores de Factura"+"Borradores de Abono")=0 THEN
        //ERROR(Text1100100);
        CLEAR(Gest_dll);
        Gest_dll.Pasa_ContratoCompra(rProy, SalesHeader);
    END;

    PROCEDURE ComprobarPostingNo(pNumero: Code[20]; "Posting No. Series": Code[20]; "Posting Date": Date)
    VAR
        NuevoNum: Code[20];
        TxtFor001: Label 'Nº siguiente factura debe tener %1 caracteres';
        ind: Integer;
        wind2: Integer;
        caracter1: Text[1];
        caracter2: Text[1];
        TxtFor002: Label 'El formato de Nº siguiente factura no es correcto.\Revise el carácter nº %1.';
        any1: Text[2];
        any2: Text[2];
        any2int: Integer;
        TxtFor003: Label 'El año de Nº siguiente factura debe ser %1';
#if CLEAN24
#pragma warning disable AL0432
        NoSeriesMgt: Codeunit NoSeriesManagement;
#pragma warning restore AL0432
#else
        NoSeriesMgt: Codeunit "No. Series";
#endif
    BEGIN
        //$010. Comparo el formato del nº introducido con el formato de nº serie
        NuevoNum := NoSeriesMgt.GetNextNo("Posting No. Series", "Posting Date", FALSE);

        //Compruebo que la longitud sea la misma
        if STRLEN(pNumero) <> STRLEN(NuevoNum) THEN
            ERROR(TxtFor001, STRLEN(NuevoNum));

        //Compruebo que los caracteres sean del mismo tipo
        FOR ind := 1 TO STRLEN(NuevoNum) DO BEGIN
            caracter1 := COPYSTR(NuevoNum, ind, 1);
            caracter2 := COPYSTR(pNumero, ind, 1);
            if (caracter1 >= 'A') AND (caracter1 <= 'Z') THEN BEGIN            //letra
                if (caracter2 < 'A') OR (caracter2 > 'Z') THEN
                    ERROR(TxtFor002, ind);
            END
            ELSE BEGIN
                if (caracter1 >= '0') AND (caracter1 <= '9') THEN BEGIN              //número
                    if (caracter2 < '0') OR (caracter2 > '9') THEN
                        ERROR(TxtFor002, ind);
                END
                ELSE BEGIN                                                  //otro carácter (debe coincidir)
                    wind2 := ind;
                    if caracter1 <> caracter2 THEN
                        ERROR(TxtFor002, ind);
                END;
            END;
        END;

        //Compruebo que los 2 caracteres anteriores al guión coincidan con el año de fecha registro
        if wind2 > 2 THEN BEGIN
            any1 := COPYSTR(pNumero, wind2 - 2, 2);
            any2int := DATE2DMY("Posting Date", 3);
            any2 := COPYSTR(FORMAT(any2int), 3, 2);
            if any1 <> any2 THEN
                ERROR(TxtFor003, any2);
        END;
    END;



    PROCEDURE UpdateCustEmp(VAR Rec: Record 36; VAR Cust: Record Customer; Emp: Text[30])
    BEGIN
        // WITH Rec DO BEGIN
        if Rec."Bill-to Customer No." <> '' THEN BEGIN
            Cust.GET(Rec."Bill-to Customer No.");
            Cust.TESTFIELD("Customer Posting Group");
            Cust.TESTFIELD("Bill-to Customer No.", '');
            //Rec."Sell-to Customer Template Code" := '';
            Rec."Sell-to Customer Name" := Cust.Name;
            Rec."Sell-to Customer Name 2" := Cust."Name 2";
            Rec."Sell-to Address" := Cust.Address;
            Rec."Sell-to Address 2" := Cust."Address 2";
            Rec."Sell-to City" := Cust.City;
            Rec."Sell-to Post Code" := Cust."Post Code";
            Rec."Sell-to County" := Cust.County;
            Rec."Sell-to Country/Region Code" := Cust."Country/Region Code";
            Rec."Sell-to Contact" := Cust.Contact;
            Rec."Gen. Bus. Posting Group" := Cust."Gen. Bus. Posting Group";
            Rec."VAT Bus. Posting Group" := Cust."VAT Bus. Posting Group";
            Rec."Tax Area Code" := Cust."Tax Area Code";
            Rec."Tax Liable" := Cust."Tax Liable";
            Rec."VAT Registration No." := Cust."VAT Registration No.";
            Rec."Shipping Advice" := Cust."Shipping Advice";
            Rec."Sell-to IC Partner Code" := Cust."IC Partner Code";
            Rec."Send IC Document" := (Rec."Sell-to IC Partner Code" <> '') AND (Rec."IC Direction" = Rec."IC Direction"::Outgoing);
            Rec."Cod cadena" := Cust."Cod cadena";            //$013

            Rec."Bill-to Name" := Cust.Name;
            Rec."Bill-to Name 2" := Cust."Name 2";
            Rec."Bill-to Address" := Cust.Address;
            Rec."Bill-to Address 2" := Cust."Address 2";
            Rec."Bill-to City" := Cust.City;
            Rec."Bill-to Post Code" := Cust."Post Code";
            Rec."Bill-to Country/Region Code" := Cust."Country/Region Code";
            Rec."Currency Code" := Cust."Currency Code";
            Rec."Customer Disc. Group" := Cust."Customer Disc. Group";
            Rec."Customer Price Group" := Cust."Customer Price Group";
            Rec."Language Code" := Cust."Language Code";
            Rec."Bill-to County" := Cust.County;
            Rec."Bill-to Country/Region Code" := Cust."Country/Region Code";

            UpdateBillToContEmp(Rec, Rec."Bill-to Customer No.", Cust, Emp);
        END ELSE BEGIN
            Rec."Bill-to Name" := '';
            Rec."Bill-to Name 2" := '';
            Rec."Bill-to Address" := '';
            Rec."Bill-to Address 2" := '';
            Rec."Bill-to City" := '';
            Rec."Bill-to Post Code" := '';
            Rec."Bill-to Country/Region Code" := '';
            Rec."Currency Code" := '';
            Rec."Customer Disc. Group" := '';
            Rec."Customer Price Group" := '';
            Rec."Language Code" := '';
            Rec."Bill-to County" := '';
            Rec."Bill-to Country/Region Code" := '';
            //Rec."Sell-to Customer Template Code" := '';
            Rec."Sell-to Customer Name" := '';
            Rec."Sell-to Customer Name 2" := '';
            Rec."Sell-to Address" := '';
            Rec."Sell-to Address 2" := '';
            Rec."Sell-to City" := '';
            Rec."Sell-to Post Code" := '';
            Rec."Sell-to County" := '';
            Rec."Sell-to Country/Region Code" := '';
            Rec."Sell-to Contact" := '';
        END;
        //  END;
    END;

    PROCEDURE UpdateBillToContEmp(VAR Rec: Record 36; CustomerNo: Code[20]; VAR Cust: Record Customer; Emp: Text[30])
    VAR
        ContBusRel: Record 5054;
    BEGIN
        //  WITH Rec DO BEGIN
        if Cust.GET(CustomerNo) THEN BEGIN
            if Cust."Primary Contact No." <> '' THEN
                Rec."Bill-to Contact No." := Cust."Primary Contact No."
            ELSE BEGIN
                ContBusRel.CHANGECOMPANY(Emp);
                ContBusRel.RESET;
                ContBusRel.SETCURRENTKEY("Link to Table", "No.");
                ContBusRel.SETRANGE("Link to Table", ContBusRel."Link to Table"::Customer);
                ContBusRel.SETRANGE("No.", Rec."Bill-to Customer No.");
                if ContBusRel.FIND('-') THEN
                    Rec."Bill-to Contact No." := ContBusRel."Contact No.";
            END;
            Rec."Bill-to Contact" := Cust.Contact;
        END;
        //  END;
    END;


    /// <summary>
    /// ShowSource.
    /// </summary>
    /// <param name="CFVariant">Variant.</param>
    procedure ShowSource(CFVariant: Variant)
    var
        CFRecordRef: RecordRef;
    begin
        CFRecordRef.GetTable(CFVariant);
        case CFRecordRef.Number of
            DATABASE::"Cash Flow Worksheet Line":
                ShowSourceLocalCFWorkSheetLine(false, CFVariant);
            DATABASE::"Cash Flow Forecast Entry":
                ShowSourceLocalCFEntry(false, CFVariant);
        end;
    end;

    /// <summary>
    /// ShowSourceDocument.
    /// </summary>
    /// <param name="CFVariant">Variant.</param>
    procedure ShowSourceDocument(CFVariant: Variant)
    var
        CFRecordRef: RecordRef;
    begin

        CFRecordRef.GetTable(CFVariant);
        case CFRecordRef.Number of
            DATABASE::"Cash Flow Worksheet Line":
                ShowSourceLocalCFWorkSheetLine(true, CFVariant);
            DATABASE::"Cash Flow Forecast Entry":
                ShowSourceLocalCFEntry(true, CFVariant);
        end;
    end;

    local procedure ShowSourceLocalCFWorkSheetLine(ShowDocument: Boolean; CFVariant: Variant)
    var
        CashFlowWorksheetLine: Record "Cash Flow Worksheet Line";
    begin
        CashFlowWorksheetLine := CFVariant;
        CashFlowWorksheetLine.TestField("Source Type");
        if CashFlowWorksheetLine."Source Type" <> CashFlowWorksheetLine."Source Type"::Tax then
            CashFlowWorksheetLine.TestField("Source No.");
        if CashFlowWorksheetLine."Source Type" = CashFlowWorksheetLine."Source Type"::"G/L Budget" then
            CashFlowWorksheetLine.TestField("G/L Budget Name");

        ShowSourceLocal(ShowDocument,
          CashFlowWorksheetLine."Source Type",
          CashFlowWorksheetLine."Source No.",
          CashFlowWorksheetLine."G/L Budget Name",
          CashFlowWorksheetLine."Document Date",
          CashFlowWorksheetLine."Document No.", CompanyName());
    end;

    local procedure ShowSourceLocalCFEntry(ShowDocument: Boolean; CFVariant: Variant)
    var
        CashFlowForecastEntry: Record "Cash Flow Forecast Entry";
    begin
        CashFlowForecastEntry := CFVariant;
        CashFlowForecastEntry.TestField("Source Type");
        if CashFlowForecastEntry."Source Type" <> CashFlowForecastEntry."Source Type"::Tax then
            CashFlowForecastEntry.TestField("Source No.");
        if CashFlowForecastEntry."Source Type" = CashFlowForecastEntry."Source Type"::"G/L Budget" then
            CashFlowForecastEntry.TestField("G/L Budget Name");

        ShowSourceLocal(ShowDocument,
          CashFlowForecastEntry."Source Type",
          CashFlowForecastEntry."Source No.",
          CashFlowForecastEntry."G/L Budget Name",
          CashFlowForecastEntry."Document Date",
          CashFlowForecastEntry."Document No.", CashFlowForecastEntry.Empresa);
    end;

    /// <summary>
    /// ShowSourceLocal.
    /// </summary>
    /// <param name="ShowDocument">Boolean.</param>
    /// <param name="SourceType">Enum "Cash Flow Source Type".</param>
    /// <param name="SourceNo">Code[20].</param>
    /// <param name="BudgetName">Code[10].</param>
    /// <param name="DocumentDate">Date.</param>
    /// <param name="DocumentNo">Code[20].</param>
    /// <param name="Empresa">Text.</param>
    procedure ShowSourceLocal(ShowDocument: Boolean; SourceType: Enum "Cash Flow Source Type"; SourceNo: Code[20];
                                                                     BudgetName: Code[10];
                                                                     DocumentDate: Date;
                                                                     DocumentNo: Code[20]; Empresa: Text)
    var
        CFWorksheetLine: Record "Cash Flow Worksheet Line";
        IsHandled: Boolean;
    begin
        case SourceType of
            CFWorksheetLine."Source Type"::"Liquid Funds":
                ShowLiquidFunds(SourceNo, ShowDocument, Empresa);
            CFWorksheetLine."Source Type"::Receivables:
                ShowCustomer(DocumentNo, ShowDocument, Empresa);
            CFWorksheetLine."Source Type"::Payables:
                ShowVendor(DocumentNo, ShowDocument, Empresa);
            CFWorksheetLine."Source Type"::"Sales Orders":
                ShowSalesOrder(DocumentNo, Empresa);
            CFWorksheetLine."Source Type"::"Purchase Orders":
                ShowPurchaseOrder(DocumentNo, Empresa);
            CFWorksheetLine."Source Type"::"Service Orders":
                ShowServiceOrder(DocumentNo, Empresa);
            CFWorksheetLine."Source Type"::"Cash Flow Manual Revenue":
                ShowManualRevenue(SourceNo, Empresa);
            CFWorksheetLine."Source Type"::"Cash Flow Manual Expense":
                ShowManualExpense(SourceNo, Empresa);
            CFWorksheetLine."Source Type"::"Fixed Assets Budget",
            CFWorksheetLine."Source Type"::"Fixed Assets Disposal":
                ShowFixedAsset(SourceNo, Empresa);
            CFWorksheetLine."Source Type"::"G/L Budget":
                ShowGLBudget(BudgetName, SourceNo, Empresa);
            CFWorksheetLine."Source Type"::Job:
                ShowJob(SourceNo, DocumentDate, DocumentNo, Empresa);
            CFWorksheetLine."Source Type"::Tax:
                ShowTax(SourceNo, DocumentDate, Empresa);
            CFWorksheetLine."Source Type"::"Azure AI":
                ShowAzureAIForecast;
            else begin
                IsHandled := false;

                if not IsHandled then
                    Error(gLSourceTypeNotSupportedErr);
            end;
        end;
    end;

    local procedure ShowJob(SourceNo: Code[20]; DocumentDate: Date; DocumentNo: Code[20]; Empresa: Text)
    var
        JobPlanningLine: Record "Job Planning Line";
        JobPlanningLines: Page "Job Planning Lines";
    begin
        JobPlanningLine.ChangeCompany(Empresa);
        JobPlanningLine.SetRange("Job No.", SourceNo);
        JobPlanningLine.SetRange("Document Date", DocumentDate);
        JobPlanningLine.SetRange("Document No.", DocumentNo);
        JobPlanningLine.SetFilter("Line Type",
          StrSubstNo('%1|%2',
            JobPlanningLine."Line Type"::Billable,
            JobPlanningLine."Line Type"::"Both Budget and Billable"));
        if not JobPlanningLine.FindFirst then
            Error(glSourceDataDoesNotExistErr, JobPlanningLines.Caption, SourceNo);
        JobPlanningLines.SetTableView(JobPlanningLine);
        JobPlanningLines.Run;
    end;

    local procedure ShowTax(SourceNo: Code[20]; TaxPayableDate: Date; Empresa: Text)
    var
        PurchaseHeader: Record "Purchase Header";
        SalesHeader: Record "Sales Header";
        VATEntry: Record "VAT Entry";
        SalesOrderList: Page "Sales Order List";
        PurchaseOrderList: Page "Purchase Order List";
        SourceNum: Integer;
    begin
        Evaluate(SourceNum, SourceNo);
        case SourceNum of
            DATABASE::"Purchase Header":
                begin
                    SetViewOnPurchaseHeaderForTaxCalc(PurchaseHeader, TaxPayableDate, Empresa);
                    PurchaseOrderList.SkipShowingLinesWithoutVAT;
                    PurchaseOrderList.SetTableView(PurchaseHeader);
                    PurchaseOrderList.Run;
                end;
            DATABASE::"Sales Header":
                begin
                    SetViewOnSalesHeaderForTaxCalc(SalesHeader, TaxPayableDate, Empresa);
                    SalesOrderList.SkipShowingLinesWithoutVAT;
                    SalesOrderList.SetTableView(SalesHeader);
                    SalesOrderList.Run;
                end;
            DATABASE::"VAT Entry":
                begin
                    SetViewOnVATEntryForTaxCalc(VATEntry, TaxPayableDate, Empresa);
                    PAGE.Run(PAGE::"VAT Entries", VATEntry);
                end;
        end;
    end;

    /// <summary>
    /// SetViewOnPurchaseHeaderForTaxCalc.
    /// </summary>
    /// <param name="PurchaseHeader">VAR Record "Purchase Header".</param>
    /// <param name="TaxPaymentDueDate">Date.</param>
    /// <param name="Empresa">Text.</param>
    procedure SetViewOnPurchaseHeaderForTaxCalc(var PurchaseHeader: Record "Purchase Header"; TaxPaymentDueDate: Date; Empresa: Text)
    var
        CashFlowSetup: Record "Cash Flow Setup";
        StartDate: Date;
        EndDate: Date;
    begin
        PurchaseHeader.ChangeCompany(Empresa);
        PurchaseHeader.SetRange("Document Type", PurchaseHeader."Document Type"::Order);
        PurchaseHeader.SetFilter("Document Date", '<>%1', gDDummyDate);
        if TaxPaymentDueDate <> gDDummyDate then begin
            CashFlowSetup.GetTaxPeriodStartEndDates(TaxPaymentDueDate, StartDate, EndDate);
            PurchaseHeader.SetFilter("Document Date", StrSubstNo('%1..%2', StartDate, EndDate));
        end;
        PurchaseHeader.SetCurrentKey("Document Date");
        PurchaseHeader.SetAscending("Document Date", true);
    end;

    /// <summary>
    /// SetViewOnSalesHeaderForTaxCalc.
    /// </summary>
    /// <param name="SalesHeader">VAR Record "Sales Header".</param>
    /// <param name="TaxPaymentDueDate">Date.</param>
    /// <param name="Empresa">Text.</param>
    procedure SetViewOnSalesHeaderForTaxCalc(var SalesHeader: Record "Sales Header"; TaxPaymentDueDate: Date; Empresa: Text)
    var
        CashFlowSetup: Record "Cash Flow Setup";
        StartDate: Date;
        EndDate: Date;
    begin
        SalesHeader.ChangeCompany(Empresa);
        SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::Order);
        SalesHeader.SetFilter("Document Date", '<>%1', gDDummyDate);
        if TaxPaymentDueDate <> gDDummyDate then begin
            CashFlowSetup.GetTaxPeriodStartEndDates(TaxPaymentDueDate, StartDate, EndDate);
            SalesHeader.SetFilter("Document Date", StrSubstNo('%1..%2', StartDate, EndDate));
        end;
        SalesHeader.SetCurrentKey("Document Date");
        SalesHeader.SetAscending("Document Date", true);
    end;

    /// <summary>
    /// SetViewOnVATEntryForTaxCalc.
    /// </summary>
    /// <param name="VATEntry">VAR Record "VAT Entry".</param>
    /// <param name="TaxPaymentDueDate">Date.</param>
    /// <param name="Empresa">Text.</param>
    procedure SetViewOnVATEntryForTaxCalc(var VATEntry: Record "VAT Entry"; TaxPaymentDueDate: Date; Empresa: Text)
    var
        CashFlowSetup: Record "Cash Flow Setup";
        StartDate: Date;
        EndDate: Date;
    begin
        VATEntry.ChangeCompany(Empresa);
        VATEntry.SetFilter(Type, StrSubstNo('%1|%2', VATEntry.Type::Purchase, VATEntry.Type::Sale));
        VATEntry.SetFilter("VAT Calculation Type", StrSubstNo('<>%1', VATEntry."VAT Calculation Type"::"Reverse Charge VAT"));
        VATEntry.SetRange(Closed, false);
        VATEntry.SetFilter(Amount, '<>%1', 0);
        VATEntry.SetFilter("Document Date", '<>%1', gDDummyDate);
        if TaxPaymentDueDate <> gDDummyDate then begin
            CashFlowSetup.GetTaxPeriodStartEndDates(TaxPaymentDueDate, StartDate, EndDate);
            VATEntry.SetFilter("Document Date", StrSubstNo('%1..%2', StartDate, EndDate));
        end;
        VATEntry.SetCurrentKey("Document Date");
        VATEntry.SetAscending("Document Date", true);

        //OnAfterSetViewOnVATEntryForTaxCalc(VATEntry, TaxPaymentDueDate, gDDummyDate);
    end;

    local procedure ShowLiquidFunds(SourceNo: Code[20]; ShowDocument: Boolean; Empresa: Text)
    var
        GLAccount: Record "G/L Account";
    begin
        GLAccount.ChangeCompany(Empresa);
        GLAccount.SetRange("No.", SourceNo);
        if not GLAccount.FindFirst then
            Error(glSourceDataDoesNotExistErr, GLAccount.TableCaption, SourceNo);
        if ShowDocument then
            PAGE.Run(PAGE::"G/L Account Card", GLAccount)
        else
            PAGE.Run(PAGE::"Chart of Accounts", GLAccount);
    end;

    local procedure ShowCustomer(SourceNo: Code[20]; ShowDocument: Boolean; Empresa: Text)
    var
        CustLedgEntry: Record "Cust. Ledger Entry";
    begin
        CustLedgEntry.ChangeCompany(Empresa);
        CustLedgEntry.SetRange("Document No.", SourceNo);
        if not CustLedgEntry.FindFirst then
            Error(gLSourceDataDoesNotExistInfoErr, CustLedgEntry.TableCaption, CustLedgEntry.FieldCaption("Document No."), SourceNo);
        if ShowDocument then
            CustLedgEntry.ShowDoc
        else
            PAGE.Run(0, CustLedgEntry);
    end;

    local procedure ShowVendor(SourceNo: Code[20]; ShowDocument: Boolean; Empresa: Text)
    var
        VendLedgEntry: Record "Vendor Ledger Entry";
    begin
        VendLedgEntry.ChangeCompany(Empresa);
        VendLedgEntry.SetRange("Document No.", SourceNo);
        if not VendLedgEntry.FindFirst then
            Error(gLSourceDataDoesNotExistInfoErr, VendLedgEntry.TableCaption, VendLedgEntry.FieldCaption("Document No."), SourceNo);
        if ShowDocument then
            VendLedgEntry.ShowDoc
        else
            PAGE.Run(0, VendLedgEntry);
    end;

    local procedure ShowSalesOrder(SourceNo: Code[20]; Empresa: Text)
    var
        SalesHeader: Record "Sales Header";
        SalesOrder: Page "Sales Order";
        SourceType: Enum "Cash Flow Source Type";
    begin
        SalesHeader.ChangeCompany(Empresa);
        SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::Order);
        SalesHeader.SetRange("No.", SourceNo);
        if not SalesHeader.FindFirst then
            Error(glSourceDataDoesNotExistErr, SourceType::"Sales Orders", SourceNo);
        SalesOrder.SetTableView(SalesHeader);
        SalesOrder.Run;
    end;

    local procedure ShowPurchaseOrder(SourceNo: Code[20]; Empresa: Text)
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseOrder: Page "Purchase Order";
        SourceType: Enum "Cash Flow Source Type";
    begin
        PurchaseHeader.ChangeCompany(Empresa);
        PurchaseHeader.SetRange("Document Type", PurchaseHeader."Document Type"::Order);
        PurchaseHeader.SetRange("No.", SourceNo);
        if not PurchaseHeader.FindFirst then
            Error(glSourceDataDoesNotExistErr, SourceType::"Purchase Orders", SourceNo);
        PurchaseOrder.SetTableView(PurchaseHeader);
        PurchaseOrder.Run;
    end;

    local procedure ShowServiceOrder(SourceNo: Code[20]; Empresa: Text)
    var
        ServiceHeader: Record "Service Header";
        ServiceOrder: Page "Service Order";
        SourceType: Enum "Cash Flow Source Type";
    begin
        ServiceHeader.ChangeCompany(Empresa);
        ServiceHeader.SetRange("Document Type", ServiceHeader."Document Type"::Order);
        ServiceHeader.SetRange("No.", SourceNo);
        if not ServiceHeader.FindFirst then
            Error(glSourceDataDoesNotExistErr, SourceType::"Service Orders", SourceNo);
        ServiceOrder.SetTableView(ServiceHeader);
        ServiceOrder.Run;
    end;

    local procedure ShowManualRevenue(SourceNo: Code[20]; Empresa: Text)
    var
        CFManualRevenue: Record "Cash Flow Manual Revenue";
        CFManualRevenues: Page "Cash Flow Manual Revenues";
    begin
        CFManualRevenue.ChangeCompany(Empresa);
        CFManualRevenue.SetRange(Code, SourceNo);
        if not CFManualRevenue.FindFirst then
            Error(glSourceDataDoesNotExistErr, CFManualRevenues.Caption, SourceNo);
        CFManualRevenues.SetTableView(CFManualRevenue);
        CFManualRevenues.Run;
    end;

    local procedure ShowManualExpense(SourceNo: Code[20]; Empresa: Text)
    var
        CFManualExpense: Record "Cash Flow Manual Expense";
        CFManualExpenses: Page "Cash Flow Manual Expenses";
    begin
        CFManualExpense.ChangeCompany(Empresa);
        CFManualExpense.SetRange(Code, SourceNo);
        if not CFManualExpense.FindFirst then
            Error(glSourceDataDoesNotExistErr, CFManualExpenses.Caption, SourceNo);
        CFManualExpenses.SetTableView(CFManualExpense);
        CFManualExpenses.Run;
    end;

    local procedure ShowFixedAsset(SourceNo: Code[20]; Empresa: Text)
    var
        FixedAsset: Record "Fixed Asset";
    begin
        FixedAsset.ChangeCompany(Empresa);
        FixedAsset.SetRange("No.", SourceNo);
        if not FixedAsset.FindFirst then
            Error(glSourceDataDoesNotExistInfoErr, FixedAsset.TableCaption, FixedAsset.FieldCaption("No."), SourceNo);
        PAGE.Run(PAGE::"Fixed Asset Card", FixedAsset);
    end;

    local procedure ShowGLBudget(BudgetName: Code[10]; SourceNo: Code[20]; Empresa: Text)
    var
        GLBudgetName: Record "G/L Budget Name";
        GLAccount: Record "G/L Account";
        Budget: Page Budget;
    begin
        GLAccount.ChangeCompany(Empresa);
        if not GLAccount.Get(SourceNo) then
            Error(glSourceDataDoesNotExistErr, GLAccount.TableCaption, SourceNo);
        GLBudgetName.ChangeCompany(Empresa);
        if not GLBudgetName.Get(BudgetName) then
            Error(glSourceDataDoesNotExistErr, GLBudgetName.TableCaption, BudgetName);
        Budget.SetBudgetName(BudgetName);
        Budget.SetGLAccountFilter(SourceNo);
        Budget.Run;
    end;

    local procedure ShowAzureAIForecast()
    begin
    end;

    internal procedure DesmarcarcomoContabilizada(Var Rec: Record "Sales Invoice Header")
    begin
        if Rec.FindFirst() then
            repeat
                Rec."Pte Contabilicación" := TRUE;
                Rec.MODIFY;
            until Rec.Next() = 0;
    end;

    internal procedure DesmarcarAbcomoContabilizada(Var Rec: Record "Sales Cr.Memo Header")
    begin
        if Rec.FindFirst() then
            repeat
                Rec."Pte Contabilicación" := TRUE;
                Rec.MODIFY;
            until Rec.Next() = 0;
    end;

    internal procedure MarcarFacturaComoContabilizada(var Rec: record 112; Marca: Boolean)
    Begin
        Rec."Pte Contabilicación" := Marca;
        Rec.Modify();
    End;

    internal procedure MarcarAbonoComoContabilizada(var Rec: record 114; Marca: Boolean)
    Begin
        Rec."Pte Contabilicación" := Marca;
        Rec.Modify();
    End;





    /// <summary>
    /// Permiso_Empresas.
    /// </summary>
    /// <param name="Empresa">Text.</param>
    /// <returns>Return value of type Boolean.</returns>
    procedure Permiso_Empresas(Empresa: Text): Boolean
    var
        rMem: Record "Access Control";
    begin
        rMem.SETRANGE(rMem."User Name", USERID);
        rMem.SetRange("Company Name", Empresa);
        if rMem.FindFirst() Then exit(True);
        rMem.SetRange("Company Name", '');
        exit(rMem.FindFirst());
    end;

    procedure AccesoProibido_Empresas(Empresa: Text; Permiso: Text): Boolean
    var
        rMem: Record "Access Control";
    begin
        rMem.SETRANGE(rMem."User Name", USERID);
        rMem.SetRange("Company Name", Empresa);
        rMem.SetRange("Role Id", Permiso);
        if rMem.FindFirst() Then exit(True);
        rMem.SetRange("Company Name", '');
        exit(rMem.FindFirst());
    end;


    /// <summary>
    /// GetDefaultDimID2.
    /// </summary>
    /// <param name="GlobalDim1Code">VAR Code[20].</param>
    /// <param name="GlobalDim2Code">VAR Code[20].</param>
    /// <param name="GlobalDim3Code">VAR Code[20].</param>
    /// <param name="GlobalDim4Code">VAR Code[20].</param>
    /// <param name="GlobalDim5Code">VAR Code[20].</param>
    /// <returns>Return value of type Integer.</returns>
    procedure GetDefaultDimID2(GlobalDim1Code: Code[20]; GlobalDim2Code: Code[20]; GlobalDim3Code: Code[20]; GlobalDim4Code: Code[20]; GlobalDim5Code: Code[20]): Integer
    var
        DimVal: Record "Dimension Value";
        TempDimSetEntry: Record "Dimension Set Entry" temporary;
        GlSetup: record "General ledger Setup";
        Control: Codeunit ContabAlb;
    begin
        GlSetup.Get();
        if DimVal.Get(GlSetup."Global Dimension 1 Code", GlobalDim1Code) Then begin
            TempDimSetEntry."Dimension Code" := GlSetup."Global Dimension 1 Code";
            TempDimSetEntry."Dimension Value Code" := GlobalDim1Code;
            TempDimSetEntry."Dimension Value ID" := DimVal."Dimension Value ID";
            TempDimSetEntry.Insert();
        End;
        if DimVal.Get(GlSetup."Global Dimension 2 Code", GlobalDim2Code) Then begin
            TempDimSetEntry."Dimension Code" := GlSetup."Global Dimension 2 Code";
            TempDimSetEntry."Dimension Value Code" := GlobalDim2Code;
            TempDimSetEntry."Dimension Value ID" := DimVal."Dimension Value ID";
            TempDimSetEntry.Insert();
        End;
        if DimVal.Get(GlSetup."Shortcut Dimension 3 Code", GlobalDim3Code) Then begin
            TempDimSetEntry."Dimension Code" := GlSetup."Shortcut Dimension 3 Code";
            TempDimSetEntry."Dimension Value Code" := GlobalDim3Code;
            TempDimSetEntry."Dimension Value ID" := DimVal."Dimension Value ID";
            TempDimSetEntry.Insert();
        End;
        if DimVal.Get(GlSetup."Shortcut Dimension 4 Code", GlobalDim4Code) Then begin
            TempDimSetEntry."Dimension Code" := GlSetup."Shortcut Dimension 4 Code";
            TempDimSetEntry."Dimension Value Code" := GlobalDim4Code;
            TempDimSetEntry."Dimension Value ID" := DimVal."Dimension Value ID";
            TempDimSetEntry.Insert();
        end;
        if DimVal.Get(GlSetup."Shortcut Dimension 5 Code", GlobalDim5Code) Then begin
            TempDimSetEntry."Dimension Code" := GlSetup."Shortcut Dimension 5 Code";
            TempDimSetEntry."Dimension Value Code" := GlobalDim5Code;
            TempDimSetEntry."Dimension Value ID" := DimVal."Dimension Value ID";
            TempDimSetEntry.Insert();
        end;
        exit(Control.GetDimensionSetID(TempDimSetEntry));
    end;

    internal procedure TraspasaDimensiones(var Rec: Record "Purch. Inv. Header")
    var
        r17: Record "G/L Entry";
        r121: Record 123;
        rDim: Record 352;

    BEGIN
        r121.SETRANGE(r121."Document No.", Rec."No.");
        REPEAT
            rDim.SETRANGE(rDim."No.", r121."No.");
            rDim.SETRANGE(rDim."Dimension Code", 'PRINCIPAL');
            rDim.FINDFIRST;
            r121."Shortcut Dimension 3 Code" := rDim."Dimension Value Code";
            rDim.SETRANGE(rDim."Dimension Code", 'SOPORTE');
            rDim.FINDFIRST;
            r121."Shortcut Dimension 5 Code" := rDim."Dimension Value Code";
            rDim.SETRANGE(rDim."Dimension Code", 'ZONA');
            rDim.FINDFIRST;
            r121."Shortcut Dimension 4 Code" := rDim."Dimension Value Code";
            r121."Dimension Set ID" := GetDefaultDimID2(r121."Shortcut Dimension 1 Code", r121."Shortcut Dimension 2 Code",
            r121."Shortcut Dimension 3 Code", r121."Shortcut Dimension 4 Code", r121."Shortcut Dimension 5 Code");
            r121.Modify();
        UNTIL r121.NEXT = 0;
        r17.SETCURRENTKEY(r17."Document No.");
        r17.SETRANGE(r17."Document Type", r17."Document Type"::Invoice);
        r17.SETRANGE(r17."Document No.", Rec."No.");
        r17.SETFILTER(r17."G/L Account No.", '%1', '600*');
        if r17.FINDFIRST THEN
            REPEAT
                r121.SETRANGE(r121."Document No.", Rec."No.");
                r121.SETFILTER(r121.Type, '<>%1', 0);
                r121.FINDFIRST;
                REPEAT
                    r17."Global Dimension 1 Code" := r121."Shortcut Dimension 1 Code";
                    r17."Global Dimension 2 Code" := r121."Shortcut Dimension 2 Code";
                    r17."Shortcut Dimension 3 Code" := r121."Shortcut Dimension 3 Code";
                    r17."Shortcut Dimension 4 Code" := r121."Shortcut Dimension 5 Code";
                    r17."Shortcut Dimension 5 Code" := r121."Shortcut Dimension 5 Code";
                    r17."Dimension Set ID" := r121."Dimension Set ID";
                    r17.Modify();
                until r121.Next() = 0;
            UNTIL r17.NEXT = 0;
    end;

    internal procedure EliminarCartera(Rec: Record "Cartera Doc.")
    var
        r17: Record "G/L Entry";
        r172: Record "G/L Entry";
        r21: Record 21;
        r379: Record 379;
    begin
        // if Rec.Type = Rec.Type::Receivable Then begin
        //     r17.Get(Rec."Entry No.");
        //     r172.SetRange("Transaction No.", r17."Transaction No.");
        //     r172.SetRange("Document No.", r17."Document No.");
        //     if r172.FindSet() Then
        //         repeat
        //             if r172."Document Type" = r172."Document Type"::Invoice Then begin
        //                 if r21.Get(r172."Entry No.") Then begin
        //                     r21.Open := true;
        //                     r21."Closed at Date" := 0D;
        //                     r21."Closed by Amount" := 0;
        //                     r21."Closed by Amount (LCY)" := 0;
        //                     r21."Closed by gCurrency Amount" := 0;
        //                     r21."Closed by Entry No." := 0;
        //                     r21.Modify();
        //                     r379.SetRange("Cust. Ledger Entry No.", r21."Entry No.");
        //                     r379.SetRange("Entry Type", r379."Entry Type"::Application);
        //                     r379.DeleteAll();
        //                 end;
        //             End;
        //             if r172."Document Type" in [r172."Document Type"::" ", r172."Document Type"::Payment, r172."Document Type"::Bill] Then begin
        //                 if r21.Get(r172."Entry No.") Then begin
        //                     r379.SetRange("Cust. Ledger Entry No.", r21."Entry No.");
        //                     r379.SetRange("Entry Type");
        //                     r379.DeleteAll();
        //                     r21.Delete();
        //                     r172."Reason Code" := 'BORRAR';
        //                     r172.Modify();
        //                 end;
        //             end;
        //         until r172.Next() = 0;
        //     r172.SetRange("Reason Code", 'BORRAR');
        //     r172.Deleteall;
        // end;
        Rec.Delete();
    end;



    internal Procedure AsignarPedidoInterEmpresas(Var Rec: Record "Purchase Header")
    VAR
        rVend: Record Vendor;
        rIc: Record 413;
        rContr: Record 36;
        rJob: Record 167;
        r112: Record 112;
    BEGIN
        Rec.Calcfields("Nº Contrato Venta");
        rVend.GET(Rec."Buy-from Vendor No.");
        if rVend."IC Partner Code" <> '' THEN BEGIN
            rIc.GET(rVend."IC Partner Code");
            if rIc."Inbox Type" = rIc."Inbox Type"::Database THEN BEGIN
                rJob.CHANGECOMPANY(rIc."Inbox Details");
                rJob.SETCURRENTKEY(rJob."Proyecto en empresa Origen");
                rJob.SETRANGE(rJob."Proyecto en empresa Origen", Rec."Nº Proyecto");
                rJob.SETRANGE(rJob."Empresa Origen", COMPANYNAME);
                if rJob.FINDFIRST THEN BEGIN
                    rContr.CHANGECOMPANY(rIc."Inbox Details");
                    rContr.SETCURRENTKEY(rContr."Nº Proyecto");
                    rContr.SETRANGE(rContr."Nº Proyecto", rJob."No.");
                    if rContr.FINDFIRST THEN
                        REPEAT
                            rContr."Customer Order No." := Rec."No.";
                            rContr.MODIFY;
                        UNTIL rContr.NEXT = 0;
                    r112.CHANGECOMPANY(rIc."Inbox Details");
                    r112.SETCURRENTKEY("Nº Proyecto");
                    r112.SETRANGE("Nº Proyecto", rJob."No.");
                    if r112.FINDFIRST THEN
                        REPEAT
                            r112."Customer Order No." := Rec."No.";
                            r112.MODIFY;
                        UNTIL r112.NEXT = 0;
                END;
            END;
        END;
    END;

    internal procedure TraerFacturasEmpresa(Var Rec: Record "Purchase Header")
    VAR
        f143: Page 143;
        r112: Record 112;
        rJob: Record 167;
        rVend: Record Vendor;
        rIC: Record 413;
    BEGIN
        Rec.Calcfields("Nº Contrato Venta");
        rVend.GET(Rec."Buy-from Vendor No.");
        if rVend."IC Partner Code" <> '' THEN BEGIN
            rIC.GET(rVend."IC Partner Code");
            if rIC."Inbox Type" = rIC."Inbox Type"::Database THEN BEGIN
                r112.CHANGECOMPANY(rIC."Inbox Details");
                r112.SETCURRENTKEY("Customer Order No.");
                r112.SETRANGE("Customer Order No.", Rec."No.");
                if r112.FINDFIRST THEN
                    CLEAR(f143);
                f143.Empresa(rVend."IC Partner Code", FALSE, TRUE);
                f143.SETTABLEVIEW(r112);
                f143.RUNMODAL;
            END;
        END;
    END;

    internal procedure CambiaProveedor(var Rec: Record "Purchase Header")
    VAR
        Vend: Record Vendor;
        r17: Record "G/L Entry";
        r39: Record 39;
        r120: Record "Purch. Rcpt. Header";
        r121: Record "Purch. Rcpt. Line";
        Vend2: Record Vendor;
        r38: Record 38;
        r25: Record 25;
        r380: Record 380;
        r70002: Record 7000002;
        r70003: Record 7000003;
        r70004: Record 7000004;
    BEGIN
        MESSAGE('Atención: Este proceso no modifica las facturas');
        commit;
        if Page.RUNMODAL(0, Vend) = ACTION::LookupOK THEN BEGIN
            r38.GET(Rec."Document Type", Rec."No.");
            r38."Buy-from Vendor No." := Vend."No.";
            r38."Buy-from Vendor Name" := Vend.Name;
            r38."Buy-from Vendor Name 2" := Vend."Name 2";
            r38."Buy-from Address" := Vend.Address;
            r38."Buy-from Address 2" := Vend."Address 2";
            r38."Buy-from City" := Vend.City;
            r38."Buy-from Post Code" := Vend."Post Code";
            r38."Buy-from County" := Vend.County;
            r38."Buy-from Country/Region Code" := Vend."Country/Region Code";
            r38."Buy-from Contact" := Vend.Contact;
            r38."Gen. Bus. Posting Group" := Vend."Gen. Bus. Posting Group";
            r38."VAT Bus. Posting Group" := Vend."VAT Bus. Posting Group";
            r38."Tax Area Code" := Vend."Tax Area Code";
            r38."Tax Liable" := Vend."Tax Liable";
            r38."VAT Country/Region Code" := Vend."Country/Region Code";
            r38."VAT Registration No." := Vend."VAT Registration No.";
            r38."Buy-from IC Partner Code" := Vend."IC Partner Code";
            r38."Send IC Document" := (Rec."Buy-from IC Partner Code" <> '') AND (Rec."IC Direction" = Rec."IC Direction"::Outgoing);
            if Vend."Pay-to Vendor No." <> '' THEN
                Vend2.GET(Vend."Pay-to Vendor No.")
            ELSE
                Vend2.GET(Vend."No.");
            r38."Pay-to Vendor No." := Vend2."No.";
            r38."Pay-to Name" := Vend2.Name;
            r38."Pay-to Name 2" := Vend2."Name 2";
            r38."Pay-to Address" := Vend2.Address;
            r38."Pay-to Address 2" := Vend2."Address 2";
            r38."Pay-to City" := Vend2.City;
            r38."Pay-to Post Code" := Vend2."Post Code";
            r38."Pay-to County" := Vend2.County;
            r38."Pay-to Country/Region Code" := Vend2."Country/Region Code";
            r38."Payment Terms Code" := Vend2."Payment Terms Code";
            r38."Payment Method Code" := Vend2."Payment Method Code";
            r38."Shipment Method Code" := Vend2."Shipment Method Code";
            r38."Vendor Posting Group" := Vend2."Vendor Posting Group";
            r38."Gen. Bus. Posting Group" := Vend2."Gen. Bus. Posting Group";
            r38."VAT Bus. Posting Group" := Vend2."VAT Bus. Posting Group";
            r38."Currency Code" := Vend2."Currency Code";
            r38."Invoice Disc. Code" := Vend2."Invoice Disc. Code";
            r38."Language Code" := Vend2."Language Code";
            r38."Purchaser Code" := Vend2."Purchaser Code";
            r38."VAT Registration No." := Vend2."VAT Registration No.";
            r38."Vendor Bank Acc. Code" := Vend2."Preferred Bank Account Code";
            r38."Pay-to IC Partner Code" := Vend2."IC Partner Code";
            r38.MODIFY;
            r39.SETRANGE(r39."Document Type", Rec."Document Type");
            r39.SETRANGE(r39."Document No.", Rec."No.");
            r39.MODIFYALL(r39."Buy-from Vendor No.", Vend."No.");
            r39.MODIFYALL(r39."Pay-to Vendor No.", Vend2."No.");
            r121.SETRANGE(r121."Order No.", Rec."No.");
            if r121.FINDFIRST THEN
                REPEAT
                    if r120.GET(r121."Document No.") THEN BEGIN
                        r120."Buy-from Vendor No." := Vend."No.";
                        r120."Buy-from Vendor Name" := Vend.Name;
                        r120."Buy-from Vendor Name 2" := Vend."Name 2";
                        r120."Buy-from Address" := Vend.Address;
                        r120."Buy-from Address 2" := Vend."Address 2";
                        r120."Buy-from City" := Vend.City;
                        r120."Buy-from Post Code" := Vend."Post Code";
                        r120."Buy-from County" := Vend.County;
                        r120."Buy-from Country/Region Code" := Vend."Country/Region Code";
                        r120."Buy-from Contact" := Vend.Contact;
                        r120."Gen. Bus. Posting Group" := Vend."Gen. Bus. Posting Group";
                        r120."VAT Bus. Posting Group" := Vend."VAT Bus. Posting Group";
                        r120."Tax Area Code" := Vend."Tax Area Code";
                        r120."Tax Liable" := Vend."Tax Liable";
                        r120."VAT Country/Region Code" := Vend."Country/Region Code";
                        r120."VAT Registration No." := Vend."VAT Registration No.";
                        r120."Pay-to Vendor No." := Vend2."No.";
                        r120."Pay-to Name" := Vend2.Name;
                        r120."Pay-to Name 2" := Vend2."Name 2";
                        r120."Pay-to Address" := Vend2.Address;
                        r120."Pay-to Address 2" := Vend2."Address 2";
                        r120."Pay-to City" := Vend2.City;
                        r120."Pay-to Post Code" := Vend2."Post Code";
                        r120."Pay-to County" := Vend2.County;
                        r120."Pay-to Country/Region Code" := Vend2."Country/Region Code";
                        r120."Payment Terms Code" := Vend2."Payment Terms Code";
                        r120."Payment Method Code" := Vend2."Payment Method Code";
                        r120."Shipment Method Code" := Vend2."Shipment Method Code";
                        r120."Vendor Posting Group" := Vend2."Vendor Posting Group";
                        r120."Gen. Bus. Posting Group" := Vend2."Gen. Bus. Posting Group";
                        r120."VAT Bus. Posting Group" := Vend2."VAT Bus. Posting Group";
                        r120."Currency Code" := Vend2."Currency Code";
                        r120."Invoice Disc. Code" := Vend2."Invoice Disc. Code";
                        r120."Language Code" := Vend2."Language Code";
                        r120."Purchaser Code" := Vend2."Purchaser Code";
                        r120."VAT Registration No." := Vend2."VAT Registration No.";
                        r120."Vendor Bank Acc. Code" := Vend2."Preferred Bank Account Code";
                        r120.MODIFY;
                        r17.SETCURRENTKEY("Document No.");
                        r17.SETCURRENTKEY("Document No.");
                        r17.SETRANGE(r17."Document No.", r120."No.");
                        r17.MODIFYALL(r17."Source No.", Vend2."No.");
                        r25.SETCURRENTKEY("Document No.");
                        r25.SETRANGE(r25."Document No.", r120."No.");
                        r25.MODIFYALL(r25."Vendor No.", Vend2."No.");
                        r25.MODIFYALL(r25."Buy-from Vendor No.", Vend."No.");
                        r380.SETCURRENTKEY("Document No.");
                        r380.SETRANGE(r380."Document No.", r120."No.");
                        r380.MODIFYALL(r380."Vendor No.", Vend2."No.");
                        r70002.SETCURRENTKEY(Type, "Document No.");
                        r70002.SETRANGE(r70002."Document No.", r120."No.");
                        r70002.MODIFYALL(r70002."Account No.", Vend2."No.");
                        r70003.SETCURRENTKEY(Type, "Document No.");
                        r70003.SETRANGE(r70003."Document No.", r120."No.");
                        r70003.MODIFYALL(r70003."Account No.", Vend2."No.");
                        r70004.SETCURRENTKEY(Type, "Document No.");
                        r70004.SETRANGE(r70004."Document No.", r120."No.");
                        r70004.MODIFYALL(r70004."Account No.", Vend2."No.");
                    END;
                UNTIL r121.NEXT = 0;
            r121.MODIFYALL(r121."Buy-from Vendor No.", Vend."No.");
            r121.MODIFYALL(r121."Pay-to Vendor No.", Vend2."No.");
        END;
    END;

    internal procedure RecrearProyecto(var Rec: Record "Purchase Header")
    VAR
        cGll: Codeunit "Gestion Proyecto";
        r39: Record 39;
        Numero: Code[20];
        rRes: Record 156;
        rResOrg: Record 156;
        r121t: Record 121 TEMPORARY;
        r36: Record 36;
        rEmp: Record "Company Information";
        Vendor: Record Vendor;
        rSo: Record 413;
        rCli: Record Customer;
        rLin: Record "Purch. Rcpt. Line";
    BEGIN
        r39.SETRANGE(r39."Document Type", Rec."Document Type");
        r39.SETRANGE(r39."Document No.", Rec."No.");
        rLin.SETRANGE("Order No.", Rec."No.");
        rLin.SETRANGE(Type, rLin.Type::Resource);
        if rLin.FINDFIRST THEN BEGIN
            if rRes.GET(rLin."No.") THEN BEGIN
                if (rRes."Empresa Origen" <> COMPANYNAME)
                AND (rRes."Nº En Empresa origen" <> '') THEN BEGIN
                    rEmp.ChangeCompany(rRes."Empresa Origen");
                    rEmp.Get();
                    rResOrg.CHANGECOMPANY(rRes."Empresa Origen");
                    rResOrg.GET(rRes."Nº En Empresa origen");
                    r121t := rLin;
                    r121t."Periodo de Pago" := rEmp.Name;
                    r121t."Job No." := rEmp."Clave Recursos";
                    if r121t.INSERT THEN;
                    r36.CHANGECOMPANY(rRes."Empresa Origen");
                    r36.SETRANGE(r36."Albarán Empresa Origen", Rec."No.");
                    r36.FINDFIRST;
                    Vendor.GET(Rec."Buy-from Vendor No.");
                    rSo.RESET;
                    rSo.SETRANGE("Inbox Details", COMPANYNAME);
                    rSo.FINDFIRST;
                    rCli.CHANGECOMPANY(r121t."Periodo de Pago");
                    rCli.SETRANGE(rCli."IC Partner Code", rSo.Code);
                    rCli.FINDFIRST;
                END;
            END;
            Numero := Rec."No.";
            cGll.ReCrearProyecto(r121t."Periodo de Pago", Numero, r39, rCli."No.", Rec
            , Rec."Posting Date", Rec."Posting Date", rSo.Code, r36."Nº Proyecto");
        END;
    END;


    PROCEDURE SumSalesLinesTempTarea(VAR NewSalesHeader: Record 36;
    VAR OldSalesLine: Record 37; QtyType: Option General,Invoicing,Shipping;
    VAR NewTotalSalesLine: Record 37; VAR NewTotalSalesLineLCY: Record 37; pFiltroTarea: Text[250];
    VAR TotalSalesLine: Record 37; var TotalSalesLineLCY: Record 37);
    VAR
        SalesLine: Record 37;
        SalesHeader: Record 36;
    BEGIN
        // JML 150704
        // $001

        SalesHeader := NewSalesHeader;
        SumSalesLinesTarea(SalesLine, OldSalesLine, QtyType, FALSE, pFiltroTarea, SalesHeader, TotalSalesLine, TotalSalesLineLCY);
        NewTotalSalesLine := TotalSalesLine;
        NewTotalSalesLineLCY := TotalSalesLineLCY;

    END;

    /// <summary>
    /// SumSalesLinesTarea.
    /// </summary>
    /// <param name="VAR NewSalesLine">Record 37.</param>
    /// <param name="VAR OldSalesLine">Record 37.</param>
    /// <param name="QtyType">Option General,Invoicing,Shipping.</param>
    /// <param name="InsertSalesLine">Boolean.</param>
    /// <param name="pFiltroTarea">Text[250].</param>
    /// <param name="Var SalesHeader">Record 36.</param>
    /// <param name="VAR TotalSalesLine">Record 37.</param>
    /// <param name="TotalSalesLineLCY">VAR Record 37.</param>
    procedure SumSalesLinesTarea(VAR NewSalesLine: Record 37; VAR OldSalesLine: Record 37;
    QtyType: Option General,Invoicing,Shipping; InsertSalesLine: Boolean; pFiltroTarea: Text[250]; Var SalesHeader: Record 36;
    VAR TotalSalesLine: Record 37; var TotalSalesLineLCY: Record 37);
    VAR
        SalesLineQty: Decimal;
        TempVATAmountLine: Record 290 TEMPORARY;
        TempVATAmountLineRemainder: Record 290 TEMPORARY;
        SalesLine: Record 37;
        SalesSetup: Record 311;
        gCurrency: Record "Currency";
        BiggestLineNo: Integer;
    BEGIN
        // JML 150704
        // $001

        TempVATAmountLineRemainder.DELETEALL;
        OldSalesLine.CalcVATAmountLines(QtyType, SalesHeader, OldSalesLine, TempVATAmountLine);
        SalesSetup.GET;
        if SalesHeader."Currency Code" = '' THEN
            gCurrency.InitRoundingPrecision
        ELSE BEGIN
            gCurrency.GET(SalesHeader."Currency Code");
            gCurrency.TESTFIELD("Amount Rounding Precision");
        END;
        OldSalesLine.SETRANGE("Document Type", SalesHeader."Document Type");
        OldSalesLine.SETRANGE("Document No.", SalesHeader."No.");
        if pFiltroTarea <> '' THEN
            OldSalesLine.SETFILTER("Job Task No.", pFiltroTarea);
        gbRoundingLineInserted := FALSE;
        if OldSalesLine.FIND('-') THEN
            REPEAT
                if NOT gbRoundingLineInserted THEN
                    SalesLine := OldSalesLine;
                CASE QtyType OF
                    QtyType::General:
                        SalesLineQty := SalesLine.Quantity;
                    QtyType::Invoicing:
                        SalesLineQty := SalesLine."Qty. to Invoice";
                    QtyType::Shipping:
                        BEGIN
                            if SalesHeader."Document Type" IN [SalesHeader."Document Type"::"Return Order", SalesHeader."Document Type"::"Credit Memo"] THEN
                                SalesLineQty := SalesLine."Return Qty. to Receive"
                            ELSE
                                SalesLineQty := SalesLine."Qty. to Ship";
                        END;
                END;
                DivideAmount(SalesHeader, SalesLine, QtyType, SalesLineQty, TempVATAmountLine, TempVATAmountLineRemainder);
                SalesLine.Quantity := SalesLineQty;
                if SalesLineQty <> 0 THEN BEGIN
                    if (SalesLine.Amount <> 0) AND NOT gbRoundingLineInserted THEN
                        if TotalSalesLine.Amount = 0 THEN BEGIN
                            TotalSalesLine."VAT %" := SalesLine."VAT %";
                            TotalSalesLine."EC %" := SalesLine."EC %";
                        END
                        ELSE
                            if TotalSalesLine."VAT %" <> SalesLine."VAT %" THEN
                                TotalSalesLine."VAT %" := 0;
                    RoundAmount(SalesHeader, SalesLine, SalesLineQty, TotalSalesLine, TotalSalesLineLCY);
                    SalesLine := gSalesLineTMP;
                END;
                if InsertSalesLine THEN BEGIN
                    NewSalesLine := SalesLine;
                    NewSalesLine.INSERT;
                END;
                if gbRoundingLineInserted THEN
                    gbLastLineRetrieved := TRUE
                ELSE BEGIN
                    BiggestLineNo := MAX(BiggestLineNo, OldSalesLine."Line No.");
                    gbLastLineRetrieved := OldSalesLine.NEXT = 0;
                    if gbLastLineRetrieved AND SalesSetup."Invoice Rounding" THEN
                        InvoiceRounding(SalesHeader, SalesLine, FALSE, BiggestLineNo, TotalSalesLine);
                END;
            UNTIL gbLastLineRetrieved;

    END;

    /// <summary>
    /// DivideAmount.
    /// </summary>
    /// <param name="SalesHeader">Record "Sales Header".</param>
    /// <param name="VAR SalesLine">Record "Sales Line".</param>
    /// <param name="QtyType">Option General,Invoicing,Shipping.</param>
    /// <param name="SalesLineQty">Decimal.</param>
    /// <param name="VAR TempVATAmountLine">Record "VAT Amount Line" TEMPORARY.</param>
    /// <param name="VAR TempVATAmountLineRemainder">Temporary Record "VAT Amount Line".</param>
    procedure DivideAmount(SalesHeader: Record "Sales Header"; VAR SalesLine: Record "Sales Line";
QtyType: Option General,Invoicing,Shipping; SalesLineQty: Decimal; VAR TempVATAmountLine: Record "VAT Amount Line" TEMPORARY;
VAR TempVATAmountLineRemainder: Record "VAT Amount Line" temporary);
    var
        OriginalDeferralAmount: Decimal;
    Begin
        if gbRoundingLineInserted AND (giRoundingLineNo = SalesLine."Line No.") THEN
            EXIT;


        WITH SalesLine DO
            if (SalesLineQty = 0) OR ("Unit Price" = 0) THEN BEGIN
                "Line Amount" := 0;
                "Line Discount Amount" := 0;
                "Pmt. Discount Amount" := 0;
                "Inv. Discount Amount" := 0;
                "VAT Base Amount" := 0;
                Amount := 0;
                "Amount Including VAT" := 0;
            END ELSE BEGIN
                OriginalDeferralAmount := GetDeferralAmount;
                TempVATAmountLine.GET("VAT Identifier", "VAT Calculation Type", "Tax Group Code", FALSE, "Line Amount" >= 0);
                if "VAT Calculation Type" = "VAT Calculation Type"::"Sales Tax" THEN BEGIN
                    "VAT %" := TempVATAmountLine."VAT %";
                    "EC %" := TempVATAmountLine."EC %";
                END;
                TempVATAmountLineRemainder := TempVATAmountLine;
                if NOT TempVATAmountLineRemainder.FIND THEN BEGIN
                    TempVATAmountLineRemainder.INIT;
                    TempVATAmountLineRemainder.INSERT;
                END;
                "Line Amount" := GetLineAmountToHandle(SalesLineQty);//+ GetPrepmtDiffToLineAmount(SalesLine);
                if SalesLineQty <> Quantity THEN BEGIN
                    "Line Discount Amount" :=
                        ROUND("Line Discount Amount" * SalesLineQty / Quantity, gCurrency."Amount Rounding Precision");
                    "Pmt. Discount Amount" :=
                        ROUND("Pmt. Discount Amount" * SalesLineQty / Quantity, gCurrency."Amount Rounding Precision");
                END;

                if "Allow Invoice Disc." AND (TempVATAmountLine."Inv. Disc. Base Amount" <> 0) THEN
                    if QtyType = QtyType::Invoicing THEN
                        "Inv. Discount Amount" := "Inv. Disc. Amount to Invoice"
                    ELSE BEGIN
                        TempVATAmountLineRemainder."Invoice Discount Amount" :=
                        TempVATAmountLineRemainder."Invoice Discount Amount" +
                        TempVATAmountLine."Invoice Discount Amount" * "Line Amount" /
                        TempVATAmountLine."Inv. Disc. Base Amount";
                        "Inv. Discount Amount" :=
                        ROUND(
                            TempVATAmountLineRemainder."Invoice Discount Amount", gCurrency."Amount Rounding Precision");
                        TempVATAmountLineRemainder."Invoice Discount Amount" :=
                        TempVATAmountLineRemainder."Invoice Discount Amount" - "Inv. Discount Amount";
                    END;

                if SalesHeader."Prices Including VAT" THEN BEGIN
                    if (TempVATAmountLine.CalcLineAmount = 0) OR ("Line Amount" = 0) THEN BEGIN
                        TempVATAmountLineRemainder."VAT Amount" := 0;
                        TempVATAmountLineRemainder."EC Amount" := 0;
                        TempVATAmountLineRemainder."Amount Including VAT" := 0;
                    END ELSE BEGIN
                        TempVATAmountLineRemainder."VAT Amount" +=
                        TempVATAmountLine."VAT Amount" *
                        (CalcLineAmount - "Pmt. Discount Amount") /
                        (TempVATAmountLine.CalcLineAmount - TempVATAmountLine."Pmt. Discount Amount");
                        TempVATAmountLineRemainder."EC Amount" +=
                        TempVATAmountLine."EC Amount" *
                        (CalcLineAmount - "Pmt. Discount Amount") /
                        (TempVATAmountLine.CalcLineAmount - TempVATAmountLine."Pmt. Discount Amount");
                        TempVATAmountLineRemainder."Amount Including VAT" +=
                        TempVATAmountLine."Amount Including VAT" *
                        (CalcLineAmount - "Pmt. Discount Amount") /
                        (TempVATAmountLine.CalcLineAmount - TempVATAmountLine."Pmt. Discount Amount");
                    END;
                    if "Line Discount %" <> 100 THEN
                        "Amount Including VAT" :=
                        ROUND(TempVATAmountLineRemainder."Amount Including VAT", gCurrency."Amount Rounding Precision")
                    ELSE
                        "Amount Including VAT" := 0;
                    Amount :=
                        ROUND("Amount Including VAT", gCurrency."Amount Rounding Precision") -
                        ROUND(TempVATAmountLineRemainder."VAT Amount", gCurrency."Amount Rounding Precision") -
                        ROUND(TempVATAmountLineRemainder."EC Amount", gCurrency."Amount Rounding Precision");
                    "VAT Base Amount" :=
                        ROUND(
                        Amount * (1 - SalesHeader."VAT Base Discount %" / 100), gCurrency."Amount Rounding Precision");
                    TempVATAmountLineRemainder."Amount Including VAT" :=
                        TempVATAmountLineRemainder."Amount Including VAT" - "Amount Including VAT";
                    TempVATAmountLineRemainder."VAT Amount" :=
                        TempVATAmountLineRemainder."VAT Amount" - "Amount Including VAT" + Amount;
                END ELSE
                    if "VAT Calculation Type" = "VAT Calculation Type"::"Full VAT" THEN BEGIN
                        if "Line Discount %" <> 100 THEN
                            "Amount Including VAT" := CalcLineAmount
                        ELSE
                            "Amount Including VAT" := 0;
                        Amount := 0;
                        "VAT Base Amount" := 0;
                    END ELSE BEGIN
                        Amount := CalcLineAmount - "Pmt. Discount Amount";
                        "VAT Base Amount" :=
                        ROUND(
                            Amount * (1 - SalesHeader."VAT Base Discount %" / 100), gCurrency."Amount Rounding Precision");
                        if TempVATAmountLine."VAT Base" = 0 THEN
                            TempVATAmountLineRemainder."VAT Amount" := 0
                        ELSE
                            if TempVATAmountLine."Line Amount" <> 0 THEN BEGIN
                                TempVATAmountLineRemainder."VAT Amount" +=
                                TempVATAmountLine."VAT Amount" *
                                (CalcLineAmount - "Pmt. Discount Amount") /
                                (TempVATAmountLine.CalcLineAmount - TempVATAmountLine."Pmt. Discount Amount");
                                TempVATAmountLineRemainder."EC Amount" +=
                                TempVATAmountLine."EC Amount" *
                                (CalcLineAmount - "Pmt. Discount Amount") /
                                (TempVATAmountLine.CalcLineAmount - TempVATAmountLine."Pmt. Discount Amount");
                            END;
                        if "Line Discount %" <> 100 THEN
                            "Amount Including VAT" :=
                                Amount + ROUND(TempVATAmountLineRemainder."VAT Amount", gCurrency."Amount Rounding Precision") +
                                ROUND(TempVATAmountLineRemainder."EC Amount", gCurrency."Amount Rounding Precision")
                        ELSE
                            "Amount Including VAT" := 0;
                        TempVATAmountLineRemainder."VAT Amount" :=
                        TempVATAmountLineRemainder."VAT Amount" - "Amount Including VAT" + Amount;
                    END;

                TempVATAmountLineRemainder.MODIFY;
                //if "Deferral Code" <> '' THEN
                //CalcDeferralAmounts(SalesHeader,SalesLine,OriginalDeferralAmount);
            END;
    END;

    /// <summary>
    /// IncrAmount.
    /// </summary>
    /// <param name="SalesHeader">Record "Sales Header".</param>
    /// <param name="SalesLine">Record "Sales Line".</param>
    /// <param name="VAR TotalSalesLine">Record "Sales Line".</param>
    procedure IncrAmount(SalesHeader: Record "Sales Header"; SalesLine: Record "Sales Line"; VAR TotalSalesLine: Record "Sales Line")
    Begin
        WITH SalesLine DO BEGIN
            if SalesHeader."Prices Including VAT" OR
                ("VAT Calculation Type" <> "VAT Calculation Type"::"Full VAT")
            THEN
                Increment(TotalSalesLine."Line Amount", "Line Amount");
            Increment(TotalSalesLine.Amount, Amount);
            Increment(TotalSalesLine."VAT Base Amount", "VAT Base Amount");
            Increment(TotalSalesLine."VAT Difference", "VAT Difference");
            Increment(TotalSalesLine."Amount Including VAT", "Amount Including VAT");
            Increment(TotalSalesLine."Line Discount Amount", "Line Discount Amount");
            Increment(TotalSalesLine."Inv. Discount Amount", "Inv. Discount Amount");
            Increment(TotalSalesLine."Inv. Disc. Amount to Invoice", "Inv. Disc. Amount to Invoice");
            Increment(TotalSalesLine."Prepmt. Line Amount", "Prepmt. Line Amount");
            Increment(TotalSalesLine."Prepmt. Amt. Inv.", "Prepmt. Amt. Inv.");
            Increment(TotalSalesLine."Prepmt Amt to Deduct", "Prepmt Amt to Deduct");
            Increment(TotalSalesLine."Prepmt Amt Deducted", "Prepmt Amt Deducted");
            Increment(TotalSalesLine."Prepayment VAT Difference", "Prepayment VAT Difference");
            Increment(TotalSalesLine."Prepmt VAT Diff. to Deduct", "Prepmt VAT Diff. to Deduct");
            Increment(TotalSalesLine."Prepmt VAT Diff. Deducted", "Prepmt VAT Diff. Deducted");
            Increment(TotalSalesLine."Pmt. Discount Amount", "Pmt. Discount Amount");

        END;
    END;

    /// <summary>
    /// Increment.
    /// </summary>
    /// <param name="VAR Number">Decimal.</param>
    /// <param name="Number2">Decimal.</param>
    procedure Increment(VAR Number: Decimal; Number2: Decimal)
    begin
        Number := Number + Number2;
    end;

    /// <summary>
    /// RoundAmount.
    /// </summary>
    /// <param name="SalesHeader">Record "Sales Header".</param>
    /// <param name="VAR SalesLine">Record "Sales Line".</param>
    /// <param name="SalesLineQty">Decimal.</param>
    /// <param name="TotalSalesLine">VAR Record 37.</param>
    /// <param name="TotalSalesLineLCY">VAR Record 37.</param>
    /// <summary>
    /// RoundAmount.
    /// </summary>
    /// <param name="SalesHeader">Record "Sales Header".</param>
    /// <param name="VAR SalesLine">Record "Sales Line".</param>
    /// <param name="SalesLineQty">Decimal.</param>
    /// <param name="TotalSalesLine">VAR Record 37.</param>
    /// <param name="TotalSalesLineLCY">VAR Record 37.</param>
    procedure RoundAmount(SalesHeader: Record "Sales Header"; VAR SalesLine: Record "Sales Line"; SalesLineQty: Decimal; var TotalSalesLine: Record 37; var TotalSalesLineLCY: Record 37)
    var
        CurrExchRate: Record "Currency Exchange Rate";
        NoVAT: Boolean;
        UseDate: Date;
    begin

        UseDate := SalesHeader."Posting Date";
        WITH SalesLine DO BEGIN
            IncrAmount(SalesHeader, SalesLine, TotalSalesLine);
            Increment(TotalSalesLine."Net Weight", ROUND(SalesLineQty * "Net Weight", 0.00001));
            Increment(TotalSalesLine."Gross Weight", ROUND(SalesLineQty * "Gross Weight", 0.00001));
            Increment(TotalSalesLine."Unit Volume", ROUND(SalesLineQty * "Unit Volume", 0.00001));
            Increment(TotalSalesLine.Quantity, SalesLineQty);
            if "Units per Parcel" > 0 THEN
                Increment(
                TotalSalesLine."Units per Parcel",
                ROUND(SalesLineQty / "Units per Parcel", 1, '>'));

            gSalesLineTMP := SalesLine;
            gSalesLineTMPACY := SalesLine;

            if SalesHeader."Currency Code" <> '' THEN BEGIN
                if SalesHeader."Posting Date" = 0D THEN
                    UseDate := WORKDATE
                ELSE
                    UseDate := SalesHeader."Posting Date";

                NoVAT := Amount = "Amount Including VAT";
                "Amount Including VAT" :=
                ROUND(
                    CurrExchRate.ExchangeAmtFCYToLCY(
                    UseDate, SalesHeader."Currency Code",
                    TotalSalesLine."Amount Including VAT", SalesHeader."Currency Factor")) -
                TotalSalesLineLCY."Amount Including VAT";
                if NoVAT THEN
                    Amount := "Amount Including VAT"
                ELSE
                    Amount :=
                        ROUND(
                        CurrExchRate.ExchangeAmtFCYToLCY(
                            UseDate, SalesHeader."Currency Code",
                            TotalSalesLine.Amount, SalesHeader."Currency Factor")) -
                        TotalSalesLineLCY.Amount;
                "Line Amount" :=
                ROUND(
                    CurrExchRate.ExchangeAmtFCYToLCY(
                    UseDate, SalesHeader."Currency Code",
                    TotalSalesLine."Line Amount", SalesHeader."Currency Factor")) -
                TotalSalesLineLCY."Line Amount";
                "Line Discount Amount" :=
                ROUND(
                    CurrExchRate.ExchangeAmtFCYToLCY(
                    UseDate, SalesHeader."Currency Code",
                    TotalSalesLine."Line Discount Amount", SalesHeader."Currency Factor")) -
                TotalSalesLineLCY."Line Discount Amount";
                "Inv. Discount Amount" :=
                ROUND(
                    CurrExchRate.ExchangeAmtFCYToLCY(
                    UseDate, SalesHeader."Currency Code",
                    TotalSalesLine."Inv. Discount Amount", SalesHeader."Currency Factor")) -
                TotalSalesLineLCY."Inv. Discount Amount";
                "Pmt. Discount Amount" :=
                ROUND(
                    CurrExchRate.ExchangeAmtFCYToLCY(
                    UseDate, SalesHeader."Currency Code",
                    TotalSalesLine."Pmt. Discount Amount", SalesHeader."Currency Factor")) -
                TotalSalesLineLCY."Pmt. Discount Amount";
                "VAT Difference" :=
                ROUND(
                    CurrExchRate.ExchangeAmtFCYToLCY(
                    UseDate, SalesHeader."Currency Code",
                    TotalSalesLine."VAT Difference", SalesHeader."Currency Factor")) -
                TotalSalesLineLCY."VAT Difference";
                "VAT Base Amount" :=
                ROUND(
                    CurrExchRate.ExchangeAmtFCYToLCY(
                    UseDate, SalesHeader."Currency Code",
                    TotalSalesLine."VAT Base Amount", SalesHeader."Currency Factor")) -
                TotalSalesLineLCY."VAT Base Amount";
            END;


            IncrAmount(SalesHeader, SalesLine, TotalSalesLineLCY);
            Increment(TotalSalesLineLCY."Unit Cost (LCY)", ROUND(SalesLineQty * "Unit Cost (LCY)"));
        END;
    END;

    /// <summary>
    /// MAX.
    /// </summary>
    /// <param name="number1">Integer.</param>
    /// <param name="number2">Integer.</param>
    /// <returns>Return value of type Integer.</returns>
    procedure MAX(number1: Integer; number2: Integer): Integer
    begin
        if number1 > number2 THEN
            EXIT(number1);
        EXIT(number2);
    end;

    /// <summary>
    /// InvoiceRounding.
    /// </summary>
    /// <param name="SalesHeader">Record "Sales Header".</param>
    /// <param name="VAR SalesLine">Record "Sales Line".</param>
    /// <param name="UseTempData">Boolean.</param>
    /// <param name="BiggestLineNo">Integer.</param>
    /// <param name="Var TotalSalesLine">Record "Sales Line".</param>
    procedure InvoiceRounding(SalesHeader: Record "Sales Header"; VAR SalesLine: Record "Sales Line"; UseTempData: Boolean; BiggestLineNo: Integer; Var TotalSalesLine: Record "Sales Line");
    var
        InvoiceRoundingAmount: Decimal;
        CustPostingGr: Record "Customer Posting Group";
    begin
        gCurrency.TESTFIELD("Invoice Rounding Precision");
        InvoiceRoundingAmount :=
        -ROUND(
            TotalSalesLine."Amount Including VAT" -
            ROUND(
            TotalSalesLine."Amount Including VAT", gCurrency."Invoice Rounding Precision", gCurrency.InvoiceRoundingDirection),
            gCurrency."Amount Rounding Precision");

        if InvoiceRoundingAmount <> 0 THEN BEGIN
            CustPostingGr.GET(SalesHeader."Customer Posting Group");
            WITH SalesLine DO BEGIN
                INIT;
                BiggestLineNo := BiggestLineNo + 10000;
                "System-Created Entry" := TRUE;
                if UseTempData THEN BEGIN
                    "Line No." := 0;
                    Type := Type::"G/L Account";
                    SetHideValidationDialog(TRUE);
                END ELSE BEGIN
                    "Line No." := BiggestLineNo;
                    VALIDATE(Type, Type::"G/L Account");
                END;
                VALIDATE("No.", CustPostingGr.GetInvRoundingAccount);
                VALIDATE(Quantity, 1);
                if IsCreditDocType THEN
                    VALIDATE("Return Qty. to Receive", Quantity)
                ELSE
                    VALIDATE("Qty. to Ship", Quantity);
                if SalesHeader."Prices Including VAT" THEN
                    VALIDATE("Unit Price", InvoiceRoundingAmount)
                ELSE
                    VALIDATE(
                        "Unit Price",
                        ROUND(
                        InvoiceRoundingAmount /
                        (1 + (1 - SalesHeader."VAT Base Discount %" / 100) * "VAT %" / 100),
                        gCurrency."Amount Rounding Precision"));
                VALIDATE("Amount Including VAT", InvoiceRoundingAmount);
                "Line No." := BiggestLineNo;
                gbLastLineRetrieved := FALSE;
                gbRoundingLineInserted := TRUE;
                giRoundingLineNo := "Line No.";
            END;
        END;
    end;






    PROCEDURE TieneMarcaDto(pNumDoc: Code[20]): Boolean;
    VAR
        rRemReg: Record 7000006;
    BEGIN
        //$004. Compruebo si la remesa tiene la marca de Remesa al descuento.
        if rRemReg.GET(pNumDoc) THEN BEGIN
            if rRemReg."Remesa al descuento" THEN
                EXIT(TRUE);
        END;
        EXIT(FALSE);
    END;

    internal procedure MarcarComoRecibida(var r39: Record "Purchase Line")
    begin
        r39.Quantity := r39."Quantity Received";
        r39."Outstanding Quantity" := 0;
        r39."Qty. to Receive" := 0;
        r39."Quantity (Base)" := r39."Qty. Received (Base)";
        r39."Qty. to Receive (Base)" := 0;
        r39.MODIFY;
    end;

    internal procedure MarcarComoPendienteEfactura(var Rec: Record "Sales Invoice Header")
    begin
        Rec."Situación Efactura" := Rec."Situación Efactura"::Pendiente;
        Rec.Modify();
    end;

    internal procedure LiquidarFacturas()
    var
        Importe2: decimal;
        rMovCliDet: record "Detailed Cust. Ledg. Entry";
        wNumMov: Integer;
        r21: Record 21;
        Importe: Decimal;
        pCustLedgEntry: Record 21;
    Begin

        //$005. Grabo un movimiento detallado de cliente para que la factura quede liquidada.
        //Se trata de gestión de remesas sin factura. La factura se registra cuando se ha creado
        //y liquidado (no siempre) el efecto.
        pCustLedgEntry.SetRange(Open, true);
        pCustLedgEntry.SetFilter("Nº Factura Borrador", '<>%1', '');
        if pCustLedgEntry.FindFirst() then
            repeat
                pCustLedgEntry.CALCFIELDS("Remaining Amount", "Remaining Amt. (LCY)");
                Importe2 := pCustLedgEntry."Remaining Amount";

                //WITH pGenJnlLine DO BEGIN
                rMovCliDet.RESET;
                if rMovCliDet.FINDLAST THEN BEGIN
                    wNumMov := rMovCliDet."Entry No.";
                END
                ELSE BEGIN
                    wNumMov := 0;
                END;
                r21.SETCURRENTKEY(r21."Nº Factura Borrador");
                r21.SETRANGE(r21."Nº Factura Borrador", pCustLedgEntry."Nº Factura Borrador");
                r21.SetRange(r21."Customer No.", pCustLedgEntry."Customer No.");
                r21.SETFILTER(r21."Entry No.", '<>%1', pCustLedgEntry."Entry No.");
                r21.SETFILTER("Remaining Amount", '<>%1', 0);
                if NOT r21.FINDLAST THEN EXIT;
                r21.CALCFIELDS("Remaining Amount", "Remaining Amt. (LCY)");
                Importe := -r21."Remaining Amount";
                if ABS(Importe2) < ABS(Importe) THEN BEGIN
                    Importe := Importe2;
                    Importe2 := pCustLedgEntry."Remaining Amt. (LCY)"
                END ELSE
                    Importe2 := -r21."Remaining Amt. (LCY)";
                //if "Source No." <> pCustLedgEntry."Customer No." THEN EXIT;
                rMovCliDet.INIT;
                rMovCliDet."Entry No." := wNumMov + 1;
                rMovCliDet."Cust. Ledger Entry No." := pCustLedgEntry."Entry No.";
                rMovCliDet."Entry Type" := rMovCliDet."Entry Type"::Application;
                rMovCliDet."Posting Date" := pCustLedgEntry."Posting Date";
                rMovCliDet."Document Type" := pCustLedgEntry."Document Type";
                rMovCliDet."Document No." := pCustLedgEntry."Document No.";
                rMovCliDet.Amount := -Importe;
                rMovCliDet."Amount (LCY)" := -Importe2;
                rMovCliDet."Customer No." := pCustLedgEntry."Customer No.";
                rMovCliDet."Currency Code" := pCustLedgEntry."Currency Code";
                rMovCliDet."User ID" := USERID;
                rMovCliDet."Source Code" := pCustLedgEntry."Source Code";
                rMovCliDet."Transaction No." := pCustLedgEntry."Transaction No.";
                rMovCliDet."Initial Entry Due Date" := pCustLedgEntry."Due Date";
                rMovCliDet."Initial Entry Global Dim. 1" := pCustLedgEntry."Global Dimension 1 Code";
                rMovCliDet."Initial Entry Global Dim. 2" := pCustLedgEntry."Global Dimension 2 Code";
                //ASC
                rMovCliDet."Initial Entry Global Dim. 3" := pCustLedgEntry."Global Dimension 3 Code";
                rMovCliDet."Initial Entry Global Dim. 4" := pCustLedgEntry."Global Dimension 4 Code";
                rMovCliDet."Initial Entry Global Dim. 5" := pCustLedgEntry."Global Dimension 5 Code";

                rMovCliDet."Initial Document Type" := pCustLedgEntry."Document Type";
                rMovCliDet."Applied Cust. Ledger Entry No." := r21."Entry No.";
                rMovCliDet.INSERT;
                rMovCliDet.INIT;
                rMovCliDet."Entry No." := wNumMov + 2;
                rMovCliDet."Cust. Ledger Entry No." := r21."Entry No.";
                rMovCliDet."Entry Type" := rMovCliDet."Entry Type"::Application;
                rMovCliDet."Posting Date" := r21."Posting Date";
                rMovCliDet."Document Type" := r21."Document Type";
                rMovCliDet."Document No." := r21."Document No.";
                // r21.CALCFIELDS(r21.Amount,r21."Amount (LCY)");
                rMovCliDet.Amount := Importe;
                rMovCliDet."Amount (LCY)" := Importe2;
                rMovCliDet."Customer No." := r21."Customer No.";
                rMovCliDet."Currency Code" := r21."Currency Code";
                rMovCliDet."User ID" := USERID;
                rMovCliDet."Source Code" := r21."Source Code";
                rMovCliDet."Transaction No." := r21."Transaction No.";
                rMovCliDet."Initial Entry Due Date" := r21."Due Date";
                rMovCliDet."Initial Entry Global Dim. 1" := r21."Global Dimension 1 Code";
                rMovCliDet."Initial Entry Global Dim. 2" := r21."Global Dimension 2 Code";
                //ASC
                rMovCliDet."Initial Entry Global Dim. 3" := r21."Global Dimension 3 Code";
                rMovCliDet."Initial Entry Global Dim. 4" := r21."Global Dimension 4 Code";
                rMovCliDet."Initial Entry Global Dim. 5" := r21."Global Dimension 5 Code";

                rMovCliDet."Initial Document Type" := r21."Document Type";
                rMovCliDet."Applied Cust. Ledger Entry No." := pCustLedgEntry."Entry No.";
                rMovCliDet.INSERT;
            //END;
            until pCustLedgEntry.Next() = 0;
    End;

    internal procedure UpdatePaymentMethodCode(EntryNo: Integer; Tipo: Enum "Cartera Document Type"; PaymentMethodCode: Code[10])
    var
        CarteraDoc: Record "Cartera Doc.";
    begin
        with CarteraDoc do begin
            if Get(Tipo, EntryNo) Then begin
                "Payment Method Code" := PaymentMethodCode;
                Modify();
            end;

        end;
    end;

    internal procedure AsignarBancoCliente(var Docs: Record "Posted Cartera Doc.")
    var
        r21: Record 21;
        Bank: Record "Customer Bank Account";
        Cust: Record Customer;
    //SalesHeader: Record "Sales Header";
    begin
        if Docs.FindFirst() Then
            Repeat
                if Docs."Cust./Vendor Bank Acc. Code" = '' THEN BEGIN
                    Cust.Get(Docs."Account No.");
                    if NOT Bank.GET(Docs."Account No.", Cust."Preferred Bank Account Code") THEN BEGIN
                        Bank.SetRange("Customer No.", Docs."Account No.");
                        if Bank.FindLast() Then begin
                            Docs."Cust./Vendor Bank Acc. Code" := Bank.Code;
                            Docs.Modify();
                        End;

                    End else begin
                        Docs."Cust./Vendor Bank Acc. Code" := Bank.Code;
                        Docs.Modify();
                    end;
                END;

            Until Docs.Next() = 0;
    end;

    internal procedure AsignarFacturaBorrador(var Docs: Record "Cartera Doc.")
    var
        r21: Record 21;
        PayMenthMetod: Record "Payment Method";
        SalesInvoice: Record 112;
        SalesHeader: Record "Sales Header";
    begin
        if Docs.FindFirst() Then
            Repeat
                if Docs."No. Borrador factura" = '' THEN BEGIN
                    if NOT r21.GET(Docs."Entry No.") THEN BEGIN
                        if PayMenthMetod.Get(Docs."Payment Method Code") Then Begin
                            if PayMenthMetod."Remesa sin factura" Then begin
                                SalesInvoice.SetRange("Bill-to Customer No.", Docs."Account No.");
                                SalesInvoice.SetRange("Due Date", Docs."Due Date");
                                //Efecto CTO22-00546-10/10/12
                                //12345678
                                SalesInvoice.Setrange("Nº Contrato", Copystr(Docs.Description, 8, 11));
                                if SalesInvoice.FindFirst() Then begin
                                    r21.SetRange("Document No.", SalesInvoice."No.");
                                    r21.SetRange("Nº Factura Borrador", '');
                                    if r21.FindFirst() Then begin
                                        r21."Nº Factura Borrador" := SalesInvoice."Pre-Assigned No.";
                                        r21.Modify();
                                    end;
                                    Docs."No. Borrador factura" := SalesInvoice."Pre-Assigned No.";
                                end else begin
                                    SalesHeader.SetRange("Bill-to Customer No.", Docs."Account No.");
                                    SalesHeader.SetRange("Due Date", Docs."Due Date");
                                    SalesHeader.Setrange("Nº Contrato", Copystr(Docs.Description, 8, 11));
                                    if SalesHeader.FindFirst() Then
                                        Docs."No. Borrador factura" := SalesHeader."No.";

                                end;
                                //Docs."No. Borrador factura" := 'SINFAC';
                                Docs.MODIFY;
                            End;
                        end;
                    END;
                END;
            Until Docs.Next() = 0;
    end;

    internal procedure AsignarFacturaBorrador(var Docs: Record "Posted Cartera Doc.")
    var
        r21: Record 21;
        PayMenthMetod: Record "Payment Method";
        SalesInvoice: Record 112;
        SalesHeader: Record "Sales Header";
    begin
        if Docs.FindFirst() Then
            Repeat
                if Docs."No. Borrador factura" = '' THEN BEGIN
                    if NOT r21.GET(Docs."Entry No.") THEN BEGIN
                        if PayMenthMetod.Get(Docs."Payment Method Code") Then Begin
                            if PayMenthMetod."Remesa sin factura" Then begin
                                SalesInvoice.SetRange("Bill-to Customer No.", Docs."Account No.");
                                SalesInvoice.SetRange("Due Date", Docs."Due Date");
                                //Efecto CTO22-00546-10/10/12
                                //12345678
                                SalesInvoice.Setrange("Nº Contrato", Copystr(Docs.Description, 8, 11));
                                if SalesInvoice.FindFirst() Then begin
                                    r21.SetRange("Document No.", SalesInvoice."No.");
                                    r21.SetRange("Nº Factura Borrador", '');
                                    if r21.FindFirst() Then begin
                                        r21."Nº Factura Borrador" := SalesInvoice."Pre-Assigned No.";
                                        r21.Modify();
                                    end;
                                    Docs."No. Borrador factura" := SalesInvoice."Pre-Assigned No.";
                                end else begin
                                    SalesHeader.SetRange("Bill-to Customer No.", Docs."Account No.");
                                    SalesHeader.SetRange("Due Date", Docs."Due Date");
                                    SalesHeader.Setrange("Nº Contrato", Copystr(Docs.Description, 8, 11));
                                    if SalesHeader.FindFirst() Then
                                        Docs."No. Borrador factura" := SalesHeader."No.";

                                end;
                                //Docs."No. Borrador factura" := 'SINFAC';
                                Docs.MODIFY;
                            End;
                        end;
                    END;
                END;
            Until Docs.Next() = 0;
    end;

    internal procedure CambiaDireccionEnvio(var Rec: Record "Sales Invoice Header"; var Envios: Record "Ship-to Address")

    begin
        Rec."Ship-to Code" := Envios.Code;
        Rec."Ship-to Address" := Envios."Address";
        Rec."Ship-to Address 2" := Envios."Address 2";
        Rec."Ship-to Name" := Envios.Name;
        Rec."Ship-to Name 2" := Envios."Name 2";
        Rec.Modify();

    end;

    internal procedure ModificaTexto(var Rec: Record "Sales Invoice Header"; WorkDescription: Text)
    VAR
        TempBlob: Codeunit "Temp Blob";
        TypeHelper: Codeunit "Type Helper";
        InStream: InStream;
        OutStream: OutStream;
        RecRf: RecordRef;
    begin
        Rec."Work Description".CreateOutStream(OutStream, TextEncoding::UTF8);
        OutStream.WriteText(WorkDescription);
        Rec.Modify();
        WorkDescription := Rec.GetWorkDescription();
        Message(WorkDescription);
        //B64.ToBase64()

    end;




    internal procedure CierreProcesos(Var Rec: Record "Posted Bill Group")
     r70004: Record 7000003;
    begin

        r70004.SETCURRENTKEY(r70004."Bill Gr./Pmt. Order No.");
        r70004.SETRANGE(r70004."Bill Gr./Pmt. Order No.", Rec."No.");
        r70004.MODIFYALL(r70004."Remaining Amount", 0);
        r70004.MODIFYALL(r70004."Remaining Amt. (LCY)", 0);
        r70004.MODIFYALL(r70004.Status, r70004.Status::Honored);


    end;

    internal procedure CierreProcesosPo(Var Rec: Record "Posted Payment Order")
     r70004: Record 7000003;
    begin

        r70004.SETCURRENTKEY(r70004."Bill Gr./Pmt. Order No.");
        r70004.SETRANGE(r70004."Bill Gr./Pmt. Order No.", Rec."No.");
        r70004.MODIFYALL(r70004."Remaining Amount", 0);
        r70004.MODIFYALL(r70004."Remaining Amt. (LCY)", 0);
        r70004.MODIFYALL(r70004.Status, r70004.Status::Honored);


    end;

    internal procedure MarcarLineasComoImprimibles(var SalesInv: Record "Sales Cr.Memo Header")
    var
        SalesInvLine: Record "Sales Cr.Memo Line";
    begin
        if SalesInv.FindFirst() then
            repeat
                SalesInvLine.SETRANGE("Document No.", SalesInv."No.");
                SalesInvLine.ModifyAll(Imprimir, TRUE);
            until SalesInv.Next() = 0;
    end;

    internal procedure MarcarImprimibleFac(Rec: Record "Sales Invoice Line")
    begin
        Rec.Imprimir := Not Rec.Imprimir;
        If not Rec.Imprimir then
            If Rec."Amount Including VAT" <> 0 then Error('No se puede desmarcar imprimir una línea con importe');
        Rec.Modify();
    end;

    internal procedure MarcarImprimibleAbo(Rec: Record "Sales Cr.Memo Line")
    begin
        Rec.Imprimir := Not Rec.Imprimir;
        If not Rec.Imprimir then
            If Rec."Amount Including VAT" <> 0 then Error('No se puede desmarcar imprimir una línea con importe');
        Rec.Modify();
    end;

    /// <summary>
    /// CompruebaPermisos.
    /// </summary>
    /// <param name="pUserGuidId">Guid.</param>
    /// <param name="pRolId">Text.</param>
    /// <param name="Empresa">Text.</param>
    /// <returns>Return value of type Boolean.</returns>
    procedure CompruebaPermisos(pUserGuidId: Guid; pRolId: Text; Empresa: Text): Boolean
    var
        rMem: Record "Access Control";
    begin
        rMem.SETRANGE("User Security ID", pUSERGuidID);
        rMem.SETRANGE(rMem."Role ID", pRolid);
        If Empresa <> '' Then
            rMem.SetFilter("Company Name", '%1|%2', '', Empresa)
        else
            rMem.SetFilter("Company Name", '%1', '');

        exit(not rMem.IsEmpty);

    end;

    internal procedure BorrcaAlb()
    begin
        If not CompruebaPermisos(UserSecurityId(), 'BORRCAALB', CompanyName) then
            ERROR('Error, no tiene permisos para completar esta acción. Contacte con Administración');
    end;

    internal procedure MarcaAlb()
    begin

        If Not (CompruebaPermisos(UserSecurityId(), 'MARCAALB', CompanyName)) then
            ERROR('Error, no tiene permisos para completar esta acción. Contacte con Administración');
    end;

    internal procedure ArreglarMandato(Rec: Record "Cartera Doc."; Todos: Boolean)
    var
        DebirMandate: Record "SEPA Direct Debit Mandate";
        custo: Record Customer;
        BanckCustomer: Record "Customer Bank Account";
        CarteraDos: Record "Cartera Doc.";
    begin
        CarteraDos.SetRange("Bill Gr./Pmt. Order No.", Rec."Bill Gr./Pmt. Order No.");
        If not Todos then
            CarteraDos.SetRange("Entry No.", Rec."Entry No.");
        if CarteraDos.FindFirst() then
            repeat
                if CarteraDos."Direct Debit Mandate ID" <> '' then begin
                    DebirMandate.Get(CarteraDos."Direct Debit Mandate ID");
                    if DebirMandate."Valid from" > CarteraDos."Due Date" then
                        DebirMandate."Valid From" := CalcDate('-1D', CarteraDos."Due Date");
                    if DebirMandate."Valid To" < CarteraDos."Due Date" then
                        DebirMandate."Valid To" := CalcDate('1D', CarteraDos."Due Date");
                    if DebirMandate."Date of Signature" >= Today then
                        DebirMandate."Date of Signature" := CalcDate('-1D', Today);
                    if DebirMandate."Customer Bank Account Code" = '' then
                        DebirMandate."Customer Bank Account Code" := CarteraDos."Cust./Vendor Bank Acc. Code";
                    if DebirMandate."Customer Bank Account Code" = '' Then begin
                        custo.Get(CarteraDos."Account No.");
                        DebirMandate."Customer Bank Account Code" := custo."Preferred Bank Account Code";
                        If DebirMandate."Customer Bank Account Code" = '' Then begin
                            BanckCustomer.SETRANGE("Customer No.", custo."No.");
                            if BanckCustomer.Count = 1 then begin
                                BanckCustomer.FINDFIRST;
                                DebirMandate."Customer Bank Account Code" := BanckCustomer.Code;
                            end;
                        end;
                    end;
                    DebirMandate.Modify();
                end else begin
                    Commit;
                    Error('No hay mandato en el Documento %1', CarteraDos."Document No.");
                end;
            until CarteraDos.Next() = 0;
    end;

    internal procedure RecircularFacturaBorrador(var Docs: Record "Posted Cartera Doc.")
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
        PayMenthMetod: Record "Payment Method";
        SalesInvoice: Record 112;
        SalesHeader: Record "Sales Header";
        Text1100000: Label 'Por especifica un nuevo vencimiento para la factura borrador';
        Text1100001: Label 'Por favor, rellene tanto el Nombre de Plantilla como el Nombre de Lote del Diario Auxiliar con valores correctos.';
        Text1100002: Label 'Recirculando           #1######';
        Text1100003: Label 'La nueva fecha de vencimiento no puede ser anterior a la actual %1 en el Documento %2 %3.';
        Text1100004: Label 'Documento %1/%2';
        Text1100005: Label 'Documento %1/%2 Gastos de Descuento/Cobro';
        Text1100006: Label 'Documento %1/%2 Intereses de Descuento';
        Text1100007: Label 'Documento %1/%2 Gastos de Rechazo';
        Text1100008: Label 'Documento %1/%2 Gastos Financieros';
        Text1100009: Label 'Ajuste residual generado por redondeo de Importe';
        Text1100010: Label '%1 Documentos han sido preparados para recircular.';
        Customer: Record Customer;
        CustPostingGr: Record "Customer Posting Group";
        GenJnlTemplate: Record "Gen. Journal Template";
        GenJnlBatch: Record "Gen. Journal Batch";
        GenJnlLine: Record "Gen. Journal Line";
        FeeRange: Record "Fee Range";
        FinanceChargeTerms: Record "Finance Charge Terms";
        PostedBillGr: Record "Posted Bill Group";
        BankAcc: Record "Bank Account";
        BankAccPostingGr: Record "Bank Account Posting Group";
        Currency: Record Currency;
        TempCVLedgEntryBuf: Record "CV Ledger Entry Buffer" temporary;
        DocPost: Codeunit "Document-Post";
        GenJnlManagement: Codeunit GenJnlManagement;
        CarteraJnlForm: Page "Cartera Journal";
        Window: Dialog;
        TransactionNo: Integer;
        IncludeDiscCollExpenses: Boolean;
        IncludeRejExpenses: Boolean;
        IncludeFinanceCharges: Boolean;
        IncludeExpenses: Boolean;
        ArePostedDocs: Boolean;
        Discount: Boolean;
        IsOpenBill: Boolean;
        PostingDate: Date;
        BillGrPostingDate: Date;
        BatchName: Code[10];
        TemplName: Code[10];
        SourceCode: Code[10];
        ReasonCode: Code[10];
        NewDocAmount: Decimal;
        NewDocAmountLCY: Decimal;
        GenJnlLineNextNo: Integer;
        DocCount: Integer;
        Account: Code[20];
        DocNo: Code[20];
        NewDueDate: Date;
        NewPmtMethod: Code[10];
        AmtForCollection: Decimal;
        SumLCYAmt: Decimal;
        EntryType: Option " ","Initial Entry",Application,"Unrealized Loss","Unrealized Gain","Realized Loss","Realized Gain","Payment Discount","Payment Discount (VAT Excl.)","Payment Discount (VAT Adjustment)","Appln. Rounding","Correction of Remaining Amount",,,,,,,,,Settlement,Rejection,Redrawal,Expenses;
        AccountType: Enum "Gen. Journal Account Type";
        DocumentType: Enum "Gen. Journal Document Type";
        lcGenJnlPostline: Codeunit "Gen. Jnl.-Post Line";
    begin
        TemplName := 'CARTERA';
        BatchName := 'GENERICO';
        if Docs.FindFirst() Then
            Repeat
                if Docs."No. Borrador factura" = '' THEN Error('No hay factura borrador en el Documento %1', Docs."Document No.");
                if CustLedgerEntry.Get(Docs."Entry No.") Then Error('Utilice la función estandard de recircular');
                If Docs."Remaining Amount" = 0 Then Error('El documento %1 ya está liquidado', Docs."Document No.");
                If PostedBillGr."Dealing Type" = PostedBillGr."Dealing Type"::Discount Then Error('No se puede recircular un documento al descuento');
            Until Docs.Next() = 0;
        if Docs.FindFirst() Then
            Repeat
                Clear(FeeRange);
                Clear(FinanceChargeTerms);
                NewDueDate := Docs."Due Date";
                SumLCYAmt := 0;
                DocCount := DocCount + 1;
                Window.Update(1, DocCount);
                Customer.Get(Docs."Account No.");
                Customer.TestField("Customer Posting Group");
                CustPostingGr.Get(Customer."Customer Posting Group");
                PostedBillGr.Get(Docs."Bill Gr./Pmt. Order No.");
                GenJnlLineInit(GenJnlLine, GenJnlLineNextNo, TransactionNo, TemplName, BatchName, PostingDate, SourceCode, ReasonCode);
                CreateCarteraDoc(Docs);
                AccountType := AccountType::"G/L Account";
                Account := CustPostingGr."Receivables Account";
                DocumentType := DocumentType::" ";
                InsertGenJnlLine(AccountType, Account, DocumentType, -Docs."Remaining Amount", 'Retrocesion Remesa ' + Docs."Bill Gr./Pmt. Order No.",
                Docs."Bill Gr./Pmt. Order No.", GenJnlLine, Docs, NewPmtMethod);
                IsOpenBill := true;
                GenJnlLine.Insert();
                Account := CustPostingGr."Bills on Collection Acc.";
                GenJnlLineInit(GenJnlLine, GenJnlLineNextNo, TransactionNo, TemplName, BatchName, PostingDate, SourceCode, ReasonCode);
                InsertGenJnlLine(AccountType, Account, DocumentType, Docs."Remaining Amount", 'Retrocesion Remesa ' + Docs."Bill Gr./Pmt. Order No.",
                Docs."Bill Gr./Pmt. Order No.", GenJnlLine, Docs, NewPmtMethod);
                lcGenJnlPostline.RunWithCheck(GenJnlLine);

                SumLCYAmt := SumLCYAmt + GenJnlLine."Amount (LCY)";

                NewDocAmount := -GenJnlLine.Amount;
                NewDocAmountLCY := -GenJnlLine."Amount (LCY)";
            until Docs.Next() = 0;
        Docs.DeleteAll();
        //Registrar diario



    end;

    local procedure CreateCarteraDoc(Var PstDoc: Record "Posted Cartera Doc.")
    var
        Doc: Record "Cartera Doc.";
    begin
        Doc.TransferFields(PstDoc);
        Doc."Bill Gr./Pmt. Order No." := '';
        Doc.Insert();
    end;

    local procedure GenJnlLineInit(var GenJnlLine: Record "Gen. Journal Line"; var GenJnlLineNextNo: Integer; var TransactionNo: Integer; var TemplName: Code[10]; var BatchName: Code[10]; var PostingDate: Date; var SourceCode: Code[10]; var ReasonCode: Code[10])
    begin
        Clear(GenJnlLine);
        GenJnlLine.Init();
        GenJnlLine."Line No." := GenJnlLineNextNo;
        GenJnlLineNextNo := GenJnlLineNextNo + 10000;
        GenJnlLine."Transaction No." := TransactionNo;
        GenJnlLine."Journal Template Name" := TemplName;
        GenJnlLine."Journal Batch Name" := BatchName;
        GenJnlLine."Posting Date" := PostingDate;
        GenJnlLine."Source Code" := SourceCode;
        GenJnlLine."Reason Code" := ReasonCode;
    end;

    local procedure InsertGenJnlLine(AccountType2: Enum "Gen. Journal Account Type";
    AccountNo2: Code[20]; DocumentType2: Enum "Gen. Journal Document Type";
    Amount2: Decimal; Description2: Text[250]; DocNo2: Code[20]; var GenJnlLine: Record "Gen. Journal Line"; Docs: Record "Posted Cartera Doc."
    ; NewPmtMethod: Code[10])
    var
        PreservedDueDate: Date;
        PreservedPaymentMethodCode: Code[10];
    begin
        GenJnlLine."Account Type" := AccountType2;
        PreservedDueDate := GenJnlLine."Due Date";
        PreservedPaymentMethodCode := GenJnlLine."Payment Method Code";
        GenJnlLine.Validate("Account No.", AccountNo2);
        GenJnlLine."Due Date" := PreservedDueDate;
        GenJnlLine."Payment Method Code" := PreservedPaymentMethodCode;
        GenJnlLine."Document Type" := DocumentType2;
        GenJnlLine."Document No." := Docs."Document No.";
        GenJnlLine."Bill No." := DocNo2;
        GenJnlLine.Description := CopyStr(Description2, 1, MaxStrLen(GenJnlLine.Description));
        GenJnlLine.Validate("Currency Code", '');
        GenJnlLine.Validate(Amount, Amount2);
        GenJnlLine."Dimension Set ID" := Docs."Dimension Set ID";
        GenJnlLine.Insert();
    end;




    /// <summary>
    /// CloseBillGroupIfEmpty.
    /// </summary>
    /// <param name="PostedBillGroup">Record "Posted Bill Group".</param>
    /// <param name="PostingDate">Date.</param>
    procedure CloseBillGroupIfEmpty(PostedBillGroup: Record "Posted Bill Group"; PostingDate: Date)
    var
        PostedCarteraDoc: Record "Posted Cartera Doc.";
        ClosedCarteraDoc: Record "Closed Cartera Doc.";
        CustLedgEntry: Record "Cust. Ledger Entry";
        ClosedBillGroup: Record "Closed Bill Group";
    begin
        with PostedCarteraDoc do begin
            Reset;
            SetCurrentKey("Bill Gr./Pmt. Order No.", Status);
            SetRange("Bill Gr./Pmt. Order No.", PostedBillGroup."No.");
            SetRange(Type, Type::Receivable);
            SetRange(Status, Status::Open);
            if not Find('-') then begin
                SetRange(Status);
                Find('-');
                repeat
                    ClosedCarteraDoc.TransferFields(PostedCarteraDoc);
                    ClosedCarteraDoc.Insert();
                    if CustLedgEntry.Get(ClosedCarteraDoc."Entry No.") Then begin
                        CustLedgEntry."Document Situation" := CustLedgEntry."Document Situation"::"Closed BG/PO";
                        CustLedgEntry.Modify();
                    End;
                until Next() = 0;
                DeleteAll();
                ClosedBillGroup.TransferFields(PostedBillGroup);
                ClosedBillGroup."Closing Date" := PostingDate;
                ClosedBillGroup.Insert();
                PostedBillGroup.Delete();
            end;
        end;
    end;

    /// <summary>
    /// CloseOrderGroupIfEmpty.
    /// </summary>
    /// <param name="PostedBillGroup">Record "Posted Payment Order".</param>
    /// <param name="PostingDate">Date.</param>
    procedure CloseOrderGroupIfEmpty(PostedBillGroup: Record "Posted Payment Order"; PostingDate: Date)
    var
        PostedCarteraDoc: Record "Posted Cartera Doc.";
        ClosedCarteraDoc: Record "Closed Cartera Doc.";
        CustLedgEntry: Record "Vendor Ledger Entry";
        ClosedBillGroup: Record "Closed Payment Order";
    begin
        with PostedCarteraDoc do begin
            Reset;
            SetCurrentKey("Bill Gr./Pmt. Order No.", Status);
            SetRange("Bill Gr./Pmt. Order No.", PostedBillGroup."No.");
            SetRange(Type, Type::Payable);
            SetRange(Status, Status::Open);
            if not Find('-') then begin
                SetRange(Status);
                if Find('-') then
                    repeat
                        ClosedCarteraDoc.TransferFields(PostedCarteraDoc);
                        if ClosedCarteraDoc.Insert() Then;
                        if CustLedgEntry.Get(ClosedCarteraDoc."Entry No.") Then begin
                            CustLedgEntry."Document Situation" := CustLedgEntry."Document Situation"::"Closed BG/PO";
                            CustLedgEntry.Modify();
                        End;
                    until Next() = 0;
                DeleteAll();
                ClosedBillGroup.TransferFields(PostedBillGroup);
                ClosedBillGroup."Closing Date" := PostingDate;
                ClosedBillGroup.Insert();
                PostedBillGroup.Delete();
            end;
        end;
    end;


    /// <summary>
    /// Inserta.
    /// </summary>
    /// <param name="RecRef">VAR RecordRef.</param>
    /// <param name="Empresa">Text.</param>
    procedure Inserta(var RecRef: RecordRef; Empresa: Text)
    Var
        Company: Record Company;
        RecRef2: RecordRef;
        rInf: Record "Company Information";
        Control: Codeunit ControlProcesos;
    begin
        rInf.Get();
        Company.SetRange("Evaluation Company", false);

        //if rInf."Empresa para mestros" = false then Error('Esta empresa no es la empresa de maestros');
        if Company.FindFirst() then
            repeat
                if (Empresa <> Company.Name) and (Control.Permiso_Empresas(Company.Name)) then begin
                    RecRef2.Open(RecRef.Number, false, Company.Name);
                    if RecRef2.Get(RecRef.RecordId) Then begin
                        RecRef2.Delete();
                    end;
                    RecRef2 := RecRef.Duplicate();
                    RecRef2.ChangeCompany(Company.Name);
                    RecRef2.Insert();
                    RecRef2.Close();
                end;
            until Company.Next() = 0;
    end;

    /// <summary>
    /// Modifica.
    /// </summary>
    /// <param name="RecRef">VAR RecordRef.</param>
    /// <param name="Empresa">Text.</param>
    /// <summary>
    /// Modifica.
    /// </summary>
    /// <param name="RecRef">VAR RecordRef.</param>
    /// <param name="Empresa">Text.</param>
    procedure Modifica(var RecRef: RecordRef; Empresa: Text)
    Var
        Company: Record Company;
        RecRef2: RecordRef;
        RecRefTemp: RecordRef;
        rInf: Record "Company Information";
        Campos: Record "Sincronization Setup (Field)";
        Control: Codeunit ControlProcesos;
    begin
        rInf.Get();
        Company.SetRange("Evaluation Company", false);
        if Company.FindFirst() then
            repeat
                if (Empresa <> Company.Name) and (Control.Permiso_Empresas(Company.Name)) then begin
                    RecRef2.Open(RecRef.Number, false, Company.Name);
                    RecRefTemp.Open(RecRef.Number, true, Company.Name);
                    if RecRef2.Get(RecRef.RecordId) Then begin
                        RecRefTemp := RecRef2.Duplicate();
                        RecRef2.Delete();
                        RecRef2 := RecRef.Duplicate();
                        RecRef2.ChangeCompany(Company.Name);
                        RecRef2.Insert();
                        Campos.SetRange("Table No.", RecRef.Number);
                        Campos.SetRange(Excluir, true);
                        if Campos.FindFirst() then begin
                            repeat
                                RecRef2.Field(Campos."Field No.").Value := RecRefTemp.Field(Campos."Field No.").Value;
                            //RecRef2.Field(Campos."Field No.").Validate();

                            until Campos.Next() = 0;
                            RecRef2.Modify();
                        end;
                        RecRef2.Close();
                        RecRefTemp.Close();
                    end else begin
                        RecRef2 := RecRef.Duplicate();
                        RecRef2.ChangeCompany(Company.Name);
                        RecRef2.Insert();
                        RecRef2.Close();
                        RecRefTemp.Close();
                    end;
                end;
            until Company.Next() = 0;
    end;

    /// <summary>
    /// Borra.
    /// </summary>
    /// <param name="RecRef">VAR RecordRef.</param>
    /// <param name="Empresa">Text.</param>
    procedure Borra(var RecRef: RecordRef; Empresa: Text)
    Var
        Company: Record Company;
        RecRef2: RecordRef;
        rInf: Record "Company Information";
        Control: Codeunit ControlProcesos;
    begin
        rInf.Get();
        Company.SetRange("Evaluation Company", false);
        //if rInf."Empresa para mestros" = false then Error('Esta empresa no es la empresa de maestros');
        if Company.FindFirst() then
            repeat
                if (Empresa <> Company.Name) and (Control.Permiso_Empresas(Company.Name)) then begin
                    RecRef2.Open(RecRef.Number, false, Company.Name);
                    if RecRef2.Get(RecRef.RecordId) Then begin
                        RecRef2.Delete();

                    end;
                    RecRef2.Close();
                end;
            until Company.Next() = 0;
    end;
}

