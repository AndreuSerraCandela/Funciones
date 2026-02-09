/// <summary>
/// Page Contratos Activities (ID 50000).
/// </summary>
Page 50000 "Contratos Activities"
{
    PageType = CardPart;
    Caption = 'Contratos';
    RefreshOnActivate = true;
    SourceTable = "Sales Cue";
    Permissions = tabledata "Sales Cue" = rm;
    layout
    {
        area(Content)
        {

            cuegroup("Para Facturar")
            {
                Caption = 'Para Facturar';
                field("Facturación No Iniciada"; Rec."Sin Facturar")
                {
                    Caption = 'Facturación No Iniciada';
                    ApplicationArea = Basic, Suite;
                    DrillDownPageID = "Lista contratos venta";
                    ToolTip = 'Specifies the number of sales quotes that are not yet converted to invoices or orders.';
                }
                field("Facturación Iniciada"; ContratosPendientes)
                {
                    Caption = 'Facturación Iniciada';
                    ApplicationArea = Basic, Suite;
                    DrillDownPageID = "Sales Order List";
                    ToolTip = 'Specifies the number of sales orders that are not fully posted.';
                    trigger OnDrillDown()
                    var
                        Contratos: Record "Sales Header";
                        UserSetup: Record "User Setup";
                    begin

                        Contratos.SETRANGE("Document Type", Contratos."Document Type"::Order);
                        Rec.CopyFilter("Date Filter", Contratos."Posting Date");
                        Contratos.SetRange(Estado, Contratos."Estado"::"Sin Montar", Contratos."Estado"::Firmado);
                        Contratos.SetRange("Facturacion Iniciada", true);
                        Contratos.SetFilter("Borradores de Factura", '<>%1', 0);
                        if UserSetup.Get("UserID") Then begin
                            Contratos.FilterGroup(2);
                            Contratos.SetRange("Salesperson Code", UserSetup."Salespers./Purch. Code");
                            Contratos.FilterGroup(0);
                        end;
                        Contratos.CALCFIELDS("borradores de factura");
                        Page.RunModal(Page::"Lista contratos venta", Contratos);
                    end;
                }
                field(Descuadre; ProcedureDescuadre())
                {
                    Caption = 'Descuadre';
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'especifica el descuadre de la facturación';
                    trigger OnDrillDown()

                    var
                        Contratos: Record "Sales Header";
                        Contratost: Record "Sales Header" temporary;
                        Facturas: Record "Sales Invoice Header";
                        Descuadre: Decimal;
                        Dif: Decimal;
                        Conador: Integer;
                    begin
                        Descuadre := 0;
                        Contratos.SetRange("Document Type", Contratos."Document Type"::Order);
                        Contratos.SetRange(Estado, Contratos."Estado"::"Sin Montar", Contratos."Estado"::Firmado);
                        Contratos.SetRange("Facturacion Iniciada", true);
                        Contratos.Setrange("Fecha Estado", CalcDate('PM+1D-3M', Today), CalcDate('PM', Today));
                        if Contratos.FindSet() then
                            repeat
                                TotalesDocumentos(Contratos, Dif);

                                If Abs(Dif) > 4 Then begin
                                    Contratost := Contratos;
                                    Contratost.Insert();
                                end;
                            until Contratos.Next() = 0;
                        Commit();
                        Page.RunModal(Page::"Lista contratos venta", Contratost);
                    end;

                }


            }
            cuegroup("Contratos en Curso")
            {
                Caption = 'Contratos en Curso';

                field("Contratos Firmados"; Rec."Contratos Firmados")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Contratos Filrmados';
                    DrillDownPageID = "Lista contratos venta";
                    ToolTip = 'especifica el numero de contratos firmados';
                    trigger OnDrillDown()
                    begin
                        Rec.ShowContratos(Rec.FieldNo("Contratos Firmados"));
                    end;

                }
                // lo mismo para los otros estados
                field("Penientes de Firma"; Rec."Contratos Pendientes Firma")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Pendientes de Firma';
                    DrillDownPageID = "Lista contratos venta";
                    ToolTip = 'especifica el numero de contratos pendientes de firma';
                    trigger OnDrillDown()
                    begin
                        Rec.ShowContratos(Rec.FieldNo("Contratos Pendientes Firma"));

                    end;
                }
                field("Contratos Sin Montar"; Rec."Contratos Sin Montar")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Contratos Sin Montar';
                    DrillDownPageID = "Lista contratos venta";
                    ToolTip = 'especifica el numero de contratos sin montar';
                    trigger OnDrillDown()
                    begin
                        Rec.ShowContratos(Rec.FieldNo("Contratos Sin Montar"));
                    end;
                }
                field("Contratos Cancelados"; Rec."Contratos Cancelados")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Contratos Cancelados';
                    DrillDownPageID = "Lista contratos venta";
                    ToolTip = 'especifica el numero de contratos cancelados';
                    trigger OnDrillDown()
                    begin
                        Rec.ShowContratos(Rec.FieldNo("Contratos Cancelados"));
                    end;


                }
                field("Contratos Anulados"; Rec."Contratos Anulados")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Contratos Anulados';
                    DrillDownPageID = "Lista contratos venta";
                    ToolTip = 'especifica el numero de contratos anulados';
                    trigger OnDrillDown()
                    begin
                        Rec.ShowContratos(Rec.FieldNo("Contratos Anulados"));
                    end;

                }
                field("Contratos Modificados"; Rec."Contratos Modificados")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Contratos Modificados';
                    DrillDownPageID = "Lista contratos venta";
                    ToolTip = 'especifica el numero de contratos modificados';
                    trigger OnDrillDown()
                    begin
                        Rec.ShowContratos(Rec.FieldNo("Contratos Modificados"));
                    end;

                }

            }
            cuegroup("Para Firmar")
            {
                Caption = 'Contratos Porta firmas';
                Visible = ActivadoPortafirmas;
                field("Enviados a gerencia"; Rec.Pending)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Enviados a gerencia';
                    DrillDownPageID = "Lista contratos venta";
                    ToolTip = 'especifica el numero de contratos enviados a gerencia';
                    trigger OnDrillDown()
                    begin
                        Rec.ShowContratos(Rec.FieldNo(Pending));
                    end;

                }
                // lo mismo para los otros estados
                field("Firmado Malla"; Rec."Own Signed")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Firmado Malla';
                    DrillDownPageID = "Lista contratos venta";
                    ToolTip = 'especifica el numero de contratos firmados por Malla';
                    trigger OnDrillDown()
                    begin
                        Rec.ShowContratos(Rec.FieldNo("Own Signed"));
                    end;
                }

                field("Rechazado Malla"; Rec."Own Rejected")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Rechazado Malla';
                    DrillDownPageID = "Lista contratos venta";
                    ToolTip = 'especifica el numero de contratos rechazados por Malla';
                    trigger OnDrillDown()
                    begin
                        Rec.ShowContratos(Rec.FieldNo("Own Rejected"));
                    end;
                }

                field("Firmado Contrato"; Rec."Customer Signed")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Firmado Contrato';
                    DrillDownPageID = "Lista contratos venta";
                    ToolTip = 'especifica el numero de contratos firmados por el cliente';
                    trigger OnDrillDown()
                    begin
                        Rec.ShowContratos(Rec.FieldNo("Customer Signed"));
                    end;
                }

                field("Rechazado Cliente"; Rec."Customer Rejected")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Rechazado Cliente';
                    DrillDownPageID = "Lista contratos venta";
                    ToolTip = 'especifica el numero de contratos rechazados por el cliente';
                    trigger OnDrillDown()
                    begin
                        Rec.ShowContratos(Rec.FieldNo("Customer Rejected"));
                    end;
                }
                field("Sepa Pendiente"; Rec."Sepa Pending")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Firmado Malla y enviado Sepa';
                    DrillDownPageID = "Lista contratos venta";
                    ToolTip = 'especifica el numero de contratos con Sepa Pendiente';
                    trigger OnDrillDown()
                    begin
                        Rec.ShowContratos(Rec.FieldNo("Sepa Pending"));
                    end;

                }

                field("Firmado Sepa"; Rec."Sepa Signed")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Firmado Sepa';
                    DrillDownPageID = "Lista contratos venta";
                    ToolTip = 'especifica el numero de contratos Sepa firmados por el cliente';
                    trigger OnDrillDown()
                    begin
                        Rec.ShowContratos(Rec.FieldNo("Sepa Signed"));
                    end;
                }

                //Rechazado Sepa
                field("Rechazado Sepa"; Rec."Sepa Rejected")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Rechazado Sepa';
                    DrillDownPageID = "Lista contratos venta";
                    ToolTip = 'especifica el numero de contratos rechazados por el cliente';
                    trigger OnDrillDown()
                    begin
                        Rec.ShowContratos(Rec.FieldNo("Sepa Rejected"));
                    end;
                }
                field("Firmado Contrato y Sepa Pendiente"; Rec."Sepa Pending & Contrat Signed")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Firmado Contrato y Sepa Pendiente';
                    DrillDownPageID = "Lista contratos venta";
                    ToolTip = 'especifica el numero de contratos firmados por el cliente con Sepa Pendiente';
                    trigger OnDrillDown()
                    begin
                        Rec.ShowContratos(Rec.FieldNo("sepa pending & contrat signed"));
                    end;
                }

                field("Firmado Sepa y Contrato"; Rec."Sepa & Contract Signed")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Firmado Sepa y Contrato';
                    DrillDownPageID = "Lista contratos venta";
                    ToolTip = 'especifica el numero de contratos firmados por el cliente';
                    trigger OnDrillDown()
                    begin
                        Rec.ShowContratos(Rec.FieldNo("sepa & contract signed"));
                    end;
                }

                //Sepa Pending & Contract Signed


                //Sepa Pending

            }
            // cuegroup("Pedientes Contabilizar")
            // {
            //     Caption = 'Pedientes Contabilizar';
            //     field("Facturas Pendientes"; Rec."Facturas Pendientes")
            //     {
            //         ApplicationArea = All;
            //         DrillDownPageID = "Sales Invoice List";
            //         ToolTip = 'especifica el numero de facturas pendientes de contabilizar';
            //     }
            //     // lo mismo para los abonos
            //     field("Abonos Pendientes"; Rec."Abonos Pendientes")
            //     {
            //         ApplicationArea = All;
            //         DrillDownPageID = "Sales Credit Memos";
            //         ToolTip = 'especifica el numero de abonos pendientes de contabilizar';
            //     }


        }

    }

    var
        ContratosPendientes: Integer;

        Control: Codeunit ControlProcesos;
        ActivadoPortafirmas: Boolean;

    trigger OnOpenPage()
    var
        UserSetup: Record "User Setup";
        CompanyInf: Record "Company Information";
        Contratos: Record "Sales Header";
    begin

        Rec.SetRange("Date Filter", CalcDate('PA+1D-1A-3M', Today), CalcDate('PA+3M', Today));
        If UserSetup.Get("UserID") Then
            If UserSetup."Salespers./Purch. Code" <> '' Then
                Rec.SetRange("Salesperson filter", UserSetup."Salespers./Purch. Code");
        rec.FilterOrders(Contratos, 0);
        Rec.CalcFields(Pending, "Own Signed", "Own Rejected", "Customer Signed", "Customer Rejected", "Sepa Pending", "Sepa Signed", "Sepa Rejected", "Sepa Pending & Contrat Signed", "Sepa & Contract Signed");

        CompanyInf.Get();
        If CompanyInf."Servidor Alfresco" <> '' then ActivadoPortafirmas := true else ActivadoPortafirmas := false;
        Contratos.SETRANGE("Document Type", Contratos."Document Type"::Order);
        Rec.CopyFilter("Date Filter", Contratos."Posting Date");
        Contratos.SetRange(Estado, Contratos."Estado"::"Sin Montar", Contratos."Estado"::Firmado);
        Contratos.SetRange("Facturacion Iniciada", true);
        Contratos.SetFilter("Borradores de Factura", '<>%1', 0);
        Contratos.CALCFIELDS("borradores de factura");
        if Contratos.FindFirst() Then
            ContratosPendientes := Contratos.Count;
    end;

    trigger OnAfterGetRecord()
    var
        Contratos: Record "Sales Header";
    begin
        Contratos.SETRANGE("Document Type", Contratos."Document Type"::Order);
        Rec.CopyFilter("Date Filter", Contratos."Posting Date");
        rec.FilterOrders(Contratos, 0);
        Contratos.SetRange(Estado, Contratos."Estado"::"Sin Montar", Contratos."Estado"::Firmado);
        Contratos.SetRange("Facturacion Iniciada", true);
        Contratos.SetFilter("Borradores de Factura", '<>%1', 0);
        Contratos.CALCFIELDS("borradores de factura");
        if Contratos.FindFirst() Then
            ContratosPendientes := Contratos.Count;

    end;

    local procedure ProcedureDescuadre(): Integer
    var
        Contratos: Record "Sales Header";
        Facturas: Record "Sales Invoice Header";
        Dif: Decimal;
        Contador: Integer;
    begin
        exit(0);
        Contratos.SetRange("Document Type", Contratos."Document Type"::Order);
        Contratos.SetRange(Estado, Contratos."Estado"::"Sin Montar", Contratos."Estado"::Firmado);
        Contratos.SetRange("Facturacion Iniciada", true);
        Contratos.Setrange("Fecha Estado", CalcDate('PM+1D-3M', Today), CalcDate('PM', Today));
        if Contratos.FindSet() then
            repeat
                TotalesDocumentos(Contratos, Dif);
                If aBS(Dif) > 4 Then Contador += 1;
            until Contratos.Next() = 0;
    end;

    PROCEDURE TotalesDocumentos(Contrato: Record "Sales Header"; VAR Diferencia: Decimal);
    VAR
        TempSalesLine: Record 37 TEMPORARY;
        rCabVenta: Record 36;
        impBorFac: Decimal;
        impBorAbo: Decimal;
        impFac: Decimal;
        impAbo: Decimal;
        TotalSalesLine: Record "Sales Line";
        TotalSalesLineLCY: Record "Sales Line";
        rCabFac: Record "Sales Invoice Header";
        rCabAbo: Record "Sales Cr.Memo Header";
        RegisVtas: Codeunit "Sales-Post";
        wDecimal: Decimal;
        TotImp: Decimal;
        TotCont: Decimal;
        wTexto: Text[250];
    BEGIN
        //$002 Obtengo totales de borradores y facturas correspondientes a este contrato.

        ImpBorFac := 0;
        ImpBorAbo := 0;
        ImpFac := 0;
        ImpAbo := 0;
        TotImp := 0;
        TotCont := 0;

        //if ("Borradores de Factura" <> 0) OR ("Borradores de Abono" <> 0) THEN BEGIN


        rCabVenta.RESET;
        rCabVenta.SETCURRENTKEY("Nº Proyecto");
        rCabVenta.SETRANGE("Nº Proyecto", Contrato."Nº Proyecto");
        rCabVenta.SETRANGE("Nº Contrato", Contrato."No.");
        rCabVenta.SETFILTER("Document Type", '%1|%2',
           rCabVenta."Document Type"::Invoice, rCabVenta."Document Type"::"Credit Memo");
        if rCabVenta.FIND('-') THEN BEGIN
            REPEAT
                CLEAR(TotalSalesLine);
                CLEAR(TotalSalesLineLCY);
                CLEAR(RegisVtas);
                CLEAR(TempSalesLine);
                RegisVtas.GetSalesLines(rCabVenta, TempSalesLine, 0);
                CLEAR(RegisVtas);
                RegisVtas.SumSalesLinesTemp(
                  rCabVenta, TempSalesLine, 0, TotalSalesLine, TotalSalesLineLCY,
                  wDecimal, wTexto, wDecimal, wDecimal, wDecimal);
                if rCabVenta."Document Type" = rCabVenta."Document Type"::Invoice THEN BEGIN
                    ImpBorFac := ImpBorFac + TotalSalesLineLCY."Amount Including VAT";
                END
                ELSE BEGIN
                    ImpBorAbo := ImpBorAbo + TotalSalesLineLCY."Amount Including VAT";
                END;
            UNTIL rCabVenta.NEXT = 0;
        END;



        if Contrato."Facturas Registradas" <> 0 THEN BEGIN

            rCabFac.RESET;
            rCabFac.SETCURRENTKEY("Nº Proyecto", "Nº Contrato");
            rCabFac.SETRANGE("Nº Contrato", Contrato."No.");
            if rCabFac.FIND('-') THEN BEGIN
                REPEAT
                    rCabFac.CALCFIELDS("Amount Including VAT");
                    ImpFac := ImpFac + rCabFac."Amount Including VAT";
                UNTIL rCabFac.NEXT = 0;
            END;

        END;

        if Contrato."Abonos Registrados" <> 0 THEN BEGIN

            rCabAbo.RESET;
            rCabAbo.SETCURRENTKEY("Nº Proyecto", "Nº Contrato");
            rCabAbo.SETRANGE("Nº Contrato", Contrato."No.");
            if rCabAbo.FIND('-') THEN BEGIN
                REPEAT
                    rCabAbo.CALCFIELDS("Amount Including VAT");
                    ImpAbo := ImpAbo + rCabAbo."Amount Including VAT";
                UNTIL rCabAbo.NEXT = 0;
            END;

        END;

        //FCL-13/02/06. Incluyo sumatorio de totales y diferencia con el total del contrato.
        TotImp := ImpBorFac - ImpBorAbo + ImpFac - ImpAbo;

        if rCabVenta.GET(rCabVenta."Document Type"::Order, Contrato."No.") THEN BEGIN
            CLEAR(TotalSalesLine);
            CLEAR(TotalSalesLineLCY);
            CLEAR(RegisVtas);
            CLEAR(TempSalesLine);
            RegisVtas.GetSalesLines(rCabVenta, TempSalesLine, 0);
            CLEAR(RegisVtas);
            RegisVtas.SumSalesLinesTemp(rCabVenta, TempSalesLine, 0, TotalSalesLine, TotalSalesLineLCY,
                                        wDecimal, wTexto, wDecimal, wDecimal, wDecimal);
            TotCont := TotalSalesLineLCY."Amount Including VAT";
        END;
    END;



}
/// <summary>
/// Page Contratos Activities (ID 7001298).
/// </summary>
Page 50066 "Systemas Activities"
{
    PageType = CardPart;
    Caption = 'Sistemas';
    RefreshOnActivate = true;
    SourceTable = "Sales Cue";
    Permissions = tabledata "Sales Cue" = rm;
    layout
    {
        area(Content)
        {


            cuegroup("Control Extensiones")
            {

                Visible = MallaAdm;
                field("Extensiones Pendientes"; GExtensionesPendientes())
                {
                    ApplicationArea = All;
                    //DrillDownPageID = "Extension Management";
                    StyleExpr = Extensiones;
                    ToolTip = 'especifica el numero de extensiones pendientes de instalar';
                    trigger OnDrillDown()
                    var
                    begin
                        Message(ExtensionesMensage());
                        Page.RunModal(Page::"Extension Management");
                    end;
                }
            }
            cuegroup("Cola Trabajos")
            {
                Visible = MallaAdm;
                field("Errores"; ErroresCola())
                {
                    ApplicationArea = All;
                    DrillDownPageID = "job queue entries";
                    StyleExpr = Errores;
                    ToolTip = 'especifica el numero de colas con errores';
                    trigger OnDrillDown()
                    begin
                        Message(ErroresMensage());
                        Page.RunModal(Page::"Job Queue Entries");
                    end;
                }
            }
        }
    }
    var
        ContratosPendientes: Integer;

        Extensiones: Text;
        Errores: Text;
        Control: Codeunit ControlProcesos;
        MallaAdm: Boolean;

    trigger OnOpenPage()
    var
        Utilidades: Codeunit Utilitis;
    begin
        Rec.SetRange("Date Filter", CalcDate('PA+1D-1A-3M', Today), CalcDate('PA+3M', Today));
        MallaAdm := Utilidades.PermisoAdm();
    end;

    trigger OnAfterGetRecord()
    begin

        ExtensionesMensage();
        ErroresMensage();
    end;

    [Scope('OnPrem')]
    procedure ExtensionesPendientes(var faltan: integer; var noinstaladas: Integer)
    var
        EnumExtensiones: Enum "Id Extensiones Malla";
        ExtensionManagemet: Codeunit "Extension Management";//IsInstalledByAppId//GetAllExtensionDeploymentStatusEntries//GetAppName
        Name: Text;
        PublishedApp: Record "NAV App Installed App";
        PublishedApp2: Record "NAV App Installed App";
    begin
        foreach Name in EnumExtensiones.Names do begin
            PublishedApp.SetRange("App Id", Name);
            if Not PublishedApp.FindFirst() Then
                faltan += 1
            else
                if not ExtensionManagemet.IsInstalledByAppId(PublishedApp."App ID") then begin
                    NoInstaladas += 1;

                end;
        end;
        if faltan <> 0 Then Extensiones := 'Unfavorable' else Extensiones := 'Favorable';
        if (faltan = 0) and (NoInstaladas <> 0) Then Extensiones := 'Attention';
        //exit(faltan);
    end;

    [Scope('OnPrem')]
    local procedure ExtensionesMensage(): Text
    var
        EnumExtensiones: Enum "Extensiones Malla";
        EnumIdExtensiones: Enum "Id Extensiones Malla";
        IdExtensiones: text;
        Name: Text;
        Textofaltan: Text;
        faltan: Integer;
        NoInstaladas: Integer;
        ExtensionManagemet: Codeunit "Extension Management";//IsInstalledByAppId//GetAllExtensionDeploymentStatusEntries//GetAppName
        PublishedApp: Record "NAV App Installed App";
        a: Integer;
        G: Guid;
    // PublishedApp2: Record "NAV App Installed App";
    begin

        // foreach Name in EnumIdExtensiones.Names do begin
        //     ExtensionManagemet.IsInstalledByAppId(Name);
        // end;
        ExtensionesPendientes(faltan, NoInstaladas);
        If (faltan = 0) and (NoInstaladas = 0) Then Exit('Todas las extensiones están instaladas');
        Textofaltan := 'Las siguientes extensiones no están instaladas: \';
        foreach Name in EnumExtensiones.Names do begin
            PublishedApp.SetRange(Name, Name);
            if Not PublishedApp.FindFirst() Then PublishedApp.Init();
            a := EnumExtensiones.Names.IndexOf(Name);

            EnumIdExtensiones.Names.Get(a, IdExtensiones);
            If G = ExtensionManagemet.GetLatestVersionPackageIdByAppId(IdExtensiones) Then
                //if Not PublishedApp.FindFirst() Then
                Textofaltan += Name + '\'
            else begin
                if not ExtensionManagemet.IsInstalledByAppId(PublishedApp."App ID") then Textofaltan += 'No instalada: ' + Name + '\';
            end;

        end;
        exit(textofaltan);
    end;

    local procedure ErroresCola(): Integer
    var
        Emppresa: Record "Company";
        JobQue: Record "Job Queue Entry";
        faltan: Integer;
        Ojo: Integer;
    begin
        If Emppresa.FindFirst() Then
            repeat
                if Control.Permiso_Empresas(Emppresa.Name) then begin
                    JobQue.ChangeCompany(Emppresa."Name");
                    JobQue.SetFilter("Status", '%1|%2', JobQue."Status"::Error, JobQue."Status"::Waiting);
                    if JobQue.FindFirst() Then
                        repeat
                            if JobQue."Object ID to Run" <> 1441 then
                                faltan += 1 else
                                Ojo += 1;
                        until jobQue.Next() = 0;
                end;
            Until Emppresa.Next() = 0;
        If Emppresa.FindFirst() Then
            repeat
                if Control.Permiso_Empresas(Emppresa.Name) then begin
                    JobQue.ChangeCompany(Emppresa."Name");
                    JobQue.SetRange("Status", JobQue."Status"::Ready);
                    JobQue.SetFilter("Earliest Start Date/Time", '<%1', CurrentDateTime);
                    if JobQue.FindFirst() Then
                        repeat
                            if JobQue."Object ID to Run" <> 1441 then
                                faltan += 1;
                        until jobQue.Next() = 0;
                end;
            Until Emppresa.Next() = 0;
        if faltan <> 0 Then Errores := 'Unfavorable' else Errores := 'Favorable';
        If (faltan = 0) And (Ojo <> 0) Then Errores := 'Attention';

        exit(faltan);
    end;

    local procedure ErroresMensage(): Text
    var
        faltan: Text;
        Emppresa: Record "Company";
        JobQue: Record "Job Queue Entry";
    begin
        if ErroresCola() = 0 Then Exit('No hay errores en la cola');
        faltan := 'Las siguientes colas están en estado de error: \';
        If Emppresa.FindFirst() Then
            repeat
                if Control.Permiso_Empresas(Emppresa.Name) then begin
                    JobQue.ChangeCompany(Emppresa."Name");
                    JobQue.SetFilter("Status", '%1|%2', JobQue."Status"::Error, JobQue."Status"::Waiting);
                    if JobQue.FindFirst() Then
                        repeat
                            JobQue.CalcFields("Object Caption to Run");
                            if JobQue."Object ID to Run" <> 1441 then begin
                                If JobQue.Status = JobQue."Status"::Error then
                                    faltan += Emppresa."Name" + ': ' + JobQue."Object Caption to Run" + '\' else
                                    faltan += Emppresa."Name" + ': ' + JobQue."Object Caption to Run" + ' (En espera)' + '\';
                            end;

                        until jobQue.Next() = 0;
                end;
            Until Emppresa.Next() = 0;
        If Emppresa.FindFirst() Then
            repeat
                if Control.Permiso_Empresas(Emppresa.Name) then begin
                    JobQue.ChangeCompany(Emppresa."Name");
                    JobQue.SetRange("Status", JobQue."Status"::Ready);
                    JobQue.SetFilter("Earliest Start Date/Time", '<%1', CurrentDateTime);
                    if JobQue.FindFirst() Then
                        repeat
                            JobQue.CalcFields("Object Caption to Run");
                            if JobQue."Object ID to Run" <> 1441 then begin
                                faltan += Emppresa."Name" + ': ' + JobQue."Object Caption to Run" + ' (hora vencida)' + '\';
                            end;

                        until jobQue.Next() = 0;
                end;
            Until Emppresa.Next() = 0;
        exit(faltan);
    end;

    local procedure GExtensionesPendientes(): Integer
    var
        faltan: Integer;
        NoInstaladas: Integer;
    begin
        ExtensionesPendientes(faltan, NoInstaladas);
        exit(faltan + NoInstaladas);
    end;

}