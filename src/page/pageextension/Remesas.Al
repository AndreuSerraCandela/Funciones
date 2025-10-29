// /// <summary>
// /// PageExtension RemesaMalla (ID 80127) extends Record 7000009.
// /// </summary>
// pageextension 80127 RemesaMalla extends "Bill Groups"
// {
//     layout
//     {
//         addafter("Dealing Type")
//         {
//             field("Remesa al descuento"; Rec."Remesa al descuento")
//             {
//                 ApplicationArea = All;
//                 Editable = true;
//             }
//         }
//         addafter("File Export Errors")
//         {
//             part("File Export Errors General"; "Payment Journal Errors Part")
//             {
//                 ApplicationArea = Basic, Suite;
//                 Caption = 'File Export Errors';
//                 Provider = Docs;
//                 SubPageLink = "Journal Template Name" = FILTER(''),
//                               "Journal Batch Name" = FILTER('7000005'),
//                               "Document No." = FIELD("Bill Gr./Pmt. Order No.");
//             }
//         }
//     }

//     actions
//     {
//         modify("Post")
//         {
//             visible = false;
//         }
//         addafter(Post)
//         {
//             action(Registrar)
//             {
//                 ApplicationArea = Basic, Suite;
//                 Caption = 'R&egistrar';
//                 Ellipsis = true;
//                 Image = Post;
//                 Promoted = true;
//                 PromotedCategory = Process;
//                 PromotedIsBig = true;
//                 ShortCutKey = 'F9';
//                 ToolTip = 'Post the documents to indicate that they are ready to submit to the bank for payment or collection. ';

//                 trigger OnAction()
//                 begin
//                     if Rec.Find then
//                         ReceivablePostOnly(Rec);
//                 end;
//             }
//         }

//         addafter(ExportToFile)
//         {
//             action("Export to file Malla")
//             {
//                 ApplicationArea = All;
//                 Image = ExportToBank;
//                 trigger OnAction()
//                 begin
//                     Rec.ExportToFileMalla();
//                 end;
//             }
//             action("Corregir Mandatos Sepa")
//             {
//                 ApplicationArea = All;
//                 Image = BankAccountStatement;
//                 trigger OnAction()
//                 var
//                     Docs: Record "Cartera Doc.";
//                     Sepa: Record "SEPA Direct Debit Mandate";
//                     Cust: Record Customer;
//                     BamkCustomer: Record "Customer Bank Account";
//                 begin
//                     Docs.SetRange("Bill Gr./Pmt. Order No.", Rec."No.");
//                     if Docs.FindSet() then
//                         repeat
//                             if Docs."Direct Debit Mandate ID" <> '' then begin
//                                 Sepa.Get(Docs."Direct Debit Mandate ID");
//                                 //Error 1 : No hay banco
//                                 if Sepa."Customer Bank Account Code" = '' then begin
//                                     Cust.Get(Docs."Account No.");
//                                     BamkCustomer.SetRange("Customer No.", Cust."No.");
//                                     if BamkCustomer.FindFirst() then begin
//                                         Sepa."Customer Bank Account Code" := BamkCustomer.Code;
//                                         if Cust."Preferred Bank Account Code" <> '' then
//                                             Sepa."Customer Bank Account Code" := Cust."Preferred Bank Account Code";
//                                         Sepa.MODIFY();
//                                     end;
//                                 end;
//                                 //Error 2 : Fecha de firma posterior a la fecha de vencimiento
//                                 if Sepa."Date of Signature" > Docs."Due Date" then begin
//                                     Sepa."Date of Signature" := Docs."Due Date";
//                                     Sepa.MODIFY();
//                                 end;
//                                 //Error 3 : Fecha de fin de validez anterior a la fecha de vencimiento
//                                 if Sepa."Valid To" < Docs."Due Date" then begin
//                                     Sepa."Valid To" := Docs."Due Date";
//                                     Sepa.MODIFY();
//                                 end;
//                                 //Error 4 : Fecha de inicio de validez posterior a la fecha de vencimiento
//                                 if Sepa."Valid from" > Docs."Due Date" then begin
//                                     Sepa."Valid from" := Docs."Due Date";
//                                     Sepa.MODIFY();
//                                 end;
//                             end;

//                         until docs.next() = 0;
//                 end;
//             }
//             action("Convertir en core")
//             {
//                 ApplicationArea = All;
//                 Image = CustomerRating;
//                 trigger OnAction()
//                 var
//                     Docs: Record "Cartera Doc.";
//                     Cust: Record Customer;
//                     BamkCustomer: Record "Customer Bank Account";
//                 begin
//                     Docs.SetRange("Bill Gr./Pmt. Order No.", Rec."No.");
//                     Rec."Partner Type" := Rec."Partner Type"::Person;
//                     Rec.Modify();
//                     if Docs.FindSet() then
//                         repeat
//                             If Cust.Get(Docs."Account No.") Then begin
//                                 Cust."Partner Type" := Cust."Partner Type"::Person;

//                                 Cust.MODIFY();
//                             end;

//                         until docs.next() = 0;
//                 end;
//             }
//             action("Convertir en core Todo")
//             {
//                 ApplicationArea = All;
//                 Image = CustomerRating;
//                 trigger OnAction()
//                 var
//                     Docs: Record "Cartera Doc.";
//                     Cust: Record Customer;
//                     BamkCustomer: Record "Customer Bank Account";
//                 begin
//                     Rec."Partner Type" := Rec."Partner Type"::Person;
//                     Rec.Modify();
//                     if Docs.FindSet() then
//                         repeat
//                             If Cust.Get(Docs."Account No.") Then begin
//                                 Cust."Partner Type" := Cust."Partner Type"::Person;

//                                 Cust.MODIFY();
//                             end;

//                         until docs.next() = 0;
//                 end;
//             }
//         }

//     }
//     /// <summary>
//     /// ReceivablePostOnly.
//     /// </summary>
//     /// <param name="BillGr">Record "Bill Group".</param>
//     procedure ReceivablePostOnly(BillGr: Record "Bill Group")
//     begin
//         if BillGr."No. Printed" = 0 then begin
//             if not Confirm(Text1100000) then
//                 Error(Text1100001);
//         end else
//             if not Confirm(Text1100002, false) then
//                 Error(Text1100001);

//         BillGr.SetRecFilter();
//         REPORT.RunModal(REPORT::"Post Bill Group Malla", BillGr."Dealing Type" = BillGr."Dealing Type"::Discount, false, BillGr);
//     end;

//     var
//         Text1100000: Label 'Esta Remesa no está impresa. Quiere continuar?';
//         Text1100001: Label 'El proceso ha sido cancelado por el usuario.';
//         Text1100002: Label 'Quiere registrar la remesa?';
//         Text1100003: Label 'ThisOrden de pago no está impresa. Quiere continuar?';
//         Text1100004: Label 'Quiere registrar la Orden de pago?';
//         Name: Text;
//         ProcesoCancelado: Label 'Proceso cancelado por el usuario';
// }
// pageextension 80147 LiqRemesas extends "Docs. in Posted BG Subform"
// {
//     layout
//     {
//         addafter("Remaining Amount")
//         {
//             field(Cuenta; Rec."Account No.")
//             {
//                 ApplicationArea = Basic, Suite;
//                 Visible = true;
//             }
//             field("No. Borrador factura"; Rec."No. Borrador factura")
//             {
//                 ApplicationArea = All;
//             }
//             field("Banco"; Rec.Banco)
//             {
//                 ApplicationArea = All;
//             }
//             field("Banco Cliente"; Rec."Cust./Vendor Bank Acc. Code")
//             {
//                 ApplicationArea = All;
//             }
//             field("Iban"; Iban)
//             {
//                 ApplicationArea = All;
//             }
//             field("Entidad Cliente"; Rec."Entidad Cliente")
//             {
//                 ApplicationArea = All;
//             }
//             field("C.I.F."; Cif)
//             {
//                 ApplicationArea = All;
//             }
//             field(Nombre; Customer.Name)
//             {
//                 ApplicationArea = All;
//             }

//         }
//     }
//     actions
//     {
//         modify("Total Settlement")
//         {
//             visible = false;
//         }
//         addafter("Total Settlement")
//         {
//             action("Liquidación Total")
//             {
//                 ApplicationArea = Basic, Suite;
//                 //Caption = 'Total Settlement';
//                 Ellipsis = true;
//                 ToolTip = 'View posted documents that were settled fully.';

//                 trigger OnAction()
//                 begin
//                     SettleDocsNuevo();
//                 end;
//             }
//             action("Asignar factura Borrador")
//             {
//                 Image = "Invoicing-Document";
//                 ApplicationArea = All;
//                 trigger OnAction()
//                 var
//                     ControlProcesos: Codeunit ControlProcesos;
//                     Docs: Record "Posted Cartera Doc.";
//                 begin
//                     CurrPage.SetSelectionFilter(Docs);
//                     ControlProcesos.AsignarFacturaBorrador(Docs);
//                 end;
//             }
//             action("Asignar Banco Cliente")
//             {
//                 Image = "Invoicing-Document";
//                 ApplicationArea = All;
//                 trigger OnAction()
//                 var
//                     ControlProcesos: Codeunit ControlProcesos;
//                     Docs: Record "Posted Cartera Doc.";
//                 begin
//                     CurrPage.SetSelectionFilter(Docs);
//                     ControlProcesos.AsignarBancoCliente(Docs);
//                 end;
//             }
//             action("Recircular factura borrdor")
//             {
//                 Image = "Invoicing-Document";
//                 ApplicationArea = All;
//                 trigger OnAction()
//                 var
//                     ControlProcesos: Codeunit ControlProcesos;
//                     Docs: Record "Posted Cartera Doc.";
//                 begin
//                     CurrPage.SetSelectionFilter(Docs);
//                     ControlProcesos.RecircularFacturaBorrador(Docs);
//                 end;
//             }
//         }
//     }
//     trigger OnAfterGetRecord()
//     begin
//         Cif := '';
//         if Rec.Type = Rec.Type::Receivable Then
//             if Customer.Get(Rec."Account No.") Then Cif := Customer."VAT Registration No.";
//         if Rec.Type = Rec.Type::Payable then
//             if Vendor.Get(Rec."Account No.") then Cif := Vendor."VAT Registration No.";
//         Rec.calcfields("Entidad Cliente");
//     end;
//     /// <summary>
//     /// Iban.
//     /// </summary>
//     /// <returns>Return value of type Text.</returns>
//     procedure Iban(): Text
//     var
//         cBank: Record "Customer Bank Account";
//         vBank: Record "Vendor Bank Account";
//     Begin

//         if Rec.Type = Rec.Type::Receivable THEN BEGIN
//             if not cBank.GET(Rec."Account No.", Rec."Cust./Vendor Bank Acc. Code") THEN
//                 EXIT(cBank.IBAN);
//             cBank.SetRange("Customer No.", rec."Account No.");
//             if cBank.FindFirst() Then exit(cBank.IBAN);
//         END ELSE BEGIN
//             if vBank.GET(Rec."Account No.", Rec."Cust./Vendor Bank Acc. Code") THEN
//                 EXIT(vBank.IBAN);
//             vBank.SetRange("Vendor No.", rec."Account No.");
//             if vBank.FindFirst() Then exit(cBank.IBAN);
//         END;
//     end;

//     var
//         Customer: Record Customer;
//         Vendor: Record Vendor;
//         Cif: Text;

//     /// <summary>
//     /// SettleDocsNuevo.
//     /// </summary>
//     procedure SettleDocsNuevo()
//     var
//         PostedDoc: Record "Posted Cartera Doc.";
//         Total: Decimal;
//         ProcesoCancelado: Label 'Proceso cancelado por el usuario';
//     begin
//         CurrPage.SetSelectionFilter(PostedDoc);
//         if not PostedDoc.Find('=><') then
//             exit;

//         PostedDoc.SetRange(Status, PostedDoc.Status::Open);
//         if not PostedDoc.Find('-') then
//             Error(
//               Text1100000 +
//               Text1100001);
//         repeat
//             Total += PostedDoc."Remaining Amount";
//         until PostedDoc.Next() = 0;
//         if Confirm('¿El importe total de la liquidación es ' + FORMAT(Total) + ', quier contiuar?') then
//             REPORT.RunModal(REPORT::"Settle Docs. Bill Gr. Malla", true, false, PostedDoc)
//         else
//             Error(ProcesoCancelado);
//         //REPORT.RunModal(REPORT::"Settle Docs. Bill Gr. Malla", true, false, PostedDoc);
//         CurrPage.Update(false);
//     end;

//     var
//         Text1100000: Label 'No se han encontrado documentos para liquidad. \';
//         Text1100001: Label 'Compruebe que haya algun documento pendiente.';
// }
// pageextension 80148 SubformCrtera extends "Docs. in BG Subform"
// {
//     layout
//     {
//         modify("Remaining Amount")
//         {
//             Editable = true;
//         }
//         modify("Original Amount")
//         {
//             Visible = true;
//         }
//         modify("Direct Debit Mandate ID")
//         {
//             Visible = true;
//             StyleExpr = Color;
//         }
//         addafter("Remaining Amount")
//         {
//             field(Cuenta; Rec."Account No.")
//             {
//                 ApplicationArea = Basic, Suite;
//                 Visible = true;
//             }
//             field("C.I.F."; Cif)
//             {
//                 ApplicationArea = All;
//             }
//             field("Cust./Vendor Bank Acc. Code"; Rec."Cust./Vendor Bank Acc. Code")
//             {
//                 ApplicationArea = All;
//             }
//             field(Nombre; Customer.Name)
//             {
//                 ApplicationArea = All;
//             }

//         }
//     }
//     actions
//     {
//         addlast("&Docs.")
//         {
//             action("Modificar Vto.")
//             {
//                 ApplicationArea = All;
//                 Image = ChangeDate;
//                 trigger OnAction()
//                 var
//                     Control: Codeunit Utilitis;
//                 Begin
//                     Control.ModificaFecha(Rec);


//                 End;
//             }
//             action("Asignar factura Borrador")
//             {
//                 Image = "Invoicing-Document";
//                 ApplicationArea = All;
//                 trigger OnAction()
//                 var
//                     ControlProcesos: Codeunit ControlProcesos;
//                     Docs: Record "Cartera Doc.";
//                 begin
//                     CurrPage.SetSelectionFilter(Docs);
//                     ControlProcesos.AsignarFacturaBorrador(Docs);
//                 end;
//             }
//             action("Arreglar Mandato")
//             {
//                 ApplicationArea = All;
//                 Image = "Invoicing-Document";
//                 trigger OnAction()
//                 var
//                     ControlProcesos: Codeunit ControlProcesos;
//                 begin
//                     ControlProcesos.ArreglarMandato(Rec, false);
//                 end;
//             }
//             action("Arreglar Mandatos Remesa")
//             {
//                 ApplicationArea = All;
//                 Image = SpecialOrder;
//                 trigger OnAction()
//                 var
//                     ControlProcesos: Codeunit ControlProcesos;
//                 begin
//                     ControlProcesos.ArreglarMandato(Rec, true);
//                 end;
//             }
//             action("Convertir en core")
//             {
//                 ApplicationArea = All;
//                 Image = CustomerRating;
//                 trigger OnAction()
//                 var
//                     Docs: Record "Cartera Doc.";
//                     Cust: Record Customer;
//                     BamkCustomer: Record "Customer Bank Account";
//                     Bo: Record "Bill Group";

//                 begin

//                     Docs.SetRange("Bill Gr./Pmt. Order No.", Rec."Bill Gr./Pmt. Order No.");
//                     Bo.Get(Rec."Bill Gr./Pmt. Order No.");
//                     Bo."Partner Type" := Bo."Partner Type"::Person;
//                     Bo.Modify();
//                     if Docs.FindSet() then
//                         repeat
//                             If Cust.Get(Docs."Account No.") Then begin
//                                 Cust."Partner Type" := Cust."Partner Type"::Person;

//                                 Cust.MODIFY();
//                             end;

//                         until docs.next() = 0;
//                 end;
//             }


//         }
//     }

//     trigger OnAfterGetRecord()
//     var
//         DebirMandate: Record "SEPA Direct Debit Mandate";
//     begin
//         Cif := '';
//         if Rec.Type = Rec.Type::Receivable Then
//             if Customer.Get(Rec."Account No.") Then Cif := Customer."VAT Registration No.";
//         if Rec.Type = Rec.Type::Payable then
//             if Vendor.Get(Rec."Account No.") then Cif := Vendor."VAT Registration No.";
//         if Rec."Direct Debit Mandate ID" <> '' then begin
//             DebirMandate.Get(Rec."Direct Debit Mandate ID");
//             if DebirMandate."Valid from" > Rec."Due Date" then
//                 Color := 'Unfavorable';
//             if DebirMandate."Valid To" < Rec."Due Date" then
//                 Color := 'Unfavorable';
//             if DebirMandate."Date of Signature" > Rec."Due Date" then
//                 Color := 'Unfavorable';
//             If DebirMandate."Customer Bank Account Code" = '' Then
//                 Color := 'Unfavorable';
//         end else
//             Color := 'Unfavorable';
//     end;

//     var
//         Customer: Record Customer;
//         Vendor: Record Vendor;
//         Cif: Text;
//         Color: Text;
// }
// pageextension 80154 SubformClCarteraBg extends "Docs. in Closed BG Subform"
// {
//     layout
//     {
//         addafter("Remaining Amount")
//         {
//             field(Cuenta; Rec."Account No.")
//             {
//                 ApplicationArea = Basic, Suite;
//                 Visible = true;
//             }
//             field("No. Borrador factura"; Rec."No. Borrador factura")
//             {
//                 ApplicationArea = All;
//             }
//             field("Banco"; Rec.Banco)
//             {
//                 ApplicationArea = All;
//             }
//             field("Banco Cliente"; Rec."Cust./Vendor Bank Acc. Code")
//             {
//                 ApplicationArea = All;
//             }
//             field("C.I.F."; Cif)
//             {
//                 ApplicationArea = All;
//             }
//             field(Nombre; Customer.Name)
//             {
//                 ApplicationArea = All;
//             }
//         }
//     }
//     trigger OnAfterGetRecord()
//     begin
//         Cif := '';
//         if Rec.Type = Rec.Type::Receivable Then
//             if Customer.Get(Rec."Account No.") Then Cif := Customer."VAT Registration No.";
//         if Rec.Type = Rec.Type::Payable then
//             if Vendor.Get(Rec."Account No.") then Cif := Vendor."VAT Registration No.";
//     end;

//     var
//         Cif: Text;
//         Customer: Record Customer;
//         Vendor: Record Vendor;
// }
// pageextension 80155 SubformCrteraPo2 extends "Docs. in Posted PO Subform"
// {

//     layout
//     {
//         modify("Posting Date")
//         {
//             Visible = true;
//             ApplicationArea = All;
//         }
//         modify("Account No.")
//         {
//             ApplicationArea = All;
//         }
//         addAfter("No.")
//         {

//             field(Cuenta; Rec."Account No.")
//             {
//                 ApplicationArea = Basic, Suite;
//                 Visible = true;
//             }


//             field("Bill Gr./Pmt. Order No."; Rec."Bill Gr./Pmt. Order No.")
//             {
//                 ApplicationArea = All;
//             }
//             field("C.I.F."; Cif)
//             {
//                 ApplicationArea = All;
//             }
//             field(Nombre; Vendor.Name)
//             {
//                 ApplicationArea = All;
//             }
//             field("Banco"; Rec.Banco)
//             {
//                 ApplicationArea = All;
//             }
//             field("Banco Proveedor"; Rec."Cust./Vendor Bank Acc. Code")
//             {
//                 ApplicationArea = All;
//             }

//             field("Iban"; Iban)
//             {
//                 ApplicationArea = All;
//             }
//             field("Entidad Cliente"; Rec."Entidad Cliente")
//             {
//                 ApplicationArea = All;
//             }
//         }
//     }

//     trigger OnAfterGetRecord()
//     var
//         DebitDir: Record "SEPA Direct Debit Mandate";
//     begin
//         Cif := '';
//         if Rec.Type = Rec.Type::Receivable Then
//             if Customer.Get(Rec."Account No.") Then Cif := Customer."VAT Registration No.";
//         if Rec.Type = Rec.Type::Payable then
//             if Vendor.Get(Rec."Account No.") then Cif := Vendor."VAT Registration No.";
//         Rec.calcfields("Entidad Cliente");
//     end;

//     var
//         Customer: Record Customer;
//         Vendor: Record Vendor;
//         Cif: Text;

//     /// <summary>
//     /// Iban.
//     /// </summary>
//     /// <returns>Return value of type Text.</returns>
//     procedure Iban(): Text
//     var
//         cBank: Record "Customer Bank Account";
//         vBank: Record "Vendor Bank Account";
//     Begin

//         if Rec.Type = Rec.Type::Receivable THEN BEGIN
//             if not cBank.GET(Rec."Account No.", Rec."Cust./Vendor Bank Acc. Code") THEN
//                 EXIT(cBank.IBAN);
//             cBank.SetRange("Customer No.", rec."Account No.");
//             if cBank.FindFirst() Then exit(cBank.IBAN);
//         END ELSE BEGIN
//             if vBank.GET(Rec."Account No.", Rec."Cust./Vendor Bank Acc. Code") THEN
//                 EXIT(vBank.IBAN);
//             vBank.SetRange("Vendor No.", rec."Account No.");
//             if vBank.FindFirst() Then exit(cBank.IBAN);
//         END;
//     end;


// }
// pageextension 80112 PostedBillGroupsList extends "Posted Bill Groups List"
// {
//     layout
//     {
//         addbefore(Amount)
//         {
//             field("Amount Grouped"; Rec."Amount Grouped")
//             {
//                 Caption = 'Importe remesado';
//                 ApplicationArea = All;
//                 ToolTip = 'Specifies the grouped amount in this posted bill group.';
//             }
//         }
//     }
// }
// pageextension 80109 ClosedBillGroups extends "Closed Bill Groups List"
// {
//     layout
//     {
//         addafter("Currency Code")
//         {
//             field("Fecha Registro"; Rec."Posting Date")
//             {
//                 ApplicationArea = All;
//                 Visible = true;
//             }
//             field("Fecha Cierre"; Rec."Closing Date")
//             {
//                 ApplicationArea = All;
//                 Visible = true;
//             }
//             field("Al descuento"; Rec."Remesa al descuento")
//             {
//                 ApplicationArea = All;
//                 Visible = true;
//             }
//             field("Dealing Type"; Rec."Dealing Type")
//             {
//                 Caption = 'Tipo Gestión';
//                 ApplicationArea = All;
//                 Visible = true;
//             }
//         }
//     }
//     trigger OnOpenPage()
//     begin
//         Rec.Ascending := false;
//     end;
// }

// pageextension 80157 CarteraDoc extends "Cartera Documents"
// {
//     layout
//     {
//         modify("Posting Date")
//         {
//             Visible = true;
//             ApplicationArea = All;
//         }
//         modify("Account No.")
//         {
//             ApplicationArea = All;
//         }
//         addAfter("No.")
//         {

//             field(Cuenta; Rec."Account No.")
//             {
//                 ApplicationArea = Basic, Suite;
//                 Visible = true;
//             }


//             field("Bill Gr./Pmt. Order No."; Rec."Bill Gr./Pmt. Order No.")
//             {
//                 ApplicationArea = All;
//             }
//             field("C.I.F."; Cif)
//             {
//                 ApplicationArea = All;
//             }
//             field(Nombre; Nombre())
//             {
//                 ApplicationArea = All;
//             }
//             field("Banco"; Rec.Banco)
//             {
//                 ApplicationArea = All;
//             }
//             field("Banco Cliente/Proveedor"; Rec."Cust./Vendor Bank Acc. Code")
//             {
//                 ApplicationArea = All;
//             }

//             field("Iban"; Iban)
//             {
//                 ApplicationArea = All;
//             }

//             field("Entidad Cliente"; Rec."Entidad Cliente")
//             {
//                 ApplicationArea = All;
//             }
//             field("Entidad Proveedor"; Rec."Entidad Proveedor")
//             {
//                 ApplicationArea = All;
//             }
//             field("Global Dimension 2 Code"; Rec."Global Dimension 2 Code")
//             {
//                 ApplicationArea = All;
//             }
//         }
//     }


//     actions
//     {
//         addlast("&Docs.")
//         {
//             action("Eliminar de Cartera")
//             {
//                 ApplicationArea = All;
//                 Image = "Invoicing-Delete";
//                 trigger OnAction()
//                 var
//                     controlProcesos: codeunit ControlProcesos;
//                 begin
//                     controlProcesos.EliminarCartera(Rec);
//                 end;
//             }

//             action("Cambiar Vencimiento")
//             {
//                 ApplicationArea = All;
//                 Image = DueDate;
//                 trigger OnAction()
//                 var
//                     controlProcesos: codeunit Utilitis;
//                 begin
//                     controlProcesos.CambiarVto(Rec);
//                 end;
//             }
//         }
//     }
//     trigger OnAfterGetRecord()
//     var
//         DebitDir: Record "SEPA Direct Debit Mandate";
//     begin
//         Cif := '';
//         if Rec.Type = Rec.Type::Receivable Then
//             if Customer.Get(Rec."Account No.") Then Cif := Customer."VAT Registration No.";
//         if Rec.Type = Rec.Type::Payable then
//             if Vendor.Get(Rec."Account No.") then Cif := Vendor."VAT Registration No.";
//         Rec.calcfields("Entidad Cliente");
//     end;

//     var
//         Customer: Record Customer;
//         Vendor: Record Vendor;
//         Cif: Text;

//     /// <summary>
//     /// Iban.
//     /// </summary>
//     /// <returns>Return value of type Text.</returns>
//     procedure Iban(): Text
//     var
//         cBank: Record "Customer Bank Account";
//         vBank: Record "Vendor Bank Account";
//     Begin

//         if Rec.Type = Rec.Type::Receivable THEN BEGIN
//             if not cBank.GET(Rec."Account No.", Rec."Cust./Vendor Bank Acc. Code") THEN
//                 EXIT(cBank.IBAN);
//             cBank.SetRange("Customer No.", rec."Account No.");
//             if cBank.FindFirst() Then exit(cBank.IBAN);
//         END ELSE BEGIN
//             if vBank.GET(Rec."Account No.", Rec."Cust./Vendor Bank Acc. Code") THEN
//                 EXIT(vBank.IBAN);
//             vBank.SetRange("Vendor No.", rec."Account No.");
//             if vBank.FindFirst() Then exit(cBank.IBAN);
//         END;
//     end;

//     procedure Nombre(): Text
//     var
//         c: Record "Customer";
//         v: Record "Vendor";
//     begin
//         if Rec.Type = Rec.Type::Receivable then
//             if c.Get(Rec."Account No.") then
//                 exit(c.Name);
//         if Rec.Type = Rec.Type::Payable then
//             if v.Get(Rec."Account No.") then
//                 exit(v.Name);
//     end;

// }
// pageextension 80158 DocCobro extends "Receivables Cartera Docs"
// {
//     layout
//     {
//         addAfter("No.")
//         {
//             field("C.I.F."; Cif)
//             {
//                 ApplicationArea = All;
//             }
//             field(Nombre; Name)
//             {
//                 ApplicationArea = All;
//             }
//             field("No. Borrador factura"; Rec."No. Borrador factura")
//             {
//                 ApplicationArea = All;
//             }
//             field("Banco"; Rec.Banco)
//             {
//                 ApplicationArea = All;
//             }
//             field("Banco Cliente"; Rec."Cust./Vendor Bank Acc. Code")
//             {
//                 ApplicationArea = All;
//             }
//             field("Id Domiciliación"; Rec."Direct Debit Mandate ID")
//             {
//                 ApplicationArea = All;
//             }
//             field("Iban"; Iban)
//             {
//                 ApplicationArea = All;
//             }
//             field("Entidad Cliente"; Rec."Entidad Cliente")
//             {
//                 ApplicationArea = All;
//             }
//             field("Global Dimension 2 Code"; Rec."Global Dimension 2 Code")
//             {
//                 ApplicationArea = All;
//             }
//         }
//     }
//     actions
//     {
//         addafter("&Docs.")
//         {
//             action("Cambiar Vencimiento")
//             {
//                 ApplicationArea = All;
//                 Image = DueDate;
//                 trigger OnAction()
//                 var
//                     controlProcesos: codeunit Utilitis;
//                 begin
//                     controlProcesos.CambiarVto(Rec);
//                 end;
//             }
//             action("Asignar factura Borrador")
//             {
//                 Image = "Invoicing-Document";
//                 ApplicationArea = All;
//                 trigger OnAction()
//                 var
//                     ControlProcesos: Codeunit ControlProcesos;
//                     Docs: Record "Cartera Doc.";
//                 begin
//                     CurrPage.SetSelectionFilter(Docs);
//                     ControlProcesos.AsignarFacturaBorrador(Docs);
//                 end;
//             }
//         }
//     }
//     trigger OnAfterGetRecord()
//     var
//         DebitDir: Record "SEPA Direct Debit Mandate";
//         Contrato: Record "Sales Header";
//         Cliente: Record Customer;
//     begin
//         Cif := '';
//         if Rec.Type = Rec.Type::Receivable Then
//             if Customer.Get(Rec."Account No.") Then begin
//                 Cif := Customer."VAT Registration No.";
//                 Name := Customer.Name;
//             end;
//         if Rec.Type = Rec.Type::Payable then
//             if Vendor.Get(Rec."Account No.") then begin
//                 Cif := Vendor."VAT Registration No.";
//                 Name := Vendor.Name;
//             end;
//         if Rec."Direct Debit Mandate ID" = '' Then begin
//             DebitDir.SetRange("Customer No.", Rec."Account No.");
//             if Rec."Cust./Vendor Bank Acc. Code" = '' then begin
//                 if StrPos(Copystr(Rec."Document No.", 7), '-') > 0 then begin
//                     if Contrato.Get(Contrato."Document Type", CopyStr(Rec."Document No.", 1, 11)) Then begin
//                         rec."Cust./Vendor Bank Acc. Code" := Contrato."Cust. Bank Acc. Code";
//                         if Rec."Cust./Vendor Bank Acc. Code" = '' Then begin
//                             Customer.get(Rec."Account No.");
//                             Rec."Cust./Vendor Bank Acc. Code" := Customer."Preferred Bank Account Code";
//                         end;
//                     end else begin
//                         Customer.get(Rec."Account No.");
//                         Rec."Cust./Vendor Bank Acc. Code" := Customer."Preferred Bank Account Code";
//                     end;
//                 end;
//             end;
//             DebitDir.SetRange("Customer Bank Account Code", Rec."Cust./Vendor Bank Acc. Code");
//             if DebitDir.FindLast() Then Rec."Direct Debit Mandate ID" := DebitDir.ID;
//             if StrPos(Copystr(Rec."Document No.", 7), '-') > 0 then begin
//                 Rec."Direct Debit Mandate ID" := CopyStr(Rec."Document No.", 1, 11);
//                 DebitDir.SetRange("ID", Rec."Direct Debit Mandate ID");
//                 if DebitDir.FindFirst() Then begin
//                     DebitDir."Valid To" := Rec."Due Date";
//                     DebitDir.MODIFY();
//                 end else begin
//                     DebitDir.INIT();
//                     DebitDir.ID := Rec."Direct Debit Mandate ID";
//                     DebitDir."Customer No." := Rec."Account No.";
//                     DebitDir."Customer Bank Account Code" := Rec."Cust./Vendor Bank Acc. Code";
//                     DebitDir."Valid From" := Rec."Due Date";
//                     if Rec."Due Date" < Rec."Posting Date" then
//                         DebitDir."Date of Signature" := Rec."Due Date"
//                     else
//                         DebitDir."Date of Signature" := Rec."Posting Date";
//                     DebitDir."Type of Payment" := DebitDir."Type of Payment"::Recurrent;
//                     if Strpos(Rec."No.", '/') > 0 then
//                         Evaluate(DebitDir."Expected Number of Debits", CopyStr(Rec."No.", Strpos(Rec."No.", '/') + 1, 100))
//                     else
//                         DebitDir."Expected Number of Debits" := 1;
//                     DebitDir."Debit Counter" := 0;
//                     DebitDir."Ignore Exp. Number of Debits" := true;
//                     DebitDir."Valid To" := Calcdate(Format(DebitDir."Expected Number of Debits") + 'M', Rec."Due Date");
//                     if DebitDir.INSERT() Then;
//                 end;
//             end;
//         end;
//         Rec.calcfields("Entidad Cliente");
//     end;

//     var
//         Customer: Record Customer;
//         Vendor: Record Vendor;
//         Cif: Text;
//         Name: Text;

//     /// <summary>
//     /// Iban.
//     /// </summary>
//     /// <returns>Return value of type Text.</returns>
//     procedure Iban(): Text

//     var
//         cBank: Record "Customer Bank Account";
//         vBank: Record "Vendor Bank Account";
//     Begin

//         if Rec.Type = Rec.Type::Receivable THEN BEGIN
//             if not cBank.GET(Rec."Account No.", Rec."Cust./Vendor Bank Acc. Code") THEN
//                 EXIT(cBank.IBAN);
//             cBank.SetRange("Customer No.", rec."Account No.");
//             if cBank.FindFirst() Then exit(cBank.IBAN);
//         END ELSE BEGIN
//             if vBank.GET(Rec."Account No.", Rec."Cust./Vendor Bank Acc. Code") THEN
//                 EXIT(vBank.IBAN);
//             vBank.SetRange("Vendor No.", rec."Account No.");
//             if vBank.FindFirst() Then exit(cBank.IBAN);
//         END;
//     end;

// }

// pageextension 80122 DocCobroC extends "Receivable Closed Cartera Docs"
// {
//     layout
//     {
//         addAfter("No.")
//         {

//             field(Cuenta; Rec."Account No.")
//             {
//                 ApplicationArea = Basic, Suite;
//                 Visible = true;
//             }
//             field("Bill Gr./Pmt. Order No."; Rec."Bill Gr./Pmt. Order No.")
//             {
//                 ApplicationArea = All;
//             }
//             field("C.I.F."; Cif)
//             {
//                 ApplicationArea = All;
//             }
//             field(Nombre; Customer.Name)
//             {
//                 ApplicationArea = All;
//             }
//             field("No. Borrador factura"; Rec."No. Borrador factura")
//             {
//                 ApplicationArea = All;
//             }
//             field("Banco"; Rec.Banco)
//             {
//                 ApplicationArea = All;
//             }
//             field("Banco Cliente"; Rec."Cust./Vendor Bank Acc. Code")
//             {
//                 ApplicationArea = All;
//             }

//             field("Iban"; Iban)
//             {
//                 ApplicationArea = All;
//             }
//             field("Entidad Cliente"; Rec."Entidad Cliente")
//             {
//                 ApplicationArea = All;
//             }
//         }
//     }
//     trigger OnAfterGetRecord()
//     var
//         DebitDir: Record "SEPA Direct Debit Mandate";
//     begin
//         Cif := '';
//         if Rec.Type = Rec.Type::Receivable Then
//             if Customer.Get(Rec."Account No.") Then Cif := Customer."VAT Registration No.";
//         if Rec.Type = Rec.Type::Payable then
//             if Vendor.Get(Rec."Account No.") then Cif := Vendor."VAT Registration No.";
//         Rec.calcfields("Entidad Cliente");
//     end;

//     var
//         Customer: Record Customer;
//         Vendor: Record Vendor;
//         Cif: Text;

//     procedure Iban(): Text
//     var
//         cBank: Record "Customer Bank Account";
//         vBank: Record "Vendor Bank Account";
//     Begin

//         if Rec.Type = Rec.Type::Receivable THEN BEGIN
//             if not cBank.GET(Rec."Account No.", Rec."Cust./Vendor Bank Acc. Code") THEN
//                 EXIT(cBank.IBAN);
//             cBank.SetRange("Customer No.", rec."Account No.");
//             if cBank.FindFirst() Then exit(cBank.IBAN);
//         END ELSE BEGIN
//             if vBank.GET(Rec."Account No.", Rec."Cust./Vendor Bank Acc. Code") THEN
//                 EXIT(vBank.IBAN);
//             vBank.SetRange("Vendor No.", rec."Account No.");
//             if vBank.FindFirst() Then exit(cBank.IBAN);
//         END;
//     end;

// }
// pageextension 80125 DocPagoC extends "Payable Closed Cartera Docs"
// {
//     layout
//     {
//         modify("Posting Date")
//         {
//             Visible = true;
//             ApplicationArea = All;
//         }
//         addAfter("No.")
//         {

//             field(Cuenta; Rec."Account No.")
//             {
//                 ApplicationArea = Basic, Suite;
//                 Visible = true;
//             }
//             field("Bill Gr./Pmt. Order No."; Rec."Bill Gr./Pmt. Order No.")
//             {
//                 ApplicationArea = All;
//             }
//             field("C.I.F."; Cif)
//             {
//                 ApplicationArea = All;
//             }
//             field(Nombre; Vendor.Name)
//             {
//                 ApplicationArea = All;
//             }
//             field("Banco"; Rec.Banco)
//             {
//                 ApplicationArea = All;
//             }
//             field("Banco Proveedor"; Rec."Cust./Vendor Bank Acc. Code")
//             {
//                 ApplicationArea = All;
//             }

//             field("Iban"; Iban)
//             {
//                 ApplicationArea = All;
//             }
//             field("Entidad Cliente"; Rec."Entidad Cliente")
//             {
//                 ApplicationArea = All;
//             }
//             field("Global Dimension 2 Code"; Rec."Global Dimension 2 Code")
//             {
//                 ApplicationArea = All;
//             }
//         }
//     }
//     trigger OnAfterGetRecord()
//     var
//         DebitDir: Record "SEPA Direct Debit Mandate";
//     begin
//         Cif := '';
//         if Rec.Type = Rec.Type::Receivable Then
//             if Customer.Get(Rec."Account No.") Then Cif := Customer."VAT Registration No.";
//         if Rec.Type = Rec.Type::Payable then
//             if Vendor.Get(Rec."Account No.") then Cif := Vendor."VAT Registration No.";
//         Rec.calcfields("Entidad Cliente");
//     end;

//     var
//         Customer: Record Customer;
//         Vendor: Record Vendor;
//         Cif: Text;

//     procedure Iban(): Text
//     var
//         cBank: Record "Customer Bank Account";
//         vBank: Record "Vendor Bank Account";
//     Begin

//         if Rec.Type = Rec.Type::Receivable THEN BEGIN
//             if not cBank.GET(Rec."Account No.", Rec."Cust./Vendor Bank Acc. Code") THEN
//                 EXIT(cBank.IBAN);
//             cBank.SetRange("Customer No.", rec."Account No.");
//             if cBank.FindFirst() Then exit(cBank.IBAN);
//         END ELSE BEGIN
//             if vBank.GET(Rec."Account No.", Rec."Cust./Vendor Bank Acc. Code") THEN
//                 EXIT(vBank.IBAN);
//             vBank.SetRange("Vendor No.", rec."Account No.");
//             if vBank.FindFirst() Then exit(cBank.IBAN);
//         END;
//     end;

// }
// pageextension 80163 DocPago extends "Payables Cartera Docs"
// {
//     layout
//     {
//         modify("Posting Date")
//         {
//             Visible = true;
//             ApplicationArea = All;
//         }
//         addAfter("No.")
//         {

//             field(Cuenta; Rec."Account No.")
//             {
//                 ApplicationArea = Basic, Suite;
//                 Visible = true;
//             }

//             field("Bill Gr./Pmt. Order No."; Rec."Bill Gr./Pmt. Order No.")
//             {
//                 ApplicationArea = All;
//             }
//             field("C.I.F."; Cif)
//             {
//                 ApplicationArea = All;
//             }
//             field(Nombre; Vendor.Name)
//             {
//                 ApplicationArea = All;
//             }
//             field("Banco"; Rec.Banco)
//             {
//                 ApplicationArea = All;
//             }
//             field("Banco Proveedor"; Rec."Cust./Vendor Bank Acc. Code")
//             {
//                 ApplicationArea = All;
//             }

//             field("Iban"; Iban)
//             {
//                 ApplicationArea = All;
//             }
//             field("Entidad Cliente"; Rec."Entidad Cliente")
//             {
//                 ApplicationArea = All;
//             }
//             field("Global Dimension 2 Code"; Rec."Global Dimension 2 Code")
//             {
//                 ApplicationArea = All;
//             }
//         }
//     }
//     trigger OnAfterGetRecord()
//     var
//         DebitDir: Record "SEPA Direct Debit Mandate";
//     begin
//         Cif := '';
//         if Rec.Type = Rec.Type::Receivable Then
//             if Customer.Get(Rec."Account No.") Then Cif := Customer."VAT Registration No.";
//         if Rec.Type = Rec.Type::Payable then
//             if Vendor.Get(Rec."Account No.") then Cif := Vendor."VAT Registration No.";
//         Rec.calcfields("Entidad Cliente");
//     end;

//     var
//         Customer: Record Customer;
//         Vendor: Record Vendor;
//         Cif: Text;

//     procedure Iban(): Text
//     var
//         cBank: Record "Customer Bank Account";
//         vBank: Record "Vendor Bank Account";
//     Begin

//         if Rec.Type = Rec.Type::Receivable THEN BEGIN
//             if not cBank.GET(Rec."Account No.", Rec."Cust./Vendor Bank Acc. Code") THEN
//                 EXIT(cBank.IBAN);
//             cBank.SetRange("Customer No.", rec."Account No.");
//             if cBank.FindFirst() Then exit(cBank.IBAN);
//         END ELSE BEGIN
//             if vBank.GET(Rec."Account No.", Rec."Cust./Vendor Bank Acc. Code") THEN
//                 EXIT(vBank.IBAN);
//             vBank.SetRange("Vendor No.", rec."Account No.");
//             if vBank.FindFirst() Then exit(cBank.IBAN);
//         END;
//     end;

// }
// pageextension 80186 SubPago extends "Docs. in PO Subform"
// {
//     layout
//     {
//         modify("Posting Date")
//         {
//             Visible = true;
//             ApplicationArea = All;
//         }
//         addAfter("No.")
//         {

//             field(Cuenta; Rec."Account No.")
//             {
//                 ApplicationArea = Basic, Suite;
//                 Visible = true;
//             }

//             field("Bill Gr./Pmt. Order No."; Rec."Bill Gr./Pmt. Order No.")
//             {
//                 ApplicationArea = All;
//             }
//             field("C.I.F."; Cif)
//             {
//                 ApplicationArea = All;
//             }
//             field(Nombre; Vendor.Name)
//             {
//                 ApplicationArea = All;
//             }
//             field("Banco"; Rec.Banco)
//             {
//                 ApplicationArea = All;
//             }
//             field("Banco Proveedor"; Rec."Cust./Vendor Bank Acc. Code")
//             {
//                 ApplicationArea = All;
//             }
//             field("Doc Externo"; ExtaernalDoc())
//             {
//                 ApplicationArea = All;
//             }
//             field("Iban"; Iban(Rec))
//             {
//                 ApplicationArea = All;
//             }
//             field("Entidad Cliente"; Rec."Entidad Cliente")
//             {
//                 ApplicationArea = All;
//             }
//         }
//     }
//     actions
//     {
//         addlast("&Docs.")
//         {
//             action("Verifica Iban")
//             {
//                 ApplicationArea = All;
//                 Image = Check;
//                 trigger OnAction()
//                 var
//                     CarteraDoc: Record "Cartera Doc.";
//                     CompaniInfo: Record "Company Information";
//                 begin
//                     CompaniInfo.Get();
//                     CurrPage.SetSelectionFilter(CarteraDoc);
//                     if CarteraDoc.FindFirst() then
//                         repeat
//                             CompaniInfo.CheckIBAN(Iban(CarteraDoc));
//                         until CarteraDoc.Next() = 0;
//                 end;
//             }
//         }
//     }
//     trigger OnAfterGetRecord()
//     var
//         DebitDir: Record "SEPA Direct Debit Mandate";
//     begin
//         Cif := '';
//         if Rec.Type = Rec.Type::Receivable Then
//             if Customer.Get(Rec."Account No.") Then Cif := Customer."VAT Registration No.";
//         if Rec.Type = Rec.Type::Payable then
//             if Vendor.Get(Rec."Account No.") then Cif := Vendor."VAT Registration No.";
//         Rec.calcfields("Entidad Cliente");
//     end;

//     var
//         Customer: Record Customer;
//         Vendor: Record Vendor;
//         Cif: Text;

//     /// <summary>
//     /// Iban.
//     /// </summary>
//     /// <param name="Carteradoc">VAR Record "Cartera Doc.".</param>
//     /// <returns>Return value of type Text.</returns>
//     procedure Iban(var Carteradoc: Record "Cartera Doc."): Text
//     var
//         cBank: Record "Customer Bank Account";
//         vBank: Record "Vendor Bank Account";
//     Begin

//         if Rec.Type = Rec.Type::Receivable THEN BEGIN
//             if not cBank.GET(Carteradoc."Account No.", Carteradoc."Cust./Vendor Bank Acc. Code") THEN
//                 EXIT(cBank.IBAN);
//             cBank.SetRange("Customer No.", Carteradoc."Account No.");
//             if cBank.FindFirst() Then exit(cBank.IBAN);
//         END ELSE BEGIN
//             if vBank.GET(Carteradoc."Account No.", Carteradoc."Cust./Vendor Bank Acc. Code") THEN
//                 EXIT(vBank.IBAN);
//             vBank.SetRange("Vendor No.", Carteradoc."Account No.");
//             if vBank.FindFirst() Then exit(cBank.IBAN);
//         END;
//     end;

//     local procedure ExtaernalDoc(): Text[50]
//     var
//         VendorEntry: Record "Vendor Ledger Entry";
//     begin
//         if VendorEntry.Get(Rec."Entry No.") Then Exit(VendorEntry."External document no.")
//     end;

// }
// pageextension 80156 SubPagoC extends "Docs. in Closed PO Subform"
// {
//     layout
//     {
//         modify("Posting Date")
//         {
//             Visible = true;
//             ApplicationArea = All;
//         }
//         modify("Account No.")
//         {
//             ApplicationArea = All;
//         }
//         addAfter("No.")
//         {

//             field(Cuenta; Rec."Account No.")
//             {
//                 ApplicationArea = Basic, Suite;
//                 Visible = true;
//             }


//             field("Bill Gr./Pmt. Order No."; Rec."Bill Gr./Pmt. Order No.")
//             {
//                 ApplicationArea = All;
//             }
//             field("C.I.F."; Cif)
//             {
//                 ApplicationArea = All;
//             }
//             field(Nombre; Vendor.Name)
//             {
//                 ApplicationArea = All;
//             }
//             field("Banco"; Rec.Banco)
//             {
//                 ApplicationArea = All;
//             }
//             field("Banco Proveedor"; Rec."Cust./Vendor Bank Acc. Code")
//             {
//                 ApplicationArea = All;
//             }

//             field("Iban"; Iban)
//             {
//                 ApplicationArea = All;
//             }
//             field("Entidad Cliente"; Rec."Entidad Cliente")
//             {
//                 ApplicationArea = All;
//             }
//         }
//     }
//     trigger OnAfterGetRecord()
//     var
//         DebitDir: Record "SEPA Direct Debit Mandate";
//     begin
//         Cif := '';
//         if Rec.Type = Rec.Type::Receivable Then
//             if Customer.Get(Rec."Account No.") Then Cif := Customer."VAT Registration No.";
//         if Rec.Type = Rec.Type::Payable then
//             if Vendor.Get(Rec."Account No.") then Cif := Vendor."VAT Registration No.";
//         Rec.calcfields("Entidad Cliente");
//     end;

//     var
//         Customer: Record Customer;
//         Vendor: Record Vendor;
//         Cif: Text;

//     procedure Iban(): Text
//     var
//         cBank: Record "Customer Bank Account";
//         vBank: Record "Vendor Bank Account";
//     Begin

//         if Rec.Type = Rec.Type::Receivable THEN BEGIN
//             if not cBank.GET(Rec."Account No.", Rec."Cust./Vendor Bank Acc. Code") THEN
//                 EXIT(cBank.IBAN);
//             cBank.SetRange("Customer No.", rec."Account No.");
//             if cBank.FindFirst() Then exit(cBank.IBAN);
//         END ELSE BEGIN
//             if vBank.GET(Rec."Account No.", Rec."Cust./Vendor Bank Acc. Code") THEN
//                 EXIT(vBank.IBAN);
//             vBank.SetRange("Vendor No.", rec."Account No.");
//             if vBank.FindFirst() Then exit(cBank.IBAN);
//         END;
//     end;

// }
// pageextension 80187 OrdenPago extends "Payment Orders"
// {
//     actions
//     {
//         addafter(Export)
//         {
//             action("Anular Envio")
//             {
//                 ApplicationArea = all;
//                 Image = Undo;
//                 trigger OnAction()
//                 var
//                 begin
//                     Rec."Elect. Pmts Exported" := false;
//                     Rec.Modify();
//                 end;
//             }
//         }
//     }
// }
// pageextension 80194 PostedBillGroups Extends "Posted Bill Groups"
// {
//     actions
//     {
//         addlast("Bill &Group")
//         {
//             action(Cerrar)
//             {
//                 ApplicationArea = All;
//                 Image = Close;
//                 trigger OnAction()
//                 VAR
//                     DocPost: Codeunit ControlProcesos;
//                 BEGIN
//                     DocPost.CloseBillGroupIfEmpty(Rec, TODAY);
//                 END;
//             }

//             action("Cerrar de Todas Formas")
//             {
//                 ApplicationArea = All;
//                 Image = ClosePeriod;
//                 trigger OnAction()
//                 VAR
//                     r70004: Record 7000003;
//                     DocPost: Codeunit ControlProcesos;
//                     ControlProcesos: Codeunit ControlProcesos;
//                 BEGIN
//                     ControlProcesos.CierreProcesos(Rec);
//                     Commit();
//                     DocPost.CloseBillGroupIfEmpty(Rec, TODAY);
//                 END;
//             }

//         }

//     }
// }
// pageextension 80195 OrdenPagoR extends "Posted Payment Orders"
// {
//     actions
//     {
//         addafter("&Navigate")
//         {
//             action("Comprobar Importe Pendiente")
//             {
//                 ApplicationArea = all;
//                 Image = ApplyEntries;
//                 trigger OnAction()
//                 var
//                     Mov: Record "Mov. emplazamientos";
//                     Movt: Record "Mov. emplazamientos" temporary;
//                     Docs: Record "Posted Cartera Doc.";
//                 begin
//                     Docs.SetRange("Bill Gr./Pmt. Order No.", Rec."No.");
//                     if Docs.FindFirst() Then
//                         repeat
//                             Mov.SetRange("Nº Factura definitivo", Docs."Document No.");
//                             if Mov.FindFirst() Then
//                                 repeat
//                                     if Mov."Importe pendiente" <> 0 then
//                                         Mov."Importe pagado" += Mov."Importe pendiente";
//                                     mov."Importe Pendiente S/Iva" := 0;
//                                     mov."Importe pendiente" := 0;
//                                     Mov.Modify();
//                                     Movt := Mov;
//                                     If Movt.Insert() then;
//                                 until Mov.Next() = 0;
//                         until Docs.Next() = 0;
//                     Commit();
//                     Page.runmodal(0, Movt);
//                 end;
//             }
//             action(Cerrar)
//             {
//                 ApplicationArea = All;
//                 Image = Close;
//                 trigger OnAction()
//                 VAR
//                     DocPost: Codeunit ControlProcesos;
//                 BEGIN
//                     DocPost.CloseOrderGroupIfEmpty(Rec, TODAY);
//                 END;
//             }

//             action("Cerrar de Todas Formas")
//             {
//                 ApplicationArea = All;
//                 Image = ClosePeriod;
//                 trigger OnAction()
//                 VAR
//                     r70004: Record 7000003;
//                     DocPost: Codeunit ControlProcesos;
//                     ControlProcesos: Codeunit ControlProcesos;
//                 BEGIN
//                     ControlProcesos.CierreProcesosPo(Rec);
//                     Commit();
//                     DocPost.CloseOrderGroupIfEmpty(Rec, TODAY);
//                 END;
//             }
//         }
//     }
// }
// pageextension 80196 OrdenPagoC extends "Closed Payment Orders"
// {
//     actions
//     {
//         addafter("&Navigate")
//         {
//             action("Comprobar Importe Pendiente")
//             {
//                 ApplicationArea = all;
//                 Image = ApplyEntries;
//                 trigger OnAction()
//                 var
//                     Mov: Record "Mov. emplazamientos";
//                     Docs: Record "Closed Cartera Doc.";
//                     a: Integer;
//                     b: Integer;
//                 begin
//                     Docs.SetRange("Bill Gr./Pmt. Order No.", Rec."No.");
//                     b := Docs.Count;
//                     if Docs.FindFirst() Then
//                         repeat
//                             Mov.SetRange("Nº Factura definitivo", Docs."Document No.");
//                             if Mov.FindFirst() Then
//                                 repeat
//                                     Mov.Validate("Importe pendiente", 0);
//                                     Mov.Modify();
//                                     a += 1;
//                                 until Mov.Next() = 0;
//                         until Docs.Next() = 0;
//                     Message(StrSubstNo('Se han actualizado %1 mov. en un total de %2 documentos de cartera', a, b));
//                 end;
//             }
//         }
//     }
// }
// pageextension 80184 OrdenPagoregis extends "Posted Payment Orders Select."
// {

//     layout
//     {
//         modify("No.")
//         {
//             trigger OnDrillDown()
//             begin
//                 Page.Runmodal(Page::"Posted Payment Orders", Rec);
//             end;
//         }
//     }

// }
