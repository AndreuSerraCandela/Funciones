
/// <summary>
/// Codeunit HttpKuara (ID 50017).
/// </summary>
codeunit 50017 "HttpKuara"
{

    /// <summary>
    /// MarcarDocumento.
    /// </summary>
    /// <param name="Doc">Text.</param>
    /// <param name="Valor">Boolean.</param>
    /// <returns>Return value of type Text.</returns>
    procedure MarcarDocumento(Doc: Text; Valor: Boolean): Text
    var
        Ficheros: Record Ficheros;
        actioncontenxt: WebServiceActionContext;
        SalesInvHeader: Record "Sales Invoice Header";
        PurchInvHeader: Record "Purch. Inv. Header";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        PurchCrMemoHeader: Record "Purch. Cr. Memo Hdr.";
        a: Integer;
    begin
        if Not Evaluate(a, Doc) Then exit(StrSubstNo('%1 no es un número válido', Doc));
        if Ficheros.Get(a) Then begin
            Ficheros.Procesado := Valor;
            if Ficheros.Procesado then begin
                If ficheros.proceso = 'SII' then begin
                    if SalesInvHeader.Get(Doc) then begin
                        SalesInvHeader.Estado := 'Procesado';
                        SalesInvHeader.Modify();
                    end;
                    if PurchInvHeader.Get(Doc) then begin
                        PurchInvHeader.Estado := 'Procesado';
                        PurchInvHeader.Modify();
                    end;
                    if SalesCrMemoHeader.Get(Doc) then begin
                        SalesCrMemoHeader.Estado := 'Procesado';
                        SalesCrMemoHeader.Modify();
                    end;
                    if PurchCrMemoHeader.Get(Doc) then begin
                        PurchCrMemoHeader.Estado := 'Procesado';
                        PurchCrMemoHeader.Modify();
                    end;
                end;
            end;
            Ficheros.Modify();
        end else
            exit(StrSubstNo('Nº doc %1, no encontrado', a));
        exit(StrSubstNo('Doc %1 se ha cambiado a procesado %2', a, valor));
    end;
    /// <summary>
    /// EnviarSii.
    /// </summary>
    /// <returns>Return variable Json of type Text.</returns>
    procedure EnviarSii() Json: Text
    var
        JsonObj: Codeunit "Json Text Reader/Writer";
        JsonText: Text;
        Recref: RecordRef;
        idReport: Integer;
        Ficheros: Record Ficheros;
        Ficheros2: Record Ficheros;
        TxtINStream: InStream;
        Base64Codeunit: Codeunit "Base64 Convert";
        Base64: Text;
    begin
        //ShipmentHeader.SetRange("No. Printed", 0);
        JsonObj.WriteStartArray('');
        Ficheros.SetRange(Procesado, false);
        Ficheros.SetFilter(Proceso, '%1|%2', 'SII', 'Face');
        Ficheros.CalcFields(Fichero);
        if Ficheros.FindSet() then
            repeat
                Ficheros2.SetRange(Secuencia, Ficheros."Secuencia");
                Ficheros2.FindFirst();
                Recref.GetTable(Ficheros2);
                JsonObj.WriteStartObject('');
                JsonObj.WriteStringProperty('Id', Ficheros2.Secuencia);
                JsonObj.WriteStringProperty('Nombre', Ficheros2."Nombre fichero");
                Ficheros.CalcFields(Fichero);
                Ficheros.Fichero.CreateInStream(TxtINStream);
                Base64 := Base64Codeunit.ToBase64(TxtINStream);
                JsonObj.WriteStringProperty('TXT', Base64);
                JsonObj.WriteEndObject();
            until Ficheros.Next() = 0;
        JsonObj.WriteEndArray();
        Json := JsonObj.GetJSonAsText();
        exit(Json);
    end;

    /// <summary>
    /// MarcarDocumentoEnviado.
    /// </summary>
    /// <param name="Doc">Text.</param>
    /// <param name="Valor">Boolean.</param>
    /// <returns>Return value of type Text.</returns>
    procedure MarcarDocumentoEnviado(Doc: Text; Valor: Boolean): Text
    var
        Ficheros: Record Ficheros;
        actioncontenxt: WebServiceActionContext;
        SalesInvHeader: Record "Sales Invoice Header";
        PurchInvHeader: Record "Purch. Inv. Header";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        PurchCrMemoHeader: Record "Purch. Cr. Memo Hdr.";
        a: Integer;
    begin
        if Not Evaluate(a, Doc) Then exit(StrSubstNo('%1 no es un número válido', Doc));
        if Ficheros.Get(a) Then begin
            Ficheros.Enviado := Valor;
            if Ficheros.Procesado then begin
                If ficheros.proceso = 'SII' then begin
                    if SalesInvHeader.Get(Doc) then begin
                        SalesInvHeader.Estado := 'Enviado';
                        SalesInvHeader.Modify();
                    end;
                    if PurchInvHeader.Get(Doc) then begin
                        PurchInvHeader.Estado := 'Enviado';
                        PurchInvHeader.Modify();
                    end;
                    if SalesCrMemoHeader.Get(Doc) then begin
                        SalesCrMemoHeader.Estado := 'Enviado';
                        SalesCrMemoHeader.Modify();
                    end;
                    if PurchCrMemoHeader.Get(Doc) then begin
                        PurchCrMemoHeader.Estado := 'Enviado';
                        PurchCrMemoHeader.Modify();
                    end;
                end;
            end;
            Ficheros.Modify();
        end else
            exit(StrSubstNo('Nº doc %1, no encontrado', a));
        exit(StrSubstNo('Doc %1 se ha cambiado a enviado %2', a, valor));
    end;

    procedure EnviarProcesadosSii() Json: Text
    var
        JsonObj: Codeunit "Json Text Reader/Writer";
        JsonText: Text;
        Recref: RecordRef;
        idReport: Integer;
        Ficheros: Record Ficheros;
        Ficheros2: Record Ficheros;
        TxtINStream: InStream;
        Base64Codeunit: Codeunit "Base64 Convert";
        Base64: Text;
    begin
        //ShipmentHeader.SetRange("No. Printed", 0);
        JsonObj.WriteStartArray('');
        Ficheros.SetRange(Procesado, true);
        Ficheros.SetRange(Enviado, false);
        Ficheros.SetRange(Proceso, 'SII');
        Ficheros.CalcFields(Fichero);
        if Ficheros.FindSet() then
            repeat
                Ficheros2.SetRange(Secuencia, Ficheros."Secuencia");
                Ficheros2.FindFirst();
                Recref.GetTable(Ficheros2);
                JsonObj.WriteStartObject('');
                JsonObj.WriteStringProperty('Id', Ficheros2.Secuencia);
                JsonObj.WriteStringProperty('Nombre', GetSiiSendedFilePath(Ficheros2."Nombre fichero"));
                JsonObj.WriteEndObject();
            until Ficheros.Next() = 0;
        JsonObj.WriteEndArray();
        Json := JsonObj.GetJSonAsText();
        exit(Json);
    end;


    local procedure GetSiiSendedFilePath(OriginalPath: Text): Text
    var
        PathUpper: Text;
        OutFolderPos: Integer;
        OutFolderToken: Text;
        FileNamePart: Text;
        PathPrefix: Text;
    begin
        if OriginalPath = '' then
            exit('');

        OutFolderToken := '\OUT\';
        PathUpper := UpperCase(OriginalPath);
        OutFolderPos := StrPos(PathUpper, OutFolderToken);
        if OutFolderPos = 0 then
            exit(OriginalPath);

        PathPrefix := CopyStr(OriginalPath, 1, OutFolderPos + StrLen(OutFolderToken) - 1);
        FileNamePart := CopyStr(OriginalPath, OutFolderPos + StrLen(OutFolderToken));
        exit(PathPrefix + 'sended\' + FileNamePart);
    end;

    /// <summary>
    /// GuardaPdfContrato.
    /// </summary>
    /// <param name="Contrato">Code[20].</param>
    /// <returns>Return value of type Text.</returns>
    procedure GuardaPdfContrato(Contrato: Code[20]): Text
    Var
        SalesHeader: Record "Sales Header";
        ServerAttachmentFilePath: Text;
        IncomingDocument: Record "Incoming Document";
        TempBlob: Codeunit "Temp Blob";
        TempBlob2: Codeunit "Base64 Convert";
        OutStr: OutStream;
        IsStr: InStream;
        Recref: RecordRef;
        Base64EncodedString: Text;
        Base64EncodedString2: Text;

        TM: Record "Tenant Media";
    Begin
        SalesHeader.SETRANGE("Document Type", SalesHeader."Document Type"::Order);
        SalesHeader.SETRANGE("No.", Contrato);
        SalesHeader.FINDFIRST;
        RecRef.GetTable(SalesHeader);
        TM.Init();
        TM.ID := CreateGuid();
        TM.Description := StrSubstNo('Signature%1', format(CurrentDateTime));
        TM."Mime Type" := 'Pdf/pdf';
        TM."Company Name" := COMPANYNAME;
        TM."File Name" := TM.Description + '.pdf';
        TM.Height := 250;
        TM.Width := 250;
        TM.CalcFields(Content);
        TM.Content.CreateOutStream(Outstr);
        REPORT.SaveAs(Report::Contrato, '', ReportFormat::Pdf, OutStr, Recref);
        TM.Insert;
        TM.CalcFields(Content);
        Tm.Content.CreateInStream(IsStr);
        Base64EncodedString := TempBlob2.ToBase64(IsStr);
        TM.Delete;
        TM.Init();
        TM.ID := CreateGuid();
        TM.Description := StrSubstNo('Signature%1', format(CurrentDateTime));
        TM."Mime Type" := 'Pdf/pdf';
        TM."Company Name" := COMPANYNAME;
        TM."File Name" := TM.Description + '.pdf';
        TM.Height := 250;
        TM.Width := 250;
        TM.CalcFields(Content);
        TM.Content.CreateOutStream(Outstr);
        if SalesHeader."Contrato Aeropuerto" then
            REPORT.SaveAs(50050, '', ReportFormat::Pdf, OutStr, Recref)
        else
            REPORT.SaveAs(50053, '', ReportFormat::Pdf, OutStr, Recref);
        TM.Insert;
        TM.CalcFields(Content);
        Tm.Content.CreateInStream(IsStr);
        Base64EncodedString2 := TempBlob2.ToBase64(IsStr);
        TM.Delete;
        Base64EncodedString := PostDocumentos(Base64EncodedString, Base64EncodedString2);
        exit(Base64EncodedString);


    end;

    /// <summary>
    /// PostDocumentos.
    /// </summary>
    /// <param name="base1">Text.</param>
    /// <param name="base2">Text.</param>
    /// <returns>Return value of type Text.</returns>
    procedure PostDocumentos(base1: Text; base2: Text): Text
    Var
        ResApi: Codeunit Restapi;
        Inf: Record "Company Information";
        RequestType: Option Get,patch,put,post,delete;
        Parametros: Text;
        SalesSetup: Record "Sales & Receivables Setup";
        UrlPdf: Text;
        JsonObj: JsonObject;
        JsonTexT: Text;
        ResPuestaJson: JsonObject;
        PdfToken: JsonToken;
    begin
        SalesSetup.Get();
        UrlPdf := SalesSetup."Url Pdf";
        jsonobj.Add('pdf1', Base1);
        jsonobj.Add('pdf2', base2);
        jsonobj.WriteTo(JsonTexT);
        ResPuestaJson.ReadFrom(ResApi.RestApi(UrlPdf, RequestType::post, jSonText));
        //Obtener el valor de la key pdf
        if ResPuestaJson.Get('pdf', PdfToken) then
            exit(PdfToken.AsValue().AsText());
    end;
    // procedure OpenXMLToHtml(stream: InStream): Text[250]
    // var
    //     xmlTextReader: DotNet  "System.Xml.XmlTextReader";
    //     htmlStringBuilder: DotNet "System.Text.StringBuilder";
    //     htmlString: Text[250];
    // begin
    //     // Convertir el archivo de Word a HTML usando la librería OpenXML
    //     xmlTextReader := xmlTextReader.XmlTextReader(stream);
    //     htmlStringBuilder := htmlStringBuilder.StringBuilder;
    //     htmlString := '';

    //     while xmlTextReader.Read() do begin
    //         case xmlTextReader.NodeType of
    //             xmlTextReader.Element:
    //                 case xmlTextReader.Name of
    //                     'w:t':
    //                         htmlStringBuilder.Append('<span>');
    //                         htmlStringBuilder.Append(xmlTextReader.ReadString());
    //                         htmlStringBuilder.Append('</span>');
    //                     'w:p':
    //                         htmlStringBuilder.Append('<p>');
    //                     'w:br':
    //                         htmlStringBuilder.Append('<br>');
    //                 end;
    //             xmlTextReader.EndElement:
    //                 case xmlTextReader.Name of
    //                     'w:p':
    //                         htmlStringBuilder.Append('</p>');
    //                 end;
    //         end;
    //     end;

    //     htmlString := htmlStringBuilder.ToString();

    //     exit(htmlString);
    // end;

    // /// <summary>
    // /// InsertWordFileInEmailBody.
    // /// </summary>
    // procedure InsertWordFileInEmailBody()
    // var
    //     stream: InStream;
    //     htmlString: Text[250];
    // begin
    //     // Insertar el archivo de Word en el cuerpo del correo electrónico
    //     InsertWordFile.OPEN;
    //     stream := InsertWordFile.GETSTREAM;
    //     htmlString := OpenXMLToHtml(stream);
    //     InsertWordFile.CLOSE;

    //     BodyText := BodyText + htmlString;
    // end;

    // procedure SendEmail()
    // var
    //     EmailMessage: Record "Email Message";
    // begin
    //     // Enviar el correo electrónico
    //     EmailMessage := EmailMessage.CreateEmailMessage();

    //     EmailMessage.Subject := 'Correo electrónico con archivo de Word incrustado';
    //     EmailMessage.To := 'destinatario@ejemplo.com';
    //     EmailMessage.Body := BodyText;

    //     EmailMessage.Send;
    // end;



}

