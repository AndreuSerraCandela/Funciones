/// <summary>
/// Report Suggest Worksheet Lines New (ID 50099).
/// </summary>
report 50033 "Suggest Worksheet Lines New"
{
    Caption = 'Proponer líneas cash flow nuevo';
    Permissions = TableData "Dimension Set ID Filter Line" = rimd,
                  TableData "Cash Flow Forecast Entry" = rimd;
    ProcessingOnly = true;

    dataset
    {
        dataitem("Cash Flow Forecast"; "Cash Flow Forecast")
        {
            DataItemTableView = SORTING("No.") ORDER(Ascending);
            dataitem("Cash Flow Account"; "Cash Flow Account")
            {
                DataItemTableView = SORTING("No.") ORDER(Ascending) WHERE("G/L Integration" = FILTER(Balance | Both), "G/L Account Filter" = FILTER(<> ''));

                trigger OnAfterGetRecord()
                var
                    GLAcc: Record "G/L Account";
                    TempGLAccount: Record "G/L Account" temporary;
                    vtoanterior: Date;
                    DesdeFecha2: Date;
                    DesdeFecha: Date;
                    DiaPago: DateFormula;
                    r17: Record "G/L Entry";
                    HastaFecha: Date;
                    vtoDummyDate: Date;
                    Dia: Integer;
                    Bank: Record "Bank Account";
                    Cf: Record "Cash Flow Account";
                    Text1140013: Label 'Saldo %1=%2';
                    salta: Boolean;
                begin

                    LiqAccT.GET("Cash Flow Account"."No.");
                    if True Then begin
                        //LiqAcc."G/L Integration" IN [LiqAcc."G/L Integration"::Balance, LiqAcc."G/L Integration"::Both] THEN BEGIN

                        GLAcc.SetFilter("No.", "G/L Account Filter");
                        GetSubPostingGLAccounts(GLAcc, TempGLAccount);

                        if TempGLAccount.FindSet() then
                            repeat
                                salta := false;
                                TempGLAccount.SETRANGE("Date Filter", 0D, 29991231D);
                                if "Calcular vto. Cuenta" = 'M' THEN
                                    TempGLAccount.SETRANGE("Date Filter", CALCDATE('PM+1D-2M', DummyDate), CALCDATE('PM+1D-2M+PM', DummyDate));
                                // Calcula del del 1 del mes anterior a DummyDate Hasta Final del Mes anterior a Post date
                                if "Calcular vto. Cuenta" = 'T' THEN
                                    TempGLAccount.SETRANGE("Date Filter", CALCDATE('PT+1D-2T', DummyDate), CALCDATE('PT+1D-2T+PT', DummyDate));
                                // Calcula del del 1 del trimeste anterior a DummyDate Hasta Final del Trimestre anterior a Post date
                                TempGLAccount.CALCFIELDS("Net Change", Balance);
                                //TempGLAccount.CalcFields(Balance);
                                r17.Reset();
                                r17.SETCURRENTKEY("G/L Account No.", "Posting Date");
                                r17.SETFILTER(r17."G/L Account No.", '%1', TempGLAccount."No." + '*');
                                Window.Update(2, Text004);
                                Window.Update(3, TempGLAccount."No.");

                                WITH CFWorksheetLine2 DO BEGIN
                                    INIT;
                                    Dia := 0;
                                    vtoDummyDate := DummyDate;
                                    HastaFecha := DummyDate;
                                    if "Calcular vto. Cuenta" <> '' THEN BEGIN
                                        if "Calcular vto. Cuenta" = 'T' THEN BEGIN
                                            HastaFecha := CALCDATE('PT+1D-2T+PT', DummyDate);
                                            // Final Trimestre anterior
                                            DesdeFecha := CALCDATE('-1T+PM+1D', HastaFecha);
                                            // Principo trimestre anterior
                                            if DATE2DMY(HastaFecha, 2) = 12 THEN
                                                vtoDummyDate := CALCDATE("Vto enero", CALCDATE('1D', HastaFecha))
                                            // En diciembre el vencimiento es 1 dia más que el calculado como vto enero
                                            ELSE
                                                vtoDummyDate := CALCDATE("Vto Resto Año", CALCDATE('1D', HastaFecha));
                                            // El resto del año el vencimiento es 1 dia más que el calculado como vto resto año
                                        END;
                                        if "Calcular vto. Cuenta" = 'M' THEN BEGIN
                                            HastaFecha := CALCDATE('PM+1D-2M+PM', DummyDate);
                                            //Final mes anterior
                                            DesdeFecha := CALCDATE('-1M+PM+1D', HastaFecha);
                                            //Principio mes anterior
                                            //        DesdeFecha:=CALCDATE('-1M+PM',HastaFecha);
                                            if DATE2DMY(HastaFecha, 2) = 12 THEN
                                                vtoDummyDate := CALCDATE("Vto enero", CALCDATE('1D', HastaFecha))
                                            // En diciembre el vencimiento es 1 dia más que el calculado como vto enero
                                            ELSE
                                                vtoDummyDate := CALCDATE("Vto Resto Año", CALCDATE('1D', HastaFecha));
                                            // El resto del año el vencimiento es 1 dia más que el calculado como vto resto año
                                        END;
                                    END;
                                    vtoanterior := vtoDummyDate;

                                    if DummyDate > vtoDummyDate THEN BEGIN
                                        r17.SETRANGE("Posting Date", CALCDATE("Vto enero", DummyDate), 99991231D);
                                        if "Calcular vto. Cuenta" = 'T' THEN
                                            r17.SETRANGE("Posting Date", CALCDATE('PT+1D-1T', DummyDate), 99991231D);
                                        if "Calcular vto. Cuenta" = 'M' THEN
                                            r17.SETRANGE("Posting Date", CALCDATE('PM+1D-1M', DummyDate), 99991231D);
                                        r17.SETRANGE("Pago Impuestos", TRUE);
                                        if NOT r17.FINDLAST THEN BEGIN
                                            vtoDummyDate := DummyDate;
                                        END;
                                    END;

                                    if DummyDate > vtoDummyDate THEN BEGIN
                                        r17.SETRANGE("Posting Date", CALCDATE("Vto enero", DummyDate), 99991231D);
                                        r17.SETRANGE("Pago Impuestos", TRUE);
                                        if r17.FINDLAST THEN salta := true;// CurrReport.SKIP;
                                        // Si la fecha de calculo es mayor que la fecha de vencimientio se va al trimestre o mes en curso
                                        if "Calcular vto. Cuenta" <> '' THEN BEGIN
                                            if "Calcular vto. Cuenta" = 'T' THEN BEGIN
                                                HastaFecha := CALCDATE('PT+1D-1T+PT', DummyDate);
                                                // Final Trimestre
                                                DesdeFecha := CALCDATE('-1T+PM+1D', HastaFecha);
                                                // Principo Trimestre
                                                if DATE2DMY(HastaFecha, 2) = 12 THEN
                                                    vtoDummyDate := CALCDATE("Vto enero", CALCDATE('1D', HastaFecha))
                                                ELSE
                                                    vtoDummyDate := CALCDATE("Vto Resto Año", CALCDATE('1D', HastaFecha));
                                            END;

                                        END;
                                        if "Calcular vto. Cuenta" = 'M' THEN BEGIN
                                            HastaFecha := CALCDATE('PM+1D-1M+PM', DummyDate);
                                            //Fin mes
                                            DesdeFecha := CALCDATE('-1M+PM+1D', HastaFecha);
                                            //Principio mes
                                            if DATE2DMY(HastaFecha, 2) = 12 THEN
                                                vtoDummyDate := CALCDATE("Vto enero", CALCDATE('1D', HastaFecha))
                                            ELSE
                                                vtoDummyDate := CALCDATE("Vto Resto Año", CALCDATE('1D', HastaFecha));
                                        END;
                                        vtoanterior := vtoDummyDate;
                                    END ELSE BEGIN
                                        DesdeFecha2 := DesdeFecha;
                                        if ("Calcular vto. Cuenta" <> '') THEN BEGIN
                                            if "Calcular vto. Cuenta" = 'T' THEN
                                                DesdeFecha2 := CALCDATE('PT+1D-1T+5D', DummyDate)
                                            ELSE
                                                DesdeFecha2 := CALCDATE('PM+1D-1M+5D', DummyDate);
                                        END;
                                        r17.SETRANGE("Posting Date", DesdeFecha2, DummyDate);
                                        r17.SETRANGE("Pago Impuestos", TRUE);
                                        // Si la fecha de calculo es mayor que la fecha de vencimientio se va al trimestre o mes en curso
                                        if ("Calcular vto. Cuenta" <> '') AND (r17.FINDLAST) THEN BEGIN
                                            if "Calcular vto. Cuenta" = 'T' THEN BEGIN
                                                HastaFecha := CALCDATE('PT', DummyDate);
                                                // Final Trimestre
                                                DesdeFecha := CALCDATE('-1T+PT+1D', HastaFecha);
                                                // Principo Trimestre
                                                if DATE2DMY(HastaFecha, 2) = 12 THEN
                                                    vtoDummyDate := CALCDATE("Vto enero", CALCDATE('1D', HastaFecha))
                                                ELSE
                                                    vtoDummyDate := CALCDATE("Vto Resto Año", CALCDATE('1D', HastaFecha));
                                            END;
                                            if "Calcular vto. Cuenta" = 'M' THEN BEGIN
                                                HastaFecha := CALCDATE('PM', DummyDate);
                                                //Fin mes
                                                DesdeFecha := CALCDATE('-1M+PM+1D', HastaFecha);
                                                //Principio mes
                                                if DATE2DMY(HastaFecha, 2) = 12 THEN
                                                    vtoDummyDate := CALCDATE("Vto enero", CALCDATE('1D', HastaFecha))
                                                ELSE
                                                    vtoDummyDate := CALCDATE("Vto Resto Año", CALCDATE('1D', HastaFecha));
                                            END;
                                            vtoanterior := vtoDummyDate;
                                        END;


                                        //    if "No."='476000001' THEN ERROR('%1 %2 %3 %4',DummyDate,vtoDummyDate,HastaFecha,DesdeFecha);
                                        r17.SETRANGE("Posting Date", DesdeFecha, HastaFecha);
                                        r17.SETRANGE("Pago Impuestos");
                                        r17.SETRANGE("Posting Date", 0D, HastaFecha);
                                        r17.SETFILTER(Banco, '<>%1', '');
                                        "Source Type" := "Source Type"::" ";
                                        "Account Type" := "Account Type"::Entry;
                                        CFWorksheetLine2."Source Type" := CFWorksheetLine2."Source Type"::"Liquid Funds";
                                        CFWorksheetLine2."Source No." := TempGLAccount."No.";
                                        "Document No." := TempGLAccount."No.";
                                        CFWorksheetLine2."Cash Flow Account No." := "Cash Flow Account"."No.";
                                        RESET;
                                        if r17.FINDLAST THEN
                                            "Cod banco" := r17.Banco;
                                        if LiqAcc.GET("Cash Flow Account"."No.") THEN BEGIN
                                            if TRUE THEN BEGIN
                                                LiqAcc.SETRANGE(LiqAcc."Vinculado a noº", "No.");
                                                LiqAcc.SETFILTER(LiqAcc."Cod banco", '%1', "Cod banco");
                                                LiqAcc.SETFILTER(LiqAcc."Banco Informes", '%1', NBanco("Cod banco"));
                                                if NOT LiqAcc.FINDFIRST THEN BEGIN
                                                    LiqAcc.SETFILTER(LiqAcc."Banco Informes", '%1', '');
                                                    if NOT LiqAcc.FINDFIRST THEN BEGIN
                                                        LiqAcc.SETRANGE(LiqAcc."Cod banco");
                                                        LiqAcc.SETFILTER(LiqAcc."Banco Informes", '%1', NBanco("Cod banco"));
                                                        if NOT LiqAcc.FINDFIRST THEN BEGIN
                                                            LiqAcc.SETRANGE(LiqAcc."Banco Informes");
                                                            LiqAcc.SETRANGE(LiqAcc."No.", "Cash Flow Account"."No.");
                                                        END;
                                                    END;
                                                END;
                                                if LiqAcc.FINDFIRST THEN
                                                    "Cash Flow Account No." := LiqAcc."No.";
                                                if LiqAcc."Banco Informes" <> '' THEN
                                                    "Nombre Banco" := LiqAcc."Banco Informes"
                                                ELSE
                                                    "Nombre Banco" := NBanco("Cod banco");
                                            END;
                                            LiqAcc.RESET;
                                        END;
                                        //"Cod banco":=LiqAcc."Cod banco";
                                        //ELSE
                                        vtoDummyDate := vtoanterior;
                                        Description := COPYSTR(STRSUBSTNO('%1  %2 De %3 a %4', FORMAT("Tipo Saldo"), TempGLAccount."No.", FORMAT(DesdeFecha),
                                                            FORMAT(HastaFecha)), 1, MAXSTRLEN(CFWorksheetLine2.Description));
                                        if ("Dia de pago" <> DiaPago) AND (LiqAccT."Vto Resto Año" = DiaPago) AND (LiqAccT."Vto enero" = DiaPago) THEN
                                            "Due Date" := CALCDATE(LiqAcc."Dia de pago", vtoDummyDate)
                                        ELSE
                                            "Due Date" := vtoDummyDate;//WORKDATE;
                                        "Cash Flow Date" := "Due Date";//WORKDATE;
                                        "Fecha Registro" := DummyDate;
                                        if (HastaFecha <> 0D) AND ("Tipo Saldo" = "Tipo Saldo"::"Saldo a la fecha") THEN BEGIN
                                            TempGLAccount.SETRANGE("Date Filter", 0D, HastaFecha);
                                            TempGLAccount.CALCFIELDS("Balance at Date");
                                            "Amount (LCY)" := TempGLAccount."Balance at Date";
                                            //"Amount (Currency)" := "G/L Account"."Balance at Date";

                                        END ELSE BEGIN
                                            TempGLAccount.CALCFIELDS("Net Change");
                                            "Amount (LCY)" := TempGLAccount."Net Change";
                                            //"Amount (Currency)" := "G/L Account"."Net Change";
                                        END;
                                        TempGLAccount.SETRANGE(TempGLAccount."Date Filter");
                                        "Shortcut Dimension 2 Code" := TempGLAccount."Global Dimension 2 Code";
                                        "Shortcut Dimension 1 Code" := TempGLAccount."Global Dimension 1 Code";

                                        //"Gen. Bus. Posting Group" := TempGLAccount."Gen. Bus. Posting Group";
                                        //"Gen. Prod. Posting Group" := TempGLAccount."Gen. Prod. Posting Group";
                                        if "Amount (LCY)" <> 0 THEN BEGIN
                                            if not salta Then
                                                InsertLiqLine();
                                            // Transfer Dimensions
                                            // DefaultDim.RESET;
                                            // DefaultDim.SETRANGE("Table ID",DATABASE::"G/L Account");
                                            // DefaultDim.SETRANGE("No.","G/L Account"."No.");
                                            // LiqDimMgt.MoveDefaultDimToJnlLineDim(DefaultDim,JnlLineDim,DATABASE::"Liq. Journal Line",LiqLine."Journal Template Name",
                                            //                                     LiqLine."Journal Batch Name",LiqLine."Line No.",0);
                                        END;
                                        //InsertCFLineForGLAccount(TempGLAccount);
                                    end;
                                end;
                            until TempGLAccount.Next() = 0;
                    end;
                    if "Cash Flow Account"."Source Type" = "Cash Flow Account"."Source Type"::"Liquid Funds" then begin
                        if "Cash Flow Account"."Banco Informes" <> '' Then begin
                            Bank.Reset();
                            Bank.SetRange("Name 2", "Cash Flow Account"."Banco Informes");
                        end else begin
                            Bank.Reset();
                            Bank.SetFilter("No.", "Cash Flow Account"."G/L Account Filter");
                            if Bank.FindFirst() Then begin
                                Cf.SetRange("Source Type", Cf."Source Type"::"Liquid Funds");
                                Cf.SetRange("Banco Informes", Bank."Name 2");
                                if Cf.FindFirst() then begin
                                    Bank.SetRange("No.", '-1');
                                end;
                            end;
                        end;
                        if Bank.FindFirst() Then begin

                            Bank.CALCFIELDS(Balance);


                            WITH CFWorksheetLine2 DO BEGIN
                                INIT;
                                "Source Type" := "Source Type"::"Liquid Funds";
                                //"Source Type" := "Source Type"::
                                "Source No." := Bank."No.";
                                "Document No." := Bank."No.";
                                "Cod banco" := Bank."No.";
                                "Associated Entry No." := 0;
                                if LiqAcc."Banco Informes" <> '' THEN
                                    "Nombre Banco" := LiqAcc."Banco Informes"
                                ELSE
                                    "Nombre Banco" := NBanco("Cod banco");
                                "Es Cartera" := TRUE;
                                "Cash Flow Account No." := LiqAcc."No.";
                                Description := COPYSTR(STRSUBSTNO(Text1140013, Bank.Name, FORMAT(Bank.Balance)),
                                                    1, MAXSTRLEN(CFWorksheetLine2.Description));
                                "Due Date" := DummyDate;//WORKDATE;
                                CFWorksheetLine2."Cash Flow Date" := DummyDate;//WORKDATE;
                                "Amount (LCY)" := Bank.Balance;
                                //"Amount (Currency)" := Bank.Balance;
                                "Shortcut Dimension 2 Code" := Bank."Global Dimension 2 Code";
                                "Shortcut Dimension 1 Code" := Bank."Global Dimension 1 Code";
                                //"Gen. Bus. Posting Group" := '';//"G/L Account"."Gen. Bus. Posting Group";
                                //"Gen. Prod. Posting Group" :='';// "G/L Account"."Gen. Prod. Posting Group";
                                if "Amount (LCY)" <> 0 THEN BEGIN
                                    InsertLiqLine();
                                    // Transfer Dimensions
                                    // DefaultDim.RESET;
                                    // DefaultDim.SETRANGE("Table ID",DATABASE::Bank);
                                    // DefaultDim.SETRANGE("No.",Bank."No.");
                                    // LiqDimMgt.MoveDefaultDimToJnlLineDim(DefaultDim,JnlLineDim,DATABASE::"Liq. Journal Line",LiqLine."Journal Template Name",
                                    //                                     LiqLine."Journal Batch Name",LiqLine."Line No.",0);
                                END;

                            end;
                        end;
                    end;
                end;

                trigger OnPreDataItem()
                begin
                    if not ConsiderSource[SourceType::"Liquid Funds".AsInteger()] then
                        CurrReport.Break();

                    if not ReadPermission then
                        CurrReport.Break();
                end;
            }
            dataitem("Cartera Doc."; "Cartera Doc.")
            {
                DataItemTableView = SORTING("Collection Agent", "Bill Gr./Pmt. Order No.", "Currency Code", Accepted, "Due Date", Place) ORDER(Ascending)
                WHERE("Remaining Amount" = FILTER(<> 0), Type = Const(Receivable));

                trigger OnAfterGetRecord()
                begin
                    Window.Update(2, 'Cartera Cliente');
                    Window.Update(3, "Entry No.");

                    if "Account No." <> '' THEN
                        Customer.GET("Account No.")
                    ELSE
                        Customer.INIT;


                    if DueDateF <> 0D THEN
                        if "Cartera Doc."."Due Date" > CALCDATE('181D', WORKDATE) THEN CurrReport.SKIP;
                    InsertCFLineForCartera();

                end;

                trigger OnPreDataItem()
                begin
                    if not ConsiderSource[SourceType::"Cartera Clientes".AsInteger()] then
                        CurrReport.Break();

                    if not ReadPermission then
                        CurrReport.Break();
                end;

                trigger OnPostDataItem()
                begin
                    Commit();
                end;
            }
            dataitem("Posted Cartera Doc."; "Posted Cartera Doc.")
            {
                DataItemTableView = SORTING("Bill Gr./Pmt. Order No.", Status, "Category Code", Redrawn, "Due Date") ORDER(Ascending)
                WHERE("Remaining Amount" = FILTER(<> 0), Type = Const(Receivable));

                trigger OnAfterGetRecord()
                begin
                    Window.Update(2, 'Cartera Cliente');
                    Window.Update(3, "Entry No.");

                    if "Account No." <> '' THEN
                        Customer.GET("Account No.")
                    ELSE
                        Customer.INIT;


                    if DueDateF <> 0D THEN
                        if "Posted Cartera Doc."."Due Date" > CALCDATE('181D', WORKDATE) THEN CurrReport.SKIP;
                    InsertCFLineForPostedCartera();

                end;

                trigger OnPreDataItem()
                begin
                    if not ConsiderSource[SourceType::"Cartera Clientes".AsInteger()] then
                        CurrReport.Break();

                    if not ReadPermission then
                        CurrReport.Break();
                end;

                trigger OnPostDataItem()
                begin
                    Commit();
                end;
            }
            dataitem("Cust. Ledger Entry"; "Cust. Ledger Entry")
            {
                DataItemTableView = SORTING(Open, "Due Date") ORDER(Ascending) WHERE(Open = CONST(true), "Remaining Amount" = FILTER(<> 0));

                trigger OnAfterGetRecord()
                begin
                    Window.Update(2, Text005);
                    Window.Update(3, "Entry No.");
                    if ("Cust. Ledger Entry"."Nº Factura Borrador" <> '') and
                    ("Cust. Ledger Entry"."Document Type" <> "Cust. Ledger Entry"."Document Type"::Payment)
                    THEN
                        CurrReport.SKIP;
                    if "Customer No." <> '' then
                        Customer.Get("Customer No.")
                    else
                        Customer.Init();

                    if "Cust. Ledger Entry"."Due Date" < DueDateD THEN Atrasado := TRUE ELSE Atrasado := FALSE;
                    if DueDateF <> 0D THEN
                        if "Cust. Ledger Entry"."Due Date" > CALCDATE('181D', WORKDATE) THEN CurrReport.SKIP;
                    CalcFields("Remaining Amt. (LCY)", "Remaining Amount");

                    InsertCFLineForCustLedgerEntry();
                end;

                trigger OnPreDataItem()
                begin
                    if not ConsiderSource[SourceType::Receivables.AsInteger()] then
                        CurrReport.Break();

                    if not ReadPermission then
                        CurrReport.Break();
                end;

                trigger OnPostDataItem()
                begin
                    Commit();
                end;
            }

            dataitem("Vendor Cartera Doc."; "Cartera Doc.")
            {
                DataItemTableView = SORTING("Collection Agent", "Bill Gr./Pmt. Order No.", "Currency Code", Accepted, "Due Date", Place) ORDER(Ascending)
                WHERE("Remaining Amount" = FILTER(<> 0), Type = Const(Payable));

                trigger OnAfterGetRecord()
                begin
                    Window.Update(2, 'Cartera proveedor');
                    Window.Update(3, "Entry No.");

                    if "Account No." <> '' THEN
                        Vendor.GET("Account No.")
                    ELSE
                        Vendor.INIT;


                    if DueDateF <> 0D THEN
                        if "Vendor Cartera Doc."."Due Date" > CALCDATE('181D', WORKDATE) THEN CurrReport.SKIP;
                    InsertPFLineForCartera();

                end;

                trigger OnPreDataItem()
                begin
                    if not ConsiderSource[SourceType::"Cartera Proveedores".AsInteger()] then
                        CurrReport.Break();

                    if not ReadPermission then
                        CurrReport.Break();
                end;

                trigger OnPostDataItem()
                begin
                    Commit();
                end;
            }
            dataitem("Vendor Pos Cartera Doc."; "Posted Cartera Doc.")
            {
                DataItemTableView = SORTING("Bill Gr./Pmt. Order No.", Status, "Category Code", Redrawn, "Due Date") ORDER(Ascending)
                WHERE("Remaining Amount" = FILTER(<> 0), Type = Const(Payable));

                trigger OnAfterGetRecord()
                begin
                    Window.Update(2, 'Cartera Proveedor');
                    Window.Update(3, "Entry No.");

                    if "Account No." <> '' THEN
                        Vendor.GET("Account No.")
                    ELSE
                        Vendor.INIT;


                    if DueDateF <> 0D THEN
                        if "Vendor Pos Cartera Doc."."Due Date" > CALCDATE('181D', WORKDATE) THEN CurrReport.SKIP;
                    InsertPFLineForPostedCartera();

                end;

                trigger OnPreDataItem()
                begin
                    if not ConsiderSource[SourceType::"Cartera Proveedores".AsInteger()] then
                        CurrReport.Break();

                    if not ReadPermission then
                        CurrReport.Break();
                end;

                trigger OnPostDataItem()
                begin
                    Commit();
                end;
            }
            dataitem("Vendor Ledger Entry"; "Vendor Ledger Entry")
            {
                DataItemTableView = SORTING(Open, "Due Date") ORDER(Ascending) WHERE(Open = CONST(true), "Remaining Amount" = FILTER(<> 0));

                trigger OnAfterGetRecord()
                begin
                    Window.Update(2, Text006);
                    Window.Update(3, "Entry No.");

                    if DueDateF <> 0D THEN
                        if "Vendor Ledger Entry"."Due Date" > DueDateF THEN CurrReport.SKIP;
                    if "Vendor Ledger Entry"."Due Date" < DueDateD THEN Atrasado := TRUE ELSE Atrasado := FALSE;
                    if "Vendor No." <> '' then
                        Vendor.Get("Vendor No.")
                    else
                        Vendor.Init();

                    CalcFields("Remaining Amt. (LCY)", "Remaining Amount");

                    InsertCFLineForVendorLedgEntry();
                end;

                trigger OnPreDataItem()
                begin
                    if not ConsiderSource[SourceType::Payables.AsInteger()] then
                        CurrReport.Break();

                    if not ReadPermission then
                        CurrReport.Break();
                end;

                trigger OnPostDataItem()
                begin
                    Commit();
                end;
            }
            dataitem("Purchase Line"; "Purchase Line")
            {
                DataItemTableView = SORTING("Document Type", "Document No.", "Line No.") ORDER(Ascending) WHERE("Document Type" = CONST(Order));

                trigger OnAfterGetRecord()
                begin
                    Window.Update(2, Text007);
                    Window.Update(3, "Document No.");

                    PurchHeader.Get("Document Type", "Document No.");
                    if PurchHeader."Buy-from Vendor No." <> '' then
                        Vendor.Get(PurchHeader."Pay-to Vendor No.")
                    else
                        Vendor.Init();

                    InsertCFLineForPurchaseLine();
                end;

                trigger OnPreDataItem()
                begin
                    if not ConsiderSource[SourceType::"Purchase Orders".AsInteger()] then
                        CurrReport.Break();

                    if not ReadPermission then
                        CurrReport.Break();

                    if not ApplicationAreaMgmtFacade.IsSuiteEnabled and not ApplicationAreaMgmtFacade.IsAllDisabled then
                        CurrReport.Break();
                end;
            }
            dataitem("Sales Line"; "Sales Line")
            {
                DataItemTableView = SORTING("Document Type", "Document No.", "Line No.") ORDER(Ascending) WHERE("Document Type" = CONST(Order));

                trigger OnAfterGetRecord()
                begin
                    Window.Update(2, Text008);
                    Window.Update(3, "Document No.");

                    SalesHeader.Get("Document Type", "Document No.");
                    if SalesHeader."Sell-to Customer No." <> '' then
                        Customer.Get(SalesHeader."Bill-to Customer No.")
                    else
                        Customer.Init();

                    InsertCFLineForSalesLine();
                end;

                trigger OnPreDataItem()
                begin
                    if not ConsiderSource[SourceType::"Sales Orders".AsInteger()] then
                        CurrReport.Break();

                    if not ReadPermission then
                        CurrReport.Break();
                end;
            }
            dataitem(InvestmentFixedAsset; "Fixed Asset")
            {
                DataItemTableView = SORTING("No.") WHERE("Budgeted Asset" = CONST(true));

                trigger OnAfterGetRecord()
                begin
                    if FADeprBook.Get("No.", FASetup."Default Depr. Book") then begin
                        FADeprBook.CalcFields("Acquisition Cost");

                        Window.Update(2, Text009);
                        Window.Update(3, "No.");

                        InsertCFLineForFixedAssetsBudget();
                    end;
                end;

                trigger OnPreDataItem()
                begin
                    if not ConsiderSource[SourceType::"Fixed Assets Budget".AsInteger()] then
                        CurrReport.Break();

                    if not ReadPermission then
                        CurrReport.Break();

                    FASetup.Get();
                end;
            }
            dataitem(SaleFixedAsset; "Fixed Asset")
            {
                DataItemTableView = SORTING("No.") WHERE("Budgeted Asset" = CONST(false));

                trigger OnAfterGetRecord()
                begin
                    if FADeprBook.Get("No.", FASetup."Default Depr. Book") then
                        if (FADeprBook."Disposal Date" = 0D) and
                           (FADeprBook."Projected Disposal Date" <> 0D) and
                           (FADeprBook."Projected Proceeds on Disposal" <> 0)
                        then begin
                            Window.Update(2, Text010);
                            Window.Update(3, "No.");

                            InsertCFLineForFixedAssetsDisposal();
                        end;
                end;

                trigger OnPreDataItem()
                begin
                    if not ConsiderSource[SourceType::"Fixed Assets Disposal".AsInteger()] then
                        CurrReport.Break();

                    if not ReadPermission then
                        CurrReport.Break();

                    FASetup.Get();
                end;
            }
            dataitem("Cash Flow Manual Expense"; "Cash Flow Manual Expense")
            {
                DataItemTableView = SORTING(Code) ORDER(Ascending);

                trigger OnAfterGetRecord()
                begin
                    Window.Update(2, Text011);
                    Window.Update(3, Code);

                    InsertCFLineForManualExpense();
                end;

                trigger OnPreDataItem()
                begin
                    if not ConsiderSource[SourceType::"Cash Flow Manual Expense".AsInteger()] then
                        CurrReport.Break();

                    if not ReadPermission then
                        CurrReport.Break();
                end;
            }
            dataitem("Cash Flow Manual Revenue"; "Cash Flow Manual Revenue")
            {
                DataItemTableView = SORTING(Code) ORDER(Ascending);

                trigger OnAfterGetRecord()
                begin
                    Window.Update(2, Text012);
                    Window.Update(3, Code);

                    InsertCFLineForManualRevenue();
                end;

                trigger OnPreDataItem()
                begin
                    if not ConsiderSource[SourceType::"Cash Flow Manual Revenue".AsInteger()] then
                        CurrReport.Break();

                    if not ReadPermission then
                        CurrReport.Break();
                end;
            }
            dataitem(CFAccountForBudget; "Cash Flow Account")
            {
                DataItemTableView = SORTING("No.") ORDER(Ascending) WHERE("G/L Integration" = FILTER(Budget | Both), "G/L Account Filter" = FILTER(<> ''));

                trigger OnAfterGetRecord()
                var
                    GLAcc: Record "G/L Account";
                begin
                    GLAcc.SetFilter("No.", "G/L Account Filter");
                    if GLAcc.FindSet() then
                        repeat
                            Window.Update(2, Text031);
                            Window.Update(3, GLAcc."No.");

                            GLBudgEntry.SetRange("Budget Name", GLBudgName);
                            GLBudgEntry.SetRange("G/L Account No.", GLAcc."No.");
                            GLBudgEntry.SetRange(Date, "Cash Flow Forecast"."G/L Budget From", "Cash Flow Forecast"."G/L Budget To");
                            if GLBudgEntry.FindSet() then
                                repeat
                                    InsertCFLineForGLBudget(GLAcc);
                                until GLBudgEntry.Next = 0;
                        until GLAcc.Next = 0;
                end;

                trigger OnPreDataItem()
                begin
                    if not ConsiderSource[SourceType::"G/L Budget".AsInteger()] then
                        CurrReport.Break();

                    if not ReadPermission then
                        CurrReport.Break();
                end;
            }
            dataitem("Service Line"; "Service Line")
            {
                DataItemTableView = SORTING("Document Type", "Document No.", "Line No.") WHERE("Document Type" = CONST(Order));

                trigger OnAfterGetRecord()
                begin
                    Window.Update(2, Text032);
                    Window.Update(3, "Document No.");

                    ServiceHeader.Get("Document Type", "Document No.");
                    if ServiceHeader."Bill-to Customer No." <> '' then
                        Customer.Get(ServiceHeader."Bill-to Customer No.")
                    else
                        Customer.Init();

                    InsertCFLineForServiceLine();
                end;

                trigger OnPreDataItem()
                begin
                    if not ConsiderSource[SourceType::"Service Orders".AsInteger()] then
                        CurrReport.Break();

                    if not ReadPermission then
                        CurrReport.Break();
                end;
            }
            dataitem("Job Planning Line"; "Job Planning Line")
            {
                DataItemTableView = SORTING("Job No.", "Planning Date", "Document No.");

                trigger OnAfterGetRecord()
                begin
                    Window.Update(2, JobsMsg);
                    Window.Update(3, "Job No.");

                    if not ("Line Type" in ["Line Type"::Billable, "Line Type"::"Both Budget and Billable"]) then
                        exit;

                    InsertCFLineForJobPlanningLine();
                end;

                trigger OnPreDataItem()
                begin
                    if not ConsiderSource[SourceType::Job.AsInteger()] then
                        CurrReport.Break();

                    if not ReadPermission then
                        CurrReport.Break();

                    if not ApplicationAreaMgmtFacade.IsJobsEnabled and not ApplicationAreaMgmtFacade.IsAllDisabled then
                        CurrReport.Break();
                end;
            }
            dataitem("Purchase Header"; "Purchase Header")
            {
                DataItemTableView = SORTING("Document Type", "No.") WHERE("Document Type" = CONST(Order));

                trigger OnAfterGetRecord()
                var
                    PurchaseOrder: Page "Purchase Order";
                begin
                    Window.Update(2, PurchaseOrder.Caption);
                    Window.Update(3, "No.");

                    InsertCFLineForTax(DATABASE::"Purchase Header");
                end;

                trigger OnPreDataItem()
                begin
                    if not ConsiderSource[SourceType::Tax.AsInteger()] then
                        CurrReport.Break();

                    if not ReadPermission then
                        CurrReport.Break();

                    if not ApplicationAreaMgmtFacade.IsSuiteEnabled and not ApplicationAreaMgmtFacade.IsAllDisabled then
                        CurrReport.Break();

                    CashFlowManagement.SetViewOnPurchaseHeaderForTaxCalc("Purchase Header", DummyDate);
                end;
            }
            dataitem("Sales Header"; "Sales Header")
            {
                DataItemTableView = SORTING("Document Type", "No.") WHERE("Document Type" = CONST(Order));

                trigger OnAfterGetRecord()
                var
                    SalesOrder: Page "Sales Order";
                begin
                    Window.Update(2, SalesOrder.Caption);
                    Window.Update(3, "No.");

                    InsertCFLineForTax(DATABASE::"Sales Header");
                end;

                trigger OnPreDataItem()
                begin
                    if not ConsiderSource[SourceType::Tax.AsInteger()] then
                        CurrReport.Break();

                    if not ReadPermission then
                        CurrReport.Break();

                    CashFlowManagement.SetViewOnSalesHeaderForTaxCalc("Sales Header", DummyDate);
                end;
            }
            dataitem("VAT Entry"; "VAT Entry")
            {

                trigger OnAfterGetRecord()
                var
                    VATEntries: Page "VAT Entries";
                begin
                    Window.Update(2, VATEntries.Caption);
                    Window.Update(3, "Entry No.");

                    InsertCFLineForTax(DATABASE::"VAT Entry");
                end;

                trigger OnPreDataItem()
                begin
                    if not ConsiderSource[SourceType::Tax.AsInteger()] then
                        CurrReport.Break();

                    if not ReadPermission then
                        CurrReport.Break();

                    CashFlowManagement.SetViewOnVATEntryForTaxCalc("VAT Entry", DummyDate);
                end;
            }
            dataitem("Cash Flow Azure AI Buffer"; "Cash Flow Azure AI Buffer")
            {

                trigger OnAfterGetRecord()
                begin
                    InsertCFLineForAzureAIForecast(DATABASE::"Cash Flow Azure AI Buffer");
                end;

                trigger OnPreDataItem()
                var
                    CashFlowForecastHandler: Codeunit "Cash Flow Forecast Handler";
                begin
                    if not ConsiderSource[SourceType::"Azure AI".AsInteger()] then
                        CurrReport.Break();

                    if not ReadPermission then
                        CurrReport.Break();

                    if not CashFlowForecastHandler.CalculateForecast then
                        CurrReport.Break();

                    SetRange(Type, Type::Forecast, Type::Correction);
                    if FindSet() then;
                end;
            }
            dataitem("Detalle Prestamo"; "Detalle Prestamo")
            {
                DataItemTableView = SORTING("Código Del Prestamo", Fecha, Liquidado) where(Renting = const(false));

                trigger OnAfterGetRecord()
                var
                    rCab: Record "Cabecera Prestamo";
                    PresLine2: Record "Detalle Prestamo";
                    rBanc: Record "Bank Account";
                    Factor: Decimal;
                    TotalAmtCurrency: Decimal;
                    TotalLineAmount: Decimal;
                begin
                    Window.Update(2, PrestMsg);
                    Window.Update(3, "Código Del Prestamo");


                    InsertCfLineForPrestamos();
                end;

                trigger OnPreDataItem()
                begin
                    if not ConsiderSource[SourceType::"Detalle Préstamos".AsInteger()] then
                        CurrReport.Break();

                    if not ReadPermission then
                        CurrReport.Break();

                    // if not ApplicationAreaMgmtFacade.IsJobsEnabled and not ApplicationAreaMgmtFacade.IsAllDisabled then
                    //   CurrReport.Break();
                end;
            }
            dataitem("Detalle Renting"; "Detalle Prestamo")
            {
                DataItemTableView = SORTING("Código Del Prestamo", Fecha, Liquidado) where(Renting = const(true));

                trigger OnAfterGetRecord()
                var
                    rCab: Record "Cabecera Prestamo";
                    PresLine2: Record "Detalle Prestamo";
                    rBanc: Record "Bank Account";
                    Factor: Decimal;
                    TotalAmtCurrency: Decimal;
                    TotalLineAmount: Decimal;
                begin
                    Window.Update(2, RentingMsg);
                    Window.Update(3, "Código Del Prestamo");


                    InsertCfLineForRenting();
                end;

                trigger OnPreDataItem()
                begin
                    if not ConsiderSource[SourceType::Rentings.AsInteger()] then
                        CurrReport.Break();

                    if not ReadPermission then
                        CurrReport.Break();

                    // if not ApplicationAreaMgmtFacade.IsJobsEnabled and not ApplicationAreaMgmtFacade.IsAllDisabled then
                    //   CurrReport.Break();
                end;
            }
            dataitem("Movimientos Emplazamiento"; "Mov. emplazamientos")
            {
                DataItemTableView = SORTING("Nº proveedor", "Nº mov.");

                trigger OnAfterGetRecord()
                var
                    rCab: Record "Cabecera Prestamo";
                    PresLine2: Record "Detalle Prestamo";
                    rBanc: Record "Bank Account";
                    Factor: Decimal;
                    TotalAmtCurrency: Decimal;
                    TotalLineAmount: Decimal;
                begin
                    Window.Update(2, EmplaMsg);
                    Window.Update(3, "Nº emplazamiento");


                    InsertCfLineForEmplazaMientos();
                end;

                trigger OnPreDataItem()
                begin
                    if not ConsiderSource[SourceType::"Detalle Préstamos".AsInteger()] then
                        CurrReport.Break();

                    if not ReadPermission then
                        CurrReport.Break();

                    // if not ApplicationAreaMgmtFacade.IsJobsEnabled and not ApplicationAreaMgmtFacade.IsAllDisabled then
                    //   CurrReport.Break();
                end;
            }

            trigger OnAfterGetRecord()
            begin
                Window.Update(1, "No.");
            end;

            trigger OnPostDataItem()
            var
                TempCashFlowForecast: Record "Cash Flow Forecast" temporary;
            begin
                InsertWorksheetLines(TempCashFlowForecast);
                DeleteEntries(TempCashFlowForecast);
                if NeedsManualPmtUpdate then
                    Message(ManualPmtRevExpNeedsUpdateMsg, TempCashFlowForecast."No.");
            end;

            trigger OnPreDataItem()
            begin
                SetRange("No.", CashFlowNo);
                LineNo := 0;
                NeedsManualPmtUpdate := false;
            end;
        }
    }

    requestpage
    {
        SaveValues = true;

        layout
        {
            area(content)
            {
                group(Options)
                {
                    Caption = 'Opciones';
                    field(CashFlowNo; CashFlowNo)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Previsión flujos efectivo';
                        TableRelation = "Cash Flow Forecast";
                        ToolTip = 'Especique la precisión de flujos de ehectivo fara cada apartado que sesee incluir en el cálculo';
                    }
                    field("Fecha Registro"; DummyDate)
                    {
                        ApplicationArea = All;
                        trigger OnValidate()
                        begin
                            DueDateD := CalcDate('PM+1D-1M', Today);
                        end;
                    }
                    field("Vencimiento Desde"; DueDateD)
                    {
                        ApplicationArea = All;
                        Editable = false;
                    }
                    field("Vencimiento Hasta"; DueDateF)
                    {
                        ApplicationArea = All;
                        trigger OnValidate()
                        begin
                            DueDateD := CalcDate('PM+1D-1M', Today);
                        end;
                    }
                    group("Source Types incluir:")
                    {
                        Caption = 'Tipos de origen a incluir:';
                        field("ConsiderSource[SourceType::""Liquid Funds""]"; ConsiderSource[SourceType::"Liquid Funds".AsInteger()])
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'Fondos líquidos';
                            ToolTip = 'Marque este punto si quiere traspasar los saldos de los movimientos de los bancos definidos como fondos líquidos';
                        }
                        field("ConsiderSource[SourceType::""Cartera Clientes""]"; ConsiderSource[SourceType::"Cartera Clientes".AsInteger()])
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'Cartera Clientes';
                            ToolTip = 'Marque este punto si quiere incluir movimientos pendientes de cartera en la previsión de flujos de efectivo.';
                        }
                        field("ConsiderSource[SourceType::Receivables]"; ConsiderSource[SourceType::Receivables.AsInteger()])
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'Cobros';
                            ToolTip = 'Marque este punto si quiere incluir movimientos pendientes de cliente en la previsión de flujos de efectivo.';
                        }
                        field("ConsiderSource[SourceType::""Sales Order""]"; ConsiderSource[SourceType::"Sales Orders".AsInteger()])
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'Pedidos de venta';
                            ToolTip = 'Marque este punto si quiere incluir los pedidos de venta en la previsión de flujos de efectivo.';
                        }
                        field("ConsiderSource[SourceType::""Service Orders""]"; ConsiderSource[SourceType::"Service Orders".AsInteger()])
                        {
                            ApplicationArea = Service;
                            Caption = 'Pedidos de servicio';
                            ToolTip = 'Marque este punto si quiere incluir los pedidos de servicio en la previsión de flujos de efectivo.';
                        }
                        field("ConsiderSource[SourceType::""Sale of Fixed Asset""]"; ConsiderSource[SourceType::"Fixed Assets Disposal".AsInteger()])
                        {
                            ApplicationArea = FixedAssets;
                            Caption = 'Venta/baja Activos fijos';
                            ToolTip = 'Marque este punto si quiere incluir los movimientos de venta/baja previstos en la previsión de flujos de efectivo.';
                        }
                        field("ConsiderSource[SourceType::""Cash Flow Manual Revenue""]"; ConsiderSource[SourceType::"Cash Flow Manual Revenue".AsInteger()])
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'Ingresos manuales';
                            ToolTip = 'Marque este punto si los ingresos manuales deben ser incluidos en la previsión de flujos de efectivo.';
                        }
                        field("ConsiderSource[SourceType::""Cartera Proveedore""]"; ConsiderSource[SourceType::"Cartera Proveedores".AsInteger()])
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'Cartera Proveedores';
                            ToolTip = 'Marque este punto si quiere incluir movimientos pendientes de cartera en la previsión de flujos de efectivo.';
                        }
                        field("ConsiderSource[SourceType::Payables]"; ConsiderSource[SourceType::Payables.AsInteger()])
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'Pagos';
                            ToolTip = 'Marque este punto si quiere incluir los movimientos pendientes de proveedor en la previsión de flujos de efectivo.';
                        }
                        field("ConsiderSource[SourceType::""Purchase Order""]"; ConsiderSource[SourceType::"Purchase Orders".AsInteger()])
                        {
                            ApplicationArea = Suite;
                            Caption = 'Pedidos compra';
                            ToolTip = 'Marque este punto si quiere incluir los pedidos de compra en la previsión de flujos de efectivo.';
                        }
                        field("ConsiderSource[SourceType::""Budgeted Fixed Asset""]"; ConsiderSource[SourceType::"Fixed Assets Budget".AsInteger()])
                        {
                            ApplicationArea = FixedAssets;
                            Caption = 'Presupuesto de activos fijos';
                            ToolTip = 'Marque este punto si quiere incluir el presupuesto de activos fijos en la previsión de flujos de efectivo.';
                        }
                        field("ConsiderSource[SourceType::""Cash Flow Manual Expense""]"; ConsiderSource[SourceType::"Cash Flow Manual Expense".AsInteger()])
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'Gastos manuales';
                            ToolTip = 'Marque este punto si los gastos manuales deben ser incluidos en la previsión de flujos de efectivo.';
                        }
                        field("ConsiderSource[SourceType::""G/L Budget""]"; ConsiderSource[SourceType::"G/L Budget".AsInteger()])
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'Presupuesto contable';
                            ToolTip = 'Marque este punto si los movimientos del presupuesto contable deben ser incluidos en la previsión de flujos de efectivo.';
                        }
                        field(GLBudgName; GLBudgName)
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'Nombre presupuesto';
                            TableRelation = "G/L Budget Name";
                            ToolTip = 'Seleccione el nombre del presupuesto.';
                        }
                        field("ConsiderSource[SourceType::Job]"; ConsiderSource[SourceType::Job.AsInteger()])
                        {
                            ApplicationArea = Jobs;
                            Caption = 'Proyectos';
                            ToolTip = 'Marque este punto si quiere incluir los movimientos del presupuesto en la previsión de flujos de efectivo.';
                        }
                        field("ConsiderSource[SourceType::Detalle Préstamos]"; ConsiderSource[SourceType::"Detalle Préstamos".AsInteger()])
                        {
                            ApplicationArea = All;
                            Caption = 'Prestamos';
                            ToolTip = 'Marque este punto si quiere incluir los movimientos de los prestamos en la previsión de flujos de efectivo.';
                        }
                        field("ConsiderSource[SourceType::Rentings]"; ConsiderSource[SourceType::Rentings.AsInteger()])
                        {
                            ApplicationArea = All;
                            Caption = 'Rentings';
                            ToolTip = 'Marque este punto si quiere incluir los movimientos de los rentings en la previsión de flujos de efectivo.';
                        }
                        field("ConsiderSource[SourceType::Moimiento emplazamientos]"; ConsiderSource[SourceType::"Movimientos emplazamientos".AsInteger()])
                        {
                            ApplicationArea = All;
                            Caption = 'Emplazamientos';
                            ToolTip = 'Marque este punto si quiere incluir los movimientos de los emplazamientos en la previsión de flujos de efectivo.';
                        }
                        field("ConsiderSource[SourceType::Tax]"; ConsiderSource[SourceType::Tax.AsInteger()])
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'Impuestos';
                            ToolTip = 'Marque este punto si quiere incluir los movimientos de impuestos en la previsión de flujos de efectivo.';
                        }
                        field("ConsiderSource[SourceType::""Azure AI""]"; ConsiderSource[SourceType::"Azure AI".AsInteger()])
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'Previsión de Azure AI st';
                            ToolTip = 'Specifies whether incluir Azure AI en la previsión de flujos de efectivo.';
                        }
                    }
                    field(Summarized; Summarized)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Agrupar por tipo de documento';
                        ToolTip = 'Marque este punto si quiere agrupar los distintos pedidos por tipo de documento.';
                    }
                }

            }

        }

        actions
        {
        }

        trigger OnInit()
        var
            CFManualExpense: Record "Cash Flow Manual Expense";
            CFManualRevenue: Record "Cash Flow Manual Revenue";
            GLBudgetEntry: Record "G/L Budget Entry";
            GLAcc: Record "G/L Account";
        begin
            DueDateD := CalcDate('PM+1D-1M', Today);
            if ConsiderSource[SourceType::"Liquid Funds".AsInteger()] then
                ConsiderSource[SourceType::"Liquid Funds".AsInteger()] := GLAcc.ReadPermission;
            if ConsiderSource[SourceType::Receivables.AsInteger()] then
                ConsiderSource[SourceType::Receivables.AsInteger()] := "Cust. Ledger Entry".ReadPermission;
            if ConsiderSource[SourceType::Payables.AsInteger()] then
                ConsiderSource[SourceType::Payables.AsInteger()] := "Vendor Ledger Entry".ReadPermission;
            if ConsiderSource[SourceType::"Purchase Orders".AsInteger()] then
                ConsiderSource[SourceType::"Purchase Orders".AsInteger()] := "Purchase Line".ReadPermission;
            if ConsiderSource[SourceType::"Sales Orders".AsInteger()] then
                ConsiderSource[SourceType::"Sales Orders".AsInteger()] := "Sales Line".ReadPermission;
            if ConsiderSource[SourceType::"Cash Flow Manual Expense".AsInteger()] then
                ConsiderSource[SourceType::"Cash Flow Manual Expense".AsInteger()] := CFManualExpense.ReadPermission;
            if ConsiderSource[SourceType::"Cash Flow Manual Revenue".AsInteger()] then
                ConsiderSource[SourceType::"Cash Flow Manual Revenue".AsInteger()] := CFManualRevenue.ReadPermission;
            if ConsiderSource[SourceType::"Fixed Assets Budget".AsInteger()] then
                ConsiderSource[SourceType::"Fixed Assets Budget".AsInteger()] := InvestmentFixedAsset.ReadPermission;
            if ConsiderSource[SourceType::"Fixed Assets Disposal".AsInteger()] then
                ConsiderSource[SourceType::"Fixed Assets Disposal".AsInteger()] := SaleFixedAsset.ReadPermission;
            if ConsiderSource[SourceType::"G/L Budget".AsInteger()] then
                ConsiderSource[SourceType::"G/L Budget".AsInteger()] := GLBudgetEntry.ReadPermission;
            if ConsiderSource[SourceType::"Service Orders".AsInteger()] then
                ConsiderSource[SourceType::"Service Orders".AsInteger()] := "Service Line".ReadPermission;
            if ConsiderSource[SourceType::Job.AsInteger()] then
                ConsiderSource[SourceType::Job.AsInteger()] := "Job Planning Line".ReadPermission;
            if ConsiderSource[SourceType::Tax.AsInteger()] then
                ConsiderSource[SourceType::Tax.AsInteger()] := "Sales Header".ReadPermission and
                  "Purchase Header".ReadPermission and "VAT Entry".ReadPermission;
            if ConsiderSource[SourceType::"Azure AI".AsInteger()] then
                ConsiderSource[SourceType::"Azure AI".AsInteger()] := "Cash Flow Azure AI Buffer".ReadPermission;
        end;
    }

    labels
    {
    }

    trigger OnPreReport()
    begin
        if CashFlowNo = '' then
            Error(Text000);
        DueDateD := CalcDate('PM+1D-1M', Today);

        if not SelectionCashFlowForecast.Get(CashFlowNo) then
            Error(Text001);

        if NoOptionsChosen then
            Error(Text002, CashFlowNo);

        CFSetup.Get();
        GLSetup.Get();
        if ConsiderSource[SourceType::"Sales Orders".AsInteger()] then
            SalesSetup.Get();
        if ConsiderSource[SourceType::"Purchase Orders".AsInteger()] then
            PurchSetup.Get();
        if ConsiderSource[SourceType::"Service Orders".AsInteger()] then
            ServSetup.Get();

        Window.Open(
          Text003 +
          Text033 +
          Text034);

        Window.Update(1, "Cash Flow Forecast"."No.");
    end;

    var
        Atrasado: Boolean;
        LiqAccT: Record "Cash Flow Account";
        Text000: Label 'Debe elegir una previsión de cash flow.';
        Text001: Label 'Elija una previsión de cash flow válida.';
        Text002: Label 'Elija una opción para rellenar la previsión de cash flow nº %1.';
        Text003: Label 'Previsión cash flow nº      #1##########\\';
        Text004: Label 'Fondos líquidos';
        Text005: Label 'Cobros';
        Text006: Label 'Pagos';
        Text007: Label 'Pedidos Compra';
        Text008: Label 'Pedidos venta';
        Text009: Label 'Presupuesto Activos';
        Text010: Label 'Venta/baja activos';
        Text011: Label 'Gastos manuales';
        Text012: Label 'Ingresos manuales';
        Text013: Label '%1 Saldo=%2';
        Text025: Label '%1 %2 %3';
        Text027: Label '%1 AC= %2';
        Text028: Label 'Gasto manual %1';
        Text029: Label 'Ingreso manual %1';
        Text030: Label '%1 presupuesto %2 ';
        Text031: Label 'Presupuesto';
        Text032: Label 'Pedidos servicio';
        Text033: Label 'Buscando para          #2####################\';
        Text034: Label 'Registros encontrados        #3####################';
        CFSetup: Record "Cash Flow Setup";
        SelectionCashFlowForecast: Record "Cash Flow Forecast";
        LiqAcc: Record "Cash Flow Account";
        TempCFWorksheetLine: Record "Cash Flow Worksheet Line" temporary;
        CFWorksheetLine2: Record "Cash Flow Worksheet Line";
        Customer: Record Customer;
        Vendor: Record Vendor;
        PurchHeader: Record "Purchase Header";
        SalesHeader: Record "Sales Header";
        ServiceHeader: Record "Service Header";
        FASetup: Record "FA Setup";
        FADeprBook: Record "FA Depreciation Book";
        GLBudgEntry: Record "G/L Budget Entry";
        GLSetup: Record "General Ledger Setup";
        Currency: Record Currency;
        CurrExchRate: Record "Currency Exchange Rate";
        PaymentMethod: Record "Payment Method";
        SalesSetup: Record "Sales & Receivables Setup";
        PurchSetup: Record "Purchases & Payables Setup";
        ServSetup: Record "Service Mgt. Setup";
        PaymentTerms: Record "Payment Terms";
        CarteraSetup: Record "Cartera Setup";
        ApplicationAreaMgmtFacade: Codeunit "Application Area Mgmt. Facade";
        CashFlowManagement: Codeunit "Cash Flow Management";
        Window: Dialog;
        ConsiderSource: array[23] of Boolean;
        SourceType: Enum "Cash Flow Source Type";
        CashFlowNo: Code[20];
        LineNo: Integer;
        DateLastExecution: Date;
        ExecutionDate: Date;
        GLBudgName: Code[10];
        TotalAmt: Decimal;
        MultiSalesLines: Boolean;
        Summarized: Boolean;
        Text1100000: Label 'No puede seleccionar movimeintos basado en efectos para los abonos.';
        Text1100001: Label '%1 debe ser 1 si %2 es Sí en %3.';
        CannotCreateCarteraDocErr: Label 'No tiene permisos para crer Documentpos de Cartera.\Por favor, cambie el método de pago.';
        Text1100004: Label 'Pedido venta efecto nº %1 de %2.';
        Text1100005: Label 'La suma de %1 no puede ser mayor que 100 en las cuotas para %2 %3.';
        Text1100006: Label 'Pedido compra efecto nº %1 de %2.';
        Text1100007: Label 'Pedido de servicio efecto nº %1 de %2';
        NeedsManualPmtUpdate: Boolean;
        ManualPmtRevExpNeedsUpdateMsg: Label 'Hay gatos/ingresos manuales recurrentrs.\Pero so se puede aplicar la recurrencia porque la fecha hasta de pagos manuales en la prevision %1 esta en blanco.\Rellene esta fecha para poder crear múltiples líneas.';
        JobsMsg: Label 'Proyectos';
        PrestMsg: Label 'Préstamos';
        RentingMsg: Label 'Préstamos';
        EmplaMsg: Label 'Movs emplazamientos';
        PostedSalesDocumentDescriptionTxt: Label 'Venta regisrtrada %1 - %2 %3', Comment = '%1 = Source Document Type (e.g. Invoice), %2 = Due Date, %3 = Source Name (e.g. Customer Name). Example: Posted Sales Invoice - 04-05-18 The Cannon Group PLC';
        PostedPurchaseDocumentDescriptionTxt: Label 'Compra registrada %1 - %2 %3', Comment = '%1 = Source Document Type (e.g. Invoice), %2 = Due Date, %3 = Source Name (e.g. Vendor Name). Example: Posted Purchase Invoice - 04-05-18 The Cannon Group PLC';
        SalesDocumentDescriptionTxt: Label 'Venta %1 - %2 %3', Comment = '%1 = Source Document Type (e.g. Invoice), %2 = Due Date, %3 = Source Name (e.g. Customer Name). Example: Sales Invoice - 04-05-18 The Cannon Group PLC';
        PurchaseDocumentDescriptionTxt: Label 'Compra %1 - %2 %3', Comment = '%1 = Source Document Type (e.g. Invoice), %2 = Due Date, %3 = Source Name (e.g. Vendor Name). Example: Purchase Invoice - 04-05-18 The Cannon Group PLC';
        ServiceDocumentDescriptionTxt: Label 'Servicio %1 - %2 %3', Comment = '%1 = Source Document Type (e.g. Invoice), %2 = Due Date, %3 = Source Name (e.g. Customer Name). Example: Service Invoice - 04-05-18 The Cannon Group PLC';
        TaxForMsg: Label 'Impuestos desde %1', Comment = '%1 = The description of the source tyoe based on which taxes are calculated.';
        DummyDate: Date;
        TaxLastSourceTableNumProcessed: Integer;
        TaxLastPayableDateProcessed: Date;
        AzureAIForecastDescriptionTxt: Label '%1 previsto en el período que comienza el %2 con una precisión de +/-  %3.', Comment = '%1 =RECEIVABLES or PAYABLES or PAYABLES TAX or RECEIVABLES TAX, %2 = Date; %3 Percentage';
        AzureAIForecastTaxDescriptionTxt: Label 'Impuesto previsto sobre %1 en el período que comienza en %2 con precisión de +/-  %3.', Comment = '%1 =RECEIVABLES or PAYABLES, %2 = Date; %3 Percentage';
        AzureAICorrectionDescriptionTxt: Label 'Corrección vencido a registro %1', Comment = '%1 = SALES ORDERS or PURCHASE ORDERS';
        AzureAICorrectionTaxDescriptionTxt: Label 'Corrección del importe del impuesto adeudado %1', Comment = '%1 = RECEIVABLES or PAYABLES';
        AzureAIOrdersCorrectionDescriptionTxt: Label 'Corrección vencido a %1', Comment = '%1 = SALES or PURCHASE';
        AzureAIOrdersTaxCorrectionDescriptionTxt: Label 'Corrección del monto del impuesto debido a %1', Comment = '%1 = SALES ORDERS or PURCHASE ORDERS';
        XRECEIVABLESTxt: Label 'COBROS', Locked = true;
        XPAYABLESTxt: Label 'PAGOS', Locked = true;
        XPAYABLESCORRECTIONTxt: Label 'Corrección Cobros';
        XRECEIVABLESCORRECTIONTxt: Label 'Corrección Pagos';
        XSALESORDERSTxt: Label 'Pedidos Venta';
        XPURCHORDERSTxt: Label 'Pedidos Compra';
        XTAXPAYABLESTxt: Label 'Impuestos a devolver', Locked = true;
        XTAXRECEIVABLESTxt: Label 'Impuestos a pagar', Locked = true;
        XTAXPAYABLESCORRECTIONTxt: Label 'Impuestos de movimientos de compra';
        XTAXRECEIVABLESCORRECTIONTxt: Label 'Impuestos de movimientos de venta';
        XTAXSALESORDERSTxt: Label 'Impuestos de pedidos de venta';
        XTAXPURCHORDERSTxt: Label 'Impuestos de pedidos de compra';
        DueDateD: Date;
        DueDateF: Date;

    local procedure InsertConditionMet(): Boolean
    begin
        exit(TempCFWorksheetLine."Amount (LCY)" <> 0);
    end;

    local procedure InsertTempCFWorksheetLine(MaxPmtTolerance: Decimal)
    begin
        with TempCFWorksheetLine do begin
            LineNo := LineNo + 100;
            TransferFields(CFWorksheetLine2);
            "Cash Flow Forecast No." := "Cash Flow Forecast"."No.";
            "Line No." := LineNo;
            CalculateCFAmountAndCFDate;
            SetCashFlowDate(TempCFWorksheetLine, "Cash Flow Date");

            if Abs("Amount (LCY)") < Abs(MaxPmtTolerance) then
                "Amount (LCY)" := 0
            else
                "Amount (LCY)" := "Amount (LCY)" - MaxPmtTolerance;

            if InsertConditionMet then
                Insert
        end;
    end;

    local procedure InsertWorksheetLines(var TempCashFlowForecast: Record "Cash Flow Forecast" temporary)
    var
        CFWorksheetLine: Record "Cash Flow Worksheet Line";
        LastCFForecastNo: Code[20];
    begin
        CFWorksheetLine.LockTable();

        CFWorksheetLine.Reset();
        CFWorksheetLine.DeleteAll();

        TempCFWorksheetLine.Reset();
        TempCFWorksheetLine.SetCurrentKey("Cash Flow Forecast No.");
        if TempCFWorksheetLine.FindSet() then
            repeat
                //    CFWorksheetLine.SetRange("Associated Entry No.", TempCFWorksheetLine."Associated Entry No.");
                //if (Not CFWorksheetLine.FindFirst()) or (TempCFWorksheetLine."Associated Entry No." = 0) Then begin
                CFWorksheetLine := TempCFWorksheetLine;
                CFWorksheetLine.Insert(true);

                if LastCFForecastNo <> CFWorksheetLine."Cash Flow Forecast No." then begin
                    TempCashFlowForecast."No." := CFWorksheetLine."Cash Flow Forecast No.";
                    TempCashFlowForecast.Insert();
                    LastCFForecastNo := CFWorksheetLine."Cash Flow Forecast No.";
                end;
            //        end;
            until TempCFWorksheetLine.Next = 0;

        TempCFWorksheetLine.DeleteAll();
    end;

    local procedure DeleteEntries(var TempCashFlowForecast: Record "Cash Flow Forecast" temporary)
    var
        CFForecastEntry: Record "Cash Flow Forecast Entry";
    begin
        TempCashFlowForecast.Reset();
        if TempCashFlowForecast.FindSet() then begin
            CFForecastEntry.LockTable();
            CFForecastEntry.Reset();
            repeat
                CFForecastEntry.SetRange("Cash Flow Forecast No.", TempCashFlowForecast."No.");
                CFForecastEntry.DeleteAll();
            until TempCashFlowForecast.Next = 0;
        end;
        TempCashFlowForecast.DeleteAll();
    end;

    local procedure InsertCFLineForGLAccount(GLAcc: Record "G/L Account")
    begin
        with CFWorksheetLine2 do begin
            Init();
            "Source Type" := "Source Type"::"Liquid Funds";
            "Source No." := GLAcc."No.";
            "Document No." := GLAcc."No.";
            "Cash Flow Account No." := "Cash Flow Account"."No.";
            Description :=
              CopyStr(
                StrSubstNo(Text013, GLAcc.Name, Format(GLAcc.Balance)),
                1, MaxStrLen(Description));
            SetCashFlowDate(CFWorksheetLine2, WorkDate);
            "Amount (LCY)" := GLAcc.Balance;
            "Shortcut Dimension 2 Code" := GLAcc."Global Dimension 2 Code";
            "Shortcut Dimension 1 Code" := GLAcc."Global Dimension 1 Code";
            MoveDefualtDimToJnlLineDim(DATABASE::"G/L Account", GLAcc."No.", "Dimension Set ID");
            InsertTempCFWorksheetLine(0);
        end;
    end;

    local procedure InsertCFLineForCustLedgerEntry()
    var
        MaxPmtTolerance: Decimal;
        Ct: Text;
        Fasctura: Record "Sales Invoice Header";
        Contrato: Record "Sales Header";
        Abono: Record "Sales Cr.Memo Header";
        Text1140019: Label '%1 %2 %3';
        EntryType: Text;
        Text1140014: Label 'Pago clte.';
        Text1140015: Label 'F.cl.';
        Text1140016: Label 'A.cl.';
        Text1140017: Label 'Doc. interés clte.';
        Text1140018: Label 'Recordatorio clte.';
        Text1140100: Label 'Efecto Cliente';
        Documentos: Record "Cartera Doc.";
        Remesas: Record "Bill Group";
        DocuemtosReg: Record "Posted Cartera Doc.";
        RemesasReg: Record "Posted Bill Group";
        Customer: Record Customer;
    begin

        if "Cust. Ledger Entry"."Customer No." <> '' THEN
            Customer.GET("Cust. Ledger Entry"."Customer No.")
        ELSE
            Customer.INIT;
        if "Cust. Ledger Entry"."Due Date" < DueDateD THEN Atrasado := TRUE ELSE Atrasado := FALSE;
        if DueDateF <> 0D THEN
            if "Cust. Ledger Entry"."Due Date" > CALCDATE('181D', WORKDATE) THEN CurrReport.SKIP;
        "Cust. Ledger Entry".CalcFields("Remaining Amt. (LCY)", "Remaining Amount");
        CASE "Cust. Ledger Entry"."Document Type" OF
            "Cust. Ledger Entry"."Document Type"::Payment:
                EntryType := Text1140014;
            "Cust. Ledger Entry"."Document Type"::Invoice:
                EntryType := Text1140015;
            "Cust. Ledger Entry"."Document Type"::"Credit Memo":
                EntryType := Text1140016;
            "Cust. Ledger Entry"."Document Type"::"Finance Charge Memo":
                EntryType := Text1140017;
            "Cust. Ledger Entry"."Document Type"::Reminder:
                EntryType := Text1140018;
            "Cust. Ledger Entry"."Document Type"::Bill:
                EntryType := Text1140100;
            ELSE
                EntryType := '';
        END;
        with CFWorksheetLine2 do begin
            INIT;
            "Source Type" := "Source Type"::Receivables;
            "Shortcut Dimension 2 Code" := "Cust. Ledger Entry"."Global Dimension 2 Code";
            "Shortcut Dimension 1 Code" := "Cust. Ledger Entry"."Global Dimension 1 Code";
            //"Gen. Bus. Posting Group" := Customer."Gen. Bus. Posting Group";
            Anotaciones("Cust. Ledger Entry"."Customer No.", False, Anotación, "Fecha Anotacion");
            "Source No." := "Cust. Ledger Entry"."Customer No.";
            "Document No." := "Cust. Ledger Entry"."Document No.";
            "Document Type" := "Cust. Ledger Entry"."Document Type";
            //"Source Code" := "Cust. Ledger Entry"."Source Code";
            //"Account Type" := CFWorksheetLine2."Account Type"::Customer;
            //"Account Number" := "Cust. Ledger Entry"."Customer No.";
            "Shortcut Dimension 2 Code" := "Cust. Ledger Entry"."Global Dimension 2 Code";
            "Shortcut Dimension 1 Code" := "Cust. Ledger Entry"."Global Dimension 1 Code";
            "Dimension Set ID" := "Cust. Ledger Entry"."Dimension Set ID";
            CFSetup.Get();
            "Cash Flow Account No." := CFSetup."Receivables CF Account No.";
            //"Cash Flow Account No." := LiqSetup."Receivables Liq. Account No.";
            LiqAcc.GET("Cash Flow Account No.");
            Ct := '';
            if Fasctura.GET("Document No.") THEN BEGIN
                if Contrato.GET(Contrato."Document Type"::Order, Fasctura."Nº Contrato") THEN
                    Ct := Contrato."No.";
            END;
            if Abono.GET("Document No.") THEN BEGIN
                if Contrato.GET(Contrato."Document Type"::Order, Abono."Nº Contrato") THEN
                    Ct := Contrato."No.";

            END;
            if CompanyName = 'UATI' then
                CFWorksheetLine2.Description := COPYSTR(STRSUBSTNO(Text1140019, EntryType + ' ' + Ct,
                                                   FORMAT("Cust. Ledger Entry"."Posting Date"), "Shortcut Dimension 2 Code" + '-' +
                                                   Customer.Name), 1, MAXSTRLEN(CFWorksheetLine2.Description))
            ELSE
                CFWorksheetLine2.Description := COPYSTR(STRSUBSTNO(Text1140019, EntryType + ' ' + Ct,
                                                    FORMAT("Cust. Ledger Entry"."Posting Date"),
                                                    Customer.Name), 1, MAXSTRLEN(CFWorksheetLine2.Description));
            "Due Date" := CalcFecha("Cust. Ledger Entry"."Due Date");
            "Fecha Registro" := CalcFechaL("Cust. Ledger Entry"."Due Date");
            "Cash Flow Date" := "Due Date";
            if "Cust. Ledger Entry"."Due Date" <= TODAY THEN BEGIN
                //"Due Date" := TODAY;
                //"Cash Flow Date" := TODAY;
            END;
            if "Cash Flow Forecast"."Consider CF Payment Terms" THEN BEGIN
                if Customer."Cash Flow Payment Terms Code" <> '' THEN BEGIN
                    PaymentTerms.GET(Customer."Cash Flow Payment Terms Code");
                    "Fecha Registro" := CALCDATE(PaymentTerms."Due Date Calculation", "Document Date");
                END;
            END;
            "Document No." := "Cust. Ledger Entry"."Document No.";

            if "Cash Flow Forecast"."Consider Discount" THEN BEGIN
                if "Cust. Ledger Entry"."Currency Code" <> '' THEN
                    "Payment Discount" := ROUND(CurrExchRate.ExchangeAmtFCYToLCYAdjmt("Cust. Ledger Entry"."Posting Date",
                                        "Cust. Ledger Entry"."Currency Code", "Cust. Ledger Entry"."Original Pmt. Disc. Possible",
                                        "Cust. Ledger Entry"."Original Currency Factor"))
                ELSE
                    "Payment Discount" := "Cust. Ledger Entry"."Original Pmt. Disc. Possible";
                "Amount (LCY)" := "Cust. Ledger Entry"."Remaining Amt. (LCY)" - "Payment Discount";
                //"Amount (Currency)" := "Cust. Ledger Entry"."Remaining Amount" - "Cust. Ledger Entry"."Original Pmt. Disc. Possible";
                if "Cust. Ledger Entry"."Pmt. Discount Date" <> 0D THEN BEGIN
                    "Fecha Registro" := "Cust. Ledger Entry"."Pmt. Discount Date";
                    if "Cash Flow Forecast"."Consider Pmt. Disc. Tol. Date" THEN
                        "Fecha Registro" := "Cust. Ledger Entry"."Pmt. Disc. Tolerance Date";
                END;
                if "Cash Flow Forecast"."Consider CF Payment Terms" THEN BEGIN
                    if Customer."Cash Flow Payment Terms Code" <> '' THEN BEGIN
                        PaymentTerms.GET(Customer."Cash Flow Payment Terms Code");
                        "Fecha registro" := CALCDATE(PaymentTerms."Discount Date Calculation", "Document Date");
                        if "Cash Flow Forecast"."Consider Pmt. Disc. Tol. Date" THEN
                            "Fecha Registro" := CALCDATE(GLSetup."Payment Discount Grace Period", "Cash Flow Date");
                        if "Cust. Ledger Entry"."Currency Code" <> '' THEN BEGIN
                            "Payment Discount" := ROUND("Cust. Ledger Entry"."Remaining Amount" * PaymentTerms."Discount %" / 100);
                            //"Amount (Currency)" := "Cust. Ledger Entry"."Remaining Amount" - "Payment Discount";
                        END ELSE BEGIN
                            "Payment Discount" := ROUND("Cust. Ledger Entry"."Remaining Amt. (LCY)" * PaymentTerms."Discount %" / 100);
                            "Amount (LCY)" := "Cust. Ledger Entry"."Remaining Amt. (LCY)" - "Payment Discount";
                        END;
                    END;
                END;
            END ELSE BEGIN
                "Amount (LCY)" := "Cust. Ledger Entry"."Remaining Amt. (LCY)";
                //"Amount (Currency)" := "Cust. Ledger Entry"."Remaining Amount";
            END;

            if "Cash Flow Forecast"."Consider Pmt. Tol. Amount" THEN BEGIN
                "Amount (LCY)" := "Amount (LCY)" - "Cust. Ledger Entry"."Max. Payment Tolerance";
                if "Cust. Ledger Entry"."Currency Code" <> '' Then
                    "Amount (LCY)" := "Amount (LCY)" -
                                        ROUND(CurrExchRate.ExchangeAmtFCYToLCYAdjmt("Cust. Ledger Entry"."Posting Date",
                                        "Cust. Ledger Entry"."Currency Code", "Cust. Ledger Entry"."Max. Payment Tolerance",
                                        "Cust. Ledger Entry"."Original Currency Factor"))
            END;
            "Es Cartera" := FALSE;
            //"Currency Code" := "Cust. Ledger Entry"."Currency Code";
            //
            if "Cust. Ledger Entry".Banco <> '' THEN
                "Cod banco" := "Cust. Ledger Entry".Banco
            ELSE
                "Cod banco" := 'SIN BANCO';
            if Fasctura.GET("Cust. Ledger Entry"."Document No.") THEN BEGIN
                if Fasctura."Nuestra Cuenta" <> '' THEN
                    "Cod banco" := Fasctura."Nuestra Cuenta";
            END;
            if Abono.GET("Cust. Ledger Entry"."Document No.") THEN BEGIN
                if Contrato.GET(Contrato."Document Type"::Order, Abono."Nº Contrato") THEN
                    if Contrato."Nuestra Cuenta" <> '' THEN
                        "Cod banco" := Contrato."Nuestra Cuenta";
            END;
            if "Cust. Ledger Entry".Banco <> '' THEN BEGIN
                "Cod banco" := "Cust. Ledger Entry".Banco;
            END;
            if Documentos.GET(Documentos.Type::Receivable, "Cust. Ledger Entry"."Entry No.") THEN BEGIN
                if Remesas.GET(Documentos."Bill Gr./Pmt. Order No.") THEN BEGIN
                    "Cod banco" := Remesas."Bank Account No.";
                    "Es Cartera" := TRUE;
                END;
            END;
            if DocuemtosReg.GET(DocuemtosReg.Type::Receivable, "Cust. Ledger Entry"."Entry No.") THEN BEGIN
                if RemesasReg.GET(DocuemtosReg."Bill Gr./Pmt. Order No.") THEN BEGIN
                    "Cod banco" := RemesasReg."Bank Account No.";
                    "Es Cartera" := TRUE;
                END;

            END;
            // if ("Cod banco" = '') Or ("Cod Banco" = 'SIN BANCO') then begin
            //     if Customer.Get("Cust. Ledger Entry"."Customer No.") Then
            //         if Customer."Banco transferencia" <> '' Then
            //             "Cod banco" := Customer."Banco transferencia";
            // end;

            // {if LiqAcc."Banco Informes"<>'' THEN
            // "Nombre Banco":=LiqAcc."Banco Informes"
            // ELSE
            // }
            // //

            "Associated Entry No." := "Cust. Ledger Entry"."Entry No.";
            "Payment Method Code" := "Cust. Ledger Entry"."Payment Method Code";
            if "Cust. Ledger Entry"."Due Date" < DueDateD THEN Atrasado := TRUE ELSE Atrasado := FALSE;
            "Nombre Banco" := NBanco("Cod banco");
            SourceType := SourceType::Receivables;
            BuscarLiq(LiqAcc, SourceType, FALSE, Atrasado, "Payment Method Code", "Cod banco", '', "Cust. Ledger Entry".Amount, "Due Date",
            "Cust. Ledger Entry"."Customer No.");

            "Cash Flow Account No." := LiqAcc."No.";

            // {LiqAcc.GET("Cash Flow Account No.");
            // if LiqAcc."Cod banco"<>'' THEN
            // if LiqAcc."Cod banco"<>"Cod banco" THEN Amount:=0;
            // if LiqAcc."Banco Informes"<>'' THEN BEGIN
            // if LiqAcc."Banco Informes"<>NBanco("Cod banco") THEN Amount:=0;
            // END;
            // if ("Cust. Ledger Entry"."Document Type"="Cust. Ledger Entry"."Document Type"::Payment)
            // AND ("Cust. Ledger Entry"."Nº Factura Borrador"<>'') THEN Amount:=0;       

            // }
            //if LiqAcc."Solo Atrasados" THEN
            if ExisteMov("Associated Entry No.") THEN "Amount (LCY)" := 0;
            "Due Date" := "Cust. Ledger Entry"."Due Date";
            "Fecha Registro" := CalcFechaL("Cust. Ledger Entry"."Due Date");
            "Cash Flow Date" := "Cust. Ledger Entry"."Due Date";
            //
            if ("Amount (LCY)" <> 0) AND (ComprobarCliente("Cust. Ledger Entry"."Customer No.", LiqAcc."Cód. Cliente")) THEN BEGIN
                if InsertLiqLine() THEN;
                // Transfer Dimensions
                // LedgEntryDim.RESET;
                // LedgEntryDim.SETRANGE("Table ID",DATABASE::"Cust. Ledger Entry");
                // LedgEntryDim.SETRANGE("Entry No.","Cust. Ledger Entry"."Entry No.");
                // DimMgt.MoveLedgEntryDimToJnlLineDimLi(LedgEntryDim,JnlLineDim,DATABASE::"Liq. Journal Line",LiqLine."Journal Template Name",
                //                             LiqLine."Journal Batch Name",LiqLine."Line No.",0);
            end;
        end;
    end;

    local procedure InsertCFLineForCartera()
    var
        MaxPmtTolerance: Decimal;
        Ct: Text;
        Fasctura: Record "Sales Invoice Header";
        Contrato: Record "Sales Header";
        Abono: Record "Sales Cr.Memo Header";
        Text1140019: Label '%1 %2 %3';
        EntryType: Text;
        Text1140014: Label 'Pago clte.';
        Text1140015: Label 'F.cl.';
        Text1140016: Label 'A.cl.';
        Text1140017: Label 'Doc. interés clte.';
        Text1140018: Label 'Recordatorio clte.';
        Text1140100: Label 'Efecto Cliente';
        Documentos: Record "Cartera Doc.";
        Remesas: Record "Bill Group";
        DocuemtosReg: Record "Posted Cartera Doc.";
        RemesasReg: Record "Posted Bill Group";
        Customer: Record Customer;
    begin


        if "Cartera Doc."."Account No." <> '' THEN
            Customer.GET("Cartera Doc."."Account No.")
        ELSE
            Customer.INIT;

        CASE "Cartera Doc."."Document Type" OF
            "Cartera Doc."."Document Type"::Invoice:
                EntryType := Text1140015;
            "Cartera Doc."."Document Type"::Bill:
                EntryType := Text1140100;
            ELSE
                EntryType := '';
        END;

        if DueDateF <> 0D THEN
            if "Cartera Doc."."Due Date" > CALCDATE('181D', WORKDATE) THEN CurrReport.SKIP;

        //if DueDateF<>0D THEN
        //if "Due Date">DueDateF THEN CurrReport.SKIP;

        //if DueDateD<>0D THEN
        //if "Due Date"<DueDateD THEN CurrReport.SKIP;
        if "Cartera Doc."."Due Date" < DueDateD THEN Atrasado := TRUE ELSE Atrasado := FALSE;
        with CFWorksheetLine2 do begin


            INIT;
            "Source Type" := "Source Type"::"Cartera Clientes";// ::Receivables;
            "Shortcut Dimension 2 Code" := "Cartera Doc."."Global Dimension 2 Code";
            "Shortcut Dimension 1 Code" := "Cartera Doc."."Global Dimension 1 Code";
            //"Gen. Bus. Posting Group" := Customer."Gen. Bus. Posting Group";
            Anotaciones("Cartera Doc."."Account No.", False, Anotación, "Fecha Anotacion");
            //"Reason Code" := '';
            //CFWorksheetLine2. := 'CARTERA';
            //"Account Type" := LiqLine2."Account Type"::Customer;
            "Source No." := "Cartera Doc."."Account No.";
            case "Cartera Doc."."Document Type" of
                "Cartera Doc."."Document Type"::Invoice:
                    "Document Type" := "Document Type"::Invoice;
                "Cartera Doc."."Document Type"::Bill:
                    "Document Type" := "Document Type"::Bill;
            End;
            CFSetup.Get();
            "Cash Flow Account No." := CFSetup."Receivables CF Account No.";
            LiqAcc.GET("Cash Flow Account No.");
            if CompanyName = 'UATI' then
                Description := COPYSTR(STRSUBSTNO(Text1140019, EntryType + ' ' + Ct,
                                                   FORMAT("Cartera Doc."."Posting Date"), "Shortcut Dimension 2 Code" + '-' +
                                                   Customer.Name), 1, MAXSTRLEN(Description))
            ELSE
                Description := COPYSTR(STRSUBSTNO(Text1140019, EntryType,
                                                    FORMAT("Cartera Doc."."Due Date"),
                                                    Customer.Name), 1, MAXSTRLEN(Description));
            CFWorksheetLine2."Due Date" := CalcFecha("Cartera Doc."."Due Date");
            "Cash Flow Date" := CalcFecha("Cartera Doc."."Due Date");
            "Fecha Registro" := CalcFechaL("Cartera Doc."."Due Date");

            if "Cash Flow Forecast"."Consider CF Payment Terms" THEN BEGIN
                if Customer."Cash Flow Payment Terms Code" <> '' THEN BEGIN
                    PaymentTerms.GET(Customer."Cash Flow Payment Terms Code");
                    "Fecha Registro" := CALCDATE(PaymentTerms."Due Date Calculation",
                    "Cartera Doc."."Posting Date");
                END;
            END;
            "Document No." := "Cartera Doc."."Document No.";

            if "Cash Flow Forecast"."Consider Discount" THEN BEGIN
                // if "Currency Code" <> '' THEN
                // "Payment Discount" := ROUND(Conversion.ExchangeAmtFCYToLCYAdjmt("Cartera Doc."."Posting Date",
                //                     "Currency Code",0,
                //                     1))
                // ELSE
                "Payment Discount" := 0;
                "Amount (LCY)" := "Cartera Doc."."Remaining Amt. (LCY)" - "Payment Discount";
                //"Amount (Currency)" := "Remaining Amount" - 0;
                if "Cash Flow Forecast".Comment THEN BEGIN
                    if Customer."Cash Flow Payment Terms Code" <> '' THEN BEGIN
                        PaymentTerms.GET(Customer."Cash Flow Payment Terms Code");
                        "Fecha Registro" := CALCDATE(PaymentTerms."Discount Date Calculation", "Cartera Doc."."Posting Date");
                        if "Cash Flow Forecast"."Consider Pmt. Disc. Tol. Date" THEN
                            "Fecha Registro" := CALCDATE(GLSetup."Payment Discount Grace Period", "Cash Flow Date");
                        // if "Currency Code" <> '' THEN BEGIN
                        // "Payment Discount" := ROUND("Remaining Amount" * PaymentTerms."Discount %" / 100);
                        // "Amount (Currency)" := "Remaining Amount" - "Payment Discount";
                        // END ELSE BEGIN
                        "Payment Discount" := ROUND("Cartera Doc."."Remaining Amt. (LCY)" * PaymentTerms."Discount %" / 100);
                        "Amount (LCY)" := "Cartera Doc."."Remaining Amt. (LCY)" - "Payment Discount";
                        //END;
                    END;
                END;
            END ELSE BEGIN
                "Amount (LCY)" := "Cartera Doc."."Remaining Amt. (LCY)";
                //"Amount (Currency)" := "Remaining Amount";
            END;

            if "Cash Flow Forecast"."Consider Pmt. Tol. Amount" THEN BEGIN
                "Amount (LCY)" := "Amount (LCY)" - 0;
                //"Amount (Currency)" := "Amount (Currency)" -
                //                  ROUND(Conversion.ExchangeAmtFCYToLCYAdjmt("Posting Date",
                //                "Currency Code",0,
                //              0))
            END;

            //"Currency Code" := "Cartera Doc."."Currency Code";
            //
            "Es Cartera" := TRUE;
            "Cod banco" := "Cartera Doc.".Banco;//'SIN BANCO';
            if "Cod banco" = '' THEN
                "Cod banco" := 'SIN BANCO';

            if Remesas.GET("Cartera Doc."."Bill Gr./Pmt. Order No.") THEN BEGIN
                "Cod banco" := Remesas."Bank Account No.";
            END;
            "Associated Entry No." := "Cartera Doc."."Entry No.";
            "Payment Method Code" := "Cartera Doc."."Payment Method Code";
            if "Cartera Doc."."Due Date" < DueDateD THEN Atrasado := TRUE ELSE Atrasado := FALSE;
            // if ("Cod banco" = '') Or ("Cod Banco" = 'SIN BANCO') then begin
            //     if Customer.Get("Cartera Doc."."Account No.") Then
            //         if Customer."Banco transferencia" <> '' Then
            //             "Cod banco" := Customer."Banco transferencia";
            // end;
            if "Cod banco" <> 'SIN BANCO' THEN
                "Nombre Banco" := NBanco("Cod banco");


            // Buscamos Con Todos los datos
            SourceType := SourceType::"Cartera Clientes"; //Receivables;
            BuscarLiq(LiqAcc, SourceType, TRUE, Atrasado, "Payment Method Code", "Cod banco", '', "Amount (LCY)", "Due Date", "Cartera Doc."."Account No.");

            if LiqAcc."Banco Informes" <> '' THEN
                "Nombre Banco" := LiqAcc."Banco Informes"
            ELSE
                "Nombre Banco" := NBanco("Cod banco");
            "Cash Flow Account No." := LiqAcc."No.";
            // {if LiqAcc."Cod banco"<>'' THEN
            // if LiqAcc."Cod banco"<>"Cod banco" THEN Amount:=0;
            // if LiqAcc."Banco Informes"<>'' THEN BEGIN
            // if Remesas.GET("Bill Gr./Pmt. Order No.") THEN BEGIN
            // if NBanco(Remesas."Bank Account No.")<>LiqAcc."Banco Informes" THEN Amount:=0;
            // END ELSE
            // if LiqAcc."Banco Informes"<>NBanco("Cod banco") THEN Amount:=0;
            // END;  }
            if ExisteMov("Associated Entry No.") THEN "Amount (LCY)" := 0;
            //if LiqAcc."Solo Atrasados" THEN
            "Due Date" := "Cartera Doc."."Due Date";
            "Cash Flow Date" := "Cartera Doc."."Due Date";
            if ("Amount (LCY)" <> 0) AND (ComprobarCliente("Cartera Doc."."Account No.", LiqAcc."Cód. Cliente")) THEN BEGIN
                InsertLiqLine();
                // Transfer Dimensions
                // LedgEntryDim.RESET;
                // LedgEntryDim.SETRANGE("Table ID",DATABASE::"Cust. Ledger Entry");
                // LedgEntryDim.SETRANGE("Entry No.","Entry No.");
                // DimMgt.MoveLedgEntryDimToJnlLineDimLi(LedgEntryDim,JnlLineDim,DATABASE::"Liq. Journal Line",LiqLine."Journal Template Name",
                //                             LiqLine."Journal Batch Name",LiqLine."Line No.",0);
            END;
        end;

    end;

    local procedure InsertCFLineForPostedCartera()
    var
        MaxPmtTolerance: Decimal;
        Ct: Text;
        Fasctura: Record "Sales Invoice Header";
        Contrato: Record "Sales Header";
        Abono: Record "Sales Cr.Memo Header";
        Text1140019: Label '%1 %2 %3';
        EntryType: Text;
        Text1140014: Label 'Pago clte.';
        Text1140015: Label 'F.cl.';
        Text1140016: Label 'A.cl.';
        Text1140017: Label 'Doc. interés clte.';
        Text1140018: Label 'Recordatorio clte.';
        Text1140100: Label 'Efecto Cliente';
        Documentos: Record "Posted Cartera Doc.";
        Remesas: Record "Posted Bill Group";
        DocuemtosReg: Record "Posted Cartera Doc.";
        RemesasReg: Record "Posted Bill Group";
        Customer: Record Customer;
    begin


        if "Posted Cartera Doc."."Account No." <> '' THEN
            Customer.GET("Posted Cartera Doc."."Account No.")
        ELSE
            Customer.INIT;

        CASE "Posted Cartera Doc."."Document Type" OF
            "Posted Cartera Doc."."Document Type"::Invoice:
                EntryType := Text1140015;
            "Posted Cartera Doc."."Document Type"::Bill:
                EntryType := Text1140100;
            ELSE
                EntryType := '';
        END;

        if DueDateF <> 0D THEN
            if "Posted Cartera Doc."."Due Date" > CALCDATE('181D', WORKDATE) THEN CurrReport.SKIP;

        //if DueDateF<>0D THEN
        //if "Due Date">DueDateF THEN CurrReport.SKIP;

        //if DueDateD<>0D THEN
        //if "Due Date"<DueDateD THEN CurrReport.SKIP;
        if "Posted Cartera Doc."."Due Date" < DueDateD THEN Atrasado := TRUE ELSE Atrasado := FALSE;
        with CFWorksheetLine2 do begin
            // Init();
            // "Source Type" := "Source Type"::Receivables;
            // "Source No." := "Cust. Ledger Entry"."Document No.";
            // "Document Type" := "Cust. Ledger Entry"."Document Type";
            // "Document Date" := "Cust. Ledger Entry"."Document Date";
            // "Shortcut Dimension 2 Code" := "Cust. Ledger Entry"."Global Dimension 2 Code";
            // "Shortcut Dimension 1 Code" := "Cust. Ledger Entry"."Global Dimension 1 Code";
            // "Dimension Set ID" := "Cust. Ledger Entry"."Dimension Set ID";
            // "Cash Flow Account No." := CFSetup."Receivables CF Account No.";
            // Description := CopyStr(
            //     StrSubstNo(PostedSalesDocumentDescriptionTxt,
            //       Format("Document Type"),
            //       Format("Cust. Ledger Entry"."Due Date"),
            //       Customer.Name),
            //     1, MaxStrLen(Description));
            // "Document No." := "Cust. Ledger Entry"."Document No.";
            // SetCashFlowDate(CFWorksheetLine2, "Cust. Ledger Entry"."Due Date");
            // "Amount (LCY)" := "Cust. Ledger Entry"."Remaining Amt. (LCY)";
            // "Pmt. Discount Date" := "Cust. Ledger Entry"."Pmt. Discount Date";
            // "Pmt. Disc. Tolerance Date" := "Cust. Ledger Entry"."Pmt. Disc. Tolerance Date";

            // if "Cust. Ledger Entry"."Currency Code" <> '' then
            //     Currency.Get("Cust. Ledger Entry"."Currency Code")
            // else
            //     Currency.InitRoundingPrecision;

            // "Payment Discount" := Round("Cust. Ledger Entry"."Remaining Pmt. Disc. Possible" /
            //     "Cust. Ledger Entry"."Adjusted Currency Factor", Currency."Amount Rounding Precision");

            // if "Cash Flow Forecast"."Consider Pmt. Tol. Amount" then
            //     MaxPmtTolerance := Round("Cust. Ledger Entry"."Max. Payment Tolerance" /
            //         "Cust. Ledger Entry"."Adjusted Currency Factor", Currency."Amount Rounding Precision")
            // else
            //     MaxPmtTolerance := 0;

            // if "Cash Flow Forecast"."Consider CF Payment Terms" and (Customer."Cash Flow Payment Terms Code" <> '') then
            //     "Payment Terms Code" := Customer."Cash Flow Payment Terms Code"
            // else
            //     "Payment Terms Code" := '';

            // InsertTempCFWorksheetLine(MaxPmtTolerance);
            //ASC

            INIT;
            "Source Type" := "Source Type"::"Cartera Clientes Registrada";// Receivables;
            "Shortcut Dimension 2 Code" := "Posted Cartera Doc."."Global Dimension 2 Code";
            "Shortcut Dimension 1 Code" := "Posted Cartera Doc."."Global Dimension 1 Code";
            //"Gen. Bus. Posting Group" := Customer."Gen. Bus. Posting Group";
            Anotaciones("Posted Cartera Doc."."Account No.", False, Anotación, "Fecha Anotacion");
            //"Reason Code" := '';
            //CFWorksheetLine2. := 'CARTERA';
            //"Account Type" := LiqLine2."Account Type"::Customer;
            "Source No." := "Posted Cartera Doc."."Account No.";
            case "Posted Cartera Doc."."Document Type" of
                "Posted Cartera Doc."."Document Type"::Invoice:
                    "Document Type" := "Document Type"::Invoice;
                "Posted Cartera Doc."."Document Type"::Bill:
                    "Document Type" := "Document Type"::Bill;
            End;
            CFSetup.Get();
            "Cash Flow Account No." := CFSetup."Receivables CF Account No.";
            LiqAcc.GET("Cash Flow Account No.");
            if CompanyName = 'UATI' then
                Description := COPYSTR(STRSUBSTNO(Text1140019, EntryType + ' ' + Ct,
                                                   FORMAT("Posted Cartera Doc."."Posting Date"), "Shortcut Dimension 2 Code" + '-' +
                                                   Customer.Name), 1, MAXSTRLEN(Description))
            ELSE
                Description := COPYSTR(STRSUBSTNO(Text1140019, EntryType,
                                                    FORMAT("Posted Cartera Doc."."Due Date"),
                                                    Customer.Name), 1, MAXSTRLEN(Description));
            "Due Date" := CalcFecha("Posted Cartera Doc."."Due Date");
            "Cash Flow Date" := CalcFecha("Posted Cartera Doc."."Due Date");
            "Fecha Registro" := CalcFechaL("Posted Cartera Doc."."Due Date");

            if "Cash Flow Forecast"."Consider CF Payment Terms" THEN BEGIN
                if Customer."Cash Flow Payment Terms Code" <> '' THEN BEGIN
                    PaymentTerms.GET(Customer."Cash Flow Payment Terms Code");
                    "Fecha Registro" := CALCDATE(PaymentTerms."Due Date Calculation",
                    "Posted Cartera Doc."."Posting Date");
                END;
            END;
            "Document No." := "Posted Cartera Doc."."Document No.";

            if "Cash Flow Forecast"."Consider Discount" THEN BEGIN
                // if "Currency Code" <> '' THEN
                // "Payment Discount" := ROUND(Conversion.ExchangeAmtFCYToLCYAdjmt("Posted Cartera Doc."."Posting Date",
                //                     "Currency Code",0,
                //                     1))
                // ELSE
                "Payment Discount" := 0;
                "Amount (LCY)" := "Posted Cartera Doc."."Remaining Amt. (LCY)" - "Payment Discount";
                //"Amount (Currency)" := "Remaining Amount" - 0;
                if "Cash Flow Forecast".Comment THEN BEGIN
                    if Customer."Cash Flow Payment Terms Code" <> '' THEN BEGIN
                        PaymentTerms.GET(Customer."Cash Flow Payment Terms Code");
                        "Fecha Registro" := CALCDATE(PaymentTerms."Discount Date Calculation", "Posted Cartera Doc."."Posting Date");
                        if "Cash Flow Forecast"."Consider Pmt. Disc. Tol. Date" THEN
                            "Fecha Registro" := CALCDATE(GLSetup."Payment Discount Grace Period", "Cash Flow Date");
                        // if "Currency Code" <> '' THEN BEGIN
                        // "Payment Discount" := ROUND("Remaining Amount" * PaymentTerms."Discount %" / 100);
                        // "Amount (Currency)" := "Remaining Amount" - "Payment Discount";
                        // END ELSE BEGIN
                        "Payment Discount" := ROUND("Posted Cartera Doc."."Remaining Amt. (LCY)" * PaymentTerms."Discount %" / 100);
                        "Amount (LCY)" := "Posted Cartera Doc."."Remaining Amt. (LCY)" - "Payment Discount";
                        //END;
                    END;
                END;
            END ELSE BEGIN
                "Amount (LCY)" := "Posted Cartera Doc."."Remaining Amt. (LCY)";
                //"Amount (Currency)" := "Remaining Amount";
            END;

            if "Cash Flow Forecast"."Consider Pmt. Tol. Amount" THEN BEGIN
                "Amount (LCY)" := "Amount (LCY)" - 0;
                //"Amount (Currency)" := "Amount (Currency)" -
                //                  ROUND(Conversion.ExchangeAmtFCYToLCYAdjmt("Posting Date",
                //                "Currency Code",0,
                //              0))
            END;

            //"Currency Code" := "Posted Cartera Doc."."Currency Code";
            //
            "Es Cartera" := TRUE;
            "Cod banco" := "Posted Cartera Doc.".Banco;//'SIN BANCO';
            if "Cod banco" = '' THEN
                "Cod banco" := 'SIN BANCO';

            if Remesas.GET("Posted Cartera Doc."."Bill Gr./Pmt. Order No.") THEN BEGIN
                "Cod banco" := Remesas."Bank Account No.";
            END;
            "Associated Entry No." := "Posted Cartera Doc."."Entry No.";
            "Payment Method Code" := "Posted Cartera Doc."."Payment Method Code";
            if "Posted Cartera Doc."."Due Date" < DueDateD THEN Atrasado := TRUE ELSE Atrasado := FALSE;
            if ("Cod banco" = '') Or ("Cod Banco" = 'SIN BANCO') then begin
                // if Customer.Get("Posted Cartera Doc."."Account No.") then
                //     if Customer."Banco transferencia" <> '' Then
                //         "Cod banco" := Customer."Banco transferencia";
            end;
            if "Cod banco" <> 'SIN BANCO' THEN
                "Nombre Banco" := NBanco("Cod banco");
            // Buscamos Con Todos los datos
            SourceType := SourceType::"Cartera Clientes";// Receivables;
            BuscarLiq(LiqAcc, SourceType, TRUE, Atrasado, "Payment Method Code", "Cod banco", '', "Amount (LCY)", "Due Date", "Posted Cartera Doc."."Account No.");

            if LiqAcc."Banco Informes" <> '' THEN
                "Nombre Banco" := LiqAcc."Banco Informes"
            ELSE
                "Nombre Banco" := NBanco("Cod banco");
            "Cash Flow Account No." := LiqAcc."No.";
            // {if LiqAcc."Cod banco"<>'' THEN
            // if LiqAcc."Cod banco"<>"Cod banco" THEN Amount:=0;
            // if LiqAcc."Banco Informes"<>'' THEN BEGIN
            // if Remesas.GET("Bill Gr./Pmt. Order No.") THEN BEGIN
            // if NBanco(Remesas."Bank Account No.")<>LiqAcc."Banco Informes" THEN Amount:=0;
            // END ELSE
            // if LiqAcc."Banco Informes"<>NBanco("Cod banco") THEN Amount:=0;
            // END;  }
            if ExisteMov("Associated Entry No.") THEN "Amount (LCY)" := 0;
            //if LiqAcc."Solo Atrasados" THEN
            "Due Date" := "Posted Cartera Doc."."Due Date";
            "Cash Flow Date" := "Posted Cartera Doc."."Due Date";

            if ("Amount (LCY)" <> 0) AND (ComprobarCliente("Posted Cartera Doc."."Account No.", LiqAcc."Cód. Cliente")) THEN BEGIN
                InsertLiqLine();
                // Transfer Dimensions
                // LedgEntryDim.RESET;
                // LedgEntryDim.SETRANGE("Table ID",DATABASE::"Cust. Ledger Entry");
                // LedgEntryDim.SETRANGE("Entry No.","Entry No.");
                // DimMgt.MoveLedgEntryDimToJnlLineDimLi(LedgEntryDim,JnlLineDim,DATABASE::"Liq. Journal Line",LiqLine."Journal Template Name",
                //                             LiqLine."Journal Batch Name",LiqLine."Line No.",0);
            END;
        end;

    end;

    local procedure InsertPFLineForCartera()
    var
        MaxPmtTolerance: Decimal;
        Ct: Text;
        Fasctura: Record "Sales Invoice Header";
        Contrato: Record "Sales Header";
        Abono: Record "Sales Cr.Memo Header";
        Text1140019: Label '%1 %2 %3';
        EntryType: Text;
        Text1140020: Label 'Pago prov.';
        Text1140021: Label 'Factura prov.';
        Text1140022: Label 'Abono prov.';
        Text1140023: Label 'Doc. interés prov.';
        Text1140024: Label 'Recordatorio prov.';
        Text1140101: Label 'Efecto Proveedor';
        Documentos: Record "Cartera Doc.";
        Remesas: Record "Payment Order";
        DocuemtosReg: Record "Posted Cartera Doc.";
        RemesasReg: Record "Posted Payment Order";
        Vendor: Record Vendor;
        VendorLedgEntry: Record "Vendor Ledger Entry";


    begin



        if "Vendor Cartera Doc."."Account No." <> '' THEN
            Vendor.GET("Vendor Cartera Doc."."Account No.")
        ELSE
            Vendor.INIT;

        CASE "Vendor Cartera Doc."."Document Type" OF
            "Vendor Cartera Doc."."Document Type"::Bill:
                EntryType := Text1140101;
            ELSE
                EntryType := '';
        END;

        if DueDateF <> 0D THEN
            if "Vendor Cartera Doc."."Due Date" > CALCDATE('181D', WORKDATE) THEN CurrReport.SKIP;

        //if DueDateF<>0D THEN
        //if "Due Date">DueDateF THEN CurrReport.SKIP;

        //if DueDateD<>0D THEN
        //if "Due Date"<DueDateD THEN CurrReport.SKIP;
        if "Vendor Cartera Doc."."Due Date" < DueDateD THEN Atrasado := TRUE ELSE Atrasado := FALSE;
        with CFWorksheetLine2 do begin
            // Init();
            // "Source Type" := "Source Type"::Receivables;
            // "Source No." := "Cust. Ledger Entry"."Document No.";
            // "Document Type" := "Cust. Ledger Entry"."Document Type";
            // "Document Date" := "Cust. Ledger Entry"."Document Date";
            // "Shortcut Dimension 2 Code" := "Cust. Ledger Entry"."Global Dimension 2 Code";
            // "Shortcut Dimension 1 Code" := "Cust. Ledger Entry"."Global Dimension 1 Code";
            // "Dimension Set ID" := "Cust. Ledger Entry"."Dimension Set ID";
            // "Cash Flow Account No." := CFSetup."Receivables CF Account No.";
            // Description := CopyStr(
            //     StrSubstNo(PostedSalesDocumentDescriptionTxt,
            //       Format("Document Type"),
            //       Format("Cust. Ledger Entry"."Due Date"),
            //       Customer.Name),
            //     1, MaxStrLen(Description));
            // "Document No." := "Cust. Ledger Entry"."Document No.";
            // SetCashFlowDate(CFWorksheetLine2, "Cust. Ledger Entry"."Due Date");
            // "Amount (LCY)" := "Cust. Ledger Entry"."Remaining Amt. (LCY)";
            // "Pmt. Discount Date" := "Cust. Ledger Entry"."Pmt. Discount Date";
            // "Pmt. Disc. Tolerance Date" := "Cust. Ledger Entry"."Pmt. Disc. Tolerance Date";

            // if "Cust. Ledger Entry"."Currency Code" <> '' then
            //     Currency.Get("Cust. Ledger Entry"."Currency Code")
            // else
            //     Currency.InitRoundingPrecision;

            // "Payment Discount" := Round("Cust. Ledger Entry"."Remaining Pmt. Disc. Possible" /
            //     "Cust. Ledger Entry"."Adjusted Currency Factor", Currency."Amount Rounding Precision");

            // if "Cash Flow Forecast"."Consider Pmt. Tol. Amount" then
            //     MaxPmtTolerance := Round("Cust. Ledger Entry"."Max. Payment Tolerance" /
            //         "Cust. Ledger Entry"."Adjusted Currency Factor", Currency."Amount Rounding Precision")
            // else
            //     MaxPmtTolerance := 0;

            // if "Cash Flow Forecast"."Consider CF Payment Terms" and (Customer."Cash Flow Payment Terms Code" <> '') then
            //     "Payment Terms Code" := Customer."Cash Flow Payment Terms Code"
            // else
            //     "Payment Terms Code" := '';

            // InsertTempCFWorksheetLine(MaxPmtTolerance);
            //ASC

            INIT;
            "Source Type" := "Source Type"::"Cartera Proveedores";//Payables;
            "Shortcut Dimension 2 Code" := "Vendor Cartera Doc."."Global Dimension 2 Code";
            "Shortcut Dimension 1 Code" := "Vendor Cartera Doc."."Global Dimension 1 Code";
            //"Gen. Bus. Posting Group" := Customer."Gen. Bus. Posting Group";
            Anotaciones("Vendor Cartera Doc."."Account No.", true, Anotación, "Fecha Anotacion");
            //"Reason Code" := '';
            //CFWorksheetLine2. := 'CARTERA';
            //"Account Type" := LiqLine2."Account Type"::Customer;
            "Source No." := "Vendor Cartera Doc."."Account No.";
            case "Vendor Cartera Doc."."Document Type" of
                "Vendor Cartera Doc."."Document Type"::Invoice:
                    "Document Type" := "Document Type"::Invoice;
                "Vendor Cartera Doc."."Document Type"::Bill:
                    "Document Type" := "Document Type"::Bill;
            End;
            CFSetup.Get();
            "Cash Flow Account No." := CFSetup."Payables CF Account No.";
            LiqAcc.GET("Cash Flow Account No.");
            if CompanyName = 'UATI' then
                Description := COPYSTR(STRSUBSTNO(Text1140019, EntryType + ' ' + Ct,
                                                   FORMAT("Vendor Cartera Doc."."Posting Date"), "Shortcut Dimension 2 Code" + '-' +
                                                   Vendor.Name), 1, MAXSTRLEN(Description))
            ELSE
                Description := COPYSTR(STRSUBSTNO(Text1140019, EntryType,
                                                    FORMAT("Vendor Cartera Doc."."Due Date"),
                                                    Vendor.Name), 1, MAXSTRLEN(Description));
            "Due Date" := CalcFecha("Vendor Cartera Doc."."Due Date");
            "Fecha Registro" := CalcFechaL("Vendor Cartera Doc."."Due Date");
            "Cash Flow Date" := "Due Date";
            if "Cash Flow Forecast"."Consider CF Payment Terms" THEN BEGIN
                if Vendor."Cash Flow Payment Terms Code" <> '' THEN BEGIN
                    PaymentTerms.GET(Vendor."Cash Flow Payment Terms Code");
                    "Fecha registro" := CALCDATE(PaymentTerms."Due Date Calculation",
                    "Vendor Cartera Doc."."Posting Date");
                END;
            END;
            "Document No." := "Vendor Cartera Doc."."Document No.";

            if "Cash Flow Forecast"."Consider Discount" THEN BEGIN
                // if "Currency Code" <> '' THEN
                // "Payment Discount" := ROUND(Conversion.ExchangeAmtFCYToLCYAdjmt("Cartera Doc."."Posting Date",
                //                     "Currency Code",0,
                //                     1))
                // ELSE
                "Payment Discount" := 0;
                "Amount (LCY)" := "Vendor Cartera Doc."."Remaining Amt. (LCY)" - "Payment Discount";
                //"Amount (Currency)" := "Remaining Amount" - 0;
                if "Cash Flow Forecast".Comment THEN BEGIN
                    if Vendor."Cash Flow Payment Terms Code" <> '' THEN BEGIN
                        PaymentTerms.GET(Vendor."Cash Flow Payment Terms Code");
                        "Fecha Registro" := CALCDATE(PaymentTerms."Discount Date Calculation", "Cartera Doc."."Posting Date");
                        if "Cash Flow Forecast"."Consider Pmt. Disc. Tol. Date" THEN
                            "Fecha Registro" := CALCDATE(GLSetup."Payment Discount Grace Period", "Cash Flow Date");
                        // if "Currency Code" <> '' THEN BEGIN
                        // "Payment Discount" := ROUND("Remaining Amount" * PaymentTerms."Discount %" / 100);
                        // "Amount (Currency)" := "Remaining Amount" - "Payment Discount";
                        // END ELSE BEGIN
                        "Payment Discount" := ROUND("Cartera Doc."."Remaining Amt. (LCY)" * PaymentTerms."Discount %" / 100);
                        "Amount (LCY)" := -"Vendor Cartera Doc."."Remaining Amt. (LCY)" + "Payment Discount";
                        //END;
                    END;
                END;
            END ELSE BEGIN
                "Amount (LCY)" := -"Vendor Cartera Doc."."Remaining Amt. (LCY)";
                //"Amount (Currency)" := "Remaining Amount";
            END;

            if "Cash Flow Forecast"."Consider Pmt. Tol. Amount" THEN BEGIN
                "Amount (LCY)" := "Amount (LCY)" - 0;
                //"Amount (Currency)" := "Amount (Currency)" -
                //                  ROUND(Conversion.ExchangeAmtFCYToLCYAdjmt("Posting Date",
                //                "Currency Code",0,
                //              0))
            END;

            //"Currency Code" := "Cartera Doc."."Currency Code";
            //
            "Es Cartera" := TRUE;
            "Cod banco" := "Vendor Cartera Doc.".Banco;//'SIN BANCO';
            if "Cod banco" = '' Then begin
                // si el cód. banco esta vacío lo cogemos de vendorledgerentry
                VendorLedgEntry.RESET;
                if VendorLedgEntry.get("Vendor Cartera Doc."."Entry No.") Then
                    "Cod banco" := VendorLedgEntry.Banco;
                if "Cod banco" = '' Then
                    if Vendor.Get("Vendor Cartera Doc."."Account No.") Then
                        "Cod banco" := Vendor.Banco;
            end;
            if "Cod banco" = '' THEN
                "Cod banco" := 'SIN BANCO';

            if Remesas.GET("Vendor Cartera Doc."."Bill Gr./Pmt. Order No.") THEN BEGIN
                if Remesas."Bank Account No." <> '' then
                    "Cod banco" := Remesas."Bank Account No.";
            END;
            "Associated Entry No." := "Vendor Cartera Doc."."Entry No.";
            "Payment Method Code" := "Vendor Cartera Doc."."Payment Method Code";
            if "Vendor Cartera Doc."."Due Date" < DueDateD THEN Atrasado := TRUE ELSE Atrasado := FALSE;
            if "Cod banco" <> 'SIN BANCO' THEN
                "Nombre Banco" := NBanco("Cod banco");
            // Buscamos Con Todos los datos
            SourceType := SourceType::"Cartera Proveedores";//Payables;
            BuscarLiq(LiqAcc, SourceType, TRUE, Atrasado, "Payment Method Code", "Cod banco", "Vendor Cartera Doc."."Account No.", "Amount (LCY)", "Due Date", '');

            if LiqAcc."Banco Informes" <> '' THEN
                "Nombre Banco" := LiqAcc."Banco Informes"
            ELSE
                "Nombre Banco" := NBanco("Cod banco");
            "Cash Flow Account No." := LiqAcc."No.";
            // {if LiqAcc."Cod banco"<>'' THEN
            // if LiqAcc."Cod banco"<>"Cod banco" THEN Amount:=0;
            // if LiqAcc."Banco Informes"<>'' THEN BEGIN
            // if Remesas.GET("Bill Gr./Pmt. Order No.") THEN BEGIN
            // if NBanco(Remesas."Bank Account No.")<>LiqAcc."Banco Informes" THEN Amount:=0;
            // END ELSE
            // if LiqAcc."Banco Informes"<>NBanco("Cod banco") THEN Amount:=0;
            // END;  }
            if ExisteMov("Associated Entry No.") THEN "Amount (LCY)" := 0;
            //if LiqAcc."Solo Atrasados" THEN
            "Due Date" := "Vendor Cartera Doc."."Due Date";
            "Cash Flow Date" := "Due Date";
            if ("Amount (LCY)" <> 0) AND (ComprobarProveedor("Vendor Cartera Doc."."Account No.", LiqAcc."Cód. Proveedor")) THEN BEGIN
                InsertLiqLine();
                // Transfer Dimensions
                // LedgEntryDim.RESET;
                // LedgEntryDim.SETRANGE("Table ID",DATABASE::"Cust. Ledger Entry");
                // LedgEntryDim.SETRANGE("Entry No.","Entry No.");
                // DimMgt.MoveLedgEntryDimToJnlLineDimLi(LedgEntryDim,JnlLineDim,DATABASE::"Liq. Journal Line",LiqLine."Journal Template Name",
                //                             LiqLine."Journal Batch Name",LiqLine."Line No.",0);
            END;
        end;

    end;

    local procedure InsertPFLineForPostedCartera()
    var
        MaxPmtTolerance: Decimal;
        Ct: Text;
        Text1140019: Label '%1 %2 %3';
        EntryType: Text;
        Text1140020: Label 'Pago prov.';
        Text1140021: Label 'Factura prov.';
        Text1140022: Label 'Abono prov.';
        Text1140023: Label 'Doc. interés prov.';
        Text1140024: Label 'Recordatorio prov.';
        Text1140101: Label 'Efecto Proveedor';
        Documentos: Record "Posted Cartera Doc.";
        Remesas: Record "Posted Payment Order";
        DocuemtosReg: Record "Posted Cartera Doc.";
        RemesasReg: Record "Posted Payment Order";
        //crear una variable para el record vendor
        Vendor: Record Vendor;
        VendorLedgEntry: Record "Vendor Ledger Entry";
    begin


        if "Vendor Pos Cartera Doc."."Account No." <> '' THEN
            Vendor.GET("Vendor Pos Cartera Doc."."Account No.")
        ELSE
            Vendor.INIT;

        CASE "Vendor Pos Cartera Doc."."Document Type" OF
            "Vendor Pos Cartera Doc."."Document Type"::Bill:
                EntryType := Text1140101;
            ELSE
                EntryType := '';
        END;

        if DueDateF <> 0D THEN
            if "Vendor Pos Cartera Doc."."Due Date" > CALCDATE('181D', WORKDATE) THEN CurrReport.SKIP;

        //if DueDateF<>0D THEN
        //if "Due Date">DueDateF THEN CurrReport.SKIP;

        //if DueDateD<>0D THEN
        //if "Due Date"<DueDateD THEN CurrReport.SKIP;
        if "Vendor Pos Cartera Doc."."Due Date" < DueDateD THEN Atrasado := TRUE ELSE Atrasado := FALSE;
        with CFWorksheetLine2 do begin
            // Init();
            // "Source Type" := "Source Type"::Receivables;
            // "Source No." := "Cust. Ledger Entry"."Document No.";
            // "Document Type" := "Cust. Ledger Entry"."Document Type";
            // "Document Date" := "Cust. Ledger Entry"."Document Date";
            // "Shortcut Dimension 2 Code" := "Cust. Ledger Entry"."Global Dimension 2 Code";
            // "Shortcut Dimension 1 Code" := "Cust. Ledger Entry"."Global Dimension 1 Code";
            // "Dimension Set ID" := "Cust. Ledger Entry"."Dimension Set ID";
            // "Cash Flow Account No." := CFSetup."Receivables CF Account No.";
            // Description := CopyStr(
            //     StrSubstNo(PostedSalesDocumentDescriptionTxt,
            //       Format("Document Type"),
            //       Format("Cust. Ledger Entry"."Due Date"),
            //       Customer.Name),
            //     1, MaxStrLen(Description));
            // "Document No." := "Cust. Ledger Entry"."Document No.";
            // SetCashFlowDate(CFWorksheetLine2, "Cust. Ledger Entry"."Due Date");
            // "Amount (LCY)" := "Cust. Ledger Entry"."Remaining Amt. (LCY)";
            // "Pmt. Discount Date" := "Cust. Ledger Entry"."Pmt. Discount Date";
            // "Pmt. Disc. Tolerance Date" := "Cust. Ledger Entry"."Pmt. Disc. Tolerance Date";

            // if "Cust. Ledger Entry"."Currency Code" <> '' then
            //     Currency.Get("Cust. Ledger Entry"."Currency Code")
            // else
            //     Currency.InitRoundingPrecision;

            // "Payment Discount" := Round("Cust. Ledger Entry"."Remaining Pmt. Disc. Possible" /
            //     "Cust. Ledger Entry"."Adjusted Currency Factor", Currency."Amount Rounding Precision");

            // if "Cash Flow Forecast"."Consider Pmt. Tol. Amount" then
            //     MaxPmtTolerance := Round("Cust. Ledger Entry"."Max. Payment Tolerance" /
            //         "Cust. Ledger Entry"."Adjusted Currency Factor", Currency."Amount Rounding Precision")
            // else
            //     MaxPmtTolerance := 0;

            // if "Cash Flow Forecast"."Consider CF Payment Terms" and (Customer."Cash Flow Payment Terms Code" <> '') then
            //     "Payment Terms Code" := Customer."Cash Flow Payment Terms Code"
            // else
            //     "Payment Terms Code" := '';

            // InsertTempCFWorksheetLine(MaxPmtTolerance);
            //ASC

            INIT;
            "Source Type" := "Source Type"::"Cartera Proveedores Registrada";//Payables;
            "Shortcut Dimension 2 Code" := "Vendor Pos Cartera Doc."."Global Dimension 2 Code";
            "Shortcut Dimension 1 Code" := "Vendor Pos Cartera Doc."."Global Dimension 1 Code";
            //"Gen. Bus. Posting Group" := Customer."Gen. Bus. Posting Group";
            Anotaciones("Vendor Pos Cartera Doc."."Account No.", True, Anotación, "Fecha Anotacion");
            //"Reason Code" := '';
            //CFWorksheetLine2. := 'CARTERA';
            //"Account Type" := LiqLine2."Account Type"::Customer;
            "Source No." := "Vendor Pos Cartera Doc."."Account No.";
            case "Vendor Pos Cartera Doc."."Document Type" of
                "Vendor Pos Cartera Doc."."Document Type"::Invoice:
                    "Document Type" := "Document Type"::Invoice;
                "Vendor Pos Cartera Doc."."Document Type"::Bill:
                    "Document Type" := "Document Type"::Bill;
            End;

            "Cash Flow Account No." := CFSetup."Payables CF Account No.";
            LiqAcc.GET("Cash Flow Account No.");
            if CompanyName = 'UATI' then
                Description := COPYSTR(STRSUBSTNO(Text1140019, EntryType + ' ' + Ct,
                                                   FORMAT("Vendor Pos Cartera Doc."."Posting Date"), "Shortcut Dimension 2 Code" + '-' +
                                                   Vendor.Name), 1, MAXSTRLEN(Description))
            ELSE
                Description := COPYSTR(STRSUBSTNO(Text1140019, EntryType,
                                                    FORMAT("Vendor Pos Cartera Doc."."Due Date"),
                                                    Vendor.Name), 1, MAXSTRLEN(Description));
            "Due Date" := ("Vendor Pos Cartera Doc."."Due Date");
            "Fecha Registro" := CalcFechaL("Vendor Pos Cartera Doc."."Due Date");
            "Cash Flow Date" := "Vendor Pos Cartera Doc."."Due Date";
            if "Cash Flow Forecast"."Consider CF Payment Terms" THEN BEGIN
                if Vendor."Cash Flow Payment Terms Code" <> '' THEN BEGIN
                    PaymentTerms.GET(Customer."Cash Flow Payment Terms Code");
                    "Fecha Registro" := CALCDATE(PaymentTerms."Due Date Calculation",
                    "Vendor Pos Cartera Doc."."Posting Date");
                END;
            END;
            "Document No." := "Vendor Pos Cartera Doc."."Document No.";

            if "Cash Flow Forecast"."Consider Discount" THEN BEGIN
                // if "Currency Code" <> '' THEN
                // "Payment Discount" := ROUND(Conversion.ExchangeAmtFCYToLCYAdjmt("Vendor Pos Cartera Doc."."Posting Date",
                //                     "Currency Code",0,
                //                     1))
                // ELSE
                "Payment Discount" := 0;
                "Amount (LCY)" := "Vendor Pos Cartera Doc."."Remaining Amt. (LCY)" - "Payment Discount";
                //"Amount (Currency)" := "Remaining Amount" - 0;
                if "Cash Flow Forecast".Comment THEN BEGIN
                    if Vendor."Cash Flow Payment Terms Code" <> '' THEN BEGIN
                        PaymentTerms.GET(Customer."Cash Flow Payment Terms Code");
                        "Fecha Registro" := CALCDATE(PaymentTerms."Discount Date Calculation", "Vendor Pos Cartera Doc."."Posting Date");
                        if "Cash Flow Forecast"."Consider Pmt. Disc. Tol. Date" THEN
                            "Fecha Registro" := CALCDATE(GLSetup."Payment Discount Grace Period", "Cash Flow Date");
                        // if "Currency Code" <> '' THEN BEGIN
                        // "Payment Discount" := ROUND("Remaining Amount" * PaymentTerms."Discount %" / 100);
                        // "Amount (Currency)" := "Remaining Amount" - "Payment Discount";
                        // END ELSE BEGIN
                        "Payment Discount" := ROUND("Vendor Pos Cartera Doc."."Remaining Amt. (LCY)" * PaymentTerms."Discount %" / 100);
                        "Amount (LCY)" := -"Vendor Pos Cartera Doc."."Remaining Amt. (LCY)" + "Payment Discount";
                        //END;
                    END;
                END;
            END ELSE BEGIN
                "Amount (LCY)" := -"Vendor Pos Cartera Doc."."Remaining Amt. (LCY)";
                //"Amount (Currency)" := "Remaining Amount";
            END;

            if "Cash Flow Forecast"."Consider Pmt. Tol. Amount" THEN BEGIN
                "Amount (LCY)" := "Amount (LCY)" - 0;
                //"Amount (Currency)" := "Amount (Currency)" -
                //                  ROUND(Conversion.ExchangeAmtFCYToLCYAdjmt("Posting Date",
                //                "Currency Code",0,
                //              0))
            END;

            //"Currency Code" := "Vendor Pos Cartera Doc."."Currency Code";
            //
            "Es Cartera" := TRUE;
            "Cod banco" := "Vendor Pos Cartera Doc.".Banco;//'SIN BANCO';
            if "Cod banco" = '' Then "Cod banco" := "Vendor Pos Cartera Doc."."Bank Account No.";
            if "Cod banco" = '' Then begin
                // si el cód. banco esta vacío lo cogemos de vendorledgerentry
                VendorLedgEntry.RESET;
                if VendorLedgEntry.get("Vendor Pos Cartera Doc."."Entry No.") Then
                    "Cod banco" := VendorLedgEntry.Banco;
                if "Cod banco" = '' Then
                    if Vendor.Get("Vendor Pos Cartera Doc."."Account No.") Then
                        "Cod banco" := Vendor.Banco;
            end;
            if "Cod banco" = '' THEN
                "Cod banco" := 'SIN BANCO';

            if Remesas.GET("Vendor Pos Cartera Doc."."Bill Gr./Pmt. Order No.") THEN BEGIN
                if Remesas."Bank Account No." <> '' THEN
                    "Cod banco" := Remesas."Bank Account No.";

            END;
            "Associated Entry No." := "Vendor Pos Cartera Doc."."Entry No.";
            "Payment Method Code" := "Vendor Pos Cartera Doc."."Payment Method Code";
            if "Vendor Pos Cartera Doc."."Due Date" < DueDateD THEN Atrasado := TRUE ELSE Atrasado := FALSE;
            if "Cod banco" <> 'SIN BANCO' THEN
                "Nombre Banco" := NBanco("Cod banco");
            // Buscamos Con Todos los datos
            SourceType := SourceType::"Cartera Proveedores Registrada";//Payables;
            BuscarLiq(LiqAcc, SourceType, TRUE, Atrasado, "Payment Method Code", "Cod banco", "Vendor Pos Cartera Doc."."Account No.", "Amount (LCY)", "Due Date", '');

            if LiqAcc."Banco Informes" <> '' THEN
                "Nombre Banco" := LiqAcc."Banco Informes"
            ELSE
                "Nombre Banco" := NBanco("Cod banco");
            "Cash Flow Account No." := LiqAcc."No.";
            // {if LiqAcc."Cod banco"<>'' THEN
            // if LiqAcc."Cod banco"<>"Cod banco" THEN Amount:=0;
            // if LiqAcc."Banco Informes"<>'' THEN BEGIN
            // if Remesas.GET("Bill Gr./Pmt. Order No.") THEN BEGIN
            // if NBanco(Remesas."Bank Account No.")<>LiqAcc."Banco Informes" THEN Amount:=0;
            // END ELSE
            // if LiqAcc."Banco Informes"<>NBanco("Cod banco") THEN Amount:=0;
            // END;  }
            if ExisteMov("Associated Entry No.") THEN "Amount (LCY)" := 0;
            //if LiqAcc."Solo Atrasados" THEN
            "Due Date" := ("Vendor Pos Cartera Doc."."Due Date");
            "Fecha Registro" := CalcFechaL("Vendor Pos Cartera Doc."."Due Date");
            "Cash Flow Date" := "Vendor Pos Cartera Doc."."Due Date";
            if ("Amount (LCY)" <> 0) AND (ComprobarProveedor("Posted Cartera Doc."."Account No.", LiqAcc."Cód. Proveedor")) THEN BEGIN
                InsertLiqLine();
                // Transfer Dimensions
                // LedgEntryDim.RESET;
                // LedgEntryDim.SETRANGE("Table ID",DATABASE::"Cust. Ledger Entry");
                // LedgEntryDim.SETRANGE("Entry No.","Entry No.");
                // DimMgt.MoveLedgEntryDimToJnlLineDimLi(LedgEntryDim,JnlLineDim,DATABASE::"Liq. Journal Line",LiqLine."Journal Template Name",
                //                             LiqLine."Journal Batch Name",LiqLine."Line No.",0);
            END;
        end;

    end;

    local procedure InsertCFLineForVendorLedgEntry()
    var
        MaxPmtTolerance: Decimal;
        Ct: Text;
        Fasctura: Record "Purch. Inv. Header";
        Contrato: Record "Sales Header";
        Abono: Record "Purch. Cr. Memo Hdr.";
        Text1140019: Label '%1 %2 %3';
        EntryType: Text;
        Text1140020: Label 'Pago prov.';
        Text1140021: Label 'Factura prov.';
        Text1140022: Label 'Abono prov.';
        Text1140023: Label 'Doc. interés prov.';
        Text1140024: Label 'Recordatorio prov.';
        Text1140101: Label 'Efecto Proveedor';
        Documentos: Record "Cartera Doc.";
        Remesas: Record "Payment Order";
        DocuemtosReg: Record "Posted Cartera Doc.";
        RemesasReg: Record "Posted Payment Order";

    begin

        if "Vendor Ledger Entry"."Vendor No." <> '' THEN
            Vendor.GET("Vendor Ledger Entry"."Vendor No.")
        ELSE
            Vendor.INIT;
        if "Vendor Ledger Entry"."Due Date" < DueDateD THEN Atrasado := TRUE ELSE Atrasado := FALSE;

        CASE "Vendor Ledger Entry"."Document Type" OF
            "Vendor Ledger Entry"."Document Type"::Payment:
                EntryType := Text1140020;
            "Vendor Ledger Entry"."Document Type"::Invoice:
                EntryType := Text1140021;
            "Vendor Ledger Entry"."Document Type"::"Credit Memo":
                EntryType := Text1140022;
            "Vendor Ledger Entry"."Document Type"::"Finance Charge Memo":
                EntryType := Text1140023;
            "Vendor Ledger Entry"."Document Type"::Reminder:
                EntryType := Text1140024;
            "Vendor Ledger Entry"."Document Type"::Bill:
                EntryType := Text1140101;
            ELSE
                EntryType := '';
        END;

        "Vendor Ledger Entry".CALCFIELDS("Remaining Amt. (LCY)", "Remaining Amount");
        with CFWorksheetLine2 do begin

            INIT;
            "Source Type" := "Source Type"::Payables;
            "Shortcut Dimension 2 Code" := "Vendor Ledger Entry"."Global Dimension 2 Code";
            "Shortcut Dimension 1 Code" := "Vendor Ledger Entry"."Global Dimension 1 Code";
            //"Gen. Bus. Posting Group" := Customer."Gen. Bus. Posting Group";
            Anotaciones("Vendor Ledger Entry"."Vendor No.", True, Anotación, "Fecha Anotacion");
            "Source No." := "Vendor Ledger Entry"."Vendor No.";
            "Document No." := "Vendor Ledger Entry"."Document No.";
            "Document Type" := "Vendor Ledger Entry"."Document Type";
            //"Source Code" := "Vendor Ledger Entry"."Source Code";
            //"Account Type" := CFWorksheetLine2."Account Type"::Customer;
            //"Account Number" := "Vendor Ledger Entry"."Customer No.";
            "Shortcut Dimension 2 Code" := "Vendor Ledger Entry"."Global Dimension 2 Code";
            "Shortcut Dimension 1 Code" := "Vendor Ledger Entry"."Global Dimension 1 Code";
            "Dimension Set ID" := "Vendor Ledger Entry"."Dimension Set ID";
            "Cash Flow Account No." := CFSetup."Payables CF Account No.";
            //"Cash Flow Account No." := LiqSetup."Receivables Liq. Account No.";
            LiqAcc.GET("Cash Flow Account No.");
            Ct := '';

            if "Vendor Ledger Entry"."Document Type" = "Vendor Ledger Entry"."Document Type"::Bill THEN begin
                if CompanyName = 'UATI' then
                    Description := COPYSTR(STRSUBSTNO(Text1140019, EntryType,
                                                       FORMAT("Vendor Ledger Entry"."Due Date"), "Shortcut Dimension 2 Code" + '-' +
                                                       Vendor.Name), 1, MAXSTRLEN(Description))
                ELSE
                    Description := COPYSTR(STRSUBSTNO(Text1140019, EntryType,
                                                        FORMAT("Vendor Ledger Entry"."Due Date"),
                                                        Vendor.Name), 1, MAXSTRLEN(CFWorksheetLine2.Description));
            end else begin
                if CompanyName = 'UATI' then
                    Description := COPYSTR(STRSUBSTNO(Text1140019, EntryType,
                                                       FORMAT("Vendor Cartera Doc."."Posting Date"), "Shortcut Dimension 2 Code" + '-' +
                                                       Vendor.Name), 1, MAXSTRLEN(Description))
                ELSE
                    Description := COPYSTR(STRSUBSTNO(Text1140019, EntryType,
                                                        FORMAT("Vendor Ledger Entry"."Posting Date"),
                                                        Vendor.Name), 1, MAXSTRLEN(CFWorksheetLine2.Description));
            end;
            "Due Date" := CalcFecha("Vendor Ledger Entry"."Due Date");

            "Fecha Registro" := CalcFechaL("Vendor Ledger Entry"."Due Date");
            "Cash Flow Date" := Calcfecha("Vendor Ledger Entry"."Due Date");
            if "Vendor Ledger Entry"."Due Date" <= TODAY THEN BEGIN
                //"Due Date" := TODAY;
                //"Cash Flow Date" := TODAY;
            END;
            if "Cash Flow Forecast"."Consider CF Payment Terms" THEN BEGIN
                if Vendor."Cash Flow Payment Terms Code" <> '' THEN BEGIN
                    PaymentTerms.GET(Vendor."Cash Flow Payment Terms Code");
                    "Fecha Registro" := CALCDATE(PaymentTerms."Due Date Calculation", "Document Date");
                END;
            END;
            "Document No." := "Vendor Ledger Entry"."Document No.";

            if "Cash Flow Forecast"."Consider Discount" THEN BEGIN
                if "Vendor Ledger Entry"."Currency Code" <> '' THEN
                    "Payment Discount" := ROUND(CurrExchRate.ExchangeAmtFCYToLCYAdjmt("Vendor Ledger Entry"."Posting Date",
                                        "Vendor Ledger Entry"."Currency Code", "Vendor Ledger Entry"."Original Pmt. Disc. Possible",
                                        "Vendor Ledger Entry"."Original Currency Factor"))
                ELSE
                    "Payment Discount" := "Vendor Ledger Entry"."Original Pmt. Disc. Possible";
                "Amount (LCY)" := "Vendor Ledger Entry"."Remaining Amt. (LCY)" - "Payment Discount";
                //"Amount (Currency)" := "Vendor Ledger Entry"."Remaining Amount" - "Vendor Ledger Entry"."Original Pmt. Disc. Possible";
                if "Vendor Ledger Entry"."Pmt. Discount Date" <> 0D THEN BEGIN
                    "Fecha Registro" := "Vendor Ledger Entry"."Pmt. Discount Date";
                    if "Cash Flow Forecast"."Consider Pmt. Disc. Tol. Date" THEN
                        "Fecha Registro" := "Vendor Ledger Entry"."Pmt. Disc. Tolerance Date";
                END;
                if "Cash Flow Forecast"."Consider CF Payment Terms" THEN BEGIN
                    if Vendor."Cash Flow Payment Terms Code" <> '' THEN BEGIN
                        PaymentTerms.GET(Vendor."Cash Flow Payment Terms Code");
                        "Fecha Registro" := CALCDATE(PaymentTerms."Discount Date Calculation", "Document Date");
                        if "Cash Flow Forecast"."Consider Pmt. Disc. Tol. Date" THEN
                            "Fecha Registro" := CALCDATE(GLSetup."Payment Discount Grace Period", "Cash Flow Date");
                        if "Vendor Ledger Entry"."Currency Code" <> '' THEN BEGIN
                            "Payment Discount" := ROUND("Vendor Ledger Entry"."Remaining Amount" * PaymentTerms."Discount %" / 100);
                            //"Amount (Currency)" := "Vendor Ledger Entry"."Remaining Amount" - "Payment Discount";
                        END ELSE BEGIN
                            "Payment Discount" := ROUND("Vendor Ledger Entry"."Remaining Amt. (LCY)" * PaymentTerms."Discount %" / 100);
                            "Amount (LCY)" := "Vendor Ledger Entry"."Remaining Amt. (LCY)" - "Payment Discount";
                        END;
                    END;
                END;
            END ELSE BEGIN
                "Amount (LCY)" := "Vendor Ledger Entry"."Remaining Amt. (LCY)";
                //"Amount (Currency)" := "Vendor Ledger Entry"."Remaining Amount";
            END;

            if "Cash Flow Forecast"."Consider Pmt. Tol. Amount" THEN BEGIN
                "Amount (LCY)" := "Amount (LCY)" - "Vendor Ledger Entry"."Max. Payment Tolerance";
                if "Vendor Ledger Entry"."Currency Code" <> '' Then
                    "Amount (LCY)" := "Amount (LCY)" -
                                        ROUND(CurrExchRate.ExchangeAmtFCYToLCYAdjmt("Vendor Ledger Entry"."Posting Date",
                                        "Vendor Ledger Entry"."Currency Code", "Vendor Ledger Entry"."Max. Payment Tolerance",
                                        "Vendor Ledger Entry"."Original Currency Factor"))
            END;

            //"Currency Code" := "Vendor Ledger Entry"."Currency Code";
            //
            "Es Cartera" := false;
            if "Vendor Ledger Entry".Banco <> '' THEN
                "Cod banco" := "Vendor Ledger Entry".Banco
            ELSE begin

                if Vendor.Get("Vendor Ledger Entry"."Vendor No.") then
                    if Vendor."Banco" <> '' then
                        "Cod banco" := Vendor."Banco"
                    else
                        "Cod banco" := 'SIN BANCO';

            END;
            if Documentos.GET(Documentos.Type::Payable, "Vendor Ledger Entry"."Entry No.") THEN BEGIN
                if Remesas.GET(Documentos."Bill Gr./Pmt. Order No.") THEN BEGIN
                    "Cod banco" := Remesas."Bank Account No.";
                    "Es Cartera" := TRUE;
                END;
                "Cash Flow Date" := Documentos."Due Date";
            END;
            if DocuemtosReg.GET(DocuemtosReg.Type::Payable, "Vendor Ledger Entry"."Entry No.") THEN BEGIN
                if RemesasReg.GET(DocuemtosReg."Bill Gr./Pmt. Order No.") THEN BEGIN
                    "Cod banco" := RemesasReg."Bank Account No.";
                    "Es Cartera" := TRUE;
                END;
                "Cash Flow Date" := DocuemtosReg."Due Date";

            END;

            // {if LiqAcc."Banco Informes"<>'' THEN
            // "Nombre Banco":=LiqAcc."Banco Informes"
            // ELSE
            // }
            // //
            //"Es Cartera" := FALSE;
            "Associated Entry No." := "Vendor Ledger Entry"."Entry No.";
            "Payment Method Code" := "Vendor Ledger Entry"."Payment Method Code";
            if "Vendor Ledger Entry"."Due Date" < DueDateD THEN Atrasado := TRUE ELSE Atrasado := FALSE;
            "Nombre Banco" := NBanco("Cod banco");
            "Source Type" := SourceType::Payables;
            SourceType := SourceType::Payables;
            BuscarLiq(LiqAcc, SourceType, FALSE, Atrasado, "Payment Method Code", "Cod banco", "Vendor Ledger Entry"."Vendor No.", "Vendor Ledger Entry".Amount, "Due Date",
            '');

            "Cash Flow Account No." := LiqAcc."No.";

            // {LiqAcc.GET("Cash Flow Account No.");
            // if LiqAcc."Cod banco"<>'' THEN
            // if LiqAcc."Cod banco"<>"Cod banco" THEN Amount:=0;
            // if LiqAcc."Banco Informes"<>'' THEN BEGIN
            // if LiqAcc."Banco Informes"<>NBanco("Cod banco") THEN Amount:=0;
            // END;
            // if ("Vendor Ledger Entry"."Document Type"="Vendor Ledger Entry"."Document Type"::Payment)
            // AND ("Vendor Ledger Entry"."Nº Factura Borrador"<>'') THEN Amount:=0;       

            // }
            //if LiqAcc."Solo Atrasados" THEN
            if ExisteMov("Associated Entry No.") THEN "Amount (LCY)" := 0;
            //"Due Date" := "Vendor Ledger Entry"."Due Date";
            //"Cash Flow Date" := "Vendor Ledger Entry"."Due Date";
            //
            if ("Amount (LCY)" <> 0) AND (ComprobarProveedor("Vendor Ledger Entry"."Vendor No.", LiqAcc."Cód. Proveedor")) THEN BEGIN
                if InsertLiqLine() THEN;
                // Transfer Dimensions
                // LedgEntryDim.RESET;
                // LedgEntryDim.SETRANGE("Table ID",DATABASE::"Vendor Ledger Entry");
                // LedgEntryDim.SETRANGE("Entry No.","Cust. Ledger Entry"."Entry No.");
                // DimMgt.MoveLedgEntryDimToJnlLineDimLi(LedgEntryDim,JnlLineDim,DATABASE::"Liq. Journal Line",LiqLine."Journal Template Name",
                //                             LiqLine."Journal Batch Name",LiqLine."Line No.",0);
            end;
        end;
    end;

    local procedure InsertCFLineForPurchaseLine()
    var
        PurchLine2: Record "Purchase Line";
    begin
        PurchLine2 := "Purchase Line";
        if Summarized and (PurchLine2.Next <> 0) and (PurchLine2."Buy-from Vendor No." <> '') and
           (PurchLine2."Document No." = "Purchase Line"."Document No.")
        then begin
            TotalAmt += CalculateLineAmountForPurchaseLine(PurchHeader, "Purchase Line");
            MultiSalesLines := true;
        end else
            with CFWorksheetLine2 do begin
                Init();
                "Source Type" := "Source Type"::"Purchase Orders";
                "Source No." := "Purchase Line"."Document No.";
                "Source Line No." := "Purchase Line"."Line No.";
                "Document Type" := "Document Type"::Invoice;
                "Document Date" := PurchHeader."Document Date";
                "Shortcut Dimension 1 Code" := PurchHeader."Shortcut Dimension 1 Code";
                "Shortcut Dimension 2 Code" := PurchHeader."Shortcut Dimension 2 Code";
                "Dimension Set ID" := PurchHeader."Dimension Set ID";
                "Cash Flow Account No." := CFSetup."Purch. Order CF Account No.";
                Description :=
                  CopyStr(
                    StrSubstNo(
                      PurchaseDocumentDescriptionTxt,
                      PurchHeader."Document Type",
                      Format(PurchHeader."Order Date"),
                      PurchHeader."Buy-from Vendor Name"),
                    1, MaxStrLen(Description));
                SetCashFlowDate(CFWorksheetLine2, PurchHeader."Due Date");
                "Document No." := "Purchase Line"."Document No.";
                "Amount (LCY)" := CalculateLineAmountForPurchaseLine(PurchHeader, "Purchase Line");

                if Summarized and MultiSalesLines then begin
                    "Amount (LCY)" := "Amount (LCY)" + TotalAmt;
                    MultiSalesLines := false;
                    TotalAmt := 0;
                end;

                if PaymentMethod.Get(PurchHeader."Payment Method Code") then
                    if (PaymentMethod."Create Bills" or PaymentMethod."Invoices to Cartera") and
                       (not CarteraSetup.ReadPermission)
                    then
                        Error(CannotCreateCarteraDocErr);

                if not ("Purchase Line"."Document Type" in
                        ["Purchase Line"."Document Type"::"Credit Memo", "Purchase Line"."Document Type"::"Return Order"]) and
                   CarteraSetup.ReadPermission and PaymentMethod."Create Bills"
                then
                    SplitPurchInv(
                      PurchHeader, CFWorksheetLine2, "Amount (LCY)", -(-"Amount (LCY)" - "Purchase Line"."Line Amount"));

                if "Cash Flow Forecast"."Consider CF Payment Terms" and (Vendor."Cash Flow Payment Terms Code" <> '') then
                    "Payment Terms Code" := Vendor."Cash Flow Payment Terms Code"
                else
                    "Payment Terms Code" := PurchHeader."Payment Terms Code";

                if ("Amount (LCY)" <> 0) and not PaymentMethod."Create Bills" then
                    InsertTempCFWorksheetLine(0);
            end;
    end;

    local procedure InsertCFLineForSalesLine()
    var
        SalesLine2: Record "Sales Line";
    begin
        SalesLine2 := "Sales Line";
        if Summarized and (SalesLine2.Next <> 0) and (SalesLine2."Sell-to Customer No." <> '') and
           (SalesLine2."Document No." = "Sales Line"."Document No.")
        then begin
            TotalAmt += CalculateLineAmountForSalesLine(SalesHeader, "Sales Line");
            MultiSalesLines := true;
        end else
            with CFWorksheetLine2 do begin
                Init();
                "Document Type" := "Document Type"::Invoice;
                "Document Date" := SalesHeader."Document Date";
                "Source Type" := "Source Type"::"Sales Orders";
                "Source No." := "Sales Line"."Document No.";
                "Source Line No." := "Sales Line"."Line No.";
                "Shortcut Dimension 1 Code" := SalesHeader."Shortcut Dimension 1 Code";
                "Shortcut Dimension 2 Code" := SalesHeader."Shortcut Dimension 2 Code";
                "Dimension Set ID" := SalesHeader."Dimension Set ID";
                "Cash Flow Account No." := CFSetup."Sales Order CF Account No.";
                Description :=
                  CopyStr(
                    StrSubstNo(
                      SalesDocumentDescriptionTxt,
                      SalesHeader."Document Type",
                      Format(SalesHeader."Order Date"),
                      SalesHeader."Sell-to Customer Name"),
                    1, MaxStrLen(Description));
                SetCashFlowDate(CFWorksheetLine2, SalesHeader."Due Date");
                "Document No." := "Sales Line"."Document No.";
                "Amount (LCY)" := CalculateLineAmountForSalesLine(SalesHeader, "Sales Line");

                if Summarized and MultiSalesLines then begin
                    "Amount (LCY)" := "Amount (LCY)" + TotalAmt;
                    MultiSalesLines := false;
                    TotalAmt := 0;
                end;

                if PaymentMethod.Get(SalesHeader."Payment Method Code") then
                    if (PaymentMethod."Create Bills" or PaymentMethod."Invoices to Cartera") and
                       (not CarteraSetup.ReadPermission)
                    then
                        Error(CannotCreateCarteraDocErr);

                if not ("Sales Line"."Document Type" in
                        ["Sales Line"."Document Type"::"Credit Memo", "Sales Line"."Document Type"::"Return Order"]) and
                   CarteraSetup.ReadPermission and PaymentMethod."Create Bills"
                then
                    SplitSalesInv(
                      SalesHeader, CFWorksheetLine2, "Amount (LCY)", "Amount (LCY)" - "Sales Line"."Line Amount");

                if "Cash Flow Forecast"."Consider CF Payment Terms" and (Customer."Cash Flow Payment Terms Code" <> '') then
                    "Payment Terms Code" := Customer."Cash Flow Payment Terms Code"
                else
                    "Payment Terms Code" := SalesHeader."Payment Terms Code";

                if ("Amount (LCY)" <> 0) and not PaymentMethod."Create Bills" then
                    InsertTempCFWorksheetLine(0);
            end;
    end;

    local procedure InsertCFLineForFixedAssetsBudget()
    begin
        with CFWorksheetLine2 do begin
            Init();
            "Source Type" := "Source Type"::"Fixed Assets Budget";
            "Source No." := InvestmentFixedAsset."No.";
            "Document No." := InvestmentFixedAsset."No.";
            "Cash Flow Account No." := CFSetup."FA Budget CF Account No.";
            Description :=
              CopyStr(
                StrSubstNo(
                  Text027, InvestmentFixedAsset."No.", Format(-FADeprBook."Acquisition Cost")),
                1, MaxStrLen(Description));
            SetCashFlowDate(CFWorksheetLine2, FADeprBook."Acquisition Date");
            "Amount (LCY)" := -FADeprBook."Acquisition Cost";
            "Shortcut Dimension 2 Code" := InvestmentFixedAsset."Global Dimension 2 Code";
            "Shortcut Dimension 1 Code" := InvestmentFixedAsset."Global Dimension 1 Code";
            MoveDefualtDimToJnlLineDim(DATABASE::"Fixed Asset", InvestmentFixedAsset."No.", "Dimension Set ID");
            InsertTempCFWorksheetLine(0);
        end;
    end;

    local procedure InsertCFLineForFixedAssetsDisposal()
    begin
        with CFWorksheetLine2 do begin
            Init();
            "Source Type" := "Source Type"::"Fixed Assets Disposal";
            "Source No." := SaleFixedAsset."No.";
            "Document No." := SaleFixedAsset."No.";
            "Cash Flow Account No." := CFSetup."FA Disposal CF Account No.";
            Description :=
              CopyStr(
                StrSubstNo(
                  Text027, SaleFixedAsset."No.", Format(FADeprBook."Projected Proceeds on Disposal")),
                1, MaxStrLen(Description));
            SetCashFlowDate(CFWorksheetLine2, FADeprBook."Projected Disposal Date");
            "Amount (LCY)" := FADeprBook."Projected Proceeds on Disposal";
            "Shortcut Dimension 2 Code" := SaleFixedAsset."Global Dimension 2 Code";
            "Shortcut Dimension 1 Code" := SaleFixedAsset."Global Dimension 1 Code";
            MoveDefualtDimToJnlLineDim(DATABASE::"Fixed Asset", SaleFixedAsset."No.", "Dimension Set ID");
            InsertTempCFWorksheetLine(0);
        end;
    end;

    local procedure InsertCFLineForManualExpense()
    var
        "Execution Date": Date;
        a: Integer;
        Text1140028: Label '%1 gastos neutr.';
    begin
        with CFWorksheetLine2 do begin
            //     "Cash Flow Manual Expense".TestField("Starting Date");
            //     Init();
            //     "Source Type" := "Source Type"::"Cash Flow Manual Expense";
            //     "Source No." := "Cash Flow Manual Expense".Code;
            //     "Document No." := "Cash Flow Manual Expense".Code;
            //     "Cash Flow Account No." := "Cash Flow Manual Expense"."Cash Flow Account No.";
            //     "Shortcut Dimension 1 Code" := "Cash Flow Manual Expense"."Global Dimension 1 Code";
            //     "Shortcut Dimension 2 Code" := "Cash Flow Manual Expense"."Global Dimension 2 Code";
            //     MoveDefualtDimToJnlLineDim(DATABASE::"Cash Flow Manual Expense", "Cash Flow Manual Expense".Code, "Dimension Set ID");
            //     Description := CopyStr(StrSubstNo(Text028, "Cash Flow Manual Expense".Description), 1, MaxStrLen(Description));
            //     DateLastExecution := "Cash Flow Forecast"."Manual Payments To";
            //     if ("Cash Flow Manual Expense"."Ending Date" <> 0D) and
            //        ("Cash Flow Manual Expense"."Ending Date" < "Cash Flow Forecast"."Manual Payments To")
            //     then
            //         DateLastExecution := "Cash Flow Manual Expense"."Ending Date";
            //     ExecutionDate := "Cash Flow Manual Expense"."Starting Date";
            //     if Format("Cash Flow Manual Expense"."Recurring Frequency") <> '' then begin
            //         if DateLastExecution = 0D then begin
            //             NeedsManualPmtUpdate := true;
            //             InsertManualData(
            //               ExecutionDate, "Cash Flow Forecast", -"Cash Flow Manual Expense".Amount);
            //         end else
            //             while ExecutionDate <= DateLastExecution do begin
            //                 InsertManualData(
            //                   ExecutionDate, "Cash Flow Forecast", -"Cash Flow Manual Expense".Amount);
            //                 ExecutionDate := CalcDate("Cash Flow Manual Expense"."Recurring Frequency", ExecutionDate);
            //             end;
            //     end else
            //         InsertManualData(ExecutionDate, "Cash Flow Forecast", -"Cash Flow Manual Expense".Amount);
            // end;

            if "Cash Flow Manual Expense"."Starting Date" = 0D THEN
                "Cash Flow Manual Expense"."Starting Date" := DummyDate;// PostDate;
            if "Cash Flow Manual Expense"."Ending Date" = 0D THEN
                "Cash Flow Manual Expense"."Ending Date" := DummyDate;
            if (Format("Cash Flow Manual Expense"."Recurring Frequency") = '') AND ("Cash Flow Manual Expense"."Una Sola Vez") THEN
                Evaluate("Cash Flow Manual Expense"."Recurring Frequency", '99A');
            INIT;
            "Source Type" := "Source Type"::"Cash Flow Manual Expense";
            "Document No." := "Cash Flow Manual Expense".Code;
            "Cash Flow Account No." := "Cash Flow Manual Expense"."Cash Flow Account No.";
            "Shortcut Dimension 1 Code" := "Cash Flow Manual Expense"."Global Dimension 1 Code";
            "Shortcut Dimension 2 Code" := "Cash Flow Manual Expense"."Global Dimension 2 Code";
            "Cod banco" := "Cash Flow Manual Expense".Banco;

            if LiqAcc."Banco Informes" <> '' THEN
                "Nombre Banco" := LiqAcc."Banco Informes"
            ELSE
                "Nombre Banco" := NBanco("Cod banco");
            Description := COPYSTR(STRSUBSTNO(Text1140028, "Cash Flow Manual Expense".Description), 1, MAXSTRLEN(CFWorksheetLine2.Description));
            DateLastExecution := "Cash Flow Forecast"."Manual Payments To";
            if ("Cash Flow Manual Expense"."Ending Date" <> 0D) AND ("Cash Flow Manual Expense"."Ending Date" < "Cash Flow Forecast"."Manual Payments To") THEN
                DateLastExecution := "Cash Flow Manual Expense"."Ending Date";
            DateLastExecution := "Cash Flow Manual Expense"."Ending Date";
            "Execution Date" := "Cash Flow Manual Expense"."Starting Date";
            //if ("Cash Flow Manual Expense"."First Execution" <> 0D) AND
            // ("Cash Flow Manual Expense"."First Execution" < Liquidity."Neutral Payments From") THEN
            //"Execution Date" := Liquidity."Neutral Payments From";
            if "Cash Flow Manual Expense"."Una Sola Vez" THEN BEGIN
                if Format("Cash Flow Manual Expense"."Recurring Frequency") = '' THEN
                    "Execution Date" := CALCDATE("Cash Flow Manual Expense"."Recurring Frequency", DummyDate);
                DateLastExecution := "Execution Date";
                if Format("Cash Flow Manual Expense"."Recurring Frequency") = '' THEN
                    EVALUATE("Cash Flow Manual Expense"."Recurring Frequency", '1M');
            END;

            WHILE ("Execution Date" <= DateLastExecution) AND (a < 1000) DO BEGIN
                a += 1;

                "Due Date" := "Execution Date";
                "Cash Flow Date" := "Execution Date";
                "Fecha Registro" := DummyDate;
                "Amount (LCY)" := -"Cash Flow Manual Expense".Amount;
                //"Amount (Currency)" := -"Cash Flow Manual Expense".Amount;
                if ("Amount (LCY)" <> 0)

                AND (("Execution Date" >= DueDateD) AND
                ("Execution Date" <= DueDateF)) THEN BEGIN

                    InsertLiqLine();
                    // Transfer Dimensions
                    if (Format("Cash Flow Manual Expense"."Recurring Frequency") = '99A') Or (Format("Cash Flow Manual Expense"."Recurring Frequency") = '99A') THEN BEGIN
                        "Execution Date" := DateLastExecution + 1;
                    END;
                END;
                if (Format("Cash Flow Manual Expense"."Recurring Frequency") = '99A') Or (Format("Cash Flow Manual Expense"."Recurring Frequency") = '99A') THEN
                    "Execution Date" := "Cash Flow Manual Expense"."Starting Date" + 1
                ELSE
                    "Execution Date" := CALCDATE("Cash Flow Manual Expense"."Recurring Frequency", "Execution Date");

            END;
        end;
    end;

    local procedure InsertCFLineForManualRevenue()
    var
        "Execution Date": Date;
        a: Integer;
        Text1140028: Label '%1 ingresos neutr.';
    begin
        with CFWorksheetLine2 do begin
            if "Cash Flow Manual Revenue"."Starting Date" = 0D THEN
                "Cash Flow Manual Revenue"."Starting Date" := DummyDate;// PostDate;
            if "Cash Flow Manual Revenue"."Ending Date" = 0D THEN
                "Cash Flow Manual Revenue"."Ending Date" := DummyDate;
            if (Format("Cash Flow Manual Revenue"."Recurring Frequency") = '') AND ("Cash Flow Manual Revenue"."Una Sola Vez") THEN
                Evaluate("Cash Flow Manual Revenue"."Recurring Frequency", '99A');
            INIT;
            "Source Type" := "Source Type"::"Cash Flow Manual Revenue";
            "Document No." := "Cash Flow Manual Revenue".Code;
            "Cash Flow Account No." := "Cash Flow Manual Revenue"."Cash Flow Account No.";
            "Shortcut Dimension 1 Code" := "Cash Flow Manual Revenue"."Global Dimension 1 Code";
            "Shortcut Dimension 2 Code" := "Cash Flow Manual Revenue"."Global Dimension 2 Code";
            "Cod banco" := "Cash Flow Manual Revenue".Banco;

            if LiqAcc."Banco Informes" <> '' THEN
                "Nombre Banco" := LiqAcc."Banco Informes"
            ELSE
                "Nombre Banco" := NBanco("Cod banco");
            Description := COPYSTR(STRSUBSTNO(Text1140028, "Cash Flow Manual Revenue".Description), 1, MAXSTRLEN(CFWorksheetLine2.Description));
            //DateLastExecution := "Cash Flow Forecast"."Manual Payments To";
            //if ("Cash Flow Manual Revenue"."Ending Date" <> 0D) AND ("Cash Flow Manual Revenue"."Ending Date" < "Cash Flow Forecast"."Manual Payments To") THEN
            //    DateLastExecution := "Cash Flow Manual Revenue"."Ending Date";
            DateLastExecution := "Cash Flow Manual Revenue"."Ending Date";
            "Execution Date" := "Cash Flow Manual Revenue"."Starting Date";
            //if ("Cash Flow Manual Expense"."First Execution" <> 0D) AND
            // ("Cash Flow Manual Expense"."First Execution" < Liquidity."Neutral Payments From") THEN
            //"Execution Date" := Liquidity."Neutral Payments From";
            if "Cash Flow Manual Revenue"."Una Sola Vez" THEN BEGIN
                "Execution Date" := CALCDATE("Cash Flow Manual Revenue"."Recurring Frequency", DummyDate);
                DateLastExecution := "Execution Date";
                EVALUATE("Cash Flow Manual Revenue"."Recurring Frequency", '1M');
            END;

            WHILE ("Execution Date" <= DateLastExecution) AND (a < 1000) DO BEGIN
                a += 1;

                "Due Date" := "Execution Date";
                "Cash Flow Date" := "Execution Date";
                "Fecha Registro" := DummyDate;
                "Amount (LCY)" := "Cash Flow Manual Revenue".Amount;
                //"Amount (Currency)" := -"Cash Flow Manual Expense".Amount;
                if ("Amount (LCY)" <> 0)

                AND (("Execution Date" >= DueDateD) AND
                ("Execution Date" <= DueDateF)) THEN BEGIN

                    InsertLiqLine();
                    // Transfer Dimensions
                    if (Format("Cash Flow Manual Revenue"."Recurring Frequency") = '99A') Or (Format("Cash Flow Manual Revenue"."Recurring Frequency") = '') THEN BEGIN
                        "Execution Date" := DateLastExecution + 1;
                    END;
                END;
                if (Format("Cash Flow Manual Revenue"."Recurring Frequency") = '99A') Or (Format("Cash Flow Manual Revenue"."Recurring Frequency") = '') THEN
                    "Execution Date" := "Cash Flow Manual Revenue"."Starting Date" + 1
                ELSE
                    "Execution Date" := CALCDATE("Cash Flow Manual Revenue"."Recurring Frequency", "Execution Date");

            END;
        end;
    end;

    local procedure InsertCFLineForGLBudget(GLAcc: Record "G/L Account")
    begin
        with CFWorksheetLine2 do begin
            Init();
            "Source Type" := "Source Type"::"G/L Budget";
            "Source No." := GLAcc."No.";
            "G/L Budget Name" := GLBudgEntry."Budget Name";
            "Document No." := Format(GLBudgEntry."Entry No.");
            "Cash Flow Account No." := CFAccountForBudget."No.";
            Description :=
              CopyStr(
                StrSubstNo(
                  Text030, GLAcc.Name, Format(GLBudgEntry.Description)),
                1, MaxStrLen(Description));
            SetCashFlowDate(CFWorksheetLine2, GLBudgEntry.Date);
            "Amount (LCY)" := -GLBudgEntry.Amount;
            "Shortcut Dimension 1 Code" := GLBudgEntry."Global Dimension 1 Code";
            "Shortcut Dimension 2 Code" := GLBudgEntry."Global Dimension 2 Code";
            "Dimension Set ID" := GLBudgEntry."Dimension Set ID";
            InsertTempCFWorksheetLine(0);
        end;
    end;

    local procedure InsertCFLineForServiceLine()
    var
        ServiceLine2: Record "Service Line";
    begin
        ServiceLine2 := "Service Line";
        if Summarized and (ServiceLine2.Next <> 0) and (ServiceLine2."Customer No." <> '') and
           (ServiceLine2."Document No." = "Service Line"."Document No.")
        then begin
            TotalAmt += CalculateLineAmountForServiceLine("Service Line");

            MultiSalesLines := true;
        end else
            with CFWorksheetLine2 do begin
                Init();
                "Source Type" := "Source Type"::"Service Orders";
                "Source No." := "Service Line"."Document No.";
                "Source Line No." := "Service Line"."Line No.";
                "Document Type" := "Document Type"::Invoice;
                "Document Date" := ServiceHeader."Document Date";
                "Shortcut Dimension 1 Code" := ServiceHeader."Shortcut Dimension 1 Code";
                "Shortcut Dimension 2 Code" := ServiceHeader."Shortcut Dimension 2 Code";
                "Dimension Set ID" := ServiceHeader."Dimension Set ID";
                "Cash Flow Account No." := CFSetup."Service CF Account No.";
                Description :=
                  CopyStr(
                    StrSubstNo(
                      ServiceDocumentDescriptionTxt,
                      ServiceHeader."Document Type",
                      ServiceHeader.Name,
                      Format(ServiceHeader."Order Date")),
                    1, MaxStrLen(Description));
                SetCashFlowDate(CFWorksheetLine2, ServiceHeader."Due Date");
                "Document No." := "Service Line"."Document No.";
                "Amount (LCY)" := CalculateLineAmountForServiceLine("Service Line");

                if Summarized and MultiSalesLines then begin
                    "Amount (LCY)" := "Amount (LCY)" + TotalAmt;
                    MultiSalesLines := false;
                    TotalAmt := 0;
                end;

                if PaymentMethod.Get(PurchHeader."Payment Method Code") then
                    if (PaymentMethod."Create Bills" or PaymentMethod."Invoices to Cartera") and
                       (not CarteraSetup.ReadPermission)
                    then
                        Error(CannotCreateCarteraDocErr);

                if ("Service Line"."Document Type" <> "Service Line"."Document Type"::"Credit Memo") and
                   CarteraSetup.ReadPermission and PaymentMethod."Create Bills"
                then
                    SplitServInv(
                      ServiceHeader, CFWorksheetLine2, "Amount (LCY)", "Amount (LCY)" - "Service Line"."Line Amount");

                if "Cash Flow Forecast"."Consider CF Payment Terms" and (Customer."Cash Flow Payment Terms Code" <> '') then
                    "Payment Terms Code" := Customer."Cash Flow Payment Terms Code"
                else
                    "Payment Terms Code" := ServiceHeader."Payment Terms Code";

                if ("Amount (LCY)" <> 0) and not PaymentMethod."Create Bills" then
                    InsertTempCFWorksheetLine(0);
            end;
    end;

    local procedure InsertCFLineForJobPlanningLine()
    var
        Job: Record Job;
        InsertConditionHasBeenMetAlready: Boolean;
    begin
        if Job.Get("Job Planning Line"."Job No.") Then begin
            if (TempCFWorksheetLine."Source Type" = TempCFWorksheetLine."Source Type"::Job) and
               ("Job Planning Line"."Job No." = TempCFWorksheetLine."Source No.") and
               ("Job Planning Line"."Planning Date" = TempCFWorksheetLine."Document Date") and
               ("Job Planning Line"."Document No." = TempCFWorksheetLine."Document No.")
            then begin
                InsertConditionHasBeenMetAlready := InsertConditionMet;
                TempCFWorksheetLine."Amount (LCY)" += GetJobPlanningAmountForCFLine("Job Planning Line");
                InsertOrModifyCFLine(InsertConditionHasBeenMetAlready);
            end else
                with CFWorksheetLine2 do begin
                    Init();
                    "Source Type" := "Source Type"::Job;
                    "Source No." := "Job Planning Line"."Job No.";
                    "Document Type" := "Document Type"::Invoice;
                    "Document Date" := "Job Planning Line"."Planning Date";
                    "Cash Flow Date" := "Document Date";
                    "Due Date" := "Document Date";
                    "Fecha Registro" := DummyDate;
                    Job.Get("Job Planning Line"."Job No.");
                    "Shortcut Dimension 1 Code" := Job."Global Dimension 1 Code";
                    "Shortcut Dimension 2 Code" := Job."Global Dimension 2 Code";
                    "Cash Flow Account No." := CFSetup."Job CF Account No.";
                    Description :=
                      CopyStr(
                        StrSubstNo(
                          Text025,
                          Job.TableCaption,
                          Job.Description,
                          Format("Job Planning Line"."Document Date")),
                        1, MaxStrLen(Description));
                    SetCashFlowDate(CFWorksheetLine2, "Job Planning Line"."Planning Date");
                    "Document No." := "Job Planning Line"."Document No.";
                    "Amount (LCY)" := GetJobPlanningAmountForCFLine("Job Planning Line");

                    InsertTempCFWorksheetLine(0);
                end;
        end;
    end;

    local procedure InsertCfLineForPrestamos()
    var
        InsertConditionHasBeenMetAlready: Boolean;
        rCab: Record "Cabecera Prestamo";
        PresLine2: Record "Detalle Prestamo";
        rBanc: Record "Bank Account";
        Factor: Decimal;
        TotalAmtCurrency: Decimal;
        TotalLineAmount: Decimal;
    begin
        if NOT rCab.GET("Detalle Prestamo"."Código Del Prestamo") THEN
            CurrReport.SKIP;
        if rCab.Renting = true Then CurrReport.Skip();
        if rCab.Empresa <> '' THEN CurrReport.SKIP;
        PresLine2 := "Detalle Prestamo";

        if Summarized AND (PresLine2.NEXT <> 0) AND (PresLine2."Código Del Prestamo" =
        "Detalle Prestamo"."Código Del Prestamo") THEN BEGIN
            CurrExchRate.SETRANGE("Currency Code", '');
            CurrExchRate.SETRANGE("Starting Date", 0D, "Detalle Prestamo".Fecha);
            if CurrExchRate.FIND('+') THEN
                Factor := CurrExchRate."Exchange Rate Amount"
            ELSE
                Factor := 1;
            TotalAmt := TotalAmt + ROUND(CurrExchRate.ExchangeAmtFCYToLCYAdjmt("Detalle Prestamo".Fecha,
                                    '', "Detalle Prestamo"."A Pagar", Factor));
            TotalAmtCurrency := TotalAmtCurrency + "Detalle Prestamo"."A Pagar";
            TotalLineAmount := TotalLineAmount + "Detalle Prestamo"."A Pagar";
            MultiSalesLines := TRUE;
        END ELSE BEGIN

            WITH CFWorksheetLine2 DO BEGIN
                INIT;
                "Source Type" := CFWorksheetLine2."Source Type"::"Detalle Préstamos";
                "Shortcut Dimension 2 Code" := rCab."Global Dimension 1 Code";
                "Shortcut Dimension 1 Code" := rCab."Global Dimension 2 Code";
                // "Gen. Bus. Posting Group" := '';
                //"Account Type" := CFWorksheetLine2."Account Type"::Credit;
                "Source No." := Copystr(rCab."Código Del Prestamo", 1, 20);
                "Cod banco" := rCab.Banco;
                LiqAcc.RESET;
                LiqAcc.SETRANGE(LiqAcc."Banco Informes");
                LiqAcc.SETRANGE(LiqAcc."Source Type", LiqAcc."Source Type"::"Detalle Préstamos");
                LiqAcc.SETRANGE(LiqAcc."Cód Prestamo", "Detalle Prestamo"."Código Del Prestamo");
                if NOT LiqAcc.FINDFIRST THEN BEGIN
                    LiqAcc.SETRANGE(LiqAcc."Cód Prestamo");
                    LiqAcc.SETRANGE(LiqAcc."Cod banco", rCab.Banco);
                    if NOT LiqAcc.FINDFIRST THEN BEGIN
                        LiqAcc.SETRANGE(LiqAcc."Cod banco");
                        if rBanc.GET(rCab.Banco) THEN BEGIN
                            if rBanc."Name 2" = '' THEN rBanc."Name 2" := 'ZZZZZ';
                            LiqAcc.SETRANGE(LiqAcc."Banco Informes", rBanc."Name 2");
                        END ELSE
                            CurrReport.SKIP;
                    END;
                END;
                if NOT LiqAcc.FINDFIRST THEN
                    CurrReport.SKIP;
                "Cash flow Account No." := LiqAcc."No.";
                Description := COPYSTR(STRSUBSTNO('Cuota Prestamo %1 %2', rCab."Código Del Prestamo",
                                        FORMAT("Detalle Prestamo".Fecha)), 1, MAXSTRLEN(CFWorksheetLine2.Description));
                "Due Date" := "Detalle Prestamo".Fecha;
                "Cash flow Date" := "Detalle Prestamo".Fecha;
                "Fecha Registro" := DummyDate;
                "Document No." := COPYSTR("Detalle Prestamo"."Código Del Prestamo", 1,
                MAXSTRLEN("Document No."));


                "Amount (LCY)" := "Detalle Prestamo"."A Pagar";
                CurrExchRate.SETRANGE("Currency Code", '');
                CurrExchRate.SETRANGE("Starting Date", 0D, "Detalle Prestamo".Fecha);
                if CurrExchRate.FIND('+') THEN
                    Factor := CurrExchRate."Exchange Rate Amount"
                ELSE
                    Factor := 1;
                "Amount (LCY)" := ROUND(CurrExchRate.ExchangeAmtFCYToLCYAdjmt("Detalle Prestamo".Fecha,
                        '', "Detalle Prestamo"."A Pagar", Factor));
                "Payment Discount" := 0;
                // if "Cash Flow Forecast"."Consider Discount" THEN BEGIN
                // Amount := ROUND(Amount - Amount * "Payment Discount");
                // "Amount (Currency)" := ROUND("Amount (Currency)" - "Amount (Currency)" * "Payment Discount");
                // END;

                if Summarized AND MultiSalesLines THEN BEGIN
                    "Amount (LCY)" := "Amount (LCY)" + TotalAmt;
                    //"Amount (Currency)" := "Amount (Currency)" + TotalAmtCurrency;
                    "Detalle Prestamo"."A Pagar" := "Detalle Prestamo"."A Pagar" + TotalLineAmount;
                    MultiSalesLines := FALSE;
                    TotalAmt := 0;
                    TotalAmtCurrency := 0;
                    TotalLineAmount := 0;
                END;



                //"Currency Code" := '';

                if LiqAcc."Banco Informes" <> '' THEN
                    "Nombre Banco" := LiqAcc."Banco Informes"
                ELSE
                    "Nombre Banco" := NBanco("Cod banco");
                "Amount (LCY)" := -"Amount (LCY)";
                if ("Amount (LCY)" <> 0)
                AND (("Detalle Prestamo".Fecha >= DueDateD) AND
                ("Detalle Prestamo".Fecha <= DueDateF)) THEN BEGIN
                    if "Detalle Prestamo".Liquidado = FALSE THEN
                        InsertLiqLine();
                    // DocDim.RESET;
                    // DocDim.SETRANGE("Table ID",DATABASE::"Cabecera Prestamo");
                    // DocDim.SETRANGE("Document No.",
                    // COPYSTR("Código Del Prestamo",1,MAXSTRLEN("Document No.")));
                    // LiqDimMgt.MoveDocDimToJnlLineDim(DocDim,JnlLineDim,DATABASE::"Liq. Journal Line", LiqLine."Journal Template Name",
                    //                                 LiqLine."Journal Batch Name",LiqLine."Line No.",0);
                    CFWorksheetLine2.Validate("Shortcut Dimension 1 Code", rCab."Global Dimension 1 Code");
                    CFWorksheetLine2.Validate("Shortcut Dimension 2 Code", rCab."Global Dimension 2 Code");
                    CFWorksheetLine2.Validate("Shortcut Dimension 3 Code", rCab."Global Dimension 3 Code");
                    CFWorksheetLine2.Validate("Shortcut Dimension 4 Code", rCab."Global Dimension 4 Code");
                    CFWorksheetLine2.Validate("Shortcut Dimension 5 Code", rCab."Global Dimension 5 Code");


                END;
            END;
        END;
    end;

    local procedure InsertCfLineForRenting()
    var
        InsertConditionHasBeenMetAlready: Boolean;
        rCab: Record "Cabecera Prestamo";
        PresLine2: Record "Detalle Prestamo";
        rBanc: Record "Bank Account";
        Factor: Decimal;
        TotalAmtCurrency: Decimal;
        TotalLineAmount: Decimal;
    begin
        if NOT rCab.GET("Detalle Renting"."Código Del Prestamo") THEN
            CurrReport.SKIP;
        if rCab.Renting = false Then CurrReport.Skip();

        if rCab.Empresa <> '' THEN CurrReport.SKIP;
        PresLine2 := "Detalle Renting";

        if Summarized AND (PresLine2.NEXT <> 0) AND (PresLine2."Código Del Prestamo" =
        "Detalle Renting"."Código Del Prestamo") THEN BEGIN
            CurrExchRate.SETRANGE("Currency Code", '');
            CurrExchRate.SETRANGE("Starting Date", 0D, "Detalle Renting".Fecha);
            if CurrExchRate.FIND('+') THEN
                Factor := CurrExchRate."Exchange Rate Amount"
            ELSE
                Factor := 1;
            TotalAmt := TotalAmt + ROUND(CurrExchRate.ExchangeAmtFCYToLCYAdjmt("Detalle Renting".Fecha,
                                    '', "Detalle Renting"."A Pagar", Factor));
            TotalAmtCurrency := TotalAmtCurrency + "Detalle Renting"."A Pagar";
            TotalLineAmount := TotalLineAmount + "Detalle Renting"."A Pagar";
            MultiSalesLines := TRUE;
        END ELSE BEGIN

            WITH CFWorksheetLine2 DO BEGIN
                INIT;
                "Source Type" := CFWorksheetLine2."Source Type"::Rentings;
                "Shortcut Dimension 2 Code" := rCab."Global Dimension 1 Code";
                "Shortcut Dimension 1 Code" := rCab."Global Dimension 2 Code";
                // "Gen. Bus. Posting Group" := '';
                //"Account Type" := CFWorksheetLine2."Account Type"::Credit;
                "Source No." := Copystr(rCab."Código Del Prestamo", 1, 20);
                "Cod banco" := rCab.Banco;
                LiqAcc.RESET;
                LiqAcc.SETRANGE(LiqAcc."Banco Informes");
                LiqAcc.SETRANGE(LiqAcc."Source Type", LiqAcc."Source Type"::Rentings);
                LiqAcc.SETRANGE(LiqAcc."Cód Prestamo", "Detalle Renting"."Código Del Prestamo");
                if NOT LiqAcc.FINDFIRST THEN BEGIN
                    LiqAcc.SETRANGE(LiqAcc."Cód Prestamo");
                    LiqAcc.SETRANGE(LiqAcc."Cod banco", rCab.Banco);
                    if NOT LiqAcc.FINDFIRST THEN BEGIN
                        LiqAcc.SETRANGE(LiqAcc."Cod banco");
                        if rBanc.GET(rCab.Banco) THEN BEGIN
                            if rBanc."Name 2" = '' THEN rBanc."Name 2" := 'ZZZZZ';
                            LiqAcc.SETRANGE(LiqAcc."Banco Informes", rBanc."Name 2");
                        END ELSE
                            CurrReport.SKIP;
                    END;
                END;
                if NOT LiqAcc.FINDFIRST THEN
                    CurrReport.SKIP;
                "Cash flow Account No." := LiqAcc."No.";
                Description := COPYSTR(STRSUBSTNO('Cuota Renting %1 %2', rCab."Código Del Prestamo",
                                        FORMAT("Detalle Renting".Fecha)), 1, MAXSTRLEN(CFWorksheetLine2.Description));
                "Due Date" := "Detalle Renting".Fecha;
                "Cash flow Date" := "Detalle Renting".Fecha;
                "Fecha Registro" := DummyDate;
                "Document No." := COPYSTR("Detalle Renting"."Código Del Prestamo", 1,
                MAXSTRLEN("Document No."));


                "Amount (LCY)" := "Detalle Renting"."A Pagar";
                CurrExchRate.SETRANGE("Currency Code", '');
                CurrExchRate.SETRANGE("Starting Date", 0D, "Detalle Renting".Fecha);
                if CurrExchRate.FIND('+') THEN
                    Factor := CurrExchRate."Exchange Rate Amount"
                ELSE
                    Factor := 1;
                "Amount (LCY)" := ROUND(CurrExchRate.ExchangeAmtFCYToLCYAdjmt("Detalle Renting".Fecha,
                        '', "Detalle Renting"."A Pagar", Factor));
                "Payment Discount" := 0;
                // if "Cash Flow Forecast"."Consider Discount" THEN BEGIN
                // Amount := ROUND(Amount - Amount * "Payment Discount");
                // "Amount (Currency)" := ROUND("Amount (Currency)" - "Amount (Currency)" * "Payment Discount");
                // END;

                if Summarized AND MultiSalesLines THEN BEGIN
                    "Amount (LCY)" := "Amount (LCY)" + TotalAmt;
                    //"Amount (Currency)" := "Amount (Currency)" + TotalAmtCurrency;
                    "Detalle Renting"."A Pagar" := "Detalle Renting"."A Pagar" + TotalLineAmount;
                    MultiSalesLines := FALSE;
                    TotalAmt := 0;
                    TotalAmtCurrency := 0;
                    TotalLineAmount := 0;
                END;



                //"Currency Code" := '';

                if LiqAcc."Banco Informes" <> '' THEN
                    "Nombre Banco" := LiqAcc."Banco Informes"
                ELSE
                    "Nombre Banco" := NBanco("Cod banco");
                "Amount (LCY)" := -"Amount (LCY)";
                if ("Amount (LCY)" <> 0)
                AND (("Detalle Renting".Fecha >= DueDateD) AND
                ("Detalle Renting".Fecha <= DueDateF)) THEN BEGIN
                    if "Detalle Renting".Facturado = FALSE THEN
                        InsertLiqLine();
                    // DocDim.RESET;
                    // DocDim.SETRANGE("Table ID",DATABASE::"Cabecera Prestamo");
                    // DocDim.SETRANGE("Document No.",
                    // COPYSTR("Código Del Prestamo",1,MAXSTRLEN("Document No.")));
                    // LiqDimMgt.MoveDocDimToJnlLineDim(DocDim,JnlLineDim,DATABASE::"Liq. Journal Line", LiqLine."Journal Template Name",
                    //                                 LiqLine."Journal Batch Name",LiqLine."Line No.",0);
                    CFWorksheetLine2.Validate("Shortcut Dimension 1 Code", rCab."Global Dimension 1 Code");
                    CFWorksheetLine2.Validate("Shortcut Dimension 2 Code", rCab."Global Dimension 2 Code");
                    CFWorksheetLine2.Validate("Shortcut Dimension 3 Code", rCab."Global Dimension 3 Code");
                    CFWorksheetLine2.Validate("Shortcut Dimension 4 Code", rCab."Global Dimension 4 Code");
                    CFWorksheetLine2.Validate("Shortcut Dimension 5 Code", rCab."Global Dimension 5 Code");


                END;
            END;
        END;
    end;

    local procedure InsertCfLineForEmplazaMientos()
    var
        InsertConditionHasBeenMetAlready: Boolean;
        rCab: Record "Cabecera Prestamo";
        rBanc: Record "Bank Account";
        Factor: Decimal;
        TotalAmtCurrency: Decimal;
        TotalLineAmount: Decimal;
        PresLine2: Record "Mov. emplazamientos";
        PaymenthMetohod: Record "Payment Method";
        Text1140039: Label 'Vto emplaz. %1 %2';
    begin

        if "Movimientos Emplazamiento"."Nº Factura definitivo" <> '' THEN CurrReport.SKIP;
        PresLine2 := "Movimientos emplazamiento";


        WITH CFWorksheetLine2 DO BEGIN
            INIT;
            "Source Type" := CFWorksheetLine2."Source Type"::"Movimientos emplazamientos";
            "Shortcut Dimension 2 Code" := '';//rCab."Global Dimension 1 Code";
            "Shortcut Dimension 1 Code" := '';//rCab."Global Dimension 2 Code";
            "Source No." := "Movimientos emplazamiento"."Nº proveedor";
            "Associated Entry No." := "Movimientos emplazamiento"."Nº mov.";
            "Cod banco" := "Movimientos emplazamiento".Banco;//rCab.Banco;
            if "Movimientos emplazamiento"."Fecha prevista pago" < DueDateD THEN Atrasados := TRUE ELSE Atrasados := FALSE;
            LiqAcc.SETRANGE(LiqAcc."Source Type", LiqAcc."Source Type"::"Movimientos emplazamientos");
            PaymenthMetohod.SETRANGE(PaymenthMetohod."Forma de Pago Emplazamiento", "Movimientos emplazamiento"."Cod. Pago");
            if NOT PaymenthMetohod.FINDFIRST THEN PaymenthMetohod.INIT;
            LiqAcc.SETRANGE(LiqAcc."Payment Method Code", PaymenthMetohod.Code);
            if Atrasados THEN
                LiqAcc.SETRANGE(LiqAcc."Solo Atrasados", TRUE);
            if NOT LiqAcc.FINDFIRST THEN
                LiqAcc.SETRANGE(LiqAcc."Payment Method Code");
            if NOT LiqAcc.FINDFIRST THEN
                CurrReport.SKIP;
            "Cash Flow Account No." := LiqAcc."No.";
            Description := COPYSTR(STRSUBSTNO(Text1140039, "Movimientos emplazamiento"."Nº emplazamiento",
                                    FORMAT("Movimientos emplazamiento"."Fecha vencimiento")), 1, MAXSTRLEN(CfWorkSheetLine2.Description));
            "Due Date" := "Movimientos emplazamiento"."Fecha prevista pago";
            "Cash Flow Date" := "Movimientos emplazamiento"."Fecha prevista pago";
            "Fecha Registro" := DummyDate;
            "Document No." := "Movimientos emplazamiento"."Nº emplazamiento";
            "Amount (LCY)" := "Movimientos emplazamiento"."Importe pendiente";//+PresLine2."Importe pagado";
            Factor := 1;
            //Amount :="Mov. emplazamientos"."Importe pendiente";//,Factor));
            "Payment Discount" := 0;//"Amount (LCY)"* "Movimientos emplazamiento"."Discount %" / 100;
            if Summarized AND MultiSalesLines THEN BEGIN
                "Amount (LCY)" := "Amount (LCY)" + TotalAmt;
                //"Amount (Currency)" := "Amount (Currency)" + TotalAmtCurrency;
                //"Importe pendiente" := "Importe pendiente" + TotalLineAmount;
                MultiSalesLines := FALSE;
                TotalAmt := 0;
                TotalAmtCurrency := 0;
                TotalLineAmount := 0;
            END;
            //"Currency Code" := '';
            if LiqAcc."Banco Informes" <> '' THEN
                "Nombre Banco" := LiqAcc."Banco Informes"
            ELSE
                "Nombre Banco" := NBanco("Cod banco");
            PaymenthMetohod.SETRANGE(PaymenthMetohod."Forma de Pago Emplazamiento", "Movimientos emplazamiento"."Cod. Pago");
            if NOT PaymenthMetohod.FINDFIRST THEN PaymenthMetohod.INIT;

            if LiqAcc."Payment Method Code" <> '' THEN
                if LiqAcc."Payment Method Code" <> PaymenthMetohod.Code THEN "Amount (LCY)" := 0;
            "Amount (LCY)" := -"Amount (LCY)";
            if (("Amount (LCY)" <> 0) AND ("Movimientos emplazamiento"."Nº Factura definitivo" = ''))
            // AND (("Fecha vencimiento">=DueDateD) AND
            //  ("Fecha vencimiento"<=DueDateF))  
            THEN BEGIN
                InsertLiqLine();
            END;
        END;
        //END;
    end;

    local procedure InsertCFLineForTax(SourceTableNum: Integer)
    var
        TaxPayableDate: Date;
        SourceNo: Code[20];
        InsertConditionHasBeenMetAlready: Boolean;
    begin
        TaxPayableDate := GetTaxPayableDateFromSource(SourceTableNum);
        if IsDateBeforeStartOfCurrentPeriod(TaxPayableDate) or HasTaxBeenPaidOn(TaxPayableDate) then
            exit;
        SourceNo := Format(SourceTableNum);
        if Summarized and (TaxLastSourceTableNumProcessed <> SourceTableNum) and
           (TaxLastPayableDateProcessed <> TaxPayableDate)
        then begin
            TotalAmt += GetTaxAmountFromSource(SourceTableNum);
            MultiSalesLines := true;
        end else
            if (TempCFWorksheetLine."Source Type" = TempCFWorksheetLine."Source Type"::Tax) and
               (TempCFWorksheetLine."Source No." = SourceNo) and
               (TempCFWorksheetLine."Document Date" = TaxPayableDate)
            then begin
                InsertConditionHasBeenMetAlready := InsertConditionMet;
                TempCFWorksheetLine."Amount (LCY)" += GetTaxAmountFromSource(SourceTableNum);
                InsertOrModifyCFLine(InsertConditionHasBeenMetAlready);
            end else
                with CFWorksheetLine2 do begin
                    Init();
                    "Source Type" := "Source Type"::Tax;
                    "Source No." := SourceNo;
                    "Document Type" := "Document Type"::" ";
                    "Document Date" := TaxPayableDate;

                    "Shortcut Dimension 1 Code" := '';
                    "Shortcut Dimension 2 Code" := '';
                    "Cash Flow Account No." := CFSetup."Tax CF Account No.";
                    Description := GetDescriptionForTaxCashFlowLine(SourceTableNum);
                    SetCashFlowDate(CFWorksheetLine2, "Document Date");
                    "Document No." := '';
                    "Amount (LCY)" := GetTaxAmountFromSource(SourceTableNum);

                    if Summarized and MultiSalesLines and (TaxLastSourceTableNumProcessed = SourceTableNum) then begin
                        "Amount (LCY)" := "Amount (LCY)" + TotalAmt;
                        MultiSalesLines := false;
                        TotalAmt := 0;
                    end;

                    InsertTempCFWorksheetLine(0);
                end;

        TaxLastSourceTableNumProcessed := SourceTableNum;
        TaxLastPayableDateProcessed := TaxPayableDate;
    end;

    local procedure InsertCFLineForAzureAIForecast(SourceTableNum: Integer)
    begin
        if "Cash Flow Azure AI Buffer"."Delta %" > CFSetup."Variance %" then
            exit;

        with CFWorksheetLine2 do begin
            Init();
            "Source Type" := "Source Type"::"Azure AI";
            "Source No." := Format(SourceTableNum);
            "Document Type" := "Document Type"::" ";
            "Document Date" := "Cash Flow Azure AI Buffer"."Period Start";
            SetCashFlowDate(CFWorksheetLine2, "Document Date");
            "Amount (LCY)" := "Cash Flow Azure AI Buffer".Amount;

            case "Cash Flow Azure AI Buffer"."Group Id" of
                XRECEIVABLESTxt:
                    begin
                        "Cash Flow Account No." := CFSetup."Receivables CF Account No.";
                        Description :=
                          StrSubstNo(
                            AzureAIForecastDescriptionTxt, LowerCase(XRECEIVABLESTxt), "Cash Flow Azure AI Buffer"."Period Start",
                            Round("Cash Flow Azure AI Buffer".Delta));
                    end;
                XPAYABLESTxt:
                    begin
                        "Cash Flow Account No." := CFSetup."Payables CF Account No.";
                        Description :=
                          StrSubstNo(
                            AzureAIForecastDescriptionTxt, LowerCase(XPAYABLESTxt), "Cash Flow Azure AI Buffer"."Period Start",
                            Round("Cash Flow Azure AI Buffer".Delta));
                    end;
                XPAYABLESCORRECTIONTxt:
                    if ConsiderSource["Source Type"::Payables.AsInteger()] then begin
                        "Cash Flow Account No." := CFSetup."Payables CF Account No.";
                        Description := StrSubstNo(AzureAICorrectionDescriptionTxt, LowerCase(XPAYABLESTxt));
                    end else
                        exit;
                XRECEIVABLESCORRECTIONTxt:
                    if ConsiderSource["Source Type"::Receivables.AsInteger()] then begin
                        "Cash Flow Account No." := CFSetup."Receivables CF Account No.";
                        Description := StrSubstNo(AzureAICorrectionDescriptionTxt, LowerCase(XRECEIVABLESTxt))
                    end else
                        exit;
                XPURCHORDERSTxt:
                    if ConsiderSource["Source Type"::"Purchase Orders".AsInteger()] then begin
                        "Cash Flow Account No." := CFSetup."Purch. Order CF Account No.";
                        Description := StrSubstNo(AzureAIOrdersCorrectionDescriptionTxt, LowerCase(XPURCHORDERSTxt))
                    end else
                        exit;
                XSALESORDERSTxt:
                    if ConsiderSource["Source Type"::"Sales Orders".AsInteger()] then begin
                        "Cash Flow Account No." := CFSetup."Sales Order CF Account No.";
                        Description := StrSubstNo(AzureAIOrdersCorrectionDescriptionTxt, LowerCase(XSALESORDERSTxt))
                    end else
                        exit;
                XTAXRECEIVABLESTxt:
                    if ConsiderSource["Source Type"::Tax.AsInteger()] then begin
                        "Cash Flow Account No." := CFSetup."Tax CF Account No.";
                        Description :=
                          StrSubstNo(
                            AzureAIForecastTaxDescriptionTxt, LowerCase(XRECEIVABLESTxt), "Cash Flow Azure AI Buffer"."Period Start",
                            Round("Cash Flow Azure AI Buffer".Delta))
                    end else
                        exit;
                XTAXPAYABLESTxt:
                    if ConsiderSource["Source Type"::Tax.AsInteger()] then begin
                        "Cash Flow Account No." := CFSetup."Tax CF Account No.";
                        Description :=
                          StrSubstNo(
                            AzureAIForecastTaxDescriptionTxt, LowerCase(XPAYABLESTxt), "Cash Flow Azure AI Buffer"."Period Start",
                            Round("Cash Flow Azure AI Buffer".Delta));
                    end else
                        exit;
                XTAXPAYABLESCORRECTIONTxt:
                    if ConsiderSource["Source Type"::Tax.AsInteger()] then begin
                        "Cash Flow Account No." := CFSetup."Tax CF Account No.";
                        Description := StrSubstNo(AzureAICorrectionTaxDescriptionTxt, LowerCase(XPAYABLESTxt));
                    end else
                        exit;
                XTAXRECEIVABLESCORRECTIONTxt:
                    if ConsiderSource["Source Type"::Tax.AsInteger()] then begin
                        "Cash Flow Account No." := CFSetup."Tax CF Account No.";
                        Description := StrSubstNo(AzureAICorrectionTaxDescriptionTxt, LowerCase(XRECEIVABLESTxt))
                    end else
                        exit;
                XTAXPURCHORDERSTxt:
                    if ConsiderSource["Source Type"::Tax.AsInteger()] then begin
                        "Cash Flow Account No." := CFSetup."Tax CF Account No.";
                        Description := StrSubstNo(AzureAIOrdersTaxCorrectionDescriptionTxt, LowerCase(XPURCHORDERSTxt))
                    end else
                        exit;
                XTAXSALESORDERSTxt:
                    if ConsiderSource["Source Type"::Tax.AsInteger()] then begin
                        "Cash Flow Account No." := CFSetup."Tax CF Account No.";
                        Description := StrSubstNo(AzureAIOrdersTaxCorrectionDescriptionTxt, LowerCase(XSALESORDERSTxt))
                    end else
                        exit;
            end;
        end;

        InsertTempCFWorksheetLine(0);
    end;

    local procedure InsertOrModifyCFLine(InsertConditionHasBeenMetAlready: Boolean)
    begin
        CFWorksheetLine2."Amount (LCY)" += TempCFWorksheetLine."Amount (LCY)";
        if InsertConditionHasBeenMetAlready then
            TempCFWorksheetLine.Modify
        else
            InsertTempCFWorksheetLine(0);
    end;

    local procedure GetSubPostingGLAccounts(var GLAccount: Record "G/L Account"; var TempGLAccount: Record "G/L Account" temporary)
    var
        SubGLAccount: Record "G/L Account";
    begin
        if not GLAccount.FindSet() then
            exit;

        repeat
            case GLAccount."Account Type" of
                GLAccount."Account Type"::Posting:
                    begin
                        TempGLAccount.Init();
                        TempGLAccount.TransferFields(GLAccount);
                        if TempGLAccount.Insert() then;
                    end;
                GLAccount."Account Type"::Heading:
                    begin
                        SubGLAccount.SetFilter("No.", GLAccount.Totaling);
                        SubGLAccount.FilterGroup := 2;
                        SubGLAccount.SetFilter("No.", '<>%1', GLAccount."No.");
                        SubGLAccount.FilterGroup := 0;
                        GetSubPostingGLAccounts(SubGLAccount, TempGLAccount);
                    end;
            end;
        until GLAccount.Next = 0;
    end;

    local procedure SetCashFlowDate(var CashFlowWorksheetLine: Record "Cash Flow Worksheet Line"; CashFlowDate: Date)
    begin
        CashFlowWorksheetLine."Cash Flow Date" := CashFlowDate;
        if CashFlowDate < WorkDate then begin
            if SelectionCashFlowForecast."Overdue CF Dates to Work Date" then
                CashFlowWorksheetLine."Cash Flow Date" := WorkDate;
            CashFlowWorksheetLine.Overdue := true;
        end
    end;

    local procedure CalculateLineAmountForPurchaseLine(PurchHeader2: Record "Purchase Header"; PurchaseLine: Record "Purchase Line"): Decimal
    var
        PrepmtAmtInvLCY: Decimal;
    begin
        if PurchHeader2."Currency Code" <> '' then begin
            Currency.Get(PurchHeader2."Currency Code");
            PrepmtAmtInvLCY :=
              Round(
                CurrExchRate.ExchangeAmtFCYToLCY(
                  PurchHeader2."Posting Date", PurchHeader2."Currency Code",
                  PurchaseLine."Prepmt. Amt. Inv.", PurchHeader2."Currency Factor"),
                Currency."Amount Rounding Precision");
        end else
            PrepmtAmtInvLCY := PurchaseLine."Prepmt. Amt. Inv.";

        Currency.InitRoundingPrecision;
        if PurchHeader2."Prices Including VAT" then
            exit(-(GetPurchaseAmountForCFLine(PurchaseLine) - PrepmtAmtInvLCY));
        exit(
          -(GetPurchaseAmountForCFLine(PurchaseLine) -
            (PrepmtAmtInvLCY +
             Round(PrepmtAmtInvLCY * PurchaseLine."VAT %" / 100, Currency."Amount Rounding Precision", Currency.VATRoundingDirection))));
    end;

    local procedure CalculateLineAmountForSalesLine(SalesHeader2: Record "Sales Header"; SalesLine: Record "Sales Line"): Decimal
    var
        PrepmtAmtInvLCY: Decimal;
    begin
        if SalesHeader2."Currency Code" <> '' then begin
            Currency.Get(SalesHeader2."Currency Code");
            PrepmtAmtInvLCY :=
              Round(
                CurrExchRate.ExchangeAmtFCYToLCY(
                  SalesHeader2."Posting Date", SalesHeader2."Currency Code",
                  SalesLine."Prepmt. Amt. Inv.", SalesHeader2."Currency Factor"),
                Currency."Amount Rounding Precision");
        end else
            PrepmtAmtInvLCY := SalesLine."Prepmt. Amt. Inv.";

        Currency.InitRoundingPrecision;
        if SalesHeader2."Prices Including VAT" then
            exit(GetSalesAmountForCFLine(SalesLine) - PrepmtAmtInvLCY);
        exit(
          GetSalesAmountForCFLine(SalesLine) -
          (PrepmtAmtInvLCY +
           Round(PrepmtAmtInvLCY * SalesLine."VAT %" / 100, Currency."Amount Rounding Precision", Currency.VATRoundingDirection)));
    end;

    local procedure CalculateLineAmountForServiceLine(ServiceLine: Record "Service Line"): Decimal
    begin
        exit(GetServiceAmountForCFLine(ServiceLine));
    end;

    local procedure NoOptionsChosen(): Boolean
    var
        SourceType: Integer;
    begin
        for SourceType := 1 to ArrayLen(ConsiderSource) do
            if ConsiderSource[SourceType] then
                exit(false);
        exit(true);
    end;

    /// <summary>
    /// InitializeRequest.
    /// </summary>
    /// <param name="NewConsiderSource">array[23] of Boolean.</param>
    /// <param name="CFNo">Code[20].</param>
    /// <param name="NewGLBudgetName">Code[10].</param>
    /// <param name="GroupByDocumentType">Boolean.</param>
    procedure InitializeRequest(NewConsiderSource: array[23] of Boolean; CFNo: Code[20]; NewGLBudgetName: Code[10]; GroupByDocumentType: Boolean)
    begin
        CopyArray(ConsiderSource, NewConsiderSource, 1);
        CashFlowNo := CFNo;
        GLBudgName := NewGLBudgetName;
        Summarized := GroupByDocumentType;
    end;

    local procedure InsertManualData(ExecutionDate: Date; CashFlowForecast: Record "Cash Flow Forecast"; ManualAmount: Decimal)
    begin
        if ((CashFlowForecast."Manual Payments From" <> 0D) and
            (ExecutionDate < CashFlowForecast."Manual Payments From")) or
           ((CashFlowForecast."Manual Payments To" <> 0D) and
            (ExecutionDate > CashFlowForecast."Manual Payments To"))
        then
            exit;

        with CFWorksheetLine2 do begin
            SetCashFlowDate(CFWorksheetLine2, ExecutionDate);
            "Amount (LCY)" := ManualAmount;
            InsertTempCFWorksheetLine(0);
        end;
    end;

    local procedure SplitSalesInv(var SalesHeader: Record "Sales Header"; var CFJournalLine3: Record "Cash Flow Worksheet Line"; TotalAmount: Decimal; VATAmount: Decimal)
    var
        Installment: Record Installment;
        DueDateAdjust: Codeunit "Due Date-Adjust";
        CurrDocNo: Integer;
        CurrencyFactor: Decimal;
        RemainingAmount: Decimal;
        TotalPerc: Decimal;
        NextDueDate: Date;
    begin
        with SalesHeader do begin
            if not PaymentMethod.Get("Payment Method Code") then
                exit;
            if (not PaymentMethod."Create Bills") and (not PaymentMethod."Invoices to Cartera") then
                exit;
            if PaymentMethod."Create Bills" and ("Document Type" = "Document Type"::"Credit Memo") then
                Error(
                  Text1100000,
                  FieldCaption("Payment Method Code"));

            if "Currency Code" = '' then
                CurrencyFactor := 1
            else
                CurrencyFactor := "Currency Factor";

            SalesSetup.Get();
            TestField("Payment Terms Code");
            PaymentTerms.Get("Payment Terms Code");
            PaymentTerms.CalcFields("No. of Installments");
            if PaymentTerms."No. of Installments" = 0 then
                PaymentTerms."No. of Installments" := 1;
            if PaymentMethod."Invoices to Cartera" and (PaymentTerms."No. of Installments" > 1) then
                Error(
                  Text1100001,
                  PaymentTerms.FieldCaption("No. of Installments"),
                  PaymentMethod.FieldCaption("Invoices to Cartera"),
                  PaymentMethod.TableCaption);

            RemainingAmount := TotalAmount;

            // create bills
            if "Currency Code" = '' then begin
                Currency."Invoice Rounding Precision" := GLSetup."Inv. Rounding Precision (LCY)";
                Currency."Invoice Rounding Type" := GLSetup."Inv. Rounding Type (LCY)";
                Currency."Amount Rounding Precision" := GLSetup."Amount Rounding Precision";
                if SalesSetup."Invoice Rounding" then
                    GLSetup.TestField("Inv. Rounding Precision (LCY)")
                else
                    GLSetup.TestField("Amount Rounding Precision");
            end else begin
                Currency.Get("Currency Code");
                if SalesSetup."Invoice Rounding" then
                    Currency.TestField("Invoice Rounding Precision")
                else
                    Currency.TestField("Amount Rounding Precision");
            end;
            TotalAmount := RoundAmt(TotalAmount);

            Installment.SetRange("Payment Terms Code", PaymentTerms.Code);
            if Installment.Find('-') then;

            NextDueDate := "Due Date";

            for CurrDocNo := 1 to PaymentTerms."No. of Installments" do begin
                CFJournalLine3."Cash Flow Date" := NextDueDate;
                CFJournalLine3.Description :=
                  CopyStr(StrSubstNo(Text1100004, Format(CFJournalLine3."Cash Flow Date"),
                      "Sell-to Customer Name"), 1, MaxStrLen(CFJournalLine3.Description));
                DueDateAdjust.SalesAdjustDueDate(
                  CFJournalLine3."Cash Flow Date", "Document Date", PaymentTerms.CalculateMaxDueDate("Document Date"), "Bill-to Customer No.");
                if CurrDocNo < PaymentTerms."No. of Installments" then begin
                    Installment.TestField("% of Total");
                    if CurrDocNo = 1 then begin
                        TotalPerc := Installment."% of Total";
                        case PaymentTerms."VAT distribution" of
                            PaymentTerms."VAT distribution"::"First Installment":
                                CFJournalLine3."Amount (LCY)" := RoundAmt(
                                    (TotalAmount - VATAmount) * Installment."% of Total" / 100 + VATAmount);
                            PaymentTerms."VAT distribution"::"Last Installment":
                                CFJournalLine3."Amount (LCY)" := RoundAmt(
                                    (TotalAmount - VATAmount) * Installment."% of Total" / 100);
                            PaymentTerms."VAT distribution"::Proportional:
                                CFJournalLine3."Amount (LCY)" := RoundAmt(
                                    TotalAmount * Installment."% of Total" / 100);
                        end;
                    end else begin
                        TotalPerc := TotalPerc + Installment."% of Total";
                        if TotalPerc >= 100 then
                            Error(
                              Text1100005,
                              Installment.FieldCaption("% of Total"),
                              PaymentTerms.TableCaption,
                              PaymentTerms.Code);
                        case PaymentTerms."VAT distribution" of
                            PaymentTerms."VAT distribution"::"First Installment",
                          PaymentTerms."VAT distribution"::"Last Installment":
                                CFJournalLine3."Amount (LCY)" := RoundAmt(
                                    (TotalAmount - VATAmount) * Installment."% of Total" / 100);
                            PaymentTerms."VAT distribution"::Proportional:
                                CFJournalLine3."Amount (LCY)" := RoundAmt(
                                    TotalAmount * Installment."% of Total" / 100);
                        end;
                    end;
                    RemainingAmount := RemainingAmount - CFJournalLine3."Amount (LCY)";

                    Installment.TestField("Gap between Installments");
                    NextDueDate := CalcDate(Installment."Gap between Installments", NextDueDate);
                    Installment.Next;
                end else
                    CFJournalLine3."Amount (LCY)" := RemainingAmount;

                if PaymentMethod."Create Bills" and (CFJournalLine3."Amount (LCY)" <> 0) then
                    InsertTempCFWorksheetLine(0);
            end;
        end;
    end;

    /// <summary>
    /// SplitPurchInv.
    /// </summary>
    /// <param name="PurchHeader">VAR Record "Purchase Header".</param>
    /// <param name="CFJournalLine3">VAR Record "Cash Flow Worksheet Line".</param>
    /// <param name="TotalAmount">Decimal.</param>
    /// <param name="VATAmount">Decimal.</param>
    //[Scope('OnPrem')]
    procedure SplitPurchInv(var PurchHeader: Record "Purchase Header"; var CFJournalLine3: Record "Cash Flow Worksheet Line"; TotalAmount: Decimal; VATAmount: Decimal)
    var
        Installment: Record Installment;
        DueDateAdjust: Codeunit "Due Date-Adjust";
        CurrDocNo: Integer;
        CurrencyFactor: Decimal;
        RemainingAmount: Decimal;
        TotalPerc: Decimal;
        NextDueDate: Date;
    begin
        with PurchHeader do begin
            if not PaymentMethod.Get("Payment Method Code") then
                exit;
            if (not PaymentMethod."Create Bills") and (not PaymentMethod."Invoices to Cartera") then
                exit;
            if PaymentMethod."Create Bills" and ("Document Type" = "Document Type"::"Credit Memo") then
                Error(
                  Text1100000,
                  FieldCaption("Payment Method Code"));

            if "Currency Code" = '' then
                CurrencyFactor := 1
            else
                CurrencyFactor := "Currency Factor";

            TestField("Payment Terms Code");
            PaymentTerms.Get("Payment Terms Code");
            PaymentTerms.CalcFields("No. of Installments");
            if PaymentTerms."No. of Installments" = 0 then
                PaymentTerms."No. of Installments" := 1;
            if PaymentMethod."Invoices to Cartera" and (PaymentTerms."No. of Installments" > 1) then
                Error(
                  Text1100001,
                  PaymentTerms.FieldCaption("No. of Installments"),
                  PaymentMethod.FieldCaption("Invoices to Cartera"),
                  PaymentMethod.TableCaption);

            RemainingAmount := TotalAmount;

            // create bills
            if "Currency Code" = '' then begin
                Currency."Invoice Rounding Precision" := GLSetup."Inv. Rounding Precision (LCY)";
                Currency."Invoice Rounding Type" := GLSetup."Inv. Rounding Type (LCY)";
                Currency."Amount Rounding Precision" := GLSetup."Amount Rounding Precision";
                if PurchSetup."Invoice Rounding" then
                    GLSetup.TestField("Inv. Rounding Precision (LCY)")
                else
                    GLSetup.TestField("Amount Rounding Precision");
            end else begin
                Currency.Get("Currency Code");
                if SalesSetup."Invoice Rounding" then
                    Currency.TestField("Invoice Rounding Precision")
                else
                    Currency.TestField("Amount Rounding Precision");
            end;
            TotalAmount := RoundAmt(TotalAmount);

            if PaymentTerms."No. of Installments" > 0 then begin
                Installment.SetRange("Payment Terms Code", PaymentTerms.Code);
                if Installment.Find('-') then;
            end;

            NextDueDate := "Due Date";

            for CurrDocNo := 1 to PaymentTerms."No. of Installments" do begin
                CFJournalLine3."Cash Flow Date" := NextDueDate;
                CFJournalLine3.Description :=
                  CopyStr(StrSubstNo(Text1100006, Format(CFJournalLine3."Cash Flow Date"),
                      "Buy-from Vendor Name"), 1, MaxStrLen(CFJournalLine3.Description));
                DueDateAdjust.PurchAdjustDueDate(
                  CFJournalLine3."Cash Flow Date", "Document Date", PaymentTerms.CalculateMaxDueDate("Document Date"), "Pay-to Vendor No.");
                if CurrDocNo < PaymentTerms."No. of Installments" then begin
                    Installment.TestField("% of Total");
                    if CurrDocNo = 1 then begin
                        TotalPerc := Installment."% of Total";
                        case PaymentTerms."VAT distribution" of
                            PaymentTerms."VAT distribution"::"First Installment":
                                CFJournalLine3."Amount (LCY)" := Round(
                                    (TotalAmount - VATAmount) * Installment."% of Total" / 100 + VATAmount);
                            PaymentTerms."VAT distribution"::"Last Installment":
                                CFJournalLine3."Amount (LCY)" := Round(
                                    (TotalAmount - VATAmount) * Installment."% of Total" / 100);
                            PaymentTerms."VAT distribution"::Proportional:
                                CFJournalLine3."Amount (LCY)" := Round(
                                    TotalAmount * Installment."% of Total" / 100);
                        end;
                    end else begin
                        TotalPerc := TotalPerc + Installment."% of Total";
                        if TotalPerc >= 100 then
                            Error(
                              Text1100005,
                              Installment.FieldCaption("% of Total"),
                              PaymentTerms.TableCaption,
                              PaymentTerms.Code);
                        case PaymentTerms."VAT distribution" of
                            PaymentTerms."VAT distribution"::"First Installment",
                          PaymentTerms."VAT distribution"::"Last Installment":
                                CFJournalLine3."Amount (LCY)" := Round(
                                    (TotalAmount - VATAmount) * Installment."% of Total" / 100);
                            PaymentTerms."VAT distribution"::Proportional:
                                CFJournalLine3."Amount (LCY)" := Round(
                                    TotalAmount * Installment."% of Total" / 100);
                        end;
                    end;
                    RemainingAmount := RemainingAmount - CFJournalLine3."Amount (LCY)";
                    Installment.TestField("Gap between Installments");
                    NextDueDate := CalcDate(Installment."Gap between Installments", NextDueDate);
                    Installment.Next;
                end else
                    CFJournalLine3."Amount (LCY)" := RemainingAmount;

                if PaymentMethod."Create Bills" and (CFJournalLine3."Amount (LCY)" <> 0) then
                    InsertTempCFWorksheetLine(0);
            end;
        end;
    end;

    /// <summary>
    /// SplitServInv.
    /// </summary>
    /// <param name="ServHeader">VAR Record "Service Header".</param>
    /// <param name="CFJournalLine3">VAR Record "Cash Flow Worksheet Line".</param>
    /// <param name="TotalAmount">Decimal.</param>
    /// <param name="VATAmount">Decimal.</param>
    //[Scope('OnPrem')]
    procedure SplitServInv(var ServHeader: Record "Service Header"; var CFJournalLine3: Record "Cash Flow Worksheet Line"; TotalAmount: Decimal; VATAmount: Decimal)
    var
        Installment: Record Installment;
        DueDateAdjust: Codeunit "Due Date-Adjust";
        CurrDocNo: Integer;
        CurrencyFactor: Decimal;
        RemainingAmount: Decimal;
        TotalPerc: Decimal;
        NextDueDate: Date;
    begin
        with ServHeader do begin
            if not PaymentMethod.Get("Payment Method Code") then
                exit;
            if (not PaymentMethod."Create Bills") and (not PaymentMethod."Invoices to Cartera") then
                exit;
            if PaymentMethod."Create Bills" and ("Document Type" = "Document Type"::"Credit Memo") then
                Error(
                  Text1100000,
                  FieldCaption("Payment Method Code"));

            if ServiceHeader."Currency Code" = '' then
                CurrencyFactor := 1
            else
                CurrencyFactor := ServiceHeader."Currency Factor";

            TestField("Payment Terms Code");
            PaymentTerms.Get("Payment Terms Code");
            PaymentTerms.CalcFields("No. of Installments");
            if PaymentTerms."No. of Installments" = 0 then
                PaymentTerms."No. of Installments" := 1;
            if PaymentMethod."Invoices to Cartera" and (PaymentTerms."No. of Installments" > 1) then
                Error(
                  Text1100001,
                  PaymentTerms.FieldCaption("No. of Installments"),
                  PaymentMethod.FieldCaption("Invoices to Cartera"),
                  PaymentMethod.TableCaption);

            RemainingAmount := TotalAmount;

            // create bills
            if "Currency Code" = '' then begin
                Currency."Invoice Rounding Precision" := GLSetup."Inv. Rounding Precision (LCY)";
                Currency."Invoice Rounding Type" := GLSetup."Inv. Rounding Type (LCY)";
                Currency."Amount Rounding Precision" := GLSetup."Amount Rounding Precision";
            end else
                Currency.Get("Currency Code");
            TotalAmount := RoundAmt(TotalAmount);

            if PaymentTerms."No. of Installments" > 0 then begin
                Installment.SetRange("Payment Terms Code", PaymentTerms.Code);
                if Installment.Find('-') then;
            end;

            NextDueDate := "Due Date";

            for CurrDocNo := 1 to PaymentTerms."No. of Installments" do begin
                CFJournalLine3."Cash Flow Date" := NextDueDate;
                CFJournalLine3.Description :=
                  CopyStr(StrSubstNo(Text1100007, Format(CFJournalLine3."Cash Flow Date"),
                      Name), 1, MaxStrLen(CFJournalLine3.Description));
                DueDateAdjust.SalesAdjustDueDate(
                  CFJournalLine3."Cash Flow Date", "Document Date", PaymentTerms.CalculateMaxDueDate("Document Date"), "Bill-to Customer No.");
                if CurrDocNo < PaymentTerms."No. of Installments" then begin
                    Installment.TestField("% of Total");
                    if CurrDocNo = 1 then begin
                        TotalPerc := Installment."% of Total";
                        case PaymentTerms."VAT distribution" of
                            PaymentTerms."VAT distribution"::"First Installment":
                                CFJournalLine3."Amount (LCY)" := Round(
                                    (TotalAmount - VATAmount) * Installment."% of Total" / 100 + VATAmount);
                            PaymentTerms."VAT distribution"::"Last Installment":
                                CFJournalLine3."Amount (LCY)" := Round(
                                    (TotalAmount - VATAmount) * Installment."% of Total" / 100);
                            PaymentTerms."VAT distribution"::Proportional:
                                CFJournalLine3."Amount (LCY)" := Round(
                                    TotalAmount * Installment."% of Total" / 100);
                        end;
                    end else begin
                        TotalPerc := TotalPerc + Installment."% of Total";
                        if TotalPerc >= 100 then
                            Error(
                              Text1100005,
                              Installment.FieldCaption("% of Total"),
                              PaymentTerms.TableCaption,
                              PaymentTerms.Code);
                        case PaymentTerms."VAT distribution" of
                            PaymentTerms."VAT distribution"::"First Installment",
                          PaymentTerms."VAT distribution"::"Last Installment":
                                CFJournalLine3."Amount (LCY)" := Round(
                                    (TotalAmount - VATAmount) * Installment."% of Total" / 100);
                            PaymentTerms."VAT distribution"::Proportional:
                                CFJournalLine3."Amount (LCY)" := Round(
                                    TotalAmount * Installment."% of Total" / 100);
                        end;
                    end;
                    RemainingAmount := RemainingAmount - CFJournalLine3."Amount (LCY)";
                    Installment.TestField("Gap between Installments");
                    NextDueDate := CalcDate(Installment."Gap between Installments", NextDueDate);
                    Installment.Next;
                end else
                    CFJournalLine3."Amount (LCY)" := RemainingAmount;

                if PaymentMethod."Create Bills" and (CFJournalLine3."Amount (LCY)" <> 0) then
                    InsertTempCFWorksheetLine(0);
            end;
        end;
    end;

    /// <summary>
    /// RoundAmt.
    /// </summary>
    /// <param name="Amount">Decimal.</param>
    /// <returns>Return value of type Decimal.</returns>
    //[Scope('OnPrem')]
    procedure RoundAmt(Amount: Decimal): Decimal
    begin
        if SalesSetup."Invoice Rounding" then
            Amount := Round(
                Amount,
                Currency."Invoice Rounding Precision",
                SelectStr(Currency."Invoice Rounding Type" + 1, '=,>,<'))
        else
            Amount := Round(
                Amount,
                Currency."Amount Rounding Precision");

        exit(Amount);
    end;

    local procedure GetPurchaseAmountForCFLine(PurchaseLine: Record "Purchase Line"): Decimal
    begin
        exit(PurchaseLine."Outstanding Amount (LCY)" + PurchaseLine."Amt. Rcd. Not Invoiced (LCY)");
    end;

    local procedure GetSalesAmountForCFLine(SalesLine: Record "Sales Line"): Decimal
    begin
        exit(SalesLine."Outstanding Amount (LCY)" + SalesLine."Shipped Not Invoiced (LCY)");
    end;

    local procedure GetServiceAmountForCFLine(ServiceLine: Record "Service Line"): Decimal
    begin
        exit(ServiceLine."Outstanding Amount (LCY)" + ServiceLine."Shipped Not Invoiced (LCY)");
    end;

    local procedure GetJobPlanningAmountForCFLine(JobPlanningLine: Record "Job Planning Line"): Decimal
    begin
        JobPlanningLine.CalcFields("Invoiced Amount (LCY)");
        exit(JobPlanningLine."Line Amount (LCY)" - JobPlanningLine."Invoiced Amount (LCY)");
    end;

    local procedure GetTaxPayableDateFromSource(SourceTableNum: Integer): Date
    var
        CashFlowSetup: Record "Cash Flow Setup";
        DocumentDate: Date;
    begin
        case SourceTableNum of
            DATABASE::"Sales Header":
                DocumentDate := "Sales Header"."Document Date";
            DATABASE::"Purchase Header":
                DocumentDate := "Purchase Header"."Document Date";
            DATABASE::"VAT Entry":
                DocumentDate := "VAT Entry"."Document Date";
        end;

        exit(CashFlowSetup.GetTaxPaymentDueDate(DocumentDate));
    end;

    local procedure HasTaxBeenPaidOn(PaymentDate: Date): Boolean
    var
        CashFlowSetup: Record "Cash Flow Setup";
        BankAccountLedgerEntry: Record "Bank Account Ledger Entry";
        TaxPaymentStartDate: Date;
        BalanceAccountType: Enum "Gen. Journal Account Type";
    begin
        TaxPaymentStartDate := CashFlowSetup.GetTaxPaymentStartDate(PaymentDate);
        case CashFlowSetup."Tax Bal. Account Type" of
            CashFlowSetup."Tax Bal. Account Type"::" ":
                exit(false);
            CashFlowSetup."Tax Bal. Account Type"::Vendor:
                BalanceAccountType := BankAccountLedgerEntry."Bal. Account Type"::Vendor;
            CashFlowSetup."Tax Bal. Account Type"::"G/L Account":
                BalanceAccountType := BankAccountLedgerEntry."Bal. Account Type"::"G/L Account";
        end;
        BankAccountLedgerEntry.SetRange("Bal. Account Type", BalanceAccountType);
        BankAccountLedgerEntry.SetFilter("Posting Date", '%1..%2', TaxPaymentStartDate, PaymentDate);
        BankAccountLedgerEntry.SetRange("Bal. Account No.", CashFlowSetup."Tax Bal. Account No.");
        exit(not BankAccountLedgerEntry.IsEmpty);
    end;

    local procedure GetDescriptionForTaxCashFlowLine(SourceTableNum: Integer): Text[250]
    var
        PurchaseOrders: Page "Purchase Orders";
        SalesOrders: Page "Sales Orders";
        VATEntries: Page "VAT Entries";
    begin
        case SourceTableNum of
            DATABASE::"Purchase Header":
                exit(StrSubstNo(TaxForMsg, PurchaseOrders.Caption));
            DATABASE::"Sales Header":
                exit(StrSubstNo(TaxForMsg, SalesOrders.Caption));
            DATABASE::"VAT Entry":
                exit(StrSubstNo(TaxForMsg, VATEntries.Caption));
        end;
    end;

    local procedure GetTaxAmountFromSource(SourceTableNum: Integer): Decimal
    var
        CashFlowManagement: Codeunit "Cash Flow Management";
    begin
        case SourceTableNum of
            DATABASE::"Sales Header":
                exit(CashFlowManagement.GetTaxAmountFromSalesOrder("Sales Header"));
            DATABASE::"Purchase Header":
                exit(CashFlowManagement.GetTaxAmountFromPurchaseOrder("Purchase Header"));
            DATABASE::"VAT Entry":
                exit("VAT Entry".Amount);
        end;
    end;

    local procedure IsDateBeforeStartOfCurrentPeriod(Date: Date): Boolean
    var
        CashFlowSetup: Record "Cash Flow Setup";
    begin
        exit(Date < CashFlowSetup.GetCurrentPeriodStartDate);
    end;

    local procedure NBanco(CodB: Code[20]): Text[50]
    var
        r270: Record 270;
    begin

        if NOT r270.GET(CodB) THEN EXIT('');
        EXIT(r270."Name 2");

    end;

    /// <summary>
    /// InsertLiqLine.
    /// </summary>
    /// <returns>Return value of type Boolean.</returns>
    procedure InsertLiqLine(): Boolean
    begin

        WITH TempCFWorksheetLine DO BEGIN
            LineNo := LineNo + 10000;
            TRANSFERFIELDS(CFWorksheetLine2);
            "Anotación" := CFWorksheetLine2."Anotación";
            "Fecha Anotacion" := CFWorksheetLine2."Fecha Anotacion";
            "Cash Flow Forecast No." := "Cash Flow Forecast"."No.";
            "Line No." := LineNo;
            if "Cash Flow Date" = 0D Then "Cash Flow Date" := DummyDate;
            LiqAcc.RESET;
            if LiqAcc.GET("Cash Flow Account No.") THEN
                Concepto := LiqAcc.Name;
            CFWorksheetLine2.SETCURRENTKEY("Associated Entry No.");
            if "Associated Entry No." = 0 THEN
                INSERT
            ELSE BEGIN
                CFWorksheetLine2.SETRANGE(CFWorksheetLine2."Associated Entry No.", "Associated Entry No.");
                if NOT CFWorksheetLine2.FINDFIRST THEN
                    INSERT
                ELSE
                    EXIT(FALSE);
            END;
        END;
        EXIT(TRUE);
    end;

    local procedure Anotaciones(No: Code[20]; Proveedor: Boolean; VAR aNOTACION: tEXT[250]; var FechaAnotacion: Date)
    var
        Anot: Record "Comment Line";
    begin

        Anot.SETRANGE(Anot."Table Name", Anot."Table Name"::Anotaciones);
        Anot.SETRANGE(Anot."No.", No);
        Anot.Setrange(Proveedor, Proveedor);
        if Anot.FINDLAST THEN begin
            aNOTACION := Anot.Comment;
            FechaAnotacion := Anot."Date";

        end;
    end;

    local procedure CalcFecha(Fec: Date): Date
    begin
        if Fec = 0D THEN EXIT(DummyDate);
        EXIT(Fec);
    end;

    local procedure CalcFechaL(Fec: Date): Date
    begin

        if Fec = 0D THEN EXIT(DummyDate);
        if Fec >= DueDateD THEN EXIT(Fec);
        if (DATE2DMY(Fec, 2) = DATE2DMY(DueDateD, 2)) AND ((DATE2DMY(Fec, 3) = DATE2DMY(DueDateD, 3))) THEN EXIT(DueDateD);
        EXIT(CALCDATE('PM+1D-2M+PM', DueDateD));
    end;

    local procedure BuscarLiq(var LiqAcc: Record "Cash Flow Account"; PSourceType: Enum "Cash Flow Source Type";
    pCartera: Boolean; pAtrasados: Boolean; pFormaPago: Code[10]; pBanco: Code[20]; pProveedor: Text; Importe: Decimal; DueDate: Date; pCliente: Code[20])
    var
        LiqAcct: Record "Temp Cash Flow Account" temporary;
        Odatef: DateFormula;
        Vtoh: Date;
        Vtod: Date;
    begin
        Case PSourceType of
            PSourceType::"Cartera Clientes":
                PSourceType := PSourceType::Receivables;
            PSourceType::"Cartera Clientes Registrada":
                PSourceType := PSourceType::Receivables;
            PSourceType::"Cartera Proveedores":
                PSourceType := PSourceType::Payables;
            PSourceType::"Cartera Proveedores Registrada":
                PSourceType := PSourceType::Payables;
        End;
        // Buscamos Con Todos los datos
        LiqAcc.RESET;
        LiqAcc.SETRANGE(LiqAcc."Source Type", PSourceType);
        if pProveedor <> '' THEN
            LiqAcc.SETRANGE(LiqAcc."Cód. Proveedor", pProveedor);
        if pCliente <> '' THEN
            LiqAcc.SETRANGE(LiqAcc."Cód. Cliente", pCliente);
        if LiqAcc.FINDFIRST THEN BEGIN
            REPEAT
                LiqAcct.TransferFields(LiqAcc);
                LiqAcct."Cód Prestamo" := LiqAcc."Cód Prestamo";
                LiqAcct."Banco Informes" := LiqAcc."Banco Informes";
                LiqAcct."Solo Cartera" := LiqAcc."Solo Atrasados";
                LiqAcct."Empresa" := LiqAcc.Empresa;
                LiqAcct."Cód. Proveedor" := LiqAcc."Cód. Proveedor";
                LiqAcct."Cód. Cliente" := LiqAcc."Cód. Cliente";
                LiqAcct."Calcular vto Cuenta" := LiqAcc."Calcular vto. Cuenta";
                LiqAcct."Dias Liquidación HASTA" := LiqAcc."Dias Liquidación HASTA";
                LiqAcct."Debe/Haber" := LiqAcc."Debe/Haber";
                LiqAcct."Solo Atrasados" := LiqAcc."Solo Atrasados";
                LiqAcct."Dias Liquidación DESDE" := LiqAcc."Dias Liquidación DESDE";
                LiqAcct."Desglosar" := LiqAcc.Desglosar;
                LiqAcct."Vinculado a noº" := LiqAcc."Vinculado a noº";
                LiqAcct."Dia de pago" := LiqAcc."Dia de pago";
                LiqAcct."Tipo Saldo" := LiqAcc."Tipo Saldo";
                LiqAcct."Vto Resto Año" := LiqAcc."Vto Resto Año";
                LiqAcct."Vto enero" := LiqAcc."Vto enero";
                LiqAcct."Pago Impuestos" := LiqAcc."Pago Impuestos";


                LiqAcct.Valoracion := 0;

                if LiqAcc."Payment Method Code" = pFormaPago THEN
                    LiqAcct.Valoracion += 2;
                if pBanco <> '' Then
                    if LiqAcc."Cod banco" = pBanco THEN
                        LiqAcct.Valoracion += 1;
                if pBanco <> '' Then
                    if NBanco(pBanco) = LiqAcc."Banco Informes" THEN
                        LiqAcct.Valoracion += 1;
                if LiqAcct."Solo Cartera" = pCartera THEN
                    LiqAcct.Valoracion += 1;
                if (LiqAcc."Debe/Haber" = LiqAcc."Debe/Haber"::Debe) AND
                (Importe > 0) THEN
                    LiqAcct.Valoracion += 1;
                if (LiqAcc."Debe/Haber" = LiqAcc."Debe/Haber"::Haber) AND
                (Importe < 0) THEN
                    LiqAcct.Valoracion += 1;
                if (LiqAcc."Debe/Haber" = LiqAcc."Debe/Haber"::Ambos) THEN
                    LiqAcct.Valoracion += 1;
                if LiqAcc."Solo Atrasados" = pAtrasados THEN
                    LiqAcct.Valoracion += 1;
                if LiqAcc."Dias Liquidación HASTA" <> Odatef THEN BEGIN
                    Vtoh := CALCDATE(LiqAcc."Dias Liquidación HASTA", WORKDATE);
                    Vtod := CALCDATE(LiqAcc."Dias Liquidación DESDE", WORKDATE);
                    if LiqAcc."Dias Liquidación DESDE" = Odatef THEN Vtod := 19800101D;
                    if (DueDate <= Vtoh) AND (DueDate >= Vtod) THEN LiqAcct.Valoracion += 1;
                END;
                LiqAcct.INSERT;
            UNTIL LiqAcc.NEXT = 0;
            LiqAcct.SETCURRENTKEY(Valoracion);
            LiqAcct.FINDLAST;
            LiqAcc.GET(LiqAcct."No.");
            EXIT;
        END ELSE BEGIN
            LiqAcc.SETRANGE(LiqAcc."Cód. Proveedor");
            LiqAcc.SETRANGE(LiqAcc."Cód. Cliente");
        END;
        if LiqAcc.FINDFIRST THEN BEGIN
            REPEAT
                LiqAcct.TransferFields(LiqAcc);
                LiqAcct."Cód Prestamo" := LiqAcc."Cód Prestamo";
                LiqAcct."Banco Informes" := LiqAcc."Banco Informes";
                LiqAcct."Solo Cartera" := LiqAcc."Solo Atrasados";
                LiqAcct."Empresa" := LiqAcc.Empresa;
                LiqAcct."Cód. Proveedor" := LiqAcc."Cód. Proveedor";
                LiqAcct."Cód. Cliente" := LiqAcc."Cód. Cliente";
                LiqAcct."Calcular vto Cuenta" := LiqAcc."Calcular vto. Cuenta";
                LiqAcct."Dias Liquidación HASTA" := LiqAcc."Dias Liquidación HASTA";
                LiqAcct."Debe/Haber" := LiqAcc."Debe/Haber";
                LiqAcct."Solo Atrasados" := LiqAcc."Solo Atrasados";
                LiqAcct."Dias Liquidación DESDE" := LiqAcc."Dias Liquidación DESDE";
                LiqAcct."Desglosar" := LiqAcc.Desglosar;
                LiqAcct."Vinculado a noº" := LiqAcc."Vinculado a noº";
                LiqAcct."Dia de pago" := LiqAcc."Dia de pago";
                LiqAcct."Tipo Saldo" := LiqAcc."Tipo Saldo";
                LiqAcct."Vto Resto Año" := LiqAcc."Vto Resto Año";
                LiqAcct."Vto enero" := LiqAcc."Vto enero";
                LiqAcct."Pago Impuestos" := LiqAcc."Pago Impuestos";
                LiqAcct.Valoracion := 0;
                if LiqAcc."Payment Method Code" = pFormaPago THEN
                    LiqAcct.Valoracion += 2;
                if pBanco <> '' Then
                    if LiqAcc."Cod banco" = pBanco THEN
                        LiqAcct.Valoracion += 1;
                if pBanco <> '' Then
                    if NBanco(pBanco) = LiqAcc."Banco Informes" THEN
                        LiqAcct.Valoracion += 1;
                if LiqAcct."Solo Cartera" = pCartera THEN
                    LiqAcct.Valoracion += 1;
                if (LiqAcc."Debe/Haber" = LiqAcc."Debe/Haber"::Debe) AND
                (Importe > 0) THEN
                    LiqAcct.Valoracion += 1;
                if (LiqAcc."Debe/Haber" = LiqAcc."Debe/Haber"::Haber) AND
                (Importe < 0) THEN
                    LiqAcct.Valoracion += 1;
                if (LiqAcc."Debe/Haber" = LiqAcc."Debe/Haber"::Ambos) THEN
                    LiqAcct.Valoracion += 1;
                if LiqAcc."Solo Atrasados" = pAtrasados THEN
                    LiqAcct.Valoracion += 1
                else
                    LiqAcct.Valoracion -= 1;
                if LiqAcc."Dias Liquidación HASTA" <> Odatef THEN BEGIN
                    Vtoh := CALCDATE(LiqAcc."Dias Liquidación HASTA", WORKDATE);
                    Vtod := CALCDATE(LiqAcc."Dias Liquidación DESDE", WORKDATE);
                    if LiqAcc."Dias Liquidación DESDE" = Odatef THEN Vtod := 19800101D;
                    if (DueDate <= Vtoh) AND (DueDate >= Vtod) THEN LiqAcct.Valoracion += 1;
                END;

                if LiqAcct.INSERT Then;
            UNTIL LiqAcc.NEXT = 0;
            LiqAcct.SETCURRENTKEY(Valoracion);
            LiqAcct.FINDLAST;
            LiqAcc.GET(LiqAcct."No.");
            EXIT;
        END;
    end;

    local procedure ExisteMov(Num: Integer): Boolean
    begin

        if Num = 0 THEN EXIT(FALSE);
        TempCFWorksheetLine.SETRANGE("Associated Entry No.", Num);
        EXIT(TempCFWorksheetLine.FINDFIRST);
    end;

    local procedure ComprobarCliente(Cta: Code[20]; Liq: Code[20]): Boolean
    var
        r18: Record Customer;
        LiqAcount: Record "Cash Flow Account";
    begin

        if r18.GET(Cta) THEN
            if (r18."IC Partner Code" <> '') THEN EXIT(FALSE);

        if (Liq <> '') THEN
            EXIT(Cta = Liq);
        LiqAcount.SETRANGE(LiqAcount."Cód. Cliente", Cta);
        EXIT(NOT LiqAcount.FINDFIRST);
    end;

    local procedure ComprobarProveedor(Cta: Code[20]; Liq: Code[20]): Boolean
    var
        r23: Record Vendor;
        LiqAcount: Record "Cash Flow Account";
    begin

        if r23.GET(Cta) THEN
            if (r23."IC Partner Code" <> '') THEN EXIT(FALSE);

        if (Liq <> '') THEN
            EXIT(Cta = Liq);
        LiqAcount.SETRANGE(LiqAcount."Cód. Proveedor", Cta);
        EXIT(NOT LiqAcount.FINDFIRST);
    end;

}

