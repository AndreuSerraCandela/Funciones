pageextension 80183 PostedSalesShps extends "Posted Sales Shipments"
{
    layout
    {
        addafter("Salesperson Code")
        {
            field("Nº Contrato"; Rec."Nº Contrato")
            {
                ApplicationArea = all;
            }
            field("Nº Proyecto"; Rec."Nº Proyecto")
            {
                ApplicationArea = all;
            }
            field("Importe Iva Incl."; Import(true))
            {
                ApplicationArea = All;
            }
            field(Importe; Import(False))
            {
                ApplicationArea = All;
            }
        }

    }


    trigger OnOpenPage();
    begin
        Rec.Setrange("Albarán Venta", true);
    end;

    local procedure Import(arg: Boolean): Decimal
    var
        Line: Record "Sales Shipment Line";
        Suma: Decimal;
    begin
        // suma lineas Albaran
        Suma := 0;
        Line.Setrange("Document No.", Rec."No.");
        if Line.Findset then
            repeat
                if arg then
                    Suma += Line."Amount Including VAT"
                else
                    Suma += Line."Amount";
            until Line.Next = 0;

    end;

}