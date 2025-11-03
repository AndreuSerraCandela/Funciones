page 50043 "Lista Líneas Factura"
{
    Caption = 'Lista Lineas Factura';
    Editable = false;
    PageType = List;
    SourceTable = "Sales Invoice Line";


    layout
    {
        area(Content)
        {
            repeater(Detalle)
            {
                field("Posting Date"; Rec."Posting Date") { ApplicationArea = All; }
                field("Document No."; Rec."Document No.") { ApplicationArea = All; }
                field("Job No."; Rec."Job No.") { ApplicationArea = All; }
                field(Contrato; Contrato) { ApplicationArea = All; }

                field(Intercambio; Interc) { ApplicationArea = All; Caption = 'Intercambio/Compensación'; }
                field("Venta a número cliente"; Rec."Sell-to Customer No.") { ApplicationArea = All; }
                field("Número Lína"; Rec."Line No.") { ApplicationArea = All; }
                field(Tipo; Rec.Type) { ApplicationArea = All; }
                field("No."; Rec."No.") { ApplicationArea = All; }
                field("Texto de Registro"; TextoRegistro) { ApplicationArea = All; }
                field("Descripción"; Rec.Description) { ApplicationArea = All; }
                field("Descripción 2"; Rec."Description 2") { ApplicationArea = All; }
                field("Precio"; Rec."Unit Price") { ApplicationArea = All; }
                field("% Descuento"; Rec."Line Discount %") { ApplicationArea = All; }
                field(Importe; Rec.Amount) { ApplicationArea = All; }
                field("Importe Incluido Iva"; Rec."Amount Including VAT") { ApplicationArea = All; }

            }
        }
    }

    Var
        Interc: Option " ",Intercambio,Compensación;
        Factura: Record 112;
        Abono: Record 114;
        TextoRegistro: Text[100];
        Contrato: Code[20];

    PROCEDURE Inter(VAR Inte: Option " ",Intercambio,Compensación): Integer;
    VAR
        rJob: Record 167;
    BEGIN
        if rJob.GET(Rec."Job No.") THEN Inte := (rJob."Interc./Compens.".AsInteger());
    END;

    trigger OnAfterGetRecord()
    BEGIN
        Inter(Interc);
        TextoRegistro := '';
        Contrato := '';
        if Factura.GET(Rec."Document No.") THEN BEGIN
            //  Factura.CALCFIELDS(Factura."Nº Contrato");
            TextoRegistro := Factura."Posting Description";
            Contrato := Factura."Nº Contrato";
        END ELSE BEGIN
            if Abono.GET(Rec."Document No.") THEN BEGIN
                //  Abono.CALCFIELDS(Abono."Nº Contrato");
                TextoRegistro := Abono."Posting Description";
                Contrato := Abono."Nº Contrato";
            END;
        END;
    END;
}
