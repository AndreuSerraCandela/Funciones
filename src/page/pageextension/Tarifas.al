pageextension 80221 Tarifas extends "Item Disc. Groups"
{
    Caption = 'Tarifas';
    InstructionalText = 'Seleccionar Tarifa';


    actions
    {
        modify("Item &Disc. Groups")
        {
            Caption = 'Descuentos Tarifas';
        }
    }


}
