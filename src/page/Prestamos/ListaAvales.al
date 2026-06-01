
/// <summary>
/// Page Lista Avales (ID 50074).
/// </summary>
page 50074 "Lista Avales"
{
    Caption = 'Lista Avales';
    ApplicationArea = All;
    PageType = List;
    UsageCategory = Lists;
    Editable = false;
    SourceTable = "Cabecera Prestamo";
    SourceTableView = WHERE(Empresa = FILTER(''), Aval = const(true));
    CardPageId = "Cabecera Aval";
    layout
    {
        area(Content)
        {

            repeater(Detalle)
            {
                field("Código Del Aval"; Rec."Código Del Prestamo") { Caption = 'Código Del Aval'; ApplicationArea = All; }
                field("Descripción"; Rec."Cabecera Prestamo2") { ApplicationArea = All; }

                field(Años; Rec."Años") { ApplicationArea = All; }
                field("Cuotas Anuales"; Rec."Cuotas Anuales") { ApplicationArea = All; }
                field("Importe Aval"; Rec."Importe Prestamo") { Caption = 'Importe Aval'; ApplicationArea = All; }
                field("Fecha Inicio Aval"; Rec."Fecha Préstamo") { Caption = 'Fecha Inicio Aval'; ApplicationArea = All; }
                field("Fecha 1ª Cuota"; Rec."Fecha 1ª Amortización") { ApplicationArea = All; }
                // field(Proveedor; Rec."Proveedor Leasing") { Caption = 'Proveedor'; ApplicationArea = All; }
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
                RunObject = page "Cabecera Aval";
                RunPageLink = "Código Del Prestamo" = FIELD("Código Del Prestamo");
            }
        }
    }
    trigger OnNewRecord(BelowRec: Boolean)
    begin
        Rec.Aval := true;
        Rec.Meses := 1;
    end;

    trigger onOpenPage()
    var
        Control: Codeunit ControlProcesos;
    begin
        If Control.AccesoProibido_Empresas(CompanyName, 'RESTRINGIDO') then
            Error('No tiene permisos para acceder a este punto del menú en esta empresa');
    end;
}
