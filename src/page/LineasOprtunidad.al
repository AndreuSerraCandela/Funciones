/// <summary>
/// Page Lineas Oprtunidad (ID 50004).
/// </summary>
page 50004 "Lineas Oprtunidad"
{

    Caption = 'Lineas Oprtunidad';
    PageType = ListPart;
    SourceTable = "Opportunity Entry";
    PopulateAllFields = true;
    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Entry No."; Rec."Entry No.")
                {
                    ApplicationArea = All;
                }
                field("Recurso Solicitado"; Rec."Recurso Solicitado")
                {
                    ApplicationArea = All;
                }
                field("Descripción Recurso"; Rec."Descripcion Recurso")
                {
                    ApplicationArea = All;
                }
                field("Tipo de Campaña"; Rec."Tipo de Campaña")
                {
                    ApplicationArea = All;
                }
                field("Tipo Soporte"; Rec."Tipo Soporte")
                {
                    ApplicationArea = All;
                }
                field("Zona Soporte"; Rec."Zona Soporte")
                {
                    ApplicationArea = All;
                }
                field("Fecha Inicio"; Rec."Fecha Inicio")
                {
                    ApplicationArea = All;
                }
                field("Fecha Fin"; Rec."Fecha Fin")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
    trigger OnNewRecord(BelowRec: Boolean)
    var
        opp: Record "Opportunity Entry";
    begin
        if opp.FindLast() then
            Rec."Entry No." := opp."Entry No." + 1
        else
            Rec."Entry No." := 1;

    end;
}
