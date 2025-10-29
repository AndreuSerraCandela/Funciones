
/// <summary>
/// PageExtension ResourceGroups (ID 80213).
/// </summary>
pageextension 80205 ResourceGroups Extends "Resource Groups"
{
    layout
    {
        addafter(Name)
        {
            field("Global Dimension 1 Code"; Rec."Global Dimension 1 Code") { ApplicationArea = All; }
            field("Global Dimension 2 Code"; Rec."Global Dimension 2 Code") { ApplicationArea = All; }
            field("Grupo contable producto"; Rec."Grupo contable producto") { ApplicationArea = All; }
            field("Grupo registro IVA prod."; Rec."Grupo registro IVA prod.") { ApplicationArea = All; }
            field("Nº proveedor"; Rec."Nº proveedor") { ApplicationArea = All; }
        }
    }
}