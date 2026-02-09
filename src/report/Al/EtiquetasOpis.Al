/// <summary>
/// Report Etiqueta orden fijación (ID 50097).
/// </summary>
Report 50040 "Etiqueta orden fijacion Opis"
{

    DefaultLayout = Word;
    WordLayout = './src/report/layout/FijacionOpi.docx';
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
            column(Qr; Qr) { }
            trigger OnAfterGetRecord()
            var
                Base64: Text;
                OutStr: OutStream;
                InStr: InStream;
                TempBlob: Codeunit "Temp Blob";
                Base64Convert: Codeunit "Base64 Convert";
                Orden_fijacion: Record "Cab Orden fijación";
                Qrs: Record "Imagenes Orden fijación";
                Control: Codeunit "ControlProcesos";
            begin
                If Orden_fijacion.GET("Nº Orden") then
                    Cab := Orden_fijacion;
                if Cab.insert then;
                If Url <> '' Then begin
                    Clear(TempBlob);
                    Clear(OutStr);
                    Clear(InStr);
                    Clear(Base64Convert);
                    Base64 := Control.ToBase64StringOcr(Url);
                    TempBlob.CreateOutStream(OutStr);
                    Base64Convert.FromBase64(base64, OutStr);
                    TempBlob.CreateInStream(InStr);
                    Image.ImportStream(InStr, Nombre);
                    Modify();
                end;
                a := 0;
                Det_Orden_fijacion.SetRange("Nº Orden", "Nº Orden");
                Det_Orden_fijacion.SETRANGE("Nº Imagen", "Nº Imagen");
                If Det_Orden_fijacion.FindSet() then begin
                    If Det_Orden_fijacion."Nº Qr" <> 0 Then begin
                        Qrs.SetRange("Nº Imagen", Det_Orden_fijacion."Nº Qr");
                        Qrs.SetRange("Nº Orden", Det_Orden_fijacion."Nº Orden");
                        If Qrs.FindSet() then
                            If Qrs.Url <> '' Then begin
                                Base64 := Control.ToBase64StringOcr(Qrs.Url);
                                Clear(TempBlob);
                                Clear(OutStr);
                                TempBlob.CreateOutStream(OutStr);
                                Base64Convert.FromBase64(base64, OutStr);
                                Clear(InStr);
                                TempBlob.CreateInStream(InStr);
                                If Nombre = '' Then Nombre := 'Qr_' + Format("Nº Imagen") + '.png';
                                Qr.ImportStream(InStr, Qrs.Nombre);
                                "Es Qr" := True;
                                Modify();
                            end;
                    end;
                end;
            end;

            trigger OnPreDataItem()
            begin
                SetRange("Nº Orden", Norden);
                SetRange("Nº Imagen", NNimagen);
            end;

        }
        dataItem("Det_Orden_fijacion"; "Orden fijación")
        {
            DataItemTableView = Sorting("Nº Recurso");


            column("Num"; a) { }
            column(Proyecto; "Nº Proyecto") { }
            column(Recurso; "Nº Recurso") { }
            column(Nombre; Nombre("Nº Recurso", "Empresa")) { }
            column(Observaciones; WorkDescription("Nº Orden")) { }


            trigger OnPreDataItem()
            BEGIN


                NroOrdenes := COUNT;
                NroColumnas := 2;
                SetRange("Nº Orden", Norden);
                SetRange("Nº Imagen", NNimagen);
            END;

            trigger OnAfterGetRecord()
            var

            BEGIN
                a += 1;
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
        NNimagen: Integer;

    procedure Filtra(Orden: Integer; NImagen: Integer)
    begin
        Imagenes.SetRange("Nº Orden", Orden);
        Imagenes.SetRange("Nº Imagen", NImagen);
        Det_Orden_fijacion.SetRange("Nº Orden", Orden);
        Det_Orden_fijacion.SETRANGE("Nº Imagen", NImagen);
        NNimagen := NImagen;
        Norden := Orden;
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

