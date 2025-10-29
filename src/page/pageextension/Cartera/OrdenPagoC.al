pageextension 80196 OrdenPagoC extends "Closed Payment Orders"
{
    actions
    {
        addafter("&Navigate")
        {
            action("Comprobar Importe Pendiente")
            {
                ApplicationArea = all;
                Image = ApplyEntries;
                trigger OnAction()
                var
                    Mov: Record "Mov. emplazamientos";
                    Docs: Record "Closed Cartera Doc.";
                    a: Integer;
                    b: Integer;
                begin
                    Docs.SetRange("Bill Gr./Pmt. Order No.", Rec."No.");
                    b := Docs.Count;
                    if Docs.FindFirst() Then
                        repeat
                            Mov.SetRange("Nº Factura definitivo", Docs."Document No.");
                            if Mov.FindFirst() Then
                                repeat
                                    Mov.Validate("Importe pendiente", 0);
                                    Mov.Modify();
                                    a += 1;
                                until Mov.Next() = 0;
                        until Docs.Next() = 0;
                    Message(StrSubstNo('Se han actualizado %1 mov. en un total de %2 documentos de cartera', a, b));
                end;
            }
        }
    }
}