/// <summary>
/// PageExtension PriceList (ID 80191) extends Record Price List Line Review.
/// </summary>
pageextension 80191 PriceList extends "Price List Line Review"
{
    layout
    {
        addafter("Source Type")
        {
            field(Agencia; Rec.Agencia)
            {
                ApplicationArea = All;
            }
        }
        modify("Source No.")
        {
            Visible = false;
        }
        modify("Source Type")
        {
            Visible = false;
        }
        modify("Currency Code")
        {
            Visible = false;
        }
        modify("Asset Type")
        {
            Caption = 'Tipo Tarifa';
            Visible = false;
        }
        addafter("Asset Type")
        {
            field("Tipo Tarifa"; Rec."Tipo de tarifa")
            {
                ApplicationArea = All;
            }
        }
        addbefore("Minimum Quantity")
        {
            field("Tipo Duracion"; Rec."Tipo Duracion")
            {
                ApplicationArea = All;
            }
            field("Duracion"; Rec."Duracion")
            {
                ApplicationArea = All;
            }
        }
        modify("Asset No.")
        {
            Caption = 'Categoría Tarifa';
            Visible = false;
        }
        addafter("Asset No.")
        {
            field("Categoría Tarifa"; Rec."Asset No.")
            {
                ApplicationArea = All;
            }
        }
        addafter("Unit Price")
        {
            //Precios alquiler
            field("Local -Alquiler 7 Meses"; Rec."Local - Alquiler 7 Meses")
            {

            }
            field("Nacional - Alquiler Anual"; Rec."Nacional - Alquiler Anual")
            {

            }
            field("Nacional - Alquiler 7 Meses"; Rec."Nacional - Alquiler 7 Meses")
            {

            }
            field("Local -Alquiler Mensula"; Rec."Local - Alquiler 1 Mes")
            {

            }
            field("Nacional - Alquiler Mensual"; Rec."Nacional - Alquiler 1 Mes")
            {

            }

        }
    }
}
pageextension 80222 PriceListLine extends "Price List Lines"
{
    layout
    {
        addafter(SourceType)
        {
            field(Agencia; Rec.Agencia)
            {
                ApplicationArea = All;
            }
        }
        addbefore("Minimum Quantity")
        {
            field("Tipo Duracion"; Rec."Tipo Duracion")
            {
                ApplicationArea = All;
            }
            field("Duracion"; Rec."Duracion")
            {
                ApplicationArea = All;
            }
        }
        modify(SourceNo)
        {
            Visible = false;
        }
        modify(SourceType)
        {
            Visible = false;
        }
        modify(CurrencyCode)
        {
            Visible = false;
        }
        modify("Asset Type")
        {
            Caption = 'Tipo Tarifa';
            Visible = false;
        }
        addafter("Asset Type")
        {
            field("Tipo Tarifa"; Rec."Tipo de tarifa")
            {
                ApplicationArea = All;
            }
        }
        modify("Asset No.")
        {
            Caption = 'Categoría Tarifa';
            Visible = false;
        }
        addafter("Asset No.")
        {
            field("Categoría Tarifa"; Rec."Asset No.")
            {
                ApplicationArea = All;
            }
        }
        addafter("Unit Price")
        {
            //Precios alquiler
            field("Local -Alquiler 7 Meses"; Rec."Local - Alquiler 7 Meses")
            {

            }
            field("Nacional - Alquiler Anual"; Rec."Nacional - Alquiler Anual")
            {

            }
            field("Nacional - Alquiler 7 Meses"; Rec."Nacional - Alquiler 7 Meses")
            {

            }
            field("Local -Alquiler Mensula"; Rec."Local - Alquiler 1 Mes")
            {

            }
            field("Nacional - Alquiler Mensual"; Rec."Nacional - Alquiler 1 Mes")
            {

            }

        }
    }
}