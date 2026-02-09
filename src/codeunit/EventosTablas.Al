/// <summary>
/// Codeunit ControldeEventos (ID 50003).
/// </summary>
codeunit 50016 ControldeEventosTables
{
    Permissions = TableData 17 = rimd,
    tabledata 110 = rimd,
    tabledata 111 = rimd,
    tabledata 112 = rimd,
    tabledata 113 = rimd,
    tabledata 114 = rimd,
    tabledata 115 = rimd,
    tabledata 120 = rimd,
    tabledata 121 = rimd,
    tabledata 122 = rimd,
    tabledata 123 = rimd,
    tabledata 124 = rimd,
    tabledata 125 = rimd,
    tabledata 81 = rimd,
    tabledata 25 = rimd,
    tabledata 21 = rimd,
    tabledata 271 = rimd,
    tabledata 379 = rimd,
    tabledata 380 = rimd,
    tabledata 7000002 = rimd;

    Var
        ContoldeProcesos: Codeunit Utilitis;
        Procesos: Codeunit ControlProcesos;

        Panorama: Codeunit Panorama;

        ContabAlb: Codeunit ContabAlb;
    #region Tables
    #region Tabla13
    [EventSubscriber(ObjectType::Table, 13, 'OnBeforeDeleteEvent', '', false, false)]
    LOCAL PROCEDURE Table13_OnDelete(VAR Rec: Record 13; RunTrigger: Boolean)
    BEGIN
        ERROR('No se pueden eliminar vendedores');
    END;
    #endregion Tabla13
    #region Tabla15
    #endregion Tabla15
    #region Tabla17
    [EventSubscriber(ObjectType::Table, Database::"G/L Entry", OnAfterModifyEvent, '', false, false)]
    LOCAL PROCEDURE Tabla17_OnModify(VAR Rec: Record "G/L Entry"; VAR xRec: Record "G/L Entry"; RunTrigger: Boolean)
    VAR
        r21: Record 21;
        r25: Record 25;
        r380: Record 380;
        r379: Record 379;
        r271: Record 271;
    BEGIN

        if RunTrigger THEN BEGIN
            if r21.GET(Rec."Entry No.") THEN BEGIN
                r21."Posting Date" := Rec."Posting Date";
                r21."Bal. Account No." := Rec."Bal. Account No.";
                r21.MODIFY;
                r379.SETCURRENTKEY(r379."Cust. Ledger Entry No.");
                r379.SETRANGE(r379."Cust. Ledger Entry No.", r21."Entry No.");
                r379.MODIFYALL("Posting Date", Rec."Posting Date");
            END;
            if r25.GET(Rec."Entry No.") THEN BEGIN
                r25."Posting Date" := Rec."Posting Date";
                r25."Bal. Account No." := Rec."Bal. Account No.";
                r25.MODIFY;
                r380.SETCURRENTKEY(r380."Vendor Ledger Entry No.");
                r380.SETRANGE(r380."Vendor Ledger Entry No.", r25."Entry No.");
                r380.MODIFYALL("Posting Date", Rec."Posting Date");
            END;
            if r271.GET(Rec."Entry No.") THEN BEGIN
                r271."Posting Date" := Rec."Posting Date";
                r271."Bal. Account No." := Rec."Bal. Account No.";
                r271.MODIFY;
            END;
        END;

    END;

    [EventSubscriber(ObjectType::Table, Database::"G/L Entry", OnAfterDeleteEvent, '', false, false)]
    LOCAL PROCEDURE Tabla17_OnDelete(VAR Rec: Record "G/L Entry"; RunTrigger: Boolean)
    VAR
        r21: Record 21;
        r25: Record 25;
        r380: Record 380;
        r379: Record 379;
        r271: Record 271;
    BEGIN
        //WITH Rec DO BEGIN
        if RunTrigger THEN BEGIN
            if r21.GET(Rec."Entry No.") THEN BEGIN
                r379.SETCURRENTKEY(r379."Cust. Ledger Entry No.");
                r379.SETRANGE(r379."Cust. Ledger Entry No.", r21."Entry No.");
                r379.DELETEALL;
                r21.DELETE;
            END;
            if r25.GET(Rec."Entry No.") THEN BEGIN
                r380.SETCURRENTKEY(r380."Vendor Ledger Entry No.");
                r380.SETRANGE(r380."Vendor Ledger Entry No.", r25."Entry No.");
                r380.DELETEALL;
                r25.DELETE;
            END;
            if r271.GET(Rec."Entry No.") THEN BEGIN
                r271.DELETE;
            END;
        END;
        //END;
    END;

    [EventSubscriber(ObjectType::Table, Database::"G/L Entry", 'OnAfterValidateEvent', 'Amount', false, false)]
    LOCAL PROCEDURE Tabla17_Amount(VAR Rec: Record "G/L Entry"; VAR xRec: Record "G/L Entry"; CurrFieldNo: Integer)
    BEGIN
        //WITH Rec DO BEGIN
        if Rec.Amount > 0 THEN
            Rec."Debit Amount" := Rec.Amount
        ELSE
            Rec."Credit Amount" := -Rec.Amount;
        //  END;
    END;

    [EventSubscriber(ObjectType::Table, Database::"G/L Entry", 'OnAfterValidateEvent', 'Debit Amount', false, false)]
    LOCAL PROCEDURE Tabla17_Debit(VAR Rec: Record "G/L Entry"; VAR xRec: Record "G/L Entry"; CurrFieldNo: Integer)
    BEGIN
        //WITH Rec DO BEGIN
        if Rec."Debit Amount" <> 0 THEN Rec."Credit Amount" := 0;
        Rec.Amount := Rec."Debit Amount" - Rec."Credit Amount";
        //END;
    END;

    [EventSubscriber(ObjectType::Table, Database::"G/L Entry", 'OnAfterValidateEvent', 'Credit Amount', false, false)]
    LOCAL PROCEDURE Tabla17_Credit(VAR Rec: Record "G/L Entry"; VAR xRec: Record "G/L Entry"; CurrFieldNo: Integer)
    BEGIN
        //WITH Rec DO BEGIN
        if Rec."Credit Amount" <> 0 THEN Rec."Debit Amount" := 0;
        Rec.Amount := Rec."Debit Amount" - Rec."Credit Amount";
        // END;
    END;

    #endregion Tabla17
    #region Tabla18
    [EventSubscriber(ObjectType::Table, Database::"Customer", 'OnAfterValidateEvent', 'B2R Cod. Fiscal', false, false)]
    LOCAL PROCEDURE Tabla18_Oficina(VAR Rec: Record Customer; VAR xRec: Record Customer; CurrFieldNo: Integer)
    BEGIN
        if rec."Oficina Contable" = '' Then
            Rec."Oficina Contable" := Rec."B2R Cod. Fiscal";
        Rec."Permite Efactura" := true;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Customer", 'OnAfterValidateEvent', 'B2R Cod. Receptor', false, false)]
    LOCAL PROCEDURE Tabla18_Gestor(VAR Rec: Record Customer; VAR xRec: Record Customer; CurrFieldNo: Integer)
    BEGIN
        Rec."Organo Gestor" := Rec."B2R Cod. Receptor";
    end;

    [EventSubscriber(ObjectType::Table, Database::"Customer", 'OnAfterValidateEvent', 'B2R Cod. Pagador', false, false)]
    LOCAL PROCEDURE Tabla18_Unidad(VAR Rec: Record Customer; VAR xRec: Record Customer; CurrFieldNo: Integer)
    BEGIN
        Rec."Unidad Tramitadora" := Rec."B2R Cod. Pagador";
    end;

    [EventSubscriber(ObjectType::Table, Database::"Customer", 'OnAfterInsertEvent', '', false, false)]
    LOCAL PROCEDURE Tabla18_Insert(VAR Rec: Record Customer)
    begin
        Rec."Fecha de alta" := TODAY;
        Rec."Partner Type" := Rec."Partner Type"::Person;
    end;


    // Crear un evento para la tabla 18 para :OnBeforeValidateVATRegistrationNo
    /// <summary>
    /// OnBeforeValidateVATRegistrationNo.
    /// </summary>
    /// <param name="Customer">VAR Record "Customer".</param>
    /// <param name="xCustomer">Record "Customer".</param>
    /// <param name="FieldNumber">Integer.</param>
    /// <param name="IsHandled">VAR Boolean.</param>
    [EventSubscriber(ObjectType::Table, Database::"Customer", 'OnBeforeValidateVATRegistrationNo', '', false, false)]
    procedure OnBeforeValidateVATRegistrationNo(var Customer: Record "Customer"; xCustomer: Record "Customer"; FieldNumber: Integer; var IsHandled: Boolean)
    var
        Company: Record "Company";
        R18: Record Customer;
        r18T: Record 18 temporary;
        Primero: Boolean;
        Control: Codeunit ControlProcesos;
    begin
        //recorrern la tabla 18 para todas las empresas menos la actual
        Primero := true;
        if Company.FindFirst() then
            repeat
                if Control.Permiso_Empresas(Company.Name) then begin
                    if Company.Name <> CompanyName then
                        r18.ChangeCompany(Company.Name);
                    R18.SetRange("VAT Registration No.", Customer."VAT Registration No.");
                    if R18.FindFirst() then begin
                        if Primero then begin
                            Primero := false;
                            Message('El Nif ya existe en la empresa %1 con el nombre %2 ', Company.Name, R18.Name);
                            if Confirm('¿Quiere recuperar los datos de este cliente? ', true) then begin
                                Customer.Name := R18.Name;
                                Customer."Name 2" := R18."Name 2";
                                Customer.Address := R18.Address;
                                Customer."Address 2" := R18."Address 2";
                                Customer."Post Code" := R18."Post Code";
                                Customer."City" := R18."City";
                                Customer."Country/Region Code" := R18."Country/Region Code";
                                Customer.County := R18.County;
                                Customer."Phone No." := R18."Phone No.";
                                Customer."Fax No." := R18."Fax No.";
                                Customer."E-Mail" := R18."E-Mail";
#if CLEAN24
#pragma warning disable AL0432
#pragma warning disable AL0432
                                Customer."Home Page" := R18."Home Page";
#pragma warning restore AL0432
#pragma warning restore AL0432
#else
#pragma warning disable AL0432
                                Customer."Home Page" := R18."Home Page";
#pragma warning restore AL0432
#endif
                                Customer.Modify();
                                r18T := R18;
                                r18T.Insert();
                                IsHandled := true;
                            end else begin
                                if Confirm('¿Quiere traspasar  los datos de este cliente a las otras empresas? ', true) then begin
                                    r18T := Customer;
                                    r18T.Insert();
                                    IsHandled := true;
                                end else begin
                                    Customer.Delete();
                                    Commit();
                                    Error('No podemos continuar con el proceso, el cliente no se ha creado. Contacte con el administrador ');
                                end;
                                IsHandled := true;
                            end;

                        end else begin
                            R18.Name := r18t.Name;
                            // lo mismo para todos los nombres y datos de direccióm
                            R18."Name 2" := r18t."Name 2";
                            R18.Address := r18t.Address;
                            r18."Address 2" := r18t."Address 2";
                            r18."Post Code" := r18t."Post Code";
                            r18."City" := r18t."City";
                            r18."Country/Region Code" := r18t."Country/Region Code";
                            r18.County := r18t.County;
                            r18."Phone No." := r18t."Phone No.";
                            r18."Fax No." := r18t."Fax No.";
                            r18."E-Mail" := r18t."E-Mail";
#if CLEAN24
#pragma warning disable AL0432
#pragma warning disable AL0432
                            r18."Home Page" := r18t."Home Page";
#pragma warning restore AL0432
#pragma warning restore AL0432
#else
#pragma warning disable AL0432
                            r18."Home Page" := r18t."Home Page";
#pragma warning restore AL0432
#endif

                            R18.Modify();
                        end;
                    end;
                end;
            until Company.Next() = 0;
    end;



    [EventSubscriber(ObjectType::Table, Database::"Customer", 'OnBeforeValidateEvent', 'Nombre Comercial', false, false)]
    local procedure OnAfterValidateEventCust(var Rec: Record "Customer"; xRec: Record "Customer")
    var
        Nombres: Record "Nombre Comercial";
    begin
        if (Rec."Nombre Comercial" <> '') and Not (Nombres.Get(Rec."Nombre Comercial")) Then begin
            if Confirm('Le asignamos como anunciante el nombre del cliente?', False) Then begin
                Nombres.Nombre := Rec."Nombre Comercial";
                if Nombres.Insert() Then;


            end;
        end;
    end;
    #endregion Tabla18
    #region Tabla36

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", OnAfterDeleteEvent, '', false, false)]
    PROCEDURE Tabla36_OnDelete(VAR Rec: Record "Sales Header"; RunTrigger: Boolean)
    VAR
        rLinContrato: Record 37;
        Fac: Record "Purchase Header";
        Lin: Record "Purchase Line";
        SalesLine: Record 37;
        rVenInter: Record "Sales Header";
        rLinVerEntry: Record 37;
    BEGIN
        if Rec."Factura Compra" <> '' Then begin

            if RunTrigger Then
                Error('Hay una factura/abono de compra asociada en una empresa del grupo');
            Fac.ChangeCompany(Rec."Empresa Origen Alb");
            if Not Fac.Get(Rec."Document Type", Rec."Factura Compra") then exit;
            if (Fac."Vendor Invoice No." = '') and (Fac."Vendor Cr. Memo No." = '') Then Begin
                lin.ChangeCompany(Rec."Empresa Origen Alb");
                Lin.SetRange("Document Type", Rec."Document Type");
                Lin.SetRange("Document No.", Fac."No.");
                Lin.DeleteAll();
                Fac.Delete();
            end;
        end;
        SalesLine.Reset();
        SalesLine.SetRange("Document Type", SalesLine."Document Type"::Order);
        SalesLine.SetRange("Document No.", Rec."No.");
        SalesLine.SetFilter("Doc. Itercompany Venta", '<>%1', '');
        if SalesLine.FindFirst() Then
            repeat
                rVenInter.ChangeCompany(SalesLine."Empresa Venta");
                rVenInter.SETRANGE(rVenInter."No.", SalesLine."Doc. Itercompany Venta");
                rLinVerEntry.ChangeCompany(SalesLine."Empresa Venta");
                if rVenInter.FindFirst() Then Begin
                    if Fac.Get(Rec."Document Type", Rec."Factura Compra") Then Begin
                        lin.ChangeCompany(Rec."Empresa Origen Alb");
                        Lin.SetRange("Document Type", Rec."Document Type");
                        Lin.SetRange("Document No.", Fac."No.");
                        Lin.DeleteAll();
                        Fac.Delete();
                    end;
                    rLinVerEntry.SETRANGE(rLinVerEntry."Document No.", rVenInter."No.");
                    rLinVerEntry.SETRANGE(rLinVerEntry."Document Type", rVenInter."Document Type");
                    rLinVerEntry.DeleteAll();
                    rVenInter.Delete();
                end;
            until SalesLine.Next() = 0;
        //WITH Rec DO BEGIN
        //$007(I)
        if Rec."Factura prepago" THEN BEGIN
            rLinContrato.RESET;
            rLinContrato.SETRANGE("Document Type", rLinContrato."Document Type"::Order);
            rLinContrato.SETRANGE("Document No.", Rec."Nº Contrato");
            if rLinContrato.FIND('-') THEN BEGIN            //Pongo a 0 los campos, sólo se factura 1 prepago.
                REPEAT
                    rLinContrato."Prepmt. Amt. Inv." := 0;
                    rLinContrato."Prepmt. Amt. Incl. VAT" := 0;
                    rLinContrato."Prepayment Amount" := 0;
                    rLinContrato."Prepmt. VAT Base Amt." := 0;
                    rLinContrato."Prepmt Amt to Deduct" := 0;
                    rLinContrato."Prepmt. Amount Inv. Incl. VAT" := 0;
                    rLinContrato.MODIFY;
                UNTIL rLinContrato.NEXT = 0;
            END;
        END;
        //$007(F)
        //END;
    END;

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", 'OnAfterValidateEvent', 'Sell-to Customer No.', false, false)]
    LOCAL PROCEDURE Tabla36_SellToCustomerOnValidate(VAR Rec: Record "Sales Header"; VAR xRec: Record "Sales Header"; CurrFieldNo: Integer)
    VAR
        Cust: Record Customer;
        rEnvio: Record 222;
        Contratos: Record "Sales Header";
        PaymentMethod: Record "Payment Method";
    BEGIN
        if Cust.GET(Rec."Sell-to Customer No.") THEN begin
            Rec."Cod cadena" := Cust."Cod cadena";            //$013
            if Rec."Nombre Comercial" = '' Then Rec."Nombre Comercial" := Cust."Nombre Comercial";
            Rec."Nuestra Cuenta" := Cust."Banco transferencia";
            Rec."Nuestra Cuenta Prepago" := Cust."Banco transferencia";
            if PaymentMethod.GET(Cust."Payment Method Code") THEN
                if PaymentMethod."Bill Type" <> PaymentMethod."Bill Type"::Transfer THEN begin
                    Rec."Nuestra Cuenta" := '';
                    Rec."Nuestra Cuenta Prepago" := '';
                end;
        End;
        Contratos.SetRange("Sell-to Customer No.", Rec."Sell-to Customer No.");
        Contratos.SetRange("Document Type", Contratos."Document Type"::Order);
        Contratos.SetFilter("No.", '<>%1', Rec."No.");
        if Not Contratos.FindLast() then begin
            if Cust.GET(Rec."Sell-to Customer No.") THEN begin
                Cust."Cliente Recuperado" := true;
                Cust."Fecha de recuperación" := Today;
                Cust.MODIFY;
            end;
        end else begin
            if Contratos."Order Date" < Calcdate('-2A', Today) then begin
                if Cust.GET(Rec."Sell-to Customer No.") THEN begin
                    Cust."Cliente Recuperado" := true;
                    Cust."Fecha de recuperación" := Today;
                    Cust.MODIFY;
                end;
            end;
        end;
        // MNC 070202
        rEnvio.RESET;
        rEnvio.SETRANGE("Customer No.", Rec."Sell-to Customer No.");
        if rEnvio.FIND('-') THEN
            MESSAGE('Recuerde que este cliente tiene Direcciones de Envio');
        // Fi MNC
    END;

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", 'OnAfterValidateEvent', 'Posting Description', false, false)]
    LOCAL PROCEDURE Tabla36_PostDescr(VAR Rec: Record "Sales Header"; VAR xRec: Record "Sales Header"; CurrFieldNo: Integer)
    VAR
        WorkText: Text;
    BEGIN
        if Rec."Document Type" = rec."Document Type"::Quote then begin
            WorkText := Rec.GetWorkDescription();
            if WorkText = '' then
                Rec.SetWorkDescription(Rec."Posting Description");
        end;
    END;

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", 'OnAfterValidateEvent', 'Bill-to Customer No.', false, false)]
    LOCAL PROCEDURE Tabla36_BillToCustomerOnValidate(VAR Rec: Record "Sales Header"; VAR xRec: Record "Sales Header"; CurrFieldNo: Integer)
    VAR
        Cust: Record Customer;
        PaymentMethod: Record 289;
    BEGIN
        //WITH Rec DO BEGIN
        if Cust.GET(Rec."Bill-to Customer No.") THEN;

        if Rec."Document Type" = Rec."Document Type"::Order THEN
            if Cust.Impagados THEN MESSAGE('Atención: Este cliente tiene impagados');

        //$003
        if PaymentMethod.GET(Rec."Payment Method Code") THEN
            Rec."Remesa sin factura" := PaymentMethod."Remesa sin factura";
        //END;
    END;

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", 'OnAfterValidateEvent', 'Bill-to Customer No.', false, false)]
    LOCAL PROCEDURE Tabla36_PostingDateOnValidate(VAR Rec: Record "Sales Header"; VAR xRec: Record "Sales Header"; CurrFieldNo: Integer)
    VAR
        cProyecTo: Codeunit "Gestion Proyecto";
        Job: Record 167;
    BEGIN
        //WITH Rec DO BEGIN
        CLEAR(cProyecTo);
        if Job.GET(Rec."Nº Proyecto") THEN BEGIN
            if cProyecTo.DebeTraspasarse(Job) THEN
                cProyecTo.CabioFechaContratoDestino(Job, Rec."Posting Date");
        END;
        Rec."Fecha registro prepago" := Rec."Posting Date";
        //END;
    END;

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", 'OnAfterValidateEvent', 'SalesPerson Code', false, false)]
    LOCAL PROCEDURE Tabla36_SalesPersonCodeOnValidate(VAR Rec: Record "Sales Header"; VAR xRec: Record "Sales Header"; CurrFieldNo: Integer)
    VAR
        SalesPerson: Record 13;
    BEGIN
        //WITH Rec DO BEGIN
        SalesPerson.GET(Rec."SalesPerson Code");
        SalesPerson.TestField("E-Mail");
        Rec."Nuevo Vendedor asignado" := Rec."Salesperson Code";

        //END;
    END;


    [EventSubscriber(ObjectType::Table, Database::"Sales Header", 'OnAfterValidateEvent', 'Payment Terms Code', false, false)]
    LOCAL PROCEDURE Tabla36_PaymenTermsCodeOnValidate(VAR Rec: Record "Sales Header"; VAR xRec: Record "Sales Header"; CurrFieldNo: Integer)
    BEGIN
        // WITH Rec DO BEGIN
        //$017
        if xRec."Payment Terms Code" <> '' THEN
            Rec.VALIDATE("Payment Discount %", xRec."Payment Discount %");
        //END;
    END;

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", 'OnAfterValidateEvent', 'Payment Method Code', false, false)]
    LOCAL PROCEDURE Tabla36_PaymenMethodCodeOnValidate(VAR Rec: Record "Sales Header"; VAR xRec: Record "Sales Header"; CurrFieldNo: Integer)
    VAR
        PaymentMethod: Record 289;
        Intercambio: Record Intercambio;
        IntercambioxEmpresa: Record "Intercambio x Empresa";
    BEGIN
        //WITH Rec DO BEGIN
        if PaymentMethod.GET(Rec."Payment Method Code") THEN begin
            Rec."Remesa sin factura" := PaymentMethod."Remesa sin factura";           //$003
            //INTERCAM =  = 
            if Rec."Payment Method Code" = 'INTERCAM' Then begin
                IntercambioxEmpresa.SETRANGE(Empresa, CompanyName);
                IntercambioxEmpresa.SETRANGE(Cliente, Rec."Bill-to Customer No.");
                if IntercambioxEmpresa.FINDfirst Then begin
                    Intercambio.GET(IntercambioxEmpresa."Código Intercambio");
                    Intercambio.Validate(Blocked, Intercambio.Blocked::" ");
                    Intercambio.Modify();
                end;
            end;

        end;
        //END;
    END;

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", 'OnAfterValidateEvent', 'Prepayment %', false, false)]
    LOCAL PROCEDURE Tabla36_PrePaymenPorOnValidate(VAR Rec: Record "Sales Header"; VAR xRec: Record "Sales Header"; CurrFieldNo: Integer)
    VAR
        PaymentMethod: Record 289;
    BEGIN
        //WITH Rec DO BEGIN
        //$009
        if Rec."% prep incl produccion" THEN
            Rec.VALIDATE("% prep incl produccion");
        //END;
    END;


    [EventSubscriber(ObjectType::Table, Database::"Sales Header", 'OnAfterRecreateSalesLine', '', false, false)]
    PROCEDURE Tabla36_RecreateSalesline(VAR SalesLine: Record 37; VAR TempSalesLine: Record 37 TEMPORARY)
    BEGIN

        //< JML 160704
        SalesLine."Job No." := TempSalesLine."Job No.";
        // $001-
        //SalesLine."Phase Code" := TempSalesLine."Phase Code";
        //SalesLine."Task Code" := TempSalesLine."Task Code";
        //SalesLine."Step Code" := TempSalesLine."Step Code";
        SalesLine."Job Task No." := TempSalesLine."Job Task No.";
        // $001+
        //>
        //$018(I)
        SalesLine.VALIDATE("Unit Price", TempSalesLine."Unit Price");
        SalesLine.VALIDATE("Line Discount %", TempSalesLine."Line Discount %");
        SalesLine.VALIDATE("Fecha inicial recurso", TempSalesLine."Fecha inicial recurso");
        SalesLine.VALIDATE("Fecha final recurso", TempSalesLine."Fecha final recurso");
        //$018(F)
    END;//$018(F)
        //END;
    [EventSubscriber(ObjectType::Table, Database::"Sales Header", 'OnBeforeSalesLineByChangedFieldNo', '', false, false)]
    PROCEDURE Tabla36_UpdateSalesline(SalesHeader: Record "Sales Header"; VAR SalesLine: Record 37; ChangedFieldNo: Integer; VAR IsHandled: Boolean)
    BEGIN

        if ChangedFieldNo = SalesLine.FIELDNO("Prepayment %") THEN BEGIN
            if SalesLine."No." <> '' THEN
            //$008(I)
            BEGIN
                if SalesLine.Reparto <> SalesLine.Reparto::"Fra prepago" THEN
                    //$008(F)
                    SalesLine.VALIDATE("Prepayment %", SalesHeader."Prepayment %");
            END;        //$008
        END;
    END;

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", 'OnBeforeValidatePaymentTermsCode', '', false, false)]
    Procedure OnBeforeValidatePaymentTermsCode(var SalesHeader: Record "Sales Header"; var xSalesHeader: Record "Sales Header"; CallingFieldNo: Integer; UpdateDocumentDate: Boolean; var IsHandled: Boolean)
    var
        PaymentTerms: Record "Payment Terms";
        AdjustDueDate: Codeunit "Due Date-Adjust";
        GLSetup: Record "General Ledger Setup";
        SalesSetup: Record "Sales & Receivables Setup";
    begin

        SalesSetup.Get();
        if (SalesHeader."Payment Terms Code" <> '') and (SalesHeader."Document Date" <> 0D) then begin
            PaymentTerms.Get(SalesHeader."Payment Terms Code");
            if SalesHeader.IsCreditDocType() and not PaymentTerms."Calc. Pmt. Disc. on Cr. Memos" then begin
                IsHandled := false;
                if not IsHandled then
                    SalesHeader.Validate("Due Date", SalesHeader."Document Date");
                SalesHeader.Validate("Pmt. Discount Date", 0D);
                SalesHeader.Validate("Payment Discount %", 0);
            end else begin
                IsHandled := false;
                if not IsHandled then begin
                    SalesHeader."Due Date" := CalcDate(PaymentTerms."Due Date Calculation", SalesHeader."Document Date");
                    AdjustDueDate.SalesAdjustDueDate(
                      SalesHeader."Due Date", SalesHeader."Document Date", PaymentTerms.CalculateMaxDueDate(SalesHeader."Document Date"), SalesHeader."Bill-to Customer No.");
                end;
                IsHandled := false;

                if not IsHandled then
                    SalesHeader."Pmt. Discount Date" := CalcDate(PaymentTerms."Discount Date Calculation", SalesHeader."Document Date");
                GLSetup.Get();
                if GLSetup."Payment Discount Type" = GLSetup."Payment Discount Type"::"Calc. Pmt. Disc. on Lines" then
                    SalesHeader.Validate("Prepmt. Payment Discount %", 0)
                else
                    if not UpdateDocumentDate then
                        SalesHeader.Validate("Prepmt. Payment Discount %", PaymentTerms."Discount %");
                if not UpdateDocumentDate then
                    SalesHeader.Validate("Payment Discount %", PaymentTerms."Discount %");
            end;
        end else begin
            IsHandled := false;

            if not IsHandled then
                SalesHeader.Validate("Due Date", SalesHeader."Document Date");
            if not UpdateDocumentDate then begin
                SalesHeader.Validate("Pmt. Discount Date", 0D);
                SalesHeader.Validate("Payment Discount %", 0);
            end;
        end;
        if xSalesHeader."Prepmt. Payment Terms Code" = '' Then
            SalesHeader.Validate("Prepmt. Payment Terms Code", SalesSetup."Prepay. Terms Code");

        IsHandled := true;
    end;

    local procedure ComprobarSaldoVencidoClientes(Contrato: Record "Sales Header")
    var
        Cliente: Record Customer;
        ClientesCadena: Record Customer;
    begin
        if Cliente.Get(Contrato."Bill-to Customer No.") then begin
            Cliente.CalcFields("Balance Due");
            if Cliente."Balance Due" > 0 then begin
                Message('El cliente %1 tiene un saldo vencido de %2', Cliente."No.", Cliente."Balance Due");
            end;
        end;
        If Cliente."Chain Name" <> '' then begin
            ClientesCadena.SetRange("Chain Name", Cliente."Chain Name");
            if ClientesCadena.FindFirst() then
                repeat
                    ClientesCadena.CalcFields("Balance Due");
                    if ClientesCadena."Balance Due" > 0 then begin
                        Message('El cliente %1 que pertenece a la cadenA %2, tiene un saldo vencido de %3', ClientesCadena."No.", Cliente."Chain Name", ClientesCadena."Balance Due");
                    end;
                until ClientesCadena.Next = 0;
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", 'OnBeforeValidatePrepmtPaymentTermsCode', '', false, false)]
    local procedure OnBeforeValidatePrepmtPaymentTermsCode(var SalesHeader: Record "Sales Header"; var xSalesHeader: Record "Sales Header"; CalledByFieldNo: Integer; CallingFieldNo: Integer; UpdateDocumentDate: Boolean; var IsHandled: Boolean)
    var
        PaymentTerms: Record "Payment Terms";
        AdjustDueDate: Codeunit "Due Date-Adjust";
        GLSetup: Record "General Ledger Setup";
        SalesSetup: Record "Sales & Receivables Setup";
    begin
        SalesSetup.Get();
        If SalesHeader."Document Type" <> SalesHeader."Document Type"::Order then exit;
        IsHandled := true;
        SalesHeader."Prepmt. Payment Terms Code" := SalesSetup."Prepay. Terms Code";
        if (SalesHeader."Prepmt. Payment Terms Code" <> '') and (SalesHeader."Document Date" <> 0D) then begin
            PaymentTerms.Get(SalesHeader."Prepmt. Payment Terms Code");
            if SalesHeader.IsCreditDocType() and not PaymentTerms."Calc. Pmt. Disc. on Cr. Memos" then begin
                SalesHeader.Validate("Prepayment Due Date", SalesHeader."Document Date");
                SalesHeader.Validate("Prepmt. Pmt. Discount Date", 0D);
                SalesHeader.Validate("Prepmt. Payment Discount %", 0);
            end else begin
                if not IsHandled then begin
                    SalesHeader."Prepayment Due Date" := CalcDate(PaymentTerms."Due Date Calculation", SalesHeader."Document Date");
                    AdjustDueDate.SalesAdjustDueDate(
                      SalesHeader."Prepayment Due Date", SalesHeader."Document Date", PaymentTerms.CalculateMaxDueDate(SalesHeader."Document Date"), SalesHeader."Bill-to Customer No.");
                end;
                SalesHeader."Prepmt. Pmt. Discount Date" := CalcDate(PaymentTerms."Discount Date Calculation", SalesHeader."Document Date");
                GLSetup.Get();
                if GLSetup."Payment Discount Type" = GLSetup."Payment Discount Type"::"Calc. Pmt. Disc. on Lines" then
                    SalesHeader.Validate("Prepmt. Payment Discount %", 0)
                else begin
                    if not UpdateDocumentDate then
                        SalesHeader.Validate("Prepmt. Payment Discount %", PaymentTerms."Discount %");
                end;
            end;
        end else begin
            SalesHeader.Validate("Prepayment Due Date", SalesHeader."Document Date");
            if not UpdateDocumentDate then begin
                SalesHeader.Validate("Prepmt. Pmt. Discount Date", 0D);
                SalesHeader.Validate("Prepmt. Payment Discount %", 0);
            end;
        end;
    end;



    [EventSubscriber(ObjectType::Table, Database::"Sales Header", 'OnAfterValidateEvent', 'Estado', false, false)]
    PROCEDURE Tabla36_EstadoOnValidate(VAR Rec: Record "Sales Header"; VAR xRec: Record "Sales Header"; CurrFieldNo: Integer)
    VAR
        FecAnul: Date;
        Ventana: Page "Dialogo fecha anulación";
        FecFin: Date;
        rProy: Record 167;
        rRes: Record Reserva;
        Gest_dll: Codeunit "Gestion Reservas";
        rDiari: Record "Diario Reserva";
        r36: Record "Sales Header";
        rVenInter: Record "Sales Header";
        rLinVerEntry: Record 37;
        Fac: Record "Purchase Header";
        lin: Record "Purchase Line";
        r120: Record "Purch. Rcpt. Header";
        c90: Codeunit "Purch.-Post";
        rCar: Record 7000002;
        Proy: Record Job;
        r70002: Record 7000002;
        Gest_Fac: Codeunit "Gestion Facturación";
        SalesLine: Record 37;
        ReleaseSalesDoc: Codeunit "Release Sales Document";
        Resource: Record Resource;
    BEGIN

        if (xRec.Estado = Rec.Estado::"Sin Montar") OR (xRec.Estado = Rec.Estado::Firmado) THEN
            if Rec.Estado = Rec.Estado::"Pendiente de Firma" THEN ERROR('No se puede regrersar a un estado anterior');
        //WITH Rec DO BEGIN
        if ((Rec.Estado = Rec.Estado::Firmado) OR (Rec.Estado = Rec.Estado::"Sin Montar"))
        AND (Rec."Albarán Empresa Origen" = '') THEN BEGIN
            Rec.TESTFIELD("Comentario Cabecera");
            ComprobarSaldoVencidoClientes(Rec);
            Rec."Fecha renovacion" := 0D;
            if Rec."Shortcut Dimension 1 Code" <> 'GENERAL' THEN begin
                //si todal las lineas del pryecto de tipo recurso son de produccion, la fecha de renovacion se deja en blanco
                SalesLine.SETRANGE("Document Type", SalesLine."Document Type"::Order);
                SalesLine.SETRANGE("Document No.", Rec."No.");
                SalesLine.SetRange(Type, SalesLine.Type::Resource);
                if SalesLine.FindFirst() then
                    repeat
                        if Resource.Get(SalesLine."No.") then
                            if Not Resource.Producción then
                                if not Rec."Contrato No Renovable" Then
                                    if (Rec.Estado = Rec.Estado::Firmado) THEN Rec.VALIDATE("Fecha renovacion", Rec."Fecha fin proyecto");
                    until SalesLine.Next() = 0;

            end;
            if (xRec.Estado <> Rec.Estado::"Sin Montar") AND (xRec.Estado <> Rec.Estado::Firmado) THEN begin          //$016
                Rec."Fecha Estado" := WORKDATE;
                FechaRenovacion(Rec."Nº Proyecto", Rec."Fecha Comparación", Rec."Fecha Estado");
            end;
            if Rec."Pedido compra creado" = FALSE THEN
                Procesos.GenerarContratoCompra(Rec);
        END;
        //$012(I)
        if Rec.Estado = Rec.Estado::Cancelado THEN
            Rec."Fecha cancelacion" := WORKDATE;         //de momento no inicializo fecha si cambia a otro estado
                                                         //$012(F)
        if ((Rec.Estado = Rec.Estado::Anulado) OR (Rec.Estado = Rec.Estado::Modificado)) OR (Rec.Estado = Rec.Estado::Cancelado) OR (Rec.Estado = Rec.Estado::Modificado) THEN BEGIN
            if CONFIRM('Se van a eliminar todas las facturas que esten en borrador \'
            + 'con fecha porterior a la solicitada, las demás deberán borrarse manualmente \'
            + 'se solicitará la fecha para anular las reservas asociadas al proyecto,\'
            + 'en el caso de anulación borrará las reservas asociadas al proyecto,\'
            + 'así mismo, se marcarán como facturados todos los albaranes posteriores \'
            + 'a fecha de anulación y, se procederá a descontabilizarlos. Los albaranes con \'
            + 'fecha anterior a la de anulación, deben anularse manualmete.¿ Desea continuar ?', TRUE)
            THEN BEGIN
                FecAnul := WORKDATE;
                Ventana.SetCampos(FecAnul, FecFin);// .OPEN('Fecha Anulación #######1#');
                Ventana.RunModal();
                Ventana.GetCampos(FecAnul, FecFin);

                if Rec.Estado = Rec.Estado::Cancelado THEN
                    Rec."Fecha cancelacion" := FecAnul;
                if (Rec.Estado = Rec.Estado::Anulado) OR (Rec.Estado = Rec.Estado::Modificado) THEN
                    Rec."Fecha cancelacion" := FecAnul;
                If ((Rec.Estado = Rec.Estado::Anulado) OR (Rec.Estado = Rec.Estado::Modificado)) and (Rec."Estado Firma Electrónica" <> Rec."Estado Firma Electrónica"::Pending)
                    THEN
                    error('El contrato no se puede anular si previamente no se cancela la firma electrónica');

                /* Ventana .OPEN('Fecha Fin Reservas -si es anulación no la tentrá en cuenta - #######1#');
                Ventana.INPUT(1, FecFin);
                Ventana.CLOSE; */
                if FecAnul = 0D THEN ERROR('La fecha anulación/modificación no puede quedar en blanco');
                if FecFin = 0D THEN ERROR('La fecha fin no puede quedar en blanco');
                if rProy.GET(Rec."Nº Proyecto") THEN BEGIN
                    rRes.SETCURRENTKEY(rRes."Nº Proyecto");
                    rRes.SETRANGE(rRes."Nº Proyecto", Rec."Nº Proyecto");
                    if rRes.FINDFIRST THEN BEGIN
                        CLEAR(Gest_dll);
                        REPEAT
                            if Rec.Estado = Rec.Estado::Cancelado THEN BEGIN
                                if rRes."Fecha fin" > FecFin THEN
                                    Gest_dll.Cambia_Fecha_Fin_Reserva(rRes, FecFin);
                            END;
                            if (Rec.Estado = Rec.Estado::Anulado) OR (Rec.Estado = Rec.Estado::Modificado) THEN BEGIN
                                rDiari.RESET;
                                rDiari.SETCURRENTKEY("Nº Reserva", Fecha);
                                rDiari.SETRANGE("Nº Reserva", rRes."Nº Reserva");
                                rDiari.DELETEALL;
                            END;
                        UNTIL rRes.NEXT = 0;
                    END;
                    if (Rec.Estado = Rec.Estado::Anulado) OR (Rec.Estado = Rec.Estado::Modificado) THEN rRes.DELETEALL;
                END;
                r36.SETRANGE(r36."Document Type", r36."Document Type"::Invoice);
                r36.SETRANGE("Nº Contrato", Rec."No.");
                r36.SETRANGE("Nº Proyecto", Rec."Nº Proyecto");
                r36.SETRANGE(r36."Posting Date", FecAnul, 29991231D);
                if r36.FINDFIRST THEN
                    REPEAT
                        rCar.SETRANGE(rCar."No. Borrador factura", r36."No.");
                        rCar.SETFILTER(rCar."Bill Gr./Pmt. Order No.", '<>%1', '');
                        rCar.DELETEALL;

                    UNTIL r36.NEXT = 0;
                r36.DELETEALL(TRUE);

                r36.SETRANGE(r36."Document Type", r36."Document Type"::"Credit Memo");
                r36.DELETEALL(TRUE);
                if Rec."Nº Proyecto" <> '' THEN BEGIN
                    r120.SETRANGE(r120."Nº Proyecto", Rec."Nº Proyecto");
                    r120.SETRANGE(r120."Posting Date", FecAnul, 99991231D);
                    if r120.FINDFIRST THEN
                        REPEAT
                            CLEAR(c90);
                            if r120.Facturado = FALSE THEN
                                ContabAlb.DesContabilizarAlbaranesContra(r120);
                            ContoldeProcesos.MarcarComofacturado(r120."No.");
                            r120.Facturado := TRUE;
                            r120.Contabilizado := TRUE;
                            r120.MODIFY;
                        UNTIL r120.NEXT = 0;
                END;
                //r120.DELETEALL;
                r70002.SETFILTER(r70002."Document No.", '%1', Rec."No." + '*');
                r70002.SETRANGE(r70002."Posting Date", FecAnul, 99991231D);
                r70002.DELETEALL;
                CLEAR(Gest_Fac);
                Gest_Fac.GeneraContrasientoprepago(Rec, FecAnul);
            END;
        END;
        //END;
        //$011(I)
        if (Rec.Estado = Rec.Estado::Firmado) OR (Rec.Estado = Rec.Estado::Anulado) OR (Rec.Estado = Rec.Estado::Cancelado) OR (Rec.Estado = Rec.Estado::Modificado) THEN BEGIN
            Rec.MODIFY;
            SalesLine.SETRANGE("Document Type", SalesLine."Document Type"::Order);
            SalesLine.SETRANGE("Document No.", Rec."No.");
            if NOT SalesLine.ISEMPTY THEN
                ReleaseSalesDoc.PerformManualRelease(Rec);
        END;
        FirmaContratosEntreEmpresas(Rec, Rec.Estado);
        //$011(F)
    END;

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", 'OnBeforeIsApprovedForPosting', '', false, false)]
    local procedure OnBeforeIsApprovedForPosting(var SalesHeader: Record "Sales Header"; var Approved: Boolean; var IsHandled: Boolean)
    var
        SalesLine: Record 37;
        SalesSLine: Record 111;
        SalesLine2: Record 37;
        SalesLine3: Record 37 temporary;
        SalesComentLine: Record "Sales Comment Line";
        SalesComentLine2: Record "Sales Comment Line";
        SalesHeader2: Record "Sales Header";
        SalesHeader3: Record "Sales Header" temporary;
        C80: Codeunit 80;
        Contab: Codeunit ContabAlb;
        Alb: Record 110;
        Setup: Record 311;
        Cust: Record Customer;
    begin
        Setup.Get;
        if Setup."Activar Cont a 0" = false then exit;

        if SalesHeader."Document Type" in [SalesHeader."Document Type"::Invoice, SalesHeader."Document Type"::"Credit Memo"] then begin
            Cust.Get(SalesHeader."Bill-to Customer No.");
            SalesHeader.CalcFields(Amount, "Amount Including VAT");
            if (Round(SalesHeader.Amount, 0.01, '=') = 0) And
            (Round(SalesHeader."Amount Including VAT", 0.01, '=') <> 0) then
                Error('La factura/albarán es 0, pero tiene Iva');
            if Cust."Generar facturas a 0" Then exit;
            if ABS(SalesHeader."Amount Including VAT") < 1 Then begin
                if Not Confirm('Esta factura va a generar apuntes contables de anulación de anticipo, ¿Desea continuar?', false) then begin
                    Approved := false;
                end;
                IsHandled := true;
                Approved := false;
                SalesLine.SetRange(SalesLine."Document Type", SalesHeader."Document Type");
                SalesLine.SetRange(SalesLine."Document No.", SalesHeader."No.");
                SalesLine2.SetRange(SalesLine2."Document Type", SalesLine2."Document Type"::Order);
                SalesLine2.SetRange(SalesLine2."Document No.", SalesHeader."No.");
                SalesLine2.DeleteAll();
                if SalesLine.FindFirst() Then
                    repeat
                        SalesLine2 := SalesLine;
                        SalesLine2."Document Type" := SalesLine."Document Type"::Order;
                        SalesLine2."Qty. to Invoice" := 0;
                        SalesLine2."Qty. to Ship" := SalesLine.Quantity;
                        SalesLine2."Qty. to Invoice (Base)" := SalesLine."Quantity (Base)";
                        SalesLine2."Qty. to Invoice (Base)" := 0;
                        SalesLine2."Job No." := '';
                        SalesLine2.Insert();
                        SalesLine3 := SalesLine;
                        SalesLine3.Insert();
                    until SalesLine.Next() = 0;
                SalesLine.DeleteAll();
                if SalesHeader2.get(SalesHeader2."Document Type"::Order, SalesHeader."No.") then
                    SalesHeader2.Delete();
                SalesHeader2 := SalesHeader;
                SalesHeader2."Document Type" := SalesHeader."Document Type"::Order;
                SalesHeader2.Ship := true;
                SalesHeader2.Invoice := false;
                SalesHeader2.Insert();
                SalesHeader3 := SalesHeader;
                SalesHeader3.Insert();
                SalesHeader.Delete();
                SalesHeader := SalesHeader2;
                Commit();
                SalesHeader.SetRange(SalesHeader."No.", SalesHeader."No.");
                SalesHeader.SetRange(SalesHeader."Document Type", SalesHeader."Document Type"::Order);
                if C80.Run(SalesHeader) then begin
                    alb.Get(salesheader."Last Shipping No.");
                    Alb.SetRange("No.", SalesHeader."Last Shipping No.");
                    SalesSLine.SetRange("Document No.", SalesHeader."Last Shipping No.");
                    if SalesSLine.FindFirst() Then
                        repeat
                            if SalesSLine."Line Amount" = 0 Then begin
                                SalesSLine."Line Amount" := SalessLine."Unit Price" * SalessLine.Quantity * (1 - (SalessLine."Line Discount %" / 100));
                                SalesSLine.Amount := SalessLine."Line Amount";
                                SalesSLine."Amount Including VAT" := SalessLine.Amount * (1 + SalessLine."VAT %" / 100);
                            end;
                            SalesSLine.Modify();
                        until SalesSLine.Next() = 0;
                    commit;
                    If Contab.ContaAlbVenta(SalesHeader, true) Then Begin
                        SalesLine2.SetRange(SalesLine2."Document Type", SalesLine2."Document Type"::Order);
                        SalesLine2.SetRange(SalesLine2."Document No.", SalesHeader."No.");
                        SalesLine2.DeleteAll();
                        SalesHeader.Delete();
                    end else begin
                        SalesLine.SetRange(SalesLine."Document Type", SalesHeader."Document Type");
                        SalesLine.SetRange(SalesLine."Document No.", SalesHeader."No.");
                        SalesLine.DeleteAll();
                        if SalesLine3.FindFirst() Then
                            repeat
                                SalesLine := SalesLine3;
                                SalesLine.Insert();

                            until SalesLine3.Next() = 0;
                        SalesHeader := SalesHeader3;
                        SalesHeader.Insert();
                        Commit();
                        Error(GetLastErrorText(false));

                    end;
                end else begin

                    SalesLine.SetRange(SalesLine."Document Type", SalesHeader."Document Type");
                    SalesLine.SetRange(SalesLine."Document No.", SalesHeader."No.");
                    SalesLine.DeleteAll();
                    if SalesLine3.FindFirst() Then
                        repeat
                            SalesLine := SalesLine3;
                            SalesLine.Insert();

                        until SalesLine3.Next() = 0;
                    SalesHeader := SalesHeader3;
                    SalesHeader.Insert();
                    Commit();
                    Error(GetLastErrorText(false));
                end;

            end;
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", 'OnAfterValidateEvent', 'Estado Contrato', false, false)]
    LOCAL PROCEDURE Tabla36_EstadoContratoOnValidate(VAR Rec: Record "Sales Header"; VAR xRec: Record "Sales Header"; CurrFieldNo: Integer)
    VAR
        FecAnul: Date;
        Ventana: Page "Dialogo fecha anulación";
        FecFin: Date;
        rProy: Record 167;
        rRes: Record Reserva;
        Gest_dll: Codeunit "Gestion Reservas";
        rDiari: Record "Diario Reserva";
        r36: Record "Sales Header";
        r120: Record "Purch. Rcpt. Header";
        c90: Codeunit "Purch.-Post";
        rCar: Record 7000002;
        r70002: Record 7000002;
        Gest_Fac: Codeunit "Gestion Facturación";
        SalesLine: Record 37;
        ReleaseSalesDoc: Codeunit "Release Sales Document";
        Text063: Label 'Se ha modifcado porcentaje prepago en cabecera y líneas.';
        SalesPostPrepmt: Codeunit 442;
        wTotContrato: Decimal;
        wTotExcluido: Decimal;
        Resource: Record Resource;
        Reservas: Record "Diario Reserva";
    BEGIN
        Reservas.SetCurrentKey(Reservas."Nº Proyecto");
        Reservas.SETRANGE("Nº Proyecto", Rec."Nº Proyecto");
        Reservas.ModifyAll("Estado Contrato", Rec."Estado Contrato");
        Reservas.ModifyAll(Contrato, Rec."No.");
        if (xRec.Estado = Rec.Estado::"Sin Montar") OR (xRec.Estado = Rec.Estado::Firmado) THEN
            if Rec.Estado = Rec.Estado::"Pendiente de Firma" THEN ERROR('No se puede regrersar a un estado anterior');

        //  WITH Rec DO BEGIN

        if ((Rec.Estado = Rec.Estado::Firmado) OR (Rec.Estado = Rec.Estado::"Sin Montar"))
        AND (Rec."Albarán Empresa Origen" = '') THEN BEGIN
            Rec.TESTFIELD("Comentario Cabecera");
            if Rec."Shortcut Dimension 1 Code" <> 'GENERAL' THEN
                SalesLine.SETRANGE("Document Type", SalesLine."Document Type"::Order);
            SalesLine.SETRANGE("Document No.", Rec."No.");
            SalesLine.SetRange(Type, SalesLine.Type::Resource);
            Rec."Fecha renovacion" := 0D;
            if SalesLine.FindFirst() then
                repeat
                    if Resource.Get(SalesLine."No.") then
                        if Not Resource.Producción then
                            if not Rec."Contrato No Renovable" Then
                                if (Rec.Estado = Rec.Estado::Firmado) THEN Rec.VALIDATE("Fecha renovacion", Rec."Fecha fin proyecto");
                until SalesLine.Next() = 0;
            if (xRec.Estado <> Rec.Estado::"Sin Montar") AND (xRec.Estado <> Rec.Estado::Firmado) THEN           //$016
                Rec."Fecha Estado" := WORKDATE;
            if Rec."Pedido compra creado" = FALSE THEN
                Procesos.GenerarContratoCompra(Rec);
        END;
        //$012(I)
        if Rec.Estado = Rec.Estado::Cancelado THEN
            Rec."Fecha cancelacion" := WORKDATE;         //de momento no inicializo fecha si cambia a otro estado
                                                         //$012(F)
        if ((Rec.Estado = Rec.Estado::Anulado) OR (Rec.Estado = Rec.Estado::Modificado)) OR (Rec.Estado = Rec.Estado::Cancelado) OR (Rec.Estado = Rec.Estado::Modificado) THEN BEGIN
            if CONFIRM('Se van a eliminar todas las facturas que esten en borrador \'
            + 'con fecha porterior a la solicitada, las demás deberán borrarse manialmente \'
            + 'se solicitará la fecha para anular las reservas asociadas al proyecto,\'
            + 'en el caso de anulación borrará las reservas asociadas al proyecto,\'
            + 'así mismo, se marcarán como facturados todos los albaranes posteriores \'
            + 'a fecha de anulación y, se procederá a descontabilizarlos. Los albaranes con \'
            + 'fecha anterior a la de anulación, deben anularse manualmete.¿ Desea continuar ?', TRUE)
            THEN BEGIN
                FecAnul := WORKDATE;
                /*  Ventana.OPEN('Fecha Anulación #######1#');
                Ventana.INPUT(1, FecAnul);
                Ventana.CLOSE; */
                Ventana.SetCampos(FecAnul, FecFin);// .OPEN('Fecha Anulación #######1#');
                Ventana.RunModal();
                Ventana.GetCampos(FecAnul, FecFin);
                if Rec.Estado = Rec.Estado::Cancelado THEN
                    Rec."Fecha cancelacion" := FecAnul;
                if (Rec.Estado = Rec.Estado::Anulado) OR (Rec.Estado = Rec.Estado::Modificado) THEN
                    Rec."Fecha cancelacion" := FecAnul;

                /* Ventana.OPEN('Fecha Fin Reservas -si es anulación no la tentrá en cuenta - #######1#');
                Ventana.INPUT(1, FecFin);
                Ventana.CLOSE; */
                If ((Rec.Estado = Rec.Estado::Anulado) OR (Rec.Estado = Rec.Estado::Modificado)) and (Rec."Estado Firma Electrónica" <> Rec."Estado Firma Electrónica"::Pending)
                    THEN
                    error('El contrato no se puede anular si previamente no se cancela la firma electrónica');
                if FecAnul = 0D THEN ERROR('La fecha anulación no puede quedar en blanco');
                if FecFin = 0D THEN ERROR('La fecha fin no puede quedar en blanco');
                if rProy.GET(Rec."Nº Proyecto") THEN BEGIN
                    rRes.SETCURRENTKEY(rRes."Nº Proyecto");
                    rRes.SETRANGE(rRes."Nº Proyecto", Rec."Nº Proyecto");
                    if rRes.FINDFIRST THEN BEGIN
                        CLEAR(Gest_dll);
                        REPEAT
                            if Rec.Estado = Rec.Estado::Cancelado THEN BEGIN
                                if rRes."Fecha fin" > FecFin THEN
                                    Gest_dll.Cambia_Fecha_Fin_Reserva(rRes, FecFin);
                            END;
                            if (Rec.Estado = Rec.Estado::Anulado) OR (Rec.Estado = Rec.Estado::Modificado) THEN BEGIN
                                rDiari.RESET;
                                rDiari.SETCURRENTKEY("Nº Reserva", Fecha);
                                rDiari.SETRANGE("Nº Reserva", rRes."Nº Reserva");
                                rDiari.DELETEALL;
                            END;
                        UNTIL rRes.NEXT = 0;
                    END;
                    if (Rec.Estado = Rec.Estado::Anulado) OR (Rec.Estado = Rec.Estado::Modificado) THEN rRes.DELETEALL;
                END;
                r36.SETRANGE(r36."Document Type", r36."Document Type"::Invoice);
                r36.SETRANGE("Nº Contrato", Rec."No.");
                r36.SETRANGE("Nº Proyecto", Rec."Nº Proyecto");
                r36.SETRANGE(r36."Posting Date", FecAnul, 29991231D);
                if r36.FINDFIRST THEN
                    REPEAT
                        rCar.SETRANGE(rCar."No. Borrador factura", r36."No.");
                        rCar.SETFILTER(rCar."Bill Gr./Pmt. Order No.", '<>%1', '');
                        rCar.DELETEALL;
                    UNTIL r36.NEXT = 0;
                r36.DELETEALL(TRUE);
                r36.SETRANGE(r36."Document Type", r36."Document Type"::"Credit Memo");
                r36.DELETEALL(TRUE);
                if Rec."Nº Proyecto" <> '' THEN BEGIN
                    r120.SETRANGE(r120."Nº Proyecto", Rec."Nº Proyecto");
                    r120.SETRANGE(r120."Posting Date", FecAnul, 99991231D);
                    if r120.FINDFIRST THEN
                        REPEAT
                            if r120.Facturado = FALSE THEN
                                ContabAlb.DesContabilizarAlbaranesContra(r120);
                            ContoldeProcesos.MarcarComofacturado(r120."No.");
                            r120.Facturado := TRUE;
                            r120.Contabilizado := TRUE;
                            r120.MODIFY;//$009

                        UNTIL r120.NEXT = 0;
                END;
                //r120.DELETEALL;
                r70002.SETFILTER(r70002."Document No.", '%1', Rec."No." + '*');
                r70002.SETRANGE(r70002."Posting Date", FecAnul, 99991231D);
                r70002.DELETEALL;
                CLEAR(Gest_Fac);
                Gest_Fac.GeneraContrasientoprepago(Rec, FecAnul);
            END;
        END;

        //$011(I)
        if (Rec.Estado = Rec.Estado::Firmado) OR (Rec.Estado = Rec.Estado::Anulado) OR (Rec.Estado = Rec.Estado::Cancelado) OR (Rec.Estado = Rec.Estado::Modificado) THEN BEGIN
            Rec.MODIFY;
            SalesLine.SETRANGE("Document Type", SalesLine."Document Type"::Order);
            SalesLine.SETRANGE("Document No.", Rec."No.");
            if NOT SalesLine.ISEMPTY THEN
                ReleaseSalesDoc.PerformManualRelease(Rec);
        END;
        //$011(F)
        //  END;
    END;

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", 'OnAfterValidateEvent', 'Fecha Estado', false, false)]
    LOCAL PROCEDURE Tabla36_FechaEstadoOnValidate(VAR Rec: Record "Sales Header"; VAR xRec: Record "Sales Header"; CurrFieldNo: Integer)
    VAR
        rConfigProy: Record 315;
        Text062: Label 'La fecha de estado no se puede cambiar una vez puesta.';
    BEGIN
        rConfigProy.GET();
        if NOT rConfigProy."Poder modificar fecha firmado" THEN BEGIN
            if ((Rec."Fecha Estado" <> xRec."Fecha Estado") AND
                (xRec."Fecha Estado" <> 0D)) THEN
                ERROR(Text062);
        END;
    END;

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", 'OnAfterValidateEvent', '% prep incl produccion', false, false)]
    LOCAL PROCEDURE Tabla36_PorProduccionOnValidate(VAR Rec: Record "Sales Header"; VAR xRec: Record "Sales Header"; CurrFieldNo: Integer)
    VAR
        Text063: Label 'Se ha modifcado porcentaje prepago en cabecera y líneas.';
        SalesPostPrepmt: Codeunit 442;
        wTotContrato: Decimal;
        wTotExcluido: Decimal;
        rLinContrato: Record 37;
    BEGIN
        //$009
        if CurrFieldNo <> Rec.FieldNo("% prep incl produccion") then exit;

        if NOT Rec."% prep incl produccion" THEN BEGIN
            Rec."Prepayment %" := Rec."% prep antes recalculo";
            Rec."% prep antes recalculo" := 0;

            Rec.UpdateSalesLines(Rec.FIELDCAPTION("Prepayment %"), CurrFieldNo <> 0);

            //$009
            if Rec."% prep incl produccion" THEN
                Rec.VALIDATE("% prep incl produccion");
        END
        ELSE BEGIN
            MESSAGE(Text063);
            wTotContrato := 0;
            wTotExcluido := 0;
            rLinContrato.RESET;
            rLinContrato.SETRANGE("Document Type", Rec."Document Type");
            rLinContrato.SETRANGE("Document No.", Rec."No.");
            rLinContrato.SETFILTER(Type, '<>%1', rLinContrato.Type::" ");
            rLinContrato.SETFILTER("Line Amount", '<>0');
            if rLinContrato.FIND('-') THEN BEGIN
                REPEAT
                    wTotContrato := wTotContrato + rLinContrato."Line Amount";
                    if rLinContrato.Reparto = rLinContrato.Reparto::"Fra prepago" THEN
                        wTotExcluido := wTotExcluido + rLinContrato."Line Amount";
                UNTIL rLinContrato.NEXT = 0;
            END;
            REC.VALIDATE("% prep antes recalculo", Rec."Prepayment %");
            Rec."Prepayment %" := Rec.UpdatePrepmtAmountOnSaleslines(Rec, ROUND(wTotContrato * Rec."Prepayment %" / 100) - wTotExcluido);

        END;

    END;

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", 'OnAfterValidateEvent', 'Nº Proyecto', false, false)]
    LOCAL PROCEDURE Table36_OnValidatePyoyecto(VAR Rec: Record "Sales Header"; VAR xRec: Record "Sales Header"; CurrFieldNo: Integer)
    VAR
        rProy: Record 167;
    BEGIN
        // $001 -
        Rec.MessageIfSalesLinesExist(Rec.FIELDCAPTION(Rec."Nº Proyecto"));

        // MNC 220802
        if (Rec."Nº Proyecto" <> '') THEN BEGIN
            rProy.GET(Rec."Nº Proyecto");
            Rec.Tipo := rProy.Tipo;
            Rec.Firmado := rProy.Firmado;
            Rec.Subtipo := rProy.Subtipo;
            Rec."Soporte de" := rProy."Soporte de";
        END;

        // $001 +

    END;

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", 'OnAfterValidateEvent', 'Prepayment %', false, false)]
    LOCAL PROCEDURE Tabla36_Prepayment(VAR Rec: Record "Sales Header"; VAR xRec: Record "Sales Header"; CurrFieldNo: Integer)
    VAR
        SalesPostPrepmt: Codeunit 442;
        wTotContrato: Decimal;
        wTotExcluido: Decimal;
        Text063: Label 'Se ha modifcado porcentaje prepago en cabecera y líneas.';
        rLinContrato: Record 37;
    BEGIN

        Rec.UpdateSalesLines(Rec.FIELDCAPTION("Prepayment %"), CurrFieldNo <> 0);

        //$009
        if Rec."% prep incl produccion" THEN
            Rec.VALIDATE("% prep incl produccion");
        // if NOT Rec."% prep incl produccion" THEN BEGIN
        // Rec."Prepayment %", Rec."% prep antes recalculo";
        // Rec.VALIDATE("% prep antes recalculo", 0);
        // END
        // ELSE BEGIN
        //     MESSAGE(Text063);
        //     wTotContrato := 0;
        //     wTotExcluido := 0;
        //     rLinContrato.RESET;
        //     rLinContrato.SETRANGE("Document Type", Rec."Document Type");
        //     rLinContrato.SETRANGE("Document No.", Rec."No.");
        //     rLinContrato.SETFILTER(Type, '<>%1', rLinContrato.Type::" ");
        //     rLinContrato.SETFILTER("Line Amount", '<>0');
        //     if rLinContrato.FIND('-') THEN BEGIN
        //         REPEAT
        //             wTotContrato := wTotContrato + rLinContrato."Line Amount";
        //             if rLinContrato.Reparto = rLinContrato.Reparto::"Fra prepago" THEN
        //                 wTotExcluido := wTotExcluido + rLinContrato."Line Amount";
        //         UNTIL rLinContrato.NEXT = 0;
        //     END;
        //     Rec.VALIDATE("% prep antes recalculo", Rec."Prepayment %");
        //     SalesPostPrepmt.UpdatePrepmtAmountOnSaleslines(Rec, ROUND(wTotContrato * Rec."Prepayment %" / 100) - wTotExcluido);
        // END;
    END;

    #endregion Tabla36
    #region Tabla37
    [EventSubscriber(ObjectType::Table, Database::"Sales Line", 'OnBeforeCheckPrepmtAmounts', '', false, false)]
    local procedure OnBeforeCheckPrepmtAmounts(var SalesLine: Record "Sales Line"; var IsHandled: Boolean)
    var
        RemLineAmountToInvoice: Decimal;
        CannotChangePrepaidServiceChargeErr: Label 'You cannot change the line because it will affect service charges that are already invoiced as part of a prepayment.';
        CannotChangePrepaidServiceChargeErrEsp: Label 'No puede modificar la línea porque afectará a los cargos de servicio que ya están facturados como parte de un prepago.';
        LineAmountInvalidErr: Label 'You have set the line amount to a value that results in a discount that is not valid. Consider increasing the unit price instead.';
        LineAmountInvalidErrEsp: Label 'Ha establecido el importe de la línea a un valor que resulta en un descuento que no es válido. Considere aumentar el precio unitario en su lugar.';
        InvDiscForPrepmtExceededErr: Label 'You cannot enter an invoice discount for sales document %1.\\You must cancel the prepayment invoice first and then you will be able to update the invoice discount.', Comment = '%1 - document number';
        InvDiscForPrepmtExceededErrEsp: Label 'No puede introducir un descuento de factura para el documento de ventas %1.\\Debe cancelar la factura de prepago primero y luego podrá actualizar el descuento de la factura.', Comment = '%1 - document number';
        Text044: Label 'cannot be less than %1';
        Text044Esp: Label 'no puede ser menor que %1';
        Text045: Label 'cannot be more than %1';
        Text045Esp: Label 'no puede ser mayor que %1';
        Text046: Label 'You cannot return more than the %1 units that you have shipped for %2 %3.';
        Text046Esp: Label 'No puede devolver más de las unidades %1 que ha enviado para %2 %3.';
        Text047: Label 'must be positive when %1 is not 0.';
        Text047Esp: Label 'debe ser positivo cuando %1 no es 0.';
        Text048: Label 'You cannot use item tracking on a %1 created from a %2.';
        Text048Esp: Label 'No puede utilizar el seguimiento de elementos en un %1 creado a partir de un %2.';
        SalesHeader: Record "Sales Header";
    begin
        IsHandled := true;


        if SalesLine."Prepayment %" <> 0 then begin
            if SalesLine."System-Created Entry" then
                if SalesLine.Type = SalesLine.Type::"G/L Account" then
                    if not SalesLine.IsServiceChargeLine() then
                        exit;
            // if SalesLine.Quantity < 0 then
            //     SalesLine.FieldError(Quantity, StrSubstNo(Text047Esp, FieldCaption("Prepayment %")));
            // if SalesLine."Unit Price" < 0 then
            //     SalesLine.FieldError("Unit Price", StrSubstNo(Text047Esp, FieldCaption("Prepayment %")));
        end;
        SalesHeader.Get(SalesLine."Document Type", SalesLine."Document No.");
        if SalesHeader."Document Type" <> SalesHeader."Document Type"::Invoice then begin
            if (SalesLine."Prepmt. Line Amount" < SalesLine."Prepmt. Amt. Inv.") and (SalesHeader.Status <> SalesHeader.Status::Released) then begin
                if SalesLine.IsServiceChargeLine() then
                    Error(CannotChangePrepaidServiceChargeErrEsp);
                if SalesLine."Inv. Discount Amount" <> 0 then
                    Error(InvDiscForPrepmtExceededErrEsp, SalesLine."Document No.");
                If (SalesLine."Prepmt. Line Amount" > 0) And (SalesLine."Prepmt. Amt. Inv." > 0) then
                    ThrowWrongAmountError(SalesLine);
            end;
            if (SalesLine."Prepmt. Line Amount" <> 0) And (SalesLine."Line Amount" > 0) then begin
                RemLineAmountToInvoice := SalesLine.GetLineAmountToHandleInclPrepmt(SalesLine.Quantity - SalesLine."Quantity Invoiced");
                if (RemLineAmountToInvoice) < (SalesLine."Prepmt Amt to Deduct" - SalesLine."Prepmt Amt Deducted") then
                    SalesLine.FieldError("Prepmt Amt to Deduct", StrSubstNo(Text045Esp, RemLineAmountToInvoice + SalesLine."Prepmt Amt Deducted"));
            end;
        end;
    end;
    /// <summary>
    /// ThrowWrongAmountError.
    /// </summary>
    /// <param name="SalesLine">VAR Record "Sales Line".</param>
    procedure ThrowWrongAmountError(var SalesLine: Record "Sales Line")
    var
        Text049: Label 'cannot be %1.';
        Text049Esp: Label 'no puede ser %1.';
    begin


        SalesLine.FieldError("Prepmt. Line Amount", StrSubstNo(Text049Esp, SalesLine."Prepmt. Amt. Inv."));
    end;
    /// <summary>
    /// BorrarLineas.
    /// </summary>
    /// <param name="Rec">VAR Record "Sales Line".</param>
    /// <param name="RunTrigger">Boolean.</param>
    [EventSubscriber(ObjectType::Table, Database::"Sales Line", OnAfterDeleteEvent, '', false, false)]
    procedure BorrarLineas(var Rec: Record "Sales Line"; RunTrigger: Boolean)
    var
        JobPlLine: Record "Job Planning Line";
        Res: Record Resource;
        Tipo: Record "Tipo Recurso";
        JobSeup: Record "Jobs Setup";
    begin
        //Si Rec es temporary exit
        if Rec.ISTEMPORARY then exit;
        // if Rec."Document Type" = Rec."Document Type"::Invoice Then
        //     if RunTrigger Then
        //         if Rec."Linea Origen" <> 0 Then Error('Existe una factura de compra asociada. No se puede eliminar la línea');


        if (Rec."No linea proyecto" <> 0) and (Rec."Document Type" = Rec."Document Type"::Order) Then begin
            if not JobSeup.Get() Then exit;
            if JobSeup."No Comprobar Recursos" then exit;
            if Not Res.Get(Rec."No.") Then exit;
            if Res."Recurso Agrupado" then exit;
            if not Tipo.Get(Res."Tipo Recurso") Then Tipo.Init();
            if Res."Producción" then Tipo."Crea Reservas" := false;
            if Res."Recurso Agrupado" then Tipo."Crea Reservas" := false;
            if Tipo."Crea Reservas" Then exit;
            if RunTrigger then
                if JobPlLine.Get(Rec."Job No.", Rec."Job Task No.", Rec."No linea proyecto") Then Error('No puede eliminar esta línea, porque está en un proyecto');
        end;
    end;
    /// <summary>
    /// ModificarLineas.
    /// </summary>
    /// <param name="Rec">VAR Record "Sales Line".</param>
    /// <param name="xRec">VAR Record "Sales Line".</param>
    /// <param name="RunTrigger">Boolean.</param>
    [EventSubscriber(ObjectType::Table, Database::"Sales Line", OnAfterModifyEvent, '', false, false)]
    procedure ModificarLineas(var Rec: Record "Sales Line"; var xRec: Record "Sales Line"; RunTrigger: Boolean)
    var

    begin
        //Si Rec es temporary exit
        if Rec.ISTEMPORARY then exit;
        if Rec."Document Type" = Rec."Document Type"::Invoice Then
            if RunTrigger Then
                if Rec."Linea Origen" <> 0 Then Error('Existe una factura de compra asociada. No se puede modificar la línea');

    end;

    /// <summary>
    /// ModificaNo.
    /// </summary>
    /// <param name="Rec">VAR Record "Sales Line".</param>
    /// <param name="xRec">VAR Record "Sales Line".</param>
    /// <param name="CurrFieldNo">Integer.</param>
    [EventSubscriber(ObjectType::Table, Database::"Sales Line", 'OnAfterValidateEvent', 'No.', false, false)]
    procedure ModificaNo(var Rec: Record "Sales Line"; var xRec: Record "Sales Line"; CurrFieldNo: Integer)
    var
        JobPlLine: Record "Job Planning Line";
        Res: Record Resource;
        Res2: Record Resource;
        Tipo: Record "Tipo Recurso";
        JobSeup: Record "Jobs Setup";
        SalesHeader: Record "Sales Header";
        Dim: Record "Default Dimension";
        Dim2: Record "Default Dimension";
    begin
        if CurrFieldNo <> Rec.FieldNo("No.") Then exit;
        if ((Rec."Document Type" = Rec."Document Type"::Order) or (Rec."Document Type" = Rec."Document Type"::"Credit Memo")) and (Rec."Job No." = '') Then begin
            SalesHeader.Get(Rec."Document Type", Rec."Document No.");
            Rec."Job No." := SalesHeader."Nº Proyecto";
        end;
        if (Rec."No linea proyecto" <> 0) and (Rec."Document Type" = Rec."Document Type"::Order) Then begin
            if not JobSeup.Get() Then exit;
            if JobSeup."No Comprobar Recursos" then exit;
            if Not Res.Get(Rec."No.") Then exit;
            if Res."Empresa Origen" <> '' Then begin
                Dim2.ChangeCompany(Res."Empresa Origen");
                Dim2.SetRange("Table Id", 156);
                Dim2.SetRange("No.", Res."Nº En Empresa origen");
                Dim.SetRange("Table Id", 156);
                Dim.SetRange("No.", Res."No.");
                Dim.DeleteAll();
                if Dim2.FindFirst() Then
                    repeat
                        Dim := Dim2;
                        Dim."No." := Res."No.";
                        Dim.Insert();
                    Until Dim2.Next = 0;
                Res2.ChangeCompany(Res."Empresa Origen");
                Res2.Get(Res."Nº En Empresa origen");
                Res."Global Dimension 1 Code" := Res2."Global Dimension 1 Code";
                //Igual para las 5 dimensiones
                Res."Global Dimension 2 Code" := Res2."Global Dimension 2 Code";
                Res."Global Dimension 3 Code" := Res2."Global Dimension 3 Code";
                Res."Global Dimension 4 Code" := Res2."Global Dimension 4 Code";
                Res."Global Dimension 5 Code" := Res2."Global Dimension 5 Code";
                Res.Modify();
            end;
            if Res."Recurso Agrupado" then exit;

            if not Tipo.Get(Res."Tipo Recurso") Then Tipo.Init();
            if Res."Producción" then Tipo."Crea Reservas" := false;
            if Res."Recurso Agrupado" then Tipo."Crea Reservas" := false;
            if Tipo."Crea Reservas" Then exit;
            if JobPlLine.Get(Rec."Job No.", Rec."Job Task No.", Rec."No linea proyecto") Then
                if JobPlLine."No." <> Rec."No." Then Error('No puede modificar esta línea, porque está en un proyecto');
        end;
    end;
    /// <summary>
    /// ModificaQuantity.
    /// </summary>
    /// <param name="Rec">VAR Record "Sales Line".</param>
    /// <param name="xRec">VAR Record "Sales Line".</param>
    /// <param name="CurrFieldNo">Integer.</param>
    [EventSubscriber(ObjectType::Table, Database::"Sales Line", 'OnAfterValidateEvent', 'Quantity', false, false)]
    procedure ModificaQuantity(var Rec: Record "Sales Line"; var xRec: Record "Sales Line"; CurrFieldNo: Integer)
    var
        Control: Codeunit "ControlProcesos";
        Res: Record Resource;
        Job: Record Job;
        Customer: Record Customer;
    begin
        exit;
        //'No Se usa se usa el de jobPlannigLine
        if Rec.Type <> Rec.Type::Resource then exit;
        if Not Res.Get(Rec."No.") then exit;
        if Not Job.Get(Rec."Job No.") then exit;
        Rec."% Dto. Venta 1" := 0;
        Rec."% Dto. Venta 2" := 0;
        If not Customer.Get(Rec."Sell-to Customer No.") then exit;
        if Rec."Precio Tarifa" = 0 Then
            Rec."Precio Tarifa" := Control.FindResourcePriceNew(Customer."Customer Posting Group" = 'AGENCIA',
             Res."Customer Price Group", WorkDate(), Rec."VAT %", Job, Res."No.", Rec."Cdad. Soportes", rec.Duracion, Rec."Tipo Duracion");

    end;
    #endregion Tabla37
    #region Tabla38
    [EventSubscriber(ObjectType::Table, Database::"Purchase Header", 'OnBeforeSendToPosting', '', false, false)]
    local procedure OnBeforeSendToPosting(var PurchaseHeader: Record "Purchase Header"; var IsSuccess: Boolean; var IsHandled: Boolean)
    var
        ErrorContextElement: Codeunit "Error Context Element";
        ErrorMessageMgt: Codeunit "Error Message Management";
        ErrorMessageHandler: Codeunit "Error Message Handler";
        PostingCodeunitID: Integer;
    begin
        IsHandled := true;
        PostingCodeunitID := CODEUNIT::"Purch.-Post (Yes/No)";

        if not PurchaseHeader.IsApprovedForPosting() then
            exit;

        Commit();
        ErrorMessageMgt.Activate(ErrorMessageHandler);
        ErrorMessageMgt.PushContext(ErrorContextElement, PurchaseHeader.RecordId, 0, '');
        IsSuccess := CODEUNIT.Run(PostingCodeunitID, PurchaseHeader);
        if not IsSuccess then begin
            Commit;
            BorrarAlbaranes(PurchaseHeader);
            ErrorMessageHandler.ShowErrors();
        end;
    end;

    PROCEDURE BorrarAlbaranes(var Rec: record "Purchase Header");
    VAR
        r120: Record "Purch. Rcpt. Header";
        PurchaseLine: Record "Purchase Line";
        r121: Record "Purch. Rcpt. Line";
    BEGIN
        r120.SETCURRENTKEY("Order No.");
        r120.SETRANGE(r120."Order No.", Rec."No.");
        PurchaseLine.SETRANGE(PurchaseLine."Document Type", Rec."Document Type");
        PurchaseLine.SETRANGE(PurchaseLine."Document No.", Rec."No.");
        PurchaseLine.SETRANGE(PurchaseLine.Type, PurchaseLine.Type::"Fixed Asset");
        if PurchaseLine.FINDFIRST THEN EXIT;
        r120.SETRANGE(Contabilizado, FALSE);
        if r120.FindFirst() THEN BEGIN
            REPEAT
                r121.SETRANGE(r121."Document No.", r120."No.");
                r121.DELETEALL;

            UNTIL r120.NEXT = 0;
        END;
        r120.DELETEALL(TRUE);
    END;

    local procedure FirmaContratosEntreEmpresas(var Rec: Record "Sales Header"; Estado: Enum "Estado Contrato")
    var
        Lines: Record "Sales Line";
        Contratos: Record "Sales Header";
        rJob2: Record Job;
    begin
        if Estado <> Estado::Firmado then exit;
        Lines.SETRANGE("Document Type", Rec."Document Type");
        Lines.SETRANGE("Document No.", Rec."No.");
        if Lines.FIND('-') then begin
            repeat
                if Lines."Empresa Compra" <> '' then begin
                    Contratos.ChangeCompany(Lines."Empresa Compra");
                    rJob2.CHANGECOMPANY(Lines."Empresa Compra");
                    rJob2.SETCURRENTKEY(rJob2."Proyecto en empresa Origen");
                    rJob2.SETRANGE(rJob2."Proyecto en empresa Origen", Rec."Nº Proyecto");
                    if rJob2.FINDFIRST Then begin
                        Contratos.SetRange("Nº Proyecto", rJob2."No.");
                        if Contratos.FindFirst() Then begin
                            Contratos.Estado := Estado;
                            Contratos.MODIFY;
                        end;
                    end;

                end;
            until Lines.NEXT = 0;
        end;
    end;

    local procedure FechaRenovacion(NProyecto: Code[20]; var FechaComparacion: Date; FechaEstado: Date)
    var
        Job: Record Job;
        JobAnt: Record Job;
        JobAntAnt: Record Job;
        ContratoAnt: Record "Sales Header";
        ContratoAntAnt: Record "Sales Header";
        Fecha: Date;
        customer: Record Customer;
    begin
        FechaComparacion := FechaEstado;
        If not job.Get(NProyecto) then exit;
        if Job."Proyecto origen" = '' then exit;
        If Not JobAnt.Get(Job."Proyecto origen") then exit;
        ContratoAnt.SETRANGE("Nº Proyecto", JobAnt."No.");
        ContratoAnt.SetRange("Document Type", ContratoAnt."Document Type"::Order);
        if ContratoAnt.FindLast() then begin
            Fecha := CalcDate('PS+1D-1S-1A+PS+5D', FechaEstado);
            If ContratoAnt."Fecha Estado" = 0D then Error('No se puede calcular la fecha de renovación, porque no existe una fecha de estado para el contrato %1', ContratoAnt."No.");
            If Date2DMY(ContratoAnt."Fecha Estado", 3) = Date2DMY(Fecha, 3) then
                ContratoAnt."Fecha Comparación" := Fecha;
            ContratoAnt.MODIFY;
            If JobAntAnt.Get(JobAnt."Proyecto origen") then begin
                ContratoAntAnt.SETRANGE("Nº Proyecto", JobAntAnt."No.");
                ContratoAntAnt.SetRange("Document Type", ContratoAntAnt."Document Type"::Order);
                if ContratoAntAnt.FindLast() then begin
                    Fecha := CalcDate('PS+1D-1S-1A+PS+5D', Fecha);
                    If ContratoAntAnt."Fecha Estado" = 0D then Error('No se puede calcular la fecha de renovación, porque no existe una fecha de estado para el contrato %1', ContratoAntAnt."No.");
                    If Date2DMY(ContratoAntAnt."Fecha Estado", 3) = Date2DMY(Fecha, 3) then
                        ContratoAntAnt."Fecha Comparación" := Fecha;
                    ContratoAntAnt.MODIFY;
                end;
            end;
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Header", 'OnAfterValidateEvent', 'Nº Proyecto', false, false)]
    LOCAL PROCEDURE Table38_OnValidatePyoyecto(VAR Rec: Record "Purchase Header"; VAR xRec: Record "Purchase Header"; CurrFieldNo: Integer)
    VAR
        PurchaseLine: Record "Purchase Line";
        rProyecto: Record 167;
    BEGIN
        // $001 -
        //MessageIfPurchLinesExist(FIELDCAPTION("Nº Proyecto"));
        PurchaseLine.SETRANGE(PurchaseLine."Document Type", Rec."Document Type");
        PurchaseLine.SETRANGE(PurchaseLine."Document No.", Rec."No.");
        PurchaseLine.MODIFYALL(PurchaseLine."Job No.", Rec."Nº Proyecto");
        // $001 +

        //$003(I)
        if Rec."Descripcion proyecto" = '' THEN BEGIN
            if rProyecto.GET(Rec."Nº Proyecto") THEN
                Rec.VALIDATE("Descripcion proyecto", rProyecto.Description);
        END;
        //$003(F)
    END;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Header", 'OnAfterValidateEvent', 'Pay-to Vendor No.', false, false)]
    LOCAL PROCEDURE Table38_OnValidateVendor(VAR Rec: Record "Purchase Header"; VAR xRec: Record "Purchase Header"; CurrFieldNo: Integer)
    VAR
        PurchaseLine: Record "Purchase Line";
        rPro: Record Vendor;
    BEGIN
        // $001 -
        if rPro.GET(Rec."Pay-to Vendor No.") THEN
            Rec.Banco := rPro.Banco;

        //$003(F)
    END;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Header", 'OnAfterValidateEvent', 'Vendor Invoice No.', false, false)]
    LOCAL PROCEDURE Table38_OnValidateVendorInvoiceNo(VAR Rec: Record "Purchase Header"; VAR xRec: Record "Purchase Header"; CurrFieldNo: Integer)
    BEGIN
        Rec."Posting Description" := FORMAT(Rec."Document Type") + ' ' + Rec."Vendor Invoice No.";
    END;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Header", 'OnAfterValidateEvent', 'Vendor Cr. Memo No.', false, false)]
    LOCAL PROCEDURE Table38_OnValidateVendorCRNo(VAR Rec: Record "Purchase Header"; VAR xRec: Record "Purchase Header"; CurrFieldNo: Integer)
    BEGIN
        Rec."Posting Description" := FORMAT(Rec."Document Type") + ' ' + Rec."Vendor Cr. Memo No.";
    END;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Header", 'OnAfterValidateEvent', 'Payment Method Code', false, false)]
    LOCAL PROCEDURE Tabla38_PaymenMethodCodeOnValidate(VAR Rec: Record "Purchase Header"; VAR xRec: Record "Purchase Header"; CurrFieldNo: Integer)
    VAR
        PaymentMethod: Record 289;
        Intercambio: Record Intercambio;
        IntercambioxEmpresa: Record "Intercambio x Empresa";
    BEGIN
        //WITH Rec DO BEGIN
        if PaymentMethod.GET(Rec."Payment Method Code") THEN begin
            //INTERCAM =  = 
            if Rec."Payment Method Code" = 'INTERCAM' Then begin
                IntercambioxEmpresa.SETRANGE(Empresa, CompanyName);
                IntercambioxEmpresa.SETRANGE(Cliente, Rec."Pay-to Vendor No.");
                if IntercambioxEmpresa.FINDfirst Then begin
                    Intercambio.GET(IntercambioxEmpresa."Código Intercambio");
                    Intercambio.Validate(Blocked, Intercambio.Blocked::" ");
                    Intercambio.Modify();
                end;
            end;

        end;
        //END;
    END;
    #endregion Tabla38
    #region Tabla39
    [EventSubscriber(ObjectType::Table, Database::"Purchase Line", 'OnBeforeCheckReceiptRelation', '', false, false)]
    local procedure OnBeforeCheckReceiptRelation(var PurchaseLine: Record "Purchase Line"; var IsHandled: Boolean)
    begin
        IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Line", 'OnBeforeValidateJobTaskNo', '', false, false)]
    local procedure OnBeforeValidateJobTaskNo(xPurchaseLine: Record "Purchase Line"; var IsHandled: Boolean)
    begin
        IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Line", 'OnAfterValidateEvent', 'No.', false, false)]
    local procedure EventNo(Var Rec: Record "Purchase Line"; Var xRec: Record "Purchase Line"; CurrFieldNo: Integer)
    var
        PurchHeader: Record "Purchase Header";
    begin
        if PurchHeader.Get(Rec."Document Type", Rec."Document No.") Then begin
            if (PurchHeader."Nº Proyecto" = '') AND
            ((PurchHeader."Document Type" = PurchHeader."Document Type"::Order) OR
            (PurchHeader."Document Type" = PurchHeader."Document Type"::"Return Order"))
            THEN
                If Copystr(Rec."Document No.", 1, 3) <> 'PCT' Then // A falta de un configurador por serie

                    MESSAGE('No ha indicado el proyecto en la cabecera');

            //$001 -
            Rec."Job No." := PurchHeader."Nº Proyecto";
            //$001 +
        End;

    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Line", 'OnBeforeCreateDim', '', false, false)]
    local procedure OnBeforeCreateDim(var PurchaseLine: Record "Purchase Line"; var IsHandled: Boolean)
    var
        SourceCodeSetup: Record "Source Code Setup";
        TableID: array[20] of Integer;
        No: array[20] of Code[20];
        DimMgt: Codeunit DimensionManagement;
        Type1: Integer;
        PurchHeader: Record "Purchase Header";
    begin

        Type1 := DimMgt.PurchLineTypeToTableID(PurchaseLine.Type);// TypeToTableID3(PurchaseLine.Type.AsInteger());
        SourceCodeSetup.Get();
        TableID[1] := Type1;
        No[1] := PurchaseLine."No.";
        TableID[2] := Database::Job;
        No[2] := PurchaseLine."Job No.";
        TableID[3] := DATABASE::"Responsibility Center";
        No[3] := PurchaseLine."Responsibility Center";
        TableID[4] := DATABASE::"Work Center";
        No[4] := PurchaseLine."Work Center No.";

        PurchaseLine."Shortcut Dimension 1 Code" := '';
        PurchaseLine."Shortcut Dimension 2 Code" := '';
        PurchaseLine."Shortcut Dimension 3 Code" := '';
        PurchaseLine."Shortcut Dimension 4 Code" := '';
        PurchaseLine."Shortcut Dimension 5 Code" := '';
        PurchHeader.get(PurchaseLine."Document Type", PurchaseLine."Document No.");
        if PurchHeader."Nº Proyecto" <> '' then PurchaseLine."Job No." := PurchHeader."Nº Proyecto";
        PurchaseLine."Dimension Set ID" :=
        ContabAlb.GetRecDefaultDimID(
            PurchaseLine, PurchaseLine.FieldNo("No."), TableID, No, SourceCodeSetup.Purchases,
            PurchaseLine."Shortcut Dimension 1 Code", PurchaseLine."Shortcut Dimension 2 Code",
            PurchaseLine."Shortcut Dimension 3 Code", PurchaseLine."Shortcut Dimension 4 Code", PurchaseLine."Shortcut Dimension 5 Code", PurchHeader."Dimension Set ID", DATABASE::Vendor);
        ContabAlb.UpdateGlobalDimFromDimSetID(PurchaseLine."Dimension Set ID", PurchaseLine."Shortcut Dimension 1 Code", PurchaseLine."Shortcut Dimension 2 Code",
            PurchaseLine."Shortcut Dimension 3 Code", PurchaseLine."Shortcut Dimension 4 Code", PurchaseLine."Shortcut Dimension 5 Code");
        IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Table, database::"Purchase Line", 'OnBeforeVerifyLineTypeForJob', '', false, false)]
    local procedure OnBeforeVerifyLineTypeForJob(var PurchaseLine: Record "Purchase Line"; xPurchaseLine: Record "Purchase Line"; var IsHandled: Boolean)
    var
        MustNotBeSpecifiedErr: Label 'must not be specified when %1 = %2', Comment = '%1 - the field name, %2 - the field value';
    begin

        IsHandled := true;
        if not (PurchaseLine.Type in [PurchaseLine.Type::Item, PurchaseLine.Type::"G/L Account", PurchaseLine.Type::Resource]) then
            PurchaseLine.FieldError("Job No.", StrSubstNo(MustNotBeSpecifiedErr, PurchaseLine.FieldCaption(Type), PurchaseLine.Type));
    end;

    [EventSubscriber(ObjectType::Table, database::"Purchase Line", 'OnBeforeCreateTempJobJnlLine', '', false, false)]
    local procedure OnBeforeCreateTempJobJnlLine(var TempJobJournalLine: Record "Job Journal Line" temporary; PurchaseLine: Record "Purchase Line"; xPurchaseLine: Record "Purchase Line"; GetPrices: Boolean; CallingFieldNo: Integer; var IsHandled: Boolean)
    var
        PurchHeader: Record "Purchase Header";
    begin
        IsHandled := true;
        PurchHeader.GET(PurchaseLine."Document Type", PurchaseLine."Document No.");
        Clear(TempJobJournalLine);
        TempJobJournalLine.DontCheckStdCost;
        TempJobJournalLine.Validate("Job No.", PurchaseLine."Job No.");
        TempJobJournalLine.Validate("Job Task No.", PurchaseLine."Job Task No.");
        TempJobJournalLine.Validate("Posting Date", PurchHeader."Posting Date");
        TempJobJournalLine.SetCurrencyFactor(PurchaseLine."Job Currency Factor");
        if PurchaseLine.Type = PurchaseLine.Type::"G/L Account" then
            TempJobJournalLine.Validate(Type, TempJobJournalLine.Type::"G/L Account");
        if PurchaseLine.Type = PurchaseLine.Type::Item Then
            TempJobJournalLine.Validate(Type, TempJobJournalLine.Type::Item);
        if PurchaseLine.Type = PurchaseLine.Type::Resource Then
            TempJobJournalLine.Validate(Type, TempJobJournalLine.Type::Resource);
        TempJobJournalLine.Validate("No.", PurchaseLine."No.");
        TempJobJournalLine.Validate(Quantity, PurchaseLine.Quantity);
        TempJobJournalLine.Validate("Variant Code", PurchaseLine."Variant Code");
        TempJobJournalLine.Validate("Unit of Measure Code", PurchaseLine."Unit of Measure Code");

        if not GetPrices then begin
            if xPurchaseLine."Line No." <> 0 then begin
                TempJobJournalLine."Unit Cost" := xPurchaseLine."Unit Cost";
                TempJobJournalLine."Unit Cost (LCY)" := xPurchaseLine."Unit Cost (LCY)";
                TempJobJournalLine."Unit Price" := xPurchaseLine."Job Unit Price";
                TempJobJournalLine."Line Amount" := xPurchaseLine."Job Line Amount";
                TempJobJournalLine."Line Discount %" := xPurchaseLine."Job Line Discount %";
                TempJobJournalLine."Line Discount Amount" := xPurchaseLine."Job Line Discount Amount";
            end else begin
                TempJobJournalLine."Unit Cost" := PurchaseLine."Unit Cost";
                TempJobJournalLine."Unit Cost (LCY)" := PurchaseLine."Unit Cost (LCY)";
                TempJobJournalLine."Unit Price" := PurchaseLine."Job Unit Price";
                TempJobJournalLine."Line Amount" := PurchaseLine."Job Line Amount";
                TempJobJournalLine."Line Discount %" := PurchaseLine."Job Line Discount %";
                TempJobJournalLine."Line Discount Amount" := PurchaseLine."Job Line Discount Amount";
            end;
            TempJobJournalLine.Validate("Unit Price");
        end else
            TempJobJournalLine.Validate("Unit Cost (LCY)", PurchaseLine."Unit Cost (LCY)");

        //OnAfterCreateTempJobJnlLine(TempJobJnlLine, Rec, xRec, GetPrices, CurrFieldNo);
    end;

    [EventSubscriber(ObjectType::Table, database::"Purchase Line", 'OnBeforeValidateLineDiscountPctForNotItemType', '', false, false)]
    local procedure OnBeforeValidateLineDiscountPctForNotItemType(var PurchaseLine: Record "Purchase Line"; var IsHandled: Boolean)
    begin
        IsHandled := true;
        PurchaseLine.Validate("Line Discount %", PurchaseLine."Line Discount %");
    end;
    #endregion Tabla39
    #region Table49
#if not CLEAN27
#pragma warning disable AL0432 // TODO: - Invoice Posting Buffer codunit 825
    // TODO: - CLEAN22



    [EventSubscriber(ObjectType::Table, Database::"Invoice Post. Buffer", 'OnAfterCopyToGenJnlLine', '', false, false)]
    local procedure OnAfterCopyToGenJnlLine(var GenJnlLine: Record "Gen. Journal Line"; InvoicePostBuffer: Record "Invoice Post. Buffer");

    var
        Text052: Label '.';
        GlSetup: Record "General Ledger Setup";

    begin

        //$007(I)

        if (InvoicePostBuffer."Nº Contrato" <> '') AND (STRLEN(GenJnlLine.Description) < 25) THEN
            GenJnlLine.Description := GenJnlLine.Description + Text052 + InvoicePostBuffer."Nº Contrato";

        //$007(F)

        //ASC
        GenJnlLine."Shortcut Dimension 1 Code" := InvoicePostBuffer."Global Dimension 1 Code";
        GenJnlLine."Shortcut Dimension 2 Code" := InvoicePostBuffer."Global Dimension 2 Code";

        GenJnlLine."Shortcut Dimension 3 Code" := InvoicePostBuffer."Global Dimension 3 Code";


        GenJnlLine."Shortcut Dimension 4 Code" := InvoicePostBuffer."Global Dimension 4 Code";


        GenJnlLine."Shortcut Dimension 5 Code" := InvoicePostBuffer."Global Dimension 5 Code";


        GenJnlLine.Circuito := InvoicePostBuffer.Agrupado;

        GenJnlLine."Dimension Set ID" := Procesos.GetDefaultDimID2(GenJnlLine."Shortcut Dimension 1 Code",
        GenJnlLine."Shortcut Dimension 2 Code", GenJnlLine."Shortcut Dimension 3 Code", GenJnlLine."Shortcut Dimension 4 Code",
        GenJnlLine."Shortcut Dimension 5 Code");

        //-SII
        GLSetup.GET;
        if GLSetup."Activar SII" THEN BEGIN

            GenJnlLine."Tipo factura SII" := InvoicePostBuffer."Tipo factura SII";


            GenJnlLine."Clave registro SII expedidas" := InvoicePostBuffer."Clave registro SII expedidas";


            GenJnlLine."Clave registro SII recibidas" := InvoicePostBuffer."Clave registro SII recibidas";


            GenJnlLine."Descripción operación" := InvoicePostBuffer."Descripción operación";


            GenJnlLine."Tipo desglose emitidas" := InvoicePostBuffer."Tipo desglose emitidas";


            GenJnlLine."Sujeta exenta" := InvoicePostBuffer."Sujeta exenta";


            GenJnlLine."Tipo de operación" := InvoicePostBuffer."Tipo de operación";


            GenJnlLine."Tipo factura rectificativa" := InvoicePostBuffer."Tipo factura rectificativa";

        END;

        GenJnlLine."Nº Contrato" := InvoicePostBuffer."Nº Contrato";

        //+SII
    end;

    // TODO: - CLEAN22
#pragma warning restore AL0432 // TODO: - Invoice Posting Buffer codunit 825
#endif
    #endregion Table49
    #region Table79
    [EventSubscriber(ObjectType::Table, Database::"Company Information", 'OnBeforeValidateEvent', 'Instalación en Curso', false, false)]
    local procedure OnBeforeValidateEventCompanyInformation(var Rec: Record "Company Information"; var xRec: Record "Company Information"; currfieldno: Integer)

    var
        Control: Codeunit "Controlprocesos";
        Emp: Record Company;
        Info: Record 79;
    begin
        Emp.SetFilter(Name, '<>%1', Emp.Name);
        If Emp.FindSet() then
            repeat
                if control.Permiso_Empresas(Emp.Name) then begin

                    Info.ChangeCompany(Emp.Name);
                    info.get();
                    info."Instalación En Curso" := Rec."Instalación En Curso";
                    info.modify();
                end;
            until Emp.Next() = 0;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Company Information", 'OnBeforeValidateEvent', 'Mensaje General', false, false)]
    local procedure OnBeforeValidateEventCompanyInformationMensajeGeneral(var Rec: Record "Company Information"; var xRec: Record "Company Information"; currfieldno: Integer)

    var
        Control: Codeunit "Controlprocesos";
        Emp: Record Company;
        Info: Record 79;
    begin
        Emp.SetFilter(Name, '<>%1', Emp.Name);
        If Emp.FindSet() then
            repeat
                if control.Permiso_Empresas(Emp.Name) then begin
                    Info.ChangeCompany(Emp.Name);
                    info.get();
                    info."Mensaje General" := Rec."Mensaje General";
                    info.modify();
                end;
            until Emp.Next() = 0;
    end;
    #endregion Table79
    #region Table81
    [EventSubscriber(ObjectType::Table, Database::"Gen. Journal Line", 'OnAfterValidateShortcutDimCode', '', false, false)]
    local procedure OnAfterValidateShortcutDimCode(var GenJournalLine: Record "Gen. Journal Line"; var xGenJournalLine: Record "Gen. Journal Line"; FieldNumber: Integer; var ShortcutDimCode: Code[20]; CallingFieldNo: Integer)
    begin
        Case FieldNumber Of
            3:
                begin
                    if GenJournalLine."Shortcut Dimension 3 Code" = '' Then
                        GenJournalLine."Shortcut Dimension 3 Code" := ShortcutDimCode;
                end;
            4:
                begin
                    if GenJournalLine."Shortcut Dimension 4 Code" = '' Then
                        GenJournalLine."Shortcut Dimension 4 Code" := ShortcutDimCode;
                end;
            5:
                begin
                    if GenJournalLine."Shortcut Dimension 5 Code" = '' Then
                        GenJournalLine."Shortcut Dimension 5 Code" := ShortcutDimCode;
                end;
        End;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Gen. Journal Line", 'OnAfterCopyGenJnlLineFromSalesHeader', '', false, false)]
    local procedure OnAfterCopyGenJnlLineFromSalesHeader(SalesHeader: Record "Sales Header"; var GenJournalLine: Record "Gen. Journal Line")
    var
        Text052: Label '.';
        r21: Record 21;
    begin
        with SalesHeader do begin

            //$007(I)
            GenJournalLine.Description := "Posting Description";
            if ("Nº Contrato" <> '') AND (STRLEN(GenJournalLine.Description) < 25) THEN
                GenJournalLine.Description := GenJournalLine.Description + Text052 + "Nº Contrato";
            //$007(F)
            GenJournalLine."Shortcut Dimension 1 Code" := "Shortcut Dimension 1 Code";
            GenJournalLine."Shortcut Dimension 2 Code" := "Shortcut Dimension 2 Code";
            //ASC
            GenJournalLine."Shortcut Dimension 3 Code" := "Shortcut Dimension 3 Code";
            GenJournalLine."Shortcut Dimension 4 Code" := "Shortcut Dimension 4 Code";
            GenJournalLine."Shortcut Dimension 5 Code" := "Shortcut Dimension 5 Code";
            GenJournalLine."Dimension Set ID" := Procesos.GetDefaultDimID2(GenJournalLine."Shortcut Dimension 1 Code",
            GenJournalLine."Shortcut Dimension 2 Code", GenJournalLine."Shortcut Dimension 3 Code", GenJournalLine."Shortcut Dimension 4 Code",
            GenJournalLine."Shortcut Dimension 5 Code");
            GenJournalLine."Salespers./Purch. Code" := "Salesperson Code";

            //$006(I)
            //ASC
            GenJournalLine."Nº Contrato" := "Nº Contrato";
            //GenJnlLine.Circuito:=Agrupado;
            //$003(F)
            if SalesHeader."Remesa sin factura" Then
                GenJournalLine."No. Borrador factura" := SalesHeader."No.";
            r21.SETCURRENTKEY(r21."Nº Factura Borrador");
            r21.SETRANGE(r21."Nº Factura Borrador", SalesHeader."No.");
            if r21.FINDLAST THEN BEGIN
                r21."Applies-to ID" := SalesHeader."No.";
                r21.MODIFY;
                if GenJournalLine."Account Type" = GenJournalLine."Account Type"::Customer Then Begin
                    GenJournalLine."Applies-to ID" := SalesHeader."No.";
                    "Applies-to ID" := SalesHeader."No.";
                End;
            END;
            //GenJournalLine.Circuito:=Agrupado;
            //$003(F)
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Gen. Journal Line", 'OnAfterCopyGenJnlLineFromSalesHeaderApplyTo', '', false, false)]
    local procedure OnAfterCopyGenJnlLineFromSalesHeaderApplyTo(SalesHeader: Record "Sales Header"; var GenJournalLine: Record "Gen. Journal Line")
    var
        r21: Record 21;
    begin
        if SalesHeader."Factura prepago" THEN
            GenJournalLine.Prepayment := TRUE;

        if SalesHeader."Remesa sin factura" THEN BEGIN
            GenJournalLine."No. Borrador factura" := SalesHeader."No.";
            r21.SETCURRENTKEY(r21."Nº Factura Borrador");
            r21.SETRANGE(r21."Nº Factura Borrador", SalesHeader."No.");
            if r21.FINDLAST THEN BEGIN
                r21."Applies-to ID" := SalesHeader."No.";
                r21.MODIFY;
                GenJournalLine."Applies-to ID" := SalesHeader."No.";
                SalesHeader."Applies-to ID" := SalesHeader."No.";
            END;
        end;
    end;
    #endregion Table81
    #region Table85
    [EventSubscriber(ObjectType::Table, Database::"Acc. Schedule Line", 'OnAfterGetAccSchedSetup', '', false, false)]
    local procedure OnAfterGetAccSchedSetup(var AnalysisView: Record "Analysis View"; AccScheduleName: Record "Acc. Schedule Name")
    var
        GlSetup: Record "General Ledger Setup";
    begin
        GlSetup.Get();
        if AnalysisView."Dimension 3 Code" = '' Then AnalysisView."Dimension 3 Code" := GlSetup."Shortcut Dimension 3 Code";
        if AnalysisView."Dimension 4 Code" = '' Then AnalysisView."Dimension 4 Code" := GlSetup."Shortcut Dimension 4 Code";
        if AnalysisView."Dimension 5 Totaling" = '' Then AnalysisView."Dimension 5 Totaling" := GlSetup."Shortcut Dimension 5 Code";

    end;

    [EventSubscriber(ObjectType::Table, Database::"Acc. Schedule Line", 'OnBeforeGetCaptionClass', '', false, false)]
    local procedure OnBeforeGetCaptionClass(var AccScheduleLine: Record "Acc. Schedule Line"; AccSchedName: Record "Acc. Schedule Name"; AnalysisViewDimType: Integer; var Result: Text[250]; var IsHandled: Boolean)
    var
        AnalysisView: Record "Analysis View";
        GlSetup: Record "General Ledger Setup";
        Text006: Label '1,6,,Dimension 5 Filter';
        Text010: Label ',, Totaling';
        Text011: Label '1,5,,Dimension 5 Totaling';

    begin
        if AnalysisViewDimType < 9 Then exit;
        IsHandled := True;
        GlSetup.Get();
        if AnalysisView."Dimension 3 Code" = '' Then AnalysisView."Dimension 3 Code" := GlSetup."Shortcut Dimension 3 Code";
        if AnalysisView."Dimension 4 Code" = '' Then AnalysisView."Dimension 4 Code" := GlSetup."Shortcut Dimension 4 Code";
        if AnalysisView."Dimension 5 Totaling" = '' Then AnalysisView."Dimension 5 Totaling" := GlSetup."Shortcut Dimension 5 Code";
        case AnalysisViewDimType of
            9:
                begin
                    if AnalysisView."Dimension 5 Totaling" <> '' then
                        Result := '1,6,' + AnalysisView."Dimension 5 Totaling" + Text010 else
                        Result := Text006;
                end;
            10:
                begin
                    if AnalysisView."Dimension 5 Totaling" <> '' then
                        Result := '1,5,' + AnalysisView."Dimension 5 Totaling" + Text010 else
                        Result := Text011;
                end;

        end;
    end;
    #endregion Table85
    // #region Table110
    // [EventSubscriber(ObjectType::Table, 110, 'OnBeforeCheckNoPrinted', '', false, false)]
    // local procedure OnBeforeCheckNoPrinted(var SalesShipmentHeader: Record "Sales Shipment Header"; var IsHandled: Boolean)
    // var
    //     lGlEntry: Record "G/L Entry";
    // begin
    //     lGlEntry.SETRANGE("Document Type", lGlEntry."Document Type"::Shipment);
    //     lGlEntry.SETRANGE("Document No.", SalesShipmentHeader."No.");
    //     if lGlEntry.FINDSET THEN
    //         ERROR('No se puede eliminar, ya se ha contabilizado');
    // end;
    // #endregion Table110
    #region Table121
    [EventSubscriber(ObjectType::Table, Database::"Purch. Rcpt. Line", 'OnBeforeInsertInvLineFromRcptLineBeforeInsertTextLine', '', false, false)]
    local procedure OnBeforeInsertInvLineFromRcptLineBeforeInsertTextLine(var PurchRcptLine: Record "Purch. Rcpt. Line"; var PurchLine: Record "Purchase Line"; var NextLineNo: Integer; var Handled: Boolean)
    var
        Text000: Label 'Nº albarán %1: - Pedido: %2';
    begin
        PurchLine.Description := STRSUBSTNO(Text000, PurchRcptLine."Document No.", PurchRcptLine."Order No.");

    end;


    #endregion Table121
    #region Tabla167
    [EventSubscriber(ObjectType::Table, Database::Job, 'OnAfterBillToCustomerNoUpdated', '', false, false)]
    local procedure OnAfterBillToCustomerNoUpdated(var Job: Record Job; BillToCustomer: Record Customer; CallingFieldNo: Integer)
    begin
        if BillToCustomer.Impagados THEN MESSAGE('Atención: Este cliente tiene impagados');
    end;

    [EventSubscriber(ObjectType::Table, Database::"Job", 'OnAfterValidateEvent', 'Bill-to Customer No.', false, false)]
    local procedure OnAfterValidateEventJobCust(var Rec: Record "Job"; xRec: Record "Job")
    var
        Cust: Record "Customer";
    begin
        if (Rec."Nombre Comercial" = '') Then
            if Cust.Get(Rec."Bill-to Customer No.") Then
                Rec."Nombre Comercial" := Cust.Name;


    end;

    [EventSubscriber(ObjectType::Table, Database::Job, 'OnAfterValidateEvent', 'Tipo', false, false)]
    LOCAL PROCEDURE Tabla167_TipoOnValidatetipo(VAR Rec: Record 167; VAR xRec: Record 167; CurrFieldNo: Integer)
    VAR
        rLinProy: Record 1003;
    BEGIN

        // $003
        CASE Rec.Tipo OF
            Rec.Tipo::"Por Campaña":
                BEGIN
                    Rec."Fija/Papel" := Rec."Fija/Papel"::Papel;
                END;
            Rec.Tipo::Otros:
                BEGIN            // unico caso que se tocan las otras opciones
                    Rec."Fija/Papel" := Rec."Fija/Papel"::" ";
                    Rec.Subtipo := Rec.Subtipo::" ";
                    Rec."Soporte de" := Rec."Soporte de"::" ";
                END;
            //$014(I)
            Rec.Tipo::Reserva:
                BEGIN
                END;
            Rec.Tipo::Propuesta:
                BEGIN
                END;
            //$014(F)
            ELSE BEGIN
                if (Rec."Soporte de" = Rec."Soporte de"::Fijación) THEN
                    Rec."Fija/Papel" := Rec."Fija/Papel"::Papel
                ELSE
                    Rec."Fija/Papel" := Rec."Fija/Papel"::Fija;
            END;
        END;

        //$013(I)
        rLinProy.RESET;
        rLinProy.SETRANGE("Job No.", Rec."No.");
        if rLinProy.FINDSET THEN BEGIN
            REPEAT
                if rLinProy."Fija/Papel" <> Rec."Fija/Papel" THEN BEGIN
                    rLinProy."Fija/Papel" := Rec."Fija/Papel";
                    rLinProy.MODIFY;
                END;
            UNTIL rLinProy.NEXT = 0;
        END;
        //$013(F)
    END;

    [EventSubscriber(ObjectType::Table, Database::Job, 'OnAfterValidateEvent', 'Firmado', false, false)]
    LOCAL PROCEDURE Tabla167_TipoOnValidateFirmado(VAR Rec: Record 167; VAR xRec: Record 167; CurrFieldNo: Integer)
    VAR
        rCabC: Record "Purchase Header";
        rCabV: Record "Sales Header";
    BEGIN
        Rec.Firma();

    END;

    [EventSubscriber(ObjectType::Table, Database::Job, OnAfterDeleteEvent, '', false, false)]
    Local PROCEDURE Table167_OnAfterDelete(VAR Rec: Record Job; RunTrigger: Boolean)
    var
        rReserva: Record Reserva;
        rTextoAmpli: Record "Texto Presupuesto";
    Begin

        // MNC 251199
        if Rec.Status = Rec.Status::Planning THEN BEGIN
            CLEAR(rReserva);
            rReserva.RESET;
            rReserva.SETCURRENTKEY("Nº Proyecto", "Fecha inicio");
            rReserva.SETRANGE("Nº Proyecto", Rec."No.");
            if rReserva.FIND('-') THEN
                If RunTrigger then ERROR('No se puede eliminar este proyecto ya que tiene reservas activas');
        END;

        // MNC
        rTextoAmpli.SETRANGE("Nº proyecto", Rec."No.");
        rTextoAmpli.DELETEALL;
        // Fi MNC
    End;

    [EventSubscriber(ObjectType::Table, Database::Job, 'OnAfterOnInsert', '', false, false)]
    Local PROCEDURE Table167_OnAfterInsert(VAR Job: Record Job; VAR xJob: Record Job)
    var
        rConf: Record "Jobs Setup";
        rGrupoProy: Record "Job Posting Group";
        rTaskGenerico: Record "Job Task";
        rTask: Record "Job Task";
        rProyecto: Record Job;
        rProyGenerico: Record Job;
        Text110: Label 'Para empezar a trabajar con proyectos debe hacer lo siguiente:\  - Tiene que crear un proyecto genérico.\  - Tiene que asignarlo en la configuración de Proyectos.';
    begin
        Job.Status := Job.Status::Planning;
        Job."Proyecto de fijación" := true;
        // MNC 301298
        if rGrupoProy.FIND('-') THEN
            Job."Job Posting Group" := rGrupoProy.Code
        ELSE
            ERROR('Debe crear como minimo un registro en Grupos Contables Proyectos');
        // Fi MNC

        // $001-
        //$007(I)
        rProyecto.RESET;
        if rProyecto.FINDFIRST THEN BEGIN
            //$007(F)
            rConf.GET();
            rConf.TESTFIELD("Cód. Proyecto Genérico");
            rProyGenerico.GET(rConf."Cód. Proyecto Genérico");
            rTaskGenerico.RESET;
            rTaskGenerico.SETRANGE("Job No.", rProyGenerico."No.");
            CLEAR(rTask);
            if rTaskGenerico.FINDSET THEN
                REPEAT
                    rTask.COPY(rTaskGenerico);
                    rTask."Job No." := Job."No.";
                    rTask."Job Posting Group" := Job."Job Posting Group";
                    rTask."Global Dimension 1 Code" := Job."Global Dimension 1 Code";
                    rTask."Global Dimension 2 Code" := Job."Global Dimension 2 Code";
                    if rTask.INSERT THEN;
                UNTIL rTaskGenerico.NEXT = 0;
            //$007(I)
        END
        ELSE BEGIN
            MESSAGE(Text110);                       //Mensaje de aviso para la creación de proyecto genérico
        END;
        //$007(F)
        // $001 +


        // $002 -
        if Job.GETFILTER("Global Dimension 1 Code") <> '' THEN
            Job."Global Dimension 1 Code" := Job.GETFILTER("Global Dimension 1 Code");
        // $002 +

        //$009
        if Job."Proyecto original" = '' THEN
            Job."Proyecto original" := Job."No.";
        Job.Status := Job.Status::Planning;
    end;

    [EventSubscriber(ObjectType::Table, Database::Job, 'OnAfterValidateEvent', 'Status', false, false)]
    LOCAL PROCEDURE Tabla167_TipoOnValidateStatus(VAR Rec: Record 167; VAR xRec: Record 167; CurrFieldNo: Integer)
    VAR
        JobPlanningLine: Record "Job Planning Line";
        Resource: Record "Resource";
        cProyecTo: Codeunit "Gestion Proyecto";
        JobSetup: Record "Jobs Setup";
        PL: array[16] of Decimal;
        GestMLL: Codeunit "Gestion Reservas";
        JobCalcStatistics: Codeunit "Job Calculate Statistics";
        Text004: Label 'FPR Albarán %1 - %2';
        Text50001: label 'No se puede eliminar un proyecto en estado pedido.';
        Text50002: label 'No se puede cambiar un proyecto a un estado anterior.';
        Text50005: Label 'Ya han pasado mas de %1 desde la creación del proyecto. No puede pasarse a Contrato.';
        Text50006: Label 'No se puede cambiar un proyecto a oferta';
        Text105: Label 'No se puede pasar a Contrato un Proyecto con importe de Venta a 0.';
        Text110: Label 'Para empezar a trabajar con proyectos debe hacer lo siguiente:\  - Tiene que crear un proyecto genérico.\  - Tiene que asignarlo en la configuración de Proyectos.';
    BEGIN


        if xRec.Status <> Rec.Status THEN BEGIN
            if (Rec.Status = Rec.Status::Quote) THEN
                ERROR(Text50002);

            // MLL -
            if (Rec.Status.AsInteger() < xRec.Status.AsInteger()) AND (xRec.Status.AsInteger() < xRec.Status::Quote.AsInteger()) THEN
                ERROR(Text50002);
            // MLL +

            if Rec.Status = Rec.Status::Completed THEN
                Rec.VALIDATE(Complete, TRUE);
            if xRec.Status = xRec.Status::Completed THEN BEGIN
                if DIALOG.CONFIRM(Text004) THEN
                    Rec.VALIDATE(Complete, FALSE)
                ELSE BEGIN
                    Rec.Status := xRec.Status;
                END;
            END;

            // MNC 111198
            if (Rec.Status = Rec.Status::Open) THEN BEGIN
                // $005 -
                CLEAR(JobCalcStatistics);
                JobCalcStatistics.JobCalculateCommonFilters(Rec);
                JobCalcStatistics.CalculateAmounts;
                JobCalcStatistics.GetLCYPriceAmounts(PL);
                if (PL[4] = 0) THEN begin
                    JobPlanningLine.SETRANGE("Job No.", Rec."No.");
                    JobPlanningLine.SETRANGe(Type, JobPlanningLine.type::"Activo fijo");
                    if not JobPlanningLine.FindFirst() Then
                        ERROR(Text105);
                    JobPlanningLine.SETRANGe(Type);
                end;
                // $005 +

                // $004 -
                JobSetup.GET;
                JobSetup.TESTFIELD("Limite paso Proyecto a Contrat");
                if Rec."Creation Date" = 0D Then Rec."Creation Date" := Today;
                if (WORKDATE > CALCDATE(JobSetup."Limite paso Proyecto a Contrat", Rec."Creation Date")) THEN
                    ERROR(Text50005, JobSetup."Limite paso Proyecto a Contrat");
                // $004 +

                //Revisar que se hayan creado todas las reservas del presupuesto
                JobPlanningLine.SETRANGE("Job No.", Rec."No.");
                if JobPlanningLine.FIND('-') THEN
                    REPEAT
                        if JobPlanningLine."Cdad. a Reservar" <> 0 THEN begin
                            Resource.Get(JobPlanningLine."No.");
                            If (Not Resource."Recurso Agrupado") and (Not Resource."Producción") THEN
                                ERROR('Todavia quedan reservas por crear. Ejecute \' +
                                    'la opción "Crear reservas" para todas las lineas del presupuesto');
                        end;
                    UNTIL JobPlanningLine.NEXT = 0;
                // Revisa que se hayan rellenado en Dpto y programa
                ContoldeProcesos.RevisaDP(Rec);
                Rec.TESTFIELD(Rec."Cód. vendedor");

                // Tambien ejecutar el proceso para crear pedidos de compra y venta
                CLEAR(cProyecTo);
                if cProyecTo.DebeTraspasarse(Rec) THEN BEGIN
                    if cProyecTo.PendienteTraspasoEmpresas(Rec) THEN ERROR('El proyecto esta pendiente de traspasar');
                    cProyecTo.MiraReservasOtraEmpresa(Rec);
                END;
                GestMLL.Pasa_Contrato(Rec);
                Rec."Proyecto de fijación" := false;
            END;
            //Fi MNC

            JobPlanningLine.SETCURRENTKEY("Job No.");
            JobPlanningLine.SETRANGE("Job No.", Rec."No.");
            JobPlanningLine.MODIFYALL(Status, Rec.Status);
            Rec.MODIFY;
        END;

    END;
    #endregion Tabla167
    #region Tabla270
    [EventSubscriber(ObjectType::Table, Database::"Bank Account", 'OnBeforeBuildCCC', '', false, false)]
    local procedure OnBeforeBuildCCC(var BankAccount: Record "Bank Account"; var IsHandled: Boolean)
    var
        Inf: Record "Company Information";
        NombreBanco: Text;
    begin
        Inf.GET;
        Inf.BuildCCCC(BankAccount."CCC No.", BankAccount."CCC Bank No.", BankAccount."CCC Control Digits",
        BankAccount."CCC Bank Branch No.", BankAccount."CCC Bank Account No.",
        BankAccount."SWIFT Code", BankAccount.IBAN, BankAccount."Country/Region Code", NombreBanco);
        if BankAccount.Name = '' then BankAccount.Name := CopyStr(NombreBanco, 1, MaxStrLen(BankAccount.Name));
        IsHandled := true;
        //if BankAccount."CCC No." <> '' then
        //  BankAccount.TestField("Bank Account No.", '');
    end;

    [EventSubscriber(ObjectType::Table, Database::"Bank Account", 'OnAfterValidateEvent', 'IBAN', false, false)]
    local procedure ValidateIBANComp(var Rec: Record "Bank Account"; var xRec: Record "Bank Account"; currfieldno: Integer)
    var
        Inf: Record "Company Information";
        NombreBanco: Text;
    begin
        Inf.GET;
        Inf.BuildCCCC(Rec."CCC No.", rec."CCC Bank No.", rec."CCC Control Digits",
        rec."CCC Bank Branch No.", rec."CCC Bank Account No.",
        rec."SWIFT Code", rec.IBAN, rec."Country/Region Code", NombreBanco);
        if rec.Name = '' then rec.Name := CopyStr(NombreBanco, 1, MaxStrLen(rec.Name));

    end;
    #endregion Tabla270
    #region Tabla287
    [EventSubscriber(ObjectType::Table, Database::"Customer Bank Account", 'OnAfterValidateEvent', 'CCC No.', false, false)]
    local procedure ValidateCCC(var Rec: Record "Customer Bank Account"; var xRec: Record "Customer Bank Account"; currfieldno: Integer)
    var
        Inf: Record "Company Information";
        NombreBanco: Text;
    begin
        Inf.GET;
        Inf.BuildCCCC(Rec."CCC No.", rec."CCC Bank No.", rec."CCC Control Digits",
        rec."CCC Bank Branch No.", rec."CCC Bank Account No.",
        rec."SWIFT Code", rec.IBAN, rec."Country/Region Code", NombreBanco);
        if rec.Name = '' then rec.Name := CopyStr(NombreBanco, 1, MaxStrLen(rec.Name));

    end;

    [EventSubscriber(ObjectType::Table, Database::"Customer Bank Account", 'OnAfterValidateEvent', 'IBAN', false, false)]
    local procedure ValidateIBAN(var Rec: Record "Customer Bank Account"; var xRec: Record "Customer Bank Account"; currfieldno: Integer)
    var
        Inf: Record "Company Information";
        NombreBanco: Text;
    begin
        Inf.GET;
        Inf.BuildCCCC(Rec."CCC No.", rec."CCC Bank No.", rec."CCC Control Digits",
        rec."CCC Bank Branch No.", rec."CCC Bank Account No.",
        rec."SWIFT Code", rec.IBAN, rec."Country/Region Code", NombreBanco);
        if rec.Name = '' then rec.Name := CopyStr(NombreBanco, 1, MaxStrLen(rec.Name));

    end;

    [EventSubscriber(ObjectType::Table, Database::"Customer Bank Account", 'OnAfterValidateEvent', 'CCC Bank Account No.', false, false)]
    local procedure ValidateCCC2(var Rec: Record "Customer Bank Account"; var xRec: Record "Customer Bank Account"; currfieldno: Integer)
    var
        Inf: Record "Company Information";
        NombreBanco: Text;
    begin
        Inf.GET;
        Inf.BuildCCCC(Rec."CCC No.", rec."CCC Bank No.", rec."CCC Control Digits",
        rec."CCC Bank Branch No.", rec."CCC Bank Account No.",
        rec."SWIFT Code", rec.IBAN, rec."Country/Region Code", NombreBanco);
        if rec.Name = '' then rec.Name := CopyStr(NombreBanco, 1, MaxStrLen(rec.Name));

    end;
    #endregion Tabla287
    #region Tabla288
    [EventSubscriber(ObjectType::Table, Database::"Vendor Bank Account", 'OnAfterValidateEvent', 'CCC No.', false, false)]
    local procedure ValidateCCCProv(var Rec: Record "Vendor Bank Account"; var xRec: Record "Vendor Bank Account"; currfieldno: Integer)
    var
        Inf: Record "Company Information";
        NombreBanco: Text;
    begin
        Inf.GET;
        Inf.BuildCCCC(Rec."CCC No.", rec."CCC Bank No.", rec."CCC Control Digits",
        rec."CCC Bank Branch No.", rec."CCC Bank Account No.",
        rec."SWIFT Code", rec.IBAN, rec."Country/Region Code", NombreBanco);
        if rec.Name = '' then rec.Name := CopyStr(NombreBanco, 1, MaxStrLen(rec.Name));

    end;

    [EventSubscriber(ObjectType::Table, Database::"Vendor Bank Account", 'OnAfterValidateEvent', 'IBAN', false, false)]
    local procedure ValidateIBANVendor(var Rec: Record "Vendor Bank Account"; var xRec: Record "Vendor Bank Account"; currfieldno: Integer)
    var
        Inf: Record "Company Information";
        NombreBanco: Text;
    begin
        Inf.GET;
        Inf.BuildCCCC(Rec."CCC No.", rec."CCC Bank No.", rec."CCC Control Digits",
        rec."CCC Bank Branch No.", rec."CCC Bank Account No.",
        rec."SWIFT Code", rec.IBAN, rec."Country/Region Code", NombreBanco);
        if rec.Name = '' then rec.Name := CopyStr(NombreBanco, 1, MaxStrLen(rec.Name));

    end;

    [EventSubscriber(ObjectType::Table, Database::"Vendor Bank Account", 'OnAfterValidateEvent', 'CCC Bank Account No.', false, false)]
    local procedure ValidateCCCProv2(var Rec: Record "Vendor Bank Account"; var xRec: Record "Vendor Bank Account"; currfieldno: Integer)
    var
        Inf: Record "Company Information";
        NombreBanco: Text;
    begin
        Inf.GET;
        Inf.BuildCCCC(Rec."CCC No.", rec."CCC Bank No.", rec."CCC Control Digits",
        rec."CCC Bank Branch No.", rec."CCC Bank Account No.",
        rec."SWIFT Code", rec.IBAN, rec."Country/Region Code", NombreBanco);
        if rec.Name = '' then rec.Name := CopyStr(NombreBanco, 1, MaxStrLen(rec.Name));

    end;
    #endregion Tabla287
    #region Tabla1003
    [EventSubscriber(ObjectType::Table, Database::"Job Planning Line", 'OnBeforeValidateModification', '', false, false)]
    local procedure OnBeforeValidateModification(var JobPlanningLine: Record "Job Planning Line"; var IsHandled: Boolean)
    begin
        IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Job Planning Line", 'OnAfterValidateEvent', 'Unit Price', false, false)]

    local procedure OnBeforeValidateUnitPrice(var Rec: Record "Job Planning Line"; var xRec: Record "Job Planning Line"; currfieldno: Integer)
    var
        Control: Codeunit ControlProcesos;
        Up: Decimal;
        Res: Record Resource;
        Tipo: Record "Tipo Recurso";
        Dto: Decimal;
        Job: Record Job;
        Customer: Record Customer;
    begin
        if currfieldno <> Rec.FieldNo("Unit Price") then exit;
        if Rec."Unit Price" <> 0 Then begin
            if Rec."Crear pedidos" = Rec."Crear pedidos"::"No crear pedido" then Rec."Crear pedidos" := Rec."Crear pedidos"::"De Venta";
        end;
        if Rec.Type <> Rec.Type::Resource then exit;
        //if Res."Empresa Origen" = '' then exit;
        if Not Res.Get(Rec."No.") then exit;
        if Not Job.Get(Rec."Job No.") then exit;
        If not Customer.Get(Job."Bill-to Customer No.") then exit;
        Up := Control.FindResourcePricenew(Customer."Customer Price Group" = 'AGENCIA', Res."Customer Price Group", WorkDate(), Rec."VAT %", Job, Res."No."
        , Rec."Cdad. Soportes", rec.Duracion, Rec."Tipo Duracion");
        //if Up = Rec."Unit Price" then exit;
        if not Tipo.Get(Res."Tipo Recurso") then exit;
        //if tipo."% Dto. Compra" = 0 then exit;
        if Up = 0 Then exit;
        Rec."Precio Tarifa" := Up;
        //REDONDEAR.MAS(("Unit Price"*(Tipo."% Dto. Compra"-15))/Up+15;0)/100
        DtO := ROUND(((Rec."Unit Price" * (Tipo."% Dto. Compra" - 15)) / Up) + 15, 1, '>') / 100;
        if Res."Empresa Origen" = '' then begin
            Rec.validate("% Dto. Compra", Dto);
        end;

    end;

    [EventSubscriber(ObjectType::Table, Database::"Job Planning Line", 'OnBeforeFindPriceAndDiscount', '', false, false)]
    local procedure OnBeforeFindPriceAndDiscount(CalledByFieldNo: Integer; var IsHandled: Boolean; var JobPlanningLine: Record "Job Planning Line"; xJobPlanningLine: Record "Job Planning Line")
    var
        Control: Codeunit ControlProcesos;
        Res: Record "Resource";
        Tipo: Record "Tipo Recurso";
        Job: Record Job;
        JobPlanningLines: Record "Job Planning Line";
        Customer: Record "Customer";
    begin
        //IsHandled := true;
        if Job.Get(JobPlanningLine."Job No.") then begin
            if (Job."Según disponibilidad") and (not job."Proyecto Mixto") then begin
                JobPlanningLine."Unit Price" := 0;
                JobPlanningLine."Unit Cost" := 0;
                If not Res.Get(JobPlanningLine."No.") then Res.Init;
                If Res."Empresa Origen" <> '' then Tipo.ChangeCompany(Res."Empresa Origen");
                if not Tipo.Get(Res."Tipo Recurso") then Tipo.Init;
                if (Res."Recurso Agrupado" = false) and (Job."Según disponibilidad") And (Tipo."Crea Reservas") Then begin
                    if JobPlanningLine."Recurso en Empresa Origen" = '' then
                        JobPlanningLine."Crear pedidos" := JobPlanningLine."Crear pedidos"::"No crear pedido"
                    else
                        JobPlanningLine."Crear pedidos" := JobPlanningLine."Crear pedidos"::"De Compra";
                end;
                exit;
            end;
        end;
        Customer.GET(Job."Bill-to Customer No.");
        if JobPlanningLine."Crear pedidos" = JobPlanningLine."Crear pedidos"::"No crear pedido" then begin
            JobPlanningLine."Unit Price" := 0;
            JobPlanningLine."Unit Cost" := 0;
            exit;
        end;
        if JobPlanningLine."Crear pedidos" = JobPlanningLine."Crear pedidos"::"De Compra" then begin
            JobPlanningLine."Unit Cost" := 0;
            exit;
        end;
        if JobPlanningLine."Crear pedidos" = JobPlanningLine."Crear pedidos"::"De Venta" then begin
            JobPlanningLine."Unit Price" := 0;

        end;

        if Res.Get(JobPlanningLine."No.") then begin
            JobPlanningLine.Validate("Unit Price", Control.FindResourcePriceNew(
                Customer."Customer Posting Group" = 'AGENCIA', Res."Customer Price Group", WorkDate,
                JobPlanningLine."VAT %", Job, JobPlanningLine."No.", JobPlanningLine."Cdad. Soportes", JobPlanningLine.Duracion, JobPlanningLine."Tipo Duracion"));
            if Tipo.Get(Res."Tipo Recurso") And (Res."Empresa Origen" <> '') then begin
                JobPlanningLine.Validate("Unit Cost", JobPlanningLine."Unit Price" * (1 - Tipo."% Dto. Compra" / 100));
                JobPlanningLine.validate("% Dto. Compra", Tipo."% Dto. Compra");
            end;
        end;
        if JobPlanningLine.Type = JobPlanningLine.Type::Resource then begin
            JobPlanningLine."Unit Cost (LCY)" := JobPlanningLine."Unit Cost";
            JobPlanningLine."Direct Unit Cost (LCY)" := JobPlanningLine."Direct Unit Cost (LCY)";
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Job Planning Line", 'OnValidateNoOnAfterCopyFromAccount', '', false, false)]
    local procedure OnValidateNoOnAfterCopyFromAccount(var JobPlanningLine: Record "Job Planning Line"; var xJobPlanningLine: Record "Job Planning Line"; var Job: Record Job)
    var
        Res: Record Resource;
        Item: Record Item;

        GLAcc: Record "G/L Account";
        StdTxt: Record "Standard Text";
        rFamilia: Record "Resource Group";
        Tipo: Record "Tipo Recurso";
    begin
        CASE JobPlanningLine.Type OF
            JobPlanningLine.Type::Resource:
                BEGIN
                    //FCL-24/02/04 (I). Migración de 2.0. a 3.70.
                    ContoldeProcesos.Mirar_Estado(JobPlanningLine);
                    if Not Res.Get(JobPlanningLine."No.") Then Res.Init();
                    JobPlanningLine."Compra a-Nº proveedor" := Res."Vendor No.";
                    if JobPlanningLine."Compra a-Nº proveedor" <> '' THEN
                        JobPlanningLine."Crear pedidos" := JobPlanningLine."Crear pedidos"::"De Compra Y De Venta";
                    //FCL-24/02/04 (F).
                    Res.GET(JobPlanningLine."No.");
                    Res.TESTFIELD(Blocked, FALSE);
                    JobPlanningLine.Description := Res.Name;
                    JobPlanningLine."Description 2" := Res."Name 2";
                    // $001-
                    JobPlanningLine.Validate("Shortcut Dimension 1 Code", Res."Global Dimension 1 Code");
                    JobPlanningLine.Validate("Shortcut Dimension 2 Code", Res."Global Dimension 2 Code");
                    JobPlanningLine.Validate("Shortcut Dimension 3 Code", Res."Global Dimension 3 Code");
                    JobPlanningLine.Validate("Shortcut Dimension 4 Code", Res."Global Dimension 4 Code");
                    JobPlanningLine.Validate("Shortcut Dimension 5 Code", Res."Global Dimension 5 Code");
                    JobPlanningLine."Shortcut Dimension 1 Code" := Res."Global Dimension 1 Code";
                    JobPlanningLine."Shortcut Dimension 2 Code" := Res."Global Dimension 2 Code";
                    JobPlanningLine."Shortcut Dimension 3 Code" := Res."Global Dimension 3 Code";
                    JobPlanningLine."Shortcut Dimension 4 Code" := Res."Global Dimension 4 Code";
                    JobPlanningLine."Shortcut Dimension 5 Code" := Res."Global Dimension 5 Code";
                    // $001+
                    JobPlanningLine."Unit Cost (LCY)" := Res."Unit Cost";
                    JobPlanningLine."Gen. Prod. Posting Group" := Res."Gen. Prod. Posting Group";
                    JobPlanningLine.VALIDATE("Unit of Measure Code", Res."Base Unit of Measure");
                    JobPlanningLine."Recurso Agrupado" := Res."Recurso Agrupado";
                    if JobPlanningLine."Planning Date" = 0D then
                        JobPlanningLine."Planning Date" := Job."Starting Date";
                    if JobPlanningLine."Fecha Final" = 0D then
                        JobPlanningLine.Validate("Fecha Final", Job."Ending Date");
                    //Si el tipo de recurso es producción entoces "Tipo Duración"='' y Duración =1

                    //Mirar_Estado;
                    // $001 +

                    // $003-
                    JobPlanningLine.Tipo := Job.Tipo;
                    JobPlanningLine."Soporte de" := Job."Soporte de";
                    JobPlanningLine."Fija/Papel" := Job."Fija/Papel";
                    // $003+
                    JobPlanningLine."Subtipo cabecera" := Job.Subtipo;
                    JobPlanningLine."Dimension Set ID" := Procesos.GetDefaultDimID2(JobPlanningLine."Shortcut Dimension 1 Code",
                    JobPlanningLine."Shortcut Dimension 2 Code", JobPlanningLine."Shortcut Dimension 3 Code",
                    JobPlanningLine."Shortcut Dimension 4 Code", JobPlanningLine."Shortcut Dimension 5 Code");
                    If Res."Empresa Origen" <> '' then Tipo.ChangeCompany(Res."Empresa Origen");
                    if not Tipo.Get(Res."Tipo Recurso") Then Tipo.Init();
                    if (Res."Recurso Agrupado" = false) and (Job."Según disponibilidad") And (Tipo."Crea Reservas") Then begin
                        if JobPlanningLine."Recurso en Empresa Origen" = '' then
                            JobPlanningLine."Crear pedidos" := JobPlanningLine."Crear pedidos"::"No crear pedido"
                        else
                            JobPlanningLine."Crear pedidos" := JobPlanningLine."Crear pedidos"::"De Compra";
                        JobPlanningLine.Validate("Imprmir en Contrato/Factura", false);
                    end else begin
                        JobPlanningLine.Validate("Imprmir en Contrato/Factura", true);
                    end;
                    JobPlanningLine."Tipo Duracion" := JobPlanningLine."Tipo Duracion"::" ";
                    // If (Res."Recurso Agrupado" = true) or (Res."Producción" = true) Then
                    //     JobPlanningLine."Tipo Duracion" := JobPlanningLine."Tipo Duracion"::" ";
                    // If (tipo."Crea Reservas") and (Res."Recurso Agrupado" = false) Then
                    //     JobPlanningLine."Tipo Duracion" := JobPlanningLine."Tipo Duracion"::Meses;
                    // if (JobPlanningLine."Shortcut Dimension 1 Code" = 'GENERAL') and (Res."Producción" = false) then
                    //     JobPlanningLine."Tipo Duracion" := JobPlanningLine."Tipo Duracion"::"Días";
                    //FindResUnitCost;
                    if Res."Producción" = true then begin
                        JobPlanningLine."Tipo Duracion" := JobPlanningLine."Tipo Duracion"::" ";
                        JobPlanningLine.Duracion := 1;
                    end;

                END;
            JobPlanningLine.Type::Item:
                BEGIN
                    Item.Get(JobPlanningLine."No.");
                    Item.TESTFIELD(Blocked, FALSE);
                    JobPlanningLine.Description := Item.Description;
                    JobPlanningLine."Description 2" := Item."Description 2";
                    // if Job."Language Code" <> '' THEN
                    //     GetItemTranslation;
                    // GetUnitCost;
                    JobPlanningLine."Gen. Prod. Posting Group" := Item."Gen. Prod. Posting Group";
                    JobPlanningLine.VALIDATE("Unit of Measure Code", Item."Base Unit of Measure");
                END;
            JobPlanningLine.Type::"G/L Account":
                BEGIN
                    GLAcc.GET(JobPlanningLine."No.");
                    GLAcc.CheckGLAcc;
                    GLAcc.TESTFIELD("Direct Posting", TRUE);
                    JobPlanningLine.Description := GLAcc.Name;
                    JobPlanningLine."Gen. Bus. Posting Group" := GLAcc."Gen. Bus. Posting Group";
                    JobPlanningLine."Gen. Prod. Posting Group" := GLAcc."Gen. Prod. Posting Group";
                    JobPlanningLine."Unit of Measure Code" := '';
                    JobPlanningLine."Direct Unit Cost (LCY)" := 0;
                    JobPlanningLine."Unit Cost (LCY)" := 0;
                    JobPlanningLine."Unit Price" := 0;
                END;
            JobPlanningLine.Type::Text:
                BEGIN
                    StdTxt.GET(JobPlanningLine."No.");
                    JobPlanningLine.Description := StdTxt.Description;
                END;
            JobPlanningLine.Type::Familia:
                // $001
                BEGIN
                    rFamilia.GET(JobPlanningLine."No.");
                    JobPlanningLine.Description := rFamilia.Name;
                    JobPlanningLine."Shortcut Dimension 1 Code" := rFamilia."Global Dimension 1 Code";
                    JobPlanningLine."Shortcut Dimension 2 Code" := rFamilia."Global Dimension 2 Code";
                    JobPlanningLine."Compra a-Nº proveedor" := rFamilia."Nº proveedor";
                    // { en migracion a 5.0 no se traspasan precios, pte si lo necesitan
                    // if ResCost.GET(ResCost.Type::"Group(Resource)","No.",'') AND
                    //     (ResCost."Cost Type" = ResCost."Cost Type"::Fixed)
                    // THEN BEGIN
                    //     "Direct Unit Cost" := ResCost."Direct Unit Cost";
                    //     "Unit Cost" := ResCost."Unit Cost";
                    // END;
                    // if ResPrice.GET("Job No.",1,"No.",'') THEN
                    //     "Unit Price" := ResPrice."Unit Price"
                    // ELSE
                    //     if ResPrice.GET('',1,"No.",'') THEN
                    //     "Unit Price" := ResPrice."Unit Price"
                    // }
                END;
        END;
        if JobPlanningLine."Type" <> JobPlanningLine.Type::Text then
            JobPlanningLine.Quantity := 1;
        if JobPlanningLine."Type" = JobPlanningLine.Type::Resource then begin
            if not Tipo.Get(Res."Tipo Recurso") Then Tipo.Init();
            if Res."Producción" then Tipo."Crea Reservas" := false;
            if Res."Recurso Agrupado" then Tipo."Crea Reservas" := false;
            iF rES."Empresa Origen" <> '' tHEN Tipo."Crea Reservas" := FALSE;
            if Tipo."Crea Reservas" Then JobPlanningLine."Cdad. a Reservar" := 1;
        end

    end;

    // [EventSubscriber(ObjectType::Table, Database::"Job Planning Line", 'OnAfterInsertEvent', '', false, false)]
    // local procedure OnAfterInsertEventJobLine(var Rec: Record "Job Planning Line")
    // Var
    //     rSelf: Record "Job Planning Line";
    //     Job: Record Job;
    //     Text50001: Label 'OJO. El proyecto ya esta en estado Contrato, y ya se han \creado los pedidos de venta y compra. Si quiere modificarlos\debera hacerlo a mano.';
    // Begin
    //     Job.Get(Rec."Job No.");
    //     // $001 -
    //     Job.TESTFIELD("Cód. vendedor");
    //     if Job.Status = Job.Status::Open THEN
    //         MESSAGE(Text50001);
    //     Rec."Planning Date" := Job."Starting Date";
    //     Rec."Fecha Final" := Job."Ending Date";
    //     //Mirar_Estado;
    //     // $001 +

    //     // $003-
    //     Rec.Tipo := Job.Tipo;
    //     Rec."Soporte de" := Job."Soporte de";
    //     Rec."Fija/Papel" := Job."Fija/Papel";
    //     // $003+
    //     Rec."Subtipo cabecera" := Job.Subtipo;                                //$009

    //     rSelf.SETRANGE(rSelf."Job No.", Rec."Job No.");
    //     rSelf.SETRANGE(rSelf."Job Task No.", Rec."Job Task No.");
    //     if rSelf.FINDLAST THEN
    //         Rec."Line No." := rSelf."Line No." + 10000;
    //     // if BuscarecursosRelacionados("Line No.", "Job No.", "No.") = FALSE THEN
    //     //   Produccion;

    // end;

    [EventSubscriber(ObjectType::Table, Database::"Job Planning Line", 'OnBeforeCalcQuantityBase', '', false, false)]
    local procedure OnBeforeCalcQuantityBase(var JobPlanningLine: Record "Job Planning Line"; xJobPlanningLine: Record "Job Planning Line"; CurrentFieldNo: Integer; var IsHandled: Boolean)
    var
        Res: Record "Resource";
        Job: Record "Job";
        rDia: Record "Diario Reserva";
        rTexto: Record "Texto Presupuesto";
        rTipus: Record "Tipo Recurso";
        rFamilia: Record "Resource Group";
        rOrden: Record "Cab. orden publicidad";
        Text50000: Label 'Cuidado! La fecha de final es menor a la fecha de inicio.';
        Text50001: Label 'OJO. El proyecto ya esta en estado Contrato, y ya se han \creado los pedidos de venta y compra. Si quiere modificarlos\debera hacerlo a mano.';
        Text50002: Label 'Esta linea ya tiene reservas asociadas. No se puede modificar este campo.';
        Text50003: Label 'No se puede eliminar esta linea, ya que tiene una orden de publicidad Validada.';
    begin
        if Not Res.GET(JobPlanningLine."No.") then Res.init;
        if ((xJobPlanningLine.Quantity <> JobPlanningLine.Quantity) AND
                (JobPlanningLine."Cdad. Reservada" <> 0) AND
                (JobPlanningLine.Quantity < JobPlanningLine."Cdad. Reservada")) THEN
            ERROR(Text50002);
        // $001 -
        if (JobPlanningLine.Quantity <> 0) AND (xJobPlanningLine.Quantity <> JobPlanningLine.Quantity) THEN BEGIN
            if ((JobPlanningLine.Type = JobPlanningLine.Type::Resource) AND ((JobPlanningLine.Quantity + JobPlanningLine."Cdad. a Reservar") > 1)) THEN BEGIN
                Res.GET(JobPlanningLine."No.");
                if rTipus.GET(Res."Tipo Recurso") THEN BEGIN
                    //if (rTipus.Exterior) THEN
                    //ERROR('Este recurso solo puede presupuestarse en una unidad');
                END;
            END;
            if ((JobPlanningLine.Type = JobPlanningLine.Type::Resource) OR (JobPlanningLine.Type = JobPlanningLine.Type::Familia)) THEN BEGIN
                if rTipus.GET(Res."Tipo Recurso") THEN BEGIN

                    if (rTipus."Crea Reservas") AND (Res."Empresa Origen" = '') and (Res."Recurso Agrupado" = false) THEN BEGIN
                        if (JobPlanningLine."Cdad. a Reservar" > 1) then //JobPlanningLine.Quantity) THEN
                            ERROR('No puede introducir esta cantidad.');
                    END;
                END;
                if (JobPlanningLine.Type = JobPlanningLine.Type::Resource) THEN BEGIN
                    if Res.GET(JobPlanningLine."No.") THEN BEGIN
                        if rTipus.GET(Res."Tipo Recurso") THEN BEGIN
                            if (rTipus."Crea Reservas") AND (Res."Empresa Origen" = '') and (Res."Recurso Agrupado" = false) and (Res."Producción" = false) THEN BEGIN
                                if (rTipus.Exterior) THEN BEGIN
                                    // JobPlanningLine."Cdad. a Reservar" := JobPlanningLine."Cdad. a Reservar" + (JobPlanningLine.Quantity - xJobPlanningLine.Quantity);
                                    // if JobPlanningLine."Cdad. a Reservar" > JobPlanningLine."Cdad. a Reservar" Then
                                    //     JobPlanningLine."Cdad. a Reservar" := JobPlanningLine.Quantity;
                                    // if JobPlanningLine."Cdad. a Reservar" > 1 Then
                                    JobPlanningLine."Cdad. a Reservar" := 1 - JobPlanningLine."Cdad. Reservada";
                                END ELSE BEGIN
                                    if (JobPlanningLine."Cdad. Reservada" = 0) THEN BEGIN
                                        JobPlanningLine."Cdad. a Reservar" := 1;
                                    END;
                                END;
                            END;
                        END;
                    END;
                END ELSE BEGIN
                    JobPlanningLine."Cdad. a Reservar" := JobPlanningLine."Cdad. a Reservar" - JobPlanningLine."Cdad. Reservada";
                    //+ (JobPlanningLine.Quantity - xJobPlanningLine.Quantity);
                    if JobPlanningLine."Cdad. a Reservar" > JobPlanningLine."Cdad. a Reservar" Then
                        JobPlanningLine."Cdad. a Reservar" := 1;//JobPlanningLine.Quantity;
                END;
            END;
            //Busca_Tarifa;                                  //$012
        END ELSE BEGIN
            if (JobPlanningLine.Quantity = 0) THEN
                JobPlanningLine."Cdad. a Reservar" := 0;
        END;
        if JobPlanningLine."Cdad. a Reservar" > 1 Then // JobPlanningLine.Quantity then
            if JobPlanningLine.Quantity > 0 then
                JobPlanningLine."Cdad. a Reservar" := 1;//JobPlanningLine.Quantity;
        // $001 +
        if Res."Recurso Agrupado" Then JobPlanningLine."Cdad. a Reservar" := 0;
        if Res."Producción" Then JobPlanningLine."Cdad. a Reservar" := 0;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Job Planning Line", 'OnAfterValidateEvent', 'Quantity', false, false)]
    procedure ModificaQuantityJobPlaning(var Rec: Record "Job planning Line"; var xRec: Record "Job Planning Line"; CurrFieldNo: Integer)
    var
        Control: Codeunit "ControlProcesos";
        Res: Record Resource;
        Job: Record Job;
        Customer: Record Customer;
    begin
        if Rec.Type <> Rec.Type::Resource then exit;

        if Not Res.Get(Rec."No.") then exit;
        if Not Job.Get(Rec."Job No.") then exit;
        If not Customer.Get(Job."Bill-to Customer No.") then exit;
        if Rec."Precio Tarifa" = 0 Then
            Rec."Precio Tarifa" := Control.FindResourcePriceNew(Customer."Customer Posting Group" = 'AGENCIA', Res."Customer Price Group", WorkDate(), Rec."VAT %", Job, Res."No."
            , Rec."Cdad. Soportes", rec.Duracion, Rec."Tipo Duracion");
        if Rec."Crear pedidos" = Rec."Crear pedidos"::"No crear pedido" then
            Rec."Unit Price" := 0 else
            If Rec."Unit Price" = 0 Then Rec."Unit Price" := Rec."Precio Tarifa";

    end;
    #endregion Tabla1003
    #region Tabla5080
    [EventSubscriber(ObjectType::Table, Database::"To-do", OnAfterDeleteEvent, '', false, false)]
    local procedure OnAfterDeleteEvent(var Rec: Record "To-do"; RunTrigger: Boolean)
    var
        SalesHeader: Record "Sales Header";
    begin
        If SalesHeader.get(SalesHeader."Document Type"::Order, Rec."No.") then begin
            SalesHeader."Ofrecida ampliación" := false;
            SalesHeader.Modify;
        end;
    end;
    #endregion Tabla580
    #region TableNombres
    [EventSubscriber(ObjectType::Table, Database::"Nombre Comercial", 'OnAfterRenameEvent', '', false, false)]
    Procedure OnRenameNom(Rec: Record "Nombre Comercial"; xRec: Record "Nombre Comercial")
    var
        Emp: Record Company;
        Job: Record Job;
        Contratos: Record "Sales Header";
        Customer: Record Customer;
        Control: Codeunit ControlProcesos;
    begin

        if Emp.FindFirst() Then
            repeat
                if Control.Permiso_Empresas(Emp.Name) then begin
                    Job.ChangeCompany(emp.Name);
                    Job.SetRange("Nombre Comercial", xRec.Nombre);
                    Job.ModifyAll("Nombre Comercial", Rec.Nombre);
                    if Job.FindFirst() then Error('No se puede Cambiar, porque el contrato %1 de la empresa %2, usa este nombre', Job."No.", Emp.Name);
                    Contratos.ChangeCompany(emp.Name);
                    Contratos.SetRange("Nombre Comercial", xRec.Nombre);
                    Contratos.ModifyAll("Nombre Comercial", Rec.Nombre);
                    if Contratos.FindFirst() then Error('No se puede Cambiar, porque el contrato %1 de la empresa %2, usa este nombre', Contratos."No.", Emp.Name);
                    Customer.ChangeCompany(emp.Name);
                    Customer.SetRange("Nombre Comercial", xRec.Nombre);
                    Customer.ModifyAll("Nombre Comercial", Rec.Nombre);
                    if Customer.FindFirst() then Error('No se puede Cambiar, porque el cliente %1 de la empresa %2, usa este nombre', Customer."No.", Emp.Name);
                end;
            until Emp.Next() = 0;
    end;
    #endregion TableNombres
    #region Tabla349
    [EventSubscriber(ObjectType::Table, Database::"Dimension Value", 'OnAfterInsertEvent', '', false, false)]
    local procedure DimensionValue_OnAfterInsert(var Rec: Record "Dimension Value"; RunTrigger: Boolean)
    var
        Company: Record Company;
        DimVal: Record "Dimension Value";
    begin
        if not RunTrigger then exit;
        if Company.FindFirst() Then begin
            if Company.Name <> CompanyName Then
                repeat
                    If Procesos.Permiso_Empresas(Company.Name) Then begin
                        DimVal.ChangeCompany(Company.Name);
                        if DimVal.get(Rec."Dimension Code", Rec.Code) Then DimVal.Delete(false);
                        DimVal := Rec;
                        DimVal.Insert(false);
                    end;
                Until Company.Next() = 0;
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Dimension Value", OnAfterModifyEvent, '', false, false)]
    local procedure DimensionValue_OnAfterModify(var Rec: Record "Dimension Value"; var xRec: Record "Dimension Value"; RunTrigger: Boolean)
    var
        Company: Record Company;
        DimVal: Record "Dimension Value";
    begin
        if not RunTrigger then exit;
        if Company.FindFirst() Then begin
            if Company.Name <> CompanyName Then
                repeat
                    If Procesos.Permiso_Empresas(Company.Name) Then begin
                        DimVal.ChangeCompany(Company.Name);
                        if DimVal.get(Rec."Dimension Code", Rec.Code) Then DimVal.Delete(false);
                        DimVal := Rec;
                        DimVal.Insert(false);
                    end;
                Until Company.Next() = 0;
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Dimension Value", OnAfterDeleteEvent, '', false, false)]
    local procedure DimensionValue_OnAfterDelete(var Rec: Record "Dimension Value"; RunTrigger: Boolean)
    var
        Company: Record Company;
        DimVal: Record "Dimension Value";
    begin
        if not RunTrigger then exit;
        if Company.FindFirst() Then begin
            if Company.Name <> CompanyName Then
                repeat
                    If Procesos.Permiso_Empresas(Company.Name) Then begin
                        DimVal.ChangeCompany(Company.Name);
                        if DimVal.get(Rec."Dimension Code", Rec.Code) Then DimVal.Delete(false);
                    end;
                Until Company.Next() = 0;
        end;
    end;
    #endregion Tabla349
    #region Tabla348
    [EventSubscriber(ObjectType::Table, Database::"Dimension", 'OnAfterInsertEvent', '', false, false)]
    local procedure Dimension_OnAfterInsert(var Rec: Record "Dimension"; RunTrigger: Boolean)
    var
        Company: Record Company;
        DimVal: Record "Dimension";
    begin
        if not RunTrigger then exit;
        if Company.FindFirst() Then begin
            if Company.Name <> CompanyName Then
                repeat
                    If Procesos.Permiso_Empresas(Company.Name) Then begin
                        DimVal.ChangeCompany(Company.Name);
                        if DimVal.get(Rec."Code") Then DimVal.Delete(false);
                        DimVal := Rec;
                        if DimVal.Insert Then;
                    end;
                Until Company.Next() = 0;
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Dimension", OnAfterModifyEvent, '', false, false)]
    local procedure Dimension_OnAfterModify(var Rec: Record "Dimension"; var xRec: Record "Dimension"; RunTrigger: Boolean)
    var
        Company: Record Company;
        DimVal: Record "Dimension";
    begin
        if not RunTrigger then exit;
        if Company.FindFirst() Then begin
            if Company.Name <> CompanyName Then
                repeat
                    If Procesos.Permiso_Empresas(Company.Name) Then begin
                        DimVal.ChangeCompany(Company.Name);
                        if DimVal.get(Rec.Code) Then DimVal.Delete(false);
                        DimVal := Rec;
                        if DimVal.Insert Then;
                    end;
                Until Company.Next() = 0;
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Dimension", OnAfterDeleteEvent, '', false, false)]
    local procedure Dimension_OnAfterDelete(var Rec: Record "Dimension"; RunTrigger: Boolean)
    var
        Company: Record Company;
        DimVal: Record "Dimension";
    begin
        if not RunTrigger then exit;
        if Company.FindFirst() Then begin
            if Company.Name <> CompanyName Then
                repeat
                    If Procesos.Permiso_Empresas(Company.Name) Then begin
                        DimVal.ChangeCompany(Company.Name);
                        if DimVal.get(Rec.Code) Then DimVal.Delete(false);
                    end;
                Until Company.Next() = 0;
        end;
    end;
    #endregion Tabla348
    #region Tabla120
    [EventSubscriber(ObjectType::Table, Database::"Purch. Rcpt. Header", OnAfterDeleteEvent, '', false, false)]
    local procedure PurchRcptHeader_OnAfterDelete(var Rec: Record "Purch. Rcpt. Header"; RunTrigger: Boolean)
    begin
        if RunTrigger then
            if Rec.Contabilizado then
                Procesos.BORRCAALB();
    end;
    #endregion Tabla120
    #region Tabla481
    [EventSubscriber(ObjectType::Table, Database::"Dimension Value Combination", 'OnAfterInsertEvent', '', false, false)]
    local procedure DimensionValueCombination_OnAfterInsert(var Rec: Record "Dimension Value Combination")
    var
        RecFef: RecordRef;
    begin
        RecFef.GetTable(Rec);
        Procesos.Inserta(RecFef, CompanyName);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Dimension Value Combination", OnAfterModifyEvent, '', false, false)]
    local procedure DimensionValueCombination_OnAfterModify(var Rec: Record "Dimension Value Combination"; var xRec: Record "Dimension Value Combination")
    var
        RecFef: RecordRef;
    begin
        RecFef.GetTable(Rec);
        Procesos.Modifica(RecFef, CompanyName);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Dimension Value Combination", 'OnBeforeDeleteEvent', '', false, false)]
    local procedure DimensionValueCombination_OnBeforeDelete(var Rec: Record "Dimension Value Combination")
    var
        RecFef: RecordRef;
    begin
        RecFef.GetTable(Rec);
        Procesos.Borra(RecFef, CompanyName);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Dimension Value Combination", 'OnBeforeRenameEvent', '', false, false)]
    local procedure DimensionValueCombination_OnBeforeRename(var Rec: Record "Dimension Value Combination"; var xRec: Record "Dimension Value Combination")
    begin
        Error('No es posible renombrar tablas compartidas');
    end;
    #endregion Tabla481
    #region Tabla1003
    [EventSubscriber(ObjectType::Table, Database::"Job Planning Line", 'OnAfterValidateEvent', 'Cartel', false, false)]
    local procedure JobPlanningLine_OnAfterValidate_Cartel(var Rec: Record "Job Planning Line"; var xRec: Record "Job Planning Line")
    var
        Control: Codeunit "ControlProcesos";
    begin
        If Rec.Cartel then
            Control.CrearLineaProduccion(Rec, 'Cartel', false, Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Job Planning Line", 'OnAfterValidateEvent', 'Lona', false, false)]
    local procedure JobPlanningLine_OnAfterValidate_Lona(var Rec: Record "Job Planning Line"; var xRec: Record "Job Planning Line")
    var
        Control: Codeunit "ControlProcesos";
    begin
        If Rec.Lona then
            Control.CrearLineaProduccion(Rec, 'Lona', false, Rec);
    end;
    //Vinilo
    [EventSubscriber(ObjectType::Table, Database::"Job Planning Line", 'OnAfterValidateEvent', 'Vinilo', false, false)]
    local procedure JobPlanningLine_OnAfterValidate_Vinilo(var Rec: Record "Job Planning Line"; var xRec: Record "Job Planning Line")
    var
        Control: Codeunit "ControlProcesos";
    begin
        If Rec.Vinilo then
            Control.CrearLineaProduccion(Rec, 'Vinilo', false, Rec);
    end;
    //Otros 
    [EventSubscriber(ObjectType::Table, Database::"Job Planning Line", 'OnAfterValidateEvent', 'Otros', false, false)]
    local procedure JobPlanningLine_OnAfterValidate_Otros(var Rec: Record "Job Planning Line"; var xRec: Record "Job Planning Line")
    var
        Control: Codeunit "ControlProcesos";
    begin
        If Rec.Otros then
            Control.CrearLineaProduccion(Rec, 'Otros', false, Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Job Planning Line", 'OnAfterValidateEvent', 'Solo Producción', false, false)]
    local procedure JobPlanningLine_OnAfterValidate_SoloProduccion(var Rec: Record "Job Planning Line"; var xRec: Record "Job Planning Line")
    var
        Prod: Record "Recursos de Producción";
        Asis: Page "Wizard Producción";
        L: Integer;
        LL: Integer;
        Linea: Record "Job Planning Line";
        TR: Record "Tipo Recurso";
        T: Code[20];
        rLin: Record 1003 temporary;
        Resource: Record Resource;
        Crear: Boolean;
        Control: Codeunit "ControlProcesos";
    begin
        Rec."Sin Producción" := false;

        if Rec."Solo Producción" then begin
            If Not Resource.Get(Rec."No.") Then Resource.Init;
            If not Resource."Producción" then Begin
                Crear := true;
                Linea.SetRange("Job No.", Rec."No.");
                T := '10';
                Linea.SetRange("Job Task No.", T);
                if Linea.FindLast() Then begin
                    LL := Rec."Line No.";
                    L := Linea."Line No.";
                    T := Linea."Job Task No.";
                end else
                    Rec.Init();
            end;
            Asis.Carga(Rec."Job No.", Rec."No.");
            Asis.RunModal();
            Asis.GetRecord(Prod);
            If Crear then begin
                Linea.Init();
                Linea."Job No." := Rec."Job No.";
                Linea."Job Task No." := T;
                if Prod.Incluida then
                    Linea."Crear pedidos" := Linea."Crear pedidos"::"De Compra"
                else
                    Linea."Crear pedidos" := Linea."Crear pedidos"::"De Compra Y De Venta";
                Linea."Line No." := l + 10000;
                Linea."Type" := Linea."Type"::Resource;
                Linea.Validate("No.", Prod."Recurso No.");
                Linea.Validate(Quantity, 1);
                if Prod.Incluida then Linea."Origin Line No." := LL;
                if Prod.Incluida = false then begin
                    Linea.Validate("Unit Price", Prod.Venta);
                    Linea.Validate("% Dto. Venta", Prod."Descuento Venta");
                end;
                Linea.Validate("Unit Cost", Prod.Compra);
                Linea.Validate("% Dto. Compra", Prod."Descuento Compra");
                TR.Get(Prod."Tipo de Soporte");
                Linea.Description := Prod.Descripcion;
                Linea.Validate("Shortcut Dimension 3 Code", TR."Cód. Principal");
                Linea.Insert();
                Commit();
                Asis.Lineas(rlin);
                if rLin.Count = 0 then
                    Control.ProduccionNueva(Rec, Prod.Empresa, prod."Nº Proyecto")
                else
                    Control.ProduccionNuevaxLinea(Rec, Prod.Empresa, rLin);
            end else begin
                if Prod.Incluida then
                    Rec."Crear pedidos" := Rec."Crear pedidos"::"De Compra"
                else
                    Rec."Crear pedidos" := Rec."Crear pedidos"::"De Compra Y De Venta";
                Rec."Type" := Linea."Type"::Resource;
                Rec.Validate("No.", Prod."Recurso No.");
                Rec.Validate(Quantity, 1);
                if Prod.Incluida then Rec."Origin Line No." := LL;
                if Prod.Incluida = false then begin
                    Rec.Validate("Unit Price", Prod.Venta);
                    Rec.Validate("% Dto. Venta", Prod."Descuento Venta");
                end;
                Rec.Validate("Unit Cost", Prod.Compra);
                Rec.Validate("% Dto. Compra", Prod."Descuento Compra");
                TR.Get(Prod."Tipo de Soporte");
                Rec.Description := Prod.Descripcion;
                Rec.Validate("Shortcut Dimension 3 Code", TR."Cód. Principal");
                Rec.Modify();
                Commit();
                Asis.Lineas(rlin);
                if rLin.Count = 0 then
                    Control.ProduccionNueva(Rec, Prod.Empresa, prod."Nº Proyecto")
                else
                    Control.ProduccionNuevaxLinea(Rec, Prod.Empresa, rLin);
            end;
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Job Planning Line", 'OnAfterInsertEvent', '', false, false)]
    local procedure JobPlanningLine_OnAfterInsert(var Rec: Record "Job Planning Line"; RunTrigger: Boolean)
    var
        rSelf: Record "Job Planning Line";
        Job: Record Job;
        EsJulia: Boolean;
        Text50001: Label 'OJO. El proyecto ya esta en estado Contrato, y ya se han \creado los pedidos de venta y compra. Si quiere modificarlos\debera hacerlo a mano.';
    begin
        If Rec."No." = '' Then Exit;
        If Not Job.Get(Rec."Job No.") Then exit;
        If Rec.IsTemporary() Then Exit;
        EsJulia := UserId in ['GRUPOMALLA\JULIÀ.SASTRE', 'JULIÀ.SASTRE'];
        // $001 -
        if RunTrigger then
            Job.TESTFIELD("Cód. vendedor");
        if Job.Status = Job.Status::Open THEN
            If not EsJulia then
                If RunTrigger then MESSAGE(Text50001);
        Rec."Planning Date" := Job."Starting Date";
        Rec."Fecha Final" := Job."Ending Date";
        //Mirar_Estado;
        // $001 +

        // $003-
        Rec.Tipo := Job.Tipo;
        Rec."Soporte de" := Job."Soporte de";
        Rec."Fija/Papel" := Job."Fija/Papel";
        // $003+
        Rec."Subtipo cabecera" := Job.Subtipo;

        rSelf.SETRANGE(rSelf."Job No.", Rec."Job No.");
        rSelf.SETRANGE(rSelf."Job Task No.", Rec."Job Task No.");
        if rSelf.FINDLAST THEN
            If Rec."Line No." = 0 Then
                Rec."Line No." := rSelf."Line No." + 10000;
        // if BuscarecursosRelacionados("Line No.", "Job No.", "No.") = FALSE THEN
        //   Produccion;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Job Planning Line", OnAfterModifyEvent, '', false, false)]
    local procedure JobPlanningLine_OnAfterModify(var Rec: Record "Job Planning Line"; var xRec: Record "Job Planning Line"; RunTrigger: Boolean)
    begin
        if xRec."No." <> Rec."No." THEN BEGIN
            //  VALIDATE("Unit Price", 0);
            if RunTrigger then
                Rec.BorrarecursosRelacionados(Rec."Line No.", Rec."Job No.");
        END;
        //if BuscarecursosRelacionados("Line No.", "Job No.", "No.") = FALSE THEN
        //  Produccion; TODO Revisar
    end;

    [EventSubscriber(ObjectType::Table, Database::"Job Planning Line", OnAfterDeleteEvent, '', false, false)]
    local procedure JobPlanningLine_OnAfterDelete(var Rec: Record "Job Planning Line"; RunTrigger: Boolean)
    var
        rSelf: Record "Job Planning Line";
        rOrden: Record "Cab. orden publicidad";
        rTexto: Record "Texto Presupuesto";
        Text50003: Label 'No se puede eliminar esta linea, ya que tiene una orden de publicidad Validada.';
    begin
        //TESTFIELD(Transferred,FALSE);
        if not RunTrigger then exit;

        Rec.BorrarecursosRelacionados(Rec."Line No.", Rec."Job No.");
        // MNC 211098
        if (Rec."Cdad. Reservada" <> 0) THEN
            ERROR('No se puede borrar esta linea, porque ya se han creado reservas');
        Rec.CALCFIELDS("No. Orden Publicidad");
        if (Rec."No. Orden Publicidad" <> '') THEN BEGIN
            if (Rec."Estado Orden Publicidad" = Rec."Estado Orden Publicidad"::Validada) THEN
                ERROR(Text50003);
            rOrden.RESET;
            if rOrden.GET(Rec."No. Orden Publicidad") Then
                rOrden.DELETE(TRUE);
        END;

        rTexto.SETRANGE("Nº proyecto", Rec."Job No.");
        //  $001 -
        // {
        // rTexto.SETRANGE("Cód. fase","Phase Code");
        // rTexto.SETRANGE("Cód. subfase","Task Code");
        // rTexto.SETRANGE("Cód. tarea","Step Code");
        // }
        rTexto.SETRANGE("Cód. tarea", Rec."Job Task No.");
        rTexto.SETRANGE("Nº linea aux", Rec."Line No.");
        //  $001 +
        rTexto.SETRANGE(Tipo, Rec.Type.AsInteger());
        rTexto.SETRANGE("Nº", Rec."No.");
        rTexto.SETRANGE("Cód. variante", Rec."Variant Code");
        rTexto.DELETEALL;
        // Fi MNC
        rSelf.SETRANGE(rSelf."Job No.", Rec."Job No.");
        rSelf.SETRANGE("Origin Line No.", Rec."Line No.");
        rSelf.DELETEALL;
    end;
    #endregion Tabla1003
    #region Tabla289
    [EventSubscriber(ObjectType::Table, Database::"Payment Method", 'OnAfterInsertEvent', '', false, false)]
    local procedure PaymentMethod_OnAfterInsert(var Rec: Record "Payment Method"; RunTrigger: Boolean)
    var
        RecFef: RecordRef;
    begin
        If Rec.IsTemporary() Then Exit;
        RecFef.GetTable(Rec);
        If not Procesos.CompruebaPermisos(UserSecurityId, 'FORMAPAGO', CompanyName) then
            Error('No tienes permisos para insertar formas de pago');
        Procesos.Inserta(RecFef, CompanyName);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Payment Method", OnAfterModifyEvent, '', false, false)]
    local procedure PaymentMethod_OnAfterModify(var Rec: Record "Payment Method"; var xRec: Record "Payment Method"; RunTrigger: Boolean)
    var
        RecFef: RecordRef;
    begin
        if Rec.IsTemporary() Then Exit;
        RecFef.GetTable(Rec);
        If not Procesos.CompruebaPermisos(UserSecurityId, 'FORMAPAGO', CompanyName) then
            Error('No tienes permisos para modificar formas de pago');
        Procesos.Modifica(RecFef, CompanyName);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Payment Method", 'OnBeforeDeleteEvent', '', false, false)]
    local procedure PaymentMethod_OnBeforeDelete(var Rec: Record "Payment Method")
    var
        RecFef: RecordRef;
    begin
        RecFef.GetTable(Rec);
        If not Procesos.CompruebaPermisos(UserSecurityId, 'FORMAPAGO', CompanyName) then
            Error('No tienes permisos para borrar formas de pago');
        Procesos.Borra(RecFef, CompanyName);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Payment Method", 'OnBeforeRenameEvent', '', false, false)]
    local procedure PaymentMethod_OnBeforeRename(var Rec: Record "Payment Method"; var xRec: Record "Payment Method")
    begin
        Error('No es posible renombrar tablas compartidas');
    end;
    #endregion Tabla289
    #region Tabla156
    [EventSubscriber(ObjectType::Table, Database::Resource, 'OnAfterValidateEvent', 'Fecha baja', false, false)]
    local procedure Resource_OnAfterValidate_FechaBaja(var Rec: Record Resource; var xRec: Record Resource)
    var
        rAct: Record 5600;
    begin
        rAct.SETRANGE(rAct.Recurso, Rec."No.");
        if rAct.FINDFIRST THEN BEGIN
            // MESSAGE('Este recurso tiene un activo relacionado. Se va a dar de baja');
            Procesos.Baja(rAct."No.", Rec."No.");
        END;
    end;
    #endregion Tabla156
    #region Tabla36
    [EventSubscriber(ObjectType::Table, Database::"Sales Header", 'OnAfterValidateEvent', 'Fecha Estado', false, false)]
    local procedure SalesHeader_OnAfterValidate_FechaEstado(var Rec: Record "Sales Header"; var xRec: Record "Sales Header")
    var
        rConfigProy: Record "Jobs Setup";
        Text062: Label 'No se puede modificar la fecha estado';
        Procesos: Codeunit "Gestion Facturación";
    begin
        rConfigProy.GET();
        if NOT rConfigProy."Poder modificar fecha firmado" THEN BEGIN
            if ((Rec."Fecha Estado" <> xRec."Fecha Estado") AND
                (xRec."Fecha Estado" <> 0D)) THEN
                ERROR(Text062);
        END;
        if (Rec."Fecha Estado" <> xRec."Fecha Estado") Then
            Procesos.EnviarMailJm(Rec."No.", STRSUBSTNO('modificado la fecha estado de %1 a %2', xRec."Fecha Estado", Rec."Fecha Estado"));
    end;
    #endregion Tabla36
    #region Tabla7001114
    [EventSubscriber(ObjectType::Table, 7001114, 'OnAfterValidateEvent', 'fecha Baja', false, false)]
    local procedure Resource3_OnAfterValidate_FechaBaja(var Rec: Record 7001114; var xRec: Record 7001114)
    var
        rAct: Record 5600;
    begin
        rAct.SETRANGE(rAct.Recurso, Rec."No.");
        if rAct.FINDFIRST THEN BEGIN
            // MESSAGE('Este recurso tiene un activo relacionado. Se va a dar de baja');
            Procesos.Baja(rAct."No.", Rec."No.");
        END;
    end;
    #endregion Tabla7001114
    #region TablaLinOrdenPublicidad
    [EventSubscriber(ObjectType::Table, Database::"Lin. orden publicidad", OnAfterDeleteEvent, '', false, false)]
    local procedure LinOrdenPublicidad_OnAfterDelete(var Rec: Record "Lin. orden publicidad"; RunTrigger: Boolean)
    var
        cMedios: Codeunit "Gestion Medios";
        rOrden: Record "Cab. orden publicidad";
        rLinOrden: Record "Lin. orden publicidad";
        wFechaIni: Date;
        wFechaFin: Date;

    begin
        if not RunTrigger then exit;
        if Rec."Dia conjunto" <> 0D THEN begin
            rLinOrden.RESET;
            rLinOrden.SETRANGE("Tipo orden", Rec."Tipo orden");
            rLinOrden.SETRANGE("No. orden", Rec."No. orden");
            rLinOrden.SETFILTER("No. linea", '<>%1', Rec."No. linea");              // Recalcular todas las lineas excepto la que borramos
            rLinOrden.SETRANGE("Dia conjunto", Rec."Dia conjunto");
            if rLinOrden.FIND('-') THEN
                wFechaIni := rLinOrden."Fecha inicio";
            if rLinOrden.FIND('+') THEN
                wFechaFin := rLinOrden."Fecha inicio";
            if (wFechaIni <> 0D) AND (wFechaFin <> 0D) THEN BEGIN
                rLinOrden.DELETEALL;
                if rOrden.GET(Rec."No. orden") THEN
                    cMedios.GenerarLineasOrden(rOrden, wFechaIni, wFechaFin, 0);
            END;
        end;
    end;




    #endregion TablaLinOrdenPublicidad

    #endregion Tables
}