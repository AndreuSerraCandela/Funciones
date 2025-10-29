/// <summary>
/// Report Letras (ID 50006).
/// </summary>
report 50005 "Letras"
{
    // 001 CAT INC-41452 - Asignación del numero de pagare.
    // 002 19/03/10 PLB: INC-47521. Poder especificar el últ. nº pagaré utilizado antes de imprimir
    DefaultLayout = RDLC;
    RDLCLayout = './src/report/layout/Letras.rdlc';
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;
    UseRequestPage = true;

    dataset
    {
        dataitem("Sales Header"; 36)
        {
            DataItemTableView = SORTING("Document Type", "No.") WHERE("Document Type" = FILTER(Order));
            RequestFilterFields = "No.";
            //MaxIteration = 1;
            dataitem("Cartera Doc."; "Facturas Propuestas")
            {
                DataItemLinkReference = "Sales Header";
                DataItemLink = "No. Contrato" = FIELD("No.");
                column(Order_Date; "Sales Header"."Order Date")
                {
                }
                column(Fecha_Vencimiento; "Fecha Vencimiento")
                {
                }
                column(Banco_CCCNo; rBanco."CCC Bank No.")
                { }
                column(Banco_BranchNo; rBanco."CCC Bank Branch No.")
                { }
                column(BancoDC; rBanco."CCC Control Digits")
                { }
                column(BancoAccNo; rBanco."CCC Bank Account No.")
                {

                }
                column(Cartera_Doc__Entry_No_; "Cartera Doc."."No. Borrador Factura")
                { }
                column(Iban; Iban)
                { }
                column(Cliente_Name; rProv.Name)
                {
                }
                column(CIF; rprov."VAT Registration No.")
                {

                }
                column(Cliente_Direccion; rprov.Address)
                { }
                column(Cliente_City; rProv.City)
                { }
                column(Cliente_CP; rProv."Post Code")
                { }
                column(Cliente_County; rProv.County)
                { }
                column(Cliente; "Sales Header"."Sell-to Customer No.")
                {
                }
                column(FORMAT__Original_Amount__0_Text000_; FORMAT("Importe con IVA", 0, Text000))
                {
                }
                column(UPPERCASE_texto_1__; UPPERCASE(texto[1]))
                {
                }
                column(UPPERCASE_texto_2__; UPPERCASE(texto[2]))
                {
                }
                column(No_Factura; "Sales Header"."No.")
                {
                }
                column(Vendedor; "Sales Header"."Salesperson Code")
                { }
                column(ToTal_Doc; wToTal)
                {
                }
                column(Ciudad; rEmpresa.City)// + Text001)
                {
                }
                column(Fecha_Factura; "Fecha factura")
                {
                }
                column(Nombre_Empresa; rEmpresa.Name)
                {
                }
                column(Unidad; wUnidad)
                {
                }

                trigger OnPreDataItem()
                var

                begin
                    if Not rContrato.Get(rContrato."Document Type"::Order, "No. Contrato") Then rContrato.Init();
                    if NOT rBanco.GET("Sales Header"."Sell-to Customer No.", rContrato."Cust. Bank Acc. Code") THEN begin
                        rBanco.SetRange("Customer No.", "Sales Header"."Sell-to Customer No.");
                        if not rBanco.FindFirst() then
                            CLEAR(rBanco);
                    end;
                    if NOT rProv.GET("Sales Header"."Sell-to Customer No.") THEN
                        CLEAR(rProv);

                    rProp.RESET;
                    rProp.SETRANGE("No. Contrato", "Sales Header"."No.");
                    rProp.SETRANGE("Factura 1", FALSE);                          //$003
                    if rProp.FINDSET THEN
                        wTotal := rProp.COUNT;

                    wUnidad := 0;
                end;

                trigger OnAfterGetRecord()
                begin
                    wUnidad += 1;
                    CLEAR(rCheque);
                    //rCheque.PasarDivisa("Cartera Doc."."Currency Code");
                    rCheque.FormatNoText(texto, "Cartera Doc."."Importe Con Iva", '');
                    texto[1] := PADSTR(texto[1], MAXSTRLEN(texto[1]) - 7, '#');
                    texto[2] := PADSTR(texto[2], MAXSTRLEN(texto[2]), '#');

                    //+001
                    // if "Cartera Doc."."¿Esta Impreso?" = "Cartera Doc."."¿Esta Impreso?"::No THEN BEGIN
                    //     // "Cartera Doc."."Nº Impreso" := cGestionpagare.ObtenerNumeroPagare("Cartera Doc.".Banco);
                    //     "Cartera Doc."."¿Esta Impreso?" := "Cartera Doc."."¿Esta Impreso?"::Si;
                    //     "Cartera Doc.".MODIFY;
                    // END;
                    //-001
                end;
            }
        }
    }

    requestpage
    {
        Caption = 'Letras';

        // layout
        // {
        //     area(content)
        //     {
        //         group(Options)
        //         {
        //             Caption = 'Opciones';
        //             field(CtrlBanco; rUsre.Code20)
        //             {
        //                 ApplicationArea = All;
        //                 Caption = 'Banco';
        //                 Editable = false;
        //             }
        //             field(CtrlPagare; wPagare)
        //             {
        //                 ApplicationArea = All;
        //                 Caption = 'Último número de pagaré';
        //                 Editable = CtrlPagareEditable;

        //                 trigger OnValidate()
        //                 begin
        //                     wPagareOnAfterValidate;
        //                 end;
        //             }
        //         }
        //     }
        // }

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
        rUsre.GET(UserId);
        //wPagare := cGestionpagare.ObtenerUltimoPagare(rUsr.Code20);
        rEmpresa.GET;
    end;

    var
        rProp: Record "Facturas Propuestas";
        wTotal: Integer;
        wUnidad: Integer;
        Text000: Label '####<Sign><Integer Thousand><Decimals>####';
        Text001: Label ', to';
        rProv: Record Customer;
        rEmpresa: Record 79;
        rBanco: Record "Customer Bank Account";
        rUsre: Record "User Setup";
        PasoParam: Record 85;
        texto: array[2] of Text[80];
        rCheque: Report CheckKuara;
        wPagare: Code[20];

        CtrlPagareEditable: Boolean;
        Mes: array[12] of Text;
        Dia: array[31] of Text;
        rContrato: Record "Sales Header";

    Procedure TablaMeses()
    Begin
        Mes[1] := 'Enero';
        Mes[2] := 'Febrero';
        Mes[3] := 'Marzo';
        Mes[4] := 'Abril';
        Mes[5] := 'Mayo';
        Mes[6] := 'Junio';
        Mes[7] := 'Julio';
        Mes[8] := 'Agosto';
        Mes[9] := 'Septiembre';
        Mes[10] := 'Octubre';
        Mes[11] := 'Noviembre';
        Mes[12] := 'Diciembre';
    End;

    Procedure TablaDias()
    Begin
        Dia[1] := 'Uno';
        Dia[2] := 'Dos';
        Dia[3] := 'Tres';
        Dia[4] := 'Cuatro';
        Dia[5] := 'Cinco';
        Dia[6] := 'Seis';
        Dia[7] := 'Siete';
        Dia[8] := 'Ocho';
        Dia[9] := 'Nueve';
        Dia[10] := 'Diez';
        Dia[11] := 'Once';
        Dia[12] := 'Doce';
        Dia[13] := 'Trece';
        Dia[14] := 'Catorce';
        Dia[15] := 'Quince';
        Dia[16] := 'Dieciseis';
        Dia[17] := 'Diecisiete';
        Dia[18] := 'Dieciocho';
        Dia[19] := 'Diecinueve';
        Dia[20] := 'Veinte';
        Dia[21] := 'Veintiuno';
        Dia[22] := 'Veintidos';
        Dia[23] := 'Veintitres';
        Dia[24] := 'Veinticuatro';
        Dia[25] := 'Veinticinco';
        Dia[26] := 'Veintiseis';
        Dia[27] := 'Veintisiete';
        Dia[28] := 'Veintiocho';
        Dia[29] := 'Veintinueve';
        Dia[30] := 'Treinta';
        Dia[31] := 'Treinta y uno';
    End;

    Procedure Iban(): Text[200]
    Begin
        if rBanco.IBAN <> '' THEN
            EXIT('IBAN: ' + COPYSTR(rBanco.IBAN, 1, 4) + ' ' +
                    COPYSTR(rBanco.IBAN, 5, 4) + ' ' +
                    COPYSTR(rBanco.IBAN, 9, 4) + ' ' +
                    COPYSTR(rBanco.IBAN, 13, 4) + ' ' +
                    COPYSTR(rBanco.IBAN, 17, 4) + ' ' +
                    COPYSTR(rBanco.IBAN, 21, 4) + ' ' +
                    COPYSTR(rBanco.IBAN, 25, 4) + ' ' +
                    COPYSTR(rBanco.IBAN, 29, 4))
        ELSE
            EXIT(rBanco.Name + ' ' + rBanco."CCC Bank No." + '-' + rBanco."CCC Bank Branch No." +
       '-' + rBanco."CCC Control Digits" + '-' + rBanco."CCC Bank Account No.");
    End;


}

