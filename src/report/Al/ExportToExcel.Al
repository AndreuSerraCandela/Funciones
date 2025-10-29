/// <summary>
/// Report Export Acc. to Excel CF (ID 50011).
/// </summary>
report 50008 "Export Acc. to Excel CF"
{
    Caption = 'Exportar Cash Flow';
    ProcessingOnly = true;
    UseRequestPage = true;

    dataset
    {
        dataitem("Integer"; "Integer")
        {
            DataItemTableView = SORTING(Number) WHERE(Number = CONST(1));

            trigger OnAfterGetRecord()
            var
                Window: Dialog;
                RecNo: Integer;
                TotalRecNo: Integer;
                RowNo: Integer;
                ColumnNo: Integer;
                ClientFileName: Text;
                Text1140001: Label 'Filtros';
                rDate: Record Date;
                FechD: Date;
                FechH: Date;
                Fec: Text;
                LiqAccSchedManagement: Codeunit "Procedures Standard";
            begin
                if DoUpdateExistingWorksheet then
                    if not UploadClientFile(ClientFileName, ServerFileName) then
                        exit;
                AccSchedName.GET(AccSchedLine.GETRANGEMIN("Schedule Name"));
                if PorDias THEN BEGIN
                    if FD = 0D THEN ERROR('Especifique fechas');
                    if FH = 0D THEN ERROR('Especifique fechas');
                    PorFechas;
                    EXIT;
                END;
                if (FD <> 0D) AND (FH <> 0D) THEN
                    AccSchedLine.SETRANGE("Date Filter", FD, FH);
                Window.Open(
                  Text000 +
                  '@1@@@@@@@@@@@@@@@@@@@@@\Linea ###########4##\ Fecha ##########2##\ Columna ##########3##');
                Window.Update(1, 0);
                AccSchedLine.SetFilter(Show, '<>%1', AccSchedLine.Show::No);
                TotalRecNo := AccSchedLine.Count();
                RecNo := 0;

                TempExcelBuffer.DeleteAll();
                Clear(TempExcelBuffer);

                AccSchedName.GET(AccSchedLine.GETRANGEMIN("Schedule Name"));
                LiqAccSchedManagement.CheckAnalysisView(AccSchedName.Name, ColumnLayout.GETRANGEMIN("Column Layout Name"), TRUE);
                // AccSchedName.Get(AccSchedLine.GetRangeMin("Schedule Name"));
                // AccSchedManagement.CheckAnalysisView(AccSchedName.Name, ColumnLayout.GetRangeMin("Column Layout Name"), true);
                // if AccSchedName."Analysis View Name" <> '' then
                //     AnalysisView.Get(AccSchedName."Analysis View Name");
                // GLSetup.Get();

                // RowNo := 1;
                // EnterCell(RowNo, 1, Text001, false, false, true, false, '', TempExcelBuffer."Cell Type"::Text);
                // EnterFilterInCell(
                //   RowNo, AccSchedLine.GetFilter("Date Filter"), AccSchedLine.FieldCaption("Date Filter"),
                //   '', TempExcelBuffer."Cell Type"::Text);
                // EnterFilterInCell(
                //   RowNo, AccSchedLine.GetFilter("G/L Budget Filter"), AccSchedLine.FieldCaption("G/L Budget Filter"),
                //   '', TempExcelBuffer."Cell Type"::Text);
                // EnterFilterInCell(
                //   RowNo, AccSchedLine.GetFilter("Cost Budget Filter"), AccSchedLine.FieldCaption("Cost Budget Filter"),
                //   '', TempExcelBuffer."Cell Type"::Text);
                // EnterFilterInCell(
                //   RowNo, AccSchedLine.GetFilter("Cost Center Filter"), AccSchedLine.FieldCaption("Cost Center Filter"),
                //   '', TempExcelBuffer."Cell Type"::Text);
                // EnterFilterInCell(
                //   RowNo, AccSchedLine.GetFilter("Cost Object Filter"), AccSchedLine.FieldCaption("Cost Object Filter"),
                //   '', TempExcelBuffer."Cell Type"::Text);
                // EnterFilterInCell(
                //   RowNo, AccSchedLine.GetFilter("Cash Flow Forecast Filter"), AccSchedLine.FieldCaption("Cash Flow Forecast Filter"),
                //   '', TempExcelBuffer."Cell Type"::Text);

                // if ((AccSchedName."Analysis View Name" = '') and (GLSetup."Global Dimension 1 Code" <> '')) or
                //    ((AccSchedName."Analysis View Name" <> '') and (AnalysisView."Dimension 1 Code" <> ''))
                // then
                //     EnterFilterInCell(
                //       RowNo, AccSchedLine.GetFilter("Dimension 1 Filter"), GetDimFilterCaption(1), '', TempExcelBuffer."Cell Type"::Text);
                // if ((AccSchedName."Analysis View Name" = '') and (GLSetup."Global Dimension 2 Code" <> '')) or
                //    ((AccSchedName."Analysis View Name" <> '') and (AnalysisView."Dimension 2 Code" <> ''))
                // then
                //     EnterFilterInCell(
                //       RowNo, AccSchedLine.GetFilter("Dimension 2 Filter"), GetDimFilterCaption(2), '', TempExcelBuffer."Cell Type"::Text);
                // if (AccSchedName."Analysis View Name" = '') or
                //    ((AccSchedName."Analysis View Name" <> '') and (AnalysisView."Dimension 3 Code" <> ''))
                // then
                //     EnterFilterInCell(
                //       RowNo, AccSchedLine.GetFilter("Dimension 3 Filter"), GetDimFilterCaption(3), '', TempExcelBuffer."Cell Type"::Text);
                // if (AccSchedName."Analysis View Name" = '') or
                //    ((AccSchedName."Analysis View Name" <> '') and (AnalysisView."Dimension 4 Code" <> ''))
                // then
                //     EnterFilterInCell(
                //       RowNo, AccSchedLine.GetFilter("Dimension 4 Filter"), GetDimFilterCaption(4), '', TempExcelBuffer."Cell Type"::Text);

                // RowNo := RowNo + 1;
                // if UseAmtsInAddCurr then
                //     EnterFilterInCell(
                //       RowNo, GLSetup."Additional Reporting Currency", Currency.TableCaption, '', TempExcelBuffer."Cell Type"::Text)
                // else
                //     EnterFilterInCell(
                //       RowNo, GLSetup."LCY Code", Currency.TableCaption, '', TempExcelBuffer."Cell Type"::Text);

                // RowNo := RowNo + 1;
                // if AccSchedLine.Find('-') then begin
                //     if ColumnLayout.Find('-') then begin
                //         RowNo := RowNo + 1;
                //         ColumnNo := 2; // Skip the "Row No." column.
                //         repeat
                //             ColumnNo := ColumnNo + 1;
                //             EnterCell(
                //               RowNo, ColumnNo, ColumnLayout."Column Header", false, false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                //         until ColumnLayout.Next() = 0;
                //     end;
                //     repeat
                //         RecNo := RecNo + 1;
                //         Window.Update(1, Round(RecNo / TotalRecNo * 10000, 1));
                //         RowNo := RowNo + 1;
                //         ColumnNo := 1;
                //         EnterCell(
                //           RowNo, ColumnNo, AccSchedLine."Row No.",
                //           AccSchedLine.Bold, AccSchedLine.Italic, AccSchedLine.Underline, AccSchedLine."Double Underline",
                //           '0', TempExcelBuffer."Cell Type"::Text);
                //         ColumnNo := 2;
                //         EnterCell(
                //           RowNo, ColumnNo, AccSchedLine.Description,
                //           AccSchedLine.Bold, AccSchedLine.Italic, AccSchedLine.Underline, AccSchedLine."Double Underline",
                //           '', TempExcelBuffer."Cell Type"::Text);
                //         if ColumnLayout.Find('-') then begin
                //             repeat
                //                 CalcColumnValue();
                //                 ColumnNo := ColumnNo + 1;
                //                 EnterCell(
                //                   RowNo, ColumnNo, MatrixMgt.FormatAmount(ColumnValue, ColumnLayout."Rounding Factor", UseAmtsInAddCurr),
                //                   AccSchedLine.Bold, AccSchedLine.Italic, AccSchedLine.Underline, AccSchedLine."Double Underline",
                //                   '', TempExcelBuffer."Cell Type"::Number)
                //             until ColumnLayout.Next() = 0;
                //         end;
                //     until AccSchedLine.Next() = 0;
                // end;

                RowNo := 1;
                EnterCell(RowNo, 1, Text1140001, FALSE, FALSE, TRUE, false, '', TempExcelBuffer."Cell Type"::Text);
                if (AccSchedLine.GETFILTER("Date Filter") <> '') THEN BEGIN
                    RowNo := RowNo + 1;
                    EnterFilterInCell(
                        RowNo,
                        AccSchedLine.GETFILTER("Date Filter"),
                        AccSchedLine.FIELDCAPTION("Date Filter"), '', TempExcelBuffer."Cell Type"::Text);
                END;
                if (AccSchedLine.GETFILTER("Cash Flow Forecast Filter") <> '') THEN BEGIN
                    RowNo := RowNo + 1;
                    EnterFilterInCell(
                        RowNo,
                        AccSchedLine.GETFILTER("Cash Flow Forecast Filter"),
                        AccSchedLine.FIELDCAPTION("Cash Flow Forecast Filter"), '', TempExcelBuffer."Cell Type"::Text);
                END;
                RowNo := 4;
                if AccSchedLine.FIND('-') THEN BEGIN
                    if ColumnLayout.FIND('-') THEN BEGIN
                        RowNo := RowNo + 1;
                        ColumnNo := 1;
                        REPEAT
                            Window.Update(3, ColumnNo);
                            ColumnNo := ColumnNo + 1;
                            EnterCell(
                                RowNo,
                                ColumnNo,
                                ColumnLayout."Column Header",
                                FALSE,
                                FALSE,
                                AccSchedLine.Underline, AccSchedLine."Double Underline",
                                           '', TempExcelBuffer."Cell Type"::Text);
                        UNTIL ColumnLayout.NEXT = 0;
                    END;
                    REPEAT
                        RecNo := RecNo + 1;
                        Window.UPDATE(1, ROUND(RecNo / TotalRecNo * 10000, 1));
                        Window.Update(4, AccSchedLine."Row No.");
                        rDate.SETRANGE(rDate."Period Type", rDate."Period Type"::Date);
                        AccSchedLine.COPYFILTER("Date Filter", rDate."Period Start");
                        if rDate.FINDFIRST THEN
                            REPEAT
                                Window.Update(2, Format((rDate."Period Start")));
                                if (LiqAccSchedManagement.ExisteFecha(rDate."Period Start", AccSchedLine, (AccSchedLine."Totaling Type" = AccSchedLine."Totaling Type"::Formula)))
                                 THEN BEGIN
                                    RowNo := RowNo + 1;
                                    ColumnNo := 1;
                                    EnterCell(
                                    RowNo,
                                    ColumnNo,
                                    AccSchedLine.Description,
                                    AccSchedLine.Bold,
                                    AccSchedLine.Italic,
                                    AccSchedLine.Underline, AccSchedLine."Double Underline",
                                                   '', TempExcelBuffer."Cell Type"::Text);

                                    if ColumnLayout.FIND('-') THEN BEGIN
                                        REPEAT
                                            Window.Update(3, ColumnNo);
                                            FechD := rDate."Period Start";
                                            FechH := rDate."Period Start";
                                            if AccSchedLine."Totaling Type" = AccSchedLine."Totaling Type"::Formula THEN BEGIN
                                                FechD := FD;
                                                FechH := FH;
                                            END;
                                            if AccSchedLine.Totaling = '' THEN
                                                ColumnValue := 0
                                            ELSE BEGIN
                                                if ColumnLayout."Column Type" = ColumnLayout."Column Type"::Date THEN BEGIN
                                                    Fec := FORMAT(rDate."Period Start", 0, '<Day,2>/<Month,2>/<Year4>');
                                                    ColumnValue := 0;
                                                END
                                                ELSE
                                                    ColumnValue := LiqAccSchedManagement.CalcCellxDate(AccSchedLine, ColumnLayout, FechD, FechH);
                                            END;
                                            ColumnNo := ColumnNo + 1;

                                            if ColumnValue <> 0 THEN
                                                EnterCell(
                                                    RowNo,
                                                    ColumnNo,
                                                    FORMAT(ColumnValue),
                                                    AccSchedLine.Bold,
                                                    AccSchedLine.Italic,
                                                    AccSchedLine.Underline, AccSchedLine."Double Underline",
                                                           '', TempExcelBuffer."Cell Type"::Text)
                                            ELSE
                                                EnterCell(
                                                    RowNo,
                                                    ColumnNo,
                                                    Fec,
                                                    AccSchedLine.Bold,
                                                    AccSchedLine.Italic,
                                                    AccSchedLine.Underline, AccSchedLine."Double Underline",
                                                           '', TempExcelBuffer."Cell Type"::Text);
                                            Fec := '';
                                        UNTIL ColumnLayout.NEXT = 0;
                                    END;
                                END;
                                if AccSchedLine.Totaling = '' THEN if rDate.FINDLAST THEN;
                                if AccSchedLine."Totaling Type" = AccSchedLine."Totaling Type"::Formula THEN if rDate.FINDLAST THEN;
                            UNTIL rDate.NEXT = 0;

                    UNTIL AccSchedLine.NEXT = 0;
                END;
                Window.CLOSE;
                //Window.Close;

                if DoUpdateExistingWorksheet then begin
                    TempExcelBuffer.UpdateBookExcel(ServerFileName, SheetName, false);
                    TempExcelBuffer.WriteSheet('', CompanyName, UserId);
                    TempExcelBuffer.CloseBook;
                    if not TestMode then
                        TempExcelBuffer.OpenExcelWithName(ClientFileName);
                end else begin
                    TempExcelBuffer.CreateBook(ServerFileName, AccSchedName.Name);
                    TempExcelBuffer.WriteSheet(AccSchedName.Description, CompanyName, UserId);
                    TempExcelBuffer.CloseBook;
                    if not TestMode then
                        TempExcelBuffer.OpenExcel;
                end;
            end;
        }
    }

    requestpage
    {

        layout
        {
            area(Content)
            {
                field("Por Dias"; PorDias)
                {
                    ApplicationArea = All;
                }
                field(Desde; FD)
                {
                    ApplicationArea = All;
                }
                field(Hasta; FH)
                {
                    ApplicationArea = All;
                }
            }

        }

        actions
        {
        }
    }

    labels
    {
    }

    var
        //PD: Boolean;
        FD: Date;
        FH: Date;
        Alinear: Option Derecha,Centro,Izquierda;
        LiqSetup: Record "Cash Flow Setup";
        rLiq: Record "Cash Flow Forecast Entry";
        PorDias: Boolean;
        Text000: Label 'Analizando Datos...\\';
        Text001: Label 'Filtros';
        Text002: Label 'Actualizar Libro';
        AccSchedName: Record "Acc. Schedule Name";
        AccSchedLine: Record "Acc. Schedule Line";
        ColumnLayout: Record "Column Layout";
        TempExcelBuffer: Record "Excel Buffer" temporary;
        GLSetup: Record "General Ledger Setup";
        AnalysisView: Record "Analysis View";
        Currency: Record Currency;
        AccSchedManagement: Codeunit AccSchedManagement;
        MatrixMgt: Codeunit "Matrix Management";
        FileMgt: Codeunit "File Management";
        UseAmtsInAddCurr: Boolean;
        ColumnValue: Decimal;
        ServerFileName: Text;
        SheetName: Text[250];
        DoUpdateExistingWorksheet: Boolean;
        ExcelFileExtensionTok: Label '.xlsx', Locked = true;
        TestMode: Boolean;


    /// <summary>
    /// SetOptions.
    /// </summary>
    /// <param name="AccSchedLine2">VAR Record "Acc. Schedule Line".</param>
    /// <param name="ColumnLayoutName2">Code[10].</param>
    /// <param name="UseAmtsInAddCurr2">Boolean.</param>
    procedure SetOptions(var AccSchedLine2: Record "Acc. Schedule Line"; ColumnLayoutName2: Code[10]; UseAmtsInAddCurr2: Boolean)
    begin
        AccSchedLine.CopyFilters(AccSchedLine2);
        ColumnLayout.SetRange("Column Layout Name", ColumnLayoutName2);
        UseAmtsInAddCurr := UseAmtsInAddCurr2;
    end;

    /// <summary>
    /// CuentaBancos.
    /// </summary>
    /// <returns>Return value of type Text.</returns>
    procedure CuentaBancos(): Text
    var
        LiqAcc: Record "Cash Flow Account";
    begin

        LiqAcc.SETRANGE(LiqAcc."Source Type", LiqAcc."Source Type"::"Liquid Funds");
        if LiqAcc.FINDFIRST THEN EXIT(LiqAcc."No.");

    end;

    /// <summary>
    /// CuentaBancos2.
    /// </summary>
    /// <returns>Return value of type Text.</returns>
    procedure CuentaBancos2(): Text
    var
        LiqAcc: Record "Cash Flow Account";
    begin

        LiqAcc.SETRANGE(LiqAcc."Source Type", LiqAcc."Source Type"::"Liquid Funds");
        if LiqAcc.FINDFIRST THEN
            if LiqAcc.NEXT <> 0 THEN EXIT(LiqAcc."No.");
    end;

    /// <summary>
    /// porfechas.
    /// </summary>
    procedure porfechas()
    var
        Window: Dialog;
        RecNo: Integer;
        TotalRecNo: Integer;
        RowNo: Integer;
        ColumnNo: Integer;
        rDate: Record Date;
        tBanco: Record "Bank Account";
        rLiqDet: Record "Cash Flow Forecast Entry";
        rBanco: Record "Bank Account";
        Ingresos: Decimal;
        Gastos: Decimal;
        FormulaTxt: Text[250];
        ColNo: Integer;
        r289: Record "Payment Method";
        t289: Record "Payment Method" temporary;
        UltimaRow: Integer;
        Mes: Text[30];
        UltimaColum: Integer;
        Inicio: Date;
        ClientFileName: Text;
        Fin: Date;
        Total: Decimal;
        UltimaRow2: Integer;
        UltimaCol: Integer;
        Text1140000: Label 'Analizar Datos...\\';
        Text1140001: Label 'Filtros';
        Text1140002: Label 'Actualizar libro';
        Text2140000: Label 'Pagos por días...\\';
        Text3140000: Label 'Resumen Cartera...\\';
        Text4140000: Label 'Disponibilidad...\\';
        Text5140000: Label 'Cartera Bco...\\';
        Text8140000: Label 'Alineando celdas...\\';

    begin

        // {LiqSetup.GET;
        // LiqAccSchedName.GET(AccSchedLine.GETRANGEMIN("Schedule Name"));
        // LiqAccSchedManagement.CheckAnalysisView(LiqAccSchedName.Name,ColumnLayout.GETRANGEMIN("Column Layout Name"),TRUE);
        // }
        Window.OPEN(
        Text1140000 +
        '@1@@@@@@@@@@@@@@@@@@@@@\');
        Window.UPDATE(1, 0);
        rDate.SETRANGE(rDate."Period Type", rDate."Period Type"::Date);
        rDate.SETRANGE(rDate."Period Start", FD, FH);
        TotalRecNo := rDate.COUNTAPPROX;
        RecNo := 0;
        //rLiqDet.SETRANGE(rLiqDet."Due Date",FD,FH);
        rLiqDet.SETRANGE(rLiqDet."Cash Flow Account No.", CuentaBancos);
        if rLiqDet.FINDFIRST THEN
            REPEAT
                if rBanco.GET(rLiqDet."Cod banco") THEN BEGIN
                    tBanco := rBanco;
                    if rBanco."Name 2" <> '' THEN tBanco.Name := rBanco."Name 2";
                END ELSE BEGIN
                    tBanco."No." := 'SIN BANCO';
                    tBanco.Name := 'Sin Banco';
                END;
                tBanco.Amount := rLiqDet."Amount (LCY)";
                if tBanco.INSERT THEN;
            UNTIL rLiqDet.NEXT = 0;
        //Conciliaciones
        rLiqDet.SETRANGE(rLiqDet."Cash Flow Account No.", CuentaBancos2);
        if rLiqDet.FINDFIRST THEN
            REPEAT
                if NOT tBanco.GET(rLiqDet."Cod banco") THEN BEGIN
                    if rBanco.GET(rLiqDet."Cod banco") THEN BEGIN
                        tBanco := rBanco;
                        if rBanco."Name 2" <> '' THEN tBanco.Name := rBanco."Name 2";
                    END ELSE BEGIN
                        tBanco."No." := 'SIN BANCO';
                        tBanco.Name := 'Sin Banco';
                    END;
                    tBanco."Min. Balance" := 0;
                    if tBanco.INSERT THEN;
                END;
                if rLiqDet."Amount (LCY)" > 0 THEN
                    tBanco."Min. Balance" := tBanco."Min. Balance" + rLiqDet."Amount (LCY)"
                ELSE
                    tBanco."Credit Limit for Discount" := tBanco."Credit Limit for Discount" + rLiqDet."Amount (LCY)";
                tBanco.MODIFY;
            UNTIL rLiqDet.NEXT = 0;

        tBanco."No." := 'SIN BANCO';
        tBanco.Name := 'Sin Banco';
        if tBanco.INSERT THEN;
        rLiqDet.SETRANGE(rLiqDet."Cash Flow Account No.");
        rLiqDet.SETRANGE(rLiqDet."Cash Flow Date", FD, FH);
        if rLiqDet.FINDFIRST THEN
            REPEAT
                if (rLiqDet."Amount (LCY)" > 0) AND //{(rLiqDet."Es Cartera") AND}
                EnCartera(rLiqDet."Associated Entry No.") THEN BEGIN
                    if r289.GET(rLiqDet."Payment Method Code") THEN BEGIN
                        t289 := r289;
                        //if r2."Name 2"<>'' THEN tBanco.Name:=rBanco."Name 2";
                    END ELSE BEGIN
                        t289.Code := 'S/FP';
                        t289.Description := 'Sin Forma';
                    END;
                    if t289.INSERT THEN;
                END;
            UNTIL rLiqDet.NEXT = 0;

        TempExcelBuffer.DELETEALL;
        CLEAR(TempExcelBuffer);
        rLiqDet.RESET;
        rLiqDet.SETRANGE(rLiqDet."Cash Flow Date", FD, FH);
        if rLiqDet.FINDFIRST THEN
            REPEAT
                Acumula(rLiqDet);
            UNTIL rLiqDet.NEXT = 0;
        RowNo := 1;
        EnterCell(RowNo, 1, COMPANYNAME, FALSE, FALSE, TRUE, AccSchedLine."Double Underline",
                          '0', TempExcelBuffer."Cell Type"::Text);
        ColumnNo := 2;
        tBanco.SETFILTER(tBanco."No.", '<>%1', 'SIN BANCO');
        if tBanco.FINDFIRST THEN
            REPEAT
                RowNo := 1;
                RowNo := RowNo + 1;
                EnterCell(
                    RowNo,
                    ColumnNo,
                    tBanco.Name, TRUE, FALSE, FALSE, AccSchedLine."Double Underline",
                                  '0', TempExcelBuffer."Cell Type"::Text);
                EnterCell(
                    RowNo + 1,
                    ColumnNo,
                    'Ingresos', TRUE, FALSE, FALSE, AccSchedLine."Double Underline",
                                  '0', TempExcelBuffer."Cell Type"::Text);
                EnterCell(
                    RowNo + 1,
                    ColumnNo + 1,
                    'Pagos', TRUE, FALSE, FALSE, AccSchedLine."Double Underline",
                                  '0', TempExcelBuffer."Cell Type"::Text);
                EnterCell(
                    RowNo + 1,
                    ColumnNo + 2,
                    'Saldo', TRUE, FALSE, FALSE, AccSchedLine."Double Underline",
                                  '0', TempExcelBuffer."Cell Type"::Text);

                ColumnNo := ColumnNo + 3;
            UNTIL tBanco.NEXT = 0;
        rDate.FINDFIRST;
        RowNo := 3;
        //Primera Línea;
        RowNo := RowNo + 1;
        ColumnNo := 2;
        EnterCell(
            RowNo,
            ColumnNo - 1,
            'Saldos', FALSE, FALSE, FALSE, AccSchedLine."Double Underline",
                          '0', TempExcelBuffer."Cell Type"::Text);
        if tBanco.FIND('-') THEN
            REPEAT
                Ingresos := tBanco."Min. Balance";
                Gastos := -tBanco."Credit Limit for Discount";
                EnterCell(
                    RowNo,
                    ColumnNo,
                    FORMAT(Ingresos), FALSE, FALSE, FALSE, AccSchedLine."Double Underline",
                                  '0', TempExcelBuffer."Cell Type"::Text);
                EnterCell(
                    RowNo,
                    ColumnNo + 1,
                    FORMAT(Gastos), FALSE, FALSE, FALSE, AccSchedLine."Double Underline",
                                  '0', TempExcelBuffer."Cell Type"::Text);
                EnterCell(
                    RowNo,
                    ColumnNo + 2,
                    FORMAT(tBanco.Amount + Ingresos - Gastos), FALSE, FALSE, FALSE, AccSchedLine."Double Underline",
                                  '0', TempExcelBuffer."Cell Type"::Text);

                //EnterCellFormula(RowNo,ColumnNo+2,'='+DevuelveLetra(ColumnNo)+FORMAT(RowNo)+
                //                         '-'+DevuelveLetra(ColumnNo+1)+FORMAT(RowNo),TRUE,FALSE,FALSE);
                ColumnNo := ColumnNo + 3;
            UNTIL tBanco.NEXT = 0;

        //Fin Primera Línea
        REPEAT
            RecNo := RecNo + 1;
            Window.UPDATE(1, ROUND(RecNo / TotalRecNo * 10000, 1));

            RowNo := RowNo + 1;
            ColumnNo := 2;
            EnterCell(
                RowNo,
                ColumnNo - 1,
                FORMAT(rDate."Period Start", 0, '<Day,2>/<Month,2>/<Year>'), FALSE, FALSE, FALSE, AccSchedLine."Double Underline",
                              '0', TempExcelBuffer."Cell Type"::Text);

            if tBanco.FIND('-') THEN
                REPEAT
                    rLiqDet.RESET;
                    rLiqDet.SETFILTER(rLiqDet."Cash flow Account No.", '<>%1', CuentaBancos);
                    rLiqDet.SETRANGE(rLiqDet."Cash Flow Date", rDate."Period Start");
                    rLiqDet.SETRANGE("Es Cartera", TRUE);
                    if tBanco."No." = 'SIN BANCO' THEN
                        rLiqDet.SETFILTER(rLiqDet."Cod banco", '%1|%2', ' ', 'SIN BANCO')
                    ELSE
                        rLiqDet.SETRANGE(rLiqDet."Cod banco", tBanco."No.");
                    rLiqDet.SETFILTER(rLiqDet."Amount (LCY)", '>%1', 0);
                    Ingresos := 0;
                    if rLiqDet.FINDFIRST THEN
                        REPEAT
                            Ingresos := Ingresos + rLiqDet."Amount (LCY)";
                        UNTIL rLiqDet.NEXT = 0;
                    EnterCell(
                        RowNo,
                        ColumnNo,
                        FORMAT(Ingresos), FALSE, FALSE, FALSE, AccSchedLine."Double Underline",
                                      '0', TempExcelBuffer."Cell Type"::Text);
                    rLiqDet.RESET;
                    rLiqDet.SETFILTER(rLiqDet."Cash Flow Account No.", '<>%1', CuentaBancos);
                    rLiqDet.SETRANGE(rLiqDet."Cash Flow Date", rDate."Period Start");
                    rLiqDet.SETRANGE("Es Cartera", TRUE);
                    if tBanco."No." = 'SIN BANCO' THEN
                        rLiqDet.SETFILTER(rLiqDet."Cod banco", '%1|%2', ' ', 'SIN BANCO')
                    ELSE
                        rLiqDet.SETRANGE(rLiqDet."Cod banco", tBanco."No.");
                    rLiqDet.SETFILTER(rLiqDet."Amount (LCY)", '<%1', 0);
                    Gastos := 0;
                    if rLiqDet.FINDFIRST THEN
                        REPEAT
                            Gastos := Gastos - rLiqDet."Amount (LCY)";
                        UNTIL rLiqDet.NEXT = 0;
                    EnterCell(
                        RowNo,
                        ColumnNo + 1,
                        FORMAT(Gastos), FALSE, FALSE, FALSE, AccSchedLine."Double Underline",
                                      '0', TempExcelBuffer."Cell Type"::Text);
                    //if RowNo>4 THEN
                    EnterCellFormula(RowNo, ColumnNo + 2, '=' + DevuelveLetra(ColumnNo + 2) + FORMAT(RowNo - 1) +
                                            '+' + DevuelveLetra(ColumnNo) + FORMAT(RowNo) +
                                            '-' + DevuelveLetra(ColumnNo + 1) + FORMAT(RowNo), TRUE, FALSE, FALSE);

                    //ELSE
                    //EnterCellFormula(RowNo,ColumnNo+2,'='+DevuelveLetra(ColumnNo)+FORMAT(RowNo)+
                    //                         '-'+DevuelveLetra(ColumnNo+1)+FORMAT(RowNo),TRUE,FALSE,FALSE);
                    ColumnNo := ColumnNo + 3;
                UNTIL tBanco.NEXT = 0;
        UNTIL rDate.NEXT = 0;

        Window.CLOSE;
        //Saldo Global
        EnterCell(2, ColumnNo, 'GLOBAL', TRUE, FALSE, FALSE, AccSchedLine."Double Underline",
                          '0', TempExcelBuffer."Cell Type"::Text);
        EnterCell(3, ColumnNo, 'Saldo', TRUE, FALSE, FALSE, AccSchedLine."Double Underline",
                          '0', TempExcelBuffer."Cell Type"::Text);
        rDate.FINDFIRST;
        RowNo := 3;
        RowNo := RowNo + 1;
        ColNo := 4;
        tBanco.RESET;
        if tBanco.FINDFIRST THEN
            REPEAT
                FormulaTxt := FormulaTxt + '+' + DevuelveLetra(ColNo) + FORMAT(RowNo);
                ColNo := ColNo + 3;
            UNTIL tBanco.NEXT = 0;
        EnterCellFormula(RowNo, ColumnNo, '=' + FormulaTxt, TRUE, FALSE, FALSE);

        REPEAT
            RowNo := RowNo + 1;
            ColNo := 4;
            tBanco.RESET;
            FormulaTxt := '';
            if tBanco.FINDFIRST THEN
                REPEAT
                    FormulaTxt := FormulaTxt + '+' + DevuelveLetra(ColNo) + FORMAT(RowNo);
                    ColNo := ColNo + 3;
                UNTIL tBanco.NEXT = 0;
            if RowNo > 50000 Then//{Es provisional para que no suceda nunca} THEN
                EnterCellFormula(RowNo, ColumnNo, '=' + DevuelveLetra(ColumnNo) + FORMAT(RowNo - 1) +
                                        FormulaTxt, TRUE, FALSE, FALSE)

            ELSE
                EnterCellFormula(RowNo, ColumnNo, '=' + FormulaTxt, TRUE, FALSE, FALSE);

        UNTIL rDate.NEXT = 0;



        //Fin Saldo Global
        //Detalle Pagos
        tBanco.SETRANGE(tBanco."No.", 'SIN BANCO');
        UltimaRow := RowNo;
        RowNo := RowNo + 1;
        Window.OPEN(
        Text2140000 +
        '@1@@@@@@@@@@@@@@@@@@@@@\');
        Window.UPDATE(1, 0);
        rDate.SETRANGE(rDate."Period Type", rDate."Period Type"::Date);
        rDate.SETRANGE(rDate."Period Start", FD, FH);
        TotalRecNo := rDate.COUNTAPPROX;
        rLiqDet.SETRANGE(rLiqDet."Cash Flow Date", FD, FH);
        EnterCell(RowNo, 1, 'PAGOS:', FALSE, FALSE, TRUE, AccSchedLine."Double Underline",
                          '0', TempExcelBuffer."Cell Type"::Text);
        ColumnNo := 7;//9
        if tBanco.FINDFIRST THEN
            REPEAT
                EnterCell(
                    RowNo,
                    ColumnNo,
                    tBanco.Name, FALSE, FALSE, FALSE, AccSchedLine."Double Underline",
                                  '0', TempExcelBuffer."Cell Type"::Text);
                tBanco."Statistics Group" := ColumnNo;
                tBanco.MODIFY;
                ColumnNo := ColumnNo + 1;
            UNTIL tBanco.NEXT = 0;
        UltimaColum := ColumnNo;
        RecNo := 0;
        rDate.FINDFIRST;
        REPEAT
            RecNo := RecNo + 1;
            Window.UPDATE(1, ROUND(RecNo / TotalRecNo * 10000, 1));
            rLiqDet.RESET;
            rLiqDet.SETRANGE(rLiqDet."Cash Flow Date", rDate."Period Start");
            rLiqDet.SETRANGE("Es Cartera");
            rLiqDet.SETFILTER(rLiqDet."Amount (LCY)", '<%1', 0);
            Ingresos := 0;
            if rLiqDet.FINDFIRST THEN
                REPEAT
                    if rLiqDet."Cash flow Account No." <> LiqSetup."Receivables CF Account No." THEN BEGIN
                        Ingresos := Ingresos - rLiqDet."Amount (LCY)";
                    END;
                UNTIL rLiqDet.NEXT = 0;
            if Ingresos <> 0 THEN BEGIN
                RowNo := RowNo + 1;
                EnterCell(
                    RowNo,
                    1,
                    FORMAT(rDate."Period Start", 0, '<Day,2>/<Month,2>/<Year>'), TRUE, FALSE, FALSE, AccSchedLine."Double Underline",
                                  '0', TempExcelBuffer."Cell Type"::Text);
                EnterCell(
                    RowNo,
                    2,
                    'Vencimiento ' + FORMAT(rDate."Period Start", 0, '<Day,2>/<Month,2>/<Year>'), FALSE, FALSE, FALSE, AccSchedLine."Double Underline",
                                  '0', TempExcelBuffer."Cell Type"::Text);


            END;
            tBanco.RESET;
            tBanco.SETRANGE(tBanco."No.", 'SIN BANCO');
            if tBanco.FINDFIRST THEN
                REPEAT
                    rLiqDet.RESET;
                    rLiqDet.SETRANGE(rLiqDet."Cash Flow Date", rDate."Period Start");
                    rLiqDet.SETRANGE("Es Cartera");
                    if tBanco."No." = 'SIN BANCO' THEN
                        rLiqDet.SETFILTER(rLiqDet."Cod banco", '%1|%2', ' ', tBanco."No.")
                    ELSE
                        rLiqDet.SETRANGE(rLiqDet."Cod banco", tBanco."No.");
                    //  if tBanco."No."='SIN BANCO' THEN
                    rLiqDet.SETFILTER(rLiqDet."Amount (LCY)", '<%1', 0);
                    Gastos := 0;
                    Ingresos := 0;
                    if rLiqDet.FINDFIRST THEN
                        REPEAT
                            if rLiqDet."Cash Flow Account No." <> LiqSetup."Receivables CF Account No." THEN BEGIN
                                Ingresos := Ingresos - rLiqDet."Amount (LCY)";
                            END;
                        UNTIL rLiqDet.NEXT = 0;
                    if Ingresos <> 0 THEN BEGIN
                        //RowNo := RowNo + 1;
                        //Ingresos:=-rLiqDet.Amount;
                        //if NOT tBanco.GET(rLiqDet."Cod banco") THEN
                        //tBanco.GET('SIN BANCO');
                        ColumnNo := tBanco."Statistics Group";
                        EnterCell(
                            RowNo,
                            ColumnNo,
                            FORMAT(Ingresos), FALSE, FALSE, FALSE, AccSchedLine."Double Underline",
                                          '0', TempExcelBuffer."Cell Type"::Text);
                    END;
                UNTIL tBanco.NEXT = 0;
        UNTIL rDate.NEXT = 0;

        //Fin Detalle
        Window.CLOSE;
        //Resumen Cobros
        RowNo := UltimaRow;
        ColumnNo := UltimaColum;
        RowNo := RowNo + 1;
        Window.OPEN(
        Text3140000 +
        '@1@@@@@@@@@@@@@@@@@@@@@\');
        Window.UPDATE(1, 0);
        rDate.RESET;
        rDate.SETRANGE(rDate."Period Type", rDate."Period Type"::Month);
        rDate.SETRANGE(rDate."Period Start", CALCDATE('PM+1D-1M', FD), CALCDATE('PM', FH));
        TotalRecNo := rDate.COUNTAPPROX;
        rLiqDet.RESET;
        rLiqDet.SETRANGE(rLiqDet."Cash Flow Date", 20000101D, FH);
        //ColumnNo:=ColumnNo+1;
        UltimaCol := ColumnNo;
        EnterCell(RowNo, ColumnNo, 'REMESABLE:', FALSE, FALSE, TRUE, AccSchedLine."Double Underline",
                          '0', TempExcelBuffer."Cell Type"::Text);
        //ColumnNo:=ColumnNo+1;
        if t289.FINDFIRST THEN
            REPEAT
                RowNo := RowNo + 1;
                EnterCell(
                    RowNo,
                    ColumnNo,
                    t289.Description, FALSE, FALSE, FALSE, AccSchedLine."Double Underline",
                                  '0', TempExcelBuffer."Cell Type"::Text);
                t289.RowNo := RowNo;
                t289.MODIFY;
            UNTIL t289.NEXT = 0;
        Mes := '';
        UltimaRow2 := RowNo;
        RowNo := UltimaRow;
        RowNo := RowNo + 1;
        RecNo := 0;
        rDate.FINDFIRST;
        REPEAT
            RecNo := RecNo + 1;
            Window.UPDATE(1, ROUND(RecNo / TotalRecNo * 10000, 1));

            RowNo := UltimaRow;
            RowNo := RowNo + 1;
            //  if Mes<>rDate."Period Name" THEN BEGIN
            Mes := rDate."Period Name";
            ColumnNo := ColumnNo + 1;
            EnterCell(
                UltimaRow + 1,
                ColumnNo + 2,
                Mes, FALSE, FALSE, FALSE, AccSchedLine."Double Underline",
                              '0', TempExcelBuffer."Cell Type"::Text);

            //  END;
            if t289.FINDFIRST THEN
                REPEAT
                    rLiqDet.RESET;
                    rLiqDet.SETRANGE(rLiqDet."Payment Method Code", t289.Code);
                    if rDate."Period Start" <= FD THEN
                        Inicio := 20010101D
                    ELSE
                        Inicio := rDate."Period Start";
                    if rDate."Period End" > FH THEN
                        Fin := FH
                    ELSE
                        Fin := rDate."Period End";

                    rLiqDet.SETRANGE(rLiqDet."Cash flow Date", Inicio, Fin);
                    //  rLiqDet.SETRANGE("Es Cartera",TRUE);
                    //  if tBanco."No."='SIN BANCO' THEN
                    rLiqDet.SETFILTER(rLiqDet."Amount (LCY)", '>%1', 0);
                    Ingresos := 0;
                    if rLiqDet.FINDFIRST THEN
                        REPEAT
                            if EnCarteraR(rLiqDet."Associated Entry No.") THEN BEGIN
                                Ingresos := Ingresos + rLiqDet."Amount (LCY)";
                                Total := Total + rLiqDet."Amount (LCY)";
                            END;
                        UNTIL rLiqDet.NEXT = 0;
                    EnterCell(
                        t289.RowNo,
                        ColumnNo + 2,
                        FORMAT(Ingresos), FALSE, FALSE, FALSE, AccSchedLine."Double Underline",
                                      '0', TempExcelBuffer."Cell Type"::Text);

                UNTIL t289.NEXT = 0;
            EnterCell(
                UltimaRow2 + 1,
                ColumnNo + 2,
                FORMAT(Total), FALSE, FALSE, FALSE, AccSchedLine."Double Underline",
                              '0', TempExcelBuffer."Cell Type"::Text);
            Total := 0;
        UNTIL rDate.NEXT = 0;
        EnterCell(
            UltimaRow2 + 1,
            UltimaCol,
            'Total', FALSE, FALSE, FALSE, AccSchedLine."Double Underline",
                          '0', TempExcelBuffer."Cell Type"::Text);

        //Fin Remesas
        //Disponibilidad Cobros
        RowNo := UltimaRow2 + 1;
        RowNo := RowNo + 1;
        Window.OPEN(
        Text4140000 +
        '@1@@@@@@@@@@@@@@@@@@@@@\');
        Window.UPDATE(1, 0);
        rDate.RESET;
        rDate.SETRANGE(rDate."Period Type", rDate."Period Type"::Date);
        rDate.SETRANGE(rDate."Period Start", FD, CALCDATE('+3D', FD));
        TotalRecNo := rDate.COUNTAPPROX;
        ColumnNo := UltimaCol;
        EnterCell(RowNo, ColumnNo, 'DISPONIB:', FALSE, FALSE, TRUE, AccSchedLine."Double Underline",
                          '0', TempExcelBuffer."Cell Type"::Text);
        if tBanco.FINDFIRST THEN
            REPEAT
                if tBanco."No." <> 'SIN BANCO' THEN BEGIN
                    ColumnNo := ColumnNo + 1;
                    EnterCell(
                        RowNo,
                        ColumnNo,
                        tBanco.Name, FALSE, FALSE, FALSE, AccSchedLine."Double Underline",
                                      '0', TempExcelBuffer."Cell Type"::Text);
                END;
            UNTIL tBanco.NEXT = 0;
        RecNo := 0;
        rDate.FINDFIRST;
        REPEAT
            RowNo := RowNo + 1;
            RecNo := RecNo + 1;
            Window.UPDATE(1, ROUND(RecNo / TotalRecNo * 10000, 1));
            Mes := FORMAT(rDate."Period Start", 0, '<Day,2>/<Month Text>');
            ColumnNo := UltimaCol;
            EnterCell(
            RowNo,
            ColumnNo,
            Mes, FALSE, FALSE, FALSE, AccSchedLine."Double Underline",
                          '0', TempExcelBuffer."Cell Type"::Text);
        UNTIL rDate.NEXT = 0;

        //Fin Dispo
        //Disponibilidad Cartera Baco
        RowNo := RowNo + 1;
        Window.OPEN(
        Text5140000 +
        '@1@@@@@@@@@@@@@@@@@@@@@\');
        Window.UPDATE(1, 0);
        rDate.RESET;
        rDate.SETRANGE(rDate."Period Type", rDate."Period Type"::Date);
        rDate.SETRANGE(rDate."Period Start", FD, CALCDATE('+2D', FD));
        TotalRecNo := rDate.COUNTAPPROX;
        ColumnNo := UltimaCol;
        EnterCell(RowNo, ColumnNo, 'CARTERA BCO.', FALSE, FALSE, TRUE, AccSchedLine."Double Underline",
                          '0', TempExcelBuffer."Cell Type"::Text);
        if tBanco.FINDFIRST THEN
            REPEAT
                if tBanco."No." <> 'SIN BANCO' THEN BEGIN
                    ColumnNo := ColumnNo + 1;
                    EnterCell(
                        RowNo,
                        ColumnNo,
                        tBanco.Name, FALSE, FALSE, FALSE, AccSchedLine."Double Underline",
                                      '0', TempExcelBuffer."Cell Type"::Text);
                    if rBanco.GET(tBanco."No.") THEN BEGIN
                        rBanco.SETRANGE(rBanco."Dealing Type Filter", rBanco."Dealing Type Filter"::Discount);
                        rBanco.CALCFIELDS("Posted Receiv. Bills Rmg. Amt.");
                        EnterCell(
                        RowNo + 1,
                        ColumnNo,
                        FORMAT(rBanco."Credit Limit for Discount"), FALSE, FALSE, FALSE, AccSchedLine."Double Underline",
                                      '0', TempExcelBuffer."Cell Type"::Text);
                        EnterCell(
                        RowNo + 2,
                        ColumnNo,
                        FORMAT(rBanco."Posted Receiv. Bills Rmg. Amt." + NonPostesDiscAmt(rBanco."No."))
                        , FALSE, FALSE, FALSE, AccSchedLine."Double Underline",
                                      '0', TempExcelBuffer."Cell Type"::Text);
                        EnterCell(
                            RowNo + 3,
                            ColumnNo,
                            FORMAT(rBanco."Credit Limit for Discount" -
                            rBanco."Posted Receiv. Bills Rmg. Amt." - NonPostesDiscAmt(rBanco."No.")), FALSE, FALSE, FALSE, AccSchedLine."Double Underline",
                                          '0', TempExcelBuffer."Cell Type"::Text);
                    END;
                END;
            UNTIL tBanco.NEXT = 0;
        RecNo := 0;
        rDate.FINDFIRST;
        REPEAT
            RowNo := RowNo + 1;
            RecNo := RecNo + 1;
            Window.UPDATE(1, ROUND(RecNo / TotalRecNo * 10000, 1));
            CASE RecNo OF
                1:
                    Mes := 'disponibilidad';
                2:
                    Mes := 'dispuesto';
                3:
                    Mes := 'disponible';
            END;
            ColumnNo := UltimaCol;
            EnterCell(
            RowNo,
            ColumnNo,
            Mes, FALSE, FALSE, FALSE, AccSchedLine."Double Underline",
                          '0', TempExcelBuffer."Cell Type"::Text);
        UNTIL rDate.NEXT = 0;

        //Fin Cartera BCO

        // if Option = Option::"Update Workbook" THEN BEGIN
        // TempExcelBuffer.OpenBook(FileName,SheetName);
        // TempExcelBuffer.CreateSheet(SheetName,'',COMPANYNAME,USERID);
        // END ELSE BEGIN
        // //LiqAccSchedName.GET(AccSchedLine."Schedule Name");
        // TempExcelBuffer.CreateBook;
        // LiqAccSchedName.FINDFIRST;
        // TempExcelBuffer.CreateSheet(LiqAccSchedName.Name,LiqAccSchedName.Description,COMPANYNAME,USERID);
        // END;

        if DoUpdateExistingWorksheet then begin
            TempExcelBuffer.UpdateBookExcel(ServerFileName, SheetName, false);
            TempExcelBuffer.WriteSheet(AccSchedName.Description, CompanyName, UserId);
            TempExcelBuffer.CloseBook;
            if not TestMode then
                TempExcelBuffer.OpenExcelWithName(ClientFileName);
        end else begin
            TempExcelBuffer.CreateBook(ServerFileName, AccSchedName.Name);
            TempExcelBuffer.WriteSheet(AccSchedName.Description, CompanyName, UserId);
            TempExcelBuffer.CloseBook;
            if not TestMode then
                TempExcelBuffer.OpenExcel;
        end;


        RowNo := 1;
        ColumnNo := 2;
        tBanco.SETFILTER(tBanco."No.", '<>%1', 'SIN BANCO');
        if tBanco.FINDFIRST THEN
            REPEAT
                RowNo := 1;
                RowNo := RowNo + 1;
                TempExcelBuffer.SetCurrent(RowNo, ColumnNo);
                TempExcelBuffer.StartRange;
                TempExcelBuffer.SetCurrent(RowNo, ColumnNo + 2);
                TempExcelBuffer.EndRange;
                TempExcelBuffer.CreateRange('R' + CONVERTSTR(tBanco."No.", ' ', '_'));
                // TempExcelBuffer.AutoFit('R' + CONVERTSTR(tBanco."No.", ' ', '_'));
                // TempExcelBuffer.Merge('R' + CONVERTSTR(tBanco."No.", ' ', '_'), Alinear::Centro);
                // TempExcelBuffer.AutoFit('R' + CONVERTSTR(tBanco."No.", ' ', '_'));
                ColumnNo := ColumnNo + 3;
            UNTIL tBanco.NEXT = 0;
        Window.OPEN(
        Text8140000 +
        '@1@@@@@@@@@@@@@@@@@@@@@\');
        Window.UPDATE(1, 0);

        RowNo := UltimaRow;
        RecNo := 0;
        rDate.SETRANGE(rDate."Period Type", rDate."Period Type"::Date);
        rLiqDet.RESET;
        TotalRecNo := rDate.COUNTAPPROX;
        rDate.FINDFIRST;
        REPEAT
            // rLiqDet.RESET;
            // rLiqDet.SETRANGE(rLiqDet."Due Date",rDate."Period Start");
            // if rLiqDet.FINDFIRST THEN REPEAT
            RecNo := RecNo + 1;
            Window.UPDATE(1, ROUND(RecNo / TotalRecNo * 10000, 1));

            RowNo := RowNo + 1;
            TempExcelBuffer.SetCurrent(RowNo, 2);
            TempExcelBuffer.StartRange;
            TempExcelBuffer.SetCurrent(RowNo, 6);//8
            TempExcelBuffer.EndRange;
            TempExcelBuffer.CreateRange('F_' + FORMAT(RowNo));
        //  TempExcelBuffer.Merge('F_' + FORMAT(RowNo), Alinear::Izquierda);
        // UNTIL rLiqDet.NEXT=0;
        UNTIL rDate.NEXT = 0;
        TempExcelBuffer.VALIDATE("Row No.", 1000);
        TempExcelBuffer.VALIDATE("Column No.", 100);
        //  TempExcelBuffer.AutoFitAll;
        Window.CLOSE;
        //        TempExcelBuffer.GiveUserControl;
    end;

    /// <summary>
    /// EnCarteraR.
    /// </summary>
    /// <param name="Num">Integer.</param>
    /// <returns>Return value of type Boolean.</returns>
    procedure EnCarteraR(Num: Integer): Boolean
    var
        rCar: Record "Cartera Doc.";
    begin

        if rCar.GET(rCar.Type::Receivable, Num) THEN EXIT(TRUE);
        //if rPos.GET(rPos.Type::Receivable,Num) THEN EXIT(TRUE);
        EXIT(FALSE);
    end;

    /// <summary>
    /// NonPostesDiscAmt.
    /// </summary>
    /// <param name="NoBco">Code[20].</param>
    /// <returns>Return value of type Decimal.</returns>
    procedure NonPostesDiscAmt(NoBco: Code[20]): Decimal
    var
        BillGr: Record "Bill Group";
        NonPostedDiscAmt: Decimal;
        BillGrc: Record "Posted Bill Group";
    begin

        BillGr.SETRANGE(BillGr."Bank Account No.", NoBco);
        BillGr.SETRANGE(BillGr."Remesa al descuento", TRUE);
        if BillGr.FIND('-') THEN BEGIN
            REPEAT
                BillGr.CALCFIELDS(Amount);
                NonPostedDiscAmt := NonPostedDiscAmt + BillGr.Amount;
            UNTIL BillGr.NEXT = 0;
        END;
        BillGrc.SETRANGE(BillGrc."Bank Account No.", NoBco);
        BillGrc.SETRANGE(BillGrc."Remesa al descuento", TRUE);
        if BillGrc.FIND('-') THEN BEGIN
            REPEAT
                BillGrc.CALCFIELDS(Amount);
                NonPostedDiscAmt := NonPostedDiscAmt + BillGrc.Amount;
            UNTIL BillGrc.NEXT = 0;
        END;

        EXIT(NonPostedDiscAmt);

    end;

    /// <summary>
    /// EnCartera.
    /// </summary>
    /// <param name="Num">Integer.</param>
    /// <returns>Return value of type Boolean.</returns>
    procedure EnCartera(Num: Integer): Boolean
    var
        rCar: Record "Cartera Doc.";
    begin

        if rCar.GET(rCar.Type::Receivable, Num) THEN EXIT(TRUE);
        //if rPos.GET(rPos.Type::Receivable,Num) THEN EXIT(TRUE);
        EXIT(FALSE);
    end;

    /// <summary>
    /// Acumula.
    /// </summary>
    /// <param name="rLiq">VAR Record "Cash Flow Forecast Entry".</param>
    procedure Acumula(var rLiq: Record "Cash Flow Forecast Entry")
    begin

    end;

    local procedure CalcColumnValue()
    begin
        OnBeforeCalcColumnValue(UseAmtsInAddCurr, ColumnLayout);
        if AccSchedLine.Totaling = '' then
            ColumnValue := 0
        else begin
            ColumnValue := AccSchedManagement.CalcCell(AccSchedLine, ColumnLayout, UseAmtsInAddCurr);
            if AccSchedManagement.GetDivisionError then
                ColumnValue := 0
        end;
        OnAferCalcColumnValue(UseAmtsInAddCurr, ColumnLayout);
    end;

    local procedure EnterFilterInCell(var RowNo: Integer; "Filter": Text[250]; FieldName: Text[100]; Format: Text[30]; CellType: Option)
    begin
        if Filter <> '' then begin
            RowNo := RowNo + 1;
            EnterCell(RowNo, 1, FieldName, false, false, false, false, '', TempExcelBuffer."Cell Type"::Text);
            EnterCell(RowNo, 2, Filter, false, false, false, false, Format, CellType);
        end;
    end;

    local procedure EnterCell(RowNo: Integer; ColumnNo: Integer; CellValue: Text[250]; Bold: Boolean; Italic: Boolean; UnderLine: Boolean; DoubleUnderLine: Boolean; Format: Text[30]; CellType: Option)
    begin
        TempExcelBuffer.Init();
        TempExcelBuffer.Validate("Row No.", RowNo);
        TempExcelBuffer.Validate("Column No.", ColumnNo);
        TempExcelBuffer."Cell Value as Text" := CellValue;
        TempExcelBuffer.Formula := '';
        TempExcelBuffer.Bold := Bold;
        TempExcelBuffer.Italic := Italic;
        if DoubleUnderLine = true then begin
            TempExcelBuffer."Double Underline" := true;
            TempExcelBuffer.Underline := false;
        end else begin
            TempExcelBuffer."Double Underline" := false;
            TempExcelBuffer.Underline := UnderLine;
        end;
        TempExcelBuffer.NumberFormat := Format;
        TempExcelBuffer."Cell Type" := CellType;
        TempExcelBuffer.Insert();
    end;

    local procedure GetDimFilterCaption(DimFilterNo: Integer): Text[80]
    var
        Dimension: Record Dimension;
    begin
        if AccSchedName."Analysis View Name" = '' then
            case DimFilterNo of
                1:
                    Dimension.Get(GLSetup."Global Dimension 1 Code");
                2:
                    Dimension.Get(GLSetup."Global Dimension 2 Code");
            end
        else
            case DimFilterNo of
                1:
                    Dimension.Get(AnalysisView."Dimension 1 Code");
                2:
                    Dimension.Get(AnalysisView."Dimension 2 Code");
                3:
                    Dimension.Get(AnalysisView."Dimension 3 Code");
                4:
                    Dimension.Get(AnalysisView."Dimension 4 Code");
            end;
        exit(CopyStr(Dimension.GetMLFilterCaption(GlobalLanguage), 1, 80));
    end;

    /// <summary>
    /// SetUpdateExistingWorksheet.
    /// </summary>
    /// <param name="UpdateExistingWorksheet">Boolean.</param>
    procedure SetUpdateExistingWorksheet(UpdateExistingWorksheet: Boolean)
    begin
        DoUpdateExistingWorksheet := UpdateExistingWorksheet;
    end;

    /// <summary>
    /// SetFileNameSilent.
    /// </summary>
    /// <param name="NewFileName">Text.</param>
    procedure SetFileNameSilent(NewFileName: Text)
    begin
        ServerFileName := NewFileName;
    end;

    /// <summary>
    /// SetTestMode.
    /// </summary>
    /// <param name="NewTestMode">Boolean.</param>
    procedure SetTestMode(NewTestMode: Boolean)
    begin
        TestMode := NewTestMode;
    end;

    local procedure UploadClientFile(var ClientFileName: Text; var ServerFileName: Text): Boolean
    begin
        ServerFileName := FileMgt.UploadFile(Text002, ExcelFileExtensionTok);
        ClientFileName := FileMgt.GetFileName(ServerFileName);
        if ServerFileName = '' then
            exit(false);

        SheetName := TempExcelBuffer.SelectSheetsName(ServerFileName);
        if SheetName = '' then
            exit(false);

        exit(true);
    end;

    local procedure DevuelveLetra(Columna: Integer): Text
    var
        xlColID: array[10] of Text;
        x: Integer;
        i: Integer;
        c: Char;
    begin

        Clear(xlColID);// := '';
        if Columna <> 0 THEN BEGIN
            x := Columna - 1;
            c := 65 + x MOD 26;
            xlColID[10] := c;
            i := 10;
            WHILE x > 25 DO BEGIN
                x := x DIV 26;
                i := i - 1;
                c := 64 + x MOD 26;
                xlColID[i] := c;
            END;
            FOR x := i TO 10 DO
                xlColID[1 + x - i] := xlColID[x];
        END;
        EXIT(xlColID[i]);

    end;

    local procedure EnterCellFormula(RowNo: Integer; ColumnNo: Integer; Formula: Text; Bold: Boolean; Italic: Boolean; Underline: Boolean)
    begin

        TempExcelBuffer.INIT;
        TempExcelBuffer.VALIDATE("Row No.", RowNo);
        TempExcelBuffer.VALIDATE("Column No.", ColumnNo);
        TempExcelBuffer.SetFormula := Formula;
        TempExcelBuffer.Bold := Bold;
        TempExcelBuffer.Italic := Italic;
        TempExcelBuffer.Underline := UnderLine;
        TempExcelBuffer.INSERT;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCalcColumnValue(var UseAmtsInAddCurr: Boolean; var ColumnLayout: Record "Column Layout")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAferCalcColumnValue(var UseAmtsInAddCurr: Boolean; var ColumnLayout: Record "Column Layout")
    begin
    end;
}