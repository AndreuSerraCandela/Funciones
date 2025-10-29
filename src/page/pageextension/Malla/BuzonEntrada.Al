pageextension 75000 BuzonEntrada extends "Buzón Entrada"
{
    layout
    {
        addafter("Empresa Seleccionda")
        {
            field(Facturas; Fact(''))
            { ApplicationArea = All; }
            field(Abonos; Abono(''))
            { ApplicationArea = All; }
        }
        addlast(Empresas)
        {
            field(LFacturas; Fact(Rec.Name)) { ApplicationArea = All; Caption = 'Facturas'; }
            field(LAbono; Abono(Rec.Name)) { ApplicationArea = All; Caption = 'Abonos'; }
        }
        addlast(Content)
        {
            group(DetalleFacturas)
            {
                Caption = 'Facturas';
                part(subf; "Lista de facturas") { ApplicationArea = All; }
            }
            group(DetalleAbonos)
            {
                Caption = 'Abonos';
                part(suba; "Lista de Abonos") { ApplicationArea = All; }
            }
        }
    }

    VAR
        Text015: Label 'El usuario no está debidamente registrado';
        Text016: Label 'El hotel de trabajo no está parametrizado';
        Text017: Label 'Reservas Anuladas';
        Text018: Label 'Reservas No Show';
        Text019: Label 'Histórico de reservas';
        Text020: Label 'Consulta de reservas';
        Text022: Label 'No tiene autorización para ejecutar esta opción';
        rIc: Record 413;
        r112: Record 112;
        Ventana: Dialog;
        Emp: Integer;
        rEmp: Record 2000000006 TEMPORARY;
        r114: Record 114;
        rInf: Record "IC Setup";

    trigger OnOpenPage()
    VAR
        wEmpresa: Text[30];
        rCust: Record Customer;
        Control: Codeunit ControlProcesos;
    BEGIN

        Rec.CLEARMARKS;
        rInf.GET;
        rIc.GET(rInf."IC Partner Code");
        Rec.SetRange("Evaluation Company", false);
        Ventana.OPEN('Buscando Facturas en Empresa ####################1##');
        if Rec.FINDFIRST THEN
            REPEAT
                if Control.Permiso_Empresas(Rec.Name) then begin
                    wEmpresa := Rec.Name;
                    rInf.ChangeCompany(wEmpresa);
                    rInf.Get;
                    rInf.Cuenta := 0;
                    rInf.Cuenta2 := 0;
                    rInf.Modify();
                    rInf.Get;
                    rCust.CHANGECOMPANY(wEmpresa);
                    rCust.SETRANGE(rCust."IC Partner Code", rIc.Code);
                    if rCust.FINDFIRST THEN
                        Repeat
                            Ventana.UPDATE(1, wEmpresa);
                            r112.CHANGECOMPANY(wEmpresa);
                            r112.SETRANGE("Sell-to Customer No.", rCust."No.");
                            r112.SETRANGE("Pte Contabilicación", TRUE);
                            if r112.FINDFIRST THEN BEGIN
                                Rec.MARK := TRUE;
                                rInf.Cuenta := r112.COUNT;
                                rInf.Modify();

                            end;
                            r114.CHANGECOMPANY(wEmpresa);
                            r114.SETRANGE("Sell-to Customer No.", rCust."No.");
                            r114.SETRANGE("Pte Contabilicación", TRUE);
                            if r114.FINDFIRST THEN BEGIN
                                Rec.MARK := TRUE;
                                rInf.Cuenta2 := r114.COUNT;
                                rInf.Modify();
                            end;


                        UNTIL rCust.NEXT = 0;
                end;
            UNTIL Rec.NEXT = 0;
        Rec.MARKEDONLY := TRUE;
        Ventana.CLOSE;
        if NOT Rec.FINDFIRST THEN
            MESSAGE('No hay nada pendiente')
        else
            Emp := Rec.Count;
        // EXIT;

        CurrPage.subf.page.Empresa(Rec.Name, TRUE, TRUE);
        CurrPage.suba.page.Empresa(Rec.Name, TRUE, TRUE);
    END;

    trigger OnAfterGetCurrRecord()
    BEGIN
        CurrPage.subf.Page.Empresa(Rec.Name, TRUE, FALSE);
        CurrPage.suba.Page.Empresa(Rec.Name, TRUE, FALSE);
    END;

    PROCEDURE Fact(wEmpresa: Text[30]): Integer;
    var
        Control: Codeunit ControlProcesos;
        Fac: Integer;
        rEmp: Record 2000000006;
    BEGIN
        rEmp.SetRange(Name);
        If wEmpresa <> '' then rEmp.SetRange(Name, wEmpresa);
        If rEmp.FindFirst() THEN
            REPEAT
                if Control.Permiso_Empresas(rEmp.Name) THEN begin
                    rInf.ChangeCompany(rEmp.Name);
                    rInf.Get;
                    Fac += (rInf.Cuenta);
                end;
            UNTIL rEmp.NEXT = 0;

        rEmp.SetRange(Name);
        exit(Fac);
    END;

    PROCEDURE Abono(wEmpresa: Text[30]): Integer;
    var
        Control: Codeunit ControlProcesos;
        Fac: Integer;
        rEmp: Record 2000000006;
    BEGIN
        rEmp.SetRange(Name);
        If wEmpresa <> '' then rEmp.SetRange(Name, wEmpresa);
        If rEmp.FindFirst() THEN
            REPEAT
                if Control.Permiso_Empresas(rEmp.Name) THEN begin
                    rInf.ChangeCompany(rEmp.Name);
                    rInf.Get;
                    Fac += (rInf.Cuenta2);
                end;
            UNTIL rEmp.NEXT = 0;

        rEmp.SetRange(Name);
        exit(Fac);
    END;


}