/// <summary>
/// PageExtension PurchaseQuote (ID 80204) extends Record Purchase Quote.
/// </summary>
pageextension 80197 PurchaseQuote extends "Purchase Quote"
{
    layout
    {
        addafter("Vendor Bank Acc. Code")
        {
            field("Descripción operación"; Rec."Descripción operación") { ApplicationArea = All; }
            field("Tipo factura SII"; Rec."Tipo factura SII") { ApplicationArea = All; }
        }
    }
}
