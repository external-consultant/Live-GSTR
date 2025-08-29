XmlPort 76952 "Export GSTR ITC 04 JW To MFG"
{
    Direction = Export;
    Format = VariableText;
    RecordSeparator = '<NewLine>';
    TableSeparator = '<NewLine>';
    TextEncoding = WINDOWS;

    schema
    {
        textelement(Root)
        {
            tableelement(Integer; Integer)
            {
                XmlName = 'Header';
                SourceTableView = sorting(Number) where(Number = const(1));
                textelement(GSTINofJobWorkerJW)
                {

                    trigger OnBeforePassVariable()
                    begin
                        GSTINofJobWorkerJW := 'GSTIN of Job Worker(JW)'
                    end;
                }
                textelement(StateincaseofunregisteredJW)
                {

                    trigger OnBeforePassVariable()
                    begin
                        StateincaseofunregisteredJW := 'State (in case of unregistered JW)'
                    end;
                }
                textelement(NatureofTransaction)
                {

                    trigger OnBeforePassVariable()
                    begin
                        NatureofTransaction := 'Nature of Transaction'
                    end;
                }
                textelement(OriginalChallanNumber)
                {

                    trigger OnBeforePassVariable()
                    begin
                        OriginalChallanNumber := 'Original Challan Number'
                    end;
                }
                textelement(OriginalChallanDate)
                {

                    trigger OnBeforePassVariable()
                    begin
                        OriginalChallanDate := 'Original Challan Date';
                    end;
                }
                textelement(No)
                {

                    trigger OnBeforePassVariable()
                    begin
                        No := 'No';
                    end;
                }
                textelement(Date)
                {

                    trigger OnBeforePassVariable()
                    begin
                        Date := 'Date';
                    end;
                }
                textelement(GSTIN)
                {

                    trigger OnBeforePassVariable()
                    begin
                        GSTIN := 'GSTIN';
                    end;
                }
                textelement(StateincaseofunregisteredJW_)
                {

                    trigger OnBeforePassVariable()
                    begin
                        StateincaseofunregisteredJW_ := 'State (in case of unregistered JW)';
                    end;
                }
                textelement(No_)
                {

                    trigger OnBeforePassVariable()
                    begin
                        No_ := 'No';
                    end;
                }
                textelement(Date_)
                {

                    trigger OnBeforePassVariable()
                    begin
                        Date_ := 'Date';
                    end;
                }
                textelement(DescriptionofGoods)
                {

                    trigger OnBeforePassVariable()
                    begin
                        DescriptionofGoods := 'Description of Goods';
                    end;
                }
                textelement(UniqueQuantityCodeUQC)
                {

                    trigger OnBeforePassVariable()
                    begin
                        UniqueQuantityCodeUQC := 'Unique Quantity Code (UQC)';
                    end;
                }
                textelement(Quantity)
                {

                    trigger OnBeforePassVariable()
                    begin
                        Quantity := 'Quantity';
                    end;
                }
                textelement(TaxableValue)
                {

                    trigger OnBeforePassVariable()
                    begin
                        TaxableValue := 'Taxable Value';
                    end;
                }
            }
            tableelement(integerbody; Integer)
            {
                XmlName = 'Body';
                textelement(GSTINofJobWorkerJWData)
                {
                }
                textelement(StateincaseofunregisteredJWData)
                {
                }
                textelement(NatureofTransactionData)
                {
                }
                textelement(OriginalChallanNumberData)
                {
                }
                textelement(OriginalChallanDateData)
                {
                }
                textelement(NoData)
                {
                }
                textelement(DateData)
                {
                }
                textelement(GSTINData)
                {
                }
                textelement(StateincaseofunregisteredJWData_)
                {
                }
                textelement(NoData_)
                {
                }
                textelement(DateData_)
                {
                }
                textelement(DescriptionofGoodsData)
                {
                }
                textelement(UniqueQuantityCodeUQCData)
                {
                }
                textelement(QuantityData)
                {
                }
                textelement(TaxableValueData)
                {
                }

                trigger OnAfterGetRecord()
                begin
                    if IntegerBody.Number = 1 then
                        BufferTableExportData_gRecTmp.FindSet
                    else
                        BufferTableExportData_gRecTmp.Next;

                    Curr_gIn += 1;
                    Window_gDlg.Update(2, Curr_gIn);

                    InsertDataBody_lFnc;
                end;

                trigger OnPreXmlItem()
                begin
                    BufferTableExportData_gRecTmp.Reset;
                    IntegerBody.SetRange(Number, 1, BufferTableExportData_gRecTmp.Count);

                    Window_gDlg.Update(1, BufferTableExportData_gRecTmp.Count);
                end;
            }
        }
    }

    requestpage
    {

        layout
        {
        }

        actions
        {
        }
    }

    trigger OnPostXmlPort()
    begin
        Window_gDlg.Close;
    end;

    trigger OnPreXmlPort()
    begin
        Window_gDlg.Open('Total Lines #1###########\Current Line #2##########');
    end;

    var
        Window_gDlg: Dialog;
        Curr_gIn: Integer;
        BufferTableExportData_gRecTmp: Record "Buffer Table Export Data_GSTR" temporary;

    local procedure InsertDataBody_lFnc()
    begin
        GSTINofJobWorkerJWData := BufferTableExportData_gRecTmp."Code 1";            //GSTIN of Job Worker(JW)
        StateincaseofunregisteredJWData := BufferTableExportData_gRecTmp."Text 6";            // State (in case of unregistered JW)
        NatureofTransactionData := BufferTableExportData_gRecTmp."Text 8";            //Nature of Transaction
        OriginalChallanNumberData := BufferTableExportData_gRecTmp."Code 2";            //Original Challan Number
        OriginalChallanDateData := Format(BufferTableExportData_gRecTmp."Date 1");    //Original Challan Date
        DescriptionofGoodsData := BufferTableExportData_gRecTmp."Text 11";           //Description of Goods
        UniqueQuantityCodeUQCData := BufferTableExportData_gRecTmp."Code 3";            //Unique Quantity Code (UQC)
        QuantityData := Format(BufferTableExportData_gRecTmp."Decimal 1"); //Quantity
        TaxableValueData := Format(BufferTableExportData_gRecTmp."Decimal 2"); //Taxable Value
    end;


    procedure CopyTmpTable_gFnc(var BufferTableExportData_VRecTmp: Record "Buffer Table Export Data_GSTR" temporary)
    begin
        BufferTableExportData_VRecTmp.Reset;

        BufferTableExportData_gRecTmp.Reset;
        BufferTableExportData_gRecTmp.DeleteAll;

        BufferTableExportData_gRecTmp.Copy(BufferTableExportData_VRecTmp, true);
    end;
}

