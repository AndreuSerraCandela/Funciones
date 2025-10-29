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

            dataitem("CampanasRetirar"; "Orden fijación")
            {
                UseTemporary = true;


                column(CampanaNombre; "Nombre Comercial") { }
                column(TirarCampana; Format("Guardar o Tirar")) { }
                column(ObservacionesCampana; AlgunosSigen(CampanasRetirar."Nº Orden")) { }
                column(FechaRetirada; "Fecha Retirada") { }
                column(TirarCampanaFlag; "Guardar o Tirar" = "Guardar o Tirar"::"Tirar") { }
                // Debug campos
                column(DebugCampanasCount; DebugCampanasCount) { }
                column(DebugCampanasMsg; 'Campañas encontradas') { }

                trigger OnPreDataItem()
                var
                    Orden_fijacion: Record "Orden fijación";
                    Job: Record Job;
                    CabOrdenFijacion: Record "Cab Orden fijación";
                begin
                    Orden_fijacion.setrange("Fecha fijación", FechaDesde, FechaHasta);
                    Orden_fijacion.SetFilter("Fecha Retirada", '<>%1', 0D);
                    if Orden_fijacion.FindSet() then
                        repeat
                            CampanasRetirar.SetRange("Nº Orden", Orden_fijacion."Nº Orden");
                            if not CampanasRetirar.FindSet() then begin
                                CampanasRetirar := Orden_fijacion;
                                if not CabOrdenFijacion.Get(Orden_fijacion."Nº Orden") then
                                    CabOrdenFijacion.Init();
                                if CampanasRetirar."Nombre Comercial" = '' then
                                    CampanasRetirar."Nombre Comercial" := CabOrdenFijacion."Nombre Comercial";
                                if CampanasRetirar."Nombre Comercial" = '' then
                                    if Job.Get(Orden_fijacion."Nº Proyecto") then
                                        CampanasRetirar."Nombre Comercial" := Job."Sell-to Customer Name";

                                CampanasRetirar.Insert();
                            end;

                        until Orden_fijacion.Next() = 0;
                end;
            }

            dataitem("Orden_fijacion"; "Cab Orden fijación")
            {
                DataItemTableView = SORTING("Fecha fijación");

                column(Nombre; NombreCliente) { }
                column(FechaFijacion; Format("Fecha fijación", 0, '<Day,2>/<Month,2>/<Year>')) { }
                column(NumOpis; "No. Opis") { }
                column(Descripcion; Descripcion) { }
                column(NProyecto; "Nº Proyecto") { }
                column(NombreComercial; "Nombre Comercial") { }
                column(RetirarCampana; Retirar(Orden_fijacion."Nº Orden")) { }
                column(Observaciones; Observaciones(Orden_fijacion."Nº Orden")) { }
                column(GuardarOTirar; GuardarTirar(Orden_fijacion."Nº Orden")) { }
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
                    if "Nombre Comercial" = '' then
                        If Job.Get("Nº Proyecto") then
                            "NombreCliente" := JOB."Sell-to Customer Name";
                    Orden_fijacion.SetRange("Nº Orden", "Nº Orden");
                    if "No. Opis" = 0 then
                        "No. Opis" := Orden_fijacion.Count;
                    Descripcion := Fijar;

                    if "No. Opis" = 0 then begin
                        //Message('Skip registro por No. Opis = 0. Orden: %1', "Nº Orden");
                        // Comentamos temporalmente el skip para debugging
                        // CurrReport.Skip();
                    end;


                    DebugOrdenCount += 1;
                end;

                trigger OnPreDataItem()
                begin
                    SetRange("Fecha fijación", FechaDesde, FechaHasta);
                    SetRange("Tipo soporte", "Tipo soporte"::"OPI");
                    DebugOrdenCount := 0;
                    //Message('Iniciando procesamiento de Orden_fijacion. Total registros disponibles: %1', Count);
                end;
            }

            trigger OnPreDataItem()
            var
                Orden_fijacion: Record "Orden fijación";
                CabOrdenFijacion: Record "Cab Orden fijación";
            begin
                CabOrdenFijacion.SetRange("Fecha fijación", FechaDesde, FechaHasta);
                CabOrdenFijacion.SetRange("Tipo soporte", CabOrdenFijacion."Tipo soporte"::"OPI");
                if CabOrdenFijacion.FindSet() then
                    repeat
                        Orden_fijacion.SetRange("Nº Orden", CabOrdenFijacion."Nº Orden");
                        TotalOpis += Orden_fijacion.Count;
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
                    field(FechaDesde; FechaDesde)
                    {
                        ApplicationArea = All;
                        Caption = 'Fecha desde';

                        trigger OnValidate()
                        var
                            CabOrdenFijacion: Record "Cab Orden fijación";
                        begin
                            ActualizarNumeroSemana();
                            FechaHasta := CalcDate('<CW>', FechaDesde);
                            CabOrdenFijacion.SetRange("Fecha fijación", FechaDesde, FechaHasta);
                            CabOrdenFijacion.SetRange("Tipo soporte", CabOrdenFijacion."Tipo soporte"::"OPI");
                            if CabOrdenFijacion.FindSet() then
                                repeat
                                    Orden_fijacion.SetRange("Nº Orden", CabOrdenFijacion."Nº Orden");
                                    TotalOpis += Orden_fijacion.Count;
                                until CabOrdenFijacion.Next() = 0;
                        end;
                    }
                    field(FechaHasta; FechaHasta)
                    {
                        ApplicationArea = All;
                        Caption = 'Fecha hasta';
                        trigger OnValidate()
                        var
                            CabOrdenFijacion: Record "Cab Orden fijación";
                        begin
                            TotalOpis := 0;
                            CabOrdenFijacion.SetRange("Fecha fijación", FechaDesde, FechaHasta);
                            CabOrdenFijacion.SetRange("Tipo soporte", CabOrdenFijacion."Tipo soporte"::"OPI");
                            if CabOrdenFijacion.FindSet() then
                                repeat
                                    Orden_fijacion.SetRange("Nº Orden", CabOrdenFijacion."Nº Orden");
                                    TotalOpis += Orden_fijacion.Count;
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

    local procedure AlgunosSigen(NoOrden_fijacion: Integer): Text
    var
        Orden_fijacion: Record "Orden fijación";
    begin
        //Si en la orden de ficjacion, queda alguna linea que no este marcada para retirar o que ya se haya retirado devuelve 'Algunos siguen.'
        Orden_fijacion.SetRange("Nº Orden", NoOrden_fijacion);
        if Orden_fijacion.FindSet() then
            repeat
                if (Orden_fijacion.Retirada = false) and (Orden_fijacion.Retirar = false) then
                    exit('Algunos siguen.');
            until Orden_fijacion.Next() = 0;
    end;

    local procedure Retirar(NOrden: Integer): Boolean
    begin
        Exit(false);
    end;

    local procedure Observaciones(NOrden: Integer): Text
    var
        Orden_fijacion: Record "Orden fijación";
    begin
        Orden_fijacion.SetRange("Nº Orden", NOrden);
        if Orden_fijacion.FindSet() then
            exit(Orden_fijacion."Observaciones");
        Exit('');
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
}