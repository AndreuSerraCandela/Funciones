/// <summary>
/// Unknown LibroFacturasRecibidas (ID 50000) extends Record Purchases Invoice Book.
/// </summary>
reportextension 80101 LibroFacturasRecibidas extends "Purchases Invoice Book"
{
    dataset
    {
        modify("No Taxable Entry")
        {
            trigger OnAfterPreDataItem()
            begin
                "No Taxable Entry".SetRange("Entry No.", 0);
            end;
        }

    }

}
