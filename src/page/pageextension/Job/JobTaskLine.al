// pageextension 80127 JobLine extends "Job Task Lines"
// {
//     var
//         Job: Record Job;
//         CurrentJobNo: Code[20];
//         CurrentJobNo3: Code[20];
//         JobDescription: Text[200];

//     trigger OnOpenPage()
//     begin

//         if CurrentJobNo3 <> '' THEN
//             CurrentJobNo := CurrentJobNo3;
//         if NOT Job.GET(CurrentJobNo) THEN
//             Job.FIND('-');
//         CurrentJobNo := Job."No.";
//         JobDescription := Job.Description;
//         Rec.FILTERGROUP := 2;
//         Rec.SETRANGE("Job No.", CurrentJobNo);
//         Rec.FILTERGROUP := 0;
//     end;

//     procedure SetJobNo(CurrentJobNo2: Code[20]);
//     begin
//         CurrentJobNo3 := CurrentJobNo2;
//     end;


// }