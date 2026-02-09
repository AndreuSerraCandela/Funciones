/// <summary>
/// Codeunit Funciones Correo PDF (ID 7001111).
/// </summary>
codeunit 7001111 "Funciones Correo PDF"
{
    Permissions = tabledata 112 = rimd, tabledata 114 = rimd, tabledata 36 = rimd, tabledata "Document Sending Profile" = rimd,
    tabledata "Facturas a Enviar" = rimd;
    trigger OnRun()
    BEGIN
        Cliente.SETFILTER(Cliente."Shipment Method Code", '<>%1', '');
        if Cliente.FINDFIRST THEN
            REPEAT
                rHisFac.SETRANGE(rHisFac."Sell-to Customer No.", Cliente."No.");
                rHisFac.MODIFYALL(rHisFac."Shipment Method Code", Cliente."Shipment Method Code");
            UNTIL Cliente.NEXT = 0;
    END;

    VAR
        smtp: Record "Email Account";
        rCnfVta: Record 311;
        TextExt: Label '.pdf';
        rCabVenta: Record 36;
        rCabVta2: Record 36;
        rHisFac: Record 112;
        rHisFac2: Record 112;
        rHisAbo: Record 114;
        rHisAbo2: Record 114;
        TxtArchivo: Text[300];
        DefaultPrinter: Text[200];
        Window: Dialog;
        //SendMsg: Codeunit 400;
        Cliente: Record Customer;
        CAtt: Codeunit 419;
        //pdfSettings : Automation "{A3F69B34-EAD8-4A3B-8DD5-C1C3FD300D67} 4.0:{F6C83BBD-F620-4F13-8320-9C51D1996EC4}:Unknown Automation Server.Unknown Class";
        //pdfUtil : Automation "{A3F69B34-EAD8-4A3B-8DD5-C1C3FD300D67} 4.0:{F9444F96-C32A-4745-9FF3-9059B92CDAB0}:Unknown Automation Server.Unknown Class";
        //SMTP: Record 409;
        REmail: Record "Email Item" temporary;
        emilesc: Enum "Email Scenario";
        Email: Record 95 TEMPORARY;
        r18: Record Customer;
        EmailF: Record 95 TEMPORARY;
        ficheros: Record Ficheros;
        Secuencia: Integer;
        rInf: Record "Company Information";
        Picture: Record "Picture Entity";

    PROCEDURE CreaPDF(pTipo: Option Contrato,Factura,Abono; pNumero: Code[20]; DocumentProfile: Code[20]);
    VAR
        statusFileName: Text[250];
        baseFolder: Text[250];
        //pdfFileName: Text[250];
        pdfFilename: OutStream;
        BigText: Text;
        rInf: Record 79;
        cr: Char;
        lf: Char;
        DataStream: OutStream;
        BodyText: BigText;
        Body: Integer;
        DocP: Record "Document Sending Profile";
        RepF: Integer;
        RepA: Integer;
        recImpresoraSeleccion: Record 78;
        recImpresoraSeleccionPrevia: Record 78 TEMPORARY;
        Fecha: Date;
        rBuzon: Record "Facturas a Enviar";
        //Fichero: File;
        outs: OutStream;
        ints: InStream;
        Correos: List of [Text];
        CorreosFrom: List of [Text];
        FileManagement: Codeunit "File Management";
        TempBlob: Codeunit "Temp Blob";
        AttachmentStream: InStream;
        Result: Boolean;
        Recref: RecordRef;
        Dir: Record "Ship-to Address";
        Base64: Text[250];
        Base64Convert: Codeunit "Base64 Convert";
        Url: Text;
        DocAttch: Record "Imagenes Orden fijación";
        Id: Integer;
        Control: Codeunit "ControlProcesos";
    BEGIN

        rCnfVta.GET;
        rCnfVta.TESTFIELD("Ruta Pdf generados");

        TxtArchivo := UPPERCASE(pNumero);

        Window.OPEN('Generando PDF Archivo ##################1', TxtArchivo);
        if DocP.GET(DocumentProfile) THEN BEGIN

            RepF := DocP."Report Facturas";
            RepA := DocP."Report Abonos";

            if DocP."Printer Name" <> '' THEN BEGIN
                if pTipo = pTipo::Factura THEN BEGIN
                    if recImpresoraSeleccion.GET('', RepF) THEN BEGIN
                        recImpresoraSeleccionPrevia.RESET;
                        recImpresoraSeleccionPrevia.INIT;
                        recImpresoraSeleccionPrevia.TRANSFERFIELDS(recImpresoraSeleccion);
                        recImpresoraSeleccionPrevia.INSERT;
                        recImpresoraSeleccion.DELETE;
                    END;
                    //Insertamos nuestra asignacion de impresora al report RepF
                    recImpresoraSeleccion.INIT;
                    recImpresoraSeleccion."Report ID" := RepF;
                    recImpresoraSeleccion."User ID" := '';
                    recImpresoraSeleccion."Printer Name" := DocP."Printer Name";
                    recImpresoraSeleccion.INSERT;
                    COMMIT;
                END;
                if pTipo = pTipo::Abono THEN BEGIN
                    if recImpresoraSeleccion.GET('', RepA) THEN BEGIN
                        recImpresoraSeleccionPrevia.RESET;
                        recImpresoraSeleccionPrevia.INIT;
                        recImpresoraSeleccionPrevia.TRANSFERFIELDS(recImpresoraSeleccion);
                        recImpresoraSeleccionPrevia.INSERT;
                        recImpresoraSeleccion.DELETE;
                    END;
                    //Insertamos nuestra asignacion de impresora al report RepA
                    recImpresoraSeleccion.INIT;
                    recImpresoraSeleccion."Report ID" := RepA;
                    recImpresoraSeleccion."User ID" := '';
                    recImpresoraSeleccion."Printer Name" := DocP."Printer Name";
                    recImpresoraSeleccion.INSERT;
                    COMMIT;
                END;
            END;
        END ELSE
            DocP.INIT;
        //if RepF = 0 THEN 
        // RepF := 50023;
        //if RepA = 0 THEN RepA := 7010797;
        if RepF = 0 THEN RepF := 50025;//Report::"Sales-Invoice Pdf";
        if RepA = 0 THEN RepA := 50029;

        //   if ISCLEAR(pdfSettings) THEN
        //     CREATE(pdfSettings);

        //   if ISCLEAR(pdfUtil) THEN
        //     CREATE(pdfUtil);
        //     baseFolder:=rCnfVta."Ruta Pdf generados";
        statusFileName := baseFolder + 'status.ini';
        //pdfFileName := baseFolder + TxtArchivo + '.pdf';
        //if EXISTS(pdfFileName) THEN ERASE(pdfFileName);
        if DocP.GET(DocumentProfile) THEN
            //        if DocP."Printer Name"<>'' THEN
            //       pdfSettings.printerName := DocP."Printer Name";
            //       pdfSettings.SetValue('Output', pdfFileName);
            //       pdfSettings.SetValue('ShowSaveAs', 'never');
            //       pdfSettings.SetValue('ShowSettings', 'never');
            //       pdfSettings.SetValue('ShowPDF', 'no');
            //       pdfSettings.SetValue('ShowProgress', 'no');
            //       pdfSettings.SetValue('ShowProgressFinished', 'no');
            //       pdfSettings.SetValue('ConfirmOverwrite', 'no');
            //       pdfSettings.SetValue('StatusFile', statusFileName);
            //       pdfSettings.SetValue('WatermarkColor', '#FF0000');
            //       pdfSettings.SetValue('WatermarkVerticalPosition', 'top');
            //       pdfSettings.SetValue('WatermarkHorizontalPosition', 'right');
            //       pdfSettings.SetValue('WatermarkRotation', '90');
            //       pdfSettings.SetValue('WatermarkOutlineWidth', '0.5');
            //       pdfSettings.SetValue('WatermarkFontSize', '20');
            //       pdfSettings.SetValue('WatermarkVerticalAdjustment', '5');
            //       pdfSettings.SetValue('WatermarkHorizontalAdjustment', '1');

            //       pdfSettings.SetValue('SuperimposeLayer', 'bottom');

            //       pdfSettings.SetValue('SuppressErrors', 'yes');

            //       pdfSettings.WriteSettings(TRUE);

            //if EXISTS(statusFileName) THEN ERASE(statusFileName);




        CASE pTipo OF
            pTipo::Contrato:
                BEGIN
                    rCabVenta.RESET;
                    rCabVenta.SETRANGE("Document Type", rCabVenta."Document Type"::Order);
                    rCabVenta.SETRANGE("No.", pNumero);
                    if rCabVenta.FINDFIRST THEN BEGIN
                        Fecha := rCabVenta."Posting Date";
                        // Report.SaveAsPdf(7010699, pdfFileName, rCabVenta);
                        Recref.GetTable(rCabVenta);
                        ficheros.Reset();
                        if ficheros.FindLast() then Secuencia := ficheros.Secuencia + 1 else Secuencia := 1;
                        ficheros.Secuencia := Secuencia;
                        ficheros."Nombre fichero" := TxtArchivo;
                        ficheros.Proceso := 'ENVIARPDF';
                        repeat
                            ficheros.Secuencia := Secuencia;
                            Secuencia += 1;
                        Until ficheros.Insert();
                        ficheros.CalcFields(Fichero);
                        ficheros.Fichero.CreateOutStream(pdfFilename);
                        If REPORT.SaveAs(Report::Contrato, '', ReportFormat::Pdf, pdfFilename, Recref) Then
                            ficheros.Modify()
                        else
                            Error('No se he generado el documento');
                        Cliente.GET(rCabVenta."Sell-to Customer No.");
                        if rCabVenta."Ship-to Code" <> '' then
                            if Dir.Get(Cliente."No.", rCabVenta."Ship-to Code") then
                                if dir."E-Mail-Facturación" <> '' Then Cliente."E-Mail-Facturación" := Dir."E-Mail-Facturación";
                    END;
                END;
            pTipo::Factura:
                BEGIN
                    rHisFac.RESET;
                    rHisFac.SETRANGE("No.", pNumero);
                    if rHisFac.FINDFIRST THEN BEGIN
                        Fecha := rHisFac."Posting Date";
                        //REPORT.SaveAsPdf(RepF, pdfFileName, rHisFac);
                        Recref.GetTable(rHisFac);
                        if ficheros.FindLast() then Secuencia := ficheros.Secuencia + 1 else Secuencia := 1;
                        ficheros.Secuencia := Secuencia;
                        ficheros."Nombre fichero" := TxtArchivo;
                        ficheros.Proceso := 'ENVIARPDF';
                        repeat
                            ficheros.Secuencia := Secuencia;
                            Secuencia += 1;
                        Until ficheros.Insert();
                        ficheros.CalcFields(Fichero);
                        ficheros.Fichero.CreateOutStream(pdfFilename);
                        if REPORT.SaveAs(RepF, '', ReportFormat::Pdf, pdfFilename, Recref) then
                            ficheros.Modify()
                        else
                            Error('No se he generado el documento');
                        if ficheros.Fichero.HasValue = false Then Error('No se he generado el documento');
                        Cliente.GET(rHisFac."Sell-to Customer No.");
                        if rHisFac."Ship-to Code" <> '' then
                            if Dir.Get(Cliente."No.", rHisFac."Ship-to Code") then
                                if dir."E-Mail-Facturación" <> '' Then Cliente."E-Mail-Facturación" := Dir."E-Mail-Facturación";
                    END;
                END;
            pTipo::Abono:
                BEGIN
                    rHisAbo.RESET;
                    rHisAbo.SETRANGE("No.", pNumero);
                    if rHisAbo.FINDFIRST THEN BEGIN
                        Fecha := rHisAbo."Posting Date";
                        //REPORT.SaveAsPdf(RepA, pdfFileName, rHisAbo);
                        Recref.GetTable(rHisAbo);
                        if ficheros.FindLast() then Secuencia := ficheros.Secuencia + 1 else Secuencia := 1;
                        ficheros.Secuencia := Secuencia;
                        ficheros."Nombre fichero" := TxtArchivo;
                        ficheros.Proceso := 'ENVIARPDF';
                        repeat
                            ficheros.Secuencia := Secuencia;
                            Secuencia += 1;
                        Until ficheros.Insert();
                        ficheros.CalcFields(Fichero);
                        ficheros.Fichero.CreateOutStream(pdfFilename);
                        if REPORT.SaveAs(RepF, '', ReportFormat::Pdf, pdfFilename, Recref) then
                            ficheros.Modify()
                        else
                            Error('No se he generado el documento');
                        if ficheros.Fichero.HasValue = false Then Error('No se he generado el documento');
                        Cliente.GET(rHisAbo."Sell-to Customer No.");
                        if rHisAbo."Ship-to Code" <> '' then
                            if Dir.Get(Cliente."No.", rHisAbo."Ship-to Code") then
                                if dir."E-Mail-Facturación" <> '' Then Cliente."E-Mail-Facturación" := Dir."E-Mail-Facturación";
                    END;
                END;
            END;

        //   if pdfUtil.WaitForFile(statusFileName, 20000)  THEN BEGIN
        //     // Check status file for errors.
        //    // if pdfUtil.ReadIniString(statusFileName, 'Status', 'Errors', '') <> '0' THEN BEGIN
        //    //   ERROR('Error creating PDF. ' + pdfUtil.ReadIniString(statusFileName, 'Status', 'MessageText', ''));
        //    // END;
        //   END ELSE BEGIN
        //     // The timeout elapsed. Something is wrong.
        //     ERROR('Error creating ' + pdfFileName)
        //   END;

        //SLEEP(4000);


        ficheros.Reset();
        ficheros.SetRange("Nombre fichero", TxtArchivo);
        ficheros.SetrANGE(Proceso, 'ENVIARPDF');
        if ficheros.FindLast() THEN BEGIN
            //if FILE.EXISTS(rCnfVta."Ruta Pdf generados" + TxtArchivo + '.pdf') THEN BEGIN
            if DocP."Enviar Ahora" THEN BEGIN
                //CLEAR(SendMsg);
                if DocP."E-Mail" = DocP.Printer::"Yes (Prompt for Settings)" THEN BEGIN
                    if Cliente."E-Mail-Facturación" <> '' THEN BEGIN // MESSAGE('El Cliente %1 no tiene mail',Cliente."No.");
                        //SMTP.GET;
                        rInf.GET;
                        //CorreosFrom.Add(Cliente."E-Mail-Facturación");
                        //CorreosFrom.AddRange(Cliente."E-Mail-Facturación".Split(';'));
                        REmail.Subject := 'Factura Nº' + TxtArchivo;

                        //FileManagement.BLOBImportFromServerFile(TempBlob, rCnfVta."Ruta Pdf generados" + TxtArchivo + '.pdf');
                        //TempBlob.CreateInStream(AttachmentStream);
                        ficheros.Reset();
                        ficheros.SetRange("Nombre fichero", TxtArchivo);
                        ficheros.SetrANGE(Proceso, 'ENVIARPDF');
                        ficheros.FindLast();
                        ficheros.CalcFields(Fichero);
                        ficheros.Fichero.CreateInStream(AttachmentStream);
                        Base64 := Base64Convert.ToBase64(AttachmentStream);
                        RecRef.Close();
                        //TempEmailItem.AddAttachment(AttachmentStream, Abono."No." + '.pdf');
                        If Base64 <> '' then
                            Url := Control.FormBase64ToUrl(Base64, TxtArchivo + '.pdf', Id);
                        Clear(AttachmentStream);
                        ficheros."Fecha Caducidad" := CalcDate('PM+2M', Today);
                        ficheros.Id_Url := Id;
                        ficheros.Fichero.CreateInStream(AttachmentStream);
                        REmail.AddAttachment(AttachmentStream, TxtArchivo + '.pdf');
                        clear(ficheros.Fichero);
                        FICHEROS.Procesado := true;
                        ficheros.modify;
                        OnAddAttachment(Url, TxtArchivo, '.pdf', Id, REmail.Id, UserSecurityId());

                        CargaPie(base64);
                        //SendMsg.CreateMessage(rInf."Cabecra Correo", SMTP."User ID", CorreosFrom, 'Factura Nº' + TxtArchivo, '', TRUE);
                        //FALSE);
                        //SendMsg.AddAttachment(rCnfVta."Ruta Pdf generados" + TxtArchivo + '.pdf', TxtArchivo + '.pdf');
                        //SendMsg.AddAttachment(rCnfVta."Ruta Pdf generados" + 'emailFoot.png', 'emailfoot.png');
                        //Correos.Add(SMTP."User ID");

                        //SendMsg.AddBCC(Correos);
                        REmail."Send to" := Cliente."E-Mail-Facturación";
                        //REmail."Send CC" := 'andreuserra@kuarasoftware.com';
                        rInf.GET;

                        BigText := ('Estimado Cliente:');
                        cr := 13;
                        lf := 10;
                        //(FORMAT(cr,0,'<CHAR>') + FORMAT(lf,0,'<CHAR>')
                        BigText := BigText + '<br> </br>';
                        BigText := BigText + '<br> </br>';
                        //BigText:=('<br> </br>';
                        BigText := BigText + ('A continuación le remitimos su factura con');
                        BigText := BigText + (' nº.  <a href="' + url + '">' + '<b>' + pNumero + '</b></a> de fecha ');
                        BigText := BigText + (FORMAT(Fecha, 0, '<Day,2>/<Month,2>/<Year>'));
                        BigText := BigText + (' correspondiente a los servicios que tiene contratados con ' + rInf.Name);
                        BigText := BigText + '<br> </br>';
                        BigText := BigText + '<br> </br>';
                        BigText := BigText + ('Aprovechamos la ocasión para enviarle un cordial saludo');
                        BigText := BigText + '<br> </br>';
                        BigText := BigText + '<br> </br>';
                        BigText := BigText + ('Atentamente');
                        BigText := BigText + '<br> </br>';
                        BigText := BigText + ('Dpto. de Administración.');
                        BigText := BigText + '<br> </br>';

                        BigText := BigText + (rInf.Name);
                        //"Plaintext Formatted":=TRUE;
                        // SendMsg.AppendBody(BigText);
                        // CLEAR(BigText);

                        BigText := BigText + '<br> </br>';
                        BigText := BigText + '<br> </br>';
                        BigText := BigText + '<img src="data:image/png;base64,' + base64 + '" />';//"emailFoot.png" />';
                        BigText := BigText + '<br> </br>';
                        BigText := BigText + '<br> </br>';
                        BigText := BigText + '<font face="Franklin Gothic Book" sice=2 color=#A6A6A6>';
                        BigText := BigText + ('<b>SI NO DESEA RECIBIR MAS INFORMACION, CONTESTE ESTE E-MAIL INDICANDOLO EXPRESAMENTE</b>');
                        BigText := BigText + '</font>';
                        BigText := BigText + '<br> </br>';
                        BigText := BigText + '<font face="Franklin Gothic Book" size=1 color=#A6A6A6>';
                        BigText := BigText + ('En cumplimiento de lo establecido en el REGLAMENTO (UE) 2016/679, de 27 de abril de 2016, con plenos efectos desde el 25 de mayo de 2018, le recordamos que sus datos personales son');
                        BigText := BigText + ('objeto de tratamiento por parte de MALLA S.A. Le informamos también que tiene la posibilidad de ejercer los derechos de acceso, rectificación, supresión, oposición, limitación del');
                        BigText := BigText + (' tratamiento y portabilidad de sus datos, mediante comunicación escrita a la dirección de correo electrónico <a href="mailto:lopd@malla.es" rel="noreferrer" target="_blank" heap-ignore="true"><span style="color:blue">lopd@malla.es</span></a>, o bien, a nuestra dirección postal (' + rInf.Name + ')');
                        BigText := BigText + (rInf.Address + '. ' + rInf."Post Code" + '. ' + rInf.City + '. España');
                        BigText := BigText + '<br> </br>';
                        BigText := BigText + ('Este correo y sus archivos asociados son privados y confidenciales y va dirigido exclusivamente a su destinatario. Si recibe este correo sin ser el destinatario del mismo, le rogamos proceda');
                        BigText := BigText + (' a su eliminación y lo ponga en conocimiento del emisor. La difusión por cualquier medio del contenido de este correo podría ser sancionada conforme a lo previsto en las leyes españolas.');
                        BigText := BigText + ('No se autoriza la utilización con fines comerciales o para su incorporación a ficheros automatizados de las direcciones del emisor o del destinatario');
                        BigText := BigText + '</font>';
                        REmail.SetBodyText(BigText);
                        // if REmail."From Address" <> '' Then
                        //     REmail."Send BCC" := REmail."From Address" else
                        //     REmail."Send BCC" := BCC();
                        REmail.Send(true, emilesc::Default);
                        //SendMsg.AppendBody(BigText);
                        //SendMsg.Send;
                        CASE pTipo OF
                            pTipo::Contrato:
                                BEGIN
                                    rCabVenta.RESET;
                                    rCabVenta.SETRANGE("Document Type", rCabVenta."Document Type"::Order);
                                    rCabVenta.SETRANGE("No.", pNumero);
                                    if rCabVenta.FINDFIRST THEN BEGIN
                                        rCabVenta."Enviada E-Mail" := TRUE;
                                        rCabVenta.MODIFY;
                                    END;
                                END;
                            pTipo::Factura:
                                BEGIN
                                    rHisFac.RESET;
                                    rHisFac.SETRANGE("No.", pNumero);
                                    if rHisFac.FINDFIRST THEN BEGIN
                                        rHisFac."Enviada E-Mail" := TRUE;
                                        rHisFac.MODIFY;
                                    END;
                                END;
                            pTipo::Abono:
                                BEGIN
                                    rHisAbo.RESET;
                                    rHisAbo.SETRANGE("No.", pNumero);
                                    if rHisAbo.FINDFIRST THEN BEGIN
                                        rHisAbo."Enviada E-Mail" := TRUE;
                                        rHisAbo.MODIFY;
                                    END;
                                END;
                        END;
                    END;
                END;
            END ELSE BEGIN
                if (pTipo = pTipo::Factura) OR (pTipo = pTipo::Abono) THEN BEGIN
                    if DocP."E-Mail" <> DocP."E-Mail"::No THEN BEGIN
                        if pTipo = pTipo::Factura THEN
                            rBuzon.TRANSFERFIELDS(rHisFac);
                        if pTipo = pTipo::Abono THEN
                            rBuzon.TRANSFERFIELDS(rHisAbo);
                        if rBuzon.INSERT THEN;
                        ficheros.Reset();
                        ficheros.SetRange("Nombre fichero", TxtArchivo);
                        ficheros.SetrANGE(Proceso, 'ENVIARPDF');
                        ficheros.FindLast();
                        ficheros.CalcFields(Fichero);
                        ficheros.Fichero.CreateInStream(ints);
                        // Fichero.OPEN(rCnfVta."Ruta Pdf generados" + TxtArchivo + '.pdf');
                        // Fichero.CREATEINSTREAM(ints);
                        rBuzon."Factura Blob".CREATEOUTSTREAM(outs);
                        COPYSTREAM(outs, ints);
                        if pTipo = pTipo::Abono THEN
                            rBuzon."Tipo Documento" := rBuzon."Tipo Documento"::"Credit Memo";
                        rBuzon.MODIFY;
                        //Fichero.CLOSE;
                    END;
                END;
            END;
        END;
        ficheros.DeleteAll();
        Window.CLOSE;
        if DocP.GET(DocumentProfile) THEN BEGIN
            if DocP."Printer Name" <> '' THEN BEGIN
                //Borramos nuestra asignacion
                if recImpresoraSeleccion.GET('', RepF) THEN BEGIN
                    recImpresoraSeleccion.DELETE;
                    //Restauramos la asignacion previa
                    if DELCHR(recImpresoraSeleccionPrevia."Printer Name", '<>', ' ') <> '' THEN BEGIN
                        recImpresoraSeleccion.INIT;
                        recImpresoraSeleccion."Report ID" := RepF;
                        recImpresoraSeleccion."User ID" := '';
                        recImpresoraSeleccion."Printer Name" := recImpresoraSeleccionPrevia."Printer Name";
                        recImpresoraSeleccion.INSERT;
                    END;
                END;
                if recImpresoraSeleccion.GET('', RepA) THEN BEGIN
                    recImpresoraSeleccion.DELETE;
                    //Restauramos la asignacion previa
                    if DELCHR(recImpresoraSeleccionPrevia."Printer Name", '<>', ' ') <> '' THEN BEGIN
                        recImpresoraSeleccion.INIT;
                        recImpresoraSeleccion."Report ID" := RepA;
                        recImpresoraSeleccion."User ID" := '';
                        recImpresoraSeleccion."Printer Name" := recImpresoraSeleccionPrevia."Printer Name";
                        recImpresoraSeleccion.INSERT;
                    END;
                END;

            END;
        END;
        if DocP.GET(DocumentProfile) THEN BEGIN
            if DocP.Printer <> DocP.Printer::No THEN BEGIN

                if RepF = 0 THEN RepF := 50025;//Report::"Sales-Invoice Pdf";
                if RepA = 0 THEN RepA := 50029;
                CASE pTipo OF
                    pTipo::Contrato:
                        BEGIN
                            rCabVenta.RESET;
                            rCabVenta.SETRANGE("Document Type", rCabVenta."Document Type"::Order);
                            rCabVenta.SETRANGE("No.", pNumero);
                            if rCabVenta.FINDFIRST THEN BEGIN
                                REPORT.RUNMODAL(Report::Contrato, FALSE, FALSE, rCabVenta);
                                Cliente.GET(rCabVenta."Sell-to Customer No.");
                                if rCabVenta."Ship-to Code" <> '' then
                                    if Dir.Get(Cliente."No.", rCabVenta."Ship-to Code") then
                                        if dir."E-Mail-Facturación" <> '' Then Cliente."E-Mail-Facturación" := Dir."E-Mail-Facturación";
                            END;
                        END;
                    pTipo::Factura:
                        BEGIN
                            rHisFac.RESET;
                            rHisFac.SETRANGE("No.", pNumero);
                            if rHisFac.FINDFIRST THEN BEGIN
                                REPORT.RUNMODAL(RepF, FALSE, FALSE, rHisFac);
                                Cliente.GET(rHisFac."Sell-to Customer No.");
                                if rHisFac."Ship-to Code" <> '' then
                                    if Dir.Get(Cliente."No.", rHisFac."Ship-to Code") then
                                        if dir."E-Mail-Facturación" <> '' Then Cliente."E-Mail-Facturación" := Dir."E-Mail-Facturación";
                            END;
                        END;
                    pTipo::Abono:
                        BEGIN
                            rHisAbo.RESET;
                            rHisAbo.SETRANGE("No.", pNumero);
                            if rHisAbo.FINDFIRST THEN BEGIN
                                REPORT.RUNMODAL(RepA, FALSE, FALSE, rHisAbo);
                                Cliente.GET(rHisAbo."Sell-to Customer No.");
                                if rHisAbo."Ship-to Code" <> '' then
                                    if Dir.Get(Cliente."No.", rHisAbo."Ship-to Code") then
                                        if dir."E-Mail-Facturación" <> '' Then Cliente."E-Mail-Facturación" := Dir."E-Mail-Facturación";
                            END;
                        END;
                END;
            END;
        END;
    END;

    PROCEDURE CreaPDFLotes(pTipo: Option Contrato,Factura,Abono; pNumero: Text[250]; pFecha: Text[100]; pCliente: Text[250]);
    BEGIN
        //DE MOMENTO NO SE UTILIZA ESTA FUNCION, NO CREA TODOS LOS PDF

        //Lo he compilado de nuevo en el servidor de Malla porque al ejecutarlo desde allí da un error en Options.
        //    {
        //   rCnfVta.GET;
        //   rCnfVta.TESTFIELD("Impresora Pdf");
        //   rCnfVta.TESTFIELD("Ruta Pdf generados");

        //   Window.OPEN('Generando PDF Archivo ##################1');

        //   if ISCLEAR(PDFCreator) THEN
        //     CREATE(PDFCreator);
        //   if ISCLEAR(PDFCreatorError) THEN
        //     CREATE(PDFCreatorError);
        //   if ISCLEAR(PDFCreatorOption) THEN
        //     CREATE(PDFCreatorOption);

        //   PDFCreatorError := PDFCreator.cError;
        //   if PDFCreator.cStart('/NoProcessingAtStartup',TRUE) = FALSE THEN
        //     ERROR('Status: Error[' + FORMAT(PDFCreatorError.Number) + ']: ' + PDFCreatorError.Email);

        //   PDFCreatorOption := PDFCreator.cOptions;
        //   PDFCreatorOption.UseAutosave := 1;
        //   PDFCreatorOption.UseAutosaveDirectory := 1;
        //   PDFCreatorOption.AutosaveDirectory := rCnfVta."Ruta Pdf generados";
        //   PDFCreatorOption.AutosaveFormat := 0;                       //PDF file, you can also save in other formats

        //   PDFCreator.cOptions := PDFCreatorOption;
        //   PDFCreator.cClearCache();
        //   DefaultPrinter := PDFCreator.cDefaultPrinter;
        //   PDFCreator.cDefaultPrinter := rCnfVta."Impresora Pdf";
        //   PDFCreator.cPrinterStop := FALSE;

        //   CASE pTipo OF
        //     pTipo::Contrato: BEGIN
        //       rCabVenta.RESET;
        //       rCabVenta.SETRANGE("Document Type",rCabVenta."Document Type"::Order);
        //       if pNumero <> '' THEN
        //         rCabVenta.SETFILTER("No.",pNumero);
        //       if pFecha <> '' THEN
        //         rCabVenta.SETFILTER("Posting Date",pFecha);
        //       if pCliente <> '' THEN
        //         rCabVenta.SETFILTER("Sell-to Customer No.",pCliente);
        //       if rCabVenta.FINDSET THEN BEGIN
        //         REPEAT
        //           rCabVta2.RESET;
        //           rCabVta2.SETRANGE("Document Type",rCabVta2."Document Type"::Order);
        //           rCabVta2.SETRANGE("No.",rCabVenta."No.");
        //           if rCabVta2.FINDFIRST THEN BEGIN
        //             TxtArchivo := UPPERCASE(rCabVta2."No.");
        //             Window.UPDATE(1,TxtArchivo);
        //             PDFCreatorOption.AutosaveFilename := TxtArchivo;
        //             REPORT.RUNMODAL(7010699,FALSE,TRUE,rCabVta2);
        //             SLEEP(4000);
        //           END;
        //         UNTIL rCabVenta.NEXT = 0;
        //       END;
        //     END;
        //     pTipo::Factura: BEGIN
        //       rHisFac.RESET;
        //       if pNumero <> '' THEN
        //         rHisFac.SETFILTER("No.",pNumero);
        //       if pFecha <> '' THEN
        //         rHisFac.SETFILTER("Posting Date",pFecha);
        //       if pCliente <> '' THEN
        //         rHisFac.SETFILTER("Sell-to Customer No.",pCliente);
        //       if rHisFac.FINDSET THEN BEGIN
        //         REPEAT
        //           rHisFac2.RESET;
        //           rHisFac2.SETRANGE("No.",rHisFac."No.");
        //           if rHisFac2.FINDFIRST THEN BEGIN
        //             TxtArchivo := UPPERCASE(rHisFac2."No.");
        //             Window.UPDATE(1,TxtArchivo);
        //             PDFCreatorOption.AutosaveFilename := TxtArchivo;
        //             REPORT.RUNMODAL(7010696,FALSE,TRUE,rHisFac2);
        //             SLEEP(4000);
        //           END;
        //         UNTIL rHisFac.NEXT = 0;
        //       END;
        //     END;
        //     pTipo::Abono: BEGIN
        //       rHisAbo.RESET;
        //       if pNumero <> '' THEN
        //         rHisAbo.SETFILTER("No.",pNumero);
        //       if pFecha <> '' THEN
        //         rHisAbo.SETFILTER("Posting Date",pFecha);
        //       if pCliente <> '' THEN
        //         rHisAbo.SETFILTER("Sell-to Customer No.",pCliente);
        //       if rHisAbo.FINDSET THEN BEGIN
        //         REPEAT
        //           rHisAbo2.RESET;
        //           rHisAbo2.SETRANGE("No.",rHisAbo."No.");
        //           if rHisAbo2.FINDFIRST THEN BEGIN
        //             TxtArchivo := UPPERCASE(rHisAbo2."No.");
        //             Window.UPDATE(1,TxtArchivo);
        //             PDFCreatorOption.AutosaveFilename := TxtArchivo;
        //             REPORT.RUNMODAL(7010697,FALSE,TRUE,rHisAbo2);
        //             SLEEP(4000);
        //           END;
        //         UNTIL rHisAbo.NEXT = 0;
        //       END;
        //     END;
        //   END;

        //   Window.CLOSE;

        //   //SLEEP(2000);

        //   PDFCreator.cPrinterStop := TRUE;
        //   PDFCreator.cDefaultPrinter := DefaultPrinter;
        //     }
    END;

    PROCEDURE CreaPDFAgrupado(pNumero: Code[20]; DocumentProfile: Code[20]; Imprimir: Boolean);
    VAR
        statusFileName: Text[250];
        baseFolder: Text[250];
        //pdfFileName: Text[250];
        pdffilename: OutStream;
        BigText: Text;
        rInf: Record 79;
        cr: Char;
        lf: Char;
        DataStream: OutStream;
        BodyText: BigText;
        Body: Integer;
        DocP: Record "Document Sending Profile";
        RepF: Integer;
        RepA: Integer;
        recImpresoraSeleccion: Record 78;
        recImpresoraSeleccionPrevia: Record 78 TEMPORARY;
        Fecha: Date;
        rBuzon: Record "Facturas a Enviar";
        Fichero: File;
        outs: OutStream;
        ints: InStream;
        RecRef: RecordRef;
        Abono: Boolean;
        Dir: Record "Ship-to Address";
    BEGIN
        //Lo he compilado de nuevo en el servidor de Malla porque al ejecutarlo desde allí da un error en Options.
        //dfC ='PDFCreator - Your OpenSource PDF Solution'.Queue
        //job = 'PDFCreator - Your OpenSource PDF Solution'.PrintJob

        rCnfVta.GET;
        //rCnfVta.TESTFIELD("Impresora Pdf");
        rCnfVta.TESTFIELD("Ruta Pdf generados");

        ///TxtArchivo := UPPERCASE(pNumero) + TextExt;
        TxtArchivo := UPPERCASE(pNumero);

        Window.OPEN('Generando PDF Archivo ##################1', TxtArchivo);
        if DocP.GET(DocumentProfile) THEN BEGIN
            RepF := DocP."Report Facturas";
            RepA := DocP."Report Abonos";
            if DocP."Printer Name" <> '' THEN BEGIN
                if recImpresoraSeleccion.GET('', RepF) THEN BEGIN
                    recImpresoraSeleccionPrevia.RESET;
                    recImpresoraSeleccionPrevia.INIT;
                    recImpresoraSeleccionPrevia.TRANSFERFIELDS(recImpresoraSeleccion);
                    recImpresoraSeleccionPrevia.INSERT;
                    recImpresoraSeleccion.DELETE;
                END;
                //Insertamos nuestra asignacion de impresora al report RepF
                recImpresoraSeleccion.INIT;
                recImpresoraSeleccion."Report ID" := RepF;
                recImpresoraSeleccion."User ID" := '';
                recImpresoraSeleccion."Printer Name" := DocP."Printer Name";
                recImpresoraSeleccion.INSERT;
                if recImpresoraSeleccion.GET('', RepA) THEN BEGIN
                    recImpresoraSeleccionPrevia.RESET;
                    recImpresoraSeleccionPrevia.INIT;
                    recImpresoraSeleccionPrevia.TRANSFERFIELDS(recImpresoraSeleccion);
                    recImpresoraSeleccionPrevia.INSERT;
                    recImpresoraSeleccion.DELETE;
                END;
                //Insertamos nuestra asignacion de impresora al report RepF
                recImpresoraSeleccion.INIT;
                recImpresoraSeleccion."Report ID" := RepA;
                recImpresoraSeleccion."User ID" := '';
                recImpresoraSeleccion."Printer Name" := DocP."Printer Name";
                recImpresoraSeleccion.INSERT;
                COMMIT;
            END;
        END ELSE
            DocP.INIT;
        if RepF = 0 THEN RepF := 50025;//Report::"Sales-Invoice Pdf";
        if RepA = 0 THEN RepA := 50029;

        //   if ISCLEAR(pdfSettings) THEN
        //     CREATE(pdfSettings);

        //   if ISCLEAR(pdfUtil) THEN
        //     CREATE(pdfUtil);
        // The status file is used to check for errors and determine when the PDF is ready.
        baseFolder := rCnfVta."Ruta Pdf generados";
        statusFileName := baseFolder + 'status.ini';
        // You can get a free test certificate at http://www.pdfpowertool.com
        //certificateFileName := baseFolder + '\ressources\certificate.pfx';
        //certificatePassword := 'password';
        // Set file name of background PDF.
        // Performance can be increased if you use an EPS file for background instead of a PDF.
        // Letterhead-A4.eps is a sample EPS background.
        // Note that using EPS files as background requires the Expert edition of the PDF Printer.
        //backgroundFileName := baseFolder + '\ressources\letterhead-a4.pdf';

        //mergeBeforeFileName := baseFolder + '\ressources\Before.pdf';
        //mergeAfterFileName := baseFolder + '\ressources\After.pdf';

        //counter := 0;
        //REPEAT
        // Set file name for output file.
        //pdfFileName := baseFolder + TxtArchivo + '.pdf';

        // Delete old output file if it already exist.
        //if EXISTS(pdfFileName) THEN ERASE(pdfFileName);

        // Multiple PDF printers could be installed.
        // Let the automation know which one to control.
        if DocP.GET(DocumentProfile) THEN
            if DocP."Printer Name" <> '' THEN
                //   pdfSettings.printerName := DocP."Printer Name";

                //   // Set output file name
                //   pdfSettings.SetValue('Output', pdfFileName);

                //   // Make sure no dialogs are shown during conversion.
                //   pdfSettings.SetValue('ShowSaveAs', 'never');
                //   pdfSettings.SetValue('ShowSettings', 'never');
                //   pdfSettings.SetValue('ShowPDF', 'no');
                //   pdfSettings.SetValue('ShowProgress', 'no');
                //   pdfSettings.SetValue('ShowProgressFinished', 'no');
                //   pdfSettings.SetValue('ConfirmOverwrite', 'no');

                //   // Set file name of status file to wait for.
                //   pdfSettings.SetValue('StatusFile', statusFileName);

                // Add a text watermark.
                // pdfSettings.SetValue('WatermarkText', 'PDF EXAMPLE - invoice ' + header."no.");
                //   pdfSettings.SetValue('WatermarkColor', '#FF0000');
                //   pdfSettings.SetValue('WatermarkVerticalPosition', 'top');
                //   pdfSettings.SetValue('WatermarkHorizontalPosition', 'right');
                //   pdfSettings.SetValue('WatermarkRotation', '90');
                //   pdfSettings.SetValue('WatermarkOutlineWidth', '0.5');
                //   pdfSettings.SetValue('WatermarkFontSize', '20');
                //   pdfSettings.SetValue('WatermarkVerticalAdjustment', '5');
                //   pdfSettings.SetValue('WatermarkHorizontalAdjustment', '1');

                // Add a background.
                // if a professional or expert license is installed the quality of the
                // background will improve.
                //pdfSettings.SetValue('Superimpose', backgroundFileName);
                //   pdfSettings.SetValue('SuperimposeLayer', 'bottom');

                // Merge with other PDF files.
                //pdfSettings.SetValue('MergeFile', mergeBeforeFileName + '|.|' + mergeAfterFileName);

                // Sign with a digital certificate.
                //pdfSettings.SetValue('SignCertificate', certificateFileName);
                //pdfSettings.SetValue('SignPassword', certificatePassword);
                //pdfSettings.SetValue('ShowSignature', 'yes');

                // Do not show errors in PDF user interface.
                //pdfSettings.SetValue('SuppressErrors', 'yes');

                // You can see more features and settings at
                // http://www.biopdf.com/guide/settings.php

                // Write settings to printer.
                // This writes a file name runonce.ini. It is a configuration that is used
                // for the next print job. The printer will delete the runonce.ini after it
                // is read.
                //pdfSettings.WriteSettings(TRUE);

                //if EXISTS(statusFileName) THEN ERASE(statusFileName);




        rHisFac.RESET;
        rHisFac.SETRANGE("No.", pNumero);
        if rHisFac.FINDFIRST THEN BEGIN
            Fecha := rHisFac."Posting Date";
            Recref.GetTable(rHisFac);
            ficheros.Reset();
            if ficheros.FindLast() then Secuencia := ficheros.Secuencia + 1 else Secuencia := 1;
            ficheros.Secuencia := Secuencia;
            ficheros."Nombre fichero" := TxtArchivo;
            ficheros.Proceso := 'ENVIARPDF';
            repeat
                ficheros.Secuencia := Secuencia;
                Secuencia += 1;
            Until ficheros.Insert();
            ficheros.CalcFields(Fichero);
            ficheros.Fichero.CreateOutStream(pdfFilename);
            If REPORT.SaveAs(RepF, '', ReportFormat::Pdf, pdfFilename, Recref) Then
                ficheros.Modify()
            else
                Error('No se he generado el documento');
            if ficheros.Fichero.HasValue = false Then Error('No se he generado el documento');
            //REPORT.SaveAsPdf(RepF, pdfFileName, rHisFac);
            Cliente.GET(rHisFac."Sell-to Customer No.");
            if rHisFac."Ship-to Code" <> '' then
                if Dir.Get(Cliente."No.", rHisfac."Ship-to Code") then
                    if dir."E-Mail-Facturación" <> '' Then Cliente."E-Mail-Facturación" := Dir."E-Mail-Facturación";
            Abono := FALSE;
        END;
        rHisAbo.RESET;
        rHisAbo.SETRANGE("No.", pNumero);
        if rHisAbo.FINDFIRST THEN BEGIN
            Fecha := rHisAbo."Posting Date";
            Recref.GetTable(rHisAbo);
            ficheros.Reset();
            if ficheros.FindLast() then Secuencia := ficheros.Secuencia + 1 else Secuencia := 1;
            ficheros.Secuencia := Secuencia;
            ficheros."Nombre fichero" := TxtArchivo;
            ficheros.Proceso := 'ENVIARPDF';
            repeat
                ficheros.Secuencia := Secuencia;
                Secuencia += 1;
            Until ficheros.Insert();
            ficheros.CalcFields(Fichero);
            ficheros.Fichero.CreateOutStream(pdfFilename);
            If REPORT.SaveAs(RepA, '', ReportFormat::Pdf, pdfFilename, Recref) then
                ficheros.Modify()
            else
                Error('No se he generado el documento');
            if ficheros.Fichero.HasValue = false Then Error('No se he generado el documento');
            //REPORT.SaveAsPdf(RepA, pdfFileName, rHisAbo);
            Cliente.GET(rHisAbo."Sell-to Customer No.");
            if rHisAbo."Ship-to Code" <> '' then
                if Dir.Get(Cliente."No.", rHisAbo."Ship-to Code") then
                    if dir."E-Mail-Facturación" <> '' Then Cliente."E-Mail-Facturación" := Dir."E-Mail-Facturación";
            Abono := TRUE
        END;

        //   if pdfUtil.WaitForFile(statusFileName, 20000)  THEN BEGIN
        //     // Check status file for errors.
        //    // if pdfUtil.ReadIniString(statusFileName, 'Status', 'Errors', '') <> '0' THEN BEGIN
        //    //   ERROR('Error creating PDF. ' + pdfUtil.ReadIniString(statusFileName, 'Status', 'MessageText', ''));
        //    // END;
        //   END ELSE BEGIN
        //     // The timeout elapsed. Something is wrong.
        //     ERROR('Error creating ' + pdfFileName)
        //   END;

        Window.CLOSE;
        if (DocP.GET(DocumentProfile)) THEN BEGIN
            if DocP."Printer Name" <> '' THEN BEGIN
                //Borramos nuestra asignacion
                if NOT Abono THEN BEGIN
                    if recImpresoraSeleccion.GET('', RepF) THEN BEGIN
                        recImpresoraSeleccion.DELETE;
                        //Restauramos la asignacion previa
                        if DELCHR(recImpresoraSeleccionPrevia."Printer Name", '<>', ' ') <> '' THEN BEGIN
                            recImpresoraSeleccion.INIT;
                            recImpresoraSeleccion."Report ID" := RepF;
                            recImpresoraSeleccion."User ID" := '';
                            recImpresoraSeleccion."Printer Name" := recImpresoraSeleccionPrevia."Printer Name";
                            recImpresoraSeleccion.INSERT;
                        END;
                    END;
                END ELSE BEGIN
                    if recImpresoraSeleccion.GET('', RepA) THEN BEGIN
                        recImpresoraSeleccion.DELETE;
                        //Restauramos la asignacion previa
                        if DELCHR(recImpresoraSeleccionPrevia."Printer Name", '<>', ' ') <> '' THEN BEGIN
                            recImpresoraSeleccion.INIT;
                            recImpresoraSeleccion."Report ID" := RepA;
                            recImpresoraSeleccion."User ID" := '';
                            recImpresoraSeleccion."Printer Name" := recImpresoraSeleccionPrevia."Printer Name";
                            recImpresoraSeleccion.INSERT;
                        END;
                    END;
                END;
            END;
        END;
        if Imprimir THEN BEGIN
            if DocP.GET(DocumentProfile) THEN BEGIN
                if DocP.Printer <> DocP.Printer::No THEN BEGIN

                    if RepF = 0 THEN RepF := 50023;//Report::"Sales-Invoice Malla";
                    if RepA = 0 THEN RepA := 50030;

                    rHisFac.RESET;
                    rHisFac.SETRANGE("No.", pNumero);
                    if rHisFac.FINDFIRST THEN BEGIN
                        REPORT.RUNMODAL(RepF, FALSE, FALSE, rHisFac);
                        Cliente.GET(rHisFac."Sell-to Customer No.");
                        if rHisFac."Ship-to Code" <> '' then
                            if Dir.Get(Cliente."No.", rHisFac."Ship-to Code") then
                                if dir."E-Mail-Facturación" <> '' Then Cliente."E-Mail-Facturación" := Dir."E-Mail-Facturación";
                    END;
                    rHisAbo.RESET;
                    rHisAbo.SETRANGE("No.", pNumero);
                    if rHisAbo.FINDFIRST THEN BEGIN
                        REPORT.RUNMODAL(RepA, FALSE, FALSE, rHisAbo);
                        Cliente.GET(rHisAbo."Sell-to Customer No.");
                        if rHisAbo."Ship-to Code" <> '' then
                            if Dir.Get(Cliente."No.", rHisAbo."Ship-to Code") then
                                if dir."E-Mail-Facturación" <> '' Then Cliente."E-Mail-Facturación" := Dir."E-Mail-Facturación";
                    END;

                END;
            END;
        END;
    END;

    PROCEDURE AgrupaPDF(VAR SalesInvoiceHeader: Record 112; pImprimir: Boolean);
    VAR
        Email: Record 95 TEMPORARY;
        r18: Record Customer;
        EmailF: Record 95 TEMPORARY;
    BEGIN
        if SalesInvoiceHeader.FINDFIRST THEN
            REPEAT
                if r18.GET(SalesInvoiceHeader."Sell-to Customer No.") THEN BEGIN
                    if r18."E-Mail-Facturación" = '' THEN r18."E-Mail-Facturación" := r18."E-Mail";
                    if r18."E-Mail-Facturación" <> '' THEN BEGIN
                        EmailF.Name := SalesInvoiceHeader."No.";
                        EmailF.Email := r18."E-Mail-Facturación";
                        EmailF."Budget Dimension 1 Code" := r18."Document Sending Profile";
                        EmailF.INSERT;
                        Email.SETRANGE(Email.Email, r18."E-Mail-Facturación");
                        if NOT Email.FINDFIRST THEN BEGIN
                            Email.Name := SalesInvoiceHeader."No.";
                            Email.Email := r18."E-Mail-Facturación";
                            Email."Budget Dimension 1 Code" := r18."Document Sending Profile";
                            Email.INSERT;
                        END;
                    END;
                END;
            UNTIL SalesInvoiceHeader.NEXT = 0;
        Email.RESET;
        if Email.FINDFIRST THEN
            REPEAT
                EmailF.SETRANGE(EmailF.Email, Email.Email);
                if EmailF.FINDFIRST THEN
                    REPEAT
                        SalesInvoiceHeader.GET(EmailF.Name);
                        r18.GET(SalesInvoiceHeader."Sell-to Customer No.");
                        CreaPDFAgrupado(SalesInvoiceHeader."No.", r18."Document Sending Profile", pImprimir);
                    UNTIL EmailF.NEXT = 0;
                EnviaCreaPDFAgrupado(EmailF, FALSE);
            UNTIL Email.NEXT = 0;
    END;

    PROCEDURE EnviaCreaPDFAgrupado(VAR EmailF: Record 95 TEMPORARY; Abono: Boolean);
    VAR
        statusFileName: Text[250];
        baseFolder: Text[250];
        pdfFileName: Text[250];
        BigText: Text;
        rInf: Record 79;
        cr: Char;
        lf: Char;
        DataStream: OutStream;
        BodyText: BigText;
        Body: Integer;
        DocP: Record "Document Sending Profile";
        RepF: Integer;
        RepA: Integer;
        recImpresoraSeleccion: Record 78;
        recImpresoraSeleccionPrevia: Record 78 TEMPORARY;
        Fecha: Date;
        rBuzon: Record "Facturas a Enviar";
        //Fichero: File;
        outs: OutStream;
        ints: InStream;
        r112: Record 112;
        Primera: Boolean;
        r114: Record 114;
        Correos: List of [Text];
        CorreosFrom: List of [Text];
        REmail: Record "Email Item" temporary;
        emilesc: Enum "Email Scenario";
        TempBlob: Codeunit "Temp Blob";
        AttachmentStream: InStream;
        FileManagement: Codeunit "File Management";
        Dir: Record "Ship-to Address";
        Base64: Text;
        Base64Convert: Codeunit "Base64 Convert";
        Url: Text;
        DocAttch: Record "Imagenes Orden fijación";
        Id: Integer;
        Control: Codeunit "ControlProcesos";
    BEGIN
        if EmailF.FINDFIRST THEN BEGIN
            TxtArchivo := EmailF.Name;
            ficheros.Reset();
            ficheros.SetRange("Nombre fichero", TxtArchivo);
            ficheros.SetrANGE(Proceso, 'ENVIARPDF');
            if ficheros.FindLast() THEN BEGIN
                //if FILE.EXISTS(rCnfVta."Ruta Pdf generados" + TxtArchivo + '.pdf') THEN BEGIN
                if TRUE THEN BEGIN
                    //CLEAR(SendMsg);
                    DocP.GET(EmailF."Budget Dimension 1 Code");
                    if TRUE THEN BEGIN
                        if (EmailF.Email <> '') AND (DocP."E-Mail" <> DocP."E-Mail"::No) THEN BEGIN
                            //SMTP.GET;
                            rInf.GET;
                            CorreosFrom.AddRange(EmailF.Email.Split(';'));//; .Add(EmailF.Email);
                            if Abono THEN
                                REmail.Subject := 'Abonos ' + rInf.Name
                            ELSE
                                REmail.Subject := 'Facturas ' + rInf.Name;
                            //FALSE);

                            // SendMsg.AddAttachment(rCnfVta."Ruta Pdf generados" + 'emailFoot', 'emailFoot.png');
                            // Correos.Add(SMTP."User ID");
                            // SendMsg.AddBCC(Correos);


                            Clear(TempBlob);

                            REmail."Send to" := EmailF.Email;// Cliente."E-Mail-Facturación";
                            BigText := ('Estimado Cliente:');
                            cr := 13;
                            lf := 10;
                            //(FORMAT(cr,0,'<CHAR>') + FORMAT(lf,0,'<CHAR>')
                            BigText := BigText + '<br> </br>';
                            BigText := BigText + '<br> </br>';
                            //BigText:=('<br> </br>';
                            if Abono THEN
                                BigText := BigText + ('A continuación le remitimos las siguientes Abonos')
                            ELSE
                                BigText := BigText + ('A continuación le remitimos las siguientes facturas');
                            //BigText:=BigText+'<table border="2px" style="margin: 0 auto;">';
                            // BigText:=BigText+'<div style="border: 1pt solid;">';
                            BigText := BigText + '<table border="1" WIDTH=400>';
                            BigText := BigText + '<TD WIDTH=200 ALIGN="CENTER"></TD>';
                            BigText := BigText + '<TD WIDTH=200 ALIGN="CENTER"></TD>';
                            BigText := BigText + '<tr>';
                            if Abono THEN
                                BigText := BigText + '<th><font Color="blue">Abono</th><font>'
                            ELSE
                                BigText := BigText + '<th><font Color="blue">Factura</th><font>';
                            BigText := BigText + '<th><font Color="blue">Fecha</th><font>';
                            BigText := BigText + '</tr>';

                            //REmail.SetBodyText(BigText);
                            //CLEAR(BigText);
                            REPEAT
                                // FileManagement.BLOBImportFromServerFile(TempBlob, rCnfVta."Ruta Pdf generados" + EmailF.Name + '.pdf');
                                // TempBlob.CreateInStream(AttachmentStream);
                                ficheros.Reset();
                                ficheros.SetRange("Nombre fichero", EmailF.Name);
                                ficheros.SetrANGE(Proceso, 'ENVIARPDF');
                                ficheros.FindLast();
                                ficheros.CalcFields(Fichero);
                                ficheros.Fichero.CreateInStream(AttachmentStream);
                                Base64 := Base64Convert.ToBase64(AttachmentStream);
                                If Base64 <> '' then
                                    Url := Control.FormBase64ToUrl(Base64, EmailF.Name + '.pdf', Id);
                                Clear(AttachmentStream);
                                ficheros."Fecha Caducidad" := CalcDate('PM+2M', Today);
                                ficheros.Id_Url := Id;
                                ficheros.Fichero.CreateInStream(AttachmentStream);
                                REmail.AddAttachment(AttachmentStream, EmailF.Name + '.pdf');
                                clear(ficheros.Fichero);
                                FICHEROS.Procesado := true;
                                ficheros.modify;
                                OnAddAttachment(Url, EmailF.Name, '.pdf', Id, REmail.Id, UserSecurityId());
                                //SendMsg.AddAttachment(rCnfVta."Ruta Pdf generados" + EmailF.Name + '.pdf', EmailF.Name + '.pdf');
                                if Abono THEN BEGIN
                                    r114.GET(EmailF.Name);
                                    Fecha := r114."Posting Date";
                                END ELSE BEGIN
                                    r112.GET(EmailF.Name);
                                    Fecha := r112."Posting Date";
                                END;
                                BigText := BigText + '<tr>';
                                BigText := BigText + ('<td ALIGN="CENTER"><font Color="blue"><a href="' + url + '">' + EmailF.Name + '</a></td></font>');
                                BigText := BigText + ('<td ALIGN="CENTER"><font Color="blue">' + FORMAT(Fecha, 0, '<Day,2>/<Month,2>/<Year>') + '</td></font>');
                                BigText := BigText + '</tr>';
                            //CLEAR(BigText);
                            //REmail.SetBodyText(BigText);
                            //CLEAR(BigText);
                            UNTIL EmailF.NEXT = 0;
                            BigText := BigText + '</table>';//</div>';
                            // SendMsg.AppendBody(BigText);
                            // CLEAR(BigText);
                            rInf.GET;
                            BigText := BigText + '<br> </br>';
                            BigText := BigText + (' correspondiente a los servicios que tiene contratados con ' + rInf.Name);
                            BigText := BigText + '<br> </br>';
                            BigText := BigText + '<br> </br>';
                            BigText := BigText + ('Aprovechamos la ocasión para enviarle un cordial saludo');
                            BigText := BigText + '<br> </br>';
                            BigText := BigText + '<br> </br>';
                            BigText := BigText + ('Atentamente');
                            BigText := BigText + '<br> </br>';
                            BigText := BigText + ('Dpto. de Administración.');
                            BigText := BigText + '<br> </br>';
                            BigText := BigText + (rInf.Name);
                            //"Plaintext Formatted":=TRUE;
                            // SendMsg.AppendBody(BigText);
                            // CLEAR(BigText);
                            CargaPie(base64);
                            BigText := BigText + '<br> </br>';
                            BigText := BigText + '<br> </br>';
                            BigText := BigText + '<img src="data:image/png;base64,' + base64 + '" />';//"emailFoot.png" />';
                            BigText := BigText + '<br> </br>';
                            BigText := BigText + '<br> </br>';
                            BigText := BigText + '<font face="Franklin Gothic Book" sice=2 color=#A6A6A6>';
                            BigText := BigText + ('<b>SI NO DESEA RECIBIR MAS INFORMACION, CONTESTE ESTE E-MAIL INDICANDOLO EXPRESAMENTE</b>');
                            BigText := BigText + '</font>';
                            BigText := BigText + '<br> </br>';
                            BigText := BigText + '<font face="Franklin Gothic Book" size=1 color=#A6A6A6>';
                            BigText := BigText + ('En cumplimiento de lo establecido en el REGLAMENTO (UE) 2016/679, de 27 de abril de 2016, con plenos efectos desde el 25 de mayo de 2018, le recordamos que sus datos personales son');
                            BigText := BigText + ('objeto de tratamiento por parte de MALLA S.A. Le informamos también que tiene la posibilidad de ejercer los derechos de acceso, rectificación, supresión, oposición, limitación del');
                            BigText := BigText + (' tratamiento y portabilidad de sus datos, mediante comunicación escrita a la dirección de correo electrónico <a href="mailto:lopd@malla.es" rel="noreferrer" target="_blank" heap-ignore="true"><span style="color:blue">lopd@malla.es</span></a>, o bien, a nuestra dirección postal (' + rInf.Name + ')');
                            BigText := BigText + (rInf.Address + '. ' + rInf."Post Code" + '. ' + rInf.City + '. España');
                            BigText := BigText + '<br> </br>';
                            BigText := BigText + ('Este correo y sus archivos asociados son privados y confidenciales y va dirigido exclusivamente a su destinatario. Si recibe este correo sin ser el destinatario del mismo, le rogamos proceda');
                            BigText := BigText + (' a su eliminación y lo ponga en conocimiento del emisor. La difusión por cualquier medio del contenido de este correo podría ser sancionada conforme a lo previsto en las leyes españolas.');
                            BigText := BigText + ('No se autoriza la utilización con fines comerciales o para su incorporación a ficheros automatizados de las direcciones del emisor o del destinatario');
                            //SendMsg.AppendBody(BigText);
                            //SendMsg.Send;
                            BigText := BigText + '</font>';
                            REmail.SetBodyText(BigText);
                            // if REmail."From Address" <> '' Then
                            //     REmail."Send BCC" := REmail."From Address" else
                            //     REmail."Send BCC" := BCC();
                            REmail.Send(true, emilesc::Default);
                            rHisFac.RESET;
                            rHisFac.SETRANGE("No.", EmailF.Name);
                            if rHisFac.FINDFIRST THEN BEGIN
                                rHisFac."Enviada E-Mail" := TRUE;
                                rHisFac.MODIFY;
                            END;
                            rHisAbo.RESET;
                            rHisAbo.SETRANGE("No.", EmailF.Name);
                            if rHisAbo.FINDFIRST THEN BEGIN
                                rHisAbo."Enviada E-Mail" := TRUE;
                                rHisAbo.MODIFY;
                            END;

                        END;
                    END;
                END;
            END ELSE BEGIN
                if Abono THEN BEGIN
                    rBuzon.TRANSFERFIELDS(rHisAbo);
                    rBuzon."Tipo Documento" := rBuzon."Tipo Documento"::"Credit Memo";
                END ELSE
                    rBuzon.TRANSFERFIELDS(rHisFac);
                if rBuzon.INSERT THEN;
                // Fichero.OPEN(rCnfVta."Ruta Pdf generados" + TxtArchivo + '.pdf');
                // Fichero.CREATEINSTREAM(ints);
                rBuzon."Factura Blob".CREATEOUTSTREAM(outs);
                ficheros.Reset();
                ficheros.SetRange("Nombre fichero", TxtArchivo);
                ficheros.SetrANGE(Proceso, 'ENVIARPDF');
                ficheros.FindLast();
                ficheros.CalcFields(Fichero);
                ficheros.Fichero.CreateInStream(ints);
                COPYSTREAM(outs, ints);
                rBuzon.MODIFY;
                //Fichero.CLOSE;
            END;
        END;
    END;

    PROCEDURE ProcesoPDF(VAR SalesInvoiceHeaxder: Record 112);
    VAR
        Contador: Integer;
        DocumentSendingProfile: Record "Document Sending Profile";
        SalesInvoiceHeaxderTemp: Record 112 TEMPORARY;
        Customer: Record Customer;
    BEGIN
        Email.DELETEALL;
        EmailF.DELETEALL;
        if DocumentSendingProfile.FINDFIRST THEN
            REPEAT
                Contador := Contador + 1;
                DocumentSendingProfile.Orden := Contador;
                DocumentSendingProfile.MODIFY;
            UNTIL DocumentSendingProfile.NEXT = 0;
        COMMIT;

        if SalesInvoiceHeaxder.FINDFIRST THEN
            REPEAT
                Customer.GET(SalesInvoiceHeaxder."Sell-to Customer No.");
                DocumentSendingProfile.GET(Customer."Document Sending Profile");
                SalesInvoiceHeaxderTemp.INIT;
                SalesInvoiceHeaxderTemp."Sell-to Customer No." := FORMAT(DocumentSendingProfile.Orden);
                SalesInvoiceHeaxderTemp."No." := SalesInvoiceHeaxder."No.";
                SalesInvoiceHeaxderTemp.INSERT;
            UNTIL SalesInvoiceHeaxder.NEXT = 0;
        if DocumentSendingProfile.FINDFIRST THEN
            REPEAT
                SalesInvoiceHeaxderTemp.SETRANGE(SalesInvoiceHeaxderTemp."Sell-to Customer No.", FORMAT(DocumentSendingProfile.Orden));
                if SalesInvoiceHeaxderTemp.FINDFIRST THEN
                    REPEAT
                        SalesInvoiceHeaxder.GET(SalesInvoiceHeaxderTemp."No.");
                        Customer.GET(SalesInvoiceHeaxder."Sell-to Customer No.");
                        if DocumentSendingProfile."Enviar Ahora" THEN BEGIN
                            AgrupaRPDF(SalesInvoiceHeaxder);
                            COMMIT;
                        END ELSE BEGIN
                            CreaPDF(1, SalesInvoiceHeaxder."No.", Customer."Document Sending Profile");
                        END;
                    UNTIL SalesInvoiceHeaxderTemp.NEXT = 0;
            UNTIL DocumentSendingProfile.NEXT = 0;
        LanzaProzesoAgr;
    END;

    PROCEDURE AgrupaRPDF(VAR SalesInvoiceHeader: Record 112 TEMPORARY);
    var
        DirEnvio: Record "Ship-to Address";
    BEGIN
        if r18.GET(SalesInvoiceHeader."Sell-to Customer No.") THEN BEGIN
            if r18."E-Mail-Facturación" = '' THEN r18."E-Mail-Facturación" := r18."E-Mail";
            if DirEnvio.Get(r18."No.", SalesInvoiceHeader."Ship-to Code") then
                if DirEnvio."E-Mail-Facturación" <> '' then r18."E-Mail-Facturación" := DirEnvio."E-Mail-Facturación";
            if r18."E-Mail-Facturación" <> '' THEN BEGIN
                EmailF.Name := SalesInvoiceHeader."No.";
                EmailF.Email := r18."E-Mail-Facturación";
                EmailF."Budget Dimension 1 Code" := r18."Document Sending Profile";
                EmailF.INSERT;
                Email.SETRANGE(Email.Email, r18."E-Mail-Facturación");
                if NOT Email.FINDFIRST THEN BEGIN
                    Email.Name := SalesInvoiceHeader."No.";
                    Email.Email := r18."E-Mail-Facturación";
                    Email."Budget Dimension 1 Code" := r18."Document Sending Profile";
                    Email.INSERT;
                END;
            END;
        END;
    END;

    PROCEDURE LanzaProzesoAgr();
    VAR
        SalesInvoiceHeader: Record 112;
    BEGIN
        Email.RESET;
        if Email.FINDFIRST THEN
            REPEAT
                EmailF.SETRANGE(EmailF.Email, Email.Email);
                if EmailF.FINDFIRST THEN
                    REPEAT
                        SalesInvoiceHeader.GET(EmailF.Name);
                        r18.GET(SalesInvoiceHeader."Sell-to Customer No.");
                        CreaPDFAgrupado(SalesInvoiceHeader."No.", r18."Document Sending Profile", TRUE);
                    UNTIL EmailF.NEXT = 0;
                EnviaCreaPDFAgrupado(EmailF, FALSE);
            UNTIL Email.NEXT = 0;
    END;

    PROCEDURE ProcesoAbonosPDF(VAR SalesInvoiceHeaxder: Record 114);
    VAR
        Contador: Integer;
        DocumentSendingProfile: Record "Document Sending Profile";
        SalesInvoiceHeaxderTemp: Record 114 TEMPORARY;
        Customer: Record Customer;
    BEGIN
        Email.DELETEALL;
        EmailF.DELETEALL;
        if DocumentSendingProfile.FINDFIRST THEN
            REPEAT
                Contador := Contador + 1;
                DocumentSendingProfile.Orden := Contador;
                DocumentSendingProfile.MODIFY;
            UNTIL DocumentSendingProfile.NEXT = 0;
        COMMIT;

        if SalesInvoiceHeaxder.FINDFIRST THEN
            REPEAT
                Customer.GET(SalesInvoiceHeaxder."Sell-to Customer No.");
                DocumentSendingProfile.GET(Customer."Document Sending Profile");
                SalesInvoiceHeaxderTemp.INIT;
                SalesInvoiceHeaxderTemp."Sell-to Customer No." := FORMAT(DocumentSendingProfile.Orden);
                SalesInvoiceHeaxderTemp."No." := SalesInvoiceHeaxder."No.";
                SalesInvoiceHeaxderTemp.INSERT;
            UNTIL SalesInvoiceHeaxder.NEXT = 0;
        if DocumentSendingProfile.FINDFIRST THEN
            REPEAT
                SalesInvoiceHeaxderTemp.SETRANGE(SalesInvoiceHeaxderTemp."Sell-to Customer No.", FORMAT(DocumentSendingProfile.Orden));
                if SalesInvoiceHeaxderTemp.FINDFIRST THEN
                    REPEAT
                        SalesInvoiceHeaxder.GET(SalesInvoiceHeaxderTemp."No.");
                        Customer.GET(SalesInvoiceHeaxder."Sell-to Customer No.");
                        if DocumentSendingProfile."Enviar Ahora" THEN
                            AgrupaRAbonoPDF(SalesInvoiceHeaxder)
                        ELSE BEGIN
                            CreaPDF(2, SalesInvoiceHeaxder."No.", Customer."Document Sending Profile");
                        END;
                    UNTIL SalesInvoiceHeaxderTemp.NEXT = 0;
            UNTIL DocumentSendingProfile.NEXT = 0;
        LanzaProzesoAbonoAgr;
    END;

    PROCEDURE LanzaProzesoAbonoAgr();
    VAR
        SalesInvoiceHeader: Record 114;
    BEGIN
        Email.RESET;
        if Email.FINDFIRST THEN
            REPEAT
                EmailF.SETRANGE(EmailF.Email, Email.Email);
                if EmailF.FINDFIRST THEN
                    REPEAT
                        SalesInvoiceHeader.GET(EmailF.Name);
                        r18.GET(SalesInvoiceHeader."Sell-to Customer No.");
                        CreaPDFAgrupado(SalesInvoiceHeader."No.", r18."Document Sending Profile", TRUE);
                    UNTIL EmailF.NEXT = 0;
                EnviaCreaPDFAbonoAgrupado(EmailF);
            UNTIL Email.NEXT = 0;
    END;

    PROCEDURE AgrupaRAbonoPDF(VAR SalesInvoiceHeader: Record 114 TEMPORARY);
    BEGIN
        if r18.GET(SalesInvoiceHeader."Sell-to Customer No.") THEN BEGIN
            if r18."E-Mail-Facturación" = '' THEN r18."E-Mail-Facturación" := r18."E-Mail";
            if r18."E-Mail-Facturación" <> '' THEN BEGIN
                EmailF.Name := SalesInvoiceHeader."No.";
                EmailF.Email := r18."E-Mail-Facturación";
                EmailF."Budget Dimension 1 Code" := r18."Document Sending Profile";
                EmailF.INSERT;
                Email.SETRANGE(Email.Email, r18."E-Mail-Facturación");
                if NOT Email.FINDFIRST THEN BEGIN
                    Email.Name := SalesInvoiceHeader."No.";
                    Email.Email := r18."E-Mail-Facturación";
                    Email."Budget Dimension 1 Code" := r18."Document Sending Profile";
                    Email.INSERT;
                END;
            END;
        END;
    END;

    PROCEDURE EnviaCreaPDFAbonoAgrupado(VAR EmailF: Record 95 TEMPORARY);
    VAR
        statusFileName: Text[250];
        baseFolder: Text[250];
        pdfFileName: Text[250];
        BigText: Text;
        rInf: Record 79;
        cr: Char;
        lf: Char;
        DataStream: OutStream;
        BodyText: BigText;
        Body: Integer;
        DocP: Record "Document Sending Profile";
        RepF: Integer;
        RepA: Integer;
        recImpresoraSeleccion: Record 78;
        recImpresoraSeleccionPrevia: Record 78 TEMPORARY;
        Fecha: Date;
        rBuzon: Record "Facturas a Enviar";
        //Fichero: File;
        outs: OutStream;
        ints: InStream;
        r112: Record 114;
        Primera: Boolean;
        rHisFac: Record 114;
        Correos: List of [Text];
        CorreosFrom: List of [Text];
        REmail: Record "Email Item" temporary;
        emilesc: Enum "Email Scenario";
        TempBlob: Codeunit "Temp Blob";
        AttachmentStream: InStream;
        FileManagement: Codeunit "File Management";
        Base64: Text;
        Base64Convert: Codeunit "Base64 Convert";
        Url: Text;
        DocAttch: Record "Imagenes Orden fijación";
        Id: Integer;
        Control: Codeunit "ControlProcesos";
    BEGIN
        if EmailF.FINDFIRST THEN BEGIN
            TxtArchivo := EmailF.Name;
            ficheros.Reset();
            ficheros.SetRange("Nombre fichero", TxtArchivo);
            ficheros.SetrANGE(Proceso, 'ENVIARPDF');
            if ficheros.FindLast() THEN BEGIN
                if TRUE THEN BEGIN
                    //CLEAR(SendMsg);
                    DocP.GET(EmailF."Budget Dimension 1 Code");
                    if TRUE THEN BEGIN
                        if (EmailF.Email <> '') AND (DocP."E-Mail" <> DocP."E-Mail"::No) THEN BEGIN
                            //SMTP.GET;
                            rInf.GET;
                            //CorreosFrom.AddRange(EmailF.Email.Split(';'));//; .Add(EmailF.Email);
                            //SendMsg.CreateMessage(rInf."Cabecra Correo", SMTP."User ID", CorreosFrom, 'Abonos ' + rInf.Name, '', TRUE);
                            REmail.Subject := 'Abonos ' + rInf.Name;
                            REmail."Send to" := EmailF.Email;
                            REmail."From Name" := rInf."Cabecra Correo";

                            Clear(TempBlob);
                            // SendMsg.AddAttachment(rCnfVta."Ruta Pdf generados" + 'emailFoot', 'emailFoot.png');
                            // Correos.Add(SMTP."User ID");
                            //SendMsg.AddBCC(Correos);

                            BigText := ('Estimado Cliente:');
                            cr := 13;
                            lf := 10;
                            //(FORMAT(cr,0,'<CHAR>') + FORMAT(lf,0,'<CHAR>')
                            BigText := BigText + '<br> </br>';
                            BigText := BigText + '<br> </br>';
                            //BigText:=('<br> </br>';
                            BigText := BigText + ('A continuación le remitimos las siguientes facturas');
                            //BigText:=BigText+'<table border="2px" style="margin: 0 auto;">';
                            // BigText:=BigText+'<div style="border: 1pt solid;">';
                            BigText := BigText + '<table border="1" WIDTH=400>';
                            BigText := BigText + '<TD WIDTH=200 ALIGN="CENTER"></TD>';
                            BigText := BigText + '<TD WIDTH=200 ALIGN="CENTER"></TD>';
                            BigText := BigText + '<tr>';
                            BigText := BigText + '<th><font Color="blue">Factura</th><font>';
                            BigText := BigText + '<th><font Color="blue">Fecha</th><font>';
                            BigText := BigText + '</tr>';
                            //REmail.SetBodyText(BigText);
                            //CLEAR(BigText);
                            REPEAT
                                // FileManagement.BLOBImportFromServerFile(TempBlob, rCnfVta."Ruta Pdf generados" + EmailF.Name + '.pdf');
                                // TempBlob.CreateInStream(AttachmentStream);
                                ficheros.Reset();
                                ficheros.SetRange("Nombre fichero", EmailF.Name);
                                ficheros.SetrANGE(Proceso, 'ENVIARPDF');
                                ficheros.FindLast();
                                ficheros.CalcFields(Fichero);
                                ficheros.Fichero.CreateInStream(AttachmentStream);
                                Base64 := Base64Convert.ToBase64(AttachmentStream);
                                If Base64 <> '' then
                                    Url := Control.FormBase64ToUrl(Base64, EmailF.Name + '.pdf', Id);
                                Clear(AttachmentStream);
                                ficheros."Fecha Caducidad" := CalcDate('PM+2M', Today);
                                ficheros.Id_Url := Id;
                                ficheros.Fichero.CreateInStream(AttachmentStream);
                                REmail.AddAttachment(AttachmentStream, EmailF.Name + '.pdf');
                                clear(ficheros.Fichero);
                                FICHEROS.Procesado := true;
                                ficheros.modify;

                                OnAddAttachment(Url, EmailF.Name, '.pdf', Id, REmail.Id, UserSecurityId());
                                //ficheros.DeleteAll();
                                //SendMsg.AddAttachment(rCnfVta."Ruta Pdf generados" + EmailF.Name + '.pdf', EmailF.Name + '.pdf');
                                r112.GET(EmailF.Name);
                                Fecha := r112."Posting Date";
                                BigText := BigText + '<tr>';
                                BigText := BigText + ('<td ALIGN="CENTER"><font Color="blue"><a href="' + url + '">' + EmailF.Name + '</a></td></font>');
                                BigText := BigText + ('<td ALIGN="CENTER"><font Color="blue">' + FORMAT(Fecha, 0, '<Day,2>/<Month,2>/<Year>') + '</td></font>');
                                BigText := BigText + '</tr>';
                            //REmail.SetBodyText(BigText);
                            // CLEAR(BigText);
                            UNTIL EmailF.NEXT = 0;
                            BigText := BigText + '</table>';//</div>';
                            //REmail.SetBodyText(BigText);
                            //CLEAR(BigText);
                            rInf.GET;
                            CargaPie(base64);
                            BigText := BigText + '<br> </br>';
                            BigText := BigText + (' correspondiente a los servicios que tiene contratados con ' + rInf.Name);
                            BigText := BigText + '<br> </br>';
                            BigText := BigText + '<br> </br>';
                            BigText := BigText + ('Aprovechamos la ocasión para enviarle un cordial saludo');
                            BigText := BigText + '<br> </br>';
                            BigText := BigText + '<br> </br>';
                            BigText := BigText + ('Atentamente');
                            BigText := BigText + '<br> </br>';
                            BigText := BigText + ('Dpto. de Administración.');
                            BigText := BigText + '<br> </br>';
                            BigText := BigText + (rInf.Name);
                            //"Plaintext Formatted":=TRUE;
                            // REmail.SetBodyText(BigText);
                            // CLEAR(BigText);
                            BigText := BigText + '<br> </br>';
                            BigText := BigText + '<br> </br>';
                            BigText := BigText + '<img src="data:image/png;base64,' + base64 + '" />';//"emailFoot.png" />';
                            BigText := BigText + '<br> </br>';
                            BigText := BigText + '<br> </br>';
                            BigText := BigText + '<font face="Franklin Gothic Book" sice=2 color=#A6A6A6>';
                            BigText := BigText + ('<b>SI NO DESEA RECIBIR MAS INFORMACION, CONTESTE ESTE E-MAIL INDICANDOLO EXPRESAMENTE</b>');
                            BigText := BigText + '</font>';
                            BigText := BigText + '<br> </br>';
                            BigText := BigText + '<font face="Franklin Gothic Book" size=1 color=#A6A6A6>';
                            BigText := BigText + ('En cumplimiento de lo establecido en el REGLAMENTO (UE) 2016/679, de 27 de abril de 2016, con plenos efectos desde el 25 de mayo de 2018, le recordamos que sus datos personales son');
                            BigText := BigText + ('objeto de tratamiento por parte de MALLA S.A. Le informamos también que tiene la posibilidad de ejercer los derechos de acceso, rectificación, supresión, oposición, limitación del');
                            BigText := BigText + (' tratamiento y portabilidad de sus datos, mediante comunicación escrita a la dirección de correo electrónico <a href="mailto:lopd@malla.es" rel="noreferrer" target="_blank" heap-ignore="true"><span style="color:blue">lopd@malla.es</span></a>, o bien, a nuestra dirección postal (' + rInf.Name + ')');
                            BigText := BigText + (rInf.Address + '. ' + rInf."Post Code" + '. ' + rInf.City + '. España');
                            BigText := BigText + '<br> </br>';
                            BigText := BigText + ('Este correo y sus archivos asociados son privados y confidenciales y va dirigido exclusivamente a su destinatario. Si recibe este correo sin ser el destinatario del mismo, le rogamos proceda');
                            BigText := BigText + (' a su eliminación y lo ponga en conocimiento del emisor. La difusión por cualquier medio del contenido de este correo podría ser sancionada conforme a lo previsto en las leyes españolas.');
                            BigText := BigText + ('No se autoriza la utilización con fines comerciales o para su incorporación a ficheros automatizados de las direcciones del emisor o del destinatario');
                            BigText := BigText + '</font>';
                            REmail.SetBodyText(BigText);
                            // if REmail."From Address" <> '' Then
                            //     REmail."Send BCC" := REmail."From Address" else
                            //     REmail."Send BCC" := BCC();
                            REmail.Send(true, emilesc::Default);
                            rHisFac.RESET;
                            rHisFac.SETRANGE("No.", EmailF.Name);
                            if rHisFac.FINDFIRST THEN BEGIN
                                rHisFac."Enviada E-Mail" := TRUE;
                                rHisFac.MODIFY;
                            END;
                        END;
                    END;
                END;
            END ELSE BEGIN
                rBuzon.TRANSFERFIELDS(rHisFac);
                if rBuzon.INSERT THEN;
                // Fichero.OPEN(rCnfVta."Ruta Pdf generados" + TxtArchivo + '.pdf');
                // Fichero.CREATEINSTREAM(ints);
                rBuzon."Factura Blob".CREATEOUTSTREAM(outs);
                rBuzon."Tipo Documento" := rBuzon."Tipo Documento"::"Credit Memo";
                ficheros.Reset();
                ficheros.SetRange("Nombre fichero", TxtArchivo);
                ficheros.SetrANGE(Proceso, 'ENVIARPDF');
                ficheros.FindLast();
                ficheros.CalcFields(Fichero);
                ficheros.Fichero.CreateInStream(ints);
                COPYSTREAM(outs, ints);
                rBuzon.MODIFY;
                //Fichero.CLOSE;
            END;
        END;
    END;

    PROCEDURE AgrupaAbonoPDF(VAR SalesInvoiceHeader: Record 114; pImprimir: Boolean);
    VAR
        Email: Record 95 TEMPORARY;
        r18: Record Customer;
        EmailF: Record 95 TEMPORARY;
    BEGIN
        if SalesInvoiceHeader.FINDFIRST THEN
            REPEAT
                if r18.GET(SalesInvoiceHeader."Sell-to Customer No.") THEN BEGIN
                    if r18."E-Mail-Facturación" = '' THEN r18."E-Mail-Facturación" := r18."E-Mail";
                    if r18."E-Mail-Facturación" <> '' THEN BEGIN
                        EmailF.Name := SalesInvoiceHeader."No.";
                        EmailF.Email := r18."E-Mail-Facturación";
                        EmailF."Budget Dimension 1 Code" := r18."Document Sending Profile";
                        EmailF.INSERT;
                        Email.SETRANGE(Email.Email, r18."E-Mail-Facturación");
                        if NOT Email.FINDFIRST THEN BEGIN
                            Email.Name := SalesInvoiceHeader."No.";
                            Email.Email := r18."E-Mail-Facturación";
                            Email."Budget Dimension 1 Code" := r18."Document Sending Profile";
                            Email.INSERT;
                        END;
                    END;
                END;
            UNTIL SalesInvoiceHeader.NEXT = 0;
        Email.RESET;
        if Email.FINDFIRST THEN
            REPEAT
                EmailF.SETRANGE(EmailF.Email, Email.Email);
                if EmailF.FINDFIRST THEN
                    REPEAT
                        SalesInvoiceHeader.GET(EmailF.Name);
                        r18.GET(SalesInvoiceHeader."Sell-to Customer No.");
                        CreaPDFAgrupado(SalesInvoiceHeader."No.", r18."Document Sending Profile", pImprimir);
                    UNTIL EmailF.NEXT = 0;
                EnviaCreaPDFAgrupado(EmailF, TRUE);
            UNTIL Email.NEXT = 0;
    END;

    PROCEDURE ProcesoAbonoPDF(VAR SalesInvoiceHeaxder: Record 114);
    VAR
        Contador: Integer;
        DocumentSendingProfile: Record "Document Sending Profile";
        SalesInvoiceHeaxderTemp: Record 114 TEMPORARY;
        Customer: Record Customer;
    BEGIN
        Email.DELETEALL;
        EmailF.DELETEALL;
        if DocumentSendingProfile.FINDFIRST THEN
            REPEAT
                Contador := Contador + 1;
                DocumentSendingProfile.Orden := Contador;
                DocumentSendingProfile.MODIFY;
            UNTIL DocumentSendingProfile.NEXT = 0;
        COMMIT;

        if SalesInvoiceHeaxder.FINDFIRST THEN
            REPEAT
                Customer.GET(SalesInvoiceHeaxder."Sell-to Customer No.");
                DocumentSendingProfile.GET(Customer."Document Sending Profile");
                SalesInvoiceHeaxderTemp.INIT;
                SalesInvoiceHeaxderTemp."Sell-to Customer No." := FORMAT(DocumentSendingProfile.Orden);
                SalesInvoiceHeaxderTemp."No." := SalesInvoiceHeaxder."No.";
                SalesInvoiceHeaxderTemp.INSERT;
            UNTIL SalesInvoiceHeaxder.NEXT = 0;
        if DocumentSendingProfile.FINDFIRST THEN
            REPEAT
                SalesInvoiceHeaxderTemp.SETRANGE(SalesInvoiceHeaxderTemp."Sell-to Customer No.", FORMAT(DocumentSendingProfile.Orden));
                if SalesInvoiceHeaxderTemp.FINDFIRST THEN
                    REPEAT
                        SalesInvoiceHeaxder.GET(SalesInvoiceHeaxderTemp."No.");
                        Customer.GET(SalesInvoiceHeaxder."Sell-to Customer No.");
                        if DocumentSendingProfile."Enviar Ahora" THEN
                            AgrupaRPDFAbono(SalesInvoiceHeaxder)
                        ELSE BEGIN
                            CreaPDF(2, SalesInvoiceHeaxder."No.", Customer."Document Sending Profile");
                        END;
                    UNTIL SalesInvoiceHeaxderTemp.NEXT = 0;
            UNTIL DocumentSendingProfile.NEXT = 0;
        LanzaProzesoAgrAbono;
    END;

    PROCEDURE AgrupaRPDFAbono(VAR SalesInvoiceHeader: Record 114 TEMPORARY);
    BEGIN
        if r18.GET(SalesInvoiceHeader."Sell-to Customer No.") THEN BEGIN
            if r18."E-Mail-Facturación" = '' THEN r18."E-Mail-Facturación" := r18."E-Mail";
            if r18."E-Mail-Facturación" <> '' THEN BEGIN
                EmailF.Name := SalesInvoiceHeader."No.";
                EmailF.Email := r18."E-Mail-Facturación";
                EmailF."Budget Dimension 1 Code" := r18."Document Sending Profile";
                EmailF.INSERT;
                Email.SETRANGE(Email.Email, r18."E-Mail-Facturación");
                if NOT Email.FINDFIRST THEN BEGIN
                    Email.Name := SalesInvoiceHeader."No.";
                    Email.Email := r18."E-Mail-Facturación";
                    Email."Budget Dimension 1 Code" := r18."Document Sending Profile";
                    Email.INSERT;
                END;
            END;
        END;
    END;

    PROCEDURE LanzaProzesoAgrAbono();
    VAR
        SalesInvoiceHeader: Record 114;
    BEGIN
        Email.RESET;
        if Email.FINDFIRST THEN
            REPEAT
                EmailF.SETRANGE(EmailF.Email, Email.Email);
                if EmailF.FINDFIRST THEN
                    REPEAT
                        SalesInvoiceHeader.GET(EmailF.Name);
                        r18.GET(SalesInvoiceHeader."Sell-to Customer No.");
                        CreaPDFAgrupado(SalesInvoiceHeader."No.", r18."Document Sending Profile", TRUE);
                    UNTIL EmailF.NEXT = 0;
                EnviaCreaPDFAgrupado(EmailF, TRUE);
            UNTIL Email.NEXT = 0;
    END;

    local procedure BCC(): Text[250]
    var
        SMTP: Record "Email Account";
    begin
        smtp.SetRange(Connector, smtp.Connector::SMTP);

        if smtp.FindFirst() then
            exit(smtp."Email Address")
        else begin
            smtp.SetRange(Connector);
            if SMTP.FindFirst() then exit(smtp."Email Address")
        end;

    end;
    /// <summary>
    /// CargaPie.
    /// </summary>
    /// <returns>Return value of type InStream.</returns>
    procedure CargaPie(var Base64: Text) AttachmentStream: InStream
    var
        TempBlob: Codeunit "Temp Blob";
        FileManagement: Codeunit "File Management";
        Outs: OutStream;
        Base64Convert: Codeunit "Base64 Convert";
    begin
        rInf.Get();
        rCnfVta.Get();


        if Not rInf."Email-Foot".HasValue Then begin

            FileManagement.BLOBImport(TempBlob, rCnfVta."Ruta Pdf generados" + 'emailFoot.png');
            TempBlob.CreateInStream(AttachmentStream);
            rInf."Email-Foot".CreateOutStream(Outs);
            CopyStream(Outs, AttachmentStream);
            rInf.Modify();
            Commit();
            Base64 := Base64Convert.ToBase64(AttachmentStream);
            Clear(AttachmentStream);

        end;
        rInf.CalcFields("Email-Foot");
        rInf."Email-Foot".CreateInStream(AttachmentStream);
        Base64 := Base64Convert.ToBase64(AttachmentStream);

    end;

    [IntegrationEvent(false, false)]
    local procedure OnAddAttachment(Url: Text; Nombre: Text[300]; Extension: Text; Id: Integer; MessageId: Guid; UserSecurityId: Guid)
    begin
    end;



    // [EventSubscriber(ObjectType::Codeunit, Codeunit::"Mail Management", 'OnSendViaEmailModuleOnAfterCreateMessage', '', false, false)]
    // internal procedure OnSendViaEmailModuleOnAfterCreateMessage(var Message: Codeunit "Email Message"; var TempEmailItem: Record "Email Item" temporary)

    // var
    //     BigText: Text;
    //     rInf: Record "Company Information";
    //     Funciones: Codeunit "Funciones Correo PDF";
    //     Attachment: InStream;
    //     ToB64: Codeunit "Base64 Convert";
    // begin

    //     TempEmailItem.AddAttachment(Funciones.CargaPie(), 'emailFoot.png');
    //     //Message.AddAttachment('emailFoot.png', GetContentTypeFromFilename('emailFoot.png'), Funciones.CargaPie());

    //     BigText := BigText + ('Aprovechamos la ocasión para enviarle un cordial saludo');
    //     BigText := BigText + '<br> </br>';
    //     BigText := BigText + '<br> </br>';
    //     BigText := BigText + ('Atentamente');
    //     BigText := BigText + '<br> </br>';
    //     BigText := BigText + ('Dpto. de Administración.');
    //     BigText := BigText + '<br> </br>';
    //     rInf.GET;
    //     BigText := BigText + (rInf.Name);
    //     //"Plaintext Formatted":=TRUE;
    //     // SendMsg.AppendBody(BigText);
    //     // CLEAR(BigText);
    //     BigText := BigText + '<br> </br>';
    //     BigText := BigText + '<br> </br>';
    //     BigText := BigText + '<img src="emailFoot.png" />';
    //     BigText := BigText + '<br> </br>';
    //     BigText := BigText + '<br> </br>';
    //     BigText := BigText + '<font face="Franklin Gothic Book" sice=2 color=Blue>';
    //     BigText := BigText + ('<b>SI NO DESEA RECIBIR MAS INFORMACION, CONTESTE ESTE E-MAIL INDICANDOLO EXPRESAMENTE</b>');
    //     BigText := BigText + '</font>';
    //     BigText := BigText + '<br> </br>';
    //     BigText := BigText + '<font face="Franklin Gothic Book" size=1 color=Blue>';
    //     BigText := BigText + ('Según la LOPD 15/199, su dirección de correo electrónico junto a los demás datos personales');
    //     BigText := BigText + (' que Ud. nos ha facilitado, constan en un fichero titularidad de ');
    //     BigText := BigText + (rInf.Name + ', cuyas finalidades son mantener la');
    //     BigText := BigText + (' gestión de las comunicaciones con sus clientes y con aquellas personas que solicitan');
    //     BigText := BigText + (' información, así como la gestión y atención de los correos entrantes o sugerencias que');
    //     BigText := BigText + (' se formulen a través de esta cuenta derivados de su actividad. Podrá ejercitar los derechos');
    //     BigText := BigText + (' de acceso, cancelación, rectificación y oposición,  dirigiéndose, por escrito a ');
    //     BigText := BigText + (rInf.Name + ' . ' + rInf.Address + '. ' + rInf."Post Code" + '. ' + rInf.City + '. España');

    //     BigText := BigText + '<br> </br>';
    //     // SendMsg.AppendBody(BigText);
    //     // CLEAR(BigText);
    //     BigText := BigText + ('Este correo y sus archivos asociados son privados y confidenciales y va');
    //     BigText := BigText + (' dirigido exclusivamente a su destinatario. Si recibe este correo sin ser');
    //     BigText := BigText + (' el destinatario del mismo, le rogamos proceda a su eliminación y lo ponga');
    //     BigText := BigText + (' en conocimiento del emisor. La difusión por cualquier medio del contenido de este');
    //     BigText := BigText + (' correo podría ser sancionada conforme a lo previsto en las leyes españolas. ');
    //     BigText := BigText + ('No se autoriza la utilización con fines comerciales o para su incorporación a ficheros');
    //     BigText := BigText + (' automatizados de las direcciones del emisor o del destinatario.');
    //     BigText := BigText + '</font>';
    //     //
    //     TempEmailItem.SetBodyText(BigText);
    // end;

    /// <summary>
    /// GetContentTypeFromFilename.
    /// </summary>
    /// <param name="FileName">Text.</param>
    /// <returns>Return value of type Text[250].</returns>

    //     BEGIN
    //     END.
    //   }
}
