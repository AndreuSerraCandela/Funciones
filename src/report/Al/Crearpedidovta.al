/// <summary>
/// Report Proceso crear pedido vta. (ID 50000).
/// </summary>
report 50000 "Proceso crear pedido vta."
{
    UseRequestPage = false;
    ProcessingOnly = true;
    dataset
    {
        dataitem(Integer; Integer)
        {
            DataItemTableView = sorting(Number) where(Number = const(1));
            trigger OnAfterGetRecord()
            BEGIN
                SalesHeader.LOCKTABLE;
                SalesLine.LOCKTABLE;
                ConfVtas.LOCKTABLE;
                rComentVenta.LOCKTABLE;
                ConfVtas.GET;
                ConfVtas.TESTFIELD("Order Nos.");
                ConfVtas.TESTFIELD("Posted Invoice Nos.");
                ConfVtas.TESTFIELD("Posted Shipment Nos.");
                ConfVtas.TESTFIELD("Posted Prepmt. Inv. Nos.");
                CLEAR(SalesHeader);
                SalesHeader."Document Type" := SalesHeader."Document Type"::Order;
                SalesHeader."No." := GestNoSer.GetNextNo(ConfVtas."Order Nos.", WORKDATE, TRUE);
                SalesHeader.INSERT(FALSE);
                SalesHeader.VALIDATE("No. Series", ConfVtas."Order Nos.");
                SalesHeader.VALIDATE("Posting No. Series", ConfVtas."Posted Invoice Nos.");
                SalesHeader.VALIDATE("Shipping No. Series", ConfVtas."Posted Shipment Nos.");
                SalesHeader.VALIDATE("Prepayment No. Series", ConfVtas."Posted Prepmt. Inv. Nos.");
                SalesHeader.VALIDATE("Posting Date", Proyecto."Starting Date");
                SalesHeader.VALIDATE("Document Date", SalesHeader."Posting Date");
                SalesHeader.VALIDATE("Shipment Date", WORKDATE);
                SalesHeader.VALIDATE("Order Date", WORKDATE);
                SalesHeader.VALIDATE("Posting Description", FORMAT(SalesHeader."Document Type") + ' ' + SalesHeader."No.");
                SalesHeader.VALIDATE("Sell-to Customer No.", Proyecto."Bill-to Customer No.");
                SalesHeader.VALIDATE("Your Reference", 'Proyecto ' + Proyecto."No.");
                SalesHeader.VALIDATE("Nº Proyecto", Proyecto."No.");
                SalesHeader.VALIDATE("Salesperson Code", Proyecto."Cód. vendedor");
                SalesHeader.VALIDATE("Posting Description", Proyecto.Description);
                SalesHeader.VALIDATE("Fecha inicial proyecto", Proyecto."Starting Date");
                SalesHeader.VALIDATE("Fecha fin proyecto", Proyecto."Ending Date");
                Proyecto.TestField("Global Dimension 1 Code");
                Proyecto.TestField("Nombre Comercial");
                SalesHeader.VALIDATE("Shortcut Dimension 1 Code", Proyecto."Global Dimension 1 Code");
                SalesHeader.VALIDATE("Shortcut Dimension 2 Code", Proyecto."Global Dimension 2 Code");
                if Proyecto."Esperar Orden Cliente" = TRUE THEN
                    SalesHeader.VALIDATE("Esperar Orden Cliente", SalesHeader."Esperar Orden Cliente"::"Sí");
                SalesHeader.VALIDATE(Tipo, Proyecto.Tipo);
                SalesHeader.VALIDATE(Firmado, Proyecto.Firmado);
                SalesHeader.VALIDATE("Fecha Firma", Proyecto."Fecha Firma");
                SalesHeader.VALIDATE(Subtipo, Proyecto.Subtipo);
                SalesHeader.VALIDATE("Soporte de", Proyecto."Soporte de");
                SalesHeader.VALIDATE("Interc./Compens.", Proyecto."Interc./Compens.");         //FCL-18/05/04
                SalesHeader.VALIDATE("Proyecto origen", Proyecto."Proyecto original");          //FCL-18/05/04
                SalesHeader.VALIDATE(Renovado, Proyecto.Renovado);                   //FCL-18/05/04
                SalesHeader.VALIDATE("External Document No.", Proyecto."No Documento externo");     //$010
                                                                                                    //$012(I)
                                                                                                    // if Proyecto."Cod forma pago" <> '' THEN
                                                                                                    //   SalesHeader.VALIDATE("Payment Method Code", Proyecto."Cod forma pago");

                if Proyecto."Payment Method Code" <> '' then SalesHeader.VALIDATE("Payment Method Code", Proyecto."Payment Method Code");
                if Proyecto."Payment Terms Code" <> '' then SalesHeader.VALIDATE("Payment Terms Code", Proyecto."Payment Terms Code");
                //$012(F)
                rClient.GET(SalesHeader."Sell-to Customer No.");
                if rClient."Cód. envio genérico" <> '' THEN
                    SalesHeader.VALIDATE("Ship-to Code", rClient."Cód. envio genérico");
                if Proyecto."Nombre Comercial" <> '' Then SalesHeader."Nombre Comercial" := Proyecto."Nombre Comercial";
                SalesHeader.MODIFY(FALSE);
                //{ *** Tambien se traspasan los comentarios *** }
                rComentProy.SETCURRENTKEY("Table Name", "No.", "Line No.");
                rComentProy.SETRANGE("Table Name", rComentProy."Table Name"::Job);
                rComentProy.SETRANGE("No.", Proyecto."No.");
                if rComentProy.FIND('-') THEN
                    REPEAT
                        rComentVenta.INIT;
                        rComentVenta."Document Type" := SalesHeader."Document Type";
                        rComentVenta."No." := SalesHeader."No.";
                        rComentVenta."Line No." := rComentProy."Line No.";
                        rComentVenta.Date := rComentProy.Date;
                        rComentVenta.Code := rComentProy.Code;
                        rComentVenta.Comment := rComentProy.Comment;
                        rComentVenta.INSERT;
                    UNTIL rComentProy.NEXT = 0;
                /* { Los filtros ya vienen desde el codeunit
                JobPlanningLine.RESET;
                JobPlanningLine.SETCURRENTKEY("Nº proyecto","Crear pedidos","Compra a-Nº proveedor");
                JobPlanningLine.SETRANGE("Nº proyecto", Proyecto."Nº"); } */

                ult := 10000;
                if JobPlanningLine.FIND('-') THEN
                    REPEAT
                        CLEAR(SalesLine);
                        SalesLine."Document Type" := SalesHeader."Document Type";
                        SalesLine."Document No." := SalesHeader."No.";
                        SalesLine."Line No." := ult;
                        ult += 10000;
                        SalesLine.INSERT;
                        SalesLine.VALIDATE("Sell-to Customer No.", SalesHeader."Sell-to Customer No.");
                        CASE JobPlanningLine.Type OF
                            JobPlanningLine.Type::"G/L Account":
                                SalesLine.VALIDATE(Type, SalesLine.Type::"G/L Account");
                            JobPlanningLine.Type::Item:
                                SalesLine.VALIDATE(Type, SalesLine.Type::Item);
                            JobPlanningLine.Type::Resource:
                                SalesLine.VALIDATE(Type, SalesLine.Type::Resource);
                            JobPlanningLine.Type::Familia:
                                SalesLine.VALIDATE(Type, SalesLine.Type::"G/L Account");
                        END;
                        if (JobPlanningLine.Type <> JobPlanningLine.Type::Familia) THEN BEGIN
                            SalesLine.VALIDATE("No.", JobPlanningLine."No.");
                            SalesLine.VALIDATE(Description, JobPlanningLine.Description);
                            if (JobPlanningLine.Type = JobPlanningLine.Type::Resource) THEN BEGIN
                                rRecurs.GET(JobPlanningLine."No.");
                                if (rRecurs."Enunciado Cto. Venta" <> '') THEN
                                    SalesLine.VALIDATE(Description, rRecurs."Enunciado Cto. Venta");
                            END;
                        END ELSE BEGIN
                            rFamilia.GET(JobPlanningLine."No.");
                            rGCP.GET(rFamilia."Grupo contable producto");
                            rGCN.GET(SalesHeader."Gen. Bus. Posting Group");
                            rCGC.GET(rGCN.Code, rGCP.Code);
                            SalesLine.VALIDATE("No.", rCGC."Sales Account");
                            SalesLine.VALIDATE("Gen. Bus. Posting Group", rGCN.Code);
                            SalesLine.VALIDATE("Gen. Prod. Posting Group", rGCP.Code);
                            SalesLine.VALIDATE(Description, JobPlanningLine.Description);
                            // En el caso de Fam. recurso supongo que debe aplicarse a una cuenta contable
                        END;
                        //$013(I)
                        if (JobPlanningLine.Type = JobPlanningLine.Type::Resource) THEN
                            SalesLine.VALIDATE("Cód. proveedor", JobPlanningLine."Compra a-Nº proveedor");
                        //$013(F)
                        SalesLine.VALIDATE("Job No.", JobPlanningLine."Job No.");               //FCL-28/02/06. Muevo aquí la línea, se machacaba cód.programa.
                        SalesLine.VALIDATE("Shortcut Dimension 1 Code", JobPlanningLine."Shortcut Dimension 1 Code");
                        SalesLine.VALIDATE("Shortcut Dimension 2 Code", JobPlanningLine."Shortcut Dimension 2 Code");
                        SalesLine.VALIDATE("Shortcut Dimension 3 Code", JobPlanningLine."Shortcut Dimension 3 Code");
                        SalesLine.VALIDATE("Shortcut Dimension 4 Code", JobPlanningLine."Shortcut Dimension 4 Code");
                        SalesLine.VALIDATE("Shortcut Dimension 5 Code", JobPlanningLine."Shortcut Dimension 5 Code");

                        SalesLine.ValidateShortcutDimCode(3, JobPlanningLine."Shortcut Dimension 3 Code");
                        SalesLine.ValidateShortcutDimCode(4, JobPlanningLine."Shortcut Dimension 4 Code");
                        SalesLine.ValidateShortcutDimCode(5, JobPlanningLine."Shortcut Dimension 5 Code");
                        //SalesLine.VALIDATE("Job No.", JobPlanningLine."Job No.");               //FCL-28/02/06.
                        /* { $001
                          SalesLine.VALIDATE("Phase Code", JobPlanningLine."Phase Code");
                          SalesLine.VALIDATE("Task Code", JobPlanningLine."Task Code");
                        } */
                        SalesLine.VALIDATE(SalesLine."Job Task No.", JobPlanningLine."Job Task No.");

                        // mig 5.0     JobPlanningLine.CALCFIELDS(Quantity);
                        SalesLine.VALIDATE(Quantity, JobPlanningLine.Quantity);
                        SalesLine.VALIDATE("Unit Price", JobPlanningLine."Unit Price");
                        SalesLine.Validate("Precio Compra", JobPlanningLine."Unit Cost");
                        SalesLine.Validate("Dto. Compra", JobPlanningLine."% Dto. Compra");
                        SalesLine.VALIDATE("Line Discount %", JobPlanningLine."% Dto. Venta");
                        SalesLine."Dto. Tarifa" := JobPlanningLine."Dto. Tarifa";
                        SalesLine."% Dto. Venta 1" := JobPlanningLine."% Dto. Venta 1";
                        SalesLine."% Dto. Venta 2" := JobPlanningLine."% Dto. Venta 2";
                        SalesLine."Precio Tarifa" := JobPlanningLine."Precio Tarifa";
                        SalesLine."Line Discount %" := JobPlanningLine."% Dto. Venta";
                        SalesLine."Tipo Duracion" := JobPlanningLine."Tipo Duracion";
                        SalesLine.Duracion := JobPlanningLine.Duracion;
                        SalesLine."Cdad. Soportes" := JobPlanningLine."Cdad. Soportes";  //  // $004
                        SalesLine.VALIDATE(Reparto, JobPlanningLine.Reparto);                                      //FCL-16/02/06
                        SalesLine."Fecha inicial recurso" := JobPlanningLine."Planning Date";              //$006
                        SalesLine."Fecha final recurso" := JobPlanningLine."Fecha Final";                  //$006
                        SalesLine.VALIDATE("No linea proyecto", JobPlanningLine."Line No.");                       //$008

                        // $003-
                        JobPlanningLine.CALCFIELDS("No. Orden Publicidad");
                        if (JobPlanningLine."No. Orden Publicidad" <> '') THEN BEGIN
                            SalesLine."No. Orden Publicidad" := JobPlanningLine."No. Orden Publicidad";
                            CLEAR(rOrden);
                            if rOrden.GET(JobPlanningLine."No. Orden Publicidad") THEN BEGIN
                                // Primera linea para nombre medio
                                SalesLine.VALIDATE(Description, rOrden."Nombre Soporte");
                            END;
                        END ELSE BEGIN
                            ///SalesLine.VALIDATE("Description 2", (STRSUBSTNO('%1',JobPlanningLine."Planning Date") + ' - ' +       //$011
                            ///                                STRSUBSTNO('%1',JobPlanningLine."Fecha Final")));                //$011
                        END;
                        // $003+
                        SalesLine.VALIDATE("Description 2", JobPlanningLine."Description 2");                                       //$011
                        SalesLine.VALIDATE(Remarcar, JobPlanningLine.Remarcar);                                                     //$014
                        if Not JobPlanningLine."Imprmir en Contrato/Factura" Then SalesLine.Imprimir := false;
                        if SalesLine."Line Amount" <> 0 then SalesLine.Imprimir := true;
                        SalesLine."Precio Tarifa" := JobPlanningLine."Precio Tarifa";
                        SalesLine."Dto. Tarifa" := JobPlanningLine."Dto. Tarifa";
                        SalesLine.Duracion := JobPlanningLine.Duracion;
                        SalesLine."Cdad. Soportes" := JobPlanningLine."Cdad. Soportes";  //
                        SalesLine.MODIFY;

                        // $002  y parte del $003
                        if (JobPlanningLine."No. Orden Publicidad" <> '') THEN BEGIN
                            CLEAR(rOrden);
                            if rOrden.GET(JobPlanningLine."No. Orden Publicidad") THEN BEGIN
                                // Linea para el nombre del recurso
                                rRecurso.GET(rOrden.Concepto);
                                Inserta_Linea(rRecurso.Name);

                                // Linea para Seccion
                                if (rOrden.Seccion <> '') THEN
                                    Inserta_Linea(STRSUBSTNO('Seccion: %1', rOrden.Seccion));

                                // Linea para alto/ancho
                                if ((rOrden.Alto <> 0) AND (rOrden.Ancho <> 0)) THEN
                                    Inserta_Linea(STRSUBSTNO('(Alto x Ancho): %1 x %2', rOrden.Alto, rOrden.Ancho));

                                // Linea para recargo si hay
                                if (rOrden.Recargo <> 0) THEN
                                    Inserta_Linea(STRSUBSTNO('Recargo: %1', rOrden.Recargo));

                                // Linea para tarifas y dias
                                Lineas_Dias;

                            END;
                        END;
                        rTexto.SETRANGE("Nº proyecto", JobPlanningLine."Job No.");
                        rTexto.SETRANGE("Nº linea aux", JobPlanningLine."Line No.");
                        rTexto.SETRANGE("Cód. tarea", JobPlanningLine."Job Task No.");                      //$009
                        rTexto.SETFILTER("Tipo linea", '%1|%2', rTexto."Tipo linea"::Ambos, rTexto."Tipo linea"::Venta);
                        if rTexto.FINDSET THEN
                            REPEAT
                                if (rTexto.Texto <> '') THEN BEGIN
                                    CLEAR(SalesLine);
                                    SalesLine."Document Type" := SalesHeader."Document Type";
                                    SalesLine."Document No." := SalesHeader."No.";
                                    SalesLine."Line No." := ult;
                                    ult += 1000;
                                    SalesLine.INSERT;
                                    SalesLine.Type := SalesLine.Type::" ";
                                    SalesLine.Description := rTexto.Texto;
                                    SalesLine.VALIDATE(Remarcar, rTexto.Remarcar);                             //$014
                                    SalesLine.MODIFY;
                                END;
                            UNTIL rTexto.NEXT = 0;
                    // $002+ y $003+

                    UNTIL JobPlanningLine.NEXT = 0;
            END;
        }
    }
    requestpage
    {
        layout
        {
            area(content)
            {
                group(GroupName)
                {
                }
            }
        }
        actions
        {
            area(processing)
            {
            }
        }
    }
    VAR
        ConfVtas: Record "Sales & Receivables Setup";
        Proyecto: Record Job;
        JobPlanningLine: Record "Job Planning Line";
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        rGCP: Record "Gen. Product Posting Group";
        rGCN: Record "Gen. Business Posting Group";
        rCGC: Record "General Posting Setup";
        rFamilia: Record "Resource Group";
        rComentVenta: Record "Sales Comment Line";
        rComentProy: Record "Comment Line";
        rRecurs: Record "Resource";
        rClient: Record "Customer";
        rTexto: Record "Texto Presupuesto";
        rOrden: Record "Cab. orden publicidad";
        SalesLineOrden: Record "Lin. orden publicidad";
        rRecurso: Record "Resource";
#if CLEAN24
#pragma warning disable AL0432
        GestNoSer: Codeunit NoSeriesManagement;
#pragma warning restore AL0432
#else
        GestNoSer: Codeunit "No. Series";
#endif
        ult: Integer;

    PROCEDURE Coge_Registros(VAR rP: Record Job; VAR rL: Record "Job Planning Line");
    BEGIN
        Proyecto := rP;
        Proyecto.COPYFILTERS(rP);
        JobPlanningLine := rL;
        JobPlanningLine.COPYFILTERS(rL);
    END;

    PROCEDURE Lineas_Dias();
    VAR
        wDiasAux: Code[10];
        wDescAux: Text[60];
        wMes: Text[30];
        wPrimero: Boolean;
        wPorDias: Boolean;
    BEGIN
        //$005. Sustituyo el formato de estas líneas.
        /* {
        CLEAR(SalesLineOrden);
        CLEAR(wDescAux);
        SalesLineOrden.SETCURRENTKEY("Tipo orden","No. orden","Dia tarifa",Concepto,"Fecha inicio");
        SalesLineOrden.SETRANGE("No. orden", rOrden.No);
        CLEAR(wDiasAux);
        if SalesLineOrden.FINDSET THEN REPEAT
          wPrimero := FALSE;
          if (SalesLineOrden."Dia tarifa" <> wDiasAux) THEN BEGIN
            if (wDiasAux <> '') THEN BEGIN
              Inserta_Linea(wDescAux);
              CLEAR(wDescAux);
            END;
            wDiasAux := SalesLineOrden."Dia tarifa";
            wDescAux := STRSUBSTNO('(%1): ', SalesLineOrden."Dia tarifa");
            wPrimero := TRUE;
          END;
          if NOT wPrimero THEN
            wDescAux += ',';
          wDescAux += FORMAT(SalesLineOrden."Fecha inicio");
          if (STRLEN(wDescAux)>=41) THEN BEGIN
            Inserta_Linea(wDescAux);
            CLEAR(wDescAux);
          END;
        UNTIL SalesLineOrden.NEXT = 0;
        Inserta_Linea(wDescAux);
        } */

        CLEAR(SalesLineOrden);
        CLEAR(wDescAux);
        CLEAR(wDiasAux);
        wPrimero := FALSE;
        wPorDias := FALSE;
        SalesLineOrden.RESET;
        SalesLineOrden.SETCURRENTKEY("Tipo orden", "No. orden", "Fecha inicio");  //Se incluyen todas las fechas
        SalesLineOrden.SETRANGE("No. orden", rOrden.No);
        ////SalesLineOrden.SETFILTER(Precio, '<>%1', 0);                        //$007
        SalesLineOrden.SETFILTER(Inserciones, '>%1', 1);
        if SalesLineOrden.FINDFIRST THEN BEGIN
            wPorDias := TRUE;
            SalesLineOrden.SETRANGE(Inserciones);
        END
        ELSE BEGIN
            SalesLineOrden.SETRANGE(Inserciones);
            SalesLineOrden.SETFILTER(Observaciones, '<>%1', '');
            if SalesLineOrden.FINDFIRST THEN BEGIN
                wPorDias := TRUE;
            END;
            SalesLineOrden.SETRANGE(Observaciones);
        END;

        if SalesLineOrden.FINDSET THEN
            REPEAT
                if wPorDias THEN BEGIN
                    if wDescAux <> '' THEN
                        wDescAux := wDescAux + ' | ';
                    wDescAux := wDescAux + FORMAT(SalesLineOrden."Fecha inicio");
                    if SalesLineOrden.Inserciones > 1 THEN
                        wDescAux := wDescAux + '=' + FORMAT(SalesLineOrden.Inserciones);
                    if (STRLEN(wDescAux) >= 40) THEN BEGIN
                        Inserta_Linea(COPYSTR(wDescAux, 1, 50));
                        CLEAR(wDescAux);
                    END;
                END
                ELSE BEGIN
                    if FORMAT(DATE2DMY(SalesLineOrden."Fecha inicio", 3)) + FORMAT(DATE2DMY(SalesLineOrden."Fecha inicio", 2)) <> wDiasAux THEN BEGIN
                        if (wDiasAux <> '') THEN BEGIN
                            Inserta_Linea(COPYSTR(wDescAux, 1, 50));
                            CLEAR(wDescAux);
                        END;
                        wMes := ObtenerMes(SalesLineOrden."Fecha inicio" - DATE2DMY(SalesLineOrden."Fecha inicio", 1) + 1);
                        //$007
                        //wDescAux:=wMes + ' ' + FORMAT(DATE2DMY(SalesLineOrden."Fecha inicio",3)) + ':';
                        wDescAux := SalesLineOrden."Dia tarifa" + ' ' + wMes + ' ' + FORMAT(DATE2DMY(SalesLineOrden."Fecha inicio", 3)) + ':';
                        wDiasAux := FORMAT(DATE2DMY(SalesLineOrden."Fecha inicio", 3)) + FORMAT(DATE2DMY(SalesLineOrden."Fecha inicio", 2));
                    END
                    ELSE BEGIN
                        if wDescAux <> '' THEN
                            wDescAux := wDescAux + ',';
                    END;
                    wDescAux := wDescAux + FORMAT(DATE2DMY(SalesLineOrden."Fecha inicio", 1));
                    if (STRLEN(wDescAux) >= 46) THEN BEGIN
                        wDescAux := wDescAux + ',';
                        Inserta_Linea(COPYSTR(wDescAux, 1, 50));
                        CLEAR(wDescAux);
                    END;
                END;
            UNTIL SalesLineOrden.NEXT = 0;
        Inserta_Linea(COPYSTR(wDescAux, 1, 50));
    END;

    PROCEDURE Inserta_Linea(wDescripcion: Text[100]);
    BEGIN
        CLEAR(SalesLine);
        SalesLine."Document Type" := SalesHeader."Document Type";
        SalesLine."Document No." := SalesHeader."No.";
        SalesLine."Line No." := ult;
        ult += 1000;
        SalesLine.INSERT;
        SalesLine.Type := SalesLine.Type::" ";
        SalesLine.Description := wDescripcion;
        SalesLine.MODIFY;

    END;

    PROCEDURE ObtenerMes(pFecha: Date): Text[30];
    VAR
        rFecha: Record 2000000007;
    BEGIN
        rFecha.RESET;
        rFecha.SETRANGE("Period Type", rFecha."Period Type"::Month);      //filtro por dia 1 del mes para obtener descr.mes
        rFecha.SETRANGE("Period Start", pFecha);
        if rFecha.FINDFIRST THEN
            EXIT(rFecha."Period Name")
        ELSE
            EXIT('');
    END;

    /*   $001 MNC 050808 migracion 5.0
      $002 MNC 270309 Cambio sistema Texto ampliado lineas, en ventas
      $003 MNC 020609 Cuando tiene orden publicidad, cambio texto descripcion
      $004 MNC 060809 A¤ado % dto ventas
      $005 FCL 260310 Modifico la parte correspondiente al texto de la descripción de los días,
                      para adaptarla al nuevo formato del borrador de factura.
      $006 FCL 290310 Grabo fechas inicial y final recurso.
      $007 FCL 080410 Al grabar texto con nº dias elimino filtro precio 0 y a¤ado nº dias en texto.
      $008 FCL 160410 Grabo nº linea proyecto, para tener enlazadas las líneas de factura con las de proyecto.
      $009 FCL 035010 Para grabar las líneas de texto presupuesto incluyo filtro por nº tarea,
                      ya que no se copian las líneas correctamente.
      $010 FCL 140610 Incluyo la grabación de nº documento externo.
      $011 FCL 220710 Grabo descripción 2 que viene del proyecto.
      $012 FCL 230810 Grabo la forma de pago del proyecto si es distinta de blanco. Si est  en blanco
                      se grabar  la del cliente, como hacía hasta ahora.
      $013 FCL 310111 Para tipo recurso cogeré el proveedor de la línea de presupuesto (OnValidate de lin. venta lo coge del recurso).
      $014 FCL 300511 Grabo el campo Remarcar en la línea de detalle. */



}
Report 50001 "Proceso crear pedido compra"
{
    UseRequestPage = false;
    ProcessingOnly = true;
    dataset
    {
        dataitem(Integer; Integer)
        {
            DataItemTableView = SORTING(Number)
                          WHERE(Number = CONST(1));
            trigger OnAfterGetRecord()
            BEGIN
                PurchaseHeader.LOCKTABLE;
                PurchaseLine.LOCKTABLE;
                ConfCompra.LOCKTABLE;
                rComentCompra.LOCKTABLE;
                ConfCompra.GET;
                ConfCompra.TESTFIELD("Order Nos.");
                ConfCompra.TESTFIELD("Posted Invoice Nos.");
                ConfCompra.TESTFIELD("Posted Receipt Nos.");
                CLEAR(PurchaseHeader);
                Crear := TRUE;
                if not Per THEN BEGIN
                    PurchaseHeader.SETRANGE(PurchaseHeader."Document Type", PurchaseHeader."Document Type"::Order);
                    PurchaseHeader.SETRANGE(PurchaseHeader."Buy-from Vendor No.", AuxProv);
                    PurchaseHeader.SETRANGE("Nº Proyecto", Proyecto."No.");
                    Crear := NOT PurchaseHeader.FINDFIRST;
                    if NOT Crear THEN BEGIN
                        PurchaseHeader.Status := PurchaseHeader.Status::Open;
                        PurchaseHeader.MODIFY;
                    END;
                END;
                if Crear THEN BEGIN
                    PurchaseHeader."Document Type" := PurchaseHeader."Document Type"::Order;
                    PurchaseHeader."No." := GestNoSer.GetNextNo(ConfCompra."Order Nos.", WORKDATE, TRUE);
                    PurchaseHeader.INSERT(FALSE);
                    PurchaseHeader.VALIDATE("No. Series", ConfCompra."Order Nos.");
                    PurchaseHeader.VALIDATE("Posting No. Series", ConfCompra."Posted Invoice Nos.");
                    PurchaseHeader.VALIDATE("Receiving No. Series", ConfCompra."Posted Receipt Nos.");
                    PurchaseHeader.VALIDATE("Posting Date", Proyecto."Starting Date");
                    PurchaseHeader.VALIDATE("Document Date", PurchaseHeader."Posting Date");
                    PurchaseHeader.VALIDATE("Expected Receipt Date", WORKDATE);
                    PurchaseHeader.VALIDATE("Order Date", WORKDATE);
                    PurchaseHeader.VALIDATE("Posting Description", FORMAT(PurchaseHeader."Document Type") + ' ' + PurchaseHeader."No.");
                    PurchaseHeader.VALIDATE("Buy-from Vendor No.", AuxProv);
                    PurchaseHeader.VALIDATE("Your Reference", 'Proyecto ' + Proyecto."No.");
                    PurchaseHeader.VALIDATE("Nº Proyecto", Proyecto."No.");
                    rProveedor.GET(AuxProv);
                    PurchaseHeader.VALIDATE("Purchaser Code", rProveedor."Purchaser Code");
                    PurchaseHeader.VALIDATE("Fecha inicial proyecto", Proyecto."Starting Date");
                    PurchaseHeader.VALIDATE("Fecha fin proyecto", Proyecto."Ending Date");
                    PurchaseHeader.VALIDATE(Firmado, Proyecto.Firmado);
                    PurchaseHeader.VALIDATE("Fecha Firma", Proyecto."Fecha Firma");
                    PurchaseHeader.VALIDATE("Shortcut Dimension 1 Code", Proyecto."Global Dimension 1 Code");
                    PurchaseHeader.VALIDATE("Shortcut Dimension 2 Code", Proyecto."Global Dimension 2 Code");
                    PurchaseHeader.MODIFY(FALSE);
                    //{ *** Tambien se traspasan los comentarios *** }
                    rComentProy.SETCURRENTKEY("Table Name", "No.", "Line No.");
                    rComentProy.SETRANGE("Table Name", rComentProy."Table Name"::Job);
                    rComentProy.SETRANGE("No.", Proyecto."No.");
                    if rComentProy.FIND('-') THEN
                        REPEAT
                            rComentCompra.INIT;
                            rComentCompra."Document Type" := PurchaseHeader."Document Type";
                            rComentCompra."No." := PurchaseHeader."No.";
                            rComentCompra."Line No." := rComentProy."Line No.";
                            rComentCompra.Date := rComentProy.Date;
                            rComentCompra.Code := rComentProy.Code;
                            rComentCompra.Comment := rComentProy.Comment;
                            rComentCompra.INSERT;
                        UNTIL rComentProy.NEXT = 0;

                    /* { Ya viene del codeunit
                    JobPlanningLine.RESET;
                    JobPlanningLine.SETRANGE("Nº proyecto", Proyecto."Nº");    } */
                END;
                PurchaseLine.RESET;
                PurchaseLine.SETRANGE(PurchaseLine."Document Type", PurchaseLine."Document Type"::Order);
                PurchaseLine.SETRANGE(PurchaseLine."Document No.", PurchaseHeader."No.");
                if NOT PurchaseLine.FINDLAST THEN
                    ult := 666
                ELSE
                    ult := PurchaseLine."Line No." + 1000;

                if JobPlanningLine.FIND('-') THEN
                    REPEAT
                        CLEAR(PurchaseLine);
                        PurchaseLine.SETRANGE(PurchaseLine."Document Type", PurchaseLine."Document Type"::Order);
                        PurchaseLine.SETRANGE(PurchaseLine."Document No.", PurchaseHeader."No.");
                        PurchaseLine.SETRANGE("Linea de proyecto", JobPlanningLine."Line No.");
                        if NOT PurchaseLine.FINDFIRST THEN BEGIN
                            PurchaseLine."Document Type" := PurchaseHeader."Document Type";
                            PurchaseLine."Document No." := PurchaseHeader."No.";
                            PurchaseLine."Line No." := ult;
                            ult += 1000;
                            PurchaseLine.INSERT;
                            PurchaseLine.VALIDATE("Buy-from Vendor No.", PurchaseHeader."Buy-from Vendor No.");
                            CASE JobPlanningLine.Type OF
                                JobPlanningLine.Type::"G/L Account":
                                    PurchaseLine.VALIDATE(Type, PurchaseLine.Type::"G/L Account");
                                JobPlanningLine.Type::Item:
                                    PurchaseLine.VALIDATE(Type, PurchaseLine.Type::Item);
                                JobPlanningLine.Type::Resource:
                                    PurchaseLine.VALIDATE(Type, PurchaseLine.Type::"G/L Account");
                                JobPlanningLine.Type::Familia:
                                    PurchaseLine.VALIDATE(Type, PurchaseLine.Type::"G/L Account");
                            END;
                            if (JobPlanningLine.Type <> JobPlanningLine.Type::Familia) AND
                               (JobPlanningLine.Type <> JobPlanningLine.Type::Resource) THEN BEGIN
                                PurchaseLine.VALIDATE("No.", JobPlanningLine."No.");
                                PurchaseLine.VALIDATE(Description, JobPlanningLine.Description);
                            END ELSE BEGIN
                                if (JobPlanningLine.Type = JobPlanningLine.Type::Familia) THEN BEGIN
                                    rFamilia.GET(JobPlanningLine."No.");
                                    rGCP.GET(rFamilia."Grupo contable producto");
                                    rGCN.GET(PurchaseHeader."Gen. Bus. Posting Group");
                                    rCGC.GET(rGCN.Code, rGCP.Code);
                                    rCGC.TESTFIELD("Purch. Account");
                                    PurchaseLine.VALIDATE("No.", rCGC."Purch. Account");
                                    PurchaseLine.VALIDATE("Gen. Bus. Posting Group", rGCN.Code);
                                    PurchaseLine.VALIDATE("Gen. Prod. Posting Group", rGCP.Code);
                                    PurchaseLine.VALIDATE(Description, JobPlanningLine.Description);
                                    /* { Ya no es necesario
                                    PurchaseLine.VALIDATE("Description 2", (STRSUBSTNO('%1',JobPlanningLine."Planning Date") + ' - ' +
                                                                   STRSUBSTNO('%1',JobPlanningLine."Fecha Final")));
                                     } */
                                    // En el caso de Fam. recurso supongo que debe aplicarse a una cuenta contable, LBO
                                END ELSE BEGIN // {Es un recurso}
                                    rRecurso.GET(JobPlanningLine."No.");
                                    PurchaseLine.Type := PurchaseLine.Type::Resource;
                                    rGCP.GET(rRecurso."Gen. Prod. Posting Group");
                                    rGCN.GET(PurchaseHeader."Gen. Bus. Posting Group");
                                    rCGC.GET(rGCN.Code, rGCP.Code);
                                    rCGC.TESTFIELD("Purch. Account");
                                    PurchaseLine.VALIDATE("No.", JobPlanningLine."No.");//rCGC."Purch. Account");
                                    PurchaseLine.VALIDATE("Gen. Bus. Posting Group", rGCN.Code);
                                    PurchaseLine.VALIDATE("Gen. Prod. Posting Group", rGCP.Code);
                                    PurchaseLine.VALIDATE(Description, JobPlanningLine.Description);
                                END;
                            END;
                            PurchaseLine.VALIDATE(Quantity, JobPlanningLine.Quantity);
                            // mig a 5.0     JobPlanningLine.CALCFIELDS(Quantity);
                            PurchaseLine.VALIDATE("Job No.", JobPlanningLine."Job No.");
                            PurchaseLine.VALIDATE("Job Task No.", JobPlanningLine."Job Task No.");

                            PurchaseLine.VALIDATE("Direct Unit Cost", JobPlanningLine."Unit Cost");
                            PurchaseLine.VALIDATE("Line Discount %", JobPlanningLine."% Dto. Compra");    // $004
                                                                                                          //FCL-23/05/05.
                            PurchaseLine.VALIDATE("Shortcut Dimension 1 Code", JobPlanningLine."Shortcut Dimension 1 Code");
                            PurchaseLine.VALIDATE("Shortcut Dimension 2 Code", JobPlanningLine."Shortcut Dimension 2 Code");
                            PurchaseLine.VALIDATE("Shortcut Dimension 3 Code", JobPlanningLine."Shortcut Dimension 3 Code");
                            PurchaseLine.VALIDATE("Shortcut Dimension 4 Code", JobPlanningLine."Shortcut Dimension 4 Code");
                            PurchaseLine.VALIDATE("Shortcut Dimension 5 Code", JobPlanningLine."Shortcut Dimension 5 Code");

                            PurchaseLine.ValidateShortcutDimCode(3, JobPlanningLine."Shortcut Dimension 3 Code");
                            PurchaseLine.ValidateShortcutDimCode(4, JobPlanningLine."Shortcut Dimension 4 Code");
                            PurchaseLine.ValidateShortcutDimCode(5, JobPlanningLine."Shortcut Dimension 5 Code");

                            //PurchaseLine.VALIDATE("Job No.", JobPlanningLine."Job No.");           //FCL-23/05/05. Machacaba dep. y prog.
                            /* { $001
                            PurchaseLine.VALIDATE("Phase Code", JobPlanningLine."Phase Code");
                            PurchaseLine.VALIDATE("Task Code", JobPlanningLine."Task Code");
                            PurchaseLine.VALIDATE("Step Code", JobPlanningLine."Step Code");
                            } */


                            // $003-
                            JobPlanningLine.CALCFIELDS("No. Orden Publicidad");
                            if (JobPlanningLine."No. Orden Publicidad" <> '') THEN BEGIN
                                PurchaseLine."No. Orden Publicidad" := JobPlanningLine."No. Orden Publicidad";
                                CLEAR(rOrden);
                                if rOrden.GET(JobPlanningLine."No. Orden Publicidad") THEN BEGIN
                                    // Primera linea para nombre medio
                                    PurchaseLine.Description := rOrden."Nombre Soporte";
                                END;
                            END ELSE BEGIN
                                PurchaseLine.VALIDATE("Description 2", (STRSUBSTNO('%1', JobPlanningLine."Planning Date") + ' - ' +
                                                              STRSUBSTNO('%1', JobPlanningLine."Fecha Final")));
                            END;
                            // $003+
                            //ASC
                            PurchaseLine."Linea de proyecto" := JobPlanningLine."Line No.";
                            PurchaseLine."Fecha inicial recurso" := JobPlanningLine."Planning Date";
                            PurchaseLine."Fecha final recurso" := JobPlanningLine."Fecha Final";
                            PurchaseLine."Empresa Origen" := Proyecto."Empresa Origen";
                            PurchaseLine."Proyecto Origen" := Proyecto."Proyecto en empresa Origen";
                            PurchaseLine.Recurso := JobPlanningLine."Recurso en Empresa Origen";
                            if JobPlanningLine."Linea en Empresa Origen" <> 0 THEN
                                PurchaseLine."Linea de proyecto" := JobPlanningLine."Linea en Empresa Origen";
                            //Fin asc
                            PurchaseLine.VALIDATE("Direct Unit Cost", JobPlanningLine."Unit Cost");
                            PurchaseLine."Direct Unit Cost" := JobPlanningLine."Unit Cost";
                            PurchaseLine.MODIFY;


                            // $002- y parte del $003
                            if (JobPlanningLine."No. Orden Publicidad" <> '') THEN BEGIN
                                CLEAR(rOrden);
                                if rOrden.GET(JobPlanningLine."No. Orden Publicidad") THEN BEGIN
                                    // Linea para el nombre del recurso
                                    rRecurso.GET(rOrden.Concepto);
                                    Inserta_Linea(rRecurso.Name);

                                    // Linea para Seccion
                                    if (rOrden.Seccion <> '') THEN
                                        Inserta_Linea(STRSUBSTNO('Seccion: %1', rOrden.Seccion));

                                    // Linea para alto/ancho
                                    if ((rOrden.Alto <> 0) AND (rOrden.Ancho <> 0)) THEN
                                        Inserta_Linea(STRSUBSTNO('(Alto x Ancho): %1 x %2', rOrden.Alto, rOrden.Ancho));

                                    // Linea para recargo si hay
                                    if (rOrden.Recargo <> 0) THEN
                                        Inserta_Linea(STRSUBSTNO('Recargo: %1', rOrden.Recargo));

                                    // Linea para tarifas y dias
                                    Lineas_Dias;
                                END;
                            END;
                            rTexto.SETRANGE("Nº proyecto", JobPlanningLine."Job No.");
                            rTexto.SETRANGE("Nº linea aux", JobPlanningLine."Line No.");
                            rTexto.SETFILTER("Tipo linea", '%1|%2', rTexto."Tipo linea"::Ambos, rTexto."Tipo linea"::Compra);
                            if rTexto.FINDSET THEN
                                REPEAT
                                    if (rTexto.Texto <> '') THEN BEGIN
                                        CLEAR(PurchaseLine);
                                        PurchaseLine."Document Type" := PurchaseHeader."Document Type";
                                        PurchaseLine."Document No." := PurchaseHeader."No.";
                                        PurchaseLine."Line No." := ult;
                                        ult += 1000;
                                        PurchaseLine.INSERT;
                                        PurchaseLine.Type := PurchaseLine.Type::" ";
                                        PurchaseLine.Description := rTexto.Texto;
                                        PurchaseLine.MODIFY;
                                    END;
                                UNTIL rTexto.NEXT = 0;

                            // $002+ y $003+
                        END ELSE BEGIN
                            // if PurchaseLine."Quantity Received" <> JobPlanningLine.Quantity Then
                            //     PurchaseLine.VALIDATE(Quantity, JobPlanningLine.Quantity);
                            // PurchaseLine.MODIFY;
                        END;

                    UNTIL JobPlanningLine.NEXT = 0;
                COMMIT;
                if not Per THEN BEGIN
                    CLEAR(Archivar);
                    // Archivar.ArchivePurchDocumentPer(PurchaseHeader);
                END;
            END;

        }

    }
    requestpage
    {
        layout
        {
            area(content)
            {
                group(GroupName)
                {
                }
            }
        }
        actions
        {
            area(processing)
            {
            }
        }
    }

    VAR
        ConfCompra: Record "Purchases & Payables Setup";
        Proyecto: Record Job;
        JobPlanningLine: Record "Job Planning Line";
        PurchaseHeader: Record 38;
        PurchaseLine: Record 39;
        rGCP: Record 251;
        rGCN: Record 250;
        rCGC: Record 252;
        rFamilia: Record 152;
        rRecurso: Record 156;
        rComentCompra: Record 43;
        rComentProy: Record 97;
        rProveedor: Record Vendor;
        rTexto: Record "Texto Presupuesto";
        rOrden: Record "Cab. orden publicidad";
        PurchaseLineOrden: Record "Lin. orden publicidad";
#if CLEAN24
#pragma warning disable AL0432
        GestNoSer: Codeunit NoSeriesManagement;
#pragma warning restore AL0432
#else
        GestNoSer: Codeunit "No. Series";
#endif
        ult: Integer;
        AuxProv: Code[20];
        cProyecto: Codeunit "Gestion Proyecto";
        Per: Boolean;
        Crear: Boolean;
        Archivar: Codeunit 5063;

    PROCEDURE Coge_Registros(VAR rP: Record Job; VAR rL: Record "Job Planning Line");
    BEGIN
        Proyecto := rP;
        Proyecto.COPYFILTERS(rP);
        JobPlanningLine := rL;
        JobPlanningLine.COPYFILTERS(rL);
        AuxProv := JobPlanningLine."Compra a-Nº proveedor";
        Per := false;
    END;

    PROCEDURE Lineas_Dias();
    VAR
        wDiasAux: Code[10];
        wDescAux: Text[60];
        wMes: Text[30];
        wPrimero: Boolean;
        wPorDias: Boolean;
    BEGIN

        CLEAR(PurchaseLineOrden);
        CLEAR(wDescAux);
        CLEAR(wDiasAux);
        wPrimero := FALSE;
        wPorDias := FALSE;
        PurchaseLineOrden.RESET;
        PurchaseLineOrden.SETCURRENTKEY("Tipo orden", "No. orden", "Fecha inicio");  //Se incluyen todas las fechas
        PurchaseLineOrden.SETRANGE("No. orden", rOrden.No);
        PurchaseLineOrden.SETFILTER(Precio, '<>%1', 0);
        PurchaseLineOrden.SETFILTER(Inserciones, '>%1', 1);
        if PurchaseLineOrden.FINDFIRST THEN BEGIN
            wPorDias := TRUE;
            PurchaseLineOrden.SETRANGE(Inserciones);
        END
        ELSE BEGIN
            PurchaseLineOrden.SETRANGE(Inserciones);
            PurchaseLineOrden.SETFILTER(Observaciones, '<>%1', '');
            if PurchaseLineOrden.FINDFIRST THEN BEGIN
                wPorDias := TRUE;
            END;
            PurchaseLineOrden.SETRANGE(Observaciones);
        END;

        if PurchaseLineOrden.FINDSET THEN
            REPEAT
                if wPorDias THEN BEGIN
                    if wDescAux <> '' THEN
                        wDescAux := wDescAux + ' | ';
                    wDescAux := wDescAux + FORMAT(PurchaseLineOrden."Fecha inicio");
                    if PurchaseLineOrden.Inserciones > 1 THEN
                        wDescAux := wDescAux + '=' + FORMAT(PurchaseLineOrden.Inserciones);
                    if (STRLEN(wDescAux) >= 40) THEN BEGIN
                        Inserta_Linea(COPYSTR(wDescAux, 1, 50));
                        CLEAR(wDescAux);
                    END;
                END
                ELSE BEGIN
                    if FORMAT(DATE2DMY(PurchaseLineOrden."Fecha inicio", 3)) + FORMAT(DATE2DMY(PurchaseLineOrden."Fecha inicio", 2)) <> wDiasAux THEN BEGIN
                        if (wDiasAux <> '') THEN BEGIN
                            Inserta_Linea(COPYSTR(wDescAux, 1, 50));
                            CLEAR(wDescAux);
                        END;
                        wMes := ObtenerMes(PurchaseLineOrden."Fecha inicio" - DATE2DMY(PurchaseLineOrden."Fecha inicio", 1) + 1);
                        wDescAux := wMes + ' ' + FORMAT(DATE2DMY(PurchaseLineOrden."Fecha inicio", 3)) + ':';
                        wDiasAux := FORMAT(DATE2DMY(PurchaseLineOrden."Fecha inicio", 3)) + FORMAT(DATE2DMY(PurchaseLineOrden."Fecha inicio", 2));
                    END
                    ELSE BEGIN
                        if wDescAux <> '' THEN
                            wDescAux := wDescAux + ',';
                    END;
                    wDescAux := wDescAux + FORMAT(DATE2DMY(PurchaseLineOrden."Fecha inicio", 1));
                    if (STRLEN(wDescAux) >= 46) THEN BEGIN
                        wDescAux := wDescAux + ',';
                        Inserta_Linea(COPYSTR(wDescAux, 1, 50));
                        CLEAR(wDescAux);
                    END;
                END;
            UNTIL PurchaseLineOrden.NEXT = 0;
        Inserta_Linea(COPYSTR(wDescAux, 1, 50));
    END;

    PROCEDURE Inserta_Linea(wDescripcion: Text[100]);
    BEGIN
        CLEAR(PurchaseLine);
        PurchaseLine."Document Type" := PurchaseHeader."Document Type";
        PurchaseLine."Document No." := PurchaseHeader."No.";
        PurchaseLine."Line No." := ult;
        ult += 1000;
        PurchaseLine.INSERT;
        PurchaseLine.Type := PurchaseLine.Type::" ";
        PurchaseLine.Description := wDescripcion;
        PurchaseLine.MODIFY;

    END;

    PROCEDURE ObtenerMes(pFecha: Date): Text[30];
    VAR
        rFecha: Record 2000000007;
    BEGIN
        rFecha.RESET;
        rFecha.SETRANGE("Period Type", rFecha."Period Type"::Month);      //filtro por dia 1 del mes para obtener descr.mes
        rFecha.SETRANGE("Period Start", pFecha);
        if rFecha.FINDFIRST THEN
            EXIT(rFecha."Period Name")
        ELSE
            EXIT('');
    END;

    PROCEDURE Coge_RegistrosPer(VAR rP: Record Job; VAR rL: Record "Job Planning Line");
    BEGIN
        Proyecto := rP;
        Proyecto.COPYFILTERS(rP);
        JobPlanningLine := rL;
        JobPlanningLine.COPYFILTERS(rL);
        AuxProv := JobPlanningLine."Compra a-Nº proveedor";
        Per := TRUE;
    END;


    /*   $001 MNC 050808 migracion a 5.0
      $002 MNC 150109 Cambio sistema Texto ampliado lineas, en compras
      $003 MNC 020609 Cuando tiene orden publicidad, cambio texto descripcion
      $004 MNC 060809 A¤ado % dto compra
      $005 FCL 260310 Modifico la parte correspondiente al texto de la descripción de los días,
                      para adaptarla al nuevo formato. */

}

