/// <summary>
/// Page ChartofCashFlowAccounts (ID 50041).
/// </summary>
page 50041 "ChartofCashFlowAccounts"
{
    ApplicationArea = Basic, Suite;
    Caption = 'Plan de Cuentas CashFlow';
    CardPageID = "Cash Flow Account Card";
    PageType = ListPart;
    RefreshOnActivate = true;
    SourceTable = "Cash Flow Account";
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(Control1000)
            {
                IndentationColumn = NameIndent;
                IndentationControls = Name;
                ShowCaption = false;
                field("No."; Rec."No.")
                {
                    ApplicationArea = Basic, Suite;
                    Style = Strong;
                    StyleExpr = NoEmphasize;
                    ToolTip = 'Specifies the number of the involved entry or record, according to the specified number series.';
                }
                field(Name; Rec.Name)
                {
                    Caption = 'Nombre';
                    ApplicationArea = Basic, Suite;
                    Style = Strong;
                    StyleExpr = NameEmphasize;
                    ToolTip = 'Specifies the name of the cash flow account.';
                }
                field("Account Type"; Rec."Account Type")
                {
                    Caption = 'Tipo';
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the purpose of the cash flow account. Newly created cash flow accounts are automatically assigned the Entry account type, but you can change this.';
                }
                field(Totaling; Rec.Totaling)
                {
                    Caption = 'Sumatorio';
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies an account interval or a list of account numbers. The entries of the account will be totaled to give a total balance. How entries are totaled depends on the value in the Account Type field.';

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        CFAccList: Page "Cash Flow Account List";
                    begin
                        CFAccList.LookupMode(true);
                        if not (CFAccList.RunModal = ACTION::LookupOK) then
                            exit(false);

                        Text := CFAccList.GetSelectionFilter;
                        exit(true);
                    end;
                }
                field("Source Type"; Rec."Source Type")
                {
                    Caption = 'Tipo Origen';
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the source type that applies to the source number that is shown in the Source No. field.';
                    Visible = false;
                }
                field("G/L Integration"; Rec."G/L Integration")
                {
                    Caption = 'Integración contabilidad';
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies if the cash flow account has integration with the general ledger. When a cash flow account has integration with the general ledger, either the balances of the general ledger accounts or their budgeted values are used in the cash flow forecast.';
                    Visible = false;
                }


                field("G/L Account Filter"; Rec."G/L Account Filter")
                {
                    Caption = 'Filtro cuenta';
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies that only the cash flow entries that are registered to the filtered general ledger accounts are included in the cash flow forecast.';
                }
                field("Solo Cartera"; Rec."Solo Cartera")
                {
                    ApplicationArea = All;
                }
                field("Banco Informes"; Rec."Banco Informes")
                {
                    ApplicationArea = All;
                    trigger OnLookup(var Text: Text): Boolean
                    var
                        "Nombre Banco": Record "Nombre Banco";
                    begin
                        if Page.RunModal(0, "Nombre Banco") in [Action::LookupOK, Action::OK] Then begin
                            Rec."Banco Informes" := "Nombre Banco"."Nombre Banco";
                            Rec.Modify();
                        end;
                    end;
                }
                field("Cod banco"; Rec."Cod banco")
                {
                    ApplicationArea = All;
                }
                field(Amount; Rec.Amount)
                {
                    Caption = 'Importe';
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ToolTip = 'Specifies the cash flow amount.';
                }
                field("Importe pendiente"; Rec."Amount Open.")
                {
                    Caption = 'Importe pendiente';
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ToolTip = 'Especifica el importe pendiente';
                    trigger OnDrillDown()
                    var
                        Cf: Record "Cash Flow Worksheet Line";
                        Pg: Page "Cash Flow Worksheet";
                    begin
                        Cf.SetRange("Cash Flow Account No.", Rec."No.");
                        Pg.ResumenVisible();
                        Pg.SetTableView(cf);
                        Pg.RunModal();
                    end;

                }
            }
        }

    }

    actions
    {
        area(processing)
        {
            group("A&ccount")
            {
                Caption = 'A&ccount';
                Image = ChartOfAccounts;
                action(Entries)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Entries';
                    Image = Entries;
                    RunObject = Page "Cash Flow Forecast Entries";
                    RunPageLink = "Cash Flow Account No." = FIELD("No.");
                    RunPageView = SORTING("Cash Flow Account No.");
                    ShortCutKey = 'Ctrl+F7';
                    ToolTip = 'View the entries that exist for the cash flow account. ';
                }
                action("Co&mments")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Co&mments';
                    Image = ViewComments;
                    RunObject = Page "Cash Flow Comment";
                    RunPageLink = "Table Name" = CONST("Cash Flow Account"),
                                  "No." = FIELD("No.");
                    ToolTip = 'View or add comments for the record.';
                }
            }
            group("F&unctions")
            {
                Caption = 'F&unctions';
                Image = "Action";
                action("Indent Chart of Cash Flow Accounts")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Indent Chart of Cash Flow Accounts';
                    Image = IndentChartOfAccounts;
                    RunObject = Codeunit "Cash Flow Account - Indent";
                    ToolTip = 'Indent rows per the hierarchy and validate the chart of cash flow accounts.';
                }
            }
        }

    }

    trigger OnAfterGetRecord()
    begin
        NameIndent := 0;
        NoOnFormat;
        NameOnFormat;
    end;

    trigger onOpenPage()
    var
        Control: Codeunit ControlProcesos;
    begin
        If Control.AccesoProibido_Empresas(CompanyName, 'RESTRINGIDO') then
            Error('No tiene permisos para acceder a este punto del menú en esta empresa');
    end;

    var

        NoEmphasize: Boolean;

        NameEmphasize: Boolean;

        NameIndent: Integer;

    local procedure NoOnFormat()
    begin
        NoEmphasize := Rec."Account Type" <> Rec."Account Type"::Entry;
    end;

    local procedure NameOnFormat()
    begin
        NameIndent := Rec.Indentation;
        NameEmphasize := Rec."Account Type" <> Rec."Account Type"::Entry;
    end;
}