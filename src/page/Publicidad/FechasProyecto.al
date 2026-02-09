page 50053 "Cambio fechas proyecto"
{
    //Version List=MLL1.00;
    PageType = Card;
    SourceTable = 167;
    layout
    {
        area(Content)
        {
            field("No."; Rec."No.")
            {
                Caption = 'Proyecto';
                ApplicationArea = All;
                Editable = false;
            }
            field("Adelant"; Adelanta)
            {
                ApplicationArea = All;
                Caption = 'Adelantar';
                trigger OnValidate()
                BEGIN
                    Atrasa := NOT Adelanta;
                END;
            }
            field("Atras"; Atrasa)
            {
                ApplicationArea = All;
                Caption = 'Atrasar';
                trigger OnValidate()
                BEGIN
                    Adelanta := NOT Atrasa;
                END;
            }

            field("Intervalo"; Intervalo) { ApplicationArea = All; Caption = 'Num. de dias'; }
        }
    }
    actions
    {
        area(Processing)
        {
            action("&Cambio")
            {
                Image = Change;
                ApplicationArea = All;
                trigger OnAction()
                BEGIN
                    if (Intervalo = 0) THEN
                        ERROR('El intervalo no puede quedar a cero');
                    if Adelanta THEN BEGIN
                        if NOT CONFIRM('Se adelantara TODO el proyecto %1 dias.\' +
                                        'Nos quedara desde %2 - %3. \' +
                                        'Tambien se cambiaran las Reservas y los datos en los\' +
                                        //               'Contratos y Facturas\'+                    //FCL-20/05/05
                                        'Contratos\' +                               //FCL-20/05/05
                                        '¿Correcto?', TRUE, STRSUBSTNO('%1', Intervalo),
                                        STRSUBSTNO('%1', Rec."Starting Date" + Intervalo), STRSUBSTNO('%1', Rec."Ending Date" + Intervalo)) THEN
                            EXIT;
                    END ELSE BEGIN
                        if NOT CONFIRM('Se atrasara TODO el proyecto %1 dias.\' +
                                        'Nos quedara desde %2 - %3. \' +
                                        'Tambien se cambiaran las Reservas y los datos en los\' +
                                        //               'Contratos y Facturas\'+                    //FCL-20/05/05
                                        'Contratos\' +                               //FCL-20/05/05
                                        '¿Correcto?', TRUE, STRSUBSTNO('%1', Intervalo),
                                        STRSUBSTNO('%1', Rec."Starting Date" - Intervalo), STRSUBSTNO('%1', Rec."Ending Date" - Intervalo)) THEN
                            EXIT;
                    END;
                    if Adelanta THEN
                        cProy.Cambio_Fecha(Rec, (Intervalo))
                    ELSE
                        cProy.Cambio_Fecha(Rec, (Intervalo * (-1)));
                    CurrPage.CLOSE;
                END;
            }

        }
    }
    VAR
        Adelanta: Boolean;
        Atrasa: Boolean;
        Intervalo: Decimal;
        cProy: Codeunit "Gestion Proyecto";

    trigger OnOpenPage()
    BEGIN
        Adelanta := TRUE;
        Atrasa := FALSE;
    END;

}
page 50056 "Fijación Proyectos"
{
    //Version List=;
    //area(Content){ Repeater(Detalle){ID=1;
    PageType = Card;
    SourceTable = Job;
    layout
    {
        area(Content)
        {
            //Repeater(Detalle)
            //{

            field("No."; Rec."No.") { ApplicationArea = All; }
            field("Descrption"; Rec.Description) { Caption = 'Descripción'; ApplicationArea = All; }
            field("Fecha Creación"; Rec."Creation Date") { ApplicationArea = All; }
            field(StartingDate; Rec."Starting Date")
            {
                ApplicationArea = ALL;

            }
            field(EndingDate; Rec."Ending Date")
            {
                ApplicationArea = ALL;

            }
            //field("No Pay"; Rec."No Pay") { ApplicationArea = ALL; }
            field("Proyecto de fijación"; Rec."Proyecto de fijación") { ApplicationArea = All; }
            // }
            part(JobTaskLines2; JobLinesSub)
            {
                ApplicationArea = ALL;
                Caption = 'Lineas';
                SubPageLink = "Job No." = FIELD("No.");
                SubPageView = SORTING("Job Task No.")
                              ORDER(Ascending);
            }
        }
    }
    actions
    {

        area(Processing)
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
                    finestra: Page Dialogo;

                    fech: Date;
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


    }
    var
        cProyecto: Codeunit "Gestion Proyecto";
}

page 50052 "Proyectos de Fijacion"
{
    //Version List=;
    //area(Content){ Repeater(Detalle){ID=1;
    PageType = List;
    UsageCategory = Lists;
    CardPageId = "Fijación Proyectos";
    SourceTable = Job;
    SourceTableView = where("Proyecto de fijación" = const(true));
    layout
    {
        area(Content)
        {
            Repeater(Detalle)
            {

                field("No."; Rec."No.") { ApplicationArea = All; }
                field("Descrption"; Rec.Description) { Caption = 'Descripción'; ApplicationArea = All; }
                field("Fecha Creación"; Rec."Creation Date") { ApplicationArea = All; }
                field("Proyecto de fijación"; Rec."Proyecto de fijación") { ApplicationArea = All; }
                //field("No Pay"; Rec."No Pay") { ApplicationArea = All; }
            }
        }
    }
}
page 50055 "Lista contratos con totales"
{
    //Version List=NAVW13.70,MLL1.00;
    PageType = List;
    UsageCategory = Lists;
    Editable = false;
    Caption = 'Lista contratos con totales';
    //area(Content){ Repeater(Detalle){ID=1;
    SourceTable = 36;
    DataCaptionFields = "Document Type";

    layout
    {
        area(Content)
        {
            Repeater(Detalle)
            {

                field("No."; Rec."No.") { ApplicationArea = All; }
                field("Sell-to Customer No."; Rec."Sell-to Customer No.") { ApplicationArea = All; }
                field("Sell-to Customer Name"; Rec."Sell-to Customer Name") { ApplicationArea = All; }
                field("Amount"; Rec.Amount) { ApplicationArea = All; }
                field("Amount Including VAT"; Rec."Amount Including VAT") { ApplicationArea = All; }
                field("Posting Description"; Rec."Posting Description") { ApplicationArea = All; }
                field("Payment Method Code"; Rec."Payment Method Code") { ApplicationArea = All; }
                field("External Document No."; Rec."External Document No.") { ApplicationArea = All; }
                field("Sell-to Post Code"; Rec."Sell-to Post Code") { ApplicationArea = All; }
                field("Sell-to Country/Region Code"; Rec."Sell-to Country/Region Code") { ApplicationArea = All; }
                field("Sell-to Contact"; Rec."Sell-to Contact") { ApplicationArea = All; }
                field("Bill-to Customer No."; Rec."Bill-to Customer No.") { ApplicationArea = All; }
                field("Bill-to Name"; Rec."Bill-to Name") { ApplicationArea = All; }
                field("Bill-to Post Code"; Rec."Bill-to Post Code") { ApplicationArea = All; }
                field("Bill-to Country/Region Code"; Rec."Bill-to Country/Region Code") { ApplicationArea = All; }
                field("Bill-to Contact"; Rec."Bill-to Contact") { ApplicationArea = All; }
                field("Ship-to Code"; Rec."Ship-to Code") { ApplicationArea = All; }
                field("Ship-to Name"; Rec."Ship-to Name") { ApplicationArea = All; }
                field("Ship-to Post Code"; Rec."Ship-to Post Code") { ApplicationArea = All; }
                field("Ship-to Country/Region Code"; Rec."Ship-to Country/Region Code") { ApplicationArea = All; }
                field("Ship-to Contact"; Rec."Ship-to Contact") { ApplicationArea = All; }
                field("Posting Date"; Rec."Posting Date") { ApplicationArea = All; }
                //    { 140 ;Label        ;0    ;0    ;0    ;0    ;
                field("Document Date"; Rec."Document Date") { ApplicationArea = All; }
                field("Order Date"; Rec."Order Date") { ApplicationArea = All; }
                field("Due Date"; Rec."Due Date") { ApplicationArea = All; }
                field("Shortcut Dimension 1 Code"; Rec."Shortcut Dimension 1 Code") { ApplicationArea = All; }
                field("Shortcut Dimension 2 Code"; Rec."Shortcut Dimension 2 Code") { ApplicationArea = All; }
                field("Location Code"; Rec."Location Code") { ApplicationArea = All; }
                field("Salesperson Code"; Rec."Salesperson Code") { ApplicationArea = All; }
                field("Comentario Cabecera"; Rec."Comentario Cabecera") { ApplicationArea = All; }
                field("Currency Code"; Rec."Currency Code") { ApplicationArea = All; }
                field("Nº Proyecto"; Rec."Nº Proyecto") { ApplicationArea = All; }
                field("Nº Contrato"; Rec."Nº Contrato") { ApplicationArea = All; }
                field("Fecha inicial proyecto"; Rec."Fecha inicial proyecto") { ApplicationArea = All; }
                field("Fecha fin proyecto"; Rec."Fecha fin proyecto") { ApplicationArea = All; }
                field(TotalSalesLineAmount; TotalSalesLine.Amount) { ApplicationArea = All; Caption = 'Importe (calc.)'; }

                field(AmountIncludingVAT; TotalSalesLine."Amount Including VAT") { ApplicationArea = All; Caption = 'Importe IVA incl. (calc.)'; }

                field("Importe líneas"; Rec."Importe líneas") { ApplicationArea = All; }
                field("Imp. IVA. incl."; Rec."Imp. IVA. incl.") { ApplicationArea = All; }
                field(Renovado; Rec.Renovado) { ApplicationArea = All; ShowCaption = false; }

                field("Interc./Compens."; Rec."Interc./Compens.") { ApplicationArea = All; }
                field("Proyecto origen"; Rec."Proyecto origen") { ApplicationArea = All; }
                field("Fecha inicial factura"; Rec."Fecha inicial factura") { ApplicationArea = All; }
                field("Fecha final factura"; Rec."Fecha final factura") { ApplicationArea = All; }
                field("Borradores de Factura"; Rec."Borradores de Factura") { ApplicationArea = All; }
                field("Borradores de Abono"; Rec."Borradores de Abono") { ApplicationArea = All; }
                field("Facturas Registradas"; Rec."Facturas Registradas") { ApplicationArea = All; }
                field("Abonos Registrados"; Rec."Abonos Registrados") { ApplicationArea = All; }
                field(ImpBorFac; ImpBorFac) { ApplicationArea = All; Caption = 'Imp. Borr.Fac.'; }

                field(ImpBorAbo; ImpBorAbo) { ApplicationArea = All; Caption = 'Imp. Borr.Abo.'; }

                field(ImpFac; ImpFac) { ApplicationArea = All; Caption = 'Imp. Fac.Reg.'; }

                field(ImpAbo; ImpAbo) { ApplicationArea = All; Caption = 'Imp. Abo.Reg.'; }

                field(TotImp; TotImp) { ApplicationArea = All; Caption = 'Importe total'; }

                field(Diferencia; TotalSalesLine."Amount Including VAT" - TotImp) { ApplicationArea = All; Caption = 'Diferencia'; }
            }
        }
    }
    actions
    {
        area(Navigation)
        {
            group("&Line")
            {
                Caption = '&Línea';
                action(Card)
                {
                    ShortCutKey = 'Mayús+F5';
                    Caption = 'Ficha';
                    trigger OnAction()
                    BEGIN
                        CASE Rec."Document Type" OF
                            Rec."Document Type"::Quote:
                                PAGE.RUN(PAGE::"Sales Quote", Rec);
                            Rec."Document Type"::Order:
                                PAGE.RUN(PAGE::"Ficha Contrato venta", Rec);
                            Rec."Document Type"::Invoice:
                                PAGE.RUN(PAGE::"Sales Invoice", Rec);
                            Rec."Document Type"::"Return Order":
                                PAGE.RUN(PAGE::"Sales Return Order", Rec);
                            Rec."Document Type"::"Credit Memo":
                                PAGE.RUN(PAGE::"Sales Credit Memo", Rec);
                            Rec."Document Type"::"Blanket Order":
                                PAGE.RUN(PAGE::"Blanket Sales Order", Rec);
                        END;
                    END;
                }
            }
        }
    }

    VAR
        TotalSalesLine: Record 37;
        TotalSalesLineLCY: Record 37;
        rCabFac: Record 112;
        rCabAbo: Record 114;
        RegisVtas: Codeunit 80;
        SumVtas: Codeunit ControlProcesos;
        wDecimal: Decimal;
        ImpBorFac: Decimal;
        ImpBorAbo: Decimal;
        ImpFac: Decimal;
        ImpAbo: Decimal;
        TotImp: Decimal;
        wTexto: Text[30];

    PROCEDURE CalcularTotales(pNumDoc: Code[20]);
    VAR
        TempSalesLine: Record 37 TEMPORARY;
    BEGIN
        //FCL-04/05/04. Obtengo total y total iva incluído, ya no me sirve el campo calculado
        // porque estos importes están a cero en las líneas.
        // JML 150704 Modificado para poder filtrar por fase.
        CLEAR(TotalSalesLine);
        CLEAR(TotalSalesLineLCY);
        if pNumDoc <> '' THEN BEGIN
            CLEAR(RegisVtas);
            CLEAR(TempSalesLine);
            Clear(SumVtas);
            RegisVtas.GetSalesLines(Rec, TempSalesLine, 0);
            CLEAR(RegisVtas);
            //  JML 150704
            //  RegisVtas.SumSalesLinesTemp(
            //    Rec,TempSalesLine,0,TotalSalesLine,TotalSalesLineLCY,
            //    wDecimal,wTexto,wDecimal,wDecimal);
            SumVtas.SumSalesLinesTempTarea(Rec, TempSalesLine, 0, TotalSalesLine,
                                        TotalSalesLineLCY, Rec.GETFILTER("Filtro fase"), TotalSalesLine, TotalSalesLineLCY);
        END;
    END;

    PROCEDURE TotalesDocumentos();
    VAR
        TempSalesLine: Record 37 TEMPORARY;
        rCabVenta: Record 36;
    BEGIN
        //FCL-13/02/06. Obtengo totales de borradores y facturas correspondientes a este contrato.
        ImpBorFac := 0;
        ImpBorAbo := 0;
        ImpFac := 0;
        ImpAbo := 0;
        if (Rec."Borradores de Factura" <> 0) OR (Rec."Borradores de Abono" <> 0) THEN BEGIN
            rCabVenta.RESET;
            rCabVenta.SETCURRENTKEY("Nº Proyecto");
            rCabVenta.SETRANGE("Nº Proyecto", Rec."Nº Proyecto");
            rCabVenta.SETRANGE("Nº Contrato", Rec."No.");
            rCabVenta.SETFILTER("Document Type", '%1|%2',
               rCabVenta."Document Type"::Invoice, rCabVenta."Document Type"::"Credit Memo");
            if rCabVenta.FIND('-') THEN BEGIN
                REPEAT
                    CLEAR(TotalSalesLine);
                    CLEAR(TotalSalesLineLCY);
                    CLEAR(RegisVtas);
                    CLEAR(TempSalesLine);
                    RegisVtas.GetSalesLines(rCabVenta, TempSalesLine, 0);
                    CLEAR(RegisVtas);
                    RegisVtas.SumSalesLinesTemp(
                      rCabVenta, TempSalesLine, 0, TotalSalesLine, TotalSalesLineLCY,
                      wDecimal, wTexto, wDecimal, wDecimal, wDecimal);
                    if rCabVenta."Document Type" = rCabVenta."Document Type"::Invoice THEN BEGIN
                        ImpBorFac := ImpBorFac + TotalSalesLineLCY."Amount Including VAT";
                    END
                    ELSE BEGIN
                        ImpBorAbo := ImpBorAbo + TotalSalesLineLCY."Amount Including VAT";
                    END;
                UNTIL rCabVenta.NEXT = 0;
            END;
        END;
        if Rec."Facturas Registradas" <> 0 THEN BEGIN
            rCabFac.RESET;
            rCabFac.SETCURRENTKEY("Nº Proyecto", "Nº Contrato");
            rCabFac.SETRANGE("Nº Contrato", Rec."No.");
            if rCabFac.FIND('-') THEN BEGIN
                REPEAT
                    rCabFac.CALCFIELDS("Amount Including VAT");
                    ImpFac := ImpFac + rCabFac."Amount Including VAT";
                UNTIL rCabFac.NEXT = 0;

            END;
        END;
        if Rec."Abonos Registrados" <> 0 THEN BEGIN
            rCabAbo.RESET;
            rCabAbo.SETCURRENTKEY("Nº Proyecto", "Nº Contrato");
            rCabAbo.SETRANGE("Nº Contrato", Rec."No.");
            if rCabAbo.FIND('-') THEN BEGIN
                REPEAT
                    rCabAbo.CALCFIELDS("Amount Including VAT");
                    ImpAbo := ImpAbo + rCabAbo."Amount Including VAT";
                UNTIL rCabAbo.NEXT = 0;
            END;
        END;
        TotImp := ImpBorFac - ImpBorAbo + ImpFac - ImpAbo;
    END;

}
page 50058 "Comer - Control contab. ptes"
{
    //Version List=FH3.70,ES;
    SaveValues = true;
    PageType = List;
    UsageCategory = Lists;
    //area(Content){ Repeater(Detalle){ID=16;
    SourceTable = 265;
    layout
    {
        area(Content)
        {
            repeater(Detalle)
            {
                field("Entry No."; Rec."Entry No.") { ApplicationArea = All; }
                field("Table ID"; Rec."Table ID") { ApplicationArea = All; }
                field("Table Name"; Rec."Table Name") { ApplicationArea = All; }

                field("No. of Records"; Rec."No. of Records") { ApplicationArea = All; DrillDown = true; }
            }
        }
    }
    VAR
        Text000: Label 'No se ha indicado tipo negocio.';
        Text001: Label 'No existe información registrada con el nº documento externo indicado.';
        Text002: Label 'Contando registros...';
        Text003: Label 'Historical sale invoices;ESP=Histórico facturas venta';
        Text004: Label 'Hotel Invoices;ESP=Facturas Hotel';
        Text005: Label 'Historical sale credits;ESP=Histórico abonos venta';
        Text006: Label 'Histórico albaranes venta';
        Text007: Label 'Recordatorio emitido';
        Text008: Label 'Doc. interés emitido';
        Text009: Label 'Historical purchase invoices;ESP=Histórico facturas compra';
        Text010: Label 'Histórico abono compra';
        Text011: Label 'Histórico albaranes compra';
        Text012: Label 'El mismo nº documento se ha utilizado en varios documentos';
        Text013: Label 'La combinación del nº documento y fecha registro se ha utilizado más de una vez.';
        Text014: Label 'No existe información registrada con el nº documento indicado.';
        Text015: Label 'No existe información registrada con esta combinación de nº documento y fecha de registro.';
        Text016: Label 'El resultado de la búsqueda incluye demasiados documentos externos. Indique un valor en tipo negocio.';
        Text017: Label 'El resultado de la búsqueda incluye demasiados documentos. Utilice Navegar desde otros movimientos más aproximados.';
        Text018: Label 'Sólo se puede imprimir desde la misma empresa.';
        Text019: Label 'Esta información no se puede imprimir.';
        Text020: Label 'FAC00001';
        rSec: Record "Gen. Journal Batch";
        rDir: Record "Gen. Journal Line";
        DocMov: Record 265 TEMPORARY;
        Ventana: Dialog;
        FiltNoAgr: Code[250];
        FiltNoFacVta: Code[250];
        FiltNoFacCom: Code[250];
        NoDocExt: Code[250];
        NueFechaRegi: Date;
        TipoDoc: Text[30];
        TipoOrigen: Text[30];
        NoOrigen: Code[20];
        NombOrigen: Text[50];
        TipoContact: Option ,Proveedor;
        ExisteDoc: Boolean;
        EmpresaBuscar: Text[30];
        ComplejoBuscar: Code[10];
        AgrupaciónBuscar: Code[12];
        Con: Record "General Ledger Setup";
        rEmp: Record 2000000006;
        wFiltro: Text[250];
        Leido: Integer;
        SumaImporte: Decimal;

    trigger OnOpenPage()
    BEGIN
        DocMov.DELETEALL;
        BuscarRegs;
    END;

    trigger OnFindRecord(which: Text): Boolean
    BEGIN
        DocMov := Rec;
        if NOT DocMov.FIND(Which) THEN
            EXIT(FALSE);
        Rec := DocMov;
        EXIT(TRUE);
    END;

    trigger OnNextRecord(Steps: Integer): Integer
    VAR
        PasosEnCurso: Integer;
    BEGIN
        DocMov := Rec;
        PasosEnCurso := DocMov.NEXT(Steps);
        if PasosEnCurso <> 0 THEN
            Rec := DocMov;
        EXIT(PasosEnCurso);
    END;

    LOCAL PROCEDURE BuscarRegs();
    var
        Coltrol: Codeunit ControlProcesos;
    BEGIN
        // MostrarRegs;
        DocMov.DELETEALL;
        DocMov."Entry No." := 0;
        rEmp.RESET;

        rEmp.SetRange("Evaluation Company", false);
        if rEmp.FIND('-') THEN
            REPEAT
                if Coltrol.Permiso_Empresas(rEmp.Name) then begin
                    EmpresaBuscar := rEmp.Name;
                    if (EmpresaBuscar <> '') THEN BEGIN
                        rSec.CHANGECOMPANY(EmpresaBuscar);
                        rDir.CHANGECOMPANY(EmpresaBuscar);
                        WITH DocMov DO BEGIN
                            Ventana.OPEN(Text002);
                            if rSec.READPERMISSION THEN BEGIN
                                rSec.RESET;
                                if rSec.FIND('-') THEN
                                    REPEAT
                                        Leido := 0;
                                        SumaImporte := 0;
                                        rDir.RESET;
                                        rDir.SETRANGE("Journal Template Name", rSec."Journal Template Name");
                                        rDir.SETRANGE("Journal Batch Name", rSec.Name);
                                        if rDir.FIND('-') THEN
                                            REPEAT
                                                Leido := Leido + 1;
                                                SumaImporte := SumaImporte + rDir."Debit Amount" - rDir."Credit Amount";
                                            UNTIL rDir.NEXT = 0;
                                        if (Leido > 0) OR (SumaImporte <> 0) THEN BEGIN
                                            DocMov.INIT;
                                            DocMov."Entry No." := DocMov."Entry No." + 1;
                                            DocMov."Table ID" := DATABASE::"Gen. Journal Batch";
                                            DocMov."Table Name" := rSec."Journal Template Name" + '/' + rSec.Name;
                                            DocMov."No. of Records" := Leido;
                                            // DocMov.Empresa := EmpresaBuscar;
                                            DocMov.INSERT;
                                        END;
                                    UNTIL rSec.NEXT = 0;
                            END;
                        END;
                    END;
                end;
            UNTIL rEmp.NEXT = 0;
        CurrPage.UPDATE(FALSE);
        ExisteDoc := Rec.FIND('-');
        //CurrPageE;
    END;

    LOCAL PROCEDURE MostrarRegs();
    BEGIN
        DocMov := Rec;
        if DocMov.FIND THEN
            Rec := DocMov;
        WITH DocMov DO
            CASE "Table ID" OF
                DATABASE::"Gen. Journal Batch":
                    BEGIN
                        //        rDir.CHANGECOMPANY(Empresa);
                        rDir.SETRANGE("Journal Template Name", rSec."Journal Template Name");
                        rDir.SETRANGE("Journal Batch Name", rSec.Name);
                        PAGE.RUNMODAL(0, rDir);
                    END;
            END;
    END;
    // BEGIN
    // {
    //   // PLB 07/08/2000
    //   Imprimir la información correspondiente
    // }
    // END.

}
page 50048 "Soportes proyecto"
{
    //Version List=MLL1.00;
    PageType = Card;
    SourceTable = 167;
    layout
    {
        area(Content)
        {
            field("No."; Rec."No.")
            {
                Caption = 'Proyecto';
                ApplicationArea = All;
                Editable = false;
            }

            field("Fecha Fijación"; Rec."Fecha Fijación")
            {
                trigger OnValidate()
                begin
                    Rec.Fijar := True;
                    Rec.Modify();
                end;
            }
            field("Tipo Soporte"; Rec."Tipo soporte")
            {

            }
            field("No. soportes"; Rec."No. soportes")
            {
                Caption = 'Nº soportes';
            }

        }
    }



}
