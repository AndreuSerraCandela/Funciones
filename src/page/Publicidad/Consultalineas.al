/// <summary>
/// Page Consulta líneas proyectoNO SE (ID 50020).
/// </summary>
page 50020 "Consulta líneas proyectoNO SE"
{
    PageType = List;
    UsageCategory = Lists;
    Editable = false;
    SourceTable = 1003;
    SourceTableView = SORTING("Job No.", "Job Task No.", "Schedule Line", "Planning Date")
                    WHERE("Line Type" = CONST(Budget));
    DataCaptionFields = "Job No.";
    Permissions =
        tabledata Job = R,
        tabledata "Job Planning Line" = RM;


    layout
    {
        area(Content)
        {
            repeater(Detalle)
            {

                field("Job No."; Rec."Job No.")
                {
                    ApplicationArea = all;

                    // OnFormat=BEGIN
                    //         if Nivel = 1 THEN
                    //             CurrForm."Job No.".UPDATEFONTBOLD := TRUE
                    //         ELSE
                    //             Text:='';
                    //         END;
                }
                field(Descriptionproyecto; rProyecto.Description)
                {
                    ApplicationArea = all;
                    Caption = 'Descripción proyecto';
                    // OnFormat=BEGIN
                    //         if Nivel = 1 THEN
                    //             CurrForm.ProyDes.UPDATEFONTBOLD := TRUE
                    //         ELSE
                    //             Text:='';
                    // END;
                }
                field(Nombre; rProyecto."Bill-to Name")
                {
                    ApplicationArea = all;
                    Caption = 'Factura a nombre';
                    // OnFormat=BEGIN
                    //         if Nivel = 1 THEN
                    //             CurrForm.ProyCli.UPDATEFONTBOLD := TRUE
                    //         ELSE
                    //             Text:='';
                    //         END;
                }
                field("Fecha Inicio proyecto"; rProyecto."Starting Date")
                {
                    Caption = 'Fecha inicial proyecto';
                    ApplicationArea = all;
                    // OnFormat=BEGIN
                    // if Nivel = 1 THEN
                    //     CurrForm.ProyFecIni.UPDATEFONTBOLD := TRUE
                    // ELSE
                    //     Text:='';
                    // END;
                }
                field("Fecha final proyecto"; rProyecto."Ending Date")
                {
                    Caption = 'Fecha final proyecto';
                    ApplicationArea = all;
                    // OnFormat=BEGIN
                    // if Nivel = 1 THEN
                    //     CurrForm.ProyFecIni.UPDATEFONTBOLD := TRUE
                    // ELSE
                    //     Text:='';
                    // END;
                }
                field("Tipo proyecto"; rProyecto.Tipo)
                {
                    Caption = 'Tipo proyecto';
                    ApplicationArea = all;
                    Visible = false;
                    // OnFormat=BEGIN
                    // if Nivel = 1 THEN
                    //     CurrForm.Tipo.UPDATEFONTBOLD := TRUE
                    // ELSE
                    //     Text:='';
                    // END;
                }
                field("SubTipo proyecto"; rProyecto.SubTipo)
                {
                    Caption = 'Subtipo proyecto';
                    ApplicationArea = all;
                    Visible = false;
                    // OnFormat=BEGIN
                    //         if Nivel = 1 THEN
                    //             CurrForm.ProySub.UPDATEFONTBOLD := TRUE
                    //         ELSE
                    //             Text:='';
                    //         END;
                }
                field("Soporte de proyecto"; rProyecto."Soporte de")
                {
                    Caption = 'Soprte de proyecto';
                    ApplicationArea = all;
                    Visible = false;
                    // OnFormat=BEGIN
                    //         if Nivel = 1 THEN
                    //             CurrForm.ProySop.UPDATEFONTBOLD := TRUE
                    //         ELSE
                    //             Text:='';
                    //         END;
                }
                field("Fija/Papel proyecto"; rProyecto."Fija/Papel")
                {
                    Caption = 'Fija/Papel proyecto';
                    ApplicationArea = all;
                    Visible = false;
                    // OnFormat=BEGIN
                    //         if Nivel = 1 THEN
                    //             CurrForm.ProyFiPa.UPDATEFONTBOLD := TRUE
                    //         ELSE
                    //             Text:='';
                    // END;
                }
                field("Planning Date"; Rec."Planning Date")
                {
                    Caption = 'Fecha inicial recurso';
                    ApplicationArea = all;
                    ;
                    // OnFormat=BEGIN
                    //         if (Nivel = 1) AND (NOT VerTodo) THEN
                    //             Text:='';
                    // END;

                    trigger OnValidate()
                    var
                    BEGIN
                        CurrPage.SAVERECORD;
                    END;
                }
                field("Fecha Final Recurso"; Rec."Fecha Final")
                {
                    Caption = 'Fecha final recurso';
                    ApplicationArea = all;
                    // OnFormat=BEGIN
                    //         if (Nivel = 1) AND (NOT VerTodo) THEN
                    //             Text:='';
                    // END;
                }
                field("Job Task No."; Rec."Job Task No.")
                {
                    Caption = 'Tarea';
                    ApplicationArea = all;
                    Visible = false;
                    // OnFormat=BEGIN
                    // if (Nivel = 1) AND (NOT VerTodo) THEN
                    //     Text:='';
                    // END;
                }
                field(Type; Rec.Type)
                {
                    Caption = 'Tipo';
                    ApplicationArea = all;
                    // OnFormat=BEGIN
                    //         if (Nivel = 1) AND (NOT VerTodo) THEN
                    //             Text:='';
                    // END;
                }
                field("No."; Rec."No.")
                {
                    Caption = 'Nº';
                    ApplicationArea = all;
                    // OnFormat=BEGIN
                    // if (Nivel = 1) AND (NOT VerTodo) THEN
                    //     Text:='';
                    // END;
                }
                field("No Orden Recurso"; Rec."No. Orden Publicidad")
                {
                    ApplicationArea = all;
                    Visible = false;
                    Editable = false;

                    // OnFormat=BEGIN
                    // if (Nivel = 1) AND (NOT VerTodo) THEN
                    //     Text:='';
                    // END;
                }
                field("Nombre Soporte"; Rec."Nombre Soporte")
                {
                    ApplicationArea = all;
                    Visible = false;
                    Editable = false;
                    // OnFormat=BEGIN
                    // if (Nivel = 1) AND (NOT VerTodo) THEN
                    //     Text:='';
                    // END;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = all;
                    Visible = false;
                    // OnFormat=BEGIN
                    // if (Nivel = 1) AND (NOT VerTodo) THEN
                    //     Text:='';
                    // END;
                }
                field("Description 2"; Rec."Description 2")
                {
                    ApplicationArea = all;
                    Visible = false;
                    // OnFormat=BEGIN
                    // if (Nivel = 1) AND (NOT VerTodo) THEN
                    //     Text:='';
                    // END;
                }
                field("Shortcut Dimension 1 Code"; Rec."Shortcut Dimension 1 Code")
                {
                    ApplicationArea = all;
                    Visible = false;
                    // OnFormat=BEGIN
                    // if (Nivel = 1) AND (NOT VerTodo) THEN
                    //     Text:='';
                    // END;
                }
                field("Shortcut Dimension 2 Code"; Rec."Shortcut Dimension 2 Code")
                {
                    ApplicationArea = all;
                    Visible = false;
                    // OnFormat=BEGIN
                    // if (Nivel = 1) AND (NOT VerTodo) THEN
                    //     Text:='';
                    // END;
                }
                field("Tipo Recurso"; rec."Tipo Recurso")
                {
                    ApplicationArea = all;
                    // OnFormat=BEGIN
                    // if (Nivel = 1) AND (NOT VerTodo) THEN
                    //     Text:='';
                    // END;
                }
                field(Tipo; Rec.Tipo)
                {
                    ApplicationArea = all;
                    // OnFormat=BEGIN
                    // if (Nivel = 1) AND (NOT VerTodo) THEN
                    //     Text:='';
                    // END;
                }
                field("Soporte de"; Rec."Soporte de")
                {
                    ApplicationArea = all;
                    // OnFormat=BEGIN
                    // if (Nivel = 1) AND (NOT VerTodo) THEN
                    //     Text:='';
                    // END;
                }
                field("Fija/Papel"; Rec."Fija/Papel")
                {

                    ApplicationArea = all;
                    // OnFormat=BEGIN
                    // if (Nivel = 1) AND (NOT VerTodo) THEN
                    //     Text:='';
                    // END;
                }
            }
        }
    }
    actions
    {
        area(Navigation)
        {
            group("&Job")
            {
                Image = Job;
                Caption = 'Pro&yecto';
                action("Mostrar &Líneas")
                {
                    Caption = 'Mostrar &Líneas';
                    Image = JobLines;
                    ApplicationArea = ALL;
                    trigger OnAction()
                    BEGIN
                        //Rec.SETRANGE(Nivel);

                        VerTodo := TRUE;
                    END;
                }
                action("Mostrar &Cabecera")
                {
                    Caption = 'Mostrar &Cabecera';
                    Image = Job;
                    ApplicationArea = ALL;
                    trigger OnAction()
                    BEGIN
                        //Rec.SETRANGE(Nivel,1);

                        VerTodo := false;
                    END;
                }

            }
        }
    }
    VAR
        TempLinProy: Record 1003 TEMPORARY;
        rProyecto: Record 167;
        wJobAnt: Code[20];
        VerTodo: Boolean;

    trigger OnOpenPage()
    BEGIN
        FiltrosNivel;

        VerTodo := FALSE;
    END;

    trigger OnAfterGetRecord()
    BEGIN
        if NOT rProyecto.GET(Rec."Job No.") THEN
            rProyecto.INIT;
    END;

    PROCEDURE FiltrosNivel();
    BEGIN
        //   TempLinProy.COPYFILTERS(Rec);

        //   Rec.SETRANGE(Nivel,1);
        //   if FIND('-') THEN BEGIN
        //     REPEAT
        //       Rec.Nivel:=0;
        //       Rec.MODIFY;
        //     UNTIL Rec.NEXT = 0;
        //   END;

        Rec.RESET;
        Rec.COPYFILTERS(TempLinProy);
        CLEAR(wJobAnt);
        if Rec.FIND('-') THEN BEGIN
            REPEAT
                if Rec."Job No." <> wJobAnt THEN BEGIN
                    //Rec.Nivel:=1;
                    wJobAnt := Rec."Job No.";
                    Rec.MODIFY;
                END;
            UNTIL Rec.NEXT = 0;
        END;

        //Rec.SETRANGE(Nivel,1);
    END;


}