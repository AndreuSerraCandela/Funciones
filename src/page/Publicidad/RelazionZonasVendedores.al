/// <summary>
/// Table Relacion Zonas/Vendedores (ID 7001197).
/// </summary>
table 7001197 "Relacion Zonas/Vendedores"
{
    fields
    {
        field(1; "Zona Comercial"; Code[20]) { TableRelation = "Zonas comerciales".Zona; }
        field(2; "Comercial"; Code[20]) { TableRelation = "Salesperson/Purchaser".Code; }
        field(3; "Descripcion Zona"; Text[250])
        {
            FieldClass = FlowField;
            CalcFormula = Lookup("Zonas comerciales".Descripcion WHERE(Zona = FIELD("Zona Comercial")));
        }
        field(4; "Nombre Comercial"; Text[100])
        {
            FieldClass = FlowField;
            CalcFormula = Lookup("Salesperson/Purchaser".Name WHERE(Code = FIELD(Comercial)));
        }
    }
    KEYS
    {
        key(P; "Zona Comercial", Comercial) { Clustered = true; }
    }
}
