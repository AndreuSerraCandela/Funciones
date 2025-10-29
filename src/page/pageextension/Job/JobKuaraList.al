/// <summary>
/// PageExtension JobKuaraList (ID 80110) extends Record Job List.
/// </summary>
pageextension 80110 "JobKuaraList" extends "Job List"
{

    layout
    {
        // Add changes to page layout here
        addafter("No.")
        {
            field("Proyecto Antiguo"; Rec."Proyecto Antiguo")
            {
                ApplicationArea = ALL;
                Caption = 'Nº proyecto aplic. antigua';
            }
            field("Proyecto original"; Rec."Proyecto original")
            {
                ApplicationArea = ALL;

            }
            field("Proyecto Origen"; Rec."Proyecto origen")
            {
                ApplicationArea = ALL;

            }
            field(Contrato; Rec."Nº Contrato")
            {
                ApplicationArea = ALL;
                Caption = 'Nº contrato';
            }
            field(Renovado; Rec.Renovado)
            {
                ApplicationArea = ALL;

            }
            field(Divisa; Rec."Currency Code")
            {
                ApplicationArea = ALL;

            }


            field(Estado; Estado)
            {
                ApplicationArea = ALL;
                trigger OnValidate()
                var

                begin
                    Rec.Validate(Status, Estado);
                end;

            }
            field("Cód. vendedor"; Rec."Cód. vendedor")
            {
                ApplicationArea = ALL;

            }
            field(Bloqueado; Rec.Blocked)
            {
                ApplicationArea = ALL;

            }
            field(Tipo; Rec.Tipo)
            {
                ApplicationArea = ALL;

            }
            field(Subtipo; Rec.Subtipo)
            {
                ApplicationArea = ALL;

            }
            field("Soporte de"; Rec."Soporte de")
            {
                ApplicationArea = ALL;

            }
            field("Fija/Papel"; Rec."Fija/Papel")
            {
                ApplicationArea = ALL;

            }
            field(CreationDate; Rec."Creation Date")
            {
                ApplicationArea = ALL;

            }
            field(StartingDate; Rec."Starting Date")
            {
                ApplicationArea = ALL;

            }
            field(EndingDate; Rec."Ending Date")
            {
                ApplicationArea = ALL;

            }
            field("Interc./Compens."; Rec."Interc./Compens.")
            {
                ApplicationArea = ALL;

            }
            field(Firmado; Rec.Firmado)
            {
                ApplicationArea = ALL;
                Caption = 'Firma Proyecto';
            }
            field("Fecha Firma"; Rec."Fecha Firma")
            {
                ApplicationArea = ALL;
                ShowCaption = false;
            }
            field("Estado Contrato"; Rec."Estado Contrato")
            {
                ApplicationArea = ALL;

            }
            field("Fecha Estado Contrato"; Rec."Fecha Estado Contrato")
            {
                ApplicationArea = ALL;
                ShowCaption = false;
            }
            field("Proyecto en empresa Origen"; Rec."Proyecto en empresa Origen")
            {
                ApplicationArea = ALL;
                Caption = 'Proyecto en empresa origen';
            }



        }
        modify(Status)
        {
            Visible = false;
        }
        modify("Project Manager")
        {
            Visible = false;
        }




    }
    actions
    {
        addfirst(processing)
        {
            action("Crear Proyecto")
            {
                ApplicationArea = All;
                Image = CreateJobSalesInvoice;
                ShortcutKey = 'Ctrl+N';
                trigger OnAction()
                var
                    Res: Record Resource temporary;
                    Asis: Page "Wizard Proyectos";
                    Job: Record Job;
                begin
                    Res.Init();
                    Asis.Carga('');
                    Commit();
                    Asis.RunModal();
                    Commit();
                    Asis.GetRecord(Job);
                    Page.RunModal(Page::"Job Card", Job);

                end;
            }
            action("Crear Proyecto Fijación")
            {
                ApplicationArea = All;
                Image = CreateJobSalesInvoice;
                ShortcutKey = 'Ctrl+N';
                trigger OnAction()
                var
                    Res: Record Resource temporary;
                    Asis: Page "Wizard Proyectos Fijación";
                    Job: Record Job;
                begin
                    Res.Init();
                    Asis.Carga('');
                    Commit();
                    Asis.RunModal();
                    Commit();
                    Asis.GetRecord(Job);
                    Page.RunModal(Page::"Fijación Proyectos", Job);

                end;
            }
            // action("Crear Proyecto Reservas")
            // {
            //     ApplicationArea = All;
            //     Image = CreateLinesFromJob;
            //     ShortcutKey = 'Ctrl+N';
            //     trigger OnAction()
            //     var
            //         Res: Record Resource temporary;
            //         Asis: Page "Wizard Proyectos Fijación";
            //         Job: Record Job;
            //     begin
            //         Res.Init();
            //         Asis.Carga('', true);
            //         Commit();
            //         Asis.RunModal();
            //         Commit();
            //         Asis.GetRecord(Job);
            //         Page.RunModal(Page::"Fijación Proyectos", Job);

            //     end;
            // }
        }
        addlast(Category_New)
        {
            actionref("Crear Job_Promoted"; "Crear Proyecto") { }
            actionref("Crear Job_Fij_Promoted"; "Crear Proyecto Fijación") { }
        }
    }
    trigger OnOpenPage()
    begin
        //Rec.SetRange("Proyecto de fijación", false);
    end;

    trigger OnAfterGetRecord()
    var
        myInt: Integer;
    begin
        Estado := Rec.Status;
    end;

    trigger OnAfterGetCurrRecord()
    var
        myInt: Integer;
    begin
        Estado := Rec.Status;
    end;

    var
        myInt: Integer;
        Estado: Enum "Job Status Kuara";

    /// <summary>
    /// Contrato.
    /// </summary>
    /// <returns>Return value of type Code[20].</returns>
    procedure Contrato(): Code[20]
    var
        SalesHeader: Record "Sales Header";
    begin
        SalesHeader.SetRange("Nº Proyecto", Rec."No.");
        if SalesHeader.FindFirst() then exit(SalesHeader."No.");
    end;
}