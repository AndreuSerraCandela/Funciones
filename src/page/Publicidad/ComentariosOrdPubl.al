page 50019 "Comentario orden publicidad"
{
    PageType = List;
    UsageCategory = Lists;
    SourceTable = "Comentario orden publicidad";
    layout
    {
        area(content)
        {

            repeater(Detalle)
            {
                field(Fecha; Rec.Fecha) { ApplicationArea = ALL; }
                field(Comentario; Rec.Comentario) { ApplicationArea = ALL; }
            }
        }
    }
}
