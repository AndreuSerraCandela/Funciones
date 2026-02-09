/// <summary>
/// Page Modelo 180 (ID 7001108).
/// </summary>
// page 7001108 "Modelo 180"
// {
//     PageType = List;
//     UsageCategory = Lists;
//     ApplicationArea = All;
//     SourceTable = "G/L Entry";
//     Extensible = TRUE;
//     layout
//     {
//         area(Content)
//         {
//             repeater(Detalle)
//             {
//                 field(Base; Base) { ApplicationArea = All; }
//                 field("Retención"; -Rec.Amount) { ApplicationArea = All; }
//                 field(Cif; Cif) { ApplicationArea = All; }
//                 field(Catastro; Catastro) { ApplicationArea = All; }
//                 field(Población; Poblacion) { ApplicationArea = All; }
//                 field("Código Postal"; CP) { ApplicationArea = All; }
//                 field(Dirección; Direccion) { ApplicationArea = All; }
//                 field(Nombre; Nombre) { ApplicationArea = All; }
//                 field(Cuenta; Rec."G/L Account No.") { ApplicationArea = All; }
//                 field(Fecha; Rec."Posting Date") { ApplicationArea = All; }
//                 field("Tipo Documento"; Rec."Document Type") { ApplicationArea = All; }
//                 field("Nº Documento"; Rec."Document No.")
//                 {
//                     ApplicationArea = All;
//                     Trigger OnDrillDown()
//                     VAR
//                         r123: Record 123;
//                         r125: Record 125;
//                     BEGIN
//                         if Rec."Document Type" = Rec."Document Type"::Invoice THEN BEGIN
//                             r123.SETRANGE(r123."Document No.", Rec."Document No.");
//                             // r123.SETRANGE(r123."No.","G/L Account No.");
//                             r123.SETFILTER(r123."No.", COPYSTR(Rec."G/L Account No.", 1, 4) + '*');
//                             Page.RUNMODAL(0, r123);
//                         END;
//                         if Rec."Document Type" = Rec."Document Type"::"Credit Memo" THEN BEGIN
//                             // r125.SETRANGE(r125."No.","G/L Account No.");
//                             r125.SETRANGE(r125."Document No.", Rec."Document No.");
//                             r125.SETFILTER(r125."No.", COPYSTR(Rec."G/L Account No.", 1, 4) + '*');
//                             Page.RUNMODAL(0, r125);
//                         END;
//                     END;
//                 }
//                 field(Descripción; Rec.Description) { ApplicationArea = All; }
//                 field(Proveedor; Rec."Source No.") { ApplicationArea = All; }
//             }
//         }
//     }
//     actions
//     {
//         area(Processing)
//         {
//             group(Acciones)
//             {
//                 action(Resumen)
//                 {
//                     ApplicationArea = All;
//                     Image = Relatives;


//                     trigger OnAction()
//                     VAR
//                         r123: Record 123;
//                         r125: Record 125;
//                         r23: Record Vendor;
//                         rRef: Record "Ref Catastral Address";
//                         rRef2: Record "Ref Catastral Address" TEMPORARY;
//                         Bas: Decimal;
//                     BEGIN
//                         if Rec.FINDFIRST THEN
//                             REPEAT
//                                 r23.GET(Rec."Source No.");
//                                 Cif := r23."VAT Registration No.";
//                                 Nombre := r23.Name;
//                                 Catastro := '';
//                                 if Rec."Document Type" = Rec."Document Type"::Invoice THEN BEGIN
//                                     r123.SETRANGE(r123."Document No.", Rec."Document No.");
//                                     //  r123.SETRANGE(r123."No.","G/L Account No.");
//                                     r123.SETFILTER(r123."No.", COPYSTR(Rec."G/L Account No.", 1, 4) + '*');
//                                     if r123.COUNT > 1 THEN BEGIN
//                                         r123.FINDFIRST;
//                                         rRef.SETRANGE(rRef."Vendor No.", Rec."Source No.");
//                                         rRef.SETFILTER(rRef."Ref. catastral", '<>%1', '');
//                                         if r123."Ref. catastral inmueble SII" <> '' THEN
//                                             rRef.SETRANGE(rRef."Ref. catastral", r123."Ref. catastral inmueble SII");
//                                         if rRef.FINDFIRST THEN BEGIN
//                                             CP := rRef."Post Code";
//                                             Poblacion := rRef.City;
//                                             Direccion := rRef.Address;
//                                             Catastro := rRef."Ref. catastral";
//                                         END;
//                                         Bas := (REc.Amount / r123.Quantity);
//                                     END ELSE BEGIN
//                                         r123.FINDFIRST;
//                                         rRef.SETRANGE(rRef."Vendor No.", Rec."Source No.");
//                                         rRef.SETFILTER(rRef."Ref. catastral", '<>%1', '');
//                                         if r123."Ref. catastral inmueble SII" <> '' THEN
//                                             rRef.SETRANGE(rRef."Ref. catastral", r123."Ref. catastral inmueble SII");
//                                         if rRef.FINDFIRST THEN BEGIN
//                                             CP := rRef."Post Code";
//                                             Poblacion := rRef.City;
//                                             Direccion := rRef.Address;
//                                             Catastro := rRef."Ref. catastral";
//                                         END;
//                                         Bas := (r123."Direct Unit Cost");
//                                     END;
//                                 END;

//                                 if Rec."Document Type" = Rec."Document Type"::"Credit Memo" THEN BEGIN
//                                     //r125.SETRANGE(r125."No.","G/L Account No.");
//                                     r125.SETFILTER(r125."No.", COPYSTR(Rec."G/L Account No.", 1, 4) + '*');
//                                     r125.SETRANGE(r125."Document No.", Rec."Document No.");
//                                     if r125.COUNT > 1 THEN BEGIN
//                                         r125.FINDFIRST;
//                                         rRef.SETRANGE(rRef."Vendor No.", Rec."Source No.");
//                                         rRef.SETFILTER(rRef."Ref. catastral", '<>%1', '');
//                                         if r125."Ref. catastral inmueble SII" <> '' THEN
//                                             rRef.SETRANGE(rRef."Ref. catastral", r125."Ref. catastral inmueble SII");

//                                         if rRef.FINDFIRST THEN BEGIN
//                                             CP := rRef."Post Code";
//                                             Poblacion := rRef.City;
//                                             Direccion := rRef.Address;
//                                             Catastro := rRef."Ref. catastral";
//                                         END;
//                                         Bas := (-Rec.Amount / r125.Quantity);
//                                     END ELSE BEGIN
//                                         r125.FINDFIRST;
//                                         rRef.SETRANGE(rRef."Vendor No.", Rec."Source No.");
//                                         rRef.SETFILTER(rRef."Ref. catastral", '<>%1', '');
//                                         if r125."Ref. catastral inmueble SII" <> '' THEN
//                                             rRef.SETRANGE(rRef."Ref. catastral", r125."Ref. catastral inmueble SII");

//                                         if rRef.FINDFIRST THEN BEGIN
//                                             CP := rRef."Post Code";
//                                             Poblacion := rRef.City;
//                                             Direccion := rRef.Address;
//                                             Catastro := rRef."Ref. catastral";
//                                         END;
//                                         Bas := (-r125."Direct Unit Cost");
//                                     END;
//                                 END;
//                                 if (Catastro = '') AND (COPYSTR(r23."VAT Registration No.", 1, 1) <> 'H')
//                                 THEN
//                                     ERROR('No se puede generar el resumen el proveedor %1 tiene referencias catastrales en blanco', r23."No.");
//                                 if Catastro = '' THEN BEGIN
//                                     rRef2.RESET;
//                                     rRef2.SETRANGE(rRef2."Vendor No.", r23."No.");
//                                     rRef2.SETRANGE(rRef2.Code, Catastro);
//                                     if rRef2.FINDFIRST THEN BEGIN
//                                         rRef2.Base := rRef2.Base + Bas;
//                                         rRef2.Retención := rRef2.Retención - Rec.Amount;
//                                         rRef2.MODIFY;
//                                     END ELSE BEGIN
//                                         rRef2."Vendor No." := r23."No.";
//                                         rRef2.Name := CambiarTXT(r23.Name);
//                                         rRef2."Name 2" := CambiarTXT(r23."Name 2");
//                                         rRef2.Address := CambiarTXT(r23.Address);
//                                         rRef2."Address 2" := CambiarTXT(r23."Address 2");
//                                         rRef2.City := r23.City;
//                                         rRef2.Code := '';
//                                         rRef2.Cif := r23."VAT Registration No.";
//                                         rRef2.Base := Bas;
//                                         rRef2.Retención := -Rec.Amount;
//                                         rRef2."Ref. catastral" := '';
//                                         rRef2.INSERT;
//                                     END;


//                                 END ELSE BEGIN
//                                     rRef2.RESET;
//                                     rRef2.SETRANGE(rRef2."Vendor No.", r23."No.");
//                                     rRef2.SETRANGE(rRef2.Code, Catastro);
//                                     if rRef2.FINDFIRST THEN BEGIN
//                                         rRef2.Base := rRef2.Base + Bas;
//                                         rRef2.Retención := rRef2.Retención - Rec.Amount;
//                                         rRef2.MODIFY;
//                                     END ELSE BEGIN
//                                         rRef2 := rRef;
//                                         rRef2.Name := CambiarTXT(rRef2.Name);
//                                         rRef2."Name 2" := CambiarTXT(rRef2."Name 2");
//                                         rRef2.Address := CambiarTXT(rRef2.Address);
//                                         rRef2."Address 2" := CambiarTXT(rRef2."Address 2");
//                                         rRef2.Code := Catastro;
//                                         rRef2.Cif := r23."VAT Registration No.";
//                                         rRef2.Base := Bas;
//                                         rRef2.Retención := -Rec.Amount;
//                                         rRef2.INSERT;
//                                     END;
//                                 END;
//                             UNTIL Rec.NEXT = 0;
//                         COMMIT;
//                         rRef2.Reset;
//                         Page.RUNMODAL(7001104, rRef2);
//                     END;
//                 }
//                 action(Recalcula)
//                 {
//                     ApplicationArea = All;
//                     Image = Calculate;
//                     trigger OnAction()
//                     BEGIN
//                         CODEUNIT.RUN(7001113); //"Ref Catastral"
//                     END;
//                 }
//                 action("Sin Referencia")
//                 {
//                     ApplicationArea = All;
//                     Image = Error;
//                     trigger OnAction()
//                     VAR
//                         r123: Record 123;
//                         r125: Record 125;
//                         Catas: Text[250];
//                         r23: Record Vendor;
//                         rRef: Record "Ref Catastral Address";
//                     BEGIN
//                         Rec.CLEARMARKS;
//                         if Rec.FINDFIRST THEN
//                             REPEAT
//                                 r23.GET(Rec."Source No.");
//                                 Catas := '';
//                                 if Rec."Document Type" = Rec."Document Type"::Invoice THEN BEGIN
//                                     r123.SETRANGE(r123."Document No.", Rec."Document No.");
//                                     //r123.SETRANGE(r123."No.","G/L Account No.");
//                                     r123.SETFILTER(r123."No.", COPYSTR(Rec."G/L Account No.", 1, 4) + '*');
//                                     if r123.COUNT > 1 THEN BEGIN
//                                         r123.FINDFIRST;
//                                         rRef.SETRANGE(rRef."Vendor No.", Rec."Source No.");
//                                         rRef.SETRANGE(rRef."Ref. catastral", r123."Ref. catastral inmueble SII");
//                                         if rRef.FINDFIRST THEN BEGIN
//                                             Catas := rRef."Ref. catastral";
//                                         END;
//                                     END ELSE BEGIN
//                                         r123.FINDFIRST;
//                                         rRef.SETRANGE(rRef."Vendor No.", Rec."Source No.");
//                                         rRef.SETRANGE(rRef."Ref. catastral", r123."Ref. catastral inmueble SII");
//                                         if rRef.FINDFIRST THEN BEGIN
//                                             Catas := rRef."Ref. catastral";
//                                         END;
//                                     END;
//                                 END;

//                                 if Rec."Document Type" = Rec."Document Type"::"Credit Memo" THEN BEGIN
//                                     //r125.SETRANGE(r125."No.","G/L Account No.");
//                                     r125.SETFILTER(r125."No.", COPYSTR(Rec."G/L Account No.", 1, 4) + '*');
//                                     r125.SETRANGE(r125."Document No.", Rec."Document No.");
//                                     if r125.COUNT > 1 THEN BEGIN
//                                         r125.FINDFIRST;
//                                         rRef.SETRANGE(rRef."Vendor No.", Rec."Source No.");
//                                         rRef.SETRANGE(rRef."Ref. catastral", r125."Ref. catastral inmueble SII");
//                                         if r125."Ref. catastral inmueble SII" = '' THEN
//                                             rRef.SETRANGE(rRef."Ref. catastral");

//                                         if rRef.FINDFIRST THEN BEGIN
//                                             Catas := rRef."Ref. catastral";
//                                         END;
//                                     END ELSE BEGIN
//                                         r125.FINDFIRST;
//                                         rRef.SETRANGE(rRef."Vendor No.", Rec."Source No.");
//                                         rRef.SETRANGE(rRef."Ref. catastral", r125."Ref. catastral inmueble SII");
//                                         if r125."Ref. catastral inmueble SII" = '' THEN
//                                             rRef.SETRANGE(rRef."Ref. catastral");

//                                         if rRef.FINDFIRST THEN BEGIN
//                                             Catas := rRef."Ref. catastral";
//                                         END;
//                                     END;
//                                 END;
//                                 if (Catas = '') And (CopyStr(r23."VAT Registration No.", 1, 1) <> 'H') THEN Rec.MARK := TRUE;
//                             UNTIL Rec.NEXT = 0;
//                         Rec.MARKEDONLY(TRUE);
//                     END;
//                 }

//             }
//         }
//     }

//     VAR
//         CP: Code[50];
//         Poblacion: Text[100];
//         Direccion: Text[100];
//         Nombre: Text[100];
//         Catastro: Text[80];
//         Cif: Text[30];
//         Base: Decimal;

//     Trigger OnOpenPage()
//     BEGIN
//         Rec.SETRANGE("G/L Account No.", '475100004');
//         Rec.SETRANGE("Posting Date", CALCDATE('PA+1D-2A', TODAY), CALCDATE('PA-1A', TODAY));
//         Rec.SETRANGE("Source Type", Rec."Source Type"::Vendor);
//         Rec.SETFILTER("Document Type", '%1|%2', Rec."Document Type"::Invoice, Rec."Document Type"::"Credit Memo");
//     END;

//     trigger OnAfterGetRecord()
//     VAR
//         a: Decimal;
//     BEGIN
//         Calcula;
//         if Catastro = '' THEN a := Base;
//     END;

//     trigger OnAfterGetCurrRecord()
//     VAR
//         a: Decimal;
//     BEGIN
//         if Catastro = '' THEN a := Base;
//     END;

//     PROCEDURE Calcula();
//     VAR
//         r123: Record 123;
//         r125: Record 125;
//         r23: Record Vendor;
//         rRef: Record "Ref Catastral Address";
//     BEGIN
//         cp := '';
//         Direccion := '';
//         Catastro := '';
//         Base := 0;
//         Nombre := '';
//         Poblacion := '';
//         Cif := '';
//         if NOT r23.GET(Rec."Source No.") THEN Exit;
//         Cif := r23."VAT Registration No.";
//         Nombre := r23.Name;
//         Catastro := '';
//         rRef.SETFILTER(rRef."Ref. catastral", '<>%1', '');
//         if Rec."Document Type" = Rec."Document Type"::Invoice THEN BEGIN
//             r123.SETRANGE(r123."Document No.", Rec."Document No.");
//             r123.SETFILTER(r123."No.", COPYSTR(Rec."G/L Account No.", 1, 4) + '*');
//             // r123.SETRANGE(r123."No.","G/L Account No.");
//             if r123.COUNT > 1 THEN BEGIN
//                 r123.FINDFIRST;
//                 rRef.SETRANGE(rRef."Vendor No.", Rec."Source No.");
//                 rRef.SETFILTER(rRef."Ref. catastral", '<>%1', '');
//                 if r123."Ref. catastral inmueble SII" <> '' THEN
//                     rRef.SETRANGE(rRef."Ref. catastral", r123."Ref. catastral inmueble SII");
//                 if rRef.FINDFIRST THEN BEGIN
//                     CP := rRef."Post Code";
//                     Poblacion := rRef.City;
//                     Direccion := rRef.Address;
//                     Catastro := rRef."Ref. catastral";
//                 END;
//                 Base := Rec.Amount / r123.Quantity;
//                 EXIT;
//             END;
//             if r123.FINDFIRST THEN BEGIN
//                 rRef.SETRANGE(rRef."Vendor No.", Rec."Source No.");
//                 rRef.SETFILTER(rRef."Ref. catastral", '<>%1', '');
//                 if r123."Ref. catastral inmueble SII" <> '' THEN
//                     rRef.SETRANGE(rRef."Ref. catastral", r123."Ref. catastral inmueble SII");
//                 if rRef.FINDFIRST THEN BEGIN
//                     CP := rRef."Post Code";
//                     Poblacion := rRef.City;
//                     Direccion := rRef.Address;
//                     if rRef."Ref. catastral" <> '' THEN
//                         Catastro := rRef."Ref. catastral";
//                 END;
//                 Base := r123."Direct Unit Cost";
//                 EXIT;
//             END;
//         END;

//         if Rec."Document Type" = Rec."Document Type"::"Credit Memo" THEN BEGIN
//             r125.SETFILTER(r125."No.", COPYSTR(Rec."G/L Account No.", 1, 4) + '*');
//             // r125.SETRANGE(r125."No.","G/L Account No.");
//             r125.SETRANGE(r125."Document No.", Rec."Document No.");
//             if r125.COUNT > 1 THEN BEGIN
//                 r125.FINDFIRST;
//                 rRef.SETRANGE(rRef."Vendor No.", Rec."Source No.");
//                 rRef.SETFILTER(rRef."Ref. catastral", '<>%1', '');
//                 if r125."Ref. catastral inmueble SII" <> '' THEN
//                     rRef.SETRANGE(rRef."Ref. catastral", r125."Ref. catastral inmueble SII");
//                 if r125."Ref. catastral inmueble SII" = '' THEN
//                     rRef.SETRANGE(rRef."Ref. catastral");
//                 if rRef.FINDFIRST THEN BEGIN
//                     CP := rRef."Post Code";
//                     Poblacion := rRef.City;
//                     Direccion := rRef.Address;
//                     Catastro := rRef."Ref. catastral";
//                 END;
//                 Base := -Rec.Amount / r125.Quantity;
//                 EXIT;
//             END;
//             if r125.FINDFIRST THEN BEGIN
//                 rRef.SETRANGE(rRef."Vendor No.", Rec."Source No.");
//                 rRef.SETFILTER(rRef."Ref. catastral", '<>%1', '');
//                 if r125."Ref. catastral inmueble SII" <> '' THEN
//                     rRef.SETRANGE(rRef."Ref. catastral", r125."Ref. catastral inmueble SII");
//                 if r125."Ref. catastral inmueble SII" = '' THEN
//                     rRef.SETRANGE(rRef."Ref. catastral");
//             END;
//             if rRef.FINDFIRST THEN BEGIN
//                 CP := rRef."Post Code";
//                 Poblacion := rRef.City;
//                 Direccion := rRef.Address;
//                 Catastro := rRef."Ref. catastral";
//             END;
//             Base := -r125."Direct Unit Cost";
//             EXIT;
//         END;
//     END;

//     PROCEDURE CambiarTXT(TextOr: Text[250]) Result: Text[250]
//     var
//         TempString: Text[100];
//         TempString1: Text[1];
//         NameString: Text[250];
//         c: Label '''';// 'ESP=''';
//         SpanishSpecialCharactersTxt: Label 'ÁÀÉÈÊÍÌÓÒÛÚÙÑÜÇ()"&´ÄËÏØÖ¹Ü$''ºª', Locked = true;
//     begin
//         Clear(Result);
//         TextOr := CONVERTSTR(TextOr, 'µ', 'A');
//         TextOr := CONVERTSTR(TextOr, '', 'E');
//         TextOr := CONVERTSTR(TextOr, 'Ö', 'I');
//         TextOr := CONVERTSTR(TextOr, 'à', 'O');
//         TextOr := CONVERTSTR(TextOr, 'é', 'U');
//         TextOr := CONVERTSTR(TextOr, 'º', 'o');
//         TextOr := CONVERTSTR(TextOr, '¦', 'a');
//         TextOr := CONVERTSTR(TextOr, '€', 'Z');

//         TextOr := CONVERTSTR(TextOr, c, ' ');
//         TempString := ConvertStr(UpperCase(NameString), SpanishSpecialCharactersTxt, 'AAEEEIIOOUUUÐUÃ     AEIOOOU    ');
//         // if StrLen(TempString) > 0 then
//         //     repeat
//         //         TempString1 := CopyStr(TempString, 1, 1);
//         //         if TempString1 in ['A' .. 'Z', '-'] then
//         //             Result := Result + TempString1
//         //         else
//         //             Result := Result + ' ';
//         //         TempString := DelStr(TempString, 1, 1);
//         //     until StrLen(TempString) = 0;

//         exit(Result);
//     end;

// }




