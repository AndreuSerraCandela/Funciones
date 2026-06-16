page 50140 "Panel Medios"
{
    ApplicationArea = All;
    Caption = 'Panel Medios';
    PageType = CardPart;

    layout
    {
        area(content)
        {
            usercontrol(Dashboard; "Medios Dashboard AddIn")
            {
                ApplicationArea = All;

                trigger ControlReady()
                begin
                    DashboardReady := true;
                    SendDashboard();
                end;

                trigger ShowProyectos()
                begin
                    OpenJobs(false);
                end;

                trigger ShowContratos()
                begin
                    OpenContracts();
                end;

                trigger ShowProyPlanning()
                begin
                    OpenJobs(false, "Job Status"::Planning);
                end;

                trigger ShowProyQuote()
                begin
                    OpenJobs(false, "Job Status"::Quote);
                end;

                trigger ShowProyOpen()
                begin
                    OpenJobs(false, "Job Status"::Open);
                end;

                trigger ShowProyCompleted()
                begin
                    OpenJobs(false, "Job Status"::Completed);
                end;

                trigger ShowProyResSin()
                begin
                    OpenJobsByReservaCategoria(0);
                end;

                trigger ShowProyResCon()
                begin
                    OpenJobsByReservaCategoria(1);
                end;

                trigger ShowProyResOrden()
                begin
                    OpenJobsByReservaCategoria(2);
                end;

                trigger ShowFijacion()
                begin
                    OpenJobs(true);
                end;

                trigger ShowContSinMontar()
                begin
                    OpenContractsByEstado(SalesHeader.Estado::"Sin Montar");
                end;

                trigger ShowContPendFirma()
                begin
                    OpenContractsByEstado(SalesHeader.Estado::"Pendiente de Firma");
                end;

                trigger ShowContFirmado()
                begin
                    OpenContractsByEstado(SalesHeader.Estado::Firmado);
                end;

                trigger ShowContModificado()
                begin
                    OpenContractsByEstado(SalesHeader.Estado::Modificado);
                end;

                trigger ShowContPteRenovar()
                begin
                    OpenContractsPendientesRenovar();
                end;

                trigger ShowContCancelado()
                begin
                    OpenContractsByEstado(SalesHeader.Estado::Cancelado);
                end;

                trigger ShowContAnulado()
                begin
                    OpenContractsByEstado(SalesHeader.Estado::Anulado);
                end;

                trigger ShowFirmaPendiente()
                begin
                    OpenContractsPendientesSinEnviarGerencia();
                end;

                trigger ShowFirmaGerencia()
                begin
                    OpenContractsPortafirmas(SalesCue.FieldNo(Pending), 7001226);
                end;

                trigger ShowFirmaMalla()
                begin
                    OpenContractsPortafirmas(SalesCue.FieldNo("Own Signed"), 7001230);
                end;

                trigger ShowFirmaCliente()
                begin
                    OpenContractsPortafirmas(SalesCue.FieldNo("Customer Signed"), 7001230);
                end;

                trigger ShowFirmaRechMalla()
                begin
                    OpenContractsPortafirmas(SalesCue.FieldNo("Own Rejected"), 7001230);
                end;

                trigger ShowFirmaRechCliente()
                begin
                    OpenContractsPortafirmas(SalesCue.FieldNo("Customer Rejected"), 7001230);
                end;

                trigger DrillDown(Action: Text; Year: Integer)
                begin
                    HandleDashboardDrillDown(Action, Year);
                end;
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(FiltrosPanel)
            {
                ApplicationArea = All;
                Caption = 'Filtros';
                Image = Filter;
                ToolTip = 'Año, comercial y cliente del panel.';

                trigger OnAction()
                begin
                    OpenFiltersDialog();
                end;
            }
            //cLIENTES
            action(CustomerList)
            {
                ApplicationArea = All;
                Caption = 'Lista clientes';
                Image = Customer;
                ToolTip = 'Abre la lista de clientes con los filtros actuales.';

                trigger OnAction()
                begin
                    OpenCustomerList();
                end;
            }

            //PROYECTOS
            action(JobList)
            {
                ApplicationArea = All;
                Caption = 'Lista proyectos';
                Image = Job;
                ToolTip = 'Abre la lista de proyectos con los filtros actuales.';

                trigger OnAction()
                begin
                    OpenJobList();
                end;
            }

            //CONTRATOS
            action(OpenContractList)
            {
                ApplicationArea = All;
                Caption = 'Lista contratos';
                Image = Document;
                ToolTip = 'Abre la lista de contratos con los filtros actuales.';

                trigger OnAction()
                begin
                    OpenContracts();
                end;
            }
            action(OpenOrdenesFijacionList)
            {
                ApplicationArea = All;
                Caption = 'Órdenes fijación';
                Image = TaskList;
                ToolTip = 'Abre la lista de órdenes de fijación con los filtros actuales del panel.';

                trigger OnAction()
                begin
                    OpenOrdenesFijacion();
                end;
            }
            //Recuros
            action(OpenResourceList)
            {
                ApplicationArea = All;
                Caption = 'Lista recursos';
                Image = Resource;
                ToolTip = 'Abre la lista de recursos con los filtros actuales.';

                trigger OnAction()
                begin
                    OpenResources();
                end;
            }
            //Contactos
            action(OpenContactList)
            {
                ApplicationArea = All;
                Caption = 'Lista contactos';
                Image = ContactPerson;
                ToolTip = 'Abre la lista de contactos con los filtros actuales.';
                trigger OnAction()
                begin
                    OpenContacts();
                end;
            }

            // }
            // area(processing)
            // {
            action(RefreshDashboard)
            {
                ApplicationArea = All;
                Caption = 'Actualizar';
                Image = Refresh;
                ToolTip = 'Recalcula los indicadores del panel (sin facturación pesada).';

                trigger OnAction()
                begin
                    CalculateDashboard();
                    SendDashboard();
                end;
            }
            action(RecalcularFacturacion)
            {
                ApplicationArea = All;
                Caption = 'Recalcular facturación';
                Image = Calculate;
                ToolTip = 'Recalcula los quesitos de facturación (puede tardar). También se actualizan en la cola Fpr.';

                trigger OnAction()
                var
                    Fpr: Codeunit "Gestion Facturación";
                begin
                    Fpr.RefreshPanelMediosCache(FilterYear, FilterSalespersonCode, FilterCustomerNo);
                    CalculateDashboard();
                    SendDashboard();
                    Message('Facturación del panel actualizada.');
                end;
            }
            action(EncolarFacturacion)
            {
                ApplicationArea = All;
                Caption = 'Encolar facturación';
                Image = JobListSetup;
                ToolTip = 'Programa el cálculo de facturación en cola de proyectos (segundo plano).';

                trigger OnAction()
                var
                    Fpr: Codeunit "Gestion Facturación";
                begin
                    Fpr.EnqueuePanelMediosCacheRefresh(FilterYear, FilterSalespersonCode, FilterCustomerNo);
                    Message('Cálculo de facturación encolado. Actualice el panel cuando termine la cola.');
                end;
            }
            // action(OpenJobList)
            // {
            //     ApplicationArea = All;
            //     Caption = 'Lista proyectos';
            //     Image = Job;
            //     ToolTip = 'Abre la lista de proyectos con los filtros actuales.';

            //     trigger OnAction()
            //     begin
            //         OpenJobs(false);
            //     end;
            // }
            // action(OpenContractList)
            // {
            //     ApplicationArea = All;
            //     Caption = 'Lista contratos';
            //     Image = Document;
            //     ToolTip = 'Abre la lista de contratos con los filtros actuales.';

            //     trigger OnAction()
            //     begin
            //         OpenContracts();
            //     end;
            // }
        }
        // area(Promoted)
        // {
        //     actionref(OpenCustomerList_Promoted; OpenCustomerList)
        //     {
        //     }
        //     actionref(OpenJobList_Promoted; OpenJobList)
        //     {
        //     }
        //     actionref(OpenContractList_Promoted; OpenContractList)
        //     {
        //     }
        //     actionref(OpenOrdenesFijacionList_Promoted; OpenOrdenesFijacionList)
        //     {
        //     }
        //     actionref(OpenResourceList_Promoted; OpenResourceList)
        //     {
        //     }
        //     actionref(OpenContactList_Promoted; OpenContactList)
        //     {
        //     }
        // }
    }

    trigger OnOpenPage()
    begin
        if FilterYear = 0 then
            FilterYear := Date2DMY(WorkDate(), 3);
        CalculateDashboard();
    end;

    local procedure CalculateDashboard()
    var
        CompanyInfo: Record "Company Information";
    begin
        Clear(ProyPlanning);
        Clear(ProyQuote);
        Clear(ProyOpen);
        Clear(ProyCompleted);
        Clear(ProySinReserva);
        Clear(ProyConReserva);
        Clear(ProyConReservaOrden);
        Clear(FijTotal);
        Clear(ContSinMontar);
        Clear(ContPendFirma);
        Clear(ContFirmado);
        Clear(ContModificado);
        Clear(ContPteRenovar);
        Clear(ContCancelado);
        Clear(ContAnulado);
        Clear(ContSinMontarPrev);
        Clear(ContPendFirmaPrev);
        Clear(ContFirmadoPrev);
        Clear(ContModificadoPrev);
        Clear(ContPteRenovarPrev);
        Clear(ContCanceladoPrev);
        Clear(ContAnuladoPrev);
        Clear(FirmaPendienteEnvio);
        Clear(FirmaGerencia);
        Clear(FirmaMalla);
        Clear(FirmaCliente);
        Clear(FirmaRechMalla);
        Clear(FirmaRechCliente);

        ProyPlanning := CountJobs(false, "Job Status"::Planning);
        ProyQuote := CountJobs(false, "Job Status"::Quote);
        ProyOpen := CountJobs(false, "Job Status"::Open);
        ProyCompleted := CountJobs(false, "Job Status"::Completed);

        CalculateProyectosReservaCategorias();

        FijTotal := CountJobsFijacion();

        ContSinMontar := CountContractsByEstado(SalesHeader.Estado::"Sin Montar");
        ContPendFirma := CountContractsByEstado(SalesHeader.Estado::"Pendiente de Firma");
        ContFirmado := CountContractsByEstado(SalesHeader.Estado::Firmado);
        ContModificado := CountContractsByEstado(SalesHeader.Estado::Modificado);
        ContPteRenovar := CountContractsPendientesRenovar(FilterYear);
        ContCancelado := CountContractsByEstado(SalesHeader.Estado::Cancelado);
        ContAnulado := CountContractsByEstado(SalesHeader.Estado::Anulado);

        ContSinMontarPrev := CountContractsByEstado(SalesHeader.Estado::"Sin Montar", FilterYear - 1);
        ContPendFirmaPrev := CountContractsByEstado(SalesHeader.Estado::"Pendiente de Firma", FilterYear - 1);
        ContFirmadoPrev := CountContractsByEstado(SalesHeader.Estado::Firmado, FilterYear - 1);
        ContModificadoPrev := CountContractsByEstado(SalesHeader.Estado::Modificado, FilterYear - 1);
        ContPteRenovarPrev := CountContractsPendientesRenovar(FilterYear - 1);
        ContCanceladoPrev := CountContractsByEstado(SalesHeader.Estado::Cancelado, FilterYear - 1);
        ContAnuladoPrev := CountContractsByEstado(SalesHeader.Estado::Anulado, FilterYear - 1);

        ActivadoPortafirmas := false;
        if CompanyInfo.Get() then
            ActivadoPortafirmas := CompanyInfo."Servidor Alfresco" <> '';
        if ActivadoPortafirmas then begin
            FirmaPendienteEnvio := CountContractsPendientesSinEnviarGerencia();
            FirmaGerencia := CountContractsPortafirmas(SalesCue.FieldNo(Pending));
            FirmaMalla := CountContractsPortafirmas(SalesCue.FieldNo("Own Signed"));
            FirmaRechMalla := CountContractsPortafirmas(SalesCue.FieldNo("Own Rejected"));
            FirmaCliente := CountContractsPortafirmas(SalesCue.FieldNo("Customer Signed"));
            FirmaRechCliente := CountContractsPortafirmas(SalesCue.FieldNo("Customer Rejected"));
        end;

        CalculateFacturacionMetrics();
        BuildPeriodText();
        BuildDashboardPayload();
        SendDashboard();
    end;

    local procedure OpenFiltersDialog()
    var
        FiltrosDlg: Page "Panel Medios Filtros";
    begin
        FiltrosDlg.SetValues(FilterYear, FilterSalespersonCode, FilterCustomerNo);
        if FiltrosDlg.RunModal() = ACTION::OK then begin
            FiltrosDlg.GetValues(FilterYear, FilterSalespersonCode, FilterCustomerNo);
            CalculateDashboard();
            RequestFacturacionCacheRefresh();
            SendDashboard();
        end;
    end;

    local procedure OpenCustomerList()
    var
        Customer: Record Customer;
    begin
        If FilterSalespersonCode <> '' then
            Customer.SetRange("Salesperson Code", FilterSalespersonCode);
        If FilterCustomerNo <> '' then
            Customer.SetRange("No.", FilterCustomerNo);
        Page.Run(Page::"Customer List", Customer);
    end;

    local procedure OpenJobList()
    var
        Job: Record Job;
    begin
        ApplyJobFilters(Job, false);
        Page.Run(Page::"Job List", Job);
    end;

    local procedure HandleDashboardDrillDown(Action: Text; Year: Integer)
    var
        SalesHeader: Record "Sales Header";
    begin
        if Year = 0 then
            Year := FilterYear;

        case Action of
            'proy-total':
                OpenJobs(false);
            'fij-total':
                OpenJobs(true);
            'cont-total':
                OpenContracts(Year);
            'proy-planning':
                OpenJobs(false, "Job Status"::Planning);
            'proy-quote':
                OpenJobs(false, "Job Status"::Quote);
            'proy-open':
                OpenJobs(false, "Job Status"::Open);
            'proy-completed':
                OpenJobs(false, "Job Status"::Completed);
            'proy-res-sin':
                OpenJobsByReservaCategoria(0);
            'proy-res-con':
                OpenJobsByReservaCategoria(1);
            'proy-res-orden':
                OpenJobsByReservaCategoria(2);
            'cont-sinmontar':
                OpenContractsByEstado(SalesHeader.Estado::"Sin Montar", Year);
            'cont-pendfirma':
                OpenContractsByEstado(SalesHeader.Estado::"Pendiente de Firma", Year);
            'cont-firmado':
                OpenContractsByEstado(SalesHeader.Estado::Firmado, Year);
            'cont-modificado':
                OpenContractsByEstado(SalesHeader.Estado::Modificado, Year);
            'cont-pterenovar':
                OpenContractsPendientesRenovar(Year);
            'cont-cancelado':
                OpenContractsByEstado(SalesHeader.Estado::Cancelado, Year);
            'cont-anulado':
                OpenContractsByEstado(SalesHeader.Estado::Anulado, Year);
            'fir-pendiente':
                OpenContractsPendientesSinEnviarGerencia();
            'fir-gerencia':
                OpenContractsPortafirmas(SalesCue.FieldNo(Pending), 7001226);
            'fir-malla':
                OpenContractsPortafirmas(SalesCue.FieldNo("Own Signed"), 7001230);
            'fir-cliente':
                OpenContractsPortafirmas(SalesCue.FieldNo("Customer Signed"), 7001230);
            'fir-rechmalla':
                OpenContractsPortafirmas(SalesCue.FieldNo("Own Rejected"), 7001230);
            'fir-rechcliente':
                OpenContractsPortafirmas(SalesCue.FieldNo("Customer Rejected"), 7001230);
            'fact-facturado':
                OpenPanelMediosFacturadoRegistrado(Year);
            'fact-pendiente':
                OpenPanelMediosFacturasPendientes(Year);
        end;
    end;

    local procedure OpenContracts()
    begin
        OpenContracts(FilterYear);
    end;

    local procedure OpenContracts(Year: Integer)
    var
        SalesHeader: Record "Sales Header";
    begin
        ApplyContractFilters(SalesHeader, Year);
        Page.Run(Page::"Sales Order List", SalesHeader);
    end;

    local procedure OpenOrdenesFijacion()
    var
        CabOrdenFijacion: Record "Cab Orden fijación";
        Job: Record Job;
        DateFilterTxt: Text;
    begin
        DateFilterTxt := GetYearDateFilter();
        CabOrdenFijacion.Reset();
        if DateFilterTxt <> '' then
            CabOrdenFijacion.SetFilter("Fecha fijación", DateFilterTxt);

        if (FilterSalespersonCode = '') and (FilterCustomerNo = '') then begin
            Page.Run(Page::"Lista Ordenes Fijación", CabOrdenFijacion);
            exit;
        end;

        ApplyJobFilters(Job, true);
        if Job.FindSet() then
            repeat
                CabOrdenFijacion.Reset();
                if DateFilterTxt <> '' then
                    CabOrdenFijacion.SetFilter("Fecha fijación", DateFilterTxt);
                CabOrdenFijacion.SetRange("Nº Proyecto", Job."No.");
                if CabOrdenFijacion.FindSet() then
                    repeat
                        CabOrdenFijacion.Mark(true);
                    until CabOrdenFijacion.Next() = 0;
            until Job.Next() = 0;

        CabOrdenFijacion.Reset();
        CabOrdenFijacion.MarkedOnly(true);
        Page.Run(Page::"Lista Ordenes Fijación", CabOrdenFijacion);
    end;

    local procedure OpenResources()
    var
        Resource: Record Resource;
    begin
        ApplyResourceFilters(Resource, FilterYear);
        Page.Run(Page::"Resource List", Resource);
    end;

    local procedure OpenContacts()
    var
        Contact: Record Contact;
    begin
        ApplyContactFilters(Contact, FilterYear);
        Page.Run(Page::"Contact List", Contact);
    end;

    local procedure ApplyCustomerFilters(var Customer: Record Customer)
    begin
        Customer.Reset();
        if FilterSalespersonCode <> '' then
            Customer.SetRange("Salesperson Code", FilterSalespersonCode);
        if FilterCustomerNo <> '' then
            Customer.SetRange("No.", FilterCustomerNo);
    end;

    local procedure ApplyJobFilters(var Job: Record Job)
    begin
        Job.Reset();
        if FilterSalespersonCode <> '' then
            Job.SetRange("Cód. vendedor", FilterSalespersonCode);
        if FilterCustomerNo <> '' then
            Job.SetRange("Bill-to Customer No.", FilterCustomerNo);
    end;

    local procedure ApplyResourceFilters(var Resource: Record Resource; Year: Integer)
    begin
        Resource.Reset();


    end;

    local procedure ApplyContactFilters(var Contact: Record Contact; Year: Integer)
    var
        Contactbus: Record "Contact Business Relation";
    begin
        Contact.Reset();
        if FilterSalespersonCode <> '' then
            Contact.SetRange("Salesperson Code", FilterSalespersonCode);
        If FilterCustomerNo <> '' then begin
            Contactbus.Reset();
            Contactbus.SetRange("Link to Table", Contactbus."Link to Table"::Customer);
            Contactbus.SetRange("No.", FilterCustomerNo);
            if Contactbus.FindSet() then
                repeat
                    Contact.SetRange("No.", Contactbus."Contact No.");
                    if Contact.FindFirst() then
                        repeat
                            contact.Mark(true);
                        until Contact.Next() = 0;

                until Contactbus.Next() = 0;
            Contact.MarkedOnly(true);
            Page.Run(Page::"Contact List", Contact);
            exit
        end;
        page.Run(Page::"Contact List", Contact);
    end;

    local procedure BuildPeriodText()
    var
        Salesperson: Record "Salesperson/Purchaser";
        Customer: Record Customer;
    begin
        PeriodText := 'Año ' + Format(FilterYear);
        if FilterSalespersonCode <> '' then
            if Salesperson.Get(FilterSalespersonCode) then
                PeriodText += ' · ' + Salesperson.Name
            else
                PeriodText += ' · ' + FilterSalespersonCode;
        if FilterCustomerNo <> '' then
            if Customer.Get(FilterCustomerNo) then
                PeriodText += ' · ' + Customer.Name
            else
                PeriodText += ' · ' + FilterCustomerNo;
    end;

    local procedure BuildDashboardPayload()
    var
        Root: JsonObject;
        Proyectos: JsonObject;
        ProyectoLabels: JsonObject;
        Fijacion: JsonObject;
        Contratos: JsonObject;
        Firma: JsonObject;
        ChartProyectos: JsonArray;
        ChartProyectosReserva: JsonArray;
        ChartContratos: JsonArray;
        ChartFirma: JsonArray;
        Facturacion: JsonObject;
        FacturacionPieActual: JsonObject;
        FacturacionPieAnterior: JsonObject;
    begin
        Proyectos.Add('planning', ProyPlanning);
        Proyectos.Add('quote', ProyQuote);
        Proyectos.Add('open', ProyOpen);
        Proyectos.Add('completed', ProyCompleted);
        Root.Add('proyectos', Proyectos);

        ProyectoLabels.Add('planning', JobStatusKuaraCaption("Job Status"::Planning));
        ProyectoLabels.Add('quote', JobStatusKuaraCaption("Job Status"::Quote));
        ProyectoLabels.Add('open', JobStatusKuaraCaption("Job Status"::Open));
        ProyectoLabels.Add('completed', JobStatusKuaraCaption("Job Status"::Completed));
        Root.Add('proyectoLabels', ProyectoLabels);

        Fijacion.Add('total', FijTotal);
        Root.Add('fijacion', Fijacion);

        Contratos.Add('sinMontar', ContSinMontar);
        Contratos.Add('pendFirma', ContPendFirma);
        Contratos.Add('firmado', ContFirmado);
        Contratos.Add('modificado', ContModificado);
        Contratos.Add('pteRenovar', ContPteRenovar);
        Contratos.Add('cancelado', ContCancelado);
        Contratos.Add('anulado', ContAnulado);
        Root.Add('contratos', Contratos);

        AddChartItem(ChartProyectos, JobStatusKuaraCaption("Job Status"::Planning), ProyPlanning, 'proy-planning');
        AddChartItem(ChartProyectos, JobStatusKuaraCaption("Job Status"::Quote), ProyQuote, 'proy-quote');
        AddChartItem(ChartProyectos, JobStatusKuaraCaption("Job Status"::Open), ProyOpen, 'proy-open');
        AddChartItem(ChartProyectos, JobStatusKuaraCaption("Job Status"::Completed), ProyCompleted, 'proy-completed');
        Root.Add('chartProyectos', ChartProyectos);

        AddChartItem(ChartProyectosReserva, 'Sin reserva', ProySinReserva, 'proy-res-sin');
        AddChartItem(ChartProyectosReserva, 'Con reserva', ProyConReserva, 'proy-res-con');
        AddChartItem(ChartProyectosReserva, 'Reserva y orden fij.', ProyConReservaOrden, 'proy-res-orden');
        Root.Add('chartProyectosReserva', ChartProyectosReserva);

        AddChartCompareItem(ChartContratos, 'Sin montar', ContSinMontar, ContSinMontarPrev, 'cont-sinmontar');
        AddChartCompareItem(ChartContratos, 'Pend. firma', ContPendFirma, ContPendFirmaPrev, 'cont-pendfirma');
        AddChartCompareItem(ChartContratos, 'Firmados', ContFirmado, ContFirmadoPrev, 'cont-firmado');
        AddChartCompareItem(ChartContratos, 'Modificados', ContModificado, ContModificadoPrev, 'cont-modificado');
        AddChartCompareItem(ChartContratos, 'Pdtes. renovar', ContPteRenovar, ContPteRenovarPrev, 'cont-pterenovar');
        AddChartCompareItem(ChartContratos, 'Cancelados', ContCancelado, ContCanceladoPrev, 'cont-cancelado');
        AddChartCompareItem(ChartContratos, 'Anulados', ContAnulado, ContAnuladoPrev, 'cont-anulado');
        Root.Add('chartContratos', ChartContratos);
        Root.Add('filterYear', FilterYear);
        Root.Add('prevYear', FilterYear - 1);

        if ActivadoPortafirmas then begin
            Firma.Add('pendiente', FirmaPendienteEnvio);
            Firma.Add('gerencia', FirmaGerencia);
            Firma.Add('malla', FirmaMalla);
            Firma.Add('cliente', FirmaCliente);
            Firma.Add('rechMalla', FirmaRechMalla);
            Firma.Add('rechCliente', FirmaRechCliente);
            Root.Add('firma', Firma);
            Root.Add('portafirmas', true);
            AddChartItem(ChartFirma, 'Pendientes envío', FirmaPendienteEnvio, 'fir-pendiente');
            AddChartItem(ChartFirma, 'Enviados gerencia', FirmaGerencia, 'fir-gerencia');
            AddChartItem(ChartFirma, 'Firmado Malla', FirmaMalla, 'fir-malla');
            AddChartItem(ChartFirma, 'Firmado cliente', FirmaCliente, 'fir-cliente');
            AddChartItem(ChartFirma, 'Rechazado Malla', FirmaRechMalla, 'fir-rechmalla');
            AddChartItem(ChartFirma, 'Rechazado cliente', FirmaRechCliente, 'fir-rechcliente');
        end else begin
            AddChartItem(ChartFirma, 'Pend. firma', ContPendFirma, 'cont-pendfirma');
            AddChartItem(ChartFirma, 'Firmados', ContFirmado, 'cont-firmado');
            AddChartItem(ChartFirma, 'Sin montar', ContSinMontar, 'cont-sinmontar');
        end;
        Root.Add('chartFirma', ChartFirma);

        Facturacion.Add('pctPendiente', FactPctPendiente);
        Facturacion.Add('pctFacturado', FactPctFacturado);
        Facturacion.Add('pctPendientePrev', FactPctPendientePrev);
        Facturacion.Add('pctFacturadoYtd', FactPctFacturadoYtd);
        Facturacion.Add('pctFacturadoYtdPrev', FactPctFacturadoYtdPrev);
        Facturacion.Add('contratos', FactContratosCount);
        Root.Add('facturacion', Facturacion);

        FacturacionPieActual.Add('facturado', FactPctFacturado);
        FacturacionPieActual.Add('pendiente', FactPctPendiente);
        FacturacionPieActual.Add('actionFacturado', 'fact-facturado');
        FacturacionPieActual.Add('actionPendiente', 'fact-pendiente');
        FacturacionPieActual.Add('year', FilterYear);
        Root.Add('facturacionPieActual', FacturacionPieActual);

        FacturacionPieAnterior.Add('facturado', FactPctFacturadoYtdPrev);
        FacturacionPieAnterior.Add('pendiente', FactPctPendientePrev);
        FacturacionPieAnterior.Add('actionFacturado', 'fact-facturado');
        FacturacionPieAnterior.Add('actionPendiente', 'fact-pendiente');
        FacturacionPieAnterior.Add('year', FilterYear - 1);
        Root.Add('facturacionPieAnterior', FacturacionPieAnterior);
        Root.Add('billingCutoff', BillingCutoffText);

        Root.Add('period', PeriodText);
        Root.Add('layoutMode', 'embed');
        Root.WriteTo(DashboardPayload);
    end;

    local procedure AddChartItem(var ChartArray: JsonArray; LabelTxt: Text; Value: Integer)
    begin
        AddChartItem(ChartArray, LabelTxt, Value, '');
    end;

    local procedure AddChartItem(var ChartArray: JsonArray; LabelTxt: Text; Value: Integer; ActionTxt: Text)
    var
        Item: JsonObject;
    begin
        Clear(Item);
        Item.Add('label', LabelTxt);
        Item.Add('value', Value);
        if ActionTxt <> '' then
            Item.Add('action', ActionTxt);
        ChartArray.Add(Item);
    end;

    local procedure AddChartCompareItem(var ChartArray: JsonArray; LabelTxt: Text; CurrentValue: Integer; PrevValue: Integer)
    begin
        AddChartCompareItem(ChartArray, LabelTxt, CurrentValue, PrevValue, '');
    end;

    local procedure AddChartCompareItem(var ChartArray: JsonArray; LabelTxt: Text; CurrentValue: Integer; PrevValue: Integer; ActionTxt: Text)
    var
        Item: JsonObject;
    begin
        Clear(Item);
        Item.Add('label', LabelTxt);
        Item.Add('value', CurrentValue);
        Item.Add('valuePrev', PrevValue);
        if ActionTxt <> '' then
            Item.Add('action', ActionTxt);
        ChartArray.Add(Item);
    end;

    local procedure AddChartComparePctItem(var ChartArray: JsonArray; LabelTxt: Text; CurrentPct: Decimal; PrevPct: Decimal)
    var
        Item: JsonObject;
    begin
        Clear(Item);
        Item.Add('label', LabelTxt);
        Item.Add('value', CurrentPct);
        Item.Add('valuePrev', PrevPct);
        Item.Add('isPercent', true);
        ChartArray.Add(Item);
    end;

    local procedure CalculateFacturacionMetrics()
    var
        FPR: Codeunit "Gestion Facturación";
    begin
        Clear(FactPctPendiente);
        Clear(FactPctFacturado);
        Clear(FactPctPendientePrev);
        Clear(FactPctFacturadoYtd);
        Clear(FactPctFacturadoYtdPrev);
        Clear(FactContratosCount);
        BillingCutoffText := '';

        if Fpr.TryLoadPanelMediosCache(
             FilterYear, FilterSalespersonCode, FilterCustomerNo,
             FactPctFacturado, FactPctPendiente, FactPctFacturadoYtdPrev, FactPctPendientePrev,
             FactContratosCount, BillingCutoffText) then begin
            FactPctFacturadoYtd := FactPctFacturado;
            exit;
        end;

        BillingCutoffText := Fpr.GetPanelMediosCacheStatusText(FilterYear, FilterSalespersonCode, FilterCustomerNo);
    end;

    local procedure RequestFacturacionCacheRefresh()
    var
        Fpr: Codeunit "Gestion Facturación";
    begin
        if FilterYear = 0 then
            exit;
        if Fpr.IsPanelMediosFactCacheReady(FilterYear, FilterSalespersonCode, FilterCustomerNo) then
            exit;
        Fpr.EnqueuePanelMediosCacheRefresh(FilterYear, FilterSalespersonCode, FilterCustomerNo);
    end;

    local procedure SendDashboard()
    begin
        if not DashboardReady then
            exit;
        if DashboardPayload = '' then
            exit;
        CurrPage.Dashboard.Render(DashboardPayload);
    end;

    local procedure GetYearDateFilter(): Text
    begin
        exit(GetYearDateFilterForYear(FilterYear));
    end;

    local procedure GetYearDateFilterForYear(Year: Integer): Text
    var
        FromDate: Date;
        ToDate: Date;
    begin
        if Year = 0 then
            exit('');
        FromDate := DMY2Date(1, 1, Year);
        ToDate := DMY2Date(31, 12, Year);
        exit(StrSubstNo('%1..%2', FromDate, ToDate));
    end;

    local procedure ApplyJobFilters(var Job: Record Job; ProyectoFijacion: Boolean)
    var
        DateFilterTxt: Text;
    begin
        Job.Reset();
        if ProyectoFijacion then
            Job.SetRange("Proyecto de fijación", true)
        else
            Job.SetRange("Proyecto de fijación", false);
        DateFilterTxt := GetYearDateFilter();
        if DateFilterTxt <> '' then
            Job.SetFilter("Creation Date", DateFilterTxt);
        if FilterSalespersonCode <> '' then
            Job.SetRange("Cód. vendedor", FilterSalespersonCode);
        if FilterCustomerNo <> '' then
            Job.SetRange("Bill-to Customer No.", FilterCustomerNo);
    end;

    local procedure ApplyContractFilters(var SalesHeader: Record "Sales Header"; Year: Integer)
    var
        DateFilterTxt: Text;
    begin
        SalesHeader.Reset();
        SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::Order);
        DateFilterTxt := GetYearDateFilterForYear(Year);
        if DateFilterTxt <> '' then
            SalesHeader.SetFilter("Posting Date", DateFilterTxt);
        if FilterSalespersonCode <> '' then
            SalesHeader.SetRange("Salesperson Code", FilterSalespersonCode);
        if FilterCustomerNo <> '' then
            SalesHeader.SetRange("Sell-to Customer No.", FilterCustomerNo);
    end;

    local procedure GetPanelMediosBillingCutoffDate(Year: Integer): Date
    begin
        if Year = Date2DMY(WorkDate(), 3) then
            exit(WorkDate());
        exit(DMY2Date(31, 12, Year));
    end;

    local procedure PreparePanelMediosContracts(var Contratos: Record "Sales Header"; Year: Integer): Boolean
    begin
        Contratos.Reset();
        ApplyContractFilters(Contratos, Year);
        Contratos.SetFilter(Estado, '<>%1&<>%2', Contratos.Estado::Cancelado, Contratos.Estado::Anulado);
        if not Contratos.FindSet() then
            exit(false);
        repeat
            Contratos.Mark(true);
        until Contratos.Next() = 0;
        Contratos.MarkedOnly(true);
        exit(true);
    end;

    local procedure OpenPanelMediosFacturadoRegistrado(Year: Integer)
    var
        Contratos: Record "Sales Header";
        SalesInvHeader: Record "Sales Invoice Header";
        Cutoff: Date;
    begin
        if not PreparePanelMediosContracts(Contratos, Year) then begin
            Page.Run(Page::"Posted Sales Invoices");
            exit;
        end;

        Cutoff := GetPanelMediosBillingCutoffDate(Year);
        SalesInvHeader.Reset();
        if FilterSalespersonCode <> '' then
            SalesInvHeader.SetRange("Salesperson Code", FilterSalespersonCode);
        if FilterCustomerNo <> '' then
            SalesInvHeader.SetRange("Sell-to Customer No.", FilterCustomerNo);
        SalesInvHeader.SetFilter("Posting Date", '..%1', Cutoff);
        if SalesInvHeader.FindSet() then
            repeat
                if SalesInvHeader."Nº Contrato" = '' then
                    continue;
                if Contratos.Get(Contratos."Document Type"::Order, SalesInvHeader."Nº Contrato") then
                    SalesInvHeader.Mark(true);
            until SalesInvHeader.Next() = 0;
        SalesInvHeader.MarkedOnly(true);
        Page.Run(Page::"Posted Sales Invoices", SalesInvHeader);
    end;

    local procedure OpenPanelMediosFacturasPendientes(Year: Integer)
    var
        Contratos: Record "Sales Header";
        SalesHeader: Record "Sales Header";
        Cutoff: Date;
    begin
        if not PreparePanelMediosContracts(Contratos, Year) then begin
            Page.Run(Page::"Sales Invoice List");
            exit;
        end;

        Cutoff := GetPanelMediosBillingCutoffDate(Year);
        SalesHeader.Reset();
        SalesHeader.SetFilter("Document Type", '%1|%2', SalesHeader."Document Type"::Invoice, SalesHeader."Document Type"::"Credit Memo");
        if FilterSalespersonCode <> '' then
            SalesHeader.SetRange("Salesperson Code", FilterSalespersonCode);
        if FilterCustomerNo <> '' then
            SalesHeader.SetRange("Sell-to Customer No.", FilterCustomerNo);
        SalesHeader.SetFilter("Posting Date", '..%1', Cutoff);
        if SalesHeader.FindSet() then
            repeat
                if SalesHeader."Nº Contrato" = '' then
                    continue;
                if Contratos.Get(Contratos."Document Type"::Order, SalesHeader."Nº Contrato") then
                    SalesHeader.Mark(true);
            until SalesHeader.Next() = 0;
        SalesHeader.MarkedOnly(true);
        Page.Run(Page::"Sales Invoice List", SalesHeader);
    end;

    local procedure JobStatusKuaraCaption(JobStatus: Enum "Job Status"): Text
    var
        Kuara: Enum "Job Status Kuara";
    begin
        Kuara := JobStatus;
        exit(Format(Kuara));
    end;

    local procedure CountJobs(ProyectoFijacion: Boolean; JobStatus: Enum "Job Status"): Integer
    var
        Job: Record Job;
    begin
        ApplyJobFilters(Job, ProyectoFijacion);
        Job.SetRange(Status, JobStatus);
        exit(Job.Count());
    end;

    local procedure CountJobsFijacion(): Integer
    var
        Job: Record Job;
    begin
        ApplyJobFilters(Job, true);
        exit(Job.Count());
    end;

    local procedure CalculateProyectosReservaCategorias()
    var
        Job: Record Job;
    begin
        ApplyJobFilters(Job, false);
        if Job.FindSet() then
            repeat
                ClassifyProyectoReserva(Job."No.");
            until Job.Next() = 0;
    end;

    local procedure ClassifyProyectoReserva(JobNo: Code[20])
    begin
        case GetProyectoReservaCategoria(JobNo) of
            0:
                ProySinReserva += 1;
            1:
                ProyConReserva += 1;
            2:
                ProyConReservaOrden += 1;
        end;
    end;

    local procedure GetProyectoReservaCategoria(JobNo: Code[20]): Integer
    var
        Reserva: Record Reserva;
        TieneOrdenFijacion: Boolean;
    begin
        if JobNo = '' then
            exit(-1);

        Reserva.Reset();
        Reserva.SetRange("Nº Proyecto", JobNo);
        if not Reserva.FindFirst() then
            exit(0);

        TieneOrdenFijacion := false;
        if Reserva.FindSet() then
            repeat
                Reserva.CalcFields("Orden fijación creada");
                if Reserva."Orden fijación creada" then
                    TieneOrdenFijacion := true;
            until Reserva.Next() = 0;

        if TieneOrdenFijacion then
            exit(2);
        exit(1);
    end;

    local procedure OpenJobsByReservaCategoria(ReservaCategoria: Integer)
    var
        Job: Record Job;
    begin
        ApplyJobFilters(Job, false);
        if Job.FindSet() then
            repeat
                if GetProyectoReservaCategoria(Job."No.") = ReservaCategoria then
                    Job.Mark(true);
            until Job.Next() = 0;
        Job.MarkedOnly(true);
        Page.Run(Page::"Job List", Job);
    end;

    local procedure CountContractsByEstado(EstadoValue: Enum "Estado Contrato"): Integer
    begin
        exit(CountContractsByEstado(EstadoValue, FilterYear));
    end;

    local procedure CountContractsByEstado(EstadoValue: Enum "Estado Contrato"; Year: Integer): Integer
    var
        SalesHeader: Record "Sales Header";
    begin
        ApplyContractFilters(SalesHeader, Year);
        SalesHeader.SetRange(Estado, EstadoValue);
        exit(SalesHeader.Count());
    end;

    local procedure ApplyToSalesCue(var SalesCue: Record "Sales Cue")
    var
        DateFilterTxt: Text;
    begin
        SalesCue.Reset();
        DateFilterTxt := GetYearDateFilter();
        if DateFilterTxt <> '' then
            SalesCue.SetFilter("Date Filter", DateFilterTxt)
        else
            SalesCue.SetRange("Date Filter", CalcDate('PA+1D-1A-3M', Today), CalcDate('PA+3M', Today));
        if FilterSalespersonCode <> '' then
            SalesCue.SetRange("Salesperson Filter", FilterSalespersonCode)
        else
            SalesCue.SetRange("Salesperson Filter");
    end;

    local procedure OpenJobs(ProyectoFijacion: Boolean)
    var
        Job: Record Job;
    begin
        ApplyJobFilters(Job, ProyectoFijacion);
        Page.Run(Page::"Job List", Job);
    end;

    local procedure OpenJobs(ProyectoFijacion: Boolean; JobStatus: Enum "Job Status")
    var
        Job: Record Job;
    begin
        ApplyJobFilters(Job, ProyectoFijacion);
        Job.SetRange(Status, JobStatus);
        Page.Run(Page::"Job List", Job);
    end;


    local procedure OpenContractsByEstado(EstadoValue: Enum "Estado Contrato")
    begin
        OpenContractsByEstado(EstadoValue, FilterYear);
    end;

    local procedure OpenContractsByEstado(EstadoValue: Enum "Estado Contrato"; Year: Integer)
    var
        SalesHeader: Record "Sales Header";
    begin
        ApplyContractFilters(SalesHeader, Year);
        SalesHeader.SetRange(Estado, EstadoValue);
        Page.Run(Page::"Lista contratos venta", SalesHeader);
    end;

    local procedure GetRenovacionDateRange(Year: Integer; var FromDate: Date; var ToDate: Date)
    begin
        FromDate := DMY2Date(1, 1, Year);
        if Year = Date2DMY(WorkDate(), 3) then
            ToDate := CalcDate('<+1M>', WorkDate())
        else
            ToDate := CalcDate('<-1Y>', CalcDate('<+1M>', WorkDate()));
        if ToDate > DMY2Date(31, 12, Year) then
            ToDate := DMY2Date(31, 12, Year);
        if ToDate < FromDate then
            ToDate := FromDate;
    end;

    local procedure ApplyPendientesRenovarFilters(var Contratos: Record "Sales Header"; Year: Integer)
    var
        FromDate: Date;
        ToDate: Date;
    begin
        ApplyContractFilters(Contratos, Year);
        GetRenovacionDateRange(Year, FromDate, ToDate);
        Contratos.SetRange("Posting Date");
        Contratos.SetFilter("Fecha renovacion", '%1..%2', FromDate, ToDate);
        Contratos.SetFilter(Estado, '<>%1&<>%2', Contratos.Estado::Cancelado, Contratos.Estado::Anulado);
    end;

    local procedure CountContractsPendientesRenovar(Year: Integer): Integer
    var
        Contratos: Record "Sales Header";
    begin
        ApplyPendientesRenovarFilters(Contratos, Year);
        exit(Contratos.Count());
    end;

    local procedure OpenContractsPendientesRenovar()
    begin
        OpenContractsPendientesRenovar(FilterYear);
    end;

    local procedure OpenContractsPendientesRenovar(Year: Integer)
    var
        Contratos: Record "Sales Header";
    begin
        ApplyPendientesRenovarFilters(Contratos, Year);
        Page.Run(Page::"Lista contratos venta", Contratos);
    end;

    local procedure CountContractsPendientesSinEnviarGerencia(): Integer
    var
        Contratos: Record "Sales Header";
    begin
        ApplyContractFilters(Contratos, FilterYear);
        Contratos.SetRange(Estado, Contratos.Estado::"Pendiente de Firma");
        Contratos.SetRange("Enviado a dirección", false);
        exit(Contratos.Count());
    end;

    local procedure OpenContractsPendientesSinEnviarGerencia()
    var
        Contratos: Record "Sales Header";
    begin
        ApplyContractFilters(Contratos, FilterYear);
        Contratos.SetRange(Estado, Contratos.Estado::"Pendiente de Firma");
        Contratos.SetRange("Enviado a dirección", false);
        Page.Run(Page::"Lista contratos venta", Contratos);
    end;

    local procedure CountContractsPortafirmas(CueFieldNo: Integer): Integer
    var
        SalesCueLocal: Record "Sales Cue";
        Contratos: Record "Sales Header";
    begin
        ApplyToSalesCue(SalesCueLocal);
        SalesCueLocal.FilterOrders(Contratos, CueFieldNo);
        exit(Contratos.Count());
    end;

    local procedure OpenContractsPortafirmas(CueFieldNo: Integer; TargetPage: Integer)
    var
        SalesCueLocal: Record "Sales Cue";
        Contratos: Record "Sales Header";
    begin
        ApplyToSalesCue(SalesCueLocal);
        SalesCueLocal.FilterOrders(Contratos, CueFieldNo);
        Page.Run(TargetPage, Contratos);
    end;

    var
        FilterYear: Integer;
        FilterSalespersonCode: Code[20];
        FilterCustomerNo: Code[20];
        ProyPlanning: Integer;
        ProyQuote: Integer;
        ProyOpen: Integer;
        ProyCompleted: Integer;
        ProySinReserva: Integer;
        ProyConReserva: Integer;
        ProyConReservaOrden: Integer;
        FijTotal: Integer;
        ContSinMontar: Integer;
        ContPendFirma: Integer;
        ContFirmado: Integer;
        ContModificado: Integer;
        ContPteRenovar: Integer;
        ContCancelado: Integer;
        ContAnulado: Integer;
        ContSinMontarPrev: Integer;
        ContPendFirmaPrev: Integer;
        ContFirmadoPrev: Integer;
        ContModificadoPrev: Integer;
        ContPteRenovarPrev: Integer;
        ContCanceladoPrev: Integer;
        ContAnuladoPrev: Integer;
        FirmaPendienteEnvio: Integer;
        FirmaGerencia: Integer;
        FirmaMalla: Integer;
        FirmaCliente: Integer;
        FirmaRechMalla: Integer;
        FirmaRechCliente: Integer;
        FactPctPendiente: Decimal;
        FactPctFacturado: Decimal;
        FactPctPendientePrev: Decimal;
        FactPctFacturadoYtd: Decimal;
        FactPctFacturadoYtdPrev: Decimal;
        FactContratosCount: Integer;
        BillingCutoffText: Text[120];
        ActivadoPortafirmas: Boolean;
        PeriodText: Text[250];
        DashboardPayload: Text;
        DashboardReady: Boolean;
        SalesHeader: Record "Sales Header";
        SalesCue: Record "Sales Cue";
}
