/// <summary>
/// Page Lista de Fact. Buzón Entrada (ID 50074).
/// </summary>
page 50074 "Lista de Fact. Buzón Entrada"
{

    PageType = List;
    UsageCategory = Lists;
    ApplicationArea = All;
    SaveValues = true;
    InsertAllowed = false;
    DeleteAllowed = false;
    ModifyAllowed = false;
    SourceTable = "Sales Header";
    //TimerInterval =10;
    SourceTableView = SORTING("Document Type", "No.")
                    WHERE("Document Type" = FILTER(Invoice | Order | "Credit Memo"),
                          "On Hold" = CONST('ASC'));

    layout
    {
        area(Content)
        {
            Repeater(Detalle)
            {
                field("Document Type"; Rec."Document Type") { ApplicationArea = All; }
                field("Bill-to Customer No."; Rec."Bill-to Customer No.") { ApplicationArea = All; }
                field("No."; Rec."No.") { ApplicationArea = All; }
                field("Posting Date"; Rec."Posting Date") { ApplicationArea = All; }
                field("Posting Description"; Rec."Posting Description") { ApplicationArea = All; }
                field(Import; Importe(Rec."No."))
                {
                    ApplicationArea = All;
                    Caption = 'Importe';

                    trigger OnDrillDown()
                    VAR
                        r37: Record 37;
                    BEGIN
                        r37.SETRANGE(r37."Document Type", Rec."Document Type");
                        r37.SETRANGE(r37."Document No.", Rec."No.");
                        PAGE.RUNMODAL(0, r37);
                    END;
                }
                field(ImportIva; ImporteIva(Rec."No."))
                {
                    ApplicationArea = All;
                    Caption = 'Importe Incl. Iva';
                    trigger OnDrillDown()
                    VAR
                        r37: Record 37;
                    BEGIN
                        r37.SETRANGE(r37."Document Type", Rec."Document Type");
                        r37.SETRANGE(r37."Document No.", Rec."No.");
                        PAGE.RUNMODAL(0, r37);
                    END;
                }
            }
            usercontrol(MyTimer; MyTimer)
            {
                ApplicationArea = Basic;

                trigger TimerElapsed()
                VAR
                    r36: Record 36;
                    rCus: Record Customer;
                    r37: Record 37;
                    rRes: Record 156;
                begin
                    CurrPage.MyTimer.StopTimer();
                    if NOT Valorado THEN BEGIN
                        r36.SETFILTER(r36."Document Type", '%1|%2', r36."Document Type"::Invoice, r36."Document Type"::Order);
                        r36.SETRANGE("On Hold", 'ASC');
                        if r36.FINDFIRST THEN
                            REPEAT
                                if NOT rCus.GET(r36."Bill-to Customer No.") THEN
                                    if NOT rCus.GET(r36."Sell-to Customer No.") THEN BEGIN
                                        rCus.INIT;
                                        rCus."VAT Bus. Posting Group" := 'NACIONAL';
                                    END;
                                if rCus."VAT Bus. Posting Group" = '' THEN rCus."VAT Bus. Posting Group" := 'NACIONAL';
                                r37.SETRANGE(r37."Document Type", r36."Document Type");
                                r37.SETRANGE(r37."Document No.", r36."No.");
                                if r37.FINDFIRST THEN
                                    REPEAT
                                        r37."VAT Bus. Posting Group" := rCus."VAT Bus. Posting Group";
                                        if rRes.GET(r37."No.") THEN
                                            r37."VAT Prod. Posting Group" := rRes."VAT Prod. Posting Group";
                                        r37.MODIFY;
                                    UNTIL r37.NEXT = 0;
                            UNTIL r36.NEXT = 0;
                        Valorado := TRUE;
                    END;
                    CurrPage.MyTimer.StartTimer();
                end;
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
                action("Aceptar Factura/Contrato")
                {
                    ApplicationArea = All;
                    Caption = 'Aceptar Factura/Contrato';
                    trigger OnAction()
                    VAR
                        r37: Record 37;
                        r37r: Record 37 TEMPORARY;
                        ReleaseSalesDoc: Codeunit 414;
                        rRes: Record 156;
                    BEGIN
                        if Rec."Currency Factor" = 0 THEN Rec."Currency Factor" := 1;
                        r37.SETRANGE(r37."Document Type", Rec."Document Type");
                        r37.SETRANGE(r37."Document No.", Rec."No.");
                        if r37.FINDFIRST THEN
                            REPEAT
                                r37r := r37;
                                if (r37."No." <> '') AND ((r37.Type.AsInteger() = 0) or (r37.Type = r37.Type::"G/L Account")) THEN BEGIN
                                    if rRes.GET(r37."No.") THEN
                                        r37r.Type := r37r.Type::Resource
                                    ELSE
                                        r37r.Type := r37r.Type::"G/L Account";
                                END;
                                if (r37."No." <> '') AND (r37.Type = r37.Type::Resource) THEN BEGIN
                                    if rRes.GET(r37."No.") THEN
                                        r37r.Type := r37r.Type::Resource
                                    ELSE
                                        r37r.Type := r37r.Type::"G/L Account";
                                END;

                                r37r.INSERT;
                            UNTIL r37.NEXT = 0;
                        Rec."Sell-to Customer No." := Rec."Bill-to Customer No.";
                        Rec.VALIDATE("Sell-to Customer No.", Rec."Bill-to Customer No.");
                        Rec.MODIFY;
                        if r37r.FINDFIRST THEN
                            REPEAT
                                if not r37.GET(r37r."Document Type", r37r."Document No.", r37r."Line No.") Then begin
                                    r37 := r37r;
                                    r37.Insert;
                                end;

                                r37.Type := r37r.Type;
                                r37."Sell-to Customer No." := Rec."Sell-to Customer No.";
                                r37.VALIDATE(r37."No.", r37r."No.");
                                r37.VALIDATE(r37.Quantity, r37r.Quantity);
                                r37.VALIDATE(r37."Unit Price", r37r."Unit Price");
                                r37.VALIDATE(r37."Line Discount %", r37r."Line Discount %");
                                r37.Description := r37r.Description;
                                r37."Description 2" := r37r."Description 2";
                                r37.MODIFY;
                            //end;
                            UNTIL r37r.NEXT = 0;
                        Rec."On Hold" := '';
                        Rec.MODIFY;
                        ReleaseSalesDoc.PerformManualRelease(Rec);
                    END;
                }
                action("Rechazar factura/Contrato")
                {
                    ApplicationArea = All;
                    Caption = 'Rechazar factura/Contrato';
                    trigger OnAction()
                    VAR
                        r37: Record 37;
                        rProy: Record 167;
                    BEGIN
                        if CONFIRM('Esta serguro que quiere borrar la factura', FALSE) THEN BEGIN
                            r37.SETRANGE(r37."Document Type", Rec."Document Type");
                            r37.SETRANGE(r37."Document No.", Rec."No.");
                            r37.DELETEALL;
                            if rProy.GET(Rec."Nº Proyecto") THEN rProy.DELETE;
                            Rec.DELETE;
                        END;
                    END;
                }
            }
        }
    }
    VAR
        TotalSalesLine: Record 37;
        TotalSalesLineLCY: Record 37;
        RegisVtas: Codeunit 80;
        wDecimal: Decimal;
        wTexto: Text[30];
        Valorado: Boolean;

    trigger OnAfterGetCurrRecord()
    begin
        CurrPage.MyTimer.SetTimerInterval(10000);
        CurrPage.MyTimer.StartTimer();
    end;



    PROCEDURE CalcularTotales(pNumDoc: Code[20]; Tipo: Integer): Decimal;
    VAR
        TempSalesLine: Record 37 TEMPORARY;
        r36: Record 36;
        rRes: Record 156;
        rCus: Record Customer;
    BEGIN
        //FCL-04/05/04. Obtengo total y total iva incluído, ya no me sirve el campo calculado
        // porque estos importes están a cero en las líneas.
        // JML 150704 Modificado para poder filtrar por fase.
        // $001 por tarea
        COMMIT;
        if NOT r36.GET(r36."Document Type"::Order, pNumDoc) THEN
            if NOT r36.GET(r36."Document Type"::Invoice, pNumDoc) THEN EXIT(0);
        CLEAR(TotalSalesLine);
        CLEAR(TotalSalesLineLCY);

        if pNumDoc <> '' THEN BEGIN
            CLEAR(RegisVtas);
            CLEAR(TempSalesLine);
            RegisVtas.GetSalesLines(r36, TempSalesLine, 0);
            CLEAR(RegisVtas);
            RegisVtas.SumSalesLinesTemp(
              r36, TempSalesLine, 0, TotalSalesLine, TotalSalesLineLCY,
              wDecimal, wTexto, wDecimal, wDecimal, wDecimal);
            TempSalesLine.SETRANGE(TempSalesLine."Document No.", pNumDoc);

            //  JML 150704
            //  RegisVtas.SumSalesLinesTempFase(Rec,TempSalesLine,0,TotalSalesLine,
            //                              TotalSalesLineLCY, GETFILTER("Filtro fase"));

        END;
        if Tipo = 0 THEN EXIT(TotalSalesLineLCY.Amount);
        EXIT(TotalSalesLineLCY."Amount Including VAT");
    END;

    PROCEDURE Importe(n: Code[20]): Decimal;
    BEGIN
        if Valorado THEN
            EXIT(CalcularTotales(n, 0));
    END;

    PROCEDURE ImporteIva(n: Code[20]): Decimal;
    BEGIN
        if Valorado THEN
            EXIT(CalcularTotales(n, 1));
    END;

}