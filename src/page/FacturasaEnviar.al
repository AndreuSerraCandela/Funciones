/// <summary>
/// Page Facturas a enviar (ID 50012).
/// </summary>
page 50012 "Facturas a enviar"
{

    Permissions = TableData 17 = rimd,
                TableData 112 = rimd,
                TableData 113 = rimd;
    Caption = 'Facturas a enviar';
    SourceTable = "Facturas a Enviar";
    PageType = List;
    UsageCategory = Lists;

    layout
    {
        area(Content)
        {

            repeater(Detalle)
            {
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                    StyleExpr = Color;
                }
                field("Customer Order No."; Rec."Customer Order No.") { ApplicationArea = All; }
                field("Sell-to Customer No."; Rec."Sell-to Customer No.") { ApplicationArea = All; }
                field("Sell-to Customer Name"; Rec."Sell-to Customer Name") { ApplicationArea = All; }
                field("Document Sending Profile"; Rec."Document Sending Profile") { ApplicationArea = All; }
                field("PostingDescription"; Rec."Posting Description") { ApplicationArea = All; }

                field(TextodelContrato; TextoContrato) { ApplicationArea = All; Caption = 'Texto Contrato'; }
                field("Currency Code"; Rec."Currency Code") { ApplicationArea = All; }
                field(Amount; Rec.Amount)
                {
                    ApplicationArea = All;
                    trigger OnDrillDown()
                    BEGIN
                        Rec.SETRANGE(Rec."No.");
                        Page.RUNMODAL(Page::"Posted Sales Invoice", Rec)
                    END;
                }
                field("Amount Including VAT"; Rec."Amount Including VAT")
                {
                    ApplicationArea = All;
                    trigger OnDrillDown()
                    BEGIN
                        Rec.SETRANGE("No.");
                        Page.RUNMODAL(Page::"Posted Sales Invoice", Rec)
                    END;
                }
                field("Payment Method Code"; Rec."Payment Method Code") { ApplicationArea = All; }
                //field("Posting Description";Rec."Posting Description"){ApplicationArea=All; }
                field("Due Date"; Rec."Due Date") { ApplicationArea = All; }
                field("Nº Contrato"; Rec."Nº Contrato") { ApplicationArea = All; }
                field("Sell-to Post Code"; Rec."Sell-to Post Code") { ApplicationArea = All; Visible = false; }
                field("Sell-to Country/Region Code"; Rec."Sell-to Country/Region Code") { ApplicationArea = All; Visible = false; }
                field("Sell-to Contact"; Rec."Sell-to Contact") { ApplicationArea = All; Visible = false; }
                field("Bill-to Customer No."; Rec."Bill-to Customer No.") { ApplicationArea = All; Visible = false; }
                field("Bill-to Name"; Rec."Bill-to Name") { ApplicationArea = All; Visible = false; }
                field("Bill-to Post Code"; Rec."Bill-to Post Code") { ApplicationArea = All; Visible = false; }
                field("Bill-to Country/Region Code"; Rec."Bill-to Country/Region Code") { ApplicationArea = All; Visible = false; }
                field("Bill-to Contact"; Rec."Bill-to Contact") { ApplicationArea = All; Visible = false; }
                field("Ship-to Code"; Rec."Ship-to Code") { ApplicationArea = All; Visible = false; }
                field("Ship-to Name"; Rec."Ship-to Name") { ApplicationArea = All; Visible = false; }
                field("Ship-to Post Code"; Rec."Ship-to Post Code") { ApplicationArea = All; Visible = false; }
                field("Ship-to Country/Region Code"; Rec."Ship-to Country/Region Code") { ApplicationArea = All; Visible = false; }
                field("Ship-to Contact"; Rec."Ship-to Contact") { ApplicationArea = All; }
                field("Posting Date"; Rec."Posting Date") { ApplicationArea = All; }
                field("Salesperson Code"; Rec."Salesperson Code") { ApplicationArea = All; }
                field("Shortcut Dimension 1 Code"; Rec."Shortcut Dimension 1 Code") { ApplicationArea = All; }
                field("Shortcut Dimension 2 Code"; Rec."Shortcut Dimension 2 Code") { ApplicationArea = All; }
                field("Cod cadena"; Rec."Cod cadena") { ApplicationArea = All; }
                field("No. Printed"; Rec."No. Printed") { ApplicationArea = All; }
                field("Pte Contabilicación"; Rec."Pte Contabilicación") { ApplicationArea = All; }
                field("Pte verificar"; Rec."Pte verificar") { ApplicationArea = All; }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            group("&Factura")
            {
                Caption = '&Factura';
                action(Ficha)
                {
                    ApplicationArea = all;
                    Scope = Repeater;
                    Image = Card;
                    ShortCutKey = 'Mayús+F5';
                    Caption = 'Ficha';
                    trigger OnAction()
                    VAR
                        r112: Record 112;
                    BEGIN
                        r112.GET(Rec."No.");
                        Page.Run(PAGE::"Posted Sales Invoice", r112)
                    END;
                }
                action("Enviar Facturas")
                {
                    ApplicationArea = all;
                    Scope = Repeater;
                    Image = "Invoicing-MailSent";
                    Caption = 'Enviar Facturas';
                    trigger OnAction()
                    VAR
                        rFac: Record "Facturas a Enviar";
                        cPdf: Codeunit "Funciones Correo PDF";
                        Customer: Record Customer;
                        r112t: Record 112 TEMPORARY;
                        r112: Record 112;
                        r114: Record 114;
                    BEGIN
                        CurrPage.SETSELECTIONFILTER(rFac);
                        r112.CLEARMARKS();
                        if rFac.FINDFIRST THEN
                            REPEAT
                                if rFac."Tipo Documento" = rFac."Tipo Documento"::Invoice THEN BEGIN
                                    r112.GET(rFac."No.");
                                    r112.MARK := TRUE;
                                END;
                                if rFac."Tipo Documento" = rFac."Tipo Documento"::"Credit Memo" THEN BEGIN
                                    r114.GET(rFac."No.");
                                    r114.MARK := TRUE;
                                END;
                            UNTIL rFac.NEXT = 0;
                        CLEAR(cPdf);
                        r112.MARKEDONLY := TRUE;
                        cPdf.AgrupaPDF(r112, FALSE);
                        r114.MARKEDONLY := TRUE;
                        cPdf.AgrupaAbonoPDF(r114, FALSE);
                        rFac.DELETEALL;
                    END;
                }
                action("Eliminar Seleccionadas")
                {
                    ApplicationArea = all;
                    Scope = Repeater;
                    Image = Undo;
                    Caption = 'Eliminar Seleccionadas';
                    trigger OnAction()
                    VAR
                        rFac: Record "Facturas a Enviar";
                    BEGIN
                        CurrPage.SETSELECTIONFILTER(rFac);
                        rFac.DELETEALL;
                    END;
                }
            }
        }
        area(Navigation)
        {
            action("&Navegar")
            {
                Caption = '&Navegar';
                trigger OnAction()
                VAR
                    r112: Record 112;
                BEGIN
                    r112.GET(Rec."No.");
                    r112.Navigate;
                END;
            }
        }
        area(Reporting)
        {
            action("&Imprimir")
            {
                ApplicationArea = all;
                Scope = Repeater;
                Image = PrintDocument;
                trigger OnAction()
                BEGIN
                    SalesInvHeader.SETRANGE(SalesInvHeader."No.", Rec."No.");
                    SalesInvHeader.PrintRecords(TRUE);
                END;
            }
        }
    }

    VAR
        SalesInvHeader: Record 112;
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
        Text003: label '%1 no debe ser 0.';
        Text004: Label '%1 no debe ser más grande de %2';
        Text005: Label 'No puede cambiar el dto. factura porque hay un %1 registro para %2 %3.';
        rPed: Record 38;
        rCab: Record 38;
        Color: Text;

    trigger OnAftergetRecord()
    Begin

        if Rec."Customer Order No." = '' THEN Color := 'Favorable';
        if Rec."Albarán Empresa Origen" <> '' THEN Color := 'Strong';
    End;

    LOCAL PROCEDURE UpdateTotalAmount(TotalAmount: Decimal);
    VAR
        SaveTotalAmount: Decimal;
    BEGIN
        //CheckAllowInvDisc;
        if Rec."Prices Including VAT" THEN BEGIN
            SaveTotalAmount := TotalAmount1;
            UpdateInvDiscAmount;
            TotalAmount1 := SaveTotalAmount;
        END;

        WITH TotalPurchLine DO
            "Inv. Discount Amount" := "Line Amount" - TotalAmount1;
        UpdateInvDiscAmount;
    END;

    LOCAL PROCEDURE UpdateInvDiscAmount();
    VAR
        InvDiscBaseAmount: Decimal;
    BEGIN
        //CheckAllowInvDisc;
        InvDiscBaseAmount := TempVATAmountLine.GetTotalInvDiscBaseAmount(FALSE, Rec."Currency Code");
        if InvDiscBaseAmount = 0 THEN
            ERROR(Text003, TempVATAmountLine.FIELDCAPTION("Inv. Disc. Base Amount"));

        if TotalPurchLine."Inv. Discount Amount" / InvDiscBaseAmount > 1 THEN
            ERROR(
              Text004,
              TotalPurchLine.FIELDCAPTION("Inv. Discount Amount"),
              TempVATAmountLine.FIELDCAPTION("Inv. Disc. Base Amount"));

        TempVATAmountLine.SetInvoiceDiscountAmount(
          TotalPurchLine."Inv. Discount Amount", Rec."Currency Code", Rec."Prices Including VAT", Rec."VAT Base Discount %");

        rCab."Invoice Discount Calculation" := rCab."Invoice Discount Calculation"::Amount;
        rCab."Invoice Discount Value" := TotalPurchLine."Inv. Discount Amount";
        rCab.MODIFY;
        UpdateVATOnPurchLines;
    END;

    LOCAL PROCEDURE UpdateVATOnPurchLines();
    VAR
        PurchLine: Record 39;
    BEGIN
        GetVATSpecification;
        if TempVATAmountLine.GetAnyLineModified THEN BEGIN
            PurchLine.UpdateVATOnLines(0, rCab, PurchLine, TempVATAmountLine);
            PurchLine.UpdateVATOnLines(1, rCab, PurchLine, TempVATAmountLine);
        END;
    END;

    LOCAL PROCEDURE GetVATSpecification();
    BEGIN
    END;

    PROCEDURE TextoContrato(): Text[100];
    VAR
        rContr: Record 36;
    BEGIN
        if rContr.GET(rContr."Document Type"::Order, Rec."Nº Contrato") THEN BEGIN
            if rContr."Nº pedido" = '' THEN
                EXIT(rContr."Posting Description");
            EXIT(rContr."Nº pedido");
        END;
    END;

    //     BEGIN
    //     {
    //       $001 FCL-050710. Aplico filtros por vendedor definidos en la tabla de usuarios.
    //     }
    //     END.
    //   }
}

