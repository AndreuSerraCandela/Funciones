/// <summary>
/// PageExtension DocAttch (ID 80118) extends Record Document Attachment Details.
/// </summary>
pageextension 80118 DocAttch extends "Document Attachment Details"
{
    layout
    {
        addafter("File Type")
        {
            field(Confidencial; Rec.Confidencial)
            {
                ApplicationArea = All;
                Caption = 'Confidencial';
                ToolTip = 'Confidencial';
                Visible = Permisos;
            }
            // field(Confidencialidad; Rec.Confidencialidad)
            // {
            //     ApplicationArea = All;
            //     Caption = 'Confidencialidad';
            //     ToolTip = 'Elija los grupos separados por |';

            // }

        }
    }
    trigger OnOpenPage();
    var
        UserGrup: Record "Security Group Member Buffer" temporary;// "User Group Member";
        SegurityGroup: Codeunit "Security Group";
        Control: Codeunit ControlProcesos;
    begin
        if not Control.CompruebaPermisos(UserSecurityId(), 'CONFIDENCIAL', CompanyName) then
            Rec.setrange(Confidencial, false);
        Permisos := Control.CompruebaPermisos(UserSecurityId(), 'CONFIDENCIAL', CompanyName);
        SegurityGroup.GetMembers(UserGrup);
        UserGrup.SetRange("User Security ID", UserSecurityId);
        UserGrup.SetFilter("Security Group Code", '<>%1', '');
        if UserGrup.FindSet() then begin
            repeat
                if UserGrup."Security Group Code" = 'TODOS' then begin
                    Rec.SetFilter("Grupos Usuario", 'TODOS');
                    break;
                end;
                if Rec.GetFilter("Grupos Usuario") = '' then
                    Rec.SetFilter("Grupos Usuario", UserGrup."Security Group Code")
                else
                    Rec.SetFilter("Grupos Usuario", Rec.GetFilter("Grupos Usuario") + '|' + UserGrup."Security Group Code");


            until UserGrup.Next() = 0;
            Rec.SetFilter("Grupos Usuario", '%1|%2', '', Rec.GetFilter("Grupos Usuario"));
            Rec.SetRange("Permiso Usuarios", true);
        end;
    end;


    var
        Permisos: Boolean;




}