/// <summary>
/// Diálogo de filtros del panel de medios (para no ocupar ancho en el Role Center).
/// </summary>
page 50152 "Panel Medios Filtros"
{
    ApplicationArea = All;
    Caption = 'Filtros del panel';
    PageType = StandardDialog;

    layout
    {
        area(content)
        {
            field(YearFilter; YearValue)
            {
                ApplicationArea = All;
                Caption = 'Año';
                MinValue = 2000;
                MaxValue = 2100;
                ToolTip = 'Año de los indicadores del panel.';
            }
            field(SalespersonFilter; SalespersonCodeValue)
            {
                ApplicationArea = All;
                Caption = 'Comercial';
                TableRelation = "Salesperson/Purchaser";
                ToolTip = 'Vacío = todos los comerciales.';
            }
            field(CustomerFilter; CustomerNoValue)
            {
                ApplicationArea = All;
                Caption = 'Cliente';
                TableRelation = Customer;
                ToolTip = 'Vacío = todos los clientes.';
            }
        }
    }

    procedure SetValues(Year: Integer; SalespersonCode: Code[20]; CustomerNo: Code[20])
    begin
        YearValue := Year;
        SalespersonCodeValue := SalespersonCode;
        CustomerNoValue := CustomerNo;
    end;

    procedure GetValues(var Year: Integer; var SalespersonCode: Code[20]; var CustomerNo: Code[20])
    begin
        Year := YearValue;
        SalespersonCode := SalespersonCodeValue;
        CustomerNo := CustomerNoValue;
    end;

    var
        YearValue: Integer;
        SalespersonCodeValue: Code[20];
        CustomerNoValue: Code[20];
}
