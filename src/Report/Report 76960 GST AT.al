Report 76960 "GST AT"
{
    Caption = 'GST AT';
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
                ReverseDetailGST_lRec: Record "Detailed GST Ledger Entry";
                AdvPayDetailGSTLedEntry_lRec: Record "Detailed GST Ledger Entry";
            begin
                RemainingPayAmount_gDec := 0;
                CurrRec_gInt += 1;
                if SetOutPutFile_gTxt = '' then
                    Win.Update(2, CurrRec_gInt);

                ConsiderEntry_lBln := false;

                if "GST Component Code" = 'KFLOODCESS' then
                    CurrReport.Skip();

                //Advance Customer Payment
                if ("Transaction Type" = "transaction type"::Sales) and ("Document Type" = "document type"::Payment) and ("GST on Advance Payment") and ("Payment Type" = "payment type"::Advance) then begin
                    ConsiderEntry_lBln := true;
                end;

                if not ConsiderEntry_lBln then
                    CurrReport.Skip;

                if Reversed then
                    CurrReport.Skip;

                //Check if Entry Reverse >>
                ReverseDetailGST_lRec.Reset;
                ReverseDetailGST_lRec.SetRange("Entry Type", ReverseDetailGST_lRec."entry type"::Application);
                ReverseDetailGST_lRec.SetRange("Document No.", "Document No.");
                ReverseDetailGST_lRec.SetRange("Posting Date", "Posting Date");
                ReverseDetailGST_lRec.SetRange(Reversed, true);
                if ReverseDetailGST_lRec.FindFirst then begin
                    CurrReport.Skip;
                end;
                //Check if Entry Reverse <<

                Clear(PlaceOfSupply_gTxt);
                PlaceOfSupply_gTxt := GSTRCommonFunction_gCdu.GSTRPlaceOfSupply_gFnc("Detailed GST Ledger Entry");

                //Posted Sales & Service Invoice
                DataExport_lBln := false;

                //**** Again Invoice ******
                //Check Amount Applied (Applied should applied in current month will not consider for GST)>>
                RemainingPayAmount_gDec := "GST Base Amount";
                // AdvPayDetailGSTLedEntry_lRec.Reset;
                // AdvPayDetailGSTLedEntry_lRec.SetRange("Entry Type", AdvPayDetailGSTLedEntry_lRec."entry type"::Application);
                // AdvPayDetailGSTLedEntry_lRec.SetRange("Transaction Type", AdvPayDetailGSTLedEntry_lRec."transaction type"::Sales);
                // AdvPayDetailGSTLedEntry_lRec.SetRange("Document Type", AdvPayDetailGSTLedEntry_lRec."document type"::Invoice);
                // AdvPayDetailGSTLedEntry_lRec.SetRange("Payment Type", AdvPayDetailGSTLedEntry_lRec."payment type"::Advance);
                // AdvPayDetailGSTLedEntry_lRec.SetRange("Original Doc. Type", AdvPayDetailGSTLedEntry_lRec."original doc. type"::Payment);
                // AdvPayDetailGSTLedEntry_lRec.SetRange("Original Doc. No.", "Document No.");
                // AdvPayDetailGSTLedEntry_lRec.SetRange("Posting Date", SD_gDte, ED_gDte);
                // AdvPayDetailGSTLedEntry_lRec.SetFilter("GST Component Code", '<>%1', 'SGST');
                // if AdvPayDetailGSTLedEntry_lRec.FindSet then begin
                //     repeat
                //         //IF AdvPayDetailGSTLedEntry_lRec."GST Base Amount" > "GST Base Amount" THEN  //SINV1718GCSD0371 on Payment Advance payment base amount more than Payment
                //         //  AdvPayDetailGSTLedEntry_lRec."GST Base Amount" := "GST Base Amount";

                //         RemainingPayAmount_gDec += AdvPayDetailGSTLedEntry_lRec."GST Base Amount";
                //     until AdvPayDetailGSTLedEntry_lRec.Next = 0;
                // end;

                //**** Again Refund ******
                //Check Amount Applied (Applied should applied in current month will not consider for GST)>>   //Check Entry No= 9007686 & 10894851
                // AdvPayDetailGSTLedEntry_lRec.Reset;
                // AdvPayDetailGSTLedEntry_lRec.SetRange("Entry Type", AdvPayDetailGSTLedEntry_lRec."entry type"::"Initial Entry");
                // AdvPayDetailGSTLedEntry_lRec.SetRange("Transaction Type", AdvPayDetailGSTLedEntry_lRec."transaction type"::Sales);
                // AdvPayDetailGSTLedEntry_lRec.SetRange("Document Type", AdvPayDetailGSTLedEntry_lRec."document type"::Refund);
                // AdvPayDetailGSTLedEntry_lRec.SetRange("Payment Type", AdvPayDetailGSTLedEntry_lRec."payment type"::Advance);
                // AdvPayDetailGSTLedEntry_lRec.SetRange("Original Doc. Type", AdvPayDetailGSTLedEntry_lRec."original doc. type"::Payment);
                // AdvPayDetailGSTLedEntry_lRec.SetRange("Original Doc. No.", "Document No.");
                // AdvPayDetailGSTLedEntry_lRec.SetRange("Posting Date", SD_gDte, ED_gDte);
                // AdvPayDetailGSTLedEntry_lRec.SetFilter("GST Component Code", '<>%1', 'SGST');
                // if AdvPayDetailGSTLedEntry_lRec.FindSet then begin
                //     repeat
                //         RemainingPayAmount_gDec += AdvPayDetailGSTLedEntry_lRec."GST Base Amount";
                //     until AdvPayDetailGSTLedEntry_lRec.Next = 0;
                // end;

                //FindApplication 
                FindAppCust_lFnc("Detailed GST Ledger Entry");


                if RemainingPayAmount_gDec = 0 then
                    CurrReport.Skip;
                //Check Amount Applied <<

                PostedSalesInvocie_gFnc("Detailed GST Ledger Entry");
                DataExport_lBln := true;

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
                SetRange("Document Type", "document type"::Payment);
                SetRange("GST on Advance Payment", true);
                SetRange("Payment Type", "payment type"::Advance);
                SetFilter("GST Component Code", '<>%1', 'SGST');  //Only CGST Line consider for export data

                CurrRec_gInt := 0;
                TempCnt_lInt := Count;
                if SetOutPutFile_gTxt = '' then
                    Win.Update(1, Count);

                GSTAT_gRec.Reset;
                GSTAT_gRec.SetCurrentkey("GST Month", "GST Year");
                GSTAT_gRec.SetRange("GST Month", Month_gInt);
                GSTAT_gRec.SetRange("GST Year", Year_gInt);
                GSTAT_gRec.SetRange("GST Registration No.", GSTRegNo_gCod);
                GSTAT_gRec.DeleteAll;


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
        GSTAT_lXml: XmlPort "GST - AT Export";
        GSTAT_lRec: Record "GST AT";
        OutputFile_lFile: File;
        OutStream_lOST: OutStream;
        SetOutPutFile_Instr: Instream;
        TempBlob_lCdu: Codeunit "Temp Blob";
    begin
        if SetOutPutFile_gTxt = '' then
            Win.Close;
        Commit;

        if not JustFillData_gBln then begin
            GSTAT_lRec.Reset;
            GSTAT_lRec.SetRange("GST Month", Month_gInt);
            GSTAT_lRec.SetRange("GST Year", Year_gInt);
            GSTAT_lRec.SetRange("GST Registration No.", GSTRegNo_gCod);
            if ExportToExcel_gBln then begin
                MakeExcelDataInfo_lFnc;
                if GSTAT_lRec.FindSet then begin
                    DataExported_gBln := true;
                    if ExcelSaveFilePath_gTxt <> '' then
                        MakeExcelDataHeader_lFnc;
                    repeat
                        MakeExcelDataBody_lFnc(GSTAT_lRec);
                    until GSTAT_lRec.Next = 0;
                end;
                CreateExcelBook_lFnc;
            end else begin
                Clear(GSTAT_lXml);
                GSTAT_lXml.SetTableview(GSTAT_lRec);

                if SetOutPutFile_gTxt = '' then begin
                    GSTAT_lXml.Run;
                end else begin
                    if GSTAT_lRec.IsEmpty then
                        CurrReport.Break;

                    // OutputFile_lFile.Create(SetOutPutFile_gTxt);
                    // OutputFile_lFile.CreateOutstream(OutStream_lOST);

                    Clear(TempBlob_lCdu);
                    TempBlob_lCdu.CreateInStream(SetOutPutFile_Instr);
                    SetOutPutFile_Instr.ReadText(SetOutPutFile_gTxt);
                    CopyStream(OutStream_lOST, SetOutPutFile_Instr);

                    GSTAT_lXml.HideWinDialog_gFnc;
                    GSTAT_lXml.SetDestination(OutStream_lOST);
                    GSTAT_lXml.Export;
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
        GSTAT_gRec: Record "GST AT";
        GSTRCommonFunction_gCdu: Codeunit "GSTR Common Function";
        PlaceOfSupply_gTxt: Text;
        RemainingPayAmount_gDec: Decimal;
        SetOutPutFile_gTxt: Text[250];
        DataExported_gBln: Boolean;
        ExportToExcel_gBln: Boolean;
        ExcelBuffer_gRecTmp: Record "Excel Buffer" temporary;
        ExcelSaveFilePath_gTxt: Text;
        CreateCustLedgEntry: Record "Cust. Ledger Entry";

        JustFillData_gBln: Boolean;


    procedure IsDataExported_gFnc(): Boolean
    begin
        exit(DataExported_gBln);
    end;

    local procedure PostedSalesInvocie_gFnc(DetailedGSTLedgerEntry_iRec: Record "Detailed GST Ledger Entry")
    var
        GSTAT_lRec: Record "GST AT";
    begin
        if DetailedGSTLedgerEntry_iRec."GST Component Code" = 'CGST' then
            DetailedGSTLedgerEntry_iRec."GST %" := DetailedGSTLedgerEntry_iRec."GST %" * 2;

        GSTAT_lRec.Reset;
        GSTAT_lRec.SetCurrentkey("Place of Supply", Rate);
        GSTAT_lRec.SetRange("GST Month", Month_gInt);
        GSTAT_lRec.SetRange("GST Year", Year_gInt);
        GSTAT_lRec.SetRange("GST Registration No.", DetailedGSTLedgerEntry_iRec."Location  Reg. No.");
        GSTAT_lRec.SetRange("Place of Supply", PlaceOfSupply_gTxt);
        GSTAT_lRec.SetRange(Rate, DetailedGSTLedgerEntry_iRec."GST %");
        if not GSTAT_lRec.FindFirst then begin
            GSTAT_lRec.Init;
            GSTAT_lRec."GST Month" := Month_gInt;
            GSTAT_lRec."GST Year" := Year_gInt;
            GSTAT_lRec."GST Registration No." := DetailedGSTLedgerEntry_iRec."Location  Reg. No.";
            GSTAT_lRec."Place of Supply" := PlaceOfSupply_gTxt;
            GSTAT_lRec.Rate := DetailedGSTLedgerEntry_iRec."GST %";
            GSTAT_lRec.Insert;
        end;

        GSTAT_lRec."Gross Advance Received" := GSTAT_lRec."Gross Advance Received" + Abs(RemainingPayAmount_gDec);
        GSTAT_lRec.Modify;





    end;


    procedure SetParameter_gFnc(Month_iInt: Integer; Year_iInt: Integer; GSTRegNo_iCod: Text; SetOutPutFile_iTxt: Text[250])
    begin
        Month_gInt := Month_iInt;
        Year_gInt := Year_iInt;
        GSTRegNo_gCod := GSTRegNo_iCod;
        SetOutPutFile_gTxt := SetOutPutFile_iTxt;
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
        ExcelBuffer_gRecTmp.AddInfoColumn('GST AT', false, false, false, false, '', ExcelBuffer_gRecTmp."cell type"::Text);
        ExcelBuffer_gRecTmp.NewRow;
        ExcelBuffer_gRecTmp.AddInfoColumn(Format(Text006), false, true, false, false, '', ExcelBuffer_gRecTmp."cell type"::Text);
        ExcelBuffer_gRecTmp.AddInfoColumn(Report::"GST AT", false, false, false, false, '', ExcelBuffer_gRecTmp."cell type"::Number);
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
        ExcelBuffer_gRecTmp.AddColumn('Gross Advance Received', false, '', true, false, true, '', ExcelBuffer_gRecTmp."cell type"::Text);
        ExcelBuffer_gRecTmp.AddColumn('Cess Amount', false, '', true, false, true, '', ExcelBuffer_gRecTmp."cell type"::Text);
    end;

    local procedure MakeExcelDataBody_lFnc(GSTAT_iRec: Record "GST AT")
    var
        BankAcc_lRec: Record "Bank Account";
        Vendor_lRec: Record Vendor;
        Customer_lRec: Record Customer;
        FixedAsset_lRec: Record "Fixed Asset";
        AmtDrLCY_lDec: Decimal;
        AmtCrLCY_lDec: Decimal;
    begin
        ExcelBuffer_gRecTmp.NewRow;
        ExcelBuffer_gRecTmp.AddColumn(GSTAT_iRec."Place of Supply", false, '', false, false, false, '', ExcelBuffer_gRecTmp."cell type"::Text);
        ExcelBuffer_gRecTmp.AddColumn('', false, '', false, false, false, '', ExcelBuffer_gRecTmp."cell type"::Text);  //NJ
        ExcelBuffer_gRecTmp.AddColumn(GSTAT_iRec.Rate, false, '', false, false, false, '#,##0.00', ExcelBuffer_gRecTmp."cell type"::Number);
        ExcelBuffer_gRecTmp.AddColumn(GSTAT_iRec."Gross Advance Received", false, '', false, false, false, '#,##0.00', ExcelBuffer_gRecTmp."cell type"::Number);
        ExcelBuffer_gRecTmp.AddColumn(GSTAT_iRec."Cess Amount", false, '', false, false, false, '#,##0.00', ExcelBuffer_gRecTmp."cell type"::Number);
    end;

    local procedure CreateExcelBook_lFnc()
    begin
        ExcelBuffer_gRecTmp.CreateNewBook('GST AT');
        ExcelBuffer_gRecTmp.WriteSheet('Data', CompanyName(), UserId());
        ExcelBuffer_gRecTmp.CloseBook();
        ExcelBuffer_gRecTmp.OpenExcel();

        // if ExcelSaveFilePath_gTxt = '' then
        //     ExcelBuffer_gRecTmp.CreateBookAndOpenExcel('', 'GST AT', 'Data', COMPANYNAME, UserId)
        // else begin
        //     ExcelBuffer_gRecTmp.FixLocationCreateBookAndSaveExcelMailSharedFile_gFnc('GST AT', 'Data', ExcelSaveFilePath_gTxt);
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

    local procedure FindAppCust_lFnc(var DetailedGSTledEntry_iRec: Record "Detailed GST Ledger Entry")
    var
        EntryNo_lInt: Integer;
        CLE_lRec: Record "Cust. Ledger Entry";
        SerachCustLedEntry_gRec: Record "Cust. Ledger Entry";
        DtldGSTLedgEntry_lRec: Record "Detailed GST Ledger Entry";
    begin

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
                if CLE_lRec."Document Type" IN [CLE_lRec."Document Type"::Invoice, CLE_lRec."Document Type"::Refund] then begin
                    if CLE_lRec."Document Type" = CLE_lRec."Document Type"::Invoice then begin
                        // DtldGSTLedgEntry_lRec
                        DtldGSTLedgEntry_lRec.Reset;
                        DtldGSTLedgEntry_lRec.SetRange("Entry Type", DtldGSTLedgEntry_lRec."entry type"::Application);
                        DtldGSTLedgEntry_lRec.SetRange("Transaction Type", DtldGSTLedgEntry_lRec."transaction type"::Sales);
                        DtldGSTLedgEntry_lRec.SetRange("Document Type", DtldGSTLedgEntry_lRec."document type"::Invoice);
                        DtldGSTLedgEntry_lRec.SetRange("Payment Type", DtldGSTLedgEntry_lRec."payment type"::Advance);
                        DtldGSTLedgEntry_lRec.SetRange("Document No.", CLE_lRec."Document No.");
                        // DtldGSTLedgEntry_lRec.SetRange("Original Doc. Type", DtldGSTLedgEntry_lRec."original doc. type"::Payment);
                        // DtldGSTLedgEntry_lRec.SetRange("Original Doc. No.", "Document No.");
                        DtldGSTLedgEntry_lRec.SetRange("Posting Date", SD_gDte, ED_gDte);
                        DtldGSTLedgEntry_lRec.SetFilter("GST Component Code", '<>%1', 'SGST');
                        if DtldGSTLedgEntry_lRec.FindSet then begin
                            repeat
                                //IF DtldGSTLedgEntry_lRec."GST Base Amount" > "GST Base Amount" THEN  //SINV1718GCSD0371 on Payment Advance payment base amount more than Payment
                                //  DtldGSTLedgEntry_lRec."GST Base Amount" := "GST Base Amount";
                                if DtldGSTLedgEntry_lRec."GST Component Code" <> 'KFLOODCESS' then
                                    RemainingPayAmount_gDec += DtldGSTLedgEntry_lRec."GST Base Amount";
                            until DtldGSTLedgEntry_lRec.Next = 0;
                        end;
                    end else
                        if CLE_lRec."Document Type" = CLE_lRec."Document Type"::Refund then begin
                            DtldGSTLedgEntry_lRec.Reset;
                            DtldGSTLedgEntry_lRec.SetRange("Entry Type", DtldGSTLedgEntry_lRec."entry type"::"Initial Entry");
                            DtldGSTLedgEntry_lRec.SetRange("Transaction Type", DtldGSTLedgEntry_lRec."transaction type"::Sales);
                            DtldGSTLedgEntry_lRec.SetRange("Document Type", DtldGSTLedgEntry_lRec."document type"::Refund);
                            DtldGSTLedgEntry_lRec.SetRange("Payment Type", DtldGSTLedgEntry_lRec."payment type"::Advance);
                            DtldGSTLedgEntry_lRec.SetRange("Document No.", CLE_lRec."Document No.");
                            // DtldGSTLedgEntry_lRec.SetRange("Original Doc. Type", DtldGSTLedgEntry_lRec."original doc. type"::Payment);
                            // DtldGSTLedgEntry_lRec.SetRange("Original Doc. No.", "Document No.");
                            DtldGSTLedgEntry_lRec.SetRange("Posting Date", SD_gDte, ED_gDte);
                            DtldGSTLedgEntry_lRec.SetFilter("GST Component Code", '<>%1', 'SGST');
                            if DtldGSTLedgEntry_lRec.FindSet then begin
                                repeat
                                    if DtldGSTLedgEntry_lRec."GST Component Code" <> 'KFLOODCESS' then
                                        RemainingPayAmount_gDec += DtldGSTLedgEntry_lRec."GST Base Amount";
                                until DtldGSTLedgEntry_lRec.Next = 0;
                            end;

                        end;

                end;
            until CLE_lRec.Next = 0;
        end;
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

