pageextension 75010 TablaReservas extends "Tabla Reservas"
{
    actions
    {
        addafter("Diario Reserva")
        {
            action("Ocupacion Diaria")
            {
                ShortCutKey = F10;
                Image = ResourcePlanning;
                ApplicationArea = ALL;
                Caption = '&Ocupacion diaria';
                trigger OnAction()
                BEGIN
                    CLEAR(Plazos);
                    rRec.GET(Rec."Nº Recurso");
                    Plazos.Coge_Recurso(rRec);
                    Plazos.RUNMODAL;
                END;
            }
        }
    }
    VAR
        Plazos: Page "Plazos recursos reservados";
        rRec: Record Resource;
}