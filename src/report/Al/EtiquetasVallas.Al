/// <summary>
/// Report Etiqueta orden fijación (ID 50097).
/// </summary>
Report 50039 "Etiqueta orden fijacion Vallas"
{
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;
    DefaultLayout = Word;
    WordLayout = './src/report/layout/FijacionValla.docx';
    dataset
    {
        dataitem("Orden_fijacion"; "Cab Orden fijación")
        {
            RequestFilterFields = "Nº Orden", "Fecha fijación", "Nº Proyecto";
            column("N_Orden"; "Nº Orden") { }

            trigger OnAfterGetRecord()
            var
                i: Integer;
                rDet: Record "Orden fijación";
            begin
                Det_Orden_fijacion.SETRANGE("Nº Orden", 0);
                Det_Orden_fijacion.DELETEALL;
                a := 1;
                rDet.SetCurrentKey("Nº Recurso");
                rDet.SetRange("Nº Orden", "Orden_fijacion"."Nº Orden");
                If rDet.FindSet() then
                    repeat
                        Rellena(a, rDet, true);
                        if rDet.Next = 0 then break;
                        Rellena(1 + a, rDet, false);
                        // if rdET.Next = 0 then break;
                        // Rellena(2 + a, rDet, false);
                        // if rdET.Next = 0 then break;
                        // Rellena(3 + a, rDet, false);
                        a += 2;

                    until rDet.Next = 0;
            end;
        }

        dataItem("Det_Orden_fijacion"; "Orden fijación")
        {
            DataItemTableView = sorting("Nº Recurso");

            column("G_Orden"; "Nº Orden") { }
            column("N_Reserva"; "Nº Reserva") { }
            column(Proyecto1; mOrden["Nº Reserva", 1]) { }
            column(FechaFijacion1; mOrden["Nº Reserva", 2]) { }
            column(Recurso1; mOrden["Nº Reserva", 3]) { }
            column(Medidas1; mOrden["Nº Reserva", 4]) { }
            column(Nombre1; mOrden["Nº Reserva", 5]) { }
            column(Nombre_2_1; mOrden["Nº Reserva", 6]) { }
            column(Fijar1; mOrden["Nº Reserva", 7]) { }
            column(Tapar1; mOrden["Nº Reserva", 8]) { }
            column(nOrdenValla1; mOrden["Nº Reserva", 9]) { }
            column(Proyecto2; mOrden["Nº Reserva" + 1, 1]) { }
            column(FechaFijacion2; mOrden["Nº Reserva" + 1, 2]) { }
            column(Recurso2; mOrden["Nº Reserva" + 1, 3]) { }
            column(Medidas2; mOrden["Nº Reserva" + 1, 4]) { }
            column(Nombre2; mOrden["Nº Reserva" + 1, 5]) { }
            column(Nombre_2_2; mOrden["Nº Reserva" + 1, 6]) { }
            column(Fijar2; mOrden["Nº Reserva" + 1, 7]) { }
            column(Tapar2; mOrden["Nº Reserva" + 1, 8]) { }
            column(nOrdenValla2; mOrden["Nº Reserva" + 1, 9]) { }
            // column(Proyecto3; mOrden["Nº Reserva" + 2, 1]) { }
            // column(FechaFijacion3; mOrden["Nº Reserva" + 2, 2]) { }
            // column(Recurso3; mOrden["Nº Reserva" + 2, 3]) { }
            // column(Medidas3; mOrden["Nº Reserva" + 2, 4]) { }
            // column(Nombre3; mOrden["Nº Reserva" + 2, 5]) { }
            // column(Nombre_2_3; mOrden["Nº Reserva" + 2, 6]) { }
            // column(Fijar3; mOrden["Nº Reserva" + 2, 7]) { }
            // column(Tapar3; mOrden["Nº Reserva" + 2, 8]) { }
            // column(nOrdenValla3; mOrden["Nº Reserva" + 2, 9]) { }
            // column(Proyecto4; mOrden["Nº Reserva" + 3, 1]) { }
            // column(FechaFijacion4; mOrden["Nº Reserva" + 3, 2]) { }
            // column(Recurso4; mOrden["Nº Reserva" + 3, 3]) { }
            // column(Medidas4; mOrden["Nº Reserva" + 3, 4]) { }
            // column(Nombre4; mOrden["Nº Reserva" + 3, 5]) { }
            // column(Nombre_2_4; mOrden["Nº Reserva" + 3, 6]) { }
            // column(Fijar4; mOrden["Nº Reserva" + 3, 7]) { }
            // column(Tapar4; mOrden["Nº Reserva" + 3, 8]) { }
            column(nOrdenValla4; mOrden["Nº Reserva" + 3, 9]) { }
            column(ImagenRecurso1; "Image Resource") { }
            column(Imagen1; Image) { }
            column(ImagenRecurso2; "Image Resource2") { }
            column(Imagen2; Image2) { }
            // column(ImagenRecurso3; "Image Resource3") { }
            // column(Imagen3; Image3) { }
            // column(ImagenRecurso4; "Image Resource4") { }
            // column(Imagen4; Image4) { }
            column(ShowBody1; (NoColumn = 0) and (LabelFormat <> LabelFormat::"36 x 105 mm (2 columns)"))
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
            column(Observaciones; "Det_Orden_fijacion".Observaciones)
            { }
            column(Qr; Qr) { }
            column(Qr2; Qr2) { }

            trigger OnPreDataItem()
            BEGIN
                SetRange("Nº Orden", 0);

                NroOrdenes := COUNT;
                NroColumnas := 2;
            END;

            trigger OnAfterGetRecord()
            var

            BEGIN
                //rRecurs.GET("Orden fijación"."Nº Recurso");

                // NoRegis := NoRegis + 1;
                // NoColumn := NoColumn + 1;
                // Rellena(NoColumn, "Det Orden fijación");

                // if NoRegis = NroOrdenes THEN BEGIN
                //     FOR i := NoColumn + 1 TO NroColumnas DO
                //         CLEAR(mOrden[i]);
                //     NoColumn := 0;
                // END ELSE BEGIN
                //     if NoColumn = NroColumnas THEN
                //         NoColumn := 0;
                // END;
            END;

        }

    }

    // requestpage
    // {
    //     SaveValues = true;

    //     layout
    //     {
    //         area(content)
    //         {
    //             group(Options)
    //             {
    //                 Caption = 'Options';
    //                 field(LabelFormat; LabelFormat)
    //                 {
    //                     ApplicationArea = Suite;
    //                     Caption = 'Format';
    //                     OptionCaption = '36 x 105 mm (2 columns)';
    //                     ToolTip = 'Specifies the format of the label.';
    //                 }
    //             }
    //         }
    //     }

    //     actions
    //     {
    //     }
    // }
    VAR
        rRecurs: Record 156;
        Resource1: Record 156;
        Resource2: Record "Imagenes Orden fijación";
        mOrden: ARRAY[500, 23] OF Text[80];
        NroOrdenes: Integer;
        NroColumnas: Integer;
        NoRegis: Integer;
        NoColumn: Integer;
        Primero: Boolean;
        a: Integer;



    PROCEDURE Rellena(j: Integer; var rOrden: Record "Orden fijación"; Primero: Boolean);
    var
        InputFile: File;
        Tipo: Record "Tipo recurso";
        Ins: InStream;
        OutStr: OutStream;
        Base64: Text;
        Base64Convert: Codeunit "Base64 Convert";
        TempBlob: Codeunit "Temp Blob";
        InStr: InStream;
    BEGIN
        mOrden[j, 1] := STRSUBSTNO('%1', rOrden."Nº Proyecto");
        mOrden[j, 2] := STRSUBSTNO('%1', rOrden."Fecha fijación");
        mOrden[j, 3] := STRSUBSTNO('%1', rOrden."Nº Recurso");
        if rOrden."Empresa" <> '' then
            rRecurs.ChangeCompany(rOrden."Empresa")
        else
            rRecurs.ChangeCompany('');
        if NOT rRecurs.GET(rOrden."Nº Recurso") THEN;

        mOrden[j, 4] := STRSUBSTNO('%1', rRecurs.Medidas);
        mOrden[j, 5] := rRecurs.Name;
        mOrden[j, 6] := rRecurs."Name 2";
        mOrden[j, 7] := 'Fijar: ' + rOrden.Fijar;
        mOrden[j, 8] := 'Tapar: ' + rOrden.Tapar;
        if rOrden."Empresa" <> '' then
            mOrden[j, 9] := rOrden."Empresa" + '- Orden de fijación'
        else
            mOrden[j, 9] := COMPANYNAME + '- Orden de fijación';
        mOrden[j, 10] := 'VALLA Nº: ' + FORMAT(rRecurs."No. Orden");             //$001
        mOrden[j, 11] := 'T.fijac: ' + FORMAT(rRecurs."Tipo fijacion");      //$002
        mOrden[j, 12] := 'L.vida: ' + FORMAT(rRecurs."Linea vida");            //$002
        mOrden[j, 13] := 'Pelig: ' + FORMAT(rRecurs.Peligrosidad);            //$002
        If Primero Then begin
            Det_Orden_fijacion.Init();
            "Det_Orden_fijacion"."Nº Orden" := 0;
            "Det_Orden_fijacion"."Nº Reserva" := a;
            "Det_Orden_fijacion".Insert();
        end;
        Clear(OutStr);
        Clear(InStr);
        Clear(Ins);
        If Primero Then begin
            if rOrden."Empresa" <> '' then
                Resource1.ChangeCompany(rOrden."Empresa")
            else
                Resource1.ChangeCompany('');
            If Not Resource1.GET(rOrden."Nº Recurso") THEN Resource1.init;
            If not Tipo.GET(Resource1."Tipo recurso") THEN Tipo.INIT;
            if File.Exists(Copystr(Tipo."Ruta imagenes", 6) + '\' + Resource1."No." + '.jpg') Then Begin
                InputFile.Open(Copystr(Tipo."Ruta imagenes", 6) + '\' + Resource1."No." + '.jpg');
                InputFile.CreateInStream(Ins);
                //Resource.CalcFields(Image);
                "Det_Orden_fijacion"."Image Resource".ImportStream(ins, 'Image');
            end;
            If Not Resource2.GET(rOrden."Nº Orden", rOrden."Nº Imagen") Then Resource2.init;
            If Resource2.Url <> '' Then begin
                Base64 := Resource2.ToBase64StringOcr(Resource2.Url);
                TempBlob.CreateOutStream(OutStr);
                Base64Convert.FromBase64(base64, OutStr);
                TempBlob.CreateInStream(InStr);
                "Det_Orden_fijacion".Image.ImportStream(InStr, Resource2.Nombre);
            end;
            If Not Resource2.GET(rOrden."Nº Orden", rOrden."Nº Qr") Then Resource2.init;
            If Resource2.Url <> '' Then begin
                Base64 := Resource2.ToBase64StringOcr(Resource2.Url);
                TempBlob.CreateOutStream(OutStr);
                Base64Convert.FromBase64(base64, OutStr);
                TempBlob.CreateInStream(InStr);
                "Det_Orden_fijacion".Qr.ImportStream(InStr, Resource2.Nombre);
            end;
            "Det_Orden_fijacion".Modify();
        end;
        if Not primero Then begin
            if rOrden."Empresa" <> '' then
                Resource1.ChangeCompany(rOrden."Empresa")
            else
                Resource1.ChangeCompany('');
            If Not Resource1.GET(rOrden."Nº Recurso") THEN Resource1.init;
            if rOrden."Empresa" <> '' then
                Tipo.ChangeCompany(rOrden."Empresa")
            else
                Tipo.ChangeCompany('');
            If not Tipo.GET(Resource1."Tipo recurso") THEN Tipo.INIT;
            if File.Exists(Copystr(Tipo."Ruta imagenes", 6) + '\' + Resource1."No." + '.jpg') Then Begin
                InputFile.Open(Copystr(Tipo."Ruta imagenes", 6) + '\' + Resource1."No." + '.jpg');
                InputFile.CreateInStream(Ins);
                //Resource.CalcFields(Image);
                "Det_Orden_fijacion"."Image Resource2".ImportStream(ins, 'Image');
            end;
            If not Resource2.GET(rOrden."Nº Orden", rOrden."Nº Imagen") Then Resource2.init;
            If Resource2.Url <> '' Then begin
                Base64 := Resource2.ToBase64StringOcr(Resource2.Url);
                TempBlob.CreateOutStream(OutStr);
                Base64Convert.FromBase64(base64, OutStr);
                TempBlob.CreateInStream(InStr);
                "Det_Orden_fijacion".Image2.ImportStream(InStr, Resource2.Nombre);
            end;
            If not Resource2.GET(rOrden."Nº Orden", rOrden."Nº Qr") Then Resource2.init;
            If Resource2.Url <> '' Then begin
                Base64 := Resource2.ToBase64StringOcr(Resource2.Url);
                TempBlob.CreateOutStream(OutStr);
                Base64Convert.FromBase64(base64, OutStr);
                TempBlob.CreateInStream(InStr);
                "Det_Orden_fijacion".Qr2.ImportStream(InStr, Resource2.Nombre);
            end;
            "Det_Orden_fijacion".Modify();
        end;
        // if j = 3 Then begin
        //     If Not Resource1.GET(rOrden."Nº Recurso") THEN Resource1.init;
        //     If not Tipo.GET(Resource1."Tipo recurso") THEN Tipo.INIT;
        //     if File.Exists(Copystr(Tipo."Ruta imagenes", 6) + '\' + Resource1."No." + '.jpg') Then Begin
        //         InputFile.Open(Copystr(Tipo."Ruta imagenes", 6) + '\' + Resource1."No." + '.jpg');
        //         InputFile.CreateInStream(Ins);
        //         //Resource.CalcFields(Image);
        //         "Det_Orden_fijacion"."Image Resource3".ImportStream(ins, 'Image');
        //     end;
        //     Resource2.GET(rOrden."Nº Orden", rOrden."Nº Imagen");
        //     If Resource2.Url <> '' Then begin
        //         Base64 := Resource2.ToBase64StringOcr(Resource2.Url);
        //         TempBlob.CreateOutStream(OutStr);
        //         Base64Convert.FromBase64(base64, OutStr);
        //         TempBlob.CreateInStream(InStr);
        //         "Det_Orden_fijacion".Image3.ImportStream(InStr, Resource2.Nombre);
        //     end;
        //     "Det_Orden_fijacion".Modify();
        // end;
        // if j = 4 Then begin
        //     If Not Resource1.GET(rOrden."Nº Recurso") THEN Resource1.init;
        //     If not Tipo.GET(Resource1."Tipo recurso") THEN Tipo.INIT;
        //     if File.Exists(Copystr(Tipo."Ruta imagenes", 6) + '\' + Resource1."No." + '.jpg') Then Begin
        //         InputFile.Open(Copystr(Tipo."Ruta imagenes", 6) + '\' + Resource1."No." + '.jpg');
        //         InputFile.CreateInStream(Ins);
        //         //Resource.CalcFields(Image);
        //         "Det_Orden_fijacion"."Image Resource4".ImportStream(ins, 'Image');
        //     end;
        //     Resource2.GET(rOrden."Nº Orden", rOrden."Nº Imagen");
        //     If Resource2.Url <> '' Then begin
        //         Base64 := Resource2.ToBase64StringOcr(Resource2.Url);
        //         TempBlob.CreateOutStream(OutStr);
        //         Base64Convert.FromBase64(base64, OutStr);
        //         TempBlob.CreateInStream(InStr);
        //         Clear(Resource2.image);
        //         "Det_Orden_fijacion".Image4.ImportStream(InStr, Resource2.Nombre);
        //     end;
        //     "Det_Orden_fijacion".Modify();
        // end;
    end;

    trigger OnPreReport()
    var
        Det: Record "Orden fijación";
        TMedia: Record "Tenant Media";
    begin
        GroupNo := 1;
        RecPerPageNum := 7;


        Det.Setrange("Nº Orden", 0);
        if Det.FindSet() then
            repeat
                if Det.Image.HasValue Then begin
                    if TMedia.Get(Det.Image.MediaId) Then Tmedia.Delete();
                end;
                if Det."Image Resource".HasValue Then begin
                    if TMedia.Get(Det."Image Resource".MediaId) Then Tmedia.Delete();
                end;
                if Det.Image2.HasValue Then begin
                    if TMedia.Get(Det.Image2.MediaId) Then Tmedia.Delete();
                end;
                if Det."Image Resource2".HasValue Then begin
                    if TMedia.Get(Det."Image Resource2".MediaId) Then Tmedia.Delete();
                end;
            until Det.Next() = 0;
        Commit();
    end;

    var
        LabelFormat: Option "36 x 105 mm (2 columns)";
        NoOfColumns: Integer;
        Imagen: Record Media;
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

