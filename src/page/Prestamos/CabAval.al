
/// <summary>
/// Page Cabecera Aval (ID 50072).
/// </summary>
page 50072 "Cabecera Aval"
{
    Caption = 'Cabecera Aval';
    SourceTable = "Cabecera Prestamo";
    SourceTableView = WHERE(Empresa = FILTER(''), Aval = const(true));
    PageType = Card;
    layout
    {
        area(Content)
        {
            group(General)
            {
                field("Código Del Aval"; Rec."Código Del Prestamo") { Caption = 'Código Del Aval'; ApplicationArea = All; }
                field(Descripción; Rec."Cabecera Prestamo2") { Caption = 'Descripción'; ApplicationArea = All; }
                field("Fecha Inicio Aval"; Rec."Fecha Préstamo") { Caption = 'Fecha Inicio Aval'; ApplicationArea = All; }
                field("Fecha Contabilización"; Rec."Fecha 1ª Amortización") { Caption = 'Fecha contabilización'; ToolTip = 'Fecha del único asiento contable del aval.'; ApplicationArea = All; }
                field("Importe Aval"; Rec."Importe Prestamo") { Caption = 'Importe Aval'; ApplicationArea = All; }
                field(Años; Rec."Años") { ApplicationArea = All; Editable = false; }
                field("Cuotas Anuales"; Rec."Cuotas Anuales") { ApplicationArea = All; Editable = false; }
                field(Banco; Rec.Banco) { ApplicationArea = All; }
                field(Meses; Rec.Meses) { ApplicationArea = All; Editable = false; ToolTip = 'Los avales generan un único periodo (1).'; }
                field("Global Dimension 1 Code"; Rec."Global Dimension 1 Code") { ApplicationArea = All; CaptionClass = '1,1,1'; }
                field("Global Dimension 2 Code"; Rec."Global Dimension 2 Code") { ApplicationArea = All; CaptionClass = '1,1,2'; }
                field("Global Dimension 3 Code"; Rec."Global Dimension 3 Code") { ApplicationArea = All; CaptionClass = '1,2,3'; }
                field("Global Dimension 4 Code"; Rec."Global Dimension 4 Code") { ApplicationArea = All; CaptionClass = '1,2,4'; }
                field("Global Dimension 5 Code"; Rec."Global Dimension 5 Code") { ApplicationArea = All; CaptionClass = '1,2,5'; }
                // field("Proveedor"; Rec."Proveedor Leasing") { Caption = 'Proveedor'; ApplicationArea = All; }
                // field("Cuenta Previsión"; Rec."Cuenta L/P") { Caption = 'Cuenta Prevision'; ApplicationArea = All; }
                field("Cuenta Gastos"; Rec."Cuenta Gastos") { Caption = 'Cuenta gastos'; ApplicationArea = All; }
                // field("Cuenta C/P"; Rec."Cuenta C/P") { Caption = 'Cuenta seguro'; ApplicationArea = All; }
                // field("Cuenta intrereses"; Rec."Cuenta intrereses") { Caption = 'Cuenta mantenimiento'; ApplicationArea = All; }
                field("Cuota"; Rec."Interes Anual") { Caption = 'Cuota Mensual'; ApplicationArea = All; }
                // field("Seguro"; Rec."Seguro") { Caption = 'Seguro Iva Incl.'; ApplicationArea = All; }
                // field("Mantenimiento"; Rec.Mantenimiento) { Caption = 'Mantenimiento Iva Incl.'; ApplicationArea = All; }
                // field(Iva; Rec.Iva) { Caption = '% Iva'; ApplicationArea = All; }
                //field("Valor Residual"; Rec."Valor Residual") { ApplicationArea = All; }
            }
            part(Fdet; "Detalle Aval")
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
                        r5801t: Record "Detalle Prestamo" TEMPORARY;
                        PosPo31: Integer;
                        Desde: Date;
                        Hasta: Date;
                        Dia: Integer;
                    BEGIN
                        if NOT CONFIRM('Esta Seguro?', FALSE) THEN EXIT;
                        r5801.SETRANGE(r5801."Código Del Prestamo", Rec."Código Del Prestamo");
                        if r5801.FindLast() then begin
                            Desde := r5801.Hasta;
                            if Desde = 0D then
                                Desde := Rec."Fecha Préstamo";
                            Desde := Today;
                            //Si r5801.Fecha  y r5801.Hasta son diferentes de 0d, calcula el proximo hasta a partir del hasta anterio + la diferencia entre fecha y hasta
                            if (r5801.Fecha <> 0D) and (r5801.Hasta <> 0D) then begin
                                Dia := r5801.Hasta - r5801.Fecha;
                                Hasta := r5801.Hasta + Dia;

                            end

                            else
                                Hasta := CalcDate('1M', Desde);
                        end;

                        Rec.Meses := r5801.Count + 1;
                        Rec.Modify();
                        r5801.INIT;
                        r5801."Código Del Prestamo" := Rec."Código Del Prestamo";
                        r5801."No. Periodo" := Rec.Meses;
                        if Desde <> 0D then
                            r5801.Fecha := Desde
                        else
                            r5801.Fecha := Rec."Fecha Préstamo";
                        r5801."Hasta" := Hasta;
                        r5801."Total Liquidación" := Rec."Interes Anual";
                        r5801."A Pagar" := Rec."Interes Anual";
                        r5801.Seguro := 0;
                        // En la descripcion del Prestamo, se ha puesto % 1, sustituirlo por la fecha
                        PosPo31 := StrPos(Rec."Cabecera Prestamo2", '%1');
                        If PosPo31 > 0 Then
                            r5801.Descripción := CopyStr(Rec."Cabecera Prestamo2", 1, PosPo31 - 1) + Format(Desde, 0, '<Day,2>/<Month,2>/<Year>') + '-' + Format(Hasta, 0, '<Day,2>/<Month,2>/<Year>') + CopyStr(Rec."Cabecera Prestamo2", PosPo31 + 2, MAXSTRLEN(Rec."Cabecera Prestamo2"))
                        Else
                            r5801.Descripción := Rec."Cabecera Prestamo2";
                        r5801.Mantenimiento := 0;
                        if r5801t.Get(r5801."Código Del Prestamo", r5801."No. Periodo") then begin
                            r5801.Liquidado := r5801t.Liquidado;
                            r5801."Hasta" := r5801t."Hasta";
                        end;
                        r5801.Facturado := false;
                        r5801.INSERT;

                    END;

                }

                action("Prevision")
                {
                    ApplicationArea = All;
                    Image = Forecast;
                    ShortCutKey = F11;
                    Caption = 'Asientos contables';
                    trigger OnAction()
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
                                recLinDiario."Document Type" := recLinDiario."Document Type"::" ";
                                recLinDiario."Document No." := NumeroSerie.GetNextNo(SeccionDIario."No. Series", 0D, FALSE);
                                recLinDiario."Account Type" := recLinDiario."Account Type"::"G/L Account";
                                recLinDiario."Account No." := Rec."Cuenta Gastos";
                                recLinDiario.Description := rdet."Descripción";
                                recLinDiario.VALIDATE("Debit Amount", ROUND((rDet."A pagar" - rDet.Seguro - rDet.Mantenimiento) / (1 + Rec.Iva / 100), 0.01, '='));
                                recLinDiario."Bal. Account Type" := recLinDiario."Bal. Account Type"::"Bank Account";
                                recLinDiario."Bal. Account No." := Rec.Banco;
                                SetShortcutDimsGenJnlFromCab(recLinDiario, Rec);
                                recLinDiario.Insert(true);




                                rDet.Liquidado := TRUE;
                                rDet.MODIFY;


                            until rDet.Next() = 0;
                        COMMIT;
                        Page.RunModal(39, recLinDiario);
                        //GenJnlManagement.OpenJnlBatch(SeccionDIario);


                    END;
                }
            }
        }
        area(Navigation)
        {
            group("&Avales")

            {
                Caption = '&Avales';
                action(Lista)
                {
                    ApplicationArea = All;
                    Image = List;
                    ShortCutKey = F5;
                    Caption = 'Lista Avales';
                    RunObject = page "Lista Avales";
                }
                action(Dimensiones)
                {
                    ApplicationArea = All;
                    Image = Dimensions;
                    ShortCutKey = 'Mayús+Ctrl+D';
                    Caption = 'Dimensiones';
                    RunObject = Page 540;
                    RunPageLink = "Table ID" = CONST(7001164),
                            "No." = FIELD("Código Del Prestamo");
                }
                action("Resumen")
                {
                    ApplicationArea = All;
                    Image = Revenue;
                    ShortCutKey = 'Mayús+F9';
                    Caption = 'Resumen Avales';
                    RunObject = Page Avales;
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
        Rec.Aval := true;
        Rec.Meses := 1;
    end;

    PROCEDURE Empresa(Cia: Text[30]);
    BEGIN
        DefEmpresa := Cia;
    END;

    local procedure SetShortcutDimsGenJnlFromCab(var GenJnlLine: Record "Gen. Journal Line"; Cab: Record "Cabecera Prestamo")
    begin
        GenJnlLine.ValidateShortcutDimCode(1, Cab."Global Dimension 1 Code");
        GenJnlLine.ValidateShortcutDimCode(2, Cab."Global Dimension 2 Code");
        GenJnlLine.ValidateShortcutDimCode(3, Cab."Global Dimension 3 Code");
        GenJnlLine.ValidateShortcutDimCode(4, Cab."Global Dimension 4 Code");
        GenJnlLine.ValidateShortcutDimCode(5, Cab."Global Dimension 5 Code");
    end;

    //     BEGIN
    //     END.
    //   }
}