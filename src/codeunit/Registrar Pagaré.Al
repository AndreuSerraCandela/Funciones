/// <summary>
/// Codeunit Registrar pagarés (ID 50013).
/// </summary>
codeunit 50013 "Registrar pagarés"
{
    VAR
        recCfgCartera: Record 7000016;
        recProveedor: Record Vendor;
        recFactCompra: Record "Purch. Inv. Header";
        recAboCompra: Record "Purch. Cr. Memo Hdr.";
        cduRegLinDiario: Codeunit 12;
        Text001: Label 'Esta pagaré ya está contabilizado.';
        Text002: Label '¿Desea registrar el pagaré?';
        Text004: Label 'Debe marcar el pagaré como firmado para poder contabilizarlo.';
        Text005: Label 'No existe factura de compra nº %1 del proveedor %2.';
        Text006: Label 'No coinciden las divisas. La divisa utilizada en el documento %1 nº %2 es %3.';
        Text007: Label 'El pagaré ha sido contabilizado y guardado en el histórico.';
        Text008: Label 'El pagaré se ha enviado al diario %1 sección %2 y guardado en el histórico.';
        GenJnlPostBatch: Codeunit 13;
        Text009: Label 'Hay lineas en el diario %1 seccion %2. No es posible registrar el pagare.';



}