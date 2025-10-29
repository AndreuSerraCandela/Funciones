// /// <summary>
// /// PageExtension ResourceCard (ID 80214).
// /// </summary>
// pageextension 80214 ResourceCard Extends "Resource Card"
// {

//     layout
//     {
//         addlast(Content)
//         {

//             field("Imágenes"; Hyper)
//             {
//                 ApplicationArea = All;
//                 trigger OnDrillDown()

//                 var
//                     myInt: Integer;
//                     Pagina: Page "Web Viewer";
//                     JObject: JsonObject;
//                     Slides: JsonArray;
//                     Base64String: Text;
//                     TempBlob2: Codeunit "Base64 Convert";
//                     TempBlob: Codeunit "Temp Blob";
//                     FileManagement: Codeunit "File Management";
//                     IStream: InStream;
//                     FileNames: Text;
//                     JsonObj: Codeunit "Json Text Reader/Writer";
//                     a: Integer;
//                     JsonText: Text;
//                     Tipo: Text;
//                 begin
//                     if StrPos(Hyper, 'file:') <> 0 Then FileNames := CopyStr(Hyper, 6) else FileNames := Hyper;
//                     JsonObj.WriteStartObject('');
//                     JsonObj.WriteStringProperty('type', 'imageLoad');

//                     JsonObj.WriteStartArray('data');

//                     FileManagement.BLOBImportFromServerFile(TempBlob, FileNames);
//                     TempBlob.CreateInStream(IStream);
//                     //UploadIntoStream('', RD.URL1, 'ALL Files (*.*)|*.*', RD.URL1, IStream);

//                     Base64String := TempBlob2.ToBase64(IStream);
//                     JsonObj.WriteStartObject('');
//                     JsonObj.WriteStringProperty('type', 'image');
//                     Tipo := 'data:image/' + 'jpg';
//                     JsonObj.WriteStringProperty('content', tipo + ';base64,' + Base64String);
//                     JsonObj.WriteStringProperty('description', FileNames);
//                     JsonObj.WriteEndObject();
//                     // until RD.Next() = 0;
//                     JsonObj.WriteEndArray();
//                     JsonObj.WriteEndObject();
//                     JsonText := JsonObj.GetJSonAsText();
//                     Pagina.LoadPdfFromBlob(JsonText);
//                     Pagina.Amplia();
//                     Pagina.Run();
//                 END;
//             }
//         }
//         modify("Name 2") { Visible = true; }
//         addafter(General)
//         {


//             group(Recurso)
//             {
//                 field(Prohibiciones; Rec.Prohibiciones) { ApplicationArea = All; }
//                 field("Tipo Recurso"; Rec."Tipo Recurso") { ApplicationArea = All; }
//                 field(Medidas; Rec.Medidas) { ApplicationArea = All; }
//                 field(Categoria; Rec.Categoria) { ApplicationArea = All; }
//                 field(Iluminado; Rec.Iluminado) { ApplicationArea = All; }
//                 field(Zona; Rec.Zona) { ApplicationArea = All; }
//                 field(Orientación; Rec.Orientación) { ApplicationArea = All; }
//                 field(Bloqueado; Rec.Blocked) { ApplicationArea = All; }
//                 field("Vendor No."; Rec."Vendor No.") { ApplicationArea = All; }
//                 field("Nº Dias Reservados"; Rec."Nº Dias Reservados") { ApplicationArea = All; }
//                 field("Estado actual"; Rec."Estado actual") { ApplicationArea = All; }
//                 field(Municipio; Rec.Municipio) { ApplicationArea = All; }
//                 field("C.P. Municipio"; Rec."C.P. Municipio") { ApplicationArea = All; }
//                 field(Historia; Rec.Historia)
//                 {
//                     ApplicationArea = All;
//                     ToolTip = 'Historia del recurso';
//                     trigger OnLookup(var Text: Text): Boolean
//                     Var
//                         Reserva: Record Reserva;
//                     begin
//                         Reserva.Setrange("Nº Recurso", Rec."No.");
//                         Page.Runmodal(Page::"Historico Recurso", Reserva)
//                     end;

//                 }
//                 field("Tipo Montaje"; Rec."Tipo Montaje") { ApplicationArea = All; }
//                 field("No. Orden"; Rec."No. Orden") { ApplicationArea = All; }
//                 field(Peligrosidad; Rec.Peligrosidad) { ApplicationArea = All; }
//                 field("Linea vida"; Rec."Linea vida") { ApplicationArea = All; }
//                 field("Fecha Alta"; Rec."Employment Date")
//                 {
//                     ApplicationArea = All;
//                     Caption = 'Fecha alta';
//                 }
//                 field("Fecha baja"; Rec."Fecha baja") { ApplicationArea = All; }
//                 field(Empresa; Rec.Empresa) { ApplicationArea = All; }
//                 field("Observaciones peligrosidad"; Rec."Observaciones peligrosidad") { ApplicationArea = All; }
//                 field("Tipo fijacion"; Rec."Tipo fijacion") { ApplicationArea = All; }
//             }

//         }
//         addlast(Content)
//         {
//             group("Datos Contables")
//             {
//                 field("Global Dimension 2 Code"; Rec."Global Dimension 2 Code") { ApplicationArea = All; }
//                 field("Global Dimension 1 Code"; Rec."Global Dimension 1 Code") { ApplicationArea = All; }
//                 field("Global Dimension 3 Code"; Rec."Global Dimension 3 Code") { ApplicationArea = All; }
//                 field("Global Dimension 4 Code"; Rec."Global Dimension 4 Code") { ApplicationArea = All; }
//                 field("Global Dimension 5 Code"; Rec."Global Dimension 5 Code") { ApplicationArea = All; }
//                 field(DZona; DZona) { ApplicationArea = All; Caption = 'Descripción Zona'; }
//                 field("Grupo Iva Producto"; Rec."VAT Prod. Posting Group") { ApplicationArea = All; }
//                 field("Grupo Producto"; Rec."Gen. Prod. Posting Group") { ApplicationArea = All; }
//             }
//             group("Datos Recurso")
//             {
//                 field("Recurso Agrupado"; Rec."Recurso Agrupado") { ApplicationArea = All; }
//                 field(Producción; Rec.Producción) { ApplicationArea = All; }
//                 field("Tipo Recurso principal"; Rec."Tipo Recurso principal") { ApplicationArea = All; }
//                 field("Zona Comercial"; Rec."Zona Comercial") { ApplicationArea = All; }
//                 group(Coordenadas)
//                 {
//                     field(PuntoX; Rec.PuntoX) { ApplicationArea = All; Trigger OnDrillDown() Begin Mapa; End; }
//                     field(PuntoY; Rec.PuntoY) { ApplicationArea = All; Trigger OnDrillDown() Begin Mapa; End; }
//                 }
//                 field("Customer Price Group"; Rec."Customer Price Group")
//                 {
//                     ApplicationArea = All;
//                     Caption = 'Categoria Tarifa';
//                 }
//                 field("Material fijación"; Rec."Material fijación") { ApplicationArea = All; }
//                 // field("Direct Unit Cost";Rec."Direct Unit Cost"){ApplicationArea=All;}
//                 // field("Indirect Cost %";Rec."Indirect Cost %"){ApplicationArea=All;}
//                 // field("Unit Cost";Rec."Unit Cost"){ApplicationArea=All;}
//                 // field("Profit %";Rec."Profit %"){ApplicationArea=All;}
//                 // field("Price/Profit Calculation";Rec."Price/Profit Calculation"){ApplicationArea=All;}
//                 // field("Unit Price";Rec."Unit Price"){ApplicationArea=All;}
//                 // field("Gen. Prod. Posting Group";Rec."Gen. Prod. Posting Group"){ApplicationArea=All;}
//                 // field("Automatic Ext. Texts";Rec."Automatic Ext. Texts"){ApplicationArea=All;}
//                 // field("VAT Prod. Posting Group";Rec."VAT Prod. Posting Group"){ApplicationArea=All;}
//                 // field("IC Partner Purch. G/L Acc. No.";Rec."IC Partner Purch. G/L Acc. No."){ApplicationArea=All;}
//                 field(Irpf; Rec.Irpf) { ApplicationArea = All; }
//                 field("Alquiler Anual"; Rec."Alquiler Anual") { ApplicationArea = All; }
//                 field("Local - Alquiler 7 Meses"; Rec."Local - Alquiler 7 Meses") { ApplicationArea = All; }
//                 field("Nacional - Alquiler Anual"; Rec."Nacional - Alquiler Anual") { ApplicationArea = All; }
//                 field("Nacional - Alquiler 7 Meses"; Rec."Nacional - Alquiler 7 Meses") { ApplicationArea = All; }
//                 field(Precio; Precio) { ApplicationArea = All; }
//                 // field(Address;Rec.Address){ApplicationArea=All;}
//                 // field(City;Rec.City){ApplicationArea=All;}
//                 // field("Social Security No.";Rec."Social Security No."){ApplicationArea=All;}
//                 // field("Job Title";Rec."Job Title"){ApplicationArea=All;}
//                 // field(Education;Rec.Education){ApplicationArea=All;}
//                 // field("Address 2";Rec."Address 2"){ApplicationArea=All;}
//                 // field("Contract Class";Rec."Contract Class"){ApplicationArea=All;}
//                 // field("Post Code";Rec."Post Code"){ApplicationArea=All;}
//                 //                                  CaptionML=ENU='Post Code/City',
//                 //                                             ESP='C.P.+Población'; }
//                 //field(County;Rec.County){ApplicationArea=All;}
//                 field("Enunciado Cto. Venta"; Rec."Enunciado Cto. Venta") { ApplicationArea = All; }
//             }
//         }
//         addbefore(Control39)
//         {
//             part(WebViewer; "Carrusel Viewer")
//             {
//                 ApplicationArea = All;
//             }

//         }
//         modify(Control39)
//         {
//             visible = false;
//         }
//     }


//     actions
//     {
//         addlast("&Resource")
//         {
//             //Añadir accion para crear recurso con wizard
//             action("Crear Recurso")
//             {
//                 ApplicationArea = All;
//                 Image = NewResource;
//                 ShortcutKey = 'Ctrl+N';
//                 trigger OnAction()
//                 var
//                     Res: Record Resource temporary;
//                     Asis: Page "Wizard Recursos";
//                 begin
//                     Res.Init();
//                     Asis.Carga();
//                     Asis.RunModal();

//                 end;
//             }
//             action("&Ocupación")
//             {
//                 ApplicationArea = All;
//                 ShortCutKey = F10;
//                 Image = BinContent;
//                 Caption = '&Ocupación';
//                 trigger OnAction()
//                 BEGIN
//                     CLEAR(Plazos);
//                     Plazos.Coge_Recurso(Rec);
//                     Plazos.RUNMODAL;
//                 END;
//             }

//             action("Ver &Reservas")
//             {
//                 ApplicationArea = All;
//                 Image = Reserve;
//                 Caption = 'Ver &Reservas';
//                 RunObject = Page "Tabla Reservas";
//                 //RunPageView=SORTING(Nº Recurso,Fecha inicio,Fecha fin);
//                 RunPageLink = "Nº Recurso" = FIELD("No.");
//             }
//             action("Asignar Dimensiones")
//             {
//                 ApplicationArea = All;
//                 Visible = false;
//                 Caption = 'Asignar Dimensiones';
//                 trigger OnAction()
//                 VAR
//                     rRes: Record 156;
//                     r351: Record 351;
//                     rDef: Record 352;
//                 BEGIN
//                     if rRes.FINDFIRST THEN
//                         REPEAT
//                             if r351.GET('DEPARTAMENTO', rRes."Global Dimension 1 Code", 'PROGRAMA', rRes."Global Dimension 2 Code") THEN BEGIN
//                                 rDef.INIT;
//                                 rDef."Table ID" := 156;
//                                 rDef."No." := rRes."No.";
//                                 rDef."Dimension Code" := 'PRINCIPAL';
//                                 rDef."Dimension Value Code" := r351."Dimension Pincipal";
//                                 if rDef.INSERT THEN;
//                             END;
//                         UNTIL rRes.NEXT = 0;
//                 END;
//             }
//             action("Equivalencias Zonas")
//             {
//                 ApplicationArea = All;
//                 Image = Zones;
//                 Caption = 'Equivalencias Zonas';
//                 //RunObject=Page "Equivalencias Zonas"; 
//             }
//             action("Copiar a Otras Empresas")
//             {
//                 ApplicationArea = All;
//                 Caption = 'Copiar a Otras Empresas';
//                 Image = Company;
//                 trigger OnAction()
//                 BEGIN
//                     Error('No se pueden copiar recursos a otras empresas');
//                     Rec.TrasladaOtrasEmpresas;
//                 END;
//             }
//             action("Borra Otras Empresas")
//             {
//                 Visible = false;
//                 Caption = 'Borra Otras Empresas';
//                 trigger OnAction()
//                 BEGIN
//                     Rec.BorraOtrasEmpresas;
//                 END;
//             }
//             action("Eliminar")
//             {
//                 ApplicationArea = All;
//                 Image = Delete;
//                 ShortCutKey = F4;
//                 Caption = 'Eliminar';
//                 trigger OnAction()
//                 VAR
//                     r60156: Record Resource3;
//                 BEGIN
//                     if CONFIRM('Seguro que desea borrar el recurso?') THEN BEGIN
//                         r60156.TRANSFERFIELDS(Rec);
//                         Rec.DELETE;
//                         r60156.INSERT;
//                     END;
//                 END;
//             }
//             action(Zone)
//             {
//                 ApplicationArea = All;
//                 Image = Zones;
//                 ShortCutKey = F11;
//                 Caption = 'Zona';
//                 trigger OnAction()
//                 VAR
//                     numPoints: Integer;
//                     inPoly: Boolean;
//                     x: Integer;
//                     j: Integer;
//                     vertex1: ARRAY[2] OF Decimal;
//                     rZon: Record 50000;
//                     vertex2: ARRAY[2] OF Decimal;
//                     valor: Integer;
//                     point: ARRAY[2] OF Decimal;
//                 BEGIN
//                     numPoints := rZon.COUNT;
//                     inPoly := FALSE;
//                     x := 0;
//                     point[1] := Rec.PuntoX;
//                     point[2] := Rec.PuntoY;
//                     rZon.FINDFIRST;
//                     vertex1[1] := rZon.PuntoX;
//                     vertex1[2] := rZon.PuntoY;
//                     rZon.NEXT;
//                     REPEAT
//                         vertex2[1] := rZon.PuntoX;
//                         vertex2[2] := rZon.PuntoY;
//                         if EstaDentro(vertex1, vertex2, point) THEN
//                             valor := valor + 1;
//                         vertex1[1] := rZon.PuntoX;
//                         vertex1[2] := rZon.PuntoY;
//                     UNTIL rZon.NEXT = 0;
//                     MESSAGE('%1', valor);
//                     // {int x = 0;
//                     //         int valor = 0;
//                     //         foreach (GLatLng punto in puntos)
//                     //         {
//                     //             x = 0;
//                     //             valor = 0;
//                     //             while (x + 1 < Polypuntos.Count)
//                     //             {
//                     //                 if (IsOnRigth(Polypuntos[x], Polypuntos[x + 1], punto))
//                     //                     valor++;
//                     //                 x++;
//                     //             }
//                     //             //si es impar entonces esta dentro de punto.
//                     //             if ((valor % 2) != 0)
//                     //                 retorno.Add(punto);
//                     //         }
//                     //         return retorno; }
//                 END;
//             }
//         }
//         addfirst("Category_Category4")
//         {
//             actionref("Crear Recurso_Promoted"; "Crear Recurso") { }
//         }
//     }

//     VAR
//         Plazos: Page "Plazos recursos reservados";
//         rSetup: Record 314;
//         Hyper: Text[1024];
//         cGest: Codeunit "Gestion Reservas";


//     trigger OnAfterGetRecord()
//     var
//         Tipo: Record "Tipo Recurso";
//     BEGIN
//         //Rec.SETRANGE("No.");
//         if Not Tipo.Get(Rec."Tipo Recurso") Then Tipo.Init();
//         //rSetup.Get();
//         if Tipo."Ruta imagenes" <> '' THEN
//             Hyper := Tipo."Ruta imagenes" + '\' + Rec."No." + '.jpg'
//         ELSE
//             Hyper := '';
//         ShowData(true);
//         //CurrPage.WebViewer.Page.ShowData();
//     END;

//     PROCEDURE DZona(): Text[100];
//     VAR
//         rDim: Record 352;
//         rVal: Record 349;
//     BEGIN
//         rDim.SETRANGE(rDim."Table ID", 156);
//         rDim.SETRANGE(rDim."No.", Rec."No.");
//         rDim.SETRANGE(rDim."Dimension Code", 'ZONA');
//         if rDim.FINDFIRST THEN BEGIN
//             if rVal.GET('ZONA', rDim."Dimension Value Code") THEN EXIT(rVal.Name);
//         END;
//     END;

//     PROCEDURE EstaDentro(PolyPointA: ARRAY[2] OF Decimal; PolyPointB: ARRAY[2] OF Decimal; point: ARRAY[2] OF Decimal): Boolean;
//     VAR
//         LngInFunction: Decimal;
//         M: Decimal;
//     BEGIN
//         //y = Lat
//         M := 0;
//         LngInFunction := 0;
//         //Si el punto esta entre la Lat de los dos puntos
//         if ((PolyPointA[2] >= point[2]) AND (PolyPointB[2] <= point[2])) OR ((PolyPointB[2] >= point[2]) AND (PolyPointA[1] <= point[2]))
//                 THEN BEGIN
//             M := (PolyPointA[2] - PolyPointB[2]) / (PolyPointA[1] - PolyPointB[1]);
//             LngInFunction := ((point[2] - PolyPointA[2]) / M) + PolyPointA[1];
//             //si esta a la derecha, sumo uno, sino no hago nada.
//             if (LngInFunction <= point[1]) THEN
//                 EXIT(TRUE);
//         END;
//         EXIT(FALSE);
//     END;

//     PROCEDURE Mapa();
//     BEGIN
//         HYPERLINK('http://maps.google.es/?q=' + CONVERTSTR(FORMAT(Rec.PuntoY, 0, '<Precision,10:10><Standard Format,0>'), ',', '.')
//         + '%20' + CONVERTSTR(FORMAT(Rec.PuntoX, 0, '<Precision,10:10><Standard Format,0>'), ',', '.'));
//     END;

//     PROCEDURE Precio(): Decimal;
//     VAR
//         FromSalesPrice: Record "Price List Line";// "Sales Price";
//         TempTargetCampaignGr: Record "Campaign Target Group";
//         StartingDate: date;
//     BEGIN

//         if StartingDate = 0D THEN StartingDate := WORKDATE;
//         FromSalesPrice.SETFILTER("Ending Date", '%1|>=%2', 0D, StartingDate);
//         FromSalesPrice.SETRANGE("Starting Date", 0D, StartingDate);
//         FromSalesPrice.SETRANGE("Source Type", FromSalesPrice."Source Type"::"Customer Price Group");
//         FromSalesPrice.SETRANGE("Source No.", Rec."Customer Price Group");
//         if FromSalesPrice.FINDLAST THEN EXIT(FromSalesPrice."Unit Price");

//     END;

//     /// <summary>
//     /// ShowData.
//     /// </summary>
//     /// <param name="a">Boolean.</param>
//     procedure ShowData(a: Boolean)
//     var
//         RD: Record "Document Attachment";
//         IStream: InStream;
//         myInt: Integer;
//         Base64String: Text;
//         TempBlob2: Codeunit "Base64 Convert";
//         JsonObj: Codeunit "Json Text Reader/Writer";
//         JsonText: Text;
//         OsTream: OutStream;
//         TempBlob: Codeunit "Temp Blob";
//         Tipo: Text;
//         Filename: Text;
//         FileManagement: Codeunit "File Management";
//         Tipos: Record "Tipo Recurso";
//         NameValueBuffer: Record "Name/Value Buffer";
//     begin
//         if not a then exit;

//         JsonObj.WriteStartObject('');
//         JsonObj.WriteStringProperty('type', 'imageLoad');

//         JsonObj.WriteStartArray('data');

//         // if RD.FINDFIRST THEN
//         //   REPEAT
//         if Not Tipos.Get(Rec."Tipo Recurso") Then Tipos.Init();
//         //rSetup.Get();

//         if Tipos."Ruta Imagenes" = '' Then begin
//             CurrPage.WebViewer.Page.Update(false);
//             Exit;
//         end;
//         if StrPos(Tipos."Ruta Imagenes", 'file:') <> 0 Then Tipos."Ruta Imagenes" := CopyStr(Tipos."Ruta Imagenes", 6);
//         NameValueBuffer.DeleteAll();
//         FileManagement.GetServerDirectoryFilesList(NameValueBuffer, Tipos."Ruta Imagenes" + '\' + Rec."No." + '*' + '.jpg');
//         // NameValueBuffer.SetFilter(Name, '%1', Tipos."Ruta imagenes" + '\' + Rec."No." + '*' + '.jpg');
//         // if Not FileManagement.ServerFileExists(Tipos."Ruta imagenes" + '\' + Rec."No." + '.jpg') then exit;
//         // FileManagement.BLOBImportFromServerFile(TempBlob, Tipos."Ruta imagenes" + '\' + Rec."No." + '.jpg');
//         // TempBlob.CreateInStream(IStream);
//         // //UploadIntoStream('', RD.URL1, 'ALL Files (*.*)|*.*', RD.URL1, IStream);

//         // Base64String := TempBlob2.ToBase64(IStream);
//         // JsonObj.WriteStartObject('');
//         // JsonObj.WriteStringProperty('type', 'image');
//         // Tipo := 'data:image/' + 'jpg';
//         // JsonObj.WriteStringProperty('content', tipo + ';base64,' + Base64String);
//         // JsonObj.WriteStringProperty('description', Rec."No.");
//         // JsonObj.WriteEndObject();
//         // // until RD.Next() = 0;
//         // JsonObj.WriteEndArray();
//         // JsonObj.WriteEndObject();
//         // JsonText := JsonObj.GetJSonAsText();
//         CurrPage.WebViewer.Page.CargaDocumentos(Tipos."Ruta imagenes" + '\' + Rec."No.");// LoadPdfFromBlob(JsonText);
//         CurrPage.WebViewer.Page.Update(false);
//     end;
//     //     BEGIN
//     //     END.
//     //   }
// }