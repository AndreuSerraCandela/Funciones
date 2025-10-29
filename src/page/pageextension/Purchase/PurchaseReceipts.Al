/// <summary>
/// PageExtension AlbaranesCompra (ID 80146) extends Record Posted Purchase Receipts.
/// </summary>
pageextension 80146 AlbaranesCompra extends "Posted Purchase Receipts"
{



    layout
    {
        modify("Posting Date")
        {
            StyleExpr = Rojo;
            ApplicationArea = All;
            Visible = true;

        }

        addafter("Posting Date")
        {
            field("Descripción Proyecto"; Rec.DescripcionProyecto(Rec."Order No."))
            {
                ApplicationArea = All;
            }
            field("Order No."; Rec."Order No.")
            {
                ApplicationArea = All;
            }
            field("Total Albarán"; Total[1])
            { ApplicationArea = All; }
            field("Diferencia Facturado/Contabilizado"; Total[2])
            {
                ApplicationArea = All;
            }
            field("Total Pendiente"; Total[5])
            {
                ApplicationArea = All;
            }
            field(Contabilizado; eContabilizado)
            {
                ApplicationArea = All;
                trigger OnDrillDown()
                VAR
                    r17: Record "G/L Entry";
                BEGIN
                    r17.SETCURRENTKEY(r17."Document No.");
                    r17.SETRANGE(r17."Document No.", Rec."No.");
                    if r17.FINDFIRST THEN Page.RUNMODAL(0, r17);
                END;
            }
            field(Facturado; ToTal[4])
            {
                ApplicationArea = All;
                StyleExpr = Negro;
                trigger OnDrillDown()
                VAR
                    r123: Record 123;
                    r122: Record "Purch. Inv. Header";
                BEGIN
                    r123.SETCURRENTKEY(r123."Buy-from Vendor No.", r123.Description);
                    //r123.SETRANGE(r123."Buy-from Vendor No.","Buy-from Vendor No.");
                    r123.SETFILTER(r123.Description, '%1', '*' + Rec."No." + '*');
                    if r123.FINDFIRST THEN
                        REPEAT
                            if r122.GET(r123."Document No.") THEN r122.MARK := TRUE;
                        UNTIL r123.NEXT = 0;
                    r122.MARKEDONLY := TRUE;
                    Page.RUNMODAL(0, r122);
                END;
            }
            field("Facturado Contabilidad"; FacCont)
            { ApplicationArea = All; }
            field("Pendiente a Fecha"; Rec.Pdte(Rec."No.", Rec.GetFilter("Posting Date"), Empresa))
            {
                ApplicationArea = All;
                Visible = false;
            }
            field("Está Contabilizado"; Rec.Contabilizado)
            {
                ApplicationArea = All;
            }
            field("Está facturado"; Rec.Facturado)
            {
                ApplicationArea = All;
            }
            field("Está finalizado"; Rec.Finalizado)
            {
                ApplicationArea = All;
            }
            field("Pasada Factura"; pPasada)
            {
                ApplicationArea = All;
            }
            field("Fecha Inicial"; Rec.TraeFechaProy('I')) { ApplicationArea = All; }
            field("Fecha final"; Rec.TraeFechaProy('F')) { ApplicationArea = All; }
            field("Nº Proyecto"; Rec."Nº Proyecto") { ApplicationArea = All; }
            field("Nº Contrato Venta"; Rec."Nº Contrato Venta") { ApplicationArea = All; }
            //field("Descripción Proyecto"; "Descripción Proyecto") { ApplicationArea = All;}
        }
    }
    actions
    {
        addlast(processing)
        {
            action(Recalcular)
            {
                Image = Calculate;
                ApplicationArea = all;
                Scope = Repeater;
                trigger OnAction()
                var
                    Inf: Record "Company Information";
                    Comandos: Record Comandos;
                begin
                    if Inf.Get() Then begin
                        Inf.Calcular := 'Albaranes';
                        inf.Modify();
                    end;
                    Comandos.Init();
                    Comandos.Id := CreateGuid();
                    Comandos."User ID" := UserId;
                    Comandos.Empresa := CompanyName;
                    Comandos.Fecha := CurrentDateTime;
                    Comandos.Procesado := false;
                    Comandos.Comando := 'Albaranes';
                    Comandos.Insert;
                end;
            }
            group("Funciones Contabilizar")
            {
                action(Contabilizar)
                {
                    ApplicationArea = all;
                    Scope = Repeater;
                    Image = Post;
                    ShortCutKey = F9;
                    trigger OnAction()
                    Var
                        c90: Codeunit ContabAlb;
                        r120: Record "Purch. Rcpt. Header";
                    BEGIN
                        CurrPage.SetSelectionFilter(r120);
                        if r120.FindSet() Then
                            repeat
                                if Rec.eFacturado(r120."No.") = 0 THEN begin
                                    CLEAR(c90);
                                    c90.ContabilizarAlbaranes(r120);
                                end;
                            until r120.Next() = 0;
                    END;
                }
                action(Descontabilizar)
                {
                    ApplicationArea = all;

                    Image = Undo;
                    trigger OnAction()
                    Var
                        c90: Codeunit Albaranes;
                        r121: Record "Purch. Rcpt. Line";
                    BEGIN

                        CLEAR(c90);
                        c90.DesContabilizar(Rec);
                    END;
                }
                action("Contabiliza Asiento Prov")
                {
                    ApplicationArea = all;
                    Scope = Repeater;
                    Image = VendorPaymentJournal;
                    trigger OnAction()
                    Begin
                        ControlProcesos.ContabilizarAsientoProv(Rec);
                    end;
                }
                action("Des-Contabiliza Asiento Prov")
                {
                    ApplicationArea = all;

                    Image = Undo;
                    trigger OnAction()
                    begin
                        ControlProcesos.DesmarcarAsientoProv(Rec);
                    end;
                }
                action("Desmarcar Como Contabilizado")
                {
                    ApplicationArea = all;

                    Image = UnApply;

                    trigger OnAction()
                    begin
                        ControlProcesos.DesmarcaComoCont(Rec);
                    end;
                }
                action("Des-Contabiliza Asiento Prov Cartera")
                {
                    ApplicationArea = all;

                    Image = CreateElectronicReminder;
                    trigger OnAction()
                    BEGIN
                        ControlProcesos.DescontablilizarAlbAlb(Rec);
                    END;
                }

            }
            group("Funciones Facturar")
            {
                action("Marcar Como Facturado")
                {
                    ApplicationArea = all;

                    Image = Invoice;

                    trigger OnAction()
                    Begin
                        ControlProcesos.MarcarComoFacturado(Rec);
                    End;
                }
                action("Marcar Como Contabilizado")
                {
                    ApplicationArea = all;

                    Image = PostApplication;
                    trigger OnAction()
                    Begin
                        Control.MARCAALB();
                        ControlProcesos.MarcarComoContabilizado(Rec, true);

                    END;
                }
                action("Desmarcar como facturado")
                {
                    ApplicationArea = all;

                    Image = UnApply;
                    trigger OnAction()
                    Var
                    BEGIN
                        if Rec.eFacturado2(Rec."No.") <> 0 THEN ERROR('Es consciente de lo que está intentando hacer ?');
                        Control.MARCAALB();
                        ControlProcesos.DesmMarCarComoFacurado(Rec);

                    END;
                }
                action("Recalcular Cantidad Facturada")
                {
                    ApplicationArea = all;

                    Image = UntrackedQuantity;
                    trigger OnAction()
                    BEGIN
                        ControlProcesos.RecalCularCantidadFacturada(Rec."No.");
                    END;
                }
            }
            group("Otras Funciones")
            {
                action("Generar Pedido")
                {
                    Image = CreateDocument;
                    ApplicationArea = all;

                    trigger OnAction()
                    Begin
                        ControlProcesos.GeneraPedido(Rec);
                    End;
                }
                action("Borrar Albarán")
                {
                    ApplicationArea = all;

                    Image = Delete;
                    trigger OnAction()
                    Var
                        r121: Record "Purch. Rcpt. Line";
                        r17: Record "G/L Entry";
                        cUndo: Codeunit ContabAlb;
                        PurchLine: Record 39;
                        rMem: Record "Access Control";
                    BEGIN
                        Control.BorrcaAlb();
                        if Rec.Facturado THEN ERROR('Ya esta facturado');

                        r121.SETRANGE(r121."Document No.", Rec."No.");
                        if Rec.Contabilizado THEN ERROR('Esta Contabilizado');
                        if r121.FINDFIRST THEN
                            REPEAT
                                CLEAR(cUndo);
                                if (r121.Quantity <> 0) THEN BEGIN
                                    if PurchLine.GET(PurchLine."Document Type"::Order, r121."Order No.", r121."Order Line No.") THEN
                                        cUndo.UpdatePurchLine2(PurchLine, r121.Quantity, r121."Quantity (Base)");
                                END;
                            UNTIL r121.NEXT = 0;
                        ControlProcesos.BorrarAlbaran(Rec);

                    END;
                }


                action("Traslada Dimensiones")
                {
                    ApplicationArea = all;

                    Image = DimensionSets;
                    trigger OnAction()
                    Begin
                        ControlProcesos.TrasladaDimensionesAlb(Rec);
                    End;
                }
                action("Traspasa otra empresa")
                {
                    ApplicationArea = all;

                    Image = Company;
                    trigger OnAction()
                    Var
                        cProy: Codeunit "Gestion Proyecto";
                    BEGIN
                        CLEAR(cProy);
                        if cProy.DebeTraspasarsePC(Rec) THEN
                            cProy.TrasPasaCompraaEmpresas(Rec);
                    END;
                }
                action("Ajustar Albarán")
                {
                    ApplicationArea = all;

                    Image = AdjustEntries;
                    trigger OnAction()
                    Begin
                        if Rec.eFacturado2(Rec."No.") = Rec.eContabilizado(Rec."No.") THEN ERROR('El albarán ya está correcto');
                        if NOT Rec.Facturado THEN ERROR('El albarán no está facturado');
                        if Rec.eFacturado2(Rec."No.") <> Rec.eFacturado((Rec."No.")) THEN
                            ControlProcesos.AjustarAlbaran(Rec, Rec.eFacturado2(Rec."No."), Rec.efacturado(Rec."No."));
                    End;
                }
                action("Enviar a otra empresa")
                {
                    ApplicationArea = all;

                    Image = SendTo;
                    trigger OnAction()
                    Var
                        cProy: Codeunit "Gestion Proyecto";
                    BEGIN
                        CLEAR(cProy);
                        if cProy.DebeTraspasarsePC(Rec) THEN
                            cProy.TrasPasaCompraaEmpresas(Rec);
                    END;
                }

                action(Finalizar)
                {
                    ApplicationArea = all;
                    Scope = Repeater;
                    Image = EndingText;
                    trigger OnAction()
                    BEGIN
                        if ABS(ABS(Rec.eFacturado(Rec."No.")) - ABS(eContabilizado)) > 0.24 THEN
                            if NOT Rec.Finalizado THEN
                                ERROR('Ojo, el albarán tiene diferencias entre lo contabilizado y facturado');
                        ControlProcesos.Finalizar(Rec);

                    END;
                }
                action("Desglosar Albarán")
                {
                    ApplicationArea = all;

                    Image = BinContent;
                    trigger OnAction()
                    Var
                        c90: Codeunit ContabAlb;
                    BEGIn
                        CLEAR(c90);
                        c90.ContabilizarAlbaranesDeslgo(Rec);
                    END;
                }
                action("Asigna Datos Albarán")
                {
                    ApplicationArea = all;

                    Image = ShipAddress;
                    trigger OnAction()
                    BEGIN
                        ControlProcesos.AsignaDatosAlbaran(Rec);
                    END;
                }
                action("Regenera Asiento")
                {
                    ApplicationArea = all;

                    Image = ChangeDimensions;
                    trigger OnAction()
                    Var

                    BEGIN
                        Control.MARCAALB();
                        ControlProcesos.RegeneraAsiento(Rec);
                    END;
                }
            }

            action("Recalcular Iva")
            {
                ApplicationArea = all;

                Image = VATEntries;
                trigger OnAction()
                BEGIN
                    ControlProcesos.RecalcularIva(Rec);
                END;
            }

        }
        addlast(Promoted)
        {
            actionref(Recalcular_Ref; Recalcular)
            { }
            actionref(Contabilizar_Promoted; Contabilizar) { }
            actionref(DeszContabilizar_Promoted; DesContabilizar) { }

        }
    }
    VAR
        Calculo: Record "Calculo Albaranes";
        PurchRcptHeader: Record "Purch. Rcpt. Header";
        Control: Codeunit "ControlProcesos";
        Rojo: Text;
        r17: Record "G/L Entry";
        r123: Record 123;
        r122: Record "Purch. Inv. Header";
        r125: Record 125;
        r25: Record 25;
        Negro: Text;
        Total2: Decimal;
        ToTal: Array[5] of decimal;
        pPasada: Boolean;
        Empresa: Text[30];
        weContabilizado: Decimal;
        econTabilizado: Decimal;
        FacCont: Decimal;
        ControlProcesos: Codeunit Albaranes;

    trigger OnAfterGetRecord()
    var
        r121: Record "Purch. Rcpt. Line";
        Importe: Decimal;

    begin
        if Calculo.Get(Rec."No.") then begin
            Calculo.SetRange(Albaran, Rec."No.");
            Calculo.FindFirst();
            Calculo.SetLoadFields(Facturado, "Facturado Contabilidad", Total2, Contabilizado);
            Total2 := 0;
            Total[1] := 0;
            ToTal[2] := 0;
            ToTal[5] := 0;
            ToTal[1] := Calculo.Total2;
            FacCont := Calculo."Facturado Contabilidad";
            ToTal[4] := Calculo.Facturado;
            Total2 := Calculo.Total2 - Calculo.Facturado;
            econTabilizado := Calculo.Contabilizado;
            if eContabilizado = 0 THEN Total2 := 0;
            if (eContabilizado < Total2) AND (Total2 <> 0) THEN Total2 := eContabilizado;
            if Rec.Contabilizado = FALSE THEN Total2 := 0;
            Total[2] := Total2;
            Total[3] := eContabilizado;
            Total[4] := Rec.eFacturado(Rec."No.");
            if eContabilizado = Faccont THEN Total[4] := Faccont;
            Total[2] := Total2;
            Total[3] := Importe;
            Total[5] := Total[2];
            if Rec.Finalizado THEN Total[2] := 0;

        end else begin
            Total2 := 0;
            Total[1] := 0;
            ToTal[2] := 0;
            ToTal[5] := 0;
            Rec.CALCFIELDS("Importe Facturado");
            r121.CHANGECOMPANY(Empresa);
            r121.SETRANGE(r121."Document No.", Rec."No.");
            if r121.FINDFIRST THEN
                REPEAT
                    Total[1] := Total[1] + (r121.Quantity * r121."Direct Unit Cost" * (1 - r121."Line Discount %" / 100));
                    Total2 := Total2 + ((r121.Quantity - r121."Quantity Invoiced")
                    * r121."Direct Unit Cost" * (1 - r121."Line Discount %" / 100));
                //eFacturado := eFacturado + r121."Quantity Invoiced" * r121."Direct Unit Cost"
                //* (1 - r121."Line Discount %" / 100);
                UNTIL r121.NEXT = 0;

            r17.SETCURRENTKEY(r17."Document No.");
            r17.SETRANGE(r17."Document No.", Rec."No.");
            r17.SETRANGE(r17."Document Type", r17."Document Type"::Receipt);
            if r17.FINDFIRST THEN
                if r17."Posting Date" <> Rec."Posting Date" THEN
                    Rojo := 'Strong';
            r25.SETCURRENTKEY(r25."Document No.");
            r25.SETRANGE(r25."Document No.", Rec."No.");
            if Not r25.FINDFIRST THEN begin
                r123.SETCURRENTKEY(r123."Buy-from Vendor No.", r123.Description);
                r123.SETFILTER(r123.Description, '%1', '*' + Rec."No." + '*');
                if NOT r123.FINDFIRST THEN BEGIN
                    r125.SETCURRENTKEY(r125.Description);
                    r125.SETFILTER(r125.Description, '%1', '*' + Rec."No." + '*');
                    if NOT r125.FINDFIRST THEN Negro := 'Strong';

                END;
            end;
            // r122.SETRANGE(r122."No.",r123."Document No.");
            if NOT r122.GET(r123."Document No.") THEN
                Negro := 'Strong';
            Total[4] := Rec.eFacturado(Rec."No.");
            if ToTal[4] = 0 THEN pPasada := FALSE;
            r17.Reset();
            r17.SETCURRENTKEY(r17."Document No.");
            r17.SETRANGE(r17."Document No.", Rec."No.");
            if r17.FINDFIRST THEN
                REPEAT
                    if (COPYSTR(r17."G/L Account No.", 1, 1) = '6') OR (COPYSTR(r17."G/L Account No.", 1, 1) = '2') THEN Importe := Importe + r17.Amount;
                UNTIL r17.NEXT = 0;

            econTabilizado := Importe;

            if eContabilizado = 0 THEN Total2 := 0;
            if (eContabilizado < Total2) AND (Total2 <> 0) THEN Total2 := eContabilizado;
            if Rec.Contabilizado = FALSE THEN Total2 := 0;
            Total[2] := Total2;
            Total[3] := eContabilizado;
            FacCont := Rec.eFacturado2(Rec."No.");
            Total[4] := Rec.eFacturado(Rec."No.");
            if eContabilizado = Faccont THEN Total[4] := Faccont;

            Total[2] := Total2;
            Total[3] := Importe;


            Total[5] := Total[2];
            if Rec.Finalizado THEN Total[2] := 0;
            //Total[1]:=Amount;
            //eFacturado:="Importe Facturado";
            //Total2:=Amount-eFacturado;
        end;
    END;

    trigger OnOpenPage()
    var
        myInt: Integer;
    begin
        SelectLatestVersion();
        CurrPage.Update(false);
    end;

    trigger OnDeleteRecord(): Boolean
    BEGIN
        ERROR('Por que lo Borrars?');
    END;

    // PROCEDURE TraeNombreProyecto(numproy: Code[20]): Text[100];
    // VAR
    //     rProy: Record 167;
    // BEGIN
    //     if rProy.GET(numproy) THEN
    //         EXIT(rProy.Description);
    // END;

    // PROCEDURE TraeFechaProy(fi: Text[1]): Date;
    // VAR
    //     r36: Record 36;
    // BEGIN
    //     Rec.CALCFIELDS("Nº Contrato Venta");
    //     if r36.GET(r36."Document Type"::Order, Rec."Nº Contrato Venta") THEN BEGIN
    //         if fi = 'I' THEN EXIT(r36."Fecha inicial proyecto");
    //         if fi = 'F' THEN EXIT(r36."Fecha fin proyecto");
    //     END;
    //     EXIT(0D);
    // END;


    // PROCEDURE eFacturado(var pPurchRcptHeader: Record 120): Decimal;
    // VAR
    //     r121: Record "Purch. Rcpt. Line";
    //     Importe: Decimal;

    // BEGIN
    //     // if eFacturado2("No.") = weContabilizado THEN EXIT(eFacturado2("No."));
    //     r121.SETRANGE(r121."Document No.", pPurchRcptHeader."No.");
    //     if r121.FINDFIRST THEN
    //         REPEAT
    //             Importe := Importe + r121."Quantity Invoiced" * r121."Direct Unit Cost"
    //             * (1 - r121."Line Discount %" / 100);
    //         UNTIL r121.NEXT = 0;
    //     if Rec.Pasada(Rec."No.") THEN
    //         EXIT(Importe) else
    //         Exit(0);
    // END;

    // PROCEDURE Pasada(): Boolean;
    // VAR
    //     r123: Record 123;
    //     r122: Record "Purch. Inv. Header";
    //     r125: Record 125;
    //     r25: Record 25;
    // BEGIN
    //     r25.SETCURRENTKEY(r25."Document No.");
    //     r25.SETRANGE(r25."Document No.", Rec."No.");
    //     if r25.FINDFIRST THEN EXIT(TRUE);

    //     r123.SETCURRENTKEY(r123.Description);
    //     r123.SETFILTER(r123.Description, '%1', '*' + Rec."No." + '*');
    //     if NOT r123.FINDFIRST THEN BEGIN
    //         r125.SETCURRENTKEY(r125.Description);
    //         r125.SETFILTER(r125.Description, '%1', '*' + Rec."No." + '*');
    //         if NOT r125.FINDFIRST THEN EXIT(FALSE);
    //         EXIT(TRUE);
    //     END;
    //     if NOT r122.GET(r123."Document No.") THEN
    //         EXIT(FALSE);
    //     EXIT(TRUE);
    // END;

    // PROCEDURE eFacturado2(No: Code[20]): Decimal;
    // VAR
    //     r17: Record "G/L Entry";
    //     Importe: Decimal;
    // BEGIN
    //     r17.SETCURRENTKEY("G/L Account No.", "Document No.", "Posting Date", "Tax Area Code");
    //     r17.SETRANGE(r17."Tax Area Code", No);
    //     r17.SETFILTER(r17."Document No.", '<>%1', No);
    //     r17.SETRANGE(r17."G/L Account No.", '40090000', '40099999');
    //     if r17.FINDFIRST THEN BEGIN
    //         r17.CALCSUMS(Amount);
    //         Importe := r17.Amount;
    //     END;
    //     r17.SETCURRENTKEY("G/L Account No.", "Document No.", "Posting Date", "Tax Area Code");
    //     r17.SETRANGE(r17."Tax Area Code", No);
    //     r17.SETFILTER(r17."Document No.", '<>%1', No);
    //     r17.SETRANGE(r17."G/L Account No.", '41090000', '41099999');
    //     if r17.FINDFIRST THEN BEGIN
    //         r17.CALCSUMS(Amount);
    //         Importe += r17.Amount;
    //     END;

    //     EXIT(Importe);
    // END;

    /// <summary>
    /// Pdte.
    /// </summary>
    /// <returns>Return value of type Decimal.</returns>

    /// <summary>
    /// CambiaEmpresa.
    /// </summary>
    /// <param name="wEmpresa">Text.</param>
    procedure CambiaEmpresa(wEmpresa: Text)
    begin
        Rec.ChangeCompany(wEmpresa);
        Empresa := wEmpresa;
    end;


    // Procedure Total3(I : Integer) : Decimal
    // if NOT Calcular THEN EXIT(0);
    // Importe4:=0;
    // rAlb.CHANGECOMPANY(Empresa);
    // rAlb.COPYFILTERS(Rec);
    // Ventana.OPEN('Calculando ##########1##de###############2##');
    // //CurrForm.SETSELECTIONFILTER(rAlb);
    // Ventana.UPDATE(2,rAlb.COUNT);
    // if rAlb.FINDFIRST THEN REPEAT
    // a:=a+1;
    // Ventana.UPDATE(1,a);
    // r121.CHANGECOMPANY(Empresa);
    // r121.SETRANGE(r121."Document No.",rAlb."No.");
    // if r121.FINDFIRST THEN REPEAT
    //  Importe:=Importe+(r121.Quantity*r121."Direct Unit Cost"*(1-r121."Line Discount %"/100));
    // if Contab(rAlb."No.") THEN
    //  Importe4:=Importe4+((r121.Quantity-r121."Quantity Invoiced")
    //  *ROUND(r121."Direct Unit Cost"*(1-r121."Line Discount %"/100),0.001,'='));

    // UNTIL r121.NEXT=0;
    // UNTIL rAlb.NEXT=0;
    // Calcular:=FALSE;
    // Ventana.CLOSE;
    // EXIT(Importe);
    // End;
    // Procedure Total4() : Decimal
    // Begin
    //     if NOT Calcular THEN EXIT(0);
    //     rAlb.CHANGECOMPANY(Empresa);
    //     rAlb.COPYFILTERS(Rec);
    //     //CurrForm.SETSELECTIONFILTER(rAlb);
    //     if rAlb.FINDFIRST THEN REPEAT
    //     r121.CHANGECOMPANY(Empresa);
    //     r121.SETRANGE(r121."Document No.",rAlb."No.");
    //     if r121.FINDFIRST THEN REPEAT
    //     if Contab(rAlb."No.") THEN
    //     Importe:=Importe+((r121.Quantity-r121."Quantity Invoiced")
    //     *r121."Direct Unit Cost"*(1-r121."Line Discount %"/100));
    //     UNTIL r121.NEXT=0;
    //     UNTIL rAlb.NEXT=0;

    // EXIT(Importe);
    // End;





}
