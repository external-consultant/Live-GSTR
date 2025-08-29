Report 76963 "GSTR ITC 04 MFG To JW"
{
    ProcessingOnly = true;

    dataset
    {
        dataitem("Delivery Challan Line"; "Delivery Challan Line")
        {
            DataItemTableView = sorting("Delivery Challan No.", "Line No.");

            trigger OnAfterGetRecord()
            var
                Vendor_lRec: Record Vendor;
                ILE_lRec: Record "Item Ledger Entry";
                Item_lRec: Record Item;
                Location_lRec: Record Location;
                UnitCost_lDec: Decimal;
            begin
                Curr_gInt += 1;
                Win_gDlg.Update(2, Curr_gInt);

                ClearValue_gFnc;

                if "Delivery Challan Line"."Vendor No." <> '' then
                    Vendor_lRec.Get("Delivery Challan Line"."Vendor No.")
                else begin
                    Location_lRec.Get("Delivery Challan Line"."Vendor Location");
                    Location_lRec.TestField("Subcontractor No.");
                    Vendor_lRec.Get(Location_lRec."Subcontractor No.");
                end;

                GSTINofJobWorkerJW_gCod := Vendor_lRec."GST Registration No.";
                StateUnregisteredJW_gTxt := GSTRPlaceOfSupply_lFnc(Vendor_lRec);
                ChallanNumber_gCod := CopyStr("Delivery Challan No.", 1, 16);  //First 16 Char Only Allowed
                ChallanDate_gDte := "Posting Date";
                DescriptionofGoods_gTxt := Description;
                UniqueQuantityCode_gCod := GSTRCommonFunction_gCdu.GetUOMDescriptionITC04_gFnc("Unit of Measure");
                Quantity_gDec := Quantity;

                ILE_lRec.Reset;
                ILE_lRec.SetRange("Entry Type", ILE_lRec."entry type"::Transfer);
                ILE_lRec.SetRange("Location Code", "Vendor Location");
                ILE_lRec.SetRange("External Document No.", "Delivery Challan No.");
                ILE_lRec.SetRange("Item No.", "Item No.");
                ILE_lRec.SetRange("Subcon Order No.", "Document No.");
                ILE_lRec.FindFirst;
                ILE_lRec.CalcFields("Cost Amount (Expected)", "Cost Amount (Actual)");
                UnitCost_lDec := (ILE_lRec."Cost Amount (Expected)" + ILE_lRec."Cost Amount (Actual)") / Abs(ILE_lRec.Quantity);
                TaxableValue_gDec := ROUND(UnitCost_lDec * Quantity, 0.01);

                TypesofGoods_gTxt := 'Inputs';

                Item_lRec.Get("Item No.");
                Item_lRec.TestField("GST Group Code");
                if Item_lRec."GST Group Code" <> '' then begin
                    // GSTSetup_gRec.Reset;
                    // GSTSetup_gRec.SetRange("GST Group Code", Item_lRec."GST Group Code");
                    // if UpperCase(StateUnregisteredJW_gTxt) <> '24-GUJARAT' then begin
                    //     GSTSetup_gRec.SetRange("GST Component Code", 'IGST');
                    //     GSTSetup_gRec.FindLast;
                    //     IntegratedTaxRate_gDec := GSTSetup_gRec."GST Component %";
                    // end else begin
                    //     GSTSetup_gRec.SetRange("GST Component Code", 'SGST');
                    //     GSTSetup_gRec.FindLast;
                    //     StateUTTaxRate_gDec := GSTSetup_gRec."GST Component %";

                    //     GSTSetup_gRec.SetRange("GST Component Code", 'CGST');
                    //     GSTSetup_gRec.FindLast;
                    //     CentralTaxRate_gDec := GSTSetup_gRec."GST Component %";
                    // end;
                end;

                if ExportData_gOpt = Exportdata_gopt::Excel then
                    MakeExcelDataBodyInv_lFnc
                else
                    InsertBufferTable_gFnc;
            end;

            trigger OnPostDataItem()
            begin
                Win_gDlg.Close;
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

                SetRange("GST Registration No.", GSTRegNo_gCod);
                SetRange("Posting Date", StartingDate_gDte, EndingDate_gDte);
                Win_gDlg.Open('Total Record #1##################\Current #2######################');
                Win_gDlg.Update(1, Count);

                BufferTableExportData_gRecTmp.Reset;
                BufferTableExportData_gRecTmp.DeleteAll;
                DocNo_gInt := 0;
                LineNo_gInt := 0;
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
        ExportData_lXml: XmlPort "Export GSTR ITC 04 MFG To JW";
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
        Text001: label 'GSTR ICT_04 MFG To JW';
        Text005: label 'Company Name';
        Text006: label 'Report No.';
        Text007: label 'Report Name';
        Text008: label 'User ID';
        Text009: label 'Date';
        GSTSetup_gRec: Record "GST Setup";
        ExcelBuffer_gRecTmp: Record "Excel Buffer" temporary;
        GSTINofJobWorkerJW_gCod: Code[15];
        StateUnregisteredJW_gTxt: Text[70];
        ChallanNumber_gCod: Code[16];
        ChallanDate_gDte: Date;
        DescriptionofGoods_gTxt: Text[250];
        UniqueQuantityCode_gCod: Code[20];
        Quantity_gDec: Decimal;
        TaxableValue_gDec: Decimal;
        TypesofGoods_gTxt: Text[50];
        IntegratedTaxRate_gDec: Decimal;
        CentralTaxRate_gDec: Decimal;
        StateUTTaxRate_gDec: Decimal;
        Cess_gDec: Decimal;
        Quarter_gOpt: Option " ",Q1,Q2,Q3,Q4;
        Year_gInt: Integer;
        StartingDate_gDte: Date;
        EndingDate_gDte: Date;
        GSTRegNo_gCod: Text;
        GSTRCommonFunction_gCdu: Codeunit "GSTR Common Function";
        Win_gDlg: Dialog;
        Curr_gInt: Integer;
        BufferTableExportData_gRecTmp: Record "Buffer Table Export Data_GSTR" temporary;
        DocNo_gInt: Integer;
        LineNo_gInt: Integer;
        ExportData_gOpt: Option Excel,CSV;


    procedure ClearValue_gFnc()
    begin
        GSTINofJobWorkerJW_gCod := '';
        StateUnregisteredJW_gTxt := '';
        ChallanNumber_gCod := '';
        ChallanDate_gDte := 0D;
        DescriptionofGoods_gTxt := '';
        UniqueQuantityCode_gCod := '';
        Quantity_gDec := 0;
        TaxableValue_gDec := 0;
        TypesofGoods_gTxt := '';
        IntegratedTaxRate_gDec := 0;
        CentralTaxRate_gDec := 0;
        StateUTTaxRate_gDec := 0;
        Cess_gDec := 0;
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
        ExcelBuffer_gRecTmp.AddInfoColumn(Report::"GSTR ITC 04 MFG To JW", false, false, false, false, '', ExcelBuffer_gRecTmp."cell type"::Number);
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
        ExcelBuffer_gRecTmp.AddColumn('Challan Number', false, '', true, false, true, '', ExcelBuffer_gRecTmp."cell type"::Text);
        ExcelBuffer_gRecTmp.AddColumn('Challan Date', false, '', true, false, true, '', ExcelBuffer_gRecTmp."cell type"::Text);
        ExcelBuffer_gRecTmp.AddColumn('Description of Goods', false, '', true, false, true, '', ExcelBuffer_gRecTmp."cell type"::Text);
        ExcelBuffer_gRecTmp.AddColumn('Unique Quantity Code (UQC) ', false, '', true, false, true, '', ExcelBuffer_gRecTmp."cell type"::Text);
        ExcelBuffer_gRecTmp.AddColumn('Quantity', false, '', true, false, true, '', ExcelBuffer_gRecTmp."cell type"::Text);
        ExcelBuffer_gRecTmp.AddColumn('Taxable Value', false, '', true, false, true, '', ExcelBuffer_gRecTmp."cell type"::Text);
        ExcelBuffer_gRecTmp.AddColumn('Types of Goods', false, '', true, false, true, '', ExcelBuffer_gRecTmp."cell type"::Text);
        ExcelBuffer_gRecTmp.AddColumn('Integrated Tax Rate in (%)', false, '', true, false, true, '', ExcelBuffer_gRecTmp."cell type"::Text);
        ExcelBuffer_gRecTmp.AddColumn('Central Tax Rate in (%)', false, '', true, false, true, '', ExcelBuffer_gRecTmp."cell type"::Text);
        ExcelBuffer_gRecTmp.AddColumn('State/UT Tax Rate in (%)', false, '', true, false, true, '', ExcelBuffer_gRecTmp."cell type"::Text);
        ExcelBuffer_gRecTmp.AddColumn('Cess', false, '', true, false, true, '', ExcelBuffer_gRecTmp."cell type"::Text);
    end;

    local procedure MakeExcelDataBodyInv_lFnc()
    begin
        ExcelBuffer_gRecTmp.NewRow;
        ExcelBuffer_gRecTmp.AddColumn(GSTINofJobWorkerJW_gCod, false, '', false, false, false, '', ExcelBuffer_gRecTmp."cell type"::Text);
        ExcelBuffer_gRecTmp.AddColumn(StateUnregisteredJW_gTxt, false, '', false, false, false, '', ExcelBuffer_gRecTmp."cell type"::Text);
        ExcelBuffer_gRecTmp.AddColumn(ChallanNumber_gCod, false, '', false, false, false, '', ExcelBuffer_gRecTmp."cell type"::Text);
        ExcelBuffer_gRecTmp.AddColumn(ChallanDate_gDte, false, '', false, false, false, '', ExcelBuffer_gRecTmp."cell type"::Date);
        ExcelBuffer_gRecTmp.AddColumn(DescriptionofGoods_gTxt, false, '', false, false, false, '', ExcelBuffer_gRecTmp."cell type"::Text);
        ExcelBuffer_gRecTmp.AddColumn(UniqueQuantityCode_gCod, false, '', false, false, false, '', ExcelBuffer_gRecTmp."cell type"::Text);
        ExcelBuffer_gRecTmp.AddColumn(Quantity_gDec, false, '', false, false, false, '#,##0.00', ExcelBuffer_gRecTmp."cell type"::Number);
        ExcelBuffer_gRecTmp.AddColumn(TaxableValue_gDec, false, '', false, false, false, '#,##0.00', ExcelBuffer_gRecTmp."cell type"::Number);
        ExcelBuffer_gRecTmp.AddColumn(TypesofGoods_gTxt, false, '', false, false, false, '', ExcelBuffer_gRecTmp."cell type"::Text);
        ExcelBuffer_gRecTmp.AddColumn(IntegratedTaxRate_gDec, false, '', false, false, false, '', ExcelBuffer_gRecTmp."cell type"::Text);
        ExcelBuffer_gRecTmp.AddColumn(CentralTaxRate_gDec, false, '', false, false, false, '', ExcelBuffer_gRecTmp."cell type"::Text);
        ExcelBuffer_gRecTmp.AddColumn(StateUTTaxRate_gDec, false, '', false, false, false, '', ExcelBuffer_gRecTmp."cell type"::Text);
        ExcelBuffer_gRecTmp.AddColumn(Cess_gDec, false, '', false, false, false, '#,##0.00', ExcelBuffer_gRecTmp."cell type"::Number);
    end;

    local procedure CreateExcelBook_lFnc()
    begin
        ExcelBuffer_gRecTmp.CreateNewBook('GSTR ITC_04 MFG To JW');
        ExcelBuffer_gRecTmp.WriteSheet('Data', CompanyName(), UserId());
        ExcelBuffer_gRecTmp.CloseBook();
        ExcelBuffer_gRecTmp.OpenExcel();

        // ExcelBuffer_gRecTmp.CreateBookAndOpenExcel('', 'GSTR ITC_04 MFG To JW', '', COMPANYNAME, UserId);
        // Error('');
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


    procedure InsertBufferTable_gFnc()
    begin
        LineNo_gInt += 1;
        BufferTableExportData_gRecTmp.Init;
        BufferTableExportData_gRecTmp."Line No." := LineNo_gInt;
        BufferTableExportData_gRecTmp."Code 1" := GSTINofJobWorkerJW_gCod;      //GSTIN of Job Worker (JW)
        BufferTableExportData_gRecTmp."Text 6" := StateUnregisteredJW_gTxt;     //State (in case of unregistered JW)
        BufferTableExportData_gRecTmp."Code 2" := ChallanNumber_gCod;           //Challan Number
        BufferTableExportData_gRecTmp."Date 1" := ChallanDate_gDte;             //Challan Date
        BufferTableExportData_gRecTmp."Text 11" := DescriptionofGoods_gTxt;      //Description of Goods
        BufferTableExportData_gRecTmp."Code 3" := UniqueQuantityCode_gCod;      //Unique Quantity Code (UQC)
        BufferTableExportData_gRecTmp."Decimal 1" := Quantity_gDec;                //Quantity
        BufferTableExportData_gRecTmp."Decimal 2" := TaxableValue_gDec;            //Taxable Value
        BufferTableExportData_gRecTmp."Text 8" := TypesofGoods_gTxt;            //Types of Goods
        BufferTableExportData_gRecTmp."Decimal 3" := IntegratedTaxRate_gDec;       //Integrated Tax Rate in
        BufferTableExportData_gRecTmp."Decimal 4" := CentralTaxRate_gDec;          //CentralTaxRate in
        BufferTableExportData_gRecTmp."Decimal 5" := StateUTTaxRate_gDec;          //State/UTTaxRatein
        BufferTableExportData_gRecTmp."Decimal 6" := Cess_gDec;                    //Cess
        BufferTableExportData_gRecTmp.Insert(true);
    end;
}

