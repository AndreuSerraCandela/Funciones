pageextension 80158 DocCobro extends "Receivables Cartera Docs"
{
    layout
    {
        addAfter("No.")
        {
            field("C.I.F."; Cif)
            {
                ApplicationArea = All;
            }
            field(Nombre; Name)
            {
                ApplicationArea = All;
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
            field("Id Domiciliación"; Rec."Direct Debit Mandate ID")
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
            field("Global Dimension 2 Code"; Rec."Global Dimension 2 Code")
            {
                ApplicationArea = All;
            }
        }
    }
    actions
    {
        addafter("&Docs.")
        {
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
        }
    }
    trigger OnAfterGetRecord()
    var
        DebitDir: Record "SEPA Direct Debit Mandate";
        Contrato: Record "Sales Header";
        Cliente: Record Customer;
    begin
        Cif := '';
        if Rec.Type = Rec.Type::Receivable Then
            if Customer.Get(Rec."Account No.") Then begin
                Cif := Customer."VAT Registration No.";
                Name := Customer.Name;
            end;
        if Rec.Type = Rec.Type::Payable then
            if Vendor.Get(Rec."Account No.") then begin
                Cif := Vendor."VAT Registration No.";
                Name := Vendor.Name;
            end;
        if Rec."Direct Debit Mandate ID" = '' Then begin
            DebitDir.SetRange("Customer No.", Rec."Account No.");
            if Rec."Cust./Vendor Bank Acc. Code" = '' then begin
                if StrPos(Copystr(Rec."Document No.", 7), '-') > 0 then begin
                    if Contrato.Get(Contrato."Document Type", CopyStr(Rec."Document No.", 1, 11)) Then begin
                        rec."Cust./Vendor Bank Acc. Code" := Contrato."Cust. Bank Acc. Code";
                        if Rec."Cust./Vendor Bank Acc. Code" = '' Then begin
                            Customer.get(Rec."Account No.");
                            Rec."Cust./Vendor Bank Acc. Code" := Customer."Preferred Bank Account Code";
                        end;
                    end else begin
                        Customer.get(Rec."Account No.");
                        Rec."Cust./Vendor Bank Acc. Code" := Customer."Preferred Bank Account Code";
                    end;
                end;
            end;
            DebitDir.SetRange("Customer Bank Account Code", Rec."Cust./Vendor Bank Acc. Code");
            if DebitDir.FindLast() Then Rec."Direct Debit Mandate ID" := DebitDir.ID;
            if StrPos(Copystr(Rec."Document No.", 7), '-') > 0 then begin
                Rec."Direct Debit Mandate ID" := CopyStr(Rec."Document No.", 1, 11);
                DebitDir.SetRange("ID", Rec."Direct Debit Mandate ID");
                if DebitDir.FindFirst() Then begin
                    DebitDir."Valid To" := Rec."Due Date";
                    DebitDir.MODIFY();
                end else begin
                    DebitDir.INIT();
                    DebitDir.ID := Rec."Direct Debit Mandate ID";
                    DebitDir."Customer No." := Rec."Account No.";
                    DebitDir."Customer Bank Account Code" := Rec."Cust./Vendor Bank Acc. Code";
                    DebitDir."Valid From" := Rec."Due Date";
                    if Rec."Due Date" < Rec."Posting Date" then
                        DebitDir."Date of Signature" := Rec."Due Date"
                    else
                        DebitDir."Date of Signature" := Rec."Posting Date";
                    DebitDir."Type of Payment" := DebitDir."Type of Payment"::Recurrent;
                    if Strpos(Rec."No.", '/') > 0 then
                        Evaluate(DebitDir."Expected Number of Debits", CopyStr(Rec."No.", Strpos(Rec."No.", '/') + 1, 100))
                    else
                        DebitDir."Expected Number of Debits" := 1;
                    DebitDir."Debit Counter" := 0;
                    DebitDir."Ignore Exp. Number of Debits" := true;
                    DebitDir."Valid To" := Calcdate(Format(DebitDir."Expected Number of Debits") + 'M', Rec."Due Date");
                    if DebitDir.INSERT() Then;
                end;
            end;
        end;
        Rec.calcfields("Entidad Cliente");
    end;

    var
        Customer: Record Customer;
        Vendor: Record Vendor;
        Cif: Text;
        Name: Text;

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

}