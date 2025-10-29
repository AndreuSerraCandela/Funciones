
page 50071 "Grupo de empresas"
{
    PageType = List;
    UsageCategory = Lists;
    SourceTable = "Grupo de empresas";

    layout
    {
        area(Content)
        {
            Repeater(Detalle)
            {
                field(Codigo; Rec.Codigo) { ApplicationArea = All; }
                field(Descripcion; Rec.Descripcion) { ApplicationArea = All; }
            }
        }
    }
    actions
    {
        area(Navigation)
        {
            action("Empresas")
            {
                Caption = 'Empresas';
                RunObject = Page "Lista empresas grupo";
                //RunPageLinkType=OnUpdate;
                RunPageLink = "Cod. grupo" = FIELD(Codigo);
            }
        }
    }

}



page 50073 "Lista grupos empresas"
{
    SourceTable = "Grupo de empresas";
    PageType = List;
    UsageCategory = Lists;


    layout
    {
        area(Content)
        {
            Repeater(Detalle)
            {
                field(Codigo; Rec.Codigo) { ApplicationArea = All; }
                field(Descripcion; Rec.Descripcion) { ApplicationArea = All; }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action("Saldo Inter Empresas Detalle")
            {
                ApplicationArea = All;
                Image = Company;
                trigger OnAction()
                begin
                    Page.RunModal(Page::"Saldo Interempresas det");
                end;
            }
        }
    }
    trigger OnOpenPage()
    BEGIN
        CurrPage.EDITABLE := NOT CurrPage.LOOKUPMODE;
    END;

}
page 50075 "Lista de códigos de agrupación"
{
    PageType = List;
    UsageCategory = Lists;
    Editable = false;
    //area(Content){ Repeater(Detalle){ID=1;
    SourceTable = "Empresa grupo";

    layout
    {
        area(Content)
        {
            Repeater(Detalle)
            {
                field("Cod. grupo"; Rec."Cod. grupo") { ApplicationArea = All; }
            }
        }

    }
}
