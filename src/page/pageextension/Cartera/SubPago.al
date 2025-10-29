pageextension 80186 SubPago extends "Docs. in PO Subform"
{
    layout
    {
        modify("Posting Date")
        {
            Visible = true;
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
            field(Nombre; Vendor.Name)
            {
                ApplicationArea = All;
            }
            field("Banco"; Rec.Banco)
            {
                ApplicationArea = All;
            }
            field("Banco Proveedor"; Rec."Cust./Vendor Bank Acc. Code")
            {
                ApplicationArea = All;
            }
            field("Doc Externo"; ExtaernalDoc())
            {
                ApplicationArea = All;
            }
            field("Iban"; Iban(Rec))
            {
                ApplicationArea = All;
            }
            field("Entidad Cliente"; Rec."Entidad Cliente")
            {
                ApplicationArea = All;
            }
        }
    }
    actions
    {
        addlast("&Docs.")
        {
            action("Verifica Iban")
            {
                ApplicationArea = All;
                Image = Check;
                trigger OnAction()
                var
                    CarteraDoc: Record "Cartera Doc.";
                    CompaniInfo: Record "Company Information";
                begin
                    CompaniInfo.Get();
                    CurrPage.SetSelectionFilter(CarteraDoc);
                    if CarteraDoc.FindFirst() then
                        repeat
                            CompaniInfo.CheckIBAN(Iban(CarteraDoc));
                        until CarteraDoc.Next() = 0;
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
    /// <param name="Carteradoc">VAR Record "Cartera Doc.".</param>
    /// <returns>Return value of type Text.</returns>
    procedure Iban(var Carteradoc: Record "Cartera Doc."): Text
    var
        cBank: Record "Customer Bank Account";
        vBank: Record "Vendor Bank Account";
    Begin

        if Rec.Type = Rec.Type::Receivable THEN BEGIN
            if not cBank.GET(Carteradoc."Account No.", Carteradoc."Cust./Vendor Bank Acc. Code") THEN
                EXIT(cBank.IBAN);
            cBank.SetRange("Customer No.", Carteradoc."Account No.");
            if cBank.FindFirst() Then exit(cBank.IBAN);
        END ELSE BEGIN
            if vBank.GET(Carteradoc."Account No.", Carteradoc."Cust./Vendor Bank Acc. Code") THEN
                EXIT(vBank.IBAN);
            vBank.SetRange("Vendor No.", Carteradoc."Account No.");
            if vBank.FindFirst() Then exit(cBank.IBAN);
        END;
    end;

    local procedure ExtaernalDoc(): Text[50]
    var
        VendorEntry: Record "Vendor Ledger Entry";
    begin
        if VendorEntry.Get(Rec."Entry No.") Then Exit(VendorEntry."External document no.")
    end;

}