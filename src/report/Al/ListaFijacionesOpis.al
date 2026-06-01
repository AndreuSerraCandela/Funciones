/// <summary>
/// Report Lista Fijaciones OPIs Semanal (ID 50056).
/// </summary>
Report 50056 "Lista Fijaciones OPIs Semanal"
{
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;
    DefaultLayout = Word;
    WordLayout = './src/report/layout/ListaFijacionesOpisSemanal.docx';

    dataset
    {
        dataitem("CabFijacion"; Integer)
        {
            MaxIteration = 1;

            column(FechaDesde; Format(FechaDesde, 0, '<Weekday Text>, <Day,2> de <Month Text> de <Year4>')) { }
            column(FechaHasta; Format(FechaHasta, 0, '<Weekday Text>, <Day,2> de <Month Text> de <Year4>')) { }
            column(NumeroSemana; NumeroSemana) { }
            column(TotalOpis; TotalOpis) { }
            column(DebugCabCount; DebugCabCount) { }
            column(DebugMessage; 'Registros encontrados en CabFijacion') { }

            dataitem("CampanasRetirar"; "Campañas a retirar")
            {
                UseTemporary = true;

                column(CampanaNombre; CampanasRetirar."Campaña") { }
                column(TirarCampana; Format(CampanasRetirar."Tirar")) { }
                column(ObservacionesCampana; CampanasRetirar."Observaciones") { }
                column(FechaRetirada; "Fecha") { }
                column(TirarCampanaFlag; Tirar = true) { }
                column(DebugCampanasCount; DebugCampanasCount) { }
                column(DebugCampanasMsg; 'Campañas encontradas') { }

                trigger OnPreDataItem()
                var
                    CampañasRetirar: Record "Campañas a retirar";
                begin
                    CampañasRetirar.SetRange("Fecha", FechaDesde, FechaHasta);
                    DebugCampanasCount := CampañasRetirar.Count;
                    if CampañasRetirar.FindSet() then
                        repeat
                            CampanasRetirar := CampañasRetirar;
                            if CampanasRetirar.Insert() then;
                        until CampañasRetirar.Next() = 0;
                end;
            }

            dataitem("Orden_fijacion"; "Planificación Fijación")
            {
                column(Nombre; Nombre) { }
                column(FechaFijacion; Format("Fecha fijación", 0, '<Day,2>/<Month,2>/<Year>')) { }
                column(NumOpis; "No. Soportes") { }
                column(Descripcion; Nombre) { }
                column(NProyecto; "Nº Proyecto") { }
                column(NombreComercial; "Nombre Comercial") { }
                column(RetirarCampana; false) { }
                column(Observaciones; Fijar) { }
                column(GuardarOTirar; 'TIRAR') { }
                column(DebugOrdenCount; DebugOrdenCount) { }
                column(DebugOrdenMsg; 'Planificaciones procesadas') { }

                trigger OnAfterGetRecord()
                begin
                    DebugOrdenCount += 1;
                end;

                trigger OnPreDataItem()
                var
                    PlanificacionFijacionRef: Record "Planificación Fijación";
                begin
                    SetRange("Fecha fijación", FechaDesde, FechaHasta);
                    SetRange("Tipo Soporte");
                    case TipoSoporte of
                        TipoSoporte::Opis:
                            SetRange("Tipo Soporte", PlanificacionFijacionRef."Tipo Soporte"::Opis);
                        TipoSoporte::Vallas:
                            SetRange("Tipo Soporte", PlanificacionFijacionRef."Tipo Soporte"::Vallas);
                        TipoSoporte::"Vallas Peantones":
                            SetRange("Tipo Soporte", PlanificacionFijacionRef."Tipo Soporte"::"Vallas Peatones");
                        TipoSoporte::Indicadores:
                            SetRange("Tipo Soporte", PlanificacionFijacionRef."Tipo Soporte"::Indicadores);
                    end;
                    DebugOrdenCount := 0;
                end;
            }

            trigger OnPreDataItem()
            var
                PlanificacionFijacion: Record "Planificación Fijación";
            begin
                TotalOpis := 0;
                PlanificacionFijacion.SetRange("Fecha fijación", FechaDesde, FechaHasta);
                AplicarFiltroTipoSoporte(PlanificacionFijacion);
                DebugCabCount := PlanificacionFijacion.Count;
                if PlanificacionFijacion.FindSet() then
                    repeat
                        TotalOpis += PlanificacionFijacion."No. Soportes";
                    until PlanificacionFijacion.Next() = 0;
            end;
        }
    }

    requestpage
    {
        layout
        {
            area(Content)
            {
                group(Opciones)
                {
                    field(TipoSoporte; TipoSoporte)
                    {
                        ApplicationArea = All;
                        Caption = 'Tipo de soporte';

                        trigger OnValidate()
                        begin
                            RecalcularTotalOpis();
                        end;
                    }
                    field(FechaDesde; FechaDesde)
                    {
                        ApplicationArea = All;
                        Caption = 'Fecha desde';

                        trigger OnValidate()
                        begin
                            ActualizarNumeroSemana();
                            FechaHasta := CalcDate('<CW>', FechaDesde);
                            RecalcularTotalOpis();
                        end;
                    }
                    field(FechaHasta; FechaHasta)
                    {
                        ApplicationArea = All;
                        Caption = 'Fecha hasta';

                        trigger OnValidate()
                        begin
                            RecalcularTotalOpis();
                        end;
                    }
                    field(NumeroSemana; NumeroSemana)
                    {
                        ApplicationArea = All;
                        Caption = 'Número de semana';
                        Editable = false;
                    }
                    field(TotalOpis; TotalOpis)
                    {
                        ApplicationArea = All;
                        Editable = false;
                    }
                }
            }
        }
    }

    trigger OnInitReport()
    begin
        FechaDesde := CalcDate('<-CW>', WorkDate());
        FechaHasta := CalcDate('<CW>', WorkDate());
        ActualizarNumeroSemana();
        RecalcularTotalOpis();
    end;

    local procedure ActualizarNumeroSemana()
    var
        DateRec: Record Date;
    begin
        DateRec.Reset();
        DateRec.SetRange("Period Type", DateRec."Period Type"::Week);
        DateRec.SetFilter("Period Start", '<=%1', FechaDesde);
        DateRec.SetFilter("Period End", '>=%1', FechaDesde);
        if DateRec.FindLast() then
            NumeroSemana := DateRec."Period No.";

        if NumeroSemana = 0 then
            NumeroSemana := Date2DWY(FechaDesde, 2);
    end;

    local procedure RecalcularTotalOpis()
    var
        PlanificacionFijacion: Record "Planificación Fijación";
    begin
        TotalOpis := 0;
        PlanificacionFijacion.SetRange("Fecha fijación", FechaDesde, FechaHasta);
        AplicarFiltroTipoSoporte(PlanificacionFijacion);
        if PlanificacionFijacion.FindSet() then
            repeat
                TotalOpis += PlanificacionFijacion."No. Soportes";
            until PlanificacionFijacion.Next() = 0;
    end;

    local procedure AplicarFiltroTipoSoporte(var PlanificacionFijacion: Record "Planificación Fijación")
    var
        PlanificacionFijacionRef: Record "Planificación Fijación";
    begin
        PlanificacionFijacion.SetRange("Tipo Soporte");
        case TipoSoporte of
            TipoSoporte::Opis:
                PlanificacionFijacion.SetRange("Tipo Soporte", PlanificacionFijacionRef."Tipo Soporte"::Opis);
            TipoSoporte::Vallas:
                PlanificacionFijacion.SetRange("Tipo Soporte", PlanificacionFijacionRef."Tipo Soporte"::Vallas);
            TipoSoporte::"Vallas Peantones":
                PlanificacionFijacion.SetRange("Tipo Soporte", PlanificacionFijacionRef."Tipo Soporte"::"Vallas Peatones");
            TipoSoporte::Indicadores:
                PlanificacionFijacion.SetRange("Tipo Soporte", PlanificacionFijacionRef."Tipo Soporte"::Indicadores);
        end;
    end;

    var
        FechaDesde: Date;
        FechaHasta: Date;
        NumeroSemana: Integer;
        TotalOpis: Integer;
        DebugCabCount: Integer;
        DebugCampanasCount: Integer;
        DebugOrdenCount: Integer;
        TipoSoporte: Option Opis,Vallas,"Vallas Peantones",Indicadores;
}
