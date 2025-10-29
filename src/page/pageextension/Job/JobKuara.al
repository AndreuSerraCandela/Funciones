/// <summary>
/// PageExtension JobKuara (ID 80111) extends Record Job Card.
/// </summary>
pageextension 80111 "JobKuara" extends "Job Card"
{


    layout
    {
        // Add changes to page layout here
        // addfirst(FactBoxes)
        // {
        //     part(WebViewer; "Web Viewer")
        //     {
        //         Caption = 'Viewer';
        //         ApplicationArea = All;

        //     }
        // }
        addafter("Bill-to Name")
        {
#if not CLEAN27
            field("Bill-to Name 2"; Rec."Bill-to Name 2")
            {
                ApplicationArea = All;
            }
#endif
        }
        addafter(Description)
        {
            field("Nombre Comercial"; Rec."Nombre Comercial")
            {
                Caption = 'Anunciante';
                ApplicationArea = All;
            }
        }
        addafter("No.")
        {
            field("Proyecto Antiguo"; Rec."Proyecto Antiguo")
            {
                ApplicationArea = ALL;
                Caption = 'Nº proy. aplic. antigua';
            }
            field("Proyecto original"; Rec."Proyecto original")
            {
                ApplicationArea = ALL;

            }
            field("Proyecto Origen"; Rec."Proyecto origen")
            {
                ApplicationArea = ALL;


            }

            field(Renovado; Rec.Renovado)
            {
                ApplicationArea = ALL;
                Editable = RenovadoEditable;

            }
            field("Fechas Flexibles"; Rec."Fechas Flexibles")
            {
                ApplicationArea = ALL;
                Caption = '¿Tienen fechas flexibles?';
            }
            field("Proyecto de fijación"; Rec."Proyecto de fijación")
            {
                ApplicationArea = ALL;
                Caption = 'Proyecto de fijación';
            }
        }

        addafter("Search Description")
        {
            field(Departamento; Rec."Global Dimension 1 Code")
            {
                ApplicationArea = ALL;

            }
            field(Programa; Rec."Global Dimension 2 Code")
            {
                ApplicationArea = ALL;

            }
            field(Lineas; Rec.Lineas())
            {
                ApplicationArea = ALL;
                Caption = 'Nº lineas';
            }
            field("No Pay"; Rec."No Pay")
            {
                ApplicationArea = ALL;

            }
            field(Divisa; Rec."Currency Code")
            {
                ApplicationArea = ALL;
                Editable = InvoiceCurrencyCodeEDITABLE;

            }
            field(Estado; Estado)
            {
                ApplicationArea = ALL;
                trigger OnValidate()
                var

                begin
                    Rec.Validate(Status, Estado);
                end;

            }
            field("Cód. vendedor"; Rec."Cód. vendedor")
            {
                ApplicationArea = ALL;

            }
            field(Bloqueado; Rec.Blocked)
            {
                ApplicationArea = ALL;

            }
            field(Tipo; Rec.Tipo)
            {
                ApplicationArea = ALL;

            }
            field("Según disponibilidad"; Rec."Según disponibilidad")
            {
                ApplicationArea = all;
            }
            field(Subtipo; Rec.Subtipo)
            {
                ApplicationArea = ALL;

            }
            field("Soporte de"; Rec."Soporte de")
            {
                ApplicationArea = ALL;

            }
            field("Fija/Papel"; Rec."Fija/Papel")
            {
                ApplicationArea = ALL;

            }
            field(CreationDate; Rec."Creation Date")
            {
                ApplicationArea = ALL;

            }
            field(StartingDate; Rec."Starting Date")
            {
                ApplicationArea = ALL;

            }
            field(EndingDate; Rec."Ending Date")
            {
                ApplicationArea = ALL;

            }
            field("Interc./Compens."; Rec."Interc./Compens.")
            {
                ApplicationArea = ALL;

            }
            field(Firmado; Rec.Firmado)
            {
                ApplicationArea = ALL;
                Caption = 'Firma Proyecto';
            }
            field("Fecha Firma"; Rec."Fecha Firma")
            {
                ApplicationArea = ALL;
                ShowCaption = false;
            }
            field("Estado Contrato"; Rec."Estado Contrato")
            {
                ApplicationArea = ALL;

            }
            field("Fecha Estado Contrato"; Rec."Fecha Estado Contrato")
            {
                ApplicationArea = ALL;
                ShowCaption = false;
            }



        }
        addbefore(JobTaskLines)
        {
            part(JobTaskLines2; JobLinesSub)
            {
                ApplicationArea = ALL;
                Caption = 'Lineas';
                SubPageLink = "Job No." = FIELD("No.");
                SubPageView = SORTING("Job Task No.")
                              ORDER(Ascending);
            }
        }
        modify(JobTaskLines)
        {
            Visible = false;

        }
        modify("Starting Date")
        {
            Visible = false;
        }
        modify("Ending Date")
        {
            Visible = false;
        }
        modify(Status)
        {
            Visible = false;
        }
        modify("Currency Code")
        {
            Visible = false;
        }
        modify(Blocked)
        {
            Visible = false;
        }
        modify("Creation Date")

        {
            Visible = false;
        }
        modify(ContactPhoneNo)
        {
            Visible = false;
        }
        modify(ContactEmail)
        {
            Visible = false;

        }
        modify(ContactMobilePhoneNo)
        {
            Visible = false;
        }
        modify("Bill-to Country/Region Code")
        {
            Visible = false;
        }
        modify("Project Manager")
        {
            Visible = false;
        }

        addbefore(Duration)
        {
            group("Empresa Grupo")
            {
                field("Proyecto en empresa Origen"; Rec."Proyecto en empresa Origen")
                { ApplicationArea = All; }
                field("Empresa Origen"; Rec."Empresa Origen")
                { ApplicationArea = All; }
            }
            field("Proyecto Mixto"; Rec."Proyecto Mixto")
            {
                ApplicationArea = All;
            }
        }


    }
    actions
    {
        // addafter(Attachments)
        // {
        //     action(ActualizaDatos)
        //     {
        //         ApplicationArea = all;
        //         Caption = 'Actualiza datos';
        //         Image = RefreshLines;
        //         trigger OnAction()
        //         var
        //             myInt: Integer;
        //         begin
        //             ShowData(true);
        //             CurrPage.WebViewer.Page.ShowData();
        //         end;
        //     }
        // }
        addfirst("Plan&ning")
        {
            action("Ocupación diaria")
            {
                Image = ResourcePlanning;
                ApplicationArea = All;
                Caption = 'Ocupación diaria';
                trigger OnAction()
                Begin
                    CurrPage.JobTaskLines2.Page.LlamarPlazos;
                END;
            }
            action("Informes Recursos")
            {
                Caption = 'Disponibilidad Recursos';
                Image = List;
                ApplicationArea = All;
                trigger OnAction()
                var
                    Sel: Record SeleccionRecursos;
                    JobPlanningLine: Record "Job Planning Line";
                    Res: Record Resource;
                    Tipos: Record "Tipo Recurso";
                begin
                    Sel.SetRange(UserId, UserId);
                    sel.ModifyAll(Seleccionar, false);
                    JobPlanningLine.SetRange("Job No.", Rec."No.");
                    if JobPlanningLine.FindSet() then
                        repeat
                            iF Res.Get(JobPlanningLine."No.") then BEGIN
                                if NOT Res."Recurso Agrupado" and NOT Res."Producción" then BEGIN
                                    if not TipoS.Get(Res."Tipo Recurso") Then Tipos.Init();
                                    if TipoS."Crea Reservas" Then bEGIN
                                        Sel.SetRange("No.", JobPlanningLine."No.");
                                        If Res."Empresa Origen" = '' then
                                            Sel.ModifyAll(Seleccionar, true);
                                    END;
                                END;
                            END;
                        until JobPlanningLine.Next() = 0;
                    Commit();
                    Page.RunModal(Page::"Seleccionar Recursos");
                end;

            }
            action("Crear fijación")
            {
                Image = CreateJobSalesCreditMemo;
                ApplicationArea = All;
                trigger OnAction()
                var
                    CrearOrdenFijacion: Report "Crear orden fijación";
                    Reserva: Record Reserva;
                    SeleccionarReservas: Page "Tabla Reservas";
                    FechaI: Date;
                    FechaF: Date;
                    OrdenesFijacion: Record "Cab Orden fijación";
                    DetalleOrdenesFijacion: Record "Orden fijación";
                    MismoProyecto: Boolean;
                begin

                    Reserva.SETRANGE("Nº Proyecto", Rec."No.");
                    Reserva.ModifyAll(Seleccionar, false);
                    Commit;
                    SeleccionarReservas.SetTableView(Reserva);
                    SeleccionarReservas.Seleccionable('');
                    SeleccionarReservas.RUNMODAL;
                    Reserva.SetRange("Seleccionar", true);
                    If Not Reserva.FindFirst() Then begin
                        SeleccionarReservas.SetSelectionFilter(Reserva);
                        If Reserva.Count = 1 Then
                            ERROR('No hay reservas seleccionadas');
                        Reserva.ModifyAll(Seleccionar, true);
                    end;
                    Commit();
                    Reserva.FindFirst();
                    If (Reserva.Estado = Reserva.Estado::Ocupado) Or (Reserva.Estado = Reserva.Estado::"Ocupado fijo") Then
                        If Confirm('Estas Reservas ya están en una orden de fijacion, Quiere Crear Una Nueva?') Then Begin
                            MismoProyecto := true;
                            if Reserva.FindFirst() then
                                repeat
                                    if DetalleOrdenesFijacion.Get(Reserva."Nº Reserva") then begin
                                        DetalleOrdenesFijacion.Tapar := DetalleOrdenesFijacion.Fijar;
                                        DetalleOrdenesFijacion.Refijacion := true;
                                        DetalleOrdenesFijacion.Modify();
                                    end;
                                until Reserva.Next() = 0;
                            Reserva.SetRange(Estado, Reserva.Estado::Ocupado);
                            Reserva.ModifyAll(Estado, Reserva.Estado::Reservado);
                            Reserva.SetRange(Estado, Reserva.Estado::"Ocupado fijo");
                            Reserva.ModifyAll(Estado, Reserva.Estado::"Reservado fijo");
                            Reserva.SetRange(Estado);


                        end else
                            ERROR('No se pueden fijar reservas ocupadas');
                    FechaI := Reserva."Fecha inicio";
                    FechaF := Reserva."Fecha fin";
                    Commit();
                    Clear(CrearOrdenFijacion);
                    Reserva.SETRANGE("Nº Proyecto", Rec."No.");
                    CrearOrdenFijacion.SetTableView(Reserva);
                    CrearOrdenFijacion.parametros(FechaI, FechaF, Rec."No.", '', 0, MismoProyecto);
                    CrearOrdenFijacion.RUNMODAL;

                    OrdenesFijacion.SETRANGE("Nº Proyecto", Rec."No.");
                    Page.RUN(0, OrdenesFijacion);
                end;
            }
            action("Traspasar Reservas")
            {
                ApplicationArea = All;
                Image = CopyBOM;
                Caption = 'Traspasar Reservas';
                trigger OnAction()
                var
                    NewJob: Record Job;
                    Reservas: Record Reserva;
                    DiarioReservas: Record "Diario Reserva";
                    JobPlanningLine2: Record "Job Planning Line";
                    JobPlanningLine: Record "Job Planning Line";
                    Linea: Integer;
                Begin
                    Message('Elija el proyecto destino');
                    If Page.RunModal(0, NewJob) in [ACTION::OK, Action::LookupOK] THEN BEGIN
                        Reservas.SetRange("Nº Proyecto", Rec."No.");
                        Reservas.SetRange("Fecha inicio");
                        Reservas.SetRange("Fecha Fin");
                        Reservas.ModifyAll("Nº Proyecto", NewJob."No.");
                        Reservas.ModifyAll("Proyecto de fijación", NewJob."Proyecto de fijación");
                        DiarioReservas.SetRange("Nº Proyecto", Rec."No.");
                        DiarioReservas.ModifyAll("Nº Proyecto", NewJob."No.");
                        DiarioReservas.ModifyAll("Proyecto de fijación", NewJob."Proyecto de fijación");
                        DiarioReservas.Reset();
                        JobPlanningLine.SetRange("Job No.", Rec."No.");
                        JobPlanningLine2.SetRange("Job No.", NewJob."No.");
                        If JobPlanningLine2.FindSet() Then Linea := JobPlanningLine2."Line No.";
                        If JobPlanningLine.FindSet() Then
                            Repeat
                                JobPlanningLine2 := JobPlanningLine;
                                JobPlanningLine2."Line No." := Linea;
                                JobPlanningLine2."Job No." := NewJob."No.";
                                JobPlanningLine2.Insert();
                                DiarioReservas.SetRange("Nº Proyecto", NewJob."No.");
                                DiarioReservas.SetRange("Nº linea proyecto", JobPlanningLine."Line No.");
                                If DiarioReservas.FindFirst() Then
                                    DiarioReservas.ModifyAll("Nº linea proyecto", Linea);
                                Linea := Linea + 10000;

                            Until JobPlanningLine.Next() = 0;
                    END;
                END;
            }
        }
        addfirst("&Job")
        {
            action("Job Task Lines")
            {
                ApplicationArea = all;
                Image = TaskList;
                Caption = 'Líneas tarea proyecto';
                trigger OnAction()
                Var
                    JTLines: Page 1002;
                    JobT: Record "Job Task";
                BEGIN
                    JobT.SETRANGE(JobT."Job No.", Rec."No.");
                    JTLines.SetTableView(JobT);
                    JTLines.RUN;
                END;
            }
            action("Cambiar &Fechas Proyecto")
            {
                Image = ChangeDates;
                ApplicationArea = all;
                Caption = 'Cambiar &Fechas Proyecto';
                trigger OnAction()
                Begin
                    Rec.SETRANGE("No.", Rec."No.");
                    Page.RUNMODAL(Page::"Cambio fechas proyecto", Rec);
                    Rec.SETRANGE("No.");
                    CurrPage.UPDATE;
                END;
            }
            action("Adelanta Fecha Fin")
            {
                Image = ChangeDate;
                ApplicationArea = all;
                Caption = 'Adelanta Fecha Fin';
                trigger OnAction()
                Var
                    NuevoTexto: Text;


                Begin

                    fech := Rec."Ending Date";
                    NuevoTexto := ('Introduzca Nueva fecha fin');
                    finestra.SetValues(fech, NuevoTexto);
                    finestra.RunModal();
                    finestra.GetValues(fech, NuevoTexto);
                    if (fech > Rec."Ending Date") THEN
                        ERROR('La nueva fecha final debe ser inferior a %1', Rec."Ending Date");
                    CLEAR(cProyecto);
                    cProyecto.Adelanta_Fecha_Fin(Rec, fech);

                END;
            }
            action("Proceso Traspaso Datos")
            {
                Image = SendTo;
                ApplicationArea = all;
                Caption = 'Proceso Traspaso Datos';
                trigger OnAction()
                Begin

                    CASE STRMENU('Solo este proyecto,Todos los proyectos', 1) OF
                        1:
                            BEGIN
                                cProyecto.Traspasa_Datos(Rec."No.");
                            END;
                        2:
                            BEGIN
                                cProyecto.Traspasa_Datos('');
                            END;
                    END;
                END;

            }
            action("Todas &Reservas Proyecto")
            {
                ApplicationArea = all;
                Image = ReservationLedger;
                //PushAction=RunObject;
                Caption = 'Todas &Reservas Proyecto';
                RunObject = page "Tabla Reservas";
                RunPageView = SORTING("Nº Proyecto", "Fecha inicio");
                RunPageLink = "Nº Proyecto" = FIELD("No.");
            }
            action("&Contrato Venta")
            {
                ApplicationArea = all;
                Image = ContractPayment;
                //PushAction=RunObject;
                Caption = '&Contrato Venta';
                RunObject = Page "Ficha Contrato Venta";
                //RunPageView=SORTING("Nº Proyecto");
                RunPageLink = "Nº Proyecto" = FIELD("No.");
            }
            action("&Pedidos Compra")
            {
                ApplicationArea = all;
                Image = Purchase;
                //PushAction=RunObject;
                Caption = '&Pedidos Compra';
                RunObject = Page 53;
                //RunPageView=SORTING("Nº Proyecto");
                RunPageLink = "Nº Proyecto" = FIELD("No.");
            }
            action("&Imprimir")
            {
                Image = Print;
                ApplicationArea = all;
                Caption = '&Imprimir';
                trigger OnAction()
                Begin

                    rP2.SETRANGE("No.", Rec."No.");
                    REPORT.RUNMODAL(REPORT::"Presupuesto proyecto para cli", TRUE, FALSE, rP2);
                END;
            }
            action("Regenera")
            {
                Image = Replan;
                Visible = false;
                ApplicationArea = all;
                Caption = 'Regenera';
                trigger OnAction()
                Var
                    c1001: Codeunit "Procedures Standard";
                BEGIN
                    EXIT;
                    CLEAR(c1001);
                    if COMPANYNAME = 'Grepsa' THEN BEGIN
                        c1001."Regenera Proyecto2"(Rec."No.");
                        COMMIT;
                        c1001."Repara Proyecto"(Rec."No.");

                    END ELSE BEGIN
                        c1001."Regenera Proyecto"(Rec."No.");
                        COMMIT;
                        c1001."Repara Proyecto"(Rec."No.");
                    END;
                END;
            }
            action("Introducir proyecto origen/original")
            {
                Image = Job;
                ApplicationArea = all;
                //PushAction=RunObject;
                Caption = 'Introducir proyecto origen/original';
                RunObject = Page "Job List Temp";
            }
            action("Aplicar filtro en líneas")
            {
                Image = Job;
                ApplicationArea = all;

                Caption = 'Aplicar filtro en líneas';
                trigger OnAction()
                Var
                    wFec1: Text[30];
                    wFec2: Text[30];
                    wFec3: Text[30];
                    wFec4: Text[30];
                BEGIN
                    CLEAR(wFec1);
                    CLEAR(wFec2);
                    CLEAR(wFec3);
                    CLEAR(wFec4);
                    if Rec.GETFILTER("Starting Date") <> '' THEN BEGIN
                        wFec1 := FORMAT(Rec.GETRANGEMIN("Starting Date"));
                        wFec2 := FORMAT(Rec.GETRANGEMAX("Starting Date"));
                    END;
                    if Rec.GETFILTER("Ending Date") <> '' THEN BEGIN
                        wFec3 := FORMAT(Rec.GETRANGEMIN("Ending Date"));
                        wFec4 := FORMAT(Rec.GETRANGEMAX("Ending Date"));
                    END;
                    CurrPage.JobTaskLines2.Page.FiltrosLinea(wFec1, wFec2,
                            COPYSTR(Rec.GETFILTER(Tipo), 1, 30),
                            COPYSTR(Rec.GETFILTER("Soporte de"), 1, 30),
                            COPYSTR(Rec.GETFILTER("Fija/Papel"), 1, 30),
                            COPYSTR(Rec.GETFILTER(Subtipo), 1, 30),
                            wFec3, wFec4);
                END;
            }
            action("Traspasar a Otra Empresa")
            {
                Image = ICPartner;
                ApplicationArea = all;
                Caption = 'Traspasar a Otra Empresa';
                trigger OnAction()
                Begin
                    CLEAR(cProyecto);
                    cProyecto.TrasPasaPoryectoaEmpresas(Rec);
                END;
            }
            action("Crear Pedido Compra Per.")
            {
                Image = CreateDocument;
                ApplicationArea = all;
                Caption = 'Crear Pedido Compra Per.';
                trigger OnAction()
                Var
                    Gest_Res: Codeunit "Gestion Reservas";
                    Contrato: Record 36;
                BEGIN
                    CLEAR(Gest_Res);
                    Contrato.SETCURRENTKEY("Nº Proyecto");
                    Contrato.SETRANGE(Contrato."Document Type", Contrato."Document Type"::Order);
                    Contrato.SETRANGE(Contrato."Nº Proyecto", Rec."No.");
                    Contrato.FINDFIRST;
                    Gest_Res.Pasa_ContratoCompraPer(Rec, Contrato);
                END;
            }
            action("Asignar Producción")
            {
                Image = AssemblyOrder;
                ApplicationArea = all;
                Caption = 'Asignar Producción';
                trigger OnAction()
                Var
                    rDet: Record 1003;
                BEGIN
                    CurrPage.JobTaskLines2.Page.GETRECORD(rDet);
                    rDet.Produccion;
                END;
            }
            action("Crear Linea Producción")
            {
                ApplicationArea = All;
                Image = StepOver;
                trigger OnAction()
                var
                    Prod: Record "Recursos de Producción";
                    Asis: Page "Wizard Producción";
                    L: Integer;
                    LL: Integer;
                    Linea: Record "Job Planning Line";
                    TR: Record "Tipo Recurso";
                    T: Code[20];
                    rDet: Record 1003;
                    rLin: Record 1003 temporary;
                begin
                    Linea.SetRange("Job No.", Rec."No.");
                    T := '10';
                    if Linea.FindLast() Then begin
                        CurrPage.JobTaskLines2.Page.GETRECORD(rDet);
                        LL := rDet."Line No.";
                        L := Linea."Line No.";
                        T := Linea."Job Task No.";
                    end else
                        rDet.Init();
                    Asis.Carga(Rec."No.", rDet."No.");
                    Asis.RunModal();
                    Asis.GetRecord(Prod);

                    Linea.Init();
                    Linea."Job No." := Rec."No.";
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
                    Linea.Insert();
                    Commit();
                    Asis.Lineas(rlin);
                    if rLin.Count = 0 then
                        Linea.ProduccionNueva(Prod.Empresa, prod."Nº Proyecto")
                    else
                        Linea.ProduccionNuevaxLinea(Prod.Empresa, rLin);




                end;
            }
            action("Asignar proyecto Otra Empresa")
            {
                Image = ChangeTo;
                ApplicationArea = all;
                Caption = 'Asignar proyecto Otra Empresa';
                trigger OnAction()
                Var
                    rEmp: Record 2000000006;
                    rJob: Record 167;
                BEGIN
                    MESSAGE('Seleccione la empresa');
                    if Page.RUNMODAL(Page::Companies, rEmp) = ACTION::LookupOK THEN BEGIN
                        rJob.CHANGECOMPANY(rEmp.Name);
                        if Page.RUNMODAL(0, rJob) = ACTION::LookupOK THEN BEGIN
                            rJob."Proyecto en empresa Origen" := Rec."No.";
                            rJob."Empresa Origen" := COMPANYNAME;
                            rJob.MODIFY;
                        END;
                    END;
                END;
            }
            action("Crear Pedido Compra")
            {
                Image = ChangeTo;
                ApplicationArea = all;
                Caption = 'Crear Pedido Compra';
                trigger OnAction()
                Var
                    Gest_Res: Codeunit "Gestion Reservas";
                    Contrato: Record 36;
                    rLin: Record 1003;
                    finestra: Dialog;
                BEGIN
                    CLEAR(Gest_Res);
                    Contrato.INIT;
                    rLin.SETCURRENTKEY("Job No.", "Crear pedidos", "Compra a-Nº proveedor");
                    rLin.SETRANGE("Job No.", Rec."No.");

                    finestra.OPEN('Creando pedidos de compra');
                    rLin.SETFILTER("Crear pedidos", '%1|%2', rLin."Crear pedidos"::"De Compra Y De Venta",
                                                            rLin."Crear pedidos"::"De Compra");
                    rLin.SetRange("Compra a-Nº proveedor", '');
                    if rLin.FindFirst() then Error('No se pueden crear pedidos de compra porque hay lineas que no tienen proveedor');
                    finestra.CLOSE;
                    Gest_Res.Pedido_Compra(Rec, rLin, Contrato);
                END;
            }
        }
        addbefore("&Job")
        {
            group("Pr&esupuesto")
            {
                action("Copiar &presupuesto")
                {
                    ApplicationArea = All;
                    Image = CopyBudget;
                    Caption = 'Copiar &presupuesto';
                    trigger OnAction()
                    Begin
                        CopiaPresupuesto.DefCabVentas(Rec);
                        CopiaPresupuesto.RUNMODAL;
                        CLEAR(CopiaPresupuesto);
                    END;
                }
                action("Re&novar presupuesto")
                {
                    ApplicationArea = All;
                    Image = NewTimesheet;
                    Caption = 'Re&novar presupuesto';
                    trigger OnAction()
                    Begin
                        RenovarPresup.DefCabVentas(Rec);
                        RenovarPresup.RUNMODAL;
                        CLEAR(RenovarPresup);
                    END;
                }
                action("&Ver Proyectos Asociados")
                {
                    ApplicationArea = All;
                    Image = Relatives;
                    Caption = '&Ver Proyectos Asociados';
                    trigger OnAction()
                    Var
                        rProyecto: Record 167;
                    BEGIN
                        if Rec."Proyecto original" <> '' THEN BEGIN
                            rProyecto.RESET;
                            rProyecto.SETRANGE("Proyecto original", Rec."Proyecto original");
                            Page.RUN(89, rProyecto);
                        END;
                    END;
                }
                action("&Texto ampliado línea")
                {
                    ApplicationArea = All;
                    Image = Relatives;
                    ShortcutKey = F10;
                    Caption = '&Texto ampliado línea';
                    trigger OnAction()
                    Begin
                        CurrPage.JobTaskLines2.Page.LlamaTexto(0);
                    END;
                }
                action("&Ordenes Publicidad")
                {
                    ApplicationArea = All;
                    Image = OrderReminder;
                    ShortCutKey = 'Ctrl+F3';
                    Caption = '&Ordenes Publicidad';
                    trigger OnAction()
                    Begin
                        CurrPage.JobTaskLines2.Page.OrdenesPubli;
                    END;
                }
                action("Revisar Tari&fas")
                {
                    ApplicationArea = All;
                    Image = PriceAdjustment;
                    Caption = 'Revisar Tari&fas';
                    trigger OnAction()
                    Begin
                        CurrPage.JobTaskLines2.Page.VerTarifas;
                    END;
                }
                action("Crear &Reservas")
                {
                    ApplicationArea = All;
                    Image = Reserve;
                    Caption = 'Crear &Reservas';
                    trigger OnAction()
                    Begin
                        CurrPage.JobTaskLines2.Page.CreaReservas;
                    END;
                }
                action("Ver R&eservas")
                {
                    ApplicationArea = All;
                    Image = Find;
                    Caption = 'Ver R&eservas';
                    trigger OnAction()
                    Begin
                        CurrPage.JobTaskLines2.Page.VerReservas;
                    END;
                }
                action("Cambiar Cliente")
                {
                    ApplicationArea = All;
                    Image = CustomerCode;
                    trigger OnAction()
                    Var
                        Contrato: Record "Sales Header";
                        Cust: Record "Customer";
                        Cust2: Record "Customer";
                        ShiptoAddress: Record "Ship-to Address";
                        Job: Record Job;
                        ContBusRel: Record "Contact Business Relation";
                    begin
                        if Page.RunModal(0, Cust) <> Action::LookupOK Then exit;
                        Cust2.Get(Cust."No.");
                        Contrato.SETFILTER(Contrato."Document Type", '%1|%2|%3', Contrato."Document Type"::Invoice, Contrato."Document Type"::"Credit Memo",
                        Contrato."Document Type"::Order);
                        Contrato.SETRANGE(Contrato."Nº Proyecto", Rec."No.");
                        if Contrato.FINDFIRST THEN
                            REPEAT
                                Cust.Get(Cust2."No.");
                                Rec."Sell-to Customer No." := Cust."No.";
                                Contrato."Sell-to Customer Name" := Cust.Name;
                                Contrato."Payment Method Code" := Cust."Payment Method Code";
                                Contrato."Payment Terms Code" := Cust."Payment Terms Code";
                                Contrato."Salesperson Code" := Cust."Salesperson Code";
                                Contrato."Sell-to Customer Name 2" := Cust."Name 2";
                                Contrato."Sell-to Address" := Cust.Address;
                                Contrato."Sell-to Address 2" := Cust."Address 2";
                                Contrato."Sell-to City" := Cust.City;
                                Contrato."Sell-to Post Code" := Cust."Post Code";
                                Contrato."Sell-to County" := Cust.County;
                                Contrato."Sell-to Country/Region Code" := Cust."Country/Region Code";
                                Contrato."Sell-to Contact" := Cust.Contact;
                                Contrato."Sell-to E-Mail" := Cust."E-Mail";
                                Contrato."Sell-to Phone No." := Cust."Phone No.";
                                Contrato."VAT Registration No." := Cust."VAT Registration No.";
                                if Cust."Bill-to Customer No." <> '' THEN Cust.GET(Cust."Bill-to Customer No.");
                                Contrato."Bill-to Customer No." := Cust."No.";
                                if Cust."Primary Contact No." <> '' then begin
                                    Contrato."Bill-to Contact No." := Cust."Primary Contact No.";
                                    Contrato."Sell-to Contact No." := Cust."Primary Contact No.";
                                end else begin
                                    ContBusRel.Reset();
                                    ContBusRel.SetCurrentKey("Link to Table", "No.");
                                    ContBusRel.SetRange("Link to Table", ContBusRel."Link to Table"::Customer);
                                    ContBusRel.SetRange("No.", Contrato."Bill-to Customer No.");
                                    if ContBusRel.FindFirst() then
                                        Contrato."Bill-to Contact No." := ContBusRel."Contact No."
                                    else
                                        Contrato."Bill-to Contact No." := '';
                                    ContBusRel.Reset();
                                    ContBusRel.SetCurrentKey("Link to Table", "No.");
                                    ContBusRel.SetRange("Link to Table", ContBusRel."Link to Table"::Customer);
                                    ContBusRel.SetRange("No.", Contrato."Sell-to Customer No.");
                                    if ContBusRel.FindFirst() then
                                        Contrato."Sell-to Contact No." := ContBusRel."Contact No."
                                    else
                                        Contrato."Sell-to Contact No." := '';

                                end;
                                Contrato."Bill-to Contact" := Cust.Contact;
                                Contrato."Bill-to Name" := Cust.Name;
                                Contrato."Bill-to Name 2" := Cust."Name 2";
                                Contrato."Bill-to Address" := Cust.Address;
                                Contrato."Bill-to Address 2" := Cust."Address 2";
                                Contrato."Bill-to City" := Cust.City;
                                Contrato."Bill-to Post Code" := Cust."Post Code";
                                Contrato."Bill-to County" := Cust.County;
                                Contrato."Bill-to Country/Region Code" := Cust."Country/Region Code";
                                Contrato."Bill-to Contact" := Cust.Contact;
                                Contrato."VAT Registration No." := Cust."VAT Registration No.";
                                Contrato."VAT Bus. Posting Group" := Cust."VAT Bus. Posting Group";
                                Contrato."Gen. Bus. Posting Group" := Cust."Gen. Bus. Posting Group";
                                Contrato."Customer Posting Group" := Cust."Customer Posting Group";
                                Contrato."Ship-to Address" := Contrato."Sell-to Address";
                                Contrato."Ship-to Address 2" := Contrato."Sell-to Address 2";
                                Contrato."Ship-to City" := Contrato."Sell-to City";
                                Contrato."Ship-to County" := Contrato."Sell-to County";
                                Contrato."Ship-to Post Code" := Contrato."Sell-to Post Code";
                                Contrato."Ship-to Country/Region Code" := Contrato."Sell-to Country/Region Code";
                                Contrato."Ship-to Contact" := Contrato."Sell-to Contact";
                                Contrato."Ship-to Code" := '';



                                Contrato.MODIFY;

                            UNTIL Contrato.NEXT = 0;
                        if Job.Get(Rec."No.") Then begin
                            Cust.Get(Cust2."No.");
                            Job."Sell-to Customer No." := Cust."No.";
                            Job."Sell-To Customer Name" := Cust.Name;
                            Job."Sell-to Customer Name 2" := Cust."Name 2";
                            Job."Sell-to Address" := Cust.Address;
                            Job."Sell-to Address 2" := Cust."Address 2";
                            Job."Sell-to City" := Cust.City;
                            Job."Sell-to Post Code" := Cust."Post Code";
                            Job."Sell-to Country/Region Code" := Cust."Country/Region Code";
                            Job."Currency Code" := Cust."Currency Code";
                            Job."Customer Disc. Group" := Cust."Customer Disc. Group";
                            Job."Customer Price Group" := Cust."Customer Price Group";
                            Job."Language Code" := Cust."Language Code";
                            Job."Payment Method Code" := Cust."Payment Method Code";
                            Job."Payment Terms Code" := Cust."Payment Terms Code";
                            Job."Cód. vendedor" := Cust."Salesperson Code";
                            if Cust."Bill-to Customer No." <> '' THEN
                                Cust.GET(Cust."Bill-to Customer No.");
                            Job."Bill-to Customer No." := Cust."No.";
                            Job."Bill-to Name" := Cust.Name;
                            Job."Bill-to Name 2" := Cust."Name 2";
                            Job."Bill-to Address" := Cust.Address;
                            Job."Bill-to Address 2" := Cust."Address 2";
                            Job."Bill-to City" := Cust.City;
                            Job."Bill-to Post Code" := Cust."Post Code";
                            Job."Bill-to Country/Region Code" := Cust."Country/Region Code";
                            Job."Currency Code" := Cust."Currency Code";
                            Job."Bill-to County" := Cust.County;
                            if Cust."Bill-to Customer No." <> '' THEN Cust.GET(Cust."Bill-to Customer No.");
                            Job."Bill-to Customer No." := Cust."No.";
                            if Cust."Primary Contact No." <> '' then begin
                                Job."Bill-to Contact No." := Cust."Primary Contact No.";
                                Job."Sell-to Contact No." := Cust."Primary Contact No.";
                            end else begin
                                ContBusRel.Reset();
                                ContBusRel.SetCurrentKey("Link to Table", "No.");
                                ContBusRel.SetRange("Link to Table", ContBusRel."Link to Table"::Customer);
                                ContBusRel.SetRange("No.", Job."Bill-to Customer No.");
                                if ContBusRel.FindFirst() then
                                    Job."Bill-to Contact No." := ContBusRel."Contact No."
                                else
                                    Job."Bill-to Contact No." := '';
                                ContBusRel.Reset();
                                ContBusRel.SetCurrentKey("Link to Table", "No.");
                                ContBusRel.SetRange("Link to Table", ContBusRel."Link to Table"::Customer);
                                ContBusRel.SetRange("No.", Job."Sell-to Customer No.");
                                if ContBusRel.FindFirst() then
                                    Job."Sell-to Contact No." := ContBusRel."Contact No."
                                else
                                    Job."Sell-to Contact No." := '';

                            end;
                            Job."Ship-to Address" := Job."Sell-to Address";
                            Job."Ship-to Address 2" := Job."Sell-to Address 2";
                            Job."Ship-to City" := Job."Sell-to City";
                            Job."Ship-to County" := Job."Sell-to County";
                            Job."Ship-to Post Code" := Job."Sell-to Post Code";
                            Job."Ship-to Country/Region Code" := Job."Sell-to Country/Region Code";
                            Job."Ship-to Contact" := Job."Sell-to Contact";
                            Job."Ship-to Code" := '';
                            Job.Modify();
                        end;
                    end;
                }
                action("&Navegar")
                {
                    ApplicationArea = All;
                    Image = Navigate;
                    trigger OnAction()
                    BEGIN
                        Rec.Navigate;
                    END;
                }
                action("Importar Lineas de Excel")
                {
                    ApplicationArea = All;
                    Image = ImportExcel;
                    Caption = 'Importar Lineas de Excel';
                    trigger OnAction()
                    var
                        TempExcelBuffer: Record "Excel Buffer" temporary;
                        FileName: Text;
                        SheetName: Text;
                        FileMgt: Codeunit "File Management";
                        InStream: InStream;
                        JobPlanningLine: Record "Job Planning Line";
                        Resource: Record Resource;
                        RowNo: Integer;
                        ColNo: Integer;
                        NoValue: Text;
                        DescValue: Text;
                        QtyValue: Decimal;
                        PriceValue: Decimal;
                        CostValue: Decimal;
                        LineNo: Integer;
                        TaskNo: Code[20];
                    begin
                        // Configurar la tarea predeterminada como "10"
                        TaskNo := '10';

                        // Buscar el último número de línea para continuar la secuencia
                        JobPlanningLine.Reset();
                        JobPlanningLine.SetRange("Job No.", Rec."No.");
                        if JobPlanningLine.FindLast() then
                            LineNo := JobPlanningLine."Line No." + 10000
                        else
                            LineNo := 10000;

                        if UploadIntoStream('Seleccionar archivo Excel', '', 'Archivos Excel (*.xlsx)|*.xlsx|Todos los archivos (*.*)|*.*', FileName, InStream) then begin
                            SheetName := TempExcelBuffer.SelectSheetsNameStream(InStream);
                            TempExcelBuffer.OpenBookStream(InStream, SheetName);
                            TempExcelBuffer.ReadSheet();

                            // Buscar la primera fila con datos (asumiendo que la primera fila es encabezado)
                            RowNo := 2;

                            // Recorrer todas las filas del Excel
                            while TempExcelBuffer.Get(RowNo, 1) do begin
                                Clear(NoValue);
                                Clear(DescValue);
                                Clear(QtyValue);
                                Clear(PriceValue);
                                Clear(CostValue);

                                // Columna 1: No. del recurso
                                NoValue := TempExcelBuffer."Cell Value as Text";

                                // Leer columnas adicionales si existen
                                if TempExcelBuffer.Get(RowNo, 2) then
                                    DescValue := TempExcelBuffer."Cell Value as Text";

                                if TempExcelBuffer.Get(RowNo, 3) then
                                    Evaluate(QtyValue, TempExcelBuffer."Cell Value as Text")
                                else
                                    QtyValue := 1;

                                if TempExcelBuffer.Get(RowNo, 4) then
                                    Evaluate(PriceValue, TempExcelBuffer."Cell Value as Text");

                                if TempExcelBuffer.Get(RowNo, 5) then
                                    Evaluate(CostValue, TempExcelBuffer."Cell Value as Text");

                                // Verificar si existe el recurso
                                if Resource.Get(NoValue) then begin
                                    // Crear línea de planificación del proyecto
                                    JobPlanningLine.Init();
                                    JobPlanningLine."Job No." := Rec."No.";
                                    JobPlanningLine."Job Task No." := TaskNo;
                                    JobPlanningLine."Line No." := LineNo;
                                    JobPlanningLine.Type := JobPlanningLine.Type::Resource;
                                    JobPlanningLine.Validate("No.", NoValue);

                                    // Si hay descripción en el Excel, usar esa en lugar de la del recurso
                                    if DescValue <> '' then
                                        JobPlanningLine.Description := DescValue;

                                    // Establecer cantidad
                                    JobPlanningLine.Validate(Quantity, QtyValue);

                                    // Establecer precio y costo si se proporcionaron
                                    if PriceValue <> 0 then
                                        JobPlanningLine.Validate("Unit Price", PriceValue);

                                    if CostValue <> 0 then
                                        JobPlanningLine.Validate("Unit Cost", CostValue);

                                    // Establecer fechas de inicio y fin desde el proyecto
                                    JobPlanningLine."Planning Date" := Rec."Starting Date";
                                    JobPlanningLine."Fecha Final" := Rec."Ending Date";

                                    // Insertar la línea
                                    if JobPlanningLine.Insert() then
                                        LineNo += 10000
                                    else
                                        Message('Error al insertar línea para el recurso %1', NoValue);
                                end else
                                    Message('El recurso %1 no existe en la base de datos.', NoValue);

                                RowNo += 1;
                            end;

                            Message('Importación completada. Las líneas han sido creadas para el proyecto.');
                        end;
                    end;
                }

            }


        }
    }
    VAR
        rP2: Record Job;
        rLinProy: Record "Job Planning Line";
        rCnfProy: Record 315;
        CopiaPresupuesto: Report "Copiar presupuesto";
        RenovarPresup: Report "Renovar presupuesto";
        cProyecto: Codeunit "Gestion Proyecto";
        finestra: Page Dialogo;
        fech: Date;
        Text001: Label 'Ha modificado %1.\¿Desea modificar las líneas del contrato?';
        RenovadoEditable: Boolean;
        InvoiceCurrencyCodeEDITABLE: Boolean;
        wEmpresa: Text[30];

    trigger OnOpenPage()
    begin

        if wEmpresa <> '' THEN
            CurrPage.JobTaskLines2.Page.CambiaEmpresa(wEmpresa);

        AplicarFiltros;                            // $003
        CamposEditables;
        if wEmpresa <> '' THEN BEGIN
            CurrPage.EDITABLE := FALSE;
            CurrPage.JobTaskLines2.Page.EDITABLE := FALSE;
            // CurrPage.BotonProyecto.ENABLED:=FALSE;
            // CurrPage.BotonPresupuesto.ENABLED:=FALSE;
            // CurrPage.BotonWip.ENABLED:=FALSE;
            // CurrPage.Botonprecio.ENABLED:=FALSE;
            // CurrPage.BotonPlanif.ENABLED:=FALSE;
        END;
    end;

    PROCEDURE CambiaEmpresa(Emp: Text[30])
    begin
        Rec.CHANGECOMPANY(Emp);
        wEmpresa := Emp;
        rP2.CHANGECOMPANY(Emp);
    end;

    PROCEDURE CurrencyCheck();
    BEGIN
        if Rec."Currency Code" <> '' THEN
            InvoiceCurrencyCodeEDITABLE := FALSE
        ELSE
            InvoiceCurrencyCodeEDITABLE := TRUE;
        CurrPage.Update(false);
    END;

    PROCEDURE CamposEditables();
    BEGIN
        rCnfProy.GET;
        if rCnfProy."Poder modificar renovado" THEN
            RenovadoEDITABLE := TRUE
        ELSE
            RenovadoEDITABLE := FALSE;
        CurrPage.UPDATE(false);
    END;

    PROCEDURE AplicarFiltros();
    VAR
        rUsuario: Record 91;
    BEGIN
        //$003
        if rUsuario.GET(USERID) THEN BEGIN
            if rUsuario."Filtro vendedor" <> '' THEN BEGIN
                Rec.FILTERGROUP(2);
                Rec.SETFILTER("Cód. vendedor", rUsuario."Filtro vendedor");
                Rec.FILTERGROUP(0);
            END;
        END;
        Rec.FILTERGROUP(2);
        Rec.SETFILTER(Status, '<>%1', Rec.Status::Quote);
        Rec.FILTERGROUP(0);
    END;

    PROCEDURE TraeCodDtoFac(): Code[20];
    VAR
        rCliente: Record Customer;
    BEGIN
        if rCliente.GET(Rec."Bill-to Customer No.") THEN
            EXIT(rCliente."Invoice Disc. Code");
        EXIT('');
    END;

    //   $001 Actualizo líneas si se modifica tipo, soporte de, o fija/papel en cabecera.
    //   $002 FCL-25/05/10. Incluyo proyecto origen y modifico la llamada a ver proyectos asociados

    //   ESTE OBJETO ES DISTINTO A MALLA

    //   $003 FCL-05/07/10. Aplico filtros por vendedor definidos en la tabla de usuarios.
    //        FCL-06/07/10. Incluyo una llamada a un formulario donde se aplican algunos
    //                      filtros de cabecera en las líneas.
    //   $004 FCL-30/08/10. Si modifican Subtipo en la cabecera lo modificaré en las líneas (se ha creado este campo), igual que con Tipo.




    trigger OnAfterGetRecord()
    var
        myInt: Integer;
        WaitTaskId: Integer;
        TaskParameters: Dictionary of [Text, Text];
    begin

        Case Rec.Status Of
            Rec.Status::Planning:
                Estado := Estado::Planning;
            Rec.Status::Quote:
                Estado := Estado::Quote;
            Rec.Status::Open:
                Estado := Estado::Open;
            Rec.Status::Completed:
                Estado := Estado::Completed;

        End;

        // ShowData(true);
        // CurrPage.WebViewer.Page.ShowData();
    end;


    trigger OnAfterGetCurrRecord()
    var
        myInt: Integer;
    begin
        Case Rec.Status Of
            Rec.Status::Planning:
                Estado := Estado::Planning;
            Rec.Status::Quote:
                Estado := Estado::Quote;
            Rec.Status::Open:
                Estado := Estado::Open;
            Rec.Status::Completed:
                Estado := Estado::Completed;

        End;
        // ShowData(true);

    end;


    var
        myInt: Integer;
        Estado: Enum "Job Status Kuara";

    /// <summary>
    /// ShowData.
    /// </summary>
    /// <param name="a">Boolean.</param>
    // procedure ShowData(a: Boolean)
    // var
    //     RD: Record "Document Attachment";
    //     IStream: InStream;
    //     myInt: Integer;
    //     Base64String: Text;
    //     TempBlob2: Codeunit "Base64 Convert";
    //     JsonObj: Codeunit "Json Text Reader/Writer";
    //     JsonText: Text;
    //     OsTream: OutStream;
    //     TempBlob: Codeunit "Temp Blob";
    //     Tipo: Text;
    //     Filename: Text;

    // begin
    // if not a then exit;
    // RD.SETRANGE(RD."Table ID", 167);
    // rd.SetRange(rd."No.", Rec."No.");
    // JsonObj.WriteStartObject('');
    // JsonObj.WriteStringProperty('type', 'imageLoad');

    // JsonObj.WriteStartArray('data');

    // if RD.FINDFIRST THEN
    //     REPEAT
    //         TempBlob.CreateOutStream(OsTream);
    //         RD."Document Reference ID".ExportStream(OsTream);
    //         TempBlob.CreateInStream(IStream);
    //         //UploadIntoStream('', RD.URL1, 'ALL Files (*.*)|*.*', RD.URL1, IStream);
    //         Base64String := TempBlob2.ToBase64(IStream);
    //         JsonObj.WriteStartObject('');
    //         JsonObj.WriteStringProperty('type', 'image');
    //         Tipo := 'data:image/' + rd."File Extension";
    //         JsonObj.WriteStringProperty('content', tipo + ';base64,' + Base64String);
    //         JsonObj.WriteStringProperty('description', rd."File Name");
    //         JsonObj.WriteEndObject();
    //     until RD.Next() = 0;
    // JsonObj.WriteEndArray();
    // JsonObj.WriteEndObject();
    // JsonText := JsonObj.GetJSonAsText();
    // CurrPage.WebViewer.Page.LoadPdfFromBlob(JsonText);

    // end;
}
