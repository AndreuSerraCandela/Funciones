/// <summary>
/// PageExtension ColumnLayaout (ID 80168) extends Record Column Layout.
/// </summary>
pageextension 80168 ColumnLayaout extends "Column Layout"
{
    layout
    {
        addafter("Comparison Period Formula")
        {
            field(Empresa; Rec.Empresa)
            {
                ApplicationArea = All;
            }
        }

    }
}
