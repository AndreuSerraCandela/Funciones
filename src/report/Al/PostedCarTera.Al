
report 50024 "Settle Docs. Bill Gr. Malla"
{
    Caption = 'Liquidar documentos.';
    Permissions = TableData "Cust. Ledger Entry" = rimd,
                  TableData "Vendor Ledger Entry" = rimd,
                  TableData "G/L Register" = m,
                  TableData "Posted Cartera Doc." = rimd,
                  TableData "Closed Cartera Doc." = rimd,
                  TableData "Posted Bill Group" = rimd,
                  TableData "Closed Bill Group" = rimd;
    ProcessingOnly = true;

    dataset
    {
        dataitem(PostedDoc; "Posted Cartera Doc.")
        {
            DataItemTableView = SORTING("Bill Gr./Pmt. Order No.", Status, "Category Code", Redrawn, "Due Date") WHERE(Status = CONST(Open));

            trigger OnAfterGetRecord()
            var
                FromJnl: Boolean;
                CarteraSetup: record "Cartera Setup";
                r21: record 21;
                PayMenthMetod: Record "Payment Method";
                SalesInvoice: Record "Sales Invoice Header";
                SalesHeader: Record "Sales Header";


            begin
                IsRedrawn := CarteraManagement.CheckFromRedrawnDoc("No.");

                if PostedDoc."No. Borrador factura" = '' THEN BEGIN
                    if NOT r21.GET(PostedDoc."Entry No.") THEN BEGIN
                        if PayMenthMetod.Get(PostedDoc."Payment Method Code") Then Begin
                            if PayMenthMetod."Remesa sin factura" Then begin
                                SalesInvoice.SetRange("Bill-to Customer No.", PostedDoc."Account No.");
                                SalesInvoice.SetRange("Due Date", PostedDoc."Due Date");
                                //Efecto CTO22-00546-10/10/12
                                //12345678
                                SalesInvoice.Setrange("Nº Contrato", Copystr(PostedDoc.Description, 8, 11));
                                if SalesInvoice.FindFirst() Then begin
                                    r21.SetRange("Document No.", SalesInvoice."No.");
                                    r21.SetRange("Nº Factura Borrador", '');
                                    if r21.FindFirst() Then begin
                                        r21."Nº Factura Borrador" := SalesInvoice."Pre-Assigned No.";
                                        r21.Modify();
                                    end;
                                    PostedDoc."No. Borrador factura" := SalesInvoice."Pre-Assigned No.";
                                end else begin
                                    SalesHeader.SetRange("Bill-to Customer No.", PostedDoc."Account No.");
                                    SalesHeader.SetRange("Due Date", PostedDoc."Due Date");
                                    SalesHeader.Setrange("Nº Contrato", Copystr(PostedDoc.Description, 8, 11));
                                    if SalesHeader.FindFirst() Then
                                        PostedDoc."No. Borrador factura" := SalesHeader."No.";

                                end;
                                //PostedDoc."No. Borrador factura" := 'SINFAC';
                                PostedDoc.MODIFY;
                            End;
                        end;
                    END;
                END;
                rDoc.GET(PostedDoc.Type, PostedDoc."Entry No.");
                rDoc.MARK := TRUE;
                CarteraSetup.GET;
                CarteraSetup.TESTFIELD(CarteraSetup."Diario reg. remesas");
                CarteraSetup.TESTFIELD(CarteraSetup."Seccion reg. remesas");
                PostedBillGr.Get("Bill Gr./Pmt. Order No.");
                BankAcc.Get(PostedBillGr."Bank Account No.");
                Delay := BankAcc."Delay for Notices";

                if DueOnly and (PostingDate < "Due Date" + Delay) then
                    CurrReport.Skip();

                DocCount := DocCount + 1;
                Window.Update(1, DocCount);

                with GenJnlLine do begin
                    GenJnlLineNextNo := GenJnlLineNextNo + 10000;
                    //Clear(GenJnlLine);

                    "Journal Template Name" := CarteraSetup."Diario reg. remesas";
                    "Journal Batch Name" := CarteraSetup."Seccion reg. remesas";
                    Init;
                    "Line No." := GenJnlLineNextNo;
                    "Posting Date" := PostingDate;
                    "Document Type" := "Document Type"::Payment;
                    "Document No." := PostedBillGr."No.";
                    "Reason Code" := PostedBillGr."Reason Code";
                    Validate("Account Type", "Account Type"::Customer);
                    //CustLedgEntry.Get(PostedDoc."Entry No.");

                    if NOT CustLedgEntry.GET("Entry No.") THEN BEGIN
                        CustLedgEntry.INIT;
                        CustLedgEntry."Entry No." := "Entry No.";
                        CustLedgEntry."Customer No." := rDoc."Account No.";
                        CustLedgEntry."Document No." := rDoc."Document No.";
                        CustLedgEntry."Global Dimension 1 Code" := rDoc."Global Dimension 1 Code";
                        CustLedgEntry."Global Dimension 2 Code" := rDoc."Global Dimension 2 Code";
                    END else BEGIN
                        if GLSetup."Unrealized VAT" and (PostedDoc."Document Type" = PostedDoc."Document Type"::Bill) then begin
                            FromJnl := false;
                            if PostedDoc."From Journal" then
                                FromJnl := true;
                            ExistsNoRealVAT := GenJnlPostLine.CustFindVATSetup(VATPostingSetup, CustLedgEntry, FromJnl)
                        end;
                    End;
                    OnAfterGetPostedDocOnBeforeValidateAccountNo(
                      GenJnlLine, PostedDoc, VATPostingSetup, CustLedgEntry, FromJnl, ExistsNoRealVAT);
                    Validate("Account No.", CustLedgEntry."Customer No.");
                    if PostedDoc."Document Type" = PostedDoc."Document Type"::Bill then
                        Description := CopyStr(
                            StrSubstNo(Text1100001, PostedDoc."Document No.", PostedDoc."No."),
                            1, MaxStrLen(Description))
                    else
                        Description := CopyStr(
                            StrSubstNo(Text1100002, PostedDoc."Document No."),
                            1, MaxStrLen(Description));
                    Validate("Currency Code", PostedDoc."Currency Code");

                    if PostedDoc."No. Borrador factura" = '' THEN BEGIN
                        if PaymentToleranceMgt.CheckCalcPmtDiscGenJnlCust(GenJnlLine, CustLedgEntry, 0, false) then
                            Validate(Amount, -PostedDoc."Remaining Amount" + CustLedgEntry."Remaining Pmt. Disc. Possible")
                        else
                            Validate(Amount, -PostedDoc."Remaining Amount");
                    END ELSE
                        VALIDATE(Amount, -PostedDoc."Remaining Amount");
                    if PostedDoc."No. Borrador factura" = '' THEN BEGIN
                        "Applies-to Doc. Type" := CustLedgEntry."Document Type";
                        "Applies-to Doc. No." := CustLedgEntry."Document No.";
                        "Applies-to Bill No." := CustLedgEntry."Bill No.";
                    END;

                    // "Applies-to Doc. Type" := CustLedgEntry."Document Type";
                    // "Applies-to Doc. No." := CustLedgEntry."Document No.";
                    // "Applies-to Bill No." := CustLedgEntry."Bill No.";
                    "Source Code" := SourceCode;
                    "System-Created Entry" := true;
                    "Shortcut Dimension 1 Code" := CustLedgEntry."Global Dimension 1 Code";
                    "Shortcut Dimension 2 Code" := CustLedgEntry."Global Dimension 2 Code";
                    "Dimension Set ID" :=
                      CarteraManagement.GetCombinedDimSetID(GenJnlLine, "Dimension Set Id");
                    OnBeforeGenJournalLineInsert(PostedDoc, GenJnlLine, VATPostingSetup, CustLedgEntry, CustLedgEntry, PostedBillGr);
                    "Liquida Facturas en Remesa" := TRUE;
                    "No. Borrador factura" := PostedDoc."No. Borrador factura";
                    GenJnlLine."Due Date" := PostedDoc."Due Date";
                    Insert;
                    SumLCYAmt := SumLCYAmt + "Amount (LCY)";
                end;

                if ("Document Type" = "Document Type"::Bill) and
                   GLSetup."Unrealized VAT" and
                   ExistsNoRealVAT and
                   (not IsRedrawn)
                then begin

                    CustLedgEntry.CalcFields("Remaining Amount", "Remaining Amt. (LCY)");
                    OnBeforeCustUnrealizedVAT2(PostedDoc, GenJnlLine, CustLedgEntry, PostedBillGr, NoRealVATBuffer);
                    CarteraManagement.CustUnrealizedVAT2(
                    CustLedgEntry,
                    CustLedgEntry."Remaining Amt. (LCY)",
                    GenJnlLine,
                    ExistVATEntry,
                    FirstVATEntryNo,
                    LastVATEntryNo,
                    NoRealVATBuffer,
                    FromJnl,
                    "Document No.");

                    TempCurrCode := "Currency Code";
                    "Currency Code" := '';

                    if NoRealVATBuffer.Find('-') then begin
                        repeat
                        begin
                            InsertGenJournalLine(
                              GenJnlLine."Account Type"::"G/L Account",
                              NoRealVATBuffer.Account,
                              NoRealVATBuffer.Amount,
                              "Global Dimension 1 Code",
                              "Global Dimension 2 Code",
                              "Dimension Set ID");
                            InsertGenJournalLine(
                              GenJnlLine."Account Type"::"G/L Account",
                              NoRealVATBuffer."Balance Account",
                              -NoRealVATBuffer.Amount,
                              "Global Dimension 1 Code",
                              "Global Dimension 2 Code",
                              "Dimension Set ID");
                        end;
                        until NoRealVATBuffer.Next() = 0;
                        NoRealVATBuffer.DeleteAll();
                    end;
                    "Currency Code" := TempCurrCode;
                end;

                if PostedDoc."No. Borrador factura" = '' THEN BEGIN
                    if PaymentToleranceMgt.CheckCalcPmtDiscGenJnlCust(GenJnlLine, CustLedgEntry, 0, false) then
                        CalcBankAccount("No.", "Remaining Amount" - CustLedgEntry."Remaining Pmt. Disc. Possible", CustLedgEntry."Entry No.")
                    else
                        CalcBankAccount("No.", "Remaining Amount", CustLedgEntry."Entry No.");


                    GroupAmount := GroupAmount + "Remaining Amount";
                    CustLedgEntry."Document Status" := CustLedgEntry."Document Status"::Honored;
                    CustLedgEntry.MODIFY;
                END ELSE BEGIN
                    CalcBankAccount("No.", "Remaining Amount", "Entry No.");
                    GroupAmount := GroupAmount + "Remaining Amount";
                END;

                // GroupAmount := GroupAmount + "Remaining Amount";
                // CustLedgEntry."Document Status" := CustLedgEntry."Document Status"::Honored;
                // CustLedgEntry.Modify();

                if (PostedBillGr."Dealing Type" = PostedBillGr."Dealing Type"::Discount) and
                   (PostedBillGr.Factoring <> PostedBillGr.Factoring::" ")
                then
                    DiscFactLiabs(PostedDoc);
            end;

            trigger OnPostDataItem()
            var
                CustLedgEntry2: Record "Cust. Ledger Entry";
                PostedDoc2: Record "Posted Cartera Doc.";
                IsHandled: Boolean;
                Total: Decimal;
            begin
                if (DocCount = 0) or (GroupAmount = 0) then begin
                    if DueOnly then
                        Error(
                          Text1100003 +
                          Text1100004);

                    Error(
                      Text1100003 +
                      Text1100005);
                end;
                IsHandled := false;
                OnPostDataItemOnBeforeBankAccPostBufferLoop(BankAccPostBuffer, PostedDoc, PostedBillGr, GenJnlLine, GenJnlLineNextNo, SumLCYAmt, PostingDate, SourceCode, IsHandled);

                if BankAccPostBuffer.FIND('-') THEN
                    REPEAT
                        Total := Total + BankAccPostBuffer.Amount;
                    UNTIL BankAccPostBuffer.NEXT = 0;
                if not IsHandled and BankAccPostBuffer.Find('-') then Begin
                    if CustLedgEntry2.Get(BankAccPostBuffer."Entry No.") Then;
                    PostedDoc2.Get(0, BankAccPostBuffer."Entry No.");
                    PostedBillGr.Get(PostedDoc2."Bill Gr./Pmt. Order No.");
                    BankAcc.Get(PostedBillGr."Bank Account No.");
                    if PostedBillGr.Factoring = PostedBillGr.Factoring::" " then begin
                        GenJnlLineNextNo := GenJnlLineNextNo + 10000;
                        with GenJnlLine do begin
                            //Clear(GenJnlLine);
                            Init;
                            "Line No." := GenJnlLineNextNo;
                            "Posting Date" := PostingDate;
                            "Document Type" := "Document Type"::Payment;
                            "Document No." := PostedBillGr."No.";
                            "Reason Code" := PostedBillGr."Reason Code";
                            if PostedBillGr."Dealing Type" = PostedBillGr."Dealing Type"::Discount then begin
                                BankAcc.TestField("Bank Acc. Posting Group");
                                BankAccPostingGr.Get(BankAcc."Bank Acc. Posting Group");
                                Validate("Account Type", "Account Type"::"G/L Account");
                                BankAccPostingGr.TestField("Liabs. for Disc. Bills Acc.");
                                Validate("Account No.", BankAccPostingGr."Liabs. for Disc. Bills Acc.");
                                Validate("Source Type", "Source Type"::"Bank Account");
                                Validate("Source No.", BankAcc."No.");
                            end else begin
                                Validate("Account Type", "Account Type"::"Bank Account");
                                Validate("Account No.", BankAcc."No.");
                            end;
                            Description := CopyStr(StrSubstNo(Text1100006, PostedBillGr."No."), 1, MaxStrLen(Description));
                            Validate("Currency Code", PostedBillGr."Currency Code");
                            Validate(Amount, Total);
                            "Source Code" := SourceCode;
                            "System-Created Entry" := true;
                            "Shortcut Dimension 1 Code" := BankAccPostBuffer."Global Dimension 1 Code";
                            "Shortcut Dimension 2 Code" := BankAccPostBuffer."Global Dimension 2 Code";
                            "Dimension Set ID" :=
                                CarteraManagement.GetCombinedDimSetID(GenJnlLine, PostedDoc2."Dimension Set Id");
                            OnBeforeGenJournalLineInsert(PostedDoc, GenJnlLine, VATPostingSetup, CustLedgEntry, CustLedgEntry2, PostedBillGr);
                            Insert;
                            SumLCYAmt := SumLCYAmt + "Amount (LCY)";
                            if gastos <> 0 then begin
                                Init;
                                GenJnlLineNextNo := GenJnlLineNextNo + 10000;
                                "Line No." := GenJnlLineNextNo;
                                "Posting Date" := PostingDate;
                                "Document Type" := "Document Type"::Payment;
                                "Document No." := PostedBillGr."No.";
                                "Reason Code" := PostedBillGr."Reason Code";
                                if PostedBillGr."Dealing Type" = PostedBillGr."Dealing Type"::Discount then begin
                                    BankAcc.TestField("Bank Acc. Posting Group");
                                    BankAccPostingGr.Get(BankAcc."Bank Acc. Posting Group");
                                    Validate("Account Type", "Account Type"::"G/L Account");
                                    BankAccPostingGr.TestField("Liabs. for Disc. Bills Acc.");
                                    Validate("Account No.", BankAccPostingGr."Liabs. for Disc. Bills Acc.");
                                    Validate("Source Type", "Source Type"::"Bank Account");
                                    Validate("Source No.", BankAcc."No.");
                                end else begin
                                    Validate("Account Type", "Account Type"::"Bank Account");
                                    Validate("Account No.", BankAcc."No.");
                                end;
                                Description := DescripcionGasto;
                                Validate("Currency Code", PostedBillGr."Currency Code");
                                Validate(Amount, -Gastos);
                                "Source Code" := SourceCode;
                                "System-Created Entry" := true;
                                "Shortcut Dimension 1 Code" := BankAccPostBuffer."Global Dimension 1 Code";
                                "Shortcut Dimension 2 Code" := BankAccPostBuffer."Global Dimension 2 Code";
                                "Dimension Set ID" :=
                                    CarteraManagement.GetCombinedDimSetID(GenJnlLine, PostedDoc2."Dimension Set Id");
                                OnBeforeGenJournalLineInsert(PostedDoc, GenJnlLine, VATPostingSetup, CustLedgEntry, CustLedgEntry2, PostedBillGr);
                                Insert;
                                SumLCYAmt := SumLCYAmt + "Amount (LCY)";
                                Init;
                                GenJnlLineNextNo := GenJnlLineNextNo + 10000;
                                "Line No." := GenJnlLineNextNo;
                                "Posting Date" := PostingDate;
                                "Document Type" := "Document Type"::Payment;
                                "Document No." := PostedBillGr."No.";
                                "Reason Code" := PostedBillGr."Reason Code";
                                Validate("Account Type", "Account Type"::"G/L Account");
                                Validate("Account No.", CuentaGastos);
                                Description := DescripCionGasto;
                                Validate("Currency Code", PostedBillGr."Currency Code");
                                Validate(Amount, Gastos);
                                "Source Code" := SourceCode;
                                "System-Created Entry" := true;
                                "Shortcut Dimension 1 Code" := BankAccPostBuffer."Global Dimension 1 Code";
                                "Shortcut Dimension 2 Code" := BankAccPostBuffer."Global Dimension 2 Code";
                                "Dimension Set ID" :=
                                    CarteraManagement.GetCombinedDimSetID(GenJnlLine, PostedDoc2."Dimension Set Id");
                                OnBeforeGenJournalLineInsert(PostedDoc, GenJnlLine, VATPostingSetup, CustLedgEntry, CustLedgEntry2, PostedBillGr);
                                Insert;
                                SumLCYAmt := SumLCYAmt + "Amount (LCY)";
                            end;
                        end;
                    end; // ELSE
                         // FactBankAccounting;
                end;//until BankAccPostBuffer.Next() = 0;

                if PostedBillGr.Factoring <> PostedBillGr.Factoring::" " then
                    FactBankAccounting;

                if PostedBillGr."Currency Code" <> '' then begin
                    if SumLCYAmt <> 0 then begin
                        Currency.SetFilter(Code, PostedBillGr."Currency Code");
                        Currency.FindFirst;
                        if SumLCYAmt > 0 then begin
                            Currency.TestField("Residual Gains Account");
                            Acct := Currency."Residual Gains Account";
                        end else begin
                            Currency.TestField("Residual Losses Account");
                            Acct := Currency."Residual Losses Account";
                        end;
                        GenJnlLineNextNo := GenJnlLineNextNo + 10000;
                        with GenJnlLine do begin
                            Clear(GenJnlLine);
                            Init;
                            "Line No." := GenJnlLineNextNo;
                            "Posting Date" := PostingDate;
                            "Document No." := PostedBillGr."No.";
                            "Reason Code" := PostedBillGr."Reason Code";
                            Validate("Account Type", "Account Type"::"G/L Account");
                            Validate("Account No.", Acct);
                            Description := Text1100007;
                            Validate("Currency Code", '');
                            Validate(Amount, -SumLCYAmt);
                            "Source Code" := SourceCode;
                            "System-Created Entry" := true;
                            "Shortcut Dimension 1 Code" := PostedDoc2."Global Dimension 1 Code";
                            "Shortcut Dimension 2 Code" := PostedDoc2."Global Dimension 2 Code";
                            "Dimension Set ID" :=
                            CarteraManagement.GetCombinedDimSetID(GenJnlLine, PostedDoc2."Dimension Set Id");
                            OnBeforeGenJournalLineInsert(PostedDoc, GenJnlLine, VATPostingSetup, CustLedgEntry, CustLedgEntry2, PostedBillGr);
                            Insert;
                        end;
                    end;
                end;
                PostedBillGr.Modify();
                OnBeforePostSettlementForPostedBillGroup(GenJnlLine, PostedBillGr, PostingDate);

                PostSettlementForPostedBillGroup(GenJnlLine, PostingDate);
                OnAfterPostSettlementForPostedBillGroup(GenJnlLine, PostedBillGr, PostingDate);

                Window.Close;

                if ExistVATEntry then begin
                    GLReg.FindLast;
                    GLReg."From VAT Entry No." := FirstVATEntryNo;
                    GLReg."To VAT Entry No." := LastVATEntryNo;
                    GLReg.Modify();
                end;

                Commit();

                COMMIT;
                rDoc.MARKEDONLY := TRUE;
                CustLedgEntry2.RESET;
                //CustLedgEntry2.SETCURRENTKEY(CustLedgEntry2."Nº Factura Borrador");
                if rDoc.FINDFIRST THEN
                    REPEAT
                        if rDoc."No. Borrador factura" <> '' THEN BEGIN
                            CustLedgEntry2.SETRANGE("Nº Factura Borrador", rDoc."No. Borrador factura");
                            CustLedgEntry2.SETRANGE(CustLedgEntry2."Document Type", CustLedgEntry2."Document Type"::Payment);
                            if CustLedgEntry2.FINDFIRST THEN BEGIN
                                rDoc."Remaining Amount" := 0;
                                rDoc."Remaining Amt. (LCY)" := 0;
                                rDoc.Status := rDoc.Status::Honored;
                                rDoc.MODIFY;
                            END else BEGIN
                                rDoc."Remaining Amount" := 0;
                                rDoc."Remaining Amt. (LCY)" := 0;
                                rDoc.Status := rDoc.Status::Honored;
                                rDoc.Place := true;
                                rDoc.MODIFY;

                            end;
                        END;
                    UNTIL rDoc.NEXT = 0;
                //MNC 150999 afegir el if
                // if VieneDeLote THEN
                // MESSAGE(
                // //    '%1 efectos por un total de %2 se han liquidado en el total de remesas registradas.',
                //     Text1100011,                            //FCL-10/03/04. Migración, sustituyo texto.
                //     DocCount,GroupAmount)
                // ELSE
                if not HidePrintDialog then
                    Message(Text1100008, DocCount, GroupAmount);
            end;

            trigger OnPreDataItem()
            begin
                DocPost.CheckPostingDate(PostingDate);

                SourceCodeSetup.Get();
                SourceCode := SourceCodeSetup."Cartera Journal";
                DocCount := 0;
                SumLCYAmt := 0;
                GenJnlLineNextNo := 0;
                ExistVATEntry := false;

                Window.Open(
                  Text1100000);
            end;

        }
    }

    requestpage
    {
        SaveValues = true;

        layout
        {
            area(content)
            {
                group(Options)
                {
                    Caption = 'Opciones';
                    field(PostingDate; PostingDate)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Fecha Registro';
                        NotBlank = true;
                        ToolTip = 'Specifies the posting date.';
                    }
                    field("Cuenta Gastos"; CuentaGastos)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Cuenta Gastos';
                        ToolTip = 'Specifies the account to use for the expenses generated by the operation.';
                        trigger OnLookup(var Text: Text): Boolean
                        var
                            GlAccount: Record "G/L Account";
                        begin
                            if Page.RunModal(Page::"G/L Account List", GlAccount) = Action::LookupOK then
                                CuentaGastos := GlAccount."No.";

                        end;
                    }
                    field(Gastos; Gastos)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Gastos';
                        ToolTip = 'Specifies the expenses generated by the operation.';
                    }
                    field("Descripción Gasto"; DescripcionGasto)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Descripción Gasto';
                        ToolTip = 'Specifies the description of the expenses generated by the operation.';
                    }
                    field(DueOnly; DueOnly)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Solo documentos vencidos';
                        ToolTip = 'Specifies if you want to only include documents that have become overdue. if it does not matter if a document is overdue at the time of settlement, leave this field blank.';
                    }
                }
            }
        }

        actions
        {
        }
    }

    labels
    {
    }

    trigger OnInitReport()
    begin
        PostingDate := WorkDate;
    end;

    trigger OnPreReport()
    begin
        GLSetup.Get();
    end;

    var

        rDoc: record "Posted Cartera Doc.";
        Text1100000: Label 'Liquidar documentos         #1######';
        Text1100001: Label 'Efecto liquidado %1/%2';
        Text1100002: Label 'Documento liquidado %1';
        Text1100003: Label 'No hay documentos de cobro para liquidar.';
        Text1100004: Label 'Por favor revise que la selección no este vacia y al menos un documento de cobro está abierto y no vencido.';
        Text1100005: Label 'Por favor revise que la selección no este vacia y al menos un documento de cobro está abierto.';
        Text1100006: Label 'Remesa liquidada %1';
        Text1100007: Label 'Se ha generado un movimiento de ajuste';
        Text1100008: Label '%1 Documentos de cobros con un total de %2 se han liquidado.';
        Text1100009: Label 'Remesa liquidada %1 Customer No. %2';
        Text1100010: Label 'Documento de cobro liquidado %1/%2';
        SourceCodeSetup: Record "Source Code Setup";
        PostedBillGr: Record "Posted Bill Group";
        GenJnlLine: Record "Gen. Journal Line" temporary;
        CustLedgEntry: Record "Cust. Ledger Entry";
        BankAccPostingGr: Record "Bank Account Posting Group";
        BankAcc: Record "Bank Account";
        Currency: Record Currency;
        GLSetup: Record "General Ledger Setup";
        GLReg: Record "G/L Register";
        VATPostingSetup: Record "VAT Posting Setup";
        BankAccPostBuffer: Record "BG/PO Post. Buffer" temporary;
        NoRealVATBuffer: Record "BG/PO Post. Buffer" temporary;
        DocPost: Codeunit "Document-Post";
        CarteraManagement: Codeunit CarteraManagement;
        GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
        PaymentToleranceMgt: Codeunit "Payment Tolerance Management";
        Window: Dialog;
        PostingDate: Date;
        DueOnly: Boolean;
        Delay: Decimal;
        SourceCode: Code[10];
        Acct: Code[20];
        DocCount: Integer;
        GroupAmount: Decimal;
        GenJnlLineNextNo: Integer;
        SumLCYAmt: Decimal;
        TotalDisctdAmt: Decimal;
        ExistVATEntry: Boolean;
        IsRedrawn: Boolean;
        FirstVATEntryNo: Integer;
        LastVATEntryNo: Integer;
        TempCurrCode: Code[10];
        ExistsNoRealVAT: Boolean;
        HidePrintDialog: Boolean;
        CuentaGastos: Code[20];
        Gastos: Decimal;
        DescripcionGasto: Text[100];




    /// <summary>
    /// DiscFactLiabs.
    /// </summary>
    /// <param name="PostedDoc2">Record "Posted Cartera Doc.".</param>
    //[Scope('OnPrem')]
    procedure DiscFactLiabs(PostedDoc2: Record "Posted Cartera Doc.")
    var
        DisctedAmt: Decimal;
        Currency2: Record Currency;
        RoundingPrec: Decimal;
    begin
        DisctedAmt := 0;
        GenJnlLineNextNo := GenJnlLineNextNo + 10000;

        if PostedDoc2."Currency Code" <> '' then begin
            Currency2.Get(PostedDoc2."Currency Code");
            RoundingPrec := Currency2."Amount Rounding Precision";
        end else
            RoundingPrec := GLSetup."Amount Rounding Precision";

        DisctedAmt := Round(DocPost.FindDisctdAmt(
              PostedDoc2."Remaining Amount",
              PostedDoc2."Account No.",
              PostedDoc2."Bank Account No."), RoundingPrec);

        CalcBankAccount(PostedDoc2."No.", -DisctedAmt, CustLedgEntry."Entry No.");
        TotalDisctdAmt := TotalDisctdAmt + DisctedAmt;

        with GenJnlLine do begin
            Clear(GenJnlLine);
            Init;
            "Line No." := GenJnlLineNextNo;
            "Posting Date" := PostingDate;
            "Document Type" := "Document Type"::Payment;
            "Document No." := PostedBillGr."No.";
            "Reason Code" := PostedBillGr."Reason Code";
            BankAcc.TestField("Bank Acc. Posting Group");
            BankAccPostingGr.Get(BankAcc."Bank Acc. Posting Group");
            Validate("Account Type", "Account Type"::"G/L Account");
            BankAccPostingGr.TestField("Liabs. for Factoring Acc.");
            Validate("Account No.", BankAccPostingGr."Liabs. for Factoring Acc.");
            Description := CopyStr(
                StrSubstNo(Text1100009,
                  PostedBillGr."No.",
                  PostedDoc2."Account No."), 1, MaxStrLen(Description));
            Validate("Currency Code", PostedBillGr."Currency Code");
            Validate(Amount, DisctedAmt);
            "Source Code" := SourceCode;
            "System-Created Entry" := true;
            "Shortcut Dimension 1 Code" := PostedDoc2."Global Dimension 1 Code";
            "Shortcut Dimension 2 Code" := PostedDoc2."Global Dimension 2 Code";
            "Dimension Set ID" := PostedDoc2."Dimension Set ID";
            OnBeforeGenJournalLineInsert(PostedDoc, GenJnlLine, VATPostingSetup, CustLedgEntry, CustLedgEntry, PostedBillGr);
            Insert;
            SumLCYAmt := SumLCYAmt + "Amount (LCY)";
        end;
    end;

    /// <summary>
    /// CloseBillGroupIfEmpty.
    /// </summary>
    /// <param name="PostedBillGroup">Record "Posted Bill Group".</param>
    /// <param name="PostingDate">Date.</param>
    procedure CloseBillGroupIfEmpty(PostedBillGroup: Record "Posted Bill Group"; PostingDate: Date)
    var
        PostedCarteraDoc: Record "Posted Cartera Doc.";
        ClosedCarteraDoc: Record "Closed Cartera Doc.";
        CustLedgEntry: Record "Cust. Ledger Entry";
        ClosedBillGroup: Record "Closed Bill Group";
    begin
        with PostedCarteraDoc do begin
            PostedCarteraDoc.Reset;
            PostedCarteraDoc.SetCurrentKey("Bill Gr./Pmt. Order No.", Status);
            PostedCarteraDoc.SetRange("Bill Gr./Pmt. Order No.", PostedBillGroup."No.");
            PostedCarteraDoc.SetRange(Type, Type::Receivable);
            PostedCarteraDoc.SetRange(Status, Status::Open);
            if not PostedCarteraDoc.Find('-') then begin
                PostedCarteraDoc.SetRange(Status);
                PostedCarteraDoc.Find('-');
                repeat
                    ClosedCarteraDoc.TransferFields(PostedCarteraDoc);
                    ClosedCarteraDoc.Insert();
                    if CustLedgEntry.Get(ClosedCarteraDoc."Entry No.") Then Begin
                        CustLedgEntry."Document Situation" := CustLedgEntry."Document Situation"::"Closed BG/PO";
                        CustLedgEntry.Modify();
                    End;
                until PostedCarteraDoc.Next() = 0;
                PostedCarteraDoc.DeleteAll();
                ClosedBillGroup.TransferFields(PostedBillGroup);
                ClosedBillGroup."Closing Date" := PostingDate;
                ClosedBillGroup.Insert();
                PostedBillGroup.Delete();
            end;
        end;
    end;

    /// <summary>
    /// PostSettlementForPostedBillGroup.
    /// </summary>
    /// <param name="GenJournalLine">VAR Record "Gen. Journal Line".</param>
    /// <param name="PostingDate">Date.</param>
    procedure PostSettlementForPostedBillGroup(var GenJournalLine: Record "Gen. Journal Line"; PostingDate: Date)
    var
        GenJournalLineToPost: Record "Gen. Journal Line";
        PostedBillGroup: Record "Posted Bill Group";
        GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
        UpdateAnalysisView: Codeunit "Update Analysis View";
    begin
        if GenJournalLine.FindSet then
            repeat
                GenJournalLineToPost := GenJournalLine;
                GenJnlPostLine.SetFromSettlement(true);
                GenJnlPostLine.Run(GenJournalLineToPost);
                if PostedBillGroup.Get(GenJournalLine."Document No.") then
                    CloseBillGroupIfEmpty(PostedBillGroup, PostingDate);
            until GenJournalLine.Next() = 0;
        UpdateAnalysisView.UpdateAll(0, true);
    end;

    /// <summary>
    /// FactBankAccounting.
    /// </summary>
    //[Scope('OnPrem')]
    procedure FactBankAccounting()
    var
        CustLedgEntry2: Record "Cust. Ledger Entry";
        Total: Decimal;
    begin
        case true of
            PostedDoc."Dealing Type" = PostedDoc."Dealing Type"::Discount:
                begin

                    if BankAccPostBuffer.FIND('-') THEN
                        REPEAT
                            Total := Total + BankAccPostBuffer.Amount;
                        UNTIL BankAccPostBuffer.NEXT = 0;
                    if BankAccPostBuffer.Find('-') then begin
                        //repeat
                        GenJnlLineNextNo := GenJnlLineNextNo + 10000;
                        CustLedgEntry2.Get(BankAccPostBuffer."Entry No.");
                        with GenJnlLine do begin
                            Clear(GenJnlLine);
                            Init;
                            "Line No." := GenJnlLineNextNo;
                            "Posting Date" := PostingDate;
                            "Document Type" := "Document Type"::Payment;
                            "Document No." := PostedBillGr."No.";
                            "Reason Code" := PostedBillGr."Reason Code";
                            BankAcc.TestField("Bank Acc. Posting Group");
                            BankAccPostingGr.Get(BankAcc."Bank Acc. Posting Group");
                            Validate("Account Type", "Account Type"::"Bank Account");
                            Validate("Account No.", BankAcc."No.");
                            Description := CopyStr(StrSubstNo(Text1100006, PostedBillGr."No."), 1, MaxStrLen(Description));
                            Validate("Currency Code", PostedBillGr."Currency Code");
                            // VALIDATE(Amount,GroupAmount - TotalDisctdAmt);
                            Validate(Amount, Total);
                            "Source Code" := SourceCode;
                            "System-Created Entry" := true;
                            "Shortcut Dimension 1 Code" := BankAccPostBuffer."Global Dimension 1 Code";
                            "Shortcut Dimension 2 Code" := BankAccPostBuffer."Global Dimension 2 Code";
                            "Dimension Set ID" := BankAccPostBuffer."Dimension Set ID";
                            OnBeforeGenJournalLineInsert(PostedDoc, GenJnlLine, VATPostingSetup, CustLedgEntry, CustLedgEntry2, PostedBillGr);
                            Insert;
                            SumLCYAmt := SumLCYAmt + "Amount (LCY)";
                        end;
                        // until BankAccPostBuffer.Next() = 0;
                    end;
                end;
            else begin
                if BankAccPostBuffer.Find('-') then
                    repeat
                        GenJnlLineNextNo := GenJnlLineNextNo + 10000;
                        CustLedgEntry2.Get(BankAccPostBuffer."Entry No.");
                        with GenJnlLine do begin
                            Clear(GenJnlLine);
                            Init;
                            "Line No." := GenJnlLineNextNo;
                            "Posting Date" := PostingDate;
                            "Document Type" := "Document Type"::Payment;
                            "Document No." := PostedBillGr."No.";
                            "Reason Code" := PostedBillGr."Reason Code";
                            BankAcc.TestField("Bank Acc. Posting Group");
                            BankAccPostingGr.Get(BankAcc."Bank Acc. Posting Group");
                            Validate("Account Type", "Account Type"::"Bank Account");
                            Validate("Account No.", BankAcc."No.");
                            Description := CopyStr(StrSubstNo(Text1100006, PostedBillGr."No."), 1, MaxStrLen(Description));
                            Validate("Currency Code", PostedBillGr."Currency Code");
                            Validate(Amount, BankAccPostBuffer.Amount);
                            "Source Code" := SourceCode;
                            "System-Created Entry" := true;
                            "Shortcut Dimension 1 Code" := BankAccPostBuffer."Global Dimension 1 Code";
                            "Shortcut Dimension 2 Code" := BankAccPostBuffer."Global Dimension 2 Code";
                            "Dimension Set ID" := BankAccPostBuffer."Dimension Set ID";
                            OnBeforeGenJournalLineInsert(PostedDoc, GenJnlLine, VATPostingSetup, CustLedgEntry, CustLedgEntry2, PostedBillGr);
                            Insert;
                            SumLCYAmt := SumLCYAmt + "Amount (LCY)";
                        end;
                    until BankAccPostBuffer.Next() = 0;
            end;
        end;
    end;

    local procedure InsertGenJournalLine(AccType: enum "Gen. Journal Account Type"; AccNo: Code[20];
                                                      Amount2: Decimal;
                                                      Dep: Code[20];
                                                      Proj: Code[20];
                                                      DimSetID: Integer)
    begin
        GenJnlLineNextNo := GenJnlLineNextNo + 10000;

        Clear(GenJnlLine);
        GenJnlLine.Init;
        GenJnlLine."Line No." := GenJnlLineNextNo;
        GenJnlLine."Posting Date" := PostingDate;
        GenJnlLine."Document Type" := GenJnlLine."Document Type"::Payment;
        GenJnlLine."Document No." := PostedBillGr."No.";
        GenJnlLine."Reason Code" := PostedBillGr."Reason Code";
        GenJnlLine."Account Type" := AccType;
        GenJnlLine."Account No." := AccNo;
        GenJnlLine.Description := CopyStr(
        StrSubstNo(Text1100010, PostedDoc."Document No.", PostedDoc."No."),
        1, MaxStrLen(GenJnlLine.Description));
        GenJnlLine.Validate("Currency Code", PostedDoc."Currency Code");
        GenJnlLine.Validate(Amount, -Amount2);
        GenJnlLine."Applies-to Doc. Type" := CustLedgEntry."Document Type";
        GenJnlLine."Applies-to Doc. No." := '';
        GenJnlLine."Applies-to Bill No." := CustLedgEntry."Bill No.";
        GenJnlLine."Source Code" := SourceCode;
        GenJnlLine."System-Created Entry" := true;
        GenJnlLine."Shortcut Dimension 1 Code" := Dep;
        GenJnlLine."Shortcut Dimension 2 Code" := Proj;
        GenJnlLine."Dimension Set ID" := DimSetID;
        SumLCYAmt := SumLCYAmt + GenJnlLine."Amount (LCY)";
        OnBeforeGenJournalLineInsert(PostedDoc, GenJnlLine, VATPostingSetup, CustLedgEntry, CustLedgEntry, PostedBillGr);
        GenJnlLine.Insert;

    end;

    //[Scope('OnPrem')]
    procedure CalcBankAccount(BankAcc2: Code[20]; Amount2: Decimal; EntryNo: Integer)
    var
        IsHandled: Boolean;
    begin
        OnBeforeCalcBankAccount(BankAcc2, Amount2, EntryNo, BankAccPostBuffer, IsHandled);
        if IsHandled then
            exit;

        if BankAccPostBuffer.Get(BankAcc2, '', EntryNo) then begin
            BankAccPostBuffer.Amount := BankAccPostBuffer.Amount + Amount2;
            BankAccPostBuffer.Modify();
        end else begin
            BankAccPostBuffer.Init();
            BankAccPostBuffer.Account := BankAcc2;
            BankAccPostBuffer.Amount := Amount2;
            BankAccPostBuffer."Entry No." := EntryNo;
            BankAccPostBuffer."Global Dimension 1 Code" := CustLedgEntry."Global Dimension 1 Code";
            BankAccPostBuffer."Global Dimension 2 Code" := CustLedgEntry."Global Dimension 2 Code";
            BankAccPostBuffer.Insert();
        end;
    end;

    procedure SetHidePrintDialog(NewHidePrintDialog: Boolean)
    begin
        HidePrintDialog := NewHidePrintDialog;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterGetPostedDocOnBeforeValidateAccountNo(var GenJournalLine: Record "Gen. Journal Line"; var PostedCarteraDoc: Record "Posted Cartera Doc."; var VATPostingSetup: Record "VAT Posting Setup"; var CustLedgerEntry: Record "Cust. Ledger Entry"; var FromJnl: Boolean; var ExistsNoRealVAT: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterPostSettlementForPostedBillGroup(var GenJournalLine: Record "Gen. Journal Line"; PostedBillGroup: Record "Posted Bill Group"; PostingDate: Date)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCalcBankAccount(BankAcc2: Code[20]; Amount2: Decimal; EntryNo: Integer; var BgPoPostBuffer: Record "BG/PO Post. Buffer"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCustUnrealizedVAT2(var PostedCarteraDoc: Record "Posted Cartera Doc."; var GenJournalLine: Record "Gen. Journal Line"; var CustLedgerEntry: Record "Cust. Ledger Entry"; var PostedBillGroup: Record "Posted Bill Group"; var BgPoPostBuffer: Record "BG/PO Post. Buffer")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeGenJournalLineInsert(var PostedCarteraDoc: Record "Posted Cartera Doc."; var GenJournalLine: Record "Gen. Journal Line"; var VATPostingSetup: Record "VAT Posting Setup"; var CustLedgerEntry: Record "Cust. Ledger Entry"; var CustLedgerEntry2: Record "Cust. Ledger Entry"; var PostedBillGroup: Record "Posted Bill Group")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforePostSettlementForPostedBillGroup(var GenJournalLine: Record "Gen. Journal Line"; PostedBillGroup: Record "Posted Bill Group"; PostingDate: Date)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnPostDataItemOnBeforeBankAccPostBufferLoop(var BankAccPostBuffer: Record "BG/PO Post. Buffer" temporary; PostedDoc: Record "Posted Cartera Doc."; PostedBillGr: Record "Posted Bill Group"; var GenJnlLine: Record "Gen. Journal Line"; var GenJnlLineNextNo: Integer; var SumLCYAmt: Decimal; PostingDate: Date; SourceCode: Code[10]; var IsHandled: Boolean)
    begin
    end;
}



