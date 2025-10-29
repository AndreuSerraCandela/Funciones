pageextension 80147 LiqRemesas extends "Docs. in Posted BG Subform"
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
            field("Iban"; Iban)
            {
                ApplicationArea = All;
            }
            field("Entidad Cliente"; Rec."Entidad Cliente")
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
    actions
    {
        modify("Total Settlement")
        {
            visible = false;
        }
        addafter("Total Settlement")
        {
            action("Liquidación Total")
            {
                ApplicationArea = Basic, Suite;
                //Caption = 'Total Settlement';
                Ellipsis = true;
                ToolTip = 'View posted documents that were settled fully.';

                trigger OnAction()
                begin
                    SettleDocsNuevo();
                end;
            }
            action("Asignar factura Borrador")
            {
                Image = "Invoicing-Document";
                ApplicationArea = All;
                trigger OnAction()
                var
                    ControlProcesos: Codeunit ControlProcesos;
                    Docs: Record "Posted Cartera Doc.";
                begin
                    CurrPage.SetSelectionFilter(Docs);
                    ControlProcesos.AsignarFacturaBorrador(Docs);
                end;
            }
            action("Asignar Banco Cliente")
            {
                Image = "Invoicing-Document";
                ApplicationArea = All;
                trigger OnAction()
                var
                    ControlProcesos: Codeunit ControlProcesos;
                    Docs: Record "Posted Cartera Doc.";
                begin
                    CurrPage.SetSelectionFilter(Docs);
                    ControlProcesos.AsignarBancoCliente(Docs);
                end;
            }
            action("Recircular factura borrdor")
            {
                Image = "Invoicing-Document";
                ApplicationArea = All;
                trigger OnAction()
                var
                    ControlProcesos: Codeunit ControlProcesos;
                    Docs: Record "Posted Cartera Doc.";
                begin
                    CurrPage.SetSelectionFilter(Docs);
                    ControlProcesos.RecircularFacturaBorrador(Docs);
                end;
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
        Rec.calcfields("Entidad Cliente");
    end;
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

    var
        Customer: Record Customer;
        Vendor: Record Vendor;
        Cif: Text;

    /// <summary>
    /// SettleDocsNuevo.
    /// </summary>
    procedure SettleDocsNuevo()
    var
        PostedDoc: Record "Posted Cartera Doc.";
        Total: Decimal;
        ProcesoCancelado: Label 'Proceso cancelado por el usuario';
    begin
        CurrPage.SetSelectionFilter(PostedDoc);
        if not PostedDoc.Find('=><') then
            exit;

        PostedDoc.SetRange(Status, PostedDoc.Status::Open);
        if not PostedDoc.Find('-') then
            Error(
              Text1100000 +
              Text1100001);
        repeat
            Total += PostedDoc."Remaining Amount";
        until PostedDoc.Next() = 0;
        if Confirm('¿El importe total de la liquidación es ' + FORMAT(Total) + ', quier contiuar?') then
            REPORT.RunModal(REPORT::"Settle Docs. Bill Gr. Malla", true, false, PostedDoc)
        else
            Error(ProcesoCancelado);
        //REPORT.RunModal(REPORT::"Settle Docs. Bill Gr. Malla", true, false, PostedDoc);
        CurrPage.Update(false);
    end;

    var
        Text1100000: Label 'No se han encontrado documentos para liquidad. \';
        Text1100001: Label 'Compruebe que haya algun documento pendiente.';
}