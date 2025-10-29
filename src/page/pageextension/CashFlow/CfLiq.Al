/// <summary>
/// PageExtension CfLiq (ID 80206) extends Record Cash Flow Account List.
/// </summary>
pageextension 80199 CfLiq extends "Cash Flow Account List"
{
    layout
    {
        modify(Amount)
        {
            Visible = false;
        }
        addafter(Amount)
        {
            field(Importe; Importe)
            {
                ApplicationArea = All;
                trigger OnDrillDown()
                var
                    Movs: Record "Cash Flow Forecast Entry";
                begin
                    Movs.ChangeCompany((wEmpresa));
                    Rec.CopyFilter("Date Filter", Movs."Cash Flow Date");
                    Movs.SetRange("Cash Flow Account No.", Rec."No.");
                    if Movs.FindFirst() Then Page.RunModal(0, Movs);

                end;
            }
        }
    }
    /// <summary>
    /// Empresa.
    /// </summary>
    /// <param name="pEmpresa">Text.</param>
    procedure Empresa(pEmpresa: Text)
    Begin
        wEmpresa := pEmpresa;
        Rec.ChangeCompany(Rec.Empresa);
    End;

    var
        wEmpresa: Text;
        DateFilter: Text;

    trigger OnOpenPage()
    begin
        Rec.ChangeCompany(wEmpresa);
    end;

    trigger OnAfterGetCurrRecord()
    var
        Movs: Record "Cash Flow Forecast Entry";
    begin
        Movs.ChangeCompany((wEmpresa));
        if Rec.GETFILTER("Date Filter") = '' THEN EXIT;
        if Rec.GETRANGEMIN("Date Filter") = Rec.GETRANGEMAX("Date Filter") THEN EXIT;
        DateFilter := Rec.GETFILTER("Date Filter");
        if (Rec."Source Type" = Rec."Source Type"::Receivables) AND (Rec."Solo Cartera") THEN BEGIN
            DateFilter := FORMAT(Rec.GETRANGEMIN("Date Filter")) + '..' + FORMAT(CALCDATE('180D', Rec.GETRANGEMAX("Date Filter")));
        END;
        Rec.SETFILTER("Date Filter", DateFilter);
        Rec.CopyFilter("Date Filter", Movs."Cash Flow Date");
        Movs.SetRange("Cash Flow Account No.", Rec."No.");
        if Movs.FindFirst() Then Movs.CalcSums("Amount (LCY)");
        Importe := Movs."Amount (LCY)";

    end;

    var
        Importe: Decimal;
}



