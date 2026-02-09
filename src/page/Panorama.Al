/// <summary>
/// Page Panorama (ID 50035).
/// </summary>
page 50010 "Panorama"
{
    Caption = 'Panorama';
    DataCaptionExpression = CurrentSchedName + ' - ' + CurrentColumnName;
    DeleteAllowed = false;
    InsertAllowed = false;
    LinksAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    PromotedActionCategories = 'Nuevo,Proceso,Informes,Columna,Periodo';
    SaveValues = true;
    ShowFilter = false;
    SourceTable = "Acc. Schedule Line";

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field(CurrentSchedName; CurrentSchedName)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Nombre esquema de cuentas';
                    Importance = Promoted;
                    Lookup = true;
                    LookupPageID = "Account Schedule Names";
                    ToolTip = 'Specifies the name of the account schedule to be shown in the window.';

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        Result: Boolean;
                    begin
                        Result := AccSchedManagement.LookupName(CurrentSchedName, Text);
                        CurrentSchedName := Text;
                        CurrentSchedNameOnAfterValidate;
                        exit(Result);
                    end;

                    trigger OnValidate()
                    begin
                        AccSchedManagement.CheckName(CurrentSchedName);
                        CurrentSchedNameOnAfterValidate;
                    end;
                }
                field(CurrentColumnName; CurrentColumnName)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Plantilla de Columna';
                    Lookup = true;
                    TableRelation = "Column Layout Name".Name;
                    ToolTip = 'Specifies the name of the column layout that you want to use in the window.';

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        Result: Boolean;
                    begin
                        Result := AccSchedManagement.LookupColumnName(CurrentColumnName, Text);
                        CurrentColumnName := Text;
                        CurrentColumnNameOnAfterValidate;
                        exit(Result);
                    end;

                    trigger OnValidate()
                    begin
                        AccSchedManagement.CheckColumnName(CurrentColumnName);
                        CurrentColumnNameOnAfterValidate;
                    end;
                }
                field(UseAmtsInAddCurr; UseAmtsInAddCurr)
                {
                    ApplicationArea = Suite;
                    Caption = 'Ver en divisa adicional';
                    MultiLine = true;
                    ToolTip = 'Specifies if the reported amounts are shown in the additional reporting currency.';
                    Visible = UseAmtsInAddCurrVisible;

                    trigger OnValidate()
                    begin
                        CurrPage.Update();
                    end;
                }
                field(PeriodType; PeriodType)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Ver Por';
                    Importance = Promoted;
                    ToolTip = 'Specifies by which period amounts are displayed.';

                    trigger OnValidate()
                    begin
                        FindPeriod(Rec, '', PeriodType);
                        DateFilter := Rec.GetFilter(Rec."Date Filter");
                        CurrPage.Update();
                    end;
                }
                field(DateFilter; DateFilter)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Filtro Fecha';
                    Importance = Promoted;
                    ToolTip = 'Specifies the dates that will be used to filter the amounts in the window.';

                    trigger OnValidate()
                    var
                        FilterTokens: Codeunit "Filter Tokens";
                    begin
                        FilterTokens.MakeDateFilter(DateFilter);
                        Rec.SetFilter("Date Filter", DateFilter);
                        DateFilter := Rec.GetFilter("Date Filter");
                        CurrPage.Update();
                    end;
                }
                field("Filtro vendedor"; SalePersonFilter)
                {
                    ApplicationArea = All;
                    Enabled = true;
                    Caption = 'Filtro Vendedor';
                    trigger OnLookup(var Text: Text): Boolean
                    var
                        DimValue: Record "Salesperson/Purchaser";
                        Result: Boolean;
                    BEGIN
                        if Page.Runmodal(0, DimValue) In [Action::LookupOK, Action::Ok] Then begin
                            Text := DimValue.Code;
                            Result := true;
                            SetDimFilters(6, Text);
                            SalePersonFilter := text;
                            Exit(Result);
                        end;
                    END;

                    trigger OnValidate()
                    BEGIN
                        SetDimFilters(6, SalePersonFilter);
                    END;
                }
            }
            group("Dimension Filters")
            {
                Caption = 'Dimension Filters';
                field(Dim1Filter; Dim1Filter)
                {
                    ApplicationArea = Dimensions;
                    CaptionClass = FormGetCaptionClass(1);
                    Caption = 'Dimension 1 Filter';
                    Enabled = Dim1FilterEnable;
                    Importance = Promoted;
                    ToolTip = 'Specifies a filter for the Dimension 1 for which entries will be shown in the matrix window.';
                    Visible = Dim1FilterEnable;

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        DimValue: Record "Dimension Value";
                        Result: Boolean;
                    begin
                        Result := DimValue.LookUpDimFilter(AnalysisView."Dimension 1 Code", Text);
                        SetDimFilters(1, Text);
                        Dim1Filter := text;
                        Exit(Result);
                    end;

                    trigger OnValidate()
                    begin
                        SetDimFilters(1, Dim1Filter);
                    end;
                }
                field(Dim2Filter; Dim2Filter)
                {
                    ApplicationArea = Dimensions;
                    CaptionClass = FormGetCaptionClass(2);
                    Caption = 'Dimension 2 Filter';
                    Enabled = Dim2FilterEnable;
                    Importance = Promoted;
                    ToolTip = 'Specifies a filter for the Dimension 2 for which entries will be shown in the matrix window.';
                    Visible = Dim2FilterEnable;

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        DimValue: Record "Dimension Value";
                        Result: Boolean;
                    begin
                        Result := DimValue.LookUpDimFilter(AnalysisView."Dimension 2 Code", Text);
                        SetDimFilters(2, Text);
                        Dim2Filter := text;
                        Exit(Result);
                    end;

                    trigger OnValidate()
                    begin
                        SetDimFilters(2, Dim2Filter);
                    end;
                }
                field(Dim4Filter; Dim4Filter)
                {
                    ApplicationArea = All;
                    Enabled = True;// Dim4FilterENABLE;
                    CaptionClass = FormGetCaptionClass(4);
                    Caption = 'Dimension 4 Filter';
                    Importance = Promoted;

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        DimValue: Record "Dimension Value";
                        Result: Boolean;
                    BEGIN
                        Result := DimValue.LookUpDimFilter(AnalysisView."Dimension 4 Code", Text);
                        SetDimFilters(4, Text);
                        Dim4Filter := text;
                        Exit(Result);
                    END;

                    trigger OnValidate()
                    BEGIN
                        SetDimFilters(4, Dim4Filter);
                    END;
                }
                field(Dim3Filter; Dim3Filter)
                {
                    Enabled = True;//Dim3FilterENABLE;
                    ApplicationArea = All;
                    Caption = 'Dimension 3 Filter';
                    Importance = Promoted;
                    CaptionClass = FormGetCaptionClass(3);
                    trigger OnLookup(var Text: Text): Boolean
                    var
                        DimValue: Record "Dimension Value";
                        Result: Boolean;
                    BEGIN
                        Result := DimValue.LookUpDimFilter(AnalysisView."Dimension 3 Code", Text);
                        SetDimFilters(3, Text);
                        Dim3Filter := text;
                        Exit(Result);
                    END;

                    trigger OnValidate()
                    BEGIN
                        SetDimFilters(3, Dim3Filter);
                    END;
                }
                field(Dim5Filter; Dim5Filter)
                {
                    ApplicationArea = All;
                    Enabled = True;// Dim4FilterENABLE;
                    CaptionClass = FormGetCaptionClass(5);
                    Caption = 'Dimension 5 Filter';
                    Importance = Promoted;

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        DimValue: Record "Dimension Value";
                        Result: Boolean;
                    BEGIN
                        Result := DimValue.LookUpDimFilter(AnalysisView."Dimension 5 Totaling", Text);
                        SetDimFilters(5, Text);
                        Dim5Filter := text;
                        Exit(Result);
                    END;

                    trigger OnValidate()
                    BEGIN
                        SetDimFilters(5, Dim5Filter);
                    END;
                }
                field("Filtro Eliminaciones"; FiltroEli)
                {
                    ApplicationArea = All;
                    trigger OnValidate()
                    begin

                        CASE FiltroEli OF
                            FiltroEli::" ":
                                Rec.SETRANGE("Filtro Eliminaciones");
                            FiltroEli::Sí:
                                Rec.SETRANGE("Filtro Eliminaciones", TRUE);
                            FiltroEli::No:
                                Rec.SETRANGE("Filtro Eliminaciones", FALSE);

                        END;
                        CurrPage.Update();
                    END;
                }
                field(CostCenterFilter; CostCenterFilter)
                {
                    ApplicationArea = CostAccounting;
                    Caption = 'Filtro Centro Coste';
                    Importance = Additional;
                    ToolTip = 'Specifies a cost center for which you want to view account amounts.';

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        CostCenter: Record "Cost Center";
                        Result: Boolean;
                    begin
                        Result := CostCenter.LookupCostCenterFilter(Text);
                        CostCenterFilter := Text;
                        if CostCenterFilter = '' then
                            Rec.SetRange("Cost Center Filter")
                        else
                            Rec.SetFilter("Cost Center Filter", CostCenterFilter);

                        OnAfterValidateCostCenterFilter(Rec, CostCenterFilter, Dim1Filter);
                        Exit(Result);
                    end;

                    trigger OnValidate()
                    begin
                        if CostCenterFilter = '' then
                            Rec.SetRange("Cost Center Filter")
                        else
                            Rec.SetFilter("Cost Center Filter", CostCenterFilter);

                        OnAfterValidateCostCenterFilter(Rec, CostCenterFilter, Dim1Filter);
                        CurrPage.Update();
                    end;
                }
                field(CostObjectFilter; CostObjectFilter)
                {
                    ApplicationArea = CostAccounting;
                    Caption = 'Filtro Objeto Coste';
                    Importance = Additional;
                    ToolTip = 'Specifies a cost object for which you want to view account amounts.';

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        CostObject: Record "Cost Object";
                        Result: Boolean;
                    begin
                        Result := CostObject.LookupCostObjectFilter(Text);
                        CostObjectFilter := Text;
                        if CostObjectFilter = '' then
                            Rec.SetRange("Cost Object Filter")
                        else
                            Rec.SetFilter("Cost Object Filter", CostObjectFilter);

                        OnAfterValidateCostObjectFilter(Rec, CostObjectFilter, Dim2Filter);
                        Exit(Result);
                    end;

                    trigger OnValidate()
                    begin
                        if CostObjectFilter = '' then
                            Rec.SetRange("Cost Object Filter")
                        else
                            Rec.SetFilter("Cost Object Filter", CostObjectFilter);

                        OnAfterValidateCostObjectFilter(Rec, CostObjectFilter, Dim2Filter);
                        CurrPage.Update();
                    end;
                }
                // field(CashFlowFilter; CashFlowFilter)
                // {
                //     ApplicationArea = Dimensions;
                //     Caption = 'Filtro Tesorería';
                //     Importance = Additional;
                //     ToolTip = 'Specifies a dimension filter for the cash flow, for which you want to view account amounts.';

                //     trigger OnLookup(var Text: Text): Boolean
                //     var
                //         CashFlowForecast: Record "Cash Flow Forecast";
                //         Result: Boolean;
                //     begin
                //         Result := CashFlowForecast.LookupCashFlowFilter(Text);
                //         CashFlowFilter := Text;
                //         if CashFlowFilter = '' then
                //             SetRange("Cash Flow Forecast Filter")
                //         else
                //             SetFilter("Cash Flow Forecast Filter", CashFlowFilter);
                //         exit(Result);
                //     end;

                //     trigger OnValidate()
                //     begin
                //         if CashFlowFilter = '' then
                //             SetRange("Cash Flow Forecast Filter")
                //         else
                //             SetFilter("Cash Flow Forecast Filter", CashFlowFilter);
                //         CurrPage.Update();
                //     end;
                // }
                field("G/LBudgetFilter"; GLBudgetFilter)
                {
                    ApplicationArea = Suite;
                    Caption = 'Filtro Presupuesto';
                    Importance = Promoted;
                    ToolTip = 'Specifies a code for a general ledger budget that the account schedule line will be filtered on.';

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        Result: Boolean;
                    begin
                        Result := Rec.LookupGLBudgetFilter(Text);
                        GLBudgetFilter := Text;
                        if Result then begin
                            Rec.SetFilter("G/L Budget Filter", Text);
                            Text := Rec.GetFilter("G/L Budget Filter");
                        end;
                        exit(Result);
                    end;

                    trigger OnValidate()
                    begin
                        if GLBudgetFilter = '' then
                            Rec.SetRange("G/L Budget Filter")
                        else
                            Rec.SetFilter("G/L Budget Filter", GLBudgetFilter);
                        CurrPage.Update();
                    end;
                }
                field(CostBudgetFilter; CostBudgetFilter)
                {
                    ApplicationArea = CostAccounting;
                    Caption = 'Filtro presupuesto Coste';
                    Importance = Additional;
                    ToolTip = 'Specifies a code for a cost budget that the account schedule line will be filtered on.';

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        Result: Boolean;
                    begin
                        Result := Rec.LookupCostBudgetFilter(Text);
                        CostBudgetFilter := Text;
                        if Result then begin
                            Rec.SetFilter("Cost Budget Filter", Text);
                            Text := Rec.GetFilter("Cost Budget Filter");
                        end;
                        exit(Result);
                    end;

                    trigger OnValidate()
                    begin
                        if CostBudgetFilter = '' then
                            Rec.SetRange("Cost Budget Filter")
                        else
                            Rec.SetFilter("Cost Budget Filter", CostBudgetFilter);
                        CurrPage.Update();
                    end;
                }
            }
            repeater(Control48)
            {
                Editable = false;
                IndentationColumn = Rec.Indentation;
                IndentationControls = Description;
                ShowCaption = false;
                field("Row No."; Rec."Row No.")
                {
                    Caption = 'Nº Fila';
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies a number that identifies the line.';
                }
                field(Description; Rec.Description)
                {
                    Caption = 'Descripción';
                    ApplicationArea = Basic, Suite;
                    Style = Strong;
                    StyleExpr = Rec.Bold;
                    ToolTip = 'Specifies text that will appear on the account schedule line.';
                }
                field(ColumnValues1; ColumnValues[1])
                {
                    ApplicationArea = Basic, Suite;
                    AutoFormatExpression = FormatStr(1);
                    AutoFormatType = 11;
                    BlankZero = true;
                    CaptionClass = '3,' + ColumnCaptions[1];
                    StyleExpr = ColumnStyle1;

                    trigger OnDrillDown()
                    begin
                        DrillDown(1);
                    end;
                }
                field(ColumnValues2; ColumnValues[2])
                {
                    ApplicationArea = Basic, Suite;
                    AutoFormatExpression = FormatStr(2);
                    AutoFormatType = 11;
                    BlankZero = true;
                    CaptionClass = '3,' + ColumnCaptions[2];
                    StyleExpr = ColumnStyle2;
                    Visible = NoOfColumns >= 2;

                    trigger OnDrillDown()
                    begin
                        DrillDown(2);
                    end;
                }
                field(ColumnValues3; ColumnValues[3])
                {
                    ApplicationArea = Basic, Suite;
                    AutoFormatExpression = FormatStr(3);
                    AutoFormatType = 11;
                    BlankZero = true;
                    CaptionClass = '3,' + ColumnCaptions[3];
                    StyleExpr = ColumnStyle3;
                    Visible = NoOfColumns >= 3;

                    trigger OnDrillDown()
                    begin
                        DrillDown(3);
                    end;
                }
                field(ColumnValues4; ColumnValues[4])
                {
                    ApplicationArea = Basic, Suite;
                    AutoFormatExpression = FormatStr(4);
                    AutoFormatType = 11;
                    BlankZero = true;
                    CaptionClass = '3,' + ColumnCaptions[4];
                    StyleExpr = ColumnStyle4;
                    Visible = NoOfColumns >= 4;

                    trigger OnDrillDown()
                    begin
                        DrillDown(4);
                    end;
                }
                field(ColumnValues5; ColumnValues[5])
                {
                    ApplicationArea = Basic, Suite;
                    AutoFormatExpression = FormatStr(5);
                    AutoFormatType = 11;
                    BlankZero = true;
                    CaptionClass = '3,' + ColumnCaptions[5];
                    StyleExpr = ColumnStyle5;
                    Visible = NoOfColumns >= 5;

                    trigger OnDrillDown()
                    begin
                        DrillDown(5);
                    end;
                }
                field(ColumnValues6; ColumnValues[6])
                {
                    ApplicationArea = Basic, Suite;
                    AutoFormatExpression = FormatStr(6);
                    AutoFormatType = 11;
                    BlankZero = true;
                    CaptionClass = '3,' + ColumnCaptions[6];
                    StyleExpr = ColumnStyle6;
                    Visible = NoOfColumns >= 6;

                    trigger OnDrillDown()
                    begin
                        DrillDown(6);
                    end;
                }
                field(ColumnValues7; ColumnValues[7])
                {
                    ApplicationArea = Basic, Suite;
                    AutoFormatExpression = FormatStr(7);
                    AutoFormatType = 11;
                    BlankZero = true;
                    CaptionClass = '3,' + ColumnCaptions[7];
                    StyleExpr = ColumnStyle7;
                    Visible = NoOfColumns >= 7;

                    trigger OnDrillDown()
                    begin
                        DrillDown(7);
                    end;
                }
                field(ColumnValues8; ColumnValues[8])
                {
                    ApplicationArea = Basic, Suite;
                    AutoFormatExpression = FormatStr(8);
                    AutoFormatType = 11;
                    BlankZero = true;
                    CaptionClass = '3,' + ColumnCaptions[8];
                    StyleExpr = ColumnStyle8;
                    Visible = NoOfColumns >= 8;

                    trigger OnDrillDown()
                    begin
                        DrillDown(8);
                    end;
                }
                field(ColumnValues9; ColumnValues[9])
                {
                    ApplicationArea = Basic, Suite;
                    AutoFormatExpression = FormatStr(9);
                    AutoFormatType = 11;
                    BlankZero = true;
                    CaptionClass = '3,' + ColumnCaptions[9];
                    StyleExpr = ColumnStyle9;
                    Visible = NoOfColumns >= 9;

                    trigger OnDrillDown()
                    begin
                        DrillDown(9);
                    end;
                }
                field(ColumnValues10; ColumnValues[10])
                {
                    ApplicationArea = Basic, Suite;
                    AutoFormatExpression = FormatStr(10);
                    AutoFormatType = 11;
                    BlankZero = true;
                    CaptionClass = '3,' + ColumnCaptions[10];
                    StyleExpr = ColumnStyle10;
                    Visible = NoOfColumns >= 10;

                    trigger OnDrillDown()
                    begin
                        DrillDown(10);
                    end;
                }
                field(ColumnValues11; ColumnValues[11])
                {
                    ApplicationArea = Basic, Suite;
                    AutoFormatExpression = FormatStr(11);
                    AutoFormatType = 11;
                    BlankZero = true;
                    CaptionClass = '3,' + ColumnCaptions[11];
                    StyleExpr = ColumnStyle11;
                    Visible = NoOfColumns >= 11;

                    trigger OnDrillDown()
                    begin
                        DrillDown(11);
                    end;
                }
                field(ColumnValues12; ColumnValues[12])
                {
                    ApplicationArea = Basic, Suite;
                    AutoFormatExpression = FormatStr(12);
                    AutoFormatType = 11;
                    BlankZero = true;
                    CaptionClass = '3,' + ColumnCaptions[12];
                    StyleExpr = ColumnStyle12;
                    Visible = NoOfColumns >= 12;

                    trigger OnDrillDown()
                    begin
                        DrillDown(12);
                    end;
                }
                field(ColumnValues13; ColumnValues[13])
                {
                    ApplicationArea = Basic, Suite;
                    AutoFormatExpression = FormatStr(13);
                    AutoFormatType = 11;
                    BlankZero = true;
                    CaptionClass = '3,' + ColumnCaptions[13];
                    StyleExpr = ColumnStyle13;
                    Visible = NoOfColumns >= 13;

                    trigger OnDrillDown()
                    begin
                        DrillDown(13);
                    end;
                }
                field(ColumnValues14; ColumnValues[14])
                {
                    ApplicationArea = Basic, Suite;
                    AutoFormatExpression = FormatStr(14);
                    AutoFormatType = 11;
                    BlankZero = true;
                    CaptionClass = '3,' + ColumnCaptions[14];
                    StyleExpr = ColumnStyle14;
                    Visible = NoOfColumns >= 14;

                    trigger OnDrillDown()
                    begin
                        DrillDown(14);
                    end;
                }
                field(ColumnValues15; ColumnValues[15])
                {
                    ApplicationArea = Basic, Suite;
                    AutoFormatExpression = FormatStr(15);
                    AutoFormatType = 11;
                    BlankZero = true;
                    CaptionClass = '3,' + ColumnCaptions[15];
                    StyleExpr = ColumnStyle15;
                    Visible = NoOfColumns >= 15;

                    trigger OnDrillDown()
                    begin
                        DrillDown(15);
                    end;
                }
                field(ColumnValues16; ColumnValues[16])
                {
                    ApplicationArea = Basic, Suite;
                    AutoFormatExpression = FormatStr(16);
                    AutoFormatType = 11;
                    BlankZero = true;
                    CaptionClass = '3,' + ColumnCaptions[16];
                    StyleExpr = ColumnStyle16;
                    Visible = NoOfColumns >= 16;

                    trigger OnDrillDown()
                    begin
                        DrillDown(16);
                    end;
                }
                field(ColumnValues17; ColumnValues[17])
                {
                    ApplicationArea = Basic, Suite;
                    AutoFormatExpression = FormatStr(17);
                    AutoFormatType = 11;
                    BlankZero = true;
                    CaptionClass = '3,' + ColumnCaptions[17];
                    StyleExpr = ColumnStyle17;
                    Visible = NoOfColumns >= 17;

                    trigger OnDrillDown()
                    begin
                        DrillDown(17);
                    end;
                }
                field(ColumnValues18; ColumnValues[18])
                {
                    ApplicationArea = Basic, Suite;
                    AutoFormatExpression = FormatStr(18);
                    AutoFormatType = 11;
                    BlankZero = true;
                    CaptionClass = '3,' + ColumnCaptions[18];
                    StyleExpr = ColumnStyle18;
                    Visible = NoOfColumns >= 18;

                    trigger OnDrillDown()
                    begin
                        DrillDown(18);
                    end;
                }
                field(ColumnValues19; ColumnValues[19])
                {
                    ApplicationArea = Basic, Suite;
                    AutoFormatExpression = FormatStr(19);
                    AutoFormatType = 11;
                    BlankZero = true;
                    CaptionClass = '3,' + ColumnCaptions[19];
                    StyleExpr = ColumnStyle19;
                    Visible = NoOfColumns >= 19;

                    trigger OnDrillDown()
                    begin
                        DrillDown(19);
                    end;
                }
                field(ColumnValues20; ColumnValues[20])
                {
                    ApplicationArea = Basic, Suite;
                    AutoFormatExpression = FormatStr(20);
                    AutoFormatType = 11;
                    BlankZero = true;
                    CaptionClass = '3,' + ColumnCaptions[20];
                    StyleExpr = ColumnStyle14;
                    Visible = NoOfColumns >= 20;

                    trigger OnDrillDown()
                    begin
                        DrillDown(20);
                    end;
                }
                field(ColumnValues21; ColumnValues[21])
                {
                    ApplicationArea = Basic, Suite;
                    AutoFormatExpression = FormatStr(21);
                    AutoFormatType = 11;
                    BlankZero = true;
                    CaptionClass = '3,' + ColumnCaptions[21];
                    StyleExpr = ColumnStyle1;

                    trigger OnDrillDown()
                    begin
                        DrillDown(21);
                    end;
                }
                field(ColumnValues22; ColumnValues[22])
                {
                    ApplicationArea = Basic, Suite;
                    AutoFormatExpression = FormatStr(22);
                    AutoFormatType = 11;
                    BlankZero = true;
                    CaptionClass = '3,' + ColumnCaptions[22];
                    StyleExpr = ColumnStyle22;
                    Visible = NoOfColumns >= 22;

                    trigger OnDrillDown()
                    begin
                        DrillDown(22);
                    end;
                }
                field(ColumnValues23; ColumnValues[23])
                {
                    ApplicationArea = Basic, Suite;
                    AutoFormatExpression = FormatStr(23);
                    AutoFormatType = 11;
                    BlankZero = true;
                    CaptionClass = '3,' + ColumnCaptions[23];
                    StyleExpr = ColumnStyle23;
                    Visible = NoOfColumns >= 23;

                    trigger OnDrillDown()
                    begin
                        DrillDown(23);
                    end;
                }
                field(ColumnValues24; ColumnValues[24])
                {
                    ApplicationArea = Basic, Suite;
                    AutoFormatExpression = FormatStr(24);
                    AutoFormatType = 11;
                    BlankZero = true;
                    CaptionClass = '3,' + ColumnCaptions[24];
                    StyleExpr = ColumnStyle24;
                    Visible = NoOfColumns >= 24;

                    trigger OnDrillDown()
                    begin
                        DrillDown(24);
                    end;
                }
                field(ColumnValues25; ColumnValues[25])
                {
                    ApplicationArea = Basic, Suite;
                    AutoFormatExpression = FormatStr(25);
                    AutoFormatType = 11;
                    BlankZero = true;
                    CaptionClass = '3,' + ColumnCaptions[25];
                    StyleExpr = ColumnStyle25;
                    Visible = NoOfColumns >= 25;

                    trigger OnDrillDown()
                    begin
                        DrillDown(25);
                    end;
                }
                field(ColumnValues26; ColumnValues[26])
                {
                    ApplicationArea = Basic, Suite;
                    AutoFormatExpression = FormatStr(26);
                    AutoFormatType = 11;
                    BlankZero = true;
                    CaptionClass = '3,' + ColumnCaptions[26];
                    StyleExpr = ColumnStyle26;
                    Visible = NoOfColumns >= 26;

                    trigger OnDrillDown()
                    begin
                        DrillDown(26);
                    end;
                }
                field(ColumnValues27; ColumnValues[27])
                {
                    ApplicationArea = Basic, Suite;
                    AutoFormatExpression = FormatStr(27);
                    AutoFormatType = 11;
                    BlankZero = true;
                    CaptionClass = '3,' + ColumnCaptions[27];
                    StyleExpr = ColumnStyle27;
                    Visible = NoOfColumns >= 27;

                    trigger OnDrillDown()
                    begin
                        DrillDown(27);
                    end;
                }
                field(ColumnValues28; ColumnValues[28])
                {
                    ApplicationArea = Basic, Suite;
                    AutoFormatExpression = FormatStr(28);
                    AutoFormatType = 11;
                    BlankZero = true;
                    CaptionClass = '3,' + ColumnCaptions[28];
                    StyleExpr = ColumnStyle28;
                    Visible = NoOfColumns >= 28;

                    trigger OnDrillDown()
                    begin
                        DrillDown(28);
                    end;
                }
                field(ColumnValues29; ColumnValues[29])
                {
                    ApplicationArea = Basic, Suite;
                    AutoFormatExpression = FormatStr(29);
                    AutoFormatType = 11;
                    BlankZero = true;
                    CaptionClass = '3,' + ColumnCaptions[29];
                    StyleExpr = ColumnStyle29;
                    Visible = NoOfColumns >= 29;

                    trigger OnDrillDown()
                    begin
                        DrillDown(9);
                    end;
                }
                field(ColumnValues30; ColumnValues[30])
                {
                    ApplicationArea = Basic, Suite;
                    AutoFormatExpression = FormatStr(30);
                    AutoFormatType = 11;
                    BlankZero = true;
                    CaptionClass = '3,' + ColumnCaptions[30];
                    StyleExpr = ColumnStyle30;
                    Visible = NoOfColumns >= 30;

                    trigger OnDrillDown()
                    begin
                        DrillDown(30);
                    end;
                }
                field(ColumnValues31; ColumnValues[31])
                {
                    ApplicationArea = Basic, Suite;
                    AutoFormatExpression = FormatStr(31);
                    AutoFormatType = 11;
                    BlankZero = true;
                    CaptionClass = '3,' + ColumnCaptions[31];
                    StyleExpr = ColumnStyle31;
                    Visible = NoOfColumns >= 31;

                    trigger OnDrillDown()
                    begin
                        DrillDown(31);
                    end;
                }
                field(ColumnValues32; ColumnValues[32])
                {
                    ApplicationArea = Basic, Suite;
                    AutoFormatExpression = FormatStr(32);
                    AutoFormatType = 11;
                    BlankZero = true;
                    CaptionClass = '3,' + ColumnCaptions[32];
                    StyleExpr = ColumnStyle32;
                    Visible = NoOfColumns >= 32;

                    trigger OnDrillDown()
                    begin
                        DrillDown(32);
                    end;
                }
                field(ColumnValues33; ColumnValues[33])
                {
                    ApplicationArea = Basic, Suite;
                    AutoFormatExpression = FormatStr(33);
                    AutoFormatType = 11;
                    BlankZero = true;
                    CaptionClass = '3,' + ColumnCaptions[33];
                    StyleExpr = ColumnStyle33;
                    Visible = NoOfColumns >= 33;

                    trigger OnDrillDown()
                    begin
                        DrillDown(33);
                    end;
                }
                field(ColumnValues34; ColumnValues[34])
                {
                    ApplicationArea = Basic, Suite;
                    AutoFormatExpression = FormatStr(34);
                    AutoFormatType = 11;
                    BlankZero = true;
                    CaptionClass = '3,' + ColumnCaptions[34];
                    StyleExpr = ColumnStyle34;
                    Visible = NoOfColumns >= 34;

                    trigger OnDrillDown()
                    begin
                        DrillDown(34);
                    end;
                }

            }
        }
    }

    actions
    {
        area(processing)
        {
            group("F&unctions")
            {
                Caption = 'F&unciones';
                Image = "Action";
            }
            action(Print)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Imprimir';
                Ellipsis = true;
                Image = Print;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                ToolTip = 'Print the information in the window. A print request window opens where you can specify what to include on the print-out.';

                trigger OnAction()
                var
                    AccSched: Report "Account Schedule";
                    DateFilter2: Text;
                    GLBudgetFilter2: Text;
                    BusUnitFilter: Text;
                    CostBudgetFilter2: Text;
                    IsHandled: Boolean;
                begin
                    IsHandled := false;
                    OnBeforePrint(Rec, CurrentColumnName, IsHandled);
                    if IsHandled then
                        exit;

                    AccSched.SetAccSchedName(CurrentSchedName);
                    AccSched.SetColumnLayoutName(CurrentColumnName);
                    DateFilter2 := Rec.GetFilter("Date Filter");
                    GLBudgetFilter2 := Rec.GetFilter("G/L Budget Filter");
                    CostBudgetFilter2 := Rec.GetFilter("Cost Budget Filter");
                    BusUnitFilter := Rec.GetFilter("Business Unit Filter");
                    AccSched.SetFilters(DateFilter2, GLBudgetFilter2, CostBudgetFilter2, BusUnitFilter, Dim1Filter, Dim2Filter, Dim3Filter, Dim4Filter);
                    AccSched.Run;
                end;
            }
            action("Por Fechas")
            {
                Image = Calendar;
                ApplicationArea = All;
                trigger OnAction()
                var
                    Desglose: Record "Detalle Fechas x Usuario";
                    UserSetup: Record "User Setup";
                begin
                    UserSetup.GET(UserId);
                    UserSetup.EsquemaCuentas := CurrentSchedName;
                    UserSetup.MODIFY;
                    Rec.COPYFILTER("Date Filter", Desglose."Filtro Fecha");
                    Desglose.SetRange(Usuario, UserId);
                    if NOT Desglose.FINDFIRST THEN BEGIN
                        Desglose.Linea := 0;
                        Desglose.Usuario := UserId;
                        Desglose."Nombre Esquema" := CurrentSchedName;
                        Desglose.INSERT;
                    END;
                    Desglose.MODIFYALL(Desglose."Nombre Esquema", CurrentSchedName);
                    COMMIT;
                    Desglose.FindFirst();
                    Page.RUN(50049, Desglose);
                end;
            }
            action(PreviousColumn)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Columna anterior';
                Image = PreviousRecord;
                Promoted = true;
                PromotedCategory = Category4;
                PromotedIsBig = true;
                PromotedOnly = true;
                ToolTip = 'Go to the previous column.';

                trigger OnAction()
                begin
                    AdjustColumnOffset(-1);
                end;
            }
            action(NextPeriod)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Periodo siguiente';
                Image = NextRecord;
                Promoted = true;
                PromotedCategory = Category5;
                PromotedOnly = true;
                ToolTip = 'Show the information based on the next period. if you set the View by field to Day, the date filter changes to the day before.';

                trigger OnAction()
                begin
                    FindPeriod(Rec, '>=', PeriodType);
                    DateFilter := Rec.GetFilter("Date Filter");
                end;
            }
            action(PreviousPeriod)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Periodo anterior';
                Image = PreviousRecord;
                Promoted = true;
                PromotedCategory = Category5;
                PromotedIsBig = true;
                PromotedOnly = true;
                ToolTip = 'Show the information based on the previous period. if you set the View by field to Day, the date filter changes to the day before.';

                trigger OnAction()
                begin
                    FindPeriod(Rec, '<=', PeriodType);
                    DateFilter := Rec.GetFilter("Date Filter");
                end;
            }
            action(NextColumn)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Siguiente Columna';
                Image = NextRecord;
                Promoted = true;
                PromotedCategory = Category4;
                PromotedOnly = true;
                ToolTip = 'Go to the next column.';

                trigger OnAction()
                begin
                    AdjustColumnOffset(1);
                end;
            }
            action(Recalculate)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Recalcular';
                Image = Refresh;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                ToolTip = 'Update the account schedule overview based on recent changes.';

                trigger OnAction()
                begin
                    AccSchedManagement.ForceRecalculate(true);
                end;
            }
            group(Excel)
            {
                Caption = 'Excel';
                group("Export to Excel")
                {
                    Caption = 'Exportar a Excel';
                    Image = ExportToExcel;
                    action("Create New Document")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Crear documento nuevo';
                        Image = ExportToExcel;
                        ToolTip = 'Open the account schedule overview in a new Excel workbook. This creates an Excel workbook on your device.';

                        trigger OnAction()
                        var
                            ExportAccSchedToExcel: Report "Export Acc. Sched. to Excel";
                        begin
                            ExportAccSchedToExcel.SetOptions(Rec, CurrentColumnName, UseAmtsInAddCurr);
                            ExportAccSchedToExcel.Run;
                        end;
                    }
                    action("Update Existing Document")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Actualizar copia de documento existente';
                        Image = ExportToExcel;
                        ToolTip = 'Refresh the data in the copy of the existing Excel workbook, and download it to your device. You must specify the workbook that you want to update.';

                        trigger OnAction()
                        var
                            ExportAccSchedToExcel: Report "Export Acc. Sched. to Excel";
                        begin
                            ExportAccSchedToExcel.SetOptions(Rec, CurrentColumnName, UseAmtsInAddCurr);
                            ExportAccSchedToExcel.SetUpdateExistingWorksheet(true);
                            ExportAccSchedToExcel.Run;
                        end;
                    }
                }
                group("Export to Excel Cash")
                {
                    Caption = 'Exportar a Excel Cash Flow';
                    Image = ExportToExcel;
                    action("Crear Documento nuevo")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Crear documento nuevo';
                        Image = ExportToExcel;
                        ToolTip = 'Open the account schedule overview in a new Excel workbook. This creates an Excel workbook on your device.';

                        trigger OnAction()
                        var
                            ExportAccSchedToExcel: Report "Export Acc. to Excel CF";
                        begin
                            ExportAccSchedToExcel.SetOptions(Rec, CurrentColumnName, UseAmtsInAddCurr);
                            ExportAccSchedToExcel.Run;
                        end;
                    }
                    action("Actualizar Existente")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Actualizar copia de documento existente';
                        Image = ExportToExcel;
                        ToolTip = 'Refresh the data in the copy of the existing Excel workbook, and download it to your device. You must specify the workbook that you want to update.';

                        trigger OnAction()
                        var
                            ExportAccSchedToExcel: Report "Export Acc. to Excel CF";
                        begin
                            ExportAccSchedToExcel.SetOptions(Rec, CurrentColumnName, UseAmtsInAddCurr);
                            ExportAccSchedToExcel.SetUpdateExistingWorksheet(true);
                            ExportAccSchedToExcel.Run;
                        end;
                    }
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    var
        ColumnNo: Integer;
        Control: Codeunit ControlProcesos;
        Empresa: Text;
    begin
        Clear(ColumnValues);

        if (Rec.Totaling = '') or (not TempColumnLayout.FindSet) then
            exit;

        repeat
            ColumnNo := ColumnNo + 1;

            if (ColumnNo > ColumnOffset) and (ColumnNo - ColumnOffset <= ArrayLen(ColumnValues)) then begin
                if (Rec.Company <> '') Or (TempColumnLayout.Empresa <> '') Then begin
                    Empresa := Rec.Company;
                    if TempColumnLayout.Empresa <> '' then Empresa := TempColumnLayout.Empresa;
                    if Control.Permiso_Empresas(Empresa) Then
                        ColumnValues[ColumnNo - ColumnOffset] :=
                      RoundIfNotNone(
                        MatrixMgt.RoundAmount(
                          AccSchedManagement.CalcCell(Rec, TempColumnLayout, UseAmtsInAddCurr),
                          TempColumnLayout."Rounding Factor"),
                        TempColumnLayout."Rounding Factor");
                end else
                    ColumnValues[ColumnNo - ColumnOffset] :=
                      RoundIfNotNone(
                        MatrixMgt.RoundAmount(
                          AccSchedManagement.CalcCell(Rec, TempColumnLayout, UseAmtsInAddCurr),
                          TempColumnLayout."Rounding Factor"),
                        TempColumnLayout."Rounding Factor");
                OnOnAfterGetRecordOnAfterAssignColumnValue(ColumnValues, ColumnNo, ColumnOffset, TempColumnLayout, UseAmtsInAddCurr);
                ColumnLayoutArr[ColumnNo - ColumnOffset] := TempColumnLayout;
                GetStyle(ColumnNo - ColumnOffset, Rec."Line No.", TempColumnLayout."Line No.");
            end;

        until TempColumnLayout.Next() = 0;
        AccSchedManagement.ForceRecalculate(false);
    end;

    trigger OnInit()
    begin
        Dim4FilterEnable := true;
        Dim5FilterEnable := true;
        Dim3FilterEnable := true;
        Dim2FilterEnable := true;
        Dim1FilterEnable := true;
    end;

    trigger OnOpenPage()
    begin
        UseAmtsInAddCurr := false;
        GLSetup.Get();
        UseAmtsInAddCurrVisible := GLSetup."Additional Reporting Currency" <> '';
        if NewCurrentSchedName <> '' then
            CurrentSchedName := NewCurrentSchedName;
        if CurrentSchedName = '' then
            CurrentSchedName := Text000;
        if NewCurrentColumnName <> '' then
            CurrentColumnName := NewCurrentColumnName;
        if CurrentColumnName = '' then
            CurrentColumnName := Text000;
        if NewPeriodTypeSet then
            PeriodType := ModifiedPeriodType;

        AccSchedManagement.CopyColumnsToTemp(CurrentColumnName, TempColumnLayout);
        AccSchedManagement.OpenSchedule(CurrentSchedName, Rec);
        AccSchedManagement.OpenColumns(CurrentColumnName, TempColumnLayout);
        AccSchedManagement.CheckAnalysisView(CurrentSchedName, CurrentColumnName, true);
        UpdateColumnCaptions;
        if AccSchedName.Get(CurrentSchedName) then
            if AccSchedName."Analysis View Name" <> '' then
                AnalysisView.Get(AccSchedName."Analysis View Name")
            else begin
                Clear(AnalysisView);
                AnalysisView."Dimension 1 Code" := GLSetup."Global Dimension 1 Code";
                AnalysisView."Dimension 2 Code" := GLSetup."Global Dimension 2 Code";
                AnalysisView."Dimension 3 Code" := GLSetup."Shortcut Dimension 3 Code";
                AnalysisView."Dimension 4 Code" := GLSetup."Shortcut Dimension 4 Code";
                AnalysisView."Dimension 5 Totaling" := GLSetup."Shortcut Dimension 5 Code";
            end;

        FindPeriod(Rec, '', PeriodType);
        Rec.SetFilter(Show, '<>%1', Rec.Show::No);
        Rec.SetRange("Dimension 1 Filter");
        Rec.SetRange("Dimension 2 Filter");
        Rec.SetRange("Dimension 3 Filter");
        Rec.SetRange("Dimension 4 Filter");
        Rec.SetRange("Dimension 5 Filter");
        Rec.SetRange("SalesPerson Filter");
        Rec.SetRange("Cost Center Filter");
        Rec.SetRange("Cost Object Filter");
        Rec.SetRange("Cash Flow Forecast Filter");
        Rec.SetRange("Cost Budget Filter");
        Rec.SetRange("G/L Budget Filter");
        UpdateDimFilterControls;
        DateFilter := Rec.GetFilter("Date Filter");

        OnBeforeCurrentColumnNameOnAfterValidate(CurrentColumnName);

        OnAfterOnOpenPage(Rec, CurrentColumnName);
    end;

    var
        Text000: Label 'GENERICO';
        Text005: Label '1,6,,Filtro %1 dimensión';
        TempColumnLayout: Record "Column Layout" temporary;
        ColumnLayoutArr: array[34] of Record "Column Layout";
        AccSchedName: Record "Acc. Schedule Name";
        AnalysisView: Record "Analysis View";
        GLSetup: Record "General Ledger Setup";
        AccSchedManagement: Codeunit "Procedures Standard";
        MatrixMgt: Codeunit "Matrix Management";
        DimensionManagement: Codeunit DimensionManagement;
        CurrentSchedName: Code[10];
        NewCurrentSchedName: Code[10];
        NewCurrentColumnName: Code[10];
        ColumnValues: array[34] of Decimal;
        ColumnCaptions: array[34] of Text[80];
        PeriodType: Enum "Analysis Period Type";
        UseAmtsInAddCurrVisible: Boolean;
        UseAmtsInAddCurr: Boolean;
        Dim1Filter: Text;
        Dim2Filter: Text;
        Dim3Filter: Text;
        Dim5Filter: Text;
        Dim4Filter: Text;
        SalePersonFilter: Text;
        CostCenterFilter: Text;
        CostObjectFilter: Text;
        CashFlowFilter: Text;
        NoOfColumns: Integer;
        ColumnOffset: Integer;
        FiltroEli: Option " ",Sí,No;

        Dim1FilterEnable: Boolean;

        Dim2FilterEnable: Boolean;

        Dim3FilterEnable: Boolean;

        Dim4FilterEnable: Boolean;
        Dim5FilterENABLE: Boolean;
        GLBudgetFilter: Text;
        CostBudgetFilter: Text;
        DateFilter: Text;
        ModifiedPeriodType: Enum "Analysis Period Type";
        NewPeriodTypeSet: Boolean;

        ColumnStyle1: Text;

        ColumnStyle2: Text;

        ColumnStyle3: Text;

        ColumnStyle4: Text;

        ColumnStyle5: Text;

        ColumnStyle6: Text;

        ColumnStyle7: Text;

        ColumnStyle8: Text;

        ColumnStyle9: Text;

        ColumnStyle10: Text;

        ColumnStyle11: Text;

        ColumnStyle12: Text;

        ColumnStyle13: Text;

        ColumnStyle14: Text;

        ColumnStyle15: Text;

        ColumnStyle16: Text;

        ColumnStyle17: Text;

        ColumnStyle18: Text;

        ColumnStyle19: Text;

        ColumnStyle20: Text;

        ColumnStyle21: Text;

        ColumnStyle22: Text;

        ColumnStyle23: Text;

        ColumnStyle24: Text;

        ColumnStyle25: Text;

        ColumnStyle26: Text;

        ColumnStyle27: Text;

        ColumnStyle28: Text;

        ColumnStyle29: Text;

        ColumnStyle30: Text;

        ColumnStyle31: Text;

        ColumnStyle32: Text;

        ColumnStyle33: Text;

        ColumnStyle34: Text;

    protected var
        CurrentColumnName: Code[10];

    /// <summary>
    /// SetAccSchedName.
    /// </summary>
    /// <param name="NewAccSchedName">Code[10].</param>
    procedure SetAccSchedName(NewAccSchedName: Code[10])
    var
        //AccSchedName: Record "Acc. Schedule Name";
        AccSchedName: Record "Financial Report";
    begin
        NewCurrentSchedName := NewAccSchedName;
        if AccSchedName.Get(NewCurrentSchedName) then
            if AccSchedName."Financial Report Column Group" <> '' then
                NewCurrentColumnName := AccSchedName."Financial Report Column Group";
        if AccSchedName.Get(NewCurrentSchedName) then
            if AccSchedName."Financial Report Row Group" <> '' then
                NewCurrentSchedName := AccSchedName."Financial Report Row Group";
    end;

    /// <summary>
    /// SetPeriodType.
    /// </summary>
    /// <param name="NewPeriodType">Option.</param>
    procedure SetPeriodType(NewPeriodType: Option)
    begin
        ModifiedPeriodType := "Analysis Period Type".FromInteger(NewPeriodType);
        NewPeriodTypeSet := true;
    end;

    local procedure SetDimFilters(DimNo: Integer; DimValueFilter: Text)
    begin
        case DimNo of
            1:
                if DimValueFilter = '' then
                    Rec.SetRange("Dimension 1 Filter")
                else begin
                    DimensionManagement.ResolveDimValueFilter(DimValueFilter, AnalysisView."Dimension 1 Code");
                    Rec.SetFilter("Dimension 1 Filter", DimValueFilter);
                end;
            2:
                if DimValueFilter = '' then
                    Rec.SetRange("Dimension 2 Filter")
                else begin
                    DimensionManagement.ResolveDimValueFilter(DimValueFilter, AnalysisView."Dimension 2 Code");
                    Rec.SetFilter("Dimension 2 Filter", DimValueFilter);
                end;
            3:
                if DimValueFilter = '' then
                    Rec.SetRange("Dimension 3 Filter")
                else begin
                    DimensionManagement.ResolveDimValueFilter(DimValueFilter, AnalysisView."Dimension 3 Code");
                    Rec.SetFilter("Dimension 3 Filter", DimValueFilter);
                end;
            4:
                if DimValueFilter = '' then
                    Rec.SetRange("Dimension 4 Filter")
                else begin
                    DimensionManagement.ResolveDimValueFilter(DimValueFilter, AnalysisView."Dimension 4 Code");
                    Rec.SetFilter("Dimension 4 Filter", DimValueFilter);
                end;
            5:
                if DimValueFilter = '' then
                    Rec.SetRange("Dimension 5 Filter")
                else begin
                    DimensionManagement.ResolveDimValueFilter(DimValueFilter, AnalysisView."Dimension 5 Totaling");
                    Rec.SetFilter("Dimension 5 Filter", DimValueFilter);
                end;
            6:
                if DimValueFilter = '' then
                    Rec.SetRange("Salesperson Filter")
                else begin
                    Rec.SetFilter("SalesPerson Filter", DimValueFilter);
                end;
        end;

        OnAfterSetDimFilters(Rec, DimNo, DimValueFilter, CostCenterFilter, CostObjectFilter);
        CurrPage.Update();
    end;

    local procedure FormGetCaptionClass(DimNo: Integer) Result: Text[250]
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeGetCaptionClass(AnalysisView, DimNo, Result, IsHandled);
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
                begin
                    if AnalysisView."Dimension 5 Totaling" <> '' then
                        exit('1,6,' + AnalysisView."Dimension 5 Totaling");

                    exit(StrSubstNo(Text005, DimNo));
                end;
            6:
                exit(Rec.FieldCaption("Date Filter"));
            7:
                exit(Rec.FieldCaption("Cash Flow Forecast Filter"));
        end;
    end;

    local procedure DrillDown(ColumnNo: Integer)
    begin
        TempColumnLayout := ColumnLayoutArr[ColumnNo];
        AccSchedManagement.DrillDownFromOverviewPage(TempColumnLayout, Rec, PeriodType.AsInteger(), FiltroEli, Dim1Filter, Dim2Filter, Dim3Filter, Dim4Filter, Dim5Filter, SalePersonFilter);
        OnAfterDrillDown(ColumnNo, TempColumnLayout, PeriodType);
    end;

    local procedure UpdateColumnCaptions()
    var
        ColumnNo: Integer;
        i: Integer;
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeUpdateColumnCaptions(ColumnCaptions, ColumnOffset, TempColumnLayout, NoOfColumns, IsHandled);
        if IsHandled then
            exit;

        Clear(ColumnCaptions);
        if TempColumnLayout.FindSet then
            repeat
                ColumnNo := ColumnNo + 1;
                if (ColumnNo > ColumnOffset) and (ColumnNo - ColumnOffset <= ArrayLen(ColumnCaptions)) then
                    ColumnCaptions[ColumnNo - ColumnOffset] := TempColumnLayout."Column Header";
            until (ColumnNo - ColumnOffset = ArrayLen(ColumnCaptions)) or (TempColumnLayout.Next() = 0);
        // Set unused columns to blank to prevent RTC to display control ID as caption
        for i := ColumnNo - ColumnOffset + 1 to ArrayLen(ColumnCaptions) do
            ColumnCaptions[i] := ' ';
        NoOfColumns := ColumnNo;
    end;

    local procedure AdjustColumnOffset(Delta: Integer)
    var
        OldColumnOffset: Integer;
    begin
        OldColumnOffset := ColumnOffset;
        ColumnOffset := ColumnOffset + Delta;
        if ColumnOffset + 34 > TempColumnLayout.Count then
            ColumnOffset := TempColumnLayout.Count - 34;
        if ColumnOffset < 0 then
            ColumnOffset := 0;
        if ColumnOffset <> OldColumnOffset then begin
            UpdateColumnCaptions;
            CurrPage.Update(false);
        end;
    end;

    local procedure UpdateDimFilterControls()
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeUpdateDimFilterControls(Rec, AnalysisView, IsHandled);
        if IsHandled then
            exit;

        Dim1Filter := Rec.GetFilter("Dimension 1 Filter");
        Dim2Filter := Rec.GetFilter("Dimension 2 Filter");
        Dim3Filter := Rec.GetFilter("Dimension 3 Filter");
        Dim4Filter := Rec.GetFilter("Dimension 4 Filter");
        Dim5Filter := Rec.GetFilter("Dimension 5 Filter");
        SalePersonFilter := Rec.GetFilter("SalesPerson Filter");
        CostCenterFilter := '';
        CostObjectFilter := '';
        CashFlowFilter := '';
        Dim1FilterEnable := AnalysisView."Dimension 1 Code" <> '';
        Dim2FilterEnable := AnalysisView."Dimension 2 Code" <> '';
        Dim3FilterEnable := AnalysisView."Dimension 3 Code" <> '';
        Dim4FilterEnable := AnalysisView."Dimension 4 Code" <> '';
        Dim5FilterEnable := AnalysisView."Dimension 4 Code" <> '';
        GLBudgetFilter := '';
        CostBudgetFilter := '';

        OnAfterUpdateDimFilterControls(Dim4FilterEnable);
    end;

    local procedure CurrentSchedNameOnAfterValidate()
    var
        AccSchedName: Record "Financial Report";
        AccSchedNames: Record "Acc. Schedule Name";
        PrevAnalysisView: Record "Analysis View";
    begin
        CurrPage.SaveRecord;
        AccSchedManagement.SetName(CurrentSchedName, Rec);
        if AccSchedName.Get(CurrentSchedName) then begin
            if not AccSchedNames.Get(CurrentSchedName) Then AccSchedNames.Init;
            if (AccSchedName."Financial Report Column Group" <> '') and
               (CurrentColumnName <> AccSchedName."Financial Report Column Group")
            then begin
                CurrentColumnName := AccSchedName."Financial Report Column Group";
                CurrentColumnNameOnAfterValidate;
            end else
                AccSchedManagement.CheckAnalysisView(CurrentSchedName, CurrentColumnName, true);
        end else
            AccSchedManagement.CheckAnalysisView(CurrentSchedName, CurrentColumnName, true);

        if AccSchedNames."Analysis View Name" <> AnalysisView.Code then begin
            PrevAnalysisView := AnalysisView;
            if AccSchedNames."Analysis View Name" <> '' then
                AnalysisView.Get(AccSchedNames."Analysis View Name")
            else begin
                Clear(AnalysisView);
                AnalysisView."Dimension 1 Code" := GLSetup."Global Dimension 1 Code";
                AnalysisView."Dimension 2 Code" := GLSetup."Global Dimension 2 Code";
                AnalysisView."Dimension 3 Code" := GLSetup."Shortcut Dimension 3 Code";
                AnalysisView."Dimension 4 Code" := GLSetup."Shortcut Dimension 4 Code";
                AnalysisView."Dimension 5 Totaling" := GLSetup."Shortcut Dimension 5 Code";
            end;
            if PrevAnalysisView."Dimension 1 Code" <> AnalysisView."Dimension 1 Code" then
                Rec.SetRange("Dimension 1 Filter");
            if PrevAnalysisView."Dimension 2 Code" <> AnalysisView."Dimension 2 Code" then
                Rec.SetRange("Dimension 2 Filter");
            if PrevAnalysisView."Dimension 3 Code" <> AnalysisView."Dimension 3 Code" then
                Rec.SetRange("Dimension 3 Filter");
            if PrevAnalysisView."Dimension 4 Code" <> AnalysisView."Dimension 4 Code" then
                Rec.SetRange("Dimension 4 Filter");
            if PrevAnalysisView."Dimension 5 Totaling" <> AnalysisView."Dimension 5 Totaling" then
                Rec.SetRange("Dimension 5 Filter");
        end;
        UpdateDimFilterControls;

        CurrPage.Update(false);
    end;

    local procedure CurrentColumnNameOnAfterValidate()
    begin
        OnBeforeCurrentColumnNameOnAfterValidate(CurrentColumnName);

        AccSchedManagement.CopyColumnsToTemp(CurrentColumnName, TempColumnLayout);
        AccSchedManagement.SetColumnName(CurrentColumnName, TempColumnLayout);
        AccSchedManagement.CheckAnalysisView(CurrentSchedName, CurrentColumnName, true);
        ColumnOffset := 0;
        UpdateColumnCaptions;
        CurrPage.Update(false);
    end;

    /// <summary>
    /// FormatStr.
    /// </summary>
    /// <param name="ColumnNo">Integer.</param>
    /// <returns>Return value of type Text.</returns>
    procedure FormatStr(ColumnNo: Integer): Text
    begin
        exit(MatrixMgt.FormatRoundingFactor(ColumnLayoutArr[ColumnNo]."Rounding Factor", UseAmtsInAddCurr));
    end;

#if not CLEAN19
    /// <summary>
    /// RoundNone.
    /// </summary>
    /// <param name="Value">Decimal.</param>
    /// <param name="RoundingFactor">Option "None","1","1000","1000000".</param>
    /// <returns>Return value of type Decimal.</returns>
    [Obsolete('Replaced by RoundIfNotNone().', '19.0')]
    procedure RoundNone(Value: Decimal; RoundingFactor: Option "None","1","1000","1000000"): Decimal
    begin
        RoundIfNotNone(Value, "Analysis Rounding Factor".FromInteger(RoundingFactor));
    end;
#endif

    /// <summary>
    /// RoundIfNotNone.
    /// </summary>
    /// <param name="Value">Decimal.</param>
    /// <param name="RoundingFactor">Enum "Analysis Rounding Factor".</param>
    /// <returns>Return value of type Decimal.</returns>
    procedure RoundIfNotNone(Value: Decimal; RoundingFactor: Enum "Analysis Rounding Factor"): Decimal
    begin
        if RoundingFactor <> RoundingFactor::None then
            exit(Value);

        exit(Round(Value));
    end;

    local procedure GetStyle(ColumnNo: Integer; RowLineNo: Integer; ColumnLineNo: Integer)
    var
        ColumnStyle: Text;
        ErrorType: Option "None","Division by Zero","Period Error",Both;
    begin
        AccSchedManagement.CalcFieldError(ErrorType, RowLineNo, ColumnLineNo);
        if ErrorType > ErrorType::None then
            ColumnStyle := 'Unfavorable'
        else
            if Rec.Bold then
                ColumnStyle := 'Strong'
            else
                ColumnStyle := 'Standard';

        OnGetStyleOnBeforeAssignColumnStyle(Rec, ColumnNo, RowLineNo, ColumnLineNo, ColumnStyle);

        case ColumnNo of
            1:
                ColumnStyle1 := ColumnStyle;
            2:
                ColumnStyle2 := ColumnStyle;
            3:
                ColumnStyle3 := ColumnStyle;
            4:
                ColumnStyle4 := ColumnStyle;
            5:
                ColumnStyle5 := ColumnStyle;
            6:
                ColumnStyle6 := ColumnStyle;
            7:
                ColumnStyle7 := ColumnStyle;
            8:
                ColumnStyle8 := ColumnStyle;
            9:
                ColumnStyle9 := ColumnStyle;
            10:
                ColumnStyle10 := ColumnStyle;
            11:
                ColumnStyle11 := ColumnStyle;
            12:
                ColumnStyle12 := ColumnStyle;
            13:
                ColumnStyle13 := ColumnStyle;
            14:
                ColumnStyle14 := ColumnStyle;
            15:
                ColumnStyle15 := ColumnStyle;
            16:
                ColumnStyle16 := ColumnStyle;
            17:
                ColumnStyle17 := ColumnStyle;
            18:
                ColumnStyle18 := ColumnStyle;
            19:
                ColumnStyle19 := ColumnStyle;
            20:
                ColumnStyle20 := ColumnStyle;
            21:
                ColumnStyle21 := ColumnStyle;
            22:
                ColumnStyle22 := ColumnStyle;
            23:
                ColumnStyle23 := ColumnStyle;
            24:
                ColumnStyle24 := ColumnStyle;
            25:
                ColumnStyle25 := ColumnStyle;
            26:
                ColumnStyle26 := ColumnStyle;
            27:
                ColumnStyle27 := ColumnStyle;
            28:
                ColumnStyle28 := ColumnStyle;
            29:
                ColumnStyle29 := ColumnStyle;
            30:
                ColumnStyle30 := ColumnStyle;
            31:
                ColumnStyle31 := ColumnStyle;
            32:
                ColumnStyle32 := ColumnStyle;
            33:
                ColumnStyle33 := ColumnStyle;
            34:
                ColumnStyle34 := ColumnStyle;
        // 35:
        //     ColumnStyle35 := ColumnStyle;
        // 36:
        //     ColumnStyle36 := ColumnStyle;
        end;
    end;

    /// <summary>
    /// FindPeriod.
    /// </summary>
    /// <param name="AccScheduleLine">VAR Record "Acc. Schedule Line".</param>
    /// <param name="SearchText">Text[3].</param>
    /// <param name="PeriodType">Enum "Analysis Period Type".</param>
    procedure FindPeriod(var AccScheduleLine: Record "Acc. Schedule Line"; SearchText: Text[3]; PeriodType: Enum "Analysis Period Type")
    var
        Calendar: Record Date;
        PeriodPageMgt: Codeunit PeriodPageManagement;
    begin
        with AccScheduleLine do begin
            if GetFilter("Date Filter") <> '' then begin
                Calendar.SetFilter("Period Start", GetFilter("Date Filter"));
                if not PeriodPageMgt.FindDate('+', Calendar, PeriodType) then
                    PeriodPageMgt.FindDate('+', Calendar, PeriodType::Day);
                Calendar.SetRange("Period Start");
            end;
            PeriodPageMgt.FindDate(SearchText, Calendar, PeriodType);
            SetRange("Date Filter", Calendar."Period Start", Calendar."Period End");
            if GetRangeMin("Date Filter") = GetRangeMax("Date Filter") then
                SetRange("Date Filter", GetRangeMin("Date Filter"));
        end;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterSetDimFilters(var AccScheduleLine: Record "Acc. Schedule Line"; var DimNo: Integer; var DimValueFilter: Text; var CostCenterFilter: Text; var CostObjectFilter: Text)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterValidateCostCenterFilter(var AccScheduleLine: Record "Acc. Schedule Line"; var CostCenterFilter: Text; var Dim1Filter: Text)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterValidateCostObjectFilter(var AccScheduleLine: Record "Acc. Schedule Line"; var CostObjectFilter: Text; var Dim2Filter: Text)
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnAfterUpdateDimFilterControls(var Dim4FilterEnable: Boolean)
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnAfterDrillDown(ColumnNo: Integer; var TempColumnLayout: Record "Column Layout" temporary; var PeriodType: Enum "Analysis Period Type")
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnAfterOnOpenPage(var AccScheduleLine: Record "Acc. Schedule Line"; var CurrentColumnName: Code[10])
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnOnAfterGetRecordOnAfterAssignColumnValue(var ColumnValues: array[34] of Decimal; var ColumnNo: Integer; var ColumnOffset: Integer; var TempColumnLayout: Record "Column Layout" temporary; var UseAmtsInAddCurr: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforePrint(var AccScheduleLine: Record "Acc. Schedule Line"; ColumnLayoutName: Code[10]; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCurrentColumnNameOnAfterValidate(var CurrentColumnName: Code[10])
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeGetCaptionClass(AnalysisView: Record "Analysis View"; DimNo: Integer; var Result: Text[250]; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeUpdateColumnCaptions(var ColumnCaptions: array[34] of Text[80]; ColumnOffset: Integer; var TempColumnLayout: Record "Column Layout" temporary; NoOfColumns: Integer; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeUpdateDimFilterControls(var AccScheduleLine: Record "Acc. Schedule Line"; AnalysisView: Record "Analysis View"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnGetStyleOnBeforeAssignColumnStyle(AccScheduleLine: Record "Acc. Schedule Line"; ColumnNo: Integer; RowLineNo: Integer; ColumnLineNo: Integer; var ColumnStyle: Text);
    begin
    end;
}