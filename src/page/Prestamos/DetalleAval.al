
/// <summary>
/// Page Detalle Aval (ID 50073).
/// </summary>
page 50073 "Detalle Aval"
{
    Caption = 'Líneas Aval';
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
                field("Hasta"; Rec."Hasta")
                {
                    ApplicationArea = All;
                    trigger OnValidate()
                    var
                        PosPo31: Integer;
                        CabPrestamo: Record "Cabecera Prestamo";
                    begin
                        If Not
                        CabPrestamo.GET(Rec."Código Del Prestamo") then
                            exit;
                        PosPo31 := StrPos(CabPrestamo."Cabecera Prestamo2", '%1');
                        If PosPo31 > 0 Then
                            Rec."Descripción" := CopyStr(CabPrestamo."Cabecera Prestamo2", 1, PosPo31 - 1) + Format(Rec.Fecha, 0, '<Day,2>/<Month,2>/<Year>') + '-' + Format(Rec."Hasta", 0, '<Day,2>/<Month,2>/<Year>') + CopyStr(CabPrestamo."Cabecera Prestamo2", PosPo31 + 2, MAXSTRLEN(Rec."Descripción"))
                        Else
                            Rec."Descripción" := CabPrestamo."Cabecera Prestamo2";
                        CabPrestamo.Modify();
                    end;
                }
                field("Cuota"; Rec."A Pagar") { ApplicationArea = All; }
                field("Descripción"; Rec."Descripción") { ApplicationArea = All; }
                //field(Descripción; Rec.Descripción) { ApplicationArea = All; }
                // field("Seguro"; Rec.Seguro) { ApplicationArea = All; Caption = 'Seguro'; }
                // field("Mantenimiento"; Rec.Mantenimiento) { ApplicationArea = All; Caption = 'Mantenimiento'; }

                field(Provisionado; Rec.Liquidado) { Caption = 'Provisionado'; ApplicationArea = All; }

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