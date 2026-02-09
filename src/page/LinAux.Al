/// <summary>
/// Page SubForm Lineas Auxiliares (ID 50053).
/// </summary>
page 50021 "SubForm Lineas Auxiliares"
{
    //Version List=FH3.70,FINTIS,PAG,ES;
    PageType = ListPart;
    Caption = 'SubForm Lineas Auxiliares';
    InsertAllowed = false;
    DeleteAllowed = false;
    //area(Content){ Repeater(Detalle){ID=1;
    SourceTable = "Lineas Auxiliares";
    AutoSplitKey = true;
    //UpdateOnActivate=Yes;

    layout
    {
        area(Content)
        {
            repeater(Detalle)
            {
                field("Nº Linea"; Rec."Nº Linea") { ApplicationArea = All; }


                //    { 3   ;Label        ;0    ;0    ;0    ;0    ;

                field(Proveedor; Rec.Proveedor) { ApplicationArea = All; }



                //    { 5   ;Label        ;0    ;0    ;0    ;0    ;

                field("Fecha Vto."; Rec."Fecha Vto.") { ApplicationArea = All; }



                //    { 11  ;Label        ;0    ;0    ;0    ;0    ;

                field(Importe; Rec.Importe) { ApplicationArea = All; }



                //    { 13  ;Label        ;0    ;0    ;0    ;0    ;

                field(Banco; Rec.Banco) { ApplicationArea = All; }


                //    { 7   ;Label        ;0    ;0    ;0    ;0    ;

                field("Shortcut Dimension 1 Code"; Rec."Shortcut Dimension 1 Code") { ApplicationArea = All; }



                //    { 9   ;Label        ;0    ;0    ;0    ;0    ;

                field("Shortcut Dimension 2 Code"; Rec."Shortcut Dimension 2 Code") { ApplicationArea = All; }



                //    { 15  ;Label        ;0    ;0    ;0    ;0    ;

                field(wCodTermPago; wCodTermPago)
                {
                    ApplicationArea = All;
                    Caption = 'Cód. Termino Pago';
                }
                //    { 1100244003;Label  ;0    ;0    ;0    ;0    ;

                field("Cod. auditoria"; Rec."Cod. auditoria") { ApplicationArea = All; }



                //    { 19  ;Label        ;0    ;0    ;0    ;0    ;

            }
        }
    }
    VAR
        wCodTermPago: Code[10];
        rProveedor: Record Vendor;

    trigger OnAfterGetRecord()
    BEGIN

        CLEAR(wCodTermPago);
        if rProveedor.GET(Rec.Proveedor) THEN
            wCodTermPago := rProveedor."Payment Terms Code"
        ELSE
            wCodTermPago := '';
    END;


    //     BEGIN
    //     {
    //       CAT 30-03-06 Dejamos editable el campo fecha vencimiento
    //     }
    //     END.
    //   }
}