/// <summary>
/// PageExtension ReverseEntry (ID 80174) extends Record Reverse Entries.
/// </summary>
pageextension 80174 ReverseEntry extends "Reverse Transaction Entries"
{

    actions
    {
        modify(Reverse)
        {
            Visible = false;
        }
        modify("Reverse and &Print")
        {
            Visible = false;
        }
        addafter("Reverse and &Print")
        {
            action("Reverse1")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Reverse';
                Image = Undo;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ShortCutKey = 'F9';
                ToolTip = 'Reverse selected entries.';

                trigger OnAction()
                begin
                    Postnew(false);
                end;
            }
            action("Reverse and &Print1")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Reverse and &Print';
                Image = Undo;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ShortCutKey = 'Shift+F9';
                ToolTip = 'Reverse and print selected entries.';

                trigger OnAction()
                begin
                    PostNEW(true);
                end;
            }
        }
    }
    local procedure PostNEW(PrintRegister: Boolean)
    var
        ReversalPost: Codeunit "Reverse";
    begin
        ReversalPost.SetPrint(PrintRegister);
        ReversalPost.Run(Rec);
        CurrPage.Update(false);
        CurrPage.Close;
    end;
}