/// <summary>
/// Report Etiqueta orden fijación (ID 50097).
/// </summary>
Report 50031 "Etiqueta orden fijación"
{
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;
    DefaultLayout = Word;
    RDLCLayout = './src/report/layout/Etiquetasfij.rdlc';
    WordLayout = './src/report/layout/Etiquetasfij.docx';
    dataset
    {
        dataitem("Ordden fijación"; "Cab Orden fijación")
        {
            RequestFilterFields = "Nº Orden", "Fecha fijación", "Nº Proyecto";

            dataItem("Det Orden fijación"; "Orden fijación")
            {
                DataItemTableView = SORTING("Nº Recurso");
                DataItemLink = "Nº Orden" = FIELD("Nº Orden");
                RequestFilterFields = "Nº Recurso", "Nº Reserva", "Fecha fijación", "Nº Proyecto";

                column(mOrden11; mOrden[1, 1]) { }
                column(mOrden12; mOrden[1, 2]) { }
                column(mOrden13; mOrden[1, 3]) { }
                column(mOrden14; mOrden[1, 4]) { }
                column(mOrden15; mOrden[1, 5]) { }
                column(mOrden16; mOrden[1, 6]) { }
                column(mOrden17; mOrden[1, 7]) { }
                column(mOrden18; mOrden[1, 8]) { }
                column(mOrden19; mOrden[1, 9]) { }
                column(mOrden20; mOrden[1, 10]) { }
                column(mOrden21; mOrden[1, 11]) { }
                column(mOrden22; mOrden[1, 12]) { }
                column(mOrden23; mOrden[1, 13]) { }
                column(mOrden31; mOrden[2, 1]) { }
                column(mOrden32; mOrden[2, 2]) { }
                column(mOrden33; mOrden[2, 3]) { }
                column(mOrden34; mOrden[2, 4]) { }
                column(mOrden35; mOrden[2, 5]) { }
                column(mOrden36; mOrden[2, 6]) { }
                column(mOrden37; mOrden[2, 7]) { }
                column(mOrden38; mOrden[2, 8]) { }
                column(mOrden39; mOrden[2, 9]) { }
                column(mOrden40; mOrden[2, 10]) { }
                column(mOrden41; mOrden[2, 11]) { }
                column(mOrden42; mOrden[2, 12]) { }
                column(mOrden43; mOrden[2, 13]) { }
                column(Imagen1; Resource1.Image) { }
                column(Imagen2; Resource2.Image) { }
                column(ShowBody1; (NoColumn = 0) and (LabelFormat <> LabelFormat::"36 x 105 mm (2 columns)"))
                {
                }
                column(GroupNo1; GroupNo)
                {
                }
                column(ShowBody2; (NoColumn = 0) and (LabelFormat <> LabelFormat::"36 x 105 mm (2 columns)"))
                {
                }
                column(ShowBody3; (NoColumn = 0) and (LabelFormat = LabelFormat::"36 x 105 mm (2 columns)"))
                {
                }
                column(ShowBody4; (NoColumn = 0) and (LabelFormat = LabelFormat::"36 x 105 mm (2 columns)"))
                {
                }
                column(Observaciones; "Ordden fijación".GetWorkDescription())
                { }

                trigger OnPreDataItem()
                BEGIN
                    NroOrdenes := COUNT;
                    NroColumnas := 2;
                END;

                trigger OnAfterGetRecord()
                BEGIN
                    //rRecurs.GET("Orden fijación"."Nº Recurso");

                    NoRegis := NoRegis + 1;
                    NoColumn := NoColumn + 1;
                    Rellena(NoColumn, "Det Orden fijación");
                    if NoRegis = NroOrdenes THEN BEGIN
                        FOR i := NoColumn + 1 TO NroColumnas DO
                            CLEAR(mOrden[i]);
                        NoColumn := 0;
                    END ELSE BEGIN
                        if NoColumn = NroColumnas THEN
                            NoColumn := 0;
                    END;
                END;

            }
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
                    Caption = 'Options';
                    field(LabelFormat; LabelFormat)
                    {
                        ApplicationArea = Suite;
                        Caption = 'Format';
                        OptionCaption = '36 x 105 mm (2 columns)';
                        ToolTip = 'Specifies the format of the label.';
                    }
                }
            }
        }

        actions
        {
        }
    }
    VAR
        rRecurs: Record 156;
        Resource1: Record 156;
        Resource2: Record 156;
        mOrden: ARRAY[6, 13] OF Text[80];
        NroOrdenes: Integer;
        NroColumnas: Integer;
        NoRegis: Integer;
        NoColumn: Integer;

    PROCEDURE Rellena(j: Integer; rOrden: Record "Orden fijación");
    BEGIN
        mOrden[j, 1] := STRSUBSTNO('%1', rOrden."Nº Proyecto");
        mOrden[j, 2] := STRSUBSTNO('%1', rOrden."Fecha fijación");
        mOrden[j, 3] := STRSUBSTNO('%1', rOrden."Nº Recurso");
        if NOT rRecurs.GET(rOrden."Nº Recurso") THEN;
        mOrden[j, 4] := STRSUBSTNO('%1', rRecurs.Medidas);
        mOrden[j, 5] := rRecurs.Name;
        mOrden[j, 6] := rRecurs."Name 2";
        mOrden[j, 7] := 'Fijar: ' + rOrden.Fijar;
        mOrden[j, 8] := 'Tapar: ' + rOrden.Tapar;
        mOrden[j, 9] := COMPANYNAME + '- Orden de fijación';
        mOrden[j, 10] := 'VALLA Nº: ' + FORMAT(rRecurs."No. Orden");             //$001
        mOrden[j, 11] := 'T.fijac: ' + FORMAT(rRecurs."Tipo fijacion");      //$002
        mOrden[j, 12] := 'L.vida: ' + FORMAT(rRecurs."Linea vida");            //$002
        mOrden[j, 13] := 'Pelig: ' + FORMAT(rRecurs.Peligrosidad);            //$002
    END;

    trigger OnPreReport()
    begin
        GroupNo := 1;
        RecPerPageNum := 7;
    end;

    var
        LabelFormat: Option "36 x 105 mm (2 columns)";
        NoOfColumns: Integer;
        i: Integer;
        GroupNo: Integer;
        Counter: Integer;
        RecPerPageNum: Integer;

    procedure InitializeRequest(SetLabelFormat: Option)
    begin
        LabelFormat := SetLabelFormat;
    end;

    //     BEGIN
    //     {
    //       $001 FCL-250310. Incluyo el nº de orden, para ello amplío la matriz.
    //       $002 FCL-201211. Nuevos campos tipo fijación, línea vida y peligrosidad.
    //     }
    //     END.
    //   }
    //   RDLDATA
    //   {
    //   }
}

