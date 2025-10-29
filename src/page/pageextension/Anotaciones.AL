pageextension 80228 Anotaciones extends "Comment Sheet"
{
    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        Rec.Proveedor := EsProveedor;
    end;

    procedure Procedure_proveedor()
    begin
        Rec.Proveedor := true;
        EsProveedor := true;
    end;

    var
        EsProveedor: Boolean;
}