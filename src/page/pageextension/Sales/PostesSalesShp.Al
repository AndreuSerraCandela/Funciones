/// <summary>
/// PageExtension PostedSalesShp (ID 80173) extends Record Posted Sales Invoice.
/// </summary>
pageextension 80182 PostedSalesShp extends "Posted Sales Shipment"
{
    layout
    {
        addafter("Quote No.")
        {
            field("Nº Contrato"; Rec."Nº Contrato")
            {
                ApplicationArea = all;
            }
            field("Nº Proyecto"; Rec."Nº Proyecto")
            {
                ApplicationArea = all;
            }
        }

    }




}
