/// <summary>
/// Page Lista de facturas (ID 50037).
/// </summary>
page 50037 "Lista de facturas"
{
    CardPageID = "Posted Sales Invoice";
    Editable = false;
    PageType = ListPart;
    //PromotedActionCategories = 'Nuevo,Proceso,Informes,Factura,Navegar,Correción,Imprimir/Enviar';
    QueryCategory = 'Posted Sales Invoices';
    RefreshOnActivate = true;
    SourceTable = "Sales Invoice Header";
    SourceTableView = SORTING("Posting Date")
                      ORDER(Descending);
    Permissions = tabledata 112 = rimd, tabledata 113 = rimd, tabledata 17 = rimd, tabledata 21 = rimd, tabledata 379 = rimd,
    tabledata 36 = rimd, tabledata 37 = rimd, tabledata 38 = rimd, tabledata 39 = rimd, tabledata 120 = rimd, tabledata 121 = rimd,
    tabledata 413 = rimd, tabledata 79 = rimd, tabledata 18 = rimd, tabledata 167 = rimd, tabledata 6650 = rimd, tabledata 6651 = rimd,
    tabledata 114 = rimd, tabledata 115 = rimd;

    AboutTitle = 'About posted sales invoices';
    AboutText = 'When sales invoices are posted, they appear here where you can follow the remaining amounts to be paid by your customers.';

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field("No."; Rec."No.")
                {

                    StyleExpr = Color;
                    ApplicationArea = Basic, Suite;
                    AboutTitle = 'The final invoice number (No.)';
                    AboutText = 'This is the invoice number uniquely identifying each posted sale. Your customers see this number on the invoices they receive from you.';
                    ToolTip = 'Specifies the number of the involved entry or record, according to the specified number series.';
                }
                field("Order No."; Rec."Order No.")
                {
                    StyleExpr = Color;
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies the number of the related order.';
                    Caption = 'Nº pedido';
                }
                field("Sell-to Customer No."; Rec."Sell-to Customer No.")
                {
                    StyleExpr = Color;
                    ApplicationArea = Basic, Suite;
                    Caption = 'Nº Cliente';
                    ToolTip = 'Specifies the number of the customer the invoice concerns.';
                }
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
                field("Sell-to Customer Name"; Rec."Sell-to Customer Name")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Nombre Cliente';
                    ToolTip = 'Specifies the name of the customer that you shipped the items on the invoice to.';
                }
                field("Currency Code"; Rec."Currency Code")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies the currency code of the invoice.';
                }
                field("Due Date"; Rec."Due Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the date on which the invoice is due for payment.';
                }
                field(Amount; Rec.Amount)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the total, in the currency of the invoice, of the amounts on all the invoice lines. The amount does not include VAT.';


                }
                field("Amount Including VAT"; Rec."Amount Including VAT")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the total of the amounts, including VAT, on all the lines on the document.';


                }
                field("Remaining Amount"; Rec."Remaining Amount")
                {
                    ApplicationArea = Basic, Suite;
                    AboutTitle = 'What remains to be paid';
                    AboutText = 'This column shows you what is not yet paid on each invoice. When full payment is registered, an invoice is marked as Closed.';
                    ToolTip = 'Specifies the amount that remains to be paid for the posted sales invoice.';
                }
                field("Sell-to Post Code"; Rec."Sell-to Post Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the postal code of the customer''s main address.';
                    Visible = false;
                }
                field("Sell-to Country/Region Code"; Rec."Sell-to Country/Region Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the country/region code of the customer''s main address.';
                    Visible = false;
                }
                field("Sell-to Contact"; Rec."Sell-to Contact")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the name of the contact person at the customer''s main address.';
                    Visible = false;
                }
                field("Bill-to Customer No."; Rec."Bill-to Customer No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the number of the customer that you send or sent the invoice or credit memo to.';
                    Visible = false;
                }
                field("Bill-to Name"; Rec."Bill-to Name")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the name of the customer that you send or sent the invoice or credit memo to.';
                    Visible = false;
                }
                field("Bill-to Post Code"; Rec."Bill-to Post Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the postal code of the customer''s billing address.';
                    Visible = false;
                }
                field("Bill-to Country/Region Code"; Rec."Bill-to Country/Region Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the country/region code of the customer''s billing address.';
                    Visible = false;
                }
                field("Bill-to Contact"; Rec."Bill-to Contact")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the name of the contact person at the customer''s billing address.';
                    Visible = false;
                }
                field("Ship-to Code"; Rec."Ship-to Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies a code for an alternate shipment address if you want to ship to another address than the one that has been entered automatically. This field is also used in case of drop shipment.';
                    Visible = false;
                }
                field("<Ship-to Code>"; Rec."Ship-to Name")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the name of the customer that the items were shipped to.';
                    Visible = false;
                }
                field("Ship-to Post Code"; Rec."Ship-to Post Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the postal code of the address that the items are shipped to.';
                    Visible = false;
                }
                field("Ship-to Country/Region Code"; Rec."Ship-to Country/Region Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the country/region code of the address that the items are shipped to.';
                    Visible = false;
                }
                field("Ship-to Contact"; Rec."Ship-to Contact")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the name of the contact person at the address that the items are shipped to.';
                    Visible = false;
                }
                field("Posting Date"; Rec."Posting Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the date when the invoice was posted.';
                    Visible = true;
                }
                field("Salesperson Code"; Rec."Salesperson Code")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies which salesperson is associated with the invoice.';
                    Visible = false;
                }
                field("Shortcut Dimension 1 Code"; Rec."Shortcut Dimension 1 Code")
                {
                    ApplicationArea = Dimensions;
                    ToolTip = 'Specifies the code for Shortcut Dimension 1, which is one of two global dimension codes that you set up in the General Ledger Setup window.';
                    Visible = false;
                }
                field("Shortcut Dimension 2 Code"; Rec."Shortcut Dimension 2 Code")
                {
                    ApplicationArea = Dimensions;
                    ToolTip = 'Specifies the code for Shortcut Dimension 2, which is one of two global dimension codes that you set up in the General Ledger Setup window.';
                    Visible = false;
                }
                field("Location Code"; Rec."Location Code")
                {
                    ApplicationArea = Location;
                    ToolTip = 'Specifies the code for the location from which the items were shipped.';
                }
                field("No. Printed"; Rec."No. Printed")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies how many times the document has been printed.';
                }
                field("External Document No."; Rec."External Document No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies a document number that refers to the customer''s or vendor''s numbering system.';
                    Visible = false;
                }
                field("Payment Terms Code"; Rec."Payment Terms Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies a formula that calculates the payment due date, payment discount date, and payment discount amount.';
                    Visible = false;
                }
                field("Payment Discount %"; Rec."Payment Discount %")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the payment discount percent granted if payment is made on or before the date in the Pmt. Discount Date field.';
                    Visible = false;
                }
                field("Shipment Method Code"; Rec."Shipment Method Code")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies the delivery conditions of the related shipment, such as free on board (FOB).';
                    Visible = false;
                }
                field("Shipping Agent Code"; Rec."Shipping Agent Code")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies the code for the shipping agent who is transporting the items.';
                    Visible = false;
                }
                field(Closed; Rec.Closed)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies if the posted sales invoice is paid. The check box will also be selected if a credit memo for the remaining amount has been applied.';
                }
                field(Cancelled; Rec.Cancelled)
                {
                    ApplicationArea = Basic, Suite;
                    HideValue = NOT Rec.Cancelled;
                    Style = Unfavorable;
                    StyleExpr = Rec.Cancelled;
                    ToolTip = 'Specifies if the posted sales invoice has been either corrected or canceled.';

                    trigger OnDrillDown()
                    begin
                        Rec.ShowCorrectiveCreditMemo;
                    end;
                }
                field(Corrective; Rec.Corrective)
                {
                    ApplicationArea = Basic, Suite;
                    HideValue = NOT Rec.Corrective;
                    Style = Unfavorable;
                    StyleExpr = Rec.Corrective;
                    ToolTip = 'Specifies if the posted sales invoice is a corrective document.';

                    trigger OnDrillDown()
                    begin
                        Rec.ShowCancelledCreditMemo;
                    end;
                }
                field("Shipment Date"; Rec."Shipment Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies when items on the document are shipped or were shipped. A shipment date is usually calculated from a requested delivery date plus lead time.';
                    Visible = false;
                }
            }
        }

    }

    actions
    {
        area(Processing)
        {
            action("Contabilizar (Negrita)")
            {
                ApplicationArea = all;
                Scope = Repeater;
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
                    a: Integer;
                    b: Integer;
                BEGIN
                    if NOT EsotraEmpresa THEN EXIT;
                    Rec.ChangeCompany(wEmpresa);
                    if rec."Albarán Empresa Origen" <> '' THEN ERROR('Esta factura tiene Albarán');
                    rCab.Setrange("Vendor Invoice No.", Rec."No.");
                    if Not rCab.FindFirst() Then Error('No se ha encontrado la factura');
                    AmountIncl := 0;
                    pAmount := 0;
                    rLinVta.CHANGECOMPANY(wEmpresa);
                    rLinVta.SETRANGE(rLinVta."Document No.", Rec."No.");
                    rLinVta.SetFilter(rLinVta.Type, '<>%1', rLinVta.Type::" ");
                    if rLinVtaF.FINDFIRST THEN
                        REPEAT
                            AmountIncl := AmountIncl + rLinVtaF."Amount Including VAT";
                            pAmount := pAmount + rLinVtaF.Amount;
                        UNTIL rLinVtaF.NEXT = 0;
                    if TotalAmount2 <> AmountIncl THEN BEGIN
                        if ABS(TotalAmount2 - AmountIncl) < 5 THEN
                            UpdateTotalAmount(pAmount);
                    END;
                    Rec."Pte Contabilicación" := false;
                    Rec.MODIFY;
                    COMMIT;

                    PAGE.RUNMODAL(51, rCab);
                end;
            }
            action("Contabilizar (Negro)")
            {
                ApplicationArea = all;
                Scope = Repeater;
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
                    a: Integer;
                    b: Integer;
                BEGIN
                    if NOT EsotraEmpresa THEN EXIT;
                    Rec.ChangeCompany(wEmpresa);
                    if rec."Albarán Empresa Origen" <> '' THEN ERROR('Esta factura tiene Albarán');
                    rPed.GET(rPed."Document Type"::Order, Rec."Customer Order No.");
                    rLinVta.CHANGECOMPANY(wEmpresa);
                    rLinVta.SETRANGE(rLinVta."Document No.", Rec."No.");
                    rLinVta.SetFilter(rLinVta.Type, '<>%1', rLinVta.Type::" ");
                    if rLinVta.FINDFIRST THEN
                        REPEAT
                            rLin2.SETRANGE(rLin2."Document Type", rPed."Document Type");
                            rLin2.SETRANGE(rLin2."Document No.", rPed."No.");
                            rLin2.SETRANGE(rLin2."Linea de proyecto", rLinVta."No linea proyecto");
                            rLin2.SETFILTER(rLin2.Type, '<>%1', 0);
                            rLin2.SETFILTER(rLin2."No.", '<>%1', '');
                            if rLin2.FINDFIRST THEN
                                REPEAT
                                    if rLin2."Qty. to Invoice" <> 0 THEN begin
                                        if ROUND(rLinVta.Quantity, 0.00001, '=') >= ROUND(rLin2."Qty. to Invoice", 0.00001, '=') then
                                            a := b
                                        else
                                            rLin2.VALIDATE("Qty. to Invoice", rLinVta.Quantity);
                                    end;
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
                        rCab."Empresa Factura" := wEmpresa;
                        rCab."Posting Date" := WORKDATE;
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
                                                Q := Round(Q, 0.00001, '=');
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
                ApplicationArea = all;
                Scope = Repeater;
                Image = Register;
                Caption = 'Contabilizar desde albarán (Verde)';
                trigger OnAction()
                Var
                    rLin: Record 39;
                    rLin2: Record 39;
                    PurchRecpLine: Record "Purch. Rcpt. Line";
                    QtyToInv: Decimal;
                    Q: Decimal;
                    Q2: Decimal;
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
                    if Rec."Albarán Empresa Origen" = '' Then error('No puede usar este punto, si no hay albarán');
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
                        rCab."Document Date" := Rec."Posting Date";
                        if Rec."Posting Date" > WORKDATE THEN
                            rCab."Posting Date" := Rec."Posting Date";
                        rCab."Vendor Invoice No." := Rec."No.";
                        rCab.Status := rCab.Status::Open;
                        rCab.INSERT(TRUE);
                        rCab.VALIDATE("Document Date", Rec."Posting Date");
                        rCab."Posting Description" := FORMAT(rCab."Document Type") + ' ' + rCab."Vendor Invoice No.";
                        rCab."Empresa Factura" := wEmpresa;
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
                                Q := PurchRecpLine."Qty. Rcd. Not Invoiced";
                                q2 += q;
                                //Inserta Linea Albarán
                                //QtyInvo:=QtyInvo+Q;
                                CLEAR(c74);
                                PurchRecpLine2.RESET;
                                PurchRecpLine2.SETRANGE(PurchRecpLine2."Document No.", PurchRecpLine."Document No.");
                                PurchRecpLine2.SETRANGE(PurchRecpLine2."Line No.", PurchRecpLine."Line No.");
                                PurchRcptHeader.Get(PurchRecpLine."Document No.");
                                if PurchRecpLine2.FindFirst() Then begin
                                    Q := Round(Q, 0.00001, '=');
                                    if Q <> 0 THEN
                                        c74.CreateInvoiceLines2(PurchRecpLine2, Q, rCab, PurchRcptHeader);
                                end;
                            //END;
                            UNTIL PurchRecpLine.NEXT = 0;
                        if Q2 = 0 Then Message('No hay nningún movimiento pendiente')
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
            action("Contabilizar Activos (Naranja)")
            {
                ShortCutKey = 'Ctrl+F11';
                ApplicationArea = all;
                Scope = Repeater;
                Image = Register;
                Caption = 'Contabilizar Activos (Naranja)';
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
                ApplicationArea = all;
                Scope = Repeater;
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
                ApplicationArea = all;
                Scope = Repeater;
                Image = Undo;
                Visible = true;
                Caption = 'Desmarcar';
                trigger OnAction()
                BEGIN
                    Rec."Pte Contabilicación" := TRUE;
                    Rec.MODIFY;
                END;
            }
            action("Asignar Pedido (Rojo)")
            {
                ApplicationArea = all;
                Scope = Repeater;
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
            action("Asignar Albarán")
            {
                ApplicationArea = all;
                Scope = Repeater;
                Image = Order;
                Caption = 'Asignar Albarán';
                trigger OnAction()
                Var
                    rCabPed: Record "Purch. Rcpt. Header";
                    rIc: Record 413;
                    rInf: Record 79;
                    rVend: Record Vendor;
                    rJob: Record 167;
                    rContr: Record 36;
                    r112: Record 112;
                    r114: Record 114;
                BEGIN
                    //if "Albarán Empresa Origen" <> '' THEN ERROR('Este abono tiene albarán');
                    rIc.SETRANGE(rIc."Inbox Details", wEmpresa);
                    rIc.FINDFIRST;
                    rVend.SETRANGE(rVend."IC Partner Code", rIc.Code);
                    rVend.FINDFIRST;
                    rCabPed.SETRANGE("Buy-from Vendor No.", rVend."No.");
                    rCabPed.SETRANGE(rCabPed."Posting Date", CALCDATE('-9M', Rec."Posting Date"), 99991231D);
                    if Page.RUNMODAL(0, rCabPed) = ACTION::LookupOK THEN BEGIN
                        Rec."Albarán Empresa Origen" := rCabPed."No.";
                        Rec.MODIFY;
                        // {if "Nº Proyecto"<>'PR99-99999' THEN BEGIN
                        //     rJob.CHANGECOMPANY(wEmpresa);
                        //     if rJob.GET("Nº Proyecto") THEN BEGIN
                        //     rContr.CHANGECOMPANY(wEmpresa);
                        //     rContr.SETCURRENTKEY(rContr."Nº Proyecto");
                        //     rContr.SETRANGE(rContr."Nº Proyecto",rJob."No.");
                        //     if rContr.FINDFIRST THEN REPEAT
                        //     rContr."Customer Order No.":=rCabPed."No.";
                        //     rContr.MODIFY;
                        //     UNTIL rContr.NEXT=0;
                        //     r112.CHANGECOMPANY(rIc."Inbox Details");
                        //     r112.SETCURRENTKEY("Nº Proyecto");
                        //     r112.SETRANGE("Nº Proyecto",rJob."No.");
                        //     if r112.FINDFIRST THEN REPEAT
                        //     if "No."<>r112."No." THEN BEGIN
                        //     r112."Customer Order No.":=rCabPed."No.";
                        //     r112.MODIFY;
                        //     END;
                        //     UNTIL r112.NEXT=0;
                        //     r114.CHANGECOMPANY(rIc."Inbox Details");
                        //     r114.SETCURRENTKEY("Nº Proyecto");
                        //     r114.SETRANGE("Nº Proyecto",rJob."No.");
                        //     if r114.FINDFIRST THEN REPEAT
                        //     r114."Customer Order No.":=rCabPed."No.";
                        //     r114.MODIFY;
                        //     UNTIL r114.NEXT=0;
                        //     END;  }
                    END;
                END;
            }
            action("Desasignar Pedido")
            {
                ApplicationArea = all;
                Scope = Repeater;
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
                ApplicationArea = all;
                Scope = Repeater;
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
                ApplicationArea = all;
                Scope = Repeater;
                Image = UnApply;
                Caption = 'Desmarcar Como Contabilizada';
                trigger OnAction()
                var
                    C: Codeunit ControlProcesos;
                BEGIN
                    c.MarcarFacturaComoContabilizada(Rec, true);

                END;
            }
            // action("Cambiar Fecha")
            // {
            //     ApplicationArea = all;Scope=Repeater;
            //     Image = ChangeDate;
            //     Caption=  'Cambiar Fecha';
            //     trigger OnAction()
            //     Var
            //         Fecha: Date;
            //         r17: Record "G/L Entry";
            //         Ventana: Page "Dialogo fecha contrato";
            //         SalesInvoice: Record 112;
            //         c11: Codeunit 11;
            //     BEGIN
            //         Ventana.SetCampos(Fecha);
            //         Ventana.RunModal();
            //         Ventana.GetCampos(Fecha);
            //         // Ventana.OPEN('Introduzca la nueva fecha: #########1##');
            //         // Ventana.INPUT(1,Fecha);
            //         // Ventana.CLOSE;
            //         CLEAR(c11);
            //         if c11.DateNotAllowed(Fecha) THEN ERROR('La fecha esta en un periodo cerrado');

            //         CurrPage.SETSELECTIONFILTER(SalesInvoice);
            //         if SalesInvoice.FINDFIRST THEN
            //             REPEAT
            //                 CLEAR(c11);
            //                 if c11.DateNotAllowed(SalesInvoice."Posting Date") THEN ERROR('La fecha esta en un periodo cerrado');
            //                 r17.SETCURRENTKEY("Document No.", "Posting Date");
            //                 r17.SETRANGE(r17."Document No.", SalesInvoice."No.");
            //                 r17.SETRANGE(r17."Posting Date", SalesInvoice."Posting Date");
            //                 r17.MODIFYALL("Posting Date", Fecha, TRUE);
            //                 SalesInvoice."Posting Date" := Fecha;
            //                 SalesInvoice.MODIFY;
            //             UNTIL SalesInvoice.NEXT = 0;
            //     END;
            // }
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
    var
        PurchaseHeader: Record 38;
        HistPurchase: Record 122;
    begin
        Color := 'Standard';
        if Rec."Customer Order No." = '' THEN Color := 'UnFavorable';
        if Rec."Albarán Empresa Origen" <> '' THEN Color := 'Favorable';
        if Activo(Rec."Albarán Empresa Origen") THEN Color := 'Ambiguous';
        PurchaseHeader.SetRange("Vendor Invoice No.", Rec."No.");
        if PurchaseHeader.FindFirst() Then
            Color := 'StandardAccent';
        HistPurchase.SetRange("Vendor Invoice No.", Rec."No.");
        if HistPurchase.FindFirst() Then
            Color := 'StrongAccent';

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

}
page 50038 "Lista de Abonos"
{
    CardPageID = "Posted Sales Credit Memo";
    Editable = false;
    PageType = ListPart;
    QueryCategory = 'Posted Sales Credit Memos';
    SourceTable = "Sales Cr.Memo Header";
    SourceTableView = SORTING("Posting Date")
                      ORDER(Descending);
    //PromotedActionCategories = 'Nuevo,Proceso,Informes,Factura,Navegar,Correción,Imprimir/Enviar';
    Permissions = tabledata 112 = rimd, tabledata 113 = rimd, tabledata 17 = rimd, tabledata 21 = rimd, tabledata 379 = rimd,
    tabledata 36 = rimd, tabledata 37 = rimd, tabledata 38 = rimd, tabledata 39 = rimd, tabledata 120 = rimd, tabledata 121 = rimd,
    tabledata 413 = rimd, tabledata 79 = rimd, tabledata 18 = rimd, tabledata 167 = rimd, tabledata 6650 = rimd, tabledata 6651 = rimd,
    tabledata 114 = rimd, tabledata 115 = rimd, tabledata 481 = rimd, tabledata 480 = rimd;

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the number of the involved entry or record, according to the specified number series.';
                    StyleExpr = Color;
                }
                field("Sell-to Customer No."; Rec."Sell-to Customer No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the number of the customer.';
                }
                field("Customer Order No."; Rec."Customer Order No.")
                {
                    ApplicationArea = All;
                }
                field("Sell-to Customer Name"; Rec."Sell-to Customer Name")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Nombre Cliente';
                    ToolTip = 'Specifies the name of the customer that you shipped the items on the credit memo to.';
                }
                field("Currency Code"; Rec."Currency Code")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies the currency code of the credit memo.';
                }
                field("Due Date"; Rec."Due Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the date on which the shipment is due for payment.';
                }
                field(Amount; Rec.Amount)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the total of the amounts on all the credit memo lines, in the currency of the credit memo. The amount does not include VAT.';


                }
                field("Amount Including VAT"; Rec."Amount Including VAT")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the total of the amounts, including VAT, on all the lines on the document.';


                }
                field("Remaining Amount"; Rec."Remaining Amount")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the amount that remains to be paid for the posted sales invoice.';
                }
                field(Paid; Rec.Paid)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies if the posted sales invoice that relates to this sales credit memo is paid.';
                }
                field(Cancelled; Rec.Cancelled)
                {
                    ApplicationArea = Basic, Suite;
                    HideValue = NOT Rec.Cancelled;
                    Style = Unfavorable;
                    StyleExpr = Rec.Cancelled;
                    ToolTip = 'Specifies if the posted sales invoice that relates to this sales credit memo has been either corrected or canceled.';

                    trigger OnDrillDown()
                    begin
                        Rec.ShowCorrectiveInvoice;
                    end;
                }
                field(Corrective; Rec.Corrective)
                {
                    ApplicationArea = Basic, Suite;
                    HideValue = NOT Rec.Corrective;
                    Style = Unfavorable;
                    StyleExpr = Rec.Corrective;
                    ToolTip = 'Specifies if the posted sales invoice has been either corrected or canceled by this sales credit memo.';

                    trigger OnDrillDown()
                    begin
                        Rec.ShowCancelledInvoice;
                    end;
                }
                field("Sell-to Post Code"; Rec."Sell-to Post Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the postal code of the customer''s main address.';
                    Visible = false;
                }
                field("Sell-to Country/Region Code"; Rec."Sell-to Country/Region Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the country/region code of the customer''s main address.';
                    Visible = false;
                }
                field("Sell-to Contact"; Rec."Sell-to Contact")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the name of the contact person at the customer''s main address.';
                    Visible = false;
                }
                field("Bill-to Customer No."; Rec."Bill-to Customer No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the number of the customer that you send or sent the invoice or credit memo to.';
                    Visible = false;
                }
                field("Bill-to Name"; Rec."Bill-to Name")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the name of the customer that you send or sent the invoice or credit memo to.';
                    Visible = false;
                }
                field("Bill-to Post Code"; Rec."Bill-to Post Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the postal code of the customer''s billing address.';
                    Visible = false;
                }
                field("Bill-to Country/Region Code"; Rec."Bill-to Country/Region Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the country/region code of the customer''s billing address.';
                    Visible = false;
                }
                field("Bill-to Contact"; Rec."Bill-to Contact")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the name of the contact person at the customer''s billing address.';
                    Visible = false;
                }
                field("Ship-to Code"; Rec."Ship-to Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies a code for an alternate shipment address if you want to ship to another address than the one that has been entered automatically. This field is also used in case of drop shipment.';
                    Visible = false;
                }
                field("Ship-to Name"; Rec."Ship-to Name")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the name of the customer at the address that the items are shipped to.';
                    Visible = false;
                }
                field("Ship-to Post Code"; Rec."Ship-to Post Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the postal code of the address that the items are shipped to.';
                    Visible = false;
                }
                field("Ship-to Country/Region Code"; Rec."Ship-to Country/Region Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the country/region code of the address that the items are shipped to.';
                    Visible = false;
                }
                field("Ship-to Contact"; Rec."Ship-to Contact")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the name of the contact person at the address that the items are shipped to.';
                    Visible = false;
                }
                field("Posting Date"; Rec."Posting Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the date when the credit memo was posted.';
                    Visible = true;
                }
                field("Salesperson Code"; Rec."Salesperson Code")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies which salesperson is associated with the credit memo.';
                    Visible = false;
                }
                field("Shortcut Dimension 1 Code"; Rec."Shortcut Dimension 1 Code")
                {
                    ApplicationArea = Dimensions;
                    ToolTip = 'Specifies the code for Shortcut Dimension 1, which is one of two global dimension codes that you set up in the General Ledger Setup window.';
                    Visible = false;
                }
                field("Shortcut Dimension 2 Code"; Rec."Shortcut Dimension 2 Code")
                {
                    ApplicationArea = Dimensions;
                    ToolTip = 'Specifies the code for Shortcut Dimension 2, which is one of two global dimension codes that you set up in the General Ledger Setup window.';
                    Visible = false;
                }
                field("Location Code"; Rec."Location Code")
                {
                    ApplicationArea = Location;
                    ToolTip = 'Specifies the location where the credit memo was registered.';
                }
                field("No. Printed"; Rec."No. Printed")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies how many times the document has been printed.';
                }
                field("Document Date"; Rec."Document Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the date when the related document was created.';
                    Visible = false;
                }
                field("Applies-to Doc. Type"; Rec."Applies-to Doc. Type")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the type of the posted document that this document or journal line will be applied to when you post, for example to register payment.';
                    Visible = false;
                }

            }
        }

    }

    actions
    {
        area(processing)
        {
            action("Contabilizar (Negro)")
            {
                ApplicationArea = all;
                Scope = Repeater;
                Image = Register;
                ShortCutKey = F11;

                trigger OnAction()
                Var
                    rLin: Record 39;
                    rLin2: Record 39;
                    PurchRecpLine: Record 6651;
                    QtyToInv: Decimal;
                    Q: Decimal;
                    QtyInvo: Decimal;
                    c74: Codeunit "Procedures Standard";
                    PurchRecpLine2: Record 6651;
                    PurchRecpHeader: Record 6650;
                    rLinVta: Record 115;
                    PurchLine: Record 39;
                    TempPurchLine: Record 39 TEMPORARY;
                    rLinVtaF: Record 115;
                    AmountIncl: Decimal;
                    pAmount: Decimal;

                BEGIN
                    if NOT EsotraEmpresa THEN EXIT;
                    rPed.GET(rPed."Document Type"::"Return Order", Rec."Customer Order No.");
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
                                    rLin2.VALIDATE("Qty. to Invoice", rLinVta.Quantity);
                                    rLin2.MODIFY;
                                UNTIL rLin2.NEXT = 0;
                        UNTIL rLinVta.NEXT = 0;
                    WITH rPed DO BEGIN
                        rCab := rPed;
                        rCab."Document Type" := rCab."Document Type"::"Credit Memo";
                        rCab."No." := '';
                        rCab."Posting Date" := WORKDATE;
                        rCab."Document Date" := Rec."Posting Date";
                        rCab."Vendor Invoice No." := rLinVta."Document No.";
                        rCab.Status := rCab.Status::Open;
                        rCab."Empresa Factura" := wEmpresa;
                        rCab.INSERT(TRUE);
                        rCab.VALIDATE("Document Date", Rec."Posting Date");
                        rCab."Posting Description" := FORMAT(rCab."Document Type") + ' ' + rCab."Vendor Invoice No.";
                        rCab.MODIFY;
                        rLin.SETRANGE(rLin."Document Type", rLin."Document Type"::"Credit Memo");
                        rLin.SETRANGE(rLin."Document No.", rCab."No.");
                        rLin2.RESET;
                        rLin2.SETRANGE(rLin2."Document Type", "Document Type");
                        rLin2.SETRANGE(rLin2."Document No.", "No.");
                        if rLin2.FINDFIRST THEN
                            REPEAT

                                PurchRecpLine.RESET;
                                PurchRecpLine.SETCURRENTKEY("Return Order No.", "Return Order Line No.");
                                PurchRecpLine.SETRANGE(PurchRecpLine."Return Order No.", "No.");
                                PurchRecpLine.SETRANGE(PurchRecpLine."Return Order Line No.", rLin2."Line No.");
                                QtyToInv := 0;
                                QtyInvo := 0;
                                if PurchRecpLine.FINDFIRST THEN
                                    REPEAT
                                        if QtyToInv <= rLin2."Qty. to Invoice" THEN BEGIN
                                            QtyToInv := QtyToInv + PurchRecpLine."Return Qty. Shipped Not Invd.";
                                            if QtyToInv > rLin2."Qty. to Invoice" THEN
                                                Q := rLin2."Qty. to Invoice" - QtyInvo
                                            ELSE
                                                Q := PurchRecpLine."Return Qty. Shipped Not Invd.";
                                            //Inserta Linea Albarán
                                            QtyInvo := QtyInvo + Q;
                                            CLEAR(c74);
                                            //c74.SetPurchHeader(rCab);
                                            PurchRecpLine2.RESET;
                                            PurchRecpLine2.SETRANGE(PurchRecpLine2."Document No.", PurchRecpLine."Document No.");
                                            PurchRecpLine2.SETRANGE(PurchRecpLine2."Line No.", PurchRecpLine."Line No.");
                                            PurchRecpLine2.SETRANGE(PurchRecpLine2."Return Order No.", "No.");
                                            PurchRecpLine2.SETRANGE(PurchRecpLine2."Return Order Line No.", rLin2."Line No.");
                                            PurchRecpHeader.Get(PurchRecpLine."Document No.");
                                            //Desmarcar
                                            if Q <> 0 THEN
                                                c74.CreateCrLines2(PurchRecpLine2, Q, rCab, PurchRecpHeader);
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
                    Page.RUNMODAL(52, rCab);
                END;

            }
            action("Contabilizar desde albarán (Verde)")
            {
                ShortCutKey = 'Mayús+F11';
                ApplicationArea = all;
                Scope = Repeater;
                Image = Register;
                Caption = 'Contabilizar desde albarán (Verde)';
                trigger OnAction()
                Var
                    rLin: Record 39;
                    rLin2: Record 39;
                    PurchRecpLine: Record 6651;
                    PurchRecpHeader: Record 6650;
                    QtyToInv: Decimal;
                    Q: Decimal;
                    QtyInvo: Decimal;
                    c74: Codeunit "Procedures Standard";
                    PurchRecpLine2: Record 6651;
                    rLinVta: Record 115;
                    PurchLine: Record 39;
                    TempPurchLine: Record 39 TEMPORARY;
                    rLinVtaF: Record 113;
                    AmountIncl: Decimal;
                    pAmount: Decimal;
                    rAlb: Record 6650;
                    rLinA: Record 6651;
                BEGIN
                    rAlb.GET(Rec."Albarán Empresa Origen");
                    rPed.GET(rPed."Document Type"::"Return Order", rAlb."Return Order No.");
                    rLinA.SETRANGE("Document No.", rAlb."No.");
                    if rLinA.FINDFIRST THEN
                        REPEAT
                            rLin2.SETRANGE(rLin2."Document Type", rPed."Document Type");
                            rLin2.SETRANGE(rLin2."Document No.", rPed."No.");
                            rLin2.SETRANGE(rLin2."Line No.", rLinA."Return Order Line No.");
                            rLin2.SETFILTER(rLin2.Type, '<>%1', 0);
                            if rLin2.FINDFIRST THEN
                                REPEAT
                                    rLin2.VALIDATE("Qty. to Invoice", rLinA.Quantity);
                                    rLin2.MODIFY;
                                UNTIL rLin2.NEXT = 0;
                        UNTIL rLinA.NEXT = 0;
                    WITH rPed DO BEGIN
                        rCab := rPed;
                        rCab."Document Type" := rCab."Document Type"::"Credit Memo";
                        rCab."No." := '';
                        rCab."Posting Date" := WORKDATE;
                        rCab."Document Date" := Rec."Posting Date";
                        if Rec."Posting Date" > WORKDATE THEN
                            rCab."Posting Date" := Rec."Posting Date";
                        rCab."Vendor Cr. Memo No." := Rec."No.";
                        rCab.Status := rCab.Status::Open;
                        rCab."Empresa Factura" := wEmpresa;
                        rCab.INSERT(TRUE);
                        rCab.VALIDATE("Document Date", Rec."Posting Date");
                        rCab."Posting Description" := FORMAT(rCab."Document Type") + ' ' + rCab."Vendor Cr. Memo No.";

                        rCab.MODIFY;
                        rLin.SETRANGE(rLin."Document Type", rLin."Document Type"::"Credit Memo");
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
                        if PurchRecpLine.FINDFIRST THEN
                            REPEAT
                                // {if QtyToInv<=PurchRecpLine."Qty. to Invoice" THEN BEGIN
                                //     QtyToInv:=QtyToInv+PurchRecpLine."Qty. Rcd. Not Invoiced";
                                //     if QtyToInv>PurchRecpLine."Qty. to Invoice" THEN
                                //     Q:=rLin2."Qty. to Invoice"-QtyInvo
                                //     ELSE }
                                Q := PurchRecpLine."Return Qty. Shipped Not Invd.";
                                //Inserta Linea Albarán
                                //QtyInvo:=QtyInvo+Q;
                                CLEAR(c74);
                                //    c74.SetPurchHeaderCr(rCab);
                                PurchRecpLine2.RESET;
                                PurchRecpLine2.SETRANGE(PurchRecpLine2."Document No.", PurchRecpLine."Document No.");
                                PurchRecpLine2.SETRANGE(PurchRecpLine2."Line No.", PurchRecpLine."Line No.");
                                PurchRecpHeader.Get(PurchRecpLine."Document No.");
                                if Q <> 0 THEN
                                    c74.CreateCrLines2(PurchRecpLine2, Q, rCab, PurchRecpHeader);
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
                    Page.RUNMODAL(52, rCab);
                END;

            }
            // action("Contabilizar Activos (Amarillo)")
            // {
            //     ShortCutKey = 'Ctrl+F11';
            //     ApplicationArea = all;Scope=Repeater;
            //     Image = Register;
            //     Caption=  'Contabilizar Activos (Amarillo)';
            //     trigger OnAction()
            //     Var
            //         r38: Record 38;
            //         r120: Record "Purch. Rcpt. Header";
            //     BEGIN
            //         if Activo("Albarán Empresa Origen") THEN BEGIN
            //             "Pte Contabilicación" := FALSE;
            //             MODIFY;
            //             COMMIT;
            //             r120.GET("Albarán Empresa Origen");
            //             r38.GET(r38."Document Type"::Order, r120."Order No.");
            //             r38."Vendor Invoice No." := "No.";
            //             r38.MODIFY;
            //             COMMIT;
            //             PAGE.RUNMODAL(50, r38);
            //         END;
            //     END;
            // }
            action("Abonos Empresa")
            {
                ApplicationArea = all;
                Scope = Repeater;
                Image = Company;
                Caption = 'Abonos Empresa';
                trigger OnAction()
                Var
                    rEmp: Record 2000000006;
                    rIc: Record 413;
                    rCust: Record Customer;
                    rInf: Record "IC Setup";
                BEGIN
                    if Page.RUNMODAL(Page::Companies, rEmp) in [ACTION::LookupOK, ACTION::OK] THEN
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
                ApplicationArea = all;
                Scope = Repeater;
                Image = Undo;
                Visible = true;
                Caption = 'Desmarcar';
                trigger OnAction()
                var
                    C: Codeunit ControlProcesos;
                BEGIN
                    c.MarcarAbonoComoContabilizada(Rec, true);

                END;
            }
            action("Asignar Pedido (Rojo)")
            {
                ApplicationArea = all;
                Scope = Repeater;
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
                    if Rec."Albarán Empresa Origen" <> '' THEN ERROR('Este abono tiene albarán');
                    rIc.SETRANGE(rIc."Inbox Details", wEmpresa);
                    rIc.FINDFIRST;
                    rVend.SETRANGE(rVend."IC Partner Code", rIc.Code);
                    rVend.FINDFIRST;
                    rCabPed.SETRANGE("Document Type", rCabPed."Document Type"::"Return Order");
                    rCabPed.SETRANGE("Buy-from Vendor No.", rVend."No.");
                    rCabPed.SETRANGE(rCabPed."Posting Date", CALCDATE('-9M', Rec."Posting Date"), 99991231D);
                    if Page.RUNMODAL(0, rCabPed) = ACTION::LookupOK THEN BEGIN
                        Rec."Customer Order No." := rCabPed."No.";
                        Rec.MODIFY;
                        // {if "Nº Proyecto"<>'PR99-99999' THEN BEGIN
                        //     rJob.CHANGECOMPANY(wEmpresa);
                        //     if rJob.GET("Nº Proyecto") THEN BEGIN
                        //     rContr.CHANGECOMPANY(wEmpresa);
                        //     rContr.SETCURRENTKEY(rContr."Nº Proyecto");
                        //     rContr.SETRANGE(rContr."Nº Proyecto",rJob."No.");
                        //     if rContr.FINDFIRST THEN REPEAT
                        //     rContr."Customer Order No.":=rCabPed."No.";
                        //     rContr.MODIFY;
                        //     UNTIL rContr.NEXT=0;
                        //     r112.CHANGECOMPANY(rIc."Inbox Details");
                        //     r112.SETCURRENTKEY("Nº Proyecto");
                        //     r112.SETRANGE("Nº Proyecto",rJob."No.");
                        //     if r112.FINDFIRST THEN REPEAT
                        //     if "No."<>r112."No." THEN BEGIN
                        //     r112."Customer Order No.":=rCabPed."No.";
                        //     r112.MODIFY;
                        //     END;
                        //     UNTIL r112.NEXT=0;
                        //     r114.CHANGECOMPANY(rIc."Inbox Details");
                        //     r114.SETCURRENTKEY("Nº Proyecto");
                        //     r114.SETRANGE("Nº Proyecto",rJob."No.");
                        //     if r114.FINDFIRST THEN REPEAT
                        //     r114."Customer Order No.":=rCabPed."No.";
                        //     r114.MODIFY;
                        //     UNTIL r114.NEXT=0;
                        //     END;  }
                    END;
                END;
            }
            action("Asignar Albarán")
            {
                ApplicationArea = All;
                Image = Order;
                Caption = 'Asignar Albarán';
                trigger OnAction()
                Var
                    rCabPed: Record "Purch. Rcpt. Header";
                    rIc: Record 413;
                    rInf: Record 79;
                    rVend: Record Vendor;
                    rJob: Record 167;
                    rContr: Record 36;
                    r112: Record 112;
                    r114: Record 114;
                BEGIN
                    //if "Albarán Empresa Origen" <> '' THEN ERROR('Este abono tiene albarán');
                    rIc.SETRANGE(rIc."Inbox Details", wEmpresa);
                    rIc.FINDFIRST;
                    rVend.SETRANGE(rVend."IC Partner Code", rIc.Code);
                    rVend.FINDFIRST;
                    rCabPed.SETRANGE("Buy-from Vendor No.", rVend."No.");
                    rCabPed.SETRANGE(rCabPed."Posting Date", CALCDATE('-9M', Rec."Posting Date"), 99991231D);
                    if Page.RUNMODAL(0, rCabPed) = ACTION::LookupOK THEN BEGIN
                        Rec."Albarán Empresa Origen" := rCabPed."No.";
                        Rec.MODIFY;
                        // {if "Nº Proyecto"<>'PR99-99999' THEN BEGIN
                        //     rJob.CHANGECOMPANY(wEmpresa);
                        //     if rJob.GET("Nº Proyecto") THEN BEGIN
                        //     rContr.CHANGECOMPANY(wEmpresa);
                        //     rContr.SETCURRENTKEY(rContr."Nº Proyecto");
                        //     rContr.SETRANGE(rContr."Nº Proyecto",rJob."No.");
                        //     if rContr.FINDFIRST THEN REPEAT
                        //     rContr."Customer Order No.":=rCabPed."No.";
                        //     rContr.MODIFY;
                        //     UNTIL rContr.NEXT=0;
                        //     r112.CHANGECOMPANY(rIc."Inbox Details");
                        //     r112.SETCURRENTKEY("Nº Proyecto");
                        //     r112.SETRANGE("Nº Proyecto",rJob."No.");
                        //     if r112.FINDFIRST THEN REPEAT
                        //     if "No."<>r112."No." THEN BEGIN
                        //     r112."Customer Order No.":=rCabPed."No.";
                        //     r112.MODIFY;
                        //     END;
                        //     UNTIL r112.NEXT=0;
                        //     r114.CHANGECOMPANY(rIc."Inbox Details");
                        //     r114.SETCURRENTKEY("Nº Proyecto");
                        //     r114.SETRANGE("Nº Proyecto",rJob."No.");
                        //     if r114.FINDFIRST THEN REPEAT
                        //     r114."Customer Order No.":=rCabPed."No.";
                        //     r114.MODIFY;
                        //     UNTIL r114.NEXT=0;
                        //     END;  }
                    END;
                END;
            }


            action("Desasignar Devolucion")
            {
                ApplicationArea = all;
                Scope = Repeater;
                Image = UnApply;
                Caption = 'Desasignar Devolución';
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
                ApplicationArea = all;
                Scope = Repeater;
                Image = AddWatch;
                Caption = 'Marcar Como Contabilizada';
                trigger OnAction()
                var
                    C: Codeunit ControlProcesos;
                BEGIN
                    c.MarcarAbonoComoContabilizada(Rec, False);

                END;
            }
            action("Desmarcar Como Contabilizada")
            {
                ApplicationArea = all;
                Scope = Repeater;
                Image = UnApply;
                Caption = 'Desmarcar Como Contabilizada';
                trigger OnAction()
                var
                    C: Codeunit ControlProcesos;
                BEGIN
                    c.MarcarAbonoComoContabilizada(Rec, true);

                END;
            }



        }
    }
    VAR
        // SalesInvHeader: Record 112;
        rCab2: Record 114;
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
    var
        ConfUser: Record "User Setup";
    begin
        if ConfUser.GET(USERID) THEN BEGIN
            ConfUser."Empresa Facturas" := wEmpresa;
            ConfUser.MODIFY;
        END;

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
    var
        PurchaseHeader: Record 38;
        HistPurchase: Record 124;
    begin
        if Rec."Customer Order No." = '' THEN Color := 'Favorable';
        if Rec."Albarán Empresa Origen" <> '' THEN Color := 'Strong';
        PurchaseHeader.SetRange("Vendor Cr. Memo No.", Rec."No.");
        if PurchaseHeader.FindFirst() Then
            Color := 'StandardAccent';
        HistPurchase.SetRange("Vendor Cr. Memo No.", Rec."No.");
        if HistPurchase.FindFirst() Then
            Color := 'StrongAccent';
    end;

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
        rPed: Record 6651;
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