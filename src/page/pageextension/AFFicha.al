/// <summary>
/// PageExtension AFFicha (ID 80190) extends Record Fixed Asset Card.
/// </summary>
pageextension 80190 AFFicha extends "Fixed Asset Card"
{
    layout
    {
        addafter(DepreciationStartingDate)
        {
            field("% Lineal"; FADepreciationBook."Straight-Line %")
            {
                ApplicationArea = FixedAssets;

                trigger OnValidate()
                begin
                    LoadFADepreciationBooks();
                    FADepreciationBook.Validate("Straight-Line %");
                    SaveSimpleDepreciationBook(xRec."No.");
                    //ShowAcquisitionNotification();
                end;
            }
        }
    }
}
pageextension 80192 AfList extends 5601
{
    layout
    {
        addafter("Budgeted Asset")
        {
            field("Valor Neto"; ValorNeto())
            {
                ApplicationArea = All;
                trigger OnDrillDown()
                var
                    FaLedgerEntry: Record "FA Ledger Entry";
                begin
                    FaLedgerEntry.SetRange("FA No.", Rec."No.");
                    Page.RunModal(Page::"FA Ledger Entries", FaLedgerEntry);
                end;
            }
            field("Pendiente Amortizar"; Pendiente())
            {
                ApplicationArea = All;
                trigger OnDrillDown()
                var
                    FaLedgerEntry: Record "FA Ledger Entry";
                begin
                    FaLedgerEntry.SetRange("FA No.", Rec."No.");
                    Page.RunModal(Page::"FA Ledger Entries", FaLedgerEntry);
                end;
            }
        }
    }
    var
        FaLedgerEntry: Record "FA Ledger Entry";
        FaSetup: Record "FA Setup";

    local procedure ValorNeto(): Decimal
    begin
        // CalcFormula = sum("FA Ledger Entry".Amount where("FA No." = field("FA No."),
        // "Depreciation Book Code" = field("Depreciation Book Code"),
        // "Part of Book Value" = const(true),
        // "FA Posting Date" = field("FA Posting Date Filter")));
        FaSetup.Get();
        FaLedgerEntry.SetRange("FA No.", Rec."No.");
        FaLedgerEntry.SetRange("Part of Book Value", true);
        if Rec.GetFilter("FA Posting Date Filter") <> '' then
            FaLedgerEntry.SetRange("FA Posting Date", Rec."FA Posting Date Filter");
        FaLedgerEntry.SetRange("Depreciation Book Code", FaSetup."Default Depr. Book");
        if FaLedgerEntry.FindFirst() then begin
            FaLedgerEntry.CalcSums("Amount");
            exit(FaLedgerEntry."Amount");
        end;
        exit(0);
    end;

    local procedure Pendiente(): Decimal
    var
        ValorPendiente: Decimal;
    begin
        // CalcFormula = sum("FA Ledger Entry".Amount where("FA No." = field("FA No."),
        //     "Depreciation Book Code" = field("Depreciation Book Code"),
        //     "FA Posting Category" = const(" "),
        //     "FA Posting Type" = const("Acquisition Cost"),
        //     "FA Posting Date" = field("FA Posting Date Filter")));
        // CalcFormula = sum("FA Ledger Entry".Amount where("FA No." = field("FA No."),
        //     "Depreciation Book Code" = field("Depreciation Book Code"),
        //     "FA Posting Category" = const(" "),
        //     "FA Posting Type" = const(Depreciation),
        //     "FA Posting Date" = field("FA Posting Date Filter")));
        FaSetup.Get();
        FaLedgerEntry.SetRange("FA No.", Rec."No.");
        FaLedgerEntry.SetRange("FA Posting Category", FaLedgerEntry."FA Posting Category"::" ");
        FaLedgerEntry.SetRange("FA Posting Type", FaLedgerEntry."FA Posting Type"::"Acquisition Cost");
        if Rec.GetFilter("FA Posting Date Filter") <> '' then
            FaLedgerEntry.SetRange("FA Posting Date", Rec."FA Posting Date Filter");
        FaLedgerEntry.SetRange("Depreciation Book Code", FaSetup."Default Depr. Book");
        if FaLedgerEntry.FindFirst() then begin
            FaLedgerEntry.CalcSums("Amount");
            ValorPendiente := FaLedgerEntry."Amount";
        end;
        FaLedgerEntry.SetRange("FA No.", Rec."No.");
        FaLedgerEntry.SetRange("FA Posting Category", FaLedgerEntry."FA Posting Category"::" ");
        FaLedgerEntry.SetRange("FA Posting Type", FaLedgerEntry."FA Posting Type"::Depreciation);
        if Rec.GetFilter("FA Posting Date Filter") <> '' then
            FaLedgerEntry.SetRange("FA Posting Date", Rec."FA Posting Date Filter");
        FaLedgerEntry.SetRange("Depreciation Book Code", FaSetup."Default Depr. Book");
        if FaLedgerEntry.FindFirst() then begin
            FaLedgerEntry.CalcSums("Amount");
            ValorPendiente := ValorPendiente + FaLedgerEntry."Amount";
        end;
        exit(ValorPendiente);

    end;
}