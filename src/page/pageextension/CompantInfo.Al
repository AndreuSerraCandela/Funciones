/// <summary>
/// PageExtension CompantInfo (ID 80205) extends Record Company Information.
/// </summary>
pageextension 80198 CompantInfo extends "Company Information"
{
    layout
    {
        addlast(content)
        {
            group(Publicidad)
            {
                group(Efactura)
                {
                    field("Cód. estandar aditional Efact."; Rec."Cód. estandar aditional Efact.") { ApplicationArea = All; }
                    field("Cód. idioma Efactura"; Rec."Cód. idioma Efactura") { ApplicationArea = All; }
                    field("Periodo declaración Iva Efact."; Rec."Periodo declaración Iva Efact.") { ApplicationArea = All; }
                    field("Versión efactura"; Rec."Versión efactura") { ApplicationArea = All; }
                    field("E-Mail efactura"; Rec."E-Mail efactura") { ApplicationArea = All; }
                    field("Cabecera Correo"; Rec."Cabecra Correo") { ApplicationArea = All; }
                    field("Carpeta e factura"; Rec."Direc. carpeta Efactura") { ApplicationArea = All; }


                }
                group(Recursos)
                {
                    field("Nombre para recursos"; Rec."Nombre para recursos") { ApplicationArea = All; }
                    field("Fecha Inicio FPR"; Rec."Fecha Inicio FPR") { ApplicationArea = All; }
                    field("Clave Recursos"; Rec."Clave Recursos") { ApplicationArea = All; }
                    //field("Cuenta";Rec."Cuenta"){ApplicationArea=All;}
                    field("InterEmpresas"; Rec."InterEmpresas") { ApplicationArea = All; }
                    //field("Cuenta2";Rec."Cuenta2"){ApplicationArea=All;}
                    field("Nombre Ficheros"; Rec."Nombre Ficheros") { ApplicationArea = All; }
                }

                group(Otros)
                {
                    field("Empresa para mestros"; Rec."Empresa para mestros") { ApplicationArea = All; }
                    field("Desctivar SendBCC Escenario Defaul"; Rec."Desctivar SendBCC Defaul") { ApplicationArea = All; }



                }
            }
            group(Mensajes)
            {
                field("Instalación en curso"; Rec."Instalación En Curso") { ApplicationArea = All; }
                field("Mensaje general"; Rec."Mensaje General") { ApplicationArea = All; }
                field("Mensaje empresa"; Rec."Mensaje empresa") { ApplicationArea = All; }
            }

        }


    }
    var
        Permisos: Boolean;
        EmpPer: Boolean;

    trigger OnAfterGetRecord()
    var
        Application: Record "Application Area";
        Control: Codeunit "ControlProcesos";
    begin
        EmpPer := false;
        Application.SetRange("Company Name", CompanyName);
        if Application.FindFirst() Then EmpPer := Application.BasicHR;
        Permisos := Control.CompruebaPermisos(UserSecurityId(), 'ESP', CompanyName);
    end;

}