
/// <summary>
/// Page Cabecera Renting (ID 50077).
/// </summary>
page 50077 "Cabecera Renting"
{
    SourceTable = "Cabecera Prestamo";
    SourceTableView = WHERE(Empresa = FILTER(''), Renting = const(true));
    PageType = Card;
    layout
    {
        area(Content)
        {
            group(General)
            {
                field("Código Del Renting"; Rec."Código Del Prestamo") { Caption = 'Código Del Renting'; ApplicationArea = All; }
                field(Descripción; Rec."Cabecera Prestamo2") { Caption = 'Descripción'; ApplicationArea = All; }
                field("Fecha Renting"; Rec."Fecha Préstamo") { Caption = 'Fecha Renting'; ApplicationArea = All; }
                field("Fecha 1ª Cuota"; Rec."Fecha 1ª Amortización") { ApplicationArea = All; }
                field("Importe Renting"; Rec."Importe Prestamo") { Caption = 'Importe Renting'; ApplicationArea = All; }
                field(Años; Rec."Años") { ApplicationArea = All; }
                field("Cuotas Anuales"; Rec."Cuotas Anuales") { ApplicationArea = All; }
                field(Banco; Rec.Banco) { ApplicationArea = All; }
                field(Meses; Rec.Meses) { ApplicationArea = All; }
                field("Proveedor Renting"; Rec."Proveedor Leasing") { Caption = 'Proveedor Renting'; ApplicationArea = All; }
                field("Cuenta Previsión"; Rec."Cuenta L/P") { Caption = 'Cuenta Prevision'; ApplicationArea = All; }
                field("Cuenta Gasto Renting"; Rec."Cuenta Gastos") { Caption = 'Cuenta Gasto Renting'; ApplicationArea = All; }
                field("Cuenta C/P"; Rec."Cuenta C/P") { Caption = 'Cuenta seguro'; ApplicationArea = All; }
                field("Cuenta intrereses"; Rec."Cuenta intrereses") { Caption = 'Cuenta mantenimiento'; ApplicationArea = All; }
                field("Cuota"; Rec."Interes Anual") { Caption = 'Cuota Mensual Total Iva Incl.'; ApplicationArea = All; }
                field("Seguro"; Rec."Seguro") { Caption = 'Seguro Iva Incl.'; ApplicationArea = All; }
                field("Mantenimiento"; Rec.Mantenimiento) { Caption = 'Mantenimiento Iva Incl.'; ApplicationArea = All; }
                field(Iva; Rec.Iva) { Caption = '% Iva'; ApplicationArea = All; }
                //field("Valor Residual"; Rec."Valor Residual") { ApplicationArea = All; }
            }
            part(Fdet; "Detalle Renting")
            {

                ApplicationArea = All;
                SubPageLink = "Código Del Prestamo" = field("Código Del Prestamo");
            }

        }
    }
    actions
    {
        area(Processing)
        {
            group("Ac&ciones")
            {

                Caption = 'Ac&ciones';

                action("Calcular")
                {
                    ApplicationArea = All;
                    Image = Calculate;
                    ShortCutKey = F9;
                    Caption = 'Calcular';
                    trigger OnAction()
                    VAR
                        r5801: Record "Detalle Prestamo";
                        t: Integer;
                        CP: Decimal;
                        i: Decimal;
                        n: Decimal;
                        D: Decimal;
                        R: Decimal;
                        Divisor: Decimal;
                        Dividendo: Decimal;
                        r5801t: Record "Detalle Prestamo" TEMPORARY;
                        Liq: Boolean;
                    BEGIN
                        if NOT CONFIRM('Esta Seguro?', FALSE) THEN EXIT;
                        r5801.SETRANGE(r5801."Código Del Prestamo", Rec."Código Del Prestamo");
                        if r5801.FIND('-') THEN
                            REPEAT
                                r5801t := r5801;
                                r5801t.INSERT;
                            UNTIL r5801.NEXT = 0;
                        r5801.DELETEALL;
                        CP := Rec."Interes Anual";
                        n := Rec.Meses;//Años*"Cuotas Anuales";
                        FOR t := 1 TO Rec.Meses DO BEGIN
                            r5801.INIT;
                            r5801."Código Del Prestamo" := Rec."Código Del Prestamo";
                            r5801."No. Periodo" := t;
                            if t > 1 THEN
                                r5801.Fecha := CALCDATE(FORMAT(t - 1) + 'M', Rec."Fecha 1ª Amortización")
                            ELSE
                                r5801.Fecha := Rec."Fecha 1ª Amortización";
                            r5801."Total Liquidación" := CP;
                            r5801."A Pagar" := (r5801."Total Liquidación");
                            r5801.Seguro := Rec.Seguro;
                            r5801.Mantenimiento := Rec.Mantenimiento;
                            if r5801t.Get(r5801."Código Del Prestamo", r5801."No. Periodo") Then r5801.Liquidado := r5801t.Liquidado;
                            r5801.INSERT;                                              //r5801."% Intereses" := i * "Cuotas Anuales" * 100;
                        END;

                    END;

                }

                action("Factura")
                {
                    ApplicationArea = All;
                    Image = Invoice;
                    ShortCutKey = F11;
                    Caption = 'Factura';
                    trigger OnAction()
                    VAR
                        r38: Record 38;
                        r39: Record 39;
                        rGp: Record 325;
                        rPro: Record Vendor;
                        Cab: Record "Cabecera Prestamo";
                    BEGIN
                        CurrPage.Fdet.Page.GETRECORD(rDet);
                        if rDet.Facturado then if Not Confirm('Esta línea está facturada,¿ Quiere continuar ?') then Error('Proceso cancelado');
                        if Rec.Iva = 0 THEN Error('Indique el % de Iva');
                        r38.INIT;
                        r38."Document Type" := r38."Document Type"::Invoice;
                        r38."No." := '';
                        r38."Posting Date" := WORKDATE;
                        r38."Order Date" := WORKDATE;
                        r38."Document Date" := WORKDATE;
                        r38.VALIDATE("Buy-from Vendor No.", Rec."Proveedor Leasing");
                        r38.INSERT(TRUE);
                        r38.VALIDATE("Posting Date", WORKDATE);
                        r38.MODIFY;
                        a := 10000;
                        rPro.Get(Rec."Proveedor Leasing");
                        r39."Document Type" := r39."Document Type"::Invoice;
                        r39."Document No." := r38."No.";
                        r39."Line No." := a;
                        r39."Código Del Prestamo" := rDet."Código Del Prestamo";
                        r39.INSERT(TRUE);
                        r39.Type := r39.Type::"G/L Account";
                        if rdet.Liquidado Then
                            r39.VALIDATE("No.", Rec."Cuenta L/P")
                        else
                            r39.VALIDATE("No.", Rec."Cuenta Gastos");
                        r39.Description := COPYSTR('Cuota ' + rDet."Código Del Prestamo" + ' per.' + FORMAT(rDet."No. Periodo"), 1,
                        MAXSTRLEN(r39.Description));
                        rgp.SetRange(rGp."VAT Bus. Posting Group", rPro."VAT Bus. Posting Group");
                        rGp.SETRANGE(rGp."VAT %", Rec.Iva);
                        rGp.FINDLAST;
                        r39."Gen. Prod. Posting Group" := 'EXTERIOR';
                        r39.VALIDATE("VAT Bus. Posting Group", rPro."VAT Bus. Posting Group");
                        r39.VALIDATE("VAT Prod. Posting Group", rGp."VAT Prod. Posting Group");
                        r39.VALIDATE(Quantity, 1);
                        r39."Código Del Prestamo" := rDet."Código Del Prestamo";
                        r39.VALIDATE("Direct Unit Cost", ROUND((rDet."A pagar" - rDet.Seguro - rDet.Mantenimiento) / (1 + Rec.Iva / 100), 0.01, '='));
                        r39.MODIFY;
                        if rDet.Seguro <> 0 then begin
                            a += 10000;
                            rPro.Get(Rec."Proveedor Leasing");
                            r39."Document Type" := r39."Document Type"::Invoice;
                            r39."Document No." := r38."No.";
                            r39."Line No." := a;
                            r39.INSERT(TRUE);
                            r39.Type := r39.Type::"G/L Account";
                            if rdet.Liquidado Then
                                r39.VALIDATE("No.", Rec."Cuenta L/P")
                            else
                                r39.VALIDATE("No.", Rec."Cuenta C/P");
                            r39.Description := COPYSTR('Seguro ' + rDet."Código Del Prestamo" + ' per.' + FORMAT(rDet."No. Periodo"), 1,
                            MAXSTRLEN(r39.Description));
                            rgp.SetRange(rGp."VAT Bus. Posting Group", rPro."VAT Bus. Posting Group");
                            rGp.SETRANGE(rGp."VAT %", Rec.Iva);
                            rGp.FINDLAST;
                            r39."Gen. Prod. Posting Group" := 'EXTERIOR';
                            r39.VALIDATE("VAT Bus. Posting Group", rPro."VAT Bus. Posting Group");
                            r39.VALIDATE("VAT Prod. Posting Group", rGp."VAT Prod. Posting Group");
                            r39.VALIDATE(Quantity, 1);
                            r39."Código Del Prestamo" := rDet."Código Del Prestamo";
                            r39.VALIDATE("Direct Unit Cost", ROUND((rDet.Seguro) / (1 + Rec.Iva / 100), 0.01, '='));
                            r39.MODIFY;
                        End;
                        if rDet.Mantenimiento <> 0 then begin
                            a += 10000;
                            rPro.Get(Rec."Proveedor Leasing");
                            r39."Document Type" := r39."Document Type"::Invoice;
                            r39."Document No." := r38."No.";
                            r39."Line No." := a;
                            r39.INSERT(TRUE);
                            r39.Type := r39.Type::"G/L Account";
                            if rdet.Liquidado Then
                                r39.VALIDATE("No.", Rec."Cuenta L/P")
                            else
                                r39.VALIDATE("No.", Rec."Cuenta intrereses");
                            r39.Description := COPYSTR('Mto. ' + rDet."Código Del Prestamo" + ' per.' + FORMAT(rDet."No. Periodo"), 1,
                            MAXSTRLEN(r39.Description));
                            rgp.SetRange(rGp."VAT Bus. Posting Group", rPro."VAT Bus. Posting Group");
                            rGp.SETRANGE(rGp."VAT %", Rec.Iva);
                            rGp.FINDLAST;
                            r39."Gen. Prod. Posting Group" := 'EXTERIOR';
                            r39.VALIDATE("VAT Bus. Posting Group", rPro."VAT Bus. Posting Group");
                            r39.VALIDATE("VAT Prod. Posting Group", rGp."VAT Prod. Posting Group");
                            r39.VALIDATE(Quantity, 1);
                            r39."Código Del Prestamo" := rDet."Código Del Prestamo";
                            r39.VALIDATE("Direct Unit Cost", ROUND((rDet.Mantenimiento) / (1 + Rec.Iva / 100), 0.01, '='));
                            r39.MODIFY;
                        End;
                        rDet.Facturado := true;
                        rDet.Modify();
                        Cab.Get(rDet."Código Del Prestamo");
                        Cab."Importe Pendiente" := Cab."Importe Pendiente" - rDet."A Pagar";
                        Commit();

                        Page.RunModal(Page::"Purchase Invoice", r38);
                    END;
                }
                action("marcar como Facturado")
                {
                    Image = Check;
                    ApplicationArea = All;
                    trigger OnAction()
                    var
                        Cab: Record "Cabecera Prestamo";
                    begin
                        CurrPage.Fdet.Page.GETRECORD(rDet);
                        rDet.Facturado := true;
                        rDet.Modify();
                        Cab.Get(rDet."Código Del Prestamo");
                        Cab."Importe Pendiente" := Cab."Importe Pendiente" - rDet."A Pagar";
                        Commit();
                    end;
                }

                action("Prevision")
                {
                    ApplicationArea = All;
                    Image = Forecast;
                    ShortCutKey = F11;
                    Caption = 'Prevision Mensual';
                    trigger OnAction()
                    VAR
                        r38: Record 38;
                        r39: Record 39;
                        rGp: Record 325;
                    BEGIN
                        CurrPage.Fdet.Page.SetSelectionFilter(rDet);
                        if rDet.FindFirst() Then
                            repeat
                                recLinDiario.INIT;
                                CLEAR(recLinDiario);
                                SeccionDIario.GET('GENERAL', 'GENERICO');
                                recLinDiario.SETRANGE(recLinDiario."Journal Template Name", 'GENERAL');
                                recLinDiario.SETRANGE(recLinDiario."Journal Batch Name", 'GENERICO');
                                a := 10000;
                                if recLinDiario.FIND('+') THEN a := recLinDiario."Line No." + 10000;
                                recLinDiario."Line No." := a;
                                recLinDiario."Posting Date" := rDet.Fecha;
                                recLinDiario."Journal Template Name" := 'GENERAL';
                                recLinDiario."Journal Batch Name" := 'GENERICO';
                                SeccionDIario.TESTFIELD("No. Series");
                                recLinDiario."Document Type" := recLinDiario."Document Type"::Receipt;
                                recLinDiario."Document No." := NumeroSerie.GetNextNo(SeccionDIario."No. Series", 0D, FALSE);
                                recLinDiario."Account Type" := recLinDiario."Account Type"::"G/L Account";
                                recLinDiario."Account No." := Rec."Cuenta Gastos";
                                recLinDiario.Description := COPYSTR('Cuota ' + rDet."Código Del Prestamo" + ' per.' + FORMAT(rDet."No. Periodo"), 1,
                                MAXSTRLEN(recLinDiario.Description));
                                recLinDiario.VALIDATE("Debit Amount", ROUND((rDet."A pagar" - rDet.Seguro - rDet.Mantenimiento) / (1 + Rec.Iva / 100), 0.01, '='));
                                recLinDiario."Bal. Account Type" := recLinDiario."Bal. Account Type"::"G/L Account";
                                recLinDiario."Bal. Account No." := '';
                                recLinDiario."Source Type" := recLinDiario."Source Type"::Vendor;
                                recLinDiario."Source No." := Rec."Proveedor Leasing";
                                recLinDiario.INSERT;
                                a := a + 10000;
                                recLinDiario."Line No." := a;
                                recLinDiario."Document Type" := recLinDiario."Document Type"::Receipt;
                                recLinDiario."Posting Date" := rDet.Fecha;
                                recLinDiario."Journal Template Name" := 'GENERAL';
                                recLinDiario."Journal Batch Name" := 'GENERICO';
                                SeccionDIario.TESTFIELD("No. Series");
                                recLinDiario."Document No." := NumeroSerie.GetNextNo(SeccionDIario."No. Series", 0D, FALSE);
                                recLinDiario."Account Type" := recLinDiario."Account Type"::"G/L Account";
                                recLinDiario."Account No." := Rec."Cuenta C/P";
                                recLinDiario.Description := COPYSTR('Seguro ' + rDet."Código Del Prestamo" + ' per.' + FORMAT(rDet."No. Periodo"), 1,
                                MAXSTRLEN(recLinDiario.Description));
                                recLinDiario.VALIDATE("Debit Amount", ROUND(rDet.Seguro / (1 + Rec.Iva / 100), 0.01, '='));
                                recLinDiario."Bal. Account Type" := recLinDiario."Bal. Account Type"::"G/L Account";
                                recLinDiario."Bal. Account No." := '';
                                recLinDiario."Source Type" := recLinDiario."Source Type"::Vendor;
                                recLinDiario."Source No." := Rec."Proveedor Leasing";
                                if rDet.Seguro <> 0 Then
                                    recLinDiario.INSERT;
                                a := a + 10000;
                                recLinDiario."Line No." := a;
                                recLinDiario."Document Type" := recLinDiario."Document Type"::Receipt;
                                recLinDiario."Posting Date" := rDet.Fecha;
                                recLinDiario."Journal Template Name" := 'GENERAL';
                                recLinDiario."Journal Batch Name" := 'GENERICO';
                                SeccionDIario.TESTFIELD("No. Series");
                                recLinDiario."Document No." := NumeroSerie.GetNextNo(SeccionDIario."No. Series", 0D, FALSE);
                                recLinDiario."Account Type" := recLinDiario."Account Type"::"G/L Account";
                                recLinDiario."Account No." := Rec."Cuenta intrereses";
                                recLinDiario.Description := COPYSTR('Mto ' + rDet."Código Del Prestamo" + ' per.' + FORMAT(rDet."No. Periodo"), 1,
                                MAXSTRLEN(recLinDiario.Description));
                                recLinDiario.VALIDATE("Debit Amount", ROUND(rDet.Mantenimiento / (1 + Rec.Iva / 100), 0.01, '='));
                                recLinDiario."Bal. Account Type" := recLinDiario."Bal. Account Type"::"G/L Account";
                                recLinDiario."Bal. Account No." := '';
                                recLinDiario."Source Type" := recLinDiario."Source Type"::Vendor;
                                recLinDiario."Source No." := Rec."Proveedor Leasing";
                                if rDet.Mantenimiento <> 0 Then
                                    recLinDiario.INSERT;
                                a := a + 10000;
                                recLinDiario."Line No." := a;
                                recLinDiario."Document Type" := recLinDiario."Document Type"::Receipt;
                                recLinDiario."Account No." := rec."Cuenta L/P";
                                recLinDiario.VALIDATE("Credit Amount", ROUND(rDet."A pagar" / (1 + Rec.Iva / 100), 0.01, '='));
                                recLinDiario."Source Type" := recLinDiario."Source Type"::Vendor;
                                recLinDiario."Source No." := Rec."Proveedor Leasing";
                                recLinDiario.INSERT;

                                rDet.Liquidado := TRUE;
                                rDet.MODIFY;


                            until rDet.Next() = 0;
                        COMMIT;
                        Page.RunModal(39, recLinDiario);
                        //GenJnlManagement.OpenJnlBatch(SeccionDIario);


                    END;
                }
                action("Recalcular Importe Pendiente")
                {
                    ApplicationArea = All;
                    Image = Recalculate;
                    trigger OnAction()
                    var
                        LinFac: Record "Purch. Inv. Line";
                        LinAbo: Record "Purch. Cr. Memo Line";
                        Cab: Record "Cabecera Prestamo";
                    begin
                        Cab.Get(Rec."Código Del Prestamo");
                        Cab."Importe Pendiente" := Cab."Importe Prestamo";
                        LinFac.SetRange("Buy-from Vendor No.", Cab."Proveedor Leasing");
                        LinFac.SetRange("Código Del Prestamo", Cab."Código Del Prestamo");
                        if LinFac.FindFirst() Then
                            repeat
                                Cab."Importe Pendiente" -= LinFac."Amount Including VAT";
                            until LinFac.Next() = 0;
                        LinAbo.SetRange("Buy-from Vendor No.", Cab."Proveedor Leasing");
                        LinAbo.SetRange("Código Del Prestamo", Cab."Código Del Prestamo");
                        if LinAbo.FindFirst() Then
                            repeat
                                Cab."Importe Pendiente" += LinAbo."Amount Including VAT";
                            until LinAbo.Next() = 0;
                    end;
                }

            }
        }
        area(Navigation)
        {
            group("&Renting")

            {
                Caption = '&Renting';
                action(Lista)
                {
                    ApplicationArea = All;
                    Image = List;
                    ShortCutKey = F5;
                    Caption = 'Lista';
                    RunObject = page "Lista Rentings";
                }
                action(Dimensiones)
                {
                    ApplicationArea = All;
                    Image = Dimensions;
                    ShortCutKey = 'Mayús+Ctrl+D';
                    Caption = 'Dimensiones';
                    RunObject = Page 540;
                    RunPageLink = "Table ID" = CONST(50067),
                            "No." = FIELD("Código Del Prestamo");
                }
                action("Resumen")
                {
                    ApplicationArea = All;
                    Image = Revenue;
                    ShortCutKey = 'Mayús+F9';
                    Caption = 'Resumen';
                    RunObject = Page Rentings;
                }

            }
        }
    }
    VAR
        recLinDiario: Record "Gen. Journal Line";
        SeccionDIario: Record "Gen. Journal Batch";
        NumeroSerie: Codeunit "No. Series";
        a: Integer;
        GenJnlManagement: Codeunit 230;
        rDet: Record "Detalle Prestamo";
        Import: Decimal;
        DefEmpresa: Text[30];

    trigger onOpenPage()
    var
        Control: Codeunit ControlProcesos;
    begin
        If Control.AccesoProibido_Empresas(CompanyName, 'RESTRINGIDO') then
            Error('No tiene permisos para acceder a este punto del menú en esta empresa');


        if DefEmpresa <> '' THEN BEGIN
            Rec.CHANGECOMPANY(DefEmpresa);
            CurrPage.Fdet.Page.Empresa(DefEmpresa);
        END;
    END;

    trigger OnNewRecord(BelowxRex: Boolean)
    begin
        Rec.Renting := true;
    end;

    PROCEDURE Empresa(Cia: Text[30]);
    BEGIN
        DefEmpresa := Cia;
    END;

    //     BEGIN
    //     END.
    //   }
}