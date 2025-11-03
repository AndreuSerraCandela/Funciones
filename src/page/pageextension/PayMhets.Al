/// <summary>
/// PageExtension Paymets (ID 80169) extends Record Payment Methods.
/// </summary>
pageextension 80169 Paymets extends "Payment Methods"
{
    layout
    {
        addbefore("Invoices to Cartera")
        {
            field("Remesa sin factura"; Rec."Remesa sin factura")
            {
                ApplicationArea = All;
            }
            field(Visible; Rec.Visible)
            {
                ApplicationArea = All;
            }
            field("Imprimir recibo"; Rec."Imprimir recibo")
            {
                ApplicationArea = All;
            }
            field(Intercambio; Rec.Intercambio)
            {
                ApplicationArea = All;
            }
            field("En Todas Las Empresas"; Rec."En Todas Las Empresas")
            {
                ApplicationArea = All;
            }
            field("Banco Obligatorio"; Rec."Banco Obligatorio")
            {
                ApplicationArea = All;
            }
            field("Banco transferencia"; Rec."Banco transferencia")
            {
                ApplicationArea = All;
            }
            field("Sin Banco"; Rec."Sin Banco")
            {
                ApplicationArea = All;
            }
            field("Cód. banco Efactura"; Rec."Cód. banco Efactura")
            {
                ApplicationArea = All;
            }
            field("Código Efactura"; Rec."Código Efactura")
            {
                ApplicationArea = All;
            }
        }
    }
    trigger OnOpenPage()
    begin
        Rec.SetRange(Visible, true);
    end;
}