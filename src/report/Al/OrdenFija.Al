/// <summary>
/// Report Crear orden fijación (ID 50098).
/// </summary>
Report 50032 "Crear orden fijación"
{

    ProcessingOnly = true;
    UsageCategory = Tasks;
    ApplicationArea = All;

    dataset
    {
        dataitem(Reserva; Reserva)
        {
            DataItemTableView = SORTING("Nº Recurso", "Fecha inicio", "Fecha fin")
                          WHERE(Estado = FILTER(Reservado | "Reservado fijo"));
            RequestFilterFields = "Nº Recurso", "Nº Proyecto";
            trigger OnPreDataItem()
            BEGIN
                If Empresa <> '' then
                    Reserva.ChangeCompany(Empresa);
                //Reserva.SETRANGE("Fecha inicio", FechaI, FechaI);
                //Reserva.SETRANGE("Fecha fin", FechaF, FechaF);
                Reserva.SetRange(Seleccionar, true);
                rOrden.reset;
                if rOrden.FindLast() THEN
                    a := rOrden."Nº Orden" + 1
                ELSE
                    a := 1;
                If Norden <> 0 THEN
                    a := Norden;
            END;

            trigger OnAfterGetRecord()
            var
                Gtask: Codeunit DropBox;
                TempBlob: Codeunit "Temp Blob";
                DocAttach: Record "Document Attachment";
                Images: Record "Imagenes Orden fijación";
                Instream: Instream;
                Base64: Text;
                Base64Convert: Codeunit "Base64 Convert";
                Url: Text;
                Id: Integer;
                Control: Codeunit "ControlProcesos";
            BEGIN

                // If Primero then begin
                If Norden = 0 Then begin
                    i := i + 1;
                    if "Nº Proyecto" <> Proyecto then begin
                        CLEAR(rOrden);
                        rOrden.RESET;

                        Proyecto := "Nº Proyecto";
                        cuenta := cuenta + 1;
                        rOrden."Nº Orden" := a;
                        rOrden."Fecha generación" := WORKDATE;
                        rOrden.Validate("Fecha fijación", FechaI);
                        rOrden."Nº Proyecto" := Reserva."Nº Proyecto";
                        If Empresa <> '' then rProyecto.ChangeCompany(Empresa);
                        rProyecto.GET(Reserva."Nº Proyecto");
                        rOrden.Fijar := COPYSTR(rProyecto.Description, 1, 30);
                        rOrden."Tipo soporte" := TTipo;
                        repeat
                            rOrden."Nº Orden" := a;
                            a += 1;
                        UNTIL rOrden.Insert();
                    END;
                End else
                    rOrden.Get(Norden);
                If Empresa <> '' then rProyecto.ChangeCompany(Empresa);
                rProyecto.GET(Reserva."Nº Proyecto");
                rOrden.Tapar := COPYSTR(rProyecto.Description, 1, 30);
                If Empresa <> '' then rDia2.ChangeCompany(Empresa);
                rDia2.RESET;
                rDia2.SETCURRENTKEY("Nº Recurso", Fecha);
                rDia2.SETRANGE("Nº Recurso", Reserva."Nº Recurso");
                rDia2.SETFILTER(Fecha, '<%1', Reserva."Fecha inicio");
                rDia2.SETFILTER("Nº Reserva", '<>%1', Reserva."Nº Reserva");
                if rDia2.FIND('+') THEN BEGIN
                    If Empresa <> '' then rProyecto.ChangeCompany(Empresa);
                    rProyecto.GET(rDia2."Nº Proyecto");
                    if not MismoProyecto then
                        if rOrden.Tapar = '' then
                            rOrden.Tapar := COPYSTR(rProyecto.Description, 1, 30);
                END;
                If Empresa <> '' then rRecurs.ChangeCompany(Empresa);
                rRecurs.GET(Reserva."Nº Recurso");
                rOrden.Zona := rRecurs.Zona;
                If Norden = 0 Then
                    rOrden.Modify();
                Primero := FALSE;
                // end;
                If Empresa <> '' then rDia2.ChangeCompany(Empresa);
                rDia2.RESET;
                rDia2.SETCURRENTKEY("Nº Recurso", Fecha);
                rDia2.SETRANGE("Nº Recurso", Reserva."Nº Recurso");
                rDia2.SETFILTER(Fecha, '<%1', Reserva."Fecha inicio");
                rDia2.SETFILTER("Nº Reserva", '<>%1', Reserva."Nº Reserva");
                if rDia2.FIND('+') THEN BEGIN
                    If Empresa <> '' then rProyecto.ChangeCompany(Empresa);
                    rProyecto.GET(rDia2."Nº Proyecto");
                    if not MismoProyecto then
                        rOrden.Tapar := COPYSTR(rProyecto.Description, 1, 30);
                END;
                If Empresa <> '' then rRecurs.ChangeCompany(Empresa);
                rRecurs.GET(Reserva."Nº Recurso");

                rDet.RESET;
                rDet."Nº Orden" := rOrden."Nº Orden";
                //rDet.TransferFields(rOrden);
                rDet."Fecha fijación" := rOrden."Fecha fijación";
                rDet."Fecha generación" := rOrden."Fecha generación";
                rDet."Nº Proyecto" := Reserva."Nº Proyecto";
                rDet.Operario := rOrden.Operario;
                rDet.Fijar := rOrden.Fijar;
                if Not Reserva.Refijar then begin
                    if (Not rDet.Refijacion) then
                        rDet.Tapar := rOrden.Tapar;
                end else
                    rDet.Tapar := '';
                rdet."Tipo Campaña" := rOrden."Tipo Campaña";
                rDet."Tipo de Campaña" := rOrden."Tipo de Campaña";
                rdet.Validado := rOrden.Validado;
                rDet."Nº Orden" := rOrden."Nº Orden";
                rDet."Nº Reserva" := Reserva."Nº Reserva";
                rDet."Nº Recurso" := Reserva."Nº Recurso";
                rdet."Nº Qr" := rDet."Nº Reserva";
                rDet."Empresa" := Empresa;
                rDet.Zona := rRecurs.Zona;
                Clear(TempBlob);
                if rOrden."Tipo soporte" = rOrden."Tipo soporte"::OPI then begin
                    if rRecurs.qr = '' Then
                        gTask.GenerateQRCodeImage('https://gtasks-app.deploy.malla.es/IdQr/' + rDet."Nº Recurso", TempBlob)

                end else
                    gTask.GenerateQRCodeImage('https://gtasks-app.deploy.malla.es/IdQr/' + Format(rDet."Nº Orden") + '-' + Format(rDet."Nº Qr"), TempBlob);
                If (rRecurs.qr = '') or (rOrden."Tipo soporte" <> rOrden."Tipo soporte"::OPI) then begin
                    Clear(Instream);
                    tempblob.CreateInStream(InStream);
                    Base64 := Base64Convert.ToBase64(InStream);
                    Images.SETRANGE("Nº Orden", rDet."Nº Orden");
                    Images.SETRANGE("Nº Imagen", rDet."Nº Qr");
                    Images.DELETEALL;
                    Images.INIT;
                    Images."Nº Orden" := rDet."Nº Orden";
                    Images."Es Qr" := TRUE;
                    Images."Nº Imagen" := rDet."Nº Qr";
                    if rOrden."Tipo soporte" = rOrden."Tipo soporte"::OPI then
                        Images.Nombre := 'Qr_' + Format(rDet."Nº Recurso") + '.png'
                    else
                        Images.Nombre := 'Qr_' + Format(rDet."Nº Orden") + '-' + Format(rDet."Nº Recurso") + '.png';
                end;
                if rRecurs.qr <> '' then begin
                    Images.Url := rRecurs.qr;
                    Base64 := '';
                end;
                If Base64 <> '' then begin
                    if rOrden."Tipo soporte" = rOrden."Tipo soporte"::OPI then begin
                        // Images2.SetRange("Es Qr", true);
                        // Images2.SETRANGE(Images2.Nombre, Images.Nombre);
                        // if Images2.FindFirst() then
                        //     Images.Url := Images2.Url
                        // else
                        Images.Url := Control.FormBase64ToUrl(Base64, Images.Nombre, Images.Id);
                        rRecurs.qr := Images.Url;
                    END else
                        Images.Url := Control.FormBase64ToUrl(Base64, Images.Nombre, Images.Id);


                end;
                If Images.Nombre = '' Then Images.Nombre := 'Imagen_' + Format(Images."Nº Orden") + '.png';
                Images.INSERT;
                cuentaReservas := cuentaReservas + 1;
                rDet.INSERT;
                rReserva2.RESET;
                If Empresa <> '' then
                    rReserva2.ChangeCompany(Empresa);
                rReserva2 := Reserva;
                CASE Reserva.Estado OF
                    Reserva.Estado::Reservado:
                        BEGIN
                            rReserva2.Estado := rReserva2.Estado::Ocupado;
                            If Empresa <> '' then
                                rDia.ChangeCompany(Empresa);
                            rDia.SETRANGE("Nº Reserva", rReserva2."Nº Reserva");
                            rDia.MODIFYALL(Estado, rReserva2.Estado);
                        END;
                    Reserva.Estado::"Reservado fijo":
                        BEGIN
                            rReserva2.Estado := rReserva2.Estado::"Ocupado fijo";
                            If Empresa <> '' then
                                rDia.ChangeCompany(Empresa);
                            rDia.SETRANGE("Nº Reserva", rReserva2."Nº Reserva");
                            rDia.MODIFYALL(Estado, rReserva2.Estado);
                        END;
                END;
                rReserva2.MODIFY;
            END;
        }


    }
    requestpage
    {
        layout
        {
            area(Content)
            {
                group(Opciones)
                {
                    field("Fecha Inicio"; FechaI)
                    {
                        ApplicationArea = All;
                        trigger OnValidate()
                        BEGIN
                            FechaF := FechaI;
                        END;
                    }
                    field("Fecha Fin"; FechaF)
                    {
                        ApplicationArea = All;
                    }
                    field("Tipo Soporte"; TTipo)
                    {
                        ApplicationArea = All;


                    }
                }
            }
        }
    }
    VAR
        Primero: Boolean;
        Proyecto: Code[20];
        rProyecto: Record 167;
        rReserva2: Record Reserva;
        rDia2: Record "Diario Reserva";
        rDia: Record "Diario Reserva";
        rRecurs: Record 156;
        MismoProyecto: Boolean;
        FechaI: Date;
        FechaF: Date;
        rOrden: Record "Cab Orden fijación";
        rDet: Record "Orden fijación";
        i: Integer;
        a: Integer;
        cuenta: Integer;
        cuentaReservas: Integer;
        TTipo: Option " ",Valla,OPI,OTROS;
        finestra: Dialog;
        Norden: Integer;
        Empresa: Text[30];

    trigger OnInitReport()
    BEGIN
        if FechaI = 0D then
            FechaI := WORKDATE;
        if FechaF = 0D then
            FechaF := WORKDATE;
        cuenta := 0;
    END;

    trigger OnPreReport()
    BEGIN
        finestra.OPEN('Generando ordenes.... Un momento, por favor');
        Proyecto := '';
    END;

    trigger OnPostReport()
    BEGIN
        finestra.CLOSE;
        If cuenta = 0 then
            Message('No se han generado ordenes nuevas, pero se han añadido %1 reservas', cuentaReservas);
    END;

    procedure parametrosxEmpresa(pFechaI: Date; pFechaF: Date; pProyecto: Code[20]; pRecurso: Code[20]; Order: Integer; pEmpresa: Text[30])
    var
        Resource: Record Resource;
        Reserva: Record Reserva;
    BEGIN
        Empresa := pEmpresa;
        Reserva.ChangeCompany(Empresa);
        Resource.ChangeCompany(Empresa);
        FechaI := pFechaI;
        FechaF := pFechaF;
        If pProyecto <> '' THEN
            Reserva.SETRANGE("Nº Proyecto", pProyecto);
        If pRecurso <> '' THEN
            Reserva.SETRANGE("Nº Recurso", pRecurso);
        If Reserva.FindFirst() then begin
            Resource.Get(Reserva."Nº Recurso");
            Ttipo := Ttipo::" ";
            If Resource."Tipo Recurso" in ['VALLA', 'VALLAS', 'P.PEATOAL'] then
                TTipo := TTipo::Valla;
            if Resource."Tipo Recurso" in ['OPI', 'OPIS', 'LUM1,5X1,1', 'OPI ROT.', 'PLANIMETRO', 'RELOJ'] then
                TTipo := TTipo::OPI;
            if Resource."Tipo Recurso" in ['INDICADOR', 'VPEATON', 'MEDIANERA'] then
                Ttipo := Ttipo::OTROS;
        end;
        Norden := Order;
    END;

    procedure parametros(pFechaI: Date; pFechaF: Date; pProyecto: Code[20]; pRecurso: Code[20]; Order: Integer; pMismoProyecto: Boolean)
    var
        Resource: Record Resource;

    BEGIN
        MismoProyecto := pMismoProyecto;
        FechaI := pFechaI;
        FechaF := pFechaF;
        If pProyecto <> '' THEN
            Reserva.SETRANGE("Nº Proyecto", pProyecto);
        If pRecurso <> '' THEN
            Reserva.SETRANGE("Nº Recurso", pRecurso);
        If Reserva.FindFirst() then begin
            Resource.Get(Reserva."Nº Recurso");
            Ttipo := Ttipo::" ";
            If Resource."Tipo Recurso" in ['VALLA', 'VALLAS', 'P.PEATOAL'] then
                TTipo := TTipo::Valla;
            if Resource."Tipo Recurso" in ['OPI', 'OPIS', 'LUM1,5X1,1', 'OPI ROT.', 'PLANIMETRO', 'RELOJ'] then
                TTipo := TTipo::OPI;
            if Resource."Tipo Recurso" in ['INDICADOR', 'VPEATON', 'MEDIANERA'] then
                Ttipo := Ttipo::OTROS;
        end;
        Norden := Order;
    END;

}

