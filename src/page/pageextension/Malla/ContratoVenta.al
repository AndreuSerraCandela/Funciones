pageextension 75004 ContratoVenta extends "Ficha Contrato Venta"
{
    layout
    {
        modify("Posting Date")
        {
            trigger OnAfterValidate()
            begin
                SaveInvoiceDiscountAmount;
            end;
        }
        modify("Salesperson Code")
        {
            trigger OnAfterValidate()
            begin
                SalespersonCodeOnAfterValidate;
            end;
        }
        modify("Currency Code")
        {
            trigger OnAssistEdit()
            var
                ChangeExchangeRate: Page "Change Exchange Rate";
            begin
                Clear(ChangeExchangeRate);
                if Rec."Posting Date" <> 0D then
                    ChangeExchangeRate.SetParameter(Rec."Currency Code", Rec."Currency Factor", Rec."Posting Date")
                else
                    ChangeExchangeRate.SetParameter(Rec."Currency Code", Rec."Currency Factor", WorkDate);
                if ChangeExchangeRate.RunModal = ACTION::OK then begin
                    Rec.Validate("Currency Factor", ChangeExchangeRate.GetParameter);
                    SaveInvoiceDiscountAmount;
                end;
                Clear(ChangeExchangeRate);
            end;
        }
    }
    actions
    {
        addfirst("&Print")
        {
            action("Imprimir")
            {
                ApplicationArea = All;
                Image = PrintDocument;
                trigger OnAction()
                var
                    rCab2: Record "Sales Header";
                begin

                    Control_Previo;

                    rCab2.SETRANGE("No.", Rec."No.");
                    REPORT.RUNMODAL(REPORT::Contrato, TRUE, FALSE, rCab2)
                end;
            }
        }
        addfirst("P&osting")
        {
            action(Post)
            {
                Enabled = false;
                Visible = False;
                ApplicationArea = Basic, Suite;
                Caption = '&Registrar';
                Ellipsis = true;
                Image = PostOrder;
                //Promoted = true;
                //PromotedCategory = Category6;
                //PromotedIsBig = true;
                ShortCutKey = 'F9';
                //   ToolTip = 'Finalize the document or journal by posting the amounts and quantities to the related accounts in your company books.';

                trigger OnAction()
                begin
                    PostDocument(CODEUNIT::"Sales-Post (Yes/No)", NavigateAfterPost::"Posted Document");
                end;
            }
            action(PostAndSend)
            {
                Enabled = false;
                Visible = False;
                ApplicationArea = Basic, Suite;
                Caption = 'Proponer fact Contratos y enviar';
                Ellipsis = true;
                Image = PostMail;
                //Promoted = true;
                //PromotedCategory = Category6;
                //  ToolTip = 'Finalize and prepare to 'Enviar el contrato according al cliente''s sending profile, such as attached to an email. The Send document to window opens first so you can confirm or select a sending profile.';

                trigger OnAction()
                begin
                    PostDocument(CODEUNIT::"Sales-Post and Send", NavigateAfterPost::"Do Nothing");
                end;
            }
        }
        addafter("&Ver Facturas Propuestas")
        {
            action("Proponer facturación contratos")
            {
                ApplicationArea = All;
                Image = Register;
                ShortcutKey = F9;
                Ellipsis = true;

                trigger OnAction()
                begin
                    PostDocument(CODEUNIT::"Sales-Post (Yes/No)", NavigateAfterPost::"Posted Document");
                end;

            }
        }

        addafter("Histórico Abonos del contrato")
        {
            action("Lista con totales")
            {
                ApplicationArea = All;
                Image = Worksheet;
                RunObject = page "Lista contratos con totales";

            }
        }
        addafter("Marcar como no Renovable")
        {
            action("Generar Pedido Compra")
            {
                ApplicationArea = All;
                Image = Purchase;
                trigger OnAction()
                var
                    cPro: Codeunit ControlProcesos;
                begin
                    cpro.GenerarContratoCompra(Rec);
                end;
            }
            action("Generar Albaranes Contratos")
            {
                ApplicationArea = All;
                Image = Purchase;
                trigger OnAction()
                var
                    cPro: Codeunit "Gestion Facturación";
                begin
                    cpro.Crear_Albaranes(Rec, true);
                end;
            }
        }
        addafter("Cambiar Cliente")
        {
            action("Generar ContraAsitento prepago")
            {
                ApplicationArea = All;
                Image = PrepaymentCreditMemo;
                trigger OnAction()
                begin
                    cGestFact.GeneraContrasientoprepago(Rec, TODAY);
                end;
            }
            action("Cambiar Fecha")
            {
                ApplicationArea = All;
                Image = ChangeDate;
                trigger OnAction()
                var
                    FechaNueva: Date;
                    Ventana: Page "Dialogo fecha contrato";
                    FechaAntigua: Date;
                    Gest_Fac: Codeunit "Gestion Facturación";
                begin


                    FechaAntigua := Rec."Order Date";
                    Ventana.SetCampos(FechaAntigua);
                    Ventana.RunModal();
                    Ventana.GetCampos(FechaNueva);
                    Rec.VALIDATE("Order Date", FechaNueva);
                    Rec.MODIFY;
                    COMMIT;
                    if (Rec.Estado = Rec.Estado::Firmado) OR (Rec.Estado = Rec.Estado::"Sin Montar") THEN BEGIN
                        CLEAR(Gest_Fac);
                        Gest_Fac.EnviarMailJm(Rec."No.",
                        STRSUBSTNO('Ha usado el botón Cambiar fecha y, se ha cambiado la fecha contrato de %1 a %2', FORMAT(FechaAntigua, 0, '<Day,2>/<Month,2>/<Year>')
                        , FORMAT(FechaNueva, 0, '<Day,2>/<Month,2>/<Year>')));
                    END;
                end;
            }
        }
        addafter("Prepayment &Test Report")
        {
            action("Generar &borrador prepago")
            {
                ApplicationArea = All;
                Image = PrepaymentSimulation;
                trigger OnAction()
                var
                    pDocumentType: Option Invoice,"Cr. Memo";
                begin
                    Rec.testfield("Fecha registro prepago");
                    cGestFact.GenerarBorradorPrepago(Rec, pDocumentType::Invoice, true, 0, 0D, 0D, Rec."Fecha registro prepago", 0, false);
                end;
            }
            //Crear_Facturas_Terminos_Prepago
            action("Generar &borradores prepago")
            {
                ApplicationArea = All;
                Image = PrepaymentInvoice;
                trigger OnAction()
                var
                begin
                    cGestFact.Crear_Facturas_Terminos_Prepago(Rec, true);
                end;
            }
        }
        addafter("Desmarcar un Periodo_promoted")

        {
            actionref("Generar Pedido Compra_promoted"; "Generar Pedido Compra")
            {

            }
        }
        addafter("Ver Facturas Propuestas_Promoted")
        {
            actionref("Proponer facturación contratos_Promoted"; "Proponer facturación contratos")
            {
            }
            actionref("Imprimir_Promoted"; "Imprimir")
            {

            }
        }
    }
    var
        cGestFact: Codeunit "Gestion Facturación";

    procedure PostDocument(PostingCodeunitID: Integer; Navigate: Enum "Navigate After Posting")
    var
        SalesHeader: Record "Sales Header";
        LinesInstructionMgt: Codeunit "Lines Instruction Mgt.";
        InstructionMgt: Codeunit "Instruction Mgt.";
        rLineas: Record "Sales Line";
        rCabVenta: Record "Sales Header";
        wPositivo: Boolean;
        rLinDetCon: Record "Sales Comment Line";
        rLinDetFra: Record "Sales Comment Line";
        NumLineas: Integer;
        r289: Record "Payment Method";
        rCli: Record Customer;
        rConfig: Record "Jobs Setup";
        Facturas: Record 36;
        SalesInvoiceHeader: Record "Sales Invoice Header";
        ApplicationAreaMgmtFacade: Codeunit "Application Area Mgmt. Facade";
    begin
        if ApplicationAreaMgmtFacade.IsFoundationEnabled then
            LinesInstructionMgt.SalesCheckAllLinesHaveQuantityAssigned(Rec);

        //Rec.SendToPosting(PostingCodeunitID);

        //DocumentIsScheduledForPosting := Rec."Job Queue Status" = Rec."Job Queue Status"::"Scheduled for Posting";
        //DocumentIsPosted := (not SalesHeader.Get(Rec."Document Type", Rec."No.")) or DocumentIsScheduledForPosting;
        //OnPostOnAfterSetDocumentIsPosted(SalesHeader, DocumentIsScheduledForPosting, DocumentIsPosted);
        //Asc

        // $004
        Rec.CalcFields("Borradores de Factura", "Facturas Registradas");
        if Rec."Borradores de Factura" <> 0 then begin
            Facturas.SetRange("Factura prepago", false);
            Facturas.SetRange("Nº Contrato", Rec."No.");
            if Facturas.FindFirst() Then
                if Rec."Tipo Facturacion" = Rec."Tipo Facturacion"::"Por Términos" Then Error('No se puede repetir la facturación por términos');

        end;
        if Rec."Facturas Registradas" > 0 Then begin
            if Rec."Tipo Facturacion" = Rec."Tipo Facturacion"::"Por Términos" Then begin
                SalesInvoiceHeader.SetRange("Nº Contrato", Rec."No.");
                SalesInvoiceHeader.SetRange("Prepayment Invoice", false);
                if SalesInvoiceHeader.FindSet() Then Error('No se puede repetir la facturación por términos');
            end;
        end;
        CompruebaPrepago(Rec);
        rLinDetCon.SETRANGE("Document Type", rLinDetCon."Document Type"::"Detalle Contrato");
        rLinDetCon.SETRANGE("No.", Rec."No.");
        rLinDetCon.SETRANGE(rLinDetCon.Validada, FALSE);
        if rLinDetCon.FINDFIRST THEN ERROR('Hay líneas de impresión sin validar');

        rConfig.GET();
        if rConfig."Facturar solo si Cto Firmado" THEN BEGIN
            if (Rec.Estado <> Rec.Estado::Firmado) AND
            (Rec.Estado <> Rec.Estado::"Sin Montar") THEN
                ERROR(Text004);
        END;
        // $003
        rLineas.RESET;
        CLEAR(rLineas);
        rLineas.SETRANGE("Document Type", Rec."Document Type");
        rLineas.SETRANGE("Document No.", Rec."No.");
        rLineas.SETFILTER("Prepmt. Line Amount", '<>%1', 0);
        rLineas.SETFILTER("Prepmt. Amt. Inv.", '%1', 0);
        rLineas.SetFilter(Reparto, '<>%1', rLineas.Reparto::"Fra prepago");
        if NOT rLineas.ISEMPTY THEN begin
            if (Rec."Last Prepayment No." <> '') Then begin
                rLineas.SetRange(rLineas."Prepmt. Amt. Inv.");
                if rLineas.FindFirst() Then
                    repeat
                        rLineas."Prepmt. Amt. Inv." := rLineas."Prepmt. Line Amount";
                        rLineas.Modify();
                    until rLineas.Next() = 0;
            end else
                ERROR(Text005);                   //$012
        end;
        //$012(I)
        rCabVenta.RESET;
        rCabVenta.SETRANGE("Nº Contrato", Rec."No.");
        rCabVenta.SETRANGE("Factura prepago", TRUE);
        if rCabVenta.count = 1 THEN begin
            if Not Confirm('Hay un prepago pendiente de registrar, quiere continuar a pesar de ello?') Then
                ERROR(Text003);
        end;
        //$012(F)

        if NOT CONFIRM('¿Desea crear los borradores de facturas para el actual contrato?') THEN
            EXIT;
        //$007
        //cGestFact.Crear_Facturas(Rec);
        r289.GET(Rec."Payment Method Code");
        if r289."Create Bills" OR r289."Invoices to Cartera" OR r289."Remesa sin factura" THEN BEGIN
            rCli.GET(Rec."Sell-to Customer No.");
            //if rCli."Default Bank Acc. Code"='' THEN ERROR('El cliente debe tener banco para esta forma de pago');
        END;
        rCabVenta := Rec;
        wPositivo := cGestFact.CalcTotalContrato(rCabVenta);
        COMMIT;
        CurrPage.UPDATE(FALSE);
        cGestFact.Crear_Facturas(Rec, wPositivo);

        rCabVenta.RESET;
        rCabVenta.SETCURRENTKEY("Nº Proyecto");
        rCabVenta.SETRANGE("Nº Proyecto", Rec."Nº Proyecto");
        rCabVenta.SETRANGE("Nº Contrato", Rec."No.");
        rCabVenta.SETRANGE("Document Type", rCabVenta."Document Type"::Invoice);
        NumLineas := rCabVenta.COUNT;
        if rCabVenta.FINDFIRST THEN
            REPEAT
                // Lineas de impresión
                rLinDetCon.SETRANGE("Document Type", rLinDetCon."Document Type"::"Detalle Contrato");
                rLinDetCon.SETRANGE("No.", Rec."No.");
                if rLinDetCon.FINDFIRST THEN
                    REPEAT
                        rLinDetFra := rLinDetCon;
                        rLinDetFra."Document Type" := rLinDetFra."Document Type"::"Detalle Factura";
                        rLinDetFra."No." := rCabVenta."No.";
                        if rLinDetFra.Precio <> 0 THEN BEGIN
                            rLinDetFra.Precio := rLinDetFra.Precio / NumLineas;
                            rLinDetFra.Iva := rLinDetFra.Precio * (rLinDetFra."% Iva" / 100);
                            rLinDetFra.Importe := rLinDetFra.Precio + rLinDetFra.Iva;
                        END;
                        rLinDetFra.INSERT;
                    UNTIL rLinDetCon.NEXT = 0;
            UNTIL rCabVenta.NEXT = 0;
        CurrPage.Update(false);
        Commit();
        if PostingCodeunitID <> CODEUNIT::"Sales-Post (Yes/No)" then
            exit;

        // case Navigate of
        //     NavigateAfterPost::"Posted Document":
        //         begin
        //             if InstructionMgt.IsEnabled(InstructionMgt.ShowPostedConfirmationMessageCode) then
        //                 ShowPostedConfirmationMessage;

        //             if DocumentIsScheduledForPosting or DocumentIsPosted then
        //                 CurrPage.Close();
        //         end;
        //     NavigateAfterPost::"New Document":
        //         if DocumentIsPosted then begin
        //             Clear(SalesHeader);
        //             SalesHeader.Init();
        //             SalesHeader.Validate("Document Type", SalesHeader."Document Type"::Order);
        //             //OnPostOnBeforeSalesHeaderInsert(SalesHeader);
        //             SalesHeader.Insert(true);
        //             PAGE.Run(PAGE::"Sales Order", SalesHeader);
        //         end;
        // end;
    end;


    local procedure SaveInvoiceDiscountAmount()
    var
        DocumentTotals: Codeunit "Document Totals";
    begin
        CurrPage.SaveRecord;
        DocumentTotals.SalesRedistributeInvoiceDiscountAmountsOnDocument(Rec);
        CurrPage.Update(false);
    end;

    local procedure SalespersonCodeOnAfterValidate()
    begin
        CurrPage.SalesLines.PAGE.UpdateForm(true);
    end;

    PROCEDURE Control_Previo();
    BEGIN
        if (Rec."Tipo Facturacion" = Rec."Tipo Facturacion"::" ") THEN BEGIN
            SalesSetup.GET();
            SalesSetup.TESTFIELD("Facturación resaltada");
            if NOT CONFIRM(Text0010, TRUE, SalesSetup."Facturación resaltada") THEN
                ERROR(Text0020);
            Rec.VALIDATE("Tipo Facturacion", SalesSetup."Facturación resaltada");
            Rec.MODIFY;
            COMMIT;
        END;
        if ((Rec."Document Type" = Rec."Document Type"::Order) AND
            (Rec."Tipo Facturacion" = Rec."Tipo Facturacion"::"Por Términos") and (Not Rec."Facturacion Bloqueada")) THEN
            cGestFact.Propuesta(Rec);
    END;

    local procedure CompruebaPrepago(Var Rec: Record "Sales Header")
    var
        TerminosFacturacion: Record "Términos facturación";
        Meses: Integer;
        Año: Integer;
        ConfV: record 311;
    begin
        ConfV.Get();
        if Rec."Cód. términos facturacion" = '' then exit;
        TerminosFacturacion.GET(Rec."Cód. términos facturacion");
        TerminosFacturacion.CalcFields("Nº de plazos");
        // meses de diferencia entre Fecha desde y fecha hasta
        Año := Date2DMY(Rec."Fecha fin proyecto", 3) - Date2DMY(Rec."Fecha inicial proyecto", 3);
        Meses := (Date2DMY(Rec."Fecha fin proyecto", 2) + 12 * Año) - (Date2DMY(Rec."Fecha inicial proyecto", 2));
        //Meses += 1;
        if TerminosFacturacion."Nº de Facturas" + TerminosFacturacion."Nº de plazos" < Meses Then begin

            if Rec."Creada facturación Prepago" = false Then begin
                if Rec."Cód. términos prepago" = '' Then begin
                    Rec."Cód. términos prepago" := Rec."Cód. términos facturacion";
                    Rec.Modify();
                    Commit;
                end;
                if Confv."Activar Prepago" Then
                    error('Debe crear la facturación prepago');
            end;
            if Confv."Activar Prepago" Then
                Error('Los periodos de pago, son menores que el peridodo de facturación');
        end;
    end;


    var
        NavigateAfterPost: Enum "Navigate After Posting";
        Importe485: Text;
        Num_Contrato: Text;

        NFC: Text;
        BillToContact: Record Contact;
        SellToContact: Record Contact;
        MoveNegSalesLines: Report "Move Negative Sales Lines";
        ApplicationAreaMgmtFacade: Codeunit "Application Area Mgmt. Facade";
        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
        ReportPrint: Codeunit "Test Report-Print";
        DocPrint: Codeunit "Document-Print";
        ArchiveManagement: Codeunit ArchiveManagement;
        SalesCalcDiscountByType: Codeunit "Sales - Calc Discount By Type";
        UserMgt: Codeunit "User Setup Management";
        CustomerMgt: Codeunit "Customer Mgt.";
        FormatAddress: Codeunit "Format Address";
        ChangeExchangeRate: Page "Change Exchange Rate";
        Usage: Option "Order Confirmation","Work Order","Pick Instruction";
        Text0010: Label 'No ha especificado Tipo Facturación. ¿Desea utilizar "%1"?';

        Text0020: Label 'Proceso abortado por el usuario.';

        Text005: Label 'No puede generar borradores de factura para este contrato porque debe generar primero el borrador de prepago y registrarlo.';

        SalesSetup: Record 311;
        Text003: Label 'No puede generar borradores de factura para este contrato porque debe registrar primero el prepago que tiene pendiente.';
        Text004: Label '"No puede generar borradores de factura para este contrato porque no esta en Estado = Firmado."';

}