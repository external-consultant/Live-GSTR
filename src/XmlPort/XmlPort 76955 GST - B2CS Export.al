XmlPort 76955 "GST - B2CS Export"
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
                XmlName = 'GSTB2BHeader';
                SourceTableView = sorting(Number) where(Number = const(1));
                textelement(TypeTitle)
                {

                    trigger OnBeforePassVariable()
                    begin
                        TypeTitle := 'Type';
                    end;
                }
                textelement(PlaceofSupplyTitle)
                {

                    trigger OnBeforePassVariable()
                    begin
                        PlaceofSupplyTitle := 'Place Of Supply';
                    end;
                }
                textelement(RateTitle)
                {

                    trigger OnBeforePassVariable()
                    begin
                        RateTitle := 'Rate';
                    end;
                }
                textelement(TaxableValueTitle)
                {

                    trigger OnBeforePassVariable()
                    begin
                        TaxableValueTitle := 'Taxable Value';
                    end;
                }
                textelement(CessAmountTitle)
                {

                    trigger OnBeforePassVariable()
                    begin
                        CessAmountTitle := 'Cess Amount';
                    end;
                }
                textelement(ECommerceGSTINTitle)
                {

                    trigger OnBeforePassVariable()
                    begin
                        ECommerceGSTINTitle := 'E-Commerce GSTIN';
                    end;
                }
            }
            tableelement("GST - B2CS"; "GST - B2CS")
            {
                XmlName = 'GSTB2CS';
                SourceTableView = sorting("Entry No.");
                fieldelement(InvoiceType; "GST - B2CS".Type)
                {
                }
                fieldelement(PlaceofSupply; "GST - B2CS"."Place of Supply")
                {
                }
                textelement(Rate)
                {
                }
                textelement(TaxableValue)
                {
                }
                textelement(CessAmount)
                {
                }
                fieldelement(ECommerceGSTIN; "GST - B2CS"."E-Commerce GSTIN")
                {
                }

                trigger OnAfterGetRecord()
                begin
                    Curr_gIn += 1;
                    if not HideWinDialog_gBln then
                        Window_gDlg.Update(2, Curr_gIn);

                    Rate := GSTRCommonFunction_gCdu.ConvertDecimal_gFnc("GST - B2CS".Rate);
                    TaxableValue := GSTRCommonFunction_gCdu.ConvertDecimal_gFnc("GST - B2CS"."Taxable Value");
                    CessAmount := GSTRCommonFunction_gCdu.ConvertDecimal_gFnc("GST - B2CS"."Cess Amount");
                end;

                trigger OnPreXmlItem()
                begin
                    if not HideWinDialog_gBln then
                        Window_gDlg.Update(1, "GST - B2CS".Count);
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
        GSTB2CS_lRec: Record "GST - B2CS";
        Window_gDlg: Dialog;
        Curr_gIn: Integer;
        GSTRCommonFunction_gCdu: Codeunit "GSTR Common Function";
        HideWinDialog_gBln: Boolean;


    procedure HideWinDialog_gFnc()
    begin
        HideWinDialog_gBln := true;
    end;
}

