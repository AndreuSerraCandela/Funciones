
/// <summary>
/// Page Detalle Renting (ID 7001153).
/// </summary>
page 7001153 "Detalle Renting"
{
    PageType = ListPart;
    SourceTable = "Detalle Prestamo";



    layout
    {
        area(Content)
        {
            repeater(Detalle)
            {
                //field("% Intereses"; Rec."% Intereses") { ApplicationArea = All; }
                field("No. Periodo"; Rec."No. Periodo") { ApplicationArea = All; }
                field(Fecha; Rec.Fecha) { ApplicationArea = All; }
                field("Cuota"; Rec."A Pagar") { ApplicationArea = All; }
                field("Seguro"; Rec.Seguro) { ApplicationArea = All; Caption = 'Seguro'; }
                field("Mantenimiento"; Rec.Mantenimiento) { ApplicationArea = All; Caption = 'Mantenimiento'; }

                field(Provisionado; Rec.Liquidado) { Caption = 'Provisionado'; ApplicationArea = All; }
                field(Facturado; Rec.Facturado) { Caption = 'Facturado'; ApplicationArea = All; }

            }
        }
    }
    VAR
        DefEmpresa: Text[30];

    trigger onOpenPage()
    var
        Control: Codeunit ControlProcesos;
    begin
        If Control.AccesoProibido_Empresas(CompanyName, 'RESTRINGIDO') then
            Error('No tiene permisos para acceder a este punto del menú en esta empresa');
        if DefEmpresa <> '' THEN
            Rec.CHANGECOMPANY(DefEmpresa);
    END;

    PROCEDURE Empresa(Cia: Text[30]);

    BEGIN
        DefEmpresa := Cia;
        Rec.CHANGECOMPANY(Cia);
    END;


}