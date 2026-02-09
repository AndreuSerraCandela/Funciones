/// <summary>
/// Page Laerit File Management Setup Wizard (ID 90103).
/// </summary>
page 50051 "Wizard Proyectos"
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
                // field("¿Es solo para fijacion?"; solofijacion)
                // {
                //     ApplicationArea = All;
                //     Caption = '¿Es solo para fijacion?';
                // }

                // group(Renvovacion)
                // {
                //     Visible = not solofijacion;
                Caption = 'Es una renovación';
                InstructionalText = 'Indique si se trata de una renovación';
                field("¿En una Renovación ?"; Rec.Renovado)
                {
                    ApplicationArea = All;
                    Caption = '¿En una Renovación ?';
                    // si es una renovación, solicita el proyecto que renueva, si no, el cliente
                    trigger OnValidate()
                    var
                        Proy: Record Job;
                    begin
                        if Rec.Renovado then begin
                            ProyectoAnteriorVisible := True;
                        end else begin
                            ProyectoAnteriorVisible := false;
                            EsClienteNuevoVisible := True;
                        end;
                    end;
                    // }

                }
                group("Proyecto Origen")
                {
                    Visible = ProyectoAnteriorVisible;
                    field("¿Qué proyecto renueva?"; Rec."Proyecto origen")
                    {
                        ApplicationArea = All;

                        trigger OnValidate()
                        var
                            Proy: Record Job;
                            Customer: Record Customer;
                            I: Date;
                            F: Date;
                        begin
                            if Proy.Get(Rec."Proyecto origen") then begin
                                I := Rec."Starting Date";
                                F := Rec."Ending Date";
                                Rec.Delete();
                                Rec := Proy;
                                Rec."No." := Num;
                                Rec."Proyecto origen" := Proy."No.";
                                Rec."Starting Date" := I;
                                Rec."Ending Date" := F;
                                Rec.Insert();
                                Customer.Get(Rec."Sell-to Customer No.");
                                SalesPerson.Get(Customer."Salesperson Code");
                            end else begin
                                ERROR('No se ha encontrado el proyecto');
                            end;
                        end;
                    }
                }
                group("Con que fechas")
                {
                    Visible = ProyectoAnteriorVisible;

                    InstructionalText = 'Indique las fechas de inicio y fin del proyecto';
                    field("Nueva Fecha Inicio"; Rec."Starting Date")
                    {
                        ApplicationArea = All;
                        trigger OnValidate()
                        begin
                            II := Rec."Starting Date";

                        end;

                        //Visible = ProyectoAnteriorVisible;
                    }
                    field("Nueva Fecha Fin"; Rec."Ending Date")
                    {
                        ApplicationArea = All;
                        trigger OnValidate()
                        begin
                            FF := Rec."Ending Date";

                        end;
                        //Visible = ProyectoAnteriorVisible;
                    }

                }
            }
            group(Step2)
            {
                Caption = 'Cliente';
                InstructionalText = 'Indique el Cliente, la campaña y, el anunciante';
                Visible = Step2Visible;
                //You might want to add fields here
                group("Cliente Nuevo")
                {
                    Visible = EsClienteNuevoVisible;
                    field("¿Es cliente Nuevo?"; ClienteNuevo)
                    {

                        ApplicationArea = All;
                        trigger OnValidate()
                        var
                            Cli: Record Customer;
                        begin
                            if ClienteNuevo Then
                                Rec.Validate("Sell-to Customer No.", CrearClienteDesdePlantilla());
                            Cli.Get(Rec."Sell-to Customer No.");
                            SalesPerson.Get(Cli."Salesperson Code");
                        end;
                    }
                }
                field("¿Es este Cliente?"; Rec."Sell-to Customer Name")
                {
                    ApplicationArea = All;
                    trigger OnValidate()
                    Var
                        Customer: Record Customer;
                    begin
                        Customer.Get(Rec."Sell-to Customer No.");
                        SalesPerson.Get(Customer."Salesperson Code");

                    end;
                }
                group("que fechas")
                {
                    Visible = nOT ProyectoAnteriorVisible;

                    InstructionalText = 'Indique las fechas de inicio y fin del proyecto';
                    field("Fecha Inicio"; Rec."Starting Date")
                    {
                        ApplicationArea = All;
                        trigger OnValidate()
                        begin
                            II := Rec."Starting Date";

                        end;
                        //Visible = ProyectoAnteriorVisible;
                    }
                    field("Fecha Fin"; Rec."Ending Date")
                    {
                        ApplicationArea = All;
                        trigger OnValidate()
                        begin
                            FF := Rec."Ending Date";

                        end;
                        //Visible = ProyectoAnteriorVisible;
                    }
                    field("Fechas Flexibles"; Rec."Fechas Flexibles")
                    {
                        ApplicationArea = All;
                        Caption = '¿Tienen fechas flexibles?';
                    }

                }


            }


            group(Step3)
            {
                Visible = Step3Visible;
                group(Group23)
                {
                    Caption = 'Campaña y Anunciante';
                    InstructionalText = 'Seleccione la campaña y el anunciante';
                    field("Campaña"; Rec.Description)
                    {
                        ApplicationArea = All;
                        Caption = 'Describeme la campaña de este proyecto';
                    }
                    field("¿Quien és el anunciante?"; Rec."Nombre Comercial")
                    {
                        ApplicationArea = All;
                        Caption = '¿Quien és el anunciante?';
                    }

                }

            }
            group(Step4)
            {
                Visible = Step4Visible;
                group(Group24)
                {
                    Caption = 'Revisemos los datos del cliente';
                    InstructionalText = 'Seleccione los datos del cliente';
                    field("¿Quien Lo lleva?"; Rec."Cód. vendedor")
                    {
                        ApplicationArea = All;
                        Caption = '¿Quien Lo lleva?';
                        trigger OnValidate()
                        begin
                            SalesPerson.Get(Rec."Cód. vendedor");
                        end;
                    }
                    field("Nombre Vendedor"; SalesPerson.Name)
                    {
                        ApplicationArea = All;
                        ShowCaption = false;
                    }
                    field("¿Como va a pagar?"; Rec."Payment Method Code")
                    {
                        ApplicationArea = All;
                        Caption = '¿Como va a pagar?';
                    }
                    field("¿Cuando va a pagar?"; Rec."Payment Terms Code")
                    {
                        ApplicationArea = All;
                        Caption = '¿Cuando va a pagar?';
                    }

                }

            }
            group(Step5)
            {
                Visible = Step5Visible;
                group(Group25)
                {
                    Caption = 'Vamos a repasar algunios datos más';
                    InstructionalText = 'Seleccione los datos correspondientes a este tipo de proyecto';
                    field("A que departamento afecta"; Rec."Global Dimension 1 Code")
                    {
                        Caption = 'A que departamento afecta';
                        ApplicationArea = All;


                    }
                    field("¿Y a que Programa?"; Rec."Global Dimension 2 Code")
                    {
                        Caption = '¿Y a que Programa?';
                        ApplicationArea = All;
                    }
                    field("De que tipo es"; Rec.Tipo)
                    {
                        Caption = 'De que tipo es';
                        ApplicationArea = All;
                    }
                    field("Y de que subtipo"; Rec.Subtipo)
                    {
                        Caption = 'Y de que subtipo';
                        ApplicationArea = All;
                    }
                    field("Soporte?"; Rec."Soporte de")
                    {
                        Caption = '¿Soporte?';
                        ApplicationArea = All;
                    }
                    field("¿Fija o Papel?"; Rec."Fija/Papel")
                    {
                        Caption = '¿Fija o Papel?';
                        ApplicationArea = All;
                    }
                    field("¿Es inercambio, compensación o donación?"; Rec."Interc./Compens.")
                    {
                        Caption = '¿Es intercambio, compensación o donación?';
                        ApplicationArea = All;
                    }
                    field("¿El proyecto va según disponibilidad?"; Rec."Según disponibilidad")
                    {
                        Caption = '¿El proyecto va según disponibilidad?';
                        ApplicationArea = All;
                        trigger OnValidate()
                        begin
                            if Rec."Según disponibilidad" then begin
                                Proyectomixpovisible := True;
                            end;
                        end;
                    }
                    group("Mixto")
                    {
                        Caption = '¿El proyecto es mixto?';

                        Visible = Proyectomixpovisible;

                        field("¿El proyecto es mixto?"; Rec."Proyecto Mixto")
                        {
                            Caption = '¿El proyecto es mixto?';
                            ApplicationArea = All;

                        }
                    }


                }
            }

            group(Step6)
            {
                Visible = Step6Visible;
                group(Group26)
                {
                    Caption = 'Ya terminamos!';
                    InstructionalText = 'Vamos a Repasar los recursos que se van a utilizar';
                    group("Recursos")
                    {
                        Caption = 'Recursos';
                        Visible = ProyectoAnteriorVisible;
                        field("¿Traspasamos los recursos del proyecto Original?"; Traspasamos)
                        {
                            ApplicationArea = All;

                            trigger OnValidate()
                            var
                                JobLine: Record "Job Planning Line";
                                Resource: Record "Resource";
                                ResUnit: Record "Resource Unit of Measure";
                                JobTak: Record "Job Task";
                            begin
                                if not JobTak.Get(Rec."No.", '10') Then begin
                                    JobTak.Init();
                                    JobTak."Job No." := Rec."No.";
                                    JobTak."Job Task No." := '10';
                                    JobTak.Description := 'Recursos';
                                    JobTak.Insert();
                                end;

                                JobLine.SetRange("Job No.", Rec."Proyecto origen");
                                if JobLine.FindFirst()
                                then begin
                                    repeat
                                        if JobLine.Type = JobLine.Type::"Resource" then begin
                                            Resource.Get(JobLine."No.");
                                            Resource.CalcFields(Bloqueado);
                                            if (Resource.Bloqueado) And (Not Resource."Producción") then begin
                                                Message('El recurso ' + Resource."No." + ' está bloqueado. Elija otro recurso para poder traspasarlo');
                                                Commit();
                                                if Page.RunModal(0, Resource) <> Action::LookupOK then begin
                                                    ERROR('No se ha seleccionado ningún recurso');
                                                end;
                                            end;
                                            JobLineT := JobLine;
                                            JobLineT."Job No." := Rec."No.";
                                            if not ResUnit.Get(Resource."No.", Resource."Base Unit of Measure") Then begin
                                                ResUnit.Init();
                                                ResUnit."Resource No." := Resource."No.";
                                                ResUnit."Code" := Resource."Base Unit of Measure";
                                                ResUnit.Insert();
                                            end;
                                            JobLineT."Job Task No." := '10';
                                            JobLineT.Validate("No.", Resource."No.");
                                            JobLineT."Fecha Final" := Rec."Ending Date";
                                            JobLineT."Planning Date" := Rec."Starting Date";
                                            if not Resource."Producción" Then
                                                JobLineT.Insert();
                                        end;
                                    until JobLine.Next() = 0;

                                end;
                            end;
                        }
                    }
                    group("Detalle Recursos")
                    {
                        Caption = 'Recursos';
                        Visible = not ProyectoAnteriorVisible;
                        field("¿Que recursos se van a utilizar?"; Añadimos)
                        {
                            ApplicationArea = All;
                            trigger OnValidate()
                            var
                                Lineas: Page "Wizard Lineas Proyectos";
                                Linea: Integer;
                                JT: Record "Job Planning Line" temporary;
                                Resource: Record Resource;
                                ResUnit: Record "Resource Unit of Measure";
                                JobTak: Record "Job Task";
                            begin
                                "Añadimos" := false;
                                if not JobTak.Get(Rec."No.", '10') Then begin
                                    JobTak.Init();
                                    JobTak."Job No." := Rec."No.";
                                    JobTak."Job Task No." := '10';
                                    JobTak.Description := 'Recursos';
                                    JobTak.Insert();
                                end;
                                Commit();
                                JobLineT.SetRange("Job No.", Rec."No.");
                                if JoblineT.FindLast() then Linea := JobLineT."Line No." + 10000 else Linea := 10000;
                                Lineas.Carga(Rec."No.", Linea);
                                Lineas.RunModal();
                                Lineas.GetRecord(JT);
                                JobLineT := JT;
                                JobLineT."Fecha Final" := Rec."Ending Date";
                                JobLineT."Planning Date" := Rec."Starting Date";
                                if Resource.Get(JobLineT."No.") then begin
                                    if not ResUnit.Get(Resource."No.", Resource."Base Unit of Measure") Then begin
                                        ResUnit.Init();
                                        ResUnit."Resource No." := Resource."No.";
                                        ResUnit."Code" := Resource."Base Unit of Measure";
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
        Step: Option Start,Step1,Step2,Step3,Step4,Step5,Step6,Finish;
        BackActionEnabled: Boolean;
        FinishActionEnabled: Boolean;
        NextActionEnabled: Boolean;
        Step0Visible: Boolean;
        Step1Visible: Boolean;
        Step2Visible: Boolean;
        Step3Visible: Boolean;
        Step4Visible: Boolean;
        Step5Visible: Boolean;
        Step6Visible: Boolean;
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
        rGrupoProy: Record "Job Posting Group";
        II: Date;
        FF: Date;

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
        if PProyecto = '' Then
            Rec."No." := NoserieManagement.GetNextNo(JobSetup."Job Nos.", Today, true)
        else
            Rec."No." := PProyecto;
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
            Step::Step4:
                ShowStep4();
            Step::Step5:
                ShowStep5();
            Step::Step6:
                ShowStep6();
            Step::Finish:
                ShowStep6();
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
        If (ii <> 0D) And (Rec."Starting Date" = 0D) then
            Rec."Starting Date" := II;
        iF (FF <> 0D) And (Rec."Starting Date" = 0D) then
            Rec."Ending Date" := FF;
        Rec.Modify();
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
    end;

    local procedure ShowStep4();
    begin
        Step4Visible := true;
    end;

    local procedure ShowStep5();
    begin
        Step5Visible := true;
    end;

    local procedure ShowStep6();
    var
        Estado: Enum "Job Status Kuara";
        rConf: Record "Jobs Setup";
        rProyGenerico: Record Job;
        rTaskGenerico: Record "Job Task";
        rTask: Record "Job Task";
    begin
        Step6Visible := true;
        if Job.Get(Rec."No.") then
            Job.Delete();
        Job := Rec;
        Job.Status := Estado::Planning;
        Job.Status := Job.Status::Planning;

        // MNC 301298
        if rGrupoProy.FIND('-') THEN
            Job."Job Posting Group" := rGrupoProy.Code
        ELSE
            ERROR('Debe crear como minimo un registro en Grupos Contables Proyectos');
        // Fi MNC

        // $001-
        //$007(I)
        //$007(F)
        rConf.GET();
        rConf.TESTFIELD("Cód. Proyecto Genérico");
        rProyGenerico.GET(rConf."Cód. Proyecto Genérico");
        rTaskGenerico.RESET;
        rTaskGenerico.SETRANGE("Job No.", rProyGenerico."No.");
        CLEAR(rTask);
        if rTaskGenerico.FINDSET THEN
            REPEAT
                rTask.COPY(rTaskGenerico);
                rTask."Job No." := Job."No.";
                rTask."Job Posting Group" := Job."Job Posting Group";
                rTask."Global Dimension 1 Code" := Job."Global Dimension 1 Code";
                rTask."Global Dimension 2 Code" := Job."Global Dimension 2 Code";
                if rTask.INSERT THEN;
            UNTIL rTaskGenerico.NEXT = 0;
        //$007(I)
        //Mensaje de aviso para la creación de proyecto genérico

        //$007(F)
        // $001 +


        // $002 -
        if Job.GETFILTER("Global Dimension 1 Code") <> '' THEN
            Job."Global Dimension 1 Code" := Job.GETFILTER("Global Dimension 1 Code");
        // $002 +

        //$009
        // if Job."Proyecto original" = '' THEN
        //     Job."Proyecto original" := Job."No.";
        Job.Status := Job.Status::Planning;
        job."Creation Date" := Today;
        Job.Insert();
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
        Step4Visible := false;
        Step5Visible := false;
        Step6Visible := false;

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


    local procedure CrearClienteDesdePlantilla(): Code[20]
    var
        CustTemplate: Record "Customer Templ.";
        Customer: Record Customer;
        No: Code[20];
        Wizard: Page "Wizard Clientes";

    begin
        Wizard.Carga();
        Wizard.RunModal();
        exit(Wizard.Recupera());
        //Elije la plantilla de una lista
        // if Page.RunModal(0, CustTemplate) <> Action::LookupOK then
        //     Error('No se ha seleccionado ninguna plantilla de cliente.');
        // // Buscar la plantilla de cliente
        // if Customer.FindLast() Then No := IncStr(Customer."No.") Else No := '10000';
        // // Crear un nuevo registro de cliente
        // Customer.Init();
        // Customer."No." := No;  // Puedes reemplazar esto por una lógica para generar números de cliente
        // Customer."Customer Posting Group" := CustTemplate."Customer Posting Group";
        // Customer."Gen. Bus. Posting Group" := CustTemplate."Gen. Bus. Posting Group";
        // Customer."VAT Bus. Posting Group" := CustTemplate."VAT Bus. Posting Group";
        // Customer."Customer Price Group" := CustTemplate."Customer Price Group";
        // Customer."Customer Disc. Group" := CustTemplate."Customer Disc. Group";
        // Customer."Payment Terms Code" := CustTemplate."Payment Terms Code";
        // Customer."Payment Method Code" := CustTemplate."Payment Method Code";
        // // Agrega aquí más campos de la plantilla según sea necesario

        // // Insertar el nuevo cliente
        // if not Customer.Insert() then
        //     Error('No se pudo crear el cliente.');
        // Commit();
        exit(Customer."No.");

    end;

}