codeunit 7001103 "SEPA DD-Export File Malla"
{
    TableNo = "Direct Debit Collection Malla";

    trigger OnRun()
    var
        DirectDebitCollection: Record "Direct Debit Collection";
        DirectDebitCollectionEntry: Record "Direct Debit Collection Malla";
        BankAccount: Record "Bank Account";
        GeneralLedgerSetup: Record "General Ledger Setup";
    begin
        DirectDebitCollectionEntry.Copy(Rec);
        GetDirectDebitCollection(Rec, DirectDebitCollection);
        DirectDebitCollection.TestField("To Bank Account No.");
        BankAccount.Get(DirectDebitCollection."To Bank Account No.");
        GeneralLedgerSetup.Get();
        if not GeneralLedgerSetup."SEPA Export w/o Bank Acc. Data" then
            BankAccount.TestField(IBAN)
        else
            if (BankAccount."Bank Account No." = '') or (BankAccount."Bank Branch No." = '') then
                if BankAccount.IBAN = '' then
                    Error(ExportWithoutIBANErr, BankAccount.TableCaption(), BankAccount."No.");

        DirectDebitCollection.LockTable();
        DirectDebitCollection.DeletePaymentFileErrors;
        Commit();
        if not Export(Rec, BankAccount.GetDDExportXMLPortID, DirectDebitCollection.Identifier) then
            Error('');

        DirectDebitCollectionEntry.SetRange("Direct Debit Collection No.", DirectDebitCollection."No.");
        DirectDebitCollectionEntry.ModifyAll(Status, DirectDebitCollectionEntry.Status::"File Created");
        DirectDebitCollection.Status := DirectDebitCollection.Status::"File Created";
        DirectDebitCollection.Modify();
    end;

    var
        ExportToServerFile: Boolean;
        ExportWithoutIBANErr: Label 'Either the Bank Account No. and Bank Branch No. fields or the IBAN field debe ser filled in for %1 %2.', Comment = '%1= table name, %2=key field value. Example: Either the Bank Account No. and Bank Branch No. fields or the IBAN field debe ser filled in for Bank Account WWB-OPERATING.';

    local procedure Export(var DirectDebitCollectionEntry: Record "Direct Debit Collection Malla"; XMLPortID: Integer; FileName: Text) Result: Boolean
    var
        TempBlob: Codeunit "Temp Blob";
        FileManagement: Codeunit "File Management";
        OutStr: OutStream;
        IsHandled: Boolean;
    begin
        TempBlob.CreateOutStream(OutStr);
        XMLPORT.Export(XMLPortID, OutStr, DirectDebitCollectionEntry);

        IsHandled := false;
        OnExportOnAfterXMLPortExport(TempBlob, Result, IsHandled);
        if IsHandled then
            exit(Result);

        exit(FileManagement.BLOBExport(TempBlob, StrSubstNo('%1.XML', FileName), not ExportToServerFile) <> '');
    end;

    local procedure GetDirectDebitCollection(var DirectDebitCollectionEntry: Record "Direct Debit Collection Malla"; var DirectDebitCollection: Record "Direct Debit Collection")
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeGetDirectDebitCollection(DirectDebitCollectionEntry, DirectDebitCollection, IsHandled);
        if IsHandled then
            exit;

        DirectDebitCollection.Get(DirectDebitCollectionEntry.GetRangeMin("Direct Debit Collection No."));
    end;

    procedure EnableExportToServerFile()
    begin
        ExportToServerFile := true;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeGetDirectDebitCollection(var DirectDebitCollectionEntry: Record "Direct Debit Collection Malla"; var DirectDebitCollection: Record "Direct Debit Collection"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnExportOnAfterXMLPortExport(var TempBlob: Codeunit "Temp Blob"; var Result: Boolean; var IsHandled: Boolean)
    begin
    end;
}
codeunit 7001104 "SEPA DD-Check Line Malla"
{
    TableNo = "Direct Debit Collection Malla";

    trigger OnRun()
    begin
        Rec.DeletePaymentFileErrors;
        CheckCollectionEntry(Rec);
    end;

    var
        EuroCurrErr: Label 'Solo están permitidas las transacciones en euro (EUR)';
        FieldBlankErr: Label '%1 debe tener el valor in %2.', Comment = '%1=field name, %2=table name. Example: Name debe tener el valor in Customer.';
        FieldKeyBlankErr: Label '%1 debe tener el valor in %2 %3.', Comment = '%1=field name, %2= table name, %3=key field value. Example: Name debe tener el valor in Customer 10000.';
        MustBeCustomerErr: Label 'El cliente %1 no existe';
        MustBePositiveErr: Label 'El importe debe ser positivo.';
        NotActiveMandateErr: Label 'El mandato %1 is no esta activo.';
        PartnerTypeErr: Label 'El campo %1, %2, debe ser igual a el %1, %3, especificado en la coleccion.', Comment = '%1 = Partner Type; %2 = Company/Person; %3 = Company/Person.';
        TransferDateErr: Label 'La fecha de vencimiento más temprana debe ser hoy.';
        TransferDateAddnlInfoTxt: Label 'Puedes usar resetear fecha tranferencia para eliminar el error.';
        SelectedRecordTxt: Label 'El registro seleccionado';
        PartnerTypeBlankErr: Label '%1 debe ser rellenado.', Comment = 'Partner Type debe ser filled.';
        ExportWithoutIBANAndSWIFTErr: Label 'La Cuenta del banco y la oficina o el SWIFT y IBAN deben ser rellenados para %1 %2.', Comment = '%1= table name, %2=key field value. Example: Either the Bank Account No. and Bank Branch No. fields or the SWIFT Code and IBAN fields debe ser filled in for Customer Bank Account ECA.';

    local procedure CheckCollectionEntry(DirectDebitCollectionEntry: Record "Direct Debit Collection Malla")
    var
        Customer: Record Customer;
        CustomerBankAccount: Record "Customer Bank Account";
        DirectDebitCollection: Record "Direct Debit Collection";
        GLSetup: Record "General Ledger Setup";
        SEPADirectDebitMandate: Record "SEPA Direct Debit Mandate";
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeCheckCollectionEntry(DirectDebitCollectionEntry, IsHandled);
        if IsHandled then
            exit;

        GLSetup.Get();
        with DirectDebitCollectionEntry do begin
            if "Transfer Amount" <= 0 then
                InsertPaymentFileError(MustBePositiveErr);

            if ("Currency Code" <> GLSetup.GetCurrencyCode('EUR')) and not GLSetup."SEPA Non-Euro Export" then
                InsertPaymentFileError(EuroCurrErr);

            if "Transfer Date" < Today then
                InsertPaymentFileErrorWithDetails(TransferDateErr, TransferDateAddnlInfoTxt);

            if not Customer.Get("Customer No.") then begin
                InsertPaymentFileError(StrSubstNo(MustBeCustomerErr, "Customer No."));
                exit;
            end;

            if Customer.Name = '' then
                AddFieldEmptyError(DirectDebitCollectionEntry, Customer.TableCaption, Customer.FieldCaption(Name), "Customer No.");

            DirectDebitCollection.Get("Direct Debit Collection No.");
            if Customer."Partner Type" <> DirectDebitCollection."Partner Type" then
                InsertPaymentFileError(StrSubstNo(PartnerTypeErr, Customer.FieldCaption("Partner Type"), Customer."Partner Type",
                    DirectDebitCollection."Partner Type"));

            if DirectDebitCollection."Partner Type" = DirectDebitCollection."Partner Type"::" " then
                InsertPaymentFileError(StrSubstNo(PartnerTypeBlankErr, DirectDebitCollection.FieldCaption("Partner Type")));

            if "Mandate ID" = '' then
                AddFieldEmptyError(DirectDebitCollectionEntry, SelectedRecordTxt, FieldCaption("Mandate ID"), "Mandate ID")
            else begin
                SEPADirectDebitMandate.Get("Mandate ID");
                if SEPADirectDebitMandate."Date of Signature" = 0D then
                    AddFieldEmptyError(
                      DirectDebitCollectionEntry, SEPADirectDebitMandate.TableCaption, SEPADirectDebitMandate.FieldCaption("Date of Signature"),
                      "Mandate ID");
                if not SEPADirectDebitMandate.IsMandateActive("Transfer Date") then
                    InsertPaymentFileError(StrSubstNo(NotActiveMandateErr, "Mandate ID"));

                if SEPADirectDebitMandate."Customer Bank Account Code" = '' then
                    AddFieldEmptyError(
                      DirectDebitCollectionEntry, SEPADirectDebitMandate.TableCaption,
                      SEPADirectDebitMandate.FieldCaption("Customer Bank Account Code"), SEPADirectDebitMandate.ID)
                else begin
                    CustomerBankAccount.Get(Customer."No.", SEPADirectDebitMandate."Customer Bank Account Code");
                    if not GLSetup."SEPA Export w/o Bank Acc. Data" then begin
                        if CustomerBankAccount."SWIFT Code" = '' then
                            AddFieldEmptyError(
                              DirectDebitCollectionEntry, CustomerBankAccount.TableCaption, CustomerBankAccount.FieldCaption("SWIFT Code"),
                              CustomerBankAccount.Code);
                        if CustomerBankAccount.IBAN = '' then
                            AddFieldEmptyError(
                              DirectDebitCollectionEntry, CustomerBankAccount.TableCaption, CustomerBankAccount.FieldCaption(IBAN),
                              CustomerBankAccount.Code);
                    end else
                        if (CustomerBankAccount."Bank Account No." = '') or (CustomerBankAccount."Bank Branch No." = '') then
                            if (CustomerBankAccount."SWIFT Code" = '') or (CustomerBankAccount.IBAN = '') then
                                InsertPaymentFileError(
                                  StrSubstNo(ExportWithoutIBANAndSWIFTErr, CustomerBankAccount.TableCaption(), CustomerBankAccount.Code));
                end;
            end;
        end;
    end;

    local procedure AddFieldEmptyError(var DirectDebitCollectionEntry: Record "Direct Debit Collection Malla"; TableCaption: Text; FieldCaption: Text; KeyValue: Text)
    var
        ErrorText: Text;
    begin
        if KeyValue = '' then
            ErrorText := StrSubstNo(FieldBlankErr, FieldCaption, TableCaption)
        else
            ErrorText := StrSubstNo(FieldKeyBlankErr, FieldCaption, TableCaption, KeyValue);
        DirectDebitCollectionEntry.InsertPaymentFileError(ErrorText);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCheckCollectionEntry(var DirectDebitCollectionEntry: Record "Direct Debit Collection Malla"; var IsHandled: Boolean)
    begin
    end;
}
codeunit 7001105 "SEPA DD-Fill Exp. Buffer Malla"
{
    Permissions = TableData "Payment Export Data" = rimd;
    TableNo = "Payment Export Data";

    trigger OnRun()
    begin
    end;

    var
        HasErrorsErr: Label 'The file export has one or more errors.\\For each line to be exported, resolve the errors displayed to the right and then try to export again.';

    /// <summary>
    /// FillExportBuffer.
    /// </summary>
    /// <param name="DirectDebitCollectionEntry">VAR Record "Direct Debit Collection Malla".</param>
    /// <param name="PaymentExportData">VAR Record "Payment Export Data".</param>
    procedure FillExportBuffer(var DirectDebitCollectionEntry: Record "Direct Debit Collection Malla"; var PaymentExportData: Record "Payment Export Data")
    var
        BankAccount: Record "Bank Account";
        BankExportImportSetup: Record "Bank Export/Import Setup";
        Customer: Record Customer;
        CustomerBankAccount: Record "Customer Bank Account";
        DirectDebitCollection: Record "Direct Debit Collection";
        GLSetup: Record "General Ledger Setup";
        SEPADirectDebitMandate: Record "SEPA Direct Debit Mandate";
        TempDirectDebitCollectionEntry: Record "Direct Debit Collection Malla" temporary;
    begin
        TempDirectDebitCollectionEntry.CopyFilters(DirectDebitCollectionEntry);
        CODEUNIT.Run(CODEUNIT::"SEPA DD-Prepare Source Malla", TempDirectDebitCollectionEntry);

        TempDirectDebitCollectionEntry.SetAutoCalcFields("Applies-to Entry Document No.", "Applies-to Entry Description");

        if not TempDirectDebitCollectionEntry.FindSet then
            exit;

        DirectDebitCollection.Get(TempDirectDebitCollectionEntry."Direct Debit Collection No.");
        BankAccount.Get(DirectDebitCollection."To Bank Account No.");
        BankAccount.GetDDExportImportSetup(BankExportImportSetup);
        BankExportImportSetup.TestField("Check Export Codeunit");
        repeat
            CODEUNIT.Run(BankExportImportSetup."Check Export Codeunit", TempDirectDebitCollectionEntry);
        until TempDirectDebitCollectionEntry.Next() = 0;

        if DirectDebitCollection.HasPaymentFileErrors then begin
            Commit();
            Error(HasErrorsErr);
        end;

        GLSetup.Get();
        GLSetup.TestField("LCY Code");

        TempDirectDebitCollectionEntry.FindSet();
        with PaymentExportData do begin
            Reset;
            if FindLast then;
            repeat
                Init;
                "Entry No." += 1;
                SetPreserveNonLatinCharacters(BankExportImportSetup."Preserve Non-Latin Characters");
                SetBankAsSenderBank(BankAccount);
                SetCreditorIdentifier(BankAccount);
                "SEPA Direct Debit Mandate ID" := TempDirectDebitCollectionEntry."Mandate ID";
                SEPADirectDebitMandate.Get(TempDirectDebitCollectionEntry."Mandate ID");
                "SEPA DD Mandate Signed Date" := SEPADirectDebitMandate."Date of Signature";

                TempDirectDebitCollectionEntry."Sequence Type" :=
                  UpdateSourceEntrySequenceType(TempDirectDebitCollectionEntry);

                Validate("SEPA Direct Debit Seq. Type", TempDirectDebitCollectionEntry."Sequence Type");
                "Transfer Date" := TempDirectDebitCollectionEntry."Transfer Date";
                "Document No." := TempDirectDebitCollectionEntry."Applies-to Entry Document No.";
                Amount := TempDirectDebitCollectionEntry."Transfer Amount";
                "Currency Code" := GLSetup.GetCurrencyCode(TempDirectDebitCollectionEntry."Currency Code");

                Customer.Get(TempDirectDebitCollectionEntry."Customer No.");
                CustomerBankAccount.Get(Customer."No.", SEPADirectDebitMandate."Customer Bank Account Code");
                SetCustomerAsRecipient(Customer, CustomerBankAccount);

                Validate("SEPA Partner Type", Customer."Partner Type");
                Validate("SEPA Instruction Priority", "SEPA Instruction Priority"::NORMAL);
                Validate("SEPA Payment Method", "SEPA Payment Method"::TRF);
                Validate("SEPA Charge Bearer", "SEPA Charge Bearer"::SLEV);

                "SEPA Batch Booking" := false;
                "Message ID" := DirectDebitCollection."Message ID";
                "Payment Information ID" := TempDirectDebitCollectionEntry."Transaction ID";
                "End-to-End ID" := TempDirectDebitCollectionEntry."Transaction ID";
                "Message to Recipient 1" := TempDirectDebitCollectionEntry."Applies-to Entry Description";
                "Message to Recipient 2" := TempDirectDebitCollectionEntry."Message to Recipient";

                OnBeforeInsertPaymentExportData(PaymentExportData, TempDirectDebitCollectionEntry);
                Insert(true);
            until TempDirectDebitCollectionEntry.Next() = 0;
        end;
    end;

    local procedure UpdateSourceEntrySequenceType(TempDirectDebitCollectionEntry: Record "Direct Debit Collection Malla" temporary) SequenceType: Integer
    var
        DirectDebitCollectionEntry: Record "Direct Debit Collection Malla";
        SEPADirectDebitMandate: Record "SEPA Direct Debit Mandate";
    begin
        if TempDirectDebitCollectionEntry.Status <> TempDirectDebitCollectionEntry.Status::New then
            exit(TempDirectDebitCollectionEntry."Sequence Type");

        with SEPADirectDebitMandate do begin
            Get(TempDirectDebitCollectionEntry."Mandate ID");
            SequenceType := GetSequenceType;
            UpdateCounter;
        end;

        DirectDebitCollectionEntry := TempDirectDebitCollectionEntry;
        with DirectDebitCollectionEntry do
            if Find then begin
                "Sequence Type" := SequenceType;
                Modify;
            end;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInsertPaymentExportData(var PaymentExportData: Record "Payment Export Data"; var TempDirectDebitCollectionEntry: Record "Direct Debit Collection Malla" temporary)
    begin
    end;
}
codeunit 7001106 "SEPA DD-Prepare Source Malla"
{
    TableNo = "Direct Debit Collection Malla";

    trigger OnRun()
    var
        DirectDebitCollectionEntry: Record "Direct Debit Collection Malla";
    begin
        DirectDebitCollectionEntry.CopyFilters(Rec);
        CopyLines(DirectDebitCollectionEntry, Rec);
    end;

    local procedure CopyLines(var FromDirectDebitCollectionEntry: Record "Direct Debit Collection Malla"; var ToDirectDebitCollectionEntry: Record "Direct Debit Collection Malla")
    begin
        if not FromDirectDebitCollectionEntry.IsEmpty() then begin
            FromDirectDebitCollectionEntry.SetFilter(Status, '%1|%2',
              FromDirectDebitCollectionEntry.Status::New, FromDirectDebitCollectionEntry.Status::"File Created");
            if FromDirectDebitCollectionEntry.FindSet then
                repeat
                    ToDirectDebitCollectionEntry := FromDirectDebitCollectionEntry;
                    ToDirectDebitCollectionEntry.Insert();
                until FromDirectDebitCollectionEntry.Next() = 0
        end else
            CreateTempCollectionEntries(FromDirectDebitCollectionEntry, ToDirectDebitCollectionEntry);
    end;

    local procedure CreateTempCollectionEntries(var FromDirectDebitCollectionEntry: Record "Direct Debit Collection Malla"; var ToDirectDebitCollectionEntry: Record "Direct Debit Collection Malla")
    var
        BillGroup: Record "Bill Group";
        CarteraDoc: Record "Cartera Doc.";
        DirectDebitCollection: Record "Direct Debit Collection";
    begin
        ToDirectDebitCollectionEntry.Reset();
        DirectDebitCollection.Get(FromDirectDebitCollectionEntry.GetRangeMin("Direct Debit Collection No."));
        BillGroup.Get(DirectDebitCollection.Identifier);
        CarteraDoc.SetCurrentKey(Type, "Collection Agent", "Bill Gr./Pmt. Order No.");
        CarteraDoc.SetRange(Type, CarteraDoc.Type::Receivable);
        CarteraDoc.SetRange("Collection Agent", CarteraDoc."Collection Agent"::Bank);
        CarteraDoc.SetRange("Bill Gr./Pmt. Order No.", BillGroup."No.");
        if CarteraDoc.FindSet then
            repeat
                ToDirectDebitCollectionEntry.Init();
                ToDirectDebitCollectionEntry."Direct Debit Collection No." := DirectDebitCollection."No.";
                ToDirectDebitCollectionEntry."Entry No." := CarteraDoc."Entry No.";
                ToDirectDebitCollectionEntry."Customer No." := CarteraDoc."Account No.";
                ToDirectDebitCollectionEntry.Validate("Applies-to Entry No.", CarteraDoc."Entry No.");
                ToDirectDebitCollectionEntry.Validate("Mandate ID", CarteraDoc."Direct Debit Mandate ID");
                ToDirectDebitCollectionEntry.Insert();
            until CarteraDoc.Next() = 0;

        OnAfterCreateTempCollectionEntries(FromDirectDebitCollectionEntry, ToDirectDebitCollectionEntry);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCreateTempCollectionEntries(var FromDirectDebitCollectionEntry: Record "Direct Debit Collection Malla"; var ToDirectDebitCollectionEntry: Record "Direct Debit Collection Malla")
    begin
    end;
}







