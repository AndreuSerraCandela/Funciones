page 50154 "SugerenciaMovDiarPagoFactBox"
{
    PageType = ListPart;
    SourceTable = "Bank Statement Matching Buffer";
    SourceTableTemporary = true;
    Caption = 'Sugerencias de Liquidación';
    Editable = false;

    layout

    {

        area(Content)

        {

            repeater(Group)

            {

                field("Match Score"; Rec."Match Score")

                {

                    ApplicationArea = All;

                    StyleExpr = RowStyleTxt;

                }

                field("Account Type"; Rec."Account Type")

                {

                    ApplicationArea = All;

                    StyleExpr = RowStyleTxt;

                }

                field("Account No."; Rec."Account No.")

                {

                    ApplicationArea = All;

                    StyleExpr = RowStyleTxt;

                }

                field("Account Name"; Rec."Account Name")

                {

                    ApplicationArea = All;

                    StyleExpr = RowStyleTxt;

                }

                field("Document No."; Rec."Document No.")

                {

                    ApplicationArea = All;

                    StyleExpr = RowStyleTxt;

                }

                field("Posting Date"; Rec."Posting Date")

                {

                    ApplicationArea = All;

                    StyleExpr = RowStyleTxt;

                }

                field("Remaining Amount"; Rec."Remaining Amount")

                {

                    ApplicationArea = All;

                    StyleExpr = RowStyleTxt;

                }

            }

        }

    }

    var

        CurrentTemplateName: Code[10];

        CurrentBatchName: Code[10];

        CurrentLineNo: Integer;

        MaxMatchScore: Integer;

        RowStyleTxt: Text;

        SelectedLineNo: Integer;

    procedure UpdateFactBox(GenJnlLine: Record "Gen. Journal Line")
    begin
        Rec.DeleteAll();
        CurrentTemplateName := GenJnlLine."Journal Template Name";
        CurrentBatchName := GenJnlLine."Journal Batch Name";
        CurrentLineNo := GenJnlLine."Line No.";

        if GenJnlLine.Amount = 0 then exit;

        BuscarMovimientosClientes(GenJnlLine);

        BuscarMovimientosProveedores(GenJnlLine);
        SortBufferByScore(Rec);
        MaxMatchScore := GetMaxMatchScore(Rec);

        if Rec.FindFirst() then
            SelectedLineNo := Rec."Line No.";
        CurrPage.Update(false);
    end;

    trigger OnAfterGetCurrRecord()
    begin
        if Rec."Line No." <> 0 then
            SelectedLineNo := Rec."Line No.";
    end;

    trigger OnAfterGetRecord()

    begin

        if (Rec."Match Score" > 0) and (Rec."Match Score" = MaxMatchScore) then
            RowStyleTxt := 'Favorable'

        else
            RowStyleTxt := 'Standard';

    end;

    local procedure BuscarMovimientosClientes(GenJnlLine: Record "Gen. Journal Line")

    var

        CustLedgerEntry: Record "Cust. Ledger Entry";

        Customer: Record Customer;

        NextLineNo: Integer;

    begin

        CustLedgerEntry.SetRange(Open, true);

        CustLedgerEntry.SetRange("Remaining Amount", -GenJnlLine.Amount);

        if CustLedgerEntry.FindSet() then
            repeat

                NextLineNo := Rec.Count + 1;

                Rec.Init();

                Rec."Line No." := NextLineNo;

                Rec."Account Type" := Rec."Account Type"::Customer;

                Rec."Account No." := CustLedgerEntry."Customer No.";



                if Customer.Get(CustLedgerEntry."Customer No.") then
                    Rec."Account Name" := Customer.Name;



                case CustLedgerEntry."Document Type" of

                    CustLedgerEntry."Document Type"::Invoice:

                        Rec."Document Type" := Rec."Document Type"::Invoice;

                    CustLedgerEntry."Document Type"::"Credit Memo":

                        Rec."Document Type" := Rec."Document Type"::"Credit Memo";

                    CustLedgerEntry."Document Type"::Payment:

                        Rec."Document Type" := Rec."Document Type"::Payment;

                    CustLedgerEntry."Document Type"::Bill:

                        Rec."Document Type" := Rec."Document Type"::Bill;

                    else begin

                        if CustLedgerEntry."Bill No." <> '' then
                            Rec."Document Type" := Rec."Document Type"::Bill

                        else
                            Rec."Document Type" := Rec."Document Type"::" ";

                    end;

                end;



                Rec."Document No." := CustLedgerEntry."Document No.";

                Rec."Bill No." := CustLedgerEntry."Bill No.";

                if (Rec."Document Type" = Rec."Document Type"::Bill) and (Rec."Bill No." = '') then
                    Rec."Bill No." := CustLedgerEntry."Document No.";

                Rec."Posting Date" := CustLedgerEntry."Posting Date";

                CustLedgerEntry.CalcFields("Remaining Amount");

                Rec."Remaining Amount" := CustLedgerEntry."Remaining Amount";

                Rec."Entry No." := CustLedgerEntry."Entry No.";

                Rec."Match Score" := CalcMatchScoreCustLedger(CustLedgerEntry, GenJnlLine);

                Rec.Insert();

            until CustLedgerEntry.Next() = 0;

    end;



    local procedure BuscarMovimientosProveedores(GenJnlLine: Record "Gen. Journal Line")

    var

        VendorLedgerEntry: Record "Vendor Ledger Entry";

        Vendor: Record Vendor;

        NextLineNo: Integer;

    begin

        VendorLedgerEntry.SetRange(Open, true);

        VendorLedgerEntry.SetRange("Remaining Amount", -GenJnlLine.Amount);

        if VendorLedgerEntry.FindSet() then
            repeat

                NextLineNo := Rec.Count + 1;

                Rec.Init();

                Rec."Line No." := NextLineNo;

                Rec."Account Type" := Rec."Account Type"::Vendor;

                Rec."Account No." := VendorLedgerEntry."Vendor No.";



                if Vendor.Get(VendorLedgerEntry."Vendor No.") then
                    Rec."Account Name" := Vendor.Name;



                case VendorLedgerEntry."Document Type" of

                    VendorLedgerEntry."Document Type"::Invoice:

                        Rec."Document Type" := Rec."Document Type"::Invoice;

                    VendorLedgerEntry."Document Type"::"Credit Memo":

                        Rec."Document Type" := Rec."Document Type"::"Credit Memo";

                    VendorLedgerEntry."Document Type"::Payment:

                        Rec."Document Type" := Rec."Document Type"::Payment;

                    VendorLedgerEntry."Document Type"::Bill:

                        Rec."Document Type" := Rec."Document Type"::Bill;

                    else begin

                        if VendorLedgerEntry."Bill No." <> '' then
                            Rec."Document Type" := Rec."Document Type"::Bill

                        else
                            Rec."Document Type" := Rec."Document Type"::" ";

                    end;

                end;



                Rec."Document No." := VendorLedgerEntry."Document No.";

                Rec."Bill No." := VendorLedgerEntry."Bill No.";

                if (Rec."Document Type" = Rec."Document Type"::Bill) and (Rec."Bill No." = '') then
                    Rec."Bill No." := VendorLedgerEntry."Document No.";

                Rec."Posting Date" := VendorLedgerEntry."Posting Date";

                VendorLedgerEntry.CalcFields("Remaining Amount");

                Rec."Remaining Amount" := VendorLedgerEntry."Remaining Amount";

                Rec."Entry No." := VendorLedgerEntry."Entry No.";

                Rec."Match Score" := CalcMatchScoreVendorLedger(VendorLedgerEntry, GenJnlLine);

                Rec.Insert();

            until VendorLedgerEntry.Next() = 0;

    end;



    procedure GetSelectedRecord(var DestBuffer: Record "Bank Statement Matching Buffer" temporary)
    begin
        DestBuffer.Reset();
        DestBuffer.DeleteAll();

        // CurrPage.GetRecord no devuelve la fila del FactBox al llamar desde el diario.
        if SelectedLineNo <> 0 then
            if Rec.Get(SelectedLineNo) then begin
                DestBuffer := Rec;
                DestBuffer.Insert();
                exit;
            end;

        if Rec."Line No." <> 0 then begin
            DestBuffer := Rec;
            DestBuffer.Insert();
            exit;
        end;

        if Rec.FindFirst() then begin
            DestBuffer := Rec;
            DestBuffer.Insert();
        end;
    end;



    procedure GetBuffer(var DestBuffer: Record "Bank Statement Matching Buffer" temporary)

    begin

        DestBuffer.Reset();

        DestBuffer.DeleteAll();



        if Rec.FindSet() then
            repeat

                DestBuffer.Init();

                DestBuffer := Rec;

                DestBuffer.Insert();

            until Rec.Next() = 0;

    end;



    procedure SetBuffer(var SourceBuffer: Record "Bank Statement Matching Buffer" temporary)

    begin

        Rec.Reset();

        Rec.DeleteAll();



        if SourceBuffer.FindSet() then
            repeat

                Rec.Init();

                Rec := SourceBuffer;

                Rec.Insert();

            until SourceBuffer.Next() = 0;



        MaxMatchScore := GetMaxMatchScore(Rec);



        if Rec.FindFirst() then
            SelectedLineNo := Rec."Line No.";

    end;


    procedure CalcMatchScoreCustLedger(CustLedgerEntry: Record "Cust. Ledger Entry"; GenJnlLine: Record "Gen. Journal Line"): Integer
    var
        Score: Integer;
        JnlDate: Date;
    begin
        Score := 1;

        JnlDate := GetJnlLineDate(GenJnlLine);
        if JnlDate <> 0D then
            if IsDateWithinDays(JnlDate, CustLedgerEntry."Posting Date", 10) or
               IsDateWithinDays(JnlDate, CustLedgerEntry."Due Date", 10)
            then
                Score += 1;

        if ReferenciaEnConcepto(GenJnlLine, CustLedgerEntry."Document No.") then
            Score += 1;
        if ReferenciaEnConcepto(GenJnlLine, CustLedgerEntry."Bill No.") then
            Score += 1;
        if ReferenciaEnConcepto(GenJnlLine, CustLedgerEntry."External Document No.") then
            Score += 1;
        if ReferenciaEnConcepto(GenJnlLine, CustLedgerEntry."Payment Reference") then
            Score += 1;
        if ReferenciaEnConcepto(GenJnlLine, CustLedgerEntry.Description) Then
            Score += 1;
        CustLedgerEntry.CalcFields("Núm Contrato");
        if ReferenciaEnConcepto(GenJnlLine, CustLedgerEntry."Núm Contrato") Then
            Score += 1;
        if ReferenciaEnConcepto(GenJnlLine, CustLedgerEntry."Nº Factura Borrador") Then
            Score += 1;

        if (GenJnlLine."Account Type" = GenJnlLine."Account Type"::Customer) and
           (GenJnlLine."Account No." <> '') and
           (GenJnlLine."Account No." = CustLedgerEntry."Customer No.")
        then
            Score += 1;

        exit(Score);
    end;

    procedure CalcMatchScoreVendorLedger(VendorLedgerEntry: Record "Vendor Ledger Entry"; GenJnlLine: Record "Gen. Journal Line"): Integer
    var
        Score: Integer;
        JnlDate: Date;
    begin
        Score := 1;

        JnlDate := GetJnlLineDate(GenJnlLine);
        if JnlDate <> 0D then
            if IsDateWithinDays(JnlDate, VendorLedgerEntry."Posting Date", 10) or
               IsDateWithinDays(JnlDate, VendorLedgerEntry."Due Date", 10)
            then
                Score += 1;

        if ReferenciaEnConcepto(GenJnlLine, VendorLedgerEntry."Document No.") then
            Score += 1;
        if ReferenciaEnConcepto(GenJnlLine, VendorLedgerEntry."Bill No.") then
            Score += 1;
        if ReferenciaEnConcepto(GenJnlLine, VendorLedgerEntry."External Document No.") then
            Score += 1;
        if ReferenciaEnConcepto(GenJnlLine, VendorLedgerEntry."Payment Reference") then
            Score += 1;
        if ReferenciaEnConcepto(GenJnlLine, VendorLedgerEntry.Description) Then
            Score += 1;


        if (GenJnlLine."Account Type" = GenJnlLine."Account Type"::Vendor) and
           (GenJnlLine."Account No." <> '') and
           (GenJnlLine."Account No." = VendorLedgerEntry."Vendor No.")
        then
            Score += 1;

        exit(Score);
    end;

    procedure SortBufferByScore(var FinMatchingBuffer: Record "Bank Statement Matching Buffer" temporary)
    var
        TempBuffer: Record "Bank Statement Matching Buffer" temporary;
        LineNo, Score, MaxScore : Integer;
    begin
        if not FinMatchingBuffer.FindSet() then
            exit;

        repeat
            TempBuffer := FinMatchingBuffer;
            TempBuffer.Insert();
        until FinMatchingBuffer.Next() = 0;

        MaxScore := GetMaxMatchScore(TempBuffer);

        FinMatchingBuffer.DeleteAll();
        LineNo := 0;

        for Score := MaxScore downto 0 do
            if TempBuffer.FindSet() then
                repeat
                    if TempBuffer."Match Score" = Score then begin
                        LineNo += 1;
                        FinMatchingBuffer := TempBuffer;
                        FinMatchingBuffer."Line No." := LineNo;
                        FinMatchingBuffer.Insert();
                    end;
                until TempBuffer.Next() = 0;
    end;

    procedure GetMaxMatchScore(var FinMatchingBuffer: Record "Bank Statement Matching Buffer" temporary): Integer
    var
        MaxScore: Integer;
    begin
        MaxScore := 0;
        if FinMatchingBuffer.FindSet() then
            repeat
                if FinMatchingBuffer."Match Score" > MaxScore then
                    MaxScore := FinMatchingBuffer."Match Score";
            until FinMatchingBuffer.Next() = 0;
        exit(MaxScore);
    end;

    local procedure GetJnlLineDate(GenJnlLine: Record "Gen. Journal Line"): Date
    begin
        if GenJnlLine."Posting Date" <> 0D then
            exit(GenJnlLine."Posting Date");
        exit(GenJnlLine."Document Date");
    end;

    local procedure IsDateWithinDays(BaseDate: Date; CompareDate: Date; DaysTolerance: Integer): Boolean
    begin
        if CompareDate = 0D then
            exit(false);
        exit(Abs(BaseDate - CompareDate) <= DaysTolerance);
    end;

    local procedure ReferenciaEnConcepto(GenJnlLine: Record "Gen. Journal Line"; Referencia: Text): Boolean
    var
        SearchText: Text;
    begin
        if Referencia = '' then
            exit(false);

        SearchText := UpperCase(GenJnlLine.Description + ' ' + GenJnlLine."Payment Reference" + ' ' + GenJnlLine."External Document No.");
        If (StrPos(SearchText, UpperCase(Referencia)) > 0) then
            exit(true);
        exit(StrPos(UpperCase(Referencia), SearchText) > 0);
    end;
}

