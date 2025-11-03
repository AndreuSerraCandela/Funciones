/// <summary>
/// Page MLL-Presupuesto proyecto compr (ID 50050).
/// </summary>
page 50050 "MLL-Presupuesto proyecto compr"
{

    SourceTable = "Job Planning Line";
    SourceTableView = SORTING("Job No.", "Job Task No.", "Line No.")
                    WHERE("Line Type" = CONST(Budget));
    DataCaptionFields = "Job No.";
    PageType = List;
    UsageCategory = Lists;
    SaveValues = true;

    layout
    {
        area(Content)
        {
            repeater(Detalle)
            {

                field("Line Type"; Rec."Line Type")
                {
                    ApplicationArea = all;
                }
                field("Job Task No."; Rec."Job Task No.")
                {
                    ApplicationArea = all;
                }
                field(Type; Rec.Type)
                {
                    ApplicationArea = all;
                }
                field("No."; Rec."No.")
                {
                    ApplicationArea = all;
                    Style = Strong;
                    StyleExpr = StyleIsStrong;

                    trigger OnAssistEdit()
                    VAR
                        rJobPl: Record 1003;
                        fJobl: page 50019;
                        rRes: Record 156;
                        rCost: Record "Price List Line";
                        Linea: Integer;
                    BEGIN
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
                    END;
                }
                field("No Orden Recurso"; Rec."No Orden Recurso")
                {
                    ApplicationArea = all;
                }
                field("Compra a-Nº proveedor"; rec."Compra a-Nº proveedor")
                {
                    ApplicationArea = all;
                    trigger OnValidate()
                    BEGIN
                        Rec."Crear pedidos" := Rec."Crear pedidos"::"De Compra";
                        CurrPage.UPDATE;
                    END;
                }
                field("Nombre Soporte"; Rec."Nombre Soporte")
                {
                    ApplicationArea = all;

                }
                field("Crear pedidos"; Rec."Crear pedidos")
                {
                    ApplicationArea = all;
                }
                field("No. Orden Publicidad"; Rec."No. Orden Publicidad")
                {
                    ApplicationArea = all;
                    Lookup = true;
                    DrillDown = false;
                    trigger OnLookup(var Text: Text): Boolean
                    BEGIN
                        OrdenesPubli;
                    END;
                }
                field("Estado Orden Publicidad"; Rec."Estado Orden Publicidad")
                {
                    ApplicationArea = all;
                    Lookup = false;
                    DrillDown = false;
                }
                field("Variant Code"; Rec."Variant Code")
                {
                    ApplicationArea = all;
                    Visible = false;
                }
                field("Planning Date"; rec."Planning Date")
                {
                    ApplicationArea = all;
                    trigger OnValidate()
                    BEGIN
                        CurrPage.SAVERECORD;
                    END;
                }
                field("Fecha Final"; Rec."Fecha Final")
                {
                    ApplicationArea = all;
                }
                field(Medidas; Rec.Medidas)
                {
                    ApplicationArea = all;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = all;
                }
                field("Description 2"; Rec."Description 2")
                {
                    ApplicationArea = all;
                }
                field("Enunciado Cto. Venta"; Rec."Enunciado Cto. Venta")
                {
                    ApplicationArea = all;
                }
                field("Shortcut Dimension 1 Code"; Rec."Shortcut Dimension 1 Code")
                {
                    ApplicationArea = all;
                }
                field("Shortcut Dimension 2 Code"; Rec."Shortcut Dimension 2 Code")
                {
                    ApplicationArea = all;
                }
                field("Customer Price Group"; Rec."Customer Price Group")
                {
                    ApplicationArea = all;
                    Visible = false;
                }
                field(Quantity; Rec.Quantity)
                {
                    ApplicationArea = all;
                }
                field("Cdad. a Reservar"; Rec."Cdad. a Reservar")
                {
                    ApplicationArea = all;
                }
                field("Cdad. Reservada"; Rec."Cdad. Reservada")
                {
                    ApplicationArea = all;
                    Editable = false;
                }
                field("Unit Cost"; Rec."Unit Cost")
                {
                    ApplicationArea = all;
                    trigger OnValidate()
                    BEGIN
                        CurrPage.SAVERECORD;
                    END;
                }
                field("Total Cost"; Rec."Total Cost")
                {
                    ApplicationArea = all;
                }
                field("% Dto. Compra"; Rec."% Dto. Compra")
                {
                    ApplicationArea = all;
                }
                field("Unit Price"; Rec."Unit Price")
                {
                    ApplicationArea = all;
                    trigger OnValidate()
                    BEGIN
                        CurrPage.SAVERECORD;
                    END;
                }
                field("Total Price"; Rec."Total Price")
                {
                    ApplicationArea = all;
                }
                field("% Dto. Venta"; Rec."% Dto. Venta")
                {
                    ApplicationArea = all;
                }
                field("Nº fam. recurso"; Rec."Nº fam. recurso")
                {
                    ApplicationArea = all;
                    Editable = false;
                }
                field("Texto en linea"; Rec."Texto en linea")
                {
                    ApplicationArea = all;
                    Editable = false;
                }
                field(Reparto; Rec.Reparto)
                {
                    ApplicationArea = all;
                }
                field("Tipo Recurso"; Rec."Tipo Recurso")
                {
                    ApplicationArea = all;
                }
                field(Tipo; Rec.Tipo)
                {
                    ApplicationArea = all;
                }
                field("Soporte de"; Rec."Soporte de")
                {
                    ApplicationArea = all;
                }
                field("Fija/Papel"; Rec."Fija/Papel")
                {
                    ApplicationArea = all;
                }

            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(TextoenLinea)
            {
                ApplicationArea = ALL;
                ShortCutKey = F10;
                Caption = 'Texto Línea';
                Image = EndingText;
                trigger OnAction()
                BEGIN
                    LlamaTexto;
                END;
            }
        }

    }
    VAR
        Proyecto: Record 167;
        rLinP: Record 1003;
        NoProyActual: Code[20];
        NoProyActualDeshabil: Boolean;
        GestRes: Codeunit "Gestion Reservas";
        Plazos: Page "Plazos recursos reservados";
        rRec: Record 156;
        rLin2: Record 1003;
        rConf: Record 315;
        fTarifas: Page "Gestion tarifas de publicidad";
        Compra: Boolean;
        Linea: Integer;
        StyleIsStrong: Boolean;

    trigger OnNewRecord(BelowxRec: Boolean)
    BEGIN
        if Compra THEN BEGIN
            Rec."Crear pedidos" := Rec."Crear pedidos"::"De Compra";
            Rec."Origin Line No." := Linea;
        END;
    END;

    trigger OnAfterGetRecord()
    var
        rJobPl: Record "Job Planning Line";
    begin

        rJobPl.SETRANGE(rJobPl."Job No.", Rec."Job No.");
        rJobPl.SETRANGE(rJobPl."Origin Line No.", Rec."Line No.");
        rJobPl.SETRANGE(rJobPl."Job Task No.", Rec."Job Task No.");
        rJobPl.SETRANGE(rJobPl."Crear pedidos", rJobPl."Crear pedidos"::"De Compra");
        StyleIsStrong := rJobPl.FINDFIRST();

    end;

    LOCAL PROCEDURE SelecNoProyActual();
    BEGIN
        // {SETRANGE("Nº proyecto",NoProyActual);
        // CurrPage.UPDATE(FALSE);
        // }
    END;

    PROCEDURE LlamaTexto();
    BEGIN
        Rec.FiltroTexto(0);
    END;

    // PROCEDURE CreaReservas();
    // VAR
    //     rLinpd: Record 1003;
    // BEGIN
    //     if NOT CONFIRM('Crear Reservas?') THEN EXIT;
    //     CurrPage.SETSELECTIONFILTER(rLinP);
    //     if rLinP.FIND('-') THEN
    //         REPEAT
    //             if (rLinP."Cdad. a Reservar" <> 0) THEN BEGIN
    //                 GestRes."Crear Reserva"(rLinP, '', 0);
    //             END;
    //             rLinpd.SETRANGE(rLinpd."Job No.", rLinP."Job No.");
    //             rLinpd.SETRANGE(rLinpd."Origin Line No.", rLinP."Line No.");
    //             if rLinP.FIND('-') THEN
    //                 REPEAT
    //                     if (rLinpd."Cdad. a Reservar" <> 0) THEN BEGIN
    //                         GestRes."Crear Reserva"(rLinpd, '', 0);
    //                     END;
    //                 UNTIL rLinpd.NEXT = 0;
    //         UNTIL rLinP.NEXT = 0;

    //     rLin2.INIT;
    //     rLin2.SETRANGE("Job No.", Rec."Job No.");
    //     rLin2.CALCSUMS("Cdad. a Reservar", "Cdad. Reservada");
    //     MESSAGE('Creadas #1######## reservas de un total de #2########\' +
    //             'para todo el proyecto.',
    //             rLin2."Cdad. Reservada", (rLin2."Cdad. Reservada" + rLin2."Cdad. a Reservar"));
    // END;

    PROCEDURE VerReservas();
    VAR
        rReserva: Record Reserva;
    BEGIN
        rReserva.SETCURRENTKEY("Nº Proyecto", "Cód. fase", "Cód. subfase", "Cód. tarea",
                                "Tipo (presupuesto)", "Nº (presupuesto)");
        rReserva.SETRANGE("Nº Proyecto", Rec."Job No.");
        // { $001
        // rReserva.SETRANGE("Cód. fase","Phase Code");
        // rReserva.SETRANGE("Cód. subfase","Task Code");
        // rReserva.SETRANGE("Cód. tarea","Step Code");
        // }
        rReserva.SETRANGE("Cód. tarea", Rec."Job Task No.");
        // $003
        rReserva.SETRANGE("Nº linea proyecto", Rec."Line No.");
        if (Rec.Type = Rec.Type::Resource) THEN BEGIN
            rReserva.SETRANGE("Tipo (presupuesto)", Rec.Type.AsInteger());
            rReserva.SETRANGE("Nº (presupuesto)", Rec."No.");
        END;
        Page.RUNMODAL(Page::"Tabla Reservas", rReserva);
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

    PROCEDURE OrdenesPubli();
    VAR
        rOrden: Record "Cab. orden publicidad";
        rProyecto: Record 167;
        rProv: Record Vendor;
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
            case rProv.Medio Of
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

        Page.RUNMODAL(Page::"Orden de publicidad", rOrden);

        CurrPage.UPDATE;
    END;

    PROCEDURE VerTarifas();
    BEGIN
        CLEAR(fTarifas);
        fTarifas.PasaParam(Rec."Compra a-Nº proveedor");
        fTarifas.RUNMODAL;
    END;

    PROCEDURE FiltrosLinea(FiltroFecIni: Text[30]; FiltroFecFin: Text[30]; FiltroTipo: Text[30]; FiltroSop: Text[30]; FiltroFipa: Text[30]; FiltroSubtipo: Text[30])
    VAR
        rLinProy: Record 1003;
        fLinProy: Page "Consulta líneas proyectoNO SE";
        FiltroFec: Date;
    BEGIN
        //$005

        rLinProy.RESET;

        if FiltroFecIni <> '' THEN BEGIN
            EVALUATE(FiltroFec, FiltroFecIni);
            rLinProy.SETFILTER("Planning Date", '%1', FiltroFec);
        END;

        if FiltroFecFin <> '' THEN BEGIN
            EVALUATE(FiltroFec, FiltroFecFin);
            rLinProy.SETFILTER("Fecha Final", '%1', FiltroFec);
        END;

        if FiltroTipo = 'Por Campaña' THEN
            rLinProy.SETRANGE(Tipo, 0);
        if FiltroTipo = 'Por Temporada' THEN
            rLinProy.SETRANGE(Tipo, 1);
        if FiltroTipo = 'Anual' THEN
            rLinProy.SETRANGE(Tipo, 2);
        if FiltroTipo = 'Otros' THEN
            rLinProy.SETRANGE(Tipo, 3);

        ///if FiltroSop = '' THEN
        ///  rLinProy.SETRANGE("Soporte de",0);
        if FiltroSop = 'Fijación' THEN
            rLinProy.SETRANGE("Soporte de", 1);
        if FiltroSop = 'Vinilo' THEN
            rLinProy.SETRANGE("Soporte de", 2);
        if FiltroSop = 'Pintura' THEN
            rLinProy.SETRANGE("Soporte de", 3);
        if FiltroSop = 'Lona' THEN
            rLinProy.SETRANGE("Soporte de", 4);

        ///if FiltroFipa = '' THEN
        ///  rLinProy.SETRANGE("Fija/Papel",0);
        if FiltroFipa = 'Fija' THEN
            rLinProy.SETRANGE("Fija/Papel", 1);
        if FiltroFipa = 'Papel' THEN
            rLinProy.SETRANGE("Fija/Papel", 2);

        ///if FiltroSubtipo = '' THEN
        ///  rLinProy.SETRANGE(Subtipo,0);
        if FiltroSubtipo = 'Vallas' THEN
            rLinProy.SETRANGE("Subtipo cabecera", 1);
        if FiltroSubtipo = 'Opis' THEN
            rLinProy.SETRANGE("Subtipo cabecera", 2);
        if FiltroSubtipo = 'Combinado' THEN
            rLinProy.SETRANGE("Subtipo cabecera", 3);

        fLinProy.SETTABLEVIEW(rLinProy);
        fLinProy.RUNMODAL;
    END;

    PROCEDURE FiltroCompra(Lin: Integer)
    BEGIN
        Compra := TRUE;
        Linea := Lin;
    END;



}