Report 76956 "GST CDNR"
{
    Caption = 'GST CDNR';
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
                SCM_lRec: Record "Sales Cr.Memo Header";
                SCML_lRec: Record "Sales Cr.Memo Line";
                SerCrMemo_lRec: Record "Service Cr.Memo Header";
                DataExport_lBln: Boolean;
                GSTSetup_lRec: Record "GST Setup";
                Customer_lRec: Record Customer;
                ShiptoAddress_lRec: Record "Ship-to Address";
            begin
                CurrRec_gInt += 1;
                if SetOutPutFile_gTxt = '' then
                    Win.Update(2, CurrRec_gInt);
                SEZGSTNNo_gCod := '';
                SEZGSTPerc_gDec := 0;
                SEZGSTAMT_gDec := 0;

                ConsiderEntry_lBln := false;

                if not ("GST Customer Type" in ["gst customer type"::Registered, "gst customer type"::"SEZ Development", "gst customer type"::"SEZ Unit"]) then
                    CurrReport.Skip;

                if "GST Component Code" = 'KFLOODCESS' then
                    CurrReport.Skip();

                //Posted Sales & Service Invoice
                if ("Transaction Type" = "transaction type"::Sales) and ("Document Type" in ["document type"::"Credit Memo"]) then begin
                    ConsiderEntry_lBln := true;
                end;

                if not ConsiderEntry_lBln then
                    CurrReport.Skip;

                //Posted Sales & Service Invoice
                DataExport_lBln := false;
                ReasonDesc_gTxt := '';
                if SCM_lRec.Get("Document No.") then begin
                    ReasonDesc_gTxt := GSTRCommonFunction_gCdu.GetReasonDesc_gFnc(SCM_lRec."Reason Code");

                    if "GST Customer Type" in ["gst customer type"::"SEZ Development", "gst customer type"::"SEZ Unit"] then begin
                        if "GST Amount" = 0 then begin
                            // GSTSetup_lRec.Reset;
                            // GSTSetup_lRec.SetRange("GST Group Code", "GST Group Code");
                            // GSTSetup_lRec.SetRange("GST Component Code", "GST Component Code");
                            // GSTSetup_lRec.SetFilter("Effective Date", '<=%1', "Posting Date");
                            // GSTSetup_lRec.FindLast;
                            // SEZGSTPerc_gDec := GSTSetup_lRec."GST Component %";
                            // if not SCM_lRec."GST Without Payment of Duty" then
                            //     SEZGSTAMT_gDec := Abs("GST Base Amount" * GSTSetup_lRec."GST Component %" / 100);
                        end else
                            SEZGSTAMT_gDec := Abs("GST Amount");

                        SCML_lRec.Reset;
                        SCML_lRec.SetRange("Document No.", "Document No.");
                        SCML_lRec.SetFilter("GST Place of Supply", '<>%1', SCML_lRec."gst place of supply"::" ");
                        SCML_lRec.FindFirst;
                        if SCML_lRec."GST Place of Supply" = SCML_lRec."gst place of supply"::"Bill-to Address" then begin
                            Customer_lRec.Get(SCML_lRec."Bill-to Customer No.");
                            SEZGSTNNo_gCod := Customer_lRec."GST Registration No.";
                        end;
                    end;

                    PostedSalesCrMemo_gFnc("Detailed GST Ledger Entry");
                    DataExport_lBln := true;
                end;

                if not DataExport_lBln then begin
                    if SerCrMemo_lRec.Get("Document No.") then begin
                        ReasonDesc_gTxt := GSTRCommonFunction_gCdu.GetReasonDesc_gFnc(SerCrMemo_lRec."Reason Code");
                        PostedSalesCrMemo_gFnc("Detailed GST Ledger Entry");
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
                // SetRange("Nature of Supply", "nature of supply"::B2B);
                // SetFilter("GST Customer Type", '%1', "GST Customer Type"::Registered);
                Setfilter("GST Customer Type", '%1|%2|%3|%4', "GST Customer Type"::Registered, "GST Customer Type"::"Deemed Export", "GST Customer Type"::"SEZ Development", "GST Customer Type"::"SEZ Unit");
                SetRange("Transaction Type", "transaction type"::Sales);
                SetRange("Document Type", "document type"::"Credit Memo");
                SetRange("GST Exempted Goods", false);
                //SETRANGE("GST Customer Type","Detailed GST Ledger Entry"."GST Customer Type"::Registered);
                SetFilter("GST Component Code", '<>%1', 'SGST');  //Only CGST Line consider for export data

                CurrRec_gInt := 0;
                TempCnt_lInt := Count;
                if SetOutPutFile_gTxt = '' then
                    Win.Update(1, Count);

                GSTCDNR_gRec.Reset;
                GSTCDNR_gRec.SetCurrentkey("GST Month", "GST Year");
                GSTCDNR_gRec.SetRange("GST Month", Month_gInt);
                GSTCDNR_gRec.SetRange("GST Year", Year_gInt);

                GSTCDNR_gRec.SetRange("GST Registration No.", GSTRegNo_gCod);
                GSTCDNR_gRec.DeleteAll;
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
        GSTCDNR_lXml: XmlPort "GST - CDNR Export";
        GSTCDNR_lRec: Record "GST CDNR";
        OutputFile_lFile: File;
        OutStream_lOST: OutStream;
        TempBlob_lCdu: Codeunit "Temp Blob";
        SetOutPutFile_Instr: Instream;
    begin
        if SetOutPutFile_gTxt = '' then
            Win.Close;

        Commit;

        if not JustFillData_gBln then begin
            GSTCDNR_lRec.Reset;
            GSTCDNR_lRec.SetRange("GST Month", Month_gInt);
            GSTCDNR_lRec.SetRange("GST Year", Year_gInt);
            GSTCDNR_lRec.SetRange("GST Registration No.", GSTRegNo_gCod);
            if ExportToExcel_gBln then begin
                MakeExcelDataInfo_lFnc;
                if GSTCDNR_lRec.FindSet then begin
                    DataExported_gBln := true;
                    if ExcelSaveFilePath_gTxt <> '' then
                        MakeExcelDataHeader_lFnc;
                    repeat
                        MakeExcelDataBody_lFnc(GSTCDNR_lRec);
                    until GSTCDNR_lRec.Next = 0;
                end;
                CreateExcelBook_lFnc;
            end else begin
                Clear(GSTCDNR_lXml);
                GSTCDNR_lXml.SetTableview(GSTCDNR_lRec);

                if SetOutPutFile_gTxt = '' then begin
                    GSTCDNR_lXml.Run;
                end else begin
                    if GSTCDNR_lRec.IsEmpty then
                        CurrReport.Break;

                    // OutputFile_lFile.Create(SetOutPutFile_gTxt);
                    // OutputFile_lFile.CreateOutstream(OutStream_lOST);

                    Clear(TempBlob_lCdu);
                    TempBlob_lCdu.CreateInStream(SetOutPutFile_Instr);
                    SetOutPutFile_Instr.ReadText(SetOutPutFile_gTxt);
                    CopyStream(OutStream_lOST, SetOutPutFile_Instr);


                    GSTCDNR_lXml.HideWinDialog_gFnc;
                    GSTCDNR_lXml.SetDestination(OutStream_lOST);
                    GSTCDNR_lXml.Export;
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
        GSTCDNR_gRec: Record "GST CDNR";
        GSTRCommonFunction_gCdu: Codeunit "GSTR Common Function";
        ReasonDesc_gTxt: Text[100];
        SEZGSTNNo_gCod: Code[20];
        SEZGSTPerc_gDec: Decimal;
        SEZGSTAMT_gDec: Decimal;
        SetOutPutFile_gTxt: Text[250];
        DataExported_gBln: Boolean;
        ExportToExcel_gBln: Boolean;
        ExcelBuffer_gRecTmp: Record "Excel Buffer" temporary;
        JustFillData_gBln: Boolean;
        ExcelSaveFilePath_gTxt: Text;

    local procedure PostedSalesCrMemo_gFnc(DetailedGSTLedgerEntry_iRec: Record "Detailed GST Ledger Entry")
    var
        GSTCDNR_lRec: Record "GST CDNR";
        ReferenceInvoiceNo_lRec: Record "Reference Invoice No.";
        SIH_lRec: Record "Sales Invoice Header";
        SalesInvoiceHeader_lRec: Record "Sales Invoice Header";
        ServInvoiceHdr_lRec: Record "Service Invoice Header";
        TransShipHdr_lRec: Record "Transfer Shipment Header";
        SCMH_lRec: Record "Sales Cr.Memo Header";
        GSTLedgerEntry_lRec: Record "GST Ledger Entry";
    begin
        if DetailedGSTLedgerEntry_iRec."GST Component Code" = 'CGST' then
            DetailedGSTLedgerEntry_iRec."GST %" := DetailedGSTLedgerEntry_iRec."GST %" * 2;

        if DetailedGSTLedgerEntry_iRec."GST %" = 0 then
            DetailedGSTLedgerEntry_iRec."GST %" := SEZGSTPerc_gDec;

        if DetailedGSTLedgerEntry_iRec."Buyer/Seller Reg. No." = '' then
            DetailedGSTLedgerEntry_iRec."Buyer/Seller Reg. No." := SEZGSTNNo_gCod;

        GSTCDNR_lRec.Reset;
        GSTCDNR_lRec.SetCurrentkey("Note/Refund Voucher Number", Rate);
        GSTCDNR_lRec.SetRange("GST Month", Month_gInt);
        GSTCDNR_lRec.SetRange("GST Year", Year_gInt);
        GSTCDNR_lRec.SetRange("GST Registration No.", DetailedGSTLedgerEntry_iRec."Location  Reg. No.");
        GSTCDNR_lRec.SetRange("Note/Refund Voucher Number", DetailedGSTLedgerEntry_iRec."Document No.");
        GSTCDNR_lRec.SetRange(Rate, DetailedGSTLedgerEntry_iRec."GST %");
        if not GSTCDNR_lRec.FindFirst then begin
            GSTCDNR_lRec.Init;
            GSTCDNR_lRec."GST Month" := Month_gInt;
            GSTCDNR_lRec."GST Year" := Year_gInt;
            GSTCDNR_lRec."GST Registration No." := DetailedGSTLedgerEntry_iRec."Location  Reg. No.";
            GSTCDNR_lRec."GSTIN/UIN of Recipient" := DetailedGSTLedgerEntry_iRec."Buyer/Seller Reg. No.";
            GSTCDNR_lRec."Receiver Name" := GSTRCommonFunction_gCdu.GetReceiverName_gFnc(DetailedGSTLedgerEntry_iRec);

            if DetailedGSTLedgerEntry_iRec."GST Customer Type" = DetailedGSTLedgerEntry_iRec."gst customer type"::"Deemed Export" then
                GSTCDNR_lRec."Invoice Type" := GSTCDNR_lRec."Invoice Type"::"Deemed Export";

            //VG-NS 05-Jun-2018
            if DetailedGSTLedgerEntry_iRec."GST Customer Type" in [DetailedGSTLedgerEntry_iRec."gst customer type"::"SEZ Development", DetailedGSTLedgerEntry_iRec."gst customer type"::"SEZ Unit"] then begin
                if DetailedGSTLedgerEntry_iRec."GST Without Payment of Duty" then
                    GSTCDNR_lRec."Invoice Type" := GSTCDNR_lRec."Invoice Type"::"SEZ supplies without payment"
                else
                    GSTCDNR_lRec."Invoice Type" := GSTCDNR_lRec."Invoice Type"::"SEZ supplies with payment";
            end;
            //VG-NE 05-Jun-2018
            //NJ-NS
            if DetailedGSTLedgerEntry_iRec."GST Customer Type" = DetailedGSTLedgerEntry_iRec."GST Customer Type"::Registered then begin
                GSTLedgerEntry_lRec.Reset();
                GSTLedgerEntry_lRec.SetRange("Document No.", DetailedGSTLedgerEntry_iRec."Document No.");
                GSTLedgerEntry_lRec.SetRange("Posting Date", DetailedGSTLedgerEntry_iRec."Posting Date");
                GSTLedgerEntry_lRec.SetRange("POS Out Of India", True);
                if GSTLedgerEntry_lRec.FindFirst() then
                    GSTCDNR_lRec."Invoice Type" := GSTCDNR_lRec."Invoice Type"::"Intra-State supplies attracting IGST"
                else
                    GSTCDNR_lRec."Invoice Type" := GSTCDNR_lRec."Invoice Type"::Regular;
            end;

            GSTCDNR_lRec."Invoice/Advance Receipt Number" := DetailedGSTLedgerEntry_iRec."Original Invoice No.";
            // GSTCDNR_lRec."Invoice/Advance Receipt date" := DetailedGSTLedgerEntry_iRec."Original Invoice Date";
            if SalesInvoiceHeader_lRec.get(DetailedGSTLedgerEntry_iRec."Original Invoice No.") then
                GSTCDNR_lRec."Invoice/Advance Receipt date" := SalesInvoiceHeader_lRec."Posting Date"
            Else
                if ServInvoiceHdr_lRec.get(DetailedGSTLedgerEntry_iRec."Original Invoice No.") then
                    GSTCDNR_lRec."Invoice/Advance Receipt date" := ServInvoiceHdr_lRec."Posting Date"
                Else
                    if TransShipHdr_lRec.get(DetailedGSTLedgerEntry_iRec."Original Invoice No.") then
                        GSTCDNR_lRec."Invoice/Advance Receipt date" := TransShipHdr_lRec."Posting Date";

            if GSTCDNR_lRec."Invoice/Advance Receipt Number" = '' then begin
                ReferenceInvoiceNo_lRec.Reset;
                ReferenceInvoiceNo_lRec.SetRange("Document No.", DetailedGSTLedgerEntry_iRec."Document No.");
                if ReferenceInvoiceNo_lRec.FindFirst then begin
                    GSTCDNR_lRec."Invoice/Advance Receipt Number" := ReferenceInvoiceNo_lRec."Reference Invoice Nos.";

                    if SIH_lRec.Get(GSTCDNR_lRec."Invoice/Advance Receipt Number") then begin
                        GSTCDNR_lRec."Invoice/Advance Receipt date" := SIH_lRec."Posting Date";
                    end else
                        if SCMH_lRec.Get(GSTCDNR_lRec."Invoice/Advance Receipt Number") then begin
                            GSTCDNR_lRec."Invoice/Advance Receipt date" := SCMH_lRec."Posting Date";
                        end;

                end;
            end;

            GSTCDNR_lRec."Note/Refund Voucher Number" := DetailedGSTLedgerEntry_iRec."Document No.";
            GSTCDNR_lRec."Note/Refund Voucher date" := DetailedGSTLedgerEntry_iRec."Posting Date";
            GSTCDNR_lRec."Document Type" := GSTCDNR_lRec."document type"::C;
            GSTCDNR_lRec."Reason For Issuing document" := ReasonDesc_gTxt;
            GSTCDNR_lRec."Note/Refund Voucher Value" := GSTRCommonFunction_gCdu.FindInvoiceValue_gFnc(DetailedGSTLedgerEntry_iRec);
            GSTCDNR_lRec."Place Of Supply" := GSTRCommonFunction_gCdu.GSTRPlaceOfSupply_gFnc(DetailedGSTLedgerEntry_iRec);
            if SEZGSTNNo_gCod <> '' then
                GSTCDNR_lRec."Place Of Supply" := GSTRCommonFunction_gCdu.GetPOSFromGSTN_gFnc(SEZGSTNNo_gCod);

            GSTCDNR_lRec."Pre GST" := GSTCDNR_lRec."pre gst"::N;
            GSTCDNR_lRec.Rate := DetailedGSTLedgerEntry_iRec."GST %";
            GSTCDNR_lRec.Insert;
        end;

        GSTCDNR_lRec."Taxable Value" := GSTCDNR_lRec."Taxable Value" + Abs(DetailedGSTLedgerEntry_iRec."GST Base Amount");

        if SEZGSTAMT_gDec <> 0 then
            GSTCDNR_lRec."Note/Refund Voucher Value" += SEZGSTAMT_gDec;

        GSTCDNR_lRec.Modify;
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
        ExcelBuffer_gRecTmp.AddInfoColumn('GST CDNR', false, false, false, false, '', ExcelBuffer_gRecTmp."cell type"::Text);
        ExcelBuffer_gRecTmp.NewRow;
        ExcelBuffer_gRecTmp.AddInfoColumn(Format(Text006), false, true, false, false, '', ExcelBuffer_gRecTmp."cell type"::Text);
        ExcelBuffer_gRecTmp.AddInfoColumn(Report::"GST CDNR", false, false, false, false, '', ExcelBuffer_gRecTmp."cell type"::Number);
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
        ExcelBuffer_gRecTmp.AddColumn('GSTIN/UIN of Recipient', false, '', true, false, true, '', ExcelBuffer_gRecTmp."cell type"::Text);
        ExcelBuffer_gRecTmp.AddColumn('Receiver Name', false, '', true, false, true, '', ExcelBuffer_gRecTmp."cell type"::Text);
        // ExcelBuffer_gRecTmp.AddColumn('Invoice/Advance Receipt Number', false, '', true, false, true, '', ExcelBuffer_gRecTmp."cell type"::Text);
        // ExcelBuffer_gRecTmp.AddColumn('Invoice/Advance Receipt Date', false, '', true, false, true, '', ExcelBuffer_gRecTmp."cell type"::Text);
        ExcelBuffer_gRecTmp.AddColumn('Note/Refund Voucher Number', false, '', true, false, true, '', ExcelBuffer_gRecTmp."cell type"::Text);
        ExcelBuffer_gRecTmp.AddColumn('Note/Refund Voucher date', false, '', true, false, true, '', ExcelBuffer_gRecTmp."cell type"::Text);
        ExcelBuffer_gRecTmp.AddColumn('Document Type', false, '', true, false, true, '', ExcelBuffer_gRecTmp."cell type"::Text);
        // ExcelBuffer_gRecTmp.AddColumn('Reason For Issuing document', false, '', true, false, true, '', ExcelBuffer_gRecTmp."cell type"::Text);
        ExcelBuffer_gRecTmp.AddColumn('Place Of Supply', false, '', true, false, true, '', ExcelBuffer_gRecTmp."cell type"::Text);
        ExcelBuffer_gRecTmp.AddColumn('Reverse Charge', false, '', true, false, true, '', ExcelBuffer_gRecTmp."cell type"::Text);
        ExcelBuffer_gRecTmp.AddColumn('Note Supply Type', false, '', true, false, true, '', ExcelBuffer_gRecTmp."cell type"::Text);
        ExcelBuffer_gRecTmp.AddColumn('Note Value', false, '', true, false, true, '', ExcelBuffer_gRecTmp."cell type"::Text);
        ExcelBuffer_gRecTmp.AddColumn('Applicable % of Tax Rate', false, '', true, false, true, '', ExcelBuffer_gRecTmp."cell type"::Text); //NJ
        ExcelBuffer_gRecTmp.AddColumn('Rate', false, '', true, false, true, '', ExcelBuffer_gRecTmp."cell type"::Text);
        ExcelBuffer_gRecTmp.AddColumn('Taxable Value', false, '', true, false, true, '', ExcelBuffer_gRecTmp."cell type"::Text);
        ExcelBuffer_gRecTmp.AddColumn('Cess Amount', false, '', true, false, true, '', ExcelBuffer_gRecTmp."cell type"::Text);
        // ExcelBuffer_gRecTmp.AddColumn('Pre GST', false, '', true, false, true, '', ExcelBuffer_gRecTmp."cell type"::Text);
    end;

    local procedure MakeExcelDataBody_lFnc(GSTCDNR_iRec: Record "GST CDNR")
    var
        BankAcc_lRec: Record "Bank Account";
        Vendor_lRec: Record Vendor;
        Customer_lRec: Record Customer;
        FixedAsset_lRec: Record "Fixed Asset";
        AmtDrLCY_lDec: Decimal;
        AmtCrLCY_lDec: Decimal;
    begin
        ExcelBuffer_gRecTmp.NewRow;
        ExcelBuffer_gRecTmp.AddColumn(GSTCDNR_iRec."GSTIN/UIN of Recipient", false, '', false, false, false, '', ExcelBuffer_gRecTmp."cell type"::Text);
        ExcelBuffer_gRecTmp.AddColumn(GSTCDNR_iRec."Receiver Name", false, '', false, false, false, '', ExcelBuffer_gRecTmp."cell type"::Text);
        // ExcelBuffer_gRecTmp.AddColumn(GSTCDNR_iRec."Invoice/Advance Receipt Number", false, '', false, false, false, '', ExcelBuffer_gRecTmp."cell type"::Text);
        // ExcelBuffer_gRecTmp.AddColumn(GSTCDNR_iRec."Invoice/Advance Receipt date", false, '', false, false, false, '', ExcelBuffer_gRecTmp."cell type"::Date);
        ExcelBuffer_gRecTmp.AddColumn(GSTCDNR_iRec."Note/Refund Voucher Number", false, '', false, false, false, '', ExcelBuffer_gRecTmp."cell type"::Text);
        ExcelBuffer_gRecTmp.AddColumn(GSTCDNR_iRec."Note/Refund Voucher date", false, '', false, false, false, '', ExcelBuffer_gRecTmp."cell type"::Date);
        ExcelBuffer_gRecTmp.AddColumn(Format(GSTCDNR_iRec."Document Type"), false, '', false, false, false, '', ExcelBuffer_gRecTmp."cell type"::Text);
        // ExcelBuffer_gRecTmp.AddColumn(GSTCDNR_iRec."Reason For Issuing document", false, '', false, false, false, '', ExcelBuffer_gRecTmp."cell type"::Text);
        ExcelBuffer_gRecTmp.AddColumn(GSTCDNR_iRec."Place Of Supply", false, '', false, false, false, '', ExcelBuffer_gRecTmp."cell type"::Text);
        ExcelBuffer_gRecTmp.AddColumn('N', false, '', false, false, false, '', ExcelBuffer_gRecTmp."cell type"::Text); //NJ
        ExcelBuffer_gRecTmp.AddColumn(Format(GSTCDNR_iRec."Invoice Type"), false, '', false, false, false, '', ExcelBuffer_gRecTmp."cell type"::Text); //NJ
        ExcelBuffer_gRecTmp.AddColumn(GSTCDNR_iRec."Note/Refund Voucher Value", false, '#,##0.00', false, false, false, '', ExcelBuffer_gRecTmp."cell type"::Number);
        ExcelBuffer_gRecTmp.AddColumn('', false, '', false, false, false, '', ExcelBuffer_gRecTmp."cell type"::Text); //NJ
        ExcelBuffer_gRecTmp.AddColumn(GSTCDNR_iRec.Rate, false, '', false, false, false, '#,##0.00', ExcelBuffer_gRecTmp."cell type"::Number);
        ExcelBuffer_gRecTmp.AddColumn(GSTCDNR_iRec."Taxable Value", false, '', false, false, false, '#,##0.00', ExcelBuffer_gRecTmp."cell type"::Number);
        ExcelBuffer_gRecTmp.AddColumn(GSTCDNR_iRec."Cess Amount", false, '', false, false, false, '#,##0.00', ExcelBuffer_gRecTmp."cell type"::Number);
        // ExcelBuffer_gRecTmp.AddColumn(Format(GSTCDNR_iRec."Pre GST"), false, '', false, false, false, '', ExcelBuffer_gRecTmp."cell type"::Text);
    end;

    local procedure CreateExcelBook_lFnc()
    begin
        ExcelBuffer_gRecTmp.CreateNewBook('GST CDNR');
        ExcelBuffer_gRecTmp.WriteSheet('Data', CompanyName(), UserId());
        ExcelBuffer_gRecTmp.CloseBook();
        ExcelBuffer_gRecTmp.OpenExcel();

        // if ExcelSaveFilePath_gTxt = '' then
        //     ExcelBuffer_gRecTmp.CreateBookAndOpenExcel('', 'GST CDNR', 'Data', COMPANYNAME, UserId)
        // else begin
        //     ExcelBuffer_gRecTmp.FixLocationCreateBookAndSaveExcelMailSharedFile_gFnc('GST CDNR', 'Data', ExcelSaveFilePath_gTxt);
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

