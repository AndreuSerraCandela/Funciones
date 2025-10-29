/// <summary>
/// Page Orden de Publicidad (ID 50024).
/// </summary>
page 50024 "Orden de Publicidad"
{
    PageType = Card;
    SourceTable = "Cab. orden publicidad";
    PopulateAllFields = true;
    layout
    {
        area(Content)
        {

            field(Duracion; Rec.Duracion)
            {
                ApplicationArea = All;
                Visible = DuracionVisible;
                Editable = DuracionEditable;

            }
            field(Alto; Rec.Alto)
            {
                ApplicationArea = All;
                Visible = AltoVisible;
                Editable = AltoEditable;

                trigger OnValidate()
                BEGIN
                    if Rec.ActualizarLineas(FALSE) THEN
                        CurrPage.SubPage.Page.Actualizar
                    ELSE
                        Rec."Cod. Soporte" := xRec."Cod. Soporte";
                END;
            }
            field(No; Rec.No)
            {
                ApplicationArea = All;
                Editable = NoEditable;
                trigger OnAssistEdit()
                BEGIN
                    if Rec.AssistEdit(xRec) THEN
                        CurrPage.UPDATE;
                END;
            }
            field("No Cliente"; Rec."No cliente")
            {
                Editable = NoclienteEditable;
                ApplicationArea = All;
                trigger OnValidate()
                BEGIN
                    MostrarComentariosCliente;
                    if Rec.ActualizarLineas(FALSE) THEN BEGIN
                        CurrPage.SubPage.Page.Actualizar;
                        Rec.ActualizarClienteLineas;
                    END
                    ELSE
                        //-008
                        Rec.VALIDATE("No cliente", xRec."No cliente");
                    //"No cliente" := xRec."No cliente";
                    //+008
                    ActualizaControles;  // 001
                END;
            }
            field(Nombre; Rec."Nombre cliente")
            {
                ApplicationArea = All;
                Editable = NombreClienteEditable;
            }
            field("Cod. soporte"; rec."Cod. Soporte")
            {
                Editable = CodSoporteEditable;
                ApplicationArea = All;
                trigger OnValidate()
                BEGIN
                    if Rec.ActualizarLineas(TRUE) THEN BEGIN
                        CurrPage.SubPage.Page.Actualizar;
                        CurrPage.SubPageTar.Page.Actualizar;
                    END
                    ELSE
                        Rec."Cod. Soporte" := xRec."Cod. Soporte";
                END;
            }
            field("Nombre Soporte"; Rec."Nombre Soporte")
            {
                ApplicationArea = All;
                Editable = NombreMedioEditable;
            }
            field(Comentado; Rec.Comentado)
            {
                ApplicationArea = all;


            }
            part(SubPage; "SubPage orden de publicidad")
            {
                SubPageLink = "No. orden" = field(No);
                ApplicationArea = All;
                Editable = SubPageEditable;
            }
            part(SubPageTar; "SubPage tarifas orden pub.")
            {
                ApplicationArea = all;
                Editable = SubPageTarEditable;
                Visible = SubPageTarVisible;
                SubPageLink = "Tipo orden" = FIELD("Tipo orden"), No = FIELD(No);
            }
        }

    }
    actions
    {
        area(Navigation)
        {
            action("Co&entarios")
            {
                Image = Comment;
                ApplicationArea = all;
                RunObject = page "Comentario orden publicidad";
                RunPageLink = "Tipo orden" = FIELD("Tipo orden"),
                                        "No." = FIELD(No);
            }
            action(List)
            {
                Image = List;

                //PushAction=LookupTable;
                ShortCutKey = F5;
                ApplicationArea = ALL;
                Caption = 'Lista';
                trigger OnAction()
                var
                    myInt: Integer;
                begin
                    Page.RunModal(0, Rec);
                end;

            }
            action("Ordenes abiertas")
            {
                ApplicationArea = All;
                Image = OpenJournal;
                Caption = 'Ordenes abiertas';
                trigger OnAction()
                BEGIN

                    Rec.FILTERGROUP(3);
                    Rec.SETRANGE(Estado, Rec.Estado::Abierta);
                    Rec.FILTERGROUP(0);
                    CurrPage.UPDATE;
                    CurrPage.Subpage.Page.Actualizar;
                END;

            }



        }
        area(Processing)
        {
            action(Generar)
            {
                Applicationarea = All;
                Caption = 'Generar';
                trigger OnAction()
                BEGIN

                    Rec.TESTFIELD("No cliente");
                    Rec.TESTFIELD("Cod. Soporte");

                    if wFechaIni = 0D THEN
                        ERROR(Err03);
                    if wFechaFin = 0D THEN
                        ERROR(Err04);
                    if wFechaIni > wFechaFin THEN
                        ERROR(Err05);


                    InsertarDiasOrden(wImporteManual <> 0);
                    GenerarLineas;
                    CurrPage.Subpage.page.Actualizar;
                    //CurrForm.FechaIni.ACTIVATE;
                END;
            }
            // action(Factura)
            // {
            //     applicationarea = All;
            //     Image = Post;
            //     Visible = false;
            //     Caption = 'Facturar';
            //     trigger OnAction()
            //     BEGIN
            //         Facturar;
            //     END;
            // }
            action(Valida)
            {
                ApplicationArea = all;
                ShortCutKey = F9;
                Image = Check;
                Caption = '&Validar';
                trigger OnAction()
                BEGIN
                    Validar;
                END;
            }
            action(DesValida)
            {
                ApplicationArea = all;
                ShortCutKey = 'Mayús+F9';
                Image = Check;
                Caption = '&Des Validar';
                trigger OnAction()
                BEGIN
                    DesValidar;
                END;
            }

        }



        // area(Reporting)
        // {
        //     action(Print)
        //     {
        //         ApplicationArea = ALL;
        //         Caption = '&Imprimir';
        //         trigger OnAction()
        //         BEGIN
        //             ImprimirOrden(TRUE);
        //         END;
        //     }
        // }
    }

    var
        SeccionVisible: Boolean;
        TextoSeccionVisible: Boolean;
        AltoVisible: Boolean;
        AnchoVisible: Boolean;
        RecargoVisible: Boolean;
        SubPageTarVisible: Boolean;
        SubPageTarEditable: Boolean;
        ImportegrabacionVisible: Boolean;
        ImporterealizacionVisible: Boolean;
        ImporteCuñaVisible: Boolean;
        ImporteTotalVisible: Boolean;

        ImporteLineasVisible: Boolean;
        DuracionVisible: Boolean;

        Bot_Menu_ValVisible: Boolean;
        Bot_Menu_DesVisible: Boolean;
        Bot_Ordenes_ValVisible: Boolean;
        Bot_Ordenes_DesVisible: Boolean;

        Bot_ImpENABLED: Boolean;

        NoEditable: Boolean;
        CodvendedorEditable: Boolean;
        NoclienteEditable: Boolean;
        NombreClienteEditable: Boolean;
        CIFClienteEditable: Boolean;
        FechacreacionEditable: Boolean;

        CodSoporteEditable: Boolean;
        NombreMedioEditable: Boolean;
        TipoordenEditable: Boolean;
        DescripcionEditable: Boolean;
        CampañaEditable: Boolean;
        AltoEditable: Boolean;
        AnchoEditable: Boolean;
        ConceptoEditable: Boolean;
        TextoConceptoEditable: Boolean;
        RecargoEditable: Boolean;
        SeccionEditable: Boolean;
        TextoSeccionEditable: Boolean;
        DuracionEditable: Boolean;
        ImporterealizacionEditable: Boolean;
        ImportegrabacionEditable: Boolean;
        SubPageEditable: Boolean;
        FechaIniEditable: Boolean;
        FechaFinEditable: Boolean;
        ImporteManualEditable: Boolean;
        TextoEditable: Boolean;
        Bot_generarENABLED: Boolean;
        rOrdenes: Record "Cab. orden publicidad";
        rConfig: Record "Jobs Setup";
        cCal: Codeunit "Funciones calendario";
        wIniciarCalendario: Boolean;
        wDias: array[38, 2] of Integer;
        wFechaSelec: Date;
        wMeses: array[2] of Option Enero,Febrero,Marzo,Abril,Mayo,Junio,Julio,Agosto,Septiembre,Octubre,Noviembre,Diciembre;
        wAños: array[2] of Integer;
        wValor: Boolean;
        wFechaIni: Date;
        wFechaFin: Date;
        wImporteManual: Decimal;
        wMarcarPeriodo: Option No,Si;
        wImporteTotal: Decimal;
        wCapConcepto: Text[30];
        wImpConcepto: Decimal;
        i: Integer;
        wImporteExtra: Decimal;
        MarcadorVISIBLE: Boolean;
        rDiasSel: Record "Dias orden publicidad";
        rLinOrden: Record "Lin. orden publicidad";
        Txt01: Label '¿Desea validar la orden de publicidad y trasladar los importes a la linea del proyecto?';
        Txt02: Label 'Desea recalcular las lineas?';
        Txt03: Label 'Desea desvalidar la orden de publicidad?';
        Txt04: Label 'Desea imprimir la orden de publicidad?';
        Txt05: Label 'Orden de publicidad';
        Txt06: Label 'Orden de publicidad validada';
        Txt07: Label 'Desea modificar ahora la orden de publicidad?';
        Err01: Label 'No hay lineas que registrar.';
        Err03: Label 'Debe introducir una fecha de inicio correcta.';
        Err04: Label 'Debe introducir una fecha de fin correcta.';
        Err05: Label 'La fecha de incio no debe ser mayor que la fecha de fin.';
        Err06: Label 'Ya existe una linea que contiene el día %1.';
        Err07: Label 'No es posible crear nuevas ordenes en este formulario.';
        Err08: Label 'El importe de la orden no puede ser 0.';
        Err09: Label 'La orden de publicidad no puede tener Tarifas diferentes.';
    //wEstado:	Option	

    trigger OnOpenPage()
    BEGIN

        rConfig.GET;

        cCal.IniciarCalendario(WORKDATE, wDias, wMeses, wAños);
        cCal.RellenarDias(wDias, wMeses, wAños);
        MueveMarcadorDiaActual;

        //-002
        wIniciarCalendario := TRUE;
    END;

    trigger OnAfterGetRecord()
    BEGIN
        ActualizaControles;
        //  CurrPage.UPDATE(false);

        //-002
        if wIniciarCalendario AND (Rec.Estado = Rec.Estado::Validada) THEN BEGIN
            cCal.IniciarCalendario(TraerFechaReferencia, wDias, wMeses, wAños);
            cCal.RellenarDias(wDias, wMeses, wAños);
            MueveMarcadorDiaActual;
            ActualizaControles;
        END
        ELSE
            wIniciarCalendario := TRUE;
        //+002


        //-003
        // {
        // if "Cod delegacion" = '' THEN BEGIN
        //     recUsuxDel.RESET;
        //     recUsuxDel.SETRANGE(recUsuxDel."Cod usuario", USERID);
        //     recUsuxDel.SETRANGE(recUsuxDel."Delegacion defecto", TRUE);
        //     if recUsuxDel.FIND('-') THEN BEGIN
        //     "Cod delegacion" := recUsuxDel."Cod delegacion";
        //     END;
        // END;
        // }
        //+003
    END;

    trigger OnNewRecord(BelowRec: Boolean)
    BEGIN
        ActualizaControles;
    END;

    trigger OnInsertRecord(BelowRec: Boolean): Boolean
    BEGIN

        ActualizaControles;
        // {
        // FILTERGROUP(3);
        //     if GETFILTER(Estado) <> '' THEN
        //     if (GETFILTER(Estado) <> PageAT(Estado)) THEN
        //     BEGIN
        //         FILTERGROUP(2);
        //         ERROR(Err07);
        //     END;
        // FILTERGROUP(2);
        // }
    END;

    /// <summary>
    /// ActualizaControles.
    /// </summary>
    procedure ActualizaControles()
    Begin
        // Dependiendo del tipo de orden se muestran unos controles u otros.

        SeccionVisible := Rec."Tipo orden" = Rec."Tipo orden"::Prensa;
        TextoSeccionVisible := Rec."Tipo orden" = Rec."Tipo orden"::Prensa;
        AltoVisible := Rec."Tipo orden" = Rec."Tipo orden"::Prensa;
        AnchoVisible := Rec."Tipo orden" = Rec."Tipo orden"::Prensa;
        RecargoVisible := Rec."Tipo orden" = Rec."Tipo orden"::Prensa;

        SubPageTarVisible := (Rec."Tipo orden" = Rec."Tipo orden"::Prensa);
        CASE Rec."Tipo orden" OF
            Rec."Tipo orden"::Prensa:
                SubPageTarEditable := (Rec.Concepto = rConfig."Tarifa manual prensa") AND (Rec.Estado = Rec.Estado::Abierta);
            Rec."Tipo orden"::Radio:
                SubPageTarEditable := (Rec.Concepto = rConfig."Tarifa manual radio") AND (Rec.Estado = Rec.Estado::Abierta);
            Rec."Tipo orden"::Audiovisuales:
                SubPageTarEditable := (Rec.Concepto = rConfig."Tarifa manual cine") AND (Rec.Estado = Rec.Estado::Abierta);
        END;
        ImportegrabacionVisible := FALSE;
        ImporterealizacionVisible := FALSE;
        ImporteCuñaVisible := FALSE;
        ImporteTotalVisible := Rec."Tipo orden" = Rec."Tipo orden"::Radio;

        ImporteLineasVisible := Rec."Tipo orden" <> Rec."Tipo orden"::Radio;
        DuracionVisible := Rec."Tipo orden" <> Rec."Tipo orden"::Prensa;

        Bot_Menu_ValVisible := (Rec.Estado = Rec.Estado::Abierta);
        Bot_Menu_DesVisible := (Rec.Estado = Rec.Estado::Validada);
        Bot_Ordenes_ValVisible := (Rec.Estado = Rec.Estado::Abierta);
        Bot_Ordenes_DesVisible := (Rec.Estado = Rec.Estado::Validada);

        Bot_ImpENABLED := (Rec.Estado = Rec.Estado::Validada);

        CurrPage.SubPage.Page.ActualizarControles(Rec."Tipo orden".AsInteger);

        // Bot_sem_1_6Visible := wDias[36][1] <> 0;
        // Bot_sem_2_6Visible := wDias[36][2] <> 0;

        // Si la orden esta validada no se puede modificar.

        NoEditable := (Rec.Estado = Rec.Estado::Abierta);
        CodvendedorEditable := (Rec.Estado = Rec.Estado::Abierta);
        NoclienteEditable := (Rec.Estado = Rec.Estado::Abierta);
        NombreClienteEditable := (Rec.Estado = Rec.Estado::Abierta);
        CIFClienteEditable := (Rec.Estado = Rec.Estado::Abierta);
        FechacreacionEditable := (Rec.Estado = Rec.Estado::Abierta);

        CodSoporteEditable := (Rec.Estado = Rec.Estado::Abierta);
        NombreMedioEditable := (Rec.Estado = Rec.Estado::Abierta);
        TipoordenEditable := (Rec.Estado = Rec.Estado::Abierta) AND NOT rOrdenes.GET(Rec.No);
        DescripcionEditable := (Rec.Estado = Rec.Estado::Abierta);
        CampañaEditable := (Rec.Estado = Rec.Estado::Abierta);
        AltoEditable := (Rec.Estado = Rec.Estado::Abierta);
        AnchoEditable := (Rec.Estado = Rec.Estado::Abierta);
        ConceptoEditable := (Rec.Estado = Rec.Estado::Abierta);
        TextoConceptoEditable := (Rec.Estado = Rec.Estado::Abierta);
        RecargoEditable := (Rec.Estado = Rec.Estado::Abierta);
        SeccionEditable := (Rec.Estado = Rec.Estado::Abierta);
        TextoSeccionEditable := (Rec.Estado = Rec.Estado::Abierta);
        DuracionEditable := (Rec.Estado = Rec.Estado::Abierta);
        ImporterealizacionEditable := (Rec.Estado = Rec.Estado::Abierta);
        ImportegrabacionEditable := (Rec.Estado = Rec.Estado::Abierta);
        SubPageEditable := (Rec.Estado = Rec.Estado::Abierta);
        FechaIniEditable := (Rec.Estado = Rec.Estado::Abierta);
        FechaFinEditable := (Rec.Estado = Rec.Estado::Abierta);
        ImporteManualEditable := (Rec.Estado = Rec.Estado::Abierta);
        TextoEditable := (Rec.Estado = Rec.Estado::Abierta);
        Bot_generarENABLED := (Rec.Estado = Rec.Estado::Abierta);

        //if Rec.Estado = Rec.Estado::Abierta THEN
        //CAPTION := Txt05
        //ELSE
        //CAPTION := Txt06;
    end;

    PROCEDURE MueveMarcadorDiaActual();
    VAR
        wFila: Integer;
        wCol: Integer;
        wDia: Integer;
        y: Integer;
        x: Integer;
        i: Integer;
    BEGIN
        // Mover el marcador de la semana actual

        MarcadorVISIBLE := FALSE;

        if (wMeses[1] + 1 = DATE2DMY(WORKDATE, 2)) AND (wAños[1] = DATE2DMY(WORKDATE, 3)) THEN BEGIN

            FOR i := 1 TO ARRAYLEN(wDias, 1) DO
                if wDias[i] [1] = DATE2DMY(WORKDATE, 1) THEN
                    wDia := i;

            wFila := ((wDia - 1) DIV 7) + 1;
            wCol := wDia - ((wFila - 1) * 7);

            //   CASE wFila OF
            //     1: y := CurrPage.day1.YPOS;
            //     2: y := CurrPage.day8.YPOS;
            //     3: y := CurrPage.day15.YPOS;
            //     4: y := CurrPage.day22.YPOS;
            //     5: y := CurrPage.day29.YPOS;
            //     6: y := CurrPage.day36.YPOS;
            //   END;

            //   CASE wCol OF
            //     1: x := CurrPage.day1.XPOS;
            //     2: x := CurrPage.day2.XPOS;
            //     3: x := CurrPage.day3.XPOS;
            //     4: x := CurrPage.day4.XPOS;
            //     5: x := CurrPage.day5.XPOS;
            //     6: x := CurrPage.day6.XPOS;
            //     7: x := CurrPage.day6.XPOS;
            //   END;

            //   CurrPage.Marcador.VISIBLE:= TRUE;
            //   CurrPage.Marcador.XPOS := x;
            //   CurrPage.Marcador.YPOS := y;

            // END
            // ELSE
            //   if (wMeses[2]+1 = DATE2DMY(WORKDATE,2)) THEN
            //   BEGIN

            //     FOR i := 1 TO ARRAYLEN(wDias,1) DO
            //       if wDias[i][2] = DATE2DMY(WORKDATE,1) THEN
            //         wDia := i;

            //     wFila := ((wDia-1) DIV 7) + 1;
            //     wCol := wDia - ((wFila-1) * 7);

            //     CASE wFila OF
            //       1: y := CurrPage.day1_2.YPOS;
            //       2: y := CurrPage.day8_2.YPOS;
            //       3: y := CurrPage.day15_2.YPOS;
            //       4: y := CurrPage.day22_2.YPOS;
            //       5: y := CurrPage.day29_2.YPOS;
            //       6: y := CurrPage.day36_2.YPOS;
            //     END;

            //     CASE wCol OF
            //       1: x := CurrPage.day1_2.XPOS;
            //       2: x := CurrPage.day2_2.XPOS;
            //       3: x := CurrPage.day3_2.XPOS;
            //       4: x := CurrPage.day4_2.XPOS;
            //       5: x := CurrPage.day5_2.XPOS;
            //       6: x := CurrPage.day6_2.XPOS;
            //       7: x := CurrPage.day6_2.XPOS;
            //     END;

            //     CurrPage.Marcador.VISIBLE:= TRUE;
            //     CurrPage.Marcador.XPOS := x;
            //     CurrPage.Marcador.YPOS := y;

        END;
    END;


    PROCEDURE Pageato(pPos: Integer; pMes: Integer)
    VAR
        wFechaSel: Date;
        wSeleccionado: Boolean;
    BEGIN


        if wDias[pPos] [pMes] <> 0 THEN BEGIN
            wFechaSel := DMY2DATE(wDias[pPos] [pMes], wMeses[pMes] + 1, wAños[pMes]);
            wSeleccionado := rDiasSel.GET(Rec."Tipo orden", Rec.No, wFechaSel);
        END
        ELSE
            wSeleccionado := FALSE;

        // CASE pMes OF
        //   1 :
        //   BEGIN
        //     CASE pPos OF
        //       1 :
        //       BEGIN
        //         CurrPage.day1.UPDATEFONTBOLD(wSeleccionado);
        //         CurrPage.day1.UPDATESELECTED(wSeleccionado);
        //       END;
        //       2 :
        //       BEGIN
        //         CurrPage.day2.UPDATEFONTBOLD(wSeleccionado);
        //         CurrPage.day2.UPDATESELECTED(wSeleccionado);
        //       END;
        //       3 :
        //       BEGIN
        //         CurrPage.day3.UPDATEFONTBOLD(wSeleccionado);
        //         CurrPage.day3.UPDATESELECTED(wSeleccionado);
        //       END;
        //       4 :
        //       BEGIN
        //         CurrPage.day4.UPDATEFONTBOLD(wSeleccionado);
        //         CurrPage.day4.UPDATESELECTED(wSeleccionado);
        //       END;
        //       5 :
        //       BEGIN
        //         CurrPage.day5.UPDATEFONTBOLD(wSeleccionado);
        //         CurrPage.day5.UPDATESELECTED(wSeleccionado);
        //       END;
        //       6 :
        //       BEGIN
        //         CurrPage.day6.UPDATEFONTBOLD(wSeleccionado);
        //         CurrPage.day6.UPDATESELECTED(wSeleccionado);
        //       END;
        //       7 :
        //       BEGIN
        //         CurrPage.day7.UPDATEFONTBOLD(wSeleccionado);
        //         CurrPage.day7.UPDATESELECTED(wSeleccionado);
        //       END;
        //       8 :
        //       BEGIN
        //         CurrPage.day8.UPDATEFONTBOLD(wSeleccionado);
        //         CurrPage.day8.UPDATESELECTED(wSeleccionado);
        //       END;
        //       9 :
        //       BEGIN
        //         CurrPage.day9.UPDATEFONTBOLD(wSeleccionado);
        //         CurrPage.day9.UPDATESELECTED(wSeleccionado);
        //       END;
        //       10 :
        //       BEGIN
        //         CurrPage.day10.UPDATEFONTBOLD(wSeleccionado);
        //         CurrPage.day10.UPDATESELECTED(wSeleccionado);
        //       END;
        //       11 :
        //       BEGIN
        //         CurrPage.day11.UPDATEFONTBOLD(wSeleccionado);
        //         CurrPage.day11.UPDATESELECTED(wSeleccionado);
        //       END;
        //       12 :
        //       BEGIN
        //         CurrPage.day12.UPDATEFONTBOLD(wSeleccionado);
        //         CurrPage.day12.UPDATESELECTED(wSeleccionado);
        //       END;
        //       13 :
        //       BEGIN
        //         CurrPage.day13.UPDATEFONTBOLD(wSeleccionado);
        //         CurrPage.day13.UPDATESELECTED(wSeleccionado);
        //       END;
        //       14 :
        //       BEGIN
        //         CurrPage.day14.UPDATEFONTBOLD(wSeleccionado);
        //         CurrPage.day14.UPDATESELECTED(wSeleccionado);
        //       END;
        //       15 :
        //       BEGIN
        //         CurrPage.day15.UPDATEFONTBOLD(wSeleccionado);
        //         CurrPage.day15.UPDATESELECTED(wSeleccionado);
        //       END;
        //       16 :
        //       BEGIN
        //         CurrPage.day16.UPDATEFONTBOLD(wSeleccionado);
        //         CurrPage.day16.UPDATESELECTED(wSeleccionado);
        //       END;
        //       17 :
        //       BEGIN
        //         CurrPage.day17.UPDATEFONTBOLD(wSeleccionado);
        //         CurrPage.day17.UPDATESELECTED(wSeleccionado);
        //       END;
        //       18 :
        //       BEGIN
        //         CurrPage.day18.UPDATEFONTBOLD(wSeleccionado);
        //         CurrPage.day18.UPDATESELECTED(wSeleccionado);
        //       END;
        //       19 :
        //       BEGIN
        //         CurrPage.day19.UPDATEFONTBOLD(wSeleccionado);
        //         CurrPage.day19.UPDATESELECTED(wSeleccionado);
        //       END;
        //       20 :
        //       BEGIN
        //         CurrPage.day20.UPDATEFONTBOLD(wSeleccionado);
        //         CurrPage.day20.UPDATESELECTED(wSeleccionado);
        //       END;
        //       21 :
        //       BEGIN
        //         CurrPage.day21.UPDATEFONTBOLD(wSeleccionado);
        //         CurrPage.day21.UPDATESELECTED(wSeleccionado);
        //       END;
        //       22 :
        //       BEGIN
        //         CurrPage.day22.UPDATEFONTBOLD(wSeleccionado);
        //         CurrPage.day22.UPDATESELECTED(wSeleccionado);
        //       END;
        //       23 :
        //       BEGIN
        //         CurrPage.day23.UPDATEFONTBOLD(wSeleccionado);
        //         CurrPage.day23.UPDATESELECTED(wSeleccionado);
        //       END;
        //       24 :
        //       BEGIN
        //         CurrPage.day24.UPDATEFONTBOLD(wSeleccionado);
        //         CurrPage.day24.UPDATESELECTED(wSeleccionado);
        //       END;
        //       25 :
        //       BEGIN
        //         CurrPage.day25.UPDATEFONTBOLD(wSeleccionado);
        //         CurrPage.day25.UPDATESELECTED(wSeleccionado);
        //       END;
        //       26 :
        //       BEGIN
        //         CurrPage.day26.UPDATEFONTBOLD(wSeleccionado);
        //         CurrPage.day26.UPDATESELECTED(wSeleccionado);
        //       END;
        //       27 :
        //       BEGIN
        //         CurrPage.day27.UPDATEFONTBOLD(wSeleccionado);
        //         CurrPage.day27.UPDATESELECTED(wSeleccionado);
        //       END;
        //       28 :
        //       BEGIN
        //         CurrPage.day28.UPDATEFONTBOLD(wSeleccionado);
        //         CurrPage.day28.UPDATESELECTED(wSeleccionado);
        //       END;
        //       29 :
        //       BEGIN
        //         CurrPage.day29.UPDATEFONTBOLD(wSeleccionado);
        //         CurrPage.day29.UPDATESELECTED(wSeleccionado);
        //       END;
        //       30 :
        //       BEGIN
        //         CurrPage.day30.UPDATEFONTBOLD(wSeleccionado);
        //         CurrPage.day30.UPDATESELECTED(wSeleccionado);
        //       END;
        //       31 :
        //       BEGIN
        //         CurrPage.day31.UPDATEFONTBOLD(wSeleccionado);
        //         CurrPage.day31.UPDATESELECTED(wSeleccionado);
        //       END;
        //       32 :
        //       BEGIN
        //         CurrPage.day32.UPDATEFONTBOLD(wSeleccionado);
        //         CurrPage.day32.UPDATESELECTED(wSeleccionado);
        //       END;
        //       33 :
        //       BEGIN
        //         CurrPage.day33.UPDATEFONTBOLD(wSeleccionado);
        //         CurrPage.day33.UPDATESELECTED(wSeleccionado);
        //       END;
        //       34 :
        //       BEGIN
        //         CurrPage.day34.UPDATEFONTBOLD(wSeleccionado);
        //         CurrPage.day34.UPDATESELECTED(wSeleccionado);
        //       END;
        //       35 :
        //       BEGIN
        //         CurrPage.day35.UPDATEFONTBOLD(wSeleccionado);
        //         CurrPage.day35.UPDATESELECTED(wSeleccionado);
        //       END;
        //       36 :
        //       BEGIN
        //         CurrPage.day36.UPDATEFONTBOLD(wSeleccionado);
        //         CurrPage.day36.UPDATESELECTED(wSeleccionado);
        //       END;
        //       37 :
        //       BEGIN
        //         CurrPage.day37.UPDATEFONTBOLD(wSeleccionado);
        //         CurrPage.day37.UPDATESELECTED(wSeleccionado);
        //       END;
        //     END;
        //   END;
        //   2 :
        //   BEGIN
        //     CASE pPos OF
        //       1 :
        //       BEGIN
        //         CurrPage.day1_2.UPDATEFONTBOLD(wSeleccionado);
        //         CurrPage.day1_2.UPDATESELECTED(wSeleccionado);
        //       END;
        //       2 :
        //       BEGIN
        //         CurrPage.day2_2.UPDATEFONTBOLD(wSeleccionado);
        //         CurrPage.day2_2.UPDATESELECTED(wSeleccionado);
        //       END;
        //       3 :
        //       BEGIN
        //         CurrPage.day3_2.UPDATEFONTBOLD(wSeleccionado);
        //         CurrPage.day3_2.UPDATESELECTED(wSeleccionado);
        //       END;
        //       4 :
        //       BEGIN
        //         CurrPage.day4_2.UPDATEFONTBOLD(wSeleccionado);
        //         CurrPage.day4_2.UPDATESELECTED(wSeleccionado);
        //       END;
        //       5 :
        //       BEGIN
        //         CurrPage.day5_2.UPDATEFONTBOLD(wSeleccionado);
        //         CurrPage.day5_2.UPDATESELECTED(wSeleccionado);
        //       END;
        //       6 :
        //       BEGIN
        //         CurrPage.day6_2.UPDATEFONTBOLD(wSeleccionado);
        //         CurrPage.day6_2.UPDATESELECTED(wSeleccionado);
        //       END;
        //       7 :
        //       BEGIN
        //         CurrPage.day7_2.UPDATEFONTBOLD(wSeleccionado);
        //         CurrPage.day7_2.UPDATESELECTED(wSeleccionado);
        //       END;
        //       8 :
        //       BEGIN
        //         CurrPage.day8_2.UPDATEFONTBOLD(wSeleccionado);
        //         CurrPage.day8_2.UPDATESELECTED(wSeleccionado);
        //       END;
        //       9 :
        //       BEGIN
        //         CurrPage.day9_2.UPDATEFONTBOLD(wSeleccionado);
        //         CurrPage.day9_2.UPDATESELECTED(wSeleccionado);
        //       END;
        //       10 :
        //       BEGIN
        //         CurrPage.day10_2.UPDATEFONTBOLD(wSeleccionado);
        //         CurrPage.day10_2.UPDATESELECTED(wSeleccionado);
        //       END;
        //       11 :
        //       BEGIN
        //         CurrPage.day11_2.UPDATEFONTBOLD(wSeleccionado);
        //         CurrPage.day11_2.UPDATESELECTED(wSeleccionado);
        //       END;
        //       12 :
        //       BEGIN
        //         CurrPage.day12_2.UPDATEFONTBOLD(wSeleccionado);
        //         CurrPage.day12_2.UPDATESELECTED(wSeleccionado);
        //       END;
        //       13 :
        //       BEGIN
        //         CurrPage.day13_2.UPDATEFONTBOLD(wSeleccionado);
        //         CurrPage.day13_2.UPDATESELECTED(wSeleccionado);
        //       END;
        //       14 :
        //       BEGIN
        //         CurrPage.day14_2.UPDATEFONTBOLD(wSeleccionado);
        //         CurrPage.day14_2.UPDATESELECTED(wSeleccionado);
        //       END;
        //       15 :
        //       BEGIN
        //         CurrPage.day15_2.UPDATEFONTBOLD(wSeleccionado);
        //         CurrPage.day15_2.UPDATESELECTED(wSeleccionado);
        //       END;
        //       16 :
        //       BEGIN
        //         CurrPage.day16_2.UPDATEFONTBOLD(wSeleccionado);
        //         CurrPage.day16_2.UPDATESELECTED(wSeleccionado);
        //       END;
        //       17 :
        //       BEGIN
        //         CurrPage.day17_2.UPDATEFONTBOLD(wSeleccionado);
        //         CurrPage.day17_2.UPDATESELECTED(wSeleccionado);
        //       END;
        //       18 :
        //       BEGIN
        //         CurrPage.day18_2.UPDATEFONTBOLD(wSeleccionado);
        //         CurrPage.day18_2.UPDATESELECTED(wSeleccionado);
        //       END;
        //       19 :
        //       BEGIN
        //         CurrPage.day19_2.UPDATEFONTBOLD(wSeleccionado);
        //         CurrPage.day19_2.UPDATESELECTED(wSeleccionado);
        //       END;
        //       20 :
        //       BEGIN
        //         CurrPage.day20_2.UPDATEFONTBOLD(wSeleccionado);
        //         CurrPage.day20_2.UPDATESELECTED(wSeleccionado);
        //       END;
        //       21 :
        //       BEGIN
        //         CurrPage.day21_2.UPDATEFONTBOLD(wSeleccionado);
        //         CurrPage.day21_2.UPDATESELECTED(wSeleccionado);
        //       END;
        //       22 :
        //       BEGIN
        //         CurrPage.day22_2.UPDATEFONTBOLD(wSeleccionado);
        //         CurrPage.day22_2.UPDATESELECTED(wSeleccionado);
        //       END;
        //       23 :
        //       BEGIN
        //         CurrPage.day23_2.UPDATEFONTBOLD(wSeleccionado);
        //         CurrPage.day23_2.UPDATESELECTED(wSeleccionado);
        //       END;
        //       24 :
        //       BEGIN
        //         CurrPage.day24_2.UPDATEFONTBOLD(wSeleccionado);
        //         CurrPage.day24_2.UPDATESELECTED(wSeleccionado);
        //       END;
        //       25 :
        //       BEGIN
        //         CurrPage.day25_2.UPDATEFONTBOLD(wSeleccionado);
        //         CurrPage.day25_2.UPDATESELECTED(wSeleccionado);
        //       END;
        //       26 :
        //       BEGIN
        //         CurrPage.day26_2.UPDATEFONTBOLD(wSeleccionado);
        //         CurrPage.day26_2.UPDATESELECTED(wSeleccionado);
        //       END;
        //       27 :
        //       BEGIN
        //         CurrPage.day27_2.UPDATEFONTBOLD(wSeleccionado);
        //         CurrPage.day27_2.UPDATESELECTED(wSeleccionado);
        //       END;
        //       28 :
        //       BEGIN
        //         CurrPage.day28_2.UPDATEFONTBOLD(wSeleccionado);
        //         CurrPage.day28_2.UPDATESELECTED(wSeleccionado);
        //       END;
        //       29 :
        //       BEGIN
        //         CurrPage.day29_2.UPDATEFONTBOLD(wSeleccionado);
        //         CurrPage.day29_2.UPDATESELECTED(wSeleccionado);
        //       END;
        //       30 :
        //       BEGIN
        //         CurrPage.day30_2.UPDATEFONTBOLD(wSeleccionado);
        //         CurrPage.day30_2.UPDATESELECTED(wSeleccionado);
        //       END;
        //       31 :
        //       BEGIN
        //         CurrPage.day31_2.UPDATEFONTBOLD(wSeleccionado);
        //         CurrPage.day31_2.UPDATESELECTED(wSeleccionado);
        //       END;
        //       32 :
        //       BEGIN
        //         CurrPage.day32_2.UPDATEFONTBOLD(wSeleccionado);
        //         CurrPage.day32_2.UPDATESELECTED(wSeleccionado);
        //       END;
        //       33 :
        //       BEGIN
        //         CurrPage.day33_2.UPDATEFONTBOLD(wSeleccionado);
        //         CurrPage.day33_2.UPDATESELECTED(wSeleccionado);
        //       END;
        //       34 :
        //       BEGIN
        //         CurrPage.day34_2.UPDATEFONTBOLD(wSeleccionado);
        //         CurrPage.day34_2.UPDATESELECTED(wSeleccionado);
        //       END;
        //       35 :
        //       BEGIN
        //         CurrPage.day35_2.UPDATEFONTBOLD(wSeleccionado);
        //         CurrPage.day35_2.UPDATESELECTED(wSeleccionado);
        //       END;
        //       36 :
        //       BEGIN
        //         CurrPage.day36_2.UPDATEFONTBOLD(wSeleccionado);
        //         CurrPage.day36_2.UPDATESELECTED(wSeleccionado);
        //       END;
        //       37 :
        //       BEGIN
        //         CurrPage.day37_2.UPDATEFONTBOLD(wSeleccionado);
        //         CurrPage.day37_2.UPDATESELECTED(wSeleccionado);
        //       END;
        //     END;
        //   END;
        // END;
    END;

    PROCEDURE GenerarLineas();
    VAR
        rDiasOrden: Record "Dias orden publicidad";
        rLinTarifas: Record "Price List Line";
        rDiasTar: Record "Dias tarifa publicidad";
        wImporte: Decimal;
        wAntLinOrden: Integer;
        wAntDiaTarifa: Code[20];
        wDiaSemana: Integer;
        wCodDiaTar: Code[10];
        wImporteTotal: Decimal;
        cMedios: codeunit "Gestion medios";
    BEGIN

        //  cMedios.GenerarLineasOrden(Rec,wFechaIni,wFechaFin,wImporteManual);
        cMedios.GenerarLineasOrden(Rec, wFechaIni, wFechaFin, wImporteManual);
    END;

    PROCEDURE BorrarLineas();
    BEGIN

        rLinOrden.RESET;
        rLinOrden.SETRANGE(rLinOrden."Tipo orden", Rec."Tipo orden");
        rLinOrden.SETRANGE(rLinOrden."No. orden", Rec.No);
        if rLinOrden.FIND('-') THEN
            rLinOrden.DELETEALL;
    END;

    PROCEDURE InsertarDiasOrden(pPeriodo: Boolean);
    VAR
        wFecha: Date;
    BEGIN

        FOR wFecha := wFechaIni TO wFechaFin DO BEGIN
            if NOT rDiasSel.GET(Rec."Tipo orden", Rec.No, wFecha) THEN BEGIN
                rDiasSel.INIT;
                rDiasSel."Tipo orden" := Rec."Tipo orden";
                rDiasSel."No. orden" := Rec.No;
                rDiasSel.VALIDATE(Dia, wFecha);
                if pPeriodo AND (wFechaIni <> wFechaFin) THEN BEGIN
                    rDiasSel.Periodo := TRUE;
                    rDiasSel."Inicio periodo" := wFechaIni;
                    rDiasSel."Fin periodo" := wFechaFin;
                END;
                rDiasSel.INSERT;
            END
            ELSE
                ERROR(Err06, wFecha);
        END;
    END;

    PROCEDURE MostrarComentariosCliente();
    VAR
        rComentarios: Record 97;
        fComentarios: Page 124;
        wTablas: Option Cuenta,Cliente,Proveedor,Producto,Recurso,Proyecto,,"Familia recurso",Banco,Campaña,"Activo Fijo",Seguro,"Pdto sin exist.";
    BEGIN

        rComentarios.RESET;
        rComentarios.SETRANGE("Table Name", wTablas::Cliente);
        rComentarios.SETRANGE("No.", Rec."No cliente");
        if rComentarios.FIND('-') THEN BEGIN
            CLEAR(fComentarios);
            fComentarios.EDITABLE := FALSE;
            fComentarios.LOOKUPMODE := TRUE;
            fComentarios.SETTABLEVIEW(rComentarios);
            fComentarios.RUNMODAL;
        END;
    END;

    PROCEDURE Validar();
    VAR
        rLinPresup: Record 1003;
        wImprimir: Boolean;
        wPrecioTotal: Decimal;
    BEGIN
        if CONFIRM(Txt01, TRUE) THEN BEGIN

            rLinOrden.RESET;
            rLinOrden.SETRANGE("Tipo orden", Rec."Tipo orden");
            rLinOrden.SETRANGE("No. orden", Rec.No);
            if NOT rLinOrden.FIND('-') THEN
                ERROR(Err01)
            ELSE BEGIN                                  // -007
                REPEAT
                    rLinOrden.TESTFIELD("Fecha inicio");
                    rLinOrden.TESTFIELD("Fecha fin");
                    //-008
                    if rLinOrden."No cliente" <> Rec."No cliente" THEN BEGIN
                        rLinOrden."No cliente" := Rec."No cliente";
                        rLinOrden.MODIFY;
                    END;
                //+008
                UNTIL rLinOrden.NEXT = 0;
            END;                                        // +007

            //-003
            //   {
            //   CALCFIELDS(Importe);
            //   CASE "Tipo orden" OF
            //     "Tipo orden"::Prensa : if Importe = 0 THEN ERROR(Err08);
            //     "Tipo orden"::Radio  : if (Importe + "Importe grabacion" + "Importe realizacion") = 0 THEN ERROR(Err08);
            //     "Tipo orden"::Prensa : if Importe = 0 THEN ERROR(Err08);
            //   END;
            //   }
            //+003

            Rec.Estado := Rec.Estado::Validada;
            Rec.MODIFY;

            CLEAR(rLinPresup);
            if rLinPresup.GET(Rec."Nº proyecto", Rec."Nº tarea proyecto", Rec."Nº linea") THEN BEGIN
                // Comprobar todas lineas misma tarifa
                rLinOrden.RESET;
                rLinOrden.SETRANGE("Tipo orden", Rec."Tipo orden");
                rLinOrden.SETRANGE("No. orden", Rec.No);
                if rLinOrden.FINDFIRST THEN BEGIN
                    rLinOrden.SETFILTER("Dia tarifa", '<>%1', rLinOrden."Dia tarifa");
                    if rLinOrden.FINDSET THEN
                        ERROR(Err09);
                END;

                rLinOrden.SETRANGE("Dia tarifa");
                rLinOrden.SETFILTER(Precio, '<>%1', 0);
                //$009
                if (Rec."Tipo orden" = Rec."Tipo orden"::Prensa) THEN BEGIN
                    rLinPresup.VALIDATE(Quantity, rLinOrden.COUNT);
                    //$010(I)
                    //rLinPresup.VALIDATE("Unit Cost", rLinOrden.Precio);
                    //rLinPresup.VALIDATE("Unit Price", rLinOrden.Precio);
                    rLinPresup.VALIDATE("Unit Cost", rLinOrden.Importe);
                    rLinPresup.VALIDATE("Unit Price", rLinOrden.Importe);
                    //$010(F)
                END ELSE BEGIN    // radio o audiovisual

                    wPrecioTotal := 0;
                    if rLinOrden.FINDSET THEN
                        REPEAT
                            wPrecioTotal += rLinOrden.Importe;
                        UNTIL rLinOrden.NEXT = 0;
                    rLinPresup.VALIDATE(Quantity, 1);
                    rLinPresup.VALIDATE("Unit Cost", wPrecioTotal);
                    rLinPresup.VALIDATE("Unit Price", wPrecioTotal);
                END;
                rLinPresup.MODIFY(TRUE);
            END;

            //-006
            COMMIT;
            //+006

            rConfig.GET;
            wImprimir := FALSE;
            if rConfig."Imprimir orden al validad" = rConfig."Imprimir orden al validad"::Preguntar THEN BEGIN
                if CONFIRM(Txt04, TRUE) THEN
                    wImprimir := TRUE;
            END
            ELSE
                if rConfig."Imprimir orden al validad" = rConfig."Imprimir orden al validad"::Siempre THEN
                    wImprimir := TRUE;

            // if wImprimir THEN
            //   ImprimirOrden(FALSE);
        END;
    END;

    PROCEDURE Desvalidar();
    BEGIN

        if CONFIRM(Txt03, TRUE) THEN BEGIN
            //   { MNC
            //   if CONFIRM(Txt07,TRUE) THEN
            //   BEGIN
            //     FILTERGROUP(3);
            //     SETRANGE(Estado, Estado::Abierta);
            //     FILTERGROUP(0);
            //   END;
            //   }
            Rec.Estado := Rec.Estado::Abierta;
            Rec.MODIFY;

            CurrPage.UPDATE;
            CurrPage.Subpage.Page.Actualizar;
        END;
    END;

    // PROCEDURE ImprimirOrden(pRequestPage: Boolean);
    // VAR
    //     rOrden2: Record "Cab. orden publicidad";
    //     repOrden: Report 80157;
    // BEGIN
    //     CLEAR(rOrden2);
    //     rOrden2.SETRANGE(No, Rec.No);

    //     CLEAR(repOrden);
    //     repOrden.USEREQUESTPage := pRequestPage;
    //     repOrden.SETTABLEVIEW(rOrden2);
    //     repOrden.RUNMODAL;
    //     CLEAR(rOrden2);
    // END;

    // PROCEDURE Facturar();
    // VAR
    //     iFacturar: Report 80150;
    // BEGIN

    //     iFacturar.RUN
    // END;

    PROCEDURE TraerFechaReferencia(): Date;
    VAR
        recLinPub: Record "Lin. orden publicidad";
        datFecha: Date;
    BEGIN
        recLinPub.RESET;
        recLinPub.SETRANGE("No. orden", Rec.No);
        if recLinPub.FIND('-') THEN
            EXIT(recLinPub."Fecha inicio");
    END;
}