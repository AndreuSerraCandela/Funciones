/// <summary>
/// Report Disponibilidad (ID 7001125).
/// </summary>
report 50038 DisponibilidadWord
{
    ApplicationArea = All;
    Caption = 'Disponibilidad';
    PreviewMode = PrintLayout;
    UsageCategory = ReportsAndAnalysis;
    DefaultLayout = Word;

    Wordlayout = './src/report/layout/DisponibilidadWord.docx';
    dataset
    {
        dataItem("User Setup"; "User Setup")
        {
            column("Comerial"; Rec.Comercial) { }//	$001
            column(Cliente; Rec."Cliente") { }
            column("Tipo_Informe"; Rec."Tipo Informe") { }
            column("Con_precios"; Rec."Precios") { }
            column("Con_prohibiciones"; Rec."Prohibiciones") { }
            column("Agencia_o_Local"; Rec."Tipo Cliente") { }
            column("Con_que_precios"; Rec."Tipo Precios") { }
            column("Con_Que_calidad"; Rec."Calidad") { }
            column(Fecha; Format(Today, 0, '<Day,2>/<Month,2>/<Year>')) { }

        }
        dataItem(Resource; SeleccionRecursos)
        {

            column(TipoRecurso; "Tipo Recurso")
            {
            }
            column(Medidas; Medidas)
            {
            }
            column(No; "No.")
            {
            }
            column(Name; Name)
            {
            }
            column("Titulo_Prohibiciones"; TProhibiciones) { }
            column(Prohibiciones; Resource.Prohibiciones) { }
            column(Imagen; Resource.Image) { }
            column(Ubicacion; 'http://maps.google.es/?q=' + CONVERTSTR(FORMAT(Resource.PuntoY, 0, '<Precision,10:10><Standard Format,0>'), ',', '.')
            + '%20' + CONVERTSTR(FORMAT(Resource.PuntoX, 0, '<Precision,10:10><Standard Format,0>'), ',', '.'))
            { }
            column("Titulo_Categoria"; TCateg) { }
            column(Categoria; Categ) { }
            column(Alquiler; Alq) { }
            column(Anual; AnualP) { }
            column(Temporada; TemporadaP) { }
            column(Disponibiliad; Disponibilidad) { }
            column(DtoAgencia; DtoAgencia) { }

            column(FechaLinea; Format(Today, 0, '<Day,2>/<Month,2>/<Year>')) { }
            Column(texto_iva; TextoIva) { }

            trigger OnAfterGetRecord()
            var
                Ins: InStream;
                InputFile: File;
                Cat: Record "Customer Price Group";
                FromSalesPrice: Record "Price List Line";
                StartingDate: date;
                Tipo: Record "Tipo Recurso";
                ControlProcesos: Codeunit ControlProcesos;
                TempBlob: Codeunit "Temp Blob";
                OutStr: OutStream;
                InStr: InStream;
                Base64Convert: Codeunit "Base64 Convert";
                base64: Text;

            begin
                rSetup.Get;
                Tipo.ChangeCompany(Resource.Empresa);
                if Not Tipo.Get(Resource."Tipo Recurso") Then Tipo.Init();

                //'file://'
                //123456
                if StartingDate = 0D THEN StartingDate := WORKDATE;
                FromSalesPrice.SETFILTER("Ending Date", '%1|>=%2', 0D, StartingDate);
                FromSalesPrice.SETRANGE("Starting Date", 0D, StartingDate);
                FromSalesPrice.SETRANGE("Source Type", FromSalesPrice."Source Type"::"Customer Price Group");
                FromSalesPrice.SETRANGE("Source No.", Resource."Customer Price Group");
                if Not FromSalesPrice.FINDLAST THEN FromSalesPrice.Init();
                // if File.Exists(Copystr(Tipo."Ruta imagenes", 6) + '\' + Resource."No." + '.jpg') Then Begin
                //     InputFile.Open(Copystr(Tipo."Ruta imagenes", 6) + '\' + Resource."No." + '.jpg');
                //     InputFile.CreateInStream(Ins);
                //     //Resource.CalcFields(Image);
                //     Resource.Image.ImportStream(ins, 'Image');
                // end else begin
                Base64 := ControlProcesos.GetFileAsBase64(Copystr(Tipo."Ruta imagenes", 6) + '\' + Resource."No." + '.jpg', 'http://192.168.10.226:8089');
                If Base64 <> '' Then begin
                    TempBlob.CreateOutStream(OutStr);
                    Base64Convert.FromBase64(base64, OutStr);
                    TempBlob.CreateInStream(InS);
                    Resource.Image.ImportStream(ins, 'Image');

                    TempBlob.CreateInStream(InS);
                    Resource.Image.ImportStream(ins, 'Image');
                end;
                //end;
                if Not Cat.Get(Resource."Customer Price Group") Then Cat.Init;
                Categ := Cat.Description;
                if Resource."Alquiler Anual" = 0 Then Resource."Alquiler Anual" := FromSalesPrice."Unit Price";
                if Resource."Local - Alquiler 7 Meses" = 0 Then Resource."Local - Alquiler 7 Meses" := FromSalesPrice."Unit Price" / 2;
                if Resource."Nacional - Alquiler Anual" = 0 Then Resource."Nacional - Alquiler Anual" := FromSalesPrice."Unit Price";
                if Resource."Nacional - Alquiler 7 Meses" = 0 Then Resource."Nacional - Alquiler 7 Meses" := FromSalesPrice."Unit Price" / 2;
                if Rec."Tipo Cliente" = Rec."Tipo Cliente"::Local Then begin
                    Resource."Nacional - Alquiler Anual" := Resource."Alquiler Anual";
                    Resource."Nacional - Alquiler 7 Meses" := Resource."Local - Alquiler 7 Meses";
                end;
                Mes := ' ';
                if Resource."Tipo Recurso" = 'VALLA' then Mes := '/Mes';
                if Resource."Tipo Recurso" = 'OPI' then Mes := '/Mes';
                If Resource."Tipo Recurso" = 'MINI OPI' Then Mes := '/Mes';
                If Resource."Tipo Recurso" = 'OPI SMAP' Then Mes := '/Mes';
                if Resource."Tipo Recurso" = 'LED' then Mes := '/Mes';
                if Resource."Tipo Recurso" = 'OPIDIGITAL' then Mes := '/Mes';
                if Resource."Tipo Recurso" = 'OPI DIGIT.' then Mes := '/Mes';
                //Indicador
                if Resource."Tipo Recurso" = 'INDICADOR' then Mes := '/Mes';
                if Resource."Tipo Recurso" = 'IND.CALLE' then Mes := '/Mes';
                //Peatonales
                if Resource."Tipo Recurso" = 'VPEATON' then Mes := '/Mes';
                //Reloj
                if Resource."Tipo Recurso" = 'RELOJ' then Mes := '/Mes';
                //Digitales
                if Resource."Tipo Recurso" = 'OPIDIGITAL' then Mes := '/Mes';
                if Resource."Tipo Recurso" = 'OPI DIGIT.' then Mes := '/Mes';
                // 'ASCENSORES' | 'ASCENSOR'
                if Resource."Tipo Recurso" = 'ASCENSORES' then Mes := '/Mes';
                if Resource."Tipo Recurso" = 'ASCENSOR' then Mes := '/Mes';
                //Ind.Calle
                if Rec.Precios Then begin
                    TextoIva := '(todos los precios son sin iva)';
                    Case "Rec"."Tipo Precios" of
                        "Rec"."Tipo Precios"::"anual y Temporada":
                            Begin
                                AnualP := Anual + ' ' + Format(Resource."Nacional - Alquiler Anual", 0, '<Precision,2:2><Standard Format,0>') + '€' + Mes;
                                TemporadaP := Temporada + ' ' + Format(Resource."Nacional - Alquiler 7 Meses", 0, '<Precision,2:2><Standard Format,0>') + '€' + Mes;
                            End;
                        "Rec"."Tipo Precios"::"solo anual":
                            Begin
                                AnualP := Anual + ' ' + Format(Resource."Nacional - Alquiler Anual", 0, '<Precision,2:2><Standard Format,0>') + '€' + Mes;
                                TemporadaP := ' ';
                            End;
                    End;
                    Alq := 'Alquiler';
                    TCateg := 'Categoria';
                end else begin
                    Anual := '';
                    Temporada := '';
                    Categ := '';
                    DtoAgencia := '';
                    TCateg := '';
                    Alq := '';
                end;
                //if rUser."Tipo Cliente" = "User Setup"."Tipo Cliente"::Local Then
                //  DtoAgencia := '' else
                //CProhibiciones := Resource.Prohibiciones;
                if Not Rec.Prohibiciones Then Resource.Prohibiciones := '';
                if Resource.Prohibiciones = '' Then TProhibiciones := '' else TProhibiciones := 'Prohibiciones';


            end;

            trigger OnPreDataItem()
            begin
                if Ordenar Then Resource.SetCurrentKey(Empresa, "Tipo Recurso", Municipio);
                Resource.SetRange(Seleccionar, true);
                Resource.SetRange(UserId, UserId());
                if CompanyName <> 'Malla Publicidad' then
                    Resource.SetRange(Empresa, CompanyName);
                Resource.FindFirst();

            end;


        }
    }
    requestpage
    {
        SaveValues = false;
        SourceTable = "User Setup";
        layout
        {
            area(content)
            {
                group(Opciones)
                {
                    field("Comerial"; Rec.Comercial) { ApplicationArea = All; }//	$001
                    field(Cliente; Rec."Cliente") { ApplicationArea = All; }
                    field("Tipo Informe"; Rec."Tipo Informe") { ApplicationArea = All; }
                    field("¿Con precios?"; Rec."Precios") { ApplicationArea = All; }
                    field("¿Con prohibiciones?"; Rec."Prohibiciones") { ApplicationArea = All; }
                    // field("¿Agencia o Local?"; Rec."Tipo Cliente")
                    // {
                    //     ApplicationArea = All;
                    //     trigger OnValidate()
                    //     begin
                    //         if Rec."Tipo Cliente" = Rec."Tipo Cliente"::Agencia then
                    //             DtoAgencia := '**Descuento de agencia e IVA no incluidos' else
                    //             DtoAgencia := '';
                    //     end;
                    // }
                    field("Con que precios"; Rec."Tipo Precios") { ApplicationArea = All; }
                    field("Con Que calidad"; Rec."Calidad") { ApplicationArea = All; }
                    field("Texto Temporada"; Temporada) { ApplicationArea = All; }
                    field("Texto disponibilidad"; Disponibilidad) { ApplicationArea = All; }
                    field("Texto Agencia"; DtoAgencia) { ApplicationArea = All; }
                    field("¿Ordenar Por Municipo?"; Ordenar)
                    {
                        ApplicationArea = All;
                        trigger OnValidate()
                        begin
                            if Ordenar then
                                Resource.SetCurrentKey(Empresa, "Tipo Recurso", Municipio);
                        end;
                    }

                }
            }

        }
        trigger OnOpenPage()
        begin
            Rec.Get(UserId);
            Anual := 'Anual:';
            Temporada := '7 meses:';
            Disponibilidad := '*Disponibilidades a dia de hoy, sin reserva de Soportes';
            if Rec."Tipo Cliente" = Rec."Tipo Cliente"::Agencia then
                DtoAgencia := '**Descuento de agencia e IVA no incluidos' else
                DtoAgencia := '';

        end;

        trigger OnInit()
        begin
            Rec.Get(UserId);
            Anual := 'Anual:';
            Temporada := '7 meses:';
            Disponibilidad := '*Disponibilidades a dia de hoy, sin reserva de Soportes';

        end;


    }
    var
        Alq: Text;
        TCateg: Text;
        rSetup: Record 314;
        TM: Record "Tenant Media";
        FileManagement: Codeunit "File Management";
        Anual: Text;
        Temporada: Text;
        AnualP: Text;
        TemporadaP: Text;
        Disponibilidad: Text;
        DtoAgencia: Text;
        Categ: Text;
        TProhibiciones: Text[100];
        Ordenar: Boolean;
        TextoIva: Text;
        Mes: Text;

    trigger OnInitReport()
    begin
        rSetup.Get;
        "User Setup".SetRange("User ID", UserId);
        Resource.SetRange(Seleccionar, true);

    end;

    trigger OnPreReport()
    begin
        "User Setup".SetRange("User ID", UserId);
        Resource.SetRange(Seleccionar, true);
    end;





}
