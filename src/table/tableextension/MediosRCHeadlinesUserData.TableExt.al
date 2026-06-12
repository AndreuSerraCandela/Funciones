// Mensajes de fijación en el headline del RC Medios (tabla estándar 1458).
tableextension 50155 "Medios RC Headlines Ext" extends "RC Headlines User Data"
{
    fields
    {
        field(60101; "Fijacion Headline 1"; Text[250])
        {
            Caption = 'Fijación headline 1';
        }
        field(60102; "Fijacion Headline 2"; Text[250])
        {
            Caption = 'Fijación headline 2';
        }
        field(60103; "Fijacion Headline 3"; Text[250])
        {
            Caption = 'Fijación headline 3';
        }
        field(60111; "Fijacion Project No. 1"; Code[20])
        {
            Caption = 'Proyecto headline 1';
            TableRelation = Job;
        }
        field(60112; "Fijacion Project No. 2"; Code[20])
        {
            Caption = 'Proyecto headline 2';
            TableRelation = Job;
        }
        field(60113; "Fijacion Project No. 3"; Code[20])
        {
            Caption = 'Proyecto headline 3';
            TableRelation = Job;
        }
    }
}
