/// <summary>
/// PageExtension SetupUsuarioKuara (ID 80126) extends Record User Setup.
/// </summary>
pageextension 80126 "SetupUsuarioKuara" extends "User Setup"
{
    layout
    {
        // Add changes to page layout here
        addlast(Control1)
        {

            field("Nombre certif. firma Efactura"; Rec."Nombre certif. firma Efactura")
            {
                ApplicationArea = All;
            }
            field("Certificado firma Efactura"; Rec."Certificado firma Efactura")
            {
                ApplicationArea = All;
            }
            field("Password certificado digital"; Rec."Password certificado digital")
            {
                ApplicationArea = All;
            }


            //añadir todos los campos de la tabla que empiezan por Mostrar
            field("Mostrar Ibiza Publicidad"; Rec."Mostrar Ibiza Publicidad")
            {
                ApplicationArea = All;

            }
            field("Mostrar Menorca Publicidad"; Rec."Mostrar Menorca Publicidad")
            {
                ApplicationArea = All;

            }
            field("Mostrar Malla Publicidad"; Rec."Mostrar Malla Publicidad")
            {
                ApplicationArea = All;

            }
            field("Mostrar Grepsa"; Rec."Mostrar Grepsa")
            {
                ApplicationArea = All;

            }



        }
        modify("Salespers./Purch. Code")
        {
            Caption = 'Comercial/Comprador/Técnico';
        }
    }
    actions
    {
        addlast(Processing)
        {
            action("Importar Certificado")
            {
                ApplicationArea = All;
                Image = Certificate;
                trigger OnAction()
                var
                    NVInStream: InStream;
                    OutStr: OutStream;
                    TempBlob: Codeunit "Temp Blob";
                    Base64: Codeunit "Base64 Convert";
                    Base64Txt: Text;
                    RecRf: RecordRef;
                begin
                    UPLOADINTOSTREAM('Import', '', ' All Files (*.*)|*.*', Rec."Nombre certif. firma Efactura", NVInStream);
                    Base64Txt := Base64.ToBase64(NVInStream);
                    TempBlob.CreateOutStream(OutStr);
                    Base64.FromBase64(Base64Txt, OutStr);
                    RecRf.Get(Rec.RecordId);
                    TempBlob.ToRecordRef(RecRf, Rec.FieldNo("Certificado firma Efactura"));
                    // Rec."Certificado firma Efactura".CreateOutStream(OutStr);
                    // CopyStream(OutStr, NVInStream);
                    RecRf.Modify();
                    Rec.Get(Rec."User ID");
                    Rec.CalcFields("Certificado firma Efactura");
                    if not rec."Certificado firma Efactura".HasValue Then Error('No se ha importado el certificado');
                end;
            }

        }
    }


}
