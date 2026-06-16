/// <summary>
/// Codeunit Fpr (ID 7001143).
/// </summary>
Codeunit 7001116 Fpr
{
    TableNo = "Job Queue Entry";
    Permissions = tabledata 15 = rimd, tabledata 17 = rimd, tabledata 18 = rimd, tabledata 2000000006 = rimd, tabledata 23 = rimd, tabledata 6650 = rimd, tabledata 92 = rimd, tabledata 13 = rimd;

    var
        a: Integer;
        PanelMediosCustomerBuf: Record Customer temporary;
        PanelMediosSalespersonBuf: Record "Salesperson/Purchaser" temporary;
        PanelMediosAccumulateBuffers: Boolean;
        PanelMediosFactYear: Integer;
        FilterYear: Integer;
        FilterSalespersonCode: text[20];
        FilterCustomerNo: text[20];
        GestionFacturación: Codeunit "Gestion Facturación";

    trigger OnRun()
    var

    begin

        GeneraEliminaciones();
        CompruebaSii();
        if GestionFacturación.ParseMediosJobParameter(Rec."Parameter String", FilterYear, FilterSalespersonCode, FilterCustomerNo) then
            GestionFacturación.RefreshPanelMediosCache(FilterYear, FilterSalespersonCode, FilterCustomerNo)
        else
            GestionFacturación.RefreshDefaultPanelMediosCaches();

    end;

    Procedure CompruebaSii()
    var
        Ficheros: Record Ficheros;
        EmailItem: Record "Email Item" temporary;
        EmailScenario: Enum "Email Scenario";
        Body: Text;
        LimiteFecha: DateTime;
        HayAlerta: Boolean;
        Subject: Text;
    begin
        LimiteFecha := CreateDateTime(CalcDate('-4D', Today), 0T);
        Ficheros.SetRange(Proceso, 'SII');
        Ficheros.SetRange(Enviado, false);
        Ficheros.SetFilter(SystemCreatedAt, '<%1', LimiteFecha);

        Body := StrSubstNo('En la empresa %1 hay ficheros del proceso SII sin enviar desde hace 4 o más días.\', COMPANYNAME);
        HayAlerta := false;

        Ficheros.SetRange(Procesado, true);
        if Ficheros.FindFirst() then begin
            HayAlerta := true;
            Subject := 'Alerta SII - ficheros procesados pero no enviados';
            Body += '\Ficheros procesados pero no enviados: FTP detenido en servidor eDiversa.\';
        end;

        Ficheros.SetRange(Procesado, false);
        if Ficheros.FindFirst() then begin
            HayAlerta := true;
            Subject := 'Alerta SII - ficheros no procesados';
            Body += '\Ficheros no procesados: revisar el equipo 187 y el servidor 215.\';
        end;

        if not HayAlerta then
            exit;

        Clear(EmailItem);
        EmailItem."Send to" := 'andreuserra@malla.es';
        EmailItem."Send CC" := 'lllompart@malla.es;luisuguet@malla.es';
        EmailItem.Subject := Subject;
        EmailItem.SetBodyText(Body);
        EmailItem.Send(true, EmailScenario::Informes);
    end;

    Procedure CalcularFpr()
    VAR
        r121: Record "Purch. Rcpt. Line";
        r23T: Record Proveedor;
        r17: Record "G/L Entry";
        aLB: Integer;
        rAlb: Record "Purch. Rcpt. Header";
        ef2: Decimal;
        rInf: Record "Company Information";
        rEmp: Record Company;
        r23: Record Vendor;
        r120: Record "Purch. Rcpt. Header";
        Total2: Decimal;
        eContabilizado: Decimal;
        eFacturado: Decimal;
        //Total2: Decimal;
        Total3: Decimal;
        rDev: Record 6650;
        Calculo: Record "Calculo Albaranes";
    BEGIN
        exit;
        rEmp.GET(COMPANYNAME);
        rInf.ChangeCompany(rEmp.Name);
        rInf.Get();
        //if Page.RunMODAL(0,r23)=ACTION::LookupOK THEN r23.SETRANGE(r23."No.",r23."No.");
        if rInf."Fecha Inicio FPR" = 0D THEN rInf."Fecha Inicio FPR" := 19000101D;
        // SoloDif := Confirm('¿Solo Diferencias?', false);
        // Ventana.OPEN('Procesando Proveedor ############1# de ############2#\' +
        //             'Nombre ############################################3#\' +
        //             'Solo Diferencias ######4#\' +
        //             '#################5# ################6# de #############7#');
        // Ventana.Update(4, SoloDif);
        // Ventana.UPDATE(2, r23.COUNT);
        SelectLatestVersion();
        r23T.DeleteAll();
        if r23.FINDFIRST THEN
            REPEAT
                a := a + 1;
                // Ventana.UPDATE(1, a);
                // Ventana.UPDATE(3, r23.Name);
                r23T.Init;
                r23T."No." := r23."No.";
                r23T.Priority := a;
                r23T.INSERT;
                r23T.SaldoConD := r23T.SaldoConD + SaldoCon(r23."No.", rEmp);
                r120.SETCURRENTKEY(r120."Pay-to Vendor No.", Finalizado2);
                r120.SETRANGE(r120."Pay-to Vendor No.", r23."No.");
                r120.SETRANGE(r120.Finalizado2, FALSE);
                // Ventana.UPDATE(5, 'Albaranes');
                // Ventana.UPDATE(7, r120.COUNT);
                if r120.FINDFIRST THEN
                    REPEAT
                        Total2 := 0;
                        aLB := aLB + 1;
                        CLEAR(eContabilizado);
                        CLEAR(eFacturado);
                        if Calculo.Get(r120."No.") then begin
                            Calculo.SetRange(Albaran, r120."No.");
                            Calculo.FindFirst();
                            Calculo.SetLoadFields(Facturado, "Facturado Contabilidad", Total2, Contabilizado);
                            if NOT r120.Finalizado THEN
                                Total2 := Calculo.Total2 - Calculo.Facturado;
                            //if Pas THEN
                            eFacturado := eFacturado + Calculo.Facturado;
                            eContabilizado := eContabilizado + Calculo.Contabilizado;
                            ef2 := eFacturado2(r120."No.");
                            if ef2 = eContabilizado THEN eFacturado := ef2;
                            if (ABS(eContabilizado) < ABS(Total2)) AND (eContabilizado >= 0) THEN Total2 := eContabilizado;
                            if r120.Contabilizado = FALSE THEN Total2 := 0;
                            r23T.Total2 := r23T.Total2 + Total2;
                            r23T.Total3 := r23T.Total3 + eContabilizado;
                            r23T.Total4 := r23T.Total4 + eFacturado;
                            if eContabilizado - eFacturado = 0 THEN BEGIN
                                rAlb.GET(r120."No.");
                                rAlb.Finalizado2 := TRUE;
                                rAlb.MODIFY;

                            END;

                        end else begin
                            r121.SETRANGE(r121."Document No.", r120."No.");
                            if r121.FINDFIRST THEN
                                REPEAT
                                    if NOT r120.Finalizado THEN
                                        Total2 := Total2 + ((r121.Quantity - r121."Quantity Invoiced")
                                        * r121."Direct Unit Cost" * (1 - r121."Line Discount %" / 100));
                                    //if Pas THEN
                                    eFacturado := eFacturado + r121."Quantity Invoiced" * r121."Direct Unit Cost"
                                    * (1 - r121."Line Discount %" / 100);
                                UNTIL r121.NEXT = 0;
                            r17.SETCURRENTKEY(r17."G/L Account No.", r17."Document No.");
                            r17.SETRANGE(r17."Document No.", r120."No.");
                            r17.SETRANGE("G/L Account No.", '6', '7');
                            if r17.FINDFIRST THEN BEGIN
                                r17.CALCSUMS(r17.Amount);
                                eContabilizado := eContabilizado + r17.Amount;
                            END;
                            r17.SETRANGE("G/L Account No.", '2', '299999999');
                            if r17.FINDFIRST THEN BEGIN
                                r17.CALCSUMS(r17.Amount);
                                eContabilizado := eContabilizado - r17.Amount;
                            END;
                            r17.SETRANGE("G/L Account No.", '47', '48');
                            if r17.FINDFIRST THEN BEGIN
                                r17.CALCSUMS(r17.Amount);
                                eContabilizado := eContabilizado + r17.Amount;
                            END;
                            ef2 := eFacturado2(r120."No.");
                            if ef2 = eContabilizado THEN eFacturado := ef2;
                            if (ABS(eContabilizado) < ABS(Total2)) AND (eContabilizado >= 0) THEN Total2 := eContabilizado;
                            if r120.Contabilizado = FALSE THEN Total2 := 0;
                            r23T.Total2 := r23T.Total2 + Total2;
                            r23T.Total3 := r23T.Total3 + eContabilizado;
                            r23T.Total4 := r23T.Total4 + eFacturado;
                            if eContabilizado - eFacturado = 0 THEN BEGIN
                                rAlb.GET(r120."No.");
                                rAlb.Finalizado2 := TRUE;
                                rAlb.MODIFY;
                            END;
                        end;
                    UNTIL r120.NEXT = 0;
                rDev.SETCURRENTKEY(rDev."Pay-to Vendor No.");
                rDev.SETRANGE(rDev."Pay-to Vendor No.", r23."No.");
                // Ventana.UPDATE(5, 'Devoluciones');
                // Ventana.UPDATE(7, rDev.COUNT);
                aLB := 0;
                if rDev.FINDFIRST THEN
                    REPEAT
                        aLB := aLB + 1;
                        // Ventana.UPDATE(6, aLB);
                        r23T.Albaranes2D := r23T.Albaranes2D + (eContabilizadoD(rDev) - eFacturadoD(rDev));
                    UNTIL rDev.NEXT = 0;

                // if SoloDif THEN BEGIN
                //     Rec.GET(r23."No.");
                //     if ROUND(ABS(SaldoConD[r23T.Priority]
                //     + Total[2, r23T.Priority] + Albaranes2D[r23T.Priority] + Albaranes3D[r23T.Priority]), 1, '=') > 5 THEN
                //         MARK := TRUE;
                // END;
                //  if a=25 THEN r23.FINDLAST;
                r23T.Modify();
            UNTIL r23.NEXT = 0;
        // Ventana.CLOSE;
        // if SoloDif THEN Rec.MARKEDONLY := TRUE;

    end;

    Procedure GeneraEliminaciones()

    VAR
        rEmp: Record 2000000006;
        rCom: Record "Company Information";
        r18: Record Customer;
        r23: Record Vendor;
        rGrp: Record "Vendor Posting Group";
        rGrc: Record 92;
        r15: Record 15;
        r50889: Record "Saldo Interempresa";
        a: Integer;
        r17: Record "G/L Entry";
        Control: Codeunit ControlProcesos;
    BEGIN
        rEmp.SetRange("Evaluation Company", false);
        if rEmp.FINDFIRST THEN
            REPEAT
                if Control.Permiso_Empresas(remp.Name) then begin
                    rCom.ChangeCompany(rEmp.Name);
                    rCom.Get();
                    if rCom.InterEmpresas Then Begin
                        //Ventana.UPDATE(4, rEmp.Name);
                        r17.RESET;
                        r17.CHANGECOMPANY(rEmp.Name);
                        r17.SETCURRENTKEY("G/L Account No.", "Source Type", "Source No.", "Posting Date"
                        , "Document Type", "Gen. Posting Type");
                        //Desde dia i de ewnero a 31 de diciembrr del Año actúal
                        r17.SetRange("Posting Date", CalcDate('PA-1A+1D', WORKDATE), CALCDATE('PA', WORKDATE));
                        r17.MODIFYALL(Eliminaciones, FALSE);
                        rGrp.CHANGECOMPANY(rEmp.Name);
                        rGrp.SETRANGE(rGrp."Payables Account", '402', '4039999999');
                        //Ventana.UPDATE(1, 'Proveedores');
                        if rGrp.FINDFIRST THEN
                            REPEAT
                                r23.CHANGECOMPANY(rEmp.Name);
                                r23.SETRANGE(r23."Vendor Posting Group", rGrp.Code);
                                if r23.FINDFIRST THEN
                                    REPEAT
                                        //Ventana.UPDATE(2, r23."No.");
                                        if r23.Blocked = r23.Blocked::" " THEN BEGIN
                                            //
                                            r15.CHANGECOMPANY(rEmp.Name);
                                            r15.SETRANGE(r15."Account Type", r15."Account Type"::Posting);
                                            if r15.FINDFIRST THEN
                                                REPEAT
                                                    //Ventana.UPDATE(3, r15."No.");
                                                    r17.RESET;
                                                    r17.CHANGECOMPANY(rEmp.Name);
                                                    r17.SETCURRENTKEY("G/L Account No.", "Source Type", "Source No.", "Posting Date"
                                                    , "Document Type", "Gen. Posting Type");
                                                    r17.SETRANGE(r17."Source Type", r17."Source Type"::Vendor);
                                                    r17.SETRANGE(r17."Source No.", r23."No.");
                                                    r17.SETRANGE(r17."G/L Account No.", r15."No.");
                                                    r17.SETFILTER(r17."Document Type", '%1|%2|%3',
                                                    r17."Document Type"::Receipt, r17."Document Type"::Invoice, r17."Document Type"::"Credit Memo");
                                                    r17.SetRange("Posting Date", CalcDate('PA-1A+1D', WORKDATE), CALCDATE('PA', WORKDATE));
                                                    r17.MODIFYALL(Eliminaciones, TRUE);
                                                UNTIL r15.NEXT = 0;
                                        END;
                                    UNTIL r23.NEXT = 0;
                            UNTIL rGrp.NEXT = 0;
                        rGrc.CHANGECOMPANY(rEmp.Name);
                        //Ventana.UPDATE(1, 'Clientes');
                        rGrc.SETRANGE(rGrc."Receivables Account", '432', '4339999999');
                        if rGrc.FINDFIRST THEN
                            REPEAT
                                r18.CHANGECOMPANY(rEmp.Name);
                                r18.SETRANGE(r18."Customer Posting Group", rGrc.Code);
                                if r18.FINDFIRST THEN
                                    REPEAT
                                        if r18.Blocked = r18.Blocked::" " THEN BEGIN
                                            //Ventana.UPDATE(2, r18."No.");
                                            r15.CHANGECOMPANY(rEmp.Name);
                                            r15.SETRANGE(r15."Account Type", r15."Account Type"::Posting);
                                            if r15.FINDFIRST THEN
                                                REPEAT
                                                    //Ventana.UPDATE(3, r15."No.");
                                                    r17.SETCURRENTKEY("G/L Account No.", "Source Type", "Source No.", "Posting Date"
                                                    , "Document Type", "Gen. Posting Type");
                                                    r17.RESET;
                                                    r17.CHANGECOMPANY(rEmp.Name);
                                                    r17.SETRANGE(r17."Source Type", r17."Source Type"::Customer);
                                                    r17.SETRANGE(r17."Source No.", r18."No.");
                                                    r17.SETRANGE(r17."G/L Account No.", r15."No.");
                                                    r17.SetRange("Posting Date", CalcDate('PA-1A+1D', WORKDATE), CALCDATE('PA', WORKDATE));
                                                    r17.SETFILTER(r17."Document Type", '%1|%2|%3',
                                                    r17."Document Type"::Receipt, r17."Document Type"::Invoice, r17."Document Type"::"Credit Memo");

                                                    r17.MODIFYALL(Eliminaciones, TRUE);
                                                UNTIL r15.NEXT = 0;
                                        END;
                                    UNTIL r18.NEXT = 0;
                            UNTIL rGrc.NEXT = 0;
                    end;
                end;
            UNTIL rEmp.NEXT = 0;
        //Ventana.CLOSE;
    END;

    Procedure CalcularFpr(var r23: Record Vendor)
    VAR
        r121: Record "Purch. Rcpt. Line";
        r23T: Record Proveedor;
        Pas: Boolean;
        r17: Record "G/L Entry";
        aLB: Integer;
        rAlb: Record "Purch. Rcpt. Header";
        ef2: Decimal;
        rInf: Record "Company Information";
        rEmp: Record Company;
        r120: Record "Purch. Rcpt. Header";
        Total2: Decimal;
        eContabilizado: Decimal;
        eFacturado: Decimal;
        //Total2: Decimal;
        Total3: Decimal;
        rDev: Record 6650;
        Calculo: Record "Calculo Albaranes";
    BEGIN
        exit;
        rEmp.GET(COMPANYNAME);
        rInf.ChangeCompany(rEmp.Name);
        rInf.Get();
        //if Page.RunMODAL(0,r23)=ACTION::LookupOK THEN r23.SETRANGE(r23."No.",r23."No.");
        if rInf."Fecha Inicio FPR" = 0D THEN rInf."Fecha Inicio FPR" := 19000101D;
        // SoloDif := Confirm('¿Solo Diferencias?', false);
        // Ventana.OPEN('Procesando Proveedor ############1# de ############2#\' +
        //             'Nombre ############################################3#\' +
        //             'Solo Diferencias ######4#\' +
        //             '#################5# ################6# de #############7#');
        // Ventana.Update(4, SoloDif);
        // Ventana.UPDATE(2, r23.COUNT);
        r23T.Get(r23."No.");
        r23T.Delete();
        // if r23.FINDFIRST THEN
        //     REPEAT
        a := a + 1;
        // Ventana.UPDATE(1, a);
        // Ventana.UPDATE(3, r23.Name);
        r23T."No." := r23."No.";
        r23T.Priority := a;
        r23T.INSERT;
        r23T.SaldoConD := r23T.SaldoConD + SaldoCon(r23."No.", rEmp);
        r120.SETCURRENTKEY(r120."Pay-to Vendor No.", Finalizado2);
        r120.SETRANGE(r120."Pay-to Vendor No.", r23."No.");
        r120.SETRANGE(r120.Finalizado2, FALSE);
        // Ventana.UPDATE(5, 'Albaranes');
        // Ventana.UPDATE(7, r120.COUNT);
        if r120.FINDFIRST THEN
            REPEAT
                Total2 := 0;
                aLB := aLB + 1;
                //Ventana.UPDATE(6, aLB);
                //Pas := Pasada(r120, '');
                CLEAR(eContabilizado);
                CLEAR(eFacturado);
                if Calculo.Get(r120."No.") then begin
                    if NOT r120.Finalizado THEN
                        Total2 := Total2 + Calculo.Facturado;
                    if Pas THEN
                        eFacturado := eFacturado + Calculo.Facturado;
                    eContabilizado := eContabilizado + Calculo.Contabilizado;
                    ef2 := eFacturado2(r120."No.");
                    if ef2 = eContabilizado THEN eFacturado := ef2;
                    if (ABS(eContabilizado) < ABS(Total2)) AND (eContabilizado >= 0) THEN Total2 := eContabilizado;
                    if r120.Contabilizado = FALSE THEN Total2 := 0;
                    r23T.Total2 := r23T.Total2 + Total2;
                    r23T.Total3 := r23T.Total3 + eContabilizado;
                    r23T.Total4 := r23T.Total4 + eFacturado;
                    if eContabilizado - eFacturado = 0 THEN BEGIN
                        rAlb.GET(r120."No.");
                        rAlb.Finalizado2 := TRUE;
                        rAlb.MODIFY;
                    END;
                end else begin
                    r121.SETRANGE(r121."Document No.", r120."No.");
                    if r121.FINDFIRST THEN
                        REPEAT
                            if NOT r120.Finalizado THEN
                                Total2 := Total2 + ((r121.Quantity - r121."Quantity Invoiced")
                                * r121."Direct Unit Cost" * (1 - r121."Line Discount %" / 100));
                            if Pas THEN
                                eFacturado := eFacturado + r121."Quantity Invoiced" * r121."Direct Unit Cost"
                                * (1 - r121."Line Discount %" / 100);
                        UNTIL r121.NEXT = 0;
                    r17.SETCURRENTKEY(r17."G/L Account No.", r17."Document No.");
                    r17.SETRANGE(r17."Document No.", r120."No.");
                    r17.SETRANGE("G/L Account No.", '6', '7');
                    if r17.FINDFIRST THEN BEGIN
                        r17.CALCSUMS(r17.Amount);
                        eContabilizado := eContabilizado + r17.Amount;
                    END;
                    r17.SETRANGE("G/L Account No.", '2', '299999999');
                    if r17.FINDFIRST THEN BEGIN
                        r17.CALCSUMS(r17.Amount);
                        eContabilizado := eContabilizado - r17.Amount;
                    END;
                    r17.SETRANGE("G/L Account No.", '47', '48');
                    if r17.FINDFIRST THEN BEGIN
                        r17.CALCSUMS(r17.Amount);
                        eContabilizado := eContabilizado + r17.Amount;
                    END;
                    ef2 := eFacturado2(r120."No.");
                    if ef2 = eContabilizado THEN eFacturado := ef2;
                    if (ABS(eContabilizado) < ABS(Total2)) AND (eContabilizado >= 0) THEN Total2 := eContabilizado;
                    if r120.Contabilizado = FALSE THEN Total2 := 0;
                    r23T.Total2 := r23T.Total2 + Total2;
                    r23T.Total3 := r23T.Total3 + eContabilizado;
                    r23T.Total4 := r23T.Total4 + eFacturado;
                    if eContabilizado - eFacturado = 0 THEN BEGIN
                        rAlb.GET(r120."No.");
                        rAlb.Finalizado2 := TRUE;
                        rAlb.MODIFY;
                    END;
                end;
            UNTIL r120.NEXT = 0;
        rDev.SETCURRENTKEY(rDev."Pay-to Vendor No.");
        rDev.SETRANGE(rDev."Pay-to Vendor No.", r23."No.");
        // Ventana.UPDATE(5, 'Devoluciones');
        // Ventana.UPDATE(7, rDev.COUNT);
        aLB := 0;
        if rDev.FINDFIRST THEN
            REPEAT
                aLB := aLB + 1;
                // Ventana.UPDATE(6, aLB);
                r23T.Albaranes2D := r23T.Albaranes2D + (eContabilizadoD(rDev) - eFacturadoD(rDev));
            UNTIL rDev.NEXT = 0;
        r23T.Modify();
        // if SoloDif THEN BEGIN
        //     Rec.GET(r23."No.");
        //     if ROUND(ABS(SaldoConD[r23T.Priority]
        //     + Total[2, r23T.Priority] + Albaranes2D[r23T.Priority] + Albaranes3D[r23T.Priority]), 1, '=') > 5 THEN
        //         MARK := TRUE;
        // END;
        //  if a=25 THEN r23.FINDLAST;
        //  UNTIL r23.NEXT = 0;
        // Ventana.CLOSE;
        // if SoloDif THEN Rec.MARKEDONLY := TRUE;

    end;

    // PROCEDURE Pasada(Num: Code[20]): Boolean;
    // VAR
    //    r122: Record "Purch. Inv. Header";

    // BEGIN
    //     if Num <> '' Then
    //         if NOT r122.GET(Num) THEN
    //             EXIT(FALSE);
    //     exit(true);
    //     // r25.SETCURRENTKEY(r25."Document No.");
    //     // if Num <> '' Then begin
    //     //     r25.SETRANGE(r25."Document No.", Num);
    //     //     if r25.FINDFIRST THEN EXIT(TRUE);
    //     // end;
    //     // r123.SetRange("Receipt No.", r120."No.");
    //     // if r123.FindFirst() then exit(true);
    //     // r123.Reset;
    //     // //r123.SETCURRENTKEY(r123.Description);
    //     // //r123.SETRANGE(r123."Buy-from Vendor No.","Buy-from Vendor No.");
    //     // r123.SETFILTER(r123.Description, '%1', '*' + r120."No." + '*');
    //     // if NOT r123.FINDFIRST THEN BEGIN
    //     //     //r125.SETCURRENTKEY(r125.Description);
    //     //     r125.SETFILTER(r125.Description, '%1', '*' + r120."No." + '*');
    //     //     if NOT r125.FINDFIRST THEN EXIT(FALSE);
    //     //     EXIT(TRUE);
    //     // END else begin
    //     //     r123."Receipt No.":=r120."No.";
    //     //     r123.Modify();
    //     // end;

    //     EXIT(TRUE);
    //END;



    PROCEDURE SaldoCon(Num: Code[20]; var rEmp: Record "Company"): Decimal;
    VAR
        r17: Record "G/L Entry";
        rGrp: Record "Vendor Posting Group";
        Importe: Decimal;
        r15: Record 15;
        r15t: Record 15 temporary;
        b: Integer;
        r312: Record "Purchases & Payables Setup";
        rPrev: Record "Periodos pago emplazamientos";
        rInf: Record "Company Information";
        r23: Record Vendor;
    BEGIN
        r23.Get(Num);
        r312.GET;
        r17.CLEARMARKS;
        r17.SETCURRENTKEY("Source Type", "Source No.", "G/L Account No.");
        r17.SETRANGE("Source Type", r17."Source Type"::Vendor);
        r17.SETRANGE(r17."Source No.", Num);
        //r17.SETFILTER("Reason Code",'%1','');
        if NOT rGrp.GET(r23."Vendor Posting Group") THEN
            rGrp.INIT;
        if rGrp.FINDFIRST THEN
            REPEAT
                if r15.GET(rGrp.FPR) THEN BEGIN
                    rPrev.SETRANGE(rPrev."Cuenta Contable FPR", r15."No.");
                    if (r312."Cuenta FPR Emplz." <> r15."No.") AND (NOT rPrev.FINDFIRST) THEN begin
                        r15t := r15;
                        if r15t.insert then;
                    end;
                END;

            UNTIL rGrp.NEXT = 0;
        rInf.ChangeCompany(rEmp.Name);
        rInf.Get();
        if r15t.FINDFIRST THEN
            REPEAT
                r17.SETRANGE(r17."G/L Account No.", r15t."No.");
                if r17.FINDFIRST THEN
                    REPEAT
                        if r17."Posting Date" >= rInf."Fecha Inicio FPR" THEN BEGIN
                            //if r17.Eliminaciones=FALSE THEN
                            if (COMPANYNAME <> 'Malla Publicidad') THEN
                                Importe := Importe + r17.Amount
                            ELSE
                                if COPYSTR(r17."G/L Account No.", 1, 4) <> '4109' THEN Importe := Importe + r17.Amount;
                        END;
                    UNTIL r17.NEXT = 0;
            UNTIL r15t.NEXT = 0;
        EXIT(Importe);
    END;

    PROCEDURE eContabilizadoD(VAR rDev: Record 6650): Decimal;
    VAR
        r17: Record "G/L Entry";
        Importe: Decimal;
    BEGIN
        r17.SETCURRENTKEY(r17."Document No.");
        r17.SETRANGE(r17."Document No.", rDev."No.");
        if r17.FINDFIRST THEN
            REPEAT
                if COPYSTR(r17."G/L Account No.", 1, 1) = '6' THEN Importe := Importe + r17.Amount;
                if COPYSTR(r17."G/L Account No.", 1, 1) = '2' THEN Importe := Importe + r17.Amount;
            UNTIL r17.NEXT = 0;
        EXIT(Importe);
    END;

    PROCEDURE eFacturadoD(VAR rDev: Record 6650): Decimal;
    VAR
        r121: Record 6651;
        Importe: Decimal;
    BEGIN
        r121.SETRANGE(r121."Document No.", rDev."No.");
        if r121.FINDFIRST THEN
            REPEAT
                Importe := Importe + r121."Quantity Invoiced" * r121."Direct Unit Cost"
                * (1 - r121."Line Discount %" / 100);
            UNTIL r121.NEXT = 0;
        EXIT(-Importe);
    END;


    PROCEDURE eFacturado2(No: Code[20]): Decimal;
    VAR
        r17: Record "G/L Entry";
        Importe: Decimal;
    BEGIN
        r17.SETCURRENTKEY("G/L Account No.", "Document No.", "Posting Date", "Tax Area Code");
        r17.SETRANGE(r17."Tax Area Code", No);
        r17.SETFILTER(r17."Document No.", '<>%1', No);
        r17.SETRANGE(r17."G/L Account No.", '40090000', '40099999');
        if r17.FINDFIRST THEN BEGIN
            r17.CALCSUMS(Amount);
            Importe := r17.Amount;
        END;
        r17.SETCURRENTKEY("G/L Account No.", "Document No.", "Posting Date", "Tax Area Code");
        r17.SETRANGE(r17."Tax Area Code", No);
        r17.SETFILTER(r17."Document No.", '<>%1', No);
        r17.SETRANGE(r17."G/L Account No.", '41090000', '41099999');
        if r17.FINDFIRST THEN BEGIN
            r17.CALCSUMS(Amount);
            Importe += r17.Amount;
        END;

        EXIT(Importe);
    END;















}