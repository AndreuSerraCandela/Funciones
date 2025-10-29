pageextension 80109 ClosedBillGroups extends "Closed Bill Groups List"
{
    layout
    {
        addafter("Currency Code")
        {
            field("Fecha Registro"; Rec."Posting Date")
            {
                ApplicationArea = All;
                Visible = true;
            }
            field("Fecha Cierre"; Rec."Closing Date")
            {
                ApplicationArea = All;
                Visible = true;
            }
            field("Al descuento"; Rec."Remesa al descuento")
            {
                ApplicationArea = All;
                Visible = true;
            }
            field("Dealing Type"; Rec."Dealing Type")
            {
                Caption = 'Tipo Gestión';
                ApplicationArea = All;
                Visible = true;
            }
        }
    }
    trigger OnOpenPage()
    begin
        Rec.Ascending := false;
    end;
}