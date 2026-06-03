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

    trigger OnRun()
    var

    begin
        GeneraEliminaciones();


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

    procedure RefreshDefaultPanelMediosCaches()
    var
        CurrentYear: Integer;
    begin
        CurrentYear := Date2DMY(WorkDate(), 3);
        RefreshPanelMediosCache(CurrentYear, '', '');
        if CurrentYear > 2000 then
            RefreshPanelMediosCache(CurrentYear - 1, '', '');
    end;

    procedure RefreshPanelMediosCache(FilterYear: Integer; FilterSalespersonCode: Code[20]; FilterCustomerNo: Code[20])
    var
        Cache: Record "Calculo Albaranes";
        SumTotCont: Decimal;
        SumPosted: Decimal;
        SumTotContPrev: Decimal;
        SumPostedPrev: Decimal;
        Cutoff: Date;
        CutoffPrev: Date;
        DummyCount: Integer;
        PctFacturado: Decimal;
        PctPendiente: Decimal;
        PctFacturadoPrev: Decimal;
        PctPendientePrev: Decimal;
        BillingCutoffText: Text[120];
        Contratos: Record "Sales Header";
    begin
        if FilterYear = 0 then
            exit;

        PanelMediosFactYear := FilterYear;
        EnsurePanelMediosCacheRecord(Cache, FilterYear, FilterSalespersonCode, FilterCustomerNo);
        Cache.Status := Cache.Status::Calculating;
        Cache."Error Message" := '';
        Cache.Modify(true);

        PanelMediosAccumulateBuffers := (FilterSalespersonCode = '') and (FilterCustomerNo = '');
        if PanelMediosAccumulateBuffers then
            InitPanelMediosFactBuffers();

        ClearLastError();
        if not DoRefreshPanelMediosCache(
             FilterYear, FilterSalespersonCode, FilterCustomerNo,
             SumTotCont, SumPosted, SumTotContPrev, SumPostedPrev,
             Cutoff, CutoffPrev, DummyCount,
             PctFacturado, PctPendiente, PctFacturadoPrev, PctPendientePrev, BillingCutoffText, Contratos) then begin
            Cache.Status := Cache.Status::Error;
            Cache."Error Message" := CopyStr(GetLastErrorText(), 1, MaxStrLen(Cache."Error Message"));
            Cache.Modify(true);
            exit;
        end;

        Cache."Pct. Facturado" := PctFacturado;
        Cache."Pct. Pendiente" := PctPendiente;
        Cache."Pct. Facturado Año Ant." := PctFacturadoPrev;
        Cache."Pct. Pendiente Año Ant." := PctPendientePrev;
        Cache."Contratos Count" := DummyCount;
        Cache."Billing Cutoff Text" := CopyStr(BillingCutoffText, 1, MaxStrLen(Cache."Billing Cutoff Text"));
        Cache."Last Updated" := CurrentDateTime;
        Cache.Status := Cache.Status::Calculado;
        Cache."Error Message" := '';
        Cache.Modify(true);

        if PanelMediosAccumulateBuffers then
            FlushPanelMediosFactBuffers(FilterYear, BillingCutoffText, CurrentDateTime)
        else
            FlushPanelMediosFactForFilters(
                FilterYear, FilterSalespersonCode, FilterCustomerNo,
                PctFacturado, PctPendiente, PctFacturadoPrev, PctPendientePrev,
                DummyCount, BillingCutoffText, CurrentDateTime);
    end;

    procedure TryLoadPanelMediosCache(
        FilterYear: Integer; FilterSalespersonCode: Code[20]; FilterCustomerNo: Code[20];
        var PctFacturado: Decimal; var PctPendiente: Decimal;
        var PctFacturadoPrev: Decimal; var PctPendientePrev: Decimal;
        var ContratosCount: Integer; var BillingCutoffText: Text[120]): Boolean
    var
        Cache: Record "Calculo Albaranes";
        LastUpdated: DateTime;
        SalespersonCode: Record "Salesperson/Purchaser";
        CustomerNo: Record Customer;
    begin
        If FilterSalespersonCode <> '' then begin
            SalespersonCode.Get(FilterSalespersonCode);
            PctFacturado := SalespersonCode."Pct. Facturado";
            PctPendiente := SalespersonCode."Pct. Pendiente";
            PctFacturadoPrev := SalespersonCode."Pct. Facturado Año Ant.";
            PctPendientePrev := SalespersonCode."Pct. Pendiente Año Ant.";
            ContratosCount := SalespersonCode."Contratos Count";
            BillingCutoffText := SalespersonCode."Billing Cutoff Text";
            LastUpdated := SalespersonCode."Last Updated";
            exit(true);
        end;
        If FilterCustomerNo <> '' then begin
            CustomerNo.Get(FilterCustomerNo);
            PctFacturado := CustomerNo."Pct. Facturado";
            PctPendiente := CustomerNo."Pct. Pendiente";
            PctFacturadoPrev := CustomerNo."Pct. Facturado Año Ant.";
            PctPendientePrev := CustomerNo."Pct. Pendiente Año Ant.";
            ContratosCount := CustomerNo."Contratos Count";
            BillingCutoffText := CustomerNo."Billing Cutoff Text";
            LastUpdated := CustomerNo."Last Updated";
            exit(true);
        end;
        if GetPanelMediosOrchestrationCache(Cache, FilterYear, FilterSalespersonCode, FilterCustomerNo) then
            if Cache.Status <> Cache.Status::Calculado then
                exit(false);

        if not TryLoadPanelMediosFactData(
             FilterYear, FilterSalespersonCode, FilterCustomerNo,
             PctFacturado, PctPendiente, PctFacturadoPrev, PctPendientePrev,
             ContratosCount, BillingCutoffText, LastUpdated) then
            exit(false);

        BillingCutoffText := BillingCutoffText + StrSubstNo(' · actualizado %1', LastUpdated);
        exit(true);
    end;

    procedure IsPanelMediosFactCacheReady(FilterYear: Integer; FilterSalespersonCode: Code[20]; FilterCustomerNo: Code[20]): Boolean
    var
        PctFacturado: Decimal;
        PctPendiente: Decimal;
        PctFacturadoPrev: Decimal;
        PctPendientePrev: Decimal;
        ContratosCount: Integer;
        BillingCutoffText: Text[120];
    begin
        exit(TryLoadPanelMediosCache(
            FilterYear, FilterSalespersonCode, FilterCustomerNo,
            PctFacturado, PctPendiente, PctFacturadoPrev, PctPendientePrev,
            ContratosCount, BillingCutoffText));
    end;

    procedure GetPanelMediosCacheStatusText(FilterYear: Integer; FilterSalespersonCode: Code[20]; FilterCustomerNo: Code[20]): Text
    var
        Cache: Record "Calculo Albaranes";
        LastUpdated: DateTime;
    begin
        if GetPanelMediosOrchestrationCache(Cache, FilterYear, FilterSalespersonCode, FilterCustomerNo) then
            case Cache.Status of
                Cache.Status::Calculating:
                    exit('Calculando facturación en segundo plano…');
                Cache.Status::Error:
                    exit('Error en último cálculo: ' + Cache."Error Message");
                Cache.Status::Calculado:
                    if GetPanelMediosFactLastUpdated(FilterYear, FilterSalespersonCode, FilterCustomerNo, LastUpdated) then
                        exit(StrSubstNo('Caché lista · %1', LastUpdated))
                    else
                        exit(StrSubstNo('Caché lista · %1', Cache."Last Updated"));
                else
                    exit('Pendiente de cálculo en cola.');
            end;

        if GetPanelMediosFactLastUpdated(FilterYear, FilterSalespersonCode, FilterCustomerNo, LastUpdated) then
            exit(StrSubstNo('Caché lista · %1', LastUpdated));

        exit('Sin caché. Se calculará en la cola de proyectos (Fpr).');
    end;

    procedure EnqueuePanelMediosCacheRefresh(FilterYear: Integer; FilterSalespersonCode: Code[20]; FilterCustomerNo: Code[20])
    var
        JobQueueEntry: Record "Job Queue Entry";
    begin
        JobQueueEntry.Init();
        JobQueueEntry."Object Type to Run" := JobQueueEntry."Object Type to Run"::Codeunit;
        JobQueueEntry."Object ID to Run" := Codeunit::Fpr;
        JobQueueEntry."Parameter String" := BuildMediosJobParameter(FilterYear, FilterSalespersonCode, FilterCustomerNo);
        JobQueueEntry."Earliest Start Date/Time" := CurrentDateTime;
        JobQueueEntry."Maximum No. of Attempts to Run" := 3;
        JobQueueEntry.Description := 'Panel Medios · facturación';
        Codeunit.Run(Codeunit::"Job Queue - Enqueue", JobQueueEntry);
    end;

    local procedure DoRefreshPanelMediosCache(
        FilterYear: Integer; FilterSalespersonCode: Code[20]; FilterCustomerNo: Code[20];
        var SumTotCont: Decimal; var SumPosted: Decimal; var SumTotContPrev: Decimal; var SumPostedPrev: Decimal;
        var Cutoff: Date; var CutoffPrev: Date; var ContractCount: Integer;
        var PctFacturado: Decimal; var PctPendiente: Decimal; var PctFacturadoPrev: Decimal; var PctPendientePrev: Decimal;
        var BillingCutoffText: Text[120]; var Contratos: Record "Sales Header"): Boolean
    var
        DummyCount: Integer;
    begin
        Cutoff := GetPanelMediosBillingCutoffDate(FilterYear);
        CutoffPrev := CalcDate('<-1Y>', Cutoff);
        BillingCutoffText := StrSubstNo('Facturado registrado a %1 · comparado con %2', Cutoff, CutoffPrev);

        AccumulatePanelMediosFacturacion(Contratos, FilterYear, FilterSalespersonCode, FilterCustomerNo, Cutoff, SumTotCont, SumPosted, ContractCount);
        CalcPanelMediosFacturacionPiePct(SumTotCont, SumPosted, PctFacturado, PctPendiente);

        AccumulatePanelMediosFacturacion(Contratos, FilterYear - 1, FilterSalespersonCode, FilterCustomerNo, CutoffPrev, SumTotContPrev, SumPostedPrev, DummyCount);
        CalcPanelMediosFacturacionPiePct(SumTotContPrev, SumPostedPrev, PctFacturadoPrev, PctPendientePrev);
        exit(true);
    end;

    local procedure AccumulatePanelMediosFacturacion(
        var Contratos: Record "Sales Header"; Year: Integer; FilterSalespersonCode: Code[20]; FilterCustomerNo: Code[20];
        CutoffDate: Date; var SumTotCont: Decimal; var SumPosted: Decimal; var ContractCount: Integer)
    var
        ControlProcesos: Codeunit ControlProcesos;
        TotCont: Decimal;
        TotImp: Decimal;
        PostedAmount: Decimal;
        PendingAmount: Decimal;
    begin
        SumTotCont := 0;
        SumPosted := 0;
        ContractCount := 0;

        ApplyPanelMediosContractFilters(Contratos, Year, FilterSalespersonCode, FilterCustomerNo);
        Contratos.SetFilter(Estado, '<>%1&<>%2', Contratos.Estado::Cancelado, Contratos.Estado::Anulado);
        if Contratos.FindSet() then
            repeat
                ControlProcesos.GetContractAmounts(Contratos, CutoffDate, TotCont, TotImp, PostedAmount, PendingAmount);
                if TotCont = 0 then
                    TotCont := TotImp;
                if TotCont <> 0 then begin
                    SumTotCont += TotCont;
                    SumPosted += PostedAmount;
                    ContractCount += 1;
                    if PanelMediosAccumulateBuffers then
                        AccumulatePanelMediosFactBuffers(
                            Contratos."Sell-to Customer No.", Contratos."Salesperson Code",
                            TotCont, PostedAmount, Year, PanelMediosFactYear);
                end;
            until Contratos.Next() = 0;
    end;

    local procedure InitPanelMediosFactBuffers()
    begin
        PanelMediosCustomerBuf.Reset();
        PanelMediosCustomerBuf.DeleteAll();
        PanelMediosSalespersonBuf.Reset();
        PanelMediosSalespersonBuf.DeleteAll();
    end;

    local procedure AccumulatePanelMediosFactBuffers(
        CustomerNo: Code[20]; SalespersonCode: Code[20]; TotCont: Decimal; PostedAmount: Decimal;
        ContractYear: Integer; FilterYear: Integer)
    begin
        if CustomerNo <> '' then
            AccumulatePanelMediosCustomerBuffer(CustomerNo, TotCont, PostedAmount, ContractYear, FilterYear);
        if SalespersonCode <> '' then
            AccumulatePanelMediosSalespersonBuffer(SalespersonCode, TotCont, PostedAmount, ContractYear, FilterYear);
    end;

    local procedure AccumulatePanelMediosCustomerBuffer(
        CustomerNo: Code[20]; TotCont: Decimal; PostedAmount: Decimal; ContractYear: Integer; FilterYear: Integer)
    begin
        if not PanelMediosCustomerBuf.Get(CustomerNo) then begin
            PanelMediosCustomerBuf.Init();
            PanelMediosCustomerBuf."No." := CustomerNo;
            PanelMediosCustomerBuf.Insert();
        end;

        if ContractYear = FilterYear then begin
            PanelMediosCustomerBuf."Panel Medios Sum Tot Cont" += TotCont;
            PanelMediosCustomerBuf."Panel Medios Sum Posted" += PostedAmount;
            PanelMediosCustomerBuf."Contratos Count" += 1;
        end else begin
            PanelMediosCustomerBuf."Panel Medios Sum Tot Cont Ant" += TotCont;
            PanelMediosCustomerBuf."Panel Medios Sum Posted Ant" += PostedAmount;
        end;
        PanelMediosCustomerBuf.Modify();
    end;

    local procedure AccumulatePanelMediosSalespersonBuffer(
        SalespersonCode: Code[20]; TotCont: Decimal; PostedAmount: Decimal; ContractYear: Integer; FilterYear: Integer)
    begin
        if not PanelMediosSalespersonBuf.Get(SalespersonCode) then begin
            PanelMediosSalespersonBuf.Init();
            PanelMediosSalespersonBuf.Code := SalespersonCode;
            PanelMediosSalespersonBuf.Insert();
        end;

        if ContractYear = FilterYear then begin
            PanelMediosSalespersonBuf."Panel Medios Sum Tot Cont" += TotCont;
            PanelMediosSalespersonBuf."Panel Medios Sum Posted" += PostedAmount;
            PanelMediosSalespersonBuf."Contratos Count" += 1;
        end else begin
            PanelMediosSalespersonBuf."Panel Medios Sum Tot Cont Ant" += TotCont;
            PanelMediosSalespersonBuf."Panel Medios Sum Posted Ant" += PostedAmount;
        end;
        PanelMediosSalespersonBuf.Modify();
    end;

    local procedure FlushPanelMediosFactBuffers(FilterYear: Integer; BillingCutoffText: Text[120]; LastUpdated: DateTime)
    begin
        if PanelMediosCustomerBuf.FindSet() then
            repeat
                SavePanelMediosFactFromCustomerBuffer(PanelMediosCustomerBuf, FilterYear, BillingCutoffText, LastUpdated);
            until PanelMediosCustomerBuf.Next() = 0;

        if PanelMediosSalespersonBuf.FindSet() then
            repeat
                SavePanelMediosFactFromSalespersonBuffer(PanelMediosSalespersonBuf, FilterYear, BillingCutoffText, LastUpdated);
            until PanelMediosSalespersonBuf.Next() = 0;
    end;

    local procedure FlushPanelMediosFactForFilters(
        FilterYear: Integer; FilterSalespersonCode: Code[20]; FilterCustomerNo: Code[20];
        PctFacturado: Decimal; PctPendiente: Decimal; PctFacturadoPrev: Decimal; PctPendientePrev: Decimal;
        ContratosCount: Integer; BillingCutoffText: Text[120]; LastUpdated: DateTime)
    begin
        if FilterCustomerNo <> '' then begin
            SavePanelMediosFactToCustomer(
                FilterCustomerNo, FilterYear, PctFacturado, PctPendiente, PctFacturadoPrev, PctPendientePrev,
                ContratosCount, BillingCutoffText, LastUpdated);
            exit;
        end;
        if FilterSalespersonCode <> '' then
            SavePanelMediosFactToSalesperson(
                FilterSalespersonCode, FilterYear, PctFacturado, PctPendiente, PctFacturadoPrev, PctPendientePrev,
                ContratosCount, BillingCutoffText, LastUpdated);
    end;

    local procedure SavePanelMediosFactFromCustomerBuffer(
        CustomerBuffer: Record Customer temporary; FilterYear: Integer; BillingCutoffText: Text[120]; LastUpdated: DateTime)
    var
        Customer: Record Customer;
        PctFacturado: Decimal;
        PctPendiente: Decimal;
        PctFacturadoPrev: Decimal;
        PctPendientePrev: Decimal;
    begin
        if not Customer.Get(CustomerBuffer."No.") then
            exit;

        CalcPanelMediosFacturacionPiePct(
            CustomerBuffer."Panel Medios Sum Tot Cont", CustomerBuffer."Panel Medios Sum Posted",
            PctFacturado, PctPendiente);
        CalcPanelMediosFacturacionPiePct(
            CustomerBuffer."Panel Medios Sum Tot Cont Ant", CustomerBuffer."Panel Medios Sum Posted Ant",
            PctFacturadoPrev, PctPendientePrev);

        Customer."Pct. Facturado" := PctFacturado;
        Customer."Pct. Pendiente" := PctPendiente;
        Customer."Pct. Facturado Año Ant." := PctFacturadoPrev;
        Customer."Pct. Pendiente Año Ant." := PctPendientePrev;
        Customer."Contratos Count" := CustomerBuffer."Contratos Count";
        Customer."Billing Cutoff Text" := CopyStr(BillingCutoffText, 1, MaxStrLen(Customer."Billing Cutoff Text"));
        Customer."Panel Medios Fact. Año" := FilterYear;
        Customer."Last Updated" := LastUpdated;
        Customer.Modify(true);
    end;

    local procedure SavePanelMediosFactFromSalespersonBuffer(
        SalespersonBuffer: Record "Salesperson/Purchaser" temporary; FilterYear: Integer; BillingCutoffText: Text[120]; LastUpdated: DateTime)
    var
        SalespersonPurchaser: Record "Salesperson/Purchaser";
        PctFacturado: Decimal;
        PctPendiente: Decimal;
        PctFacturadoPrev: Decimal;
        PctPendientePrev: Decimal;
    begin
        if not SalespersonPurchaser.Get(SalespersonBuffer.Code) then
            exit;

        CalcPanelMediosFacturacionPiePct(
            SalespersonBuffer."Panel Medios Sum Tot Cont", SalespersonBuffer."Panel Medios Sum Posted",
            PctFacturado, PctPendiente);
        CalcPanelMediosFacturacionPiePct(
            SalespersonBuffer."Panel Medios Sum Tot Cont Ant", SalespersonBuffer."Panel Medios Sum Posted Ant",
            PctFacturadoPrev, PctPendientePrev);

        SalespersonPurchaser."Pct. Facturado" := PctFacturado;
        SalespersonPurchaser."Pct. Pendiente" := PctPendiente;
        SalespersonPurchaser."Pct. Facturado Año Ant." := PctFacturadoPrev;
        SalespersonPurchaser."Pct. Pendiente Año Ant." := PctPendientePrev;
        SalespersonPurchaser."Contratos Count" := SalespersonBuffer."Contratos Count";
        SalespersonPurchaser."Billing Cutoff Text" := CopyStr(BillingCutoffText, 1, MaxStrLen(SalespersonPurchaser."Billing Cutoff Text"));
        SalespersonPurchaser."Panel Medios Fact. Año" := FilterYear;
        SalespersonPurchaser."Last Updated" := LastUpdated;
        SalespersonPurchaser.Modify(true);
    end;

    local procedure ApplyPanelMediosContractFilters(var SalesHeader: Record "Sales Header"; Year: Integer; FilterSalespersonCode: Code[20]; FilterCustomerNo: Code[20])
    var
        DateFilterTxt: Text;
        FromDate: Date;
        ToDate: Date;
    begin
        SalesHeader.Reset();
        SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::Order);
        if Year <> 0 then begin
            FromDate := DMY2Date(1, 1, Year);
            ToDate := DMY2Date(31, 12, Year);
            DateFilterTxt := StrSubstNo('%1..%2', FromDate, ToDate);
            SalesHeader.SetFilter("Posting Date", DateFilterTxt);
        end;
        if FilterSalespersonCode <> '' then
            SalesHeader.SetRange("Salesperson Code", FilterSalespersonCode);
        if FilterCustomerNo <> '' then
            SalesHeader.SetRange("Sell-to Customer No.", FilterCustomerNo);
    end;

    local procedure GetPanelMediosBillingCutoffDate(FilterYear: Integer): Date
    begin
        if FilterYear = Date2DMY(WorkDate(), 3) then
            exit(WorkDate());
        exit(DMY2Date(31, 12, FilterYear));
    end;

    local procedure CalcPanelMediosFacturacionPiePct(SumTotCont: Decimal; SumPosted: Decimal; var PctFacturado: Decimal; var PctPendiente: Decimal)
    begin
        PctFacturado := CalcPanelMediosPct(SumPosted, SumTotCont);
        PctPendiente := CalcPanelMediosPct(SumTotCont - SumPosted, SumTotCont);
        if (PctFacturado = 0) and (PctPendiente = 0) and (SumTotCont <> 0) then
            PctPendiente := 100;
    end;

    local procedure CalcPanelMediosPct(Part: Decimal; Total: Decimal): Decimal
    begin
        if Total = 0 then
            exit(0);
        exit(Round(Part / Total * 100, 0.01));
    end;

    local procedure EnsurePanelMediosCacheRecord(var Cache: Record "Calculo Albaranes"; FilterYear: Integer; FilterSalespersonCode: Code[20]; FilterCustomerNo: Code[20])
    begin
        if not GetPanelMediosOrchestrationCache(Cache, FilterYear, FilterSalespersonCode, FilterCustomerNo) then begin
            Cache.Init();
            Cache.Albaran := format(FilterYear);
            Cache."Salesperson Code" := FilterSalespersonCode;
            Cache."Proveedor" := FilterCustomerNo;
            Cache.Insert(true);
        end;
    end;

    local procedure GetPanelMediosOrchestrationCache(var Cache: Record "Calculo Albaranes"; FilterYear: Integer; FilterSalespersonCode: Code[20]; FilterCustomerNo: Code[20]): Boolean
    begin
        Cache.Reset();
        Cache.SetRange(Albaran, Format(FilterYear));
        Cache.SetRange("Salesperson Code", FilterSalespersonCode);
        Cache.SetRange("Proveedor", FilterCustomerNo);
        exit(Cache.FindFirst());
    end;

    local procedure SavePanelMediosFactToCustomer(
        CustomerNo: Code[20]; FilterYear: Integer;
        PctFacturado: Decimal; PctPendiente: Decimal; PctFacturadoPrev: Decimal; PctPendientePrev: Decimal;
        ContratosCount: Integer; BillingCutoffText: Text[120]; LastUpdated: DateTime)
    var
        Customer: Record Customer;
    begin
        if not Customer.Get(CustomerNo) then
            exit;

        Customer."Pct. Facturado" := PctFacturado;
        Customer."Pct. Pendiente" := PctPendiente;
        Customer."Pct. Facturado Año Ant." := PctFacturadoPrev;
        Customer."Pct. Pendiente Año Ant." := PctPendientePrev;
        Customer."Contratos Count" := ContratosCount;
        Customer."Billing Cutoff Text" := CopyStr(BillingCutoffText, 1, MaxStrLen(Customer."Billing Cutoff Text"));
        Customer."Panel Medios Fact. Año" := FilterYear;
        Customer."Last Updated" := LastUpdated;
        Customer.Modify(true);
    end;

    local procedure SavePanelMediosFactToSalesperson(
        SalespersonCode: Code[20]; FilterYear: Integer;
        PctFacturado: Decimal; PctPendiente: Decimal; PctFacturadoPrev: Decimal; PctPendientePrev: Decimal;
        ContratosCount: Integer; BillingCutoffText: Text[120]; LastUpdated: DateTime)
    var
        SalespersonPurchaser: Record "Salesperson/Purchaser";
    begin
        if not SalespersonPurchaser.Get(SalespersonCode) then
            exit;

        SalespersonPurchaser."Pct. Facturado" := PctFacturado;
        SalespersonPurchaser."Pct. Pendiente" := PctPendiente;
        SalespersonPurchaser."Pct. Facturado Año Ant." := PctFacturadoPrev;
        SalespersonPurchaser."Pct. Pendiente Año Ant." := PctPendientePrev;
        SalespersonPurchaser."Contratos Count" := ContratosCount;
        SalespersonPurchaser."Billing Cutoff Text" := CopyStr(BillingCutoffText, 1, MaxStrLen(SalespersonPurchaser."Billing Cutoff Text"));
        SalespersonPurchaser."Panel Medios Fact. Año" := FilterYear;
        SalespersonPurchaser."Last Updated" := LastUpdated;
        SalespersonPurchaser.Modify(true);
    end;

    local procedure TryLoadPanelMediosFactData(
        FilterYear: Integer; FilterSalespersonCode: Code[20]; FilterCustomerNo: Code[20];
        var PctFacturado: Decimal; var PctPendiente: Decimal; var PctFacturadoPrev: Decimal; var PctPendientePrev: Decimal;
        var ContratosCount: Integer; var BillingCutoffText: Text[120]; var LastUpdated: DateTime): Boolean
    begin
        if FilterCustomerNo <> '' then
            exit(TryLoadPanelMediosFactFromCustomer(FilterCustomerNo, FilterYear, PctFacturado, PctPendiente, PctFacturadoPrev, PctPendientePrev, ContratosCount, BillingCutoffText, LastUpdated));
        if FilterSalespersonCode <> '' then
            exit(TryLoadPanelMediosFactFromSalesperson(FilterSalespersonCode, FilterYear, PctFacturado, PctPendiente, PctFacturadoPrev, PctPendientePrev, ContratosCount, BillingCutoffText, LastUpdated));
        exit(TryLoadPanelMediosFactFromCalculo(FilterYear, PctFacturado, PctPendiente, PctFacturadoPrev, PctPendientePrev, ContratosCount, BillingCutoffText, LastUpdated));
    end;

    local procedure TryLoadPanelMediosFactFromCustomer(
        CustomerNo: Code[20]; FilterYear: Integer;
        var PctFacturado: Decimal; var PctPendiente: Decimal; var PctFacturadoPrev: Decimal; var PctPendientePrev: Decimal;
        var ContratosCount: Integer; var BillingCutoffText: Text[120]; var LastUpdated: DateTime): Boolean
    var
        Customer: Record Customer;
    begin
        if not Customer.Get(CustomerNo) then
            exit(false);
        if (Customer."Panel Medios Fact. Año" <> FilterYear) or (Customer."Last Updated" = 0DT) then
            exit(false);

        PctFacturado := Customer."Pct. Facturado";
        PctPendiente := Customer."Pct. Pendiente";
        PctFacturadoPrev := Customer."Pct. Facturado Año Ant.";
        PctPendientePrev := Customer."Pct. Pendiente Año Ant.";
        ContratosCount := Customer."Contratos Count";
        BillingCutoffText := Customer."Billing Cutoff Text";
        LastUpdated := Customer."Last Updated";
        exit(true);
    end;

    local procedure TryLoadPanelMediosFactFromSalesperson(
        SalespersonCode: Code[20]; FilterYear: Integer;
        var PctFacturado: Decimal; var PctPendiente: Decimal; var PctFacturadoPrev: Decimal; var PctPendientePrev: Decimal;
        var ContratosCount: Integer; var BillingCutoffText: Text[120]; var LastUpdated: DateTime): Boolean
    var
        SalespersonPurchaser: Record "Salesperson/Purchaser";
    begin
        if not SalespersonPurchaser.Get(SalespersonCode) then
            exit(false);
        if (SalespersonPurchaser."Panel Medios Fact. Año" <> FilterYear) or (SalespersonPurchaser."Last Updated" = 0DT) then
            exit(false);

        PctFacturado := SalespersonPurchaser."Pct. Facturado";
        PctPendiente := SalespersonPurchaser."Pct. Pendiente";
        PctFacturadoPrev := SalespersonPurchaser."Pct. Facturado Año Ant.";
        PctPendientePrev := SalespersonPurchaser."Pct. Pendiente Año Ant.";
        ContratosCount := SalespersonPurchaser."Contratos Count";
        BillingCutoffText := SalespersonPurchaser."Billing Cutoff Text";
        LastUpdated := SalespersonPurchaser."Last Updated";
        exit(true);
    end;

    local procedure TryLoadPanelMediosFactFromCalculo(
        FilterYear: Integer;
        var PctFacturado: Decimal; var PctPendiente: Decimal; var PctFacturadoPrev: Decimal; var PctPendientePrev: Decimal;
        var ContratosCount: Integer; var BillingCutoffText: Text[120]; var LastUpdated: DateTime): Boolean
    var
        Cache: Record "Calculo Albaranes";
    begin
        if not GetPanelMediosOrchestrationCache(Cache, FilterYear, '', '') then
            exit(false);
        if Cache.Status <> Cache.Status::Calculado then
            exit(false);
        if Cache."Last Updated" = 0DT then
            exit(false);

        PctFacturado := Cache."Pct. Facturado";
        PctPendiente := Cache."Pct. Pendiente";
        PctFacturadoPrev := Cache."Pct. Facturado Año Ant.";
        PctPendientePrev := Cache."Pct. Pendiente Año Ant.";
        ContratosCount := Cache."Contratos Count";
        BillingCutoffText := Cache."Billing Cutoff Text";
        LastUpdated := Cache."Last Updated";
        exit(true);
    end;

    local procedure GetPanelMediosFactLastUpdated(FilterYear: Integer; FilterSalespersonCode: Code[20]; FilterCustomerNo: Code[20]; var LastUpdated: DateTime): Boolean
    var
        PctFacturado: Decimal;
        PctPendiente: Decimal;
        PctFacturadoPrev: Decimal;
        PctPendientePrev: Decimal;
        ContratosCount: Integer;
        BillingCutoffText: Text[120];
    begin
        exit(TryLoadPanelMediosFactData(
            FilterYear, FilterSalespersonCode, FilterCustomerNo,
            PctFacturado, PctPendiente, PctFacturadoPrev, PctPendientePrev,
            ContratosCount, BillingCutoffText, LastUpdated));
    end;

    local procedure BuildMediosJobParameter(FilterYear: Integer; FilterSalespersonCode: Code[20]; FilterCustomerNo: Code[20]): Text[250]
    begin
        exit(StrSubstNo('MEDIOS;%1;%2;%3', FilterYear, FilterSalespersonCode, FilterCustomerNo));
    end;

    local procedure ParseMediosJobParameter(ParameterString: Text; var FilterYear: Integer; var FilterSalespersonCode: text[20]; var FilterCustomerNo: text[20]): Boolean
    var
        Parts: List of [Text];
        YearText: Text;
    begin
        if ParameterString = '' then
            exit(false);
        Parts := ParameterString.Split(';');
        if Parts.Count < 4 then
            exit(false);
        if Parts.Get(1) <> 'MEDIOS' then
            exit(false);
        Parts.Get(2, YearText);
        Evaluate(FilterYear, YearText);
        Parts.Get(3, FilterSalespersonCode);
        Parts.Get(4, FilterCustomerNo);
        exit(FilterYear <> 0);
    end;
}