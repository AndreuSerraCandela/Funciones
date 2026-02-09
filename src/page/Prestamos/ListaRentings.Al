
/// <summary>
/// Page Lista Rentings (ID 50070).
/// </summary>
page 50070 "Lista Rentings"
{
    ApplicationArea = All;
    PageType = List;
    UsageCategory = Lists;
    Editable = false;
    SourceTable = "Cabecera Prestamo";
    SourceTableView = WHERE(Empresa = FILTER(''), Renting = const(true));
    CardPageId = "Cabecera Renting";
    layout
    {
        area(Content)
        {

            repeater(Detalle)
            {
                field("Código Del Renting"; Rec."Código Del Prestamo") { Caption = 'Código Del Renting'; ApplicationArea = All; }
                field("Descripción"; Rec."Cabecera Prestamo2") { ApplicationArea = All; }

                field(Años; Rec."Años") { ApplicationArea = All; }
                field("Cuotas Anuales"; Rec."Cuotas Anuales") { ApplicationArea = All; }
                field("Importe Renting"; Rec."Importe Prestamo") { Caption = 'Importe Renting'; ApplicationArea = All; }
                field("Fecha Renting"; Rec."Fecha Préstamo") { Caption = 'Fecha Renting'; ApplicationArea = All; }
                field("Fecha 1ª Cuota"; Rec."Fecha 1ª Amortización") { ApplicationArea = All; }
                field(Proveedor; Rec."Proveedor Leasing") { Caption = 'Proveedor'; ApplicationArea = All; }
                field(Meses; Rec.Meses) { ApplicationArea = All; }
            }
        }
    }
    actions
    {
        area(Navigation)
        {
            action(Ficha)
            {
                ApplicationArea = All;
                Scope = Repeater;
                Image = Card;
                ShortCutKey = 'Mayús+F5';
                Caption = 'Ficha';
                RunObject = page "Cabecera Renting";
                RunPageLink = "Código Del Prestamo" = FIELD("Código Del Prestamo");
            }
        }
    }
    trigger OnNewRecord(BelowRec: Boolean)
    begin
        Rec.Renting := true;
    end;

    trigger onOpenPage()
    var
        Control: Codeunit ControlProcesos;
    begin
        If Control.AccesoProibido_Empresas(CompanyName, 'RESTRINGIDO') then
            Error('No tiene permisos para acceder a este punto del menú en esta empresa');
    end;
}
