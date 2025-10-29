/// <summary>
/// PageExtension VendorGroups (ID 80130) extends Record Vendor Posting Groups.
/// </summary>
pageextension 80130 VendorGroups extends "Vendor Posting Groups"
{
    layout
    {
        addafter("Bills in Payment Order Acc.")
        {
            field(FPR; Rec.FPR)
            { ApplicationArea = All; }
        }
    }
}
