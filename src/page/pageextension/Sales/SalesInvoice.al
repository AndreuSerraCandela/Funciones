/// <summary>
/// PageExtension SalesInvoice (ID 80140) extends Record Sales Invoice.
/// </summary>
pageextension 80140 SalesInvoice extends "Sales Invoice"
{
    Caption = 'Documento de venta';
    DataCaptionExpression = Albaran_Factura;


    layout
    {


        modify("Posting Description")
        {
            Visible = true;
            ApplicationArea = All;
        }



        addafter(Status)
        {
            field("Nº Proyecto"; Rec."Nº Proyecto")
            {
                ApplicationArea = All;
            }
            field("Nº Contrato"; Rec."Nº Contrato")
            {
                ApplicationArea = All;

            }
            field("Nº pedido"; Rec."Nº pedido")
            {
                ApplicationArea = All;
            }
            field("Nº pedido cliente"; Rec."Customer Order No.")
            {
                ApplicationArea = All;
            }
            field("Fecha inicial proyecto"; Rec."Fecha inicial proyecto")
            {
                ApplicationArea = All;

            }
            field("Fecha fin proyecto"; Rec."Fecha fin proyecto")
            {
                ApplicationArea = All;
            }
            field("Posting No. Series"; Rec."Posting No. Series")
            {
                ApplicationArea = All;
            }
            field("No. Series"; Rec."No. Series")
            {
                ApplicationArea = All;
                Editable = true;
            }
            field("Factura prepago"; Rec."Factura prepago")
            {
                ApplicationArea = All;
            }
            field("Esperar Orden Cliente"; Rec."Esperar Orden Cliente")
            {
                ApplicationArea = All;
            }
        }
        addbefore(SalesLines)
        {
            field(AVT; Avisos)
            {
                Visible = AVTVisible;
                ApplicationArea = All;
            }
        }
        addafter(SalesLines)
        {
            part("Lineas de impresion"; "Lineas de Impresión")
            {
                SubPageLink = "Document Type" = field("Document Type"), "No." = field("No.");
                ApplicationArea = All;

            }
        }
        addafter("Bill-to Contact")
        {
            // field("Esperar Orden Cliente";Rec."Esperar Orden Cliente")
            // {
            //     ApplicationArea=All;
            // }
            field("Nº sig. factura"; Rec."Posting No.")
            {
                ApplicationArea = All;
            }

        }
        addafter("Payment Method Code")
        {
            field("Nuestra Cuenta Transf."; Rec."Nuestra Cuenta")
            {
                ApplicationArea = All;
                Importance = Promoted;
                ShowMandatory = true;
                trigger OnLookup(var Text: Text): Boolean
                var
                    r270: Record 270;
                begin
                    r270.SETRANGE("Banco para Transf. Clientes", TRUE);
                    if Page.RUNMODAL(0, r270) = ACTION::LookupOK THEN BEGIN
                        Rec."Nuestra Cuenta" := r270."No.";
                        Rec."B2R Bank Payment Code" := Rec."Nuestra Cuenta";

                    END;

                end;


            }
        }
        addafter("Payment Terms Code")
        {
            field("Tipo factura SII"; Rec."Tipo factura SII")
            {
                ApplicationArea = All;
            }
            field("Descripción operación"; Rec."Descripción operación")
            {
                ApplicationArea = All;
            }
            field("Tipo factura rectificativa"; Rec."Tipo factura rectificativa")
            {
                ApplicationArea = All;
            }
            field("Nº factura correctiva"; Rec."Corrected Invoice No.")
            {
                ApplicationArea = All;
            }
        }
        addafter("Foreign Trade")
        {
            group(Comentario)
            {

                field("Comentario Cabecera"; Rec."Comentario Cabecera")
                {
                    ApplicationArea = All;
                }
            }
            group(Proyecto)
            {
                field("Proyecto origen"; Rec."Proyecto origen") { ApplicationArea = All; }
                field("Interc./Compens."; Rec."Interc./Compens.") { Editable = false; ApplicationArea = All; }
                field(Renovado; Rec.Renovado) { Editable = false; ApplicationArea = All; }
                field("Soporte de"; Rec."Soporte de") { Editable = false; ApplicationArea = All; }
                field(Subtipo; Rec.Subtipo) { Editable = false; ApplicationArea = All; }
                field("Fecha Firma"; Rec."Fecha Firma") { Editable = false; ApplicationArea = All; }
                field(Firmado; Rec.Firmado) { Editable = false; ApplicationArea = All; }
                field(Tipo; Rec.Tipo) { Editable = false; ApplicationArea = All; }
                field("Fecha inicial factura"; Rec."Fecha inicial factura") { Editable = false; ApplicationArea = All; }
                field("Fecha final factura"; Rec."Fecha final factura") { Editable = false; ApplicationArea = All; }
                field("Número Proyecto"; Rec."Nº Proyecto") { ApplicationArea = All; }

            }
        }
    }
    actions
    {
        addlast("&Invoice")
        {
            action("Imprimir &Factura Borrador")
            {
                Image = Document;
                ApplicationArea = All;
                trigger OnAction()
                var
                    rCab2: Record "Sales Header";
                Begin
                    rCab2.RESET;
                    rCab2.SETRANGE("Document Type", Rec."Document Type"::Invoice);
                    rCab2.SETRANGE("No.", Rec."No.");
                    REPORT.RUNMODAL(REPORT::"Pre-Sales-Invoice Pdf", TRUE, FALSE, rCab2);
                End;
            }

            action("Cambair Nº Serie")
            {
                Image = SerialNo;
                ApplicationArea = All;
                trigger OnAction()
                var
                    NoSeries: Record "No. Series";
                begin
                    if Page.RunModal(0, NoSeries) in [Action::LookupOK, Action::OK] then begin
                        Rec.Validate("No. Series", NoSeries.Code);
                        Rec.Modify();
                    end;
                end;
            }
            action("Recupera Dimensiones Contrato")
            {
                Image = Dimensions;
                ApplicationArea = All;
                trigger ONaction()
                begin
                    RecuperaDimensionesContrato(Rec);
                end;
            }
            action("Recupera Nº Cuenta")
            {
                Image = BankAccount;
                ApplicationArea = All;
                trigger ONaction()
                var
                    // Crea una varaible para customer
                    rCustomer: Record Customer;
                begin
                    //Recupera el cliente de la factura y actualiza el campo nuestra cuenta
                    rCustomer.GET(Rec."Sell-to Customer No.");
                    Rec."Nuestra Cuenta" := rCustomer."Banco transferencia";
                    Rec.MODIFY;

                end;


            }
            action("Eliminar")
            {
                Image = Delete;
                ApplicationArea = All;
                trigger OnAction()
                var
                    r37: Record 37;
                Begin
                    r37.SetRange("Document Type", Rec."Document Type");
                    r37.SetRange("Document No.", Rec."No.");
                    r37.DeleteAll();
                    Rec.Delete();
                End;
            }
        }
        addafter("F&unctions")
        {
            action("Enviar a Cartera")
            {
                ApplicationArea = All;
                Image = SuggestCustomerBill;
                trigger OnAction()
                var
                    rContr: Record "Sales Header";
                    i: Integer;
                    rPag: Record "Payment Method";
                    cCartera: Codeunit "Gestion cartera";
                    rBorr: Record "Sales Header";
                begin

                    Rec.TESTFIELD("Nº Contrato");
                    rContr.GET(rContr."Document Type"::Order, Rec."Nº Contrato");
                    rContr.CALCFIELDS(rContr."Facturas Registradas");
                    i := rContr."Facturas Registradas";
                    rPag.GET(Rec."Payment Method Code");
                    rPag.TESTFIELD(rPag."Remesa sin factura");
                    Rec."Remesa sin factura" := TRUE;
                    Rec.MODIFY;
                    rBorr.SETCURRENTKEY(rBorr."Nº Proyecto");
                    rBorr.SETRANGE(rBorr."Nº Proyecto", Rec."Nº Proyecto");

                    if rBorr.FINDFIRST THEN
                        REPEAT
                            i := i + 1;
                            if rBorr."No." = Rec."No." THEN cCartera.CrearDocCartera(rBorr, i, rBorr.Count);
                        UNTIL rBorr.NEXT = 0;
                    cCartera.RegistrarDocCartera;
                end;
            }
        }

    }
    var
        AvtVisible: Boolean;
        AvbVisible: Boolean;
        Avb2Visible: Boolean;
        SalesSetup: Record 311;
        ChangeExchangeRate: page 511;
        CopySalesDoc: Report 292;
        MoveNegSalesLines: Report 6699;
        ReportPrint: Codeunit 228;
        UserMgt: Codeunit 5700;
        SalesInfoPaneMgt: Codeunit 7171;
        rContr: Record 36;
        Avisos: Text;

        NotificationLifecycleMgt: Codeunit "Notification Lifecycle Mgt.";
        Notification: Notification;
        Text001: Label 'El albarán no está a 0';
        Text002: Label 'Ver albarán';
        TotalSalesLine: Record 37;
        TotalSalesLineLCY: Record 37;
        cust: Record Customer;
        DocumentType: enum "Gen. Journal Document Type";
        RegisVtas: Codeunit "Sales-Post";
        wDecimal: Decimal;
        wTexto: Text;
        ImpBorFac: Decimal;
        ImpBorAbo: Decimal;
        ImpFac: Decimal;
        ImpAbo: Decimal;
        TotImp: Decimal;
        TotCont: Decimal;


    trigger OnOpenPage()
    BEGIN
        if UserMgt.GetSalesFilter <> '' THEN BEGIN
            Rec.FILTERGROUP(2);
            Rec.SETRANGE("Responsibility Center", UserMgt.GetSalesFilter);
            Rec.FILTERGROUP(0);
        END;

        AplicarFiltros;                       //$001
    END;

    trigger OnAfterGetCurrRecord()
    begin
        If (ABS(TotalSalesLine.Amount) > 0)
                and (Abs(TotalSalesLineLCY.Amount) < 1) then begin
            sendDocumentNotification();
        end;
    end;

    procedure Albaran_Factura(): Text
    begin
        CalcularTotales(Rec."No.");              //FCL-17/05/04
                                                 // $002 -
        if ABS(TotalSalesLine.Amount) < 1 Then begin
            if not cust.Get(Rec."Sell-to Customer No.") then
                Cust.Init;
            if Cust."Generar facturas a 0" Then
                documentType := DocumentType::Invoice
            else
                DocumentType := DocumentType::Shipment;
        end else
            DocumentType := DocumentType::Invoice;

        exit(Format(DocumentType));
    end;

    PROCEDURE CalcularTotales(pNumDoc: Code[20]);
    VAR
        TempSalesLine: Record 37 TEMPORARY;
    BEGIN
        //FCL-04/05/04. Obtengo total y total iva incluído, ya no me sirve el campo calculado
        // porque estos importes están a cero en las líneas.
        // JML 150704 Modificado para poder filtrar por fase.
        // $001 por tarea

        CLEAR(TotalSalesLine);
        CLEAR(TotalSalesLineLCY);

        if pNumDoc <> '' THEN BEGIN
            CLEAR(RegisVtas);
            CLEAR(TempSalesLine);
            RegisVtas.GetSalesLines(Rec, TempSalesLine, 0);
            CLEAR(RegisVtas);

            RegisVtas.SumSalesLinesTemp(
              Rec, TempSalesLine, 0, TotalSalesLine, TotalSalesLineLCY,
              wDecimal, wTexto, wDecimal, wDecimal, wDecimal);

            //  JML 150704
            //  RegisVtas.SumSalesLinesTempFase(Rec,TempSalesLine,0,TotalSalesLine,
            //                              TotalSalesLineLCY, GETFILTER("Filtro fase"));

        END;
    END;




    PROCEDURE AplicarFiltros();
    VAR
        rUsuario: Record 91;
    BEGIN
        //$001
        if rUsuario.GET(USERID) THEN BEGIN
            if rUsuario."Filtro vendedor" <> '' THEN BEGIN
                Rec.FILTERGROUP(2);
                Rec.SETFILTER("Salesperson Code", rUsuario."Filtro vendedor");
                Rec.FILTERGROUP(0);
            END;
        END;
    END;

    PROCEDURE NC(): Text[250];
    VAR
        r270: Record 270;
        r289: Record 289;
    BEGIN
        AVBVISIBLE := FALSE;
        AVB2VISIBLE := FALSE;
        AVTVISIBLE := FALSE;
        Avisos := '';
        if NOT r289.GET(Rec."Payment Method Code") THEN BEGIN
            AVBVISIBLE := TRUE;
            AVB2VISIBLE := TRUE;
            AVTVISIBLE := TRUE;
            Avisos := Avisos + ' Especifique forma de pago';
        END ELSE BEGIN
            if (Rec."Nuestra Cuenta" = '') And (Rec."Nuestra Cuenta Prepago" <> '') Then Rec."Nuestra Cuenta" := Rec."Nuestra Cuenta Prepago";
            if r270.GET(Rec."Nuestra Cuenta") THEN BEGIN
                if r270.IBAN <> '' Then exit(r270.IBAN);
                EXIT(r270."CCC Bank No." + '-' + r270."CCC Bank Branch No." + '-' + r270."CCC Control Digits" +
                '-' + r270."CCC Bank Account No.");
            END ELSE BEGIN
                if r289."Bill Type" = r289."Bill Type"::Transfer THEN BEGIN
                    AVBVISIBLE := TRUE;
                    AVTVISIBLE := TRUE;
                    AVB2VISIBLE := TRUE;
                    Avisos := Avisos + ' Especifique Nº de banco para la transferencia en la pestaña de facturación' +
                    ' en el campo Nuestra cuenta transferencia';

                END;
            END;
        END;
    END;

    PROCEDURE RecuperaDimensionesContrato(VAR rFac: Record 36);
    VAR
        r37: Record 37;
        r37L: Record 37;
        ShorCutDim: ARRAY[8] OF Code[10];
    BEGIN
        r37.SETRANGE(r37."Document Type", rFac."Document Type");
        r37.SETRANGE(r37."Document No.", rFac."No.");
        if r37.FINDFIRST THEN
            REPEAT
                r37L.SETRANGE(r37L."Document Type", r37L."Document Type"::Order);
                r37L.SETRANGE(r37L."Document No.", rFac."Nº Contrato");
                r37L.SETRANGE(r37L."No.", r37."No.");
                if r37L.FINDFIRST THEN BEGIN
                    ShorCutDim[1] := r37L."Shortcut Dimension 1 Code";
                    ShorCutDim[2] := r37L."Shortcut Dimension 2 Code";
                    ShorCutDim[3] := r37L."Shortcut Dimension 3 Code";
                    ShorCutDim[4] := r37L."Shortcut Dimension 4 Code";
                    ShorCutDim[5] := r37L."Shortcut Dimension 5 Code";
                    r37L.ShowShortcutDimCode(ShorCutDim);
                    if r37."Shortcut Dimension 1 Code" = '' THEN
                        r37.VALIDATE(r37."Shortcut Dimension 1 Code", ShorCutDim[1]);
                    if r37."Shortcut Dimension 2 Code" = '' THEN
                        r37.VALIDATE(r37."Shortcut Dimension 2 Code", ShorCutDim[2]);
                    if r37."Shortcut Dimension 3 Code" = '' THEN
                        r37.VALIDATE(r37."Shortcut Dimension 3 Code", ShorCutDim[3]);
                    if r37."Shortcut Dimension 4 Code" = '' THEN
                        r37.VALIDATE(r37."Shortcut Dimension 4 Code", ShorCutDim[4]);
                    if r37."Shortcut Dimension 5 Code" = '' THEN
                        r37.VALIDATE(r37."Shortcut Dimension 5 Code", ShorCutDim[5]);
                    r37.MODIFY;
                END;
            UNTIL r37.NEXT = 0;
    END;

    procedure sendDocumentNotification()
    begin
        // Mostrar notificación si hay proyecto asociado

        Notification.Id := CreateGuid();
        Notification.Message := Text001;
        Notification.Scope := NotificationScope::LocalScope;
        Notification.AddAction(Text002, Codeunit::ControldeEventos, 'OpenDocumentCard');
        Notification.SetData('DocumentNo', Rec."No.");
        NotificationLifecycleMgt.SendNotification(Notification, Rec.RecordId);

    end;

}
