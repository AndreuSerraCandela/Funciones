/// <summary>
/// Page Lista Planificación Fijación (ID 50100).
/// </summary>
page 50076 "Lista Planificación Fijación"
{
    ApplicationArea = All;
    Caption = 'Planificación fijación';
    PageType = List;
    SourceTable = "Planificación Fijación";
    UsageCategory = Lists;
    Editable = true;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Entry No."; Rec."Entry No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Nº Proyecto"; Rec."Nº Proyecto")
                {
                    ApplicationArea = All;
                }
                field(Nombre; Rec.Nombre)
                {
                    ApplicationArea = All;
                }
                field("Fecha fijación"; Rec."Fecha fijación")
                {
                    ApplicationArea = All;
                }
                field("Tipo Soporte"; Rec."Tipo Soporte")
                {
                    ApplicationArea = All;
                }
                field("No. Soportes"; Rec."No. Soportes")
                {
                    ApplicationArea = All;
                }
                field("No. Opis"; Rec."No. Opis")
                {
                    ApplicationArea = All;
                }
                field("Nombre Comercial"; Rec."Nombre Comercial")
                {
                    ApplicationArea = All;
                }
                field(Validado; Rec.Validado)
                {
                    ApplicationArea = All;
                }
            }
        }
    }
}
