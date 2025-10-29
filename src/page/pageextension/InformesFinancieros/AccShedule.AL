/// <summary>
/// PageExtension AccShd (ID 80179) extends Record Account Schedule.
/// </summary>
pageextension 80179 AccShd extends "Account Schedule"
{
    layout
    {
        addafter("Dimension 4 Totaling")
        {
            field(Empresa; Rec.Company)
            {
                ApplicationArea = All;
            }
            field("Salesperson Code"; Rec."Salesperson Code")
            {
                ApplicationArea = aLL;
            }
            field("Dimension 5 Totaling"; Rec."Dimension 5 Totaling")
            {
                ApplicationArea = aLL;
            }
            field("Grupo Contable"; Rec."Grupo Contable")
            {
                ApplicationArea = All;
            }

        }
        modify("Dimension 1 Totaling")
        {
            Visible = true;
        }
        modify("Dimension 2 Totaling")
        {
            Visible = true;
        }
        modify("Dimension 3 Totaling")
        {
            Visible = true;
        }
        modify("Dimension 4 Totaling")
        {
            Visible = true;
        }

    }
}
