/// <summary>
/// TableExtension ResourceKuara (ID 80112) extends Record Resource.
/// </summary>
tableextension 75005 ResourceKuaraExt extends Resource
{

    Var
        rEmp: Record Company;
        rInf: record "Company Information";

    Procedure TrasladaOtrasEmpresas()
    Var
        rRes: Record Resource;
        Control: Codeunit ControlProcesos;
    begin
        //rEmp.SETRANGE(rEmp.InterEmpresas,TRUE);

        rEmp.SETFILTER(rEmp.Name, '<>%1', COMPANYNAME);
        rEmp.SetRange("Evaluation Company", false);
        if rEmp.FINDFIRST THEN
            REPEAT
                if Control.Permiso_Empresas(rEmp.Name) then begin
                    rInf.CHANGECOMPANY(rEmp.Name);
                    if rInf.Get() then begin
                        if rInf.InterEmpresas = true Then begin
                            rRes.CHANGECOMPANY(rEmp.Name);
                            if rRes.GET("No.") THEN rRes.DELETE;
                            rRes := Rec;
                            rRes.INSERT;
                        End;
                    end;
                end;
            UNTIL rEmp.NEXT = 0;
    end;

    Procedure BorraOtrasEmpresas()
    var
        rRes: Record Resource;
        Control: Codeunit ControlProcesos;
    begin
        //rEmp.SETRANGE(rEmp.InterEmpresas,TRUE);
        rEmp.SETFILTER(rEmp.Name, '<>%1', COMPANYNAME);
        rEmp.SetRange("Evaluation Company", false);

        if rEmp.FINDFIRST THEN
            REPEAT
                if Control.Permiso_Empresas(rEmp.Name) then begin
                    rInf.CHANGECOMPANY(rEmp.Name);
                    if rInf.Get() then begin
                        if rInf.InterEmpresas then begin
                            if rRes.GET("No.") THEN rRes.DELETE;
                            // rRes:=Rec;
                            // rRes:=Rec;
                        end;
                    end;          // rRes.INSERT;
                end;
            UNTIL rEmp.NEXT = 0;
    end;

}
// tableextension 80117 ResourceKuaraExt extends Resource3
// {
//     fields
//     {
//         field(80026; "Fecha de baja"; Boolean)
//         {
//             Caption = 'No usar';
//             DataClassification = ToBeClassified;
//         }
//         field(80027; "Fecha baja."; Date)
//         {
//             Caption = 'Fecha baja';
//             DataClassification = ToBeClassified;
//             trigger OnValidate()
//             VAR
//                 rAct: Record 5600;
//                 CCod: Codeunit ControlProcesos;
//             BEGIN
//                 rAct.SETRANGE(rAct.Recurso, "No.");
//                 if rAct.FINDFIRST THEN BEGIN
//                     // MESSAGE('Este recurso tiene un activo relacionado. Se va a dar de baja');
//                     CLEAR(CCod);
//                     CCod.Baja(rAct."No.", "No.");
//                 END;
//             END;
//             //Description=$004 
//         }
//         field(50001; "Categoria"; Enum "Categoria")
//         {
//             InitValue = " ";

//         }
//         field(50002; "Iluminado"; Boolean)
//         {
//             InitValue = false;
//         }
//         field(50003; "Tipo Recurso"; Code[10])
//         {
//             TableRelation = "Tipo Recurso";

//             //Description=FK Tipo Recurso 
//         }
//         field(50004; "Historia"; Boolean)
//         {
//             FieldClass = FlowField;
//             CalcFormula = Exist(Reserva WHERE("Nº Recurso" = FIELD("No.")));
//             //Description=Campo calculado historia 
//         }
//         field(50005; "Nº Dias Reservados"; Integer)
//         {
//             FieldClass = FlowField;
//             CalcFormula = Count("Diario Reserva" WHERE("Nº Recurso" = FIELD("No."),
//                         Fecha = FIELD("Date Filter")));
//             //Description=Campo suma reservas del recurso;
//             Editable = false;
//         }
//         field(50006; "Ocupado"; Boolean)
//         {
//             InitValue = false;
//             //Description=Campo para saber los recursos libres a la hora de cambiar una reserva 
//         }
//         field(50007; "Estado actual"; Enum "Estado Reserva")
//         {
//             FieldClass = FlowField;
//             CalcFormula = Lookup("Diario Reserva".Estado WHERE("Nº Recurso" = FIELD("No."),
//                                 Fecha = FIELD("Date Filter")));
//             //OptionString=Reservado,Reservado fijo,Ocupado,Ocupado fijo,Libre;
//             Editable = false;
//         }
//         field(50008; "Medidas"; Code[20]) { TableRelation = Medidas; }
//         field(50009; "Zona"; Code[20])
//         {
//             TableRelation = "Zonas Recursos";
//             //Description=FK Zonas 
//         }
//         field(50010; "Orientación"; Enum "Orientación") { }//Indistinto,Entrada,Salida }
//         field(50015; "Enunciado Cto. Venta"; Text[30])
//         {
//             //Description=Si hay algo, sustituye la descripcion en el cto. vta. 
//         }
//         field(50020; "Carretera"; Text[20])
//         {
//             //Description=Punto kilometrico 
//         }
//         field(50025; "Municipio"; Code[15]) { }
//         field(50026; "C.P. Municipio"; Code[5]) { }
//         field(50030; "Prohibiciones"; Text[50])
//         {
//         }
//         field(50031; "Tiene Prohibiciones"; Boolean) { Editable = false; }
//         field(50035; "Tipo Montaje"; Enum "Tipo Montaje")
//         {
//             //" ,V,T,VT,BP";
//             //Description=$002 
//         }
//         field(50036; "Filtro Proveedor"; Code[20]) { FieldClass = FlowFilter; }
//         field(50037; "Filtro Seccion"; Code[20]) { FieldClass = FlowFilter; }
//         field(50038; "Tiene Tarifas"; Boolean)
//         {
//             FieldClass = FlowField;
//             CalcFormula = Exist("Resource Cost" WHERE(Type = CONST(Resource),
//                                 Code = FIELD("No."),
//                                 "Vendor No." = FIELD("Filtro Proveedor"),
//                                 Seccion = FIELD("Filtro Seccion")));
//         }
//         field(50039; "No. Orden"; Integer)
//         {
//             BlankZero = true;

//         }
//         field(50040; "Peligrosidad"; Code[20])
//         {
//             TableRelation = "Codigos peligrosidad";
//             //Description=$003 
//         }
//         field(50041; "Linea vida"; Boolean)
//         {
//             Caption=  'Línea vida';
//             //Description=$003 
//         }
//         field(50042; "Fecha baja"; Boolean)
//         {

//         }
//         field(50043; "Clave orden"; Code[30]) { }//        ;Description=$005 }
//         field(50044; "Empresa"; Enum "Empresa")
//         {//=Común,BAPUEXSA,Basisa,CRUCEROS PROVIDENCIA,ES FORTI 49,Grepsa,Ibiza Publicidad,INVERSIONES EN MEDIOS PUBL.,JUNIPERO SERRA DE CONST.,Malla de Promociones y RR.PP.,Malla de serv. técnicos,Malla Publicidad,Mediterranea,Menorca de Publicidad,PISCIS DOS TRES HACHE,PITOSPORUM,Publicidad Continental,SA VINYA DELS MOSCATELLS,TOLO 54,VIA ROMA Nº 20;
//         }
//         field(50045; "Tipo fijacion"; Enum "Tipo fijacion") { }
//         field(50046; "Observaciones peligrosidad"; Text[80]) { }
//         field(50047; "Nº En Empresa origen"; Code[20]) { }
//         field(50048; "Empresa Origen"; Text[30]) { }
//         field(50049; "Emplazamiento"; Code[20])
//         {
//             FieldClass = FlowField;
//             CalcFormula = Lookup("Emplazamientos x Recursos"."Nº Emplazamiento" WHERE("Nº Recurso" = FIELD("No.")));
//         }
//         field(50050; "Irpf"; Boolean) { }
//         field(50051; "Principal"; Code[20])
//         {
//             FieldClass = FlowField;
//             CalcFormula = Lookup("Default Dimension"."Dimension Value Code" WHERE("Table ID" = CONST(156),
//                                 "No." = FIELD("No."),
//                                 "Dimension Code" = CONST('PRINCIPAL')));
//             TableRelation = "Dimension Value".Code WHERE("Dimension Code" = CONST('PRINCIPAL'));
//             Editable = true;
//         }
//         field(50052; "Soporte"; Code[20])
//         {
//             FieldClass = FlowField;
//             CalcFormula = Lookup("Default Dimension"."Dimension Value Code" WHERE("Table ID" = CONST(156),
//                                 "No." = FIELD("No."),
//                                 "Dimension Code" = CONST('SOPORTE')));
//             TableRelation = "Dimension Value".Code WHERE("Dimension Code" = CONST('SOPORTE'));
//         }
//         field(50053; "Dimensión Zona"; Code[20])
//         {
//             FieldClass = FlowField;
//             CalcFormula = Lookup("Default Dimension"."Dimension Value Code" WHERE("Table ID" = CONST(156),
//                                 "No." = FIELD("No."),
//                                 "Dimension Code" = CONST('ZONA')));
//             TableRelation = "Dimension Value".Code WHERE("Dimension Code" = CONST('ZONA'));
//         }
//         field(51016; "Global Dimension 3 Code"; Code[20])
//         {
//             TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(3));
//             CaptionClass = '1,2,3';

//         }
//         field(51017; "Global Dimension 4 Code"; Code[20])
//         {
//             TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(4));
//             CaptionClass = '1,2,4';
//         }
//         field(51018; "Global Dimension 5 Code"; Code[20])
//         {
//             TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(5));
//             CaptionClass = '1,2,5';
//         }
//         field(51019; "Recurso Agrupado"; Boolean) { }
//         field(51020; "Producción"; Boolean) { }
//         field(51021; "Tipo Recurso principal"; Code[10]) { TableRelation = "Tipo Recurso"; }
//         field(51022; "Zona Comercial"; Code[20]) { TableRelation = "Zonas comerciales".Zona; }
//         field(51023; "PuntoX"; Decimal) {; DecimalPlaces = 8 : 8; }
//         field(51024; "PuntoY"; Decimal) {; DecimalPlaces = 8 : 8; }
//         field(51025; "Customer Price Group"; Code[10])
//         {
//             TableRelation = "Customer Price Group";
//             Caption=  'Categoría Tarifa';
//         }
//         field(51026; "Activo"; Code[20])
//         {
//             FieldClass = FlowField;
//             CalcFormula = Lookup("Fixed Asset"."No." WHERE(Recurso = FIELD("No.")));
//         }
//         field(51027; "Seleccionar"; Boolean) { }
//         field(51028; "Alquiler Anual"; Decimal) { }
//         field(51029; "Local - Alquiler 7 Meses"; Decimal) { }
//         field(51030; "Nacional - Alquiler Anual"; Decimal) { }
//         field(51031; "Nacional - Alquiler 7 Meses"; Decimal) { }
//         field(51032; "Material fijación"; Enum "Material de Fijación")
//         {//Sin especificar,Solo Vinilo,Vinilo y Papel,Vinilo y lona;
//         }

//     }
// }

