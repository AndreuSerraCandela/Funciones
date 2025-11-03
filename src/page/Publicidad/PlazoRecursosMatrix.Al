/// <summary>
/// Page Plazos recursos Matrix (ID 50023).
/// </summary>
page 50023 "Plazos recursos Matrix"
{
    PageType = ListPart;
    SourceTable = Resource;
    SourceTableView = SORTING("No.");

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field("No."; Rec."No.")
                {
                    StyleExpr = "Seleccionado";
                    ApplicationArea = All;
                    ToolTip = 'Specifies the number of the involved entry or record, according to the specified number series.';
                }
                field(Nombre; Rec.Name)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies a description of the resource.';
                    StyleExpr = EstaEnlistadeEspera;
                }
                field("Fecha baja"; Rec."Fecha baja")
                {
                    ApplicationArea = All;
                }
                // field(Emplazamiento; Rec.Emplazamiento)
                // {
                //     ApplicationArea = All;
                //     Visible = false;
                // }
                field(Medidas; Rec.Medidas)
                {
                    ApplicationArea = All;
                    Visible = true;
                }
                field("Dimensión Zona"; Rec."Dimensión Zona")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Nombre Zona"; DescZona(Rec."Dimensión Zona"))
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field(Zona; Rec.Zona)
                {
                    ApplicationArea = All;
                    Visible = true;
                }
                field("Name 2"; Rec."Name 2")
                {
                    ApplicationArea = All;
                    Visible = true;
                }
                field("No. Orden"; Rec."No. Orden")
                {
                    ApplicationArea = All;
                    Visible = true;
                }
                field("Resource Group No."; Rec."Resource Group No.")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Tipo Montaje"; Rec."Tipo Montaje")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field(Orientación; Rec.Orientación)
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field(Municipio; Rec.Municipio)
                {
                    ApplicationArea = All;
                    Visible = true;
                }
                field("Código Postal"; Rec."C.P. Municipio")
                {
                    ApplicationArea = All;
                }

                field(Field1; MATRIX_CellData[1])
                {
                    ApplicationArea = All;
                    CaptionClass = '3,' + MATRIX_ColumnCaption[1];
                    StyleExpr = Color1;
                    trigger OnDrillDown()
                    begin
                        MatrixOnDrillDown(1)
                    end;

                    trigger OnValidate()
                    begin
                        //  ValidateCapacity(1);
                    end;
                }
                field(Field2; MATRIX_CellData[2])
                {
                    ApplicationArea = All;
                    CaptionClass = '3,' + MATRIX_ColumnCaption[2];
                    StyleExpr = Color2;
                    trigger OnDrillDown()
                    begin
                        MatrixOnDrillDown(2)
                    end;

                    trigger OnValidate()
                    begin
                        //ValidateCapacity(2);
                    end;
                }
                field(Field3; MATRIX_CellData[3])
                {
                    ApplicationArea = All;
                    CaptionClass = '3,' + MATRIX_ColumnCaption[3];
                    StyleExpr = Color3;
                    trigger OnDrillDown()
                    begin
                        MatrixOnDrillDown(3)
                    end;

                    trigger OnValidate()
                    begin
                        //ValidateCapacity(3);
                    end;
                }
                field(Field4; MATRIX_CellData[4])
                {
                    ApplicationArea = All;
                    CaptionClass = '3,' + MATRIX_ColumnCaption[4];
                    StyleExpr = Color4;
                    trigger OnDrillDown()
                    begin
                        MatrixOnDrillDown(4)
                    end;

                    trigger OnValidate()
                    begin
                        //ValidateCapacity(4);
                    end;
                }
                field(Field5; MATRIX_CellData[5])
                {
                    ApplicationArea = All;
                    CaptionClass = '3,' + MATRIX_ColumnCaption[5];
                    StyleExpr = Color5;
                    trigger OnDrillDown()
                    begin
                        MatrixOnDrillDown(5)
                    end;

                    trigger OnValidate()
                    begin
                        //ValidateCapacity(5);
                    end;
                }
                field(Field6; MATRIX_CellData[6])
                {
                    ApplicationArea = All;
                    CaptionClass = '3,' + MATRIX_ColumnCaption[6];
                    StyleExpr = Color6;
                    trigger OnDrillDown()
                    begin
                        MatrixOnDrillDown(6)
                    end;

                    trigger OnValidate()
                    begin
                        //ValidateCapacity(6);
                    end;
                }
                field(Field7; MATRIX_CellData[7])
                {
                    ApplicationArea = All;
                    CaptionClass = '3,' + MATRIX_ColumnCaption[7];
                    StyleExpr = Color7;
                    trigger OnDrillDown()
                    begin
                        MatrixOnDrillDown(7)
                    end;

                    trigger OnValidate()
                    begin
                        //ValidateCapacity(7);
                    end;
                }
                field(Field8; MATRIX_CellData[8])
                {
                    ApplicationArea = All;
                    CaptionClass = '3,' + MATRIX_ColumnCaption[8];
                    StyleExpr = Color8;
                    trigger OnDrillDown()
                    begin
                        MatrixOnDrillDown(8)
                    end;

                    trigger OnValidate()
                    begin
                        //ValidateCapacity(8);
                    end;
                }
                field(Field9; MATRIX_CellData[9])
                {
                    ApplicationArea = All;
                    CaptionClass = '3,' + MATRIX_ColumnCaption[9];
                    StyleExpr = Color9;
                    trigger OnDrillDown()
                    begin
                        MatrixOnDrillDown(9)
                    end;

                    trigger OnValidate()
                    begin
                        //ValidateCapacity(9);
                    end;
                }
                field(Field10; MATRIX_CellData[10])
                {
                    ApplicationArea = All;
                    CaptionClass = '3,' + MATRIX_ColumnCaption[10];
                    StyleExpr = Color10;
                    trigger OnDrillDown()
                    begin
                        MatrixOnDrillDown(10)
                    end;

                    trigger OnValidate()
                    begin
                        //ValidateCapacity(10);
                    end;
                }
                field(Field11; MATRIX_CellData[11])
                {
                    ApplicationArea = All;
                    CaptionClass = '3,' + MATRIX_ColumnCaption[11];
                    StyleExpr = Color11;
                    trigger OnDrillDown()
                    begin
                        MatrixOnDrillDown(11)
                    end;

                    trigger OnValidate()
                    begin
                        //ValidateCapacity(11);
                    end;
                }
                field(Field12; MATRIX_CellData[12])
                {
                    ApplicationArea = All;
                    CaptionClass = '3,' + MATRIX_ColumnCaption[12];
                    StyleExpr = Color12;
                    trigger OnDrillDown()
                    begin
                        MatrixOnDrillDown(12)
                    end;

                    trigger OnValidate()
                    begin
                        // ValidateCapacity(12);
                    end;
                }
                field(Field13; MATRIX_CellData[13])
                {
                    ApplicationArea = All;
                    CaptionClass = '3,' + MATRIX_ColumnCaption[13];
                    StyleExpr = Color13;
                    trigger OnDrillDown()
                    begin
                        MatrixOnDrillDown(13)
                    end;

                    trigger OnValidate()
                    begin
                        // ValidateCapacity(13);
                    end;
                }
                field(Field14; MATRIX_CellData[14])
                {
                    ApplicationArea = All;
                    CaptionClass = '3,' + MATRIX_ColumnCaption[14];
                    StyleExpr = Color14;
                    trigger OnDrillDown()
                    begin
                        MatrixOnDrillDown(14)
                    end;

                    trigger OnValidate()
                    begin
                        // ValidateCapacity(14);
                    end;
                }
                field(Field15; MATRIX_CellData[15])
                {
                    ApplicationArea = All;
                    CaptionClass = '3,' + MATRIX_ColumnCaption[15];
                    StyleExpr = Color15;
                    trigger OnDrillDown()
                    begin
                        MatrixOnDrillDown(15)
                    end;

                    trigger OnValidate()
                    begin
                        // ValidateCapacity(15);
                    end;
                }
                field(Field16; MATRIX_CellData[16])
                {
                    ApplicationArea = All;
                    CaptionClass = '3,' + MATRIX_ColumnCaption[16];
                    StyleExpr = Color16;
                    trigger OnDrillDown()
                    begin
                        MatrixOnDrillDown(16)
                    end;

                    trigger OnValidate()
                    begin
                        // ValidateCapacity(16);
                    end;
                }
                field(Field17; MATRIX_CellData[17])
                {
                    ApplicationArea = All;
                    CaptionClass = '3,' + MATRIX_ColumnCaption[17];
                    StyleExpr = Color17;
                    trigger OnDrillDown()
                    begin
                        MatrixOnDrillDown(17)
                    end;

                    trigger OnValidate()
                    begin
                        // ValidateCapacity(17);
                    end;
                }
                field(Field18; MATRIX_CellData[18])
                {
                    ApplicationArea = All;
                    CaptionClass = '3,' + MATRIX_ColumnCaption[18];
                    StyleExpr = Color18;
                    trigger OnDrillDown()
                    begin
                        MatrixOnDrillDown(18)
                    end;

                    trigger OnValidate()
                    begin
                        // ValidateCapacity(18);
                    end;
                }
                field(Field19; MATRIX_CellData[19])
                {
                    ApplicationArea = All;
                    CaptionClass = '3,' + MATRIX_ColumnCaption[19];
                    StyleExpr = Color19;
                    trigger OnDrillDown()
                    begin
                        MatrixOnDrillDown(19)
                    end;

                    trigger OnValidate()
                    begin
                        // ValidateCapacity(19);
                    end;
                }
                field(Field20; MATRIX_CellData[20])
                {
                    ApplicationArea = All;
                    CaptionClass = '3,' + MATRIX_ColumnCaption[20];
                    StyleExpr = Color20;
                    trigger OnDrillDown()
                    begin
                        MatrixOnDrillDown(20)
                    end;

                    trigger OnValidate()
                    begin
                        //ValidateCapacity(22);
                    end;
                }
                field(Field21; MATRIX_CellData[21])
                {
                    ApplicationArea = All;
                    CaptionClass = '3,' + MATRIX_ColumnCaption[21];
                    StyleExpr = Color21;
                    trigger OnDrillDown()
                    begin
                        MatrixOnDrillDown(21)
                    end;

                    trigger OnValidate()
                    begin
                        //ValidateCapacity(22);
                    end;
                }
                field(Field22; MATRIX_CellData[22])
                {
                    ApplicationArea = All;
                    CaptionClass = '3,' + MATRIX_ColumnCaption[22];
                    StyleExpr = Color22;
                    trigger OnDrillDown()
                    begin
                        MatrixOnDrillDown(22)
                    end;

                    trigger OnValidate()
                    begin
                        // ValidateCapacity(22);
                    end;
                }
                field(Field23; MATRIX_CellData[23])
                {
                    ApplicationArea = All;
                    CaptionClass = '3,' + MATRIX_ColumnCaption[23];
                    StyleExpr = Color23;
                    trigger OnDrillDown()
                    begin
                        MatrixOnDrillDown(23)
                    end;

                    trigger OnValidate()
                    begin
                        // ValidateCapacity(23);
                    end;
                }
                field(Field24; MATRIX_CellData[24])
                {
                    ApplicationArea = All;
                    CaptionClass = '3,' + MATRIX_ColumnCaption[24];
                    StyleExpr = Color24;
                    trigger OnDrillDown()
                    begin
                        MatrixOnDrillDown(24)
                    end;

                    trigger OnValidate()
                    begin
                        // ValidateCapacity(24);
                    end;
                }
                field(Field25; MATRIX_CellData[25])
                {
                    ApplicationArea = All;
                    CaptionClass = '3,' + MATRIX_ColumnCaption[25];
                    StyleExpr = Color25;
                    trigger OnDrillDown()
                    begin
                        MatrixOnDrillDown(25)
                    end;

                    trigger OnValidate()
                    begin
                        // ValidateCapacity(25);
                    end;
                }
                field(Field26; MATRIX_CellData[26])
                {
                    ApplicationArea = All;
                    CaptionClass = '3,' + MATRIX_ColumnCaption[26];
                    StyleExpr = Color26;
                    trigger OnDrillDown()
                    begin
                        MatrixOnDrillDown(26)
                    end;

                    trigger OnValidate()
                    begin
                        // ValidateCapacity(26);
                    end;
                }
                field(Field27; MATRIX_CellData[27])
                {
                    ApplicationArea = All;
                    CaptionClass = '3,' + MATRIX_ColumnCaption[27];
                    StyleExpr = Color27;
                    trigger OnDrillDown()
                    begin
                        MatrixOnDrillDown(27)
                    end;

                    trigger OnValidate()
                    begin
                        // ValidateCapacity(27);
                    end;
                }
                field(Field28; MATRIX_CellData[28])
                {
                    ApplicationArea = All;
                    CaptionClass = '3,' + MATRIX_ColumnCaption[28];
                    StyleExpr = Color28;
                    trigger OnDrillDown()
                    begin
                        MatrixOnDrillDown(28)
                    end;

                    trigger OnValidate()
                    begin
                        // ValidateCapacity(28);
                    end;
                }
                field(Field29; MATRIX_CellData[29])
                {
                    ApplicationArea = All;
                    CaptionClass = '3,' + MATRIX_ColumnCaption[29];
                    StyleExpr = Color29;
                    trigger OnDrillDown()
                    begin
                        MatrixOnDrillDown(29)
                    end;

                    trigger OnValidate()
                    begin
                        // ValidateCapacity(29);
                    end;
                }
                field(Field30; MATRIX_CellData[30])
                {
                    ApplicationArea = All;
                    CaptionClass = '3,' + MATRIX_ColumnCaption[30];
                    StyleExpr = Color30;
                    trigger OnDrillDown()
                    begin
                        MatrixOnDrillDown(30)
                    end;

                    trigger OnValidate()
                    begin
                        // ValidateCapacity(30);
                    end;
                }
                field(Field31; MATRIX_CellData[31])
                {
                    ApplicationArea = All;
                    CaptionClass = '3,' + MATRIX_ColumnCaption[31];
                    StyleExpr = Color31;
                    trigger OnDrillDown()
                    begin
                        MatrixOnDrillDown(31)
                    end;

                    trigger OnValidate()
                    begin
                        // ValidateCapacity(31);
                    end;
                }
                field(Field32; MATRIX_CellData[32])
                {
                    ApplicationArea = All;
                    CaptionClass = '3,' + MATRIX_ColumnCaption[32];
                    StyleExpr = Color32;
                    trigger OnDrillDown()
                    begin
                        MatrixOnDrillDown(32)
                    end;

                    trigger OnValidate()
                    begin
                        // ValidateCapacity(32);
                    end;
                }
            }

        }

    }
    actions
    {
        area(Processing)
        {
            group(Planificación)
            {
                action("Ver Ficha Reserva")
                {
                    Caption = '&Ver Reserva';
                    ApplicationArea = ALL;
                    RunObject = Page "Tabla Reservas";
                    RunPageView = SORTING("Nº Reserva");
                    RunPageLink = "Nº Recurso" = FIELD("No.");
                }
                action("Añadir a Lista Fijacion")
                {
                    Image = AdjustEntries;
                    ApplicationArea = All;
                    Scope = Repeater;
                    trigger OnAction()
                    var
                        Res: Record Resource;

                    begin
                        CurrPage.SetSelectionFilter(Res);
                        if Res.FindFirst()
                        then
                            repeat
                                Recurso := Rec;
                                Recurso."Employment Date" := InicioReserva;
                                Recurso."Last Date Modified" := FinReserva;
                                if Recurso.Insert() Then;
                            until Res.Next() = 0;
                    end;
                }
                action("Asignación recursos")
                {
                    Caption = '&Asignación recursos';
                    ApplicationArea = ALL;
                    RunObject = Page 221;
                    //RunPageLinkType =OnUpdate;
                    RunPageLink = "Resource Filter" = FIELD("No.");
                }
                action("Disponibilidad recurso")
                {
                    Caption = 'Disponibilidad recurso';
                    RunObject = Page 225;
                    ApplicationArea = ALL;
                    //RunPageLinkType =OnUpdate;
                    RunPageLink = "No." = FIELD("No."),
                                "Unit of Measure Filter" = FIELD("Base Unit of Measure"),
                                "Chargeable Filter" = FIELD("Chargeable Filter");
                }
                action("Presupuesto Proyecto")
                {
                    Caption = 'Presupuesto proyecto';
                    RunObject = Page "Job Planning Lines";
                    ApplicationArea = ALL;
                }
            }
            group(Precios)
            {
                action(Costes)
                {
                    Caption = 'Costes';
                    ApplicationArea = ALL;
                    trigger OnAction()
                    var
                        AmountType: Enum "Price Amount Type";
                        PriceType: Enum "Price Type";
                    begin
                        Rec.ShowPriceListLines(PriceType::Purchase, AmountType::Any);
                    end;
                }
                action("Precios Recurso")
                {
                    Caption = 'Precios';
                    ApplicationArea = ALL;
                    trigger OnAction()
                    var
                        AmountType: Enum "Price Amount Type";
                        PriceType: Enum "Price Type";
                    begin
                        Rec.ShowPriceListLines(PriceType::Sale, AmountType::Any);
                    end;
                }
            }
            group(Recurso)
            {
                action(Lista)
                {
                    //LookupTable;
                    ApplicationArea = ALL;
                    ShortCutKey = F5;
                    Caption = 'Lista';
                    trigger OnAction()
                    var
                        Resource: Record Resource;
                    begin
                        Resource.SetRange(Hoy, Today);
                        resource.SetRange(Bloqueado, FALSE);
                        Page.Runmodal(0, Resource);
                    end;
                }
                action(Ficha)
                {
                    //PushAction=RunObject;
                    ApplicationArea = ALL;
                    ShortCutKey = 'Mayús+F5';
                    Caption = 'Ficha';
                    RunObject = Page 76;
                    //RunPageLinkType =OnUpdate;
                    RunPageLink = "No." = FIELD("No."),
                                "Date Filter" = FIELD("Date Filter"),
                                "Base Unit of Measure" = FIELD("Base Unit of Measure"),
                                "Chargeable Filter" = FIELD("Chargeable Filter");
                }
                action(Estadísticas)
                {
                    //PushAction=RunObject;
                    ShortCutKey = F9;
                    Caption = 'Estadísticas';
                    ApplicationArea = ALL;
                    RunObject = Page 223;
                    RunPageLink = "No." = Field("No."),
                                "Date Filter" = FIELD("Date Filter"),
                                "Unit of Measure Filter" = FIELD("Base Unit of Measure"),
                                "Chargeable Filter" = FIELD("Chargeable Filter");
                }
                action(Comentarios)
                {
                    //PushAction=RunObject;
                    Caption = 'C&omentarios';
                    RunObject = Page "Comment Sheet";
                    ApplicationArea = ALL;
                    //RunPageLinkType =OnUpdate;
                    RunPageLink = "Table Name" = CONST(Resource),
                                "No." = Field("No.");
                }
                action(Movimientos)
                {
                    //PushAction=RunObject;
                    ShortCutKey = 'Ctrl+F5';
                    Caption = 'Movimientos';
                    ApplicationArea = ALL;
                    RunObject = Page 202;
                    //RunPageLinkType =OnUpdate;
                    RunPageView = SORTING("Resource No.", "Posting Date");
                    RunPageLink = "Resource No." = Field("No.");
                }
                action("Ver Reserva")
                {
                    ShortCutKey = F6;
                    Caption = 'Ver &Reserva';
                    ApplicationArea = ALL;
                    trigger OnAction()
                    BEGIN
                        rReserva2.SETCURRENTKEY("Nº Recurso", "Fecha inicio", "Fecha fin");
                        rReserva2.SETRANGE("Nº Recurso", Rec."No.");
                        rReserva2.SETFILTER("Fecha inicio", '>=%1', MatrixRecords[MATRIX_CurrentColumnOrdinal]."Period Start");
                        Page.RUNMODAL(Page::"Tabla Reservas", rReserva2);
                    END;
                }
            }
        }
    }

    VAR
        GestionPagePeriodo: Codeunit PeriodPageManagement;
        Fecha: Record Date;
        TipoPeriodo: Enum "Analysis Period Type";//Option Día,Semana,Mes;
        rReserva: Record Reserva;
        rReserva2: Record Reserva;
        rDia: Record "Diario Reserva";
        rProy: Record 167;
        rRecurs: Record 156;
        Nom: Text[100];
        Familia: Code[20];
        Tipus: Code[10];
        Color1: Text;
        Color2: Text;
        Color3: Text;
        Color4: Text;
        Color5: Text;
        Color6: Text;
        Color7: Text;
        Color8: Text;
        Color9: Text;
        Color10: Text;
        Color11: Text;
        Color12: Text;
        Color13: Text;
        Color14: Text;
        Color15: Text;
        Color16: Text;
        Color17: Text;
        Color18: Text;
        Color19: Text;
        Color20: Text;
        Color21: Text;
        Color22: Text;
        Color23: Text;
        Color24: Text;
        Color25: Text;
        Color26: Text;
        Color27: Text;
        Color28: Text;
        Color29: Text;
        Color30: Text;
        Color31: Text;
        Color32: Text;
        Contrato: Enum "Filtro Estado Contrato";
        EstaEnlistadeEspera: Text;
        Fzona: Code[20];
        MATRIX_CellData: array[32] of Text;
        MatrixRecords: ARRAY[32] OF Record 2000000007;
        MATRIX_NoOfMatrixColumns: Integer;
        MATRIX_ColumnCaption: ARRAY[32] of Text[1024];
        Recurso: Record Resource temporary;
        InicioReserva: Date;
        FinReserva: Date;
        "Seleccionado": Code[20];
        MATRIX_CurrentColumnOrdinal: Integer;

    trigger OnAfterGetRecord()
    var

    begin
        MATRIX_CurrentColumnOrdinal := 0;
        WHILE MATRIX_CurrentColumnOrdinal < MATRIX_NoOfMatrixColumns DO BEGIN
            MATRIX_CurrentColumnOrdinal := MATRIX_CurrentColumnOrdinal + 1;
            MATRIX_OnAfterGetRecord(MATRIX_CurrentColumnOrdinal);
        END;
        //Seleccionado en rojo si existwe recurso con el mismo No.

        if Recurso.GET(Rec."No.") THEN
            Seleccionado := 'Unfavorable'
        ELSE
            Seleccionado := 'Standard';

    end;

    /// <summary>
    /// MATRIX_OnAfterGetRecord.
    /// </summary>
    /// <param name="ColumnID">Integer.</param>
    procedure MATRIX_OnAfterGetRecord(ColumnID: Integer)
    begin
        MATRIX_CellData[ColumnID] := Trae_nombre(MatrixRecords[ColumnID]."Period Start", MatrixRecords[ColumnID]."Period End", ColumnID);
    end;

    LOCAL PROCEDURE AsigFiltFecha();
    BEGIN
    END;
    /// <summary>
    /// Fechas.
    /// </summary>
    /// <param name="pInicio">Date.</param>
    /// <param name="pFin">Date.</param>
    procedure Fechas(pInicio: Date; pFin: Date);
    begin
        InicioReserva := pInicio;
        FinReserva := pFin;
    end;
    /// <summary>
    /// Recurso.
    /// </summary>
    /// <param name="pRecurso">VAR Record Resource.</param>
    procedure Recursos(var pRecurso: Record Resource temporary);
    begin
        if Recurso.FindFirst() Then
            Repeat
                pRecurso := Recurso;
                if pRecurso.Insert() Then;
            until Recurso.Next() = 0;

    end;
    //procedure para añadir un Recurso a la variable temporal de Recurso
    /// <summary>
    /// Recurso.
    /// </summary>
    /// <param name="pRecurso">VAR Record Resource.</param>
    /// 
    /// <returns>Boolean.</returns>
    ///     
    /// <remarks>Devuelve true si se ha añadido correctamente.</remarks>
    procedure IncorporaRecurso(pRecurso: Code[20]): Boolean;
    var
        Res: Record Resource;
    begin
        if not Res.GET(pRecurso) Then
            exit(false);
        Recurso := Res;
        if Recurso.Insert() Then
            exit(true)
        else
            exit(false);
    end;

    PROCEDURE Trae_nombre(Desde: Date; Hasta: Date; ColumnID: Integer): Text;
    var
        Dias: Integer;
        Nombre: Text;
        StandarText: Record "Standard Text" temporary;
        Contratos: Record "Sales Header";
        LinstaEspera: Record "Diario Incidencias Rescursos";
        CabeceraEspera: Record "Incidencias Rescursos";
    BEGIN
        if Lunes Then begin
            Desde := DWY2Date(1, Date2DWY(Desde, 2), Date2DWY(Desde, 3));
            Hasta := CalcDate('6D', Desde);
        end;
        if Martes Then begin
            Desde := DWY2Date(2, Date2DWY(Desde, 2), Date2DWY(Desde, 3));
            Hasta := CalcDate('6D', Desde);
        end;
        if Miercoles Then begin
            Desde := DWY2Date(3, Date2DWY(Desde, 2), Date2DWY(Desde, 3));
            Hasta := CalcDate('6D', Desde);
        end;
        if Jueves Then begin
            Desde := DWY2Date(4, Date2DWY(Desde, 2), Date2DWY(Desde, 3));
            Hasta := CalcDate('6D', Desde);
        end;
        if Viernes Then begin
            Desde := DWY2Date(5, Date2DWY(Desde, 2), Date2DWY(Desde, 3));
            Hasta := CalcDate('6D', Desde);
        end;
        if Sabado Then begin
            Desde := DWY2Date(6, Date2DWY(Desde, 2), Date2DWY(Desde, 3));
            Hasta := CalcDate('6D', Desde);
        end;
        if Domingo Then begin
            Desde := DWY2Date(7, Date2DWY(Desde, 2), Date2DWY(Desde, 3));
            Hasta := CalcDate('6D', Desde);
        end;
        Case ColumnId Of
            1:
                Color1 := '';
            2:
                Color2 := '';
            3:
                Color3 := '';
            4:
                Color4 := '';
            5:
                Color5 := '';
            6:
                Color6 := '';
            7:
                Color7 := '';
            8:
                Color8 := '';
            9:
                Color9 := '';
            10:
                Color10 := '';
            11:
                Color11 := '';
            12:
                Color12 := '';
            13:
                Color13 := '';
            14:
                Color14 := '';
            15:
                Color15 := '';
            16:
                Color16 := '';
            17:
                Color17 := '';
            18:
                Color18 := '';
            19:
                Color19 := '';
            20:
                Color20 := '';
            21:
                Color21 := '';
            22:
                Color22 := '';
            23:
                Color23 := '';
            24:
                Color24 := '';
            25:
                Color25 := '';
            26:
                Color26 := '';
            27:
                Color27 := '';
            28:
                Color28 := '';
            29:
                Color29 := '';
            30:
                Color30 := '';
            31:
                Color31 := '';
            32:
                Color32 := '';

        End;

        rReserva.RESET;
        CLEAR(rDia);
        LinstaEspera.RESET;
        LinstaEspera.SetRange("Nº Recurso", Rec."No.");
        LinstaEspera.SetRange(Motivo, LinstaEspera.Motivo::"Lista de Espera");

        if LinstaEspera.FindSET() Then begin
            If Not CabeceraEspera.Get(LinstaEspera."Nº Incidencia") Then begin
                CabeceraEspera.Init();
                CabeceraEspera.Orden := 99
            end;
            If CabeceraEspera.Orden < 99 then
                EstaEnlistadeEspera := 'StrongAccent'
            else
                EstaEnlistadeEspera := 'Standard';
        end else
            EstaEnlistadeEspera := 'Standard';
        rDia.SETCURRENTKEY(rDia."Nº Recurso", rDia.Fecha);
        rDia.SETRANGE("Nº Recurso", Rec."No.");
        rDia.SETRANGE(Fecha, Desde,
                             Hasta);
        if Contrato <> Contrato::Todos then begin
            if rDia.FindFirst() Then
                repeat
                    Contratos.SetRange("Nº Proyecto", rDia."Nº Proyecto");
                    if not Contratos.FindFirst() Then Contratos.Init();
                    case Contrato of
                        Contrato::Anulado:
                            if Contratos."Estado Contrato" = Contratos."Estado Contrato"::Anulado Then
                                rDia.Mark(True);
                        Contrato::Modificado:
                            if Contratos."Estado Contrato" = Contratos."Estado Contrato"::Modificado Then
                                rDia.Mark(True);
                        Contrato::Cancelado:
                            if Contratos."Estado Contrato" = Contratos."Estado Contrato"::Cancelado Then
                                rDia.Mark(True);
                        Contrato::"Con Contrato":
                            if Contratos."Estado Contrato" in [Contratos."Estado Contrato"::Firmado, Contratos."Estado Contrato"::"Pendiente de Firma", Contratos."Estado Contrato"::"Sin Montar"] Then
                                rDia.Mark(True);
                        Contrato::Firmado:
                            if Contratos."Estado Contrato" = Contratos."Estado Contrato"::Firmado Then
                                rDia.Mark(True);
                        Contrato::"Pendiente de Firma":
                            if Contratos."Estado Contrato" = Contratos."Estado Contrato"::"Pendiente de Firma" Then
                                rDia.Mark(True);
                        Contrato::"Sin Contrato":
                            if Contratos."No." <> '' Then
                                rDia.Mark(True);
                        Contrato::"Sin Montar":
                            if Contratos."Estado Contrato" = Contratos."Estado Contrato"::"Sin Montar" Then
                                rDia.Mark(True);
                    end;
                until rDia.Next() = 0;
            rDia.MarkedOnly(true);
        end;

        if rDia.FIND('-') THEN Begin
            Repeat
                if Not rProy.GET(rDia."Nº Proyecto") Then rProy.Init();

                // CASE rDia.Estado OF
                //     rDia.Estado::Reservado:
                //         Color := 'Favorable';
                //     rDia.Estado::"Reservado fijo":
                //         Color := 'Ambiguous';
                //     rDia.Estado::Ocupado:
                //         Color := 'Strong';
                //     rDia.Estado::"Ocupado fijo":
                //         Color := 'Subordinate';
                // END;
                StandarText.SetRange(Code, rProy."No.");
                if not StandarText.FindFirst() Then begin
                    StandarText.Init();
                    StandarText.Code := rProy."No.";
                    StandarText.Insert();
                    if Nombre = '' Then
                        Nombre := rProy.Description
                    else begin
                        Nombre := Nombre + '###' + rProy.Description;
                        Case ColumnId Of
                            1:
                                Color1 := 'UnFavorable';
                            2:
                                Color2 := 'UnFavorable';
                            3:
                                Color3 := 'UnFavorable';
                            4:
                                Color4 := 'UnFavorable';
                            5:
                                Color5 := 'UnFavorable';
                            6:
                                Color6 := 'UnFavorable';
                            7:
                                Color7 := 'UnFavorable';
                            8:
                                Color8 := 'UnFavorable';
                            9:
                                Color9 := 'UnFavorable';
                            10:
                                Color10 := 'UnFavorable';
                            11:
                                Color11 := 'UnFavorable';
                            12:
                                Color12 := 'UnFavorable';
                            13:
                                Color13 := 'UnFavorable';
                            14:
                                Color14 := 'UnFavorable';
                            15:
                                Color15 := 'UnFavorable';
                            16:
                                Color16 := 'UnFavorable';
                            17:
                                Color17 := 'UnFavorable';
                            18:
                                Color18 := 'UnFavorable';
                            19:
                                Color19 := 'UnFavorable';
                            20:
                                Color20 := 'UnFavorable';
                            21:
                                Color21 := 'UnFavorable';
                            22:
                                Color22 := 'UnFavorable';
                            23:
                                Color23 := 'UnFavorable';
                            24:
                                Color24 := 'UnFavorable';
                            25:
                                Color25 := 'UnFavorable';
                            26:
                                Color26 := 'UnFavorable';
                            27:
                                Color27 := 'UnFavorable';
                            28:
                                Color28 := 'UnFavorable';
                            29:
                                Color29 := 'UnFavorable';
                            30:
                                Color30 := 'UnFavorable';
                            31:
                                Color31 := 'UnFavorable';
                            32:
                                Color32 := 'UnFavorable';

                        End;
                    end;
                end;
            until rDia.Next() = 0;
            If EstaEnlistadeEspera = 'StrongAccent' Then begin
                Case ColumnId Of
                    1:
                        Color1 := 'StrongAccent';
                    2:
                        Color2 := 'StrongAccent';
                    3:
                        Color3 := 'StrongAccent';
                    4:
                        Color4 := 'StrongAccent';
                    5:
                        Color5 := 'StrongAccent';
                    6:
                        Color6 := 'StrongAccent';
                    7:
                        Color7 := 'StrongAccent';
                    8:
                        Color8 := 'StrongAccent';
                    9:
                        Color9 := 'StrongAccent';
                    10:
                        Color10 := 'StrongAccent';
                    11:
                        Color11 := 'StrongAccent';
                    12:
                        Color12 := 'StrongAccent';
                    13:
                        Color13 := 'StrongAccent';
                    14:
                        Color14 := 'StrongAccent';
                    15:
                        Color15 := 'StrongAccent';
                    16:
                        Color16 := 'StrongAccent';
                    17:
                        Color17 := 'StrongAccent';
                    18:
                        Color18 := 'StrongAccent';
                    19:
                        Color19 := 'StrongAccent';
                    20:
                        Color20 := 'StrongAccent';
                    21:
                        Color21 := 'StrongAccent';
                    22:
                        Color22 := 'StrongAccent';
                    23:
                        Color23 := 'StrongAccent';
                    24:
                        Color24 := 'StrongAccent';
                    25:
                        Color25 := 'StrongAccent';
                    26:
                        Color26 := 'StrongAccent';
                    27:
                        Color27 := 'StrongAccent';
                    28:
                        Color28 := 'StrongAccent';
                    29:
                        Color29 := 'StrongAccent';
                    30:
                        Color30 := 'StrongAccent';
                    31:
                        Color31 := 'StrongAccent';
                    32:
                        Color32 := 'StrongAccent';

                End;
            end;
            EXIT(Nombre);
        END;
        //ELSE
        //  EXIT('');
    END;

    PROCEDURE Coge_Recurso(VAR rRec: Record 156);
    BEGIN
        rRecurs := rRec;
    END;

    PROCEDURE DescZona(zcode: Code[20]): Text[50];
    VAR
        rdim: Record 349;
    BEGIN
        if rdim.GET('ZONA', zcode) THEN EXIT(rdim.Name);
    END;

    Procedure Load(PeriodType: Enum "Analysis Period Type"; MatrixColumns1: ARRAY[32] OF Text[1024];
    MatrixRecords1: ARRAY[32] OF Record 2000000007; NoOfMatrixColumns1: Integer
    ; Tipo: Text; fzona: Text; PFamilia: Text; pLunes: Boolean;
        pMartes: Boolean;
        pMiercoles: Boolean;
        pJueves: Boolean;
        pViernes: Boolean;
        pSabado: Boolean;
        pDomingo: Boolean; DZona: Text; PContrato: Enum "Filtro Estado Contrato"; pActivos: Boolean);
    var
        i: Integer;
    Begin
        Lunes := pLunes;
        Martes := pMartes;
        Miercoles := pMiercoles;
        Jueves := pJueves;
        Viernes := pViernes;
        Sabado := pSabado;
        Domingo := pDomingo;
        Contrato := PContrato;
        Rec.SetRange("Tipo Recurso");
        Rec.SetRange(Zona);
        Rec.SetRange("Resource Group No.");
        if Tipo <> '' Then
            Rec.SetFilter("Tipo Recurso", Tipo);
        if fzona <> '' Then
            Rec.SetFilter(Zona, fzona);
        if PFamilia <> '' Then
            Rec.SetFilter("Resource Group No.", PFamilia);
        TipoPeriodo := PeriodType;
        if DZona <> '' then
            Rec.SetFilter("Global Dimension 4 Code", DZona);
        COPYARRAY(MATRIX_ColumnCaption, MatrixColumns1, 1);
        FOR i := 1 TO ARRAYLEN(MatrixRecords) DO
            MatrixRecords[i].COPY(MatrixRecords1[i]);
        MATRIX_NoOfMatrixColumns := NoOfMatrixColumns1;
        If pActivos Then
            SoloReales();
        CurrPage.Update(false);
    End;

    /// <summary>
    /// MatrixOnDrillDown.
    /// </summary>
    /// <param name="i">Integer.</param>
    procedure MatrixOnDrillDown(i: Integer)
    begin
        DrilDown(MatrixRecords[i]."Period Start", MatrixRecords[i]."Period End");

    end;

    PROCEDURE DrilDown(Desde: Date; Hasta: Date)
    var
        Dias: Integer;
        Nombre: Text;
        Contratos: Record "Sales Header";
    Begin
        if Lunes Then begin
            Desde := DWY2Date(1, Date2DWY(Desde, 2), Date2DWY(Desde, 3));
            Hasta := CalcDate('6D', Desde);
        end;
        if Martes Then begin
            Desde := DWY2Date(2, Date2DWY(Desde, 2), Date2DWY(Desde, 3));
            Hasta := CalcDate('6D', Desde);
        end;
        if Miercoles Then begin
            Desde := DWY2Date(3, Date2DWY(Desde, 2), Date2DWY(Desde, 3));
            Hasta := CalcDate('6D', Desde);
        end;
        if Jueves Then begin
            Desde := DWY2Date(4, Date2DWY(Desde, 2), Date2DWY(Desde, 3));
            Hasta := CalcDate('6D', Desde);
        end;
        if Viernes Then begin
            Desde := DWY2Date(5, Date2DWY(Desde, 2), Date2DWY(Desde, 3));
            Hasta := CalcDate('6D', Desde);
        end;
        if Sabado Then begin
            Desde := DWY2Date(6, Date2DWY(Desde, 2), Date2DWY(Desde, 3));
            Hasta := CalcDate('6D', Desde);
        end;
        if Domingo Then begin
            Desde := DWY2Date(7, Date2DWY(Desde, 2), Date2DWY(Desde, 3));
            Hasta := CalcDate('6D', Desde);
        end;
        rReserva.RESET;
        CLEAR(rDia);
        rDia.SETCURRENTKEY("Nº Recurso", "Estado Contrato", Fecha);
        rDia.SETRANGE("Nº Recurso", Rec."No.");
        rDia.SETRANGE(Fecha, Desde,
                             Hasta);
        rDia.Setrange("Estado Contrato");
        if Contrato <> Contrato::Todos then begin
            //    if rDia.FindFirst() Then
            //      repeat
            // If Proyecto <> rDia."Nº Proyecto" Then begin
            //     Contratos.SetRange("Nº Proyecto", rDia."Nº Proyecto");
            //     if not Contratos.FindFirst() Then Contratos.Init();
            // end;
            // Proyecto := rDia."Nº Proyecto";
            case Contrato of
                Contrato::Anulado:
                    if Contratos."Estado Contrato" = Contratos."Estado Contrato"::Anulado Then
                        rDia.Setrange("Estado Contrato", rDia."Estado Contrato"::Anulado);//rDia.Mark(True);
                Contrato::Modificado:
                    if Contratos."Estado Contrato" = Contratos."Estado Contrato"::Modificado Then
                        rDia.Setrange("Estado Contrato", rDia."Estado Contrato"::Modificado);//rDia.Mark(True);
                Contrato::Cancelado:
                    if Contratos."Estado Contrato" = Contratos."Estado Contrato"::Cancelado Then
                        rDia.Setrange("Estado Contrato", rDia."Estado Contrato"::Cancelado);//rDia.Mark(True);
                Contrato::"Con Contrato":
                    if Contratos."Estado Contrato" in [Contratos."Estado Contrato"::Firmado, Contratos."Estado Contrato"::"Pendiente de Firma", Contratos."Estado Contrato"::"Sin Montar"] Then
                        rDia.Setfilter("Estado Contrato", '%1|%2|%3', rDia."Estado Contrato"::Firmado, rDia."Estado Contrato"::"Pendiente de Firma", rDia."Estado Contrato"::"Sin Montar");//rDia.Mark(True);
                Contrato::Firmado:
                    if Contratos."Estado Contrato" = Contratos."Estado Contrato"::Firmado Then
                        rDia.Setrange("Estado Contrato", rDia."Estado Contrato"::Firmado);//rDia.Mark(True);
                Contrato::"Pendiente de Firma":
                    if Contratos."Estado Contrato" = Contratos."Estado Contrato"::"Pendiente de Firma" Then
                        rDia.Setrange("Estado Contrato", rDia."Estado Contrato"::"Pendiente de Firma");//rDia.Mark(True);
                Contrato::"Sin Contrato":
                    rDia.Setrange("Contrato", '');//rDia.Mark(True);
                                                  // Contrato::"Con Contrato":
                                                  //     rDia.Setfilter("Contrato",'<>%1','');//rDia.Mark(True);
                Contrato::"Sin Montar":
                    if Contratos."Estado Contrato" = Contratos."Estado Contrato"::"Sin Montar" Then
                        rDia.Setrange("Estado Contrato", rDia."Estado Contrato"::"Sin Montar");//rDia.Mark(True);
            end;
            //until rDia.Next() = 0;
            //rDia.MarkedOnly(true);

        end;

        if rDia.FIND('-') THEN Begin
            Page.Runmodal(Page::"Diario Reserva", rDia);

        End;
    END;

    procedure SeleccionaColumnas(Var Columnas: Record "Standard Text" temporary)
    var
        i: Integer;
    begin
        for i := 1 to 32 do begin
            if MATRIX_ColumnCaption[i] <> '' then begin
                Columnas.Code := Format(i);
                Columnas.Description := Copystr(Matrix_ColumnCaption[i], 1, MaxStrLen(Columnas.Description));
                Columnas.Insert();
            end;
        end;
    end;
    // BEGIN
    // {
    //   $001 FCL-220211. Cambio la clave (por clave orden);
    // }
    // END.
    var
        Lunes: Boolean;
        Martes: Boolean;
        Miercoles: Boolean;
        Jueves: Boolean;
        Viernes: Boolean;
        Sabado: Boolean;
        Domingo: Boolean;

    procedure SoloReales()
    begin
        Rec.SetRange(Bloqueado, FALSE);
    end;
}
