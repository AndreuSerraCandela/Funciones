/// <summary>
/// Page Laerit File Management Setup Wizard (ID 90103).
/// </summary>
page 7001176 "Wizard Proyectos Fijación"
{
    Caption = 'Wizard Proyectos';
    PageType = NavigatePage;
    SourceTable = "Job";
    SourceTableTemporary = true;
    Editable = true;
    layout
    {
        area(content)
        {
            group(StandardBanner)
            {
                Caption = '';
                Editable = true;
                Visible = TopBannerVisible and not FinishActionEnabled;
                field(MediaResourcesStandard; MediaResourcesStandard."Media Reference")
                {
                    ApplicationArea = All;
                    Editable = true;
                    ShowCaption = false;
                }
            }
            group(FinishedBanner)
            {
                Caption = '';
                Editable = true;
                Visible = TopBannerVisible and FinishActionEnabled;
                field(MediaResourcesDone; MediaResourcesDone."Media Reference")
                {
                    ApplicationArea = All;
                    Editable = true;
                    ShowCaption = false;
                }

            }

            group(Step0)
            {
                Visible = Step0Visible;
                group("Bienvenido al proceso de asignación de Proyectos")
                {
                    Caption = 'Bienvenido al proceso de creación de Proyectos';
                    Visible = Step1Visible;
                    group(Group18)
                    {
                        Caption = 'Proceso';
                        InstructionalText = 'Este asistente le guiará por los distintos pasos';

                    }
                }
                group("Let's go!")
                {
                    Caption = 'Empecemos!';
                    group(Group22)
                    {
                        Caption = '';
                        InstructionalText = 'Para empezar pulse siguiente';
                    }

                }
            }
            group(Step1)
            {
                Visible = Step1Visible;
                Caption = 'Elejir proyecto fjijación';
                InstructionalText = 'Cree un nuevo proyecto o utilize uno existente';
                // field("¿Es un Proyecto de fijación?"; Fijación)
                // {
                //     ApplicationArea = All;

                // }
                group(Fijacion)
                {
                    //Visible = Fijación;
                    field("¿Creamos uno nuevo ?"; Nuevo)
                    {
                        ApplicationArea = All;
                        Caption = '¿Creamos uno nuevo ?';
                        trigger OnValidate()
                        begin
                            if Nuevo then begin
                                Carga('');
                                Step := Step::Step2;
                            end else begin
                                Job.SetRange("Proyecto de fijación", true);
                                //Job.SetRange("No Pay", Rec."No Pay");
                                Job.SetRange("Creation Date", CalcDate('PA+1D-1A', Today), CalcDate('PA', Today));
                                Job.FindLast();
                                Carga(Job."No.");
                                Step := Step::Step2;
                                ProyectoAnteriorVisible := True;
                            end;
                        end;
                    }
                }
                // group(Reserva)
                // {
                //     Visible = Not Fijación;
                //     field("¿Creamos nuevo ?"; Nuevo)
                //     {
                //         ApplicationArea = All;
                //         Caption = '¿Creamos uno nuevo ?';
                //         trigger OnValidate()
                //         begin
                //             if Nuevo then begin
                //                 Carga('', true);
                //                 Step := Step::Step2;
                //             end else begin
                //                 Job.SetRange("Proyecto de fijación", false);
                //                 Job.SetRange("No Pay", Rec."No Pay");
                //                 Job.SetRange("Creation Date", CalcDate('PA+1D-1A', Today), CalcDate('PA', Today));
                //                 Job.FindLast();
                //                 Carga(Job."No.", false);
                //                 Step := Step::Step2;
                //                 ProyectoAnteriorVisible := True;
                //             end;
                //         end;
                //     }
                // }

                group("Con que fechas")
                {
                    Visible = Nuevo;

                    InstructionalText = 'Indique las fechas de inicio y fin del proyecto';
                    field("Nueva Fecha Inicio"; Rec."Starting Date")
                    {
                        ApplicationArea = All;
                        //Visible = ProyectoAnteriorVisible;
                    }
                    field("Nueva Fecha Fin"; Rec."Ending Date")
                    {
                        ApplicationArea = All;
                        //Visible = ProyectoAnteriorVisible;
                    }

                }
            }


            group(Step2)
            {
                Visible = Step2Visible;
                group(Group23)
                {
                    Caption = 'Ya terminamos!';
                    InstructionalText = 'Vamos a Repasar los recursos que se van RESERVAR';

                    group("Detalle Recursos")
                    {
                        Caption = 'Recursos';
                        field("¿Que recursos se van a reservar?"; Añadimos)
                        {
                            ApplicationArea = All;
                            trigger OnValidate()
                            var
                                Lineas: Page "Wizard Lineas Proyectos";
                                Linea: Integer;
                                JT: Record "Job Planning Line" temporary;
                                ResUnit: Record "Resource Unit of Measure";
                                Recurso: Record Resource;
                                JobTak: Record "Job Task";
                            begin
                                if not JobTak.Get(Rec."No.", '10') Then begin
                                    JobTak.Init();
                                    JobTak."Job No." := Rec."No.";
                                    JobTak."Job Task No." := '10';
                                    JobTak.Description := 'Recursos';
                                    JobTak.Insert();
                                end;
                                "Añadimos" := false;
                                JobLineT.SetRange("Job No.", Rec."No.");
                                if JoblineT.FindLast() then Linea := JobLineT."Line No." + 10000 else Linea := 10000;
                                Lineas.Carga(Rec."No.", Linea);
                                Lineas.RunModal();
                                Lineas.GetRecord(JT);
                                JobLineT := JT;
                                JobLineT."Fecha Final" := Rec."Ending Date";
                                JobLineT."Planning Date" := Rec."Starting Date";
                                if Recurso.Get(JobLineT."No.") then begin
                                    if not ResUnit.Get(Recurso."No.", Recurso."Base Unit of Measure") Then begin
                                        ResUnit.Init();
                                        ResUnit."Resource No." := Recurso."No.";
                                        ResUnit."Code" := Recurso."Base Unit of Measure";
                                        ResUnit.Insert();
                                    end;
                                end;
                                JobLineT.Insert();
                            end;
                        }
                    }
                    part(Lines; JobLinesSub)
                    {
                        ApplicationArea = aLL;
                        SubPageLink = "Job No." = FIELD("No.");
                        SubPageView = SORTING("Job Task No.")
                        ORDER(Ascending);
                    }
                }


            }
            group(Step3)
            {
                Visible = Step3Visible;
                group(Group26)
                {
                    Caption = 'Reservamos!';
                    InstructionalText = 'Vamos a Reservar los recursos que se van a utilizar';

                    group("Reservas")
                    {
                        Caption = 'Reservas';
                        field("¿Vamos a crear las reservas?"; Reservar)
                        {
                            ApplicationArea = All;
                            trigger OnValidate()
                            var
                                Lineas: Page "Wizard Lineas Proyectos";
                                Linea: Integer;
                                JT: Record "Job Planning Line" temporary;
                            begin

                                CurrPage.Lines.Page.CreaReservasFijacion(0);

                            end;
                        }
                    }

                }

                group("Esto es todo!")
                {
                    Caption = 'Esto es todo!';
                    group(Group27)
                    {
                        Caption = '';
                        InstructionalText = 'Pulse finalizar para volver al proyecto e insertar la línea';


                    }
                }
            }
        }
    }
    actions
    {
        area(processing)
        {
            action(ActionBack)
            {
                ApplicationArea = All;
                Caption = 'Anterior';
                Enabled = BackActionEnabled;
                Image = PreviousRecord;
                InFooterBar = true;
                trigger OnAction();
                begin
                    NextStep(true);
                end;
            }
            action(ActionNext)
            {
                ApplicationArea = All;
                Caption = 'Siguiente';
                Enabled = NextActionEnabled;
                Image = NextRecord;
                InFooterBar = true;
                trigger OnAction();
                begin
                    NextStep(false);
                end;
            }
            action(ActionFinish)
            {
                ApplicationArea = All;
                Caption = 'Fializar';
                Enabled = FinishActionEnabled;
                Image = Approve;
                InFooterBar = true;
                trigger OnAction();
                begin
                    FinishAction();
                end;
            }
        }
    }

    trigger OnInit();
    begin
        LoadTopBanners();
    end;

    trigger OnOpenPage();
    var
        Glseup: Record "General Ledger Setup";
    begin


        Step := Step::Start;
        EnableControls();
    end;


    var
        Num: Code[20];
        LLamar: Boolean;
        MediaRepositoryDone: Record "Media Repository";
        MediaRepositoryStandard: Record "Media Repository";
        MediaResourcesDone: Record "Media Resources";
        MediaResourcesStandard: Record "Media Resources";
        Step: Option Start,Step1,Step2,Step3,Finish;
        BackActionEnabled: Boolean;
        FinishActionEnabled: Boolean;
        NextActionEnabled: Boolean;
        Step0Visible: Boolean;
        Step1Visible: Boolean;
        Step2Visible: Boolean;
        Step3Visible: Boolean;

        TopBannerVisible: Boolean;
        ProyectoAnteriorVisible: Boolean;
        EsClienteNuevoVisible: Boolean;

        ClienteNuevo: Boolean;
        SalesPerson: Record "Salesperson/Purchaser";
        Proyectomixpovisible: Boolean;
        Traspasamos: Boolean;
        JobLineT: Record "Job Planning Line";
        //Variable Record Job
        Job: Record Job;
        Añadimos: Boolean;
        Nuevo: Boolean;
        Reservar: Boolean;
    //Fijación: Boolean;



    /// <summary>
    /// Carga.
    /// </summary>
    /// <param name="PProyecto">code[20].</param>

    procedure Carga(PProyecto: code[20])
    var
        //Varaable Job Setup
        JobSetup: Record "Jobs Setup";
        //Variable Codeunit NoserieManagement
#if CLEAN24
#pragma warning disable AL0432
        NoserieManagement: Codeunit NoSeriesManagement;
#pragma warning restore AL0432
#else
        NoserieManagement: Codeunit "No. Series";
#endif

    begin
        //Crtear proyecto con numero correspondiente
        Rec.Init();
        JobSetup.Get();
        if PProyecto = '' Then begin
            Job.SetRange("Proyecto de fijación", true);
            Job.SetRange("Creation Date", CalcDate('PA+1D-1A', Today), CalcDate('PA', Today));
            if Job.FindLast() then
                Rec."No." := IncStr(Job."No.")
            else
                Rec."No." := 'FI' + Format(Today, 0, '<Year>') + '-0001';
        end
        else
            Rec."No." := PProyecto;
        //Rec."No Pay" := true;
        Rec."Proyecto de fijación" := true;
        Rec.Insert();
        Num := Rec."No.";

    end;

    local procedure EnableControls();
    begin
        ResetControls();

        case Step of
            Step::Start:
                ShowStep0();
            Step::Step1:
                ShowStep1();
            Step::Step2:
                ShowStep2();
            Step::Step3:
                ShowStep3();

            Step::Finish:
                ShowStep3();
        end;
    end;

    local procedure StoreRecordVar();
    var
        GlSetup: Record "General Ledger Setup";
    begin
        // if not GlSetup.Get() then begin
        //     GlSetup.Init();
        //     GlSetup.Insert();
        // end;

        // GlSetup.TransferFields(Rec, false);
        // GlSetup.Modify(true);
    end;

    local procedure FinishAction();
    begin
        // StoreRecordVar();
        // if Not LLamar then begin
        //     Commit();
        //     Page.RunModal(Page::"Printer Management");
        // end;
        CurrPage.Close();
    end;

    local procedure NextStep(Backwards: Boolean);
    begin
        // if solofijacion then begin
        //     if Step = Step::Step1 then begin
        //         Step := Step::Step6;
        //     end else begin
        //         if (Step = Step::Step6) and (Backwards) then begin
        //             Step := Step::Step1;

        //         end;
        //     end;
        // end else
        if Backwards then
            Step := Step - 1
        else
            Step := Step + 1;

        EnableControls();
    end;

    local procedure ShowStep0();
    begin
        Step0Visible := true;
        ProyectoAnteriorVisible := false;
        EsClienteNuevoVisible := true;
        FinishActionEnabled := false;
        BackActionEnabled := false;
    end;

    local procedure ShowStep1();
    begin
        Step1Visible := true;

        FinishActionEnabled := false;
        BackActionEnabled := true;
    end;

    local procedure ShowStep2();
    begin
        Step2Visible := true;
    end;


    local procedure ShowStep3();
    begin
        Step3Visible := true;
        if Not Job.Get(Rec."No.") then begin
            Job := Rec;
            Job.Insert();
        end;
        NextActionEnabled := false;
        FinishActionEnabled := true;
    end;

    local procedure ResetControls();
    begin
        FinishActionEnabled := false;
        BackActionEnabled := true;
        NextActionEnabled := true;
        Step0Visible := false;
        Step1Visible := false;
        Step2Visible := false;
        Step3Visible := false;


    end;

    local procedure LoadTopBanners();
    begin
        if MediaRepositoryStandard.Get('AssistedSetup-NoText-400px.png', Format(CurrentClientType())) and
            MediaRepositoryDone.Get('AssistedSetupDone-NoText-400px.png', Format(CurrentClientType()))
        then
            if MediaResourcesStandard.Get(MediaRepositoryStandard."Media Resources Ref") and
                MediaResourcesDone.Get(MediaRepositoryDone."Media Resources Ref")
        then
                TopBannerVisible := MediaResourcesDone."Media Reference".HasValue();
    end;



}