/// <summary>
/// PageExtension PanoramaAf (ID 80171) extends Record 5662.
/// </summary>
pageextension 80171 PanoramaAf extends "FA Posting Types Overview"
{
    layout
    {

        addlast("Matrix Options")
        {
            field("Filtro Fecha"; FiltroFecha)
            {
                ApplicationArea = All;
                trigger OnValidate()
                begin
                    Rec.SetFilter("FA Posting Date Filter", FiltroFecha);
                end;
            }
        }
    }
    var
        FiltroFecha: Text;
}
pageextension 80178 PanoramaAfdet extends "FA Posting Types Overv. Matrix"
{
    layout
    {
        addafter(Description)
        {
            field("Cuenta Coste"; CuentaCoste)
            {
                ApplicationArea = All;
            }
            field("Cuenta Amortización"; CuentaAmortizacion)
            {
                ApplicationArea = All;
            }
            field(Bloqueado; Rec.Bloqueado)
            {
                ApplicationArea = all;
            }
            field(Inactivo; Rec.Inactivo)
            { ApplicationArea = All; }

        }
    }
    /// <summary>
    /// CuentaCoste.
    /// </summary>
    /// <returns>Return value of type Text.</returns>
    procedure CuentaCoste(): Text
    begin
        if Fixed.GET(Rec."FA No.") THEN
            if Posting.GET(Fixed."FA Posting Group") THEN
                EXIT(Posting."Acquisition Cost Account");
    end;

    Procedure CuentaAmortizacion(): Text
    begin
        if Fixed.GET(Rec."FA No.") THEN
            if Posting.GET(Fixed."FA Posting Group") THEN
                EXIT(Posting."Accum. Depreciation Account");
    end;

    trigger OnOpenPage()
    var
        Fa: Record "FA Depreciation Book";

    begin
        if Fa.FindFirst() Then
            Repeat
                if Fixed.GET(Rec."FA No.") THEN begin
                    Fa.Bloqueado := Fixed.Blocked;
                    Fa.Inactivo := Fixed.Inactive;
                    Fa.Modify();
                end;
            until Fa.Next() = 0;
        rEC.SetRange(Inactivo, false);
    end;

    var
        Fixed: Record "Fixed Asset";
        Posting: Record "FA Posting Group";
}