/// <summary>
/// PageExtension PurchaseOrderSubPage (ID 80209).
/// </summary>
pageextension 80202 PurchaseOrderSubPage Extends "Purchase Order Subform"
{
    layout
    {
        modify("No.")
        {
            // trigger OnLookup(var Text: Text): Boolean
            // var
            //     ResourceList: Page "Resource List";
            //     Resource: Record Recurso;
            // begin
            //     if Rec.Type = Rec.Type::Resource Then begin
            //         if ResourceList.RunModal() = Action::LookupOK Then begin
            //             Rec.Validate("No.", ResourceList.CambiaEmpresa());
            //         end;
            //     end;
            // end;

            trigger OnAfterValidate()
            BEGIN
                InsertExtendedText(FALSE);
                if (Rec.Type = Rec.Type::"Charge (Item)") AND (Rec."No." <> xRec."No.") AND
                    (xRec."No." <> '')
                THEN
                    CurrPage.SAVERECORD;
            END;
        }
        modify("Line Discount %")
        {
            ApplicationArea = All;
            Visible = true;
        }
        modify("VAT Prod. Posting Group")
        {
            ApplicationArea = All;
            Visible = true;
        }
        modify(ShortcutDimCode3)
        {
            ApplicationArea = All;
            Visible = true;

        }
        modify(ShortcutDimCode4)
        {
            ApplicationArea = All;
            Visible = true;

        }
        modify(ShortcutDimCode5)
        {
            ApplicationArea = All;
            Visible = true;

        }
        modify("Item Reference No.")
        {
            trigger OnLookup(var Text: Text): Boolean
            BEGIN

                //CrossReferenceNoLookUp;
                InsertExtendedText(FALSE);
            END;

            trigger OnAfterValidate()
            BEGIN
                InsertExtendedText(FALSE);
            END;
        }
        // addafter("No.")
        // {
        //     field("IC Partner Code";Rec."IC Partner Code"){ApplicationArea=All;}
        //     field("IC Partner Ref. Type";Rec."IC Partner Ref. Type"){ApplicationArea=All;}
        //     field("IC Partner Reference";Rec."IC Partner Reference"){ApplicationArea=All;}
        // }
        addafter("Variant Code")
        {
            //field("Gen. Prod. Posting Group"; Rec."Gen. Prod. Posting Group") { ApplicationArea = All; }
            //    field("VAT Prod. Posting Group";Rec."VAT Prod. Posting Group"){ApplicationArea=All;}
            field("Fecha inicial recurso"; Rec."Fecha inicial recurso") { ApplicationArea = All; }
            field("Fecha final recurso"; Rec."Fecha final recurso") { ApplicationArea = All; }
        }
        addafter(Description)
        {
            // field("Description 2"; Rec."Description 2") { ApplicationArea = All; }
        }
        modify("Description 2")
        {
            Visible = true;
        }
        addafter(Quantity)
        {
            field("Cantidad a Imprimir"; Rec."Cantidad a Imprimir") { ApplicationArea = All; }
            field("No imprimir"; Rec."No imprimir") { ApplicationArea = All; }
        }
        addafter(ShortcutDimCode8)
        {
            field(JobNo; Rec."Job No.") { ApplicationArea = All; }
            field("Tipo sit. inmueble SII"; Rec."Tipo sit. inmueble SII") { ApplicationArea = All; }
            field("Ref. catastral inmueble SII"; Rec."Ref. catastral inmueble SII") { ApplicationArea = All; }
            field(JobTaskNo; Rec."Job Task No.") { ApplicationArea = All; }
        }
    }
    VAR
        rCabCompra: Record 38;
        TransferExtendedText: Codeunit 378;
        ShortcutDimCode: ARRAY[8] OF Code[20];
        PurchInfoPaneMgt: Codeunit 7181;
        PurchHeader: Record 38;
        //PurchPriceCalcMgt: Codeunit 7010;
        wImporte: Decimal;
        wImpIvaInc: Decimal;
        ControldeProcesos: Codeunit ControlProcesos;

    PROCEDURE CalcInvDisc();
    BEGIN
        CODEUNIT.RUN(CODEUNIT::"Purch.-Calc.Discount", Rec);
    END;

    PROCEDURE ExplodeBOM();
    BEGIN
        CODEUNIT.RUN(CODEUNIT::"Purch.-Explode BOM", Rec);
    END;

    PROCEDURE OpenSalesOrderForm();
    VAR
        SalesHeader: Record 36;
        SalesOrder: Page 42;
    BEGIN
        Rec.TESTFIELD("Sales Order No.");
        SalesHeader.SETRANGE("No.", Rec."Sales Order No.");
        SalesOrder.SETTABLEVIEW(SalesHeader);
        SalesOrder.EDITABLE := FALSE;
        SalesOrder.RUN;
    END;

    // PROCEDURE InsertExtendedText(Unconditionally: Boolean);
    // BEGIN
    //     if TransferExtendedText.PurchCheckIfAnyExtText(Rec, Unconditionally) THEN BEGIN
    //         CurrPage.SAVERECORD;
    //         TransferExtendedText.InsertPurchExtText(Rec);
    //     END;
    //     if TransferExtendedText.MakeUpdate THEN
    //         UpdateForm(TRUE);
    // END;

    // PROCEDURE ShowReservation();
    // BEGIN
    //     FIND;
    //     Rec.ShowReservation;
    // END;

    PROCEDURE LlamaTexto();
    BEGIN
        Rec.FiltroTexto;
    END;

    PROCEDURE CalcularTotales();
    BEGIN
        // CalcularTotales. FCL-24/05/04.
        // De momento calcularé totales sólo para tipo Iva Normal.
        // No sé si los cálculos son muy correctos
        wImpIvaInc := 0;
        if Rec."VAT Calculation Type" = Rec."VAT Calculation Type"::"Normal VAT" THEN BEGIN
            if rCabCompra.GET(Rec."Document Type", Rec."Document No.") THEN BEGIN
                wImporte := ROUND(Rec.Quantity * Rec."Direct Unit Cost");
                wImporte := wImporte - ROUND(wImporte * Rec."Line Discount %" / 100);
                wImporte := ROUND(wImporte * (1 - rCabCompra."VAT Base Discount %" / 100), 0.00001);
                wImpIvaInc := ROUND(wImporte + wImporte * Rec."VAT %" / 100, 0.00001);
            END;
        END;
    END;

    PROCEDURE VerOrdenPub();
    VAR
        rCabOrd: Record "Cab. orden publicidad";
        fOrdPub: Page "Orden de Publicidad";// 7010656;
    BEGIN
        rCabOrd.RESET;
        if rCabOrd.GET(Rec."No. Orden Publicidad") THEN BEGIN
            CLEAR(fOrdPub);
            fOrdPub.SETTABLEVIEW(rCabOrd);
            fOrdPub.SETRECORD(rCabOrd);
            fOrdPub.EDITABLE(FALSE);
            fOrdPub.RUN;
            //Page.RUN(7010656,rCabOrd);
        END;
    END;
    //     BEGIN
    //     {
    //       $001 FCL 040510  Incluyo un punto para ver la orden de publicidad correspondiente a la línea
    //     }
    //     END.
    //   }
}