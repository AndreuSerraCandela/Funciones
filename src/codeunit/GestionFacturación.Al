/// <summary>
/// Codeunit Gestion Facturación (ID 50001).
/// </summary>
codeunit 50001 "Gestion Facturación"
{
    Permissions = TableData 17 = rimd,
    tabledata 110 = rimd,
    tabledata 111 = rimd,
    tabledata 112 = rimd,
    tabledata 113 = rimd,
    tabledata 114 = rimd,
    tabledata 115 = rimd,
    tabledata 120 = rimd,
    tabledata 121 = rimd,
    tabledata 122 = rimd,
    tabledata 123 = rimd,
    tabledata 124 = rimd,
    tabledata 125 = rimd,
    tabledata 81 = rimd,
    tabledata 25 = rimd,
    tabledata 21 = rimd,
    tabledata 379 = rimd,
    tabledata 380 = rimd;

    trigger OnRun()
    VAR
        rCab: Record 38;
        PurchPostViaJobQueue: Codeunit "Purchase Post via Job Queue";
        Contratos: Record 36;
        ReleaseSalesDoc: Codeunit "Release Sales Document";
        Contabiliza: Boolean;
        ImpV: Decimal;
        ImpC: Decimal;
        FechaV: Date;
        FechaC: Date;
        Eventos: Codeunit ControldeEventosCodeunits;
    BEGIN
        //rCab.GET(rCab."Document Type"::Order,'CTO13-00898');
        //GeneraContrasientoprepago(rCab,TODAY);
        //EnviarMailJm('CTO20003', 'Prueba');
        rCab.SetRange("Document Type", rCab."Document Type"::Invoice);
        rCab.SetFilter("Vendor Invoice No.", '<>%1', '');
        rCab.SetFilter("Empresa Factura", '<>%1', '');
        rCab.SetRange(ContabilizaInter, True);
        rCab.SetRange(EnProceso, False);

        if rCab.FindSet() Then
            Repeat

                rCab.EnProceso := True;
                rCab.Modify();
                Contabiliza := True;
                If rCab."Document Type" = rCab."Document Type"::Invoice Then begin
                    If Not Eventos.ImporteProv(rCab, Impv, ImpC) Then Contabiliza := False;
                    If Not Eventos.FechaProv(rCab, Fechav, FechaC) Then Contabiliza := False;
                end;
                PurchPostViaJobQueue.EnqueuePurchDoc(Rcab)
            Until rCab.Next() = 0;
        commit;
        //Contratos.SetRange("Facturacion Iniciada", true);
        Contratos.SetRange("Document Type", Contratos."Document Type"::Order);
        Contratos.SetRange(Status, Contratos.Status::Open);
        Contratos.SetRange("Order Date", CalcDate('-3M', TODAY), TODAY);
        Contratos.SetRange("Salesperson Code", '1090', '1099');
        If Contratos.FindSet() Then
            Repeat
                ReleaseSalesDoc.PerformManualRelease(Contratos);
                commit;
            Until Contratos.Next() = 0;

    END;


    VAR
        ConfVtas: Record 311;
        rLin: Record 37;
        rLinPrepago: Record 37;
        rTerminos: Record 3;
        rOrden: Record "Cab. orden publicidad";
        rLinOrden: Record "Lin. orden publicidad";
        rSerie: Record 308;
        rCabFra: Record 36;
        rLinFra: Record 37;
        rComentVenta: Record 44;
        rComent2: Record 44;
        rTnos: Record "Términos facturación";
        rPlazos: Record "Plazos de facturación";
        rPlazos2: Record "Plazos de facturación";
        rRecurso: Record 156;
        rCabTemp: Record 36;
        rLinTemp: Record 37;
        GestNoSer: Codeunit "No. Series";
        AdjustDueDate: Codeunit 10700;
        cGesCartera: Codeunit "Gestion cartera";
        ReleaseSalesDoc: Codeunit "Release Sales Document";
        wFecha: Date;
        Text001: Label '% contrato';
        fechaR: Date;
        fechaRDes: Date;
        fechaI: Date;
        fechaF: Date;
        fechaReg: Date;
        wFechaD: Date;
        wFechaH: Date;
        w1Fac: Boolean;
        w1FacPro: Boolean;
        Text002: Label 'No se permite reparto 1ª Fra y 1ª Fra+proporc. en un mismo contrato';
        wSelec: Integer;
        Text003: Label 'Por &términos,Por &Fechas,Por &líneas';
        wBucle: Integer;
        Text004: Label 'La Propuesta de Facturación ya se ha generado. ¿Desea continuar y reescribir la propuesta anterior?';
        wDiasFact: Integer;
        wDias: Integer;
        wLinea: Integer;
        wLinTemp: Integer;
        wMesesCont: Integer;
        wDiasCont: Integer;
        dPrepago: Decimal;
        dPrepagoIVA: Decimal;
        wImpPrepago: Decimal;
        wImpPrepago2: Decimal;
        wTotLinFac: Decimal;
        wTotLinCont: Decimal;
        wTotLinFacCost: Decimal;
        wTotLinContCost: Decimal;
        wTotPrepago: Decimal;
        wDiasFactEsp: Decimal;
        wDiasSumar: Decimal;
        finestra: Dialog;
        Text005: Label 'Se van a facturar todas las Ordenes de Publicidad entre %1 y %2, y se creará un borrador de factura con fecha %3. ¿Es correcto?';
        Text006: Label 'Ya se han creado los borradores de facturas de este contrato.';
        fDatos: page 50010;
        Text007: Label 'Este contrato tiene lineas que no proceden de Ordenes de Publicidad.\La Facturación Por Fechas no contemplará esas lineas.';
        Text008: Label 'Este contrato ya ha sido empezado con la facturacion %1 y no puede ser cambiado.';
        Text009: Label 'Facturación %1 finalizada. Se ha creado el borrador de Factura Nº %2.';
        Text010: Label 'Facturación de %1 a %2.';
        Text011: Label 'No existe Config. Grupos contables %1 - %2';
        Text012: Label 'Especifique Cuenta prepagos en config. grupos contables %1 - %2';
        Text013: Label 'Se van a facturar todas las lineas marcadas. ¿Es correcto?';
        Text014: Label 'No hay ninguna linea marcada para facturar.';
        Text015: Label 'Facturación %1.';
        Text016: Label 'Se han encontrado precios distintos en la orden de pago. Revise el borrador de factura.';
        Text017: Label 'Facturación %1 finalizada. Se ha creado el borrador de Factura Nº %2 y el efecto asociado.';
        Text018: Label 'Facturación %1 finalizada. Se ha creado el borrador de Factura Nº %2. Revise el diario de cartera, no se han registrado los efectos a cobrar.';
        wTxtFec: Text[10];
        DimMng: Codeunit 408;
        GestionProyecto: Codeunit "Gestion Proyecto";
        rJob: Record Job;
        rJobSetup: Record "Jobs Setup";
        ShorCutDim: ARRAY[8] OF Code[20];


    PROCEDURE Crear_Albaranes(VAR rCab: Record 36; pPositivo: Boolean);
    VAR
        rPropVto: Record "Facturas Propuestas";
        i: Integer;
        yafact: Decimal;
        yadura: Decimal;
        wFecVto: Date;
        SerieCode: Code[20];
        wImpPrepagoCoste: Decimal;
        Fra: Record 36;

    BEGIN
        //$017 Incluyo parámetro pPositivo.
        if (rCab."Tipo Facturacion" = Rcab."Tipo Facturacion"::"Por Lineas") THEN
            ERROR('Solo es válido, si la facturación es por líneas o por fechas.');
        // Filtra las Fra de este contrato que no sean prepayments
        Fra.SETRANGE("Document Type", rCab."Document Type"::Invoice);
        Fra.SETRANGE(Fra."Nº Contrato", rCab."No.");
        Fra.SETRANGE(Fra."Factura prepago", FALSE);
        if Fra.FindFirst() THEN
            ERROR('No hay facturas de anticipo para este contrato.');

        rCab.TESTFIELD("Cód. términos facturacion");
        fechaR := rCab."Posting Date";
        fechaRDes := rCab."Fecha inicial proyecto";                       //$005
        wFecha := fechaR;
        rTnos.GET(rCab."Cód. términos facturacion");

        rTnos.CALCFIELDS("Nº de plazos");
        wTotPrepago := 0;                                                   //FCL-19/04/10

        ComprobarReparto(rCab, rTnos);

        if NOT CONFIRM('Se van a generar ' + STRSUBSTNO('%1', wBucle) + ' albaranes de este contrato.\' +
                       'El proyecto esta entre ' + STRSUBSTNO('%1', rCab."Fecha inicial proyecto") + ' y ' +
                       STRSUBSTNO('%1', rCab."Fecha fin proyecto") + ' \' +
                       ' y el termino de facturacion elegido es ' + rCab."Cód. términos facturacion") THEN
            EXIT;

        ////{ *** Pido Nº Serie registro *** }
        //$017
        if pPositivo THEN BEGIN
            SerieCode := LookupSeries(ConfVtas."Posted Invoice Nos.", rSerie.Code);
        END ELSE BEGIN
            SerieCode := LookupSeries(ConfVtas."Posted Credit Memo Nos.", rSerie.Code);
        END;

        finestra.OPEN('Creando #3# de un total de #2# -------> Nº #1########');
        finestra.UPDATE(2, wBucle);

        // $030 Limpio campo temporal
        rLin.RESET;
        rLin.SETRANGE("Document Type", rCab."Document Type");
        rLin.SETRANGE("Document No.", rCab."No.");
        rLin.SetFilter(Reparto, '<>%1', rLin.Reparto::"Fra prepago");
        if rLin.FINDSET THEN
            rLin.MODIFYALL("Cdad. Facturada MLL", 0);

        //$020(I)
        wMesesCont := rCab."Fecha fin proyecto" - rCab."Fecha inicial proyecto";
        wMesesCont := ROUND(wMesesCont / 30.42, 1);          //son 365 dias entre 12 meses
        wDiasFactEsp := 0;
        if (wBucle < wMesesCont) AND (wBucle <> 1) THEN BEGIN
            wDiasCont := (rCab."Fecha fin proyecto" - rCab."Fecha inicial proyecto") + 1;
            wFechaD := fechaRDes;
            wFechaH := fechaRDes;
            FOR i := 1 TO wBucle DO BEGIN
                if rPlazos."Distancia entre plazos" = '' Then
                    wFechaH := CalcDate(rTnos."Cálculo de Plazos", wFechaH)
                else
                    wFechaH := CALCDATE(rPlazos."Distancia entre plazos", wFechaH);
            END;
            wFechaH := wFechaH - 1;
            wDiasFactEsp := (wFechaH - wFechaD) + 1;
        END;
        //$020(F)

        //$008(I)
        rLin.RESET;
        rLin.SETRANGE("Document Type", rCab."Document Type");
        rLin.SETRANGE("Document No.", rCab."No.");
        rLin.SetFilter(Reparto, '<>%1', rLin.Reparto::"Fra prepago");
        wImpPrepago := 0;
        If rLin.FindSet() Then
            Repeat
                wImpPrepago += rLin."Prepmt. Amt. Inv.";
            Until rLin.Next() = 0;


        //$008(F)
        if rTnos."Nº de plazos" = 0 then begin
            rTnos."Nº de plazos" := rTnos."Nº de Facturas";
            rPlazos.Init();
        end;
        //$034(I) Generaré nº de bucles + 1¦ fra.
        if w1Fac THEN BEGIN
            wBucle := wBucle + 1;

            rTnos."Nº de plazos" := rTnos."Nº de plazos" + 1;
        END;
        //$034(F)

        FOR i := 1 TO wBucle DO BEGIN
            finestra.UPDATE(3, i);
            if rTnos."Nº de Facturas" = 0 then
                rPlazos.TESTFIELD("% del total");

            /////if (rTnos."Nº de plazos" = 13) AND (i = 2) THEN                   //FCL-18/06/04   //$023
            /////  fechaR:=wFecha;                                                 //FCL-18/06/04   //$023

            ////{ *** Cabecera de factura *** }
            CabeceraComun(fechaR, rCab, pPositivo, SerieCode);
            //rCabFra.VALIDATE("Posting Description",'Periodo facturación: ' + STRSUBSTNO('%1',fechaRDes) + ' - ');  //$005
            //$034(I)
            if NOT w1Fac THEN BEGIN
                //$034(F)
                rCabFra.VALIDATE("Posting Description", STRSUBSTNO('%1', fechaRDes) + ' - ');                              //$005,$027
                                                                                                                           //$034(I)
            END
            ELSE BEGIN
                rCabFra.VALIDATE("Posting Description", rCab."No.");
            END;
            //$034(F)

            //$029(I)
            CLEAR(wFecVto);
            rPropVto.RESET;
            rPropVto.SETRANGE("No. Contrato", rCab."No.");
            rPropVto.SETRANGE(rPropVto."No. linea", i);               //números de línea están grabados de 1 en 1
            if rPropVto.FIND('-') THEN
                wFecVto := rPropVto."Fecha Vencimiento";
            if (rCabFra."Due Date" <> wFecVto) AND (wFecVto <> 0D) THEN
                rCabFra.VALIDATE("Due Date", wFecVto);
            if rPropVto."Customer Order No." <> '' THEN
                rCabFra.VALIDATE("Customer Order No.", rPropVto."Customer Order No.");
            //$029(F)

            ////{ *** Lineas de factura *** }
            rLin.SETCURRENTKEY("Document Type", "Document No.", "Line No.");
            rLin.SETRANGE("Document Type", rCab."Document Type");
            rLin.SETRANGE("Document No.", rCab."No.");
            rLin.SetFilter(Reparto, '<>%1', rLin.Reparto::"Fra prepago");
            //FCL-16/02/06(I).
            if w1Fac THEN BEGIN
                rLin.SETRANGE(Reparto, rLin.Reparto::"1ª Fra");
            END
            ELSE BEGIN
                if (w1FacPro) AND (i = 1) THEN BEGIN
                    //rLin.SETFILTER(Reparto,'<>%1',rLin.Reparto::"1¦ Fra");                                              //$025
                    rLin.SETFILTER(Reparto, '<>%1 & <>%2', rLin.Reparto::"1ª Fra", rLin.Reparto::"Fra prepago");             //$025
                END
                ELSE BEGIN
                    rLin.SETRANGE(Reparto, rLin.Reparto::Proporcional);
                END;
            END;
            //FCL-16/02/06(F).

            if rLin.FIND('-') THEN
                REPEAT
                    // $003
                    if (rLin.Type.AsInteger() <> 0) THEN BEGIN
                        rLin.TESTFIELD("Shortcut Dimension 1 Code");
                        rLin.TESTFIELD("Shortcut Dimension 2 Code");
                    END;
                    CLEAR(rLinFra);
                    rLinFra.INIT;
                    rLinFra."Document Type" := rCabFra."Document Type";
                    rLinFra."Document No." := rCabFra."No.";
                    rLinFra."Line No." := rLin."Line No.";
                    rLinFra."Customer Order No." := rLin."Customer Order No.";
                    rLinFra.INSERT;
                    rLinFra.VALIDATE("Sell-to Customer No.", rCabFra."Sell-to Customer No.");
                    rLinFra.VALIDATE(Type, rLin.Type);
                    rLinFra.VALIDATE("No.", rLin."No.");
                    //$036(I)
                    if rLin.Type.AsInteger() <> 0 THEN BEGIN
                        rLinFra.VALIDATE("VAT Bus. Posting Group", rLin."VAT Bus. Posting Group");
                        rLinFra.VALIDATE("VAT Prod. Posting Group", rLin."VAT Prod. Posting Group");
                    END;
                    //$036(F)
                    rLinFra.VALIDATE(Description, rLin.Description);
                    rLinFra.VALIDATE("Description 2", rLin."Description 2");
                    //$031(I)
                    if (rLin.Type = rLin.Type::Resource) THEN
                        rLinFra.VALIDATE("Cód. proveedor", rLin."Cód. proveedor");
                    //$031(F)
                    //+001
                    //  rLinFra.VALIDATE("Shortcut Dimension 1 Code", rLin."Shortcut Dimension 1 Code");
                    //  rLinFra.VALIDATE("Shortcut Dimension 2 Code", rLin."Shortcut Dimension 2 Code");
                    //-001
                    rLinFra.VALIDATE("Job No.", rLin."Job No.");
                    /*  {
                     rLinFra.VALIDATE(RowID1, rLin.RowID1);
                     rLinFra.VALIDATE(GetItemCrossRef, rLin.GetItemCrossRef);
                     rLinFra.VALIDATE(GetResource, rLin.GetResource);
                     } */
                    rLinFra.VALIDATE("Job Task No.", rLin."Job Task No.");
                    if rTnos."Nº de plazos" = 0 Then rTnos."Nº de plazos" := rTnos."Nº de Facturas";
                    //      //{ *** ¿me faltan los descuentos? ***}
                    CLEAR(yafact);
                    if rLin.Reparto = rLin.Reparto::Proporcional THEN BEGIN          //FCL-16/02/06
                        yafact := rLin.Quantity * rPlazos."% del total" / 100;
                        yadura := rlin.Duracion * rPlazos."% del total" / 100;
                        if rPlazos."% del total" = 0 Then yafact := Round(rLin.Quantity / rTnos."Nº de Facturas", 0.001, '=');
                        if rPlazos."% del total" = 0 Then yadura := Round(rLin.Duracion / rTnos."Nº de Facturas", 0.001, '=');
                        rLin."Cdad. Facturada MLL" := rLin."Cdad. Facturada MLL" + yafact;
                        rlin."Duración Facturada MLL" := rlin."Duración Facturada MLL" + yadura;
                        if (i = rTnos."Nº de plazos") THEN BEGIN //{Es la ultima factura, asegurarse de que se factura todo}
                            if (rLin."Cdad. Facturada MLL" <> rLin.Quantity) THEN BEGIN
                                rLin."Cdad. Facturada MLL" := rLin."Cdad. Facturada MLL" - yafact;
                                yafact := rLin.Quantity - rLin."Cdad. Facturada MLL";
                                rLin."Cdad. Facturada MLL" := rLin."Cdad. Facturada MLL" + yafact;
                            END;
                            if (rLin."Duración Facturada MLL" <> rLin.Duracion) THEN BEGIN
                                rLin."Duración Facturada MLL" := rLin."Duración Facturada MLL" - yadura;
                                yadura := rLin.Duracion - rLin."Duración Facturada MLL";
                                rLin."Duración Facturada MLL" := rLin."Duración Facturada MLL" + yadura;
                            END;
                        END;
                    END                                                              //FCL-16/02/06
                    ELSE BEGIN
                        // i:=1-1;                                        //FCL-16/02/06
                        yafact := rLin.Quantity;
                        yadura := rLin.Duracion;                                    //FCL-16/02/06
                    END;                                                             //FCL-16/02/06
                    if (yafact <> 0) THEN
                        rLinFra.VALIDATE(Quantity, yafact);
                    if (yadura <> 0) Then rLinFra.Duracion := yadura;
                    if (yadura <> 0) Then rLinFra."Cdad. Soportes" := rLin."Cdad. Soportes";
                    if (NOT pPositivo) AND (rLinFra.Quantity <> 0) THEN begin           //$017
                        rLinFra.VALIDATE(Quantity, -rLinFra.Quantity);
                        rLinFra.Duracion := -rLinFra.Duracion;
                    end;         //$017
                    if (rLin."Unit Price" <> 0) THEN
                        rLinFra.VALIDATE("Unit Price", rLin."Unit Price");
                    //  FCL-09/03/04. Migración 2.0. a 3.70. El siguiente campo ya no existe.
                    //  rLinFra.VALIDATE(("% Dto. cantidad",rLin."% Dto. cantidad");
                    if (rLin."Line Discount %" <> 0) THEN
                        rLinFra.VALIDATE("Line Discount %", rLin."Line Discount %");
                    //  FCL-09/03/04. Migración 2.0. a 3.70. El siguiente ya no existe.
                    //  rLinFra.VALIDATE("% Dto. cliente/producto", rLin."% Dto. cliente/producto");

                    //+001
                    ShorCutDim[1] := rLin."Shortcut Dimension 1 Code";
                    ShorCutDim[2] := rLin."Shortcut Dimension 2 Code";
                    ShorCutDim[3] := rLin."Shortcut Dimension 3 Code";
                    ShorCutDim[4] := rLin."Shortcut Dimension 4 Code";
                    ShorCutDim[5] := rLin."Shortcut Dimension 5 Code";
                    rLin.ShowShortcutDimCode(ShorCutDim);
                    if ShorCutDim[1] = '' THEN ShorCutDim[1] := rLin."Shortcut Dimension 1 Code";
                    if ShorCutDim[1] = '' THEN ShorCutDim[2] := rLin."Shortcut Dimension 2 Code";
                    if ShorCutDim[1] = '' THEN ShorCutDim[3] := rLin."Shortcut Dimension 3 Code";
                    if ShorCutDim[1] = '' THEN ShorCutDim[4] := rLin."Shortcut Dimension 4 Code";
                    if ShorCutDim[1] = '' THEN ShorCutDim[5] := rLin."Shortcut Dimension 5 Code";

                    rLinFra.VALIDATE("Shortcut Dimension 1 Code", ShorCutDim[1]);
                    rLinFra.VALIDATE("Shortcut Dimension 2 Code", ShorCutDim[2]);
                    rLinFra.VALIDATE("Shortcut Dimension 3 Code", ShorCutDim[3]);
                    rLinFra.VALIDATE("Shortcut Dimension 4 Code", ShorCutDim[4]);
                    rLinFra.VALIDATE("Shortcut Dimension 5 Code", ShorCutDim[5]);

                    CLEAR(DimMng);
                    //Revisar
                    /* FromDocDim.SETRANGE(FromDocDim."Table ID", 37);
                    FromDocDim.SETRANGE(FromDocDim."Document Type", rLin."Document Type");
                    FromDocDim.SETRANGE(FromDocDim."Document No.", rLin."Document No.");
                    FromDocDim.SETRANGE(FromDocDim."Line No.", rLin."Line No.");
                    if FromDocDim.FINDFIRST THEN
                        REPEAT
                          
                            if ToDocDim.INSERT THEN;
                        UNTIL FromDocDim.NEXT = 0; */
                    //-001
                    rLinFra.VALIDATE("No linea proyecto", rLin."No linea proyecto");          //$018
                    rLinFra."Fecha inicial recurso" := rLin."Fecha inicial recurso";  //$021
                    rLinFra."Fecha final recurso" := rLin."Fecha final recurso";      //$021
                    rLinFra.VALIDATE("Imprimir fecha recurso", rLin."Imprimir fecha recurso");//$024
                    rLinFra.Imprimir := true;                                        //$024
                    rLinFra.VALIDATE(Remarcar, rLin.Remarcar);                                //$039
                    rlinFra."Precio Compra" := rlin."Precio Compra";         //$040
                    rLinFra."Dto. Compra" := rLin."Dto. Compra";
                    rLinFra.MODIFY;
                    rLin.MODIFY;

                //$008. Bloqueo esta parte, será un total
                //if (rLin."Prepmt. Amt. Inv." <> 0) THEN BEGIN
                //  Linea_Prepago(rLinFra.Quantity, rLin."Prepmt. Amt. Inv.");
                //END;

                UNTIL rLin.NEXT = 0;

            //$008(I)
            if wImpPrepago <> 0 THEN BEGIN
                //$025(I)
                //rCab.CALCFIELDS("Importe líneas");
                //rCabFra.CALCFIELDS("Importe líneas");
                wTotLinCont := TotalLineasRep(rCab."Document Type".AsInteger(), rCab."No.");
                wTotLinFac := TotalLineasRep(rCabFra."Document Type".AsInteger(), rCabFra."No.");
                wTotLinContCost := TotalLineasRepCost(rCab."Document Type".AsInteger(), rCab."No.");
                wTotLinFacCost := TotalLineasRepCost(rCabFra."Document Type".AsInteger(), rCabFra."No.");

                //wImpPrepago2 := ROUND((wImpPrepago * rCabFra."Importe líneas") / rCab."Importe líneas");
                wImpPrepago2 := ROUND((wImpPrepago * wTotLinFac) / wTotLinCont);

                //$025(F)
                wTotPrepago := wTotPrepago + wImpPrepago2;
                if i = wBucle THEN BEGIN                                       //Sumo la diferencia a la última línea
                    if wTotPrepago <> wImpPrepago THEN
                        wImpPrepago2 := wImpPrepago2 + (wImpPrepago - wTotPrepago);
                END;
                if wTotLinFac <> 0 then wImpPrepagoCoste := ROUND(wImpPrepago * (wTotLinFacCost / wTotLinFac));
                Linea_Prepago(1, wImpPrepago2, wImpPrepagoCoste);
            END;
            wTotLinFac := TotalLineasRep(rCabFra."Document Type".AsInteger(), rCabFra."No.");
            if wTotLinFac <> 0 Then begin
                Linea_Prepago(1, wTotLinFac, wTotLinFac);

            end;
            //$008(F)

            //$034(I)
            if NOT w1Fac THEN BEGIN
                //$034(F)
                if rPlazos."Distancia entre plazos" = '' Then rPlazos."Distancia entre plazos" := StrSubstNo('%1', rTnos."Cálculo de Plazos");
                rPlazos.TESTFIELD("Distancia entre plazos");
                fechaR := CALCDATE(rPlazos."Distancia entre plazos", fechaR);
                fechaRDes := CALCDATE(rPlazos."Distancia entre plazos", fechaRDes);         //$005
                                                                                            //FCL-18/06/04 (I)
                                                                                            /////if (rTnos."Nº de plazos" = 13) AND (i = 1) THEN BEGIN                  //$023
                                                                                            /////  rCabFra.VALIDATE("Posting Description",FORMAT(rPlazos."% del total")+Text001);  //$023
                                                                                            /////END ELSE BEGIN                                                                    //$023
                                                                                            //FCL-18/06/04 (F)
                                                                                            //{Para acabar de completar el periodo de factura.}
                                                                                            //$005
                                                                                            //rCabFra.VALIDATE("Posting Description", rCabFra."Posting Description" + STRSUBSTNO('%1', fechaR-1));
                rCabFra.VALIDATE("Posting Description", rCabFra."Posting Description" + STRSUBSTNO('%1', fechaRDes - 1));
                /////END;                   $023                                               //FCL-18/06/04
                //$020(I)
                if wDiasFactEsp <> 0 THEN BEGIN
                    wDiasSumar := ROUND(wDiasCont * ((fechaR - 1) - rCabFra."Posting Date") / wDiasFactEsp, 1);
                    if i = 1 THEN
                        wFechaD := rCab."Fecha inicial proyecto";
                    if i <> wBucle THEN BEGIN
                        wTxtFec := '+' + FORMAT(wDiasSumar, 0, '<integer>') + 'D';
                        wFechaH := CALCDATE(wTxtFec, wFechaD);
                    END
                    ELSE BEGIN
                        wFechaH := rCab."Fecha fin proyecto";
                    END;
                    //rCabFra.VALIDATE("Posting Description",'Periodo facturación: ' +
                    //                STRSUBSTNO('%1',wFechaD) + ' - ' + STRSUBSTNO('%1', wFechaH));
                    rCabFra.VALIDATE("Posting Description", STRSUBSTNO('%1', wFechaD) + ' - ' + STRSUBSTNO('%1', wFechaH));        //$027

                    wFechaD := wFechaH + 1;
                END
                ELSE BEGIN
                    if rTnos."Nº de plazos" = 1 THEN
                        //rCabFra.VALIDATE("Posting Description",'Periodo facturación: ' +
                        //              STRSUBSTNO('%1',rCab."Fecha inicial proyecto") + ' - ' + STRSUBSTNO('%1',rCab."Fecha fin proyecto"));
                        rCabFra.VALIDATE("Posting Description",                                                                                 //$027
                          STRSUBSTNO('%1', rCab."Fecha inicial proyecto") + ' - ' + STRSUBSTNO('%1', rCab."Fecha fin proyecto"));

                END;
                //$020(F)
                rCabFra."Fecha final factura" := fechaR - 1;                              //FCL-17/06/04
                                                                                          //$034(I)
            END
            ELSE BEGIN
                rCabFra."Fecha final factura" := rCabFra."Fecha inicial factura";
            END;
            //$034(F)
            rCabFra."Customer Order No." := rCab."Customer Order No.";
            rCabFra."Vendedor Origen" := rCab."Vendedor Origen";
            rCabFra."Salesperson Code" := rCab."Salesperson Code";
            rCabFra.MODIFY;
            if (NOT w1Fac) and (rPlazos."% del total" <> 0) THEN rPlazos.NEXT;
            if (i <= 1) AND (w1Fac) THEN BEGIN                                     //FCL-16/02/06
                                                                                   ////i:= i - 1;                                                      //FCL-16/02/06          //$025
                w1Fac := FALSE;                                                       //FCL-16/02/06
            END;                                                                  //FCL-16/02/06
            If i = wBucle Then begin
                rPropVto.SETRANGE(rPropVto."No. linea");               //números de línea están grabados de 1 en 1
                If not rPropVto.FindLast() then
                    Message('No se ha encontrado la última línea de la propuesta de vencimientos')
                else
                    CalcularUtimaFactura(rCabFra, rPropVto, false);
            end;
            //$012


        end;
        rCab.Modify();
        Commit();
        rCab.Get(rCab."Document Type", rCab."No.");
        //$028(I)
        if rCab.Status = rCab.Status::Open THEN
            ReleaseSalesDoc.PerformManualRelease(rCab);
        //$028(F)
        rCab.MODIFY;
        finestra.CLOSE;
        MESSAGE('Facturacion finalizada.\' +
                    'Se han creado %1 borradores de albaranes.', wBucle);
        //$012(I)

        //$012(F)
    END;


    PROCEDURE Crear_Facturas(VAR rCab: Record 36; pPositivo: Boolean);
    BEGIN
        //$017 Incluyo parámetro pPositivo.

        if (rCab."Document Type" <> rCab."Document Type"::Order) THEN
            ERROR('Solo puede crear los borradores de facturas de los contratos de venta');


        ConfVtas.GET;
        ConfVtas.TESTFIELD("Posted Invoice Nos.");
        ConfVtas.TESTFIELD("Posted Credit Memo Nos.");                 //$017
        ConfVtas.TESTFIELD("Order Nos.");
        ConfVtas.TESTFIELD("Invoice Nos.");
        ConfVtas.TESTFIELD("Credit Memo Nos.");                        //$017
        ConfVtas.TESTFIELD("Posted Invoice Nos.");
        ConfVtas.TESTFIELD("Posted Shipment Nos.");
        rCab.TESTFIELD("Posting Date");
        rCab.TESTFIELD("Payment Terms Code");
        rCab.TESTFIELD("Payment Method Code");

        //$003
        if (rCab."Tipo Facturacion" = rCab."Tipo Facturacion"::" ") THEN BEGIN
            wSelec := STRMENU(Text003, ConfVtas."Facturación resaltada".AsInteger());
            if wSelec = 0 THEN
                EXIT;
            if (rCab."Facturacion Iniciada") THEN BEGIN
                if (rCab."Tipo Facturacion".AsInteger() <> wSelec) THEN
                    ERROR(Text008, rCab."Tipo Facturacion");
            END;
        END ELSE
            wSelec := rCab."Tipo Facturacion".AsInteger();

        CASE wSelec OF
            1:
                Crear_Facturas_Terminos(rCab, pPositivo);
            2:
                Crear_Facturas_Fechas(rCab, pPositivo);
            3:
                Crear_Facturas_Lineas(rCab, pPositivo);
        END;
    END;

    PROCEDURE Crear_Facturas_Terminos(VAR rCab: Record 36; pPositivo: Boolean);
    VAR
        rPropVto: Record "Facturas Propuestas";
        i: Integer;
        yafact: Decimal;
        yadura: Decimal;
        wFecVto: Date;
        SerieCode: Code[20];
        wImpPrepagoCoste: Decimal;
        Fra: Record 36;

    BEGIN
        //$017 Incluyo parámetro pPositivo.
        if (rCab."Creada su facturación") THEN
            ERROR(Text006);
        // Filtra las Fra de este contrato que no sean prepayments
        Fra.SETRANGE("Document Type", rCab."Document Type"::Invoice);
        Fra.SETRANGE(Fra."Nº Contrato", rCab."No.");
        Fra.SETRANGE(Fra."Factura prepago", FALSE);
        if Fra.FindFirst() THEN
            ERROR(Text006);

        rCab.TESTFIELD("Cód. términos facturacion");
        fechaR := rCab."Posting Date";
        fechaRDes := rCab."Fecha inicial proyecto";                       //$005
        wFecha := fechaR;
        rTnos.GET(rCab."Cód. términos facturacion");

        rTnos.CALCFIELDS("Nº de plazos");
        wTotPrepago := 0;                                                   //FCL-19/04/10

        ComprobarReparto(rCab, rTnos);

        if NOT CONFIRM('Se van a generar ' + STRSUBSTNO('%1', wBucle) + ' facturas de este contrato.\' +
                       'El proyecto esta entre ' + STRSUBSTNO('%1', rCab."Fecha inicial proyecto") + ' y ' +
                       STRSUBSTNO('%1', rCab."Fecha fin proyecto") + ' \' +
                       ' y el termino de facturacion elegido es ' + rCab."Cód. términos facturacion") THEN
            EXIT;

        ////{ *** Pido Nº Serie registro *** }
        //$017
        if pPositivo THEN BEGIN
            SerieCode := LookupSeries(ConfVtas."Posted Invoice Nos.", rSerie.Code);
        END ELSE BEGIN
            SerieCode := LookupSeries(ConfVtas."Posted Credit Memo Nos.", rSerie.Code);
        END;

        finestra.OPEN('Creando #3# de un total de #2# -------> Nº #1########');
        finestra.UPDATE(2, wBucle);

        // $030 Limpio campo temporal
        rLin.RESET;
        rLin.SETRANGE("Document Type", rCab."Document Type");
        rLin.SETRANGE("Document No.", rCab."No.");
        rLin.SetFilter(Reparto, '<>%1', rLin.Reparto::"Fra prepago");
        if rLin.FINDSET THEN
            rLin.MODIFYALL("Cdad. Facturada MLL", 0);

        //$020(I)
        wMesesCont := rCab."Fecha fin proyecto" - rCab."Fecha inicial proyecto";
        wMesesCont := ROUND(wMesesCont / 30.42, 1);          //son 365 dias entre 12 meses
        wDiasFactEsp := 0;
        if (wBucle < wMesesCont) AND (wBucle <> 1) THEN BEGIN
            wDiasCont := (rCab."Fecha fin proyecto" - rCab."Fecha inicial proyecto") + 1;
            wFechaD := fechaRDes;
            wFechaH := fechaRDes;
            FOR i := 1 TO wBucle DO BEGIN
                if rPlazos."Distancia entre plazos" = '' Then
                    wFechaH := CalcDate(rTnos."Cálculo de Plazos", wFechaH)
                else
                    wFechaH := CALCDATE(rPlazos."Distancia entre plazos", wFechaH);
            END;
            wFechaH := wFechaH - 1;
            wDiasFactEsp := (wFechaH - wFechaD) + 1;
        END;
        //$020(F)

        //$008(I)
        rLin.RESET;
        rLin.SETRANGE("Document Type", rCab."Document Type");
        rLin.SETRANGE("Document No.", rCab."No.");
        rLin.SetFilter(Reparto, '<>%1', rLin.Reparto::"Fra prepago");
        wImpPrepago := 0;
        If rLin.FindSet() Then
            Repeat
                wImpPrepago += rLin."Prepmt. Amt. Inv.";
            Until rLin.Next() = 0;


        //$008(F)
        if rTnos."Nº de plazos" = 0 then begin
            rTnos."Nº de plazos" := rTnos."Nº de Facturas";
            rPlazos.Init();
        end;
        //$034(I) Generaré nº de bucles + 1¦ fra.
        if w1Fac THEN BEGIN
            wBucle := wBucle + 1;

            rTnos."Nº de plazos" := rTnos."Nº de plazos" + 1;
        END;
        //$034(F)

        FOR i := 1 TO wBucle DO BEGIN
            finestra.UPDATE(3, i);
            if rTnos."Nº de Facturas" = 0 then
                rPlazos.TESTFIELD("% del total");

            /////if (rTnos."Nº de plazos" = 13) AND (i = 2) THEN                   //FCL-18/06/04   //$023
            /////  fechaR:=wFecha;                                                 //FCL-18/06/04   //$023

            ////{ *** Cabecera de factura *** }
            CabeceraComun(fechaR, rCab, pPositivo, SerieCode);
            //rCabFra.VALIDATE("Posting Description",'Periodo facturación: ' + STRSUBSTNO('%1',fechaRDes) + ' - ');  //$005
            //$034(I)
            if NOT w1Fac THEN BEGIN
                //$034(F)
                rCabFra.VALIDATE("Posting Description", STRSUBSTNO('%1', fechaRDes) + ' - ');                              //$005,$027
                                                                                                                           //$034(I)
            END
            ELSE BEGIN
                rCabFra.VALIDATE("Posting Description", rCab."No.");
            END;
            //$034(F)

            //$029(I)
            CLEAR(wFecVto);
            rPropVto.RESET;
            rPropVto.SETRANGE("No. Contrato", rCab."No.");
            rPropVto.SETRANGE(rPropVto."No. linea", i);               //números de línea están grabados de 1 en 1
            if rPropVto.FIND('-') THEN
                wFecVto := rPropVto."Fecha Vencimiento";
            if (rCabFra."Due Date" <> wFecVto) AND (wFecVto <> 0D) THEN
                rCabFra.VALIDATE("Due Date", wFecVto);
            if rPropVto.FIND('-') THEN
                rCabFra."Línea Borrador" := i;
            if rPropVto."Customer Order No." <> '' THEN
                rCabFra.VALIDATE("Customer Order No.", rPropVto."Customer Order No.");
            //$029(F)

            ////{ *** Lineas de factura *** }
            rLin.SETCURRENTKEY("Document Type", "Document No.", "Line No.");
            rLin.SETRANGE("Document Type", rCab."Document Type");
            rLin.SETRANGE("Document No.", rCab."No.");
            rLin.SetFilter(Reparto, '<>%1', rLin.Reparto::"Fra prepago");
            //FCL-16/02/06(I).
            if w1Fac THEN BEGIN
                rLin.SETRANGE(Reparto, rLin.Reparto::"1ª Fra");
            END
            ELSE BEGIN
                if (w1FacPro) AND (i = 1) THEN BEGIN
                    //rLin.SETFILTER(Reparto,'<>%1',rLin.Reparto::"1¦ Fra");                                              //$025
                    rLin.SETFILTER(Reparto, '<>%1 & <>%2', rLin.Reparto::"1ª Fra", rLin.Reparto::"Fra prepago");             //$025
                END
                ELSE BEGIN
                    rLin.SETRANGE(Reparto, rLin.Reparto::Proporcional);
                END;
            END;
            //FCL-16/02/06(F).

            if rLin.FIND('-') THEN
                REPEAT
                    // $003
                    if (rLin.Type.AsInteger() <> 0) THEN BEGIN
                        rLin.TESTFIELD("Shortcut Dimension 1 Code");
                        rLin.TESTFIELD("Shortcut Dimension 2 Code");
                    END;
                    CLEAR(rLinFra);
                    rLinFra.INIT;
                    rLinFra."Document Type" := rCabFra."Document Type";
                    rLinFra."Document No." := rCabFra."No.";
                    rLinFra."Line No." := rLin."Line No.";
                    rLinFra."Customer Order No." := rLin."Customer Order No.";
                    rLinFra.INSERT;
                    rLinFra.VALIDATE("Sell-to Customer No.", rCabFra."Sell-to Customer No.");
                    rLinFra.VALIDATE(Type, rLin.Type);
                    rLinFra.VALIDATE("No.", rLin."No.");
                    //$036(I)
                    if rLin.Type.AsInteger() <> 0 THEN BEGIN
                        rLinFra.VALIDATE("VAT Bus. Posting Group", rLin."VAT Bus. Posting Group");
                        rLinFra.VALIDATE("VAT Prod. Posting Group", rLin."VAT Prod. Posting Group");
                    END;
                    //$036(F)
                    rLinFra.VALIDATE(Description, rLin.Description);
                    rLinFra.VALIDATE("Description 2", rLin."Description 2");
                    //$031(I)
                    if (rLin.Type = rLin.Type::Resource) THEN
                        rLinFra.VALIDATE("Cód. proveedor", rLin."Cód. proveedor");
                    //$031(F)
                    //+001
                    //  rLinFra.VALIDATE("Shortcut Dimension 1 Code", rLin."Shortcut Dimension 1 Code");
                    //  rLinFra.VALIDATE("Shortcut Dimension 2 Code", rLin."Shortcut Dimension 2 Code");
                    //-001
                    rLinFra.VALIDATE("Job No.", rLin."Job No.");
                    /*  {
                     rLinFra.VALIDATE(RowID1, rLin.RowID1);
                     rLinFra.VALIDATE(GetItemCrossRef, rLin.GetItemCrossRef);
                     rLinFra.VALIDATE(GetResource, rLin.GetResource);
                     } */
                    rLinFra.VALIDATE("Job Task No.", rLin."Job Task No.");
                    if rTnos."Nº de plazos" = 0 Then rTnos."Nº de plazos" := rTnos."Nº de Facturas";
                    //      //{ *** ¿me faltan los descuentos? ***}
                    CLEAR(yafact);
                    if rLin.Reparto = rLin.Reparto::Proporcional THEN BEGIN          //FCL-16/02/06
                        yafact := rLin.Quantity * rPlazos."% del total" / 100;
                        yadura := rlin.Duracion * rPlazos."% del total" / 100;
                        If rPlazos."% del total" = 0 Then yadura := Round(rLin.Duracion / rTnos."Nº de Facturas", 0.001, '=');
                        if rPlazos."% del total" = 0 Then yafact := Round(rLin.Quantity / rTnos."Nº de Facturas", 0.001, '=');
                        rLin."Cdad. Facturada MLL" := rLin."Cdad. Facturada MLL" + yafact;
                        if (i = rTnos."Nº de plazos") THEN BEGIN //{Es la ultima factura, asegurarse de que se factura todo}
                            if (rLin."Cdad. Facturada MLL" <> rLin.Quantity) THEN BEGIN
                                rLin."Cdad. Facturada MLL" := rLin."Cdad. Facturada MLL" - yafact;
                                yafact := rLin.Quantity - rLin."Cdad. Facturada MLL";
                                rLin."Cdad. Facturada MLL" := rLin."Cdad. Facturada MLL" + yafact;
                            END;
                            if (rLin."Duración Facturada MLL" <> rLin.Duracion) THEN BEGIN
                                rLin."Duración Facturada MLL" := rLin."Duración Facturada MLL" - yadura;
                                yadura := rLin.Duracion - rLin."Duración Facturada MLL";
                                rLin."Duración Facturada MLL" := rLin."Duración Facturada MLL" + yadura;
                            END;
                        END;
                    END                                                              //FCL-16/02/06
                    ELSE BEGIN
                        // i:=1-1;                                        //FCL-16/02/06
                        yafact := rLin.Quantity;
                        yadura := rlin.Duracion;                                  //FCL-16/02/06
                    END;                                                             //FCL-16/02/06
                    if (yafact <> 0) THEN
                        rLinFra.VALIDATE(Quantity, yafact);
                    if (yadura <> 0) Then rLinFra.Duracion := yadura;
                    if (yadura <> 0) Then rLinFra."Cdad. Soportes" := rLin."Cdad. Soportes";
                    if (NOT pPositivo) AND (rLinFra.Quantity <> 0) THEN begin          //$017
                        rLinFra.VALIDATE(Quantity, -rLinFra.Quantity);
                        rLinFra.Duracion := -rLinFra.Duracion;
                    end;
                    //$017
                    if (rLin."Unit Price" <> 0) THEN
                        rLinFra.VALIDATE("Unit Price", rLin."Unit Price");
                    //  FCL-09/03/04. Migración 2.0. a 3.70. El siguiente campo ya no existe.
                    //  rLinFra.VALIDATE(("% Dto. cantidad",rLin."% Dto. cantidad");
                    if (rLin."Line Discount %" <> 0) THEN
                        rLinFra.VALIDATE("Line Discount %", rLin."Line Discount %");
                    //  FCL-09/03/04. Migración 2.0. a 3.70. El siguiente ya no existe.
                    //  rLinFra.VALIDATE("% Dto. cliente/producto", rLin."% Dto. cliente/producto");

                    //+001
                    ShorCutDim[1] := rLin."Shortcut Dimension 1 Code";
                    ShorCutDim[2] := rLin."Shortcut Dimension 2 Code";
                    ShorCutDim[3] := rLin."Shortcut Dimension 3 Code";
                    ShorCutDim[4] := rLin."Shortcut Dimension 4 Code";
                    ShorCutDim[5] := rLin."Shortcut Dimension 5 Code";
                    rLin.ShowShortcutDimCode(ShorCutDim);
                    if ShorCutDim[1] = '' THEN ShorCutDim[1] := rLin."Shortcut Dimension 1 Code";
                    if ShorCutDim[1] = '' THEN ShorCutDim[2] := rLin."Shortcut Dimension 2 Code";
                    if ShorCutDim[1] = '' THEN ShorCutDim[3] := rLin."Shortcut Dimension 3 Code";
                    if ShorCutDim[1] = '' THEN ShorCutDim[4] := rLin."Shortcut Dimension 4 Code";
                    if ShorCutDim[1] = '' THEN ShorCutDim[5] := rLin."Shortcut Dimension 5 Code";

                    rLinFra.VALIDATE("Shortcut Dimension 1 Code", ShorCutDim[1]);
                    rLinFra.VALIDATE("Shortcut Dimension 2 Code", ShorCutDim[2]);
                    rLinFra.VALIDATE("Shortcut Dimension 3 Code", ShorCutDim[3]);
                    rLinFra.VALIDATE("Shortcut Dimension 4 Code", ShorCutDim[4]);
                    rLinFra.VALIDATE("Shortcut Dimension 5 Code", ShorCutDim[5]);

                    CLEAR(DimMng);
                    //Revisar
                    /* FromDocDim.SETRANGE(FromDocDim."Table ID", 37);
                    FromDocDim.SETRANGE(FromDocDim."Document Type", rLin."Document Type");
                    FromDocDim.SETRANGE(FromDocDim."Document No.", rLin."Document No.");
                    FromDocDim.SETRANGE(FromDocDim."Line No.", rLin."Line No.");
                    if FromDocDim.FINDFIRST THEN
                        REPEAT
                          
                            if ToDocDim.INSERT THEN;
                        UNTIL FromDocDim.NEXT = 0; */
                    //-001
                    rLinFra.VALIDATE("No linea proyecto", rLin."No linea proyecto");          //$018
                    rLinFra."Fecha inicial recurso" := rLin."Fecha inicial recurso";  //$021
                    rLinFra."Fecha final recurso" := rLin."Fecha final recurso";      //$021
                    rLinFra.VALIDATE("Imprimir fecha recurso", rLin."Imprimir fecha recurso");//$024
                    if (rLinFra."Line Amount" <> 0) and not rLin.Imprimir then
                        Error('No se puede marcar no imprimirmibles con importe');
                    rLinFra.Imprimir := rLin.Imprimir;                                        //$024
                    rLinFra.VALIDATE(Remarcar, rLin.Remarcar);                                //$039
                    rlinFra."Precio Compra" := rlin."Precio Compra";         //$040
                    rLinFra."Dto. Compra" := rLin."Dto. Compra";
                    rLinFra.MODIFY;
                    rLin.MODIFY;

                //$008. Bloqueo esta parte, será un total
                //if (rLin."Prepmt. Amt. Inv." <> 0) THEN BEGIN
                //  Linea_Prepago(rLinFra.Quantity, rLin."Prepmt. Amt. Inv.");
                //END;

                UNTIL rLin.NEXT = 0;

            //$008(I)
            if wImpPrepago <> 0 THEN BEGIN
                //$025(I)
                //rCab.CALCFIELDS("Importe líneas");
                //rCabFra.CALCFIELDS("Importe líneas");
                wTotLinCont := TotalLineasRep(rCab."Document Type".AsInteger(), rCab."No.");
                wTotLinFac := TotalLineasRep(rCabFra."Document Type".AsInteger(), rCabFra."No.");
                wTotLinContCost := TotalLineasRepCost(rCab."Document Type".AsInteger(), rCab."No.");
                wTotLinFacCost := TotalLineasRepCost(rCabFra."Document Type".AsInteger(), rCabFra."No.");

                //wImpPrepago2 := ROUND((wImpPrepago * rCabFra."Importe líneas") / rCab."Importe líneas");
                wImpPrepago2 := ROUND((wImpPrepago * wTotLinFac) / wTotLinCont);

                //$025(F)
                wTotPrepago := wTotPrepago + wImpPrepago2;
                if i = wBucle THEN BEGIN                                       //Sumo la diferencia a la última línea
                    if wTotPrepago <> wImpPrepago THEN
                        wImpPrepago2 := wImpPrepago2 + (wImpPrepago - wTotPrepago);
                END;
                if wTotLinFac <> 0 then wImpPrepagoCoste := ROUND(wImpPrepago * (wTotLinFacCost / wTotLinFac));
                Linea_Prepago(1, wImpPrepago2, wImpPrepagoCoste);
            END;
            //$008(F)

            //$034(I)
            if NOT w1Fac THEN BEGIN
                //$034(F)
                if rPlazos."Distancia entre plazos" = '' Then rPlazos."Distancia entre plazos" := StrSubstNo('%1', rTnos."Cálculo de Plazos");
                rPlazos.TESTFIELD("Distancia entre plazos");
                fechaR := CALCDATE(rPlazos."Distancia entre plazos", fechaR);
                fechaRDes := CALCDATE(rPlazos."Distancia entre plazos", fechaRDes);         //$005
                                                                                            //FCL-18/06/04 (I)
                                                                                            /////if (rTnos."Nº de plazos" = 13) AND (i = 1) THEN BEGIN                  //$023
                                                                                            /////  rCabFra.VALIDATE("Posting Description",FORMAT(rPlazos."% del total")+Text001);  //$023
                                                                                            /////END ELSE BEGIN                                                                    //$023
                                                                                            //FCL-18/06/04 (F)
                                                                                            //{Para acabar de completar el periodo de factura.}
                                                                                            //$005
                                                                                            //rCabFra.VALIDATE("Posting Description", rCabFra."Posting Description" + STRSUBSTNO('%1', fechaR-1));
                rCabFra.VALIDATE("Posting Description", rCabFra."Posting Description" + STRSUBSTNO('%1', fechaRDes - 1));
                /////END;                   $023                                               //FCL-18/06/04
                //$020(I)
                if wDiasFactEsp <> 0 THEN BEGIN
                    wDiasSumar := ROUND(wDiasCont * ((fechaR - 1) - rCabFra."Posting Date") / wDiasFactEsp, 1);
                    if i = 1 THEN
                        wFechaD := rCab."Fecha inicial proyecto";
                    if i <> wBucle THEN BEGIN
                        wTxtFec := '+' + FORMAT(wDiasSumar, 0, '<integer>') + 'D';
                        wFechaH := CALCDATE(wTxtFec, wFechaD);
                    END
                    ELSE BEGIN
                        wFechaH := rCab."Fecha fin proyecto";
                    END;
                    //rCabFra.VALIDATE("Posting Description",'Periodo facturación: ' +
                    //                STRSUBSTNO('%1',wFechaD) + ' - ' + STRSUBSTNO('%1', wFechaH));
                    rCabFra.VALIDATE("Posting Description", STRSUBSTNO('%1', wFechaD) + ' - ' + STRSUBSTNO('%1', wFechaH));        //$027

                    wFechaD := wFechaH + 1;
                END
                ELSE BEGIN
                    if rTnos."Nº de plazos" = 1 THEN
                        //rCabFra.VALIDATE("Posting Description",'Periodo facturación: ' +
                        //              STRSUBSTNO('%1',rCab."Fecha inicial proyecto") + ' - ' + STRSUBSTNO('%1',rCab."Fecha fin proyecto"));
                        rCabFra.VALIDATE("Posting Description",                                                                                 //$027
                          STRSUBSTNO('%1', rCab."Fecha inicial proyecto") + ' - ' + STRSUBSTNO('%1', rCab."Fecha fin proyecto"));

                END;
                //$020(F)
                rCabFra."Fecha final factura" := fechaR - 1;                              //FCL-17/06/04
                                                                                          //$034(I)
            END
            ELSE BEGIN
                rCabFra."Fecha final factura" := rCabFra."Fecha inicial factura";
            END;
            //$034(F)
            rCabFra."Customer Order No." := rCab."Customer Order No.";
            rCabFra."Vendedor Origen" := rCab."Vendedor Origen";
            rCabFra."Salesperson Code" := rCab."Salesperson Code";
            rCabFra.MODIFY;
            if (NOT w1Fac) and (rPlazos."% del total" <> 0) THEN rPlazos.NEXT;
            if (i <= 1) AND (w1Fac) THEN BEGIN                                     //FCL-16/02/06
                                                                                   ////i:= i - 1;                                                      //FCL-16/02/06          //$025
                w1Fac := FALSE;                                                       //FCL-16/02/06
            END;                                                                  //FCL-16/02/06
            If i = wBucle Then begin
                rPropVto.SETRANGE(rPropVto."No. linea");               //números de línea están grabados de 1 en 1
                If not rPropVto.FindLast() then
                    Message('No se ha encontrado la última línea de la propuesta de vencimientos')
                else
                    CalcularUtimaFactura(rCabFra, rPropVto, false);
            end;
            //$012
            if rCabFra."Remesa sin factura" THEN               //$035, sustituyo rCab por rCabFra
                cGesCartera.CrearDocCartera(rCabFra, i, wBucle);
            rJobSetup.Get();
            if rJobSetup."Crear Factura Interempresas" Then
                if rJob.Get(rCab."Nº Proyecto") then
                    GestionProyecto.CreaFacturaVenta(rJob, rCabFra, rCabFra."Posting Description");
        END;
        rCab."Creada su facturación" := TRUE;
        rCab."Facturacion Iniciada" := TRUE;
        rCab."Tipo Facturacion" := rCab."Tipo Facturacion"::"Por términos";
        rCab.Modify();
        Commit();
        rCab.Get(rCab."Document Type", rCab."No.");
        //$028(I)
        if rCab.Status = rCab.Status::Open THEN
            ReleaseSalesDoc.PerformManualRelease(rCab);
        //$028(F)
        rCab.MODIFY;
        finestra.CLOSE;
        if NOT rCab."Remesa sin factura" THEN BEGIN                        //$012
            MESSAGE('Facturacion finalizada.\' +
                    'Se han creado %1 borradores de facturas.', wBucle);
            //$012(I)
        END
        ELSE BEGIN

            if cGesCartera.RegistrarDocCartera THEN BEGIN
                MESSAGE('Facturacion finalizada.\' +
                      'Se han creado %1 borradores de facturas y %2 efectos a cobrar.', wBucle, wBucle);
            END
            ELSE BEGIN
                MESSAGE('Facturacion finalizada.\' +
                      'Se han creado %1 borradores de facturas. Revise el diario de cartera, no se han registrado los efectos a cobrar.', wBucle);
            END;
        END;

        //$012(F)
    END;

    PROCEDURE Crear_Facturas_Terminos_Prepago(VAR rCab: Record 36; pPositivo: Boolean);
    VAR
        rPropVto: Record "Facturas Propuestas";
        i: Integer;
        yafact: Decimal;
        wFecVto: Date;
        SerieCode: Code[20];
        wImpPrepagoCoste: Decimal;
        Plazo: Decimal;
        Fra: Record 36;
        Desde: Date;
        Hasta: Date;
        Prepago: Decimal;
        Distancia: Integer;
        Año: Integer;
        Meses: Integer;
        Paymet: Record "Payment Method";
    BEGIN
        //$017 Incluyo parámetro pPositivo.
        if (rCab."Creada facturación prepago") THEN
            ERROR(Text006);
        // Filtra las Fra de este contrato que no sean prepayments
        Fra.SETRANGE("Document Type", rCab."Document Type"::Invoice);
        Fra.SETRANGE(Fra."Nº Contrato", rCab."No.");
        Fra.SETRANGE(Fra."Factura prepago", FALSE);
        if Fra.FindFirst() THEN
            ERROR(Text006);

        rCab.TESTFIELD("Cód. términos prepago");
        fechaR := rCab."Posting Date";
        fechaRDes := rCab."Fecha inicial proyecto";
        Desde := fechaRDes;                 //$005
        wFecha := fechaR;
        rTnos.GET(rCab."Cód. términos prepago");
        rTnos.CALCFIELDS("Nº de plazos");
        wTotPrepago := 0;                                                   //FCL-19/04/10
        Prepago := rCab."Prepayment %";
        ComprobarReparto(rCab, rTnos);

        if NOT CONFIRM('Se van a generar ' + STRSUBSTNO('%1', wBucle) + ' facturas de este contrato.\' +
                       'El proyecto esta entre ' + STRSUBSTNO('%1', rCab."Fecha inicial proyecto") + ' y ' +
                       STRSUBSTNO('%1', rCab."Fecha fin proyecto") + ' \' +
                       ' y el termino de facturacion elegido es ' + rCab."Cód. términos prepago") THEN
            EXIT;

        ////{ *** Pido Nº Serie registro *** }
        //$017


        finestra.OPEN('Creando #3# de un total de #2# -------> Nº #1########');
        finestra.UPDATE(2, wBucle);

        // $030 Limpio campo temporal

        if rTnos."Nº de plazos" = 0 then rTnos."Nº de plazos" := rTnos."Nº de Facturas";
        //$034(I) Generaré nº de bucles + 1¦ fra.
        if w1Fac THEN BEGIN
            wBucle := wBucle + 1;

            rTnos."Nº de plazos" := rTnos."Nº de plazos" + 1;
        END;
        //$034(F)
        rCab.TestField(Status, rCab.Status::Released);
        FOR i := 1 TO wBucle DO BEGIN
            finestra.UPDATE(3, i);
            if rTnos."Nº de Facturas" = 0 then
                rPlazos.TESTFIELD("% del total");
            rCab.Status := rCab.Status::Open;
            Plazo := rPlazos."% del total";
            if Prepago <> 0 then
                rPlazos."% del total" := rPlazos."% del total" * ((100 - Prepago) / 100);
            if rCab."Prepayment %" + rPlazos."% del total" > 100 then
                rCab.Validate("Prepayment %", 100)
            else
                rCab.Validate("Prepayment %", rCab."Prepayment %" + rPlazos."% del total");

            rCab.Modify();

            //Distancia
            wMesesCont := rCab."Fecha fin proyecto" - rCab."Fecha inicial proyecto";
            Distancia := Round(wMesesCont * Plazo / 100, 1, '=');

            Hasta := Calcdate(Format(Distancia) + 'D', Desde);// CalcDate(rPlazos."Distancia entre plazos", Desde);
            GenerarBorradorPrepago(rCab, 0, false, rPlazos."% del total", Desde, Hasta, fechar, i, true);
            fechaR := CALCDATE(rPlazos."Distancia entre plazos", fechaR);
            if Distancia < 0 Then Distancia := 0; //FCL-19/04/10';
            Desde := hasta;/////if (rTnos."Nº de plazos" = 13) AND (i = 2) THEN                   //FCL-18/06/04   //$023
                           /////  fechaR:=wFecha;                                                 //FCL-18/06/04   //$023


            if (NOT w1Fac) and (rPlazos."% del total" <> 0) THEN rPlazos.NEXT;
            if (i <= 1) AND (w1Fac) THEN BEGIN                                     //FCL-16/02/06
                                                                                   ////i:= i - 1;                                                      //FCL-16/02/06          //$025
                w1Fac := FALSE;                                                       //FCL-16/02/06
            END;
            //     rJobSetup.Get();
            //     if rJobSetup."Crear Factura Interempresas" Then
            //         if rJob.Get(rCab."Nº Proyecto") then
            //             GestionProyecto.CreaFacturaVenta(rJob, rCabFra);
        END;
        rCab.geT(rCab."Document Type", rCab."No.");
        rCab."Creada facturación prepago" := TRUE;
        rCab."Tipo Facturacion" := rCab."Tipo Facturacion"::"Por términos";
        rCab."Prepayment %" := 100;
        //$028(I)
        if rCab.Status = rCab.Status::Open THEN
            ReleaseSalesDoc.PerformManualRelease(rCab);
        //$028(F)
        rCab.MODIFY;
        finestra.CLOSE;
        Paymet.GET(rCab."Payment Method Code");

        if NOT Paymet."Remesa sin factura" THEN BEGIN                        //$012
            MESSAGE('Facturacion finalizada.\' +
                    'Se han creado %1 borradores de facturas.', wBucle);
            //$012(I)
        END
        ELSE BEGIN
            if cGesCartera.RegistrarDocCartera THEN BEGIN
                MESSAGE('Facturacion finalizada.\' +
                      'Se han creado %1 borradores de facturas y %2 efectos a cobrar.', wBucle, wBucle);
            END
            ELSE BEGIN
                MESSAGE('Facturacion finalizada.\' +
                      'Se han creado %1 borradores de facturas. Revise el diario de cartera, no se han registrado los efectos a cobrar.', wBucle);
            END;
        END;
        //$012(I)

    END;
    //$012(F)
    //END;
    PROCEDURE Crear_Facturas_Fechas(VAR rCab: Record 36; pPositivo: Boolean);
    VAR
        wCantOrd: Decimal;
        wPreOrd: Decimal;
        wMsg: Boolean;
        SerieCode: Code[20];
        wImpPrepagoCoste: Decimal;
    BEGIN
        //$017 Incluyo parámetro pPositivo.

        CLEAR(fechaI);
        CLEAR(fechaF);
        CLEAR(fDatos);
        if fDatos.RUNMODAL in [Action::Cancel, Action::LookupCancel, Action::No, Action::None] Then error('Proceso Cancelado');
        //$006 (I)
        //fDatos.Recoge_Fechas(fechaI,fechaF);
        //if NOT CONFIRM(Text005, TRUE, fechaI, fechaF, WORKDATE) THEN
        fDatos.Recoge_Fechas(fechaI, fechaF, fechaReg);
        if NOT CONFIRM(Text005, TRUE, fechaI, fechaF, fechaReg) THEN
            //$006 (F)
            EXIT;
        wImpPrepago := 0;                                                  //$008
        wMsg := FALSE;                                                     //$010
        CLEAR(rLin);
        rLin.RESET;
        rLin.SETCURRENTKEY("Document Type", "Document No.", "Line No.");
        rLin.SETRANGE("Document Type", rCab."Document Type");
        rLin.SETRANGE("Document No.", rCab."No.");
        rLin.SETFILTER("No.", '<>%1', '');
        rLin.SETFILTER(rLin.Reparto, '<>%1', rLin.Reparto::"Fra prepago");   //$025
                                                                             //$007 (I)
                                                                             //rLin.SETFILTER("No. Orden Publicidad", '%1', '');
                                                                             //if rLin.FINDSET THEN
                                                                             //  MESSAGE(Text007);
                                                                             //rLin.SETRANGE("No. Orden Publicidad");
                                                                             //$007 (F)
        if rLin.FINDSET THEN
            REPEAT
                wImpPrepago := wImpPrepago + rLin."Prepmt. Amt. Inv.";          //$008
                wCantOrd := 0;                                                   //$010
                wPreOrd := 0;                                                    //$010
                if rLin."No. Orden Publicidad" <> '' THEN BEGIN                //$007
                    CLEAR(rOrden);
                    rOrden.GET(rLin."No. Orden Publicidad");
                    CLEAR(rLinOrden);
                    rLinOrden.RESET;
                    rLinOrden.SETCURRENTKEY("Tipo orden", "No. orden", "Fecha inicio");
                    rLinOrden.SETRANGE("No. orden", rOrden.No);
                    rLinOrden.SETRANGE("Fecha inicio", fechaI, fechaF);
                    rLinOrden.SETFILTER(Precio, '<>%1', 0);
                    //$010(I)
                    if rLinOrden.FINDFIRST THEN BEGIN
                        REPEAT
                            if rLinOrden.Facturada = TRUE THEN
                                ERROR('La Orden de publicidad %1 ya ha sido facturada en estas fechas', rLinOrden."No. orden");
                            rLinOrden.Facturada := TRUE;
                            rLinOrden.MODIFY;
                            wCantOrd := wCantOrd + rLinOrden.Inserciones;
                            if (wPreOrd <> rLinOrden.Precio) AND (wPreOrd <> 0) THEN
                                wMsg := TRUE;
                            //$033(I) y $041
                            if rLinOrden."Tipo orden" = rLinOrden."Tipo orden"::Radio THEN BEGIN
                                wPreOrd := rLinOrden.Precio;
                            END
                            ELSE BEGIN
                                wPreOrd := rLinOrden.Importe;
                            END;
                        //$033(F)
                        UNTIL rLinOrden.NEXT = 0;
                    END;
                    //$010(F)
                    rLin."Linea Marcada a Borrador" := TRUE;
                    //$010(I)
                    ///rLin."Cantidad a Borrador" := rLinOrden.COUNT;
                    rLin."Cantidad a Borrador" := wCantOrd;
                    rLin."Precio a Borrador" := wPreOrd;
                    //$010(F)
                    rLin.MODIFY;
                    //$007 (I)
                END
                ELSE BEGIN
                    DiasProyecto;
                    if wDias <> 0 THEN BEGIN
                        rLin."Linea Marcada a Borrador" := TRUE;
                        rLin."Cantidad a Borrador" := 1;
                        rLin."Precio a Borrador" := ROUND(wDias * rLin."Unit Price") /
                                         ((rLin."Fecha final recurso" - rLin."Fecha inicial recurso") + 1);
                        rLin."Cantidad pasada Borrador" := rLin."Cantidad pasada Borrador" + wDias - 1;
                        if rLin."Cantidad pasada Borrador" > (rLin."Fecha final recurso" - rLin."Fecha inicial recurso") + 1 THEN
                            ERROR('Ya se han facturado todos los días para la linea %1', rLin."Line No.");
                        rLin.MODIFY;
                    END;
                END;
            //$007 (F)
            UNTIL rLin.NEXT = 0;

        if wMsg THEN                        //$010
            MESSAGE(Text016);                 //$010

        COMMIT;

        //$017
        if pPositivo THEN BEGIN
            SerieCode := LookupSeries(ConfVtas."Posted Invoice Nos.", rSerie.Code);
        END ELSE BEGIN
            SerieCode := LookupSeries(ConfVtas."Posted Credit Memo Nos.", rSerie.Code);
        END;

        finestra.OPEN('Creando Factura Nº #1########');

        // //{ *** Cabecera de factura *** }
        //CabeceraComun(WORKDATE, rCab);               //$006
        CabeceraComun(fechaReg, rCab, pPositivo, SerieCode);                 //$006

        ////{ *** Lineas de factura *** }
        rLin.SETCURRENTKEY("Document Type", "Document No.", "Line No.");
        rLin.SETRANGE("Document Type", rCab."Document Type");
        rLin.SETRANGE("Document No.", rCab."No.");
        rLin.SETRANGE("Linea Marcada a Borrador", TRUE);
        rLin.SETFILTER("Cantidad a Borrador", '<>%1', 0);
        if rLin.FINDSET THEN
            REPEAT
                // $003
                if (rLin.Type.AsInteger() <> 0) THEN BEGIN
                    rLin.TESTFIELD("Shortcut Dimension 1 Code");
                    rLin.TESTFIELD("Shortcut Dimension 2 Code");
                END;
                CLEAR(rLinFra);
                rLinFra.INIT;
                rLinFra."Document Type" := rCabFra."Document Type";
                rLinFra."Document No." := rCabFra."No.";
                rLinFra."Line No." := rLin."Line No.";
                rLinFra."Customer Order No." := rLin."Customer Order No.";
                rLinFra.INSERT;
                rLinFra.VALIDATE("Sell-to Customer No.", rCabFra."Sell-to Customer No.");
                rLinFra.VALIDATE(Type, rLin.Type);
                rLinFra.VALIDATE("No.", rLin."No.");
                //$036(I)
                if rLin.Type.AsInteger() <> 0 THEN BEGIN
                    rLinFra.VALIDATE("VAT Bus. Posting Group", rLin."VAT Bus. Posting Group");
                    rLinFra.VALIDATE("VAT Prod. Posting Group", rLin."VAT Prod. Posting Group");
                END;
                //$036(F)
                rLinFra.VALIDATE(Description, rLin.Description);
                rLinFra.VALIDATE("Description 2", rLin."Description 2");
                rLinFra.VALIDATE("Job No.", rLin."Job No.");
                rLinFra.VALIDATE("Job Task No.", rLin."Job Task No.");
                //$031(I)
                if (rLin.Type = rLin.Type::Resource) THEN
                    rLinFra.VALIDATE("Cód. proveedor", rLin."Cód. proveedor");
                //$031(F)

                rLinFra.VALIDATE(Quantity, rLin."Cantidad a Borrador");
                rLinFra.Duracion := rLin.Duracion;
                rLinFra."Cdad. Soportes" := rLin."Cdad. Soportes";
                if (NOT pPositivo) AND (rLinFra.Quantity <> 0) THEN begin             //$017
                    rLinFra.VALIDATE(Quantity, -rLinFra.Quantity);
                    rLinFra.Duracion := -rLinFra.Duracion;
                end;          //$017
                rLin."Cantidad pasada Borrador" += rLin."Cantidad a Borrador";

                if (rLin."Unit Price" <> 0) THEN
                    //rLinFra.VALIDATE("Unit Price", rLin."Unit Price");        //FCL-25/03/10
                    rLinFra.VALIDATE("Unit Price", rLin."Precio a Borrador");   //FCL-25/03/10
                if (rLin."Line Discount %" <> 0) THEN
                    rLinFra.VALIDATE("Line Discount %", rLin."Line Discount %");

                //+001
                ShorCutDim[1] := rLin."Shortcut Dimension 1 Code";
                ShorCutDim[2] := rLin."Shortcut Dimension 2 Code";
                ShorCutDim[3] := rLin."Shortcut Dimension 3 Code";
                ShorCutDim[4] := rLin."Shortcut Dimension 4 Code";
                ShorCutDim[5] := rLin."Shortcut Dimension 5 Code";
                rLin.ShowShortcutDimCode(ShorCutDim);
                if ShorCutDim[1] = '' THEN ShorCutDim[1] := rLin."Shortcut Dimension 1 Code";
                if ShorCutDim[1] = '' THEN ShorCutDim[2] := rLin."Shortcut Dimension 2 Code";
                if ShorCutDim[1] = '' THEN ShorCutDim[3] := rLin."Shortcut Dimension 3 Code";
                if ShorCutDim[1] = '' THEN ShorCutDim[4] := rLin."Shortcut Dimension 4 Code";
                if ShorCutDim[1] = '' THEN ShorCutDim[5] := rLin."Shortcut Dimension 5 Code";

                rLinFra.VALIDATE("Shortcut Dimension 1 Code", ShorCutDim[1]);
                rLinFra.VALIDATE("Shortcut Dimension 2 Code", ShorCutDim[2]);
                rLinFra.VALIDATE("Shortcut Dimension 3 Code", ShorCutDim[3]);
                rLinFra.VALIDATE("Shortcut Dimension 4 Code", ShorCutDim[4]);
                rLinFra.VALIDATE("Shortcut Dimension 5 Code", ShorCutDim[5]);

                //-001
                rLinFra.VALIDATE("No linea proyecto", rLin."No linea proyecto");          //$018
                rLinFra."Fecha inicial recurso" := rLin."Fecha inicial recurso";  //$021
                rLinFra."Fecha final recurso" := rLin."Fecha final recurso";      //$021
                rLinFra.VALIDATE("Imprimir fecha recurso", rLin."Imprimir fecha recurso");//$024
                if (rLinFra."Line Amount" <> 0) and not rLin.Imprimir then
                    Error('No se puede marcar no imprimirmibles con importe');
                rLinFra.Imprimir := rLin.Imprimir;                                        //$024
                rLinFra.VALIDATE(Remarcar, rLin.Remarcar);                                //$039
                rlinFra."Precio Compra" := rlin."Precio Compra";         //$040
                rLinFra."Dto. Compra" := rLin."Dto. Compra";

                rLinFra.MODIFY;
                rLin.MODIFY;

                //$008. Bloqueo esta parte, será un total
                //if (rLin."Prepmt. Amt. Inv." <> 0) THEN BEGIN
                //  Linea_Prepago(rLinFra.Quantity, rLin."Prepmt. Amt. Inv.");
                //END;

                //$009. Creo las líneas correspondientes a comentarios orden de publicidad
                if rLin."No. Orden Publicidad" <> '' THEN BEGIN
                    wLinea := rLinFra."Line No.";
                    LineasOrden;
                END;

                //$011
                wLinea := rLinFra."Line No.";
                TextoAmpliado;

            UNTIL rLin.NEXT = 0;

        //$008(I)
        if wImpPrepago <> 0 THEN BEGIN
            //$025(I)
            //rCab.CALCFIELDS("Importe líneas");
            //rCabFra.CALCFIELDS("Importe líneas");
            wTotLinCont := TotalLineasRep(rCab."Document Type".AsInteger(), rCab."No.");
            wTotLinFac := TotalLineasRep(rCabFra."Document Type".AsInteger(), rCabFra."No.");
            //wImpPrepago := ROUND((wImpPrepago * rCabFra."Importe líneas") / rCab."Importe líneas");
            wImpPrepago := ROUND((wImpPrepago * wTotLinFac) / wTotLinCont);
            wTotLinContCost := TotalLineasRepCost(rCab."Document Type".AsInteger(), rCab."No.");
            wTotLinFacCost := TotalLineasRepCost(rCabFra."Document Type".AsInteger(), rCabFra."No.");
            //$025(F)
            if wTotLinFac <> 0 then wImpPrepagoCoste := ROUND(wImpPrepago * (wTotLinFacCost / wTotLinFac));
            Linea_Prepago(1, wImpPrepago, wImpPrepagoCoste);
        END;
        //$008(F)

        rLin.MODIFYALL("Cantidad a Borrador", 0);
        rLin.MODIFYALL("Precio a Borrador", 0);               //$010
        rLin.MODIFYALL("Linea Marcada a Borrador", FALSE);

        rCabFra.VALIDATE("Posting Description", STRSUBSTNO(Text010, fechaI, fechaF));
        rCabFra."Fecha final factura" := WORKDATE;
        rCabFra."Vendedor Origen" := rCab."Vendedor Origen";
        rCabFra."Salesperson Code" := rCab."Salesperson Code";
        rCabFra.MODIFY;

        //$012
        if rCab."Remesa sin factura" THEN
            cGesCartera.CrearDocCartera(rCabFra, 0, 0);
        rJobSetup.Get();
        if rJobSetup."Crear Factura Interempresas" Then
            if rJob.Get(rCab."Nº Proyecto") then
                GestionProyecto.CreaFacturaVenta(rJob, rCabFra, rCabFra."Posting Description");
        rCab."Creada su facturación" := TRUE;

        rCab."Facturacion Iniciada" := TRUE;
        rCab."Tipo Facturacion" := rCab."Tipo Facturacion"::Enviada;
        //$028(I)
        if rCab.Status = rCab.Status::Open THEN
            ReleaseSalesDoc.PerformManualRelease(rCab);
        //$028(F)
        rCab.MODIFY;

        finestra.CLOSE;

        if NOT rCab."Remesa sin factura" THEN BEGIN                    //$012
            MESSAGE(Text009, rCab."Tipo Facturacion", rCabFra."No.");
            //$012(I)
        END
        ELSE BEGIN
            if cGesCartera.RegistrarDocCartera THEN BEGIN
                MESSAGE(Text017, rCab."Tipo Facturacion", rCabFra."No.");
            END
            ELSE BEGIN
                MESSAGE(Text018, rCab."Tipo Facturacion", rCabFra."No.");
            END;
        END;
    END;

    PROCEDURE Crear_Facturas_Fechas_prepago(VAR rCab: Record 36; pPositivo: Boolean);
    VAR
        wCantOrd: Decimal;
        wPreOrd: Decimal;
        wMsg: Boolean;
        SerieCode: Code[20];
        wImpPrepagoCoste: Decimal;
    BEGIN
        //$017 Incluyo parámetro pPositivo.

        CLEAR(fechaI);
        CLEAR(fechaF);
        CLEAR(fDatos);
        if fDatos.RUNMODAL in [Action::Cancel, Action::LookupCancel, Action::No, Action::None] Then error('Proceso Cancelado');
        //$006 (I)
        //fDatos.Recoge_Fechas(fechaI,fechaF);
        //if NOT CONFIRM(Text005, TRUE, fechaI, fechaF, WORKDATE) THEN
        fDatos.Recoge_Fechas(fechaI, fechaF, fechaReg);
        if NOT CONFIRM(Text005, TRUE, fechaI, fechaF, fechaReg) THEN
            //$006 (F)
            EXIT;
        wImpPrepago := 0;                                                  //$008
        wMsg := FALSE;                                                     //$010
        CLEAR(rLin);
        rLin.RESET;
        rLin.SETCURRENTKEY("Document Type", "Document No.", "Line No.");
        rLin.SETRANGE("Document Type", rCab."Document Type");
        rLin.SETRANGE("Document No.", rCab."No.");
        rLin.SETFILTER("No.", '<>%1', '');
        rLin.SETFILTER(rLin.Reparto, '<>%1', rLin.Reparto::"Fra prepago");   //$025
                                                                             //$007 (I)
                                                                             //rLin.SETFILTER("No. Orden Publicidad", '%1', '');
                                                                             //if rLin.FINDSET THEN
                                                                             //  MESSAGE(Text007);
                                                                             //rLin.SETRANGE("No. Orden Publicidad");
                                                                             //$007 (F)
        if rLin.FINDSET THEN
            REPEAT
                wImpPrepago := wImpPrepago + rLin."Prepmt. Amt. Inv.";          //$008
                wCantOrd := 0;                                                   //$010
                wPreOrd := 0;                                                    //$010
                if rLin."No. Orden Publicidad" <> '' THEN BEGIN                //$007
                    CLEAR(rOrden);
                    rOrden.GET(rLin."No. Orden Publicidad");
                    CLEAR(rLinOrden);
                    rLinOrden.RESET;
                    rLinOrden.SETCURRENTKEY("Tipo orden", "No. orden", "Fecha inicio");
                    rLinOrden.SETRANGE("No. orden", rOrden.No);
                    rLinOrden.SETRANGE("Fecha inicio", fechaI, fechaF);
                    rLinOrden.SETFILTER(Precio, '<>%1', 0);
                    //$010(I)
                    if rLinOrden.FINDFIRST THEN BEGIN
                        REPEAT
                            if rLinOrden.Facturada = TRUE THEN
                                ERROR('La Orden de publicidad %1 ya ha sido facturada en estas fechas', rLinOrden."No. orden");
                            rLinOrden.Facturada := TRUE;
                            rLinOrden.MODIFY;
                            wCantOrd := wCantOrd + rLinOrden.Inserciones;
                            if (wPreOrd <> rLinOrden.Precio) AND (wPreOrd <> 0) THEN
                                wMsg := TRUE;
                            //$033(I) y $041
                            if rLinOrden."Tipo orden" = rLinOrden."Tipo orden"::Radio THEN BEGIN
                                wPreOrd := rLinOrden.Precio;
                            END
                            ELSE BEGIN
                                wPreOrd := rLinOrden.Importe;
                            END;
                        //$033(F)
                        UNTIL rLinOrden.NEXT = 0;
                    END;
                    //$010(F)
                    rLin."Linea Marcada a Borrador" := TRUE;
                    //$010(I)
                    ///rLin."Cantidad a Borrador" := rLinOrden.COUNT;
                    rLin."Cantidad a Borrador" := wCantOrd;
                    rLin."Precio a Borrador" := wPreOrd;
                    //$010(F)
                    rLin.MODIFY;
                    //$007 (I)
                END
                ELSE BEGIN
                    DiasProyecto;
                    if wDias <> 0 THEN BEGIN
                        rLin."Linea Marcada a Borrador" := TRUE;
                        rLin."Cantidad a Borrador" := 1;
                        rLin."Precio a Borrador" := ROUND(wDias * rLin."Unit Price") /
                                         ((rLin."Fecha final recurso" - rLin."Fecha inicial recurso") + 1);
                        rLin."Cantidad pasada Borrador" := rLin."Cantidad pasada Borrador" + wDias - 1;
                        if rLin."Cantidad pasada Borrador" > (rLin."Fecha final recurso" - rLin."Fecha inicial recurso") + 1 THEN
                            ERROR('Ya se han facturado todos los días para la linea %1', rLin."Line No.");
                        rLin.MODIFY;
                    END;
                END;
            //$007 (F)
            UNTIL rLin.NEXT = 0;

        if wMsg THEN                        //$010
            MESSAGE(Text016);                 //$010

        COMMIT;

        //$017
        if pPositivo THEN BEGIN
            SerieCode := LookupSeries(ConfVtas."Posted Invoice Nos.", rSerie.Code);
        END ELSE BEGIN
            SerieCode := LookupSeries(ConfVtas."Posted Credit Memo Nos.", rSerie.Code);
        END;

        finestra.OPEN('Creando Factura Nº #1########');

        // //{ *** Cabecera de factura *** }
        //CabeceraComun(WORKDATE, rCab);               //$006
        CabeceraComun(fechaReg, rCab, pPositivo, SerieCode);                 //$006

        ////{ *** Lineas de factura *** }
        rLin.SETCURRENTKEY("Document Type", "Document No.", "Line No.");
        rLin.SETRANGE("Document Type", rCab."Document Type");
        rLin.SETRANGE("Document No.", rCab."No.");
        rLin.SETRANGE("Linea Marcada a Borrador", TRUE);
        rLin.SETFILTER("Cantidad a Borrador", '<>%1', 0);
        if rLin.FINDSET THEN
            REPEAT
                // $003
                if (rLin.Type.AsInteger() <> 0) THEN BEGIN
                    rLin.TESTFIELD("Shortcut Dimension 1 Code");
                    rLin.TESTFIELD("Shortcut Dimension 2 Code");
                END;
                CLEAR(rLinFra);
                rLinFra.INIT;
                rLinFra."Document Type" := rCabFra."Document Type";
                rLinFra."Document No." := rCabFra."No.";
                rLinFra."Line No." := rLin."Line No.";
                rLinFra."Customer Order No." := rLin."Customer Order No.";
                rLinFra.INSERT;
                rLinFra.VALIDATE("Sell-to Customer No.", rCabFra."Sell-to Customer No.");
                rLinFra.VALIDATE(Type, rLin.Type);
                rLinFra.VALIDATE("No.", rLin."No.");
                //$036(I)
                if rLin.Type.AsInteger() <> 0 THEN BEGIN
                    rLinFra.VALIDATE("VAT Bus. Posting Group", rLin."VAT Bus. Posting Group");
                    rLinFra.VALIDATE("VAT Prod. Posting Group", rLin."VAT Prod. Posting Group");
                END;
                //$036(F)
                rLinFra.VALIDATE(Description, rLin.Description);
                rLinFra.VALIDATE("Description 2", rLin."Description 2");
                rLinFra.VALIDATE("Job No.", rLin."Job No.");
                rLinFra.VALIDATE("Job Task No.", rLin."Job Task No.");
                //$031(I)
                if (rLin.Type = rLin.Type::Resource) THEN
                    rLinFra.VALIDATE("Cód. proveedor", rLin."Cód. proveedor");
                //$031(F)

                rLinFra.VALIDATE(Duracion, rLin."Cantidad a Borrador");
                rLinFra."Cdad. Soportes" := rLin."Cdad. Soportes";
                if (NOT pPositivo) AND (rLinFra.Quantity <> 0) THEN begin           //$017
                    rLinFra.VALIDATE(Quantity, -rLinFra.Quantity);
                    rLinFra.Duracion := -rLinFra.Duracion;
                end;         //$017
                rLin."Cantidad pasada Borrador" += rLin."Cantidad a Borrador";

                if (rLin."Unit Price" <> 0) THEN
                    //rLinFra.VALIDATE("Unit Price", rLin."Unit Price");        //FCL-25/03/10
                    rLinFra.VALIDATE("Unit Price", rLin."Precio a Borrador");   //FCL-25/03/10
                if (rLin."Line Discount %" <> 0) THEN
                    rLinFra.VALIDATE("Line Discount %", rLin."Line Discount %");

                //+001
                ShorCutDim[1] := rLin."Shortcut Dimension 1 Code";
                ShorCutDim[2] := rLin."Shortcut Dimension 2 Code";
                ShorCutDim[3] := rLin."Shortcut Dimension 3 Code";
                ShorCutDim[4] := rLin."Shortcut Dimension 4 Code";
                ShorCutDim[5] := rLin."Shortcut Dimension 5 Code";
                rLin.ShowShortcutDimCode(ShorCutDim);
                if ShorCutDim[1] = '' THEN ShorCutDim[1] := rLin."Shortcut Dimension 1 Code";
                if ShorCutDim[1] = '' THEN ShorCutDim[2] := rLin."Shortcut Dimension 2 Code";
                if ShorCutDim[1] = '' THEN ShorCutDim[3] := rLin."Shortcut Dimension 3 Code";
                if ShorCutDim[1] = '' THEN ShorCutDim[4] := rLin."Shortcut Dimension 4 Code";
                if ShorCutDim[1] = '' THEN ShorCutDim[5] := rLin."Shortcut Dimension 5 Code";

                rLinFra.VALIDATE("Shortcut Dimension 1 Code", ShorCutDim[1]);
                rLinFra.VALIDATE("Shortcut Dimension 2 Code", ShorCutDim[2]);
                rLinFra.VALIDATE("Shortcut Dimension 3 Code", ShorCutDim[3]);
                rLinFra.VALIDATE("Shortcut Dimension 4 Code", ShorCutDim[4]);
                rLinFra.VALIDATE("Shortcut Dimension 5 Code", ShorCutDim[5]);

                //-001
                rLinFra.VALIDATE("No linea proyecto", rLin."No linea proyecto");          //$018
                rLinFra."Fecha inicial recurso" := rLin."Fecha inicial recurso";  //$021
                rLinFra."Fecha final recurso" := rLin."Fecha final recurso";      //$021
                rLinFra.VALIDATE("Imprimir fecha recurso", rLin."Imprimir fecha recurso");//$024
                if (rLinFra."Line Amount" <> 0) and not rLin.Imprimir then
                    Error('No se puede marcar no imprimirmibles con importe');
                rLinFra.Imprimir := rLin.Imprimir;                                        //$024
                rLinFra.VALIDATE(Remarcar, rLin.Remarcar);                                //$039
                rlinFra."Precio Compra" := rlin."Precio Compra";         //$040
                rLinFra."Dto. Compra" := rLin."Dto. Compra";

                rLinFra.MODIFY;
                rlin."Prepayment %" := (rlin."Cantidad pasada Borrador" / rlin.Quantity) * 100;
                rlin."Prepmt. Line Amount" := rlin."Prepayment %" * rlin."Line Amount";
                rlin."Prepmt. Amt. Inv." := rlin."Prepmt. Line Amount";
                rlin."Prepmt. Amt. Incl. VAT" := rlin."Prepmt. Line Amount" * (1 + rlin."VAT %" / 100);
                rlin."Prepmt. Amount Inv. Incl. VAT" := rlin."Prepmt. Amt. Incl. VAT";
                rLin."Prepmt Amt to Deduct" :=
               rlin."Prepmt. Amt. Inv." - rlin."Prepmt Amt Deducted";
                rLin.MODIFY;

                //$008. Bloqueo esta parte, será un total
                //if (rLin."Prepmt. Amt. Inv." <> 0) THEN BEGIN
                //  Linea_Prepago(rLinFra.Quantity, rLin."Prepmt. Amt. Inv.");
                //END;

                //$009. Creo las líneas correspondientes a comentarios orden de publicidad
                if rLin."No. Orden Publicidad" <> '' THEN BEGIN
                    wLinea := rLinFra."Line No.";
                    LineasOrden;
                END;

                //$011
                wLinea := rLinFra."Line No.";
                TextoAmpliado;

            UNTIL rLin.NEXT = 0;

        //$008(I)
        if wImpPrepago <> 0 THEN BEGIN
            //$025(I)
            //rCab.CALCFIELDS("Importe líneas");
            //rCabFra.CALCFIELDS("Importe líneas");
            wTotLinCont := TotalLineasRep(rCab."Document Type".AsInteger(), rCab."No.");
            wTotLinFac := TotalLineasRep(rCabFra."Document Type".AsInteger(), rCabFra."No.");
            //wImpPrepago := ROUND((wImpPrepago * rCabFra."Importe líneas") / rCab."Importe líneas");
            wImpPrepago := ROUND((wImpPrepago * wTotLinFac) / wTotLinCont);
            wTotLinContCost := TotalLineasRepCost(rCab."Document Type".AsInteger(), rCab."No.");
            wTotLinFacCost := TotalLineasRepCost(rCabFra."Document Type".AsInteger(), rCabFra."No.");
            //$025(F)
            if wTotLinFac <> 0 then wImpPrepagoCoste := ROUND(wImpPrepago * (wTotLinFacCost / wTotLinFac));
            Linea_Prepago(1, wImpPrepago, wImpPrepagoCoste);
        END;
        //$008(F)

        rLin.MODIFYALL("Cantidad a Borrador", 0);
        rLin.MODIFYALL("Precio a Borrador", 0);               //$010
        rLin.MODIFYALL("Linea Marcada a Borrador", FALSE);

        rCabFra.VALIDATE("Posting Description", STRSUBSTNO(Text010, fechaI, fechaF));
        rCabFra."Fecha final factura" := WORKDATE;
        rCabFra."Vendedor Origen" := rCab."Vendedor Origen";
        rCabFra."Salesperson Code" := rCab."Salesperson Code";
        rCabFra.MODIFY;

        //$012
        if rCab."Remesa sin factura" THEN
            cGesCartera.CrearDocCartera(rCabFra, 0, 0);
        rJobSetup.Get();
        if rJobSetup."Crear Factura Interempresas" Then
            if rJob.Get(rCab."Nº Proyecto") then
                GestionProyecto.CreaFacturaVenta(rJob, rCabFra, rCabFra."Posting Description");
        rCab."Creada su facturación" := TRUE;

        rCab."Facturacion Iniciada" := TRUE;
        rCab."Tipo Facturacion" := rCab."Tipo Facturacion"::Enviada;
        //$028(I)
        if rCab.Status = rCab.Status::Open THEN
            ReleaseSalesDoc.PerformManualRelease(rCab);
        //$028(F)
        rCab.MODIFY;

        finestra.CLOSE;

        if NOT rCab."Remesa sin factura" THEN BEGIN                    //$012
            MESSAGE(Text009, rCab."Tipo Facturacion", rCabFra."No.");
            //$012(I)
        END
        ELSE BEGIN
            if cGesCartera.RegistrarDocCartera THEN BEGIN
                MESSAGE(Text017, rCab."Tipo Facturacion", rCabFra."No.");
            END
            ELSE BEGIN
                MESSAGE(Text018, rCab."Tipo Facturacion", rCabFra."No.");
            END;
        END;
    END;


    PROCEDURE Crear_Facturas_Lineas(VAR rCab: Record 36; pPositivo: Boolean);
    VAR
        //FromDocDim : Record 357;
        //ToDocDim : Record 357;
        SerieCode: Code[20];
        wImpPrepagoCoste: Decimal;
    BEGIN
        //$017 Incluyo parámetro pPositivo.

        wImpPrepago := 0;                                                  //$008

        if NOT CONFIRM(Text013, TRUE) THEN
            EXIT;
        CLEAR(rLin);
        rLin.RESET;
        rLin.SETCURRENTKEY("Document Type", "Document No.", "Line No.");
        rLin.SETRANGE("Document Type", rCab."Document Type");
        rLin.SETRANGE("Document No.", rCab."No.");
        rLin.SETFILTER("No.", '<>%1', '');
        rLin.SETRANGE("Linea Marcada a Borrador", TRUE);
        rLin.SETFILTER(rLin.Reparto, '<>%1', rLin.Reparto::"Fra prepago");   //$025
        if rLin.ISEMPTY THEN
            ERROR(Text014);

        //$017
        if pPositivo THEN BEGIN
            SerieCode := LookupSeries(ConfVtas."Posted Invoice Nos.", rSerie.Code);
        END ELSE BEGIN
            SerieCode := LookupSeries(ConfVtas."Posted Credit Memo Nos.", rSerie.Code);
        END;

        finestra.OPEN('Creando Factura Nº #1########');

        ////{ *** Cabecera de factura *** }
        CabeceraComun(WORKDATE, rCab, pPositivo, SerieCode);

        ////{ *** Lineas de factura *** }
        rLin.SETCURRENTKEY("Document Type", "Document No.", "Line No.");
        rLin.SETRANGE("Document Type", rCab."Document Type");
        rLin.SETRANGE("Document No.", rCab."No.");
        rLin.SETRANGE("Linea Marcada a Borrador", TRUE);
        rLin.SETFILTER("Cantidad a Borrador", '<>%1', 0);
        rLin.SETFILTER(rLin.Reparto, '<>%1', rLin.Reparto::"Fra prepago");   //$025
        if rLin.FINDSET THEN
            REPEAT
                wImpPrepago := wImpPrepago + rLin."Prepmt. Amt. Inv.";          //$008
                                                                                // $003
                if (rLin.Type.AsInteger() <> 0) THEN BEGIN
                    rLin.TESTFIELD("Shortcut Dimension 1 Code");
                    rLin.TESTFIELD("Shortcut Dimension 2 Code");
                END;
                CLEAR(rLinFra);
                rLinFra.INIT;
                rLinFra."Document Type" := rCabFra."Document Type";
                rLinFra."Document No." := rCabFra."No.";
                rLinFra."Line No." := rLin."Line No.";
                rLinFra."Customer Order No." := rLin."Customer Order No.";
                rLinFra.INSERT;
                rLinFra.VALIDATE("Sell-to Customer No.", rCabFra."Sell-to Customer No.");
                rLinFra.VALIDATE(Type, rLin.Type);
                rLinFra.VALIDATE("No.", rLin."No.");
                //$036(I)
                if rLin.Type.AsInteger() <> 0 THEN BEGIN
                    rLinFra.VALIDATE("VAT Bus. Posting Group", rLin."VAT Bus. Posting Group");
                    rLinFra.VALIDATE("VAT Prod. Posting Group", rLin."VAT Prod. Posting Group");
                END;
                //$036(F)
                rLinFra.VALIDATE(Description, rLin.Description);
                rLinFra.VALIDATE("Description 2", rLin."Description 2");
                rLinFra.VALIDATE("Job No.", rLin."Job No.");
                rLinFra.VALIDATE("Job Task No.", rLin."Job Task No.");
                //$031(I)
                if (rLin.Type = rLin.Type::Resource) THEN
                    rLinFra.VALIDATE("Cód. proveedor", rLin."Cód. proveedor");
                //$031(F)

                rLinFra.VALIDATE(Duracion, rLin."Cantidad a Borrador");

                rLinFra."Cdad. Soportes" := rLin."Cdad. Soportes";
                rLinFra.VALIDATE(Quantity, rLin."Cantidad a Borrador");
                if (NOT pPositivo) AND (rLinFra.Quantity <> 0) THEN begin       //$017
                    rLinFra.VALIDATE(Quantity, -rLinFra.Quantity);
                    rLinFra.Duracion := -rLinFra.Duracion;
                end;    //$017
                rLin."Cantidad pasada Borrador" += rLin."Cantidad a Borrador";

                if (rLin."Unit Price" <> 0) THEN
                    rLinFra.VALIDATE("Unit Price", rLin."Unit Price");
                if (rLin."Line Discount %" <> 0) THEN
                    rLinFra.VALIDATE("Line Discount %", rLin."Line Discount %");

                //+001
                ShorCutDim[1] := rLin."Shortcut Dimension 1 Code";
                ShorCutDim[2] := rLin."Shortcut Dimension 2 Code";
                ShorCutDim[3] := rLin."Shortcut Dimension 3 Code";
                ShorCutDim[4] := rLin."Shortcut Dimension 4 Code";
                ShorCutDim[5] := rLin."Shortcut Dimension 5 Code";
                rLin.ShowShortcutDimCode(ShorCutDim);
                if ShorCutDim[1] = '' THEN ShorCutDim[1] := rLin."Shortcut Dimension 1 Code";
                if ShorCutDim[1] = '' THEN ShorCutDim[2] := rLin."Shortcut Dimension 2 Code";
                if ShorCutDim[1] = '' THEN ShorCutDim[3] := rLin."Shortcut Dimension 3 Code";
                if ShorCutDim[1] = '' THEN ShorCutDim[4] := rLin."Shortcut Dimension 4 Code";
                if ShorCutDim[1] = '' THEN ShorCutDim[5] := rLin."Shortcut Dimension 5 Code";

                rLinFra.VALIDATE("Shortcut Dimension 1 Code", ShorCutDim[1]);
                rLinFra.VALIDATE("Shortcut Dimension 2 Code", ShorCutDim[2]);
                rLinFra.VALIDATE("Shortcut Dimension 3 Code", ShorCutDim[3]);
                rLinFra.VALIDATE("Shortcut Dimension 4 Code", ShorCutDim[4]);
                rLinFra.VALIDATE("Shortcut Dimension 5 Code", ShorCutDim[5]);

                //-001
                rLinFra.VALIDATE("No linea proyecto", rLin."No linea proyecto");          //$018
                rLinFra."Fecha inicial recurso" := rLin."Fecha inicial recurso";  //$021
                rLinFra."Fecha final recurso" := rLin."Fecha final recurso";      //$021
                rLinFra.VALIDATE("Imprimir fecha recurso", rLin."Imprimir fecha recurso");//$024
                if (rLinFra."Line Amount" <> 0) and not rLin.Imprimir then
                    Error('No se puede marcar no imprimirmibles con importe');
                rLinFra.Imprimir := rLin.Imprimir;                                        //$024
                rLinFra.VALIDATE(Remarcar, rLin.Remarcar);                                //$039
                CLEAR(DimMng);
                rlinFra."Precio Compra" := rlin."Precio Compra";         //$040
                rLinFra."Dto. Compra" := rLin."Dto. Compra";

                rLinFra.MODIFY;
                rLin.MODIFY;

            //$008. Bloqueo esta parte, será un total
            //if (rLin."Prepmt. Amt. Inv." <> 0) THEN BEGIN
            //  Linea_Prepago(rLinFra.Quantity, rLin."Prepmt. Amt. Inv.");
            //END;

            UNTIL rLin.NEXT = 0;

        //$008(I)
        if wImpPrepago <> 0 THEN BEGIN
            //$025(I)
            //rCab.CALCFIELDS("Importe líneas");
            //rCabFra.CALCFIELDS("Importe líneas");
            wTotLinCont := TotalLineasRep(rCab."Document Type".AsInteger(), rCab."No.");
            wTotLinFac := TotalLineasRep(rCabFra."Document Type".AsInteger(), rCabFra."No.");
            //wImpPrepago := ROUND((wImpPrepago * rCabFra."Importe líneas") / rCab."Importe líneas");
            wImpPrepago2 := ROUND((wImpPrepago * wTotLinFac) / wTotLinCont);
            wTotLinContCost := TotalLineasRepCost(rCab."Document Type".AsInteger(), rCab."No.");
            wTotLinFacCost := TotalLineasRepCost(rCabFra."Document Type".AsInteger(), rCabFra."No.");
            //$025(F)
            if wTotLinFac <> 0 then wImpPrepagoCoste := ROUND(wImpPrepago * (wTotLinFacCost / wTotLinFac));
            //$025(F)
            Linea_Prepago(1, wImpPrepago, wImpPrepagoCoste);
        END;
        //$008(F)

        rLin.MODIFYALL("Cantidad a Borrador", 0);
        rLin.MODIFYALL("Linea Marcada a Borrador", FALSE);

        rCabFra.VALIDATE("Posting Description", STRSUBSTNO(Text015, WORKDATE));
        rCabFra."Fecha final factura" := WORKDATE;
        rCabFra."Vendedor Origen" := rCab."Vendedor Origen";
        rCabFra."Salesperson Code" := rCab."Salesperson Code";
        rCabFra.MODIFY;

        //$012
        if rCab."Remesa sin factura" THEN
            cGesCartera.CrearDocCartera(rCabFra, 0, 0);
        rJobSetup.Get();
        if rJobSetup."Crear Factura Interempresas" Then
            if rJob.Get(rCab."Nº Proyecto") then
                GestionProyecto.CreaFacturaVenta(rJob, rCabFra, rCabFra."Posting Description");
        rCab."Creada su facturación" := TRUE;
        rCab."Facturacion Iniciada" := TRUE;
        rCab."Tipo Facturacion" := rCab."Tipo Facturacion"::"Por Lineas";
        //$028(I)
        if rCab.Status = rCab.Status::Open THEN
            ReleaseSalesDoc.PerformManualRelease(rCab);
        //$028(F)
        rCab.MODIFY;

        finestra.CLOSE;
        cGesCartera.RegistrarDocCartera;                           //$012
        MESSAGE(Text009, rCab."Tipo Facturacion", rCabFra."No.");
    END;

    PROCEDURE CabeceraComun(wFecha2: Date; VAR rCab: Record 36; pPositivo: Boolean; SerieCode: Code[20]);
    var
        WorkDescription: Text;
    BEGIN
        ////{ *** Crea cabecera factura *** }

        CLEAR(rCabFra);
        CLEAR(rLinFra);
        //$017
        if pPositivo THEN BEGIN
            rCabFra."Document Type" := rCabFra."Document Type"::Invoice;
            rCabFra."No." := GestNoSer.GetNextNo(ConfVtas."Invoice Nos.", WORKDATE, TRUE);
        END
        ELSE BEGIN
            rCabFra."Document Type" := rCabFra."Document Type"::"Credit Memo";
            rCabFra."No." := GestNoSer.GetNextNo(ConfVtas."Credit Memo Nos.", WORKDATE, TRUE);
        END;
        //ASC 23/08/12
        rCabFra."Customer Order No." := rCab."Customer Order No.";

        rCabFra.INSERT(FALSE);
        finestra.UPDATE(1, rCabFra."No.");
        //$017
        if pPositivo THEN
            rCabFra.VALIDATE("No. Series", ConfVtas."Invoice Nos.")
        ELSE
            rCabFra.VALIDATE("No. Series", ConfVtas."Credit Memo Nos.");
        rCabFra.VALIDATE("Posting No. Series", SerieCode);
        rCabFra.VALIDATE("Shipping No. Series", ConfVtas."Posted Shipment Nos.");
        //$034(I)
        if NOT w1Fac THEN
            //$034(F)
            rCabFra.VALIDATE("Posting Date", wFecha2)
        //$034(I)
        ELSE
            rCabFra.VALIDATE("Posting Date", rCab."Fecha registro prepago");

        //$034(F)
        rCabFra.VALIDATE("Document Date", rCabFra."Posting Date");
        rCabFra.VALIDATE("Shipment Date", rCab."Shipment Date");
        rCabFra.VALIDATE("Order Date", rCab."Order Date");
        rCabFra.VALIDATE("Sell-to Customer No.", rCab."Sell-to Customer No.");
        //$002-
        rCabFra."Sell-to Customer Name" := rCab."Sell-to Customer Name";
        rCabFra."Sell-to Customer Name 2" := rCab."Sell-to Customer Name 2";
        rCabFra."Sell-to Address" := rCab."Sell-to Address";
        rCabFra."Sell-to Address 2" := rCab."Sell-to Address 2";
        rCabFra."Sell-to City" := rCab."Sell-to City";
        rCabFra."Sell-to Contact" := rCab."Sell-to Contact";
        rCabFra."Sell-to Post Code" := rCab."Sell-to Post Code";
        rCabFra."Sell-to County" := rCab."Sell-to County";
        rCabFra."Sell-to Country/Region Code" := rCab."Sell-to Country/Region Code";
        rCabFra."Bill-to Customer No." := rCab."Bill-to Customer No.";
        rCabFra."Bill-to Name" := rCab."Bill-to Name";
        rCabFra."Bill-to Name 2" := rCab."Bill-to Name 2";
        rCabFra."Bill-to Address" := rCab."Bill-to Address";
        rCabFra."Bill-to Address 2" := rCab."Bill-to Address 2";
        rCabFra."Bill-to City" := rCab."Bill-to City";
        rCabFra."Bill-to Contact" := rCab."Bill-to Contact";
        rCabFra."Bill-to Post Code" := rCab."Bill-to Post Code";
        rCabFra."Bill-to County" := rCab."Bill-to County";
        rCabFra."Bill-to Country/Region Code" := rCab."Bill-to Country/Region Code";
        // $002+
        rCabFra.VALIDATE("Your Reference", 'Proyecto ' + rCab."Nº Proyecto");
        rCabFra.VALIDATE("Nº Proyecto", rCab."Nº Proyecto");
        rCabFra.VALIDATE("Salesperson Code", rCab."Salesperson Code");
        rCabFra.VALIDATE("Currency Code", rCab."Currency Code");
        //rCabFra.VALIDATE("Posting Description",       'Periodo facturación: ' +
        //                  STRSUBSTNO('%1',rCabFra."Posting Date") + ' - ');
        rCabFra.VALIDATE("Posting Description", STRSUBSTNO('%1', rCabFra."Posting Date") + ' - ');          //$027
        //$034(I)
        if NOT w1Fac THEN BEGIN
            //$034(F)
            rCabFra.VALIDATE("Payment Terms Code", rCab."Payment Terms Code");
            rCabFra.VALIDATE("Payment Method Code", rCab."Payment Method Code");
            //$034(I)
        END
        ELSE BEGIN
            rCabFra.VALIDATE("Payment Terms Code", rCab."Prepmt. Payment Terms Code");
            rCabFra.VALIDATE("Payment Method Code", rCab."Forma pago prepago");
        END;
        //$034(F)
        rCabFra.VALIDATE("Fecha inicial proyecto", rCab."Fecha inicial proyecto");
        rCabFra.VALIDATE("Fecha fin proyecto", rCab."Fecha fin proyecto");
        rCabFra.VALIDATE("Cód. términos facturacion", rCab."Cód. términos facturacion");
        rCabFra.VALIDATE("Factura propuesta sistema", TRUE);
        rCabFra.VALIDATE("Nº Contrato", rCab."No.");
        rCabFra.VALIDATE("Payment Discount %", rCab."Payment Discount %");
#if not CLEAN27
        // TODO: - CLEAN22
#pragma warning disable AL0432
        rCabFra.VALIDATE("Pay-at Code", rCab."Pay-at Code");
#pragma warning restore AL0432
        // TODO: - CLEAN22
#endif
        rCabFra.VALIDATE("Ship-to Code", rCab."Ship-to Code");
        // $002-
        rCabFra."Ship-to Name" := rCab."Ship-to Name";
        rCabFra."Ship-to Name 2" := rCab."Ship-to Name 2";
        rCabFra."Ship-to Address" := rCab."Ship-to Address";
        rCabFra."Ship-to Address 2" := rCab."Ship-to Address 2";
        rCabFra."Ship-to City" := rCab."Ship-to City";
        rCabFra."Ship-to Contact" := rCab."Ship-to Contact";
        rCabFra."Ship-to Post Code" := rCab."Ship-to Post Code";
        rCabFra."Ship-to County" := rCab."Ship-to County";
        rCabFra."Ship-to Country/Region Code" := rCab."Ship-to Country/Region Code";
        // $002+
        rCabFra."Comentario Cabecera" := rCab."Comentario Cabecera";
        rCabFra.Tipo := rCab.Tipo;
        rCabFra.Firmado := rCab.Firmado;
        rCabFra.Subtipo := rCab.Subtipo;
        rCabFra."Soporte de" := rCab."Soporte de";
        rCabFra.VALIDATE("Interc./Compens.", rCab."Interc./Compens.");         //FCL-18/05/04
        rCabFra.VALIDATE("Proyecto origen", rCab."Proyecto origen");          //FCL-18/05/04
        rCabFra.VALIDATE(Renovado, rCab.Renovado);                   //FCL-18/05/04
        rCabFra."Fecha inicial factura" := rCabFra."Posting Date";              //FCL-17/06/04
        rCabFra.VALIDATE("Shortcut Dimension 1 Code", rCab."Shortcut Dimension 1 Code");
        rCabFra.VALIDATE("Shortcut Dimension 2 Code", rCab."Shortcut Dimension 2 Code");
        rCabFra.VALIDATE("Shortcut Dimension 3 Code", rCab."Shortcut Dimension 3 Code");
        rCabFra.VALIDATE("Shortcut Dimension 4 Code", rCab."Shortcut Dimension 4 Code");
        rCabFra.VALIDATE("Shortcut Dimension 5 Code", rCab."Shortcut Dimension 5 Code");

        rCabFra.VALIDATE("Invoice Disc. Code", rCab."Invoice Disc. Code");     //$026
        rCabFra.VALIDATE("Cod cadena", rCab."Cod cadena");                     //$038
        rCabFra."Esperar Orden Cliente" := rCab."Esperar Orden Cliente";
        rCabFra."Nuestra Cuenta" := rCab."Nuestra Cuenta";
        rCabFra."B2R Bank Payment Code" := rCab."Nuestra Cuenta";
        if rCab."Nuestra Cuenta Prepago" = '' Then rcAb."Nuestra Cuenta Prepago" := rCab."Nuestra Cuenta";
        rCabFra."Nuestra Cuenta Prepago" := rCab."Nuestra Cuenta Prepago";
        if rCabFra."Factura prepago" Then rCabFra."B2R Bank Payment Code" := rCab."Nuestra Cuenta Prepago";
        rCabFra."Ampliación Covit19" := rCab."Ampliación Covit19";
        rCabFra."Posting No. Series" := SerieCode;
        WorkDescription := rCab.GetWorkDescription();
        rCabFra.SetWorkDescription(WorkDescription);
        rCabFra."Vendedor Origen" := rCab."Vendedor Origen";
        rCabFra."Salesperson Code" := rCab."Salesperson Code";
        OnAfterCreateInvoiceHeader(rCabFra, rCab);
        rCabFra.MODIFY(FALSE);


        // //{ *** También se traspasan los comentarios *** }
        rComentVenta.SETCURRENTKEY("Document Type", "No.", "Line No.");
        rComentVenta.SETRANGE("Document Type", rComentVenta."Document Type"::Order);
        rComentVenta.SETRANGE("No.", rCab."No.");
        if rComentVenta.FIND('-') THEN
            REPEAT
                CLEAR(rComent2);
                //rComent2."Document Type" := rComent2."Document Type"::Invoice;             //$017
                rComent2."Document Type" := rCabFra."Document Type";                       //$017
                rComent2."No." := rCabFra."No.";
                rComent2."Line No." := rComentVenta."Line No.";
                rComent2.Date := rComentVenta.Date;
                rComent2.Code := rComentVenta.Code;
                rComent2.Comment := rComentVenta.Comment;
                rComent2.INSERT;
            UNTIL rComentVenta.NEXT = 0;
    END;

    PROCEDURE ComprobarReparto(rCab: Record 36; rTerminos: Record "Términos facturación");
    VAR
        rLinFac: Record 37;
    BEGIN
        //FCL-16/02/06. Sumatorio de líneas con reparto en primera factura y en primera factura + proporcional.

        w1Fac := FALSE;
        rLinFac.RESET;
        rLinFac.SETRANGE("Document Type", rCab."Document Type");
        rLinFac.SETRANGE("Document No.", rCab."No.");
        rLinFac.SETRANGE(Reparto, rLinFac.Reparto::"1ª Fra");
        if rLinFac.FIND('-') THEN
            w1Fac := TRUE;

        w1FacPro := FALSE;
        rLinFac.RESET;
        rLinFac.SETRANGE("Document Type", rCab."Document Type");
        rLinFac.SETRANGE("Document No.", rCab."No.");
        rLinFac.SETRANGE(Reparto, rLinFac.Reparto::"1ª Fra+proporc.");
        if rLinFac.FIND('-') THEN
            w1FacPro := TRUE;

        if w1Fac AND w1FacPro THEN
            ERROR(Text002);

        //$034. Bloqueo algunas líneas, sumaré 1 a los plazos en la función que llama a ésta.
        //if NOT w1Fac THEN BEGIN
        if rTnos."Nº de plazos" = 0 Then
            wBucle := rTnos."Nº de Facturas" else
            wBucle := rTnos."Nº de plazos";
        //END
        //ELSE BEGIN
        //  wBucle := rTnos."Nº de plazos" + 1;
        //END;

        if rTnos."Nº de plazos" = 0 THEN
            rTnos."Nº de plazos" := 0;
        if rTnos."Nº de plazos" > 0 THEN BEGIN
            rPlazos.SETRANGE("Cód. términos facturación", rTnos.Código);
            if rPlazos.FIND('-') THEN BEGIN
                rPlazos2.COPYFILTERS(rPlazos);
                rPlazos2.CALCSUMS("% del total");
                if (rPlazos2."% del total" <> 100) THEN
                    ERROR('El total de los plazos en los terminos de \' +
                          'facturacion %1 es %2 \' +
                          'y tiene que ser igual a 100', rPlazos."Cód. términos facturación", rPlazos2."% del total");
            END;
        END;
    END;

    PROCEDURE Linea_Prepago(wCantidad: Decimal; wPrecio: Decimal; wPrecioCompra: Decimal);
    VAR
        rConfig: Record 252;
    BEGIN

        CLEAR(rLinPrepago);
        rLinPrepago.INIT;
        rLinPrepago."Document Type" := rLinFra."Document Type";
        rLinPrepago."Document No." := rLinFra."Document No.";
        rLinPrepago."Line No." := rLinFra."Line No." + 50;
        rLinPrepago.INSERT;
        rLinPrepago.VALIDATE("Sell-to Customer No.", rCabFra."Sell-to Customer No.");

        //$008. Cogeré la primera configuración, todas las líneas tienen la misma.
        //Más adelante se puede crear una configuración general.
        rConfig.RESET;
        rConfig.FIND('-');
        //if NOT rConfig.GET(rLinFra."Gen. Bus. Posting Group", rLinFra."Gen. Prod. Posting Group") THEN
        //  ERROR(Text011, rLinFra."Gen. Bus. Posting Group", rLinFra."Gen. Prod. Posting Group");
        if rConfig."Sales Prepayments Account" = '' THEN
            //ERROR(Text012, rLinFra."Gen. Bus. Posting Group", rLinFra."Gen. Prod. Posting Group");
            ERROR(Text012, rConfig."Gen. Bus. Posting Group", rConfig."Gen. Prod. Posting Group");

        rLinPrepago.VALIDATE(Type, rLinPrepago.Type::"G/L Account");
        rLinPrepago.VALIDATE("No.", rConfig."Sales Prepayments Account");

        //$013
        //rLinPrepago.VALIDATE(Description, STRSUBSTNO('%1 %2', 'Prepago', rLin.Description));

        rLinPrepago.VALIDATE(Description, COPYSTR(STRSUBSTNO('%1 %2', 'ENTREGA A CUENTA', ''), 1,
                             MAXSTRLEN(rLinPrepago.Description)));                        //REVISAR
                                                                                          //rLinFra.VALIDATE("Description 2", rLin."Description 2");

        // Los prepagos no deben tener no. proyecto para que no genere mov. proyecto
        rLinPrepago."Job No." := '';

        rLinPrepago."Allow Invoice Disc." := FALSE;

        /* {
        rLinPrepago.VALIDATE(Quantity, (rLin."Cantidad a Borrador" * (-1)));
        rLinPrepago.VALIDATE("Unit Price", ROUND(rLin."Prepmt. Amt. Inv."/rLin."Quantity (Base)", 0.01));
        } */
        rLinPrepago.VALIDATE(Quantity, (wCantidad * (-1)));
        rLinPrepago.VALIDATE("Unit Price", wPrecio);
        rLinPrepago."Precio Compra" := wPrecioCompra;

        //+001
        //$008- Se cogerán las dimensiones de la cuenta.
        ////rLinPrepago.VALIDATE("Shortcut Dimension 1 Code", rLinFra."Shortcut Dimension 1 Code");
        ////rLinPrepago.VALIDATE("Shortcut Dimension 2 Code", rLinFra."Shortcut Dimension 2 Code");
        //-001

        rLinPrepago.MODIFY;
    END;

    PROCEDURE Propuesta(rCab: Record 36);
    VAR
        rLin: Record 37;
        rLinFac: Record 37;
        rPropuesta: Record "Facturas Propuestas";
        ImporteLineasFacturaPrepago: Decimal;
        ImportePrepagoLineasFacturaPrepago: Decimal;
        i: Integer;
        yafact: Decimal;
        wDescontar: Decimal;
        wImporte: Decimal;
        wImporteIva: Decimal;
        rPaymentTerms: Record "Payment Terms";
        rCabVenta: Record 36;
        TempSalesLine: Record 37 temporary;
        TotalSalesLine: Record 37;
        TotalSalesLineLCY: Record 37;
        RegisVtas: Codeunit "Sales-Post";
        wDecimal: Decimal;
        wTexto: Text;
        TotCont: Decimal;
        TotContI: Decimal;
        Diff: Decimal;
        DiffI: Decimal;
    BEGIN
        if rCabVenta.GET(rCabVenta."Document Type"::Order, rCab."No.") THEN BEGIN
            CLEAR(TotalSalesLine);
            CLEAR(TotalSalesLineLCY);
            CLEAR(RegisVtas);
            CLEAR(TempSalesLine);
            RegisVtas.GetSalesLines(rCabVenta, TempSalesLine, 0);
            CLEAR(RegisVtas);
            RegisVtas.SumSalesLinesTemp(rCabVenta, TempSalesLine, 0, TotalSalesLine, TotalSalesLineLCY,
                                        wDecimal, wTexto, wDecimal, wDecimal, wDecimal);
            TotCont := TotalSalesLineLCY.Amount;
            TotContI := TotalSalesLineLCY."Amount Including VAT";
        END;
        rLin.RESET;
        rLin.SETRANGE("Document Type", rCab."Document Type");
        rLin.SETRANGE("Document No.", rCab."No.");
        wImpPrepago := 0;
        If rLin.FindFirst() then
            repeat
                if rLin.Reparto = rLin.Reparto::"Fra prepago" then begin

                    ImporteLineasFacturaPrepago += rLin."Line Amount";
                    ImportePrepagoLineasFacturaPrepago += rLin."Prepmt. Line Amount";
                end;

                wImpPrepago += rLin."Prepmt. Line Amount";
            until rLin.Next() = 0;
        If rcab."% prep incl produccion" then
            wImpPrepago += ImporteLineasFacturaPrepago - ImportePrepagoLineasFacturaPrepago
        else
            wImpPrepago += ImporteLineasFacturaPrepago;
        CLEAR(rPropuesta);
        rPropuesta.SETRANGE("No. Contrato", rCab."No.");
        if rPropuesta.ISEMPTY THEN BEGIN

            //$016. Limpio el campo temporal
            rLin.RESET;
            rLin.SETCURRENTKEY("Document Type", "Document No.", "Line No.");
            rLin.SETRANGE("Document Type", rCab."Document Type");
            rLin.SETRANGE("Document No.", rCab."No.");
            if rLin.FINDSET THEN
                rLin.MODIFYALL("Cdad. Facturada MLL", 0);

            rCab.TESTFIELD("Posting Date");
            rCab.TESTFIELD("Payment Terms Code");
            rCab.TESTFIELD("Payment Method Code");
            if rCab."Cód. términos prepago" = '' Then
                rCab.TESTFIELD("Cód. términos facturacion");

            fechaR := rCab."Posting Date";
            fechaRDes := rCab."Fecha inicial proyecto";                              //$005B
            wFecha := fechaR;
            wTotPrepago := 0;                                                         //FCL-14/02/11
            if rCab."Cód. términos prepago" <> '' Then
                rTnos.GET(rCab."Cód. términos prepago")
            else
                rTnos.GET(rCab."Cód. términos facturacion");
            rTnos.CALCFIELDS("Nº de plazos");
            if rCab."Cód. términos prepago" <> '' Then
                rPlazos.SETRANGE(rPlazos."Cód. términos facturación", rCab."Cód. términos prepago")
            else
                rPlazos.SETRANGE(rPlazos."Cód. términos facturación", rCab."Cód. términos facturacion");
            if not rPlazos.FINDFIRST THEN begin
                rPlazos.Init();
                rPlazos."Cód. términos facturación" := '';
            end;
            //$019(I)


            //$019(F)

            ComprobarReparto(rCab, rTnos);
            //$020(I)
            wMesesCont := rCab."Fecha fin proyecto" - rCab."Fecha inicial proyecto";
            wMesesCont := ROUND(wMesesCont / 30.42, 1);          //son 365 dias entre 12 meses
            wDiasFactEsp := 0;
            if (wBucle < wMesesCont) AND (wBucle <> 1) THEN BEGIN
                wDiasCont := (rCab."Fecha fin proyecto" - rCab."Fecha inicial proyecto") + 1;
                //$034(I)
                //wFechaD:=fechaR;
                //wFechaH:=fechaR;
                wFechaD := fechaRDes;
                wFechaH := fechaRDes;
                //$034(F)
                FOR i := 1 TO wBucle DO BEGIN
                    if rPlazos."Distancia entre plazos" = '' then
                        wFechaH := CALCDATE(rTnos."Cálculo de Plazos", wFechaH)
                    else
                        wFechaH := CALCDATE(rPlazos."Distancia entre plazos", wFechaH);
                END;
                wFechaH := wFechaH - 1;
                wDiasFactEsp := (wFechaH - wFechaD) + 1;
            END;
            //$020(F)

            //$034(I) Generaré nº de bucles + 1¦ fra.
            if w1Fac THEN
                wBucle := wBucle + 1;
            //$034(F)
            rTnos."Nº de plazos" := rTnos."Nº de plazos" + 1;

            FOR i := 1 TO wBucle DO BEGIN
                if rPlazos."Cód. términos facturación" <> '' tHEN
                    rPlazos.TESTFIELD("% del total");
                /////if (wBucle = 13) AND (i = 2) THEN                        //$023
                /////  fechaR:=wFecha;                                        //$023
                CLEAR(rPropuesta);
                rPropuesta."No. Contrato" := rCab."No.";
                rPropuesta."No. linea" := i;
                rPropuesta."Customer Order No." := rCab."Customer Order No.";
                //$034(I)
                if NOT w1Fac THEN BEGIN
                    //$034(F)
                    rPropuesta."Cód. Forma Pago" := rCab."Payment Method Code";
                    rPropuesta."Cód. términos Pago" := rCab."Payment Terms Code";
                    //$034(I)
                END
                ELSE BEGIN
                    rPropuesta."Cód. Forma Pago" := rCab."Forma pago prepago";
                    rPropuesta."Cód. términos Pago" := rCab."Prepmt. Payment Terms Code";
                    rPropuesta."Factura 1" := TRUE;
                END;
                //$034(F)
                if rCab."Cód. términos prepago" <> '' Then
                    rPropuesta."Cód. términos facturacion" := rCab."Cód. términos prepago"
                else
                    rPropuesta."Cód. términos facturacion" := rCab."Cód. términos facturacion";
                rPropuesta."Tipo Facturación" := rCab."Tipo Facturacion";
                if rPlazos."Cód. términos facturación" = '' tHEN
                    rPlazos."Cód. términos facturación" := StrSubstNo('%1', rTnos."Cálculo de Plazos");
                rPlazos.TESTFIELD("Distancia entre plazos");
                //rPropuesta."Texto de registro"         := STRSUBSTNO('Periodo facturación: %1 - ', fechaR);    //$005B
                //rPropuesta."Texto de registro"         := STRSUBSTNO('Periodo facturación: %1 - ', fechaRDes);   //$005B

                //$034(I)
                if NOT w1Fac THEN BEGIN
                    //$034(F)
                    rPropuesta."Texto de registro" := STRSUBSTNO('%1 - ', fechaRDes);                                   //$005B, %027
                    rPropuesta."Fecha Factura" := fechaR;
                    rTerminos.GET(rCab."Payment Terms Code");
                    rPropuesta."Fecha Vencimiento" := CALCDATE(rTerminos."Due Date Calculation", rPropuesta."Fecha Factura");
                    if rCab."Bill-to Customer No." <> '' THEN
                        AdjustDueDate.SalesAdjustDueDate(rPropuesta."Fecha Vencimiento",
                        rPropuesta."Fecha Factura", rTerminos.CalculateMaxDueDate(rPropuesta."Fecha Factura"), rCab."Bill-to Customer No.");
                    //$034(I)
                END
                ELSE BEGIN
                    rPropuesta."Texto de registro" := rCab."No.";
                    rPropuesta."Fecha Factura" := rCab."Fecha registro prepago";
                    //If Not rTerminos.GET(rPropuesta."Cód. términos Pago") then rTerminos.Init();
                    rPropuesta."Fecha Vencimiento" := rCab."Prepayment Due Date";       //cojo la fecha de la pantalla del contrato
                END;
                //$034(F)

                if NOT w1Fac THEN BEGIN
                    if rPlazos."Distancia entre plazos" = '' then
                        FechaR := CALCDATE(rTnos."Cálculo de Plazos", FechaR)
                    ELSE                                              //$034
                        fechaR := CALCDATE(rPlazos."Distancia entre plazos", fechaR);
                    if rPlazos."Distancia entre plazos" = '' then
                        fechaRDes := CALCDATE(rTnos."Cálculo de Plazos", fechaRDes) ELSE
                        fechaRDes := CALCDATE(rPlazos."Distancia entre plazos", fechaRDes);     //$005B
                                                                                                /////if (wBucle = 13) AND (i = 1) THEN BEGIN                            //$023
                                                                                                /////  rPropuesta."Texto de registro" := STRSUBSTNO('%1 '+Text001, FORMAT(rPlazos."% del total"));//$023
                                                                                                /////END ELSE BEGIN                                                     //$023
                                                                                                // {Para acabar de completar el periodo de factura.}
                                                                                                //rPropuesta."Texto de registro" += STRSUBSTNO('%1', fechaR-1);       //$005B
                    rPropuesta."Texto de registro" += STRSUBSTNO('%1', fechaRDes - 1);      //$005B
                                                                                            /////END;

                    //$032(I). Aqui está mal colocado.
                    /* {
                    if (i = 1) AND (w1Fac) THEN BEGIN                                     //FCL-16/02/06
                      ///i:= i - 1;                                                       //FCL-16/02/06         //$025
                      w1Fac:=FALSE;                                                       //FCL-16/02/06
                    END;
                    } */
                    //$032(F)

                    if wDiasFactEsp <> 0 THEN BEGIN
                        wDiasSumar := ROUND(wDiasCont * ((fechaR - 1) - rPropuesta."Fecha Factura") / wDiasFactEsp, 1);
                        if i = 1 THEN
                            wFechaD := rCab."Fecha inicial proyecto";
                        if i <> wBucle THEN BEGIN
                            wTxtFec := '+' + FORMAT(wDiasSumar, 0, '<integer>') + 'D';
                            wFechaH := CALCDATE(wTxtFec, wFechaD);
                        END
                        ELSE BEGIN
                            wFechaH := rCab."Fecha fin proyecto";
                        END;
                        //rPropuesta."Texto de registro":='Periodo facturación: ' +
                        //           STRSUBSTNO('%1',wFechaD) + ' - ' + STRSUBSTNO('%1', wFechaH);
                        rPropuesta."Texto de registro" := STRSUBSTNO('%1', wFechaD) + ' - ' + STRSUBSTNO('%1', wFechaH);       //$027
                        wFechaD := wFechaH + 1;
                    END
                    ELSE BEGIN
                        if rTnos."Nº de plazos" = 1 THEN
                            //rPropuesta.VALIDATE("Texto de registro",'Periodo facturación: ' +
                            //              STRSUBSTNO('%1',rCab."Fecha inicial proyecto") + ' - ' + STRSUBSTNO('%1',rCab."Fecha fin proyecto"));
                            rPropuesta.VALIDATE("Texto de registro",
                            STRSUBSTNO('%1', rCab."Fecha inicial proyecto") + ' - ' + STRSUBSTNO('%1', rCab."Fecha fin proyecto"));   //$027

                    END;
                END;                                                                     //$034

                CabeceraPropuesta(rPropuesta, rCab);                             //$019

                // calculo importe
                // //{ *** Lineas de factura *** }
                rLin.RESET;
                rLin.SETCURRENTKEY("Document Type", "Document No.", "Line No.");
                rLin.SETRANGE("Document Type", rCab."Document Type");
                rLin.SETRANGE("Document No.", rCab."No.");
                //FCL-16/02/06(I).
                if w1Fac THEN BEGIN
                    rLin.SETRANGE(Reparto, rLin.Reparto::"1ª Fra");
                END
                ELSE BEGIN
                    if (w1FacPro) AND (i = 1) THEN BEGIN
                        //rLin.SETFILTER(Reparto,'<>%1',rLin.Reparto::"1¦ Fra");                                              //$025
                        rLin.SETFILTER(Reparto, '<>%1 & <>%2', rLin.Reparto::"1ª Fra", rLin.Reparto::"Fra prepago");             //$025
                    END
                    ELSE BEGIN
                        rLin.SETRANGE(Reparto, rLin.Reparto::Proporcional);
                    END;
                END;
                //FCL-16/02/06(F).

                rLin.SETFILTER(Quantity, '<>%1', 0);
                if rLin.FINDSET THEN
                    REPEAT
                        // $003
                        if (rLin.Type.AsInteger() <> 0) THEN BEGIN
                            rLin.TESTFIELD("Shortcut Dimension 1 Code");
                            rLin.TESTFIELD("Shortcut Dimension 2 Code");
                        END;


                        CLEAR(yafact);
                        if rLin.Reparto = rLin.Reparto::Proporcional THEN BEGIN          //FCL-16/02/06
                            yafact := rLin.Quantity * rPlazos."% del total" / 100;
                            if rPlazos."% del total" = 0 then yafact := rLin.Quantity / rTnos."Nº de Facturas";
                            rLin."Cdad. Facturada MLL" := rLin."Cdad. Facturada MLL" + yafact;
                            if (i = rTnos."Nº de plazos") THEN BEGIN                  //    {Es la ultima factura, asegurarse de que se factura todo}
                                if (rLin."Cdad. Facturada MLL" <> rLin.Quantity) THEN BEGIN
                                    yafact := rLin.Quantity - rLin."Cdad. Facturada MLL";
                                    rLin."Cdad. Facturada MLL" := rLin."Cdad. Facturada MLL" + yafact;
                                END;
                            END;
                        END                                                              //FCL-16/02/06
                        ELSE BEGIN                                                       //FCL-16/02/06
                            yafact := rLin.Quantity;                                         //FCL-16/02/06
                        END;
                        CLEAR(wDescontar);                               // unidad
                                                                         //$015
                                                                         //wDescontar := (rPlazos."% del total" / 100);
                        wDescontar := yafact;

                        // $004



                        // descuentos linea
                        if (rLin."Line Discount %" <> 0) THEN BEGIN
                            //rLinFra.VALIDATE("Line Discount %",            rLin."Line Discount %");
                            //$015(I)
                            //rPropuesta."Importe sin IVA" -= ROUND(wDescontar * rLin."Line Discount Amount", 0.001);
                            //rPropuesta."Importe con IVA" -= ROUND(wDescontar * rLin."Line Discount Amount" * (
                            //                               1 +
                            //                               TraeIva(rLin."VAT Bus. Posting Group",
                            //                               rLin."VAT Prod. Posting Group",
                            //                               rPropuesta."Fecha Factura") / 100), 0.001);
                            rPropuesta."Importe sin IVA" += ((wDescontar * (rLin."Unit Price") * (1 - rLin."Line Discount %" / 100)));//, 0.001);
                            rPropuesta."Importe con IVA" += ((wDescontar * (rLin."Unit Price") * (1 - rLin."Line Discount %" / 100)) * (
                                                           1 +
                                                           TraeIva(rLin."VAT Bus. Posting Group",
                                                           rLin."VAT Prod. Posting Group",
                                                           rPropuesta."Fecha Factura") / 100));//, 0.001);
                                                                                               //$015(F)

                        END ELSE BEGIN
                            rPropuesta."Importe sin IVA" += (yafact * rLin."Unit Price");//, 0.001);
                            rPropuesta."Importe con IVA" += (yafact * rLin."Unit Price" * (
                                                            1 +
                                                            TraeIva(rLin."VAT Bus. Posting Group",
                                                            rLin."VAT Prod. Posting Group",
                                                           rPropuesta."Fecha Factura") / 100));//, 0.001);

                        END;

                        LineaPropuesta(rLin, yafact);                                           //$019

                        //$019. Bloqueo esta parte, se calculará al final de las líneas.
                        /*  {
                         // prepagos
                         //if rLin."Prepmt. Amt. Inv." <> 0) THEN BEGIN     // Para el calculo de propuestas uso el imp sin facturar
                         if (rLin."Prepmt. Line Amount" <> 0) THEN BEGIN
                           //Linea_Prepago(rLinFra.Quantity, rLin."Prepmt. Amt. Inv.");
                          rPropuesta."Importe sin IVA" -= ROUND(wDescontar * rLin."Prepmt. Line Amount", 0.001);
                          rPropuesta."Importe con IVA" -= ROUND(wDescontar * rLin."Prepmt. Line Amount" * (
                                                          1 +
                                                          TraeIva(rLin."VAT Bus. Posting Group",
                                                          rLin."VAT Prod. Posting Group",
                                                          rPropuesta."Fecha Factura") / 100), 0.001);

                         END;
                         } */

                        rLin.MODIFY;

                    UNTIL rLin.NEXT = 0;

                // fin calculo importe
                if NOT w1Fac THEN
                    if rPlazos."Cód. términos facturación" <> '' then rPlazos.NEXT;

                //$019(I)
                // prepagos
                if wImpPrepago <> 0 THEN BEGIN
                    //$025(I)
                    //rCab.CALCFIELDS("Importe líneas");
                    wTotLinCont := TotalLineasRep(rCab."Document Type".AsInteger(), rCab."No.");
                    //wImpPrepago2 := ROUND(((wImpPrepago) * rPropuesta."Importe sin IVA") / wTotLinCont);
                    wImpPrepago2 := ROUND(((wImpPrepago - ImporteLineasFacturaPrepago) * rPropuesta."Importe sin IVA") / wTotLinCont);
                    //$025(F)
                    wTotPrepago := wTotPrepago + wImpPrepago2;
                    // if i = wBucle THEN BEGIN                                       //Sumo la diferencia a la última línea
                    //     if wTotPrepago <> wImpPrepago THEN
                    //         wImpPrepago2 := wImpPrepago2 + (wImpPrepago - wTotPrepago);
                    // END;

                    rPropuesta."Importe sin IVA" -= wImpPrepago2;
                    LineaPropuestaPrep(wImpPrepago2);      //voy ahora a generar la línea, así obtendré los grupos de iva.
                    rPropuesta."Importe con IVA" -= ROUND(wImpPrepago2 *
                       (1 + TraeIva(rLinTemp."VAT Bus. Posting Group", rLinTemp."VAT Prod. Posting Group",
                       rPropuesta."Fecha Factura") / 100), 0.001);

                END;
                //$019(F)

                //$019(I)
                CalcTotalPropuesta(rCabTemp, wImporte, wImporteIva);
                rPropuesta."Importe sin IVA" := wImporte;
                rPropuesta."Importe con IVA" := wImporteIva;
                //$019(F)

                rPropuesta.INSERT;

                //$032(I).
                if (i = 1) AND (w1Fac) THEN BEGIN                                     //FCL-16/02/06
                                                                                      ///i:= i - 1;                                                       //FCL-16/02/06         //$025
                    w1Fac := FALSE;                                                       //FCL-16/02/06
                END;
                //$032(F)

            END;
            // Otra pasada en las lineas para limpiar campo temporal
            rLin.RESET;
            rLin.SETCURRENTKEY("Document Type", "Document No.", "Line No.");
            rLin.SETRANGE("Document Type", rCab."Document Type");
            rLin.SETRANGE("Document No.", rCab."No.");
            if rLin.FINDSET THEN
                rLin.MODIFYALL("Cdad. Facturada MLL", 0);

            COMMIT;
        END;
        rPropuesta.Reset();
        rPropuesta.SETRANGE("No. Contrato", rCab."No.");
        If rPropuesta.FindFirst() then
            repeat
                Diff += rPropuesta."Importe sin IVA";
                DiffI += rPropuesta."Importe con IVA";
            until rPropuesta.NEXT() = 0;
        rLin.RESET;
        rLin.SETCURRENTKEY("Document Type", "Document No.", "Line No.");
        rLin.SETRANGE("Document Type", rCab."Document Type");
        rLin.SETRANGE("Document No.", rCab."No.");
        rlin.SetFilter(rLin."VAT Prod. Posting Group", '<>%1', '');
        if rLin.FINDSET THEN
            wImpPrepago2 := Round(wImpPrepago * (1 + TraeIva(rcab."VAT Bus. Posting Group", rLin."VAT Prod. Posting Group",
                           rPropuesta."Fecha Factura") / 100), 0.001);
        Diff += wImpPrepago;
        DiffI += wImpPrepago2;
        if (Diff <> TotCont) or (DiffI <> TotContI) then begin
            rPropuesta.FindLast();
            rPropuesta."Importe con IVA" += (TotContI - DiffI);
            rPropuesta."Importe sin IVA" += (TotCont - Diff);
            If Abs(DiffI - TotContI) < 2 then begin
                rPropuesta.Modify();
                COMMIT;
            end;
        end;
    END;

    PROCEDURE TraeIva("VAT Bus. Posting Group": Code[20]; "VAT Prod. Posting Group": Code[20]; "Posting Date": Date): Decimal;
    VAR
        VATPostingSetup: Record 325;
        rIva: Record "Iva por fechas";
    BEGIN
        //FCL-09/08/10. Desconecto la parte de Iva por fechas, no se utiliza.

        if NOT VATPostingSetup.GET("VAT Bus. Posting Group", "VAT Prod. Posting Group") THEN EXIT(0);

        rIva.SETRANGE(rIva."VAT Bus. Posting Group", "VAT Bus. Posting Group");
        rIva.SETRANGE(rIva."VAT Prod. Posting Group", "VAT Prod. Posting Group");
        rIva.SETFILTER(rIva."Fecha Entrada en vigor", '<=%1', "Posting Date");
        if rIva.FINDFIRST THEN
            VATPostingSetup.GET(rIva."New VAT Bus. Posting Group", rIva."New VAT Prod. Posting Group");

        EXIT(VATPostingSetup."VAT %");
    END;

    PROCEDURE DiasProyecto();
    BEGIN
        // $007. //Compruebo que las fechas del proyecto estén entre el rango de fechas a facturar.

        wDiasFact := (fechaF - fechaI) + 1;
        wDias := 0;

        if rLin."Fecha inicial recurso" < fechaI THEN BEGIN
            if rLin."Fecha final recurso" < fechaI THEN BEGIN
                wDias := 0;
            END
            ELSE BEGIN
                if rLin."Fecha final recurso" < fechaF THEN BEGIN
                    wDias := (rLin."Fecha final recurso" - fechaI) + 1;
                END
                ELSE BEGIN
                    wDias := wDiasFact;
                END;
            END;
        END
        ELSE BEGIN
            if rLin."Fecha inicial recurso" > fechaF THEN BEGIN
                wDias := 0;
            END
            ELSE BEGIN
                if rLin."Fecha final recurso" > fechaF THEN BEGIN
                    wDias := (fechaF - rLin."Fecha inicial recurso") + 1;
                END
                ELSE BEGIN
                    wDias := (rLin."Fecha final recurso" - rLin."Fecha inicial recurso") + 1;
                END;
            END;
        END;
    END;

    PROCEDURE LineasOrden();
    VAR
        wDiasAux: Code[10];
        wDescAux: Text[60];
        wMes: Text[30];
        wPrimero: Boolean;
        wMesAux: Integer;
        wPorDias: Boolean;
    BEGIN
        //Datos correspondientes a la orden de publicidad, que se grabarán como línea de comentario

        if rOrden.GET(rLin."No. Orden Publicidad") THEN BEGIN

            // Linea para el nombre del recurso
            if rRecurso.GET(rOrden.Concepto) THEN
                InsertaLinea(rRecurso.Name);

            // Linea para Seccion
            if (rOrden.Seccion <> '') THEN
                InsertaLinea(STRSUBSTNO('Seccion: %1', rOrden.Seccion));

            // Linea para alto/ancho
            if ((rOrden.Alto <> 0) AND (rOrden.Ancho <> 0)) THEN
                InsertaLinea(STRSUBSTNO('(Alto x Ancho): %1 x %2', rOrden.Alto, rOrden.Ancho));

            // Linea para recargo si hay
            if (rOrden.Recargo <> 0) THEN
                InsertaLinea(STRSUBSTNO('Recargo: %1', rOrden.Recargo));

        END;

        // Datos correspondientes a los días de las líneas.
        // Si alguna línea tiene observaciones o alguna línea tiene más de una inserción imprimo día a día.
        CLEAR(rLinOrden);
        CLEAR(wDescAux);
        CLEAR(wDiasAux);
        wPrimero := FALSE;
        wPorDias := FALSE;
        rLinOrden.RESET;
        rLinOrden.SETCURRENTKEY("Tipo orden", "No. orden", "Fecha inicio");
        rLinOrden.SETRANGE("No. orden", rLin."No. Orden Publicidad");
        rLinOrden.SETRANGE("Fecha inicio", fechaI, fechaF);
        ////rLinOrden.SETFILTER(Precio, '<>%1', 0);              //$014
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
                        InsertaLinea(wDescAux);
                        CLEAR(wDescAux);
                    END;
                END
                ELSE BEGIN
                    if FORMAT(DATE2DMY(rLinOrden."Fecha inicio", 3)) + FORMAT(DATE2DMY(rLinOrden."Fecha inicio", 2)) <> wDiasAux THEN BEGIN
                        if (wDiasAux <> '') THEN BEGIN
                            InsertaLinea(wDescAux);
                            CLEAR(wDescAux);
                        END;
                        wMes := ObtenerMes(rLinOrden."Fecha inicio" - DATE2DMY(rLinOrden."Fecha inicio", 1) + 1);
                        //$014
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
                        InsertaLinea(wDescAux);
                        CLEAR(wDescAux);
                    END;
                END;
            UNTIL rLinOrden.NEXT = 0;
        InsertaLinea(wDescAux);
    END;

    PROCEDURE InsertaLinea(wDescripcion: Text[60]);
    BEGIN
        CLEAR(rLinFra);
        rLinFra."Document Type" := rCabFra."Document Type";
        rLinFra."Document No." := rCabFra."No.";
        wLinea += 10;
        rLinFra."Line No." := wLinea;
        rLinFra.INSERT;
        rLinFra.Type := rLinFra.Type::" ";
        rLinFra.Description := COPYSTR(wDescripcion, 1, 50);
        rLinFra.MODIFY;
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

    PROCEDURE TextoAmpliado();
    VAR
        rTexto: Record "Texto Presupuesto";
    BEGIN
        //$011. Traspaso el texto ampliado a las líneas de detalle del borrador de factura.
        //FCL-05/05/10. Accedo por tarea y nº línea proyecto, no coinciden los nºs de línea de proyecto y contrato.

        rTexto.RESET;
        rTexto.SETRANGE("Nº proyecto", rLin."Job No.");
        rTexto.SETRANGE("Cód. tarea", rLin."Job Task No.");
        if rLin."No linea proyecto" <> 0 THEN BEGIN
            rTexto.SETRANGE("Nº linea aux", rLin."No linea proyecto");
        END ELSE BEGIN
            rTexto.SETRANGE("Nº linea aux", rLin."Line No.");
        END;
        rTexto.SETFILTER("Tipo linea", '%1|%2', rTexto."Tipo linea"::Ambos, rTexto."Tipo linea"::Venta);
        if rTexto.FINDSET THEN
            REPEAT
                if (rTexto.Texto <> '') THEN
                    InsertaLinea(rTexto.Texto);
            UNTIL rTexto.NEXT = 0;
    END;

    PROCEDURE CalcTotalContrato(pCabVenta: Record 36) pPositivo: Boolean;
    VAR
        rCnfVta: Record 311;
        rLinVenta: Record 37;
        SalesLine: Record 37;
        TempSalesLine: Record 37 TEMPORARY;
        TotalSalesLine: Record 37;
        TotalSalesLineLCY: Record 37;
        SalesPost: Codeunit "Sales-Post";
        VATAmountText: Text[30];
        VATAmount: Decimal;
        ProfitLCY: Decimal;
        ProfitPct: Decimal;
        TotalAdjCostLCY: Decimal;
        TotalAmount: Decimal;
    BEGIN
        //$017
        pPositivo := TRUE;

        rCnfVta.GET;
        if rCnfVta."Calc. Inv. Discount" THEN BEGIN
            rLinVenta.RESET;
            rLinVenta.SETRANGE("Document Type", pCabVenta."Document Type");
            rLinVenta.SETRANGE("Document No.", pCabVenta."No.");
            if rLinVenta.FINDFIRST THEN
                CODEUNIT.RUN(CODEUNIT::"Sales-Calc. Discount", rLinVenta);
        END;

        CLEAR(SalesLine);
        CLEAR(TotalSalesLine);
        CLEAR(TotalSalesLineLCY);
        CLEAR(SalesPost);

        SalesPost.GetSalesLines(pCabVenta, TempSalesLine, 0);
        CLEAR(SalesPost);
        SalesPost.SumSalesLinesTemp(
          pCabVenta, TempSalesLine, 0, TotalSalesLine, TotalSalesLineLCY,
          VATAmount, VATAmountText, ProfitLCY, ProfitPct, TotalAdjCostLCY);

        if pCabVenta."Prices Including VAT" THEN BEGIN
            TotalAmount := TotalSalesLine.Amount;
        END ELSE BEGIN
            TotalAmount := TotalSalesLine."Amount Including VAT";
        END;

        if TotalAmount < 0 THEN
            pPositivo := FALSE;
    END;

    PROCEDURE CabeceraPropuesta(pPropuesta: Record "Facturas Propuestas"; pCab: Record 36);
    BEGIN
        //$019. Genero una cabecera en la tabla que utilizaré como temporal

        rCabTemp.INIT;
        rCabTemp."Document Type" := rCabTemp."Document Type"::Invoice;
        // if Strpos(UserId, '\') <> 0 Then
        //     rCabTemp."No." := Copystr('TEMP ' + Copystr(USERID, 11), 1, 20)
        // else
        //     rCabTemp."No." := Copystr('TEMP ' + UserId, 1, MaxStrLen(rCabTemp."No."));
        rCabTemp."No." := 'TEMP';
        rCabTemp."Assigned User ID" := UserId;
        rCabTemp.VALIDATE("Posting Date", pPropuesta."Fecha Factura");
        rCabTemp.VALIDATE("Due Date", pPropuesta."Fecha Vencimiento");
        rCabTemp.VALIDATE("Sell-to Customer No.", pCab."Sell-to Customer No.");
        rCabTemp.VALIDATE("Bill-to Customer No.", pCab."Bill-to Customer No.");
        rCabTemp.VALIDATE("Currency Code", pCab."Currency Code");
        rCabTemp.VALIDATE("Payment Terms Code", pPropuesta."Cód. términos Pago");
        rCabTemp.VALIDATE("Payment Method Code", pPropuesta."Cód. Forma Pago");
        rCabTemp.VALIDATE("Payment Discount %", pCab."Payment Discount %");
        rCabTemp.VALIDATE("Invoice Disc. Code", pCab."Invoice Disc. Code");                       //$026
        rCabTemp.INSERT;
        wLinTemp := 0;
    END;

    PROCEDURE LineaPropuesta(pLin: Record 37; pCantidad: Decimal);
    BEGIN
        //$019. Genero una línea en la tabla que utilizaré como temporal

        rLinTemp.INIT;
        rLinTemp."Document Type" := rLinTemp."Document Type"::Invoice;
        // if Strpos(UserId, '\') <> 0 Then
        //     rLinTemp."Document No." := 'TEMP ' + Copystr(USERID, 11)
        // else
        //     rLinTemp."Document No." := Copystr('TEMP ' + UserId, 1, MaxStrLen(rLinTemp."Document No."));
        rLinTemp."Document No." := 'TEMP';
        wLinTemp := wLinTemp + 1;
        rLinTemp."Line No." := wLinTemp;
        rLinTemp.VALIDATE(Type, pLin.Type);
        rLinTemp.VALIDATE("No.", pLin."No.");
        rLinTemp.VALIDATE("VAT Bus. Posting Group", pLin."VAT Bus. Posting Group");        //$036
        rLinTemp.VALIDATE("VAT Prod. Posting Group", pLin."VAT Prod. Posting Group");      //$036
        rLinTemp.VALIDATE(Quantity, pCantidad);
        rLinTemp.VALIDATE("Unit Price", (pLin."Unit Price") * (1 - pLin."Line Discount %" / 100));
        //rLinTemp.VALIDATE("Line Discount %",pLin."Line Discount %");
        rLinTemp.INSERT;
    END;

    PROCEDURE LineaPropuestaPrep(pPrecio: Decimal);
    VAR
        rConfig: Record 252;
    BEGIN
        //$019. Genero una línea para prepago en la tabla que utilizaré como temporal

        rLinTemp.INIT;
        rLinTemp."Document Type" := rLinTemp."Document Type"::Invoice;
        // if Strpos(UserId, '\') <> 0 Then
        //     rLinTemp."Document No." := 'TEMP ' + Copystr(USERID, 11)
        // else
        //     rLinTemp."Document No." := Copystr('TEMP ' + UserId, 1, MaxStrLen(rLinTemp."No."));
        wLinTemp := wLinTemp + 1;
        rLinTemp."Document No." := 'TEMP';
        rLinTemp."Line No." := wLinTemp;
        rLinTemp.VALIDATE(Type, rLinTemp.Type::"G/L Account");

        rConfig.RESET;                //De momento se coge el primer registro, todos tienen la misma cuenta
        rConfig.FIND('-');
        if rConfig."Sales Prepayments Account" = '' THEN
            ERROR(Text012, rConfig."Gen. Bus. Posting Group", rConfig."Gen. Prod. Posting Group");

        rLinTemp.VALIDATE("No.", rConfig."Sales Prepayments Account");
        rLinTemp."Allow Invoice Disc." := FALSE;
        rLinTemp.VALIDATE(Quantity, -1);
        rLinTemp.VALIDATE("Unit Price", pPrecio);
        rLinTemp.INSERT;
    END;

    PROCEDURE CalcTotalPropuesta(pCabTemp: Record 36; VAR pImporte: Decimal; VAR pImporteIva: Decimal);
    VAR
        rCnfVta: Record 311;
        rLinVenta: Record 37;
        SalesLine: Record 37;
        TempSalesLine: Record 37 TEMPORARY;
        TotalSalesLine: Record 37;
        TotalSalesLineLCY: Record 37;
        SalesPost: Codeunit "Sales-Post";
        VATAmountText: Text[30];
        VATAmount: Decimal;
        ProfitLCY: Decimal;
        ProfitPct: Decimal;
        TotalAdjCostLCY: Decimal;
        TotalAmount: Decimal;
    BEGIN
        //$019

        rCnfVta.GET;
        if rCnfVta."Calc. Inv. Discount" THEN BEGIN
            rLinTemp.RESET;
            rLinTemp.SETRANGE("Document Type", pCabTemp."Document Type");
            rLinTemp.SETRANGE("Document No.", pCabTemp."No.");
            if rLinTemp.FINDFIRST THEN
                CODEUNIT.RUN(CODEUNIT::"Sales-Calc. Discount", rLinTemp);
        END;

        CLEAR(SalesLine);
        CLEAR(TotalSalesLine);
        CLEAR(TotalSalesLineLCY);
        CLEAR(SalesPost);

        SalesPost.GetSalesLines(pCabTemp, TempSalesLine, 0);
        CLEAR(SalesPost);
        SalesPost.SumSalesLinesTemp(
          pCabTemp, TempSalesLine, 0, TotalSalesLine, TotalSalesLineLCY,
          VATAmount, VATAmountText, ProfitLCY, ProfitPct, TotalAdjCostLCY);

        pImporte := TotalSalesLine.Amount;
        pImporteIva := TotalSalesLine."Amount Including VAT";

        rCabTemp.RESET;
        rCabTemp.SETRANGE("Document Type", pCabTemp."Document Type"::Invoice);
        // if Strpos(UserId, '\') <> 0 Then
        //     rCabTemp.Setrange("No.", 'TEMP ' + COPYSTR(UserId, 11))
        // else
        //     rCabTemp.SETRANGE("No.", Copystr('TEMP ' + UserId, 1, MaxStrLen(rCabTemp."No.")));
        rCabTemp.SETRANGE("No.", 'TEMP');
        rCabTemp.SetRange("Assigned User ID", UserId);
        rCabTemp.DELETE(TRUE);
    END;

    local procedure GetPrepmtAccNo(GenBusPostingGroup: Code[20]; GenProdPostingGroup: Code[20]): Code[20]
    var
        GenPostingSetup: Record "General Posting Setup";
    begin
        if (GenBusPostingGroup <> GenPostingSetup."Gen. Bus. Posting Group") or
           (GenProdPostingGroup <> GenPostingSetup."Gen. Prod. Posting Group")
        then
            GenPostingSetup.Get(GenBusPostingGroup, GenProdPostingGroup);
        exit(GenPostingSetup.GetSalesPrepmtAccount());
    end;

    local procedure CalcularUtimaFactura(var rCabFra: Record "Sales Header"; var rPropVto: Record "Facturas Propuestas"; Prepago: Boolean)
    var
        TempSalesLine: Record 37 temporary;
        TotalSalesLine: Record 37;
        TotalSalesLineLCY: Record 37;
        RegisVtas: Codeunit "Sales-Post";
        wDecimal: Decimal;
        wTexto: Text;
        TotCont: Decimal;
        TotContI: Decimal;
        Diff: Decimal;
        DiffI: Decimal;
        SalesLine: Record 37;
        SalesLine2: Record 37;
        LineNo: Integer;
        Gps: Record "General Posting Setup";
        Resource: Record Resource;
        GlAccount: Record "G/L Account";
    begin
        CLEAR(TotalSalesLine);
        CLEAR(TotalSalesLineLCY);
        CLEAR(RegisVtas);
        CLEAR(TempSalesLine);
        RegisVtas.GetSalesLines(rCabFra, TempSalesLine, 0);
        CLEAR(RegisVtas);
        RegisVtas.SumSalesLinesTemp(rCabFra, TempSalesLine, 0, TotalSalesLine, TotalSalesLineLCY,
                                    wDecimal, wTexto, wDecimal, wDecimal, wDecimal);
        TotCont := TotalSalesLineLCY.Amount;
        TotContI := TotalSalesLineLCY."Amount Including VAT";
        //If Abs(TotCont) < 2 then exit;
        If Abs(TotContI - rPropVto."Importe con IVA") > 10 then exit;
        If (TotCont = rPropVto."Importe sin IVA") And (TotContI = rPropVto."Importe con IVA") then exit;
        SalesLine.SetRange("Document Type", rCabFra."Document Type");
        SalesLine.SetRange("Document No.", rCabFra."No.");
        If Prepago then begin
            SalesLine.SetRange(Type, SalesLine.Type::"G/L Account");
            SalesLine.FindLast();
            GlAccount.Get(Salesline."No.");
            Gps.GET(rCabFra."Gen. Bus. Posting Group", GlAccount."Gen. Prod. Posting Group");
            SalesLine.SetRange(Type);
            SalesLine.FindLast();
            LineNo := SalesLine."Line No.";
            SalesLine2 := SalesLine;
            SalesLine2."Line No." := LineNo + 1;
            SalesLine2.Type := SalesLine2.Type::"G/L Account";
            SalesLine2."No." := Gps."Sales Account";
            SalesLine2.Description := '-';
            SalesLine2.Quantity := 1;
            SalesLine2."Unit Price" := rPropVto."Importe sin IVA" - TotCont;
            SalesLine2."Line Discount %" := 0;
            SalesLine2."VAT Base Amount" := rPropVto."Importe sin IVA" - TotCont;
            SalesLine2."Line Amount" := rPropVto."Importe sin IVA" - TotCont;
            SalesLine2.Amount := rPropVto."Importe sin IVA" - TotCont;
            SalesLine2."Amount Including VAT" := rPropVto."Importe con IVA" - TotContI;
            SalesLine2."Inv. Discount Amount" := 0;
            SalesLine2."Gen. Bus. Posting Group" := rCabFra."Gen. Bus. Posting Group";
            SalesLine2."Gen. Prod. Posting Group" := GlAccount."Gen. Prod. Posting Group";
            SalesLine2."VAT Bus. Posting Group" := rCabFra."VAT Bus. Posting Group";
            SalesLine2."VAT Prod. Posting Group" := GlAccount."VAT Prod. Posting Group";
            SalesLine2.INSERT;
        end else begin
            SalesLine.SetRange(Type, SalesLine.Type::Resource);
            If Not SalesLine.FindLast() Then exit;
            Resource.Get(Salesline."No.");
            Gps.GET(rCabFra."Gen. Bus. Posting Group", Resource."Gen. Prod. Posting Group");
            SalesLine.SetRange(Type);
            SalesLine.FindLast();
            LineNo := SalesLine."Line No.";
            SalesLine2 := SalesLine;
            SalesLine2."Line No." := LineNo + 1;
            SalesLine2.Type := SalesLine2.Type::"G/L Account";
            SalesLine2."No." := Gps."Sales Account";
            SalesLine2.Description := '-';
            SalesLine2.Quantity := 1;
            SalesLine2."Unit Price" := rPropVto."Importe sin IVA" - TotCont;
            SalesLine2."Line Discount %" := 0;
            SalesLine2."VAT Base Amount" := rPropVto."Importe sin IVA" - TotCont;
            SalesLine2."Line Amount" := rPropVto."Importe sin IVA" - TotCont;
            SalesLine2.Amount := rPropVto."Importe sin IVA" - TotCont;
            SalesLine2."Amount Including VAT" := rPropVto."Importe con IVA" - TotContI;
            SalesLine2."Inv. Discount Amount" := 0;
            SalesLine2."Gen. Bus. Posting Group" := rCabFra."Gen. Bus. Posting Group";
            SalesLine2."Gen. Prod. Posting Group" := Resource."Gen. Prod. Posting Group";
            SalesLine2."VAT Bus. Posting Group" := rCabFra."VAT Bus. Posting Group";
            SalesLine2."VAT Prod. Posting Group" := Resource."VAT Prod. Posting Group";
            //  SalesLine2.INSERT;
        end;

    end;



    PROCEDURE GenerarBorradorPrepago(VAR pSalesHeader: Record 36;
    pDocumentType: Option Invoice,"Credit Memo"; CompresPrepayment: Boolean;
     PorCentajePrepago: Decimal; Desde: date; Hasta: Date; FECHAR: DATE; i: Integer; NuevoSistema: Boolean)
    VAR
        rCabVenta: Record 36;
        rLinVenta: Record 37;
        SalesSetup: Record 311;
        PaymentTerms: Record 3;
        SalesHeader: Record 36;
        SalesInvHeader: Record 112;
        SalesLine: Record 37;
        PrepmtInvBuffer: Record 461 TEMPORARY;
#pragma warning disable AL0432
        TempVATAmountLine: Record 290 TEMPORARY;
#pragma warning restore AL0432
        //TempDocDim: Record 357 TEMPORARY;
        TempDimBuf: Record 360 TEMPORARY;
        PrepmtInvLine: Record "Prepayment Inv. Line Buffer";
        NoSeriesMgt: Codeunit "No. Series";
        cPrepagoStd: Codeunit "Sales-Post Prepayments";
        Window: Dialog;
        PostingDescription: Text[100];
        PrevLineNo: Integer;
        LineCount: Integer;
        LineNo: Integer;
        rPropVto: Record "Facturas Propuestas";
        wFecVto: Date;
        Text1000: Label 'No hay nada que registrar';
        Text1001: Label 'Creando líneas prepago #2######\';
        Text1002: Label 'Factura,Abono';
        Text1003: Label '"ENTREGA A CUENTA "';
        Text1004: Label '"%1 %2 "';
        Text1005: Label 'Se ha creado el borrador de factura prepago nº %1';
    BEGIN
        //Para esta función me he basado en la codeunit 442, que graba históricos.
        //De momento no generamos abono prepago, no se ha probado.
        //Tener en cuenta que descontamos los importes de prepago aunque no se haya facturado

        SalesHeader := pSalesHeader;

        //WITH SalesHeader DO BEGIN
        SalesHeader.TESTFIELD("Document Type", SalesHeader."Document Type"::Order);
        SalesHeader.TESTFIELD("Sell-to Customer No.");
        SalesHeader.TESTFIELD("Bill-to Customer No.");


        SalesHeader.TESTFIELD("Forma pago prepago");
        SalesHeader.TESTFIELD("Document Date");

        if NOT cPrepagoStd.CheckOpenPrepaymentLines(SalesHeader, pDocumentType) THEN
            if not CompresPrepayment then exit else Error(Text1000);

        CASE pDocumentType OF
            pDocumentType::Invoice:
                BEGIN
                    SalesHeader.TESTFIELD("Prepayment Due Date");
                    SalesHeader.TESTFIELD("Prepmt. Cr. Memo No.", '');
                    if SalesHeader."Prepayment No." = '' THEN
                        SalesHeader.TESTFIELD("Prepayment No. Series");
                END;
            pDocumentType::"Credit Memo":
                BEGIN
                    SalesHeader.TESTFIELD("Prepayment No.", '');
                    if SalesHeader."Prepmt. Cr. Memo No." = '' THEN
                        SalesHeader.TESTFIELD("Prepmt. Cr. Memo No. Series");
                END;
        END;

        Window.OPEN(
          '#1#################################\\' +
          Text1001);
        Window.UPDATE(1, STRSUBSTNO('%1 %2', SELECTSTR(1 + pDocumentType, Text1002), SalesHeader."No."));

        SalesSetup.GET;
        SalesSetup.TESTFIELD("Invoice Nos.");
        SalesSetup.TESTFIELD("Credit Memo Nos.");
        SalesSetup.TESTFIELD("Posted Prepmt. Inv. Nos.");
        ///SalesSetup.TESTFIELD("Posted Prepmt. Cr. Memo Nos.");    de momento no se utilizan los abonos

        // Crear cabecera pedido
        rCabVenta.INIT;
        rCabVenta.TRANSFERFIELDS(SalesHeader);
        if pDocumentType = pDocumentType::Invoice THEN BEGIN
            rCabVenta."Document Type" := rCabVenta."Document Type"::Invoice;
            rCabVenta."No." := GestNoSer.GetNextNo(SalesSetup."Invoice Nos.", fechar, TRUE);
        END
        ELSE BEGIN
            rCabVenta."Document Type" := rCabVenta."Document Type"::"Credit Memo";
            rCabVenta."No." := GestNoSer.GetNextNo(SalesSetup."Credit Memo Nos.", fechar, TRUE);
        END;
        rCabVenta.INSERT(FALSE);

        if pDocumentType = pDocumentType::Invoice THEN BEGIN
            rCabVenta.VALIDATE("No. Series", SalesSetup."Invoice Nos.");
            rCabVenta.VALIDATE("Posting No. Series", SalesSetup."Posted Prepmt. Inv. Nos.");
            rCabVenta.VALIDATE("Prepayment No. Series", SalesSetup."Posted Prepmt. Inv. Nos.");
        END
        ELSE BEGIN
            rCabVenta.VALIDATE("No. Series", SalesSetup."Credit Memo Nos.");
            rCabVenta.VALIDATE("Posting No. Series", SalesSetup."Posted Prepmt. Cr. Memo Nos.");
            rCabVenta.VALIDATE("Prepmt. Cr. Memo No. Series", SalesSetup."Posted Prepmt. Cr. Memo Nos.");
        END;
        rCabVenta.VALIDATE("Shipping No. Series", SalesSetup."Posted Shipment Nos.");
        rCabVenta.VALIDATE("Prepayment No. Series", SalesSetup."Posted Prepmt. Inv. Nos.");
        rCabVenta.VALIDATE("Posting Date", fechar);
        rCabVenta.VALIDATE("Document Date", FECHAR);
        rCabVenta.VALIDATE("Shortcut Dimension 1 Code", SalesHeader."Shortcut Dimension 1 Code");
        rCabVenta.VALIDATE("Shortcut Dimension 2 Code", SalesHeader."Shortcut Dimension 2 Code");
        if NuevoSistema then
            rCabVenta.Validate("Payment Method Code", SalesHeader."Payment Method Code")
        else
            rCabVenta.VALIDATE("Payment Method Code", SalesHeader."Forma pago prepago");
        if NuevoSistema then
            rCabVenta.Validate("Payment Terms Code", SalesHeader."Payment Terms Code")
        else
            rCabVenta.VALIDATE("Payment Terms Code", SalesHeader."Prepmt. Payment Terms Code");

        if i <> 0 Then begin
            rPropVto.RESET;
            rPropVto.SETRANGE("No. Contrato", SalesHeader."No.");
            rPropVto.SETRANGE(rPropVto."No. linea", i);               //números de línea están grabados de 1 en 1
            if rPropVto.FIND('-') THEN
                wFecVto := rPropVto."Fecha Vencimiento";
            if (rCabVenta."Due Date" <> wFecVto) AND (wFecVto <> 0D) THEN
                rCabVenta.VALIDATE("Due Date", wFecVto);
            if rPropVto.FIND('-') THEN
                rCabFra."Línea Borrador" := i;
            if rPropVto."Customer Order No." <> '' THEN
                rCabFra.VALIDATE("Customer Order No.", rPropVto."Customer Order No.");
        end else
            rCabVenta.VALIDATE("Due Date", SalesHeader."Prepayment Due Date");
        rCabVenta.VALIDATE("Pmt. Discount Date", SalesHeader."Prepmt. Pmt. Discount Date");
        rCabVenta.VALIDATE("Payment Discount %", SalesHeader."Prepmt. Payment Discount %");
        rCabVenta.VALIDATE("Invoice Disc. Code", SalesHeader."Invoice Disc. Code");                         //$026
        rCabVenta.VALIDATE("Nº Contrato", SalesHeader."No.");
        rCabVenta.VALIDATE("Factura prepago", TRUE);
        rCabVenta.VALIDATE("Nº pedido prepago", SalesHeader."No.");
        if pDocumentType = pDocumentType::"Credit Memo" THEN BEGIN
            if SalesHeader."Prepmt. Payment Terms Code" <> '' THEN BEGIN
                PaymentTerms.GET(SalesHeader."Prepmt. Payment Terms Code");
                if NOT PaymentTerms."Calc. Pmt. Disc. on Cr. Memos" THEN BEGIN
                    rCabVenta."Payment Discount %" := 0;
                    rCabVenta."Pmt. Discount Date" := 0D;
                END;
            END;
        END;
        if SalesHeader."Prepmt. Posting Description" <> '' THEN
            rCabVenta.VALIDATE("Posting Description", SalesHeader."Prepmt. Posting Description")
        ELSE
            rCabVenta.VALIDATE("Posting Description", Text1003);
        rCabVenta."Nuestra Cuenta" := SalesHeader."Nuestra Cuenta Prepago";
        if (Desde <> 0D) and (Hasta <> 0D) then begin
            rCabVenta.VALIDATE("Posting Description", Format(Desde, 0, '<Day,2>/<Month,2>/<Year>') + ' - ' + Format(Hasta, 0, '<Day,2>/<Month,2>/<Year>'));
        end;
        if SalesHeader."Nuestra Cuenta Prepago" = '' Then SalesHeader."Nuestra Cuenta Prepago" := SalesHeader."Nuestra Cuenta";
        rCabVenta."Nuestra Cuenta Prepago" := SalesHeader."Nuestra Cuenta Prepago";
        OnAfterGenerateBorradorPrepago(rCabVenta, SalesHeader);
        if rCabVenta."Factura prepago" then
            rCabVenta."B2R Bank Payment Code" := SalesHeader."Nuestra Cuenta Prepago";

        //Revisar líneas
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        If Not NuevoSistema then begin
            SalesLine.SetRange(Reparto, SalesLine.Reparto::"Fra prepago");
            SalesLine.ModifyAll("Prepmt. Line Amount", 0);
            SalesLine.ModifyAll("Prepmt. Amt. Inv.", 0);
            SalesLine.SetRange(Reparto);
        end;
        SalesLine.SetFilter(Quantity, '<>%1', 0);
        SalesLine.SetFilter("Prepayment %", '<>%1', 100);
        if not SalesLine.FindFirst() Then begin
            SalesHeader."Compress Prepayment" := false;
            SalesHeader.Modify();
            rCabVenta."Compress Prepayment" := false;
        end;
        If NuevoSistema then
            SalesLine.SetFilter(Reparto, '<>%1', SalesLine.Reparto::"Fra prepago");
        if Not CompresPrepayment then rCabVenta."Compress Prepayment" := false;
        SalesLine.Reset();
        /// 
        if SalesHeader."Compress Prepayment" Then begin
            SalesInvHeader.SetRange("Nº Contrato", SalesHeader."No.");

            if SalesInvHeader.FindFirst() then SalesHeader.Validate("Compress Prepayment", false);
        end;
        if NuevoSistema then rcabventa."Prepago Nuevo" := true;
        rCabVenta.MODIFY(FALSE);

        Window.UPDATE(1, STRSUBSTNO(Text1004, SalesHeader."Document Type", SalesHeader."No."));

        // Crear líneas pedido
        if rCabVenta."Compress Prepayment" = false then begin
            PrepmtInvBuffer.DELETEALL;

            cPrepagoStd.CalcVATAmountLines(SalesHeader, SalesLine, TempVATAmountLine, pDocumentType);
            cPrepagoStd.UpdateVATOnLines(SalesHeader, SalesLine, TempVATAmountLine, pDocumentType);
            cPrepagoStd.BuildInvLineBuffer(
              SalesHeader, SalesLine, pDocumentType, PrepmtInvBuffer);
            SalesLine.RESET;
            if NuevoSistema then SalesLine.SetFilter(Reparto, '<>%1', SalesLine.Reparto::"Fra prepago");
            SalesLine.SetRange("Document No.", SalesHeader."No.");
            SalesLine.SetRange("Document Type", SalesHeader."Document Type");

            if SalesLine.FindFirst() Then
                repeat
                    rLinVenta.Init;
                    rLinVenta."Document Type" := rCabVenta."Document Type";
                    rLinVenta."Document No." := rCabVenta."No.";
                    rLinVenta."Line No." := SalesLine."Line No.";
                    rLinVenta.INSERT;
                    rLinVenta."Gen. Bus. Posting Group" := salesLine."Gen. Bus. Posting Group";
                    rLinVenta."Gen. Prod. Posting Group" := salesLine."Gen. Prod. Posting Group";
                    rLinVenta."VAT Bus. Posting Group" := salesLine."VAT Bus. Posting Group";
                    rLinVenta."VAT Prod. Posting Group" := salesLine."VAT Prod. Posting Group";
                    rLinVenta.Type := SalesLine.Type;
                    rLinVenta."Customer Order No." := SalesLine."Customer Order No.";
                    if rLinVenta.Type <> rLinVenta.Type::" " then begin
                        rLinVenta.Type := rLinVenta.Type::"G/L Account";
                        rLinVenta."No." := GetPrepmtAccNo(rLinVenta."Gen. Bus. Posting Group", rLinVenta."Gen. Prod. Posting Group");
                        rLinVenta.VALIDATE("Sell-to Customer No.", rCabVenta."Sell-to Customer No.");
                    end;
                    If Strpos(SalesLine.Description, 'INGRESOS ANTICIPADOS') <> 0 then SalesLine.Description := StrSubstNo('%1 %2', 'ENTREGA A CUENTA', SalesHeader."No.");
                    rLinVenta.Description := SalesLine.Description;
                    rLinVenta."Description 2" := SalesLine."Description 2";
                    if SalesLine.Type <> SalesLine.Type::" " then begin

                        //rLinVenta.VALIDATE("Shortcut Dimension 1 Code", );                   Cogeremos las dimensiones de la cuenta
                        //rLinVenta.VALIDATE("Shortcut Dimension 2 Code", );
                        if PorCentajePrepago <> 0 Then
                            rLinVenta.VALIDATE(Quantity, SalesLine.Quantity * PorCentajePrepago / 100)
                        Else
                            rLinVenta.VALIDATE(Quantity, SalesLine.Quantity);

                        rLinVenta.VALIDATE("Unit Price", SalesLine."Unit Price");
                        if PorCentajePrepago <> 0 Then
                            rLinVenta.VALIDATE("Line Amount", SalesLine."Line Amount" * PorCentajePrepago / 100)
                        Else
                            rLinVenta.VALIDATE("Line Amount", SalesLine."Line Amount");
                        rLinVenta."Precio Compra" := SalesLine."Precio Compra";
                        rLinVenta."Gen. Bus. Posting Group" := salesLine."Gen. Bus. Posting Group";
                        rLinVenta."Gen. Prod. Posting Group" := salesLine."Gen. Prod. Posting Group";
                        rLinVenta."VAT Bus. Posting Group" := salesLine."VAT Bus. Posting Group";
                        rLinVenta."VAT Prod. Posting Group" := salesLine."VAT Prod. Posting Group";
                        rLinVenta."VAT %" := salesLine."VAT %";
                        rLinVenta."VAT Identifier" := SalesLine."VAT Identifier";
                    end;
                    rLinVenta.MODIFY;


                until SalesLine.Next() = 0;
        end else begin
            PrepmtInvBuffer.DELETEALL;
            If NuevoSistema then SalesLine.SetFilter(Reparto, '<>%1', SalesLine.Reparto::"Fra prepago");
            cPrepagoStd.CalcVATAmountLines(SalesHeader, SalesLine, TempVATAmountLine, pDocumentType);
            cPrepagoStd.UpdateVATOnLines(SalesHeader, SalesLine, TempVATAmountLine, pDocumentType);

            cPrepagoStd.BuildInvLineBuffer(
              SalesHeader, SalesLine, pDocumentType, PrepmtInvBuffer);

            PrepmtInvBuffer.FIND('-');
            if PrepmtInvBuffer."Line No." <> 0 THEN
                LineNo := PrevLineNo + PrepmtInvBuffer."Line No."
            ELSE
                LineNo := PrevLineNo + 10000;
            TempDimBuf.INIT;
            REPEAT
                LineCount := LineCount + 1;
                Window.UPDATE(2, LineCount);

                rLinVenta.INIT;
                rLinVenta."Document Type" := rCabVenta."Document Type";
                rLinVenta."Document No." := rCabVenta."No.";
                rLinVenta."Line No." := LineNo;
                LineNo += 10000;
                rLinVenta."Customer Order No." := SalesLine."Customer Order No.";
                rLinVenta.INSERT;
                rLinVenta.VALIDATE("Sell-to Customer No.", rCabVenta."Sell-to Customer No.");
                rLinVenta.VALIDATE(Type, rLinVenta.Type::"G/L Account");
                rLinVenta.VALIDATE("No.", PrepmtInvBuffer."G/L Account No.");
                rLinVenta.VALIDATE(Description, PrepmtInvBuffer.Description);
                rLinVenta.Description := StrSubstNo('%1 %2', 'ENTREGA A CUENTA', SalesHeader."No.");
                //rLinVenta.VALIDATE("Shortcut Dimension 1 Code", );                   Cogeremos las dimensiones de la cuenta
                //rLinVenta.VALIDATE("Shortcut Dimension 2 Code", );
                rLinVenta.VALIDATE(Quantity, 1);
                if SalesHeader."Prices Including VAT" THEN BEGIN
                    rLinVenta.VALIDATE("Unit Price", PrepmtInvBuffer."Amount Incl. VAT");
                    rLinVenta.VALIDATE("Line Amount", PrepmtInvBuffer."Amount Incl. VAT");
                END ELSE BEGIN
                    rLinVenta.VALIDATE("Unit Price", PrepmtInvBuffer.Amount);
                    rLinVenta.VALIDATE("Line Amount", PrepmtInvBuffer.Amount);
                END;
                if SalesLine.Get(rCabVenta."Document Type", rCabVenta."No.", PrepmtInvBuffer."Line No.") Then
                    if SalesLine."Line Amount" <> 0 then
                        rLinVenta."Precio Compra" := SalesLine."Precio Compra" * (PrepmtInvBuffer.Amount / SalesLine."Line Amount");
                rLinVenta."Gen. Bus. Posting Group" := PrepmtInvBuffer."Gen. Bus. Posting Group";
                rLinVenta."Gen. Prod. Posting Group" := PrepmtInvBuffer."Gen. Prod. Posting Group";
                rLinVenta."VAT Bus. Posting Group" := PrepmtInvBuffer."VAT Bus. Posting Group";
                rLinVenta."VAT Prod. Posting Group" := PrepmtInvBuffer."VAT Prod. Posting Group";
                rLinVenta."VAT %" := PrepmtInvBuffer."VAT %";
                rLinVenta.Amount := PrepmtInvBuffer.Amount;
                rLinVenta."Amount Including VAT" := PrepmtInvBuffer."Amount Incl. VAT";
                rLinVenta."VAT Calculation Type" := PrepmtInvBuffer."VAT Calculation Type";
                rLinVenta."VAT Base Amount" := PrepmtInvBuffer."VAT Base Amount";
                rLinVenta."VAT Identifier" := PrepmtInvBuffer."VAT Identifier";
                rLinVenta.Description := StrSubstNo('%1 %2', 'ENTREGA A CUENTA', SalesHeader."No.");
                rLinVenta.MODIFY;

            UNTIL PrepmtInvBuffer.NEXT = 0;
        end;
        // Update lines & header
        SalesLine.RESET;
        SalesLine.SETRANGE("Document Type", SalesHeader."Document Type");
        SalesLine.SETRANGE("Document No.", SalesHeader."No.");
        if pDocumentType = pDocumentType::Invoice THEN BEGIN
            SalesLine.SETFILTER("Prepmt. Line Amount", '<>0');
            if SalesLine.FIND('-') THEN
                REPEAT
                    if SalesLine."Prepmt. Line Amount" <> SalesLine."Prepmt. Amt. Inv." THEN BEGIN
                        SalesLine."Prepmt. Amt. Inv." := SalesLine."Prepmt. Line Amount";
                        SalesLine."Prepmt. Amount Inv. Incl. VAT" := SalesLine."Prepmt. Amt. Incl. VAT";
                        SalesLine."Prepmt Amt to Deduct" :=
                          SalesLine."Prepmt. Amt. Inv." - SalesLine."Prepmt Amt Deducted";
                        SalesLine.MODIFY;
                    END;
                UNTIL SalesLine.NEXT = 0;
        END ELSE BEGIN
            SalesLine.SETFILTER("Prepmt. Amt. Inv.", '<>0');
            if SalesLine.FIND('-') THEN
                REPEAT
                    SalesLine."Prepmt. Amt. Inv." := SalesLine."Prepmt Amt Deducted";
                    SalesLine."Prepmt. Amount Inv. Incl. VAT" :=
                      SalesLine."Prepmt. Amt. Inv." + SalesLine."Prepmt. Amt. Inv." * SalesLine."Prepayment VAT %" / 100;
                    SalesLine."Prepmt Amt to Deduct" := 0;
                    SalesLine.MODIFY;
                UNTIL SalesLine.NEXT = 0;
        END;
        if SalesHeader.Status <> SalesHeader.Status::"Pending Prepayment" THEN
            SalesHeader.Status := SalesHeader.Status::"Pending Prepayment";
        SalesHeader.MODIFY;
        //END;
        If Not NuevoSistema then
            AñadirLineasPrepago(SalesHeader, pDocumentType, rCabVenta."No.", LineNo);                                        //$025

        pSalesHeader := SalesHeader;

        if i = 0 Then MESSAGE(Text1005, rCabVenta."No.");
        if rCabVenta."Remesa sin factura" THEN               //$035, sustituyo rCab por rCabFra
            cGesCartera.CrearDocCartera(rCabVenta, i, wBucle);
        If i = wBucle Then begin
            rPropVto.FindLast();
            CalcularUtimaFactura(rCabVenta, rPropVto, true);
        end;
    END;

    PROCEDURE AñadirLineasPrepago(pSalesHeader: Record 36; pDocumentType: Option Invoice,"Credit Memo"; pDocumentNo: Code[20]; pLinea: Integer);
    VAR
        rLinVenta: Record 37;
    BEGIN
        //$025

        rLin.RESET;
        rLin.SETRANGE("Document Type", pSalesHeader."Document Type");
        rLin.SETRANGE("Document No.", pSalesHeader."No.");
        rLin.SETRANGE(Reparto, rLin.Reparto::"Fra prepago");
        if rLin.FIND('-') THEN BEGIN
            REPEAT
                rLinVenta.INIT;
                if pDocumentType = pDocumentType::Invoice THEN BEGIN
                    rLinVenta."Document Type" := rLinVenta."Document Type"::Invoice;
                END
                ELSE BEGIN
                    rLinVenta."Document Type" := rLinVenta."Document Type"::"Credit Memo";
                END;
                rLinVenta."Document No." := pDocumentNo;
                repeat
                    rLinVenta."Line No." := pLinea;
                    pLinea := pLinea + 10000;
                Until rLinVenta.INSERT;
                rLinVenta."Customer Order No." := rLin."Customer Order No.";
                rLinVenta.VALIDATE("Sell-to Customer No.", pSalesHeader."Sell-to Customer No.");
                rLinVenta.VALIDATE(Type, rLin.Type);
                rLinVenta.VALIDATE("No.", rLin."No.");
                rLinVenta.VALIDATE(Description, rLin.Description);
                rLinVenta.VALIDATE("Description 2", rLin."Description 2");
                if (rLin.Type.AsInteger() <> 0) THEN BEGIN
                    rLin.TESTFIELD("Shortcut Dimension 1 Code");
                    rLin.TESTFIELD("Shortcut Dimension 2 Code");
                END;
                rLinVenta.VALIDATE("Shortcut Dimension 1 Code", rLin."Shortcut Dimension 1 Code");
                rLinVenta.VALIDATE("Shortcut Dimension 2 Code", rLin."Shortcut Dimension 2 Code");
                rLinVenta.VALIDATE("Shortcut Dimension 3 Code", rLin."Shortcut Dimension 3 Code");
                rLinVenta.VALIDATE("Shortcut Dimension 4 Code", rLin."Shortcut Dimension 4 Code");
                rLinVenta.VALIDATE("Shortcut Dimension 5 Code", rLin."Shortcut Dimension 5 Code");

                if rLin.Type.AsInteger() <> 0 THEN BEGIN                   //$037, las líneas siguientes dan error si es tipo comentario
                    rLinVenta.VALIDATE(Quantity, rLin.Quantity);
                    rLinVenta.VALIDATE("Unit Price", rLin."Unit Price");
                    rLinVenta.VALIDATE("Line Discount %", rLin."Line Discount %");
                    rLinVenta."Precio Compra" := rLin."Precio Compra";
                END;                                           //$037
                rLinVenta.VALIDATE("Job No.", rLin."Job No.");
                rLinVenta.VALIDATE("Job Task No.", rLin."Job Task No.");
                rLinVenta.VALIDATE("No linea proyecto", rLin."No linea proyecto");
                rLinVenta."Fecha inicial recurso" := rLin."Fecha inicial recurso";
                rLinVenta."Fecha final recurso" := rLin."Fecha final recurso";
                rLinVenta.VALIDATE("Imprimir fecha recurso", rLin."Imprimir fecha recurso");
                rLinVenta.MODIFY;
            UNTIL rLin.NEXT = 0;
        END;

    END;

    PROCEDURE TotalLineasRep(pTipDoc: Option Quote,Order,Invoice,"Credit Memo","Blanket Order","Return Order"; pNumDoc: Code[20]) pImporte: Decimal;
    VAR
        rLinVenta: Record 37;
    BEGIN
        //$025
        //Calculo el total de las líneas para descontar el prepago.

        pImporte := 0;
        rLinVenta.RESET;
        rLinVenta.SETRANGE("Document Type", pTipDoc);
        rLinVenta.SETRANGE("Document No.", pNumDoc);
        rLinVenta.SETFILTER(Reparto, '<>%1', rLinVenta.Reparto::"Fra prepago");
        if rLinVenta.FINDSET THEN BEGIN
            REPEAT
                pImporte := pImporte + rLinVenta."Line Amount";
            UNTIL rLinVenta.NEXT = 0;
        END;
    END;

    PROCEDURE TotalLineasRepCost(pTipDoc: Option Quote,Order,Invoice,"Credit Memo","Blanket Order","Return Order"; pNumDoc: Code[20]) pImporte: Decimal;
    VAR
        rLinVenta: Record 37;
    BEGIN
        //$025
        //Calculo el total de las líneas para descontar el prepago.

        pImporte := 0;
        rLinVenta.RESET;
        rLinVenta.SETRANGE("Document Type", pTipDoc);
        rLinVenta.SETRANGE("Document No.", pNumDoc);
        rLinVenta.SETFILTER(Reparto, '<>%1', rLinVenta.Reparto::"Fra prepago");
        if rLinVenta.FINDSET THEN BEGIN
            REPEAT
                pImporte := pImporte + rLinVenta."Precio Compra";
            UNTIL rLinVenta.NEXT = 0;
        END;
    END;

    PROCEDURE TotalLineasRepFac(pNumDoc: Code[20]) pImporte: Decimal;
    VAR
        rLinVenta: Record 113;
    BEGIN
        //$025
        //Calculo el total de las líneas para descontar el prepago.

        pImporte := 0;
        rLinVenta.RESET;
        //rLinVenta.SETRANGE("Document Type",pTipDoc);
        rLinVenta.SETRANGE("Document No.", pNumDoc);
        rLinVenta.SETFILTER("No.", '%1', '485*');
        if rLinVenta.FINDSET THEN BEGIN
            REPEAT
                //if rLinVenta."Line Amount"<0 THEN
                pImporte := pImporte + rLinVenta."Line Amount";
            UNTIL rLinVenta.NEXT = 0;
        END;
    END;

    PROCEDURE GeneraContrasientoprepago(VAR rCab: Record 36; Fecha: Date);
    VAR
        GenJnlLine: Record "Gen. Journal Line";
        //TempJnlLineDim: Record 356;
        //TempDocDim: Record 357 TEMPORARY;
        GenJnlCheckLine: Codeunit 11;
        GenJnlPostLine: Codeunit 12;
        //rDefDim: Record 357;
        rLin: Record 37;
        i: Integer;
        l: Integer;
        rConfig: Record 252;
        DimMgt: Codeunit 408;
        r252: Record 252;
        Cuenta: Code[20];
        suma: Decimal;
        rCabFra: Record 112;
        rCabAbo: Record 114;
        TempSalesLine: Record 37 TEMPORARY;
        SalesPostPrepmt: Codeunit "Sales-Post Prepayments";
        PrepmtTotalAmount: Decimal;
        PrepmtVATAmount: Decimal;
        PrepmtVATAmountText: Text[30];
#pragma warning disable AL0432
        TempVATAmountLine4: Record 290;
#pragma warning restore AL0432
        wTotFra1: Decimal;
        rPropuestas: Record "Facturas Propuestas";
    BEGIN
        CLEAR(suma);
        CLEAR(wImpPrepago);
        CLEAR(wTotLinFac);
        rConfig.RESET;
        rConfig.FIND('-');
        wImpPrepago := 0;
        TempSalesLine.DELETEALL;
        CLEAR(TempSalesLine);
        SalesPostPrepmt.GetSalesLines(rCab, 0, TempSalesLine);
        SalesPostPrepmt.SumPrepmt(
          rCab, TempSalesLine, TempVATAmountLine4, PrepmtTotalAmount, PrepmtVATAmount, PrepmtVATAmountText);
        wTotFra1 := 0;
        rPropuestas.SETRANGE("No. Contrato", rCab."No.");
        rPropuestas.SETRANGE("Factura 1", TRUE);
        if rPropuestas.FINDSET THEN
            REPEAT
                wTotFra1 += rPropuestas."Importe con IVA";
            UNTIL rPropuestas.NEXT = 0;

        rLin.RESET;
        rLin.SETRANGE("Document Type", rCab."Document Type");
        rLin.SETRANGE("Document No.", rCab."No.");
        rLin.SETRANGE(Reparto, rLin.Reparto::"Fra prepago");
        if rLin.FINDSET THEN BEGIN
            REPEAT
                wImpPrepago := wImpPrepago + rLin."Line Amount";
                wImpPrepago := wImpPrepago + ROUND(rLin."Line Amount" * rLin."VAT %" / 100);
            UNTIL rLin.NEXT = 0;
        END;
        wImpPrepago := PrepmtTotalAmount + PrepmtVATAmount + wImpPrepago + wTotFra1;
        if wImpPrepago = 0 THEN EXIT;
        rCabFra.SETRANGE(rCabFra."Nº Contrato", rCab."No.");
        if rCabFra.FINDFIRST THEN
            REPEAT
                wTotLinFac += TotalLineasRepFac(rCabFra."No.");
            UNTIL rCabFra.NEXT = 0;
        rCabAbo.SETRANGE(rCabAbo."Nº Contrato", rCab."No.");
        if rCabAbo.FINDFIRST THEN
            REPEAT
                wTotLinFac += TotalLineasRepAbo(rCabAbo."No.");
            UNTIL rCabAbo.NEXT = 0;

        //$025(F)
        rLin.RESET;
        rLin.SETRANGE("Document Type", rCab."Document Type");
        rLin.SETRANGE("Document No.", rCab."No.");

        if wTotLinFac <> 0 THEN BEGIN

            wImpPrepago2 := -wTotLinFac;

            GenJnlLine.SETRANGE(GenJnlLine."Journal Template Name", 'GENERAL');
            GenJnlLine.SETRANGE(GenJnlLine."Journal Batch Name", 'DIFCONTRA');
            if NOT GenJnlLine.FINDLAST THEN
                l := 10000
            ELSE
                l := GenJnlLine."Line No." + 10000;
            GenJnlLine."Line No." := l;
            GenJnlLine."Journal Template Name" := 'GENERAL';
            GenJnlLine."Journal Batch Name" := 'DIFCONTRA';
            GenJnlLine."Document Type" := GenJnlLine."Document Type"::" ";
            GenJnlLine."Posting Date" := Fecha;
            GenJnlLine."Document Date" := Fecha;
            GenJnlLine.Description := 'Anulación Prepago Contrato';
            GenJnlLine."Shortcut Dimension 1 Code" := '';
            GenJnlLine."Shortcut Dimension 2 Code" := '';
            GenJnlLine."Reason Code" := '';
            GenJnlLine."Account Type" := GenJnlLine."Account Type"::"G/L Account";
            GenJnlLine."Account No." := rConfig."Sales Prepayments Account";
            GenJnlLine."Document No." := rCab."No.";
            GenJnlLine.Amount := wImpPrepago2;
            GenJnlLine."Source Currency Amount" := wImpPrepago2;
            GenJnlLine."Amount (LCY)" := wImpPrepago2;
            GenJnlLine."Currency Factor" := 1;
            GenJnlLine."Sales/Purch. (LCY)" := 0;
            GenJnlLine."Inv. Discount (LCY)" := 0;
            GenJnlLine."Pmt. Discount Given/Rec. (LCY)" := 0;
            GenJnlLine."Sell-to/Buy-from No." := rCab."Sell-to Customer No.";
            GenJnlLine."Bill-to/Pay-to No." := rCab."Bill-to Customer No.";
            GenJnlLine."Salespers./Purch. Code" := rCab."Salesperson Code";
            GenJnlLine."System-Created Entry" := TRUE;
            GenJnlLine."On Hold" := '';
            GenJnlLine."Applies-to Doc. Type" := GenJnlLine."Applies-to Doc. Type"::" ";
            GenJnlLine."Applies-to Bill No." := '';
            GenJnlLine."Applies-to Doc. No." := '';
            GenJnlLine."Applies-to ID" := '';
            GenJnlLine."Payment Terms Code" := '';
            GenJnlLine."Payment Method Code" := '';
            // GenJnlLine."Pmt. Address Code" := '';
            //GenJnlLine."Cust./Vendor Bank Acc. Code" := '';
            GenJnlLine."Due Date" := 0D;
            GenJnlLine."Payment Discount %" := 0;
            GenJnlLine."Source Type" := GenJnlLine."Source Type"::Customer;
            GenJnlLine."Source No." := rCab."Bill-to Customer No.";
            GenJnlLine."Source Code" := 'VENTAS';
            GenJnlLine."Posting No. Series" := '';
            GenJnlLine."IC Partner Code" := '';//"Pay-to IC Partner Code";
            GenJnlLine."Generate AutoInvoices" := FALSE;//"Generate Autoinvoices" OR "Generate Autocredit Memo";
            GenJnlLine."AutoDoc. No." := '';
            GenJnlLine."Gen. Posting Type" := GenJnlLine."Gen. Posting Type"::" ";
            GenJnlLine."Gen. Bus. Posting Group" := '';
            GenJnlLine."Gen. Prod. Posting Group" := '';
            GenJnlLine."VAT Bus. Posting Group" := '';
            GenJnlLine."VAT Prod. Posting Group" := '';
            GenJnlLine."Periodo de Pago" := '';
            GenJnlLine.Validate("Shortcut Dimension 1 Code", rCab."Shortcut Dimension 1 Code");
            GenJnlLine.Validate("Shortcut Dimension 2 Code", rCab."Shortcut Dimension 2 Code");
            GenJnlLine.Validate("Shortcut Dimension 3 Code", rCab."Shortcut Dimension 3 Code");
            GenJnlLine.Validate("Shortcut Dimension 4 Code", rCab."Shortcut Dimension 4 Code");
            GenJnlLine.Validate("Shortcut Dimension 5 Code", rCab."Shortcut Dimension 5 Code");

            GenJnlLine.INSERT;
            //Revisar
            /* TempJnlLineDim.SETRANGE(TempJnlLineDim."Table ID", 81);
            TempJnlLineDim.SETRANGE(TempJnlLineDim."Journal Template Name", 'GENERAL');
            TempJnlLineDim.SETRANGE(TempJnlLineDim."Journal Batch Name", 'DIFCONTRA');
            TempJnlLineDim.SETRANGE(TempJnlLineDim."Journal Line No.", l);
            TempDocDim.RESET;
            TempDocDim.SETRANGE("Table ID", 36);
            TempDocDim.SETRANGE(TempDocDim."Document Type", TempDocDim."Document Type"::Order);
            TempDocDim.SETRANGE(TempDocDim."Document No.", rCab."No.");
            if TempDocDim.FINDFIRST THEN
                REPEAT
                    TempJnlLineDim."Table ID" := 81;
                    TempJnlLineDim."Journal Template Name" := 'GENERAL';
                    TempJnlLineDim."Journal Batch Name" := 'DIFCONTRA';
                    TempJnlLineDim."Journal Line No." := l;
                    TempJnlLineDim."Dimension Code" := TempDocDim."Dimension Code";
                    TempJnlLineDim."Dimension Value Code" := TempDocDim."Dimension Value Code";
                    TempJnlLineDim.INSERT;
                UNTIL TempDocDim.NEXT = 0; */

            //GenJnlPostLine.RunWithCheck(GenJnlLine,TempJnlLineDim);
            rLin.SETFILTER(rLin."Prepayment Amount", '<>%1', 0);
            if rLin.FINDFIRST THEN
                REPEAT
                    l := l + 10000;
                    GenJnlLine.INIT;
                    GenJnlLine."Line No." := l;
                    GenJnlLine."Document No." := rCab."No.";
                    GenJnlLine."Journal Template Name" := 'GENERAL';
                    GenJnlLine."Journal Batch Name" := 'DIFCONTRA';
                    GenJnlLine."Document Type" := GenJnlLine."Document Type"::" ";
                    GenJnlLine."Posting Date" := Fecha;
                    GenJnlLine."Document Date" := Fecha;
                    GenJnlLine.Description := 'Anulación Prepago Contrato';
                    GenJnlLine."Shortcut Dimension 1 Code" := rLin."Shortcut Dimension 1 Code";
                    GenJnlLine."Shortcut Dimension 2 Code" := rLin."Shortcut Dimension 2 Code";
                    GenJnlLine."Shortcut Dimension 3 Code" := rLin."Shortcut Dimension 3 Code";
                    GenJnlLine."Shortcut Dimension 4 Code" := rLin."Shortcut Dimension 4 Code";
                    GenJnlLine."Shortcut Dimension 5 Code" := rLin."Shortcut Dimension 5 Code";

                    GenJnlLine."Reason Code" := '';
                    GenJnlLine."Account Type" := GenJnlLine."Account Type"::"G/L Account";
                    Cuenta := rLin."No.";
                    if rLin.Type IN [rLin.Type::Resource, rLin.Type::Item] THEN BEGIN
                        r252.GET(rLin."Gen. Bus. Posting Group", rLin."Gen. Prod. Posting Group");
                        Cuenta := r252."Sales Account";
                    END;
                    GenJnlLine."Account No." := Cuenta;
                    GenJnlLine.Amount := -(wImpPrepago2 / wImpPrepago * rLin."Prepmt. Line Amount");
                    suma := suma + (wImpPrepago2 / wImpPrepago * rLin."Prepmt. Line Amount");
                    GenJnlLine."Source Currency Amount" := -(wImpPrepago2 / wImpPrepago * rLin."Prepmt. Line Amount");
                    GenJnlLine."Amount (LCY)" := -(wImpPrepago2 / wImpPrepago * rLin."Prepmt. Line Amount");
                    GenJnlLine."Currency Factor" := 1;
                    GenJnlLine."Sales/Purch. (LCY)" := -(wImpPrepago2 / wImpPrepago * rLin."Prepmt. Line Amount");
                    GenJnlLine."Inv. Discount (LCY)" := 0;
                    GenJnlLine."Pmt. Discount Given/Rec. (LCY)" := 0;
                    GenJnlLine."Sell-to/Buy-from No." := rCab."Sell-to Customer No.";
                    GenJnlLine."Bill-to/Pay-to No." := rCab."Bill-to Customer No.";
                    GenJnlLine."Salespers./Purch. Code" := rCab."Salesperson Code";
                    GenJnlLine."System-Created Entry" := TRUE;
                    GenJnlLine."On Hold" := '';
                    GenJnlLine."Applies-to Doc. Type" := GenJnlLine."Applies-to Doc. Type"::" ";
                    GenJnlLine."Applies-to Bill No." := '';
                    GenJnlLine."Applies-to Doc. No." := '';
                    GenJnlLine."Applies-to ID" := '';
                    GenJnlLine."Payment Terms Code" := '';
                    GenJnlLine."Payment Method Code" := '';
                    //GenJnlLine."Pmt. Address Code" := '';
                    //GenJnlLine."Cust./Vendor Bank Acc. Code" := '';
                    GenJnlLine."Due Date" := 0D;
                    GenJnlLine."Payment Discount %" := 0;
                    GenJnlLine."Source Type" := GenJnlLine."Source Type"::Customer;
                    GenJnlLine."Source No." := rCab."Bill-to Customer No.";
                    GenJnlLine."Source Code" := 'VENTAS';
                    GenJnlLine."Posting No. Series" := '';
                    GenJnlLine."IC Partner Code" := '';//"Pay-to IC Partner Code";
                    GenJnlLine."Generate AutoInvoices" := FALSE;//"Generate Autoinvoices" OR "Generate Autocredit Memo";
                    GenJnlLine."AutoDoc. No." := '';
                    GenJnlLine."External Document No." := '';
                    GenJnlLine."Gen. Posting Type" := GenJnlLine."Gen. Posting Type"::" ";
                    GenJnlLine."Gen. Bus. Posting Group" := '';
                    GenJnlLine."Gen. Prod. Posting Group" := '';
                    GenJnlLine."VAT Bus. Posting Group" := '';
                    GenJnlLine."VAT Prod. Posting Group" := '';
                    GenJnlLine."Periodo de Pago" := '';
                    /* //Revisar
                    rDefDim.RESET;
                    rDefDim.SETRANGE("Table ID", 37);
                    rDefDim.SETRANGE(rDefDim."Document No.", rLin."Document No.");
                    rDefDim.SETRANGE(rDefDim."Document Type", rDefDim."Document Type"::Order);
                    rDefDim.SETRANGE(rDefDim."Line No.", rLin."Line No.");
                    TempJnlLineDim.SETRANGE(TempJnlLineDim."Journal Line No.", l);
                    if rDefDim.FINDFIRST THEN
                        REPEAT
                            TempJnlLineDim."Table ID" := 81;
                            TempJnlLineDim."Journal Template Name" := 'GENERAL';
                            TempJnlLineDim."Journal Batch Name" := 'DIFCONTRA';
                            TempJnlLineDim."Journal Line No." := l;
                            TempJnlLineDim."Dimension Code" := rDefDim."Dimension Code";
                            TempJnlLineDim."Dimension Value Code" := rDefDim."Dimension Value Code";
                            TempJnlLineDim.INSERT;
                        UNTIL rDefDim.NEXT = 0; */
                    GenJnlLine.Validate("Shortcut Dimension 1 Code", rLin."Shortcut Dimension 1 Code");
                    GenJnlLine.Validate("Shortcut Dimension 2 Code", rLin."Shortcut Dimension 2 Code");
                    GenJnlLine.Validate("Shortcut Dimension 3 Code", rLin."Shortcut Dimension 3 Code");
                    GenJnlLine.Validate("Shortcut Dimension 4 Code", rLin."Shortcut Dimension 4 Code");
                    GenJnlLine.Validate("Shortcut Dimension 5 Code", rLin."Shortcut Dimension 5 Code");

                    GenJnlLine.INSERT;
                UNTIL rLin.NEXT = 0;
            if wImpPrepago2 <> suma THEN BEGIN
                l := l + 10000;
                GenJnlLine."Line No." := l;
                suma := suma - wImpPrepago2;
                GenJnlLine.Amount := suma;
                GenJnlLine."Source Currency Amount" := suma;
                GenJnlLine."Amount (LCY)" := suma;
                GenJnlLine."Currency Factor" := 1;
                GenJnlLine."Sales/Purch. (LCY)" := suma;
                //Revisar
                /* rDefDim.RESET;
                rDefDim.SETRANGE("Table ID", 37);
                rDefDim.SETRANGE(rDefDim."Document No.", rLin."Document No.");
                rDefDim.SETRANGE(rDefDim."Document Type", rDefDim."Document Type"::Order);
                rDefDim.SETRANGE(rDefDim."Line No.", rLin."Line No.");
                TempJnlLineDim.SETRANGE(TempJnlLineDim."Journal Line No.", l);
                if rDefDim.FINDFIRST THEN
                    REPEAT
                        TempJnlLineDim."Table ID" := 81;
                        TempJnlLineDim."Journal Template Name" := 'GENERAL';
                        TempJnlLineDim."Journal Batch Name" := 'DIFCONTRA';
                        TempJnlLineDim."Journal Line No." := l;
                        TempJnlLineDim."Dimension Code" := rDefDim."Dimension Code";
                        TempJnlLineDim."Dimension Value Code" := rDefDim."Dimension Value Code";
                        TempJnlLineDim.INSERT;
                    UNTIL rDefDim.NEXT = 0; */
                GenJnlLine.Validate("Shortcut Dimension 1 Code", rLin."Shortcut Dimension 1 Code");
                GenJnlLine.Validate("Shortcut Dimension 2 Code", rLin."Shortcut Dimension 2 Code");
                GenJnlLine.Validate("Shortcut Dimension 3 Code", rLin."Shortcut Dimension 3 Code");
                GenJnlLine.Validate("Shortcut Dimension 4 Code", rLin."Shortcut Dimension 4 Code");
                GenJnlLine.Validate("Shortcut Dimension 5 Code", rLin."Shortcut Dimension 5 Code");
                GenJnlLine.INSERT;
            END;
            COMMIT;
            EnviarMailAz(rCab."No.", wImpPrepago2);
        END;
    END;

    PROCEDURE EnviarMailAz(Documento: Code[20]; Importe: Decimal);
    VAR
        Smtp: Record "Email Item" temporary;
        emilesc: Enum "Email Scenario";
        Correos: List of [Text];
        CorreosFrom: List of [Text];
    BEGIN
        CLEAR(Smtp);
        CorreosFrom.Add('juan@grepsa.com');
        Smtp."Send to" := 'juan@grepsa.com';
        Smtp.Subject := 'Revisar Contrato ' + Documento;
        Smtp."Send CC" := 'miguel@malla.es;janaya@malla.es';
        Smtp.SetBodyText('Revisar el Contrato ' + Documento + ' ' + 'de la empresa ' + COMPANYNAME + '. ' + 'Se ha generado un apunte de ' + FORMAT(Importe, 0, '<Precision,2:3><Standard Format,0>') + ',' + 'en el diario GENERAL sección DIFCONTRA');
        Smtp.Send(true, emilesc::Default);
    END;

    PROCEDURE TotalLineasRepAbo(pNumDoc: Code[20]) pImporte: Decimal;
    VAR
        rLinVenta: Record 115;
    BEGIN
        //$025
        //Calculo el total de las líneas para descontar el prepago.

        pImporte := 0;
        rLinVenta.RESET;
        //rLinVenta.SETRANGE("Document Type",pTipDoc);
        rLinVenta.SETRANGE("Document No.", pNumDoc);
        rLinVenta.SETFILTER("No.", '%1', '485*');
        if rLinVenta.FINDSET THEN BEGIN
            REPEAT
                //if rLinVenta."Line Amount"<0 THEN
                pImporte := pImporte - rLinVenta."Line Amount";
            UNTIL rLinVenta.NEXT = 0;
        END;
    END;

    PROCEDURE CopiaComentarios(VAR LinContr: Record 37; VAR LinFactura: Record 37);
    VAR
        ComentLineContrarto: Record 44;
        ComentLineFactura: Record 44;
    BEGIN
        //ComentLineContrarto.Setrnage(ComentLineContrarto."Document Type",LinContr."Document Type");
    END;

    PROCEDURE EnviarMailJm(Documento: Code[20]; Problema: Text[250]);
    VAR
        Smtp: Record "Email Item" temporary;
        emilesc: Enum "Email Scenario";
        Correos: List of [Text];
        CorreosFrom: List of [Text];
    BEGIN

        CLEAR(Smtp);
        CorreosFrom.Add('andreuserra@malla.es');
        //SendMsg.CreateMessage(rInf."Cabecra Correo",SMTP."User ID",Cliente."E-Mail-Facturación",'Factura Nº'+TxtArchivo,'',TRUE);
        // Smtp.CreateMessage('Navision', rSMTP."User ID", CorreosFrom, 'Revisar Contrato ' + Documento, '', TRUE);
        // Correos.Add('andreuserra@kuarasoftware.com');
        // Correos.Add('lllompart@malla.es');
        // Smtp.AddCC(Correos);
        // Smtp.AppendBody('Revisar el Contrato ' + Documento + ' ');
        // Smtp.AppendBody('de la empresa ' + COMPANYNAME + '. ');
        // Smtp.AppendBody('Se ha ' + Problema);

        //Smtp.Send();
        Smtp."Send to" := 'andreuserra@malla.es';
        Smtp.Subject := 'Revisar Contrato ' + Documento;
        Smtp."Send CC" := 'lllompart@malla.es';
        Smtp.SetBodyText('Revisar el Contrato ' + Documento + ' ' + 'de la empresa ' + COMPANYNAME + '. ' + 'Se ha ' + Problema);
        Smtp.Send(true, emilesc::Default);
    END;

    procedure LookUpSeries(var Series: Code[20]; var SerieCode: Code[20]): Text;
    begin
#If CLEAN24
#pragma warning disable AL0432
        if GestNoSer.LookupSeries(Series, SerieCode) THEN
#pragma warning restore AL0432
            exit(rSerie.Code);
#else
        if GestNoSer.LookupRelatedNoSeries(Series, SerieCode) THEN
            exit(rSerie.Code);
#endif
        exit('');
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCreateInvoiceHeader(var rCabFra: Record "Sales Header"; var rCab: Record "Sales Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterGenerateBorradorPrepago(var rCabVenta: Record "Sales Header"; var SalesHeader: Record "Sales Header")
    begin
    end;

    /* BEGIN
    {
      
                         se cambian de lugar los validates para asegurarnos de q ningún validate posterior lo modificará.
      $002 MNC 150109 Quieren que los datos se conserven del borrador, por si se modifican
      $003 MNC 100809 Ahora 3 tipos de facturación, 2 de ellos nuevos especificos para Grepsa
      $004 MNC 270110 Cambio las tres formas de calcular el IVA 18 para Julio 2010
      $005 FCL 220310 En texto de registro pongo la fecha de inicio de proyecto, en los tres tipos de facturación
                      15/04. Retrocedo la modificación en facturación por fechas.
                      Modifico el texto de registro para facturación por términos para que se calcule
                      a partir de fecha inicio proyecto
                      Mod.$005B es $005 para propuesta (19/05/10)

      $006 FCL 220310 En facturación por fechas solicitar fecha de registro
      $007 FCL 220310 En facturación por fechas creo la línea aunque no haya orden de publicidad
      $008 FCL 230310 Depuración de los prepagos en facturación por fechas, no coge el importe
                      correcto, y debería ser acumulado de líneas. Depurar otros campos.
                      Incluir acumulado de líneas en facturación por términos y por líneas
                      PENDIENTE PRUEBAS EN FACTURACION POR LINEAS
      $009 FCL 230310 Para facturación por fechas generar las líneas correspondientes a comentarios
                      fechas orden publicidad. También genero el resto de comentarios.
      $010 FCL 250310 En facturación por fechas modifico precio y cantidad que se graban en el borrador
                      de factura cuando viene de orden publicidad.
      $011 FCL 290310 En facturación por fechas traspaso texto ampliado línea
      $012 FCL 310310 En facturación por términos incluyo la gestión de remesas sin factura
                      PENDIENTE PRUEBAS EN FACTURACION POR LINEAS
      $013 FCL 080410 Error en longitud descripción prepago.
      $014 FCL 080410 Al grabar texto con nº dias elimino filtro precio 0 y añado nº dias en texto.
      $015 FCL 090410 Al generar propuesta no aplica bien los descuentos.
      $016 FCL 090410 Si se genera propuesta después de crear borradores hace mal el cálculo, falta limpiar el campo de trabajo
      $017 FCL 120410 Si el total del contrato es negativo generaré abono en lugar de factura
      $018 FCL 160410 Inclyo la grabación del nº de línea proyecto
      $019 FCL 270410 Incluyo el cálculo de descuentos de cabecera en la generación de propuesta
                      También incluyo el descuento de prepagos al final de las líneas
      $020 FCL 110510 Grabo Posting description distinta si nº plazos es distinto de nº meses contrato
                      En facturación por términos y en generación propuesta. Excepto para 1 plazo.
                      Para 1 plazo grabo siempre fecha inicial y final contrato.
      $021 FCL 310510 Grabo las fechas inicial y final recurso en la generación de borrador.
      $022 FCL 010610 Elimino una modificación antigua correspondiente a 13 plazos, no se utiliza.
      $023 Corresponde al primer comentario.
      $024 FCL 220710 Grabo el campo Imprimir fecha recurso.
      $025 FCL 260710 Incluyo nueva función para generar borrador prepago, que sustituirá el tratamiento del standard,
                      ya que éste genera directamente los históricos.
                      El motivo es poder facturar líneas junto al prepago.
                      Incluyo la facturación de líneas con reparto 'Fra prepago' junto al prepago. También en propuesta.
                      Modifico el descuento del prepago para no tener en cuenta las líneas con reparto 'Fra prepago'. También en propuesta
      $026 FCL 310810 Al generar borrador cabecera y propuesta grabo cód. descuento factura del contrato, puede que se haya modificado.
      $027 FCL 181010 Elimino el literal 'Periodo facturación:' de texto registro de la cabecera.
      $028 FCL 071210 Grabo la marca Lanzado en la cabecera del contrato
      $029 FCL 131210 En facturación por términos la fecha de vencimiento se cogerá de la propuesta.
      $030 FCL 201210 En facturación por términos limpio cantidad facturada antes de empezar a generar borradores (por si no es la 1¦ vez)
      $031 FCL 310111 Para tipo recurso cogeré el proveedor de la línea de venta (OnValidate de lin. venta lo coge del recurso).
      $032 FCL 080211 Arreglo error en propuesta, para Reparto 1¦ fra hace un reparto proporcional.
      $033 FCL 140211 En facturación por fechas cojo importe línea orden publicidad en lugar de precio.
      $034 FCL 210211 Modificaciones en Reparto 1¦ fra, al generar propuesta y al generar borrador por términos
      $035 FCL 140311 En facturación por términos generaré remesa según forma de pago del borrador de factura, ya que
                      ahora los borradores pueden tener distinta forma de pago (caso de reparto = 1¦ fra).
      $036 FCL 040411 En propuesta y generación de borradores cojo grupo Iva de las líneas.
      $037 FCL 040411 Incluyo comentarios en factura prepago.
      $038 FCL 260411 Grabo código cadena en cabecera al generar borrador
      $039 FCL 300511 Grabo el campo Remarcar de las líneas del proyecto.
      $041 FCL 310511 Para radio cogeremos precio en lugar de importe.
    }
    END. */

}