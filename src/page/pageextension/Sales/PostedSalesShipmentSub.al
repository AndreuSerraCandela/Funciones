
pageextension 80185 Shipsubf extends "Posted Sales Shpt. Subform"
{
    layout
    {
        addafter("quantity")
        {
            field("Unit Price"; Rec."Unit Price")
            {
                ApplicationArea = all;
            }
            field("Importe"; Rec."Amount")
            {
                ApplicationArea = all;
            }
        }

    }
}
