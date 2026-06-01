/// <summary>
/// Page Planificar Fijación (ID 50103).
/// Diálogo para crear una planificación de fijación desde un proyecto.
/// </summary>
page 50048 "Planificar Fijación"
{
    ApplicationArea = All;
    Caption = 'Planificar fijación';
    PageType = Card;
    SourceTable = "Planificación Fijación";
    SourceTableTemporary = true;

    layout
    {
        area(Content)
        {
            group(General)
            {
                field("Nº Proyecto"; Rec."Nº Proyecto")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Fecha fijación"; Rec."Fecha fijación")
                {
                    ApplicationArea = All;
                    ShowMandatory = true;
                }
                field(Nombre; Rec.Nombre)
                {
                    ApplicationArea = All;
                    ShowMandatory = true;
                }
                field("Tipo Soporte"; Rec."Tipo Soporte")
                {
                    ApplicationArea = All;

                    trigger OnValidate()
                    var
                        ControlProcesos: Codeunit ControlProcesos;
                    begin
                        ControlProcesos.PlanifFijActualizarNoSoportes(Rec);
                    end;
                }
                field("No. Soportes"; Rec."No. Soportes")
                {
                    ApplicationArea = All;
                    ToolTip = 'Suma de la cantidad de soportes del tipo elegido en las líneas de planificación del proyecto.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            // action(Aceptar)
            // {
            //     ApplicationArea = All;
            //     Caption = 'Aceptar';
            //     Image = Approve;
            //     InFooterBar = true;

            //     trigger OnAction()
            //     begin
            //         GuardarPlanificacion();
            //     end;
            // }
            action(Cancelar)
            {
                ApplicationArea = All;
                Caption = 'Cancelar';
                Image = Cancel;
                InFooterBar = true;

                trigger OnAction()
                begin
                    CurrPage.Close();
                end;
            }
        }
    }

    trigger OnOpenPage()
    var
        Job: Record Job;
        ControlProcesos: Codeunit ControlProcesos;
    begin
        If Rec."Nº Proyecto" <> '' then SetJobNo(Rec."Nº Proyecto");
        if JobNo = '' then
            Error('No se ha indicado el proyecto.');

        if not Job.Get(JobNo) then
            Error('No se ha encontrado el proyecto %1.', JobNo);
        If Rec.Nombre = '' then
            ControlProcesos.PlanifFijInicializarDesdeProyecto(Rec, Job);
    end;

    local procedure GuardarPlanificacion()
    var
        PlanificacionFijacion: Record "Planificación Fijación";
    begin
        Rec.TestField("Fecha fijación");
        Rec.TestField(Nombre);
        Rec.TestField("Nº Proyecto");

        PlanificacionFijacion := Rec;
        if PlanificacionFijacion."Fecha generación" = 0D then
            PlanificacionFijacion."Fecha generación" := WorkDate();
        PlanificacionFijacion."No. Opis" := PlanificacionFijacion."No. Soportes";
        PlanificacionFijacion.Insert(true);
        CurrPage.Close();
    end;

    procedure SetJobNo(NewJobNo: Code[20])
    begin
        JobNo := NewJobNo;
    end;

    var
        JobNo: Code[20];
}
