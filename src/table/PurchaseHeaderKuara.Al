tableextension 75001 PurchaseKuara extends "Purchase Header"
{
    procedure RenoveDocument(): Code[20]
    var
        CopyPurchaseDocument: Report "Renove Purchase Document";
        IsHandled: Boolean;
    begin
        IsHandled := false;
        if IsHandled then
            exit;

        CopyPurchaseDocument.SetPurchHeader(Rec);
        CopyPurchaseDocument.RunModal();
        exit(CopyPurchaseDocument.GetNo());
    end;
}