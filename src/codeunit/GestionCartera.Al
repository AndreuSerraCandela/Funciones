/// <summary>
/// Codeunit Gestion cartera (ID 50004).
/// </summary>
codeunit 50004 "Gestion cartera"
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
    tabledata 380 = rimd,
    tabledata 7000002 = rimd;

    trigger OnRun()
    BEGIN
        r121.FINDFIRST;
        REPEAT
            r39.GET(r39."Document Type"::Order, r121."Order No.", r121."Order Line No.");
            if r121.Type = r121.Type::Resource THEN BEGIN
                if r39.Type <> r39.Type::Resource THEN BEGIN
                    r39.Type := r121.Type;
                    r39."No." := r121."No.";
                    r39.MODIFY;
                END;
            END;
        UNTIL r121.NEXT = 0;
    END;

    VAR
        r39: Record 39;
        r121: Record "Purch. Rcpt. Line";

    PROCEDURE CrearDocCartera(rCabVenta: Record 36; pNumFac: Integer; NoPlazos: Integer);
    VAR
        rLinDiaGen: Record "Gen. Journal Line";
        rCliente: Record Customer;
        rGrContCli: Record 92;
        SalesLine: Record 37;
        TempSalesLine: Record 37 TEMPORARY;
        TotalSalesLine: Record 37;
        TotalSalesLineLCY: Record 37;
        rCnfCar: Record 7000016;
        rCnfVta: Record 311;
        rCabVenta2: Record 36;
        rLinVenta: Record 37;
        rTnos: Record "Términos facturación";
        SalesPost: Codeunit "Sales-Post";
        VATAmountText: Text[30];
        wNumTot: Text[20];
        TotalAmount: Decimal;
        VATAmount: Decimal;
        ProfitLCY: Decimal;
        ProfitPct: Decimal;
        TotalAdjCostLCY: Decimal;
        wLinea: Integer;
    BEGIN
        // Creo una línea de diario que generará doc. a cobrar y hará el asiento contable.
        // Si pNumFac es 0 obtendré el siguiente nº de borrador a crear.

        rCnfCar.GET;
        rCnfCar.TESTFIELD("Seccion remesa sin factura");

        if pNumFac = 0 THEN BEGIN
            rCabVenta2.RESET;
            rCabVenta2.SETRANGE("Document Type", rCabVenta2."Document Type"::Invoice);
            rCabVenta2.SETRANGE("Nº Contrato", rCabVenta."Nº Contrato");
            pNumFac := rCabVenta2.COUNT;      //no sumo 1 porque aqui incluye el actual
            wNumTot := '';
        END
        ELSE BEGIN
            //if rTnos.GET(rCabVenta."Cód. términos facturacion") THEN BEGIN
            //  rTnos.CALCFIELDS("Nº de plazos");
            wNumTot := '/' + FORMAT(NoPlazos);// rTnos."Nº de plazos");
                                              // END;
        END;

        //Primero calculo los totales de la factura

        rCnfVta.GET;
        if rCnfVta."Calc. Inv. Discount" THEN BEGIN
            rLinVenta.RESET;
            rLinVenta.SETRANGE("Document Type", rCabVenta."Document Type");
            rLinVenta.SETRANGE("Document No.", rCabVenta."No.");
            if rLinVenta.FINDFIRST THEN
                CODEUNIT.RUN(CODEUNIT::"Sales-Calc. Discount", rLinVenta);
        END;

        CLEAR(SalesLine);
        CLEAR(TotalSalesLine);
        CLEAR(TotalSalesLineLCY);
        CLEAR(SalesPost);

        SalesPost.GetSalesLines(rCabVenta, TempSalesLine, 0);
        CLEAR(SalesPost);
        SalesPost.SumSalesLinesTemp(
          rCabVenta, TempSalesLine, 0, TotalSalesLine, TotalSalesLineLCY,
          VATAmount, VATAmountText, ProfitLCY, ProfitPct, TotalAdjCostLCY);

        if rCabVenta."Prices Including VAT" THEN BEGIN
            TotalAmount := TotalSalesLine.Amount;
        END ELSE BEGIN
            TotalAmount := TotalSalesLine."Amount Including VAT";
        END;

        wLinea := 0;
        rLinDiaGen.RESET;
        rLinDiaGen.SETRANGE("Journal Template Name", 'CARTERA');
        rLinDiaGen.SETRANGE("Journal Batch Name", rCnfCar."Seccion remesa sin factura");
        if rLinDiaGen.FIND('+') THEN
            wLinea := rLinDiaGen."Line No.";

        rLinDiaGen.INIT;
        rLinDiaGen.VALIDATE("Journal Template Name", 'CARTERA');
        rLinDiaGen.VALIDATE("Journal Batch Name", rCnfCar."Seccion remesa sin factura");
        wLinea := wLinea + 1;
        rLinDiaGen.VALIDATE(rLinDiaGen."Line No.", wLinea);
        rLinDiaGen.VALIDATE("Posting Date", rCabVenta."Posting Date");
        rLinDiaGen.VALIDATE("Document Type", rLinDiaGen."Document Type"::Bill);
        rLinDiaGen.VALIDATE("Account Type", rLinDiaGen."Account Type"::Customer);
        rLinDiaGen.VALIDATE("Account No.", rCabVenta."Bill-to Customer No.");
        rLinDiaGen.VALIDATE("Document No.", rCabVenta."Nº Contrato" + '-' + FORMAT(pNumFac));
        rLinDiaGen.VALIDATE("Bill No.", FORMAT(pNumFac) + wNumTot);
        rLinDiaGen.VALIDATE("Due Date", rCabVenta."Due Date");
        if TotalAmount > 0 THEN BEGIN
            rLinDiaGen.VALIDATE("Debit Amount", TotalAmount);
        END
        ELSE BEGIN
            rLinDiaGen.VALIDATE("Credit Amount", -TotalAmount);
        END;
        rLinDiaGen.VALIDATE("Currency Code", rCabVenta."Currency Code");
        rLinDiaGen.VALIDATE("Bal. Account Type", rLinDiaGen."Bal. Account Type"::"G/L Account");
        rCliente.GET(rCabVenta."Bill-to Customer No.");
        rGrContCli.GET(rCliente."Customer Posting Group");
        rGrContCli.TESTFIELD("Cta efectos sin fra");
        rLinDiaGen.VALIDATE("Bal. Account No.", rGrContCli."Cta efectos sin fra");
        rLinDiaGen.VALIDATE("No. Borrador factura", rCabVenta."No.");
        rLinDiaGen."Payment Method Code" := rCabVenta."Payment Method Code";
        rLinDiaGen.VALIDATE(Description, COPYSTR('Efecto ' + rLinDiaGen."Document No." + '/' +
                            rLinDiaGen."Bill No.", 1, MAXSTRLEN(rLinDiaGen.Description)));
        if TotalAmount > 2 THEN
            rLinDiaGen.INSERT(TRUE);
    END;

    PROCEDURE RegistrarDocCartera(): Boolean;
    VAR
        rLinDiaGen: Record "Gen. Journal Line";
        rCnfCar: Record 7000016;
        DocPost: Codeunit 7000006;
        PostOk: Boolean;
    BEGIN
        rCnfCar.GET;
        rCnfCar.TESTFIELD("Seccion remesa sin factura");

        rLinDiaGen.RESET;
        rLinDiaGen.SETRANGE("Journal Template Name", 'CARTERA');
        rLinDiaGen.SETRANGE("Journal Batch Name", rCnfCar."Seccion remesa sin factura");
        rLinDiaGen.SetFilter("Posting Date", '<>%1', 0D);
        if rLinDiaGen.FINDFIRST THEN BEGIN
            PostOk := FALSE;
            PostLinesSinMsg(rLinDiaGen, PostOk, FALSE);
            EXIT(PostOk);
        END;
        EXIT(FALSE);
    END;

    /// <summary>
    /// PostLinesSinMsg.
    /// </summary>
    /// <param name="GenJnlLine2">VAR Record "Gen. Journal Line".</param>
    /// <param name="PostOk">VAR Boolean.</param>
    /// <param name="Print">Boolean.</param>
    procedure PostLinesSinMsg(var GenJnlLine2: Record "Gen. Journal Line"; var PostOk: Boolean; Print: Boolean)
    begin
        //$001
        //GenJnlLine.COPY(GenJnlLine2);
        CodeSinMsg(GenJnlLine2, PostOk, Print);
        //GenJnlLine2.COPY(GenJnlLine);
    end;

    /// <summary>
    /// CodeSinMsg.
    /// </summary>
    /// <param name="GenJnlLine">VAR Record "Gen. Journal Line".</param>
    /// <param name="PostOk">VAR Boolean.</param>
    /// <param name="Print">Boolean.</param>
    procedure CodeSinMsg(var GenJnlLine: Record "Gen. Journal Line"; var PostOk: Boolean; Print: Boolean)
    var
        GenJnlTemplate: Record "Gen. Journal Template";
        GenJnlPostBatch: Codeunit "Gen. Jnl.-Post Batch";
        TempJnlBatchName: Code[20];
        GLReg: Record "G/L Register";
        CVLedgEntryBuf: Record "CV Ledger Entry Buffer";
        r17: Record "G/L Entry";
        a: Integer;
        Text1100012: Label 'no puede contener un filtro cuando se registra un diario periódico';
        DocPost: Codeunit 7000006;
    begin

        //$001
        //WITH GenJnlLine DO BEGIN
        GenJnlLine.FINDFIRST;
        GenJnlTemplate.GET(GenJnlLine."Journal Template Name");
        GenJnlTemplate.TESTFIELD("Force Posting Report", FALSE);
        if GenJnlTemplate.Recurring AND (GenJnlLine.GETFILTER("Posting Date") <> '') THEN
            GenJnlLine.FIELDERROR("Posting Date", Text1100012);

        /* {Bloqueada esta parte
        if Print THEN BEGIN
            if NOT CONFIRM(Text1100013,FALSE) THEN
            EXIT;
        END ELSE BEGIN
            if NOT CONFIRM(Text1100014,FALSE) THEN
            EXIT;
        END;
        } */

        TempJnlBatchName := GenJnlLine."Journal Batch Name";

        if Print THEN BEGIN
            GLReg.LOCKTABLE;
            if GLReg.FIND('+') THEN;
        END;
        GLReg.LOCKTABLE;
        if GLReg.FIND('+') THEN;
        GLReg."No." := GLReg."No." + 1;
        GLReg."From Entry No." := GLReg."To Entry No." + 1;
        GLReg."To Entry No." := GLReg."To Entry No." + GenJnlLine.COUNT;
#if CLEAN24
#pragma warning disable AL0432
        GLReg."Creation Date" := TODAY;
#pragma warning restore AL0432
#else
        GLReg."SystemCreatedAt" := CURRENTDATETIME;
#endif
        GLReg."Source Code" := GenJnlLine."Source Code";
        GLReg."User ID" := USERID;
        GLReg."From VAT Entry No." := GLReg."To VAT Entry No.";
        GLReg."Posting Date" := GenJnlLine."Posting Date";
        r17.FINDLAST;
        a := r17."Entry No.";
        r17.INIT;
        r17."Entry No." := a + GenJnlLine.COUNT;
        r17.INSERT;
        REPEAT
            CVLedgEntryBuf.INIT;
            a := a + 1;
            CVLedgEntryBuf."Entry No." := a;
            CVLedgEntryBuf."CV No." := GenJnlLine."Account No.";
            CVLedgEntryBuf."Posting Date" := GenJnlLine."Posting Date";
            CVLedgEntryBuf."Document Type" := GenJnlLine."Document Type";
            CVLedgEntryBuf."Document No." := GenJnlLine."Document No.";
            CVLedgEntryBuf.Description := GenJnlLine.Description;
            CVLedgEntryBuf."Currency Code" := GenJnlLine."Currency Code";
            CVLedgEntryBuf.Amount := GenJnlLine.Amount;
            CVLedgEntryBuf."Remaining Amount" := GenJnlLine.Amount;
            CVLedgEntryBuf."Original Amount" := GenJnlLine.Amount;
            CVLedgEntryBuf."Original Amt. (LCY)" := GenJnlLine."Amount (LCY)";
            CVLedgEntryBuf."Remaining Amt. (LCY)" := GenJnlLine."Amount (LCY)";
            CVLedgEntryBuf."Amount (LCY)" := GenJnlLine."Amount (LCY)";
            CVLedgEntryBuf."Sales/Purchase (LCY)" := 0;
            CVLedgEntryBuf."Inv. Discount (LCY)" := GenJnlLine."Inv. Discount (LCY)";
            CVLedgEntryBuf."Bill-to/Pay-to CV No." := GenJnlLine."Account No.";
            CVLedgEntryBuf."CV Posting Group" := GenJnlLine."Posting Group";
            CVLedgEntryBuf."Global Dimension 1 Code" := GenJnlLine."Shortcut Dimension 1 Code";
            CVLedgEntryBuf."Global Dimension 2 Code" := GenJnlLine."Shortcut Dimension 2 Code";
            CVLedgEntryBuf."Salesperson Code" := GenJnlLine."Salespers./Purch. Code";
            CVLedgEntryBuf."User ID" := USERID;
            CVLedgEntryBuf."Source Code" := GenJnlLine."Source Code";
            CVLedgEntryBuf."On Hold" := GenJnlLine."On Hold";
            CVLedgEntryBuf."Applies-to Doc. Type" := GenJnlLine."Applies-to Doc. Type";
            CVLedgEntryBuf."Applies-to Doc. No." := GenJnlLine."Applies-to Doc. No.";
            CVLedgEntryBuf.Open := TRUE;
            CVLedgEntryBuf."Due Date" := GenJnlLine."Due Date";
            CVLedgEntryBuf."Pmt. Discount Date" := GenJnlLine."Pmt. Discount Date";
            CVLedgEntryBuf."Original Pmt. Disc. Possible" := 0;
            CVLedgEntryBuf."Remaining Pmt. Disc. Possible" := 0;
            CVLedgEntryBuf."Pmt. Disc. Given (LCY)" := 0;
            CVLedgEntryBuf.Positive := (GenJnlLine.Amount > 0);
            CVLedgEntryBuf."Closed by Entry No." := 0;
            CVLedgEntryBuf."Closed at Date" := 0D;
            CVLedgEntryBuf."Closed by Amount" := 0;
            CVLedgEntryBuf."Applies-to ID" := '';
            CVLedgEntryBuf."Journal Batch Name" := GenJnlLine."Journal Batch Name";
            CVLedgEntryBuf."Reason Code" := GenJnlLine."Reason Code";
            CVLedgEntryBuf."Bal. Account Type" := GenJnlLine."Bal. Account Type";
            CVLedgEntryBuf."Bal. Account No." := GenJnlLine."Bal. Account No.";
            CVLedgEntryBuf."Transaction No." := GenJnlLine."Transaction No.";
            CVLedgEntryBuf."Closed by Amount (LCY)" := 0;
            CVLedgEntryBuf."Debit Amount" := GenJnlLine."Debit Amount";
            CVLedgEntryBuf."Credit Amount" := GenJnlLine."Credit Amount";
            CVLedgEntryBuf."Debit Amount (LCY)" := 0;
            CVLedgEntryBuf."Credit Amount (LCY)" := 0;
            if GenJnlLine."Amount (LCY)" > 0 THEN
                CVLedgEntryBuf."Debit Amount (LCY)" := GenJnlLine."Amount (LCY)";
            if GenJnlLine."Amount (LCY)" < 0 THEN
                CVLedgEntryBuf."Credit Amount (LCY)" := -GenJnlLine."Amount (LCY)";
            CVLedgEntryBuf."Document Date" := GenJnlLine."Document Date";
            CVLedgEntryBuf."External Document No." := GenJnlLine."External Document No.";
            CVLedgEntryBuf."No. Series" := '';
            CVLedgEntryBuf."Closed by Currency Code" := '';
            CVLedgEntryBuf."Closed by Currency Amount" := 0;
            CVLedgEntryBuf."Adjusted Currency Factor" := GenJnlLine."Currency Factor";
            CVLedgEntryBuf."Original Currency Factor" := GenJnlLine."Currency Factor";
            CVLedgEntryBuf."Pmt. Disc. Tolerance Date" := 0D;
            CVLedgEntryBuf.Prepayment := GenJnlLine.Prepayment;
            CVLedgEntryBuf."Bill No." := GenJnlLine."Bill No.";
            CVLedgEntryBuf."Document Situation" := CVLedgEntryBuf."Document Situation"::Cartera;
            CVLedgEntryBuf."Applies-to Bill No." := '';
            CVLedgEntryBuf."Document Status" := CVLedgEntryBuf."Document Status"::Open;

            CreateReceivableDoc(GenJnlLine, CVLedgEntryBuf, TRUE);
        UNTIL GenJnlLine.NEXT = 0;
        GenJnlLine.DELETEALL;
        //END;
    end;

    /// <summary>
    /// CreateReceivableDoc.
    /// </summary>
    /// <param name="GenJnlLine">Record "Gen. Journal Line".</param>
    /// <param name="CVLedgEntryBuf">VAR Record "CV Ledger Entry Buffer".</param>
    /// <param name="IsFromJournal">Boolean.</param>
    procedure CreateReceivableDoc(GenJnlLine: Record "Gen. Journal Line"; var CVLedgEntryBuf: Record "CV Ledger Entry Buffer"; IsFromJournal: Boolean)
    var
        CarteraDoc: Record "Cartera Doc.";
        CompanyInfo: Record "Company Information";
        OldCustLedgEntry: Record "Cust. Ledger Entry";
        CustBankAccCode: Record "Customer Bank Account";
        Text1100004: Label 'Efecto %1/%2 ya existe.';
        DebitMandate: Record "SEPA Direct Debit Mandate";
        Contrato: Record "Sales Header";
        Customer: Record Customer;
    begin
        CarteraDoc.Init();
        GJLInfoToDoc(GenJnlLine, CarteraDoc);
        with CVLedgEntryBuf do begin
            CarteraDoc.Type := CarteraDoc.Type::Receivable;
            CarteraDoc."Entry No." := "Entry No.";
            CarteraDoc."Remaining Amount" := "Remaining Amount";
            CarteraDoc."Remaining Amt. (LCY)" := "Remaining Amt. (LCY)";
            CarteraDoc."Original Amount" := "Remaining Amount";
            CarteraDoc."Original Amount (LCY)" := "Remaining Amt. (LCY)";
            CarteraDoc."No. Borrador factura" := GenJnlLine."No. Borrador factura";
            //CarteraDoc.Banco := Banco;
            if CompanyInfo.Get and CustBankAccCode.Get("CV No.", GenJnlLine."Recipient Bank Account") then
                CarteraDoc.Place := CopyStr(CompanyInfo."Post Code", 1, 2) = CopyStr(CustBankAccCode."Post Code", 1, 2);
            // Check the Doc no.
            OldCustLedgEntry.Reset();
            OldCustLedgEntry.SetCurrentKey("Document No.", "Document Type", "Customer No.");
            OldCustLedgEntry.SetRange("Document No.", "Document No.");
            if GenJnlLine."Document Type" = GenJnlLine."Document Type"::Bill then
                OldCustLedgEntry.SetRange("Document Type", OldCustLedgEntry."Document Type"::Bill)
            else
                if GenJnlLine."Document Type" = GenJnlLine."Document Type"::Invoice then
                    OldCustLedgEntry.SetRange("Document Type", OldCustLedgEntry."Document Type"::Invoice);
            OldCustLedgEntry.SetRange("Bill No.", "Bill No.");
            if OldCustLedgEntry.FindFirst then
                Error(
                  Text1100004,
                  "Document No.", "Bill No.");
        end;

        if IsFromJournal then
            CarteraDoc."From Journal" := true;
        //Direct Debit Mandate es igual al Numero de documento lo que va antes del guion
        //CTO22-00961-12
        //123456789012345
        //rECUPERAR LA SEGINDA POSICION DEL -
        if StrPos(Copystr(CarteraDoc."Document No.", 7), '-') > 0 then begin
            CarteraDoc."Direct Debit Mandate ID" := CopyStr(CarteraDoc."Document No.", 1, 11);
            DebitMandate.SetRange("ID", CarteraDoc."Direct Debit Mandate ID");
            if DebitMandate.FindFirst() Then begin
                DebitMandate."Valid To" := CarteraDoc."Due Date";
                DebitMandate.MODIFY();
            end else begin
                DebitMandate.INIT();
                DebitMandate.ID := CarteraDoc."Direct Debit Mandate ID";
                DebitMandate."Customer No." := CarteraDoc."Account No.";
                if CarteraDoc."Cust./Vendor Bank Acc. Code" = '' then begin
                    if StrPos(Copystr(CarteraDoc."Document No.", 7), '-') > 0 then begin
                        if Contrato.Get(Contrato."Document Type", CopyStr(CarteraDoc."Document No.", 1, 11)) Then begin
                            CarteraDoc."Cust./Vendor Bank Acc. Code" := Contrato."Cust. Bank Acc. Code";
                            if CarteraDoc."Cust./Vendor Bank Acc. Code" = '' Then begin
                                Customer.get(CarteraDoc."Account No.");
                                CarteraDoc."Cust./Vendor Bank Acc. Code" := Customer."Preferred Bank Account Code";
                            end;
                        end else begin
                            Customer.get(CarteraDoc."Account No.");
                            CarteraDoc."Cust./Vendor Bank Acc. Code" := Customer."Preferred Bank Account Code";
                        end;
                    end;
                end;
                DebitMandate."Customer Bank Account Code" := CarteraDoc."Cust./Vendor Bank Acc. Code";
                DebitMandate."Valid From" := CarteraDoc."Due Date";
                DebitMandate."Date of Signature" := CarteraDoc."Posting Date";
                DebitMandate."Type of Payment" := DebitMandate."Type of Payment"::Recurrent;
                if Strpos(CarteraDoc."No.", '/') > 0 then
                    Evaluate(DebitMandate."Expected Number of Debits", CopyStr(CarteraDoc."No.", Strpos(CarteraDoc."No.", '/') + 1, 100))
                else
                    DebitMandate."Expected Number of Debits" := 1;
                DebitMandate."Debit Counter" := 0;
                DebitMandate."Ignore Exp. Number of Debits" := true;
                DebitMandate."Valid To" := CarteraDoc."Due Date";
                DebitMandate."Valid To" := Calcdate(Format(DebitMandate."Expected Number of Debits") + 'M', CarteraDoc."Due Date");
                if DebitMandate.INSERT() Then;
            end;
        end;

        //OnBeforeCreateReceivableDoc(CarteraDoc, GenJnlLine, CVLedgEntryBuf);
        CarteraDoc.Insert();
        // OnAfterCreateReceivableDoc(CarteraDoc, GenJnlLine, CVLedgEntryBuf);
        CVLedgEntryBuf."Document Situation" := CVLedgEntryBuf."Document Situation"::Cartera;
        CVLedgEntryBuf."Document Status" := CVLedgEntryBuf."Document Status"::Open;

    end;

    /// <summary>
    /// GJLInfoToDoc.
    /// </summary>
    /// <param name="GenJnlLine">VAR Record "Gen. Journal Line".</param>
    /// <param name="CarteraDoc">VAR Record "Cartera Doc.".</param>
    procedure GJLInfoToDoc(var GenJnlLine: Record "Gen. Journal Line"; var CarteraDoc: Record "Cartera Doc.")
    var
        PaymentMethod: Record "Payment Method";
        CompanyInfo: Record "Company Information";
        CustBankAcc: Record "Customer Bank Account";
        //CustPmtAddress: Record "Customer Pmt. Address";
        Cust: Record Customer;
    begin
        with GenJnlLine do begin
            CarteraDoc."No." := "Bill No.";
            CarteraDoc."Posting Date" := "Posting Date";
            CarteraDoc."No. Borrador factura" := GenJnlLine."No. Borrador factura";
            CarteraDoc.Banco := Banco;
            CarteraDoc."Document No." := "Document No.";
            CarteraDoc."Original Document No." := "Document No.";
            CarteraDoc.Description := Description;
            CarteraDoc."Due Date" := "Due Date";
            CarteraDoc."Payment Method Code" := "Payment Method Code";
            PaymentMethod.Get("Payment Method Code");
            if PaymentMethod."Submit for Acceptance" then
                CarteraDoc.Accepted := CarteraDoc.Accepted::No
            else
                CarteraDoc.Accepted := CarteraDoc.Accepted::"Not Required";
            CarteraDoc."Collection Agent" := PaymentMethod."Collection Agent";
            CarteraDoc."Account No." := "Account No.";
            CarteraDoc."Currency Code" := "Currency Code";
            CarteraDoc."Cust./Vendor Bank Acc. Code" :=
              CopyStr("Recipient Bank Account", 1, MaxStrLen(CarteraDoc."Cust./Vendor Bank Acc. Code"));
            //CarteraDoc."Pmt. Address Code" := "Pmt. Address Code";
            CarteraDoc."Global Dimension 1 Code" := "Shortcut Dimension 1 Code";
            CarteraDoc."Global Dimension 2 Code" := "Shortcut Dimension 2 Code";
            CarteraDoc."Dimension Set ID" := "Dimension Set ID";
            CarteraDoc."Direct Debit Mandate ID" := "Direct Debit Mandate ID";
            case "Document Type" of
                "Document Type"::Bill:
                    CarteraDoc."Document Type" := CarteraDoc."Document Type"::Bill;
                "Document Type"::Invoice:
                    CarteraDoc."Document Type" := CarteraDoc."Document Type"::Invoice;
                "Document Type"::"Credit Memo":
                    CarteraDoc."Document Type" := CarteraDoc."Document Type"::Invoice;
            end;
            if "Account Type" = "Account Type"::Customer then begin
                CompanyInfo.Get();
                if "Recipient Bank Account" <> '' then begin
                    CustBankAcc.Get("Account No.", "Recipient Bank Account");
                    CarteraDoc.Place := CompanyInfo."Post Code" = CustBankAcc."Post Code";
                    exit;
                end;
                // if "Pmt. Address Code" <> '' then begin
                //     CustPmtAddress.Get("Account No.", "Pmt. Address Code");
                //     CarteraDoc.Place := CompanyInfo."Post Code" = CustPmtAddress."Post Code";
                //     exit;
                // end;
                Cust.Get("Account No.");
                CarteraDoc.Place := CompanyInfo."Post Code" = Cust."Post Code";
            end;
        end;
    end;

    PROCEDURE CrearDocCarteraReg(rCabVenta: Record 112);
    VAR
        rLinDiaGen: Record "Gen. Journal Line";
        rCliente: Record Customer;
        rGrContCli: Record 92;
        rCnfCar: Record 7000016;
        rLinVenta: Record 113;
        rHisCabVta2: Record 112;
        rCabVta: Record 36;
        VATAmountText: Text[30];
        TotalAmount: Decimal;
        wLinea: Integer;
        wNumFac: Integer;
    BEGIN
        // Función provisional para crear los documentos de cartera de facturas registradas.
        // Creo una línea de diario que generará doc. a cobrar y hará el asiento contable.

        rCnfCar.GET;
        rCnfCar.TESTFIELD("Seccion remesa sin factura");

        //Primero calculo los totales de la factura
        TotalAmount := 0;
        rLinVenta.RESET;
        rLinVenta.SETRANGE("Document No.", rCabVenta."No.");
        if rLinVenta.FIND('-') THEN BEGIN
            REPEAT
                TotalAmount := TotalAmount + rLinVenta."Amount Including VAT";
            UNTIL rLinVenta.NEXT = 0;
        END;

        rHisCabVta2.RESET;
        rHisCabVta2.SETCURRENTKEY("Nº Proyecto", "Nº Contrato");
        rHisCabVta2.SETRANGE("Nº Contrato", rCabVenta."Nº Contrato");
        rHisCabVta2.SETFILTER("No.", '..%1', rCabVenta."No.");
        wNumFac := rHisCabVta2.COUNT;
        rCabVta.RESET;
        rCabVta.SETRANGE("Document Type", rCabVta."Document Type"::Invoice);
        rCabVta.SETRANGE("Nº Contrato", rCabVenta."Nº Contrato");
        wNumFac := wNumFac + rCabVta.COUNT;

        wLinea := 0;
        rLinDiaGen.RESET;
        rLinDiaGen.SETRANGE("Journal Template Name", 'CARTERA');
        rLinDiaGen.SETRANGE("Journal Batch Name", rCnfCar."Seccion remesa sin factura");
        if rLinDiaGen.FIND('+') THEN
            wLinea := rLinDiaGen."Line No.";

        rLinDiaGen.INIT;
        rLinDiaGen.VALIDATE("Journal Template Name", 'CARTERA');
        rLinDiaGen.VALIDATE("Journal Batch Name", rCnfCar."Seccion remesa sin factura");
        wLinea := wLinea + 1;
        rLinDiaGen.VALIDATE(rLinDiaGen."Line No.", wLinea);
        rLinDiaGen.VALIDATE("Posting Date", rCabVenta."Posting Date");
        rLinDiaGen.VALIDATE("Document Type", rLinDiaGen."Document Type"::Bill);
        rLinDiaGen.VALIDATE("Account Type", rLinDiaGen."Account Type"::Customer);
        rLinDiaGen.VALIDATE("Account No.", rCabVenta."Bill-to Customer No.");
        rLinDiaGen.VALIDATE("Document No.", rCabVenta."Nº Contrato" + '-' + FORMAT(wNumFac));
        rLinDiaGen.VALIDATE("Bill No.", '1');
        rLinDiaGen.VALIDATE("Payment Method Code", rCabVenta."Payment Method Code");
        rLinDiaGen.VALIDATE("Due Date", rCabVenta."Due Date");
        if TotalAmount > 0 THEN BEGIN
            rLinDiaGen.VALIDATE("Debit Amount", TotalAmount);
        END
        ELSE BEGIN
            rLinDiaGen.VALIDATE("Credit Amount", -TotalAmount);
        END;
        rLinDiaGen.VALIDATE("Currency Code", rCabVenta."Currency Code");
        rLinDiaGen.VALIDATE("Bal. Account Type", rLinDiaGen."Bal. Account Type"::"G/L Account");
        rCliente.GET(rCabVenta."Bill-to Customer No.");
        rGrContCli.GET(rCliente."Customer Posting Group");
        ////rLinDiaGen.VALIDATE("Bal. Account No.",rGrContCli."Receivables Account");
        rLinDiaGen.VALIDATE("Bal. Account No.", rGrContCli."Bills Account");
        rLinDiaGen.VALIDATE("No. Borrador factura", rCabVenta."No.");
        rLinDiaGen.VALIDATE("Payment Method Code", rCabVenta."Payment Method Code");
        rLinDiaGen.VALIDATE(Description, COPYSTR('Efecto ' + rLinDiaGen."Document No." + '/' +
                            rLinDiaGen."Bill No.", 1, MAXSTRLEN(rLinDiaGen.Description)));
        if TotalAmount > 0 THEN
            rLinDiaGen.INSERT(TRUE);
    END;

}