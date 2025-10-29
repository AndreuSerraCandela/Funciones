/// <summary>
/// PageExtension KuaraFirmasExt (ID 80106) extends Record SO Processor Activities.
/// </summary>
pageextension 80106 "KuaraFirmasExt" extends "SO Processor Activities"
{

    layout
    {
        modify("Missing SII Entries")
        {
            Visible = false;
        }
        modify("Days Since Last SII Check")
        {
            Visible = false;
        }
        modify("Sales Quotes - Open")
        {
            Visible = false;
        }
        modify("For Release")
        {
            Visible = false;
        }
        modify("Sales Orders Released Not Shipped")
        {
            Visible = false;
        }
        modify(Returns)
        {
            Visible = false;
        }


    }



    trigger OnOpenPage()
    begin
        Rec.SetRange("Date Filter", CalcDate('PA+1D-1A-3M', Today), CalcDate('PA+3M', Today));
    end;


}