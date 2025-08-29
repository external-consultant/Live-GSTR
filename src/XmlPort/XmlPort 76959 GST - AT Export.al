XmlPort 76959 "GST - AT Export"
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
                textelement(GrossAdvanceRecdTitle)
                {

                    trigger OnBeforePassVariable()
                    begin
                        GrossAdvanceRecdTitle := 'Gross Advance Received';
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
            tableelement("GST AT"; "GST AT")
            {
                XmlName = 'GSTAT';
                SourceTableView = sorting("Entry No.");
                fieldelement(PlaceofSupply; "GST AT"."Place of Supply")
                {
                }
                textelement(Rate)
                {
                }
                textelement(GrossAdvanceRecd)
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

                    Rate := GSTRCommonFunction_gCdu.ConvertDecimal_gFnc("GST AT".Rate);
                    GrossAdvanceRecd := GSTRCommonFunction_gCdu.ConvertDecimal_gFnc("GST AT"."Gross Advance Received");
                    CessAmount := GSTRCommonFunction_gCdu.ConvertDecimal_gFnc("GST AT"."Cess Amount");
                end;

                trigger OnPreXmlItem()
                begin
                    if not HideWinDialog_gBln then
                        Window_gDlg.Update(1, "GST AT".Count);
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
        GSTAT_gRec: Record "GST AT";
        Window_gDlg: Dialog;
        Curr_gIn: Integer;
        GSTRCommonFunction_gCdu: Codeunit "GSTR Common Function";
        HideWinDialog_gBln: Boolean;


    procedure HideWinDialog_gFnc()
    begin
        HideWinDialog_gBln := true;
    end;
}

