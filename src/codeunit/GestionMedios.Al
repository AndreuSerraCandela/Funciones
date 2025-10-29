/// <summary>
/// Codeunit Gestion medios (ID 50005).
/// </summary>
codeunit 50005 "Gestion medios"
{

    VAR
        rCabOrdPub: Record "Cab. orden publicidad";
        rLinOrdPub: Record "Lin. orden publicidad";
        rComOrdPub: Record "Comentario orden publicidad";
        rDiasOrdPub: Record "Dias orden publicidad";
        Err01: Label 'No se han encontrado tarifas para \\ Medio: %1.\\ Fecha: %2.\\ Seccion: %3.\\ Tamaño: %4.';
        Err02: Label 'No se han encontrado tarifas para \\ Medio: %1.\\ Fecha: %2.\\ Concepto: %3.';
        Err03: Label 'Carece de permisos para visualizar datos de la delegación %1.';
        txt01: Label 'Se ha insertado la linea con fecha anterior al día de trabajo.';
        rTexOrdPub: Record "Texto orden publicidad";

    PROCEDURE RegistrarOrden(prOrden: Record "Cab. orden publicidad");
    BEGIN
        /* {
          WITH prOrden DO
          BEGIN

            CASE "Tipo orden" OF
              "Tipo orden"::Prensa :
              BEGIN
                rCabOrdPrensa.INIT;
                rCabOrdPrensa.TRANSFERFIELDS(prOrden);
                rCabOrdPrensa.INSERT;

                rLinOrdPub.RESET;
                rLinOrdPub.SETRANGE("Tipo orden", "Tipo orden");
                rLinOrdPub.SETRANGE("No. orden", No);
                if rLinOrdPub.FIND('-') THEN
                REPEAT
                  rLinOrdPrensa.INIT;
                  rLinOrdPrensa.TRANSFERFIELDS(rLinOrdPub);
                  rLinOrdPrensa.INSERT;
                UNTIL rLinOrdPub.NEXT = 0;

                rDiasOrdPub.RESET;
                rDiasOrdPub.SETRANGE("Tipo orden", "Tipo orden");
                rDiasOrdPub.SETRANGE("No. orden", No);
                if rDiasOrdPub.FIND('-') THEN
                REPEAT
                  rDiasOrdPrensa.INIT;
                  rDiasOrdPrensa.TRANSFERFIELDS(rDiasOrdPub);
                  rDiasOrdPrensa.INSERT;
                UNTIL rDiasOrdPub.NEXT = 0;

                rComOrdPub.RESET;
                rComOrdPub.SETRANGE("Tipo orden", "Tipo orden");
                rComOrdPub.SETRANGE("No.", No);
                if rComOrdPub.FIND('-') THEN
                REPEAT
                  rComOrdPrensa.INIT;
                  rComOrdPrensa.TRANSFERFIELDS(rComOrdPub);
                  rComOrdPrensa.INSERT;
                UNTIL rComOrdPub.NEXT = 0;

                //$003-
                rTexOrdPub.RESET;
                rTexOrdPub.SETRANGE("Tipo orden", "Tipo orden");
                rTexOrdPub.SETRANGE("No.", No);
                if rTexOrdPub.FIND('-') THEN
                REPEAT
                  rTexOrdPrensa.INIT;
                  rTexOrdPrensa.TRANSFERFIELDS(rTexOrdPub);
                  rTexOrdPrensa.INSERT;
                UNTIL rTexOrdPub.NEXT = 0;
                //$003+

              END;
              "Tipo orden"::Radio :
              BEGIN

                rCabOrdRadio.INIT;
                rCabOrdRadio.TRANSFERFIELDS(prOrden);
                rCabOrdRadio.INSERT;

                rLinOrdPub.RESET;
                rLinOrdPub.SETRANGE("Tipo orden", "Tipo orden");
                rLinOrdPub.SETRANGE("No. orden", No);
                if rLinOrdPub.FIND('-') THEN
                REPEAT
        //          rLinOrdPub.TESTFIELD(rLinOrdPub."Fecha inicio");
        //          rLinOrdPub.TESTFIELD(rLinOrdPub."Fecha fin");
        //          rLinOrdPub.TESTFIELD(rLinOrdPub.Importe);  //GRC170106, el importe de la línea puede ser 0
                  rLinOrdRadio.INIT;
                  rLinOrdRadio.TRANSFERFIELDS(rLinOrdPub);
                  rLinOrdRadio.INSERT;
                UNTIL rLinOrdPub.NEXT = 0;

                rDiasOrdPub.RESET;
                rDiasOrdPub.SETRANGE("Tipo orden", "Tipo orden");
                rDiasOrdPub.SETRANGE("No. orden", No);
                if rDiasOrdPub.FIND('-') THEN
                REPEAT
                  rDiasOrdRadio.INIT;
                  rDiasOrdRadio.TRANSFERFIELDS(rDiasOrdPub);
                  rDiasOrdRadio.INSERT;
                UNTIL rDiasOrdPub.NEXT = 0;

                rComOrdPub.RESET;
                rComOrdPub.SETRANGE("Tipo orden", "Tipo orden");
                rComOrdPub.SETRANGE("No.", No);
                if rComOrdPub.FIND('-') THEN
                REPEAT
                  rComOrdRadio.INIT;
                  rComOrdRadio.TRANSFERFIELDS(rComOrdPub);
                  rComOrdRadio.INSERT;
                UNTIL rComOrdPub.NEXT = 0;

                //$003-
                rTexOrdPub.RESET;
                rTexOrdPub.SETRANGE("Tipo orden", "Tipo orden");
                rTexOrdPub.SETRANGE("No.", No);
                if rTexOrdPub.FIND('-') THEN
                REPEAT
                  rTexOrdRadio.INIT;
                  rTexOrdRadio.TRANSFERFIELDS(rTexOrdPub);
                  rTexOrdRadio.INSERT;
                UNTIL rTexOrdPub.NEXT = 0;
                //$003+

              END;
              "Tipo orden"::Audiovisuales :
              BEGIN

                rCabOrdCine.INIT;
                rCabOrdCine.TRANSFERFIELDS(prOrden);
                rCabOrdCine.INSERT;

                rLinOrdPub.RESET;
                rLinOrdPub.SETRANGE("Tipo orden", "Tipo orden");
                rLinOrdPub.SETRANGE("No. orden", No);
                if rLinOrdPub.FIND('-') THEN
                REPEAT
        //          rLinOrdPub.TESTFIELD(rLinOrdPub."Fecha inicio");
        //          rLinOrdPub.TESTFIELD(rLinOrdPub."Fecha fin");
        //          rLinOrdPub.TESTFIELD(rLinOrdPub.Importe);  //grc170106, quito el control de importe 0
                  rLinOrdCine.INIT;
                  rLinOrdCine.TRANSFERFIELDS(rLinOrdPub);
                  rLinOrdCine.INSERT;
                UNTIL rLinOrdPub.NEXT = 0;

                rDiasOrdPub.RESET;
                rDiasOrdPub.SETRANGE("Tipo orden", "Tipo orden");
                rDiasOrdPub.SETRANGE("No. orden", No);
                if rDiasOrdPub.FIND('-') THEN
                REPEAT
                  rDiasOrdCine.INIT;
                  rDiasOrdCine.TRANSFERFIELDS(rDiasOrdPub);
                  rDiasOrdCine.INSERT;
                UNTIL rDiasOrdPub.NEXT = 0;

                rComOrdPub.RESET;
                rComOrdPub.SETRANGE("Tipo orden", "Tipo orden");
                rComOrdPub.SETRANGE("No.", No);
                if rComOrdPub.FIND('-') THEN
                REPEAT
                  rComOrdCine.INIT;
                  rComOrdCine.TRANSFERFIELDS(rComOrdPub);
                  rComOrdCine.INSERT;
                UNTIL rComOrdPub.NEXT = 0;

                //$003-
                rTexOrdPub.RESET;
                rTexOrdPub.SETRANGE("Tipo orden", "Tipo orden");
                rTexOrdPub.SETRANGE("No.", No);
                if rTexOrdPub.FIND('-') THEN
                REPEAT
                  rTexOrdCine.INIT;
                  rTexOrdCine.TRANSFERFIELDS(rTexOrdPub);
                  rTexOrdCine.INSERT;
                UNTIL rTexOrdPub.NEXT = 0;
                //$003+

              END;
            END;
            rLinOrdPub.DELETEALL;
            rDiasOrdPub.DELETEALL;
            rComOrdPub.DELETEALL;
            rTexOrdPub.DELETEALL;
            DELETE;
          END;
          } */
    END;

    PROCEDURE GenerarLineasOrden(prOrden: Record "Cab. orden publicidad"; pFechaIni: Date; pFechaFin: Date; pImporteManual: Decimal);
    VAR
        rLinOrden: Record "Lin. orden publicidad";
        rDiasOrden: Record "Dias orden publicidad";
        rDiasTar: Record "Dias tarifa publicidad";
        rDiasTar2: Record "Dias tarifa publicidad";
        wImporte: Decimal;
        wAntLinOrden: Integer;
        wAntDiaTarifa: Code[20];
        wCodDiaTar: Code[10];
        Err02: Label 'No se han encontrado tarifas para \\ Medio: %1.\\ Dia: %2.';
    BEGIN

        //  WITH prOrden DO BEGIN
        if pImporteManual = 0 THEN BEGIN

            rDiasOrden.RESET;
            rDiasOrden.SETRANGE("Tipo orden", prOrden."Tipo orden");
            rDiasOrden.SETRANGE("No. orden", prOrden.No);
            rDiasOrden.SETRANGE(rDiasOrden.Periodo, FALSE);
            if pFechaIni <> 0D THEN
                rDiasOrden.SETFILTER(Dia, '>=%1', pFechaIni);
            if pFechaFin <> 0D THEN
                rDiasOrden.SETFILTER(Dia, '<=%1', pFechaFin);
            if rDiasOrden.FIND('-') THEN
                REPEAT

                    rLinOrden.RESET;
                    rLinOrden.SETRANGE("Tipo orden", prOrden."Tipo orden");
                    rLinOrden.SETRANGE("No. orden", prOrden.No);
                    rLinOrden.SETRANGE("Fecha inicio", rDiasOrden.Dia);
                    if NOT rLinOrden.FIND('-') THEN BEGIN
                        // Si no existe rlinorden la crea
                        rDiasTar.RESET;
                        rDiasTar.SETRANGE(rDiasTar."Cod. Soporte", prOrden."Cod. Soporte");
                        rDiasTar.SETRANGE(rDiasTar.Conjunto, TRUE);
                        rDiasTar.SETRANGE(rDiasTar.Seccion, prOrden.Seccion);  //grc240505, los dias van por seccion
                        CASE rDiasOrden."Dia semana" OF
                            rDiasOrden."Dia semana"::Lunes:
                                rDiasTar.SETRANGE(rDiasTar.Lunes, TRUE);
                            rDiasOrden."Dia semana"::Martes:
                                rDiasTar.SETRANGE(rDiasTar.Martes, TRUE);
                            rDiasOrden."Dia semana"::Miercoles:
                                rDiasTar.SETRANGE(rDiasTar.Miercoles, TRUE);
                            rDiasOrden."Dia semana"::Jueves:
                                rDiasTar.SETRANGE(rDiasTar.Jueves, TRUE);
                            rDiasOrden."Dia semana"::Viernes:
                                rDiasTar.SETRANGE(rDiasTar.Viernes, TRUE);
                            rDiasOrden."Dia semana"::Sabado:
                                rDiasTar.SETRANGE(rDiasTar.Sabado, TRUE);
                            rDiasOrden."Dia semana"::Domingo:
                                rDiasTar.SETRANGE(rDiasTar.Domingo, TRUE);
                        END;
                        // Conjunto
                        if rDiasTar.FIND('-') THEN BEGIN
                            if BuscarDiasConjunto(prOrden, rDiasOrden.Dia, rDiasOrden."Dia semana".AsInteger(), rDiasTar) THEN BEGIN
                                InsertarLineaOrden(prOrden, rDiasTar.Codigo, rDiasOrden.Dia);
                                ModificarLineasConjunto(prOrden, rDiasOrden.Dia, rDiasOrden."Dia semana".AsInteger(), rDiasTar);
                            END ELSE BEGIN
                                rDiasTar2.RESET;
                                rDiasTar2.SETVIEW(rDiasTar.GETVIEW);
                                rDiasTar2.SETRANGE(rDiasTar2.Seccion, prOrden.Seccion);  //grc240505, los dias van por seccion
                                rDiasTar2.SETRANGE(Conjunto, FALSE);
                                if rDiasTar2.FIND('-') THEN BEGIN
                                    REPEAT
                                        InsertarLineaOrden(prOrden, rDiasTar2.Codigo, rDiasOrden.Dia)
                                    UNTIL rDiasTar2.NEXT = 0;
                                END ELSE
                                    InsertarLineaOrden(prOrden, rDiasTar.Codigo, rDiasOrden.Dia);
                            END;
                        END ELSE BEGIN
                            // No es conjunto
                            rDiasTar.SETRANGE(Conjunto, FALSE);
                            if rDiasTar.FIND('-') THEN BEGIN
                                REPEAT
                                    InsertarLineaOrden(prOrden, rDiasTar.Codigo, rDiasOrden.Dia)
                                UNTIL rDiasTar.NEXT = 0;
                            END ELSE
                                CASE prOrden."Tipo orden" OF
                                    //$006(I)
                                    //prOrden."Tipo orden"::Prensa : ERROR(Err01,"Cod. Soporte", rDiasOrden.Dia, Seccion, Concepto);
                                    prOrden."Tipo orden"::Prensa:
                                        InsertarLineaOrden(prOrden, '', rDiasOrden.Dia);
                                    //$006(F)
                                    prOrden."Tipo orden"::Radio:
                                        InsertarLineaOrden(prOrden, '', rDiasOrden.Dia);
                                    prOrden."Tipo orden"::Audiovisuales:
                                        InsertarLineaOrden(prOrden, '', rDiasOrden.Dia);
                                END;
                        END;
                    END;
                UNTIL rDiasOrden.NEXT = 0;
        END
        ELSE BEGIN
            rLinOrden.RESET;
            rLinOrden.SETRANGE(rLinOrden."Tipo orden", prOrden."Tipo orden");
            rLinOrden.SETRANGE(rLinOrden."No. orden", prOrden.No);
            rLinOrden.SETRANGE(rLinOrden."Fecha inicio", pFechaIni);
            rLinOrden.SETRANGE(rLinOrden."Fecha fin", pFechaFin);
            if rLinOrden.FIND('-') THEN BEGIN
                if prOrden."Tipo orden" <> "Tipo orden"::Prensa THEN               //$002
                    rLinOrden.Precio := pImporteManual;                      //
                rLinOrden.Importe := pImporteManual;
                rLinOrden."Importe manual" := TRUE;
                rLinOrden.MODIFY;
            END
            ELSE BEGIN
                rLinOrden.INIT;
                rLinOrden."Tipo orden" := prOrden."Tipo orden";
                rLinOrden."No. orden" := prOrden.No;
                rLinOrden."No. linea" := rLinOrden.UltLinea + 1000;
                rLinOrden.Concepto := prOrden.Concepto;
                rLinOrden.Ancho := prOrden.Ancho;
                rLinOrden.Alto := prOrden.Alto;
                rLinOrden."Fecha inicio" := pFechaIni;
                rLinOrden."Fecha fin" := pFechaFin;
                rLinOrden.Inserciones := pFechaFin - pFechaIni + 1;
                if prOrden."Tipo orden" <> "Tipo orden"::Prensa THEN               //$002
                    rLinOrden.Precio := pImporteManual
                ELSE BEGIN
                    rLinOrden.Precio := ROUND(pImporteManual / rLinOrden.Inserciones, 0.00001);  // $004
                END;
                rLinOrden.VALIDATE(Importe, pImporteManual);
                rLinOrden."Importe manual" := TRUE;
                rLinOrden.INSERT(TRUE);
            END;
        END;
        //  END;
    END;

    PROCEDURE InsertarLineaOrden(prOrden: Record "Cab. orden publicidad"; pCodDiaTar: Code[20]; pDia: Date);
    VAR
        rLinTarOrd: Record "Tarifas orden publicidad";
        // rLinTar: Record 7012;
        rLinOrden: Record "Lin. orden publicidad";
        rConceptos: Record 27;
        rConfig: Record 315;
    BEGIN

        // WITH prOrden DO BEGIN
        CASE prOrden."Tipo orden" OF
            prOrden."Tipo orden"::Prensa:
                BEGIN
                    rLinOrden.INIT;
                    rLinOrden."Tipo orden" := prOrden."Tipo orden";
                    rLinOrden."No. orden" := prOrden.No;
                    rLinOrden."No. linea" := rLinOrden.UltLinea + 1000;
                    rLinOrden.Concepto := prOrden.Concepto;
                    rLinOrden."Dia tarifa" := pCodDiaTar;
                    rLinOrden.Ancho := prOrden.Ancho;
                    rLinOrden.Alto := prOrden.Alto;
                    rLinOrden."Fecha inicio" := pDia;
                    rLinOrden."Fecha fin" := pDia;
                    rLinOrden.Inserciones := rLinOrden."Fecha fin" - rLinOrden."Fecha inicio" + 1;
                    rLinOrden.Recargo := prOrden.Recargo;
                    if rLinOrden."Dia tarifa" <> '' THEN BEGIN
                        if rLinTarOrd.GET(prOrden."Tipo orden", prOrden.No, pCodDiaTar) THEN BEGIN
                            if rLinTarOrd.Precio <> 0 THEN
                                rLinOrden.VALIDATE(Precio, rLinTarOrd.Precio)
                            ELSE
                                CLEAR(rLinOrden."Dia tarifa");
                        END
                        ELSE
                            CLEAR(rLinOrden."Dia tarifa");
                    END;
                    //$005 , aqui no procede
                    /* //if (rLinOrden.Importe <> 0)  THEN         $006
                        rLinOrden.INSERT(TRUE);
                    END;
                    prOrden."Tipo orden"::Radio :
                    BEGIN
                      rLinOrden.INIT;
                      rLinOrden."Tipo orden" := "Tipo orden";
                      rLinOrden."No. orden" := No;
                      rLinOrden."No. linea" := rLinOrden.UltLinea + 1000;
                      rLinOrden."Fecha inicio" := pDia;
                      rLinOrden."Fecha fin" := pDia;
                      rLinOrden.Inserciones := rLinOrden."Fecha fin" - rLinOrden."Fecha inicio" + 1;
                      rLinOrden."Dia tarifa" := pCodDiaTar;
                      rLinOrden.Concepto := Concepto;
                      { Duracion no existe
                      rLinOrden.Duracion := Duracion;
                      if rConceptos.GET(Concepto) THEN
                      BEGIN
                        if rLinOrden.Duracion > rConceptos.Duracion THEN
                          rLinOrden."Tiempo extra" := rLinOrden.Duracion - rConceptos.Duracion;
                        if rLinOrden."Tiempo extra" <> 0 THEN
                        BEGIN
                          rConfig.GET;
                          rConfig.TESTFIELD(rConfig."Concepto tiempo extra radio");
                          if rLinTar.GET("Cod. medio",CALCDATE( '-PA', pDia),Seccion,rConfig."Concepto tiempo extra radio",pCodDiaTar) THEN
                            rLinOrden."Precio extra" := rLinTar."Direct Unit Cost";
                        END;
                      END;
                      } */
                    rLinOrden."Fecha inicio" := pDia;
                    rLinOrden."Fecha fin" := pDia;
                    if rLinTarOrd.GET(prOrden."Tipo orden", prOrden.No, pCodDiaTar) THEN
                        rLinOrden.VALIDATE(Precio, rLinTarOrd.Precio);
                    //$005  if rLinOrden.Importe <> 0 THEN
                    rLinOrden.INSERT(TRUE);
                END;

            prOrden."Tipo orden"::Audiovisuales:
                BEGIN
                    rLinOrden.INIT;
                    rLinOrden."Tipo orden" := prOrden."Tipo orden";
                    rLinOrden."No. orden" := prOrden.No;
                    rLinOrden."No. linea" := rLinOrden.UltLinea + 1000;
                    rLinOrden."Fecha inicio" := pDia;
                    rLinOrden."Fecha fin" := pDia;
                    rLinOrden.Inserciones := rLinOrden."Fecha fin" - rLinOrden."Fecha inicio" + 1;
                    rLinOrden."Dia tarifa" := pCodDiaTar;
                    rLinOrden.Concepto := prOrden.Concepto;
                    rLinOrden.Duracion := prOrden.Duracion;
                    rLinOrden."Fecha inicio" := pDia;
                    rLinOrden."Fecha fin" := pDia;
                    if rLinTarOrd.GET(prOrden."Tipo orden", prOrden.No, pCodDiaTar) THEN
                        rLinOrden.VALIDATE(Precio, rLinTarOrd.Precio);
                    //$005  if rLinOrden.Importe <> 0 THEN
                    rLinOrden.INSERT(TRUE);

                END;
        END;
        //    if pDia < WORKDATE THEN
        //      MESSAGE(txt01);
        // END;
    END;

    PROCEDURE BuscarDiasConjunto(prOrden: Record "Cab. orden publicidad"; pDia: Date; pDiaSemana: Integer; prDiasTar: Record "Dias tarifa publicidad"): Boolean;
    VAR
        rDiasOrden: Record "Dias orden publicidad";
        wDiasConjunto: ARRAY[7] OF Date;
        wEstanTodos: Boolean;
        i: Integer;
    BEGIN

        // Comprueba que todos los días del conjunto esten marcados.
        // Para que funcione correctamente es necesario que los días del conjunto esten dentro de la misma semana.

        //$007(I)
        //if prDiasTar.Lunes THEN     wDiasConjunto[1] := pDia - pDiaSemana + 1;
        if prDiasTar.Lunes THEN BEGIN
            if DATE2DWY(pDia, 1) <> 7 THEN
                wDiasConjunto[1] := pDia - pDiaSemana + 1
            ELSE
                wDiasConjunto[1] := pDia - pDiaSemana + 8;
        END;
        //$007(F)
        if prDiasTar.Martes THEN wDiasConjunto[2] := pDia - pDiaSemana + 2;
        if prDiasTar.Miercoles THEN wDiasConjunto[3] := pDia - pDiaSemana + 3;
        if prDiasTar.Jueves THEN wDiasConjunto[4] := pDia - pDiaSemana + 4;
        if prDiasTar.Viernes THEN wDiasConjunto[5] := pDia - pDiaSemana + 5;
        if prDiasTar.Sabado THEN wDiasConjunto[6] := pDia - pDiaSemana + 6;
        //$007(I)
        //if prDiasTar.Domingo THEN   wDiasConjunto[7] := pDia - pDiaSemana + 7;
        if prDiasTar.Domingo THEN BEGIN
            if DATE2DWY(pDia, 1) <> 1 THEN
                wDiasConjunto[7] := pDia - pDiaSemana + 7
            ELSE
                wDiasConjunto[7] := pDia - pDiaSemana;
        END;
        //$007(F)

        wEstanTodos := TRUE;
        REPEAT
            i += 1;
            if wDiasConjunto[i] <> 0D THEN
                wEstanTodos := rDiasOrden.GET(prOrden."Tipo orden", prOrden.No, wDiasConjunto[i]);
        UNTIL (i = 7) OR NOT wEstanTodos;

        EXIT(wEstanTodos);
    END;

    PROCEDURE ModificarLineasConjunto(prOrden: Record "Cab. orden publicidad"; pDia: Date; pDiaSemana: Integer; prDiasTar: Record "Dias tarifa publicidad");
    VAR
        rLinOrden: Record "Lin. orden publicidad";
        rLinTarifas: Record "Tarifas orden publicidad";
        wDiasConjunto: ARRAY[7] OF Date;
        wPrimerDia: Date;
        i: Integer;
    BEGIN

        //$007(I)
        //if prDiasTar.Lunes THEN     wDiasConjunto[1] := pDia - pDiaSemana + 1;
        if prDiasTar.Lunes THEN BEGIN
            if DATE2DWY(pDia, 1) <> 7 THEN
                wDiasConjunto[1] := pDia - pDiaSemana + 1
            ELSE
                wDiasConjunto[1] := pDia - pDiaSemana + 8;
        END;
        //$007(F)
        if prDiasTar.Martes THEN wDiasConjunto[2] := pDia - pDiaSemana + 2;
        if prDiasTar.Miercoles THEN wDiasConjunto[3] := pDia - pDiaSemana + 3;
        if prDiasTar.Jueves THEN wDiasConjunto[4] := pDia - pDiaSemana + 4;
        if prDiasTar.Viernes THEN wDiasConjunto[5] := pDia - pDiaSemana + 5;
        if prDiasTar.Sabado THEN wDiasConjunto[6] := pDia - pDiaSemana + 6;
        //$007(I)
        //if prDiasTar.Domingo THEN   wDiasConjunto[7] := pDia - pDiaSemana + 7;
        if prDiasTar.Domingo THEN BEGIN
            if DATE2DWY(pDia, 1) <> 1 THEN
                wDiasConjunto[7] := pDia - pDiaSemana + 7
            ELSE
                wDiasConjunto[7] := pDia - pDiaSemana;
        END;
        //$007(F)

        CLEAR(wPrimerDia);
        FOR i := 1 TO 7 DO BEGIN
            if wDiasConjunto[i] <> 0D THEN BEGIN
                rLinOrden.RESET;
                rLinOrden.SETRANGE("Tipo orden", prOrden."Tipo orden");
                rLinOrden.SETRANGE("No. orden", prOrden.No);
                rLinOrden.SETRANGE("Fecha inicio", wDiasConjunto[i]);
                rLinOrden.SETRANGE("Fecha fin", wDiasConjunto[i]);
                rLinOrden.SETRANGE("Importe manual", FALSE);
                rLinOrden.SETFILTER("Dia tarifa", '<>%1', '');          //$001
                if rLinOrden.FIND('-') THEN BEGIN
                    rLinOrden."Dia tarifa" := prDiasTar.Codigo;
                    if wPrimerDia = 0D THEN BEGIN
                        if rLinTarifas.GET(prOrden."Tipo orden", prOrden.No, prDiasTar.Codigo) THEN
                            rLinOrden.VALIDATE(Precio, rLinTarifas.Precio);
                        rLinOrden."Dia conjunto" := rLinOrden."Fecha inicio";
                        wPrimerDia := rLinOrden."Dia conjunto";
                    END
                    ELSE BEGIN
                        rLinOrden.VALIDATE(Precio, 0);
                        rLinOrden."Dia conjunto" := wPrimerDia;
                    END;
                    rLinOrden.MODIFY;
                END;
            END;
        END;
    END;

    PROCEDURE BorrarLineasOrden(prOrden: Record "Cab. orden publicidad");
    VAR
        rLinOrden: Record "Lin. orden publicidad";
    BEGIN

        rLinOrden.RESET;
        rLinOrden.SETRANGE(rLinOrden."Tipo orden", prOrden."Tipo orden");
        rLinOrden.SETRANGE(rLinOrden."No. orden", prOrden.No);
        rLinOrden.SETRANGE(rLinOrden."Importe manual", FALSE);
        if rLinOrden.FIND('-') THEN
            rLinOrden.DELETEALL;
    END;

    PROCEDURE BorrarLineaOrden(prOrden: Record "Cab. orden publicidad"; pFecha: Date);
    VAR
        rLinOrden: Record "Lin. orden publicidad";
    BEGIN

        rLinOrden.RESET;
        rLinOrden.SETRANGE(rLinOrden."Tipo orden", prOrden."Tipo orden");
        rLinOrden.SETRANGE(rLinOrden."No. orden", prOrden.No);
        rLinOrden.SETRANGE("Fecha inicio", pFecha);
        if rLinOrden.FIND('-') THEN
            rLinOrden.DELETE(TRUE);
    END;

    PROCEDURE DividirTexto(texPrmEntrada: Text[60]; VAR texPrmSalida: ARRAY[2] OF Text[60]; intPrmMax: Integer);
    VAR
        intPos: Integer;
        i: Integer;
    BEGIN
        // Divide la cadena de texto en dos partes si es muy larga.
        CLEAR(texPrmSalida);
        if STRLEN(texPrmEntrada) > intPrmMax THEN BEGIN
            FOR i := 1 TO intPrmMax DO
                if texPrmEntrada[i] = ' ' THEN
                    intPos := i;
            if intPos = 0 THEN
                FOR i := 1 TO intPrmMax DO
                    if texPrmEntrada[i] = '-' THEN
                        intPos := i;
            if intPos = 0 THEN
                FOR i := 1 TO intPrmMax DO
                    if texPrmEntrada[i] = ',' THEN
                        intPos := i;
            if intPos = 0 THEN
                intPos := intPrmMax;
            texPrmSalida[1] := COPYSTR(texPrmEntrada, 1, intPos);
            texPrmSalida[2] := COPYSTR(texPrmEntrada, intPos + 1, MAXSTRLEN(texPrmSalida[2]));
        END
        ELSE
            texPrmSalida[1] := COPYSTR(texPrmEntrada, 1, MAXSTRLEN(texPrmSalida[1]));
    END;

    PROCEDURE CortarTexto(texPrmEntrada: Text[60]; intPrmMax: Integer): Text[60];
    VAR
        texSalida: ARRAY[2] OF Text[60];
    BEGIN
        DividirTexto(texPrmEntrada, texSalida, intPrmMax);
        EXIT(texSalida[1]);
    END;

    PROCEDURE TraerCuentaVentas(codPrmCliente: Code[20]): Text[20];
    VAR
        recCabVenta: Record 36;
        recCliente: Record Customer;
        recCfgGrupCont: Record 252;
    BEGIN
        if recCliente.GET(codPrmCliente) THEN BEGIN
            recCliente.TESTFIELD("Gen. Bus. Posting Group");
            recCfgGrupCont.RESET;
            recCfgGrupCont.SETRANGE("Gen. Bus. Posting Group", recCliente."Gen. Bus. Posting Group");
            if recCfgGrupCont.FIND('-') THEN
                EXIT(recCfgGrupCont."Sales Account");
        END;
    END;

    /*  BEGIN
     {
       $001 24/11/05 JML : Cuando se inserta la línea de la orden, si no existe tarifa o es cero no se guarda el campo "Dia tarifa".
       $002 19/01/06 JML : Guardar precio en ordenes radio y cine cuando es importe manual. Si na hay tarifa crear líneas sin precio.
       $003 14/02/08 JML : Traspaso texto anuncio al histórico.
       $004 MNC 250110 Calcula precio individual cuando es importe manual
       $005 MNC 250210 Aunque sea 0, la linea debe crearse, solo para radio y audiovisuales
       $006 FCL 160310 Aunque sea 0, la línea debe crearse para prensa. Se trata del caso en que no hay tarifa.
       $007 FCL 170810 Trato la excepción D+L (el lunes será de la siguiente semana, nunca de la misma).

                 PENDIENTE destapar funcion RegistrarOrden si es necesario
     }
     END.
   } */
}