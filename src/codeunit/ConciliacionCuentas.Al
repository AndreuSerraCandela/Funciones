/// <summary>
/// Codeunit Funciones conciliacion cuenta (ID 7001110).
/// </summary>
codeunit 7001110 "Funciones conciliacion cuenta"
{
    Permissions = TableData "G/L Entry" = m;
    trigger OnRun()
    BEGIN
        //Conciliacion_Automatica;
        RehacelGlEntrysCont;
        //PonerFechaConciliacion;
    END;

    VAR
        glLabel100: Label 'Conciliación Normal\ \';
        glLabel102: Label 'Conciliación FPR\ \';
        glLabel104: Label 'Debe marcar algun %1 para conciliar.';
        glLabel105: Label 'La suma de los importes a conciliar debe ser 0.';
        glLabel106: Label 'Conciliación automática.';
        glLabel107: Label 'No hay movimientos para desliquidar.';
        glLabel108: Label '" - desconciliacion"';
        glLabel109: Label '¿Seguro que desea desconciliar los movimientos seleccionados?';
        glLabel110: Label 'Debe especificar una cuenta para conciliar.';
        glLabel111: Label '"  Cuenta      #1######## @2@@@@@@@@@\"';
        glLabel112: Label '"  Movs. conc. #3########"';
        glLabel113: Label '¿Confirma que desea regenerar los datos de la conciliación contable?';
        glLabel114: Label '¿Confirma que desea grabar la fecha conciliación en los movimientos contables?';
        glLabel115: Label 'Procesando @1@@@@@@@@@';
        gFinestra: Dialog;
        glLabel116: Label 'El %1 %2 %3 ha sido liquidado por otro usuario.';
        giMinMov: Integer;
        giMaxMov: Integer;

    PROCEDURE ImporteConciliado(piMov: Integer): Decimal;
    VAR
        lMovCon: Record "Mov. Conciliacion cuenta";
        lDImporte: Decimal;
    BEGIN

        lDImporte := 0;

        lMovCon.RESET;
        lMovCon.SETRANGE("Nº Mov.", piMov);
        if lMovCon.FIND('-') THEN BEGIN
            lMovCon.CALCSUMS("Importe conciliado");
            lDImporte := lMovCon."Importe conciliado";
        END;

        EXIT(lDImporte);
    END;

    PROCEDURE Conciliado(piMov: Integer; pDImporteDL: Decimal): Boolean;
    BEGIN

        EXIT(ImporteConciliado(piMov) = pDImporteDL);
    END;

    PROCEDURE Conciliacion_Automatica(pCCuenta: Code[20]);
    VAR
        lVendorPostingGroup: Record "Vendor posting group";
    BEGIN
        if pCCuenta = '' THEN
            ERROR(glLabel110);

        lVendorPostingGroup.SETRANGE(FPR, pCCuenta);
        if lVendorPostingGroup.FIND('-') THEN
            Conciliacion_Albaranes(pCCuenta)
        ELSE
            Conciliacion_Cuenta(pCCuenta);
    END;

    PROCEDURE Conciliacion_Cuenta(ppCCuenta: Text[20]);
    VAR
        lGlEntry: Record "G/L Entry";
        lGlEntry2: Record "G/L Entry";
        lGlEntryTMP: Record "G/L Entry" TEMPORARY;
        lDImporteConciliadoCon: Decimal;
        liLinCon: Integer;
        i: Integer;
        lilinRegs: Integer;
        lbesConciliado: Boolean;
    BEGIN
        if ppCCuenta = '' THEN
            ERROR(glLabel110);

        lGlEntry.RESET;

        // PLB 27/06/2007
        // INC-23651
        // mejora de rendimiento
        //lGlEntry.SETCURRENTKEY("Posting Date","G/L Account No.",Pendiente);
        lGlEntry.SETCURRENTKEY("G/L Account No.", "Posting Date");

        lGlEntry.SETRANGE("G/L Account No.", ppCCuenta);
        lGlEntry.SETRANGE(Pendiente, TRUE);

        lGlEntry2.RESET;
        lGlEntry2.SETCURRENTKEY("G/L Account No.", "Document No.", "Bill No.", "External Document No.");
        lGlEntry2.SETRANGE("G/L Account No.", ppCCuenta);
        lGlEntry2.SETRANGE(Pendiente, TRUE);

        if lGlEntry.FIND('-') THEN BEGIN
            gFinestra.OPEN(glLabel100 +
                          glLabel111 +
                          glLabel112);
            gFinestra.UPDATE(1, ppCCuenta);
            i := 0;
            lilinRegs := lGlEntry.COUNT;
            REPEAT
                lbesConciliado := FALSE;
                i := i + 1;
                gFinestra.UPDATE(2, ROUND((i / lilinRegs) * 10000, 1));
                lDImporteConciliadoCon := lGlEntry.Amount - lGlEntry."Importe pendiente";

                // PLB 27/06/2007
                // INC-23651
                //
                //if lGlEntry.Amount <> ImporteConciliadoCon THEN BEGIN
                if (lGlEntry.Amount <> lDImporteConciliadoCon) AND (lGlEntry."External Document No." <> '') THEN BEGIN

                    lGlEntry2.SETRANGE("Posting Date");
                    lGlEntry2.SETRANGE("External Document No.", lGlEntry."External Document No.");
                    lGlEntry2.SETFILTER("Entry No.", '<>%1', lGlEntry."Entry No.");
                    if lGlEntry2.FIND('-') THEN BEGIN

                        // -- 1er intento conciliacion -------------------------------------------
                        REPEAT
                            if (lGlEntry2."Importe pendiente" + lGlEntry."Importe pendiente") = 0 THEN BEGIN
                                lGlEntryTMP := lGlEntry;
                                lGlEntryTMP."Importe a conciliar" := lGlEntry."Importe pendiente";
                                lGlEntryTMP.INSERT;

                                lGlEntryTMP := lGlEntry2;
                                lGlEntryTMP."Importe a conciliar" := lGlEntry2."Importe pendiente";
                                lGlEntryTMP.INSERT;

                                i := i + 1;
                                lbesConciliado := TRUE;
                            END
                        UNTIL lbesConciliado OR (lGlEntry2.NEXT = 0);

                        // -- 2o intento conciliacion -------------------------------------------
                        if NOT lbesConciliado THEN BEGIN
                            lDImporteConciliadoCon := 0;
                            lGlEntry2.SETRANGE("Entry No.");
                            if lGlEntry2.FIND('-') THEN BEGIN
                                REPEAT
                                    lDImporteConciliadoCon += lGlEntry2."Importe pendiente";
                                UNTIL (lDImporteConciliadoCon = 0) OR (lGlEntry2.NEXT = 0);

                                if lDImporteConciliadoCon = 0 THEN BEGIN
                                    lGlEntry2.FIND('-');
                                    REPEAT
                                        if lGlEntry2."Importe pendiente" <> 0 THEN BEGIN
                                            lDImporteConciliadoCon += lGlEntry2."Importe pendiente";

                                            lGlEntryTMP := lGlEntry2;
                                            lGlEntryTMP."Importe a conciliar" := lGlEntry2."Importe pendiente";
                                            lGlEntryTMP.INSERT;

                                            if lGlEntry2."Entry No." <> lGlEntry."Entry No." THEN
                                                i := i + 1;
                                            lbesConciliado := lDImporteConciliadoCon = 0;
                                        END;
                                    UNTIL lbesConciliado OR (lGlEntry2.NEXT = 0);
                                END;
                            END;

                            // -- 3er intento conciliacion -------------------------------------------
                            if NOT lbesConciliado THEN BEGIN
                                lDImporteConciliadoCon := 0;
                                lGlEntry2.SETRANGE("Posting Date", lGlEntry."Posting Date", 99991231D);
                                lGlEntry2.SETFILTER("Entry No.", '%1..', lGlEntry."Entry No.");
                                if lGlEntry2.FIND('-') THEN BEGIN
                                    REPEAT
                                        lDImporteConciliadoCon += lGlEntry2."Importe pendiente";
                                    UNTIL (lDImporteConciliadoCon = 0) OR (lGlEntry2.NEXT = 0);

                                    if lDImporteConciliadoCon = 0 THEN BEGIN
                                        lGlEntry2.FIND('-');
                                        REPEAT
                                            lDImporteConciliadoCon += lGlEntry2."Importe pendiente";
                                            if (lGlEntry2."Importe pendiente") <> 0 THEN BEGIN
                                                lGlEntryTMP := lGlEntry2;
                                                lGlEntryTMP."Importe a conciliar" := lGlEntry2."Importe pendiente";
                                                lGlEntryTMP.INSERT;

                                                if lGlEntry2."Entry No." <> lGlEntry."Entry No." THEN
                                                    i := i + 1;
                                                lbesConciliado := lDImporteConciliadoCon = 0;
                                            END;
                                        UNTIL lbesConciliado OR (lGlEntry2.NEXT = 0);
                                    END;
                                END;
                            END;
                        END;
                    END;
                END;

                if lbesConciliado THEN BEGIN
                    liLinCon += lGlEntryTMP.COUNT;
                    gFinestra.UPDATE(3, liLinCon);
                    Conciliar(lGlEntryTMP, glLabel106);
                END;
            UNTIL lGlEntry.NEXT = 0;
            gFinestra.CLOSE;
        END;
    END;

    PROCEDURE Conciliar(VAR pglEntry: Record "G/L Entry" TEMPORARY; ptDescripcion: Text[50]): Integer;
    VAR
        lGlEntry: Record "G/L Entry";
        lMovCon: Record "Mov. Conciliacion cuenta";
        lConciliacionCuenta: Record "Conciliacion cuenta";
        cDiaGenRegLin: Codeunit "Gen. Jnl.-Post Line";
        liMin: Integer;
        liMax: Integer;
    BEGIN
        WITH pglEntry DO BEGIN
            SETCURRENTKEY("G/L Account No.", "Posting Date");
            if NOT FIND('-') THEN
                ERROR(glLabel104, TABLECAPTION);
            CALCSUMS("Importe a conciliar");
            if "Importe a conciliar" <> 0 THEN BEGIN
                DELETEALL;
                COMMIT;
                EXIT;
            END;
            BuscarMaxMinNmovE(liMin, liMax);

            lConciliacionCuenta.RESET;
            lConciliacionCuenta.SETRANGE("Nº", liMin, liMax);
            if lConciliacionCuenta.FIND('+') THEN
                lConciliacionCuenta."Nº" := lConciliacionCuenta."Nº" + 1
            ELSE
                lConciliacionCuenta."Nº" := liMin + 1;
            // if Strpos(UserId, '\') <> 0 Then
            //     lConciliacionCuenta."Usuario" := Copystr(USERID, 11)
            // else
            lConciliacionCuenta.Usuario := USERID;
            lConciliacionCuenta.Fecha := TODAY;
            lConciliacionCuenta.Hora := TIME;
            lConciliacionCuenta.Comentario := ptDescripcion;
            lConciliacionCuenta.INSERT(TRUE);

            if FIND('-') THEN
                REPEAT
                    lGlEntry.GET("Entry No.");
                    if lGlEntry."Importe pendiente" <> "Importe pendiente" THEN
                        ERROR(glLabel116, lGlEntry.TABLECAPTION, lGlEntry.FIELDCAPTION("Entry No."), lGlEntry."Entry No.");

                    lMovCon.INIT;
                    lMovCon."Nº Mov." := "Entry No.";
                    lMovCon."Nº Conciliacion" := lConciliacionCuenta."Nº";
                    lMovCon."Importe conciliado" := "Importe a conciliar";
                    lMovCon."Nº cuenta" := "G/L Account No.";
                    lMovCon."Fecha conciliacion" := lConciliacionCuenta.Fecha;
                    lMovCon.INSERT(TRUE);

                    lGlEntry."Importe pendiente" := "Importe pendiente" - "Importe a conciliar";
                    lGlEntry."Importe a conciliar" := 0;
                    lGlEntry."Usuario conciliacion" := '';
                    if lGlEntry."Importe pendiente" = 0 THEN
                        lGlEntry.Pendiente := FALSE;
                    //lGlEntry.Replicado := FALSE;
                    lGlEntry.MODIFY;
                UNTIL NEXT = 0;

            DELETEALL;

            COMMIT;
        END;

        EXIT(lConciliacionCuenta."Nº");
    END;

    PROCEDURE Conciliar_Manual(VAR pglEntry: Record "G/L Entry" TEMPORARY);
    VAR
        lGlEntry: Record "G/L Entry";
        lGlEntryTMP: Record "G/L Entry" TEMPORARY;
        lConciliacionCuenta: Record "Conciliacion cuenta";
        liLinCon: Integer;
        lGlEntry2: Record "G/L Entry";
        lbesConciliado: Boolean;
        lDImportec: Decimal;
    BEGIN
        // Conciliar_Registros
        //
        lGlEntry.COPY(pglEntry);
        lGlEntry.SETCURRENTKEY("G/L Account No.", "Usuario conciliacion");
        lGlEntry.SETRANGE("G/L Account No.", pglEntry."G/L Account No.");
        lGlEntry.SETRANGE("Usuario conciliacion", USERID);
        lGlEntry.SETFILTER(lGlEntry.Marca, '<>%1', '');
        if lGlEntry.FINDFIRST THEN BEGIN

            lGlEntry2.COPY(pglEntry);
            lGlEntry2.SETCURRENTKEY("G/L Account No.", "Usuario conciliacion");
            lGlEntry2.SETRANGE("G/L Account No.", pglEntry."G/L Account No.");
            lGlEntry2.SETRANGE("Usuario conciliacion", USERID);
            lGlEntry2.SETFILTER(lGlEntry2.Marca, '%1', '');
            if lGlEntry2.FIND('-') THEN BEGIN
                REPEAT
                    lDImportec := lDImportec - lGlEntry2."Importe pendiente";

                    lGlEntryTMP := lGlEntry2;
                    lGlEntryTMP."Importe a conciliar" := +lGlEntry2."Importe pendiente";
                    lGlEntryTMP.INSERT;
                    if lDImportec = -lGlEntry."Importe pendiente" THEN
                        lbesConciliado := TRUE;
                UNTIL lbesConciliado OR (lGlEntry2.NEXT = 0);
            END;
            lGlEntryTMP := lGlEntry;
            lGlEntryTMP."Importe a conciliar" := +lDImportec;
            lGlEntryTMP.INSERT;

        END;

        liLinCon := Conciliar(lGlEntryTMP, '');

        lConciliacionCuenta.GET(liLinCon);
        lConciliacionCuenta.SETRECFILTER;
        PAGE.RUN(PAGE::"Ficha Conciliaciones cuenta", lConciliacionCuenta);
    END;

    PROCEDURE Desconciliar_Registros(VAR pglEntry: Record "G/L Entry");
    VAR
        lConciliacionCuenta: Record "Conciliacion cuenta";
        lMovCon: Record "Mov. Conciliacion cuenta";
        lMovCon2: Record "Mov. Conciliacion cuenta";
        lpFichaCon: page "Movs. Conciliacion cuenta";
        lGlEntry: Record "G/L Entry";
    BEGIN

        lMovCon.RESET;
        lMovCon.SETRANGE("Nº Mov.", pglEntry."Entry No.");
        if NOT lMovCon.FIND('-') THEN
            ERROR(glLabel107);

        CLEAR(lpFichaCon);
        lpFichaCon.SETTABLEVIEW := lMovCon;
        lpFichaCon.LOOKUPMODE := TRUE;
        lpFichaCon.CAPTION := lpFichaCon.CAPTION + glLabel108;
        if lpFichaCon.RUNMODAL = ACTION::LookupOK THEN BEGIN
            lpFichaCon.DevolverSeleccionados(lMovCon);
            if NOT CONFIRM(glLabel109) THEN
                EXIT;
            if lMovCon.FIND('-') THEN
                REPEAT
                    lMovCon2.RESET;
                    lMovCon2.SETRANGE("Nº Conciliacion", lMovCon."Nº Conciliacion");
                    if lMovCon2.FIND('-') THEN
                        REPEAT
                            lGlEntry.GET(lMovCon2."Nº Mov.");
                            lGlEntry."Importe pendiente" := lGlEntry."Importe pendiente" + lMovCon2."Importe conciliado";
                            lGlEntry.Pendiente := TRUE;
                            //lGlEntry.Replicado := FALSE;
                            lGlEntry.MODIFY;
                        UNTIL lMovCon2.NEXT = 0;
                    if lConciliacionCuenta.GET(lMovCon."Nº Conciliacion") THEN
                        lConciliacionCuenta.DELETE(TRUE);
                UNTIL lMovCon.NEXT = 0;
        END;
    END;

    PROCEDURE Conciliacion_Cuenta_FPR(pCCuenta: Code[20]);
    VAR
        lGlEntry: Record "G/L Entry";
        lGlEntry2: Record "G/L Entry";
        lGlEntryTMP: Record "G/L Entry" TEMPORARY;
        lPurchRcptHdr: Record "Purch. Rcpt. Header";
        lPurchInvHdr: Record "Purch. Inv. Header";
        lPurchCrMemoHdr: Record "Purch. Cr. Memo Hdr.";
        lDImporteConciliadoCon: Decimal;
        liLinCon: Integer;
        i: Integer;
        ilinRegs: Integer;
        lCFactura: Code[20];
        lPurchRcptHdrtmp: Record "Purch. Rcpt. Header" TEMPORARY;
    BEGIN

        if pCCuenta = '' THEN
            ERROR(glLabel110);

        liLinCon := 0;
        lGlEntry.RESET;

        // PLB 27/06/2007
        // INC-23651
        // mejora de rendimiento
        //lGlEntry.SETCURRENTKEY("Posting Date","G/L Account No.",Pendiente);
        lGlEntry.SETCURRENTKEY("G/L Account No.", "Usuario conciliacion", Pendiente, "Document Type");

        lGlEntry.SETRANGE("G/L Account No.", pCCuenta);
        lGlEntry.SETRANGE(Pendiente, TRUE);
        lGlEntry.SETRANGE("Document Type", lGlEntry."Document Type"::" ");

        lGlEntry2.RESET;
        lGlEntry2.SETCURRENTKEY("G/L Account No.", "Document No.", "Bill No.", "External Document No.");
        lGlEntry2.SETRANGE("G/L Account No.", pCCuenta);
        lGlEntry2.SETRANGE(Pendiente, TRUE);

        if lGlEntry.FIND('-') THEN BEGIN
            gFinestra.OPEN(glLabel102 +
                          glLabel111 +
                          glLabel112);
            gFinestra.UPDATE(1, pCCuenta);
            i := 0;
            ilinRegs := lGlEntry.COUNT;
            REPEAT
                i := i + 1;
                gFinestra.UPDATE(2, ROUND((i / ilinRegs) * 10000, 1));

                if lPurchRcptHdr.GET(lGlEntry."Document No.") then // {AND (lPurchRcptHdr."Nº Factura" <> '')} THEN
                    lCFactura := Factura(lPurchRcptHdr."No.")
                ELSE
                    lCFactura := '';
                if lCFactura <> '' THEN BEGIN
                    if lPurchInvHdr.GET(lCFactura) THEN BEGIN
                        lGlEntry2.SETRANGE("Document Type", lGlEntry2."Document Type"::Invoice);
                        lGlEntry2.SETRANGE("Document No.", lCFactura);
                    END
                    ELSE
                        if lPurchCrMemoHdr.GET(lCFactura) THEN BEGIN
                            lGlEntry2.SETRANGE("Document Type", lGlEntry2."Document Type"::"Credit Memo");
                            lGlEntry2.SETRANGE("Document No.", lCFactura);
                        END
                        ELSE BEGIN
                            lGlEntry2.SETRANGE("Document Type");
                            lGlEntry2.SETRANGE("Document No.", lCFactura);
                        END;

                    // -- 1er intento conciliacion -------------------------------------------
                    // se cazan los movimientos de las facturas con el albarán
                    //
                    if lGlEntry2.FIND('-') THEN BEGIN
                        REPEAT
                            if NOT lGlEntryTMP.GET(lGlEntry."Entry No.") THEN BEGIN
                                lGlEntryTMP := lGlEntry;
                                lGlEntryTMP."Importe a conciliar" := 0;
                                lGlEntryTMP.INSERT;
                            END;
                            lGlEntryTMP."Importe a conciliar" -= lGlEntry2."Importe pendiente";
                            lGlEntryTMP.MODIFY;

                            lGlEntryTMP := lGlEntry2;
                            lGlEntryTMP."Importe a conciliar" := lGlEntry2."Importe pendiente";
                            lGlEntryTMP.INSERT;

                            if lGlEntry2."Document Type" = lGlEntry2."Document Type"::" " THEN
                                i := i + 1;
                        UNTIL lGlEntry2.NEXT = 0;

                        // -- 2o intento conciliacion -------------------------------------------
                        // se cazan todos los albaranes relacionados con las facturas del primer albarán
                        //
                        Albaranes(lCFactura, pCCuenta, lPurchRcptHdrtmp);
                        lPurchRcptHdrtmp.SETFILTER("No.", '<>%1', lPurchRcptHdr."No.");
                        if lPurchRcptHdrtmp.FIND('-') THEN
                            REPEAT
                                if lPurchRcptHdrtmp."No." <> lGlEntryTMP."Document No." THEN BEGIN
                                    lGlEntry2.SETRANGE("Document Type", lGlEntry2."Document Type"::Receipt);
                                    lGlEntry2.SETRANGE("Document No.", lPurchRcptHdr."No.");
                                    if lGlEntry2.FIND('-') THEN BEGIN
                                        lDImporteConciliadoCon := -lGlEntry2."Importe pendiente";

                                        if NOT lGlEntryTMP.GET(lGlEntry."Entry No.") THEN BEGIN
                                            lGlEntryTMP := lGlEntry;
                                            lGlEntryTMP."Importe a conciliar" := 0;
                                            lGlEntryTMP.INSERT;
                                        END;
                                        lGlEntryTMP."Importe a conciliar" -= lGlEntry2."Importe pendiente";
                                        lGlEntryTMP.MODIFY;

                                        lGlEntryTMP := lGlEntry2;
                                        lGlEntryTMP."Importe a conciliar" := lGlEntry2."Importe pendiente";
                                        lGlEntryTMP.INSERT;

                                        i := i + 1;
                                    END;
                                END;
                            UNTIL lPurchRcptHdrtmp.NEXT = 0;

                        // -- Testeo conciliacion -------------------------------------------
                        // Se verifica que los importes a conciliar tengan sentido. En caso contrario
                        // se intentan recalcular los importes a liquidar
                        //
                        lGlEntryTMP.GET(lGlEntry."Entry No.");
                        lGlEntryTMP.CALCFIELDS("Importe conciliado");
                        if (ABS(lGlEntryTMP."Importe a conciliar" + lGlEntryTMP."Importe conciliado") > ABS(lGlEntryTMP.Amount)) OR
                           ((lGlEntryTMP.Amount > 0) AND (lGlEntryTMP."Importe a conciliar" < 0)) OR
                           ((lGlEntryTMP.Amount < 0) AND (lGlEntryTMP."Importe a conciliar" > 0)) THEN BEGIN
                            lDImporteConciliadoCon := lGlEntryTMP."Importe a conciliar";

                            lGlEntryTMP."Importe a conciliar" := lGlEntryTMP.Amount - lGlEntryTMP."Importe conciliado";
                            lGlEntryTMP.MODIFY;
                            lDImporteConciliadoCon := lGlEntryTMP."Importe a conciliar" - lDImporteConciliadoCon;

                            lGlEntryTMP.SETFILTER("Entry No.", '<>%1', lGlEntry."Entry No.");
                            if lGlEntryTMP.FIND('+') THEN
                                REPEAT
                                    if ((lGlEntryTMP.Amount > 0) AND (lDImporteConciliadoCon > 0)) OR
                                       ((lGlEntryTMP.Amount < 0) AND (lDImporteConciliadoCon < 0)) THEN BEGIN

                                        // solo volvemos el contador atras si el movimiento quedaba totalmente liquidado
                                        //
                                        if (lGlEntryTMP."Document Type" = lGlEntryTMP."Document Type"::" ") AND
                                           (lGlEntryTMP."Importe pendiente" = lGlEntryTMP."Importe a conciliar") THEN
                                            i := i - 1;

                                        if ABS(lDImporteConciliadoCon) > ABS(lGlEntryTMP."Importe a conciliar") THEN BEGIN
                                            lDImporteConciliadoCon := lDImporteConciliadoCon - lGlEntryTMP."Importe a conciliar";
                                            lGlEntryTMP.DELETE;
                                        END
                                        ELSE BEGIN
                                            lGlEntryTMP."Importe a conciliar" := lGlEntryTMP."Importe a conciliar" - lDImporteConciliadoCon;
                                            lGlEntryTMP.MODIFY;
                                            lDImporteConciliadoCon := 0;
                                        END;
                                    END;
                                UNTIL (lGlEntryTMP.NEXT(-1) = 0) OR (lDImporteConciliadoCon = 0);
                            lGlEntryTMP.SETRANGE("Entry No.");

                            // Si aun asi la suma de los importes a conciliar no es 0, modificamos el importe a conciliar
                            // del movimiento de referencia
                            //
                            if lDImporteConciliadoCon <> 0 THEN BEGIN
                                lGlEntryTMP.GET(lGlEntry."Entry No.");
                                lGlEntryTMP."Importe a conciliar" := lGlEntryTMP."Importe a conciliar" - lDImporteConciliadoCon;
                                if lGlEntryTMP."Importe a conciliar" = 0 THEN
                                    lGlEntryTMP.DELETEALL
                                ELSE
                                    lGlEntryTMP.MODIFY;
                            END;
                        END;

                        // Solo conciliaremos si hay algo que conciliar
                        //
                        if lGlEntryTMP.FIND('-') THEN BEGIN
                            liLinCon += lGlEntryTMP.COUNT;
                            Conciliar(lGlEntryTMP, glLabel106);
                            gFinestra.UPDATE(3, liLinCon);
                        END;
                    END;
                END;
            UNTIL lGlEntry.NEXT = 0;
            gFinestra.CLOSE;
        END;
    END;

    PROCEDURE RehacelGlEntrysCont();
    VAR
        lGlEntry: Record "G/L Entry";
        i: Integer;
        ilinRegs: Integer;
        lDImpCon: Decimal;
    BEGIN

        if NOT CONFIRM(glLabel113) THEN
            EXIT;

        lGlEntry.RESET;
        if lGlEntry.FIND('-') THEN BEGIN
            gFinestra.OPEN(glLabel115);
            i := 0;
            ilinRegs := lGlEntry.COUNT;
            REPEAT
                i := i + 1;
                gFinestra.UPDATE(1, ROUND((i / ilinRegs) * 10000, 1));
                lDImpCon := ImporteConciliado(lGlEntry."Entry No.");
                if lGlEntry."Importe pendiente" <> ROUND(lGlEntry.Amount - lDImpCon) THEN BEGIN
                    lGlEntry."Importe pendiente" := ROUND(lGlEntry.Amount - lDImpCon);
                    lGlEntry.Pendiente := lGlEntry."Importe pendiente" <> 0;
                    //      lGlEntry.Replicado := FALSE;
                    lGlEntry.MODIFY;
                END;
            UNTIL lGlEntry.NEXT = 0;
            gFinestra.CLOSE;
        END;
    END;

    PROCEDURE PonerFechaConciliacion();
    VAR
        lMovCon: Record "Mov. Conciliacion cuenta";
        lMovCon2: Record "Mov. Conciliacion cuenta";
        lConciliacionCuenta: Record "Conciliacion cuenta";
        i: Integer;
        linRegs: Integer;
    BEGIN

        if NOT CONFIRM(glLabel114) THEN
            EXIT;

        lMovCon.RESET;
        lMovCon.SETCURRENTKEY("Fecha conciliacion");
        lMovCon.SETRANGE("Fecha conciliacion", 0D);
        if lMovCon.FIND('-') THEN BEGIN
            gFinestra.OPEN(glLabel115);
            i := 0;
            linRegs := lMovCon.COUNT;
            REPEAT
                i := i + 1;
                gFinestra.UPDATE(1, ROUND((i / linRegs) * 10000, 1));
                lConciliacionCuenta.GET(lMovCon."Nº Conciliacion");
                lMovCon2 := lMovCon;
                lMovCon2."Fecha conciliacion" := lConciliacionCuenta.Fecha;
                lMovCon2.MODIFY;
            UNTIL lMovCon.NEXT = 0;
        END;
        gFinestra.CLOSE;
    END;

    PROCEDURE Conciliacion_Albaranes(pCCuenta: Text[20]);
    VAR
        lGlEntry: Record "G/L Entry";
        lGlEntry2: Record "G/L Entry";
        lGlEntryTMP: Record "G/L Entry" TEMPORARY;
        lDImporteConciliadoCon: Decimal;
        liLinCon: Integer;
        i: Integer;
        linRegs: Integer;
        lbesConciliado: Boolean;
    BEGIN
        //Tax Area Code
        if pCCuenta = '' THEN
            ERROR(glLabel110);

        lGlEntry.RESET;

        // PLB 27/06/2007
        // INC-23651
        // mejora de rendimiento
        //lGlEntry.SETCURRENTKEY("Posting Date","G/L Account No.",Pendiente);
        lGlEntry.SETCURRENTKEY("G/L Account No.", "Posting Date");
        lGlEntry.SETRANGE("G/L Account No.", pCCuenta);
        lGlEntry.SETRANGE(Pendiente, TRUE);

        lGlEntry2.RESET;
        lGlEntry2.SETCURRENTKEY("G/L Account No.", "Document No.", "Posting Date", "Tax Area Code");
        lGlEntry2.SETRANGE("G/L Account No.", pCCuenta);
        lGlEntry2.SETRANGE(Pendiente, TRUE);
        lGlEntry2.SETRANGE(lGlEntry2."Document Type", lGlEntry2."Document Type"::Receipt);
        lGlEntry2.SETRANGE(lGlEntry2."Tax Area Code", '');
        lGlEntry2.SETFILTER(lGlEntry2."Document No.", '<>%1', '');
        if lGlEntry2.FINDFIRST THEN
            REPEAT
                lGlEntry2."Tax Area Code" := lGlEntry2."Document No.";
                lGlEntry2.MODIFY;
            UNTIL NOT lGlEntry2.FINDFIRST;
        lGlEntry2.SETRANGE(lGlEntry2."Document Type");
        lGlEntry2.SETRANGE(lGlEntry2."Tax Area Code");
        lGlEntry2.SETRANGE(lGlEntry2."Document No.");

        if lGlEntry.FIND('-') THEN BEGIN
            gFinestra.OPEN(glLabel100 +
                          glLabel111 +
                          glLabel112);
            gFinestra.UPDATE(1, pCCuenta);
            i := 0;
            linRegs := lGlEntry.COUNT;
            REPEAT
                lbesConciliado := FALSE;
                i := i + 1;
                gFinestra.UPDATE(2, ROUND((i / linRegs) * 10000, 1));
                lDImporteConciliadoCon := lGlEntry.Amount - lGlEntry."Importe pendiente";

                if (lGlEntry.Amount <> lDImporteConciliadoCon) AND (lGlEntry."Tax Area Code" <> '') THEN BEGIN

                    lGlEntry2.SETRANGE("Posting Date");
                    lGlEntry2.SETRANGE("Tax Area Code", lGlEntry."Tax Area Code");
                    lGlEntry2.SETFILTER("Entry No.", '<>%1', lGlEntry."Entry No.");
                    if lGlEntry2.FIND('-') THEN BEGIN

                        // -- 1er intento conciliacion -------------------------------------------
                        REPEAT
                            if (lGlEntry2."Importe pendiente" + lGlEntry."Importe pendiente") = 0 THEN BEGIN
                                lGlEntryTMP := lGlEntry;
                                lGlEntryTMP."Importe a conciliar" := lGlEntry."Importe pendiente";
                                lGlEntryTMP.INSERT;

                                lGlEntryTMP := lGlEntry2;
                                lGlEntryTMP."Importe a conciliar" := lGlEntry2."Importe pendiente";
                                lGlEntryTMP.INSERT;

                                i := i + 1;
                                lbesConciliado := TRUE;
                            END
                        UNTIL lbesConciliado OR (lGlEntry2.NEXT = 0);
                        //Conciliando por el mayor
                        if NOT lbesConciliado THEN BEGIN
                            REPEAT
                                if ABS(lGlEntry2."Importe pendiente") < ABS(lGlEntry."Importe pendiente") THEN BEGIN
                                    lGlEntryTMP := lGlEntry;
                                    lGlEntryTMP."Importe a conciliar" := -lGlEntry2."Importe pendiente";
                                    lGlEntryTMP.INSERT;

                                    lGlEntryTMP := lGlEntry2;
                                    lGlEntryTMP."Importe a conciliar" := lGlEntry2."Importe pendiente";
                                    lGlEntryTMP.INSERT;

                                    i := i + 1;
                                    lbesConciliado := TRUE;
                                END
                            UNTIL lbesConciliado OR (lGlEntry2.NEXT = 0);
                        END;
                        // -- 2o intento conciliacion -------------------------------------------
                        if NOT lbesConciliado THEN BEGIN
                            lDImporteConciliadoCon := 0;
                            lGlEntry2.SETRANGE("Entry No.");
                            if lGlEntry2.FIND('-') THEN BEGIN
                                REPEAT
                                    lDImporteConciliadoCon += lGlEntry2."Importe pendiente";
                                UNTIL (lDImporteConciliadoCon = 0) OR (lGlEntry2.NEXT = 0);

                                if lDImporteConciliadoCon = 0 THEN BEGIN
                                    lGlEntry2.FIND('-');
                                    REPEAT
                                        if lGlEntry2."Importe pendiente" <> 0 THEN BEGIN
                                            lDImporteConciliadoCon += lGlEntry2."Importe pendiente";

                                            lGlEntryTMP := lGlEntry2;
                                            lGlEntryTMP."Importe a conciliar" := lGlEntry2."Importe pendiente";
                                            lGlEntryTMP.INSERT;

                                            if lGlEntry2."Entry No." <> lGlEntry."Entry No." THEN
                                                i := i + 1;
                                            lbesConciliado := lDImporteConciliadoCon = 0;
                                        END;
                                    UNTIL lbesConciliado OR (lGlEntry2.NEXT = 0);
                                END;
                            END;

                            // -- 3er intento conciliacion -------------------------------------------
                            if NOT lbesConciliado THEN BEGIN
                                lDImporteConciliadoCon := 0;
                                lGlEntry2.SETRANGE("Posting Date", lGlEntry."Posting Date", 99991231D);
                                lGlEntry2.SETFILTER("Entry No.", '%1..', lGlEntry."Entry No.");
                                if lGlEntry2.FIND('-') THEN BEGIN
                                    REPEAT
                                        lDImporteConciliadoCon += lGlEntry2."Importe pendiente";
                                    UNTIL (lDImporteConciliadoCon = 0) OR (lGlEntry2.NEXT = 0);

                                    if lDImporteConciliadoCon = 0 THEN BEGIN
                                        lGlEntry2.FIND('-');
                                        REPEAT
                                            lDImporteConciliadoCon += lGlEntry2."Importe pendiente";
                                            if (lGlEntry2."Importe pendiente") <> 0 THEN BEGIN
                                                lGlEntryTMP := lGlEntry2;
                                                lGlEntryTMP."Importe a conciliar" := lGlEntry2."Importe pendiente";
                                                lGlEntryTMP.INSERT;

                                                if lGlEntry2."Entry No." <> lGlEntry."Entry No." THEN
                                                    i := i + 1;
                                                lbesConciliado := lDImporteConciliadoCon = 0;
                                            END;
                                        UNTIL lbesConciliado OR (lGlEntry2.NEXT = 0);
                                    END;
                                END;
                            END;
                        END;
                    END;
                END;

                if lbesConciliado THEN BEGIN
                    liLinCon += lGlEntryTMP.COUNT;
                    gFinestra.UPDATE(3, liLinCon);
                    Conciliar(lGlEntryTMP, glLabel106);
                    COMMIT;
                END;
            UNTIL lGlEntry.NEXT = 0;
            gFinestra.CLOSE;
        END;
    END;

    PROCEDURE BuscarMaxMinNmovE(VAR piMin: Integer; VAR piMax: Integer);
    VAR
        lGlSetup: Record "General Ledger Setup";
    BEGIN
        // BuscarMaxMinNmovE
        //
        // Numerador movimientos

        lGlSetup.GET;
        BuscarMaxMinNmov;

        piMin := giMinMov;
        piMax := giMaxMov;
    END;

    PROCEDURE Factura(pCAlbaran: Code[20]): Code[20];
    VAR
        lPurchInvoiceLine: Record "Purch. Inv. Line";
        lPurchCrMemoLine: Record "Purch. Cr. Memo Line";
    BEGIN
        lPurchInvoiceLine.SETCURRENTKEY(lPurchInvoiceLine."Buy-from Vendor No.", lPurchInvoiceLine.Description);
        //lPurchInvoiceLine.SETRANGE(lPurchInvoiceLine."Buy-from Vendor No.","Buy-from Vendor No.");
        lPurchInvoiceLine.SETFILTER(lPurchInvoiceLine.Description, '%1', '*' + pCAlbaran + '*');
        if lPurchInvoiceLine.FINDFIRST THEN EXIT(lPurchInvoiceLine."Document No.");
        lPurchCrMemoLine.SETCURRENTKEY(lPurchCrMemoLine."Buy-from Vendor No.", lPurchCrMemoLine.Description);
        //lPurchInvoiceLine.SETRANGE(lPurchInvoiceLine."Buy-from Vendor No.","Buy-from Vendor No.");
        lPurchCrMemoLine.SETFILTER(lPurchCrMemoLine.Description, '%1', '*' + pCAlbaran + '*');
        if lPurchCrMemoLine.FINDFIRST THEN EXIT(lPurchCrMemoLine."Document No.");

        //   {REPEAT
        //        r122.SETRANGE(r122."No.", lSalesInvoiceLine."Document No.");
        //        if r122.FINDFIRST THEN r122.MARK := TRUE;
        //     UNTIL lSalesInvoiceLine.NEXT = 0;
        //     r122.SETRANGE(r122."No.");
        //     r122.MARKEDONLY := TRUE;
        //     PAGE.RUNMODAL(0, r122); }
    END;

    PROCEDURE Albaranes(pCFactura: Code[20]; pCCuenta: Text[30]; VAR pPurchRcptHdrTMP: Record 120 TEMPORARY): Code[20];
    VAR
        lGlEntry: Record "G/L Entry";
        lPurchRcptHdr: Record "Purch. Rcpt. Header";
    BEGIN
        lGlEntry.SETCURRENTKEY(lGlEntry."G/L Account No.", lGlEntry."Document No.", lGlEntry."Posting Date", lGlEntry."Tax Area Code");
        lGlEntry.SETRANGE("Document No.", pCFactura);
        lGlEntry.SETRANGE(lGlEntry."G/L Account No.", pCCuenta);
        if lGlEntry.FINDFIRST THEN
            REPEAT
                if lGlEntry."Tax Area Code" <> '' THEN BEGIN
                    if lPurchRcptHdr.GET(lGlEntry."Tax Area Code") THEN BEGIN
                        pPurchRcptHdrTMP := lPurchRcptHdr;
                        if pPurchRcptHdrTMP.INSERT THEN;
                    END;
                END;
            UNTIL lGlEntry.NEXT = 0;
    END;

    LOCAL PROCEDURE BuscarMaxMinNmov();
    VAR
    BEGIN
        // BuscarMaxMinNmov
        //
        // Numerador movimientos

        giMinMov := 0;
        giMaxMov := 2147483647;
    END;

    PROCEDURE Conciliacion_Proveedor(pCCuenta: Code[20]; pCProveedor: Code[20]);
    VAR
        lGlEntry: Record "G/L Entry";
        lGlEntry2: Record "G/L Entry";
        lGlEntryTMP: Record "G/L Entry" TEMPORARY;
        lDImporteConciliadoCon: Decimal;
        liLinCon: Integer;
        i: Integer;
        linRegs: Integer;
        lbesConciliado: Boolean;
    BEGIN
        //Tax Area Code
        if pCCuenta = '' THEN
            ERROR(glLabel110);

        lGlEntry.RESET;

        // PLB 27/06/2007
        // INC-23651
        // mejora de rendimiento
        //lGlEntry.SETCURRENTKEY("Posting Date","G/L Account No.",Pendiente);
        lGlEntry.SETCURRENTKEY("Source Type", "Source No.", "G/L Account No.", "Gen. Posting Type", "Document Type");
        lGlEntry.SETRANGE("G/L Account No.", pCCuenta);
        lGlEntry.SETRANGE("Source No.", pCProveedor);
        lGlEntry.SETRANGE("Source Type", lGlEntry."Source Type"::Vendor);
        lGlEntry.SETRANGE(Pendiente, TRUE);

        lGlEntry2.RESET;
        lGlEntry2.SETCURRENTKEY("Source Type", "Source No.", "G/L Account No.", "Gen. Posting Type", "Document Type");
        lGlEntry2.SETRANGE("G/L Account No.", pCCuenta);
        lGlEntry2.SETRANGE(Pendiente, TRUE);
        lGlEntry2.SETRANGE("Source No.", pCProveedor);
        lGlEntry2.SETRANGE("Source Type", lGlEntry2."Source Type"::Vendor);

        if lGlEntry.FIND('-') THEN BEGIN
            gFinestra.OPEN(glLabel100 +
                          glLabel111 +
                          glLabel112);
            gFinestra.UPDATE(1, pCCuenta);
            i := 0;
            linRegs := lGlEntry.COUNT;
            REPEAT
                lbesConciliado := FALSE;
                i := i + 1;
                gFinestra.UPDATE(2, ROUND((i / linRegs) * 10000, 1));
                lDImporteConciliadoCon := lGlEntry.Amount - lGlEntry."Importe pendiente";

                if (lGlEntry.Amount <> lDImporteConciliadoCon) then begin //{AND (lGlEntry."Tax Area Code" <> '')} THEN BEGIN

                    lGlEntry2.SETRANGE("Posting Date");
                    //lGlEntry2.SETRANGE("Tax Area Code", lGlEntry."Tax Area Code");
                    lGlEntry2.SETFILTER("Entry No.", '<>%1', lGlEntry."Entry No.");
                    if lGlEntry2.FIND('-') THEN BEGIN

                        // -- 1er intento conciliacion -------------------------------------------
                        REPEAT
                            if (lGlEntry2."Importe pendiente" + lGlEntry."Importe pendiente") = 0 THEN BEGIN
                                lGlEntryTMP := lGlEntry;
                                lGlEntryTMP."Importe a conciliar" := lGlEntry."Importe pendiente";
                                lGlEntryTMP.INSERT;

                                lGlEntryTMP := lGlEntry2;
                                lGlEntryTMP."Importe a conciliar" := lGlEntry2."Importe pendiente";
                                lGlEntryTMP.INSERT;

                                i := i + 1;
                                lbesConciliado := TRUE;
                            END
                        UNTIL lbesConciliado OR (lGlEntry2.NEXT = 0);

                        // -- 2o intento conciliacion -------------------------------------------
                        if NOT lbesConciliado THEN BEGIN
                            lDImporteConciliadoCon := 0;
                            lGlEntry2.SETRANGE("Entry No.");
                            if lGlEntry2.FIND('-') THEN BEGIN
                                REPEAT
                                    lDImporteConciliadoCon += lGlEntry2."Importe pendiente";
                                UNTIL (lDImporteConciliadoCon = 0) OR (lGlEntry2.NEXT = 0);

                                if lDImporteConciliadoCon = 0 THEN BEGIN
                                    lGlEntry2.FIND('-');
                                    REPEAT
                                        if lGlEntry2."Importe pendiente" <> 0 THEN BEGIN
                                            lDImporteConciliadoCon += lGlEntry2."Importe pendiente";

                                            lGlEntryTMP := lGlEntry2;
                                            lGlEntryTMP."Importe a conciliar" := lGlEntry2."Importe pendiente";
                                            lGlEntryTMP.INSERT;

                                            if lGlEntry2."Entry No." <> lGlEntry."Entry No." THEN
                                                i := i + 1;
                                            lbesConciliado := lDImporteConciliadoCon = 0;
                                        END;
                                    UNTIL lbesConciliado OR (lGlEntry2.NEXT = 0);
                                END;
                            END;

                            // -- 3er intento conciliacion -------------------------------------------
                            if NOT lbesConciliado THEN BEGIN
                                lDImporteConciliadoCon := 0;
                                lGlEntry2.SETRANGE("Posting Date", lGlEntry."Posting Date", 99991231D);
                                lGlEntry2.SETFILTER("Entry No.", '%1..', lGlEntry."Entry No.");
                                if lGlEntry2.FIND('-') THEN BEGIN
                                    REPEAT
                                        lDImporteConciliadoCon += lGlEntry2."Importe pendiente";
                                    UNTIL (lDImporteConciliadoCon = 0) OR (lGlEntry2.NEXT = 0);

                                    if lDImporteConciliadoCon = 0 THEN BEGIN
                                        lGlEntry2.FIND('-');
                                        REPEAT
                                            lDImporteConciliadoCon += lGlEntry2."Importe pendiente";
                                            if (lGlEntry2."Importe pendiente") <> 0 THEN BEGIN
                                                lGlEntryTMP := lGlEntry2;
                                                lGlEntryTMP."Importe a conciliar" := lGlEntry2."Importe pendiente";
                                                lGlEntryTMP.INSERT;

                                                if lGlEntry2."Entry No." <> lGlEntry."Entry No." THEN
                                                    i := i + 1;
                                                lbesConciliado := lDImporteConciliadoCon = 0;
                                            END;
                                        UNTIL lbesConciliado OR (lGlEntry2.NEXT = 0);
                                    END;
                                END;
                            END;
                        END;
                    END;
                END;

                if lbesConciliado THEN BEGIN
                    liLinCon += lGlEntryTMP.COUNT;
                    gFinestra.UPDATE(3, liLinCon);
                    Conciliar(lGlEntryTMP, glLabel106);
                END;
            UNTIL lGlEntry.NEXT = 0;
            gFinestra.CLOSE;
        END;
    END;

    // BEGIN
    // {
    //   // COC2.00 - Conciliación de FPR

    //   // PLB 06/03/2002
    //   COC2.01
    //   Guardar la fecha de conciliación en los movimientos para poder hacer ver que estaba pendiente a una fecha determinada

    //   // PLB 17/07/2002
    //   Conciliación automática para la empresa activa

    //   // PLB 15/02/2006
    //   INC-18469
    //   Problemas de rendimiento y bloqueos provocados por la conciliación contable

    //   Se han realizado los siguientes cambios:

    //   - Se ha reprogramado las rutinas de conciliacion contable
    //   - Sigue liquidando los movimientos con las mismas condiciones pero se emplean variables temporales
    //     para ir guardando las conciliaciones
    //   - Tambien se ha a¤adido un COMMIT despues de una conciliación (en la del FPR ya estaba)
    //   - Al inicio de las conciliaciones ya no se realiza ningún MODIFYALL
    //   - No se utiliza el campo "Usuario conciliacion" (este se usará sólo en las conciliaciones manuales)
    //   - Se ha eliminado una parte de codigo que no repercutía en los procesos (el bucle de empresas)
    //   - La función "Conciliacion_Automatica" se ha dividido en dos: "Conciliacion_Automatica" y "Conciliacion_Cuenta"
    //   - La función "Conciliacion_Automatica_FPR" se ha renombrado a "Conciliacion_Cuenta_FPR"
    //   - Se ha eliminado la parte pensada para la marca "Conciliacion automatica" en la cuenta. Este campo
    //     deberá eliminarse en un futuro

    //   // PLB 27/06/2007
    //   INC-23651
    //   Mejoras de rendimiento
    // }
    // END.

}