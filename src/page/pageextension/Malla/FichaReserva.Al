pageextension 75005 FichaReserva extends "Ficha Reserva"
{
    actions
    {
        addafter("Diario Reserva")
        {
            action("Cambiar estado")
            {
                Caption = 'C&ambiar estado';
                ApplicationArea = ALL;
                trigger OnAction()
                BEGIN
                    Gestio.Cambio_Estado(Rec);
                END;
            }
        }
        addafter("Texto Linea")
        {
            action("Ocupacion Diaria")
            {
                ShortCutKey = F10;
                Caption = '&Ocupacion diaria';
                ApplicationArea = ALL;
                trigger OnAction()
                BEGIN
                    CLEAR(Plazos);
                    rRec.GET(Rec."Nº Recurso");
                    Plazos.Coge_Recurso(rRec);
                    Plazos.RUNMODAL;
                END;
            }
        }
        addafter(Reserva)
        {
            group(Acciones)
            {
                Caption = 'Acci&ones';

                action("Particion Reserva")
                {
                    Caption = '&Partición reserva';
                    ApplicationArea = ALL;
                    trigger OnAction()
                    BEGIN
                        Rec.SETRANGE("Nº Reserva", Rec."Nº Reserva");
                        Page.RUNMODAL(Page::"Particion Reserva", Rec);
                        Rec.SETRANGE("Nº Reserva");
                        CurrPage.UPDATE;
                    END;
                }
            }
        }
    }
    VAR
        Gestio: Codeunit "Gestion Reservas";
        Plazos: Page "Plazos recursos reservados";
        rRec: Record 156;
}