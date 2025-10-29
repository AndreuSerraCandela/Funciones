/// <summary>
/// Page Compras vs Ventas (ID 50086).
/// </summary>
page 50086 "Compras vs Ventas"
{

    Editable = false;
    Caption = 'Histórico albaranes de compra';
    SourceTable = 120;

    layout
    {
        area(Content)
        {
            repeater(Detalle)
            {
                field("No."; Rec."No.") { ApplicationArea = All; }
                field("Buy-from Vendor No."; Rec."Buy-from Vendor No.") { ApplicationArea = All; }

                field("Pay-to Vendor No."; Rec."Pay-to Vendor No.") { ApplicationArea = All; }

                field("Posting Date"; Rec."Posting Date") { ApplicationArea = All; }

                field("Nº Proyecto"; Rec."Nº Proyecto") { ApplicationArea = All; }
                field("Order No."; Rec."Order No.") { ApplicationArea = All; }

                field("Order Address Code"; Rec."Order Address Code") { ApplicationArea = All; Visible = false; }
                field("Buy-from Vendor Name"; Rec."Buy-from Vendor Name") { ApplicationArea = All; }
                field("Buy-from Post Code"; Rec."Buy-from Post Code") { ApplicationArea = All; Visible = false; }
                field("Buy-from Country/Region Code"; Rec."Buy-from Country/Region Code") { ApplicationArea = All; Visible = false; }
                field("Buy-from Contact"; Rec."Buy-from Contact") { ApplicationArea = All; Visible = false; }
                field("Pay-to Name"; Rec."Pay-to Name") { ApplicationArea = All; Visible = false; }
                field("Pay-to Post Code"; Rec."Pay-to Post Code") { ApplicationArea = All; Visible = false; }
                field("Pay-to Country/Region Code"; Rec."Pay-to Country/Region Code") { ApplicationArea = All; Visible = false; }
                field("Pay-to Contact"; Rec."Pay-to Contact") { ApplicationArea = All; Visible = false; }
                field("Ship-to Code"; Rec."Ship-to Code") { ApplicationArea = All; Visible = false; }
                field("Ship-to Name"; Rec."Ship-to Name") { ApplicationArea = All; Visible = false; }
                field("Ship-to Post Code"; Rec."Ship-to Post Code") { ApplicationArea = All; Visible = false; }
                field("Ship-to Country/Region Code"; Rec."Ship-to Country/Region Code") { ApplicationArea = All; Visible = false; }
                field("Ship-to Contact"; Rec."Ship-to Contact") { ApplicationArea = All; Visible = false; }
                field("Purchaser Code"; Rec."Purchaser Code") { ApplicationArea = All; Visible = false; }
                field("Shortcut Dimension 1 Code"; Rec."Shortcut Dimension 1 Code") { ApplicationArea = All; Visible = false; }
                field("Shortcut Dimension 2 Code"; Rec."Shortcut Dimension 2 Code") { ApplicationArea = All; Visible = false; }
                field("Location Code"; Rec."Location Code") { ApplicationArea = All; Visible = false; }
                field("Total Albarán"; Total[1]) { ApplicationArea = All; }
                field("Total Pendiente2"; Total[2]) { ApplicationArea = All; Caption = 'Diferencia Facturado/Contabilizado'; }
                field("Total Pendiente"; Total[5]) { ApplicationArea = All; }
                field("Contabilizado"; Total[3])
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
                field(Facturado; Total[4])
                {
                    ApplicationArea = All;
                    // OnFormat=VAR
                    //             r122:Record "Purch. Inv. Header";
                    //             r123:Record 123;
                    //             r125:Record 125;
                    //             r25:Record 25;
                    //         BEGIN
                    //             r25.SETCURRENTKEY(r25."Document No.");
                    //             r25.SETRANGE(r25."Document No.","No.");
                    //             if r25.FINDFIRST THEN EXIT;

                    //             r123.SETCURRENTKEY(r123.Description);
                    //             //r123.SETRANGE(r123."Buy-from Vendor No.","Buy-from Vendor No.");
                    //             r123.SETFILTER(r123.Description,'%1','*'+"No."+'*');
                    //             if NOT r123.FINDFIRST THEN BEGIN
                    //             r125.SETCURRENTKEY(r125.Description);
                    //             r125.SETFILTER(r125.Description,'%1','*'+"No."+'*');
                    //             if NOT r125.FINDFIRST THEN CurrPage.Factu.UPDATEFORECOLOR(255);
                    //             EXIT;
                    //             END;
                    //             if NOT r122.GET(r123."Document No.") THEN
                    //             CurrPage.Factu.UPDATEFORECOLOR(255);
                    //         END;

                    trigger OnDrillDown()
                    VAR
                        r122: Record "Purch. Inv. Header";
                        r123: Record 123;
                    BEGIN
                        r123.SETCURRENTKEY(r123."Buy-from Vendor No.", r123.Description);
                        //r123.SETRANGE(r123."Buy-from Vendor No.","Buy-from Vendor No.");
                        r123.SETFILTER(r123.Description, '%1', '*' + Rec."No." + '*');
                        if r123.FINDFIRST THEN
                            REPEAT
                                r122.SETRANGE(r122."No.", r123."Document No.");
                                if r122.FINDFIRST THEN r122.MARK := TRUE;
                            UNTIL r123.NEXT = 0;
                        r122.SETRANGE(r122."No.");
                        r122.MARKEDONLY := TRUE;
                        Page.RUNMODAL(0, r122);
                    END;
                }

                field("Pendiente a Fecha"; Pdte) { ApplicationArea = All; }

                field(Contabi; Rec.Contabilizado) { ApplicationArea = All; Caption = 'Contabilizado'; }


                field(Factur; Rec.Facturado) { ApplicationArea = All; Caption = 'Facturado'; }

                field(Finalizado; Rec.Finalizado) { ApplicationArea = All; }

                field(Pasada1; Pasada) { ApplicationArea = All; Caption = 'Pasada Factura'; }

                field(Contrato1; Contrato) { ApplicationArea = All; }
                field(Vendedor; Rec.Vendedor) { ApplicationArea = All; }

                field(VtaAlb1; VtaAlb)
                {
                    ApplicationArea = All;
                    Caption = 'Venta/Albarán';
                    trigger OnDrillDown()
                    VAR
                        r112: Record 112;
                    BEGIN
                        r112.SETRANGE("Nº Proyecto", Rec."Nº Proyecto");
                        r112.SETRANGE(r112."Posting Date", Rec."Posting Date");
                        if r112.FINDFIRST THEN
                            Page.RUNMODAL(0, r112)
                        ELSE BEGIN
                            r112.SETRANGE(r112."Posting Date");
                            if r112.FINDFIRST THEN
                                Page.RUNMODAL(0, r112);

                        END;
                    END;
                }

                field(VtaTotal1; VtaTotal)
                {
                    ApplicationArea = All;
                    Caption = 'Vta Total';
                    trigger OnDrillDown()
                    VAR
                        rJob: Record 167;
                    BEGIN
                        rJob.SETRANGE("No.", Rec."Nº Proyecto");
                        if rJob.FINDFIRST THEN
                            Page.RUNMODAL(Page::"MLL-Presupuesto proyecto compr", rJob);
                    END;
                }




                field("No. Printed"; Rec."No. Printed") { ApplicationArea = All; }
            }
            group(Totales)
            {

                field(Total33; Total3(3)) { ApplicationArea = All; Caption = 'Total Albarán'; }
                field(Importe4; Importe4) { ApplicationArea = All; Caption = 'Total Pendiente'; }
            }

        }
    }
    actions
    {
        area(Processing)
        {
            group("Al&baranes")
            {
                action(Ficha)
                {
                    ApplicationArea = All;
                    Image = Card;
                    ShortCutKey = 'Mayús+F5';
                    Caption = 'Ficha';
                    RunObject = Page 136;
                    RunPageLink = "No." = FIELD("No.");
                }
                action("Estadísticas")
                {
                    ApplicationArea = All;
                    Image = Statistics;
                    ShortCutKey = F9;
                    Caption = 'Estadísticas';
                    RunObject = Page 399;
                    RunPageLink = "No." = FIELD("No.");
                }
                action("C&omentarios")
                {
                    ApplicationArea = All;
                    Image = Comment;

                    Caption = 'C&omentarios';
                    RunObject = Page 66;
                    RunPageLink = "Document Type" = CONST(Receipt),
                            "No." = FIELD("No.");
                }
                action("Recalcular Fechas")
                {
                    ApplicationArea = All;
                    Image = Calculate;
                    Caption = 'Recalcular Fechas';
                    trigger OnAction()
                    VAR
                        rAlb: Record "Purch. Rcpt. Header";
                        r17: Record "G/L Entry";
                    BEGIN
                        CurrPage.SETSELECTIONFILTER(rAlb);
                        if rAlb.FINDFIRST THEN
                            REPEAT
                                r17.SETCURRENTKEY(r17."G/L Account No.", r17."Posting Date");
                                r17.SETRANGE(r17."G/L Account No.", '400900001');
                                r17.SETRANGE(r17."Document No.", rAlb."No.");
                                if rAlb.FINDFIRST THEN BEGIN
                                    rAlb."Posting Date" := r17."Posting Date";
                                    rAlb.MODIFY;
                                END;
                            UNTIL rAlb.NEXT = 0;
                    END;
                }
                action("Cambia Proveedor")
                {
                    ApplicationArea = All;
                    Image = Vendor;
                    Caption = 'Cambia Proveedor';
                    trigger OnAction()
                    VAR
                        r17: Record "G/L Entry";
                        r23: Record Vendor;
                    BEGIN
                        if Page.RUNMODAL(0, r23) = ACTION::LookupOK THEN BEGIN
                            r17.SETCURRENTKEY(r17."Document No.");
                            r17.SETRANGE(r17."Document No.", Rec."No.");
                            if r17.FINDFIRST THEN
                                REPEAT
                                    r17."Source No." := r23."No.";
                                    r17.MODIFY;
                                UNTIL r17.NEXT = 0;
                            Rec."Pay-to Vendor No." := r23."No.";
                            Rec.MODIFY;
                        END;
                    END;
                }
                action("Quita Marca")
                {
                    ApplicationArea = All;
                    Image = UnApply;
                    Caption = 'Quita Marca';
                    trigger OnAction()
                    vaR
                        Utilidades: Codeunit Utilitis;
                    BEGIN
                        if Utilidades.PermisoAdm() THEN BEGIN
                            Rec."Reason Code" := '';
                            Rec.MODIFY;
                        END;
                    END;
                }
                action("Añadir Marca")
                {
                    ApplicationArea = All;
                    Image = Select;
                    Caption = 'Añadir Marca';
                    trigger OnAction()
                    var
                        Utilidades: Codeunit Utilitis;
                    BEGIN
                        if Utilidades.PermisoAdm() THEN BEGIN
                            Rec."Reason Code" := FORMAT(WORKDATE);
                            Rec.MODIFY;
                        END;
                    END;
                }
                action(Contabilizar)
                {
                    ApplicationArea = All;
                    Image = Register;
                    ShortCutKey = F11;
                    Caption = 'Contabilizar';
                    trigger OnAction()
                    VAR
                        C90: Codeunit ContabAlb;
                    BEGIN
                        if eFacturado <> 0 THEN ERROR('El albarán ya eata facturado');
                        CLEAR(C90);
                        C90.ContabilizarAlbaranes(Rec);
                    END;
                }
                action("Contabilizar Ptes.")
                {
                    ApplicationArea = All;
                    Image = Registered;
                    ShortCutKey = 'Mayús+F11';
                    Caption = 'Contabilizar Ptes.';
                    trigger OnAction()
                    VAR
                        r120: Record "Purch. Rcpt. Header";
                        c90: Codeunit ContabAlb;
                    BEGIN
                        r120.SETRANGE(r120.Contabilizado, FALSE);
                        if r120.FINDFIRST THEN
                            REPEAT
                                //if eFacturado<>0 THEN ERROR('El albarán ya eata facturado');
                                CLEAR(c90);
                                c90.ContabilizarAlbaranes(r120);
                            UNTIL r120.NEXT = 0;
                    END;
                }
                action("Albaranes Erróneos")
                {
                    ApplicationArea = All;
                    Image = ErrorLog;
                    Caption = 'Albaranes Erróneos';
                    trigger OnAction()
                    VAR
                        r120: Record "Purch. Rcpt. Header";
                    BEGIN
                        CurrPage.SETSELECTIONFILTER(r120);
                        if r120.FINDFIRST THEN
                            REPEAT
                                if r120.Contabilizado = TRUE THEN BEGIN
                                    if NOT Contab(r120."No.") THEN BEGIN
                                        Rec.GET(r120."No.");
                                        Rec.MARK := TRUE;
                                    END;
                                END;
                            UNTIL r120.NEXT = 0;
                        Rec.MARKEDONLY;
                    END;
                }
                action("Finalizar")
                {
                    ApplicationArea = All;
                    Image = Card;
                    Caption = 'Finalizar';
                    trigger OnAction()
                    BEGIN
                        if ABS(ABS(Total[3]) - ABS(Total[4])) > 0.24 THEN
                            ERROR('Ojo, el albarán tiene diferencias entre lo contabilizado y facturado');
                        Rec.Finalizado := NOT Rec.Finalizado;
                        Rec.MODIFY;
                    END;
                }
            }
        }
        area(Reporting)
        {
            action("&Imprimir")
            {
                ApplicationArea = All;
                Image = PrintDocument;
                trigger OnAction()
                BEGIN
                    CurrPage.SETSELECTIONFILTER(PurchRcptHeader);
                    PurchRcptHeader.PrintRecords(TRUE);
                END;
            }
            action("&Navegar")
            {
                ApplicationArea = All;
                Image = Navigate;
                trigger OnAction()
                BEGIN
                    Rec.Navigate;
                END;
            }
        }
    }
    VAR
        PurchRcptHeader: Record "Purch. Rcpt. Header";
        Calcular: Boolean;
        Total2: Decimal;
        eContabilizado: Decimal;
        eFacturado: Decimal;
        Total: ARRAY[5] OF Decimal;
        Importe: ARRAY[4] OF Decimal;
        Importe4: Decimal;

    PROCEDURE Total3(I: Integer): Decimal;
    VAR
        r121: Record "Purch. Rcpt. Line";
        Importe: Decimal;
        rAlb: Record "Purch. Rcpt. Header";
        Ventana: Dialog;
        a: Integer;
    BEGIN
        if NOT Calcular THEN EXIT(0);
        Importe4 := 0;
        rAlb.COPYFILTERS(Rec);
        Ventana.OPEN('Calculando ##########1##de###############2##');
        //CurrForm.SETSELECTIONFILTER(rAlb);
        Ventana.UPDATE(2, rAlb.COUNT);
        if rAlb.FINDFIRST THEN
            REPEAT
                a := a + 1;
                Ventana.UPDATE(1, a);
                r121.SETRANGE(r121."Document No.", rAlb."No.");
                if r121.FINDFIRST THEN
                    REPEAT
                        Importe := Importe + (r121.Quantity * r121."Direct Unit Cost" * (1 - r121."Line Discount %" / 100));
                        if Contab(rAlb."No.") THEN
                            Importe4 := Importe4 + ((r121.Quantity - r121."Quantity Invoiced")
                            * ROUND(r121."Direct Unit Cost" * (1 - r121."Line Discount %" / 100), 0.001, '='));

                    UNTIL r121.NEXT = 0;
            UNTIL rAlb.NEXT = 0;
        Calcular := FALSE;
        Ventana.CLOSE;
        EXIT(Importe);
    END;

    PROCEDURE Total4(): Decimal;
    VAR
        r121: Record "Purch. Rcpt. Line";
        Importe: Decimal;
        rAlb: Record "Purch. Rcpt. Header";
    BEGIN
        if NOT Calcular THEN EXIT(0);
        rAlb.COPYFILTERS(Rec);
        //CurrForm.SETSELECTIONFILTER(rAlb);
        if rAlb.FINDFIRST THEN
            REPEAT
                r121.SETRANGE(r121."Document No.", rAlb."No.");
                if r121.FINDFIRST THEN
                    REPEAT
                        if Contab(rAlb."No.") THEN
                            Importe := Importe + ((r121.Quantity - r121."Quantity Invoiced")
                            * r121."Direct Unit Cost" * (1 - r121."Line Discount %" / 100));
                    UNTIL r121.NEXT = 0;
            UNTIL rAlb.NEXT = 0;

        EXIT(Importe);
    END;

    PROCEDURE eDescont(): Decimal;
    VAR
        r121: Record "Purch. Rcpt. Line";
        Importe: Decimal;
        r17: Record "G/L Entry";
        r123: Record 123;
        r122: Record "Purch. Inv. Header";
    BEGIN
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
        r25: Record 25;
    BEGIN
        r25.SETCURRENTKEY(r25."Document No.");
        r25.SETRANGE(r25."Document No.", Rec."No.");
        if r25.FINDFIRST THEN EXIT(TRUE);
        r123.SETCURRENTKEY(r123.Description);
        //r123.SETRANGE(r123."Buy-from Vendor No.","Buy-from Vendor No.");
        r123.SETFILTER(r123.Description, '%1', '*' + Rec."No." + '*');
        if NOT r123.FINDFIRST THEN BEGIN
            r125.SETCURRENTKEY(r125.Description);
            r125.SETFILTER(r125.Description, '%1', '*' + Rec."No." + '*');
            if NOT r125.FINDFIRST THEN EXIT(FALSE);
            EXIT(TRUE);
        END;
        if NOT r122.GET(r123."Document No.") THEN
            EXIT(FALSE);
        EXIT(TRUE);
    END;

    PROCEDURE Contab(Num: Code[20]): Boolean;
    VAR
        Imp: Decimal;
        r17: Record "G/L Entry";
    BEGIN
        r17.SETCURRENTKEY(r17."Document No.");
        r17.SETRANGE(r17."Document No.", Num);
        if r17.FINDFIRST THEN
            REPEAT
                if COPYSTR(r17."G/L Account No.", 1, 1) = '6' THEN Imp := Imp + r17.Amount;
                if COPYSTR(r17."G/L Account No.", 1, 2) = '47' THEN Imp := Imp + r17.Amount;
            UNTIL r17.NEXT = 0;
        if Imp = 0 THEN EXIT(FALSE);
        EXIT(TRUE);
    END;

    PROCEDURE Pdte(): Decimal;
    VAR
        r17: Record "G/L Entry";
        T: Decimal;
    BEGIN
        Rec.COPYFILTER("Posting Date", r17."Posting Date");
        r17.SETCURRENTKEY(r17."G/L Account No.", r17."Document No.");
        r17.SETRANGE(r17."Document No.", Rec."No.");
        r17.SETRANGE("G/L Account No.", '4009', '40099');
        if r17.FINDFIRST THEN r17.CALCSUMS(r17.Amount);
        T := T + r17.Amount;
        r17.SETRANGE("G/L Account No.", '4109', '41099');
        if r17.FINDFIRST THEN BEGIN
            r17.CALCSUMS(r17.Amount);
            T := T + r17.Amount;
        END;
        r17.SETCURRENTKEY(r17."G/L Account No.", r17."Document No.");
        r17.SETRANGE(r17."Document No.");
        r17.SETRANGE("Tax Area Code", Rec."No.");
        r17.SETRANGE("G/L Account No.", '4009', '40099');
        if r17.FINDFIRST THEN r17.CALCSUMS(r17.Amount);
        T := T + r17.Amount;
        r17.SETRANGE("G/L Account No.", '4109', '41099');
        if r17.FINDFIRST THEN BEGIN
            r17.CALCSUMS(r17.Amount);
            T := T + r17.Amount;
        END;
        EXIT(T);
    END;

    PROCEDURE Contrato(): Text[30];
    VAR
        r36: Record 36;
    BEGIN
        r36.SETCURRENTKEY(r36."Nº Proyecto");
        r36.SETRANGE(r36."Document Type", r36."Document Type"::Order);
        r36.SETRANGE(r36."Nº Proyecto", Rec."Nº Proyecto");
        if r36.FINDFIRST THEN EXIT(r36."No.");
    END;

    PROCEDURE VtaAlb(): Decimal;
    VAR
        rLin: Record 113;
        r121: Record 39;
        d: Decimal;
    BEGIN
        rLin.SETRANGE(rLin."Job No.", Rec."Nº Proyecto");
        r121.SETRANGE(r121."Document Type", r121."Document Type"::Order);
        r121.SETRANGE(r121."Document No.", Rec."Order No.");
        if r121.FINDFIRST THEN
            REPEAT
                rLin.SETRANGE(rLin."Line No.", r121."Linea de proyecto");
                if rLin.FINDFIRST THEN
                    d := d + rLin."Line Amount";
            UNTIL r121.NEXT = 0;
        EXIT(d);
    END;

    PROCEDURE VtaTotal(): Decimal;
    BEGIN
        EXIT(TotalesDocumentos(Rec."Nº Proyecto", Contrato));
    END;

    PROCEDURE TotalesDocumentos(wNumProyecto: Code[20]; wNum: Code[20]): Decimal;
    VAR
        TempSalesLine: Record 37 TEMPORARY;
        rCabVenta: Record 36;
        ImpBorFac: Decimal;
        ImpBorAbo: Decimal;
        ImpAbo: Decimal;
        ImpFac: Decimal;
        TotImp: Decimal;
        TotCont: Decimal;
        TotalSalesLine: Record 37;
        TotalSalesLineLCY: Record 37;
        rCabFac: Record 112;
        rCabAbo: Record 114;
        RegisVtas: Codeunit 80;
        wDecimal: Decimal;
        wTexto: Text[30];
        r36: Record 36;
    BEGIN
        //$002 Obtengo totales de borradores y facturas correspondientes a este contrato.

        ImpBorFac := 0;
        ImpBorAbo := 0;
        ImpFac := 0;
        ImpAbo := 0;
        TotImp := 0;
        TotCont := 0;
        if NOT r36.GET(r36."Document Type"::Order, wNum) THEN EXIT(0);
        WITH r36 DO BEGIN
            CALCFIELDS("Borradores de Factura", "Borradores de Abono",
                       "Facturas Registradas", "Abonos Registrados");

            if ("Borradores de Factura" <> 0) OR ("Borradores de Abono" <> 0) THEN BEGIN

                rCabVenta.RESET;
                rCabVenta.SETCURRENTKEY("Nº Proyecto");
                rCabVenta.SETRANGE("Nº Proyecto", wNumProyecto);
                rCabVenta.SETRANGE("Nº Contrato", wNum);
                rCabVenta.SETFILTER("Document Type", '%1|%2',
                   rCabVenta."Document Type"::Invoice, rCabVenta."Document Type"::"Credit Memo");
                if rCabVenta.FIND('-') THEN BEGIN
                    REPEAT
                        CLEAR(TotalSalesLine);
                        CLEAR(TotalSalesLineLCY);
                        CLEAR(RegisVtas);
                        CLEAR(TempSalesLine);
                        RegisVtas.GetSalesLines(rCabVenta, TempSalesLine, 0);
                        CLEAR(RegisVtas);
                        RegisVtas.SumSalesLinesTemp(
                          rCabVenta, TempSalesLine, 0, TotalSalesLine, TotalSalesLineLCY,
                          wDecimal, wTexto, wDecimal, wDecimal, wDecimal);
                        if rCabVenta."Document Type" = rCabVenta."Document Type"::Invoice THEN BEGIN
                            ImpBorFac := ImpBorFac + TotalSalesLineLCY.Amount;
                        END
                        ELSE BEGIN
                            ImpBorAbo := ImpBorAbo + TotalSalesLineLCY.Amount;
                        END;
                    UNTIL rCabVenta.NEXT = 0;
                END;

            END;

            if "Facturas Registradas" <> 0 THEN BEGIN

                rCabFac.RESET;
                rCabFac.SETCURRENTKEY("Nº Proyecto", "Nº Contrato");
                rCabFac.SETRANGE("Nº Contrato", wNum);
                if rCabFac.FIND('-') THEN BEGIN
                    REPEAT
                        rCabFac.CALCFIELDS("Amount Including VAT", Amount);
                        ImpFac := ImpFac + rCabFac.Amount;
                    UNTIL rCabFac.NEXT = 0;
                END;

            END;

            if "Abonos Registrados" <> 0 THEN BEGIN

                rCabAbo.RESET;
                rCabAbo.SETCURRENTKEY("Nº Proyecto", "Nº Contrato");
                rCabAbo.SETRANGE("Nº Contrato", wNum);
                if rCabAbo.FIND('-') THEN BEGIN
                    REPEAT
                        rCabAbo.CALCFIELDS("Amount Including VAT", Amount);
                        ImpAbo := ImpAbo + rCabAbo.Amount;
                    UNTIL rCabAbo.NEXT = 0;
                END;

            END;

            //FCL-13/02/06. Incluyo sumatorio de totales y diferencia con el total del contrato.
            TotImp := ImpBorFac - ImpBorAbo + ImpFac - ImpAbo;
            EXIT(TotImp);
            if rCabVenta.GET(rCabVenta."Document Type"::Order, wNum) THEN BEGIN
                CLEAR(TotalSalesLine);
                CLEAR(TotalSalesLineLCY);
                CLEAR(RegisVtas);
                CLEAR(TempSalesLine);
                RegisVtas.GetSalesLines(rCabVenta, TempSalesLine, 0);
                CLEAR(RegisVtas);
                RegisVtas.SumSalesLinesTemp(rCabVenta, TempSalesLine, 0, TotalSalesLine, TotalSalesLineLCY,
                                            wDecimal, wTexto, wDecimal, wDecimal, wDecimal);
                TotCont := TotalSalesLineLCY.Amount;
            END;
        END;
    END;

    trigger OnAfterGetRecord()
    VAR
        r121: Record "Purch. Rcpt. Line";
        r17: Record "G/L Entry";
    BEGIN
        CLEAR(Total);
        CLEAR(eContabilizado);
        CLEAR(eFacturado);
        Total2 := 0;
        r121.SETRANGE(r121."Document No.", Rec."No.");
        if r121.FINDFIRST THEN
            REPEAT
                Total[1] := Total[1] + (r121.Quantity * r121."Direct Unit Cost" * (1 - r121."Line Discount %" / 100));
                Total2 := Total2 + ((r121.Quantity - r121."Quantity Invoiced")
                * r121."Direct Unit Cost" * (1 - r121."Line Discount %" / 100));
                eFacturado := eFacturado + r121."Quantity Invoiced" * r121."Direct Unit Cost"
                * (1 - r121."Line Discount %" / 100);
            UNTIL r121.NEXT = 0;
        if NOT Pasada THEN
            eFacturado := 0;
        r17.SETCURRENTKEY(r17."G/L Account No.", r17."Document No.");
        r17.SETRANGE(r17."Document No.", Rec."No.");
        r17.SETRANGE("G/L Account No.", '6', '7');
        if r17.FINDFIRST THEN r17.CALCSUMS(r17.Amount);
        eContabilizado := eContabilizado + r17.Amount;
        r17.SETRANGE("G/L Account No.", '47', '48');
        if r17.FINDFIRST THEN BEGIN
            r17.CALCSUMS(r17.Amount);
            eContabilizado := eContabilizado + r17.Amount;
        END;
        //    {
        //     if COPYSTR(r17."G/L Account No.",1,1)='6' THEN eContabilizado:=eContabilizado+r17.Amount;
        //     if COPYSTR(r17."G/L Account No.",1,2)='47' THEN eContabilizado:=eContabilizado+r17.Amount;
        //    UNTIL r17.NEXT=0;}
        if eContabilizado = 0 THEN Total2 := 0;
        if (eContabilizado < Total2) AND (Total2 <> 0) THEN Total2 := eContabilizado;
        if Rec.Contabilizado = FALSE THEN Total2 := 0;
        Total[2] := Total2;
        Total[3] := eContabilizado;
        Total[4] := eFacturado;
        Total[5] := Total[2];
        if Rec.Finalizado THEN Total[2] := 0;
    END;
}