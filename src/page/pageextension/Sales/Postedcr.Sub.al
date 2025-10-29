/// <summary>
/// PageExtension SaleCrSub (ID 80135) extends Record 135.
/// </summary>
pageextension 80214 SaleCrSub extends 135
{
    actions
    {
        addlast("&Line")
        {
            action("Marcar Imprimible")
            {
                ApplicationArea = All;
                Image = Print;
                trigger OnAction()
                var
                    Irpf: Codeunit ControlProcesos;
                begin
                    Irpf.MarcarImprimibleAbo(Rec);

                end;
            }
        }
    }
}
/// <summary>
/// PageExtension SaleCrSub (ID 80135) extends Record 135.
/// </summary>
pageextension 80213 SaleInvSub extends "Posted Sales Invoice Subform"
{
    actions
    {
        addlast("&Line")
        {
            action("Marcar Imprimible")
            {
                ApplicationArea = All;
                Image = Print;
                trigger OnAction()
                var
                    Irpf: Codeunit ControlProcesos;
                begin
                    Irpf.MarcarImprimibleFac(Rec);

                end;
            }
        }
    }
}