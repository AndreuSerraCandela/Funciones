/// <summary>
/// Report Generacion Facturae (ID 50024).
/// </summary>
Report 50044 "Generacion Facturae"
{
    ObsoleteState = Pending;

    Permissions = TableData 112 = rimd;
    ProcessingOnly = true;
    UseRequestPage = false;

    DATASET
    {
        DataItem("Sales Invoice Header"; "Sales Invoice Header")
        {
            DataItemTableView = SORTING("No.");
            trigger OnAfterGetRecord()
            VAR
                //FileSystemObject@1170190008 : Automation "{420B2830-E718-11CF-893D-00A0C9054228} 1.0:{0D43FE01-F093-11CF-8940-00A0C9054228}:'Microsoft Scripting Runtime'.FileSystemObject";
                OStreamionFileName: Text[1024];
                DestinationFolderNae: Text[1024];
                FileToUpload: Text[124];
                FolderName: Text[1024];
                IStream: InStream;
                MagicPah: Text[1024];
                I: Integer;
                o: Boolean;
                nombreFichero: Text[250];
                DocumentAttachment: Record 1173;
                a: Integer;
                ShiptoAddress: Record 222;
            BEGIN
                //Error('Este procedimiento ya no puede usarse');
                if Gitipo = Gitipo::" " THEN
                    Gitipo := Gitipo::Facturae;
                Grecinfo.Get();
                Cust.Get("Bill-to Customer No.");
                if "Sales Invoice Header"."Ship-to Address" = '' THEN BEGIN
                    if Cust.GET("Bill-to Customer No.") THEN BEGIN
                        "Oficina contable" := Cust."Oficina Contable";
                        "Organo gestor" := Cust."Organo Gestor";
                        "Unidad tramitadora" := Cust."Unidad tramitadora";
                        MODIFY;
                    END;
                END ELSE BEGIN
                    if ShiptoAddress.GET("Bill-to Customer No.", "Sales Invoice Header"."Ship-to Code") THEN BEGIN
                        "Oficina contable" := '';//ShiptoAddress."Oficina Contable";
                        "Organo gestor" := '';//ShiptoAddress."Organo Gestor";
                        "Unidad tramitadora" := '';// ShiptoAddress."Unidad tramitadora";
                        MODIFY;
                    END;
                END;
                if "Oficina contable" = '' Then begin
                    Cust.GET("Bill-to Customer No.");
                    "Oficina contable" := Cust."Oficina Contable";
                    "Organo gestor" := Cust."Organo Gestor";
                    "Unidad tramitadora" := Cust."Unidad tramitadora";
                    MODIFY;
                end;
                TestField("Oficina contable");
                TestField("Organo gestor");
                TestField("Unidad tramitadora");

                nombreFichero := CONVERTSTR("Sales Invoice Header"."No.", '\/.|', '____');
                Gtfile := nombreFichero;
                //FileMgt.SaveFileDialog(Text001, nombreFichero, Text002); //+001
                CALCFIELDS(Amount, "Amount Including VAT");
                CLEAR(Grecconf);
                Grecconf.GET;
                Giversion := Grecinfo."Versión efactura".AsInteger();
                CLEAR(Greccli);
                Greccli.GET("Bill-to Customer No.");
                if (Gitipo = Gitipo::Facturae) OR (Gitipo = Gitipo::PDF) THEN BEGIN
                    Gtfile2 := Gtfile;
                    Gtfile := Grecinfo."Direc. carpeta Efactura" + '\' + nombreFichero + '.XML';
                    // if Gitipo=Gitipo::PDF THEN BEGIN
                    //   if Grecconf."Firma eléctonica automática" THEN
                    //      Gtfile:=COPYSTR(Gtfile,1,STRLEN(Gtfile)-3)+'xsig'
                    //   ELSE
                    //      Gtfile:=COPYSTR(Gtfile,1,STRLEN(Gtfile)-3)+'XML';
                    // END;

                    if EXISTS(Gtfile) THEN
                        ERASE(Gtfile);
                    // if Grecconf."Tipo emisor factura" = Grecconf."Tipo emisor factura"::Tercero THEN BEGIN
                    //     Grecconf.TESTFIELD("Razón social/Nombre");
                    //     Grecconf.TESTFIELD(Dirección);
                    //     Grecconf.TESTFIELD("Código postal");
                    //     Grecconf.TESTFIELD(Población);
                    //     Grecconf.TESTFIELD(Provincia);
                    //     Grecconf.TESTFIELD("Cód. pais (ISO 3166-1_2006)");
                    //     Grecconf.TESTFIELD("NIF/Cif (2 letras de país)");
                    //     if Grecconf."Tipo persona" = Grecconf."Tipo persona"::Fisica THEN BEGIN
                    //         Grecconf.TESTFIELD("Primer apellido");
                    //         Grecconf.TESTFIELD("Segundo apellido");
                    //     END;
                    // END;
                    Grecinfo.GET;
                    Grecinfo.TESTFIELD(Address);
                    Grecinfo.TESTFIELD("Post Code");
                    Grecinfo.TESTFIELD(City);
                    Grecinfo.TESTFIELD(County);
                    CLEAR(Grecformapago);
                    Grecformapago.GET("Payment Method Code");
                    Grecformapago.TESTFIELD("Código Efactura");
                    if (Grecformapago."Código Efactura" = '04') OR
                    (Grecformapago."Código Efactura" = '02') THEN BEGIN
                        Grecformapago.TESTFIELD("Cód. banco Efactura");
                        Grecbank.GET(Grecformapago."Cód. banco Efactura");
                        Grecbank.TESTFIELD(IBAN);
                        Grecbank.TESTFIELD("CCC Bank Account No.");
                    END;

                    if Grecformapago."Código Efactura" = '02' Then BEGIN
                        "Sales Invoice Header".TESTFIELD("Cust. Bank Acc. Code");
                        Grecbank2.GET("Sales Invoice Header"."Bill-to Customer No.", "Sales Invoice Header"."Cust. Bank Acc. Code");
                        Grecbank.Init();
                        Grecbank.IBAN := Grecbank2.IBAN;
                        Grecbank."CCC No." := Grecbank2."CCC No.";
                        Grecbank."CCC Bank No." := Grecbank2."CCC Bank No.";
                        Grecbank."CCC Bank Branch No." := Grecbank2."CCC Bank Branch No.";
                    END;

                    //Transferencia
                    if Grecformapago."Código Efactura" = '04' Then BEGIN
                        //Si especificado banco a nivel de forma de pago.
                        if "Sales Invoice Header"."Nuestra Cuenta" <> '' THEN BEGIN
                            Grecbank.GET("Sales Invoice Header"."Nuestra Cuenta");
                            if Grecbank.IBAN = '' THEN BEGIN
                                if Grecbank."CCC No." <> '' THEN
                                    Grecbank.IBAN := Grecbank."CCC No."
                                ELSE
                                    Grecbank.TESTFIELD(IBAN);
                            END;
                        end;
                    END;

                    // En el caso de que no tenga ningún IVA la factura
                    if "Amount Including VAT" <> Amount THEN BEGIN
                        CLEAR(Gtreciva);
                        Gtreciva.DELETEALL;
                        CLEAR(Greciva);
                        Greciva.SETCURRENTKEY("Document No.");
                        Greciva.SETRANGE("Document No.", "No.");
                        Gii := 0;
                        Gdecbase := 0;
                        Gdeciva := 0;
                        Gdecret := 0;
                        if Greciva.FIND('-') THEN
                            REPEAT
                                CLEAR(Gtreciva);
                                Gtreciva.SETRANGE("VAT Calculation Type", Greciva."VAT Calculation Type");
                                Gtreciva.SETRANGE("VAT %", Greciva."VAT %");
                                if NOT Gtreciva.FIND('-') THEN BEGIN
                                    Gii += 1;
                                    Gtreciva."Entry No." := Gii;
                                    Gtreciva."VAT Calculation Type" := Greciva."VAT Calculation Type";
                                    Gtreciva."VAT %" := Greciva."VAT %";
                                    if Gtreciva."VAT %" = 0 THEN BEGIN
                                        if Grecconfiva.GET(Greciva."VAT Prod. Posting Group") THEN BEGIN
                                            Gtreciva."Internal Ref. No." := COPYSTR(Grecconfiva.Description, 1, 30);
                                        END;
                                    END;
                                    Gtreciva.INSERT;
                                END;
                                Gtreciva.Base += -(Greciva.Base + Greciva."Unrealized Base");
                                Gtreciva.Amount += -(Greciva.Amount + Greciva."Unrealized Amount");
                                Gtreciva.MODIFY;
                                Gdecbase += -(Greciva.Base + Greciva."Unrealized Base");
                                Gdeciva += -(Greciva.Amount + Greciva."Unrealized Amount");
                            UNTIL Greciva.NEXT = 0;
                        if "Amount Including VAT" <> Gdecbase + Gdeciva THEN
                            ERROR('El total de la factura          #1###########\' +
                                    'no coincide con datos de IVA.   #2###########', "Amount Including VAT", Gdecbase + Gdeciva);
                        if Amount <> Gdecbase THEN
                            ERROR('La base imponible de la factura #1###########\' +
                                    'no coincide con datos de IVA.   #2###########', Amount, Gdecbase);
                    END;

                    //+001
                    // {
                    // CLEAR(Gfile);

                    // CREATE(Gfile);
                    // Gfile.Open;
                    // Gfile.Charset('UTF-8');
                    // }
                    FileName := Grecinfo."Direc. carpeta Efactura" + "Sales Invoice Header"."No." + '.xml';
                    // ArchSalida.CREATE(SrvFileName);
                    // ArchSalida.CREATEOUTSTREAM(os);
                    if ArchSalida.FindLast() Then
                        a := ArchSalida.Secuencia + 1;
                    ArchSalida.Init();
                    ArchSalida.Nueva := True;
                    ArchSalida.Secuencia := a;
                    ArchSalida."Nombre fichero" := FileName;
                    ArchSalida.Procesado := false;
                    ArchSalida.Proceso := 'Face';
                    ArchSalida.Insert(True);
                    ArchSalida.CalcFields(Fichero);
                    ArchSalida.Fichero.CreateOutStream(OS);

                    //-001

                    Gi('?xml version="1.0" encoding="UTF-8"?');
                    if Giversion = 2 THEN
                        Gi('fe:Facturae xmlns:fe="http://www.facturae.es/Facturae/2009/v3.2/Facturae" xmlns:ds="http://www.w3.org/2000/09/xmldsig#" xmlns:dentsu="http://www.edicomgroup.com/schemas/dentsu"')
                    ELSE
                        if Giversion = 1 THEN
                            Gi('fe:Facturae xmlns:fe="http://www.facturae.es/Facturae/2007/v3.1/Facturae" xmlns:ds="http://www.w3.org/2000/09/xmldsig#"')
                        ELSE
                            Gi('namespace:Facturae xmlns:namespace="http://www.facturae.es/Facturae/2007/v3.0/Facturae" ' +
                                'xmlns:namespace2="http://uri.etsi.org/01903/v1.2.2#" ' +
                                'xmlns:namespace3="http://www.w3.org/2000/09/xmldsig#"');
                    Gi('FileHeader');
                    if Giversion = 0 THEN
                        Gm('SchemaVersion', '3.0')
                    ELSE
                        if Giversion = 1 THEN
                            Gm('SchemaVersion', '3.1')
                        ELSE
                            Gm('SchemaVersion', '3.2');
                    Gm('Modality', 'I');
                    if True Then
                        //if Grecconf."Tipo emisor factura"=Grecconf."Tipo emisor factura"::Emisor THEN
                        Gm('InvoiceIssuerType', 'EM')
                    ELSE
                        if True Then //Grecconf."Tipo emisor factura"=Grecconf."Tipo emisor factura"::Receptor THEN
                            Gm('InvoiceIssuerType', 'RE')
                        ELSE BEGIN
                            Gm('InvoiceIssuerType', 'TE');
                            Gi('ThirdParty');
                            Gi('TaxIdentification');
                            if True Then //Grecconf."Tipo persona"=Grecconf."Tipo persona"::Juridica THEN
                                Gm('PersonTypeCode', 'J')
                            ELSE
                                Gm('PersonTypeCode', 'P');
                            // CASE Grecconf."Identificación residencia" OF
                            // Grecconf."Identificación residencia"::Residente     : Gm('ResidenceTypeCode','R');
                            // Grecconf."Identificación residencia"::Extranjero    : Gm('ResidenceTypeCode','E');
                            // Grecconf."Identificación residencia"::"Residente UE": Gm('ResidenceTypeCode','U');
                            // END;
                            //Gm('TaxIdentificationNumber',Grecconf."NIF/Cif (2 letras de país)");
                            Gf('TaxIdentification');
                            // if Grecconf."Tipo persona"=Grecconf."Tipo persona"::Juridica THEN
                            //     BEGIN
                            //         Gi('LegalEntity');
                            //         Gm('CorporateName',Grecconf."Razón social/Nombre");
                            //         Gi('AddressInSpain');
                            //         Gm('Address',Grecconf.Dirección);
                            //         Gm('PostCode',Grecconf."Código postal");
                            //         Gm('Town',Grecconf.Población);
                            //         Gm('Province',Grecconf.Provincia);
                            //         Gm('CountryCode','ESP');
                            //         Gf('AddressInSpain');
                            //         if (Grecconf."Telefono contacto"<>'') OR
                            //             (Grecconf."Fáx contacto"<>'') OR
                            //             (Grecconf."Página Web contacto"<>'') OR
                            //             (Grecconf."Correo e contacto"<>'') OR
                            //             (Grecconf."Apellidos y Nombre contacto"<>'') OR
                            //             (Grecconf."CNO/CNAE contacto"<>'') OR
                            //             (Grecconf."Población INE contacto"<>'') OR
                            //             (Grecconf."Otros datos contacto"<>'') THEN
                            //         BEGIN
                            //             Gi('ContactDetails');
                            //             if Grecconf."Telefono contacto"<>'' THEN
                            //                 Gm('Telephone',Grecconf."Telefono contacto");
                            //             if Grecconf."Fáx contacto"<>'' THEN
                            //                 Gm('TeleFax',Grecconf."Fáx contacto");
                            //             if Grecconf."Página Web contacto"<>'' THEN
                            //                 Gm('WebAddress',Grecconf."Página Web contacto");
                            //             if Grecconf."Correo e contacto"<>'' THEN
                            //                 Gm('ElectronicMail',Grecconf."Correo e contacto");
                            //             if Grecconf."Apellidos y Nombre contacto"<>'' THEN
                            //                 Gm('ContactPersons',Grecconf."Apellidos y Nombre contacto");
                            //             if Grecconf."CNO/CNAE contacto"<>'' THEN
                            //                 Gm('CnoCnae',Grecconf."CNO/CNAE contacto");
                            //             if Grecconf."Población INE contacto"<>'' THEN
                            //                 Gm('INETownCode',Grecconf."Población INE contacto");
                            //             if Grecconf."Otros datos contacto"<>'' THEN
                            //                 Gm('AdditionalContactDetails',Grecconf."Otros datos contacto");
                            //             Gf('ContactDetails');
                            //         END;
                            //         Gf('LegalEntity');
                            //     END
                            // ELSE
                            //     BEGIN
                            //     Gi('Individual');
                            //     Gm('Name',Grecconf."Razón social/Nombre");
                            //     Gm('FirstSurname',Grecconf."Primer apellido");
                            //     Gm('SecondSurname',Grecconf."Segundo apellido");
                            //     Gi('AddressInSpain');
                            //         Gm('Address',Grecconf.Dirección);
                            //         Gm('PostCode',Grecconf."Código postal");
                            //         Gm('Town',Grecconf.Población);
                            //         Gm('Province',Grecconf.Provincia);
                            //         Gm('CountryCode','ESP');
                            //     Gf('AddressInSpain');
                            //     if (Grecconf."Telefono contacto"<>'') OR
                            //         (Grecconf."Fáx contacto"<>'') OR
                            //         (Grecconf."Página Web contacto"<>'') OR
                            //         (Grecconf."Correo e contacto"<>'') OR
                            //         (Grecconf."CNO/CNAE contacto"<>'') OR
                            //         (Grecconf."Población INE contacto"<>'') OR
                            //         (Grecconf."Apellidos y Nombre contacto"<>'') OR
                            //         (Grecconf."Otros datos contacto"<>'') THEN
                            //         BEGIN
                            //         Gi('ContactDetails');
                            //             if Grecconf."Telefono contacto"<>'' THEN
                            //             Gm('Telephone',Grecconf."Telefono contacto");
                            //             if Grecconf."Fáx contacto"<>'' THEN
                            //             Gm('TeleFax',Grecconf."Fáx contacto");
                            //             if Grecconf."Página Web contacto"<>'' THEN
                            //             Gm('WebAddress',Grecconf."Página Web contacto");
                            //             if Grecconf."Correo e contacto"<>'' THEN
                            //             Gm('ElectronicMail',Grecconf."Correo e contacto");
                            //             if Grecconf."Apellidos y Nombre contacto"<>'' THEN
                            //             Gm('ContactPersons',Grecconf."Apellidos y Nombre contacto");
                            //             if Grecconf."CNO/CNAE contacto"<>'' THEN
                            //             Gm('CnoCnae',Grecconf."CNO/CNAE contacto");
                            //             if Grecconf."Población INE contacto"<>'' THEN
                            //             Gm('INETownCode',Grecconf."Población INE contacto");
                            //             if Grecconf."Otros datos contacto"<>'' THEN
                            //             Gm('AdditionalContactDetails',Grecconf."Otros datos contacto");
                            //         Gf('ContactDetails');
                            //         END;
                            //     Gf('Individual');
                            // END;
                            Gf('ThirdParty');
                        END;
                    Gi('Batch');
                    Gm('BatchIdentifier', "No.");
                    Gm('InvoicesCount', '1');
                    Gdecret := 0;
                    Gi('TotalInvoicesAmount');
                    // En el caso de que no tenga ningún IVA la factura
                    if "Amount Including VAT" <> Amount THEN BEGIN
                        Gm('TotalAmount', Formato(Gdecbase + Gdeciva, 2));
                        Gf('TotalInvoicesAmount');
                        Gi('TotalOutstandingAmount');
                        Gm('TotalAmount', Formato(Gdecbase + Gdeciva, 2));
                        Gf('TotalOutstandingAmount');
                        Gi('TotalExecutableAmount');
                        Gm('TotalAmount', Formato(Gdecbase + Gdeciva - Gdecret, 2));
                    END ELSE BEGIN
                        Gm('TotalAmount', Formato("Amount Including VAT", 2));
                        Gf('TotalInvoicesAmount');
                        Gi('TotalOutstandingAmount');
                        Gm('TotalAmount', Formato("Amount Including VAT", 2));
                        Gf('TotalOutstandingAmount');
                        Gi('TotalExecutableAmount');
                        Gm('TotalAmount', Formato("Amount Including VAT", 2));
                    END;
                    Gf('TotalExecutableAmount');
                    Gm('InvoiceCurrencyCode', 'EUR');
                    Gf('Batch');
                    Gf('FileHeader');
                    Gi('Parties');
                    Gi('SellerParty');
                    Gi('TaxIdentification');
                    Gm('PersonTypeCode', 'J');
                    Gm('ResidenceTypeCode', 'R');
                    Gm('TaxIdentificationNumber', Grecinfo."VAT Registration No.");
                    Gf('TaxIdentification');
                    Gi('LegalEntity');
                    Gm('CorporateName', Grecinfo.Name);
                    Gi('AddressInSpain');
                    Gm('Address', Grecinfo.Address);
                    Gm('PostCode', Grecinfo."Post Code");
                    Gm('Town', Grecinfo.City);
                    Gm('Province', Grecinfo.County);
                    Gm('CountryCode', 'ESP');
                    Gf('AddressInSpain');
                    Gf('LegalEntity');
                    Gf('SellerParty');
                    Gi('BuyerParty');
                    Gi('TaxIdentification');
                    if STRPOS('1234567890', COPYSTR("VAT Registration No.", 1, 1)) = 0 THEN
                        Gm('PersonTypeCode', 'J')
                    ELSE
                        Gm('PersonTypeCode', 'F');
                    Gbespana := TRUE;
                    if ("Bill-to Country/Region Code" = '') OR ("Bill-to Country/Region Code" = 'ES') THEN
                        Gm('ResidenceTypeCode', 'R')
                    ELSE BEGIN
                        Gm('ResidenceTypeCode', 'U');
                        Gbespana := FALSE;
                    END;
                    Gm('TaxIdentificationNumber', "VAT Registration No.");
                    Gf('TaxIdentification');

                    if ("Oficina contable" <> '') OR ("Organo gestor" <> '') OR
                        ("Unidad tramitadora" <> '') THEN BEGIN

                        Gi('AdministrativeCentres');

                        if True THEN BEGIN
                            //if NOT Grecship.GET('', "Sales Invoice Header"."Oficina contable") THEN BEGIN
                            //  if NOT Grecship.GET("Sales Invoice Header"."Bill-to Customer No.", "Sales Invoice Header"."Ship-to Code") THEN BEGIN
                            Grecship.INIT;
                            Grecship.Address := Cust.Address;
                            Grecship."Post Code" := Cust."Post Code";
                            Grecship.City := Cust.City;
                            Grecship.County := Cust.County;
                            Grecship.TESTFIELD(Address);
                            Grecship.TESTFIELD("Post Code");
                            //END;
                            ///END;
                            Gi('AdministrativeCentre');
                            Gm('CentreCode', "Oficina contable");
                            Gm('RoleTypeCode', '01');
                            Gi('AddressInSpain');
                            Gm('Address', Grecship.Address);
                            Gm('PostCode', COPYSTR(Grecship."Post Code", 1, 5));
                            Gm('Town', Grecship.City);
                            Gm('Province', Grecship.County);
                            Gm('CountryCode', 'ESP');
                            Gf('AddressInSpain');
                            Gf('AdministrativeCentre');
                        END;

                        if True THEN BEGIN
                            //if NOT Grecship.GET('', "Sales Invoice Header"."Organo gestor") THEN BEGIN
                            //  if NOT Grecship.GET("Sales Invoice Header"."Bill-to Customer No.", "Sales Invoice Header"."Ship-to Code") THEN BEGIN
                            Grecship.INIT;
                            Grecship.Address := Cust.Address;
                            Grecship."Post Code" := Cust."Post Code";
                            Grecship.City := Cust.City;
                            Grecship.County := Cust.County;
                            Grecship.TESTFIELD(Address);
                            Grecship.TESTFIELD("Post Code");
                            //     END;
                            // END;
                            Grecship.TESTFIELD(Address);
                            Grecship.TESTFIELD("Post Code");
                            Gi('AdministrativeCentre');
                            Gm('CentreCode', "Organo gestor");
                            Gm('RoleTypeCode', '02');
                            Gi('AddressInSpain');
                            Gm('Address', Grecship.Address);
                            Gm('PostCode', COPYSTR(Grecship."Post Code", 1, 5));
                            Gm('Town', Grecship.City);
                            Gm('Province', Grecship.County);
                            Gm('CountryCode', 'ESP');
                            Gf('AddressInSpain');
                            Gf('AdministrativeCentre');
                        END;

                        if True THEN BEGIN
                            // if NOT Grecship.GET('', "Sales Invoice Header"."Unidad tramitadora") THEN BEGIN
                            //     if NOT Grecship.GET("Sales Invoice Header"."Bill-to Customer No.", "Sales Invoice Header"."Ship-to Code") THEN BEGIN
                            Grecship.INIT;
                            Grecship.Address := Cust.Address;
                            Grecship."Post Code" := Cust."Post Code";
                            Grecship.City := Cust.City;
                            Grecship.County := Cust.County;
                            Grecship.TESTFIELD(Address);
                            Grecship.TESTFIELD("Post Code");
                            //     END;
                            // END;
                            Grecship.TESTFIELD(Address);
                            Grecship.TESTFIELD("Post Code");
                            Gi('AdministrativeCentre');
                            Gm('CentreCode', "Unidad tramitadora");
                            Gm('RoleTypeCode', '03');
                            Gi('AddressInSpain');
                            Gm('Address', Grecship.Address);
                            Gm('PostCode', COPYSTR(Grecship."Post Code", 1, 5));
                            Gm('Town', Grecship.City);
                            Gm('Province', Grecship.County);
                            Gm('CountryCode', 'ESP');
                            Gf('AddressInSpain');
                            Gf('AdministrativeCentre');
                        END;

                        Gf('AdministrativeCentres');
                    END;

                    if STRPOS('1234567890', COPYSTR("VAT Registration No.", 1, 1)) = 0 THEN BEGIN
                        Gi('LegalEntity');
                        Gm('CorporateName', "Bill-to Name");
                        if Gbespana THEN BEGIN
                            Gi('AddressInSpain');
                            Gm('Address', "Bill-to Address");
                            Gm('PostCode', COPYSTR("Bill-to Post Code", 1, 5));
                            Gm('Town', "Bill-to City");
                            Gm('Province', "Bill-to County");
                            Gm('CountryCode', 'ESP');
                            Gf('AddressInSpain');
                        END
                        ELSE BEGIN
                            Gi('OverseasAddress');
                            Gm('Address', "Bill-to Address");
                            Gm('PostCodeAndTown', COPYSTR("Bill-to Post Code" + ' ' + "Bill-to City", 1, 50));
                            Gm('Province', "Bill-to County");
                            if "Bill-to Country/Region Code" = 'ES' THEN
                                Gm('CountryCode', 'ESP')
                            ELSE
                                Gm('CountryCode', "Bill-to Country/Region Code");
                            Gf('OverseasAddress');
                        END;
                        Gf('LegalEntity');
                    END
                    ELSE BEGIN
                        Gi('Individual');
                        if STRPOS("Bill-to Name", ' ') <> 0 THEN BEGIN
                            Gm('Name', COPYSTR("Bill-to Name", 1, STRPOS("Bill-to Name", ' ') - 1));
                            Gm('FirstSurname', COPYSTR("Bill-to Name", STRPOS("Bill-to Name", ' ') + 1));
                        END
                        ELSE BEGIN
                            Gm('Name', "Bill-to Name");
                            Gm('FirstSurname', ' ');
                        END;
                        if Gbespana THEN BEGIN
                            Gi('AddressInSpain');
                            Gm('Address', "Bill-to Address");
                            Gm('PostCode', COPYSTR("Bill-to Post Code", 1, 5));
                            Gm('Town', "Bill-to City");
                            Gm('Province', "Bill-to County");
                            Gm('CountryCode', 'ESP');
                            Gf('AddressInSpain');
                        END
                        ELSE BEGIN
                            Gi('OverseasAddress');
                            Gm('Address', "Bill-to Address");
                            Gm('PostCodeAndTown', COPYSTR("Bill-to Post Code" + ' ' + "Bill-to City", 1, 50));
                            Gm('Province', "Bill-to County");
                            if "Bill-to Country/Region Code" = 'ES' THEN
                                Gm('CountryCode', 'ESP')
                            ELSE
                                Gm('CountryCode', "Bill-to Country/Region Code");
                            Gf('OverseasAddress');
                        END;
                        Gf('Individual');
                    END;
                    Gf('BuyerParty');
                    Gf('Parties');
                    Gi('Invoices');
                    Gi('Invoice');
                    Gi('InvoiceHeader');
                    Gm('InvoiceNumber', "No.");
                    Gm('InvoiceDocumentType', 'FC');
                    Gm('InvoiceClass', 'OO');
                    Gf('InvoiceHeader');
                    Gi('InvoiceIssueData');
                    Gm('IssueDate', FORMAT(DATE2DMY("Posting Date", 3)) + '-' +
                                    COPYSTR(FORMAT("Posting Date"), 4, 2) + '-' + COPYSTR(FORMAT("Posting Date"), 1, 2));
                    Gm('InvoiceCurrencyCode', 'EUR');
                    Gm('TaxCurrencyCode', 'EUR');
                    Gm('LanguageName', 'es');
                    Gf('InvoiceIssueData');
                    Gi('TaxesOutputs');
                    Gii := 100;
                    CLEAR(Gtreciva);
                    if Gtreciva.FIND('-') THEN BEGIN
                        REPEAT
                            Gii += 1;
                            Gi('Tax');
                            Gm('TaxTypeCode', '01');
                            Gm('TaxRate', Formato(Gtreciva."VAT %", 2));
                            Gi('TaxableBase');
                            Gm('TotalAmount', Formato(Gtreciva.Base, 2));
                            Gf('TaxableBase');
                            Gi('TaxAmount');
                            Gm('TotalAmount', Formato(Gtreciva.Amount, 2));
                            Gf('TaxAmount');
                            Gf('Tax');
                        UNTIL Gtreciva.NEXT = 0;
                    END ELSE BEGIN
                        Gi('Tax');
                        Gm('TaxTypeCode', '01');
                        Gm('TaxRate', Formato(0, 2));
                        Gi('TaxableBase');
                        Gm('TotalAmount', Formato(Greclinea.Amount, 2));
                        Gf('TaxableBase');
                        Gi('TaxAmount');
                        Gm('TotalAmount', Formato(Greclinea."Amount Including VAT" - Greclinea.Amount, 2));
                        Gf('TaxAmount');
                        Gf('Tax');
                    END;
                    Gf('TaxesOutputs');
                    Gi('InvoiceTotals');
                    // En el caso de que no tenga ningún IVA la factura
                    if "Amount Including VAT" <> Amount THEN BEGIN
                        Gm('TotalGrossAmount', Formato(Gdecbase, 2));
                        Gm('TotalGrossAmountBeforeTaxes', Formato(Gdecbase, 2));
                        Gm('TotalTaxOutputs', Formato(Gdeciva, 2));
                        Gm('TotalTaxesWithheld', '0.00');
                        Gm('InvoiceTotal', Formato(Gdecbase + Gdeciva, 2));
                        Gm('TotalOutstandingAmount', Formato(Gdecbase + Gdeciva, 2));
                    END ELSE BEGIN
                        Gm('TotalGrossAmount', Formato(Amount, 2));
                        Gm('TotalGrossAmountBeforeTaxes', Formato(Amount, 2));
                        Gm('TotalTaxOutputs', Formato(0, 2));
                        Gm('TotalTaxesWithheld', '0.00');
                        Gm('InvoiceTotal', Formato("Amount Including VAT", 2));
                        Gm('TotalOutstandingAmount', Formato("Amount Including VAT", 2));
                    END;
                    if Gdecret <> 0 THEN BEGIN
                        Gi('AmountsWithheld');
                        Gm('WithholdingReason', 'Retención de garantia');
                        GdecRetencion := 0;
                        if Grecfp.GET("Payment Terms Code") THEN BEGIN
                            // {Grecfp.CALCFIELDS(Retención);
                            // if Grecfp.Retención THEN
                            // BEGIN
                            //     Grecnp.SETRANGE("Payment Terms Code","Payment Terms Code");
                            //     Grecnp.SETRANGE(Retención,TRUE);
                            //     if Grecnp.FIND('-') THEN
                            //     GdecRetencion := Grecnp."% of Total";
                            // END;}
                        END;
                        Gm('WithholdingRate', Formato(GdecRetencion, 4));
                        Gm('WithholdingAmount', Formato(Gdecret, 2));
                        Gf('AmountsWithheld');
                    END;
                    // En el caso de que no tenga ningún IVA la factura
                    if "Amount Including VAT" <> Amount THEN
                        Gm('TotalExecutableAmount', Formato(Gdecbase + Gdeciva - Gdecret, 2))
                    ELSE
                        Gm('TotalExecutableAmount', Formato("Amount Including VAT", 2));

                    Gf('InvoiceTotals');
                    Gi('Items');
                    CLEAR(Greclinea);
                    GreclineaT.SETRANGE("Document No.", "No.");
                    GreclineaT.SETFILTER(Quantity, '>%1', 0);
                    GreclineaT.FINDFIRST;
                    Greclinea := GreclineaT;
                    Greclinea.INSERT;
                    Greclinea."Unit Price" := Amount / Greclinea.Quantity;
                    Greclinea.Amount := Amount;
                    Greclinea."Amount Including VAT" := "Amount Including VAT";
                    Greclinea.MODIFY;
                    Greclinea.SETRANGE("Document No.", "No.");
                    if Greclinea.FIND('-') THEN
                        REPEAT
                            Gi('InvoiceLine');
                            if "Sales Invoice Header".GetWorkDescription() <> '' then
                                Gm('ItemDescription', "Sales Invoice Header".GetWorkDescription()) else
                                Gm('ItemDescription', Greclinea.Description + ' ' + "Posting Description");
                            Gm('Quantity', Formato(Greclinea.Quantity, 2));
                            if Greclinea.Quantity <> 0 THEN
                                Gm('UnitPriceWithoutTax', Formato(Greclinea.Amount / Greclinea.Quantity, 6))
                            ELSE
                                Gm('UnitPriceWithoutTax', Formato(Greclinea."Unit Price", 6));
                            if Giversion < 2 THEN
                                Gm('TotalCost', Formato(Greclinea.Amount, 2)) //2
                            ELSE
                                Gm('TotalCost', Formato(Greclinea.Amount, 6)); //2
                            Gi('DiscountsAndRebates');
                            Gi('Discount');
                            Gm('DiscountReason', 'Descuento cliente');
                            Gm('DiscountRate', '0.0000');
                            if Giversion < 2 THEN
                                Gm('DiscountAmount', '0.00') //6
                            ELSE
                                Gm('DiscountAmount', '0.000000'); //6
                            Gf('Discount');
                            Gf('DiscountsAndRebates');
                            if Giversion < 2 THEN
                                Gm('GrossAmount', Formato(Greclinea.Amount, 2)) //6
                            ELSE
                                Gm('GrossAmount', Formato(Greclinea.Amount, 6)); //6
                            CLEAR(Gtreciva);
                            Gtreciva.SETRANGE("VAT Calculation Type", Greclinea."VAT Calculation Type");
                            Gtreciva.SETRANGE("VAT %", Greclinea."VAT %");
                            if Greclinea.Type <> Greclinea.Type::" " THEN
                                if Gtreciva.FIND('-') THEN;
                            Gi('TaxesOutputs');
                            Gi('Tax');
                            Gm('TaxTypeCode', '01');
                            Gm('TaxRate', Formato(Gtreciva."VAT %", 2));
                            Gi('TaxableBase');
                            Gm('TotalAmount', Formato(Greclinea.Amount, 2));
                            Gf('TaxableBase');
                            Gi('TaxAmount');
                            Gm('TotalAmount', Formato(Greclinea."Amount Including VAT" - Greclinea.Amount, 2));
                            Gf('TaxAmount');
                            Gf('Tax');
                            Gf('TaxesOutputs');
                            Gi('Extensions');
                            Gi('dentsu:DentsuLineExtension');
                            //Gm('dentsu:CodigoMedio', CodigoMedio(Greclinea));
                            //Gm('dentsu:Anunciante', Anunciante(Greclinea));
                            //Gm('dentsu:CodigoDeAnunciante', CodigoDeAnunciante(Greclinea));
                            // Gm('dentsu:Soporte','XXXXXX');
                            // Gm('dentsu:Marca','XXXXX<');
                            // Gm('dentsu:FechaEmision','2020-12-28');
                            // Gm('dentsu:HoraEmision','09:48:25');
                            // Gm('dentsu:Publicacion','XXXX');
                            // Gm('dentsu:DetalleDePublicacion','XXXXXXXXXXXXX');
                            // Gm('dentsu:ReferenciaDelAnuncio','XXXXXXX');
                            // Gm('dentsu:Referencia2DelAnuncio','XXXXXXX');
                            // Gm('dentsu:Enviados','XXXX');
                            // Gm('dentsu:Producto','XXXX');
                            if Greclinea."Fecha inicial recurso" <> 0D Then
                                Gm('dentsu:InicioPeriodoDeFacturacion', Format(Greclinea."Fecha inicial recurso", 0, '<Year4>-<Month,2>-<Day,2>'));
                            if Greclinea."Fecha final recurso" <> 0D Then
                                Gm('dentsu:FinPeriodoDeFacturacion', Format(Greclinea."Fecha final recurso", 0, '<Year4>-<Month,2>-<Day,2>'));

                            // Gm('dentsu:UnidadDeMedida','XXXXX');
                            Gf('dentsu:DentsuLineExtension');
                            Gf('Extensions');
                            Gf('InvoiceLine');
                        UNTIL Greclinea.NEXT = 0;
                    Gf('Items');
                    Gi('PaymentDetails');
                    CLEAR(Grecret);
                    Grecret.SETCURRENTKEY("Document No.", "Document Type", "Customer No.");
                    Grecret.SETRANGE("Document No.", "No.");
                    Grecret.SETFILTER("Document Type", '%1|%2', Grecret."Document Type"::Bill, Grecret."Document Type"::Invoice);
                    Gdecret := 0;
                    Gii := 100;
                    if Grecret.FINDSET THEN
                        REPEAT
                            Grecret2 := Grecret;
                            Gbvencimiento := TRUE;
                            if Grecret2.NEXT <> 0 THEN BEGIN
                                if (Grecret2."Document No." = Grecret."Document No.") AND
                                    (COPYSTR(Grecret2.Description, 1, 17) = 'Convertir factura') THEN
                                    Gbvencimiento := FALSE;
                            END;
                            if Gbvencimiento THEN BEGIN
                                Gi('Installment');
                                Gm('InstallmentDueDate', FORMAT(DATE2DMY(Grecret."Due Date", 3)) + '-' + COPYSTR(FORMAT(Grecret."Due Date"), 4, 2) + '-' +
                                    COPYSTR(FORMAT(Grecret."Due Date"), 1, 2));
                                Grecret.CALCFIELDS(Amount);
                                Gm('InstallmentAmount', Formato(Grecret.Amount, 2));
                                Gm('PaymentMeans', Grecformapago."Código Efactura");
                                if Grecformapago."Código Efactura" = '04' THEN BEGIN
                                    Gi('AccountToBeCredited');
                                    Gm('IBAN', Grecbank.IBAN);
                                    //Gm('AccountNumber',Grecbank."CCC No.");
                                    Gm('BankCode', Grecbank."CCC Bank No.");
                                    Gm('BranchCode', Grecbank."CCC Bank Branch No.");
                                    // {Gi('BranchInSpainAddress');
                                    //     Gm('Address',Grecbank.Address);
                                    //     Gm('PostCode',Grecbank."Post Code");
                                    //     Gm('Town',Grecbank.City);
                                    //     Gm('Province',Grecbank.County);
                                    //     Gm('CountryCode','ESP');
                                    // Gf('BranchInSpainAddress');}
                                    Gf('AccountToBeCredited');
                                END;
                                if Grecformapago."Código Efactura" = '02' THEN BEGIN
                                    Gi('AccountToBeDebited');
                                    Gm('IBAN', Grecbank.IBAN);
                                    Gm('BankCode', Grecbank."CCC Bank No.");
                                    Gm('BranchCode', Grecbank."CCC Bank Branch No.");
                                    Gf('AccountToBeDebited');
                                END;
                                Gf('Installment');
                            END;
                        UNTIL Grecret.NEXT = 0;
                    Gf('PaymentDetails');
                    Gf('Invoice');
                    Gf('Invoices');
                    if Giversion <> 0 THEN
                        Gf('fe:Facturae')
                    ELSE
                        Gf('namespace:Facturae');

                    //+001
                    // {
                    // Gfile.SaveToFile(Gtfile,2);
                    // Gfile.Close;
                    // }
                    // ArchSalida.CLOSE;
                    // FileMgt.DownloadToFile(SrvFileName, Gtfile);
                    //-001

                    if Gitipo = Gitipo::PDF THEN BEGIN
                        Gttpdf := Gtfile;
                        Gtfile := Gtfile2;
                        Grecconf.TESTFIELD("Impresora PDF");
                        Grecconf2.GET;
                        Gtdirectorio := '';
                        Gtnombre := Gtfile;
                        if EXISTS(Gtfile) THEN BEGIN
                            ERASE(Gtfile);
                        END;

                        FOR Gii := STRLEN(Gtfile) DOWNTO 1 DO BEGIN
                            if COPYSTR(Gtfile, Gii, 1) = '\' THEN BEGIN
                                Gtdirectorio := COPYSTR(Gtfile, 1, Gii - 1);
                                Gtnombre := COPYSTR(Gtfile, Gii + 1);
                                Gii := -1;
                            END;
                        END;

                        // if ISCLEAR(GOCXPdf) THEN
                        //     CREATE(GOCXPdf,TRUE,TRUE);
                        // if ISCLEAR(GOCXPdfopt) THEN
                        // CREATE(GOCXPdfopt,TRUE,TRUE);
                        // if ISCLEAR(GOCXPdferror) THEN
                        // CREATE(GOCXPdferror,TRUE,TRUE);

                        // GOCXPdf.cStart;

                        // GOCXPdferror:=GOCXPdf.cError;
                        // GOCXPdfopt  :=GOCXPdf.cOptions;

                        // GOCXPdfopt.UseAutosave         :=1;
                        // GOCXPdfopt.UseAutosaveDirectory:=1;
                        // GOCXPdfopt.AutosaveDirectory   :=Gtdirectorio;
                        // GOCXPdfopt.AutosaveFormat      :=0;
                        // GOCXPdfopt.AutosaveFilename    :=Gtnombre;

                        // GOCXPdf.cOptions:=GOCXPdfopt;
                        // GOCXPdf.cClearCache;
                        // GOCXPdf.cDefaultPrinter:=Grecconf."Impresora PDF";
                        // GOCXPdf.cSaveOptions(GOCXPdfopt);
                        // GOCXPdf.cPrinterStop:=FALSE;



                        // PrintRecords(FALSE);

                        // GOCXPdf.cClearCache;
                        // GOCXPdf.cOptions:=GOCXPdfopt;
                        // if Grecconf."Segundos espera PDF"=0 THEN
                        // SLEEP(4000)
                        // ELSE
                        // SLEEP(Grecconf."Segundos espera PDF"*1000);
                        // GOCXPdf.cClose;
                        // if Grecconf."Segundos espera PDF"=0 THEN
                        // SLEEP(400)
                        // ELSE
                        // SLEEP(Grecconf."Segundos espera PDF"*100);
                        // CLEAR(GOCXPdf);
                        // CLEAR(GOCXPdfopt);

                    END;
                END;


                //+001
                // {
                // end
                // ELSE
                // if Gitipo=Gitipo::HTML THEN
                // BEGIN
                //     {if ("A repercutir") AND ("No. Series"=Grecconf2."Nº serie prefacturas IVA") THEN
                //     BEGIN
                //         Grecconf2.GET;
                //         Grecconf2.TESTFIELD("Nº doc. prefactura impresión");
                //         REPORT.SAVEASHTML(Grecconf2."Nº doc. prefactura impresión",Gtfile,FALSE,"Sales Invoice Header");
                //     END
                //     ELSE}
                //     BEGIN
                //         PrintRecordsHTML(Gtfile);
                //     END;
                // END;
                // }
                //-001

                if True Then //Grecconf."Firma eléctonica automática" THEN
                BEGIN
                    if Gitipo = Gitipo::Facturae THEN BEGIN
                        //+001 Libreria no valida para Nav2016, sustituida por una de fabricacion propia.
                        // {
                        //     CLEAR(GOCXFacturae);
                        //     CREATE(GOCXFacturae,TRUE,TRUE);

                        //     Grecconfg.TESTFIELD("Certificado digital");
                        //     GOCXFacturae.LoadCertificado(Grecconf."Certificado digital",Grecconf."Password certificado digital");
                        //     if ISSERVICETIER THEN BEGIN
                        //         DestinationFileName := 'C:\Facturae\newfile.txt';
                        //         FileVar.OPEN(Gtfile);
                        //         FileVar.CREATEINSTREAM(StreamVar);
                        //         DOWNLOADFROMSTREAM(StreamVar,'','<TEMP>',Text002,DestinationFileName);
                        //         FileVar.CLOSE;

                        //         GOCXFacturae.Firmar(DestinationFileName);
                        //         ERASE(Gtfile);

                        //         Gtfile := DestinationFileName;

                        //         CREATE(FileSystemObject,TRUE,TRUE);
                        //         FileSystemObject.CopyFile(Gtfile,FileName);
                        //     END ELSE
                        //         GOCXFacturae.Firmar(Gtfile);
                        // }
                        // { aFirmaDigital .nombreFicheroXML := Gtfile;
                        // aFirmaDigital.certificadopfx := Grecconf."Certificado digital";
                        // aFirmaDigital.passwordCertificado := Grecconf."Password certificado digital";
                        // aFirmaDigital.nombreFicheroSig := Gtfile; //sobreescribira el xml sin firma.
                        // ok := aFirmaDigital.firmarFacturae();}
                        //ERROR('%1 %2 %3',Gtfile,Grecconf."Directorio Facturae"+'\',Grecconf."Certificado digital");
                        RecRef.GetTable("Sales Invoice Header");
                        TM.Init();
                        TM.ID := CreateGuid();
                        TM.Description := StrSubstNo('Signature%1', format(CurrentDateTime));
                        TM."Mime Type" := 'Pdf/pdf';
                        TM."Company Name" := COMPANYNAME;
                        TM."File Name" := TM.Description + '.pdf';
                        TM.Height := 250;
                        TM.Width := 250;
                        TM.CalcFields(Content);
                        TM.Content.CreateOutStream(OutStrem);
                        REPORT.SaveAs(50023, '', ReportFormat::Pdf, OutStrem, Recref);
                        TM.Insert;
                        TM.CalcFields(Content);
                        TM.Content.CREATEINSTREAM(IStream);
                        // ArchSalida.Modify();
                        ArchSalida.CalcFields(Fichero);
                        //Base64String := TempBlob2.ToBase64String();//
                        Base64StringPDF := TempBlob2.ToBase64(IStream);
                        Clear(IStream);
                        ArchSalida.Fichero.CreateInStream(IStream);
                        Base64StringXML := TempBlob2.ToBase64(IStream);

                        //REPORT.SAVEASPDF(206, COPYSTR(Gtfile, 1, STRLEN(Gtfile) - 4) + '.pdf', "Sales Invoice Header");
                        ConfUser.Get(UserId);
                        ConfUser.CalcFields("Certificado firma Efactura");
                        Clear(IStream);
                        ConfUser."Certificado firma Efactura".CreateInStream(IStream);
                        Base64StringCER := TempBlob2.ToBase64(IStream);
                        JsonObj.WriteStartObject('');
                        // {
                        JsonObj.WriteStringProperty('xml', Base64StringXML);
                        JsonObj.WriteStringProperty('certificate', Base64StringCER);
                        JsonObj.WriteStringProperty('password', ConfUser."Password certificado digital");
                        //JsonObj.WriteStringProperty('SAVE_path', Grecinfo."c");
                        // }
                        JsonObj.WriteEndObject();
                        JsonText := JsonObj.GetJSonAsText();
                        Base64StringXsig := RestApi.RestApi('http://192.168.10.226:8082/api/xml/signXML', RequestType::post, JsonText);
                        Base64StringXsig := CopyStr(Base64StringXsig, 2, StrLen(Base64StringXsig) - 2);
                        if ArchSalidaXML.FindLast() Then a := ArchSalidaXML.Secuencia + 1;
                        FileName := Grecinfo."Direc. carpeta Efactura" + "Sales Invoice Header"."No." + '.xsig';
                        ArchSalidaXML.Init();
                        ArchSalidaXML.Nueva := True;
                        ArchSalidaXML.Secuencia := a;
                        ArchSalidaXML."Nombre fichero" := FileName;
                        ArchSalidaXML.Procesado := false;
                        ArchSalidaXML.Proceso := 'Face';
                        ArchSalidaXML.Insert(True);
                        ArchSalidaXML.CalcFields(Fichero);
                        Clear(OutStrem);
                        ArchSalidaXML.Fichero.CreateOutStream(OutStrem);
                        TempBlob2.FromBase64(Base64StringXsig, OutStrem);
                        ArchSalidaXML.Modify();
                        // tm.Insert();
                        // Tm.CalcFields(Content);
                        // Clear(IStream);
                        // TM.Content.CreateInStream(IStream);


                        // if DownloadFromStream(IStream, 'Fichero Firmado', 'C:\Temp', 'ALL Files (*.*)|*.*', FileName) then
                        // Commit();
                        // clear(Tm);
                        // Tm.Init();
                        // TM.ID := CreateGuid();
                        // TM.CalcFields(Content);
                        // Clear(OutStrem);
                        // TM.Content.CreateOutStream(OutStrem);
                        // TempBlob2.FromBase64(Base64StringPdf, OutStrem);
                        // tm.Insert();
                        // Tm.CalcFields(Content);
                        // Clear(IStream);
                        // TM.Content.CreateInStream(IStream);
                        if ArchSalidaPDf.FindLast() Then a := ArchSalidaXML.Secuencia + 1;
                        FileName := Grecinfo."Direc. carpeta Efactura" + "Sales Invoice Header"."No." + '.Pdf';
                        ArchSalidaPdf.Init();
                        ArchSalidaPdf.Nueva := True;
                        ArchSalidaPdf.Secuencia := a;
                        ArchSalidaPdf."Nombre fichero" := FileName;
                        ArchSalidaPdf.Procesado := false;
                        ArchSalidaPdf.Proceso := 'Face';
                        ArchSalidaPdf.Insert(True);
                        ArchSalidaPdf.CalcFields(Fichero);
                        Clear(OutStrem);
                        ArchSalidaPdf.Fichero.CreateOutStream(OutStrem);
                        TempBlob2.FromBase64(Base64StringPdf, OutStrem);
                        ArchSalidaPdf.Modify();
                        //if DownloadFromStream(IStream, 'Fichero Pdf', 'C:\Temp', 'ALL Files (*.*)|*.*', FileName) Then
                        Commit();
                        clear(Tm);
                        Tm.Init();
                        TM.ID := CreateGuid();
                        TM.CalcFields(Content);
                        Clear(OutStrem);
                        TM.Content.CreateOutStream(OutStrem);
                        TempBlob2.FromBase64(Base64StringXML, OutStrem);
                        tm.Insert();
                        Tm.CalcFields(Content);
                        Clear(IStream);
                        TM.Content.CreateInStream(IStream);
                        FileName := "Sales Invoice Header"."No." + '.xml';
                        DownloadFromStream(IStream, 'Fichero XmL', 'C:\Temp', 'ALL Files (*.*)|*.*', FileName);
                        // TM.Init();
                        // TM.ID := CreateGuid();
                        // TM.Description := StrSubstNo('Signature%1', format(CurrentDateTime));
                        // TM."Mime Type" := 'Pdf/pdf';
                        // TM."Company Name" := COMPANYNAME;
                        // TM."File Name" := TM.Description + '.pdf';
                        // TM.Height := 250;
                        // TM.Width := 250;
                        // TM.CalcFields(Content);
                        // TM.Content.CreateOutStream(OutStrem);
                        // REPORT.SaveAs(206, '', ReportFormat::Pdf, OutStrem, Recref);
                        // aFirmaDigital:=aFirmaDigital.UtilsXML();// .FirmaFactura();
                        // aFirmaDigital.FirmaryGuardarXML( ConfUser."Nombre certif. firma Efactura", ConfUser."Password certificado digital",Gtfile,COPYSTR(Gtfile,1,STRLEN(Gtfile)-4)+'.xsig');
                        //FileMgt.CopyClientFile(COPYSTR(Gtfile, 1, STRLEN(Gtfile) - 4) + '.xsig', COPYSTR(Gtfile2, 1, STRLEN(Gtfile2) - 4) + '.xsig', TRUE);
                        //FileMgt.CopyClientFile(COPYSTR(Gtfile, 1, STRLEN(Gtfile) - 4) + '.pdf', COPYSTR(Gtfile2, 1, STRLEN(Gtfile2) - 4) + '.pdf', TRUE);
                        DocumentAttachment.SETRANGE("Table ID", DATABASE::"Sales Invoice Header");
                        DocumentAttachment.SETRANGE("No.", "Sales Invoice Header"."No.");
                        a := 0;
                        // if DocumentAttachment.FINDFIRST THEN
                        //     REPEAT
                        //         a += 1;
                        //         DocumentAttachment."File Name" := COPYSTR(Gtfile2, 1, STRLEN(Gtfile2) - 4) + '-' + FORMAT(a);
                        //         FileMgt.CopyClientFile(DocumentAttachment.Export(FALSE), DocumentAttachment."File Name" + '.' + DocumentAttachment."File Extension", TRUE);
                        //     UNTIL DocumentAttachment.NEXT = 0;
                        //-001


                    END;
                    if Gitipo = Gitipo::PDF THEN BEGIN
                        // SLEEP(1000);
                        // CLEAR(GOCXPDFutil);
                        // CREATE(GOCXPDFutil,TRUE,TRUE);
                        // GOCXPDFutil.LoadPdfFile(Gtfile);
                        // if Grecconf."Firma eléctonica automática" THEN
                        //     Gtnombre:=COPYSTR(Gtnombre,1,STRLEN(Gtnombre)-3)+'xsig'
                        // ELSE
                        //     Gtnombre:=COPYSTR(Gtnombre,1,STRLEN(Gtnombre)-3)+'XML';
                        // GOCXPDFutil.AddAttachFile_2(Gttpdf,Gtnombre,'Facturae firmada');
                        // GOCXPDFutil.ProcesarAdjuntos;
                        // CLEAR(GOCXPDMetadata);
                        // CREATE(GOCXPDMetadata,TRUE,TRUE);
                        // if Grecconf."Tipo emisor factura"=Grecconf."Tipo emisor factura"::Tercero THEN
                        // BEGIN
                        //     GOCXPDMetadata.Author:=Grecconf."Razón social/Nombre";
                        //     GOCXPDMetadata.Subject:='Factura';
                        //     GOCXPDMetadata.Creator:=Grecconf."Razón social/Nombre";
                        //     GOCXPDMetadata.FirmaRazon:='Firmado';
                        // END
                        // ELSE
                        // BEGIN
                        //     GOCXPDMetadata.Author:=Grecinfo.Name;
                        //     GOCXPDMetadata.Subject:='Factura';
                        //     GOCXPDMetadata.Creator:=Grecinfo.Name;
                        //     GOCXPDMetadata.FirmaRazon:='Firmado';
                        // END;
                        // GOCXPDFutil.FirmaPdf(Grecconf."Certificado digital",Grecconf."Password certificado digital",GOCXPDMetadata);
                        // GOCXPDFutil.SaveToFile(Gtfile);
                        // CLEAR(GOCXPDFutil);
                        // CLEAR(GOCXPdf);
                    END;
                    if (Gitipo = Gitipo::HTML) THEN BEGIN
                        // {
                        // Grecconf.TESTFIELD("CIF/DNI/Nº certificado");
                        // CLEAR(GOCXFirmaX);
                        // GretOCXFirma:=COPYSTR(GOCXFirmaX.FIRMA(Gtfile,Grecconf."CIF/DNI/Nº certificado",Gtfile),1,1024);
                        // if COPYSTR(GretOCXFirma,1,2)<>'00' THEN
                        // BEGIN
                        //     ERASE(Gtfile);
                        //     ERROR('ERROR Facturae : '+GretOCXFirma);
                        // END;
                        // }
                    END;
                END;
                if EXISTS(Gttpdf) THEN
                    ERASE(Gttpdf);

                Gbemail := FALSE;
                if Greccli."E-Mail Efactura" <> '' Then // ."E-mail con Facturae"=Greccli."E-mail con Facturae"::"Por defecto" THEN
                 BEGIN
                    if Grecinfo."E-Mail efactura" <> '' Then// Grecconf.e- ."Envio e-mail por defecto" THEN
                        Gbemail := TRUE;
                END;
                //ELSE
                //if Greccli."E-mail con Facturae"=Greccli."E-mail con Facturae"::Sí THEN
                //  Gbemail:=TRUE;

                if Gbemail THEN BEGIN
                    //if ISSERVICETIER THEN
                    //  Email("Sales Invoice Header", FileName)
                    //ELSE
                    Email("Sales Invoice Header", Gtfile);
                END;

                if Gtfile <> '' THEN BEGIN
                    FIND;
                    // if Facturae<>Gtfile THEN
                    // BEGIN
                    //     if EXISTS(Facturae) THEN
                    //     ERASE(Facturae);
                    // END;
                    // "Tipo Facturae":=Gitipo;
                    //     if ISSERVICETIER THEN
                    //         Facturae:=FileName
                    //     ELSE
                    //         Facturae:=Gtfile;
                    MODIFY;
                END;

                //+001
                //Facturae := Gtfile;
                //"Tipo Facturae" := "Sales Invoice Header"."Tipo Facturae"::"Facturae XML";"Sales Invoice Header".
                "Situación Efactura" := "Situación Efactura"::"Enviada-Firmada";
                MODIFY;
                //"Sales Invoice Header"."Fichero Facturae" := GtFile;
                //-001

                FIND('+');
            END;
        }

    }
    REQUESTPAGE
    {

    }


    VAR
        Text001: Label 'Exportar a archivo XML';
        Text002: Label 'Archivos XML (*.xml)|*.xml|Todos los archivos (*.*)|*.*';
        Text003: Label 'Default.xml';
        Text006: Label 'Exportar';
        Text009: Label 'Todos los archivos (*.*)|*.*';
        Gtfile: Text;
        OutStrem: OutStream;
        Recref: RecordRef;
        TM: Record "Tenant Media" temporary;
        TMC: Record "Tenant Media Set";
        Base64StringXML: Text;
        Base64StringCER: Text;
        Base64StringXsig: Text;
        Base64StringPdf: Text;
        TempFile: File;
        TempBlob2: Codeunit "Base64 Convert";
        Grecfactura: Record 112;
        Grecinfo: Record 79;
        Gcu40: Codeunit 419;
        Gcfra: Code[20];
        Grecconf: Record 311;
        Grecret: Record 21;
        Gdecret: Decimal;
        Gbespana: Boolean;
        Gtreciva: Record 254 TEMPORARY;
        Greciva: Record 254;
        Gii: Integer;
        ConfUser: Record "User Setup";
        Grecconfiva: Record 324;
        Gdecbase: Decimal;
        Gdeciva: Decimal;
        Grecfp: Record 3;
        GdecRetencion: Decimal;
        Grecnp: Record 7000018;
        Greclinea: Record 113 TEMPORARY;
        GreclineaT: Record 113;
        Grecret2: Record 21;
        Gbvencimiento: Boolean;
        Grecformapago: Record 289;
        Gtrecformapago: Record 289 TEMPORARY;
        Grecbank: Record 270;
        Grecbank2: Record "Customer Bank Account";
        Giversion: Integer;
        GretOCXFirma: Text[1024];
        JsonObj: Codeunit "Json Text Reader/Writer";
        JsonText: Text;
        Gitipo: Option " ",Facturae,PDF,HTML;
        // GOCXFacturae : Automation "{ACB3B99E-D8E0-4C72-8FB4-A3AD79EAB289} 1.0:{7F344E8B-8D9C-3B96-8259-9C8934C201C4}:'GTFacturae'.Facturae";
        // GOCXPDFutil : Automation "{ACB3B99E-D8E0-4C72-8FB4-A3AD79EAB289} 1.0:{915ADEDC-6918-3FAF-A538-3E15A299A0B9}:'GTFacturae'.PdfUtil";
        // GOCXPdf : Automation "{1CE9DC08-9FBC-45C6-8A7C-4FE1E208A613} 7.1:{40108C54-9352-46C9-822C-027727352F00}:'PDFCreator'.clsPDFCreator";
        // GOCXPrinter : Automation "{F935DC20-1CF0-11D0-ADB9-00C04FD58A0B} 1.0:{093FF999-1EA0-4079-9525-9614C3504B74}:'Windows Script Host Object Model'.WshNetwork";
        Grecconf2: Record "General Ledger Setup";
        Gtext: Text[30];
        // GOCXPdfopt : Automation "{1CE9DC08-9FBC-45C6-8A7C-4FE1E208A613} 7.1:{FCC886F6-E0DF-4302-8BE4-F8A8D9CB881C}:'PDFCreator'.clsPDFCreatorOptions";
        // GOCXPdferror : Automation "{1CE9DC08-9FBC-45C6-8A7C-4FE1E208A613} 7.1:{84D26557-2990-4B3E-A99F-C4DC1CB6C225}:'PDFCreator'.clsPDFCreatorError";
        Gtdirectorio: Text[250];
        Gtnombre: Text[250];
        Gtfile2: Text[250];
        RestApi: Codeunit Restapi;
        RequestType: Option Get,patch,put,post,delete;
        Token: Text;
        Gttpdf: Text[250];
        // GOCXPDMetadata : Automation "{ACB3B99E-D8E0-4C72-8FB4-A3AD79EAB289} 1.0:{5102D725-41CE-3312-8A72-23A52143D016}:'GTFacturae'.PdfMetaData";
        Greccli: Record Customer;
        Gbemail: Boolean;
        Gtasunto: Text[250];
        Gtvalor: Text[250];
        Gipos: Integer;
        Gtlinea1: Text[250];
        Gtlinea2: Text[250];
        Gtlinea3: Text[250];
        Gtlinea4: Text[250];
        Gtlinea5: Text[250];
        Gtlinea6: Text[250];
        Gtlinea7: Text[250];
        Gtlinea8: Text[250];
        Gtlinea9: Text[250];
        Giultima: Integer;
        Gtcuerpo: Text[1024];
        Gtlinea: Text[250];
        Gcret13: Char;
        Gcret10: Char;
        Gtdir: Text[1024];
        Gtpdf: Text[1024];
        Gitimeout: Integer;
        Gffile: File;
        gins: InStream;
        Glinea: Text[1024];
        FileName: Text[250];
        FileVar: File;
        StreamVar: InStream;
        ExternalFile: Text[1024];
        FileMgt: Codeunit 419;
        FichCertTemp: Text[1024];
        Grecship: Record 222;
        os: OutStream;
        SrvFileName: Text[250];
        ArchSalida: Record Ficheros;
        ArchSalidaXML: Record Ficheros;
        ArchSalidaPDF: Record Ficheros;
        NewFileName: Text[1024];
        Cust: Record Customer;
        //aFirmaDigital : DotNet "'FirmaFactura, Version=2.0.0.0, Culture=neutral, PublicKeyToken=null'.FirmasXML.UtilsXML";
        Text010: Label 'Archivos XSIG (*.xsig)|*.xsig|Todos los archivos (*.*)|*.*';


    PROCEDURE Pfra(Pcfra: Code[20]; Ptipo: Integer);
    BEGIN
        Gcfra := Pcfra;
        Gitipo := Ptipo;
    END;

    PROCEDURE Gi(Ptext: Text[1024]);
    BEGIN
        //+001
        //+001
        //Gfile.WriteText('<'+Ptext+'>',1);
        os.WRITETEXT('<' + Ptext + '>');
        os.WRITETEXT();
        //-001
    END;

    PROCEDURE Gf(Ptext: Text[1024]);
    BEGIN
        //+001
        //Gfile.WriteText('</'+Ptext+'>',1);
        os.WRITETEXT('</' + Ptext + '>');
        os.WRITETEXT();
        //-001
    END;

    PROCEDURE Gm(Ptext: Text[1024]; Pvalor: Text[1024]);
    BEGIN
        Pvalor := ftCambiarCaracteres(Pvalor);
        //+001
        //Gfile.WriteText('<'+Ptext+'>'+Pvalor+'</'+Ptext+'>',1);
        os.WRITETEXT('<' + Ptext + '>' + Pvalor + '</' + Ptext + '>');
        os.WRITETEXT();
        //-001
    END;

    PROCEDURE ftCambiarCaracteres(ptCadena: Text[250]) rtCadenaRetorno: Text[250];
    VAR
        lcCodigoAscci: Char;
        ltCodigoFormateado: Text[1];
    BEGIN
        rtCadenaRetorno := ptCadena;
        lcCodigoAscci := 241;
        ltCodigoFormateado := FORMAT(lcCodigoAscci);
        rtCadenaRetorno := CONVERTSTR(rtCadenaRetorno, '¤', 'n');
        lcCodigoAscci := 209;
        ltCodigoFormateado := FORMAT(lcCodigoAscci);
        rtCadenaRetorno := CONVERTSTR(rtCadenaRetorno, '¥', 'N');
        lcCodigoAscci := 193;
        ltCodigoFormateado := FORMAT(lcCodigoAscci);
        rtCadenaRetorno := CONVERTSTR(rtCadenaRetorno, 'µ', 'A');
        lcCodigoAscci := 201;
        ltCodigoFormateado := FORMAT(lcCodigoAscci);
        rtCadenaRetorno := CONVERTSTR(rtCadenaRetorno, '', 'E');
        lcCodigoAscci := 205;
        ltCodigoFormateado := FORMAT(lcCodigoAscci);
        rtCadenaRetorno := CONVERTSTR(rtCadenaRetorno, 'Ö', 'I');
        lcCodigoAscci := 211;
        ltCodigoFormateado := FORMAT(lcCodigoAscci);
        rtCadenaRetorno := CONVERTSTR(rtCadenaRetorno, 'à', 'O');
        lcCodigoAscci := 218;
        ltCodigoFormateado := FORMAT(lcCodigoAscci);
        rtCadenaRetorno := CONVERTSTR(rtCadenaRetorno, 'é', 'U');
        lcCodigoAscci := 220;
        ltCodigoFormateado := FORMAT(lcCodigoAscci);
        rtCadenaRetorno := CONVERTSTR(rtCadenaRetorno, 'š', 'U');
        lcCodigoAscci := 225;
        ltCodigoFormateado := FORMAT(lcCodigoAscci);
        rtCadenaRetorno := CONVERTSTR(rtCadenaRetorno, ' ', 'a');
        lcCodigoAscci := 233;
        ltCodigoFormateado := FORMAT(lcCodigoAscci);
        rtCadenaRetorno := CONVERTSTR(rtCadenaRetorno, '‚', 'e');
        lcCodigoAscci := 237;
        ltCodigoFormateado := FORMAT(lcCodigoAscci);
        rtCadenaRetorno := CONVERTSTR(rtCadenaRetorno, '¡', 'i');
        lcCodigoAscci := 243;
        ltCodigoFormateado := FORMAT(lcCodigoAscci);
        rtCadenaRetorno := CONVERTSTR(rtCadenaRetorno, 'ó', 'o');
        lcCodigoAscci := 250;
        ltCodigoFormateado := FORMAT(lcCodigoAscci);
        rtCadenaRetorno := CONVERTSTR(rtCadenaRetorno, '£', 'u');
        lcCodigoAscci := 252;
        ltCodigoFormateado := FORMAT(lcCodigoAscci);
        rtCadenaRetorno := CONVERTSTR(rtCadenaRetorno, '', 'u');
        rtCadenaRetorno := CONVERTSTR(rtCadenaRetorno, '¦', '.');
        lcCodigoAscci := 186;
        ltCodigoFormateado := FORMAT(lcCodigoAscci);
        rtCadenaRetorno := CONVERTSTR(rtCadenaRetorno, 'º', '.');
    END;

    local procedure CodigoMedio(var Greclinea: Record "Sales Invoice Line" temporary): Text
    begin
        Error('Procedure CodigoMedio not implemented.');
    end;

    local procedure CodigoDeAnunciante(var Greclinea: Record "Sales Invoice Line" temporary): Text
    begin
        Error('Procedure CodigoDeAnunciante not implemented.');
    end;

    local procedure Anunciante(var Greclinea: Record "Sales Invoice Line" temporary): Text
    begin
        Error('Procedure Anunciante not implemented.');
    end;

    PROCEDURE Formato(Pdecvalor: Decimal; Pcprecision: Integer) Retvalor: Text[30];
    VAR
        Lcvalor: Code[100];
    BEGIN
        Lcvalor := FORMAT(Pdecvalor, 100, '<Precision,' + FORMAT(Pcprecision) + ':' + FORMAT(Pcprecision) + '><Standard Format,2>');
        Lcvalor := CONVERTSTR(Lcvalor, ',', '.');
        Retvalor := Lcvalor;
    END;

    PROCEDURE Pgennombre();
    VAR
        Lrecfra: Record 112;
        Lrecconf: Record 79;
    BEGIN
        CLEAR(Lrecconf);
        Lrecconf.GET;
        Lrecconf.TESTFIELD("Direc. carpeta Efactura");
        if Lrecconf."Direc. carpeta Efactura" <> '' THEN
            if COPYSTR(Lrecconf."Direc. carpeta Efactura", STRLEN(Lrecconf."Direc. carpeta Efactura"), 1) <> '\' THEN
                Lrecconf."Direc. carpeta Efactura" := Lrecconf."Direc. carpeta Efactura" + '\';
        if Lrecconf."Direc. carpeta Efactura" <> '' THEN BEGIN
            //Gcu40.Creadir(Lrecconf."Directorio Facturae");     //+001 Traspasado a codeunit 40
        END;

        if Lrecfra.GET(Gcfra) THEN;

        Gtdir := Lrecconf."Direc. carpeta Efactura";

        //if Lrecconf."Carpeta por Nº serie" THEN
        Gtdir += FORMAT(Lrecfra."No. Series") + '\';
        //if Lrecconf."Carpeta por a¤o" THEN
        //  Gtdir+=FORMAT(DATE2DMY(Lrecfra."Posting Date",3))+'\';
        //if Lrecconf."C<<<<<<<<<<<<<<<<<<<<<<arpeta por mes" THEN
        //  Gtdir+=COPYSTR(FORMAT(100+DATE2DMY(Lrecfra."Posting Date",2)),2)+'\';

        //Gcu40.Creadir(Gtdir);  //+001

        if Lrecfra.GET(Gcfra) THEN
            if Gitipo = Gitipo::Facturae THEN BEGIN
                if True Then // Lrecconf."Firma eléctonica automática" THEN
                    Gtext := '.xsig'
                ELSE
                    Gtext := '.XML'
            END ELSE
                if Gitipo = Gitipo::PDF THEN
                    Gtext := '.pdf'
                ELSE
                    if Gitipo = Gitipo::HTML THEN
                        Gtext := '.html';
        //if Lrecfra.GET(Gcfra) THEN
        //  Gtfile:=Lrecfra.Facturae;
        if (Gtfile = '') Then// OR (Gitipo<>Lrecfra."Tipo Facturae") THEN
            Gtfile := Gtdir + CONVERTSTR(Gcfra, '\/.|', '____') + Gtext;
    END;

    PROCEDURE Email(Prec: Record 112; Pfile: Text[250]);
    VAR
        LcuEmail: Codeunit 397;
        Lreccli: Record Customer;
    BEGIN
        if EXISTS(Pfile) THEN begin
            //ERROR('No existe fichero adjunto: %1.', CONVERTSTR(Pfile, '\', '/'));
            Prec.TESTFIELD(Prec."Bill-to Customer No.");
            CLEAR(Lreccli);
            Lreccli.GET(Prec."Bill-to Customer No.");

            Gtfile2 := '';

        end;
    END;

    PROCEDURE Ptransforma(Gtasunto: Text[250]; Prec: Record 112; Lreccli: Record 18) TRet: Text[250];
    BEGIN
        Gtasunto := Pcamcad(Gtasunto);
        Gipos := STRPOS(Gtasunto, '#');
        if Gipos <> 0 THEN BEGIN
            REPEAT
                Gtasunto := COPYSTR(Gtasunto, 1, Gipos - 1) + Prec."Bill-to Name" + COPYSTR(Gtasunto, Gipos + 1);
                Gipos := STRPOS(Gtasunto, '#');
            UNTIL Gipos = 0;
        END;
        Gipos := STRPOS(Gtasunto, '%');
        if Gipos <> 0 THEN BEGIN
            REPEAT
                Gtasunto := COPYSTR(Gtasunto, 1, Gipos - 1) + Prec."No." + COPYSTR(Gtasunto, Gipos + 1);
                Gipos := STRPOS(Gtasunto, '%');
            UNTIL Gipos = 0;
        END;
        Gipos := STRPOS(Gtasunto, '&');
        if Gipos <> 0 THEN BEGIN
            REPEAT
                Gtasunto := COPYSTR(Gtasunto, 1, Gipos - 1) + Lreccli.Contact + COPYSTR(Gtasunto, Gipos + 1);// +Lreccli."Contacto Facturae"+COPYSTR(Gtasunto,Gipos+1);
                Gipos := STRPOS(Gtasunto, '&');
            UNTIL Gipos = 0;
        END;
        Gipos := STRPOS(Gtasunto, '|');
        if Gipos <> 0 THEN BEGIN
            REPEAT
                Gtasunto := COPYSTR(Gtasunto, 1, Gipos - 1) + FORMAT(Prec."Posting Date") + COPYSTR(Gtasunto, Gipos + 1);
                Gipos := STRPOS(Gtasunto, '|');
            UNTIL Gipos = 0;
        END;
        Gipos := STRPOS(Gtasunto, '[');
        if Gipos <> 0 THEN BEGIN
            REPEAT
                Gtasunto := COPYSTR(Gtasunto, 1, Gipos - 1) + Prec."Your Reference" + COPYSTR(Gtasunto, Gipos + 1);
                Gipos := STRPOS(Gtasunto, '[');
            UNTIL Gipos = 0;
        END;
        Gipos := STRPOS(Gtasunto, ']');
        if Gipos <> 0 THEN BEGIN
            REPEAT
                Gtasunto := COPYSTR(Gtasunto, 1, Gipos - 1) + FORMAT(Prec."Shipment Date") + COPYSTR(Gtasunto, Gipos + 1);
                Gipos := STRPOS(Gtasunto, ']');
            UNTIL Gipos = 0;
        END;
        EXIT(Gtasunto);
    END;

    PROCEDURE Pcamcad(Cadena: Text[250]) cadf: Text[250];
    VAR
        cad1: Text[250];
        cad2: Text[250];
        i: Decimal;
        elem: Char;
        elem2: Text[1];
        pcad: Label '';
    BEGIN
        cad1 := ' ‚¡ó£à¥¤º¦…Š—‡';
        cad2 := 'áéíóúÓÑñ{ªàèùç';
        cadf := CONVERTSTR(cadena, cad2, cad1);
        elem := 186;
        elem2 := FORMAT(elem);
        cadf := CONVERTSTR(cadf, elem2, 'º');
        elem := 193;
        elem2 := FORMAT(elem);
        cadf := CONVERTSTR(cadf, elem2, 'µ');
        elem := 201;
        elem2 := FORMAT(elem);
        cadf := CONVERTSTR(cadf, elem2, '');
        elem := 205;
        elem2 := FORMAT(elem);
        cadf := CONVERTSTR(cadf, elem2, 'Ö');
        elem := 218;
        elem2 := FORMAT(elem);
        cadf := CONVERTSTR(cadf, elem2, 'é');
        elem := 242;
        elem2 := FORMAT(elem);
        cadf := CONVERTSTR(cadf, elem2, '•');
    END;

    // PROCEDURE SaveToFile(VAR FileName2: Text[1024]);
    // BEGIN
    //     //+001
    //     //NewFileName := CommonDialogMgt.OpenFile(Text001,FileName2,4,Text009,1);
    //     NewFileName := FileMgt.SaveFileDialog(Text001, FileName2, Text009);
    //     if NewFileName <> '' THEN
    //         FileName2 := NewFileName;
    //     //-001
    // END;

}

