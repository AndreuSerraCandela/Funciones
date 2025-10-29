/// <summary>
/// PageExtension DocumentPrifiles (ID 80161) extends Record Document Sending Profiles.
/// </summary>
pageextension 80161 DocumentPrifiles extends "Document Sending Profiles"
{
    layout
    {
        addlast(Group)
        {
            field("Enviar Ahora"; Rec."Enviar Ahora")
            {
                ApplicationArea = All;
            }
            field("Report Facturas"; Rec."Report Facturas")
            {
                ApplicationArea = All;
            }
            field("Report Abonos"; Rec."Report Abonos")
            {
                ApplicationArea = All;
            }

        }
    }
}