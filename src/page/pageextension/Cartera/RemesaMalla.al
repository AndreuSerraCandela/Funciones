/// <summary>
/// PageExtension RemesaMalla (ID 80127) extends Record 7000009.
/// </summary>
pageextension 80127 RemesaMalla extends "Bill Groups"
{
    layout
    {
        addafter("Dealing Type")
        {
            field("Remesa al descuento"; Rec."Remesa al descuento")
            {
                ApplicationArea = All;
                Editable = true;
            }
        }
        addafter("File Export Errors")
        {
            part("File Export Errors General"; "Payment Journal Errors Part")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'File Export Errors';
                Provider = Docs;
                SubPageLink = "Journal Template Name" = FILTER(''),
                              "Journal Batch Name" = FILTER('7000005'),
                              "Document No." = FIELD("Bill Gr./Pmt. Order No.");
            }
        }
    }

    actions
    {
        modify("Post")
        {
            visible = false;
        }
        addafter(Post)
        {
            action(Registrar)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'R&egistrar';
                Ellipsis = true;
                Image = Post;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ShortCutKey = 'F9';
                ToolTip = 'Post the documents to indicate that they are ready to submit to the bank for payment or collection. ';

                trigger OnAction()
                begin
                    if Rec.Find then
                        ReceivablePostOnly(Rec);
                end;
            }
        }

        addafter(ExportToFile)
        {
            action("Export to file Malla")
            {
                ApplicationArea = All;
                Image = ExportToBank;
                trigger OnAction()
                begin
                    Rec.ExportToFileMalla();
                end;
            }
            action("Corregir Mandatos Sepa")
            {
                ApplicationArea = All;
                Image = BankAccountStatement;
                trigger OnAction()
                var
                    Docs: Record "Cartera Doc.";
                    Sepa: Record "SEPA Direct Debit Mandate";
                    Cust: Record Customer;
                    BamkCustomer: Record "Customer Bank Account";
                begin
                    Docs.SetRange("Bill Gr./Pmt. Order No.", Rec."No.");
                    if Docs.FindSet() then
                        repeat
                            if Docs."Direct Debit Mandate ID" <> '' then begin
                                Sepa.Get(Docs."Direct Debit Mandate ID");
                                //Error 1 : No hay banco
                                if Sepa."Customer Bank Account Code" = '' then begin
                                    Cust.Get(Docs."Account No.");
                                    BamkCustomer.SetRange("Customer No.", Cust."No.");
                                    if BamkCustomer.FindFirst() then begin
                                        Sepa."Customer Bank Account Code" := BamkCustomer.Code;
                                        if Cust."Preferred Bank Account Code" <> '' then
                                            Sepa."Customer Bank Account Code" := Cust."Preferred Bank Account Code";
                                        Sepa.MODIFY();
                                    end;
                                end;
                                //Error 2 : Fecha de firma posterior a la fecha de vencimiento
                                if Sepa."Date of Signature" > Docs."Due Date" then begin
                                    Sepa."Date of Signature" := Docs."Due Date";
                                    Sepa.MODIFY();
                                end;
                                //Error 3 : Fecha de fin de validez anterior a la fecha de vencimiento
                                if Sepa."Valid To" < Docs."Due Date" then begin
                                    Sepa."Valid To" := Docs."Due Date";
                                    Sepa.MODIFY();
                                end;
                                //Error 4 : Fecha de inicio de validez posterior a la fecha de vencimiento
                                if Sepa."Valid from" > Docs."Due Date" then begin
                                    Sepa."Valid from" := Docs."Due Date";
                                    Sepa.MODIFY();
                                end;
                            end;

                        until docs.next() = 0;
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
                begin
                    Docs.SetRange("Bill Gr./Pmt. Order No.", Rec."No.");
                    Rec."Partner Type" := Rec."Partner Type"::Person;
                    Rec.Modify();
                    if Docs.FindSet() then
                        repeat
                            If Cust.Get(Docs."Account No.") Then begin
                                Cust."Partner Type" := Cust."Partner Type"::Person;

                                Cust.MODIFY();
                            end;

                        until docs.next() = 0;
                end;
            }
            action("Convertir en core Todo")
            {
                ApplicationArea = All;
                Image = CustomerRating;
                trigger OnAction()
                var
                    Docs: Record "Cartera Doc.";
                    Cust: Record Customer;
                    BamkCustomer: Record "Customer Bank Account";
                begin
                    Rec."Partner Type" := Rec."Partner Type"::Person;
                    Rec.Modify();
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
    /// <summary>
    /// ReceivablePostOnly.
    /// </summary>
    /// <param name="BillGr">Record "Bill Group".</param>
    procedure ReceivablePostOnly(BillGr: Record "Bill Group")
    begin
        if BillGr."No. Printed" = 0 then begin
            if not Confirm(Text1100000) then
                Error(Text1100001);
        end else
            if not Confirm(Text1100002, false) then
                Error(Text1100001);

        BillGr.SetRecFilter();
        REPORT.RunModal(REPORT::"Post Bill Group Malla", BillGr."Dealing Type" = BillGr."Dealing Type"::Discount, false, BillGr);
    end;

    var
        Text1100000: Label 'Esta Remesa no está impresa. Quiere continuar?';
        Text1100001: Label 'El proceso ha sido cancelado por el usuario.';
        Text1100002: Label 'Quiere registrar la remesa?';
        Text1100003: Label 'ThisOrden de pago no está impresa. Quiere continuar?';
        Text1100004: Label 'Quiere registrar la Orden de pago?';
        Name: Text;
        ProcesoCancelado: Label 'Proceso cancelado por el usuario';
}