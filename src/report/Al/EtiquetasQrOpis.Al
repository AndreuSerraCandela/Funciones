/// <summary>
/// Report Etiqueta orden fijación (ID 50097).
/// </summary>
Report 50049 "Etiqueta Qr Opis"
{

    DefaultLayout = Word;
    WordLayout = './src/report/layout/EtiquetaQrOpis.docx';
    dataset
    {

        dataitem(Imagenes; "Imagenes Orden fijación")
        {
            DataItemTableView = Sorting("Nº Orden");
            RequestFilterFields = "Nº Orden";
            column("Nombre_Proyecto"; fijar("Nº Orden")) { }
            column("Fecha_fijación"; FechaFijacion("Nº Orden")) { }
            column("N_Imagen"; "Nº Imagen") { }
            column("Url"; "Url") { }
            column("Imagen"; Image) { }

            trigger OnAfterGetRecord()
            var
                Base64: Text;
                OutStr: OutStream;
                InStr: InStream;
                TempBlob: Codeunit "Temp Blob";
                Base64Convert: Codeunit "Base64 Convert";
                Orden_fijacion: Record "Cab Orden fijación";
            begin
                If Orden_fijacion.GET("Nº Orden") then
                    Cab := Orden_fijacion;
                if Cab.insert then;
                // If Url <> '' Then begin
                //     Base64 := ToBase64StringOcr(Url);
                //     TempBlob.CreateOutStream(OutStr);
                //     If Base64 <> '' Then begin
                //         Base64Convert.FromBase64(base64, OutStr);
                //         TempBlob.CreateInStream(InStr);
                //         Image.ImportStream(InStr, Nombre);
                //         Modify();
                //     end;
                // end;
                a := 0;

            end;

            trigger OnPreDataItem()
            begin
                SetRange("Nº Orden", Norden);

            end;

        }
        dataItem("Det_Orden_fijacion"; "Orden fijación")
        {
            UseTemporary = true;
            DataItemTableView = Sorting("Nº Recurso");


            column("Num"; a) { }
            column(Proyecto; "Nº Proyecto") { }
            column(Recurso1; "Nº Recurso") { }
            column(Recurso2; Operario) { }
            column(Recurso3; Zona) { }
            column(Nombre; Nombre("Nº Recurso", "Empresa")) { }
            column(Observaciones; WorkDescription("Nº Orden")) { }
            column(Qr; Qr) { }
            column(Qr2; Qr2) { }
            column(Qr3; Qr3) { }

            trigger OnPreDataItem()
            BEGIN


                NroOrdenes := COUNT;
                if FindFirst() then;
                NroColumnas := 2;
                SetRange("Nº Orden", Norden);

            END;

            trigger OnAfterGetRecord()
            var
                TempBlob: Codeunit "Temp Blob";
                Base64Convert: Codeunit "Base64 Convert";
                Orden_fijacion: Record "Cab Orden fijación";
                Qrs: Record "Imagenes Orden fijación";
                Base64: Text;
                OutStr: OutStream;
                InStr: InStream;
            BEGIN
                a += 1;
                If Det_Orden_fijacion."Nº Qr" <> 0 Then begin
                    Qrs.SetRange("Nº Imagen", Det_Orden_fijacion."Nº Qr");
                    Qrs.SetRange("Nº Orden", Det_Orden_fijacion."Nº Orden");
                    If Qrs.FindSet() then
                        If Qrs.Url <> '' Then begin
                            Base64 := Qrs.ToBase64StringOcr(Qrs.Url);
                            Clear(TempBlob);
                            Clear(OutStr);
                            TempBlob.CreateOutStream(OutStr);
                            Base64Convert.FromBase64(base64, OutStr);
                            Clear(InStr);
                            TempBlob.CreateInStream(InStr);
                            Qr.ImportStream(InStr, Qrs.Nombre);
                            Modify();
                        end;
                end;
                if Det_Orden_fijacion."No. Opis" <> 0 then begin
                    Qrs.SetRange("Nº Imagen", Det_Orden_fijacion."No. Opis");
                    Qrs.SetRange("Nº Orden", Det_Orden_fijacion."Nº Orden");
                    If Qrs.FindSet() then
                        If Qrs.Url <> '' Then begin
                            Base64 := Qrs.ToBase64StringOcr(Qrs.Url);
                            Clear(TempBlob);
                            Clear(OutStr);
                            TempBlob.CreateOutStream(OutStr);
                            Base64Convert.FromBase64(base64, OutStr);
                            Clear(InStr);
                            TempBlob.CreateInStream(InStr);
                            Qr2.ImportStream(InStr, Qrs.Nombre);
                            Modify();
                        end;
                end;
                if Det_Orden_fijacion."Nº Vallas" <> 0 then begin
                    Qrs.SetRange("Nº Imagen", Det_Orden_fijacion."Nº Vallas");
                    Qrs.SetRange("Nº Orden", Det_Orden_fijacion."Nº Orden");
                    If Qrs.FindSet() then
                        If Qrs.Url <> '' Then begin
                            Base64 := Qrs.ToBase64StringOcr(Qrs.Url);
                            Clear(TempBlob);
                            Clear(OutStr);
                            TempBlob.CreateOutStream(OutStr);
                            Base64Convert.FromBase64(base64, OutStr);
                            Clear(InStr);
                            TempBlob.CreateInStream(InStr);
                            Qr3.ImportStream(InStr, Qrs.Nombre);
                            Modify();
                        end;
                end;
            END;

        }




    }


    VAR
        rRecurs: Record 156;
        Resource1: Record 156;
        Cab: Record "Cab Orden fijación" temporary;
        NroOrdenes: Integer;
        NroColumnas: Integer;
        NoRegis: Integer;
        NoColumn: Integer;
        Primero: Boolean;
        a: Integer;
        Norden: Integer;
        Rec1: Text;
        Rec2: Text;
        Rec3: Text;


    procedure Filtra(Orden: Integer)
    var
        Reserva: Record Reserva;
    begin

        Imagenes.SetRange("Nº Orden", Orden);
        Imagenes.SetRange("Es Qr", true);
        Det_Orden_fijacion.DeleteAll();
        if Imagenes.FindSet() then begin
            // Det_Orden_fijacion.Init();
            // Det_Orden_fijacion."Nº Orden" := Orden;
            // Det_Orden_fijacion."Nº Reserva" := 0;
            // Det_Orden_fijacion."Nº Qr" := 0;
            // Det_Orden_fijacion."Nº Recurso" := '';
            // Det_Orden_fijacion.Insert();
            repeat
                Det_Orden_fijacion.Init();
                Det_Orden_fijacion."Nº Orden" := Orden;
                Det_Orden_fijacion."Nº Reserva" := Imagenes."Nº Imagen";
                Det_Orden_fijacion."Nº Qr" := Imagenes."Nº Imagen";
                If Reserva.Get(Imagenes."Nº Imagen") then
                    Det_Orden_fijacion."Nº Recurso" := Reserva."Nº Recurso";
                If Imagenes.Next() <> 0 then begin
                    Det_Orden_fijacion."No. Opis" := Imagenes."Nº Imagen";
                    If Reserva.Get(Imagenes."Nº Imagen") then
                        Det_Orden_fijacion.Operario := Reserva."Nº Recurso";
                end else
                    Det_Orden_fijacion."No. Opis" := 0;
                If Imagenes.Next() <> 0 then begin
                    Det_Orden_fijacion."Nº Vallas" := Imagenes."Nº Imagen";
                    If Reserva.Get(Imagenes."Nº Imagen") then
                        Det_Orden_fijacion.Zona := Reserva."Nº Recurso"
                end else
                    Det_Orden_fijacion."Nº Vallas" := 0;
                Det_Orden_fijacion.Insert();
            until Imagenes.Next() = 0;
        end;
        Norden := Orden;

    end;

    procedure DesdeListadeRecursos(var Resource: Record Resource)
    var
        Secuencial: Integer;
        TempBlob: Codeunit "Temp Blob";
        InStream: InStream;
        Base64: Text;
        Base64Convert: Codeunit "Base64 Convert";
        gTask: Codeunit DropBox;
    begin
        Imagenes.SetRange("Nº Orden", 0);
        Imagenes.ModifyAll(Id, 0);
        Imagenes.DeleteAll();
        //Ahy que generar los QR de cada recurso, con Nº Orden =0 y nº de imagen secuancial
        If Resource.FindSet() then
            repeat
                Secuencial := Secuencial + 1;
                Imagenes.Init();
                Imagenes."Nº Orden" := 0;
                Imagenes."Nº Imagen" := Secuencial;
                Imagenes."Es Qr" := true;
                Imagenes.Nombre := 'Qr_' + Resource."No." + '.png';

                Clear(TempBlob);
                Base64 := '';
                If Resource.qr <> '' then begin
                    Imagenes.Url := Resource.qr;
                    Base64 := Imagenes.ToBase64StringOcr(Imagenes.Url);
                end;
                If Base64 = '' then begin
                    gTask.GenerateQRCodeImage('https://gtasks-app.deploy.malla.es/IdQr/' + Resource."No.", TempBlob);
                    tempblob.CreateInStream(InStream);
                    Base64 := Base64Convert.ToBase64(InStream);
                    Imagenes.Url := Imagenes.FormBase64ToUrl(Base64, Imagenes.Nombre, Imagenes.Id);
                end;
                Imagenes.Insert();
                Resource.qr := Imagenes.Url;
                Resource.Modify();
            until Resource.Next() = 0;

        Imagenes.SetRange("Nº Orden", 0);
        Imagenes.SetRange("Es Qr", true);
        Det_Orden_fijacion.DeleteAll();
        Resource.FindFirst();
        if Imagenes.FindSet() then begin
            // Det_Orden_fijacion.Init();
            // Det_Orden_fijacion."Nº Orden" := 0;
            // Det_Orden_fijacion."Nº Reserva" := -1;
            // Det_Orden_fijacion."Nº Qr" := 0;
            // Det_Orden_fijacion."Nº Recurso" := '';
            // Det_Orden_fijacion.Insert();
            repeat
                Det_Orden_fijacion.Init();
                Det_Orden_fijacion."Nº Orden" := 0;
                Det_Orden_fijacion."Nº Reserva" := Imagenes."Nº Imagen";
                Det_Orden_fijacion."Nº Qr" := Imagenes."Nº Imagen";
                Det_Orden_fijacion."Nº Recurso" := Resource."No.";
                If Imagenes.Next() <> 0 then begin
                    Det_Orden_fijacion."No. Opis" := Imagenes."Nº Imagen";
                    If Resource.Next() <> 0 then
                        Det_Orden_fijacion.Operario := Resource."No.";
                end else
                    Det_Orden_fijacion."No. Opis" := 0;
                If Imagenes.Next() <> 0 then begin
                    Det_Orden_fijacion."Nº Vallas" := Imagenes."Nº Imagen";
                    If Resource.Next() <> 0 then
                        Det_Orden_fijacion.Zona := Resource."No.";
                end else
                    Det_Orden_fijacion."Nº Vallas" := 0;
                Det_Orden_fijacion.Insert();
                if Resource.Next() <> 0 then;
            until Imagenes.Next() = 0;
        end;
        Norden := 0;
    end;

    PROCEDURE Nombre(Recurso: Code[20]; Empresa: Text): Text;
    var

    BEGIN
        if Empresa <> '' then
            rRecurs.ChangeCompany(Empresa)
        else
            rRecurs.ChangeCompany('');
        if NOT rRecurs.GET(Recurso) THEN exit('');
        exit(rRecurs.Name);

    end;

    trigger OnPostReport()
    var
        Det: Record "Imagenes Orden fijación";
        TMedia: Record "Tenant Media";
    begin
        Cab.Reset();
        If Cab.FindFirst() then
            repeat


                Det.Setrange("Nº Orden", Cab."Nº Orden");
                if Det.FindSet() then
                    repeat
                        if Det.Image.HasValue Then begin
                            if TMedia.Get(Det.Image.MediaId) Then Tmedia.Delete();
                        end;

                    until Det.Next() = 0;
            until Cab.Next() = 0;
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

    local procedure FechaFijacion(NOrden: Integer): Text
    var
        Cab: Record "Cab Orden fijación";
    begin
        Cab.GET(NOrden);
        exit('FIJAR ' + format(Cab."Fecha fijación", 0, '<Day,2>/<Month,2>/<Year>'));
    end;

    local procedure fijar(NOrden: Integer): Text
    var
        Cab: Record "Cab Orden fijación";
    begin
        Cab.GET(NOrden);
        exit(Cab.Fijar);

    end;

    local procedure WorkDescription("Nº Orden": Integer): Text
    var
        Cab: Record "Cab Orden fijación";
    begin
        Cab.GET("Nº Orden");
        exit(Cab.GetWorkDescription());
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

