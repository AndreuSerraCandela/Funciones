tableextension 50143 "Panel Medios Salesperson" extends "Salesperson/Purchaser"
{
    fields
    {
        field(60121; "Panel Medios Sum Tot Cont"; Decimal)
        {
            Caption = 'Panel Medios sum. tot. cont.';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(60122; "Panel Medios Sum Posted"; Decimal)
        {
            Caption = 'Panel Medios sum. facturado';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(60123; "Panel Medios Sum Tot Cont Ant"; Decimal)
        {
            Caption = 'Panel Medios sum. tot. cont. ant.';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(60124; "Panel Medios Sum Posted Ant"; Decimal)
        {
            Caption = 'Panel Medios sum. facturado ant.';
            DataClassification = CustomerContent;
            Editable = false;
        }
    }
}
