/// <summary>
/// PageExtension Esquema2 (ID 80250) extends Record Financial Reports.
/// </summary>
pageextension 80119 Esquema2 extends "Financial Reports"
{
    layout
    {
        modify(Name)
        {
            Visible = false;
            ApplicationArea = Basic, Suite;
            ToolTip = 'Specifies the name of the financial report.';
            trigger OnDrillDown()
            var
                AccSchedOverview: Page Panorama;
            begin
                AccSchedOverview.SetAccSchedName(Rec.Name);
                AccSchedOverview.Run();
            end;
        }
        addafter(Name)
        {
            field("Nombre"; Rec."Name")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the name of the financial report.';
                trigger OnAssistEdit()
                var
                    AccSchedOverview: Page Panorama;
                begin
                    AccSchedOverview.SetAccSchedName(Rec.Name);
                    AccSchedOverview.Run();
                end;
            }
        }
    }
    actions
    {
        modify(Overview)
        {
            Visible = false;

        }
        modify(ViewFinancialReport)
        {
            Visible = false;
        }
        addafter(Overview)
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