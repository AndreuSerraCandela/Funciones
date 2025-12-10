/// <summary>
/// PageExtension PosrtedSalesInvioce (ID 80131) extends Record Posted Sales Invoices.
/// </summary>
pageextension 80131 PosrtedSalesInvioce extends "Posted Sales Invoices"
{
    layout
    {
        modify("No.")
        {
            StyleExpr = Color;
        }
        addbefore("Sell-to Customer No.")
        {
            field("Customer Order No."; Rec."Customer Order No.")
            {
                ApplicationArea = All;
                Visible = true;
            }
            field("Posting Description"; Rec."Posting Description")
            {
                ApplicationArea = All;
            }
            field("Document Sending Profile"; Rec."Document Sending Profile")
            {
                ApplicationArea = All;
            }
            field("Cod cadena"; Rec."Cod cadena")
            {
                ApplicationArea = All;
            }
            field("Payment Method Code"; Rec."Payment Method Code")
            {
                ApplicationArea = All;
            }
            field("Nº Contrato"; Rec."Nº Contrato")
            {
                ApplicationArea = All;
            }
        }
        addafter("Salesperson Code")
        {
            field("Vendedor Origen"; Rec."Vendedor Origen")
            {
                ApplicationArea = All;
            }
        }
        modify("Order No.")
        {
            Visible = true;


        }

    }
    actions
    {
        addafter("&Invoice")
        {
            group(Face)
            {
                action("Facturas Pendientes")
                {
                    Image = UseFilters;
                    ApplicationArea = All;
                    trigger OnAction()
                    begin
                        Rec.SetRange("Situación Efactura", Rec."Situación Efactura"::Pendiente);
                        CurrPage.Update(False);

                    end;
                }
                action("Marcar como Pendientes")
                {
                    Image = Open;
                    ApplicationArea = All;
                    trigger OnAction()
                    var
                        ControlProcesos: Codeunit ControlProcesos;
                    begin
                        ControlProcesos.MarcarComoPendienteEfactura(Rec);
                        CurrPage.Update(False);

                    end;
                }
                // action("Enviar Seleccionadas")
                // {
                //     Image = SendElectronicDocument;
                //     ApplicationArea = All;
                //     trigger OnAction()
                //     var
                //         Envios: Record 112;
                //         Face: Report "Generacion Facturae";
                //     begin
                //         CurrPage.SetSelectionFilter(Envios);
                //         Face.SetTableView(Envios);
                //         Face.RunModal();

                //     end;
                // }
                action("Cambiar Dirección Envio")
                {
                    Image = ShipAddress;
                    ApplicationArea = All;
                    trigger OnAction()
                    var
                        Envios: Record 222;
                        Control: Codeunit ControlProcesos;

                    begin
                        Envios.SetRange("Customer No.", Rec."Sell-to Customer No.");
                        if Page.RunModal(0, Envios) in [Action::LookupOK, Action::OK]
                        Then
                            Control.CambiaDireccionEnvio(Rec, Envios);


                    end;
                }
            }
            group(Contabilizar)
            {
                action("Contabilizar (Negro)")
                {
                    ApplicationArea = All;
                    Image = Register;
                    ShortCutKey = F11;

                    trigger OnAction()
                    Var
                        rLin: Record 39;
                        rLin2: Record 39;
                        PurchRecpLine: Record "Purch. Rcpt. Line";
                        QtyToInv: Decimal;
                        Q: Decimal;
                        QtyInvo: Decimal;
                        c74: Codeunit "Procedures Standard";
                        PurchRecpLine2: Record "Purch. Rcpt. Line";
                        rLinVta: Record 113;
                        PurchLine: Record 39;
                        TempPurchLine: Record 39 TEMPORARY;
                        rLinVtaF: Record 113;
                        AmountIncl: Decimal;
                        pAmount: Decimal;
                        PurchRcptHeader: Record "Purch. Rcpt. Header";
                    BEGIN
                        if NOT EsotraEmpresa THEN EXIT;
                        if Rec."Albarán Empresa Origen" <> '' THEN ERROR('Esta factura tiene Albarán');
                        rPed.GET(rPed."Document Type"::Order, Rec."Customer Order No.");
                        rLinVta.CHANGECOMPANY(wEmpresa);
                        rLinVta.SETRANGE(rLinVta."Document No.", Rec."No.");
                        if rLinVta.FINDFIRST THEN
                            REPEAT
                                rLin2.SETRANGE(rLin2."Document Type", rPed."Document Type");
                                rLin2.SETRANGE(rLin2."Document No.", rPed."No.");
                                rLin2.SETRANGE(rLin2."Linea de proyecto", rLinVta."No linea proyecto");
                                rLin2.SETFILTER(rLin2.Type, '<>%1', 0);
                                if rLin2.FINDFIRST THEN
                                    REPEAT
                                        if rLin2."Qty. to Invoice" <> 0 THEN
                                            rLin2.VALIDATE("Qty. to Invoice", rLinVta.Quantity);
                                        if rLinVta.Type = rLinVta.Type::Resource THEN BEGIN
                                            rLin2."Fecha inicial recurso" := rLinVta."Fecha inicial recurso";
                                            rLin2."Fecha final recurso" := rLinVta."Fecha final recurso";
                                            rLin2.Recurso := rLinVta."No.";
                                        END;
                                        rLin2."Empresa Origen" := wEmpresa;
                                        rLin2."Proyecto Origen" := rLinVta."Job No.";
                                        rLin2.MODIFY;
                                    UNTIL rLin2.NEXT = 0;
                            UNTIL rLinVta.NEXT = 0;
                        WITH rPed DO BEGIN
                            rCab := rPed;
                            rCab."Document Type" := rCab."Document Type"::Invoice;
                            rCab."No." := '';
                            rCab."Posting Date" := WORKDATE;
                            rCab."Empresa Factura" := wEmpresa;
                            rCab."Document Date" := Rec."Posting Date";
                            if Rec."Posting Date" > WORKDATE THEN
                                rCab."Posting Date" := Rec."Posting Date";

                            rCab."Vendor Invoice No." := rLinVta."Document No.";
                            rCab.Status := rCab.Status::Open;
                            rCab.INSERT(TRUE);
                            rCab.VALIDATE("Document Date", Rec."Posting Date");
                            rCab."Posting Description" := FORMAT(rCab."Document Type") + ' ' + rCab."Vendor Invoice No.";
                            rCab.MODIFY;
                            rLin.SETRANGE(rLin."Document Type", rLin."Document Type"::Invoice);
                            rLin.SETRANGE(rLin."Document No.", rCab."No.");
                            rLin2.RESET;
                            rLin2.SETRANGE(rLin2."Document Type", "Document Type");
                            rLin2.SETRANGE(rLin2."Document No.", "No.");
                            if rLin2.FINDFIRST THEN
                                REPEAT

                                    PurchRecpLine.RESET;
                                    PurchRecpLine.SETCURRENTKEY("Order No.", "Order Line No.");
                                    PurchRecpLine.SETRANGE(PurchRecpLine."Order No.", "No.");
                                    PurchRecpLine.SETRANGE(PurchRecpLine."Order Line No.", rLin2."Line No.");
                                    QtyToInv := 0;
                                    QtyInvo := 0;
                                    if PurchRecpLine.FINDFIRST THEN
                                        REPEAT
                                            if QtyToInv <= rLin2."Qty. to Invoice" THEN BEGIN
                                                QtyToInv := QtyToInv + PurchRecpLine."Qty. Rcd. Not Invoiced";
                                                if QtyToInv > rLin2."Qty. to Invoice" THEN
                                                    Q := rLin2."Qty. to Invoice" - QtyInvo
                                                ELSE
                                                    Q := PurchRecpLine."Qty. Rcd. Not Invoiced";
                                                //Inserta Linea Albarán
                                                QtyInvo := QtyInvo + Q;
                                                CLEAR(c74);
                                                //c74.SetPurchHeader(rCab);
                                                PurchRecpLine2.RESET;
                                                PurchRecpLine2.SETRANGE(PurchRecpLine2."Document No.", PurchRecpLine."Document No.");
                                                PurchRecpLine2.SETRANGE(PurchRecpLine2."Line No.", PurchRecpLine."Line No.");
                                                PurchRecpLine2.SETRANGE(PurchRecpLine2."Order No.", "No.");
                                                PurchRecpLine2.SETRANGE(PurchRecpLine2."Order Line No.", rLin2."Line No.");
                                                if PurchRecpLine2.FindFirst() Then begin
                                                    PurchRcptHeader.Get(PurchRecpLine."Document No.");
                                                    q := Round(q, 00000.1, '=');
                                                    if Q <> 0 THEN
                                                        c74.CreateInvoiceLines2(PurchRecpLine2, Q, rCab, PurchRcptHeader);
                                                end;
                                            END;
                                        UNTIL PurchRecpLine.NEXT = 0;
                                UNTIL rLin2.NEXT = 0;
                        END;
                        Rec."Pte Contabilicación" := FALSE;
                        Rec.MODIFY;
                        COMMIT;
                        CLEAR(PurchLine);
                        CLEAR(TotalPurchLine);
                        CLEAR(TotalPurchLineLCY);
                        CLEAR(PurchPost);

                        PurchPost.GetPurchLines(rCab, TempPurchLine, 0);
                        CLEAR(PurchPost);
                        PurchPost.SumPurchLinesTemp(
                        rCab, TempPurchLine, 0, TotalPurchLine, TotalPurchLineLCY, VATAmount, VATAmountText);

                        if rCab."Prices Including VAT" THEN BEGIN
                            TotalAmount2 := TotalPurchLine.Amount;
                            TotalAmount1 := TotalAmount2 + VATAmount;
                            TotalPurchLine."Line Amount" := TotalAmount1 + TotalPurchLine."Inv. Discount Amount"
                                + TotalPurchLine."Pmt. Discount Amount";
                        END ELSE BEGIN
                            TotalAmount1 := TotalPurchLine.Amount;
                            TotalAmount2 := TotalPurchLine."Amount Including VAT";
                        END;

                        if Vend.GET(rCab."Pay-to Vendor No.") THEN
                            Vend.CALCFIELDS("Balance (LCY)")
                        ELSE
                            CLEAR(Vend);

                        PurchLine.CalcVATAmountLines(0, rCab, TempPurchLine, TempVATAmountLine);
                        TempVATAmountLine.MODIFYALL(Modified, FALSE);
                        rLinVtaF.CHANGECOMPANY(wEmpresa);
                        rLinVtaF.SETRANGE(rLinVtaF."Document No.", Rec."No.");
                        AmountIncl := 0;
                        pAmount := 0;
                        if rLinVtaF.FINDFIRST THEN
                            REPEAT
                                AmountIncl := AmountIncl + rLinVtaF."Amount Including VAT";
                                pAmount := pAmount + rLinVtaF.Amount;
                            UNTIL rLinVtaF.NEXT = 0;
                        if TotalAmount2 <> AmountIncl THEN BEGIN
                            if ABS(TotalAmount2 - AmountIncl) < 5 THEN
                                UpdateTotalAmount(pAmount);
                        END;
                        COMMIT;
                        PAGE.RUNMODAL(51, rCab);
                    END;
                }
                action("Contabilizar desde albarán (Verde)")
                {
                    ShortCutKey = 'Mayús+F11';
                    ApplicationArea = All;
                    Image = Register;
                    Caption = 'Contabilizar desde albarán (Verde)';
                    trigger OnAction()
                    Var
                        rLin: Record 39;
                        rLin2: Record 39;
                        PurchRecpLine: Record "Purch. Rcpt. Line";
                        QtyToInv: Decimal;
                        Q: Decimal;
                        QtyInvo: Decimal;
                        c74: Codeunit "Procedures Standard";
                        PurchRecpLine2: Record "Purch. Rcpt. Line";
                        rLinVta: Record 113;
                        PurchLine: Record 39;
                        TempPurchLine: Record 39 TEMPORARY;
                        rLinVtaF: Record 113;
                        AmountIncl: Decimal;
                        pAmount: Decimal;
                        rAlb: Record "Purch. Rcpt. Header";
                        rLinA: Record "Purch. Rcpt. Line";
                        PurchRcptHeader: Record "Purch. Rcpt. Header";
                    BEGIN
                        rAlb.GET(Rec."Albarán Empresa Origen");
                        rPed.GET(rPed."Document Type"::Order, rAlb."Order No.");
                        rLinA.SETRANGE("Document No.", rAlb."No.");
                        rLinA.SETFILTER(rLinA.Type, '<>%1', 0);
                        rLinA.FINDFIRST;
                        if rLinA.FINDFIRST THEN
                            REPEAT
                                rLin2.SETRANGE(rLin2."Document Type", rPed."Document Type");
                                rLin2.SETRANGE(rLin2."Document No.", rPed."No.");
                                rLin2.SETRANGE(rLin2."Line No.", rLinA."Order Line No.");
                                rLin2.SETFILTER(rLin2.Type, '<>%1', 0);
                                rLin2.FINDFIRST;
                                if rLin2.FINDFIRST THEN
                                    REPEAT
                                        rLin2.VALIDATE("Qty. to Invoice", rLinA.Quantity);
                                        rLin2.MODIFY;
                                    UNTIL rLin2.NEXT = 0;
                            UNTIL rLinA.NEXT = 0;
                        WITH rPed DO BEGIN
                            rCab := rPed;
                            rCab."Document Type" := rCab."Document Type"::Invoice;
                            rCab."No." := '';
                            rCab."Posting Date" := WORKDATE;
                            rCab."Empresa Factura" := wEmpresa;
                            rCab."Document Date" := Rec."Posting Date";
                            if Rec."Posting Date" > WORKDATE THEN
                                rCab."Posting Date" := Rec."Posting Date";
                            rCab."Vendor Invoice No." := Rec."No.";
                            rCab.Status := rCab.Status::Open;
                            rCab.INSERT(TRUE);
                            rCab.VALIDATE("Document Date", Rec."Posting Date");
                            rCab."Posting Description" := FORMAT(rCab."Document Type") + ' ' + rCab."Vendor Invoice No.";

                            rCab.MODIFY;
                            rLin.SETRANGE(rLin."Document Type", rLin."Document Type"::Invoice);
                            rLin.SETRANGE(rLin."Document No.", rCab."No.");
                            rLin2.RESET;
                            rLin2.SETRANGE(rLin2."Document Type", "Document Type");
                            rLin2.SETRANGE(rLin2."Document No.", "No.");
                            //if rLin2.FINDFIRST THEN REPEAT

                            PurchRecpLine.RESET;
                            PurchRecpLine.SETRANGE("Document No.", rAlb."No.");
                            //PurchRecpLine.SETRANGE("Line No.",rAlb."Line No.");
                            QtyToInv := 0;
                            QtyInvo := 0;
                            PurchRecpLine.FINDFIRST;
                            if PurchRecpLine.FINDFIRST THEN
                                REPEAT
                                    // {if QtyToInv<=PurchRecpLine."Qty. to Invoice" THEN BEGIN
                                    //     QtyToInv:=QtyToInv+PurchRecpLine."Qty. Rcd. Not Invoiced";
                                    //     if QtyToInv>PurchRecpLine."Qty. to Invoice" THEN
                                    //     Q:=rLin2."Qty. to Invoice"-QtyInvo
                                    //     ELSE }
                                    Q := Round(PurchRecpLine."Qty. Rcd. Not Invoiced", 0.0001, '=');
                                    //Inserta Linea Albarán
                                    //QtyInvo:=QtyInvo+Q;
                                    CLEAR(c74);
                                    PurchRecpLine2.RESET;
                                    PurchRecpLine2.SETRANGE(PurchRecpLine2."Document No.", PurchRecpLine."Document No.");
                                    PurchRecpLine2.SETRANGE(PurchRecpLine2."Line No.", PurchRecpLine."Line No.");
                                    PurchRcptHeader.Get(PurchRecpLine."Document No.");
                                    if PurchRecpLine2.FindFirst() Then begin
                                        if Q <> 0 THEN
                                            c74.CreateInvoiceLines2(PurchRecpLine2, Q, rCab, PurchRcptHeader);
                                    End;
                                //END;
                                UNTIL PurchRecpLine.NEXT = 0;
                            //UNTIL rLin2.NEXT=0;
                        END;
                        Rec."Pte Contabilicación" := FALSE;
                        Rec.MODIFY;
                        COMMIT;
                        CLEAR(PurchLine);
                        CLEAR(TotalPurchLine);
                        CLEAR(TotalPurchLineLCY);
                        CLEAR(PurchPost);

                        PurchPost.GetPurchLines(rCab, TempPurchLine, 0);
                        CLEAR(PurchPost);
                        PurchPost.SumPurchLinesTemp(
                        rCab, TempPurchLine, 0, TotalPurchLine, TotalPurchLineLCY, VATAmount, VATAmountText);

                        if rCab."Prices Including VAT" THEN BEGIN
                            TotalAmount2 := TotalPurchLine.Amount;
                            TotalAmount1 := TotalAmount2 + VATAmount;
                            TotalPurchLine."Line Amount" := TotalAmount1 + TotalPurchLine."Inv. Discount Amount"
                                + TotalPurchLine."Pmt. Discount Amount";
                        END ELSE BEGIN
                            TotalAmount1 := TotalPurchLine.Amount;
                            TotalAmount2 := TotalPurchLine."Amount Including VAT";
                        END;

                        if Vend.GET(rCab."Pay-to Vendor No.") THEN
                            Vend.CALCFIELDS("Balance (LCY)")
                        ELSE
                            CLEAR(Vend);

                        PurchLine.CalcVATAmountLines(0, rCab, TempPurchLine, TempVATAmountLine);
                        TempVATAmountLine.MODIFYALL(Modified, FALSE);
                        rLinVtaF.CHANGECOMPANY(wEmpresa);
                        rLinVtaF.SETRANGE(rLinVtaF."Document No.", Rec."No.");
                        AmountIncl := 0;
                        pAmount := 0;
                        if rLinVtaF.FINDFIRST THEN
                            REPEAT
                                AmountIncl := AmountIncl + rLinVtaF."Amount Including VAT";
                                pAmount := pAmount + rLinVtaF.Amount;
                            UNTIL rLinVtaF.NEXT = 0;
                        if TotalAmount2 <> AmountIncl THEN BEGIN
                            if ABS(TotalAmount2 - AmountIncl) < 5 THEN
                                UpdateTotalAmount(pAmount);
                        END;
                        COMMIT;
                        Page.RUNMODAL(51, rCab);
                    END;
                }
                action("Contabilizar Activos (Amarillo)")
                {
                    ShortCutKey = 'Ctrl+F11';
                    ApplicationArea = All;
                    Image = Register;
                    Caption = 'Contabilizar Activos (Amarillo)';
                    trigger OnAction()
                    Var
                        r38: Record 38;
                        r120: Record "Purch. Rcpt. Header";
                    BEGIN
                        if Activo(Rec."Albarán Empresa Origen") THEN BEGIN
                            Rec."Pte Contabilicación" := FALSE;
                            Rec.MODIFY;
                            COMMIT;
                            r120.GET(Rec."Albarán Empresa Origen");
                            r38.GET(r38."Document Type"::Order, r120."Order No.");
                            r38."Vendor Invoice No." := Rec."No.";
                            r38."Empresa Factura" := wEmpresa;
                            r38.MODIFY;
                            COMMIT;
                            PAGE.RUNMODAL(50, r38);
                        END;
                    END;
                }
                action("Facturas Empresa")
                {
                    ApplicationArea = All;
                    Image = Company;
                    Caption = 'Facturas Empresa';
                    trigger OnAction()
                    Var
                        rEmp: Record Company;
                        rIc: Record 413;
                        rCust: Record Customer;
                        rInf: Record "IC Setup";
                    BEGIN
                        if Page.RUNMODAL(Page::Companies, rEmp) = ACTION::LookupOK THEN
                            Empresa(rEmp.Name, FALSE, FALSE);
                        if EsotraEmpresa THEN BEGIN
                            rInf.GET;
                            rIc.GET(rInf."IC Partner Code");
                            rCust.CHANGECOMPANY(wEmpresa);
                            rCust.SETRANGE(rCust."IC Partner Code", rIc.Code);
                            rCust.FINDFIRST;
                            Rec.SETRANGE("Sell-to Customer No.", rCust."No.");
                            Rec.SETRANGE("Pte Contabilicación", TRUE);
                        END;
                    END;
                }
                action(Desmarcar)
                {
                    ApplicationArea = All;
                    Image = Undo;
                    Visible = true;
                    Caption = 'Desmarcar';
                    trigger OnAction()
                    var
                        Control: Codeunit ControlProcesos;
                        SalesInv: Record "Sales Invoice Header";
                    BEGIN
                        CurrPage.SetSelectionFilter(SalesInv);
                        Control.DesmarcarcomoContabilizada(SalesInv);
                    END;
                }
                action("Asignar Pedido (Rojo)")
                {
                    ApplicationArea = All;
                    Image = Order;
                    Caption = 'Asignar Pedido (Rojo)';
                    trigger OnAction()
                    Var
                        rCabPed: Record 38;
                        rIc: Record 413;
                        rInf: Record 79;
                        rVend: Record Vendor;
                        rJob: Record 167;
                        rContr: Record 36;
                        r112: Record 112;
                        r114: Record 114;
                    BEGIN
                        if Rec."Albarán Empresa Origen" <> '' THEN ERROR('Esta factura tiene albarán');
                        rIc.SETRANGE(rIc."Inbox Details", wEmpresa);
                        rIc.FINDFIRST;
                        rVend.SETRANGE(rVend."IC Partner Code", rIc.Code);
                        rVend.FINDFIRST;
                        rCabPed.SETRANGE("Document Type", rCabPed."Document Type"::Order);
                        rCabPed.SETRANGE("Buy-from Vendor No.", rVend."No.");
                        rCabPed.SETRANGE(rCabPed."Posting Date", CALCDATE('-9M', Rec."Posting Date"), 99991231D);
                        if Page.RUNMODAL(0, rCabPed) = ACTION::LookupOK THEN BEGIN
                            Rec."Customer Order No." := rCabPed."No.";
                            Rec.MODIFY;
                            if Rec."Nº Proyecto" <> 'PR99-99999' THEN BEGIN
                                rJob.CHANGECOMPANY(wEmpresa);
                                if rJob.GET(Rec."Nº Proyecto") THEN BEGIN
                                    rContr.CHANGECOMPANY(wEmpresa);
                                    rContr.SETCURRENTKEY(rContr."Nº Proyecto");
                                    rContr.SETRANGE(rContr."Nº Proyecto", rJob."No.");
                                    if rContr.FINDFIRST THEN
                                        REPEAT
                                            rContr."Customer Order No." := rCabPed."No.";
                                            rContr.MODIFY;
                                        UNTIL rContr.NEXT = 0;
                                    r112.CHANGECOMPANY(rIc."Inbox Details");
                                    r112.SETCURRENTKEY("Nº Proyecto");
                                    r112.SETRANGE("Nº Proyecto", rJob."No.");
                                    if r112.FINDFIRST THEN
                                        REPEAT
                                            if Rec."No." <> r112."No." THEN BEGIN
                                                r112."Order No." := rCabPed."No.";
                                                r112.MODIFY;
                                            END;
                                        UNTIL r112.NEXT = 0;
                                    r114.CHANGECOMPANY(rIc."Inbox Details");
                                    r114.SETCURRENTKEY("Nº Proyecto");
                                    r114.SETRANGE("Nº Proyecto", rJob."No.");
                                    if r114.FINDFIRST THEN
                                        REPEAT
                                            r114."Customer Order No." := rCabPed."No.";
                                            r114.MODIFY;
                                        UNTIL r114.NEXT = 0;
                                END;
                            END;

                        END;
                    END;
                }
                action("Desasignar Pedido")
                {
                    ApplicationArea = All;
                    Image = UnApply;
                    Caption = 'Desasignar Pedido';
                    trigger OnAction()
                    BEGIN
                        //  if ("Albarán Empresa Origen"<>'') AND (COPYSTR("Customer Order No.",1,2)<>'DC') THEN ERROR('Esta factura tiene Albarán');
                        if (COPYSTR(Rec."Albarán Empresa Origen", 1, 2) = 'DC') THEN
                            Rec."Albarán Empresa Origen" := '';
                        Rec."Customer Order No." := '';
                        Rec.MODIFY;
                    END;
                }
                action("Marcar Como Contabilizada")
                {
                    ApplicationArea = All;
                    Image = AddWatch;
                    Caption = 'Marcar Como Contabilizada';
                    trigger OnAction()
                    var
                        C: Codeunit ControlProcesos;
                    BEGIN
                        c.MarcarFacturaComoContabilizada(Rec, False);

                    END;
                }
                action("Desmarcar Como Contabilizada")
                {
                    ApplicationArea = All;
                    Image = UnApply;
                    Caption = 'Desmarcar Como Contabilizada';
                    trigger OnAction()
                    var
                        Control: Codeunit ControlProcesos;
                        Facturas: Record 112;
                    BEGIN

                        Facturas.SetRange("No.", Rec."No.");
                        Control.DesmarcarcomoContabilizada(Facturas);
                    END;
                }
            }


            group(Envios)
            {
                action("Enviar Facturas")
                {
                    ApplicationArea = All;
                    Image = SendAsPDF;
                    Caption = 'Enviar Facturas';
                    trigger OnAction()
                    Var
                        r112: Record 112;
                        cPdf: Codeunit "Funciones Correo PDF";
                        Customer: Record Customer;
                        a: RecordId;
                    BEGIN
                        CurrPage.SETSELECTIONFILTER(r112);
                        CLEAR(cPdf);

                        cPdf.ProcesoPDF(r112);
                        //   {
                        //   if r112.FINDFIRST THEN REPEAT
                        //    CLEAR(cPdf);
                        //    Customer.GET(r112."Sell-to Customer No.");
                        //    cPdf.CreaPDF(1,r112."No.",Customer."Document Sending Profile");
                        //   UNTIL r112.NEXT=0;    }
                    END;
                }
                action("Enviar Agrupadas")
                {
                    Visible = false;
                    Image = SendToMultiple;
                    Caption = 'Enviar Agrupadas';
                    trigger OnAction()
                    Var
                        r112: Record 112;
                        cPdf: Codeunit "Funciones Correo PDF";
                        Customer: Record Customer;
                    BEGIN
                        CurrPage.SETSELECTIONFILTER(r112);
                        if r112.FINDFIRST THEN BEGIN
                            CLEAR(cPdf);
                            cPdf.AgrupaPDF(r112, TRUE);
                        END;
                    END;
                }
                action("Facturas Pendientes Enviar")
                {
                    ApplicationArea = All;
                    Image = "Invoicing-MailSent";
                    Caption = 'Facturas Pendientes Enviar';
                    RunObject = page "Facturas a enviar";
                    RunPageLink = "Tipo Documento" = CONST(Invoice);
                }
            }
            group(Sii)
            {
                action("Reenviar SII")
                {
                    ApplicationArea = All;
                    Image = SendElectronicDocument;
                    Caption = 'Reenviar SII';
                    trigger OnAction()
                    Var
                        GestiónSII: Report "Gestión SII";
                        SalesInv: Record 112;
                        DocType: Option " ",Payment,Invoice,"Credit Memo","Finance Charge Memo",Reminder,Refund,,,,,,,,,,,,,,,Bill;
                        r114: Record 114;
                    BEGIN

                        //-SII1
                        CurrPage.SETSELECTIONFILTER(SalesInv);
                        if SalesInv.FINDFIRST THEN
                            REPEAT
                                r114.INIT;
                                GestiónSII.CreateOrUpdateFileSales(SalesInv, r114, TRUE);
                            //GestiónSII.SetRegeneracion(2,SalesInv."No.",DocType::Invoice,SalesInv."Posting Date",SalesInv."Currency Code",TRUE);
                            //GestiónSII.USEREQUESTFORM:=FALSE;
                            //GestiónSII.RUN;
                            UNTIL SalesInv.NEXT = 0;
                        //+SII1
                    END;
                }
                action("Reenviar Modificacion SII")
                {
                    ApplicationArea = All;
                    Image = SendElectronicDocument;
                    Caption = 'Reenviar Modificacion SII';
                    trigger OnAction()
                    Var
                        GestiónSII: Report "Gestión SII";
                        SalesInv: Record 112;
                        r114: Record 114;
                        DocType: Option " ",Payment,Invoice,"Credit Memo","Finance Charge Memo",Reminder,Refund,,,,,,,,,,,,,,,Bill;
                    BEGIN

                        //-SII1
                        CurrPage.SETSELECTIONFILTER(SalesInv);
                        CurrPage.SETSELECTIONFILTER(SalesInv);
                        if SalesInv.FINDFIRST THEN
                            REPEAT
                                r114.INIT;
                                GestiónSII.CreateOrUpdateFileSalesA1(SalesInv, r114, TRUE);
                            UNTIL SalesInv.NEXT = 0;
                        //+SII1
                    END;
                }
                action("Actualiza Situacion SII")
                {
                    ApplicationArea = All;
                    Image = Refresh;
                    Caption = 'Actualiza Situacion SII';
                    trigger OnAction()
                    Var
                        rGes: Codeunit "Gestion Proyecto";
                    BEGIN
                        CLEAR(rGes);
                        rGes.SiiMensajes;
                    END;
                }
            }
            // action("Contabiliza Anticipo")
            // { 
            //   ApplicationArea=All;
            //   Image=Prepayment;
            //   CaptionML=ESP='Contabiliza Anticipo';
            //   trigger OnAction() Var
            //           FacturaAGH: Record "Impuestos factura";
            //           ContabAGH: Codeunit 50002;
            //         BEGIN
            //           FacturaAGH.SETRANGE(FacturaAGH.Factura,"No.");
            //           FacturaAGH.SETRANGE(FacturaAGH."Grupo contable producto",'');
            //           if FacturaAGH.FINDFIRST THEN REPEAT
            //             CLEAR(ContabAGH);
            //             ContabAGH.ContabilizarAnticiposHist(Rec,-FacturaAGH."Importe Bruto");
            //           UNTIL FacturaAGH.NEXT=0;
            //         END;
            //   }

        }
    }
    VAR
        // SalesInvHeader: Record 112;
        rCab2: Record 112;
        EsotraEmpresa: Boolean;
        wEmpresa: Text[30];
        TotalPurchLine: Record 39;
        TotalPurchLineLCY: Record 39;
        Vend: Record Vendor;
#pragma warning disable AL0432
        TempVATAmountLine: Record "VAT Amount Line" TEMPORARY;
#pragma warning restore AL0432
        PurchSetup: Record "Purchases & Payables Setup";
        PurchPost: Codeunit 90;
        TotalAmount1: Decimal;
        TotalAmount2: Decimal;
        VATAmount: Decimal;
        VATAmountText: Text[30];
        PrevNo: Code[20];
        AllowInvDisc: Boolean;
        AllowVATDifference: Boolean;
        Text000: Label 'Estadísticas %1 compras';
        Text001: Label 'Importe';
        Text002: Label 'Total';
        Text003: Label '%1 no debe ser 0.';
        Text004: Label '%1 no debe ser más grande de %2';
        Text005: Label 'No puede cambiar el dto. factura porque hay un %1 registro para %2 %3.';
        rPed: Record 38;
        rCab: Record 38;
        rInf: Record "IC Setup";
        rIc: Record "IC Partner";
        rCust: Record Customer;
        CustomerOrderNoVISIBLE: Boolean;
        Color: Text;

    trigger OnOpenPage()
    begin

        if EsotraEmpresa THEN BEGIN
            rInf.GET;
            rIc.GET(rInf."IC Partner Code");
            rCust.CHANGECOMPANY(wEmpresa);
            rCust.SETRANGE(rCust."IC Partner Code", rIc.Code);
            rCust.FINDFIRST;
            Rec.SETRANGE("Sell-to Customer No.", rCust."No.");
            Rec.SETRANGE("Pte Contabilicación", TRUE);
        END;
        AplicarFiltros;
        //$001
    end;

    trigger OnAfterGetRecord()
    begin
        if Rec."Customer Order No." = '' THEN Color := 'Favorable';
        if Rec."Albarán Empresa Origen" <> '' THEN Color := 'Strong';
    end;

    /// <summary>
    /// UpdateTotalAmount.
    /// </summary>
    /// <param name="TotalAmount">Decimal.</param>
    procedure UpdateTotalAmount(TotalAmount: Decimal)
    begin


    end;

    PROCEDURE AplicarFiltros();
    VAR
        rUsuario: Record 91;
    BEGIN
        //$001
        if rUsuario.GET(USERID) THEN BEGIN
            if rUsuario."Filtro vendedor" <> '' THEN BEGIN
                Rec.FILTERGROUP(2);
                Rec.SETFILTER("Salesperson Code", rUsuario."Filtro vendedor");
                Rec.FILTERGROUP(0);
            END;
            if rUsuario."Filtro departamento" <> '' THEN BEGIN
                Rec.FILTERGROUP(2);
                Rec.SETFILTER("Shortcut Dimension 1 Code", rUsuario."Filtro departamento");
                Rec.FILTERGROUP(0);
            END;

        END;
    END;

    PROCEDURE Empresa(pEmpresa: Text[30]; pActualiza: Boolean; pPdte: Boolean);
    VAR
        rIc: Record 413;
        rInf: Record "IC Setup";
        rCust: Record Customer;
    BEGIN
        Rec.CHANGECOMPANY(pEmpresa);
        wEmpresa := pEmpresa;
        rInf.GET;
        rIc.GET(rInf."IC Partner Code");
        rCust.CHANGECOMPANY(wEmpresa);
        rCust.SETRANGE(rCust."IC Partner Code", rIc.Code);
        if NOT rCust.FINDFIRST THEN
            Rec.SETRANGE("Sell-to Customer No.", '')
        ELSE
            Rec.SETRANGE("Sell-to Customer No.", rCust."No.");
        if pPdte THEN
            Rec.SETRANGE("Pte Contabilicación", TRUE);
        CustomerOrderNoVISIBLE := TRUE;
        EsotraEmpresa := TRUE;
        if pActualiza THEN BEGIN
            CurrPage.UPDATE(FALSE);
            if Rec.FINDFIRST THEN;
        END;
    END;



    PROCEDURE TextoContrato(): Text[100];
    VAR
        rContr: Record 36;
    BEGIN
        if wEmpresa <> '' THEN
            rContr.CHANGECOMPANY(wEmpresa);
        if rContr.GET(rContr."Document Type"::Order, Rec."Nº Contrato") THEN BEGIN
            if rContr."Nº pedido" = '' THEN
                EXIT(rContr."Posting Description");
            EXIT(rContr."Nº pedido");
        END;
    END;

    PROCEDURE Activo(Pedido: Code[20]): Boolean;
    VAR
        rPed: Record "Purch. Rcpt. Line";
    BEGIN
        rPed.SETRANGE(rPed."Document No.", Pedido);
        rPed.SETRANGE(rPed.Type, rPed.Type::"Fixed Asset");
        EXIT(rPed.FINDFIRST);
    END;

    // BEGIN
    // {
    //   $001 FCL-050710. Aplico filtros por vendedor definidos en la tabla de usuarios.
    // }
    // END.
}
