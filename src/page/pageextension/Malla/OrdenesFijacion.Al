pageextension 75009 OrdenesFijacion extends "Ficha Orden Fijacion"
{
    actions
    {
        addafter("Asignar Imagen Valla fijada a Lineas")
        {
            action("Imprimir")
            {
                Image = Print;
                ApplicationArea = All;
                Caption = 'Imprimir';
                trigger OnAction()
                var
                    Opcion: Integer;
                    rDet: Record "Orden fijación";
                    Resource: Record "Resource";
                    Imagenes: Record "Imagenes Orden fijación";
                    im: Record "Imagenes Orden fijación";
                    TipoOrden: Label 'Vallas,Opis,Otros';
                    Rep: Report "Etiqueta orden fijacion Opis";
                    Rep2: Report "Etiqueta fijacion soportes";
                    Cab: Record "Cab Orden fijación";
                    Job: Record Job;
                    Observaciones: Text;
                begin
                    Opcion := 0;
                    if Rec."Tipo soporte" = Rec."Tipo soporte"::Valla then Opcion := 1;
                    if Rec."Tipo soporte" = Rec."Tipo soporte"::OPI then Opcion := 2;
                    if Rec."Tipo soporte" = Rec."Tipo soporte"::Otros then Opcion := 3;
                    rDet.SETRANGE("Nº Orden", Rec."Nº Orden");
                    If (rDet.FindFirst()) and (Opcion = 0) then begin
                        If rDet."Empresa" <> '' then
                            Resource.ChangeCompany(rDet."Empresa")
                        else
                            Resource.ChangeCompany('');
                        Resource.Get(rDet."Nº Recurso");
                        Opcion := 0;
                        If Resource."Tipo Recurso" in ['VALLA', 'VALLAS', 'P.PEATOAL'] then
                            Opcion := 1;
                        if Resource."Tipo Recurso" in ['OPI', 'OPIS', 'LUM1,5X1,1', 'OPI ROT.', 'PLANIMETRO', 'RELOJ'] then
                            Opcion := 2;
                        if Resource."Tipo Recurso" in ['INDICADOR', 'VPEATON', 'MEDIANERA'] then
                            Opcion := 3;
                    end;
                    if Opcion = 0 then
                        Opcion := StrMenu(TipoOrden, Opcion, 'Seleccione el tipo de tarea a crear');
                    if Opcion = 1 Then begin
                        Cab.SETRANGE("Nº Orden", Rec."Nº Orden");
                        Report.RunModal(Report::"Etiqueta orden fijacion Vallas", true, true, Cab);
                    end;
                    if Opcion = 2 Then begin
                        commit;
                        Imagenes.SETRANGE("Nº Orden", Rec."Nº Orden");
                        Imagenes.SetRange("Es Qr", false);
                        Imagenes.SetRange("Es Incidencia", false);
                        Imagenes.SetRange("Valla Fijada", False);
                        If Imagenes.FINDSET THEN
                            repeat
                                im.SetRange("Nº Orden", Imagenes."Nº Orden");
                                im.SetRange("Nº Imagen", Imagenes."Nº Imagen");
                                im.SetRange("Valla Fijada", false);
                                If im.FindFirst() Then;
                                clear(rep);
                                Rep.Filtra(Imagenes."Nº Orden", Imagenes."Nº Imagen");
                                rep.SetTableView(im);
                                Rep.RUNMODAL();
                            until Imagenes.NEXT = 0
                        else begin
                            Imagenes.Init();
                            Imagenes."Nº Orden" := Rec."Nº Orden";
                            Imagenes."Nº Imagen" := 0;
                            If Imagenes.Insert() Then;
                            Commit();
                            Imagenes.SETRANGE("Nº Orden", Rec."Nº Orden");
                            Imagenes.SETRANGE("Nº Imagen", 0);
                            Imagenes.SetRange("Valla Fijada", false);
                            Rep.Filtra(Imagenes."Nº Orden", Imagenes."Nº Imagen");
                            rep.SetTableView(Imagenes);
                            Rep.RUNMODAL();
                            Imagenes.Delete();
                        end;
                    end;
                    if Opcion = 3 Then begin
                        Cab.SETRANGE("Nº Orden", Rec."Nº Orden");
                        Job.GET(Rec."Nº Proyecto");
                        rDet.SETRANGE("Nº Orden", Rec."Nº Orden");
                        rDet.FindFirst();
                        If rDet."Empresa" <> '' then
                            Resource.ChangeCompany(rDet."Empresa")
                        else
                            Resource.ChangeCompany('');
                        Resource.GET(rDet."Nº Recurso");
                        Observaciones := Rec.GetWorkDescription();
                        Rep2.CargaObservaciones(Observaciones, Resource.Medidas + ' ' + Rec."Título");
                        Rep2.SetTableView(Cab);
                        Rep2.RUNMODAL();
                    end;

                end;

            }
            action("Imprimir Etiqueta Qr")
            {
                Image = Print;
                ApplicationArea = All;
                Caption = 'Imprimir Etiqueta Qr';
                trigger OnAction()
                var
                    rDet: Record "Orden fijación";
                    Resource: Record "Resource";
                    Imagenes: Record "Imagenes Orden fijación";
                    Rep: Report "Etiqueta Qr Opis";

                begin

                    Imagenes.SETRANGE("Nº Orden", Rec."Nº Orden");
                    Imagenes.SetRange("Es Qr", true);
                    Imagenes.SetRange("Es Incidencia", false);
                    If Imagenes.FINDSET THEN
                        //    repeat
                        clear(rep);
                    Rep.Filtra(Imagenes."Nº Orden");
                    rep.SetTableView(Imagenes);
                    Rep.RUNMODAL();
                    //   until Imagenes.NEXT = 0

                end;

            }
            action("Retirada Publicidad")
            {
                Image = Print;
                ApplicationArea = All;
                Caption = 'Retirada Publicidad';
                trigger OnAction()
                var
                    Opcion: Integer;
                    rDet: Record "Orden fijación";
                    Resource: Record "Resource";
                    Imagenes: Record "Imagenes Orden fijación";
                    im: Record "Imagenes Orden fijación";
                    TipoOrden: Label 'Vallas,Opis,Otros';
                    Rep2: Report "Retirada fijacion soportes";
                    Cab: Record "Cab Orden fijación";
                    Job: Record Job;

                begin
                    Opcion := 0;
                    if Rec."Tipo soporte" = Rec."Tipo soporte"::Valla then Opcion := 1;
                    if Rec."Tipo soporte" = Rec."Tipo soporte"::OPI then Opcion := 2;
                    if Rec."Tipo soporte" = Rec."Tipo soporte"::Otros then Opcion := 3;
                    rDet.SETRANGE("Nº Orden", Rec."Nº Orden");
                    rDet.SetRange(Retirar, TRUE);

                    Cab.SETRANGE("Nº Orden", Rec."Nº Orden");
                    Job.GET(Rec."Nº Proyecto");
                    rDet.SETRANGE("Nº Orden", Rec."Nº Orden");
                    rDet.FindFirst();
                    If rDet."Empresa" <> '' then
                        Resource.ChangeCompany(rDet."Empresa")
                    else
                        Resource.ChangeCompany('');
                    Resource.GET(rDet."Nº Recurso");
                    Rep2.CargaObservaciones(Job.Description, Resource.Medidas);
                    Rep2.SetTableView(Cab);
                    Rep2.RUNMODAL();

                    rDet.SetRange(Retirar, TRUE);
                    rDet.ModifyAll(Retirada, true);
                    rDet.ModifyAll(Retirar, false);
                end;

            }
            action("Añadir Otro proyecto")
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
                    Job: Record Job;
                    MismoProyecto: Boolean;
                    DetalleOrdenesFijacion: Record "Orden fijación";
                begin
                    If Page.Runmodal(0, Job) in [Action::LookupOK, Action::OK] Then Begin
                        Reserva.SETRANGE("Nº Proyecto", Job."No.");
                        Reserva.ModifyAll(Seleccionar, false);
                        Commit;
                        SeleccionarReservas.SetTableView(Reserva);
                        SeleccionarReservas.Seleccionable('');
                        SeleccionarReservas.RUNMODAL;
                        Commit();
                        Reserva.SetRange("Seleccionar", true);
                        If Not Reserva.FindFirst() Then begin
                            SeleccionarReservas.SetSelectionFilter(Reserva);
                            If Reserva.Count = 1 Then
                                ERROR('No hay reservas seleccionadas');
                            Reserva.ModifyAll(Seleccionar, true);
                        end;
                        Reserva.FindFirst();
                        FechaI := Reserva."Fecha inicio";
                        FechaF := Reserva."Fecha fin";
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
                                Reserva.ModifyAll(Refijar, true);
                                Reserva.SetRange(Estado);
                            end else
                                ERROR('No se pueden fijar reservas ocupadas');
                        Clear(CrearOrdenFijacion);
                        Commit();
                        CrearOrdenFijacion.SetTableView(Reserva);
                        CrearOrdenFijacion.parametros(FechaI, FechaF, Job."No.", '', Rec."Nº Orden", MismoProyecto);
                        CrearOrdenFijacion.RUNMODAL;
                        Commit();
                        CurrPage.UPDATE(false);
                    end;
                end;
            }
            action("Añadir Otra Empresa")
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
                    Job: Record Job;
                    JobTemp: Record Job temporary;
                    Empresa: Record Company;
                    DetalleOrdenesFijacion: Record "Orden fijación";
                begin
                    If Page.Runmodal(Page::"Companies", Empresa) in [Action::LookupOK, Action::OK] Then Begin
                        Reserva.ChangeCompany(Empresa.Name);
                        Reserva.SetRange("Fecha fin", Today, 99991231D);
                        Job.ChangeCompany(Empresa.Name);
                        If Reserva.FindSet() Then
                            Repeat
                                If Not JobTemp.Get(Reserva."Nº Proyecto") Then begin
                                    If Job.GET(Reserva."Nº Proyecto") then begin
                                        JobTemp.TransferFields(Job);
                                        JobTemp.Insert();
                                    end;
                                end;
                            Until Reserva.Next() = 0;

                        Reserva.ChangeCompany(Empresa.Name);
                        If Page.Runmodal(0, JobTemp) in [Action::LookupOK, Action::OK] Then Begin
                            Reserva.SetRange("Fecha fin");
                            Reserva.SETRANGE("Nº Proyecto", JobTemp."No.");
                            Reserva.ModifyAll(Seleccionar, false);
                            Commit;
                            SeleccionarReservas.SetTableView(Reserva);
                            SeleccionarReservas.Seleccionable(Empresa.Name);
                            SeleccionarReservas.RUNMODAL;
                            Commit();
                            Reserva.SetRange("Seleccionar", true);
                            If Not Reserva.FindFirst() Then begin
                                SeleccionarReservas.SetSelectionFilter(Reserva);
                                If Reserva.Count = 1 Then
                                    ERROR('No hay reservas seleccionadas');
                                Reserva.ModifyAll(Seleccionar, true);
                            end;
                            Reserva.FindFirst();
                            FechaI := Reserva."Fecha inicio";
                            FechaF := Reserva."Fecha fin";
                            If (Reserva.Estado = Reserva.Estado::Ocupado) Or (Reserva.Estado = Reserva.Estado::"Ocupado fijo") Then
                                If Confirm('Estas Reservas ya están en una orden de fijacion, Quiere Crear Una Nueva?') Then Begin
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
                                    Reserva.ModifyAll(Refijar, true);
                                    Reserva.SetRange(Estado);
                                end else
                                    ERROR('No se pueden fijar reservas ocupadas');
                            Clear(CrearOrdenFijacion);
                            Commit();
                            CrearOrdenFijacion.SetTableView(Reserva);
                            CrearOrdenFijacion.parametrosxEmpresa(FechaI, FechaF, Job."No.", '', Rec."Nº Orden", Empresa.Name);
                            CrearOrdenFijacion.RUNMODAL;
                            Commit();
                            CurrPage.UPDATE(false);
                        end;
                    end;
                end;
            }


        }

    }
}