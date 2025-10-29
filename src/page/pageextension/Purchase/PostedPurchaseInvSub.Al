/// <summary>
/// PageExtension PostedPurchInvoiceSubPage (ID 80249).
/// </summary>
pageextension 80117 PostedPurchInvoiceSubPage Extends "Posted Purch. Invoice Subform"
{
    layout
    {
        addafter("No.")
        {
            field("Nº Pedido"; Pedido)
            {
                ApplicationArea = All;
                trigger OnDrillDown()
                var
                    PurchaseHeader: Record 38;
                begin
                    PurchaseHeader.SetRange("No.", Pedido);
                    Page.RunModal(0, PurchaseHeader);
                end;
            }
            field("Nº Albarán"; Rec."Receipt No.")
            {
                ApplicationArea = All;
            }
        }

    }

    Procedure Pedido(): Text
    var
        PurchaseRec: Record "Purch. Rcpt. Header";
    begin
        if PurchaseRec.Get(Rec."Receipt No.") Then Exit(PurchaseRec."Order No.");
    end;


}