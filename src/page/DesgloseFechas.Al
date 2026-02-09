/// <summary>
/// Page Detalle fechas (ID 50049).
/// </summary>
page 50017 "Detalle fechas"
{
    SourceTable = "Detalle Fechas x Usuario";
    PageType = List;
    SaveValues = true;
    UsageCategory = Lists;
    ApplicationArea = aLL;

    layout
    {
        area(Content)
        {
            group(Filtros)
            {
                field("Filtro Fecha"; "FiltroFecha")
                {
                    ApplicationArea = All;
                    trigger OnValidate()
                    begin
                        Rec.SetFilter("Filtro Fecha", "FiltroFecha");
                        UserSetup.Get(UserId);
                        UserSetup.FiltroFechas := FiltroFecha;
                        UserSetup.EsquemaCuentas := Rec."Nombre Esquema";
                        UserSetup.Modify();
                        FiltroFecha := Rec.GetFilter(Rec."Filtro Fecha");
                    end;
                }
                field("Nombre Esquema"; FiltroEsquema)
                {
                    ApplicationArea = All;
                    Editable = true;
                    trigger OnValidate()
                    begin
                        Rec."Nombre Esquema" := FiltroEsquema;
                        if Rec.Modify() Then;
                        UserSetup.Get(UserId);
                        UserSetup.FiltroFechas := FiltroFecha;
                        UserSetup.EsquemaCuentas := FiltroEsquema;
                        UserSetup.Modify();

                    end;
                }
            }

            repeater(Detalle)
            {
                field(Fila; TextoFila(Rec.Fila)) { ApplicationArea = All; StyleExpr = Negrita; }

                field(Descripcion; TextoFila(Rec.Descripcion)) { ApplicationArea = All; StyleExpr = Negrita; }
                field(Fecha; TextoFila3(Rec.Fecha)) { ApplicationArea = All; StyleExpr = Negrita; }
                field("Empresa 1"; TextoFila2(Rec."Empresa 1"))
                {
                    ApplicationArea = All;
                    StyleExpr = Negrita;
                    Numeric = true;
                    CaptionClass = Cap(1);
                    trigger OnDrillDown()
                    BEGIN
                        Drill(1);
                    END;
                }

                field("Empresa 2"; TextoFila2(Rec."Empresa 2"))
                {
                    ApplicationArea = All;
                    StyleExpr = Negrita;
                    Numeric = true;
                    CaptionClass = Cap(2);
                    trigger OnDrillDown()
                    BEGIN
                        Drill(2);
                    END;
                }
                field("Empresa 3"; TextoFila2(Rec."Empresa 3"))
                {
                    ApplicationArea = All;
                    StyleExpr = Negrita;
                    Numeric = true;
                    CaptionClass = Cap(3);
                    trigger OnDrillDown()
                    BEGIN
                        Drill(3);
                    END;
                }
                field("Empresa 4"; TextoFila2(Rec."Empresa 4"))
                {
                    ApplicationArea = All;
                    StyleExpr = Negrita;
                    Numeric = true;
                    CaptionClass = Cap(4);
                    trigger OnDrillDown()
                    BEGIN
                        Drill(4);
                    END;
                }
                field("Empresa 5"; TextoFila2(Rec."Empresa 5"))
                {
                    ApplicationArea = All;
                    StyleExpr = Negrita;
                    Numeric = true;
                    CaptionClass = Cap(5);
                    trigger OnDrillDown()
                    BEGIN
                        Drill(5);
                    END;
                }
                field("Empresa 6"; TextoFila2(Rec."Empresa 6"))
                {
                    ApplicationArea = All;
                    StyleExpr = Negrita;
                    Numeric = true;
                    CaptionClass = Cap(6);
                    trigger OnDrillDown()
                    BEGIN
                        Drill(6);
                    END;
                }
                field("Empresa 7"; TextoFila2(Rec."Empresa 7"))
                {
                    ApplicationArea = All;
                    StyleExpr = Negrita;
                    Numeric = true;
                    CaptionClass = Cap(7);
                    trigger OnDrillDown()
                    BEGIN
                        Drill(7);
                    END;
                }
                field("Empresa 8"; TextoFila2(Rec."Empresa 8"))
                {
                    ApplicationArea = All;
                    StyleExpr = Negrita;
                    Numeric = true;
                    CaptionClass = Cap(8);
                    trigger OnDrillDown()
                    BEGIN
                        Drill(8);
                    END;
                }
                field("Empresa 9"; TextoFila2(Rec."Empresa 9"))
                {
                    ApplicationArea = All;
                    StyleExpr = Negrita;
                    Numeric = true;
                    CaptionClass = Cap(9);
                    trigger OnDrillDown()
                    BEGIN
                        Drill(9);
                    END;
                }
                // field("Empresa 10"; TextoFila2(Rec."Empresa 10"))
                // {
                //     ApplicationArea = All;
                //     Numeric = true;
                //     StyleExpr = Negrita;
                //     CaptionClass = Cap(10);
                //     trigger OnDrillDown()
                //     BEGIN
                //         Drill(10);
                //     END;
                // }
                //field("Empresa 11"; TextoFila2(Rec."Empresa 11"))
                // {
                //     ApplicationArea = All;
                //     Numeric = true;
                //     StyleExpr = Negrita;
                //     CaptionClass = Cap(11);
                //     trigger OnDrillDown()
                //     BEGIN
                //         Drill(11);
                //     END;
                // }
                field(Total; TextoFila2(Rec."Total"))
                {
                    ApplicationArea = All;
                    Numeric = true;
                    StyleExpr = NegritaRojo;
                    trigger OnDrillDown()
                    BEGIN
                        Drill(10);
                    END;
                }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action(Calcular)
            {
                ApplicationArea = All;
                Image = Calculate;
                ShortCutKey = F9;
                Caption = 'Calcular';
                trigger OnAction()
                VAR
                    rLiqAcc: Record "Cash Flow Account";
                    rLiqMov: Record "Cash Flow Forecast Entry";
                    ColumnValue: Decimal;
                    a: Integer;
                    Ventana: Dialog;
                    Control: Codeunit ControlProcesos;
                BEGIN
                    Ventana.OPEN('Calculando......');
                    Rec.Reset;
                    Rec.SetRange(Usuario, UserId);
                    Rec.SetFilter("Filtro Fecha", "FiltroFecha");
                    FiltroFecha := Rec.GetFilter(Rec."Filtro Fecha");
                    Rec.SETRANGE(Total);
                    if FiltroEsquema = '' Then
                        Rec.TESTFIELD("Nombre Esquema");
                    if FiltroEsquema = '' Then FiltroEsquema := Rec."Nombre Esquema";
                    if Rec.GETFILTER("Filtro Fecha") = '' THEN ERROR('Especifique fechas');
                    if Rec.GETRANGEMIN("Filtro Fecha") = Rec.GETRANGEMAX("Filtro Fecha") THEN ERROR('Especifique fechas');
                    LiqAccSchedLine.SETRANGE(LiqAccSchedLine."Schedule Name", FiltroEsquema);
                    Rec.DELETEALL;
                    if LiqAccSchedLine.FINDFIRST THEN
                        REPEAT
                            if (LiqAccSchedLine."Totaling Type" = LiqAccSchedLine."Totaling Type"::"Cash Flow Entry Accounts") AND
                            (LiqAccSchedLine.Totaling <> '') THEN BEGIN
                                rLiqAcc.SETFILTER(rLiqAcc."No.", LiqAccSchedLine.Totaling);
                                rLiqAcc.SETRANGE(rLiqAcc.Desglosar, TRUE);
                                if rLiqAcc.FINDFIRST THEN
                                    REPEAT
                                        Empresas.SetRange("Evaluation Company", false);
                                        if Empresas.FINDFIRST THEN
                                            REPEAT
                                                if Control.Permiso_Empresas(Empresas.Name) Then begin
                                                    rLiqMov.CHANGECOMPANY(Empresas.Name);
                                                    if (rLiqAcc."Source Type" in [rLiqAcc."Source Type"::"Cartera Clientes", rLiqAcc."Source Type"::Receivables]) AND
                                                    (rLiqAcc."Solo Cartera") THEN BEGIN
                                                        rLiqMov.SETRANGE("Cash Flow Date", Rec.GETRANGEMIN("Filtro Fecha"), CALCDATE('180D', Rec.GETRANGEMAX("Filtro Fecha")));
                                                    END ELSE
                                                        Rec.COPYFILTER("Filtro Fecha", rLiqMov."Cash Flow Date");
                                                    rLiqMov.SETRANGE(rLiqMov."Cash Flow Account No.", rLiqAcc."No.");
                                                    if rLiqMov.FINDFIRST THEN
                                                        REPEAT
                                                            Rec.Fila := LiqAccSchedLine."Row No.";
                                                            Rec.Descripcion := LiqAccSchedLine.Description;
                                                            Rec.Linea := LiqAccSchedLine."Line No.";
                                                            Rec.Fecha := rLiqMov."Cash Flow Date";
                                                            Rec."Totaling Type" := LiqAccSchedLine."Totaling Type";
                                                            Rec.Usuario := UserId;
                                                            Rec."Nombre Esquema" := FiltroEsquema;
                                                            if Rec.INSERT THEN;
                                                        UNTIL rLiqMov.NEXT = 0;
                                                end;
                                            UNTIL Empresas.NEXT = 0;
                                    // {  Fila:=LiqAccSchedLine."Row No.";
                                    // Descripcion:=LiqAccSchedLine.Description;
                                    // Linea:=LiqAccSchedLine."Line No.";
                                    // Fecha:=GETRANGEMIN("Filtro Fecha");
                                    // // if INSERT THEN;
                                    //                                 }
                                    UNTIL rLiqAcc.NEXT = 0;
                            END;
                            Rec.Fila := LiqAccSchedLine."Row No.";
                            Rec.Descripcion := LiqAccSchedLine.Description;
                            Rec.Linea := LiqAccSchedLine."Line No.";
                            Rec.Fecha := 0D;
                            Rec."Totaling Type" := LiqAccSchedLine."Totaling Type";
                            Rec.Usuario := UserId;
                            Rec."Nombre Esquema" := FiltroEsquema;
                            if Rec.INSERT THEN;
                        UNTIL LiqAccSchedLine.NEXT = 0;
                    if Rec.FINDFIRST THEN
                        REPEAT
                            if NOT LiqAccSchedLine.GET(FiltroEsquema, Rec.Linea) THEN EXIT;
                            if Rec.GETFILTER("Filtro Fecha") = '' THEN EXIT;

                            a := 0;
                            Liq.RESET;

                            Liq.SETRANGE(Liq."Column Layout Name", AccSheDuleName."Financial Report Column Group");

                            if Liq.FINDFIRST THEN
                                REPEAT
                                    a += 1;
                                    LiqAccSchedLine.GET(FiltroEsquema, Rec.Linea);
                                    if Rec.Fecha = 0D THEN
                                        Rec.COPYFILTER("Filtro Fecha", LiqAccSchedLine."Date Filter")
                                    ELSE
                                        LiqAccSchedLine.SETRANGE(LiqAccSchedLine."Date Filter", Rec.Fecha);
                                    if LiqAccSchedLine.Totaling = '' THEN BEGIN
                                        ColumnValue := 0;
                                        Rec."Empresa 1" := ColumnValue;
                                        Rec."Empresa 2" := ColumnValue;
                                        Rec."Empresa 3" := ColumnValue;
                                        Rec."Empresa 4" := ColumnValue;
                                        Rec."Empresa 5" := ColumnValue;
                                        Rec."Empresa 6" := ColumnValue;
                                        Rec."Empresa 7" := ColumnValue;
                                        Rec."Empresa 8" := ColumnValue;
                                        Rec."Empresa 9" := ColumnValue;
                                        // Rec."Empresa 10" := ColumnValue;
                                        //Rec."Empresa 11" := ColumnValue;
                                        Rec.Total := 0;
                                    END ELSE BEGIN
                                        ColumnValue := LiqAccSchedManagement.CalcCell(LiqAccSchedLine, Liq);
                                        if a = 1 THEN Rec."Empresa 1" := ColumnValue;
                                        if a = 2 THEN Rec."Empresa 2" := ColumnValue;
                                        if a = 3 THEN Rec."Empresa 3" := ColumnValue;
                                        if a = 4 THEN Rec."Empresa 4" := ColumnValue;
                                        if a = 5 THEN Rec."Empresa 5" := ColumnValue;
                                        if a = 6 THEN Rec."Empresa 6" := ColumnValue;
                                        if a = 7 THEN Rec."Empresa 7" := ColumnValue;
                                        if a = 8 THEN Rec."Empresa 8" := ColumnValue;
                                        if a = 9 THEN Rec."Empresa 9" := ColumnValue;
                                        //if a = 10 THEN Rec."Empresa 10" := ColumnValue;
                                        //if a = 11 THEN Rec."Empresa 11" := ColumnValue;

                                        if a = 10 THEN Rec.Total := ColumnValue;
                                        If (a = 10) And (LiqAccSchedLine."Totaling Type" in [LiqAccSchedLine."Totaling Type"::"Posting Accounts", LiqAccSchedLine."Totaling Type"::"Total Accounts"]) Then
                                            Rec."Total" := Rec."Empresa 1" + Rec."Empresa 2" + Rec."Empresa 3" + Rec."Empresa 4" + Rec."Empresa 5" + Rec."Empresa 6" + Rec."Empresa 7" + Rec."Empresa 8" + Rec."Empresa 9";
                                    END;
                                    Rec.MODIFY;
                                UNTIL Liq.NEXT = 0;

                        UNTIL Rec.NEXT = 0;
                    Rec.SETRANGE("Totaling Type", Rec."Totaling Type"::Linea);
                    Rec.MODIFYALL(Total, -1);
                    Rec.SETRANGE("Totaling Type");
                    Rec.SETFILTER(Total, '<>%1', 0);
                    if Rec.FINDFIRST THEN;
                    Ventana.CLOSE;
                end;
            }
            action(Imprimir)
            {
                ApplicationArea = All;
                Image = Report;
                Caption = 'Imprimir';
                trigger OnAction()
                VAR
                // pPrint : Report 50225;
                BEGIN
                    // CLEAR(pPrint);
                    // Rec.SETRANGE("Nombre Esquema","Nombre Esquema");
                    // pPrint.SETTABLEVIEW(Rec);
                    // pPrint.RUNMODAL;
                    // Rec.SETRANGE("Nombre Esquema");
                END;
            }
        }
    }
    VAR
        Liq: Record 334;
        FiltroFecha: Text;
        FiltroEsquema: Text;
        Negrita: Text;
        NegritaRojo: Text;
        AccSheDuleName: Record "Financial Report";
        LiqAccSchedLine: Record "Acc. Schedule Line";
        LiqAccSchedColumn: Record 334;
        Empresas: Record 2000000006;
        LiqAccSchedManagement: Codeunit LiqAccountScheduleManagement;
        AccSchedManagement: Codeunit "Procedures Standard";
        Text1140000: Label 'GENERICO';
        Text1140001: Label '* ERROR *';
        Text1140002: Label 'Fórmula columna: %1';
        Text1140003: Label 'Fórmula fila: %1';
        Text1140004: Label 'No disponible';
        Text1140005: Label '1,6,,Filtro dimensión %1';
        UserSetup: Record "User Setup";

    trigger OnOpenPage()
    begin
        UserSetup.Get(UserId);
        Rec.Reset();
        Rec.SetRange(Usuario, UserId);
        if not Rec.FindFirst() Then begin
            Rec.Linea := 0;
            Rec."Nombre Esquema" := UserSetup.EsquemaCuentas;
            if Rec.Insert() Then;
        end;
        if Rec.FINDFIRST THEN;
        FiltroFecha := UserSetup.FiltroFechas;
        FiltroEsquema := UserSetup.EsquemaCuentas;
        Rec.SetFilter("Filtro Fecha", FiltroFecha);
        Rec.SETFILTER(Total, '<>%1', 0);
        CurrPage.Update(false);
    end;

    trigger OnAfterGetRecord()
    VAR
        ColumnValue: Decimal;
        a: Integer;
    BEGIN
        Negrita := '';
        NegritaRojo := '';
        if LiqAccSchedLine.GET(Rec."Nombre Esquema", Rec.Linea) THEN
            if LiqAccSchedLine.Bold THEN Negrita := 'Strong';
        if LiqAccSchedLine.Bold Then NegritaRojo := 'Strong';
        if (LiqAccSchedLine.Bold) And (Rec.Fecha <> 0D) Then NegritaRojo := 'StrongAccent';
    END;

    PROCEDURE Cap(num: Integer): Text[30];
    var
        UserSetup: Record "User Setup";
    BEGIN
        If Rec."Nombre Esquema" = '' THEN begin
            UserSetup.Get(UserId);
            Rec."Nombre Esquema" := UserSetup.EsquemaCuentas;

        end;
        If not AccSheDuleName.GET(Rec."Nombre Esquema") THEN Exit(''); // ERROR('No existe el esquema de cuentas');
        Liq.SETRANGE(Liq."Column Layout Name", AccSheDuleName."Financial Report Column Group");
        Liq.FINDFIRST;
        if num > 1 THEN Liq.NEXT(num - 1);
        EXIT('3,' + Liq."Column Header");
    END;

    /// <summary>
    /// TextoFila2.
    /// </summary>
    /// <param name="D">Decimal.</param>
    /// <returns>Return value of type Text.</returns>
    procedure TextoFila2(D: Decimal): Text
    var
        T: Text;
    begin
        T := Format(D, 0, '<Precision,2:3><Standard Format,0>');
        if LiqAccSchedLine."Totaling Type" = LiqAccSchedLine."Totaling Type"::Linea THEN T := '_________';
        Exit(T);
    end;

    /// <summary>
    /// TextoFila3.
    /// </summary>
    /// <param name="D">Date.</param>
    /// <returns>Return value of type Text.</returns>
    procedure TextoFila3(D: Date): Text
    var
        T: Text;
    begin
        T := Format(D, 0, '<Day,2>/<Month,2>/<Year>');
        if LiqAccSchedLine."Totaling Type" = LiqAccSchedLine."Totaling Type"::Linea THEN T := '_________';
        Exit(T);
    end;

    /// <summary>
    /// TextoFila.
    /// </summary>
    /// <param name="T">Text.</param>
    /// <returns>Return value of type Text.</returns>
    procedure TextoFila(T: Text): Text
    begin
        if Rec.Fecha <> 0D THEN T := '';
        if LiqAccSchedLine."Totaling Type" = LiqAccSchedLine."Totaling Type"::Linea THEN T := '_________';
        Exit(T);
    end;

    PROCEDURE Conumna(num: Integer): Text[30];
    BEGIN
        AccSheDuleName.Get(Rec."Nombre Esquema");

        Liq.SETRANGE(Liq."Column Layout Name", AccSheDuleName."Financial Report Column Group");

        Liq.FINDFIRST;
        if num > 1 THEN Liq.NEXT(num - 1);
        EXIT('3,' + Liq."Column Header");
    END;

    PROCEDURE Drill(b: Integer);
    VAR
        LiqAcc: Record "Cash Flow Account";
        ChartOfAcc: Page "Cash Flow Account List";
        LiqAccAnalysisView: Record "G/L Account (Analysis View)";// "Liq. Account (Analysis View)";
        ChartofAccAnalysisView: Page "Chart of Accs. (Analysis View)";
        ChartofGlAccAnalysisView: Page "Chart of Accs. (Analysis View)";
        GlAccount: Record "G/L Account";
        FromDate: Date;
        ToDate: Date;
        FiscalStartDate: Date;
        LiqAccSchedName: Record "Financial Report";
        LiqAccSchedName2: Record "Acc. Schedule Name";
        ChartOfGLAcc: Page "Chart of Accounts (G/L)";
        TempColumnLayout: Record "Column Layout" TEMPORARY;
        FiltroEli: Option " ",Sí,No;
        Dim1Filter: Text;
        Dim2Filter: Text;
        Dim3Filter: Text;
        Dim4Filter: Text;
        Dim5Filter: Text;
        SalePersonFilter: Text;
        PeriodType: Enum "Analysis Period Type";
    BEGIN
        LiqAccSchedName.Get(Rec."Nombre Esquema");
        if LiqAccSchedName2.GET(Rec."Nombre Esquema") THEN LiqAccSchedName2.Init();
        if FiltroFecha <> '' then
            LiqAccSchedLine.SetFilter("Date Filter", FiltroFecha);
        LiqAccSchedLine.SetRange("Schedule Name", Rec."Nombre Esquema");
        Rec.COPYFILTER("Filtro Fecha", LiqAccSchedLine."Date Filter");

        Liq.SETRANGE(Liq."Column Layout Name", LiqAccSchedName."Financial Report Column Group");

        Liq.FINDFIRST;
        if b > 1 THEN Liq.NEXT(b - 1);
        if LiqAccSchedLine.GET(Rec."Nombre Esquema", Rec.Linea) THEN;

        WITH LiqAccSchedLine DO BEGIN
            case LiqAccSchedLine."Totaling Type" of
                LiqAccSchedLine."Totaling Type"::"Cash Flow Entry Accounts", LiqAccSchedLine."Totaling Type"::"Cash Flow Total Accounts":
                    begin


                        if Liq.Empresa <> '' THEN
                            LiqAcc.CHANGECOMPANY(Liq.Empresa);
                        if Liq."Column Type" = Liq."Column Type"::Formula THEN
                            MESSAGE(Text1140002, Liq.Formula)
                        ELSE
                            if "Totaling Type" IN ["Totaling Type"::Formula, "Totaling Type"::"Set Base For Percent"] THEN
                                MESSAGE(Text1140003, Totaling)
                            ELSE
                                if Totaling <> '' THEN BEGIN

                                    COPYFILTER("Cash Flow Forecast Filter", LiqAcc."Cash Flow Forecast Filter");
                                    LiqAccSchedManagement.SetLiqAccRowFilter(LiqAcc, LiqAccSchedLine);
                                    LiqAccSchedManagement.SetLiqAccColumnFilter(LiqAcc, LiqAccSchedLine, Liq);
                                    LiqAccSchedName.GET(Rec."Nombre Esquema");
                                    if LiqAccSchedName2."Analysis View Name" = '' THEN BEGIN
                                        COPYFILTER("Dimension 1 Filter", LiqAcc."Global Dimension 1 Filter");
                                        COPYFILTER("Dimension 2 Filter", LiqAcc."Global Dimension 2 Filter");
                                        LiqAcc.FILTERGROUP(2);
                                        LiqAcc.SETFILTER("Global Dimension 1 Filter", "Dimension 1 Totaling");
                                        LiqAcc.SETFILTER("Global Dimension 2 Filter", "Dimension 2 Totaling");
                                        LiqAcc.FILTERGROUP(6);
                                        LiqAcc.SETFILTER(
                                          "Global Dimension 1 Filter",
                                          LiqAccSchedManagement.GetDimTotalingFilter(1, Liq."Dimension 1 Totaling"));
                                        LiqAcc.SETFILTER(
                                          "Global Dimension 2 Filter",
                                          LiqAccSchedManagement.GetDimTotalingFilter(2, Liq."Dimension 2 Totaling"));
                                        LiqAcc.FILTERGROUP(0);
                                        if Liq.Empresa <> '' Then LiqAcc.ChangeCompany(Liq.Empresa);
                                        if Liq.Empresa <> '' THEN
                                            LiqAcc.MODIFYALL(Empresa, Liq.Empresa);
                                        if Rec.Fecha <> 0D THEN
                                            LiqAcc.SETRANGE(LiqAcc."Date Filter", Rec.Fecha);
                                        LiqAccSchedManagement.CalcCell(LiqAccSchedLine, Liq);
                                        COMMIT;
                                        CLEAR(ChartOfAcc);
                                        ChartOfAcc.Empresa(Liq.Empresa);
                                        ChartOfAcc.SETTABLEVIEW(LiqAcc);
                                        ChartOfAcc.RUNMODAL;
                                        //FORM.RUN(FORM::"Chart of Liquidity Accounts",LiqAcc)
                                    END ELSE BEGIN
                                        LiqAcc.COPYFILTER("Date Filter", LiqAccAnalysisView."Date Filter");
                                        LiqAcc.COPYFILTER("Cash Flow Forecast Filter", LiqAccAnalysisView."Cash Flow Forecast Filter");
                                        LiqAccAnalysisView.SETRANGE("Analysis View Filter", LiqAccSchedName2."Analysis View Name");
                                        COPYFILTER("Dimension 1 Filter", LiqAccAnalysisView."Dimension 1 Filter");
                                        COPYFILTER("Dimension 2 Filter", LiqAccAnalysisView."Dimension 2 Filter");
                                        COPYFILTER("Dimension 3 Filter", LiqAccAnalysisView."Dimension 3 Filter");
                                        COPYFILTER("Dimension 4 Filter", LiqAccAnalysisView."Dimension 4 Filter");
                                        LiqAccAnalysisView.FILTERGROUP(2);
                                        LiqAccAnalysisView.SETFILTER("Dimension 1 Filter", LiqAccSchedManagement.GetDimTotalingFilter(1, "Dimension 1 Totaling"));
                                        LiqAccAnalysisView.SETFILTER("Dimension 2 Filter", LiqAccSchedManagement.GetDimTotalingFilter(2, "Dimension 2 Totaling"));
                                        LiqAccAnalysisView.SETFILTER("Dimension 3 Filter", LiqAccSchedManagement.GetDimTotalingFilter(3, "Dimension 3 Totaling"));
                                        LiqAccAnalysisView.SETFILTER("Dimension 4 Filter", LiqAccSchedManagement.GetDimTotalingFilter(4, "Dimension 4 Totaling"));
                                        LiqAccAnalysisView.FILTERGROUP(6);
                                        LiqAccAnalysisView.SETFILTER(
                                          "Dimension 1 Filter",
                                          LiqAccSchedManagement.GetDimTotalingFilter(1, Liq."Dimension 1 Totaling"));
                                        LiqAccAnalysisView.SETFILTER(
                                          "Dimension 2 Filter",
                                          LiqAccSchedManagement.GetDimTotalingFilter(2, Liq."Dimension 2 Totaling"));
                                        LiqAccAnalysisView.SETFILTER(
                                          "Dimension 3 Filter",
                                          LiqAccSchedManagement.GetDimTotalingFilter(3, Liq."Dimension 3 Totaling"));
                                        LiqAccAnalysisView.SETFILTER(
                                          "Dimension 4 Filter",
                                          LiqAccSchedManagement.GetDimTotalingFilter(4, Liq."Dimension 4 Totaling"));
                                        LiqAccAnalysisView.FILTERGROUP(0);
                                        CLEAR(ChartofAccAnalysisView);
                                        ChartofAccAnalysisView.InsertTempLiqAccAnalysisViews(LiqAcc);
                                        ChartofAccAnalysisView.SETTABLEVIEW(LiqAccAnalysisView);
                                        ChartofAccAnalysisView.RUN;
                                    END;
                                END;
                    end;
                LiqAccSchedLine."Totaling Type"::"Posting Accounts", LiqAccSchedLine."Totaling Type"::"Total Accounts":
                    begin
                        if Liq.Empresa <> '' THEN
                            LiqAcc.CHANGECOMPANY(Liq.Empresa);
                        if Liq."Column Type" = Liq."Column Type"::Formula THEN
                            MESSAGE(Text1140002, Liq.Formula)
                        ELSE
                            if "Totaling Type" IN ["Totaling Type"::Formula, "Totaling Type"::"Set Base For Percent"] THEN
                                MESSAGE(Text1140003, Totaling)
                            ELSE
                                TempColumnLayout := Liq;
                        FiltroEli := FiltroEli::" ";
                        Dim1Filter := LiqAccSchedLine.GetFilter("Dimension 1 Filter");
                        Dim2Filter := LiqAccSchedLine.GetFilter("Dimension 2 Filter");
                        Dim3Filter := LiqAccSchedLine.GetFilter("Dimension 3 Filter");
                        Dim4Filter := LiqAccSchedLine.GetFilter("Dimension 4 Filter");
                        Dim5Filter := LiqAccSchedLine.GetFilter("Dimension 5 Filter");
                        SalePersonFilter := LiqAccSchedLine.GetFilter("Salesperson Filter");
                        PeriodType := PeriodType::Month;
                        AccSchedManagement.CalcCell(LiqAccSchedLine, Liq, false);
                        AccSchedManagement.DrillDownFromOverviewPage(TempColumnLayout, LiqAccSchedLine, PeriodType.AsInteger(), FiltroEli, Dim1Filter, Dim2Filter, Dim3Filter, Dim4Filter, Dim5Filter, SalePersonFilter);


                    end;
            end;
        END;
    END;


}
