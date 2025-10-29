/// <summary>
/// PageExtension GetReceiptLines (ID 80334).
/// </summary>
pageextension 80189 GetReceiptLines Extends "Get Receipt Lines"
{
    layout
    {
        addafter("Document No.")
        {
            field("Order No."; Rec."Order No.") { ApplicationArea = All; }

            field("Fecha Albaran"; FechaAlbaran) { ApplicationArea = All; }
            field("Fecha Inicial"; TraeFechaProy('I')) { ApplicationArea = All; HideValue = DocumentNoHideValue; }
            field("Fecha Final"; TraeFechaProy('F')) { ApplicationArea = All; HideValue = DocumentNoHideValue; }
            field("Importe Pedido"; ImportePedido) { ApplicationArea = All; }
        }
    }
    PROCEDURE FechaAlbaran(): Date;
    var
        PurchRcptHeader: Record "Purch. Rcpt. Header";
    BEGIN
        if PurchRcptHeader.GET(Rec."Document No.") THEN EXIT(PurchRcptHeader."Posting Date");
    END;

    PROCEDURE ImportePedido(): Decimal;
    VAR
        r39: Record 39;
    BEGIN
        if r39.GET(r39."Document Type"::Order, Rec."Order No.", Rec."Order Line No.") THEN BEGIN
            EXIT(r39.Amount);
        END;
    END;

    PROCEDURE TraeFechaProy(fi: Text[1]): Date;
    VAR
        r36: Record 36;
        PurchRcptHeader: Record "Purch. Rcpt. Header";
    BEGIN
        if not PurchRcptHeader.GET(Rec."Document No.") THEN EXIT(Rec."Expected Receipt Date");
        PurchRcptHeader.CALCFIELDS("Nº Contrato Venta");
        if r36.GET(r36."Document Type"::Order, PurchRcptHeader."Nº Contrato Venta") THEN BEGIN
            if fi = 'I' THEN EXIT(r36."Fecha inicial proyecto");
            if fi = 'F' THEN EXIT(r36."Fecha fin proyecto");
        END;
        EXIT(PurchRcptHeader."Posting Date");
    END;
}