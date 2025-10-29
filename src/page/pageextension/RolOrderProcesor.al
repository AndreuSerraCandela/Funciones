/// <summary>
/// PageExtension OrderProcesor (ID 80103) extends Record Order Processor Role Center.
/// </summary>
pageextension 80103 OrderProcesor extends "Order Processor Role Center"
{
    layout
    {
        modify(Control14)
        {
            Visible = false;
        }
        addafter(Control1901851508)
        {
            part(ContratosASctivities; "Contratos Activities")
            {
                ApplicationArea = All;
            }
            part(SystemActivities; "Systemas Activities")
            {
                ApplicationArea = All;

            }
        }
    }
    //añade una accion antes se SalesOrder para los Contartos
    actions
    {
        modify(Action62)
        {
            Visible = false;
        }

        addafter(Action63)
        {
            group(Gestión)
            {
                Caption = 'Gestión Proyectos';
                ToolTip = 'Gestion de Proyectos';
                action(Resources)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Recursos';
                    Image = Resource;
                    // Promoted = true;
                    // PromotedCategory = Process;
                    RunObject = Page "Resource List";
                    ToolTip = 'Ver y editar los recursos de la empresa';
                }

                action(Proyectos)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Proyectos';
                    Image = Job;
                    // Promoted = true;
                    // PromotedCategory = Process;
                    RunObject = Page "Job List";
                    ToolTip = 'Ver y editar los proyectos de la empresa';
                }

            }
        }
        addafter(SalesOrders)
        {
            action(Contract)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Contratos';
                Image = ContractPayment;
                RunObject = Page "Lista Contratos Venta";
                //Toottip descriptivo de esta operacion
                ToolTip = 'Lista de Contratos de Venta';


            }
            action(Proyecto)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Proyectos';
                Image = Job;
                RunObject = Page "Job List";
                //Toottip descriptivo de esta operacion
                ToolTip = 'Lista de Proyectos de Venta';
            }
            action(Recursos)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Recursos';
                Image = Resource;
                RunObject = Page "Resource List";
                //Toottip descriptivo de esta operacion
                ToolTip = 'Lista de Recursos de la empresa';
            }
            action(Proveedores)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Proveedores';
                Image = Vendor;
                RunObject = Page "Vendor List";
                //Toottip descriptivo de esta operacion
                ToolTip = 'Lista de Proveedores de la empresa';
            }
            action(SalesInvoices)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Histórico facturas ventas';
                Image = PostedOrder;
                RunObject = Page "Posted Sales Invoices";
                ToolTip = 'Histórico de facturas de ventas';
            }
        }
        modify(Items)
        {
            Visible = false;
        }
        modify("Item Journals")
        {
            Visible = false;
        }
        modify("Transfer Orders")
        {
            Visible = false;
        }

        addafter("Sales Orders")
        {
            action(Contractos)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Contratos';
                Image = ContractPayment;
                RunObject = Page "Lista Contratos Venta";
                //Toottip descriptivo de esta operacion
                ToolTip = 'Lista de Contratos de Venta';


            }
        }
        addafter("Sales &Order")
        {
            action("C&ontrato")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'C&ontrato';
                Image = Document;
                RunObject = Page "Ficha Contrato Venta";
                RunPageMode = Create;
                ToolTip = 'Crear nuevo Contrato de Venta';
            }
            action("&Proyecto")
            {
                ApplicationArea = Basic, Suite;
                Caption = '&Proyecto';
                Image = Document;
                RunObject = Page "Job Card";
                RunPageMode = Create;
                ToolTip = 'Crear nuevo Proyecto de Venta';
            }


        }
    }

}