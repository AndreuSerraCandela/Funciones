pageextension 75012 CabeceraPrestamos extends "Cabecera Prestamo"
{
    trigger onOpenPage()
    var
        Control: Codeunit ControlProcesos;
    begin
        If Control.AccesoProibido_Empresas(CompanyName, 'RESTRINGIDO') then
            Error('No tiene permisos para acceder a este punto del menú en esta empresa');

        if DefEmpresa <> '' THEN BEGIN
            Rec.CHANGECOMPANY(DefEmpresa);
            CurrPage.Fdet.Page.Empresa(DefEmpresa);
        END;
    END;

    PROCEDURE Empresa(Cia: Text[30]);
    BEGIN
        DefEmpresa := Cia;
    END;

    VAR
        DefEmpresa: Text[30];
}
pageextension 75013 DetallePrestamos extends "Detalle Prestamo"
{
    VAR
        DefEmpresa: Text[30];

    trigger onOpenPage()
    var
        Control: Codeunit ControlProcesos;
    begin
        If Control.AccesoProibido_Empresas(CompanyName, 'RESTRINGIDO') then
            Error('No tiene permisos para acceder a este punto del menú en esta empresa');
        if DefEmpresa <> '' THEN
            Rec.CHANGECOMPANY(DefEmpresa);
    END;

    PROCEDURE Empresa(Cia: Text[30]);

    BEGIN
        DefEmpresa := Cia;
        Rec.CHANGECOMPANY(Cia);
    END;
}
pageextension 75014 ListaPrestamos extends "Lista Prestamos"
{
    trigger onOpenPage()
    var
        Control: Codeunit ControlProcesos;
    begin
        If Control.AccesoProibido_Empresas(CompanyName, 'RESTRINGIDO') then
            Error('No tiene permisos para acceder a este punto del menú en esta empresa');
    end;
}
pageextension 75015 Prestamos extends Prestamos
{
    layout
    {
        addfirst(Filtros)
        {
            field(Desde; Desde)
            {
                ApplicationArea = All;
                trigger OnValidate()
                begin
                    Contruye();
                    CurrPage.Update();
                end;
            }
            field(Hasta; Hasta)
            {
                ApplicationArea = All;
                trigger OnValidate()
                begin
                    Contruye();
                    CurrPage.Update();
                end;
            }
            field("Solo con Importes Pendiente"; SoloImprePend)
            {
                ApplicationArea = All;
                trigger OnValidate()
                begin
                    Contruye();
                    CurrPage.Update();
                end;
            }

        }
    }
    actions
    {
        addfirst(Processing)
        {
            action(Calcular)
            {
                ApplicationArea = All;
                Scope = Repeater;
                Image = Calculate;
                trigger OnAction()
                var
                    myInt: Integer;
                begin
                    Contruye();
                end;
            }

        }
    }
    trigger onOpenPage()
    var
        Control: Codeunit ControlProcesos;
    begin
        If Control.AccesoProibido_Empresas(CompanyName, 'RESTRINGIDO') then
            Error('No tiene permisos para acceder a este punto del menú en esta empresa');

    END;

    PROCEDURE Contruye();
    VAR
        a: Integer;
        rEmp: Record 2000000006;
        rCab: Record "Cabecera Prestamo";
        rDet: Record "Detalle Prestamo";
        rCab2: Record "Cabecera Prestamo" TEMPORARY;
        rDet2: Record "Detalle Prestamo" TEMPORARY;
        Pendiente: Decimal;
        vtoPrestamo: Date;
        Control: Codeunit ControlProcesos;

        Coltrol: Codeunit ControlProcesos;
    BEGIN
        if Desde = 0D Then Desde := CalcDate('PA-1A+1D', WorkDate());
        rCab.SETFILTER(rCab.Empresa, '<>%1', '');
        rCab.DELETEALL;
        rCab.SETRANGE(rCab.Empresa);
        rDet.SETFILTER(rDet.Empresa, '<>%1', '');
        rDet.DELETEALL;
        rDet.SETRANGE(rDet.Empresa);

        rEmp.SetRange("Evaluation Company", false);
        if rEmp.FINDFIRST THEN
            REPEAT
                if Coltrol.Permiso_Empresas(rEmp.Name) then begin
                    rCab.CHANGECOMPANY(rEmp.Name);
                    rCab.SETFILTER(rCab.Empresa, '<>%1', '');
                    rCab.DELETEALL;
                    rCab.SETRANGE(rCab.Empresa);
                    rDet.CHANGECOMPANY(rEmp.Name);
                    rDet.SETFILTER(rDet.Empresa, '<>%1', '');
                    rDet.DELETEALL;
                    rDet.SETRANGE(rDet.Empresa);

                    if rCab.FINDFIRST THEN
                        REPEAT
                            a := a + 1;
                            rCab2 := rCab;
                            rCab2.Empresa := rEmp.Name;
                            rCab2."Cabecera Prestamo2" := rCab2."Código Del Prestamo";
                            rCab2."Código Del Prestamo" := FORMAT(a) + '#';
                            rCab2.INSERT;
                            rDet.SETRANGE(rDet."Código Del Prestamo", rCab."Código Del Prestamo");
                            if rDet.FINDFIRST THEN
                                REPEAT
                                    rDet2 := rDet;
                                    rDet2.Empresa := rEmp.Name;
                                    rDet2."Código Del Prestamo" := rCab2."Código Del Prestamo";
                                    rDet2.INSERT;
                                UNTIL rDet.NEXT = 0;
                        UNTIL rCab.NEXT = 0;
                end;
            UNTIL rEmp.NEXT = 0;
        rCab.CHANGECOMPANY(COMPANYNAME);
        rDet.CHANGECOMPANY(COMPANYNAME);
        if rCab2.FINDFIRST THEN
            REPEAT
                Pendiente := 0;
                rCab := rCab2;
                rCab.INSERT;
                rDet2.SETRANGE(rDet2."Código Del Prestamo", rCab2."Código Del Prestamo");
                if rDet2.FINDFIRST THEN
                    REPEAT
                        rDet := rDet2;
                        rDet.INSERT;
                    UNTIL rDet2.NEXT = 0;
                Pendiente := Pend(rCab);
                rCab."Importe Pendiente" := Pendiente;
                rCab.Modify();
                vtoPrestamo := Vto(rCab);
                if ((Round(Pendiente, 1, '=') = 0) And (vtoPrestamo < Desde)) or
                 ((Round(Pendiente, 1, '=') = 0) And (SoloImprePend)) then begin
                    rCab.Delete();
                    rDet.SETRANGE(rDet."Código Del Prestamo", rCab."Código Del Prestamo");
                    rDet.DeleteAll();
                end;

            UNTIL rCab2.NEXT = 0;
    END;

    var
        Desde: Date;
        Hasta: Date;
        SoloImprePend: Boolean;
}