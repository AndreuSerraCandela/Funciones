/// <summary>
/// PageExtension ModDatosFactura (ID 80108) extends Page 10765.
/// </summary>
pageextension 80108 ModDatosFactura extends 10765
{
    layout
    {
        addafter("Posting Date")
        {
            field("Posting Description"; Rec."Posting Description")
            {
                Caption = 'Texto Factura';
                ApplicationArea = All;
            }
            field("Due Date"; Rec."Due Date")
            {
                Caption = 'Fecha Vencimiento';
                ApplicationArea = All;
                Editable = true;
                trigger OnValidate()
                vaR
                    Control: Codeunit ControlProcesos;
                begin
                    Control.CambiarVto(Rec, Rec."Due Date");
                end;
            }
        }
    }
}
