Report 76955 "GST EXP"
{
    Caption = 'GST EXP';
    ProcessingOnly = true;

    dataset
    {
        dataitem("Detailed GST Ledger Entry"; "Detailed GST Ledger Entry")
        {
            DataItemTableView = sorting("Transaction Type", "Document Type", "Document No.", "Document Line No.");
            RequestFilterFields = "Document Type", "Document No.";


            trigger OnAfterGetRecord()
            var
                ConsiderEntry_lBln: Boolean;
                SIH_lRec: Record "Sales Invoice Header";
                SerInvHdr_lRec: Record "Service Invoice Header";
                DataExport_lBln: Boolean;
            begin
                CurrRec_gInt += 1;
                if SetOutPutFile_gTxt = '' then
                    Win.Update(2, CurrRec_gInt);

                if ("GST %" = 0) and (not "GST Without Payment of Duty") then
                    CurrReport.Skip;

                if "GST Component Code" = 'KFLOODCESS' then
                    CurrReport.Skip();

                ConsiderEntry_lBln := false;

                //Posted Sales & Service Invoice
                if ("Transaction Type" = "transaction type"::Sales) and ("Document Type" in ["document type"::Invoice]) then begin
                    ConsiderEntry_lBln := true;
                end;

                if not ConsiderEntry_lBln then
                    CurrReport.Skip;

                //Posted Sales & Service Invoice
                DataExport_lBln := false;
                PortCode_gCod := '';

                if SIH_lRec.Get("Document No.") then begin
                    PortCode_gCod := SIH_lRec."Exit Point";
                    PostedSalesInvocie_gFnc("Detailed GST Ledger Entry");
                    DataExport_lBln := true;
                end;

                if not DataExport_lBln then begin
                    if SerInvHdr_lRec.Get("Document No.") then begin
                        PortCode_gCod := SerInvHdr_lRec."Exit Point";
                        PostedSalesInvocie_gFnc("Detailed GST Ledger Entry");
                        DataExport_lBln := true;
                    end;
                end;

                if not DataExport_lBln then
                    Error('Case not found for Data Export');
            end;

            trigger OnPreDataItem()
            var
                TempCnt_lInt: Integer;
            begin

                SD_gDte := Dmy2date(1, Month_gInt, Year_gInt);
                ED_gDte := CalcDate('CM', SD_gDte);
                if GSTRegNo_gCod <> '' then
                    SetRange("Location  Reg. No.", GSTRegNo_gCod);
                SetRange("Entry Type", "entry type"::"Initial Entry");
                SetRange("Posting Date", SD_gDte, ED_gDte);
                SetRange("Transaction Type", "transaction type"::Sales);
                //SetFilter("GST Customer Type", '%1|%2|%3', "Detailed GST Ledger Entry"."gst customer type"::Export, "Detailed GST Ledger Entry"."gst customer type"::"SEZ Development", "Detailed GST Ledger Entry"."gst customer type"::"SEZ Unit");
                SetRange("GST Customer Type", "Detailed GST Ledger Entry"."gst customer type"::Export);
                SetRange("Document Type", "document type"::Invoice);
                SetFilter("GST Component Code", '<>%1', 'SGST');  //Only CGST Line consider for export data
                SetRange("GST Exempted Goods", false);
                //SETFILTER("GST %",'<>%1',0);

                CurrRec_gInt := 0;
                TempCnt_lInt := Count;
                if SetOutPutFile_gTxt = '' then
                    Win.Update(1, Count);

                GSTEXP_gRec.Reset;
                GSTEXP_gRec.SetCurrentkey("GST Month", "GST Year");
                GSTEXP_gRec.SetRange("GST Month", Month_gInt);
                GSTEXP_gRec.SetRange("GST Year", Year_gInt);
                GSTEXP_gRec.SetRange("GST Registration No.", GSTRegNo_gCod);
                GSTEXP_gRec.DeleteAll;
            end;
        }
    }

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
                field("Export to Excel"; ExportToExcel_gBln)
                {
                    ApplicationArea = Basic;
                    Caption = 'Export to Excel';
                }
            }
        }

        actions
        {
        }
    }

    labels
    {
    }

    trigger OnPostReport()
    var
        GSTExp_lXml: XmlPort "GST EXP Export";
        GSTExp_lRec: Record "GST EXP";
        OutputFile_lFile: File;
        OutStream_lOST: OutStream;
        TempBlob_lCdu: Codeunit "Temp Blob";
        SetOutPutFile_Instr: Instream;
    begin
        if SetOutPutFile_gTxt = '' then
            Win.Close;

        Commit;

        if not JustFillData_gBln then begin
            GSTExp_lRec.Reset;
            GSTExp_lRec.SetRange("GST Month", Month_gInt);
            GSTExp_lRec.SetRange("GST Year", Year_gInt);
            GSTExp_lRec.SetRange("GST Registration No.", GSTRegNo_gCod);
            if ExportToExcel_gBln then begin
                MakeExcelDataInfo_lFnc;
                if GSTExp_lRec.FindSet then begin
                    DataExported_gBln := true;
                    if ExcelSaveFilePath_gTxt <> '' then
                        MakeExcelDataHeader_lFnc;
                    repeat
                        MakeExcelDataBody_lFnc(GSTExp_lRec);
                    until GSTExp_lRec.Next = 0;
                end;
                CreateExcelBook_lFnc;
            end else begin
                Clear(GSTExp_lXml);
                GSTExp_lXml.SetTableview(GSTExp_lRec);

                if SetOutPutFile_gTxt = '' then begin
                    GSTExp_lXml.Run;
                end else begin
                    if GSTExp_lRec.IsEmpty then
                        CurrReport.Break;
                    // OutputFile_lFile.Create(SetOutPutFile_gTxt);
                    // OutputFile_lFile.CreateOutstream(OutStream_lOST);

                    Clear(TempBlob_lCdu);
                    TempBlob_lCdu.CreateInStream(SetOutPutFile_Instr);
                    SetOutPutFile_Instr.ReadText(SetOutPutFile_gTxt);
                    CopyStream(OutStream_lOST, SetOutPutFile_Instr);

                    GSTExp_lXml.HideWinDialog_gFnc;
                    GSTExp_lXml.SetDestination(OutStream_lOST);
                    GSTExp_lXml.Export;
                    DataExported_gBln := true;
                end;
            end;
        end;
    end;

    trigger OnPreReport()
    begin
        if Month_gInt = 0 then
            Error('Select Month to Export Data');

        if Year_gInt = 0 then
            Error('Select Year to Export Data');

        if GSTRegNo_gCod = '' then
            Error('Select GST Registration No.');


        SD_gDte := Dmy2date(1, Month_gInt, Year_gInt);
        ED_gDte := CalcDate('CM', SD_gDte);

        if SetOutPutFile_gTxt = '' then
            Win.Open('Total Record #1##########\Current Record #2###########');
    end;

    var
        Text001: label 'Outward';
        Text005: label 'Company Name';
        Text006: label 'Report No.';
        Text007: label 'Report Name';
        Text008: label 'User ID';
        Text009: label 'Date';
        Text010: label 'Filters';
        Month_gInt: Integer;
        Year_gInt: Integer;
        GSTRegNo_gCod: Text;
        SD_gDte: Date;
        ED_gDte: Date;
        Text50009_gCtx: label 'Outward';
        Win: Dialog;
        CurrRec_gInt: Integer;
        // GSTManagement: Codeunit UnknownCodeunit16401;
        GSTEXP_gRec: Record "GST EXP";
        GSTRCommonFunction_gCdu: Codeunit "GSTR Common Function";
        PortCode_gCod: Code[6];
        GSTSetup_gRec: Record "GST Setup";
        SetOutPutFile_gTxt: Text[250];
        DataExported_gBln: Boolean;
        ExcelBuffer_gRecTmp: Record "Excel Buffer" temporary;
        ExportToExcel_gBln: Boolean;
        JustFillData_gBln: Boolean;
        ExcelSaveFilePath_gTxt: Text;

    local procedure PostedSalesInvocie_gFnc(DetailedGSTLedgerEntry_iRec: Record "Detailed GST Ledger Entry")
    var
        GSTEXP_lRec: Record "GST EXP";
        SalesInvoiceHeader_lRec: Record "Sales Invoice Header";
        ServInvoiceHdr_lRec: Record "Service Invoice Header";
    begin
        if DetailedGSTLedgerEntry_iRec."GST Component Code" = 'CGST' then
            DetailedGSTLedgerEntry_iRec."GST %" := DetailedGSTLedgerEntry_iRec."GST %" * 2;

        if (DetailedGSTLedgerEntry_iRec."GST %" = 0) and (DetailedGSTLedgerEntry_iRec."GST Without Payment of Duty") then begin  //System make GST % zero when GST Payment With Duty
            // GSTSetup_gRec.Reset;
            // GSTSetup_gRec.SetRange("GST Group Code", DetailedGSTLedgerEntry_iRec."GST Group Code");
            // GSTSetup_gRec.SetRange("GST Component Code", DetailedGSTLedgerEntry_iRec."GST Component Code");
            // GSTSetup_gRec.FindLast;
            // DetailedGSTLedgerEntry_iRec."GST %" := GSTSetup_gRec."GST Component %";
        end;

        GSTEXP_lRec.Reset;
        GSTEXP_lRec.SetCurrentkey("Invoice Number", Rate);
        GSTEXP_lRec.SetRange("Invoice Number", DetailedGSTLedgerEntry_iRec."Document No.");
        GSTEXP_lRec.SetRange(Rate, DetailedGSTLedgerEntry_iRec."GST %");
        if not GSTEXP_lRec.FindFirst then begin
            GSTEXP_lRec.Init;
            GSTEXP_lRec."GST Month" := Month_gInt;
            GSTEXP_lRec."GST Year" := Year_gInt;
            GSTEXP_lRec."GST Registration No." := DetailedGSTLedgerEntry_iRec."Location  Reg. No.";

            if DetailedGSTLedgerEntry_iRec."GST Without Payment of Duty" then
                GSTEXP_lRec."Export Type" := GSTEXP_lRec."export type"::WOPAY
            else
                GSTEXP_lRec."Export Type" := GSTEXP_lRec."export type"::WPAY;

            GSTEXP_lRec."Invoice Number" := DetailedGSTLedgerEntry_iRec."Document No.";
            GSTEXP_lRec."Invoice date" := DetailedGSTLedgerEntry_iRec."Posting Date";
            GSTEXP_lRec."Invoice Value" := GSTRCommonFunction_gCdu.FindInvoiceValue_gFnc(DetailedGSTLedgerEntry_iRec);
            GSTEXP_lRec."Port Code" := PortCode_gCod;
            // GSTEXP_lRec."Shipping Bill Date" := DetailedGSTLedgerEntry_iRec."Bill Of Export Date";
            // GSTEXP_lRec."Shipping Bill Number" := DetailedGSTLedgerEntry_iRec."Bill Of Export No.";

            if SalesInvoiceHeader_lRec.get(DetailedGSTLedgerEntry_iRec."Document No.") then begin
                GSTEXP_lRec."Shipping Bill Date" := SalesInvoiceHeader_lRec."Bill Of Export Date";
                GSTEXP_lRec."Shipping Bill Number" := SalesInvoiceHeader_lRec."Bill Of Export No.";
            End Else
                if ServInvoiceHdr_lRec.get(DetailedGSTLedgerEntry_iRec."Document No.") then begin
                    GSTEXP_lRec."Shipping Bill Date" := ServInvoiceHdr_lRec."Bill Of Export Date";
                    GSTEXP_lRec."Shipping Bill Number" := ServInvoiceHdr_lRec."Bill Of Export No.";
                end;


            GSTEXP_lRec.Rate := DetailedGSTLedgerEntry_iRec."GST %";
            GSTEXP_lRec.Insert;
        end;

        GSTEXP_lRec."Taxable Value" := GSTEXP_lRec."Taxable Value" + Abs(DetailedGSTLedgerEntry_iRec."GST Base Amount");
        GSTEXP_lRec.Modify;
    end;


    procedure SetParameter_gFnc(Month_iInt: Integer; Year_iInt: Integer; GSTRegNo_iCod: Text; SetOutPutFile_iTxt: Text[250])
    begin
        Month_gInt := Month_iInt;
        Year_gInt := Year_iInt;
        GSTRegNo_gCod := GSTRegNo_iCod;
        SetOutPutFile_gTxt := SetOutPutFile_iTxt;
    end;


    procedure IsDataExported_gFnc(): Boolean
    begin
        exit(DataExported_gBln);
    end;

    local procedure MakeExcelDataInfo_lFnc()
    begin
        if ExcelSaveFilePath_gTxt <> '' then
            exit;

        ExcelBuffer_gRecTmp.SetUseInfoSheet;
        ExcelBuffer_gRecTmp.AddInfoColumn(Format(Text005), false, true, false, false, '', ExcelBuffer_gRecTmp."cell type"::Text);
        ExcelBuffer_gRecTmp.AddInfoColumn(COMPANYNAME, false, false, false, false, '', ExcelBuffer_gRecTmp."cell type"::Text);
        ExcelBuffer_gRecTmp.NewRow;
        ExcelBuffer_gRecTmp.AddInfoColumn(Format(Text007), false, true, false, false, '', ExcelBuffer_gRecTmp."cell type"::Text);
        ExcelBuffer_gRecTmp.AddInfoColumn('GST EXP', false, false, false, false, '', ExcelBuffer_gRecTmp."cell type"::Text);
        ExcelBuffer_gRecTmp.NewRow;
        ExcelBuffer_gRecTmp.AddInfoColumn(Format(Text006), false, true, false, false, '', ExcelBuffer_gRecTmp."cell type"::Text);
        ExcelBuffer_gRecTmp.AddInfoColumn(Report::"GST EXP", false, false, false, false, '', ExcelBuffer_gRecTmp."cell type"::Number);
        ExcelBuffer_gRecTmp.NewRow;
        ExcelBuffer_gRecTmp.AddInfoColumn(Format(Text008), false, true, false, false, '', ExcelBuffer_gRecTmp."cell type"::Text);
        ExcelBuffer_gRecTmp.AddInfoColumn(UserId, false, false, false, false, '', ExcelBuffer_gRecTmp."cell type"::Text);
        ExcelBuffer_gRecTmp.NewRow;
        ExcelBuffer_gRecTmp.AddInfoColumn(Format(Text009), false, true, false, false, '', ExcelBuffer_gRecTmp."cell type"::Text);
        ExcelBuffer_gRecTmp.AddInfoColumn(Today, false, false, false, false, '', ExcelBuffer_gRecTmp."cell type"::Date);
        ExcelBuffer_gRecTmp.NewRow;
        ExcelBuffer_gRecTmp.AddInfoColumn('Filters', false, true, false, false, '', ExcelBuffer_gRecTmp."cell type"::Text);
        ExcelBuffer_gRecTmp.AddInfoColumn(CopyStr("Detailed GST Ledger Entry".GetFilters, 1, 250), false, false, false, false, '', ExcelBuffer_gRecTmp."cell type"::Text);

        ExcelBuffer_gRecTmp.ClearNewRow;
        MakeExcelDataHeader_lFnc;
    end;

    local procedure MakeExcelDataHeader_lFnc()
    begin
        ExcelBuffer_gRecTmp.NewRow;
        ExcelBuffer_gRecTmp.AddColumn('Export Type', false, '', true, false, true, '', ExcelBuffer_gRecTmp."cell type"::Text);
        ExcelBuffer_gRecTmp.AddColumn('Invoice Number', false, '', true, false, true, '', ExcelBuffer_gRecTmp."cell type"::Text);
        ExcelBuffer_gRecTmp.AddColumn('Invoice date', false, '', true, false, true, '', ExcelBuffer_gRecTmp."cell type"::Text);
        ExcelBuffer_gRecTmp.AddColumn('Invoice Value', false, '', true, false, true, '', ExcelBuffer_gRecTmp."cell type"::Text);
        ExcelBuffer_gRecTmp.AddColumn('Port Code', false, '', true, false, true, '', ExcelBuffer_gRecTmp."cell type"::Text);
        ExcelBuffer_gRecTmp.AddColumn('Shipping Bill Number', false, '', true, false, true, '', ExcelBuffer_gRecTmp."cell type"::Text);
        ExcelBuffer_gRecTmp.AddColumn('Shipping Bill Date', false, '', true, false, true, '', ExcelBuffer_gRecTmp."cell type"::Text);
        ExcelBuffer_gRecTmp.AddColumn('Rate', false, '', true, false, true, '', ExcelBuffer_gRecTmp."cell type"::Text);
        ExcelBuffer_gRecTmp.AddColumn('Taxable Value', false, '', true, false, true, '', ExcelBuffer_gRecTmp."cell type"::Text);
    end;

    local procedure MakeExcelDataBody_lFnc(GSTEXP_iRec: Record "GST EXP")
    var
        BankAcc_lRec: Record "Bank Account";
        Vendor_lRec: Record Vendor;
        Customer_lRec: Record Customer;
        FixedAsset_lRec: Record "Fixed Asset";
        AmtDrLCY_lDec: Decimal;
        AmtCrLCY_lDec: Decimal;
    begin
        ExcelBuffer_gRecTmp.NewRow;
        ExcelBuffer_gRecTmp.AddColumn(Format(GSTEXP_iRec."Export Type"), false, '', false, false, false, '', ExcelBuffer_gRecTmp."cell type"::Text);
        ExcelBuffer_gRecTmp.AddColumn(GSTEXP_iRec."Invoice Number", false, '', false, false, false, '', ExcelBuffer_gRecTmp."cell type"::Text);
        ExcelBuffer_gRecTmp.AddColumn(GSTEXP_iRec."Invoice date", false, '', false, false, false, '', ExcelBuffer_gRecTmp."cell type"::Date);
        ExcelBuffer_gRecTmp.AddColumn(GSTEXP_iRec."Invoice Value", false, '', false, false, false, '#,##0.00', ExcelBuffer_gRecTmp."cell type"::Number);
        ExcelBuffer_gRecTmp.AddColumn(GSTEXP_iRec."Port Code", false, '', false, false, false, '', ExcelBuffer_gRecTmp."cell type"::Text);
        ExcelBuffer_gRecTmp.AddColumn(GSTEXP_iRec."Shipping Bill Number", false, '', false, false, false, '', ExcelBuffer_gRecTmp."cell type"::Text);
        ExcelBuffer_gRecTmp.AddColumn(GSTEXP_iRec."Shipping Bill Date", false, '', false, false, false, '', ExcelBuffer_gRecTmp."cell type"::Date);
        ExcelBuffer_gRecTmp.AddColumn(GSTEXP_iRec.Rate, false, '', false, false, false, '#,##0.00', ExcelBuffer_gRecTmp."cell type"::Number);
        ExcelBuffer_gRecTmp.AddColumn(GSTEXP_iRec."Taxable Value", false, '', false, false, false, '#,##0.00', ExcelBuffer_gRecTmp."cell type"::Number);
    end;

    local procedure CreateExcelBook_lFnc()
    begin
        ExcelBuffer_gRecTmp.CreateNewBook('GST EXP');
        ExcelBuffer_gRecTmp.WriteSheet('Data', CompanyName(), UserId());
        ExcelBuffer_gRecTmp.CloseBook();
        ExcelBuffer_gRecTmp.OpenExcel();

        // if ExcelSaveFilePath_gTxt = '' then
        //     ExcelBuffer_gRecTmp.CreateBookAndOpenExcel('', 'GST EXP', 'Data', COMPANYNAME, UserId)
        // else begin
        //     ExcelBuffer_gRecTmp.FixLocationCreateBookAndSaveExcelMailSharedFile_gFnc('GST EXP', 'Data', ExcelSaveFilePath_gTxt);
        // end;
    end;


    procedure SetFixLocationExcelExport_gFnc(ExcelSaveFilePath_iTxt: Text)
    begin
        ExportToExcel_gBln := true;
        ExcelSaveFilePath_gTxt := ExcelSaveFilePath_iTxt;
    end;

    procedure SetJustFillData_gFnc(Month_iInt: Integer; Year_iInt: Integer; GSTRegNo_iCod: Text; JustFillData_iBln: Boolean)
    begin
        Month_gInt := Month_iInt;
        Year_gInt := Year_iInt;
        GSTRegNo_gCod := GSTRegNo_iCod;
        JustFillData_gBln := JustFillData_iBln;
    end;
}

