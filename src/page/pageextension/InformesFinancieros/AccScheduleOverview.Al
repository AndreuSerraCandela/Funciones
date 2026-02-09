/// <summary>
/// PageExtension AccScheduleOverview (ID 80287).
/// </summary>
pageextension 80188 AccScheduleOverview Extends "Acc. Schedule Overview"
{
    layout
    {
        addlast(General)
        {
            field("Filtro vendedor"; Rec."Salesperson Filter") { ApplicationArea = All; }
        }
        addlast("Dimension Filters")
        {

            field("Dimension 4 Filter"; Rec."Dimension 4 Filter")
            {
                ApplicationArea = All;
                Enabled = Dim4FilterENABLED;
                CaptionClass = FormGetCaptionClass(4);

                trigger OnLookup(var Text: Text): Boolean
                BEGIN
                    EXIT(FormLookUpDimFilter(AnalysisView."Dimension 4 Code", Text));
                END;

                trigger OnValidate()
                BEGIN
                    CurrPage.UPDATE;
                END;
            }
            field("Dimension 3 Filter"; Rec."Dimension 3 Filter")
            {
                Enabled = Dim3FilterENABLED;
                ApplicationArea = All;
                CaptionClass = FormGetCaptionClass(3);
                trigger OnLookup(var Text: Text): Boolean
                BEGIN
                    EXIT(FormLookUpDimFilter(AnalysisView."Dimension 3 Code", Text));
                END;

                trigger OnValidate()
                BEGIN
                    CurrPage.UPDATE;
                END;
            }
            field("Dimension 5 Filter"; Rec."Dimension 5 Filter")
            {
                Enabled = Dim5FilterENABLED;
                ApplicationArea = All;
                CaptionClass = FormGetCaptionClass(5);
                trigger OnLookup(var Text: Text): Boolean
                BEGIN
                    EXIT(FormLookUpDimFilter(AnalysisView."Dimension 5 Totaling", Text));
                END;

                trigger OnValidate()
                BEGIN
                    CurrPage.UPDATE;
                END;
            }

        }
        modify(Dim3Filter)
        {
            Visible = false;
        }
        modify(Dim4Filter)
        {
            Visible = false;
        }
        addafter("Row No.")
        {
            field(Indentation; Rec.Indentation)
            {
                ApplicationArea = All;
            }
        }


        // fixed(Empresas)
        // {
        // Caption = 'Empresas';

        // group(Empresa)
        // {
        //     field(CompanyFilter; CompanyFilter)
        //     {
        //         ApplicationArea = All;
        //         Caption = 'Filtro Empresas';
        //         Editable = false;

        //         trigger OnDrillDown()
        //         var
        //             Company: Record 2000000006;
        //             rInf: Record "Company Information";
        //             C: Label '''';
        //         begin
        //             CompanyFilter := '';
        //             if PAGE.RUNMODAL(80357, Company) = ACTION::LookupOK THEN BEGIN
        //                 if Company.FINDFIRST THEN
        //                     REPEAT
        //                         rInf.ChangeCompany(Company.Name);
        //                         rInf.Get();
        //                         if rInf.Seleccionar = TRUE THEN CompanyFilter := CompanyFilter + '|' + C + Company.Name + C;
        //                     UNTIL Company.NEXT = 0;
        //             END;
        //             if STRLEN(CompanyFilter) > 1 THEN CompanyFilter := COPYSTR(CompanyFilter, 2);
        //             Rec.SETFILTER("Company Filter", CompanyFilter);
        //             CurrPage.UPDATE(FALSE);
        //         end;
        //     }
        // }
        // }
    }
    local procedure FormGetCaptionClass(DimNo: Integer) Result: Text[250]
    var
        IsHandled: Boolean;

    begin
        IsHandled := false;
        if IsHandled then
            exit(Result);

        case DimNo of
            1:
                begin
                    if AnalysisView."Dimension 1 Code" <> '' then
                        exit('1,6,' + AnalysisView."Dimension 1 Code");

                    exit(StrSubstNo(Text005, DimNo));
                end;
            2:
                begin
                    if AnalysisView."Dimension 2 Code" <> '' then
                        exit('1,6,' + AnalysisView."Dimension 2 Code");

                    exit(StrSubstNo(Text005, DimNo));
                end;
            3:
                begin
                    if AnalysisView."Dimension 3 Code" <> '' then
                        exit('1,6,' + AnalysisView."Dimension 3 Code");

                    exit(StrSubstNo(Text005, DimNo));
                end;
            4:
                begin
                    if AnalysisView."Dimension 4 Code" <> '' then
                        exit('1,6,' + AnalysisView."Dimension 4 Code");

                    exit(StrSubstNo(Text005, DimNo));
                end;
            5:
                exit(Rec.FieldCaption("Date Filter"));
            6:
                exit(Rec.FieldCaption("Cash Flow Forecast Filter"));
        end;
    end;

    local procedure FormLookUpDimFilter(Dim: Code[20]; var Text: Text): Boolean
    var
        DimVal: Record "Dimension Value";
        DimValList: Page "Dimension Value List";

    begin

        if Dim = '' THEN
            EXIT(FALSE);
        DimValList.LOOKUPMODE(TRUE);
        DimVal.SETRANGE("Dimension Code", Dim);
        DimValList.SETTABLEVIEW(DimVal);
        if DimValList.RUNMODAL = ACTION::LookupOK THEN BEGIN
            DimValList.GETRECORD(DimVal);
            Text := DimValList.GetSelectionFilter;
            EXIT(TRUE);
        END ELSE
            EXIT(FALSE)
    end;

    local procedure FindPeriod(SearchText: Text)
    var
        Calendar: Record "Date";
        PeriodFormMgt: Codeunit PeriodPageManagement;

    begin

        if Rec.GETFILTER("Date Filter") <> '' THEN BEGIN
            Calendar.SETFILTER("Period Start", Rec.GETFILTER("Date Filter"));
            if NOT PeriodFormMgt.FindDate('+', Calendar, PeriodType) THEN
                PeriodFormMgt.FindDate('+', Calendar, PeriodType::Day);
            Calendar.SETRANGE("Period Start");
        END;
        PeriodFormMgt.FindDate(SearchText, Calendar, PeriodType);
        Rec.SETRANGE("Date Filter", Calendar."Period Start", Calendar."Period End");
        if Rec.GETRANGEMIN("Date Filter") = Rec.GETRANGEMAX("Date Filter") THEN
            Rec.SETRANGE("Date Filter", Rec.GETRANGEMIN("Date Filter"));
    end;



    trigger OnOpenPage()

    var
        Control: Codeunit ControlProcesos;
    begin
        If Control.AccesoProibido_Empresas(CompanyName, 'RESTRINGIDO') then
            Error('No tiene permisos para acceder a este punto del menú en esta empresa');


        GLSetup.GET;
        if NewCurrentSchedName <> '' THEN
            CurrentSchedName := NewCurrentSchedName;
        if CurrentSchedName = '' THEN
            CurrentSchedName := Text000;
        if NewCurrentColumnName <> '' THEN
            CurrentColumnName := NewCurrentColumnName;
        if CurrentColumnName = '' THEN
            CurrentColumnName := Text000;
        AccSchedManagement.CopyColumnsToTemp(CurrentColumnName, TempColumnLayout);
        AccSchedManagement.OpenSchedule(CurrentSchedName, Rec);
        AccSchedManagement.OpenColumns(CurrentColumnName, TempColumnLayout);
        AccSchedManagement.CheckAnalysisView(CurrentSchedName, CurrentColumnName, TRUE);

        if AccSchedName.GET(CurrentSchedName) THEN
            if AccSchedName."Analysis View Name" <> '' THEN
                AnalysisView.GET(AccSchedName."Analysis View Name")
            ELSE BEGIN
                CLEAR(AnalysisView);
                AnalysisView."Dimension 1 Code" := GLSetup."Global Dimension 1 Code";
                AnalysisView."Dimension 3 Code" := GLSetup."Shortcut Dimension 3 Code";
                AnalysisView."Dimension 4 Code" := GLSetup."Shortcut Dimension 4 Code";
                AnalysisView."Dimension 5 Totaling" := GLSetup."Shortcut Dimension 5 Code";

            END;

        FindPeriod('');
        Dim1FilterENABLED := AnalysisView."Dimension 1 Code" <> '';
        Dim5FilterENABLED := AnalysisView."Dimension 5 Totaling" <> '';
        Dim3FilterENABLED := AnalysisView."Dimension 3 Code" <> '';
        Dim4FilterENABLED := AnalysisView."Dimension 4 Code" <> '';


    end;

    var
        Text000: Label 'GENERICO';
        Text001: Label '* ERROR *';
        Text002: Label 'Fórmula columna: %1';
        Text003: Label 'Fórmula fila: %1';
        Text004: Label 'No disponible';
        Text005: Label '1,6,,Filtro dimensión %1';
        Dim1FilterENABLED: Boolean;
        Dim2FilterENABLED: Boolean;
        Dim3FilterENABLED: Boolean;
        Dim4FilterENABLED: Boolean;
        Dim5FilterENABLED: Boolean;
        GLSetup: Record "General Ledger Setup";
        CompanyFilter: Text;
        AccSchedName: Record "Acc. Schedule Name";
        AnalysisView: Record "Analysis View";
        AccSchedManagement: Codeunit "Procedures Standard";
        TempColumnLayout: Record "Column Layout" temporary;
        CurrentSchedName: Code[20];
        CurrentColumnName: Code[20];
        NewCurrentSchedName: Code[20];
        NewCurrentColumnName: Code[20];
        ShowError: Option None,"Division by Zero","Period Error",Both;
        ColumnValue: Decimal;
        PeriodType: Enum "Analysis Period Type";// Option Day,Week,Month,Quarter,Year,"Accounting Period";
        UseAmtsInAddCurr: Boolean;
        FiltroEli: Option " ",Sí,No;



}
