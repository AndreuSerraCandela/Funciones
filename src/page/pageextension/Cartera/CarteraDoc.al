pageextension 80157 CarteraDoc extends "Cartera Documents"
{
    layout
    {
        modify("Posting Date")
        {
            Visible = true;
            ApplicationArea = All;
        }
        modify("Account No.")
        {
            ApplicationArea = All;
        }
        addAfter("No.")
        {

            field(Cuenta; Rec."Account No.")
            {
                ApplicationArea = Basic, Suite;
                Visible = true;
            }


            field("Bill Gr./Pmt. Order No."; Rec."Bill Gr./Pmt. Order No.")
            {
                ApplicationArea = All;
            }
            field("C.I.F."; Cif)
            {
                ApplicationArea = All;
            }
            field(Nombre; Nombre())
            {
                ApplicationArea = All;
            }
            field("Banco"; Rec.Banco)
            {
                ApplicationArea = All;
            }
            field("Banco Cliente/Proveedor"; Rec."Cust./Vendor Bank Acc. Code")
            {
                ApplicationArea = All;
            }

            field("Iban"; Iban)
            {
                ApplicationArea = All;
            }

            field("Entidad Cliente"; Rec."Entidad Cliente")
            {
                ApplicationArea = All;
            }
            field("Entidad Proveedor"; Rec."Entidad Proveedor")
            {
                ApplicationArea = All;
            }
            field("Global Dimension 2 Code"; Rec."Global Dimension 2 Code")
            {
                ApplicationArea = All;
            }
        }
    }


    actions
    {
        addlast("&Docs.")
        {
            action("Eliminar de Cartera")
            {
                ApplicationArea = All;
                Image = "Invoicing-Delete";
                trigger OnAction()
                var
                    controlProcesos: codeunit ControlProcesos;
                begin
                    controlProcesos.EliminarCartera(Rec);
                end;
            }

            action("Cambiar Vencimiento")
            {
                ApplicationArea = All;
                Image = DueDate;
                trigger OnAction()
                var
                    controlProcesos: codeunit Utilitis;
                begin
                    controlProcesos.CambiarVto(Rec);
                end;
            }
        }
    }
    trigger OnAfterGetRecord()
    var
        DebitDir: Record "SEPA Direct Debit Mandate";
    begin
        Cif := '';
        if Rec.Type = Rec.Type::Receivable Then
            if Customer.Get(Rec."Account No.") Then Cif := Customer."VAT Registration No.";
        if Rec.Type = Rec.Type::Payable then
            if Vendor.Get(Rec."Account No.") then Cif := Vendor."VAT Registration No.";
        Rec.calcfields("Entidad Cliente");
    end;

    var
        Customer: Record Customer;
        Vendor: Record Vendor;
        Cif: Text;

    /// <summary>
    /// Iban.
    /// </summary>
    /// <returns>Return value of type Text.</returns>
    procedure Iban(): Text
    var
        cBank: Record "Customer Bank Account";
        vBank: Record "Vendor Bank Account";
    Begin

        if Rec.Type = Rec.Type::Receivable THEN BEGIN
            if not cBank.GET(Rec."Account No.", Rec."Cust./Vendor Bank Acc. Code") THEN
                EXIT(cBank.IBAN);
            cBank.SetRange("Customer No.", rec."Account No.");
            if cBank.FindFirst() Then exit(cBank.IBAN);
        END ELSE BEGIN
            if vBank.GET(Rec."Account No.", Rec."Cust./Vendor Bank Acc. Code") THEN
                EXIT(vBank.IBAN);
            vBank.SetRange("Vendor No.", rec."Account No.");
            if vBank.FindFirst() Then exit(cBank.IBAN);
        END;
    end;

    procedure Nombre(): Text
    var
        c: Record "Customer";
        v: Record "Vendor";
    begin
        if Rec.Type = Rec.Type::Receivable then
            if c.Get(Rec."Account No.") then
                exit(c.Name);
        if Rec.Type = Rec.Type::Payable then
            if v.Get(Rec."Account No.") then
                exit(v.Name);
    end;

}