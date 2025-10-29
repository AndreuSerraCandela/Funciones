/// <summary>
/// PageExtension PurchaseCreditMemo (ID 80207).
/// </summary>
pageextension 80200 PurchaseCreditMemo Extends "Purchase Credit Memo"
{
    layout
    {

        addAfter("Corrected Invoice No.")
        {
            field("Nº Proyecto"; Rec."Nº Proyecto") { ApplicationArea = All; }
        }
        addAfter("Vendor Bank Acc. Code")
        {
            field("Tipo factura rectificativa"; Rec."Tipo factura rectificativa") { ApplicationArea = All; }
            field("Descripción operación"; Rec."Descripción operación") { ApplicationArea = All; }
            field("Tipo factura SII"; Rec."Tipo factura SII") { ApplicationArea = All; }
            field("Posting No. Series"; Rec."Posting No. Series") { ApplicationArea = All; }
        }
    }
}