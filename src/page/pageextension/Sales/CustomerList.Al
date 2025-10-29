/// <summary>
/// PageExtension CustomerList (ID 80135) extends Record Customer List.
/// </summary>
pageextension 80135 CustomerList extends "Customer List"
{
    layout
    {
        addafter(Name)
        {
            field("Tipo Cliente"; Rec."Tipo Cliente")
            {
                ApplicationArea = All;
            }
            field("VAT Registration No."; Rec."VAT Registration No.")
            {
                ApplicationArea = all;
            }
            field("Payment Method Code"; Rec."Payment Method Code")
            {
                ApplicationArea = All;
            }
            field("Banco transferencia"; Rec."Banco transferencia")
            {
                ApplicationArea = All;
                Caption = 'Bancos transferencia';
                ToolTip = 'Separados por | \ Por ejemplo: \ 57200001|57200002';
                trigger OnLookup(var Texxt: Text): Boolean
                VAR
                    B: Text[250];
                    Bancos: Record 270;
                BEGIN
                    B := Rec."Banco transferencia";
                    if (STRLEN(B) <> 0) THEN
                        if (COPYSTR(B, STRLEN(B), 1) <> '|') THEN B := B + '|';
                    if Page.RUNMODAL(0, Bancos) = ACTION::LookupOK THEN
                        Rec."Banco transferencia" := B + Bancos."No.";
                END;
            }
        }
        addbefore("Customer Posting Group")
        {
            field("Cod cadena"; Rec."Cod cadena")
            {
                ApplicationArea = all;
            }
        }
    }
    actions
    {
        addfirst("&Customer")
        {
            action("Crear Cliente")
            {
                ApplicationArea = All;
                Image = NewCustomer;
                ShortcutKey = 'Ctrl+N';
                trigger OnAction()
                var
                    Res: Record Customer temporary;
                    Asis: Page "Wizard Clientes";
                begin
                    Res.Init();
                    Asis.Carga();
                    Asis.RunModal();

                end;
            }
        }
        addafter("Service &Items")
        {
            action("Clientes erróneos")
            {
                ApplicationArea = all;
                Scope = Repeater;
                Image = ErrorLog;
                trigger OnAction()
                var
                    rCust: Record Customer;
                begin
                    Rec.CLEARMARKS;
                    if rCust.FINDFIRST THEN
                        REPEAT
                            if COMPANYNAME in [glUnion, glUATI] THEN BEGIN

                                rCust.CALCFIELDS(rCust."Net Change (LCY)", rCust."Saldo en Contab UAT", rCust."Saldo real (DL)");
                                if (ABS(rCust."Net Change (LCY)" - rCust."Saldo en Contab UAT") > 1) OR
                                (ABS(rCust."Saldo en Contab UAT" - rCust."Saldo real (DL)") > 1) OR
                                (ABS(rCust."Saldo real (DL)" - rCust."Net Change (LCY)") > 1)
                                THEN BEGIN
                                    Rec.GET(rCust."No.");
                                    Rec.MARK := TRUE;
                                END;

                            END ELSE BEGIN
                                rCust.CALCFIELDS(rCust."Net Change (LCY)", rCust."Saldo en Contab", rCust."Saldo real (DL)");
                                if (ABS(rCust."Net Change (LCY)" - rCust."Saldo en Contab") > 1) OR
                                (ABS(rCust."Saldo en Contab" - rCust."Saldo real (DL)") > 1) OR
                                (ABS(rCust."Saldo real (DL)" - rCust."Net Change (LCY)") > 1)
                                THEN BEGIN
                                    Rec.GET(rCust."No.");
                                    Rec.MARK := TRUE;
                                END;
                            END;
                        UNTIL rCust.NEXT = 0;
                    Rec.MARKEDONLY := TRUE;
                end;
            }
            // action("Cargar datos Face")
            // {
            //     Image = ImportCodes;
            //     ApplicationArea = all;
            //     trigger OnAction()
            //     var
            //         Centros: Record "B2R Centros Admin.";
            //         Cli: Record Customer;
            //         Ship: Record "Ship-to Address";
            //     begin
            //         Ship.SetFilter("Oficina Contable", '<>%1', '');
            //         if Ship.FindFirst() Then
            //             repeat
            //                 if Not Centros.Get(Centros."Tipo Centro"::"01", Ship."Oficina Contable") then begin
            //                     Centros.Init();
            //                     Centros."Tipo Centro" := Centros."Tipo Centro"::"01";
            //                     Centros."Cód. Centro" := Ship."Oficina Contable";
            //                     Centros."C.P." := Ship."Post Code";
            //                     Centros."Dirección" := Ship.Address;
            //                     Centros."Población" := Ship.City;
            //                     Centros.Provincia := Ship.County;
            //                     Centros."Cód. Pais" := Ship."Country/Region Code";
            //                     Centros.Insert();
            //                 end;
            //                 if Not Centros.Get(Centros."Tipo Centro"::"02", Ship."Organo Gestor") then begin
            //                     Centros.Init();
            //                     Centros."Tipo Centro" := Centros."Tipo Centro"::"02";
            //                     Centros."Cód. Centro" := Ship."Organo Gestor";
            //                     Centros."C.P." := Ship."Post Code";
            //                     Centros."Dirección" := Ship.Address;
            //                     Centros."Población" := Ship.City;
            //                     Centros.Provincia := Ship.County;
            //                     Centros."Cód. Pais" := Ship."Country/Region Code";
            //                     Centros.Insert();
            //                 end;
            //                 if Not Centros.Get(Centros."Tipo Centro"::"03", Ship."Unidad tramitadora") then begin
            //                     Centros.Init();
            //                     Centros."Tipo Centro" := Centros."Tipo Centro"::"03";
            //                     Centros."Cód. Centro" := Ship."Unidad tramitadora";
            //                     Centros."C.P." := Ship."Post Code";
            //                     Centros."Dirección" := Ship.Address;
            //                     Centros."Población" := Ship.City;
            //                     Centros.Provincia := Ship.County;
            //                     Centros."Cód. Pais" := Ship."Country/Region Code";
            //                     Centros.Insert();
            //                 end;
            //                 Ship.Validate("B2R Facturación electrónica", true);
            //                 Ship.Validate("B2R Cod. Fiscal", Ship."Oficina Contable");
            //                 Ship.Validate("B2R Cod. Receptor", Ship."Organo Gestor");
            //                 Ship.Validate("B2R Cod. Pagador", Ship."Unidad tramitadora");
            //                 Ship.Modify();
            //             Until Ship.next = 0;
            //         Cli.SetFilter("Oficina Contable", '<>%1', '');
            //         if Cli.FindFirst() Then
            //             repeat
            //                 if Not Centros.Get(Centros."Tipo Centro"::"01", Cli."Oficina Contable") then begin
            //                     Centros.Init();
            //                     Centros."Tipo Centro" := Centros."Tipo Centro"::"01";
            //                     Centros."Cód. Centro" := Cli."Oficina Contable";
            //                     Centros."C.P." := Cli."Post Code";
            //                     Centros."Dirección" := Cli.Address;
            //                     Centros."Población" := cli.City;
            //                     Centros.Provincia := Cli.County;
            //                     Centros."Cód. Pais" := Cli."Country/Region Code";
            //                     Centros.Insert();
            //                 end;
            //                 if Not Centros.Get(Centros."Tipo Centro"::"02", Cli."Organo Gestor") then begin
            //                     Centros.Init();
            //                     Centros."Tipo Centro" := Centros."Tipo Centro"::"02";
            //                     Centros."Cód. Centro" := Cli."Organo Gestor";
            //                     Centros."C.P." := Cli."Post Code";
            //                     Centros."Dirección" := Cli.Address;
            //                     Centros."Población" := cli.City;
            //                     Centros.Provincia := Cli.County;
            //                     Centros."Cód. Pais" := Cli."Country/Region Code";
            //                     Centros.Insert();
            //                 end;
            //                 if Not Centros.Get(Centros."Tipo Centro"::"03", Cli."Unidad tramitadora") then begin
            //                     Centros.Init();
            //                     Centros."Tipo Centro" := Centros."Tipo Centro"::"03";
            //                     Centros."Cód. Centro" := Cli."Unidad tramitadora";
            //                     Centros."C.P." := Cli."Post Code";
            //                     Centros."Dirección" := Cli.Address;
            //                     Centros."Población" := cli.City;
            //                     Centros.Provincia := Cli.County;
            //                     Centros."Cód. Pais" := Cli."Country/Region Code";
            //                     Centros.Insert();
            //                 end;
            //                 Cli.Validate("B2R Facturación electrónica", true);
            //                 Cli.Validate("B2R Cod. Fiscal", cli."Oficina Contable");
            //                 Cli.Validate("B2R Cod. Receptor", cli."Organo Gestor");
            //                 Cli.Validate("B2R Cod. Pagador", Cli."Unidad tramitadora");
            //                 Cli.Modify();
            //             Until Cli.next = 0;
            //     end;

            // }
            action("Liquidar facturas borrador")
            {
                Image = ApplyEntries;
                ApplicationArea = all;
                Scope = Repeater;
                trigger OnAction()
                var
                    Controldeprocesos: Codeunit ControlProcesos;
                begin
                    Controldeprocesos.LiquidarFacturas();
                end;
            }
            action("Marcar para listado")
            {
                ApplicationArea = all;
                Image = MakeOrder;
                trigger OnAction()
                var
                    rCust: Record Customer;
                begin
                    rCust.ModifyAll(Listado, false);
                    CurrPage.SetSelectionFilter(rCust);
                    rCust.ModifyAll(Listado, true);
                end;
            }
        }
        addlast("&Customer")
        {
            action("Anotaciones")
            {
                ApplicationArea = All;
                Image = Notes;
                Caption = 'Anotaciones';
                RunObject = Page 124;
                RunPageLink = "Table Name" = CONST(Anotaciones),
                             "No." = FIELD("No."), Proveedor = const(false);
            }
        }
        addfirst(Promoted)
        {
            actionref("Crear Cliente_Promoted"; "Crear Cliente") { }
            actionref("Anotaciones_Ref"; "Anotaciones") { }
        }
    }
    var
        glUnion: Label 'UNION AGRICOLA Y TURISTICA, SL';
        glUATI: Label 'UATI';
}