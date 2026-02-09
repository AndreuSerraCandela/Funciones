pageextension 75019 ImagenesOrdenFijacion extends "Imagenes Orden fijacion"
{
    layout
    {
        modify(Nombre)
        {
            trigger OnDrillDown()
            var
                Selection: Integer;
                Control: Codeunit "ControlProcesos";
            begin
                if Rec."Image".HasValue() then
                    Control.Export(Rec, true)
                else
                    if not IsOfficeAddin or not EmailHasAttachments then
                        InitiateUploadFile()
                    else begin
                        Selection := StrMenu(MenuOptionsTxt, 1, SelectInstructionTxt);
                        case
                            Selection of
                            1:
                                InitiateAttachFromEmail();
                            2:
                                InitiateUploadFile();
                        end;
                    end;
            end;
        }
    }
    actions
    {
        addafter(shareWithOneDrive)
        {
            action(Preview)
            {
                ApplicationArea = All;
                Caption = 'Download';
                Image = Download;
                Enabled = DownloadEnabled;
                Scope = Repeater;
                ToolTip = 'Download the file to your device. Depending on the file, you will need an app to view or edit the file.';

                trigger OnAction()
                var
                    Control: Codeunit "ControlProcesos";
                begin
                    if Rec."Nombre" <> '' then
                        Control.Export(Rec, true);
                end;
            }

        }
        addafter(AttachFromEmail)
        {
            action(UploadFile)
            {
                ApplicationArea = All;
                Caption = 'Subir archivo';
                Image = Document;
                Enabled = true;
                Scope = Page;
                ToolTip = 'Subir un archivo desde su dispositivo.';
                Visible = IsOfficeAddin;

                trigger OnAction()
                begin
                    InitiateUploadFile();
                end;
            }
        }
    }
    trigger OnAfterGetCurrRecord()
    begin
        DownloadEnabled := (Rec.Image.HasValue() or (Rec.Url <> '')) and (not IsMultiSelect);
    end;

    local procedure InitiateAttachFromEmail()
    begin
        OfficeMgmt.InitiateSendToAttachments(FromRecRef);
        CurrPage.Update(true);
    end;

    local procedure InitiateUploadFile()
    var
        DocumentAttachment: Record "Imagenes Orden fijación";
        TempBlob: Codeunit "Temp Blob";
        FileName: Text;
        NImagen: Integer;
        Norden: Integer;
        DocStream: InStream;
        IsHandled: Boolean;
        Control: Codeunit "ControlProcesos";
    begin
        OnBeforeImportWithFilter(Rec, EsIncidencia, VallaFijada, IsHandled);
        if IsHandled then begin
            CurrPage.Update(false);
            exit;
        end;
        ImportWithFilter(TempBlob, FileName);

        if FileName <> '' then BEGIN
            iF Rec."Nº Imagen" = 0 then begin
                Rec."Nº Imagen" := -1;
                Rec.Insert();
                Norden := Rec."Nº Orden";
                DocumentAttachment.SetRange("Nº Orden", Rec."Nº Orden");
                Rec.Delete();
                If DocumentAttachment.FindSet() then
                    NImagen := DocumentAttachment."Nº Imagen"
                else
                    NImagen := 0;
            end;
            If Norden = 0 Then Norden := Rec."Nº Orden";
            Rec.Init();
            Rec."Nº Orden" := Norden;
            Rec."Nº Imagen" := NImagen + 1;
            Rec."Nombre" := FileName;
            TempBlob.CreateInStream(DocStream);
            Control.InsertAttachment(Rec, DocStream, FileName, true);
        end;
        CurrPage.Update(false);
    end;

    var
        DownloadEnabled: Boolean;
        EmailHasAttachments: Boolean;
        IsOfficeAddin: Boolean;
        MenuOptionsTxt: Label 'Attach from email,Upload file', Comment = 'Comma seperated phrases must be translated seperately.';
        SelectInstructionTxt: Label 'Choose the files to attach.';
        IsMultiSelect: Boolean;
        OfficeMgmt: Codeunit "Office Management";
        ImportTxt: Label 'Import';
        FileDialogTxt: Label 'Import';
        FilterTxt: Label 'Import';

    local procedure ImportWithFilter(var TempBlob: Codeunit "Temp Blob"; var FileName: Text)
    var
        FileManagement: Codeunit "File Management";
        IsHandled: Boolean;
    begin


        FileName := FileManagement.BLOBImportWithFilter(
            TempBlob, ImportTxt, FileName, StrSubstNo(FileDialogTxt, FilterTxt), FilterTxt);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeImportWithFilter(var Rec: Record "Imagenes Orden fijación"; var Esincidencia: Boolean; var VallaFijada: Boolean; var IsHandled: Boolean)
    begin
    end;

}