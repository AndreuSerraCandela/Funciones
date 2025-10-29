/// <summary>
/// PageExtension Gastos (ID 80229) extends Record Cash Flow Manual Expenses.
/// </summary>
pageextension 80211 Gastos extends "Cash Flow Manual Expenses"
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
    }
}