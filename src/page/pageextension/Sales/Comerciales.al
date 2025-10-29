pageextension 80229 SalesPersonExt extends "Salespersons/Purchasers"
{
    actions
    {
        addfirst(Navigation)
        {
            action("Ver Lista Espera")
            {
                Image = List;
                ApplicationArea = All;
                Caption = 'Ver Lista Espera';
                RunObject = page "Lista Espera Recursos";
                ToolTip = 'Muestra la lista de espera de recursos';
                trigger OnAction()
                var
                    ListaEspera: Record "Incidencias Rescursos";
                begin
                    ListaEspera.SetRange("Vendedor", Rec."Code");
                    ListaEspera.SetRange(Motivo, ListaEspera.Motivo::"Lista de Espera");
                    ListaEspera.SetRange("Fecha Inicio", CalcDate('-3M', Today), CalcDate('+3M', Today));
                    Page.Run(0, ListaEspera);
                end;
            }
        }
    }
}