
/// <summary>
/// PageExtension Banco (ID 80255) extends Record Bank Account Card.
/// </summary>
pageextension 80120 Banco extends "Bank Account Card"
{
    layout
    {
        addafter(Name)
        {
            field("Nombre para Informes"; Rec."Name 2")
            {
                Caption = 'Nombre para Informes';
                ApplicationArea = All;
                trigger OnLookup(var Text: Text): Boolean
                var
                    "Nombre Banco": Record "Nombre Banco";
                begin
                    if Page.RunModal(0, "Nombre Banco") in [Action::LookupOK, Action::OK] Then begin
                        Rec."Name 2" := "Nombre Banco"."Nombre Banco";
                        Rec.Modify();
                    end;
                end;
            }
        }
    }
    actions
    {
        addafter("&Bank Acc.")
        {
            action("Arregla banco")
            {
                ApplicationArea = All;
                Image = BankAccount;
                trigger OnAction()
                var
                    Control: Codeunit Utilitis;
                begin
                    Control.ArregloBanco(Rec."No.");
                end;
            }
        }
    }
}