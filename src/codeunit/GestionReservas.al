/// <summary>
/// Codeunit Gestion Reservas (ID 50000).
/// </summary>
codeunit 50000 "Gestion Reservas"
{
    // Permissions = TableData "SMTP Mail Setup" = r;



    /// <summary>
    /// GetPdfViewerUrl.
    /// </summary>
    /// <returns>Return value of type Text.</returns>
    procedure GetPdfViewerUrl(): Text
    begin
        exit(PDFViewerUrlTxt);
    end;

    /// <summary>
    /// GetImagesViewerUrl.
    /// </summary>
    /// <returns>Return value of type Text.</returns>
    procedure GetImagesViewerUrl(): Text
    begin
        exit(KuaraViewerUrlTxt);
    end;

    // trigger OnRun()
    // VAR
    //     rTipo: Record "Tipo Recurso";
    //     rDia: Record "Diario Reserva";
    // BEGIN
    //     rDia.SETRANGE(Fecha, 20171001D, 99991231D);
    //     ventana.OPEN('#################1## de ################2##');
    //     ventana.UPDATE(2, rDia.COUNT);
    //     if rDia.FINDFIRST THEN
    //         REPEAT
    //             b := b + 1;
    //             ventana.UPDATE(1, b);

    //             // rDia.CALCFIELDS(rDia."Zona.",rDia."Tipo Recurso.",rDia."Municipo.",rDia."Cód cliente",rDia."Cód Zona.");
    //             rDia.Cliente := rDia."Cód cliente";
    //             if rReserva.GET(rDia."Nº Reserva") THEN
    //                 rDia."No Pay" := rReserva."No Pay";
    //             if rProyecto.GET(rDia."Nº Proyecto") THEN BEGIN
    //                 if ((UPPERCASE(COPYSTR(rProyecto.Description, 1, 2)) = 'B ') OR
    //                    (UPPERCASE(COPYSTR(rProyecto.Description, 1, 2)) = 'R-') OR
    //                    (UPPERCASE(COPYSTR(rProyecto.Description, 1, 2)) = 'R ') OR
    //                    (UPPERCASE(COPYSTR(rProyecto.Description, 1, 4)) = 'GRIS') OR
    //                    (STRPOS(UPPERCASE(rProyecto.Description), 'S/C') <> 0)) THEN
    //                     rDia."Sin Cargo" := TRUE;
    //             END;
    //             /*{ rDia.Zona:=rDia."Zona.";
    //              rDia."Tipo Recurso":=rDia."Tipo Recurso.";
    //              rDia.Municipo:=rDia."Municipo.";
    //              rDia."Cód Zona":=rDia."Cód Zona.";
    //              if rRecurso.GET(rDia."Nº Recurso") THEN
    //              rDia."Customer Price Group":= rRecurso."Customer Price Group";       }*/

    //             rDia.MODIFY;
    //             if ROUND(b / 10000, 1, '=') = b THEN COMMIT;
    //         UNTIL rDia.NEXT = 0;
    //     ventana.CLOSE;
    //     EXIT;
    //     /*{r5600.SETRANGE(r5600."Description 2",'borrar');
    //     if r5600.FINDFIRST THEN REPEAT
    //      if r56002.GET(r5600."Component of Main Asset") THEN
    //      r56002.DELETE;
    //     UNTIL r5600.NEXT=0;
    //     r5600.DELETEALL;
    //     EXIT;        }*/
    //     ventana.OPEN('#################1## de ################2##');
    //     ventana.UPDATE(2, Rempla.COUNT);
    //     if Rempla.FINDFIRST THEN
    //         REPEAT
    //             b := b + 1;
    //             ventana.UPDATE(1, b);
    //             GeneraActivo(Rempla."Nº Emplazamiento", Rempla."Nº Proveedor");
    //         UNTIL Rempla.NEXT = 0;
    //     ventana.CLOSE;
    //     EXIT;
    //     Emplazamientos.SETFILTER(Emplazamientos."Fecha firma contrato", '<>%1', 0D);
    //     Emplazamientos.SETFILTER(Emplazamientos."Fecha vto. contrato", '<>%1', 0D);
    //     Emplazamientos.SETRANGE(Emplazamientos.Estado, Emplazamientos.Estado::Alta);
    //     if Emplazamientos.FINDFIRST THEN
    //         REPEAT
    //             if Emplazamientos."Fecha firma contrato Des" = 0D THEN
    //                 Emplazamientos."Fecha firma contrato Des" := Emplazamientos."Fecha firma contrato";
    //             if Emplazamientos."Fecha vto. contrato Des" = 0D THEN
    //                 Emplazamientos."Fecha vto. contrato Des" := Emplazamientos."Fecha vto. contrato";
    //             rRest."No." := Emplazamientos."Nº Emplazamiento";
    //             if rRest.INSERT THEN BEGIN
    //                 r5600."No." := Emplazamientos."Nº Emplazamiento" + '-' + Emplazamientos."Nº Proveedor";
    //                 r5600.Description := 'Desm. Empl Nº ' + Emplazamientos."Nº Emplazamiento";
    //                 r5600."Search Description" := r5600.Description;
    //                 r5600."Description 2" := COPYSTR(Emplazamientos.Descripción, 1, MAXSTRLEN(r5600.Description));
    //                 r5600."Vendor No." := Emplazamientos."Nº Proveedor";
    //                 r5600."Main Asset/Component" := r5600."Main Asset/Component"::"Main Asset";
    //                 r5600."FA Posting Group" := 'DESMONTAJE';
    //                 Recursos.SETRANGE(Recursos."Nº Emplazamiento", Emplazamientos."Nº Emplazamiento");
    //                 a := Cuenta(Emplazamientos."Nº Emplazamiento");
    //                 if a > 0 THEN BEGIN
    //                     if a = 999 THEN BEGIN
    //                         r5600."No Recursos" := 1;
    //                         r5600."Mód. Montado" := Emplazamientos."Módulo montado";
    //                         if r5600."Mód. Montado" < 1 THEN r5600."Mód. Montado" := 1;
    //                         r5600.INSERT;
    //                         r56002."No." := Emplazamientos."Nº Emplazamiento";
    //                         r56002.Description := 'Desm. recu. Nº ' + Emplazamientos."Nº Emplazamiento";
    //                         r56002."Search Description" := r56002.Description;
    //                         r56002."Description 2" := COPYSTR(Emplazamientos."Nº Emplazamiento", 1, MAXSTRLEN(r5600.Description));
    //                         r56002."Vendor No." := Emplazamientos."Nº Proveedor";
    //                         r56002."FA Posting Group" := 'DESMONTAJE';
    //                         r56002."Main Asset/Component" := r56002."Main Asset/Component"::Component;
    //                         r56002."Component of Main Asset" := r5600."No.";
    //                         r56122."FA No." := r56002."No.";
    //                         r56122."Depreciation Book Code" := 'IBIZA PUBL';
    //                         r56122."FA Posting Group" := 'DESMONTAJE';
    //                         r56122."Depreciation Method" := r56122."Depreciation Method"::"Straight-Line";
    //                         r56122."Depreciation Starting Date" := Emplazamientos."Fecha firma contrato Des";
    //                         r56122."G/L Acquisition Date" := r56122."Depreciation Starting Date";
    //                         r56122."No. of Depreciation Years" := DATE2DMY(Emplazamientos."Fecha vto. contrato Des", 3) -
    //                                                             DATE2DWY(r56122."Depreciation Starting Date", 3);
    //                         r56002."No Recursos" := 1;
    //                         r56002."Mód. Montado" := Emplazamientos."Módulo montado";
    //                         r56002.Recurso := '';//Recursos."Nº Recurso";
    //                         if r56002."Mód. Montado" < 1 THEN r56002."Mód. Montado" := 1;
    //                         r56122.INSERT;
    //                         r56002.INSERT;
    //                         r5612."FA No." := r5600."No.";
    //                         r5612."Depreciation Book Code" := 'CONTABLE';
    //                         r5612."Depreciation Method" := r5612."Depreciation Method"::"Straight-Line";
    //                         r5612."Depreciation Starting Date" := Emplazamientos."Fecha firma contrato Des";
    //                         r5612."G/L Acquisition Date" := r5612."Depreciation Starting Date";
    //                         r5612."FA Posting Group" := 'DESMONTAJE';
    //                         r5612."No. of Depreciation Years" := DATE2DMY(Emplazamientos."Fecha vto. contrato Des", 3) -
    //                         DATE2DWY(r5612."Depreciation Starting Date", 3);
    //                         r5612.INSERT;

    //                     END ELSE BEGIN
    //                         r5600."No Recursos" := a;
    //                         r5600."Mód. Montado" := Emplazamientos."Módulo montado";
    //                         if r5600."Mód. Montado" < 1 THEN r5600."Mód. Montado" := 1;
    //                         r5600.INSERT;
    //                         if Recursos.FINDFIRST THEN
    //                             REPEAT
    //                                 if rRes.GET(Recursos."Nº Recurso") THEN BEGIN
    //                                     if rTipo.GET(rRes."Tipo Recurso") THEN BEGIN
    //                                         if rTipo."Cód. Principal" <> '1020' THEN BEGIN
    //                                             r56002."No." := Recursos."Nº Recurso" + '-' + Emplazamientos."Nº Emplazamiento";
    //                                             r56002.Description := 'Desm. recu. Nº ' + Recursos."Nº Recurso";
    //                                             r56002."Search Description" := r56002.Description;
    //                                             r56002."Description 2" := COPYSTR(Recursos."Descripción recurso", 1, MAXSTRLEN(r5600.Description));
    //                                             r56002."Vendor No." := Emplazamientos."Nº Proveedor";
    //                                             r56002."FA Posting Group" := 'DESMONTAJE';
    //                                             r56002."Main Asset/Component" := r56002."Main Asset/Component"::Component;
    //                                             r56002."Component of Main Asset" := r5600."No.";
    //                                             r56122."FA No." := r56002."No.";
    //                                             r56122."Depreciation Book Code" := 'CONTABLE';
    //                                             r56122."FA Posting Group" := 'DESMONTAJE';
    //                                             r56122."Depreciation Method" := r56122."Depreciation Method"::"Straight-Line";
    //                                             r56122."Depreciation Starting Date" := Emplazamientos."Fecha firma contrato Des";
    //                                             r56122."G/L Acquisition Date" := r56122."Depreciation Starting Date";
    //                                             r56122."No. of Depreciation Years" := DATE2DMY(Emplazamientos."Fecha vto. contrato Des", 3) -
    //                                                                                 DATE2DWY(r56122."Depreciation Starting Date", 3);
    //                                             r56002."No Recursos" := a;
    //                                             r56002."Mód. Montado" := Emplazamientos."Módulo montado";
    //                                             r56002.Recurso := Recursos."Nº Recurso";
    //                                             if r56002."Mód. Montado" < 1 THEN r56002."Mód. Montado" := 1;
    //                                             r56122.INSERT;
    //                                             r56002.INSERT;
    //                                         END;
    //                                     END;
    //                                 END;
    //                             UNTIL Recursos.NEXT = 0;
    //                         r5612."FA No." := r5600."No.";
    //                         r5612."Depreciation Book Code" := 'CONTABLE';
    //                         r5612."FA Posting Group" := 'DESMONTAJE';
    //                         r5612."Depreciation Method" := r5612."Depreciation Method"::"Straight-Line";
    //                         r5612."Depreciation Starting Date" := Emplazamientos."Fecha firma contrato Des";
    //                         r5612."G/L Acquisition Date" := r5612."Depreciation Starting Date";
    //                         r5612."No. of Depreciation Years" := DATE2DMY(Emplazamientos."Fecha vto. contrato Des", 3) -
    //                         DATE2DWY(r5612."Depreciation Starting Date", 3);
    //                         r5612.INSERT;
    //                     END;
    //                 END;
    //             END;
    //         UNTIL Emplazamientos.NEXT = 0;
    //     r56002.SETRANGE(r56002."FA Posting Group", 'DESMONTAJE');
    //     r56002.SETRANGE(r56002."Main Asset/Component", r56002."Main Asset/Component"::Component);

    //     if r56002.FINDFIRST THEN
    //         REPEAT
    //             Importe := 278.56;
    //             if (COPYSTR(r56002."No.", 1, 2) = '40') AND (r56002.Recurso <> '') THEN
    //                 Importe := 5432;
    //             Import := Importe * r56002."Mód. Montado";
    //             Import := Import / r56002."No Recursos";
    //             r81.SETRANGE(r81."Journal Template Name", 'ACTIVOS');
    //             r81.SETRANGE(r81."Journal Batch Name", 'GENERICO');
    //             if r81.FINDLAST THEN Linea := r81."Line No.";
    //             r81.INIT;
    //             r81."Journal Template Name" := 'ACTIVOS';
    //             r81."Journal Batch Name" := 'GENERICO';
    //             r81."Line No." := Linea + 10000;
    //             r81."Account Type" := r81."Account Type"::"Fixed Asset";
    //             r81."Posting Date" := WORKDATE;
    //             r81.VALIDATE("Account No.", r56002."No.");
    //             r81."Depreciation Book Code" := 'IBIZA PUBL';
    //             r81."Document No." := r5600."No.";
    //             r81."FA Posting Type" := r81."FA Posting Type"::"Acquisition Cost";
    //             r81.VALIDATE("Debit Amount", Import);
    //             r81."Bal. Account No." := '143000060';
    //             r81.INSERT;

    //         UNTIL r56002.NEXT = 0;

    //     EXIT;
    //     //PonerRecurso;
    //     //SLEEP(150000);
    //     //RecuReserva();
    //     //EXIT;
    //     GeneraDimensiones;

    //     EXIT;
    //     GeneraDimensiones2;
    // END;


    VAR
        rLinP: Record 1003;
        rProyecto: Record 167;
        rReserva: Record Reserva;
        rDia: Record "Diario Reserva";
        rRecurso: Record 156;
        rHistorico: Record "Historico Recurso";
        rRes2: Record Reserva;
        rTipus: Record "Tipo Recurso";
        Num: Integer;
        NumR: Integer;
        total: Integer;
        resto: Integer;
        fin: Boolean;
        finestra: Dialog;
        ventana: Dialog;
        d: Date;
        num_dia: Integer;
        iVenta: Report "Proceso crear pedido vta.";
        iCompra: Report "Proceso crear pedido compra";
        Emplazamientos: Record "Emplazamientos proveedores";
        //Recursos: Record "Emplazamientos x Recursos";
        r5600: Record 5600;
        r5612: Record 5612;
        r56002: Record 5600;
        r56122: Record 5612;
        a: Integer;
        r81: Record "Gen. Journal Line";
        Importe: Decimal;
        Import: Decimal;
        Linea: Integer;
        rRes: Record 156;
        rRest: Record 156 TEMPORARY;
        Rempla: Record "Emplazamientos proveedores";
        b: Integer;
        Procesos: Codeunit ControlProcesos;
        t: Integer;
        PDFViewerUrlTxt: Label 'https://bcpdfviewer.z6.web.core.windows.net/web/viewer.html?file=', Locked = true;
        KuaraViewerUrlTXT: Label 'https://navision-image-previewer.deploy.kuarasoftware.es', Locked = true;
        Utilidades: Codeunit Utilitis;

    PROCEDURE "Crear ListaEspera"(VAR rLinPresup: Record 1003; RecursoAgrupado: Code[20]; Linea: Integer; EsAgrupado: Boolean; LineaAgrupado: Integer);
    var
        Res: Record Resource;
        Bloqueos: Record "Diario Incidencias Rescursos";
    BEGIN
        rLinP.LOCKTABLE;
        rReserva.LOCKTABLE;
        finestra.OPEN('Creando reservas...\' +
                      'Linea de #1##################\' +
                      'Recurso  #2##################');
        EsAgrupado := false;
        if RecursoAgrupado <> '' Then EsAgrupado := true;
        if EsAgrupado Then if Not Res.Get(RecursoAgrupado) Then Res.Init();
        Bloqueos.SETRANGE(Bloqueos."Nº Recurso", rLinP."No.");
        Bloqueos.SETRANGE(Bloqueos.Fecha, rLinP."Planning Date", rLinP."Fecha Final");
        if Bloqueos.FIND('-') THEN
            ERROR('El recurso %1 esta bloqueado entre las \' +
                  'fechas %2 .. %3, por el motivo %4', rLinP."No.",
                  rLinP."Planning Date", rLinP."Fecha Final", Bloqueos.Motivo);
        finestra.UPDATE(1, rLinP."No.");
        rLinP := rLinPresup;
        rProyecto.GET(rLinP."Job No.");
        rLinP.TESTFIELD("Planning Date");
        rLinP.TESTFIELD("Fecha Final");
        CASE rLinP.Type OF
            rLinP.Type::Resource:
                BEGIN
                    total := rLinP."Cdad. a Reservar";
                    resto := total;
                    if rRecurso.GET(rLinP."No.") THEN BEGIN
                        if Res."No." <> '' then
                            if rRecurso."Tipo Recurso" <> Res."Tipo Recurso" Then
                                if rProyecto."Proyecto Mixto" = False Then
                                    Error('El recurso agrupado %1 es %2 y, el recurso %3 es %4', Res."No.", Res."Tipo Recurso", rRecurso."No.", rRecurso."Tipo Recurso");
                        finestra.UPDATE(2, rRecurso."No.");
                        CreaReserva_Historia(rRecurso, RecursoAgrupado, Linea, EsAgrupado, true, LineaAgrupado);
                        resto := resto - 1;
                    END;
                    rLinP."Cdad. a Reservar" := rLinP."Cdad. a Reservar" - (total - resto);
                    rLinP."Cdad. Reservada" := rLinP."Cdad. Reservada" + (total - resto);
                    if rReCurso."Recurso Agrupado" Then rLinp."Cdad. a Reservar" := 0;
                    rLinP.MODIFY;
                END;
            rLinP.Type::Familia:
                BEGIN
                    //                              Marca_Ocupados(rLinP."Starting Date", rLinP."Fecha Final", rLinP."No.");    //FCL-16/06/04
                    Marca_Ocupados(rLinP."Planning Date", rLinP."Fecha Final", rLinP."No.", ''); //FCL-16/06/04
                    rRecurso.SETCURRENTKEY(Blocked, "Resource Group No.", Ocupado, Categoria);
                    rRecurso.SETRANGE(Blocked, FALSE);
                    rRecurso.SETRANGE("Resource Group No.", rLinP."No.");
                    rRecurso.SETRANGE(Ocupado, FALSE);

                    total := rLinP."Cdad. a Reservar";
                    resto := total;
                    fin := FALSE;
                    rRecurso.SETRANGE(Categoria, rRecurso.Categoria::"1");
                    Comun_Categoria(RecursoAgrupado, Linea, true, LineaAgrupado);
                    rRecurso.SETRANGE(Categoria, rRecurso.Categoria::"2");
                    Comun_Categoria(RecursoAgrupado, Linea, true, LineaAgrupado);
                    rRecurso.SETRANGE(Categoria, rRecurso.Categoria::Especial);
                    Comun_Categoria(RecursoAgrupado, Linea, true, LineaAgrupado);
                    rRecurso.SETRANGE(Categoria, rRecurso.Categoria::" ");
                    Comun_Categoria(RecursoAgrupado, Linea, true, LineaAgrupado);
                    // rLinP."Cdad. a Reservar" := rLinP."Cdad. a Reservar" - (total - resto);
                    // rLinP."Cdad. Reservada" := rLinP."Cdad. Reservada" + (total - resto);
                    rLinP.MODIFY;
                END;
        END;
        finestra.CLOSE;
    END;

    PROCEDURE "Crear Reserva"(VAR rLinPresup: Record 1003; RecursoAgrupado: Code[20]; Linea: Integer; EsAgrupado: Boolean; LineaAgrupado: Integer): Integer;
    var
        Res: Record Resource;
        Reservada: Integer;
        Bloqueos: Record "Diario Incidencias Rescursos";
    BEGIN
        rLinP.LOCKTABLE;
        rReserva.LOCKTABLE;
        finestra.OPEN('Creando reservas...\' +
                      'Linea de #1##################\' +
                      'Recurso  #2##################');
        EsAgrupado := false;
        if RecursoAgrupado <> '' Then EsAgrupado := true;
        if EsAgrupado Then if Not Res.Get(RecursoAgrupado) Then Res.Init();
        Bloqueos.SETRANGE(Bloqueos."Nº Recurso", rLinP."No.");
        Bloqueos.SETRANGE(Bloqueos.Fecha, rLinP."Planning Date", rLinP."Fecha Final");
        if Bloqueos.FIND('-') THEN
            ERROR('El recurso %1 esta bloqueado entre las \' +
                  'fechas %2 .. %3, por el motivo %4', rLinP."No.",
                  rLinP."Planning Date", rLinP."Fecha Final", Bloqueos.Motivo);
        finestra.UPDATE(1, rLinP."No.");
        rLinP := rLinPresup;
        rProyecto.GET(rLinP."Job No.");
        rLinP.TESTFIELD("Planning Date");
        rLinP.TESTFIELD("Fecha Final");
        CASE rLinP.Type OF
            rLinP.Type::Resource:
                BEGIN
                    total := rLinP."Cdad. a Reservar";
                    resto := total;
                    if rRecurso.GET(rLinP."No.") THEN BEGIN
                        if Res."No." <> '' then
                            if rRecurso."Tipo Recurso" <> Res."Tipo Recurso" Then
                                if rProyecto."Proyecto Mixto" = False Then
                                    Error('El recurso agrupado %1 es %2 y, el recurso %3 es %4', Res."No.", Res."Tipo Recurso", rRecurso."No.", rRecurso."Tipo Recurso");
                        finestra.UPDATE(2, rRecurso."No.");
                        CreaReserva_Historia(rRecurso, RecursoAgrupado, Linea, EsAgrupado, false, LineaAgrupado);
                        resto := resto - 1;
                    END;
                    rLinP."Cdad. a Reservar" := rLinP."Cdad. a Reservar" - (total - resto);
                    rLinP."Cdad. Reservada" := rLinP."Cdad. Reservada" + (total - resto);
                    Reservada := rLinP."Cdad. Reservada";
                    if rReCurso."Recurso Agrupado" Then rLinp."Cdad. a Reservar" := 0;
                    rLinP.MODIFY;
                END;
            rLinP.Type::Familia:
                BEGIN
                    //                              Marca_Ocupados(rLinP."Starting Date", rLinP."Fecha Final", rLinP."No.");    //FCL-16/06/04
                    Marca_Ocupados(rLinP."Planning Date", rLinP."Fecha Final", rLinP."No.", ''); //FCL-16/06/04
                    rRecurso.SETCURRENTKEY(Blocked, "Resource Group No.", Ocupado, Categoria);
                    rRecurso.SETRANGE(Blocked, FALSE);
                    rRecurso.SETRANGE("Resource Group No.", rLinP."No.");
                    rRecurso.SETRANGE(Ocupado, FALSE);

                    total := rLinP."Cdad. a Reservar";
                    resto := total;
                    fin := FALSE;
                    rRecurso.SETRANGE(Categoria, rRecurso.Categoria::"1");
                    Reservada := Comun_Categoria(RecursoAgrupado, Linea, false, LineaAgrupado);
                    rRecurso.SETRANGE(Categoria, rRecurso.Categoria::"2");
                    Reservada := Comun_Categoria(RecursoAgrupado, Linea, false, LineaAgrupado);
                    rRecurso.SETRANGE(Categoria, rRecurso.Categoria::Especial);
                    Reservada := Comun_Categoria(RecursoAgrupado, Linea, false, LineaAgrupado);
                    rRecurso.SETRANGE(Categoria, rRecurso.Categoria::" ");
                    Reservada := Comun_Categoria(RecursoAgrupado, Linea, false, LineaAgrupado);
                    // rLinP."Cdad. a Reservar" := rLinP."Cdad. a Reservar" - (total - resto);
                    // rLinP."Cdad. Reservada" := rLinP."Cdad. Reservada" + (total - resto);
                    rLinP.MODIFY;
                END;
        END;
        finestra.CLOSE;
        exit(Reservada);
    END;

    PROCEDURE CreaReserva_Historia(VAR rRecurs: Record 156; RecursoAgrupado: Code[20]; Linea: Integer; EsAgrupado: Boolean; LS: Boolean; LineaAgrupado: Integer);
    BEGIN
        rTipus.GET(rRecurs."Tipo Recurso");
        if (rTipus.Exterior) THEN BEGIN
            rDia.RESET;
            rDia.SETCURRENTKEY("Nº Recurso", Fecha);
            rDia.SETRANGE("Nº Recurso", rRecurs."No.");
            rDia.SETRANGE(Fecha, rLinP."Planning Date", rLinP."Fecha Final");
            if rDia.FIND('-') THEN
                ERROR('El recurso %1 esta %2 entre las \' +
                      'fechas %3 .. %4, en el proyecto %5.', rRecurs."No.", rDia.Estado,
                      rLinP."Planning Date", rLinP."Fecha Final", rDia."Nº Proyecto");
        END;
        // Si no es exterior no necesito hacer la comprobacion, porque deben hacerse todas
        // las reservas necesarias.

        Crea_Base_Reserva(rLinP, rLinP."Planning Date", rLinP."Fecha Final", rRecurs, RecursoAgrupado, Linea, EsAgrupado, LineaAgrupado);
        Crea_Dia_Reserva(rReserva);
        // $001 Crea_Historia(rReserva."Nº Recurso",rReserva,'SUYO');
    END;

    PROCEDURE Crea_Base_Reserva(rLinea: Record 1003; FechaInicio: Date; FechaFin: Date; rRecurs2: Record 156; RecursoAgrupado: Code[20]; Linea: Integer; EsAgrupado: Boolean; LineaAgrupado: Integer);
    VAR
        rProy: Record 167;
        rRec: Record 156;
        rRecAgre: Record 156;
    BEGIN
        rProy.GET(rLinea."Job No.");
        rReserva.RESET;
        if rReserva.FIND('+') THEN
            NumR := rReserva."Nº Reserva" + 1
        ELSE
            NumR := 1;
        CLEAR(rReserva);
        rReserva."Nº Reserva" := NumR;
        rReserva."Fecha inicio" := FechaInicio;
        rReserva."Fecha fin" := FechaFin;
        rReserva."Nº Recurso" := rRecurs2."No.";
        rReserva.Descripción := rRecurs2.Name;
        rReserva.Estado := rReserva.Estado::Reservado;
        rReserva."Linea Agrupado" := LineaAgrupado;
        rReserva."Cód. Cliente" := rProy."Bill-to Customer No.";
        rReserva."Nº Proyecto" := rLinea."Job No.";
        /* {
        rReserva."Cód. fase"          := rLinea."Phase Code";
        rReserva."Cód. subfase"       := rLinea."Task Code";
        } */
        rReserva."Cód. tarea" := rLinea."Job Task No.";
        //$003
        rReserva."Nº linea proyecto" := rLinea."Line No.";
        case rLinea.Type of
            rLinea.Type::"G/L Account":
                rReserva."Tipo (presupuesto)" := rReserva."Tipo (presupuesto)"::Cuenta;
            rLinea.Type::Item:
                rReserva."Tipo (presupuesto)" := rReserva."Tipo (presupuesto)"::Producto;
            rLinea.Type::Resource:
                rReserva."Tipo (presupuesto)" := rReserva."Tipo (presupuesto)"::Recurso;
            rLinea.Type::Text:
                rReserva."Tipo (presupuesto)" := rReserva."Tipo (presupuesto)"::Texto;
            rLinea.Type::"Activo fijo":
                rReserva."Tipo (presupuesto)" := rReserva."Tipo (presupuesto)"::"Activo Fijo";
            rLinea.Type::"Familia":
                rReserva."Tipo (presupuesto)" := rReserva."Tipo (presupuesto)"::Familia;
        End;
        rReserva."Nº (presupuesto)" := rLinea."No.";
        rReserva."Nº fam. recurso" := rRecurs2."Resource Group No.";
        rReserva."Cód. variante (presupuesto)" := rLinea."Variant Code";
        rReserva."Usuario creacion" := UserId;
        rReserva."Fecha creacion" := CURRENTDATETIME;
        if rRec.Get(rReserva."Nº Recurso") Then Begin
            if Not rRecAgre.Get(RecursoAgrupado) Then rRecAgre.Init();
            //if rRec."Tipo Recurso" = rRecAgre."Tipo Recurso" Then
            rReserva."Recurso Agrupado" := RecursoAgrupado;
        End;

        rReserva.Linea := Linea;
        // $002+
        rReserva."No Pay" := rProy."No Pay";
        if ((UPPERCASE(COPYSTR(rProy.Description, 1, 2)) = 'B ') OR
            (UPPERCASE(COPYSTR(rProy.Description, 1, 2)) = 'R-') OR
            (UPPERCASE(COPYSTR(rProy.Description, 1, 2)) = 'R ') OR
            (UPPERCASE(COPYSTR(rProy.Description, 1, 4)) = 'GRIS') OR
            (STRPOS(UPPERCASE(rProy.Description), 'S/C') <> 0)) THEN
            rReserva."Sin Cargo" := TRUE;
        rReserva."Proyecto de fijación" := rProy."Proyecto de fijación";
        rReserva."Tipo de Fijación" := rProy."Tipo de Fijación";
        rReserva.Estado := rReserva.Estado::Reservado;
        rReserva.INSERT;
    END;

    PROCEDURE Crea_Dia_Reserva(rRes: Record Reserva);
    var
        rRecAgre: Record Resource;
        Contrato: Record "Sales Header";
    BEGIN
        Contrato.SETCURRENTKEY("Nº Proyecto");
        Contrato.SetRange("Nº Proyecto", rRes."Nº Proyecto");
        Contrato.SetRange("Document Type", Contrato."Document Type"::"Order");
        If Not Contrato.FindSet() Then
            Contrato.init;
        FOR d := rRes."Fecha inicio" TO rRes."Fecha fin" DO BEGIN
            CLEAR(rDia);
            rDia."Nº Reserva" := rRes."Nº Reserva";
            rDia.Fecha := d;
            rDia."Nº Recurso" := rRes."Nº Recurso";
            rDia."Nº Proyecto" := rRes."Nº Proyecto";
            rDia.Contrato := Contrato."No.";
            rdia."Estado Contrato" := Contrato."Estado Contrato";

            /* {
            rDia."Cód. fase"          := rRes."Cód. fase";
            rDia."Cód. subfase"       := rRes."Cód. subfase";
            } */
            rDia."Cód. tarea" := rRes."Cód. tarea";
            //$003
            rDia."Nº linea proyecto" := rRes."Nº linea proyecto";
            rDia."Tipo (presupuesto)" := rRes."Tipo (presupuesto)";
            rDia."Nº (presupuesto)" := rRes."Nº (presupuesto)";
            rDia.Estado := rRes.Estado;
            rDia."Nº fam. recurso" := rRes."Nº fam. recurso";
            rDia."No Pay" := rRes."No Pay";
            rDia."Proyecto de fijación" := rRes."Proyecto de fijación";
            rDia."Tipo de Fijación" := rRes."Tipo de Fijación";
            rDia.Cliente := rRes."Cód. Cliente";
            if rRecurso.GET(rRes."Nº Recurso") THEN BEGIN
                rDia.Zona := rRecurso."Global Dimension 4 Code";
                rDia."Tipo Recurso" := rRecurso."Tipo Recurso";
                rDia.Municipo := rRecurso.Municipio;
                rDia."Cód Zona" := rRecurso.Zona;
                rDia."Customer Price Group" := rRecurso."Customer Price Group";
                if Not rRecAgre.Get(rRes."Recurso Agrupado") Then rRecAgre.Init();
                //if rRecurso."Tipo Recurso" = rRecAgre."Tipo Recurso" Then
                rDia."Recurso Agrupado" := rRes."Recurso Agrupado";

            END;
            rDia."Sin Cargo" := rReserva."Sin Cargo";
            rDia.INSERT;
        END;
    END;

    PROCEDURE Comun_Categoria(Recurso: Code[20]; Linea: Integer; Ls: Boolean; LineaAgrupado: Integer): Integer;
    VAR
        rRec2: Record 156;
        Reservada: Integer;
    BEGIN
        if (NOT fin) THEN BEGIN
            if rRecurso.FIND('-') THEN
                REPEAT
                    rRec2 := rRecurso;
                    finestra.UPDATE(2, rRec2."No.");
                    CreaReserva_Historia(rRec2, Recurso, Linea, false, Ls, LineaAgrupado);
                    resto := resto - 1;
                    Reservada := Reservada + 1;
                    if (resto = 0) THEN
                        fin := TRUE;
                UNTIL (rRecurso.NEXT = 0) OR (fin);
        END;
        Exit(Reservada);
    END;


    PROCEDURE Cambio_Estado(VAR rRes: Record Reserva);
    VAR
        xEstado: Enum "Estado Reserva";// Option Reservado,"Reservado fijo",Ocupado,"Ocupado fijo";
    BEGIN
        xEstado := rRes.Estado;
        CASE rRes.Estado OF
            rRes.Estado::Reservado:
                BEGIN
                    if CONFIRM('Cambiar el estado de la \' +
                             'reserva a Reservado fijo?') THEN BEGIN
                        rRes.Estado := rRes.Estado::"Reservado fijo";
                        rRes.MODIFY;
                        rDia.SETRANGE("Nº Reserva", rRes."Nº Reserva");
                        rDia.MODIFYALL(Estado, rRes.Estado);
                        // $001 Crea_Historia(rRes."Nº Recurso",rRes,'SUYO');
                    END;
                END;
            rRes.Estado::Ocupado:
                BEGIN
                    if CONFIRM('Cambiar el estado de la \' +
                             'reserva a Ocupado fijo?') THEN BEGIN
                        rRes.Estado := rRes.Estado::"Ocupado fijo";
                        rRes.MODIFY;
                        rDia.SETRANGE("Nº Reserva", rRes."Nº Reserva");
                        rDia.MODIFYALL(Estado, rRes.Estado);
                        // $001 Crea_Historia(rRes."Nº Recurso",rRes,'SUYO');
                    END;
                END;
            ELSE
                ERROR('Este estado ya no se pueden cambiar');
        END;
    END;

    PROCEDURE Marca_Ocupados(FI: Date; FF: Date; Family: Code[20]; TipoRec: Code[10]);
    VAR
        rRec3: Record 156;
        rRec4: Record 156;
    BEGIN
        ventana.OPEN('Calculando Recurso #1################. Un momento, por favor.');
        if TipoRec <> '' THEN                                     //FCL-16/06/04
            rRec4.SETRANGE("Tipo Recurso", TipoRec);                 //FCL-16/06/04
        rRec4.MODIFYALL(Ocupado, FALSE);
        rRec3.LOCKTABLE;

        rRec4.SETCURRENTKEY(Blocked, "Resource Group No.", Ocupado, Categoria);
        rRec4.SETRANGE(Blocked, FALSE);
        // MNC Llevat 30-4-99
        // rRec4.SETRANGE("Nº fam. recurso", Family);
        // Fi MNC
        rRec4.SETRANGE(Ocupado, FALSE);
        if TipoRec <> '' THEN                                     //FCL-16/06/04
            rRec4.SETRANGE("Tipo Recurso", TipoRec);                 //FCL-16/06/04
        if rRec4.FIND('-') THEN
            REPEAT
                ventana.UPDATE(1, rRec4."No.");
                rDia.RESET;
                rDia.SETCURRENTKEY("Nº Recurso", Fecha);
                rDia.SETRANGE("Nº Recurso", rRec4."No.");
                rDia.SETRANGE(Fecha, FI, FF);
                if rDia.FIND('-') THEN BEGIN
                    rRec3 := rRec4;
                    rRec3.Ocupado := TRUE;
                    rRec3.MODIFY;
                END;
            UNTIL (rRec4.NEXT = 0);
        ventana.CLOSE;
    END;

    PROCEDURE Pasa_Contrato(rProyecto: Record 167);
    VAR
        rLin: Record 1003;
        JobSetup: Record 315;
        Contrato: Record 36;
    BEGIN
        finestra.OPEN('Creando pedidos de venta');
        rLin.SETCURRENTKEY("Job No.", "Crear pedidos", "Compra a-Nº proveedor");
        rLin.SETRANGE("Job No.", rProyecto."No.");
        rLin.SETFILTER("Crear pedidos", '%1|%2', rLin."Crear pedidos"::"De Venta",
                                                rLin."Crear pedidos"::"De Compra Y De Venta");

        if rLin.FindFirst() THEN
            Pedido_Venta(rProyecto, rLin);
        finestra.CLOSE;

        //Modificado para Grepsa
        JobSetup.GET;
        if JobSetup."Correlación de ingresos-gastos" = FALSE THEN BEGIN
            finestra.OPEN('Creando pedidos de compra');
            rLin.SETFILTER("Crear pedidos", '%1|%2', rLin."Crear pedidos"::"De Compra Y De Venta",
                                                   rLin."Crear pedidos"::"De Compra");
            COMMIT;
            Contrato.SETCURRENTKEY("Nº Proyecto");
            Contrato.SETRANGE(Contrato."Document Type", Contrato."Document Type"::Order);
            Contrato.SETRANGE(Contrato."Nº Proyecto", rProyecto."No.");
            rLin.SETFILTER("Crear pedidos", '%1|%2', rLin."Crear pedidos"::"De Compra",
                                                rLin."Crear pedidos"::"De Compra Y De Venta");
            if NOT Contrato.FINDFIRST THEN Contrato.INIT;
            if rLin.FIND('-') THEN
                Pedido_Compra(rProyecto, rLin, Contrato);
            finestra.CLOSE;
        END;
        MESSAGE('Proceso finalizado');
    END;

    PROCEDURE Pedido_Venta(VAR rProyV: Record 167; VAR rLineaV: Record 1003);
    var
        Res: Record Resource;
        ProduccionesRelacionadas: Record "Produccines Relacionadas";
    BEGIN
        CLEAR(iVenta);
        if rLineaV.FindFirst() Then
            repeat
                if Res.Get(rLineaV."No.") then
                    if Res."Producción" Then begin
                        ProduccionesRelacionadas.SetRange("Job No.", rProyV."No.");
                        ProduccionesRelacionadas.SetRange("No.", Res."No.");
                        if not ProduccionesRelacionadas.FindFirst() Then ERROR('No se ha asignado producción para ' + Res."No.");
                    end;
            until rLineaV.Next() = 0;
        iVenta.Coge_Registros(rProyV, rLineaV);
        iVenta.RUNMODAL;
    END;

    PROCEDURE Pedido_Compra(VAR rProyC: Record 167; VAR rLineaC: Record 1003; VAR Contrato: Record 36);
    VAR
        aux_p: Code[20];
        rL2: Record 1003;
        cProyecto: Codeunit 50002;
        rJobSetup: Record "Jobs Setup";
        Vendor: Record Vendor;
    BEGIN
        aux_p := '';
        rLineaC.SetFilter("Compra a-Nº proveedor", '<>%1', '');
        if rLineaC.FIND('-') THEN
            REPEAT
                if (aux_p <> rLineaC."Compra a-Nº proveedor") THEN BEGIN
                    aux_p := rLineaC."Compra a-Nº proveedor";
                    rL2.COPYFILTERS(rLineaC);
                    rL2 := rLineaC;
                    rL2.SETRANGE("Compra a-Nº proveedor", rLineaC."Compra a-Nº proveedor");
                    if Not Vendor.Get(rLineaC."Compra a-Nº proveedor") Then Vendor.Init();
                    rJobSetup.Get();
                    if (rJobSetup."Crear Factura Interempresas" = false) or (Vendor."IC Partner Code" = '') Then begin
                        CLEAR(iCompra);
                        iCompra.Coge_Registros(rProyC, rL2);
                        iCompra.RUNMODAL;
                    end;
                    rL2.RESET;
                END;
            UNTIL rLineaC.NEXT = 0;
        CLEAR(cProyecto);
        if (cProyecto.DebeTraspasarse(rProyC)) AND (Contrato."No." <> '') THEN
            cProyecto.CreaPedidoVenta(rProyC, Contrato);
    END;

    PROCEDURE Busca_Tarifa(aux_Num: Code[20]; aux_Prov: Code[20]; aux_F_I: Date; aux_F_F: Date; aux_Proy: Code[20]): Decimal;
    VAR
        rFecha: Record 2000000007;
        rProy: Record 167;
        tarifa: Integer;
        fecha_trabajo: Date;
        Precio_acum: Decimal;
    BEGIN
        /*{    Anuladas tablas antiguas  4-12-09
        CLEAR(tarifa);
        CLEAR(Precio_acum);
        ////{ ***** CABECERA TARIFA ***** }
        rCabT.RESET;
        rCabT.SETCURRENTKEY(Proveedor,"Fecha desde","Fecha hasta");
        rCabT.SETRANGE(Proveedor, aux_Prov);
        FOR fecha_trabajo := aux_F_I TO aux_F_F DO BEGIN
          rCabT.SETFILTER("Fecha desde",'<=%1',fecha_trabajo);
          rCabT.SETFILTER("Fecha hasta",'>=%1',fecha_trabajo);
          if rCabT.FIND('-') THEN BEGIN
            // Me aseguro que el proyecto tenga la misma divisa
            rProy.GET(aux_Proy);
            if (rProy."Cód. divisa" <> rCabT."Cód. divisa") THEN
              ERROR('OJO: No se puede aplicar la tarifa ya que esta en #1### y el proyecto esta en #2###',
                    rCabT."Cód. divisa", rProy."Cód. divisa");
          //  //{ ***** LINEAS TARIFA ***** }
            rLinT.RESET;
            rLinT.SETCURRENTKEY("Num. Tarifa",Recurso,"Fecha desde","Fecha hasta",
                                "Dia desde","Dia hasta",Festivo);
            rLinT.SETRANGE("Num. Tarifa",rCabT."Num. Tarifa");
            rLinT.SETRANGE(Recurso,aux_Num);
            rLinT.SETFILTER("Fecha desde",'<=%1',fecha_trabajo);
            rLinT.SETFILTER("Fecha hasta",'>=%1',fecha_trabajo);

            rFecha.RESET;
            rFecha.SETRANGE("Period Type",rFecha."Period Type"::Date);
            rFecha.SETRANGE("Period Start",fecha_trabajo);
            if rFecha.FIND('-') THEN BEGIN
              NumeroDia(rFecha);
              rLinT.SETFILTER("Dia desde",'<=%1',num_dia);
              rLinT.SETFILTER("Dia hasta",'>=%1',num_dia);
            END;

            if rLinT.FIND('-') THEN
              Precio_acum := Precio_acum + rLinT.Importe;

          END ELSE BEGIN
            rCabT.RESET;
            { ERROR('¿¿?? No existe tarifa para proveedor %1 de fecha %2',
                  aux_Prov, fecha_trabajo);     } 
          END;
        END;

        ////{ ***** EXTRAS ***** }
        rParam_Extras.RESET;
        rParam_Extras.SETCURRENTKEY("Dia desde","Dia hasta");
        rExtra.RESET;
        rExtra.SETCURRENTKEY("Num. Tarifa",Extra,Recurso);
        rExtra.SETRANGE("Num. Tarifa", rCabT."Num. Tarifa");
        rExtra.SETRANGE(Recurso, aux_Num);
        rFecha.RESET;
        rFecha.SETRANGE("Period Type",rFecha."Period Type"::Date);
        rFecha.SETRANGE("Period Start",aux_F_I);
        if rFecha.FIND('-') THEN BEGIN
          NumeroDia(rFecha);
          rParam_Extras.SETRANGE("Dia desde", num_dia);
        END;
        rFecha.SETRANGE("Period Start", aux_F_F);
        if rFecha.FIND('-') THEN BEGIN
          NumeroDia(rFecha);
          rParam_Extras.SETRANGE("Dia hasta", num_dia);
        END;
        if rParam_Extras.FIND('-') THEN BEGIN
          rExtra.SETRANGE(Extra, rParam_Extras.Extra);
          if rExtra.FIND('-') THEN
            Precio_acum := Precio_acum + rExtra.Importe;
        END;

        EXIT(Precio_acum);

        }*/
    END;

    PROCEDURE NumeroDia(Fech: Record 2000000007);
    BEGIN
        CLEAR(num_dia);
        if Fech."Period Name" = 'lunes' THEN num_dia := 0;
        if Fech."Period Name" = 'martes' THEN num_dia := 1;
        if Fech."Period Name" = 'miércoles' THEN num_dia := 2;
        if Fech."Period Name" = 'jueves' THEN num_dia := 3;
        if Fech."Period Name" = 'viernes' THEN num_dia := 4;
        if Fech."Period Name" = 'sábado' THEN num_dia := 5;
        if Fech."Period Name" = 'domingo' THEN num_dia := 6;
    END;

    PROCEDURE Partir_Reserva(VAR rReserva1: Record Reserva; VAR fmed1: Date; VAR fmed2: Date; VAR FiltroTipo: Code[10]);
    VAR
        FI: Date;
        FF: Date;
        rRec: Record 156;
        rRec2: Record 156;
        rRec3: Record 156;
        rDia: Record "Diario Reserva";
        rLinea: Record 1003;
        rReserva2: Record Reserva;
        rReserva3: Record Reserva;
        ventana: Page 50005;
    BEGIN
        if (rReserva1.Estado <> rReserva1.Estado::Reservado) AND
           (rReserva1.Estado <> rReserva1.Estado::Ocupado) THEN
            ERROR('Solo se pueden hacer divisiones en las reservas con Estado=Reservado o Ocupado');
        if fmed1 = 0D THEN
            ERROR('No puede dejar la fecha inicio en blanco');
        if fmed2 = 0D THEN
            ERROR('No puede dejar la fecha fin en blanco');
        if (fmed1 > fmed2) THEN
            ERROR('La fecha de inicio debe ser menor o igual a la fecha de fin');
        if (fmed1 < rReserva1."Fecha inicio") THEN
            ERROR('La fecha de inicio de la nueva reserva no puede ser inferior al \' +
                  'inicio de la reserva original');
        if (fmed2 > rReserva1."Fecha fin") THEN
            ERROR('La fecha de fin de la nueva reserva no puede ser superior al \' +
                  'final de la reserva original');
        if NOT CONFIRM('Esta seguro que quiere partir la reserva') THEN
            EXIT;
        FI := rReserva1."Fecha inicio";
        FF := rReserva1."Fecha fin";
        rRec.GET(rReserva1."Nº Recurso");
        //Marca_Ocupados(fmed1,fmed2,rRec."Resource Group No.");                 //FCL-16/06/04
        Marca_Ocupados(fmed1, fmed2, rRec."Resource Group No.", FiltroTipo);        //FCL-16/06/04
        COMMIT;
        rRec2.RESET;
        rRec2.SETCURRENTKEY(Blocked, "Resource Group No.", Ocupado, Categoria);
        rRec2.SETRANGE(Blocked, FALSE);
        // MNC Llevat 30-4-99
        // rRec2.SETRANGE("Nº fam. recurso", rRec."Nº fam. recurso");
        // Fi MNC
        rRec2.SETRANGE(Ocupado, FALSE);
        if FiltroTipo <> '' THEN                                     //FCL-16/06/04
            rRec2.SETRANGE("Tipo Recurso", FiltroTipo);                 //FCL-16/06/04
        ventana.SETTABLEVIEW(rRec2);
        ventana.LOOKUPMODE(TRUE);
        if (ventana.RUNMODAL <> ACTION::LookupOK) THEN
            EXIT;
        ventana.GETRECORD(rRec2);
        //{ OJO }
        rRec2.LOCKTABLE;
        rReserva1.LOCKTABLE;
        rRec.LOCKTABLE;

        ////{ *** Borro diario reserva primera *** }
        rDia.SETCURRENTKEY("Nº Reserva", Fecha);
        rDia.SETRANGE("Nº Reserva", rReserva1."Nº Reserva");
        rDia.DELETEALL;

        ////{ *** Caso A: Solo es un cambio de recurso *** }
        if ((FI = fmed1) AND (FF = fmed2)) THEN BEGIN
            // $001 Crea_Historia(rReserva1."Nº Recurso",rReserva1,'LIBRE');
            rReserva1."Nº Recurso" := rRec2."No.";
            rReserva1."Orden fijación creada" := FALSE;
            rReserva1.MODIFY;
            Borra_Orden(rReserva1);
            // $001 Crea_Historia(rReserva1."Nº Recurso",rReserva1,'SUYO');
            Crea_Dia_Reserva(rReserva1);
            EXIT;
        END;
        ////{ *** Caso B: Quedan 2 reservas ***}
        if ((FI = fmed1) AND (fmed2 < FF)) THEN BEGIN
            rReserva1."Fecha inicio" := fmed2 + 1;
            rReserva1."Orden fijación creada" := FALSE;
            rReserva1.MODIFY;
            Borra_Orden(rReserva1);
            // $001 Crea_Historia(rReserva1."Nº Recurso",rReserva1,'SUYO');
            Crea_Dia_Reserva(rReserva1);
            /* //{ *** Crear la nueva reserva, la segunda ***}
            { $001
            rLinea.GET(rReserva1."Nº Proyecto",rReserva1."Cód. fase",rReserva1."Cód. subfase",
                       rReserva1."Cód. tarea",rReserva1."Tipo (presupuesto)",
                       rReserva1."Nº (presupuesto)",rReserva1."Cód. variante (presupuesto)");
            } */
            rLinea.RESET;
            rLinea.SETRANGE("Job No.", rReserva1."Nº Proyecto");
            rLinea.SETRANGE("Job Task No.", rReserva1."Cód. tarea");
            rLinea.SETRANGE(Type, rReserva1."Tipo (presupuesto)");
            rLinea.SETRANGE("No.", rReserva1."Nº (presupuesto)");
            rLinea.SETRANGE("Variant Code", rReserva1."Cód. variante (presupuesto)");
            if rLinea.FINDFIRST THEN
                Crea_Base_Reserva(rLinea, fmed1, fmed2, rRec2, rReserva1."Recurso Agrupado", rReserva1.Linea, false, rReserva1."Linea Agrupado");
            ////{ *** Crea el diario de la segunda reserva ***}
            rReserva2.SETCURRENTKEY("Nº Recurso", "Fecha inicio", "Fecha fin");
            rReserva2.SETRANGE("Nº Recurso", rRec2."No.");
            rReserva2.SETRANGE("Fecha inicio", fmed1);
            rReserva2.SETRANGE("Fecha fin", fmed2);
            if rReserva2.FINDFIRST THEN
                Crea_Dia_Reserva(rReserva2);
            // $001 Crea_Historia(rReserva2."Nº Recurso",rReserva2,'SUYO');
        END;
        ////{ *** Caso C: Quedan 2 reservas ***}
        if ((fmed1 > FI) AND (fmed2 = FF)) THEN BEGIN
            rReserva1."Fecha fin" := fmed1 - 1;
            rReserva1."Orden fijación creada" := FALSE;
            rReserva1.MODIFY;
            Borra_Orden(rReserva1);
            // $001 Crea_Historia(rReserva1."Nº Recurso",rReserva1,'SUYO');
            Crea_Dia_Reserva(rReserva1);
            /* //{ *** Crear la nueva reserva, la segunda ***}
            { $001
            rLinea.GET(rReserva1."Nº Proyecto",rReserva1."Cód. fase",rReserva1."Cód. subfase",
                       rReserva1."Cód. tarea",rReserva1."Tipo (presupuesto)",
                       rReserva1."Nº (presupuesto)",rReserva1."Cód. variante (presupuesto)");
            } */
            rLinea.RESET;
            rLinea.SETRANGE("Job No.", rReserva1."Nº Proyecto");
            rLinea.SETRANGE("Job Task No.", rReserva1."Cód. tarea");
            rLinea.SETRANGE(Type, rReserva1."Tipo (presupuesto)");
            rLinea.SETRANGE("No.", rReserva1."Nº (presupuesto)");
            rLinea.SETRANGE("Variant Code", rReserva1."Cód. variante (presupuesto)");
            if rLinea.FINDFIRST THEN
                Crea_Base_Reserva(rLinea, fmed1, fmed2, rRec2, rReserva1."Recurso Agrupado", rReserva1.Linea, false, rReserva1."Linea Agrupado");
            ////{ *** Crea el diario de la segunda reserva ***}
            rReserva2.SETCURRENTKEY("Nº Recurso", "Fecha inicio", "Fecha fin");
            rReserva2.SETRANGE("Nº Recurso", rRec2."No.");
            rReserva2.SETRANGE("Fecha inicio", fmed1);
            rReserva2.SETRANGE("Fecha fin", fmed2);
            if rReserva2.FINDFIRST THEN
                Crea_Dia_Reserva(rReserva2);
            // $001 Crea_Historia(rReserva2."Nº Recurso",rReserva2,'SUYO');
        END;
        ////{ *** Caso D: Quedan 3 reservas *** }
        if ((fmed1 > FI) AND (fmed2 < FF)) THEN BEGIN
            rReserva1."Fecha fin" := fmed1 - 1;
            rReserva1."Orden fijación creada" := FALSE;
            rReserva1.MODIFY;
            Borra_Orden(rReserva1);
            // $001 Crea_Historia(rReserva1."Nº Recurso",rReserva1,'SUYO');
            Crea_Dia_Reserva(rReserva1);
            /* //{ *** Crear la nueva reserva, la segunda ***}
            { $001
            rLinea.GET(rReserva1."Nº Proyecto",rReserva1."Cód. fase",rReserva1."Cód. subfase",
                       rReserva1."Cód. tarea",rReserva1."Tipo (presupuesto)",
                       rReserva1."Nº (presupuesto)",rReserva1."Cód. variante (presupuesto)");
            } */
            rLinea.RESET;
            rLinea.SETRANGE("Job No.", rReserva1."Nº Proyecto");
            rLinea.SETRANGE("Job Task No.", rReserva1."Cód. tarea");
            rLinea.SETRANGE(Type, rReserva1."Tipo (presupuesto)");
            rLinea.SETRANGE("No.", rReserva1."Nº (presupuesto)");
            rLinea.SETRANGE("Variant Code", rReserva1."Cód. variante (presupuesto)");
            if rLinea.FINDFIRST THEN
                Crea_Base_Reserva(rLinea, fmed1, fmed2, rRec2, rReserva1."Recurso Agrupado", rReserva1.Linea, false, rReserva1."Linea Agrupado");
            ////{ *** Crea el diario de la segunda reserva ***}
            rReserva2.SETCURRENTKEY("Nº Recurso", "Fecha inicio", "Fecha fin");
            rReserva2.SETRANGE("Nº Recurso", rRec2."No.");
            rReserva2.SETRANGE("Fecha inicio", fmed1);
            rReserva2.SETRANGE("Fecha fin", fmed2);
            if rReserva2.FIND('-') THEN
                Crea_Dia_Reserva(rReserva2);
            // $001 Crea_Historia(rReserva2."Nº Recurso",rReserva2,'SUYO');

            ////{ *** Crear la tercera reserva ***}
            rRec3.GET(rReserva1."Nº Recurso");
            Crea_Base_Reserva(rLinea, fmed2 + 1, FF, rRec3, rReserva1."Recurso Agrupado", rReserva1.Linea, false, rReserva1."Linea Agrupado");
            ////{ *** Crea el diario de la tercera reserva ***}
            rReserva3.SETCURRENTKEY("Nº Recurso", "Fecha inicio", "Fecha fin");
            rReserva3.SETRANGE("Nº Recurso", rRec3."No.");
            rReserva3.SETRANGE("Fecha inicio", fmed2 + 1);
            rReserva3.SETRANGE("Fecha fin", FF);
            if rReserva3.FIND('-') THEN
                Crea_Dia_Reserva(rReserva3);
            // $001 Crea_Historia(rReserva3."Nº Recurso",rReserva3,'SUYO');
        END;
    END;

    PROCEDURE Cambia_Fecha_Reserva(VAR rRes1: Record Reserva; Intervalo: Decimal);
    VAR
        exFI: Date;
        exFF: Date;
        rDia1: Record "Diario Reserva";
        rLinP: Record 1003;
        rProy: Record 167;
        rCabV: Record 36;
        rLinV: Record 37;
    BEGIN
        Mira_Libre(rRes1, rRes1."Fecha inicio" + Intervalo, rRes1."Fecha fin" + Intervalo);
        Cambia_F_Reserva(rRes1, Intervalo);
    END;

    PROCEDURE Mira_Libre(rR: Record Reserva; Fecha1: Date; Fecha2: Date);
    VAR
        rDia1: Record "Diario Reserva";
    BEGIN
        rDia1.RESET;
        rDia1.SETCURRENTKEY(Fecha, "Nº Recurso", "Nº Reserva");
        rDia1.SETRANGE(Fecha, Fecha1, Fecha2);
        rDia1.SETRANGE("Nº Recurso", rR."Nº Recurso");
        rDia1.SETFILTER("Nº Reserva", '<>%1', rR."Nº Reserva");
        if rDia1.FIND('-') THEN //{Existe otra reserva con las nuevas fechas}
            ERROR('Ya existe otra reserva con el nº %4 para el recurso %1 \' +
                  'entre las fechas %2 y %3 que se solapa con esta reserva nº %5', rR."Nº Recurso", Fecha1, Fecha2, rR."Nº Reserva",
                  rDia1."Nº Reserva");
    END;

    PROCEDURE Cambia_F_Reserva(VAR rR: Record Reserva; Intervalo: Decimal);
    VAR
        rDiari: Record "Diario Reserva";
    BEGIN
        rDiari.RESET;
        rDiari.SETCURRENTKEY("Nº Reserva", Fecha);
        rDiari.SETRANGE("Nº Reserva", rR."Nº Reserva");
        rDiari.DELETEALL;
        rR."Fecha inicio" := rR."Fecha inicio" + Intervalo;
        rR."Fecha fin" := rR."Fecha fin" + Intervalo;
        rR.MODIFY;
        // $001 Crea_Historia(rR."Nº Recurso",rR,'SUYO');
        Crea_Dia_Reserva(rR);
    END;

    PROCEDURE Borra_Orden(rR: Record Reserva);
    VAR
        rOrden: Record "Cab Orden fijación";
        rLinFijacion: Record "Orden fijación";
        rImage: record "Imagenes Orden fijación";
        Orden: Integer;
    BEGIN
        If Not Confirm('¿Desea borrar la orden de fijación?', false) Then Exit;
        rLinFijacion.RESET;
        rLinFijacion.SETCURRENTKEY("Nº Reserva");
        rLinFijacion.SETRANGE("Nº Reserva", rR."Nº Reserva");
        if rLinFijacion.FIND('-') THEN begin
            Orden := rLinFijacion."Nº Orden";
            rLinFijacion.DELETE;
            rLinFijacion.Reset();
            rLinFijacion.SETCURRENTKEY("Nº Orden");
            rLinFijacion.SETRANGE("Nº Orden", Orden);
            if not rLinFijacion.FIND('-') then begin
                rOrden.RESET;
                if rOrden.Get(Orden) then rOrden.DELETE;
                rImage.SetRange("Nº Orden", Orden);
                rImage.SetRange("Es Incidencia", false);
                rImage.DELETEALL;
            end;

        end;

    END;

    PROCEDURE Pasa_ContratoCompra(rProyecto: Record 167; Contrato: Record 36);
    VAR
        rLin: Record 1003;
    BEGIN

        /*{finestra.OPEN('Creando pedidos de venta');
        rLin.SETCURRENTKEY("Job No.","Crear pedidos","Compra a-Nº proveedor");
        rLin.SETRANGE("Job No.", rProyecto."No.");
        rLin.SETFILTER("Crear pedidos", '%1|%2',rLin."Crear pedidos"::"De Venta",
                                                rLin."Crear pedidos"::"De Compra Y De Venta");

        if rLin.FIND('-') THEN
          Pedido_Venta(rProyecto, rLin);
        finestra.CLOSE; }*/

        finestra.OPEN('Creando pedidos de compra');
        rLin.SETCURRENTKEY("Job No.", "Crear pedidos", "Compra a-Nº proveedor");
        rLin.SETRANGE("Job No.", rProyecto."No.");
        rLin.SETFILTER("Crear pedidos", '%1|%2', rLin."Crear pedidos"::"De Compra Y De Venta",
                                                rLin."Crear pedidos"::"De Compra");
        if rLin.FIND('-') THEN
            Pedido_Compra(rProyecto, rLin, Contrato);
        finestra.CLOSE;

        MESSAGE('Proceso finalizado');
    END;

    PROCEDURE Cambia_Fecha_Fin_Reserva(VAR rRes1: Record Reserva; FechaFin: Date);
    VAR
        exFI: Date;
        exFF: Date;
        rDia1: Record "Diario Reserva";
        rLinP: Record 1003;
        rProy: Record 167;
        rCabV: Record 36;
        rLinV: Record 37;
    BEGIN
        Mira_Libre(rRes1, rRes1."Fecha inicio", FechaFin);
        Cambia_FF_Reserva(rRes1, FechaFin);
    END;

    PROCEDURE Cambia_FF_Reserva(VAR rR: Record Reserva; fECHAfIN: Date);
    VAR
        rDiari: Record "Diario Reserva";
    BEGIN
        rDiari.RESET;
        rDiari.SETCURRENTKEY("Nº Reserva", Fecha);
        rDiari.SETRANGE("Nº Reserva", rR."Nº Reserva");
        rDiari.DELETEALL;
        rR."Fecha inicio" := rR."Fecha inicio";
        rR."Fecha fin" := fECHAfIN;
        rR.MODIFY;
        // $001 Crea_Historia(rR."Nº Recurso",rR,'SUYO');
        Crea_Dia_Reserva(rR);
    END;

    PROCEDURE PonerRecurso();
    VAR
        rPed: Record 38;
        rDetPed: Record 39;
        r121: Record "Purch. Rcpt. Line";
        r1003: Record 1003;
        a: Integer;
        Ventana: Dialog;
        r39: Record 39;
        C: Codeunit ControlProcesos;
    BEGIN

        if Not Utilidades.PermisoAdm() THEN ERROR('Con que finalidad esta pulsando este botón');
        rPed.SETRANGE(rPed."Document Type", rPed."Document Type"::Order);
        rPed.SETRANGE(rPed."Posting Date", 20110101D, 20121231D);
        Ventana.OPEN('Procesando ############1## de ###############2##');
        Ventana.UPDATE(2, rPed.COUNT);
        if rPed.FINDFIRST THEN
            REPEAT
                a := a + 1;
                Ventana.UPDATE(1, a);
                rDetPed.SETRANGE(rDetPed."Document Type", rPed."Document Type");
                rDetPed.SETRANGE(rDetPed."Document No.", rPed."No.");
                if rDetPed.FINDFIRST THEN
                    REPEAT
                        r1003.SETRANGE(r1003."Job No.", rDetPed."Job No.");
                        r1003.SETRANGE(r1003."Line No.", rDetPed."Linea de proyecto");
                        if r1003.FINDFIRST THEN BEGIN
                            r121.SETCURRENTKEY("Order No.", "Order Line No.");
                            r121.SETRANGE(r121."Order No.", rDetPed."Document No.");
                            r121.SETRANGE(r121."Order Line No.", rDetPed."Line No.");
                            if r121.FINDFIRST THEN
                                REPEAT
                                    if r1003.Type = r1003.Type::Resource THEN BEGIN
                                        r121.Type := r121.Type::Resource;
                                        r121."No." := r1003."No.";
                                        r121.MODIFY;
                                    END;
                                UNTIL r121.NEXT = 0;
                            rDetPed.Type := rDetPed.Type::Resource;
                            rDetPed."No." := r1003."No.";
                            rDetPed.MODIFY;

                        END;
                    UNTIL rDetPed.NEXT = 0;
            UNTIL rPed.NEXT = 0;
        Ventana.CLOSE;
    END;

    PROCEDURE PonerProyecto();
    VAR
        rPed: Record 38;
        rDetPed: Record 39;
        r121: Record "Purch. Rcpt. Line";
        r1003: Record 1003;
        a: Integer;
        Ventana: Dialog;
        r120: Record "Purch. Rcpt. Header";
        r17: Record "G/L Entry";
        C: Codeunit ControlProcesos;
    BEGIN
        if Not Utilidades.PermisoAdm() THEN ERROR('Con que finalidad esta pulsando este botón');
        r120.SETRANGE("Posting Date", 20110101D, 20121231D);
        Ventana.OPEN('Procesando ############1## de ###############2##');
        Ventana.UPDATE(2, rPed.COUNT);
        if r120.FINDFIRST THEN
            REPEAT
                a := a + 1;
                Ventana.UPDATE(1, a);
                r17.SETCURRENTKEY(r17."Document No.", r17."Posting Date");
                r17.SETRANGE(r17."Document No.", r120."No.");
                r17.SETRANGE(r17."Document Type", r17."Document Type"::Receipt);
                if r17.FINDFIRST THEN
                    REPEAT
                        if r17."Job No." = '' THEN BEGIN
                            r17."Job No." := r120."Nº Proyecto";
                            r17.MODIFY;
                        END;
                    UNTIL r17.NEXT = 0;
            UNTIL r120.NEXT = 0;
        Ventana.CLOSE;
    END;

    PROCEDURE GeneraDimensiones2();
    VAR
        r1003: Record 1003;
        rres: Record 156;
        rDim: Record 352;
        a: Integer;
        Ventana: Dialog;
        rLin: Record 37;
        rLinc: Record 39;
        rDetPed: Record 39;
        r121: Record "Purch. Rcpt. Line";
        r17: Record "G/L Entry";
        r113: Record 113;
        //rDoc: Record 359;
        cDim: Codeunit DimensionManagement;
        rLed: Record 355;
        rDim2: Record 352;
        rGr: Record 252;
        r114: Record 115;
    BEGIN
        a := 0;
        Ventana.OPEN('Procesando ############1## de ###############2##');
        Ventana.UPDATE(2, r121.COUNT);

        if r121.FINDFIRST THEN
            REPEAT
                a := a + 1;
                Ventana.UPDATE(1, a);
                if r121.Type = r121.Type::Resource THEN BEGIN
                    if rres.GET(r121."No.") THEN BEGIN
                        //rDoc."Table ID" := 121;
                        //rDoc."Document No." := r121."Document No.";
                        //rDoc."Line No." := r121."Line No.";
                        rDim.SETRANGE(rDim."Table ID", 156);
                        rDim.SETRANGE(rDim."No.", r121."No.");
                        rDim.SETRANGE(rDim."Dimension Code", 'PRINCIPAL');
                        if rDim.FindFirst() Then begin
                            r121.Validate("Shortcut Dimension 3 Code", rDim."Dimension Value Code");
                            Clear(cDim);
                            cDim.ValidateDimValueCode(1, r121."Shortcut Dimension 1 Code");
                            r121.Modify();
                            rDim.SETRANGE(rDim."Dimension Code", 'SOPORTE');
                            if NOT rDim.FINDFIRST THEN BEGIN
                                r1003.SETRANGE(r1003."Job No.", r121."Job No.");
                                r1003.SETFILTER(r1003."Compra a-Nº proveedor", '<>%1', '');
                                if r1003.FINDFIRST THEN BEGIN
                                    rDim2.SETRANGE(rDim2."Table ID", 23);
                                    rDim2.SETRANGE(rDim2."No.", r1003."Compra a-Nº proveedor");
                                    rDim2.SETRANGE(rDim2."Dimension Code", 'SOPORTE');
                                    if rDim2.FINDFIRST THEN BEGIN
                                        r121.Validate("Shortcut Dimension 5 Code", rDim."Dimension Value Code");
                                        Clear(cDim);
                                        cDim.ValidateDimValueCode(5, r121."Shortcut Dimension 5 Code");
                                        r121.Modify();
                                    END;
                                END;
                            END ELSE BEGIN
                                r121.Validate("Shortcut Dimension 5 Code", rDim."Dimension Value Code");
                                Clear(cDim);
                                cDim.ValidateDimValueCode(5, r121."Shortcut Dimension 5 Code");
                                r121.Modify();
                            END;
                            rDim.SETRANGE(rDim."Dimension Code", 'ZONA');
                            rDim.FINDFIRST;
                            r121.Validate("Shortcut Dimension 4 Code", rDim."Dimension Value Code");
                            Clear(cDim);
                            cDim.ValidateDimValueCode(4, r121."Shortcut Dimension 4 Code");
                            r121.Modify();
                            r17.SETCURRENTKEY(r17."Document No.");
                            r17.SETRANGE(r17."Document No.", r121."Document No.");
                            if NOT rGr.GET('NACIONAL', rres."Gen. Prod. Posting Group") THEN
                                r17.SETFILTER(r17."G/L Account No.", '%1', '6*')
                            ELSE
                                r17.SETRANGE(r17."G/L Account No.", rGr."Purch. Account");
                            if NOT r17.FINDFIRST THEN BEGIN
                                r17.SETFILTER(r17."G/L Account No.", '%1', '6*');
                            END;

                            if r17.FINDFIRST THEN
                                REPEAT
                                    rDim.SETRANGE(rDim."Table ID", 156);
                                    rDim.SETRANGE(rDim."No.", r121."No.");
                                    rDim.SETRANGE(rDim."Dimension Code", 'PRINCIPAL');
                                    if rDim.FINDFIRST THEN BEGIN
                                        r17.Validate("Global Dimension 3 Code", rDim."Dimension Value Code");
                                        Clear(cDim);
                                        cDim.ValidateDimValueCode(3, r17."Global Dimension 3 Code");
                                        r17.Modify();
                                    END;
                                    rDim.SETRANGE(rDim."Dimension Code", 'SOPORTE');
                                    if rDim.FINDFIRST THEN BEGIN
                                        r17.Validate("Global Dimension 4 Code", rDim."Dimension Value Code");
                                        Clear(cDim);
                                        cDim.ValidateDimValueCode(4, r17."Global Dimension 4 Code");
                                        r17.Modify();
                                    END;
                                    rDim.SETRANGE(rDim."Dimension Code", 'ZONA');
                                    if rDim.FINDFIRST THEN BEGIN
                                        r17.Validate("Global Dimension 5 Code", rDim."Dimension Value Code");
                                        Clear(cDim);
                                        cDim.ValidateDimValueCode(5, r17."Global Dimension 5 Code");
                                        r17.Modify();
                                    END;

                                UNTIL r17.NEXT = 0;
                        END;
                    END;
                END;
            UNTIL r121.NEXT = 0;
        Ventana.CLOSE;
    END;

    PROCEDURE GeneraDimensiones();
    VAR
        r1003: Record 1003;
        rres: Record 156;
        rDim: Record 352;
        a: Integer;
        Ventana: Dialog;
        rLin: Record 37;
        rLinc: Record 39;
        rDetPed: Record 39;
        r121: Record "Purch. Rcpt. Line";
        r17: Record "G/L Entry";
        r113: Record 113;
        //rDoc: Record 359;
        rLed: Record 355;
        rDim2: Record 352;
        rCab: Record 36;
        rCabc: Record 36;
        r112: Record 112;
        r120: Record "Purch. Rcpt. Header";
        cDim: Codeunit DimensionManagement;
    BEGIN

        Ventana.OPEN('Procesando ############1## de ###############2##');
        Ventana.UPDATE(2, r1003.COUNT);

        if r1003.FINDFIRST THEN
            REPEAT
                a := a + 1;
                Ventana.UPDATE(1, a);
                if r1003.Type = r1003.Type::Resource THEN BEGIN
                    rDim.SETRANGE(rDim."Table ID", 156);
                    rDim.SETRANGE(rDim."No.", r1003."No.");
                    rDim.SETRANGE(rDim."Dimension Code", 'PRINCIPAL');
                    if rDim.FINDFIRST THEN
                        r1003."Shortcut Dimension 3 Code" := rDim."Dimension Value Code";
                    rDim.SETRANGE(rDim."Dimension Code", 'SOPORTE');
                    if NOT rDim.FINDFIRST THEN BEGIN
                        rDim2.SETRANGE(rDim2."Table ID", 23);
                        rDim2.SETRANGE(rDim2."No.", r1003."Compra a-Nº proveedor");
                        rDim2.SETRANGE(rDim2."Dimension Code", 'SOPORTE');
                        if rDim2.FINDFIRST THEN BEGIN
                            r1003.Validate("Shortcut Dimension 5 Code", rDim."Dimension Value Code");
                            Clear(cDim);
                            cDim.ValidateDimValueCode(5, r1003."Shortcut Dimension 4 Code");
                            r1003.Modify();
                        END;
                    END ELSE BEGIN
                        r1003."Shortcut Dimension 5 Code" := rDim."Dimension Value Code";
                    END;
                    rDim.SETRANGE(rDim."Dimension Code", 'ZONA');
                    if rDim.FINDFIRST THEN
                        r1003."Shortcut Dimension 4 Code" := rDim."Dimension Value Code";
                    r1003.MODIFY;
                    rLin.SETCURRENTKEY("Document Type", "Job No.", "No linea proyecto");
                    rLin.SETRANGE(rLin."Job No.", r1003."Job No.");
                    if rLin.FINDFIRST THEN
                        REPEAT
                            if (rCab.GET(rLin."Document Type", rLin."Document No.")) AND
                            (rCab."Posting Date" > 20111231D) THEN BEGIN
                                rLin.ValidateShortcutDimCode(3, r1003."Shortcut Dimension 3 Code");
                                rLin.ValidateShortcutDimCode(5, r1003."Shortcut Dimension 5 Code");
                                rLin.ValidateShortcutDimCode(4, r1003."Shortcut Dimension 4 Code");
                                rLin.MODIFY;
                            END;
                        UNTIL rLin.NEXT = 0;
                    r113.SETRANGE(r113."Line No.");
                    r113.SETCURRENTKEY("Job No.", "No linea proyecto");
                    r113.SETRANGE("Job No.", r1003."Job No.");
                    r113.SETRANGE(r113."No linea proyecto", r1003."Line No.");
                    if NOT r113.FINDFIRST THEN BEGIN
                        r113.SETRANGE(r113."Line No.", r1003."Line No.");
                        r113.SETRANGE(r113."No linea proyecto");
                    END;
                    if r113.FINDFIRST THEN
                        REPEAT
                            if (r112.GET(r113."Document No.")) AND
                            (r112."Posting Date" > 20111231D) THEN BEGIN

                                //if r113.Type=r113.Type::Resource THEN BEGIN
                                //rDoc."Table ID" := 113;
                                //rDoc."Document Type":=rDoc."Document Type"::Invoice;
                                //rDoc."Document No." := r113."No.";
                                rDim.SETRANGE(rDim."Table ID", 156);
                                rDim.SETRANGE(rDim."No.", r113."No.");
                                rDim.SETRANGE(rDim."Dimension Code", 'PRINCIPAL');
                                if rDim.FINDFIRST THEN BEGIN
                                    //rDoc."Dimension Code" := 'PRINCIPAL';
                                    //rDoc."Dimension Value Code" := rDim."Dimension Value Code";
                                    //if rDoc.INSERT THEN;
                                    r113.Validate("Shortcut Dimension 3 Code", rDim."Dimension Value Code");
                                    Clear(cDim);
                                    cDim.ValidateDimValueCode(3, r113."Shortcut Dimension 3 Code");
                                    r113.Modify();
                                END;
                                rDim.SETRANGE(rDim."Dimension Code", 'SOPORTE');
                                if NOT rDim.FINDFIRST THEN BEGIN
                                    rDim2.SETRANGE(rDim2."Table ID", 23);
                                    rDim2.SETRANGE(rDim2."No.", r1003."Compra a-Nº proveedor");
                                    rDim2.SETRANGE(rDim2."Dimension Code", 'SOPORTE');
                                    if rDim2.FINDFIRST THEN BEGIN
                                        //rDoc."Dimension Code" := 'SOPORTE';
                                        //rDoc."Dimension Value Code" := rDim."Dimension Value Code";
                                        //if rDoc.INSERT THEN;
                                        r113.Validate("Shortcut Dimension 5 Code", rDim."Dimension Value Code");
                                        Clear(cDim);
                                        cDim.ValidateDimValueCode(5, r113."Shortcut Dimension 5 Code");
                                        r113.Modify();
                                    END;
                                END ELSE BEGIN
                                    //rDoc."Dimension Code" := 'SOPORTE';
                                    //rDoc."Dimension Value Code" := rDim."Dimension Value Code";
                                    //if rDoc.INSERT THEN;
                                    r113.Validate("Shortcut Dimension 5 Code", rDim."Dimension Value Code");
                                    Clear(cDim);
                                    cDim.ValidateDimValueCode(5, r113."Shortcut Dimension 5 Code");
                                    r113.Modify();
                                END;
                                rDim.SETRANGE(rDim."Dimension Code", 'ZONA');
                                if rDim.FINDFIRST THEN BEGIN
                                    //rDoc."Dimension Code" := 'ZONA';
                                    //rDoc."Dimension Value Code" := rDim."Dimension Value Code";
                                    //if rDoc.INSERT THEN;
                                    r113.Validate("Shortcut Dimension 4 Code", rDim."Dimension Value Code");
                                    Clear(cDim);
                                    cDim.ValidateDimValueCode(4, r113."Shortcut Dimension 4 Code");
                                    r113.Modify();
                                END;
                                r17.SETCURRENTKEY(r17."Document No.");
                                r17.SETRANGE(r17."Document No.", r113."Document No.");
                                if r17.FINDFIRST THEN
                                    REPEAT
                                        rDim.SETRANGE(rDim."Table ID", 156);
                                        rDim.SETRANGE(rDim."No.", r113."No.");
                                        rDim.SETRANGE(rDim."Dimension Code", 'PRINCIPAL');
                                        if rDim.FINDFIRST THEN BEGIN
                                            // rLed."Dimension Code" := 'PRINCIPAL';
                                            // rLed."Dimension Value Code" := rDim."Dimension Value Code";
                                            // if rLed.INSERT THEN;
                                            r17.Validate("Global Dimension 3 Code", rDim."Dimension Value Code");
                                            Clear(cDim);
                                            cDim.ValidateDimValueCode(3, r17."Global Dimension 3 Code");
                                            r17.Modify();
                                        END;
                                        rDim.SETRANGE(rDim."Dimension Code", 'ZONA');
                                        if rDim.FINDFIRST THEN BEGIN
                                            /* rLed."Dimension Code" := 'SOPORTE';
                                            rLed."Dimension Value Code" := rDim."Dimension Value Code";
                                            if rLed.INSERT THEN; */
                                            r17.Validate("Global Dimension 4 Code", rDim."Dimension Value Code");
                                            Clear(cDim);
                                            cDim.ValidateDimValueCode(4, r17."Global Dimension 4 Code");
                                            r17.Modify();
                                        END;
                                        rDim.SETRANGE(rDim."Dimension Code", 'SOPORTE');
                                        if rDim.FINDFIRST THEN BEGIN
                                            /* rLed."Dimension Code" := 'ZONA';
                                            rLed."Dimension Value Code" := rDim."Dimension Value Code";
                                            if rLed.INSERT THEN; */
                                            r17.Validate("Global Dimension 5 Code", rDim."Dimension Value Code");
                                            Clear(cDim);
                                            cDim.ValidateDimValueCode(5, r17."Global Dimension 5 Code");
                                            r17.Modify();
                                        END;
                                    UNTIL r17.NEXT = 0;
                            END;
                        UNTIL r113.NEXT = 0;
                    rDetPed.SETCURRENTKEY("Job No.");
                    rDetPed.SETRANGE(rDetPed."Line No.");
                    rDetPed.SETRANGE(rDetPed."Job No.", r1003."Job No.");
                    rDetPed.SETRANGE(rDetPed."Linea de proyecto", r1003."Line No.");
                    if NOT rDetPed.FINDFIRST THEN BEGIN
                        rDetPed.SETRANGE(rDetPed."Linea de proyecto");
                        rDetPed.SETRANGE(rDetPed."Line No.", r1003."Line No.");
                    END;
                    if rDetPed.FINDFIRST THEN
                        REPEAT
                            r121.SETCURRENTKEY("Order No.", "Order Line No.");
                            r121.SETRANGE(r121."Order No.", rDetPed."Document No.");
                            r121.SETRANGE(r121."Order Line No.", rDetPed."Line No.");
                            if r121.FINDFIRST THEN
                                REPEAT
                                    if (r120.GET(r121."Document No.")) AND
                                    (r120."Posting Date" > 20111231D) THEN BEGIN

                                        r121.Type := r121.Type::Resource;
                                        r121."No." := r1003."No.";
                                        r121.MODIFY;
                                        if r121.Type = r121.Type::Resource THEN BEGIN
                                            //rDoc."Table ID" := 121;
                                            //rDoc."Document Type":=rDoc."Document Type"::Invoice;
                                            //rDoc."Document No." := r121."Document No.";
                                            //rDoc."Line No." := r121."Line No.";
                                            rDim.SETRANGE(rDim."Table ID", 156);
                                            rDim.SETRANGE(rDim."No.", r121."No.");
                                            rDim.SETRANGE(rDim."Dimension Code", 'PRINCIPAL');
                                            if rDim.FINDFIRST THEN BEGIN
                                                /*   rDoc."Dimension Code" := 'PRINCIPAL';
                                                  rDoc."Dimension Value Code" := rDim."Dimension Value Code";
                                                  if rDoc.INSERT THEN; */
                                                r121.Validate("Shortcut Dimension 3 Code", rDim."Dimension Value Code");
                                                Clear(cDim);
                                                cDim.ValidateDimValueCode(3, r121."Shortcut Dimension 3 Code");
                                                r121.Modify();
                                            END;
                                            rDim.SETRANGE(rDim."Dimension Code", 'SOPORTE');
                                            if NOT rDim.FINDFIRST THEN BEGIN
                                                rDim2.SETRANGE(rDim2."Table ID", 23);
                                                rDim2.SETRANGE(rDim2."No.", r1003."Compra a-Nº proveedor");
                                                rDim2.SETRANGE(rDim2."Dimension Code", 'SOPORTE');
                                                if rDim2.FINDFIRST THEN BEGIN
                                                    /* rDoc."Dimension Code" := 'SOPORTE';
                                                    rDoc."Dimension Value Code" := rDim."Dimension Value Code";
                                                    if rDoc.INSERT THEN; */
                                                    r121.Validate("Shortcut Dimension 5 Code", rDim."Dimension Value Code");
                                                    Clear(cDim);
                                                    cDim.ValidateDimValueCode(5, r121."Shortcut Dimension 5 Code");
                                                    r121.Modify();
                                                END;
                                            END ELSE BEGIN

                                                /* rDoc."Dimension Code" := 'SOPORTE';
                                                rDoc."Dimension Value Code" := rDim."Dimension Value Code";
                                                if rDoc.INSERT THEN; */
                                                r121.Validate("Shortcut Dimension 5 Code", rDim."Dimension Value Code");
                                                Clear(cDim);
                                                cDim.ValidateDimValueCode(5, r121."Shortcut Dimension 5 Code");
                                                r121.Modify();
                                            END;
                                            rDim.SETRANGE(rDim."Dimension Code", 'ZONA');
                                            if rDim.FINDFIRST THEN BEGIN
                                                /* rDoc."Dimension Code" := 'ZONA';
                                                rDoc."Dimension Value Code" := rDim."Dimension Value Code";
                                                if rDoc.INSERT THEN; */
                                                r121.Validate("Shortcut Dimension 4 Code", rDim."Dimension Value Code");
                                                Clear(cDim);
                                                cDim.ValidateDimValueCode(4, r121."Shortcut Dimension 4 Code");
                                                r121.Modify();
                                            END;
                                            r17.SETCURRENTKEY(r17."Document No.");
                                            r17.SETRANGE(r17."Document No.", r121."Document No.");
                                            if r17.FINDFIRST THEN
                                                REPEAT
                                                    //rLed."Table ID" := 17;
                                                    //rLed."Entry No." := r17."Entry No.";
                                                    rDim.SETRANGE(rDim."Table ID", 156);
                                                    rDim.SETRANGE(rDim."No.", r121."No.");
                                                    rDim.SETRANGE(rDim."Dimension Code", 'PRINCIPAL');
                                                    if rDim.FINDFIRST THEN BEGIN
                                                        /*   rLed."Dimension Code" := 'PRINCIPAL';
                                                          rLed."Dimension Value Code" := rDim."Dimension Value Code";
                                                          if rLed.INSERT THEN; */
                                                        r17.Validate("Global Dimension 3 Code", rDim."Dimension Value Code");
                                                        Clear(cDim);
                                                        cDim.ValidateDimValueCode(3, r17."Global Dimension 3 Code");
                                                        r17.Modify();
                                                    END;
                                                    rDim.SETRANGE(rDim."Dimension Code", 'SOPORTE');
                                                    if rDim.FINDFIRST THEN BEGIN
                                                        /* rLed."Dimension Code" := 'SOPORTE';
                                                        rLed."Dimension Value Code" := rDim."Dimension Value Code";
                                                        if rLed.INSERT THEN; */
                                                        r17.Validate("Global Dimension 5 Code", rDim."Dimension Value Code");
                                                        Clear(cDim);
                                                        cDim.ValidateDimValueCode(5, r17."Global Dimension 5 Code");
                                                        r17.Modify();
                                                    END;
                                                    rDim.SETRANGE(rDim."Dimension Code", 'ZONA');
                                                    if rDim.FINDFIRST THEN BEGIN
                                                        /* rLed."Dimension Code" := 'ZONA';
                                                        rLed."Dimension Value Code" := rDim."Dimension Value Code";
                                                        if rLed.INSERT THEN; */
                                                        r17.Validate("Global Dimension 4 Code", rDim."Dimension Value Code");
                                                        Clear(cDim);
                                                        cDim.ValidateDimValueCode(4, r17."Global Dimension 4 Code");
                                                        r17.Modify();
                                                    END;

                                                UNTIL r17.NEXT = 0;

                                        END;
                                    END;
                                UNTIL r121.NEXT = 0;
                            rDetPed.Type := rDetPed.Type::Resource;
                            rDetPed."No." := r1003."No.";
                            rDetPed.MODIFY;
                        UNTIL rDetPed.NEXT = 0;

                END;
            UNTIL r1003.NEXT = 0;
        Ventana.CLOSE;
    END;

    // PROCEDURE RenumReserva(NumNou: Integer; NumDia: Integer);
    // VAR
    //     rRes: Record Reserva;
    //     rRes2: Record Reserva Temporary;
    //     rdRes: Record "Diario Reserva";
    //     rdRes2: Record "Diario Reserva" temporary;
    // BEGIN
    //     if rRes.FINDFIRST THEN
    //         REPEAT
    //             rRes2 := rRes;
    //             rRes2."Nº Reserva" := NumNou;
    //             rRes2.INSERT;
    //             NumNou := NumNou + 1;
    //             rdRes.SETRANGE(rdRes."Nº Reserva", rRes."Nº Reserva");
    //             if rdRes.FINDFIRST THEN
    //                 REPEAT
    //                     rdRes2 := rdRes;
    //                     rdRes2."Nº Reserva" := rRes2."Nº Reserva";
    //                     rdRes2.INSERT;
    //                 UNTIL rdRes2.NEXT = 0;
    //             rdRes.DELETEALL;
    //         UNTIL rRes.NEXT = 0;
    //     rRes.DELETEALL;
    //     if rRes2.FINDFIRST THEN
    //         REPEAT
    //             rRes := rRes2;
    //             rRes.INSERT;
    //         UNTIL rRes2.NEXT = 0;
    //     if rdRes2.FINDFIRST THEN
    //         REPEAT
    //             rdRes := rdRes2;
    //             rdRes.INSERT;
    //         UNTIL rdRes2.NEXT = 0;
    // END;

    // PROCEDURE RecuReserva();
    // VAR
    //     rRes: Record Reserva;
    //     rRes2: Record Reserva temporary;
    //     rdRes: Record "Diario Reserva";
    //     rdRes2: Record "Diario Reserva";
    //     rReserva: Record Reserva;
    //     rLinea: Record 1003;
    //     rRecurs2: Record 156;
    //     rProy: Record 167;
    // BEGIN
    //     rdRes.FINDFIRST;
    //     REPEAT
    //         rdRes2.SETRANGE(rdRes2."Nº Reserva", rdRes."Nº Reserva");
    //         rdRes2.FINDLAST;
    //         rReserva."Nº Reserva" := rdRes."Nº Reserva";
    //         rReserva."Fecha inicio" := rdRes.Fecha;
    //         rReserva."Fecha fin" := rdRes2.Fecha;
    //         rReserva."Nº Recurso" := rdRes."Nº Recurso";
    //         if rRecurs2.GET(rdRes."Nº Recurso") THEN
    //             rReserva.Descripción := rRecurs2.Name;
    //         rReserva.Estado := rdRes.Estado;
    //         if rProy.GET(rdRes."Nº Proyecto") THEN
    //             rReserva."Cód. Cliente" := rProy."Bill-to Customer No.";
    //         rReserva."Nº Proyecto" := rdRes."Nº Proyecto";
    //         /*{
    //         rReserva."Cód. fase"          := rLinea."Phase Code";
    //         rReserva."Cód. subfase"       := rLinea."Task Code";
    //         }*/
    //         //if rLinea.GET(rdRes."Nº Proyecto",rdRes."Cód. tarea",rdRes."Nº linea proyecto") Then
    //         rReserva."Cód. tarea" := rdRes."Cód. tarea";
    //         //$003
    //         rReserva."Nº linea proyecto" := rdRes."Nº linea proyecto";
    //         rReserva."Tipo (presupuesto)" := rdRes."Tipo (presupuesto)";
    //         rReserva."Nº (presupuesto)" := rdRes."Nº (presupuesto)";
    //         rReserva."Nº fam. recurso" := rRecurs2."Resource Group No.";
    //         if rLinea.GET(rdRes."Nº Proyecto", rdRes."Cód. tarea", rdRes."Nº linea proyecto") THEN
    //             rReserva."Cód. variante (presupuesto)" := rLinea."Variant Code";
    //         // $002-
    //         if Strpos(UserId, '\') <> 0 Then
    //             rReserva."Usuario creacion" := Copystr(USERID, 11)
    //         else
    //             rReserva."Usuario creacion" := UserId;
    //         rReserva."Fecha creacion" := CURRENTDATETIME;

    //         rReserva."No Pay" := rProy."No Pay";
    //         rReserva."Proyecto de fijación" := rProy."Proyecto de fijación";
    //         rReserva."Tipo de Fijación" := rProy."Tipo de Fijación";
    //         if ((UPPERCASE(COPYSTR(rProy.Description, 1, 2)) = 'B ') OR
    //             (UPPERCASE(COPYSTR(rProy.Description, 1, 2)) = 'R-') OR
    //             (UPPERCASE(COPYSTR(rProy.Description, 1, 2)) = 'R ') OR
    //             (UPPERCASE(COPYSTR(rProy.Description, 1, 4)) = 'GRIS') OR
    //             (STRPOS(UPPERCASE(rProy.Description), 'S/C') <> 0)) THEN
    //             rReserva."Sin Cargo" := TRUE;

    //         // $002+
    //         if rReserva.INSERT THEN;

    //     UNTIL rdRes.NEXT = 0;
    // END;

    PROCEDURE Pasa_ContratoCompraPer(rProyecto: Record 167; Contrato: Record 36);
    VAR
        rLin: Record 1003;
        rSetup: Record "Jobs Setup";
        Vendor: Record Vendor;
    BEGIN

        /*{finestra.OPEN('Creando pedidos de venta');
        rLin.SETCURRENTKEY("Job No.","Crear pedidos","Compra a-Nº proveedor");
        rLin.SETRANGE("Job No.", rProyecto."No.");
        rLin.SETFILTER("Crear pedidos", '%1|%2',rLin."Crear pedidos"::"De Venta",
                                                rLin."Crear pedidos"::"De Compra Y De Venta");

        if rLin.FIND('-') THEN
          Pedido_Venta(rProyecto, rLin);
        finestra.CLOSE; }*/
        rSetup.Get();
        finestra.OPEN('Creando pedidos de compra');
        rLin.SETCURRENTKEY("Job No.", "Crear pedidos", "Compra a-Nº proveedor");
        rLin.SETRANGE("Job No.", rProyecto."No.");
        rLin.SETFILTER("Crear pedidos", '%1|%2', rLin."Crear pedidos"::"De Compra Y De Venta",
                                                rLin."Crear pedidos"::"De Compra");
        if rLin.FIND('-') THEN
            rLin.TESTFIELD(rLin."Compra a-Nº proveedor");
        if rSetup."Crear Factura Interempresas" then
            if Vendor.Get(rLin."Compra a-Nº proveedor") then
                if Vendor."IC Partner Code" <> '' Then Error('No se puede crear pedidos para empresas del grupo');
        Pedido_CompraPer(rProyecto, rLin, Contrato);
        finestra.CLOSE;

        MESSAGE('Proceso finalizado');
    END;

    PROCEDURE Pedido_CompraPer(VAR rProyC: Record 167; VAR rLineaC: Record 1003; VAR Contrato: Record 36);
    VAR
        aux_p: Code[20];
        rL2: Record 1003;
        cProyecto: Codeunit 50002;
    BEGIN
        aux_p := '';
        if rLineaC.FIND('-') THEN
            REPEAT
                if (aux_p <> rLineaC."Compra a-Nº proveedor") THEN BEGIN
                    aux_p := rLineaC."Compra a-Nº proveedor";
                    rL2.COPYFILTERS(rLineaC);
                    rL2 := rLineaC;
                    rL2.SETRANGE("Compra a-Nº proveedor", rLineaC."Compra a-Nº proveedor");
                    CLEAR(iCompra);
                    iCompra.Coge_RegistrosPer(rProyC, rL2);
                    iCompra.RUNMODAL;
                    rL2.RESET;
                END;
            UNTIL rLineaC.NEXT = 0;
        CLEAR(cProyecto);
    END;

    // PROCEDURE Cuenta(Empla: Code[20]): Integer;
    // VAR
    //     b: Integer;
    //     rTipo: Record "Tipo Recurso";
    // BEGIN
    //     Recursos.SETRANGE(Recursos."Nº Emplazamiento", Emplazamientos."Nº Emplazamiento");
    //     if Recursos.FINDFIRST THEN BEGIN
    //         REPEAT
    //             if rRes.GET(Recursos."Nº Recurso") THEN BEGIN
    //                 if rTipo.GET(rRes."Tipo Recurso") THEN BEGIN
    //                     if rTipo."Cód. Principal" <> '1020' THEN b := b + 1;
    //                 END;
    //             END;
    //         UNTIL Recursos.NEXT = 0;
    //     END ELSE
    //         EXIT(999);
    //     EXIT(b);
    // END;

    // PROCEDURE GeneraActivo(Emplaza: Code[20]; Proveedor: Code[20]);
    // VAR
    //     rTipo: Record "Tipo Recurso";
    //     Existe: Boolean;
    // BEGIN
    //     Emplazamientos.SETRANGE(Emplazamientos."Nº Emplazamiento", Emplaza);
    //     Emplazamientos.SETRANGE(Emplazamientos."Nº Proveedor", Proveedor);
    //     Emplazamientos.SETFILTER(Emplazamientos."Fecha firma contrato", '<>%1', 0D);
    //     Emplazamientos.SETFILTER(Emplazamientos."Fecha vto. contrato", '<>%1', 0D);
    //     Emplazamientos.SETRANGE(Emplazamientos.Estado, Emplazamientos.Estado::Alta);
    //     //if Not Emplazamientos.FINDFIRST Then
    //     //ERROR('Revise los datos de este emplazamiento, No son correctos');
    //     if Emplazamientos.FINDFIRST THEN
    //         REPEAT
    //             Existe := CompruebaCambioproveedor(Emplaza, Proveedor);
    //             if Emplazamientos."Fecha firma contrato Des" = 0D THEN
    //                 Emplazamientos."Fecha firma contrato Des" := Emplazamientos."Fecha firma contrato";
    //             if Emplazamientos."Fecha vto. contrato Des" = 0D THEN
    //                 Emplazamientos."Fecha vto. contrato Des" := Emplazamientos."Fecha vto. contrato";
    //             rRest."No." := Emplazamientos."Nº Emplazamiento";
    //             if rRest.INSERT THEN BEGIN
    //                 r5600."No." := Emplazamientos."Nº Emplazamiento" + '-' + Emplazamientos."Nº Proveedor";
    //                 r5600.Description := 'Desm. Empl Nº ' + Emplazamientos."Nº Emplazamiento";
    //                 r5600."Search Description" := r5600.Description;
    //                 r5600."Description 2" := COPYSTR(Emplazamientos.Descripción, 1, MAXSTRLEN(r5600.Description));
    //                 r5600."Vendor No." := Emplazamientos."Nº Proveedor";
    //                 r5600."Main Asset/Component" := r5600."Main Asset/Component"::"Main Asset";
    //                 r5600."FA Posting Group" := 'DESMONTAJE';
    //                 r5600.Emplazamiento := Emplazamientos."Nº Emplazamiento";
    //                 Recursos.SETRANGE(Recursos."Nº Emplazamiento", Emplazamientos."Nº Emplazamiento");
    //                 a := Cuenta(Emplazamientos."Nº Emplazamiento");
    //                 if a > 0 THEN BEGIN
    //                     if a = 999 THEN BEGIN
    //                         r5600."No Recursos" := 1;
    //                         r5600."Mód. Montado" := Emplazamientos."Módulo montado";
    //                         if r5600."Mód. Montado" < 1 THEN r5600."Mód. Montado" := 1;
    //                         r5600.INSERT;
    //                         if Existe THEN
    //                             r56002."No." := Emplazamientos."Nº Emplazamiento" + '-Y'
    //                         ELSE
    //                             r56002."No." := Emplazamientos."Nº Emplazamiento";
    //                         r56002.Description := 'Desm. recu. Nº ' + Emplazamientos."Nº Emplazamiento";
    //                         r56002."Search Description" := r56002.Description;
    //                         r56002."Description 2" := COPYSTR(Emplazamientos."Nº Emplazamiento", 1, MAXSTRLEN(r5600.Description));
    //                         r56002."Vendor No." := Emplazamientos."Nº Proveedor";
    //                         r56002."FA Posting Group" := 'DESMONTAJE';
    //                         r56002."Main Asset/Component" := r56002."Main Asset/Component"::Component;
    //                         r56002."Component of Main Asset" := r5600."No.";
    //                         r56002.Emplazamiento := Emplazamientos."Nº Emplazamiento";
    //                         r56122."FA No." := r56002."No.";
    //                         r56122."Depreciation Book Code" := 'CONTABLE';
    //                         r56122."FA Posting Group" := 'DESMONTAJE';
    //                         r56122."Depreciation Method" := r56122."Depreciation Method"::"Straight-Line";
    //                         r56122."Depreciation Starting Date" := Emplazamientos."Fecha firma contrato Des";
    //                         r56122."G/L Acquisition Date" := r56122."Depreciation Starting Date";
    //                         r56122."No. of Depreciation Years" := DATE2DMY(Emplazamientos."Fecha vto. contrato Des", 3) -
    //                                                             DATE2DWY(r56122."Depreciation Starting Date", 3);
    //                         r56002."No Recursos" := 1;
    //                         r56002."Mód. Montado" := Emplazamientos."Módulo montado";
    //                         r56002.Recurso := '';//Recursos."Nº Recurso";
    //                         if r56002."Mód. Montado" < 1 THEN r56002."Mód. Montado" := 1;
    //                         if r56122.INSERT THEN;
    //                         r56002.INSERT;
    //                         r5612."FA No." := r5600."No.";
    //                         r5612."Depreciation Book Code" := 'CONTABLE';
    //                         r5612."Depreciation Method" := r5612."Depreciation Method"::"Straight-Line";
    //                         r5612."Depreciation Starting Date" := Emplazamientos."Fecha firma contrato Des";
    //                         r5612."G/L Acquisition Date" := r5612."Depreciation Starting Date";
    //                         r5612."FA Posting Group" := 'DESMONTAJE';
    //                         r5612."No. of Depreciation Years" := DATE2DMY(Emplazamientos."Fecha vto. contrato Des", 3) -
    //                         DATE2DWY(r5612."Depreciation Starting Date", 3);
    //                         if r5612.INSERT THEN;

    //                     END ELSE BEGIN
    //                         r5600."No Recursos" := a;
    //                         r5600."Mód. Montado" := Emplazamientos."Módulo montado";
    //                         if r5600."Mód. Montado" < 1 THEN r5600."Mód. Montado" := 1;
    //                         if r5600.INSERT THEN;
    //                         if Recursos.FINDFIRST THEN
    //                             REPEAT
    //                                 if rRes.GET(Recursos."Nº Recurso") THEN BEGIN
    //                                     if rTipo.GET(rRes."Tipo Recurso") THEN BEGIN
    //                                         if rTipo."Cód. Principal" <> '1020' THEN BEGIN
    //                                             if Existe THEN
    //                                                 r56002."No." := Recursos."Nº Recurso" + '-' + Emplazamientos."Nº Emplazamiento" + '-Y'
    //                                             ELSE
    //                                                 r56002."No." := Recursos."Nº Recurso" + '-' + Emplazamientos."Nº Emplazamiento";
    //                                             r56002.Description := 'Desm. recu. Nº ' + Recursos."Nº Recurso";
    //                                             r56002."Search Description" := r56002.Description;
    //                                             r56002."Description 2" := COPYSTR(Recursos."Descripción recurso", 1, MAXSTRLEN(r5600.Description));
    //                                             r56002."Vendor No." := Emplazamientos."Nº Proveedor";
    //                                             r56002."FA Posting Group" := 'DESMONTAJE';
    //                                             r56002."Main Asset/Component" := r56002."Main Asset/Component"::Component;
    //                                             r56002."Component of Main Asset" := r5600."No.";
    //                                             r56002.Emplazamiento := Emplazamientos."Nº Emplazamiento";
    //                                             r56122."FA No." := r56002."No.";
    //                                             r56122."Depreciation Book Code" := 'CONTABLE';
    //                                             r56122."FA Posting Group" := 'DESMONTAJE';
    //                                             r56122."Depreciation Method" := r56122."Depreciation Method"::"Straight-Line";
    //                                             r56122."Depreciation Starting Date" := Emplazamientos."Fecha firma contrato Des";
    //                                             r56122."G/L Acquisition Date" := r56122."Depreciation Starting Date";
    //                                             r56122."No. of Depreciation Years" := DATE2DMY(Emplazamientos."Fecha vto. contrato Des", 3) -
    //                                                                                 DATE2DWY(r56122."Depreciation Starting Date", 3);
    //                                             r56002."No Recursos" := a;
    //                                             r56002."Mód. Montado" := Emplazamientos."Módulo montado";
    //                                             r56002.Recurso := Recursos."Nº Recurso";
    //                                             if r56002."Mód. Montado" < 1 THEN r56002."Mód. Montado" := 1;
    //                                             if r56122.INSERT THEN;
    //                                             if r56002.INSERT THEN;
    //                                         END;
    //                                     END;
    //                                 END;
    //                             UNTIL Recursos.NEXT = 0;
    //                         r5612."FA No." := r5600."No.";
    //                         r5612."Depreciation Book Code" := 'CONTABLE';
    //                         r5612."FA Posting Group" := 'DESMONTAJE';
    //                         r5612."Depreciation Method" := r5612."Depreciation Method"::"Straight-Line";
    //                         r5612."Depreciation Starting Date" := Emplazamientos."Fecha firma contrato Des";
    //                         r5612."G/L Acquisition Date" := r5612."Depreciation Starting Date";
    //                         r5612."No. of Depreciation Years" := DATE2DMY(Emplazamientos."Fecha vto. contrato Des", 3) -
    //                         DATE2DWY(r5612."Depreciation Starting Date", 3);
    //                         if r5612.INSERT THEN;
    //                     END;
    //                 END;
    //             END;
    //             r56002.RESET;
    //             r56002.SETRANGE(r56002."FA Posting Group", 'DESMONTAJE');
    //             r56002.SETRANGE(r56002."Main Asset/Component", r56002."Main Asset/Component"::Component);
    //             r56002.SETRANGE(Emplazamiento, Emplazamientos."Nº Emplazamiento");
    //             if r56002.FINDFIRST THEN
    //                 REPEAT
    //                     Importe := 295.56;
    //                     if (COPYSTR(r56002."No.", 1, 2) = '40') AND (r56002.Recurso <> '') THEN
    //                         Importe := 5432;
    //                     Import := Importe * r56002."Mód. Montado";
    //                     Import := Import / r56002."No Recursos";
    //                     r81.SETRANGE(r81."Journal Template Name", 'ACTIVOS');
    //                     r81.SETRANGE(r81."Journal Batch Name", 'GENERICO');
    //                     if r81.FINDLAST THEN Linea := r81."Line No.";
    //                     r81.INIT;
    //                     r81."Journal Template Name" := 'ACTIVOS';
    //                     r81."Journal Batch Name" := 'GENERICO';
    //                     r81."Line No." := Linea + 10000;
    //                     r81."Account Type" := r81."Account Type"::"Fixed Asset";
    //                     r81."Posting Date" := WORKDATE;
    //                     r81.VALIDATE("Account No.", r56002."No.");
    //                     r81."Document No." := r5600."No.";
    //                     r81."FA Posting Type" := r81."FA Posting Type"::"Acquisition Cost";
    //                     r81.VALIDATE("Debit Amount", Import);
    //                     r81."Bal. Account No." := '143000060';
    //                     r81.INSERT;

    //                 UNTIL r56002.NEXT = 0;
    //         UNTIL Emplazamientos.NEXT = 0;
    // END;

    PROCEDURE EnviarMailAz(Documento: Code[20]);
    VAR
        ruser: Record 91;
    //cSmtp: codeunit 400;
    BEGIN
        if NOT ruser.GET(USERID) THEN BEGIN
            ruser."User ID" := USERID;
            ruser.INSERT;
        END;
        ruser.Documento := Documento;
        ruser.MODIFY;
        /* {
        COMMIT;
        CLEAR(cSmtp);
        if cSmtp.RUN THEN;

        CLEAR(Smtp);
        Smtp.CreateMessage('Navision','info@malla.es','juan@grepsa.com','Recurso de baja '+Documento,'',FALSE);
        Smtp.AddCC('lllompart@malla.es');
        Smtp.AppendBody('Revisar el Recurso '+ Documento+' ');
        Smtp.AppendBody('de la empresa '+COMPANYNAME+'. ');
        Smtp.AppendBody('Se ha generado un apunte de baja');
        Smtp.AppendBody('en Diarios Generales AF sección GENERICO');
        Smtp.Send;
         } */
    END;

    PROCEDURE CompruebaCambioproveedor(Emplazamiento: Code[20]; Proveedor: Code[20]): Boolean;
    VAR
        r5600: Record 5600;
        r5600c: Record 5600;
        Existe: Boolean;
    BEGIN
        Existe := FALSE;
        if r5600.GET(Emplazamiento + '-' + Proveedor) THEN ERROR('Compruebe que sucede porque para este proveedor ya existe el activo');
        r5600.SETFILTER(r5600."No.", '%1', Emplazamiento + '-*');
        r5600.SETRANGE(r5600."Main Asset/Component", r5600."Main Asset/Component"::"Main Asset");
        if r5600.FINDFIRST THEN BEGIN
            r5600c.SETRANGE(r5600c."Component of Main Asset", r5600."No.");
            if r5600c.FINDFIRST THEN
                REPEAT
                    //  r5600c.CALCFIELDS(r5600c.Recurso);
                    Baja(r5600c."No.", r5600c.Recurso);
                UNTIL r5600c.NEXT = 0;
            r5600.Inactive := TRUE;
            r5600.Blocked := TRUE;
            r5600.MODIFY;
            Existe := TRUE;
        END;
        EXIT(Existe);
    END;

    PROCEDURE Baja(Activo: Code[20]; Recurso: Code[20]);
    VAR
        Acti: Record 5600;
        Lib: Record 5612;
    BEGIN
        if Activo = '' THEN EXIT;
        r56002.RESET;
        r56002.SETRANGE(r56002."No.", Activo);
        if r56002.FINDFIRST THEN
            REPEAT
                if NOT r56002."Baja 143" THEN BEGIN
                    Lib.SETRANGE(Lib."FA No.", r56002."No.");
                    Lib.FINDFIRST;
                    if Lib."Disposal Date" = 0D THEN BEGIN

                        r56002."Baja 143" := TRUE;
                        r56002.MODIFY;
                        r56002.CALCFIELDS(Coste);
                        Importe := r56002.Coste;
                        r81.SETRANGE(r81."Journal Template Name", 'ACTIVOS');
                        r81.SETRANGE(r81."Journal Batch Name", 'GENERICO');
                        if r81.FINDLAST THEN Linea := r81."Line No.";
                        r81.INIT;
                        r81."Journal Template Name" := 'ACTIVOS';
                        r81."Journal Batch Name" := 'GENERICO';
                        r81."Document No." := Activo;
                        r81."Line No." := Linea + 10000;
                        r81."Account Type" := r81."Account Type"::"G/L Account";
                        r81."Posting Date" := WORKDATE;
                        r81.VALIDATE("Account No.", '771000001');
                        r81."Document No." := r56002."No.";
                        //r81."FA Posting Type":=r81."FA Posting Type"::Disposal;
                        r81.VALIDATE("Credit Amount", Importe);
                        r81."Bal. Account No." := '143000060';
                        r81.INSERT;

                        Importe := 0;
                        r81.SETRANGE(r81."Journal Template Name", 'ACTIVOS');
                        r81.SETRANGE(r81."Journal Batch Name", 'GENERICO');
                        if r81.FINDLAST THEN Linea := r81."Line No.";
                        r81.INIT;
                        r81."Journal Template Name" := 'ACTIVOS';
                        r81."Journal Batch Name" := 'GENERICO';
                        r81."Document No." := Activo;
                        r81."Line No." := Linea + 10000;
                        r81."Account Type" := r81."Account Type"::"Fixed Asset";
                        r81."Posting Date" := WORKDATE;
                        r81.VALIDATE("Account No.", r56002."No.");
                        r81."Document No." := r56002."No.";
                        r81."FA Posting Type" := r81."FA Posting Type"::Disposal;
                        r81.VALIDATE("Debit Amount", Importe);
                        // r81."Bal. Account No.":='143000060';
                        r81.INSERT;
                    END;
                END;
            UNTIL r56002.NEXT = 0;
        //EnviarMailAz(Recurso);
    END;
}










