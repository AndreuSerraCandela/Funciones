pageextension 80194 PostedBillGroups Extends "Posted Bill Groups"
{
    actions
    {
        addlast("Bill &Group")
        {
            action(Cerrar)
            {
                ApplicationArea = All;
                Image = Close;
                trigger OnAction()
                VAR
                    DocPost: Codeunit ControlProcesos;
                BEGIN
                    DocPost.CloseBillGroupIfEmpty(Rec, TODAY);
                END;
            }

            action("Cerrar de Todas Formas")
            {
                ApplicationArea = All;
                Image = ClosePeriod;
                trigger OnAction()
                VAR
                    r70004: Record 7000003;
                    DocPost: Codeunit ControlProcesos;
                    ControlProcesos: Codeunit ControlProcesos;
                BEGIN
                    ControlProcesos.CierreProcesos(Rec);
                    Commit();
                    DocPost.CloseBillGroupIfEmpty(Rec, TODAY);
                END;
            }

        }

    }
}