/// <summary>
/// Page Plazos recursos reservados (ID 50022).
/// </summary>
page 50022 "Plazos recursos reservados"
{
    Caption = 'Plazos recurso';
    //ApplicationArea=all;
    SaveValues = true;
    InsertAllowed = false;
    DeleteAllowed = false;
    ModifyAllowed = false;
    LinksAllowed = false;
    SourceTable = Resource;
    PageType = ListPlus;
    UsageCategory = Tasks;
    RefreshOnActivate = true;


    layout
    {
        area(Content)
        {
            Group("Opciones matriz")
            {
                field(PeriodType; PeriodType)
                {
                    ApplicationArea = all;
                    Caption = 'Ver por';
                    ToolTip = 'Especifica para qué periodos se muestran';
                    //OptionCaption = 'Día,Semana,Mes';

                    trigger OnValidate()
                    BEGIN
                        SetColumns(SetWanted::Initial);
                        UpdateMatrixSubPage;
                    END;
                }
                field("Contrato"; Contratos)
                {

                    ApplicationArea = All;
                    trigger OnValidate()
                    BEGIN
                        UpdateMatrixSubPage;
                    End;
                }
                field(Desde; Desde)
                {
                    ApplicationArea = all;
                    trigger OnValidate()
                    BEGIN
                        UpdateMatrixSubPage;
                    End;
                }
                field(Hasta; Hasta)
                {
                    ApplicationArea = all;
                    trigger OnValidate()
                    BEGIN
                        UpdateMatrixSubPage;
                    End;

                }

                field("Filtro Tipo Recurso"; Tipus)
                {
                    ApplicationArea = all;
                    TableRelation = "Tipo Recurso";
                    ToolTip = 'Filtra por tipo de recurso';
                    trigger OnValidate()
                    BEGIN
                        if (Tipus <> '') THEN
                            Rec.SETFILTER("Tipo Recurso", Tipus)
                        ELSE
                            Rec.SETRANGE("Tipo Recurso");
                        UpdateMatrixSubPage;
                    END;
                }
                field("Filtro Familia"; Familia)
                {
                    ApplicationArea = all;
                    TableRelation = "Resource Group";

                    trigger OnValidate()
                    var

                    begin

                        if (Familia <> '') THEN
                            Rec.SetFilter("Resource Group No.", Familia)
                        ELSE
                            Rec.SETRANGE("Resource Group No.");
                        UpdateMatrixSubPage;
                    end;
                }
                field("Filtro Zona"; Fzona)
                {
                    TableRelation = "Zonas Recursos";
                    ApplicationArea = all;
                    trigger OnValidate()
                    begin
                        // if Fzona = '' THEN
                        //     Rec.SETRANGE("Dimensión Zona")
                        // ELSE
                        //     Rec.SETFILTER("Dimensión Zona", Fzona);
                        UpdateMatrixSubPage;
                    end;


                    trigger OnLookup(var Text: Text): Boolean
                    var
                        ZZonas: Record "Zonas Recursos";
                    begin
                        if Page.RunModal(0, ZZonas) in [Action::LookupOK, Action::OK] then
                            Fzona := ZZonas."Cod. Zona";
                        UpdateMatrixSubPage;
                    end;



                }
                field("Filtro dimension Zona"; FDzona)
                {
                    TableRelation = "Dimension Value";
                    ApplicationArea = all;
                    trigger OnValidate()
                    begin
                        // if Fzona = '' THEN
                        //     Rec.SETRANGE("Dimensión Zona")
                        // ELSE
                        //     Rec.SETFILTER("Dimensión Zona", Fzona);
                        UpdateMatrixSubPage;
                    end;


                    trigger OnLookup(var Text: Text): Boolean
                    var
                        ZZonas: Record "Dimension Value";
                        GlSetup: Record "General Ledger Setup";
                    begin
                        GlSetup.Get();
                        ZZonas.SetRange("Dimension Code", GlSetup."Shortcut Dimension 4 Code");
                        if Page.RunModal(0, ZZonas) in [Action::LookupOK, Action::OK] then
                            FDzona := ZZonas.Code;
                        UpdateMatrixSubPage;
                    end;

                }
                field("Solo Activos"; Activos)
                {
                    ApplicationArea = All;
                    trigger OnValidate()
                    begin
                        UpdateMatrixSubPage;
                    end;
                }
                field(Lunes; Lunes)
                {
                    ApplicationArea = All;
                    trigger OnValidate()
                    begin
                        UpdateMatrixSubPage;
                    end;
                }
                field(Martes; Martes)
                {
                    ApplicationArea = All;
                    trigger OnValidate()
                    begin
                        UpdateMatrixSubPage;
                    end;

                }
                field("Miércoles"; Miercoles)
                {
                    ApplicationArea = All;
                    trigger OnValidate()
                    begin
                        UpdateMatrixSubPage;
                    end;
                }
                field(Jueves; Jueves)
                {
                    ApplicationArea = All;
                    trigger OnValidate()
                    begin
                        UpdateMatrixSubPage;
                    end;
                }
                field(Viernes; Viernes)
                {
                    ApplicationArea = All;
                    trigger OnValidate()
                    begin
                        UpdateMatrixSubPage;
                    end;
                }
                field("Sábado"; Sabado)
                {
                    ApplicationArea = All;
                    trigger OnValidate()
                    begin
                        UpdateMatrixSubPage;
                    end;
                }
                field(Domingo; Domingo)
                {
                    ApplicationArea = All;
                    trigger OnValidate()
                    begin
                        UpdateMatrixSubPage;
                    end;
                }

                field(Nombre; Nombre)
                {
                    ShowCaption = false;
                    ApplicationArea = all;
                }
            }
            Part(Matrix; "Plazos recursos Matrix")
            {
                ApplicationArea = all;
            }

        }
    }

    actions

    {
        area(Navigation)
        {
            action("Guardar Filtro")
            {
                Image = SaveViewAs;
                ApplicationArea = All;
                trigger OnAction()
                var
                    Dialogo: Page Dialogo;
                    Filtros: Record "Filtros Recursos";
                    Fil: Text;
                begin
                    Dialogo.SetTexto('Introduzca el nombre del filtro');
                    Dialogo.RunModal();
                    Dialogo.GetTexto(Fil);
                    if Filtros.Get(UserId, Fil) Then error('El filtro %1 ya existe', Fil);
                    Filtros.Init();
                    Filtros.Usuario := UserId;
                    Filtros."Nombre del filtro" := Fil;
                    Filtros.Desde := Desde;
                    Filtros.Hasta := Hasta;
                    Filtros.Domingo := Domingo;
                    Filtros."Sábado" := Sabado;
                    Filtros.Viernes := Viernes;
                    Filtros.Jueves := Jueves;
                    Filtros."Miércoles" := Miercoles;
                    Filtros.Martes := Martes;
                    Filtros.Lunes := Lunes;
                    Filtros."Filtro dimension Zona" := FDzona;
                    Filtros."Filtro Familia" := Familia;
                    Filtros."Filtro Tipo Recurso" := Tipus;
                    Filtros."Filtro Zona" := Fzona;
                    Filtros.PeriodTypeNew := PeriodType;
                    Filtros.Insert();
                end;
            }
            action("Aplicar Filtro")
            {
                Image = UseFilters;
                ApplicationArea = All;
                trigger OnAction()
                var
                    Dialogo: Page Dialogo;
                    Filtros: Record "Filtros Recursos";
                    Fil: Text;
                begin
                    Filtros.SetRange(Usuario, UserId);
                    if Page.RunModal(Page::Filtros, Filtros) = Action::LookupOK Then begin
                        // Desde := Filtros.Desde;
                        // Hasta := Filtros.Hasta;
                        // Domingo := Filtros.Domingo;
                        // Sabado := Filtros."Sábado";
                        // Viernes := Filtros.Viernes;
                        // Jueves := Filtros.Jueves;
                        // Miercoles := Filtros."Miércoles";
                        // Martes := Filtros.Martes;
                        // Lunes := Filtros.Lunes;
                        FdZona := Filtros."Filtro dimension Zona";
                        Familia := Filtros."Filtro Familia";
                        Tipus := Filtros."Filtro Tipo Recurso";
                        Fzona := Filtros."Filtro Zona";
                        // PeriodType := Filtros.PeriodType;
                        if (Tipus <> '') THEN
                            Rec.SETFILTER("Tipo Recurso", Tipus)
                        ELSE
                            Rec.SETRANGE("Tipo Recurso");
                        if (Familia <> '') THEN
                            Rec.SetFilter("Resource Group No.", Familia)
                        ELSE
                            Rec.SETRANGE("Resource Group No.");

                        UpdateMatrixSubPage;
                    end;
                end;
            }
            group(Fijación)
            {
                action("Seleccionar fechas")
                {
                    Image = AdjustEntries;
                    ApplicationArea = All;
                    trigger OnAction()
                    var
                        Dialogo: Page "Date-Time Dialog";
                    begin
                        if Dialogo.RunModal() in [Action::Cancel, Action::LookupCancel, Action::No, Action::None] Then error('Proceso Cancelado');
                        InicioReserva := Dialogo.GetDate();
                        // Clear(Dialogo);
                        // if Dialogo.RunModal() in [Action::Cancel, Action::LookupCancel, Action::No, Action::None] Then error('Proceso Cancelado');
                        FinReserva := Dialogo.GetDate();
                        CurrPage.Matrix.Page.Fechas(InicioReserva, FinReserva);
                    end;
                }
                action("Añadir a Lista Fijacion")
                {
                    Image = AdjustEntries;
                    ApplicationArea = All;
                    trigger OnAction()
                    var
                        Res: Record Resource;
                        Fechas: Page "Date-Time Dialog";
                    begin
                        CurrPage.SetSelectionFilter(Res);
                        if Res.FindFirst()
                        then
                            repeat
                                Recurso := Res;
                                Recurso."Employment Date" := InicioReserva;
                                Recurso."Last Date Modified" := FinReserva;
                                if Recurso.Insert() Then
                                    CurrPage.Matrix.Page.IncorporaRecurso(Recurso."No.");
                            until Res.Next() = 0;
                        CurrPage.Matrix.Page.Update(false);
                    end;
                }
                action("Crear Proyecto Fijacion")
                {
                    Image = JobTimeSheet;
                    ApplicationArea = All;
                    trigger OnAction()
                    var
                        Job: Record Job;
                        JobsSetup: Record "Jobs Setup";
                        ResUnit: Record "Resource Unit of Measure";
                        JobplanningLine: Record "Job Planning Line";
                        Linea: Integer;
                    begin
                        Job.SetRange("Creation Date", CalcDate('PA+1D-1A'), CalcDate('PA'));
                        Job.SetRange("Proyecto de fijación", true);
                        if not Job.FindFirst() then begin
                            Job.Init();
                            Job.Description := 'Proyecto de fijación ' + Format(Date2DMY(Today, 3), 0);
                            Job."No." := 'FI' + Format(Date2DMY(Today, 3), 0) + '-00001';
                            Job."Creation Date" := Today;
                            Job."Proyecto de fijación" := true;
                            Job.Insert(true);
                        end;
                        // Quiero recuperar los recursos de la matriz de recursos de una procedure creata a tal efecto
                        // Recuperar los recursos de la matriz de recursos
                        // Recorrer los recursos y crear las lineas de planificación
                        CurrPage.Matrix.Page.Recursos(Recurso);
                        if Recurso.FindFirst() Then
                            repeat
                                JobplanningLine.SetRange("Job No.", Job."No.");
                                if JobplanningLine.FindLast() Then Linea := JobplanningLine."Line No." + 10000 Else Linea := 10000;
                                JobplanningLine.Init();
                                JobplanningLine."Job No." := Job."No.";
                                JobplanningLine."Line No." := Linea;
                                JobplanningLine."Job Task No." := '10';
                                JobplanningLine.Type := JobplanningLine.Type::Resource;
                                if not ResUnit.Get(Recurso."No.", Recurso."Base Unit of Measure") Then begin
                                    ResUnit.Init();
                                    ResUnit."Resource No." := Recurso."No.";
                                    ResUnit."Code" := Recurso."Base Unit of Measure";
                                    ResUnit.Insert();
                                end;
                                JobplanningLine.Validate("No.", Recurso."No.");
                                JobplanningLine."Planning Date" := Recurso."Employment Date";
                                JobplanningLine."Fecha Final" := Recurso."Last Date Modified";
                                JobplanningLine.Validate(Quantity, 1);
                                JobplanningLine.Insert();
                            until Recurso.Next() = 0;
                        Commit();
                        Page.RunModal(Page::"Fijación Proyectos", Job);
                    end;
                }
            }
            action("Previous Set")
            {
                Caption = 'Conjunto anterior';
                ToolTip = 'Permite desplazarse al conjunto de datos anterior.';
                ApplicationArea = all;
                Promoted = true;
                PromotedIsBig = true;
                Image = PreviousSet;
                PromotedCategory = Process;
                trigger OnAction()
                BEGIN
                    SetColumns(SetWanted::Previous);
                    UpdateMatrixSubPage;
                END;
            }
            action("Previous Column")
            {
                Caption = 'Columna anterior';
                ToolTip = 'Permite desplazarse a la columna anterior.';
                ApplicationArea = all;
                Promoted = true;
                PromotedIsBig = true;
                Image = PreviousRecord;
                PromotedCategory = Process;
                trigger OnAction()
                BEGIN
                    SetColumns(SetWanted::PreviousColumn);
                    UpdateMatrixSubPage;
                END;
            }
            action("Next Column")
            {
                Caption = 'Columna siguiente';
                ToolTip = 'Permite desplazarse a la columna siguiente.';
                ApplicationArea = all;
                Promoted = true;
                PromotedIsBig = true;
                Image = NextRecord;
                PromotedCategory = Process;
                trigger OnAction()
                BEGIN
                    SetColumns(SetWanted::NextColumn);
                    UpdateMatrixSubPage;
                END;
            }
            action("Next Set")
            {
                Caption = 'Conjunto siguiente';
                ToolTip = 'Permite desplazarse al conjunto de datos siguiente.';
                ApplicationArea = all;
                Promoted = true;
                PromotedIsBig = true;
                Image = NextSet;
                PromotedCategory = Process;
                trigger OnAction()
                BEGIN
                    SetColumns(SetWanted::Next);
                    UpdateMatrixSubPage;
                END;
            }
            action(Imprimir)
            {
                ApplicationArea = All;
                Visible = false;
                Image = Print;
                trigger OnAction()
                var
                    Columnas: Record "Standard Text" temporary;
                begin
                    CurrPage.Matrix.Page.SeleccionaColumnas(columnas);
                    CurrPage.Matrix.Page.SetSelectionFilter(columnas);
                    If Columnas.Count > 3 then Error('No se pueden imprimir más de 3 columnas');
                end;


            }
        }
    }
    VAR
        Lunes: Boolean;
        Martes: Boolean;
        Miercoles: Boolean;
        Jueves: Boolean;
        Viernes: Boolean;
        Sabado: Boolean;
        Domingo: Boolean;
        Contratos: Option "Pendiente de Firma",Firmado,Anulado,Cancelado,Modificado,"Sin Montar","Sin Contrato","Con Contrato","Todos";// Enum "Filtro Estado Contrato";
        MatrixRecords: ARRAY[32] OF Record 2000000007;
        PeriodType: Enum "Analysis Period Type";
        MatrixColumnCaptions: ARRAY[32] OF Text[1024];
        ColumnSet: Text[1024];
        SetWanted: Option Initial,Previous,Same,Next,PreviousColumn,NextColumn;
        PKFirstRecInCurrSet: Text[100];
        CurrSetLength: Integer;
        Nombre: Text;
        Fzona: Text;
        FDzona: Text;
        Familia: Text;
        Tipus: Text;
        Zonas: Record "Zonas Recursos";
        rRecurs: Record Resource;
        Desde: Date;
        Hasta: Date;
        Recurso: Record Resource temporary;
        InicioReserva: Date;
        FinReserva: Date;
        Activos: Boolean;

    trigger OnOpenPage()
    BEGIN

        Rec.RESET;
        Rec.SETRANGE("No.", rRecurs."No.");
        if Rec.FIND('-') THEN;
        Rec.SETCURRENTKEY("Clave orden");                     //$001
        Rec.SETRANGE("No.");
        SetColumns(SetWanted::Initial);
        Contratos := Contratos::"Con Contrato";
        UpdateMatrixSubPage;
    END;

    trigger OnAfterGetRecord()
    begin
        Nombre := '';
        if Strlen(Fzona) < 21 then
            if Zonas.Get(FZona) Then Nombre := Zonas."Texto Zona";
    end;


    PROCEDURE SetColumns(SetWanted: Option Initial,Previous,Same,Next,PreviousColumn,NextColumn);
    VAR
        MatrixMgt: Codeunit 9200;
    BEGIN
        if (Desde <> 0D) And (Hasta = 0D) Then Hasta := Desde;
        if (Desde <> 0D) and (Hasta <> 0D) Then if Hasta < Desde Then Hasta := Desde;
        if (Desde = 0D) Or (Hasta = 0D) Then begin
            MatrixMgt.GeneratePeriodMatrixData(SetWanted, 32, FALSE, PeriodType, '',
              PKFirstRecInCurrSet, MatrixColumnCaptions, ColumnSet, CurrSetLength, MatrixRecords);
            Rec.SetRange("Date Filter")
        end else begin
            Rec.SetRange("Date Filter", Desde, Hasta);
            MatrixMgt.GeneratePeriodMatrixData(SetWanted, 32, FALSE, PeriodType, Rec.GetFilter("Date Filter"),
              PKFirstRecInCurrSet, MatrixColumnCaptions, ColumnSet, CurrSetLength, MatrixRecords);
        End;

    END;

    LOCAL PROCEDURE UpdateMatrixSubPage();
    var
        EnumContratos: Enum "Filtro Estado Contrato";
    BEGIN
        if Lunes Then begin
            Martes := false;
            Miercoles := false;
            Jueves := false;
            Viernes := false;
            Sabado := false;
            Domingo := false;
            PeriodType := PeriodType::Week;
        end;
        if Martes Then begin
            Lunes := false;
            Miercoles := false;
            Jueves := false;
            Viernes := false;
            Sabado := false;
            Domingo := false;
            PeriodType := PeriodType::Week;
        end;
        if Miercoles Then begin
            Martes := false;
            Lunes := false;
            Jueves := false;
            Viernes := false;
            Sabado := false;
            Domingo := false;
            PeriodType := PeriodType::Week;
        end;
        if Jueves Then begin
            Martes := false;
            Miercoles := false;
            Lunes := false;
            Viernes := false;
            Sabado := false;
            Domingo := false;
            PeriodType := PeriodType::Week;
        end;
        if Viernes Then begin
            Martes := false;
            Miercoles := false;
            Jueves := false;
            Lunes := false;
            Sabado := false;
            Domingo := false;
            PeriodType := PeriodType::Week;
        end;
        if Sabado Then begin
            Martes := false;
            Miercoles := false;
            Jueves := false;
            Viernes := false;
            Lunes := false;
            Domingo := false;
            PeriodType := PeriodType::Week;
        end;
        if Domingo Then begin
            Martes := false;
            Miercoles := false;
            Jueves := false;
            Viernes := false;
            Sabado := false;
            Lunes := false;
            PeriodType := PeriodType::Week;
        end;
        Case Contratos of
            Contratos::Anulado:
                EnumContratos := EnumContratos::Anulado;
            Contratos::Cancelado:
                EnumContratos := EnumContratos::Cancelado;
            Contratos::"Con Contrato":
                EnumContratos := EnumContratos::"Con Contrato";
            Contratos::Modificado:
                EnumContratos := EnumContratos::Modificado;
            Contratos::Firmado:
                EnumContratos := EnumContratos::Firmado;
            Contratos::"Pendiente de Firma":
                EnumContratos := EnumContratos::"Pendiente de Firma";
            Contratos::"Sin Contrato":
                EnumContratos := EnumContratos::"Sin Contrato";
            Contratos::"Sin Montar":
                EnumContratos := EnumContratos::"Sin Montar";
            Contratos::Todos:
                EnumContratos := EnumContratos::Todos;
        End;
        CurrPage.Matrix.PAGE.Load(PeriodType, MatrixColumnCaptions,
        MatrixRecords, CurrSetLength, Tipus, Fzona, Familia, Lunes, Martes, Miercoles, Jueves, Viernes, Sabado, Domingo, FDzona, EnumContratos, Activos);
        CurrPage.UPDATE(FALSE);
    END;


    PROCEDURE Coge_Recurso(VAR rRec: Record 156);
    BEGIN
        rRecurs := rRec;
    END;



}