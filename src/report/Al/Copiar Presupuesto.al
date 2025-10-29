/// <summary>
/// Report Copiar presupuesto (ID 50022).
/// </summary>
report 50019 "Copiar presupuesto"
{
    UseRequestPage = true;
    ProcessingOnly = true;
    //No se usa
    dataset
    {

    }
    requestpage
    {
        layout
        {
            area(Content)
            {
                field(NoDoc; NoDoc)
                {
                    ApplicationArea = All;
                    Caption = 'Nº documento';
                    trigger OnValidate()
                    BEGIN
                        ValidarNoDoc;
                    END;

                    trigger OnLookup(var Text: Text): Boolean
                    BEGIN
                        LookupNoDoc;
                    END;
                }
                field(Cliente; DesdeCab."Bill-to Customer No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Caption = 'Venta a-Nº cliente';
                }
                field(Nombre; DesdeCab."Bill-to Name")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Caption = 'Venta a-Nombre';
                }
            }
        }
        trigger OnOpenPage()
        begin
            if NoDoc <> '' THEN BEGIN
                CASE TipoDoc OF
                    TipoDoc::Oferta:
                        if DesdeCabVenta.GET(DesdeCabVenta."Document Type"::Quote, NoDoc) THEN
                            ;
                    TipoDoc::"Pedido abierto":
                        if DesdeCabVenta.GET(DesdeCabVenta."Document Type"::"Blanket Order", NoDoc) THEN
                            ;
                    TipoDoc::Pedido:
                        if DesdeCabVenta.GET(DesdeCabVenta."Document Type"::Order, NoDoc) THEN
                            ;
                    TipoDoc::Factura:
                        if DesdeCabVenta.GET(DesdeCabVenta."Document Type"::Invoice, NoDoc) THEN
                            ;
                    TipoDoc::Abono:
                        if DesdeCabVenta.GET(DesdeCabVenta."Document Type"::"Credit Memo", NoDoc) THEN
                            ;
                    TipoDoc::"Albarán regis.":
                        if DesdeCabAlbVenta.GET(NoDoc) THEN
                            DesdeCabVenta.TRANSFERFIELDS(DesdeCabAlbVenta);
                    TipoDoc::"Factura regis.":
                        if DesdeCabFacVenta.GET(NoDoc) THEN
                            DesdeCabVenta.TRANSFERFIELDS(DesdeCabFacVenta);
                    TipoDoc::"Abono regis.":
                        if DesdeCabAboVenta.GET(NoDoc) THEN
                            DesdeCabVenta.TRANSFERFIELDS(DesdeCabAboVenta);
                END;
                if DesdeCabVenta."No." = '' THEN
                    NoDoc := '';
            END;
            ValidarNoDoc;
        end;



    }
    VAR
        CabVenta: Record 36;
        Proyecto: Record 167;
        LinVtas: Record 37;
        Lin: Record 1003;
        CabVtasAnt: Record 36;
        ProyAnt: Record 167;
        DesdeCabVenta: Record 36;
        DesdeCab: Record 167;
        DesdeLinVenta: Record 37;
        DesdeLin: Record 1003;
        DesdeCabAlbVenta: Record 110;
        DesdeLinAlbVenta: Record 111;
        DesdeCabFacVenta: Record 112;
        DesdeProyecto: Record 167;
        DesdeLinFacVenta: Record 113;
        DesdeCabAboVenta: Record 114;
        DesdeLinAboVenta: Record 115;
        MovClie: Record 21;
        CGCta: Record 15;
        rTAmpli: Record "Texto Presupuesto";
        rTA2: Record "Texto Presupuesto";

        rTask: Record 1001;
        TestLimitCredCliente: Codeunit 312;
        TestDispoProd: Codeunit 311;
        TransfTextAdicPrev: Codeunit 379;
        TipoDoc: Option Oferta,"Pedido abierto",Pedido,Factura,Abono,"Albarán regis.","Factura regis.","Abono regis.";
        NoDoc: Code[20];
        IncluirCab: Boolean;
        RecalcLins: Boolean;
        NoSigLin: Integer;
        CopiaEstaLin: Boolean;
        LinsNoCopiadas: Integer;
        AnulacionDocumento: Boolean;

    trigger OnPreReport()
    begin
        if NoDoc = '' THEN
            ERROR('Introduzca un nº documento.');
        Proyecto.FIND;
        DesdeCab.GET(NoDoc);
        if (DesdeCab."No." = Proyecto."No.") THEN
            ERROR('Proyecto %1. No se puede copiar sobre si mismo.', Proyecto."No.");

        Lin.LOCKTABLE;
        Lin.SETRANGE("Job No.", Proyecto."No.");
        Proyecto.LOCKTABLE(TRUE, FALSE);

        LinsNoCopiadas := 0;
        DesdeLin.RESET;
        DesdeLin.SETCURRENTKEY("Job No.", "Line Type");
        DesdeLin.SETRANGE("Job No.", DesdeCab."No.");
        DesdeLin.SETRANGE("Line Type", DesdeLin."Line Type"::Budget);
        if DesdeLin.FIND('-') THEN
            REPEAT
                CopiarLineas;
            UNTIL DesdeLin.NEXT = 0;

        if LinsNoCopiadas > 0 THEN
            MESSAGE(
                'La/s línea/s del documento que tienen indicada una cuenta contable que no admite' +
                'registro directo, no se copian al nuevo documento.');
    END;

    LOCAL PROCEDURE ValidarNoDoc();
    BEGIN
        if NoDoc = '' THEN
            DesdeCab.INIT
        ELSE
            if DesdeCab."No." = '' THEN BEGIN
                DesdeCab.INIT;
                DesdeProyecto.GET(NoDoc);
                DesdeCab.TRANSFERFIELDS(DesdeProyecto);
            END;
        DesdeCab."No." := '';

        ValidarIncluirCab;
    END;

    LOCAL PROCEDURE LookupNoDoc();
    BEGIN
        DesdeCab."No." := NoDoc;
        if (NoDoc = '') AND (Proyecto."Bill-to Customer No." <> '') THEN BEGIN
            if DesdeCab.SETCURRENTKEY("Bill-to Customer No.") THEN BEGIN
                DesdeCab."Bill-to Customer No." := Proyecto."Bill-to Customer No.";
                if DesdeCab.FIND('=><') THEN;
            END;
            if PAGE.RUNMODAL(0, DesdeCab) = ACTION::LookupOK THEN
                NoDoc := DesdeCab."No.";
        END;
        ValidarNoDoc;
    END;

    LOCAL PROCEDURE ValidarIncluirCab();
    BEGIN
        RecalcLins := NOT IncluirCab;
    END;

    LOCAL PROCEDURE CopiarLineas();
    VAR
        Lin2: Record 1003;
        L: Integer;
        rTA2T: Record "Texto Presupuesto" temporary;
        Resource: Record Resource;
        ResourceOtraEmpresa: Record Resource;
        Blo: Record "Incidencias Rescursos";
    BEGIN
        Lin.INIT;
        Lin.TRANSFERFIELDS(DesdeLin);
        Lin2.SETRANGE(Lin2."Job No.", Proyecto."No.");
        if Lin2.FINDLAST THEN
            Lin."Line No." := Lin2."Line No." + 10000;
        Lin."Job No." := Proyecto."No.";
        Lin."Planning Date" := Proyecto."Starting Date";
        Lin."Fecha Final" := Proyecto."Ending Date";
        Lin.INSERT;
        Lin.Quantity := 0;
        Lin."Cdad. a Reservar" := 0;
        Lin."Cdad. Reservada" := 0;
        Lin."Direct Unit Cost (LCY)" := 0;
        Lin."Unit Cost (LCY)" := 0;
        Lin."Unit Price (LCY)" := 0;
        Lin."Unit Cost" := 0;
        Lin."Unit Price" := 0;
        Lin.VALIDATE("No.");

        Lin.Description := DesdeLin.Description;
        // $001 DesdeLin.CALCFIELDS(Quantity);
        Lin.VALIDATE(Quantity, DesdeLin.Quantity);
        //$002(I)
        Lin.VALIDATE("Compra a-Nº proveedor", DesdeLin."Compra a-Nº proveedor");
        Lin.VALIDATE("Unit Cost", DesdeLin."Unit Cost");
        Lin.VALIDATE("Unit Price", DesdeLin."Unit Price");
        Lin."Tipo Duracion" := DesdeLin."Tipo Duracion";
        Lin.Duracion := DesdeLin.Duracion;
        Lin."Cdad. Soportes" := DesdeLin."Cdad. Soportes";
        Lin.Validate("Dto. Tarifa", DesdeLin."Dto. Tarifa");
        Lin.Validate("% Dto. Venta", DesdeLin."% Dto. Venta");
        Lin.Validate("% Dto. Venta 1", DesdeLin."% Dto. Venta 1");
        Lin.Validate("% Dto. Venta 2", DesdeLin."% Dto. Venta 2");
        Lin.Validate("% Dto. Compra", DesdeLin."% Dto. Compra");




        //$002(F)
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
        Lin.MODIFY;

        CLEAR(rTask);
        rTask.SETRANGE("Job No.", Lin."Job No.");
        rTask.SETRANGE("Job Task No.", Lin."Job Task No.");
        if rTask.ISEMPTY THEN BEGIN
            rTask."Job No." := Lin."Job No.";
            rTask."Job Task No." := Lin."Job Task No.";
            rTask."Job Task Type" := rTask."Job Task Type"::Posting;
            rTask."Job Posting Group" := Proyecto."Job Posting Group";
            if rTask.INSERT THEN;
        END;

        // TEXTO PRESUPUESTO
        rTAmpli.INIT;
        rTAmpli.SETCURRENTKEY("Nº proyecto", "Cód. fase", "Cód. subfase", "Cód. tarea",
                 Tipo, "Nº", "Cód. variante", "Nº linea aux", "Nº linea");
        rTAmpli.SETRANGE("Nº proyecto", DesdeLin."Job No.");
        //   // $001-
        //   {
        //   rTAmpli.SETRANGE("Cód. fase",     DesdeLin."Phase Code");
        //   rTAmpli.SETRANGE("Cód. subfase",  DesdeLin."Task Code");
        //   rTAmpli.SETRANGE("Cód. tarea",    DesdeLin."Step Code");
        //   }
        rTAmpli.SETRANGE("Cód. tarea", DesdeLin."Job Task No.");
        rTAmpli.SETRANGE("Nº linea aux", DesdeLin."Line No.");
        // $001+
        rTAmpli.SETRANGE(Tipo, DesdeLin.Type.AsInteger());
        rTAmpli.SETRANGE("Nº", DesdeLin."No.");
        rTAmpli.SETRANGE("Cód. variante", DesdeLin."Variant Code");
        if rTAmpli.FindFirst() THEN
            REPEAT
                rTA2T.INIT;
                rTA2T.TRANSFERFIELDS(rTAmpli);
                rTA2T."Nº proyecto" := Lin."Job No.";
                rTA2T."Nº linea aux" := Lin."Line No.";
                L := rTAmpli."Nº linea";
                rTA2T."Nº linea" := L;
                repeat
                    rTA2T."Nº linea" := L;
                    l += 10000;
                Until rTA2T.INSERT;
            UNTIL rTAmpli.NEXT = 0;
        if rTA2T.FindFirst() then
            repeat
                rTA2 := rTA2T;
                L := rTA2T."Nº linea";
                repeat
                    rTA2."Nº linea" := L;
                    l += 10000;
                Until rTA2.INSERT;
            until rTA2T.Next() = 0;
    END;

    LOCAL PROCEDURE TestEfecs();
    BEGIN
        MovClie.SETRANGE("Document Type", MovClie."Document Type"::Refund);
        if NOT MovClie.FIND('-') THEN
            EXIT;
        MovClie.MODIFYALL("Applies-to ID", DesdeCabFacVenta."No.");
        CabVenta."Applies-to ID" := DesdeCabFacVenta."No.";
    END;

    PROCEDURE DefOpciones(TipoDocumento: Integer; NumeroDoc: Code[20]; IncluirCabecera: Boolean; RecalcularLineas: Boolean; AnulaDoc: Boolean);
    BEGIN
        TipoDoc := TipoDocumento;
        NoDoc := '';
        ValidarNoDoc;
        NoDoc := NumeroDoc;
        AnulacionDocumento := AnulaDoc;
        ValidarNoDoc;
        IncluirCab := IncluirCabecera;
        ValidarIncluirCab;
        RecalcLins := RecalcularLineas;
        if TipoDoc = TipoDoc::"Albarán regis." THEN
            RecalcLins := TRUE;
    END;

    PROCEDURE DefCabVentas(VAR NuevoProy: Record 167);
    BEGIN
        Proyecto := NuevoProy;
    END;


}

