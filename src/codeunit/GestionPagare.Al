/// <summary>
/// Codeunit GestionPagare (ID 50008).
/// </summary>
codeunit 50008 GestionPagare
{
    Permissions = TableData 25 = m,
    TableData 355 = id,
    TableData 7000002 = m;

    VAR
        Text000: Label 'COBROS';
        recCfgCartera: Record 7000016;
        recProveedor: Record Vendor;
        Text001: Label 'LIQ.CART.';
        Text002: Label 'PAGOS';
        Text003: Label 'LIQ.PAG';
        Text004: Label 'Diario Liquidacion pagares';
        Text005: Label 'Diario Liquidación cartera';
        Text006: Label 'Liquidacion pagare';
        Finestra: Dialog;
        Text113: Label 'Generando y registrando lineas...\';
        Text114: Label 'Un momento, por favor';
        Text115: Label 'P.fac. nº';
        Text116: Label 'PAG.EMIT.';
        Text117: Label 'Pagares proveedor ya emitidos';
        Text118: Label 'Pagaré para';
        Text120: Label 'Algun banco de los pagares marcados es diferente.';
        Text121: Label 'Introduzca 1er. Número de Pagaré #1####';
        Text122: Label 'Algun pagaré no está impreso, debe emplear imprimir.';
        Text123: Label 'Algun pagaré está impreso, debe emplear reimprimir.';
        Text124: Label 'Debe especificar %1 en %2 o %3 en %4.';
        Text125: Label 'El %1 no está entre el %2 y %3. Debe borrar el contenido de %1 para poder inicializar el numerador, o cambiar el %2 y %3 por el nuevo rango proporcionado por el banco.';
        Text126: Label 'Se ha llegado al %1 y no se han podido imprimir todos los pagarés. Debe cambiar el %2 y %1 por el nuevo rango proporcionado por el banco antes de continuar con la impresión de pagarés con este banco.';
        Text127: Label 'Quedan menos de 10 pagarés para imprimir con la actual numeración. Debe solicitar a su banco un nuevo rango de pagarés a la mayor brevedad.';
        Text202: Label 'Algún pagaré del proveedor %1 es negativo. Revise las facturas y abonos marcados y vuelva a generar los pagarés.';
        Text207: Label 'Difs. de cambio en pagaré';

    PROCEDURE CrearPagares(var par_MovProv: Record 25);
    VAR
        rTipoCambio: Record "Currency Exchange Rate";
        rMovProv: Record 25;
        rMovProv2: Record 25;
        rLinAux: Record "Lineas Auxiliares";
        rLinAuxTMP: ARRAY[2] OF Record "Lineas Auxiliares" TEMPORARY;
        rBanco: Record 270;
        rMovDim: Record 355;
        TempDimBuf: Record 360 TEMPORARY;
        rConfCont: Record "General Ledger Setup";
        fPagares: Page "Lista pagares";// "Pagarés";
        fGenerar: Page "Generar pagares";
        DimBufMgt: Codeunit 411;
        wNumLin: Integer;
        wFechaVto: Boolean;
        wDimensiones: Text[250];
    BEGIN
        // CrearPagares
        //
        // Esta función se llama desde el formulario de facturas y abonos pendientes "Lineas Auxiliares"
        //   Compras y pagos / Proveedor / Pagares / Un solo proveedor [Todos los proveedores]

        if fGenerar.RUNMODAL <> ACTION::OK THEN
            EXIT;

        rBanco.GET(fGenerar.Banco);
        wDimensiones := fGenerar.Dimensiones;
        wFechaVto := fGenerar.FechaVto;

        if wDimensiones <> '' THEN
            rConfCont.GET;

        rLinAux.RESET;
        rLinAux.DELETEALL;

        //       rMovDim.RESET;
        //       rMovDim.SETRANGE("Table ID", DATABASE::"Lineas Auxiliares");
        //       rMovDim.DELETEALL;

        // Limpiamos marcas anteriores en "Mov. proveedor"
        //
        rMovProv.RESET;
        rMovProv.SETCURRENTKEY(Usuario);
        if USERID() <> '' THEN
            rMovProv.SETRANGE(Usuario, USERID())
        ELSE
            rMovProv.SETRANGE(Usuario, '******');
        if rMovProv.FIND('-') THEN
            REPEAT
                rMovProv2.GET(rMovProv."Entry No.");
                rMovProv2.Usuario := '';
                rMovProv2.MODIFY;
            UNTIL rMovProv.NEXT = 0;

        CLEAR(fPagares);
        wNumLin := 0;

        par_MovProv.SETCURRENTKEY("Vendor No.", Open, Positive);
        if par_MovProv.FIND('-') THEN
            REPEAT
                //WITH rLinAuxTMP[1] DO BEGIN
                CLEAR(rLinAuxTMP);

                // emitir el pagaré con la divisa del banco
                //
                if (rBanco."Currency Code" <> '') THEN BEGIN
                    if rBanco."Currency Code" = par_MovProv."Currency Code" THEN BEGIN
                        par_MovProv.CALCFIELDS("Remaining Amount");
                        rLinAuxTMP[1].Importe := -par_MovProv."Remaining Amount";
                    END
                    ELSE BEGIN
                        par_MovProv.CALCFIELDS("Remaining Amt. (LCY)");
                        //BRM          Importe := -rTipoCambio.ExchangeAmtLCYToFCY(WORKDATE, rBanco."Currency Code",
                        rLinAuxTMP[1].Importe := -rTipoCambio.ExchangeAmtLCYToFCY(rLinAux."Fecha Vto.", rBanco."Currency Code",
                              //BRM                par_MovProv."Remaining Amt. (LCY)", rTipoCambio.ExchangeRate(WORKDATE, rBanco."Currency Code"));
                              par_MovProv."Remaining Amount", rTipoCambio.ExchangeRate(rLinAux."Fecha Vto.", rBanco."Currency Code"));
                    END;
                END
                ELSE BEGIN
                    par_MovProv.CALCFIELDS("Remaining Amt. (LCY)");
                    rLinAuxTMP[1].Importe := -par_MovProv."Remaining Amt. (LCY)";
                END;

                rLinAuxTMP[1].Proveedor := par_MovProv."Vendor No.";
                rLinAuxTMP[1]."Fecha Vto." := par_MovProv."Due Date";
                rLinAuxTMP[1].Banco := rBanco."No.";
                rLinAuxTMP[1]."Cod. Divisa" := rBanco."Currency Code";
                if wDimensiones <> '' THEN BEGIN

                    rLinAuxTMP[1]."Shortcut Dimension 1 Code" := par_MovProv."Global Dimension 1 Code";
                    rLinAuxTMP[1]."Shortcut Dimension 2 Code" := par_MovProv."Global Dimension 2 Code";

                    rLinAuxTMP[1]."Nº mov. dimension" := par_MovProv."Dimension Set ID";
                END;
                rLinAuxTMP[1]."Cod. auditoria" := par_MovProv."Reason Code";

                rLinAuxTMP[2].SETRANGE(Proveedor, rLinAuxTMP[1].Proveedor);
                if wFechaVto THEN
                    rLinAuxTMP[2].SETRANGE(rLinAuxTMP[2]."Fecha Vto.", rLinAuxTMP[1]."Fecha Vto.");
                rLinAuxTMP[2].SETRANGE(Banco, rLinAuxTMP[1].Banco);
                rLinAuxTMP[2].SETRANGE(rLinAuxTMP[2]."Cod. Divisa", rLinAuxTMP[1]."Cod. Divisa");
                rLinAuxTMP[2].SETRANGE(rLinAuxTMP[2]."Nº mov. dimension", rLinAuxTMP[1]."Nº mov. dimension");
                rLinAuxTMP[2].SETRANGE(rLinAuxTMP[2]."Shortcut Dimension 1 Code", rLinAuxTMP[1]."Shortcut Dimension 1 Code");
                rLinAuxTMP[2].SETRANGE(rLinAuxTMP[2]."Shortcut Dimension 2 Code", rLinAuxTMP[1]."Shortcut Dimension 2 Code");
                rLinAuxTMP[2].SETRANGE(rLinAuxTMP[2]."Cod. auditoria", rLinAuxTMP[1]."Cod. auditoria");
                if rLinAuxTMP[2].FIND('-') THEN BEGIN
                    rLinAuxTMP[2].Importe += rLinAuxTMP[1].Importe;
                    rLinAuxTMP[2].MODIFY;
                END
                ELSE BEGIN
                    wNumLin += 1;
                    rLinAuxTMP[1]."Nº Linea" := wNumLin;
                    rLinAuxTMP[1].INSERT;
                END;


                rMovProv2 := par_MovProv;
                if USERID <> '' THEN
                    rMovProv2.Usuario := USERID
                ELSE
                    rMovProv2.Usuario := '******';
                rMovProv2.MODIFY;

            UNTIL par_MovProv.NEXT = 0;

        if rLinAuxTMP[1].FIND('-') THEN BEGIN
            REPEAT
                if rLinAuxTMP[1].Importe <= 0 THEN
                    ERROR(Text202, rLinAuxTMP[1].Proveedor);

                rLinAux := rLinAuxTMP[1];
                rLinAux.INSERT;

                DimBufMgt.GetDimensions(rLinAux."Nº mov. dimension", TempDimBuf);

                rLinAux."Nº mov. dimension" := rLinAuxTMP[1]."Nº mov. dimension";
                rLinAux."Shortcut Dimension 1 Code" := rLinAuxTMP[1]."Shortcut Dimension 1 Code";
                rLinAux."Shortcut Dimension 2 Code" := rLinAuxTMP[1]."Shortcut Dimension 2 Code";
            until rLinAuxTMP[1].Next() = 0;
        END;

        COMMIT;
        fPagares.RUNMODAL;
    END;

    PROCEDURE Registrar(par_Diario: Code[10]; par_Seccion: Code[10]; VAR par_PrimerPagare: Code[20]; VAR par_UltimoPagare: Code[20]);
    VAR
        rConfCompra: Record "Purchases & Payables Setup";
        rTipoCambio: Record "Currency Exchange Rate";
        rMovProveedor: Record 25;
        rLinAux: Record "Lineas Auxiliares";
        rLinDiaGen: Record "Gen. Journal Line";
        rProveedor: Record Vendor;
        rPagFra: Record "Pagare/Confirming-Factura";
        rFormaPago: Record 289;
        rDivisa: Record "Currency";
        rBanco: Record 270;
        rMovDim: Record 355;
        rMovDim2: Record 355;
        //rJnlLineDimTMP : Record 356 TEMPORARY;
        rDimTMP: Record 348;
#if CLEAN24
#pragma warning disable AL0432
        GestNoSer: Codeunit NoSeriesManagement;
#pragma warning restore AL0432
#else
        GestNoSer: Codeunit "No. Series";
#endif
        cRegisLinDiaGen: Codeunit 12;
        wProveedorAnt: Code[20];
        wNPagare: Code[20];
        wTotalRegistradoDL: Decimal;
        wVtoAnt: Date;
        wEncontrado: Boolean;
    BEGIN
        // Registrar
        //
        // Este proceso se llama desde el formulario 7000706 "Pagarés II"
        //   Compras y pagos / Proveedor / Pagares / Un solo proveedor [Todos los proveedores]

        Finestra.OPEN(Text113 +
         Text114);

        rConfCompra.LOCKTABLE;
        rConfCompra.GET();
        rConfCompra.TESTFIELD("Nº serie pagarés");

        rLinAux.RESET;
        rLinAux.SETCURRENTKEY(Proveedor);
        CLEAR(wProveedorAnt);
        CLEAR(wVtoAnt);
        CLEAR(par_PrimerPagare);
        CLEAR(par_UltimoPagare);
        if rLinAux.FIND('-') THEN BEGIN
            REPEAT
                rLinAux.TESTFIELD(Banco);
                rLinAux.TESTFIELD("Fecha Vto.");
                // PLB 15/03/2004
                // el sistema, a pesar de haber creado una línea por proveedor y f. vto., al final
                // sólo se genera un pagaré
                //if wProveedorAnt <> rLinAux.Proveedor THEN BEGIN
                if (wProveedorAnt <> rLinAux.Proveedor) OR
      (wVtoAnt <> rLinAux."Fecha Vto.") THEN BEGIN
                    //BRM      wNPagare := GestNoSer.GetNextNo(rConfCompra."Nº serie pagarés", WORKDATE, TRUE);
                    wNPagare := GestNoSer.GetNextNo(rConfCompra."Nº serie pagarés", rLinAux."Fecha Vto.", TRUE);
                    wProveedorAnt := rLinAux.Proveedor;
                    wVtoAnt := rLinAux."Fecha Vto.";
                    if par_PrimerPagare = '' THEN
                        par_PrimerPagare := wNPagare;
                END;
                rLinAux."Nº Pagaré" := wNPagare;
                rLinAux.MODIFY;
            UNTIL rLinAux.NEXT = 0;
            par_UltimoPagare := wNPagare;
        END;

        rMovProveedor.SETCURRENTKEY(Usuario);
        if USERID <> '' THEN
            rMovProveedor.SETRANGE(Usuario, USERID)
        ELSE
            rMovProveedor.SETRANGE(Usuario, '******');

        wTotalRegistradoDL := 0;



        // Primero las lineas de pago
        //
        wProveedorAnt := '';
        wVtoAnt := 0D;
        if rMovProveedor.FIND('-') THEN
            REPEAT
                // PLB 15/03/2004
                if (wProveedorAnt <> rMovProveedor."Vendor No.") OR
                   // PLB 09/09/2005
                   //(wVtoAnt <> rMovProveedor."Due Date") THEN BEGIN
                   (wVtoAnt <> rMovProveedor."Due Date") OR
      (rDimTMP.FIND('-')) THEN BEGIN
                    wProveedorAnt := rMovProveedor."Vendor No.";
                    // PLB 15/03/2004
                    wVtoAnt := rMovProveedor."Due Date";
                    rLinAux.SETRANGE(Proveedor, wProveedorAnt);
                    rLinAux.SETRANGE(rLinAux."Fecha Vto.", wVtoAnt);
                    // PLB 15/03/2004
                    if NOT rLinAux.FIND('-') THEN BEGIN
                        rLinAux.SETRANGE("Fecha Vto.");
                        rLinAux.FIND('-');
                    END;

                    rLinAux."Shortcut Dimension 1 Code" := rMovProveedor."Global Dimension 1 Code";
                    rLinAux."Shortcut Dimension 2 Code" := rMovProveedor."Global Dimension 2 Code";
                    rLinAux."Nº mov. dimension" := rMovProveedor."Dimension Set ID";
                    // Capturamos el banco de pago
                    //
                    rBanco.GET(rLinAux.Banco);
                END;
                rLinDiaGen.INIT;
                rLinDiaGen.VALIDATE("Journal Template Name", par_Diario);
                rLinDiaGen.VALIDATE("Journal Batch Name", par_Seccion);
                rLinDiaGen.VALIDATE("Posting Date", WORKDATE);
                rLinDiaGen.VALIDATE("Transaction No.", 1);

                rLinDiaGen.VALIDATE("Document Type", rLinDiaGen."Document Type"::Payment);
                rLinDiaGen.VALIDATE("Document No.", rLinAux."Nº Pagaré");

                rLinDiaGen.VALIDATE("Account Type", rLinDiaGen."Account Type"::Vendor);
                rLinDiaGen.VALIDATE("Account No.", rMovProveedor."Vendor No.");

                // se va a emitir el pagaré con la divisa del banco
                //
                rLinDiaGen.VALIDATE("Currency Code", rBanco."Currency Code");

                if rBanco."Currency Code" <> '' THEN BEGIN
                    if rBanco."Currency Code" = rMovProveedor."Currency Code" THEN BEGIN
                        rMovProveedor.CALCFIELDS("Remaining Amount");
                        rLinDiaGen.VALIDATE(Amount, -rMovProveedor."Remaining Amount");
                    END
                    ELSE BEGIN
                        rMovProveedor.CALCFIELDS("Remaining Amt. (LCY)");
                        //BRM        rLinDiaGen.VALIDATE(Amount, rTipoCambio.ExchangeAmtLCYToFCY(WORKDATE, rBanco."Currency Code",
                        rLinDiaGen.VALIDATE(Amount, rTipoCambio.ExchangeAmtLCYToFCY(rLinAux."Fecha Vto.", rBanco."Currency Code",
                          //BRM          -rMovProveedor."Remaining Amt. (LCY)", rTipoCambio.ExchangeRate(WORKDATE, rBanco."Currency Code")));
                          -rMovProveedor."Remaining Amt. (LCY)", rTipoCambio.ExchangeRate(rLinAux."Fecha Vto.", rBanco."Currency Code")));
                    END;
                END
                ELSE BEGIN
                    rMovProveedor.CALCFIELDS("Remaining Amt. (LCY)");
                    rLinDiaGen.VALIDATE(Amount, -rMovProveedor."Remaining Amt. (LCY)");
                END;

                rLinDiaGen.VALIDATE("Applies-to Doc. Type", rMovProveedor."Document Type");


                rLinDiaGen."Applies-to Doc. No." := rMovProveedor."Document No.";

                rLinDiaGen.VALIDATE("Shortcut Dimension 1 Code", rMovProveedor."Global Dimension 1 Code");
                rLinDiaGen.VALIDATE("Shortcut Dimension 2 Code", rMovProveedor."Global Dimension 2 Code");
                if rProveedor.GET(rMovProveedor."Vendor No.") THEN BEGIN

                    rLinDiaGen.Description := COPYSTR(Text115 + rMovProveedor."External Document No." + ' ' +
      rProveedor.Name, 1, MAXSTRLEN(rLinDiaGen.Description));

                END;

                rMovProveedor.CALCFIELDS(Amount);

                rPagFra.INIT;
                rPagFra."Pagaré/Confirming" := rLinAux."Nº Pagaré";
                rPagFra."Tipo documento" := rMovProveedor."Document Type";
                rPagFra.Numero := rMovProveedor."Document No.";

                // PLB 08/08/2005
                rPagFra."Nº Efecto" := STRSUBSTNO('%1', rLinAux."Nº Linea");

                rPagFra."Importe original" := -rMovProveedor.Amount;
                // PLB 29/06/2007
                //rPagFra."Importe a pagar" := rLinDiaGen."Debit Amount";
                rPagFra."Importe a pagar" := rLinDiaGen.Amount;
                rPagFra."Fecha vencimiento" := rLinAux."Fecha Vto.";
                rPagFra.INSERT;

                MarcaResto(rMovProveedor."Entry No.", rLinAux."Nº Pagaré");

                // acumulamos los pagos
                //
                wTotalRegistradoDL += rLinDiaGen."Amount (LCY)";
                cRegisLinDiaGen.RUN(rLinDiaGen);

            UNTIL rMovProveedor.NEXT = 0;

        // Luego las lineas de efectos
        //
        rLinAux.RESET;
        if rLinAux.FIND('-') THEN
            REPEAT
                rLinDiaGen.INIT;
                rLinDiaGen.VALIDATE("Journal Template Name", par_Diario);
                rLinDiaGen.VALIDATE("Journal Batch Name", par_Seccion);
                rLinDiaGen.VALIDATE("Posting Date", WORKDATE);
                rLinDiaGen.VALIDATE("Transaction No.", 1);
                rLinDiaGen.VALIDATE("Document Type", rLinDiaGen."Document Type"::Bill);
                rLinDiaGen.VALIDATE("Bill No.", STRSUBSTNO('%1', rLinAux."Nº Linea"));
                rLinDiaGen.VALIDATE("Document No.", rLinAux."Nº Pagaré");
                rLinDiaGen.VALIDATE("Account Type", rLinDiaGen."Account Type"::Vendor);
                rLinDiaGen.VALIDATE("Account No.", rLinAux.Proveedor);

                // se va a emitir el pagaré con la divisa del banco
                //
                rLinDiaGen.VALIDATE("Currency Code", rBanco."Currency Code");
                rLinDiaGen.VALIDATE("Credit Amount", rLinAux.Importe);
                rLinDiaGen.VALIDATE(Banco, rLinAux.Banco);
                rLinDiaGen.VALIDATE("Due Date", rLinAux."Fecha Vto.");

                // PLB 4/03/2003
                // a¤adidos datos para el registro del efecto
                //
                rLinDiaGen.VALIDATE("Shortcut Dimension 1 Code", rLinAux."Shortcut Dimension 1 Code");
                rLinDiaGen.VALIDATE("Shortcut Dimension 2 Code", rLinAux."Shortcut Dimension 2 Code");
                //    rLinDiaGen.VALIDATE("Cód. tesoreria", rLinAux."Cod. tesoreria");
                rLinDiaGen.VALIDATE("Reason Code", rLinAux."Cod. auditoria");

                // A¤adido para la 1.30, necesita que la forma de pago de la linea del efecto
                // tenga crear efectos a True
                //
                if NOT rFormaPago.GET(Text116) THEN BEGIN
                    CLEAR(rFormaPago);
                    rFormaPago.Code := Text116;
                    rFormaPago.Description := Text117;
                    rFormaPago."Create Bills" := TRUE;
                    rFormaPago.INSERT;
                END;

                if rProveedor.GET(rLinAux.Proveedor) THEN
                    rLinDiaGen.Description := COPYSTR(Text118 + rProveedor.Name, 1,
                    MAXSTRLEN(rLinDiaGen.Description));
                rLinDiaGen."Payment Method Code" := rFormaPago.Code;

                // acumulamos los pagos
                //
                wTotalRegistradoDL += rLinDiaGen."Amount (LCY)";


                cRegisLinDiaGen.RunWithCheck(rLinDiaGen);//, rJnlLineDimTMP);
            UNTIL rLinAux.NEXT = 0;

        // Corregimos las diferencias obtenidas debido al redondeo
        //
        if wTotalRegistradoDL <> 0 THEN BEGIN
            rDivisa.GET(rBanco."Currency Code");

            rLinDiaGen.INIT;
            rLinDiaGen.VALIDATE("Journal Template Name", par_Diario);
            rLinDiaGen.VALIDATE("Journal Batch Name", par_Seccion);
            rLinDiaGen.VALIDATE("Posting Date", WORKDATE);
            rLinDiaGen.VALIDATE("Transaction No.", 1);
            rLinDiaGen.VALIDATE("Document No.", rLinAux."Nº Pagaré");
            rLinDiaGen.VALIDATE("Account Type", rLinDiaGen."Account Type"::"G/L Account");
            if wTotalRegistradoDL > 0 THEN BEGIN
                rDivisa.TESTFIELD("Realized Gains Acc.");
                rLinDiaGen.VALIDATE("Account No.", rDivisa."Realized Gains Acc.");
            END
            ELSE BEGIN
                rDivisa.TESTFIELD("Realized Gains Acc.");
                rLinDiaGen.VALIDATE("Account No.", rDivisa."Realized Gains Acc.");
            END;
            rLinDiaGen.VALIDATE("Currency Code", '');
            rLinDiaGen.VALIDATE(Amount, -wTotalRegistradoDL);
            rLinDiaGen.VALIDATE("Shortcut Dimension 1 Code", rLinAux."Shortcut Dimension 1 Code");
            rLinDiaGen.VALIDATE("Shortcut Dimension 2 Code", rLinAux."Shortcut Dimension 2 Code");
            rLinDiaGen.Description := Text207 + rLinAux."Nº Pagaré";

            cRegisLinDiaGen.RUN(rLinDiaGen);
        END;

        rMovProveedor.MODIFYALL(Usuario, '');
        rLinAux.DELETEALL;

        //       rMovDim.RESET;
        //       rMovDim.SETRANGE("Table ID", DATABASE::"Lineas Auxiliares");
        //       rMovDim.DELETEALL;

        Finestra.CLOSE;
    END;

    PROCEDURE LiquidarPagare(Var par_DocCartera: Record 7000002);
    VAR
        rLinDiaGen: Record 81 TEMPORARY;
        rSeccion: Record "Gen. Journal Batch";
        rConfCart: Record 7000016;
        ConfCont: Record "General Ledger Setup";
        GenJlnPostLine: Codeunit 12;
        wDiario: Code[10];
        wSeccion: Code[10];
    BEGIN
        // LiquidarPagare
        //
        // Este proceso se llama desde el formulario "Documentos cartera" 7000003
        //   Cartera / Docs. a pagar / Pagaré / Liquidar

        //  WITH par_DocCartera DO BEGIN
        par_DocCartera.TESTFIELD(Banco);

        ConfCont.GET;


        CASE par_DocCartera.Type OF
            par_DocCartera.Type::Receivable:
                BEGIN
                    wDiario := Text000;
                    wSeccion := Text001;
                END;
            par_DocCartera.Type::Payable:
                BEGIN
                    wDiario := Text002;
                    wSeccion := Text003;
                END;
        END;
        //     END;

        //WITH rLinDiaGen. DO BEGIN
        rSeccion.SETRANGE("Journal Template Name", wDiario);
        rSeccion.SETRANGE(Name, wSeccion);
        if NOT rSeccion.FIND('-') THEN BEGIN
            rSeccion."Journal Template Name" := wDiario;
            rSeccion.Name := wSeccion;
            rSeccion.Description := Text005;
            rSeccion.INSERT;
        END;

        CLEAR(rLinDiaGen);
        rLinDiaGen."Journal Template Name" := wDiario;
        rLinDiaGen."Journal Batch Name" := wSeccion;


        if par_DocCartera.Type = par_DocCartera.Type::Receivable THEN
            rLinDiaGen.VALIDATE("Account Type", rLinDiaGen."Account Type"::Customer)
        ELSE
            rLinDiaGen.VALIDATE("Account Type", rLinDiaGen."Account Type"::Vendor);
        rLinDiaGen.VALIDATE("Account No.", par_DocCartera."Account No.");
        rLinDiaGen.VALIDATE("Document No.", par_DocCartera."Document No.");
        rLinDiaGen.VALIDATE("Bill No.", '');
        rLinDiaGen.VALIDATE(Description, Text006 + STRSUBSTNO('%1', rLinDiaGen."Document No."));
        rLinDiaGen.VALIDATE("Currency Code", par_DocCartera."Currency Code");

        if par_DocCartera.Type = par_DocCartera.Type::Receivable THEN
            rLinDiaGen.VALIDATE("Credit Amount", par_DocCartera."Remaining Amount")
        ELSE
            rLinDiaGen.VALIDATE("Debit Amount", par_DocCartera."Remaining Amount");
        rLinDiaGen.VALIDATE("Transaction No.", 1);
        rLinDiaGen.VALIDATE("Bal. Account Type", rLinDiaGen."Bal. Account Type"::"Bank Account");
        rLinDiaGen.VALIDATE("Bal. Account No.", par_DocCartera.Banco);
        rLinDiaGen.VALIDATE("Applies-to Doc. Type", rLinDiaGen."Applies-to Doc. Type"::Bill);
        // PLB 26/02/2004
        //VALIDATE("Applies-to Doc. No.", par_DocCartera."Document No.")
        rLinDiaGen."Applies-to Doc. No." := par_DocCartera."Document No.";
        rLinDiaGen.VALIDATE("Applies-to Bill No.", par_DocCartera."No.");
        rLinDiaGen.VALIDATE(Banco, par_DocCartera.Banco);
        rLinDiaGen.VALIDATE("Due Date", par_DocCartera."Due Date");
        //"Cód. tesoreria" := par_DocCartera."Cod. tesoreria";

        rLinDiaGen."Shortcut Dimension 1 Code" := par_DocCartera."Global Dimension 1 Code";
        rLinDiaGen."Shortcut Dimension 2 Code" := par_DocCartera."Global Dimension 2 Code";


        GenJlnPostLine.RunWithCheck(rLinDiaGen);
    END;

    PROCEDURE MarcaResto(par_NMov: Integer; par_Npagare: Code[20]);
    VAR
        rMovProveedor: Record 25;
        rPagFra: Record "Pagare/Confirming-Factura";
    BEGIN
        // MarcaResto
        //

        rMovProveedor.RESET;
        rMovProveedor.INIT;
        rMovProveedor.SETCURRENTKEY(rMovProveedor."Closed by Entry No.");
        rMovProveedor.SETRANGE("Closed by Entry No.", par_Nmov);
        if rMovProveedor.FIND('-') THEN
            REPEAT
                rPagFra.INIT;
                rPagFra."Pagaré/Confirming" := par_Npagare;


                rPagFra."Tipo documento" := rMovProveedor."Document Type";

                rMovProveedor.CALCFIELDS(Amount);

                rPagFra.Numero := rMovProveedor."Document No.";
                rPagFra."Importe original" := -rMovProveedor.Amount;
                rPagFra.INSERT;
            UNTIL rMovProveedor.NEXT = 0;
    END;

    PROCEDURE ImprimirerPagare(par_PrimerPagare: Code[20]; par_UltimoPagare: Code[20]);
    VAR
        rDocCartera: Record 7000002;
        rDocCartera2: Record 7000002;
        rBanco: Record 270;
        wBancoAnt: Code[20];
        wPrimerPagare: Integer;
    BEGIN
        // Imprimir
        //
        // Este proceso se llama desde el formulario 7000706 "Pagarés II"
        //   Compras y pagos / Proveedor / Pagares / Un solo proveedor [Todos los proveedores]

        //WITH rDocCartera. DO BEGIN
        rDocCartera.RESET;
        rDocCartera.SETRANGE(rDocCartera."¨Esta Impreso?", rDocCartera."¨Esta Impreso?"::No);
        rDocCartera.SETRANGE(Type, rDocCartera.Type::Payable);
        rDocCartera.SETRANGE("Document No.", par_PrimerPagare, par_UltimoPagare);
        if rDocCartera.FIND('-') THEN
            ImprimirDocCartera(rDocCartera, FALSE);
    END;

    PROCEDURE ImprimirDocCartera(Var par_DocCartera: Record 7000002; par_reimprimir: Boolean);
    VAR
        rDocCartera: Record 7000002;
        rBanco: Record 270;
        rMovProveedor: Record 25;
        rMovBanco: Record 271;
        rMovContabilidad: Record "G/L Entry";
        wBancoAnt: Code[20];
        wPrimerPagare: Code[20];
        wNumeracionAcabada: Boolean;
        finestra: page "Primer pagare";
        i: Integer;
    BEGIN
        // ImprimirDocCartera
        //
        // Este proceso se llama desde el formulario 7000003 "Documentos cartera" y desde esta misma codeunit
        //   Cartera / Docs a pagar / Pagaré / Imprimir [Reimprimir]

        wBancoAnt := par_DocCartera.Banco;
        REPEAT
            par_DocCartera.TESTFIELD(Type, par_DocCartera.Type::Payable);

            if wBancoAnt <> par_DocCartera.Banco THEN
                ERROR(Text120);

            if par_reimprimir THEN BEGIN
                if par_DocCartera."¨Esta Impreso?" = par_DocCartera."¨Esta Impreso?"::No THEN
                    ERROR(Text122);
            END
            ELSE
                if par_DocCartera."¨Esta Impreso?" = par_DocCartera."¨Esta Impreso?"::Si THEN
                    ERROR(Text123);
        UNTIL par_DocCartera.NEXT = 0;

        rDocCartera.RESET;
        par_DocCartera.FIND('-');
        REPEAT
            rDocCartera := par_DocCartera;
            rDocCartera.MARK(TRUE);
        UNTIL par_DocCartera.NEXT = 0;

        rDocCartera.MARKEDONLY(TRUE);
        rBanco.GET(par_DocCartera.Banco);
        rBanco.TESTFIELD(rBanco."Informe Pagare");

        // PLB 30/08/2005
        // Si se ha especificado "Ult nº pagare" en la ficha del banco no se pide que el usuario
        // introduzca otro, se coge el que tiene el banco y se incrementa en 1
        //
        if (rBanco."Ult. nº pagare" = '') AND
        (rBanco."Nº Final pagare" = '') THEN BEGIN
            //Finestra.OPEN(Text121);

            if finestra.RunModal() in [Action::Cancel, Action::LookupCancel, Action::No, Action::None] Then error('Proceso Cancelado');
            ;
            wPrimerPagare := finestra.GetPrimero();
            //Finestra.INPUT(1,wPrimerPagare);
            Finestra.CLOSE;
        END
        ELSE
            if rBanco."Nº Final pagare" = '' THEN BEGIN
                wPrimerPagare := rBanco."Ult. nº pagare";
                wPrimerPagare := INCSTR(wPrimerPagare);
            END
            ELSE
                if NOT par_reimprimir AND (rBanco."Ult. nº pagare" >= rBanco."Nº Final pagare") OR
            (rBanco."Nº Final pagare" < rBanco."Nº Inicial pagare") THEN
                    ERROR(Text125, rBanco.FIELDCAPTION("Ult. nº pagare"), rBanco.FIELDCAPTION("Nº Inicial pagare"),
                    rBanco.FIELDCAPTION("Nº Final pagare"));

        // PLB 28/10/2005
        // Problemas en la impresion de pagares en caso de control de numeracion (detectado y corregido en GLOBALES)
        //
        //REPORT.RUN(rBanco."Informe Pagare",TRUE,FALSE,rDocCartera);
        //INC-14583 Inicio
        COMMIT;
        //INC-14583 FIN
        REPORT.RUNMODAL(rBanco."Informe Pagare", TRUE, FALSE, rDocCartera);

        if rDocCartera.FIND('-') THEN
            REPEAT
                // PLB 30/08/2005
                // en caso de control de numeracion, se supone que es el propio report quien imprime
                // el número de pagare, con lo que la actualizacion del nº impreso dependera
                // del
                if rBanco."Nº Final pagare" = '' THEN BEGIN
                    rDocCartera."Nº Impreso" := wPrimerPagare;
                    rDocCartera."¨Esta Impreso?" := rDocCartera."¨Esta Impreso?"::Si;
                    rDocCartera.MODIFY;

                    if rBanco."Ult. nº pagare" <> '' THEN
                        rBanco."Ult. nº pagare" := wPrimerPagare;

                    wPrimerPagare := INCSTR(wPrimerPagare);
                END
                ELSE
                    wNumeracionAcabada := rDocCartera."Nº Impreso" = '';

                rDocCartera.MARK(FALSE);
            UNTIL rDocCartera.NEXT = 0;

        if (rBanco."Nº Final pagare" = '') AND
        (rBanco."Ult. nº pagare" <> '') THEN
            rBanco.MODIFY
        ELSE
            if wNumeracionAcabada THEN BEGIN
                rBanco.GET(wBancoAnt);
                if rBanco."Ult. nº pagare" = rBanco."Nº Final pagare" THEN
                    MESSAGE(Text126, rBanco.FIELDCAPTION("Nº Final pagare"), rBanco.FIELDCAPTION("Nº Inicial pagare"))
            END
            ELSE
                if NOT par_reimprimir AND NOT ((rBanco."Ult. nº pagare" = '') AND
            (rBanco."Nº Final pagare" = '')) THEN BEGIN
                    wPrimerPagare := rBanco."Ult. nº pagare";
                    i := 0;
                    WHILE (i < 10) AND (wPrimerPagare <> rBanco."Nº Final pagare") DO BEGIN
                        i += 1;
                        wPrimerPagare := INCSTR(wPrimerPagare);
                    END;

                    if wPrimerPagare = rBanco."Nº Final pagare" THEN
                        MESSAGE(Text127);
                END;
    END;

    PROCEDURE RegistrarPagares(recPrmPagare: Record "Cab. borrador pagare");

    VAR
        recDiario: Record "Gen. Journal Line";
        recLinPagare: Record "Lin. borrador pagare";
        TextoDescripcion: Text[50];
        Contabilizar: Boolean;
        intLinea: Integer;
        Text001: Label 'Esta pagaré ya está contabilizado.';
        Text002: Label '¿Desea registrar el pagaré?';
        Text004: Label 'Debe marcar el pagaré como firmado para poder contabilizarlo.';
        Text005: Label 'No existe factura de compra nº %1 del proveedor %2.';
        Text006: Label 'No coinciden las divisas. La divisa utilizada en el documento %1 nº %2 es %3.';
        Text007: Label 'El pagaré ha sido contabilizado y guardado en el histórico.';
        Text008: Label 'El pagaré se ha enviado al diario %1 sección %2 y guardado en el histórico.';
        GenJnlPostBatch: Codeunit 13;
        Text009: Label 'Hay lineas en el diario %1 seccion %2. No es posible registrar el pagare.';
    BEGIN

        recCfgCartera.GET;
        recCfgCartera.TESTFIELD("Diario reg. pagares");
        recCfgCartera.TESTFIELD("Seccion reg. pagares");
        recCfgCartera.TESTFIELD("Forma Pago Pagare");

        recPrmPagare.TESTFIELD("Cód. pagaré");
        recPrmPagare.TESTFIELD("Cód. proveedor");
        recPrmPagare.TESTFIELD("Fecha registro");
        recPrmPagare.TESTFIELD("Fecha de vto.");
        recPrmPagare.TESTFIELD("Cód. banco");
        recPrmPagare.TESTFIELD("Nº documento propio");
        recPrmPagare.CALCFIELDS(Importe);

        if recPrmPagare.Contabilizado THEN
            ERROR(Text001);

        if NOT CONFIRM(Text002) THEN
            EXIT;

        recProveedor.GET(recPrmPagare."Cód. proveedor");
        TextoDescripcion := recProveedor.Name;

        recDiario.RESET;
        recDiario.SETRANGE("Journal Template Name", recCfgCartera."Diario reg. pagares");
        recDiario.SETRANGE("Journal Batch Name", recCfgCartera."Seccion reg. pagares");
        if recDiario.FINDLAST THEN
            intLinea := recDiario."Line No.";

        // Crear los apuntes de detalle de facturas
        recLinPagare.RESET;
        recLinPagare.SETRANGE("Cód. pagaré", recPrmPagare."Cód. pagaré");
        if recLinPagare.FINDSET THEN
            REPEAT

                if recLinPagare."Cod. divisa" <> recPrmPagare."Cód. divisa" THEN
                    ERROR(Text006, recLinPagare."No. documento", recLinPagare."Tipo documento", recLinPagare."Cod. divisa");

                recDiario.INIT;
                recDiario."Journal Template Name" := recCfgCartera."Diario reg. pagares";
                recDiario."Journal Batch Name" := recCfgCartera."Seccion reg. pagares";
                intLinea += 10000;
                recDiario."Line No." := intLinea;

                recDiario.VALIDATE("Account Type", recDiario."Account Type"::Vendor);
                recDiario.VALIDATE("Account No.", recPrmPagare."Cód. proveedor");
                recDiario.VALIDATE("Posting Date", recPrmPagare."Fecha registro");
                recDiario.VALIDATE("Currency Code", recPrmPagare."Cód. divisa");

                CASE recLinPagare."Tipo documento" OF
                    recLinPagare."Tipo documento"::Invoice:
                        recDiario."Applies-to Doc. Type" := recDiario."Applies-to Doc. Type"::Invoice;
                    recLinPagare."Tipo documento"::"Credit Memo":
                        recDiario."Applies-to Doc. Type" := recDiario."Applies-to Doc. Type"::"Credit Memo";
                END;
                recDiario.VALIDATE("Applies-to Doc. No.", recLinPagare."No. documento");

                if recLinPagare.Importe >= 0 THEN
                    recDiario.VALIDATE(recDiario."Debit Amount", recLinPagare.Importe)
                ELSE
                    recDiario.VALIDATE(recDiario."Credit Amount", -recLinPagare.Importe);

                recDiario.VALIDATE("Document Type", recDiario."Document Type"::Payment);
                recDiario."Document No." := recPrmPagare."Cód. pagaré";
                recDiario."External Document No." := recPrmPagare."Nº documento propio";
                recDiario.Description := TextoDescripcion;

                if recCfgCartera."Registro aut. pagarés" THEN BEGIN
                    // MNC002
                    //cduRegLinDiario.RUN(recDiario)
                    recDiario.INSERT(TRUE);
                    recDiario.MARK(TRUE);
                END
                ELSE
                    recDiario.INSERT(TRUE);

            UNTIL recLinPagare.NEXT = 0;

        // Crear el apunte de cabecera del efecto

        CLEAR(recDiario);
        recDiario.VALIDATE("Account Type", recDiario."Account Type"::Vendor);
        recDiario.VALIDATE("Account No.", recPrmPagare."Cód. proveedor");
        recDiario.VALIDATE("Posting Date", recPrmPagare."Fecha registro");
        recDiario.VALIDATE("Currency Code", recPrmPagare."Cód. divisa");
        if recPrmPagare.Importe >= 0 THEN
            recDiario.VALIDATE("Credit Amount", recPrmPagare.Importe)
        ELSE
            recDiario.VALIDATE("Debit Amount", (recPrmPagare.Importe * (-1)));

        recDiario."Journal Template Name" := recCfgCartera."Diario reg. pagares";
        recDiario."Journal Batch Name" := recCfgCartera."Seccion reg. pagares";
        intLinea += 10000;
        recDiario."Line No." := intLinea;
        recDiario.VALIDATE("Document Type", recDiario."Document Type"::Bill);
        recDiario."Document No." := recPrmPagare."Cód. pagaré";
        recDiario."External Document No." := recPrmPagare."Nº documento propio";
        recDiario."Cod banco" := recPrmPagare."Cód. banco";
        recDiario."Bill No." := '1';
        recDiario."Payment Method Code" := recCfgCartera."Forma Pago Pagare";
        recDiario."Due Date" := recPrmPagare."Fecha de vto.";
        recDiario.Description := TextoDescripcion;

        if recCfgCartera."Registro aut. pagarés" THEN BEGIN
            // MNC002
            //cduRegLinDiario.RUN(recDiario)
            recDiario.INSERT(TRUE);
            recDiario.MARK(TRUE);
        END
        ELSE
            recDiario.INSERT(TRUE);

        // MNC002
        if recCfgCartera."Registro aut. pagarés" THEN BEGIN
            recDiario.SETRANGE("Journal Template Name", recCfgCartera."Diario reg. pagares");
            recDiario.SETRANGE("Journal Batch Name", recCfgCartera."Seccion reg. pagares");
            recDiario.MARKEDONLY;
            if recDiario.FIND('-') THEN BEGIN
                GenJnlPostBatch.RUN(recDiario);
                CLEAR(GenJnlPostBatch);
            END;
        END;
        // Fi MNC002

        recPrmPagare.Contabilizado := TRUE;
        recPrmPagare.MODIFY;

        if recCfgCartera."Registro aut. pagarés" THEN
            MESSAGE(Text007)
        ELSE
            MESSAGE(Text008, recCfgCartera."Diario reg. pagares", recCfgCartera."Seccion reg. pagares");
    END;

}