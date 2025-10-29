pageextension 75006 JobLinesSub extends "JobLinesSub"
{
    layout
    {
        modify("No.")
        {
            trigger OnAssistEdit()
            var
                rJobPl: Record "Job Planning Line";
                fJobl: Page "MLL-Presupuesto proyecto compr";
                rRes: Record "Resource";
                rCost: Record "Price List Line";
                Linea: Integer;
            begin

                if Rec."Origin Line No." <> 0 THEN EXIT;
                rJobPl.SETRANGE(rJobPl."Job No.", Rec."Job No.");
                if rJobPl.FINDLAST THEN Linea := rJobPl."Line No." + 10000 ELSE EXIT;
                rJobPl.SETRANGE(rJobPl."Origin Line No.", Rec."Line No.");
                rJobPl.SETRANGE(rJobPl."Job Task No.", Rec."Job Task No.");
                rJobPl.SETRANGE(rJobPl."Crear pedidos", rJobPl."Crear pedidos"::"De Compra");
                if (NOT rJobPl.FINDFIRST) AND (Rec.Type IN [Rec.Type::Resource, Rec.Type::Familia]) THEN BEGIN
                    CASE Rec.Type OF
                        Rec.Type::Resource:
                            BEGIN
                                rCost.SETRANGE(rCost."Asset Type", rCost."Asset Type"::Resource);
                                rCost.SETRANGE(rCost."Asset No.", Rec."No.");
                                rRes.GET(Rec."No.");
                                if (NOT rCost.FINDFIRST) AND (rRes."Resource Group No." <> '') THEN BEGIN
                                    rCost.SETRANGE(rCost."Asset Type", rCost."Asset Type"::"Resource Group");
                                    rCost.SETRANGE(rCost."Asset No.", rRes."Resource Group No.");
                                END;
                            END;
                        Rec.Type::Familia:
                            BEGIN
                                rCost.SETRANGE(rCost."Asset Type", rCost."Asset Type"::"Resource Group");
                                rCost.SETRANGE(rCost."Asset No.", Rec."No.");
                            END;
                    END;
                    if rCost.FINDFIRST THEN
                        REPEAT
                            rJobPl := Rec;
                            rJobPl."Line No." := Linea;
                            Linea := Linea + 10000;
                            CASE rCost."Dest. Type" OF
                                rCost."Dest. Type"::Resource:
                                    rJobPl.Type := rJobPl.Type::Resource;
                                rCost."Dest. Type"::"Group(Resource)":
                                    rJobPl.Type := rJobPl.Type::Familia;
                            END;
                            rJobPl."Cdad. a Reservar" := 0;
                            rJobPl.VALIDATE("No.", rCost."Dest. Code");
                            if rCost."Amount Type" = rCost."Amount Type"::"% Extra" THEN
                                rJobPl.VALIDATE(rJobPl."Unit Cost", Rec."Unit Cost" * rCost."Direct Unit Cost" / 100)
                            ELSE
                                rJobPl.VALIDATE(rJobPl."Unit Cost", rCost."Direct Unit Cost");
                            rJobPl."Crear pedidos" := Rec."Crear pedidos"::"De Compra";
                            rJobPl."Origin Line No." := Rec."Line No.";
                            rJobPl.VALIDATE(rJobPl."Compra a-Nº proveedor", rCost."Source No.");
                            rJobPl."Cdad. Reservada" := 0;
                            rJobPl.INSERT;
                        UNTIL rCost.NEXT = 0;
                END;
                COMMIT;
                CLEAR(fJobl);
                fJobl.FiltroCompra(Rec."Line No.");
                fJobl.SETTABLEVIEW(rJobPl);
                fJobl.RUNMODAL;
                COMMIT;
                Rec."Crear pedidos" := Rec."Crear pedidos"::"De Venta";
                // if ISCLEAR(ws) THEN
                // CREATE(ws);
                // ws.SendKeys('% ');
                // ws.SendKeys('{RIGHT}');
                // ws.SendKeys('x');
            end;


        }
    }
    actions
    {
        addafter("JobPlanningLines")
        {
            action("Asignar produccion a seleccionadas")
            {
                ApplicationArea = All;
                Caption = 'Asignar produccion a seleccionadas';
                Image = AssessFinanceCharges;
                Scope = Repeater;

                trigger OnAction()
                var
                    JobPlanningLine: Record "Job Planning Line";
                    Tipo: Code[20];
                    Res: Record Resource;
                    rProd: Record "Recursos de Producción";
                begin
                    CurrPage.SetSelectionFilter(JobPlanningLine);
                    JobPlanningLine.SetRange(Type, JobPlanningLine.Type::Resource);
                    JobPlanningLine.Modifyall(Cartel, false);
                    JobPlanningLine.Modifyall(Lona, false);
                    JobPlanningLine.Modifyall(Vinilo, false);
                    JobPlanningLine.Modifyall(Otros, false);
                    JobPlanningLine.ModifyAll("Sin Producción", false);
                    JobPlanningLine.ModifyAll("Solo Producción", false);
                    If JobPlanningLine.FindSet() Then
                        Repeat
                            Res.GET(JobPlanningLine."No.");
                            If Res."Producción" then Error('La linea no puede ser de producción');
                            If (Tipo <> '') And (Tipo <> Res."Tipo Recurso") Then Error('No se pueden mezclar tipos de recursos');
                        Until JobPlanningLine.Next = 0;
                    rProd.SetRange("Tipo de Soporte", Res."Tipo Recurso");
                    If Page.RunModal(0, rProd) = Action::LookupOK then begin
                        case rProd.Material of
                            'Cartel':
                                JobPlanningLine.Modifyall(Cartel, true);
                            'Lona':
                                JobPlanningLine.Modifyall(Lona, true);
                            'Vinilo':
                                JobPlanningLine.Modifyall(Vinilo, true);
                            else
                                JobPlanningLine.Modifyall(Otros, true);

                        end;
                        commit;
                        Rec.CrearLineaProduccion(rProd.Material, True, JobPlanningLine);
                    end;

                end;
            }
        }
    }

    PROCEDURE CreaReservas();
    VAR
        rLinpd: Record 1003;
        RecursoAgrupado: Code[20];
        ResourceAgr: Record Resource;
        Resource: Record Resource;
        linea: Integer;
        Job: Record Job;
        Total: Integer;
        ACrear: Integer;
        Reservas: Record Reserva;
        LineasRecursoAgrupado: Record "Job Planning Line";
        LineaAgrupado: Integer;
        i: Integer;
        GestRes: Codeunit "Gestion Reservas";
    BEGIN
        if NOT CONFIRM('Crear Reservas?') THEN EXIT;
        Job.Get(Rec."Job No.");
        If Not Resource.Get(Rec."No.") then Resource.Init();
        LineasRecursoAgrupado.SetRange("Job No.", Rec."Job No.");
        If LineasRecursoAgrupado.FindSet() then
            repeat
                If Resource.Get(LineasRecursoAgrupado."No.") then begin
                    If Resource."Recurso Agrupado" then begin
                        If LineasRecursoAgrupado."Recurso Agrupado" = false then begin
                            LineaAgrupado := LineasRecursoAgrupado."Line No.";
                            LineasRecursoAgrupado."Recurso Agrupado" := true;
                            LineasRecursoAgrupado.Modify();
                        end;
                    end;
                end;
            Until LineasRecursoAgrupado.Next() = 0;
        Commit();
        LineasRecursoAgrupado.SetRange("Recurso Agrupado", true);

        if LineasRecursoAgrupado.FindSet() then
            repeat
                If ResourceAgr.Get(LineasRecursoAgrupado."No.") then
                    If ResourceAgr."Tipo Recurso" = Resource."Tipo Recurso" then begin
                        RecursoAgrupado := LineasRecursoAgrupado."No.";
                        LineaAgrupado := LineasRecursoAgrupado."Line No.";
                        i += 1;
                    end;

            until LineasRecursoAgrupado.Next() = 0;
        if i > 1 then RecursoAgrupado := '';
        if i > 1 then LineaAgrupado := 0;
        ComprobarRegursosAgrupados(RecursoAgrupado, linea, Rec."Job No.");
        COMMIT;
        CurrPage.SETSELECTIONFILTER(rLinP);
        rLinP.SetFilter("Cdad. a Reservar", '<>%1', 0);
        if not rLinP.FindSet() then
            ERROR('No hay nada que reservar');
        rLinP.SetRange("Cdad. a Reservar");
        if rLinP.FindSet() THEN
            REPEAT
                if (RecursoAgrupado <> '') AND (rLinP."Unit Price (LCY)" <> 0) THEN
                    if Job."Proyecto Mixto" = False Then
                        ERROR('No se pueden crear circuitos con Recursos con precio a no ser que se trate de un proyecto mixto');
                if (rLinP."Cdad. a Reservar" <> 0) THEN BEGIN
                    GestRes."Crear Reserva"(rLinP, RecursoAgrupado, linea, true, LineaAgrupado);
                END;
                rLinpd.SETRANGE(rLinpd."Job No.", rLinP."Job No.");
                rLinpd.SETRANGE(rLinpd."Origin Line No.", rLinP."Line No.");
                if rLinpd.FIND('-') THEN
                    REPEAT
                        if (rLinpd."Cdad. a Reservar" <> 0) THEN BEGIN
                            GestRes."Crear Reserva"(rLinpd, RecursoAgrupado, linea, true, LineaAgrupado);
                        END;
                    UNTIL rLinpd.NEXT = 0;
            UNTIL rLinP.NEXT = 0;
        // rLin2.INIT;
        // rLin2.SETRANGE("Job No.", Rec."Job No.");

        // rLin2.CALCSUMS("Cdad. a Reservar", "Cdad. Reservada");
        ACrear := 0;
        Total := 0;
        if ACrear = 0 then begin
            rLin2.Reset();
            rLin2.SETRANGE("Job No.", Rec."Job No.");
            if rLin2.findfirst() then
                repeat
                    ACrear += rLin2."Cdad. a Reservar" + rLin2."Cdad. Reservada";
                    Total += rLin2."Cdad. Reservada";
                until rLin2.next() = 0;

        end;
        if rec.Type = Rec.Type::Familia Then begin
            Reservas.SetRange("Nº Proyecto", Rec."Job No.");
            Total := Reservas.Count;
        end;

        MESSAGE('Creadas #1######## reservas de un total de #2########\' +
                'para todo el proyecto.',
                Total, ACrear);
    END;

    PROCEDURE CreaReservasFijacion(LineaAgrupado: Integer);
    VAR
        rLinpd: Record 1003;
        Recurso: Code[20];
        linea: Integer;
        Job: Record Job;
        Total: Integer;
        ACrear: Integer;
    BEGIN
        if NOT CONFIRM('Crear Reservas?') THEN EXIT;

        COMMIT;
        Job.Get(Rec."Job No.");

        rLinP.SETRANGE("Job No.", Rec."Job No.");
        rLinP.SetFilter("Cdad. a Reservar", '<>%1', 0);
        if not rLinP.FindSet() then
            ERROR('No hay nada que reservar');
        rLinP.SetRange("Cdad. a Reservar");
        if rLinP.FIND('-') THEN
            REPEAT

                rLinpd.SETRANGE(rLinpd."Job No.", rLinP."Job No.");
                rLinpd.SETRANGE(rLinpd."Origin Line No.", rLinP."Line No.");
                if rLinpd.FIND('-') THEN
                    REPEAT
                        if (rLinpd."Cdad. a Reservar" <> 0) THEN BEGIN
                            GestRes."Crear Reserva"(rLinpd, '', linea, true, LineaAgrupado);
                        END;
                    UNTIL rLinpd.NEXT = 0;
            UNTIL rLinP.NEXT = 0;

        ACrear := 0;
        Total := 0;
        if ACrear = 0 then begin
            rLin2.Reset();
            rLin2.SETRANGE("Job No.", Rec."Job No.");
            if rLin2.findfirst() then
                repeat
                    ACrear += rLin2."Cdad. Reservada";
                    Total += rLin2."Cdad. Reservada" + rLin2."Cdad. a Reservar";
                until rLin2.next() = 0;
            Total := ACrear;
        end;

        MESSAGE('Creadas #1######## reservas de un total de #2########\' +
                'para todo el proyecto.',
                Total, ACrear);
    END;

    PROCEDURE OrdenesPubli();
    VAR
        rOrden: Record "Cab. orden publicidad";
        rProyecto: Record 167;
        rProv: Record Vendor;
        rLinCont: Record 37;
    BEGIN
        // $002
        Rec.TESTFIELD("Compra a-Nº proveedor");
        rProv.GET(Rec."Compra a-Nº proveedor");
        rOrden.RESET;
        rOrden.SETCURRENTKEY("Nº proyecto", "Nº tarea proyecto", "Nº linea");
        rOrden.SETRANGE("Tipo orden", rProv.Medio.AsInteger());
        rOrden.SETRANGE("Nº proyecto", Rec."Job No.");
        rOrden.SETRANGE("Nº tarea proyecto", Rec."Job Task No.");
        rOrden.SETRANGE("Nº linea", Rec."Line No.");
        if NOT rOrden.FINDSET THEN BEGIN
            CLEAR(rOrden);
            case rProv.Medio of
                rProv.Medio::Audiovisuales:
                    rOrden."Tipo orden" := rOrden."Tipo orden"::Audiovisuales;
                rProv.Medio::Prensa:
                    rOrden."Tipo orden" := rOrden."Tipo orden"::Prensa;
                rProv.Medio::Radio:
                    rOrden."Tipo orden" := rOrden."Tipo orden"::Radio;
                rProv.Medio::Otros:
                    rOrden."Tipo orden" := rOrden."Tipo orden"::Otros;
            end;
            rOrden."Nº proyecto" := Rec."Job No.";
            rOrden."Nº tarea proyecto" := Rec."Job Task No.";
            rOrden."Nº linea" := Rec."Line No.";
            rOrden.INSERT(TRUE);
            if rProyecto.GET(Rec."Job No.") THEN BEGIN
                rProyecto.TESTFIELD("Bill-to Customer No.");
                rOrden.VALIDATE("No cliente", rProyecto."Bill-to Customer No.");
                rOrden.VALIDATE("Cod vendedor", rProyecto."Cód. vendedor");
                rOrden.VALIDATE(Descripcion, rProyecto.Description);
            END;
            Rec.TESTFIELD("Compra a-Nº proveedor");
            rOrden.VALIDATE("Cod. Soporte", Rec."Compra a-Nº proveedor");
            Rec.TESTFIELD(Type, Rec.Type::Resource);
            Rec.TESTFIELD("No.");
            rOrden.VALIDATE(Concepto, Rec."No.");
            rOrden.MODIFY(TRUE);
            rOrden.ActualizarLineas(TRUE);
            COMMIT;
        END;

        //$006(I)
        if rProyecto.GET(Rec."Job No.") THEN BEGIN
            if rProyecto.Status = rProyecto.Status::Open THEN BEGIN
                rLinCont.RESET;
                rLinCont.SETCURRENTKEY("Document Type", "Document No.", "Job No.", "Job Task No.");
                rLinCont.SETRANGE("Document Type", rLinCont."Document Type"::Order);
                rLinCont.SETRANGE("Job No.", Rec."Job No.");
                rLinCont.SETRANGE("Job Task No.", Rec."Job Task No.");
                rLinCont.SETRANGE("No linea proyecto", Rec."Line No.");
                if rLinCont.FINDFIRST THEN BEGIN
                    if rLinCont."No. Orden Publicidad" = '' THEN BEGIN
                        rLinCont.VALIDATE("No. Orden Publicidad", rOrden.No);
                        rLinCont.MODIFY;
                        COMMIT;
                    END;
                END;
            END;
        END;
        //$006(F)

        Page.RUNMODAL(Page::"Orden de publicidad", rOrden);

        CurrPage.UPDATE;
    END;

    PROCEDURE LlamarPlazos();
    BEGIN
        CLEAR(Plazos);
        if (Rec.Type = Rec.Type::Resource) THEN BEGIN
            rRec.GET(Rec."No.");
            Plazos.Coge_Recurso(rRec);
        END;
        Plazos.RUNMODAL;
    END;





    var
        rLinP: Record "Job Planning Line";
        rLin2: Record "Job Planning Line";
        Plazos: Page "Plazos recursos reservados";
        rRec: Record Resource;


        GestRes: Codeunit "Gestion Reservas";
}