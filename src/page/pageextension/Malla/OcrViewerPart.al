pageextension 75018 OcrViewerPart extends "OCR Viewer Part"
{
    actions
    {
        addfirst(Processing)
        {
            action("Ampliar")
            {
                Caption = 'Abrir enlace';
                ApplicationArea = All;

                trigger OnAction();
                begin
                    Hyperlink(Url);
                end;
            }
        }
    }
    trigger OnAfterGetRecord()
    var
        base64: Text;
        Base64Convert: Codeunit "Base64 Convert";
        OutStr: OutStream;
        InStr: InStream;
        TempBlob: Codeunit "Temp Blob";
    begin
        Url := Rec.Url;
        if Url = '' Then exit;
        Base64 := Rec.ToBase64StringOcr(Url);
        TempBlob.CreateOutStream(OutStr);
        Base64Convert.FromBase64(base64, OutStr);
        TempBlob.CreateInStream(InStr);
        Clear(Rec.image);
        Rec.Image.ImportStream(InStr, Rec.Nombre);
    end;

    var
        Url: Text;

}
