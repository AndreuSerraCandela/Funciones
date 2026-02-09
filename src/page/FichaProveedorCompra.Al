/// <summary>
/// Page Ficha Proveedor Compra (ID 50050).
/// </summary>
page 50050 "Ficha Proveedor Compra"
{

    Caption = 'Ficha Proveedor Compra';
    PageType = Card;
    SourceTable = "Proveedores Compra";

    layout
    {
        area(content)
        {
            group(General)
            {
                field("No."; Rec."No.")
                {
                    ToolTip = 'Specifies the value of the No. field';
                    ApplicationArea = All;
                }
                field(Name; Rec.Name)
                {
                    ToolTip = 'Specifies the value of the Name field';
                    ApplicationArea = All;
                }
                field("Name 2"; Rec."Name 2")
                {
                    ToolTip = 'Specifies the value of the Name 2 field';
                    ApplicationArea = All;
                }
                field(Address; Rec.Address)
                {
                    ToolTip = 'Specifies the value of the Address field';
                    ApplicationArea = All;
                }
                field("Address 2"; Rec."Address 2")
                {
                    ToolTip = 'Specifies the value of the Address 2 field';
                    ApplicationArea = All;
                }
                field("Post Code"; Rec."Post Code")
                {
                    ToolTip = 'Specifies the value of the Post Code field';
                    ApplicationArea = All;
                }
                field(City; Rec.City)
                {
                    ToolTip = 'Specifies the value of the City field';
                    ApplicationArea = All;
                }
                field(County; Rec.County)
                {
                    ToolTip = 'Specifies the value of the County field';
                    ApplicationArea = All;
                }
                field("Country/Region Code"; Rec."Country/Region Code")
                {
                    ToolTip = 'Specifies the value of the Country/Region Code field';
                    ApplicationArea = All;
                }
                field("Phone No."; Rec."Phone No.")
                {
                    ToolTip = 'Specifies the value of the Phone No. field';
                    ApplicationArea = All;
                }
                field("Primary Contact No."; Rec."Primary Contact No.")
                {
                    ToolTip = 'Specifies the value of the Primary Contact No. field';
                    ApplicationArea = All;
                }
                field(Contact; Rec.Contact)
                {
                    ToolTip = 'Specifies the value of the Contact field';
                    ApplicationArea = All;
                }
                field("VAT Registration No."; Rec."VAT Registration No.")
                {
                    ToolTip = 'Specifies the value of the VAT Registration No. field';
                    ApplicationArea = All;
                }
                field("Search Name"; Rec."Search Name")
                {
                    ToolTip = 'Specifies the value of the Search Name field';
                    ApplicationArea = All;
                }
                field("Salesperson Code"; Rec."Salesperson Code")
                {
                    ToolTip = 'Specifies the value of the Salesperson Code field';
                    ApplicationArea = All;
                }
                field(Blocked; Rec.Blocked)
                {
                    ToolTip = 'Specifies the value of the Blocked field';
                    ApplicationArea = All;
                }
                field("Last Date Modified"; Rec."Last Date Modified")
                {
                    ToolTip = 'Specifies the value of the Last Date Modified field';
                    ApplicationArea = All;
                }
            }
            part(Lineas; "Proveedores x Empresa")
            {
                SubpageLink = "Código Proveedor" = FIELD("No."),
                "Date Filter" = FIELD("Date Filter");
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action("Ficha")
            {
                ApplicationArea = All;
                Image = List;
                ShortCutKey = 'Mayús+F5';
                //       CaptionML=ESP=Ficha;
                RunObject = Page "Ficha Intercambio";
                RunPageLink = "No." = FIELD("No.");
            }
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
                    RxE: Record "Proveedores x Empresa";
                    Cli: Code[20];
                    Prov: Code[20];

                BEGIN
                    Desplegar(Rec);
                END;
            }
            action("&Ver Provee x Empresa")
            {
                ApplicationArea = All;
                Image = Find;
                //CaptionML=ESP=Ver Clientes/Provee x Empresa;
                trigger OnAction()
                VAR
                    RxE: Record "Proveedores x Empresa";
                BEGIN
                    RxE.SETRANGE(RxE."Código Proveedor", Rec."No.");
                    Page.RUNMODAL(Page::"Proveedores x Empresa", RxE);
                END;
            }
            action("Copiar &Datos del Proveedor")
            {
                ApplicationArea = All;
                ShortCutKey = F6;
                Image = Copy;
                //CaptionML=ESP=Copiar Datos del cliente;
                trigger OnAction()
                VAR
                    Customer: Record Vendor;
                BEGIN
                    if Page.RUNMODAL(0, Customer) = ACTION::LookupOK THEN BEGIN
                        //"No.":=Customer."No.";
                        if Rec."No." = '' THEN Rec.INSERT(TRUE);
                        //"Search Name":=Customer."Search Name";
                        Rec.Name := Customer.Name;
                        Rec."Name 2" := Customer."Name 2";
                        Rec.Address := Customer.Address;
                        Rec."Address 2" := Customer."Address 2";
                        Rec.City := Customer.City;
                        Rec.Contact := Customer.Contact;
                        Rec."Phone No." := Customer."Phone No.";
                        Rec."Telex No." := Customer."Telex No.";
                        Rec."Our Account No." := Customer."Our Account No.";
                        Rec."Territory Code" := Customer."Territory Code";
                        Rec."Global Dimension 1 Code" := Customer."Global Dimension 1 Code";
                        Rec."Global Dimension 2 Code" := Customer."Global Dimension 2 Code";
                        Rec."Budgeted Amount" := Customer."Budgeted Amount";
                        Rec."Currency Code" := Customer."Currency Code";
                        Rec."Payment Terms Code" := Customer."Payment Terms Code";
                        Rec."Shipment Method Code" := Customer."Shipment Method Code";
                        Rec."Shipping Agent Code" := Customer."Shipping Agent Code";
                        Rec."Country/Region Code" := Customer."Country/Region Code";
                        Rec.Blocked := Customer.Blocked;
                        Rec."Payment Method Code" := Customer."Payment Method Code";
                        Rec."Last Date Modified" := Customer."Last Date Modified";
                        Rec."Fax No." := Customer."Fax No.";
                        Rec."VAT Registration No." := Customer."VAT Registration No.";
                        Rec."Post Code" := Customer."Post Code";
                        Rec.County := Customer.County;
                        Rec."E-Mail" := Customer."E-Mail";
#if CLEAN24
#pragma warning disable AL0432
                        Rec."Home Page" := Customer."Home Page";
#pragma warning restore AL0432
#else
#pragma warning disable AL0432
                        Rec."Home Page" := Customer."Home Page";
#endif
                        Rec."Primary Contact No." := Customer."Primary Contact No.";

                        Rec.MODIFY;
                    END;
                END;
            }

            action("Ver Detalle &Todos")
            {
                ApplicationArea = All;
                Image = AllLines;
                // PushAction=RunObject;                // CaptionML=ESP=Ver Detalle Todos;
                RunObject = Page "Proveedores x Empresa";
            }
            action("Crear Grupo Compras")
            {
                ApplicationArea = All;
                Image = Company;
                trigger OnAction()
                var
                    Gr: Record "Grupo de empresas";
                    EmpGr: Record "Empresa grupo";
                begin
                    if not Gr.Get('COMPRAS', 'Grupo Compras') Then begin
                        Gr.Codigo := 'COMPRAS';
                        Gr.Descripcion := 'Grupo Compras';
                        Gr.Insert();
                        Commit();
                    end;
                    EmpGr.SetRange("Cod. grupo", 'COMPRAS');
                    Page.RunModal(0, EmpGr);
                end;
            }
        }
    }


    PROCEDURE Desplegar(VAR Inter: Record "Proveedores Compra");
    VAR
        rEmpresa: Record Company;
        Vendor: Record Vendor;
        RxE: Record "Proveedores x Empresa";
        Cli: Code[20];
        Prov: Code[20];
        Control: Codeunit ControlProcesos;
    BEGIN
        //rEmpresa.SETFILTER(rEmpresa."Clave Recursos",'<>%1','');
        rEmpresa.SetRange("Evaluation Company", false);
        if rEmpresa.FINDFIRST THEN
            REPEAT
                if Control.Permiso_Empresas(rEmpresa.Name) then begin


                    Vendor.CHANGECOMPANY(rEmpresa.Name);
                    WITH Inter DO BEGIN
                        Vendor.SETRANGE("VAT Registration No.", "VAT Registration No.");
                        if NOT Vendor.FINDFIRST THEN Prov := '' ELSE Prov := Vendor."No.";
                        if RxE.GET("No.", rEmpresa.Name) THEN RxE.DELETE;
                        RxE.INIT;
                        RxE.Empresa := rEmpresa.Name;
                        RxE."Código proveedor" := "No.";
                        RxE.Proveedor := Prov;
                        if (Prov <> '') THEN
                            RxE.INSERT;
                    END;

                end;
            UNTIL rEmpresa.NEXT = 0;
    END;

}