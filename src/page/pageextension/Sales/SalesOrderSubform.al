/// <summary>
/// PageExtension SalesOrderSubform (ID 80139) extends Record Sales Order Subform.
/// </summary>
pageextension 80139 SalesOrderSubform extends "Sales Order Subform"
{

    layout
    {
        modify(Quantity)
        {
            Visible = false;
        }
        addbefore("Unit of Measure Code")
        {
            field("Tipo Duracion"; Rec."Tipo Duracion") { ApplicationArea = All; }
            field("Fecha inicial recurso"; Rec."Fecha inicial recurso") { ApplicationArea = All; }
            field("Fecha final recurso"; Rec."Fecha final recurso") { ApplicationArea = All; }
            field(Duracion; Rec.Duracion) { ApplicationArea = All; }
            field("Cdad. Soportes"; Rec."Cdad. Soportes") { ApplicationArea = All; }

        }
        addbefore("Unit Price")
        {
            field("Precio Tarifa"; Rec."Precio Tarifa") { ApplicationArea = All; }
            field("Dto. Tarifa"; Rec."Dto. Tarifa") { ApplicationArea = All; }
        }
        addafter("Unit Price")
        {
            field("% Dto. Volumen"; Rec."% Dto. Venta 1") { ApplicationArea = All; }
            field("% Dto. Agencia"; Rec."% Dto. Venta 2") { ApplicationArea = All; }
        }
        modify("Line Discount %")
        {
            Visible = false;
        }
        //modifica el campo numero con un estilo en funcion de si el recurso es agrupado o no
        modify("No.")
        {
            StyleExpr = Color;
        }
        addafter("No.")
        {
            field("No Orden Recurso"; Rec."No Orden Recurso") { ApplicationArea = All; Editable = false; }
            field("No. Orden Publicidad"; Rec."No. Orden Publicidad")
            {
                ApplicationArea = All;
                trigger OnLookup(var Text: Text): Boolean
                BEGIN
                    OrdenesPubli;
                END;
            }
            //  field("Cross-Reference No.";Rec."Cross-Reference No."){ApplicationArea=All;Visible=False;
            //  trigger OnLookup(var Text: Text): Boolean BEGIN
            //             CrossReferenceNoLookUp;
            //             InsertExtendedText(FALSE);
            //           END;

            //  trigger OnValidate() BEGIN
            //                    InsertExtendedText(FALSE);
            //                  END;
            //                   }
            // field("IC Partner Code";Rec. ){ApplicationArea=All;Visible=False;}
            // field("IC Partner Ref. Type";Rec. ){ApplicationArea=All;Visible=False;}
            // field("IC Partner Reference";Rec. ){ApplicationArea=All;Visible=False;}
            // field("Variant Code";Rec. ){ApplicationArea=All;Visible=False;}
            //field("Substitution Available";Rec. ){ApplicationArea=All;Visible=False;}
            //field("Purchasing Code";Rec. ){ApplicationArea=All;Visible=False;}
        }

        addafter(Description)
        {

            //field("Description 2"; Rec."Description 2") { ApplicationArea = All; }
            field(Medidas; Rec.Medidas) { ApplicationArea = All; }
            field(Imprimir; Rec.Imprimir) { ApplicationArea = All; }

        }
        modify("Description 2")
        {
            Visible = true;
        }
        addafter("Inv. Discount Amount")
        {
            field("Linea Marcada a Borrador"; Rec."Linea Marcada a Borrador") { ApplicationArea = All; }
            field("Cantidad a Borrador"; Rec."Cantidad a Borrador") { ApplicationArea = All; }
            field("Cantidad pasada Borrador"; Rec."Cantidad pasada Borrador") { ApplicationArea = All; }
        }
        addafter(ShortcutDimCode8)
        {
            field("Job No."; Rec."Job No.") { ApplicationArea = All; }
            field("Job Task No."; Rec."Job Task No.") { Caption = 'Tarea'; ApplicationArea = All; }
            field(Reparto; Rec.Reparto) { ApplicationArea = All; }
            field("No linea proyecto"; Rec."No linea proyecto")
            {
                ApplicationArea = All;
                trigger OnValidate()

                BEGIN
                    if xRec."No linea proyecto" <> 0 THEN ERROR('No se puede cambiar la línea si esta no era 0');
                    SalesHeader.GET(Rec."Document Type", Rec."Document No.");
                    SalesHeader.CALCFIELDS(SalesHeader."Borradores de Factura");
                    if SalesHeader."Borradores de Factura" > 0 THEN ERROR('No se puede cambiar la linea porque ya hay borradores de factura');
                END;
            }
            field("Imprimir fecha recurso"; Rec."Imprimir fecha recurso")
            {
                ApplicationArea = All;
                trigger OnValidate()
                begin
                    CurrPage.UPDATE(false);
                end;
            }
            field("Imprimir Nº recurso"; Rec."Imprimir Nº recurso")
            {
                ApplicationArea = All;
                trigger OnValidate()
                begin
                    CurrPage.UPDATE(false);
                end;
            }
            field(Remarcar; Rec.Remarcar) { ApplicationArea = All; }

        }
        modify("Prepayment %")
        {
            Editable = false;
        }
        modify("Prepmt. Line Amount")
        {
            Editable = false;
        }
        modify("Prepmt. Amt. Inv.")
        {
            Editable = false;
        }

    }
    actions
    {
        addafter("&Line")
        {
            action("&Texto ampliado línea")
            {
                ApplicationArea = All;
                Image = Text;
                Scope = Repeater;
                ShortcutKey = F10;
                trigger OnAction()
                begin
                    LlamaTexto;
                end;
            }
        }
    }
    VAR
        SalesHeader: Record 36;
        // SalesPriceCalcMgt: Codeunit 7000;
        TransferExtendedText: Codeunit 378;
        SalesInfoPaneMgt: Codeunit 7171;
        ShortcutDimCode: ARRAY[8] OF Code[20];
        Color: Text;

    trigger OnAfterGetRecord()
    var
        Res: Record Resource;
    begin
        Color := 'Standard';
        if Rec.Type = Rec.Type::Resource THEN BEGIN
            if Not Res.GET(Rec."No.") then Res.Init();
            if Res."Recurso Agrupado" THEN
                Color := 'Unfavorable'
            ELSE
                if Res."Producción" then Color := 'Favorable';

        END;
    end;

    PROCEDURE LlamaTexto();
    BEGIN
        Rec.FiltroTexto;
    END;

    PROCEDURE OrdenesPubli();
    VAR
        rOrden: Record "Cab. orden publicidad";
        rProyecto: Record 167;
    BEGIN
        rOrden.RESET;
        rOrden.SETCURRENTKEY("Nº proyecto", "Nº tarea proyecto", "Nº linea");
        //$001(I)
        if Rec."No. Orden Publicidad" <> '' THEN BEGIN
            rOrden.SETRANGE(No, Rec."No. Orden Publicidad");
        END
        ELSE BEGIN
            //$001(F)
            rOrden.SETRANGE("Nº proyecto", Rec."Job No.");
            rOrden.SETRANGE("Nº tarea proyecto", Rec."Job Task No.");
            rOrden.SETRANGE("Nº linea", Rec."Line No.");         //en este caso no tengo nº línea proyecto
                                                                 //$001(I)
        END;
        if (rOrden.FINDFIRST) AND (Rec."No. Orden Publicidad" = '') THEN
            Rec.VALIDATE("No. Orden Publicidad", rOrden.No);
        //$001(F)

        Page.RUNMODAL(Page::"Orden de publicidad", rOrden);

        CurrPage.UPDATE;
    END;

}

