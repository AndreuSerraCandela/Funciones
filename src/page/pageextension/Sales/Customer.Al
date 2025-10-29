/// <summary>
/// PageExtension CustomerKuara (ID 80134) extends Record Customer Card.
/// </summary>
pageextension 80134 CustomerKuara extends "Customer Card"
{

    // Permissions=TableData 21=rimd,
    //         TableData 25=rimd,
    //         TableData 379=rimd,
    //         TableData 380=rimd;

    layout
    {
        addafter(Name)
        {
            field("Nombre Comercial"; Rec."Nombre Comercial")
            {
                Caption = 'Anunciante';
                ApplicationArea = All;
            }
            field("Tipo Cliente"; Rec."Tipo Cliente")
            {
                ApplicationArea = All;
            }
        }
        addafter("Prices Including VAT")
        {
            field("Generar facturas a 0"; Rec."Generar facturas a 0") { ApplicationArea = All; }

        }
        addafter("Country/Region Code")
        {
            field("Tipo ID receptor"; Rec."Tipo ID receptor")
            { }
            field("ID receptor"; Rec."ID receptor")
            { }
        }
        modify("Balance (LCY)")
        {
            Visible = true;
            trigger OnDrillDown()
            VAR
                DtldCustLedgEntry: Record 379;
                CustLedgEntry: Record 21;
            BEGIN
                DtldCustLedgEntry.SETRANGE("Customer No.", Rec."No.");
                Rec.COPYFILTER("Global Dimension 1 Filter", DtldCustLedgEntry."Initial Entry Global Dim. 1");
                Rec.COPYFILTER("Global Dimension 2 Filter", DtldCustLedgEntry."Initial Entry Global Dim. 2");
                Rec.COPYFILTER("Currency Filter", DtldCustLedgEntry."Currency Code");
                CustLedgEntry.DrillDownOnEntries(DtldCustLedgEntry);
            END;
        }
        addafter("Balance (LCY)")
        {
            field("Saldo en Contab"; Rec."Saldo en Contab") { ApplicationArea = All; Visible = SaldoenContabVISIBLE; }
            field("Saldo en Efecto"; Rec."Saldo en Efecto") { ApplicationArea = All; }
            field("Saldo real (DL)"; Rec."Saldo real (DL)") { ApplicationArea = All; }
            field("Saldo real periodo (DL)"; Rec."Saldo real periodo (DL)") { ApplicationArea = All; }
            field("Saldo en Cta Efectos"; Rec."Saldo en Cta Efectos") { ApplicationArea = All; }
            group(Comentarios)
            {
                Editable = CurrPageEditable;
                field(MatComent1; MatComent[1]) { ApplicationArea = All; ShowCaption = false; }
                field(MatComent2; MatComent[2]) { ApplicationArea = All; ShowCaption = false; }
                field(MatComent3; MatComent[3]) { ApplicationArea = All; ShowCaption = false; }
                field(MatComent4; MatComent[4]) { ApplicationArea = All; ShowCaption = false; }
                field(MatComent5; MatComent[5]) { ApplicationArea = All; ShowCaption = false; }
            }
            field("Fecha ult movimiento"; Rec."Fecha ult movimiento") { ApplicationArea = All; }
            field("Fecha ult factura"; Rec."Fecha ult factura") { ApplicationArea = All; }
            field("Omitir 347"; Rec."Omitir 347") { ApplicationArea = All; }
            field(Impagados; Rec.Impagados) { ApplicationArea = All; }
            field("Saldo en Contab UAT"; Rec."Saldo en Contab UAT") { ApplicationArea = All; Visible = SaldoenContabUATVISIBLE; }
            field("Fecha primer movimiento"; Rec."Fecha primer movimiento") { ApplicationArea = All; }
        }
        addafter("E-Mail")
        {
            field("Correo Facturación"; Correo)
            {
                ApplicationArea = All;
                ToolTip = 'Nuevo mensaje correo';
                trigger OnValidate()
                begin
                    If StrLen(Correo) > MaxStrLen(Rec."E-Mail-Facturación") then
                        Message('El correo no puede tener más de %1 caracteres, se perderán los últimos %2 caracteres', MaxStrLen(Rec."E-Mail-Facturación"), StrLen(Correo) - MaxStrLen(Rec."E-Mail-Facturación"));

                    Rec."E-Mail-Facturación" := CopyStr(Correo, 1, MaxStrLen(Rec."E-Mail-Facturación"));
                end;
            }
        }
        addafter("Prepayment %")
        {

            field("Nº copias contratos"; Rec."Nº copias contratos") { ApplicationArea = All; }
            field("Cliente Ruta"; Rec."Cliente Ruta") { ApplicationArea = All; }
            field("Banco transferencia"; Rec."Banco transferencia")
            {
                ApplicationArea = All;
                Caption = 'Bancos transferencia';
                ToolTip = 'Separados por | \ Por ejemplo: \ 57200001|57200002';
                trigger OnLookup(var Texxt: Text): Boolean
                VAR
                    B: Text[250];
                    Bancos: Record 270;
                BEGIN
                    B := Rec."Banco transferencia";
                    if (STRLEN(B) <> 0) THEN
                        if (COPYSTR(B, STRLEN(B), 1) <> '|') THEN B := B + '|';
                    if Page.RUNMODAL(0, Bancos) = ACTION::LookupOK THEN
                        Rec."Banco transferencia" := B + Bancos."No.";
                END;
            }
        }
        addafter("Base Calendar Code")
        {
            field("Cód. envio genérico"; Rec."Cód. envio genérico")
            {
                ApplicationArea = All;
                Editable = false;
            }
            field("Cod cadena"; Rec."Cod cadena") { ApplicationArea = All; }
            // group(Efactura)
            // {
            //     field("Oficina Contable"; Rec."Oficina Contable") { ApplicationArea = All; }
            //     field("Organo Gestor"; Rec."Organo Gestor") { ApplicationArea = All; }
            //     field("Unidad tramitadora"; Rec."Unidad tramitadora") { ApplicationArea = All; }
            //     field("Permite Efactura"; Rec."Permite Efactura") { ApplicationArea = All; }
            //     field("E-Mail Efactura"; Rec."E-Mail Efactura") { ApplicationArea = All; }
            // }
        }

        addafter("Attached Documents")
        {
            part(Correos; "Sent Emails List Part")
            {
                ApplicationArea = All;
            }
        }
    }
    actions
    {
        addafter("Ledger E&ntries")
        {

            action("Unificar Clientes")
            {
                Image = MovementWorksheet;
                ApplicationArea = All;
                trigger OnAction()
                var
                    Customer: Record Customer;
                    SameCIFCustomer: Record Customer;
                begin
                    Customer := Rec;
                    //if Customer.GET('CIF') then begin
                    SameCIFCustomer.SETRANGE("VAT Registration No.", Customer."VAT Registration No.");
                    if Page.RunModal(0, SameCIFCustomer) = Action::LookupOK then begin
                        Customer.Delete();
                        SameCIFCustomer.Rename(Customer."No.")

                    end;

                    //end;
                end;
            }
        }

        addafter("&Jobs")
        {

            action("Comprueba mov. pendientes")
            {
                ApplicationArea = All;
                Image = Entries;
                Caption = 'Comprueba mov. pendientes';
                trigger OnAction()
                VAR
                    Ventana: Dialog;
                    r21: Record 21;
                    r379: Record 379;
                    r25: Record 25;
                    r380: Record 380;
                    a: Integer;
                BEGIN
                    if Confirm('Comprobamos clientes', true) Then begin
                        Ventana.OPEN('Comprueba mov. clientes ##########1## de ##########2##');
                        Ventana.UPDATE(2, r21.COUNT);
                        r21.FINDset;
                        REPEAT
                            a := a + 1;
                            Ventana.UPDATE(1, a);

                            r21.CALCFIELDS(r21."Remaining Amount");
                            if r21."Remaining Amount" <> 0 THEN BEGIN
                                r21.Open := TRUE;
                                r21.MODIFY;
                            END ELSE BEGIN
                                r21.Open := FALSE;
                                r21.MODIFY;

                            END;
                            if a / 500 = Round(a / 500, 1, '=') tHEN Commit();
                        UNTIL r21.NEXT = 0;
                        Ventana.CLOSE;
                    END;
                    a := 0;
                    if Confirm('Comprobamos también proveedores', true) Then begin
                        Ventana.OPEN('Comprueba mov. proveedor ##########1## de ##########2##');
                        Ventana.UPDATE(2, r25.COUNT);
                        r25.FINDset;
                        REPEAT
                            a := a + 1;
                            Ventana.UPDATE(1, a);

                            r25.CALCFIELDS(r25."Remaining Amount");
                            if r25."Remaining Amount" <> 0 THEN BEGIN
                                r25.Open := TRUE;
                                r25.MODIFY;
                            END ELSE BEGIN
                                r25.Open := FALSE;
                                r25.MODIFY;

                            END;
                            if a / 500 = Round(a / 500, 1, '=') tHEN Commit();
                        UNTIL r25.NEXT = 0;
                        Ventana.CLOSE;
                    end;
                END;
            }
            action("Anotaciones")
            {
                ApplicationArea = All;
                Image = Notes;
                Caption = 'Anotaciones';
                RunObject = Page 124;
                RunPageLink = "Table Name" = CONST(Anotaciones),
                             "No." = FIELD("No."), Proveedor = const(false);

            }


        }
        addafter(Templates)
        {
            action(Salda)
            {
                ShortCutKey = F2;
                Caption = 'Salda';
                trigger OnAction()
                VAR
                    r21: Record 21;
                    r379: Record 379;
                    a: Integer;
                    Ip: Decimal;
                    Ipd: Decimal;
                BEGIN
                    r379.FINDLAST;
                    a := r379."Entry No.";
                    Rec.COPYFILTER("Date Filter", r21."Posting Date");
                    r21.SETRANGE(r21."Customer No.", Rec."No.");
                    if r21.FINDFIRST THEN
                        REPEAT
                            r21.CALCFIELDS(r21."Remaining Amount", r21."Remaining Amt. (LCY)");
                            if r21."Remaining Amt. (LCY)" <> 0 THEN BEGIN
                                a := a + 1;
                                Ip := r21."Remaining Amount";
                                Ipd := r21."Remaining Amt. (LCY)";
                                r379.SETCURRENTKEY(r379."Cust. Ledger Entry No.");
                                r379.SETRANGE(r379."Cust. Ledger Entry No.", r21."Entry No.");
                                r379.FINDFIRST;
                                r379."Entry No." := a;
                                r379."Entry Type" := r379."Entry Type"::Application;
                                r379.Amount := -Ip;
                                r379."Amount (LCY)" := -Ipd;
                                if r379.Amount > 0 THEN BEGIN
                                    r379."Debit Amount" := r379.Amount;
                                    r379."Debit Amount (LCY)" := r379."Amount (LCY)";
                                    r379."Credit Amount" := 0;
                                    r379."Credit Amount (LCY)" := 0;
                                END ELSE BEGIN
                                    r379."Credit Amount" := -r379.Amount;
                                    r379."Credit Amount (LCY)" := -r379."Amount (LCY)";
                                    r379."Debit Amount (LCY)" := 0;
                                    r379."Debit Amount" := 0;
                                END;
                                r379.INSERT;
                            END;
                            r21.Open := FALSE;
                            r21.MODIFY;
                        UNTIL r21.NEXT = 0;
                    if Rec.NEXT <> 0 THEN CurrPage.UPDATE(FALSE);
                END;
            }

        }
        addafter("Ledger E&ntries_Promoted")
        {
            actionref(Anotaciones_Promoted; Anotaciones)
            {

            }
        }
    }
    var
        SaldoenContabVISIBLE: Boolean;
        SaldoenContabUATVISIBLE: Boolean;
        MatComent: array[6] of Text;
        CurrPageEditable: Boolean;
        Correo: Text;
        glUnion: Label 'UNION AGRICOLA Y TURISTICA, SL';
        glUATI: Label 'UATI';

    trigger OnOpenPage()
    VAR
        MapMgt: Codeunit 802;
    BEGIN
        if (COMPANYNAME in [glUnion, glUATI])
        OR (COMPANYNAME = 'Apartamentos los Tilos') THEN BEGIN
            SaldoenContabVISIBLE := FALSE;
            SaldoenContabUATVISIBLE := TRUE;
        END;
    END;

    trigger OnAfterGetRecord()
    var
        InvoiceHeader: Record "Sales Invoice Header";
    BEGIN
        Rec.SETRANGE("No.");
        ObtenerComentarios;
        CurrPageEditable := CurrPage.Editable;
        Correo := Rec."E-Mail-Facturación";
        InvoiceHeader.SETRANGE("Sell-to Customer No.", Rec."No.");
        If InvoiceHeader.FindFirst() then
            repeat
                CurrPage.Correos.Page.SetRelatedRecord(Database::"Sales Invoice Header", InvoiceHeader.SystemId);
            until InvoiceHeader.Next() = 0;
        CurrPage.Correos.Page.SetRelatedRecord(Database::"Customer", Rec.SystemId);
        CurrPage.Correos.Page.Load();
    END;


    PROCEDURE ObtenerComentarios();
    VAR
        indice: Integer;
        rLinComent: Record 97;

    BEGIN
        //$001
        CLEAR(MatComent);
        CLEAR(indice);
        rLinComent.RESET;
        rLinComent.SETRANGE("Table Name", rLinComent."Table Name"::Customer);
        rLinComent.SETRANGE("No.", Rec."No.");
        if rLinComent.FIND('-') THEN BEGIN
            REPEAT
                indice := indice + 1;
                MatComent[indice] := rLinComent.Comment;
            UNTIL (rLinComent.NEXT = 0) OR (indice = 5);
        END;
    END;


}