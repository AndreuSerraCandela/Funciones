/// <summary>
/// Codeunit Gestion Confirming (ID 50010).
/// </summary>
Codeunit 50010 "Gestion Confirming"
{
    Permissions = TableData 7000002 = m,
                TableData 7000005 = m;

    VAR
        rMovProv: Record 25;
        rConfFact: Record "Lin. relacion pagos";
        Ef: Record 7000002;

    PROCEDURE ClasifEfecs(VAR Efecto: Record 7000002);
    BEGIN
        REPORT.RUNMODAL(REPORT::"Bill Group - Test", TRUE, FALSE, Efecto);
    END;

    PROCEDURE DesclasifEfecs(VAR Efecto: Record 7000002);
    BEGIN
        Efecto.MODIFYALL("Category Code", '');
    END;

    PROCEDURE ClasifEfecsRegis(VAR EfectRegis: Record 7000003);
    BEGIN
        REPORT.RUNMODAL(REPORT::"Payment Order - Test", TRUE, FALSE, EfectRegis);
    END;

    PROCEDURE DeclasifEfecsRegis(VAR EfectRegis: Record 7000003);
    BEGIN
        EfectRegis.MODIFYALL("Category Code", '');
    END;

    PROCEDURE ActualizEstadis(VAR Efec2: Record 7000002; VAR ImpoTotActual: Decimal; VAR MostrarActual: Boolean);
    VAR
        Efecto: Record 7000002;
    BEGIN
        WITH Efecto DO BEGIN
            COPY(Efec2);
            SETCURRENTKEY(Type, "Collection Agent", "Bill Gr./Pmt. Order No.", "Category Code");
            MostrarActual := CALCSUMS("Remaining Amt. (LCY)");
            if MostrarActual THEN
                ImpoTotActual := "Remaining Amt. (LCY)"
            ELSE
                ImpoTotActual := 0;
        END;
    END;

    PROCEDURE NavegarEfecs(VAR Efecto: Record 7000002);
    VAR
        Navegar: Page 344;
        MovProveedor: Record 25;
        MovCliente: Record 21;
    BEGIN
        WITH Efecto DO BEGIN
            CASE Type OF
                Type::Receivable:
                    BEGIN
                        if NOT MovCliente.GET("Entry No.") THEN
                            EXIT;
                        Navegar.SetDoc(MovCliente."Posting Date", "Document No.");
                    END;
                Type::Payable:
                    BEGIN
                        if NOT MovProveedor.GET("Entry No.") THEN
                            EXIT;
                        Navegar.SetDoc(MovProveedor."Posting Date", "Document No.");
                    END;
            END;
            Navegar.RUN;
        END;
    END;

    PROCEDURE NavegarEfeRegis(VAR EfectRegis: Record 7000003);
    VAR
        Navegar: Page 344;
        MovProveedor: Record 25;
        MovCliente: Record 21;
    BEGIN
        WITH EfectRegis DO BEGIN
            if NOT MovCliente.GET("Entry No.") THEN
                EXIT;
            Navegar.SetDoc(MovCliente."Posting Date", "Document No.");
            Navegar.RUN;
        END;
    END;

    PROCEDURE NavegarEfeCerrado(VAR EfecCerrad: Record 7000004);
    VAR
        Navegar: Page 344;
        MovProveedor: Record 25;
        MovCliente: Record 21;
    BEGIN
        WITH EfecCerrad DO BEGIN
            CASE Type OF
                Type::Receivable:
                    BEGIN
                        if NOT MovCliente.GET("Entry No.") THEN
                            EXIT;
                        Navegar.SetDoc(MovCliente."Posting Date", "Document No.");
                    END;
                Type::Payable:
                    BEGIN
                        if NOT MovProveedor.GET("Entry No.") THEN
                            EXIT;
                        Navegar.SetDoc(MovProveedor."Posting Date", "Document No.");
                    END;
            END;
            Navegar.RUN;
        END;
    END;

    PROCEDURE InsertEfecs(VAR Efec2: Record 7000002);
    VAR
        Efecto: Record 7000002;
        EfecPrev: Record 7000002;
        CtaBanco: Record 270;
        NoRemesa: Record "Cab. borrador pagare";
        ConfigContable: Record "General Ledger Setup";
        InsertEfecs: Page 7000003;
        TestLimDto: Page 7000037;
        ImporSelect: Decimal;
        CoTipoEntFin: Integer;
        NoGrupo: Code[10];
        NoEntFinan: Code[20];
    BEGIN
        CoTipoEntFin := 1;  //{El confirming siempre sera banco}

        Efec2.FILTERGROUP(2);
        Efec2.SETRANGE("Bill Gr./Pmt. Order No.");
        Efec2.FILTERGROUP(0);
        NoGrupo := Efec2.GETRANGEMIN("Bill Gr./Pmt. Order No.");
        if NOT NoRemesa.GET(NoGrupo) THEN
            ERROR('La remesa no existe.');

        if NoRemesa.Impresa <> false THEN
            if NOT CONFIRM('La remesa ya se ha impreso. ¿Confirma que desea continuar?', FALSE) THEN
                EXIT;

        //WITH Efecto DO BEGIN
        Efecto.RESET;
        Efecto.SETCURRENTKEY(Type, "Collection Agent", "Bill Gr./Pmt. Order No.", "Currency Code", Accepted);
        Efecto.SETRANGE(Type, Efecto.Type::Payable);
        Efecto.SETRANGE("Bill Gr./Pmt. Order No.", '');
        Efecto.SETRANGE("Currency Code", '');
        //Efecto.SETFILTER(Accepted, '<>%1', Efecto.Accepted::No);
        InsertEfecs.SETTABLEVIEW(Efecto);
        InsertEfecs.LOOKUPMODE(TRUE);
        if InsertEfecs.RUNMODAL <> ACTION::LookupOK THEN
            EXIT;
        InsertEfecs.GetSelected(Efecto);

        CLEAR(InsertEfecs);
        if NOT Efecto.FIND('-') THEN
            EXIT;

        if Not NoRemesa.Impresa AND CtaBanco.GET(NoRemesa."Fecha de vto.") THEN BEGIN
            ConfigContable.GET;
            ImporSelect := 0;
            REPEAT
                ImporSelect := ImporSelect + Efecto."Remaining Amt. (LCY)";
            UNTIL Efecto.NEXT = 0;
            NoRemesa.CALCFIELDS("Nombre banco");
            CtaBanco.CALCFIELDS("Posted Receiv. Bills Rmg. Amt.");
            if NoRemesa.Importe + ImporSelect + CtaBanco."Posted Receiv. Bills Rmg. Amt." > CtaBanco."Credit Limit for Discount"
            THEN BEGIN
                TestLimDto.SETRECORD(CtaBanco);
                //TestLimDto.SetValues(NoRemesa."Nombre banco",ImporSelect);
                if TestLimDto.RUNMODAL <> ACTION::Yes THEN
                    ERROR('Se ha interrumpido la transacción para respetar la advertencia.');
                CLEAR(TestLimDto);
            END;
        END;

        Efecto.SETCURRENTKEY(Type, "Entry No.");
        Efecto.FIND('-');
        REPEAT
            Efecto.TESTFIELD("Bill Gr./Pmt. Order No.", '');
            Efecto.TESTFIELD("Currency Code", '');
            Efecto.TESTFIELD(Type, Efecto.Type::Payable);
            if Efecto.Accepted = Efecto.Accepted::No THEN
                Efecto.FIELDERROR(Accepted);
            EfecPrev := Efecto;
            Efecto."Collection Agent" := CoTipoEntFin;
            Efecto."Bill Gr./Pmt. Order No." := NoGrupo;
            Efecto.MODIFY;
            Efecto := EfecPrev;
        UNTIL Efecto.NEXT = 0;

        NoRemesa.Impresa := true;
        NoRemesa.MODIFY;

        //CONF 1.30
        Ef.SETCURRENTKEY(Ef."Collection Agent", Ef."Bill Gr./Pmt. Order No.", Ef."Pendiente liq. conf.");
        Ef.SETRANGE("Collection Agent", Ef."Collection Agent"::Bank);
        Ef.SETRANGE("Bill Gr./Pmt. Order No.", NoRemesa."Cód. pagaré");
        if Ef.FIND('-') THEN
            REPEAT
                if rMovProv.GET(Ef."Entry No.") THEN BEGIN
                    rConfFact.INIT;
                    rConfFact."No. relación pagos" := NoRemesa."Cód. pagaré";
                    rConfFact."Pago-a Nº proveedor" := rMovProv."Vendor No.";
                    rConfFact."Pago a-Nombre" := rMovProv."Document No.";
                    rConfFact."Pago a-Nombre 2" := Ef."No.";
                    rConfFact."Importe IVA incl." := rMovProv.Amount * (-1);
                    //rConfFact."Importe a pagar"   := rMovProv."Remaining Amount" * (-1);
                    rConfFact."Fecha registro" := rMovProv."Posting Date";
                    //rConfFact."Efecto Interno"    := Ef."Document No.";
                    if rConfFact.INSERT THEN
                        MarcasConfirming(rMovProv, NoRemesa."Cód. pagaré", Ef."Document No.");
                END;
            UNTIL Ef.NEXT = 0;
        //Fin CONF
    END;
    // END;

    PROCEDURE EliminEfecs(VAR Efec2: Record 7000002);
    VAR
        NoRemesa: Record "Cab. borrador pagare";
    BEGIN
        //  WITH Efec2 DO
        if Efec2.FIND('-') THEN BEGIN
            NoRemesa.GET(Efec2."Bill Gr./Pmt. Order No.");
            if NoRemesa.Impresa <> false THEN
                if NOT CONFIRM('La remesa ya se ha impreso. ¿Confirma qué desea continuar?', FALSE) THEN
                    EXIT;
            NoRemesa.Impresa := true;
            REPEAT
                // CONF1.30
                rConfFact.SETCURRENTKEY("No. relación pagos");
                rConfFact.SETRANGE("No. relación pagos", Efec2."Bill Gr./Pmt. Order No.");
                //rConfFact.SETRANGE("Efecto Interno",Efec2."Document No.");
                rConfFact.DELETEALL;
                // Fin CONF
                Efec2."Bill Gr./Pmt. Order No." := '';
                Efec2.MODIFY;
            UNTIL Efec2.NEXT = 0;
            NoRemesa.MODIFY;
        END;
    END;

    PROCEDURE TestLimDto(VAR NoRemesa: Record "Cab. borrador pagare");
    VAR
        ConfigContable: Record "General Ledger Setup";
        CtaBanco: Record 270;
        TestLimDto: Page 7000037;
    BEGIN
        // WITH NoRemesa DO BEGIN
        ConfigContable.GET;
        if not NoRemesa.Impresa AND CtaBanco.GET(NoRemesa."Fecha de vto.") THEN BEGIN
            CtaBanco.CALCFIELDS(CtaBanco."Posted Receiv. Bills Rmg. Amt.");
            NoRemesa.CALCFIELDS(Importe);
            if NoRemesa.Importe + CtaBanco."Posted Receiv. Bills Rmg. Amt." > CtaBanco."Credit Limit for Discount" THEN BEGIN
                TestLimDto.SETRECORD(CtaBanco);
                // TestLimDto.SetValues(NoRemesa.Importe,0);
                if TestLimDto.RUNMODAL <> ACTION::Yes THEN
                    ERROR('Se ha interrumpido la transacción para respetar la advertencia.');
                CLEAR(TestLimDto);
            END;
        END;
    END;
    //END;

    PROCEDURE CrearPagoEfec(VAR LinDiaGen2: Record "Gen. Journal Line"; VAR MovCliente: Record 21);
    BEGIN
        //  WITH LinDiaGen2. DO BEGIN
        LinDiaGen2."Account Type" := LinDiaGen2."Account Type"::Customer;
        LinDiaGen2."Account No." := MovCliente."Customer No.";
        LinDiaGen2."Document Type" := LinDiaGen2."Document Type"::Payment;
        LinDiaGen2."Document No." := MovCliente."Document No.";
        LinDiaGen2."Bill No." := MovCliente."Bill No.";
        LinDiaGen2.Description := STRSUBSTNO(
          'Liq. efecto %1/%2',
          MovCliente."Document No.",
          MovCliente."Bill No.");
        LinDiaGen2."Currency Code" := MovCliente."Currency Code";
        LinDiaGen2.VALIDATE(Amount, -MovCliente."Remaining Amount");
        LinDiaGen2."Shortcut Dimension 1 Code" := MovCliente."Global Dimension 1 Code";
        LinDiaGen2."Shortcut Dimension 2 Code" := MovCliente."Global Dimension 2 Code";
        LinDiaGen2."System-Created Entry" := TRUE;
        LinDiaGen2."Applies-to Doc. Type" := LinDiaGen2."Document Type"::Refund;
        LinDiaGen2."Applies-to Doc. No." := MovCliente."Document No.";
        LinDiaGen2."Applies-to Bill No." := MovCliente."Bill No.";
        //END;
    END;

    PROCEDURE MarcasConfirming(rMov: Record 25; nRemesa: Code[20]; nEfecto: Code[10]);
    VAR
        rMov2: Record 25;
    BEGIN
        rMov2.SETCURRENTKEY(rMov2."Closed by Entry No.");
        rMov2.SETRANGE("Closed by Entry No.", rMov."Entry No.");
        if rMov2.FIND('-') THEN
            REPEAT
                rConfFact.INIT;
                rConfFact."No. relación pagos" := nRemesa;
                rConfFact."Pago-a Nº proveedor" := rMov2."Vendor No.";
                rConfFact."Pago a-Nombre" := rMov2."Vendor Name";
                rConfFact."Pago a-Nombre 2" := rMov2."Bill No.";
                rConfFact."Importe IVA incl." := rMov2.Amount * (-1);
                //rConfFact."Importe a pagar"   := rMov2."Remaining Amount" * (-1);
                rConfFact."Fecha registro" := rMov2."Posting Date";
                //rConfFact."Efecto Interno"    := nEfecto;
                if rConfFact.INSERT THEN
                    MarcasConfirming(rMov2, nRemesa, nEfecto);
            UNTIL rMov2.NEXT = 0;
    END;


}
