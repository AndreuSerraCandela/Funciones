
/// <summary>
/// Codeunit Restapi (ID 50018).
/// </summary>
codeunit 50018 "Restapi"
{
    var
        Client: HttpClient;
        RequestHeaders: HttpHeaders;
        RequestContent: HttpContent;
        ResponseMessage: HttpResponseMessage;
        RequestMessage: HttpRequestMessage;
        ResponseText: Text;
        contentHeaders: HttpHeaders;
        MEDIA_TYPE: Label 'application/json';

    trigger OnRun()
    begin


    end;

    /// <summary>
    /// RestApi.
    /// </summary>
    /// <param name="url">Text.</param>
    /// <param name="RequestType">Option Get,patch,put,post,delete.</param>
    /// <param name="payload">Text.</param>
    /// <returns>Return value of type Text.</returns>
    procedure RestApiImagenes(url: Text; RequestType: Option Get,patch,put,post,delete; payload: Text): Text
    var
        Ok: Boolean;
        Respuesta: Text;
    begin
        RequestHeaders := Client.DefaultRequestHeaders();
        //RequestHeaders.Add('Authorization', CreateBasicAuthHeader(Username, Password));

        case RequestType of
            RequestType::Get:
                Client.Get(URL, ResponseMessage);
            RequestType::patch:
                begin
                    RequestContent.WriteFrom(payload);

                    RequestContent.GetHeaders(contentHeaders);
                    contentHeaders.Clear();
                    contentHeaders.Add('Content-Type', 'application/json-patch+json');

                    RequestMessage.Content := RequestContent;

                    RequestMessage.SetRequestUri(URL);
                    RequestMessage.Method := 'PATCH';

                    client.Send(RequestMessage, ResponseMessage);
                end;
            RequestType::post:
                begin
                    RequestContent.WriteFrom(payload);

                    RequestContent.GetHeaders(contentHeaders);
                    contentHeaders.Clear();
                    contentHeaders.Add('Content-Type', 'application/json');

                    Client.Post(URL, RequestContent, ResponseMessage);
                end;
            RequestType::delete:
                begin


                    Client.Delete(URL, ResponseMessage);
                end;
        end;

        ResponseMessage.Content().ReadAs(ResponseText);
        exit(ResponseText);

    end;


    /// <summary>
    /// RestApi.
    /// </summary>
    /// <param name="url">Text.</param>
    /// <param name="RequestType">Option Get,patch,put,post,delete.</param>
    /// <param name="payload">Text.</param>
    /// <returns>Return value of type Text.</returns>

    procedure RestApi(url: Text; RequestType: Option Get,patch,put,post,delete; payload: Text; User: Text; Pass: Text): Text
    var
        Ok: Boolean;
        Respuesta: Text;
        Base64Convert: Codeunit "Base64 Convert";
    begin
        RequestHeaders := Client.DefaultRequestHeaders();
        //RequestHeaders.Add('Authorization', 'Basic cGk6SWI2MzQzZHMu');
        RequestHeaders.Add('Authorization', 'Basic ' + Base64Convert.ToBase64(User + ':' + Pass));
        //CreateBasicAuthHeader(User, Pass, RequestHeaders); 


        case RequestType of
            RequestType::Get:
                If Not Client.Get(URL, ResponseMessage) Then
                    exit('Retry');

            RequestType::patch:
                begin
                    RequestContent.WriteFrom(payload);

                    RequestContent.GetHeaders(contentHeaders);
                    contentHeaders.Clear();
                    contentHeaders.Add('Content-Type', 'application/json-patch+json');

                    RequestMessage.Content := RequestContent;

                    RequestMessage.SetRequestUri(URL);
                    RequestMessage.Method := 'PATCH';

                    if not client.Send(RequestMessage, ResponseMessage) then exit('Retry');
                end;
            RequestType::post:
                begin
                    RequestContent.WriteFrom(payload);

                    RequestContent.GetHeaders(contentHeaders);
                    contentHeaders.Clear();
                    contentHeaders.Add('Content-Type', 'application/json');

                    if not Client.Post(URL, RequestContent, ResponseMessage) then exit('Retry');
                end;
            RequestType::delete:
                If not Client.Delete(URL, ResponseMessage) then
                    exit('Retry');
        end;

        ResponseMessage.Content().ReadAs(ResponseText);
        exit(ResponseText);

    end;



    /// <summary>
    /// RestApi.
    /// </summary>
    /// <param name="url">Text.</param>
    /// <param name="RequestType">Option Get,patch,put,post,delete.</param>
    /// <param name="payload">Text.</param>
    /// <returns>Return value of type Text.</returns>
    procedure RestApi(url: Text; RequestType: Option Get,patch,put,post,delete; payload: Text): Text
    var
        Ok: Boolean;
        Respuesta: Text;
    begin
        RequestHeaders := Client.DefaultRequestHeaders();
        //RequestHeaders.Add('Authorization', CreateBasicAuthHeader(Username, Password));

        case RequestType of
            RequestType::Get:
                Client.Get(URL, ResponseMessage);
            RequestType::patch:
                begin
                    RequestContent.WriteFrom(payload);

                    RequestContent.GetHeaders(contentHeaders);
                    contentHeaders.Clear();
                    contentHeaders.Add('Content-Type', 'application/json-patch+json');

                    RequestMessage.Content := RequestContent;

                    RequestMessage.SetRequestUri(URL);
                    RequestMessage.Method := 'PATCH';

                    client.Send(RequestMessage, ResponseMessage);
                end;
            RequestType::post:
                begin
                    RequestContent.WriteFrom(payload);

                    RequestContent.GetHeaders(contentHeaders);
                    contentHeaders.Clear();
                    contentHeaders.Add('Content-Type', 'application/json');

                    Client.Post(URL, RequestContent, ResponseMessage);
                end;
            RequestType::delete:
                Client.Delete(URL, ResponseMessage);
        end;

        ResponseMessage.Content().ReadAs(ResponseText);
        exit(ResponseText);

    end;

    /// <summary>
    /// RestApiToken.
    /// </summary>
    /// <param name="url">Text.</param>
    /// <param name="Token">Text.</param>
    /// <param name="RequestType">Option Get,patch,put,post,delete.</param>
    /// <param name="payload">Text.</param>
    /// <returns>Return value of type Text.</returns>
    procedure RestApiToken(url: Text; Token: Text; RequestType: Option Get,patch,put,post,delete; payload: Text): Text
    var
        Ok: Boolean;
        Respuesta: Text;

        GlSetup: Record "General Ledger Setup";
    begin
        GlSetup.Get();
        //url := GlSetup."Url" + url;
        if Token = '' Then
            RecuperarToken('', '', '', Token);
        RequestHeaders := Client.DefaultRequestHeaders();
        RequestHeaders.Add('Authorization', StrSubstNo('Bearer %1', token));

        case RequestType of
            RequestType::Get:
                Client.Get(URL, ResponseMessage);
            RequestType::patch:
                begin
                    RequestContent.WriteFrom(payload);

                    RequestContent.GetHeaders(contentHeaders);
                    contentHeaders.Clear();
                    contentHeaders.Add('Content-Type', 'application/json-patch+json');

                    RequestMessage.Content := RequestContent;

                    RequestMessage.SetRequestUri(URL);
                    RequestMessage.Method := 'PATCH';

                    client.Send(RequestMessage, ResponseMessage);
                end;
            RequestType::post:
                begin
                    RequestContent.WriteFrom(payload);

                    RequestContent.GetHeaders(contentHeaders);
                    contentHeaders.Clear();
                    contentHeaders.Add('Content-Type', 'application/json');

                    Client.Post(URL, RequestContent, ResponseMessage);
                end;
            RequestType::put:
                begin
                    RequestContent.WriteFrom(payload);

                    RequestContent.GetHeaders(contentHeaders);
                    contentHeaders.Clear();
                    contentHeaders.Add('Content-Type', 'application/json');

                    Client.Put(URL, RequestContent, ResponseMessage);
                end;
            RequestType::delete:
                Client.Delete(URL, ResponseMessage);
        end;

        ResponseMessage.Content().ReadAs(ResponseText);
        exit(ResponseText);

    end;

    /// <summary>
    /// RestApiXToken.
    /// </summary>
    /// <param name="url">Text.</param>
    /// <param name="Token">Text.</param>
    /// <param name="RequestType">Option Get,patch,put,post,delete.</param>
    /// <param name="payload">Text.</param>
    /// <returns>Return value of type Text.</returns>
    procedure RestApiXToken(url: Text; Token: Text; RequestType: Option Get,patch,put,post,delete; payload: Text): Text
    var
        Ok: Boolean;
        Respuesta: Text;

        GlSetup: Record "General Ledger Setup";
    begin
        GlSetup.Get();
        //url := GlSetup."Url" + url;
        RequestHeaders := Client.DefaultRequestHeaders();


        case RequestType of
            RequestType::Get:
                begin

                    Client.Get(URL, ResponseMessage);
                end;
            RequestType::patch:
                begin
                    RequestContent.WriteFrom(payload);

                    RequestContent.GetHeaders(contentHeaders);
                    contentHeaders.Clear();
                    contentHeaders.Add('Content-Type', 'application/json-patch+json');
                    contentHeaders.Add('X-Token', Token);

                    RequestMessage.Content := RequestContent;

                    RequestMessage.SetRequestUri(URL);
                    RequestMessage.Method := 'PATCH';

                    client.Send(RequestMessage, ResponseMessage);
                end;
            RequestType::post:
                begin
                    RequestContent.WriteFrom(payload);

                    RequestContent.GetHeaders(contentHeaders);
                    contentHeaders.Clear();
                    contentHeaders.Add('Content-Type', 'application/json');
                    contentHeaders.Add('X-Token', Token);

                    Client.Post(URL, RequestContent, ResponseMessage);
                end;
            RequestType::put:
                begin
                    RequestContent.WriteFrom(payload);

                    RequestContent.GetHeaders(contentHeaders);
                    contentHeaders.Clear();
                    contentHeaders.Add('Content-Type', 'application/json');
                    contentHeaders.Add('X-Token', Token);

                    Client.Put(URL, RequestContent, ResponseMessage);
                end;
            RequestType::delete:
                Client.Delete(URL, ResponseMessage);
        end;

        ResponseMessage.Content().ReadAs(ResponseText);
        exit(ResponseText);

    end;

    /// <summary>
    /// RecuperarToken.
    /// </summary>
    /// <param name="Url">Text.</param>
    /// <param name="Usuario">Text.</param>
    /// <param name="password">Text.</param>
    /// <param name="Token">VAR Text.</param>
    procedure RecuperarToken(Url: Text; Usuario: Text; password: Text; var Token: Text);
    var
        Pregunta: Text;
        JSONMgt: Codeunit "JSON Management";
        JsonObjt: Codeunit "Json Text Reader/Writer";
        Name: Text;
        Value1: Text;
        i: Integer;
        RequestType: Option Get,patch,put,post,delete;
        GeneralLedgerSetup: Record "General Ledger Setup";
        Dur: Duration;
        FechaToken: DateTime;
        Dura: Integer;
        bigInt: BigInteger;
    begin
        GeneralLedgerSetup.Get();
        // if GeneralLedgerSetup."Fecha Token" <> 0DT Then begin
        //     Dur := (CurrentDateTime - GeneralLedgerSetup."Fecha Token");
        //     bigInt := Dur;
        //     Dura := bigInt DIV (60 * 60 * 1000);
        //     if Dura < 48 then begin
        //         Token := GeneralLedgerSetup.Token;
        //         FechaToken := GeneralLedgerSetup."Fecha Token";
        //         exit;
        //     end
        // end;
        // if Url = '' Then
        //     Url := GeneralLedgerSetup.URL;
        // if Url = '' Then url := 'http://ocr-api.deploy.kuarasoftware.es/';
        Url := Url + 'Authenticate';
        //Url := Url + '/user/login';
        // if Usuario = '' Then Usuario := GeneralLedgerSetup."Usuario Ocr";
        // if password = '' then password := GeneralLedgerSetup."Password";
        // if Usuario = '' then Usuario := 'Andreu';
        // if password = '' then password := '12345';
        Pregunta += '{"username":"' + Usuario + '","password":"' + password + '"}';
        RequestContent.WriteFrom(Pregunta);

        RequestContent.GetHeaders(contentHeaders);
        contentHeaders.Clear();
        contentHeaders.Add('Content-Type', 'application/json');

        Client.Post(URL, RequestContent, ResponseMessage);
        ResponseMessage.Content().ReadAs(Token);
        JSONMgt.InitializeObject(Token);
        JSONMgt.ReadProperties();
        WHILE JSONMgt.GetNextProperty(Name, Value1) DO BEGIN

            CASE Name OF
                'access_token':
                    BEGIN
                        Token := Value1;
                    end;
            end;
        end;
        FechaToken := CurrentDateTime;
        // GeneralLedgerSetup.Token := Token;
        // GeneralLedgerSetup."Fecha Token" := FechaToken;
        // GeneralLedgerSetup.Modify();

    end;
    /// <summary>
    /// RestApiToken.
    /// </summary>
    /// <param name="url">Text.</param>
    /// <param name="RequestType">Option Get,patch,put,post,delete.</param>
    /// <param name="payload">Text.</param>
    /// <returns>Return value of type Text.</returns>
    procedure RestApiToken(url: Text; RequestType: Option Get,patch,put,post,delete; payload: Text): Text
    var
        Ok: Boolean;
        Respuesta: Text;
        Token: Text;
        GlSetup: Record "General Ledger Setup";
    begin
        RecuperarToken('', '', '', Token);
        RequestHeaders := Client.DefaultRequestHeaders();
        RequestHeaders.Add('Authorization', StrSubstNo('Bearer %1', token));

        case RequestType of
            RequestType::Get:
                Client.Get(URL, ResponseMessage);
            RequestType::patch:
                begin
                    RequestContent.WriteFrom(payload);

                    RequestContent.GetHeaders(contentHeaders);
                    contentHeaders.Clear();
                    contentHeaders.Add('Content-Type', 'application/json-patch+json');

                    RequestMessage.Content := RequestContent;

                    RequestMessage.SetRequestUri(URL);
                    RequestMessage.Method := 'PATCH';

                    client.Send(RequestMessage, ResponseMessage);
                end;
            RequestType::post:
                begin
                    RequestContent.WriteFrom(payload);

                    RequestContent.GetHeaders(contentHeaders);
                    contentHeaders.Clear();
                    contentHeaders.Add('Content-Type', 'application/json');

                    Client.Post(URL, RequestContent, ResponseMessage);
                end;
            RequestType::delete:
                Client.Delete(URL, ResponseMessage);
        end;

        ResponseMessage.Content().ReadAs(ResponseText);
        exit(ResponseText);

    end;


    /// <summary>
    /// RecuperarTokenGoTime.
    /// </summary>
    /// <param name="Url">Text.</param>
    /// <param name="Usuario">Text.</param>
    /// <param name="password">Text.</param>
    /// <param name="Empresa">Text.</param>
    /// <param name="Token">VAR Text.</param>
    procedure RecuperarTokenGoTime(Url: Text; Usuario: Text; password: Text; Empresa: Text; var Token: Text);
    var
        Pregunta: Text;
        JSONMgt: Codeunit "JSON Management";
        JSONMgt2: Codeunit "JSON Management";
        JsonObjt: Codeunit "Json Text Reader/Writer";
        Name: Text;
        Name2: Text;
        JsonText: Text;
        Value1: Text;
        Value2: Text;
        i: Integer;
        RequestType: Option Get,patch,put,post,delete;
        GeneralLedgerSetup: Record "General Ledger Setup";
        Dur: Duration;
        FechaToken: DateTime;
        Dura: Integer;
        bigInt: BigInteger;
        JsonObj: JsonObject;
        JdataObj: JsonObject;
        JdataToken: JsonToken;
        JTokenToken: JsonToken;
    begin

        Url := Url + 'login';
        Pregunta += '{"company":"' + Empresa + '","username":"' + Usuario + '","password":"' + password + '"}';
        RequestContent.WriteFrom(Pregunta);

        RequestContent.GetHeaders(contentHeaders);
        contentHeaders.Clear();
        contentHeaders.Add('Content-Type', 'application/json');

        Client.Post(URL, RequestContent, ResponseMessage);
        ResponseMessage.Content().ReadAs(JsonText);
        if JsonObj.ReadFrom(JsonText) Then begin
            if JsonObj.Get('data', JdataToken) Then begin
                if JdataToken.IsObject Then begin
                    JdataObj := JdataToken.AsObject();
                    if JdataObj.Get('token', JTokenToken) Then Token := JTokenToken.AsValue().AsText();
                end;
            end;
        end;

    end;

    local procedure CreateBasicAuthHeader(UserName: Text[50]; Password: Text[50]; var Requestheader: Httpheaders);
    var
        AuthString: Text;
        TempBlob: Codeunit "Base64 Convert";
    begin
        AuthString := STRSUBSTNO('%1:%2', UserName, Password);
        //TempBlob.WriteTextLine(AuthString);
        AuthString := TempBlob.ToBase64(AuthString);
        AuthString := STRSUBSTNO('Basic %1', AuthString);
        Requestheader.Add('Authorization', AuthString);
    end;


}
