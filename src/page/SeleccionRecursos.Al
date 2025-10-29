/// <summary>
/// Page Nombre Comercial (ID 7001158).
/// </summary>
page 7001161 "Seleccionar Recursos"
{
    ApplicationArea = All;
    Caption = 'Seleccion Recursos';
    PageType = Card;
    SourceTable = "User Setup";
    UsageCategory = Tasks;
    DeleteAllowed = false;
    // InsertAllowed = false;
    layout
    {
        area(content)
        {
            field(Tarea; GTarea)
            {
                ApplicationArea = All;
                trigger OnAssistEdit()
                var
                    Sel: Record "To-do";
                begin
                    sel.SetRange("Peticion disponibilidad", "Peticion disponibilidad"::"Peticion Enviada");
                    if Page.RunModal(0, Sel) = Action::LookupOK then
                        GTarea := Sel."No.";
                end;
            }
            group(Buscar)
            {

                field("Mostrar Malla Publicidad"; Rec."Mostrar Malla Publicidad")
                {
                    ApplicationArea = All;
                    trigger OnValidate()
                    var
                        Sel: Record SeleccionRecursos;
                    begin
                        Sel.SetRange(UserId, UserId);
                        CurrPage.Opis.Page.filtraEmresa(rec);
                        CurrPage.Vallas.Page.filtraEmresa(rec);
                        CurrPage.SNAP.Page.filtraEmresa(rec);
                        CurrPage.Ascencores.Page.filtraEmresa(rec);
                        CurrPage.Peatonales.Page.filtraEmresa(rec);
                        CurrPage.V2x150.Page.filtraEmresa(rec);
                        CurrPage.IndCalle.Page.filtraEmresa(rec);
                        CurrPage.Medianeras.Page.filtraEmresa(rec);
                        CurrPage.Digitales.Page.filtraEmresa(rec);

                    end;
                }
                field("Mostrar Grepsa"; Rec."Mostrar Grepsa")
                {
                    ApplicationArea = All;
                    trigger OnValidate()
                    var
                        Sel: Record SeleccionRecursos;
                    begin
                        Sel.SetRange(UserId, UserId);
                        CurrPage.Opis.Page.filtraEmresa(rec);
                        CurrPage.Vallas.Page.filtraEmresa(rec);
                        CurrPage.SNAP.Page.filtraEmresa(rec);
                        CurrPage.Ascencores.Page.filtraEmresa(rec);
                        CurrPage.Peatonales.Page.filtraEmresa(rec);
                        CurrPage.V2x150.Page.filtraEmresa(rec);
                        CurrPage.IndCalle.Page.filtraEmresa(rec);
                        CurrPage.Medianeras.Page.filtraEmresa(rec);
                        CurrPage.Digitales.Page.filtraEmresa(rec);

                    end;
                }
                field("Mostrar Ibiza Publicidad"; Rec."Mostrar Ibiza Publicidad")
                {
                    ApplicationArea = All;
                    trigger OnValidate()
                    var
                        Sel: Record SeleccionRecursos;
                    begin
                        Sel.SetRange(UserId, UserId);
                        CurrPage.Opis.Page.filtraEmresa(rec);
                        CurrPage.Vallas.Page.filtraEmresa(rec);
                        CurrPage.SNAP.Page.filtraEmresa(rec);
                        CurrPage.Ascencores.Page.filtraEmresa(rec);
                        CurrPage.Peatonales.Page.filtraEmresa(rec);
                        CurrPage.V2x150.Page.filtraEmresa(rec);
                        CurrPage.IndCalle.Page.filtraEmresa(rec);
                        CurrPage.Medianeras.Page.filtraEmresa(rec);
                        CurrPage.Digitales.Page.filtraEmresa(rec);

                    end;
                }
                field("Mostrar Menorca Publicidad"; Rec."Mostrar Menorca Publicidad")
                {
                    ApplicationArea = All;
                    trigger OnValidate()
                    var
                        Sel: Record SeleccionRecursos;
                    begin
                        Sel.SetRange(UserId, UserId);
                        CurrPage.Opis.Page.filtraEmresa(rec);
                        CurrPage.Vallas.Page.filtraEmresa(rec);
                        CurrPage.SNAP.Page.filtraEmresa(rec);
                        CurrPage.Ascencores.Page.filtraEmresa(rec);
                        CurrPage.Peatonales.Page.filtraEmresa(rec);
                        CurrPage.V2x150.Page.filtraEmresa(rec);
                        CurrPage.IndCalle.Page.filtraEmresa(rec);
                        CurrPage.Medianeras.Page.filtraEmresa(rec);
                        CurrPage.Digitales.Page.filtraEmresa(rec);

                    end;
                }
                field(Busca; Busca)
                {
                    ApplicationArea = All;
                    trigger OnValidate()
                    var
                        Sel: Record SeleccionRecursos;
                    begin
                        Sel.SetRange(UserId, UserId);
                        CurrPage.Opis.Page.filtra(Busca);
                        CurrPage.Vallas.Page.filtra(Busca);
                        CurrPage.SNAP.Page.filtra(Busca);
                        CurrPage.Ascencores.Page.filtra(Busca);
                        CurrPage.Peatonales.Page.filtra(Busca);
                        CurrPage.V2x150.Page.filtra(Busca);
                        CurrPage.IndCalle.Page.filtra(Busca);
                        CurrPage.Medianeras.Page.filtra(Busca);
                        CurrPage.Digitales.Page.filtra(Busca);
                        CurrPage.Relojes.Page.filtra(Busca);
                    end;

                }
            }
            group("Vallas y Opis")
            {
                part(Opis; SeleccionRecursos)
                {
                    Caption = 'Opis';
                    SubPageView = where("Tipo Recurso" = const('OPI'));
                }
                part(Vallas; SeleccionRecursos)
                {
                    Caption = 'Vallas';
                    SubPageView = where("Tipo Recurso" = const('VALLA'));
                }
            }
            group("Otros Soportes")
            {
                part(Peatonales; SeleccionRecursos)
                {
                    Caption = 'Peatonales';
                    SubPageView = where("Tipo Recurso" = filter('VPEATON' | 'V.PEATON'));
                }
                part(Medianeras; SeleccionRecursos)
                {
                    Caption = 'Medianeras';
                    SubPageView = where("Tipo Recurso" = const('MEDIANERA'));
                }


                part("IndCalle"; SeleccionRecursos)
                {
                    Caption = 'Ind.Calle';
                    SubPageView = where("Tipo Recurso" = filter('INDICADOR' | 'IND.CALLE'));
                }
                part("V2x150"; SeleccionRecursos)
                {
                    Caption = '2x1''50';
                    SubPageView = where("Tipo Recurso" = const('2x1''50'));
                    //SubPageView = where("No." = filter('03*'));
                }
                // }
                // group("Soportes.")
                // {
                part(SNAP; SeleccionRecursos)
                {
                    Caption = 'SMAP';
                    SubPageView = where("Tipo Recurso" = Filter('MINI OPI' | 'OPI SMAP'));
                }
                part(Ascencores; SeleccionRecursos)
                {
                    Caption = 'Ascencores';
                    SubPageView = where("Tipo Recurso" = Filter('ASCENSORES' | 'ASCENSOR'));
                }
                part(Digitales; SeleccionRecursos)
                {
                    Caption = 'Digitales';
                    SubPageView = where("Tipo Recurso" = Filter('OPIDIGITAL' | 'OPI DIGIT.'));
                }
                part(Relojes; SeleccionRecursos)
                {
                    Caption = 'Relojes';
                    SubPageView = where("Tipo Recurso" = Filter('RELOJ'));
                }
            }
        }

    }
    actions
    {
        area(Reporting)
        {
            action(Informe)
            {
                ApplicationArea = All;
                Image = Loaner;
                trigger OnAction()
                var
                    Rep: Report "DisponibilidadWord";
                    Sel: Record SeleccionRecursos;
                    TMedia: Record "Tenant Media";
                    IsHanded: Boolean;
                    SaveStream: Boolean;
                begin
                    Sel.SetRange(UserId, UserId);
                    Sel.SetRange(Seleccionar, true);
                    IsHanded := false;
                    SaveStream := false;
                    OnAfterExportToExcelReport(Sel, SaveStream, IsHanded);
                    if not IsHanded then
                        ExportToExcel(Sel, SaveStream);
                    Rep.RunModal();
                    if Sel.FindSet() then
                        repeat
                            if Sel.Image.HasValue Then begin
                                if TMedia.Get(Sel.Image.MediaId) Then Tmedia.Delete();
                            end;
                        until Sel.Next() = 0;


                end;

            }
            action("Enviar Informe")
            {
                ApplicationArea = All;
                Image = SendConfirmation;
                trigger OnAction()
                var
                    Rep: Report DisponibilidadWord;
                    Sel: Record SeleccionRecursos;
                    TempBlob: Codeunit "Temp Blob";
                    DocAttachment: Record "Document Attachment";
                    out: OutStream;
                    ins: InStream;
                    "To-Do": Record "To-Do";
                    Dialog: Page Dialogo;
                    Tarea: Text;
                    Id: Integer;
                    RecRef: RecordRef;
                    RecRef2: RecordRef;
                    REmail: Record "Email Item" temporary;
                    AttachmentStream: InStream;
                    DocumentStream: OutStream;
                    Funciones: Codeunit "Funciones Correo PDF";
                    SalesPerson: Record "Salesperson/Purchaser";
                    BigText: Text;
                    rInf: Record "Company Information";
                    emilesc: Enum "Email Scenario";
                    Tmedia: Record "Tenant Media";
                    IsHanded: Boolean;
                    Base64: Text;
                begin
                    Sel.SetRange(UserId, UserId);
                    Sel.SetRange(Seleccionar, true);
                    TempBlob.CreateOutStream(out);
                    IsHanded := false;
                    OnAfterExportToExcel(Sel, out, IsHanded);
                    if not IsHanded then
                        ExportToExcel(Sel, out);
                    if GTarea = '' Then begin
                        Dialog.SetTexto('Nº de tarea: ');
                        Dialog.RunModal();
                        Dialog.GetTexto(Tarea);
                    end else begin
                        Tarea := GTarea;
                    end;
                    "To-Do".Get(Tarea);
                    DocAttachment.SetRange("Table ID", Database::"To-do");
                    DocAttachment.SetRange("No.", "To-Do"."No.");
                    DocAttachment.SetRange("File Name", 'Links_' + Tarea);
                    DocAttachment.DeleteAll();
                    DocAttachment.SetRange("File Name", 'Presentacion_' + Tarea);
                    DocAttachment.DeleteAll(true);
                    DocAttachment.SetRange("File Name");
                    if DocAttachment.FindLast() then
                        Id := DocAttachment.ID + 1
                    else
                        Id := 1;
                    DocAttachment.Init();
                    DocAttachment.ID := Id;
                    DocAttachment."Table ID" := Database::"To-do";
                    DocAttachment."No." := "To-Do"."No.";
                    DocAttachment."File Name" := 'Links_' + Tarea + '.xlsx';
                    DocAttachment."File Type" := "Document Attachment File Type"::Excel;
                    DocAttachment."File Extension" := 'xlsx';
                    TempBlob.CreateInStream(ins);
                    RecRef.GetTable("To-Do");
                    DocAttachment.SaveAttachmentFromStream(ins, RecRef, DocAttachment."File Name");
                    DocAttachment.Init();
                    DocAttachment.ID := Id + 1;
                    DocAttachment."Table ID" := Database::"To-do";
                    DocAttachment."No." := "To-Do"."No.";
                    DocAttachment."File Name" := 'Presentacion_' + Tarea + '.pdf';
                    DocAttachment."File Type" := "Document Attachment File Type"::PDF;
                    DocAttachment."File Extension" := 'Pdf';
                    RecRef.GetTable("To-Do");
                    Clear(TempBlob);
                    Clear(out);
                    Clear(ins);
                    TempBlob.CreateOutStream(out);
                    RecRef2.GetTable(Sel);
                    REPORT.SaveAs(Report::DisponibilidadWord, '', ReportFormat::Pdf, out, Recref2);
                    TempBlob.CreateInStream(ins);
                    DocAttachment.SaveAttachmentFromStream(ins, RecRef, DocAttachment."File Name");
                    REmail.Subject := 'RE: peticion disponibilidad tarea Nº' + Tarea;

                    //FileManagement.BLOBImportFromServerFile(TempBlob, rCnfVta."Ruta Pdf generados" + TxtArchivo + '.pdf');
                    //TempBlob.CreateInStream(AttachmentStream);
                    DocAttachment.Reset();
                    DocAttachment.SetRange("Table ID", Database::"To-do");
                    DocAttachment.SetRange("No.", "To-Do"."No.");
                    if DocAttachment.FindFirst() then
                        repeat
                            Clear(TempBlob);
                            TempBlob.CreateOutStream(DocumentStream);
                            DocAttachment."Document Reference ID".ExportStream(DocumentStream);
                            TempBlob.CreateInStream(AttachmentStream);
                            REmail.AddAttachment(AttachmentStream, DocAttachment."File Name" + '.' + DocAttachment."File Extension");
                        until DocAttachment.Next() = 0;


                    Funciones.CargaPie(base64);
                    "To-Do".TestField("Salesperson Code");
                    SalesPerson.Get("To-Do"."Salesperson Code");
                    SalesPerson.TESTFIELD("E-Mail");
                    REmail."Send to" := SalesPerson."E-Mail";
                    //REmail."Send CC" := 'andreuserra@kuarasoftware.com';


                    BigText := ('Estimado Compañero:');
                    if "To-Do"."Last Date Modified" = 0D then "To-Do"."Last Date Modified" := TODAY;
                    "To-Do".CalcFields("Contact Company Name");
                    //(FORMAT(cr,0,'<CHAR>') + FORMAT(lf,0,'<CHAR>')
                    BigText := BigText + '<br> </br>';
                    BigText := BigText + '<br> </br>';
                    //BigText:=('<br> </br>';
                    BigText := BigText + ('A continuación te remitimo la información relacionada con tu tarea');
                    BigText := BigText + (' nº. <b>' + "To-Do"."No." + '</b> de fecha ');
                    BigText := BigText + (FORMAT("To-Do"."Last Date Modified", 0, '<Day,2>/<Month,2>/<Year>'));
                    BigText := BigText + (' correspondiente al cliente: ' + "To-Do"."Contact Company Name");
                    BigText := BigText + '<br> </br>';
                    BigText := BigText + '<br> </br>';
                    BigText := BigText + ('Aprovechamos la ocasión para enviarle un cordial saludo');
                    BigText := BigText + '<br> </br>';
                    BigText := BigText + '<br> </br>';
                    BigText := BigText + ('Atentamente');
                    BigText := BigText + '<br> </br>';
                    BigText := BigText + ('Dpto. de medios.');
                    BigText := BigText + '<br> </br>';
                    rInf.GET;
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
                    if REmail.Send(false, emilesc::Default) then begin
                        "To-Do"."Peticion disponibilidad" := "Peticion disponibilidad"::"Respuesta Enviada";
                        "To-Do".Modify();
                    end;
                    if Sel.FindSet() then
                        repeat

                            if Sel.Image.HasValue Then begin
                                if TMedia.Get(Sel.Image.MediaId) Then Tmedia.Delete();
                            end;
                        until Sel.Next() = 0;
                end;

            }
            action(Desmaracar)
            {
                ApplicationArea = all;
                Image = UnApply;
                trigger OnAction()
                var
                    Sel: Record SeleccionRecursos;
                begin
                    Sel.SetRange(UserId, UserId);
                    Sel.ModifyAll(Seleccionar, false);
                end;
            }
            action("Importar Recursos")
            {
                // Permite importar una lista de recursos desde Excel para seleccionarlos automáticamente
                ApplicationArea = All;
                Image = Import;
                Caption = 'Importar Recursos desde Excel';
                trigger OnAction()
                var
                    TempExcelBuffer: Record "Excel Buffer" temporary;
                    FileName: Text;
                    SheetName: Text;
                    FileMgt: Codeunit "File Management";
                    InStream: InStream;
                    SeleccionRec: Record SeleccionRecursos;
                    Resource: Record Resource;
                    RowNo: Integer;
                    NoValue: Text;

                begin
                    SeleccionRec.SetRange(UserId, UserId);
                    SeleccionRec.SetRange(Seleccionar, false);
                    if UploadIntoStream('Seleccionar archivo Excel', '', 'Archivos Excel (*.xlsx)|*.xlsx|Todos los archivos (*.*)|*.*', FileName, InStream) then begin
                        SheetName := TempExcelBuffer.SelectSheetsNameStream(InStream);
                        TempExcelBuffer.OpenBookStream(InStream, SheetName);
                        TempExcelBuffer.ReadSheet();

                        // Buscar la primera fila con datos (asumiendo que la primera fila es encabezado)
                        RowNo := 2;

                        // Recorrer todas las filas del Excel
                        while TempExcelBuffer.Get(RowNo, 1) do begin
                            // Obtener el valor de la columna No. (primera columna)
                            NoValue := TempExcelBuffer."Cell Value as Text";

                            // Verificar si existe el recurso
                            //if Resource.Get(NoValue) then begin
                            // Crear registro en SeleccionRecursos si no existe
                            SeleccionRec.SetRange("No.", NoValue);
                            SeleccionRec.SetRange(UserId, UserId);

                            if SeleccionRec.FindFirst() then begin
                                SeleccionRec.Seleccionar := true;
                                SeleccionRec.Modify();
                            end else begin
                                Message('El recurso %1 no existe en la base de datos. para este usuario, compruebe si tiene seleccionadas las empresas correctas en mostrar', NoValue);
                            end;
                            //end;

                            RowNo += 1;
                        end;

                        Message('Importación completada. Los recursos han sido marcados para selección.');
                    end;
                end;
            }

        }
    }
    var
        Tipo: Code[20];
        L2x150: Label '2X1''50';
        Busca: Text;
        GTarea: Text;


    trigger OnOpenPage()
    begin
        Rec.SetRange("User ID", UserId);

        CurrPage.Opis.Page.filtraEmresa(rec);
        CurrPage.Vallas.Page.filtraEmresa(rec);
        CurrPage.SNAP.Page.filtraEmresa(rec);
        CurrPage.Ascencores.Page.filtraEmresa(rec);
        CurrPage.Peatonales.Page.filtraEmresa(rec);
        CurrPage.V2x150.Page.filtraEmresa(rec);
        CurrPage.IndCalle.Page.filtraEmresa(rec);
        CurrPage.Medianeras.Page.filtraEmresa(rec);
        CurrPage.Relojes.Page.filtraEmresa(rec);
        CurrPage.Digitales.Page.filtraEmresa(rec);


    end;

    local procedure ExportToExcel(var ResSel: Record SeleccionRecursos; ExcelStream: OutStream)
    var
        TempExcelBuffer: Record "Excel Buffer" temporary;
        LinksLbl2: Label 'Links';
        ExcelFileName2: Label 'Links_%1_%2';
        ReSources: Record Resource;
        ReSourceTemp: Record Resource temporary;
        CustomerPriceGroup: Record "Customer Price Group";
    begin
        if ResSel.FindFirst() Then
            repeat
                ReSources.ChangeCompany(ResSel.Empresa);
                if ReSources.get(ResSel."No.") Then begin
                    ReSourceTemp := ReSources;
                    if ReSourceTemp.Insert() then;
                end;
            until ResSel.Next() = 0;

        TempExcelBuffer.Reset();
        TempExcelBuffer.DeleteAll();
        TempExcelBuffer.NewRow();
        TempExcelBuffer.AddColumn(ResourceTemp.FieldCaption("No."), false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(ResourceTemp.FieldCaption(Name), false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(ResourceTemp.FieldCaption("Tipo Recurso"), false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(ResourceTemp.FieldCaption(Categoria), false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(ResourceTemp.FieldCaption(Medidas), false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(ResourceTemp.FieldCaption("Resource Group No."), false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(ResourceTemp.FieldCaption("Carretera"), false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(ResourceTemp.FieldCaption("prohibiciones"), false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(ResourceTemp.FieldCaption("Material Fijación"), false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Latitud', false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Longitud', false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);

        if ResourceTemp.FindSet() then
            repeat

                TempExcelBuffer.NewRow();
                TempExcelBuffer.AddColumn(ResourceTemp."No.", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn(ResourceTemp.Name, false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn(ResourceTemp."Tipo Recurso", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                if CustomerPriceGroup.Get(ResourceTemp."Customer Price Group") then
                    TempExcelBuffer.AddColumn(CustomerPriceGroup.Description, false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text)
                else
                    TempExcelBuffer.AddColumn(ResourceTemp."Customer Price Group", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn(ResourceTemp.Medidas, false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn(ResourceTemp."Resource Group No.", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn(ResourceTemp.Carretera, false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn(ResourceTemp.Prohibiciones, false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn(ResourceTemp."Material fijación", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                //La latitud corresponde a las coordenadas Y, mientras que la longitud corresponde a las coordenadas X.
                TempExcelBuffer.AddColumn(ConvertStr(Format(ResourceTemp.PuntoY), ',', '.'), false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn(ConvertStr(Format(ResourceTemp.PuntoX), ',', '.'), false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);

            until ResourceTemp.Next() = 0;
        TempExcelBuffer.CreateNewBook(LinksLbl2);
        TempExcelBuffer.WriteSheet(LinksLbl2, CompanyName, UserId);
        TempExcelBuffer.CloseBook();
        TempExcelBuffer.SetFriendlyFilename(StrSubstNo(ExcelFileName2, CurrentDateTime, UserId));
        TempExcelBuffer.SaveToStream(ExcelStream, true)

    end;

    local procedure ExportToExcel(var ResSel: Record SeleccionRecursos; SaveTostream: Boolean)
    var
        TempExcelBuffer: Record "Excel Buffer" temporary;
        LinksLbl: Label 'Links';
        ExcelFileName: Label 'Links_%1_%2';
        ReSources: Record Resource;
        ReSourceTemp: Record Resource temporary;
        CustomerPriceGroup: Record "Customer Price Group";

    begin
        if ResSel.FindFirst() Then
            repeat
                ReSources.ChangeCompany(ResSel.Empresa);
                if ReSources.get(ResSel."No.") Then begin
                    ReSourceTemp := ReSources;
                    if ReSourceTemp.Insert() then;
                end;
            until ResSel.Next() = 0;

        TempExcelBuffer.Reset();
        TempExcelBuffer.DeleteAll();
        TempExcelBuffer.NewRow();
        TempExcelBuffer.AddColumn(ResourceTemp.FieldCaption("No."), false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(ResourceTemp.FieldCaption(Name), false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(ResourceTemp.FieldCaption("Tipo Recurso"), false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(ResourceTemp.FieldCaption(Categoria), false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(ResourceTemp.FieldCaption(Medidas), false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(ResourceTemp.FieldCaption("Resource Group No."), false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(ResourceTemp.FieldCaption("Carretera"), false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(ResourceTemp.FieldCaption("prohibiciones"), false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(ResourceTemp.FieldCaption("Material Fijación"), false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Latitud', false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Longitud', false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);

        if ResourceTemp.FindSet() then
            repeat

                TempExcelBuffer.NewRow();
                TempExcelBuffer.AddColumn(ResourceTemp."No.", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn(ResourceTemp.Name, false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn(ResourceTemp."Tipo Recurso", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                if CustomerPriceGroup.Get(ResourceTemp."Customer Price Group") then
                    TempExcelBuffer.AddColumn(CustomerPriceGroup.Description, false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text)
                else
                    TempExcelBuffer.AddColumn(ResourceTemp."Customer Price Group", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn(ResourceTemp.Medidas, false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn(ResourceTemp."Resource Group No.", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn(ResourceTemp.Carretera, false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn(ResourceTemp.Prohibiciones, false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn(ResourceTemp."Material fijación", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                //La latitud corresponde a las coordenadas Y, mientras que la longitud corresponde a las coordenadas X.
                TempExcelBuffer.AddColumn(ConvertStr(Format(ResourceTemp.PuntoY), ',', '.'), false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn(ConvertStr(Format(ResourceTemp.PuntoX), ',', '.'), false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);

            until ResourceTemp.Next() = 0;
        TempExcelBuffer.CreateNewBook(LinksLbl);
        TempExcelBuffer.WriteSheet(LinksLbl, CompanyName, UserId);
        TempExcelBuffer.CloseBook();
        TempExcelBuffer.SetFriendlyFilename(StrSubstNo(ExcelFileName, CurrentDateTime, UserId));

        TempExcelBuffer.OpenExcel();

    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterExportToExcel(var Sel: Record SeleccionRecursos; var ExcelStream: OutStream; var IsHanded: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterExportToExcelReport(var Sel: Record SeleccionRecursos; var SaveStream: Boolean; var IsHanded: Boolean)
    begin
    end;
}