pageextension 80187 OrdenPago extends "Payment Orders"
{
    actions
    {
        addafter(Export)
        {
            action("Anular Envio")
            {
                ApplicationArea = all;
                Image = Undo;
                trigger OnAction()
                var
                begin
                    Rec."Elect. Pmts Exported" := false;
                    Rec.Modify();
                end;
            }
        }
    }
}