/// <summary>
/// Page Historico Recurso (ID 50079).
/// </summary>
page 50079 "Historico Recurso"
{
    SourceTable = "Reserva";
    SourceTableView = SORTING("Nº Recurso", "Fecha inicio", "Fecha fin");
    PageType = List;
    UsageCategory = Lists;
    layout
    {
        area(Content)
        {
            Repeater(Detalle)
            {
                Editable = false;

                field("Nº Recurso"; Rec."Nº Recurso") { ApplicationArea = All; }
                field("Nº Reserva"; Rec."Nº Reserva") { ApplicationArea = All; }
                field("Nº Proyecto"; Rec."Nº Proyecto") { ApplicationArea = All; }
                // OnFormat=BEGIN
                //            rProyecto.GET("Nº Proyecto");
                //          END;
                //           }
                field("Fecha inicio"; Rec."Fecha inicio") { ApplicationArea = All; }
                field("Fecha fin"; Rec."Fecha fin") { ApplicationArea = All; }
                field("Estado"; Rec.Estado) { ApplicationArea = All; }
                field("Cód. fase"; Rec."Cód. fase") { ApplicationArea = All; }
                field("Cód. subfase"; Rec."Cód. subfase") { ApplicationArea = All; }
                field("Cód. tarea"; Rec."Cód. tarea") { ApplicationArea = All; }
                field(Description; rProyecto.Description)
                {
                    Caption = 'Proyecto';
                    ApplicationArea = All;
                }

            }
        }
    }
    VAR
        rProyecto: Record 167;

    trigger OnAfterGetRecord()
    begin
        if Not rProyecto.Get(Rec."Nº Proyecto") then rProyecto.Init();
    end;

}
