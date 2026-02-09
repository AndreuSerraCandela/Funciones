/// <summary>
/// Report Lista Fijaciones OPIs Semanal (ID 50050).
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
            //RequestFilterFields = "Fecha fijación";

            column(FechaDesde; Format(FechaDesde, 0, '<Weekday Text>, <Day,2> de <Month Text> de <Year4>')) { }
            column(FechaHasta; Format(FechaHasta, 0, '<Weekday Text>, <Day,2> de <Month Text> de <Year4>')) { }
            column(NumeroSemana; NumeroSemana) { }
            column(TotalOpis; TotalOpis) { }
            // Campos de debugging
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
                // Debug campos
                column(DebugCampanasCount; DebugCampanasCount) { }
                column(DebugCampanasMsg; 'Campañas encontradas') { }

                trigger OnPreDataItem()
                var
                    CampañasRetirar: Record "Campañas a retirar";
                begin
                    CampañasRetirar.SetRange("Fecha", FechaDesde, FechaHasta);
                    DebugCampanasCount := CampañasRetirar.Count;
                    If CampañasRetirar.FindSet() then
                        repeat
                            CampanasRetirar := CampañasRetirar;
                            If CampanasRetirar.Insert() then;
                        until CampañasRetirar.Next() = 0;
                end;
            }

            dataitem("Orden_fijacion"; Job)
            {

                column(Nombre; "Sell-to Customer Name") { }
                column(FechaFijacion; Format("Fecha fijación", 0, '<Day,2>/<Month,2>/<Year>')) { }
                column(NumOpis; "No. soportes") { }
                column(Descripcion; Description) { }
                column(NProyecto; "No.") { }
                column(NombreComercial; "Nombre Comercial") { }
                column(RetirarCampana; false) { }
                column(Observaciones; Descripcion) { }
                column(GuardarOTirar; 'TIRAR') { }
                // Debug campos
                column(DebugOrdenCount; DebugOrdenCount) { }
                column(DebugOrdenMsg; 'Órdenes procesadas') { }
                trigger OnAfterGetRecord()
                var
                    Job: Record Job;
                    Resource: Record Resource;
                    Cli: Record Customer;
                    Orden_fijacion: Record "Orden fijación";

                begin



                    DebugOrdenCount += 1;
                end;

                trigger OnPreDataItem()
                begin
                    SetRange(Fijar, true);
                    SetRange("Fecha fijación", FechaDesde, FechaHasta);
                    SetRange("Tipo soporte", "Tipo soporte"::Opis);
                    DebugOrdenCount := 0;
                    //Message('Iniciando procesamiento de Orden_fijacion. Total registros disponibles: %1', Count);
                end;
            }

            trigger OnPreDataItem()
            var
                CabOrdenFijacion: Record Job;
            begin
                CabOrdenFijacion.SetRange(Fijar, true);
                CabOrdenFijacion.SetRange("Fecha fijación", FechaDesde, FechaHasta);
                CabOrdenFijacion.SetRange("Tipo soporte", CabOrdenFijacion."Tipo soporte"::Opis);
                if CabOrdenFijacion.FindSet() then
                    repeat
                        TotalOpis += CabOrdenFijacion."No. Soportes";
                    until CabOrdenFijacion.Next() = 0;

                // Contar registros para debugging
                DebugCabCount := Count;

                // Comentamos el error temporalmente para debugging
                // if not FindSet then
                //     Error('No hay fijaciones en el rango de fechas seleccionado.');

                // Agregar mensaje de debugging


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

                    }
                    field(FechaDesde; FechaDesde)
                    {
                        ApplicationArea = All;
                        Caption = 'Fecha desde';

                        trigger OnValidate()
                        var
                            CabOrdenFijacion: Record Job;
                        begin
                            ActualizarNumeroSemana();
                            CabOrdenFijacion.SetRange(Fijar, true);
                            FechaHasta := CalcDate('<CW>', FechaDesde);
                            CabOrdenFijacion.SetRange("Fecha fijación", FechaDesde, FechaHasta);
                            CabOrdenFijacion.SetRange("Tipo soporte", CabOrdenFijacion."Tipo soporte"::"OPIs");
                            if CabOrdenFijacion.FindSet() then
                                repeat
                                    TotalOpis += CabOrdenFijacion."No. soportes";
                                until CabOrdenFijacion.Next() = 0;
                        end;
                    }
                    field(FechaHasta; FechaHasta)
                    {
                        ApplicationArea = All;
                        Caption = 'Fecha hasta';
                        trigger OnValidate()
                        var
                            CabOrdenFijacion: Record Job;
                        begin
                            TotalOpis := 0;
                            CabOrdenFijacion.SetRange(Fijar, true);
                            CabOrdenFijacion.SetRange("Fecha fijación", FechaDesde, FechaHasta);
                            CabOrdenFijacion.SetRange("Tipo soporte", CabOrdenFijacion."Tipo soporte"::"OPIs");
                            if CabOrdenFijacion.FindSet() then
                                repeat
                                    TotalOpis += CabOrdenFijacion."No. soportes";
                                until CabOrdenFijacion.Next() = 0;
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

        if NumeroSemana = 0 then begin
            // Si no se encuentra en el registro Date, calcularlo manualmente
            NumeroSemana := Date2DWY(FechaDesde, 2);
        end;
    end;







    local procedure GuardarTirar(NOrden: Integer): Text
    begin
        exit('')
    end;


    var
        FechaDesde: Date;
        FechaHasta: Date;
        NumeroSemana: Integer;
        NombreCliente: Text[100];
        Descripcion: Text[250];
        TotalOpis: Integer;
        DebugCabCount: Integer;
        DebugCampanasCount: Integer;
        DebugOrdenCount: Integer;
        TipoSoporte: Option "Opis","Vallas","Vallas Peantones","Indicadores";
}