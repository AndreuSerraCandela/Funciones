/// <summary>
/// Codeunit Funciones calendario (ID 7001145).
/// </summary>
codeunit 7001115 "Funciones calendario"
{


    VAR
        cMedios: Codeunit "Gestion medios";
        wFechaIniPeriodo: Date;
        txt01: Label 'Se desmarcaran los días del periodo %1 - %2. ¿Desea continuar?.';

    PROCEDURE IniciarCalendario(pFechaRef: Date; VAR pDias: ARRAY[38, 2] OF Integer; VAR pMeses: ARRAY[2] OF Option Enero,Febrero,Marzo,Abril,Mayo,Junio,Julio,Agosto,Septiembre,Octubre,Noviembre,Diciembre; VAR pAños: ARRAY[2] OF Integer)
    VAR
        wFechaRef: Date;
        i: Integer;
    BEGIN

        if pFechaRef <> 0D THEN
            wFechaRef := pFechaRef
        ELSE
            wFechaRef := WORKDATE;

        pMeses[1] := DATE2DMY(wFechaRef, 2) - 1;
        pAños[1] := DATE2DMY(wFechaRef, 3);

        if pMeses[1] = 11 THEN BEGIN
            pAños[2] := pAños[1] + 1;
            pMeses[2] := 0;
        END
        ELSE BEGIN
            pAños[2] := pAños[1];
            pMeses[2] := pMeses[1] + 1;
        END;

        RellenarDias(pDias, pMeses, pAños);
    END;

    PROCEDURE RellenarDias(VAR pDias: ARRAY[38, 2] OF Integer; VAR pMeses: ARRAY[2] OF Option Enero,Febrero,Marzo,Abril,Mayo,Junio,Julio,Agosto,Septiembre,Octubre,Noviembre,Diciembre; VAR pAños: ARRAY[2] OF Integer)
    VAR
        wPosicion: Integer;
        wFechaIni: Date;
        wDia: Integer;
        wDiasmes: Integer;
        i: Integer;
        j: Integer;
    BEGIN

        CLEAR(pDias);

        FOR i := 1 TO ARRAYLEN(pMeses) DO BEGIN
            wPosicion := 0;
            wFechaIni := DMY2DATE(1, pMeses[i] + 1, pAños[i]);
            wDia := DATE2DWY(wFechaIni, 1);
            //    wDiasmes:= DATE2DMY(CalcFechaFin(wFechaIni),1);  // 001
            wDiasmes := DATE2DMY(CALCDATE('+PM', wFechaIni), 1);  // 001

            FOR j := 1 TO wDiasmes DO BEGIN
                wPosicion := (wDia - 1) + j;
                pDias[wPosicion] [i] := j;
            END;
        END;
    END;

    PROCEDURE MoverCalendario(pCambio: Integer; VAR pMeses: ARRAY[2] OF Option Enero,Febrero,Marzo,Abril,Mayo,Junio,Julio,Agosto,Septiembre,Octubre,Noviembre,Diciembre; VAR pAños: ARRAY[2] OF Integer)
    BEGIN

        CASE pCambio OF
            1:
                BEGIN                                       // Un mes menos
                    if pMeses[1] = pMeses::Enero THEN BEGIN
                        pMeses[1] := pMeses::Diciembre;
                        pAños[1] := pAños[1] - 1;
                    END
                    ELSE
                        pMeses[1] := pMeses[1] - 1;

                    if pMeses[2] = pMeses::Enero THEN BEGIN
                        pMeses[2] := pMeses::Diciembre;
                        pAños[2] := pAños[2] - 1;
                    END
                    ELSE
                        pMeses[2] := pMeses[2] - 1;
                END;
            2:                                       // Un mes mas
                BEGIN
                    if pMeses[1] = pMeses::Diciembre THEN BEGIN
                        pMeses[1] := pMeses::Enero;
                        pAños[1] := pAños[1] + 1
                    END
                    ELSE
                        pMeses[1] := pMeses[1] + 1;

                    if pMeses[2] = pMeses::Diciembre THEN BEGIN
                        pMeses[2] := pMeses::Enero;
                        pAños[2] := pAños[2] + 1
                    END
                    ELSE
                        pMeses[2] := pMeses[2] + 1;
                END;
            3:
                BEGIN                                       // Cambio mes 1
                    if pMeses[1] = pMeses::Diciembre THEN BEGIN
                        pMeses[2] := pMeses::Enero;
                        pAños[2] := pAños[1] + 1;
                    END
                    ELSE BEGIN
                        pMeses[2] := pMeses[1] + 1;
                        pAños[2] := pAños[1];
                    END;
                END;
            4:                                     // Cambio de mes 2
                BEGIN
                    if pMeses[2] = pMeses::Enero THEN BEGIN
                        pMeses[1] := pMeses::Diciembre;
                        pAños[1] := pAños[2] - 1;
                    END
                    ELSE BEGIN
                        pMeses[1] := pMeses[2] - 1;
                        pAños[1] := pAños[2];
                    END;
                END;
        END;
    END;

    PROCEDURE CalcFechaFin(pFechaInicio: Date): Date;
    VAR
        rFecha: Record 2000000007;
    BEGIN

        rFecha.RESET;
        rFecha.SETRANGE(rFecha."Period Type", rFecha."Period Type"::Month);
        rFecha.SETFILTER(rFecha."Period Start", '<= %1', pFechaInicio);
        rFecha.SETFILTER(rFecha."Period End", '>= %1', pFechaInicio);
        if rFecha.FIND('-') THEN
            EXIT(NORMALDATE(rFecha."Period End"));
    END;

    PROCEDURE PushDia(prOrden: Record "Cab. orden publicidad"; pDias: ARRAY[38, 2] OF Integer; pMeses: ARRAY[2] OF Option Enero,Febrero,Marzo,Abril,Mayo,Junio,Julio,Agosto,Septiembre,Octubre,Noviembre,Diciembre; pAños: ARRAY[2] OF Integer; pPosForm: Integer; pMesForm: Integer; pPeriodo: Boolean)
    VAR
        rFechas: Record 2000000007;
        rDiasSel: Record "Dias orden publicidad";
        wFecha: Date;
        wActivar: Boolean;
    BEGIN

        wFecha := DMY2DATE(pDias[pPosForm] [pMesForm], pMeses[pMesForm] + 1, pAños[pMesForm]);
        if pPeriodo THEN BEGIN
            if wFechaIniPeriodo = 0D THEN BEGIN
                wFechaIniPeriodo := wFecha;
                wActivar := NOT rDiasSel.GET(prOrden."Tipo orden", prOrden.No, wFecha);
                ActualizarDiaOrden(prOrden, wFecha, wActivar);
            END
            ELSE BEGIN
                PushPeriodo(prOrden, pDias, pMeses, pAños, pPosForm, pMesForm);
                CLEAR(wFechaIniPeriodo);
            END;
        END
        ELSE BEGIN
            wActivar := NOT rDiasSel.GET(prOrden."Tipo orden", prOrden.No, wFecha);
            ActualizarDiaOrden(prOrden, wFecha, wActivar);
            CLEAR(wFechaIniPeriodo);
        END;

        //  cMedios.BorrarLineasOrden(prOrden);
        //  cMedios.GenerarLineasOrden(prOrden);
    END;

    PROCEDURE PushDiaSemana(prOrden: Record "Cab. orden publicidad"; pDias: ARRAY[38, 2] OF Integer; pMeses: ARRAY[2] OF Option Enero,Febrero,Marzo,Abril,Mayo,Junio,Julio,Agosto,Septiembre,Octubre,Noviembre,Diciembre; pAños: ARRAY[2] OF Integer; pDiaSemana: Integer; pMesForm: Integer)
    VAR
        rDiasSel: Record "Dias orden publicidad";
        wFecha: Date;
        wActivar: Boolean;
        wTodosActivados: Boolean;
        j: Integer;
        i: Integer;
    BEGIN

        // Si hay algún día desactivado dentro de la seleccion, se activara toda la selección.
        // Si todos los dias estan seleccionados, se desactivadan toda la selección.

        j := 1;
        i := pDiaSemana + ((j - 1) * 7);
        wTodosActivados := TRUE;
        REPEAT
            if pDias[i] [pMesForm] <> 0 THEN BEGIN
                wFecha := DMY2DATE(pDias[i] [pMesForm], pMeses[pMesForm] + 1, pAños[pMesForm]);
                wTodosActivados := rDiasSel.GET(prOrden."Tipo orden", prOrden.No, wFecha);
            END;
            j += 1;
            i := pDiaSemana + ((j - 1) * 7);
        UNTIL (i > 37) OR NOT wTodosActivados;
        wActivar := NOT wTodosActivados;

        j := 1;
        i := pDiaSemana + ((j - 1) * 7);
        REPEAT
            if pDias[i] [pMesForm] <> 0 THEN BEGIN
                wFecha := DMY2DATE(pDias[i] [pMesForm], pMeses[pMesForm] + 1, pAños[pMesForm]);
                ActualizarDiaOrden(prOrden, wFecha, wActivar);
            END;
            j += 1;
            i := pDiaSemana + ((j - 1) * 7);
        UNTIL (i > 37);

        //  cMedios.BorrarLineasOrden(prOrden);
        //  cMedios.GenerarLineasOrden(prOrden);
    END;

    PROCEDURE PushSemana(prOrden: Record "Cab. orden publicidad"; pDias: ARRAY[38, 2] OF Integer; pMeses: ARRAY[2] OF option Enero,Febrero,Marzo,Abril,Mayo,Junio,Julio,Agosto,Septiembre,Octubre,Noviembre,Diciembre; pAños: ARRAY[2] OF Integer; pSemana: Integer; pMesForm: Integer)
    VAR
        rDiasSel: Record "Dias orden publicidad";
        wFecha: Date;
        wActivar: Boolean;
        wTodosActivados: Boolean;
        j: Integer;
        i: Integer;
        wDiaSemana: Date;
    BEGIN

        // {
        // // Marca toda la semana aunque la mitad de la semana este en otro mes.

        //     i := (7 * (pSemana-1)) + 1;     // Primer dia de la semana
        //     if pDias[i][pMesForm] = 0 THEN
        //     i += 6;                       // Ultimo día de la semana

        //     wDiaSemana := DMY2DATE(pDias[i][pMesForm], pMeses[pMesForm]+1, pAños[pMesForm]);
        //     FOR wFecha := CALCDATE( '-PS', wDiaSemana ) TO CALCDATE( '+PS', wDiaSemana ) DO
        //     wTodosActivados := rDiasSel.GET(prOrden."Tipo orden",prOrden.No,wFecha);
        //     wActivar := NOT wTodosActivados;

        //     FOR wFecha := CALCDATE( '-PS', wDiaSemana ) TO CALCDATE( '+PS', wDiaSemana ) DO
        //     ActualizarDiaOrden(prOrden,wFecha,wActivar);
        // }

        // Marca la semana hasta fin de mes

        j := 1;
        i := (7 * (pSemana - 1)) + j;
        wTodosActivados := TRUE;
        REPEAT
            if pDias[i] [pMesForm] <> 0 THEN BEGIN
                wFecha := DMY2DATE(pDias[i] [pMesForm], pMeses[pMesForm] + 1, pAños[pMesForm]);
                wTodosActivados := rDiasSel.GET(prOrden."Tipo orden", prOrden.No, wFecha);
            END;
            j += 1;
            i := (7 * (pSemana - 1)) + j;
        UNTIL (j > 7) OR (i > 37) OR NOT wTodosActivados;
        wActivar := NOT wTodosActivados;

        j := 1;
        i := (7 * (pSemana - 1)) + j;
        REPEAT
            if pDias[i] [pMesForm] <> 0 THEN BEGIN
                wFecha := DMY2DATE(pDias[i] [pMesForm], pMeses[pMesForm] + 1, pAños[pMesForm]);
                ActualizarDiaOrden(prOrden, wFecha, wActivar);
            END;
            j += 1;
            i := (7 * (pSemana - 1)) + j;
        UNTIL (j > 7) OR (i > 37);


        //  cMedios.BorrarLineasOrden(prOrden);
        //  cMedios.GenerarLineasOrden(prOrden);
    END;

    PROCEDURE PushMes(prOrden: Record "Cab. orden publicidad"; pDias: ARRAY[38, 2] OF Integer; pMeses: ARRAY[2] OF option Enero,Febrero,Marzo,Abril,Mayo,Junio,Julio,Agosto,Septiembre,Octubre,Noviembre,Diciembre; pAños: ARRAY[2] OF Integer; pMesForm: Integer)
    VAR
        rDiasSel: Record "Dias tarifa publicidad";
        wFechaIni: Date;
        wFechaFin: Date;
        wFecha: Date;
        wActivar: Boolean;
        wTodosActivados: Boolean;
        i: Integer;
    BEGIN

        wFechaIni := CALCDATE('-PM', DMY2DATE(1, pMeses[pMesForm] + 1, pAños[pMesForm]));
        wFechaFin := CALCDATE('PM', DMY2DATE(1, pMeses[pMesForm] + 1, pAños[pMesForm]));

        wTodosActivados := TRUE;
        wFecha := wFechaIni;
        WHILE (wFecha <= wFechaFin) AND wTodosActivados DO BEGIN
            wTodosActivados := rDiasSel.GET(prOrden."Tipo orden", prOrden.No, wFecha);
            wFecha += 1;
        END;
        wActivar := NOT wTodosActivados;

        FOR wFecha := wFechaIni TO wFechaFin DO
            ActualizarDiaOrden(prOrden, wFecha, wActivar);

        //  cMedios.BorrarLineasOrden(prOrden);
        //  cMedios.GenerarLineasOrden(prOrden);
    END;

    PROCEDURE PushPeriodo(prOrden: Record "Cab. orden publicidad"; pDias: ARRAY[38, 2] OF Integer; pMeses: ARRAY[2] OF option Enero,Febrero,Marzo,Abril,Mayo,Junio,Julio,Agosto,Septiembre,Octubre,Noviembre,Diciembre; pAños: ARRAY[2] OF Integer; pPosForm: Integer; pMesForm: Integer)
    VAR
        rDiasSel: Record "Dias tarifa publicidad";
        wFechaFinPeriodo: Date;
        wFecha: Date;
        wFechaIni: Date;
        wFechaFin: Date;
        wTodosActivados: Boolean;
        wActivar: Boolean;
    BEGIN

        wFechaFin := DMY2DATE(pDias[pPosForm] [pMesForm], pMeses[pMesForm] + 1, pAños[pMesForm]);
        if wFechaIniPeriodo < wFechaFin THEN
            wFechaIni := wFechaIniPeriodo
        ELSE BEGIN
            wFechaIni := wFechaFin;
            wFechaFin := wFechaIniPeriodo;
        END;

        wTodosActivados := TRUE;
        wFecha := wFechaIni;
        WHILE (wFecha <= wFechaFin) AND wTodosActivados DO BEGIN
            wTodosActivados := rDiasSel.GET(prOrden."Tipo orden", prOrden.No, wFecha);
            wFecha += 1;
        END;
        wActivar := NOT wTodosActivados;

        FOR wFecha := wFechaIni TO wFechaFin DO
            ActualizarDiaOrden(prOrden, wFecha, wActivar);
    END;

    PROCEDURE ActualizarDiaOrden(prOrden: Record "Cab. orden publicidad"; pDia: Date; pActivar: Boolean)
    VAR
        rDiasSel: Record "Dias orden publicidad";
        rDiasSel2: Record "Dias orden publicidad";
        rLinOrden: Record "Lin. orden publicidad";
    BEGIN

        if pActivar THEN BEGIN
            if NOT rDiasSel.GET(prOrden."Tipo orden", prOrden.No, pDia) THEN BEGIN
                rDiasSel.INIT;
                rDiasSel."Tipo orden" := prOrden."Tipo orden";
                rDiasSel."No. orden" := prOrden.No;
                rDiasSel.VALIDATE(Dia, pDia);
                //      EVALUATE(rDiasSel."Dia semana", FORMAT(pDia,0,'<WeekDay>'));
                rDiasSel.INSERT;
            END;
            cMedios.GenerarLineasOrden(prOrden, pDia, pDia, 0);
        END
        ELSE
            if rDiasSel.GET(prOrden."Tipo orden", prOrden.No, pDia) THEN BEGIN
                if rDiasSel.Periodo THEN BEGIN
                    if CONFIRM(txt01, FALSE, rDiasSel."Inicio periodo", rDiasSel."Fin periodo") THEN BEGIN
                        rDiasSel2.RESET;
                        rDiasSel2.SETRANGE("Tipo orden", rDiasSel."Tipo orden");
                        rDiasSel2.SETRANGE("No. orden", rDiasSel."No. orden");
                        rDiasSel2.SETRANGE(Dia, rDiasSel."Inicio periodo", rDiasSel."Fin periodo");
                        if rDiasSel2.FIND('-') THEN BEGIN
                            rDiasSel2.DELETEALL;
                            cMedios.BorrarLineaOrden(prOrden, rDiasSel."Inicio periodo");
                        END;
                    END;
                END
                ELSE BEGIN
                    rDiasSel.DELETE;
                    cMedios.BorrarLineaOrden(prOrden, pDia);
                END;
            END;
    END;

}