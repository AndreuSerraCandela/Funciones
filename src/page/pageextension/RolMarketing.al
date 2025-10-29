/// <summary>
/// PageExtension RolMarketing (ID 80101) extends Record Sales Relationship Mgr. RC.
/// </summary>
pageextension 80101 RolMarketing extends "Sales & Relationship Mgr. RC"
{
    layout
    {
        addafter(ApprovalsActivities)
        {
            part(ContratosActivities; "Contratos Activities")
            {
                ApplicationArea = All;
                Caption = 'Contratos';
                Visible = true;
            }
        }
        modify(ApprovalsActivities)
        {
            Visible = false;
        }
        modify(Control16)
        {
            Visible = false;
        }
    }
    actions
    {
        addafter(Customers)
        {
            action(Resource)
            {

                ApplicationArea = RelationshipMgmt;
                Caption = 'Recursos';
                Image = Resource;
                RunObject = Page "Resource List";

            }

        }
        addafter("Sales &Return Order")
        {
            action("Crear Tarea")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Crear &Tarea';
                Image = Task;
                RunObject = Page "Create Task";
                RunPageMode = Create;
                ToolTip = 'Crea tareas';
            }
        }

        modify("Blanket Sales Order Archives")
        {
            Visible = false;
        }
        modify("Sales Quotes")
        {
            Caption = 'Ofertas Contrato';
        }
        modify("Sales &Quote")
        {
            Caption = '&Ofertas Contrato';
        }
        modify("Sales Orders")
        {
            Caption = 'Contratos';
        }
        modify(Action65)
        {
            Caption = 'Ofertas de contrato';
        }
        modify(Action64)
        {
            Caption = 'Contratos';
        }
        modify(Action62)
        {
            Visible = false;
        }
        modify("Sales &Order")
        {
            Caption = '&Contratos';

        }

#pragma warning disable AL0432 // TODO: - Eliminar
        modify("Sales Line &Discounts")
#pragma warning restore AL0432 // TODO: - Eliminar

        {
            Visible = false;
        }
        modify("Blanket Sales Orders")
        {
            Visible = false;
        }
        modify("Cust. Invoice Discounts")
        {
            Visible = false;
        }
        modify("Customer - &Order Summary")
        {
            Caption = 'Cliente - Total Contratos';
        }
        modify("Issued Finance Charge Memos")
        {
            Visible = false;
        }
        modify("Issued Reminders")
        {
            Visible = false;
        }
        modify("Item Attributes")
        {
            Visible = false;
        }
        modify("Item Charges")
        {
            Visible = false;
        }
        modify("Item Disc. Groups")
        {
            Visible = false;
        }
        modify(Items)
        {
            Visible = false;
        }
        modify("Posted Return Receipts")
        {
            Visible = false;
        }
        modify("Customer Price Groups")
        {
            Caption = 'Tarifas';
        }

#pragma warning disable AL0432 // TODO: - Eliminar
        modify("Sales &Prices")
#pragma warning restore AL0432 // TODO: - Eliminar

        {
            Visible = false;
        }

#pragma warning disable AL0432 // TODO: - Eliminar
        modify("Sales Price &Worksheet")
#pragma warning restore AL0432 // TODO: - Eliminar

        {
            Visible = false;
        }
        modify("Sales &Return Order")
        {
            Visible = false;
        }
        modify("Sales Order Archive")
        {
            Caption = 'Contratos archivados';
        }
        modify("Salesperson - &Commission")
        {
            Visible = false;
        }
        modify("Sales Quote Archive")
        {
            Caption = 'Ofertas contrato archivadas';
        }
        modify("Sales Return Orders")
        {
            Visible = false;
        }


    }
}
