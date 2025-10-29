/// <summary>
/// PageExtension PostingAplication (ID 80128) extends Record Post Application.
/// </summary>
pageExtension 80128 PostingAplication extends "Post Application"
{

    layout
    {
        addlast(content)
        {
            group("Solicitar datos")
            {
                Visible = liquida2;
                field(TP; TipoOperacion)
                {
                    Visible = Tipo;
                    ApplicationArea = All;
                    Caption = 'Tipo Operación';
                }
                field(Fec3; PostingDate)
                {
                    Visible = Fecha;
                    ApplicationArea = All;
                    Caption = 'Fecha registro';
                }

                field(FR; PeriodoPago)
                {
                    Visible = true;
                    ApplicationArea = All;
                    Caption = 'Periodo de Pago';
                    TableRelation = "Periodos pago emplazamientos";
                }
                field(Frase; 'El Periodo de Pago se puede dejar en blanco, si solo se factura')
                {
                    ApplicationArea = All;
                    MultiLine = true;
                    Visible = true;
                    Caption = 'El Periodo de Pago se puede dejar en blanco, si solo se factura';
                }
                field(VTASN; bgeneravto)
                {
                    Visible = Vto;
                    ApplicationArea = All;
                    Caption = 'Genera Venciminetos';
                }
                field(VTASN4; bsolprov)
                {
                    Visible = ProvSel;
                    ApplicationArea = All;
                    Caption = 'Solo prov. seleccionado';
                }
            }

        }
        modify(PostingDate)
        {
            Visible = not Liquida2;

        }
        modify(DocNo)
        {
            Visible = not Liquida2;
        }

    }
    VAR
        Liquida2: Boolean;
        TipoOperacion: Option "Solo Prevision","Solo Facturación","Previsión y Facturación";
        PeriodoPago: Text[30];
        bgeneravto: Boolean;
        bsolprov: Boolean;
        PostingDate: Date;
        Vto: Boolean;
        Provsel: Boolean;
        Tipo: Boolean;
        Fecha: Boolean;

    trigger OnOpenPage()
    begin
        bgeneravto := TRUE;
    end;

    PROCEDURE SetValues2(NewOpera: Integer; NewPostingDate: Date);
    VAR
        Control: Codeunit "ControlProcesos";
    BEGIN
        TipoOperacion := NewOpera;
        PostingDate := NewPostingDate;
        Liquida2 := TRUE;
        Tipo := true;
        Fecha := true;
        Provsel := false;
        vto := (Control.CompruebaPermisos(UserSecurityId(), 'EMPLAZA', CompanyName));
    END;

    PROCEDURE GetValues2(VAR NewOpera: Option "Solo Prevision","Solo Facturación","Previsión y Facturación"; VAR NewPostingDate: Date; VAR NewPeriodo: Text[30]; VAR GeneraVto: Boolean);
    BEGIN
        NewOpera := TipoOperacion;
        NewPostingDate := PostingDate;
        NewPeriodo := PeriodoPago;
        GeneraVto := bgeneravto;
    END;

    PROCEDURE SetValues3(NewOpera: Integer; NewPostingDate: Date);
    VAR
        rMie: Record "Access Control";
    BEGIN
        Tipo := true;
        TipoOperacion := NewOpera;
        PostingDate := NewPostingDate;
        Liquida2 := TRUE;
        Tipo := true;
        Fecha := true;
        Provsel := false;
        //CurrPage.fec.VISIBLE:=TRUE;
        vto := false;
        Tipo := FALSE;

    END;

    PROCEDURE SetValuesFacTranf(NewOpera: Integer; NewPostingDate: Date);
    VAR
        rMie: Record "Access Control";
    BEGIN
        TipoOperacion := NewOpera;
        PostingDate := NewPostingDate;
        Liquida2 := TRUE;
        Tipo := true;
        Fecha := true;
        Provsel := false;
        //CurrPage.fec.VISIBLE:=FALSE;
        vto := false;
        Fecha := FALSE;
        Tipo := FALSE;
    END;

    PROCEDURE SetValues4(NewOpera: Integer; NewPostingDate: Date);
    VAR
        Control: Codeunit "ControlProcesos";
    BEGIN
        TipoOperacion := NewOpera;
        PostingDate := NewPostingDate;
        Liquida2 := TRUE;
        Tipo := true;
        Fecha := true;
        Provsel := false;
        //CurrPage.TP.VISIBLE:=FALSE;
        vto := (Control.CompruebaPermisos(UserSecurityId(), 'EMPLAZA', CompanyName));
        Provsel := true;
    END;

    PROCEDURE GetValues4(VAR NewOpera: Option "Solo Prevision","Solo Facturación","Previsión y Facturación"; VAR NewPostingDate: Date; VAR NewPeriodo: Text[30]; VAR GeneraVto: Boolean; VAR NewSoloProv: Boolean);
    BEGIN
        NewOpera := TipoOperacion;
        NewPostingDate := PostingDate;
        NewPeriodo := PeriodoPago;
        GeneraVto := bgeneravto;
        NewSoloProv := bsolprov;
    END;

}