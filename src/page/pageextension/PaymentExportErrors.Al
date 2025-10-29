/// <summary>
/// PageExtension paymentErrors (ID 80113) extends Record Payment Journal Errors Part.
/// </summary>
pageextension 80113 paymentErrors extends "Payment Journal Errors Part"
{
    layout
    {
        addfirst(Group)
        {
            field("Document No."; DocumentNo)
            {
                Caption = 'Nº Documento';
                ApplicationArea = All;
            }
            field("Nº"; NO)
            {
                Caption = 'Nº';
                ApplicationArea = All;
            }
            field("Cliente/Proveedor"; Cuenta)
            {
                Caption = 'Cliente/Proveedor';
                ApplicationArea = All;
            }
        }
    }
    /// <summary>
    /// Cuenta.
    /// </summary>
    /// <returns>Return value of type Text.</returns>
    procedure Cuenta(): Text
    var
        CarteraDoc: Record "Cartera Doc.";
        PostedDoc: Record "Posted Cartera DOc.";
        ClosedDoc: Record "Closed Cartera Doc.";
    begin
        if ClosedDoc.Get(Rec."Line No.") then
            exit(ClosedDoc."account No.");
        if PostedDoc.Get(Rec."Line No.") then
            exit(PostedDoc."account No.");
        if CarteraDoc.Get(Rec."Line No.") then
            exit(CarteraDoc."account No.");
    end;
    /// <summary>
    /// DocumentNo.
    /// </summary>
    /// <returns>Return value of type Text.</returns>
    procedure DocumentNo(): Text
    var
        CarteraDoc: Record "Cartera Doc.";
        PostedDoc: Record "Posted Cartera DOc.";
        ClosedDoc: Record "Closed Cartera Doc.";
    begin
        if ClosedDoc.Get(Rec."Line No.") then
            exit(ClosedDoc."Document No.");
        if PostedDoc.Get(Rec."Line No.") then
            exit(PostedDoc."Document No.");
        if CarteraDoc.Get(Rec."Line No.") then
            exit(CarteraDoc."Document No.");
    end;
    /// <summary>
    /// NO.
    /// </summary>
    /// <returns>Return value of type Text.</returns>
    procedure NO(): Text
    var
        CarteraDoc: Record "Cartera Doc.";
        PostedDoc: Record "Posted Cartera DOc.";
        ClosedDoc: Record "Closed Cartera Doc.";
    begin
        if ClosedDoc.Get(Rec."Line No.") then
            exit(ClosedDoc."No.");
        if PostedDoc.Get(Rec."Line No.") then
            exit(PostedDoc."No.");
        if CarteraDoc.Get(Rec."Line No.") then
            exit(CarteraDoc."No.");
    end;
}