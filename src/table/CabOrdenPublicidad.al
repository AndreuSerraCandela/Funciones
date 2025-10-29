tableextension 75008 CabOrdenPublicidadKuara extends "Cab. Orden Publicidad"
{
    PROCEDURE ActualizarLineas(pActualizarTarifas: Boolean): Boolean;
    VAR
        wOpciones: Option Cancelar,Recalcular,Eliminar;
        txt01: Label 'Recalcular lineas,Eliminar lineas';
        rLinOrden: Record "Lin. orden publicidad";
        cMedios: Codeunit "Gestion medios";
    BEGIN

        rLinOrden.RESET;
        rLinOrden.SETRANGE("Tipo orden", "Tipo orden");
        rLinOrden.SETRANGE("No. orden", No);
        rLinOrden.SETRANGE(rLinOrden."Importe manual", FALSE);
        if rLinOrden.FIND('-') THEN BEGIN

            wOpciones := STRMENU(txt01);

            CASE wOpciones OF
                wOpciones::Cancelar:
                    EXIT(FALSE);
                wOpciones::Recalcular:
                    BEGIN
                        rLinOrden.DELETEALL;
                        if pActualizarTarifas THEN
                            CopiaTarifasTamaño;
                        cMedios.GenerarLineasOrden(Rec, 0D, 0D, 0);  // Genera todas las lineas otra vez
                        EXIT(TRUE);
                    END;
                wOpciones::Eliminar:
                    BEGIN
                        rLinOrden.DELETEALL(TRUE);
                        if pActualizarTarifas THEN
                            CopiaTarifasTamaño;
                        EXIT(TRUE);
                    END;
            END;
        END
        ELSE BEGIN
            if pActualizarTarifas THEN
                CopiaTarifasTamaño;
            EXIT(TRUE);
        END;
    END;


}
tableextension 75006 LinOrdenPublicidadKuara extends "Lin. orden publicidad"
{
    trigger OnAfterDelete()
    begin
        if "Dia conjunto" <> 0D THEN
            RecalcularConjunto();
    end;

    PROCEDURE RecalcularConjunto();
    VAR
        rOrden: Record "Cab. orden publicidad";
        rLinOrden: Record "Lin. orden publicidad";
        wFechaIni: Date;
        wFechaFin: Date;
    BEGIN

        rLinOrden.RESET;
        rLinOrden.SETRANGE("Tipo orden", "Tipo orden");
        rLinOrden.SETRANGE("No. orden", "No. orden");
        rLinOrden.SETFILTER("No. linea", '<>%1', "No. linea");              // Recalcular todas las lineas excepto la que borramos
        rLinOrden.SETRANGE("Dia conjunto", "Dia conjunto");
        if rLinOrden.FIND('-') THEN
            wFechaIni := rLinOrden."Fecha inicio";
        if rLinOrden.FIND('+') THEN
            wFechaFin := rLinOrden."Fecha inicio";
        if (wFechaIni <> 0D) AND (wFechaFin <> 0D) THEN BEGIN
            rLinOrden.DELETEALL;
            if rOrden.GET("No. orden") THEN
                cMedios.GenerarLineasOrden(rOrden, wFechaIni, wFechaFin, 0);
        END;
    END;

    VAR
        cMedios: Codeunit "Gestion medios";
}