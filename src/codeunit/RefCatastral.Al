/// <summary>
/// Codeunit Ref Catastral (ID 7001149).
/// </summary>
codeunit 7001113 "Ref Catastral"
{
    Permissions = tabledata 122 = rimd, tabledata 123 = rimd, tabledata 124 = rimd, tabledata 125 = rimd;

    var
        rRef: Record "Ref Catastral Address";
        rMov: Record "Mov. emplazamientos";
        r123: Record "Purch. Inv. Line";
        r125: Record "Purch. Cr. Memo Line";
        r122: Record "Purch. Inv. Header";
        r124: Record "Purch. Cr. Memo Hdr.";
        Vendor: Code[20];
        Code: Code[20];

    trigger OnRun()
    begin

        r122.SETRANGE(r122."Posting Date", 20180101D, Calcdate('PA-1A', Today));
        if r122.FINDFIRST THEN
            REPEAT
                Vendor := r122."Buy-from Vendor No.";
                Code := r122."Buy-from Vendor No.";
                r123.SETRANGE(r123."Document No.", r122."No.");
                r123.SETRANGE(r123."Ref. catastral inmueble SII", '');
                rMov.SETRANGE(rMov."Nº Factura definitivo", r122."No.");
                if rMov.FINDFIRST THEN BEGIN
                    Code := rMov."Nº emplazamiento";
                END;
                rRef.SETRANGE(rRef."Vendor No.", Vendor);
                rRef.SETRANGE(rRef.Code, Code);
                if NOT rRef.FINDFIRST THEN Code := Vendor;
                rRef.SETRANGE(rRef.Code, Code);
                if (rRef.FINDFIRST) AND (rRef."Ref. catastral" <> '') THEN
                    r123.MODIFYALL(r123."Ref. catastral inmueble SII", rRef."Ref. catastral");
            UNTIL r122.NEXT = 0;

        r124.SETRANGE(r124."Posting Date", 20180101D, Calcdate('PA-1A', Today));
        if r124.FINDFIRST THEN
            REPEAT
                Vendor := r124."Buy-from Vendor No.";
                Code := r124."Buy-from Vendor No.";
                r125.SETRANGE(r125."Document No.", r124."No.");
                rMov.SETRANGE(rMov."Nº Factura definitivo", r124."No.");
                r125.SETRANGE(r125."Ref. catastral inmueble SII", '');
                if rMov.FINDFIRST THEN BEGIN
                    Code := rMov."Nº emplazamiento";
                END;
                rRef.SETRANGE(rRef."Vendor No.", Vendor);
                rRef.SETRANGE(rRef.Code, Code);
                if NOT rRef.FINDFIRST THEN Code := Vendor;
                rRef.SETRANGE(rRef.Code, Code);
                if (rRef.FINDFIRST) AND (rRef."Ref. catastral" <> '') THEN
                    r125.MODIFYALL(r125."Ref. catastral inmueble SII", rRef."Ref. catastral");
            UNTIL r124.NEXT = 0;
    end;
}