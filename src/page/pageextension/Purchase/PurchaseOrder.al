/// <summary>
/// PageExtension PedidoCompraKuara (ID 80114) extends Record Purchase Order.
/// </summary>
pageextension 80114 "PedidoCompraKuara" extends "Purchase Order"
{
    layout
    {
        addafter("Quote No.")
        {

            field("Nº Proyecto"; Rec."Nº Proyecto") { ApplicationArea = All; }
            field("Factura recibida"; Rec."Factura recibida") { ApplicationArea = All; }
#if not CLEAN27
            field("Buy-from Vendor Name 2"; Rec."Buy-from Vendor Name 2") { ApplicationArea = All; }
#endif
            field("Nº Contrato Venta"; Rec."Nº Contrato Venta") { ApplicationArea = All; }
            field("Descripcion proyecto"; Rec."Descripcion proyecto")
            {
                ApplicationArea = All;
                Caption = 'Descripción Proyecto';
            }
            field("Observaciones"; Rec."Descripción operación") { ApplicationArea = All; }
            field(TraeFechaProyI; TraeFechaProy('I'))
            {
                ApplicationArea = All;
                Caption = 'Fecha Inicial';
            }
            field(TraeFechaProyF; TraeFechaProy('F'))
            {
                ApplicationArea = All;

                Caption = 'Fecha final';
            }


            field(TraeFechaProy1; TraeFechaProy('1')) { ApplicationArea = All; Caption = 'Fecha 1ª Factura'; }
            field("Forzar Traspaso"; Rec."Forzar Traspaso")
            {
                ApplicationArea = All;
                trigger OnValidate()
                BEGIN
                    MESSAGE('Cuando se genera un pedido adicional a un proyecto inter-empreas,\'
                    + 'el pedido no se traspasa. Pulsando este botón, forzamos el traspaso\'
                    + 'y, por tanto, llegará a la otra empresa como factura.\' +
                    'Si pulsa este botón cuando no corresponde, duplicará la factura');
                END;
            }
            field(Alba; Alba) { ApplicationArea = All; Visible = AlbaranesVISIBLE; }
            group(Renovación)
            {
                field("Renovacion en:"; Rec."Renovacion en:")
                {
                    ApplicationArea = All;
                    ToolTip = 'Introduzca la fórmula para calcular la renovación. Por ejemplo, 1 Año=1A 3 meses=3M';
                }
                field("Fecha Prevista Renovación"; Rec."Fecha Prevista Renovación")
                {
                    ApplicationArea = All;
                }
                field("Pedido Original"; Rec."Pedido Original")
                {
                    ApplicationArea = All;
                }

            }
        }
        addafter("Vendor Bank Acc. Code")
        {
            field(Banco; Rec.Banco) { ApplicationArea = All; }
            field("Genera Prev. de pagos"; Rec."Genera Prev. de pagos") { ApplicationArea = All; }

            field("Tipo factura SII"; Rec."Tipo factura SII") { ApplicationArea = All; }
        }
        addafter(Prepayment)
        {
            group(Proyecto)
            {
                field("NProyecto"; Rec."Nº Proyecto") { ApplicationArea = All; }
                field(TraeNombreProyecto; TraeNombreProyecto(Rec."Nº Proyecto")) { ApplicationArea = All; Caption = 'Descripción Proyecto'; }
                field("Contrato Venta"; Rec."Nº Contrato Venta") { ApplicationArea = All; }
                field("Nombre Cliente Venta"; Rec."Nombre Cliente Venta") { ApplicationArea = All; }
                field("Nombre 2 Cliente Venta"; Rec."Nombre 2 Cliente Venta") { ApplicationArea = All; }
            }
        }
        modify("Order Date")
        {
            Visible = True;
            ApplicationArea = All;
            Importance = Promoted;
        }
        modify("VAT Reporting Date")
        {
            Visible = false;
        }
        modify("Document Date")
        {
            Importance = Additional;
        }
        modify("Due Date")
        {
            Visible = false;
        }


        // addfirst(FactBoxes)
        // {
        //     part(PDFViewer; "PDF Viewer Part")
        //     {
        //         Caption = 'PDF Viewer';
        //         ApplicationArea = All;
        //     }
        // }
    }
    actions
    {
        modify("Post &Batch")
        {
            Visible = false;
        }


        addafter(CopyDocument)
        {
            action(RenoveDocument)
            {
                ApplicationArea = Suite;
                Caption = 'Renovar Documento';
                Ellipsis = true;
                Enabled = Rec."No." <> '';
                Image = RemoveContacts;
                ToolTip = 'Copy document lines and header information from another purchase document to this document. You can copy a posted purchase invoice into a new purchase invoice to quickly create a similar document.';

                trigger OnAction()
                var
                    FromDocNo: Code[20];
                    Control: Codeunit "ControlProcesos";
                begin
                    FromDocNo := Control.RenoveDocument(Rec);
                    if Rec.Get(Rec."Document Type", Rec."No.") then;
                    Rec."Pedido Original" := FromDocNo;
                    Rec.Modify();
                    Commit();
                    if Rec.Get(Rec."Document Type", Rec."No.") then;
                    CurrPage.PurchLines.Page.ForceTotalsCalculation();
                    CurrPage.Update();
                end;
            }
        }
        addfirst(Print)
        {
            action("Guardar e Imprimir")
            {
                ApplicationArea = All;
                Image = Save;
                Caption = 'Guardar e Imprimir';
                trigger OnAction()
                VAR
                    cArchi: Codeunit Utilitis;
                    RArchi: Record 5109;
                BEGIN
                    cArchi.ArchivePurchDocumentPer(Rec);
                    COMMIT;
                    RArchi.SETRANGE(RArchi."Document Type", RArchi."Document Type"::Order);
                    RArchi.SETRANGE(RArchi."No.", Rec."No.");
                    if RArchi.FINDLAST THEN BEGIN
                        RArchi.SETRANGE(RArchi."Version No.", RArchi."Version No.");
                        Page.RUNMODAL(5167, RArchi);
                        COMMIT;
                        if NOT CONFIRM('Es Correcta esta Versión del pedido ?', FALSE) THEN
                            RArchi.DELETE(TRUE)
                        ELSE
                            REPORT.RUNMODAL(Report::"Archived Purchase Order", TRUE, TRUE, RArchi);
                    END;
                END;
            }
            action("&Imprimir")
            {
                ApplicationArea = All;
                Image = PrintDocument;
                Caption = '&Imprimir';
                trigger OnAction()
                BEGIN
                    // $001
                    rConf.GET();
                    if rConf."Impr. Ped. Compra asociado Cto" THEN BEGIN
                        rCabV.RESET;
                        CLEAR(rCabV);
                        rCabV.SETCURRENTKEY("Nº Proyecto");
                        rCabV.SETRANGE("Nº Proyecto", Rec."Nº Proyecto");
                        rCabV.SETRANGE("Document Type", rCabV."Document Type"::Order);
                        if rCabV.FINDSET THEN
                            if (rCabV.Estado <> rCabV.Estado::Firmado) THEN
                                ERROR(Text003, rCabV."No.");
                    END;
                    rCab2.SETRANGE("No.", Rec."No.");
                    Commit;
                    REPORT.RUNMODAL(REPORT::Order, TRUE, FALSE, rCab2);
                END;
            }
            action("Imprimir pedidos &periodicos")
            {
                ApplicationArea = All;
                Image = PrintChecklistReport;
                Caption = 'Imprimir pedidos &periodicos';
                trigger OnAction()
                BEGIN
                    // $001
                    rConf.GET();
                    if rConf."Impr. Ped. Compra asociado Cto" THEN BEGIN
                        rCabV.RESET;
                        CLEAR(rCabV);
                        rCabV.SETCURRENTKEY("Nº Proyecto");
                        rCabV.SETRANGE("Nº Proyecto", Rec."Nº Proyecto");
                        rCabV.SETRANGE("Document Type", rCabV."Document Type"::Order);
                        if rCabV.FINDSET THEN
                            if (rCabV.Estado <> rCabV.Estado::Firmado) THEN
                                ERROR(Text003, rCabV."No.");
                    END;
                    rCab2.SETRANGE("No.", Rec."No.");
                    REPORT.RUNMODAL(Report::Order, TRUE, FALSE, rCab2);
                END;
            }
            action("Imprimir anti&guo (texto ampliado)")
            {
                ApplicationArea = All;
                Image = PrintCover;
                Caption = 'Imprimir anti&guo (texto ampliado)';
                trigger OnAction()
                BEGIN
                    rCab2.SETRANGE("No.", Rec."No.");
                    //Revisar REPORT.RUNMODAL(REPORT::"Pedido Old", TRUE, FALSE, rCab2);
                END;
            }

            action("Volver a Imprimir")
            {
                ApplicationArea = All;
                Image = PrintAttachment;
                Caption = 'Volver a Imprimir';
                trigger OnAction()
                VAR
                    cArchi: Codeunit 5063;
                    RArchi: Record 5109;
                BEGIN
                    RArchi.SETRANGE(RArchi."Document Type", RArchi."Document Type"::Order);
                    RArchi.SETRANGE(RArchi."No.", Rec."No.");
                    if Page.RUNMODAL(0, RArchi) = ACTION::LookupOK THEN BEGIN
                        RArchi.SETRANGE(RArchi."Version No.", RArchi."Version No.");
                        REPORT.RUNMODAL(7012810, TRUE, TRUE, RArchi);
                    END;
                END;
            }

        }
        addafter("F&unctions")
        {
            group("Acciones Pedido")
            {
                action("&Ver orden publicidad")
                {
                    ApplicationArea = All;
                    Image = OrderReminder;
                    Caption = '&Ver orden publicidad';
                    trigger OnAction()
                    BEGIN
                        CurrPage.PurchLines.Page.VerOrdenPub;
                    END;
                }
                action("&Navegar")
                {
                    ApplicationArea = All;
                    Image = Navigate;
                    trigger OnAction()
                    BEGIN
                        Rec.Navigate;
                    END;
                }
                action("Marcar Linea como recibida")
                {
                    ApplicationArea = All;
                    Caption = 'Marcar Linea como recibida';

                    trigger OnAction()
                    VAR

                        r39: Record 39;
                    BEGIN
                        CurrPage.PurchLines.Page.GETRECORD(r39);
                        ControldeProcesos.MarcarComoRecibida(r39);

                    END;
                }

                action("Anular Pedido")
                {
                    ApplicationArea = All;
                    Image = Undo;
                    Caption = 'Anular Pedido';
                    trigger OnAction()
                    BEGIN
                        Rec.VALIDATE(Status, Rec.Status::Canceled);
                        Rec.MODIFY;
                    END;
                }
                action("Arreglar Recurso")
                {
                    ApplicationArea = All;
                    Image = ReferenceData;
                    Caption = 'Arreglar Recurso';
                    trigger OnAction()
                    VAR
                        cGll: Codeunit "Gestion Reservas";
                    BEGIN
                        CLEAR(cGll);
                        cGll.PonerRecurso;
                    END;
                }
                action("Arreglar Proyecto")
                {
                    ApplicationArea = All;
                    Image = Job;
                    Caption = 'Arreglar Proyecto';
                    trigger OnAction()
                    VAR
                        cGll: Codeunit "Gestion Reservas";
                    BEGIN
                        CLEAR(cGll);
                        cGll.PonerProyecto;
                    END;
                }
                action("Asignar Pedido Cliente Interempresas")
                {
                    ApplicationArea = All;
                    Image = ICPartner;
                    Caption = 'Asignar Pedido Cliente Interempresas';
                    trigger OnAction()
                    begin
                        ControldeProcesos.AsignarPedidoInterEmpresas(Rec);
                    end;
                }
                action("Traer Facturas Empresa")
                {
                    ApplicationArea = All;
                    Image = "Invoicing-MDL-Attach";
                    Caption = 'Traer Facturas Empresa';
                    trigger OnAction()
                    begin
                        ControldeProcesos.TraerFacturasEmpresa(Rec);
                    end;
                }
                action("Cambiar Proveedor")
                {
                    ApplicationArea = All;
                    Image = VendorCode;
                    Caption = 'Cambiar Proveedor';
                    trigger OnAction()
                    begin
                        ControldeProcesos.CambiaProveedor(Rec);
                    end;
                }
                action("Recrear Proyecto")
                {
                    ApplicationArea = All;
                    Image = Job;
                    Visible = false;
                    Caption = 'Recrear Proyecto';
                    trigger OnAction()
                    begin
                        ControldeProcesos.RecrearProyecto(Rec);
                    end;
                }


            }
        }

        addfirst("O&rder")
        {
            action("&Texto ampliado línea")
            {
                ApplicationArea = All;
                Image = EndingText;
                ShortCutKey = F10;
                Caption = '&Texto ampliado línea';
                trigger OnAction()
                BEGIN
                    CurrPage.PurchLines.Page.LlamaTexto;
                END;

            }

        }

        modify(Approvals)
        {
            Visible = false;
        }
        modify(SendApprovalRequest)
        {
            Visible = false;
        }
        modify(CancelApprovalRequest)
        {
            Visible = false;
        }
        addafter(Dimensions_Promoted)
        {
            actionref(TextoAmpliado; "&Texto ampliado línea")
            { }
        }
        addafter(Reopen_Promoted)
        {
            actionref(Navegar_Promoted; "&Navegar")
            { }
        }

    }


    var
        myInt: Integer;
        rCab2: Record 38;
        PurchSetup: Record "Purchases & Payables Setup";
        rCabV: Record 36;
        rConf: Record 315;
        ChangeExchangeRate: Page 511;
        CopyPurchDoc: Report 492;
        MoveNegPurchLines: Report 6698;
        ApprovalMgt: Codeunit 439;
        ReportPrint: Codeunit 228;
        DocPrint: Codeunit 229;
        UserMgt: Codeunit 5700;
        ArchiveManagement: Codeunit 5063;
        ControldeProcesos: Codeunit ControlProcesos;
        Text001: Label 'No hay cantidades prepago registradas en %1 %2.';
        Text002: Label 'Existen facturas prepago sin abonar relacionadas con %1 %2. ¿Desea continuar?';
        PurchInfoPaneMgmt: Codeunit 7181;
        Text003: Label 'No puede imprimirse este Pedido de Compra ya que el Contrato %1 no esta en estado Firmado.';
        Borrar: Boolean;
        AlbaranesVISIBLE: Boolean;
    // OnTimer=BEGIN
    //           if Borrar THEN BEGIN
    //            BorrarAlbaranes;
    //            Borrar:=FALSE;
    //           END;
    //         END;

    PROCEDURE TraeNombreProyecto(numproy: Code[20]): Text[100];
    VAR
        rProy: Record 167;
    BEGIN
        if rProy.GET(numproy) THEN
            EXIT(rProy.Description);
    END;

    PROCEDURE TraeFechaProy(fi: Text[1]): Date;
    VAR
        r36: Record 36;
        r112: Record 112;
        Proy: Code[20];
    BEGIN
        Rec.Calcfields("Nº Contrato Venta");
        if r36.GET(r36."Document Type"::Order, Rec."Nº Contrato Venta") THEN BEGIN
            if fi = 'I' THEN EXIT(r36."Fecha inicial proyecto");
            if fi = 'F' THEN EXIT(r36."Fecha fin proyecto");
            if fi = '1' THEN BEGIN
                r36.Calcfields("Facturas Registradas", r36."Borradores de Factura");
                if r36."Facturas Registradas" > 0 THEN BEGIN
                    r112.SETCURRENTKEY("Nº Proyecto", "Nº Contrato");
                    r112.SETRANGE("Nº Contrato", Rec."Nº Contrato Venta");
                    if r112.FINDFIRST THEN EXIT(r112."Posting Date");
                END ELSE BEGIN
                    Proy := r36."Nº Proyecto";
                    r36.RESET;
                    r36.SETCURRENTKEY(r36."Nº Proyecto");
                    r36.SETRANGE(r36."Nº Proyecto", Proy);
                    if r36.FINDFIRST THEN EXIT(r36."Posting Date");
                END;
            END;
        END;
        EXIT(0D);
    END;

    PROCEDURE Alba(): Text;
    VAR
        r120: Record "Purch. Rcpt. Header";
    BEGIN
        r120.SETCURRENTKEY("Order No.");
        r120.SETRANGE("Order No.", Rec."No.");
        if r120.FINDFIRST THEN BEGIN
            //CurrPage.war.VISIBLE:=FALSE;
            AlbaranesVISIBLE := FALSE;
            EXIT('');
        END;
        //CurrPage.war.VISIBLE:=TRUE;
        AlbaranesVISIBLE := TRUE;
        EXIT('No se han generado los albaranes');
    END;


}
