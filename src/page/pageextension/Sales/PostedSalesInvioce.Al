
/// <summary>
/// PageExtension PostedSalesInv (ID 80172) extends Record Posted Sales Invoice.
/// </summary>
pageextension 80172 PostedSalesInv extends "Posted Sales Invoice"
{
    layout
    {
        addafter("Pre-Assigned No.")
        {
            field("Nº Contrato"; Rec."Nº Contrato")
            {
                ApplicationArea = all;
            }
            field("Nº Proyecto"; Rec."Nº Proyecto")
            {
                ApplicationArea = all;
            }
            field("Nº pedido"; Rec."Nº pedido")
            {
                ApplicationArea = all;
            }
            field("Nº pedido cliente"; Rec."Customer Order No.")
            {
                ApplicationArea = all;
            }
        }
        modify("Work Description")
        {
            Visible = false;
        }
        addafter("Work Description")
        {
            field("Descripcion Trabajo"; Descwork)
            {
                Editable = true;
                ApplicationArea = All;
                trigger OnValidate()
                var
                    Control: Codeunit ControlProcesos;
                begin
                    Control.ModificaTexto(Rec, Descwork);
                end;

            }

        }

    }

    trigger OnAfterGetRecord()
    begin
        Descwork := Rec.GetWorkDescription();

    end;


    Var
        Descwork: Text;

}
