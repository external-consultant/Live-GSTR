Report 76964 "GSTR ITC 04 JW To MFG"
{
    ProcessingOnly = true;

    dataset
    {
        dataitem("Item Ledger Entry"; "Item Ledger Entry")
        {
            DataItemTableView = sorting("Posting Date", "Item No.") where("Entry Type" = const(Consumption), Quantity = filter(< 0));


            trigger OnAfterGetRecord()
            var
                Location_lRec: Record Location;
                Vendor_lRec: Record Vendor;
                DeliveryChallanLine_lRec: Record "Delivery Challan Line";
                UnitCost_lDec: Decimal;
            begin
                Curr_gInt += 1;
                Win_gDlg.Update(2, Curr_gInt);

                Location_lRec.Get("Location Code");
                if not Location_lRec."Subcontracting Location" then
                    CurrReport.Skip;

                ClearVar_gFnc;

                MailTempItemEntry_gRecTmp.Reset;
                MailTempItemEntry_gRecTmp.DeleteAll;
                FindAppliedEntry("Item Ledger Entry");

                MailTempItemEntry_gRecTmp.Reset;
                MailTempItemEntry_gRecTmp.FindFirst;
                Location_lRec.Get(MailTempItemEntry_gRecTmp."Location Code");
                Location_lRec.TestField("Subcontractor No.");
                Vendor_lRec.Get(Location_lRec."Subcontractor No.");

                //Find Olrignal Delivery Challan Line
                DeliveryChallanLine_lRec.Reset;
                DeliveryChallanLine_lRec.SetRange("Vendor Location", MailTempItemEntry_gRecTmp."Location Code");
                DeliveryChallanLine_lRec.SetRange("Delivery Challan No.", MailTempItemEntry_gRecTmp."External Document No.");
                DeliveryChallanLine_lRec.SetRange("Item No.", MailTempItemEntry_gRecTmp."Item No.");
                DeliveryChallanLine_lRec.SetRange("Document No.", MailTempItemEntry_gRecTmp."Subcon Order No.");
                DeliveryChallanLine_lRec.FindLast;
                DeliveryChallanLine_lRec.CalcFields("GST Registration No.");
                if DeliveryChallanLine_lRec."GST Registration No." <> GSTRegNo_gCod then
                    CurrReport.Skip;

                GSTINofJobWorkerJW_gCod := Vendor_lRec."GST Registration No.";
                StateUnregisteredJW_gTxt := GSTRPlaceOfSupply_lFnc(Vendor_lRec);
                NatureofTransaction_gTxt := 'Goods Received back from JW';
                ChallanNumber_gCod := DeliveryChallanLine_lRec."Delivery Challan No.";
                ChallanDate_gDte := DeliveryChallanLine_lRec."Posting Date";
                DescriptionofGoods_gTxt := DeliveryChallanLine_lRec.Description;
                UniqueQuantityCode_gCod := GSTRCommonFunction_gCdu.GetUOMDescriptionITC04_gFnc(DeliveryChallanLine_lRec."Unit of Measure");
                Quantity_gDec := Abs(Quantity);

                MailTempItemEntry_gRecTmp.CalcFields("Cost Amount (Expected)", "Cost Amount (Actual)");
                UnitCost_lDec := (MailTempItemEntry_gRecTmp."Cost Amount (Expected)" + MailTempItemEntry_gRecTmp."Cost Amount (Actual)") / Abs(MailTempItemEntry_gRecTmp.Quantity);
                TaxableValue_gDec := ROUND(UnitCost_lDec * Abs(Quantity), 0.01);

                if ExportData_gOpt = Exportdata_gopt::Excel then
                    MakeExcelDataBodyInv_lFnc
                else
                    InsertBufferTable_gFnc;
            end;

            trigger OnPreDataItem()
            begin
                if GSTRegNo_gCod = '' then
                    Error('Select GST Registration No.');

                if Year_gInt = 0 then
                    Error('Select Year');

                if StartingDate_gDte = 0D then
                    Error('Select Quarter');

                GSTRCommonFunction_gCdu.GetDateByQuarter_gFnc(Year_gInt, Quarter_gOpt, StartingDate_gDte, EndingDate_gDte);

                SetRange("Posting Date", StartingDate_gDte, EndingDate_gDte);
                //SETFILTER(Quantity,'<%1',-100000);
                Win_gDlg.Open('Total Record #1##################\Current #2######################');
                Win_gDlg.Update(1, Count);

                //Example ILE No. to Check - Hirel - 793015
            end;
        }
        dataitem(ILEReverseBackMaterial; "Item Ledger Entry")
        {
            DataItemTableView = sorting("Posting Date", "Item No.");

            trigger OnAfterGetRecord()
            var
                Location_lRec: Record Location;
                Vendor_lRec: Record Vendor;
                DeliveryChallanLine_lRec: Record "Delivery Challan Line";
                UnitCost_lDec: Decimal;
            begin
                Curr_gInt += 1;
                Win_gDlg.Update(2, Curr_gInt);

                Location_lRec.Get("Location Code");
                if not Location_lRec."Subcontracting Location" then
                    CurrReport.Skip;

                ClearVar_gFnc;

                MailTempItemEntry_gRecTmp.Reset;
                MailTempItemEntry_gRecTmp.DeleteAll;
                FindAppliedEntry(ILEReverseBackMaterial);

                MailTempItemEntry_gRecTmp.Reset;
                MailTempItemEntry_gRecTmp.FindFirst;
                Location_lRec.Get(MailTempItemEntry_gRecTmp."Location Code");
                Location_lRec.TestField("Subcontractor No.");
                Vendor_lRec.Get(Location_lRec."Subcontractor No.");

                //Find Olrignal Delivery Challan Line
                DeliveryChallanLine_lRec.Reset;
                DeliveryChallanLine_lRec.SetRange("Vendor Location", MailTempItemEntry_gRecTmp."Location Code");
                DeliveryChallanLine_lRec.SetRange("Delivery Challan No.", MailTempItemEntry_gRecTmp."External Document No.");
                DeliveryChallanLine_lRec.SetRange("Item No.", MailTempItemEntry_gRecTmp."Item No.");
                DeliveryChallanLine_lRec.SetRange("Document No.", MailTempItemEntry_gRecTmp."Subcon Order No.");
                DeliveryChallanLine_lRec.FindLast;
                DeliveryChallanLine_lRec.CalcFields("GST Registration No.");
                if DeliveryChallanLine_lRec."GST Registration No." <> GSTRegNo_gCod then
                    CurrReport.Skip;

                GSTINofJobWorkerJW_gCod := Vendor_lRec."GST Registration No.";
                StateUnregisteredJW_gTxt := GSTRPlaceOfSupply_lFnc(Vendor_lRec);
                NatureofTransaction_gTxt := 'Goods Received back from JW';
                ChallanNumber_gCod := DeliveryChallanLine_lRec."Delivery Challan No.";
                ChallanDate_gDte := DeliveryChallanLine_lRec."Posting Date";
                DescriptionofGoods_gTxt := DeliveryChallanLine_lRec.Description;
                UniqueQuantityCode_gCod := GSTRCommonFunction_gCdu.GetUOMDescriptionITC04_gFnc(DeliveryChallanLine_lRec."Unit of Measure");
                Quantity_gDec := Abs(Quantity);

                MailTempItemEntry_gRecTmp.CalcFields("Cost Amount (Expected)", "Cost Amount (Actual)");
                UnitCost_lDec := (MailTempItemEntry_gRecTmp."Cost Amount (Expected)" + MailTempItemEntry_gRecTmp."Cost Amount (Actual)") / Abs(MailTempItemEntry_gRecTmp.Quantity);
                TaxableValue_gDec := ROUND(UnitCost_lDec * Abs(Quantity), 0.01);

                if ExportData_gOpt = Exportdata_gopt::Excel then
                    MakeExcelDataBodyInv_lFnc
                else
                    InsertBufferTable_gFnc;
            end;

            trigger OnPreDataItem()
            begin
                SetRange("Posting Date", StartingDate_gDte, EndingDate_gDte);
                SetRange("Entry Type", "entry type"::Transfer);
                SetFilter(Quantity, '<%1', 0);
                Win_gDlg.Update(1, Count);

                //Example ILE No. to Check - Hirel - 399362  //Reverse Back Material from Vendor Subcon Location
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
                group(Options)
                {
                    field("GST Register No."; GSTRegNo_gCod)
                    {
                        ApplicationArea = Basic;
                        Caption = 'GST Registration No.';
                        TableRelation = "GST Registration Nos.";
                    }
                    field(Year; Year_gInt)
                    {
                        ApplicationArea = Basic;
                        Caption = 'Year';
                        MaxValue = 2099;
                        MinValue = 2017;
                    }
                    field(Quarter_gOpt; Quarter_gOpt)
                    {
                        ApplicationArea = Basic;
                        Caption = 'Quarter';

                        trigger OnValidate()
                        begin
                            if Year_gInt = 0 then
                                Error('Year must have a value.');

                            GSTRCommonFunction_gCdu.GetDateByQuarter_gFnc(Year_gInt, Quarter_gOpt, StartingDate_gDte, EndingDate_gDte);
                        end;
                    }
                    field(StartingDate_gDte; StartingDate_gDte)
                    {
                        ApplicationArea = Basic;
                        Caption = 'Start Date';
                        Editable = false;
                    }
                    field(EndingDate_gDte; EndingDate_gDte)
                    {
                        ApplicationArea = Basic;
                        Caption = 'End Date';
                        Editable = false;
                    }
                    field("Export Data"; ExportData_gOpt)
                    {
                        ApplicationArea = Basic;
                    }
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
        ExportData_lXml: XmlPort "Export GSTR ITC 04 JW To MFG";
    begin
        if ExportData_gOpt = Exportdata_gopt::Excel then
            CreateExcelBook_lFnc
        else begin
            Clear(ExportData_lXml);
            ExportData_lXml.CopyTmpTable_gFnc(BufferTableExportData_gRecTmp);
            ExportData_lXml.Run;
        end;
    end;

    trigger OnPreReport()
    begin
        if ExportData_gOpt = Exportdata_gopt::Excel then
            MakeExcelDataInfo_lFnc;
    end;

    var
        Text001: label 'GSTR ICT_04 JW To MFG';
        Text005: label 'Company Name';
        Text006: label 'Report No.';
        Text007: label 'Report Name';
        Text008: label 'User ID';
        Text009: label 'Date';
        MailTempItemEntry_gRecTmp: Record "Item Ledger Entry" temporary;
        ExcelBuffer_gRecTmp: Record "Excel Buffer" temporary;
        GSTINofJobWorkerJW_gCod: Code[15];
        StateUnregisteredJW_gTxt: Text[70];
        NatureofTransaction_gTxt: Text;
        ChallanNumber_gCod: Code[20];
        ChallanDate_gDte: Date;
        DescriptionofGoods_gTxt: Text[250];
        UniqueQuantityCode_gCod: Code[20];
        Quantity_gDec: Decimal;
        TaxableValue_gDec: Decimal;
        ExportData_gOpt: Option Excel,CSV;
        BufferTableExportData_gRecTmp: Record "Buffer Table Export Data_GSTR" temporary;
        LineNo_gInt: Integer;
        Quarter_gOpt: Option " ",Q1,Q2,Q3,Q4;
        Year_gInt: Integer;
        StartingDate_gDte: Date;
        EndingDate_gDte: Date;
        GSTRegNo_gCod: Text;
        GSTRCommonFunction_gCdu: Codeunit "GSTR Common Function";
        Win_gDlg: Dialog;
        Curr_gInt: Integer;


    procedure ClearVar_gFnc()
    begin
        GSTINofJobWorkerJW_gCod := '';
        StateUnregisteredJW_gTxt := '';
        NatureofTransaction_gTxt := '';
        ChallanNumber_gCod := '';
        ChallanDate_gDte := 0D;
        DescriptionofGoods_gTxt := '';
        UniqueQuantityCode_gCod := '';
        Quantity_gDec := 0;
        TaxableValue_gDec := 0;
    end;

    local procedure MakeExcelDataInfo_lFnc()
    begin
        ExcelBuffer_gRecTmp.SetUseInfoSheet;
        ExcelBuffer_gRecTmp.AddInfoColumn(Format(Text005), false, true, false, false, '', ExcelBuffer_gRecTmp."cell type"::Text);
        ExcelBuffer_gRecTmp.AddInfoColumn(COMPANYNAME, false, false, false, false, '', ExcelBuffer_gRecTmp."cell type"::Text);
        ExcelBuffer_gRecTmp.NewRow;
        ExcelBuffer_gRecTmp.AddInfoColumn(Format(Text007), false, true, false, false, '', ExcelBuffer_gRecTmp."cell type"::Text);
        ExcelBuffer_gRecTmp.AddInfoColumn(Format(Text001), false, false, false, false, '', ExcelBuffer_gRecTmp."cell type"::Text);
        ExcelBuffer_gRecTmp.NewRow;
        ExcelBuffer_gRecTmp.AddInfoColumn(Format(Text006), false, true, false, false, '', ExcelBuffer_gRecTmp."cell type"::Text);
        ExcelBuffer_gRecTmp.AddInfoColumn(Report::"GSTR ITC 04 JW To MFG", false, false, false, false, '', ExcelBuffer_gRecTmp."cell type"::Number);
        ExcelBuffer_gRecTmp.NewRow;
        ExcelBuffer_gRecTmp.AddInfoColumn(Format(Text008), false, true, false, false, '', ExcelBuffer_gRecTmp."cell type"::Text);
        ExcelBuffer_gRecTmp.AddInfoColumn(UserId, false, false, false, false, '', ExcelBuffer_gRecTmp."cell type"::Text);
        ExcelBuffer_gRecTmp.NewRow;
        ExcelBuffer_gRecTmp.AddInfoColumn(Format(Text009), false, true, false, false, '', ExcelBuffer_gRecTmp."cell type"::Text);
        ExcelBuffer_gRecTmp.AddInfoColumn(Today, false, false, false, false, '', ExcelBuffer_gRecTmp."cell type"::Date);
        ExcelBuffer_gRecTmp.NewRow;
        ExcelBuffer_gRecTmp.AddInfoColumn('GST Registration No.', false, true, false, false, '', ExcelBuffer_gRecTmp."cell type"::Text);
        ExcelBuffer_gRecTmp.AddInfoColumn(GSTRegNo_gCod, false, false, false, false, '', ExcelBuffer_gRecTmp."cell type"::Text);
        ExcelBuffer_gRecTmp.NewRow;
        ExcelBuffer_gRecTmp.AddInfoColumn('Quarter', false, true, false, false, '', ExcelBuffer_gRecTmp."cell type"::Text);
        ExcelBuffer_gRecTmp.AddInfoColumn(Format(Quarter_gOpt), false, false, false, false, '', ExcelBuffer_gRecTmp."cell type"::Text);
        ExcelBuffer_gRecTmp.NewRow;

        ExcelBuffer_gRecTmp.ClearNewRow;
        MakeExcelDataHeader_lFnc;
    end;

    local procedure MakeExcelDataHeader_lFnc()
    var
        i: Integer;
        j: Integer;
    begin
        ExcelBuffer_gRecTmp.NewRow;
        ExcelBuffer_gRecTmp.AddColumn('GSTIN of Job Worker (JW)', false, '', true, false, true, '', ExcelBuffer_gRecTmp."cell type"::Text);
        ExcelBuffer_gRecTmp.AddColumn('State (in case of unregistered JW)', false, '', true, false, true, '', ExcelBuffer_gRecTmp."cell type"::Text);
        ExcelBuffer_gRecTmp.AddColumn('Nature of Transaction', false, '', true, false, true, '', ExcelBuffer_gRecTmp."cell type"::Text);
        ExcelBuffer_gRecTmp.AddColumn('Original Challan Number', false, '', true, false, true, '', ExcelBuffer_gRecTmp."cell type"::Text);
        ExcelBuffer_gRecTmp.AddColumn('Original Challan Date', false, '', true, false, true, '', ExcelBuffer_gRecTmp."cell type"::Text);
        ExcelBuffer_gRecTmp.AddColumn('No.', false, '', true, false, true, '', ExcelBuffer_gRecTmp."cell type"::Text);
        ExcelBuffer_gRecTmp.AddColumn('Date', false, '', true, false, true, '', ExcelBuffer_gRecTmp."cell type"::Text);
        ExcelBuffer_gRecTmp.AddColumn('GSTIN', false, '', true, false, true, '', ExcelBuffer_gRecTmp."cell type"::Text);
        ExcelBuffer_gRecTmp.AddColumn('State (in case of unregistered JW)', false, '', true, false, true, '', ExcelBuffer_gRecTmp."cell type"::Text);
        ExcelBuffer_gRecTmp.AddColumn('No.', false, '', true, false, true, '', ExcelBuffer_gRecTmp."cell type"::Text);
        ExcelBuffer_gRecTmp.AddColumn('Date', false, '', true, false, true, '', ExcelBuffer_gRecTmp."cell type"::Text);
        ExcelBuffer_gRecTmp.AddColumn('Description of Goods', false, '', true, false, true, '', ExcelBuffer_gRecTmp."cell type"::Text);
        ExcelBuffer_gRecTmp.AddColumn('Unique Quantity Code (UQC)', false, '', true, false, true, '', ExcelBuffer_gRecTmp."cell type"::Text);
        ExcelBuffer_gRecTmp.AddColumn('Quantity', false, '', true, false, true, '', ExcelBuffer_gRecTmp."cell type"::Text);
        ExcelBuffer_gRecTmp.AddColumn('Taxable Value', false, '', true, false, true, '', ExcelBuffer_gRecTmp."cell type"::Text);
    end;

    local procedure MakeExcelDataBodyInv_lFnc()
    begin
        ExcelBuffer_gRecTmp.NewRow;
        ExcelBuffer_gRecTmp.AddColumn(GSTINofJobWorkerJW_gCod, false, '', false, false, false, '', ExcelBuffer_gRecTmp."cell type"::Text);
        ExcelBuffer_gRecTmp.AddColumn(StateUnregisteredJW_gTxt, false, '', false, false, false, '', ExcelBuffer_gRecTmp."cell type"::Text);
        ExcelBuffer_gRecTmp.AddColumn(NatureofTransaction_gTxt, false, '', false, false, false, '', ExcelBuffer_gRecTmp."cell type"::Text);
        ExcelBuffer_gRecTmp.AddColumn(ChallanNumber_gCod, false, '', false, false, false, '', ExcelBuffer_gRecTmp."cell type"::Text);
        ExcelBuffer_gRecTmp.AddColumn(ChallanDate_gDte, false, '', false, false, false, '', ExcelBuffer_gRecTmp."cell type"::Date);
        ExcelBuffer_gRecTmp.AddColumn('', false, '', false, false, false, '', ExcelBuffer_gRecTmp."cell type"::Text);
        ExcelBuffer_gRecTmp.AddColumn('', false, '', false, false, false, '', ExcelBuffer_gRecTmp."cell type"::Text);
        ExcelBuffer_gRecTmp.AddColumn('', false, '', false, false, false, '', ExcelBuffer_gRecTmp."cell type"::Text);
        ExcelBuffer_gRecTmp.AddColumn('', false, '', false, false, false, '', ExcelBuffer_gRecTmp."cell type"::Text);
        ExcelBuffer_gRecTmp.AddColumn('', false, '', false, false, false, '', ExcelBuffer_gRecTmp."cell type"::Text);
        ExcelBuffer_gRecTmp.AddColumn('', false, '', false, false, false, '', ExcelBuffer_gRecTmp."cell type"::Text);
        ExcelBuffer_gRecTmp.AddColumn(DescriptionofGoods_gTxt, false, '', false, false, false, '', ExcelBuffer_gRecTmp."cell type"::Text);
        ExcelBuffer_gRecTmp.AddColumn(UniqueQuantityCode_gCod, false, '', false, false, false, '', ExcelBuffer_gRecTmp."cell type"::Text);
        ExcelBuffer_gRecTmp.AddColumn(Quantity_gDec, false, '', false, false, false, '#,##0.00', ExcelBuffer_gRecTmp."cell type"::Number);
        ExcelBuffer_gRecTmp.AddColumn(TaxableValue_gDec, false, '', false, false, false, '#,##0.00', ExcelBuffer_gRecTmp."cell type"::Number);
    end;

    local procedure CreateExcelBook_lFnc()
    begin
        ExcelBuffer_gRecTmp.CreateNewBook('GSTR ITC_04 JW To MFG');
        ExcelBuffer_gRecTmp.WriteSheet('Data', CompanyName(), UserId());
        ExcelBuffer_gRecTmp.CloseBook();
        ExcelBuffer_gRecTmp.OpenExcel();

        // ExcelBuffer_gRecTmp.CreateBookAndOpenExcel('', 'GSTR ITC_04 JW To MFG', '', COMPANYNAME, UserId);
        // Error('');
    end;


    procedure InsertBufferTable_gFnc()
    begin
        LineNo_gInt += 1;
        BufferTableExportData_gRecTmp.Init;
        BufferTableExportData_gRecTmp."Line No." := LineNo_gInt;
        BufferTableExportData_gRecTmp."Code 1" := GSTINofJobWorkerJW_gCod;  //GSTIN of Job Worker(JW)
        BufferTableExportData_gRecTmp."Text 6" := StateUnregisteredJW_gTxt; // State (in case of unregistered JW)
        BufferTableExportData_gRecTmp."Text 8" := NatureofTransaction_gTxt; //Nature of Transaction
        BufferTableExportData_gRecTmp."Code 2" := ChallanNumber_gCod;       //Original Challan Number
        BufferTableExportData_gRecTmp."Date 1" := ChallanDate_gDte;         //Original Challan Date
        BufferTableExportData_gRecTmp."Text 11" := DescriptionofGoods_gTxt;  //Description of Goods
        BufferTableExportData_gRecTmp."Code 3" := UniqueQuantityCode_gCod;  //Unique Quantity Code (UQC)
        BufferTableExportData_gRecTmp."Decimal 1" := Quantity_gDec;            //Quantity
        BufferTableExportData_gRecTmp."Decimal 2" := TaxableValue_gDec;        //Taxable Value
        BufferTableExportData_gRecTmp.Insert(true);
    end;


    procedure GSTRPlaceOfSupply_lFnc(var Vendor_vRec: Record Vendor): Text[100]
    var
        State_lRec: Record State;
        Location_gTxt: Text;
        PlaceofSupplyOpt_lTxt: Text;
    begin
        State_lRec.Get(Vendor_vRec."State Code");
        State_lRec.TestField(Description);
        State_lRec.TestField("State Code (GST Reg. No.)");
        PlaceofSupplyOpt_lTxt := State_lRec."State Code (GST Reg. No.)" + '-' + State_lRec.Description;
        exit(PlaceofSupplyOpt_lTxt);
    end;


    procedure "------Find ILE-------"()
    begin
    end;

    local procedure FindAppliedEntry(ItemLedgEntry: Record "Item Ledger Entry")
    var
        ItemApplnEntry: Record "Item Application Entry";
    begin
        if ItemLedgEntry.Positive then begin
            ItemApplnEntry.Reset;
            ItemApplnEntry.SetCurrentkey("Inbound Item Entry No.", "Outbound Item Entry No.", "Cost Application");
            ItemApplnEntry.SetRange("Inbound Item Entry No.", ItemLedgEntry."Entry No.");
            ItemApplnEntry.SetFilter("Outbound Item Entry No.", '<>%1', 0);
            //ItemApplnEntry.SETRANGE("Cost Application",TRUE);
            if ItemApplnEntry.Find('-') then
                repeat
                    InsertTempEntry(ItemApplnEntry."Outbound Item Entry No.", ItemApplnEntry.Quantity);
                until ItemApplnEntry.Next = 0;
        end else begin
            ItemApplnEntry.Reset;
            ItemApplnEntry.SetCurrentkey("Outbound Item Entry No.", "Item Ledger Entry No.", "Cost Application");
            ItemApplnEntry.SetRange("Outbound Item Entry No.", ItemLedgEntry."Entry No.");
            ItemApplnEntry.SetRange("Item Ledger Entry No.", ItemLedgEntry."Entry No.");
            //ItemApplnEntry.SETRANGE("Cost Application",TRUE);
            if ItemApplnEntry.Find('-') then
                repeat
                    InsertTempEntry(ItemApplnEntry."Inbound Item Entry No.", -ItemApplnEntry.Quantity);
                until ItemApplnEntry.Next = 0;
        end;
    end;

    local procedure InsertTempEntry(EntryNo: Integer; AppliedQty: Decimal)
    var
        ItemLedgEntry: Record "Item Ledger Entry";
    begin
        ItemLedgEntry.Get(EntryNo);
        if AppliedQty * ItemLedgEntry.Quantity < 0 then
            exit;

        if not MailTempItemEntry_gRecTmp.Get(EntryNo) then begin
            MailTempItemEntry_gRecTmp.Init;
            MailTempItemEntry_gRecTmp := ItemLedgEntry;
            MailTempItemEntry_gRecTmp.Quantity := AppliedQty;
            MailTempItemEntry_gRecTmp.Insert;
        end else begin
            MailTempItemEntry_gRecTmp.Quantity := MailTempItemEntry_gRecTmp.Quantity + AppliedQty;
            MailTempItemEntry_gRecTmp.Modify;
        end;
    end;
}

