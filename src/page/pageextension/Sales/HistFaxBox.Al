pageextension 80223 HistFaxBox extends "Sales Hist. Sell-to FactBox"
{
    layout
    {
        addafter("NoofBlanketOrdersTile")
        {
            field("Pedidos de venta en curso"; Rec."No. de Pedidos")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Pedidos de venta en curso';
                DrillDownPageID = "Sales Order List";
            }
            field("Contratos"; Rec."No. de Contratos")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Contratos';
                DrillDownPageID = "Lista Contratos Venta";
            }
            field("Proyectos"; Rec."No. de Proyectos")
            {
                ApplicationArea = all;
                Caption = 'Proyectos';
                DrillDownPageID = "Job List";
            }
        }
        addbefore(NoofPstdInvoicesTile)
        {
            field(NoofAlbaranesTile; Rec."No. de Albaranes")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Historial de Albaranes venta';
                DrillDownPageID = "Posted Sales Shipments";
                ToolTip = 'Specifies the number of posted sales shipments that have been registered for the customer.';
            }
        }
        modify(NoofOrdersTile)
        {
            visible = false;
        }
        modify(NoofPstdShipmentsTile)
        {

            visible = false;
        }


    }
}