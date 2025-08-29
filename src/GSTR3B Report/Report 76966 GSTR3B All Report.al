report 76966 "GSTR3B All Report"
{
    ApplicationArea = All;
    Caption = 'GSTR-3B ISPL';
    UsageCategory = ReportsAndAnalysis;
    ProcessingOnly = true;

    dataset
    {

    }
    requestpage
    {

        layout
        {
            area(content)
            {
                field("GSTIN No"; GSTIN)
                {
                    Caption = 'GSTIN No.';
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the GST registration number for which the report will be generated.';
                    // TableRelation = "GST Registration Nos.";

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        GSTRegnNos_lRec: Record "GST Registration Nos.";
                        GSTRegnNos_lPge: Page "GST Registration Nos.";
                    begin
                        GSTRegnNos_lRec.Reset();

                        Clear(GSTRegnNos_lPge);
                        GSTIN := '';
                        GSTRegnNos_lPge.LookupMode(true);
                        GSTRegnNos_lPge.SetTableView(GSTRegnNos_lRec);
                        if GSTRegnNos_lPge.RunModal() = Action::LookupOK then begin
                            GSTRegnNos_lRec.Reset();
                            GSTRegnNos_lPge.SetSelectionFilter(GSTRegnNos_lRec);
                            if GSTRegnNos_lRec.FindSet then begin
                                repeat
                                    if GSTIN = '' then
                                        GSTIN := GSTRegnNos_lRec.Code
                                    else
                                        GSTIN := GSTIN + '|' + GSTRegnNos_lRec.Code;
                                until GSTRegnNos_lRec.Next = 0;
                            end;
                        end else
                            Error('');
                    end;
                }
                field("Period Date"; PeriodDate)
                {
                    Caption = 'Period Date';
                    ToolTip = 'Specifies the date that you want the period of the Return.';
                    ApplicationArea = Basic, Suite;
                }
                field("Authorised Person"; AuthorisedPerson)
                {
                    Caption = 'Name of the Authorized Person';
                    ToolTip = 'Specifies the Authorised Person Name for Print on Report.';
                    ApplicationArea = Basic, Suite;
                }
                field("Place Name"; Place)
                {
                    Caption = 'Place';
                    ToolTip = 'Specifies the Place Name for Print on Reports.';
                    ApplicationArea = Basic, Suite;
                }
                field("Posting Date"; PostingDate)
                {
                    Caption = 'Posting Date';
                    ToolTip = 'Specifies the Date for print on Reports. Date should be after end of the period.';
                    ApplicationArea = Basic, Suite;

                    trigger OnValidate()
                    begin
                        if PeriodDate = 0D then
                            Error(PeriodDateErr);
                        if PostingDate <= CalcDate('<CM>', PeriodDate) then
                            Error(PostingDateErr, CalcDate('<CM>', PeriodDate));
                    end;
                }
            }
        }
    }

    trigger OnPreReport()
    var
        GSTRBISPL_lRpt: Report "GSTR-3B ISPL";
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
        FileName: Text;
    begin
        if PeriodDate = 0D then
            Error(PeriodDateErr);
        if AuthorisedPerson = '' then
            Error(AuthErr);
        if Place = '' then
            Error(PlaceErr);
        if PostingDate = 0D then
            Error(PostingDateBlankErr);

        Clear(GSTRBISPL_lRpt);

        GSTRegnNos_lRec.Reset();
        GSTRegnNos_lRec.SetFilter(Code, GSTIN);
        if GSTRegnNos_lRec.FindSet then begin
            GSTRCount_lInt := GSTRegnNos_lRec.Count;
            if GSTRCount_lInt > 1 then begin
                Clear(DataCompression);
                DataCompression.CreateZipArchive();
            end;
            repeat
                Commit;

                Clear(ReportRunTempBlob);
                Clear(Rpt_OutStream);
                Clear(Rpt_Instr);
                ReportRunTempBlob.CreateOutStream(Rpt_OutStream);

                Clear(GSTRBISPL_lRpt);
                GSTRBISPL_lRpt.UseRequestPage(false);
                GSTRBISPL_lRpt.SetJustFillData_gFnc(GSTRegnNos_lRec.Code, PeriodDate, AuthorisedPerson, Place, PostingDate);
                GSTRBISPL_lRpt.SaveAs('', ReportFormat::Pdf, Rpt_OutStream);
                ReportRunTempBlob.CREATEINSTREAM(Rpt_Instr);
                FileName := StrSubstNo('GSTR3B_%1_%2%3.pdf', GSTRegnNos_lRec.Code, Date2DMY(PeriodDate, 2), Date2DMY(PeriodDate, 3));

                if GSTRCount_lInt > 1 then begin
                    DataCompression.AddEntry(Rpt_Instr, FileName);
                end else
                    DownloadFromStream(Rpt_Instr, '', '', '', FileName);

            until GSTRegnNos_lRec.Next = 0;

            if GSTRCount_lInt > 1 then begin
                //Save Zip Archive and Convert in InStream Data
                ZipTempBlob.CreateOutStream(ZipFileOutStream);
                DataCompression.SaveZipArchive(ZipFileOutStream);
                ZipTempBlob.CreateInStream(ZipFileInStream);


                DataCompression.CloseZipArchive();

                ZipFileName := 'GSTR3B.Zip';
                DOWNLOADFROMSTREAM(ZipFileInStream, '', '', '', ZipFileName);

            end;
        end;
    end;

    var
        GSTIN: Text;
        PeriodDate: Date;
        AuthorisedPerson: Text[100];
        Place: Text[50];
        PostingDate: Date;
        PostingDateErr: Label 'Posting Date must be after Period End Date %1.', Comment = '%1= period date';
        PeriodDateErr: Label 'Period Date can not be Blank.', Locked = true;
        AuthErr: Label 'Provide a name for the Authorised Person.', Locked = true;
        PlaceErr: Label 'Provide the name of Place.', Locked = true;
        PostingDateBlankErr: Label 'Posting Date can not be Blank.', Locked = true;
}
