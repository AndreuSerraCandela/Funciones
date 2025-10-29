pageextension 80154 SubformClCarteraBg extends "Docs. in Closed BG Subform"
{
    layout
    {
        addafter("Remaining Amount")
        {
            field(Cuenta; Rec."Account No.")
            {
                ApplicationArea = Basic, Suite;
                Visible = true;
            }
            field("No. Borrador factura"; Rec."No. Borrador factura")
            {
                ApplicationArea = All;
            }
            field("Banco"; Rec.Banco)
            {
                ApplicationArea = All;
            }
            field("Banco Cliente"; Rec."Cust./Vendor Bank Acc. Code")
            {
                ApplicationArea = All;
            }
            field("C.I.F."; Cif)
            {
                ApplicationArea = All;
            }
            field(Nombre; Customer.Name)
            {
                ApplicationArea = All;
            }
        }
    }
    trigger OnAfterGetRecord()
    begin
        Cif := '';
        if Rec.Type = Rec.Type::Receivable Then
            if Customer.Get(Rec."Account No.") Then Cif := Customer."VAT Registration No.";
        if Rec.Type = Rec.Type::Payable then
            if Vendor.Get(Rec."Account No.") then Cif := Vendor."VAT Registration No.";
    end;

    var
        Cif: Text;
        Customer: Record Customer;
        Vendor: Record Vendor;
}