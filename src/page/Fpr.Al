page 50057 "Saldo Proveedores FPR"
{
    SourceTable = 23;
    UsageCategory = Tasks;
    ApplicationArea = All;
    PageType = List;

    layout
    {
        area(Content)
        {
            repeater(Detalle)
            {
                field("No."; Rec."No.") { ApplicationArea = All; }
                field(Name; Rec.Name) { ApplicationArea = All; }
                field("Saldo Contable"; -r23T.SaldoConD)
                {
                    ApplicationArea = All;
                    trigger OnDrillDown()
                    VAR
                        r17: Record "G/L Entry";
                        rGrp: Record "Vendor Posting Group";
                        r15: Record 15;
                        r312: Record "Purchases & Payables Setup";
                        rPrev: Record "Periodos pago emplazamientos";
                        Import: Decimal;
                        rInf: Record "Company Information";
                    BEGIN
                        r312.GET;
                        r17.CLEARMARKS;
                        r17.SETCURRENTKEY("Source Type", "Source No.", "G/L Account No.");
                        r17.SETRANGE("Source Type", r17."Source Type"::Vendor);
                        r17.SETRANGE(r17."Source No.", Rec."No.");
                        if NOT rGrp.GET(Rec."Vendor Posting Group") THEN
                            rGrp.INIT;
                        if rGrp.FINDFIRST THEN
                            REPEAT
                                if r15.GET(rGrp.FPR) THEN BEGIN
                                    rPrev.SETRANGE(rPrev."Cuenta Contable FPR", r15."No.");
                                    if (r312."Cuenta FPR Emplz." <> r15."No.") AND (NOT rPrev.FINDFIRST) THEN begin
                                        if CompanyName = 'Malla Publicidad' Then begin
                                            if COPYSTR(r17."G/L Account No.", 1, 4) <> '4109' THEN r15.Mark := true;
                                        end else
                                            r15.MARK := TRUE;
                                    end;
                                END;

                            UNTIL rGrp.NEXT = 0;
                        r15.MARKEDONLY := TRUE;
                        Import := 0;
                        rInf.ChangeCompany(rEmp.Name);
                        rInf.Get();
                        if r15.FINDFIRST THEN
                            REPEAT
                                r17.SETRANGE(r17."G/L Account No.", r15."No.");
                                if r17.FINDFIRST THEN
                                    REPEAT
                                        if r17."Posting Date" >= rInf."Fecha Inicio FPR" THEN BEGIN
                                            r17.MARK := TRUE;
                                            //  if r17."Reason Code"='' THEN
                                            Import := Import + r17.Amount;
                                        END;
                                    UNTIL r17.NEXT = 0;
                            UNTIL r15.NEXT = 0;
                        r17.MARKEDONLY := TRUE;
                        //r17.SETFILTER("Reason Code",'%1','');
                        r17.SETRANGE(r17."G/L Account No.");
                        //if Import<>SaldoConD THEN r17.SETRANGE("Reason Code");
                        Page.RUNMODAL(0, r17);
                    END;
                }
                field(Albaranes; r23T.Total2)
                {
                    ApplicationArea = All;
                    trigger OnDrillDown()
                    VAR
                        r120: Record "Purch. Rcpt. Header";
                    BEGIN
                        r120.SETFILTER("Reason Code", '%1', '');
                        r120.SETRANGE(r120."Pay-to Vendor No.", Rec."No.");
                        Page.RUNMODAL(0, r120);
                    END;
                }
                field(Devoluciones; r23T.Albaranes2D)
                {
                    ApplicationArea = All;
                    trigger OnDrillDown()
                    VAR
                        r120: Record 6650;
                    BEGIN
                        r120.SETFILTER("Reason Code", '%1', '');
                        r120.SETRANGE(r120."Pay-to Vendor No.", Rec."No.");
                        Page.RUNMODAL(0, r120);
                    END;
                }
                field("Asientos Proveedor"; r23T.Albaranes3D)
                {
                    ApplicationArea = All;
                    trigger OnDrillDown()
                    VAR
                        r17: Record "G/L Entry";
                        r120: Record "Purch. Rcpt. Header";
                    BEGIN
                        r17.CLEARMARKS;
                        r120.SETRANGE(r120."Pay-to Vendor No.", Rec."No.");
                        if r120.FINDFIRST THEN
                            REPEAT
                                r17.SETCURRENTKEY(r17."Document No.");
                                r17.SETRANGE(r17."Document No.", r120."No.");
                                if r17.FINDFIRST THEN
                                    REPEAT
                                        if COPYSTR(r17."G/L Account No.", 1, 4) = '4100' THEN r17.MARK := TRUE;
                                        if COPYSTR(r17."G/L Account No.", 1, 4) = '4030' THEN r17.MARK := TRUE;
                                        if COPYSTR(r17."G/L Account No.", 1, 4) = '4000' THEN r17.MARK := TRUE;
                                    UNTIL r17.NEXT = 0;
                            UNTIL r120.NEXT = 0;
                        r17.MARKEDONLY := TRUE;
                        Page.RUNMODAL(0, r17);
                    END;
                }
                Field(Diferncias; (-r23T.SaldoConD) - (r23T.Total2 - r23T.Albaranes2D))
                {
                    ApplicationArea = all;
                    Style = AttentionAccent;
                    StyleExpr = Negrita;
                }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action("Liquida Proveedores Marcados")
            {
                ApplicationArea = All;
                Image = ApplyEntries;
                trigger OnAction()
                Var

                    alb: Integer;
                    Pas: Boolean;
                    r121: Record "Purch. Rcpt. Line";
                    r120: Record "Purch. Rcpt. Header";
                    rDev: Record 6650;
                    r17: Record "G/L Entry";
                    b: Integer;
                    rInf: Record "Company Information";
                BEGIN
                    rEmp.GET(COMPANYNAME);
                    r120.RESET;
                    rDev.RESET;
                    rInf.ChangeCompany(rEmp.Name);
                    rInf.Get();
                    if rInf."Fecha Inicio FPR" = 0D THEN rInf."Fecha Inicio FPR" := 19000101D;
                    Rec.CLEARMARKS;
                    Ventana.OPEN('Procesando Proveedor ############1# de ############2#\' +
                                'Nombre ############################################3#\' +
                                'Solo Diferencias ######4#\' +
                                '#################5# ################6# de #############7#');
                    //Ventana.INPUT(4,SoloDif);
                    CurrPage.SETSELECTIONFILTER(r23);
                    Ventana.UPDATE(2, r23.COUNT);
                    //r23.SETRANGE(r23."No.","No.");
                    b := 0;
                    if r23.FINDFIRST THEN
                        REPEAT
                            b := b + 1;
                            Ventana.UPDATE(1, b);
                            Ventana.UPDATE(3, r23.Name);
                            SaldoCon2(r23."No.");
                            r120.SETCURRENTKEY(r120."Pay-to Vendor No.");
                            r120.SETRANGE(r120."Pay-to Vendor No.", r23."No.");
                            Ventana.UPDATE(5, 'Albaranes');
                            Ventana.UPDATE(7, r120.COUNT);
                            if r120.FINDFIRST THEN
                                REPEAT
                                    Total2 := 0;
                                    alb := alb + 1;
                                    Ventana.UPDATE(6, alb);
                                    Pas := Pasada(r120);
                                    CLEAR(eContabilizado);
                                    CLEAR(eFacturado);
                                    r121.SETRANGE(r121."Document No.", r120."No.");
                                    if r121.FINDFIRST THEN
                                        REPEAT
                                            if Pas THEN
                                                eFacturado := eFacturado + r121."Quantity Invoiced" * r121."Direct Unit Cost"
                                                * (1 - r121."Line Discount %" / 100);
                                        UNTIL r121.NEXT = 0;
                                    r17.RESET;
                                    r17.SETCURRENTKEY(r17."G/L Account No.", r17."Document No.");
                                    r17.SETRANGE(r17."Document No.", r120."No.");
                                    r17.SETRANGE("G/L Account No.", '6', '7');
                                    if r17.FINDFIRST THEN BEGIN
                                        r17.CALCSUMS(r17.Amount);
                                        eContabilizado := eContabilizado + r17.Amount;
                                    END;
                                    r17.SETRANGE("G/L Account No.", '47', '48');
                                    if r17.FINDFIRST THEN BEGIN
                                        r17.CALCSUMS(r17.Amount);
                                        eContabilizado := eContabilizado + r17.Amount;
                                    END;
                                    if ROUND(eFacturado, 1, '=') = ROUND(eContabilizado, 1, '=') THEN BEGIN
                                        r120."Reason Code" := FORMAT(WORKDATE);
                                        if eContabilizado <> 0 THEN
                                            r120.MODIFY;
                                    END ELSE BEGIN
                                        r17.SETCURRENTKEY(r17."G/L Account No.", r17."Document No.");
                                        r17.SETRANGE(r17."Document No.", r120."No.");
                                        r17.SETRANGE("G/L Account No.", '4', '5');
                                        if r17.FINDFIRST THEN r17.MODIFYALL("Reason Code", '');
                                        r17.SETCURRENTKEY(r17."G/L Account No.", r17."Document No.");
                                        r17.SETRANGE(r17."Document No.");
                                        r17.SETRANGE("Tax Area Code", r120."No.");
                                        r17.SETRANGE("G/L Account No.", '4', '5');
                                        if r17.FINDFIRST THEN r17.MODIFYALL("Reason Code", '');

                                    END;
                                UNTIL r120.NEXT = 0;
                            rDev.SETCURRENTKEY(rDev."Pay-to Vendor No.");
                            rDev.SETRANGE(rDev."Pay-to Vendor No.", r23."No.");
                            Ventana.UPDATE(5, 'Devoluciones');
                            Ventana.UPDATE(7, rDev.COUNT);
                            alb := 0;
                            if rDev.FINDFIRST THEN
                                REPEAT
                                    alb := alb + 1;
                                    Ventana.UPDATE(6, alb);
                                    if (eContabilizadoD(rDev) = eFacturadoD(rDev)) THEN BEGIN
                                        rDev."Reason Code" := FORMAT(WORKDATE);
                                        rDev.MODIFY;
                                    END ELSE BEGIN
                                        r17.SETCURRENTKEY(r17."G/L Account No.", r17."Document No.");
                                        r17.SETRANGE(r17."Document No.", rDev."No.");
                                        r17.SETRANGE("G/L Account No.", '4', '5');
                                        if r17.FINDFIRST THEN r17.MODIFYALL("Reason Code", '');
                                        r17.SETCURRENTKEY(r17."G/L Account No.", r17."Document No.");
                                        r17.SETRANGE(r17."Document No.");
                                        r17.SETRANGE("Tax Area Code", rDev."No.");
                                        r17.SETRANGE("G/L Account No.", '4', '5');
                                        if r17.FINDFIRST THEN r17.MODIFYALL("Reason Code", '');

                                    END;
                                UNTIL rDev.NEXT = 0;
                        UNTIL r23.NEXT = 0;
                    Ventana.CLOSE;
                END;
            }
            action(Recalcula)
            {
                ApplicationArea = all;
                Scope = Repeater;
                Image = Calculate;
                trigger OnAction()
                Var
                    // r121: Record "Purch. Rcpt. Line";
                    // Pas: Boolean;
                    // r17: Record "G/L Entry";
                    // aLB: Integer;
                    // r17t: Record "G/L Entry" TEMPORARY;
                    // rInf: Record "Company Information";
                    // Num: Integer;
                    // r120: Record "Purch. Rcpt. Header";
                    // rDev: Record 6650;
                    Control: Codeunit Fpr;
                    r121: Record "Purch. Rcpt. Line";
                    Pas: Boolean;
                    r17: Record "G/L Entry";
                    aLB: Integer;
                    r17t: Record "G/L Entry" TEMPORARY;
                    rInf: Record "Company Information";
                    Num: Integer;
                BEGIN
                    Control.CalcularFpr(Rec);
                    // rEmp.GET(COMPANYNAME);
                    // rInf.ChangeCompany(rEmp.Name);
                    // rInf.Get();
                    // SoloDif := Confirm('¿Solo Diferencias?', false);
                    // if rInf."Fecha Inicio FPR" = 0D THEN rInf."Fecha Inicio FPR" := 19000101D;
                    // Ventana.OPEN('Procesando Proveedor ############1# de ############2#\' +
                    //             'Nombre ############################################3#\' +
                    //             'Solo Diferencias ######4#\' +
                    //             '#################5# ################6# de #############7#');
                    // Ventana.Update(4, SoloDif);
                    // r23.SETRANGE(r23."No.", "No.");
                    // Ventana.UPDATE(2, r23.COUNT);
                    // if r23.FINDFIRST THEN
                    //     REPEAT
                    //         //a:=a+1;

                    //         Ventana.UPDATE(3, r23.Name);
                    //         r23T.GET(r23."No.");
                    //         a := r23T.Priority;
                    //         r23T.Total2 := 0;
                    //         r23T.Total3 := 0;
                    //         r23T.Total4 := 0;
                    //         r23T.Albaranes2D := 0;
                    //         r23T.SaldoConD := 0;
                    //         Ventana.UPDATE(1, a);
                    //         // r23T.INSERT;
                    //         //Pruebas
                    //         //if a<25 THEN BEGIN
                    //         r23T.SaldoConD := r23T.SaldoConD + SaldoCon(r23."No.");
                    //         // AlbaranesD:=AlbaranesD+Albaranes(r23."No.");
                    //         // Albaranes2D:=Albaranes2D+Albaranes2(r23."No.");
                    //         // Albaranes3D:=Albaranes3D+Albaranes3(r23."No.");
                    //         r120.SETCURRENTKEY(r120."Pay-to Vendor No.");
                    //         r120.SETRANGE(r120."Pay-to Vendor No.", r23."No.");
                    //         r120.SETFILTER("Reason Code", '%1', '');
                    //         Ventana.UPDATE(5, 'Albaranes');
                    //         Ventana.UPDATE(7, r120.COUNT);
                    //         if r120.FINDFIRST THEN
                    //             REPEAT
                    //                 Total2 := 0;
                    //                 aLB := aLB + 1;
                    //                 Ventana.UPDATE(6, aLB);
                    //                 Pas := Pasada(r120);
                    //                 CLEAR(eContabilizado);
                    //                 CLEAR(eFacturado);
                    //                 r121.SETRANGE(r121."Document No.", r120."No.");
                    //                 if r121.FINDFIRST THEN
                    //                     REPEAT
                    //                         // Total[1,r23T.Priority]:=Total[1,r23T.Priority]+(r121.Quantity*r121."Direct Unit Cost"*(1-r121."Line Discount %"/100));
                    //                         Total2 := Total2 + ((r121.Quantity - r121."Quantity Invoiced")
                    //                         * r121."Direct Unit Cost" * (1 - r121."Line Discount %" / 100));
                    //                         if Pas THEN
                    //                             eFacturado := eFacturado + r121."Quantity Invoiced" * r121."Direct Unit Cost"
                    //                             * (1 - r121."Line Discount %" / 100);
                    //                     UNTIL r121.NEXT = 0;
                    //                 r17.SETCURRENTKEY(r17."G/L Account No.", r17."Document No.");
                    //                 r17.SETRANGE(r17."Document No.", r120."No.");
                    //                 r17.SETRANGE("G/L Account No.", '6', '7');
                    //                 if r17.FINDFIRST THEN BEGIN
                    //                     r17.CALCSUMS(r17.Amount);
                    //                     eContabilizado := eContabilizado + r17.Amount;
                    //                 END;
                    //                 r17.SETRANGE("G/L Account No.", '47', '48');
                    //                 if r17.FINDFIRST THEN BEGIN
                    //                     r17.CALCSUMS(r17.Amount);
                    //                     eContabilizado := eContabilizado + r17.Amount;
                    //                 END;
                    //                 if (ABS(eContabilizado) < ABS(Total2)) AND (eContabilizado >= 0) THEN Total2 := eContabilizado;
                    //                 if r120.Contabilizado = FALSE THEN Total2 := 0;
                    //                 r23T.Total2 := r23T.Total2 + Total2;
                    //                 r23T.Total3 := r23T.Total3 + eContabilizado;
                    //                 r23T.Total4 := r23T.Total4 + eFacturado;
                    //                 // Insertamos albaranes con totales calculados
                    //                 Num := Num + 1;
                    //                 r17t."Entry No." := Num;
                    //                 r17t."Debit Amount" := Total2;
                    //                 r17t."Credit Amount" := eContabilizado;
                    //                 r17t.Amount := eFacturado;
                    //                 r17t."Document No." := r120."No.";
                    //                 r17t."G/L Account No." := r23."No.";
                    //                 r17t.INSERT;

                    //             //
                    //             UNTIL r120.NEXT = 0;
                    //         rDev.SETCURRENTKEY(rDev."Pay-to Vendor No.");
                    //         rDev.SETRANGE(rDev."Pay-to Vendor No.", r23."No.");
                    //         rDev.SETFILTER("Reason Code", '%1', '');
                    //         Ventana.UPDATE(5, 'Devoluciones');
                    //         Ventana.UPDATE(7, rDev.COUNT);
                    //         aLB := 0;
                    //         if rDev.FINDFIRST THEN
                    //             REPEAT
                    //                 aLB := aLB + 1;
                    //                 Ventana.UPDATE(6, aLB);

                    //                 r23T.Albaranes2D := r23T.Albaranes2D + (eContabilizadoD(rDev) - eFacturadoD(rDev));
                    //             UNTIL rDev.NEXT = 0;
                    //         if SoloDif THEN BEGIN
                    //             Rec.GET(r23."No.");
                    //             if ROUND(ABS(r23T.SaldoConD
                    //             + r23T.Total2 + r23T.Albaranes2D + r23T.Albaranes3D), 1, '=') > 5 THEN
                    //                 MARK := TRUE;
                    //         END;
                    //     //END;
                    //     UNTIL r23.NEXT = 0;
                    // Ventana.CLOSE;
                    // if SoloDif THEN MARKEDONLY := TRUE;
                    // Page.RunMODAL(0, r17t);
                END;
            }
            action("Recalcula Todos")
            {
                ApplicationArea = all;
                Scope = Repeater;
                Image = Calculate;
                trigger OnAction()
                Var
                    Control: Codeunit Fpr;
                    r121: Record "Purch. Rcpt. Line";
                    Pas: Boolean;
                    r17: Record "G/L Entry";
                    aLB: Integer;
                    r17t: Record "G/L Entry" TEMPORARY;
                    rInf: Record "Company Information";
                    Num: Integer;
                    Comandos: Record Comandos;
                BEGIN
                    Control.CalcularFpr();
                    if rInf.Get() Then begin
                        rInf.Calcular := 'FPR';
                        rinf.Modify();
                    end;
                    Comandos.Init();
                    Comandos.Id := CreateGuid();
                    Comandos."User ID" := UserId;
                    Comandos.Empresa := CompanyName;
                    Comandos.Fecha := CurrentDateTime;
                    Comandos.Procesado := false;
                    Comandos.Comando := 'FPR';
                    Comandos.Insert;
                END;

            }
            action("Quitar Todas las marcas")
            {
                ApplicationArea = all;
                Scope = Repeater;
                Image = ClearFilter;
                trigger OnAction()
                Var
                    alb: Integer;
                    Pas: Boolean;
                    r121: Record "Purch. Rcpt. Line";
                    r17: Record "G/L Entry";
                    r120: Record "Purch. Rcpt. Header";
                    rDev: Record 6650;
                    b: Integer;
                    rInf: Record "Company Information";
                BEGIN
                    rEmp.GET(COMPANYNAME);
                    rInf.ChangeCompany(rEmp.Name);
                    rInf.Get();
                    r120.RESET;
                    rDev.RESET;
                    if rInf."Fecha Inicio FPR" = 0D THEN rInf."Fecha Inicio FPR" := 19000101D;
                    Rec.CLEARMARKS;
                    Ventana.OPEN('Procesando Proveedor ############1# de ############2#\' +
                                'Nombre ############################################3#\' +
                                'Solo Diferencias ######4#\' +
                                '#################5# ################6# de #############7#');
                    //Ventana.INPUT(4,SoloDif);
                    CurrPage.SETSELECTIONFILTER(r23);
                    Ventana.UPDATE(2, r23.COUNT);
                    //r23.SETRANGE(r23."No.","No.");
                    b := 0;
                    if r23.FINDFIRST THEN
                        REPEAT
                            b := b + 1;
                            Ventana.UPDATE(1, b);
                            Ventana.UPDATE(3, r23.Name);
                            SaldoCon3(r23."No.");
                            r120.SETCURRENTKEY(r120."Pay-to Vendor No.");
                            r120.SETRANGE(r120."Pay-to Vendor No.", r23."No.");
                            Ventana.UPDATE(5, 'Albaranes');
                            Ventana.UPDATE(7, r120.COUNT);
                            if r120.FINDFIRST THEN
                                REPEAT
                                    r120."Reason Code" := '';
                                    r120.MODIFY;
                                UNTIL r120.NEXT = 0;
                            rDev.SETCURRENTKEY(rDev."Pay-to Vendor No.");
                            rDev.SETRANGE(rDev."Pay-to Vendor No.", r23."No.");
                            Ventana.UPDATE(5, 'Devoluciones');
                            Ventana.UPDATE(7, rDev.COUNT);
                            alb := 0;
                            if rDev.FINDFIRST THEN
                                REPEAT
                                    alb := alb + 1;
                                    Ventana.UPDATE(6, alb);
                                    rDev."Reason Code" := '';
                                    rDev.MODIFY;
                                UNTIL rDev.NEXT = 0;
                        UNTIL r23.NEXT = 0;
                    Ventana.CLOSE;
                END;
            }
            action("Albaranes a Fecha")
            {
                ApplicationArea = all;
                Scope = Repeater;
                Image = Receipt;

                trigger OnAction()
                Var
                    alb: Integer;
                    Pas: Boolean;
                    r121: Record "Purch. Rcpt. Line";
                    r17: Record "G/L Entry";
                    b: Integer;
                    Fecha: Date;
                    r312: Record "Purchases & Payables Setup";
                    rGrp: Record "Vendor Posting Group";
                    r15: Record 15;
                    rPrev: Record "Periodos pago emplazamientos";
                    rInf: Record "Company Information";
                    DielogoFechas: Page "Date-Time Dialog";
                    r120: Record "Purch. Rcpt. Header";
                    rDev: Record 6650;

                BEGIN
                    rEmp.GET(COMPANYNAME);
                    r120.RESET;
                    rDev.RESET;
                    rInf.ChangeCompany(rEmp.Name);
                    rInf.Get();
                    DielogoFechas.RunModal();
                    Fecha := DielogoFechas.GetDate();
                    if rInf."Fecha Inicio FPR" = 0D THEN rInf."Fecha Inicio FPR" := 19000101D;
                    Rec.CLEARMARKS;
                    Ventana.OPEN('Procesando Proveedor ############1# de ############2#\' +
                                'Nombre ############################################3#\' +
                                'Fecha Cuadre ########4#\' +
                                '#################5# ################6# de #############7#');
                    Ventana.Update(4, Fecha);
                    r23.RESET;
                    //CurrForm.SETSELECTIONFILTER(r23);
                    Ventana.UPDATE(2, r23.COUNT);
                    //r23.SETRANGE(r23."No.","No.");
                    b := 0;
                    if r23.FINDFIRST THEN
                        REPEAT
                            b := b + 1;
                            Ventana.UPDATE(1, b);
                            Ventana.UPDATE(3, r23.Name);
                            // r120.SETRANGE(r120."Reason Code",'<>%1','');
                            r120.SETCURRENTKEY(r120."Pay-to Vendor No.");
                            r120.SETRANGE(r120."Pay-to Vendor No.", r23."No.");
                            Ventana.UPDATE(5, 'Albaranes');
                            Ventana.UPDATE(7, r120.COUNT);
                            if r120.FINDFIRST THEN
                                REPEAT
                                    alb := alb + 1;
                                    Ventana.UPDATE(6, alb);

                                    r17.SETCURRENTKEY(r17."G/L Account No.", r17."Document No.");
                                    r17.SETRANGE(r17."Document No.", r120."No.");
                                    r17.SETRANGE("G/L Account No.", '4', '5');
                                    if r17.FINDFIRST THEN
                                        if r17."Posting Date" <= Fecha THEN r120.MARK := TRUE;
                                UNTIL r120.NEXT = 0;
                            //rDev.SETRANGE(rDev."Reason Code",'<>%1','');
                            rDev.SETCURRENTKEY(rDev."Pay-to Vendor No.");
                            rDev.SETRANGE(rDev."Pay-to Vendor No.", r23."No.");
                            Ventana.UPDATE(5, 'Devoluciones');
                            Ventana.UPDATE(7, rDev.COUNT);
                            alb := 0;
                            if rDev.FINDFIRST THEN
                                REPEAT
                                    alb := alb + 1;
                                    Ventana.UPDATE(6, alb);
                                    r17.SETCURRENTKEY(r17."G/L Account No.", r17."Document No.");
                                    r17.SETRANGE(r17."Document No.", rDev."No.");
                                    r17.SETRANGE("G/L Account No.", '4', '5');
                                    if r17.FINDFIRST THEN
                                        if r17."Posting Date" <= Fecha THEN r120.MARK := TRUE;
                                UNTIL rDev.NEXT = 0;
                            r120.SETRANGE(r120."Reason Code");
                            rDev.SETRANGE(rDev."Reason Code");
                            r312.GET;
                            r17.RESET;
                            r17.SETCURRENTKEY("Source Type", "Source No.", "G/L Account No.");
                            r17.SETFILTER(r17."Reason Code", '<>%1', '');
                            r17.SETRANGE("Source Type", r17."Source Type"::Vendor);
                            r17.SETRANGE(r17."Source No.", r23."No.");
                            if NOT rGrp.GET(Rec."Vendor Posting Group") THEN
                                rGrp.INIT;
                            if rGrp.FINDFIRST THEN
                                REPEAT
                                    if r15.GET(rGrp.FPR) THEN BEGIN
                                        rPrev.SETRANGE(rPrev."Cuenta Contable FPR", r15."No.");
                                        if (r312."Cuenta FPR Emplz." <> r15."No.") AND (NOT rPrev.FINDFIRST) THEN
                                            r15.MARK := TRUE;
                                    END;

                                UNTIL rGrp.NEXT = 0;
                            r15.MARKEDONLY := TRUE;
                            if r15.FINDFIRST THEN
                                REPEAT
                                    r17.SETRANGE(r17."G/L Account No.", r15."No.");
                                    if r17.FINDFIRST THEN
                                        REPEAT
                                            if (r17."Posting Date" > Fecha) AND (r17."Tax Area Code" <> '')
                                            AND (r17."Document Type" <> r17."Document Type"::Receipt) THEN BEGIN
                                                if r120.GET(r17."Tax Area Code") AND (r120."Posting Date" <= Fecha) THEN r120.MARK := TRUE;
                                                if rDev.GET(r17."Tax Area Code") AND (rDev."Posting Date" <= Fecha) THEN rDev.MARK := TRUE;
                                            END;
                                        UNTIL r17.NEXT = 0;
                                UNTIL r15.NEXT = 0;

                        UNTIL r23.NEXT = 0;
                    Ventana.CLOSE;
                    r120.SETRANGE(r120."Pay-to Vendor No.");
                    rDev.SETRANGE(rDev."Pay-to Vendor No.");
                    r120.MARKEDONLY := TRUE;
                    rDev.MARKEDONLY := TRUE;
                    Page.RunMODAL(0, r120);
                    Page.RunMODAL(0, rDev);
                END;
            }
            action("Movimientos Pendientes a Fecha")
            {
                ApplicationArea = all;
                Scope = Repeater;
                Image = Entry;
                trigger OnAction()
                Var
                    alb: Integer;
                    Pas: Boolean;
                    r121: Record "Purch. Rcpt. Line";
                    r17: Record "G/L Entry";
                    b: Integer;
                    Fecha: Date;
                    Fecha2: Date;
                    rInf: Record "Company Information";
                    Dialogo: Page "Date-Time Dialog";
                    r120: Record "Purch. Rcpt. Header";
                    rDev: Record 6650;
                    rT17: Record "G/L Entry" temporary;
                BEGIN
                    rEmp.GET(COMPANYNAME);
                    rT17.DELETEALL;
                    r120.RESET;
                    rDev.RESET;
                    rInf.ChangeCompany(rEmp.Name);
                    rInf.Get();
                    Dialogo.RunModal();
                    Fecha := Dialogo.GetDate();
                    if rInf."Fecha Inicio FPR" = 0D THEN rInf."Fecha Inicio FPR" := 19000101D;
                    Rec.CLEARMARKS;
                    Ventana.OPEN('Procesando Proveedor ############1# de ############2#\' +
                                'Nombre ############################################3#\' +
                                'Fecha ######4#\' +
                                '#################5# ################6# de #############7#');
                    Ventana.Update(4, Fecha);
                    //CurrForm.SETSELECTIONFILTER(r23);
                    r23.RESET;
                    Ventana.UPDATE(2, r23.COUNT);
                    //r23.SETRANGE(r23."No.","No.");
                    b := 0;
                    if r23.FINDFIRST THEN
                        REPEAT
                            b := b + 1;
                            Ventana.UPDATE(1, b);
                            Ventana.UPDATE(3, r23.Name);
                            SaldoConaFecha(r23."No.", Fecha);
                            r120.SETCURRENTKEY(r120."Pay-to Vendor No.");
                            r120.SETRANGE(r120."Pay-to Vendor No.", r23."No.");
                            r120.SETRANGE(r120."Posting Date", 0D, Fecha);
                            Ventana.UPDATE(5, 'Albaranes');
                            Ventana.UPDATE(7, r120.COUNT);
                            if r120.FINDFIRST THEN
                                REPEAT
                                    Total2 := 0;
                                    alb := alb + 1;
                                    Ventana.UPDATE(6, alb);
                                    if NOT EVALUATE(Fecha2, r120."Reason Code") THEN Fecha2 := Fecha;
                                    if Fecha2 = 0D THEN Fecha2 := Fecha;
                                    if Fecha2 >= Fecha THEN BEGIN
                                        // {r17.SETCURRENTKEY("G/L Account No.","Document No.","Posting Date","Tax Area Code");
                                        // r17.SETRANGE(r17."G/L Account No.",'4','5');
                                        // r17.SETRANGE(r17."Tax Area Code",r120."No.");
                                        // r17.SETFILTER(r17."Document No.",'<>%1',r120."No.");}

                                        Pas := PasadaFecha(r120, Fecha);
                                        CLEAR(eContabilizado);
                                        CLEAR(eFacturado);
                                        r121.SETRANGE(r121."Document No.", r120."No.");
                                        if r121.FINDFIRST THEN
                                            REPEAT
                                                if Pas THEN
                                                    eFacturado := eFacturado + r121."Quantity Invoiced" * r121."Direct Unit Cost"
                                                    * (1 - r121."Line Discount %" / 100);
                                            UNTIL r121.NEXT = 0;
                                        r17.RESET;
                                        r17.SETCURRENTKEY(r17."G/L Account No.", r17."Document No.");
                                        r17.SETRANGE(r17."Document No.", r120."No.");
                                        r17.SETRANGE("G/L Account No.", '6', '7');
                                        r17.SETRANGE(r17."Posting Date", 0D, Fecha);
                                        if r17.FINDFIRST THEN
                                            REPEAT
                                                //r17.CALCSUMS(r17.Amount);
                                                eContabilizado := eContabilizado + r17.Amount;
                                            UNTIL r17.NEXT = 0;
                                        r17.SETRANGE("G/L Account No.", '47', '48');
                                        if r17.FINDFIRST THEN
                                            REPEAT
                                                //r17.CALCSUMS(r17.Amount);
                                                eContabilizado := eContabilizado + r17.Amount;
                                            UNTIL r17.NEXT = 0;
                                        if ROUND(eFacturado, 1, '=') = ROUND(eContabilizado, 1, '=') THEN BEGIN
                                            rT17.SETCURRENTKEY(rT17."G/L Account No.", rT17."Document No.");
                                            rT17.SETRANGE(rT17."Document No.", r120."No.");
                                            rT17.SETRANGE("G/L Account No.", '4', '5');
                                            rT17.DELETEALL;
                                            rT17.SETCURRENTKEY(rT17."G/L Account No.", rT17."Document No.");
                                            rT17.SETRANGE(rT17."Document No.");
                                            rT17.SETRANGE("Tax Area Code", r120."No.");
                                            rT17.SETRANGE("G/L Account No.", '4', '5');
                                            rT17.DELETEALL;
                                        END;
                                    END;
                                UNTIL r120.NEXT = 0;
                            rDev.SETCURRENTKEY(rDev."Pay-to Vendor No.");
                            rDev.SETRANGE(rDev."Pay-to Vendor No.", r23."No.");
                            rDev.SETRANGE(rDev."Posting Date", 0D, Fecha);
                            Ventana.UPDATE(5, 'Devoluciones');
                            Ventana.UPDATE(7, rDev.COUNT);
                            alb := 0;
                            if rDev.FINDFIRST THEN
                                REPEAT
                                    alb := alb + 1;
                                    Ventana.UPDATE(6, alb);
                                    if NOT EVALUATE(Fecha2, rDev."Reason Code") THEN Fecha2 := Fecha;
                                    if Fecha2 = 0D THEN Fecha2 := Fecha;
                                    if Fecha2 >= Fecha THEN BEGIN

                                        if (eContabilizadoD(rDev) = eFacturadoD(rDev)) THEN BEGIN
                                            rT17.SETCURRENTKEY(rT17."G/L Account No.", rT17."Document No.");
                                            rT17.SETRANGE(rT17."Document No.", rDev."No.");
                                            rT17.SETRANGE("G/L Account No.", '4', '5');
                                            rT17.DELETEALL;
                                            rT17.SETCURRENTKEY(rT17."G/L Account No.", rT17."Document No.");
                                            rT17.SETRANGE(rT17."Document No.");
                                            rT17.SETRANGE("Tax Area Code", rDev."No.");
                                            rT17.SETRANGE("G/L Account No.", '4', '5');
                                            rT17.DELETEALL;
                                            ;

                                        END;
                                    END;
                                UNTIL rDev.NEXT = 0;
                        UNTIL r23.NEXT = 0;
                    Ventana.CLOSE;
                    rT17.RESET;
                    COMMIT;
                    Page.RunMODAL(0, rT17);
                END;
            }
            action("Solo Diferencias")
            {
                Image = CalculatePlanChange;
                ApplicationArea = all;
                Scope = Repeater;
                trigger OnAction()
                var
                begin
                    Rec.ClearMarks();
                    if Rec.FindFirst() Then
                        repeat
                            if Not r23T.Get(Rec."No.") Then r23T.Init();
                            if Round((-r23T.SaldoConD) - (r23T.Total2 - r23T.Albaranes2D), 1, '=') <> 0 Then Rec.Mark(true);
                        until Rec.Next() = 0;
                    Rec.MarkedOnly(true);
                    CurrPage.Update(false);
                end;
            }
        }
    }

    VAR
        Ventana: Dialog;
        SoloDif: Boolean;
        SaldoConD: ARRAY[10000] OF Decimal;
        Total1: ARRAY[4, 10000] OF Decimal;
        Albaranes2D: ARRAY[10000] OF Decimal;
        Albaranes3D: ARRAY[10000] OF Decimal;
        r23: Record Vendor;
        Negrita: Boolean;
        a: Integer;
        r23T: Record Proveedor;
        rEmp: Record 2000000006;
        Total2: Decimal;
        eContabilizado: Decimal;
        eFacturado: Decimal;

    trigger OnOpenPage()
    begin
        SelectLatestVersion();
    END;

    trigger OnAfterGetRecord()
    BEGIN
        if nOT r23T.GET(Rec."No.") THEN r23T.iNIT;
        Negrita := Round((-r23T.SaldoConD) - (r23T.Total2 - r23T.Albaranes2D), 1, '=') <> 0;
    END;

    Procedure Calcular()
    VAR
        Control: Codeunit Fpr;
        r121: Record "Purch. Rcpt. Line";
        Pas: Boolean;
        r17: Record "G/L Entry";
        aLB: Integer;
        rAlb: Record "Purch. Rcpt. Header";
        ef2: Decimal;
        rInf: Record "Company Information";
    BEGIN
        Control.CalcularFpr();
    end;


    PROCEDURE Pasada(VAR r120: Record 120): Boolean;
    VAR
        r123: Record 123;
        r122: Record "Purch. Inv. Header";
        r125: Record 125;
        r25: Record 25;
    BEGIN
        r25.SETCURRENTKEY(r25."Document No.");
        r25.SETRANGE(r25."Document No.", Rec."No.");
        if r25.FINDFIRST THEN EXIT(TRUE);
        r123.SETCURRENTKEY(r123.Description);
        //r123.SETRANGE(r123."Buy-from Vendor No.","Buy-from Vendor No.");
        r123.SETFILTER(r123.Description, '%1', '*' + r120."No." + '*');
        if NOT r123.FINDFIRST THEN BEGIN
            r125.SETCURRENTKEY(r125.Description);
            r125.SETFILTER(r125.Description, '%1', '*' + r120."No." + '*');
            if NOT r125.FINDFIRST THEN EXIT(FALSE);
            EXIT(TRUE);
        END;
        if NOT r122.GET(r123."Document No.") THEN
            EXIT(FALSE);
        EXIT(TRUE);
    END;


    PROCEDURE SaldoCon(Num: Code[20]): Decimal;
    VAR
        r17: Record "G/L Entry";
        rGrp: Record "Vendor Posting Group";
        Importe: Decimal;
        r15: Record 15;
        b: Integer;
        r312: Record "Purchases & Payables Setup";
        rPrev: Record "Periodos pago emplazamientos";
        rInf: Record "Company Information";
    BEGIN
        r312.GET;
        r17.CLEARMARKS;
        r17.SETCURRENTKEY("Source Type", "Source No.", "G/L Account No.");
        r17.SETRANGE("Source Type", r17."Source Type"::Vendor);
        r17.SETRANGE(r17."Source No.", Num);
        //r17.SETFILTER("Reason Code",'%1','');
        if NOT rGrp.GET(Rec."Vendor Posting Group") THEN
            rGrp.INIT;
        if rGrp.FINDFIRST THEN
            REPEAT
                if r15.GET(rGrp.FPR) THEN BEGIN
                    rPrev.SETRANGE(rPrev."Cuenta Contable FPR", r15."No.");
                    if (r312."Cuenta FPR Emplz." <> r15."No.") AND (NOT rPrev.FINDFIRST) THEN
                        r15.MARK := TRUE;
                END;

            UNTIL rGrp.NEXT = 0;
        r15.MARKEDONLY := TRUE;
        rInf.ChangeCompany(rEmp.Name);
        rInf.Get();
        if r15.FINDFIRST THEN
            REPEAT
                r17.SETRANGE(r17."G/L Account No.", r15."No.");
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
            UNTIL r15.NEXT = 0;
        EXIT(Importe);
    END;

    PROCEDURE eContabilizadoD(VAR rDev: Record 6650): Decimal;
    var
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

    PROCEDURE eDescontD(VAR rDev: Record 6650): Decimal;
    VAR
        r121: Record 6651;
        Importe: Decimal;
        r17: Record "G/L Entry";
        r123: Record 125;
        r122: Record "Purch. Cr. Memo Hdr.";
    BEGIN
        r123.SETCURRENTKEY(r123."Buy-from Vendor No.", r123.Description);
        //r123.SETRANGE(r123."Buy-from Vendor No.","Buy-from Vendor No.");
        r123.SETFILTER(r123.Description, '%1', '*' + rDev."No." + '*');
        if r123.FINDFIRST THEN
            REPEAT
                r122.SETRANGE(r122."No.", r123."Document No.");
                if r122.FINDFIRST THEN BEGIN
                    r17.SETCURRENTKEY(r17."Document No.");
                    r17.SETRANGE(r17."Document No.", r122."No.");
                    if r17.FINDFIRST THEN
                        REPEAT
                            if COPYSTR(r17."G/L Account No.", 1, 4) = '4009' THEN Importe := Importe + r17.Amount;
                            if COMPANYNAME <> 'Malla Publicidad' THEN
                                if COPYSTR(r17."G/L Account No.", 1, 4) = '4109' THEN Importe := Importe + r17.Amount;
                        UNTIL r17.NEXT = 0;
                END;
            UNTIL r123.NEXT = 0;
        EXIT(Importe);
    END;

    PROCEDURE SaldoCon2(Num: Code[20]): Decimal;
    VAR
        r17: Record "G/L Entry";
        rGrp: Record "Vendor Posting Group";
        Importe: Decimal;
        r15: Record 15;
        b: Integer;
        r312: Record "Purchases & Payables Setup";
        rPrev: Record "Periodos pago emplazamientos";
        rInf: Record "Company Information";
    BEGIN
        r312.GET;
        r17.CLEARMARKS;
        r17.SETCURRENTKEY("Source Type", "Source No.", "G/L Account No.");
        r17.SETRANGE("Source Type", r17."Source Type"::Vendor);
        r17.SETRANGE(r17."Source No.", Num);
        if NOT rGrp.GET(Rec."Vendor Posting Group") THEN
            rGrp.INIT;
        if rGrp.FINDFIRST THEN
            REPEAT
                if r15.GET(rGrp.FPR) THEN BEGIN
                    rPrev.SETRANGE(rPrev."Cuenta Contable FPR", r15."No.");
                    if (r312."Cuenta FPR Emplz." <> r15."No.") AND (NOT rPrev.FINDFIRST) THEN
                        r15.MARK := TRUE;
                END;

            UNTIL rGrp.NEXT = 0;
        r15.MARKEDONLY := TRUE;
        rInf.ChangeCompany(rEmp.Name);
        rInf.Get();
        if r15.FINDFIRST THEN
            REPEAT
                r17.SETRANGE(r17."G/L Account No.", r15."No.");
                if r17.FINDFIRST THEN
                    REPEAT
                        if r17."Posting Date" >= rInf."Fecha Inicio FPR" THEN BEGIN
                            r17."Reason Code" := FORMAT(WORKDATE);
                            r17.MODIFY;
                        END;
                    UNTIL r17.NEXT = 0;
            UNTIL r15.NEXT = 0;
        EXIT(Importe);
    END;

    PROCEDURE SaldoCon3(Num: Code[20]): Decimal;
    VAR
        r17: Record "G/L Entry";
        rGrp: Record "Vendor Posting Group";
        Importe: Decimal;
        r15: Record 15;
        b: Integer;
        r312: Record "Purchases & Payables Setup";
        rPrev: Record "Periodos pago emplazamientos";
        rInf: Record "Company Information";
    BEGIN
        r312.GET;
        r17.CLEARMARKS;
        r17.SETCURRENTKEY("Source Type", "Source No.", "G/L Account No.");
        r17.SETRANGE("Source Type", r17."Source Type"::Vendor);
        r17.SETRANGE(r17."Source No.", Num);
        if NOT rGrp.GET(Rec."Vendor Posting Group") THEN
            rGrp.INIT;
        if rGrp.FINDFIRST THEN
            REPEAT
                if r15.GET(rGrp.FPR) THEN BEGIN
                    rPrev.SETRANGE(rPrev."Cuenta Contable FPR", r15."No.");
                    if (r312."Cuenta FPR Emplz." <> r15."No.") AND (NOT rPrev.FINDFIRST) THEN
                        r15.MARK := TRUE;
                END;

            UNTIL rGrp.NEXT = 0;
        r15.MARKEDONLY := TRUE;
        rInf.ChangeCompany(rEmp.Name);
        rInf.Get();
        if r15.FINDFIRST THEN
            REPEAT
                r17.SETRANGE(r17."G/L Account No.", r15."No.");
                if r17.FINDFIRST THEN
                    REPEAT
                        if r17."Posting Date" >= rInf."Fecha Inicio FPR" THEN BEGIN
                            r17."Reason Code" := '';
                            r17.MODIFY;
                        END;
                    UNTIL r17.NEXT = 0;
            UNTIL r15.NEXT = 0;
        EXIT(Importe);
    END;

    PROCEDURE SaldoConaFecha(Num: Code[20]; Fecha: Date): Decimal;
    VAR
        r17: Record "G/L Entry";
        rGrp: Record "Vendor Posting Group";
        Importe: Decimal;
        r15: Record 15;
        b: Integer;
        r312: Record "Purchases & Payables Setup";
        rPrev: Record "Periodos pago emplazamientos";
        Fecha2: Date;
        rInf: Record "Company Information";
    BEGIN
        r312.GET;
        r17.CLEARMARKS;
        r17.SETCURRENTKEY("Source Type", "Source No.", "G/L Account No.");
        r17.SETRANGE("Source Type", r17."Source Type"::Vendor);
        r17.SETRANGE(r17."Source No.", Num);
        if NOT rGrp.GET(Rec."Vendor Posting Group") THEN
            rGrp.INIT;
        rGrp.SETRANGE(rGrp.FPR, '400900001');
        if rGrp.FINDFIRST THEN
            REPEAT
                if r15.GET(rGrp.FPR) THEN BEGIN
                    rPrev.SETRANGE(rPrev."Cuenta Contable FPR", r15."No.");
                    if (r312."Cuenta FPR Emplz." <> r15."No.") AND (NOT rPrev.FINDFIRST) THEN
                        r15.MARK := TRUE;
                END;

            UNTIL rGrp.NEXT = 0;
        r15.MARKEDONLY := TRUE;
        rInf.ChangeCompany(rEmp.Name);
        rInf.Get();
        if r15.FINDFIRST THEN
            REPEAT
                r17.SETRANGE(r17."G/L Account No.", r15."No.");
                r17.SETRANGE(r17."Posting Date", 0D, Fecha);
                if r17.FINDFIRST THEN
                    REPEAT
                        if r17."Posting Date" >= rInf."Fecha Inicio FPR" THEN BEGIN
                            //r17."Reason Code":=FORMAT(WORKDATE);
                            //r17.MODIFY;
                            // {   rT17:=r17;
                            //    if NOT EVALUATE(Fecha2,r17."Reason Code") THEN Fecha2:=Fecha;
                            //    if Fecha2=0D THEN Fecha2:=Fecha;
                            //    if Fecha2>=Fecha THEN
                            //     if rT17.INSERT THEN;  }
                            if r17.Eliminaciones = FALSE THEN
                                Importe := Importe + r17.Amount;

                        END;
                    UNTIL r17.NEXT = 0;
            UNTIL r15.NEXT = 0;
        EXIT(Importe);
    END;

    PROCEDURE PasadaFecha(VAR r120: Record "Purch. Rcpt. Header"; Fecha: Date): Boolean;
    VAR
        r123: Record 123;
        r122: Record "Purch. Inv. Header";
        r25: Record 25;
    BEGIN
        r25.SETCURRENTKEY("Vendor No.", "Posting Date", "Document No.");
        r25.SETRANGE(r25."Document No.", rec."No.");
        r25.SETRANGE(r25."Vendor No.", r120."Pay-to Vendor No.");
        r25.SETRANGE(r25."Posting Date", 0D, Fecha);
        if r25.FINDFIRST THEN EXIT(TRUE);

        r123.SETCURRENTKEY(r123."Buy-from Vendor No.", r123.Description);
        //r123.SETRANGE(r123."Buy-from Vendor No.","Buy-from Vendor No.");
        r123.SETFILTER(r123.Description, '%1', '*' + r120."No." + '*');
        if NOT r123.FINDFIRST THEN EXIT(FALSE);
        REPEAT
            if NOT r122.GET(r123."Document No.") THEN
                EXIT(FALSE);
            if r122."Posting Date" > Fecha THEN EXIT(FALSE);
        UNTIL r123.NEXT = 0;
        EXIT(TRUE);
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