pageextension 75002 Intercambiolist extends "Intercambio list"
{
    actions
    {
        addafter("Copiar &Datos del cliente")
        {
            action("Crear automá&ticamente")
            {
                Image = Create;
                ApplicationArea = All;
                Visible = false;
                //CaptionML=ESP=Crear automáticamente;
                trigger OnAction()
                VAR
                    Inter: Record Intercambio;
                    rEmpresa: Record Company;
                    Customer: Record Customer;
                    Vendor: Record Vendor;
                    RxE: Record "Intercambio x Empresa";
                    Cli: Code[20];
                    Prov: Code[20];
                    rEmp: Record "Company Information";
                    Control: Codeunit ControlProcesos;
                BEGIN

                    Inter.DELETEALL;
                    if COMPANYNAME <> 'Malla Publicidad' THEN ERROR('Solo se puede ejecutar desde Malla');
                    //rEmpresa.SETFILTER(rEmpresa."Clave Recursos",'<>%1','');
                    rEmpresa.SetRange("Evaluation Company", false);
                    if rEmpresa.FINDFIRST THEN
                        REPEAT
                            if Control.Permiso_Empresas(rEmpresa.Name) then begin
                                rEmp.ChangeCompany(rEmpresa.Name);
                                if not rEmp.Get() Then rEmp.Init();
                                if rEmp."Clave Recursos" <> '' then begin
                                    Customer.CHANGECOMPANY(rEmpresa.Name);
                                    Vendor.CHANGECOMPANY(rEmpresa.Name);
                                    Customer.SETRANGE(Customer."Payment Method Code", 'INTERCAM');
                                    Customer.SETFILTER("VAT Registration No.", '<>%1', '');
                                    if Customer.FINDFIRST THEN
                                        REPEAT
                                            Inter.SETRANGE(Inter."VAT Registration No.", Customer."VAT Registration No.");
                                            if NOT Inter.FINDFIRST THEN BEGIN
                                                WITH Inter DO BEGIN
                                                    "No." := '';
                                                    if "No." = '' THEN INSERT(TRUE);
                                                    //    "Search Name":=Customer."Search Name";
                                                    Name := Customer.Name;
                                                    "Name 2" := Customer."Name 2";
                                                    Address := Customer.Address;
                                                    "Address 2" := Customer."Address 2";
                                                    City := Customer.City;
                                                    Contact := Customer.Contact;
                                                    "Phone No." := Customer."Phone No.";
                                                    "Telex No." := Customer."Telex No.";
                                                    "Our Account No." := Customer."Our Account No.";
                                                    "Territory Code" := Customer."Territory Code";
                                                    "Global Dimension 1 Code" := Customer."Global Dimension 1 Code";
                                                    "Global Dimension 2 Code" := Customer."Global Dimension 2 Code";
                                                    "Chain Name" := Customer."Chain Name";
                                                    "Budgeted Amount" := Customer."Budgeted Amount";
                                                    "Credit Limit (LCY)" := Customer."Credit Limit (LCY)";
                                                    "Currency Code" := Customer."Currency Code";
                                                    "Payment Terms Code" := Customer."Payment Terms Code";
                                                    "Salesperson Code" := Customer."Salesperson Code";
                                                    "Shipment Method Code" := Customer."Shipment Method Code";
                                                    "Shipping Agent Code" := Customer."Shipping Agent Code";
                                                    "Country/Region Code" := Customer."Country/Region Code";
                                                    Blocked := Customer.Blocked;
                                                    "Payment Method Code" := Customer."Payment Method Code";
                                                    "Last Date Modified" := Customer."Last Date Modified";
                                                    "Fax No." := Customer."Fax No.";
                                                    "VAT Registration No." := Customer."VAT Registration No.";
                                                    "Post Code" := Customer."Post Code";
                                                    County := Customer.County;
                                                    "E-Mail" := Customer."E-Mail";
#pragma warning disable AL0432
                                                    "Home Page" := Customer."Home Page";
#pragma warning restore AL0432
                                                    "Primary Contact No." := Customer."Primary Contact No.";
                                                    "E-Mail-Facturación" := Customer."E-Mail Efactura";
                                                    MODIFY;
                                                    Desplegar(Inter);
                                                    COMMIT;
                                                END;
                                            END;
                                        UNTIL Customer.NEXT = 0;
                                    Vendor.SETRANGE("Payment Method Code", 'INTERCAM');
                                    Vendor.SETFILTER("VAT Registration No.", '<>%1', '');

                                    if Vendor.FINDFIRST THEN
                                        REPEAT
                                            Inter.SETRANGE(Inter."VAT Registration No.", Vendor."VAT Registration No.");
                                            if NOT Inter.FINDFIRST THEN BEGIN
                                                WITH Inter DO BEGIN
                                                    "No." := '';
                                                    if "No." = '' THEN INSERT(TRUE);
                                                    //  "Search Name":=Vendor."Search Name";
                                                    Name := Vendor.Name;
                                                    "Name 2" := Vendor."Name 2";
                                                    Address := Vendor.Address;
                                                    "Address 2" := Vendor."Address 2";
                                                    City := Vendor.City;
                                                    Contact := Vendor.Contact;
                                                    "Phone No." := Vendor."Phone No.";
                                                    "Telex No." := Vendor."Telex No.";
                                                    "Our Account No." := Vendor."Our Account No.";
                                                    "Territory Code" := Vendor."Territory Code";
                                                    "Global Dimension 1 Code" := Vendor."Global Dimension 1 Code";
                                                    "Global Dimension 2 Code" := Vendor."Global Dimension 2 Code";
                                                    "Chain Name" := '';
                                                    "Budgeted Amount" := Vendor."Budgeted Amount";
                                                    "Credit Limit (LCY)" := 0;
                                                    "Currency Code" := Vendor."Currency Code";
                                                    "Payment Terms Code" := Vendor."Payment Terms Code";
                                                    "Salesperson Code" := '';
                                                    "Shipment Method Code" := Vendor."Shipment Method Code";
                                                    "Shipping Agent Code" := Vendor."Shipping Agent Code";
                                                    "Country/Region Code" := Vendor."Country/Region Code";
                                                    Blocked := Vendor.Blocked;
                                                    "Payment Method Code" := Vendor."Payment Method Code";
                                                    "Last Date Modified" := Vendor."Last Date Modified";
                                                    "Fax No." := Vendor."Fax No.";
                                                    "VAT Registration No." := Vendor."VAT Registration No.";
                                                    "Post Code" := Vendor."Post Code";
                                                    County := Vendor.County;
                                                    "E-Mail" := Vendor."E-Mail";
#pragma warning disable AL0432
                                                    "Home Page" := Vendor."Home Page";
#pragma warning restore AL0432
                                                    "Primary Contact No." := Vendor."Primary Contact No.";

                                                    MODIFY;
                                                    Desplegar(Inter);
                                                    COMMIT;
                                                END;
                                            END;

                                        UNTIL Vendor.NEXT = 0;
                                end;
                            end;
                        UNTIL rEmpresa.NEXT = 0;
                END;
            }
        }
        addafter(Ficha)

        {
            action("&Desplegar")
            {
                ApplicationArea = All;
                Image = BOMLevel;
                ShortCutKey = F11;
                //CaptionML=ESP=Desplegar;
                trigger OnAction()
                VAR
                    rEmpresa: Record 2000000006;
                    Customer: Record Customer;
                    Vendor: Record Vendor;
                    RxE: Record "Intercambio x Empresa";
                    Cli: Code[20];
                    Prov: Code[20];
                BEGIN
                    Desplegar(Rec);
                END;
            }
        }
    }
    PROCEDURE Desplegar(VAR Inter: Record Intercambio);
    VAR
        rEmpresa: Record Company;
        rEmp: Record "Company Information";
        Customer: Record Customer;
        Vendor: Record Vendor;
        RxE: Record 7001119;
        Cli: Code[20];
        Prov: Code[20];
        Control: Codeunit ControlProcesos;
    BEGIN
        //rEmpresa.SETFILTER(rEmpresa."Clave Recursos",'<>%1','');
        rEmpresa.SetRange("Evaluation Company", false);
        if rEmpresa.FINDFIRST THEN
            REPEAT
                if Control.Permiso_Empresas(rEmpresa.Name) then begin
                    rEmp.ChangeCompany((rEmpresa.Name));
                    if not rEmp.get() then rEmp.Init();
                    ;
                    if rEmp."Clave Recursos" <> '' Then begin
                        Customer.CHANGECOMPANY(rEmpresa.Name);
                        Vendor.CHANGECOMPANY(rEmpresa.Name);
                        WITH Inter DO BEGIN
                            Customer.SETRANGE("VAT Registration No.", "VAT Registration No.");
                            if NOT Customer.FINDFIRST THEN Cli := '' ELSE Cli := Customer."No.";
                            Vendor.SETRANGE("VAT Registration No.", "VAT Registration No.");
                            if NOT Vendor.FINDFIRST THEN Prov := '' ELSE Prov := Vendor."No.";
                            if RxE.GET("No.", rEmpresa.Name) THEN RxE.DELETE;
                            RxE.INIT;
                            RxE.Empresa := rEmpresa.Name;
                            RxE."Código Intercambio" := "No.";
                            RxE.Cliente := Cli;
                            RxE.Proveedor := Prov;
                            if (Cli <> '') OR (Prov <> '') THEN
                                RxE.INSERT;
                        END;
                    End;
                end;
            UNTIL rEmpresa.NEXT = 0;
    END;
}