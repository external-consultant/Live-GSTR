XmlPort 76951 "Export GSTR ITC 04 MFG To JW"
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
                        GSTINofJobWorkerJW := 'GSTIN of Job Worker (JW)'
                    end;
                }
                textelement(StateInCaseOfUnregisteredJW)
                {

                    trigger OnBeforePassVariable()
                    begin
                        StateInCaseOfUnregisteredJW := 'State (in case of unregistered JW) '
                    end;
                }
                textelement(ChallanNumber)
                {

                    trigger OnBeforePassVariable()
                    begin
                        ChallanNumber := 'Challan Number '
                    end;
                }
                textelement(ChallanDate)
                {

                    trigger OnBeforePassVariable()
                    begin
                        ChallanDate := 'Challan Date'
                    end;
                }
                textelement(DescriptionOfGoods)
                {

                    trigger OnBeforePassVariable()
                    begin
                        DescriptionOfGoods := 'Description of Goods';
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
                textelement(TypesOfGoods)
                {

                    trigger OnBeforePassVariable()
                    begin
                        TypesOfGoods := 'Types of Goods';
                    end;
                }
                textelement(IntegratedTaxRatePer)
                {

                    trigger OnBeforePassVariable()
                    begin
                        IntegratedTaxRatePer := 'Integrated Tax Rate in (%)';
                    end;
                }
                textelement(CentralTaxRatePer)
                {

                    trigger OnBeforePassVariable()
                    begin
                        CentralTaxRatePer := 'Central Tax Rate in (%)';
                    end;
                }
                textelement(StateUTTaxRatePer)
                {

                    trigger OnBeforePassVariable()
                    begin
                        StateUTTaxRatePer := 'State/UT Tax Rate in (%)';
                    end;
                }
                textelement(Cess)
                {

                    trigger OnBeforePassVariable()
                    begin
                        Cess := 'Cess';
                    end;
                }
            }
            tableelement(integerbody; Integer)
            {
                XmlName = 'Body';
                textelement(GSTINofJobWorkerJWData)
                {
                }
                textelement(StateInCaseOfUnregisteredJWData)
                {
                }
                textelement(ChallanNumberData)
                {
                }
                textelement(ChallanDateData)
                {
                }
                textelement(DescriptionOfGoodsData)
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
                textelement(TypesOfGoodsData)
                {
                }
                textelement(IntegratedTaxRatePerData)
                {
                }
                textelement(CentralTaxRatePerData)
                {
                }
                textelement(StateUTTaxRatePerData)
                {
                }
                textelement(CessData)
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

                    GSTINofJobWorkerJWData := BufferTableExportData_gRecTmp."Code 1";               //GSTIN of Job Worker (JW)
                    StateInCaseOfUnregisteredJWData := BufferTableExportData_gRecTmp."Text 6";      //State (in case of unregistered JW)
                    ChallanNumberData := BufferTableExportData_gRecTmp."Code 2";                    //Challan Number
                    ChallanDateData := Format(BufferTableExportData_gRecTmp."Date 1");              //Challan Date
                    DescriptionOfGoodsData := BufferTableExportData_gRecTmp."Text 11";              //Description of Goods
                    UniqueQuantityCodeUQCData := BufferTableExportData_gRecTmp."Code 3";            //Unique Quantity Code (UQC)
                    QuantityData := Format(BufferTableExportData_gRecTmp."Decimal 1");              //Quantity
                    TaxableValueData := Format(BufferTableExportData_gRecTmp."Decimal 2");          //Taxable Value
                    TypesOfGoodsData := BufferTableExportData_gRecTmp."Text 8";                     //Types of Goods
                    IntegratedTaxRatePerData := Format(BufferTableExportData_gRecTmp."Decimal 3");  //Integrated Tax Rate in
                    CentralTaxRatePerData := Format(BufferTableExportData_gRecTmp."Decimal 4");     //CentralTaxRate in
                    StateUTTaxRatePerData := Format(BufferTableExportData_gRecTmp."Decimal 5");     //State/UTTaxRatein
                    CessData := Format(BufferTableExportData_gRecTmp."Decimal 6");                  //Cess
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


    procedure CopyTmpTable_gFnc(var BufferTableExportData_VRecTmp: Record "Buffer Table Export Data_GSTR" temporary)
    begin
        BufferTableExportData_VRecTmp.Reset;

        BufferTableExportData_gRecTmp.Reset;
        BufferTableExportData_gRecTmp.DeleteAll;

        BufferTableExportData_gRecTmp.Copy(BufferTableExportData_VRecTmp, true);
    end;
}

