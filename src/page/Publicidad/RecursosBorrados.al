/// <summary>
/// Page Resource List 2 (ID 50016).
/// </summary>
page 50016 "Resource List 2"
{
    AdditionalSearchTerms = 'capacity,job,project';
    ApplicationArea = All;
    Caption = 'Lista Resoursos Borrados';
    Editable = false;
    PageType = List;
    PromotedActionCategories = 'New,Process,Report,Resource,Navigate,Prices & Discounts';
    SourceTable = Resource3;
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field("No."; Rec."No.")
                {
                    ApplicationArea = Jobs;
                    ToolTip = 'Specifies the number of the involved entry or record, according to the specified number series.';
                }
                field(Nombre; Rec.Name)
                {
                    ApplicationArea = Jobs;
                    ToolTip = 'Specifies a description of the resource.';
                }
                field(Tipo; Rec.Type)
                {
                    ApplicationArea = Jobs;
                    ToolTip = 'Specifies whether the resource is a person or a machine.';
                }
                field("Unidad de medida"; Rec."Base Unit of Measure")
                {
                    ApplicationArea = Jobs;
                    ToolTip = 'Specifies the base unit used to measure the resource, such as hour, piece, or kilometer.';
                }
                field("Familia"; Rec."Resource Group No.")
                {
                    ApplicationArea = Jobs;
                    ToolTip = 'Specifies the resource group that this resource is assigned to.';
                    Visible = false;
                }

            }
        }
    }
}

