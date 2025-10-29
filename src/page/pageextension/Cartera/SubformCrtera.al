pageextension 80148 SubformCrtera extends "Docs. in BG Subform"
{
    layout
    {
        modify("Remaining Amount")
        {
            Editable = true;
        }
        modify("Original Amount")
        {
            Visible = true;
        }
        modify("Direct Debit Mandate ID")
        {
            Visible = true;
            StyleExpr = Color;
        }
        addafter("Remaining Amount")
        {
            field(Cuenta; Rec."Account No.")
            {
                ApplicationArea = Basic, Suite;
                Visible = true;
            }
            field("C.I.F."; Cif)
            {
                ApplicationArea = All;
            }
            field("Cust./Vendor Bank Acc. Code"; Rec."Cust./Vendor Bank Acc. Code")
            {
                ApplicationArea = All;
            }
            field(Nombre; Customer.Name)
            {
                ApplicationArea = All;
            }

        }
    }
    actions
    {
        addlast("&Docs.")
        {
            action("Modificar Vto.")
            {
                ApplicationArea = All;
                Image = ChangeDate;
                trigger OnAction()
                var
                    Control: Codeunit Utilitis;
                Begin
                    Control.ModificaFecha(Rec);


                End;
            }
            action("Asignar factura Borrador")
            {
                Image = "Invoicing-Document";
                ApplicationArea = All;
                trigger OnAction()
                var
                    ControlProcesos: Codeunit ControlProcesos;
                    Docs: Record "Cartera Doc.";
                begin
                    CurrPage.SetSelectionFilter(Docs);
                    ControlProcesos.AsignarFacturaBorrador(Docs);
                end;
            }
            action("Arreglar Mandato")
            {
                ApplicationArea = All;
                Image = "Invoicing-Document";
                trigger OnAction()
                var
                    ControlProcesos: Codeunit ControlProcesos;
                begin
                    ControlProcesos.ArreglarMandato(Rec, false);
                end;
            }
            action("Arreglar Mandatos Remesa")
            {
                ApplicationArea = All;
                Image = SpecialOrder;
                trigger OnAction()
                var
                    ControlProcesos: Codeunit ControlProcesos;
                begin
                    ControlProcesos.ArreglarMandato(Rec, true);
                end;
            }
            action("Convertir en core")
            {
                ApplicationArea = All;
                Image = CustomerRating;
                trigger OnAction()
                var
                    Docs: Record "Cartera Doc.";
                    Cust: Record Customer;
                    BamkCustomer: Record "Customer Bank Account";
                    Bo: Record "Bill Group";

                begin

                    Docs.SetRange("Bill Gr./Pmt. Order No.", Rec."Bill Gr./Pmt. Order No.");
                    Bo.Get(Rec."Bill Gr./Pmt. Order No.");
                    Bo."Partner Type" := Bo."Partner Type"::Person;
                    Bo.Modify();
                    if Docs.FindSet() then
                        repeat
                            If Cust.Get(Docs."Account No.") Then begin
                                Cust."Partner Type" := Cust."Partner Type"::Person;

                                Cust.MODIFY();
                            end;

                        until docs.next() = 0;
                end;
            }


        }
    }

    trigger OnAfterGetRecord()
    var
        DebirMandate: Record "SEPA Direct Debit Mandate";
    begin
        Cif := '';
        if Rec.Type = Rec.Type::Receivable Then
            if Customer.Get(Rec."Account No.") Then Cif := Customer."VAT Registration No.";
        if Rec.Type = Rec.Type::Payable then
            if Vendor.Get(Rec."Account No.") then Cif := Vendor."VAT Registration No.";
        if Rec."Direct Debit Mandate ID" <> '' then begin
            DebirMandate.Get(Rec."Direct Debit Mandate ID");
            if DebirMandate."Valid from" > Rec."Due Date" then
                Color := 'Unfavorable';
            if DebirMandate."Valid To" < Rec."Due Date" then
                Color := 'Unfavorable';
            if DebirMandate."Date of Signature" > Rec."Due Date" then
                Color := 'Unfavorable';
            If DebirMandate."Customer Bank Account Code" = '' Then
                Color := 'Unfavorable';
        end else
            Color := 'Unfavorable';
    end;

    var
        Customer: Record Customer;
        Vendor: Record Vendor;
        Cif: Text;
        Color: Text;
}