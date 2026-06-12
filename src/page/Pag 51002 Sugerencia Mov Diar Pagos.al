page 50155 "SugerenciaMovDiarPago"
{
    PageType = List; // Es una lista completa para tener botones
    SourceTable = "Bank Statement Matching Buffer";
    SourceTableTemporary = true;
    Caption = 'Seleccionar Movimiento a Vincular';
    Editable = false;
    InsertAllowed = false;
    DeleteAllowed = false;
    ModifyAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Account Type"; Rec."Account Type")
                {
                    ApplicationArea = All;
                }
                field("Account No."; Rec."Account No.")
                {
                    ApplicationArea = All;
                }
                field("Account Name"; Rec."Account Name")
                {
                    ApplicationArea = All;
                }
                field("Document Type"; Rec."Document Type")
                {
                    ApplicationArea = All;
                }
                field("Document No."; Rec."Document No.")
                {
                    ApplicationArea = All;
                }
                field("Bill No."; Rec."Bill No.")
                {
                    ApplicationArea = All;
                }
                field("Posting Date"; Rec."Posting Date")
                {
                    ApplicationArea = All;
                }
                field("Remaining Amount"; Rec."Remaining Amount")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    // El mismo inyector que usamos antes
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
        if Rec.FindFirst() then;
    end;
}