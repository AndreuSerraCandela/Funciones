// Headline del Role Center Gestión Medios (patrón estándar BC + RC Headlines User Data).
page 50153 "Headline RC Medios"
{
    ApplicationArea = All;
    Caption = 'Titular Medios';
    PageType = HeadlinePart;
    RefreshOnActivate = true;

    layout
    {
        area(content)
        {
            group(Control1)
            {
                ShowCaption = false;
                Visible = UserGreetingVisible;
                field(GreetingText; RCHeadlinesPageCommon.GetGreetingText())
                {
                    ApplicationArea = All;
                    Caption = 'Saludo';
                    Editable = false;
                }
            }
            group(Control2)
            {
                ShowCaption = false;
                Visible = DefaultFieldsVisible;
                field(DocumentationText; RCHeadlinesPageCommon.GetDocumentationText())
                {
                    ApplicationArea = All;
                    Caption = 'Documentación';
                    DrillDown = true;
                    Editable = false;

                    trigger OnDrillDown()
                    begin
                        HyperLink(RCHeadlinesPageCommon.DocumentationUrlTxt());
                    end;
                }
            }
            group(FijacionFoto1)
            {
                ShowCaption = false;
                Visible = FijacionHeadline1Visible;
                field(FijacionHeadline1Text; FijacionHeadline1Text)
                {
                    ApplicationArea = All;
                    Editable = false;

                    trigger OnDrillDown()
                    begin
                        ControlProcesos.MediosRC_DrillDownFijacionHeadline(1);
                    end;
                }
            }
            group(FijacionFoto2)
            {
                ShowCaption = false;
                Visible = FijacionHeadline2Visible;
                field(FijacionHeadline2Text; FijacionHeadline2Text)
                {
                    ApplicationArea = All;
                    Editable = false;

                    trigger OnDrillDown()
                    begin
                        ControlProcesos.MediosRC_DrillDownFijacionHeadline(2);
                    end;
                }
            }
            group(FijacionFoto3)
            {
                ShowCaption = false;
                Visible = FijacionHeadline3Visible;
                field(FijacionHeadline3Text; FijacionHeadline3Text)
                {
                    ApplicationArea = All;
                    Editable = false;

                    trigger OnDrillDown()
                    begin
                        ControlProcesos.MediosRC_DrillDownFijacionHeadline(3);
                    end;
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        RCHeadlinesPageCommon.HeadlineOnOpenPage(Page::"Headline RC Medios");
        DefaultFieldsVisible := RCHeadlinesPageCommon.AreDefaultFieldsVisible();
        UserGreetingVisible := RCHeadlinesPageCommon.IsUserGreetingVisible();
    end;

    trigger OnAfterGetRecord()
    begin
        ControlProcesos.MediosRC_LoadFijacionHeadlines(
            FijacionHeadline1Text, FijacionHeadline2Text, FijacionHeadline3Text,
            FijacionHeadline1Visible, FijacionHeadline2Visible, FijacionHeadline3Visible);
    end;

    var
        ControlProcesos: Codeunit ControlProcesos;
        RCHeadlinesPageCommon: Codeunit "RC Headlines Page Common";
        DefaultFieldsVisible: Boolean;
        UserGreetingVisible: Boolean;
        FijacionHeadline1Text: Text;
        FijacionHeadline2Text: Text;
        FijacionHeadline3Text: Text;
        FijacionHeadline1Visible: Boolean;
        FijacionHeadline2Visible: Boolean;
        FijacionHeadline3Visible: Boolean;
}
