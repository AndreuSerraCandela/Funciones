pageextension 80166 RelacionDim extends "Dimension Values"
{
    layout
    {
        addafter(Blocked)
        {
            field(Agrupacion; Rec.Agrupacion)
            {
                ApplicationArea = All;

            }
        }
    }
    actions
    {
        addafter("F&unctions")
        {
            action("Relación dimensiones")
            {
                ApplicationArea = All;
                Image = MapDimensions;
                trigger OnAction()
                Var
                    Rel: Record "Relación Dimensiones";
                begin
                    Rel.SetRange("Código Dimension", Rec.Code);
                    Rel.SetRange("Empresa Origen", CompanyName);
                    Page.RunModal(Page::"Relación Dimensiones", Rel);
                end;
            }
        }
    }
}