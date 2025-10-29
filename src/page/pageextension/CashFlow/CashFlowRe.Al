/// <summary>
/// PageExtension Ingresos (ID 80228) extends Record Cash Flow Manual Revenues.
/// </summary>
pageextension 80210 Ingresos extends "Cash Flow Manual Revenues"
{
    layout
    {
        addafter("Ending Date")
        {
            field(Banco; Rec.Banco)
            {
                ApplicationArea = All;
            }
            field("Una Sola Vez"; Rec."Una Sola Vez")
            {
                ApplicationArea = All;
            }

        }
        modify("Cash Flow Account No.")
        {
            Visible = true;
            ApplicationArea = All;
        }
    }
}