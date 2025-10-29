/// <summary>
/// PageExtension AlbaranCompra (ID 80116) extends Record Posted Purchase Receipt.
/// </summary>
pageextension 80116 AlbaranCompra extends "Posted Purchase Receipt"
{



    layout
    {
        modify("Posting Date")
        {
            StyleExpr = Rojo;


        }

        addafter("Quote No.")
        {
            field("Descripción Proyecto"; Rec.DescripcionProyecto(Rec."Order No."))
            {
                ApplicationArea = All;
            }
            field(Contabilizado; Rec.eContabilizado(Rec."No."))
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
            field(Facturado; Rec.eFacturado(Rec."No."))
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
            field("Fecha Inicial"; Rec.TraeFechaProy('I')) { ApplicationArea = All; }
            field("Fecha final"; Rec.TraeFechaProy('I')) { ApplicationArea = All; }
            field("Nº Proyecto"; Rec."Nº Proyecto") { ApplicationArea = All; Editable = false; }
            field("Nº Contrato Venta"; Rec."Nº Contrato Venta") { ApplicationArea = All; }
            //field("Descripción Proyecto"; "Descripción Proyecto") { ApplicationArea = All;}
        }
    }
    actions
    {
        addlast(processing)
        {
            action(Contabilizar)
            {
                ApplicationArea = All;
                Image = Post;
                ShortCutKey = F9;
                trigger OnAction()
                Var
                    c90: Codeunit ContabAlb;
                BEGIN
                    if Rec.eFacturado(Rec."No.") <> 0 THEN ERROR('El albarán ya eata facturado');
                    CLEAR(c90);
                    c90.ContabilizarAlbaranes(Rec);
                END;
            }
            action(Descontabilizar)
            {
                ApplicationArea = All;
                Image = Undo;
                trigger OnAction()
                Var
                    c90: Codeunit Albaranes;
                BEGIN
                    Clear(C90);
                    c90.DesContabilizar(Rec);
                END;
            }
            action("Marcar Como Facturado")
            {
                ApplicationArea = All;
                Image = Invoice;

                trigger OnAction()
                BEGIN
                    Control.MarcaAlb();
                    controlProcesos.MarcarComoFacturado(Rec);
                END;
            }
            action("Marcar Como Contabilizado")
            {
                ApplicationArea = All;
                Image = PostApplication;
                trigger OnAction()
                Begin
                    Control.MarcaAlb();
                    controlProcesos.MarcarComoContabilizado(Rec, true);
                END;
            }
            action("Generar Pedido")
            {
                Image = CreateDocument;
                ApplicationArea = All;
                trigger OnAction()
                BEGIN
                    controlProcesos.GeneraPedido(Rec);
                END;
            }
            action("Borrar Albarán")
            {
                ApplicationArea = All;
                Image = Delete;
                trigger OnAction()
                Var

                BEGIN
                    Control.BorrcaAlb();

                    if Rec.Facturado THEN ERROR('Ya esta facturado');
                    ControlProcesos.BorrarAlbaran(Rec);
                END;
            }
            action("Desmarcar como facturado")
            {
                ApplicationArea = All;
                Image = UnApply;
                trigger OnAction()
                BEGIN
                    if Rec.eFacturado2(Rec."No.") <> 0 THEN ERROR('Es consciente de lo que está intentando hacer ?');
                    Control.MarcaAlb();
                    controlProcesos.DesmMarCarComoFacurado(Rec);
                END;
            }
            action("Contabiliza Asiento Prov")
            {
                ApplicationArea = All;
                Image = VendorPaymentJournal;
                trigger OnAction()
                Var
                BEGIN
                    controlProcesos.ContabilizarAsientoProv(Rec);
                END;
            }
            action("Des-Contabiliza Asiento Prov")
            {
                ApplicationArea = All;
                Image = Undo;
                trigger OnAction()
                BEGIN
                    controlProcesos.DesmarcarAsientoProv(Rec);
                END;
            }
            action("Desmarcar Como Contabilizado")
            {
                ApplicationArea = All;
                Image = UnApply;

                trigger OnAction()
                BEGIN
                    ControlProcesos.DesmarcaComoCont(Rec);
                END;
            }
            action("Dimensiones Pedido")
            {
                ApplicationArea = All;
                Image = MapDimensions;
                trigger OnAction()
                BEGIN
                    controlProcesos.TrasladaDimensionesPed(Rec);
                END;
            }
            action("Traslada Dimensiones")
            {
                ApplicationArea = All;
                Image = DimensionSets;
                trigger OnAction()
                BEGIN
                    controlProcesos.TrasladaDimensionesAlb(Rec);
                END;
            }
            action("Traspasa otra empresa")
            {
                ApplicationArea = All;
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
                ApplicationArea = All;
                Image = AdjustEntries;
                trigger OnAction()
                BEGIN
                    if Rec.eFacturado2(Rec."No.") = Rec.eContabilizado(Rec."No.") THEN ERROR('El albarán ya está correcto');
                    if NOT Rec.Facturado THEN ERROR('El albarán no está facturado');
                    if Rec.eFacturado2(Rec."No.") <> Rec.eFacturado(Rec."No.") THEN BEGIN
                        controlProcesos.AjustarAlbaran(Rec, Rec.eFacturado2(Rec."No."), Rec.efacturado(Rec."No."));
                    END;
                END;
            }
            action("Enviar a otra empresa")
            {
                ApplicationArea = All;
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
            action("Des-Contabiliza Asiento Prov Cartera")
            {
                ApplicationArea = All;
                Image = CreateElectronicReminder;
                trigger OnAction()
                BEGIN
                    controlProcesos.DescontabilizaAsCarte(Rec);
                END;
            }
            action(Finalizar)
            {
                ApplicationArea = All;
                Image = EndingText;
                trigger OnAction()
                BEGIN
                    if ABS(ABS(Rec.eFacturado(Rec."No.")) - ABS(Rec.eContabilizado(Rec."No."))) > 0.24 THEN
                        if NOT Rec.Finalizado THEN
                            ERROR('Ojo, el albarán tiene diferencias entre lo contabilizado y facturado');
                    controlProcesos.Finalizar(Rec);
                END;
            }
            action("Desglosar Albarán")
            {
                ApplicationArea = All;
                Image = BinContent;
                trigger OnAction()
                Var
                    c90: Codeunit ContabAlb;
                BEGIN
                    CLEAR(c90);
                    c90.ContabilizarAlbaranesDeslgo(Rec);
                END;
            }
            action("Asigna Datos Albarán")
            {
                ApplicationArea = All;
                Image = ShipAddress;
                trigger OnAction()
                BEGIN
                    ControlProcesos.AsignaDatosAlbaran(Rec);
                END;
            }
            action("Regenera Asiento")
            {
                ApplicationArea = All;
                Image = ChangeDimensions;
                trigger OnAction()
                Var
                BEGIN
                    Control.MarcaAlb();
                    ControlProcesos.RegeneraAsiento(Rec);
                END;
            }
            action("Recalcular Cantidad Facturada")
            {
                ApplicationArea = All;
                Image = UntrackedQuantity;
                trigger OnAction()
                BEGIN
                    ControlProcesos.RecalCularCantidadFacturada(Rec."No.");
                END;
            }

            action("Recalcular Iva")
            {
                ApplicationArea = All;
                Image = VATEntries;
                trigger OnAction()
                BEGIN
                    ControlProcesos.RecalcularIva(Rec);
                END;
            }
        }
    }
    VAR
        PurchRcptHeader: Record "Purch. Rcpt. Header";
        Control: Codeunit ControlProcesos;
        Rojo: Text;
        r17: Record "G/L Entry";
        r123: Record 123;
        r122: Record "Purch. Inv. Header";
        r125: Record 125;
        r25: Record 25;
        Negro: Text;
        ControlProcesos: Codeunit Albaranes;

    trigger OnAfterGetRecord()
    begin
        r17.SETCURRENTKEY(r17."Document No.");
        r17.SETRANGE(r17."Document No.", Rec."No.");
        r17.SETRANGE(r17."Document Type", r17."Document Type"::Receipt);
        if r17.FINDFIRST THEN
            if r17."Posting Date" <> Rec."Posting Date" THEN
                Rojo := 'Strong';
        r25.SETCURRENTKEY(r25."Document No.");
        r25.SETRANGE(r25."Document No.", Rec."No.");
        if r25.FINDFIRST THEN EXIT;
        r123.SETCURRENTKEY(r123."Buy-from Vendor No.", r123.Description);
        r123.SETFILTER(r123.Description, '%1', '*' + Rec."No." + '*');
        if NOT r123.FINDFIRST THEN BEGIN
            r125.SETCURRENTKEY(r125.Description);
            r125.SETFILTER(r125.Description, '%1', '*' + Rec."No." + '*');
            if NOT r125.FINDFIRST THEN Negro := 'Strong';
            EXIT;
        END;
        // r122.SETRANGE(r122."No.",r123."Document No.");
        if NOT r122.GET(r123."Document No.") THEN
            Negro := 'Strong';
    END;

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

    // PROCEDURE eContabilizado(): Decimal;
    // VAR
    //     r17: Record "G/L Entry";
    //     Importe: Decimal;
    // BEGIN
    //     r17.SETCURRENTKEY(r17."Document No.");
    //     r17.SETRANGE(r17."Document No.", Rec."No.");
    //     if r17.FINDFIRST THEN
    //         REPEAT
    //             if (COPYSTR(r17."G/L Account No.", 1, 1) = '6') OR (COPYSTR(r17."G/L Account No.", 1, 1) = '2') THEN Importe := Importe + r17.Amount;
    //         UNTIL r17.NEXT = 0;
    //     EXIT(Importe);
    // END;

    // PROCEDURE eFacturado(): Decimal;
    // VAR
    //     r121: Record "Purch. Rcpt. Line";
    //     Importe: Decimal;
    // BEGIN
    //     if eFacturado2(Rec."No.") = eContabilizado THEN EXIT(eFacturado2(Rec."No."));
    //     r121.SETRANGE(r121."Document No.", Rec."No.");
    //     if r121.FINDFIRST THEN
    //         REPEAT
    //             Importe := Importe + r121."Quantity Invoiced" * r121."Direct Unit Cost"
    //             * (1 - r121."Line Discount %" / 100);
    //         UNTIL r121.NEXT = 0;
    //     if Pasada THEN
    //         EXIT(Importe);
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





}
pageextension 80227 LineasAlbaranCompra extends "Posted Purchase Rcpt. Subform"
{
    layout
    {
        addafter("Quantity")
        {
            field("Fecha inicial recurso"; Rec."Fecha inicial recurso") { ApplicationArea = All; }
            field("Fecha final recurso"; Rec."Fecha final recurso") { ApplicationArea = All; }
        }
    }
    actions
    {
        addlast(processing)
        {
            action("Recalcula fechas")
            {
                ApplicationArea = All;
                Image = ChangeDate;
                trigger OnAction()
                BEGIN
                    controlProcesos.RecalcularFechas(Rec);
                END;
            }

        }
    }
    VAR
        ControlProcesos: Codeunit Albaranes;

}
