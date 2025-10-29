
pageextension 80162 DocumentPrifile extends "Document Sending Profile"
{
    layout
    {
        addlast(content)
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