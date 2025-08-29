report 76952 "GSTR All Report Multiple"
{
    ApplicationArea = All;
    Caption = 'GSTR All Report';
    UsageCategory = ReportsAndAnalysis;
    ProcessingOnly = true;




    requestpage
    {
        SaveValues = true;

        layout
        {
            area(content)
            {
                field(Month; Month_gInt)
                {
                    ApplicationArea = Basic;
                    Caption = 'Month';
                    MaxValue = 12;
                    MinValue = 0;
                }
                field(Year; Year_gInt)
                {
                    ApplicationArea = Basic;
                    Caption = 'Year';
                    MaxValue = 2099;
                    MinValue = 2017;
                }
                field("GST Register No."; GSTRegNo_gCod)
                {
                    ApplicationArea = Basic;
                    Caption = 'GST Registration No.';
                    // TableRelation = "GST Registration Nos.";

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        GSTRegnNos_lRec: Record "GST Registration Nos.";
                        GSTRegnNos_lPge: Page "GST Registration Nos.";
                    begin
                        GSTRegnNos_lRec.Reset();

                        Clear(GSTRegnNos_lPge);
                        GSTRegNo_gCod := '';
                        GSTRegnNos_lPge.LookupMode(true);
                        GSTRegnNos_lPge.SetTableView(GSTRegnNos_lRec);
                        if GSTRegnNos_lPge.RunModal() = Action::LookupOK then begin
                            GSTRegnNos_lRec.Reset();
                            GSTRegnNos_lPge.SetSelectionFilter(GSTRegnNos_lRec);
                            if GSTRegnNos_lRec.FindSet then begin
                                repeat
                                    if GSTRegNo_gCod = '' then
                                        GSTRegNo_gCod := GSTRegnNos_lRec.Code
                                    else
                                        GSTRegNo_gCod := GSTRegNo_gCod + '|' + GSTRegnNos_lRec.Code;
                                until GSTRegnNos_lRec.Next = 0;
                            end;
                        end else
                            Error('');
                    end;
                }
            }
        }
    }

    trigger OnPreReport()
    var
        GSTRAllReport_lRpt: Report "GSTR All Report";
        GSTRegnNos_lRec: Record "GST Registration Nos.";
        GSTRCount_lInt: Integer;
        GSTROutStream: OutStream;
        Rpt_Instr: InStream;
        DataCompression: Codeunit "Data Compression";
        ZipTempBlob: Codeunit "Temp Blob";
        ZipFileOutStream: OutStream;
        ZipFileInStream: InStream;
        ZipFileName: Text;
        ReportRunTempBlob: Codeunit "Temp Blob";
        Rpt_OutStream: OutStream;
    begin
        Clear(GSTRAllReport_lRpt);

        GSTRegnNos_lRec.Reset();
        GSTRegnNos_lRec.SetFilter(Code, GSTRegNo_gCod);
        if GSTRegnNos_lRec.FindSet then begin
            GSTRCount_lInt := GSTRegnNos_lRec.Count;
            if GSTRCount_lInt > 1 then begin
                Clear(DataCompression);
                DataCompression.CreateZipArchive();
            end;
            repeat
                Commit;

                Clear(GSTRAllReport_lRpt);
                GSTRAllReport_lRpt.UseRequestPage(false);
                GSTRAllReport_lRpt.SetJustFillData_gFnc(Month_gInt, Year_gInt, GSTRegnNos_lRec.Code, GSTRCount_lInt - 1);
                GSTRAllReport_lRpt.RunModal();

                if GSTRCount_lInt > 1 then begin
                    Clear(Rpt_OutStream);
                    Clear(GSTROutStream);
                    Clear(Rpt_Instr);
                    ReportRunTempBlob.CreateOutStream(Rpt_OutStream);
                    GSTRAllReport_lRpt.CreateExcelBook_Zip(Rpt_OutStream);
                    Rpt_OutStream := GSTROutStream;
                    ReportRunTempBlob.CREATEINSTREAM(Rpt_Instr);

                    DataCompression.AddEntry(Rpt_Instr, StrSubstNo('GSTR1_%1_%2%3.xlsx', GSTRegnNos_lRec.Code, Month_gInt, Year_gInt));

                end;

            until GSTRegnNos_lRec.Next = 0;

            if GSTRCount_lInt > 1 then begin
                //Save Zip Archive and Convert in InStream Data
                ZipTempBlob.CreateOutStream(ZipFileOutStream);
                DataCompression.SaveZipArchive(ZipFileOutStream);
                ZipTempBlob.CreateInStream(ZipFileInStream);


                DataCompression.CloseZipArchive();

                ZipFileName := 'GSTR.Zip';
                DOWNLOADFROMSTREAM(ZipFileInStream, '', '', '', ZipFileName);

            end;
        end;
    end;

    var
        Month_gInt: Integer;
        Year_gInt: Integer;
        GSTRegNo_gCod: Text;
}
