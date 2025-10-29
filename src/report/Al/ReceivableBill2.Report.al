/// <summary>
/// Report Receivable Bill2 (ID 50021).
/// </summary>
report 50018 "Receivable Bill2"
{
    // 001 CAT INC-41452 - Asignación del numero de pagare.
    // 002 19/03/10 PLB. INC-47521. Quitar modificación 001
    DefaultLayout = RDLC;
    RDLCLayout = './src/report/layout/ReceivableBill2.rdlc';

    Caption = 'Carata Pagaré - Tipo 0';
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;
    Permissions = TableData 7000002 = rimd;

    dataset
    {
        dataitem("Cartera Doc."; 7000002)
        {
            DataItemTableView = SORTING(Type, "Entry No.");
            column(rProv_Name; rProv.Name)
            {
            }
            column(rProv_Address; rProv.Address)
            {
            }
            column(rProv_County; rProv.County)
            {
            }
            column(rProv__Post_Code______rProv_City; rProv."Post Code" + ' ' + rProv.City)
            {
            }
            column(Cartera_Doc___Document_No__; "Document No.")
            {
            }
            column(Cartera_Doc___Posting_Date_; "Posting Date")
            {
            }
            column(rEmpresa_Name; rEmpresa.Name)
            {
            }
            column(rEmpresa_Address; rEmpresa.Address)
            {
            }
            column(rEmpresa__Post_Code______rEmpresa_City; rEmpresa."Post Code" + ' ' + rEmpresa.City)
            {
            }
            column(rEmpresa_County; rEmpresa.County)
            {
            }
            column(Cartera_Doc___N__Impreso_; "Nº Impreso")
            {
            }
            column(rProv__Phone_No__; rProv."Phone No.")
            {
            }
            column(rProv__Address_2_; rProv."Address 2")
            {
            }
            column(CarteraDoc_Entry_No; "Cartera Doc."."Entry No.")
            {
            }
            column(CarteraDoc_Type; "Cartera Doc.".Type)
            {
            }
            column(Cartera_Doc__Type; Type)
            {
            }
            column(Cartera_Doc___No__; "No.")
            {
            }
            column(Cartera_Doc___Posting_Date__Control34; "Posting Date")
            {
            }
            column(Cartera_Doc___Document_No___Control36; "Document No.")
            {
            }
            column(Cartera_Doc___Remaining_Amount_; "Remaining Amount")
            {
            }
            column(Cartera_Doc___Due_Date_; "Due Date")
            {
            }
            column(Cartera_Doc__Banco; Banco)
            {
            }
            column(Cartera_Doc___N__Impreso__Control46; "Nº Impreso")
            {
            }
            column(Cartera_Doc__Description; Description)
            {
            }
            column(Payment_CardCaption; Payment_CardCaptionLbl)
            {
            }
            column(Document_Num_Caption; Document_Num_CaptionLbl)
            {
            }
            column(Cartera_Doc___N__Impreso_Caption; FIELDCAPTION("Nº Impreso"))
            {
            }
            column(DateCaption; DateCaptionLbl)
            {
            }
            column(Phone_n__Caption; Phone_n__CaptionLbl)
            {
            }
            column(Cartera_Doc__TypeCaption; FIELDCAPTION(Type))
            {
            }
            column(Cartera_Doc___No__Caption; FIELDCAPTION("No."))
            {
            }
            column(Cartera_Doc___Posting_Date__Control34Caption; Cartera_Doc___Posting_Date__Control34CaptionLbl)
            {
            }
            column(Cartera_Doc___Document_No___Control36Caption; FIELDCAPTION("Document No."))
            {
            }
            column(Cartera_Doc___Remaining_Amount_Caption; FIELDCAPTION("Remaining Amount"))
            {
            }
            column(Cartera_Doc___Due_Date_Caption; Cartera_Doc___Due_Date_CaptionLbl)
            {
            }
            column(Cartera_Doc__BancoCaption; FIELDCAPTION(Banco))
            {
            }
            column(Cartera_Doc___N__Impreso__Control46Caption; FIELDCAPTION("Nº Impreso"))
            {
            }
            column(Cartera_Doc__DescriptionCaption; FIELDCAPTION(Description))
            {
            }
            column(UPPERCASE_texto_1__; UPPERCASE(texto[1]))
            {
            }
            column(UPPERCASE_texto_2__; UPPERCASE(texto[2]))
            {
            }
            column(rEmpresa_City___Text001; rEmpresa.City + Text001)
            {
            }
            column(FORMAT__Original_Amount__0_Text000_; FORMAT("Original Amount", 0, Text000))
            {
            }
            column(Cartera_Doc___Due_Date__Control2; "Due Date")
            {
            }
            column(Cartera_Doc___Due_Date__Control3; "Due Date")
            {
            }
            column(Cartera_Doc___Posting_Date__Control6; "Posting Date")
            {
            }
            column(Cartera_Doc___Posting_Date__Control4; "Posting Date")
            {
            }
            column(Cartera_Doc__Entry_No_; "Entry No.")
            {
            }
            column(Cartera_Doc____Total_; Total)
            {
            }
            dataitem("Pagare/Confirming-Factura"; 7001193)
            {
                DataItemLink = "Pagaré/Confirming" = FIELD("Document No.");
                DataItemTableView = SORTING("Pagaré/Confirming", "Tipo documento", Numero);
                column(Pagare_Confirming_Factura__Pagare_Confirming_Factura____Importe_a_pagar_; "Pagare/Confirming-Factura"."Importe a pagar")
                {
                }
                column(Pagare_Confirming_Factura__Pagare_Confirming_Factura__Numero; "Pagare/Confirming-Factura".Numero)
                {
                }
                column(rMovProv__Document_Date_; Descripcion)
                {
                }
                column(rMovProv__External_Document_No__; rMovProv."External Document No.")
                {
                }
                column(Pagare_Confirming_Factura__Pagare_Confirming_Factura___Importe_original_; "Pagare/Confirming-Factura"."Importe original")
                {
                }
                column(Pagare_Confirming_Factura__Pagare_Confirming_Factura___Tipo_documento_; "Pagare/Confirming-Factura"."Tipo documento")
                {
                }
                column(Cartera_Doc____Original_Amount_; "Cartera Doc."."Original Amount")
                {
                }
                column(Document_numberCaption; Document_numberCaptionLbl)
                {
                }
                column(DateCaption_Control15; DateCaption_Control15Lbl)
                {
                }
                column(AmountCaption; AmountCaptionLbl)
                {
                }
                column(Supplier_document_numberCaption; Supplier_document_numberCaptionLbl)
                {
                }
                column(Original_amountCaption; Original_amountCaptionLbl)
                {
                }
                column(TypeCaption; TypeCaptionLbl)
                {
                }
                column(TOTALCaption; TOTALCaptionLbl)
                {
                }
                column("Pagare_Confirming_Factura_Pagaré_Confirming"; "Pagaré/Confirming")
                {
                }
                column(Pagare_Confirming_Factura_N__Efecto; "Nº Efecto")
                {
                }

                trigger OnAfterGetRecord()
                begin
                    rMovProv.SETRANGE("Document Type", "Tipo documento");
                    rMovProv.SETRANGE("Document No.", Numero);
                    rMovProv.SETRANGE("Vendor No.", "Cartera Doc."."Account No.");
                    if NOT rMovProv.FIND('-') THEN
                        CLEAR(rMovProv);
                    Descripcion := rMovProv.Description;
                end;

                trigger OnPreDataItem()
                begin
                    rMovProv.SETCURRENTKEY("Document Type", "Document No.", "Vendor No.");

                    // PLB 08/08/2005
                    // Imprimir en la carta de pago aquellas facturas pagadas con este pagaré
                    SETFILTER("Nº Efecto", '%1|%2', "Cartera Doc."."No.", '');
                end;
            }

            trigger OnAfterGetRecord()
            var
                PagareConfirmingFactura: Record 7001193;
            begin
                if rEmpresa.GET THEN;

                if NOT rProv.GET("Cartera Doc."."Account No.") THEN;

                CLEAR(rCheque);
                //rCheque.PasarDivisa("Cartera Doc."."Currency Code");
                rCheque.FormatNoText(texto, "Cartera Doc."."Original Amount", "Cartera Doc."."Currency Code");
                texto[1] := PADSTR(texto[1], MAXSTRLEN(texto[1]) - 7, '#');
                texto[2] := PADSTR(texto[2], MAXSTRLEN(texto[2]), '#');
                Total := "Cartera Doc."."Original Amount";
                //+001
                if "Cartera Doc."."¨Esta Impreso?" = "Cartera Doc."."¨Esta Impreso?"::No THEN BEGIN
                    // "Cartera Doc."."Nº Impreso" := cGestionpagare.ObtenerNumeroPagare("Cartera Doc.".Banco);
                    "Cartera Doc."."¨Esta Impreso?" := "Cartera Doc."."¨Esta Impreso?"::Si;
                    "Cartera Doc.".MODIFY;
                END;
                //-001
                PagareConfirmingFactura.SETRANGE("Pagaré/Confirming", "Cartera Doc."."Document No.");
                if NOT PagareConfirmingFactura.FINDFIRST THEN BEGIN
                    rMovProv.GET("Cartera Doc."."Entry No.");
                    rMovProv.SETFILTER("Entry No.", '<>%1', "Cartera Doc."."Entry No.");
                    rMovProv.SETRANGE("Transaction No.", rMovProv."Transaction No.");
                    if rMovProv.FINDFIRST THEN BEGIN
                        CreateVendLedgEntry := rMovProv;
                        FindApplnEntriesDtldtLedgEntry;
                        rMovProv.SETCURRENTKEY("Entry No.");
                        rMovProv.SETRANGE("Entry No.");
                        rMovProv.SETRANGE("Transaction No.");
                        if CreateVendLedgEntry."Closed by Entry No." <> 0 THEN BEGIN
                            rMovProv.GET(CreateVendLedgEntry."Closed by Entry No.");
                            PagareConfirmingFactura.INIT;
                            PagareConfirmingFactura."Pagaré/Confirming" := "Cartera Doc."."Document No.";
                            PagareConfirmingFactura."Tipo documento" := rMovProv."Document Type";
                            PagareConfirmingFactura.Numero := rMovProv."Document No.";
                            rMovProv.CALCFIELDS(Amount);
                            PagareConfirmingFactura."Importe a pagar" := -rMovProv.Amount;
                            PagareConfirmingFactura."Importe original" := -rMovProv.Amount;
                            if PagareConfirmingFactura.INSERT THEN;
                        END;
                        rMovProv.SETCURRENTKEY("Entry No.");
                        rMovProv.SETRANGE("Entry No.");
                        rMovProv.SETRANGE("Transaction No.");
                        rMovProv.SETCURRENTKEY("Closed by Entry No.");
                        rMovProv.SETRANGE("Closed by Entry No.", CreateVendLedgEntry."Entry No.");
                        if rMovProv.FIND('-') THEN
                            REPEAT

                                PagareConfirmingFactura.INIT;
                                PagareConfirmingFactura."Pagaré/Confirming" := "Cartera Doc."."Document No.";
                                PagareConfirmingFactura."Tipo documento" := rMovProv."Document Type";
                                PagareConfirmingFactura.Numero := rMovProv."Document No.";
                                rMovProv.CALCFIELDS(Amount);
                                PagareConfirmingFactura."Importe a pagar" := -rMovProv.Amount;
                                PagareConfirmingFactura."Importe original" := -rMovProv.Amount;
                                if PagareConfirmingFactura.INSERT THEN;
                            UNTIL rMovProv.NEXT = 0;

                    END;
                    rMovProv.RESET;
                END;
            end;
        }
    }

    requestpage
    {

        layout
        {
            area(content)
            {
                group(Options)
                {
                    Caption = 'Opciones';
                    field(CtrlBanco; rUsre.Code20)
                    {
                        ApplicationArea = All;
                        Caption = 'Banco';
                        Editable = false;
                    }
                    field(CtrlPagare; wPagare)
                    {
                        ApplicationArea = All;
                        Caption = 'Último número de pagaré';
                        Editable = true;

                        trigger OnValidate()
                        begin
                            wPagareOnAfterValidate;
                        end;
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
        rUsre.GET(UserId);
    end;

    var
        rProv: Record Vendor;
        rMovProv: Record 25;
        rEmpresa: Record 79;
        rBanco: Record 270;
        PasoParam: Record 85;
        Payment_CardCaptionLbl: Label 'Carta de pago';
        Document_Num_CaptionLbl: Label 'Nº Documento';
        DateCaptionLbl: Label 'Fecha';
        Phone_n__CaptionLbl: Label 'Phone nº.';
        Cartera_Doc___Posting_Date__Control34CaptionLbl: Label 'Fecha Registro';
        Cartera_Doc___Due_Date_CaptionLbl: Label 'Overdue Date';
        Document_numberCaptionLbl: Label 'Número Documento';
        DateCaption_Control15Lbl: Label 'Fecha';
        AmountCaptionLbl: Label 'Importe';
        Supplier_document_numberCaptionLbl: Label 'Nº documento proveedor';
        Original_amountCaptionLbl: Label 'Importe Original';
        TypeCaptionLbl: Label 'Tipo';
        TOTALCaptionLbl: Label 'TOTAL';
        texto: array[2] of Text[80];
        rCheque: Report 1401;
        Text000: Label '####<Sign><Integer Thousand><Decimals>####';
        Text001: Label ', a';
        Text003: Label 'No puede dejar el último nº de pagaré en blanco';
        Total: Decimal;
        wPagare: Text;
        rUsre: Record "User Setup";
        CreateVendLedgEntry: Record 25;
        Descripcion: Text[80];

    local procedure wPagareOnAfterValidate()
    begin
        if wPagare = '' THEN
            ERROR(Text003);
        rUsre.Get(UserId);
        rBanco.GET(rUsre.Code20);
        if (rBanco."Ult. nº pagare" = '') AND (wPagare = rBanco."Nº inicial pagare") THEN
            EXIT;
        if wPagare = rBanco."Ult. nº pagare" THEN
            EXIT;
        rBanco."Ult. nº pagare" := wPagare;
        rBanco.MODIFY;
    end;

    local procedure FindApplnEntriesDtldtLedgEntry()
    var
        DtldVendLedgEntry1: Record 380;
        DtldVendLedgEntry2: Record 380;
    begin
        DtldVendLedgEntry1.SETCURRENTKEY("Vendor Ledger Entry No.");
        DtldVendLedgEntry1.SETRANGE("Vendor Ledger Entry No.", CreateVendLedgEntry."Entry No.");
        DtldVendLedgEntry1.SETRANGE(Unapplied, FALSE);
        if DtldVendLedgEntry1.FIND('-') THEN
            REPEAT
                if DtldVendLedgEntry1."Vendor Ledger Entry No." =
                   DtldVendLedgEntry1."Applied Vend. Ledger Entry No."
                THEN BEGIN
                    DtldVendLedgEntry2.INIT;
                    DtldVendLedgEntry2.SETCURRENTKEY("Applied Vend. Ledger Entry No.", "Entry Type");
                    DtldVendLedgEntry2.SETRANGE(
                      "Applied Vend. Ledger Entry No.", DtldVendLedgEntry1."Applied Vend. Ledger Entry No.");
                    DtldVendLedgEntry2.SETRANGE("Entry Type", DtldVendLedgEntry2."Entry Type"::Application);
                    DtldVendLedgEntry2.SETRANGE(Unapplied, FALSE);
                    if DtldVendLedgEntry2.FIND('-') THEN
                        REPEAT
                            if DtldVendLedgEntry2."Vendor Ledger Entry No." <>
                               DtldVendLedgEntry2."Applied Vend. Ledger Entry No."
                            THEN BEGIN
                                rMovProv.SETCURRENTKEY("Entry No.");
                                rMovProv.SETRANGE("Entry No.", DtldVendLedgEntry2."Vendor Ledger Entry No.");
                                if rMovProv.FIND('-') THEN
                                    rMovProv.MARK(TRUE);
                            END;
                        UNTIL DtldVendLedgEntry2.NEXT = 0;
                END ELSE BEGIN
                    rMovProv.SETCURRENTKEY("Entry No.");
                    rMovProv.SETRANGE("Entry No.", DtldVendLedgEntry1."Applied Vend. Ledger Entry No.");
                    if rMovProv.FIND('-') THEN
                        rMovProv.MARK(TRUE);
                END;
            UNTIL DtldVendLedgEntry1.NEXT = 0;
    end;
}

