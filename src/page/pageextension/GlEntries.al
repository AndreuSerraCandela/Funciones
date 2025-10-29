/// <summary>
/// PageExtension GlEntries (ID 80133) extends Record General Ledger Entries.
/// </summary>
pageextension 80133 GlEntries extends "General Ledger Entries"
{


    layout
    {
        modify("IC Partner Code")
        {
            visible = true;
        }
        addafter("Dimension Set ID")
        {
            field("Transaction No."; Rec."Transaction No.") { ApplicationArea = All; Visible = true; }
            field(Marca; Rec.Marca) { ApplicationArea = All; Visible = true; }
            field(Eliminaciones; Rec.Eliminaciones) { ApplicationArea = All; Visible = true; }
            field(FecVto; OrdenPago) { Caption = 'Fecha Vencimiento'; ApplicationArea = All; Visible = true; }

            field("Periodo de Pago"; Rec."Periodo de Pago")
            {
                Visible = true;
                ApplicationArea = All;

                StyleExpr = FPR;
                // OnFormat=VAR
                //         rPag: Record 7010615;
                //         BEGIN
                //         if rPag.GET("Periodo de Pago") THEN BEGIN
                //             if (rPag."Cuenta Contable FPR"<>"G/L Account No.") AND
                //             (rPag."Cuenta Contable FPR"<>'') THEN BEGIN
                //             if COPYSTR("G/L Account No.",1,4)='4009' THEN CurrPage."Periodo de Pago".UPDATEFORECOLOR(255);
                //             END;
                //         END;
                //         END;

                trigger OnLookup(var Text: Text): Boolean
                VAR
                    rPag: Record "Periodos pago emplazamientos";
                BEGIN
                    if rPag.GET(Rec."Periodo de Pago") THEN;
                    Page.RUNMODAL(0, rPag);
                END;
            }
            field("Tax Area Code"; Rec."Tax Area Code")
            {
                Visible = true;
                ApplicationArea = All;
                Caption = 'Nº Albarán';

                trigger OnLookup(var Text: Text): Boolean
                VAR
                    r120: Record "Purch. Rcpt. Header";
                    Con: Codeunit ControlProcesos;
                BEGIN
                    if r120.GET(Rec."Tax Area Code") THEN;
                    Page.RUNMODAL(136, r120);
                END;
            }


            field("Descripción Ampliada"; DescriptionA) { ApplicationArea = All; }
        }

        addafter("Global Dimension 2 Code")
        {
            field(Principal; Rec."Global Dimension 3 Code")
            {
                Caption = 'Principal';
                ApplicationArea = All;
                Visible = true;
            }

            field(Zona; Rec."Global Dimension 4 Code")
            {
                Caption = 'Zona';
                ApplicationArea = All;
                Visible = true;
            }
            field(Soporte; Rec."Global Dimension 5 Code")
            {
                Caption = 'Soporte';
                ApplicationArea = All;
                Visible = true;
            }
            field("SalesPerson Code"; Rec."SalesPerson Code")
            {
                Caption = 'Cód. Vendedor';
                ApplicationArea = All;
                Visible = true;
            }
            field("Nombre Comercial"; ProcedureNombreCom())
            {
                Caption = 'Nombre Comercial';
                ApplicationArea = All;
                Visible = true;
            }
        }
        addafter("Source No.")
        {
            field(Nombre; ProcedureNombre('NOM'))
            {
                ApplicationArea = All;
            }
            field(Anunciante; ProcedureNombre('NOM'))
            {
                ApplicationArea = All;
            }
            field(Cif; ProcedureNombre('CIF'))
            {
                ApplicationArea = All;
            }
        }
        modify("Source No.")
        {
            Visible = true;
            ApplicationArea = All;
            StyleExpr = ExisteMov;
            // OnFormat=VAR
            //         r21: Record 21;
            //         r25 : Record 25;
            //         BEGIN
            //         if ("Source Type"="Source Type"::Customer) AND
            //         ((COPYSTR("G/L Account No.",1,2)='43') OR (COPYSTR("G/L Account No.",1,2)='44')) AND
            //         (NOT r21.GET("Entry No.")) AND (Amount<>0) THEN
            //         CurrPage."Source No.".UPDATEFONTBOLD(TRUE);
            //         if ("Source Type"="Source Type"::Customer) AND
            //         ((COPYSTR("G/L Account No.",1,2)='43') OR (COPYSTR("G/L Account No.",1,2)='44'))
            //         THEN BEGIN
            //         if NOT r21.GET("Entry No.") THEN r21.INIT;
            //         r21.CALCFIELDS("Amount (LCY)");
            //         if (Amount<>r21."Amount (LCY)") THEN
            //         CurrPage."Source No.".UPDATEFONTBOLD(TRUE);
            //         END;
            //         if ("Source Type"="Source Type"::Vendor) AND
            //         ((COPYSTR("G/L Account No.",1,2)='40') OR (COPYSTR("G/L Account No.",1,2)='41')) AND
            //         (NOT r25.GET("Entry No.")) AND (Amount<>0)THEN
            //         CurrPage."Source No.".UPDATEFONTBOLD(TRUE);
            //         END;
        }
        addafter("Credit Amount")
        {
            //field("Importe pendiente"; Rec."Importe pendiente") { ApplicationArea = All; Visible = true; }
            //field(Factur; Factura) { Caption = 'Factura'; ApplicationArea = All; Visible = true; }
            field(Contrat; Rec."Nº Contrato")
            {
                Caption = 'Contrato';
                ApplicationArea = All;
                Visible = true;
                // TableRelation = "Sales Header"."No.";
                // LookupPageId = "Sales List";
                // DrillDownPageId = "Sales List";

                trigger OnDrillDown()
                var
                    SalesHeader: Record "Sales Header";
                    SalesHeaderRf: RecordRef;
                begin
                    if Rec.Comment <> '' Then EmpresaTXT := Rec.Comment;
                    SalesHeaderRf.Close();
                    SalesHeaderRf.Open(DATABASE::"Sales Header");
                    if EmpresaTXT <> '' Then ProChangeCompany(SalesHeaderRf, EmpresaTXT);
                    SalesHeaderRf.SetTable(SalesHeader);
                    SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::Order);
                    SalesHeader.SetRange("No.", Rec."Nº Contrato");
                    if SalesHeader.FindFirst() Then
                        Page.RunModal(Page::"Ficha Contrato Venta", SalesHeader);
                end;

            }
            field("Nº Proyecto"; Rec."Job No.") { ApplicationArea = All; Visible = true; }
            field("Núm. Contrato"; Rec."Núm. Contrato") { ApplicationArea = All; Visible = false; }
            field("Fecha Estado"; FechaEstado())
            {
                Caption = 'Fecha Estado';
                ApplicationArea = All;
            }
            field("Tipo factura SII"; Rec."Tipo factura SII") { ApplicationArea = All; Visible = true; }
            field("Clave registro SII expedidas"; Rec."Clave registro SII expedidas") { ApplicationArea = All; Visible = true; }
            field("Clave registro SII recibidas"; Rec."Clave registro SII recibidas") { ApplicationArea = All; Visible = true; }
            field("Tipo desglose emitidas"; Rec."Tipo desglose emitidas") { ApplicationArea = All; Visible = true; }
            field("Sujeta exenta"; Rec."Sujeta exenta") { ApplicationArea = All; Visible = true; }
            field("Tipo de operación"; Rec."Tipo de operación") { ApplicationArea = All; Visible = true; }
            field("Tipo desglose recibidas"; Rec."Tipo desglose recibidas") { ApplicationArea = All; Visible = true; }
            field("Descripción operación"; Rec."Descripción operación") { ApplicationArea = All; Visible = true; }
            field("Tipo factura rectificativa"; Rec."Tipo factura rectificativa") { ApplicationArea = All; Visible = true; }
            field(Banco; Rec.Banco) { ApplicationArea = All; Visible = true; }
            field(Iban; Procedure_Iban()) { ApplicationArea = All; Visible = true; }
            field("Pago Impuestos"; Rec."Pago Impuestos") { ApplicationArea = All; Visible = true; }

        }
        modify("Document No.")
        {
            StyleExpr = DESGLO;
        }
        modify("Reason Code")
        {
            Visible = true;
            Editable = true;
            trigger OnAfterValidate()
            var
                Con: Codeunit ControlProcesos;
            begin
                Codeunit.Run(Codeunit::ControlProcesos, Rec);
            end;

            trigger OnLookup(var Text: Text): Boolean
            VAR
                rAud: Record 231;
                r17: Record "G/L Entry";
            BEGIN
                if ACTION::LookupOK = Page.RUNMODAL(0, rAud) THEN BEGIN
                    r17.GET(Rec."Entry No.");
                    r17."Reason Code" := rAud.Code;
                    Codeunit.Run(Codeunit::ControlProcesos, r17);
                    // r17."Reason Code" := rAud.Code;
                    // r17.MODIFY;
                    Text := rAud.Code;
                END;
            END;
        }
        addlast(Control1)
        {
            field("Nombre Empresa"; Rec.Comment)
            {
                Caption = 'Nombre Empresa';
                Visible = VariasEmpresas;
                ApplicationArea = All;
            }
        }
        modify("Shortcut Dimension 3 Code")
        { Visible = false; Enabled = false; }
        modify("Shortcut Dimension 4 Code")
        { Visible = false; }
        modify("Shortcut Dimension 5 Code")
        { Visible = false; }
    }
    actions
    {
        addafter(ReverseTransaction)
        {

            group(Asignar)
            {
                Image = AdjustItemCost;
                action("Asigna Contrato")
                {
                    ApplicationArea = all;

                    Image = FileContract;
                    Caption = 'Asigna Contrato';
                    trigger OnAction()
                    Var
                        r17: Record "G/L Entry";
                    BEGIN
                        CurrPage.SETSELECTIONFILTER(r17);
                        ControlProcesos.AsignaContrato(r17);
                    END;
                }
                action("Asigna Proyecto")
                {
                    ApplicationArea = all;

                    Image = Job;
                    trigger OnAction()
                    Var
                        r17: Record "G/L Entry";
                        r15: Record Job;
                    BEGIN
                        if ACTION::LookupOK = Page.RUNMODAL(0, r15) THEN BEGIN
                            CurrPage.SETSELECTIONFILTER(r17);
                            ControlProcesos.MoveraOtroProyecto(r17, r15);

                        END;
                    END;
                }

                action("Asigna Prev como Nº Doc")
                {
                    ApplicationArea = all;

                    Image = Document;
                    Caption = 'Asigna Prev como Nº Doc';
                    trigger OnAction()
                    Var
                        r17: Record "G/L Entry";
                        r17R: Record "G/L Entry";
                    BEGIN
                        CurrPage.SETSELECTIONFILTER(r17);
                        ControlProcesos.AsignaPrevComoNoDoc(r17);

                    END;
                }
                action("Asigna Periodo")
                {
                    ApplicationArea = all;

                    Visible = false;
                    Image = PeriodEntries;
                    Caption = 'Asigna Periodo';
                    trigger OnAction()
                    Var
                        r17: Record "G/L Entry";
                        r17R: Record "G/L Entry";
                        rPer: Record "Periodos pago emplazamientos";
                    BEGIN
                        if ACTION::LookupOK = Page.RUNMODAL(0, rPer) THEN BEGIN
                            CurrPage.SETSELECTIONFILTER(r17);
                            ControlProcesos.AsignaPeriodo(r17);

                        END;
                    END;
                }
                action("Asigna Periodo de Pago")
                {
                    ApplicationArea = all;
                    Scope = Repeater;
                    Image = ChangeDates;

                    Caption = 'Asigna Periodo de Pago a Seleccionadas';
                    trigger OnAction()
                    Var
                        r17: Record "G/L Entry";
                        r17R: Record "G/L Entry";
                        rPer: Record "Periodos pago emplazamientos";
                    BEGIN
                        if ACTION::LookupOK = Page.RUNMODAL(0, rPer) THEN BEGIN
                            CurrPage.SETSELECTIONFILTER(r17);
                            ControlProcesos.AsignaPeriododePago(r17, rPer."Cód. Periodo Pago");
                        End;
                    END;
                }
                action("Asigna Albarán")
                {
                    ApplicationArea = all;
                    Scope = Repeater;
                    Image = Receipt;
                    trigger OnAction()
                    var
                        GlEntries: Record "G/L Entry";
                        Alb: Record "Purch. Rcpt. Header";
                        Lin: Record "Purch. Inv. Line";
                        Albt: Record "Purch. Rcpt. Header" temporary;
                    begin
                        CurrPage.SETSELECTIONFILTER(GlEntries);
                        if GlEntries.FindFirst() Then
                            repeat
                                Lin.SetRange("Document No.", GlEntries."Document No.");
                                if lin.FindFirst() Then
                                    repeat
                                        if Lin."Receipt No." <> '' Then begin
                                            Alb.Get(Lin."Receipt No.");
                                            Albt := Alb;
                                            if Albt.Insert() Then;
                                        end;
                                    until lin.Next() = 0;
                            Until GlEntries.Next() = 0;
                        ControlProcesos.CambiAlbaran(GlEntries, Albt);
                    end;
                }
            }

            group(Albaranes)
            {
                Image = Shipment;

                action("Buscar albaranes incorrectos")
                {
                    ApplicationArea = all;

                    Image = ShowList;
                    trigger OnAction()
                    var
                        GlEntries: Record "G/L Entry";
                        GlEntriest: Record "G/L Entry" temporary;

                        Alb: Record "Purch. Rcpt. Header";
                        Lin: Record "Purch. Inv. Line";
                        Albt: Record "Purch. Rcpt. Header" temporary;
                    begin
                        CurrPage.SETSELECTIONFILTER(GlEntries);
                        if GlEntries.FindFirst() Then
                            repeat
                                Lin.SetRange("Document No.", GlEntries."Document No.");
                                if lin.FindFirst() Then
                                    repeat
                                        if (Lin."Receipt No." <> '') And (Lin.Quantity <> 0) Then begin
                                            if Not Alb.Get(Lin."Receipt No.") then begin
                                                Albt."No." := Lin."Receipt No.";
                                            end else
                                                Albt := Alb;
                                            Albt."Dimension Set ID" := GlEntries."Entry No.";
                                            Albt."No Factura" := GlEntries."Document No.";
                                            if Albt.Insert() Then;
                                        end;
                                    until lin.Next() = 0;
                            Until GlEntries.Next() = 0;
                        GlEntries.Reset();
                        if Albt.FindFirst() then
                            repeat
                                GlEntries.SetRange("Document No.", Albt."No Factura");
                                GlEntries.SetRange("Tax Area Code", Albt."No.");
                                if not GlEntries.FindFirst() Then begin
                                    GlEntries.Reset();
                                    GlEntries.Get(Albt."Dimension Set ID");
                                    GlEntriest := GlEntries;
                                    if GlEntriest.Insert() Then;
                                end;
                            until Albt.Next() = 0;
                        Commit();
                        Page.RunModal(0, GlEntriest);

                    end;


                }
                action("Buscar albaranes mal asignados")
                {
                    ApplicationArea = all;

                    Image = ShowList;
                    trigger OnAction()
                    var
                        GlEntries: Record "G/L Entry";
                        GlEntriest: Record "G/L Entry" temporary;
                        Fac: Record "Purch. Inv. Header";
                        Alb: Record "Purch. Rcpt. Header";
                        Lin: Record "Purch. Inv. Line";
                        Albt: Record "Purch. Rcpt. Header" temporary;
                    begin
                        Fac.SetRange("Posting Date", 20220101D, 20250101D);
                        if Fac.FindFirst() Then
                            repeat
                                GlEntries.SetRange("Document No.", Fac."No.");
                                GlEntries.SetFilter("Tax Area Code", '<>%1', '');
                                GlEntries.SetFilter(Amount, '<>%1', 0);
                                if GlEntries.FindFirst() Then
                                    repeat
                                        Lin.SetRange("Document No.", Fac."No.");
                                        Lin.SetRange("Receipt No.", GlEntries."Tax Area Code");
                                        Lin.SetFilter(Quantity, '<>%1', 0);
                                        if Not lin.FindFirst() Then
                                            repeat
                                                if Not Alb.Get(Lin."Receipt No.") then begin
                                                    Albt."No." := Lin."Receipt No.";
                                                end else
                                                    Albt := Alb;
                                                Albt."Dimension Set ID" := GlEntries."Entry No.";
                                                Albt."No Factura" := GlEntries."Document No.";
                                                if Albt.Insert() Then begin
                                                    GlEntriest := GlEntries;
                                                    if GlEntriest.Insert() Then;
                                                end;
                                            until lin.Next() = 0;
                                    Until GlEntries.Next() = 0;
                                Lin.SetRange("Document No.", Fac."No.");
                                Lin.SetFilter("Receipt No.", '<>%1', '');
                                Lin.SetFilter(Quantity, '<>%1', 0);
                                if Lin.FindFirst() Then
                                    repeat
                                        GlEntries.SetRange("Document No.", Fac."No.");
                                        GlEntries.SetFilter("Tax Area Code", Lin."Receipt No.");
                                        GlEntries.SetFilter(Amount, '<>%1', 0);
                                        if Not GlEntries.FindFirst() Then begin
                                            GlEntriest := GlEntries;
                                            if GlEntriest.Insert() Then;
                                        end;
                                    Until Lin.Next = 0;
                            until Fac.Next() = 0;
                        //GlEntries.Reset();
                        // if Albt.FindFirst() then
                        //     repeat
                        //         GlEntries.SetRange("Document No.", Albt."No Factura");
                        //         GlEntries.SetRange("Tax Area Code", Albt."No.");
                        //         if not GlEntries.FindFirst() Then begin
                        //             GlEntries.Reset();
                        //             GlEntries.Get(Albt."Dimension Set ID");
                        //             GlEntriest := GlEntries;
                        //             if GlEntriest.Insert() Then;
                        //         end;
                        //     until Albt.Next() = 0;
                        Commit();
                        Page.RunModal(0, GlEntriest);

                    end;


                }
                action("Asignar Albarán")
                {
                    ApplicationArea = all;
                    Scope = Repeater;
                    Image = Receipt;
                    trigger OnAction()
                    var
                        GlEntries: Record "G/L Entry";
                        Alb: Record "Purch. Rcpt. Header";
                        Lin: Record "Purch. Inv. Line";
                        Albt: Record "Purch. Rcpt. Header" temporary;
                    begin
                        CurrPage.SETSELECTIONFILTER(GlEntries);
                        if GlEntries.FindFirst() Then
                            repeat
                                Lin.SetRange("Document No.", GlEntries."Document No.");
                                if lin.FindFirst() Then
                                    repeat
                                        if Lin."Receipt No." <> '' Then begin
                                            Alb.Get(Lin."Receipt No.");
                                            Albt := Alb;
                                            if Albt.Insert() Then;
                                        end;
                                    until lin.Next() = 0;
                            Until GlEntries.Next() = 0;
                        ControlProcesos.CambiAlbaran(GlEntries, Albt);
                    end;
                }
                action("Marcar como Albarán")
                {
                    ApplicationArea = all;
                    Scope = Repeater;
                    Image = AddWatch;
                    Caption = 'Marcar como Albarán';
                    trigger OnAction()
                    Var
                        r17: Record "G/L Entry";
                    BEGIN
                        CurrPage.SETSELECTIONFILTER(r17);
                        ControlProcesos.MarcaComoAlbaran(r17);
                    END;
                }

                action("DesMarcar como Albarán")
                {
                    ApplicationArea = all;
                    Scope = Repeater;
                    Image = AddWatch;
                    Caption = 'DesMarcar como Albarán';
                    trigger OnAction()
                    Var
                        r17: Record "G/L Entry";
                    BEGIN
                        CurrPage.SETSELECTIONFILTER(r17);
                        ControlProcesos.DesMarcaComoAlbaran(r17);
                    END;
                }

            }
            group(Liquidez)
            {
                Image = CashFlow;

                action("Cambiar Banco Liquidez")
                {
                    ApplicationArea = all;
                    Scope = Repeater;
                    Image = NewBank;
                    Caption = 'Cambiar Banco Liquidez';
                    trigger OnAction()
                    Var
                    BEGIN
                        ControlProcesos.CambiarBancoLiquidez(Rec);
                    END;
                }
                action("Dejar banco en blanco")
                {
                    ApplicationArea = all;
                    Scope = Repeater;
                    Image = Bank;
                    Caption = 'Dejar banco en blanco';
                    trigger OnAction()
                    Begin
                        ControlProcesos.Dejarbancoenblanco(Rec);
                    END;
                }
                action("Pago Impuesto")
                {
                    ApplicationArea = all;
                    Scope = Repeater;
                    Image = TaxDetail;
                    Caption = 'Pago Impuestos';
                    trigger OnAction()
                    Begin
                        ControlProcesos.PagoImpuestos(Rec);
                    END;
                }
            }

            action("Quita Marca")
            {
                ApplicationArea = all;

                Image = AddWatch;
                Visible = false;
                Caption = 'Quita Marca';
                trigger OnAction()
                Begin
                    controlProcesos.QuitaMarca(Rec);
                END;
            }
            action("Añadir Marca")
            {
                ApplicationArea = all;

                Image = AddWatch;
                Visible = false;
                Caption = 'Añadir Marca';
                trigger OnAction()
                Begin
                    ControlProcesos.AñadirMarca(Rec);
                END;
            }
        }
    }

    VAR
        GLAcc: Record 15;
        Navigate: Page 344;
        Text000: Label 'Cliente,Proveedor';
        FPR: Text;
        DESGLO: Text;
        ExisteMov: Text;
        ControlProcesos: Codeunit Utilitis;
        EmpresaTXT: Text;
        VariasEmpresas: Boolean;

    trigger OnOpenPage()
    var
        Control: Codeunit ControlProcesos;
    Begin
        Rec.SetCurrentKey("G/L Account No.", "Posting Date");
        Rec.SetAscending("Posting Date", TRUE);//              ORDER(Descending);
        if Rec.Findlast() then if Rec.IsTemporary Then Varias();
        if REC.CurrentCompany <> CompanyName THEN EmpresaBuscar(rEC.CurrentCompany);

        If Control.AccesoProibido_Empresas(CompanyName, 'RESTRINGIDO') then
            Error('No tiene permisos para acceder a este punto del menú en esta empresa');
    end;

    trigger OnAfterGetCurrRecord()
    begin
        if Rec.IsTemporary Then Varias();
    end;

    trigger OnAfterGetRecord()
    begin
        If Rec.Comment = '' Then
            Rec."Nº Contrato" := ProContrato();
    end;

    LOCAL PROCEDURE GetCaption(): Text[250];
    BEGIN
        if GLAcc."No." <> Rec."G/L Account No." THEN
            if NOT GLAcc.GET(Rec."G/L Account No.") THEN
                if Rec.GETFILTER("G/L Account No.") <> '' THEN EXIT('Varias Cuentas');
        //if GLAcc.GET(GETRANGEMIN("G/L Account No.")) THEN;
        EXIT(STRSUBSTNO('%1 %2', GLAcc."No.", GLAcc.Name))
    END;

    local procedure FechaEstado(): Date
    var
        Contrato: Record 36;
        ContratoRf: RecordRef;
    begin
        if (Rec.Comment <> '') Then EmpresaTXT := Rec.Comment;
        ContratoRf.Close();
        ContratoRf.Open(DATABASE::"Sales Header");
        ProChangeCompany(ContratoRf, EmpresaTXT);
        ContratoRf.SetTable(Contrato);
        If Contrato.Get(Contrato."Document Type"::Order, ProContrato()) Then
            exit(Contrato."Fecha Estado");
    end;

    local procedure Procedure_Iban(): Text
    var
        Customer: Record Customer;
        Cartera: Record "Cartera Doc.";
        PostedCartera: Record "Posted Cartera Doc.";
        ClosedCartera: Record "Closed Cartera Doc.";
        Vendor: Record Vendor;
        BancNo: Code[20];
    begin
        If Rec."Source Type" = Rec."Source Type"::Customer then begin
            if not Customer.GET(Rec."Source No.") then exit('');
            if Cartera.get(Cartera.Type::Receivable, Rec."Entry No.") then exit(Iban(Customer."No.", 'C', Cartera."Cust./Vendor Bank Acc. Code"));
            if PostedCartera.get(PostedCartera.Type::Receivable, Rec."Entry No.") then exit(Iban(Customer."No.", 'C', PostedCartera."Cust./Vendor Bank Acc. Code"));
            if ClosedCartera.get(ClosedCartera.Type::Receivable, Rec."Entry No.") then exit(Iban(Customer."No.", 'C', ClosedCartera."Cust./Vendor Bank Acc. Code"));
            exit(Iban(Customer."No.", 'C', Customer."Preferred Bank Account Code"));
        end;
        if Rec."Source Type" = Rec."Source Type"::Vendor then begin
            if not Vendor.GET(Rec."Source No.") then exit('');
            if Cartera.get(Cartera.Type::Payable, Rec."Entry No.") then exit(Iban(Vendor."No.", 'V', Cartera."Cust./Vendor Bank Acc. Code"));
            if PostedCartera.get(PostedCartera.Type::Payable, Rec."Entry No.") then exit(Iban(Vendor."No.", 'V', PostedCartera."Cust./Vendor Bank Acc. Code"));
            if ClosedCartera.get(ClosedCartera.Type::Payable, Rec."Entry No.") then exit(Iban(Vendor."No.", 'V', ClosedCartera."Cust./Vendor Bank Acc. Code"));
            exit(Iban(Vendor."No.", 'V', Vendor."Preferred Bank Account Code"));
        end;



    end;

    local procedure ProChangeCompany(var RecRf: RecordRef; EmpresaTXT: Text)
    var
        Control: Codeunit ControlProcesos;
    begin
        If Control.Permiso_Empresas(EmpresaTXT) then begin
            RecRf.ChangeCompany(EmpresaTXT);
        end;

    end;

    procedure Iban(Cuenta: Code[20]; Tipo: code[1]; BancNo: code[20]): Text
    var
        cBank: Record "Customer Bank Account";
        vBank: Record "Vendor Bank Account";
    Begin

        if Tipo = 'C' THEN BEGIN
            if not cBank.GET(Cuenta, BancNo) THEN
                EXIT(cBank.IBAN);
            cBank.SetRange("Customer No.", Cuenta);
            if cBank.FindFirst() Then exit(cBank.IBAN);
        END ELSE BEGIN
            if vBank.GET(Cuenta, BancNo) THEN
                EXIT(vBank.IBAN);
            vBank.SetRange("Vendor No.", Cuenta);
            if vBank.FindFirst() Then exit(cBank.IBAN);
        END;
    end;

    PROCEDURE Factura(): Text[30];
    VAR
        r123: Record 123;
        r122: Record "Purch. Inv. Header";
        r124: Record 123;
        r17: Record "G/L Entry";
    BEGIN
        if Rec."Document Type" = Rec."Document Type"::Invoice THEN EXIT(Rec."Document No.");
        if Rec."Document Type" = Rec."Document Type"::"Credit Memo" THEN EXIT(Rec."Document No.");
        if Rec."Document Type" = Rec."Document Type"::" " THEN EXIT(Rec."Document No.");
        if Rec."Document Type" = Rec."Document Type"::Receipt THEN BEGIN
            r123.SETCURRENTKEY(r123."Buy-from Vendor No.", r123.Description);
            //r123.SETRANGE(r123."Buy-from Vendor No.","Buy-from Vendor No.");
            r123.SETFILTER(r123.Description, '%1', '*' + Rec."Document No." + '*');
            if NOT r123.FINDFIRST THEN BEGIN
                r124.SETCURRENTKEY(r124."Buy-from Vendor No.", r124.Description);
                r124.SETFILTER(r124.Description, '%1', '*' + Rec."Document No." + '*');
                if r124.FINDFIRST THEN EXIT(r124."Document No.");
                if COPYSTR(Rec.Description, 1, 3) = 'Dev' THEN BEGIN
                    r17.SETCURRENTKEY("G/L Account No.", "Source Type", "Source No.", "Posting Date", "Document Type");
                    r17.SETRANGE(r17."G/L Account No.", Rec."G/L Account No.");
                    r17.SETRANGE("Source Type", r17."Source Type"::Vendor);
                    r17.SETRANGE(r17."Source No.", Rec."Source No.");
                    r17.SETRANGE(r17.Amount, -Rec.Amount);
                    if r17.FINDFIRST THEN EXIT(r17."Document No.");
                END;
                EXIT('');
            END;
            if NOT r122.GET(r123."Document No.") THEN
                EXIT('');
            EXIT(r123."Document No.");
        END;
    END;

    PROCEDURE DescriptionA(): Text[1024];
    VAR
        rCli: Record Customer;
        rVen: Record Vendor;
        rBan: Record 270;
        rCliRf: RecordRef;
        rVenRf: RecordRef;
        rBanRf: RecordRef;
    BEGIN
        if (Rec.Comment <> '') and (EmpresaTXT = '') Then EmpresaTXT := Rec.Comment;
        if EmpresaTXT <> '' Then begin
            rCliRf.Close();
            rVenRf.Close();
            rBanRf.Close();
            rCliRf.Open(DATABASE::Customer);
            rVenRf.Open(DATABASE::Vendor);
            rBanRf.Open(DATABASE::"Bank Account");
            ProChangeCompany(rCliRf, EmpresaTXT);
            ProChangeCompany(rVenRf, EmpresaTXT);
            ProChangeCompany(rBanRf, EmpresaTXT);
            rCliRf.SetTable(rCli);
            rVenRf.SetTable(rVen);
            rBanRf.SetTable(rBan);
        end;
        if Rec."Source Type" = Rec."Source Type"::Vendor THEN
            if rVen.GET(Rec."Source No.") THEN EXIT(Rec.Description + '-' + rVen.Name);
        if Rec."Source Type" = Rec."Source Type"::Customer THEN
            if rCli.GET(Rec."Source No.") THEN EXIT(Rec.Description + '-' + rCli.Name);
        if Rec."Source Type" = Rec."Source Type"::"Bank Account" THEN
            if rBan.GET(Rec."Source No.") THEN EXIT(Rec.Description + '-' + rBan.Name);
    END;

    PROCEDURE ProcedureNombre(Tipo: Text): Text[1024];
    VAR
        rCli: Record Customer;
        rVen: Record Vendor;
        rBan: Record 270;
        rGl: Record 15;
        rAct: Record 5600;
        r36: Record 36;
        rCliRf: RecordRef;
        rVenRf: RecordRef;
        rBanRf: RecordRef;
        rGlRf: RecordRef;
        rActRf: RecordRef;
        r36Rf: RecordRef;
    BEGIN
        if (Rec.Comment <> '') Then EmpresaTXT := Rec.Comment;
        if EmpresaTXT <> '' Then begin
            rCliRf.Close();
            rVenRf.Close();
            rBanRf.Close();
            rGlRf.Close();
            rActRf.Close();
            r36Rf.Close();
            rCliRf.Open(DATABASE::Customer);
            rVenRf.Open(DATABASE::Vendor);
            rBanRf.Open(DATABASE::"Bank Account");
            rGlRf.Open(DATABASE::"G/L Account");
            rActRf.Open(DATABASE::"Fixed Asset");
            r36Rf.Open(DATABASE::"Sales Header");
            ProChangeCompany(rCliRf, EmpresaTXT);
            ProChangeCompany(rVenRf, EmpresaTXT);
            ProChangeCompany(rBanRf, EmpresaTXT);
            ProChangeCompany(rGlRf, EmpresaTXT);
            ProChangeCompany(rActRf, EmpresaTXT);
            ProChangeCompany(r36Rf, EmpresaTXT);
            rCliRf.SetTable(rCli);
            rVenRf.SetTable(rVen);
            rBanRf.SetTable(rBan);
            rGlRf.SetTable(rGl);
            rActRf.SetTable(rAct);
            r36Rf.SetTable(r36);
        end;
        if Tipo = 'NOM' Then begin
            if Rec."Source Type" = Rec."Source Type"::Vendor THEN
                if rVen.GET(Rec."Source No.") THEN EXIT(rVen.Name);
            if Rec."Source Type" = Rec."Source Type"::Customer THEN
                if rCli.GET(Rec."Source No.") THEN EXIT(rCli.Name);
            if Rec."Source Type" = Rec."Source Type"::"Bank Account" THEN
                if rBan.GET(Rec."Source No.") THEN EXIT(rBan.Name);
            if Rec."Source Type" = Rec."Source Type"::"Fixed Asset" then
                if rAct.Get(Rec."Source No.") then exit(rAct.Description);
            if rGl.GET(Rec."Source No.") THEN EXIT(rGl.Name);
        end;
        if TIpo = 'CIF' then begin
            if Rec."Source Type" = Rec."Source Type"::Vendor THEN
                if rVen.GET(Rec."Source No.") THEN EXIT(rVen."VAT Registration No.");
            if Rec."Source Type" = Rec."Source Type"::Customer THEN
                if rCli.GET(Rec."Source No.") THEN EXIT(rCli."VAT Registration No.");
            if Rec."Source Type" = Rec."Source Type"::"Bank Account" THEN
                if rBan.GET(Rec."Source No.") THEN EXIT(rBan."VAT Registration No.");

        end;
        if Tipo = 'ANU' then begin
            if r36.Get(r36."Document Type"::Order, ProContrato()) then exit(r36."Nombre Comercial");
        end;
    END;

    PROCEDURE ProcedureNombreCom(): Text
    var
        r13: Record 13;
        r13Rf: RecordRef;
    begin
        if (Rec.Comment <> '') Then EmpresaTXT := Rec.Comment;
        r13Rf.Close();
        r13Rf.Open(DATABASE::"Salesperson/Purchaser");
        if EmpresaTXT <> '' Then ProChangeCompany(r13Rf, EmpresaTXT);
        r13Rf.SetTable(r13);
        if r13.get(Rec."SalesPerson Code") Then exit(r13.Name);
    end;

    PROCEDURE ProContrato(): Code[20];
    VAR
        r120: Record "Purch. Rcpt. Header";
        r112: Record 112;
        r114: Record 114;
        r110: Record 110;
        Cont: Record 36;
        ContRf: RecordRef;
        r110Rf: RecordRef;
        r112Rf: RecordRef;
        r114Rf: RecordRef;
        r120Rf: RecordRef;
    BEGIN
        If Rec.Comment <> '' Then EmpresaTXT := Rec.Comment;
        if EmpresaTXT <> '' then begin
            r110Rf.Close();
            r112Rf.Close();
            r114Rf.Close();
            r120Rf.Close();
            contRf.Close();
            r110Rf.Open(DATABASE::"Sales Shipment Header");
            r112Rf.Open(DATABASE::"Sales Invoice Header");
            r114Rf.Open(DATABASE::"Sales Cr.Memo Header");
            r120Rf.Open(DATABASE::"Purch. Rcpt. Header");
            contRf.Open(DATABASE::"Sales Header");
            ProChangeCompany(r110Rf, EmpresaTXT);
            ProChangeCompany(r112Rf, EmpresaTXT);
            ProChangeCompany(r114Rf, EmpresaTXT);
            ProChangeCompany(r120Rf, EmpresaTXT);
            ProChangeCompany(contRf, EmpresaTXT);
            r110Rf.SetTable(r110);
            r112Rf.SetTable(r112);
            r114Rf.SetTable(r114);
            r120Rf.SetTable(r120);
            contRf.SetTable(cont);
        end;

        Rec.CALCFIELDS("Núm. Contrato");
        if Rec."Job No." <> '' THEN begin
            contRf.Close();
            contRf.Open(DATABASE::"Sales Header");
            ProChangeCompany(contRf, EmpresaTXT);
            contRf.SetTable(cont);
            cont.SetRange("Document Type", cont."Document Type"::Order);
            cont.SetRange("Nº Proyecto", Rec."Job No.");
            if Cont.findfirst Then Exit(cont."No.");
            if (Rec."Núm. Contrato" <> '') AND (Rec."Núm. Contrato" <> '--') THEN EXIT(Rec."Núm. Contrato");
        end;
        if r112.GET(Rec."Document No.") THEN EXIT(r112."Nº Contrato");
        if r114.GET(Rec."Document No.") THEN EXIT(r114."Nº Contrato");
        if r110.GET(Rec."Document No.") THEN EXIT(r110."Nº Contrato");

        // if (Rec."Núm. Contrato" = '--') OR (Rec."Job No." = '') THEN BEGIN
        //     if r120.GET(COPYSTR(Rec."Document No.", 1, MAXSTRLEN(r120."No."))) THEN BEGIN
        //         r120.CALCFIELDS(r120."Nº Contrato Venta");
        //         EXIT(r120."Nº Contrato Venta");
        //     END;
        // END;
        if Rec."Job No." = '' THEN EXIT('--');
        EXIT(Rec."Núm. Contrato");
    END;


    PROCEDURE OrdenPago(): Date;
    VAR
        r25: Record 25;
        r7020: Record 7000002;
        r7021: Record 7000003;
        r7022: Record 7000004;
    BEGIN
        //if r25.GET("Entry No.") THEN EXIT(r25."Due Date");
        if STRLEN(Rec."Document No.") > 20 THEN EXIT(0D);
        r7020.SETRANGE(r7020."Document No.", Rec."Document No.");
        r7020.SETRANGE(r7020."No.", Rec."Bill No.");
        r7021.SETRANGE(r7021."Document No.", Rec."Document No.");
        r7021.SETRANGE(r7021."No.", Rec."Bill No.");
        r7022.SETRANGE(r7022."Document No.", Rec."Document No.");
        r7022.SETRANGE(r7022."No.", Rec."Bill No.");
        if r7020.FINDFIRST THEN EXIT(r7020."Due Date");
        if r7021.FINDFIRST THEN EXIT(r7021."Due Date");
        if r7022.FINDFIRST THEN EXIT(r7022."Due Date");
    END;
    /// <summary>
    /// EmpresaBuscar.
    /// </summary>
    /// <param name="emp">Text.</param>
    procedure EmpresaBuscar(emp: Text)
    begin
        EmpresaTxt := Emp;
    end;

    Procedure Varias()
    begin
        VariasEmpresas := true;
    end;


}