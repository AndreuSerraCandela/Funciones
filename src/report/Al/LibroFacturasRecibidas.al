/// <summary>
/// Extensión del libro de facturas recibidas (evita filas duplicadas por varias bases de IVA en el mismo documento).
/// </summary>
reportextension 80101 LibroFacturasRecibidas extends "Purchases Invoice Book"
{
    dataset
    {

        modify(VATEntry2)
        {

            trigger OnAfterPreDataItem()
            begin
                Salta := false;
                VatEntryTemp.Reset();
                VatEntryTemp.SetRange(Type, VATEntry.Type);
                VatEntryTemp.SetRange("Document Type", VATEntry."Document Type");
                VatEntryTemp.SetRange("Document No.", VATEntry."Document No.");
                VatEntryTemp.SetRange("Vat %", VATEntry."Vat %");
                if VatEntryTemp.FindFirst() then begin
                    Salta := true;
                    CurrReport.Break();
                end;
                VatEntryTemp := VATEntry;
                VatEntryTemp.Insert();

            end;
        }
        modify("Integer")
        {
            trigger OnBeforePreDataItem()
            begin
                If Salta then CurrReport.Break();

            end;

            trigger OnAfterPreDataItem()
            begin
                If Salta then CurrReport.Break();

            end;
        }


        modify("No Taxable Entry")
        {
            trigger OnAfterPreDataItem()
            begin
                "No Taxable Entry".SetRange("Entry No.", 0);
            end;
        }
    }
    var
        VatEntryTemp: Record "VAT Entry" temporary;
        Salta: Boolean;


}
reportextension 80102 LibroFacturasEmitidas extends "Sales Invoice Book"
{
    dataset
    {




        modify("No Taxable Entry")
        {
            trigger OnAfterPreDataItem()
            begin
                "No Taxable Entry".SetRange("Entry No.", 0);
            end;
        }
    }
    var
        VatEntryTemp: Record "VAT Entry" temporary;


}