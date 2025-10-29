/// <summary>
/// PageExtension ShipToAdr (ID 80167) extends Record sh.
/// </summary>
pageextension 80177 ShipToAdr extends "Ship-to Address"
{
    layout
    {
        modify("E-Mail")
        {
            Importance = Promoted;
        }
        addafter("E-Mail")
        {
            field("E-Mail-Facturación"; Rec."E-Mail-Facturación") { }
        }
    }
}