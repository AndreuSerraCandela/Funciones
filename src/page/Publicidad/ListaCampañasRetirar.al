/// <summary>
/// Page Campañas a retirar (ID 50118).
/// </summary>
page 50047 "Campañas a retirar"
{
    ApplicationArea = All;
    Caption = 'Campañas a retirar';
    PageType = List;
    SourceTable = "Campañas a retirar";
    UsageCategory = Lists;
    Editable = true;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Entry No."; Rec."Entry No.")
                {
                    ToolTip = 'Specifies the value of the Entry No. field';
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Fecha"; Rec."Fecha")
                {
                    ToolTip = 'Specifies the value of the Fecha field';
                    ApplicationArea = All;
                }
                field("Campaña"; Rec."Campaña")
                {
                    ToolTip = 'Specifies the value of the Campaña field';
                    ApplicationArea = All;
                }
                field("Tirar"; Rec."Tirar")
                {
                    ToolTip = 'Specifies the value of the Tirar field';
                    ApplicationArea = All;
                }
                field("Observaciones"; Rec."Observaciones")
                {
                    ToolTip = 'Specifies the value of the Observaciones field';
                    ApplicationArea = All;
                }
            }
        }
    }
}
