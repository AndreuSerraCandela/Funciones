pageextension 80112 PostedBillGroupsList extends "Posted Bill Groups List"
{
    layout
    {
        addbefore(Amount)
        {
            field("Amount Grouped"; Rec."Amount Grouped")
            {
                Caption = 'Importe remesado';
                ApplicationArea = All;
                ToolTip = 'Specifies the grouped amount in this posted bill group.';
            }
        }
    }
}