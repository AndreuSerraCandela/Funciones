pageextension 80184 OrdenPagoregis extends "Posted Payment Orders Select."
{

    layout
    {
        modify("No.")
        {
            trigger OnDrillDown()
            begin
                Page.Runmodal(Page::"Posted Payment Orders", Rec);
            end;
        }
    }

}