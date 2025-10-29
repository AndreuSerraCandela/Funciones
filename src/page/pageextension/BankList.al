/// <summary>
/// PageExtension ListaBancos (ID 80149) extends Record Bank Account List.
/// </summary>
pageextension 80149 ListaBancos extends "Bank Account List"
{
    layout
    {
        addafter(BalanceLCY)
        {
            field("Transit No."; Rec."Transit No.")
            {
                ApplicationArea = all;
            }
        }
    }
    actions
    {
        addafter(Balance)
        {
            action(Prestamo)
            {
                ApplicationArea = All;
                trigger OnAction()
                begin
                    Page.RunModal(Page::"Prestamos");
                end;
            }

        }

    }
    trigger onOpenPage()
    var
        Control: Codeunit ControlProcesos;
    begin
        If Control.AccesoProibido_Empresas(CompanyName, 'RESTRINGIDO') then
            Error('No tiene permisos para acceder a este punto del menú en esta empresa');

        Rec.SetRange(Blocked, false);
    end;
}