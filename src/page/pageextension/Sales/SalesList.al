/// <summary>
/// PageExtension SalesList (ID 80142) extends Record Sales List.
/// </summary>
pageextension 80142 SalesList extends "Sales List"
{
    layout
    {
        addafter("Sell-to Customer Name")
        {
            field("VAT Registration No."; Rec."VAT Registration No.")
            {
                ApplicationArea = All;
            }
            field("Customer Posting Group"; Rec."Customer Posting Group")
            {
                ApplicationArea = All;
            }
            field("Estado Contrato"; Rec."Estado Contrato")
            {
                ApplicationArea = All;
            }
            field(Estado; Rec.Estado)
            {
                ApplicationArea = All;
            }
            // field(Amount; Rec.Amount)
            // {
            //     ApplicationArea = All;
            // }
            // field("Amount Including VAT"; Rec."Amount Including VAT")
            // {
            //     ApplicationArea = All;
            // }
            field("Posting Description"; Rec."Posting Description")
            {
                ApplicationArea = All;
            }
            field("Ampliación Covit19"; Rec."Ampliación Covit19")
            {
                ApplicationArea = All;
            }
            // field("Borradores de Factura"; Rec."Borradores de Factura")
            // {
            //     ApplicationArea = All;
            // }
            // field("Borradores de Abono"; Rec."Borradores de Abono")
            // {
            //     ApplicationArea = All;
            // }
            // field("Facturas Registradas"; Rec."Facturas Registradas")
            // {
            //     ApplicationArea = All;
            // }
            // field("Abonos Registrados"; Rec."Abonos Registrados")
            // {
            //     ApplicationArea = All;
            // }
            // field("Total Fras-Abo"; TotImp)
            // {
            //     ApplicationArea = All;
            // }
            // field(Diferencia; (TotCont - TotImp))
            // {
            //     ApplicationArea = All;
            // }
            // field("Pendiente Facturación"; (ImpBorFac - ImpBorAbo) + (TotCont - TotImp))
            // {
            //     ApplicationArea = All;
            // }

        }
        addafter("Currency Code")
        {
            field("Nº Proyecto"; Rec."Nº Proyecto")
            {
                ApplicationArea = All;
            }
            field("Nº Contrato"; Rec."Nº Contrato")
            {
                ApplicationArea = All;
            }
            field("Nº pedido"; Rec."Nº pedido")
            {
                ApplicationArea = All;
            }
            field("Nº pedido cliente"; Rec."Customer Order No.")
            {
                ApplicationArea = All;
            }
            field("Fecha inicial proyecto"; Rec."Fecha inicial proyecto")
            {
                ApplicationArea = all;
            }
            field("Fecha fin proyecto"; Rec."Fecha fin proyecto")
            {
                ApplicationArea = All;
            }
            field("Pte firma cliente"; Rec."Pte firma cliente")
            {
                ApplicationArea = All;

            }
            field("Importe (calc.)"; TotalSalesLine.Amount)
            {
                ApplicationArea = All;
            }
            field("Importe IVA incl. (calc.)"; TotalSalesLine."Amount Including VAT")
            {
                ApplicationArea = All;
            }
            field(Renovado; Rec.Renovado)
            {
                ApplicationArea = All;
            }
            field("Interc./Compens."; Rec."Interc./Compens.")
            {
                ApplicationArea = All;
            }
            field("Proyecto origen"; Rec."Proyecto origen")
            {
                ApplicationArea = All;
            }
            field("Fecha inicial factura"; Rec."Fecha inicial factura")
            {
                ApplicationArea = All;
            }
            field("Fecha final factura"; Rec."Fecha final factura")
            {
                ApplicationArea = All;
            }
            field("Fecha renovacion"; Rec."Fecha renovacion")
            {
                ApplicationArea = All;
            }
            field("Contrato original"; "Contrato original")
            {
                ApplicationArea = All;
            }
            field("Contrato origen"; "Contrato origen")
            {
                ApplicationArea = All;
            }
            field("Contrato renovado"; "Contrato renovado")
            {
                ApplicationArea = All;
            }
            field("Esperar Orden Cliente"; Rec."Esperar Orden Cliente")
            {
                ApplicationArea = All;
            }
            field("Fecha cancelacion"; Rec."Fecha cancelacion")
            {
                ApplicationArea = All;
            }
        }
    }
    actions
    {
        addlast("&Line")
        {
            action("Lanzar Todas")
            {
                ApplicationArea = all;
                Scope = Repeater;
                Caption = 'Lanzar Todas';
                trigger OnAction()
                Var
                    r36: Record 36;
                    ReleaseSalesDoc: Codeunit 414;
                BEGIN
                    CurrPage.SETSELECTIONFILTER(r36);
                    if r36.FINDFIRST THEN
                        REPEAT
                            ReleaseSalesDoc.PerformManualRelease(r36);
                        UNTIL r36.NEXT = 0;
                END;
            }
            action("Enviar a Cartera")
            {

                ApplicationArea = all;
                Scope = Repeater;
                Caption = 'Enviar a Cartera';
                Image = BinJournal;
                trigger OnAction()
                Var
                    cGesCartera: Codeunit "Gestion cartera";
                    r36: Record 36;
                    rFp: Record 289;
                    i: Integer;
                    Num: Code[20];
                BEGIN
                    CurrPage.SETSELECTIONFILTER(r36);
                    r36.SETCURRENTKEY(r36."Document Type", r36."No.");
                    i := 1;
                    Num := '';
                    if r36.FINDFIRST THEN
                        REPEAT
                            if r36."Nº Contrato" <> Num THEN BEGIN
                                i := 1;
                                Num := r36."Nº Contrato";
                            END;
                            if r36."Document Type" <> r36."Document Type"::Invoice THEN ERROR('Solo se pueden enviar facturas');
                            rFp.GET(r36."Payment Method Code");
                            if rFp."Remesa sin factura" = FALSE THEN ERROR('La forma de pago no es para remesas sin factura');
                            CLEAR(cGesCartera);
                            cGesCartera.CrearDocCartera(r36, i, r36.count);
                        UNTIL r36.NEXT = 0;
                    COMMIT;
                    r36.MODIFYALL(r36."Remesa sin factura", TRUE);
                END;
            }
            action("Imprimir &Factura Borrador")
            {
                Image = Document;
                ApplicationArea = All;
                trigger OnAction()
                var
                    rCab2: Record "Sales Header";
                Begin
                    rCab2.RESET;
                    rCab2.SETRANGE("Document Type", Rec."Document Type"::Invoice);
                    rCab2.SETRANGE("No.", Rec."No.");
                    if rCab2.FindFirst() Then
                        REPORT.RUNMODAL(REPORT::"Pre-Sales-Invoice Pdf", TRUE, FALSE, rCab2);
                End;
            }
            action("Actualizar Forma Pago")
            {
                ApplicationArea = all;
                Scope = Repeater;
                Image = Payment;
                Caption = 'Actualizar Forma Pago';
                trigger OnAction()
                Var
                    r36: Record 36;
                    rFp: Record 289;
                    i: Integer;
                    Num: Code[20];
                BEGIN
                    CurrPage.SETSELECTIONFILTER(r36);
                    r36.SETCURRENTKEY(r36."Document Type", r36."No.");
                    i := 1;
                    Num := '';
                    if r36.FINDFIRST THEN
                        REPEAT
                            if r36."Document Type" <> r36."Document Type"::Order THEN ERROR('Solo se actualizar contratos');
                            rFp.GET(r36."Payment Method Code");
                            if rFp."Remesa sin factura" = FALSE THEN ERROR('La forma de pago no es para remesas sin factura');
                        UNTIL r36.NEXT = 0;
                    r36.MODIFYALL(r36."Remesa sin factura", TRUE);
                END;
            }
        }
    }
    var
        TotalSalesLine: Record "Sales Line";
        TotalSalesLineLCY: Record "Sales Line";
        rCabFac: Record "Sales Invoice Header";
        rCabAbo: Record "Sales Cr.Memo Header";
        RegisVtas: Codeunit "Sales-Post";
        wDecimal: Decimal;
        wTexto: Text[30];
        ImpBorFac: Decimal;
        ImpBorAbo: Decimal;
        ImpFac: Decimal;
        ImpAbo: Decimal;
        TotImp: Decimal;
        TotCont: Decimal;
        wVer: Option Todos,Defecto,Exceso;
        "Contrato original": Code[20];
        "Contrato origen": Code[20];
        "Contrato renovado": Code[20];
        Empresa: Text[30];
        BImpBorFac: Decimal;
        BImpBorAbo: Decimal;
        BImpFac: Decimal;
        BImpAbo: Decimal;
        BTotImp: Decimal;
        BTotCont: Decimal;

    trigger OnOpenPage()
    BEGIN
        AplicarFiltros;                          //$004
        if Empresa <> '' THEN Rec.CHANGECOMPANY(Empresa);
    END;

    trigger OnAfterGetRecord()
    BEGIN
        // if Empresa <> '' THEN Rec.CHANGECOMPANY(Empresa);
        // CalcularTotales(Rec."No.");              //FCL-17/05/04
        //                                          // $002 -
        // if Empresa <> '' THEN
        //     TotalesDocumentosEmpresa(Rec, Empresa)
        // ELSE
        //     TotalesDocumentos(Rec."No.");
        // // $002+

        // BuscarProyectos;                    //$003
    END;

    PROCEDURE CalcularTotales(pNumDoc: Code[20]);
    VAR
        TempSalesLine: Record 37 TEMPORARY;
    BEGIN
        //FCL-04/05/04. Obtengo total y total iva incluído, ya no me sirve el campo calculado
        // porque estos importes están a cero en las líneas.
        // JML 150704 Modificado para poder filtrar por fase.
        // $001 por tarea

        CLEAR(TotalSalesLine);
        CLEAR(TotalSalesLineLCY);

        if pNumDoc <> '' THEN BEGIN
            CLEAR(RegisVtas);
            CLEAR(TempSalesLine);
            RegisVtas.GetSalesLines(Rec, TempSalesLine, 0);
            CLEAR(RegisVtas);

            RegisVtas.SumSalesLinesTemp(
              Rec, TempSalesLine, 0, TotalSalesLine, TotalSalesLineLCY,
              wDecimal, wTexto, wDecimal, wDecimal, wDecimal);

            //  JML 150704
            //  RegisVtas.SumSalesLinesTempFase(Rec,TempSalesLine,0,TotalSalesLine,
            //                              TotalSalesLineLCY, GETFILTER("Filtro fase"));

        END;
    END;

    PROCEDURE TotalesDocumentos(wNum: Code[20]);
    VAR
        TempSalesLine: Record 37 TEMPORARY;
        rCabVenta: Record 36;
    BEGIN
        //$002 Obtengo totales de borradores y facturas correspondientes a este contrato.

        ImpBorFac := 0;
        ImpBorAbo := 0;
        ImpFac := 0;
        ImpAbo := 0;
        TotImp := 0;
        TotCont := 0;

        //if ("Borradores de Factura" <> 0) OR ("Borradores de Abono" <> 0) THEN BEGIN
        if (wNum <> '') THEN BEGIN

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

        //FCL-13/02/06. Incluyo sumatorio de totales y diferencia con el total del contrato.
        TotImp := ImpBorFac - ImpBorAbo + ImpFac - ImpAbo;

        if rCabVenta.GET(rCabVenta."Document Type"::Order, Rec."No.") THEN BEGIN
            CLEAR(TotalSalesLine);
            CLEAR(TotalSalesLineLCY);
            CLEAR(RegisVtas);
            CLEAR(TempSalesLine);
            RegisVtas.GetSalesLines(rCabVenta, TempSalesLine, 0);
            CLEAR(RegisVtas);
            RegisVtas.SumSalesLinesTemp(rCabVenta, TempSalesLine, 0, TotalSalesLine, TotalSalesLineLCY,
                                        wDecimal, wTexto, wDecimal, wDecimal, wDecimal);
            TotCont := TotalSalesLineLCY."Amount Including VAT";
        END;
    END;

    PROCEDURE BuscarProyectos();
    VAR
        rContrato: Record 36;
        rProyecto: Record 167;
        wCuantos: Integer;
    BEGIN
        // $003 Obtengo los contratos asociados a los proyectos original, origen y renovado.

        "Contrato origen" := '';
        "Contrato original" := '';
        "Contrato renovado" := '';

        if rProyecto.GET(Rec."Nº Proyecto") THEN BEGIN
            if rProyecto."Proyecto original" <> '' THEN BEGIN
                rContrato.RESET;
                rContrato.SETCURRENTKEY("Nº Proyecto");
                rContrato.SETRANGE("Nº Proyecto", rProyecto."Proyecto original");
                if rContrato.FINDFIRST THEN
                    "Contrato original" := rContrato."No.";
            END;
            if rProyecto."Proyecto origen" <> '' THEN BEGIN
                rContrato.RESET;
                rContrato.SETCURRENTKEY("Nº Proyecto");
                rContrato.SETRANGE("Nº Proyecto", rProyecto."Proyecto origen");
                if rContrato.FINDFIRST THEN
                    "Contrato origen" := rContrato."No.";
            END;
            //$005(I)
            wCuantos := 0;
            rProyecto.RESET;
            rProyecto.SETCURRENTKEY("Proyecto origen");
            rProyecto.SETRANGE("Proyecto origen", Rec."Nº Proyecto");
            wCuantos := rProyecto.COUNT;
            //$005(F)
            rProyecto.RESET;
            rProyecto.SETCURRENTKEY("Proyecto origen");
            rProyecto.SETRANGE("Proyecto origen", Rec."Nº Proyecto");
            //$005(I)
            if wCuantos > 0 THEN
                rProyecto.SETFILTER("No.", '<>%1', Rec."Nº Proyecto");
            //$005(F)
            if rProyecto.FINDFIRST THEN BEGIN
                rContrato.RESET;
                rContrato.SETCURRENTKEY("Nº Proyecto");
                rContrato.SETRANGE("Nº Proyecto", rProyecto."No.");
                if rContrato.FINDFIRST THEN
                    "Contrato renovado" := rContrato."No.";
            END;
        END;
    END;

    PROCEDURE AplicarFiltros();
    VAR
        rUsuario: Record 91;
    BEGIN
        //$004
        if rUsuario.GET(USERID) THEN BEGIN
            if rUsuario."Filtro vendedor" <> '' THEN BEGIN
                Rec.FILTERGROUP(2);
                Rec.SETFILTER("Salesperson Code", rUsuario."Filtro vendedor");
                Rec.FILTERGROUP(0);
            END;
        END;
    END;

    PROCEDURE TotalesDocumentosEmpresa(VAR Contrato: Record 36; Empresa: Text[30]);
    VAR
        rCabVenta: Record 36;
        rCabFac: Record 112;
        rCabAbo: Record 114;
        RegisVtas: Codeunit 80;
        rCabFacL: Record 113;
        rCabAboL: Record 115;
        SalesLine: Record 37;
        Importe: Decimal;
        Iva: Decimal;
        BImporte: Decimal;
    BEGIN
        //FCL-31/05/04. Obtengo totales de borradores y facturas correspondientes a este contrato.
        ImpBorFac := 0;
        ImpBorAbo := 0;
        ImpFac := 0;
        ImpAbo := 0;
        BImpBorFac := 0;
        BImpBorAbo := 0;
        BImpFac := 0;
        BImpAbo := 0;

        WITH Contrato DO BEGIN
            Contrato.CHANGECOMPANY(Empresa);
            if Estado = Estado::Anulado THEN BEGIN
                TotCont := 0;
                TotImp := 0;
                ImpBorFac := 0;
                ImpBorAbo := 0;
                ImpFac := 0;
                ImpAbo := 0;
                EXIT;
            END;
            if Estado = Estado::Cancelado THEN BEGIN
                TotCont := 0;
                TotImp := 0;
                ImpBorFac := 0;
                ImpBorAbo := 0;
                ImpFac := 0;
                ImpAbo := 0;
                EXIT;
            END;
            CALCFIELDS(Contrato."Abonos Registrados", Contrato."Facturas Registradas", Contrato."Borradores de Factura",
            Contrato."Borradores de Abono");
            //if ("Borradores de Factura" <> 0) OR ("Borradores de Abono" <> 0) THEN BEGIN
            rCabVenta.RESET;
            rCabVenta.CHANGECOMPANY(Empresa);
            rCabVenta.SETCURRENTKEY("Nº Proyecto");
            rCabVenta.SETRANGE("Nº Proyecto", "Nº Proyecto");
            rCabVenta.SETRANGE("Nº Contrato", "No.");
            rCabVenta.SETFILTER("Document Type", '%1|%2',
               rCabVenta."Document Type"::Invoice, rCabVenta."Document Type"::"Credit Memo");
            if rCabVenta.FIND('-') THEN BEGIN
                REPEAT
                    SalesLine.CHANGECOMPANY(Empresa);
                    SalesLine.SETRANGE(SalesLine."Document Type", rCabVenta."Document Type");
                    SalesLine.SETRANGE(SalesLine."Document No.", rCabVenta."No.");
                    Importe := 0;
                    BImporte := 0;
                    if SalesLine.FINDFIRST THEN
                        REPEAT
                            Importe += (SalesLine.Quantity * SalesLine."Unit Price" * (1 - SalesLine."Line Discount %" / 100)) * (1 + SalesLine."VAT %" / 100);
                            BImporte += (SalesLine.Quantity * SalesLine."Unit Price" * (1 - SalesLine."Line Discount %" / 100));
                        UNTIL SalesLine.NEXT = 0;
                    if rCabVenta."Document Type" = rCabVenta."Document Type"::Invoice THEN BEGIN
                        //$009(I)
                        //ImpBorFac:=ImpBorFac + TotalSalesLineLCY."Amount Including VAT";
                        ImpBorFac := ImpBorFac + Importe;
                        BImpBorFac := BImpBorFac + BImporte;
                        //$009(F)
                    END
                    ELSE BEGIN
                        //$009(I)
                        //ImpBorAbo:=ImpBorAbo + TotalSalesLineLCY."Amount Including VAT";
                        ImpBorAbo := ImpBorAbo + Importe;
                        BImpBorAbo := BImpBorAbo + BImporte;
                        //$009(F)
                    END;
                UNTIL rCabVenta.NEXT = 0;
            END;

            //END;

            //if "Facturas Registradas" <> 0 THEN BEGIN

            rCabFac.RESET;
            rCabFac.CHANGECOMPANY(Empresa);
            rCabFacL.CHANGECOMPANY(Empresa);
            rCabFac.SETCURRENTKEY("Nº Proyecto", "Nº Contrato");
            rCabFac.SETRANGE("Nº Contrato", "No.");
            if rCabFac.FIND('-') THEN BEGIN
                REPEAT
                    rCabFacL.SETRANGE(rCabFacL."Document No.", rCabFac."No.");
                    if rCabFacL.FINDFIRST THEN
                        rCabFacL.CALCSUMS(rCabFacL."Amount Including VAT", Amount)
                    ELSE
                        rCabFacL.INIT;
                    ImpFac := ImpFac + rCabFacL."Amount Including VAT";
                    BImpFac := BImpFac + rCabFacL.Amount;
                UNTIL rCabFac.NEXT = 0;
            END;

            //END;

            //if "Abonos Registrados" <> 0 THEN BEGIN

            rCabAbo.RESET;
            rCabAbo.CHANGECOMPANY(Empresa);
            rCabAboL.CHANGECOMPANY(Empresa);
            rCabAbo.SETCURRENTKEY("Nº Proyecto", "Nº Contrato");
            rCabAbo.SETRANGE("Nº Contrato", "No.");
            if rCabAbo.FIND('-') THEN BEGIN
                REPEAT
                    rCabAboL.SETRANGE(rCabAboL."Document No.", rCabAbo."No.");
                    if rCabAboL.FINDFIRST THEN
                        rCabAboL.CALCSUMS(rCabAboL."Amount Including VAT", Amount)
                    ELSE
                        rCabAboL.INIT;
                    ImpAbo := ImpAbo + rCabAboL."Amount Including VAT";
                    BImpAbo := BImpAbo + rCabAboL.Amount;
                //$009(F)
                UNTIL rCabAbo.NEXT = 0;
            END;

            //END;

            //FCL-13/02/06. Incluyo sumatorio de totales y diferencia con el total del contrato.
            TotImp := ImpBorFac - ImpBorAbo + ImpFac - ImpAbo;
            BTotImp := BImpBorFac - BImpBorAbo + BImpFac - BImpAbo;
            rCabVenta.CHANGECOMPANY(Empresa);
            if rCabVenta.GET(rCabVenta."Document Type"::Order, "No.") THEN BEGIN
                SalesLine.CHANGECOMPANY(Empresa);
                SalesLine.SETRANGE(SalesLine."Document Type", rCabVenta."Document Type");
                SalesLine.SETRANGE(SalesLine."Document No.", rCabVenta."No.");
                Importe := 0;
                BImporte := 0;
                if SalesLine.FINDFIRST THEN
                    REPEAT
                        Importe += (SalesLine.Quantity * SalesLine."Unit Price" * (1 - SalesLine."Line Discount %" / 100)) * (1 + SalesLine."VAT %" / 100);
                        BImporte += (SalesLine.Quantity * SalesLine."Unit Price" * (1 - SalesLine."Line Discount %" / 100));
                        Iva := SalesLine."VAT %";
                    UNTIL SalesLine.NEXT = 0;

                TotCont := Importe;
                BTotCont := BImporte;
            END;
        END;
        if ABS((BImpBorFac - BImpBorAbo) + (BTotCont - BTotImp)) < 1 THEN BEGIN
            BImpBorFac := BImpBorFac * (1 + Iva / 100);
            ImpBorAbo := BImpBorAbo * (1 + Iva / 100);
            ImpFac := BImpFac * (1 + Iva / 100);
            ImpAbo := BImpAbo * (1 + Iva / 100);
            TotImp := BTotImp * (1 + Iva / 100);
            TotCont := BTotCont * (1 + Iva / 100);
        END;
    END;

    PROCEDURE CambiarEmpresa(Emp: Text[30]);
    BEGIN
        Empresa := Emp;
    END;

    // BEGIN
    // {
    //   $001 MNC 290708 para migracion a 5.0, no tenemos fase, tenemos tarea
    //   $002 MNC 170609 Campos total y diferencia
    //   $003 FCL 310510 Campos referentes a renovación
    //   $004 FCL-050710. Aplico filtros por vendedor definidos en la tabla de usuarios.
    //   $005 FCL 191010 Al buscar el proyecto original tengo en cuenta que puede haber dos, en este caso
    //                   cogeré aquel cuyo nº proyecto origen sea distinto a nº proyecto.
    // }
    // END.

}
pageextension 80159 SalesInvoicList extends "Sales Invoice List"
{
    layout
    {
        addfirst(Control1)
        {
            field("Tipo Documento"; "DocumentType") { Caption = 'Tipo Documento'; ApplicationArea = All; }
        }
        modify("Sell-to Customer Name")
        {
            StyleExpr = Color;
            ApplicationArea = All;
        }
#if not CLEAN27
        addafter(Amount)
        {
            field("Amount Including VAT"; Rec."Amount Including VAT")
            {
                ApplicationArea = All;
            }
        }
#endif
        addafter("Salesperson Code")
        {
            field("Nombre Vendedor"; Vendedor(Rec."Salesperson Code"))
            {
                ApplicationArea = all;
            }
        }
        addafter("Sell-to Customer Name")
        {
            field("VAT Registration No."; Rec."VAT Registration No.")
            {
                ApplicationArea = All;
            }
            field("Customer Posting Group"; Rec."Customer Posting Group")
            {
                ApplicationArea = All;
            }
            field("Estado Contrato"; Rec."Estado Contrato")
            {
                ApplicationArea = All;
            }
            field(Estado; Rec.Estado)
            {
                ApplicationArea = All;
            }
            field("Payment Method Code"; Rec."Payment Method Code")
            {
                ApplicationArea = All;
            }

            field("Nuestra Cuenta Transf."; NC())
            {
                ApplicationArea = All;
            }

            field("Comentario Cabecera"; Rec."Comentario Cabecera")
            {
                ApplicationArea = All;
            }

            // field("Posting Description"; Rec."Posting Description")
            // {
            //     ApplicationArea = All;
            // }


        }
        addafter("Currency Code")
        {
            field("Nº Proyecto"; Rec."Nº Proyecto")
            {
                ApplicationArea = All;
            }
            field("Nº Contrato"; Rec."Nº Contrato")
            {
                ApplicationArea = All;
            }
            field("Fecha inicial proyecto"; Rec."Fecha inicial proyecto")
            {
                ApplicationArea = all;
            }
            field("Fecha fin proyecto"; Rec."Fecha fin proyecto")
            {
                ApplicationArea = All;
            }
            field("Pte firma cliente"; Rec."Pte firma cliente")
            {
                ApplicationArea = All;

            }
            field("Importe (calc.)"; TotalSalesLine.Amount)
            {
                ApplicationArea = All;
            }
            field("Importe IVA incl. (calc.)"; TotalSalesLine."Amount Including VAT")
            {
                ApplicationArea = All;
            }
            field(Renovado; Rec.Renovado)
            {
                ApplicationArea = All;
            }
            field("Interc./Compens."; Rec."Interc./Compens.")
            {
                ApplicationArea = All;
            }
            field("Proyecto origen"; Rec."Proyecto origen")
            {
                ApplicationArea = All;
            }
            field("Fecha inicial factura"; Rec."Fecha inicial factura")
            {
                ApplicationArea = All;
            }
            field("Fecha final factura"; Rec."Fecha final factura")
            {
                ApplicationArea = All;
            }
            field("Fecha renovacion"; Rec."Fecha renovacion")
            {
                ApplicationArea = All;
            }
            field("Contrato original"; "Contrato original")
            {
                ApplicationArea = All;
            }
            field("Contrato origen"; "Contrato origen")
            {
                ApplicationArea = All;
            }
            field("Contrato renovado"; "Contrato renovado")
            {
                ApplicationArea = All;
            }
            field("Esperar Orden Cliente"; Rec."Esperar Orden Cliente")
            {
                ApplicationArea = All;
            }
            field("Fecha cancelacion"; Rec."Fecha cancelacion")
            {
                ApplicationArea = All;
            }
            field("Nombre Empresa"; NEmpresa())
            {
                ApplicationArea = All;
            }
        }
    }
    actions
    {
        addafter("Test Report")
        {
            action("Imprimir &Factura Borrador")
            {
                Image = Document;
                ApplicationArea = All;
                Scope = Repeater;
                trigger OnAction()
                var
                    rCab2: Record "Sales Header";
                Begin
                    rCab2.RESET;
                    rCab2.SETRANGE("Document Type", Rec."Document Type"::Invoice);
                    rCab2.SETRANGE("No.", Rec."No.");
                    REPORT.RUNMODAL(REPORT::"Pre-Sales-Invoice Pdf", TRUE, FALSE, rCab2);
                End;
            }
        }
        addafter(Preview_Promoted)
        {
            actionref("Borrador_Promoted"; "Imprimir &Factura Borrador")
            {
            }
        }
    }


    var
        TotalSalesLine: Record "Sales Line";
        TotalSalesLineLCY: Record "Sales Line";
        rCabFac: Record "Sales Invoice Header";
        rCabAbo: Record "Sales Cr.Memo Header";
        RegisVtas: Codeunit "Sales-Post";
        wDecimal: Decimal;
        wTexto: Text[30];
        ImpBorFac: Decimal;
        ImpBorAbo: Decimal;
        ImpFac: Decimal;
        ImpAbo: Decimal;
        TotImp: Decimal;
        TotCont: Decimal;
        wVer: Option Todos,Defecto,Exceso;
        "Contrato original": Code[20];
        "Contrato origen": Code[20];
        "Contrato renovado": Code[20];
        Empresa: Text[30];
        BImpBorFac: Decimal;
        BImpBorAbo: Decimal;
        BImpFac: Decimal;
        BImpAbo: Decimal;
        BTotImp: Decimal;
        BTotCont: Decimal;
        Color: Text[30];
        DocumentType: enum "Gen. Journal Document Type";

    trigger OnOpenPage()
    BEGIN
        AplicarFiltros;                          //$004
        if Empresa <> '' THEN Rec.CHANGECOMPANY(Empresa);
    END;

    trigger OnAfterGetRecord()
    var
        Cust: Record Customer;
    BEGIN
        if Empresa <> '' THEN Rec.CHANGECOMPANY(Empresa);
        CalcularTotales(Rec."No.");              //FCL-17/05/04
                                                 // $002 -
        if Empresa <> '' THEN
            TotalesDocumentosEmpresa(Rec, Empresa)
        ELSE
            TotalesDocumentos(Rec."No.");
        // $002+
        if ABS(TotalSalesLine.Amount) < 1 Then begin
            if not cust.Get(Rec."Sell-to Customer No.") then
                Cust.Init;
            if Cust."Generar facturas a 0" Then
                documentType := DocumentType::Invoice
            else
                DocumentType := DocumentType::Shipment;
        end else
            DocumentType := DocumentType::Invoice;
        Color := '';
        if DocumentType = DocumentType::Shipment Then begin
            if TotalSalesLine."Amount Including VAT" <> 0 then
                if TotalSalesLine."Amount Including VAT" <> 0 then
                    Color := 'Unfavorable'
                else
                    Color := 'Attention';
        end;
        BuscarProyectos;                    //$003
    END;

    PROCEDURE CalcularTotales(pNumDoc: Code[20]);
    VAR
        TempSalesLine: Record 37 TEMPORARY;
    BEGIN
        //FCL-04/05/04. Obtengo total y total iva incluído, ya no me sirve el campo calculado
        // porque estos importes están a cero en las líneas.
        // JML 150704 Modificado para poder filtrar por fase.
        // $001 por tarea

        CLEAR(TotalSalesLine);
        CLEAR(TotalSalesLineLCY);

        if pNumDoc <> '' THEN BEGIN
            CLEAR(RegisVtas);
            CLEAR(TempSalesLine);
            RegisVtas.GetSalesLines(Rec, TempSalesLine, 0);
            CLEAR(RegisVtas);

            RegisVtas.SumSalesLinesTemp(
              Rec, TempSalesLine, 0, TotalSalesLine, TotalSalesLineLCY,
              wDecimal, wTexto, wDecimal, wDecimal, wDecimal);

            //  JML 150704
            //  RegisVtas.SumSalesLinesTempFase(Rec,TempSalesLine,0,TotalSalesLine,
            //                              TotalSalesLineLCY, GETFILTER("Filtro fase"));

        END;
    END;

    PROCEDURE TotalesDocumentos(wNum: Code[20]);
    VAR
        TempSalesLine: Record 37 TEMPORARY;
        rCabVenta: Record 36;
    BEGIN
        //$002 Obtengo totales de borradores y facturas correspondientes a este contrato.

        ImpBorFac := 0;
        ImpBorAbo := 0;
        ImpFac := 0;
        ImpAbo := 0;
        TotImp := 0;
        TotCont := 0;

        //if ("Borradores de Factura" <> 0) OR ("Borradores de Abono" <> 0) THEN BEGIN
        if (wNum <> '') THEN BEGIN

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

        //FCL-13/02/06. Incluyo sumatorio de totales y diferencia con el total del contrato.
        TotImp := ImpBorFac - ImpBorAbo + ImpFac - ImpAbo;

        if rCabVenta.GET(rCabVenta."Document Type"::Order, Rec."No.") THEN BEGIN
            CLEAR(TotalSalesLine);
            CLEAR(TotalSalesLineLCY);
            CLEAR(RegisVtas);
            CLEAR(TempSalesLine);
            RegisVtas.GetSalesLines(rCabVenta, TempSalesLine, 0);
            CLEAR(RegisVtas);
            RegisVtas.SumSalesLinesTemp(rCabVenta, TempSalesLine, 0, TotalSalesLine, TotalSalesLineLCY,
                                        wDecimal, wTexto, wDecimal, wDecimal, wDecimal);
            TotCont := TotalSalesLineLCY."Amount Including VAT";
        END;
    END;

    PROCEDURE BuscarProyectos();
    VAR
        rContrato: Record 36;
        rProyecto: Record 167;
        wCuantos: Integer;
    BEGIN
        // $003 Obtengo los contratos asociados a los proyectos original, origen y renovado.

        "Contrato origen" := '';
        "Contrato original" := '';
        "Contrato renovado" := '';

        if rProyecto.GET(Rec."Nº Proyecto") THEN BEGIN
            if rProyecto."Proyecto original" <> '' THEN BEGIN
                rContrato.RESET;
                rContrato.SETCURRENTKEY("Nº Proyecto");
                rContrato.SETRANGE("Nº Proyecto", rProyecto."Proyecto original");
                if rContrato.FINDFIRST THEN
                    "Contrato original" := rContrato."No.";
            END;
            if rProyecto."Proyecto origen" <> '' THEN BEGIN
                rContrato.RESET;
                rContrato.SETCURRENTKEY("Nº Proyecto");
                rContrato.SETRANGE("Nº Proyecto", rProyecto."Proyecto origen");
                if rContrato.FINDFIRST THEN
                    "Contrato origen" := rContrato."No.";
            END;
            //$005(I)
            wCuantos := 0;
            rProyecto.RESET;
            rProyecto.SETCURRENTKEY("Proyecto origen");
            rProyecto.SETRANGE("Proyecto origen", Rec."Nº Proyecto");
            wCuantos := rProyecto.COUNT;
            //$005(F)
            rProyecto.RESET;
            rProyecto.SETCURRENTKEY("Proyecto origen");
            rProyecto.SETRANGE("Proyecto origen", Rec."Nº Proyecto");
            //$005(I)
            if wCuantos > 0 THEN
                rProyecto.SETFILTER("No.", '<>%1', Rec."Nº Proyecto");
            //$005(F)
            if rProyecto.FINDFIRST THEN BEGIN
                rContrato.RESET;
                rContrato.SETCURRENTKEY("Nº Proyecto");
                rContrato.SETRANGE("Nº Proyecto", rProyecto."No.");
                if rContrato.FINDFIRST THEN
                    "Contrato renovado" := rContrato."No.";
            END;
        END;
    END;

    PROCEDURE AplicarFiltros();
    VAR
        rUsuario: Record 91;
    BEGIN
        //$004
        if rUsuario.GET(USERID) THEN BEGIN
            if rUsuario."Filtro vendedor" <> '' THEN BEGIN
                Rec.FILTERGROUP(2);
                Rec.SETFILTER("Salesperson Code", rUsuario."Filtro vendedor");
                Rec.FILTERGROUP(0);
            END;
        END;
    END;

    PROCEDURE TotalesDocumentosEmpresa(VAR Contrato: Record 36; Empresa: Text[30]);
    VAR
        rCabVenta: Record 36;
        rCabFac: Record 112;
        rCabAbo: Record 114;
        RegisVtas: Codeunit 80;
        rCabFacL: Record 113;
        rCabAboL: Record 115;
        SalesLine: Record 37;
        Importe: Decimal;
        Iva: Decimal;
        BImporte: Decimal;
    BEGIN
        //FCL-31/05/04. Obtengo totales de borradores y facturas correspondientes a este contrato.
        ImpBorFac := 0;
        ImpBorAbo := 0;
        ImpFac := 0;
        ImpAbo := 0;
        BImpBorFac := 0;
        BImpBorAbo := 0;
        BImpFac := 0;
        BImpAbo := 0;

        WITH Contrato DO BEGIN
            Contrato.CHANGECOMPANY(Empresa);
            if Estado = Estado::Anulado THEN BEGIN
                TotCont := 0;
                TotImp := 0;
                ImpBorFac := 0;
                ImpBorAbo := 0;
                ImpFac := 0;
                ImpAbo := 0;
                EXIT;
            END;
            if Estado = Estado::Cancelado THEN BEGIN
                TotCont := 0;
                TotImp := 0;
                ImpBorFac := 0;
                ImpBorAbo := 0;
                ImpFac := 0;
                ImpAbo := 0;
                EXIT;
            END;
            CALCFIELDS(Contrato."Abonos Registrados", Contrato."Facturas Registradas", Contrato."Borradores de Factura",
            Contrato."Borradores de Abono");
            //if ("Borradores de Factura" <> 0) OR ("Borradores de Abono" <> 0) THEN BEGIN
            rCabVenta.RESET;
            rCabVenta.CHANGECOMPANY(Empresa);
            rCabVenta.SETCURRENTKEY("Nº Proyecto");
            rCabVenta.SETRANGE("Nº Proyecto", "Nº Proyecto");
            rCabVenta.SETRANGE("Nº Contrato", "No.");
            rCabVenta.SETFILTER("Document Type", '%1|%2',
               rCabVenta."Document Type"::Invoice, rCabVenta."Document Type"::"Credit Memo");
            if rCabVenta.FIND('-') THEN BEGIN
                REPEAT
                    SalesLine.CHANGECOMPANY(Empresa);
                    SalesLine.SETRANGE(SalesLine."Document Type", rCabVenta."Document Type");
                    SalesLine.SETRANGE(SalesLine."Document No.", rCabVenta."No.");
                    Importe := 0;
                    BImporte := 0;
                    if SalesLine.FINDFIRST THEN
                        REPEAT
                            Importe += (SalesLine.Quantity * SalesLine."Unit Price" * (1 - SalesLine."Line Discount %" / 100)) * (1 + SalesLine."VAT %" / 100);
                            BImporte += (SalesLine.Quantity * SalesLine."Unit Price" * (1 - SalesLine."Line Discount %" / 100));
                        UNTIL SalesLine.NEXT = 0;
                    if rCabVenta."Document Type" = rCabVenta."Document Type"::Invoice THEN BEGIN
                        //$009(I)
                        //ImpBorFac:=ImpBorFac + TotalSalesLineLCY."Amount Including VAT";
                        ImpBorFac := ImpBorFac + Importe;
                        BImpBorFac := BImpBorFac + BImporte;
                        //$009(F)
                    END
                    ELSE BEGIN
                        //$009(I)
                        //ImpBorAbo:=ImpBorAbo + TotalSalesLineLCY."Amount Including VAT";
                        ImpBorAbo := ImpBorAbo + Importe;
                        BImpBorAbo := BImpBorAbo + BImporte;
                        //$009(F)
                    END;
                UNTIL rCabVenta.NEXT = 0;
            END;

            //END;

            //if "Facturas Registradas" <> 0 THEN BEGIN

            rCabFac.RESET;
            rCabFac.CHANGECOMPANY(Empresa);
            rCabFacL.CHANGECOMPANY(Empresa);
            rCabFac.SETCURRENTKEY("Nº Proyecto", "Nº Contrato");
            rCabFac.SETRANGE("Nº Contrato", "No.");
            if rCabFac.FIND('-') THEN BEGIN
                REPEAT
                    rCabFacL.SETRANGE(rCabFacL."Document No.", rCabFac."No.");
                    if rCabFacL.FINDFIRST THEN
                        rCabFacL.CALCSUMS(rCabFacL."Amount Including VAT", Amount)
                    ELSE
                        rCabFacL.INIT;
                    ImpFac := ImpFac + rCabFacL."Amount Including VAT";
                    BImpFac := BImpFac + rCabFacL.Amount;
                UNTIL rCabFac.NEXT = 0;
            END;

            //END;

            //if "Abonos Registrados" <> 0 THEN BEGIN

            rCabAbo.RESET;
            rCabAbo.CHANGECOMPANY(Empresa);
            rCabAboL.CHANGECOMPANY(Empresa);
            rCabAbo.SETCURRENTKEY("Nº Proyecto", "Nº Contrato");
            rCabAbo.SETRANGE("Nº Contrato", "No.");
            if rCabAbo.FIND('-') THEN BEGIN
                REPEAT
                    rCabAboL.SETRANGE(rCabAboL."Document No.", rCabAbo."No.");
                    if rCabAboL.FINDFIRST THEN
                        rCabAboL.CALCSUMS(rCabAboL."Amount Including VAT", Amount)
                    ELSE
                        rCabAboL.INIT;
                    ImpAbo := ImpAbo + rCabAboL."Amount Including VAT";
                    BImpAbo := BImpAbo + rCabAboL.Amount;
                //$009(F)
                UNTIL rCabAbo.NEXT = 0;
            END;

            //END;

            //FCL-13/02/06. Incluyo sumatorio de totales y diferencia con el total del contrato.
            TotImp := ImpBorFac - ImpBorAbo + ImpFac - ImpAbo;
            BTotImp := BImpBorFac - BImpBorAbo + BImpFac - BImpAbo;
            rCabVenta.CHANGECOMPANY(Empresa);
            if rCabVenta.GET(rCabVenta."Document Type"::Order, "No.") THEN BEGIN
                SalesLine.CHANGECOMPANY(Empresa);
                SalesLine.SETRANGE(SalesLine."Document Type", rCabVenta."Document Type");
                SalesLine.SETRANGE(SalesLine."Document No.", rCabVenta."No.");
                Importe := 0;
                BImporte := 0;
                if SalesLine.FINDFIRST THEN
                    REPEAT
                        Importe += (SalesLine.Quantity * SalesLine."Unit Price" * (1 - SalesLine."Line Discount %" / 100)) * (1 + SalesLine."VAT %" / 100);
                        BImporte += (SalesLine.Quantity * SalesLine."Unit Price" * (1 - SalesLine."Line Discount %" / 100));
                        Iva := SalesLine."VAT %";
                    UNTIL SalesLine.NEXT = 0;

                TotCont := Importe;
                BTotCont := BImporte;
            END;
        END;
        if ABS((BImpBorFac - BImpBorAbo) + (BTotCont - BTotImp)) < 1 THEN BEGIN
            BImpBorFac := BImpBorFac * (1 + Iva / 100);
            ImpBorAbo := BImpBorAbo * (1 + Iva / 100);
            ImpFac := BImpFac * (1 + Iva / 100);
            ImpAbo := BImpAbo * (1 + Iva / 100);
            TotImp := BTotImp * (1 + Iva / 100);
            TotCont := BTotCont * (1 + Iva / 100);
        END;
    END;

    PROCEDURE CambiarEmpresa(Emp: Text[30]);
    BEGIN
        Empresa := Emp;
    END;

    local procedure NEmpresa(): Text
    begin
        if Empresa = '' Then exit(CompanyName);
        exit(Empresa);
    end;

    local procedure Vendedor(SalespersonCode: Code[20]): Text
    var
        SalesPerson: Record "Salesperson/Purchaser";
    begin
        if SalesPerson.Get(SalespersonCode) then exit(SalesPerson.Name);
    end;

    PROCEDURE NC(): Text[250];
    VAR
        r270: Record 270;
        r289: Record 289;
    BEGIN
        if NOT r289.GET(Rec."Payment Method Code") THEN BEGIN
            exit
        END ELSE BEGIN
            if (Rec."Nuestra Cuenta" = '') And (Rec."Nuestra Cuenta Prepago" <> '') Then Rec."Nuestra Cuenta" := Rec."Nuestra Cuenta Prepago";
            if r270.GET(Rec."Nuestra Cuenta") THEN BEGIN
                if r270.IBAN <> '' Then exit(r270.IBAN);
                EXIT(r270."CCC Bank No." + '-' + r270."CCC Bank Branch No." + '-' + r270."CCC Control Digits" +
                '-' + r270."CCC Bank Account No.");
            END ELSE BEGIN
                if r289."Bill Type" = r289."Bill Type"::Transfer THEN BEGIN
                    exit('Especifique Nº de banco en:' + Rec."Nuestra Cuenta");

                END;
            END;
        END;
    END;



    // BEGIN
    // {
    //   $001 MNC 290708 para migracion a 5.0, no tenemos fase, tenemos tarea
    //   $002 MNC 170609 Campos total y diferencia
    //   $003 FCL 310510 Campos referentes a renovación
    //   $004 FCL-050710. Aplico filtros por vendedor definidos en la tabla de usuarios.
    //   $005 FCL 191010 Al buscar el proyecto original tengo en cuenta que puede haber dos, en este caso
    //                   cogeré aquel cuyo nº proyecto origen sea distinto a nº proyecto.
    // }
    // END.

}
