/// <summary>
/// PageExtension PedidoCompraKuaraList (ID 80115) extends Record Purchase order List.
/// </summary>
pageextension 80115 "PedidoCompraKuaraList" extends "Purchase order List"
{
    layout
    {
        addafter("Buy-from Vendor Name")
        {
            field("Descripcion proyecto"; Rec."Descripcion proyecto")
            {
                ApplicationArea = all;
            }
            field("Observaciones"; Rec."Descripción operación") { ApplicationArea = All; }
            field("Nº Proyecto"; Rec."Nº Proyecto") { ApplicationArea = All; }
            field("Factura recibida"; Rec."Factura recibida") { ApplicationArea = All; }
            field("Expected Receipt Date"; Rec."Expected Receipt Date") { ApplicationArea = All; }
            field("Order Date"; Rec."Order Date") { ApplicationArea = All; }
            field("Nº Contrato Venta"; Rec."Nº Contrato Venta") { ApplicationArea = All; }
        }

    }
    actions
    {
        modify(Receipts)
        {
            Visible = false;
        }
        addafter(Receipts)
        {
            action(Albaranes)
            {
                Caption = 'Albaranes';
                Scope = Repeater;
                Image = PostedReceipts;
                RunObject = Page "Posted Purchase Receipts";
                RunPageLink = "Order No." = FIELD("No.");
                RunPageView = SORTING("Order No.");
                // ToolTip = 'View a list of posted purchase receipts for the order.';
                //pON EL TOOLTIP EN ESPAÑOL
                ToolTip = 'Ver una lista de albaranes de compra registrados para el pedido.';

            }
        }
    }
    var
        myInt: Integer;

}