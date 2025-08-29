Report 76968 "GSTB2B Recon Report"
{
    Caption = 'GSTB2B Reconciliation Report';
    ProcessingOnly = true;

    dataset
    {
        dataitem("Detailed GST Ledger Entry"; "Detailed GST Ledger Entry")
        {
            DataItemTableView = sorting("Entry No.") order(ascending) where("Transaction Type" = const(Purchase), "Document Type" = const(Invoice));
            RequestFilterFields = "Document No.", "Buyer/Seller Reg. No.";
            column(ReportForNavId_33027920; 33027920)
            {
            }

            trigger OnAfterGetRecord()
            var
                PurchInvHeader_lRec: Record "Purch. Inv. Header";
                PurchCrMemoHdr_lRec: Record "Purch. Cr. Memo Hdr.";
            begin

                VendorNo_gCode := '';
                VendorName_gTxt := '';
                DocDate_gDte := 0D;
                if PurchInvHeader_lRec.Get("Document No.") then begin
                    if Pending_gBln then begin
                        if PurchInvHeader_lRec."GSTR-1/IFF/GSTR-5 Period" <> '' then
                            CurrReport.Skip;
                    end else begin
                        if PurchInvHeader_lRec."GSTR-1/IFF/GSTR-5 Period" = '' then
                            CurrReport.Skip;
                    end;

                    VendorNo_gCode := PurchInvHeader_lRec."Buy-from Vendor No.";
                    VendorName_gTxt := PurchInvHeader_lRec."Buy-from Vendor Name";
                    DocDate_gDte := PurchInvHeader_lRec."Document Date";
                end else
                    if PurchCrMemoHdr_lRec.Get("Document No.") then begin
                        if Pending_gBln then begin
                            if PurchCrMemoHdr_lRec."GSTR-1/IFF/GSTR-5 Period" <> '' then
                                CurrReport.Skip;
                        end else begin
                            if PurchCrMemoHdr_lRec."GSTR-1/IFF/GSTR-5 Period" = '' then
                                CurrReport.Skip;
                        end;
                        VendorNo_gCode := PurchCrMemoHdr_lRec."Buy-from Vendor No.";
                        VendorName_gTxt := PurchCrMemoHdr_lRec."Buy-from Vendor Name";
                        DocDate_gDte := PurchCrMemoHdr_lRec."Document Date";
                    end else
                        CurrReport.Skip;

                EntryNo_gInt += 1;
                if ExportToExcel_gBln then
                    MakeExcelDataBody_lFnc;
            end;

            trigger OnPreDataItem()
            begin
                CurrCnt_gInt := 0;
                Window_gDlg.Open('Total No of Items #1##############\' + 'Current Count #2##############');

                if ExportToExcel_gBln then
                    MakeExcelDataInfo_lFnc;



                EntryNo_gInt := 0;
            end;
        }
    }

    requestpage
    {

        layout
        {
            area(content)
            {
                field(Pending; Pending_gBln)
                {
                    ApplicationArea = Basic;
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
    begin
        Window_gDlg.Close;

        if ExportToExcel_gBln then
            CreateExcelBook_lFnc;
    end;

    trigger OnPreReport()
    begin
        ExportToExcel_gBln := true;
    end;

    var
        ExcelBuffer_gRecTmp: Record "Excel Buffer" temporary;
        Text005: label 'Company Name';
        Text006: label 'Report No.';
        Text007: label 'Report Name';
        Text008: label 'User ID';
        Text009: label 'Date';
        Text011: label 'Export Data...\';
        Text50001_gCtx: label 'Item Ledger';
        Text50002_gCtx: label 'Please select date filer.';
        PrintVchNarration_gBln: Boolean;
        EntryNo_gInt: Integer;
        Window_gDlg: Dialog;
        ExportToExcel_gBln: Boolean;
        CurrCnt_gInt: Integer;
        Tempdate_gDate: Date;
        SendEmil_gBln: Boolean;
        ExportExcelPath_gTxt: Text;
        Pending_gBln: Boolean;
        VendorNo_gCode: Code[20];
        VendorName_gTxt: Text[100];
        DocDate_gDte: Date;

    local procedure MakeExcelDataInfo_lFnc()
    begin
        ExcelBuffer_gRecTmp.SetUseInfoSheet;
        ExcelBuffer_gRecTmp.AddInfoColumn(Format(Text005), false, true, false, false, '', ExcelBuffer_gRecTmp."cell type"::Text);
        ExcelBuffer_gRecTmp.AddInfoColumn(COMPANYNAME, false, false, false, false, '', ExcelBuffer_gRecTmp."cell type"::Text);
        ExcelBuffer_gRecTmp.NewRow;
        ExcelBuffer_gRecTmp.AddInfoColumn(Format(Text007), false, true, false, false, '', ExcelBuffer_gRecTmp."cell type"::Text);
        ExcelBuffer_gRecTmp.AddInfoColumn(Format(Text50001_gCtx), false, false, false, false, '', ExcelBuffer_gRecTmp."cell type"::Text);
        ExcelBuffer_gRecTmp.NewRow;
        ExcelBuffer_gRecTmp.AddInfoColumn(Format(Text006), false, true, false, false, '', ExcelBuffer_gRecTmp."cell type"::Text);
        ExcelBuffer_gRecTmp.AddInfoColumn(Report::"GSTB2B Recon Report", false, false, false, false, '', ExcelBuffer_gRecTmp."cell type"::Number);
        ExcelBuffer_gRecTmp.NewRow;
        ExcelBuffer_gRecTmp.AddInfoColumn(Format(Text008), false, true, false, false, '', ExcelBuffer_gRecTmp."cell type"::Text);
        ExcelBuffer_gRecTmp.AddInfoColumn(UserId, false, false, false, false, '', ExcelBuffer_gRecTmp."cell type"::Text);
        ExcelBuffer_gRecTmp.NewRow;
        ExcelBuffer_gRecTmp.AddInfoColumn(Format(Text009), false, true, false, false, '', ExcelBuffer_gRecTmp."cell type"::Text);
        ExcelBuffer_gRecTmp.AddInfoColumn(Today, false, false, false, false, '', ExcelBuffer_gRecTmp."cell type"::Date);
        ExcelBuffer_gRecTmp.NewRow;
        ExcelBuffer_gRecTmp.AddInfoColumn('Filters', false, true, false, false, '', ExcelBuffer_gRecTmp."cell type"::Text);
        ExcelBuffer_gRecTmp.AddInfoColumn("Detailed GST Ledger Entry".GetFilters, false, false, false, false, '', ExcelBuffer_gRecTmp."cell type"::Text);

        ExcelBuffer_gRecTmp.ClearNewRow;
        MakeExcelDataHeader_lFnc;
    end;

    local procedure MakeExcelDataHeader_lFnc()
    begin
        ExcelBuffer_gRecTmp.NewRow;
        ExcelBuffer_gRecTmp.AddColumn('Vendor GST Reg. No.', false, '', true, false, true, '', ExcelBuffer_gRecTmp."cell type"::Text);
        ExcelBuffer_gRecTmp.AddColumn('Document No.', false, '', true, false, true, '', ExcelBuffer_gRecTmp."cell type"::Text);
        ExcelBuffer_gRecTmp.AddColumn('Posting Date', false, '', true, false, true, '', ExcelBuffer_gRecTmp."cell type"::Text);
        ExcelBuffer_gRecTmp.AddColumn('Vendor Code', false, '', true, false, true, '', ExcelBuffer_gRecTmp."cell type"::Text);
        ExcelBuffer_gRecTmp.AddColumn('Vendor Name', false, '', true, false, true, '', ExcelBuffer_gRecTmp."cell type"::Text);
        ExcelBuffer_gRecTmp.AddColumn('Vendor Invoice No', false, '', true, false, true, '', ExcelBuffer_gRecTmp."cell type"::Text);
        ExcelBuffer_gRecTmp.AddColumn('Vendor Invoice Date', false, '', true, false, true, '', ExcelBuffer_gRecTmp."cell type"::Text);
        ExcelBuffer_gRecTmp.AddColumn('Total GST Base Amount', false, '', true, false, true, '', ExcelBuffer_gRecTmp."cell type"::Text);
        ExcelBuffer_gRecTmp.AddColumn('Total GST Amount', false, '', true, false, true, '', ExcelBuffer_gRecTmp."cell type"::Text);
        ExcelBuffer_gRecTmp.AddColumn('Total Invoice Amount', false, '', true, false, true, '', ExcelBuffer_gRecTmp."cell type"::Text);
    end;

    local procedure MakeExcelDataBody_lFnc()
    var
        PurchInvHeader_lRec: Record "Purch. Inv. Header";
    begin
        ExcelBuffer_gRecTmp.NewRow;

        PurchInvHeader_lRec.Get("Detailed GST Ledger Entry"."Document No.");

        ExcelBuffer_gRecTmp.AddColumn("Detailed GST Ledger Entry"."Buyer/Seller Reg. No.", false, '', false, false, false, '', ExcelBuffer_gRecTmp."cell type"::Text);   //Entry No.
        ExcelBuffer_gRecTmp.AddColumn("Detailed GST Ledger Entry"."Document No.", false, '', false, false, false, '', ExcelBuffer_gRecTmp."cell type"::Text);            //Item No
        ExcelBuffer_gRecTmp.AddColumn("Detailed GST Ledger Entry"."Posting Date", false, '', false, false, false, '', ExcelBuffer_gRecTmp."cell type"::Date);           //Description
        ExcelBuffer_gRecTmp.AddColumn(VendorNo_gCode, false, '', false, false, false, '', ExcelBuffer_gRecTmp."cell type"::Text);            //Location Code
        ExcelBuffer_gRecTmp.AddColumn(VendorName_gTxt, false, '', false, false, false, '', ExcelBuffer_gRecTmp."cell type"::Text);            //Location Code
        ExcelBuffer_gRecTmp.AddColumn("Detailed GST Ledger Entry"."External Document No.", false, '', false, false, false, '', ExcelBuffer_gRecTmp."cell type"::Text);            //Location Code
        ExcelBuffer_gRecTmp.AddColumn(DocDate_gDte, false, '', false, false, false, '', ExcelBuffer_gRecTmp."cell type"::Date);               //Expration Date
        ExcelBuffer_gRecTmp.AddColumn("Detailed GST Ledger Entry"."GST Base Amount", false, '', false, false, false, '', ExcelBuffer_gRecTmp."cell type"::Text);   //Cost  Actual
        ExcelBuffer_gRecTmp.AddColumn("Detailed GST Ledger Entry"."GST Amount", false, '', false, false, false, '', ExcelBuffer_gRecTmp."cell type"::Text);   //Cost Expected
        ExcelBuffer_gRecTmp.AddColumn("Detailed GST Ledger Entry"."Amount Loaded on Item", false, '', false, false, false, '', ExcelBuffer_gRecTmp."cell type"::Text);   //Cost Expected
    end;

    local procedure CreateExcelBook_lFnc()
    begin
        if EntryNo_gInt = 0 then
            exit;

        // ExcelBuffer_gRecTmp.CreateBookAndOpenExcel('', Text50001_gCtx, 'Data', COMPANYNAME, UserId);
        ExcelBuffer_gRecTmp.CreateNewBook(Text50001_gCtx);
        ExcelBuffer_gRecTmp.WriteSheet(Text50001_gCtx, CompanyName(), UserId());
        ExcelBuffer_gRecTmp.CloseBook();
        ExcelBuffer_gRecTmp.OpenExcel();
    end;


    procedure SetMail_gFnc()
    begin
        SendEmil_gBln := true;
    end;


    procedure GetFilePath_gFnc(): Text
    begin
        exit(ExportExcelPath_gTxt)
    end;
}

