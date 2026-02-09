pageextension 80143 SalesInvoSubform extends "Sales Invoice Subform"
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
        addafter(Description)
        {

            //field("Description 2"; Rec."Description 2") { ApplicationArea = All; }
            field(Medidas; Rec.Medidas) { ApplicationArea = All; }

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
            field(Reparto; Rec.Reparto) { ApplicationArea = All; }
            // field("Fecha inicial recurso"; Rec."Fecha inicial recurso") { ApplicationArea = All; }
            // field("Fecha final recurso"; Rec."Fecha final recurso") { ApplicationArea = All; }

            field("Ref. catastral inmueble SII"; Rec."Ref. catastral inmueble SII")
            {
                ApplicationArea = All;


            }
            field(Remarcar; Rec.Remarcar) { ApplicationArea = All; }
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
                ShortcutKey = F10;
                trigger OnAction()
                begin
                    LlamaTexto;
                end;
            }
            action("Asignar Producción")
            {
                Image = AssemblyOrder;
                ApplicationArea = all;
                Caption = 'Asignar Producción';
                trigger OnAction()
                Var
                    rDet: Record 1003;
                    SalesHeader: Record "Sales Header";
                    Control: Codeunit "ControlProcesos";
                BEGIN
                    SalesHeader.Get(Rec."Document Type", Rec."Document No.");
                    If Rec."Job No." = '' Then Rec."Job No." := SalesHeader."Nº Proyecto";
                    rDet.SetRange("Job No.", Rec."Job No.");
                    rDet.SetRange("Line No.", Rec."No linea proyecto");
                    rDet.FindFirst();
                    Control.Produccion(rDet);
                END;
            }
        }
    }
    VAR
        SalesHeader: Record 36;
        // SalesPriceCalcMgt: Codeunit 7000;
        TransferExtendedText: Codeunit 378;
        SalesInfoPaneMgt: Codeunit 7171;

        VATAmount: Decimal;
        ShortcutDimCode: ARRAY[8] OF Code[20];
        IsFoundation: Boolean;




    PROCEDURE LlamaTexto();
    BEGIN
        Rec.FiltroTexto;
    END;


}