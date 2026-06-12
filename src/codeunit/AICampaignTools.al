/// <summary>
/// Fachada controlada para agentes IA sobre campañas OOH.
/// Expone operaciones de negocio en JSON sin dar acceso directo a tablas internas.
/// </summary>
codeunit 50021 "AI Campaign Tools"
{
    [ServiceEnabled]
    procedure buscarSoportes(RequestJson: Text): Text
    var
        Req: JsonObject;
        Resp: JsonObject;
        Items: JsonArray;
        Resource: Record Resource;
        TipoRecursoFilter: Text;
        Zona: Code[20];
        ZonaNormalizada: Text;
        Municipio: Code[15];
        Medidas: Code[20];
        Texto: Text;
        FechaInicio: Date;
        FechaFin: Date;
        SoloDisponibles: Boolean;
        MaxItems: Integer;
        Added: Integer;
        ListaEmpresas: List of [Text[30]];
        Empresa: Text[30];
        ZonaText: Text;
    begin
        ListaEmpresas.Add('Malla Publicidad');
        ListaEmpresas.Add('Grepsa');
        ListaEmpresas.add('Ibiza Publicidad, S.A.');
        ListaEmpresas.add('Menorca de Publicidad, S.A.');
        if not ReadRequest(RequestJson, Req, Resp) then
            exit(JsonToText(Resp));

        TipoRecursoFilter := BuildTipoRecursoFilterFromRequest(Req);
        Zona := CopyStr(GetJsonText(Req, 'zona'), 1, MaxStrLen(Zona));
        ZonaNormalizada := UpperCase(DelChr(Zona, '<>', ' '));
        Municipio := CopyStr(GetJsonText(Req, 'municipio'), 1, MaxStrLen(Municipio));
        Medidas := CopyStr(GetJsonText(Req, 'medidas'), 1, MaxStrLen(Medidas));
        Texto := GetJsonText(Req, 'texto');
        FechaInicio := GetJsonDate(Req, 'fechaInicio');
        FechaFin := GetJsonDate(Req, 'fechaFin');
        SoloDisponibles := GetJsonBoolean(Req, 'soloDisponibles');
        MaxItems := GetJsonInteger(Req, 'max');
        if MaxItems <= 0 then
            MaxItems := 50;


        foreach Empresa in ListaEmpresas do begin
            Resource.Reset();
            Resource.ChangeCompany(Empresa);
            Resource.SetRange(Blocked, false);
            resource.SetRange("Empresa Origen", '');
            ApplySeleccionRecursosTypeFilter(Resource, TipoRecursoFilter);
            ZonaText := '';
            if Zona <> '' then begin
                case ZonaNormalizada of
                    'MALLORCA':
                        If Empresa in ['Ibiza Publicidad, S.A.', 'Menorca de Publicidad, S.A.'] then
                            continue;
                    'MENORCA':
                        If Empresa <> 'Menorca de Publicidad, S.A.' then
                            continue;
                    'IBIZA':
                        If Empresa <> 'Ibiza Publicidad, S.A.' then
                            continue;
                    else begin
                        ZonaText := Zona;
                    end;

                end;
            end;
            if Municipio <> '' then
                Resource.SetRange(Municipio, Municipio);
            if Medidas <> '' then
                Resource.SetRange(Medidas, Medidas);
            if Texto <> '' then
                Resource.SetFilter(Name, '@*%1*', Texto);

            if Resource.FindSet() then
                repeat
                    if IncludeResource(Resource, FechaInicio, FechaFin, SoloDisponibles, Empresa, ZonaText) then begin
                        AddResourceJson(Items, Resource, FechaInicio, FechaFin, Empresa);
                        Added += 1;
                    end;
                until (Resource.Next() = 0) or (Added >= MaxItems);

            if Added >= MaxItems then
                break;
        end;

        Resp.Add('ok', true);
        Resp.Add('count', Added);
        Resp.Add('items', Items);
        exit(JsonToText(Resp));
    end;

    [ServiceEnabled]
    procedure obtenerDisponibilidad(RequestJson: Text): Text
    var
        Req: JsonObject;
        Resp: JsonObject;
        Items: JsonArray;
        Tok: JsonToken;
        ResourceNos: JsonArray;
        ResourceNoTok: JsonToken;
        ResourceNo: Code[20];
        Resource: Record Resource;
        FechaInicio: Date;
        FechaFin: Date;
        Empresa: Text[30];
    begin
        if not ReadRequest(RequestJson, Req, Resp) then
            exit(JsonToText(Resp));

        FechaInicio := GetJsonDate(Req, 'fechaInicio');
        FechaFin := GetJsonDate(Req, 'fechaFin');
        Empresa := CopyStr(GetJsonText(Req, 'empresa'), 1, MaxStrLen(Empresa));
        if (FechaInicio = 0D) or (FechaFin = 0D) or (FechaFin < FechaInicio) then
            exit(ErrorResponse('Rango de fechas no valido.'));

        if Req.Get('resourceNos', Tok) then begin
            ResourceNos := Tok.AsArray();
            foreach ResourceNoTok in ResourceNos do begin
                ResourceNo := CopyStr(TokenAsText(ResourceNoTok), 1, MaxStrLen(ResourceNo));
                if Resource.Get(ResourceNo) then
                    AddAvailabilityJson(Items, Resource, FechaInicio, FechaFin, Empresa);
            end;
        end else begin
            Resource.Reset();
            Resource.ChangeCompany(Empresa);
            Resource.SetRange(Blocked, false);
            if Resource.FindSet() then
                repeat
                    AddAvailabilityJson(Items, Resource, FechaInicio, FechaFin, Empresa);
                until Resource.Next() = 0;
        end;

        Resp.Add('ok', true);
        Resp.Add('items', Items);
        exit(JsonToText(Resp));
    end;

    [ServiceEnabled]
    procedure calcularPrecio(RequestJson: Text): Text
    var
        Req: JsonObject;
        Resp: JsonObject;
        Job: Record Job temporary;
        Resource: Record Resource;
        ControlProcesos: Codeunit ControlProcesos;
        ResourceNo: Code[20];
        CustomerNo: Code[20];
        ItemDiscGroup: Code[20];
        FechaInicio: Date;
        FechaFin: Date;
        Cantidad: Decimal;
        Duracion: Decimal;
        TipoDuracion: Enum Duracion;
        Agencia: Boolean;
        PrecioUnitario: Decimal;
        Empresa: Text[30];
    begin
        if not ReadRequest(RequestJson, Req, Resp) then
            exit(JsonToText(Resp));

        Empresa := CopyStr(GetJsonText(Req, 'empresa'), 1, MaxStrLen(Empresa));
        ResourceNo := CopyStr(GetJsonText(Req, 'resourceNo'), 1, MaxStrLen(ResourceNo));
        CustomerNo := CopyStr(GetJsonText(Req, 'customerNo'), 1, MaxStrLen(CustomerNo));
        ItemDiscGroup := CopyStr(GetJsonText(Req, 'itemDiscGroup'), 1, MaxStrLen(ItemDiscGroup));
        FechaInicio := GetJsonDate(Req, 'fechaInicio');
        FechaFin := GetJsonDate(Req, 'fechaFin');
        Cantidad := GetJsonDecimal(Req, 'cantidad');
        Duracion := GetJsonDecimal(Req, 'duracion');
        Agencia := GetJsonBoolean(Req, 'agencia');
        TipoDuracion := ParseTipoDuracion(GetJsonText(Req, 'tipoDuracion'));

        if ResourceNo = '' then
            exit(ErrorResponse('Falta resourceNo.'));
        if Empresa <> '' then
            Resource.ChangeCompany(Empresa);
        if not Resource.Get(ResourceNo) then
            exit(ErrorResponse(StrSubstNo('No existe el recurso %1.', ResourceNo)));
        if ItemDiscGroup = '' then
            ItemDiscGroup := Resource."Customer Price Group";
        if Cantidad = 0 then
            Cantidad := 1;
        if FechaInicio = 0D then
            FechaInicio := WorkDate();
        if FechaFin = 0D then
            FechaFin := FechaInicio;
        if Duracion = 0 then
            Duracion := CalculateDuration(FechaInicio, FechaFin, TipoDuracion);

        Job.Init();
        Job."No." := 'AI-CALC';
        Job."Bill-to Customer No." := CustomerNo;
        Job."Starting Date" := FechaInicio;
        Job."Ending Date" := FechaFin;

        PrecioUnitario := ControlProcesos.FindResourcePriceNew(Agencia, ItemDiscGroup, FechaInicio, 0, Job, ResourceNo, Cantidad, Duracion, TipoDuracion, Empresa);

        Resp.Add('ok', true);
        Resp.Add('resourceNo', ResourceNo);
        Resp.Add('unitPrice', PrecioUnitario);
        Resp.Add('quantity', Cantidad);
        Resp.Add('duration', Duracion);
        Resp.Add('lineAmount', Round(PrecioUnitario * Cantidad * Duracion, 0.01));
        if PrecioUnitario = 0 then
            Resp.Add('warning', 'No se ha encontrado tarifa aplicable; no inventar precio.');
        exit(JsonToText(Resp));
    end;

    [ServiceEnabled]
    procedure obtenerHistorialCliente(RequestJson: Text): Text
    var
        Req: JsonObject;
        Resp: JsonObject;
        Items: JsonArray;
        Job: Record Job;
        JobPlanningLine: Record "Job Planning Line";
        Resource: Record Resource;
        CustomerNo: Code[20];
        MaxItems: Integer;
        Added: Integer;
    begin
        if not ReadRequest(RequestJson, Req, Resp) then
            exit(JsonToText(Resp));

        CustomerNo := CopyStr(GetJsonText(Req, 'customerNo'), 1, MaxStrLen(CustomerNo));
        if CustomerNo = '' then
            exit(ErrorResponse('Falta customerNo.'));

        MaxItems := GetJsonInteger(Req, 'max');
        if MaxItems <= 0 then
            MaxItems := 50;

        Job.Reset();
        Job.SetRange("Bill-to Customer No.", CustomerNo);
        if Job.FindSet() then
            repeat
                JobPlanningLine.Reset();
                JobPlanningLine.SetRange("Job No.", Job."No.");
                JobPlanningLine.SetRange("Line Type", JobPlanningLine."Line Type"::Budget);
                JobPlanningLine.SetRange(Type, JobPlanningLine.Type::Resource);
                if JobPlanningLine.FindSet() then
                    repeat
                        if Resource.Get(JobPlanningLine."No.") then begin
                            AddHistoryLineJson(Items, Job, JobPlanningLine, Resource);
                            Added += 1;
                        end;
                    until (JobPlanningLine.Next() = 0) or (Added >= MaxItems);
            until (Job.Next() = 0) or (Added >= MaxItems);

        Resp.Add('ok', true);
        Resp.Add('customerNo', CustomerNo);
        Resp.Add('count', Added);
        Resp.Add('items', Items);
        exit(JsonToText(Resp));
    end;

    [ServiceEnabled]
    procedure crearBorradorPresupuesto(RequestJson: Text): Text
    var
        Req: JsonObject;
        Resp: JsonObject;
        LinesTok: JsonToken;
        Lines: JsonArray;
        LineTok: JsonToken;
        LineObj: JsonObject;
        Job: Record Job;
        JobTask: Record "Job Task";
        JobPlanningLine: Record "Job Planning Line";
        CreatedLines: JsonArray;
        LineResp: JsonObject;
        JobNo: Code[20];
        JobTaskNo: Code[20];
        LineNo: Integer;
    begin
        if not ReadRequest(RequestJson, Req, Resp) then
            exit(JsonToText(Resp));

        CreateDraftJob(Req, Job);

        JobTaskNo := CopyStr(GetJsonText(Req, 'jobTaskNo'), 1, MaxStrLen(JobTaskNo));
        if JobTaskNo = '' then
            JobTaskNo := EnsureDefaultJobTask(Job);

        if Req.Get('lines', LinesTok) then
            Lines := LinesTok.AsArray();

        LineNo := GetLastJobPlanningLineNo(Job."No.", JobTaskNo);
        foreach LineTok in Lines do begin
            LineObj := LineTok.AsObject();
            LineNo += 10000;
            CreateDraftJobLine(Job, JobTaskNo, LineNo, LineObj, JobPlanningLine);

            Clear(LineResp);
            LineResp.Add('lineNo', JobPlanningLine."Line No.");
            LineResp.Add('type', Format(JobPlanningLine.Type));
            LineResp.Add('no', JobPlanningLine."No.");
            LineResp.Add('description', JobPlanningLine.Description);
            LineResp.Add('quantity', JobPlanningLine.Quantity);
            LineResp.Add('unitPrice', JobPlanningLine."Unit Price");
            LineResp.Add('fechaInicio', FormatDateIso(JobPlanningLine."Planning Date"));
            LineResp.Add('fechaFin', FormatDateIso(JobPlanningLine."Fecha Final"));
            LineResp.Add('reservableQuantity', JobPlanningLine."Cdad. a Reservar");
            CreatedLines.Add(LineResp);
        end;

        JobNo := Job."No.";
        Resp.Add('ok', true);
        Resp.Add('jobNo', JobNo);
        Resp.Add('jobTaskNo', JobTaskNo);
        Resp.Add('lines', CreatedLines);
        exit(JsonToText(Resp));
    end;

    local procedure CreateDraftJob(var Req: JsonObject; var Job: Record Job)
    var
        JobsSetup: Record "Jobs Setup";
        JobPostingGroup: Record "Job Posting Group";
        GenericJob: Record Job;
        GenericJobTask: Record "Job Task";
        JobTask: Record "Job Task";
        NoSeries: Codeunit "No. Series";
        JobNo: Code[20];
        CustomerNo: Code[20];
    begin
        JobNo := CopyStr(GetJsonText(Req, 'jobNo'), 1, MaxStrLen(JobNo));
        CustomerNo := CopyStr(GetJsonText(Req, 'customerNo'), 1, MaxStrLen(CustomerNo));
        if CustomerNo = '' then
            Error('Falta customerNo.');

        JobsSetup.Get();
        if JobNo = '' then
            JobNo := NoSeries.GetNextNo(JobsSetup."Job Nos.", WorkDate(), true);

        if Job.Get(JobNo) then
            Error('Ya existe el presupuesto/proyecto %1.', JobNo);

        Job.Init();
        Job."No." := JobNo;
        Job.Insert(false);
        Job.Validate("Bill-to Customer No.", CustomerNo);
        Job.Validate("Sell-to Customer No.", CustomerNo);
        Job.Description := CopyStr(GetJsonText(Req, 'description'), 1, MaxStrLen(Job.Description));
        Job."Nombre Comercial" := CopyStr(GetJsonText(Req, 'advertiserName'), 1, MaxStrLen(Job."Nombre Comercial"));
        Job."Starting Date" := GetJsonDate(Req, 'fechaInicio');
        Job."Ending Date" := GetJsonDate(Req, 'fechaFin');
        Job."Según disponibilidad" := GetJsonBoolean(Req, 'segunDisponibilidad');
        Job.Status := Job.Status::Planning;
        Job."Creation Date" := Today();

        if JobPostingGroup.FindFirst() then
            Job."Job Posting Group" := JobPostingGroup.Code;

        JobsSetup.TestField("Cód. Proyecto Genérico");
        if GenericJob.Get(JobsSetup."Cód. Proyecto Genérico") then begin
            GenericJobTask.SetRange("Job No.", GenericJob."No.");
            if GenericJobTask.FindSet() then
                repeat
                    JobTask := GenericJobTask;
                    JobTask."Job No." := Job."No.";
                    JobTask."Job Posting Group" := Job."Job Posting Group";
                    JobTask."Global Dimension 1 Code" := Job."Global Dimension 1 Code";
                    JobTask."Global Dimension 2 Code" := Job."Global Dimension 2 Code";
                    if not JobTask.Insert(false) then;
                until GenericJobTask.Next() = 0;
        end;

        Job.Modify(true);
    end;

    local procedure EnsureDefaultJobTask(var Job: Record Job): Code[20]
    var
        JobTask: Record "Job Task";
    begin
        JobTask.SetRange("Job No.", Job."No.");
        if JobTask.FindFirst() then
            exit(JobTask."Job Task No.");

        JobTask.Init();
        JobTask."Job No." := Job."No.";
        JobTask."Job Task No." := '10';
        JobTask.Description := 'Recursos';
        JobTask."Job Posting Group" := Job."Job Posting Group";
        JobTask.Insert(true);
        exit(JobTask."Job Task No.");
    end;

    local procedure CreateDraftJobLine(var Job: Record Job; JobTaskNo: Code[20]; LineNo: Integer; var LineObj: JsonObject; var JobPlanningLine: Record "Job Planning Line")
    var
        Resource: Record Resource;
        Tipo: Record "Tipo Recurso";
        ResourceNo: Code[20];
        Quantity: Decimal;
        UnitPrice: Decimal;
    begin
        ResourceNo := CopyStr(GetJsonText(LineObj, 'resourceNo'), 1, MaxStrLen(ResourceNo));
        if ResourceNo = '' then
            Error('Todas las lineas deben informar resourceNo.');
        if not Resource.Get(ResourceNo) then
            Error('No existe el recurso %1.', ResourceNo);

        Quantity := GetJsonDecimal(LineObj, 'quantity');
        if Quantity = 0 then
            Quantity := 1;
        UnitPrice := GetJsonDecimal(LineObj, 'unitPrice');

        JobPlanningLine.Init();
        JobPlanningLine."Job No." := Job."No.";
        JobPlanningLine."Job Task No." := JobTaskNo;
        JobPlanningLine."Line No." := LineNo;
        JobPlanningLine."Line Type" := JobPlanningLine."Line Type"::Budget;
        JobPlanningLine.Type := JobPlanningLine.Type::Resource;
        JobPlanningLine.Validate("No.", ResourceNo);
        JobPlanningLine."Planning Date" := FirstNonZeroDate(GetJsonDate(LineObj, 'fechaInicio'), Job."Starting Date");
        JobPlanningLine.Validate("Fecha Final", FirstNonZeroDate(GetJsonDate(LineObj, 'fechaFin'), Job."Ending Date"));
        if GetJsonText(LineObj, 'description') <> '' then
            JobPlanningLine.Description := CopyStr(GetJsonText(LineObj, 'description'), 1, MaxStrLen(JobPlanningLine.Description));
        JobPlanningLine.Validate(Quantity, Quantity);
        if UnitPrice <> 0 then
            JobPlanningLine.Validate("Unit Price", UnitPrice);

        if Tipo.Get(Resource."Tipo Recurso") then
            if Tipo."Crea Reservas" and (not Resource."Recurso Agrupado") and (not Resource.Producción) and (Resource."Empresa Origen" = '') then
                JobPlanningLine."Cdad. a Reservar" := 1;

        JobPlanningLine.Insert(true);
    end;

    local procedure GetLastJobPlanningLineNo(JobNo: Code[20]; JobTaskNo: Code[20]): Integer
    var
        JobPlanningLine: Record "Job Planning Line";
    begin
        JobPlanningLine.SetRange("Job No.", JobNo);
        JobPlanningLine.SetRange("Job Task No.", JobTaskNo);
        if JobPlanningLine.FindLast() then
            exit(JobPlanningLine."Line No.");
        exit(0);
    end;

    local procedure ApplySeleccionRecursosTypeFilter(var Resource: Record Resource; TipoRecursoFilter: Text)
    begin
        if TipoRecursoFilter = '' then
            TipoRecursoFilter := GetAllSeleccionRecursosTypeFilter();
        Resource.SetFilter("Tipo Recurso", TipoRecursoFilter);
    end;

    local procedure BuildTipoRecursoFilterFromRequest(var Req: JsonObject): Text
    var
        Tok: JsonToken;
        TipoArray: JsonArray;
        TipoToken: JsonToken;
        TipoText: Text;
        SingleFilter: Text;
        CombinedFilter: Text;
    begin
        if not Req.Get('tipoRecurso', Tok) then
            exit(GetAllSeleccionRecursosTypeFilter());

        if Tok.IsArray() then begin
            TipoArray := Tok.AsArray();
            if TipoArray.Count() = 0 then
                exit(GetAllSeleccionRecursosTypeFilter());

            foreach TipoToken in TipoArray do begin
                TipoText := TokenAsText(TipoToken);
                if TipoText = '' then
                    continue;
                SingleFilter := GetSeleccionRecursosTypeFilter(TipoText);
                if SingleFilter = '__TIPO_RECURSO_NO_VISIBLE__' then
                    continue;
                CombinedFilter := AppendTipoRecursoFilter(CombinedFilter, SingleFilter);
            end;

            if CombinedFilter = '' then
                exit('__TIPO_RECURSO_NO_VISIBLE__');
            exit(CombinedFilter);
        end;

        SingleFilter := GetSeleccionRecursosTypeFilter(TokenAsText(Tok));
        if SingleFilter = '' then
            exit(GetAllSeleccionRecursosTypeFilter());
        exit(SingleFilter);
    end;

    local procedure AppendTipoRecursoFilter(CurrentFilter: Text; NewFilter: Text): Text
    var
        FilterPart: Text;
        PipePos: Integer;
    begin
        if NewFilter = '' then
            exit(CurrentFilter);

        if CurrentFilter = '' then
            exit(NewFilter);

        while NewFilter <> '' do begin
            PipePos := StrPos(NewFilter, '|');
            if PipePos = 0 then begin
                if StrPos('|' + CurrentFilter + '|', '|' + NewFilter + '|') = 0 then
                    if CurrentFilter = '' then
                        CurrentFilter := NewFilter
                    else
                        CurrentFilter += '|' + NewFilter;
                exit(CurrentFilter);
            end;

            FilterPart := CopyStr(NewFilter, 1, PipePos - 1);
            if StrPos('|' + CurrentFilter + '|', '|' + FilterPart + '|') = 0 then
                if CurrentFilter = '' then
                    CurrentFilter := FilterPart
                else
                    CurrentFilter += '|' + FilterPart;
            NewFilter := CopyStr(NewFilter, PipePos + 1);
        end;

        exit(CurrentFilter);
    end;

    local procedure GetSeleccionRecursosTypeFilter(TipoRecursoText: Text): Text
    var
        NormalizedTipo: Text;
    begin
        if TipoRecursoText = '' then
            exit('');

        NormalizedTipo := NormalizeResourceTypeText(TipoRecursoText);
        case NormalizedTipo of
            'OPI', 'OPIS':
                exit('OPI');
            'VALLA', 'VALLAS':
                exit('VALLA');
            'VALLAS_PEATONALES', 'PEATON', 'PEATONAL', 'PEATONALES', 'PEATONAES', 'VPEATON', 'VALLAPEATON', 'VALLASPEATONALES', 'PPEATOAL':
                exit('VPEATON|V.PEATON|P.PEATOAL');
            'MEDIANERA', 'MEDIANERAS':
                exit('MEDIANERA');
            'INDICADORES_CALLE', 'INDICADOR', 'INDICADORES', 'INDCALLE', 'INDICADORCALLE', 'INDICADORDECALLE',
            'INDICADORESCALLE', 'INDICADORESDECALLE':
                exit('INDICADOR|IND.CALLE');
            'VALLAS_2X150', '2X150', '2X1', '2X1M50', 'V2X150', 'VALLA2X150', 'VALLAS2X150':
                exit('2x1''50');
            'SNAP', 'SMAP', 'MINIOPI', 'OPISMAP':
                exit('MINI OPI|OPI SMAP');
            'ASCENSOR', 'ASCENSORES':
                exit('ASCENSORES|ASCENSOR');
            'OPIS_DIGITALES', 'DIGITAL', 'DIGITALES', 'OPIDIGITAL', 'OPIDIGIT', 'OPISDIGITALES', 'PLED', 'PLEDS', 'LEDS':
                exit('OPIDIGITAL|OPI DIGIT.|P.LEDS');
            'RELOJ', 'RELOJES':
                exit('RELOJ');
        end;

        exit('__TIPO_RECURSO_NO_VISIBLE__');
    end;

    local procedure GetAllSeleccionRecursosTypeFilter(): Text
    begin
        exit('OPI|VALLA|VPEATON|V.PEATON|P.PEATOAL|MEDIANERA|INDICADOR|IND.CALLE|2x1''50|MINI OPI|OPI SMAP|ASCENSORES|ASCENSOR|OPIDIGITAL|OPI DIGIT.|P.LEDS|RELOJ');
    end;

    local procedure NormalizeResourceTypeText(Value: Text): Text
    var
        Result: Text;
        i: Integer;
        C: Char;
    begin
        Value := UpperCase(Value);
        for i := 1 to StrLen(Value) do begin
            C := Value[i];
            if StrPos('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_', Format(C)) > 0 then
                Result += C;
        end;
        exit(Result);
    end;

    local procedure IncludeResource(var Resource: Record Resource; FechaInicio: Date; FechaFin: Date; SoloDisponibles: Boolean; Empresa: Text[30]; ZonaText: Text): Boolean
    begin
        if Resource.Blocked then
            exit(false);
        if (Resource."Fecha baja" <> 0D) and ((FechaFin = 0D) or (Resource."Fecha baja" <= FechaFin)) then
            exit(false);
        if (ZonaText <> '') and (not ResourceMatchesZonaSearch(Resource, ZonaText, Empresa)) then
            exit(false);
        if not SoloDisponibles then
            exit(true);
        if (FechaInicio = 0D) or (FechaFin = 0D) then
            exit(true);
        exit(IsResourceAvailable(Resource."No.", FechaInicio, FechaFin, Empresa));
    end;

    local procedure ResourceMatchesZonaSearch(var Resource: Record Resource; SearchText: Text; Empresa: Text[30]): Boolean
    var
        ZonasRecursos: Record "Zonas Recursos";
        ZoneDescription: Text;
    begin
        ZoneDescription := '';
        if Resource.Zona <> '' then begin
            ZonasRecursos.ChangeCompany(Empresa);
            if ZonasRecursos.Get(Resource.Zona) then
                ZoneDescription := ZonasRecursos."Texto Zona";
        end;

        exit(ZonaTextMatchesSearch(SearchText, Resource.Zona, ZoneDescription, Resource.Municipio));
    end;

    local procedure ZonaTextMatchesSearch(SearchText: Text; ZoneCode: Text; ZoneDescription: Text; Municipio: Text): Boolean
    var
        NormalizedSearch: Text;
        Haystack: Text;
    begin
        NormalizedSearch := NormalizeZonaText(SearchText);
        if NormalizedSearch = '' then
            exit(true);

        Haystack := NormalizeZonaText(ZoneCode) + ' ' +
            NormalizeZonaText(ZoneDescription) + ' ' +
            NormalizeZonaText(Municipio);

        if StrPos(Haystack, NormalizedSearch) > 0 then
            exit(true);

        exit(ZonaTokensMatch(NormalizedSearch, Haystack));
    end;

    local procedure ZonaTokensMatch(SearchText: Text; Haystack: Text): Boolean
    var
        SearchTokens: List of [Text];
        HaystackTokens: List of [Text];
        SearchToken: Text;
        HaystackToken: Text;
    begin
        SplitZonaTokens(SearchText, SearchTokens);
        if SearchTokens.Count = 0 then
            exit(false);

        SplitZonaTokens(Haystack, HaystackTokens);

        foreach SearchToken in SearchTokens do begin
            if StrLen(SearchToken) < 3 then
                continue;
            foreach HaystackToken in HaystackTokens do
                if ZonaTokensAreSimilar(SearchToken, HaystackToken) then
                    exit(true);
        end;

        exit(false);
    end;

    local procedure ZonaTokensAreSimilar(TokenA: Text; TokenB: Text): Boolean
    var
        MinOverlap: Integer;
        i: Integer;
        Sub: Text;
    begin
        if (TokenA = '') or (TokenB = '') then
            exit(false);
        if TokenA = TokenB then
            exit(true);
        if (StrLen(TokenA) >= 3) and (StrPos(TokenB, TokenA) > 0) then
            exit(true);
        if (StrLen(TokenB) >= 3) and (StrPos(TokenA, TokenB) > 0) then
            exit(true);

        MinOverlap := 5;
        if StrLen(TokenA) < MinOverlap then
            MinOverlap := StrLen(TokenA);
        if StrLen(TokenB) < MinOverlap then
            MinOverlap := StrLen(TokenB);
        if MinOverlap < 4 then
            exit(false);

        for i := 1 to StrLen(TokenA) - MinOverlap + 1 do begin
            Sub := CopyStr(TokenA, i, MinOverlap);
            if StrPos(TokenB, Sub) > 0 then
                exit(true);
        end;

        exit(false);
    end;

    local procedure SplitZonaTokens(Value: Text; var Tokens: List of [Text])
    var
        Word: Text;
        i: Integer;
        C: Char;
    begin
        Clear(Tokens);
        Value := DelChr(Value, '<>', ' ');
        Word := '';
        for i := 1 to StrLen(Value) do begin
            C := Value[i];
            if C = ' ' then begin
                if (Word <> '') and (not IsZonaStopWord(Word)) then
                    Tokens.Add(Word);
                Word := '';
            end else
                Word += C;
        end;
        if (Word <> '') and (not IsZonaStopWord(Word)) then
            Tokens.Add(Word);
    end;

    local procedure IsZonaStopWord(Word: Text): Boolean
    begin
        exit(Word in ['EL', 'LA', 'LOS', 'LAS', 'DE', 'DEL', 'O', 'V', 'Y', 'EN', 'UN', 'UNA', 'SA', 'SL', 'SLU']);
    end;

    local procedure NormalizeZonaText(Value: Text): Text
    var
        Result: Text;
        i: Integer;
        C: Char;
    begin
        Value := UpperCase(Value);
        for i := 1 to StrLen(Value) do begin
            C := Value[i];
            if C in ['-', '+', '/', '\', '.', ',', ';', ':', '&', '(', ')'] then
                Result += ' '
            else
                Result += C;
        end;

        while StrPos(Result, '  ') > 0 do
            Result := ReplaceStr(Result, '  ', ' ');

        exit(DelChr(Result, '<>', ' '));
    end;

    local procedure ReplaceStr(Source: Text; FindText: Text; ReplaceText: Text): Text
    var
        Pos: Integer;
    begin
        Pos := StrPos(Source, FindText);
        if Pos = 0 then
            exit(Source);
        exit(CopyStr(Source, 1, Pos - 1) + ReplaceText + CopyStr(Source, Pos + StrLen(FindText)));
    end;

    local procedure AddResourceJson(var Items: JsonArray; var Resource: Record Resource; FechaInicio: Date; FechaFin: Date; Empresa: Text[30])
    var
        Item: JsonObject;
        Available: Boolean;
        ReservedDays: Integer;
        BlockedDays: Integer;
    begin
        Available := true;
        if (FechaInicio <> 0D) and (FechaFin <> 0D) then begin
            ReservedDays := CountReservedDays(Resource."No.", FechaInicio, FechaFin, Empresa);
            BlockedDays := CountBlockedDays(Resource."No.", FechaInicio, FechaFin, Empresa);
            Available := (ReservedDays = 0) and (BlockedDays = 0);
        end;

        Item.Add('resourceNo', Resource."No.");
        Item.Add('name', Resource.Name);
        Item.Add('tipoRecurso', Resource."Tipo Recurso");
        Item.Add('zona', Resource.Zona);
        Item.Add('municipio', Resource.Municipio);
        Item.Add('medidas', Resource.Medidas);
        Item.Add('resourceGroupNo', Resource."Resource Group No.");
        Item.Add('customerPriceGroup', Resource."Customer Price Group");
        Item.Add('available', Available);
        Item.Add('reservedDays', ReservedDays);
        Item.Add('blockedDays', BlockedDays);
        Item.Add('empresa', Empresa);
        Items.Add(Item);
    end;

    local procedure AddAvailabilityJson(var Items: JsonArray; var Resource: Record Resource; FechaInicio: Date; FechaFin: Date; Empresa: Text[30])
    var
        Item: JsonObject;
        ReservedDays: Integer;
        BlockedDays: Integer;
    begin
        ReservedDays := CountReservedDays(Resource."No.", FechaInicio, FechaFin, Empresa);
        BlockedDays := CountBlockedDays(Resource."No.", FechaInicio, FechaFin, Empresa);

        Item.Add('resourceNo', Resource."No.");
        Item.Add('name', Resource.Name);
        Item.Add('fechaInicio', FormatDateIso(FechaInicio));
        Item.Add('fechaFin', FormatDateIso(FechaFin));
        Item.Add('available', (ReservedDays = 0) and (BlockedDays = 0) and (not Resource.Blocked));
        Item.Add('reservedDays', ReservedDays);
        Item.Add('blockedDays', BlockedDays);
        Item.Add('resourceBlocked', Resource.Blocked);
        case empresA OF
            'Malla Publicidad':
                Item.Add('isla', 'Mallorca');
            'Grepsa':
                Item.Add('isla', 'Mallorca');
            'Ibiza Publicidad, S.A.':
                Item.Add('isla', 'Ibiza');
            'Menorca de Publicidad, S.A.':
                Item.Add('isla', 'Menorca');
        end;
        Items.Add(Item);
    end;

    local procedure AddHistoryLineJson(var Items: JsonArray; var Job: Record Job; var JobPlanningLine: Record "Job Planning Line"; var Resource: Record Resource)
    var
        Item: JsonObject;
    begin
        Item.Add('jobNo', Job."No.");
        Item.Add('jobDescription', Job.Description);
        Item.Add('jobStartingDate', FormatDateIso(Job."Starting Date"));
        Item.Add('jobEndingDate', FormatDateIso(Job."Ending Date"));
        Item.Add('lineNo', JobPlanningLine."Line No.");
        Item.Add('resourceNo', Resource."No.");
        Item.Add('name', Resource.Name);
        Item.Add('tipoRecurso', Resource."Tipo Recurso");
        Item.Add('zona', Resource.Zona);
        Item.Add('municipio', Resource.Municipio);
        Item.Add('medidas', Resource.Medidas);
        Item.Add('resourceGroupNo', Resource."Resource Group No.");
        Item.Add('customerPriceGroup', Resource."Customer Price Group");
        Item.Add('planningDate', FormatDateIso(JobPlanningLine."Planning Date"));
        Item.Add('fechaFin', FormatDateIso(JobPlanningLine."Fecha Final"));
        Item.Add('quantity', JobPlanningLine.Quantity);
        Item.Add('unitPrice', JobPlanningLine."Unit Price");
        Items.Add(Item);
    end;

    local procedure IsResourceAvailable(ResourceNo: Code[20]; FechaInicio: Date; FechaFin: Date; Empresa: Text[30]): Boolean
    begin
        exit((CountReservedDays(ResourceNo, FechaInicio, FechaFin, Empresa) = 0) and (CountBlockedDays(ResourceNo, FechaInicio, FechaFin, Empresa) = 0));
    end;

    local procedure CountReservedDays(ResourceNo: Code[20]; FechaInicio: Date; FechaFin: Date; Empresa: Text[30]): Integer
    var
        DiarioReserva: Record "Diario Reserva";
    begin
        DiarioReserva.ChangeCompany(Empresa);
        DiarioReserva.SetCurrentKey("Nº Recurso", Fecha);
        DiarioReserva.SetRange("Nº Recurso", ResourceNo);
        DiarioReserva.SetRange(Fecha, FechaInicio, FechaFin);
        exit(DiarioReserva.Count());
    end;

    local procedure CountBlockedDays(ResourceNo: Code[20]; FechaInicio: Date; FechaFin: Date; Empresa: Text[30]): Integer
    var
        DiarioIncidencias: Record "Diario Incidencias Rescursos";
    begin
        DiarioIncidencias.ChangeCompany(Empresa);
        DiarioIncidencias.SetCurrentKey("Nº Recurso", Fecha);
        DiarioIncidencias.SetRange("Nº Recurso", ResourceNo);
        DiarioIncidencias.SetRange(Fecha, FechaInicio, FechaFin);
        DiarioIncidencias.SetRange("Incidencia de Bloqueo", DiarioIncidencias."Incidencia de Bloqueo"::Bloqueo);
        exit(DiarioIncidencias.Count());
    end;

    local procedure CalculateDuration(FechaInicio: Date; FechaFin: Date; TipoDuracion: Enum Duracion): Decimal
    var
        Days: Decimal;
    begin
        if (FechaInicio = 0D) or (FechaFin = 0D) or (FechaFin < FechaInicio) then
            exit(1);

        Days := FechaFin - FechaInicio + 1;
        case TipoDuracion of
            TipoDuracion::"Días":
                exit(Days);
            TipoDuracion::Semanas:
                exit(Round(Days / 7, 0.01));
            TipoDuracion::Catorzenas:
                exit(Round(Days / 14, 0.01));
            TipoDuracion::Quincenas:
                exit(Round(Days / 15, 0.01));
            else
                exit(Round(Days / 30.42, 0.01));
        end;
    end;

    local procedure ParseTipoDuracion(Value: Text): Enum Duracion
    var
        T: Text;
    begin
        T := UpperCase(DelChr(Value, '<>', ' '));
        case T of
            'DIA', 'DIAS', 'DÍA', 'DÍAS', 'DAYS':
                exit(Duracion::"Días");
            'SEMANA', 'SEMANAS', 'WEEK', 'WEEKS':
                exit(Duracion::Semanas);
            'CATORZENA', 'CATORZENAS', 'CATORCENA', 'CATORCENAS':
                exit(Duracion::Catorzenas);
            'QUINCENA', 'QUINCENAS':
                exit(Duracion::Quincenas);
            else
                exit(Duracion::Meses);
        end;
    end;

    local procedure ReadRequest(RequestJson: Text; var Req: JsonObject; var Resp: JsonObject): Boolean
    begin
        Clear(Req);
        Clear(Resp);
        if RequestJson = '' then begin
            Resp.Add('ok', false);
            Resp.Add('error', 'RequestJson vacio.');
            exit(false);
        end;
        if not Req.ReadFrom(RequestJson) then begin
            Resp.Add('ok', false);
            Resp.Add('error', 'JSON de entrada no valido.');
            exit(false);
        end;
        exit(true);
    end;

    local procedure ErrorResponse(MessageText: Text): Text
    var
        Resp: JsonObject;
    begin
        Resp.Add('ok', false);
        Resp.Add('error', MessageText);
        exit(JsonToText(Resp));
    end;

    local procedure GetJsonText(var Obj: JsonObject; KeyName: Text): Text
    var
        Tok: JsonToken;
    begin
        if not Obj.Get(KeyName, Tok) then
            exit('');
        exit(TokenAsText(Tok));
    end;

    local procedure TokenAsText(Tok: JsonToken): Text
    var
        Jv: JsonValue;
    begin
        if not Tok.IsValue() then
            exit('');
        Jv := Tok.AsValue();
        if Jv.IsNull() then
            exit('');
        exit(Jv.AsText());
    end;

    local procedure GetJsonBoolean(var Obj: JsonObject; KeyName: Text): Boolean
    var
        T: Text;
        B: Boolean;
    begin
        T := LowerCase(GetJsonText(Obj, KeyName));
        if T in ['1', 'true', 'yes', 'si', 'sí', 'on'] then
            exit(true);
        if Evaluate(B, T) then
            exit(B);
        exit(false);
    end;

    local procedure GetJsonInteger(var Obj: JsonObject; KeyName: Text): Integer
    var
        I: Integer;
    begin
        if Evaluate(I, GetJsonText(Obj, KeyName)) then
            exit(I);
        exit(0);
    end;

    local procedure GetJsonDecimal(var Obj: JsonObject; KeyName: Text): Decimal
    var
        D: Decimal;
        T: Text;
    begin
        T := ConvertStr(GetJsonText(Obj, KeyName), '.', ',');
        if Evaluate(D, T) then
            exit(D);
        exit(0);
    end;

    local procedure GetJsonDate(var Obj: JsonObject; KeyName: Text): Date
    begin
        exit(ParseIsoDate(GetJsonText(Obj, KeyName)));
    end;

    local procedure ParseIsoDate(DateText: Text): Date
    var
        Y: Integer;
        M: Integer;
        D: Integer;
    begin
        DateText := DelChr(DateText, '<>', ' ');
        if DateText = '' then
            exit(0D);
        if StrLen(DateText) = 10 then
            if (CopyStr(DateText, 5, 1) = '-') and (CopyStr(DateText, 8, 1) = '-') then begin
                Evaluate(Y, CopyStr(DateText, 1, 4));
                Evaluate(M, CopyStr(DateText, 6, 2));
                Evaluate(D, CopyStr(DateText, 9, 2));
                exit(DMY2DATE(D, M, Y));
            end;
        if Evaluate(ResultDate, DateText) then
            exit(ResultDate);
        exit(0D);
    end;

    local procedure FormatDateIso(Value: Date): Text
    begin
        if Value = 0D then
            exit('');
        exit(StrSubstNo('%1-%2-%3',
            PadLeft(Format(Date2DMY(Value, 3)), 4, '0'),
            PadLeft(Format(Date2DMY(Value, 2)), 2, '0'),
            PadLeft(Format(Date2DMY(Value, 1)), 2, '0')));
    end;

    local procedure FirstNonZeroDate(Value1: Date; Value2: Date): Date
    begin
        if Value1 <> 0D then
            exit(Value1);
        exit(Value2);
    end;

    local procedure PadLeft(Value: Text; Length: Integer; PadChar: Text[1]): Text
    begin
        while StrLen(Value) < Length do
            Value := PadChar + Value;
        exit(Value);
    end;

    local procedure JsonToText(var Obj: JsonObject): Text
    var
        OutText: Text;
    begin
        Obj.WriteTo(OutText);
        exit(OutText);
    end;

    var
        ResultDate: Date;
}
