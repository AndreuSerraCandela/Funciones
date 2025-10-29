//Page Extension Page ApplyCli Extends "Apply Customer Entries"
pageextension 80225 ApplyCli extends "Apply Customer Entries"
{
    layout
    {
        addafter("Document Situation")
        {
            field("Payment Method Code"; Rec."Payment Method Code")
            {
                ApplicationArea = All;

            }
        }
    }
}
//Lo mismo para proveedores
pageextension 80226 ApplyVen extends "Apply Vendor Entries"
{
    layout
    {
        addafter("Document Situation")
        {
            field("Payment Method Code"; Rec."Payment Method Code")
            {
                ApplicationArea = All;

            }
        }
    }
}

