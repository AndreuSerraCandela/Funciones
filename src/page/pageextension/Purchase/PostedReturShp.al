/// <summary>
/// PageExtension AlbaranCompra (ID 80116) extends Record Posted Purchase Receipt.
/// </summary>
pageextension 80181 DevilCompra extends "Posted Return Shipment"
{



    layout
    {
        modify("Posting Date")
        {
            StyleExpr = Rojo;


        }
        modify("Return Order No.")
        {
            trigger OnLookup(var Text: Text): Boolean
            var
                r38: Record 38;
            BEGIN
                r38.SETRANGE(r38."Document Type", r38."Document Type"::"Return Order");
                r38.SETRANGE(r38."No.", Rec."Return Order No.");
                Page.RUNMODAL(0, r38);
            END;
        }
        addafter("Document Date")
        {
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
            field(Facturado; eFacturado)
            {
                ApplicationArea = All;
                StyleExpr = Negro;
                trigger OnDrillDown()
                VAR
                    r123: Record 125;
                    r122: Record "Purch. Cr. Memo Hdr.";
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
            field("Fecha Inicial"; TraeFechaProy('I')) { ApplicationArea = All; }
            field("Fecha final"; TraeFechaProy('I')) { ApplicationArea = All; }
            field("Nº Proyecto"; Rec."Nº Proyecto") { ApplicationArea = All; }
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
                    if eFacturado <> 0 THEN ERROR('El albarán ya eata facturado');
                    CLEAR(c90);
                    c90.ContabilizarDevoluciones(Rec);
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
                    c90.DesContabilizarDevoluciones(Rec);
                END;
            }
            action("Borrar Albarán")
            {
                ApplicationArea = All;
                Image = Delete;
                trigger OnAction()
                Var
                    Control: Codeunit ControlProcesos;
                BEGIN
                    Control.BorrcaAlb();

                    if Rec.Facturado THEN ERROR('Ya esta facturado');
                    ControlProcesos.BorrarDevolucion(Rec);
                END;
            }






        }
    }
    VAR
        PurchRcptHeader: Record "Purch. Rcpt. Header";
        rMem: Record "Access Control";
        Rojo: Text;
        r17: Record "G/L Entry";
        r123: Record 123;
        r122: Record "Purch. Inv. Header";
        r125: Record 125;
        r25: Record 25;
        Negro: Text;
        ControlProcesos: Codeunit Albaranes;
        Empresa: Text;

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

    PROCEDURE TraeNombreProyecto(numproy: Code[20]): Text[100];
    VAR
        rProy: Record 167;
    BEGIN
        if rProy.GET(numproy) THEN
            EXIT(rProy.Description);
    END;

    PROCEDURE TraeFechaProy(fi: Text[1]): Date;
    VAR
        r36: Record 36;
    BEGIN
        Rec.CALCFIELDS("Nº Contrato Venta");
        if r36.GET(r36."Document Type"::Order, Rec."Nº Contrato Venta") THEN BEGIN
            if fi = 'I' THEN EXIT(r36."Fecha inicial proyecto");
            if fi = 'F' THEN EXIT(r36."Fecha fin proyecto");
        END;
        EXIT(0D);
    END;

    PROCEDURE eContabilizado(): Decimal;
    VAR
        r17: Record "G/L Entry";
        Importe: Decimal;
    BEGIN
        if Empresa <> '' THEN
            r17.CHANGECOMPANY(Empresa);
        r17.SETCURRENTKEY(r17."Document No.");
        r17.SETRANGE(r17."Document No.", Rec."No.");
        if r17.FINDFIRST THEN
            REPEAT
                if COPYSTR(r17."G/L Account No.", 1, 1) = '6' THEN Importe := Importe + r17.Amount;
                if COPYSTR(r17."G/L Account No.", 1, 1) = '2' THEN Importe := Importe + r17.Amount;
            UNTIL r17.NEXT = 0;
        EXIT(Importe);
    END;

    PROCEDURE eFacturado(): Decimal;
    VAR
        r121: Record 6651;
        Importe: Decimal;
    BEGIN
        if Empresa <> '' THEN
            r121.CHANGECOMPANY(Empresa);
        r121.SETRANGE(r121."Document No.", Rec."No.");
        if r121.FINDFIRST THEN
            REPEAT
                Importe := Importe + r121."Quantity Invoiced" * r121."Direct Unit Cost"
                * (1 - r121."Line Discount %" / 100);
            UNTIL r121.NEXT = 0;
        EXIT(-Importe);
    END;

    PROCEDURE eDescont(): Decimal;
    VAR
        r121: Record 6651;
        Importe: Decimal;
        r17: Record "G/L Entry";
        r123: Record 125;
        r122: Record "Purch. Cr. Memo Hdr.";
    BEGIN
        if Empresa <> '' THEN
            r123.CHANGECOMPANY(Empresa);
        if Empresa <> '' THEN
            r122.CHANGECOMPANY(Empresa);
        if Empresa <> '' THEN
            r17.CHANGECOMPANY(Empresa);
        r123.SETCURRENTKEY(r123."Buy-from Vendor No.", r123.Description);
        //r123.SETRANGE(r123."Buy-from Vendor No.","Buy-from Vendor No.");
        r123.SETFILTER(r123.Description, '%1', '*' + Rec."No." + '*');
        if r123.FINDFIRST THEN
            REPEAT
                r122.SETRANGE(r122."No.", r123."Document No.");
                if r122.FINDFIRST THEN BEGIN
                    r17.SETCURRENTKEY(r17."Document No.");
                    r17.SETRANGE(r17."Document No.", r122."No.");
                    if r17.FINDFIRST THEN
                        REPEAT
                            if COPYSTR(r17."G/L Account No.", 1, 4) = '4009' THEN Importe := Importe + r17.Amount;
                            if COPYSTR(r17."G/L Account No.", 1, 4) = '4109' THEN Importe := Importe + r17.Amount;
                        UNTIL r17.NEXT = 0;
                END;
            UNTIL r123.NEXT = 0;
        EXIT(Importe);
    END;

    PROCEDURE Pasada(): Boolean;
    VAR
        r123: Record 123;
        r122: Record "Purch. Inv. Header";
        r125: Record 125;
        r124: Record "Purch. Cr. Memo Hdr.";
    BEGIN
        if Empresa <> '' THEN
            r123.CHANGECOMPANY(Empresa);
        if Empresa <> '' THEN
            r124.CHANGECOMPANY(Empresa);
        if Empresa <> '' THEN
            r123.CHANGECOMPANY(Empresa);
        if Empresa <> '' THEN
            r122.CHANGECOMPANY(Empresa);
        r125.SETCURRENTKEY(r125."Buy-from Vendor No.", r125.Description);
        r125.SETFILTER(r125.Description, '%1', '*' + Rec."No." + '*');
        if r124.FINDFIRST THEN BEGIN
            r124.SETRANGE(r124."No.", r125."Document No.");
            if r124.FINDFIRST THEN BEGIN
                EXIT(TRUE);
            END;
        END;
        r123.SETCURRENTKEY(r123."Buy-from Vendor No.", r123.Description);
        //r123.SETRANGE(r123."Buy-from Vendor No.","Buy-from Vendor No.");
        r123.SETFILTER(r123.Description, '%1', '*' + Rec."No." + '*');
        if NOT r123.FINDFIRST THEN EXIT(FALSE);
        r122.SETRANGE(r122."No.", r123."Document No.");
        if NOT r122.FINDFIRST THEN BEGIN
            EXIT(FALSE);
        END;
        EXIT(TRUE);
    END;

    PROCEDURE Total2(VAR r120: Record 6650): Decimal;
    VAR
        r121: Record 6651;
        Importe: Decimal;
    BEGIN
        if Empresa <> '' THEN
            r121.CHANGECOMPANY(Empresa);
        r121.SETRANGE(r121."Document No.", r120."No.");
        if r121.FINDFIRST THEN
            REPEAT
                Importe := Importe + ((r121.Quantity - r121."Quantity Invoiced")
                * r121."Direct Unit Cost" * (1 - r121."Line Discount %" / 100));
            UNTIL r121.NEXT = 0;
        EXIT(Importe);
    END;

    PROCEDURE Total(): Decimal;
    VAR
        r121: Record 6651;
        Importe: Decimal;
    BEGIN
        if Empresa <> '' THEN
            r121.CHANGECOMPANY(Empresa);
        r121.SETRANGE(r121."Document No.", Rec."No.");
        if r121.FINDFIRST THEN
            REPEAT
                Importe := Importe + (r121.Quantity * r121."Direct Unit Cost" * (1 - r121."Line Discount %" / 100));
            UNTIL r121.NEXT = 0;
        EXIT(-Importe);
    END;


}
