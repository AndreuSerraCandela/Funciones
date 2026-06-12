/// <summary>
/// Page Contratos Activities (ID 7001298).
/// </summary>
Page 50066 "Systemas Activities"
{
    PageType = CardPart;
    Caption = 'Sistemas';
    RefreshOnActivate = true;
    SourceTable = "Sales Cue";
    Permissions = tabledata "Sales Cue" = rm;
    layout
    {
        area(Content)
        {


            cuegroup("Control Extensiones")
            {

                Visible = MallaAdm;
                field("Extensiones Pendientes"; GExtensionesPendientes())
                {
                    ApplicationArea = All;
                    //DrillDownPageID = "Extension Management";
                    StyleExpr = Extensiones;
                    ToolTip = 'especifica el numero de extensiones pendientes de instalar';
                    trigger OnDrillDown()
                    var
                    begin
                        Message(ExtensionesMensage());
                        Page.RunModal(Page::"Extension Management");
                    end;
                }
            }
            cuegroup("Cola Trabajos")
            {
                Visible = MallaAdm;
                field("Errores"; ErroresCola())
                {
                    ApplicationArea = All;
                    DrillDownPageID = "job queue entries";
                    StyleExpr = Errores;
                    ToolTip = 'especifica el numero de colas con errores';
                    trigger OnDrillDown()
                    begin
                        Message(ErroresMensage());
                        Page.RunModal(Page::"Job Queue Entries");
                    end;
                }
            }
            cuegroup("SII")
            {
                Visible = MallaAdm;
                field("SII pendiente"; SIIPendiente())
                {
                    ApplicationArea = All;
                }
            }
        }
    }
    var
        ContratosPendientes: Integer;

        Extensiones: Text;
        Errores: Text;
        Control: Codeunit ControlProcesos;
        MallaAdm: Boolean;

    trigger OnOpenPage()
    var
        Utilidades: Codeunit Utilitis;
    begin
        Rec.SetRange("Date Filter", CalcDate('PA+1D-1A-3M', Today), CalcDate('PA+3M', Today));
        MallaAdm := Utilidades.PermisoAdm();
    end;

    procedure SIIPendiente(): Integer
    var
        SalesInvHeader: Record "Sales Invoice Header";
        PurchInvHeader: Record "Purch. Inv. Header";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        PurchCrMemoHeader: Record "Purch. Cr. Memo Hdr.";
    begin
        SalesInvHeader.SetRange("Estado", '');
        PurchInvHeader.SetRange("Estado", '');
        SalesCrMemoHeader.SetRange("Estado", '');
        PurchCrMemoHeader.SetRange("Estado", '');
        exit(SalesInvHeader.Count() + PurchInvHeader.Count() + SalesCrMemoHeader.Count() + PurchCrMemoHeader.Count());
    end;

    trigger OnAfterGetRecord()
    begin

        ExtensionesMensage();
        ErroresMensage();
    end;

    [Scope('OnPrem')]
    procedure ExtensionesPendientes(var faltan: integer; var noinstaladas: Integer)
    var
        EnumExtensiones: Enum "Id Extensiones Malla";
        ExtensionManagemet: Codeunit "Extension Management";//IsInstalledByAppId//GetAllExtensionDeploymentStatusEntries//GetAppName
        Name: Text;
        PublishedApp: Record "NAV App Installed App";
        PublishedApp2: Record "NAV App Installed App";
    begin
        foreach Name in EnumExtensiones.Names do begin
            PublishedApp.SetRange("App Id", Name);
            if Not PublishedApp.FindFirst() Then
                faltan += 1
            else
                if not ExtensionManagemet.IsInstalledByAppId(PublishedApp."App ID") then begin
                    NoInstaladas += 1;

                end;
        end;
        if faltan <> 0 Then Extensiones := 'Unfavorable' else Extensiones := 'Favorable';
        if (faltan = 0) and (NoInstaladas <> 0) Then Extensiones := 'Attention';
        //exit(faltan);
    end;

    [Scope('OnPrem')]
    local procedure ExtensionesMensage(): Text
    var
        EnumExtensiones: Enum "Extensiones Malla";
        EnumIdExtensiones: Enum "Id Extensiones Malla";
        IdExtensiones: text;
        Name: Text;
        Textofaltan: Text;
        faltan: Integer;
        NoInstaladas: Integer;
        ExtensionManagemet: Codeunit "Extension Management";//IsInstalledByAppId//GetAllExtensionDeploymentStatusEntries//GetAppName
        PublishedApp: Record "NAV App Installed App";
        a: Integer;
        G: Guid;
    // PublishedApp2: Record "NAV App Installed App";
    begin

        // foreach Name in EnumIdExtensiones.Names do begin
        //     ExtensionManagemet.IsInstalledByAppId(Name);
        // end;
        ExtensionesPendientes(faltan, NoInstaladas);
        If (faltan = 0) and (NoInstaladas = 0) Then Exit('Todas las extensiones están instaladas');
        Textofaltan := 'Las siguientes extensiones no están instaladas: \';
        foreach Name in EnumExtensiones.Names do begin
            PublishedApp.SetRange(Name, Name);
            if Not PublishedApp.FindFirst() Then PublishedApp.Init();
            a := EnumExtensiones.Names.IndexOf(Name);

            EnumIdExtensiones.Names.Get(a, IdExtensiones);
            If G = ExtensionManagemet.GetLatestVersionPackageIdByAppId(IdExtensiones) Then
                //if Not PublishedApp.FindFirst() Then
                Textofaltan += Name + '\'
            else begin
                if not ExtensionManagemet.IsInstalledByAppId(PublishedApp."App ID") then Textofaltan += 'No instalada: ' + Name + '\';
            end;

        end;
        exit(textofaltan);
    end;

    local procedure ErroresCola(): Integer
    var
        Emppresa: Record "Company";
        JobQue: Record "Job Queue Entry";
        faltan: Integer;
        Ojo: Integer;
    begin
        If Emppresa.FindFirst() Then
            repeat
                if Control.Permiso_Empresas(Emppresa.Name) then begin
                    JobQue.ChangeCompany(Emppresa."Name");
                    JobQue.SetFilter("Status", '%1|%2', JobQue."Status"::Error, JobQue."Status"::Waiting);
                    if JobQue.FindFirst() Then
                        repeat
                            if JobQue."Object ID to Run" <> 1441 then
                                faltan += 1 else
                                Ojo += 1;
                        until jobQue.Next() = 0;
                end;
            Until Emppresa.Next() = 0;
        If Emppresa.FindFirst() Then
            repeat
                if Control.Permiso_Empresas(Emppresa.Name) then begin
                    JobQue.ChangeCompany(Emppresa."Name");
                    JobQue.SetRange("Status", JobQue."Status"::Ready);
                    JobQue.SetFilter("Earliest Start Date/Time", '<%1', CurrentDateTime);
                    if JobQue.FindFirst() Then
                        repeat
                            if JobQue."Object ID to Run" <> 1441 then
                                faltan += 1;
                        until jobQue.Next() = 0;
                end;
            Until Emppresa.Next() = 0;
        if faltan <> 0 Then Errores := 'Unfavorable' else Errores := 'Favorable';
        If (faltan = 0) And (Ojo <> 0) Then Errores := 'Attention';

        exit(faltan);
    end;

    local procedure ErroresMensage(): Text
    var
        faltan: Text;
        Emppresa: Record "Company";
        JobQue: Record "Job Queue Entry";
    begin
        if ErroresCola() = 0 Then Exit('No hay errores en la cola');
        faltan := 'Las siguientes colas están en estado de error: \';
        If Emppresa.FindFirst() Then
            repeat
                if Control.Permiso_Empresas(Emppresa.Name) then begin
                    JobQue.ChangeCompany(Emppresa."Name");
                    JobQue.SetFilter("Status", '%1|%2', JobQue."Status"::Error, JobQue."Status"::Waiting);
                    if JobQue.FindFirst() Then
                        repeat
                            JobQue.CalcFields("Object Caption to Run");
                            if JobQue."Object ID to Run" <> 1441 then begin
                                If JobQue.Status = JobQue."Status"::Error then
                                    faltan += Emppresa."Name" + ': ' + JobQue."Object Caption to Run" + '\' else
                                    faltan += Emppresa."Name" + ': ' + JobQue."Object Caption to Run" + ' (En espera)' + '\';
                            end;

                        until jobQue.Next() = 0;
                end;
            Until Emppresa.Next() = 0;
        If Emppresa.FindFirst() Then
            repeat
                if Control.Permiso_Empresas(Emppresa.Name) then begin
                    JobQue.ChangeCompany(Emppresa."Name");
                    JobQue.SetRange("Status", JobQue."Status"::Ready);
                    JobQue.SetFilter("Earliest Start Date/Time", '<%1', CurrentDateTime);
                    if JobQue.FindFirst() Then
                        repeat
                            JobQue.CalcFields("Object Caption to Run");
                            if JobQue."Object ID to Run" <> 1441 then begin
                                faltan += Emppresa."Name" + ': ' + JobQue."Object Caption to Run" + ' (hora vencida)' + '\';
                            end;

                        until jobQue.Next() = 0;
                end;
            Until Emppresa.Next() = 0;
        exit(faltan);
    end;

    local procedure GExtensionesPendientes(): Integer
    var
        faltan: Integer;
        NoInstaladas: Integer;
    begin
        ExtensionesPendientes(faltan, NoInstaladas);
        exit(faltan + NoInstaladas);
    end;

}