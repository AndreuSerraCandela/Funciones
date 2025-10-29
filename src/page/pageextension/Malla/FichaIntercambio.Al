pageextension 75001 FichaIntercambio extends "Ficha Intercambio"
{
    actions
    {
        addfirst("Acci&ones")
        {
            action("&Desplegar")
            {
                ShortCutKey = F11;
                ApplicationArea = All;
                Image = BOMLevel;
                //CaptionML=ESP=Desplegar;
                trigger OnAction()
                VAR
                    rEmp: Record "Company Information";
                    rEmpresa: Record 2000000006;
                    Customer: Record Customer;
                    Vendor: Record Vendor;
                    RxE: Record "Intercambio x Empresa";
                    Cli: Code[20];
                    Prov: Code[20];
                    Control: Codeunit ControlProcesos;
                BEGIN
                    //rEmpresa.SETFILTER(rEmpresa."Clave Recursos",'<>%1','');
                    rEmpresa.SetRange("Evaluation Company", false);
                    if rEmpresa.FINDFIRST THEN
                        REPEAT
                            if Control.Permiso_Empresas(rEmpresa.Name) then begin
                                rEmp.ChangeCompany(rEmpresa.Name);
                                if not rEmp.Get() then rEmp.Init();
                                if rEmp."Clave Recursos" <> '' Then begin
                                    Customer.CHANGECOMPANY(rEmpresa.Name);
                                    Vendor.CHANGECOMPANY(rEmpresa.Name);
                                    Customer.SETRANGE("VAT Registration No.", Rec."VAT Registration No.");
                                    if NOT Customer.FINDFIRST THEN Cli := '' ELSE Cli := Customer."No.";
                                    Vendor.SETRANGE("VAT Registration No.", Rec."VAT Registration No.");
                                    if NOT Vendor.FINDFIRST THEN Prov := '' ELSE Prov := Vendor."No.";
                                    if RxE.GET(Rec."No.", rEmpresa.Name) THEN RxE.DELETE;
                                    RxE.INIT;
                                    RxE.Empresa := rEmpresa.Name;
                                    RxE."Código Intercambio" := Rec."No.";
                                    RxE.Cliente := Cli;
                                    RxE.Proveedor := Prov;
                                    if (Cli <> '') OR (Prov <> '') THEN
                                        RxE.INSERT;
                                end;
                            end;
                        UNTIL rEmpresa.NEXT = 0;
                END;
            }
        }
    }
}