/// <summary>
/// PageExtension MarKetingKuara (ID 80123) extends Record Sales Relationship Mgr. Act..
/// </summary>
pageextension 80123 MarKetingKuara extends "Sales & Relationship Mgr. Act."
{
    layout
    {

        addbefore(Opportunities)
        {
            cuegroup(Tareas)
            {
                field(Task; Rec.Interacciones)
                {
                    ApplicationArea = All;
                    Image = Calendar;
                    Caption = 'Reuniones';
                }
                field(Llamadas; Rec.Llamadas)
                {
                    ApplicationArea = All;
                    Image = People;
                    Caption = 'Llamadas';

                }
                field(Actividades; Rec.Actividades)
                {
                    ApplicationArea = All;
                    Image = Checklist;
                    Caption = 'Actividades';

                }

            }
            // cuegroup(Funciones)
            // {
            //     // actions
            //     // {
            //     //     action("Crear tarea")
            //     //     {
            //     //         ApplicationArea = ALL;
            //     //         Caption = '&Crear Tarea';
            //     //         Image = TileBrickCalendar;
            //     //         Promoted = true;
            //     //         PromotedCategory = Process;
            //     //         ToolTip = 'Crear una nueva tarea';

            //     //         trigger OnAction()
            //     //         var
            //     //             TempTask: Record "To-do" temporary;
            //     //             Task: Record "To-do";
            //     //         begin
            //     //             //Task.SetRange("Contact No.",Rec."No.");
            //     //             if Not Task.FindLast() Then begin
            //     //                 Task.Init();
            //     //                 //  Task."Contact No.":=Rec."No.";
            //     //             end;
            //     //             TempTask.CreateTaskFromTask(Task);
            //     //         end;
            //     //     }
            //     // }
            // }
            cuegroup(Interacciones)
            {

                field("Interacciones Contactos"; Rec.Task)
                {
                    ApplicationArea = All;
                    Image = Message;

                }
            }


        }
        addafter("Closed Opportunities")
        {

            field(NoComunicadas; Rec."Oport. Ptes. de Comunicar")
            {
                Caption = 'No comunicadas';
                ApplicationArea = all;
            }
            field(Comunicadas; Rec."Oport. Comunicadas")
            {
                Caption = 'Comunicadas';
                ApplicationArea = all;
            }

        }
        modify("Open Sales Orders")
        {
            Caption = 'Contratos pendientes de firma';
        }
        modify("Open Sales Quotes")
        {
            Caption = 'Ofertas de contrato';
        }

    }


}
