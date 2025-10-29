/// <summary>
/// PageExtension CofAn (ID 80216) extends Record Chart of Accs. (Analysis View).
/// </summary>
pageextension 80207 CofAn extends "Chart of Accs. (Analysis View)"
{

    /// <summary>
    /// InsertTempLiqAccAnalysisViews.
    /// </summary>
    /// <param name="LiqAcc">VAR Record "Cash Flow Account".</param>
    procedure InsertTempLiqAccAnalysisViews(var LiqAcc: Record "Cash Flow Account")
    begin

        if LiqAcc.FIND('-') THEN
            REPEAT
                TempLiqAccAnalysisView.INIT;
                TempLiqAccAnalysisView.TRANSFERFIELDS(LiqAcc, TRUE);
                TempLiqAccAnalysisView.INSERT;
            UNTIL LiqAcc.NEXT = 0;
    end;

    trigger onOpenPage()
    var
        Control: Codeunit ControlProcesos;
    begin
        If Control.AccesoProibido_Empresas(CompanyName, 'RESTRINGIDO') then
            Error('No tiene permisos para acceder a este punto del menú en esta empresa');
    end;

    var
        TempLiqAccAnalysisView: Record "Cash Flow Account";
}