pageextension 75007 ListaOrdenesFijacion extends "Lista Ordenes Fijación"
{
    actions
    {
        addafter("Validad/Desvalidar")
        {
            action("Duplicación masiva ordenes")
            {
                ApplicationArea = ALL;
                Caption = '&Duplicación masiva ordenes';
                RunObject = report "Proceso duplicar ordenes masiv";

            }
        }
    }
}
pageextension 75008 DetalleOrdenesFijacion extends "Detalle Ordenes Fijación"
{
    actions
    {
        addafter("Validad/Desvalidar")
        {
            action("Duplicación masiva ordenes")
            {
                ApplicationArea = ALL;
                Caption = '&Duplicación masiva ordenes';
            }
        }
    }
}