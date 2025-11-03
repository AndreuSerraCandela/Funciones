/// <summary>
/// TableExtension JobPlaningKuara (ID 80104) extends Record Job Planning Line.
/// </summary>
tableextension 75002 JobPlaningKuaraExt extends "Job Planning Line"
{


    procedure CrearLineaProduccion(Material: Text[30]; Agrupando: Boolean; Var LineasAgrupar: Record "Job Planning Line")
    var
        Prod: Record "Recursos de Producción";
        ResourceProd: Record Resource;
        ResourceOtra: Record Resource;
        ResourceOtra2: Record Resource;
        ProdTemp: Record "Recursos de Producción" temporary;
        L: Integer;
        LL: Integer;
        Linea: Record "Job Planning Line";
        TR: Record "Tipo Recurso";
        T: Code[20];
        rDet: Record 1003;
        rLin: Record 1003 temporary;
        Resource: Record Resource;
        LineaTmp: Record "Job Planning Line" temporary;
        Crear: Boolean;
        RecId: RecordId;
    begin
        If ResourceOtra2.Get(Rec."No.") Then begin
            If ResourceOtra2."Empresa Origen" <> '' Then begin
                ResourceOtra2.ChangeCompany(ResourceOtra2."Empresa Origen");
                ResourceOtra2.Get(ResourceOtra2."Nº En Empresa origen");
            end;
        end;
        Linea.SetRange("Job No.", Rec."Job No.");
        Linea.SetRange("Es Produccion", true);
        Case Material of
            'Cartel':
                Linea.SetRange(Cartel, true);
            'Lona':
                Linea.SetRange(Lona, true);
            'Vinilo':
                Linea.SetRange(Vinilo, true);
            'Otros':
                Linea.SetRange(Otros, true);
        end;
        If Not Insert(true) then
            Modify(true);
        Crear := true;
        If (Linea.Findfirst) Then
            Repeat
                If ResourceOtra.Get(Linea."No.") Then begin
                    If ResourceOtra."Empresa Origen" <> '' Then ResourceOtra.ChangeCompany(ResourceOtra."Empresa Origen");
                    ResourceOtra.Get(ResourceOtra."Nº En Empresa origen");
                end;
                If ResourceOtra2."Tipo Recurso" = ResourceOtra."Tipo Recurso" Then
                    Crear := Confirm('Ya existe una linea de producción para este material, ¿Desea crear otra?');
            until Linea.Next() = 0;
        get(Rec."Job No.", Rec."Job Task No.", Rec."Line No.");
        Commit();
        If Crear Then Begin
            Resource.Get(Rec."No.");
            if Resource."Empresa Origen" <> '' Then Prod.ChangeCompany(Resource."Empresa Origen");
            Prod.SetRange("Tipo de Soporte", Resource."Tipo Recurso");
            Prod.SetRange(Material, Material);
            if Prod.FindFirst() Then begin
                ProdTemp := Prod;
                ProdTemp."Recurso No." := Prod."Recurso No.";
                ProdTemp.Compra := Prod.Compra;
                ProdTemp.Venta := Prod.Venta;
                ProdTemp."Descuento Compra" := Prod."Descuento Compra";
                ProdTemp."Descuento Venta" := Prod."Descuento Venta";
                ProdTemp."Precio Unitario" := Prod."Precio Unitario";
                ProdTemp."Empresa Origen" := Resource."Empresa Origen";
                ProdTemp.Insert();
                Commit();
                Page.RunModal(0, ProdTemp);
            end else // si no encuentra el material, da error
                ERROR('No se ha encontrado el material para este tipo de soporte');
            Linea.SetRange("Job No.", Rec."Job No.");
            Linea.SetRange(Cartel);
            Linea.SetRange("Es Produccion");
            Linea.SetRange(Lona);
            Linea.SetRange(Vinilo);
            Linea.SetRange(Otros);
            T := '10';
            if Linea.FindLast() Then begin
                LL := "Line No.";
                L := Linea."Line No.";
                T := Linea."Job Task No.";
            end;

            Linea.Init();
            Linea."Es Produccion" := true;
            Linea.Cartel := Material = 'Cartel';
            Linea.Lona := Material = 'Lona';
            Linea.Vinilo := Material = 'Vinilo';
            Linea.Otros := Material = 'Otros';
            Linea."Job No." := Rec."Job No.";
            Linea."Job Task No." := T;
            if Prod.Incluida then
                Linea."Crear pedidos" := Linea."Crear pedidos"::"De Compra"
            else
                Linea."Crear pedidos" := Linea."Crear pedidos"::"De Compra Y De Venta";
            Linea."Line No." := l + 10000;
            Linea."Type" := Linea."Type"::Resource;
            If ProdTemp."Empresa Origen" <> '' Then begin
                ResourceProd.SetRange("Empresa Origen", ProdTemp."Empresa Origen");
                ResourceProd.SetRange("Nº En Empresa origen", ProdTemp."Recurso No.");
                ResourceProd.FindFirst();
                Linea.Validate("No.", ResourceProd."No.");
            end else
                Linea.Validate("No.", Prodtemp."Recurso No.");
            Linea.Validate(Quantity, 1);
            if Prod.Incluida then Linea."Origin Line No." := LL;
            if Prod.Incluida = false then begin
                Linea.Validate("Unit Price", Prodtemp.Venta);
                Linea.Validate("% Dto. Venta", Prodtemp."Descuento Venta");
            end;
            Linea.Validate("Unit Cost", Prodtemp.Compra);
            Linea.Validate("% Dto. Compra", Prodtemp."Descuento Compra");
            If ProdTemp."Empresa Origen" <> '' Then TR.ChangeCompany(ProdTemp."Empresa Origen");
            TR.Get(Prod."Tipo de Soporte");
            If Prod.Descripcion <> '' Then
                Linea.Description := Prod.Descripcion;
            Linea.Validate("Shortcut Dimension 3 Code", TR."Cód. Principal");
            Linea.Insert();
            If Agrupando Then begin
                if LineasAgrupar.FindFirst() then
                    repeat
                        LineaTmp := LineasAgrupar;
                        LineaTmp.LineaProduccion := RecId;
                        LineaTmp.Insert();
                    until LineasAgrupar.Next() = 0;
            end else begin
                LineaTmp := Rec;
                LineaTmp.Insert();
            end;
            Commit();
            Linea.ProduccionNuevaxLinea(Prod.Empresa, LineaTmp);
            get(Rec."Job No.", Rec."Job Task No.", Rec."Line No.");
            Rec.LineaProduccion := Linea.RecordId;
            Rec.Modify();
        End else begin
            RecId := Linea.RecordId;
            If Agrupando Then begin
                if LineasAgrupar.FindFirst() then
                    repeat
                        LineaTmp := LineasAgrupar;
                        LineaTmp.LineaProduccion := RecId;
                        LineaTmp.Insert();
                    until LineasAgrupar.Next() = 0;
            end else
                If Linea.FindSet() Then
                    repeat
                        LineaTmp := Linea;
                        If LineaTmp.Insert() then;
                    until Linea.Next() = 0;
            LineaTmp := Rec;
            If LineaTmp.Insert() Then;
            Linea.Reset;
            Linea.get(RecId);
            Linea.ProduccionNuevaxLinea(Prod.Empresa, LineaTmp);
            get(Rec."Job No.", Rec."Job Task No.", Rec."Line No.");
            Rec.LineaProduccion := Linea.RecordId;
            Rec.Modify();
        end;

    end;

    /// <summary>
    /// ValidateShortcutDimCode.
    /// </summary>
    /// <param name="FieldNumber">Integer.</param>
    /// <param name="ShortcutDimCode">VAR Code[20].</param>


    // PROCEDURE Busca_Tarifa();
    // BEGIN
    //     //$001
    //     CLEAR(wP);
    //     if (Type = Type::Resource) AND ("Compra a-Nº proveedor" <> '') AND
    //        ("Planning Date" <> 0D) AND ("Fecha Final" <> 0D) THEN BEGIN
    //         wP := Gest_Rvas.Busca_Tarifa("No.", "Compra a-Nº proveedor", "Planning Date", "Fecha Final", "Job No.");
    //         if wp = 0 Then exit;
    //         CASE "Crear pedidos" OF
    //             "Crear pedidos"::"De Venta":
    //                 BEGIN
    //                     //  {
    //                     //  "Unit Price" := wP;
    //                     //  MODIFY;
    //                     //  VALIDATE("Unit Price");
    //                     //  }
    //                     VALIDATE("Unit Price", wP);
    //                 END;
    //             "Crear pedidos"::"De Compra Y De Venta":
    //                 BEGIN
    //                     // {
    //                     // "Unit Price" := wP;
    //                     // MODIFY;
    //                     // VALIDATE("Unit Price");
    //                     // "Unit Cost" := wP;
    //                     // MODIFY;
    //                     // VALIDATE("Unit Cost");
    //                     // }
    //                     VALIDATE("Unit Price", wP);
    //                     VALIDATE("Unit Cost", wP);
    //                 END;
    //         END;
    //     END;
    // END;

    trigger OnInsert()
    Var
        rSelf: Record "Job Planning Line";
        Job: Record Job;
        EsJulia: Boolean;
        Text50001: Label 'OJO. El proyecto ya esta en estado Contrato, y ya se han \creado los pedidos de venta y compra. Si quiere modificarlos\debera hacerlo a mano.';
    Begin
        Job.Get(Rec."Job No.");
        EsJulia := UserId in ['GRUPOMALLA\JULIÀ.SASTRE', 'JULIÀ.SASTRE'];
        // $001 -
        Job.TESTFIELD("Cód. vendedor");
        if Job.Status = Job.Status::Open THEN
            If not EsJulia then
                MESSAGE(Text50001);
        Rec."Planning Date" := Job."Starting Date";
        Rec."Fecha Final" := Job."Ending Date";
        //Mirar_Estado;
        // $001 +

        // $003-
        Rec.Tipo := Job.Tipo;
        Rec."Soporte de" := Job."Soporte de";
        Rec."Fija/Papel" := Job."Fija/Papel";
        // $003+
        Rec."Subtipo cabecera" := Job.Subtipo;                                //$009

        rSelf.SETRANGE(rSelf."Job No.", Rec."Job No.");
        rSelf.SETRANGE(rSelf."Job Task No.", Rec."Job Task No.");
        if rSelf.FINDLAST THEN
            If Rec."Line No." = 0 Then
                Rec."Line No." := rSelf."Line No." + 10000;
        // if BuscarecursosRelacionados("Line No.", "Job No.", "No.") = FALSE THEN
        //   Produccion;

    end;


    trigger OnModify()
    Begin

        if xRec."No." <> "No." THEN BEGIN
            //  VALIDATE("Unit Price", 0);
            BorrarecursosRelacionados("Line No.", "Job No.");
        END;
        //if BuscarecursosRelacionados("Line No.", "Job No.", "No.") = FALSE THEN
        //  Produccion; TODO Revisar
    End;

    trigger OnDelete()
    var
        rSelf: Record "Job Planning Line";
    Begin

        //TESTFIELD(Transferred,FALSE);

        BorrarecursosRelacionados("Line No.", "Job No.");
        // MNC 211098
        if ("Cdad. Reservada" <> 0) THEN
            ERROR('No se puede borrar esta linea, porque ya se han creado reservas');
        CALCFIELDS("No. Orden Publicidad");
        if ("No. Orden Publicidad" <> '') THEN BEGIN
            if ("Estado Orden Publicidad" = "Estado Orden Publicidad"::Validada) THEN
                ERROR(Text50003);
            rOrden.RESET;
            if rOrden.GET("No. Orden Publicidad") Then
                rOrden.DELETE(TRUE);
        END;

        rTexto.SETRANGE("Nº proyecto", "Job No.");
        //  $001 -
        // {
        // rTexto.SETRANGE("Cód. fase","Phase Code");
        // rTexto.SETRANGE("Cód. subfase","Task Code");
        // rTexto.SETRANGE("Cód. tarea","Step Code");
        // }
        rTexto.SETRANGE("Cód. tarea", "Job Task No.");
        rTexto.SETRANGE("Nº linea aux", "Line No.");
        //  $001 +
        rTexto.SETRANGE(Tipo, Type.AsInteger());
        rTexto.SETRANGE("Nº", "No.");
        rTexto.SETRANGE("Cód. variante", "Variant Code");
        rTexto.DELETEALL;
        // Fi MNC
        rSelf.SETRANGE(rSelf."Job No.", "Job No.");
        rSelf.SETRANGE("Origin Line No.", "Line No.");
        rSelf.DELETEALL;
    End;

    PROCEDURE Mirar_Estado();
    var
        Tipo: Record "Tipo Recurso";
    BEGIN
        //$001
        if ((Type = Type::Resource) AND ("No." <> '')) THEN BEGIN
            if Res.GET("No.") THEN
                Res.TESTFIELD(Blocked, FALSE);
            If Not Tipo.GET(Res."Tipo Recurso") THEN
                Tipo.Init();
            If Not ((Res."Recurso Agrupado") Or (Tipo."Crea Reservas")) THEN
                Rec."Sin Producción" := TRUE;
            if Rec."Recurso Agrupado" then exit;
            if Res."Producción" then exit;
            if Not Tipo."Crea Reservas" then exit;
            if Rec."Planning Date" = 0D then exit;
            if Rec."Fecha Final" = 0D then exit;
            rDia.RESET;
            CLEAR(rDia);
            rDia.SETCURRENTKEY("Nº Recurso", Fecha);
            rDia.SETRANGE("Nº Recurso", "No.");
            rDia.SETRANGE(Fecha, "Planning Date", "Fecha Final");
            if rDia.FINDFIRST THEN BEGIN
                Job.GET(rDia."Nº Proyecto");
                MESSAGE('Este recurso ya está %1 en el proyecto %2 \' +
                        'Campaña: %3\' +
                        'No se permitirá la creación de nuevas reservas en del %4 al %5. \' +
                        'Téngalo en cuenta.', rDia.Estado, rDia."Nº Proyecto", Job.Description, Format(Rec."Planning Date", 0, '<Day,2> de <Month,2> de <Year>'), Format(Rec."Fecha Final", 0, '<Day,2> de <Month,2> de <Year>'));
            END;
        END;
    END;

    PROCEDURE TraeCodDivisa(): Code[10];
    VAR
        rProy: Record 167;
    BEGIN
        //FCL-24/02/04. Migración de 2.0. a 3.70.

        if ("Job No." = rProy."No.") THEN
            EXIT(rProy."Cód. divisa")
        ELSE
            if rProy.GET("Job No.") THEN
                EXIT(rProy."Cód. divisa")
            ELSE
                EXIT('');
    END;

    PROCEDURE RevisaOpciones();
    BEGIN
        //   { No se si en las lineas lo tengo que dejar... Pte Lloren‡
        //   // $003
        //   CASE Tipo OF
        //     Tipo::"Por Campa¤a": BEGIN
        //              "Fija/Papel" := "Fija/Papel"::Papel;
        //            END;
        //     Tipo::Otros: BEGIN            // unico caso que se tocan las otras opciones
        //              "Fija/Papel" := 0;
        //              Subtipo      := 0;
        //              "Soporte de" := 0;
        //            END;
        //     ELSE BEGIN
        //            if ("Soporte de" = "Soporte de"::Fijación) THEN
        //              "Fija/Papel" := "Fija/Papel"::Papel
        //            ELSE
        //              "Fija/Papel" := "Fija/Papel"::Fija;
        //          END;
        //   END;
        //   }
    END;

    PROCEDURE BorrarecursosRelacionados(Num: Integer; JobNum: Code[20]);
    VAR
        ProduccionesRelacionadas: Record "Produccines Relacionadas";
        Job: Record Job;
        rRecRerlOtra: Record "Produccines Relacionadas";
        Resource: Record Resource;
        Contrato: Record "Sales Header";
    BEGIN
        ProduccionesRelacionadas.SETRANGE(ProduccionesRelacionadas."Line No.", Num);
        ProduccionesRelacionadas.SETRANGE(ProduccionesRelacionadas."Job No.", JobNum);
        Job.Get(JobNum);
        If Contrato.Get(Contrato."Document Type"::Order, Job."Nº Contrato") then
            If Contrato.Estado = Contrato.Estado::Firmado THEN
                ERROR('No se puede eliminar una producción de un contrato firmado');
        if ProduccionesRelacionadas.FINDFIRST THEN
            REPEAT
                If ProduccionesRelacionadas.Empresa <> CompanyName tHEN begin
                    rRecRerlOtra.ChangeCompany(ProduccionesRelacionadas.Empresa);
                    If Resource.Get(ProduccionesRelacionadas."No.") Then
                        Resource.ChangeCompany(ProduccionesRelacionadas.Empresa);
                    If Resource.Get("Recurso en Empresa Origen") Then begin
                        rRecRerlOtra.SETRANGE(rRecRerlOtra."No.", Resource."No.");
                        rRecRerlOtra.SETRANGE(rRecRerlOtra."Job No.", ProduccionesRelacionadas."Job No.2");
                        rRecRerlOtra.DeleteAll();
                    end;
                end;
            UNTIL ProduccionesRelacionadas.NEXT = 0;
        ProduccionesRelacionadas.DELETEALL;
    END;

    PROCEDURE BorrarecursosRelacionados(Num: Integer; JobNum: Code[20]; Num2: Integer; JobNum2: Code[20]);
    VAR
        ProduccionesRelacionadas: Record "Produccines Relacionadas";
        rRecRerlOtra: Record "Produccines Relacionadas";
        Resource: Record Resource;
        Job: Record Job;
        Contrato: Record "Sales Header";
    BEGIN
        ProduccionesRelacionadas.SETRANGE(ProduccionesRelacionadas."Line No.", Num);
        ProduccionesRelacionadas.SETRANGE(ProduccionesRelacionadas."Job No.", JobNum);
        if ProduccionesRelacionadas.FINDFIRST THEN
            REPEAT
                If ProduccionesRelacionadas.Empresa <> CompanyName tHEN begin
                    rRecRerlOtra.ChangeCompany(ProduccionesRelacionadas.Empresa);
                    Resource.Get(ProduccionesRelacionadas."No.");
                    Resource.ChangeCompany(ProduccionesRelacionadas.Empresa);
                    If Resource.Get("Recurso en Empresa Origen") Then begin
                        rRecRerlOtra.SETRANGE(rRecRerlOtra."No.", Resource."No.");
                        rRecRerlOtra.SETRANGE(rRecRerlOtra."Job No.", JobNum2);
                        if rRecRerlOtra.FindFirst() then Error('No se puede eliminar una producción de un recurso que ha sido asignado en otra empresa. Primero debe borrar en %1 el proyecto %2', ProduccionesRelacionadas.Empresa, JobNum2);
                    end;
                end;
            UNTIL ProduccionesRelacionadas.NEXT = 0;
        Job.Get(JobNum);
        If Contrato.Get(Contrato."Document Type"::Order, Job."Nº Contrato") then
            If Contrato.Estado = Contrato.Estado::Firmado THEN
                ERROR('No se puede eliminar una producción de un contrato firmado');
        ProduccionesRelacionadas.SETRANGE("Line No.", Num);
        ProduccionesRelacionadas.SETRANGE("Job No.", JobNum);
        ProduccionesRelacionadas.SETRANGE("Line No.2", Num2);
        ProduccionesRelacionadas.SETRANGE("Job No.2", JobNum2);
        ProduccionesRelacionadas.DELETEALL;

    END;

    PROCEDURE Produccion();
    VAR
        Felije: Page "Elige Proyecto";
        rJobPl: Record 1003 TEMPORARY;
        rRes: Record 156;
        rJobPl2: Record 1003;
        Linea: Integer;

    BEGIN
        if rRes.GET("No.") THEN BEGIN
            Linea := "Line No.";
            if NOT rRes.Producción THEN BEGIN
                rJobPl2.SETRANGE(rJobPl2."Job No.", "Job No.");
                rJobPl2.SETRANGE(rJobPl2."Origin Line No.", "Line No.");
                if rJobPl2.FINDFIRST THEN
                    REPEAT
                        Linea := rJobPl2."Line No.";
                        if rRes.GET(rJobPl2."No.") THEN BEGIN
                            if rRes.Producción THEN rJobPl2.FINDLAST;
                        END;
                    UNTIL rJobPl2.NEXT = 0;
            END;
            if rRes.Producción THEN BEGIN
                rJobPl."Job No." := "Job No.";
                rJobPl."Job Task No." := "Job Task No.";
                rJobPl."Line No." := Linea;
                rJobPl."Planning Date" := "Planning Date";
                rJobPl."Document No." := "Document No.";
                rJobPl.Type := Type;
                rJobPl."No." := rRes."No.";
                rJobPl.INSERT;
                COMMIT;
                CLEAR(Felije);
                Felije.CargaLinea(rJobPl);
                Felije.RUNMODAL;
            END;
        END;
    END;

    PROCEDURE ProduccionNuevaxLinea(Empresa: Text; Var r1003: Record 1003 Temporary);
    VAR
        Felije: Page "Elige Proyecto";
        rJobPl: Record 1003 TEMPORARY;
        rRes: Record 156;
        rRes2: Record 156;
        rJobPl2: Record 1003;
        Linea: Integer;
        Actual: Boolean;
        rProdu: Record "Produccines Relacionadas";
    BEGIN

        if rRes.GET("No.") THEN BEGIN
            rRes2.Get("No.");
            Linea := "Line No.";
            if NOT rRes.Producción THEN BEGIN
                rJobPl2.SETRANGE(rJobPl2."Job No.", "Job No.");
                rJobPl2.SETRANGE(rJobPl2."Origin Line No.", "Line No.");
                if rJobPl2.FINDFIRST THEN
                    REPEAT
                        Linea := rJobPl2."Line No.";
                        if rRes.GET(rJobPl2."No.") THEN BEGIN
                            if rRes.Producción THEN rJobPl2.FINDLAST;
                        END;
                    UNTIL rJobPl2.NEXT = 0;
            END;
            if rRes.Producción THEN BEGIN
                rJobPl."Job No." := "Job No.";
                rJobPl."Job Task No." := "Job Task No.";
                rJobPl."Line No." := Linea;
                rJobPl."Planning Date" := "Planning Date";
                rJobPl."Document No." := "Document No.";
                rJobPl.Type := Type;
                rJobPl."No." := rRes."No.";
                rJobPl.INSERT;
                //Miro si solo hay una linea
                if r1003.FindFirst() Then begin
                    if r1003.FINDFIRST THEN
                        repeat
                            if rProdu.GET(Rec."Line No.", Rec."Job No.", r1003."Line No.", r1003."Job No.") THEN rProdu.DELETE;
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
                            if Not rRes.GET(r1003."No.") THEN rRes.Init;
                            If Rres2."Empresa Origen" <> '' Then Begin
                                rRes2.ChangeCompany(Rres2."Empresa Origen");
                                rRes2.Get(rRes2."Nº En Empresa origen");
                            end;
                            if rRes2."Tipo Recurso" = rRes."Tipo Recurso" Then begin
                                rProdu.Description := Rec.Description;
                                rProdu."Description 2" := r1003.Description;
                                rProdu."No.2" := r1003."No.";
                                if Not rRes.Producción THEN
                                    rProdu.INSERT;
                            end else
                                Error(' No se puede relacionar un recurso de tipo %1 con un recurso de tipo %2', rRes2."Tipo Recurso", rRes."Tipo Recurso");
                        until r1003.Next() = 0;
                    Commit();
                    exit;
                end;

            END;
        END;
    END;


    PROCEDURE ProduccionNueva(Empresa: Text; Proyecto: Code[20]);
    VAR
        Felije: Page "Elige Proyecto";
        rJobPl: Record 1003 TEMPORARY;
        rRes: Record 156;
        rRes2: Record 156;
        rJobPl2: Record 1003;
        Linea: Integer;
        r1003: Record 1003;
        Actual: Boolean;
        rProdu: Record "Produccines Relacionadas";

    BEGIN

        if rRes.GET("No.") THEN BEGIN
            rRes2.Get("No.");
            Linea := "Line No.";
            if NOT rRes.Producción THEN BEGIN
                rJobPl2.SETRANGE(rJobPl2."Job No.", "Job No.");
                rJobPl2.SETRANGE(rJobPl2."Origin Line No.", "Line No.");
                if rJobPl2.FINDFIRST THEN
                    REPEAT
                        Linea := rJobPl2."Line No.";
                        if rRes.GET(rJobPl2."No.") THEN BEGIN
                            if rRes.Producción THEN rJobPl2.FINDLAST;
                        END;
                    UNTIL rJobPl2.NEXT = 0;
            END;
            if rRes.Producción THEN BEGIN
                rJobPl."Job No." := "Job No.";
                rJobPl."Job Task No." := "Job Task No.";
                rJobPl."Line No." := Linea;
                rJobPl."Planning Date" := "Planning Date";
                rJobPl."Document No." := "Document No.";
                rJobPl.Type := Type;
                rJobPl."No." := rRes."No.";
                rJobPl.INSERT;
                Actual := (Proyecto = Rec."Job No.");
                //Miro si solo hay una linea
                if Empresa <> COMPANYNAME THEN
                    r1003.CHANGECOMPANY(Empresa);
                r1003.RESET;
                r1003.SETRANGE(r1003."Job No.", Proyecto);
                if Actual THEN
                    r1003.SETFILTER(r1003."Line No.", '<>%1', Rec."Line No.");

                if r1003.FindFirst() Then begin
                    if r1003.FINDFIRST THEN
                        repeat
                            if rProdu.GET(Rec."Line No.", Rec."Job No.", r1003."Line No.", r1003."Job No.") THEN rProdu.DELETE;
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
                            if Not rRes.GET(r1003."No.") THEN rRes.Init;
                            if rRes2."Tipo Recurso" = rRes."Tipo Recurso" Then begin
                                rProdu.Description := Rec.Description;
                                rProdu."Description 2" := r1003.Description;
                                rProdu."No.2" := r1003."No.";
                                if Not rRes.Producción THEN
                                    rProdu.INSERT;
                            end;
                        until r1003.Next() = 0;
                    Commit();
                    exit;
                end;
                COMMIT;
                CLEAR(Felije);
                Felije.CargaLinea(rJobPl, Empresa, Proyecto);
                Felije.RUNMODAL;
            END;
        END;
    END;

    PROCEDURE BuscarecursosRelacionados(Num: Integer; JobNum: Code[20]; ResNum: Code[20]): Boolean;
    VAR
        rRecRerl: Record "Produccines Relacionadas";

    BEGIN
        rRecRerl.SETRANGE(rRecRerl."Line No.", Num);
        rRecRerl.SETRANGE(rRecRerl."Job No.", JobNum);
        rRecRerl.SETRANGE(rRecRerl."No.", ResNum);
        EXIT(rRecRerl.FINDFIRST);
    END;


    var
        myInt: Integer;
        rDim: Record 352;
        wP: Decimal;
        Gest_Rvas: Codeunit "Gestion Reservas";
        Res: Record "Resource";
        Job: Record "Job";
        rDia: Record "Diario Reserva";
        rTexto: Record "Texto Presupuesto";
        rTipus: Record "Tipo Recurso";
        rFamilia: Record "Resource Group";
        rOrden: Record "Cab. orden publicidad";
        Text50000: Label 'Cuidado! La fecha de final es menor a la fecha de inicio.';
        Text50001: Label 'OJO. El proyecto ya esta en estado Contrato, y ya se han \creado los pedidos de venta y compra. Si quiere modificarlos\debera hacerlo a mano.';
        Text50002: Label 'Esta linea ya tiene reservas asociadas. No se puede modificar este campo.';
        Text50003: Label 'No se puede eliminar esta linea, ya que tiene una orden de publicidad Validada.';
}