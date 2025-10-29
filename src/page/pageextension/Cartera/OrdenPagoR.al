pageextension 80195 OrdenPagoR extends "Posted Payment Orders"
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
                    Movt: Record "Mov. emplazamientos" temporary;
                    Docs: Record "Posted Cartera Doc.";
                begin
                    Docs.SetRange("Bill Gr./Pmt. Order No.", Rec."No.");
                    if Docs.FindFirst() Then
                        repeat
                            Mov.SetRange("Nº Factura definitivo", Docs."Document No.");
                            if Mov.FindFirst() Then
                                repeat
                                    if Mov."Importe pendiente" <> 0 then
                                        Mov."Importe pagado" += Mov."Importe pendiente";
                                    mov."Importe Pendiente S/Iva" := 0;
                                    mov."Importe pendiente" := 0;
                                    Mov.Modify();
                                    Movt := Mov;
                                    If Movt.Insert() then;
                                until Mov.Next() = 0;
                        until Docs.Next() = 0;
                    Commit();
                    Page.runmodal(0, Movt);
                end;
            }
            action(Cerrar)
            {
                ApplicationArea = All;
                Image = Close;
                trigger OnAction()
                VAR
                    DocPost: Codeunit ControlProcesos;
                BEGIN
                    DocPost.CloseOrderGroupIfEmpty(Rec, TODAY);
                END;
            }

            action("Cerrar de Todas Formas")
            {
                ApplicationArea = All;
                Image = ClosePeriod;
                trigger OnAction()
                VAR
                    r70004: Record 7000003;
                    DocPost: Codeunit ControlProcesos;
                    ControlProcesos: Codeunit ControlProcesos;
                BEGIN
                    ControlProcesos.CierreProcesosPo(Rec);
                    Commit();
                    DocPost.CloseOrderGroupIfEmpty(Rec, TODAY);
                END;
            }
        }
    }
}