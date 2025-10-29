/// <summary>
/// PageExtension ResourceList (ID 80215).
/// </summary>
pageextension 80206 ResourceList Extends "Resource List"
{
    Editable = True;
    layout
    {
        addfirst(Content)
        {
            field(Empresa; Emp)
            {
                ApplicationArea = All;
                Editable = true;

                TableRelation = Company.Name;// WHERE (Clave Recursos=FILTER(<>''));
                                             // OnActivate=BEGIN
                                             //             CurrPage.Acep.ENABLED:=FALSE;
                                             //         END;
                                             // OnDeactivate=BEGIN
                                             //             CurrPage.Acep.ENABLED:=TRUE;
                                             //             END;
                trigger OnLookup(var Text: Text): Boolean
                Var
                    Company: Record Company;
                BEGIN
                    if Page.Runmodal(Page::Companies, Company) in [Action::LookupOK, Action::OK] Then Emp := Company.Name;
                    CambiaEmpresa(Emp);



                END;

                trigger OnValidate()
                BEGIN
                    CambiaEmpresa(Emp);
                END;
            }
        }
        modify(Type)
        {
            Visible = false;
        }
        modify("Base Unit of Measure")
        {
            Visible = false;
        }
        modify("Resource Group No.")
        {
            Visible = false;
        }
        modify("Direct Unit Cost")
        {
            Visible = false;
        }
        modify("Indirect Cost %")
        {
            Visible = false;
        }
        modify("Unit Cost")
        {
            Visible = false;
        }
        modify("Price/Profit Calculation")
        {
            Visible = false;
        }
        modify("Profit %")
        {
            Visible = false;
        }
        modify("Unit Price")
        {
            Visible = false;
        }
        modify("Gen. Prod. Posting Group")
        {
            Visible = false;
        }
        modify("VAT Prod. Posting Group")
        {
            Visible = false;
        }
        modify("Privacy Blocked")
        {
            Visible = false;
        }
        modify("Search Name")
        {
            Visible = false;
        }
        modify("Default Deferral Template Code")
        {
            Visible = false;
        }
        modify("Name 2") { Visible = true; }
        addafter("No.")
        {

            field(Nombre; Rec.Name) { ApplicationArea = All; Editable = false; StyleExpr = Color; }
            //field("Name 2"; Rec."Name 2") { ApplicationArea = All; }
            field(Typo; Rec.Type) { ApplicationArea = All; }
            field("Tipo Recurso"; Rec."Tipo Recurso") { ApplicationArea = All; StyleExpr = ONFormat; }
            field("Recurso Agrupado"; Rec."Recurso Agrupado") { ApplicationArea = All; Style = Favorable; }
            field(Producción; Rec.Producción) { ApplicationArea = All; Style = Favorable; }
            field("No. Orden"; Rec."No. Orden") { ApplicationArea = All; }
            field("Tipo Recurso principal"; Rec."Tipo Recurso principal") { ApplicationArea = All; Style = Favorable; }
            field("Customer Price Group"; Rec."Customer Price Group") { ApplicationArea = All; }
            field("Precio Vigente"; Precio) { ApplicationArea = All; Caption = 'Precio Vigente'; }
            field(Medidas; Rec.Medidas) { ApplicationArea = All; }
            field("Unidad de medida"; Rec."Base Unit of Measure") { ApplicationArea = All; }
            field("Familia"; Rec."Resource Group No.") { ApplicationArea = All; Editable = true; }
            field(Categoria; Rec.Categoria) { ApplicationArea = All; }
            field(Iluminado; Rec.Iluminado) { ApplicationArea = All; }
            field("Zona Comercial"; Rec."Zona Comercial") { ApplicationArea = All; }
            field(Orientación; Rec.Orientación) { ApplicationArea = All; }
            field("Último Coste"; Rec."Direct Unit Cost") { ApplicationArea = All; Editable = false; }
            field("% Coste indirecto"; Rec."Indirect Cost %") { ApplicationArea = All; Editable = false; }
            field("Coste Unitario"; Rec."Unit Cost") { ApplicationArea = All; }
            field("Tipo cálculo bebeficio"; Rec."Price/Profit Calculation") { ApplicationArea = All; }
            field("% Beneficio"; Rec."Profit %") { ApplicationArea = All; }
            field("Price Venta"; Rec."Unit Price") { ApplicationArea = All; }
            field("Grupo registro producto"; Rec."Gen. Prod. Posting Group") { ApplicationArea = All; Editable = false; }
            field("Grupo registro iva producto"; Rec."VAT Prod. Posting Group") { ApplicationArea = All; }
            field("Departamento"; Rec."Global Dimension 1 Code") { ApplicationArea = All; }
            field("Programa"; Rec."Global Dimension 2 Code") { ApplicationArea = All; }
            field("Alias"; Rec."Search Name") { ApplicationArea = All; }
            field(Municipio; Rec.Municipio) { ApplicationArea = All; }
            field("C.P. Municipio"; Rec."C.P. Municipio") { ApplicationArea = All; }
            field(PuntoX; Rec.PuntoX) { ApplicationArea = All; }
            field(PuntoY; Rec.PuntoY) { ApplicationArea = All; }
            field("Tipo Montaje"; Rec."Tipo Montaje") { ApplicationArea = All; }
            field(Peligrosidad; Rec.Peligrosidad) { ApplicationArea = All; }
            field("Linea vida"; Rec."Linea vida") { ApplicationArea = All; }
            field("Employment Date"; Rec."Employment Date")
            {
                ApplicationArea = All;
                Caption = 'Fecha alta';
            }
            field("Fecha baja"; Rec."Fecha baja") { ApplicationArea = All; }
            field("Tipo fijacion"; Rec."Tipo fijacion") { ApplicationArea = All; }
            field(Soporte; Rec.Soporte) { ApplicationArea = All; }
            field("Dimensión Zona"; Rec."Dimensión Zona") { ApplicationArea = All; }
            field(Principal; Rec.Principal) { ApplicationArea = All; }
            // field("Global Dimension 3 Code"; Rec."Global Dimension 3 Code") { ApplicationArea = All; }
            // field("Global Dimension 5 Code"; Rec."Global Dimension 5 Code") { ApplicationArea = All; }
            // field("Global Dimension 4 Code"; Rec."Global Dimension 4 Code") { ApplicationArea = All; }
            field(DZona; DZona) { ApplicationArea = All; Caption = 'Descripción Zona'; }
            field(Prohibiciones; Rec.Prohibiciones) { ApplicationArea = All; }
            field(Zona; Rec.Zona) { ApplicationArea = All; }
            field("Observaciones peligrosidad"; Rec."Observaciones peligrosidad") { ApplicationArea = All; }
            field("Ultima Reserva"; Rec."Ultima Reserva") { ApplicationArea = All; }
        }
        //modifica el campo no. para poner un estylod e color
        modify("No.")
        {
            StyleExpr = Color;
        }

    }
    actions
    {
        addfirst("&Resource")
        {
            action("Crear Recurso")
            {
                ApplicationArea = All;
                Image = NewResource;
                ShortcutKey = 'Ctrl+N';
                trigger OnAction()
                var
                    Res: Record Resource temporary;
                    Asis: Page "Wizard Recursos";
                begin
                    Res.Init();
                    Asis.Carga();
                    Asis.RunModal();

                end;
            }
            action("Bloquear este Recurso")
            {
                ApplicationArea = All;
                Image = Lock;
                Caption = 'Bloquear Recurso';
                trigger OnAction()
                VAR
                    r60156: Record "Incidencias Rescursos";
                    Sec: Integer;
                begin
                    //Buscar ultima incidencia  
                    if r60156.FindLast() then
                        Sec := r60156."Nº Incidencia" + 1
                    else
                        Sec := 1;

                    r60156.INIT;
                    r60156."Nº Incidencia" := Sec;
                    r60156."Nº Recurso" := Rec."No.";
                    r60156.Insert();
                    Commit();
                    Page.RunModal(Page::"Ficha Incidencias", r60156);
                end;

            }
            action("Des-Bloquear este Recurso")
            {
                ApplicationArea = All;
                Image = UnApply;
                Caption = 'Des-Bloquear Recurso';
                trigger OnAction()
                VAR
                    r60156: Record "Incidencias Rescursos";
                    Sec: Integer;
                begin
                    //Buscar ultima incidencia  
                    r60156.SetRange("Nº Recurso", Rec."No.");
                    r60156.SetRange("Incidencia de Bloqueo", bloqueo::Bloqueo);

                    r60156.DeleteAll(true);

                end;

            }
            action("Bloquear Recursos")
            {
                ApplicationArea = All;
                Image = LotProperties;
                Caption = 'Bloquear Recursos';
                trigger OnAction()
                VAR
                    r60156: Record "Incidencias Rescursos";
                    rIn: Record "Incidencias Rescursos";
                    rDia: Record "Diario Incidencias Rescursos";
                    rRes: Record 156;
                    Sec: Integer;
                    i: Date;
                    TotalResources: Integer;
                    CurrentResource: Integer;
                    CompletionPercentage: Decimal;
                    Ventana: Dialog;
                begin
                    //Buscar ultima incidencia  
                    if r60156.FindLast() then
                        Sec := r60156."Nº Incidencia" + 1
                    else
                        Sec := 1;
                    Message('Se bloquearan todos los recursos de la lista,con los mismos datos que el recurso actual');
                    r60156.INIT;
                    r60156."Nº Incidencia" := Sec;
                    r60156."Nº Recurso" := Rec."No.";
                    r60156.Insert();
                    Commit();
                    Page.RunModal(Page::"Ficha Incidencias", r60156);
                    Commit();
                    r60156.Get(Sec);
                    //tesfield de fechas
                    r60156.TestField("Fecha Inicio");
                    r60156.TestField("Fecha fin");
                    CurrPage.SETSELECTIONFILTER(rReS);
                    Ventana.Open('Bloquear Recursos: #1###### @2@@@');
                    Ventana.Update(2, 0);
                    TotalResources := rRes.COUNT;
                    if rRes.FindSet() then
                        repeat
                            Sec += 1;
                            Ventana.Update(1, rRes."No.");
                            if (Sec mod 5) = 0 then
                                Ventana.Update(2, 100 * Sec div TotalResources);
                            rIn := r60156;
                            rIn."Nº Incidencia" := Sec;
                            rIn."Fecha Inicio" := r60156."Fecha Inicio";
                            rin."Fecha fin" := r60156."Fecha fin";
                            rIn."Nº Recurso" := rRes."No.";
                            rIn.Motivo := r60156.Motivo;
                            rRes."Fecha Baja" := 0D;
                            Case rIn.Motivo Of
                                rIn.Motivo::"Baja":
                                    begin
                                        rIn."Incidencia de Bloqueo" := rIn."Incidencia de Bloqueo"::"Bloqueo";
                                        rres."Fecha Baja" := rIn."Fecha inicio";
                                        rRes."Resource Group No." := 'BAJA';
                                        rRes.MODIFY;

                                    end;
                                rIn.Motivo::Bloqueo:
                                    begin
                                        rIn."Incidencia de Bloqueo" := rIn."Incidencia de Bloqueo"::"Bloqueo";
                                    end;
                                rIn.Motivo::"Fin Concesion":
                                    begin
                                        rIn."Incidencia de Bloqueo" := rIn."Incidencia de Bloqueo"::"Bloqueo";
                                    end;
                                rIn.Motivo::"Lista de espera":
                                    begin
                                        rIn."Incidencia de Bloqueo" := rIn."Incidencia de Bloqueo"::Informacion;
                                    end;
                                rIn.Motivo::Obras:
                                    begin
                                        rIn."Incidencia de Bloqueo" := rIn."Incidencia de Bloqueo"::Bloqueo;
                                    end;
                                rIn.Motivo::Otros:
                                    begin
                                        rIn."Incidencia de Bloqueo" := rIn."Incidencia de Bloqueo"::Bloqueo;
                                    end;
                                rIn.Motivo::Reparacion:
                                    begin
                                        rIn."Incidencia de Bloqueo" := rIn."Incidencia de Bloqueo"::Bloqueo;
                                    end;
                            End;



                            rIn.Insert();
                            // desde Fecha inicio hasta fecha fin crear diario
                            for i := r60156."Fecha Inicio" to r60156."Fecha fin" do begin
                                rDia.INIT;
                                rDia."Nº Incidencia" := Sec;
                                rDia.Motivo := r60156.Motivo;
                                rDia."Nº Recurso" := rRes."No.";
                                rDia."Fecha" := i;
                                rDia.Insert();
                            end;


                            // Añadir commit cada 100 registros
                            if (Sec mod 100) = 0 then begin
                                Commit();

                            end;
                        // Mostrar diálogo de porcentaje de completado

                        until rRes.Next() = 0;

                    Commit();
                    Ventana.Close();
                end;

            }
            action("Des-Bloquear Recursos")
            {
                ApplicationArea = All;
                Image = LotProperties;
                Caption = 'Des-bloquear Recursos';
                trigger OnAction()
                VAR
                    r60156: Record "Incidencias Rescursos";
                    rIn: Record "Incidencias Rescursos";
                    rDia: Record "Diario Incidencias Rescursos";
                    rRes: Record 156;
                    Sec: Integer;
                    i: Date;
                    TotalResources: Integer;
                    CurrentResource: Integer;
                    CompletionPercentage: Decimal;
                    Ventana: Dialog;
                begin
                    //Buscar ultima incidencia  
                    If Confirm('¿Quiere des-bloquear todos los recursos de la lista?') Then begin
                        CurrPage.SETSELECTIONFILTER(rReS);
                        Ventana.Open('Des-bloqueando Recurso: #1###### @2@@@');
                        Ventana.Update(2, 0);
                        TotalResources := rRes.COUNT;
                        if rRes.FindSet() then
                            repeat
                                Sec += 1;
                                Ventana.Update(1, rRes."No.");
                                //Buscar ultima incidencia  
                                r60156.SetRange("Nº Recurso", rRes."No.");
                                r60156.SetRange("Incidencia de Bloqueo", bloqueo::Bloqueo);

                                r60156.DeleteAll(true);
                            // Mostrar diálogo de porcentaje de completado

                            until rRes.Next() = 0;

                        Commit();
                        Ventana.Close();
                    end;
                end;
            }
            action("Añadir a Lista Espera")
            {
                Image = AdjustEntries;
                ApplicationArea = All;
                Scope = Repeater;
                trigger OnAction()
                var
                    Res: Record Resource;
                    Customer: Record Customer;
                    Vendedor: Record "Salesperson/Purchaser";
                    r60156: Record "Incidencias Rescursos";
                    Orden: Record "Incidencias Rescursos";
                    Sec: Integer;
                    Ventana: Page Dialogo;
                    NombreCliente: Text;
                begin
                    Ventana.SetTexto('Nombre del Cliente');
                    Ventana.RunModal();
                    Ventana.GetTexto(NombreCliente);
                    Message('Seleccione vendedor');
                    //if Page.RunModal(0, Customer) = Action::LookupCancel Then Error('No se ha elegido cliente');
                    Vendedor.SetRange("Code", Customer."Salesperson Code");
                    if Vendedor.FindFirst() Then;
                    Vendedor.Reset();
                    if Page.RunModal(0, Vendedor) = Action::LookupCancel Then Error('No se ha elegido vendedor');
                    //Buscar ultima incidencia  
                    if r60156.FindLast() then
                        Sec := r60156."Nº Incidencia" + 1
                    else
                        Sec := 1;
                    Orden.SetCurrentKey("Nº Recurso", Orden);
                    Orden.SetRange("Nº Recurso", Rec."No.");
                    If Not Orden.FindLast() Then orden.Init();
                    r60156.INIT;
                    r60156."Nº Incidencia" := Sec;
                    r60156."Nº Recurso" := Rec."No.";
                    r60156."Fecha Inicio" := Today;
                    r60156."Fecha fin" := Today;
                    r60156."Vendedor" := Vendedor."Code";
                    r60156."Nombre Cliente" := NombreCliente;
                    r60156.Validate(Motivo, r60156.Motivo::"Lista de Espera");
                    r60156.Observaciones := 'Añadido a lista de espera el ' + Format(Today) + ' por ' + UserId;
                    r60156.Orden := Orden.Orden + 1;
                    r60156.Insert(true);

                end;
            }
            action("Añadir a Lista Espera desde Excel")
            {
                Image = AdjustEntries;
                ApplicationArea = All;
                Scope = Repeater;
                trigger OnAction()
                var
                    TempExcelBuffer: Record "Excel Buffer" temporary;
                    FileName: Text;
                    SheetName: Text;
                    FileMgt: Codeunit "File Management";
                    InStream: InStream;
                    Res: Record Resource;
                    Customer: Record Customer;
                    Vendedor: Record "Salesperson/Purchaser";
                    r60156: Record "Incidencias Rescursos";
                    Orden: Record "Incidencias Rescursos";
                    Sec: Integer;
                    RowNo: Integer;
                    RecursoNo: Code[20];
                    NombreCliente: Text[100];
                    CodigoVendedor: Code[20];
                    FechaReserva: Date;
                    ProyectoAntiguo: Code[20];
                    Observaciones: Text[250];
                    Descripcion: Text[100];
                    TextoOrden: Text[250];
                begin
                    if UploadIntoStream('Seleccionar archivo Excel', '', 'Archivos Excel (*.xlsx)|*.xlsx|Todos los archivos (*.*)|*.*', FileName, InStream) then begin
                        SheetName := TempExcelBuffer.SelectSheetsNameStream(InStream);
                        TempExcelBuffer.OpenBookStream(InStream, SheetName);
                        TempExcelBuffer.ReadSheet();
                    end;

                    // Buscar última incidencia para obtener el siguiente número
                    if r60156.FindLast() then
                        Sec := r60156."Nº Incidencia" + 1
                    else
                        Sec := 1;

                    RowNo := 2; // Empezar desde la fila 2 (saltar encabezados)
                    while TempExcelBuffer.Get(RowNo, 2) do begin
                        // Leer datos de cada columna del Excel
                        RecursoNo := TempExcelBuffer."Cell Value as Text";

                        // Saltar filas vacías
                        if RecursoNo = '' then begin
                            RowNo += 1;
                            // Saltar al siguiente registro
                        end else begin
                            //Leer Ordden en columna 1
                            if TempExcelBuffer.Get(RowNo, 1) then
                                TextoOrden := TempExcelBuffer."Cell Value as Text";

                            // Leer descripción (columna C)
                            if TempExcelBuffer.Get(RowNo, 3) then
                                Descripcion := TempExcelBuffer."Cell Value as Text";

                            // Leer fecha de reserva (columna D)
                            if TempExcelBuffer.Get(RowNo, 4) then
                                Evaluate(FechaReserva, TempExcelBuffer."Cell Value as Text");

                            // Leer nombre del cliente (columna E)
                            if TempExcelBuffer.Get(RowNo, 5) then
                                NombreCliente := TempExcelBuffer."Cell Value as Text";

                            // Leer código del vendedor (columna F)
                            if TempExcelBuffer.Get(RowNo, 6) then
                                CodigoVendedor := TempExcelBuffer."Cell Value as Text";

                            // Leer proyecto antiguo (columna H)
                            if TempExcelBuffer.Get(RowNo, 8) then
                                ProyectoAntiguo := TempExcelBuffer."Cell Value as Text";

                            // Leer observaciones (columna I)
                            if TempExcelBuffer.Get(RowNo, 9) then
                                Observaciones := TempExcelBuffer."Cell Value as Text";

                            // Verificar que el recurso existe
                            if not Res.Get(RecursoNo) then begin
                                Message('El recurso %1 no existe. Se saltará esta fila.', RecursoNo);
                            end else begin
                                // Verificar que el vendedor existe
                                if not Vendedor.Get(CodigoVendedor) then begin
                                    Message('El vendedor %1 no existe. Se saltará esta fila.', CodigoVendedor);
                                end else begin

                                    // Buscar orden para el recurso
                                    // Orden.SetCurrentKey("Nº Recurso", Orden);
                                    // Orden.SetRange("Nº Recurso", RecursoNo);
                                    // If Not Orden.FindLast() Then orden.Init();

                                    // Crear nueva incidencia
                                    r60156.INIT;
                                    r60156."Nº Incidencia" := Sec;
                                    r60156."Nº Recurso" := RecursoNo;
                                    r60156.Descripción := Descripcion;
                                    r60156."Fecha inicio" := FechaReserva;
                                    r60156."Fecha fin" := FechaReserva;
                                    r60156."Vendedor" := CodigoVendedor;
                                    r60156."Nombre Cliente" := NombreCliente;
                                    r60156."Nº Proyecto" := ProyectoAntiguo;
                                    r60156.Validate(Motivo, r60156.Motivo::"Lista de espera");
                                    r60156.Observaciones := 'Importado desde Excel el ' + Format(Today) + ' por ' + UserId;
                                    if Observaciones <> '' then
                                        r60156.Observaciones += ' | ' + Observaciones;
                                    If Evaluate(r60156.Orden, TextoOrden) Then;
                                    r60156.Insert(true);

                                    Sec += 1;
                                end; // Cerrar validación vendedor
                            end; // Cerrar validación recurso
                        end; // Cerrar validación RecursoNo no vacío

                        RowNo += 1;
                    end;

                    Message('Importación completada. Se han procesado %1 registros.', RowNo - 2);
                end;
            }
            action("Ver Lista Espera")
            {
                Image = List;
                ApplicationArea = All;
                Caption = 'Ver Lista Espera';
                RunObject = page "Lista Espera Recursos";
                RunPageLink = "Nº Recurso" = FIELD("No.");
                ToolTip = 'Muestra la lista de espera de recursos';
            }
            action("Generar QR")
            {
                Image = BarCode;
                ApplicationArea = All;
                Caption = 'Generar QR';
                trigger OnAction()
                var
                    Rep: Report "Etiqueta Qr Opis";
                    Resource: Record Resource;

                begin
                    CurrPage.SETSELECTIONFILTER(Resource);
                    Rep.DesdeListadeRecursos(Resource);
                    Commit();
                    Rep.RunModal();
                end;
            }
            // action("Crear Proyecto Lista Espera")
            // {
            //     Image = JobTimeSheet;
            //     ApplicationArea = All;
            //     trigger OnAction()
            //     var
            //         Job: Record Job;
            //         JobsSetup: Record "Jobs Setup";
            //         ResUnit: Record "Resource Unit of Measure";
            //         JobplanningLine: Record "Job Planning Line";
            //         Linea: Integer;
            //     begin
            //         Job.SetRange("Creation Date", CalcDate('PA+1D-1A'), CalcDate('PA'));
            //         Job.SetRange("Proyecto de fijación", false);
            //         Job.SetRange("No Pay", true);
            //         if not Job.FindFirst() then begin
            //             Job.Init();
            //             Job.Description := 'Lista De Espera ' + Format(Date2DMY(Today, 3), 0);
            //             Job."No." := 'LE' + Format(Date2DMY(Today, 3), 0) + '-00001';
            //             Job."Creation Date" := Today;
            //             Job."Proyecto de fijación" := true;
            //             Job.Insert(true);
            //         end;

            //         // Recorrer los recursos y crear las lineas de planificación

            //         if Recurso.FindFirst() Then
            //             repeat
            //                 JobplanningLine.SetRange("Job No.", Job."No.");
            //                 if JobplanningLine.FindLast() Then Linea := JobplanningLine."Line No." + 10000 Else Linea := 10000;
            //                 JobplanningLine.Init();
            //                 JobplanningLine."Job No." := Job."No.";
            //                 JobplanningLine."Line No." := Linea;
            //                 JobplanningLine."Job Task No." := '10';
            //                 JobplanningLine.Type := JobplanningLine.Type::Resource;
            //                 if not ResUnit.Get(Recurso."No.", Recurso."Base Unit of Measure") Then begin
            //                     ResUnit.Init();
            //                     ResUnit."Resource No." := Recurso."No.";
            //                     ResUnit."Code" := Recurso."Base Unit of Measure";
            //                     ResUnit.Insert();
            //                 end;
            //                 JobplanningLine.Validate("No.", Recurso."No.");
            //                 JobplanningLine."Planning Date" := Recurso."Employment Date";
            //                 JobplanningLine."Fecha Final" := Recurso."Last Date Modified";
            //                 JobplanningLine.Validate(Quantity, 1);
            //                 JobplanningLine.Insert();
            //             until Recurso.Next() = 0;
            //         Commit();
            //         CrearReservas(Job."No.");
            //         Commit();
            //         Page.RunModal(Page::"Fijación Proyectos", Job);
            //     end;
            // }
            //}

        }

        addafter("&Resource")
        {
            // action("&Ocupación diaria")
            // {
            //     ApplicationArea = All;
            //     ShortCutKey = F10;
            //     Image = DateRange;
            //     Scope = Repeater;
            //     Caption = '&Ocupación diaria';
            //     trigger OnAction()
            //     BEGIN
            //         CLEAR(Plazos);
            //         Plazos.Coge_Recurso(Rec);
            //         Plazos.RUNMODAL;
            //     END;
            // }

            action(Cuenta)
            {
                ApplicationArea = All;
                Image = Recalculate;
                Caption = 'Cuenta';
                trigger OnAction()
                BEGIN
                    MESSAGE('En la pantalla hay #1##### recursos', Rec.COUNT);
                END;
            }
            action("Tabla para MODIFICAR")
            {
                ApplicationArea = All;
                Image = Edit;
                Caption = 'Tabla para MODIFICAR';
                RunObject = page "Tabla Recursos (2)";//"Tabla Recursos (2)"; 
            }
            action("Asigna Dimension")
            {
                ApplicationArea = All;
                Image = DimensionSets;
                Caption = 'Asigna Dimension';
                trigger OnAction()
                VAR
                    r349: Record 349;
                    r348: Record 348;
                    rRes: Record 156;
                    rDiRe: Record 352;
                BEGIN
                    if Page.RUNMODAL(0, r348) = ACTION::LookupOK THEN BEGIN
                        r349.SETRANGE(r349."Dimension Code", r348.Code);
                        if Page.RUNMODAL(0, r349) = ACTION::LookupOK THEN BEGIN
                            CurrPage.SETSELECTIONFILTER(rRes);
                            if rRes.FINDFIRST THEN
                                REPEAT
                                    if rDiRe.GET(156, rRes."No.", r349."Dimension Code") THEN rDiRe.DELETE;
                                    rDiRe."Table ID" := 156;
                                    rDiRe."No." := rRes."No.";
                                    rDiRe."Dimension Code" := r349."Dimension Code";
                                    rDiRe."Dimension Value Code" := r349.Code;
                                    rDiRe.INSERT;
                                UNTIL rRes.NEXT = 0;
                        END;
                    END;
                END;
            }
            action("Asigna Categoria")
            {
                ApplicationArea = All;
                Image = ApplyEntries;
                Caption = 'Asigna Categoria';
                trigger OnAction()
                VAR
                    rRes: Record 156;
                    Cat: Record 6;
                    Ventana: Dialog;
                BEGIN
                    MESSAGE('Elija categoria');// ########1##');
                    if Page.RUNMODAL(0, Cat) = ACTION::LookupOK THEN BEGIN
                        CurrPage.SETSELECTIONFILTER(rRes);
                        if rRes.FINDSET THEN
                            REPEAT
                                rRes."Customer Price Group" := Cat.Code;
                                rRes.MODIFY;
                            UNTIL rRes.NEXT = 0;
                    END;
                END;
            }
            action("Relación dimensiones")
            {
                ApplicationArea = All;
                Image = MapDimensions;
                Caption = 'Relación dimensiones';
                trigger OnAction()
                VAR
                    fRel: Page "Relación Dimensiones";
                BEGIN
                    CLEAR(fRel);
                    if Emp <> '' THEN
                        fRel.Origen := Emp;
                    fRel.RUNMODAL;
                END;
            }
            action("Ver Ventas Recursos Seleccionados")
            {
                ApplicationArea = All;
                Image = Statistics;
                Caption = 'Ver Ventas Recursos Seleccionados';
                trigger OnAction()
                VAR
                    rres: Record 156;
                    r112t: Record 112 TEMPORARY;
                    r113: Record 113;
                    r112: Record 112;
                    r113t: Record 113 TEMPORARY;
                    r115: Record 115;
                    r114: Record 114;
                    d: Integer;
                BEGIN
                    CurrPage.SETSELECTIONFILTER(rres);
                    r113.SETCURRENTKEY("Document No.", Type, "No.");
                    Ventana.OPEN('#########1# de #########2#');
                    Ventana.UPDATE(2, rres.COUNT);
                    if rres.FINDFIRST THEN
                        REPEAT
                            d := d + 1;
                            Ventana.UPDATE(1, d);
                            r113.SETRANGE(r113.Type, r113.Type::Resource);
                            r113.SETRANGE(r113."No.", rres."No.");
                            if r113.FINDFIRST THEN
                                REPEAT
                                    r113t := r113;
                                    if r113t.INSERT THEN;
                                    if r112.GET(r113."Document No.") THEN BEGIN
                                        r112t := r112;
                                        q112t := r112;
                                        if r112t.INSERT THEN;
                                        if q112t.INSERT THEN;
                                    END;
                                UNTIL r113.NEXT = 0;
                            r115.SETRANGE(r115.Type, r115.Type::Resource);
                            r115.SETRANGE(r115."No.", rres."No.");
                            if r115.FINDFIRST THEN
                                REPEAT
                                    r113t.TRANSFERFIELDS(r115);
                                    r113t.Amount := -r113t.Amount;
                                    r113t."Amount Including VAT" := -r113t."Amount Including VAT";
                                    if r113t.INSERT THEN;
                                    if r114.GET(r115."Document No.") THEN BEGIN
                                        r112t.TRANSFERFIELDS(r114);
                                        q112t.TRANSFERFIELDS(r114);
                                        if r112t.INSERT THEN;
                                        if q112t.INSERT THEN;
                                    END;
                                UNTIL r115.NEXT = 0;
                        UNTIL rres.NEXT = 0;
                    Ventana.CLOSE;
                    if CONFIRM('Ver detalle ?', TRUE) THEN
                        Page.RUNMODAL(Page::"Lista Líneas Factura", r113t)
                    ELSE
                        Page.RUNMODAL(0, r112t);
                END;
            }
            action("Ver Ventas Circuitos")
            {
                ApplicationArea = All;
                Image = StatisticsGroup;
                Caption = 'Ver Ventas Circuitos';
                trigger OnAction()
                VAR
                    rres: Record 156;
                    r112t: Record 112 TEMPORARY;
                    r113: Record 113;
                    r112: Record 112;
                    r113t: Record 113 TEMPORARY;
                    r115: Record 115;
                    r114: Record 114;
                    r1003: Record Reserva;
                    a: Integer;
                    b: Integer;
                    d: Integer;
                    e: Integer;
                BEGIN
                    if NOT q112t.FINDFIRST THEN ERROR('Deje ejecutar primero el puento de ventas de recursos');
                    CurrPage.SETSELECTIONFILTER(rres);
                    Ventana.OPEN('#########1# de #########2#');
                    Ventana.UPDATE(2, rres.COUNT);
                    r1003.SETCURRENTKEY("Nº Recurso", "Fecha inicio", "Fecha fin");
                    if rres.FINDFIRST THEN
                        REPEAT
                            d := d + 1;
                            Ventana.UPDATE(1, d);
                            r1003.SETRANGE(r1003."Nº Recurso", rres."No.");
                            if r1003.FINDFIRST THEN
                                REPEAT
                                    r113.RESET;
                                    r113.SETCURRENTKEY("Document No.", Type, "No.");
                                    r113.SETRANGE(r113.Type, r113.Type::Resource);
                                    r113.SETRANGE("Job No.", r1003."Nº Proyecto");
                                    r113.SETRANGE(r113."No.", r1003."Nº Recurso");
                                    if NOT r113.FINDFIRST THEN BEGIN
                                        r113.RESET;
                                        r113.SETCURRENTKEY("Job No.", "No linea proyecto");
                                        r113.SETRANGE(r113."Job No.", r1003."Nº Proyecto");
                                        if r113.FINDFIRST THEN
                                            REPEAT
                                                a := CuentaLineasFacturaRecurso(r113."Document No.");
                                                b := CuentaLineasProyecto(r1003."Nº Proyecto", r1003."Fecha inicio", r1003."Fecha fin");//-a;
                                                r113t := r113;
                                                r113t."No." := r1003."Nº Recurso";
                                                e := r113t."Line No.";
                                                r113t.Amount := r113t.Amount / b;
                                                r113t."Line Discount %" := b;
                                                if a = 0 THEN a := 1;
                                                r113t."Amount Including VAT" := r113t."Amount Including VAT" / b * a;
                                                if NOT r113t.INSERT THEN
                                                    REPEAT
                                                        e := e + 1;
                                                        r113t."Line No." := e;
                                                    UNTIL r113t.INSERT;
                                                if r112.GET(r113."Document No.") THEN BEGIN
                                                    r112t := r112;
                                                    if r112t.INSERT THEN;
                                                END;
                                            UNTIL r113.NEXT = 0;
                                    END;
                                UNTIL r1003.NEXT = 0;
                        UNTIL rres.NEXT = 0;
                    Ventana.CLOSE;
                    r113t.RESET;
                    if CONFIRM('Ver detalle ?', TRUE) THEN
                        Page.RUNMODAL(Page::"Lista Líneas Factura", r113t)
                    ELSE
                        Page.RUNMODAL(0, r112t);
                END;
            }
            action("Ver Produccion Recursos Seleccionados")
            {
                ApplicationArea = All;
                Image = Statistics;
                Caption = 'Ver Produccion Recursos Seleccionados';
                trigger OnAction()
                VAR
                    rres: Record 156;
                    r112t: Record 112 TEMPORARY;
                    r113: Record 113;
                    r112: Record 112;
                    r113t: Record 113 TEMPORARY;
                    r115: Record 115;
                    r114: Record 114;
                    d: Integer;
                    ProduccionesRelacionadas: Record "Produccines Relacionadas";
                    LinProy: Record "Job Planning Line";
                    ProduccionesRelacionadas2: Record "Produccines Relacionadas";
                    a: Integer;
                    b: Integer;
                BEGIN

                    CurrPage.SETSELECTIONFILTER(rres);
                    r113.SETCURRENTKEY("Document No.", Type, "No.");
                    Ventana.OPEN('#########1# de #########2#');
                    Ventana.UPDATE(2, rres.COUNT);
                    if rres.FINDFIRST THEN
                        REPEAT
                            d := d + 1;
                            Ventana.UPDATE(1, d);
                            LinProy.SETRANGE(LinProy."No.", rres."No.");
                            if LinProy.FINDFIRST THEN
                                REPEAT
                                    ProduccionesRelacionadas.SETRANGE("No.2", rres."No.");
                                    ProduccionesRelacionadas.SETRANGE("Job No.2", LinProy."Job No.");
                                    if ProduccionesRelacionadas.FINDFIRST THEN
                                        REPEAT
                                            ProduccionesRelacionadas2.SETRANGE("Line No.", ProduccionesRelacionadas."Line No.");
                                            ProduccionesRelacionadas2.SETRANGE("Job No.", ProduccionesRelacionadas."Job No.");
                                            a := ProduccionesRelacionadas2.COUNT;
                                            if a = 0 THEN a := 1;
                                            r113.SETRANGE(r113.Type, r113.Type::Resource);
                                            r113.SETRANGE(r113."No linea proyecto", ProduccionesRelacionadas."Line No.");
                                            r113.SETRANGE(r113."Job No.", ProduccionesRelacionadas."Job No.");
                                            if r113.FINDFIRST THEN
                                                REPEAT
                                                    if r113t.GET(r113."Document No.", r113."Line No.") THEN BEGIN
                                                        b := 0;
                                                        r113t := r113;
                                                        r113t."No." := rres."No.";
                                                        r113t.Amount := r113t.Amount / a;
                                                        //     r113t.Description:=STRSUBSTNO('%1- a>%2',Prod2.GETFILTERS,a);
                                                        r113t."Amount Including VAT" := r113t."Amount Including VAT" / a;
                                                        REPEAT
                                                            r113t."Line No." += 1;
                                                        UNTIL r113t.INSERT = TRUE;
                                                    END ELSE BEGIN
                                                        r113t := r113;
                                                        r113t."No." := rres."No.";
                                                        r113t.Amount := r113t.Amount / a;
                                                        //    r113t.Description:=STRSUBSTNO('%1- a>%2',Prod2.GETFILTERS,a);
                                                        r113t."Amount Including VAT" := r113t."Amount Including VAT" / a;

                                                        if NOT r113t.INSERT THEN
                                                            REPEAT
                                                                r113t."Line No." += 1;
                                                            UNTIL r113t.INSERT = TRUE;

                                                    END;
                                                    if r112.GET(r113."Document No.") THEN BEGIN
                                                        r112t := r112;
                                                        q112t := r112;
                                                        if r112t.INSERT THEN;
                                                        if q112t.INSERT THEN;
                                                    END;

                                                UNTIL r113.NEXT = 0;
                                            r115.SETRANGE(r115.Type, r115.Type::Resource);
                                            r115.SETRANGE(r115."No linea proyecto", ProduccionesRelacionadas."Line No.");
                                            r115.SETRANGE(r115."Job No.", ProduccionesRelacionadas."Job No.");
                                            if r115.FINDFIRST THEN
                                                REPEAT
                                                    if r113t.GET(r115."Document No.", r115."Line No.") THEN BEGIN
                                                        b := 0;
                                                        r113t.TRANSFERFIELDS(r115);
                                                        r113t."No." := rres."No.";
                                                        r113t.Amount := -r113t.Amount / a;
                                                        r113t."Amount Including VAT" := -r113t."Amount Including VAT" / a;

                                                        REPEAT
                                                            r113t."Line No." += 1;
                                                        UNTIL r113t.INSERT = TRUE;
                                                    END ELSE BEGIN

                                                        r113t.TRANSFERFIELDS(r115);
                                                        r113t."No." := rres."No.";
                                                        r113t.Amount := -r113t.Amount / a;
                                                        r113t."Amount Including VAT" := -r113t."Amount Including VAT" / a;
                                                        if NOT r113t.INSERT THEN
                                                            REPEAT
                                                                r113t."Line No." += 1;
                                                            UNTIL r113t.INSERT = TRUE;

                                                    END;
                                                    if r114.GET(r115."Document No.") THEN BEGIN
                                                        r112t.TRANSFERFIELDS(r114);
                                                        q112t.TRANSFERFIELDS(r114);
                                                        if r112t.INSERT THEN;
                                                        if q112t.INSERT THEN;
                                                    END;
                                                UNTIL r115.NEXT = 0;
                                        UNTIL ProduccionesRelacionadas.NEXT = 0;
                                UNTIL LinProy.NEXT = 0;
                        UNTIL rres.NEXT = 0;
                    Ventana.CLOSE;
                    if CONFIRM('Ver detalle ?', TRUE) THEN
                        Page.RUNMODAL(Page::"Lista Líneas Factura", r113t)
                    ELSE
                        Page.RUNMODAL(0, r112t);
                END;
            }
            action("Ver Coste Recursos Seleccionados")
            {
                ApplicationArea = All;
                Image = Statistics;
                Caption = 'Ver Coste Recursos Seleccionados';
                trigger OnAction()
                VAR
                    rres: Record 156;
                    r112t: Record 122 TEMPORARY;
                    r113: Record 123;
                    r112: Record "Purch. Inv. Header";
                    r113t: Record 123 TEMPORARY;
                    r115: Record 125;
                    r114: Record "Purch. Cr. Memo Hdr.";
                    d: Integer;
                    ProduccionesRelacionadas: Record "Produccines Relacionadas";
                    LinProy: Record "Job Planning Line";
                    ProduccionesRelacionadas2: Record "Produccines Relacionadas";
                    a: Integer;
                    b: Integer;
                    q112t: Record "Purch. Inv. Header";
                BEGIN
                    CurrPage.SETSELECTIONFILTER(rres);
                    r113.SETCURRENTKEY("Document No.", Type, "No.");
                    Ventana.OPEN('#########1# de #########2#');
                    Ventana.UPDATE(2, rres.COUNT);
                    if rres.FINDFIRST THEN
                        REPEAT
                            d := d + 1;
                            Ventana.UPDATE(1, d);
                            LinProy.SETRANGE(LinProy."No.", rres."No.");
                            if LinProy.FINDFIRST THEN
                                REPEAT
                                    ProduccionesRelacionadas.SETRANGE("No.2", rres."No.");
                                    ProduccionesRelacionadas.SETRANGE("Job No.2", LinProy."Job No.");
                                    if ProduccionesRelacionadas.FINDFIRST THEN
                                        REPEAT
                                            ProduccionesRelacionadas.SETRANGE("Line No.", ProduccionesRelacionadas."Line No.");
                                            ProduccionesRelacionadas2.SETRANGE("Job No.", ProduccionesRelacionadas."Job No.");
                                            a := ProduccionesRelacionadas2.COUNT;
                                            if a = 0 THEN a := 1;
                                            r113.SETRANGE(r113.Type, r113.Type::Resource);
                                            r113.SETRANGE(r113."Linea de proyecto", ProduccionesRelacionadas."Line No.");
                                            r113.SETRANGE(r113."Job No.", ProduccionesRelacionadas."Job No.");
                                            if r113.FINDFIRST THEN
                                                REPEAT
                                                    if r113t.GET(r113."Document No.", r113."Line No.") THEN BEGIN
                                                        b := 0;
                                                        r113t := r113;
                                                        r113t."No." := rres."No.";
                                                        r113t.Amount := r113t.Amount / a;
                                                        //     r113t.Description:=STRSUBSTNO('%1- a>%2',Prod2.GETFILTERS,a);
                                                        r113t."Amount Including VAT" := r113t."Amount Including VAT" / a;
                                                        REPEAT
                                                            r113t."Line No." += 1;
                                                        UNTIL r113t.INSERT = TRUE;
                                                    END ELSE BEGIN
                                                        r113t := r113;
                                                        r113t."No." := rres."No.";
                                                        r113t.Amount := r113t.Amount / a;
                                                        //    r113t.Description:=STRSUBSTNO('%1- a>%2',Prod2.GETFILTERS,a);
                                                        r113t."Amount Including VAT" := r113t."Amount Including VAT" / a;

                                                        if NOT r113t.INSERT THEN
                                                            REPEAT
                                                                r113t."Line No." += 1;
                                                            UNTIL r113t.INSERT = TRUE;

                                                    END;
                                                    if r112.GET(r113."Document No.") THEN BEGIN
                                                        r112t := r112;
                                                        q112t := r112;
                                                        if r112t.INSERT THEN;
                                                        if q112t.INSERT THEN;
                                                    END;

                                                UNTIL r113.NEXT = 0;
                                            r115.SETRANGE(r115.Type, r115.Type::Resource);
                                            //r115.SETRANGE(r115."Linea de proyecto",Prod."Line No.");
                                            r115.SETRANGE(r115."No.", ProduccionesRelacionadas."No.");
                                            r115.SETRANGE(r115."Job No.", ProduccionesRelacionadas."Job No.");
                                            if r115.FINDFIRST THEN
                                                REPEAT
                                                    if r113t.GET(r115."Document No.", r115."Line No.") THEN BEGIN
                                                        b := 0;
                                                        r113t.TRANSFERFIELDS(r115);
                                                        r113t."No." := rres."No.";
                                                        r113t.Amount := -r113t.Amount / a;
                                                        r113t."Amount Including VAT" := -r113t."Amount Including VAT" / a;

                                                        REPEAT
                                                            r113t."Line No." += 1;
                                                        UNTIL r113t.INSERT = TRUE;
                                                    END ELSE BEGIN

                                                        r113t.TRANSFERFIELDS(r115);
                                                        r113t."No." := rres."No.";
                                                        r113t.Amount := -r113t.Amount / a;
                                                        r113t."Amount Including VAT" := -r113t."Amount Including VAT" / a;
                                                        if NOT r113t.INSERT THEN
                                                            REPEAT
                                                                r113t."Line No." += 1;
                                                            UNTIL r113t.INSERT = TRUE;

                                                    END;
                                                    if r114.GET(r115."Document No.") THEN BEGIN
                                                        r112t.TRANSFERFIELDS(r114);
                                                        q112t.TRANSFERFIELDS(r114);
                                                        if r112t.INSERT THEN;
                                                        if q112t.INSERT THEN;
                                                    END;
                                                UNTIL r115.NEXT = 0;
                                        UNTIL ProduccionesRelacionadas.NEXT = 0;
                                UNTIL LinProy.NEXT = 0;
                        UNTIL rres.NEXT = 0;
                    Ventana.CLOSE;
                    if CONFIRM('Ver detalle ?', TRUE) THEN
                        Page.RUNMODAL(PAge::"Lista Líneas Factura C", r113t)
                    ELSE
                        Page.RUNMODAL(0, r112t);
                END;
            }
            action(Eliminar)
            {
                ApplicationArea = All;
                Image = Delete;
                ShortCutKey = F4;
                Caption = 'Eliminar';
                trigger OnAction()
                VAR
                    r60156: Record Resource3;
                BEGIN
                    if CONFIRM('Seguro que desea borrar el recurso?') THEN BEGIN
                        r60156.TRANSFERFIELDS(Rec);
                        Rec.DELETE;
                        r60156.INSERT;
                    END;
                END;
            }
            // { ID=1000000009;
            //                                          CaptionML=ESP=Crear Copia;
            // trigger OnAction()VAR
            //     r50156: Record 50156;
            //     r156: Record 156;
            // BEGIN
            //     if r156.FINDFIRST THEN REPEAT
            //     r50156.TRANSFERFIELDS(r156);
            //     r50156.INSERT;
            //     UNTIL r156.NEXT=0;
            // END;
            //}
            action("Recuperar recurso Borrado")
            {
                ApplicationArea = All;
                ;
                Caption = 'Recuperar recurso Borrado';
                trigger OnAction()
                VAR
                    r60156: Record Resource3;
                    r156: Record 156;
                BEGIN
                    if Page.RUNMODAL(PAge::"Resource List 2", r60156) = ACTION::LookupOK THEN BEGIN
                        r156.TRANSFERFIELDS(r60156);
                        r60156.DELETE;
                        r156.INSERT;
                    END;
                END;
            }
            action("Actualiza Dimensiones")
            {
                ApplicationArea = All;
                Image = DimensionSets;
                Caption = 'Actualiza Dimensiones';
                trigger OnAction()
                VAR
                    rRes: Record 156;
                    rDim: Record 352;
                BEGIN
                    CurrPage.SETSELECTIONFILTER(rRes);
                    if rRes.FINDFIRST THEN
                        REPEAT
                            rRes.Calcfields(Principal, Soporte, "Dimensión Zona");
                            rRes."Global Dimension 3 Code" := rRes.Principal;
                            rRes."Global Dimension 4 Code" := rRes."Dimensión Zona";
                            rRes."Global Dimension 5 Code" := rRes.Soporte;
                            rDim.SETRANGE(rDim."Table ID", 156);
                            rDim.SETRANGE(rDim."No.", rRes."No.");
                            rDim.SETRANGE(rDim."Dimension Code", 'DEPARTAMENTO');
                            if rDim.FINDFIRST THEN
                                rRes."Global Dimension 1 Code" := rDim."Dimension Value Code";
                            rDim.SETRANGE(rDim."Dimension Code", 'PROGRAMA');
                            if rDim.FINDFIRST THEN
                                rRes."Global Dimension 2 Code" := rDim."Dimension Value Code";
                            rRes.MODIFY;
                        UNTIL rRes.NEXT = 0;
                END;
            }
        }
        addafter("Res. Price List")
        {
            action("Informes Recursos")
            {
                Caption = 'Disponibilidad Recursos';
                Image = List;
                ApplicationArea = All;
                trigger OnAction()
                begin
                    Page.RunModal(Page::"Seleccionar Recursos");
                end;

            }
        }
        addafter("Res. Price List_Promoted")
        {
            actionref("Informes Recursos_Promoted"; "Informes Recursos") { }
        }
        addbefore("New Resource Group_Promoted")
        {
            actionref("Crear Recurso_Promoted"; "Crear Recurso") { }
        }
        // addbefore("Create Time Sheets_Promoted")
        // {
        //     actionref(Ocupacion_Diaria_Promoted; "&Ocupación diaria") { }
        // }
        addbefore(Statistics_Promoted)
        {
            actionref(Bloquear_Promoted; "Bloquear este Recurso") { }
            actionref(Bloquear_Recursos_promoted; "Bloquear Recursos") { }

        }
        addafter("Informes Recursos_Promoted")
        {
            actionref(Ver_Ventas_Recursos; "Ver Ventas Recursos Seleccionados") { }
            actionref(Ver_Ventas_Circuitos_Promoted; "Ver Ventas Circuitos") { }
            actionref(Ver_Produccion_Recursos; "Ver Produccion Recursos Seleccionados") { }
            actionref(Ver_Coste_Recursos; "Ver Coste Recursos Seleccionados") { }
        }
    }
    VAR
        // Plazos: Page "Plazos recursos reservados";
        Emp: Text[30];
        rEmp: Record 2000000006;
        a: Integer;
        Ventana: Dialog;
        q112t: Record 112 TEMPORARY;
        Onformat: Text;
        Color: Text;
        Recurso: Record Resource;
        InicioReserva: Date;
        FinReserva: Date;
        Todos: Boolean;

    trigger OnOpenPage()
    begin
        Rec.SetRange(Hoy, Today);
        Rec.CalcFields(Bloqueado);
        Rec.SetRange(Bloqueado, false);
        if Todos Then begin
            Rec.Setrange(Bloqueado);
            Rec.SetRange(Blocked);
        end
    end;

    trigger OnClosePage()
    VAR
        rRes: Record 156;
        rUni: Record 205;
        rSo: Record 413;
        rPro: Record Vendor;
        rRel: Record "Relación Grupos";
        r352: Record 352;
        r3522: Record 352;
        r349: Record 349;
        rRelD: Record "Relación Dimensiones";
        Grupo: Code[20];
        rInf: Record "Company Information";
        Dim2: Record "Default Dimension";
        Dim: Record "Default Dimension";
    BEGIN
        //if CloseAction in [Action::LookupOK, Action::OK] Then begin
        if (Emp <> '') AND (Emp <> COMPANYNAME) THEN BEGIN
            rEmp.GET(Emp);
            rInf.ChangeCompany(Emp);
            if Not rInf.Get() then rInf.Init();
            if NOT rRes.GET(rInf."Clave Recursos" + Rec."No.") THEN BEGIN
                //Creo Recurso
                rRes.TRANSFERFields(Rec);
                rRes."No." := rInf."Clave Recursos" + Rec."No.";
                rRes.INSERT;
            END;
            Dim2.ChangeCompany(rRes."Empresa Origen");
            Dim2.SetRange("Table Id", 156);
            Dim2.SetRange("No.", rRes."Nº En Empresa origen");
            Dim.SetRange("Table Id", 156);
            Dim.SetRange("No.", rRes."No.");
            Dim.DeleteAll();
            if Dim2.FindFirst() Then
                repeat
                    Dim := Dim2;
                    Dim."No." := rRes."No.";
                    Dim.Insert();
                Until Dim2.Next = 0;
            rRes."Global Dimension 1 Code" := Rec."Global Dimension 1 Code";
            //Igual para las 5 dimensiones
            rRes."Global Dimension 2 Code" := Rec."Global Dimension 2 Code";
            rRes."Global Dimension 3 Code" := Rec."Global Dimension 3 Code";
            rRes."Global Dimension 4 Code" := Rec."Global Dimension 4 Code";
            rRes."Global Dimension 5 Code" := ReC."Global Dimension 5 Code";
            rRes.Modify();
            rRes.Name := Rec.Name;
            rUni."Resource No." := rRes."No.";
            rUni.Code := rRes."Base Unit of Measure";
            rUni."Qty. per Unit of Measure" := 1;
            rSo.SETRANGE(rSo."Inbox Details", Emp);
            if rSo.FINDFIRST THEN BEGIN
                rPro.SETRANGE(rPro."IC Partner Code", rSo.Code);
                if rPro.FINDFIRST THEN
                    rRes."Vendor No." := rPro."No.";
            END;
            // Busco Relación
            Grupo := Rec."Gen. Prod. Posting Group";
            rRes."Gen. Prod. Posting Group" := '';
            rRel.SETRANGE(rRel."Empresa Origen", Emp);
            rRel.SETRANGE(rRel."Grupo Contable Origen", Grupo);
            rRel.SETRANGE(rRel."Empresa Destino", COMPANYNAME);
            if rRel.FINDFIRST THEN
                rRes."Gen. Prod. Posting Group" := rRel."Grupo Contable Destino"
            ELSE BEGIN
                // No lo Encuentro, Busco Relación Dimensiones
                r352.SETRANGE(r352."Table ID", 156);
                r352.SETRANGE(r352."No.", Rec."No.");
                r352.CHANGECOMPANY(Emp);
                if r352.FINDFIRST THEN
                    REPEAT
                        if NOT rRelD.GET(Emp, r352."Dimension Code", COMPANYNAME, r352."Dimension Value Code") THEN BEGIN
                            if r352."Dimension Code" IN ['DEPARTAMENTO', 'PROGRAMA'] THEN
                                MESSAGE('No existe una relación entre el %1 valor %2 entre la empresa %3 y la empresa %4',
                                r352."Dimension Code", r352."Dimension Value Code", Emp, COMPANYNAME)
                        END ELSE
                            if r349.GET(r352."Dimension Code", r352."Dimension Value Code") THEN
                                if r349."Gen. Prod. Posting Group" <> '' THEN
                                    rRes."Gen. Prod. Posting Group" := r349."Gen. Prod. Posting Group";
                    UNTIL r352.NEXT = 0;
            END;
            if rRes."Gen. Prod. Posting Group" = '' THEN
                ERROR('No hay una relación Entre el Grupo Contable Origen %1 del la empresa Origen %2' +
                ' con la empresa destino %3', Grupo, Emp, COMPANYNAME);
            //
            if rUni.INSERT THEN;
            rRes."Nº En Empresa origen" := Rec."No.";
            rRes."Empresa Origen" := Emp;
            r352.SETRANGE(r352."Table ID", 156);
            r352.SETRANGE(r352."No.", Rec."No.");
            r352.CHANGECOMPANY(Emp);
            if r352.FINDFIRST THEN
                REPEAT
                    if NOT r3522.GET(r352."Table ID", rRes."No.", r352."Dimension Code") THEN BEGIN
                        r3522 := r352;
                        r3522."No." := rRes."No.";
                        r3522.INSERT;
                    END;
                    if NOT rRelD.GET(Emp, r352."Dimension Code", COMPANYNAME, r352."Dimension Value Code") THEN BEGIN
                        if r352."Dimension Code" IN ['DEPARTAMENTO', 'PROGRAMA'] THEN
                            MESSAGE('No existe una relación entre el %1 valor %2 entre la empresa %3 y la empresa %4',
                            r352."Dimension Code", r352."Dimension Value Code", Emp, COMPANYNAME)
                    END ELSE
                        r3522."Dimension Value Code" := rRelD."Valor Dimensión destino";
                    r3522.MODIFY;
                    if r3522."Dimension Code" = 'DEPARTAMENTO' THEN BEGIN
                        rRes."Global Dimension 1 Code" := r3522."Dimension Value Code";
                    END;
                    if r3522."Dimension Code" = 'PROGRAMA' THEN BEGIN
                        rRes."Global Dimension 2 Code" := r3522."Dimension Value Code";
                    END;
                    if r349.GET(r352."Dimension Code", r352."Dimension Value Code") THEN
                        if r349."Gen. Prod. Posting Group" <> '' THEN
                            rRes."Gen. Prod. Posting Group" := r349."Gen. Prod. Posting Group";
                UNTIL r352.NEXT = 0;
            rRes.RESET;
            r352.SETRANGE(r352."Table ID", 156);
            r352.SETRANGE(r352."No.", Rec."No.");
            r352.CHANGECOMPANY(Emp);
            if r352.FINDFIRST THEN
                REPEAT
                    //if r352."Dimension Code" IN ['DEPARTAMENTO','PROGRAMA'] THEN Begin
                    r3522 := r352;
                    if r3522.INSERT THEN;
                //End;
                UNTIL r352.NEXT = 0;
            rRes.MODIFY;
            Rec.CHANGECOMPANY(COMPANYNAME);

            Rec.GET(rRes."No.");
            Rec.SetRange("No.", rRes."No.");
            //Emp := '';
            //exit(true);
        END;
        // exit(true);
        //END;
    END;
    // OnTimer=BEGIN
    //           if (a=0) AND (COMPANYNAME<>Emp) THEN BEGIN
    //            CurrPage.UPDATE(FALSE);
    //            a:=1;
    //           END;
    //         END;

    trigger OnAfterGetRecord()
    VAR
        r349: Record 352;
        ListaEspera: Record "Incidencias Rescursos";
    BEGIN
        if Rec."Tipo Recurso" = '' THEN Rec."Tipo Recurso" := 'SIN TIPO';
        r349.SETRANGE(r349."Table ID", 156);
        r349.SETRANGE(r349."No.", Rec."No.");
        r349.SETRANGE(r349."Dimension Code", 'ZONA');
        if NOT r349.FINDFIRST THEN Onformat := 'Unfavorable';
        r349.SETRANGE(r349."Table ID", 156);
        r349.SETRANGE(r349."No.", Rec."No.");
        r349.SETRANGE(r349."Dimension Code", 'SOPORTE');
        if NOT r349.FINDFIRST THEN Onformat := 'Attention';
        r349.SETRANGE(r349."Table ID", 156);
        r349.SETRANGE(r349."No.", Rec."No.");
        r349.SETRANGE(r349."Dimension Code", 'PRINCIPAL');
        if NOT r349.FINDFIRST THEN OnFormat := 'Anbiguos';
        //cambia el color en funcion de si es un recurso agrupado o, de producción
        Color := 'Standard';
        if Rec."Producción" THEN Color := 'Favorable';
        if Rec."Recurso Agrupado" then Color := 'Unfavorable';
        ListaEspera.SetRange("Nº Recurso", Rec."No.");
        ListaEspera.SetRange(Motivo, ListaEspera.Motivo::"Lista de espera");
        if ListaEspera.FindSet then Color := 'StandardAccent';

    End;

    procedure SetTodos(pTodos: Boolean)
    begin
        Todos := pTodos;
    end;

    PROCEDURE CambiaEmpresa(Em: Text[30]);
    VAR
        rRes: Record 156;
    BEGIN
        Rec.CHANGECOMPANY(Em);
        a := 0;
        CurrPage.Update(false);
    END;

    PROCEDURE DZona(): Text[50];
    VAR
        rDim: Record 352;
        rVal: Record 349;
    BEGIN
        rDim.SETRANGE(rDim."Table ID", 156);
        rDim.SETRANGE(rDim."No.", Rec."No.");
        rDim.SETRANGE(rDim."Dimension Code", 'ZONA');
        if rDim.FINDFIRST THEN BEGIN
            if rVal.GET('ZONA', rDim."Dimension Value Code") THEN EXIT(rVal.Name);
        END;
    END;

    PROCEDURE CuentaLineasProyecto(JobNo: Code[20]; FechaI: Date; FechaF: Date): Integer;
    VAR
        p1003: Record Reserva;
    BEGIN
        p1003.SETCURRENTKEY("Nº Proyecto", "Nº Recurso", "Fecha inicio");
        p1003.SETRANGE(p1003."Nº Proyecto", JobNo);
        //p1003.SETRANGE(p1003."Fecha inicio",FechaI);
        //p1003.SETRANGE(p1003."Fecha fin",FechaF);
        EXIT(p1003.COUNT);
    END;

    PROCEDURE CuentaLineasFactura(DocumentNo: Code[20]; FechaI: Date; FechaF: Date): Integer;
    VAR
        p113: Record 113;
    BEGIN
        p113.SETRANGE(p113."Document No.", DocumentNo);
        //p113.SETRANGE(p113."Fecha inicial recurso",FechaI);
        //p113.SETRANGE(p113."Fecha final recurso",FechaF);
        p113.SETFILTER(Amount, '<>%1', 0);
        EXIT(p113.COUNT);
    END;

    PROCEDURE LineaProyecto(JobNo: Code[20]; ResNo: Code[20]; FechaI: Date; FechaF: Date): Integer;
    VAR
        p1003: Record Reserva;
        c: Integer;
    BEGIN
        p1003.SETCURRENTKEY("Nº Proyecto", "Nº Recurso", "Fecha inicio");
        p1003.SETRANGE(p1003."Nº Proyecto", JobNo);
        p1003.SETRANGE(p1003."Fecha inicio", FechaI);
        //p1003.SETRANGE(p1003."Fecha fin",FechaF);
        c := 1;
        if p1003.FINDFIRST THEN
            REPEAT
                if p1003."Nº Recurso" = ResNo THEN EXIT(c * 1000000 + p1003."Nº Reserva");
                c := c + 1;
            UNTIL p1003.NEXT = 0;
        EXIT(c * 1000000)
    END;

    PROCEDURE CuentaLineasFacturaRecurso(DocumentNo: Code[20]): Integer;
    VAR
        p113: Record 113;
    BEGIN
        p113.SETRANGE(p113."Document No.", DocumentNo);
        p113.SETRANGE(Type, p113.Type::Resource);
        //p113.SETRANGE(p113."Fecha final recurso",FechaF);
        EXIT(0);
        EXIT(p113.COUNT);
    END;

    PROCEDURE Precio(): Decimal;
    VAR
        FromSalesPrice: Record "Price List Line";// "Sales Price";
        TempTargetCampaignGr: Record "Campaign Target Group";
        StartingDate: date;
    BEGIN

        if StartingDate = 0D THEN StartingDate := WORKDATE;
        FromSalesPrice.SETFILTER("Ending Date", '%1|>=%2', 0D, StartingDate);
        FromSalesPrice.SETRANGE("Starting Date", 0D, StartingDate);
        FromSalesPrice.SETRANGE("Source Type", FromSalesPrice."Source Type"::"Customer Price Group");
        FromSalesPrice.SETRANGE("Source No.", Rec."Customer Price Group");
        if FromSalesPrice.FINDLAST THEN EXIT(FromSalesPrice."Unit Price");

    END;

    local procedure CrearReservas(No: Code[20]; LineaAgrupado: Integer)
    VAR
        rLinpd: Record 1003;
        rLinp: Record 1003;
        rLin2: Record 1003;
        Recurso: Code[20];
        linea: Integer;
        Job: Record Job;
        GestRes: Codeunit "Gestion Reservas";
        Total: Integer;
        Acrear: Integer;
    BEGIN
        Job.Get(No);
        rLinP.SETRANGE("Job No.", "No");
        if rLinP.FIND('-') THEN
            REPEAT

                rLinpd.SETRANGE(rLinpd."Job No.", rLinP."Job No.");
                rLinpd.SETRANGE(rLinpd."Origin Line No.", rLinP."Line No.");
                if rLinpd.FIND('-') THEN
                    REPEAT
                        if (rLinpd."Cdad. a Reservar" <> 0) THEN BEGIN
                            Acrear += rLinpd."Cdad. a Reservar";
                            Total += GestRes."Crear Reserva"(rLinpd, '', linea, true, LineaAgrupado);
                        END;
                    UNTIL rLinpd.NEXT = 0;
            UNTIL rLinP.NEXT = 0;

        rLin2.INIT;
        rLin2.SETRANGE("Job No.", "No");
        rLin2.CALCSUMS("Cdad. a Reservar", "Cdad. Reservada");
        MESSAGE('Creadas #1######## reservas de un total de #2########\' +
                'para todo el proyecto.',
                Total, Acrear);
    END;

}