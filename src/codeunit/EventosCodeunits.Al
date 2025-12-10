/// <summary>
/// Codeunit ControldeEventos (ID 50015).
/// </summary>
codeunit 50015 ControldeEventosCodeunits
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
    tabledata 7000002 = rimd,
    tabledata 380 = rimd;

    Var
        ContoldeProcesos: Codeunit Utilitis;
        Procesos: Codeunit ControlProcesos;
        Panorama: Codeunit Panorama;

        ContabAlb: Codeunit ContabAlb;
        NoContab: Label 'El Albarán %1, no está contabilizado';
        glUnion: Label 'UNION AGRICOLA Y TURISTICA, SL';
        glUATI: Label 'UATI';

        #region Codeunits

        DevolNotConta: Label 'La devolución %1, no está contabilizada';
        ContabNoActivada: Label 'La contabilización de albaranes, no está activada';
        ContabActivos: Label 'No se pueden contabilizar activos fijos';
        ProcesoCancelado: Label 'Proceso Cancelado por el usuario';
        Contacte: Label 'El proceso no puede continuar, Contacte con informática';
    #region Codeunit1
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"System Initialization", 'OnAfterLogin', '', false, false)]
    internal procedure OnAfterLogin()
    var
        Fichajes: Record Punches;
        UserSetup: Record "User Setup";
        Http: Codeunit HttpKuara;
        Fecha: Date;
        Como: Option User,Employee;
    begin
        // if UserSetup.Get(UserId) Then begin
        //     if (UserSetup."employee gotimecloud" <> '')
        //     and (UserSetup."username gotimecloud" <> '')
        //     and (UserSetup."password gotimecloud" <> '') then begin
        //         Fichajes.SetRange(Empleado, UserSetup."employee gotimecloud");
        //         if Not Fichajes.FindLast() Then begin
        //             Http.CreateFichaje(Userid, Como::User);
        //         end else begin
        //             Fecha := DT2Date(Fichajes.Fecha);
        //             if Fecha < Today then begin
        //                 Http.CreateFichaje(UserId, Como::User);
        //                 exit;
        //             end;
        //             if Fichajes.Fecha < CreateDateTime(Today, 150000T) then
        //                 Http.CreateFichaje(UserId, Como::User);

        //         end;
        //     end;
        //end;
    end;
    #endregion Codeunit1
    #region Codeunit8
    [EventSubscriber(ObjectType::Codeunit, 8, 'OnBeforeCalcCellExit', '', false, false)]
    local procedure OnBeforeCalcCellExit(var AccSchedLine: Record "Acc. Schedule Line"; var ColumnLayout: Record "Column Layout"; CalcAddCurr: Boolean; var Result: Decimal)
    Var
        AccSchedManagement: Codeunit "Procedures Standard";
    begin
        Result := AccSchedManagement.CalcCell(AccSchedLine, ColumnLayout, CalcAddCurr);
    end;

    [EventSubscriber(ObjectType::Codeunit, 8, 'OnAfterCalcCellValue', '', false, false)]
    Procedure CalcValueOnAfterCalcCellValue(var AccSchedLine: Record "Acc. Schedule Line"; var ColumnLayout: Record "Column Layout"; var Result: Decimal)
    var
        AccSchedName: Record "Acc. Schedule Name";
        VeAcc: Record Vendor;
        CuAcc: Record Customer;
        Control: Codeunit ControlProcesos;
    begin

        //Asc Customer & Vendors
        if AccSchedLine."Totaling Type" IN
        [AccSchedLine."Totaling Type"::Vendor, AccSchedLine."Totaling Type"::Customer]
        THEN BEGIN
            if ColumnLayout.Empresa <> '' THEN begin
                if not Control.Permiso_Empresas(ColumnLayout.Empresa) then begin
                    Result := 0;
                    exit;
                end;
            end;
            if AccSchedLine.Company <> '' THEN BEGIN
                if not Control.Permiso_Empresas(AccSchedLine.Company) then begin
                    Result := 0;
                    exit;
                END;
            end;
            //AccSchedLine.COPYFILTERS(AccountScheduleLine);
            if AccSchedName.GET(AccSchedLine."Schedule Name") THEN
                if AccSchedLine."Totaling Type" = AccSchedLine."Totaling Type"::Vendor THEN BEGIN
                    Panorama.SetVeAccRowFilters(VeAcc, AccSchedLine);
                    Panorama.SetVeAccColumnFilters(VeAcc, AccSchedLine, ColumnLayout);
                    if ColumnLayout.Empresa <> '' THEN begin
                        VeAcc.CHANGECOMPANY(ColumnLayout.Empresa);


                    end;
                    if AccSchedLine.Company <> '' THEN BEGIN
                        VeAcc.CHANGECOMPANY(AccSchedLine.Company);

                    END;
                    if (ColumnLayout.Empresa <> '') AND
                    (AccSchedLine.Company <> '') AND
                    (AccSchedLine.Company <> ColumnLayout.Empresa) THEN
                        Result := Result + 0
                    ELSE BEGIN

                        if VeAcc.FIND('-') THEN
                            REPEAT
                                if AccSchedLine."Grupo Contable" = VeAcc."Vendor Posting Group" THEN
                                    Result := Result + Panorama.CalcVeAcc(VeAcc, AccSchedLine, ColumnLayout, false);
                            UNTIL VeAcc.NEXT = 0;
                    END;
                END ELSE BEGIN
                    Panorama.SetCuAccRowFilters(CuAcc, AccSchedLine);
                    Panorama.SetCuAccColumnFilters(CuAcc, AccSchedLine, ColumnLayout);
                    if ColumnLayout.Empresa <> '' THEN
                        CuAcc.CHANGECOMPANY(ColumnLayout.Empresa);
                    if AccSchedLine.Company <> '' THEN
                        CuAcc.CHANGECOMPANY(AccSchedLine.Company);
                    if (ColumnLayout.Empresa <> '') AND
                    (AccSchedLine.Company <> '') AND
                    (AccSchedLine.Company <> ColumnLayout.Empresa) THEN
                        Result := Result + 0
                    ELSE BEGIN

                        if CuAcc.FIND('-') THEN
                            REPEAT
                                if AccSchedLine."Grupo Contable" = CuAcc."Customer Posting Group" THEN
                                    Result := Result + Panorama.CalcCuAcc(CuAcc, AccSchedLine, ColumnLayout, false);
                            UNTIL CuAcc.NEXT = 0;
                    END;
                END;
        END;

        // Fin Asc
    end;
    #endregion Codeunit8
    #region Codeunit11
    [EventSubscriber(ObjectType::Codeunit, 11, 'OnBeforeCheckAccountNo', '', false, false)]
    local procedure CheckAccountNo(var GenJnlLine: Record "Gen. Journal Line"; CheckDone: Boolean)
    var
        ICPartner: Record "IC Partner";
    begin
        if (GenJnlLine."Document Type" in [GenJnlLine."Document Type"::Shipment, GenJnlLine."Document Type"::Receipt]) Then
            CheckDone := true
        else
            exit;
        with GenJnlLine do
            case "Account Type" of
                "Account Type"::"G/L Account":
                    begin
                        if ("Gen. Posting Type" <> "Gen. Posting Type"::" ")
                        then
                            Error(
                                ErrorInfo.Create(
                                    StrSubstNo('No se puede introducir un valor en el campo %1 al contabilizar un albarán', FieldCaption("Gen. Posting Type")),
                                    true,
                                    GenJnlLine,
                                    GenJnlLine.FieldNo("Gen. Posting Type")));



                    end;
                "Account Type"::Customer, "Account Type"::Vendor, "Account Type"::Employee:
                    begin
                        TestField("Gen. Posting Type", 0, ErrorInfo.Create());
                        TestField("Gen. Prod. Posting Group", '', ErrorInfo.Create());
                        TestField("VAT Bus. Posting Group", '', ErrorInfo.Create());
                        TestField("VAT Prod. Posting Group", '', ErrorInfo.Create());


                    end;

            end;



    end;

    [EventSubscriber(ObjectType::Codeunit, 11, 'OnBeforeCheckDocType', '', false, false)]
    local procedure OnBeforeCheckDocType(GenJournalLine: Record "Gen. Journal Line"; var IsHandled: Boolean)
    begin
        if GenJournalLine."Document Type" = GenJournalLine."Document Type"::Receipt Then IsHandled := true;
    end;
    #endregion Codeunit11
    #region Codeunit12
    [EventSubscriber(ObjectType::Codeunit, 12, 'OnAfterSettingIsTransactionConsistent', '', false, false)]
    local procedure OnAfterSettingIsTransactionConsistent(GenJournalLine: Record "Gen. Journal Line"; var IsTransactionConsistent: Boolean)
    var
        GlSetup: Record "General Ledger Setup";
    begin
        GlSetup.Get();
        if GlSetup."No Comprobar Consistencia" then IsTransactionConsistent := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, 12, 'OnAfterGLFinishPosting', '', false, false)]
    local procedure OnAfterGLFinishPosting(GLEntry: Record "G/L Entry"; var GenJnlLine: Record "Gen. Journal Line"; IsTransactionConsistent: Boolean; FirstTransactionNo: Integer; var GLRegister: Record "G/L Register"; var TempGLEntryBuf: Record "G/L Entry" temporary; var NextEntryNo: Integer; var NextTransactionNo: Integer)
    var
        lGlEntry: Record "G/L Entry";
        lCustEntry: Record "Cust. Ledger Entry";
        lDCuesEntry: Record "Detailed Cust. Ledg. Entry";
        lVendEntry: Record "Vendor Ledger Entry";
        lDVendEntry: Record "Detailed Vendor Ledg. Entry";
    begin
        lGlEntry.SetRange("Entry No.", GLRegister."From Entry No.", GLRegister."To Entry No.");
        lGlEntry.ModifyAll("Transaction No.", GLRegister."No.");
        lCustEntry.SetRange("Entry No.", GLRegister."From Entry No.", GLRegister."To Entry No.");
        lCustEntry.ModifyAll("Transaction No.", GLRegister."No.");
        lDCuesEntry.SetRange("Cust. Ledger Entry No.", GLRegister."From Entry No.", GLRegister."To Entry No.");
        lDCuesEntry.ModifyAll("Transaction No.", GLRegister."No.");
        lVendEntry.SetRange("Entry No.", GLRegister."From Entry No.", GLRegister."To Entry No.");
        lVendEntry.ModifyAll("Transaction No.", GLRegister."No.");
        ldVendEntry.SetRange("Vendor Ledger Entry No.", GLRegister."From Entry No.", GLRegister."To Entry No.");
        ldVendEntry.ModifyAll("Transaction No.", GLRegister."No.");

    end;

    [EventSubscriber(ObjectType::Codeunit, 12, 'OnBeforeFindFirstPurchInvoiceLine', '', false, false)]
    local procedure OnBeforeFindFirstPurchInvoiceLine(var PurchInvLine: Record "Purch. Inv. Line"; var VendLedgEntry4: Record "Vendor Ledger Entry"; var IsHandled: Boolean)
    begin
        IsHandled := true;
        PurchInvLine.SetRange("Document No.", VendLedgEntry4."Document No.");
        PurchInvLine.SetFilter(Type, '<>%1', "Purchase Line Type"::" ");
        if Not PurchInvLine.FindSet() Then PurchInvLine.Init();
    end;

    [EventSubscriber(ObjectType::Codeunit, 12, 'OnApplyVendLedgEntryOnBeforeTempOldVendLedgEntryDelete', '', false, false)]
    local procedure OnApplyVendLedgEntryOnBeforeTempOldVendLedgEntryDelete(var GenJournalLine: Record "Gen. Journal Line";
    var TempVendorLedgerEntry: Record "Vendor Ledger Entry" temporary; AppliedAmount: Decimal)
    var
        Conciliar: Record "Finance Charge Terms";
        IcPartner: Record "IC Partner";
    begin

        if GenJournalLine."IC Partner Code" <> '' THEN BEGIN
            // Asc 06/08/14
            Conciliar.Code := TempVendorLedgerEntry."Vendor No.";
            Conciliar.Asiento := TempVendorLedgerEntry."Transaction No.";
            Conciliar.Documento := TempVendorLedgerEntry."Document No.";
            Conciliar."Documento Ext" := TempVendorLedgerEntry."External Document No.";
            Conciliar."Empresa Org" := COMPANYNAME;
            if IcPartner.GET(GenJournalLine."IC Partner Code") THEN
                Conciliar."Empresa Dest" := IcPartner."Inbox Details";
            if GenJournalLine."Applies-to ID" <> '' THEN Conciliar."Liquidado por Id" := TRUE;
            Case TempVendorLedgerEntry."Document Type" of
                TempVendorLedgerEntry."Document Type"::" ":
                    Conciliar."Document Type" := Conciliar."Document Type"::" ";
                TempVendorLedgerEntry."Document Type"::Receipt:
                    Conciliar."Document Type" := Conciliar."Document Type"::Albaran;
                TempVendorLedgerEntry."Document Type"::Bill:
                    Conciliar."Document Type" := Conciliar."Document Type"::Bill;
                TempVendorLedgerEntry."Document Type"::"Credit Memo":
                    Conciliar."Document Type" := Conciliar."Document Type"::"Credit Memo";
                TempVendorLedgerEntry."Document Type"::"Finance Charge Memo":
                    Conciliar."Document Type" := Conciliar."Document Type"::"Finance Charge Memo";
                TempVendorLedgerEntry."Document Type"::Invoice:
                    Conciliar."Document Type" := Conciliar."Document Type"::Invoice;
                TempVendorLedgerEntry."Document Type"::Payment:
                    Conciliar."Document Type" := Conciliar."Document Type"::Payment;
                TempVendorLedgerEntry."Document Type"::Refund:
                    Conciliar."Document Type" := Conciliar."Document Type"::Refund;
                TempVendorLedgerEntry."Document Type"::Reminder:
                    Conciliar."Document Type" := Conciliar."Document Type"::Reminder
            End;
            Conciliar."Nº Mov" := TempVendorLedgerEntry."Entry No.";
            if Conciliar.INSERT THEN;
        END;
    end;

    [EventSubscriber(ObjectType::Codeunit, 12, 'OnBeforeInitGLEntry', '', false, false)]
    local procedure OnBeforeInitGLEntry(var GenJournalLine: Record "Gen. Journal Line"; var GLAccNo: Code[20]; SystemCreatedEntry: Boolean; Amount: Decimal; AmountAddCurr: Decimal)
    var
        CustPostingGr: Record "Customer Posting Group";
        Cust: Record Customer;
    begin
        if GenJournalLine."Document Type" <> GenJournalLine."Document Type"::Payment Then Exit;
        if (GenJournalLine."Liquida Facturas en Remesa") OR
            ((GenJournalLine."No. Borrador factura" <> '') AND (ContoldeProcesos.EsRemesa(GenJournalLine."Document No."))) THEN BEGIN
            Cust.Get(GenJournalLine."Source No.");
            CustPostingGr.Get(Cust."Customer Posting Group");
            GLAccNo := CustPostingGr."Bills on Collection Acc.";
            if Procesos.TieneMarcaDto(GenJournalLine."Document No.") THEN
                GLAccNo := CustPostingGr."Discted. Bills Acc.";
        END;
    end;

    [EventSubscriber(ObjectType::Codeunit, 12, 'OnBeforeCheckCarteraCustUnrealizedVAT', '', false, false)]
    local procedure OnBeforeCheckCarteraCustUnrealizedVAT(var VATEntry: Record "VAT Entry"; var CustLedgerEntry4: Record "Cust. Ledger Entry"; var CustLedgerEntry3: Record "Cust. Ledger Entry"; var CustLedgerEntry2: Record "Cust. Ledger Entry" temporary; CarteraDoc: Record "Cartera Doc."; PostedCarteraDoc: Record "Posted Cartera Doc."; ClosedCarteraDoc: Record "Closed Cartera Doc."; var IsHandled: Boolean)
    var
        FromJnl: Boolean;
        C12: Codeunit 12;
        VATPostingSetup: Record "VAT Posting Setup";
        FromDocInPostedBillGr: Boolean;
        FromDoc: Boolean;
        Text1100000: Label 'En tipo de iva no realizado debe se "Porcentaje" en Configruración registro iva.';
        Text1100001: Label 'Efecto/Factura Nª %1 no existe';
    begin
        IsHandled := true;
        if CustLedgerEntry4."Document No." = '' Then exit;

        if CustLedgerEntry4."Document Type" = CustLedgerEntry4."Document Type"::Bill then begin
            if PostedCarteraDoc."Bill Gr./Pmt. Order No." <> '' Then FromDocInPostedBillGr := True;
            FromJnl := false;
            if CarteraDoc."From Journal" or PostedCarteraDoc."From Journal" or ClosedCarteraDoc."From Journal" then
                FromJnl := true;
            C12.CustFindVATSetup(VATPostingSetup, CustLedgerEntry4, FromJnl);
            if (VATPostingSetup."Unrealized VAT Type" > VATPostingSetup."Unrealized VAT Type"::Percentage) and
            (not FromDocInPostedBillGr)
            then
                Error(Text1100000);
            CustLedgerEntry3.SetCurrentKey("Document No.", "Document Type", "Customer No.");
            CustLedgerEntry3.SetRange("Document Type", CustLedgerEntry3."Document Type"::Invoice);
            CustLedgerEntry3.SetRange("Document No.", CustLedgerEntry4."Document No.");
            FromDoc := false;
            if Not CustLedgerEntry3.FindFirst() then
                CustLedgerEntry3.SetRange("Document Type", CustLedgerEntry3."Document Type"::Bill);
            if CustLedgerEntry3.FindFirst() then begin
                CustLedgerEntry3.CalcFields("Original Amt. (LCY)");
                CustLedgerEntry2.Open := true;
                VATEntry.SetRange("Transaction No.", CustLedgerEntry3."Transaction No.");
                VATEntry.SetRange("Document No.", CustLedgerEntry3."Document No.");
            end else
                Error(Text1100001, CustLedgerEntry3."Document No.");
        end else begin
            VATEntry.SetRange("Transaction No.", CustLedgerEntry4."Transaction No.");
            VATEntry.SetRange("Document No.", CustLedgerEntry4."Document No.");
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 12, 'OnBeforeCheckCarteraVendUnrealizedVAT', '', false, false)]
    local procedure OnBeforeCheckCarteraVendUnrealizedVAT(var VATEntry: Record "VAT Entry"; var VendLedgerEntry4: Record "Vendor Ledger Entry"; var VendLedgerEntry3: Record "Vendor Ledger Entry"; var VendLedgerEntry2: Record "Vendor Ledger Entry" temporary; CarteraDoc: Record "Cartera Doc."; PostedCarteraDoc: Record "Posted Cartera Doc."; ClosedCarteraDoc: Record "Closed Cartera Doc."; var IsHandled: Boolean)
    var
        VATPostingSetup: Record "VAT Posting Setup";
        PurchaseInvoice: Record "Purch. Inv. Header";
        FromJnl: Boolean;
        C12: Codeunit 12;
        FromDocInPostedPmtOrd: Boolean;
        FromDoc: Boolean;
        Text1100000: Label 'En tipo de iva no realizado debe se "Porcentaje" en Configruración registro iva.';
        Text1100001: Label 'Efecto/Factura Nª %1 no existe';
    begin
        IsHandled := true;
        if VendLedgerEntry4."Document No." = '' Then Exit;
        if VendLedgerEntry4."Document Type" = VendLedgerEntry4."Document Type"::Bill then begin
            FromJnl := false;
            if CarteraDoc."From Journal" or PostedCarteraDoc."From Journal" or ClosedCarteraDoc."From Journal" then
                FromJnl := true;
            if (VendLedgerEntry4."Document Type" = VendLedgerEntry4."Document Type"::Bill) And (Not PurchaseInvoice.Get(VendLedgerEntry4."Document No."))
            Then begin
                VATEntry.SetRange("Transaction No.", VendLedgerEntry4."Transaction No.");
                VATEntry.SetRange("Document No.", '-1');
                Exit;
            end;
            C12.VendFindVATSetup(VATPostingSetup, VendLedgerEntry4, FromJnl);
            if (VATPostingSetup."Unrealized VAT Type" > VATPostingSetup."Unrealized VAT Type"::Percentage) and
            (not FromDocInPostedPmtOrd)
            then
                Error(Text1100000);
            VendLedgerEntry3.SetCurrentKey("Document No.", "Document Type", "Vendor No.");
            VendLedgerEntry3.SetRange("Document Type", VendLedgerEntry3."Document Type"::Invoice);
            VendLedgerEntry3.SetRange("Document No.", VendLedgerEntry4."Document No.");
            if Not VendLedgerEntry3.FindFirst() then
                VendLedgerEntry3.SetRange("Document Type", VendLedgerEntry3."Document Type"::Bill);

            if VendLedgerEntry3.FindFirst then begin
                VendLedgerEntry3.CalcFields("Original Amt. (LCY)");
                VendLedgerEntry2.Open := true;
                VATEntry.SetRange("Transaction No.", VendLedgerEntry3."Transaction No.");
                VATEntry.SetRange("Document No.", VendLedgerEntry3."Document No.");
            end else
                Error(Text1100001, VendLedgerEntry3."Document No.");
        end else begin
            VATEntry.SetRange("Transaction No.", VendLedgerEntry4."Transaction No.");
            VATEntry.SetRange("Document No.", VendLedgerEntry4."Document No.");
        end;

    end;

    [EventSubscriber(ObjectType::Codeunit, 12, 'OnBeforeGetGLAccountForReceivableDocs', '', false, false)]
    local procedure OnBeforeGetGLAccountForReceivableDocs(GenJournalLine: Record "Gen. Journal Line"; CustPostingGr: Record "Customer Posting Group"; DocAmountLCY: Decimal; var AccountNo: Code[20]; var IsHandled: Boolean)
    var
        AccNo3: Code[20];
    begin
        IsHandled := true;
        if (GenJournalLine."Applies-to Doc. Type" = GenJournalLine."Applies-to Doc. Type"::Invoice)
        OR (GenJournalLine."Applies-to Doc. Type" = GenJournalLine."Applies-to Doc. Type"::Receipt)
        THEN BEGIN
            CustPostingGr.TESTFIELD("Receivables Account");
            AccNo3 := CustPostingGr."Receivables Account";
            if (GenJournalLine."Liquida Facturas en Remesa") OR
            ((GenJournalLine."No. Borrador factura" <> '') AND (ContoldeProcesos.EsRemesa(GenJournalLine."Document No."))) THEN BEGIN

                AccNo3 := CustPostingGr."Bills on Collection Acc.";
                if Procesos.TieneMarcaDto(GenJournalLine."Document No.") THEN
                    AccNo3 := CustPostingGr."Discted. Bills Acc.";
            END;
        END ELSE BEGIN
            //$003(I)
            if GenJournalLine."No. Borrador factura" = '' THEN BEGIN
                CustPostingGr.TESTFIELD("Bills Account");                //std
                AccNo3 := CustPostingGr."Bills Account";  //std
            END
            ELSE BEGIN
                CustPostingGr.TESTFIELD("Cta efectos sin fra");
                AccNo3 := CustPostingGr."Cta efectos sin fra";
            END;
            //$003(F)

        END;
        AccountNo := AccNo3;
    END;

    [EventSubscriber(ObjectType::Codeunit, 12, 'OnPostCustOnAfterInitCustLedgEntry', '', false, false)]
    local procedure OnPostCustOnAfterInitCustLedgEntry(var GenJournalLine: Record "Gen. Journal Line"; var CustLedgEntry: Record "Cust. Ledger Entry"; Cust: Record Customer; CustPostingGr: Record "Customer Posting Group")
    begin

        //ASC
        CustLedgEntry."Global Dimension 1 Code" := GenJournalLine."Shortcut Dimension 1 Code";
        CustLedgEntry."Global Dimension 2 Code" := GenJournalLine."Shortcut Dimension 2 Code";
        CustLedgEntry."Global Dimension 3 Code" := GenJournalLine."Shortcut Dimension 3 Code";
        CustLedgEntry."Global Dimension 4 Code" := GenJournalLine."Shortcut Dimension 4 Code";
        CustLedgEntry."Global Dimension 5 Code" := GenJournalLine."Shortcut Dimension 5 Code";
        CustLedgEntry."Nº Factura Borrador" := GenJournalLine."No. Borrador factura";
        // MLL 291099             //FCL-Pagarés
        CustLedgEntry."Cod. Forma Pago" := CustLedgEntry."Payment Method Code";

        CustLedgEntry.Banco := GenJournalLine.Banco;
        // Fin
        //$005(I)
        //$005(F)
    end;

#pragma warning disable AL0432 // TODO: - Eliminar 23
    [EventSubscriber(ObjectType::Codeunit, 12, 'OnAfterCustLedgEntryInsert', '', false, false)]
#pragma warning restore AL0432 // TODO: - Eliminar 23
    local procedure OnAfterCustLedgEntryInsert(var CustLedgerEntry: Record "Cust. Ledger Entry"; GenJournalLine: Record "Gen. Journal Line"; DtldLedgEntryInserted: Boolean)
    begin
        if ((GenJournalLine."Document Type" = GenJournalLine."Document Type"::Invoice)
        OR (GenJournalLine."Document Type" = GenJournalLine."Document Type"::Payment))
        AND (GenJournalLine."No. Borrador factura" <> '') THEN BEGIN
            ContoldeProcesos.LiquidarFactura(GenJournalLine, CustLedgerEntry);
        END ELSE

            //$005(F)
            if (GenJournalLine."Document Type" = GenJournalLine."Document Type"::Invoice)
                THEN
                ContoldeProcesos.LiquidarFacturaCon(GenJournalLine, CustLedgerEntry);

    end;
    // [EventSubscriber(ObjectType::Codeunit, 12, 'OnAfterCustLedgEntryInsertInclPreviewMode', '', false, false)]
    // local procedure OnAfterCustLedgEntryInsertInclPrevModde(var CustLedgerEntry: Record "Cust. Ledger Entry"; GenJournalLine: Record "Gen. Journal Line"; DtldLedgEntryInserted: Boolean)
    // begin
    //     if ((GenJournalLine."Document Type" = GenJournalLine."Document Type"::Invoice)
    //     OR (GenJournalLine."Document Type" = GenJournalLine."Document Type"::Payment))
    //     AND (GenJournalLine."No. Borrador factura" <> '') THEN BEGIN
    //         ContoldeProcesos.LiquidarFactura(GenJournalLine, CustLedgerEntry);
    //     END ELSE

    //         //$005(F)
    //         if (GenJournalLine."Document Type" = GenJournalLine."Document Type"::Invoice)
    //             THEN
    //             ContoldeProcesos.LiquidarFacturaCon(GenJournalLine, CustLedgerEntry);

    // end;

    [EventSubscriber(ObjectType::Codeunit, 12, 'OnBeforeInsertDtldCustLedgEntry', '', false, false)]
    local procedure OnBeforeInsertDtldCustLedgEntry(var DtldCustLedgEntry: Record "Detailed Cust. Ledg. Entry"; GenJournalLine: Record "Gen. Journal Line"; DtldCVLedgEntryBuffer: Record "Detailed CV Ledg. Entry Buffer")
    begin

        //ASC
        DtldCustLedgEntry."Initial Entry Global Dim. 1" := GenJournalLine."Shortcut Dimension 1 Code";
        DtldCustLedgEntry."Initial Entry Global Dim. 2" := GenJournalLine."Shortcut Dimension 2 Code";
        DtldCustLedgEntry."Initial Entry Global Dim. 3" := GenJournalLine."Shortcut Dimension 3 Code";
        DtldCustLedgEntry."Initial Entry Global Dim. 4" := GenJournalLine."Shortcut Dimension 4 Code";
        DtldCustLedgEntry."Initial Entry Global Dim. 5" := GenJournalLine."Shortcut Dimension 5 Code";


    end;

    [EventSubscriber(ObjectType::Codeunit, 12, 'OnPostVendOnAfterInitVendLedgEntry', '', false, false)]
    local procedure OnPostVendOnAfterInitVendLedgEntry(var GenJnlLine: Record "Gen. Journal Line"; var VendLedgEntry: Record "Vendor Ledger Entry")
    begin

        //ASC
        VendLedgEntry."Global Dimension 1 Code" := GenJnlLine."Shortcut Dimension 1 Code";
        VendLedgEntry."Global Dimension 2 Code" := GenJnlLine."Shortcut Dimension 2 Code";
        VendLedgEntry."Global Dimension 3 Code" := GenJnlLine."Shortcut Dimension 3 Code";
        VendLedgEntry."Global Dimension 4 Code" := GenJnlLine."Shortcut Dimension 4 Code";
        VendLedgEntry."Global Dimension 5 Code" := GenJnlLine."Shortcut Dimension 5 Code";

        // MLL 291099             //FCL-Pagarés
        VendLedgEntry."Cod. Forma Pago" := VendLedgEntry."Payment Method Code";
        VendLedgEntry.Banco := GenJnlLine.Banco;
        // Fin

    end;

    [EventSubscriber(ObjectType::Codeunit, 12, 'OnAfterInitGLEntry', '', false, false)]
    local procedure OnAfterInitGLEntry(var GLEntry: Record "G/L Entry"; GenJournalLine: Record "Gen. Journal Line"; Amount: Decimal; AddCurrAmount: Decimal; UseAddCurrAmount: Boolean; var CurrencyFactor: Decimal)
    var
        GLSetup: Record "General Ledger Setup";
        VATPostingSetup: Record "VAT Posting Setup";
        Calculo: Record "Calculo Albaranes";
        rInf: Record "Company Information";
        VPR: Record "Vendor Posting Group";
        CPR: Record "Customer Posting Group";
        Customer: Record Customer;
        Vendor: Record Vendor;
        Control: Codeunit ControlProcesos;
    begin
        rInf.Get();
        if rInf.InterEmpresas then begin
            if GLEntry."Document Type" in [GLEntry."Document Type"::Invoice, GLEntry."Document Type"::"Credit Memo", GLEntry."Document Type"::Receipt] then begin
                Case GLEntry."Source Type" of
                    GLEntry."Source Type"::Vendor:
                        begin
                            if Vendor.Get(GLEntry."Source No.") then
                                VPR.SetRange(Code, Vendor."Vendor Posting Group");
                            VPR.SETRANGE("Payables Account", '402', '4039999999');
                            if VPR.FindFirst() Then begin
                                GLEntry.Eliminaciones := true;
                            end;
                            if (GLEntry."Document Type" = GlEntry."Document Type"::Receipt)
                                And (Copystr(GLEntry."G/L Account No.", 1, 2) In ['6', '7', '2']) Then
                                GlEntry."Gen. Bus. Posting Group" := Vendor."Gen. Bus. Posting Group";
                        end;
                    GLEntry."Source Type"::Customer:
                        begin
                            if Customer.Get(GLEntry."Source No.") then
                                CPR.SetRange(Code, Customer."Customer Posting Group");
                            CPR.SETRANGE("Receivables Account", '432', '4339999999');
                            if CPR.FindFirst() Then begin
                                GLEntry.Eliminaciones := true;
                            end;
                            if (GLEntry."Document Type" = GlEntry."Document Type"::Receipt)
                                And (Copystr(GLEntry."G/L Account No.", 1, 2) In ['6', '7', '2']) Then
                                GlEntry."Gen. Bus. Posting Group" := Customer."Gen. Bus. Posting Group";
                        end;

                end;
            end;
        end;
        Case GLEntry."Source Type" of
            GLEntry."Source Type"::Vendor:
                begin
                    if Vendor.Get(GLEntry."Source No.") then
                        if (GLEntry."Document Type" = GlEntry."Document Type"::Receipt)
                          And (Copystr(GLEntry."G/L Account No.", 1, 1) In ['6', '7', '2']) Then
                            GlEntry."Gen. Bus. Posting Group" := Vendor."Gen. Bus. Posting Group";
                end;
            GLEntry."Source Type"::Customer:
                begin
                    if Customer.Get(GLEntry."Source No.") then
                        if (GLEntry."Document Type" = GlEntry."Document Type"::Receipt)
                        And (Copystr(GLEntry."G/L Account No.", 1, 1) In ['6', '7', '2']) Then
                            GlEntry."Gen. Bus. Posting Group" := Customer."Gen. Bus. Posting Group";
                end;

        end;
        //-SII
        if GLSetup."Activar SII" THEN BEGIN
            //SII1
            if NOT VATPostingSetup.GET(GenJournalLine."VAT Bus. Posting Group", GenJournalLine."VAT Prod. Posting Group") THEN BEGIN
                // GLEntry."Tipo factura SII" :=  VATEntry."Tipo factura SII";
                // GLEntry."Clave registro SII expedidas" := VATEntry."Clave registro SII expedidas";
                // GLEntry."Clave registro SII recibidas" := VATEntry."Clave registro SII recibidas";
                // GLEntry."Descripción operación" := VATEntry."Descripción operación";
                // GLEntry."Tipo desglose emitidas" := VATEntry."Tipo desglose emitidas";
                // GLEntry."Tipo desglose recibidas" := VATEntry."Tipo desglose recibidas";
                // GLEntry."Sujeta exenta" := VATEntry."Sujeta exenta";
                // GLEntry."Tipo de operación" := VATEntry."Tipo de operación";
                // GLEntry."Tipo factura rectificativa" := VATEntry."Tipo factura rectificativa";
            END ELSE BEGIN
                //SII1
                GLEntry."Tipo factura SII" := GenJournalLine."Tipo factura SII";
                GLEntry."Clave registro SII expedidas" := GenJournalLine."Clave registro SII expedidas";
                GLEntry."Clave registro SII recibidas" := GenJournalLine."Clave registro SII recibidas";
                GLEntry."Descripción operación" := GenJournalLine."Descripción operación";
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
                        GLEntry."Tipo desglose emitidas" := GenJournalLine."Tipo desglose emitidas";
                        GLEntry."Sujeta exenta" := GenJournalLine."Sujeta exenta";
                        GLEntry."Tipo de operación" := GenJournalLine."Tipo de operación";
                    END ELSE BEGIN
                        GLEntry."Tipo desglose emitidas" := VATPostingSetup."Tipo desglose emitidas";
                        GLEntry."Sujeta exenta" := VATPostingSetup."Sujeta exenta";
                        GLEntry."Tipo de operación" := VATPostingSetup."Tipo de operación";
                    END;
                if GenJournalLine."Clave registro SII recibidas" <> '' THEN
                    if VATPostingSetup."Tipo desglose recibidas" = '' THEN BEGIN
                        GLEntry."Tipo desglose recibidas" := GenJournalLine."Tipo desglose recibidas";
                        GLEntry."Sujeta exenta" := GenJournalLine."Sujeta exenta";
                        GLEntry."Tipo de operación" := GenJournalLine."Tipo de operación";
                    END ELSE BEGIN
                        GLEntry."Tipo desglose recibidas" := VATPostingSetup."Tipo desglose recibidas";
                        GLEntry."Sujeta exenta" := VATPostingSetup."Sujeta exenta";
                        GLEntry."Tipo de operación" := VATPostingSetup."Tipo de operación";
                    END;
                //+SII1
                GLEntry."Tipo factura rectificativa" := GenJournalLine."Tipo factura rectificativa";
            END;
        END;
        //+SII


        GLEntry.Circuitos := GenJournalLine.Circuito;
        GLEntry.Description := GenJournalLine.Description;
        //ASC
        if GenJournalLine."Shortcut Dimension 1 Code" = '' Then begin
            if GenJournalLine."Shortcut Dimension 3 Code" <> '' Then begin
                Case CopyStr(GenJournalLine."Shortcut Dimension 3 Code", 1) OF
                    '1':
                        GLEntry."Global Dimension 1 Code" := 'EXTERIOR';
                    '2':
                        GLEntry."Global Dimension 1 Code" := 'EXTERIOR';
                    '3':
                        GLEntry."Global Dimension 1 Code" := 'EXTERIOR';
                    '4':
                        GLEntry."Global Dimension 1 Code" := 'EXTERIOR';
                    '5':
                        GLEntry."Global Dimension 1 Code" := 'GENERAL';
                    '6':
                        GLEntry."Global Dimension 1 Code" := 'EXTERIOR';
                    '7':
                        GLEntry."Global Dimension 1 Code" := 'ESTRUCTURA';
                    '8':
                        GLEntry."Global Dimension 1 Code" := 'ESTRUCTURA';
                    '9':
                        GLEntry."Global Dimension 1 Code" := 'ESTRUCTURA';

                End;
            end;
        end else
            GLEntry."Global Dimension 1 Code" := GenJournalLine."Shortcut Dimension 1 Code";
        GLEntry."Global Dimension 2 Code" := GenJournalLine."Shortcut Dimension 2 Code";
        GLEntry."Global Dimension 3 Code" := GenJournalLine."Shortcut Dimension 3 Code";
        GLEntry."Global Dimension 4 Code" := GenJournalLine."Shortcut Dimension 4 Code";
        GLEntry."Global Dimension 5 Code" := GenJournalLine."Shortcut Dimension 5 Code";
        GlEntry."Dimension Set ID" := Control.GetDefaultDimID2(GenJournalLine."Shortcut Dimension 1 Code", GenJournalLine."Shortcut Dimension 2 Code",
                GenJournalLine."Shortcut Dimension 3 Code", GenJournalLine."Shortcut Dimension 4 Code", GenJournalLine."Shortcut Dimension 5 Code");
        GLEntry."SalesPerson Code" := GenJournalLine."Salespers./Purch. Code";
        if GenJournalLine."Nº Albar n" <> '' THEN
            GLEntry."Tax Area Code" := GenJournalLine."Nº Albar n";

        //ASC
        if Calculo.Get(GLEntry."Tax Area Code") Then Begin Calculo.Calculado := False; Calculo.Modify() End;
        GLEntry."Núm. Contrato" := GenJournalLine."Nº Contrato";
        GLEntry.Banco := GenJournalLine.Banco;
        // Conciliacion Cuenta
        GLEntry."Importe pendiente" := GenJournalLine.Amount;
        GLEntry.Pendiente := GLEntry."Importe pendiente" <> 0;

        if GLEntry."IC Partner Code" <> GLEntry."IC Partner Code" THEN
            GLEntry.Eliminaciones := TRUE;
        GLEntry.Eliminaciones := GenJournalLine.Eliminaciones;
        GLEntry."Periodo de Pago" := GenJournalLine."Periodo de Pago";

    end;

    [EventSubscriber(ObjectType::Codeunit, 12, 'OnBeforeInsertDtldVendLedgEntry', '', false, false)]
    local procedure OnBeforeInsertDtldVendLedgEntry(var DtldVendLedgEntry: Record "Detailed Vendor Ledg. Entry"; GenJournalLine: Record "Gen. Journal Line"; DtldCVLedgEntryBuffer: Record "Detailed CV Ledg. Entry Buffer")
    begin

        //ASC
        DtldVendLedgEntry."Initial Entry Global Dim. 1" := GenJournalLine."Shortcut Dimension 1 Code";
        DtldVendLedgEntry."Initial Entry Global Dim. 2" := GenJournalLine."Shortcut Dimension 2 Code";
        DtldVendLedgEntry."Initial Entry Global Dim. 3" := GenJournalLine."Shortcut Dimension 3 Code";
        DtldVendLedgEntry."Initial Entry Global Dim. 4" := GenJournalLine."Shortcut Dimension 4 Code";
        DtldVendLedgEntry."Initial Entry Global Dim. 5" := GenJournalLine."Shortcut Dimension 5 Code";


    end;
    #endregion Codeunit12
    #region Codeunit74
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Get Receipt", 'OnAfterPurchRcptLineSetFilters', '', false, false)]
    local procedure OnAfterPurchRcptLineSetFilters(var PurchRcptLine: Record "Purch. Rcpt. Line"; PurchaseHeader: Record "Purchase Header")
    var
        rPed: Record "Purchase Header";
        rLin: Record "Purchase Line";
        PurchRcptHeader: Record "Purch. Rcpt. Header";
        Calculo: Record "Calculo Albaranes";
    //PurchRcptLine: Record "Purch. Rcpt. Line";
    begin
        PurchRcptLine.SetRange("Buy-from Vendor No.");

        //Solo para union agricola, ya que no hay pedidos
        if COMPANYNAME in [glUnion, glUATI] THEN BEGIN
            if PurchaseHeader."Currency Code" IN ['', 'EUR'] THEN BEGIN
                PurchRcptLine.SETFILTER("Currency Code", '%1|%2', '', 'EUR');
                if PurchRcptLine.FINDFIRST THEN
                    REPEAT
                        PurchRcptLine.CALCFIELDS(Facturado);
                        if PurchRcptHeader.GET(PurchRcptLine."Document No.") then begin
                            if Calculo.Get(PurchRcptHeader."No.") Then Begin Calculo.Calculado := False; Calculo.Modify() End;
                            PurchRcptHeader."Currency Code" := PurchaseHeader."Currency Code";
                            PurchRcptHeader.MODIFY;
                        end;
                        if NOT rLin.GET(rLin."Document Type"::Order, PurchRcptLine."Order No.",
                                        PurchRcptLine."Order Line No.") THEN BEGIN
                            rLin.TRANSFERFIELDS(PurchRcptLine);
                            rLin."Document Type" := rLin."Document Type"::Order;
                            rLin."Document No." := PurchRcptLine."Order No.";
                            rLin."Line No." := PurchRcptLine."Order Line No.";
                            rLin."Qty. to Invoice" := rLin.Quantity;
                            rLin."Qty. Rcd. Not Invoiced" := rLin.Quantity;
                            rLin."Quantity Received" := rLin.Quantity;
                            rLin."Qty. Rcd. Not Invoiced (Base)" := rLin."Quantity (Base)";
                            rLin."Qty. Received (Base)" := rLin."Quantity (Base)";
                            rLin."Quantity Invoiced" := 0;
                            rLin.INSERT;
                        END;
                        if NOT rPed.GET(rPed."Document Type"::Order, PurchRcptLine."Order No.") THEN BEGIN
                            rPed.TRANSFERFIELDS(PurchRcptHeader);
                            rPed."Document Type" := rPed."Document Type"::Order;
                            rPed."No." := PurchRcptLine."Order No.";
                            rPed.Status := rPed.Status::Released;
                            rPed.INSERT;
                        END;
                    UNTIL PurchRcptLine.NEXT = 0;

                COMMIT;
            END;
        END;
    end;
    #endregion Codeunit74
    #region Codeunit80

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnBeforeValidatePostingAndDocumentDate', '', false, false)]
    local procedure OnBeforeValidatePostingAndDocumentDate(var SalesHeader: Record "Sales Header"; CommitIsSuppressed: Boolean)
    begin
        SalesHeader."Fecha Vencimiento" := SalesHeader."Due Date";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnAfterValidatePostingAndDocumentDate', '', false, false)]
    local procedure OnAfterValidatePostingAndDocumentDate(var SalesHeader: Record "Sales Header"; CommitIsSuppressed: Boolean; PreviewMode: Boolean; ReplacePostingDate: Boolean; ReplaceDocumentDate: Boolean)
    begin
        if SalesHeader."Fecha Vencimiento" <> 0D then
            if SalesHeader."Due Date" <> SalesHeader."Fecha Vencimiento" Then begin
                SalesHeader."Due Date" := SalesHeader."Fecha Vencimiento";
                SalesHeader.Modify();
            End;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnBeforeSalesShptHeaderInsert', '', false, false)]
    local procedure OnBeforeSalesShptHeaderInsert(var SalesShptHeader: Record "Sales Shipment Header"; SalesHeader: Record "Sales Header"; CommitIsSuppressed: Boolean; var IsHandled: Boolean; var TempWhseRcptHeader: Record "Warehouse Receipt Header" temporary; WhseReceive: Boolean; var TempWhseShptHeader: Record "Warehouse Shipment Header" temporary; WhseShip: Boolean)
    var
        GlSetup: Record "General Ledger Setup";
        VATBusPostGrp: Record "VAT Business Posting Group";
    begin

        //-SII
        if GLSetup."Activar SII" THEN BEGIN
            VATBusPostGrp.GET(SalesShptHeader."VAT Bus. Posting Group");
            SalesShptHeader."Clave registro SII expedidas" := VATBusPostGrp."Clave registro SII expedidas";
        END;
        //+SII
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnBeforeReturnRcptHeaderInsert', '', false, false)]
    local procedure OnBeforeReturnRcptHeaderInsert(var ReturnRcptHeader: Record "Return Receipt Header"; SalesHeader: Record "Sales Header"; CommitIsSuppressed: Boolean; var TempWhseRcptHeader: Record "Warehouse Receipt Header" temporary; WhseReceive: Boolean; var TempWhseShptHeader: Record "Warehouse Shipment Header" temporary; WhseShip: Boolean)
    var
        GlSetup: Record "General Ledger Setup";
        VATBusPostGrp: Record "VAT Business Posting Group";
    begin

        //-SII
        if GLSetup."Activar SII" THEN BEGIN
            VATBusPostGrp.GET(ReturnRcptHeader."VAT Bus. Posting Group");
            ReturnRcptHeader."Clave registro SII expedidas" := VATBusPostGrp."Clave registro SII expedidas";
        END;
        //+SII
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnValidatePostingAndDocumentDateOnAfterCalcPostingDateExists', '', false, false)]
    local procedure OnValidatePostingAndDocumentDateOnAfterCalcPostingDateExists(var PostingDateExists: Boolean; var ReplacePostingDate: Boolean; var ReplaceDocumentDate: Boolean; var PostingDate: Date; var SalesHeader: Record "Sales Header")
    begin
        if ReplacePostingDate Then SalesHeader."Vat Reporting Date" := PostingDate;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnBeforeSalesShptLineInsert', '', false, false)]
    local procedure OnBeforeSalesShptLineInsert(var SalesShptLine: Record "Sales Shipment Line"; SalesShptHeader: Record "Sales Shipment Header"; SalesLine: Record "Sales Line"; CommitIsSuppressed: Boolean; PostedWhseShipmentLine: Record "Posted Whse. Shipment Line"; SalesHeader: Record "Sales Header"; WhseShip: Boolean; WhseReceive: Boolean; ItemLedgShptEntryNo: Integer; xSalesLine: record "Sales Line"; var TempSalesLineGlobal: record "Sales Line" temporary; var IsHandled: Boolean)
    begin
        if SalesHeader."Pedido standard" THEN
            SalesShptHeader."Albarán Venta" := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnBeforeSalesInvHeaderInsert', '', false, false)]
    local procedure OnBeforeSalesInvHeaderInsert(var SalesInvHeader: Record "Sales Invoice Header"; var SalesHeader: Record "Sales Header"; CommitIsSuppressed: Boolean; var IsHandled: Boolean)
    var
        GlSetup: Record "General Ledger Setup";
        VATBusPostGrp: Record "VAT Business Posting Group";
        rContrato: Record "Sales Header";
        rLinDetFra: Record "Sales Comment Line";
        rLinDetFraDef: Record "Sales Comment Line";
        Cust: Record Customer;
        Fac: Record 38;
    begin
        if SalesHeader."Factura Compra" <> '' Then begin
            Fac.ChangeCompany(Salesheader."Empresa Origen Alb");
            Fac.Get(Fac."Document Type"::Invoice, SalesHeader."Factura Compra");
            Fac."Vendor Invoice No." := SalesInvHeader."No.";
            Fac."Posting Date" := SalesInvHeader."Posting Date";
            Fac."Document Date" := SalesInvHeader."Document Date";
            Fac."VAT Reporting Date" := SalesInvHeader."VAT Reporting Date";
            if Fac."Empresa Factura" = '' Then
                Fac."Empresa Factura" := SalesHeader."Empresa Origen Alb";
            Fac.ContabilizaInter := true;
            Fac.Modify();
        end;
        if Cust.GET(SalesInvHeader."Sell-to Customer No.") THEN
            if Cust."Permite Efactura" THEN
                SalesInvHeader."Situación Efactura" := SalesInvHeader."Situación Efactura"::"Pendiente";
        SalesInvHeader."Cod cadena" := Cust."Cod cadena";
        //-SII
        if GLSetup."Activar SII" THEN BEGIN
            VATBusPostGrp.GET(SalesInvHeader."VAT Bus. Posting Group");
            SalesInvHeader."Clave registro SII expedidas" := VATBusPostGrp."Clave registro SII expedidas";
        END;

        //$005(I)
        //if "Creado por anulación" THEN BEGIN                                          //$006
        SalesInvHeader."Prepayment Invoice" := SalesHeader."Factura prepago";
        SalesInvHeader."Prepayment Order No." := SalesHeader."Nº pedido prepago";
        SalesInvHeader."Pte Contabilicación" := true;
        //END;                                                                          //$006
        //$005(F)  
        if rContrato.GET(rContrato."Document Type"::Order, SalesHeader."Nº Contrato") THEN BEGIN
            if rContrato."Customer Order No." <> '' THEN
                SalesInvHeader."Customer Order No." := rContrato."Customer Order No."
        END;
        //Lineas de factura de impresión
        rLinDetFra.SETRANGE("Document Type", rLinDetFra."Document Type"::"Detalle Factura");
        rLinDetFra.SETRANGE("No.", SalesHeader."No.");
        rLinDetFra.SETRANGE(rLinDetFra.Validada);
        if rLinDetFra.FINDFIRST THEN
            REPEAT
                rLinDetFraDef := rLinDetFra;
                rLinDetFraDef."Document Type" := rLinDetFraDef."Document Type"::"Detalle Fac. Reg";
                rLinDetFraDef.INSERT;
            UNTIL rLinDetFra.NEXT = 0;

        //$006(I)
        if SalesHeader."Factura prepago" THEN BEGIN
            if rContrato.GET(rContrato."Document Type"::Order, SalesHeader."Nº Contrato") THEN BEGIN
                rContrato."Last Prepayment No." := SalesInvHeader."No.";
                rContrato.MODIFY;
            END;
        END;

        //$006(F) 
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnBeforeSalesCrMemoHeaderInsert', '', false, false)]
    local procedure OnBeforeSalesInvCrMemoInsert(var SalesCrMemoHeader: Record "Sales Cr.Memo Header"; var SalesHeader: Record "Sales Header"; CommitIsSuppressed: Boolean; var IsHandled: Boolean)
    var
        GlSetup: Record "General Ledger Setup";
        VATBusPostGrp: Record "VAT Business Posting Group";
        rContrato: Record "Sales Header";
        rLinDetFra: Record "Sales Comment Line";
        rLinDetFraDef: Record "Sales Comment Line";
    begin

        //-SII
        if GLSetup."Activar SII" THEN BEGIN
            VATBusPostGrp.GET(SalesCrMemoHeader."VAT Bus. Posting Group");
            SalesCrMemoHeader."Clave registro SII expedidas" := VATBusPostGrp."Clave registro SII expedidas";
        END;
        SalesCrMemoHeader."Pte Contabilicación" := true;
        //Lineas de factura de impresión
        rLinDetFra.SETRANGE("Document Type", rLinDetFra."Document Type"::"Detalle Abono");
        rLinDetFra.SETRANGE("No.", SalesHeader."No.");
        rLinDetFra.SETRANGE(rLinDetFra.Validada);
        if rLinDetFra.FINDFIRST THEN
            REPEAT
                rLinDetFraDef := rLinDetFra;
                rLinDetFraDef."Document Type" := rLinDetFraDef."Document Type"::"Detalle Abo. Reg";
                rLinDetFraDef.INSERT;
            UNTIL rLinDetFra.NEXT = 0;

        //$006(F) 
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnAfterCheckMandatoryFields', '', false, false)]
    local procedure OnAfterCheckMandatoryFields(var SalesHeader: Record "Sales Header"; CommitIsSuppressed: Boolean)
    begin

        SalesHeader.TESTFIELD("Document Type");
        SalesHeader.TESTFIELD("Sell-to Customer No.");
        SalesHeader.TESTFIELD("Bill-to Customer No.");
        SalesHeader.TESTFIELD("Posting Date");
        SalesHeader.TESTFIELD("Document Date");
        SalesHeader.TESTFIELD("Salesperson Code");                       //FCL-25/05/05
        if COMPANYNAME <> 'UNION AGRICOLA Y TURISTICA, SL' THEN
            SalesHeader.TESTFIELD("VAT Registration No.");
        if SalesHeader."Pedido standard" then exit;
        if SalesHeader."Albarán Empresa Origen" = '' THEN
            SalesHeader.TESTFIELD("Nº Proyecto");                                //MNC001
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnBeforePostCommitSalesDoc', '', false, false)]
    local procedure OnBeforePostCommitSalesDoc(var SalesHeader: Record "Sales Header"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; PreviewMode: Boolean; var ModifyHeader: Boolean; var CommitIsSuppressed: Boolean; var TempSalesLineGlobal: Record "Sales Line" temporary)
    Var
        ModifyHeaderSII: boolean;
        GestiónSII: Report "Gestión SII";
        GLSetup: Record "General Ledger Setup";
    begin

        //-SII
        //-SII 3.0
        CLEAR(ModifyHeaderSII);
        //+SII 3.0
        GLSetup.GET;
        if GLSetup."Activar SII" THEN BEGIN
            //-SII1
            if NOT SalesHeader."Obviar SII" THEN
                //-SII 3.0
                //GestiónSII.CheckPurchRequiredFields(PurchHeader,ModifyHeader);
                GestiónSII.CheckSalesRequiredFields(SalesHeader, ModifyHeaderSII);
            //+SII 3.0
            //+SII1
            //-SII 3.0
            if ModifyHeaderSII THEN
                ModifyHeader := ModifyHeaderSII;
            //+SII 3.0
        END;
        //+SII
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnBeforePostSalesDoc', '', false, false)]
    local procedure OnBeforePostSalesDoc(var SalesHeader: Record "Sales Header"; CommitIsSuppressed: Boolean; PreviewMode: Boolean; var HideProgressWindow: Boolean)
    Var
        GestiónSII: Report "Gestión SII";
        rLinDetFra: Record "Sales Comment Line";
        GlSetup: Record "General Ledger Setup";
        rContr: Record 36;
    begin


        if ((SalesHeader."Factura prepago" = FALSE) or (SalesHeader."Prepago Nuevo"))
        and (SalesHeader."Document Type" = SalesHeader."Document Type"::Invoice) THEN begin
            if rContr.GET(rContr."Document Type"::Order, SalesHeader."Nº Contrato") THEN
                if rContr.Estado <> rContr.Estado::Firmado THEN ERROR('El Contrato No esta firmado');
        End;
        if SalesHeader."Esperar Orden Cliente" <> SalesHeader."Esperar Orden Cliente"::No THEN
            Error('No se puede facturar. Revisar el campo Esperar Orden Cliente');
        //-SII
        CLEAR(GestiónSII);
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

        // if PostingDateExists AND (ReplacePostingDate OR ("Posting Date" = 0D)) THEN BEGIN
        // "Posting Date" := PostingDate;
        // "Document Date":= PostingDate;
        // //  VALIDATE("Document Date");
        // VALIDATE("Currency Code");
        //END;
        if SalesHeader."Esperar Orden Cliente" <> SalesHeader."Esperar Orden Cliente"::No THEN ERROR('Está marcado el campo Esperar orden Cliente');
        //ASC Lineas de Impresion
        rLinDetFra.SETRANGE("Document Type", rLinDetFra."Document Type"::"Detalle Factura");
        rLinDetFra.SETRANGE("No.", SalesHeader."No.");
        rLinDetFra.SETRANGE(rLinDetFra.Validada, FALSE);
        if rLinDetFra.FINDFIRST THEN ERROR('Hay líneas de impresión sin validar');

        //if PostingDateExists AND (ReplaceDocumentDate OR ("Document Date" = 0D)) THEN BEGIN
        //  VALIDATE("Document Date",PostingDate);    // Parche registro lotes MNC 310399
        SalesHeader."Document Date" := SalesHeader."Posting Date";              // Parche registro lotes MNC 310399
                                                                                //  SalesHeader.ValidatePaymentTerms();
    END;




#if not CLEAN22
    // TODO: - CLEAN22
#if not CLEAN27
#pragma warning disable AL0432 // TODO: - Invoice Posting Buffer codunit 825
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnBeforeFillInvoicePostingBuffer', '', false, false)]
    local procedure OnBeforeFillInvoicePostingBuffer(SalesHeader: Record "Sales Header"; SalesLine: Record "Sales Line"; SalesLineACY: Record "Sales Line"; var TempInvoicePostBuffer: Record "Invoice Post. Buffer" temporary; var InvoicePostBuffer: Record "Invoice Post. Buffer"; var IsHandled: Boolean)


    var
        SelesDesgl: Record "Sales Shipment Line";
        SalesDesglLCY: Record "Sales Shipment Line";
        GenPostingSetup: Record "General Posting Setup";
        SalesPostPrepayments: Codeunit "Sales-Post Prepayments";
        AdjAmount: Decimal;
        TotalVAT: Decimal;
        TotalVATACY: Decimal;
        TotalAmount: Decimal;
        TotalAmountACY: Decimal;
        AmtToDefer: Decimal;
        AmtToDeferACY: Decimal;
        TotalVATBase: Decimal;
        TotalVATBaseACY: Decimal;
        DeferralAccount: Code[20];
        SalesAccount: Code[20];
        InvDiscAccount: code[20];
        LineDiscAccount: code[20];
        InvoiceDiscountPosting: Boolean;
        LineDiscountPosting: Boolean;
        FalineNo: Integer;
    begin

        IsHandled := True;
        TempInvoicePostBuffer.Deleteall;
        with SalesHeader do begin
            SelesDesgl.SETRANGE(SelesDesgl."Document No.", "Posting No.");
            if SelesDesgl.FINDFIRST THEN
                REPEAT
                    SalesDesglLCY := SelesDesgl;
                    if NOT ("Document Type" IN ["Document Type"::"Return Order", "Document Type"::"Credit Memo"]) THEN BEGIN
                        SelesDesgl."Line Amount" := -SelesDesgl."Line Amount";
                        SelesDesgl.Amount := -SelesDesgl.Amount;
                        SelesDesgl."VAT Base Amount" := -SelesDesgl."VAT Base Amount";
                        SelesDesgl."VAT Difference" := -SelesDesgl."VAT Difference";
                        SelesDesgl."Amount Including VAT" := -SelesDesgl."Amount Including VAT";
                        SelesDesgl."Line Discount Amount" := -SelesDesgl."Line Discount Amount";
                        SelesDesgl."Inv. Discount Amount" := -SelesDesgl."Inv. Discount Amount";
                        SelesDesgl."Pmt. Disc. Given Amount" := -SelesDesgl."Pmt. Disc. Given Amount";
                        SalesDesglLCY."Line Amount" := -SalesDesglLCY."Line Amount";
                        SalesDesglLCY.Amount := -SalesDesglLCY.Amount;
                        SalesDesglLCY."VAT Base Amount" := -SalesDesglLCY."VAT Base Amount";
                        SalesDesglLCY."VAT Difference" := -SalesDesglLCY."VAT Difference";
                        SalesDesglLCY."Amount Including VAT" := -SalesDesglLCY."Amount Including VAT";
                        SalesDesglLCY."Line Discount Amount" := -SalesDesglLCY."Line Discount Amount";
                        SalesDesglLCY."Inv. Discount Amount" := -SalesDesglLCY."Inv. Discount Amount";
                        SalesDesglLCY."Pmt. Disc. Given Amount" := -SalesDesglLCY."Pmt. Disc. Given Amount";

                    END;
                    ContabAlb.FillInvPostingBufferDesglo(SelesDesgl, SalesDesglLCY, InvoicePostBuffer, SalesHeader, FalineNo, TempInvoicePostBuffer);
                UNTIL SelesDesgl.NEXT = 0;

        end;
    end;
#endif
    // TODO: - CLEAN22
#pragma warning restore AL0432 // TODO: - Invoice Posting Buffer codunit 825
#endif



    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnBeforePostJobContractLine', '', false, false)]
    local procedure OnBeforePostJobContractLine(SalesHeader: Record "Sales Header"; SalesLine: Record "Sales Line"; var IsHandled: Boolean; var JobContractLine: Boolean)
    var
        JonPostingLine: Codeunit "Job Post-Line";
        Job: Record Job;
        JT: Record "Job Task";
        JobLedgEntry: Record "Job Ledger Entry";
        JobPlanningLine: Record "Job Planning Line";
        Factor: Integer;
        Txt: Text[500];
        SalesLine2: Record "Sales Line";
        SalesHeader2: Record "Sales Header";
        Text000: label 'se ha cambiado (inicial a %1: %2= %3, %4= %5)';
        QtyBase: Decimal;
        Text001: Label 'Debe consumir %1 %2 en %3 %4 antes de registrar la factura de ventas %5 %6 = %7.';
        Item: Record Item;
        JobJnlPostLine: Codeunit "Job Jnl.-Post Line";
        JobTransferLine: Codeunit "Job Transfer Line";
        JobJnlLine: Record "Job Journal Line";
        EntryType: enum "Job Journal Line Entry Type";// Option Usage,Sale;
    begin
        if SalesLine."Job Contract Entry No." <> 0 Then Exit;
        if SalesLine."Document Type" = SalesLine."Document Type"::Order Then Exit;
        if ((SalesLine."Job No." <> '') AND (SalesLine."Job Task No." <> '')) THEN begin

            if (SalesHeader."Document Type" <> SalesHeader."Document Type"::Invoice) AND
            (SalesHeader."Document Type" <> SalesHeader."Document Type"::"Credit Memo")
            THEN
                SalesLine.TESTFIELD("Job Contract Entry No.", 0);

            SalesLine.TESTFIELD("Job No.");
            SalesLine.TESTFIELD("Job Task No.");
            SalesHeader2.Get(SalesHeader."Document Type", SalesHeader."No.");
            SalesLine2.Get(SalesLine."Document Type", SalesLine."Document No.", SalesLine."Line No.");
            if SalesHeader."Document Type" = SalesHeader."Document Type"::Invoice THEN
                SalesLine2."Document No." := SalesHeader."Posting No.";
            if SalesHeader."Document Type" = SalesHeader."Document Type"::"Credit Memo" THEN
                SalesLine2."Document No." := SalesHeader."Posting No.";

            JobPlanningLine.SETRANGE("Job No.", SalesLine2."Job No.");
            JobPlanningLine.SETRANGE("Job Task No.", SalesLine2."Job Task No.");
            JobPlanningLine.SETRANGE("No.", SalesLine2."No.");
            if NOT JobPlanningLine.FINDFIRST THEN EXIT;
            Job.GET(SalesLine2."Job No.");
            JT.GET(SalesLine2."Job No.", SalesLine2."Job Task No.");
            // $001 +

            Txt := STRSUBSTNO(Text000,
                JT.TABLECAPTION, JT.FIELDCAPTION("Job No."), JT."Job No.",
                JT.FIELDCAPTION("Job Task No."), JT."Job Task No.");

            // if NOT SalesHeader2."Currency Code" THEN BEGIN
            Job.TESTFIELD("Currency Code", SalesHeader2."Currency Code");
            Job.TESTFIELD("Currency Code", JobPlanningLine."Currency Code");
            SalesHeader.TESTFIELD("Currency Code", JobPlanningLine."Currency Code");
            SalesHeader.TESTFIELD("Currency Factor", JobPlanningLine."Currency Factor");
            // END ELSE BEGIN
            // Job.TESTFIELD("Currency Code",'');
            // JobPlanningLine.TESTFIELD("Currency Code",'');
            // END;
            // $001 -
            // // // $001 +

            JobPlanningLine."Invoiced Amount (LCY)" := JobPlanningLine."Line Amount (LCY)";
            JobPlanningLine."Invoiced Cost Amount (LCY)" := JobPlanningLine."Total Cost (LCY)";
            // JobPlanningLine.Invoiced := TRUE;
            // JobPlanningLine."Invoiced Date" := SalesHeader."Posting Date";
            // if SalesHeader2."Document Type" = SalesHeader."Document Type"::Invoice THEN BEGIN
            // JobPlanningLine."Invoice Type" := JobPlanningLine."Invoice Type"::"Posted Invoice";
            // JobPlanningLine."Invoice No." := SalesLine."Document No.";
            // END;
            // if SalesHeader."Document Type" = SalesHeader."Document Type"::"Credit Memo" THEN BEGIN
            // JobPlanningLine."Invoice Type" := JobPlanningLine."Invoice Type"::"Posted Credit Memo";
            // JobPlanningLine."Invoice No." := SalesLine."Document No.";
            // END;
            if NOT JobLedgEntry.FIND('+') THEN EXIT;
            JobPlanningLine."Job Ledger Entry No." := JobLedgEntry."Entry No." + 1;
            JobPlanningLine.MODIFY;

            if JobPlanningLine.Type = JobPlanningLine.Type::Item THEN begin
                Item.Get(SalesLine2."No.");
                CLEAR(JobLedgEntry);
                WITH JobLedgEntry DO BEGIN
                    SETRANGE("Job No.", JobPlanningLine."Job No.");
                    SETRANGE(Type, Type::Item);
                    SETRANGE("No.", JobPlanningLine."No.");
                    if FIND('-') THEN
                        REPEAT
                            if ("Location Code" = JobPlanningLine."Location Code") AND
                                ("Variant Code" = JobPlanningLine."Variant Code")
                            THEN
                                QtyBase := QtyBase + "Quantity (Base)";
                        UNTIL NEXT = 0;
                    if (QtyBase - JobPlanningLine."Quantity (Base)") < 0 THEN
                        ERROR(
                        Text001, Item.TABLECAPTION, "No.", Job.TABLECAPTION,
                        "Job No.", Salesheader."No.",
                        Salesline.FIELDCAPTION("Line No."), Salesline."Line No.");
                END;
            end;

            if JobPlanningLine.Type <> JobPlanningLine.Type::Text THEN begin
                EntryType := EntryType::Sale;
                JobTransferLine.FromPlanningSalesLinetoJnlLine(JobPlanningLine, SalesHeader2, SalesLine2, JobJnlLine, EntryType);
                JobJnlPostLine.RunWithCheck(JobJnlLine);
            end;
            JobContractLine := TRUE;
        end;
    end;

    // local procedure OnAfterCopyToTempLines(var TempSalesLine: Record "Sales Line" temporary; SalesHeader: Record "Sales Header")
    // var
    //     SelesDesgl: Record "Sales Shipment Line";
    // begin
    //     SelesDesgl.SETRANGE(SelesDesgl."Document No.", SalesHeader."Posting No.");
    //     if Not SelesDesgl.FINDFIRST Then Exit;
    //     TempSalesLine.Deleteall;
    //     if SelesDesgl.FINDFIRST THEN
    //         REPEAT
    //             TempSalesLine.TransferFields(SelesDesgl);
    //             TempSalesLine."Document Type" := SalesHeader."Document Type";
    //             TempSalesLine."Document No." := SalesHeader."No.";
    //             TempSalesLine."Tax Area Code" := SalesHeader."Posting No.";
    //             TempSalesLine.Insert;
    //         UNTIL SelesDesgl.NEXT = 0;
    // end;
#pragma warning disable AL0432

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnBeforePostSalesLines', '', false, false)]
    local procedure OnBeforePostSalesLines(var SalesHeader: Record "Sales Header"; var TempSalesLineGlobal: Record "Sales Line" temporary; var TempVATAmountLine: Record "VAT Amount Line" temporary)
    begin
#pragma warning restore AL0432
        if SalesHeader."Document Type" in [SalesHeader."Document Type"::Invoice, SalesHeader."Document Type"::"Credit Memo"] Then
            ContabAlb.Desglosar(SalesHeader);
        // OnAfterCopyToTempLines(TempSalesLineGlobal, SalesHeader);
    end;

    // [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnAfterPostSalesLines', '', false, false)]
    // local procedure OnAfterPostSalesLines(var SalesHeader: Record "Sales Header"; var SalesShipmentHeader: Record "Sales Shipment Header"; var SalesInvoiceHeader: Record "Sales Invoice Header"; var SalesCrMemoHeader: Record "Sales Cr.Memo Header"; var ReturnReceiptHeader: Record "Return Receipt Header"; WhseShip: Boolean; WhseReceive: Boolean; var SalesLinesProcessed: Boolean; CommitIsSuppressed: Boolean; EverythingInvoiced: Boolean; var TempSalesLineGlobal: Record "Sales Line" temporary)
    // var
    //     SalesLines: Record "Sales Line";
    // begin
    //     SalesLines.SETRANGE(SalesLines."Document Type", SalesHeader."Document Type");
    //     SalesLines.SETRANGE(SalesLines."Document No.", SalesHeader."No.");
    //     TempSalesLineGlobal.Deleteall;
    //     if SalesLines.FINDFIRST THEN
    //         REPEAT
    //             TempSalesLineGlobal := SalesLines;
    //             TempSalesLineGlobal.Insert;
    //         UNTIL SalesLines.NEXT = 0;
    // end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales Post Invoice Events", 'OnBeforePostLines', '', false, false)]
    local procedure OnBeforePostLines(SalesHeader: Record "Sales Header"; var TempInvoicePostingBuffer: Record "Invoice Posting Buffer" temporary)
    var
        SelesDesgl: Record "Sales Shipment Line";
        SalesDesglLCY: Record "Sales Shipment Line";
        GenPostingSetup: Record "General Posting Setup";
        SalesPostPrepayments: Codeunit "Sales-Post Prepayments";
        AdjAmount: Decimal;
        TotalVAT: Decimal;
        TotalVATACY: Decimal;
        TotalAmount: Decimal;
        TotalAmountACY: Decimal;
        AmtToDefer: Decimal;
        AmtToDeferACY: Decimal;
        TotalVATBase: Decimal;
        TotalVATBaseACY: Decimal;
        DeferralAccount: Code[20];
        SalesAccount: Code[20];
        InvDiscAccount: code[20];
        LineDiscAccount: code[20];
        InvoiceDiscountPosting: Boolean;
        LineDiscountPosting: Boolean;
        FalineNo: Integer;
        TempInvoiceBuffer: Record "Invoice Posting Buffer" temporary;
    begin
        SelesDesgl.SETRANGE(SelesDesgl."Document No.", SalesHeader."Posting No.");
        if SelesDesgl.FINDSET Then begin
            TempInvoicePostingBuffer.Deleteall;
            Repeat

                SalesDesglLCY := SelesDesgl;

                if NOT (SalesHeader."Document Type" IN [SalesHeader."Document Type"::"Return Order", SalesHeader."Document Type"::"Credit Memo"]) THEN BEGIN
                    SelesDesgl."Line Amount" := -SelesDesgl."Line Amount";
                    SelesDesgl.Amount := -SelesDesgl.Amount;
                    SelesDesgl."VAT Base Amount" := -SelesDesgl."VAT Base Amount";
                    SelesDesgl."VAT Difference" := -SelesDesgl."VAT Difference";
                    SelesDesgl."Amount Including VAT" := -SelesDesgl."Amount Including VAT";
                    SelesDesgl."Line Discount Amount" := -SelesDesgl."Line Discount Amount";
                    SelesDesgl."Inv. Discount Amount" := -SelesDesgl."Inv. Discount Amount";
                    SelesDesgl."Pmt. Disc. Given Amount" := -SelesDesgl."Pmt. Disc. Given Amount";
                    SalesDesglLCY."Line Amount" := -SalesDesglLCY."Line Amount";
                    SalesDesglLCY.Amount := -SalesDesglLCY.Amount;
                    SalesDesglLCY."VAT Base Amount" := -SalesDesglLCY."VAT Base Amount";
                    SalesDesglLCY."VAT Difference" := -SalesDesglLCY."VAT Difference";
                    SalesDesglLCY."Amount Including VAT" := -SalesDesglLCY."Amount Including VAT";
                    SalesDesglLCY."Line Discount Amount" := -SalesDesglLCY."Line Discount Amount";
                    SalesDesglLCY."Inv. Discount Amount" := -SalesDesglLCY."Inv. Discount Amount";
                    SalesDesglLCY."Pmt. Disc. Given Amount" := -SalesDesglLCY."Pmt. Disc. Given Amount";

                END;

                ContabAlb.FillInvPostingBufferDesgloNew(SelesDesgl, SalesDesglLCY, TempInvoicePostingBuffer, SalesHeader, FalineNo, TempInvoiceBuffer);
            until SelesDesgl.NEXT = 0;
            TempInvoiceBuffer.Reset();
            if TempInvoiceBuffer.FINDset THEN
                REPEAT
                    TempInvoicePostingBuffer := TempInvoiceBuffer;
                    TempInvoicePostingBuffer.Insert();
                UNTIL TempInvoiceBuffer.NEXT = 0;
        end;


    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales Post Invoice Events", 'OnAfterPrepareGenJnlLine', '', false, false)]
    local procedure OnAfterPrepareGenJnlLine(var GenJnlLine: Record "Gen. Journal Line"; SalesHeader: Record "Sales Header"; InvoicePostingBuffer: Record "Invoice Posting Buffer")
    var
        GLSetup: Record "General Ledger Setup";
    begin
        //ASC
        GenJnlLine."Shortcut Dimension 1 Code" := InvoicePostingBuffer."Global Dimension 1 Code";
        GenJnlLine."Shortcut Dimension 2 Code" := InvoicePostingBuffer."Global Dimension 2 Code";
        GenJnlLine."Shortcut Dimension 3 Code" := InvoicePostingBuffer."Global Dimension 3 Code";
        GenJnlLine."Shortcut Dimension 4 Code" := InvoicePostingBuffer."Global Dimension 4 Code";
        GenJnlLine."Shortcut Dimension 5 Code" := InvoicePostingBuffer."Global Dimension 5 Code";
        GenJnlLine."Dimension Set ID" := InvoicePostingBuffer."Dimension Set ID";

        //GenJnlLine.Circuito:=Agrupado;

        //-SII
        GLSetup.GET;
        if GLSetup."Activar SII" THEN BEGIN
            GenJnlLine."Tipo factura SII" := InvoicePostingBuffer."Tipo factura SII";
            GenJnlLine."Clave registro SII expedidas" := InvoicePostingBuffer."Clave registro SII expedidas";
            GenJnlLine."Clave registro SII recibidas" := InvoicePostingBuffer."Clave registro SII recibidas";
            GenJnlLine."Descripción operación" := InvoicePostingBuffer."Descripción operación";
            GenJnlLine."Tipo desglose recibidas" := InvoicePostingBuffer."Tipo desglose recibidas";
            GenJnlLine."Sujeta exenta" := InvoicePostingBuffer."Sujeta exenta";
            GenJnlLine."Tipo de operación" := InvoicePostingBuffer."Tipo de operación";
            GenJnlLine."Tipo factura rectificativa" := InvoicePostingBuffer."Tipo factura rectificativa";
        END;
        //+SII
    end;
    // [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnBeforePostInvoicePostBuffer', '', false, false)]
    // local procedure OnBeforePostInvoicePostBuffer(SalesHeader: Record "Sales Header"; var TempInvoicePostBuffer: Record "Invoice Post. Buffer" temporary; var TotalSalesLine: Record "Sales Line"; var TotalSalesLineLCY: Record "Sales Line")
    // begin
    //  Is   
    // end;
    // [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnAfterPostSalesDoc', '', false, false)]
    // [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnAfterPostSalesDoc', '', false, false)]
    // local procedure OnAfterPostSalesDoc(var SalesHeader: Record "Sales Header"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; SalesShptHdrNo: Code[20]; RetRcpHdrNo: Code[20]; SalesInvHdrNo: Code[20]; SalesCrMemoHdrNo: Code[20]; CommitIsSuppressed: Boolean; InvtPickPutaway: Boolean; var CustLedgerEntry: Record "Cust. Ledger Entry"; WhseShip: Boolean; WhseReceiv: Boolean)
    // var
    //     GestiónSII: Report "Gestión SII";
    //     SalesInvHeader: Record "Sales Invoice Header";
    //     SalesCrMemoHeader: Record "Sales Cr.Memo Header";
    //     GlSetup: Record "General Ledger Setup";
    // begin
    //     if Not SalesInvHeader.Get(SalesInvHdrNo) Then SalesInvHeader.Init;
    //     if Not SalesCrMemoHeader.Get(SalesCrMemoHdrNo) Then SalesCrMemoHeader.Init();
    //     //-SII
    //     GLSetup.GET;
    //     if GLSetup."Activar SII" THEN
    //         //-SII1
    //         if NOT SalesHeader."Obviar SII" THEN
    //             //+SII1

    //             GestiónSII.CreateOrUpdateFileSales(SalesInvHeader, SalesCrMemoHeader, (SalesHeader."Document Type"
    //             IN [SalesHeader."Document Type"::Order, SalesHeader."Document Type"::Invoice])
    //             AND (SalesHeader."Corrected Invoice No." <> ''));

    //     //+SII
    // end;

#if not CLEAN22
    // TODO: - CLEAN22
#if not CLEAN27
#pragma warning disable AL0432 // TODO: - Invoice Posting Buffer codunit 825
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnBeforePostBalancingEntry', '', false, false)]

    local procedure OnBeforePostSalesBalancingEntry(var GenJnlLine: Record "Gen. Journal Line"; SalesHeader: Record "Sales Header"; var TotalSalesLine: Record "Sales Line"; var TotalSalesLineLCY: Record "Sales Line"; CommitIsSuppressed: Boolean; PreviewMode: Boolean)
    var
        GlSetup: Record "General Ledger Setup";
        VatBusPostGrp: Record "VAT Business Posting Group";
    begin

        //-SII
        GLSetup.GET;
        if GLSetup."Activar SII" THEN BEGIN
            GenJnlLine."Tipo factura SII" := SalesHeader."Tipo factura SII";
            VATBusPostGrp.GET(SalesHeader."VAT Bus. Posting Group");
            GenJnlLine."Clave registro SII expedidas" := VATBusPostGrp."Clave registro SII expedidas";
            GenJnlLine."Descripción operación" := SalesHeader."Descripción operación";
            GenJnlLine."Tipo factura rectificativa" := SalesHeader."Tipo factura rectificativa";
        END;
        //+SII
    end;
#endif
    // TODO: - CLEAN22
#pragma warning restore AL0432 // TODO: - Invoice Posting Buffer codunit 825
#endif


    #endregion Codeunit80
    #region Codeunit90
#if not CLEAN22
#if not CLEAN27
#pragma warning disable AL0432 // TODO: - Invoice Posting Buffer codunit 825
    // TODO: - CLEAN22

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", 'OnBeforeFillInvoicePostBuffer', '', false, false)]
    local procedure OnBeforeFillInvoicePostBuffer(PurchHeader: Record "Purchase Header"; PurchLine: Record "Purchase Line"; PurchLineACY: Record "Purchase Line"; InvoicePostBuffer: Record "Invoice Post. Buffer"; var IsHandled: Boolean; var TempInvoicePostBuffer: Record "Invoice Post. Buffer" temporary)


    var
        SelesDesgl: Record "Purch. Rcpt. Line";
        SalesDesglLCY: Record "Purch. Rcpt. Line";
        GenPostingSetup: Record "General Posting Setup";
        //SalesPostPrepayments: Codeunit "Purch.-Post Prepayments";
        AdjAmount: Decimal;
        TotalVAT: Decimal;
        TotalVATACY: Decimal;
        TotalAmount: Decimal;
        TotalAmountACY: Decimal;
        AmtToDefer: Decimal;
        AmtToDeferACY: Decimal;
        TotalVATBase: Decimal;
        TotalVATBaseACY: Decimal;
        DeferralAccount: Code[20];
        SalesAccount: Code[20];
        InvDiscAccount: code[20];
        LineDiscAccount: code[20];
        InvoiceDiscountPosting: Boolean;
        LineDiscountPosting: Boolean;
        FalineNo: Integer;
        Liines: Record "Purchase Line";
    begin
        if PurchHeader."Empresa Factura" = '' Then exit;
        if Not PurchHeader.ContabilizaInter then exit;

        IsHandled := True;
        TempInvoicePostBuffer.Deleteall;
        with PurchHeader do begin
            SelesDesgl.SETRANGE(SelesDesgl."Document No.", "Posting No.");
            if not SelesDesgl.FINDFIRST THEN begin
                IsHandled := false;
                exit;
            end;
            if SelesDesgl.FINDFIRST THEN
                REPEAT
                    SalesDesglLCY := SelesDesgl;
                    if ("Document Type" IN ["Document Type"::"Return Order", "Document Type"::"Credit Memo"]) THEN BEGIN
                        SelesDesgl."Line Amount" := -SelesDesgl."Line Amount";
                        SelesDesgl.Amount := -SelesDesgl.Amount;
                        SelesDesgl."VAT Base Amount" := -SelesDesgl."VAT Base Amount";
                        //SelesDesgl."VAT Difference" := -SelesDesgl."VAT Difference";
                        SelesDesgl."Amount Including VAT" := -SelesDesgl."Amount Including VAT";
                        SelesDesgl."Line Discount Amount" := -SelesDesgl."Line Discount Amount";
                        //SelesDesgl."Inv. Discount Amount" := -SelesDesgl."Inv. Discount Amount";
                        //SelesDesgl."Pmt. Disc. Given Amount" := -SelesDesgl."Pmt. Disc. Given Amount";
                        SalesDesglLCY."Line Amount" := -SalesDesglLCY."Line Amount";
                        SalesDesglLCY.Amount := -SalesDesglLCY.Amount;
                        SalesDesglLCY."VAT Base Amount" := -SalesDesglLCY."VAT Base Amount";
                        //SalesDesglLCY."VAT Difference" := -SalesDesglLCY."VAT Difference";
                        SalesDesglLCY."Amount Including VAT" := -SalesDesglLCY."Amount Including VAT";
                        SalesDesglLCY."Line Discount Amount" := -SalesDesglLCY."Line Discount Amount";
                        //SalesDesglLCY."Inv. Discount Amount" := -SalesDesglLCY."Inv. Discount Amount";
                        //SalesDesglLCY."Pmt. Disc. Given Amount" := -SalesDesglLCY."Pmt. Disc. Given Amount";

                    END;
                    ContabAlb.FillInvPostingBufferDesglCompra(SelesDesgl, SalesDesglLCY, InvoicePostBuffer, PurchHeader, FalineNo, TempInvoicePostBuffer);
                UNTIL SelesDesgl.NEXT = 0;

        end;
    end;

    // TODO: - CLEAN22
#pragma warning restore AL0432 // TODO: - Invoice Posting Buffer codunit 825
#endif
#endif
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", 'OnBeforePostPurchLine', '', false, false)]
    local procedure OnRunOnBeforePostPurchLine(var PurchLine: Record "Purchase Line"; var PurchHeader: Record "Purchase Header")
    var
        Liines: Record "Purchase Line";
        ImpV: decimal;
        ImpC: Decimal;
        FechaV: Date;
        FechaC: Date;
    begin
        If PurchHeader."Document Type" = PurchHeader."Document Type"::Invoice Then begin
            If Not ImporteProv(PurchHeader, Impv, ImpC) Then Error(StrSubstNo('Compruebe los importes venta %1 compra %2', Impv, ImpC));
            If Not FechaProv(PurchHeader, Fechav, FechaC) Then Error(StrSubstNo('Compruebe las fechas venta %1 compra %2', Format(FechaV, 0, '<Day,2>/<Month,2>/<Year>'), Format(FechaC, 0, '<Day,2>/<Month,2>/<Year>')));
        end;
        if PurchHeader."Empresa Factura" <> '' Then begin
            if PurchHeader.ContabilizaInter then
                ContabAlb.DesglosarCompra(PurchHeader);
        end;
    end;

    procedure FechaProv(var Rec: Record "Purchase header"; var FechaV: Date; var FechaC: Date): Boolean;
    VAR
        rIc: Record 413;
        r112: Record 112;
        TotalPurchaseLine: Record 39 temporary;
        TempPurchaseLine: Record 39 temporary;
        PurchaseLine: Record 39;
        VatAmount: Decimal;
        InvoiceDiscountAmount: Decimal;
        InvoiceDiscountPct: Decimal;
        rCust: Record Customer;
        wEmpresa: Text[30];
        r23: Record Vendor;
        DocumentTotals: Codeunit "Document Totals";
        MesVenta, MesCompra : Integer;
        AñoVenta, AñoCompra : Integer;
    BEGIN
        if NOT r23.GET(Rec."Buy-from Vendor No.") THEN EXIT(true);
        if NOT rIc.GET(r23."IC Partner Code") THEN EXIT(true);
        wEmpresa := rIc."Inbox Details";
        r112.CHANGECOMPANY(wEmpresa);
        if r112.GET(Rec."Vendor Invoice No.") THEN BEGIN
            FechaV := r112."Posting Date";
            FechaC := Rec."Posting Date";

            // Extraer mes y año de ambas fechas
            MesVenta := DATE2DMY(FechaV, 2);
            AñoVenta := DATE2DMY(FechaV, 3);
            MesCompra := DATE2DMY(FechaC, 2);
            AñoCompra := DATE2DMY(FechaC, 3);

            // Verificar que estén en el mismo mes y año, y que la fecha de compra no sea menor que la de venta
            EXIT((MesVenta = MesCompra) AND (AñoVenta = AñoCompra) AND (FechaC >= FechaV));
        END;

    end;

    PROCEDURE ImporteProv(var Rec: Record "Purchase header"; var ImpV: decimal; var ImpC: Decimal): Boolean;
    VAR
        rIc: Record 413;
        r112: Record 112;
        TotalPurchaseLine: Record 39 temporary;
        TempPurchaseLine: Record 39 temporary;
        PurchaseLine: Record 39;
        VatAmount: Decimal;
        InvoiceDiscountAmount: Decimal;
        InvoiceDiscountPct: Decimal;
        rCust: Record Customer;
        wEmpresa: Text[30];
        r23: Record Vendor;
        DocumentTotals: Codeunit "Document Totals";
    BEGIN
        if NOT r23.GET(Rec."Buy-from Vendor No.") THEN EXIT(true);
        if NOT rIc.GET(r23."IC Partner Code") THEN EXIT(true);
        wEmpresa := rIc."Inbox Details";
        //rCust.CHANGECOMPANY(wEmpresa);
        //rCust.SETRANGE(rCust."IC Partner Code",rIc.Code);
        //rCust.FINDFIRST;
        PurchaseLine.SETRANGE("Document No.", Rec."No.");
        PurchaseLine.SETRANGE("Document Type", Rec."Document Type");
        if PurchaseLine.FindSet() Then begin
            TempPurchaseLine := PurchaseLine;
            TempPurchaseLine.Insert();
        end;
        DocumentTotals.PurchaseCalculateTotalsWithInvoiceRounding(TempPurchaseLine, VATAmount, TotalPurchaseLine);


        r112.CHANGECOMPANY(wEmpresa);
        if r112.GET(Rec."Vendor Invoice No.") THEN BEGIN
            r112.Calcfields(r112."Amount Including VAT");
            ImpC := TotalPurchaseLine."Amount Including VAT";
            ImpV := r112."Amount Including VAT";
            EXIT(ABS(TotalPurchaseLine."Amount Including VAT" - r112."Amount Including VAT") < 0.02);
        END;
        exit(True);
    END;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", 'OnRunOnBeforeFinalizePosting', '', false, false)]
    local procedure OnRunOnBeforeFinalizePosting(var PurchaseHeader: Record "Purchase Header"; var PurchRcptHeader: Record "Purch. Rcpt. Header"; var PurchInvHeader: Record "Purch. Inv. Header"; var PurchCrMemoHdr: Record "Purch. Cr. Memo Hdr."; var ReturnShipmentHeader: Record "Return Shipment Header"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; CommitIsSuppressed: Boolean)
    var
        SalesInvHeader: Record "Sales invoice header";
    begin
        if PurchInvHeader."Empresa Factura" <> '' Then begin
            SalesInvHeader.ChangeCompany(PurchInvHeader."Empresa Factura");
            if SalesInvHeader.Get(PurchInvHeader."Vendor Invoice No.") Then begin
                SalesInvHeader."Pte Contabilicación" := false;
                SalesInvHeader.Modify();
            end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", 'OnBeforeTestPurchLineJob', '', false, false)]
    local procedure OnBeforeTestPurchLineJob(PurchaseLine: Record "Purchase Line"; var IsHandled: Boolean)
    begin
        IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Release Purchase Document", 'OnAfterManualReopenPurchaseDoc', '', false, false)]
    local procedure OnAfterManualReopenPurchaseDoc(var PurchaseHeader: Record "Purchase Header"; PreviewMode: Boolean)
    var
        IncomingDocument: Record "Incoming Document";
    begin
        if PurchaseHeader."Incoming Document Entry No." <> 0 Then
            if IncomingDocument.get(PurchaseHeader."Incoming Document Entry No.") Then IncomingDocument.Delete();
    end;

    /// <summary>
    /// InsertaDocumentosPedidoParaFactura.
    /// </summary>
    /// <param name="PurchaseHeader">VAR Record "Purchase Header".</param>
    /// <param name="PreviewMode">Boolean.</param>
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Release Purchase Document", 'OnAfterManualReleasePurchaseDoc', '', false, false)]
    procedure InsertaDocumentosPedidoParaFactura(var PurchaseHeader: Record "Purchase Header"; PreviewMode: Boolean)
    var

        PurchaseLine: Record "Purchase Line";
        PurchRcptHeader: Record "Purch. Rcpt. Header";

        Calculo: Record "Calculo Albaranes";
    begin

        if PurchaseHeader."Document Type" IN [PurchaseHeader."Document Type"::"Credit Memo", PurchaseHeader."Document Type"::Invoice] THEN BEGIN
            PurchaseLine.SETRANGE(PurchaseLine."Document Type", PurchaseHeader."Document Type");
            PurchaseLine.SETRANGE(PurchaseLine."Document No.", PurchaseHeader."No.");
            if PurchaseLine.FINDFIRST THEN
                REPEAT
                    if PurchaseLine."Receipt No." <> '' THEN BEGIN
                        if PurchRcptHeader.GET(PurchaseLine."Receipt No.") THEN BEGIN
                            if Calculo.Get(PurchRcptHeader."No.") Then Begin Calculo.Calculado := False; Calculo.Modify() End;

                        END;
                    END;
                UNTIL PurchaseLine.NEXT = 0;
        END;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", 'OnAfterPostPurchaseDoc', '', false, false)]

    /// <summary>
    /// PostPutch.
    /// </summary>
    /// <param name="VAR PurchaseHeader">Record "Purchase Header".</param>
    /// <param name="VAR GenJnlPostLine">Codeunit "Gen. Jnl.-Post Line".</param>
    /// <param name="PurchRcpHdrNo">Code[20].</param>
    /// <param name="RetShptHdrNo">Code[20].</param>
    /// <param name="PurchInvHdrNo">Code[20].</param>
    /// <param name="PurchCrMemoHdrNo">Code[20].</param>
    /// <param name="CommitIsSupressed">Boolean.</param>
    procedure PostPutch(VAR PurchaseHeader: Record "Purchase Header"; VAR GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; PurchRcpHdrNo: Code[20]; RetShptHdrNo: Code[20]; PurchInvHdrNo: Code[20]; PurchCrMemoHdrNo: Code[20]; CommitIsSupressed: Boolean)
    var
        Calculo: Record "Calculo Albaranes";
    begin

        if Calculo.Get(PurchRcpHdrNo) Then Begin Calculo.Calculado := False; Calculo.Modify() End;
    end;
#if not CLEAN22
#if not CLEAN27
    // TODO: - CLEAN22
#pragma warning disable AL0432 // TODO: - Invoice Posting Buffer codunit 825
    [EventSubscriber(ObjectType::codeunit, 90, 'OnAfterFillInvoicePostBuffer', '', false, false)]
    PROCEDURE CorreccionInvBufer(VAR InvoicePostBuffer: Record 49; PurchLine: Record 39; VAR TempInvoicePostBuffer: Record 49 TEMPORARY; CommitIsSupressed: Boolean)


    VAR
        PurchRcptHeader: Record "Purch. Rcpt. Header";
        PurchShptHeader: Record 6650;
        VendPostingGr: Record "Vendor Posting Group";
        PurchaseHeader: Record 38;
        Vendor: Record Vendor;
        GrupoProv: Record "Vendor Posting Group";
        r14: Record Location;
        VATBus: Record "VAT Business Posting Group";
        GenPostingSetup: Record "General Posting Setup";
        GLSetup: Record "General Ledger Setup";
        VatPostingSetup: Record "VAT Posting Setup";
        Calculo: Record "Calculo Albaranes";
    BEGIN
        if (PurchLine.Type <> PurchLine.Type::"Fixed Asset") THEN BEGIN
            PurchaseHeader.GET(PurchLine."Document Type", PurchLine."Document No.");
            //if PurchaseHeader."Last Receiving No." <> '' THEN PurchLine."Receipt No." := PurchaseHeader."Last Receiving No.";
            if (PurchLine."Receipt No." <> '')
            //{AND (PurchLine.Type = PurchLine.Type::"G/L Account")} 
            THEN BEGIN
                if Not PurchRcptHeader.GET(PurchLine."Receipt No.") Then PurchRcptHeader.Init();
                if Calculo.Get(PurchRcptHeader."No.") Then Begin Calculo.Calculado := False; Calculo.Modify() End;
                if PurchRcptHeader.Contabilizado THEN BEGIN
                    VendPostingGr.GET(PurchRcptHeader."Vendor Posting Group");
                    VendPostingGr.TESTFIELD(FPR);
                    InvoicePostBuffer."G/L Account" := VendPostingGr.FPR;
                    //     InvoicePostBuffer.MODIFY;
                END else
                    if Not ContabAlb.TestActivosAlb(PurchRcptHeader) Then
                        if PurchRcptHeader."No." <> '' then
                            Error(NoContab, PurchRcptHeader."No.");

            END;
            //if PurchaseHeader."Last Return Shipment No." <> '' THEN PurchLine."Return Shipment No." := PurchaseHeader."Last Return Shipment No.";
            if (PurchLine."Return Shipment No." <> '')
            //{AND (PurchLine.Type = PurchLine.Type::"G/L Account")} 
            THEN BEGIN
                PurchShptHeader.GET(PurchLine."Return Shipment No.");
                if PurchShptHeader.Contabilizado THEN BEGIN
                    VendPostingGr.GET(PurchShptHeader."Vendor Posting Group");
                    VendPostingGr.TESTFIELD(FPR);
                    InvoicePostBuffer."G/L Account" := VendPostingGr.FPR;
                    //InvoicePostBuffer.MODIFY;
                END else
                    if Not ContabAlb.TestActivosShp(PurchShptHeader) then error(DevolNotConta, PurchShptHeader."No.");
            END;
        END;
        PurchaseHeader.GET(PurchLine."Document Type", PurchLine."Document No.");
        if (PurchLine.Type = PurchLine.Type::"G/L Account") OR (PurchLine.Type = PurchLine.Type::"Fixed Asset") THEN
            InvoicePostBuffer."G/L Account" := PurchLine."No."
        ELSE
            if PurchLine."Document Type" IN [PurchLine."Document Type"::"Return Order", PurchLine."Document Type"::"Credit Memo"] THEN BEGIN
                if NOT r14.GET(PurchLine."Location Code") THEN r14.INIT;
                if r14."Cta. Compras" <> '' THEN BEGIN
                    InvoicePostBuffer."G/L Account" := r14."Cta. Compras";
                END ELSE BEGIN
                    GenPostingSetup.Get(PurchLine."Gen. Bus. Posting Group", PurchLine."Gen. Prod. Posting Group");
                    GenPostingSetup.TESTFIELD("Purch. Credit Memo Account");
                    InvoicePostBuffer."G/L Account" := GenPostingSetup."Purch. Credit Memo Account";
                END;
            END ELSE BEGIN
                if NOT r14.GET(PurchLine."Location Code") THEN r14.INIT;
                if r14."Cta. Compras" <> '' THEN BEGIN
                    InvoicePostBuffer."G/L Account" := r14."Cta. Compras";
                END ELSE BEGIN
                    GenPostingSetup.Get(PurchLine."Gen. Bus. Posting Group", PurchLine."Gen. Prod. Posting Group");
                    GenPostingSetup.TESTFIELD("Purch. Account");
                    InvoicePostBuffer."G/L Account" := GenPostingSetup."Purch. Account";
                END;
            END;
        if ContabAlb.CompruebaAlbarán(PurchLine."Receipt No.", PurchaseHeader) THEN BEGIN
            if Calculo.Get(PurchLine."Receipt No.") Then Begin Calculo.Calculado := False; Calculo.Modify() End;
            Vendor.GET(PurchLine."Pay-to Vendor No.");
            GrupoProv.GET(Vendor."Vendor Posting Group");
            InvoicePostBuffer.Type := InvoicePostBuffer.Type::"G/L Account";
            InvoicePostBuffer."G/L Account" := GrupoProv.FPR;
        END else begin
            if PurchRcptHeader.GET(PurchLine."Receipt No.") Then
                if Not ContabAlb.TestActivosAlb(PurchRcptHeader) Then
                    error(NoContab, PurchLine."Receipt No.");
        end;
        if ContabAlb.CompruebaDevolución(PurchLine."Return Shipment No.", PurchaseHeader) THEN BEGIN
            Vendor.GET(PurchLine."Pay-to Vendor No.");
            GrupoProv.GET(Vendor."Vendor Posting Group");
            InvoicePostBuffer.Type := InvoicePostBuffer.Type::"G/L Account";
            InvoicePostBuffer."G/L Account" := GrupoProv.FPR;
        END else begin
            if PurchShptHeader.GET(PurchLine."Return Shipment No.") then
                if Not ContabAlb.TestActivosShp(PurchShptHeader) then
                    error(DevolNotConta, PurchLine."Return Shipment No.");
        end;

        //ASC
        InvoicePostBuffer."Global Dimension 1 Code" := PurchLine."Shortcut Dimension 1 Code";
        InvoicePostBuffer."Global Dimension 2 Code" := PurchLine."Shortcut Dimension 2 Code";
        InvoicePostBuffer."Global Dimension 3 Code" := PurchLine."Shortcut Dimension 3 Code";


        InvoicePostBuffer."Global Dimension 4 Code" := PurchLine."Shortcut Dimension 4 Code";


        InvoicePostBuffer."Global Dimension 5 Code" := PurchLine."Shortcut Dimension 5 Code";

        PurchaseHeader.GET(PurchLine."Document Type", PurchLine."Document No.");
        //-SII
        GLSetup.GET;
        if GLSetup."Activar SII" THEN BEGIN
            if VATPostingSetup.GET(PurchLine."VAT Bus. Posting Group", PurchLine."VAT Prod. Posting Group") THEN;
            if VATBus.GET(PurchLine."VAT Bus. Posting Group") THEN;
            //PurchaseHeader.GET(PurchLine."Document Type",PurchLine."Document No.");

            InvoicePostBuffer."Tipo factura SII" := PurchaseHeader."Tipo factura SII";


            InvoicePostBuffer."Clave registro SII recibidas" := VATBus."Clave registro SII recibidas";


            InvoicePostBuffer."Descripción operación" := PurchaseHeader."Descripción operación";


            InvoicePostBuffer."Tipo desglose emitidas" := VATPostingSetup."Tipo desglose emitidas";


            InvoicePostBuffer."Sujeta exenta" := VATPostingSetup."Sujeta exenta";


            InvoicePostBuffer."Tipo de operación" := VATPostingSetup."Tipo de operación";


            InvoicePostBuffer."Tipo factura rectificativa" := PurchaseHeader."Tipo factura rectificativa";

        END;
        //+SII


        InvoicePostBuffer."Periodo de Pago" := PurchLine."Periodo de Pago";


        //ASC
        InvoicePostBuffer."Tax Area Code" := PurchLine."Receipt No.";
        if PurchLine."Return Shipment No." <> '' THEN
            InvoicePostBuffer."Tax Area Code" := PurchLine."Return Shipment No.";
        //ASC
    END;


    [EventSubscriber(ObjectType::codeunit, 90, 'OnBeforePostInvPostBuffer', '', false, false)]


    local procedure OnBeforePostInvPostBuffer(var GenJnlLine: Record "Gen. Journal Line"; var InvoicePostBuffer: Record "Invoice Post. Buffer"; var PurchHeader: Record "Purchase Header"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; PreviewMode: Boolean; CommitIsSupressed: Boolean; var GenJnlLineDocNo: code[20])

    var
        GlSetup: Record "General Ledger Setup";
    begin
        //ASC
        GenJnlLine."Shortcut Dimension 1 Code" := InvoicePostBuffer."Global Dimension 1 Code";
        GenJnlLine."Shortcut Dimension 2 Code" := InvoicePostBuffer."Global Dimension 2 Code";
        GenJnlLine."Shortcut Dimension 3 Code" := InvoicePostBuffer."Global Dimension 3 Code";
        GenJnlLine."Shortcut Dimension 4 Code" := InvoicePostBuffer."Global Dimension 4 Code";
        GenJnlLine."Shortcut Dimension 5 Code" := InvoicePostBuffer."Global Dimension 5 Code";

        //GenJnlLine.Circuito:=Agrupado;
        //-SII
        GLSetup.GET;
        if GLSetup."Activar SII" THEN BEGIN
            GenJnlLine."Tipo factura SII" := InvoicePostBuffer."Tipo factura SII";
            GenJnlLine."Clave registro SII expedidas" := InvoicePostBuffer."Clave registro SII expedidas";
            GenJnlLine."Clave registro SII recibidas" := InvoicePostBuffer."Clave registro SII recibidas";
            GenJnlLine."Descripción operación" := InvoicePostBuffer."Descripción operación";
            GenJnlLine."Tipo desglose recibidas" := InvoicePostBuffer."Tipo desglose recibidas";
            GenJnlLine."Sujeta exenta" := InvoicePostBuffer."Sujeta exenta";
            GenJnlLine."Tipo de operación" := InvoicePostBuffer."Tipo de operación";
            GenJnlLine."Tipo factura rectificativa" := InvoicePostBuffer."Tipo factura rectificativa";
        END;
        //+SII


    end;

    // TODO: - CLEAN22
#pragma warning restore AL0432 // TODO: - Invoice Posting Buffer codunit 825
#endif
#endif
    [EventSubscriber(ObjectType::codeunit, 826, 'OnPostLinesOnBeforeGenJnlLinePost', '', false, false)]

    local procedure OnPostLinesOnBeforeGenJnlLinePost(var GenJnlLine: Record "Gen. Journal Line"; PurchHeader: Record "Purchase Header"; TempInvoicePostingBuffer: Record "Invoice Posting Buffer"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; PreviewMode: Boolean; SuppressCommit: Boolean)
    var
        GlSetup: Record "General Ledger Setup";
    begin

        //ASC
        GenJnlLine."Shortcut Dimension 1 Code" := TempInvoicePostingBuffer."Global Dimension 1 Code";
        GenJnlLine."Shortcut Dimension 2 Code" := TempInvoicePostingBuffer."Global Dimension 2 Code";
        GenJnlLine."Shortcut Dimension 3 Code" := TempInvoicePostingBuffer."Global Dimension 3 Code";
        GenJnlLine."Shortcut Dimension 4 Code" := TempInvoicePostingBuffer."Global Dimension 4 Code";
        GenJnlLine."Shortcut Dimension 5 Code" := TempInvoicePostingBuffer."Global Dimension 5 Code";

        //GenJnlLine.Circuito:=Agrupado;

        //-SII
        GLSetup.GET;
        if GLSetup."Activar SII" THEN BEGIN
            GenJnlLine."Tipo factura SII" := TempInvoicePostingBuffer."Tipo factura SII";
            GenJnlLine."Clave registro SII expedidas" := TempInvoicePostingBuffer."Clave registro SII expedidas";
            GenJnlLine."Clave registro SII recibidas" := TempInvoicePostingBuffer."Clave registro SII recibidas";
            GenJnlLine."Descripción operación" := TempInvoicePostingBuffer."Descripción operación";
            GenJnlLine."Tipo desglose recibidas" := TempInvoicePostingBuffer."Tipo desglose recibidas";
            GenJnlLine."Sujeta exenta" := TempInvoicePostingBuffer."Sujeta exenta";
            GenJnlLine."Tipo de operación" := TempInvoicePostingBuffer."Tipo de operación";
            GenJnlLine."Tipo factura rectificativa" := TempInvoicePostingBuffer."Tipo factura rectificativa";
        END;
        //+SII

    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch. Post Invoice Events", OnAfterPrepareInvoicePostingBuffer, '', false, false)]
    local procedure OnAfterPrepareInvoicePostingBuffer(var PurchaseLine: Record "Purchase Line"; var InvoicePostingBuffer: Record "Invoice Posting Buffer")

    var
        GlSetup: Record "General Ledger Setup";
        PurchaseHeader: Record "Purchase Header";
        VATBus: Record "VAT Business Posting Group";
        VATPostingSetup: Record "VAT Posting Setup";
    begin
        if Not PurchaseHeader.Get(PurchaseLine."Document Type", PurchaseLine."Document No.") then PurchaseHeader.Init();
        //ASC
        InvoicePostingBuffer."Global Dimension 1 Code" := PurchaseLine."ShortCut Dimension 1 Code";
        InvoicePostingBuffer."Global Dimension 2 Code" := PurchaseLine."ShortCut Dimension 2 Code";
        InvoicePostingBuffer."Global Dimension 3 Code" := PurchaseLine."ShortCut Dimension 3 Code";
        InvoicePostingBuffer."Global Dimension 4 Code" := PurchaseLine."ShortCut Dimension 4 Code";
        InvoicePostingBuffer."Global Dimension 5 Code" := PurchaseLine."ShortCut Dimension 5 Code";

        //InvoicePostingBuffer.Circuito:=Agrupado;

        //-SII
        GLSetup.GET;
        if GLSetup."Activar SII" THEN BEGIN
            InvoicePostingBuffer."Tipo factura SII" := PurchaseHeader."Tipo factura SII";
            if VATPostingSetup.GET(PurchaseLine."VAT Bus. Posting Group", PurchaseLine."VAT Prod. Posting Group") THEN;
            if VATBus.GET(PurchaseLine."VAT Bus. Posting Group") THEN;
            InvoicePostingBuffer."Clave registro SII expedidas" := VatBus."Clave registro SII expedidas";
            InvoicePostingBuffer."Clave registro SII recibidas" := VATBus."Clave registro SII recibidas";
            if PurchaseHeader."Descripción operación" = '' Then PurchaseHeader."Descripción operación" := PurchaseHeader."Posting Description";
            InvoicePostingBuffer."Descripción operación" := PurchaseHeader."Descripción operación";
            InvoicePostingBuffer."Tipo desglose recibidas" := VATPostingSetup."Tipo desglose recibidas";
            InvoicePostingBuffer."Sujeta exenta" := VATPostingSetup."Sujeta exenta";
            InvoicePostingBuffer."Tipo de operación" := VATPostingSetup."Tipo de operación";
            InvoicePostingBuffer."Tipo factura rectificativa" := PurchaseHeader."Tipo factura rectificativa";
        END;
        //+SII

    end;




    [EventSubscriber(ObjectType::codeunit, 90, 'OnBeforeReturnShptLineInsert', '', false, false)]
    local procedure OnBeforeReturnShptLineInsert(var ReturnShptLine: Record "Return Shipment Line"; var ReturnShptHeader: Record "Return Shipment Header"; var PurchLine: Record "Purchase Line"; CommitIsSupressed: Boolean)
    begin

        //ASC
        ReturnShptLine."Fecha inicial recurso" := PurchLine."Fecha inicial recurso";
        ReturnShptLine."Fecha final recurso" := PurchLine."Fecha final recurso";
        //ASC
    end;

    [EventSubscriber(ObjectType::codeunit, 90, 'OnBeforePurchRcptLineInsert', '', false, false)]
    local procedure OnBeforePurchRcptLineInsert(var PurchRcptLine: Record "Purch. Rcpt. Line"; var PurchRcptHeader: Record "Purch. Rcpt. Header"; var PurchLine: Record "Purchase Line"; CommitIsSupressed: Boolean; PostedWhseRcptLine: Record "Posted Whse. Receipt Line"; var IsHandled: Boolean)
    begin

        //ASC
        PurchRcptLine."Fecha inicial recurso" := PurchLine."Fecha inicial recurso";
        PurchRcptLine."Fecha final recurso" := PurchLine."Fecha final recurso";
        //ASC
    end;


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", 'OnBeforePostPurchaseDoc', '', false, false)]
    local procedure OnBeforePostPurchaseDoc(var PurchaseHeader: Record "Purchase Header"; PreviewMode: Boolean; CommitIsSupressed: Boolean; var HideProgressWindow: Boolean; var ItemJnlPostLine: Codeunit "Item Jnl.-Post Line")
    Var
        GestiónSII: Report "Gestión SII";
        GlSetup: Record "General Ledger Setup";
    begin

        //-SII
        CLEAR(GestiónSII);
        //+SII
        //-SII
        GLSetup.GET;
        if GLSetup."Activar SII" THEN BEGIN
            if PurchaseHeader."Tipo factura SII" = '' THEN BEGIN
                PurchaseHeader."Tipo factura SII" := 'F1';
                if (PurchaseHeader."Document Type" = PurchaseHeader."Document Type"::"Credit Memo") OR (PurchaseHeader."Document Type" = PurchaseHeader."Document Type"::"Return Order") THEN
                    PurchaseHeader."Tipo factura SII" := '4';
            END;
            if PurchaseHeader."Descripción operación" = '' THEN
                PurchaseHeader."Descripción operación" := PurchaseHeader."Posting Description";
        END;
        //+SII
    end;
    #endregion Codeunit90
    #region Codeunit91
    [EventSubscriber(ObjectType::Codeunit, 91, 'OnBeforeConfirmPost', '', false, false)]
    LOCAL PROCEDURE OnBeforeConfirmPost(var PurchaseHeader: Record "Purchase Header"; var HideDialog: Boolean; var IsHandled: Boolean; var DefaultOption: Integer)
    VAR
        PurchRcptHeader: Record "Purch. Rcpt. Header";
        PurchShptHeader: Record 6650;
        PurchSetup: Record "Purchases & Payables Setup";
        NumeroAlbaranes: Integer;
        Selection2: Integer;
        Selection1: Integer;
        Text1006: Label 'Por &Fechas,Por &Términos';
        Text0005: Label '&Recibir,Recibir y &Contabilizar';
        rVend: Record Vendor;
        rIc: Record 413;
        Tipo: Option Pedido,Devolucion;
        rJob: Record 167;
        rContr: Record 36;
        InterEmpresas: Boolean;
        Albaranes: Record "Purch. Rcpt. Header";
        Ventana: Page 50008;
        VentanaAlb: Page "Dialogo Albaranes";
        Distancia: DateFormula;
        r36: Record 36;
        fec: Date;
        contador: Integer;
        PurchPost: Codeunit 90;
        Text001: Label '¿Confirma que desea registrar el/la %1?';
        ErrorAnulado: Label 'El/La %1 %2 ha sido Anulado';
        Albaran: Integer;
        Documentos: array[20] of Code[20];
    BEGIN

        WITH Purchaseheader DO BEGIN
            if Status = Status::Canceled THEN ERROR(ErrorAnulado, "Document Type", "No.");
            CASE "Document Type" OF
                "Document Type"::Order:
                    BEGIN
                        Selection1 := STRMENU(Text0005, 2);
                        if Selection1 = 0 THEN
                            EXIT;
                        Receive := Selection1 IN [1, 2];
                        Invoice := false;
                    END;
                "Document Type"::"Return Order":
                    BEGIN
                        Selection1 := STRMENU(Text0005, 2);
                        if Selection1 = 0 THEN
                            EXIT;
                        Ship := Selection1 IN [1, 2];
                        Invoice := false;
                    END ELSE
                            // if NOT
                            // CONFIRM(
                            //     Text001, FALSE,
                            //     "Document Type")
                            // THEN
                            EXIT;
            END;
            HideDialog := true;
            PurchSetup.GET;
            if (Selection1 = 2) AND (NOT PurchSetup."Activar contabilización albara") THEN ERROR(ContabNoActivada);
            if (Selection1 = 2) AND (ContabAlb.TestActivos(Purchaseheader)) THEN ERROR(ContabActivos);
            NumeroAlbaranes := 1;
            Purchaseheader."Last Receiving No." := '';
            Purchaseheader."Last Return Shipment No." := '';
            Purchaseheader.MODIFY;
            Commit();
            if (Receive OR Ship) AND ("Document Type" IN ["Document Type"::Order, "Document Type"::"Return Order"]) THEN BEGIN
                Selection2 := STRMENU(Text1006, 1);
                if Selection2 = 1 THEN BEGIN
                    Purchaseheader.CALCFIELDS("Nº Contrato Venta");
                    rVend.GET(Purchaseheader."Buy-from Vendor No.");
                    if rVend."IC Partner Code" <> '' THEN BEGIN
                        rIc.GET(rVend."IC Partner Code");
                        if rIc."Inbox Type" = rIc."Inbox Type"::Database THEN BEGIN
                            rJob.CHANGECOMPANY(rIc."Inbox Details");
                            rJob.SETCURRENTKEY(rJob."Proyecto en empresa Origen");
                            rJob.SETRANGE(rJob."Proyecto en empresa Origen", Purchaseheader."Nº Proyecto");
                            rJob.SETRANGE(rJob."Empresa Origen", COMPANYNAME);
                            if rJob.FINDFIRST THEN BEGIN
                                rContr.CHANGECOMPANY(rIc."Inbox Details");
                                rContr.SETCURRENTKEY(rContr."Nº Proyecto");
                                rContr.SETRANGE(rContr."Nº Proyecto", rJob."No.");
                                if rContr.FINDFIRST THEN
                                    REPEAT
                                        rContr."Customer Order No." := "No.";
                                        rContr.MODIFY;
                                    UNTIL rContr.NEXT = 0;
                                Commit();
                            END;
                        END;
                    END;
                    Purchaseheader.CALCFIELDS("Nº Contrato Venta");
                    if r36.GET(r36."Document Type"::Order, Purchaseheader."Nº Contrato Venta") THEN
                        fec := r36."Fecha inicial proyecto"
                    ELSE
                        fec := Purchaseheader."Posting Date";
                    CLEAR(Ventana);
                    if fec = 0D Then fec := WorkDate();
                    VentanaAlb.SetCampos(1, Distancia, fec);
                    if VentanaAlb.RUNMODAL in [Action::Cancel, Action::LookupCancel, Action::No, Action::None] Then error(ProcesoCancelado);
                    VentanaAlb.GetCampos(NumeroAlbaranes, Distancia, fec);
                    PurchaseHeader."Posting Date" := fec;
                    // Ventana.OPEN('Cuantos Albaranes quiere #########1##');
                    // Ventana.INPUT(1,a);
                    // Ventana.CLOSE;
                    if NumeroAlbaranes > 1 THEN BEGIN
                        // Purchaseheader.CALCFIELDS("Nº Contrato Venta");
                        // if r36.GET(r36."Document Type"::Order, Purchaseheader."Nº Contrato Venta") THEN
                        //     fec := r36."Fecha inicial proyecto"
                        // ELSE
                        //     fec := Purchaseheader."Posting Date";
                        // // Ventana.OPEN('Con que distancia quiere los albaranes  #########1## \'+
                        //             'Arrancando desde día  (inicio contrato) #########2##');


                        // Ventana.INPUT(1,d);
                        // Ventana.INPUT(2,fec);
                        // Ventana.CLOSE;
                        // Purchaseheader."Posting Date":=fec;
                        FOR Albaran := 1 TO NumeroAlbaranes DO BEGIN
                            Documentos[Albaran] := ContabAlb.Dividir(Purchaseheader, Purchaseheader."Posting Date", Ship, Receive, Albaran, NumeroAlbaranes);
                            if Albaran > 1 THEN
                                if Documentos[Albaran] = Documentos[Albaran - 1] THEN ERROR(Contacte);
                            Purchaseheader."Posting Date" := CALCDATE(Distancia, Purchaseheader."Posting Date");
                        END;
                        FOR Albaran := 1 TO NumeroAlbaranes DO BEGIN
                            if (Selection1 = 1)
                            OR
                            (Selection1 = 2)
                            THEN
                                ContabAlb.SoloTraspasar(Documentos[Albaran], Purchaseheader."Document Type" = Purchaseheader."Document Type"::Order);
                            COMMIT;
                        END;
                        FOR Albaran := 1 TO NumeroAlbaranes DO BEGIN
                            if Selection1 = 2 THEN ContabAlb.SoloContabilizar(Documentos[Albaran], Purchaseheader."Document Type" = Purchaseheader."Document Type"::Order);
                            COMMIT;
                        END;

                    END;
                END ELSE BEGIN
                    NumeroAlbaranes := 0;
                    Purchaseheader.CALCFIELDS("Nº Contrato Venta");
                    rVend.GET(Purchaseheader."Buy-from Vendor No.");
                    if rVend."IC Partner Code" <> '' THEN BEGIN
                        rIc.GET(rVend."IC Partner Code");
                        if rIc."Inbox Type" = rIc."Inbox Type"::Database THEN BEGIN
                            rJob.CHANGECOMPANY(rIc."Inbox Details");
                            rJob.SETCURRENTKEY(rJob."Proyecto en empresa Origen");
                            rJob.SETRANGE(rJob."Proyecto en empresa Origen", Purchaseheader."Nº Proyecto");
                            rJob.SETRANGE(rJob."Empresa Origen", COMPANYNAME);
                            if rJob.FINDFIRST THEN BEGIN
                                rContr.CHANGECOMPANY(rIc."Inbox Details");
                                rContr.SETCURRENTKEY(rContr."Nº Proyecto");
                                rContr.SETRANGE(rContr."Nº Proyecto", rJob."No.");
                                if rContr.FINDFIRST THEN
                                    REPEAT
                                        rContr."Customer Order No." := "No.";
                                        rContr.MODIFY;
                                    UNTIL rContr.NEXT = 0;
                            END;
                        END;
                    END;
                    ContabAlb.GenerarFechasAlbaran(Purchaseheader."Nº Contrato Venta", Purchaseheader."No.");
                    COMMIT;
                    ContabAlb.DividirTerminos(Purchaseheader, Ship, Receive, Selection1);
                    Commit();
                    PurchRcptHeader.SetRange("Order No.", PurchaseHeader."No.");
                    if PurchRcptHeader.FindFirst() Then
                        repeat
                            if (Selection1 = 1)
                                OR
                                (Selection1 = 2)
                                THEN
                                ContabAlb.SoloTraspasar(PurchRcptHeader."No.", Purchaseheader."Document Type" = Purchaseheader."Document Type"::Order);
                            COMMIT;
                        until PurchRcptHeader.Next() = 0;
                    if PurchRcptHeader.FindFirst() Then
                        repeat
                            if (Selection1 = 2)
                                THEN
                                ContabAlb.SoloContaBILIZAR(PurchRcptHeader."No.", Purchaseheader."Document Type" = Purchaseheader."Document Type"::Order);
                            COMMIT;
                        until PurchRcptHeader.Next() = 0;
                END;
            END;
            if NumeroAlbaranes = 1 THEN BEGIN
                Purchaseheader.CALCFIELDS("Nº Contrato Venta");
                if Selection1 = 2 THEN BEGIN
                    // if r36.GET(r36."Document Type"::Order, Purchaseheader."Nº Contrato Venta") THEN
                    //     fec := r36."Fecha inicial proyecto"
                    // ELSE
                    //     fec := Purchaseheader."Posting Date";
                    // // Ventana.OPEN('Fecha (inicio contrato) #########1##');
                    // Ventana.INPUT(1,fec);
                    // Ventana.CLOSE;
                    Purchaseheader."Posting Date" := fec;
                END;
                PurchPost.RUN(Purchaseheader);
                COMMIT;
                if Selection1 = 2 THEN ContabAlb.Contabilizar(Purchaseheader);
                if Selection1 = 1 THEN ContabAlb.Traspasar(Purchaseheader);
            END;
        END;
        IsHandled := true;
    end;
    #endregion Codeunit91
    #region Codeunit103
    [EventSubscriber(ObjectType::Codeunit, 103, 'OnBeforeCustLedgEntryModify', '', false, false)]
    local procedure OnBeforeCustLedgEntryModify(var CustLedgEntry: Record "Cust. Ledger Entry"; FromCustLedgEntry: Record "Cust. Ledger Entry")
    begin
        CustLedgEntry.Validate("Cod. Forma Pago", FromCustLedgEntry."Payment Method Code");
        CustLedgEntry.Banco := FromCustLedgEntry.Banco;

    end;

    [EventSubscriber(ObjectType::Codeunit, 103, 'OnRunOnAfterCustLedgEntryModify', '', false, false)]
    local procedure OnRunOnAfterCustLedgEntryModify(var CustLedgerEntryRec: Record "Cust. Ledger Entry"; var CustLedgerEntry: Record "Cust. Ledger Entry")
    Var
        Tipo: Enum "Cartera Document Type";
        ControldeProcesos: Codeunit ControlProcesos;
    begin
        ControldeProcesos.UpdatePaymentMethodCode(CustLedgerEntry."Entry No.", Tipo::Receivable, CustLedgerEntry."Payment Method Code");


    end;
    #endregion Codeunit103
    #region Codeunit113
    [EventSubscriber(ObjectType::Codeunit, 113, 'OnBeforeVendLedgEntryModify', '', false, false)]
    local procedure OnBeforeVendLedgEntryModify(var VendLedgEntry: Record "Vendor Ledger Entry"; FromVendLedgEntry: Record "Vendor Ledger Entry")
    begin
        VendLedgEntry.Validate("Cod. Forma Pago", FromVendLedgEntry."Payment Method Code");
        VendLedgEntry.Banco := FromVendLedgEntry.Banco;
    end;

    [EventSubscriber(ObjectType::Codeunit, 113, 'OnRunOnAfterVendLedgEntryMofidy', '', false, false)]
    local procedure OnRunOnAfterVendLedgEntryMofidy(var VendorLedgerEntry: Record "Vendor Ledger Entry")
    Var
        Tipo: Enum "Cartera Document Type";
        ControldeProcesos: Codeunit ControlProcesos;
    begin
        ControldeProcesos.UpdatePaymentMethodCode(VendorLedgerEntry."Entry No.", Tipo::Payable, VendorLedgerEntry."Payment Method Code");


    end;
    #endregion Codeunit113
    #region Codeunit179
    [EventSubscriber(ObjectType::Table, 179, 'OnBeforeCheckEntries', '', false, false)]
    local procedure OnBeforeCheckEntries(ReversalEntry: Record "Reversal Entry"; TableID: Integer; var SkipCheck: Boolean)
    begin
        SkipCheck := ReversalEntry.Albaran;
        if ReversalEntry.Albaran Then begin
            CheckPostingDate(ReversalEntry."Posting Date", ReversalEntry.TableCaption, ReversalEntry."Entry No.");
        end;
    end;

    local procedure CheckPostingDate(PostingDate: Date; Caption: Text[50]; EntryNo: Integer)
    var
        GenJnlCheckLine: Codeunit "Gen. Jnl.-Check Line";
        Text001: Label 'You cannot reverse %1 No. %2 because the posting date is not within the allowed posting period.';
        AllowPostingFrom: Date;
        AllowPostingto: Date;
    begin

        if GenJnlCheckLine.DateNotAllowed(PostingDate) then
            Error(Text001, Caption, EntryNo);
        // if PostingDate > MaxPostingDate then
        //     MaxPostingDate := PostingDate;
    end;
    #endregion Codeunit179
    #region Codeunit226
    [EventSubscriber(ObjectType::Codeunit, 226, 'OnBeforeCheckInitialDocumentType', '', false, false)]
    local procedure OnBeforeCheckInitialDocumentTypeCust(var DtldCustLedgEntry: Record "Detailed Cust. Ledg. Entry"; DocNo: Code[20]; PostingDate: Date; var IsHandled: Boolean)
    begin
        IsHandled := true;
    end;
    #endregion Codeunit226
    #region Codeunit227
    [EventSubscriber(ObjectType::Codeunit, 227, 'OnBeforeCheckInitialDocumentType', '', false, false)]
    local procedure OnBeforeCheckInitialDocumentType(var DtldVendLedgEntry: Record "Detailed Vendor Ledg. Entry"; DocNo: Code[20]; PostingDate: Date; var IsHandled: Boolean)
    begin
        IsHandled := true;
    end;
    #endregion Codeunit227
    #region Codeunit414
    [EventSubscriber(ObjectType::Codeunit, 414, 'OnPerformManualReleaseOnBeforeTestSalesPrepayment', '', false, false)]
    local procedure OnPerformManualReleaseOnBeforeTestSalesPrepayment(var SalesHeader: Record "Sales Header"; PreviewMode: Boolean; var IsHandled: Boolean)
    begin
        IsHandled := True;
    end;
    #endregion Codeunit414
    #region Codeunit 441
    [EventSubscriber(ObjectType::Codeunit, 441, 'OnBeforeTestSalesPrepayment', '', false, false)]
    local procedure OnBeforeTestSalesPrepayment(SalesHeader: Record "Sales Header"; var TestResult: Boolean; var IsHandled: Boolean)
    begin
        IsHandled := true;
    end;
    #endregion Codeunit 441
    #region Codeunit442
    [EventSubscriber(ObjectType::Codeunit, 442, 'OnBeforeUpdateDocNos', '', false, false)]
    local procedure OnBeforeUpdateDocNos(var SalesHeader: Record "Sales Header"; DocumentType: Option Invoice,"Credit Memo"; var DocNo: Code[20]; var NoSeriesCode: Code[20]; var ModifyHeader: Boolean; IsPreviewMode: Boolean; var IsHandled: Boolean)
    begin
        SalesHeader."Nº Contrato" := SalesHeader."No.";
    end;

    [EventSubscriber(ObjectType::Codeunit, 442, 'OnBeforeSalesCrMemoHeaderInsert', '', false, false)]
    local procedure OnBeforeSalesCrMemoHeaderInsert(var SalesCrMemoHeader: Record "Sales Cr.Memo Header"; SalesHeader: Record "Sales Header"; CommitIsSuppressed: Boolean)
    begin
        SalesCrMemoHeader."Posting Date" := Today;
        SalesCrMemoHeader."Document Date" := Today;
    end;

    [EventSubscriber(ObjectType::Codeunit, 442, 'OnBeforeSalesCrMemoLineInsert', '', false, false)]
    local procedure OnBeforeSalesCrMemoLineInsert(var SalesCrMemoLine: Record "Sales Cr.Memo Line"; SalesCrMemoHeader: Record "Sales Cr.Memo Header"; PrepmtInvLineBuffer: Record "Prepayment Inv. Line Buffer"; CommitIsSuppressed: Boolean)
    begin
        SalesCrMemoLine.Imprimir := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, 442, 'OnBeforePostPrepmtInvLineBuffer', '', false, false)]
    local procedure OnBeforePostPrepmtInvLineBuffer(var GenJnlLine: Record "Gen. Journal Line"; PrepmtInvLineBuffer: Record "Prepayment Inv. Line Buffer"; CommitIsSuppressed: Boolean)
    begin
        if GenJnlLine."Document Type" = GenJnlLine."Document Type"::"Credit Memo" Then begin
            GenJnlLine."Posting Date" := Today;
            GenJnlLine."Document Date" := Today;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 442, 'OnBeforeCheckSalesLineIsNegative', '', false, false)]
    local procedure OnBeforeCheckSalesLineIsNegative(SalesLine: Record "Sales Line"; var IsHandled: Boolean)
    begin
        IsHandled := true;
    end;
    #endregion Codeunit442
    #region Codeunit1222
    [EventSubscriber(ObjectType::Codeunit, 1222, 'OnBeforeCreateTempJnlLines', '', false, false)]
    local procedure OnBeforeCreateTempJnlLines(var FromGenJnlLine: Record "Gen. Journal Line"; var TempGenJnlLine: Record "Gen. Journal Line" temporary; var IsHandled: Boolean)
    var
        PaymentOrder: Record "Payment Order";
        PurchInvHeader: Record "Purch. Inv. Header";
        CarteraDoc: Record "Cartera Doc.";
        DescriptionTxt: Label '%1; %2', Comment = '%1=Vendor Invoice No., %2=Bill No.';
    begin
        IsHandled := true;
        TempGenJnlLine.Reset();
        PaymentOrder.Get(FromGenJnlLine.GetFilter("Document No."));
        CarteraDoc.Reset();
        CarteraDoc.SetCurrentKey(Type, "Collection Agent", "Bill Gr./Pmt. Order No.");
        CarteraDoc.SetRange(Type, CarteraDoc.Type::Payable);
        CarteraDoc.SetRange("Collection Agent", CarteraDoc."Collection Agent"::Bank);
        CarteraDoc.SetRange("Bill Gr./Pmt. Order No.", PaymentOrder."No.");
        if CarteraDoc.FindSet() then
            repeat
                with TempGenJnlLine do begin
                    Init();
                    "Journal Template Name" := '';
                    "Journal Batch Name" := '';
                    "Line No." := CarteraDoc."Entry No.";
                    "Posting Date" := CarteraDoc."Due Date";
                    "Due Date" := CarteraDoc."Due Date";
                    "Document Type" := "Document Type"::Payment;
                    "Account Type" := "Account Type"::Vendor;
                    "Account No." := CarteraDoc."Account No.";
                    "Recipient Bank Account" := CarteraDoc."Cust./Vendor Bank Acc. Code";
                    "Bal. Account Type" := "Bal. Account Type"::"Bank Account";
                    "Bal. Account No." := PaymentOrder."Bank Account No.";
                    "Bill No." := CarteraDoc."Document No.";
                    "Document No." := PaymentOrder."No.";
                    if PurchInvHeader.Get(CarteraDoc."Document No.") then
                        Description := StrSubstNo(DescriptionTxt, PurchInvHeader."Vendor Invoice No.", CarteraDoc.Description)
                    else
                        Description := CarteraDoc.Description;
                    "External Document No." := CarteraDoc."Original Document No.";
                    "Currency Code" := CarteraDoc."Currency Code";
                    Amount := CarteraDoc."Remaining Amount";
                    Insert();
                end;
            until CarteraDoc.Next() = 0;
    end;
    #endregion Codeunit1222
    #region Codeunit700
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Page Management", 'OnBeforeGetConditionalCardPageID', '', false, false)]
    local procedure OnBeforeGetConditionalCardPageID(RecRef: RecordRef; var CardPageID: Integer; var IsHandled: Boolean);
    var
        SalesHeader: record "Sales Header";
    begin
        if RecRef.Number =
            DATABASE::"Sales Header" Then begin
            RecRef.SetTable(SalesHeader);
            if SalesHeader."No. Series" = 'CONTRATO' Then begin
                CardPageID := Page::"Ficha Contrato Venta";
                IsHandled := true;
            end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Page Management", 'OnPageRunAtFieldOnBeforeRunPage', '', false, false)]
    local procedure OnPageRunAtFieldOnBeforeRunPage(var RecordRef: RecordRef; var PageID: Integer)
    var
        SalesHeader: record "Sales Header";
        AllObj: Record "AllObj";
    begin
        If PageID = Page::"Sales Order" Then Begin
            if RecordRef.Number =
                 DATABASE::"Sales Header" Then begin
                RecordRef.SetTable(SalesHeader);
                if SalesHeader."No. Series" = 'CONTRATO' Then begin
                    PageID := Page::"Ficha Contrato Venta";

                end;
            end;
        end;
    end;
    #endregion Codeunit700
    #region Codeunit841
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Cash Flow Management", 'OnBeforeShowSourceDocument', '', false, false)]
    local procedure OnBeforeShowSourceDocument(CFVariant: Variant; var Handled: Boolean)
    var
        ControldeProcesos: Codeunit ControlProcesos;
    begin
        Handled := True;
        ControldeProcesos.ShowSourceDocument(CFVariant);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Cash Flow Management", 'OnBeforeShowSource', '', false, false)]
    local procedure OnBeforeShowSource(CFVariant: Variant; var Handled: Boolean)
    var
        ControldeProcesos: Codeunit ControlProcesos;
    begin
        Handled := True;
        ControldeProcesos.ShowSource(CFVariant);
    end;
    #endregion Codeunit841
    #region Codeunit846
    [EventSubscriber(ObjectType::Codeunit, 846, 'OnAfterCreateForecastEntry', '', false, false)]
    local procedure OnAfterCreateForecastEntry(var CashFlowForecastEntry: Record "Cash Flow Forecast Entry"; CashFlowWorksheetLine: Record "Cash Flow Worksheet Line")
    begin
        CashFlowForecastEntry."Cod banco" := CashFlowWorksheetLine."Cod banco";
        CashFlowForecastEntry."Payment Method Code" := CashFlowWorksheetLine."Payment Method Code";
        CashFlowForecastEntry."Es Cartera" := CashFlowWorksheetLine."Es Cartera";
        CashFlowForecastEntry."Nombre Banco" := CashFlowWorksheetLine."Nombre Banco";
        CashFlowForecastEntry."Concepto" := CashFlowWorksheetLine.Concepto;
        CashFlowForecastEntry."Fecha Registro" := CashFlowWorksheetLine."Fecha Registro";
        CashFlowForecastEntry."Anotación" := CashFlowWorksheetLine."Anotación";
        CashFlowForecastEntry."Fecha Anotacion" := CashFlowWorksheetLine."Fecha Anotacion";
        CashFlowForecastEntry.Empresa := CompanyName();
    end;
    #endregion Codeunit846
    #region Codeunit1221
    [EventSubscriber(ObjectType::Codeunit, 1221, 'OnFillExportBufferOnAfterGetMessageID', '', false, false)]
    local procedure OnFillExportBufferOnAfterGetMessageID(var TempGenJnlLine: Record "Gen. Journal Line" temporary; var MessageID: code[20])
    begin
        MessageID := TempGenJnlLine."Document No.";
    end;
    #endregion Codeunit1221
    #region Codeunit7000
    [EventSubscriber(ObjectType::Codeunit, 7000, 'OnBeforeFindJobPlanningLinePrice', '', false, false)]
    local procedure OnBeforeFindJobPlanningLinePrice(var JobPlanningLine: Record "Job Planning Line"; CalledByFieldNo: Integer; var IsHandled: Boolean)
    var
        Control: Codeunit ControlProcesos;
        Res: Record "Resource";
    begin
        IsHandled := true;
        if Res.Get(JobPlanningLine."No.") then
            Control.FindResourcePriceOld(Res."Customer Price Group", WorkDate, JobPlanningLine."VAT %");

    end;


    #endregion Codeunit7000
    #region Codeunit10765
    [EventSubscriber(ObjectType::Codeunit, 10765, 'OnRunOnBeforeSalesInvoiceHeaderModify', '', false, false)]
    local procedure OnRunOnBeforeSalesInvoiceHeaderModify(var SalesInvoiceHeader: Record "Sales Invoice Header"; FromSalesInvoiceHeader: Record "Sales Invoice Header")
    begin
        SalesInvoiceHeader."Posting Description" := FromSalesInvoiceHeader."Posting Description";
    end;
    #endregion Codeunit10765

    #region Codeunit7000000
    [EventSubscriber(ObjectType::Codeunit, 7000000, 'OnAfterInsertReceivableDocs', '', false, false)]
    local procedure OnAfterInsertReceivableDocs(var CarteraDoc: Record "Cartera Doc."; var BillGroup: Record "Bill Group")
    var
        DebitRirectMandate: Record "SEPA Direct Debit Mandate";
        Customer: Record Customer;
        Contrato: Record "Sales Header";
        RemClos: Record "Closed Bill Group";
        RemReg: Record "Posted Bill Group";
        Remesa: Record "Bill Group";
        CarteraDocAux: Record "Cartera Doc.";
        PostedCarteraDoc: Record "Posted Cartera Doc.";
        ClosedCarteraDoc: Record "Closed Cartera Doc.";

    begin
        CarteraDoc.Get(CarteraDoc.Type, CarteraDoc."Entry No.");
        CarteraDocAux.SetFilter("Document No.", '%1', CarteraDoc."Direct Debit Mandate ID" + '*');
        If CarteraDocAux.FindSet() then
            // repeat
            //     if Remesa.Get(CarteraDocAux."Bill Gr./Pmt. Order No.") then
            //         if Remesa."Partner Type" <> BillGroup."Partner Type" then
            //             Message('La remesa no tiene el mismo tipo de socio que las anteriores');
            // until CarteraDocAux.Next() = 0;
        PostedCarteraDoc.SetFilter("Document No.", '%1', CarteraDoc."Direct Debit Mandate ID" + '*');
        If PostedCarteraDoc.FindSet() then
            // repeat
            //     if RemReg.Get(PostedCarteraDoc."Bill Gr./Pmt. Order No.") then
            //         if RemReg."Partner Type" <> BillGroup."Partner Type".AsInteger() then
            //             Message('La remesa no tiene el mismo tipo de socio que las anteriores');
            // until PostedCarteraDoc.Next() = 0;
        ClosedCarteraDoc.SetFilter("Document No.", '%1', CarteraDoc."Direct Debit Mandate ID" + '*');
        If ClosedCarteraDoc.FindSet() then
            // repeat
            //     if RemClos.Get(ClosedCarteraDoc."Bill Gr./Pmt. Order No.") then
            //         if RemClos."Partner Type" <> BillGroup."Partner Type".AsInteger() then
            //             Message('La remesa no tiene el mismo tipo de socio que las anteriores');
            // until ClosedCarteraDoc.Next() = 0;
        DebitRirectMandate.SetRange("Customer No.", CarteraDoc."Account No.");
        if CarteraDoc."Direct Debit Mandate ID" = '' Then begin
            DebitRirectMandate.SetRange("Customer No.", CarteraDoc."Account No.");
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
        end;
        if CarteraDoc."Cust./Vendor Bank Acc. Code" <> '' then
            DebitRirectMandate.SetRange("Customer Bank Account Code", CarteraDoc."Cust./Vendor Bank Acc. Code");
        DebitRirectMandate.SetRange(Closed, false);
        if DebitRirectMandate.FindLast() Then CarteraDoc."Direct Debit Mandate ID" := DebitRirectMandate.ID;
        if StrPos(Copystr(CarteraDoc."Document No.", 7), '-') > 0 then begin
            CarteraDoc."Direct Debit Mandate ID" := CopyStr(CarteraDoc."Document No.", 1, 11);
            DebitRirectMandate.SetRange("ID", CarteraDoc."Direct Debit Mandate ID");
            if DebitRirectMandate.FindFirst() Then begin
                DebitRirectMandate."Valid To" := CarteraDoc."Due Date";
                DebitRirectMandate.MODIFY();
            end else begin
                DebitRirectMandate.INIT();
                DebitRirectMandate.ID := CarteraDoc."Direct Debit Mandate ID";
                DebitRirectMandate."Customer No." := CarteraDoc."Account No.";
                DebitRirectMandate."Customer Bank Account Code" := CarteraDoc."Cust./Vendor Bank Acc. Code";
                DebitRirectMandate."Valid From" := CarteraDoc."Due Date";
                DebitRirectMandate."Date of Signature" := CarteraDoc."Posting Date";
                DebitRirectMandate."Type of Payment" := DebitRirectMandate."Type of Payment"::Recurrent;
                if Strpos(CarteraDoc."No.", '/') > 0 then
                    Evaluate(DebitRirectMandate."Expected Number of Debits", CopyStr(CarteraDoc."No.", Strpos(CarteraDoc."No.", '/') + 1, 100))
                else
                    DebitRirectMandate."Expected Number of Debits" := 1;
                DebitRirectMandate."Debit Counter" := 0;
                DebitRirectMandate."Ignore Exp. Number of Debits" := true;
                DebitRirectMandate."Valid To" := CarteraDoc."Due Date";
                DebitRirectMandate."Valid To" := Calcdate(Format(DebitRirectMandate."Expected Number of Debits") + 'M', CarteraDoc."Due Date");
                if DebitRirectMandate.INSERT() then;
            end;
        end;
        CarteraDoc.Modify();
    end;
    #endregion Codeunit 7000000
    #region Codeunit7000005
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Invoice-Split Payment", 'OnSplitSalesInvOnBeforeCheckPaymentMethod', '', false, false)]
    local procedure OnSplitSalesInvOnBeforeCheckPaymentMethod(var SalesHeader: Record "Sales Header"; var PaymentMethod: Record "Payment Method"; var PaymentTerms: Record "Payment Terms"; var IsHandled: Boolean)
    var
    begin
        IsHandled := true;
        if PaymentMethod.Get(SalesHeader."Payment Method Code") Then begin

            if NOT PaymentMethod."Remesa sin factura" THEN BEGIN                //$003
                if Salesheader.Invoice AND (SalesHeader."Bal. Account No." = '') AND
                    NOT (Salesheader."Document Type" IN [Salesheader."Document Type"::"Credit Memo", Salesheader."Document Type"::"Return Order"])
                THEN
                    IsHandled := false
                else
                    IsHandled := true;
            end else
                IsHandled := true;
        End;
        if IsHandled Then PaymentMethod."Create Bills" := false;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Invoice-Split Payment", 'OnBeforeSplitPurchInvCreateBills', '', false, false)]
    local procedure OnBeforeSplitPurchInvCreateBills(var GenJournalLine: Record "Gen. Journal Line"; PurchaseHeader: Record "Purchase Header")
    begin
        if GenJournalLine.Banco = '' Then GenJournalLine.Banco := PurchaseHeader.Banco;
    end;

    #endregion Codeunit7000005
    #region Codeunit7000008
    [EventSubscriber(ObjectType::Codeunit, 7000008, 'OnBeforeModifyCarteraDoc', '', false, false)]
    local procedure OnBeforeModifyCarteraDoc(var CarteraDoc: Record "Cartera Doc."; CurrCarteraDoc: Record "Cartera Doc.")
    begin

        CarteraDoc."Due Date" := CurrCarteraDoc."Due Date";
        CarteraDoc."Cust./Vendor Bank Acc. Code" := CurrCarteraDoc."Cust./Vendor Bank Acc. Code";
        //CarteraDoc."Pmt. Address Code" := CurrCarteraDoc."Pmt. Address Code";
        CarteraDoc."Collection Agent" := CurrCarteraDoc."Collection Agent";
        CarteraDoc.Accepted := CurrCarteraDoc.Accepted;
        CarteraDoc.Banco := CurrCarteraDoc.Banco;
        CarteraDoc."Global Dimension 2 Code" := CurrCarteraDoc."Global Dimension 2 Code";
        if CurrCarteraDoc."Bill Gr./Pmt. Order No." <> '' THEN BEGIN
            if CarteraDoc."Remaining Amount" <> CurrCarteraDoc."Remaining Amount" THEN BEGIN
                if CONFIRM('Quiere modificar el importe?', FALSE) THEN BEGIN
                    CarteraDoc."Remaining Amount" := CurrCarteraDoc."Remaining Amount";
                    CarteraDoc."Remaining Amt. (LCY)" := CurrCarteraDoc."Remaining Amount";
                END;
            END;
        END;


    end;


    [EventSubscriber(ObjectType::Codeunit, Codeunit::CarteraManagement, 'OnInsertReceivableDocsOnAfterSetFilters', '', false, false)]
    local procedure OnInsertReceivableDocsOnAfterSetFilters(var CarteraDoc: Record "Cartera Doc."; BillGroup: Record "Bill Group")
    begin
        CarteraDoc.Setrange(Accepted);
        CarteraDoc.SetRange("Collection Agent");
        CarteraDoc.SetRange("Document Type");
    end;
    #endregion Codeunit7000008
    #endregion Codeunits
}