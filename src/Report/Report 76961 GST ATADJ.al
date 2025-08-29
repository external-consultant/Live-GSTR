Report 76961 "GST ATADJ"
{

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
                OrignalGSTDetail_lRec: Record "Detailed GST Ledger Entry";
                DocumentNo_lTxt: Text;
            begin
                CurrRec_gInt += 1;
                if SetOutPutFile_gTxt = '' then
                    Win.Update(2, CurrRec_gInt);

                ConsiderEntry_lBln := false;
                GSTAdjAmt_gDec := 0;

                if ("Document Type" = "document type"::Invoice) and ("Entry Type" = "entry type"::Application) then
                    ConsiderEntry_lBln := true;

                if "GST Component Code" = 'KFLOODCESS' then
                    CurrReport.Skip();

                if ("Document Type" = "document type"::Refund) and ("Entry Type" = "entry type"::"Initial Entry") then
                    ConsiderEntry_lBln := true;

                if not ConsiderEntry_lBln then
                    CurrReport.Skip;

                //Advance Customer Payment
                Clear(PlaceOfSupply_gTxt);
                PlaceOfSupply_gTxt := GSTRCommonFunction_gCdu.GSTRPlaceOfSupply_gFnc("Detailed GST Ledger Entry");

                //Check the Orignal Advance Payment date should be receive in earlier accouting period
                DocumentNo_lTxt := FindAppCust_lFnc("Detailed GST Ledger Entry");
                //Find Adavnce Payment and Apply  -NJ
                OrignalGSTDetail_lRec.Reset;
                OrignalGSTDetail_lRec.SetRange("Entry Type", OrignalGSTDetail_lRec."entry type"::"Initial Entry");
                // OrignalGSTDetail_lRec.SetRange("Document No.", "Original Doc. No.");
                OrignalGSTDetail_lRec.SetFilter("Document No.", DocumentNo_lTxt);
                OrignalGSTDetail_lRec.SetFilter("Posting Date", '<%1', SD_gDte);
                OrignalGSTDetail_lRec.SetRange("GST on Advance Payment", true);
                if not OrignalGSTDetail_lRec.FindFirst then
                    CurrReport.Skip;

                DataExport_lBln := true;

                GSTAdjAmt_gDec := Abs("GST Base Amount");
                PostedSalesInvocie_gFnc("Detailed GST Ledger Entry");

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
                SETRANGE("Entry Type", "Entry Type"::Application);
                SetRange("Transaction Type", "transaction type"::Sales);
                SETRANGE("Document Type", "Document Type"::Invoice);
                SetRange("Payment Type", "payment type"::Advance);
                // SetRange("Original Doc. Type", "original doc. type"::Payment);
                // SetFilter("Original Doc. No.", '<>%1', '');
                SetRange("Posting Date", SD_gDte, ED_gDte);
                SetFilter("GST Component Code", '<>%1', 'SGST');  //Only CGST Line consider for export data

                CurrRec_gInt := 0;
                TempCnt_lInt := Count;
                if SetOutPutFile_gTxt = '' then
                    Win.Update(1, Count);

                GSTATADJ_gRec.Reset;
                GSTATADJ_gRec.SetCurrentkey("GST Month", "GST Year");
                GSTATADJ_gRec.SetRange("GST Month", Month_gInt);
                GSTATADJ_gRec.SetRange("GST Year", Year_gInt);
                GSTATADJ_gRec.SetRange("GST Registration No.", GSTRegNo_gCod);
                GSTATADJ_gRec.DeleteAll;


                // GSTRCal_lRec.RESET;
                // GSTRCal_lRec.DELETEALL(TRUE);


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
        GSTATAJ_lXml: XmlPort "GST - ATADJ Export";
        GSTATADJ_lRec: Record "GST ATADJ";
        OutputFile_lFile: File;
        OutStream_lOST: OutStream;
        TempBlob_lCdu: Codeunit "Temp Blob";
        SetOutPutFile_Instr: Instream;
    begin
        if SetOutPutFile_gTxt = '' then
            Win.Close;

        Commit;

        if not JustFillData_gBln then begin
            GSTATADJ_lRec.Reset;
            GSTATADJ_lRec.SetRange("GST Month", Month_gInt);
            GSTATADJ_lRec.SetRange("GST Year", Year_gInt);
            GSTATADJ_lRec.SetRange("GST Registration No.", GSTRegNo_gCod);
            if ExportToExcel_gBln then begin
                MakeExcelDataInfo_lFnc;
                if GSTATADJ_lRec.FindSet then begin
                    DataExported_gBln := true;
                    if ExcelSaveFilePath_gTxt <> '' then
                        MakeExcelDataHeader_lFnc;
                    repeat
                        MakeExcelDataBody_lFnc(GSTATADJ_lRec);
                    until GSTATADJ_lRec.Next = 0;
                end;
                CreateExcelBook_lFnc;
            end else begin
                Clear(GSTATAJ_lXml);
                GSTATAJ_lXml.SetTableview(GSTATADJ_lRec);

                if SetOutPutFile_gTxt = '' then begin
                    GSTATAJ_lXml.Run;
                end else begin
                    if GSTATADJ_lRec.IsEmpty then
                        CurrReport.Break;
                    // OutputFile_lFile.Create(SetOutPutFile_gTxt);
                    // OutputFile_lFile.CreateOutstream(OutStream_lOST);                

                    Clear(TempBlob_lCdu);
                    TempBlob_lCdu.CreateInStream(SetOutPutFile_Instr);
                    SetOutPutFile_Instr.ReadText(SetOutPutFile_gTxt);
                    CopyStream(OutStream_lOST, SetOutPutFile_Instr);

                    GSTATAJ_lXml.HideWinDialog_gFnc;
                    GSTATAJ_lXml.SetDestination(OutStream_lOST);
                    GSTATAJ_lXml.Export;
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
        GSTATADJ_gRec: Record "GST ATADJ";
        GSTRCommonFunction_gCdu: Codeunit "GSTR Common Function";
        PlaceOfSupply_gTxt: Text;
        GSTAdjAmt_gDec: Decimal;
        SetOutPutFile_gTxt: Text[250];
        DataExported_gBln: Boolean;
        ExportToExcel_gBln: Boolean;
        ExcelBuffer_gRecTmp: Record "Excel Buffer" temporary;
        ExcelSaveFilePath_gTxt: Text;
        JustFillData_gBln: Boolean;
        CreateCustLedgEntry: Record "Cust. Ledger Entry";

    local procedure PostedSalesInvocie_gFnc(DetailedGSTLedgerEntry_iRec: Record "Detailed GST Ledger Entry")
    var
        GSTATADJ_lRec: Record "GST ATADJ";
    begin
        if DetailedGSTLedgerEntry_iRec."GST Component Code" = 'CGST' then
            DetailedGSTLedgerEntry_iRec."GST %" := DetailedGSTLedgerEntry_iRec."GST %" * 2;

        GSTATADJ_lRec.Reset;
        GSTATADJ_lRec.SetCurrentkey("Place of Supply", Rate);
        GSTATADJ_lRec.SetRange("GST Month", Month_gInt);
        GSTATADJ_lRec.SetRange("GST Year", Year_gInt);
        GSTATADJ_lRec.SetRange("GST Registration No.", DetailedGSTLedgerEntry_iRec."Location  Reg. No.");
        GSTATADJ_lRec.SetRange("Place of Supply", PlaceOfSupply_gTxt);
        GSTATADJ_lRec.SetRange(Rate, DetailedGSTLedgerEntry_iRec."GST %");
        if not GSTATADJ_lRec.FindFirst then begin
            GSTATADJ_lRec.Init;
            GSTATADJ_lRec."GST Month" := Month_gInt;
            GSTATADJ_lRec."GST Year" := Year_gInt;
            GSTATADJ_lRec."GST Registration No." := DetailedGSTLedgerEntry_iRec."Location  Reg. No.";
            GSTATADJ_lRec."Place of Supply" := PlaceOfSupply_gTxt;
            GSTATADJ_lRec.Rate := DetailedGSTLedgerEntry_iRec."GST %";
            GSTATADJ_lRec.Insert;
        end;

        GSTATADJ_lRec."Gross Advance Adjusted" := GSTATADJ_lRec."Gross Advance Adjusted" + GSTAdjAmt_gDec;
        GSTATADJ_lRec.Modify;



        // CLEAR(GSTRCal_lRec);
        // GSTRCal_lRec.INIT;
        // GSTRCal_lRec.TRANSFERFIELDS(DetailedGSTLedgerEntry_iRec);
        // GSTRCal_lRec."Entry No." := 0;
        // GSTRCal_lRec."GSTR Report Type" := GSTRCal_lRec."GSTR Report Type"::"8";
        // GSTRCal_lRec."GSTR Entry No." := GSTATADJ_lRec."Entry No.";
        // GSTRCal_lRec."GST Reaminig Amount AT" := GSTAdjAmt_gDec;
        // GSTRCal_lRec.INSERT;


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
        ExcelBuffer_gRecTmp.AddInfoColumn('GST ATADJ', false, false, false, false, '', ExcelBuffer_gRecTmp."cell type"::Text);
        ExcelBuffer_gRecTmp.NewRow;
        ExcelBuffer_gRecTmp.AddInfoColumn(Format(Text006), false, true, false, false, '', ExcelBuffer_gRecTmp."cell type"::Text);
        ExcelBuffer_gRecTmp.AddInfoColumn(Report::"GST ATADJ", false, false, false, false, '', ExcelBuffer_gRecTmp."cell type"::Number);
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
        ExcelBuffer_gRecTmp.AddColumn('Place Of Supply', false, '', true, false, true, '', ExcelBuffer_gRecTmp."cell type"::Text);
        ExcelBuffer_gRecTmp.AddColumn('Applicable % of Tax Rate', false, '', true, false, true, '', ExcelBuffer_gRecTmp."cell type"::Text); //NJ
        ExcelBuffer_gRecTmp.AddColumn('Rate', false, '', true, false, true, '', ExcelBuffer_gRecTmp."cell type"::Text);
        ExcelBuffer_gRecTmp.AddColumn('Gross Advance Adjusted', false, '', true, false, true, '', ExcelBuffer_gRecTmp."cell type"::Text);
        ExcelBuffer_gRecTmp.AddColumn('Cess Amount', false, '', true, false, true, '', ExcelBuffer_gRecTmp."cell type"::Text);
    end;

    local procedure MakeExcelDataBody_lFnc(GSTATADJ_iRec: Record "GST ATADJ")
    var
        BankAcc_lRec: Record "Bank Account";
        Vendor_lRec: Record Vendor;
        Customer_lRec: Record Customer;
        FixedAsset_lRec: Record "Fixed Asset";
        AmtDrLCY_lDec: Decimal;
        AmtCrLCY_lDec: Decimal;
    begin
        ExcelBuffer_gRecTmp.NewRow;
        ExcelBuffer_gRecTmp.AddColumn(GSTATADJ_iRec."Place of Supply", false, '', false, false, false, '', ExcelBuffer_gRecTmp."cell type"::Text);
        ExcelBuffer_gRecTmp.AddColumn('', false, '', false, false, false, '', ExcelBuffer_gRecTmp."cell type"::Text);  //NJ
        ExcelBuffer_gRecTmp.AddColumn(GSTATADJ_iRec.Rate, false, '', false, false, false, '#,##0.00', ExcelBuffer_gRecTmp."cell type"::Number);
        ExcelBuffer_gRecTmp.AddColumn(GSTATADJ_iRec."Gross Advance Adjusted", false, '', false, false, false, '#,##0.00', ExcelBuffer_gRecTmp."cell type"::Number);
        ExcelBuffer_gRecTmp.AddColumn(GSTATADJ_iRec."Cess Amount", false, '', false, false, false, '#,##0.00', ExcelBuffer_gRecTmp."cell type"::Number);
    end;

    local procedure CreateExcelBook_lFnc()
    begin
        ExcelBuffer_gRecTmp.CreateNewBook('GST ATADJ');
        ExcelBuffer_gRecTmp.WriteSheet('Data', CompanyName(), UserId());
        ExcelBuffer_gRecTmp.CloseBook();
        ExcelBuffer_gRecTmp.OpenExcel();


        // if ExcelSaveFilePath_gTxt = '' then
        //     ExcelBuffer_gRecTmp.CreateBookAndOpenExcel('', 'GST ATADJ', 'Data', COMPANYNAME, UserId)
        // else begin
        //     ExcelBuffer_gRecTmp.FixLocationCreateBookAndSaveExcelMailSharedFile_gFnc('GST ATADJ', 'Data', ExcelSaveFilePath_gTxt);
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

    local procedure FindAppCust_lFnc(var DetailedGSTledEntry_iRec: Record "Detailed GST Ledger Entry"): Text
    var
        EntryNo_lInt: Integer;
        CLE_lRec: Record "Cust. Ledger Entry";
        SerachCustLedEntry_gRec: Record "Cust. Ledger Entry";
        DtldGSTLedgEntry_lRec: Record "Detailed GST Ledger Entry";
        DocumentNo_lTxt: Text;
    begin
        DocumentNo_lTxt := '';

        SerachCustLedEntry_gRec.Reset();
        SerachCustLedEntry_gRec.SetRange("Document No.", DetailedGSTledEntry_iRec."Document No.");
        SerachCustLedEntry_gRec.SetRange("Posting Date", DetailedGSTledEntry_iRec."Posting Date");
        if SerachCustLedEntry_gRec.FindFirst() then;

        CLEAR(CreateCustLedgEntry);
        IF SerachCustLedEntry_gRec."Entry No." <> 0 THEN BEGIN
            CreateCustLedgEntry := SerachCustLedEntry_gRec;

            FindApplnEntriesDtldtLedgEntry(SerachCustLedEntry_gRec);
            CLE_lRec.SETCURRENTKEY("Entry No.");
            CLE_lRec.SETRANGE("Entry No.");

            IF CreateCustLedgEntry."Closed by Entry No." <> 0 THEN BEGIN
                CLE_lRec."Entry No." := CreateCustLedgEntry."Closed by Entry No.";
                CLE_lRec.MARK(TRUE);
            END;

            CLE_lRec.SETCURRENTKEY("Closed by Entry No.");
            CLE_lRec.SETRANGE("Closed by Entry No.", CreateCustLedgEntry."Entry No.");
            IF CLE_lRec.FIND('-') THEN
                REPEAT
                    CLE_lRec.MARK(TRUE);
                UNTIL CLE_lRec.NEXT = 0;

            CLE_lRec.SETCURRENTKEY("Entry No.");
            CLE_lRec.SETRANGE("Closed by Entry No.");
        END;

        CLE_lRec.MARKEDONLY(TRUE);

        if CLE_lRec.FindSet() then begin
            repeat
                if CLE_lRec."Document Type" = CLE_lRec."Document Type"::Payment then begin
                    if DocumentNo_lTxt <> '' then
                        DocumentNo_lTxt := DocumentNo_lTxt + '|' + CLE_lRec."Document No."
                    else
                        DocumentNo_lTxt := CLE_lRec."Document No.";
                end;
            until CLE_lRec.Next = 0;
        end;

        exit(DocumentNo_lTxt);
    End;

    local procedure FindApplnEntriesDtldtLedgEntry(var SerachCustLedEntry_gRec: Record "Cust. Ledger Entry")
    var
        DtldCustLedgEntry1: Record "Detailed Cust. Ledg. Entry";
        DtldCustLedgEntry2: Record "Detailed Cust. Ledg. Entry";
    begin
        DtldCustLedgEntry1.SETCURRENTKEY("Cust. Ledger Entry No.");
        DtldCustLedgEntry1.SETRANGE("Cust. Ledger Entry No.", CreateCustLedgEntry."Entry No.");
        DtldCustLedgEntry1.SETRANGE(Unapplied, FALSE);
        IF DtldCustLedgEntry1.FIND('-') THEN
            REPEAT
                IF DtldCustLedgEntry1."Cust. Ledger Entry No." =
                   DtldCustLedgEntry1."Applied Cust. Ledger Entry No."
                THEN BEGIN
                    DtldCustLedgEntry2.INIT;
                    DtldCustLedgEntry2.SETCURRENTKEY("Applied Cust. Ledger Entry No.", "Entry Type");
                    DtldCustLedgEntry2.SETRANGE(
                      "Applied Cust. Ledger Entry No.", DtldCustLedgEntry1."Applied Cust. Ledger Entry No.");
                    DtldCustLedgEntry2.SETRANGE("Entry Type", DtldCustLedgEntry2."Entry Type"::Application);
                    DtldCustLedgEntry2.SETRANGE(Unapplied, FALSE);
                    IF DtldCustLedgEntry2.FIND('-') THEN
                        REPEAT
                            IF DtldCustLedgEntry2."Cust. Ledger Entry No." <>
                               DtldCustLedgEntry2."Applied Cust. Ledger Entry No."
                            THEN BEGIN
                                SerachCustLedEntry_gRec.SETCURRENTKEY("Entry No.");
                                SerachCustLedEntry_gRec.SETRANGE("Entry No.", DtldCustLedgEntry2."Cust. Ledger Entry No.");
                                IF SerachCustLedEntry_gRec.FIND('-') THEN
                                    SerachCustLedEntry_gRec.MARK(TRUE);
                            END;
                        UNTIL DtldCustLedgEntry2.NEXT = 0;
                END ELSE BEGIN
                    SerachCustLedEntry_gRec.SETCURRENTKEY("Entry No.");
                    SerachCustLedEntry_gRec.SETRANGE("Entry No.", DtldCustLedgEntry1."Applied Cust. Ledger Entry No.");
                    IF SerachCustLedEntry_gRec.FIND('-') THEN
                        SerachCustLedEntry_gRec.MARK(TRUE);
                END;
            UNTIL DtldCustLedgEntry1.NEXT = 0;
    End;

}

