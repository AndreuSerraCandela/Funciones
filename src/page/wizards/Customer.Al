/// <summary>
/// Page Laerit File Management Setup Wizard (ID 50003).
/// </summary>
page 50003 "Wizard Clientes"
{
    Caption = 'Wizard Clientes';
    PageType = NavigatePage;
    SourceTable = Customer;
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
                field(MediaCustomersStandard; MediaCustomersStandard."Media Reference")
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
                field(MediaCustomersDone; MediaCustomersDone."Media Reference")
                {
                    ApplicationArea = All;
                    Editable = true;
                    ShowCaption = false;
                }

            }

            group(Step0)
            {
                Visible = Step0Visible;
                group("Bienvenido al proceso de creación de clientes")
                {
                    Caption = 'Bienvenido al proceso de creación de clientes';
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
                group(Group21)
                {
                    Caption = 'Empecemos por lo más fácil. ¿Qué cif tiene el cliente?';
                    InstructionalText = 'Escriba el Cif Cliente';
                    field("Cif Cliente"; Cif)
                    {
                        ApplicationArea = All;
                        trigger OnValidate()
                        var
                            //Variable Customer
                            Customer: Record Customer;
                            Company: Record Company;
                            Control: Codeunit ControlProcesos;
                            Primero: Boolean;
                            r18T: Record 18 temporary;
                        begin
                            Datosvisible := true;

                            Primero := true;
                            Numero := '<Teclee el código o déjelo en blanco>';
                            //Si se encuentra, error de ya existe   
                            Customer.SetRange("VAT Registration No.", Cif);
                            if Customer.FindFirst() then
                                if Not Confirm('El Cliente ya existe, ¿Quiere crear otro cliente con el mismo Cif?') then
                                    ERROR('El Cliente ya existe');
                            if Company.FindFirst() then
                                repeat
                                    if Control.Permiso_Empresas(Company.Name) then begin
                                        if Company.Name <> CompanyName then
                                            Customer.ChangeCompany(Company.Name);
                                        Customer.SetRange("VAT Registration No.", Cif);
                                        if Customer.FindFirst() then begin
                                            if Primero then begin
                                                Primero := false;
                                                Message('El Cif ya existe en la empresa %1 con el nombre %2 ', Company.Name, Customer.Name);
                                                if Confirm('¿Quiere recuperar los datos de este cliente? ', true) then begin
                                                    Rec.Init;
                                                    Rec."No." := 'temp';
                                                    Rec.Name := Customer.Name;
                                                    Rec."Name 2" := Customer."Name 2";
                                                    Rec.Address := Customer.Address;
                                                    Rec."Address 2" := Customer."Address 2";
                                                    Rec."Post Code" := Customer."Post Code";
                                                    Rec."City" := Customer."City";
                                                    Rec."Country/Region Code" := Customer."Country/Region Code";
                                                    Rec.County := Customer.County;
                                                    Rec."Phone No." := Customer."Phone No.";
                                                    Rec."Fax No." := Customer."Fax No.";
                                                    Rec."E-Mail" := Customer."E-Mail";
#if CLEAN24
#pragma warning disable AL0432
#pragma warning disable AL0432
                                                    Rec."Home Page" := Customer."Home Page";
#pragma warning restore AL0432
#pragma warning restore AL0432
#else
#pragma warning disable AL0432
                                                    Rec."Home Page" := Customer."Home Page";
#endif
                                                    r18T := Customer;
                                                    r18T.Insert();
                                                    Rec.Insert();
                                                end else begin

                                                    Error('No podemos continuar con el proceso, el cliente no se ha creado. Contacte con el administrador ');
                                                end;



                                            end else begin
                                                Customer.Name := r18t.Name;
                                                // lo mismo para todos los nombres y datos de direccióm
                                                Customer."Name 2" := r18t."Name 2";
                                                Customer.Address := r18t.Address;
                                                Customer."Address 2" := r18t."Address 2";
                                                Customer."Post Code" := r18t."Post Code";
                                                Customer."City" := r18t."City";
                                                Customer."Country/Region Code" := r18t."Country/Region Code";
                                                Customer.County := r18t.County;
                                                Customer."Phone No." := r18t."Phone No.";
                                                Customer."Fax No." := r18t."Fax No.";
                                                Customer."E-Mail" := r18t."E-Mail";
#pragma warning disable AL0432
#pragma warning disable AL0432
                                                Customer."Home Page" := r18t."Home Page";
#pragma warning restore AL0432
#pragma warning restore AL0432

                                                Customer.Modify();
                                            end;
                                        end;
                                    end;
                                until Company.Next() = 0;

                        end;

                    }

                }
                group(Group20)
                {
                    visible = Datosvisible;

                    Caption = 'Nº y Nombre del Cliente';
                    InstructionalText = 'Si deja en blanco el nº del cliente se generará automáticamente';

                    //You might want to add fields here
                    field("Código"; Numero)
                    {
                        ApplicationArea = All;
                        trigger OnValidate()
                        var
                            //Variable Customer
                            Cliente: Record Customer;
                            Cliente2: Record Customer temporary;
                        begin
                            //Si se encuentra, error de ya existe   
                            if Numero = '<Teclee el código o déjelo en blanco>' Then Numero := '';
                            if Cliente.Get(Numero) then
                                ERROR('El Cliente ya existe');
                            Contacto.Init();
                            Contactofirma.Init();
                            if Rec."No." <> '' Then
                                Cliente2 := Rec;
                            if Rec.Delete() Then
                                Rec.Init();
                            Rec."No." := Numero;
                            Rec.Insert(true);
                            Numero := Rec."No.";
                            if Cliente.Get(Numero) then
                                ERROR('El Cliente ya existe');
                            if Cliente2."No." <> '' Then
                                Rec := Cliente2;
                            Rec."No." := Numero;
                            Rec."VAT Registration No." := Cif;
                            if Cif <> '' Then begin
                                ContactoVisible := true;
                                NextActionEnabled := true;
                            end;
                            Rec.Modify();
                        end;

                    }

                    field("Nombre"; Rec.Name)
                    {
                        ApplicationArea = All;
                        trigger OnValidate()
                        begin
                            ContactoVisible := true;
                            NextActionEnabled := true;
                        end;
                    }
                }
                group(Group19)
                {
                    Visible = ContactoVisible;
                    Caption = 'Datos de contacto';
                    InstructionalText = 'Escriba los datos de contacto del Cliente';
                    field("Dirección"; Rec.Address)
                    {
                        ApplicationArea = All;

                    }
                    field("Código Postal"; Rec."Post Code")
                    {
                        ApplicationArea = All;

                    }
                    field("Población"; Rec.City)
                    {
                        ApplicationArea = All;

                    }
                    field("Provincia"; Rec."County")
                    {
                        ApplicationArea = All;

                    }
                    field("País"; Rec."Country/Region Code")
                    {
                        ApplicationArea = All;

                    }

                    field("Teléfono"; Rec."Phone No.")
                    {
                        ApplicationArea = All;

                    }
                    field("Fax"; Rec."Fax No.")
                    {
                        ApplicationArea = All;

                    }

                    field("Email"; Rec."E-Mail")
                    {
                        ApplicationArea = All;

                    }
#pragma warning disable AL0432
                    field("Web"; Rec."Home Page")
#pragma warning restore AL0432
                    {
                        ApplicationArea = All;

                    }
                }
            }
            group(Step2)
            {
                Visible = Step2Visible;
                group(Group27)
                {
                    Caption = 'Ahora viene lo complicado!';
                    InstructionalText = 'Vamos con los datos de facturación. Ojo al dato ;)';
                    field("¿Como vamos a enviar las facturas?"; Rec."Document Sending Profile")
                    {
                        Caption = '¿Como vamos a enviar las facturas?';
                        ApplicationArea = All;

                    }
                    field("¿A quien le vamos a enviar las facturuas?"; rec."E-Mail-Facturación")
                    {
                        Caption = '¿A que email vamos a enviar las facturas?';
                        ApplicationArea = All;

                    }
                    field("¿Quieres aplicar una plantilla?"; Plantilla)
                    {
                        Caption = '¿Quieres aplicar una plantilla?';
                        ApplicationArea = All;
                        trigger OnValidate()
                        var
                            Plant: Record "Customer Templ.";
                        begin
                            if Page.RunModal(0, Plant) = Action::LookupOK then begin
                                ApplyTemplate(Rec, Plant, true);
                            end;
                        end;
                    }
                    field("¿Que tipo de cliente és?"; Rec."Customer Posting Group")
                    {
                        Caption = '¿Que tipo de cliente és?';
                        ToolTip = 'Agencias, Ayuntamientos,Emp.Grupo,Govern,Local,Nacional,..';
                        ApplicationArea = All;

                    }
                    field("Vamos Con el grupo contable"; Rec."Gen. Bus. Posting Group")
                    {
                        Caption = 'Vamos Con el grupo contable. Ojo';
                        ToolTip = 'El grupo contable es el que determina las cuentas contables que se aplican a las facturas. Nacional para clientes nacionales, local para clientes locales, EMP.GRUPO para empresas del grupo,UE para clientes de la UE y IMPORT para clientes fuera de la UE';

                        ApplicationArea = All;
                        trigger OnValidate()
                        begin
                            Rec."VAT Bus. Posting Group" := 'NACIONAL';
                        end;

                    }
                    field("¿Que iva le corresponde?"; Rec."VAT Bus. Posting Group")
                    {
                        Caption = '¿Que iva le corresponde?';
                        ToolTip = 'El grupo de IVA es el que determina el tipo de IVA que se aplica a las facturas. Nacional para todos, excepto en ningún caso';

                        ApplicationArea = All;

                    }


                    field("¿Como cobraremos?"; Rec."Payment Method Code")
                    {
                        Caption = '¿Como cobraremos?';
                        ApplicationArea = All;

                    }
                    field("¿Cuando cobraremos?"; Rec."Payment Terms Code")
                    {
                        Caption = '¿Cuando cobraremos?';
                        ApplicationArea = All;
                        // trigger OnValidate()
                        // begin
                        //     irpfflag := true;
                        // end;
                    }
                    field("¿Tenes el Iban?"; Iban)
                    {
                        Caption = '¿Tenes el Iban?';
                        ApplicationArea = All;
                        trigger OnValidate()
                        var
                            CustomerBankAccount: Record "Customer Bank Account";
                        begin
                            if Iban <> '' then begin
                                CustomerBankAccount.Init();
                                CustomerBankAccount."Customer No." := Rec."No.";
                                CustomerBankAccount.Code := '1';
                                CustomerBankAccount.Validate(IBAN, Iban);
                                CustomerBankAccount.Insert;
                                Rec."Preferred Bank Account Code" := '1';
                            end;

                        end;
                    }
                    field("¿Tenemos alguna preferencia para nuestro banco?"; Rec."Banco transferencia")
                    {
                        Caption = '¿Tenemos alguna preferencia para nuestro banco?';
                        ApplicationArea = All;

                    }
                    field("¿Qué Comercial le corresponde?"; Rec."Salesperson Code")
                    {
                        Caption = '¿Qué Comercial le corresponde?';
                        ApplicationArea = All;

                    }
                    // group(Irpf)
                    // {
                    //     Visible = Irpfflag;

                    //     Caption = 'Tiene Irpf';
                    //     InstructionalText = 'Escriba los datos de Irpf';
                    //     field("Irpf Cliente"; Rec."Retention Group Code (IRPF)")
                    //     {
                    //         Caption = 'Irpf Cliente';
                    //         ApplicationArea = All;

                    //     }
                    // }

                }
            }
            group(Step3)
            {
                Visible = Step3Visible;
                Caption = '¿Es un cliente de la administración?';
                InstructionalText = 'Indique los datos de la administración';
                field("Oficina Contable"; Rec."B2R Cod. Fiscal")
                {
                    ApplicationArea = All;
                    trigger OnValidate()
                    begin
                        Rec."B2R Facturación electrónica" := true;
                        Rec."B2R Formato Envío" := Rec."B2R Formato Envío"::Facturae;

                    end;
                }
                field("Órgano Gestor"; Rec."B2R Cod. Receptor")
                {
                    ApplicationArea = All;

                }
                field("Unidad Tramitadora"; Rec."B2R Cod. Pagador")
                {
                    ApplicationArea = All;

                }

            }


            group(Step4)
            {
                Visible = Step4Visible;
                group(Group23)
                {
                    Caption = 'Ahora vamos a crear el contacto';
                    InstructionalText = 'Quien firma los contratos';
                    field("¿Como se llama?"; ContactoFirma."First Name")
                    {
                        Caption = '¿Como se llama?';
                        ApplicationArea = All;

                    }

                    field("Primer Apellido"; ContactoFirma."Middle Name")
                    {
                        Caption = 'Primer Apellido';
                        ApplicationArea = All;

                    }
                    field("Segundo Apellido"; ContactoFirma.Surname)
                    {
                        Caption = 'Segundo Apellido';
                        ApplicationArea = All;

                    }
                    field("Ahora el email"; ContactoFirma."E-Mail")
                    {
                        Caption = 'Ahora el email';
                        ApplicationArea = All;

                    }
                    field("¿Como va a firmar?"; ContactoFirma."Tipo firma")
                    {
                        Caption = '¿Como va a firmar?';
                        ApplicationArea = All;

                    }
                    field("¿Y el teléfono?"; ContactoFirma."Mobile Phone No.")
                    {
                        Caption = '¿Y el móvil?';
                        ApplicationArea = All;
                        trigger OnValidate()
                        begin
                            ContactoFirma.Firmante := true;
                            ContactoFirma.posKey := '2';
                        end;

                    }
                    field("¿Qué cargo tiene?"; ContactoFirma."Job Title")
                    {
                        Caption = '¿Qué cargo tiene?';
                        ApplicationArea = All;

                    }
                }

            }
            group(Step5)
            {
                Visible = Step5Visible;
                group(Group24)
                {
                    Caption = 'Ánimo, queda muy poco!';
                    InstructionalText = 'Secmentemos el cliente';
                    field("Escribe un grupo industria"; EligirGrupo)
                    {
                        Caption = 'Elija a que grupos industria pertenece';
                        ApplicationArea = All;
                        trigger OnValidate()
                        var
                            IndustryGroup: Record "Industry Group";
                        begin
                            EligirGrupo := false;
                            Commit();
                            if Page.RunModal(0, IndustryGroup) = Action::LookupOK then begin
                                IndG."Industry Group Code" := IndustryGroup."Code";
                                IndG.Insert;
                                if grIndustrias = '' Then
                                    grIndustrias := IndustryGroup."Code"
                                else
                                    grIndustrias := grIndustrias + ',' + IndustryGroup."Code";
                            end;
                        end;
                    }
                    field("Grupos Industria"; grIndustrias)
                    {
                        ApplicationArea = All;
                        trigger OnAssistEdit()
                        begin
                            Commit();
                            grIndustrias := '';
                            Page.RunModal(0, IndG);
                            if IndG.FindFirst()
                            then
                                repeat
                                    if grIndustrias = '' Then
                                        grIndustrias := IndG."Industry Group Code"
                                    else
                                        grIndustrias := grIndustrias + ',' + IndG."Industry Group Code";
                                until IndG.Next() = 0;
                        end;
                    }
                    field("¿Quiere Crear Grupos de correo?"; EligirGrupoCorreo)
                    {
                        Caption = 'Elija a que grupos correo pertenece';
                        ApplicationArea = All;
                        trigger OnValidate()
                        var
                            IndustryGroup: Record "Mailing Group";
                        begin
                            EligirGrupoCorreo := false;
                            Commit();
                            if Page.RunModal(0, IndustryGroup) = Action::LookupOK then begin
                                ContGrupoCorreo."Mailing Group Code" := IndustryGroup."Code";
                                ContGrupoCorreo.Insert;
                                if grCorreo = '' Then
                                    grCorreo := IndustryGroup."Code"
                                else
                                    grCorreo := grCorreo + ',' + IndustryGroup."Code";
                            end;
                        end;
                    }
                    field("Grupos Correo"; grCorreo)
                    {
                        ApplicationArea = All;
                        trigger OnAssistEdit()
                        begin
                            Commit();
                            grCorreo := '';
                            Page.RunModal(0, ContGrupoCorreo);
                            if ContGrupoCorreo.FindFirst()
                            then
                                repeat
                                    if grCorreo = '' Then
                                        grCorreo := ContGrupoCorreo."Mailing Group Code"
                                    else
                                        grCorreo := grCorreo + ',' + ContGrupoCorreo."Mailing Group Code";
                                until ContGrupoCorreo.Next() = 0;
                        end;
                    }


                }

            }
            group(Step6)
            {
                Visible = Step6Visible;
                group(Group25)
                {
                    Caption = 'Por último, vamos a responder a un pequeño cuestionario sobre el cliente';
                    InstructionalText = 'Seleccione el tipo de Clientes';
                    field("Cuestionario"; AbreCuestionario)
                    {
                        ApplicationArea = All;
                        trigger OnValidate()
                        var
                            ProfileManagement: Codeunit ProfileManagement;
                        begin
                            AbreCuestionario := false;
                            ProfileManagement.ShowContactQuestionnaireCard(Contactos, '', 0);
                        end;

                    }


                }


                group("Esto es todo!")
                {
                    Caption = 'Esto es todo!';
                    group(Group30)
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
    var
        Finalizado: Boolean;
        AbreCuestionario: Boolean;
        EligirGrupoCorreo: Boolean;
        ContGrupoCorreo: Record "Contact Mailing Group" temporary;
        GrupoCorreo: Record "Mailing Group";
        ContactoVisible: Boolean;
        Numero: Text;
        ObservacionesPeligrosidadVisible: Boolean;
        ClienteAgrupadoVisible: Boolean;
        ProduccionVisible: Boolean;
        Ubicacion: Text;
        LLamar: Boolean;
        MediaRepositoryDone: Record "Media Repository";
        MediaRepositoryStandard: Record "Media Repository";
        MediaCustomersDone: Record "Media Resources";
        MediaCustomersStandard: Record "Media Resources";
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

        Datosvisible: Boolean;
        TopBannerVisible: Boolean;
        Iban: Text[50];
        //Irpfflag: Boolean;
        ContactoFirma: Record "Contact" temporary;
        Contacto: Record "Contact" temporary;
        IndG: Record "Contact Industry Group" temporary;
        EligirGrupo: Boolean;
        Contactos: Record Contact;
        Customer: Record Customer;
        Cif: Text[30];

        grIndustrias: Text;
        grCorreo: Text;
        Plantilla: Boolean;

    local procedure ApplyTemplate(var Customer: Record Customer; CustomerTempl: Record "Customer Templ."; UpdateExistingValues: Boolean)
    var
        CustomerRecRef: RecordRef;
        EmptyCustomerRecRef: RecordRef;
        CustomerTemplRecRef: RecordRef;
        EmptyCustomerTemplRecRef: RecordRef;
        CustomerFldRef: FieldRef;
        EmptyCustomerFldRef: FieldRef;
        CustomerTemplFldRef: FieldRef;
        EmptyCustomerTemplFldRef: FieldRef;
        IsHandled: Boolean;
        i: Integer;
        FieldExclusionList: List of [Integer];
    begin

        CustomerRecRef.GetTable(Customer);
        EmptyCustomerRecRef.Open(Database::Customer);
        EmptyCustomerRecRef.Init();
        CustomerTemplRecRef.GetTable(CustomerTempl);
        EmptyCustomerTemplRecRef.Open(Database::"Customer Templ.");
        EmptyCustomerTemplRecRef.Init();

        FillFieldExclusionList(FieldExclusionList);

        for i := 3 to CustomerTemplRecRef.FieldCount do begin
            CustomerTemplFldRef := CustomerTemplRecRef.FieldIndex(i);
            if TemplateFieldCanBeProcessed(CustomerTemplFldRef.Number, FieldExclusionList) then begin
                CustomerFldRef := CustomerRecRef.Field(CustomerTemplFldRef.Number);
                EmptyCustomerFldRef := EmptyCustomerRecRef.Field(CustomerTemplFldRef.Number);
                EmptyCustomerTemplFldRef := EmptyCustomerTemplRecRef.Field(CustomerTemplFldRef.Number);
                if (not UpdateExistingValues and (CustomerFldRef.Value = EmptyCustomerFldRef.Value) and (CustomerTemplFldRef.Value <> EmptyCustomerTemplFldRef.Value)) or
                   (UpdateExistingValues and (CustomerTemplFldRef.Value <> EmptyCustomerTemplFldRef.Value))
                then
                    CustomerFldRef.Value := CustomerTemplFldRef.Value;
            end;
        end;
        CustomerRecRef.SetTable(Customer);
        if CustomerTempl."Invoice Disc. Code" <> '' then
            Customer."Invoice Disc. Code" := CustomerTempl."Invoice Disc. Code";
        Customer.Validate("Payment Method Code", CustomerTempl."Payment Method Code");
        if CustomerTempl."Payment Days Code" <> '' then
            Customer."Payment Days Code" := CustomerTempl."Payment Days Code";
        if CustomerTempl."Non-Paymt. Periods Code" <> '' then
            Customer."Non-Paymt. Periods Code" := CustomerTempl."Non-Paymt. Periods Code";

        Customer.Modify();
    end;

    local procedure FillFieldExclusionList(var FieldExclusionList: List of [Integer])
    var
        CustomerTempl: Record "Customer Templ.";
    begin
        FieldExclusionList.Add(CustomerTempl.FieldNo("Invoice Disc. Code"));
        FieldExclusionList.Add(CustomerTempl.FieldNo("No. Series"));
        FieldExclusionList.Add(CustomerTempl.FieldNo("Payment Method Code"));
        FieldExclusionList.Add(CustomerTempl.FieldNo("Payment Days Code"));
        FieldExclusionList.Add(CustomerTempl.FieldNo("Non-Paymt. Periods Code"));


    end;

    local procedure TemplateFieldCanBeProcessed(FieldNumber: Integer; FieldExclusionList: List of [Integer]): Boolean
    var
        CustomerField: Record Field;
        CustomerTemplateField: Record Field;
    begin
        if FieldExclusionList.Contains(FieldNumber) or (FieldNumber > 2000000000) then
            exit(false);

        if not (CustomerField.Get(Database::Customer, FieldNumber) and CustomerTemplateField.Get(Database::"Customer Templ.", FieldNumber)) then
            exit(false);

        if (CustomerField.Class <> CustomerField.Class::Normal) or (CustomerTemplateField.Class <> CustomerTemplateField.Class::Normal) or
            (CustomerField.Type <> CustomerTemplateField.Type) or (CustomerField.FieldName <> CustomerTemplateField.FieldName) or
            (CustomerField.Len <> CustomerTemplateField.Len) or
            (CustomerField.ObsoleteState = CustomerField.ObsoleteState::Removed) or
            (CustomerTemplateField.ObsoleteState = CustomerTemplateField.ObsoleteState::Removed)
        then
            exit(false);

        exit(true);
    end;

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


    trigger OnClosePage();
    begin
        if Not Finalizado Then Error('No puede cerrar el formulario sin finalizar');
    end;
    /// <summary>    
    /// Carga.
    /// </summary>
    procedure Carga()
    var
        Res: Record Customer;
    begin
        Rec.Init();

    end;
    /// <summary>
    /// Recupera.
    /// </summary>
    /// <returns>Return value of type Code[20].</returns>
    procedure Recupera(): Code[20];
    begin
        exit(Customer."No.");
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
                ShowFinish();
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
    var
        Res: Record Customer;

    begin


        Finalizado := true;

        CurrPage.Close();
    end;

    local procedure NextStep(Backwards: Boolean);
    begin
        CompruebaPaso(Step);

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
        NextActionEnabled := false;
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
    //crea hasta el 8
    local procedure ShowStep6();
    var
        Firmante: Record "Contact";
#if CLEAN24
#pragma warning disable AL0432
        NoSeriesMgt: Codeunit "NoSeriesManagement";
#pragma warning restore AL0432
#else
        NoSeriesMgt: Codeunit "No. Series";
#endif
        RMSetup: Record "Marketing Setup";
        Rel: Record "Contact Business Relation";
        IndG2: Record "Contact Industry Group";
        ContGrupoCorreo2: Record "Contact Mailing Group";
    begin
        RMSetup.Get();
        Step6Visible := true;
        if Customer.Get(Rec."No.") Then Customer.Delete();
        Customer.Init;
        Customer := Rec;
        Customer.Insert;
        with Contactos do begin
            Init();
            TransferFields(Customer);
            Validate(Name);
            Validate("E-Mail");
            "No." := '';
            "No. Series" := '';
            RMSetup.TestField("Contact Nos.");
#if CLEAN24
#pragma warning disable AL0432
            NoSeriesMgt.InitSeries(rMSetup."Contact Nos.", '', 0D, "No.", "No. Series");
#pragma warning restore AL0432
#else
            If NoSeriesMgt.AreRelated(rMSetup."Contact Nos.", "No. Series") THEN
                Rec."No. Series" := rMSetup."Contact Nos.";
#endif
            Type := Type::Person;
            SetSkipDefault();
            Insert(true);
        end;
        with Rel do begin
            Init();
            "Contact No." := Contactos."No.";
            "Business Relation Code" := RMSetup."Bus. Rel. Code for Customers";
            "Link to Table" := "Contact Business Relation Link To Table"::Customer;
            "No." := Customer."No.";
            Insert(true);
        end;
        with Firmante do begin
            Init();
            Type := Type::Person;
            Validate("Company No.", Contactos."No.");
            Validate("First Name", ContactoFirma."First Name");
            Validate("Middle Name", ContactoFirma."Middle Name");
            Validate(Surname, ContactoFirma.Surname);
            Validate("E-Mail", ContactoFirma."E-Mail");
            Validate("Phone No.", ContactoFirma."Phone No.");
            Validate("Mobile Phone No.", ContactoFirma."Mobile Phone No.");
            Validate(Firmante, ContactoFirma.Firmante);
            Validate(posKey, ContactoFirma.posKey);
            "No." := '';
            "No. Series" := '';
            RMSetup.TestField("Contact Nos.");
#if CLEAN24
#pragma warning disable AL0432
            NoSeriesMgt.InitSeries(rMSetup."Contact Nos.", '', 0D, "No.", "No. Series");
#pragma warning restore AL0432
#else
            If NoSeriesMgt.AreRelated(rMSetup."Contact Nos.", "No. Series") THEN
                Rec."No. Series" := rMSetup."Contact Nos.";
#endif
            Type := Type::Person;
            SetSkipDefault();
            Insert(true);
        end;
        if IndG.FindFirst() then
            repeat
                IndG2 := IndG;
                IndG2."Contact No." := Contactos."No.";
                IndG2.Insert(true);
            until IndG.Next() = 0;
        //lo mismo para gruposcorreo
        if ContGrupoCorreo.FindFirst() then
            repeat
                ContGrupoCorreo2 := ContGrupoCorreo;
                ContGrupoCorreo2."Contact No." := Contactos."No.";
                ContGrupoCorreo2.Insert(true);
            until ContGrupoCorreo.Next() = 0;
        NextActionEnabled := false;
        FinishActionEnabled := true;
    end;

    local procedure ShowFinish();
    var

    begin
        Step6Visible := true;

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
        //añade hasta el 9
        Step4Visible := false;
        Step5Visible := false;
        Step6Visible := false;


    end;

    local procedure LoadTopBanners();
    begin
        if MediaRepositoryStandard.Get('AssistedSetup-NoText-400px.png', Format(CurrentClientType())) and
            MediaRepositoryDone.Get('AssistedSetupDone-NoText-400px.png', Format(CurrentClientType()))
        then
            if MediaCustomersStandard.Get(MediaRepositoryStandard."Media Resources Ref") and
                MediaCustomersDone.Get(MediaRepositoryDone."Media Resources Ref")
        then
                TopBannerVisible := MediaCustomersDone."Media Reference".HasValue();
    end;

    local procedure CompruebaPaso(Step: Option Start,Step1,Step2,Step3,Step4,Step5,Step6,Finish)
    begin
        // Hacer un tesfield a los campos incluidos en cada step
        // case Step of
        //     Step::Step3:
        //         //Testfield a todos los campos del step2
        //         begin
        //             Rec.TestField("VAT Bus. Posting Group");
        //             Rec.TestField("Gen. Bus. Posting Group");
        //             Rec.TestField("Customer Posting Group");
        //             Rec.TestField("E-Mail-Facturación");
        //             Rec.TestField("Payment Method Code");
        //             Rec.TestField("Payment Terms Code");
        //         end;

        //     Step::Step2:
        //         begin
        //             Rec.TestField("No.");
        //             Rec.TestField("Name");
        //         end;
        // // Step::Step4:
        // //     begin
        // //         Rec.TestField("Customer Group No.");
        // //         // Rec.TestField("Categoria");
        // //     end;
        // // Step::Step8:
        // //     begin
        // //         Rec.TestField("global Dimension 1 Code");
        // //         Rec.TestField("global Dimension 2 Code");
        // //         Rec.TestField("global Dimension 3 Code");
        // //         Rec.TestField("global Dimension 4 Code");
        // //         Rec.TestField("global Dimension 5 Code");
        // //     end;

        // end;
    end;
}