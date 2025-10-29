/// <summary>
/// PageExtension MovCli (ID 80136) extends Record Customer Ledger Entries.
/// </summary>
pageextension 80136 MovCli extends "Customer Ledger Entries"
{
    layout
    {
        addafter("Currency Code")
        {
            field("Nº Contrato"; Rec."Núm Contrato")
            {
                ApplicationArea = All;
            }
            field("Transaction No."; Rec."Transaction No.")
            {
                ApplicationArea = All;
            }

        }
        addafter("Bal. Account No.")
        {
            field(Banco; Rec.Banco)
            {
                ApplicationArea = ALL;
            }
        }
    }
    actions
    {
        addafter(ReverseTransaction)
        {
            group(Reclamaciones)
            {
                action("Reclamar Documento")
                {
                    ApplicationArea = All;
                    Image = Reminder;
                    Scope = Repeater;
                    Caption = 'Reclamar Documento';
                    trigger OnAction()
                    Var
                        rRem: Record 296;
                        rCabRem: Record 295;
                        r18: Record Customer;
                        r5054: Record 5054;
                        a: Integer;
                    BEGIN
                        if Reclamada THEN ERROR('La factura ya está reclamada');
                        rCabRem.SETRANGE(rCabRem."Customer No.", Rec."Customer No.");
                        r5054.SETRANGE(r5054."Link to Table", r5054."Link to Table"::Customer);
                        r5054.SETRANGE(r5054."No.", Rec."Customer No.");
                        r5054.FINDFIRST;
                        r18.GET(Rec."Customer No.");
                        r18.TESTFIELD(r18."Reminder Terms Code");
                        if NOT rCabRem.FINDLAST THEN BEGIN
                            rCabRem.INIT;
                            rCabRem."No." := '';
                            rCabRem."Customer No." := Rec."Customer No.";
                            rCabRem."Contact No." := r5054."Contact No.";
                            rCabRem.INSERT(TRUE);
                            rCabRem.VALIDATE(rCabRem."Customer No.", Rec."Customer No.");
                            rCabRem.VALIDATE("Reminder Terms Code", r18."Reminder Terms Code");
                            rCabRem.MODIFY(TRUE);
                        END;
                        rRem.SETRANGE(rRem."Reminder No.", rCabRem."No.");
                        if rRem.FINDLAST THEN a := rRem."Line No." ELSE a := 0;
                        rRem.INIT;
                        rRem."Reminder No." := rCabRem."No.";
                        rRem."Line No." := a + 10000;
                        rRem.Type := rRem.Type::"Customer Ledger Entry";
                        rRem.VALIDATE("Entry No.", Rec."Entry No.");
                        rRem.INSERT(TRUE);
                        COMMIT;
                        rCabRem.CreateTodo;
                    END;
                }
                action("Ver Reclamación")
                {
                    ApplicationArea = All;
                    Image = ShowSelected;
                    Caption = 'Ver Reclamación';
                    Scope = Repeater;
                    trigger OnAction()
                    Var
                        rRem: Record 296;
                        rCabRem: Record 295;
                        r18: Record Customer;
                        r5054: Record 5054;
                        a: Integer;
                    BEGIN
                        if NOT Reclamada THEN ERROR('La factura no está reclamada');
                        rCabRem.SETRANGE(rCabRem."Customer No.", Rec."Customer No.");
                        r5054.SETRANGE(r5054."Link to Table", r5054."Link to Table"::Customer);
                        r5054.SETRANGE(r5054."No.", Rec."Customer No.");
                        r5054.FINDFIRST;
                        r18.GET(Rec."Customer No.");
                        r18.TESTFIELD(r18."Reminder Terms Code");
                        if rCabRem.FINDLAST THEN
                            PAge.RUNMODAL(0, rCabRem);
                    END;
                }
            }
            group(SII)
            {
                action("Regenerar SII como nuevo")
                {
                    ApplicationArea = All;
                    Scope = Repeater;
                    Caption = 'Regenerar SII como nuevo';
                    Image = NewInvoice;
                    trigger OnAction()
                    var
                        GestiónSII: Report "Gestión SII";
                        Dk: Enum "Document Type Kuara";
                    Begin
                        Case Rec."Document Type" Of

                            Rec."Document Type"::" ", Rec."Document Type"::Advance:
                                Dk := Dk::" ";
                            Rec."Document Type"::Bill:
                                Dk := Dk::Bill;
                            Rec."Document Type"::"Credit Memo":
                                Dk := Dk::"Credit Memo";
                            Rec."Document Type"::"Finance Charge Memo":
                                Dk := Dk::"Finance Charge Memo";
                            Rec."Document Type"::Invoice:
                                Dk := Dk::Invoice;
                            Rec."Document Type"::Payment:
                                Dk := Dk::Payment;
                            Rec."Document Type"::Receipt:
                                Dk := Dk::Albaran;
                            Rec."Document Type"::Refund:
                                Dk := Dk::Refund;
                            Rec."Document Type"::Reminder:
                                Dk := Dk::Reminder;

                        End;

                        //-SII1
                        GestiónSII.SetRegeneracion(2, Rec."Document No.", DK, Rec."Posting Date", Rec."Currency Code", TRUE);
                        GestiónSII.RUN;
                        //+SII1
                    END;
                }
                action("Regenear documento SII")
                {
                    ApplicationArea = All;
                    Caption = 'Regenear documento SII';
                    Image = ReferenceData;
                    trigger OnAction()
                    var
                        GestiónSII: Report "Gestión SII";
                        Dk: Enum "Document Type Kuara";
                    Begin
                        Case Rec."Document Type" Of

                            Rec."Document Type"::" ", Rec."Document Type"::Advance:
                                Dk := Dk::" ";
                            Rec."Document Type"::Bill:
                                Dk := Dk::Bill;
                            Rec."Document Type"::"Credit Memo":
                                Dk := Dk::"Credit Memo";
                            Rec."Document Type"::"Finance Charge Memo":
                                Dk := Dk::"Finance Charge Memo";
                            Rec."Document Type"::Invoice:
                                Dk := Dk::Invoice;
                            Rec."Document Type"::Payment:
                                Dk := Dk::Payment;
                            Rec."Document Type"::Receipt:
                                Dk := Dk::Albaran;
                            Rec."Document Type"::Refund:
                                Dk := Dk::Refund;
                            Rec."Document Type"::Reminder:
                                Dk := Dk::Reminder;

                        End;
                        //-SII
                        //-SII1
                        //GestiónSII.RegenerarFichero(0,"Document No.","Document Type","Posting Date","Currency Code");
                        GestiónSII.SetRegeneracion(0, Rec."Document No.", DK, Rec."Posting Date", Rec."Currency Code", TRUE);
                        GestiónSII.RUN;
                        //+SII1
                        //+SII
                    END;
                }
                action("Cancelar documento SII")
                {
                    ApplicationArea = All;
                    Image = CancelLine;
                    Caption = 'Cancelar documento SII';
                    trigger OnAction()
                    var
                        GestiónSII: Report "Gestión SII";
                        Dk: Enum "Document Type Kuara";
                    Begin
                        Case Rec."Document Type" Of

                            Rec."Document Type"::" ", Rec."Document Type"::Advance:
                                Dk := Dk::" ";
                            Rec."Document Type"::Bill:
                                Dk := Dk::Bill;
                            Rec."Document Type"::"Credit Memo":
                                Dk := Dk::"Credit Memo";
                            Rec."Document Type"::"Finance Charge Memo":
                                Dk := Dk::"Finance Charge Memo";
                            Rec."Document Type"::Invoice:
                                Dk := Dk::Invoice;
                            Rec."Document Type"::Payment:
                                Dk := Dk::Payment;
                            Rec."Document Type"::Receipt:
                                Dk := Dk::Albaran;
                            Rec."Document Type"::Refund:
                                Dk := Dk::Refund;
                            Rec."Document Type"::Reminder:
                                Dk := Dk::Reminder;

                        End;
                        //-SII
                        GestiónSII.RegenerarFichero(1, Rec."Document No.", Dk, Rec."Posting Date", Rec."Currency Code");
                        //+SII
                    END;
                }
            }
        }



    }
    VAR
        rMov2: Record 21;
        Text000: Label 'Documento';

    PROCEDURE MOV558(): Boolean;
    VAR
        r17: Record "G/L Entry";
    BEGIN
        if NOT r17.GET(Rec."Entry No.") THEN EXIT(FALSE);
        if r17."G/L Account No." = '555000088' THEN EXIT(TRUE);
    END;

    PROCEDURE MOV558B(): Boolean;
    VAR
        r17: Record "G/L Entry";
    BEGIN
        if NOT r17.GET(Rec."Entry No.") THEN EXIT(TRUE);
        if r17."G/L Account No." = '555000088' THEN EXIT(TRUE);
        if (COPYSTR(r17."G/L Account No.", 1, 2) <> '43') AND (COPYSTR(r17."G/L Account No.", 1, 2) <> '44') THEN EXIT(TRUE);
        Rec.CALCFIELDS("Amount (LCY)");
        if Rec."Amount (LCY)" <> r17.Amount THEN EXIT(TRUE);
    END;

    PROCEDURE ELIMOV558(): Boolean;
    VAR
        r17: Record "G/L Entry";
        r379: Record 379;
    BEGIN
        if MOV558 THEN BEGIN
            r17.SETCURRENTKEY(r17."Transaction No.");
            if r17.GET(Rec."Entry No.") THEN BEGIN
                r17.SETRANGE(r17."Transaction No.", r17."Transaction No.");
                r17.CALCSUMS(Amount);
                if r17.Amount <> 0 THEN ERROR('ojo');
                r17.DELETEALL;
            END;
            r379.SETCURRENTKEY(r379."Cust. Ledger Entry No.");
            r379.SETRANGE(r379."Cust. Ledger Entry No.", Rec."Entry No.");
            r379.DELETEALL;
            Rec.DELETE;
        END;
    END;

    PROCEDURE AMostrar(VAR r21: Record 21);
    BEGIN
        Rec.COPY(r21);
        Rec.MARKEDONLY := TRUE;
        CurrPage.UPDATE(FALSE);
    END;

    PROCEDURE Reclamada(): Boolean;
    VAR
        rRem: Record 296;
        rRemR: Record 298;
    BEGIN
        Rec.CALCFIELDS("Remaining Amount");
        if Rec."Remaining Amount" = 0 THEN EXIT(FALSE);
        rRem.SETRANGE(rRem."Entry No.", Rec."Entry No.");
        if rRem.FINDFIRST THEN EXIT(TRUE);
        rRemR.SETRANGE(rRemR."Entry No.", Rec."Entry No.");
        if rRemR.FINDFIRST THEN EXIT(TRUE);
        EXIT(FALSE);
    END;
}