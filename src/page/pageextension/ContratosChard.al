/// <summary>
/// PageExtension ContratosChard (ID 80104) extends Record Trailing Sales Orders Chart.
/// </summary>
pageextension 80104 ContratosChard extends "Trailing Sales Orders Chart"
{
    Caption = 'Contratos';
    actions

    {
        modify(AllOrders)
        {
            Caption = 'Todos los Contratos';
            ToolTip = 'Ver todos los contratos.';

        }
        modify(OrdersUntilToday)
        {
            Caption = 'Contratos hasta hoy';
            ToolTip = 'Ver los contratos hasta hoy.';


        }
        modify(DelayedOrders)
        {
            Visible = false;
        }


        modify(NoofOrders)
        {
            Caption = 'Nº de Contratos';
            ToolTip = 'El eje Y muestra el número de contratos.';

        }
    }


}

