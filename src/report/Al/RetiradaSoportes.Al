/// <summary>
/// Report Etiqueta orden fijación (ID 50097).
/// </summary>
Report 50042 "Retirada fijacion Soportes"
{
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;
    DefaultLayout = Word;
    WordLayout = './src/report/layout/RetiradaSoportes.docx';
    dataset
    {
        dataitem("Orden_fijacion"; "Cab Orden fijación")
        {
            RequestFilterFields = "Nº Orden", "Fecha fijación", "Nº Proyecto";
            column("N_Orden"; "Nº Orden") { }
            column(Titulo; "Título") { }
            // column(Observaciones; "Orden_fijacion".GetWorkDescription())
            //     {}

            trigger OnAfterGetRecord()
            var
                i: Integer;
                rDet: Record "Orden fijación";
            begin
                Det_Orden_fijacion.SETRANGE("Nº Orden", 0);
                Det_Orden_fijacion.DELETEALL;
                Det_Orden_fijacion.SetRange(Retirar, true);
                a := 1;
                rDet.SetRange("Nº Orden", "Orden_fijacion"."Nº Orden");
                rDet.SetRange(Retirar, true);
                If rDet.FindSet() then
                    repeat
                        Rellena(a, rDet, true);
                        //if rDet.Next = 0 then break;

                        a += 1;

                    until rDet.Next = 0;
            end;
        }

        dataItem("Det_Orden_fijacion"; "Orden fijación")
        {

            column("G_Orden"; "Nº Orden") { }
            column("N_Reserva"; "Nº Reserva") { }
            column(Proyecto; mOrden["Nº Reserva", 1]) { }
            column(FechaFijacion; mOrden["Nº Reserva", 2]) { }
            column(Recurso; mOrden["Nº Reserva", 3]) { }
            column(Medidas; mOrden["Nº Reserva", 4]) { }
            column(Nombre; mOrden["Nº Reserva", 5]) { }
            column(Empresa; mOrden["Nº Reserva", 6]) { }
            column(Contrato; mOrden["Nº Reserva", 7]) { }
            column(Comercial; mOrden["Nº Reserva", 8]) { }
            column(Observaciones; mOrden["Nº Reserva", 9]) { }
            column(Zona; mOrden["Nº Reserva", 10]) { }
            column(CaraA; mOrden["Nº Reserva", 11]) { }
            column(CaraB; mOrden["Nº Reserva", 12]) { }

            column(ImagenRecurso1; "Image Resource") { }
            column(Imagen1; Image) { }
            column(Imagen2; Image2) { }
            column(Qr; "Qr Retirada") { }


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

    requestpage
    {
        SaveValues = true;

        layout
        {
            area(content)
            {
                group(Datos)
                {
                    Caption = 'Datos';
                    field(Observaciones; Observaciones)
                    {
                        ApplicationArea = All;

                    }
                    field("Título"; "Título")
                    {
                        ApplicationArea = All;
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
        Resource2: Record "Imagenes Orden fijación";
        mOrden: ARRAY[500, 23] OF Text;
        NroOrdenes: Integer;
        NroColumnas: Integer;
        NoRegis: Integer;
        NoColumn: Integer;
        Primero: Boolean;
        Observaciones: Text;
        "Título": Text;
        a: Integer;

    procedure CargaObservaciones(pObservaciones: Text; pTítulo: Text)
    begin
        Observaciones := pObservaciones;
        "Título" := pTítulo;
    end;

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
        Contrato: record "Sales Header";
        SalesPersonCode: Record "Salesperson/Purchaser";
        DocAtch: Record "Document Attachment";
        Job: Record "Job";
        gTask: Codeunit DropBox;
        VallasFijadas: Record "Imagenes Orden fijación";
        InStream: Instream;
    BEGIN
        if rOrden."Empresa" <> '' then
            Contrato.ChangeCompany(rOrden."Empresa")
        else
            Contrato.ChangeCompany('');
        Contrato.setrange("Document Type", Contrato."Document Type"::"Order");
        Contrato.setrange("Nº Proyecto", rOrden."Nº Proyecto");
        If not Contrato.FindSet() then begin
            mOrden[j, 7] := '';
            mOrden[j, 8] := '';
        end else begin
            mOrden[j, 7] := Contrato."No.";
            If rOrden."Nombre Comercial" = '' then begin
                If SalesPersonCode.Get(Contrato."Salesperson Code") then
                    mOrden[j, 8] := SalesPersonCode.Name;
            end else
                mOrden[j, 8] := rOrden."Nombre Comercial";

        end;
        If Rorden.Observaciones = '' then
            Observaciones := "Orden_fijacion".GetWorkDescription()
        else
            Observaciones := rOrden.Observaciones;
        mOrden[j, 9] := Observaciones;
        if rOrden."Empresa" <> '' then
            Job.ChangeCompany(rOrden."Empresa")
        else
            Job.ChangeCompany('');
        If not Job.Get(rOrden."Nº Proyecto") then
            mOrden[j, 1] := ''
        else
            mOrden[j, 1] := STRSUBSTNO('%1', job.Description);
        mOrden[j, 2] := STRSUBSTNO('%1', rOrden."Fecha Retirada");
        mOrden[j, 3] := STRSUBSTNO('%1', rOrden."Nº Recurso");
        if rOrden."Empresa" <> '' then
            rRecurs.ChangeCompany(rOrden."Empresa")
        else
            rRecurs.ChangeCompany('');
        if NOT rRecurs.GET(rOrden."Nº Recurso") THEN;

        mOrden[j, 4] := rOrden.Material;
        mOrden[j, 5] := rRecurs.Name;
        if rOrden."Empresa" <> '' then
            mOrden[j, 6] := rOrden."Empresa"
        else
            mOrden[j, 6] := CompanyName();
        mOrden[j, 10] := rRecurs.Zona;             //$001
        mOrden[j, 11] := '';            //$001''
        mOrden[j, 12] := '';            //$002
        mOrden[j, 6] := Format(rOrden."Guardar o Tirar");            //$002
        If Primero Then begin
            Det_Orden_fijacion.Init();
            "Det_Orden_fijacion"."Nº Orden" := 0;
            "Det_Orden_fijacion"."Nº Reserva" := a;
            "Det_Orden_fijacion".Retirar := true;
            If "Det_Orden_fijacion".Insert() Then;
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
            if rOrden."Empresa" <> '' then
                Tipo.ChangeCompany(rOrden."Empresa")
            else
                Tipo.ChangeCompany('');
            If not Tipo.GET(Resource1."Tipo recurso") THEN Tipo.INIT;
            //Primero Buscamos  si hay Documeent Attach para este recurso y proyecto
            VallasFijadas.SetRange("Nº Imagen", rOrden."Imagen Valla Fijada");
            VallasFijadas.SetRange("Nº Orden", rOrden."Nº Orden");
            If VallasFijadas.Findlast() Then begin
                TempBlob.CreateOutStream(OutStr);
                Base64Convert.FromBase64(VallasFijadas.ToBase64StringOcr(VallasFijadas.Url), OutStr);
                TempBlob.CreateInStream(InStr);
                "Det_Orden_fijacion".Image.ImportStream(InStr, VallasFijadas.Nombre);
            end else begin
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
            end;
            If rOrden."2ª Imagen" <> 0 Then begin
                mOrden[j, 11] := 'Cara que se ve en la foto';
                mOrden[j, 12] := 'Cara posterior';
                Resource2.GET(rOrden."Nº Orden", rOrden."2ª Imagen");
                If Resource2.Url <> '' Then begin
                    Clear(OutStr);
                    Clear(InStr);
                    Clear(TempBlob);
                    Clear(Base64Convert);
                    Base64 := Resource2.ToBase64StringOcr(Resource2.Url);
                    TempBlob.CreateOutStream(OutStr);
                    Base64Convert.FromBase64(base64, OutStr);
                    TempBlob.CreateInStream(InStr);
                    "Det_Orden_fijacion".Image2.ImportStream(InStr, Resource2.Nombre);
                end;
            end else begin
                Base64 := 'iVBORw0KGgoAAAANSUhEUgAAACMAAAAUCAYAAAAHpoRMAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAAJcEhZcwAADsIAAA7CARUoSoAAADKOY2FCWAAAMo5qdW1iAAAAHmp1bWRjMnBhABEAEIAAAKoAOJtxA2MycGEAAAAyaGp1bWIAAABHanVtZGMybWEAEQAQgAAAqgA4m3EDdXJuOnV1aWQ6ZjZiMzc0ODctNjNiNy00ZDE3LWI3MzctNTkyNDM2OTBmYjExAAAAAtJqdW1iAAAAKWp1bWRjMmFzABEAEIAAAKoAOJtxA2MycGEuYXNzZXJ0aW9ucwAAAAG7anVtYgAAAClqdW1kY2JvcgARABCAAACqADibcQNjMnBhLmhhc2guYm94ZXMAAAABimNib3KiY2FsZ2ZzaGEyNTZlYm94ZXOHo2VuYW1lc4FkUE5HaGRoYXNoWCBMS2o74TFKuGE4vvQxTd4CLmAJYNhomiyPhjGALSDatmNwYWRAo2VuYW1lc4FkSUhEUmRoYXNoWCBeJwhkpPDS8SiftO8z7xN3A0QgscFNcUic9awWRurYTmNwYWRAo2VuYW1lc4Fkc1JHQmRoYXNoWCBzJsP7+1+aQ3Hvh9pzmOYej4n7bzMGrSmcalK4aULtSWNwYWRAo2VuYW1lc4FkZ0FNQWRoYXNoWCA4rXegkiHP9x5cpXUzPldt5x4AB/TTcAg9gAXc4VAX1WNwYWRAo2VuYW1lc4FkQzJQQWRoYXNoQQBjcGFkQKNlbmFtZXOBZElEQVRkaGFzaFggziEHwaMMDKRRUm8eDmvl2uCBGxeOYS1NCNN1vHDAZxNjcGFkQKNlbmFtZXOBZElFTkRkaGFzaFgggZ5y7wBQZ2uGFgtvvQs5tH+7E6jhDmnCmcvhrYSNI99jcGFkQAAAAKNqdW1iAAAALGp1bWRjYm9yABEAEIAAAKoAOJtxA2MycGEuaW5ncmVkaWVudC52MgAAAABvY2JvcqNoZGM6dGl0bGV4LmFzc2V0LTRiZDRlNmIwLWM5MzUtNDdkYS04NmFmLTkwNmJmODI5NDZiNi5wbmdpZGM6Zm9ybWF0aWltYWdlL3BuZ2xyZWxhdGlvbnNoaXBrY29tcG9uZW50T2YAAABDanVtYgAAAClqdW1kY2JvcgARABCAAACqADibcQNjMnBhLmFjdGlvbnMudjIAAAAAEmNib3KhZ2FjdGlvbnOAAAADdWp1bWIAAAAkanVtZGMyY2wAEQAQgAAAqgA4m3EDYzJwYS5jbGFpbQAAAANJY2JvcqdjYWxnZnNoYTI1NmlkYzpmb3JtYXRpaW1hZ2UvcG5naXNpZ25hdHVyZXhMc2VsZiNqdW1iZj1jMnBhL3Vybjp1dWlkOmY2YjM3NDg3LTYzYjctNGQxNy1iNzM3LTU5MjQzNjkwZmIxMS9jMnBhLnNpZ25hdHVyZWppbnN0YW5jZUlEeC11cm46dXVpZDoyZjMxMmM3YS1hMzhlLTQ3YmQtYWRmNC1hZDgxOGQxZDFiYTdvY2xhaW1fZ2VuZXJhdG9ydk1pY3Jvc29mdF9EZXNpZ25lci8xLjB0Y2xhaW1fZ2VuZXJhdG9yX2luZm+BpGVhcHBJZHgkNWUyNzk1ZTMtY2U4Yy00Y2ZiLWIzMDItMzVmZTVjZDAxNTk3ZG5hbWVyTWljcm9zb2Z0X0Rlc2lnbmVyaXJlcXVlc3RJZHgkMDY2ZGY0Y2QtMTRiNS00MzM2LWFmOTQtZmVmY2UwMWMyNDNkZ3ZlcnNpb25jMS4wamFzc2VydGlvbnODo2NhbGdmc2hhMjU2Y3VybHhdc2VsZiNqdW1iZj1jMnBhL3Vybjp1dWlkOmY2YjM3NDg3LTYzYjctNGQxNy1iNzM3LTU5MjQzNjkwZmIxMS9jMnBhLmFzc2VydGlvbnMvYzJwYS5oYXNoLmJveGVzZGhhc2hYIBWwDTv9mBIivxWiMS0DxlWmSQu7gbVgouVqQmcjS7Omo2NhbGdmc2hhMjU2Y3VybHhgc2VsZiNqdW1iZj1jMnBhL3Vybjp1dWlkOmY2YjM3NDg3LTYzYjctNGQxNy1iNzM3LTU5MjQzNjkwZmIxMS9jMnBhLmFzc2VydGlvbnMvYzJwYS5pbmdyZWRpZW50LnYyZGhhc2hYIJ7FrllCQ9rUOniHirXyfteii/SZ8QBY40YYEo08vSTyo2NhbGdmc2hhMjU2Y3VybHhdc2VsZiNqdW1iZj1jMnBhL3Vybjp1dWlkOmY2YjM3NDg3LTYzYjctNGQxNy1iNzM3LTU5MjQzNjkwZmIxMS9jMnBhLmFzc2VydGlvbnMvYzJwYS5hY3Rpb25zLnYyZGhhc2hYIC1yt0odH0wiUSTHfAdNepNa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';
                Clear(OutStr);
                Clear(InStr);
                Clear(TempBlob);
                Clear(Base64Convert);
                TempBlob.CreateOutStream(OutStr);
                Base64Convert.FromBase64(base64, OutStr);
                TempBlob.CreateInStream(InStr);
                "Det_Orden_fijacion".Image2.ImportStream(InStr, Resource2.Nombre);
            end;
            If rOrden."Nº Qr" <> 0 Then begin
                Clear(TempBlob);
                Clear(InStr);
                gTask.GenerateQRCodeImage('https://gtasks-app.deploy.malla.es/IdQr/' + Format(rOrden."Nº Orden") + '-R' + Format(rOrden."Nº Qr"), TempBlob);
                tempblob.CreateInStream(InStream);
                Base64 := Base64Convert.ToBase64(InStream);
                Clear(TempBlob);
                TempBlob.CreateOutStream(OutStr);
                Base64Convert.FromBase64(base64, OutStr);
                TempBlob.CreateInStream(InStr);
                If not Resource2.GET(rOrden."Nº Orden", rOrden."Nº Qr") then Resource2.init;
                "Det_Orden_fijacion"."Qr Retirada".ImportStream(InStr, Resource2.Nombre);

            end;

            "Det_Orden_fijacion".Modify();
            if Not Det_Orden_fijacion."Qr Retirada".HasValue Then Error('No se ha generado el Qr de Retirada');
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

