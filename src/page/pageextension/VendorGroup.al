
/// <summary>
/// PageExtension VendorGroup (ID 80230) extends Record Vendor Posting Group Card.
/// </summary>
pageextension 80212 VendorGroup extends "Vendor Posting Group Card"
{
    layout
    {
        addafter("Debit Rounding Account")
        {
            field(FPR; Rec.FPR)
            { ApplicationArea = All; }
        }
    }
}