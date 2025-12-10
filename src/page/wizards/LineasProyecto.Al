/// <summary>
/// Page Laerit File Management Setup Wizard (ID 90103).
/// </summary>
page 7001160 "Wizard Lineas Proyectos"
{
    Caption = 'Wizard Lineas Proyecto';
    PageType = NavigatePage;
    SourceTable = "Job Planning Line";
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
                    Caption = 'Bienvenido al proceso de creación de las lineas de Proyectos';
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
                Caption = '¿Qué tipo de proyecto es?';
                InstructionalText = 'Indique de que tipo es el recurso';
                field("¿En un recurso agrupado ?"; Agrupado)
                {
                    ApplicationArea = All;
                    Caption = '¿En una recurso agrupado?';
                    trigger OnValidate()
                    begin
                        if Agrupado then begin
                            Produccion := false;

                        end;
                    end;
                }
                field("¿Es de producción?"; Produccion)
                {
                    ApplicationArea = All;
                    Caption = '¿Es de producción?';
                    trigger OnValidate()
                    begin
                        if (Produccion) then begin
                            Agrupado := false;
                        end;
                    end;
                }
                field("¿Qué tipo de resurso es?"; TipoRecurso)
                {
                    ApplicationArea = All;

                    trigger OnValidate()
                    var
                        Tipo: Record "Tipo Recurso";
                    begin
                        if Not Tipo.Get(TipoRecurso) then
                            ERROR('No se ha encontrado el Recurso');
                    end;

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        Tipo: Record "Tipo Recurso";
                    begin
                        if Page.RunModal(0, Tipo) = Action::LookupOK then begin
                            TipoRecurso := Tipo.Tipo;

                        end else
                            Error('No se ha seleccionado ningún tipo');
                    end;




                }


                field("¿Qué recurso es"; Rec."No.")
                {
                    Caption = '¿Qué recurso és?';
                    ApplicationArea = All;
                    trigger OnLookup(var Text: Text): Boolean
                    var
                        Resource: Record "Resource";

                        Prod: Record "Recursos de Producción";
                        Asis: Page "Wizard Producción";
                        L: Integer;
                        LL: Integer;
                        Linea: Record "Job Planning Line";
                        TR: Record "Tipo Recurso";
                        T: Code[20];
                        Job: Record Job;
                        JobTak: Record "Job Task";
                        Control: Codeunit "ControlProcesos";
                    begin
                        if Produccion then begin
                            if not Job.Get(Rec."Job No.") then begin
                                Job.Init();

                            end;
                            if not JobTak.Get(Rec."No.", '10') Then begin
                                JobTak.Init();
                                JobTak."Job No." := Rec."Job No.";
                                JobTak."Job Task No." := '10';
                                JobTak.Description := 'Recursos';
                                JobTak.Insert();
                            end;
                            Linea.SetRange("Job No.", Rec."Job No.");
                            T := '10';
                            if Linea.FindLast() Then begin
                                LL := JobLineT."Line No.";
                                L := Linea."Line No.";
                                T := Linea."Job Task No.";
                            end else
                                JobLineT.Init();
                            Commit();
                            Asis.Carga(Rec."Job No.", JobLineT."No.");
                            Asis.RunModal();
                            Asis.GetRecord(Prod);

                            Linea.Init();
                            Linea."Job No." := Rec."Job No.";
                            Linea."Job Task No." := T;
                            if Prod.Incluida then
                                Linea."Crear pedidos" := Linea."Crear pedidos"::"De Compra"
                            else
                                Linea."Crear pedidos" := Linea."Crear pedidos"::"De Compra Y De Venta";
                            Linea."Line No." := l + 10000;
                            Linea."Type" := Linea."Type"::Resource;
                            Linea.Validate("No.", Prod."Recurso No.");
                            Linea.Validate(Quantity, 1);
                            if Prod.Incluida then Linea."Origin Line No." := LL;
                            if Prod.Incluida = false then begin
                                Linea.Validate("Unit Price", Prod.Venta);
                                Linea.Validate("% Dto. Venta", Prod."Descuento Venta");
                            end;
                            Linea.Validate("Unit Cost", Prod.Compra);
                            Linea.Validate("% Dto. Compra", Prod."Descuento Compra");
                            TR.Get(Prod."Tipo de Soporte");
                            Linea.Description := Prod.Descripcion;
                            Linea.Validate("Shortcut Dimension 3 Code", TR."Cód. Principal");
                            //pon las fecha de inicio y fin
                            Linea."Planning Date" := Job."Starting Date";
                            Linea."Fecha Final" := Job."Ending Date";
                            Linea.Insert();
                            Commit();
                            Control.ProduccionNueva(Linea, Prod.Empresa, prod."Nº Proyecto");
                        end else begin
                            Resource.SetRange("Tipo Recurso", TipoRecurso);
                            Resource.SetRange("Recurso Agrupado", Agrupado);
                            Resource.SetRange("Bloqueado", false);
                            Resource.SetRange(Hoy, Today);
                            Resource.SetRange("Producción", Produccion);
                            Commit();
                            if Page.RunModal(0, Resource) = Action::LookupOK then begin
                                Rec."No." := Resource."No.";
                                Rec.Validate("No.", Resource."No.");
                                if not Job.Get(Rec."Job No.") then begin
                                    Job.Init();
                                end;
                                //pon las fecha de inicio y fin
                                Rec."Planning Date" := Job."Starting Date";
                                Rec."Fecha Final" := Job."Ending Date";
                            end else
                                Error('No se ha seleccionado ningún recurso');
                        end;
                    end;
                }



            }
            group(Step2)
            {
                Caption = 'Describe la operación';
                InstructionalText = 'Descripción de la operación';
                Visible = Step2Visible;
                //You might want to add fields here

                field("Describeme la línea"; Rec.Description)
                {
                    ApplicationArea = All;
                    Caption = 'Describeme la línea';
                }
                field("¿Cuantos necesitamos?"; Rec."Quantity")
                {
                    ApplicationArea = All;
                    Caption = '¿Cuantos necesitamos?';
                }


            }


            group(Step3)
            {
                Visible = Step3Visible;
                group(Group23)
                {
                    Caption = 'Compramos, vendemos o ambas';
                    InstructionalText = 'Seleccione la campaña y el anunciante';
                    field("¿Es un proyecto de Compra?"; Compra)
                    {
                        ApplicationArea = All;
                        Caption = '¿Es un proyecto de Compra?';
                        trigger OnValidate()
                        begin
                            if (Compra) and (venta) Then
                                Rec."Crear Pedidos" := Rec."Crear Pedidos"::"De Compra Y De Venta";
                            if (Compra) and (not venta) Then
                                Rec."Crear Pedidos" := Rec."Crear Pedidos"::"De Compra";
                            if (not Compra) and (venta) Then
                                Rec."Crear Pedidos" := Rec."Crear Pedidos"::"De Venta";
                        end;
                    }
                    field("¿Es un proyecto de venta?"; Venta)
                    {
                        ApplicationArea = All;
                        Caption = '¿Es un proyecto de venta?';
                        trigger OnValidate()
                        begin
                            if (Compra) and (venta) Then
                                Rec."Crear Pedidos" := Rec."Crear Pedidos"::"De Compra Y De Venta";
                            if (Compra) and (not venta) Then
                                Rec."Crear Pedidos" := Rec."Crear pedidos"::"De Compra";
                            if (not Compra) and (venta) Then
                                Rec."Crear pedidos" := Rec."Crear pedidos"::"De venta";
                        end;
                    }

                }

            }
            group(Step4)
            {
                Visible = Step4Visible;
                group(Group24)
                {
                    Caption = 'Pongamos los precios';
                    InstructionalText = 'Seleccione los precios de la línea';
                    group(Venta)
                    {
                        visible = venta;

                        field("¿Que precio de venta?"; Rec."Unit Price")
                        {
                            ApplicationArea = All;
                            Caption = '¿Que precio de venta?';

                        }
                        field("¿Qué descuento?"; Rec."% Dto. Venta")
                        {
                            ApplicationArea = All;
                            Caption = '¿Qué descuento?';
                        }


                    }
                    //lo mismo para compra
                    group(Compra)
                    {
                        visible = Compra;
                        field("¿Que precio de compra?"; Rec."Unit Cost")
                        {
                            ApplicationArea = All;
                            Caption = '¿Que precio de compra?';

                        }
                        field("¿Con qué descuento?"; Rec."% Dto. Compra")
                        {
                            ApplicationArea = All;
                            Caption = '¿Qué descuento?';
                        }
                    }


                }

            }
            group(Step5)
            {
                Visible = Step5Visible;
                group(Group25)
                {
                    Caption = 'Ya casi Está!';
                    InstructionalText = 'Vamos con las dimensiones?';
                    field("¿Qué departamento?"; Rec."Shortcut Dimension 1 Code")
                    {
                        Caption = '¿Qué departamento?';
                        ApplicationArea = All;


                    }
                    field("¿Qué programa?"; Rec."Shortcut Dimension 2 Code")
                    {
                        Caption = '¿Qué programa?';
                        ApplicationArea = All;

                    }
                    field("¿Qué dimension principal?"; Rec."Shortcut Dimension 3 Code")
                    {
                        Caption = '¿Qué dimension principal?';
                        ApplicationArea = All;

                    }
                    field("¿En qué zona?"; Rec."Shortcut Dimension 4 Code")
                    {
                        Caption = '¿En qué zona?';
                        ApplicationArea = All;

                    }
                    field("¿Qué tipo de soporte?"; Rec."Shortcut Dimension 5 Code")
                    {
                        Caption = '¿Qué tipo de soporte?';
                        ApplicationArea = All;

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
        Step: Option Start,Step1,Step2,Step3,Step4,Step5,Finish;
        BackActionEnabled: Boolean;
        FinishActionEnabled: Boolean;
        NextActionEnabled: Boolean;
        Step0Visible: Boolean;
        Step1Visible: Boolean;
        Step2Visible: Boolean;
        Step3Visible: Boolean;
        Step4Visible: Boolean;
        Step5Visible: Boolean;
        //Step6Visible: Boolean;
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
        Agrupado: Boolean;
        TipoRecurso: Code[20];
        Produccion: Boolean;
        Compra: Boolean;
        Venta: Boolean;
    /// <summary>
    /// Carga.
    /// </summary>
    /// <param name="PProyecto">code[20].</param>
    /// <param name="linea">Integer.</param>
    procedure Carga(PProyecto: code[20]; linea: Integer)
    var
        //Varaable Job Setup
        JobSetup: Record "Jobs Setup";
    //Variable Codeunit NoserieManagement


    begin
        //Crtear proyecto con numero correspondiente
        Rec.Init();
        Rec."Job No." := PProyecto;
        Rec."Job Task No." := '10';
        Rec."Line No." := linea;
        Rec.Insert();


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
            // Step::Step5:
            //     ShowStep5();
            Step::Step5:
                ShowStep5();
            Step::Finish:
                ShowStep5();
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
        if Backwards then
            Step := Step - 1
        else
            Step := Step + 1;

        EnableControls();
    end;

    local procedure ShowStep0();
    begin
        Step0Visible := true;

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

    // local procedure ShowStep5();
    // begin
    //     Step5Visible := true;
    // end;

    local procedure ShowStep5();
    begin
        Step5Visible := true;
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
        //Step6Visible := false;

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


    // local procedure CrearClienteDesdePlantilla(): Code[20]
    // var
    //     CustTemplate: Record "Customer Templ.";
    //     Customer: Record Customer;
    //     No: Code[20];
    // begin
    //     //Elije la plantilla de una lista
    //     if Page.RunModal(0, CustTemplate) <> Action::LookupOK then
    //         Error('No se ha seleccionado ninguna plantilla de cliente.');
    //     // Buscar la plantilla de cliente
    //     if Customer.FindLast() Then No := IncStr(Customer."No.") Else No := '10000';
    //     // Crear un nuevo registro de cliente
    //     Customer.Init();
    //     Customer."No." := No;  // Puedes reemplazar esto por una lógica para generar números de cliente
    //     Customer."Customer Posting Group" := CustTemplate."Customer Posting Group";
    //     Customer."Gen. Bus. Posting Group" := CustTemplate."Gen. Bus. Posting Group";
    //     Customer."VAT Bus. Posting Group" := CustTemplate."VAT Bus. Posting Group";
    //     Customer."Customer Price Group" := CustTemplate."Customer Price Group";
    //     Customer."Customer Disc. Group" := CustTemplate."Customer Disc. Group";
    //     Customer."Payment Terms Code" := CustTemplate."Payment Terms Code";
    //     Customer."Payment Method Code" := CustTemplate."Payment Method Code";
    //     // Agrega aquí más campos de la plantilla según sea necesario

    //     // Insertar el nuevo cliente
    //     if not Customer.Insert() then
    //         Error('No se pudo crear el cliente.');
    //     Commit();
    //     exit(Customer."No.");

    // end;

}