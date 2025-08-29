Report 76962 "GSTR EXEMP"
{
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
        GSTExemp_lXml: XmlPort "GST - EXEMP Export";
        GSTEXEMP_lRec: Record "GST EXEMP";
        OutputFile_lFile: File;
        OutStream_lOST: OutStream;
        TempBlob_lCdu: Codeunit "Temp Blob";
        SetOutPutFile_Instr: Instream;
    begin
        Commit;

        if not JustFillData_gBln then begin
            GSTEXEMP_lRec.Reset;
            GSTEXEMP_lRec.SetRange("GST Month", Month_gInt);
            GSTEXEMP_lRec.SetRange("GST Year", Year_gInt);
            GSTEXEMP_lRec.SetRange("GST Registration No.", GSTRegNo_gCod);
            if ExportToExcel_gBln then begin
                MakeExcelDataInfo_lFnc;
                if GSTEXEMP_lRec.FindSet then begin
                    DataExported_gBln := true;
                    if ExcelSaveFilePath_gTxt <> '' then
                        MakeExcelDataHdr_lFnc;
                    repeat
                        MakeExcelDataBody_lFnc(GSTEXEMP_lRec);
                    until GSTEXEMP_lRec.Next = 0;
                end;
                CreateExcelBook_lFnc;
            end else begin
                Clear(GSTExemp_lXml);
                GSTExemp_lXml.SetTableview(GSTEXEMP_lRec);

                if SetOutPutFile_gTxt = '' then begin
                    GSTExemp_lXml.Run;
                end else begin
                    if GSTEXEMP_lRec.IsEmpty then
                        CurrReport.Break;
                    // OutputFile_lFile.Create(SetOutPutFile_gTxt);
                    // OutputFile_lFile.CreateOutstream(OutStream_lOST);

                    Clear(TempBlob_lCdu);
                    TempBlob_lCdu.CreateInStream(SetOutPutFile_Instr);
                    SetOutPutFile_Instr.ReadText(SetOutPutFile_gTxt);
                    CopyStream(OutStream_lOST, SetOutPutFile_Instr);

                    GSTExemp_lXml.HideWinDialog_gFnc;
                    GSTExemp_lXml.SetDestination(OutStream_lOST);
                    GSTExemp_lXml.Export;
                    DataExported_gBln := true;
                end;
            end;
        end;
    end;

    trigger OnPreReport()
    var
        DetailedGSTLedgerEntry_lRec: Record "Detailed GST Ledger Entry";
        GSTEXEMP_lRec: Record "GST EXEMP";
        GSTGroup_lRec: Record "GST Group";
    begin
        if Month_gInt = 0 then
            Error('Select Month to Export Data');

        if Year_gInt = 0 then
            Error('Select Year to Export Data');

        if GSTRegNo_gCod = '' then
            Error('Select GST Registration No.');

        GSTEXEMP_lRec.Reset;
        GSTEXEMP_lRec.SetRange("GST Month", Month_gInt);
        GSTEXEMP_lRec.SetRange("GST Year", Year_gInt);
        GSTEXEMP_lRec.SetRange("GST Registration No.", GSTRegNo_gCod);
        GSTEXEMP_lRec.DeleteAll;

        SD_gDte := Dmy2date(1, Month_gInt, Year_gInt);
        ED_gDte := CalcDate('CM', SD_gDte);

        if SetOutPutFile_gTxt = '' then
            Win.Open('Total Record #1##########\Current Record #2###########');



        //NIL Rated Supplies
        Description_gTxt := '';
        DetailedGSTLedgerEntry_lRec.Reset;
        if GSTRegNo_gCod <> '' then
            DetailedGSTLedgerEntry_lRec.SetRange("Location  Reg. No.", GSTRegNo_gCod);
        DetailedGSTLedgerEntry_lRec.SetRange("Entry Type", DetailedGSTLedgerEntry_lRec."entry type"::"Initial Entry");
        DetailedGSTLedgerEntry_lRec.SetRange("Posting Date", SD_gDte, ED_gDte);
        DetailedGSTLedgerEntry_lRec.SetRange("Transaction Type", DetailedGSTLedgerEntry_lRec."transaction type"::Sales);
        DetailedGSTLedgerEntry_lRec.SetFilter("Document Type", '%1|%2', DetailedGSTLedgerEntry_lRec."document type"::Invoice, DetailedGSTLedgerEntry_lRec."Document Type"::"Credit Memo");
        DetailedGSTLedgerEntry_lRec.SetFilter("GST Component Code", '<>%1', 'SGST');  //Only CGST Line consider for export data
        DetailedGSTLedgerEntry_lRec.SetFilter("GST %", '=%1', 0);
        DetailedGSTLedgerEntry_lRec.SetRange("GST Exempted Goods", false);
        DetailedGSTLedgerEntry_lRec.SetFilter("GST Customer Type", '%1|%2', DetailedGSTLedgerEntry_lRec."GST Customer Type"::Registered, DetailedGSTLedgerEntry_lRec."GST Customer Type"::Unregistered);
        if DetailedGSTLedgerEntry_lRec.FindSet then begin
            repeat
                if DetailedGSTLedgerEntry_lRec."GST Component Code" <> 'KFLOODCESS' then begin
                    GSTGroup_lRec.Get(DetailedGSTLedgerEntry_lRec."GST Group Code");
                    // if GSTGroup_lRec."NIL Rated Group" then begin
                    Description_gTxt := UpdateDescription_gFnc(DetailedGSTLedgerEntry_lRec);
                    UpdateNilRated_gFnc(DetailedGSTLedgerEntry_lRec);
                    // end;
                end;
            until DetailedGSTLedgerEntry_lRec.Next = 0;
        end;

        //Exempted
        Description_gTxt := '';
        DetailedGSTLedgerEntry_lRec.Reset;
        if GSTRegNo_gCod <> '' then
            DetailedGSTLedgerEntry_lRec.SetRange("Location  Reg. No.", GSTRegNo_gCod);
        DetailedGSTLedgerEntry_lRec.SetRange("Entry Type", DetailedGSTLedgerEntry_lRec."entry type"::"Initial Entry");
        DetailedGSTLedgerEntry_lRec.SetRange("Posting Date", SD_gDte, ED_gDte);
        DetailedGSTLedgerEntry_lRec.SetRange("Transaction Type", DetailedGSTLedgerEntry_lRec."transaction type"::Sales);
        DetailedGSTLedgerEntry_lRec.SetFilter("Document Type", '%1|%2', DetailedGSTLedgerEntry_lRec."document type"::Invoice, DetailedGSTLedgerEntry_lRec."Document Type"::"Credit Memo");
        DetailedGSTLedgerEntry_lRec.SetFilter("GST Component Code", '<>%1', 'SGST');  //Only CGST Line consider for export data
        DetailedGSTLedgerEntry_lRec.SetRange("GST Exempted Goods", true);
        DetailedGSTLedgerEntry_lRec.SetFilter("GST Customer Type", '%1|%2', DetailedGSTLedgerEntry_lRec."GST Customer Type"::Registered, DetailedGSTLedgerEntry_lRec."GST Customer Type"::Unregistered);
        if DetailedGSTLedgerEntry_lRec.FindSet then begin
            repeat
                if DetailedGSTLedgerEntry_lRec."GST Component Code" <> 'KFLOODCESS' then begin
                    Description_gTxt := UpdateDescription_gFnc(DetailedGSTLedgerEntry_lRec);
                    UpdateExempted_gFnc(DetailedGSTLedgerEntry_lRec);
                end;
            until DetailedGSTLedgerEntry_lRec.Next = 0;
        end;

        // //Non GST
        // Description_gTxt := '';
        // DetailedGSTLedgerEntry_lRec.Reset;
        // DetailedGSTLedgerEntry_lRec.SetRange("Location  Reg. No.", GSTRegNo_gCod);
        // DetailedGSTLedgerEntry_lRec.SetRange("Entry Type", DetailedGSTLedgerEntry_lRec."entry type"::"Initial Entry");
        // DetailedGSTLedgerEntry_lRec.SetRange("Posting Date", SD_gDte, ED_gDte);
        // DetailedGSTLedgerEntry_lRec.SetRange("Transaction Type", DetailedGSTLedgerEntry_lRec."transaction type"::Sales);
        // DetailedGSTLedgerEntry_lRec.SetFilter("Document Type", '%1|%2', DetailedGSTLedgerEntry_lRec."document type"::Invoice, DetailedGSTLedgerEntry_lRec."Document Type"::"Credit Memo");
        // DetailedGSTLedgerEntry_lRec.SetFilter("GST Component Code", '<>%1', 'SGST');  //Only CGST Line consider for export data
        // DetailedGSTLedgerEntry_lRec.SetRange("GST Exempted Goods", false);
        // DetailedGSTLedgerEntry_lRec.SetFilter("GST Customer Type", '%1|%2', DetailedGSTLedgerEntry_lRec."GST Customer Type"::Registered, DetailedGSTLedgerEntry_lRec."GST Customer Type"::Unregistered);
        // // DetailedGSTLedgerEntry_lRec.SetRange("Sales Invoice Type", DetailedGSTLedgerEntry_lRec."sales invoice type"::"Non-GST");
        // if DetailedGSTLedgerEntry_lRec.FindSet then begin
        //     repeat
        //         if DetailedGSTLedgerEntry_lRec."GST Component Code" <> 'KFLOODCESS then begin
        //             Description_gTxt := UpdateDescription_gFnc(DetailedGSTLedgerEntry_lRec);
        //             UpdateNonGST_gFnc(DetailedGSTLedgerEntry_lRec);
        //         End;
        //     until DetailedGSTLedgerEntry_lRec.Next = 0;
        // end;
    end;

    var
        Month_gInt: Integer;
        Year_gInt: Integer;
        GSTRegNo_gCod: Text;
        SD_gDte: Date;
        ED_gDte: Date;
        Win: Dialog;
        CurrRec_gInt: Integer;
        Description_gOpt: Option "Inter-State supplies to registered persons","Intra-State supplies to registered persons","Inter-State supplies to unregistered persons","Intra-State supplies to unregistered persons";
        Description_gTxt: Text;
        SetOutPutFile_gTxt: Text[250];
        DataExported_gBln: Boolean;
        ExportToExcel_gBln: Boolean;
        ExcelBuffer_gRecTmp: Record "Excel Buffer" temporary;
        Text005: label 'Company Name';
        Text006: label 'Report No.';
        Text007: label 'Report Name';
        Text008: label 'User ID';
        Text009: label 'Date';
        Text010: label 'Filters';
        ExcelSaveFilePath_gTxt: Text;
        JustFillData_gBln: Boolean;


    procedure UpdateDescription_gFnc(var DetailedGSTLedgerEntry_vRec: Record "Detailed GST Ledger Entry"): Text[50]
    var
        GSTEXEMP_lRec: Record "GST EXEMP";
    begin
        GSTEXEMP_lRec.Reset();
        GSTEXEMP_lRec.SetRange(Description, Format(Description_gopt::"Inter-State supplies to registered persons"));
        GSTEXEMP_lRec.SetRange("GST Month", Month_gInt);
        GSTEXEMP_lRec.SetRange("GST Year", Year_gInt);
        GSTEXEMP_lRec.SetRange("GST Registration No.", DetailedGSTLedgerEntry_vRec."Location  Reg. No.");
        if not GSTEXEMP_lRec.FindFirst() then begin
            Clear(GSTEXEMP_lRec);
            GSTEXEMP_lRec.Init;
            GSTEXEMP_lRec."GST Month" := Month_gInt;
            GSTEXEMP_lRec."GST Year" := Year_gInt;
            GSTEXEMP_lRec."GST Registration No." := DetailedGSTLedgerEntry_vRec."Location  Reg. No.";
            GSTEXEMP_lRec.Description := Format(Description_gopt::"Inter-State supplies to registered persons");
            GSTEXEMP_lRec.Insert;
        end;
        GSTEXEMP_lRec.Reset;
        GSTEXEMP_lRec.SetRange(Description, Format(Description_gopt::"Intra-State supplies to registered persons"));
        GSTEXEMP_lRec.SetRange("GST Month", Month_gInt);
        GSTEXEMP_lRec.SetRange("GST Year", Year_gInt);
        GSTEXEMP_lRec.SetRange("GST Registration No.", DetailedGSTLedgerEntry_vRec."Location  Reg. No.");
        if not GSTEXEMP_lRec.FindFirst() then begin
            Clear(GSTEXEMP_lRec);
            GSTEXEMP_lRec.Init;
            GSTEXEMP_lRec."GST Month" := Month_gInt;
            GSTEXEMP_lRec."GST Year" := Year_gInt;
            GSTEXEMP_lRec."GST Registration No." := DetailedGSTLedgerEntry_vRec."Location  Reg. No.";
            GSTEXEMP_lRec.Description := Format(Description_gopt::"Intra-State supplies to registered persons");
            GSTEXEMP_lRec.Insert;
        end;
        GSTEXEMP_lRec.Reset;
        GSTEXEMP_lRec.SetRange(Description, Format(Description_gopt::"Inter-State supplies to unregistered persons"));
        GSTEXEMP_lRec.SetRange("GST Month", Month_gInt);
        GSTEXEMP_lRec.SetRange("GST Year", Year_gInt);
        GSTEXEMP_lRec.SetRange("GST Registration No.", DetailedGSTLedgerEntry_vRec."Location  Reg. No.");
        if not GSTEXEMP_lRec.FindFirst() then begin
            Clear(GSTEXEMP_lRec);
            GSTEXEMP_lRec.Init;
            GSTEXEMP_lRec."GST Month" := Month_gInt;
            GSTEXEMP_lRec."GST Year" := Year_gInt;
            GSTEXEMP_lRec."GST Registration No." := DetailedGSTLedgerEntry_vRec."Location  Reg. No.";
            GSTEXEMP_lRec.Description := Format(Description_gopt::"Inter-State supplies to unregistered persons");
            GSTEXEMP_lRec.Insert;
        end;
        GSTEXEMP_lRec.Reset;
        GSTEXEMP_lRec.SetRange(Description, Format(Description_gopt::"Intra-State supplies to unregistered persons"));
        GSTEXEMP_lRec.SetRange("GST Month", Month_gInt);
        GSTEXEMP_lRec.SetRange("GST Year", Year_gInt);
        GSTEXEMP_lRec.SetRange("GST Registration No.", DetailedGSTLedgerEntry_vRec."Location  Reg. No.");
        if not GSTEXEMP_lRec.FindFirst() then begin
            Clear(GSTEXEMP_lRec);
            GSTEXEMP_lRec.Init;
            GSTEXEMP_lRec."GST Month" := Month_gInt;
            GSTEXEMP_lRec."GST Year" := Year_gInt;
            GSTEXEMP_lRec."GST Registration No." := DetailedGSTLedgerEntry_vRec."Location  Reg. No.";
            GSTEXEMP_lRec.Description := Format(Description_gopt::"Intra-State supplies to unregistered persons");
            GSTEXEMP_lRec.Insert;
        end;

        case DetailedGSTLedgerEntry_vRec."GST Customer Type" of
            DetailedGSTLedgerEntry_vRec."GST Customer Type"::Registered:
                begin
                    if DetailedGSTLedgerEntry_vRec."GST Jurisdiction Type" = DetailedGSTLedgerEntry_vRec."gst jurisdiction type"::Interstate then
                        exit(Format(Description_gopt::"Inter-State supplies to registered persons"));
                    if DetailedGSTLedgerEntry_vRec."GST Jurisdiction Type" = DetailedGSTLedgerEntry_vRec."gst jurisdiction type"::Intrastate then
                        exit(Format(Description_gopt::"Intra-State supplies to registered persons"));
                end;
            DetailedGSTLedgerEntry_vRec."GST Customer Type"::Unregistered:
                begin
                    if DetailedGSTLedgerEntry_vRec."GST Jurisdiction Type" = DetailedGSTLedgerEntry_vRec."gst jurisdiction type"::Interstate then
                        exit(Format(Description_gopt::"Inter-State supplies to unregistered persons"));
                    if DetailedGSTLedgerEntry_vRec."GST Jurisdiction Type" = DetailedGSTLedgerEntry_vRec."gst jurisdiction type"::Intrastate then
                        exit(Format(Description_gopt::"Intra-State supplies to unregistered persons"));
                end;
        end;
    end;

    local procedure UpdateNilRated_gFnc(var DetailedGSTLedgerEntry_vRec: Record "Detailed GST Ledger Entry")
    var
        GSTEXEMP_lRec: Record "GST EXEMP";
    begin
        GSTEXEMP_lRec.Reset;
        GSTEXEMP_lRec.SetRange(Description, Description_gTxt);
        GSTEXEMP_lRec.SetRange("GST Month", Month_gInt);
        GSTEXEMP_lRec.SetRange("GST Year", Year_gInt);
        GSTEXEMP_lRec.SetRange("GST Registration No.", DetailedGSTLedgerEntry_vRec."Location  Reg. No.");
        if not GSTEXEMP_lRec.FindFirst then begin
            GSTEXEMP_lRec.Init;
            GSTEXEMP_lRec."GST Month" := Month_gInt;
            GSTEXEMP_lRec."GST Year" := Year_gInt;
            GSTEXEMP_lRec."GST Registration No." := DetailedGSTLedgerEntry_vRec."Location  Reg. No.";
            GSTEXEMP_lRec.Description := Description_gTxt;
            GSTEXEMP_lRec.Insert;
        end;
        if DetailedGSTLedgerEntry_vRec."Document Type" = DetailedGSTLedgerEntry_vRec."Document Type"::"Credit Memo" then
            GSTEXEMP_lRec."Nil Rated Supplies" += (-1) * Abs(DetailedGSTLedgerEntry_vRec."GST Base Amount")
        else
            GSTEXEMP_lRec."Nil Rated Supplies" += Abs(DetailedGSTLedgerEntry_vRec."GST Base Amount");
        GSTEXEMP_lRec.Modify;
    end;

    local procedure UpdateExempted_gFnc(var DetailedGSTLedgerEntry_vRec: Record "Detailed GST Ledger Entry")
    var
        GSTEXEMP_lRec: Record "GST EXEMP";
    begin
        GSTEXEMP_lRec.Reset;
        GSTEXEMP_lRec.SetRange("GST Month", Month_gInt);
        GSTEXEMP_lRec.SetRange("GST Year", Year_gInt);
        GSTEXEMP_lRec.SetRange("GST Registration No.", DetailedGSTLedgerEntry_vRec."Location  Reg. No.");
        GSTEXEMP_lRec.SetRange(Description, Description_gTxt);
        if not GSTEXEMP_lRec.FindFirst then begin
            GSTEXEMP_lRec.Init;
            GSTEXEMP_lRec."GST Month" := Month_gInt;
            GSTEXEMP_lRec."GST Year" := Year_gInt;
            GSTEXEMP_lRec."GST Registration No." := DetailedGSTLedgerEntry_vRec."Location  Reg. No.";
            GSTEXEMP_lRec.Description := Description_gTxt;
            GSTEXEMP_lRec.Insert;
        end;
        if DetailedGSTLedgerEntry_vRec."Document Type" = DetailedGSTLedgerEntry_vRec."Document Type"::"Credit Memo" then
            GSTEXEMP_lRec.Exempted += (-1) * Abs(DetailedGSTLedgerEntry_vRec."GST Base Amount")
        else
            GSTEXEMP_lRec.Exempted += Abs(DetailedGSTLedgerEntry_vRec."GST Base Amount");
        GSTEXEMP_lRec.Modify;
    end;

    local procedure UpdateNonGST_gFnc(var DetailedGSTLedgerEntry_vRec: Record "Detailed GST Ledger Entry")
    var
        GSTEXEMP_lRec: Record "GST EXEMP";
    begin
        GSTEXEMP_lRec.Reset;
        GSTEXEMP_lRec.SetRange("GST Month", Month_gInt);
        GSTEXEMP_lRec.SetRange("GST Year", Year_gInt);
        GSTEXEMP_lRec.SetRange("GST Registration No.", DetailedGSTLedgerEntry_vRec."Location  Reg. No.");
        GSTEXEMP_lRec.SetRange(Description, Description_gTxt);
        if not GSTEXEMP_lRec.FindFirst then begin
            GSTEXEMP_lRec.Init;
            GSTEXEMP_lRec."GST Month" := Month_gInt;
            GSTEXEMP_lRec."GST Year" := Year_gInt;
            GSTEXEMP_lRec."GST Registration No." := DetailedGSTLedgerEntry_vRec."Location  Reg. No.";
            GSTEXEMP_lRec.Description := Description_gTxt;
            GSTEXEMP_lRec.Insert;
        end;
        if DetailedGSTLedgerEntry_vRec."Document Type" = DetailedGSTLedgerEntry_vRec."Document Type"::"Credit Memo" then
            GSTEXEMP_lRec."Non-GST supplies" += (-1) * Abs(DetailedGSTLedgerEntry_vRec."GST Base Amount")
        else
            GSTEXEMP_lRec."Non-GST supplies" += Abs(DetailedGSTLedgerEntry_vRec."GST Base Amount");
        GSTEXEMP_lRec.Modify;
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
        ExcelBuffer_gRecTmp.AddInfoColumn('GSTR EXEMP', false, false, false, false, '', ExcelBuffer_gRecTmp."cell type"::Text);
        ExcelBuffer_gRecTmp.NewRow;
        ExcelBuffer_gRecTmp.AddInfoColumn(Format(Text006), false, true, false, false, '', ExcelBuffer_gRecTmp."cell type"::Text);
        ExcelBuffer_gRecTmp.AddInfoColumn(Report::"GSTR EXEMP", false, false, false, false, '', ExcelBuffer_gRecTmp."cell type"::Number);
        ExcelBuffer_gRecTmp.NewRow;
        ExcelBuffer_gRecTmp.AddInfoColumn(Format(Text008), false, true, false, false, '', ExcelBuffer_gRecTmp."cell type"::Text);
        ExcelBuffer_gRecTmp.AddInfoColumn(UserId, false, false, false, false, '', ExcelBuffer_gRecTmp."cell type"::Text);
        ExcelBuffer_gRecTmp.NewRow;
        ExcelBuffer_gRecTmp.AddInfoColumn(Format(Text009), false, true, false, false, '', ExcelBuffer_gRecTmp."cell type"::Text);
        ExcelBuffer_gRecTmp.AddInfoColumn(Today, false, false, false, false, '', ExcelBuffer_gRecTmp."cell type"::Date);

        ExcelBuffer_gRecTmp.ClearNewRow;
        MakeExcelDataHdr_lFnc;
    end;

    local procedure MakeExcelDataHdr_lFnc()
    begin
        ExcelBuffer_gRecTmp.NewRow;
        ExcelBuffer_gRecTmp.AddColumn('Description', false, '', true, false, true, '', ExcelBuffer_gRecTmp."cell type"::Text);
        ExcelBuffer_gRecTmp.AddColumn('Nil Rated Supplies', false, '', true, false, true, '', ExcelBuffer_gRecTmp."cell type"::Text);
        ExcelBuffer_gRecTmp.AddColumn('Exempted', false, '', true, false, true, '', ExcelBuffer_gRecTmp."cell type"::Text);
        ExcelBuffer_gRecTmp.AddColumn('Non GST supplies', false, '', true, false, true, '', ExcelBuffer_gRecTmp."cell type"::Text);
    end;

    local procedure MakeExcelDataBody_lFnc(GSTEXEMP_iRec: Record "GST EXEMP")
    var
        BankAcc_lRec: Record "Bank Account";
        Vendor_lRec: Record Vendor;
        Customer_lRec: Record Customer;
        FixedAsset_lRec: Record "Fixed Asset";
        AmtDrLCY_lDec: Decimal;
        AmtCrLCY_lDec: Decimal;
    begin
        ExcelBuffer_gRecTmp.NewRow;
        ExcelBuffer_gRecTmp.AddColumn(GSTEXEMP_iRec.Description, false, '', false, false, false, '@', ExcelBuffer_gRecTmp."cell type"::Text);
        ExcelBuffer_gRecTmp.AddColumn(GSTEXEMP_iRec."Nil Rated Supplies", false, '', false, false, false, '@', ExcelBuffer_gRecTmp."cell type"::Text);
        ExcelBuffer_gRecTmp.AddColumn(GSTEXEMP_iRec.Exempted, false, '', false, false, false, '@', ExcelBuffer_gRecTmp."cell type"::Text);
        ExcelBuffer_gRecTmp.AddColumn(GSTEXEMP_iRec."Non-GST supplies", false, '', false, false, false, '@', ExcelBuffer_gRecTmp."cell type"::Text);
    end;

    local procedure CreateExcelBook_lFnc()
    begin
        ExcelBuffer_gRecTmp.CreateNewBook('GST EXEMP');
        ExcelBuffer_gRecTmp.WriteSheet('Data', CompanyName(), UserId());
        ExcelBuffer_gRecTmp.CloseBook();
        ExcelBuffer_gRecTmp.OpenExcel();

        // if ExcelSaveFilePath_gTxt = '' then
        //     ExcelBuffer_gRecTmp.CreateBookAndOpenExcel('', 'GST EXEMP', 'Data', COMPANYNAME, UserId)
        // else begin
        //     ExcelBuffer_gRecTmp.FixLocationCreateBookAndSaveExcelMailSharedFile_gFnc('GST EXEMP', 'Data', ExcelSaveFilePath_gTxt);
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

