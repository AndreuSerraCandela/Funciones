/// <summary>
/// Codeunit Gestion Proyecto (ID 50002).
/// </summary>
codeunit 50002 "Gestion Proyecto"
{

    Permissions = TableData 112 = rim,
                TableData 114 = rim;
    trigger OnRun()
    VAR
        lJob: Record Job;
        lJobPlanningLine: Record 1003;
        lVentana: Dialog;
        la: Integer;
        SalesInvHeader: Record "Sales Invoice Header";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        PurchInvHeader: Record "Purch. Inv. Header";
        PurchCrMemoHeader: Record "Purch. Cr. Memo Hdr.";
    BEGIN


        /*             {Ventana.OPEN('############1## de #############2##');
                    rJob.SETFILTER(rJob."Proyecto en empresa Origen",'<>%1','');
                    Ventana.UPDATE(2,rJob.COUNT);
                    if rJob.FINDFIRST THEN REPEAT
                    a:=a+1;
                    Ventana.UPDATE(1,a);
                     JobPlanningLine.SETRANGE(JobPlanningLine."Job No.",rJob."No.");
                     if JobPlanningLine.FINDFIRST THEN REPEAT
                      lTextot.DELETEALL;
                      lTexto.SETRANGE(lTexto."Nº proyecto",rJob."No.");
                      lTexto.SETRANGE(lTexto."Cód. tarea",JobPlanningLine."Job Task No.");
                      lTexto.SETRANGE(lTexto."Nº linea aux",JobPlanningLine."Line No.");
                      if lTexto.FINDFIRST THEN REPEAT
                       lTextot:=lTexto;
                       lTextot."Nº":=JobPlanningLine."No.";
                       if lTextot.INSERT THEN;
                      UNTIL lTexto.NEXT=0;
                      lTexto.DELETEALL;
                      if lTextot.FINDFIRST THEN REPEAT
                       lTexto:=lTextot;
                       lTexto.INSERT;
                      UNTIL lTextot.NEXT=0;
                     UNTIL JobPlanningLine.NEXT=0;
                    UNTIL rJob.NEXT=0;
                    Ventana.CLOSE;} */
    END;

    VAR
        GProcesoCancelado: Label 'Proceso Cancelado por el usuario';
        lcReservas: Codeunit "Gestion Reservas";

    PROCEDURE Cambio_Fecha(VAR PProyecto: Record Job; PIntervalo: Decimal);
    VAR
        lJobPlanningLine: Record 1003;
        lReserva: Record Reserva;
        lSalesHeader: Record "Sales Header";
        lSalesLine: Record "Sales Line";
    BEGIN
        PProyecto.LOCKTABLE;
        lJobPlanningLine.LOCKTABLE;
        lReserva.LOCKTABLE;
        lSalesHeader.LOCKTABLE;
        lSalesLine.LOCKTABLE;
        ////{ *** Cambios en reservas *** }
        lReserva.RESET;
        CLEAR(lReserva);
        lReserva.SETCURRENTKEY("Nº Proyecto", "Fecha inicio");
        lReserva.SETRANGE("Nº Proyecto", PProyecto."No.");
        if (PIntervalo > 0) THEN BEGIN
            if lReserva.FIND('+') THEN
                REPEAT
                    lcReservas.Cambia_Fecha_Reserva(lReserva, PIntervalo);
                UNTIL lReserva.NEXT(-1) = 0;
        END ELSE BEGIN
            if lReserva.FIND('-') THEN
                REPEAT
                    lcReservas.Cambia_Fecha_Reserva(lReserva, PIntervalo);
                UNTIL lReserva.NEXT = 0;
        END;
        ////{ *** Cambios en lineas presupuesto *** }
        lJobPlanningLine.RESET;
        lJobPlanningLine.SETCURRENTKEY("Job No.");
        lJobPlanningLine.SETRANGE("Job No.", PProyecto."No.");
        if lJobPlanningLine.FIND('-') THEN
            REPEAT
                lJobPlanningLine."Planning Date" := lJobPlanningLine."Planning Date" + PIntervalo;
                lJobPlanningLine."Fecha Final" := lJobPlanningLine."Fecha Final" + PIntervalo;
                lJobPlanningLine.MODIFY;
            UNTIL lJobPlanningLine.NEXT = 0;
        ////{ *** Cambios en cab.venta, en todos, contratos y facturas *** }
        lSalesHeader.SETCURRENTKEY("Nº Proyecto");
        lSalesHeader.SETRANGE("Nº Proyecto", PProyecto."No.");
        lSalesHeader.SETRANGE("Document Type", lSalesHeader."Document Type"::Order);  //FCL-20/05/05. Sólo cambio en pedidos
        if lSalesHeader.FIND('-') THEN
            REPEAT
                lSalesHeader.Validate("Fecha inicial proyecto", lSalesHeader."Fecha inicial proyecto" + PIntervalo);
                lSalesHeader.Validate("Fecha fin proyecto", lSalesHeader."Fecha fin proyecto" + PIntervalo);
                lSalesHeader."Posting Date" := lSalesHeader."Fecha inicial proyecto";             //FCL-07/10/04
                lSalesHeader."Document Date" := lSalesHeader."Fecha inicial proyecto";            //FCL-07/10/04
                lSalesHeader.MODIFY;
                lSalesLine.RESET;
                lSalesLine.SETCURRENTKEY("Document Type", "Document No.", "Job No.");
                lSalesLine.SETRANGE("Document Type", lSalesHeader."Document Type");
                lSalesLine.SETRANGE("Document No.", lSalesHeader."No.");
                lSalesLine.SETRANGE("Job No.", lSalesHeader."Nº Proyecto");
                if lSalesLine.FIND('-') THEN
                    REPEAT
                        if (lSalesLine.Type = lSalesLine.Type::Resource) THEN BEGIN
                            lJobPlanningLine.RESET;
                            lJobPlanningLine.SETCURRENTKEY("Job No.", "Job Task No.", "Line No.");
                            lJobPlanningLine.SETRANGE("Job No.", lSalesLine."Job No.");
                            lJobPlanningLine.SETRANGE("Job Task No.", lSalesLine."Job Task No.");
                            lJobPlanningLine.SETRANGE(Type, lJobPlanningLine.Type::Resource);
                            lJobPlanningLine.SETRANGE("No.", lSalesLine."No.");
                            lJobPlanningLine.SETRANGE("Variant Code", lSalesLine."Variant Code");
                            if lJobPlanningLine.FIND('-') THEN BEGIN
                                //$001(I)
                                ///lSalesLine."Description 2" := STRSUBSTNO('%1',lJobPlanningLine."Planning Date") + ' - ' +
                                ///                       STRSUBSTNO('%1',lJobPlanningLine."Fecha Final");
                                lSalesLine."Fecha inicial recurso" := lSalesHeader."Fecha inicial proyecto";
                                lSalesLine."Fecha final recurso" := lSalesHeader."Fecha fin proyecto";
                                //$001(F)
                                lSalesLine.MODIFY;
                            END;
                        END;
                    UNTIL lSalesLine.NEXT = 0;
            UNTIL lSalesHeader.NEXT = 0;
        ////{ *** Cambios en la cabecera del proyecto *** }
        PProyecto."Starting Date" := PProyecto."Starting Date" + PIntervalo;
        PProyecto."Ending Date" := PProyecto."Ending Date" + PIntervalo;
        PProyecto.MODIFY;
    END;

    PROCEDURE Adelanta_Fecha_Fin(VAR rProyecto: Record Job; nFecha: Date);
    VAR
        lJobPlanningLine: Record 1003;
        lReserva: Record Reserva;
        lSalesHeader: Record "Sales Header";
        lSalesLine: Record "Sales Line";
        lDiari: Record "Diario Reserva";
        lcReservas: Codeunit "Gestion Reservas";
    BEGIN
        rProyecto.LOCKTABLE;
        lJobPlanningLine.LOCKTABLE;
        lReserva.LOCKTABLE;
        lSalesHeader.LOCKTABLE;
        lSalesLine.LOCKTABLE;
        //{ *** Cambios en reservas *** }
        lReserva.RESET;
        CLEAR(lReserva);
        lReserva.SETCURRENTKEY("Nº Proyecto", "Fecha inicio");
        lReserva.SETRANGE("Nº Proyecto", rProyecto."No.");
        if lReserva.FIND('-') THEN
            REPEAT
                //lcReservas.Cambia_Fecha_Reserva(lReserva, Intervalo);
                lDiari.RESET;
                lDiari.SETCURRENTKEY("Nº Reserva", Fecha);
                lDiari.SETRANGE("Nº Reserva", lReserva."Nº Reserva");
                lDiari.DELETEALL;
                lReserva."Fecha fin" := nFecha;
                lReserva.MODIFY;
                //Reserva.Crea_Historia(lReserva."Nº Recurso", lReserva, 'SUYO');
                lcReservas.Crea_Dia_Reserva(lReserva);
            UNTIL lReserva.NEXT = 0;
        //{ *** Cambios en lineas presupuesto *** }
        lJobPlanningLine.RESET;
        lJobPlanningLine.SETCURRENTKEY("Job No.", "Job Task No.", "Line No.");
        lJobPlanningLine.SETRANGE("Job No.", rProyecto."No.");
        if lJobPlanningLine.FIND('-') THEN
            REPEAT
                lJobPlanningLine."Fecha Final" := nFecha;
                lJobPlanningLine.MODIFY;
            UNTIL lJobPlanningLine.NEXT = 0;
        //{ *** Cambios en cab.venta, en todos, contratos y facturas *** }
        lSalesHeader.SETCURRENTKEY("Nº Proyecto");
        lSalesHeader.SETRANGE("Nº Proyecto", rProyecto."No.");
        lSalesHeader.SETRANGE("Document Type", lSalesHeader."Document Type"::Order);  //FCL-20/05/05. Sólo cambio en pedidos
        if lSalesHeader.FIND('-') THEN
            REPEAT
                lSalesHeader."Fecha fin proyecto" := nFecha;
                lSalesHeader.MODIFY;
                lSalesLine.RESET;
                lSalesLine.SETCURRENTKEY("Document Type", "Document No.", "Job No.");
                lSalesLine.SETRANGE("Document Type", lSalesHeader."Document Type");
                lSalesLine.SETRANGE("Document No.", lSalesHeader."No.");
                lSalesLine.SETRANGE("Job No.", lSalesHeader."Nº Proyecto");
                if lSalesLine.FIND('-') THEN
                    REPEAT
                        if (lSalesLine.Type = lSalesLine.Type::Resource) THEN BEGIN
                            lJobPlanningLine.RESET;
                            lJobPlanningLine.SETCURRENTKEY("Job No.", "Job Task No.", "Line No.");
                            lJobPlanningLine.SETRANGE("Job No.", lSalesLine."Job No.");
                            lJobPlanningLine.SETRANGE("Job Task No.", lSalesLine."Job Task No.");
                            lJobPlanningLine.SETRANGE(Type, lJobPlanningLine.Type::Resource);
                            lJobPlanningLine.SETRANGE("No.", lSalesLine."No.");
                            lJobPlanningLine.SETRANGE("Variant Code", lSalesLine."Variant Code");
                            if lJobPlanningLine.FIND('-') THEN BEGIN
                                //$001(I)
                                ///lSalesLine."Description 2" := STRSUBSTNO('%1',lJobPlanningLine."Planning Date") + ' - ' +
                                ///                       STRSUBSTNO('%1',lJobPlanningLine."Fecha Final");
                                lSalesLine."Fecha final recurso" := nFecha;
                                //$001(F)
                                lSalesLine.MODIFY;
                            END;
                        END;
                    UNTIL lSalesLine.NEXT = 0;
            UNTIL lSalesHeader.NEXT = 0;
        //{ *** Cambios en la cabecera del proyecto *** }
        rProyecto."Ending Date" := nFecha;
        rProyecto.MODIFY;
    END;

    PROCEDURE Traspasa_Datos(wProyecto: Code[20]);
    VAR
        rHF: Record "Sales Invoice Header";
        rHA: Record "Sales Cr.Memo Header";
        rP: Record Job;
        rC: Record "Sales Header";
    BEGIN
        rHF.SETCURRENTKEY("Nº Proyecto");
        if (wProyecto <> '') THEN
            rHF.SETRANGE("Nº Proyecto", wProyecto);
        if rHF.FIND('-') THEN
            REPEAT
                if (rHF."Nº Proyecto" <> '') THEN BEGIN
                    if rP.GET(rHF."Nº Proyecto") THEN BEGIN
                        rHF.Tipo := rP.Tipo;
                        rHF.Firmado := rP.Firmado;
                        rHF."Fecha Firma" := rP."Fecha Firma";
                        rHF.Subtipo := rP.Subtipo;
                        rHF."Soporte de" := rP."Soporte de";
                        rHF.Renovado := rP.Renovado;                          //FCL-25/05/05
                        rHF."Interc./Compens." := rP."Interc./Compens.";      //FCL-25/05/05
                        rHF."Proyecto origen" := rP."Proyecto original";        //FCL-25/05/05
                        rHF.MODIFY;
                    END;
                END;
            UNTIL rHF.NEXT = 0;

        rHA.SETCURRENTKEY("Nº Proyecto");
        if (wProyecto <> '') THEN
            rHA.SETRANGE("Nº Proyecto", wProyecto);
        if rHA.FIND('-') THEN
            REPEAT
                if (rHA."Nº Proyecto" <> '') THEN BEGIN
                    if rP.GET(rHA."Nº Proyecto") THEN BEGIN
                        rHA.Tipo := rP.Tipo;
                        rHA.Firmado := rP.Firmado;
                        rHA."Fecha Firma" := rP."Fecha Firma";
                        rHA.Subtipo := rP.Subtipo;
                        rHA."Soporte de" := rP."Soporte de";
                        rHA.MODIFY;
                    END;
                END;
            UNTIL rHA.NEXT = 0;

        rC.SETCURRENTKEY("Nº Proyecto");
        if (wProyecto <> '') THEN
            rC.SETRANGE("Nº Proyecto", wProyecto);
        if rC.FIND('-') THEN
            REPEAT
                if (rC."Nº Proyecto" <> '') THEN BEGIN
                    if rP.GET(rC."Nº Proyecto") THEN BEGIN
                        rC.Tipo := rP.Tipo;
                        rC.Firmado := rP.Firmado;
                        rC."Fecha Firma" := rP."Fecha Firma";
                        rC.Subtipo := rP.Subtipo;
                        rC."Soporte de" := rP."Soporte de";
                        rC.Renovado := rP.Renovado;                          //FCL-25/05/05
                        rC."Interc./Compens." := rP."Interc./Compens.";      //FCL-25/05/05
                        rC."Proyecto origen" := rP."Proyecto original";        //FCL-25/05/05
                        rC."Shortcut Dimension 2 Code" := rP."Global Dimension 2 Code";
                        rC.MODIFY;
                    END;
                END;
            UNTIL rC.NEXT = 0;

        MESSAGE('Fin del proceso traspaso datos');
    END;

    PROCEDURE TotalProyecto(pProyecto: Record Job; VAR pTotalSalesLine: Record "Sales Line"; VAR pCabTemp: Record "Sales Header");
    VAR
        rProyecto: Record Job;
        lJobPlanningLine: Record 1003;
        rCabTemp: Record "Sales Header";
        SalesLineTemp: Record "Sales Line";
        rCnfVta: Record 311;
        lSalesLine: Record "Sales Line";
        SalesLine: Record "Sales Line";
        TempSalesLine: Record "Sales Line" temporary;
        TotalSalesLine: Record "Sales Line";
        TotalSalesLineLCY: Record "Sales Line";
        rFamilia: Record 152;
        rGCP: Record 251;
        rGCN: Record 250;
        rCGC: Record 252;
        SalesPost: Codeunit "Sales-Post";
        wNumDoc: Code[20];
        VATAmountText: Text[30];
        VATAmount: Decimal;
        ProfitLCY: Decimal;
        ProfitPct: Decimal;
        TotalAdjCostLCY: Decimal;
        TotalAmount: Decimal;
        wLinTemp: Integer;
    BEGIN
        // Genero un contrato temporal para poder calcular los totales del proyecto

        rProyecto.GET(pProyecto."No.");
        // if Strpos(UserId, '\') <> 0 Then
        //     wNumDoc := Copystr('TEMPJOB' + COPYSTR(UserId, 11), 1, 20)
        // else
        //     wNumDoc := Copystr('TEMPJOB' + UserId, 1, 20);

        // Cabecera proyecto
        wNumDoc := 'TEMPJOB';
        rCabTemp.INIT;
        rCabTemp."Assigned User ID" := UserId;
        rCabTemp."Document Type" := rCabTemp."Document Type"::Invoice;
        rCabTemp."No." := wNumDoc;
        rCabTemp.VALIDATE("Posting Date", rProyecto."Starting Date");
        rCabTemp.VALIDATE("Due Date", rProyecto."Starting Date");
        rCabTemp.VALIDATE("Sell-to Customer No.", rProyecto."Bill-to Customer No.");
        rCabTemp.VALIDATE("Currency Code", rProyecto."Currency Code");
        if rProyecto."Payment Method Code" <> '' THEN
            rCabTemp.VALIDATE("Payment Method Code", rProyecto."Payment Method Code");
        rCabTemp.INSERT;

        // líneas proyecto
        wLinTemp := 0;
        lJobPlanningLine.RESET;
        lJobPlanningLine.SETRANGE("Job No.", rProyecto."No.");
        if lJobPlanningLine.FINDSET THEN BEGIN
            REPEAT
                SalesLineTemp.INIT;
                SalesLineTemp."Document Type" := SalesLineTemp."Document Type"::Invoice;
                SalesLineTemp."Document No." := wNumDoc;
                wLinTemp := wLinTemp + 1;
                SalesLineTemp."Line No." := wLinTemp;
                CASE lJobPlanningLine.Type OF
                    lJobPlanningLine.Type::"G/L Account":
                        SalesLineTemp.VALIDATE(Type, SalesLineTemp.Type::"G/L Account");
                    lJobPlanningLine.Type::Item:
                        SalesLineTemp.VALIDATE(Type, SalesLineTemp.Type::Item);
                    lJobPlanningLine.Type::Resource:
                        SalesLineTemp.VALIDATE(Type, SalesLineTemp.Type::Resource);
                    lJobPlanningLine.Type::Familia:
                        SalesLineTemp.VALIDATE(Type, SalesLineTemp.Type::"G/L Account");
                END;
                if (lJobPlanningLine.Type <> lJobPlanningLine.Type::Familia) THEN BEGIN
                    SalesLineTemp.VALIDATE("No.", lJobPlanningLine."No.");
                END ELSE BEGIN
                    rFamilia.GET(lJobPlanningLine."No.");
                    rGCP.GET(rFamilia."Grupo contable producto");
                    rGCN.GET(rCabTemp."Gen. Bus. Posting Group");
                    rCGC.GET(rGCN.Code, rGCP.Code);
                    SalesLineTemp.VALIDATE("No.", rCGC."Sales Account");
                    SalesLineTemp.VALIDATE("Gen. Bus. Posting Group", rGCN.Code);
                    SalesLineTemp.VALIDATE("Gen. Prod. Posting Group", rGCP.Code);
                END;
                SalesLineTemp.VALIDATE(Quantity, lJobPlanningLine.Quantity);
                SalesLineTemp.VALIDATE("Unit Price", lJobPlanningLine."Unit Price");
                SalesLineTemp.VALIDATE("Line Discount %", lJobPlanningLine."% Dto. Venta");
                SalesLineTemp."Dto. Tarifa" := lJobPlanningLine."Dto. Tarifa";
                SalesLineTemp."% Dto. Venta 1" := lJobPlanningLine."% Dto. Venta 1";
                SalesLineTemp."% Dto. Venta 2" := lJobPlanningLine."% Dto. Venta 2";
                SalesLineTemp."Precio Tarifa" := lJobPlanningLine."Precio Tarifa";
                SalesLineTemp."Line Discount %" := lJobPlanningLine."% Dto. Venta";
                SalesLineTemp."Tipo Duracion" := lJobPlanningLine."Tipo Duracion";
                SalesLineTemp.Duracion := lJobPlanningLine.Duracion;
                SalesLineTemp."Cdad. Soportes" := lJobPlanningLine."Cdad. Soportes";
                SalesLineTemp.INSERT;
            UNTIL lJobPlanningLine.NEXT = 0;
        END;

        //Cálculo de totales

        rCnfVta.GET;
        if rCnfVta."Calc. Inv. Discount" THEN BEGIN
            SalesLineTemp.RESET;
            SalesLineTemp.SETRANGE("Document Type", rCabTemp."Document Type");
            SalesLineTemp.SETRANGE("Document No.", rCabTemp."No.");
            if SalesLineTemp.FINDFIRST THEN
                CODEUNIT.RUN(CODEUNIT::"Sales-Calc. Discount", SalesLineTemp);
        END;

        CLEAR(SalesLine);
        CLEAR(TotalSalesLine);
        CLEAR(TotalSalesLineLCY);
        CLEAR(SalesPost);

        SalesPost.GetSalesLines(rCabTemp, TempSalesLine, 0);
        CLEAR(SalesPost);
        SalesPost.SumSalesLinesTemp(
          rCabTemp, TempSalesLine, 0, TotalSalesLine, TotalSalesLineLCY,
          VATAmount, VATAmountText, ProfitLCY, ProfitPct, TotalAdjCostLCY);

        pTotalSalesLine := TotalSalesLine;
        pCabTemp := rCabTemp;

        rCabTemp.RESET;
        rCabTemp.SETRANGE("Document Type", rCabTemp."Document Type"::Invoice);
        rCabTemp.SETRANGE("No.", wNumDoc);
        rCabTemp.DELETE(TRUE);
    END;

    PROCEDURE TrasPasaPoryectoaEmpresas(VAR rJob: Record Job);
    VAR
        rJob2: Record Job;
        JobPlanningLine: Record 1003;
        JobPlanningLine2: Record 1003;
        JobTask: Record 1001;
        JobTask2: Record 1001;
        JobPlanningLineT: Record 1003 temporary;
        JobTaskt: Record 1001 temporary;
        rJobt: Record Job temporary;
        rRes: Record "Resource";
        rEmp: Record 2000000006;
        CMan: Codeunit "No. Series";
        JobSetup: Record 315;
        rCli: Record "Customer";
        rSo: Record 413;
        lTexto: Record "Texto Presupuesto";
        lTexto2: Record "Texto Presupuesto";
        lTextot: Record "Texto Presupuesto" temporary;
        rResOrg: Record "Resource";
        rJobOrg: Record Job;
        rJobOrgEmp: Record Job;
        rGrupo: Record 251;
        rResv: Record Reserva;
        rTip: Record "Tipo Recurso";
        rInf: Record "Company Information";
        rProd: Record "Produccines Relacionadas";
        rProd2: Record "Produccines Relacionadas";
    BEGIN
        JobPlanningLine.SETRANGE(JobPlanningLine."Job No.", rJob."No.");
        if JobPlanningLine.FINDFIRST THEN
            REPEAT
                if rRes.GET(JobPlanningLine."No.") THEN BEGIN
                    if (rRes."Empresa Origen" <> COMPANYNAME)
                    AND (rRes."Nº En Empresa origen" <> '') THEN BEGIN
                        rEmp.GET(rRes."Empresa Origen");
                        rResOrg.CHANGECOMPANY(rRes."Empresa Origen");
                        rResOrg.GET(rRes."Nº En Empresa origen");
                        rJobt := rJob;
                        rJobt."Bill-to Contact" := rEmp.Name;
                        rInf.ChangeCompany(rEmp.Name);
                        rInf.Get();
                        rJobt."No." := rInf."Clave Recursos";
                        rJobt."Proyecto en empresa Origen" := rJob."No.";
                        rJobt.Status := rJobt.Status::Quote;
                        rJobt."Global Dimension 1 Code" := rResOrg."Global Dimension 1 Code";
                        rJobt."Global Dimension 2 Code" := rResOrg."Global Dimension 2 Code";
                        if rJobt.INSERT THEN;
                        JobPlanningLineT := JobPlanningLine;
                        rInf.ChangeCompany(rEmp.Name);
                        rInf.Get();
                        JobPlanningLineT."Job No." := rInf."Clave Recursos";
                        JobPlanningLineT."No." := rRes."Nº En Empresa origen";
                        JobPlanningLineT."Crear pedidos" := JobPlanningLineT."Crear pedidos"::"De Venta";
                        if JobPlanningLine."Unit Cost" = 0 Then
                            Error('No puede crear líneas de recursos de otra empresa sin precio de compra, revise la linea % 1 con el recurso %2 del proyecto %3',
                            JobPlanningLine."Line No.", JobPlanningLine."No.", JobPlanningLine."Job No.");
                        JobPlanningLineT."Unit Price" := JobPlanningLine."Unit Cost";
                        JobPlanningLineT."Total Price" := (JobPlanningLine."Total Cost" * (1 - JobPlanningLine."% Dto. Compra" / 100));
                        JobPlanningLineT."Unit Cost (LCY)" := 0;
                        JobPlanningLineT."Total Cost (LCY)" := 0;
                        JobPlanningLineT."Direct Unit Cost (LCY)" := 0;
                        JobPlanningLineT."Unit Cost" := 0;
                        JobPlanningLineT."Total Cost" := 0;
                        JobPlanningLineT."Recurso en Empresa Origen" := JobPlanningLine."No.";
                        JobPlanningLineT."Linea en Empresa Origen" := JobPlanningLine."Line No.";
                        JobPlanningLineT."% Dto. Venta 1" := JobPlanningLineT."% Dto. Compra";
                        JobPlanningLineT."% Dto. Venta" := JobPlanningLineT."% Dto. Compra";
                        JobPlanningLineT."% Dto. Compra" := 0;
                        JobPlanningLineT."Compra a-Nº proveedor" := '';
                        JobPlanningLineT."Cdad. a Reservar" := 0;
                        rTip.CHANGECOMPANY(rRes."Empresa Origen");
                        if rTip.GET(rResOrg."Tipo Recurso") THEN
                            if (rTip."Crea Reservas") and (rResOrg."Recurso Agrupado" = false) and (rResOrg."Producción" = false) THEN
                                JobPlanningLineT."Cdad. a Reservar" := JobPlanningLineT.Quantity;
                        if JobPlanningLineT."Cdad. a Reservar" > 1 THEN
                            JobPlanningLineT."Cdad. a Reservar" := 1;
                        if JobPlanningLineT.INSERT THEN;
                        lTexto.SETRANGE("Nº proyecto", JobPlanningLine."Job No.");
                        lTexto.SETRANGE(lTexto."Cód. tarea", JobPlanningLine."Job Task No.");
                        lTexto.SETRANGE(lTexto."Nº linea aux", JobPlanningLine."Line No.");
                        if lTexto.FINDFIRST THEN
                            REPEAT
                                lTextot := lTexto;
                                rInf.ChangeCompany(rEmp.Name);
                                rInf.Get();
                                lTextot."Nº proyecto" := rInf."Clave Recursos";
                                lTextot."Nº" := rRes."Nº En Empresa origen";
                                if lTextot.INSERT THEN;
                            UNTIL lTexto.NEXT = 0;

                        JobTask.SETRANGE(JobTask."Job No.", JobPlanningLine."Job No.");
                        if JobTask.FINDFIRST THEN
                            REPEAT
                                JobTaskt := JobTask;
                                rInf.ChangeCompany(rEmp.Name);
                                rInf.Get();
                                JobTaskt."Job No." := rInf."Clave Recursos";
                                if JobTaskt.INSERT THEN;
                            UNTIL JobTask.NEXT = 0;

                    END;
                END;
            UNTIL JobPlanningLine.NEXT = 0;
        if rJobt.FINDFIRST THEN
            REPEAT
                CLEAR(cMan);
                rSo.SETRANGE(rSo."Inbox Details", COMPANYNAME);
                rSo.FINDFIRST;

                rCli.CHANGECOMPANY(rJobt."Bill-to Contact");
                rCli.SETRANGE(rCli."IC Partner Code", rSo.Code);
                rCli.FINDFIRST;
                rJob2.CHANGECOMPANY(rJobt."Bill-to Contact");
                rJob2.SETCURRENTKEY(rJob2."Proyecto en empresa Origen");
                rJob2.SETRANGE(rJob2."Proyecto en empresa Origen", rJob."No.");
                rJob2.SETRANGE(rJob2."Bill-to Customer No.", rCli."No.");
                rResv.ChangeCompany(rEmp.Name);

                if rJob2.FINDFIRST THEN BEGIN
                    rResv.SetRange("Nº Proyecto", rJob2."No.");
                    if rResv.FindFirst() Then
                        ERROR('El proyecto %1 en la empresa %2 tiene reservas',
                            rJob2."No.", rJobt."Bill-to Contact");
                    if rJob2.Status = rJob2.Status::Open THEN
                        ERROR('El proyecto %1 en la empresa %2 esta en estado Contrato',
                        rJob2."No.", rJobt."Bill-to Contact");
                    JobTask2.CHANGECOMPANY(rJobt."Bill-to Contact");
                    JobTask2.SETRANGE(JobTask2."Job No.", rJob2."No.");
                    JobTask2.DELETEALL;
                    JobPlanningLine2.CHANGECOMPANY(rJobt."Bill-to Contact");
                    JobPlanningLine2.SETRANGE(JobPlanningLine2."Job No.", rJob2."No.");
                    JobPlanningLine2.DELETEALL;
                    lTexto2.CHANGECOMPANY(rJobt."Bill-to Contact");
                    lTexto2.SETRANGE("Nº proyecto", rJob2."No.");
                    lTexto2.DELETEALL;
                    rJob2.DELETE;
                END;
                JobSetup.CHANGECOMPANY(rJobt."Bill-to Contact");
                JobSetup.GET;
                rJob2 := rJobt;
                rCli.CHANGECOMPANY(rJobt."Bill-to Contact");
                rCli.SETRANGE(rCli."IC Partner Code", rSo.Code);
                rCli.FINDFIRST;
                //
                rJob2."Proyecto origen" := '';
                rJob2."Proyecto original" := '';
                if rJob."Proyecto origen" <> '' THEN BEGIN
                    if rJobOrg.GET(rJob."Proyecto origen") THEN BEGIN
                        rJobOrgEmp.CHANGECOMPANY(rJobt."Bill-to Contact");
                        rJobOrgEmp.SETCURRENTKEY("Proyecto en empresa Origen");
                        rJobOrgEmp.SETRANGE("Proyecto en empresa Origen", rJobOrg."No.");
                        if NOT rJobOrgEmp.FINDFIRST THEN BEGIN
                            MESSAGE('Este proyecto es una renovación, pero el proyecto anterior\'
                            + ' no se hizo con este sistema y en %1\'
                            + ' no puedo encontrar el proyecto anterior.\'
                            + ' después de pulsar aceptar aparecerá una\'
                            + ' ventana con la lista de proyectos de %2\'
                            + ' en %1 seleccione\'
                            + ' el proyecto anterior a este para que pueda\'
                            + ' recuperar los datos de Proyecto Origen y Original', rJobt."Bill-to Contact",
                            COMPANYNAME);
                            COMMIT;
                            rJobOrgEmp.SETRANGE("Proyecto en empresa Origen");
                            rJobOrgEmp.SETRANGE("Bill-to Customer No.", rCli."No.");
                            if Page.RUNMODAL(0, rJobOrgEmp) <> ACTION::LookupOK THEN
                                ERROR(GProcesoCancelado);
                        END;
                        rJob2."Proyecto origen" := rJobOrgEmp."No.";
                        rJob2."Proyecto original" := rJobOrgEmp."Proyecto original";
                    END;
                END;
                //
                rJob2."Bill-to Customer No." := rCli."No.";
                rJob2.UpdateCustEmp(rCli, rJobt."Bill-to Contact");
                rJob2."Cód. vendedor" := rCli."Salesperson Code";
                rJob2."No." := GetNextNoEmp(JobSetup."Job Nos.", WORKDATE, TRUE, COPYSTR(rJobt."Bill-to Contact", 1, 30));
                rJob2."Empresa Origen" := COMPANYNAME;
                rJob2.Description := rJob.Description;
                rJob2.INSERT;
                JobTaskt.SETRANGE(JobTaskt."Job No.", rJobt."No.");
                if JobTaskt.FINDFIRST THEN
                    REPEAT
                        JobTask2.CHANGECOMPANY(rJobt."Bill-to Contact");
                        JobTask2 := JobTaskt;
                        JobTask2."Job No." := rJob2."No.";
                        JobTask2.INSERT;
                    UNTIL JobTaskt.NEXT = 0;
                JobPlanningLineT.SETRANGE(JobPlanningLineT."Job No.", rJobt."No.");
                if JobPlanningLineT.FINDFIRST THEN
                    REPEAT
                        JobPlanningLine2.CHANGECOMPANY(rJobt."Bill-to Contact");
                        JobPlanningLine2 := JobPlanningLineT;
                        JobPlanningLine2."Job No." := rJob2."No.";
                        rResOrg.CHANGECOMPANY(rJobt."Bill-to Contact");
                        rResOrg.GET(JobPlanningLine2."No.");
                        rGrupo.CHANGECOMPANY(rJobt."Bill-to Contact");
                        if NOT rGrupo.GET(rResOrg."Gen. Prod. Posting Group") THEN
                            ERROR('El Recurso %1 esta mal configurado en %1. Reviselo Para Continuar',
                        rResOrg."No.", rJobt."Bill-to Contact");
                        JobPlanningLine2."Gen. Bus. Posting Group" := rCli."Gen. Bus. Posting Group";
                        JobPlanningLine2."Gen. Prod. Posting Group" := rResOrg."Gen. Prod. Posting Group";
                        JobPlanningLine2."Shortcut Dimension 1 Code" := rResOrg."Global Dimension 1 Code";
                        JobPlanningLine2."Shortcut Dimension 2 Code" := rResOrg."Global Dimension 2 Code";
                        JobPlanningLine2.INSERT;
                        //Recurso de produccion
                        If rResOrg."Producción" Then begin
                            rProd.SetRange("Job No.", rJob."No.");
                            rProd.SetRange("Line No.", JobPlanningLineT."Line No.");
                            If rProd.FindFirst() Then Begin
                                rProd2.ChangeCompany(rJobt."Bill-to Contact");
                                rProd2.SetRange("Job No.", rJob2."No.");
                                rProd2.SetRange("Line No.", JobPlanningLine2."Line No.");
                                rProd2.DeleteAll;
                                Repeat
                                    rProd2 := rProd;
                                    rProd2."Job No." := rJob2."No.";
                                    rProd2."No." := JobPlanningLine2."No.";
                                    rProd2."Line No." := JobPlanningLine2."Line No.";
                                    If rRes.Get(rProd."No.2") Then
                                        If rRes."Nº En Empresa origen" <> '' Then
                                            rProd2."No.2" := rRes."Nº En Empresa origen";
                                    If rProd."Job No.2" = rJob."No." Then
                                        rProd2."Job No.2" := rJob2."No.";
                                    If rProd2.Empresa = '' Then rProd2.Empresa := CompanyName;
                                    If rProd2.Empresa = rJobt."Bill-to Contact" Then rProd2.Empresa := '';
                                    rProd2.INSERT;
                                until rProd.Next() = 0;
                            end;
                        end;
                    UNTIL JobPlanningLineT.NEXT = 0;
                lTextot.SETRANGE(lTextot."Nº proyecto", rJobt."No.");
                if lTextot.FINDFIRST THEN
                    REPEAT
                        lTexto2.CHANGECOMPANY(rJobt."Bill-to Contact");
                        lTexto2 := lTextot;
                        lTexto2."Nº proyecto" := rJob2."No.";
                        if lTexto2.INSERT THEN;
                    UNTIL lTextot.NEXT = 0;

            UNTIL rJobt.NEXT = 0;
    END;

    PROCEDURE PendienteTraspasoEmpresas(VAR rJob: Record Job): Boolean;
    VAR
        rJob2: Record Job;
        JobPlanningLine: Record 1003;
        JobPlanningLine2: Record 1003;
        JobTask: Record 1001;
        JobTask2: Record 1001;
        JobPlanningLineT: Record 1003 temporary;
        JobTaskt: Record 1001 temporary;
        rJobt: Record Job temporary;
        rRes: Record "Resource";
        rEmp: Record 2000000006;
        CMan: Codeunit "No. Series";
        JobSetup: Record 315;
        rCli: Record "Customer";
        rSo: Record 413;
        rInf: Record "Company Information";
    BEGIN
        JobPlanningLine.SETRANGE(JobPlanningLine."Job No.", rJob."No.");
        if JobPlanningLine.FINDFIRST THEN
            REPEAT
                if rRes.GET(JobPlanningLine."No.") THEN BEGIN
                    if (rRes."Empresa Origen" <> COMPANYNAME)
                    AND (rRes."Nº En Empresa origen" <> '') THEN BEGIN
                        rEmp.GET(rRes."Empresa Origen");
                        rInf.ChangeCompany(rEmp.Name);
                        rInf.Get();
                        rJobt := rJob;
                        rJobt."Bill-to Contact" := rEmp.Name;
                        rJobt."No." := rInf."Clave Recursos";
                        rJobt."Proyecto en empresa Origen" := rJob."No.";
                        rJobt."Empresa Origen" := COMPANYNAME;
                        if rJobt.INSERT THEN;
                        JobPlanningLineT := JobPlanningLine;
                        JobPlanningLineT."Job No." := rInf."Clave Recursos";
                        JobPlanningLineT."No." := rRes."Nº En Empresa origen";
                        JobPlanningLineT.INSERT;
                        JobTask.SETRANGE(JobTask."Job No.", JobPlanningLine."Job No.");
                        if JobTask.FINDFIRST THEN
                            REPEAT
                                JobTaskt := JobTask;
                                JobTaskt."Job No." := rInf."Clave Recursos";
                                if JobTaskt.INSERT THEN;
                            UNTIL JobTask.NEXT = 0;
                    END;
                END;
            UNTIL JobPlanningLine.NEXT = 0;
        if rJobt.FINDFIRST THEN
            REPEAT
                CLEAR(cMan);
                rJob2.CHANGECOMPANY(rJobt."Bill-to Contact");
                rJob2.SETCURRENTKEY(rJob2."Proyecto en empresa Origen");
                rJob2.SETRANGE(rJob2."Proyecto en empresa Origen", rJob."No.");
                if NOT rJob2.FINDFIRST THEN EXIT(TRUE);
            UNTIL rJobt.NEXT = 0;
        EXIT(FALSE);
    END;

    PROCEDURE DebeTraspasarse(VAR rJob: Record Job): Boolean;
    VAR
        rJob2: Record Job;
        JobPlanningLine: Record 1003;
        JobPlanningLine2: Record 1003;
        JobTask: Record 1001;
        JobTask2: Record 1001;
        JobPlanningLineT: Record 1003 temporary;
        JobTaskt: Record 1001 temporary;
        rJobt: Record Job temporary;
        rRes: Record "Resource";
        rEmp: Record 2000000006;
        CMan: Codeunit "No. Series";
        JobSetup: Record 315;
        rCli: Record "Customer";
        rSo: Record 413;
    BEGIN
        JobPlanningLine.SETRANGE(JobPlanningLine."Job No.", rJob."No.");
        if JobPlanningLine.FINDFIRST THEN
            REPEAT
                if rRes.GET(JobPlanningLine."No.") THEN BEGIN
                    if (rRes."Empresa Origen" <> COMPANYNAME)
                    AND (rRes."Nº En Empresa origen" <> '') THEN BEGIN
                        rEmp.GET(rRes."Empresa Origen");
                        EXIT(TRUE);
                    END;
                END;
            UNTIL JobPlanningLine.NEXT = 0;
        EXIT(FALSE);
    END;

    PROCEDURE MiraReservasOtraEmpresa(VAR rJob: Record Job);
    VAR
        rJob2: Record Job;
        rJobPlanningLine: Record 1003;
        rJobPlanningLine2: Record 1003;
        JobTask: Record 1001;
        JobTask2: Record 1001;
        JobPlanningLinet: Record 1003 temporary;
        JobTaskt: Record 1001 temporary;
        rJobt: Record Job temporary;
        rRes: Record "Resource";
        rEmp: Record 2000000006;
        CMan: Codeunit "No. Series";
        JobSetup: Record 315;
        rCli: Record "Customer";
        rSo: Record 413;
        JobPlanningLine: Record 1003;
        rInf: Record "Company Information";
        Resource: Record "Resource";
    BEGIN
        rJobPlanningLine.SETRANGE(rJobPlanningLine."Job No.", rJob."No.");
        if rJobPlanningLine.FINDFIRST THEN
            REPEAT
                if rRes.GET(rJobPlanningLine."No.") THEN BEGIN
                    if (rRes."Empresa Origen" <> COMPANYNAME)
                    AND (rRes."Nº En Empresa origen" <> '') THEN BEGIN
                        rEmp.GET(rRes."Empresa Origen");
                        rInf.ChangeCompany(rEmp.Name);
                        rInf.Get();
                        rJobt := rJob;
                        rJobt."Bill-to Contact" := rEmp.Name;
                        rJobt."No." := rInf."Clave Recursos";
                        rJobt."Proyecto en empresa Origen" := rJob."No.";
                        rJobt."Empresa Origen" := COMPANYNAME;
                        if rJobt.INSERT THEN;
                        JobPlanningLinet := rJobPlanningLine;
                        JobPlanningLinet."Job No." := rinf."Clave Recursos";
                        JobPlanningLinet."No." := rRes."Nº En Empresa origen";
                        JobPlanningLinet.INSERT;
                        JobTask.SETRANGE(JobTask."Job No.", rJobPlanningLine."Job No.");
                        if JobTask.FINDFIRST THEN
                            REPEAT
                                JobTaskt := JobTask;
                                JobTaskt."Job No." := rInf."Clave Recursos";
                                if JobTaskt.INSERT THEN;
                            UNTIL JobTask.NEXT = 0;
                    END;
                END;
            UNTIL rJobPlanningLine.NEXT = 0;
        if rJobt.FINDFIRST THEN
            REPEAT
                CLEAR(cMan);
                rJob2.CHANGECOMPANY(rJobt."Bill-to Contact");
                rJob2.SETCURRENTKEY(rJob2."Proyecto en empresa Origen");
                rJob2.SETRANGE(rJob2."Proyecto en empresa Origen", rJob."No.");
                rJob2.SETRANGE(rJob2."Empresa Origen", COMPANYNAME);
                rJob2.FINDFIRST;
                JobPlanningLine.CHANGECOMPANY(rJobt."Bill-to Contact");
                JobPlanningLine.SETRANGE("Job No.", rJob2."No.");
                if JobPlanningLine.FIND('-') THEN
                    REPEAT
                        if JobPlanningLine."Cdad. a Reservar" <> 0 THEN begin
                            Resource.ChangeCompany(rJobt."Bill-to Contact");
                            If (Not Resource."Recurso Agrupado") and (Not Resource."Producción") THEN
                                ERROR('Todavia quedan reservas por crear. Ejecute \' +
                                      'la opción "Crear reservas" para todas las lineas del presupuesto \' +
                                      'En la empresa %1 nº de Proyecto %2', rJobt."Bill-to Contact", rJob2."No.");
                        end;
                    UNTIL JobPlanningLine.NEXT = 0;

            UNTIL rJobt.NEXT = 0;
    END;

    PROCEDURE CreaFacturaVenta(VAR rJob: Record Job; VAR Factura: Record "Sales Header"; PostingDescription: Text);
    VAR
        JobOtraEmpresa: Record Job;
        rJobPlanigLine: Record 1003;
        rJobPlanigLineOtraEmpresa: Record 1003;
        rLinContratoVentaOtraEmpresa: Record "Sales Line";
        JobPlanningLineT: Record 1003 temporary;
        JobTask: Record 1001;
        rJobt: Record Job temporary;
        rRes: Record "Resource";
        rEmp: Record 2000000006;
#if CLEAN24
#pragma warning disable AL0432
        cMan: Codeunit NoSeriesManagement;
#pragma warning restore AL0432
#else
        CMan: Codeunit "No. Series";
#endif
        JobSetup: Record 315;
        rCli: Record "Customer";
        rSo: Record 413;
        lSalesHeaderOtraEmpresa: Record "Sales Header";
        lSalesLineOtraEmpresa: Record "Sales Line";
        rCabCompr: Record "Purchase Header";
        rLinCompra: Record "Purchase Line";
        SalesLineFacOrTMP: Record "Sales Line" temporary;
        SalesLineFacOr: Record "Sales Line";
        ConfVtas: Record 311;
        rComentVenta: Record 44;
#if CLEAN24
#pragma warning disable AL0432
        GestNoSer: Codeunit NoSeriesManagement;
#pragma warning restore AL0432
#else
        GestNoSer: Codeunit "No. Series";
#endif
        rClient: Record "Customer";
        rComentProy: Record 97;
        ult: Integer;
        rRecurs: Record "Resource";
        rGCP: Record 251;
        rGCN: Record 250;
        rCGC: Record 252;
        rFamilia: Record 152;
        lTexto: Record "Texto Presupuesto";
        r352: Record 352;
        //r357: Record 357;
        r325: Record 325;
        Currency: Record "Currency";
        rInf: Record "Company Information";
        Vendor: Record Vendor;
        ContratoOtraEmpresa: Record "Sales Header";
        Contrato: Record "Sales Header";
        LinContrato: Record "Sales Line";
        LinContratoOtraEmpresa: Record "Sales Line";
        Ic: Record "IC Setup";
        ConfCompra: Record "Purchases & Payables Setup";
        rComentCompra: Record 43;
    BEGIN
        rClient.GET(Factura."Bill-to Customer No.");
        If rClient."IC Partner Code" <> '' THEN BEGIN
            CreaFacturaCompraOtraEmpresa(Factura);
            exit;
        END;
        ConfCompra.Get();
        SalesLineFacOr.SetRange("Document Type", Factura."Document Type");
        SalesLineFacOr.SetRange("Document No.", Factura."No.");
        SalesLineFacOr.SetFilter(Type, '<>%1', SalesLineFacOr.Type::"G/L Account");
        SalesLineFacOr.FindFirst();
        repeat
            SalesLineFacOrTMP := SalesLineFacOr;
            If (SalesLineFacOr."No linea proyecto" = 0) and (SalesLineFacOr.Type <> SalesLineFacOr.Type::" ") Then begin
                LinContrato.Get(LinContrato."Document Type"::Order, Factura."Nº Contrato", SalesLineFacOr."Line No.");
                If LinContrato."No linea proyecto" = 0 Then
                    if rRes.GET(SalesLineFacOr."No.") THEN
                        if (rRes."Empresa Origen" <> COMPANYNAME)
                        AND (rRes."Nº En Empresa origen" <> '') THEN
                            error('No se pueden crear contratos con recursos de otras empresas, con líneas de contrato que no estén en el proyecto');
                SalesLineFacOrTMP."No linea proyecto" := LinContrato."No linea proyecto";
                SalesLineFacOrTMP."Empresa Compra" := rRes."Empresa Origen";
            end;
            if SalesLineFacOrTMP.Insert() then;
        until SalesLineFacOr.NEXT = 0;
        rJobPlanigLine.SETRANGE(rJobPlanigLine."Job No.", rJob."No.");
        rJobPlanigLine.SetFilter("Compra a-Nº proveedor", '<>%1', '');
        if rJobPlanigLine.FINDFIRST THEN
            REPEAT
                if rRes.GET(rJobPlanigLine."No.") THEN BEGIN
                    if (rRes."Empresa Origen" <> COMPANYNAME)
                    AND (rRes."Nº En Empresa origen" <> '') THEN BEGIN
                        rEmp.GET(rRes."Empresa Origen");
                        rInf.ChangeCompany(rEmp.Name);
                        rInf.Get();
                        rJobt := rJob;
                        rJobt."Bill-to Contact" := rEmp.Name;
                        rJobt."No." := rInf."Clave Recursos";
                        rJobt."Proyecto en empresa Origen" := rJob."No.";
                        rJobt."Empresa Origen" := COMPANYNAME;
                        if rJobt.INSERT THEN;
                        JobPlanningLineT := rJobPlanigLine;
                        JobPlanningLineT."Job No." := rInf."Clave Recursos";
                        SalesLineFacOrTMP.Reset();
                        SalesLineFacOrTMp.SetRange("No linea proyecto", rJobPlanigLine."Line No.");
                        if SalesLineFacOrTMp.FindFirst() Then begin
                            SalesLineFacOrTMp."Empresa Compra" := rEmp.Name;
                            SalesLineFacOrTMp."Empresa Venta" := CompanyName;
                            SalesLineFacOrTMp.Modify();

                        end else begin
                            SalesLineFacOr.SetRange("No linea proyecto");
                            SalesLineFacOr.FindLast();
                            SalesLineFacOrTMp := SalesLineFacOr;
                            //inicio

                            SalesLineFacOrTmp."Document Type" := Factura."Document Type";
                            SalesLineFacOrTmp."Document No." := Factura."No.";
                            ult := SalesLineFacOr."Line No.";
                            repeat
                                ult += 10000;
                                SalesLineFacOrTmp."Line No." := ult;
                            Until SalesLineFacOrTmp.INSERT;
                            SalesLineFacOrTmp."No linea proyecto" := rJobPlanigLine."Line No.";
                            SalesLineFacOrTmp."Sell-to Customer No." := Factura."Sell-to Customer No.";
                            CASE rJobPlanigLine.Type OF
                                rJobPlanigLine.Type::"G/L Account":
                                    SalesLineFacOrTmp.Type := SalesLineFacOrTmp.Type::"G/L Account";
                                rJobPlanigLine.Type::Item:
                                    SalesLineFacOrTmp.Type := SalesLineFacOrTmp.Type::Item;
                                rJobPlanigLine.Type::Resource:
                                    SalesLineFacOrTmp.Type := SalesLineFacOrTmp.Type::Resource;
                                rJobPlanigLine.Type::Familia:
                                    SalesLineFacOrTmp.Type := SalesLineFacOrTmp.Type::"G/L Account";
                            END;
                            if (rJobPlanigLine.Type <> rJobPlanigLine.Type::Familia) THEN BEGIN
                                SalesLineFacOrTmp."No." := rJobPlanigLine."No.";
                                SalesLineFacOrTmp.Description := rJobPlanigLine.Description;
                                if (rJobPlanigLine.Type = rJobPlanigLine.Type::Resource) THEN BEGIN
                                    rRecurs.GET(rJobPlanigLine."No.");
                                    if (rRecurs."Enunciado Cto. Venta" <> '') THEN
                                        SalesLineFacOrTmp.Description := rRecurs."Enunciado Cto. Venta";
                                END;
                            END;
                            //$013(I)
                            if (rJobPlanigLine.Type = rJobPlanigLine.Type::Resource) THEN
                                SalesLineFacOrTmp."Cód. proveedor" := rJobPlanigLine."Compra a-Nº proveedor";
                            //$013(F)
                            SalesLineFacOrTmp."Job No." := rJobPlanigLine."Job No.";               //FCL-28/02/06. Muevo aquí la línea:= se machacaba cód.programa.
                            SalesLineFacOrTmp."Shortcut Dimension 1 Code" := rJobPlanigLine."Shortcut Dimension 1 Code";
                            SalesLineFacOrTmp."Shortcut Dimension 2 Code" := rJobPlanigLine."Shortcut Dimension 2 Code";
                            SalesLineFacOrTmp."Shortcut Dimension 3 Code" := rJobPlanigLine."Shortcut Dimension 3 Code";
                            SalesLineFacOrTmp."Shortcut Dimension 4 Code" := rJobPlanigLine."Shortcut Dimension 4 Code";
                            SalesLineFacOrTmp."Shortcut Dimension 5 Code" := rJobPlanigLine."Shortcut Dimension 5 Code";


                            //SalesLineFacOrTemp."Job No.":= rJobPlanigLine."Job No.";               //FCL-28/02/06.
                            /* { $001
                            SalesLineFacOrTemp."Phase Code":= rJobPlanigLine."Phase Code";
                            SalesLineFacOrTemp."Task Code":= rJobPlanigLine."Task Code";
                            } */
                            SalesLineFacOrTmp."Job Task No." := rJobPlanigLine."Job Task No.";

                            // mig 5.0     rJobPlanigLine.CALCFIELDS(Quantity;
                            SalesLineFacOrTmp.Quantity := rJobPlanigLine.Quantity;
                            SalesLineFacOrTmp."Unit Price" := rJobPlanigLine."Unit Price";
                            SalesLineFacOrTmp."Precio Compra" := rJobPlanigLine."Unit Cost";
                            SalesLineFacOrTmp."Precio Tarifa" := rJobPlanigLine."Precio Tarifa";
                            SalesLineFacOrTmp."Dto. Tarifa" := rJobPlanigLine."Dto. Tarifa";
                            SalesLineFacOrTmp."% Dto. Venta 1" := rJobPlanigLine."% Dto. Venta 1";
                            SalesLineFacOrTmp."% Dto. Venta 2" := rJobPlanigLine."% Dto. Venta 2";
                            SalesLineFacOrTmp."Tipo Duracion" := rJobPlanigLine."Tipo Duracion";
                            SalesLineFacOrTmp.Duracion := rJobPlanigLine.Duracion;
                            SalesLineFacOrTmp."Cdad. Soportes" := rJobPlanigLine."Cdad. Soportes";
                            SalesLineFacOrTmp."Dto. Compra" := rJobPlanigLine."% Dto. Compra";
                            SalesLineFacOrTmp."Line Discount %" := rJobPlanigLine."% Dto. Venta";     // $004
                            SalesLineFacOrTmp.Reparto := rJobPlanigLine.Reparto;                                      //FCL-16/02/06
                            SalesLineFacOrTmp."Fecha inicial recurso" := rJobPlanigLine."Planning Date";              //$006
                            SalesLineFacOrTmp."Fecha final recurso" := rJobPlanigLine."Fecha Final";                  //$006
                            SalesLineFacOrTmp."No linea proyecto" := rJobPlanigLine."Line No.";                       //$008

                            // $003-


                            // $003+
                            SalesLineFacOrTmp."Description 2" := rJobPlanigLine."Description 2";                                       //$011
                            SalesLineFacOrTmp.Remarcar := rJobPlanigLine.Remarcar;                                                     //$014
                            if Not rJobPlanigLine."Imprmir en Contrato/Factura" Then SalesLineFacOrTmp.Imprimir := false;
                            SalesLineFacOrTmp.MODIFY;


                            //fin

                        end;
                        SalesLineFacOr.SetRange("No linea proyecto", rJobPlanigLine."Line No.");
                        if SalesLineFacOr.FindFirst() Then begin
                            SalesLineFacOr."Empresa Compra" := rEmp.Name;
                            SalesLineFacOr."Empresa Venta" := CompanyName;
                            SalesLineFacOr.Modify();
                        end;
                        JobPlanningLineT.Insert();
                        SalesLineFacOrTmp.SetRange("No linea proyecto");
                    END;
                END;
            UNTIL rJobPlanigLine.NEXT = 0;
        if rJobt.FINDFIRST THEN
            REPEAT
                JobOtraEmpresa.CHANGECOMPANY(rJobt."Bill-to Contact");
                JobOtraEmpresa.SETCURRENTKEY(JobOtraEmpresa."Proyecto en empresa Origen");
                JobOtraEmpresa.SETRANGE(JobOtraEmpresa."Proyecto en empresa Origen", rJob."No.");
                JobOtraEmpresa.FINDFIRST;
                rJobPlanigLineOtraEmpresa.ChangeCompany(rJobt."Bill-to Contact");
                rJobPlanigLineOtraEmpresa.SETRANGE("Job No.", JobOtraEmpresa."No.");
                if rJobPlanigLineOtraEmpresa.FIND('-') THEN
                    REPEAT
                        If rJobPlanigLineOtraEmpresa."Unit Price" = 0 THEN begin
                            if rJobPlanigLine.get(rJob."No.", rJobPlanigLineOtraEmpresa."Job Task No.", rJobPlanigLineOtraEmpresa."Line No.") then begin
                                If rJobPlanigLine."Unit Cost" = 0 Then begin
                                    error('El recurso %1 no tiene precio de compra en la linea %2 del proyecto %3', rJobPlanigLine."No.", rJobPlanigLine."Line No.", rJobPlanigLine."Job No.");

                                end;
                                rJobPlanigLineOtraEmpresa."Unit Price" := rJobPlanigLine."Unit Cost";
                                rJobPlanigLineOtraEmpresa."% Dto. Venta 1" := rJobPlanigLine."% Dto. Compra";
                                rJobPlanigLineOtraEmpresa."% Dto. Venta" := rJobPlanigLineOtraEmpresa."% Dto. Venta 1";
                                rJobPlanigLineOtraEmpresa."Total Price (LCY)" := ROUND(rJobPlanigLineOtraEmpresa."Unit Price (LCY)" *
                                rJobPlanigLineOtraEmpresa.Quantity * (1 - rJobPlanigLineOtraEmpresa."% Dto. Venta" / 100), Currency."Amount Rounding Precision");
                                rJobPlanigLineOtraEmpresa."Total Price" := ROUND(rJobPlanigLineOtraEmpresa.Quantity * rJobPlanigLineOtraEmpresa."Unit Price" * (1 - rJobPlanigLineOtraEmpresa."% Dto. Venta" / 100), Currency."Amount Rounding Precision");
                                rJobPlanigLineOtraEmpresa."Line Amount" := rJobPlanigLineOtraEmpresa."Line Amount" * (1 - rJobPlanigLineOtraEmpresa."% Dto. Venta" / 100);
                            end;

                        end;
                    UNTIL rJobPlanigLineOtraEmpresa.NEXT = 0;
                Ic.ChangeCompany(rJobt."Bill-to Contact");
                Ic.Get();
                ContratoOtraEmpresa.CHANGECOMPANY(rJobt."Bill-to Contact");
                ContratoOtraEmpresa.SetRange("Nº Proyecto", JobOtraEmpresa."No.");
                ContratoOtraEmpresa.FindFirst();
                ContratoOtraEmpresa.Estado := ContratoOtraEmpresa.Estado::Firmado;
                ContratoOtraEmpresa."Fecha Estado" := WorkDate();
                ContratoOtraEmpresa."Facturacion Iniciada" := TRUE;
                rLinContratoVentaOtraEmpresa.CHANGECOMPANY(rJobt."Bill-to Contact");
                rLinContratoVentaOtraEmpresa.SETRANGE("Document No.", ContratoOtraEmpresa."No.");
                if rLinContratoVentaOtraEmpresa.FIND('-') THEN
                    REPEAT
                        if (rLinContratoVentaOtraEmpresa."Unit Price" = 0) and (LinContratoOtraEmpresa."No." <> '') THEN begin
                            Error('La linea %1 del contrato %2 no tiene precio de venta', rLinContratoVentaOtraEmpresa."Line No.", rLinContratoVentaOtraEmpresa."Document No.");
                            // rJobPlanigLineOtraEmpresa.SetRange("Job No.", ContratoOtraEmpresa."Nº Proyecto");
                            // rJobPlanigLineOtraEmpresa.SETRANGE("Line No.", rLinContratoVentaOtraEmpresa."Line No.");
                            // If rJobPlanigLineOtraEmpresa.FindFirst() Then begin
                            //     rLinContratoVentaOtraEmpresa.Validate("Unit Price", rJobPlanigLineOtraEmpresa."Unit price");
                            //     rLinContratoVentaOtraEmpresa.Validate("% Dto. Venta 1", rJobPlanigLineOtraEmpresa."% Dto. Venta 1");
                            //     rLinContratoVentaOtraEmpresa.Modify();
                            // end

                        end;
                    UNTIL rLinContratoVentaOtraEmpresa.NEXT = 0;
                ContratoOtraEmpresa.Modify();
                Vendor.SetRange("IC Partner Code", Ic."IC Partner Code");
                Vendor.FindFirst();
                lSalesHeaderOtraEmpresa.LOCKTABLE;
                lSalesLineOtraEmpresa.LOCKTABLE;
                ConfVtas.LOCKTABLE;
                rComentVenta.LOCKTABLE;
                lSalesHeaderOtraEmpresa.CHANGECOMPANY(rJobt."Bill-to Contact");
                lSalesLineOtraEmpresa.CHANGECOMPANY(rJobt."Bill-to Contact");
                SalesLineFacOrTmp.SetRange("Empresa Compra", rJobt."Bill-to Contact");
                ConfVtas.CHANGECOMPANY(rJobt."Bill-to Contact");
                rComentVenta.CHANGECOMPANY(rJobt."Bill-to Contact");
                ConfVtas.GET;
                ConfVtas.TESTFIELD("Invoice Nos.");
                ConfVtas.TESTFIELD("Posted Invoice Nos.");
                ConfVtas.TESTFIELD("Posted Shipment Nos.");
                ConfVtas.TESTFIELD("Posted Prepmt. Inv. Nos.");
                //CLEAR(rCab);
                rClient.CHANGECOMPANY(rJobt."Bill-to Contact");
                rClient.GET(JobOtraEmpresa."Bill-to Customer No.");
                lSalesHeaderOtraEmpresa.SETCURRENTKEY("Nº Proyecto");
                lSalesHeaderOtraEmpresa.SETRANGE("Nº Proyecto", JobOtraEmpresa."No.");
                lSalesHeaderOtraEmpresa."Document Type" := lSalesHeaderOtraEmpresa."Document Type"::Invoice;
                lSalesHeaderOtraEmpresa."No." := GetNextNoEmp(ConfVtas."Invoice Nos.", WORKDATE, TRUE, rJobt."Bill-to Contact");
                lSalesHeaderOtraEmpresa.INSERT(FALSE);
                lSalesHeaderOtraEmpresa.Validate("Posting Description", Factura."Posting Description");
                lSalesHeaderOtraEmpresa."Posting Description" := PostingDescription;
                lSalesHeaderOtraEmpresa."Your Reference" := Factura."No.";
                lSalesHeaderOtraEmpresa."No. Series" := ConfVtas."Invoice Nos.";
                lSalesHeaderOtraEmpresa."Posting No. Series" := ConfVtas."Posted Invoice Nos.";
                lSalesHeaderOtraEmpresa."Shipping No. Series" := ConfVtas."Posted Shipment Nos.";
                lSalesHeaderOtraEmpresa."Prepayment No. Series" := ConfVtas."Posted Prepmt. Inv. Nos.";
                lSalesHeaderOtraEmpresa."Posting Date" := Factura."Posting Date";
                lSalesHeaderOtraEmpresa."Document Date" := Factura."Document Date";
                lSalesHeaderOtraEmpresa."Shipment Date" := Factura."Shipment Date";
                lSalesHeaderOtraEmpresa."Order Date" := Factura."Order Date";
                lSalesHeaderOtraEmpresa."Due Date" := Factura."Due Date";
                lSalesHeaderOtraEmpresa."VAT Reporting Date" := Factura."VAT Reporting Date";
                lSalesHeaderOtraEmpresa."Payment Terms Code" := rClient."Payment Terms Code";
                lSalesHeaderOtraEmpresa."Payment Method Code" := rClient."Payment Method Code";
                lSalesHeaderOtraEmpresa."Posting Description" := FORMAT(lSalesHeaderOtraEmpresa."Document Type") + ' ' + lSalesHeaderOtraEmpresa."No.";
                lSalesHeaderOtraEmpresa."Sell-to Customer No." := JobOtraEmpresa."Bill-to Customer No.";
                lSalesHeaderOtraEmpresa."Bill-to Customer No." := JobOtraEmpresa."Bill-to Customer No.";
                lSalesHeaderOtraEmpresa."Bill-to Name" := rClient.Name;
                lSalesHeaderOtraEmpresa."Bill-to Name 2" := rClient."Name 2";
                lSalesHeaderOtraEmpresa."Bill-to Address" := rClient.Address;
                lSalesHeaderOtraEmpresa."Bill-to Address 2" := rClient."Address 2";
                lSalesHeaderOtraEmpresa."Bill-to City" := rClient.City;
                lSalesHeaderOtraEmpresa."Bill-to Contact No." := rClient."Primary Contact No.";
                lSalesHeaderOtraEmpresa."Sell-to Customer Name" := rClient.Name;
                lSalesHeaderOtraEmpresa."Sell-to Customer Name 2" := rClient."Name 2";
                lSalesHeaderOtraEmpresa."Sell-to Address" := rClient.Address;
                lSalesHeaderOtraEmpresa."Sell-to Address 2" := rClient."Address 2";
                lSalesHeaderOtraEmpresa."Sell-to City" := rClient.City;
                lSalesHeaderOtraEmpresa."Bill-to Post Code" := rClient."Post Code";
                lSalesHeaderOtraEmpresa."Bill-to County" := rClient.County;
                lSalesHeaderOtraEmpresa."Bill-to Country/Region Code" := rClient."Country/Region Code";
                lSalesHeaderOtraEmpresa."Sell-to Post Code" := rClient."Post Code";
                lSalesHeaderOtraEmpresa."Sell-to County" := rClient.County;
                lSalesHeaderOtraEmpresa."Sell-to Country/Region Code" := rClient."Country/Region Code";
                lSalesHeaderOtraEmpresa."Ship-to Name" := rClient.Name;
                lSalesHeaderOtraEmpresa."Ship-to Name 2" := rClient."Name 2";
                lSalesHeaderOtraEmpresa."Ship-to Address" := rClient.Address;
                lSalesHeaderOtraEmpresa."Ship-to Address 2" := rClient."Address 2";
                lSalesHeaderOtraEmpresa."Ship-to City" := rClient.City;
                lSalesHeaderOtraEmpresa."Ship-to Post Code" := rClient."Post Code";
                lSalesHeaderOtraEmpresa."Ship-to County" := rClient.County;
                lSalesHeaderOtraEmpresa."Ship-to Country/Region Code" := rClient."Country/Region Code";
                lSalesHeaderOtraEmpresa."Customer Posting Group" := rClient."Customer Posting Group";
                lSalesHeaderOtraEmpresa."Your Reference" := 'Proyecto ' + JobOtraEmpresa."No.";
                lSalesHeaderOtraEmpresa."Nº Proyecto" := JobOtraEmpresa."No.";
                lSalesHeaderOtraEmpresa."Nº Contrato" := ContratoOtraEmpresa."No.";
                lSalesHeaderOtraEmpresa."VAT Registration No." := rClient."VAT Registration No.";
                if rClient."Salesperson Code" = '' THEN
                    lSalesHeaderOtraEmpresa."Salesperson Code" := JobOtraEmpresa."Cód. vendedor"
                ELSE
                    lSalesHeaderOtraEmpresa."Salesperson Code" := rClient."Salesperson Code";
                lSalesHeaderOtraEmpresa."Posting Description" := JobOtraEmpresa.Description;
                lSalesHeaderOtraEmpresa.Validate("Fecha inicial proyecto", JobOtraEmpresa."Starting Date");
                lSalesHeaderOtraEmpresa.Validate("Fecha fin proyecto", JobOtraEmpresa."Ending Date");
                lSalesHeaderOtraEmpresa."Shortcut Dimension 1 Code" := JobOtraEmpresa."Global Dimension 1 Code";
                lSalesHeaderOtraEmpresa."Shortcut Dimension 2 Code" := JobOtraEmpresa."Global Dimension 2 Code";
                if JobOtraEmpresa."Esperar Orden Cliente" = TRUE THEN
                    lSalesHeaderOtraEmpresa."Esperar Orden Cliente" := lSalesHeaderOtraEmpresa."Esperar Orden Cliente"::"Sí";
                lSalesHeaderOtraEmpresa.Tipo := JobOtraEmpresa.Tipo;
                lSalesHeaderOtraEmpresa.Firmado := JobOtraEmpresa.Firmado;
                lSalesHeaderOtraEmpresa."Fecha Firma" := JobOtraEmpresa."Fecha Firma";
                lSalesHeaderOtraEmpresa.Subtipo := JobOtraEmpresa.Subtipo;
                lSalesHeaderOtraEmpresa."Soporte de" := JobOtraEmpresa."Soporte de";
                lSalesHeaderOtraEmpresa."Interc./Compens." := JobOtraEmpresa."Interc./Compens.";         //FCL-18/05/04
                lSalesHeaderOtraEmpresa."Proyecto origen" := JobOtraEmpresa."Proyecto original";          //FCL-18/05/04
                lSalesHeaderOtraEmpresa.Renovado := JobOtraEmpresa.Renovado;                   //FCL-18/05/04
                lSalesHeaderOtraEmpresa."External Document No." := JobOtraEmpresa."No Documento externo";     //$010
                                                                                                              //$012(I)
                lSalesHeaderOtraEmpresa."Payment Method Code" := rClient."Payment Method Code";
                lSalesHeaderOtraEmpresa."Gen. Bus. Posting Group" := rClient."Gen. Bus. Posting Group";
                lSalesHeaderOtraEmpresa."VAT Bus. Posting Group" := rClient."VAT Bus. Posting Group";
                //$012(F)
                if rClient."Cód. envio genérico" <> '' THEN
                    lSalesHeaderOtraEmpresa."Ship-to Code" := rClient."Cód. envio genérico";
                lSalesHeaderOtraEmpresa."Cód. términos facturacion" := TermFact(lSalesHeaderOtraEmpresa, rJobt."Bill-to Contact", Factura."Cód. términos facturacion");
                lSalesHeaderOtraEmpresa."Posting Description" := PostingDescription;
                lSalesHeaderOtraEmpresa.MODIFY(FALSE);
                //{ *** Tambien se traspasan los comentarios *** }
                rComentProy.CHANGECOMPANY(rJobt."Bill-to Contact");
                rComentProy.SETCURRENTKEY("Table Name", "No.", "Line No.");
                rComentProy.SETRANGE("Table Name", rComentProy."Table Name"::Job);
                rComentProy.SETRANGE("No.", JobOtraEmpresa."No.");
                if rComentProy.FIND('-') THEN
                    REPEAT
                        rComentVenta.INIT;
                        rComentVenta."Document Type" := lSalesHeaderOtraEmpresa."Document Type";
                        rComentVenta."No." := lSalesHeaderOtraEmpresa."No.";
                        rComentVenta."Line No." := rComentProy."Line No.";
                        rComentVenta.Date := rComentProy.Date;
                        rComentVenta.Code := rComentProy.Code;
                        rComentVenta.Comment := rComentProy.Comment;
                        rComentVenta.INSERT;
                    UNTIL rComentProy.NEXT = 0;

                ult := 10000;
                //rJobPlanigLine.CHANGECOMPANY(rJobt."Bill-to Contact");
                r352.CHANGECOMPANY(rJobt."Bill-to Contact");
                //r357.CHANGECOMPANY(rJobt."Bill-to Contact");

                //rJobPlanigLine.SETRANGE(rJobPlanigLine."Job No.", JobOtraEmpresa."No.");
                lSalesLineOtraEmpresa.CHANGECOMPANY(rJobt."Bill-to Contact");
                If SalesLineFacOrTmp.FindFirst() Then
                    REPEAT
                        JobPlanningLineT.SetRange("Line No.", SalesLineFacOrTmp."No linea proyecto");
                        //if (SalesLineFacOrTemp.Type <> SalesLineFacOrTemp.Type::" ") then
                        //  if Not JobPlanningLineT.FindFirst() Then error('No se ha encontrado la linea de proyecto %1', SalesLineFacOrTemp."No linea proyecto");
                        if JobPlanningLineT.FindFirst() Then begin
                            //CLEAR(rLin);
                            lSalesLineOtraEmpresa := SalesLineFacOrTmp;
                            lSalesLineOtraEmpresa."Job No." := lSalesHeaderOtraEmpresa."Nº Proyecto";
                            lSalesLineOtraEmpresa."Document Type" := lSalesHeaderOtraEmpresa."Document Type";
                            lSalesLineOtraEmpresa."Document No." := lSalesHeaderOtraEmpresa."No.";
                            lSalesLineOtraEmpresa."Line No." := ult;
                            ult += 10000;
                            lSalesLineOtraEmpresa.INSERT;
                            lSalesLineOtraEmpresa."Linea Origen" := SalesLineFacOrTmp."Line No.";
                            lSalesLineOtraEmpresa."Contrato Origen" := SalesLineFacOrTmp."Document No.";
                            lSalesLineOtraEmpresa."Empresa Compra" := CompanyName;
                            lSalesLineOtraEmpresa."Sell-to Customer No." := lSalesHeaderOtraEmpresa."Sell-to Customer No.";
                            lSalesLineOtraEmpresa.Type := SalesLineFacOrTmp.Type;
                            lSalesLineOtraEmpresa."No." := SalesLineFacOrTmp."No.";
                            lSalesLineOtraEmpresa.Description := SalesLineFacOrTmp.Description;
                            if (SalesLineFacOrTmp.Type = SalesLineFacOrTmp.Type::Resource) THEN BEGIN
                                rRecurs.CHANGECOMPANY(CompanyName);
                                rRecurs.GET(SalesLineFacOrTmp."No.");
                                if rRecurs."Nº En Empresa origen" = '' then
                                    ERROR('Compruebe el Recurso %1, está mal creado', SalesLineFacOrTmp."No.");
                                lSalesLineOtraEmpresa."No." := rRecurs."Nº En Empresa origen";
                                rRecurs.CHANGECOMPANY(rJobt."Bill-to Contact");

                                rRecurs.Get(lSalesLineOtraEmpresa."No.");
                                lSalesLineOtraEmpresa."Gen. Prod. Posting Group" := rRecurs."Gen. Prod. Posting Group";
                                lSalesLineOtraEmpresa."VAT Prod. Posting Group" := rRecurs."VAT Prod. Posting Group";
                                lSalesLineOtraEmpresa."Unit of Measure Code" := rRecurs."Base Unit of Measure";
                                r352.SETRANGE(r352."Table ID", 156);
                                r352.SETRANGE(r352."No.", SalesLineFacOrTmp."No.");
                                if r352.FINDFIRST THEN
                                    REPEAT
                                        case r352."Dimension Code" of
                                            'DEPARTAMENTO':
                                                lSalesLineOtraEmpresa.Validate("Shortcut Dimension 1 Code", r352."Dimension Value Code");
                                            'PROGRAMA':
                                                lSalesLineOtraEmpresa.Validate("Shortcut Dimension 2 Code", r352."Dimension Value Code");
                                            'PRINCIPAL':
                                                lSalesLineOtraEmpresa.Validate("Shortcut Dimension 3 Code", r352."Dimension Value Code");
                                            'SOPORTE':
                                                lSalesLineOtraEmpresa.Validate("Shortcut Dimension 5 Code", r352."Dimension Value Code");
                                            'ZONA':
                                                lSalesLineOtraEmpresa.Validate("Shortcut Dimension 4 Code", r352."Dimension Value Code");
                                        end;
                                    /* r357."Table ID" := 37;
                                    r357."Document Type" := r357."Document Type"::Order;
                                    r357."Document No." := rCab."No.";
                                    r357."Line No." := rLin."Line No.";
                                    r357."Dimension Code" := r352."Dimension Code";
                                    r357."Dimension Value Code" := r352."Dimension Value Code";
                                    r357.INSERT; */
                                    UNTIL r352.NEXT = 0;
                                if (rRecurs."Enunciado Cto. Venta" <> '') THEN
                                    lSalesLineOtraEmpresa.Description := rRecurs."Enunciado Cto. Venta";
                                lSalesLineOtraEmpresa."Gen. Bus. Posting Group" := lSalesHeaderOtraEmpresa."Gen. Bus. Posting Group";
                                lSalesLineOtraEmpresa."Gen. Prod. Posting Group" := rRecurs."Gen. Prod. Posting Group";
                                lSalesLineOtraEmpresa."VAT Bus. Posting Group" := rClient."VAT Bus. Posting Group";
                                lSalesLineOtraEmpresa."VAT Prod. Posting Group" := rRecurs."VAT Prod. Posting Group";
                                r325.CHANGECOMPANY(rJobt."Bill-to Contact");
                                if r325.GET(lSalesLineOtraEmpresa."VAT Bus. Posting Group", lSalesLineOtraEmpresa."VAT Prod. Posting Group") THEN
                                    lSalesLineOtraEmpresa."VAT %" := r325."VAT %";
                                lSalesLineOtraEmpresa."Dto. Tarifa" := JobPlanningLineT."Dto. Tarifa";
                                lSalesLineOtraEmpresa."% Dto. Venta 1" := JobPlanningLineT."% Dto. Venta 1";

                            END;

                            //$013(I)
                            if (SalesLineFacOrTmp.Type = SalesLineFacOrTmp.Type::Resource) THEN
                                lSalesLineOtraEmpresa."Cód. proveedor" := SalesLineFacOrTmp."Cód. proveedor";
                            //$013(F)
                            lSalesLineOtraEmpresa."Job No." := SalesLineFacOrTmp."Job No.";               //FCL-28/02/06. Muevo aquí la línea:= se machacaba cód.programa.
                            lSalesLineOtraEmpresa."Shortcut Dimension 1 Code" := SalesLineFacOrTmp."Shortcut Dimension 1 Code";
                            lSalesLineOtraEmpresa."Shortcut Dimension 2 Code" := SalesLineFacOrTmp."Shortcut Dimension 2 Code";
                            //rLin."Job No.":= rJobPlanigLine."Job No.";               //FCL-28/02/06.
                            /* { $001
                              rLin."Phase Code":= rJobPlanigLine."Phase Code";
                              rLin."Task Code":= rJobPlanigLine."Task Code";
                            } */
                            lSalesLineOtraEmpresa."Job Task No." := SalesLineFacOrTmp."Job Task No.";

                            // mig 5.0     rJobPlanigLine.CALCFIELDS(Quantity);
                            lSalesLineOtraEmpresa.Quantity := SalesLineFacOrTmp.Quantity;
                            lSalesLineOtraEmpresa.Duracion := SalesLineFacOrTmp.Duracion;
                            lSalesLineOtraEmpresa."Tipo Duracion" := SalesLineFacOrTmp."Tipo Duracion";
                            lSalesLineOtraEmpresa."Cdad. Soportes" := SalesLineFacOrTmp."Cdad. Soportes";
                            if SalesLineFacOrTmp."Precio Compra" = 0 then begin
                                Error('El recurso %1  no tiene precio de compra', SalesLineFacOrTmp."No.");

                            end else begin
                                lSalesLineOtraEmpresa."Unit Price" := SalesLineFacOrTmp."Precio Compra";
                                lSalesLineOtraEmpresa."Line Discount %" := SalesLineFacOrTmp."Dto. Compra";
                                lSalesLineOtraEmpresa."% Dto. Venta 1" := SalesLineFacOrTmp."Dto. Compra";    // $004
                            end;
                            Currency.INIT;
                            lSalesLineOtraEmpresa."Line Discount Amount" :=
                            ROUND(
                              ROUND(lSalesLineOtraEmpresa.Quantity * lSalesLineOtraEmpresa."Unit Price", Currency."Amount Rounding Precision") *
                              lSalesLineOtraEmpresa."Line Discount %" / 100, Currency."Amount Rounding Precision");
                            lSalesLineOtraEmpresa.Reparto := SalesLineFacOrTmp.Reparto;
                            lSalesLineOtraEmpresa."Line Amount" := lSalesLineOtraEmpresa.Quantity * lSalesLineOtraEmpresa."Unit Price" * (1 - lSalesLineOtraEmpresa."Line Discount %" / 100);
                            lSalesLineOtraEmpresa.Amount := lSalesLineOtraEmpresa."Line Amount";
                            lSalesLineOtraEmpresa."Amount Including VAT" := lSalesLineOtraEmpresa.Amount * (1 + lSalesLineOtraEmpresa."VAT %" / 100);
                            lSalesLineOtraEmpresa."Fecha inicial recurso" := SalesLineFacOrTmp."Fecha Inicial recurso";              //$006
                            lSalesLineOtraEmpresa."Fecha final recurso" := SalesLineFacOrTmp."Fecha Final Recurso";                  //$006
                            lSalesLineOtraEmpresa."No linea proyecto" := SalesLineFacOrTmp."No linea proyecto";                       //$008

                            // $003-  No insertamos ordenes de publicidad
                            //rPresup.CALCFIELDS("No. Orden Publicidad");
                            lSalesLineOtraEmpresa."Description 2" := SalesLineFacOrTmp."Description 2";                                       //$011
                            lSalesLineOtraEmpresa.Remarcar := SalesLineFacOrTmp.Remarcar;
                            lSalesLineOtraEmpresa.Modify();
                            LUpdateAmounts(rJobt."Bill-to Contact", lSalesLineOtraEmpresa, lSalesHeaderOtraEmpresa);
                            lSalesLineOtraEmpresa.MODIFY;
                            SalesLineFacOrTmp."Doc. Itercompany Venta" := lSalesHeaderOtraEmpresa."No.";
                            SalesLineFacOrTmp."Empresa Venta" := rJobt."Bill-to Contact";
                            SalesLineFacOrTmp."Empresa Compra" := CompanyName;
                            SalesLineFacOrTmp.Modify();

                            // $002  y parte del $003
                            // No insertamos ordenes de publicidad
                            lTexto.CHANGECOMPANY(rJobt."Bill-to Contact");
                            lTexto.SETRANGE("Nº proyecto", SalesLineFacOrTmp."Job No.");
                            lTexto.SETRANGE("Nº linea aux", SalesLineFacOrTmp."No linea proyecto");
                            lTexto.SETRANGE("Cód. tarea", SalesLineFacOrTmp."Job Task No.");                      //$009
                            lTexto.SETFILTER("Tipo linea", '%1|%2', lTexto."Tipo linea"::Ambos, lTexto."Tipo linea"::Venta);
                            if lTexto.FINDSET THEN
                                REPEAT
                                    if (lTexto.Texto <> '') THEN BEGIN
                                        CLEAR(lSalesLineOtraEmpresa);
                                        lSalesLineOtraEmpresa.CHANGECOMPANY(rJobt."Bill-to Contact");
                                        lSalesLineOtraEmpresa."Document Type" := lSalesHeaderOtraEmpresa."Document Type";
                                        lSalesLineOtraEmpresa."Document No." := lSalesHeaderOtraEmpresa."No.";
                                        lSalesLineOtraEmpresa."Line No." := ult;
                                        ult += 1000;
                                        lSalesLineOtraEmpresa.INSERT;
                                        lSalesLineOtraEmpresa.Type := lSalesLineOtraEmpresa.Type::" ";
                                        lSalesLineOtraEmpresa.Description := lTexto.Texto;
                                        lSalesLineOtraEmpresa.Remarcar := lTexto.Remarcar;                             //$014
                                        lSalesLineOtraEmpresa.MODIFY;
                                    END;
                                UNTIL lTexto.NEXT = 0;
                            // $002+ y $003+
                        end;
                    UNTIL SalesLineFacOrTmp.NEXT = 0;
                ///////////////Crear factua Copmpra
                rCabCompr.Init();
                rCabCompr."Buy-from Vendor No." := Vendor."No.";
                rCabCompr."Document Type" := rCabCompr."Document Type"::Invoice;
                rCabCompr."No." := GestNoSer.GetNextNo(ConfCompra."Invoice Nos.", WORKDATE, TRUE);
                rCabCompr.INSERT(FALSE);
                rCabCompr.VALIDATE("No. Series", ConfCompra."Order Nos.");
                rCabCompr.VALIDATE("Posting No. Series", ConfCompra."Posted Invoice Nos.");
                rCabCompr.VALIDATE("Receiving No. Series", ConfCompra."Posted Receipt Nos.");
                rCabCompr.VALIDATE("Posting Date", rJob."Starting Date");
                rCabCompr.VALIDATE("Document Date", rCabCompr."Posting Date");
                rCabCompr.VALIDATE("Expected Receipt Date", WORKDATE);
                rCabCompr.VALIDATE("Order Date", WORKDATE);
                rCabCompr.VALIDATE("Posting Description", Factura."Posting Description");
                rCabCompr.VALIDATE("Buy-from Vendor No.", Vendor."No.");
                rCabCompr.VALIDATE("Your Reference", 'Proyecto ' + rJob."No.");
                rCabCompr."Vendor Order No." := lSalesHeaderOtraEmpresa."No.";
                rCabCompr.VALIDATE("Nº Proyecto", rJob."No.");
                Contrato.Get(Contrato."Document Type"::"Order", Factura."Nº Contrato");
                rCabCompr."Nº Contrato" := Contrato."No.";
                rCabCompr.VALIDATE("Purchaser Code", Vendor."Purchaser Code");
                rCabCompr.VALIDATE("Fecha inicial proyecto", rJob."Starting Date");
                rCabCompr.VALIDATE("Fecha fin proyecto", rJob."Ending Date");
                rCabCompr.VALIDATE(Firmado, rJob.Firmado);
                rCabCompr.VALIDATE("Fecha Firma", rJob."Fecha Firma");
                rCabCompr.VALIDATE("Shortcut Dimension 1 Code", rJob."Global Dimension 1 Code");
                rCabCompr.VALIDATE("Shortcut Dimension 2 Code", rJob."Global Dimension 2 Code");
                rCabCompr."Empresa Factura" := rJobt."Bill-to Contact";
                rCabCompr."Posting Description" := Factura."Posting Description";
                rCabCompr.MODIFY(FALSE);
                //{ *** Tambien se traspasan los comentarios *** }
                rComentProy.SETCURRENTKEY("Table Name", "No.", "Line No.");
                rComentProy.SETRANGE("Table Name", rComentProy."Table Name"::Job);
                rComentProy.SETRANGE("No.", rJob."No.");
                if rComentProy.FIND('-') THEN
                    REPEAT
                        rComentCompra.INIT;
                        rComentCompra."Document Type" := rCabCompr."Document Type";
                        rComentCompra."No." := rCabCompr."No.";
                        rComentCompra."Line No." := rComentProy."Line No.";
                        rComentCompra.Date := rComentProy.Date;
                        rComentCompra.Code := rComentProy.Code;
                        rComentCompra.Comment := rComentProy.Comment;
                        rComentCompra.INSERT;
                    UNTIL rComentProy.NEXT = 0;

                /* { Ya viene del codeunit
                rPresup.RESET;
                rPresup.SETRANGE("Nº proyecto", rJob."Nº");    } */
                lSalesHeaderOtraEmpresa."Empresa Origen Alb" := CompanyName;
                lSalesHeaderOtraEmpresa."Factura Compra" := rCabCompr."No.";
                lSalesHeaderOtraEmpresa.MODIFY(FALSE);
                ult := 10000;
                SalesLineFacOrTmp.Reset();
                SalesLineFacOrTmp.SetRange("Document Type", Factura."Document Type");
                SalesLineFacOrTmp.SetRange("Document No.", Factura."No.");
                SalesLineFacOrTmp.FindFirst();
                if SalesLineFacOrTmp.FINDfirst THEN
                    REPEAT
                        JobPlanningLineT.SetRange("Compra a-Nº proveedor");
                        JobPlanningLineT.SetRange("Line No.", SalesLineFacOrTmp."No linea proyecto");
                        //JobPlanningLineT.SetRange("Compra a-Nº proveedor", rCabCompr."Buy-from Vendor No.");
                        //if (SalesLineFacOrTemp.Type <> SalesLineFacOrTemp.Type::" ") then
                        //  if Not JobPlanningLineT.FindFirst() Then error('No se ha encontrado la linea de proyecto %1', SalesLineFacOrTemp."No linea proyecto");
                        JobPlanningLineT.SetRange("Compra a-Nº proveedor", rCabCompr."Buy-from Vendor No.");
                        if JobPlanningLineT.FindFirst() Then begin
                            CLEAR(rLinCompra);
                            rLinCompra.Init();
                            //  rLinCompra.SETRANGE(rLinCompra."Document Type", rLinCompra."Document Type"::invoice);
                            //  rLinCompra.SETRANGE(rLinCompra."Document No.", rCabCompr."No.");
                            //  rLinCompra.SETRANGE("Linea de proyecto", SalesLineFacOrTemp."Line No.");
                            //  if NOT rLinCompra.FINDFIRST THEN BEGIN
                            rLinCompra."Document Type" := rCabCompr."Document Type";
                            rLinCompra."Document No." := rCabCompr."No.";
                            rLinCompra."Line No." := ult;
                            ult += 10000;
                            rlinCompra."Linea Origen" := SalesLineFacOrTmp."Line No.";
                            rLinCompra."Contrato Origen" := SalesLineFacOrTmp."Document No.";
                            rLinCompra."Empresa Venta" := rJobt."Bill-to Contact";
                            rLinCompra.INSERT;
                            rLinCompra.VALIDATE("Buy-from Vendor No.", rCabCompr."Buy-from Vendor No.");
                            rLinCompra.VALIDATE(Type, SalesLineFacOrTmp.Type);
                            rLinCompra.VALIDATE("No.", SalesLineFacOrTmp."No.");
                            rLinCompra.VALIDATE(Description, SalesLineFacOrTmp.Description);
                            rLinCompra.VALIDATE(Quantity, SalesLineFacOrTmp.Quantity);
                            // mig a 5.0     SalesLineFacOrTemp.CALCFIELDS(Quantity);
                            rLinCompra.VALIDATE("Job No.", rCabCompr."Nº Proyecto");
                            rLinCompra.VALIDATE("Job Task No.", SalesLineFacOrTmp."Job Task No.");
                            if SalesLineFacOrTmp."Precio Compra" = 0 then begin
                                Error('El recurso %1  no tiene precio de compra', SalesLineFacOrTmp."No.");
                            end else begin
                                rLinCompra.VALIDATE("Direct Unit Cost", SalesLineFacOrTmp."Precio Compra");
                                rLinCompra.VALIDATE("Line Discount %", SalesLineFacOrTmp."Dto. Compra");    // $004

                            end;                                                       //FCL-23/05/05.
                            rLinCompra.VALIDATE("Shortcut Dimension 1 Code", SalesLineFacOrTmp."Shortcut Dimension 1 Code");
                            rLinCompra.VALIDATE("Shortcut Dimension 2 Code", SalesLineFacOrTmp."Shortcut Dimension 2 Code");
                            rLinCompra.VALIDATE("Shortcut Dimension 3 Code", SalesLineFacOrTmp."Shortcut Dimension 3 Code");
                            rLinCompra.VALIDATE("Shortcut Dimension 4 Code", SalesLineFacOrTmp."Shortcut Dimension 4 Code");
                            rLinCompra.VALIDATE("Shortcut Dimension 5 Code", SalesLineFacOrTmp."Shortcut Dimension 5 Code");

                            rLinCompra.ValidateShortcutDimCode(3, SalesLineFacOrTmp."Shortcut Dimension 3 Code");
                            rLinCompra.ValidateShortcutDimCode(4, SalesLineFacOrTmp."Shortcut Dimension 4 Code");
                            rLinCompra.ValidateShortcutDimCode(5, SalesLineFacOrTmp."Shortcut Dimension 5 Code");

                            rLinCompra."Linea de proyecto" := SalesLineFacOrTmp."Line No.";
                            rLinCompra."Fecha inicial recurso" := SalesLineFacOrTmp."Fecha inicial recurso";
                            rLinCompra."Fecha final recurso" := SalesLineFacOrTmp."Fecha final recurso";
                            rLinCompra."Empresa Origen" := rJob."Empresa Origen";
                            rLinCompra."Proyecto Origen" := rJob."Proyecto en empresa Origen";

                            rLinCompra."Linea de proyecto" := SalesLineFacOrTmp."No linea proyecto";
                            //Fin asc
                            if SalesLineFacOrTmp."Precio Compra" = 0 then begin
                                rLinCompra.VALIDATE("Direct Unit Cost", SalesLineFacOrTmp."Unit Price");
                                rLinCompra."Direct Unit Cost" := SalesLineFacOrTmp."Unit Price";
                            end else begin
                                rLinCompra.VALIDATE("Direct Unit Cost", SalesLineFacOrTmp."Precio Compra");
                                rLinCompra."Direct Unit Cost" := SalesLineFacOrTmp."Precio Compra";
                            end;
                            rLinCompra.Description := SalesLineFacOrTmp.Description;
                            rLinCompra.MODIFY;


                            // $002- y parte del $003

                            lTexto.SETRANGE("Nº proyecto", SalesLineFacOrTmp."Job No.");
                            lTexto.SETRANGE("Nº linea aux", SalesLineFacOrTmp."Line No.");
                            lTexto.SETFILTER("Tipo linea", '%1|%2', lTexto."Tipo linea"::Ambos, lTexto."Tipo linea"::Compra);
                            if lTexto.FINDSET THEN
                                REPEAT
                                    if (lTexto.Texto <> '') THEN BEGIN
                                        CLEAR(rLinCompra);
                                        rLinCompra."Document Type" := rCabCompr."Document Type";
                                        rLinCompra."Document No." := rCabCompr."No.";
                                        rLinCompra."Line No." := ult;
                                        ult += 1000;
                                        rLinCompra.INSERT;
                                        rLinCompra.Type := rLinCompra.Type::" ";
                                        rLinCompra.Description := lTexto.Texto;
                                        rLinCompra.MODIFY;
                                    END;
                                UNTIL lTexto.NEXT = 0;

                            // $002+ y $003+
                            if rLinCompra."No." <> '' Then
                                rLinCompra.VALIDATE(Quantity, SalesLineFacOrTmp.Quantity)
                            else
                                rLinCompra.Quantity := 0;
                            rLinCompra.MODIFY;
                            SalesLineFacOrTmp."Doc Intercompany Compra" := rCabCompr."No.";
                            SalesLineFacOrTmp.Modify();
                        END;
                    // end;
                    UNTIL SalesLineFacOrTmp.NEXT = 0;
            /// 

            UNTIL rJobt.NEXT = 0;
    END;

    procedure CreaFacturaCompraOtraEmpresa(var Factura: Record "Sales Header")
    var
        rCabCompr: Record "Purchase Header";
        rCabCompr2: Record "Purchase Header";
        Vendor: Record Vendor;
        rIc: Record "IC Setup";
        rIcPartner: Record "IC Partner";
        Customer: Record "Customer";
        GestNoSer: Codeunit "Procedures Standard";
        ConfCompra: Record "Purchases & Payables Setup";
        rComentProy: Record 97;
        rComentCompra: Record 43;
        SalesLineFac: Record "Sales Line";
        rLinCompra: Record "Purchase Line" temporary;
        rLinCompraDef: Record "Purchase Line";
        Ult: Integer;
        Recurs: Record "Resource";
        Borrar: Boolean;
        VatPostingSetup: Record "Vat Posting Setup";
        Series: Record "No. Series line";
    begin
        rIc.Get();
        Customer.Get(Factura."Bill-to Customer No.");
        rIcPartner.Get(Customer."IC Partner Code");
        Vendor.ChangeCompany(rIcPartner."Inbox Details");
        ConfCompra.ChangeCompany(rIcPartner."Inbox Details");
        ConfCompra.GET();
        rCabCompr.ChangeCompany(rIcPartner."Inbox Details");
        Vendor.SetRange("IC Partner Code", rIc."IC Partner Code");
        Vendor.FindFirst();
        rCabCompr.Init();
        rCabCompr."Buy-from Vendor No." := Vendor."No.";
        rCabCompr."Document Type" := rCabCompr."Document Type"::Invoice;
        Series.ChangeCompany(rIcPartner."Inbox Details");
        Series.SetRange("Series Code", ConfCompra."Invoice Nos.");
        Series.SetFilter("Starting Date", '<= %1', WORKDATE);
        If not Series.FindLast() then begin
            Series.SetRange("Starting Date");
            If not Series.FindLast() then
                ERROR('No se ha encontrado la serie de facturas de compra');
        end;

        rCabCompr."No." := GestNoSer.GetNextNoEmpresa(Series, WORKDATE, true, TRUE, rIcPartner."Inbox Details");
        rCabCompr.INSERT(FALSE);
        rCabCompr.VALIDATE("No. Series", ConfCompra."Order Nos.");
        rCabCompr.VALIDATE("Posting No. Series", ConfCompra."Posted Invoice Nos.");
        rCabCompr.VALIDATE("Receiving No. Series", ConfCompra."Posted Receipt Nos.");
        rCabCompr.VALIDATE("Posting Date", Factura."Posting Date");
        rCabCompr.VALIDATE("Document Date", rCabCompr."Posting Date");
        rCabCompr.VALIDATE("Expected Receipt Date", WORKDATE);
        rCabCompr.VALIDATE("Order Date", WORKDATE);
        rCabCompr.VALIDATE("Posting Description", Factura."Posting Description");
        rCabCompr."Buy-from Vendor Name" := Vendor.Name;
        rCabCompr."VAT Registration No." := Vendor."VAT Registration No.";
        rCabCompr."Payment Method Code" := Vendor."Payment Method Code";
        rCabCompr."Buy-from Vendor No." := Vendor."No.";
        rCabCompr."Buy-from Address" := Vendor.Address;
        rCabCompr."Buy-from Address 2" := Vendor."Address 2";
        rCabCompr."Buy-from City" := Vendor.City;
        rCabCompr."Buy-from Post Code" := Vendor."Post Code";
        rCabCompr."Buy-from County" := Vendor.County;
        rCabCompr."Buy-from Country/Region Code" := Vendor."Country/Region Code";
        rCabCompr."Purchaser Code" := Vendor."Purchaser Code";
        rCabCompr."Gen. Bus. Posting Group" := Vendor."Gen. Bus. Posting Group";
        rCabCompr."VAT Bus. Posting Group" := Vendor."VAT Bus. Posting Group";
        rCabCompr."Tax Area Code" := Vendor."Tax Area Code";
        rCabCompr."Tax Liable" := Vendor."Tax Liable";
        rCabCompr."VAT Country/Region Code" := Vendor."Country/Region Code";
        rCabCompr."Payment Terms Code" := Vendor."Payment Terms Code";
        rCabCompr.Validate("Lead Time Calculation", Vendor."Lead Time Calculation");
        rCabCompr."Shipment Method Code" := Vendor."Shipment Method Code";
        rCabCompr."Buy-from IC Partner Code" := Vendor."IC Partner Code";
        rCabCompr."Send IC Document" := false;
        rCabCompr."Order Address Code" := '';
        rCabCompr."Pay-to Vendor No." := Vendor."No.";
        rCabCompr."Pay-to Address" := Vendor.Address;
        rCabCompr."Pay-to Address 2" := Vendor."Address 2";
        rCabCompr."Pay-to City" := Vendor.City;
        rCabCompr."Pay-to Post Code" := Vendor."Post Code";
        rCabCompr."Pay-to County" := Vendor.County;
        rCabCompr."Pay-to Country/Region Code" := Vendor."Country/Region Code";
        rCabCompr."Vendor Posting Group" := Vendor."Vendor Posting Group";
        rCabCompr.VALIDATE("Fecha inicial proyecto", Factura."Fecha inicial proyecto");
        rCabCompr.VALIDATE("Fecha fin proyecto", Factura."Fecha fin proyecto");
        rCabCompr.VALIDATE(Firmado, Factura.Firmado);
        rCabCompr.VALIDATE("Fecha Firma", Factura."Fecha Firma");
        rCabCompr.VALIDATE("Shortcut Dimension 1 Code", Factura."ShortCut Dimension 1 Code");
        rCabCompr.VALIDATE("Shortcut Dimension 2 Code", Factura."ShortCut Dimension 2 Code");
        rCabCompr."Empresa Factura" := CompanyName;
        rCabCompr."Posting Description" := Factura."Posting Description";
        rCabCompr.VALIDATE("Your Reference", Factura."Nº Contrato");
        rCabCompr.MODIFY(FALSE);
        rCabCompr2 := rCabCompr;
        If rCabCompr2.Insert() then Borrar := true;
        //{ *** Tambien se traspasan los comentarios *** }
        rComentProy.SETCURRENTKEY("Table Name", "No.", "Line No.");
        rComentProy.SETRANGE("Table Name", rComentProy."Table Name"::Job);
        rComentProy.SETRANGE("No.", Factura."Nº Proyecto");
        rComentCompra.ChangeCompany(rIcPartner."Inbox Details");
        if rComentProy.FIND('-') THEN
            REPEAT
                rComentCompra.INIT;
                rComentCompra."Document Type" := rCabCompr."Document Type";
                rComentCompra."No." := rCabCompr."No.";
                rComentCompra."Line No." := rComentProy."Line No.";
                rComentCompra.Date := rComentProy.Date;
                rComentCompra.Code := rComentProy.Code;
                rComentCompra.Comment := rComentProy.Comment;
                rComentCompra.INSERT;
            UNTIL rComentProy.NEXT = 0;

        SalesLineFac.Reset();
        SalesLineFac.SetRange("Document Type", Factura."Document Type");
        SalesLineFac.SetRange("Document No.", Factura."No.");
        SalesLineFac.FindFirst();

        if SalesLineFac.FINDfirst THEN
            REPEAT
                rLinCompra.Init();
                rLinCompra."Document Type" := rCabCompr."Document Type";
                rLinCompra."Document No." := rCabCompr."No.";
                ult += 10000;
                rLinCompra."Line No." := SalesLineFac."Line No.";

                rLinCompra."Empresa Venta" := CompanyName;
                rLinCompra.INSERT;
                rLinCompra."Buy-from Vendor No." := rCabCompr."Buy-from Vendor No.";
                rLinCompra."Pay-to Vendor No." := rCabCompr."Buy-from Vendor No.";
                rLinCompra.VALIDATE(Type, SalesLineFac.Type);
                rLinCompra.Validate("No.", SalesLineFac."No.");

                //else
                //     rLinCompra.VALIDATE("No.", SalesLineFac."No.");
                // No := rLinCompra."No.";
                rLinCompra.VALIDATE(Description, SalesLineFac.Description);
                rLinCompra.VALIDATE(Quantity, SalesLineFac.Quantity);
                // mig a 5.0     SalesLineFacOrTemp.CALCFIELDS(Quantity);
                rLinCompra.VALIDATE("Direct Unit Cost", SalesLineFac."Unit Price");
                rLinCompra.VALIDATE("Line Discount %", SalesLineFac."Line Discount %");    // $004
                rLinCompra.VALIDATE("Shortcut Dimension 1 Code", SalesLineFac."Shortcut Dimension 1 Code");
                rLinCompra.VALIDATE("Shortcut Dimension 2 Code", SalesLineFac."Shortcut Dimension 2 Code");
                rLinCompra.VALIDATE("Shortcut Dimension 3 Code", SalesLineFac."Shortcut Dimension 3 Code");
                rLinCompra.VALIDATE("Shortcut Dimension 4 Code", SalesLineFac."Shortcut Dimension 4 Code");
                rLinCompra.VALIDATE("Shortcut Dimension 5 Code", SalesLineFac."Shortcut Dimension 5 Code");

                rLinCompra.ValidateShortcutDimCode(3, SalesLineFac."Shortcut Dimension 3 Code");
                rLinCompra.ValidateShortcutDimCode(4, SalesLineFac."Shortcut Dimension 4 Code");
                rLinCompra.ValidateShortcutDimCode(5, SalesLineFac."Shortcut Dimension 5 Code");
                If SalesLineFac.Type = SalesLineFac.Type::Resource then begin
                    Recurs.ChangeCompany(rIcPartner."Inbox Details");
                    Recurs.SetRange("Nº En Empresa origen", SalesLineFac."No.");
                    if Recurs.FindSet() then begin
                        rLinCompra."Vendor Item No." := Recurs."No.";
                        rLinCompra."Gen. Prod. Posting Group" := Recurs."Gen. Prod. Posting Group";
                        rLinCompra."VAT Prod. Posting Group" := Recurs."VAT Prod. Posting Group";
                        VatPostingSetup.ChangeCompany(rIcPartner."Inbox Details");
                        VatPostingSetup.SetRange("VAT Bus. Posting Group", Vendor."VAT Bus. Posting Group");
                        VatPostingSetup.SetRange("VAT Prod. Posting Group", Recurs."VAT Prod. Posting Group");
                        if VatPostingSetup.FindFirst() then
                            If SalesLineFac."VAT %" <> VatPostingSetup."VAT %" then begin
                                VatPostingSetup.SetRange("VAT Prod. Posting Group");
                                VatPostingSetup.SetRange("VAT %", SalesLineFac."VAT %");
                                if VatPostingSetup.FindFirst() then
                                    rLinCompra."VAT Prod. Posting Group" := VatPostingSetup."VAT Prod. Posting Group";
                            end;
                    end;
                end;
                rLinCompra."VAT %" := SalesLineFac."VAT %";
                rLinCompra."Fecha inicial recurso" := SalesLineFac."Fecha inicial recurso";
                rLinCompra."Fecha final recurso" := SalesLineFac."Fecha final recurso";
                rLinCompra."Empresa Origen" := CompanyName;
                rLinCompra."Proyecto Origen" := Factura."Nº Proyecto";

                rLinCompra.Description := SalesLineFac.Description;
                if rLinCompra."No." = '' Then
                    rLinCompra.Quantity := 0;
                rLinCompra.MODIFY;
                SalesLineFac."Doc Intercompany Compra" := rCabCompr."No.";
                SalesLineFac.Modify();
            UNTIL SalesLineFac.NEXT = 0;
        Factura."Factura Compra" := rCabCompr."No.";
        Factura."Empresa Origen Alb" := rIcPartner."Inbox Details";
        Factura.MODIFY(FALSE);
        if Borrar then
            rCabCompr2.DELETE;

        rLinCompra.FindFirst();
        repeat
            rLinCompraDef.ChangeCompany(rIcPartner."Inbox Details");
            rLinCompraDef := rLinCompra;
            rLinCompraDef."Vendor Item No." := '';
            rLinCompraDef."No." := rLinCompra."Vendor Item No.";
            rLinCompraDef.Insert;
        until rLinCompra.NEXT = 0;
    end;


    PROCEDURE CreaPedidoVenta(VAR rJob: Record Job; VAR Contrato: Record "Sales Header");
    VAR
        rJob2: Record Job;
        JobPlanningLine: Record 1003;
        JobPlanningLine2: Record 1003;
        JobTask: Record 1001;
        JobTask2: Record 1001;
        JobPlanningLineT: Record 1003 temporary;
        JobTaskt: Record 1001 temporary;
        rJobt: Record Job temporary;
        rRes: Record "Resource";
        rEmp: Record 2000000006;
#if CLEAN24
#pragma warning disable AL0432
        cMan: Codeunit NoSeriesManagement;
#pragma warning restore AL0432
#else
        CMan: Codeunit "No. Series";
#endif
        JobSetup: Record 315;
        rCli: Record "Customer";
        rSo: Record 413;
        rCab: Record "Sales Header";
        rLin: Record "Sales Line";
        ConfVtas: Record 311;
        rComentVenta: Record 44;
        rClient: Record "Customer";
        rComentProy: Record 97;
        rPresup: Record 1003;
        ult: Integer;
        rRecurs: Record "Resource";
        rGCP: Record 251;
        rGCN: Record 250;
        rCGC: Record 252;
        rFamilia: Record 152;
        lTexto: Record "Texto Presupuesto";
        r352: Record 352;
        //r357: Record 357;
        r325: Record 325;
        Currency: Record "Currency";
        rInf: Record "Company Information";
    BEGIN
        JobPlanningLine.SETRANGE(JobPlanningLine."Job No.", rJob."No.");
        if JobPlanningLine.FINDFIRST THEN
            REPEAT
                if rRes.GET(JobPlanningLine."No.") THEN BEGIN
                    if (rRes."Empresa Origen" <> COMPANYNAME)
                    AND (rRes."Nº En Empresa origen" <> '') THEN BEGIN
                        rEmp.GET(rRes."Empresa Origen");
                        rInf.ChangeCompany(rEmp.Name);
                        rInf.Get();
                        rJobt := rJob;
                        rJobt."Bill-to Contact" := rEmp.Name;
                        rJobt."No." := rInf."Clave Recursos";
                        rJobt."Proyecto en empresa Origen" := rJob."No.";
                        rJobt."Empresa Origen" := COMPANYNAME;
                        if rJobt.INSERT THEN;
                        JobPlanningLineT := JobPlanningLine;
                        JobPlanningLineT."Job No." := rInf."Clave Recursos";
                        JobPlanningLineT."No." := rRes."Nº En Empresa origen";
                        JobPlanningLineT.INSERT;
                        JobTask.SETRANGE(JobTask."Job No.", JobPlanningLine."Job No.");
                        if JobTask.FINDFIRST THEN
                            REPEAT
                                JobTaskt := JobTask;
                                JobTaskt."Job No." := rInf."Clave Recursos";
                                if JobTaskt.INSERT THEN;
                            UNTIL JobTask.NEXT = 0;
                    END;
                END;
            UNTIL JobPlanningLine.NEXT = 0;
        if rJobt.FINDFIRST THEN
            REPEAT
                rJob2.CHANGECOMPANY(rJobt."Bill-to Contact");
                rJob2.SETCURRENTKEY(rJob2."Proyecto en empresa Origen");
                rJob2.SETRANGE(rJob2."Proyecto en empresa Origen", rJob."No.");
                rJob2.FINDFIRST;
                rJob2."Estado Contrato" := rJob2."Estado Contrato"::Firmado;
                rJob2.Status := rJob2.Status::Open;
                rJob2.MODIFY;
                rCab.LOCKTABLE;
                rLin.LOCKTABLE;
                ConfVtas.LOCKTABLE;
                rComentVenta.LOCKTABLE;
                rCab.CHANGECOMPANY(rJobt."Bill-to Contact");
                rLin.CHANGECOMPANY(rJobt."Bill-to Contact");
                ConfVtas.CHANGECOMPANY(rJobt."Bill-to Contact");
                rComentVenta.CHANGECOMPANY(rJobt."Bill-to Contact");
                ConfVtas.GET;
                ConfVtas.TESTFIELD("Order Nos.");
                ConfVtas.TESTFIELD("Posted Invoice Nos.");
                ConfVtas.TESTFIELD("Posted Shipment Nos.");
                ConfVtas.TESTFIELD("Posted Prepmt. Inv. Nos.");
                //CLEAR(rCab);
                rClient.CHANGECOMPANY(rJobt."Bill-to Contact");
                rClient.GET(rJob2."Bill-to Customer No.");
                rCab.SETCURRENTKEY("Nº Proyecto");
                rCab.SETRANGE("Nº Proyecto", rJob2."No.");
                if rCab.FINDFIRST THEN BEGIN
                    //ERROR('El proyecto %1 de la Empresa %2 ya Tiene Contrato',rJob2."No.",rJobt."Bill-to Contact");
                    rLin.CHANGECOMPANY(rJobt."Bill-to Contact");
                    rLin.SETRANGE(rLin."Document Type", rCab."Document Type");
                    rLin.SETRANGE(rLin."Document No.", rCab."No.");
                    rLin.DELETEALL;
                    //Ahora no borro
                    //rCab.DELETE;
                END ELSE BEGIN
                    rCab."Document Type" := rCab."Document Type"::Order;
                    rCab."No." := GetNextNoEmp(ConfVtas."Order Nos.", WORKDATE, TRUE, rJobt."Bill-to Contact");
                    rCab.INSERT(FALSE);
                END;
                rCab."No. Series" := ConfVtas."Order Nos.";
                rCab."Posting No. Series" := ConfVtas."Posted Invoice Nos.";
                rCab."Shipping No. Series" := ConfVtas."Posted Shipment Nos.";
                rCab."Prepayment No. Series" := ConfVtas."Posted Prepmt. Inv. Nos.";
                rCab."Posting Date" := rJob2."Starting Date";
                rCab."Document Date" := rJob2."Starting Date";
                rCab."Shipment Date" := WORKDATE;
                rCab."Order Date" := WORKDATE;
                rCab."Due Date" := WORKDATE;
                rCab."Payment Terms Code" := rClient."Payment Terms Code";
                rCab."Payment Method Code" := rClient."Payment Method Code";
                rCab."Posting Description" := FORMAT(rCab."Document Type") + ' ' + rCab."No.";
                rCab."Sell-to Customer No." := rJob2."Bill-to Customer No.";
                rCab."Bill-to Customer No." := rJob2."Bill-to Customer No.";
                rCab."Bill-to Name" := rClient.Name;
                rCab."Bill-to Name 2" := rClient."Name 2";
                rCab."Bill-to Address" := rClient.Address;
                rCab."Bill-to Address 2" := rClient."Address 2";
                rCab."Bill-to City" := rClient.City;
                rCab."Bill-to Contact No." := rClient."Primary Contact No.";
                rCab."Sell-to Customer Name" := rClient.Name;
                rCab."Sell-to Customer Name 2" := rClient."Name 2";
                rCab."Sell-to Address" := rClient.Address;
                rCab."Sell-to Address 2" := rClient."Address 2";
                rCab."Sell-to City" := rClient.City;
                rCab."Bill-to Post Code" := rClient."Post Code";
                rCab."Bill-to County" := rClient.County;
                rCab."Bill-to Country/Region Code" := rClient."Country/Region Code";
                rCab."Sell-to Post Code" := rClient."Post Code";
                rCab."Sell-to County" := rClient.County;
                rCab."Sell-to Country/Region Code" := rClient."Country/Region Code";
                rCab."Ship-to Name" := rClient.Name;
                rCab."Ship-to Name 2" := rClient."Name 2";
                rCab."Ship-to Address" := rClient.Address;
                rCab."Ship-to Address 2" := rClient."Address 2";
                rCab."Ship-to City" := rClient.City;
                rCab."Ship-to Post Code" := rClient."Post Code";
                rCab."Ship-to County" := rClient.County;
                rCab."Ship-to Country/Region Code" := rClient."Country/Region Code";
                rCab."Customer Posting Group" := rClient."Customer Posting Group";
                rCab."Your Reference" := 'Proyecto ' + rJob2."No.";
                rCab."Nº Proyecto" := rJob2."No.";
                rCab."VAT Registration No." := rClient."VAT Registration No.";
                if rClient."Salesperson Code" = '' THEN
                    rCab."Salesperson Code" := rJob2."Cód. vendedor"
                ELSE
                    rCab."Salesperson Code" := rClient."Salesperson Code";
                rCab."Posting Description" := rJob2.Description;
                rCab.Validate("Fecha inicial proyecto", rJob2."Starting Date");
                rCab.Validate("Fecha fin proyecto", rJob2."Ending Date");
                rCab."Shortcut Dimension 1 Code" := rJob2."Global Dimension 1 Code";
                rCab."Shortcut Dimension 2 Code" := rJob2."Global Dimension 2 Code";
                if rJob2."Esperar Orden Cliente" = TRUE THEN
                    rCab."Esperar Orden Cliente" := rCab."Esperar Orden Cliente"::"Sí";
                rCab.Tipo := rJob2.Tipo;
                rCab.Firmado := rJob2.Firmado;
                rCab."Fecha Firma" := rJob2."Fecha Firma";
                rCab.Subtipo := rJob2.Subtipo;
                rCab."Soporte de" := rJob2."Soporte de";
                rCab."Interc./Compens." := rJob2."Interc./Compens.";         //FCL-18/05/04
                rCab."Proyecto origen" := rJob2."Proyecto original";          //FCL-18/05/04
                rCab.Renovado := rJob2.Renovado;                   //FCL-18/05/04
                rCab."External Document No." := rJob2."No Documento externo";     //$010
                                                                                  //$012(I)
                rCab."Payment Method Code" := rClient."Payment Method Code";
                rCab."Gen. Bus. Posting Group" := rClient."Gen. Bus. Posting Group";
                rCab."VAT Bus. Posting Group" := rClient."VAT Bus. Posting Group";
                //$012(F)
                if rClient."Cód. envio genérico" <> '' THEN
                    rCab."Ship-to Code" := rClient."Cód. envio genérico";
                rCab."Cód. términos facturacion" := TermFact(rCab, rJobt."Bill-to Contact", Contrato."Cód. términos facturacion");
                rCab.MODIFY(FALSE);
                //{ *** Tambien se traspasan los comentarios *** }
                rComentProy.CHANGECOMPANY(rJobt."Bill-to Contact");
                rComentProy.SETCURRENTKEY("Table Name", "No.", "Line No.");
                rComentProy.SETRANGE("Table Name", rComentProy."Table Name"::Job);
                rComentProy.SETRANGE("No.", rJob2."No.");
                if rComentProy.FIND('-') THEN
                    REPEAT
                        rComentVenta.INIT;
                        rComentVenta."Document Type" := rCab."Document Type";
                        rComentVenta."No." := rCab."No.";
                        rComentVenta."Line No." := rComentProy."Line No.";
                        rComentVenta.Date := rComentProy.Date;
                        rComentVenta.Code := rComentProy.Code;
                        rComentVenta.Comment := rComentProy.Comment;
                        rComentVenta.INSERT;
                    UNTIL rComentProy.NEXT = 0;

                ult := 10000;
                rPresup.CHANGECOMPANY(rJobt."Bill-to Contact");
                r352.CHANGECOMPANY(rJobt."Bill-to Contact");
                //r357.CHANGECOMPANY(rJobt."Bill-to Contact");
                rRecurs.CHANGECOMPANY(rJobt."Bill-to Contact");
                rPresup.SETRANGE(rPresup."Job No.", rJob2."No.");
                rLin.CHANGECOMPANY(rJobt."Bill-to Contact");
                if rPresup.FIND('-') THEN
                    REPEAT
                        //CLEAR(rLin);
                        rLin."Document Type" := rCab."Document Type";
                        rLin."Document No." := rCab."No.";
                        rLin."Line No." := ult;
                        ult += 10000;
                        rLin.INSERT;
                        rLin."Sell-to Customer No." := rCab."Sell-to Customer No.";
                        CASE rPresup.Type OF
                            rPresup.Type::"G/L Account":
                                rLin.Type := rLin.Type::"G/L Account";
                            rPresup.Type::Item:
                                rLin.Type := rLin.Type::Item;
                            rPresup.Type::Resource:
                                rLin.Type := rLin.Type::Resource;
                            rPresup.Type::Familia:
                                rLin.Type := rLin.Type::"G/L Account";
                        END;
                        if (rPresup.Type <> rPresup.Type::Familia) THEN BEGIN
                            rLin."No." := rPresup."No.";
                            rLin.Description := rPresup.Description;
                            if (rPresup.Type = rPresup.Type::Resource) THEN BEGIN
                                rRecurs.GET(rPresup."No.");
                                rLin."Unit of Measure Code" := rRecurs."Base Unit of Measure";
                                r352.SETRANGE(r352."Table ID", 156);
                                r352.SETRANGE(r352."No.", rPresup."No.");
                                if r352.FINDFIRST THEN
                                    REPEAT
                                        case r352."Dimension Code" of
                                            'DEPARTAMENTO':
                                                rLin.Validate("Shortcut Dimension 1 Code", r352."Dimension Value Code");
                                            'PROGRAMA':
                                                rLin.Validate("Shortcut Dimension 2 Code", r352."Dimension Value Code");
                                            'PRINCIPAL':
                                                rLin.Validate("Shortcut Dimension 3 Code", r352."Dimension Value Code");
                                            'SOPORTE':
                                                rLin.Validate("Shortcut Dimension 5 Code", r352."Dimension Value Code");
                                            'ZONA':
                                                rLin.Validate("Shortcut Dimension 4 Code", r352."Dimension Value Code");
                                        end;
                                    /* r357."Table ID" := 37;
                                    r357."Document Type" := r357."Document Type"::Order;
                                    r357."Document No." := rCab."No.";
                                    r357."Line No." := rLin."Line No.";
                                    r357."Dimension Code" := r352."Dimension Code";
                                    r357."Dimension Value Code" := r352."Dimension Value Code";
                                    r357.INSERT; */
                                    UNTIL r352.NEXT = 0;
                                if (rRecurs."Enunciado Cto. Venta" <> '') THEN
                                    rLin.Description := rRecurs."Enunciado Cto. Venta";
                                rLin."Gen. Bus. Posting Group" := rCab."Gen. Bus. Posting Group";
                                rLin."Gen. Prod. Posting Group" := rRecurs."Gen. Prod. Posting Group";
                                rLin."VAT Bus. Posting Group" := rClient."VAT Bus. Posting Group";
                                rLin."VAT Prod. Posting Group" := rRecurs."VAT Prod. Posting Group";
                                r325.CHANGECOMPANY(rJobt."Bill-to Contact");
                                if r325.GET(rLin."VAT Bus. Posting Group", rLin."VAT Prod. Posting Group") THEN
                                    rLin."VAT %" := r325."VAT %";
                            END;
                        END ELSE BEGIN
                            rGCP.CHANGECOMPANY(rJobt."Bill-to Contact");
                            rGCN.CHANGECOMPANY(rJobt."Bill-to Contact");
                            rCGC.CHANGECOMPANY(rJobt."Bill-to Contact");
                            rFamilia.CHANGECOMPANY(rJobt."Bill-to Contact");
                            rFamilia.GET(rPresup."No.");
                            rGCP.GET(rFamilia."Grupo contable producto");
                            rGCN.GET(rCab."Gen. Bus. Posting Group");
                            rCGC.GET(rGCN.Code, rGCP.Code);
                            rLin."No." := rCGC."Sales Account";
                            rLin."Gen. Bus. Posting Group" := rGCN.Code;
                            rLin."Gen. Prod. Posting Group" := rGCP.Code;
                            rLin.Description := rPresup.Description;
                            // En el caso de Fam. recurso supongo que debe aplicarse a una cuenta contable
                        END;
                        //$013(I)
                        if (rPresup.Type = rPresup.Type::Resource) THEN
                            rLin."Cód. proveedor" := rPresup."Compra a-Nº proveedor";
                        //$013(F)
                        rLin."Job No." := rPresup."Job No.";               //FCL-28/02/06. Muevo aquí la línea:= se machacaba cód.programa.
                        rLin."Shortcut Dimension 1 Code" := rPresup."Shortcut Dimension 1 Code";
                        rLin."Shortcut Dimension 2 Code" := rPresup."Shortcut Dimension 2 Code";
                        //rLin."Job No.":= rPresup."Job No.";               //FCL-28/02/06.
                        /* { $001
                          rLin."Phase Code":= rPresup."Phase Code";
                          rLin."Task Code":= rPresup."Task Code";
                        } */
                        rLin."Job Task No." := rPresup."Job Task No.";

                        // mig 5.0     rPresup.CALCFIELDS(Quantity);
                        rLin.Quantity := rPresup.Quantity;
                        rLin."Unit Price" := rPresup."Unit Price";
                        rLin."Line Discount %" := rPresup."% Dto. Venta";
                        rLin."Dto. Tarifa" := rPresup."Dto. Tarifa";
                        rLin."% Dto. Venta 1" := rPresup."% Dto. Venta 1";
                        rLin."% Dto. Venta 2" := rPresup."% Dto. Venta 2";
                        rLin."Precio Tarifa" := rPresup."Precio Tarifa";
                        rLin."Line Discount %" := rPresup."% Dto. Venta";  // $004
                        rLin."Tipo Duracion" := rPresup."Tipo Duracion";
                        rlin.Duracion := rPresup.Duracion;
                        rLin."Cdad. Soportes" := rPresup."Cdad. Soportes";
                        Currency.INIT;
                        rLin."Line Discount Amount" :=
                        ROUND(
                          ROUND(rLin.Quantity * rLin."Unit Price", Currency."Amount Rounding Precision") *
                          rLin."Line Discount %" / 100, Currency."Amount Rounding Precision");
                        rLin.Reparto := rPresup.Reparto;                                      //FCL-16/02/06
                        rLin."Fecha inicial recurso" := rPresup."Planning Date";              //$006
                        rLin."Fecha final recurso" := rPresup."Fecha Final";                  //$006
                        rLin."No linea proyecto" := rPresup."Line No.";                       //$008

                        // $003-  No insertamos ordenes de publicidad
                        //rPresup.CALCFIELDS("No. Orden Publicidad");
                        rLin."Description 2" := rPresup."Description 2";                                       //$011
                        rLin.Remarcar := rPresup.Remarcar;
                        LUpdateAmounts(rJobt."Bill-to Contact", rLin, rCab);
                        rLin.MODIFY;

                        // $002  y parte del $003
                        // No insertamos ordenes de publicidad
                        lTexto.CHANGECOMPANY(rJobt."Bill-to Contact");
                        lTexto.SETRANGE("Nº proyecto", rPresup."Job No.");
                        lTexto.SETRANGE("Nº linea aux", rPresup."Line No.");
                        lTexto.SETRANGE("Cód. tarea", rPresup."Job Task No.");                      //$009
                        lTexto.SETFILTER("Tipo linea", '%1|%2', lTexto."Tipo linea"::Ambos, lTexto."Tipo linea"::Venta);
                        if lTexto.FINDSET THEN
                            REPEAT
                                if (lTexto.Texto <> '') THEN BEGIN
                                    CLEAR(rLin);
                                    rLin.CHANGECOMPANY(rJobt."Bill-to Contact");
                                    rLin."Document Type" := rCab."Document Type";
                                    rLin."Document No." := rCab."No.";
                                    rLin."Line No." := ult;
                                    ult += 1000;
                                    rLin.INSERT;
                                    rLin.Type := rLin.Type::" ";
                                    rLin.Description := lTexto.Texto;
                                    rLin.Remarcar := lTexto.Remarcar;                             //$014
                                    rLin.MODIFY;
                                END;
                            UNTIL lTexto.NEXT = 0;
                    // $002+ y $003+

                    UNTIL rPresup.NEXT = 0;
            UNTIL rJobt.NEXT = 0;
    END;

    PROCEDURE SetNoSeriesLineFilter(VAR NoSeriesLine: Record 309; NoSeriesCode: Code[10]; StartDate: Date);
    BEGIN
        begin
            if StartDate = 0D THEN
                NoSeriesLine.RESET;
            NoSeriesLine.SETCURRENTKEY("Series Code", "Starting Date");
            NoSeriesLine.SETRANGE("Series Code", NoSeriesCode);
            NoSeriesLine.SETRANGE("Starting Date", 0D, StartDate);
            if NoSeriesLine.FINDLAST THEN BEGIN
                NoSeriesLine.SETRANGE("Starting Date", NoSeriesLine."Starting Date");
                NoSeriesLine.SETRANGE(Open, TRUE);
            end
        end;
    end;

    PROCEDURE GetNextNoEmp(NoSeriesCode: Code[10]; SeriesDate: Date; ModifySeries: Boolean; Empresa: Text[30]): Code[20]
    VAR
        NoSeriesLine: Record 309;
        NoSeries: Record 308;
        LastNoSeriesLine: Record 309;
        WarningNoSeriesCode: Code[10];
        TryNoSeriesCode: Code[10];
        TryNo: Code[20];
        Text004: Label 'Selecc. %1 para el %2 %3.';
        Text005: Label 'No puede asignar números nuevos de la serie %1.';
        Text006: Label 'No puede asignar números nuevos de la serie %1 en una fecha anterior a %2.';
        Text007: Label 'No puede asignar números mayores que %1 de la serie %2.';
    BEGIN

        if SeriesDate = 0D THEN
            SeriesDate := WORKDATE;
        LastNoSeriesLine.CHANGECOMPANY(Empresa);
        NoSeriesLine.CHANGECOMPANY(Empresa);

        if ModifySeries OR (LastNoSeriesLine."Series Code" = '') THEN BEGIN
            if ModifySeries THEN
                NoSeriesLine.LOCKTABLE;
            NoSeries.GET(NoSeriesCode);
            SetNoSeriesLineFilter(NoSeriesLine, NoSeriesCode, SeriesDate);
            if NOT NoSeriesLine.FINDFIRST THEN BEGIN
                NoSeriesLine.SETRANGE("Starting Date");
                if NOT NoSeriesLine.ISEMPTY THEN
                    ERROR(
                        Text004,
                        NoSeriesCode, SeriesDate);
                ERROR(
                Text005,
                NoSeriesCode);
            END;
        END ELSE
            NoSeriesLine := LastNoSeriesLine;

        if NoSeries."Date Order" AND (SeriesDate < NoSeriesLine."Last Date Used") THEN
            ERROR(
                Text006,
                NoSeries.Code, NoSeriesLine."Last Date Used");
        NoSeriesLine."Last Date Used" := SeriesDate;
        if NoSeriesLine."Last No. Used" = '' THEN BEGIN
            NoSeriesLine.TESTFIELD("Starting No.");
            NoSeriesLine."Last No. Used" := NoSeriesLine."Starting No.";
        END ELSE
            if NoSeriesLine."Increment-by No." <= 1 THEN
                NoSeriesLine."Last No. Used" := INCSTR(NoSeriesLine."Last No. Used")
            ELSE
                IncrementNoText(NoSeriesLine."Last No. Used", NoSeriesLine."Increment-by No.");
        if (NoSeriesLine."Ending No." <> '') AND
        (NoSeriesLine."Last No. Used" > NoSeriesLine."Ending No.")
        THEN
            ERROR(
                Text007,
                NoSeriesLine."Ending No.", NoSeriesCode);
        if (NoSeriesLine."Ending No." <> '') AND
        (NoSeriesLine."Warning No." <> '') AND
        (NoSeriesLine."Last No. Used" >= NoSeriesLine."Warning No.") AND
        (NoSeriesCode <> WarningNoSeriesCode) AND
        (TryNoSeriesCode = '')
        THEN BEGIN
            WarningNoSeriesCode := NoSeriesCode;
            MESSAGE(
                Text007,
                NoSeriesLine."Ending No.", NoSeriesCode);
        END;
        NoSeriesLine.VALIDATE(Open);

        //if ModifySeries THEN
        NoSeriesLine.MODIFY;
        //ELSE
        //LastNoSeriesLine := NoSeriesLine;
        EXIT(NoSeriesLine."Last No. Used");
    END;

    /// <summary>
    /// IncrementNoText.
    /// </summary>
    /// <param name="VAR No">Code[20].</param>
    /// <param name="IncrementByNo">Decimal.</param>
    procedure IncrementNoText(VAR No: Code[20]; IncrementByNo: Decimal)
    var
        DecimalNo: Decimal;
        StartPos: Integer;
        EndPos: Integer;
        NewNo: Text[30];
#if CLEAN24
#pragma warning disable AL0432
        cMan: Codeunit NoSeriesManagement;
#pragma warning restore AL0432
#else
        CMan: Codeunit "No. Series";
#endif
    begin

        GetIntegerPos(No, StartPos, EndPos);
        EVALUATE(DecimalNo, COPYSTR(No, StartPos, EndPos - StartPos + 1));
        NewNo := FORMAT(DecimalNo + IncrementByNo, 0, 1);
        ReplaceNoText(No, NewNo, 0, StartPos, EndPos);

    end;

    /// <summary>
    /// ReplaceNoText.
    /// </summary>
    /// <param name="No">VAR Code[20].</param>
    /// <param name="NewNo">Code[20].</param>
    /// <param name="FixedLength">Integer.</param>
    /// <param name="StartPos">Integer.</param>
    /// <param name="EndPos">Integer.</param>
    procedure ReplaceNoText(var No: Code[20]; NewNo: Code[20]; FixedLength: Integer; StartPos: Integer; EndPos: Integer)
    var
        StartNo: Code[20];
        EndNo: Code[20];
        ZeroNo: Code[20];
        NewLength: Integer;
        OldLength: Integer;
        Text010: Label 'El número %1 no puede superar 20 caracteres.';
    begin

        if StartPos > 1 THEN
            StartNo := COPYSTR(No, 1, StartPos - 1);
        if EndPos < STRLEN(No) THEN
            EndNo := COPYSTR(No, EndPos + 1);
        NewLength := STRLEN(NewNo);
        OldLength := EndPos - StartPos + 1;
        if FixedLength > OldLength THEN
            OldLength := FixedLength;
        if OldLength > NewLength THEN
            ZeroNo := PADSTR('', OldLength - NewLength, '0');
        if STRLEN(StartNo) + STRLEN(ZeroNo) + STRLEN(NewNo) + STRLEN(EndNo) > 20 THEN
            ERROR(
                Text010,
                No);
        No := StartNo + ZeroNo + NewNo + EndNo;
    end;

    /// <summary>
    /// GetIntegerPos.
    /// </summary>
    /// <param name="No">Code[20].</param>
    /// <param name="StartPos">VAR Integer.</param>
    /// <param name="EndPos">VAR Integer.</param>
    procedure GetIntegerPos(No: Code[20]; var StartPos: Integer; var EndPos: Integer)
    var
        i: Integer;
        IsDigit: Boolean;
    begin

        StartPos := 0;
        EndPos := 0;
        if No <> '' THEN BEGIN
            i := STRLEN(No);
            REPEAT
                IsDigit := No[i] IN ['0' .. '9'];
                if IsDigit THEN BEGIN
                    if EndPos = 0 THEN
                        EndPos := i;
                    StartPos := i;
                END;
                i := i - 1;
            UNTIL (i = 0) OR (StartPos <> 0) AND NOT IsDigit;
        END;
    end;

    PROCEDURE LUpdateAmounts(VAR Emp: Text[30]; VAR rLin: Record "Sales Line"; VAR SalesHeader: Record "Sales Header");

    VAR
        Currency: Record "Currency";
    BEGIN
        //WITH rLin DO BEGIN
        rLin."VAT Difference" := 0;
        if rLin."Line Amount" <> ROUND(rLin.Quantity * rLin."Unit Price", Currency."Amount Rounding Precision") - rLin."Line Discount Amount" THEN BEGIN
            rLin."Line Amount" := ROUND(rLin.Quantity * rLin."Unit Price", Currency."Amount Rounding Precision") - rLin."Line Discount Amount";
            rLin."VAT Difference" := 0;
            rLin."EC Difference" := 0;
        END;
        if SalesHeader.Status = SalesHeader.Status::Released THEN
            LUpdateVATAmounts(Emp, rLin, SalesHeader);
        if SalesHeader."Document Type" <> SalesHeader."Document Type"::Invoice THEN BEGIN
            rLin."Prepmt. Line Amount" := ROUND(rLin."Line Amount" * rLin."Prepayment %" / 100, Currency."Amount Rounding Precision");
        END;
        InitOutstandingAmount2(rLin, SalesHeader);
        //END;
    END;

    LOCAL PROCEDURE LUpdateVATAmounts(VAR Emp: Text[30]; VAR rLin: Record "Sales Line"; VAR SalesHeader: Record "Sales Header");
    VAR
        SalesLine2: Record "Sales Line";
        TotalLineAmount: Decimal;
        TotalInvDiscAmount: Decimal;
        TotalAmount: Decimal;
        TotalAmountInclVAT: Decimal;
        TotalQuantityBase: Decimal;
        Currency: Record "Currency";
        SalesTaxCalculate: Codeunit 398;
    BEGIN
        //WITH rLin DO BEGIN
        SalesLine2.CHANGECOMPANY(Emp);
        SalesLine2.SETRANGE("Document Type", rLin."Document Type");
        SalesLine2.SETRANGE("Document No.", rLin."Document No.");
        SalesLine2.SETFILTER("Line No.", '<>%1', rLin."Line No.");
        if rLin."Line Amount" > 0 THEN
            SalesLine2.SETFILTER(Amount, '>%1', 0)
        ELSE
            SalesLine2.SETFILTER(Amount, '<%1', 0);
        SalesLine2.SETRANGE("VAT Identifier", rLin."VAT Identifier");
        SalesLine2.SETRANGE("Tax Group Code", rLin."Tax Group Code");

        if rLin."Line Amount" = rLin."Inv. Discount Amount" THEN BEGIN
            rLin.Amount := 0;
            rLin."VAT Base Amount" := 0;
            rLin."Amount Including VAT" := 0;
            if rLin."Line No." <> 0 THEN
                if SalesHeader.MODIFY THEN
                    if SalesLine2.FINDLAST THEN BEGIN
                        LUpdateAmounts(Emp, SalesLine2, SalesHeader);
                        SalesLine2.MODIFY;
                    END;
        END ELSE BEGIN
            TotalLineAmount := 0;
            TotalInvDiscAmount := 0;
            TotalAmount := 0;
            TotalAmountInclVAT := 0;
            TotalQuantityBase := 0;
            if (rLin."VAT Calculation Type" = rLin."VAT Calculation Type"::"Sales Tax") OR
               ((rLin."VAT Calculation Type" IN
                 [rLin."VAT Calculation Type"::"Normal VAT", rLin."VAT Calculation Type"::"No Taxable VAT",
                 rLin."VAT Calculation Type"::"Reverse Charge VAT"]) AND (rLin."VAT %" <> 0))
            THEN BEGIN
                if SalesLine2.FINDSET THEN
                    REPEAT
                        TotalLineAmount := TotalLineAmount + SalesLine2."Line Amount";
                        TotalInvDiscAmount := TotalInvDiscAmount + SalesLine2."Inv. Discount Amount";
                        TotalAmount := TotalAmount + SalesLine2.Amount;
                        TotalAmountInclVAT := TotalAmountInclVAT + SalesLine2."Amount Including VAT";
                        TotalQuantityBase := TotalQuantityBase + SalesLine2."Quantity (Base)";
                    UNTIL SalesLine2.NEXT = 0;
            END;

            if SalesHeader."Prices Including VAT" THEN
                CASE rLin."VAT Calculation Type" OF
                    rLin."VAT Calculation Type"::"Normal VAT",
                    rLin."VAT Calculation Type"::"Reverse Charge VAT",
                    rLin."VAT Calculation Type"::"No Taxable VAT":
                        BEGIN
                            rLin.Amount :=
                              ROUND(
                                (TotalLineAmount - TotalInvDiscAmount + rLin."Line Amount" - rLin."Inv. Discount Amount") / (1 + (rLin."VAT %" + rLin."EC %") / 100),
                                Currency."Amount Rounding Precision") -
                              TotalAmount;
                            rLin."VAT Base Amount" :=
                              ROUND(
                                rLin.Amount * (1 - SalesHeader."VAT Base Discount %" / 100),
                                Currency."Amount Rounding Precision");
                            rLin."Amount Including VAT" :=
                              TotalLineAmount + rLin."Line Amount" +
                              ROUND(
                                (TotalAmount + rLin.Amount) * (SalesHeader."VAT Base Discount %" / 100) * (rLin."VAT %" + rLin."EC %") / 100,
                                Currency."Amount Rounding Precision", Currency.VATRoundingDirection) -
                              TotalAmountInclVAT;
                        END;
                    rLin."VAT Calculation Type"::"Full VAT":
                        BEGIN
                            rLin.Amount := 0;
                            rLin."VAT Base Amount" := 0;
                        END;
                    rLin."VAT Calculation Type"::"Sales Tax":
                        BEGIN
                            SalesHeader.TESTFIELD("VAT Base Discount %", 0);
                            rLin.Amount :=
                              SalesTaxCalculate.ReverseCalculateTax(
                                rLin."Tax Area Code", rLin."Tax Group Code", rLin."Tax Liable", SalesHeader."Posting Date",
                                TotalAmountInclVAT + rLin."Amount Including VAT", TotalQuantityBase + rLin."Quantity (Base)",
                                SalesHeader."Currency Factor") -
                              TotalAmount;
                            if rLin.Amount <> 0 THEN
                                rLin."VAT %" :=
                                  ROUND(100 * (rLin."Amount Including VAT" - rLin.Amount) / rLin.Amount, 0.000001)
                            ELSE BEGIN
                                rLin."VAT %" := 0;
                                rLin."EC %" := 0;
                            END;
                            rLin.Amount := ROUND(rLin.Amount, Currency."Amount Rounding Precision");
                            rLin."VAT Base Amount" := rLin.Amount;
                        END;
                END
            ELSE
                CASE rLin."VAT Calculation Type" OF
                    rLin."VAT Calculation Type"::"Normal VAT",
                    rLin."VAT Calculation Type"::"Reverse Charge VAT",
                    rLin."VAT Calculation Type"::"No Taxable VAT":
                        BEGIN
                            rLin.Amount := ROUND(rLin."Line Amount" - rLin."Inv. Discount Amount", Currency."Amount Rounding Precision");
                            rLin."VAT Base Amount" :=
                              ROUND(rLin.Amount * (1 - SalesHeader."VAT Base Discount %" / 100), Currency."Amount Rounding Precision");
                            rLin."Amount Including VAT" :=
                              TotalAmount + rLin.Amount +
                              ROUND(
                                (TotalAmount + rLin.Amount) * (1 - SalesHeader."VAT Base Discount %" / 100) * (rLin."VAT %" + rLin."EC %") / 100,
                                Currency."Amount Rounding Precision", Currency.VATRoundingDirection) -
                              TotalAmountInclVAT;
                        END;
                    rLin."VAT Calculation Type"::"Full VAT":
                        BEGIN
                            rLin.Amount := 0;
                            rLin."VAT Base Amount" := 0;
                            rLin."Amount Including VAT" := rLin."Line Amount" - rLin."Inv. Discount Amount";
                        END;
                    rLin."VAT Calculation Type"::"Sales Tax":
                        BEGIN
                            rLin.Amount := ROUND(rLin."Line Amount" - rLin."Inv. Discount Amount", Currency."Amount Rounding Precision");
                            rLin."VAT Base Amount" := rLin.Amount;
                            rLin."Amount Including VAT" :=
                              TotalAmount + rLin.Amount +
                              ROUND(
                                SalesTaxCalculate.CalculateTax(
                                  rLin."Tax Area Code", rLin."Tax Group Code", rLin."Tax Liable", SalesHeader."Posting Date",
                                  (TotalAmount + rLin.Amount), (TotalQuantityBase + rLin."Quantity (Base)"),
                                  SalesHeader."Currency Factor"), Currency."Amount Rounding Precision") -
                              TotalAmountInclVAT;
                            if rLin."VAT Base Amount" <> 0 THEN
                                rLin."VAT %" :=
                                  ROUND(100 * (rLin."Amount Including VAT" - rLin."VAT Base Amount") / rLin."VAT Base Amount", 0.000001)
                            ELSE BEGIN
                                rLin."VAT %" := 0;
                                rLin."EC %" := 0;
                            END;
                        END;
                END;
        END;
    END;
    //END;

    PROCEDURE InitOutstandingAmount2(VAR rLin: Record "Sales Line"; VAR SalesHeader: Record "Sales Header");
    VAR
        AmountInclVAT: Decimal;
        SalesTaxCalculate: Codeunit 398;
        Currency: Record "Currency";
    BEGIN
        //WITH rLin DO BEGIN
        if rLin.Quantity = 0 THEN BEGIN
            rLin."Outstanding Amount" := 0;
            rLin."Outstanding Amount (LCY)" := 0;
            rLin."Shipped Not Invoiced" := 0;
            rLin."Shipped Not Invoiced (LCY)" := 0;
            rLin."Return Rcd. Not Invd." := 0;
            rLin."Return Rcd. Not Invd. (LCY)" := 0;
        END ELSE BEGIN
            if SalesHeader.Status = SalesHeader.Status::Released THEN
                AmountInclVAT := rLin."Amount Including VAT"
            ELSE
                if SalesHeader."Prices Including VAT" THEN
                    AmountInclVAT := rLin."Line Amount" - rLin."Inv. Discount Amount"
                ELSE
                    if rLin."VAT Calculation Type" = rLin."VAT Calculation Type"::"Sales Tax" THEN
                        AmountInclVAT :=
                          rLin."Line Amount" - rLin."Inv. Discount Amount" +
                          ROUND(
                            SalesTaxCalculate.CalculateTax(
                              rLin."Tax Area Code", rLin."Tax Group Code", rLin."Tax Liable", SalesHeader."Posting Date",
                              rLin."Line Amount" - rLin."Inv. Discount Amount", rLin."Quantity (Base)", SalesHeader."Currency Factor"),
                            Currency."Amount Rounding Precision")
                    ELSE
                        AmountInclVAT :=
                          ROUND(
                            (rLin."Line Amount" - rLin."Inv. Discount Amount") *
                            (1 + (rLin."VAT %" + rLin."EC %") / 100 * (1 - SalesHeader."VAT Base Discount %" / 100)),
                            Currency."Amount Rounding Precision");

            rLin."Outstanding Amount" :=
            ROUND(
              AmountInclVAT * rLin."Outstanding Quantity" / rLin.Quantity,
              Currency."Amount Rounding Precision");

            rLin."Shipped Not Invoiced" :=
              ROUND(
                AmountInclVAT * rLin."Qty. Shipped Not Invoiced" / rLin.Quantity,
                Currency."Amount Rounding Precision");
        END;
        //END;
    END;

    PROCEDURE TermFact(rCab: Record "Sales Header"; Empresa: Text[30]; Term: Code[10]): Code[10];
    VAR
        rTerm: Record "Términos facturación";
        rEqui: Record "Equi. Términos Facuración";
        FechaFin: Date;
    BEGIN
        rEqui.CHANGECOMPANY(Empresa);
        if rEqui.FINDFIRST THEN
            REPEAT
                FechaFin := CALCDATE(rEqui."Duración Contrato", rCab."Fecha inicial proyecto");
                if ABS(rCab."Fecha fin proyecto" - FechaFin) < 30 THEN EXIT(rEqui."Código Terminos");
            UNTIL rEqui.NEXT = 0;
        if rTerm.GET(Term) THEN
            if rTerm."Código interempreas" <> '' THEN EXIT(rTerm."Código interempreas");
        EXIT(Term);
    END;

    PROCEDURE DebeTraspasarsePC(VAR rCab: Record 120): Boolean;
    VAR
        rRes: Record "Resource";
        rEmp: Record 2000000006;
#if CLEAN24
#pragma warning disable AL0432
        cMan: Codeunit NoSeriesManagement;
#pragma warning restore AL0432
#else
        CMan: Codeunit "No. Series";
#endif
        JobSetup: Record 315;
        rCli: Record "Customer";
        rSo: Record 413;
        rLin: Record "Purch. Rcpt. Line";
        rAct: Record 5600;
    BEGIN
        if NOT rCab."Forzar Traspaso" THEN
            if rCab."Nº Proyecto" <> '' THEN EXIT;
        rLin.SETRANGE(rLin."Document No.", rCab."No.");
        rLin.SETFILTER(rLin.Type, '%1|%2', rLin.Type::Resource, rLin.Type::"Fixed Asset");
        if rLin.FINDFIRST THEN
            REPEAT
                if rLin.Type = rLin.Type::"Fixed Asset" THEN BEGIN
                    rAct.GET(rLin."No.");
                    rLin."No." := rAct."Recurso Otra Empresa";
                END;

                if rRes.GET(rLin."No.") THEN BEGIN
                    if (rRes."Empresa Origen" <> COMPANYNAME)
                    AND (rRes."Nº En Empresa origen" <> '') THEN BEGIN
                        rEmp.GET(rRes."Empresa Origen");
                        EXIT(TRUE);
                    END;
                END;
            UNTIL rLin.NEXT = 0;
        EXIT(FALSE);
    END;

    PROCEDURE TrasPasaCompraaEmpresas(VAR r120: Record 120);
    VAR
        lSalesHeader: Record "Sales Header";
        rLin: Record "Purch. Rcpt. Line";
        rLin2: Record "Sales Line";
        rLinC: Record "Purchase Line";
        JobTaskt: Record 1001 temporary;
        rJobt: Record Job temporary;
        rRes: Record "Resource";
        rEmp: Record 2000000006;
#if CLEAN24
#pragma warning disable AL0432
        cMan: Codeunit NoSeriesManagement;
#pragma warning restore AL0432
#else
        CMan: Codeunit "No. Series";
#endif
        SalesSetup: Record 311;
        rCli: Record "Customer";
        rSo: Record 413;
        rResOrg: Record "Resource";
        rJobOrg: Record Job;
        rJobOrgEmp: Record Job;
        rGrupo: Record 251;
        r121t: Record 121 temporary;
        Vendor: Record Vendor;
        r39: Record "Purchase Line";
        Contrato: Code[20];
        r352: Record 352;
        //r357: Record 357;
        r251: Record 251;
        Numero: Code[20];
        r38: Record "Purchase Header";
        rAct: Record 5600;
        rInf: Record "Company Information";
        cPro: Codeunit ControlProcesos;
    BEGIN
        if NOT PendienteVentaEmpresas(r120) THEN EXIT;
        rLin.SETRANGE(rLin."Document No.", r120."No.");
        rLin.SETFILTER(rLin.Type, '%1|%2', rLin.Type::Resource, rLin.Type::"Fixed Asset");

        if rLin.FINDFIRST THEN
            REPEAT
                if rLin.Type = rLin.Type::"Fixed Asset" THEN BEGIN
                    rAct.GET(rLin."No.");
                    rLin."No." := rAct."Recurso Otra Empresa";
                    rLin.Type := rLin.Type::Resource;
                END;
                if rRes.GET(rLin."No.") THEN BEGIN
                    if (rRes."Empresa Origen" <> COMPANYNAME)
                    AND (rRes."Nº En Empresa origen" <> '') THEN BEGIN
                        rEmp.GET(rRes."Empresa Origen");
                        rResOrg.CHANGECOMPANY(rRes."Empresa Origen");
                        rResOrg.GET(rRes."Nº En Empresa origen");
                        r121t := rLin;
                        r121t."Periodo de Pago" := rEmp.Name;
                        rInf.ChangeCompany(rEmp.Name);
                        rInf.Get();
                        r121t."Job No." := rInf."Clave Recursos";
                        if r121t.INSERT THEN;
                    END;
                END;
            UNTIL rLin.NEXT = 0;
        if r121t.FINDFIRST THEN
            REPEAT
                //Contrato
                CLEAR(cMan);
                SalesSetup.CHANGECOMPANY(r121t."Periodo de Pago");
                SalesSetup.GET;
                lSalesHeader.RESET;
                lSalesHeader.CHANGECOMPANY(r121t."Periodo de Pago");
                lSalesHeader.SETCURRENTKEY(lSalesHeader."Albarán Empresa Origen");
                lSalesHeader.SETRANGE(lSalesHeader."Albarán Empresa Origen", r121t."Order No.");
                lSalesHeader.SETRANGE(lSalesHeader."Empresa Origen Alb", COMPANYNAME);
                if NOT lSalesHeader.FINDFIRST THEN BEGIN
                    Vendor.GET(r120."Buy-from Vendor No.");
                    rSo.RESET;
                    rSo.SETRANGE("Inbox Details", COMPANYNAME);
                    rSo.FINDFIRST;
                    rCli.CHANGECOMPANY(r121t."Periodo de Pago");
                    rCli.SETRANGE(rCli."IC Partner Code", rSo.Code);
                    rCli.FINDFIRST;
                    lSalesHeader."Document Type" := lSalesHeader."Document Type"::Order;
                    lSalesHeader."Bill-to Customer No." := rCli."No.";
                    lSalesHeader."Posting Date" := r120."Posting Date";
                    lSalesHeader."Order Date" := r120."Order Date";
                    lSalesHeader."Shipment Date" := r120."Expected Receipt Date";
                    lSalesHeader."Document Date" := r120."Document Date";
                    cPro.UpdateCustEmp(lSalesHeader, rCli, r121t."Periodo de Pago");
                    //lSalesHeader.UpdateCustEmp(rCli, r121t."Periodo de Pago");
                    lSalesHeader."Salesperson Code" := r120."Purchaser Code";
                    lSalesHeader."No." := GetNextNoEmp(SalesSetup."Order Nos.", WORKDATE, TRUE, r121t."Periodo de Pago");
                    Contrato := lSalesHeader."No.";
                    lSalesHeader."Empresa Origen Alb" := COMPANYNAME;
                    lSalesHeader."Posting Description" := r120."Posting Description";
                    lSalesHeader."On Hold" := 'ASC';
                    lSalesHeader."Albarán Empresa Origen" := r121t."Order No.";
                    lSalesHeader."Fecha Estado" := r120."Posting Date";
                    lSalesHeader."Fecha renovacion" := r120."Posting Date";
                    lSalesHeader.Validate("Fecha inicial proyecto", r120."Posting Date");
                    lSalesHeader.Validate("Fecha fin proyecto", r120."Posting Date");
                    lSalesHeader.INSERT;

                    r39.SETRANGE(r39."Document Type", r39."Document Type"::Order);
                    r39.SETRANGE(r39."Document No.", r121t."Order No.");
                    r39.SETRANGE(r39.Type, r39.Type::Resource);
                    r39.SETFILTER(r39.Type, '%1|%2', r39.Type::Resource, r39.Type::"Fixed Asset");
                    r38.GET(r39."Document Type"::Order, r121t."Order No.");
                    CrearProyecto(r121t."Periodo de Pago", Numero, r39, rCli."No.", r38
                    , r120."Posting Date", r120."Posting Date", rSo.Code);
                    lSalesHeader."Nº Proyecto" := Numero;
                    lSalesHeader.MODIFY;
                    if r39.FINDFIRST THEN
                        REPEAT
                            if r39.Type = r39.Type::"Fixed Asset" THEN BEGIN
                                rAct.GET(r39."No.");
                                r39."No." := rAct."Recurso Otra Empresa";
                                r39.Type := r39.Type::Resource;
                            END;
                            rLin2.CHANGECOMPANY(r121t."Periodo de Pago");
                            //rLin2.TRANSFERFIELDS(r121t);
                            rLin2."Document Type" := lSalesHeader."Document Type";
                            rLin2.Type := r39.Type;
                            rLin2."Document No." := lSalesHeader."No.";
                            rLin2."Line No." := r39."Line No.";
                            rLin2.Description := r39.Description;
                            rLin2."Description 2" := r39."Description 2";
                            rLin2.Quantity := r39.Quantity;
                            rLin2."Unit Price" := r39."Direct Unit Cost";
                            rLin2."VAT %" := r39."VAT %";
                            rLin2."Line Discount %" := r39."Line Discount %";
                            rRes.GET(r39."No.");
                            if rRes."Empresa Origen" = r121t."Periodo de Pago" THEN BEGIN
                                rResOrg.CHANGECOMPANY(rRes."Empresa Origen");
                                // r357.CHANGECOMPANY(rRes."Empresa Origen");
                                rResOrg.GET(rRes."Nº En Empresa origen");
                                rLin2."No." := rResOrg."No.";
                                rLin2."Unit of Measure" := rResOrg."Base Unit of Measure";
                                rLin2.INSERT;
                                r352.CHANGECOMPANY(r121t."Periodo de Pago");
                                r352.SETRANGE(r352."Table ID", 156);
                                r352.SETRANGE(r352."No.", rResOrg."No.");
                                if r352.FINDFIRST THEN
                                    REPEAT
                                        case r352."Dimension Code" of
                                            'DEPARTAMENTO':
                                                rLin.Validate("Shortcut Dimension 1 Code", r352."Dimension Value Code");
                                            'PROGRAMA':
                                                rLin.Validate("Shortcut Dimension 2 Code", r352."Dimension Value Code");
                                            'PRINCIPAL':
                                                rLin.Validate("Shortcut Dimension 3 Code", r352."Dimension Value Code");
                                            'SOPORTE':
                                                rLin.Validate("Shortcut Dimension 5 Code", r352."Dimension Value Code");
                                            'ZONA':
                                                rLin.Validate("Shortcut Dimension 4 Code", r352."Dimension Value Code");
                                        end;
                                    /*  r357."Table ID" := 37;
                                     r357."Document Type" := r357."Document Type"::Order;
                                     r357."Document No." := lSalesHeader."No.";
                                     r357."Line No." := rLin2."Line No.";
                                     r357."Dimension Code" := r352."Dimension Code";
                                     r357."Dimension Value Code" := r352."Dimension Value Code";
                                     r357.INSERT; */
                                    UNTIL r352.NEXT = 0;
                                // if rResOrg.Irpf THEN BEGIN
                                //     r251.CHANGECOMPANY(r121t."Periodo de Pago");
                                //     r251.GET(rResOrg."Gen. Prod. Posting Group");
                                //     rLin2.Type := rLin2.Type::"G/L Account";
                                //     rLin2."Line No." := rLin2."Line No." + 1;
                                //     rLin2."No." := r251."Cuenta Ret. IRPF";
                                //     rLin2.Quantity := -(r251."% Irpf Alquileres" / 100);
                                //     rLin2."Unit Price" := r39.Quantity * r39."Unit Cost";
                                //     rLin2."VAT %" := 0;
                                //     rLin2."VAT Prod. Posting Group" := r251."Grupo Iva IRPF";
                                //     rLin2."Shortcut Dimension 1 Code" := rResOrg."Global Dimension 1 Code";
                                //     rLin2."Shortcut Dimension 2 Code" := rResOrg."Global Dimension 2 Code";
                                //     lSalesHeader."Shortcut Dimension 1 Code" := rResOrg."Global Dimension 1 Code";
                                //     lSalesHeader."Shortcut Dimension 2 Code" := rResOrg."Global Dimension 2 Code";
                                //     lSalesHeader.MODIFY;
                                //     rLin2.INSERT;
                                // END;
                            END;
                        UNTIL r39.NEXT = 0;
                END ELSE BEGIN
                    Contrato := lSalesHeader."No.";
                    Numero := lSalesHeader."Nº Proyecto";
                    lSalesHeader."Fecha Estado" := r120."Posting Date";
                    lSalesHeader."Fecha renovacion" := r120."Posting Date";
                    lSalesHeader."Fecha fin proyecto" := r120."Posting Date";
                    CambiaFecha(r121t."Periodo de Pago", Numero, r120."Posting Date");
                    lSalesHeader.MODIFY;
                END;
                //Fin Contrato
                CLEAR(cMan);
                SalesSetup.CHANGECOMPANY(r121t."Periodo de Pago");
                SalesSetup.GET;
                lSalesHeader.RESET;
                lSalesHeader.CHANGECOMPANY(r121t."Periodo de Pago");
                lSalesHeader.SETCURRENTKEY(lSalesHeader."Albarán Empresa Origen");
                lSalesHeader.SETRANGE(lSalesHeader."Albarán Empresa Origen", r121t."Document No.");
                lSalesHeader.SETRANGE(lSalesHeader."Empresa Origen Alb", COMPANYNAME);
                if NOT lSalesHeader.FINDFIRST THEN BEGIN
                    Vendor.GET(r120."Buy-from Vendor No.");
                    rSo.RESET;
                    rSo.SETRANGE("Inbox Details", COMPANYNAME);
                    rSo.FINDFIRST;
                    rCli.CHANGECOMPANY(r121t."Periodo de Pago");
                    rCli.SETRANGE(rCli."IC Partner Code", rSo.Code);
                    rCli.FINDFIRST;
                    lSalesHeader."Document Type" := lSalesHeader."Document Type"::Invoice;
                    lSalesHeader."Bill-to Customer No." := rCli."No.";
                    lSalesHeader."Posting Date" := r120."Posting Date";
                    lSalesHeader."Order Date" := r120."Order Date";
                    lSalesHeader."Shipment Date" := r120."Expected Receipt Date";
                    lSalesHeader."Document Date" := r120."Document Date";
                    cPro.UpdateCustEmp(lSalesHeader, rCli, r121t."Periodo de Pago");
                    //lSalesHeader.UpdateCustEmp(rCli, r121t."Periodo de Pago");
                    lSalesHeader."Salesperson Code" := r120."Purchaser Code";
                    lSalesHeader."No." := GetNextNoEmp(SalesSetup."Invoice Nos.", WORKDATE, TRUE, r121t."Periodo de Pago");
                    lSalesHeader."Empresa Origen Alb" := COMPANYNAME;
                    lSalesHeader."Posting Description" := r120."Posting Description";
                    lSalesHeader."Posting No. Series" := SalesSetup."Posted Invoice Nos.";
                    lSalesHeader."On Hold" := 'ASC';
                    lSalesHeader."Nº Contrato" := Contrato;
                    lSalesHeader."Factura propuesta sistema" := TRUE;
                    lSalesHeader."Albarán Empresa Origen" := r121t."Document No.";
                    lSalesHeader.INSERT;
                END;
                rLin2.CHANGECOMPANY(r121t."Periodo de Pago");
                //rLin2.TRANSFERFIELDS(r121t);
                rLin2."Document Type" := lSalesHeader."Document Type";
                rLin2.Type := r121t.Type;
                rLin2."Document No." := lSalesHeader."No.";
                rLin2."Line No." := r121t."Line No.";
                rLin2.Description := r121t.Description;
                rLin2."Description 2" := r121t."Description 2";
                rLin2.Quantity := r121t.Quantity;
                rLin2."Unit Price" := r121t."Direct Unit Cost";
                rLin2."VAT %" := r121t."VAT %";
                rLin2."Line Discount %" := r121t."Line Discount %";
                rRes.GET(r121t."No.");
                rResOrg.CHANGECOMPANY(rRes."Empresa Origen");
                rResOrg.GET(rRes."Nº En Empresa origen");
                rLin2."No." := rResOrg."No.";
                rLin2."Unit of Measure" := rResOrg."Base Unit of Measure";
                rLin2.INSERT;
                r352.CHANGECOMPANY(r121t."Periodo de Pago");
                r352.SETRANGE(r352."Table ID", 156);
                r352.SETRANGE(r352."No.", rResOrg."No.");
                if r352.FINDFIRST THEN
                    REPEAT
                        case r352."Dimension Code" of
                            'DEPARTAMENTO':
                                rLin2.Validate("Shortcut Dimension 1 Code", r352."Dimension Value Code");
                            'PROGRAMA':
                                rLin2.Validate("Shortcut Dimension 2 Code", r352."Dimension Value Code");
                            'PRINCIPAL':
                                rLin2.Validate("Shortcut Dimension 3 Code", r352."Dimension Value Code");
                            'SOPORTE':
                                rLin2.Validate("Shortcut Dimension 5 Code", r352."Dimension Value Code");
                            'ZONA':
                                rLin2.Validate("Shortcut Dimension 4 Code", r352."Dimension Value Code");
                        end;
                    /* r357."Table ID" := 37;
                    r357."Document Type" := r357."Document Type"::Invoice;
                    r357."Document No." := lSalesHeader."No.";
                    r357."Line No." := rLin2."Line No.";
                    r357."Dimension Code" := r352."Dimension Code";
                    r357."Dimension Value Code" := r352."Dimension Value Code";
                    r357.INSERT; */
                    UNTIL r352.NEXT = 0;
                // if rResOrg.Irpf THEN BEGIN
                //     r251.CHANGECOMPANY(r121t."Periodo de Pago");
                //     r251.GET(rResOrg."Gen. Prod. Posting Group");
                //     rLin2.Type := rLin2.Type::"G/L Account";
                //     rLin2."Line No." := rLin2."Line No." + 1;
                //     rLin2."No." := r251."Cuenta Ret. IRPF";
                //     rLin2.Quantity := -(r251."% Irpf Alquileres" / 100);
                //     rLin2."Unit Price" := r121t.Quantity * r121t."Unit Cost";
                //     rLin2."VAT %" := 0;
                //     rLin2."VAT Prod. Posting Group" := r251."Grupo Iva IRPF";
                //     rLin2."Shortcut Dimension 1 Code" := rResOrg."Global Dimension 1 Code";
                //     rLin2."Shortcut Dimension 2 Code" := rResOrg."Global Dimension 2 Code";
                //     lSalesHeader."Shortcut Dimension 1 Code" := rResOrg."Global Dimension 1 Code";
                //     lSalesHeader."Shortcut Dimension 2 Code" := rResOrg."Global Dimension 2 Code";
                //     lSalesHeader.MODIFY;

                //     rLin2.INSERT;
                // END;

                COMMIT;
            UNTIL r121t.NEXT = 0;
    END;

    PROCEDURE PendienteVentaEmpresas(VAR rCab: Record 120): Boolean;
    VAR
        r121t: Record 121 temporary;
        rLin: Record "Purch. Rcpt. Line";
        rRes: Record "Resource";
        rEmp: Record 2000000006;
        lSalesHeader: Record "Sales Header";
        lSalesInvHeader: Record "Sales Invoice Header";
        rAct: Record 5600;
        rInf: Record "Company Information";
    BEGIN
        rLin.SETRANGE(rLin."Document No.", rCab."No.");
        if rLin.FINDFIRST THEN
            REPEAT
                if rLin.Type = rLin.Type::"Fixed Asset" THEN BEGIN
                    rAct.GET(rLin."No.");
                    rLin."No." := rAct."Recurso Otra Empresa";
                END;

                if rRes.GET(rLin."No.") THEN BEGIN
                    if (rRes."Empresa Origen" <> COMPANYNAME)
                    AND (rRes."Nº En Empresa origen" <> '') THEN BEGIN
                        rEmp.GET(rRes."Empresa Origen");
                        r121t := rLin;
                        r121t.Description := rEmp.Name;
                        rInf.ChangeCompany(rEmp.Name);
                        rInf.Get();
                        r121t."Job No." := rInf."Clave Recursos";
                        if r121t.INSERT THEN;
                    END;
                END;
            UNTIL rLin.NEXT = 0;
        if r121t.FINDFIRST THEN
            REPEAT
                lSalesHeader.CHANGECOMPANY(r121t.Description);
                lSalesHeader.SETCURRENTKEY(lSalesHeader."Albarán Empresa Origen");
                lSalesHeader.SETRANGE(lSalesHeader."Albarán Empresa Origen", r121t."Document No.");
                lSalesHeader.SETRANGE(lSalesHeader."Empresa Origen Alb", COMPANYNAME);
                if NOT lSalesHeader.FINDFIRST THEN EXIT(TRUE);
                lSalesInvHeader.CHANGECOMPANY(r121t.Description);
                lSalesInvHeader.SETCURRENTKEY(lSalesInvHeader."Albarán Empresa Origen");
                lSalesInvHeader.SETRANGE("Albarán Empresa Origen", r121t."Document No.");
                lSalesInvHeader.SETRANGE("Empresa Origen Alb", COMPANYNAME);
                if NOT lSalesInvHeader.FINDFIRST THEN EXIT(TRUE);

            UNTIL lSalesHeader.NEXT = 0;
        EXIT(FALSE);
    END;

    PROCEDURE CrearProyecto(Empresa: Text[30]; VAR Numero: Code[20]; VAR r39: Record "Purchase Line"; Cliente: Code[20]; VAR r38: Record "Purchase Header"; Fini: Date; FFin: Date; CodeIc: Code[20]);
    VAR
        rJob2: Record Job;
        rCli: Record "Customer";
        JobSetup: Record 315;
        JobPlanningLine: Record 1003;
        JobTask: Record 1001;
#if CLEAN24
#pragma warning disable AL0432
        cMan: Codeunit NoSeriesManagement;
#pragma warning restore AL0432
#else
        CMan: Codeunit "No. Series";
#endif
        rRes: Record "Resource";
        rResOrigen: Record "Resource";
        rAct: Record 5600;
    BEGIN
        rJob2.CHANGECOMPANY(Empresa);
        rCli.CHANGECOMPANY(Empresa);
        JobPlanningLine.CHANGECOMPANY(Empresa);
        JobTask.CHANGECOMPANY(Empresa);
        JobSetup.CHANGECOMPANY(Empresa);
        JobSetup.GET;
        rCli.SETRANGE(rCli."IC Partner Code", CodeIc);
        rCli.FINDFIRST;
        //
        rJob2.INIT;
        rJob2."Proyecto origen" := '';
        rJob2."Proyecto original" := '';
        rJob2."Bill-to Customer No." := rCli."No.";
        rJob2.UpdateCustEmp(rCli, Empresa);
        rJob2."Cód. vendedor" := rCli."Salesperson Code";
        rJob2."No." := GetNextNoEmp(JobSetup."Job Nos.", WORKDATE, TRUE, Empresa);
        Numero := rJob2."No.";
        rJob2."Empresa Origen" := COMPANYNAME;
        rJob2.Description := r38."Posting Description";//rJob.Description;
        rJob2."Creation Date" := Fini;
        rJob2."Starting Date" := Fini;
        rJob2."Ending Date" := FFin;
        rJob2.Status := rJob2.Status::Open;
        rJob2.INSERT;
        if r39.FINDFIRST THEN
            REPEAT
                JobPlanningLine."Job No." := rJob2."No.";
                JobPlanningLine."Job Task No." := '10';
                JobPlanningLine."Line No." := r39."Line No.";
                if r39.Type = r39.Type::"Fixed Asset" THEN BEGIN
                    rAct.GET(r39."No.");
                    r39."No." := rAct."Recurso Otra Empresa";
                END;

                if rRes.GET(r39."No.") THEN BEGIN
                    rResOrigen.CHANGECOMPANY(Empresa);
                    rResOrigen.GET(rRes."Nº En Empresa origen");
                    JobPlanningLine.Type := JobPlanningLine.Type::Resource;
                    JobPlanningLine."No." := rResOrigen."No.";
                    JobPlanningLine.Description := rResOrigen.Name;
                    JobPlanningLine.Quantity := r39.Quantity;
                    JobPlanningLine."Planning Date" := Fini;
                    JobPlanningLine."Direct Unit Cost (LCY)" := r39."Direct Unit Cost";
                    JobPlanningLine."Unit Cost (LCY)" := r39."Unit Cost (LCY)";
                    JobPlanningLine."Total Cost (LCY)" := r39."Line Amount";
                    JobPlanningLine."Unit Price (LCY)" := r39."Unit Cost (LCY)";
                    JobPlanningLine."Total Price (LCY)" := r39."Line Amount";
                    JobPlanningLine."Resource Group No." := rRes."Resource Group No.";
                    JobPlanningLine."Unit of Measure Code" := rRes."Base Unit of Measure";
                    JobPlanningLine."Gen. Prod. Posting Group" := rRes."Gen. Prod. Posting Group";
                    JobPlanningLine."Line Amount (LCY)" := r39."Line Amount";
                    JobPlanningLine."Unit Cost" := r39."Unit Cost (LCY)";
                    JobPlanningLine."Total Cost" := r39."Line Amount";
                    JobPlanningLine."Unit Price" := r39."Unit Cost (LCY)";
                    JobPlanningLine."Total Price" := r39."Line Amount";
                    JobPlanningLine."Cdad. a Reservar" := r39.Quantity;
                    if JobPlanningLine."Cdad. a Reservar" > 1 THEN JobPlanningLine."Cdad. a Reservar" := 1;
                    if (rResOrigen."Recurso Agrupado") or (rResOrigen."Producción") Then JobPlanningLine."Cdad. a Reservar" := 0;
                    JobPlanningLine."Fecha Final" := FFin;
                    JobPlanningLine."Tipo Recurso" := rRes."Tipo Recurso";
                    JobPlanningLine.INSERT;
                END;
            UNTIL r39.NEXT = 0;
        JobTask."Job No." := rJob2."No.";
        JobTask."Job Task No." := '10';
        JobTask.Description := 'Traspaso';
        JobTask.INSERT;
        COMMIT;
    END;

    PROCEDURE CambiaFecha(Empresa: Text[30]; Numero: Code[20]; Ff: Date);
    VAR
        rJob2: Record Job;
        JobPlanningLine: Record 1003;
    BEGIN
        rJob2.CHANGECOMPANY(Empresa);
        JobPlanningLine.CHANGECOMPANY(Empresa);
        if rJob2.GET(Numero) THEN BEGIN
            rJob2."Ending Date" := Ff;
            rJob2.MODIFY;
        END;
        JobPlanningLine.SETRANGE(JobPlanningLine."Job No.", Numero);
        JobPlanningLine.MODIFYALL(JobPlanningLine."Fecha Final", Ff);
    END;

    PROCEDURE CabioFechaContratoDestino(VAR rJob: Record Job; Fecha: Date);
    VAR
        rJob2: Record Job;
        JobPlanningLine: Record 1003;
        JobPlanningLine2: Record 1003;
        JobTask: Record 1001;
        JobTask2: Record 1001;
        JobPlanningLineT: Record 1003 TEMPORARY;
        JobTaskt: Record 1001 TEMPORARY;
        rJobt: Record Job TEMPORARY;
        rRes: Record "Resource";
        rEmp: Record 2000000006;
#if CLEAN24
#pragma warning disable AL0432
        cMan: Codeunit NoSeriesManagement;
#pragma warning restore AL0432
#else
        CMan: Codeunit "No. Series";
#endif
        JobSetup: Record 315;
        rCli: Record "Customer";
        rSo: Record 413;
        rContr: Record "Sales Header";
        rInf: Record "Company Information";
    BEGIN
        JobPlanningLine.SETRANGE(JobPlanningLine."Job No.", rJob."No.");
        if JobPlanningLine.FINDFIRST THEN
            REPEAT
                if rRes.GET(JobPlanningLine."No.") THEN BEGIN
                    if (rRes."Empresa Origen" <> COMPANYNAME)
                    AND (rRes."Nº En Empresa origen" <> '') THEN BEGIN
                        rEmp.GET(rRes."Empresa Origen");
                        rJobt := rJob;
                        rJobt."Bill-to Contact" := rEmp.Name;
                        rInf.ChangeCompany(rEmp.Name);
                        rInf.Get();
                        rJobt."No." := rInf."Clave Recursos";
                        rJobt."Proyecto en empresa Origen" := rJob."No.";
                        rJobt."Empresa Origen" := COMPANYNAME;
                        if rJobt.INSERT THEN;
                        JobPlanningLineT := JobPlanningLine;
                        JobPlanningLineT."Job No." := rInf."Clave Recursos";
                        JobPlanningLineT."No." := rRes."Nº En Empresa origen";
                        JobPlanningLineT.INSERT;
                        JobTask.SETRANGE(JobTask."Job No.", JobPlanningLine."Job No.");
                        if JobTask.FINDFIRST THEN
                            REPEAT
                                JobTaskt := JobTask;
                                rInf.ChangeCompany(rEmp.Name);
                                rInf.Get();
                                JobTaskt."Job No." := rInf."Clave Recursos";
                                if JobTaskt.INSERT THEN;
                            UNTIL JobTask.NEXT = 0;
                    END;
                END;
            UNTIL JobPlanningLine.NEXT = 0;
        if rJobt.FINDFIRST THEN
            REPEAT
                CLEAR(cMan);
                rJob2.CHANGECOMPANY(rJobt."Bill-to Contact");
                rJob2.SETCURRENTKEY(rJob2."Proyecto en empresa Origen");
                rJob2.SETRANGE(rJob2."Proyecto en empresa Origen", rJob."No.");
                if rJob2.FINDFIRST THEN BEGIN
                    rContr.CHANGECOMPANY(rJobt."Bill-to Contact");
                    rContr.SETCURRENTKEY(rContr."Nº Proyecto");
                    rContr.SETRANGE(rContr."Document Type", rContr."Document Type"::Order);
                    if rContr.FINDFIRST THEN BEGIN
                        rContr."Posting Date" := Fecha;
                        rContr."Document Date" := Fecha;
                        rContr.MODIFY;
                    END;
                END;
            UNTIL rJobt.NEXT = 0;
    END;

    PROCEDURE RenovarContratoDestino(VAR rJob: Record Job);
    VAR
        rJob2: Record Job;
        JobPlanningLine: Record 1003;
        JobPlanningLine2: Record 1003;
        JobTask: Record 1001;
        JobTask2: Record 1001;
        JobPlanningLineT: Record 1003 temporary;
        JobTaskt: Record 1001 temporary;
        rJobt: Record Job temporary;
        rRes: Record "Resource";
        rEmp: Record 2000000006;
#if CLEAN24
#pragma warning disable AL0432
        cMan: Codeunit NoSeriesManagement;
#pragma warning restore AL0432
#else
        CMan: Codeunit "No. Series";
#endif
        JobSetup: Record 315;
        rCli: Record "Customer";
        rSo: Record 413;
        rContr: Record "Sales Header";
        rInf: Record "Company Information";
    BEGIN
        JobPlanningLine.SETRANGE(JobPlanningLine."Job No.", rJob."No.");
        if JobPlanningLine.FINDFIRST THEN
            REPEAT
                if rRes.GET(JobPlanningLine."No.") THEN BEGIN
                    if (rRes."Empresa Origen" <> COMPANYNAME)
                    AND (rRes."Nº En Empresa origen" <> '') THEN BEGIN
                        rEmp.GET(rRes."Empresa Origen");
                        rJobt := rJob;
                        rJobt."Bill-to Contact" := rEmp.Name;
                        rInf.ChangeCompany(rEmp.Name);
                        rInf.Get();
                        rJobt."No." := rInf."Clave Recursos";
                        rJobt."Proyecto en empresa Origen" := rJob."No.";
                        rJobt."Empresa Origen" := COMPANYNAME;
                        if rJobt.INSERT THEN;
                        JobPlanningLineT := JobPlanningLine;
                        JobPlanningLineT."Job No." := rInf."Clave Recursos";
                        JobPlanningLineT."No." := rRes."Nº En Empresa origen";
                        JobPlanningLineT.INSERT;
                        JobTask.SETRANGE(JobTask."Job No.", JobPlanningLine."Job No.");
                        if JobTask.FINDFIRST THEN
                            REPEAT
                                JobTaskt := JobTask;
                                JobTaskt."Job No." := rInf."Clave Recursos";
                                if JobTaskt.INSERT THEN;
                            UNTIL JobTask.NEXT = 0;
                    END;
                END;
            UNTIL JobPlanningLine.NEXT = 0;
        if rJobt.FINDFIRST THEN
            REPEAT
                CLEAR(cMan);
                rJob2.CHANGECOMPANY(rJobt."Bill-to Contact");
                rJob2.SETCURRENTKEY(rJob2."Proyecto en empresa Origen");
                rJob2.SETRANGE(rJob2."Proyecto en empresa Origen", rJob."No.");
                if rJob2.FINDFIRST THEN BEGIN
                    rContr.CHANGECOMPANY(rJobt."Bill-to Contact");
                    rContr.SETCURRENTKEY(rContr."Nº Proyecto");
                    rContr.SETRANGE(rContr."Document Type", rContr."Document Type"::Order);
                    if rContr.FINDFIRST THEN BEGIN
                        rContr.Renovado := TRUE;
                        if rContr."Nuevo Vendedor asignado" <> '' Then begin
                            rContr."Vendedor Origen" := rContr."Salesperson Code";
                            rContr."Salesperson Code" := rContr."Nuevo Vendedor asignado";
                        end;
                        rContr."Fecha renovacion" := 0D;
                        rContr.MODIFY;
                    END;
                END;
            UNTIL rJobt.NEXT = 0;
    END;

    PROCEDURE ReCrearProyecto(Empresa: Text[30]; VAR Numero: Code[20]; VAR r39: Record "Purchase Line"; Cliente: Code[20]; VAR r38: Record "Purchase Header"; Fini: Date; FFin: Date; CodeIc: Code[20]; NumProy: Code[20]);
    VAR
        rJob2: Record Job;
        rCli: Record "Customer";
        JobSetup: Record 315;
        JobPlanningLine: Record 1003;
        JobTask: Record 1001;
#if CLEAN24
#pragma warning disable AL0432
        cMan: Codeunit NoSeriesManagement;
#pragma warning restore AL0432
#else
        CMan: Codeunit "No. Series";
#endif
        rRes: Record "Resource";
        rResOrigen: Record "Resource";
        rAct: Record 5600;
    BEGIN
        rJob2.CHANGECOMPANY(Empresa);
        rCli.CHANGECOMPANY(Empresa);
        JobPlanningLine.CHANGECOMPANY(Empresa);
        JobTask.CHANGECOMPANY(Empresa);
        JobSetup.CHANGECOMPANY(Empresa);
        JobSetup.GET;
        rCli.SETRANGE(rCli."IC Partner Code", CodeIc);
        rCli.FINDFIRST;
        //
        rJob2.INIT;
        rJob2."Proyecto origen" := '';
        rJob2."Proyecto original" := '';
        rJob2."Bill-to Customer No." := rCli."No.";
        rJob2.UpdateCustEmp(rCli, Empresa);
        rJob2."Cód. vendedor" := rCli."Salesperson Code";
        rJob2."No." := NumProy;//cMan.GetNextNoEmp(JobSetup."Job Nos.",WORKDATE,TRUE,Empresa);
        Numero := rJob2."No.";
        rJob2."Empresa Origen" := COMPANYNAME;
        rJob2.Description := r38."Posting Description";//rJob.Description;
        rJob2."Creation Date" := Fini;
        rJob2."Starting Date" := Fini;
        rJob2."Ending Date" := FFin;
        rJob2.Status := rJob2.Status::Open;
        rJob2.INSERT;
        if r39.FINDFIRST THEN
            REPEAT
                JobPlanningLine."Job No." := rJob2."No.";
                JobPlanningLine."Job Task No." := '10';
                JobPlanningLine."Line No." := r39."Line No.";
                if r39.Type = r39.Type::"Fixed Asset" THEN BEGIN
                    rAct.GET(r39."No.");
                    r39."No." := rAct."Recurso Otra Empresa";
                END;

                if rRes.GET(r39."No.") THEN BEGIN
                    rResOrigen.CHANGECOMPANY(Empresa);
                    rResOrigen.GET(rRes."Nº En Empresa origen");
                    JobPlanningLine.Type := JobPlanningLine.Type::Resource;
                    JobPlanningLine."No." := rResOrigen."No.";
                    JobPlanningLine.Description := rResOrigen.Name;
                    JobPlanningLine.Quantity := r39.Quantity;
                    JobPlanningLine."Planning Date" := Fini;
                    JobPlanningLine."Direct Unit Cost (LCY)" := r39."Direct Unit Cost";
                    JobPlanningLine."Unit Cost (LCY)" := r39."Unit Cost (LCY)";
                    JobPlanningLine."Total Cost (LCY)" := r39."Line Amount";
                    JobPlanningLine."Unit Price (LCY)" := r39."Unit Cost (LCY)";
                    JobPlanningLine."Total Price (LCY)" := r39."Line Amount";
                    JobPlanningLine."Resource Group No." := rRes."Resource Group No.";
                    JobPlanningLine."Unit of Measure Code" := rRes."Base Unit of Measure";
                    JobPlanningLine."Gen. Prod. Posting Group" := rRes."Gen. Prod. Posting Group";
                    JobPlanningLine."Line Amount (LCY)" := r39."Line Amount";
                    JobPlanningLine."Unit Cost" := r39."Unit Cost (LCY)";
                    JobPlanningLine."Total Cost" := r39."Line Amount";
                    JobPlanningLine."Unit Price" := r39."Unit Cost (LCY)";
                    JobPlanningLine."Total Price" := r39."Line Amount";
                    JobPlanningLine."Cdad. a Reservar" := r39.Quantity;
                    if JobPlanningLine."Cdad. a Reservar" > 1 THEN JobPlanningLine."Cdad. a Reservar" := 1;
                    JobPlanningLine."Fecha Final" := FFin;
                    JobPlanningLine."Tipo Recurso" := rRes."Tipo Recurso";
                    if JobPlanningLine.INSERT THEN;
                END;
            UNTIL r39.NEXT = 0;
        JobTask."Job No." := rJob2."No.";
        JobTask."Job Task No." := '10';
        JobTask.Description := 'Traspaso';
        if JobTask.INSERT THEN;
        COMMIT;
    END;

    PROCEDURE DebeTraspasarseDC(VAR rCab: Record 6650): Boolean;
    VAR
        rRes: Record "Resource";
        rEmp: Record 2000000006;
#if CLEAN24
#pragma warning disable AL0432
        cMan: Codeunit NoSeriesManagement;
#pragma warning restore AL0432
#else
        CMan: Codeunit "No. Series";
#endif
        JobSetup: Record 315;
        rCli: Record "Customer";
        rSo: Record 413;
        rLin: Record 6651;
        rAct: Record 5600;
    BEGIN
        //if rCab."Nº Proyecto"<>'' THEN EXIT;
        rLin.SETRANGE(rLin."Document No.", rCab."No.");
        rLin.SETFILTER(rLin.Type, '%1|%2', rLin.Type::Resource, rLin.Type::"Fixed Asset");
        if rLin.FINDFIRST THEN
            REPEAT
                if rLin.Type = rLin.Type::"Fixed Asset" THEN BEGIN
                    rAct.GET(rLin."No.");
                    rLin."No." := rAct."Recurso Otra Empresa";
                END;
                if rRes.GET(rLin."No.") THEN BEGIN
                    if (rRes."Empresa Origen" <> COMPANYNAME)
                    AND (rRes."Nº En Empresa origen" <> '') THEN BEGIN
                        rEmp.GET(rRes."Empresa Origen");
                        EXIT(TRUE);
                    END;
                END;
            UNTIL rLin.NEXT = 0;
        EXIT(FALSE);
    END;

    PROCEDURE TrasPasaDevolaEmpresas(VAR r120: Record 6650);
    VAR
        lSalesHeader: Record "Sales Header";
        rLin: Record 6651;
        rLin2: Record "Sales Line";
        rLinC: Record "Purchase Line";
        JobTaskt: Record 1001 TEMPORARY;
        rJobt: Record Job TEMPORARY;
        rRes: Record "Resource";
        rEmp: Record 2000000006;
#if CLEAN24
#pragma warning disable AL0432
        cMan: Codeunit NoSeriesManagement;
#pragma warning restore AL0432
#else
        CMan: Codeunit "No. Series";
#endif
        SalesSetup: Record 311;
        rCli: Record "Customer";
        rSo: Record 413;
        rResOrg: Record "Resource";
        rJobOrg: Record Job;
        rJobOrgEmp: Record Job;
        rGrupo: Record 251;
        r121t: Record 6651 temporary;
        Vendor: Record Vendor;
        r39: Record "Purchase Line";
        Contrato: Code[20];
        r352: Record 352;
        //r357: Record 357;
        r251: Record 251;
        Numero: Code[20];
        r38: Record "Purchase Header";
        rAct: Record 5600;
        rInf: Record "Company Information";
        cPro: Codeunit ControlProcesos;
    BEGIN
        if NOT PendienteVentaEmpresasDev(r120) THEN EXIT;
        rLin.SETRANGE(rLin."Document No.", r120."No.");
        rLin.SETFILTER(rLin.Type, '%1|%2', rLin.Type::Resource, rLin.Type::"Fixed Asset");

        if rLin.FINDFIRST THEN
            REPEAT
                if rLin.Type = rLin.Type::"Fixed Asset" THEN BEGIN
                    rAct.GET(rLin."No.");
                    rLin."No." := rAct."Recurso Otra Empresa";
                END;
                if rRes.GET(rLin."No.") THEN BEGIN
                    if (rRes."Empresa Origen" <> COMPANYNAME)
                    AND (rRes."Nº En Empresa origen" <> '') THEN BEGIN
                        rEmp.GET(rRes."Empresa Origen");
                        rInf.ChangeCompany(rEmp.Name);
                        rInf.Get();
                        rResOrg.CHANGECOMPANY(rRes."Empresa Origen");
                        rResOrg.GET(rRes."Nº En Empresa origen");
                        r121t := rLin;
                        r121t."Periodo de Pago" := rEmp.Name;
                        r121t."Job No." := rInf."Clave Recursos";
                        if r121t.INSERT THEN;
                    END;
                END;
            UNTIL rLin.NEXT = 0;
        if r121t.FINDFIRST THEN
            REPEAT
                //Contrato
                CLEAR(cMan);
                SalesSetup.CHANGECOMPANY(r121t."Periodo de Pago");
                SalesSetup.GET;
                lSalesHeader.RESET;
                lSalesHeader.CHANGECOMPANY(r121t."Periodo de Pago");
                lSalesHeader.SETCURRENTKEY(lSalesHeader."Albarán Empresa Origen");
                lSalesHeader.SETRANGE(lSalesHeader."Albarán Empresa Origen", r121t."Return Order No.");
                lSalesHeader.SETRANGE(lSalesHeader."Empresa Origen Alb", COMPANYNAME);
                if NOT lSalesHeader.FINDFIRST THEN BEGIN
                    //ERROR(lSalesHeader.GETFILTERS);
                    Vendor.GET(r120."Buy-from Vendor No.");
                    rSo.RESET;
                    rSo.SETRANGE("Inbox Details", COMPANYNAME);
                    rSo.FINDFIRST;
                    rCli.CHANGECOMPANY(r121t."Periodo de Pago");
                    rCli.SETRANGE(rCli."IC Partner Code", rSo.Code);
                    rCli.FINDFIRST;
                    lSalesHeader."Document Type" := lSalesHeader."Document Type"::Order;
                    lSalesHeader."Bill-to Customer No." := rCli."No.";
                    lSalesHeader."Posting Date" := r120."Posting Date";
                    lSalesHeader."Order Date" := r120."Posting Date";
                    lSalesHeader."Shipment Date" := r120."Expected Receipt Date";
                    lSalesHeader."Document Date" := r120."Document Date";
                    cPro.UpdateCustEmp(lSalesHeader, rCli, r121t."Periodo de Pago");
                    //lSalesHeader.UpdateCustEmp(rCli, r121t."Periodo de Pago");
                    lSalesHeader."Salesperson Code" := r120."Purchaser Code";
                    lSalesHeader."No." := GetNextNoEmp(SalesSetup."Order Nos.", WORKDATE, TRUE, r121t."Periodo de Pago");
                    Contrato := lSalesHeader."No.";
                    lSalesHeader."Empresa Origen Alb" := COMPANYNAME;
                    lSalesHeader."Posting Description" := r120."Posting Description";
                    lSalesHeader."On Hold" := 'ASC';
                    lSalesHeader."Albarán Empresa Origen" := r121t."Return Order No.";
                    lSalesHeader."Fecha Estado" := r120."Posting Date";
                    lSalesHeader."Fecha renovacion" := r120."Posting Date";
                    lSalesHeader."Fecha inicial proyecto" := r120."Posting Date";
                    lSalesHeader."Fecha fin proyecto" := r120."Posting Date";
                    lSalesHeader.INSERT;

                    r39.SETRANGE(r39."Document Type", r39."Document Type"::"Return Order");
                    r39.SETRANGE(r39."Document No.", r121t."Return Order No.");
                    r39.SETFILTER(r39.Type, '%1|%2', r39.Type::Resource, r39.Type::"Fixed Asset");
                    r38.GET(r39."Document Type"::"Return Order", r121t."Return Order No.");
                    CrearProyecto(r121t."Periodo de Pago", Numero, r39, rCli."No.", r38
                    , r120."Posting Date", r120."Posting Date", rSo.Code);
                    lSalesHeader."Nº Proyecto" := Numero;
                    lSalesHeader.MODIFY;
                    if r39.FINDFIRST THEN
                        REPEAT
                            if r39.Type = r39.Type::"Fixed Asset" THEN BEGIN
                                rAct.GET(r39."No.");
                                r39."No." := rAct."Recurso Otra Empresa";
                            END;
                            rLin2.CHANGECOMPANY(r121t."Periodo de Pago");
                            //rLin2.TRANSFERFIELDS(r121t);
                            rLin2."Document Type" := lSalesHeader."Document Type";
                            rLin2.Type := r39.Type;
                            rLin2."Document No." := lSalesHeader."No.";
                            rLin2."Line No." := r39."Line No.";
                            rLin2.Description := r39.Description;
                            rLin2."Description 2" := r39."Description 2";
                            rLin2.Quantity := -r39.Quantity;
                            rLin2."Unit Price" := r39."Direct Unit Cost";
                            rLin2."VAT %" := r39."VAT %";
                            rLin2."Line Discount %" := r39."Line Discount %";
                            rRes.GET(r39."No.");
                            if rRes."Empresa Origen" = r121t."Periodo de Pago" THEN BEGIN
                                rResOrg.CHANGECOMPANY(rRes."Empresa Origen");
                                //r357.CHANGECOMPANY(rRes."Empresa Origen");
                                rResOrg.GET(rRes."Nº En Empresa origen");
                                rLin2."No." := rResOrg."No.";
                                rLin2."Unit of Measure" := rResOrg."Base Unit of Measure";
                                rLin2.INSERT;
                                r352.CHANGECOMPANY(r121t."Periodo de Pago");
                                r352.SETRANGE(r352."Table ID", 156);
                                r352.SETRANGE(r352."No.", rResOrg."No.");
                                if r352.FINDFIRST THEN
                                    REPEAT
                                        case r352."Dimension Code" of
                                            'DEPARTAMENTO':
                                                rLin2.Validate("Shortcut Dimension 1 Code", r352."Dimension Value Code");
                                            'PROGRAMA':
                                                rLin2.Validate("Shortcut Dimension 2 Code", r352."Dimension Value Code");
                                            'PRINCIPAL':
                                                rLin2.Validate("Shortcut Dimension 3 Code", r352."Dimension Value Code");
                                            'SOPORTE':
                                                rLin2.Validate("Shortcut Dimension 5 Code", r352."Dimension Value Code");
                                            'ZONA':
                                                rLin2.Validate("Shortcut Dimension 4 Code", r352."Dimension Value Code");
                                        end;
                                    /*       r357."Table ID" := 37;
                                          r357."Document Type" := r357."Document Type"::Order;
                                          r357."Document No." := lSalesHeader."No.";
                                          r357."Line No." := rLin2."Line No.";
                                          r357."Dimension Code" := r352."Dimension Code";
                                          r357."Dimension Value Code" := r352."Dimension Value Code";
                                          r357.INSERT; */
                                    UNTIL r352.NEXT = 0;
                                //     if rResOrg.Irpf THEN BEGIN
                                //         r251.CHANGECOMPANY(r121t."Periodo de Pago");
                                //         r251.GET(rResOrg."Gen. Prod. Posting Group");
                                //         rLin2.Type := rLin2.Type::"G/L Account";
                                //         rLin2."Line No." := rLin2."Line No." + 1;
                                //         rLin2."No." := r251."Cuenta Ret. IRPF";
                                //         rLin2.Quantity := (r251."% Irpf Alquileres" / 100);
                                //         rLin2."Unit Price" := r39.Quantity * r39."Unit Cost";
                                //         rLin2."VAT %" := 0;
                                //         rLin2."VAT Prod. Posting Group" := r251."Grupo Iva IRPF";
                                //         rLin2."Shortcut Dimension 1 Code" := rResOrg."Global Dimension 1 Code";
                                //         rLin2."Shortcut Dimension 2 Code" := rResOrg."Global Dimension 2 Code";
                                //         lSalesHeader."Shortcut Dimension 1 Code" := rResOrg."Global Dimension 1 Code";
                                //         lSalesHeader."Shortcut Dimension 2 Code" := rResOrg."Global Dimension 2 Code";
                                //         lSalesHeader.MODIFY;
                                //         rLin2.INSERT;
                                //     END;
                            END;
                        UNTIL r39.NEXT = 0;
                END ELSE BEGIN
                    Contrato := lSalesHeader."No.";
                    Numero := lSalesHeader."Nº Proyecto";
                    lSalesHeader."Fecha Estado" := r120."Posting Date";
                    lSalesHeader."Fecha renovacion" := r120."Posting Date";
                    lSalesHeader."Fecha fin proyecto" := r120."Posting Date";
                    CambiaFecha(r121t."Periodo de Pago", Numero, r120."Posting Date");
                    lSalesHeader.MODIFY;
                END;
                //Fin Contrato
                CLEAR(cMan);
                SalesSetup.CHANGECOMPANY(r121t."Periodo de Pago");
                SalesSetup.GET;
                lSalesHeader.RESET;
                lSalesHeader.CHANGECOMPANY(r121t."Periodo de Pago");
                lSalesHeader.SETCURRENTKEY(lSalesHeader."Albarán Empresa Origen");
                lSalesHeader.SETRANGE(lSalesHeader."Albarán Empresa Origen", r121t."Document No.");
                lSalesHeader.SETRANGE(lSalesHeader."Empresa Origen Alb", COMPANYNAME);
                if NOT lSalesHeader.FINDFIRST THEN BEGIN
                    Vendor.GET(r120."Buy-from Vendor No.");
                    rSo.RESET;
                    rSo.SETRANGE("Inbox Details", COMPANYNAME);
                    rSo.FINDFIRST;
                    rCli.CHANGECOMPANY(r121t."Periodo de Pago");
                    rCli.SETRANGE(rCli."IC Partner Code", rSo.Code);
                    rCli.FINDFIRST;
                    lSalesHeader."Document Type" := lSalesHeader."Document Type"::"Credit Memo";
                    lSalesHeader."Bill-to Customer No." := rCli."No.";
                    lSalesHeader."Posting Date" := r120."Posting Date";
                    lSalesHeader."Order Date" := r120."Posting Date";
                    lSalesHeader."Shipment Date" := r120."Expected Receipt Date";
                    lSalesHeader."Document Date" := r120."Document Date";
                    cPro.UpdateCustEmp(lSalesHeader, rCli, r121t."Periodo de Pago");
                    //lSalesHeader.UpdateCustEmp(rCli, r121t."Periodo de Pago");
                    lSalesHeader."Salesperson Code" := r120."Purchaser Code";
                    lSalesHeader."No." := GetNextNoEmp(SalesSetup."Credit Memo Nos.", WORKDATE, TRUE, r121t."Periodo de Pago");
                    lSalesHeader."Empresa Origen Alb" := COMPANYNAME;
                    lSalesHeader."Posting Description" := r120."Posting Description";
                    lSalesHeader."Posting No. Series" := SalesSetup."Posted Credit Memo Nos.";
                    lSalesHeader."On Hold" := 'ASC';
                    lSalesHeader."Nº Contrato" := Contrato;
                    lSalesHeader."Factura propuesta sistema" := TRUE;
                    lSalesHeader."Albarán Empresa Origen" := r121t."Document No.";
                    lSalesHeader.INSERT;
                END;
                rLin2.CHANGECOMPANY(r121t."Periodo de Pago");
                //rLin2.TRANSFERFIELDS(r121t);
                rLin2."Document Type" := lSalesHeader."Document Type";
                rLin2.Type := r121t.Type;
                rLin2."Document No." := lSalesHeader."No.";
                rLin2."Line No." := r121t."Line No.";
                rLin2.Description := r121t.Description;
                rLin2."Description 2" := r121t."Description 2";
                rLin2.Quantity := r121t.Quantity;
                rLin2."Unit Price" := r121t."Direct Unit Cost";
                rLin2."VAT %" := r121t."VAT %";
                rLin2."Line Discount %" := r121t."Line Discount %";
                rRes.GET(r121t."No.");
                rResOrg.CHANGECOMPANY(rRes."Empresa Origen");
                rResOrg.GET(rRes."Nº En Empresa origen");
                rLin2."No." := rResOrg."No.";
                rLin2."Unit of Measure" := rResOrg."Base Unit of Measure";
                rLin2.INSERT;
                r352.CHANGECOMPANY(r121t."Periodo de Pago");
                r352.SETRANGE(r352."Table ID", 156);
                r352.SETRANGE(r352."No.", rResOrg."No.");
                if r352.FINDFIRST THEN
                    REPEAT
                        case r352."Dimension Code" of
                            'DEPARTAMENTO':
                                rLin2.Validate("Shortcut Dimension 1 Code", r352."Dimension Value Code");
                            'PROGRAMA':
                                rLin2.Validate("Shortcut Dimension 2 Code", r352."Dimension Value Code");
                            'PRINCIPAL':
                                rLin2.Validate("Shortcut Dimension 3 Code", r352."Dimension Value Code");
                            'SOPORTE':
                                rLin2.Validate("Shortcut Dimension 5 Code", r352."Dimension Value Code");
                            'ZONA':
                                rLin2.Validate("Shortcut Dimension 4 Code", r352."Dimension Value Code");
                        end;
                    /* r357."Table ID" := 37;
                    r357."Document Type" := r357."Document Type"::Invoice;
                    r357."Document No." := lSalesHeader."No.";
                    r357."Line No." := rLin2."Line No.";
                    r357."Dimension Code" := r352."Dimension Code";
                    r357."Dimension Value Code" := r352."Dimension Value Code";
                    r357.INSERT; */
                    UNTIL r352.NEXT = 0;
                // if rResOrg.Irpf THEN BEGIN
                //     r251.CHANGECOMPANY(r121t."Periodo de Pago");
                //     r251.GET(rResOrg."Gen. Prod. Posting Group");
                //     rLin2.Type := rLin2.Type::"G/L Account";
                //     rLin2."Line No." := rLin2."Line No." + 1;
                //     rLin2."No." := r251."Cuenta Ret. IRPF";
                //     rLin2.Quantity := -(r251."% Irpf Alquileres" / 100);
                //     rLin2."Unit Price" := r121t.Quantity * r121t."Unit Cost";
                //     rLin2."VAT %" := 0;
                //     rLin2."VAT Prod. Posting Group" := r251."Grupo Iva IRPF";
                //     rLin2."Shortcut Dimension 1 Code" := rResOrg."Global Dimension 1 Code";
                //     rLin2."Shortcut Dimension 2 Code" := rResOrg."Global Dimension 2 Code";
                //     lSalesHeader."Shortcut Dimension 1 Code" := rResOrg."Global Dimension 1 Code";
                //     lSalesHeader."Shortcut Dimension 2 Code" := rResOrg."Global Dimension 2 Code";
                //     lSalesHeader.MODIFY;

                //     rLin2.INSERT;
                // END;

                COMMIT;
            UNTIL r121t.NEXT = 0;
    END;

    PROCEDURE PendienteVentaEmpresasDev(VAR rCab: Record 6650): Boolean;
    VAR
        r121t: Record 6651 temporary;
        rLin: Record 6651;
        rRes: Record "Resource";
        rEmp: Record 2000000006;
        lSalesHeader: Record "Sales Header";
        lSalesInvHeader: Record "Sales Invoice Header";
        rAct: Record 5600;
        rInf: Record "Company Information";
    BEGIN
        rLin.SETRANGE(rLin."Document No.", rCab."No.");
        if rLin.FINDFIRST THEN
            REPEAT
                if rLin.Type = rLin.Type::"Fixed Asset" THEN BEGIN
                    rAct.GET(rLin."No.");
                    rLin."No." := rAct."Recurso Otra Empresa";
                END;
                if rRes.GET(rLin."No.") THEN BEGIN
                    if (rRes."Empresa Origen" <> COMPANYNAME)
                    AND (rRes."Nº En Empresa origen" <> '') THEN BEGIN
                        rEmp.GET(rRes."Empresa Origen");
                        r121t := rLin;
                        r121t.Description := rEmp.Name;
                        rInf.ChangeCompany(rEmp.Name);
                        rInf.Get();
                        r121t."Job No." := rInf."Clave Recursos";
                        if r121t.INSERT THEN;
                    END;
                END;
            UNTIL rLin.NEXT = 0;
        if r121t.FINDFIRST THEN
            REPEAT
                lSalesHeader.CHANGECOMPANY(r121t.Description);
                lSalesHeader.SETCURRENTKEY(lSalesHeader."Albarán Empresa Origen");
                lSalesHeader.SETRANGE(lSalesHeader."Albarán Empresa Origen", r121t."Document No.");
                lSalesHeader.SETRANGE(lSalesHeader."Empresa Origen Alb", COMPANYNAME);
                if lSalesHeader.FINDFIRST THEN EXIT(FALSE);
                lSalesInvHeader.CHANGECOMPANY(r121t.Description);
                lSalesInvHeader.SETCURRENTKEY(lSalesInvHeader."Albarán Empresa Origen");
                lSalesInvHeader.SETRANGE(lSalesInvHeader."Albarán Empresa Origen", r121t."Document No.");
                lSalesInvHeader.SETRANGE(lSalesInvHeader."Empresa Origen Alb", COMPANYNAME);
                if NOT lSalesInvHeader.FINDFIRST THEN EXIT(TRUE);

            UNTIL lSalesHeader.NEXT = 0;
        EXIT(FALSE);
    END;

    PROCEDURE SiiMensajes();
    VAR
        //rFile : Record 2000000022;
        //d58885 : Dataport 7000532;
        r98: Record "General Ledger Setup";
        //rMes : Record 7000532;
        SalesInvHeader: Record "Sales Invoice Header";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        PurchInvHeader: Record "Purch. Inv. Header";
        PurchCrMemoHeader: Record "Purch. Cr. Memo Hdr.";
        Ventana: Dialog;
        a: Integer;
        r23: Record Vendor;
        rInf: Record 79;
        nombre: Text[1024];
    BEGIN
        /* r98.GET();
        rFile.SETRANGE(rFile.Path,'C:\');
        rFile.FINDFIRST;
        rFile.SETRANGE(rFile.Path,r98."Ruta fichero SII IN");
        rFile.SETFILTER(rFile.Name,'%1|%2','*.txt','*.TXT');
        Ventana.OPEN('Procesando fichero ############1## de #############2##');
        Ventana.UPDATE(2,rFile.COUNT);

        if rFile.FINDFIRST THEN REPEAT
         CLEAR(d58885);
         a:=a+1;
         Ventana.UPDATE(1,a);
         d58885.IMPORT:=TRUE;
         d58885.FILENAME:=rFile.Path+'\'+rFile.Name;
         d58885.RUN;
         COMMIT;
         FILE.COPY(rFile.Path+'\'+rFile.Name,rFile.Path+'\sended\'+rFile.Name);
         ERASE(rFile.Path+'\'+rFile.Name);
        UNTIL rFile.NEXT=0;
        COMMIT;
        Ventana.CLOSE;
        rMes.SETRANGE(rMes.Procesado,FALSE);
        Ventana.OPEN('Procesando mensaje ############1## de #############2##');
        Ventana.UPDATE(2,rMes.COUNT);
        a:=0;
        if rMes.FINDSET THEN REPEAT
         a:=a+1;
         Ventana.UPDATE(1,a);
         //Procesar por mensaje
         nombre:=r98."Ruta fichero SII"+COPYSTR(rMes.Mensaje,STRLEN(r98."Ruta fichero SII IN")+1,250);
         nombre:=COPYSTR(nombre,1,STRLEN(nombre)-9)+'.txt';
         SalesInvHeader.SETRANGE("Nombre fichero SII",nombre);
         if SalesInvHeader.FINDFIRST THEN BEGIN
           SalesInvHeader.Estado:=rMes.Estado;
           SalesInvHeader.MODIFY;
           rMes."Num Doc":=SalesInvHeader."No.";
           rMes.Procesado:=TRUE;
           rMes.MODIFY;
         END;
         SalesCrMemoHeader.SETRANGE("Nombre fichero SII",nombre);
         if SalesCrMemoHeader.FINDFIRST THEN BEGIN
           SalesCrMemoHeader.Estado:=rMes.Estado;
           SalesCrMemoHeader.MODIFY;
           rMes."Num Doc":=SalesCrMemoHeader."No.";
           rMes.Procesado:=TRUE;
           rMes.MODIFY;
         END;
         PurchInvHeader.SETRANGE("Nombre fichero SII",nombre);
         if PurchInvHeader.FINDFIRST THEN BEGIN
           PurchInvHeader.Estado:=rMes.Estado;
           PurchInvHeader.MODIFY;
           rMes."Num Doc":=PurchInvHeader."No.";
           rMes.Procesado:=TRUE;
           rMes.MODIFY;
         END;
         PurchCrMemoHeader.SETRANGE("Nombre fichero SII",nombre);
         if PurchCrMemoHeader.FINDFIRST THEN BEGIN
           PurchCrMemoHeader.Estado:=rMes.Estado;
           PurchCrMemoHeader.MODIFY;
           rMes."Num Doc":=PurchCrMemoHeader."No.";
           rMes.Procesado:=TRUE;
           rMes.MODIFY;
         END;
         //
        UNTIL rMes.NEXT=0;
        SalesInvHeader.RESET;
        SalesCrMemoHeader.RESET;
        PurchInvHeader.RESET;
        PurchCrMemoHeader.RESET;

        a:=0;
        Ventana.UPDATE(2,rMes.COUNT);
        if rMes.FINDFIRST THEN REPEAT
         a:=a+1;
         Ventana.UPDATE(1,a);

         if rMes.Tipo='FE' THEN BEGIN
          if SalesInvHeader.GET(rMes.Documento) THEN BEGIN
           SalesInvHeader.Estado:=rMes.Estado;
           SalesInvHeader.MODIFY;
          END ELSE BEGIN
           if SalesCrMemoHeader.GET(rMes.Documento) THEN BEGIN
           SalesCrMemoHeader.Estado:=rMes.Estado;
           SalesCrMemoHeader.MODIFY;
           END;
          END;
         END ELSE BEGIN
           PurchInvHeader.RESET;
           PurchCrMemoHeader.RESET;
           PurchInvHeader.SETRANGE(PurchInvHeader."Vendor Invoice No.",rMes.Documento);
           PurchInvHeader.SETFILTER(PurchInvHeader."VAT Registration No.",'%1','*'+rMes.Cif+'*');
           if PurchInvHeader.FINDFIRST THEN BEGIN
            PurchInvHeader.Estado:=rMes.Estado;
            PurchInvHeader.MODIFY;
            rMes."Num Doc":=PurchInvHeader."No.";
            rMes.MODIFY;
           END ELSE BEGIN
           PurchCrMemoHeader.SETRANGE(PurchCrMemoHeader."Vendor Cr. Memo No.",rMes.Documento);
           PurchCrMemoHeader.SETFILTER(PurchCrMemoHeader."VAT Registration No.",'%1','*'+rMes.Cif+'*');
           if PurchCrMemoHeader.FINDFIRST THEN BEGIN
           PurchCrMemoHeader.Estado:=rMes.Estado;
           PurchCrMemoHeader.MODIFY;
           rMes."Num Doc":=PurchCrMemoHeader."No.";
           rMes.MODIFY;
           END ELSE BEGIN
            rInf.GET;
            if rMes.Cif<>rInf."VAT Registration No." THEN BEGIN
             r23.SETFILTER("VAT Registration No.",'%1','*'+rMes.Cif+'*');
             r23.FINDFIRST;
             PurchInvHeader.RESET;
             PurchCrMemoHeader.RESET;
             PurchInvHeader.SETRANGE(PurchInvHeader."Vendor Invoice No.",rMes.Documento);
             PurchInvHeader.SETRANGE(PurchInvHeader."Buy-from Vendor No.",r23."No.");
            if PurchInvHeader.FINDFIRST THEN BEGIN
             PurchInvHeader.Estado:=rMes.Estado;
             PurchInvHeader.MODIFY;
             rMes."Num Doc":=PurchInvHeader."No.";
             rMes.MODIFY;
            END ELSE BEGIN
             PurchCrMemoHeader.SETRANGE(PurchCrMemoHeader."Vendor Cr. Memo No.",rMes.Documento);
             PurchCrMemoHeader.SETRANGE(PurchCrMemoHeader."Buy-from Vendor No.",r23."No.");
             if NOT PurchCrMemoHeader.FINDFIRST THEN MESSAGE('No se puede encontrar la factura o abono %2 del proveedor %3',rMes.Documento,r23."No.")
             ELSE BEGIN
             PurchCrMemoHeader.Estado:=rMes.Estado;
             PurchCrMemoHeader.MODIFY;
             rMes."Num Doc":=PurchCrMemoHeader."No.";
             rMes.MODIFY;
             END;
            END;
           END;
           END;
           END;
         END;
        UNTIL rMes.NEXT=0;
        rMes.MODIFYALL(rMes.Procesado,TRUE);
        Ventana.CLOSE; */
    END;

    /* BEGIN
    {
      $001 FCL-270910. Al cambiar y adelantar fechas proyecto modifico las correspondientes a las líneas del contrato.
                       Bloqueo la modificación de Descripción 2.
    }
    END.
  } */
}
