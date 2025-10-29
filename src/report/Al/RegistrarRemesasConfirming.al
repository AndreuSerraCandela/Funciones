/// <summary>
/// Report Registrar remesas confirming (ID 50004).
/// </summary>
report 50003 "Registrar remesas confirming"
{
    UseRequestPage = false;
    ProcessingOnly = true;
    //No se usa
    dataset
    {
        dataitem(NoRemesa; "Cab. borrador pagare")
        {

            dataitem("Cartera Doc."; "Cartera Doc.")
            {
                DataItemLink = "Bill Gr./Pmt. Order No." = field("Cód. pagaré");
            }
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
                }
            }
        }
        actions
        {
            area(processing)
            {
            }
        }
    }
    VAR
        ConfVtas: Record 311;
        Proyecto: Record 167;
        rPresup: Record 1003;
        rCab: Record 36;
        rLin: Record 37;
        rGCP: Record 251;
        rGCN: Record 250;
        rCGC: Record 252;
        rFamilia: Record 152;
        rComentVenta: Record 44;
        rComentProy: Record 97;
        rRecurs: Record 156;
        rClient: Record Customer;
        rTexto: Record "Texto Presupuesto";
        rOrden: Record "Cab. orden publicidad";
        rLinOrden: Record "Lin. orden publicidad";
        rRecurso: Record 156;
#if CLEAN24
#pragma warning disable AL0432
        GestNoSer: Codeunit NoSeriesManagement;
#pragma warning restore AL0432
#else
        GestNoSer: Codeunit "No. Series";
#endif
        ult: Integer;

    PROCEDURE Coge_Registros(VAR rP: Record 167; VAR rL: Record 1003);
    BEGIN
        Proyecto := rP;
        Proyecto.COPYFILTERS(rP);
        rPresup := rL;
        rPresup.COPYFILTERS(rL);
    END;

    PROCEDURE Lineas_Dias();
    VAR
        wDiasAux: Code[10];
        wDescAux: Text[60];
        wMes: Text[30];
        wPrimero: Boolean;
        wPorDias: Boolean;
    BEGIN
        //$005. Sustituyo el formato de estas líneas.
        /* {
        CLEAR(rLinOrden);
        CLEAR(wDescAux);
        rLinOrden.SETCURRENTKEY("Tipo orden","No. orden","Dia tarifa",Concepto,"Fecha inicio");
        rLinOrden.SETRANGE("No. orden", rOrden.No);
        CLEAR(wDiasAux);
        if rLinOrden.FINDSET THEN REPEAT
          wPrimero := FALSE;
          if (rLinOrden."Dia tarifa" <> wDiasAux) THEN BEGIN
            if (wDiasAux <> '') THEN BEGIN
              Inserta_Linea(wDescAux);
              CLEAR(wDescAux);
            END;
            wDiasAux := rLinOrden."Dia tarifa";
            wDescAux := STRSUBSTNO('(%1): ', rLinOrden."Dia tarifa");
            wPrimero := TRUE;
          END;
          if NOT wPrimero THEN
            wDescAux += ',';
          wDescAux += FORMAT(rLinOrden."Fecha inicio");
          if (STRLEN(wDescAux)>=41) THEN BEGIN
            Inserta_Linea(wDescAux);
            CLEAR(wDescAux);
          END;
        UNTIL rLinOrden.NEXT = 0;
        Inserta_Linea(wDescAux);
        } */

        CLEAR(rLinOrden);
        CLEAR(wDescAux);
        CLEAR(wDiasAux);
        wPrimero := FALSE;
        wPorDias := FALSE;
        rLinOrden.RESET;
        rLinOrden.SETCURRENTKEY("Tipo orden", "No. orden", "Fecha inicio");  //Se incluyen todas las fechas
        rLinOrden.SETRANGE("No. orden", rOrden.No);
        ////rLinOrden.SETFILTER(Precio, '<>%1', 0);                        //$007
        rLinOrden.SETFILTER(Inserciones, '>%1', 1);
        if rLinOrden.FINDFIRST THEN BEGIN
            wPorDias := TRUE;
            rLinOrden.SETRANGE(Inserciones);
        END
        ELSE BEGIN
            rLinOrden.SETRANGE(Inserciones);
            rLinOrden.SETFILTER(Observaciones, '<>%1', '');
            if rLinOrden.FINDFIRST THEN BEGIN
                wPorDias := TRUE;
            END;
            rLinOrden.SETRANGE(Observaciones);
        END;

        if rLinOrden.FINDSET THEN
            REPEAT
                if wPorDias THEN BEGIN
                    if wDescAux <> '' THEN
                        wDescAux := wDescAux + ' | ';
                    wDescAux := wDescAux + FORMAT(rLinOrden."Fecha inicio");
                    if rLinOrden.Inserciones > 1 THEN
                        wDescAux := wDescAux + '=' + FORMAT(rLinOrden.Inserciones);
                    if (STRLEN(wDescAux) >= 40) THEN BEGIN
                        Inserta_Linea(COPYSTR(wDescAux, 1, 50));
                        CLEAR(wDescAux);
                    END;
                END
                ELSE BEGIN
                    if FORMAT(DATE2DMY(rLinOrden."Fecha inicio", 3)) + FORMAT(DATE2DMY(rLinOrden."Fecha inicio", 2)) <> wDiasAux THEN BEGIN
                        if (wDiasAux <> '') THEN BEGIN
                            Inserta_Linea(COPYSTR(wDescAux, 1, 50));
                            CLEAR(wDescAux);
                        END;
                        wMes := ObtenerMes(rLinOrden."Fecha inicio" - DATE2DMY(rLinOrden."Fecha inicio", 1) + 1);
                        //$007
                        //wDescAux:=wMes + ' ' + FORMAT(DATE2DMY(rLinOrden."Fecha inicio",3)) + ':';
                        wDescAux := rLinOrden."Dia tarifa" + ' ' + wMes + ' ' + FORMAT(DATE2DMY(rLinOrden."Fecha inicio", 3)) + ':';
                        wDiasAux := FORMAT(DATE2DMY(rLinOrden."Fecha inicio", 3)) + FORMAT(DATE2DMY(rLinOrden."Fecha inicio", 2));
                    END
                    ELSE BEGIN
                        if wDescAux <> '' THEN
                            wDescAux := wDescAux + ',';
                    END;
                    wDescAux := wDescAux + FORMAT(DATE2DMY(rLinOrden."Fecha inicio", 1));
                    if (STRLEN(wDescAux) >= 46) THEN BEGIN
                        wDescAux := wDescAux + ',';
                        Inserta_Linea(COPYSTR(wDescAux, 1, 50));
                        CLEAR(wDescAux);
                    END;
                END;
            UNTIL rLinOrden.NEXT = 0;
        Inserta_Linea(COPYSTR(wDescAux, 1, 50));
    END;

    PROCEDURE Inserta_Linea(wDescripcion: Text[50]);
    BEGIN
        CLEAR(rLin);
        rLin."Document Type" := rCab."Document Type";
        rLin."Document No." := rCab."No.";
        rLin."Line No." := ult;
        ult += 1000;
        rLin.INSERT;
        rLin.Type := rLin.Type::" ";
        rLin.Description := wDescripcion;
        rLin.MODIFY;

    END;

    PROCEDURE ObtenerMes(pFecha: Date): Text[30];
    VAR
        rFecha: Record 2000000007;
    BEGIN
        rFecha.RESET;
        rFecha.SETRANGE("Period Type", rFecha."Period Type"::Month);      //filtro por dia 1 del mes para obtener descr.mes
        rFecha.SETRANGE("Period Start", pFecha);
        if rFecha.FINDFIRST THEN
            EXIT(rFecha."Period Name")
        ELSE
            EXIT('');
    END;

    /*   $001 MNC 050808 migracion 5.0
      $002 MNC 270309 Cambio sistema Texto ampliado lineas, en ventas
      $003 MNC 020609 Cuando tiene orden publicidad, cambio texto descripcion
      $004 MNC 060809 A¤ado % dto ventas
      $005 FCL 260310 Modifico la parte correspondiente al texto de la descripción de los días,
                      para adaptarla al nuevo formato del borrador de factura.
      $006 FCL 290310 Grabo fechas inicial y final recurso.
      $007 FCL 080410 Al grabar texto con nº dias elimino filtro precio 0 y a¤ado nº dias en texto.
      $008 FCL 160410 Grabo nº linea proyecto, para tener enlazadas las líneas de factura con las de proyecto.
      $009 FCL 035010 Para grabar las líneas de texto presupuesto incluyo filtro por nº tarea,
                      ya que no se copian las líneas correctamente.
      $010 FCL 140610 Incluyo la grabación de nº documento externo.
      $011 FCL 220710 Grabo descripción 2 que viene del proyecto.
      $012 FCL 230810 Grabo la forma de pago del proyecto si es distinta de blanco. Si est  en blanco
                      se grabar  la del cliente, como hacía hasta ahora.
      $013 FCL 310111 Para tipo recurso cogeré el proveedor de la línea de presupuesto (OnValidate de lin. venta lo coge del recurso).
      $014 FCL 300511 Grabo el campo Remarcar en la línea de detalle. */



}

