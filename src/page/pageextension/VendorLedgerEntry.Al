/// <summary>
/// PageExtension MovProveedor (ID 80151) extends Record Vendor Ledger Entries.
/// </summary>
pageextension 80151 MovProveedor extends "Vendor Ledger Entries"
{
    layout
    {
        addafter("Payment Method Code")
        {
            field(Banco; Rec.Banco)
            {
                ApplicationArea = All;
            }
        }
    }
    actions
    {
        addlast(processing)
        {
            action("Generar Pagaré")
            {
                Image = VendorBill;
                ApplicationArea = all;
                Scope = Repeater;
                trigger OnAction()
                var
                    r81: Record "Gen. Journal Line";
                    r25: Record 25;
                    a: Integer;

                Begin

                    CurrPage.SETSELECTIONFILTER(r25);
                    if r25.FINDFIRST THEN
                        REPEAT
                            r81.SETRANGE(r81."Journal Template Name", 'CARTERA');
                            r81.SETRANGE(r81."Journal Batch Name", 'GENERICO');
                            if r81.FINDLAST THEN a := r81."Line No.";
                            r81.INIT;
                            r81."Journal Template Name" := 'CARTERA';
                            r81."Journal Batch Name" := 'GENERICO';
                            r81."Line No." := a + 10000;
                            r81."Account Type" := r81."Account Type"::Vendor;
                            r81.VALIDATE("Account No.", r25."Vendor No.");
                            r81.VALIDATE("Posting Date", WORKDATE);
                            r81."Document Type" := r81."Document Type"::Payment;
                            r81."Document No." := r25."Document No.";
                            r81.Description := r25.Description;
                            r25.CALCFIELDS(r25."Remaining Amount");
                            r81.VALIDATE("Debit Amount", -r25."Remaining Amount");
                            r81."Applies-to Doc. Type" := r81."Applies-to Doc. Type"::Invoice;
                            r81."Applies-to Doc. No." := r25."Document No.";
                            r81.INSERT;
                            r81."Line No." := a + 20000;
                            r81."Document Type" := r81."Document Type"::Bill;
                            r81."Bill No." := '1';
                            r81.VALIDATE("Credit Amount", r81."Debit Amount");
                            r81."Applies-to Doc. Type" := r81."Applies-to Doc. Type"::" ";
                            r81."Applies-to Doc. No." := '';
                            r81."Payment Method Code" := 'EMISION';
                            r81."Due Date" := r25."Due Date";
                            r81.INSERT;

                        UNTIL r25.NEXT = 0;
                    MESSAGE('Proceso concluido');
                end;
            }
            action(Marcar)
            {
                ApplicationArea = all;

                trigger OnAction()
                BEGIN
                    Rec.MARK := NOT Rec.MARK;
                End;
            }
            group(SII)
            {

                action("Envias SII Criterio Caja")
                {
                    ApplicationArea = all;
                    Scope = Repeater;
                    Image = TaxPayment;
                    trigger OnAction()
                    var
                        GestiónSII: Codeunit GestionSii;
                    begin
                        "GestiónSII".CreatePayMent(Rec);

                    end;
                }

            }
        }
    }
    trigger OnOpenPage()
    begin
        Rec.SetCurrentKey("Vendor No.", "Posting Date");
    end;
}