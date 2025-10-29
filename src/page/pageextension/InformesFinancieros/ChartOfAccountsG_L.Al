/// <summary>
/// PageExtension ChartOfAccounts (ID 80170) extends Record Chart of Accounts (G/L).
/// </summary>
pageextension 80170 ChartOfAccounts extends "Chart of Accounts (G/L)"
{
    layout
    {
        addafter("Net Change")
        {
            field("Saldo Periodo"; Rec."Saldo del Periodo")
            {
                Caption = 'Saldo Periodo';
                ApplicationArea = All;
                trigger OnDrillDown()
                var
                    Mov: Record "G/L Entry";
                    pMov: Page 20;
                begin

                    Mov.SetRange("G/L Account No.", Rec."No.");
                    if Rec.Totaling <> '' Then Mov.SetFilter("G/L Account No.", Rec.Totaling);
                    Rec.CopyFilter("Business Unit Filter", Mov."Business Unit Code");
                    Rec.CopyFilter("Global Dimension 1 Filter", Mov."Global Dimension 1 Code");
                    Rec.CopyFilter("Global Dimension 2 Filter", Mov."Global Dimension 2 Code");
                    Rec.CopyFilter("Global Dimension 3 Filter", Mov."Global Dimension 3 Code");
                    Rec.CopyFilter("Global Dimension 4 Filter", Mov."Global Dimension 4 Code");
                    Rec.CopyFilter("Global Dimension 5 Filter", Mov."Global Dimension 5 Code");
                    Rec.CopyFilter("Salesperson Filter", mov."SalesPerson Code");
                    Rec.CopyFilter("Filtro Eliminaciones", Mov.Eliminaciones);
                    Rec.CopyFilter("Date Filter", Mov."Posting Date");
                    Rec.CopyFilter("Dimension Set ID Filter", Mov."Dimension Set ID");
                    if Empresa <> '' Then Mov.ChangeCompany(Empresa);
                    // pMov.EmpresaBuscar(Empresa);
                    // pMov.SetTableView(Mov);
                    // pMov.RunModal();
                    Page.RunModal(0, Mov);
                end;
            }
        }
        modify("Net Change")
        {
            Visible = false;
        }
    }
    trigger onOpenPage()
    var
        Control: Codeunit ControlProcesos;
    begin
        If Control.AccesoProibido_Empresas(CompanyName, 'RESTRINGIDO') then
            Error('No tiene permisos para acceder a este punto del menú en esta empresa');

        Rec.CalcFields("Saldo del Periodo");
        CurrPage.Update(false);
    end;

    /// <summary>
    /// CambiaEmpresa.
    /// </summary>
    /// <param name="pEmpresa">Text.</param>
    procedure CambiaEmpresa(pEmpresa: Text)
    begin
        Empresa := pEmpresa;
        Rec.ChangeCompany(Empresa);
    end;

    var
        Empresa: Text;
}