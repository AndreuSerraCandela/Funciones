pageextension 80219 SalesOrderExt extends "Sales Order"
{
    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        rec."Pedido standard" := true;
    end;

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    begin
        rec."Pedido standard" := true;

    end;


}