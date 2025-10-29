/// <summary>
/// PageExtension Email Address Lookup (ID 80900) extends Record Email Address Lookup.
/// </summary>
pageextension 80176 "EmailAddressLookup" extends "Email Address Lookup"
{


    actions
    {
        addbefore(Users)
        {
            action(Vendedores)
            {
                ApplicationArea = All;
                Caption = 'Vendedores';
                ToolTip = 'Añade direcciones para vendedores.';
                Image = SalesPurchaseTeam;

                trigger OnAction()
                begin
                    LookupFullAddressList(EntityType::"Salesperson/Purchaser");
                end;

            }
            action(Emplazamientos)
            {
                ApplicationArea = All;
                Caption = 'Emplazamientos';
                ToolTip = 'Añade direcciones para emplazamientos.';
                Image = ContactPerson;

                trigger OnAction()
                begin
                    LookupFullAddressList(EntityType::Emplazamiento);
                end;

            }



        }
        addlast(Category_Category4)
        {

            actionref(Vendedores_Promoted; Vendedores)
            {
            }
            actionref(Emplazamientos_Promoted; Emplazamientos)
            {
            }

        }
    }


}