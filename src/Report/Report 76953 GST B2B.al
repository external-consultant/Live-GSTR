Report 76953 "GST B2B"
{
    Caption = 'GST B2B';
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
                TSH_lRec: Record "Transfer Shipment Header";
                TSL_lRec: Record "Transfer Shipment Line";
                ShiptoAddress_lRec: Record "Ship-to Address";
                Customer_lRec: Record Customer;
                GSTSetup_lRec: Record "GST Setup";
                SIL_lRec: Record "Sales Invoice Line";
                GSTLedgerEntry_lRec: Record "GST Ledger Entry";
            begin
                CurrRec_gInt += 1;

                if SetOutPutFile_gTxt = '' then
                    Win.Update(2, CurrRec_gInt);
                SEZGSTNNo_gCod := '';
                SEZGSTPerc_gDec := 0;
                SEZPlaceofSupply_gTxt := '';
                SEZGSTAMT_gDec := 0;

                if not ("GST Customer Type" in ["gst customer type"::Registered, "gst customer type"::"Deemed Export", "gst customer type"::"SEZ Development", "gst customer type"::"SEZ Unit"]) then
                    CurrReport.Skip;

                if "GST Component Code" = 'KFLOODCESS' then
                    CurrReport.Skip();

                //IF ("GST Base Amount" = 0) AND (Quantity = 0) THEN  //For Transfer Order Line System Create the Zero GST Base Amount line
                //  CurrReport.SKIP;

                ConsiderEntry_lBln := false;

                //Posted Sales & Service Invoice
                if ("Transaction Type" = "transaction type"::Sales) and ("Document Type" in ["document type"::Invoice]) then begin
                    ConsiderEntry_lBln := true;
                end;

                if not ConsiderEntry_lBln then
                    CurrReport.Skip;

                InvoiceValue_gDec := 0;
                Clear(GSTRInvoiceType_gOpt);

                //Posted Sales & Service Invoice
                DataExport_lBln := false;
                if SIH_lRec.Get("Document No.") then begin
                    if "GST Customer Type" = "gst customer type"::"Deemed Export" then
                        GSTRInvoiceType_gOpt := Gstrinvoicetype_gopt::"Deemed Export";

                    //VG-NS 05-Jun-2018
                    if "GST Customer Type" in ["gst customer type"::"SEZ Development", "gst customer type"::"SEZ Unit"] then begin
                        if "GST Without Payment of Duty" then
                            GSTRInvoiceType_gOpt := Gstrinvoicetype_gopt::"SEZ supplies without payment"
                        else
                            GSTRInvoiceType_gOpt := Gstrinvoicetype_gopt::"SEZ supplies with payment";
                    end else begin
                        if "GST %" = 0 then
                            CurrReport.Skip;
                    end;
                    //VG-NE 05-Jun-2018
                    //NJ-NS
                    if "GST Customer Type" = "GST Customer Type"::Registered then begin
                        GSTLedgerEntry_lRec.Reset();
                        GSTLedgerEntry_lRec.SetRange("Document No.", "Document No.");
                        GSTLedgerEntry_lRec.SetRange("Posting Date", "Posting Date");
                        GSTLedgerEntry_lRec.SetRange("POS Out Of India", True);
                        if GSTLedgerEntry_lRec.FindFirst() then
                            GSTRInvoiceType_gOpt := GSTRInvoiceType_gOpt::"Intra-State supplies attracting IGST"
                        else
                            GSTRInvoiceType_gOpt := GSTRInvoiceType_gOpt::Regular;
                    end;
                    //NJ-NE

                    InvoiceValue_gDec := GSTRCommonFunction_gCdu.FindInvoiceValue_gFnc("Detailed GST Ledger Entry");

                    if "GST Customer Type" in ["gst customer type"::"SEZ Development", "gst customer type"::"SEZ Unit"] then begin
                        if "GST Amount" = 0 then begin
                            // GSTSetup_lRec.Reset;
                            // GSTSetup_lRec.SetRange("GST Group Code", "GST Group Code");
                            // GSTSetup_lRec.SetRange("GST Component Code", "GST Component Code");
                            // GSTSetup_lRec.SetFilter("Effective Date", '<=%1', "Posting Date");
                            // GSTSetup_lRec.FindLast;
                            // SEZGSTPerc_gDec := GSTSetup_lRec."GST Component %";
                            // if GSTRInvoiceType_gOpt = Gstrinvoicetype_gopt::"SEZ supplies with payment" then
                            //     SEZGSTAMT_gDec := Abs("GST Base Amount" * GSTSetup_lRec."GST Component %" / 100);
                        end else
                            SEZGSTAMT_gDec := Abs("GST Amount");

                        SIL_lRec.Reset;
                        SIL_lRec.SetRange("Document No.", "Document No.");
                        SIL_lRec.SetFilter("GST Place of Supply", '<>%1', SIL_lRec."gst place of supply"::" ");
                        SIL_lRec.FindFirst;
                        if SIL_lRec."GST Place of Supply" = SIL_lRec."gst place of supply"::"Bill-to Address" then begin
                            Customer_lRec.Get(SIL_lRec."Bill-to Customer No.");
                            SEZPlaceofSupply_gTxt := GSTRCommonFunction_gCdu.GetPOSFromState_gFnc(Customer_lRec."State Code");
                            SEZGSTNNo_gCod := Customer_lRec."GST Registration No.";
                        end;
                        if SIL_lRec."GST Place of Supply" = SIL_lRec."gst place of supply"::"Ship-to Address" then begin
                            ShiptoAddress_lRec.Get(SIL_lRec."Sell-to Customer No.", SIH_lRec."Ship-to Code");
                            SEZPlaceofSupply_gTxt := GSTRCommonFunction_gCdu.GetPOSFromState_gFnc(ShiptoAddress_lRec.State);
                            SEZGSTNNo_gCod := ShiptoAddress_lRec."GST Registration No.";
                        end;
                    end;

                    PostedSalesInvocie_gFnc("Detailed GST Ledger Entry");
                    DataExport_lBln := true;
                end;

                if not DataExport_lBln then begin
                    if SerInvHdr_lRec.Get("Document No.") then begin
                        if "GST Customer Type" = "gst customer type"::"Deemed Export" then
                            GSTRInvoiceType_gOpt := Gstrinvoicetype_gopt::"Deemed Export";

                        //VG-NS 05-Jun-2018
                        if "GST Customer Type" in ["gst customer type"::"SEZ Development", "gst customer type"::"SEZ Unit"] then begin
                            if "GST Without Payment of Duty" then
                                GSTRInvoiceType_gOpt := Gstrinvoicetype_gopt::"SEZ supplies without payment"
                            else
                                GSTRInvoiceType_gOpt := Gstrinvoicetype_gopt::"SEZ supplies with payment";
                        end else begin
                            if "GST %" = 0 then
                                CurrReport.Skip;
                        end;
                        //VG-NE 05-Jun-2018

                        //NJ-NS
                        if "GST Customer Type" = "GST Customer Type"::Registered then begin
                            GSTLedgerEntry_lRec.Reset();
                            GSTLedgerEntry_lRec.SetRange("Document No.", "Document No.");
                            GSTLedgerEntry_lRec.SetRange("Posting Date", "Posting Date");
                            GSTLedgerEntry_lRec.SetRange("POS Out Of India", True);
                            if GSTLedgerEntry_lRec.FindFirst() then
                                GSTRInvoiceType_gOpt := GSTRInvoiceType_gOpt::"Intra-State supplies attracting IGST"
                            else
                                GSTRInvoiceType_gOpt := GSTRInvoiceType_gOpt::Regular;
                        end;
                        //NJ-NE

                        InvoiceValue_gDec := GSTRCommonFunction_gCdu.FindInvoiceValue_gFnc("Detailed GST Ledger Entry");
                        PostedSalesInvocie_gFnc("Detailed GST Ledger Entry");
                        DataExport_lBln := true;
                    end;
                end;

                if not DataExport_lBln then begin
                    if TSH_lRec.Get("Document No.") then begin
                        // TSL_lRec.Reset;
                        // TSL_lRec.SetRange("Document No.", TSH_lRec."No.");
                        // if TSL_lRec.FindSet then begin
                        //     repeat
                        //         InvoiceValue_gDec += TSL_lRec.Amount + TSL_lRec."Total GST Amount";
                        //     until TSL_lRec.Next = 0;
                        // end;
                        InvoiceValue_gDec := "Detailed GST Ledger Entry"."GST Amount" + "Detailed GST Ledger Entry"."GST Base Amount";
                        PostedSalesInvocie_gFnc("Detailed GST Ledger Entry");
                        DataExport_lBln := true;

                        if "GST %" = 0 then
                            CurrReport.Skip;
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


                SetRange("Location  Reg. No.", GSTRegNo_gCod);
                SetRange("Entry Type", "entry type"::"Initial Entry");
                SetRange("Posting Date", SD_gDte, ED_gDte);
                // SetRange("Nature of Supply", "nature of supply"::B2B);
                Setfilter("GST Customer Type", '%1|%2|%3|%4', "GST Customer Type"::Registered, "GST Customer Type"::"Deemed Export", "GST Customer Type"::"SEZ Development", "GST Customer Type"::"SEZ Unit");
                SetRange("Transaction Type", "transaction type"::Sales);
                SetRange("Document Type", "document type"::Invoice);
                // SetFilter("Sales Invoice Type", '<>%1', "sales invoice type"::"Non-GST");
                SetFilter("GST Component Code", '<>%1', 'SGST');  //Only CGST Line consider for export data
                SetRange("GST Exempted Goods", false);
                //SETFILTER("GST %",'<>%1',0);

                CurrRec_gInt := 0;
                TempCnt_lInt := Count;

                if SetOutPutFile_gTxt = '' then
                    Win.Update(1, Count);

                GSTB2B_gRec.Reset;
                GSTB2B_gRec.SetCurrentkey("GST Month", "GST Year");
                GSTB2B_gRec.SetRange("GST Month", Month_gInt);
                GSTB2B_gRec.SetRange("GST Year", Year_gInt);
                GSTB2B_gRec.SetRange("GST Registration No.", GSTRegNo_gCod);
                GSTB2B_gRec.DeleteAll;
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
                    TableRelation = "GST Registration Nos.";

                    // trigger OnLookup(var Text: Text): Boolean
                    // var
                    //     GSTRegnNos_lRec: Record "GST Registration Nos.";
                    //     GSTRegnNos_lPge: Page "GST Registration Nos.";
                    // begin
                    //     GSTRegnNos_lRec.Reset();

                    //     Clear(GSTRegnNos_lPge);
                    //     GSTRegNo_gCod := '';
                    //     GSTRegnNos_lPge.LookupMode(true);
                    //     GSTRegnNos_lPge.SetTableView(GSTRegnNos_lRec);
                    //     if GSTRegnNos_lPge.RunModal() = Action::LookupOK then begin
                    //         GSTRegnNos_lRec.Reset();
                    //         GSTRegnNos_lPge.SetSelectionFilter(GSTRegnNos_lRec);
                    //         if GSTRegnNos_lRec.FindSet then begin
                    //             repeat
                    //                 if GSTRegNo_gCod = '' then
                    //                     GSTRegNo_gCod := GSTRegnNos_lRec.Code
                    //                 else
                    //                     GSTRegNo_gCod := GSTRegNo_gCod + '|' + GSTRegnNos_lRec.Code;
                    //             until GSTRegnNos_lRec.Next = 0;
                    //         end;
                    //     end else
                    //         Error('');
                    // end;
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
        GSTB2B_lXml: XmlPort "GST - B2B Export";
        GSTB2B_lRec: Record "GST B2B";
        OutputFile_lFile: File;
        OutStream_lOST: OutStream;
        TempBlob_lCdu: Codeunit "Temp Blob";
        SetOutPutFile_Instr: Instream;
    begin
        if SetOutPutFile_gTxt = '' then
            Win.Close;

        Commit;

        if not JustFillData_gBln then begin
            GSTB2B_lRec.Reset;
            GSTB2B_lRec.SetRange("GST Month", Month_gInt);
            GSTB2B_lRec.SetRange("GST Year", Year_gInt);
            GSTB2B_lRec.SetRange("GST Registration No.", GSTRegNo_gCod);
            if ExportToExcel_gBln then begin
                MakeExcelDataInfo_lFnc;
                if GSTB2B_lRec.FindSet then begin
                    DataExported_gBln := true;
                    if ExcelSaveFilePath_gTxt <> '' then
                        MakeExcelDataHeader_lFnc;
                    repeat
                        MakeExcelDataBody_lFnc(GSTB2B_lRec);
                    until GSTB2B_lRec.Next = 0;
                end;
                CreateExcelBook_lFnc;
            end else begin
                Clear(GSTB2B_lXml);
                GSTB2B_lXml.SetTableview(GSTB2B_lRec);

                if SetOutPutFile_gTxt = '' then begin
                    GSTB2B_lXml.Run;
                end else begin
                    if GSTB2B_lRec.IsEmpty then
                        CurrReport.Break;

                    // OutputFile_lFile.Create(SetOutPutFile_gTxt);
                    // OutputFile_lFile.CreateOutstream(OutStream_lOST);

                    Clear(TempBlob_lCdu);
                    TempBlob_lCdu.CreateInStream(SetOutPutFile_Instr);
                    SetOutPutFile_Instr.ReadText(SetOutPutFile_gTxt);
                    CopyStream(OutStream_lOST, SetOutPutFile_Instr);

                    GSTB2B_lXml.HideWinDialog_gFnc;
                    GSTB2B_lXml.SetDestination(OutStream_lOST);
                    GSTB2B_lXml.Export;
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
        GSTB2B_gRec: Record "GST B2B";
        GSTRCommonFunction_gCdu: Codeunit "GSTR Common Function";
        GSTRInvoiceType_gOpt: Option Regular,"SEZ Supplies with Payment","SEZ Supplies without Payment","Deemed Export","Intra-State supplies attracting IGST";
        InvoiceValue_gDec: Decimal;
        SEZGSTNNo_gCod: Code[20];
        SEZGSTPerc_gDec: Decimal;
        SEZPlaceofSupply_gTxt: Text[100];
        SEZGSTAMT_gDec: Decimal;
        SetOutPutFile_gTxt: Text[250];
        DataExported_gBln: Boolean;
        ExportToExcel_gBln: Boolean;
        ExcelBuffer_gRecTmp: Record "Excel Buffer" temporary;
        JustFillData_gBln: Boolean;
        ExcelSaveFilePath_gTxt: Text;

    local procedure PostedSalesInvocie_gFnc(DetailedGSTLedgerEntry_iRec: Record "Detailed GST Ledger Entry")
    var
        GSTB2B_lRec: Record "GST B2B";
    begin
        if DetailedGSTLedgerEntry_iRec."GST Component Code" = 'CGST' then
            DetailedGSTLedgerEntry_iRec."GST %" := DetailedGSTLedgerEntry_iRec."GST %" * 2;

        if (SEZGSTPerc_gDec <> 0) and (DetailedGSTLedgerEntry_iRec."GST %" = 0) then
            DetailedGSTLedgerEntry_iRec."GST %" := SEZGSTPerc_gDec;

        GSTB2B_lRec.Reset;
        GSTB2B_lRec.SetCurrentkey("Invoice Number", Rate);
        GSTB2B_lRec.SetRange("Invoice Number", DetailedGSTLedgerEntry_iRec."Document No.");
        GSTB2B_lRec.SetRange(Rate, DetailedGSTLedgerEntry_iRec."GST %");
        if not GSTB2B_lRec.FindFirst then begin
            GSTB2B_lRec.Init;
            GSTB2B_lRec."GST Month" := Month_gInt;
            GSTB2B_lRec."GST Year" := Year_gInt;
            GSTB2B_lRec."GST Registration No." := DetailedGSTLedgerEntry_iRec."Location  Reg. No.";
            GSTB2B_lRec."GSTIN/UIN of Recipient" := DetailedGSTLedgerEntry_iRec."Buyer/Seller Reg. No.";
            if GSTB2B_lRec."GSTIN/UIN of Recipient" = '' then
                GSTB2B_lRec."GSTIN/UIN of Recipient" := SEZGSTNNo_gCod;

            GSTB2B_lRec."Receiver Name" := GSTRCommonFunction_gCdu.GetReceiverName_gFnc(DetailedGSTLedgerEntry_iRec);
            GSTB2B_lRec."Invoice Number" := DetailedGSTLedgerEntry_iRec."Document No.";
            GSTB2B_lRec."Invoice Date" := DetailedGSTLedgerEntry_iRec."Posting Date";
            GSTB2B_lRec."Invoice Type" := GSTRInvoiceType_gOpt;
            GSTB2B_lRec."Invoice Value" := InvoiceValue_gDec;
            if DetailedGSTLedgerEntry_iRec."Reverse Charge" then
                GSTB2B_lRec."Reverse Charge" := GSTB2B_lRec."reverse charge"::Y
            else
                GSTB2B_lRec."Reverse Charge" := GSTB2B_lRec."reverse charge"::N;

            if SEZPlaceofSupply_gTxt <> '' then
                GSTB2B_lRec."Place of Supply" := SEZPlaceofSupply_gTxt
            else
                GSTB2B_lRec."Place of Supply" := GSTRCommonFunction_gCdu.GSTRPlaceOfSupply_gFnc(DetailedGSTLedgerEntry_iRec);

            // GSTB2B_lRec."E-Commerce GSTIN" := DetailedGSTLedgerEntry_iRec."e-Comm. Operator GST Reg. No.";
            GSTB2B_lRec.Rate := DetailedGSTLedgerEntry_iRec."GST %";
            GSTB2B_lRec.Insert;
        end;

        GSTB2B_lRec."Taxable Value" := GSTB2B_lRec."Taxable Value" + Abs(DetailedGSTLedgerEntry_iRec."GST Base Amount");

        if SEZGSTAMT_gDec <> 0 then
            GSTB2B_lRec."Invoice Value" += SEZGSTAMT_gDec;

        GSTB2B_lRec.Modify;
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
        ExcelBuffer_gRecTmp.AddInfoColumn('GST B2B', false, false, false, false, '', ExcelBuffer_gRecTmp."cell type"::Text);
        ExcelBuffer_gRecTmp.NewRow;
        ExcelBuffer_gRecTmp.AddInfoColumn(Format(Text006), false, true, false, false, '', ExcelBuffer_gRecTmp."cell type"::Text);
        ExcelBuffer_gRecTmp.AddInfoColumn(Report::"GST B2B", false, false, false, false, '', ExcelBuffer_gRecTmp."cell type"::Number);
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
        ExcelBuffer_gRecTmp.AddColumn('Invoice Number', false, '', true, false, true, '', ExcelBuffer_gRecTmp."cell type"::Text);
        ExcelBuffer_gRecTmp.AddColumn('Invoice date', false, '', true, false, true, '', ExcelBuffer_gRecTmp."cell type"::Text);
        ExcelBuffer_gRecTmp.AddColumn('Invoice Value', false, '', true, false, true, '', ExcelBuffer_gRecTmp."cell type"::Text);
        ExcelBuffer_gRecTmp.AddColumn('Place Of Supply', false, '', true, false, true, '', ExcelBuffer_gRecTmp."cell type"::Text);
        ExcelBuffer_gRecTmp.AddColumn('Reverse Charge', false, '', true, false, true, '', ExcelBuffer_gRecTmp."cell type"::Text);
        ExcelBuffer_gRecTmp.AddColumn('Applicable % of Tax Rate', false, '', true, false, true, '', ExcelBuffer_gRecTmp."cell type"::Text);  //NJ
        ExcelBuffer_gRecTmp.AddColumn('Invoice Type', false, '', true, false, true, '', ExcelBuffer_gRecTmp."cell type"::Text);
        ExcelBuffer_gRecTmp.AddColumn('E-Commerce GSTIN', false, '', true, false, true, '', ExcelBuffer_gRecTmp."cell type"::Text);
        ExcelBuffer_gRecTmp.AddColumn('Rate', false, '', true, false, true, '', ExcelBuffer_gRecTmp."cell type"::Text);
        ExcelBuffer_gRecTmp.AddColumn('Taxable Value', false, '', true, false, true, '', ExcelBuffer_gRecTmp."cell type"::Text);
        ExcelBuffer_gRecTmp.AddColumn('Cess Amount', false, '', true, false, true, '', ExcelBuffer_gRecTmp."cell type"::Text);

    end;

    local procedure MakeExcelDataBody_lFnc(GSTB2B_iRec: Record "GST B2B")
    var
        BankAcc_lRec: Record "Bank Account";
        Vendor_lRec: Record Vendor;
        Customer_lRec: Record Customer;
        FixedAsset_lRec: Record "Fixed Asset";
        AmtDrLCY_lDec: Decimal;
        AmtCrLCY_lDec: Decimal;
    begin
        ExcelBuffer_gRecTmp.NewRow;
        ExcelBuffer_gRecTmp.AddColumn(GSTB2B_iRec."GSTIN/UIN of Recipient", false, '', false, false, false, '', ExcelBuffer_gRecTmp."cell type"::Text);
        ExcelBuffer_gRecTmp.AddColumn(GSTB2B_iRec."Receiver Name", false, '', false, false, false, '', ExcelBuffer_gRecTmp."cell type"::Text);
        ExcelBuffer_gRecTmp.AddColumn(GSTB2B_iRec."Invoice Number", false, '', false, false, false, '', ExcelBuffer_gRecTmp."cell type"::Text);
        ExcelBuffer_gRecTmp.AddColumn(GSTB2B_iRec."Invoice Date", false, '', false, false, false, '', ExcelBuffer_gRecTmp."cell type"::Date);
        ExcelBuffer_gRecTmp.AddColumn(GSTB2B_iRec."Invoice Value", false, '', false, false, false, '#,##0.00', ExcelBuffer_gRecTmp."cell type"::Number);
        ExcelBuffer_gRecTmp.AddColumn(GSTB2B_iRec."Place of Supply", false, '', false, false, false, '', ExcelBuffer_gRecTmp."cell type"::Text);
        ExcelBuffer_gRecTmp.AddColumn(Format(GSTB2B_iRec."Reverse Charge"), false, '', false, false, false, '', ExcelBuffer_gRecTmp."cell type"::Text);
        ExcelBuffer_gRecTmp.AddColumn('', false, '', false, false, false, '', ExcelBuffer_gRecTmp."cell type"::Text);  //NJ
        ExcelBuffer_gRecTmp.AddColumn(Format(GSTB2B_iRec."Invoice Type"), false, '', false, false, false, '', ExcelBuffer_gRecTmp."cell type"::Text);
        ExcelBuffer_gRecTmp.AddColumn(GSTB2B_iRec."E-Commerce GSTIN", false, '', false, false, false, '', ExcelBuffer_gRecTmp."cell type"::Text);
        ExcelBuffer_gRecTmp.AddColumn(GSTB2B_iRec.Rate, false, '', false, false, false, '#,##0.00', ExcelBuffer_gRecTmp."cell type"::Number);
        ExcelBuffer_gRecTmp.AddColumn(GSTB2B_iRec."Taxable Value", false, '', false, false, false, '#,##0.00', ExcelBuffer_gRecTmp."cell type"::Number);
        ExcelBuffer_gRecTmp.AddColumn(GSTB2B_iRec."Cess Amount", false, '', false, false, false, '#,##0.00', ExcelBuffer_gRecTmp."cell type"::Number);
    end;

    local procedure CreateExcelBook_lFnc()
    begin
        ExcelBuffer_gRecTmp.CreateNewBook('GST B2B');
        ExcelBuffer_gRecTmp.WriteSheet('Data', CompanyName(), UserId());
        ExcelBuffer_gRecTmp.CloseBook();
        ExcelBuffer_gRecTmp.OpenExcel();

        // if ExcelSaveFilePath_gTxt = '' then
        //     ExcelBuffer_gRecTmp.CreateBookAndOpenExcel('', 'GST B2B', 'Data', COMPANYNAME, UserId)
        // else begin
        //     ExcelBuffer_gRecTmp.FixLocationCreateBookAndSaveExcelMailSharedFile_gFnc('GST B2B', 'Data', ExcelSaveFilePath_gTxt);
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

