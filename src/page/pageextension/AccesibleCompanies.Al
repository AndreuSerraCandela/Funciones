/// <summary>
/// PageExtension Empresas (ID 80256) extends Record Accessible Companies.
/// </summary>
pageextension 80121 Empresas extends "Accessible Companies"
{
    layout
    {
        modify("Evaluation Company")
        {
            Caption = 'Ocultar';
            Visible = false;
        }
    }
    trigger OnOpenPage()
    begin
        Rec.SetRange(Rec."Evaluation Company", false);
    end;
}