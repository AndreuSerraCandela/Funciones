/// <summary>
/// PageExtension Liquidity Journal (ID 80144) extends Record Cash Flow Worksheet.
/// </summary>
pageextension 80144 "Liquidity Journal" extends "Cash Flow Worksheet"
{
    layout
    {
        addbefore("Amount (LCY)")
        {
            field("Anotación"; Rec."Anotación")
            {
                ApplicationArea = All;
            }
            field("Fecha Anotacion"; Rec."Fecha Anotacion")
            {
                ApplicationArea = All;
            }
            field(Programa; Rec."Shortcut Dimension 2 Code")
            {
                ApplicationArea = All;
            }
        }
        addafter("Amount (LCY)")
        {
            field("Cod banco"; Rec."Cod banco")
            {
                ApplicationArea = All;
            }
            field("Payment Method Code"; Rec."Payment Method Code")
            {
                ApplicationArea = All;
            }
        }
        addbefore("Cash Flow Date")
        {
            field("Due Date"; Rec."Due Date")
            {
                ApplicationArea = All;
            }
            field("Fecha Registro"; Rec."Fecha Registro")
            {
                ApplicationArea = All;
            }
        }
        addfirst(content)
        {
            group(Resumen)
            {
                //Visible=Rv;
                part(fr; "ChartofCashFlowAccounts")
                {
                    ApplicationArea = All;
                    //Visible=RV;

                }
            }
        }
    }
    actions
    {
        addafter(SuggestWorksheetLines)
        {
            action("Sugerir lineas Nuevo")
            {
                ApplicationArea = Basic, Suite;
                Ellipsis = true;
                Image = Import;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ShortCutKey = 'Shift+Ctrl+F';
                ToolTip = 'Transfer information from the areas of general ledger, purchasing, sales, service, fixed assets, manual revenues, and manual expenses to the cash flow worksheet. You use the batch job to make a cash flow forecast.';

                trigger OnAction()
                var
                    SuggestWkshLines2: Report "Suggest Worksheet Lines New";
                begin
                    DeleteErrors;
                    SuggestWkshLines2.RunModal;
                    Clear(SuggestWkshLines2);
                end;
            }
            action("Acturalizar Plan de cuentas")
            {
                ApplicationArea = All;
                Image = ChartOfAccounts;
                trigger OnAction()
                var
                    GlAccount: Record "G/L Account";
                    CashFlow: Record "Cash Flow Account";
                    Comapy: Record Company;
                    Control: Codeunit ControlProcesos;
                begin

                    Comapy.SetRange("Evaluation Company", false);
                    if Comapy.FindFirst() Then
                        Repeat
                            if Control.Permiso_Empresas(Comapy.Name) then begin
                                CashFlow.ChangeCompany(Comapy.Name);
                                GlAccount.ChangeCompany(Comapy.Name);
                                CashFlow.ModifyAll("G/L Account Filter", '');
                                GlAccount.SetFilter("Liq. Account", '<>%1', '');
                                if GlAccount.FindFirst() Then
                                    repeat
                                        if CashFlow.Get(GlAccount."Liq. Account") then begin
                                            if CashFlow."G/L Account Filter" = '' Then
                                                CashFlow."G/L Account Filter" := GlAccount."No."
                                            else
                                                CashFlow."G/L Account Filter" := CashFlow."G/L Account Filter" + '|' + GlAccount."No.";
                                            CashFlow.Modify();
                                        end;
                                    until GlAccount.Next() = 0;
                            end;
                        until Comapy.Next() = 0;

                end;
            }
        }
        modify(Register)
        {
            trigger OnBeforeAction()
            var
                CashEntry: Record "Cash Flow Forecast Entry";
            begin
                CashEntry.DeleteAll();
            end;
        }
    }
    procedure ResumenVisible()
    begin
        Rv := false;
    end;

    trigger onOpenPage()
    var
        Control: Codeunit ControlProcesos;
    begin
        If Control.AccesoProibido_Empresas(CompanyName, 'RESTRINGIDO') then
            Error('No tiene permisos para acceder a este punto del menú en esta empresa');
    end;

    var
        Rv: Boolean;

}



