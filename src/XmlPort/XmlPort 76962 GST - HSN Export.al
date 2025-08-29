XmlPort 76962 "GST - HSN Export"
{
    Direction = Export;
    FieldDelimiter = '<None>';
    Format = VariableText;
    RecordSeparator = '<NewLine>';
    TableSeparator = '<NewLine>';
    TextEncoding = WINDOWS;
    UseRequestPage = false;

    schema
    {
        textelement(Root)
        {
            tableelement(Integer; Integer)
            {
                XmlName = 'GSTHSNHeader';
                SourceTableView = sorting(Number) where(Number = const(1));
                textelement(HSNTitle)
                {

                    trigger OnBeforePassVariable()
                    begin
                        HSNTitle := 'HSN';
                    end;
                }
                textelement(DescriptionTitle)
                {

                    trigger OnBeforePassVariable()
                    begin
                        DescriptionTitle := 'Description';
                    end;
                }
                textelement(UQCTitle)
                {

                    trigger OnBeforePassVariable()
                    begin
                        UQCTitle := 'UQC';
                    end;
                }
                textelement(TotalQuantityTitle)
                {

                    trigger OnBeforePassVariable()
                    begin
                        TotalQuantityTitle := 'Total Quantity';
                    end;
                }
                textelement(TotalValueTitle)
                {

                    trigger OnBeforePassVariable()
                    begin
                        TotalValueTitle := 'Total Value';
                    end;
                }
                textelement(RateTitle)
                {

                    trigger OnBeforePassVariable()
                    begin
                        RateTitle := 'Rate'; //T23698-N
                    end;
                }
                textelement(TaxableValueTitle)
                {

                    trigger OnBeforePassVariable()
                    begin
                        TaxableValueTitle := 'Taxable Value';
                    end;
                }
                textelement(IntegratedTaxAmountTitle)
                {

                    trigger OnBeforePassVariable()
                    begin
                        IntegratedTaxAmountTitle := 'Integrated Tax Amount';
                    end;
                }
                textelement(CentralTaxAmountTitle)
                {

                    trigger OnBeforePassVariable()
                    begin
                        CentralTaxAmountTitle := 'Central Tax Amount';
                    end;
                }
                textelement(StateUTTaxAmountTitle)
                {

                    trigger OnBeforePassVariable()
                    begin
                        StateUTTaxAmountTitle := 'State/UT Tax Amount';
                    end;
                }
                textelement(CessAmountTitle)
                {

                    trigger OnBeforePassVariable()
                    begin
                        CessAmountTitle := 'Cess Amount';
                    end;
                }
            }
            tableelement("GST HSN"; "GST HSN")
            {
                XmlName = 'GSTHSN';
                SourceTableView = sorting("Entry No.");
                fieldelement(HSN; "GST HSN".HSN)
                {
                }
                fieldelement(Description; "GST HSN".Description)
                {
                }
                fieldelement(UQC; "GST HSN".UQC)
                {
                }
                textelement(TotalQuantity)
                {
                }
                textelement(TotalValue)
                {
                }
                textelement(Rate)
                {
                }
                textelement(TaxableValue)
                {
                }
                textelement(IntegratedTaxAmount)
                {
                }
                textelement(CentralTaxAmount)
                {
                }
                textelement(StateUTTaxAmount)
                {
                }
                textelement(CessAmount)
                {
                }

                trigger OnAfterGetRecord()
                begin
                    Curr_gIn += 1;
                    if not HideWinDialog_gBln then
                        Window_gDlg.Update(2, Curr_gIn);
                    TotalQuantity := GSTRCommonFunction_gCdu.ConvertDecimal_gFnc("GST HSN"."Total Quantity");
                    TotalValue := GSTRCommonFunction_gCdu.ConvertDecimal_gFnc("GST HSN"."Total Value");
                    TaxableValue := GSTRCommonFunction_gCdu.ConvertDecimal_gFnc("GST HSN"."Taxable Value");
                    IntegratedTaxAmount := GSTRCommonFunction_gCdu.ConvertDecimal_gFnc("GST HSN"."Integrated Tax Amount");
                    CentralTaxAmount := GSTRCommonFunction_gCdu.ConvertDecimal_gFnc("GST HSN"."Central Tax Amount");
                    StateUTTaxAmount := GSTRCommonFunction_gCdu.ConvertDecimal_gFnc("GST HSN"."State/UT Tax Amount");
                    CessAmount := GSTRCommonFunction_gCdu.ConvertDecimal_gFnc("GST HSN"."Cess Amount");
                    Rate := GSTRCommonFunction_gCdu.ConvertDecimal_gFnc("GST HSN"."GST %"); //T23698-N
                end;

                trigger OnPreXmlItem()
                begin
                    if not HideWinDialog_gBln then
                        Window_gDlg.Update(1, "GST HSN".Count);
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
        if not HideWinDialog_gBln then
            Window_gDlg.Close;
    end;

    trigger OnPreXmlPort()
    begin
        if not HideWinDialog_gBln then
            Window_gDlg.Open('Total Lines #1###########\Current Line #2##########');
    end;

    var
        GSTHSN_gRec: Record "GST HSN";
        Window_gDlg: Dialog;
        Curr_gIn: Integer;
        GSTRCommonFunction_gCdu: Codeunit "GSTR Common Function";
        HideWinDialog_gBln: Boolean;


    procedure HideWinDialog_gFnc()
    begin
        HideWinDialog_gBln := true;
    end;
}

