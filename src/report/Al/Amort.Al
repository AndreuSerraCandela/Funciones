// reportextension 7001102 CAL extends "Calculate Depreciation"
// {
//     requestpage

//     {
//         layout
//         {
//             modify(PostingDate)
//             {
//                 trigger OnAfterValidate()
//                 var
//                     FAJnlSetup: Record "FA Journal Setup";
//                     GenJnlTemplate: Record "Gen. Journal Template";
//                     GenJnlBatch: Record "Gen. Journal Batch";
//                     FAGetJnl: Codeunit "FA Get Journal";
//                     TemplateName: Code[10];
//                     BatchName: Code[10];
//                     GenJnlLine: Record "Gen. Journal Line";
//                 begin
//                     FAJnlSetup.TestField("Gen. Jnl. Template Name");
//                     FAJnlSetup.TestField("Gen. Jnl. Batch Name");
//                     TemplateName := FAJnlSetup."Gen. Jnl. Template Name";
//                     BatchName := FAJnlSetup."Gen. Jnl. Batch Name";
//                     GenJnlTemplate.Get(TemplateName);
//                     GenJnlBatch.Get(TemplateName, BatchName);
//                     GenJnlLine.SetRange("Journal Template Name", TemplateName);
//                     GenJnlLine.SetRange("Journal Batch Name", BatchName);
//                     GenJnlLine.SetRange("Posting Date", PostingDate);
//                     if GenJnlLine.FindFirst() then Error('Hay líneas en el diario para esta fecha, elimínelas o regístrelas para continuar');
//                 end;

//             }
//         }
//     }
//     trigger OnPreReport()
//     begin
//         PostingDate := 0D;
//         DeprUntilDate := 0D;
//     end;

// }