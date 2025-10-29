/// <summary>
/// Report Renovar presupuesto (ID 50007).
/// </summary>
report 50006 "Renovar presupuesto"
{
    UseRequestPage = true;
    ProcessingOnly = true;
    //No se usa
    dataset
    {
        dataitem(Job; Job)
        {
            DataItemTableView = SORTING("No.");
            trigger OnPreDataItem()
            begin
                SETRANGE(Job."No.", rProyecto."No.");
            end;

            trigger OnAfterGetRecord()
            begin

                CopiarCabecera;

                //Lin.LOCKTABLE;
                Lin.SETRANGE("Job No.", "No.");
                //LOCKTABLE(TRUE,TRUE);

                LinsNoCopiadas := 0;
                DesdeLin.RESET;
                DesdeLin.SETRANGE("Job No.", "No.");
                DesdeLin.SETRANGE("Line Type", DesdeLin."Line Type"::Budget);               //$004
                if DesdeLin.FIND('-') THEN BEGIN
                    REPEAT
                        CopiarLineas;
                    UNTIL DesdeLin.NEXT = 0;
                END;

                //esto no se usa, se ha copiado de otro report.
                if LinsNoCopiadas > 0 THEN
                    MESSAGE(
                      'La/s línea/s del documento que tienen indicada una cuenta contable que no admite' +
                      'registro directo, no se copian al nuevo documento.');
                rGes.RenovarContratoDestino(Job);
                Job.Renovado := TRUE;
                Job.MODIFY(TRUE);

                //$003(I)
                rCabVenta.RESET;
                rCabVenta.SETCURRENTKEY("Nº Proyecto");
                rCabVenta.SETRANGE("Nº Proyecto", Job."No.");
                if rCabVenta.FIND('-') THEN BEGIN
                    rCabVenta.VALIDATE("Fecha renovacion", 0D);
                    rCabVenta.VALIDATE(Renovado, TRUE);
                    rCabVenta.MODIFY(TRUE);
                END;

                MESSAGE(Text001, rProyecto."No.");
            end;
        }
    }
    requestpage
    {
        layout
        {
            area(Content)
            {
                field(Texto; 'Renovación proyecto Nº: ' + rProyOpc."No.")
                {
                    ApplicationArea = All;
                    ShowCaption = false;
                }
                field("Fecha Inicial Proyecto"; rProyOpc."Starting Date")
                {
                    ApplicationArea = All;

                }
                field("Fecha Final Proyecto"; rProyOpc."Ending Date")
                {
                    ApplicationArea = All;
                }
            }
        }
        trigger OnOpenPage()
        begin

            if rProyOpc.GET(rProyecto."No.") THEN BEGIN
                wDias := (rProyOpc."Ending Date" - rProyOpc."Starting Date");
                If wDias < 0 Then Error('La fecha final no puede ser menor que la inicial');
                if wDias = 366 Then wDias := 365;
                wTxt := '+' + FORMAT(wDias) + 'D';
                if rProyOpc."Starting Date" = 0D Then Error('La fecha de inicio no puede estar vacia');
                rProyOpc."Starting Date" := CALCDATE('+1D', rProyOpc."Ending Date");
                rProyOpc."Ending Date" := CALCDATE(wTxt, rProyOpc."Starting Date");
            END;
        end;



    }
    VAR
        rProyecto: Record 167;
        rProyOpc: Record 167;
        Lin: Record 1003;
        DesdeLin: Record 1003;
        rTAmpli: Record "Texto presupuesto";
        rTA2: Record "Texto presupuesto";
        rCabVenta: Record 36;
        LinsNoCopiadas: Integer;
        wDias: Integer;
        NoDoc: Code[20];
        Text001: Label 'Se ha renovado este proyecto, y se ha creado el nº %1';
        wTxt: Text[10];
        Text002: Label 'La fecha no puede estar en blanco';
        rGes: Codeunit "Gestion Proyecto";

    PROCEDURE CopiarCabecera();
    var
        ContratoOrigen: Record 36;
        NuevoVendedor: Code[20];
        VendedorAntiguo: Code[20];
    BEGIN
        // Job es el proyecto de origen, desde el que se copia. rProyecto es el nuevo.
        ComprobarSaldoVencidoClientes(Job);
        rProyecto.INIT;
        rProyecto.TRANSFERFIELDS(Job);
        rProyecto."No." := '';
        ContratoOrigen.SetRange("Nº Proyecto", Job."No.");
        ContratoOrigen.SetRange("Document Type", ContratoOrigen."Document Type"::Order);
        if ContratoOrigen.FindFirst() then begin
            NuevoVendedor := ContratoOrigen."Nuevo Vendedor asignado";
            VendedorAntiguo := ContratoOrigen."Salesperson Code";
        end;
        //$002-
        if Job."Proyecto original" = '' THEN
            rProyecto."Proyecto original" := Job."No."
        ELSE
            rProyecto."Proyecto original" := Job."Proyecto original";
        //$002+
        rProyecto.Status := rProyecto.Status::Planning;
        rProyecto.INSERT(TRUE);
        NoDoc := rProyecto."No.";
        rProyecto.Status := rProyecto.Status::Planning;
        rProyecto."Creation Date" := TODAY;
        rProyecto."Starting Date" := 0D;
        rProyecto."Ending Date" := 0D;
        rProyecto.Renovado := FALSE;
        rProyecto.VALIDATE(rProyecto."Global Dimension 1 Code");
        //$003(I)
        rProyecto."Proyecto origen" := Job."No.";
        rProyecto."Starting Date" := rProyOpc."Starting Date";
        rProyecto."Ending Date" := rProyOpc."Ending Date";

        rProyecto.VALIDATE("Global Dimension 1 Code", Job."Global Dimension 1 Code");
        rProyecto.VALIDATE("Global Dimension 2 Code", Job."Global Dimension 2 Code");
        rProyecto.Firmado := rProyecto.Firmado::"No Firmado";

        //$003(F)
        If NuevoVendedor <> '' then begin
            rProyecto."Cód. vendedor" := NuevoVendedor;
            rProyecto."Vendedor Origen" := VendedorAntiguo;
        end;
        rProyecto.MODIFY;
    END;

    LOCAL PROCEDURE CopiarLineas();
    var
        Resource: Record Resource;
        ResourceOtraEmpresa: Record Resource;
        Blo: Record "Incidencias Rescursos";
        rTipo: Record "Tipo Recurso";
    BEGIN
        Lin.INIT;
        Lin.TRANSFERFIELDS(DesdeLin);
        Lin."Job No." := rProyecto."No.";
        Lin."Planning Date" := 0D;
        Lin."Fecha Final" := 0D;
        Lin.INSERT;
        Lin.Renovando := TRUE;
        Lin."Cdad. a Reservar" := 0;
        Lin."Cdad. Reservada" := 0;
        Lin.VALIDATE("No.");

        Lin.Description := DesdeLin.Description;
        // $001        DesdeLin.CALCFIELDS(Quantity);
        Lin.Quantity := 0;
        Lin."Cdad. a Reservar" := 0;
        Lin."Cdad. Reservada" := 0;
        //$003(I)
        Lin."Fecha Final" := rProyecto."Ending Date";
        Lin."Planning Date" := rProyecto."Starting Date";
        Lin.VALIDATE(Quantity, DesdeLin.Quantity);
        Lin."Cdad. a Reservar" := 0;
        Lin."Cdad. Reservada" := 0;
        Lin.VALIDATE("Unit Cost", DesdeLin."Unit Cost");
        Lin.Validate("% Dto. Compra", DesdeLin."% Dto. Compra");
        Lin.VALIDATE("Unit Price", DesdeLin."Unit Price");
        //$003(F)
        lin.Renovando := false;
        If Resource.Get(DesdeLin."No.") then begin
            If Resource."Nº En Empresa origen" <> '' then begin
                ResourceOtraEmpresa.ChangeCompany(resource."Empresa Origen");
                ResourceOtraEmpresa.Get(Resource."Nº En Empresa origen");
                lin.Description := ResourceOtraEmpresa.Name;
                Resource.Name := ResourceOtraEmpresa.Name;
                Blo.ChangeCompany(resource."Empresa Origen");
                Blo.SETRANGE("Nº Recurso", Resource."Nº En Empresa origen");
                if Blo.FINDFIRST then begin
                    If Blo."Incidencia de Bloqueo" = Blo."Incidencia de Bloqueo"::Bloqueo Then begin
                        MESSAGE('El recurso %1 está bloqueado en la empresa origen.', Resource."Nº En Empresa origen");
                        Resource.Bloqueado := TRUE;
                    end;

                end;
                Resource.MODIFY;
            end else begin
                If Resource."Recurso Agrupado" = false then begin
                    lin.Description := Resource.Name;

                end;
            end;
        end;
        //if JobPlanningLine."Type" = JobPlanningLine.Type::Resource then begin
        //    if not Tipo.Get(Res."Tipo Recurso") Then Tipo.Init();
        //    if Tipo."Crea Reservas" Then if not Res."Recurso Agrupado" Then if Res."Empresa Origen" = '' Then JobPlanningLine."Cdad. a Reservar" := 1;
        //end
        if Lin.Type = Lin.Type::Resource then begin
            Resource.Get(Lin."No.");
            if not rTipo.Get(Resource."Tipo Recurso") Then rTipo.Init();
            if Resource."Producción" then rTipo."Crea Reservas" := false;
            if Resource."Recurso Agrupado" then rTipo."Crea Reservas" := false;
            if Resource."Empresa Origen" <> '' then rTipo."Crea Reservas" := false;
            if rTipo."Crea Reservas" Then Lin."Cdad. a Reservar" := 1;
        end;
        Lin.MODIFY;

        // TEXTO PRESUPUESTO
        rTAmpli.INIT;
        rTAmpli.SETCURRENTKEY("Nº proyecto", "Cód. fase", "Cód. subfase", "Cód. tarea",
                 Tipo, "Nº", "Cód. variante", "Nº linea aux", "Nº linea");
        rTAmpli.SETRANGE("Nº proyecto", DesdeLin."Job No.");
        // $001-
        rTAmpli.SETRANGE("Cód. tarea", DesdeLin."Job Task No.");
        rTAmpli.SETRANGE("Nº linea aux", DesdeLin."Line No.");
        // $001+
        rTAmpli.SETRANGE(Tipo, DesdeLin.Type.AsInteger());
        rTAmpli.SETRANGE("Nº", DesdeLin."No.");
        rTAmpli.SETRANGE("Cód. variante", DesdeLin."Variant Code");
        if rTAmpli.FIND('-') THEN
            REPEAT
                rTA2.INIT;
                rTA2.TRANSFERFIELDS(rTAmpli);
                rTA2."Nº proyecto" := Lin."Job No.";
                rTA2.INSERT;
            UNTIL rTAmpli.NEXT = 0;
    END;

    local procedure ComprobarSaldoVencidoClientes(Job: Record Job)
    var
        Cliente: Record Customer;
        ClientesCadena: Record Customer;
    begin
        if Cliente.Get(Job."Bill-to Customer No.") then begin
            Cliente.CalcFields("Balance Due");
            if Cliente."Balance Due" > 0 then begin
                Message('El cliente %1 tiene un saldo vencido de %2', Cliente."No.", Cliente."Balance Due");
            end;
        end;
        If Cliente."Chain Name" <> '' then begin
            ClientesCadena.SetRange("Chain Name", Cliente."Chain Name");
            if ClientesCadena.FindFirst() then
                repeat
                    ClientesCadena.CalcFields("Balance Due");
                    if ClientesCadena."Balance Due" > 0 then begin
                        Message('El cliente %1 que pertenece a la cadenA %2, tiene un saldo vencido de %3', ClientesCadena."No.", Cliente."Chain Name", ClientesCadena."Balance Due");
                    end;
                until ClientesCadena.Next = 0;
        end;
    end;

    PROCEDURE DefCabVentas(VAR NuevoProy: Record 167);
    BEGIN
        rProyecto := NuevoProy;
    END;
}

