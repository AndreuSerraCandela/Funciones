/// <summary>
/// Report Pagaré - T0 (ID 50017).
/// </summary>
report 50014 "Pagaré - T0"
{
    // 001 CAT INC-41452 - Asignación del numero de pagare.
    // 002 19/03/10 PLB: INC-47521. Poder especificar el últ. nº pagaré utilizado antes de imprimir
    DefaultLayout = RDLC;
    RDLCLayout = './src/report/layout/PagaréT0.rdlc';
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;
    UseRequestPage = true;

    dataset
    {
        dataitem("Cartera Doc."; 7000002)
        {
            DataItemTableView = SORTING(Type, "Entry No.");
            column(Cartera_Doc___Due_Date_; "Due Date")
            {
            }
            column(Cartera_Doc___Due_Date__Control2; "Due Date")
            {
            }
            column(rProv_Name; rProv.Name)
            {
            }
            column(Cartera_Doc___Due_Date__Control3; "Due Date")
            {
            }
            column(FORMAT__Original_Amount__0_Text000_; FORMAT("Original Amount", 0, Text000))
            {
            }
            column(UPPERCASE_texto_1__; UPPERCASE(texto[1]))
            {
            }
            column(UPPERCASE_texto_2__; UPPERCASE(texto[2]))
            {
            }
            column(Cartera_Doc___Posting_Date_; "Posting Date")
            {
            }
            column(Cartera_Doc___Posting_Date__Control6; "Posting Date")
            {
            }
            column(rEmpresa_City___Text001; rEmpresa.City + Text001)
            {
            }
            column(Cartera_Doc___Posting_Date__Control4; "Posting Date")
            {
            }
            column(Cartera_Doc__Type; Type)
            {
            }
            column(Cartera_Doc__Entry_No_; "Entry No.")
            {
            }

            trigger OnAfterGetRecord()
            begin
                if NOT rBanco.GET("Cartera Doc.".Banco) THEN
                    CLEAR(rBanco);
                if NOT rProv.GET("Cartera Doc."."Account No.") THEN
                    CLEAR(rProv);

                CLEAR(rCheque);
                //rCheque.PasarDivisa("Cartera Doc."."Currency Code");
                rCheque.FormatNoText(texto, "Cartera Doc."."Original Amount", "Cartera Doc."."Currency Code");
                texto[1] := PADSTR(texto[1], MAXSTRLEN(texto[1]) - 7, '#');
                texto[2] := PADSTR(texto[2], MAXSTRLEN(texto[2]), '#');

                //+001
                if "Cartera Doc."."¨Esta Impreso?" = "Cartera Doc."."¨Esta Impreso?"::No THEN BEGIN
                    // "Cartera Doc."."Nº Impreso" := cGestionpagare.ObtenerNumeroPagare("Cartera Doc.".Banco);
                    "Cartera Doc."."¨Esta Impreso?" := "Cartera Doc."."¨Esta Impreso?"::Si;
                    "Cartera Doc.".MODIFY;
                END;
                //-001
            end;
        }
    }

    requestpage
    {
        Caption = 'Pagaré - T0 Banco Popular';

        layout
        {
            area(content)
            {
                group(Options)
                {
                    Caption = 'Opciones';
                    field(CtrlBanco; rUsre.Code20)
                    {
                        ApplicationArea = All;
                        Caption = 'Banco';
                        Editable = false;
                    }
                    field(CtrlPagare; wPagare)
                    {
                        ApplicationArea = All;
                        Caption = 'Último número de pagaré';
                        Editable = CtrlPagareEditable;

                        trigger OnValidate()
                        begin
                            wPagareOnAfterValidate;
                        end;
                    }
                }
            }
        }

        actions
        {
        }

        trigger OnInit()
        begin
            CtrlPagareEditable := TRUE;
        end;

        trigger OnOpenPage()
        begin
            CtrlPagareEditable := TRUE;// NOT rUsr.Boolean9;
        end;
    }

    labels
    {
    }

    trigger OnInitReport()
    begin
        rUsre.GET(USERSECURITYID);
        //wPagare := cGestionpagare.ObtenerUltimoPagare(rUsr.Code20);
        rEmpresa.GET;
    end;

    var
        Text000: Label '####<Sign><Integer Thousand><Decimals>####';
        Text001: Label ', to';
        rProv: Record Vendor;
        rMovProv: Record 25;
        rEmpresa: Record 79;
        rBanco: Record 270;
        rUsre: Record "User Setup";
        PasoParam: Record 85;
        texto: array[2] of Text[80];
        rCheque: Report CheckKuara;
        wPagare: Code[20];
        Text003: Label 'No puede dejar el último nº de pagaré en blanco';

        CtrlPagareEditable: Boolean;

    local procedure wPagareOnAfterValidate()
    begin
        if wPagare = '' THEN
            ERROR(Text003);

        if (rBanco."Ult. nº pagare" = '') AND (wPagare = rBanco."Nº Inicial pagare") THEN
            EXIT;
        if wPagare = rBanco."Ult. nº pagare" THEN
            EXIT;
        rBanco."Ult. nº pagare" := wPagare;
        rBanco.MODIFY;
    end;
}

