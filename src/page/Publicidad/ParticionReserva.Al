page 50089 "Particion Reserva"
{
    PageType = Card;
    SourceTable = Reserva;
    InsertAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            group("Particion Reserva")
            {
                Caption = 'Particion Reserva';
                field("Reserva Original"; Rec."Nº Reserva")
                {
                    ApplicationArea = all;
                    Editable = false;
                }
                field("Recurso Original"; Rec."Nº Recurso")
                {
                    ApplicationArea = all;
                    Editable = false;
                }

                field("Fecha Inicio"; Rec."Fecha inicio")
                {
                    ApplicationArea = all;
                    Editable = false;
                }
                field("Fecha fin"; Rec."Fecha fin")
                {
                    ApplicationArea = all;
                    Editable = false;
                }
            }
            group("Nueva Reserva")
            {

                Caption = 'Nueva Reserva';
                field(FMed1; FMed1)
                {
                    Caption = 'Fecha Inicio';
                    ApplicationArea = all;

                }

                field(FMed2; FMed2)
                {
                    Caption = 'Fecha Fin';
                    ApplicationArea = all;

                }
                field("Filtro Tipo Recurso"; FiltroTipo)
                {
                    Caption = 'Filtro tipo recurso';
                    TableRelation = "Tipo Recurso";
                }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action("&Ejecutar")
            {
                ApplicationArea = ALL;
                trigger OnAction()
                VAR
                    rRec: Record 156;
                    rRec2: Record 156;
                    ventana: Page "Tabla Recursos";
                BEGIN
                    GReserva.Partir_Reserva(Rec, FMed1, FMed2, FiltroTipo);
                    CurrPage.UPDATE;
                    CurrPage.CLOSE;
                END;
            }
        }
    }
    VAR
        rDia: Record "Diario Reserva";
        rReserva2: Record Reserva;
        FinPrimera: Date;
        InicioSegunda: Date;
        FinSegunda: Date;
        FMed1: Date;
        FMed2: Date;
        GReserva: Codeunit "Gestion Reservas";
        FiltroTipo: Code[10];


}

