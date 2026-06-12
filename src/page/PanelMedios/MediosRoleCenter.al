// Role Center orientado al panel de medios (proyectos, fijacion y contratos).
page 50141 "Medios Role Center"
{
    ApplicationArea = All;
    Caption = 'Gestión Medios';
    PageType = RoleCenter;
    layout
    {
        area(rolecenter)
        {
            part(HeadlineMedios; "Headline RC Medios")
            {
                ApplicationArea = All;
            }
            part(PanelMedios; "Panel Medios")
            {
                ApplicationArea = All;
                Caption = 'Panel Medios';
            }
        }
    }
    actions
    {
        area(Embedding)
        {
            ToolTip = 'Gestión de ventas, contratos, proyectos y clientes.';


            action(Contratos)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Contratos';
                Image = ContractPayment;
                RunObject = page "Lista Contratos Venta";
                ToolTip = 'Lista de contratos de venta.';
            }
            action(Proyectos)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Proyectos';
                Image = Job;
                RunObject = page "Job List";
                ToolTip = 'Lista de proyectos.';
            }
            action(Recursos)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Recursos';
                Image = Resource;
                RunObject = page "Resource List";
                ToolTip = 'Lista de recursos.';
            }
            action(Proveedores)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Proveedores';
                Image = Vendor;
                RunObject = page "Vendor List";
                ToolTip = 'Lista de proveedores.';
            }
            action(HistoricoFacturasVentas)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Histórico facturas ventas';
                Image = PostedOrder;
                RunObject = page "Posted Sales Invoices";
                ToolTip = 'Histórico de facturas de venta registradas.';
            }


            action(Clientes)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Clientes';
                Image = Customer;
                RunObject = page "Customer List";
                ToolTip = 'Lista de clientes.';
            }
            action(Contactos)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Contactos';
                RunObject = page "Contact List";
                ToolTip = 'Lista de contactos.';

            }
        }
        area(Sections)
        {
            group(Ventas)
            {
                Caption = 'Ventas';
                Image = Sales;
                ToolTip = 'Ofertas, pedidos, facturas y clientes.';
                action(ClientesMenu)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Clientes';
                    Image = Customer;
                    RunObject = page "Customer List";
                    ToolTip = 'Ficha y lista de clientes.';
                }
                action(ProyectosVenta)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Proyectos venta';
                    RunObject = page "Job List";
                    ToolTip = 'Proyectos de venta.';
                }
                //Ordenes fijacion
                action(OrdenesFijacion)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Orden fijación';
                    Image = Document;
                    RunObject = page "Lista Ordenes Fijación";
                    ToolTip = 'Lista de órdenes de fijación.';
                }
                action(PedidosVentaMenu)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Pedidos venta';
                    RunObject = page "Sales Order List";
                    ToolTip = 'Pedidos de venta.';
                }
                //contratosventa
                action(ContratosVenta)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Contratos venta';
                    RunObject = page "Lista Contratos Venta";
                    ToolTip = 'Contratos de venta.';
                }
                action(FacturasVenta)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Facturas venta';
                    RunObject = page "Sales Invoice List";
                    ToolTip = 'Facturas de venta.';
                }
                action(DevolucionesVenta)
                {
                    ApplicationArea = SalesReturnOrder;
                    Caption = 'Devoluciones venta';
                    RunObject = page "Sales Return Order List";
                    ToolTip = 'Pedidos de devolución de venta.';
                }
                action(AbonosVenta)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Abonos venta';
                    RunObject = page "Sales Credit Memos";
                    ToolTip = 'Abonos de venta.';
                }

                action(FacturasVentaRegistradas)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Facturas venta registradas';
                    RunObject = page "Posted Sales Invoices";
                    ToolTip = 'Facturas de venta registradas.';
                }
                action(AbonosVentaRegistrados)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Abonos venta registrados';
                    RunObject = page "Posted Sales Credit Memos";
                    ToolTip = 'Abonos de venta registrados.';
                }
                action(RecepcionesDevolucionRegistradas)
                {
                    ApplicationArea = SalesReturnOrder;
                    Caption = 'Recepciones devolución registradas';
                    RunObject = page "Posted Return Receipts";
                    ToolTip = 'Recepciones de devolución registradas.';
                }

            }
            group(Compras)
            {
                Caption = 'Compras';
                Image = FiledPosted;
                ToolTip = 'Proveedores, pedidos y facturas de compra.';
                action(ProveedoresMenu)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Proveedores';
                    Image = Vendor;
                    RunObject = page "Vendor List";
                    ToolTip = 'Lista de proveedores.';
                }

                action(PedidosCompra)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Pedidos compra';
                    RunObject = page "Purchase Order List";
                    ToolTip = 'Pedidos de compra.';
                }

            }
            group(DocumentosRegistrados)
            {
                Caption = 'Documentos registrados';
                Image = FiledPosted;
                ToolTip = 'Histórico de documentos registrados.';
                action(FacturasVentaRegistradasDoc)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Facturas venta registradas';
                    Image = PostedOrder;
                    RunObject = page "Posted Sales Invoices";
                    ToolTip = 'Facturas de venta registradas.';
                }
                action(AbonosVentaRegistradosDoc)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Abonos venta registrados';
                    Image = PostedOrder;
                    RunObject = page "Posted Sales Credit Memos";
                    ToolTip = 'Abonos de venta registrados.';
                }
                action(RecepcionesDevolucionRegistradasDoc)
                {
                    ApplicationArea = SalesReturnOrder;
                    Caption = 'Recepciones devolución registradas';
                    Image = PostedReturnReceipt;
                    RunObject = page "Posted Return Receipts";
                    ToolTip = 'Recepciones de devolución registradas.';
                }
                action(EnviosVentaRegistradosDoc)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Envíos venta registrados';
                    Image = PostedShipment;
                    RunObject = page "Posted Sales Shipments";
                    ToolTip = 'Envíos de venta registrados.';
                }

            }
        }
        area(Creation)
        {


            action(Contrato)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'C&ontrato';
                Image = Document;
                RunObject = page "Ficha Contrato Venta";
                RunPageMode = Create;
                ToolTip = 'Crear un contrato de venta.';
            }
            action(Proyecto)
            {
                ApplicationArea = Basic, Suite;
                Caption = '&Proyecto';
                Image = Document;
                RunObject = page "Job Card";
                RunPageMode = Create;
                ToolTip = 'Crear un proyecto.';
            }
            //Ordenes fijacion
            action(OrdenFijacion)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Orden fijación';
                Image = Document;
                RunObject = Report "Crear orden fijación";
                ToolTip = 'Crear una orden de fijación.';
            }

        }
        area(Processing)
        {

            group(GestionProyectos)
            {
                Caption = 'Gestión proyectos';
                ToolTip = 'Recursos y proyectos.';
                action(RecursosGestion)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Recursos';
                    Image = Resource;
                    RunObject = page "Resource List";
                    ToolTip = 'Ver y editar los recursos de la empresa.';
                }
                action(ProyectosGestion)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Proyectos';
                    Image = Job;
                    RunObject = page "Job List";
                    RunPageView = where("Proyecto de fijación" = const(false));
                    ToolTip = 'Ver y editar los proyectos de la empresa.';
                }
                //Proyectos fijacion
                action(ProyectosFijacion)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Proyectos fijación';
                    Image = Job;
                    RunObject = page "Job List";
                    RunPageView = where("Proyecto de fijación" = const(true));
                    ToolTip = 'Ver y editar los proyectos fijación de la empresa.';
                }
                //Ordenes fijacion
                action(OrdenesFijacionGestion)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Ordenes fijación';
                    Image = Document;
                    RunObject = page "Lista Ordenes Fijación";
                    ToolTip = 'Lista de órdenes de fijación.';
                }
            }

            group(Informes)
            {
                Caption = 'Informes';
                group(InformesCliente)
                {
                    Caption = 'Cliente';
                    Image = Customer;
                    action(InformeResumenPedidosCliente)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Cliente - Resumen pedidos';
                        Image = Report;
                        RunObject = report "Customer - Order Summary";
                        ToolTip = 'Resumen de pedidos por cliente.';
                    }
                    action(InformeTop10Cliente)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Cliente - Top 10';
                        Image = Report;
                        RunObject = report "Customer - Top 10 List";
                        ToolTip = 'Top 10 clientes.';
                    }

                }
                group(InformesVentas)
                {
                    Caption = 'Ventas';
                    Image = Sales;
                    action(InformeEstadisticasVendedor)
                    {
                        ApplicationArea = Suite;
                        Caption = 'Vendedor - Estadísticas ventas';
                        Image = Report;
                        RunObject = report "Salesperson - Sales Statistics";
                        ToolTip = 'Estadísticas de ventas por vendedor.';
                    }

                }
            }
            group(Historial)
            {
                Caption = 'Historial';
                action(BuscarMovimientos)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Buscar movimientos...';
                    Image = Navigate;
                    RunObject = page Navigate;
                    ShortCutKey = 'Ctrl+Alt+Q';
                    ToolTip = 'Buscar movimientos y documentos relacionados.';
                }
            }
        }
    }
}
