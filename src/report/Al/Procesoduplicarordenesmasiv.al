/// <summary>
/// Report Proceso duplicar ordenes masiv (ID 50002).
/// </summary>
report 50002 "Proceso duplicar ordenes masiv"
{
    Caption = 'Proceso duplicar ordenes masiv';
    ProcessingOnly = true;
    dataset
    {
        dataitem(Job; Job)
        {
            DataItemTableView = SORTING("No.");
            RequestFilterFields = "No.";
            //ReqFilterHeading='Proyecto';
            trigger OnPreDataItem()
            BEGIN
                if (NuevaFecha = 0D) THEN
                    ERROR('Debe introducir una nueva fecha de fijación');
                if (NuevoFijar = '') THEN
                    ERROR('El nuevo texto no deberia quedar en blanco');
                rOrden.SETCURRENTKEY("Nº Proyecto", "Fecha fijación");
                if (FechaOriginal = 0D) THEN
                    ERROR('Debe introducir una fecha original')
                ELSE
                    rOrden.SETRANGE("Fecha fijación", FechaOriginal);
            END;

            trigger OnAfterGetRecord()
            var
                rDet: Record "Orden fijación";
                i: Integer;
                num: Integer;
            BEGIN
                if (Job.GETFILTER("No.") = '') THEN
                    ERROR('Deberia introducir un filtro en la pestaña de proyecto')
                ELSE
                    rOrden.SETRANGE("Nº Proyecto", Job."No.");

                cuenta := 0;
                if rOrden.FIND('-') THEN
                    REPEAT
                        rDet.SETRANGE("Nº Orden", rOrden."Nº Orden");
                        If rDet.FindSet() THEN
                            repeat
                                if rReserva.GET(rDet."Nº Reserva") THEN BEGIN
                                    if (NuevaFecha <= rReserva."Fecha fin") THEN BEGIN
                                        i += 1;
                                    END;
                                END;

                            UNTIL rDet.NEXT = 0;
                        if i > 0 then begin
                            num := rOrden.Duplicar(rOrden, NuevaFecha, NuevoFijar);
                            If rDet.FindSet() THEN
                                repeat
                                    if rReserva.GET(rDet."Nº Reserva") THEN BEGIN
                                        if (NuevaFecha <= rReserva."Fecha fin") THEN BEGIN
                                            cuenta := cuenta + 1;
                                            rDet.duplicar(Num, rDet, NuevaFecha, NuevoFijar, rOrden.Tapar);
                                        end;
                                    end;
                                until rdet.Next() = 0;
                        end;

                    UNTIL rOrden.NEXT = 0;

                rOrden2.RESET;
                if rOrden2.FIND('+') THEN
                    i := rOrden2."Nº Orden" + 1
                ELSE
                    i := 1;

                rReserva.INIT;
                rReserva.SETCURRENTKEY("Nº Proyecto", "Fecha inicio");
                rReserva.SETRANGE("Nº Proyecto", Job."No.");
                rReserva.SETRANGE("Fecha inicio", NuevaFecha);
                if rReserva.FIND('-') THEN begin
                    CLEAR(rOrden);
                    rOrden.RESET;
                    rOrden."Nº Orden" := i;
                    rOrden."Fecha generación" := WORKDATE;
                    rOrden."Fecha fijación" := rReserva."Fecha inicio";
                    rOrden."Nº Proyecto" := rReserva."Nº Proyecto";
                    rOrden.Fijar := NuevoFijar;
                    rDia2.RESET;
                    rDia2.SETCURRENTKEY("Nº Recurso", Fecha);
                    rDia2.SETRANGE("Nº Recurso", rReserva."Nº Recurso");
                    rDia2.SETFILTER(Fecha, '<%1', rReserva."Fecha inicio");
                    rDia2.SETFILTER("Nº Reserva", '<>%1', rReserva."Nº Reserva");
                    if rDia2.FIND('+') THEN BEGIN
                        rProyecto.GET(rDia2."Nº Proyecto");
                        rOrden.Tapar := rProyecto.Description;
                    END;
                    rRecurs.GET(rReserva."Nº Recurso");
                    rOrden.Zona := rRecurs.Zona;
                    repeat
                        rOrden."Nº Orden" := i;
                        I += 1;
                    UNTIL rOrden.INSERT;
                    REPEAT
                        cuenta := cuenta + 1;
                        CLEAR(rDet);
                        rDet.RESET;
                        rDet."Nº Orden" := rOrden."Nº Orden";
                        i := i + 1;
                        rDet."Nº Reserva" := rReserva."Nº Reserva";
                        rDet."Nº Recurso" := rReserva."Nº Recurso";
                        rDet."Fecha generación" := WORKDATE;
                        rDet."Fecha fijación" := rReserva."Fecha inicio";
                        rDet."Nº Proyecto" := rReserva."Nº Proyecto";
                        rDet.Fijar := NuevoFijar;
                        rDia2.RESET;
                        rDia2.SETCURRENTKEY("Nº Recurso", Fecha);
                        rDia2.SETRANGE("Nº Recurso", rReserva."Nº Recurso");
                        rDia2.SETFILTER(Fecha, '<%1', rReserva."Fecha inicio");
                        rDia2.SETFILTER("Nº Reserva", '<>%1', rReserva."Nº Reserva");
                        if rDia2.FIND('+') THEN BEGIN
                            rProyecto.GET(rDia2."Nº Proyecto");
                            rOrden.Tapar := rProyecto.Description;
                        END;
                        rRecurs.GET(rReserva."Nº Recurso");
                        rDet.Zona := rRecurs.Zona;
                        rDet.INSERT;
                        rReserva2.RESET;
                        rReserva2 := rReserva;
                        CASE rReserva.Estado OF
                            rReserva.Estado::Reservado:
                                BEGIN
                                    rReserva2.Estado := rReserva2.Estado::Ocupado;
                                    rDia.SETRANGE("Nº Reserva", rReserva2."Nº Reserva");
                                    rDia.MODIFYALL(Estado, rReserva2.Estado);
                                END;
                            rReserva.Estado::"Reservado fijo":
                                BEGIN
                                    rReserva2.Estado := rReserva2.Estado::"Ocupado fijo";
                                    rDia.SETRANGE("Nº Reserva", rReserva2."Nº Reserva");
                                    rDia.MODIFYALL(Estado, rReserva2.Estado);
                                END;
                        END;
                        rReserva2.MODIFY;
                    UNTIL rReserva.NEXT = 0;
                END;
                MESSAGE('Se han creado ' + STRSUBSTNO('%1', cuenta) +
                        ' nuevas ordenes de fijación');
            END;

        }
    }
    requestpage
    {
        layout
        {
            area(content)
            {
                group(GroupName)
                {
                    field("Fecha Original"; FechaOriginal) { ApplicationArea = All; }
                    field("Nueva fecha fijación"; NuevaFecha) { ApplicationArea = All; }
                    field("Nuevo texto fijación"; NuevoFijar) { ApplicationArea = All; }
                }
            }
        }

    }
    VAR
        FechaOriginal: Date;
        NuevaFecha: Date;
        NuevoFijar: Text[30];
        rOrden: Record "Cab Orden fijación";
        rOrden2: Record "Cab Orden fijación";
        rReserva: Record Reserva;
        rReserva2: Record Reserva;
        rDia: Record "Diario Reserva";
        rDia2: Record "Diario Reserva";
        rRecurs: Record 156;
        rProyecto: Record 167;
        i: Integer;
        cuenta: Integer;
}
