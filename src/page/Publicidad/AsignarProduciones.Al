/// <summary>
/// Page Asignar Producciones (ID 50096).
/// </summary>
page 50045 "Asignar Producciones"
{
    PageType = ListPart;
    SourceTable = "Produccines Relacionadas";
    layout
    {
        area(Content)
        {

            repeater(Producciones)
            {
                field("Line No."; Rec."Line No.")
                {
                    ApplicationArea = all;
                    Caption = 'Nº línea';
                }
                field("Job No."; Rec."Job No.")
                {
                    ApplicationArea = all;
                    Caption = 'Proyecto';
                }
                field(Type; Rec.Type)
                {
                    ApplicationArea = all;
                    Caption = 'Tipo';
                }
                field("No."; Rec."No.")
                {
                    ApplicationArea = all;
                    Caption = 'Recurso';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = all;
                    Caption = 'Descripción';
                }
                field("Line No.2"; Rec."Line No.2")
                {
                    ApplicationArea = All;
                    Caption = 'Nº Línea en proyecto origen';
                }
                field("Job No.2"; Rec."Job No.2")
                {
                    ApplicationArea = All;
                    Caption = 'Proyecto Origen';
                }
                field(Type2; Rec.Type2)
                {
                    ApplicationArea = all;
                    Caption = 'Tipo';
                }
                field("No.2"; Rec."No.2")
                {
                    ApplicationArea = All;
                    Caption = 'Recurso Origen';
                }
                field("Description 2"; Rec."Description 2")
                {
                    ApplicationArea = all;
                    Caption = 'Descripción';
                }

            }

        }
    }

}