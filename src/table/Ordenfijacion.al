tableextension 75007 OrdenfijacionKuara extends "Imagenes Orden fijación"
{
    procedure FormBase64ToUrl(Base64: text; Filename: Text; var Id: Integer) ReturnValue: Text
    VAR
        Outstr: OutStream;
        GeneralLedgerSetup: Record "General Ledger Setup";
        Token: Text;
        RestApiC: Codeunit Restapi;
        JsonObj: JsonObject;
        UrlToken: JsonToken;
        RequestType: Option Get,patch,put,post,delete;
        FileMgt: Codeunit "File Management";
        Json: Text;
        IdToken: JsonToken;
        Ok: Boolean;
    begin
        GeneralLedgerSetup.Get();
        case FileMgt.GetExtension(Filename) of
            'jpg', 'png', 'bmp', 'tif':
                Base64 := 'image/' + FileMgt.GetExtension(Filename) + ';base64,' + Base64;
            else
                Base64 := 'application/' + FileMgt.GetExtension(Filename) + ';base64,' + Base64;
        end;

        Repeat

            JsonObj.add('base64', base64);
            jsonobj.add('filename', filename);
            JsonObj.WriteTo(Json);
            Json := RestApiC.RestApiImagenes('https://base64-api.deploy.malla.es/' + 'save', RequestType::Post, Json);
            Clear(JsonObj);
            //Request failed with status code 400
            if Json = 'Request failed with status code 400' then
                Error('Error al guardar el archivo');
            Ok := JsonObj.ReadFrom(Json);
            if not Ok then
                sleep(5000);
        Until Ok;
        JsonObj.Get('url', UrlToken);
        JsonObj.Get('_id', IdToken);
        ReturnValue := UrlToken.AsValue().AsText;
        Id := IdToken.AsValue().AsInteger;
        exit(ReturnValue);
    end;
    /// <summary>
    /// ToBase64StringOcr.
    /// </summary>
    /// <param name="bUrl">Text.</param>
    /// <returns>Return value of type Text.</returns>
    procedure ToBase64StringOcr(bUrl: Text): Text
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
        JsonObj: JsonObject;
        Json: Text;
        RestapiC: Codeunit RestApi;
        RequestType: Option Get,patch,put,post,delete;
        base64Token: JsonToken;
        base64: Text;
    begin
        GeneralLedgerSetup.Get();
        JsonObj.add('url', bUrl);
        JsonObj.WriteTo(Json);
        Json := RestApiC.RestApiImagenes('https://base64-api.deploy.malla.es/' + 'fetch', RequestType::Post, Json);

        // Verificar si la respuesta es HTML (error 502, 404, etc.)
        if (StrPos(Json, '<!doctype html>') > 0) or
           (StrPos(Json, '<html>') > 0) or
           (StrPos(Json, 'NGINX 502 Error') > 0) or
           (StrPos(Json, 'Error') > 0) then begin
            exit(''); // Devolver cadena vacía si es una página de error
        end;

        // Verificar si la respuesta es JSON válido
        if not JsonObj.ReadFrom(Json) then begin
            // Si no es JSON válido, intentar extraer base64 directamente
            if (StrLen(Json) > 2) and (Json[1] = '"') and (Json[StrLen(Json)] = '"') then
                base64 := CopyStr(Json, 2, StrLen(Json) - 2)
            else
                base64 := Json;
        end else begin
            // Si es JSON válido, intentar obtener el campo base64
            if JsonObj.Get('base64', base64Token) then
                base64 := base64Token.AsValue().AsText()
            else
                base64 := CopyStr(Json, 2, StrLen(Json) - 2);
        end;

        exit(base64);
    end;

    /// <summary>
    /// DeleteId.
    /// </summary>
    /// <param name="Id">Integer.</param>
    /// <returns>Return value of type Text.</returns>
    procedure DeleteId(Id: Integer): Text
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
        JsonObj: JsonObject;
        Json: Text;
        RestapiC: Codeunit RestApi;
        RequestType: Option Get,patch,put,post,delete;
        base64Token: JsonToken;
        base64: Text;
    begin
        GeneralLedgerSetup.Get();
        Json := RestApiC.RestApiImagenes('https://base64-api.deploy.malla.es/' + 'delete/' + Format(Id), RequestType::delete, '');
        //Clear(JsonObj);
        //JsonObj.ReadFrom(Json);
        //JsonObj.Get('base64', base64Token);
        exit(Json);

    end;

    procedure Export(ShowFileDialog: Boolean) Result: Text
    var
        TempBlob: Codeunit "Temp Blob";
        FileManagement: Codeunit "File Management";
        DocumentStream: OutStream;
        FullFileName: Text;
        IsHandled: Boolean;
        Base64Convert: Codeunit "Base64 Convert";
        Ins: Instream;

    begin
        If Rec.Url <> '' Then begin
            TempBlob.CreateOutStream(DocumentStream);
            Base64Convert.FromBase64(ToBase64StringOcr(Url), DocumentStream);
            TempBlob.CreateInStream(Ins);
            Image.ImportStream(Ins, Nombre + '.' + "Extension");
        end;
        exit(Result);
    end;

    procedure SaveAttachment(RecRef: RecordRef; FileName: Text; TempBlob: Codeunit "Temp Blob")
    begin
        SaveAttachment(RecRef, FileName, TempBlob, true);
    end;

    procedure InsertAttachment(DocStream: InStream; RecRef: RecordRef; FileName: Text; AllowDuplicateFileName: Boolean)
    var
        IsHandled: Boolean;
        Base64Convert: Codeunit "Base64 Convert";
        Base64: Text;
    begin

        IncomingFileName := FileName;

        Validate(Extension, FileManagement.GetExtension(IncomingFileName));
        Validate("Nombre", CopyStr(FileManagement.GetFileNameWithoutExtension(IncomingFileName), 1, MaxStrLen("Nombre")));



        Base64 := Base64Convert.ToBase64(DocStream);
        Url := FormBase64ToUrl(Base64, Filename, "Nº Imagen");
        Id := "Nº Imagen";
        Insert(true);
    end;

    procedure InsertAttachment(DocStream: InStream; FileName: Text; AllowDuplicateFileName: Boolean)
    var
        IsHandled: Boolean;
        Base64Convert: Codeunit "Base64 Convert";
        Base64: Text;
    begin

        IncomingFileName := FileName;

        Validate(Extension, FileManagement.GetExtension(IncomingFileName));
        Validate("Nombre", CopyStr(FileManagement.GetFileNameWithoutExtension(IncomingFileName), 1, MaxStrLen("Nombre")));



        Base64 := Base64Convert.ToBase64(DocStream);
        Url := FormBase64ToUrl(Base64, Filename, "Nº Imagen");
        Id := "Nº Imagen";
        Insert(true);
    end;

    procedure SaveAttachment(RecRef: RecordRef; FileName: Text; TempBlob: Codeunit "Temp Blob"; AllowDuplicateFileName: Boolean)
    var
        DocStream: InStream;
    begin

        if FileName = '' then
            Error(EmptyFileNameErr);
        // Validate file/media is not empty
        if not TempBlob.HasValue() then
            Error(NoContentErr);

        TempBlob.CreateInStream(DocStream);
        InsertAttachment(DocStream, RecRef, FileName, AllowDuplicateFileName);
    end;

    procedure SaveAttachmentFromStream(DocStream: InStream; RecRef: RecordRef; FileName: Text; AllowDuplicateFileName: Boolean)
    begin

        if FileName = '' then
            Error(EmptyFileNameErr);

        InsertAttachment(DocStream, RecRef, FileName, AllowDuplicateFileName);
    end;

    procedure SaveAttachmentFromStream(DocStream: InStream; RecRef: RecordRef; FileName: Text)
    begin
        SaveAttachmentFromStream(DocStream, RecRef, FileName, true);
    end;

    var
        FileManagement: Codeunit "File Management";
        IncomingFileName: Text;
        NoDocumentAttachedErr: Label 'Please attach a document first.';
        EmptyFileNameErr: Label 'Please choose a file to attach.';
        NoContentErr: Label 'The selected file has no content. Please choose another file.';
        DuplicateErr: Label 'This file is already attached to the document. Please choose another file.';
}