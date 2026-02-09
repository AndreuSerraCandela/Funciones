/// <summary>
/// Page Lista Proveedores Compra (ID 50049).
/// </summary>
page 50049 "Lista Proveedores Compra"
{
    Caption = 'Lista Proveedores Compra';
    PageType = List;
    ApplicationArea = All;
    Editable = true;
    UsageCategory = Lists;
    CardPageId = "Ficha Proveedor Compra";
    SourceTable = "Proveedores Compra";
    layout
    {
        area(Content)
        {
            group(Fechas)
            {

                field(Desde; Desde)
                {
                    ApplicationArea = all;
                    trigger OnValidate()
                    begin
                        if (Hasta <> 0D) And (Desde <> 0D) Then Rec.SetRange("Date Filter", Desde, Hasta);
                    end;
                }
                field(Hasta; Hasta)
                {
                    ApplicationArea = all;
                    trigger OnValidate()
                    begin
                        if (Hasta <> 0D) And (Desde <> 0D) Then Rec.SetRange("Date Filter", Desde, Hasta);
                    end;
                }

            }
            repeater(Detalle)
            {
                Editable = false;


                field(Name; rec.Name)
                {
                    ApplicationArea = All;
                }

                field(ColumnValues1; ColumnValues[1])
                {
                    ApplicationArea = Basic, Suite;
                    //AutoFormatExpression = FormatStr(1);
                    AutoFormatType = 11;
                    BlankZero = true;
                    CaptionClass = '3,' + ColumnCaptions[1];
                    StyleExpr = ColumnStyle1;

                    trigger OnDrillDown()
                    begin
                        DrillDown(1);
                    end;
                }
                field(ColumnValues2; ColumnValues[2])
                {
                    ApplicationArea = Basic, Suite;
                    //AutoFormatExpression = FormatStr(2);
                    AutoFormatType = 11;
                    BlankZero = true;
                    CaptionClass = '3,' + ColumnCaptions[2];
                    StyleExpr = ColumnStyle2;
                    Visible = NoOfColumns >= 2;

                    trigger OnDrillDown()
                    begin
                        DrillDown(2);
                    end;
                }
                field(ColumnValues3; ColumnValues[3])
                {
                    ApplicationArea = Basic, Suite;
                    //AutoFormatExpression = FormatStr(3);
                    AutoFormatType = 11;
                    BlankZero = true;
                    CaptionClass = '3,' + ColumnCaptions[3];
                    StyleExpr = ColumnStyle3;
                    Visible = NoOfColumns >= 3;

                    trigger OnDrillDown()
                    begin
                        DrillDown(3);
                    end;
                }
                field(ColumnValues4; ColumnValues[4])
                {
                    ApplicationArea = Basic, Suite;
                    //AutoFormatExpression = FormatStr(4);
                    AutoFormatType = 11;
                    BlankZero = true;
                    CaptionClass = '3,' + ColumnCaptions[4];
                    StyleExpr = ColumnStyle4;
                    Visible = NoOfColumns >= 4;

                    trigger OnDrillDown()
                    begin
                        DrillDown(4);
                    end;
                }
                field(ColumnValues5; ColumnValues[5])
                {
                    ApplicationArea = Basic, Suite;
                    //AutoFormatExpression = FormatStr(5);
                    AutoFormatType = 11;
                    BlankZero = true;
                    CaptionClass = '3,' + ColumnCaptions[5];
                    StyleExpr = ColumnStyle5;
                    Visible = NoOfColumns >= 5;

                    trigger OnDrillDown()
                    begin
                        DrillDown(5);
                    end;
                }
                field(ColumnValues6; ColumnValues[6])
                {
                    ApplicationArea = Basic, Suite;
                    //AutoFormatExpression = FormatStr(6);
                    AutoFormatType = 11;
                    BlankZero = true;
                    CaptionClass = '3,' + ColumnCaptions[6];
                    StyleExpr = ColumnStyle6;
                    Visible = NoOfColumns >= 6;

                    trigger OnDrillDown()
                    begin
                        DrillDown(6);
                    end;
                }
                field(ColumnValues7; ColumnValues[7])
                {
                    ApplicationArea = Basic, Suite;
                    //AutoFormatExpression = FormatStr(7);
                    AutoFormatType = 11;
                    BlankZero = true;
                    CaptionClass = '3,' + ColumnCaptions[7];
                    StyleExpr = ColumnStyle7;
                    Visible = NoOfColumns >= 7;

                    trigger OnDrillDown()
                    begin
                        DrillDown(7);
                    end;
                }
                field(ColumnValues8; ColumnValues[8])
                {
                    ApplicationArea = Basic, Suite;
                    //AutoFormatExpression = FormatStr(8);
                    AutoFormatType = 11;
                    BlankZero = true;
                    CaptionClass = '3,' + ColumnCaptions[8];
                    StyleExpr = ColumnStyle8;
                    Visible = NoOfColumns >= 8;

                    trigger OnDrillDown()
                    begin
                        DrillDown(8);
                    end;
                }
                field(ColumnValues9; ColumnValues[9])
                {
                    ApplicationArea = Basic, Suite;
                    //AutoFormatExpression = FormatStr(9);
                    AutoFormatType = 11;
                    BlankZero = true;
                    CaptionClass = '3,' + ColumnCaptions[9];
                    StyleExpr = ColumnStyle9;
                    Visible = NoOfColumns >= 9;

                    trigger OnDrillDown()
                    begin
                        DrillDown(9);
                    end;
                }
                field(ColumnValues10; ColumnValues[10])
                {
                    ApplicationArea = Basic, Suite;
                    //AutoFormatExpression = FormatStr(10);
                    AutoFormatType = 11;
                    BlankZero = true;
                    CaptionClass = '3,' + ColumnCaptions[10];
                    StyleExpr = ColumnStyle10;
                    Visible = NoOfColumns >= 10;

                    trigger OnDrillDown()
                    begin
                        DrillDown(10);
                    end;
                }
                field(ColumnValues11; ColumnValues[11])
                {
                    ApplicationArea = Basic, Suite;
                    //AutoFormatExpression = FormatStr(11);
                    AutoFormatType = 11;
                    BlankZero = true;
                    CaptionClass = '3,' + ColumnCaptions[11];
                    StyleExpr = ColumnStyle11;
                    Visible = NoOfColumns >= 11;

                    trigger OnDrillDown()
                    begin
                        DrillDown(11);
                    end;
                }
                field(ColumnValues12; ColumnValues[12])
                {
                    ApplicationArea = Basic, Suite;
                    //AutoFormatExpression = FormatStr(12);
                    AutoFormatType = 11;
                    BlankZero = true;
                    CaptionClass = '3,' + ColumnCaptions[12];
                    StyleExpr = ColumnStyle12;
                    Visible = NoOfColumns >= 12;

                    trigger OnDrillDown()
                    begin
                        DrillDown(12);
                    end;
                }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action("Ficha")
            {
                ApplicationArea = All;
                Image = List;
                ShortCutKey = 'Mayús+F5';
                //       CaptionML=ESP=Ficha;
                RunObject = Page "Ficha Intercambio";
                RunPageLink = "No." = FIELD("No.");
            }
            action("&Desplegar")
            {
                ApplicationArea = All;
                Image = BOMLevel;
                ShortCutKey = F11;
                //CaptionML=ESP=Desplegar;
                trigger OnAction()
                VAR
                    rEmpresa: Record 2000000006;
                    Customer: Record Customer;
                    Vendor: Record Vendor;
                    RxE: Record "Proveedores x Empresa";
                    Cli: Code[20];
                    Prov: Code[20];

                BEGIN
                    Desplegar(Rec);
                END;
            }
            action("&Ver Provee x Empresa")
            {
                ApplicationArea = All;
                Image = Find;
                //CaptionML=ESP=Ver Clientes/Provee x Empresa;
                trigger OnAction()
                VAR
                    RxE: Record "Proveedores x Empresa";
                BEGIN
                    RxE.SETRANGE(RxE."Código Proveedor", Rec."No.");
                    Page.RUNMODAL(Page::"Proveedores x Empresa", RxE);
                END;
            }
            action("Copiar &Datos del Proveedor")
            {
                ApplicationArea = All;
                ShortCutKey = F6;
                Image = Copy;
                //CaptionML=ESP=Copiar Datos del cliente;
                trigger OnAction()
                VAR
                    Customer: Record Vendor;
                BEGIN
                    if Page.RUNMODAL(0, Customer) = ACTION::LookupOK THEN BEGIN
                        //"No.":=Customer."No.";
                        if Rec."No." = '' THEN Rec.INSERT(TRUE);
                        //"Search Name":=Customer."Search Name";
                        Rec.Name := Customer.Name;
                        Rec."Name 2" := Customer."Name 2";
                        Rec.Address := Customer.Address;
                        Rec."Address 2" := Customer."Address 2";
                        Rec.City := Customer.City;
                        Rec.Contact := Customer.Contact;
                        Rec."Phone No." := Customer."Phone No.";
                        Rec."Telex No." := Customer."Telex No.";
                        Rec."Our Account No." := Customer."Our Account No.";
                        Rec."Territory Code" := Customer."Territory Code";
                        Rec."Global Dimension 1 Code" := Customer."Global Dimension 1 Code";
                        Rec."Global Dimension 2 Code" := Customer."Global Dimension 2 Code";
                        Rec."Budgeted Amount" := Customer."Budgeted Amount";
                        Rec."Currency Code" := Customer."Currency Code";
                        Rec."Payment Terms Code" := Customer."Payment Terms Code";
                        Rec."Shipment Method Code" := Customer."Shipment Method Code";
                        Rec."Shipping Agent Code" := Customer."Shipping Agent Code";
                        Rec."Country/Region Code" := Customer."Country/Region Code";
                        Rec.Blocked := Customer.Blocked;
                        Rec."Payment Method Code" := Customer."Payment Method Code";
                        Rec."Last Date Modified" := Customer."Last Date Modified";
                        Rec."Fax No." := Customer."Fax No.";
                        Rec."VAT Registration No." := Customer."VAT Registration No.";
                        Rec."Post Code" := Customer."Post Code";
                        Rec.County := Customer.County;
                        Rec."E-Mail" := Customer."E-Mail";
#if CLEAN24
#pragma warning disable AL0432
                        Rec."Home Page" := Customer."Home Page";
#pragma warning restore AL0432
#else
#pragma warning disable AL0432
                        Rec."Home Page" := Customer."Home Page";
#endif
                        Rec."Primary Contact No." := Customer."Primary Contact No.";

                        Rec.MODIFY;
                    END;
                END;
            }

            action("Ver Detalle &Todos")
            {
                ApplicationArea = All;
                Image = AllLines;
                // PushAction=RunObject;                // CaptionML=ESP=Ver Detalle Todos;
                trigger OnAction()
                begin
                    Page.RunModal(Page::"Proveedores x Empresa");
                end;

            }
            action("Grupo Compras")
            {
                ApplicationArea = All;
                Image = Company;
                trigger OnAction()
                var
                    Gr: Record "Grupo de empresas";
                    EmpGr: Record "Empresa grupo";
                begin
                    if not Gr.Get('COMPRAS', 'Grupo Compras') Then begin
                        Gr.Codigo := 'COMPRAS';
                        Gr.Descripcion := 'Grupo Compras';
                        Gr.Insert();
                        Commit();
                    end;
                    EmpGr.SetRange("Cod. grupo", 'COMPRAS');
                    Page.RunModal(0, EmpGr);
                end;
            }
            action("&Calcular")
            {
                ApplicationArea = All;
                Scope = Repeater;
                Image = Calculate;
                ShortCutKey = F9;
                trigger OnAction()
                BEGIN
                    Calcular('');
                END;
            }
            action("&Calcular Venta")
            {
                ApplicationArea = All;
                Scope = Repeater;
                Image = Calculate;
                ShortCutKey = F9;
                trigger OnAction()
                BEGIN
                    CalcularVenta('');
                END;
            }
        }
    }
    var
        T: Boolean;
        AL: Boolean;
        "F-T": Boolean;
        "F+A": Boolean;
        MatrixRec: Record "Proveedores x Empresa";
        ColumnOffset: Integer;
        Ventana: Dialog;
        a: Integer;
        ColumnValues: array[100] of Decimal;
        ColumnCaptions: array[100] of Text[100];
        NoOfColumns: Integer;
        Desde: Date;
        Hasta: Date;
        ColumnStyle1: Text;
        ColumnStyle2: Text;
        ColumnStyle3: Text;
        ColumnStyle4: Text;
        ColumnStyle5: Text;
        ColumnStyle6: Text;
        ColumnStyle7: Text;
        ColumnStyle8: Text;
        ColumnStyle9: Text;
        ColumnStyle10: Text;
        ColumnStyle11: Text;
        ColumnStyle12: Text;


    trigger OnAfterGetRecord()
    var
        ColumnNo: Integer;
        ColumnNo2: Integer;
        Emp: Record "Empresa grupo";
        IxE: Record "Proveedores x Empresa";
    begin
        ColumnStyle1 := 'Standard';
        ColumnStyle2 := 'StrongAccent';
        ColumnStyle3 := 'Standard';
        ColumnStyle4 := 'StrongAccent';
        ColumnStyle5 := 'Standard';
        ColumnStyle6 := 'StrongAccent';
        ColumnStyle7 := 'Standard';
        ColumnStyle8 := 'StrongAccent';
        ColumnStyle9 := 'Standard';
        ColumnStyle10 := 'StrongAccent';
        ColumnStyle11 := 'Standard';
        ColumnStyle12 := 'StrongAccent';
        Clear(ColumnValues);
        ColumnOffset := 0;
        MatrixRec.Reset();
        ColumnNo := 0;
        Emp.Reset();
        Emp.SetRange("Cod. grupo", 'COMPRAS');
        if Emp.FindFirst() then
            repeat
                if ColumnNo = 0 Then
                    ColumnNo := 1 else
                    ColumnNo += 2;
                MatrixRec.SetRange("Código Proveedor", Rec."No.");
                MatrixRec.SetRange(Empresa, Emp.Empresa);
                if MatrixRec.FindFirst() Then
                    repeat

                        if (ColumnNo > ColumnOffset) and (ColumnNo - ColumnOffset <= ArrayLen(ColumnValues)) then begin
                            ColumnValues[ColumnNo - ColumnOffset] := MatrixRec.Saldo;
                            ColumnCaptions[ColumnNo - ColumnOffset] := Emp.Empresa;

                        end;
                    until MatrixRec.Next() = 0;

            Until Emp.Next = 0;
        NoOfColumns := ColumnNo + 1;
        ColumnNo2 := 2;
        Repeat
            //for ColumnNo2 := 2 to ColumnNo + 1  do begin
            if Not IxE.Get('TOTAL', ColumnCaptions[ColumnNo2 - 1 - ColumnOffset]) Then IxE.Init();
            if IxE.Saldo <> 0 Then
                ColumnValues[ColumnNo2 - ColumnOffset] := ColumnValues[ColumnNo2 - 1 - ColumnOffset] / IxE.Saldo * 100;
            ColumnCaptions[ColumnNo2 - ColumnOffset] := '%';
            ColumnNo2 += 2;
        Until ColumnNo2 > NoOfColumns;
    end;

    trigger OnOpenPage()
    var
        EmpGr: Record "Empresa grupo";
    begin
        if (Hasta <> 0D) And (Desde <> 0D) Then Rec.SetRange("Date Filter", Desde, Hasta);
        if Not Rec.get('TOTAL') Then begin
            Rec."No." := 'TOTAL';
            Rec.Name := 'TOTAL';
            Rec.Insert();
        end;
        if not EmpGr.Get('COMPRAS', 'Z-TOTAL') Then begin
            EmpGr."Cod. grupo" := 'COMPRAS';
            EmpGr.Empresa := 'Z-TOTAL';
            EmpGr.Insert();
        end;
    end;

    PROCEDURE Calcular(Interc: Code[20]);
    VAR
        IxE: Record "Proveedores x Empresa";
        IxEmpGr: Record "Proveedores x Empresa";
        Contratos: Record 36;
        rAlb: Record "Purch. Rcpt. Header";
        r121: Record "Purch. Rcpt. Line";
        rDev: Record 6650;
        r121D: Record 6651;
        r25: Record 25;
        r21: Record 21;
        r380: Record 380;
        r379: Record 379;
        EmpGr: Record "Empresa grupo";
        Pro: Record "Proveedores Compra";
    BEGIN
        if Rec.GETFILTER("Date Filter") = '' THEN ERROR('Especifique filtro fecha');
        // IxE.SETRANGE(IxE."Código Proveedor", Rec."No.");
        IxE.SetRange("Código Proveedor", 'TOTAL');
        IxE.DeleteAll();
        IxE.Reset();
        IxE.SetRange(Empresa, 'Z-TOTAL');
        IxE.DeleteAll();
        IxE.SetRange(Empresa, 'TOTAL');
        IxE.DeleteAll();
        IxE.Reset();
        Commit();
        Rec.Copyfilter("Date Filter", IxE."Date Filter");
        Ventana.OPEN('#########1## de #########2##');
        Ventana.UPDATE(2, IxE.COUNT);
        if IxE.FINDFIRST THEN
            REPEAT
                a += 1;
                Ventana.UPDATE(1, a);
                IxE.Saldo := 0;
                IxE.Desde := Desde;
                IxE.Hasta := Hasta;
                IxE.Saldo := TotalesDocumentos(IxE.Proveedor, IxE.Empresa, Ixe.Desde, Ixe.Hasta);
                IxE.MODIFY;
                COMMIT;

            UNTIL IxE.NEXT = 0;
        IxE.Reset();
        if Pro.FindFirst() Then
            repeat
                IxE.SetRange("Código Proveedor", pro."No.");
                if IxE.FindFirst() Then begin
                    IxEmpGr."Código Proveedor" := Pro."No.";
                    IxEmpGr.Empresa := 'Z-TOTAL';
                    IxEmpGr.Saldo := 0;
                    IxEmpGr.Desde := Desde;
                    IxEmpGr.Hasta := Hasta;
                    IxEmpGr.Insert();
                    repeat
                        IxEmpGr.Saldo += IxE.Saldo;
                    until IxE.Next() = 0;
                    IxEmpGr.Modify();
                end;
            until Pro.Next() = 0;
        IxE.Reset();
        EmpGr.SetRange("Cod. grupo", 'COMPRAS');
        if EmpGr.FindFirst() Then
            repeat
                IxE.SetRange(Empresa, EmpGr.Empresa);
                if IxE.FindFirst() Then begin
                    IxEmpGr."Código Proveedor" := 'TOTAL';
                    IxEmpGr.Empresa := EmpGr.Empresa;
                    IxEmpGr.Saldo := 0;
                    IxEmpGr.Desde := Desde;
                    IxEmpGr.Hasta := Hasta;
                    IxEmpGr.Insert();
                    repeat
                        if IxE."Código Proveedor" <> 'TOTAL' then
                            IxEmpGr.Saldo += IxE.Saldo;
                        IxEmpGr.Modify();
                    until IxE.Next() = 0;
                end;
            until EmpGr.Next() = 0;
        Ventana.CLOSE;
        // Sql.Close;
        // CLEAR(Sql);
    END;

    PROCEDURE TotalesDocumentos(No: Code[20]; pEmpresa: Text[30]; Desde: Date; Hasta: Date): Decimal;
    VAR
        rCabVenta: Record 38;
        SalesLine: Record 39;
        Importe: Decimal;
        BImporte: Decimal;
        BImpBorFac: Decimal;
        BImpBorAbo: Decimal;
        BImpFac: Decimal;
        BImpAbo: Decimal;
        BTotImp: Decimal;
        BTotCont: Decimal;
    BEGIN
        //FCL-31/05/04. Obtengo totales de borradores y facturas correspondientes a este contrato.
        // Contrato.Get(Contrato."Document Type"::Order, No);
        Importe := 0;
        if pEmpresa = 'Z-TOTAL' Then exit(0);

        rCabVenta.RESET;
        rCabVenta.CHANGECOMPANY(pEmpresa);
        rCabVenta.SetRange("Posting Date", Desde, Hasta);
        rCabVenta.SETRANGE("Buy-From Vendor No.", No);
        rCabVenta.SETFILTER("Document Type", '%1|%2',
           rCabVenta."Document Type"::Order, rCabVenta."Document Type"::"Return Order");
        if rCabVenta.FIND('-') THEN BEGIN
            REPEAT
                SalesLine.CHANGECOMPANY(pEmpresa);
                SalesLine.SETRANGE(SalesLine."Document Type", rCabVenta."Document Type");
                SalesLine.SETRANGE(SalesLine."Document No.", rCabVenta."No.");

                if SalesLine.FINDFIRST THEN
                    REPEAT
                        Importe += (SalesLine.Quantity * SalesLine."Direct Unit Cost" * (1 - SalesLine."Line Discount %" / 100));
                    //BImporte += (SalesLine.Quantity * SalesLine."Direct Unit Cost" * (1 - SalesLine."Line Discount %" / 100));
                    UNTIL SalesLine.NEXT = 0;

            UNTIL rCabVenta.NEXT = 0;
        END;

        EXIT(Importe);
    END;

    PROCEDURE CalcularVenta(Interc: Code[20]);
    VAR
        IxE: Record "Proveedores x Empresa";
        IxEmpGr: Record "Proveedores x Empresa";
        Contratos: Record 36;
        rAlb: Record "Purch. Rcpt. Header";
        r121: Record "Purch. Rcpt. Line";
        rDev: Record 6650;
        r121D: Record 6651;
        r25: Record 25;
        r21: Record 21;
        r380: Record 380;
        r379: Record 379;
        EmpGr: Record "Empresa grupo";
        Pro: Record "Proveedores Compra";
    BEGIN
        if Rec.GETFILTER("Date Filter") = '' THEN ERROR('Especifique filtro fecha');
        // IxE.SETRANGE(IxE."Código Proveedor", Rec."No.");
        IxE.SetRange("Código Proveedor", 'TOTAL');
        IxE.DeleteAll();
        IxE.Reset();
        IxE.SetRange(Empresa, 'Z-TOTAL');
        IxE.DeleteAll();
        IxE.SetRange(Empresa, 'TOTAL');
        IxE.DeleteAll();
        IxE.Reset();
        Commit();
        Rec.Copyfilter("Date Filter", IxE."Date Filter");
        Ventana.OPEN('#########1## de #########2##');
        Ventana.UPDATE(2, IxE.COUNT);
        if IxE.FINDFIRST THEN
            REPEAT
                a += 1;
                Ventana.UPDATE(1, a);
                IxE.Saldo := 0;
                IxE.Desde := Desde;
                IxE.Hasta := Hasta;
                IxE.Saldo := TotalesDocumentosVenta(IxE.Proveedor, IxE.Empresa, Ixe.Desde, Ixe.Hasta);
                IxE.MODIFY;
                COMMIT;

            UNTIL IxE.NEXT = 0;
        IxE.Reset();
        if Pro.FindFirst() Then
            repeat
                IxE.SetRange("Código Proveedor", pro."No.");
                if IxE.FindFirst() Then begin
                    IxEmpGr."Código Proveedor" := Pro."No.";
                    IxEmpGr.Empresa := 'Z-TOTAL';
                    IxEmpGr.Saldo := 0;
                    IxEmpGr.Desde := Desde;
                    IxEmpGr.Hasta := Hasta;
                    IxEmpGr.Insert();
                    repeat
                        IxEmpGr.Saldo += IxE.Saldo;
                    until IxE.Next() = 0;
                    IxEmpGr.Modify();
                end;
            until Pro.Next() = 0;
        IxE.Reset();
        EmpGr.SetRange("Cod. grupo", 'COMPRAS');
        if EmpGr.FindFirst() Then
            repeat
                IxE.SetRange(Empresa, EmpGr.Empresa);
                if IxE.FindFirst() Then begin
                    IxEmpGr."Código Proveedor" := 'TOTAL';
                    IxEmpGr.Empresa := EmpGr.Empresa;
                    IxEmpGr.Saldo := 0;
                    IxEmpGr.Desde := Desde;
                    IxEmpGr.Hasta := Hasta;
                    IxEmpGr.Insert();
                    repeat
                        if IxE."Código Proveedor" <> 'TOTAL' then
                            IxEmpGr.Saldo += IxE.Saldo;
                        IxEmpGr.Modify();
                    until IxE.Next() = 0;
                end;
            until EmpGr.Next() = 0;
        Ventana.CLOSE;
        // Sql.Close;
        // CLEAR(Sql);
    END;

    PROCEDURE TotalesDocumentosVenta(No: Code[20]; pEmpresa: Text[30]; Desde: Date; Hasta: Date): Decimal;
    VAR
        rCabVenta: Record 36;
        SalesLine: Record 37;
        rCabCompra: Record 38;
        PurchLine: Record 39;
        Importe: Decimal;
        BImporte: Decimal;
        BImpBorFac: Decimal;
        BImpBorAbo: Decimal;
        BImpFac: Decimal;
        BImpAbo: Decimal;
        BTotImp: Decimal;
        BTotCont: Decimal;
    BEGIN
        //FCL-31/05/04. Obtengo totales de borradores y facturas correspondientes a este contrato.
        // Contrato.Get(Contrato."Document Type"::Order, No);
        Importe := 0;
        if pEmpresa = 'Z-TOTAL' Then exit(0);

        rCabCompra.RESET;
        rCabCompra.CHANGECOMPANY(pEmpresa);
        rCabVenta.SetRange("Posting Date", Desde, Hasta);
        rCabCompra.SETRANGE("Buy-From Vendor No.", No);
        rCabCompra.SETFILTER("Document Type", '%1|%2',
           rCabCompra."Document Type"::Order, rCabVenta."Document Type"::"Return Order");
        if rCabCompra.FIND('-') THEN BEGIN
            REPEAT
                SalesLine.CHANGECOMPANY(pEmpresa);
                SalesLine.SETRANGE(SalesLine."Document Type", rCabVenta."Document Type"::Order);
                SalesLine.SETRANGE(SalesLine."Document No.", rCabCompra."Nº Contrato");

                if SalesLine.FINDFIRST THEN
                    REPEAT
                        PurchLine.CHANGECOMPANY(pEmpresa);
                        PurchLine.SETRANGE("Document Type", rCabCompra."Document Type");
                        PurchLine.SETRANGE("Document No.", rCabCompra."No.");
                        PurchLine.SetRange("No.", SalesLine."No.");
                        If PurchLine.FindFirst() Then
                            Importe += (SalesLine.Quantity * SalesLine."Unit Price" * (1 - SalesLine."Line Discount %" / 100));

                    //BImporte += (SalesLine.Quantity * SalesLine."Direct Unit Cost" * (1 - SalesLine."Line Discount %" / 100));
                    UNTIL SalesLine.NEXT = 0;

            UNTIL rCabCompra.NEXT = 0;
        END;

        EXIT(Importe);
    END;



    PROCEDURE Desplegar(VAR Inter: Record "Proveedores Compra");
    VAR
        rEmpresa: Record Company;
        Vendor: Record Vendor;
        RxE: Record "Proveedores x Empresa";
        Cli: Code[20];
        Prov: Code[20];
        Control: Codeunit ControlProcesos;
    BEGIN
        //rEmpresa.SETFILTER(rEmpresa."Clave Recursos",'<>%1','');
        rEmpresa.SetRange("Evaluation Company", false);
        if rEmpresa.FINDFIRST THEN
            REPEAT
                if Control.Permiso_Empresas(rEmpresa.Name) then begin


                    Vendor.CHANGECOMPANY(rEmpresa.Name);
                    WITH Inter DO BEGIN
                        Vendor.SETRANGE("VAT Registration No.", "VAT Registration No.");
                        if NOT Vendor.FINDFIRST THEN Prov := '' ELSE Prov := Vendor."No.";
                        if RxE.GET("No.", rEmpresa.Name) THEN RxE.DELETE;
                        RxE.INIT;
                        RxE.Empresa := rEmpresa.Name;
                        RxE."Código proveedor" := "No.";
                        RxE.Proveedor := Prov;
                        if (Prov <> '') THEN
                            RxE.INSERT;
                    END;

                end;
            UNTIL rEmpresa.NEXT = 0;
    END;

    PROCEDURE DrillDown(a: Integer)
    VAR
        r17: Record 38;
        Prov: Record "Proveedores x Empresa";
    BEGIN
        // r17.SETCURRENTKEY(
        // "G/L Account No.", "Source Type", "Source No.", "Posting Date", "Document Type", "Gen. Posting Type");
        r17.ChangeCompany(ColumnCaptions[a]);
        Prov.SetRange("Código Proveedor", Rec."No.");
        Prov.SetRange(Empresa, ColumnCaptions[a]);
        if Not Prov.FindFirst() then Prov.Init();
        r17.SETRANGE("Buy-From Vendor No.", prov.Proveedor);//, ColumnCaptions[a] + '999999');
        r17.SetRange("Posting Date", Prov.Desde, Prov.Hasta);
        Page.RUNMODAL(0, r17);
    END;

}