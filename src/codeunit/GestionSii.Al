/// <summary>
/// Codeunit GestionSii (ID 7001102).
/// </summary>
codeunit 7001102 GestionSii
{
    PROCEDURE UpdateFieldsSIIVentas(VAR SalesHeader: Record 36): Boolean
    VAR
        GLSetup: Record "General Ledger Setup";
    BEGIN
        // WITH SalesHeader DO BEGIN
        //-SII1
        GLSetup.GET;
        if NOT GLSetup."Activar SII" THEN
            EXIT;
        // Si ya están informados no volver a informarlos..
        if (SalesHeader."Tipo factura SII" <> '') AND (SalesHeader."Descripción operación" <> '') THEN
            EXIT;
        SalesHeader."Tipo factura SII" := 'F1';
        if SalesHeader."Document Type" IN [SalesHeader."Document Type"::"Credit Memo", SalesHeader."Document Type"::"Return Order"] THEN BEGIN
            SalesHeader."Tipo factura rectificativa" := 'I';
        END;
        SalesHeader."Descripción operación" := SalesHeader."Posting Description";
        EXIT(TRUE);
        //+SII1
        // END;
    END;

    PROCEDURE UpdateFieldsSIICompras(VAR PurchaseHeader: Record 38): Boolean
    VAR
        GlSetup: Record "General Ledger Setup";
    BEGIN

        //-SII1
        GlSetup.GET;
        if NOT GlSetup."Activar SII" THEN
            EXIT;
        // Si ya están informados no volver a informarlos..
        //if ("Tipo factura SII" <> '') AND ("Descripción operación" <> '') THEN
        //EXIT;
        PurchaseHeader."Tipo factura SII" := 'F1';
        if PurchaseHeader."Document Type" IN [PurchaseHeader."Document Type"::"Credit Memo", PurchaseHeader."Document Type"::"Return Order"] THEN BEGIN
            PurchaseHeader."Tipo factura rectificativa" := 'I';
        END;
        PurchaseHeader."Descripción operación" := PurchaseHeader."Posting Description";
        EXIT(TRUE);
        //+SII1

    END;

    [EventSubscriber(ObjectType::Table, 36, 'OnAfterInsertEvent', '', false, false)]
    PROCEDURE Tabla36_OnInsert(VAR Rec: Record 36; RunTrigger: Boolean)
    VAR
        SalesSetup: Record 311;
    BEGIN
        //WITH Rec DO BEGIN
        //$004(I)
        SalesSetup.Get();
        SalesSetup.TESTFIELD("Forma pago prepago");
        Rec."Forma pago prepago" := SalesSetup."Forma pago prepago";
        Rec."Fecha registro prepago" := WORKDATE;
        //$004(F)
        //-SII
        UpdateFieldsSII_36(Rec);
        //+SII
        //END;
    END;

    [EventSubscriber(ObjectType::Table, 38, 'OnAfterInsertEvent', '', false, false)]
    PROCEDURE Tabla38_OnInsert(VAR Rec: Record 38; RunTrigger: Boolean)
    VAR
        SalesSetup: Record 311;
    BEGIN
        //WITH Rec DO BEGIN
        //$004(I)
        //$004(F)
        //-SII
        UpdateFieldsSII_38(Rec);
        //+SII
        //END;
    END;

    PROCEDURE UpdateFieldsSII_36(VAR Rec: Record 36): Boolean
    VAR
        GlSetup: Record "General Ledger Setup";
    BEGIN
        //WITH Rec DO BEGIN
        //-SII1
        GlSetup.GET;
        if NOT GlSetup."Activar SII" THEN
            EXIT;
        // Si ya están informados no volver a informarlos..
        if (Rec."Tipo factura SII" <> '') AND (Rec."Descripción operación" <> '') THEN
            EXIT;
        Rec."Tipo factura SII" := 'F1';
        if Rec."Document Type" IN [Rec."Document Type"::"Credit Memo", Rec."Document Type"::"Return Order"] THEN BEGIN
            Rec."Tipo factura rectificativa" := 'I';
        END;
        Rec."Descripción operación" := Rec."Posting Description";
        EXIT(TRUE);
        //+SII1
        //END;
    END;

    [EventSubscriber(ObjectType::Table, 36, 'OnAfterValidateEvent', 'Corrected Invoice No.', false, false)]
    LOCAL PROCEDURE Tabla36_CorrectInvoiceNoOnValidate(VAR Rec: Record 36; VAR xRec: Record 36; CurrFieldNo: Integer)
    VAR
        GeneralLedgerSetup: Record "General Ledger Setup";
    BEGIN
        //  WITH Rec DO BEGIN

        //-SII1
        GeneralLedgerSetup.GET;
        //+SII1
        if Rec."Corrected Invoice No." <> '' THEN BEGIN
            //-SII
            if GeneralLedgerSetup."Activar SII" THEN
                //-SII1
                if Rec."Document Type" IN [Rec."Document Type"::Invoice, Rec."Document Type"::Order] THEN BEGIN
                    //"Tipo factura SII" := '4';
                    Rec."Tipo factura SII" := 'R1';
                    Rec."Tipo factura rectificativa" := 'S';
                END;
            //+SII1
            //+SII
        END;
        //-SII1
        if Rec."Corrected Invoice No." = '' THEN BEGIN
            if GeneralLedgerSetup."Activar SII" THEN BEGIN
                if Rec."Document Type" IN [Rec."Document Type"::Invoice, Rec."Document Type"::Order] THEN BEGIN
                    Rec."Tipo factura SII" := 'F1';
                    Rec."Tipo factura rectificativa" := '';
                END;
                if Rec."Document Type" IN [Rec."Document Type"::"Credit Memo", Rec."Document Type"::"Return Order"] THEN BEGIN
                    Rec."Tipo factura SII" := 'F1';
                    Rec."Tipo factura rectificativa" := 'I';
                END;
            END;
        END;
        //+SII1
        //  END;
    END;

    PROCEDURE UpdateFieldsSII_38(VAR Rec: Record 38): Boolean
    VAR
        GLSetup: Record "General Ledger Setup";
    BEGIN

        //-SII1
        GLSetup.GET;
        if NOT GLSetup."Activar SII" THEN
            EXIT;
        // Si ya están informados no volver a informarlos..
        //if ("Tipo factura SII" <> '') AND ("Descripción operación" <> '') THEN
        //EXIT;
        Rec."Tipo factura SII" := 'F1';
        if Rec."Document Type" IN [Rec."Document Type"::"Credit Memo", Rec."Document Type"::"Return Order"] THEN BEGIN
            Rec."Tipo factura rectificativa" := 'I';
        END;
        Rec."Descripción operación" := Rec."Posting Description";
        EXIT(TRUE);
        //+SII1
    END;

    internal procedure CreatePayMent(Var Rec: Record "Vendor Ledger Entry")
    var
        GenJnlLine: Record "Gen. Journal Line";
        GestiónSII: Report "Gestión SII";
        VatIva: Record "VAT Entry";
    begin
        VatIva.SetRange("Bill-to/Pay-to No.", Rec."Vendor No.");
        VatIva.SetRange("External Document No.", Rec."Applies-to Ext. Doc. No.");
        VatIva.FindFirst();
        GenJnlLine.Init;
        GenJnlLine."Document Type" := Rec."Document Type";
        GenJnlLine."Document No." := Rec."Document No.";
        GenJnlLine."Account Type" := GenJnlLine."Account Type"::Vendor;
        GenJnlLine."Account No." := Rec."Vendor No.";
        GenJnlLine."VAT Bus. Posting Group" := VatIva."VAT Bus. Posting Group";
        GenJnlLine."VAT Prod. Posting Group" := VatIva."VAT Prod. Posting Group";
        GenJnlLine."Posting Date" := Rec."Posting Date";
        GenJnlLine."Document Date" := Rec."Document Date";
        Rec.CalcFields(Amount, "Amount (LCY)");
        GenJnlLine.Amount := Rec.Amount;
        GenJnlLine."Amount (LCY)" := Rec."Amount (LCY)";
        if GenJnlLine."Document Type" IN [GenJnlLine."Document Type"::"Credit Memo", GenJnlLine."Document Type"::Invoice, GenJnlLine."Document Type"::Payment, GenJnlLine."Document Type"::Bill] THEN BEGIN
            if GenJnlLine."VAT Bus. Posting Group" <> '' THEN
                GestiónSII.CreateOrUpdateFileGenJnlLine(GenJnlLine, GenJnlLine."VAT Bus. Posting Group", GenJnlLine."VAT Prod. Posting Group");
            if GenJnlLine."Bal. VAT Bus. Posting Group" <> '' THEN
                GestiónSII.CreateOrUpdateFileGenJnlLine(GenJnlLine, GenJnlLine."Bal. VAT Bus. Posting Group", GenJnlLine."Bal. VAT Prod. Posting Group");
            if GenJnlLine."Document Type" IN [GenJnlLine."Document Type"::Payment, GenJnlLine."Document Type"::Bill] THEN
                GestiónSII.CreateOrUpdateFileGenJnlLine(GenJnlLine, '', '');
        END;

    end;

    [EventSubscriber(Objecttype::Codeunit, Codeunit::"Sales-Post", 'OnBeforePostSalesDoc', '', false, false)]
    LOCAL PROCEDURE Codeunit80_OnRun(VAR Sender: Codeunit "Sales-Post"; VAR SalesHeader: Record 36; CommitIsSuppressed: Boolean; PreviewMode: Boolean)
    VAR
        GestionSII: Report "Gestión SII";
        GLSetup: Record "General Ledger Setup";
        rLinDetFra: Record 44;
        rLinDetFraDef: Record 44;
    BEGIN

        //-SII
        CLEAR(GestionSII);
        //+SII
        //-SII
        GLSetup.GET;
        if GLSetup."Activar SII" THEN BEGIN
            if SalesHeader."Tipo factura SII" = '' THEN
                SalesHeader."Tipo factura SII" := 'F1';
            if (SalesHeader."Document Type" = SalesHeader."Document Type"::"Credit Memo") OR (SalesHeader."Document Type" = SalesHeader."Document Type"::"Return Order") THEN
                SalesHeader."Tipo factura SII" := '4';
            if SalesHeader."Descripción operación" = '' THEN
                SalesHeader."Descripción operación" := SalesHeader."Posting Description";
        END;
        //+SII

        if SalesHeader."Esperar Orden Cliente" <> SalesHeader."Esperar Orden Cliente"::No THEN ERROR('Está marcado el campo Esperar orden Cliente');
        //ASC Lineas de Impresion
        rLinDetFra.SETRANGE("Document Type", rLinDetFra."Document Type"::"Detalle Factura");
        rLinDetFra.SETRANGE("No.", SalesHeader."No.");
        rLinDetFra.SETRANGE(rLinDetFra.Validada, FALSE);
        if rLinDetFra.FINDFIRST THEN ERROR('Hay líneas de impresión sin validar');

        if COMPANYNAME <> 'UNION AGRICOLA Y TURISTICA, SL' THEN
            SalesHeader.TESTFIELD("VAT Registration No.");
        if SalesHeader."Pedido standard" then exit;
        if SalesHeader."Albarán Empresa Origen" = '' THEN
            SalesHeader.TESTFIELD("Nº Proyecto");                                //MNC001
    END;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnAfterGLFinishPosting', '', false, false)]
    local procedure OnAfterGLFinishPosting(GLEntry: Record "G/L Entry"; var GenJnlLine: Record "Gen. Journal Line"; IsTransactionConsistent: Boolean; FirstTransactionNo: Integer; var GLRegister: Record "G/L Register"; var TempGLEntryBuf: Record "G/L Entry" temporary; var NextEntryNo: Integer; var NextTransactionNo: Integer)
    var
        GLSetup: Record "General Ledger Setup";
        GestiónSII: Report "Gestión SII";
    begin
        GLSetup.Get();
        //-SII
        if GLSetup."Activar SII" THEN
            if NOT GenJnlLine."System-Created Entry" THEN BEGIN
                //-SII1
                if NOT GenJnlLine."Obviar SII" THEN BEGIN
                    //+SII1
                    if GenJnlLine."Document Type" IN [GenJnlLine."Document Type"::"Credit Memo", GenJnlLine."Document Type"::Invoice, GenJnlLine."Document Type"::Payment, GenJnlLine."Document Type"::Bill] THEN BEGIN
                        if GenJnlLine."VAT Bus. Posting Group" <> '' THEN
                            GestiónSII.CreateOrUpdateFileGenJnlLine(GenJnlLine, GenJnlLine."VAT Bus. Posting Group", GenJnlLine."VAT Prod. Posting Group");
                        if GenJnlLine."Bal. VAT Bus. Posting Group" <> '' THEN
                            GestiónSII.CreateOrUpdateFileGenJnlLine(GenJnlLine, GenJnlLine."Bal. VAT Bus. Posting Group", GenJnlLine."Bal. VAT Prod. Posting Group");
                        if GenJnlLine."Document Type" IN [GenJnlLine."Document Type"::Payment, GenJnlLine."Document Type"::Bill] THEN
                            GestiónSII.CreateOrUpdateFileGenJnlLine(GenJnlLine, '', '');
                    END;
                    //-SII1
                END;
                //+SII1
            END;
        //+SII
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnAfterInitVAT', '', false, false)]
    local procedure OnAfterInitVAT(var GenJournalLine: Record "Gen. Journal Line"; var GLEntry: Record "G/L Entry"; var VATPostingSetup: Record "VAT Posting Setup"; var AddCurrGLEntryVATAmt: Decimal)
    var
        GLSetup: Record "General Ledger Setup";
    begin
        GLSetup.Get();
        //-SII
        if GLSetup."Activar SII" THEN BEGIN
            //-SII1
            //GLEntry."Tipo desglose emitidas" := VATPostingSetup."Tipo desglose emitidas";
            if GenJournalLine."Clave registro SII expedidas" <> '' THEN
                GLEntry."Tipo desglose emitidas" := VATPostingSetup."Tipo desglose emitidas";
            if GenJournalLine."Clave registro SII recibidas" <> '' THEN
                GLEntry."Tipo desglose recibidas" := VATPostingSetup."Tipo desglose recibidas";
            //+SII1
            GLEntry."Sujeta exenta" := VATPostingSetup."Sujeta exenta";
            GLEntry."Tipo de operación" := VATPostingSetup."Tipo de operación";
            GLEntry."Tipo factura SII" := GenJournalLine."Tipo factura SII";
            GLEntry."Clave registro SII expedidas" := GenJournalLine."Clave registro SII expedidas";
            GLEntry."Clave registro SII recibidas" := GenJournalLine."Clave registro SII recibidas";
            GLEntry."Descripción operación" := GenJournalLine."Descripción operación";
            GLEntry."Tipo factura rectificativa" := GenJournalLine."Tipo factura rectificativa";
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnInsertVATOnAfterAssignVATEntryFields', '', false, false)]
    local procedure OnInsertVATOnAfterAssignVATEntryFields(GenJnlLine: Record "Gen. Journal Line"; var VATEntry: Record "VAT Entry"; CurrExchRate: Record "Currency Exchange Rate")
    var
        GLSetup: Record "General Ledger Setup";
        VATPostingSetup: Record "VAT Posting Setup";
    begin
        //-SII
        if GLSetup."Activar SII" THEN BEGIN
            VATEntry."Tipo factura SII" := GenJnlLine."Tipo factura SII";
            VATEntry."Clave registro SII expedidas" := GenJnlLine."Clave registro SII expedidas";
            VATEntry."Clave registro SII recibidas" := GenJnlLine."Clave registro SII recibidas";
            VATEntry."Descripción operación" := GenJnlLine."Descripción operación";
            if not VATPostingSetup.Get(VATEntry."VAT Bus. Posting Group", VATEntry."VAT Prod. Posting Group") then VATPostingSetup.Init();
            //-SII1
            //VATEntry."Tipo desglose emitidas" := VATPostingSetup."Tipo desglose emitidas";
            if GenJnlLine."Clave registro SII expedidas" <> '' THEN
                VATEntry."Tipo desglose emitidas" := VATPostingSetup."Tipo desglose emitidas";
            if GenJnlLine."Clave registro SII recibidas" <> '' THEN
                VATEntry."Tipo desglose recibidas" := VATPostingSetup."Tipo desglose recibidas";
            //+SII1
            VATEntry."Sujeta exenta" := VATPostingSetup."Sujeta exenta";
            VATEntry."Tipo de operación" := VATPostingSetup."Tipo de operación";
            VATEntry."Tipo factura rectificativa" := GenJnlLine."Tipo factura rectificativa";
        END;
        //+SII
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnBeforeInsertGLEntryBuffer', '', false, false)]
    local procedure OnBeforeInsertGLEntryBuffer(var TempGLEntryBuf: Record "G/L Entry" temporary; var GenJournalLine: Record "Gen. Journal Line"; var BalanceCheckAmount: Decimal; var BalanceCheckAmount2: Decimal; var BalanceCheckAddCurrAmount: Decimal; var BalanceCheckAddCurrAmount2: Decimal;
   var NextEntryNo: Integer; var TotalAmount: Decimal; var TotalAddCurrAmount: Decimal)
    var
        GLSetup: Record "General Ledger Setup";
        VATPostingSetup: Record "VAT Posting Setup";
    begin
        //-SII
        GLSetup.Get();
        if GLSetup."Activar SII" THEN BEGIN
            //SII1
            //WITH TempGLEntryBuf DO BEGIN
            if NOT VATPostingSetup.GET(GenJournalLine."VAT Bus. Posting Group", GenJournalLine."VAT Prod. Posting Group") THEN BEGIN
                TempGLEntryBuf."Tipo factura SII" := GenJournalLine."Tipo factura SII";
                TempGLEntryBuf."Clave registro SII expedidas" := GenJournalLine."Clave registro SII expedidas";
                TempGLEntryBuf."Clave registro SII recibidas" := GenJournalLine."Clave registro SII recibidas";
                TempGLEntryBuf."Descripción operación" := GenJournalLine."Descripción operación";
                TempGLEntryBuf."Tipo desglose emitidas" := GenJournalLine."Tipo desglose emitidas";
                TempGLEntryBuf."Tipo desglose recibidas" := GenJournalLine."Tipo desglose recibidas";
                TempGLEntryBuf."Sujeta exenta" := GenJournalLine."Sujeta exenta";
                TempGLEntryBuf."Tipo de operación" := GenJournalLine."Tipo de operación";
                TempGLEntryBuf."Tipo factura rectificativa" := GenJournalLine."Tipo factura rectificativa";
            END ELSE BEGIN
                //SII1
                TempGLEntryBuf."Tipo factura SII" := GenJournalLine."Tipo factura SII";
                TempGLEntryBuf."Clave registro SII expedidas" := GenJournalLine."Clave registro SII expedidas";
                TempGLEntryBuf."Clave registro SII recibidas" := GenJournalLine."Clave registro SII recibidas";
                TempGLEntryBuf."Descripción operación" := GenJournalLine."Descripción operación";
                // {"Tipo desglose" := VATPostingSetup."Tipo desglose";
                // "Sujeta exenta" := VATPostingSetup."Sujeta exenta";
                // "Tipo de operación" := VATPostingSetup."Tipo de operación";}
                //-SII1
                //if VATPostingSetup."Tipo desglose emitidas" = '' THEN BEGIN
                //  "Tipo desglose emitidas" := GenJnlLine."Tipo desglose emitidas";
                //  "Sujeta exenta" := GenJnlLine."Sujeta exenta";
                //  "Tipo de operación" := GenJnlLine."Tipo de operación";
                //END ELSE BEGIN
                //  "Tipo desglose emitidas" := VATPostingSetup."Tipo desglose emitidas";
                //  "Sujeta exenta" := VATPostingSetup."Sujeta exenta";
                //  "Tipo de operación" := VATPostingSetup."Tipo de operación";
                //END;
                if GenJournalLine."Clave registro SII expedidas" <> '' THEN
                    if VATPostingSetup."Tipo desglose emitidas" = '' THEN BEGIN
                        TempGLEntryBuf."Tipo desglose emitidas" := GenJournalLine."Tipo desglose emitidas";
                        TempGLEntryBuf."Sujeta exenta" := GenJournalLine."Sujeta exenta";
                        TempGLEntryBuf."Tipo de operación" := GenJournalLine."Tipo de operación";
                    END ELSE BEGIN
                        TempGLEntryBuf."Tipo desglose emitidas" := VATPostingSetup."Tipo desglose emitidas";
                        TempGLEntryBuf."Sujeta exenta" := VATPostingSetup."Sujeta exenta";
                        TempGLEntryBuf."Tipo de operación" := VATPostingSetup."Tipo de operación";
                    END;
                if GenJournalLine."Clave registro SII recibidas" <> '' THEN
                    if VATPostingSetup."Tipo desglose recibidas" = '' THEN BEGIN
                        TempGLEntryBuf."Tipo desglose recibidas" := GenJournalLine."Tipo desglose recibidas";
                        TempGLEntryBuf."Sujeta exenta" := GenJournalLine."Sujeta exenta";
                        TempGLEntryBuf."Tipo de operación" := GenJournalLine."Tipo de operación";
                    END ELSE BEGIN
                        TempGLEntryBuf."Tipo desglose recibidas" := VATPostingSetup."Tipo desglose recibidas";
                        TempGLEntryBuf."Sujeta exenta" := VATPostingSetup."Sujeta exenta";
                        TempGLEntryBuf."Tipo de operación" := VATPostingSetup."Tipo de operación";
                    END;
                //+SII1
                TempGLEntryBuf."Tipo factura rectificativa" := GenJournalLine."Tipo factura rectificativa";
            END;

            //end;
            //WITH GLEntry DO BEGIN
            if NOT VATPostingSetup.GET(GenJournalLine."VAT Bus. Posting Group", GenJournalLine."VAT Prod. Posting Group") THEN BEGIN
                TempGLEntryBuf."Tipo factura SII" := GenJournalLine."Tipo factura SII";
                TempGLEntryBuf."Clave registro SII expedidas" := GenJournalLine."Clave registro SII expedidas";
                TempGLEntryBuf."Clave registro SII recibidas" := GenJournalLine."Clave registro SII recibidas";
                TempGLEntryBuf."Descripción operación" := GenJournalLine."Descripción operación";
                TempGLEntryBuf."Tipo desglose emitidas" := GenJournalLine."Tipo desglose emitidas";
                TempGLEntryBuf."Tipo desglose recibidas" := GenJournalLine."Tipo desglose recibidas";
                TempGLEntryBuf."Sujeta exenta" := GenJournalLine."Sujeta exenta";
                TempGLEntryBuf."Tipo de operación" := GenJournalLine."Tipo de operación";
                TempGLEntryBuf."Tipo factura rectificativa" := GenJournalLine."Tipo factura rectificativa";
            END ELSE BEGIN
                //SII1
                TempGLEntryBuf."Tipo factura SII" := GenJournalLine."Tipo factura SII";
                TempGLEntryBuf."Clave registro SII expedidas" := GenJournalLine."Clave registro SII expedidas";
                TempGLEntryBuf."Clave registro SII recibidas" := GenJournalLine."Clave registro SII recibidas";
                TempGLEntryBuf."Descripción operación" := GenJournalLine."Descripción operación";
                // {"Tipo desglose" := VATPostingSetup."Tipo desglose";
                // "Sujeta exenta" := VATPostingSetup."Sujeta exenta";
                // "Tipo de operación" := VATPostingSetup."Tipo de operación";}
                //-SII1
                //if VATPostingSetup."Tipo desglose emitidas" = '' THEN BEGIN
                //  "Tipo desglose emitidas" := GenJnlLine."Tipo desglose emitidas";
                //  "Sujeta exenta" := GenJnlLine."Sujeta exenta";
                //  "Tipo de operación" := GenJnlLine."Tipo de operación";
                //END ELSE BEGIN
                //  "Tipo desglose emitidas" := VATPostingSetup."Tipo desglose emitidas";
                //  "Sujeta exenta" := VATPostingSetup."Sujeta exenta";
                //  "Tipo de operación" := VATPostingSetup."Tipo de operación";
                //END;
                if GenJournalLine."Clave registro SII expedidas" <> '' THEN
                    if VATPostingSetup."Tipo desglose emitidas" = '' THEN BEGIN
                        TempGLEntryBuf."Tipo desglose emitidas" := GenJournalLine."Tipo desglose emitidas";
                        TempGLEntryBuf."Sujeta exenta" := GenJournalLine."Sujeta exenta";
                        TempGLEntryBuf."Tipo de operación" := GenJournalLine."Tipo de operación";
                    END ELSE BEGIN
                        TempGLEntryBuf."Tipo desglose emitidas" := VATPostingSetup."Tipo desglose emitidas";
                        TempGLEntryBuf."Sujeta exenta" := VATPostingSetup."Sujeta exenta";
                        TempGLEntryBuf."Tipo de operación" := VATPostingSetup."Tipo de operación";
                    END;
                if GenJournalLine."Clave registro SII recibidas" <> '' THEN
                    if VATPostingSetup."Tipo desglose recibidas" = '' THEN BEGIN
                        TempGLEntryBuf."Tipo desglose recibidas" := GenJournalLine."Tipo desglose recibidas";
                        TempGLEntryBuf."Sujeta exenta" := GenJournalLine."Sujeta exenta";
                        TempGLEntryBuf."Tipo de operación" := GenJournalLine."Tipo de operación";
                    END ELSE BEGIN
                        TempGLEntryBuf."Tipo desglose recibidas" := VATPostingSetup."Tipo desglose recibidas";
                        TempGLEntryBuf."Sujeta exenta" := VATPostingSetup."Sujeta exenta";
                        TempGLEntryBuf."Tipo de operación" := VATPostingSetup."Tipo de operación";
                    END;
                //+SII1
                TempGLEntryBuf."Tipo factura rectificativa" := GenJournalLine."Tipo factura rectificativa";
            END;

            //end;
        END;
        //+SII
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnBeforeInsertTempVATEntry', '', false, false)]
    local procedure OnBeforeInsertTempVATEntry(var TempVATEntry: Record "VAT Entry" temporary; GenJournalLine: Record "Gen. Journal Line"; VATEntry: Record "VAT Entry")
    var
        GlSetup: Record "General Ledger Setup";
        VATPostingSetup: Record "VAT Posting Setup";
        VATBusPostGrp: Record "VAT Business Posting Group";
    begin
        //-SII
        GLSetup.Get();
        //-SII
        if GLSetup."Activar SII" THEN BEGIN
            if VATBusPostGrp.GET(GenJournalLine."VAT Bus. Posting Group") THEN;
            if VATPostingSetup.GET(GenJournalLine."VAT Bus. Posting Group", GenJournalLine."VAT Prod. Posting Group") THEN;
            TempVATEntry."Tipo factura SII" := GenJournalLine."Tipo factura SII";
            //-SII1
            //TempVATEntry."Clave registro SII expedidas" := VATBusPostGrp."Clave registro SII expedidas";
            //TempVATEntry."Tipo desglose emitidas" := VATPostingSetup."Tipo desglose emitidas";
            if GenJournalLine."Gen. Posting Type" = GenJournalLine."Gen. Posting Type"::Sale THEN BEGIN
                TempVATEntry."Clave registro SII expedidas" := VATBusPostGrp."Clave registro SII expedidas";
                TempVATEntry."Tipo desglose emitidas" := VATPostingSetup."Tipo desglose emitidas";
            END ELSE
                if GenJournalLine."Gen. Posting Type" = GenJournalLine."Gen. Posting Type"::Purchase THEN BEGIN
                    TempVATEntry."Clave registro SII recibidas" := VATBusPostGrp."Clave registro SII recibidas";
                    TempVATEntry."Tipo desglose recibidas" := VATPostingSetup."Tipo desglose recibidas";
                END;
            //+SII1
            TempVATEntry."Descripción operación" := GenJournalLine."Descripción operación";
            TempVATEntry."Sujeta exenta" := VATPostingSetup."Sujeta exenta";
            TempVATEntry."Tipo de operación" := VATPostingSetup."Tipo de operación";
            TempVATEntry."Tipo factura rectificativa" := GenJournalLine."Tipo factura rectificativa";
        END;
        //+SII
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnBeforeInsertPostUnrealVATEntry', '', false, false)]
    local procedure OnBeforeInsertPostUnrealVATEntry(var VATEntry: Record "VAT Entry"; GenJournalLine: Record "Gen. Journal Line"; var VATEntry2: Record "VAT Entry")
    var
        GlSetup: Record "General Ledger Setup";
        VATPostingSetup: Record "VAT Posting Setup";
        VATBusPostGrp: Record "VAT Business Posting Group";
    begin
        //-SII
        GLSetup.Get();
        if NOT (GenJournalLine."Document Type" IN [GenJournalLine."Document Type"::Bill, GenJournalLine."Document Type"::Payment]) THEN
            if GLSetup."Activar SII" THEN BEGIN
                if VATBusPostGrp.GET(GenJournalLine."VAT Bus. Posting Group") THEN;
                if VATPostingSetup.GET(GenJournalLine."VAT Prod. Posting Group") THEN;
                VATEntry2."Tipo factura SII" := GenJournalLine."Tipo factura SII";
                //-SII1
                //VATEntry."Clave registro SII expedidas" := GenJnlLine."Clave registro SII expedidas";
                //VATEntry."Clave registro SII recibidas" := GenJnlLine."Clave registro SII recibidas";
                //VATEntry."Descripción operación" := GenJnlLine."Descripción operación";
                //VATEntry."Tipo desglose emitidas" := VATPostingSetup."Tipo desglose emitidas";
                if GenJournalLine."Clave registro SII expedidas" <> '' THEN BEGIN
                    VATEntry."Clave registro SII expedidas" := GenJournalLine."Clave registro SII expedidas";
                    VATEntry."Tipo desglose emitidas" := VATPostingSetup."Tipo desglose emitidas";
                END;
                if GenJournalLine."Clave registro SII recibidas" <> '' THEN BEGIN
                    VATEntry."Clave registro SII recibidas" := GenJournalLine."Clave registro SII recibidas";
                    VATEntry."Tipo desglose recibidas" := VATPostingSetup."Tipo desglose recibidas";
                END;
                VATEntry."Descripción operación" := GenJournalLine."Descripción operación";
                //+SII1
                VATEntry."Sujeta exenta" := VATPostingSetup."Sujeta exenta";
                VATEntry."Tipo de operación" := VATPostingSetup."Tipo de operación";
                VATEntry."Tipo factura rectificativa" := GenJournalLine."Tipo factura rectificativa";
            END;
        //+SII

    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Check Line", 'OnBeforeRunCheck', '', false, false)]
    local procedure OnBeforeRunCheck(var GenJournalLine: Record "Gen. Journal Line")
    var
        GlSetup: Record "General Ledger Setup";
        VATPostingSetup: Record "VAT Posting Setup";
        VATBusPostGrp: Record "VAT Business Posting Group";
        GestiónSII: Report "Gestión SII";
    begin
        //-SII
        GLSetup.Get();
        if GLSetup."Activar SII" THEN
            if NOT GenJournalLine."System-Created Entry" THEN BEGIN
                //-SII1
                if NOT GenJournalLine."Obviar SII" THEN BEGIN
                    //+SII1
                    if GenJournalLine."Document Type" IN [GenJournalLine."Document Type"::"Credit Memo", GenJournalLine."Document Type"::Invoice, GenJournalLine."Document Type"::Payment, GenJournalLine."Document Type"::Bill] THEN BEGIN
                        if GenJournalLine."VAT Bus. Posting Group" <> '' THEN
                            GestiónSII.CheckGenJnlLineFields(GenJournalLine, GenJournalLine."VAT Bus. Posting Group", GenJournalLine."VAT Prod. Posting Group");
                        if GenJournalLine."Bal. VAT Bus. Posting Group" <> '' THEN
                            GestiónSII.CheckGenJnlLineFields(GenJournalLine, GenJournalLine."Bal. VAT Bus. Posting Group", GenJournalLine."Bal. VAT Prod. Posting Group");
                        if GenJournalLine."Document Type" IN [GenJournalLine."Document Type"::Payment, GenJournalLine."Document Type"::Bill] THEN
                            GestiónSII.CheckGenJnlLineFields(GenJournalLine, '', '');
                    END;
                    //-SII1
                END;
                //+SII1
            END;
        //+SII
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnAfterPostSalesDoc', '', false, false)]
    local procedure OnAfterPostSalesDoc(var SalesHeader: Record "Sales Header";
        var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
        SalesShptHdrNo: Code[20]; RetRcpHdrNo: Code[20]; SalesInvHdrNo: Code[20]; SalesCrMemoHdrNo: Code[20]; CommitIsSuppressed: Boolean; InvtPickPutaway: Boolean; var CustLedgerEntry: Record "Cust. Ledger Entry"; WhseShip: Boolean; WhseReceiv: Boolean)
    var
        GlSetup: Record "General Ledger Setup";
        GestiónSII: Report "Gestión SII";
        SalesInvHeader: Record "Sales Invoice Header";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
    begin
        //-SII
        GLSetup.Get;
        if Not SalesInvHeader.Get(SalesInvHdrNo) Then SalesInvHeader.Init();
        if Not SalesCrMemoHeader.Get(SalesCrMemoHdrNo) then SalesCrMemoHeader.Init();
        if GLSetup."Activar SII" THEN
            //-SII1
            if NOT SalesHeader."Obviar SII" THEN
                //+SII1
                GestiónSII.CreateOrUpdateFileSales(SalesInvHeader, SalesCrMemoHeader, (SalesHeader."Document Type" IN [SalesHeader."Document Type"::Order, SalesHeader."Document Type"::Invoice]) AND (SalesHeader."Corrected Invoice No." <> ''));
        //+SII
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", 'OnAfterPostPurchaseDoc', '', false, false)]
    local procedure OnAfterPostPurchaseDoc(var PurchaseHeader: Record "Purchase Header"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; PurchRcpHdrNo: Code[20]; RetShptHdrNo: Code[20]; PurchInvHdrNo: Code[20]; PurchCrMemoHdrNo: Code[20]; CommitIsSupressed: Boolean)
    var
        GlSetup: Record "General Ledger Setup";
        GestiónSII: Report "Gestión SII";
        PurchaseInvHeader: Record "Purch. Inv. Header";
        PurchaseCrMemoHeader: Record "Purch. Cr. Memo Hdr.";
    begin
        //-SII
        GLSetup.Get;
        if Not PurchaseInvHeader.Get(PurchInvHdrNo) Then PurchaseInvHeader.Init();
        if Not PurchaseCrMemoHeader.Get(PurchCrMemoHdrNo) then PurchaseCrMemoHeader.Init();
        if GLSetup."Activar SII" THEN
            //-SII1
            if NOT PurchaseHeader."Obviar SII" THEN
                //+SII1
                GestiónSII.CreateOrUpdateFilePurch(PurchaseInvHeader, PurchaseCrMemoHeader, (PurchaseHeader."Document Type" IN [PurchaseHeader."Document Type"::Order, PurchaseHeader."Document Type"::Invoice]) AND (PurchaseHeader."Corrected Invoice No." <> ''));
        //+SII
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnBeforePostCommitSalesDoc', '', false, false)]

    local procedure OnBeforePostCommitSalesDoc(var SalesHeader: Record "Sales Header"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; PreviewMode: Boolean; var ModifyHeader: Boolean; var CommitIsSuppressed: Boolean; var TempSalesLineGlobal: Record "Sales Line" temporary)
    var
        GlSetup: Record "General Ledger Setup";
        GestiónSII: Report "Gestión SII";
    begin
        //-SII
        GLSetup.Get;
        if GLSetup."Activar SII" THEN BEGIN
            //-SII1
            if NOT SalesHeader."Obviar SII" THEN
                //GestiónSII.CheckSalesRequiredFields(SalesHeader);
                GestiónSII.CheckSalesRequiredFields(SalesHeader, ModifyHeader);
            //+SII1
        END;
        //+SII
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", 'OnBeforePostCommitPurchaseDoc', '', false, false)]

    local procedure OnBeforePostCommitPurchaseDoc(var PurchaseHeader: Record "Purchase Header"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; PreviewMode: Boolean; ModifyHeader: Boolean; CommitIsSupressed: Boolean; var TempPurchLineGlobal: Record "Purchase Line" temporary)
    var
        GlSetup: Record "General Ledger Setup";
        GestiónSII: Report "Gestión SII";
    begin
        //-SII
        GLSetup.Get;
        if GLSetup."Activar SII" THEN BEGIN
            //-SII1
            if NOT PurchaseHeader."Obviar SII" THEN
                //GestiónSII.CheckSalesRequiredFields(SalesHeader);
                GestiónSII.CheckPurchRequiredFields(PurchaseHeader, ModifyHeader);
            //+SII1
        END;
        //+SII
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnBeforeInsertICGenJnlLine', '', false, false)]
    local procedure OnBeforeInsertICGenJnlLine(var ICGenJournalLine: Record "Gen. Journal Line"; SalesHeader: Record "Sales Header"; SalesLine: Record "Sales Line"; CommitIsSuppressed: Boolean)
    var
        GlSetup: Record "General Ledger Setup";
        GestiónSII: Report "Gestión SII";
        VATBusPostGrp: Record "VAT Business Posting Group";
    begin
        //-SII
        GLSetup.Get;
        if GLSetup."Activar SII" THEN BEGIN
            ICGenJournalLine.Banco := SalesHeader."Tipo factura SII";
            VATBusPostGrp.GET(SalesHeader."VAT Bus. Posting Group");
            ICGenJournalLine."Clave registro SII expedidas" := VATBusPostGrp."Clave registro SII expedidas";
            ICGenJournalLine."Descripción operación" := SalesHeader."Descripción operación";
            ICGenJournalLine."Tipo factura rectificativa" := SalesHeader."Tipo factura rectificativa";
        END;
        //+SII
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", 'OnInsertICGenJnlLineOnBeforeICGenJnlLineInsert', '', false, false)]
    local procedure OnInsertICGenJnlLineOnBeforeICGenJnlLineInsert(var TempICGenJournalLine: Record "Gen. Journal Line" temporary; PurchaseHeader: Record "Purchase Header"; PurchaseLine: Record "Purchase Line"; CommitIsSuppressed: Boolean)
    var
        GlSetup: Record "General Ledger Setup";
        GestiónSII: Report "Gestión SII";
        VATBusPostGrp: Record "VAT Business Posting Group";
    begin
        //-SII
        GLSetup.Get;
        if GLSetup."Activar SII" THEN BEGIN
            TempICGenJournalLine.Banco := PurchaseHeader."Tipo factura SII";
            VATBusPostGrp.GET(PurchaseHeader."VAT Bus. Posting Group");
            TempICGenJournalLine."Clave registro SII recibidas" := VATBusPostGrp."Clave registro SII recibidas";
            TempICGenJournalLine."Descripción operación" := PurchaseHeader."Descripción operación";
            TempICGenJournalLine."Tipo factura rectificativa" := PurchaseHeader."Tipo factura rectificativa";
        END;
        //+SII
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnBeforeSalesShptHeaderInsert', '', false, false)]
    local procedure OnBeforeSalesShptHeaderInsert(SalesHeader: Record "Sales Header"; SalesShptHeader: Record "Sales Shipment Header")
    var
        GlSetup: Record "General Ledger Setup";
        GestiónSII: Report "Gestión SII";
        VATBusPostGrp: Record "VAT Business Posting Group";
    begin
        //-SII
        if GLSetup."Activar SII" THEN BEGIN
            VATBusPostGrp.GET(SalesShptHeader."VAT Bus. Posting Group");
            SalesShptHeader."Clave registro SII expedidas" := VATBusPostGrp."Clave registro SII expedidas";
        END;
        //+SII

    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", 'OnBeforePurchRcptHeaderInsert', '', false, false)]
    local procedure OnBeforePurchRcptHeaderInsert(var PurchRcptHeader: Record "Purch. Rcpt. Header"; var PurchaseHeader: Record "Purchase Header"; CommitIsSupressed: Boolean)
    var
        GlSetup: Record "General Ledger Setup";
        GestiónSII: Report "Gestión SII";
        VATBusPostGrp: Record "VAT Business Posting Group";
    begin
        //-SII
        if GLSetup."Activar SII" THEN BEGIN
            VATBusPostGrp.GET(PurchRcptHeader."VAT Bus. Posting Group");
            PurchRcptHeader."Clave registro SII recibidas" := VATBusPostGrp."Clave registro SII recibidas";
        END;
        //+SII

    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnBeforeReturnRcptHeaderInsert', '', false, false)]
    local procedure OnBeforeReturnRcptHeaderInsert(var ReturnRcptHeader: Record "Return Receipt Header"; SalesHeader: Record "Sales Header"; CommitIsSuppressed: Boolean)
    var
        GlSetup: Record "General Ledger Setup";
        GestiónSII: Report "Gestión SII";
        VATBusPostGrp: Record "VAT Business Posting Group";
    begin
        //-SII
        if GLSetup."Activar SII" THEN BEGIN
            VATBusPostGrp.GET(ReturnRcptHeader."VAT Bus. Posting Group");
            ReturnRcptHeader."Clave registro SII expedidas" := VATBusPostGrp."Clave registro SII recibidas";
        END;
        //+SII

    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", 'OnBeforeReturnShptHeaderInsert', '', false, false)]
    local procedure OnBeforeReturnShptHeaderInsert(var ReturnShptHeader: Record "Return Shipment Header"; var PurchHeader: Record "Purchase Header"; CommitIsSupressed: Boolean)
    var
        GlSetup: Record "General Ledger Setup";
        GestiónSII: Report "Gestión SII";
        VATBusPostGrp: Record "VAT Business Posting Group";
    begin
        //-SII
        if GLSetup."Activar SII" THEN BEGIN
            VATBusPostGrp.GET(ReturnShptHeader."VAT Bus. Posting Group");
            ReturnShptHeader."Clave registro SII recibidas" := VATBusPostGrp."Clave registro SII recibidas";
        END;
        //+SII

    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnBeforeSalesInvHeaderInsert', '', false, false)]
    local procedure OnBeforeSalesInvHeaderInsert(var SalesInvHeader: Record "Sales Invoice Header"; SalesHeader: Record "Sales Header"; CommitIsSuppressed: Boolean; var IsHandled: Boolean)
    var
        GlSetup: Record "General Ledger Setup";
        GestiónSII: Report "Gestión SII";
        VATBusPostGrp: Record "VAT Business Posting Group";
    begin
        GlSetup.Get;

        //-SII
        if GLSetup."Activar SII" THEN BEGIN
            VATBusPostGrp.GET(SalesInvHeader."VAT Bus. Posting Group");
            SalesInvHeader."Clave registro SII expedidas" := VATBusPostGrp."Clave registro SII expedidas";
        END;
        //+SII

    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", 'OnBeforePurchInvHeaderInsert', '', false, false)]
    local procedure OnBeforePurchInvHeaderInsert(var PurchInvHeader: Record "Purch. Inv. Header"; var PurchHeader: Record "Purchase Header"; CommitIsSupressed: Boolean)
    var
        GlSetup: Record "General Ledger Setup";
        GestiónSII: Report "Gestión SII";
        VATBusPostGrp: Record "VAT Business Posting Group";
    begin
        GlSetup.Get;
        //PurchInvHeader."Pte. Pdf" := TRUE; //+002

        //-SII
        if GLSetup."Activar SII" THEN BEGIN
            VATBusPostGrp.GET(PurchInvHeader."VAT Bus. Posting Group");
            PurchInvHeader."Clave registro SII recibidas" := VATBusPostGrp."Clave registro SII recibidas";
        END;
        //+SII

    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnBeforeSalesCrMemoHeaderInsert', '', false, false)]
    local procedure OnBeforeSalesCrMemoHeaderInsert(var SalesCrMemoHeader: Record "Sales Cr.Memo Header"; SalesHeader: Record "Sales Header"; CommitIsSuppressed: Boolean; var IsHandled: Boolean)
    var
        GlSetup: Record "General Ledger Setup";
        GestiónSII: Report "Gestión SII";
        VATBusPostGrp: Record "VAT Business Posting Group";
    begin
        GlSetup.Get;

        //-SII
        if GLSetup."Activar SII" THEN BEGIN
            VATBusPostGrp.GET(SalesCrMemoHeader."VAT Bus. Posting Group");
            SalesCrMemoHeader."Clave registro SII expedidas" := VATBusPostGrp."Clave registro SII expedidas";
        END;
        //+SII

    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", 'OnBeforePurchCrMemoHeaderInsert', '', false, false)]
    local procedure OnBeforePurchCrMemoHeaderInsert(var PurchCrMemoHdr: Record "Purch. Cr. Memo Hdr."; var PurchHeader: Record "Purchase Header"; CommitIsSupressed: Boolean)
    var
        GlSetup: Record "General Ledger Setup";
        GestiónSII: Report "Gestión SII";
        VATBusPostGrp: Record "VAT Business Posting Group";
    begin
        GlSetup.Get;
        //PurchCrMemoHeader."Pte. Pdf" := TRUE; //+002

        //-SII
        if GLSetup."Activar SII" THEN BEGIN
            VATBusPostGrp.GET(PurchCrMemoHdr."VAT Bus. Posting Group");
            PurchCrMemoHdr."Clave registro SII recibidas" := VATBusPostGrp."Clave registro SII recibidas";
        END;
        //+SII

    end;
}