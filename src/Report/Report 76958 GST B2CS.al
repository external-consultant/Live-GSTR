Report 76958 "GST B2CS"
{
    Caption = 'GST B2CS';
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
                SCM_lRec: Record "Sales Cr.Memo Header";
            begin
                CurrRec_gInt += 1;
                if SetOutPutFile_gTxt = '' then
                    Win.Update(2, CurrRec_gInt);

                if "GST Customer Type" = "gst customer type"::Export then
                    CurrReport.Skip;

                if "GST Component Code" = 'KFLOODCESS' then
                    CurrReport.Skip();

                ConsiderEntry_lBln := false;

                //Posted Sales & Service Invoice
                if ("Transaction Type" = "transaction type"::Sales) and ("Document Type" in ["document type"::Invoice, "Document Type"::"Credit Memo"]) then begin
                    ConsiderEntry_lBln := true;
                end;

                if not ConsiderEntry_lBln then
                    CurrReport.Skip;

                Clear(PlaceOfSupply_gTxt);
                PlaceOfSupply_gTxt := GSTRCommonFunction_gCdu.GSTRPlaceOfSupply_gFnc("Detailed GST Ledger Entry");

                //Posted Sales & Service Invoice
                DataExport_lBln := false;
                if SIH_lRec.Get("Document No.") then begin
                    if "Detailed GST Ledger Entry"."GST Component Code" = 'IGST' then
                        if GSTRCommonFunction_gCdu.FindInvoiceValue_gFnc("Detailed GST Ledger Entry") > 250000 then
                            CurrReport.Skip;

                    PostedSalesInvocie_gFnc("Detailed GST Ledger Entry", False);
                    DataExport_lBln := true;
                end;

                if not DataExport_lBln then begin
                    if SerInvHdr_lRec.Get("Document No.") then begin
                        if "Detailed GST Ledger Entry"."GST Component Code" = 'IGST' then
                            if GSTRCommonFunction_gCdu.FindInvoiceValue_gFnc("Detailed GST Ledger Entry") > 250000 then
                                CurrReport.Skip;

                        PostedSalesInvocie_gFnc("Detailed GST Ledger Entry", False);
                        DataExport_lBln := true;
                    end;
                end;

                if not DataExport_lBln then begin
                    if SCM_lRec.Get("Document No.") then begin
                        if "Detailed GST Ledger Entry"."GST Component Code" = 'IGST' then
                            if GSTRCommonFunction_gCdu.FindInvoiceValueforCDNUR_gFnc("Detailed GST Ledger Entry") > 250000 then
                                CurrReport.Skip;

                        PostedSalesInvocie_gFnc("Detailed GST Ledger Entry", True);
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
                // SetRange("Nature of Supply", "nature of supply"::B2C);
                SetRange("GST Customer Type", "GST Customer Type"::Unregistered);
                SetRange("Transaction Type", "transaction type"::Sales);
                // SetRange("Document Type", "document type"::Invoice);
                SetFilter("Document Type", '%1|%2', "document type"::Invoice, "document type"::"Credit Memo");
                // SetFilter("Sales Invoice Type", '<>%1&<>%2', "sales invoice type"::Export, "sales invoice type"::"Non-GST");
                SetFilter("GST Component Code", '<>%1', 'SGST');  //Only CGST Line consider for export data
                SetRange("GST Exempted Goods", false);
                SetFilter("GST %", '<>%1', 0);

                CurrRec_gInt := 0;
                TempCnt_lInt := Count;
                if SetOutPutFile_gTxt = '' then
                    Win.Update(1, Count);

                GSTB2CS_gRec.Reset;
                GSTB2CS_gRec.SetCurrentkey("GST Month", "GST Year");
                GSTB2CS_gRec.SetRange("GST Month", Month_gInt);
                GSTB2CS_gRec.SetRange("GST Year", Year_gInt);
                GSTB2CS_gRec.SetRange("GST Registration No.", GSTRegNo_gCod);
                GSTB2CS_gRec.DeleteAll;
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
        GSTB2CS_lXml: XmlPort "GST - B2CS Export";
        GSTB2CS_lRec: Record "GST - B2CS";
        OutputFile_lFile: File;
        OutStream_lOST: OutStream;
        TempBlob_lCdu: Codeunit "Temp Blob";
        SetOutPutFile_Instr: Instream;
    begin
        if SetOutPutFile_gTxt = '' then
            Win.Close;

        Commit;

        if not JustFillData_gBln then begin

            GSTB2CS_lRec.Reset;
            GSTB2CS_lRec.SetRange("GST Month", Month_gInt);
            GSTB2CS_lRec.SetRange("GST Year", Year_gInt);
            GSTB2CS_lRec.SetRange("GST Registration No.", GSTRegNo_gCod);
            if ExportToExcel_gBln then begin
                MakeExcelDataInfo_lFnc;
                if GSTB2CS_lRec.FindSet then begin
                    DataExported_gBln := true;
                    if ExcelSaveFilePath_gTxt <> '' then
                        MakeExcelDataHeader_lFnc;
                    repeat
                        MakeExcelDataBody_lFnc(GSTB2CS_lRec);
                    until GSTB2CS_lRec.Next = 0;
                end;
                CreateExcelBook_lFnc;
            end else begin
                Clear(GSTB2CS_lXml);
                GSTB2CS_lXml.SetTableview(GSTB2CS_lRec);

                if SetOutPutFile_gTxt = '' then begin
                    GSTB2CS_lXml.Run;
                end else begin
                    if GSTB2CS_lRec.IsEmpty then
                        CurrReport.Break;

                    // OutputFile_lFile.Create(SetOutPutFile_gTxt);
                    // OutputFile_lFile.CreateOutstream(OutStream_lOST);

                    Clear(TempBlob_lCdu);
                    TempBlob_lCdu.CreateInStream(SetOutPutFile_Instr);
                    SetOutPutFile_Instr.ReadText(SetOutPutFile_gTxt);
                    CopyStream(OutStream_lOST, SetOutPutFile_Instr);


                    GSTB2CS_lXml.HideWinDialog_gFnc;
                    GSTB2CS_lXml.SetDestination(OutStream_lOST);
                    GSTB2CS_lXml.Export;
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
        GSTB2CS_gRec: Record "GST - B2CS";
        GSTRCommonFunction_gCdu: Codeunit "GSTR Common Function";
        PlaceOfSupply_gTxt: Text;
        SetOutPutFile_gTxt: Text[250];
        DataExported_gBln: Boolean;
        ExportToExcel_gBln: Boolean;
        ExcelBuffer_gRecTmp: Record "Excel Buffer" temporary;
        JustFillData_gBln: Boolean;
        ExcelSaveFilePath_gTxt: Text;

    local procedure PostedSalesInvocie_gFnc(DetailedGSTLedgerEntry_iRec: Record "Detailed GST Ledger Entry"; CreditMemo_iBln: Boolean)
    var
        GSTB2CS_lRec: Record "GST - B2CS";
    begin
        if DetailedGSTLedgerEntry_iRec."GST Component Code" = 'CGST' then
            DetailedGSTLedgerEntry_iRec."GST %" := DetailedGSTLedgerEntry_iRec."GST %" * 2;

        GSTB2CS_lRec.Reset;
        GSTB2CS_lRec.SetCurrentkey("Place of Supply", "E-Commerce GSTIN", Rate);
        GSTB2CS_lRec.SetRange("GST Month", Month_gInt);
        GSTB2CS_lRec.SetRange("GST Year", Year_gInt);
        GSTB2CS_lRec.SetRange("GST Registration No.", DetailedGSTLedgerEntry_iRec."Location  Reg. No.");
        GSTB2CS_lRec.SetRange("Place of Supply", PlaceOfSupply_gTxt);
        // GSTB2CS_lRec.SetRange("E-Commerce GSTIN", DetailedGSTLedgerEntry_iRec."e-Comm. Operator GST Reg. No.");
        GSTB2CS_lRec.SetRange(Rate, DetailedGSTLedgerEntry_iRec."GST %");
        if not GSTB2CS_lRec.FindFirst then begin
            GSTB2CS_lRec.Init;
            GSTB2CS_lRec."GST Month" := Month_gInt;
            GSTB2CS_lRec."GST Year" := Year_gInt;
            GSTB2CS_lRec."GST Registration No." := DetailedGSTLedgerEntry_iRec."Location  Reg. No.";
            // if DetailedGSTLedgerEntry_iRec."e-Comm. Operator GST Reg. No." <> '' then
            //     GSTB2CS_lRec.Type := GSTB2CS_lRec.Type::E
            // else
            GSTB2CS_lRec.Type := GSTB2CS_lRec.Type::OE;
            GSTB2CS_lRec."Place of Supply" := PlaceOfSupply_gTxt;
            // GSTB2CS_lRec."E-Commerce GSTIN" := DetailedGSTLedgerEntry_iRec."e-Comm. Operator GST Reg. No.";
            GSTB2CS_lRec.Rate := DetailedGSTLedgerEntry_iRec."GST %";
            GSTB2CS_lRec.Insert;
        end;

        if CreditMemo_iBln then
            GSTB2CS_lRec."Taxable Value" := GSTB2CS_lRec."Taxable Value" + (-1 * Abs(DetailedGSTLedgerEntry_iRec."GST Base Amount"))
        else
            GSTB2CS_lRec."Taxable Value" := GSTB2CS_lRec."Taxable Value" + Abs(DetailedGSTLedgerEntry_iRec."GST Base Amount");
        GSTB2CS_lRec.Modify;
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
        ExcelBuffer_gRecTmp.AddInfoColumn('GST B2CS', false, false, false, false, '', ExcelBuffer_gRecTmp."cell type"::Text);
        ExcelBuffer_gRecTmp.NewRow;
        ExcelBuffer_gRecTmp.AddInfoColumn(Format(Text006), false, true, false, false, '', ExcelBuffer_gRecTmp."cell type"::Text);
        ExcelBuffer_gRecTmp.AddInfoColumn(Report::"GST B2CS", false, false, false, false, '', ExcelBuffer_gRecTmp."cell type"::Number);
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
        ExcelBuffer_gRecTmp.AddColumn('Type', false, '', true, false, true, '', ExcelBuffer_gRecTmp."cell type"::Text);
        ExcelBuffer_gRecTmp.AddColumn('Place Of Supply', false, '', true, false, true, '', ExcelBuffer_gRecTmp."cell type"::Text);
        ExcelBuffer_gRecTmp.AddColumn('Applicable % of Tax Rate', false, '', true, false, true, '', ExcelBuffer_gRecTmp."cell type"::Text); //NJ
        ExcelBuffer_gRecTmp.AddColumn('Rate', false, '', true, false, true, '', ExcelBuffer_gRecTmp."cell type"::Text);
        ExcelBuffer_gRecTmp.AddColumn('Taxable Value', false, '', true, false, true, '', ExcelBuffer_gRecTmp."cell type"::Text);
        ExcelBuffer_gRecTmp.AddColumn('Cess Amount', false, '', true, false, true, '', ExcelBuffer_gRecTmp."cell type"::Text);
        ExcelBuffer_gRecTmp.AddColumn('E-Commerce GSTIN', false, '', true, false, true, '', ExcelBuffer_gRecTmp."cell type"::Text);
    end;

    local procedure MakeExcelDataBody_lFnc(GSTB2CS_iRec: Record "GST - B2CS")
    var
        BankAcc_lRec: Record "Bank Account";
        Vendor_lRec: Record Vendor;
        Customer_lRec: Record Customer;
        FixedAsset_lRec: Record "Fixed Asset";
        AmtDrLCY_lDec: Decimal;
        AmtCrLCY_lDec: Decimal;
    begin
        ExcelBuffer_gRecTmp.NewRow;
        ExcelBuffer_gRecTmp.AddColumn(Format(GSTB2CS_iRec.Type), false, '', false, false, false, '', ExcelBuffer_gRecTmp."cell type"::Text);
        ExcelBuffer_gRecTmp.AddColumn(GSTB2CS_iRec."Place of Supply", false, '', false, false, false, '', ExcelBuffer_gRecTmp."cell type"::Text);
        ExcelBuffer_gRecTmp.AddColumn('', false, '', false, false, false, '', ExcelBuffer_gRecTmp."cell type"::Text); //NJ
        ExcelBuffer_gRecTmp.AddColumn(GSTB2CS_iRec.Rate, false, '', false, false, false, '#,##0.00', ExcelBuffer_gRecTmp."cell type"::Number);
        ExcelBuffer_gRecTmp.AddColumn(GSTB2CS_iRec."Taxable Value", false, '', false, false, false, '#,##0.00', ExcelBuffer_gRecTmp."cell type"::Number);
        ExcelBuffer_gRecTmp.AddColumn(GSTB2CS_iRec."Cess Amount", false, '', false, false, false, '#,##0.00', ExcelBuffer_gRecTmp."cell type"::Number);
        ExcelBuffer_gRecTmp.AddColumn(GSTB2CS_iRec."E-Commerce GSTIN", false, '', false, false, false, '', ExcelBuffer_gRecTmp."cell type"::Text);
    end;

    local procedure CreateExcelBook_lFnc()
    begin
        ExcelBuffer_gRecTmp.CreateNewBook('GST B2CS');
        ExcelBuffer_gRecTmp.WriteSheet('Data', CompanyName(), UserId());
        ExcelBuffer_gRecTmp.CloseBook();
        ExcelBuffer_gRecTmp.OpenExcel();

        // if ExcelSaveFilePath_gTxt = '' then
        //     ExcelBuffer_gRecTmp.CreateBookAndOpenExcel('', 'GST B2CS', 'Data', COMPANYNAME, UserId)
        // else begin
        //     ExcelBuffer_gRecTmp.FixLocationCreateBookAndSaveExcelMailSharedFile_gFnc('GST B2CS', 'Data', ExcelSaveFilePath_gTxt);
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

