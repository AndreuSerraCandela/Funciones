/// <summary>
/// PageExtension Esquema (ID 80145) extends Record Account Schedule Names.
/// </summary>
pageextension 80145 Esquema extends "Account Schedule Names"
{
    actions
    {
        // TODO: - Revisar en próxima versión
#pragma warning disable AL0432
#if not CLEAN27
        modify(Overview)
#pragma warning restore AL0432
        // TODO: - Revisar en próxima versión
        {
            Visible = false;

        }
#endif
        addafter(EditAccountSchedule)
        {
            action(Panorama)
            {
                ApplicationArea = All;
                Ellipsis = true;
                Image = ViewDetails;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                ToolTip = 'See an overview of the current account schedule based on the current account schedule name and column layout.';

                trigger OnAction()
                var
                    AccSchedOverview: Page Panorama;
                begin
                    AccSchedOverview.SetAccSchedName(Rec.Name);
                    AccSchedOverview.Run();
                end;
            }
        }
    }
}
