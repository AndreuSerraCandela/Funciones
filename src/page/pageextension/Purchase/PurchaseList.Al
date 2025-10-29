
/// <summary>
/// PageExtension PurchaseList (ID 80208).
/// </summary>
pageextension 80201 PurchaseList Extends "Purchase List"
{
    layout
    {
        modify("No.")
        {
            trigger OnDrillDown()
            var
                PageManagement: Codeunit "Page Management";
            begin
                PageManagement.PageRun(Rec);
            end;
        }
        modify("Posting Date") { Visible = true; }
        addafter("Order Address Code")
        {
            field("Nº Proyecto"; Rec."Nº Proyecto") { ApplicationArea = All; }
            field("Factura recibida"; Rec."Factura recibida") { ApplicationArea = All; }
            field("Expected Receipt Date"; Rec."Expected Receipt Date") { ApplicationArea = All; }
            field("Order Date"; Rec."Order Date") { ApplicationArea = All; }
            field("Nº Contrato Venta"; Rec."Nº Contrato Venta") { ApplicationArea = All; }
            field("Cód. cliente venta"; Rec."Cód. cliente venta") { ApplicationArea = All; }
            field("Nombre Cliente Venta"; Rec."Nombre Cliente Venta") { ApplicationArea = All; }
            field("Nombre 2 Cliente Venta"; Rec."Nombre 2 Cliente Venta") { ApplicationArea = All; }
            field("Posting Description"; Rec."Posting Description") { ApplicationArea = All; }
            field("Descripcion proyecto"; Rec."Descripcion proyecto") { ApplicationArea = All; }
#if not CLEAN27
            field(Amount; Rec.Amount) { ApplicationArea = All; }
            field("Amount Including VAT"; Rec."Amount Including VAT") { ApplicationArea = All; }
#endif
            field(CalcularTotales; CalcularTotales(Rec."No.", 1))
            {
                ApplicationArea = All;
                Caption = 'Importe';
            }
            field(CalcularTotales2; CalcularTotales(Rec."No.", 2))
            {
                ApplicationArea = All;
                Caption = 'Importe IVA incl. (calc.)';
            }
            field(CalcularTotales3; CalcularTotales(Rec."No.", 3))
            {
                ApplicationArea = All;
                Caption = 'Importe Pendiente';
            }
        }
    }
    actions
    {

        addfirst("&Line")
        {
            action("Relación Vta")
            {
                ApplicationArea = All;
                Image = Sales;
                Caption = 'Relación Vta';
                trigger OnAction()
                BEGIN
                    CLEAR(fVenta);
                    rCab.RESET;
                    rCab.SETCURRENTKEY(rCab."Nº Proyecto");
                    rCab.SETRANGE("Nº Proyecto", Rec."Nº Proyecto");
                    fVenta.SETTABLEVIEW(rCab);
                    fVenta.RUNMODAL;
                END;
            }
            action("Eliminar Seleccionados")
            {
                ApplicationArea = All;
                Image = DeleteRow;
                Caption = 'Eliminar Seleccionados';
                trigger OnAction()
                VAR
                    PurchHeader: Record 38;
                    PurchLine: Record 39;
                    PurchHeaderT: Record 38 TEMPORARY;
                    Utilidades: Codeunit Utilitis;
                BEGIN
                    if not Utilidades.PermisoAdm() THEN ERROR('No tiene permisos');
                    CurrPage.SETSELECTIONFILTER(PurchHeader);
                    if PurchHeader.FINDFIRST THEN
                        REPEAT
                            // if CalcularTotales(PurchHeader."No.",1)=0 THEN BEGIN
                            PurchLine.SETRANGE(PurchLine."Document Type", PurchHeader."Document Type");
                            PurchLine.SETRANGE(PurchLine."Document No.", PurchHeader."No.");
                            PurchLine.DELETEALL;
                            PurchHeaderT := PurchHeader;
                            PurchHeaderT.INSERT;
                        // END;
                        UNTIL PurchHeader.NEXT = 0;
                    PurchHeader.RESET;
                    if PurchHeaderT.FINDFIRST THEN
                        REPEAT
                            if PurchHeader.GET(PurchHeaderT."Document Type", PurchHeaderT."No.") THEN PurchHeader.DELETE;
                        UNTIL PurchHeaderT.NEXT = 0;
                END;
            }
            action("Im&primir todo")
            {
                ApplicationArea = All;
                Caption = 'Im&primir todo';
                Image = Print;
                trigger OnAction()
                BEGIN
                    // $001
                    rConf.GET();
                    if rConf."Impr. Ped. Compra asociado Cto" THEN BEGIN
                        rCabV.RESET;
                        CLEAR(rCabV);
                        rCabV.SETCURRENTKEY("Nº Proyecto");
                        rCabV.SETRANGE("Nº Proyecto", Rec."Nº Proyecto");
                        rCabV.SETRANGE("Document Type", rCabV."Document Type"::Order);
                        if rCabV.FINDSET THEN
                            if (rCabV.Estado <> rCabV.Estado::Firmado) THEN
                                ERROR(Text003, rCabV."No.");
                    END;
                    rCab2.SETRANGE("Nº Proyecto", Rec."Nº Proyecto");
                    REPORT.RUNMODAL(REPORT::Order, TRUE, FALSE, rCab2);
                END;
            }
        }
        addlast(Promoted)
        {

            actionref(Ficha; "ShowDocument") { }




        }
    }

    VAR
        rCab: Record 36;
        rCab2: Record 38;
        rCabV: Record 36;
        rConf: Record 315;
        fVenta: Page "Lista docs. vta. relacionados";
        DimMgt: Codeunit 408;
        wTexto: Text[30];
        Text003: Label 'No pueden imprimirse estos Pedidos de Compra ya que el Contrato %1 no esta Firmado.';
        Empresa: Text[30];

    PROCEDURE CalcularTotales(pNumDoc: Code[20]; Tipo: Integer): Decimal;
    VAR
        TempPurchLine: Record 39 TEMPORARY;
        r39: Record 39;
        TotalPurchLine: Record 39;
        TotalPurchLineLCY: Record 39;
        RegisCompras: Codeunit 90;
        wDecimal: Decimal;
        TotalPurchLineT: Record 39 TEMPORARY;
    BEGIN
        //FCL-07/10/04. Obtengo total y total iva incluído, no sirve el campo calculado
        // del standard porque estos importes están a cero en las líneas.
        CLEAR(TotalPurchLine);
        CLEAR(TotalPurchLineLCY);
        CLEAR(TempPurchLine);
        TotalPurchLineT.DELETEALL;
        if Empresa <> COMPANYNAME THEN
            r39.CHANGECOMPANY(Empresa);
        r39.SETRANGE(r39."Document Type", Rec."Document Type");
        r39.SETRANGE(r39."Document No.", pNumDoc);
        if r39.FINDFIRST THEN
            REPEAT
                TempPurchLine := r39;
                TempPurchLine.Amount := (TempPurchLine.Quantity * TempPurchLine."Direct Unit Cost" *
                (1 - TempPurchLine."Line Discount %" / 100));
                TempPurchLine."Amount Including VAT" := TempPurchLine.Amount * (1 + TempPurchLine."VAT %" / 100);
                TempPurchLine."Outstanding Amount" := (TempPurchLine."Outstanding Quantity" * TempPurchLine."Direct Unit Cost" *
                (1 - TempPurchLine."Line Discount %" / 100)) * (1 + TempPurchLine."VAT %" / 100);
                if TempPurchLine.INSERT THEN;
                if NOT TotalPurchLineT.GET(TempPurchLine."Document Type", TempPurchLine."Document No.", 0) THEN BEGIN
                    TotalPurchLineT := TempPurchLine;
                    TotalPurchLineT."Line No." := 0;
                    TotalPurchLineT.INSERT;
                END ELSE BEGIN
                    TotalPurchLineT.Amount += TempPurchLine.Amount;
                    TotalPurchLineT."Amount Including VAT" += TempPurchLine."Amount Including VAT";
                    TotalPurchLineT."Outstanding Amount" += (TempPurchLine."Outstanding Quantity" * TempPurchLine."Direct Unit Cost" *
                     (1 - TempPurchLine."Line Discount %" / 100)) * (1 + TempPurchLine."VAT %" / 100);
                    TotalPurchLineT.MODIFY;
                END;
            UNTIL r39.NEXT = 0;
        if Tipo = 1 THEN EXIT(TotalPurchLineT.Amount);
        if Tipo = 2 THEN EXIT(TotalPurchLineT."Amount Including VAT");
        if Tipo = 3 THEN EXIT(TotalPurchLineT."Outstanding Amount");
    END;

    PROCEDURE CambiaEmpresa(pEmpresa: Text[30]);
    BEGIN
        Empresa := pEmpresa;
        Rec.CHANGECOMPANY(pEmpresa);
    END;
    //     BEGIN
    //     {
    //       $001 MNC 171209  No poder imprimir los pedidos de compra si el estado del contrato no es Firmado
    //     }
    //     END.
    //   }
}
