/// <summary>
/// Page Elige Proyecto (ID 50097).
/// </summary>
page 50046 "Elige Proyecto"
{
    SourceTable = "Job Planning Line";
    SourceTableTemporary = true;
    PageType = Card;
    layout
    {
        area(Content)
        {
            part(SubPage; "Asignar Producciones")
            {
                Caption = 'Asignación actual';
                ApplicationArea = ALL;
                Editable = false;
                SubPageLink = "Line No." = FIELD("Line No."),
                            "Job No." = FIELD("Job No.");
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action("Proyecto actual")
            {
                Caption = 'Proyecto actúal';
                Image = Job;
                ApplicationArea = ALL;

                trigger OnAction()
                BEGIN
                    Actual := TRUE;
                    Proyecto := Rec."Job No.";
                END;
            }
            action("Otro Proyecto")
            {
                Caption = 'Otro Proyecto';
                Image = ChangeTo;
                ApplicationArea = ALL;
                trigger OnAction()
                BEGIN
                    Actual := FALSE;
                    MESSAGE('Elija Proyecto');
                    // {if rJob."No."='' THEN BEGIN
                    // //  rJob.SETRANGE(rJob."Creation Date",010115D,311215D);
                    // rJob.FINDFIRST;
                    // rJob.SETRANGE(rJob."Creation Date");
                    // END;
                    // rJob.GET(rJob."No.");
                    // rJob.SETRANGE(rJob."Bill-to Customer No.",rJob."Bill-to Customer No."); }
                    if Page.RUNMODAL(0, rJob) = ACTION::LookupOK THEN
                        Proyecto := rJob."No.";
                END;
            }
            action(Atras)
            {
                Image = PreviousSet;
                ApplicationArea = ALL;
                Caption = 'Atrás';
                trigger OnAction()
                BEGIN
                    CurrPage.CLOSE;
                END;
            }
            action(Remplazar)
            {
                Caption = 'Remplazar';
                ApplicationArea = ALL;
                trigger OnAction()
                VAR
                    r1003: Record 1003;
                    fList: Page 1007;
                    r1003Otra: Record 1003;
                    rRes: Record Resource;
                    rProduOtra: Record "Produccines Relacionadas";
                    Job: Record Job;
                    Contrato: Record "Sales Header";
                BEGIN
                    Job.Get(Rec."Job No.");
                    If Contrato.Get(Contrato."Document Type"::Order, Job."Nº Contrato") then
                        If Contrato.Estado = Contrato.Estado::Firmado THEN
                            ERROR('No se puede eliminar una producción de un contrato firmado');
                    Rec.BorrarecursosRelacionados(Rec."Line No.", Rec."Job No.");
                    MESSAGE('Elija las líneas y pulse el boton seleccionar');
                    COMMIT;
                    r1003.RESET;
                    if Empresa <> COMPANYNAME THEN
                        r1003.CHANGECOMPANY(Empresa);
                    rRes.Get(Rec."No.");
                    If Empresa <> COMPANYNAME THEN
                        rRes.Testfield(rRes."Nº En Empresa origen");
                    r1003.SETRANGE(r1003."Job No.", Proyecto);
                    if Actual THEN
                        r1003.SETFILTER(r1003."Line No.", '<>%1', Rec."Line No.");
                    CLEAR(fList);
                    fList.SETTABLEVIEW(r1003);
                    fList.LOOKUPMODE := TRUE;
                    if Empresa <> COMPANYNAME THEN
                        fList.CambiaEmpresa(Empresa);

                    fList.RUNMODAL;
                    fList.Devuelvemarcados(r1003);
                    r1003.MARKEDONLY := TRUE;
                    if r1003.FINDFIRST THEN
                        REPEAT
                            if rProdu.GET(Rec."Line No.", Rec."Job No.", r1003."Line No.", r1003."Job No.") THEN rProdu.DELETE;
                            if Empresa <> COMPANYNAME THEN begin
                                rProduOtra.CHANGECOMPANY(Empresa);
                                r1003Otra.SetRange("Job No.", r1003."Job No.");
                                r1003Otra.SetRange("No.", rRes."Nº En Empresa origen");
                                If r1003Otra.FindFirst then
                                    if rProduOtra.GET(r1003Otra."Line No.", r1003Otra."Job No.", r1003."Line No.", r1003."Job No.") THEN rProduOtra.DELETE;

                            end;
                            rProdu.INIT;
                            rProdu."Line No." := Rec."Line No.";
                            rProdu."Job No." := Rec."Job No.";
                            rProdu."No." := Rec."No.";
                            rProdu."Line No.2" := r1003."Line No.";
                            case Rec.Type of
                                Rec.Type::"Activo fijo":
                                    rProdu.Type := rProdu.Type::"Activo Fijo";
                                Rec.Type::Familia:
                                    rProdu.Type := rProdu.Type::Familia;
                                Rec.Type::"G/L Account":
                                    rProdu.Type := rProdu.Type::Cuenta;
                                Rec.Type::Item:
                                    rProdu.Type := rProdu.Type::Producto;
                                Rec.Type::Resource:
                                    rProdu.Type := rProdu.Type::Recurso;
                                Rec.Type::Text:
                                    rProdu.Type := rProdu.Type::Texto;
                            End;
                            rProdu."Job No.2" := r1003."Job No.";
                            case r1003.Type of
                                r1003.Type::"Activo fijo":
                                    rProdu.Type2 := rProdu.Type2::"Activo Fijo";
                                r1003.Type::Familia:
                                    rProdu.Type2 := rProdu.Type2::Familia;
                                r1003.Type::"G/L Account":
                                    rProdu.Type2 := rProdu.Type2::Cuenta;
                                r1003.Type::Item:
                                    rProdu.Type2 := rProdu.Type2::Producto;
                                r1003.Type::Resource:
                                    rProdu.Type2 := rProdu.Type2::Recurso;
                                r1003.Type::Text:
                                    rProdu.Type2 := rProdu.Type2::Texto;
                            End;
                            rProdu."No.2" := r1003."No.";
                            rProdu.Empresa := Empresa;
                            if rRes.GET(r1003."No.") THEN
                                if rRes.Producción THEN
                                    ERROR('Que se supone que desea hacer; Como es posible que asigne\'
                                            + 'producción a un recurso de producción, que sentido tiene !!!!');
                            rProdu.Description := Rec.Description;
                            rProdu."Description 2" := r1003.Description;
                            rProdu.INSERT;
                            If Empresa <> COMPANYNAME THEN begin
                                r1003Otra.SetRange("Job No.", r1003."Job No.");
                                r1003Otra.SetRange("No.", rRes."Nº En Empresa origen");
                                If r1003Otra.FindFirst then begin
                                    rProduOtra := rProdu;
                                    rProduOtra.ChangeCompany(Empresa);
                                    rProduOtra."Job No." := r1003Otra."Job No.";
                                    rProduOtra."Line No." := r1003Otra."Line No.";
                                    rProduOtra."No." := r1003Otra."No.";
                                    rProduOtra.Insert();
                                end;
                            end;
                        UNTIL r1003.NEXT = 0;
                    CurrPage.CLOSE;
                END;
            }

            action(Añadir)
            {
                Image = Add;
                ApplicationArea = ALL;
                Caption = 'Añadir';
                trigger OnAction()
                VAR
                    r1003: Record 1003;
                    r1003Otra: Record 1003;
                    Reserva: Record Reserva;
                    rRes: Record Resource;
                    fList: Page 1007;
                    rProduOtra: Record "Produccines Relacionadas";
                BEGIN
                    MESSAGE('Elija las líneas y pulse el boton seleccionar');
                    COMMIT;
                    if Empresa <> COMPANYNAME THEN
                        r1003.CHANGECOMPANY(Empresa);
                    rRes.Get(Rec."No.");
                    If Empresa <> COMPANYNAME THEN
                        rRes.Testfield(rRes."Nº En Empresa origen");
                    r1003.RESET;

                    r1003.SETRANGE(r1003."Job No.", Proyecto);
                    if Actual THEN
                        r1003.SETFILTER(r1003."Line No.", '<>%1', Rec."Line No.");
                    CLEAR(fList);
                    fList.SETTABLEVIEW(r1003);
                    fList.LOOKUPMODE := TRUE;
                    if Empresa <> COMPANYNAME THEN
                        fList.CambiaEmpresa(Empresa);
                    fList.RUNMODAL;
                    fList.Devuelvemarcados(r1003);
                    r1003.MARKEDONLY := TRUE;
                    if r1003.FINDFIRST THEN
                        REPEAT
                            if rProdu.GET(Rec."Line No.", Rec."Job No.", r1003."Line No.", r1003."Job No.") THEN rProdu.DELETE;
                            if Empresa <> COMPANYNAME THEN begin
                                rProduOtra.CHANGECOMPANY(Empresa);
                                r1003Otra.SetRange("Job No.", r1003."Job No.");
                                r1003Otra.SetRange("No.", rRes."Nº En Empresa origen");
                                If r1003Otra.FindFirst then
                                    if rProduOtra.GET(r1003Otra."Line No.", r1003Otra."Job No.", r1003."Line No.", r1003."Job No.") THEN rProduOtra.DELETE;

                            end;
                            rProdu.INIT;
                            rProdu."Line No." := Rec."Line No.";
                            rProdu."Job No." := Rec."Job No.";
                            rProdu."No." := Rec."No.";
                            rProdu."Line No.2" := r1003."Line No.";
                            case Rec.Type of
                                Rec.Type::"Activo fijo":
                                    rProdu.Type := rProdu.Type::"Activo Fijo";
                                Rec.Type::Familia:
                                    rProdu.Type := rProdu.Type::Familia;
                                Rec.Type::"G/L Account":
                                    rProdu.Type := rProdu.Type::Cuenta;
                                Rec.Type::Item:
                                    rProdu.Type := rProdu.Type::Producto;
                                Rec.Type::Resource:
                                    rProdu.Type := rProdu.Type::Recurso;
                                Rec.Type::Text:
                                    rProdu.Type := rProdu.Type::Texto;
                            End;
                            rProdu."Job No.2" := r1003."Job No.";
                            case r1003.Type of
                                r1003.Type::"Activo fijo":
                                    rProdu.Type2 := rProdu.Type2::"Activo Fijo";
                                r1003.Type::Familia:
                                    rProdu.Type2 := rProdu.Type2::Familia;
                                r1003.Type::"G/L Account":
                                    rProdu.Type2 := rProdu.Type2::Cuenta;
                                r1003.Type::Item:
                                    rProdu.Type2 := rProdu.Type2::Producto;
                                r1003.Type::Resource:
                                    rProdu.Type2 := rProdu.Type2::Recurso;
                                r1003.Type::Text:
                                    rProdu.Type2 := rProdu.Type2::Texto;
                            End;
                            rProdu."Job No.2" := r1003."Job No.";
                            rProdu.Empresa := Empresa;
                            if Empresa <> COMPANYNAME THEN rRes.CHANGECOMPANY(Empresa);
                            if rRes.GET(r1003."No.") THEN
                                if rRes.Producción THEN
                                    ERROR('Que se supone que desea hacer; Como es posible que asigne\'
                                 + 'producción a un recurso de producción, que sentido tiene !!!!!');
                            rProdu.Description := Rec.Description;
                            rProdu."Description 2" := r1003.Description;
                            rProdu."No.2" := r1003."No.";
                            rProdu.INSERT;
                            If Empresa <> COMPANYNAME THEN begin
                                r1003Otra.SetRange("Job No.", r1003."Job No.");
                                r1003Otra.SetRange("No.", rRes."Nº En Empresa origen");
                                If r1003Otra.FindFirst then begin
                                    rProduOtra := rProdu;
                                    rProduOtra.ChangeCompany(Empresa);
                                    rProduOtra."Job No." := r1003Otra."Job No.";
                                    rProduOtra."Line No." := r1003Otra."Line No.";
                                    rProduOtra."No." := r1003Otra."No.";
                                    rProduOtra.Insert();
                                end;
                            end;
                        UNTIL r1003.NEXT = 0;

                    CurrPage.CLOSE;
                END;
            }
            action(Eliminar)
            {
                Image = Delete;
                ApplicationArea = ALL;
                Caption = 'Eliminar';
                trigger OnAction()
                var
                    ProduccionesRelacionadas: Record "Produccines Relacionadas";
                    Job: Record Job;
                    Contrato: Record "Sales Header";
                BEGIN
                    CurrPage.SubPage.Page.GetRecord(ProduccionesRelacionadas);
                    Job.Get(ProduccionesRelacionadas."Job No.");
                    If Contrato.Get(Contrato."Document Type"::Order, Job."Nº Contrato") then
                        If Contrato.Estado = Contrato.Estado::Firmado THEN
                            ERROR('No se puede eliminar una producción de un contrato firmado');
                    Rec.BorrarecursosRelacionados(ProduccionesRelacionadas."Line No.", ProduccionesRelacionadas."Job No.", ProduccionesRelacionadas."Line No.2", ProduccionesRelacionadas."Job No.2");

                END;
            }
            action("Proyecto otra empresa")
            {
                Image = SwitchCompanies;
                ApplicationArea = ALL;
                Caption = 'Proyecto otra empresa';
                trigger OnAction()
                VAR
                    rEmp: Record 2000000006;
                BEGIN
                    Actual := FALSE;
                    MESSAGE('Elija empresa');
                    if PAGE.RUNMODAL(Page::Companies, rEmp) = ACTION::LookupOK THEN BEGIN
                        Empresa := rEmp.Name;
                        MESSAGE('Elija Proyecto');
                        // {if rJob."No."='' THEN BEGIN
                        // //  rJob.SETRANGE(rJob."Creation Date",010115D,311215D);
                        // rJob.FINDFIRST;
                        // rJob.SETRANGE(rJob."Creation Date");
                        // END;
                        // rJob.GET(rJob."No.");
                        // rJob.SETRANGE(rJob."Bill-to Customer No.",rJob."Bill-to Customer No."); }
                        rJob.CHANGECOMPANY(Empresa);
                        if Page.RUNMODAL(0, rJob) = ACTION::LookupOK THEN
                            Proyecto := rJob."No.";

                    END;
                END;
            }
        }
    }
    VAR
        Actual: Boolean;
        rJob: Record 167;
        Proyecto: Code[20];
        rProdu: Record "Produccines Relacionadas";
        rRes: Record 156;
        Empresa: Text[30];

    trigger OnOpenPage()
    BEGIN
        if Proyecto < Rec."Job No." then
            Actual := FALSE;
        if Proyecto = '' then
            Proyecto := Rec."Job No.";
        if Empresa = '' Then
            Empresa := COMPANYNAME;
    END;

    /// <summary>
    /// CargaLinea.
    /// </summary>
    /// <param name="rJobPl">VAR Record "Job Planning Line".</param>
    procedure CargaLinea(var rJobPl: Record "Job Planning Line")
    begin
        Rec := rJobPl;
        if Rec.Insert Then;
    end;
    /// <summary>
    /// CargaLinea.
    /// </summary>
    /// <param name="rJobPl">VAR Record "Job Planning Line".</param>
    /// <param name="tEmpresa">Text.</param>
    /// <param name="Pproyecto">Code[20].</param>
    procedure CargaLinea(var rJobPl: Record "Job Planning Line"; tEmpresa: Text; Pproyecto: Code[20])
    var
        Res: Record Resource;
    begin
        Rec := rJobPl;
        Actual := true;
        if Rec.Insert Then;
        Proyecto := Pproyecto;
        if Proyecto < Rec."Job No." then
            Actual := FALSE;
        Empresa := tEmpresa;
    end;
}