

/// <summary>
/// PageExtension PostedReturnShipments (ID 80345).
/// </summary>
pageextension 80193 PostedReturnShipments Extends "Posted Return Shipments"
{
    layout
    {
        // Repeater(Detalle){
        // field("No.";Rec."No."){ApplicationArea=All;}
        // field("Buy-from Vendor No.";Rec."Buy-from Vendor No."){ApplicationArea=All;}
        // field("Pay-to Vendor No.";Rec."Pay-to Vendor No."){ApplicationArea=All;}
        addafter("Posting Date")
        {
            field("Nº Proyecto"; Rec."Nº Proyecto") { ApplicationArea = All; }
            // field("Return Order No.";Rec."Return Order No."){ApplicationArea=All;}
            // field("Buy-from Vendor Name";Rec."Buy-from Vendor Name"){ApplicationArea=All;}
            // field("Location Code";Rec."Location Code"){ApplicationArea=All;}
            //                                                  CaptionML=ESP=Total Devolición;
            field(Total; Total) { ApplicationArea = All; }
            //                                                  CaptionML=ESP=Contabilizado;
            field(Contabilizado; eContabilizado)
            {
                ApplicationArea = All;
                trigger OnDrillDown()
                VAR
                    r17: Record "G/L Entry";
                BEGIN
                    r17.SETCURRENTKEY(r17."Document No.");
                    r17.SETRANGE(r17."Document No.", Rec."No.");
                    Page.RUNMODAL(0, r17);
                END;
            }
            //                                                  CaptionML=ESP=Pendiente;
            field(Pendiente; eContabilizado - eFacturado) { ApplicationArea = All; }
            //                                                  CaptionML=ESP=Facturado;
            field(Facturado; eFacturado)
            {
                ApplicationArea = All;
                trigger OnDrillDown()
                VAR
                    r124: Record "Purch. Cr. Memo Hdr.";
                    r125: Record 125;
                BEGIN
                    r124.CLEARMARKS;
                    r125.SETCURRENTKEY(r125."Buy-from Vendor No.", r125.Description);
                    r125.SETFILTER(r125.Description, '%1', '*' + Rec."No." + '*');
                    if r125.FINDFIRST THEN
                        REPEAT
                            if r124.GET(r125."Document No.") THEN r124.MARK := TRUE;
                        UNTIL r125.NEXT = 0;
                    r124.MARKEDONLY := TRUE;
                    Page.RUNMODAL(0, r124);
                END;
            }
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
                Scope = Repeater;
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
                    r121: Record "Return Shipment Header";
                BEGIN

                    CLEAR(c90);
                    c90.DesContabilizarDevoluciones(Rec);
                END;
            }
            action("Marcar Como Facturado")
            {
                ApplicationArea = All;
                Image = Invoice;

                trigger OnAction()
                Begin
                    ControlProcesos.MarcarComoFacturadoDev(Rec."No.");
                End;
            }

            action("Convertir en Albarán")
            {
                ApplicationArea = All;
                Image = Receipt;
                trigger OnAction()
                Var
                    c90: Codeunit Albaranes;
                BEGIN
                    CLEAR(c90);
                    c90.ConvertirEnAlbaran(Rec);
                END;

            }

        }

    }
    // field("Buy-from Post Code";Rec."Buy-from Post Code"){ApplicationArea=All;}
    // field("Currency Code";Rec."Currency Code"){ApplicationArea=All;}
    // field("Buy-from Country/Region Code";Rec."Buy-from Country/Region Code"){ApplicationArea=All;}
    // field("Buy-from Contact";Rec."Buy-from Contact"){ApplicationArea=All;}
    // field("Pay-to Name";Rec."Pay-to Name"){ApplicationArea=All;}
    // field("Pay-to Post Code";Rec."Pay-to Post Code"){ApplicationArea=All;}
    // field("Pay-to Country/Region Code";Rec."Pay-to Country/Region Code"){ApplicationArea=All;}
    // field("Pay-to Contact";Rec."Pay-to Contact"){ApplicationArea=All;}
    // field("Ship-to Code";Rec."Ship-to Code"){ApplicationArea=All;}
    // field("Ship-to Name";Rec."Ship-to Name"){ApplicationArea=All;}
    // field("Ship-to Post Code";Rec."Ship-to Post Code"){ApplicationArea=All;}
    // field("Ship-to Country/Region Code";Rec."Ship-to Country/Region Code"){ApplicationArea=All;}
    // field("Ship-to Contact";Rec."Ship-to Contact"){ApplicationArea=All;}
    // field("Purchaser Code";Rec."Purchaser Code"){ApplicationArea=All;}
    // field("Shortcut Dimension 1 Code";Rec."Shortcut Dimension 1 Code"){ApplicationArea=All;}
    // field("Shortcut Dimension 2 Code";Rec."Shortcut Dimension 2 Code"){ApplicationArea=All;}
    // field("No. Printed";Rec."No. Printed"){ApplicationArea=All;}
    // field("Order Address Code";Rec."Order Address Code"){ApplicationArea=All;}
    //     { 10  ;CommandButton;1980 ;5940 ;2200 ;550  ;HorzGlue=Right;
    //                                                  Default=true;
    //                                                  PushAction=LookupOK;
    //                                                  InvalidActionAppearance=Hide }
    //     { 11  ;CommandButton;4400 ;5940 ;2200 ;550  ;HorzGlue=Right;
    //                                                  Cancel=true;
    //                                                  PushAction=LookupCancel;
    //                                                  InvalidActionAppearance=Hide }
    //     { 12  ;CommandButton;14080;5940 ;2200 ;550  ;HorzGlue=Right;
    //                                                  PushAction=FormHelp }
    //     { 21  ;CommandButton;9240 ;5940 ;2200 ;550  ;HorzGlue=Right;
    //                                                  Ellipsis=true;
    //                                                  CaptionML=ENU='&Print;
    //                                                             ESP=&Imprimir];
    // trigger OnAction()BEGIN
    //                                                           CurrPage.SETSELECTIONFILTER(ReturnShptHeader);
    //                                                           ReturnShptHeader.PrintRecords(TRUE);
    //                                                         END;
    //                                                          }
    //     { 22  ;CommandButton;11660;5940 ;2200 ;550  ;HorzGlue=Right;
    //                                                  CaptionML=ENU='&Navigate;
    //                                                             ESP=&Navegar];
    // trigger OnAction()BEGIN
    //                                                           Navigate;
    //                                                         END;
    //                                                          }
    //     { 23  ;MenuButton   ;6820 ;5940 ;2200 ;550  ;HorzGlue=Right;
    //                                                  CaptionML=ENU='&Return Shpt.;
    //                                                             ESP=&Env. devol.];
    //                                                  Menu=MENUITEMS
    //                                                  {
    //                                                    { ID=24;
    //                                                      PushAction=RunObject;
    //                                                      ShortCutKey=Mayús+F5;
    //                                                      CaptionML=ENU='Card;
    //                                                                 ESP=Ficha];
    //                                                      RunObject=Page 6650;
    //                                                      RunPageLinkType=OnUpdate;
    //                                                      RunPageLink=No.=FIELD(No.) }
    //                                                    { ID=29;
    //                                                      PushAction=RunObject;
    //                                                      ShortCutKey=F9;
    //                                                      CaptionML=ENU='Statistics;
    //                                                                 ESP=Estadísticas];
    //                                                      RunObject=Page 6655;
    //                                                      RunPageLinkType=OnUpdate;
    //                                                      RunPageLink=No.=FIELD(No.) }
    //                                                    { ID=30;
    //                                                      PushAction=RunObject;
    //                                                      CaptionML=ENU='Co&mments;
    //                                                                 ESP=C&omentarios];
    //                                                      RunObject=Page 66;
    //                                                      RunPageLinkType=OnUpdate;
    //                                                      RunPageLink=Document Type=CONST(Posted Return Shipment),
    //                                                                  No.=FIELD(No.) }
    //                                                    { ID=1100253008;
    //                                                      CaptionML=ESP=Añadir Marca;
    //     trigger OnAction()BEGIN
    //                                                               if UPPERCASE(USERID)='MAC' THEN BEGIN
    //                                                                "Reason Code":=FORMAT(WORKDATE);
    //                                                                MODIFY;
    //                                                               END;
    //                                                             END;
    //                                                              }
    //                                                    { ID=1100253009;
    //                                                      CaptionML=ESP=Quitar Marca;
    //     trigger OnAction()BEGIN
    //                                                               if UPPERCASE(USERID)='MAC' THEN BEGIN
    //                                                                "Reason Code":='';
    //                                                                MODIFY;
    //                                                               END;
    //                                                             END;
    //                                                              }
    //                                                  }
    //                                                   }
    //   }
    //   CODE
    //   {
    VAR
        ReturnShptHeader: Record 6650;
        Empresa: Text[30];
        ControlProcesos: Codeunit Utilitis;

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

    PROCEDURE CambiaEmpresa(pEmpresa: Text[30]);
    BEGIN
        Empresa := pEmpresa;
    END;

    trigger OnOpenPage()
    begin
        If Empresa <> '' THEN
            Rec.ChangeCompany(Empresa);
    end;
    //     BEGIN
    //     END.
}
