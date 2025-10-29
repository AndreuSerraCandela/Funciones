/// <summary>
/// PageExtension ModDatosFactura (ID 80108) extends Page 10765.
/// </summary>
pageextension 80108 ModDatosFactura extends 10765
{
    layout
    {
        addafter("Posting Date")
        {
            field("Posting Description"; Rec."Posting Description")
            {
                Caption = 'Texto Factura';
                ApplicationArea = All;
            }
        }
    }
}
