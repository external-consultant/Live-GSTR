XmlPort 76960 "GST - ATADJ Export"
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
                textelement(GrossAdvanceAdjdTitle)
                {

                    trigger OnBeforePassVariable()
                    begin
                        GrossAdvanceAdjdTitle := 'Gross Advance Adjusted';
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
            tableelement("GST ATADJ"; "GST ATADJ")
            {
                XmlName = 'GSTADADJ';
                SourceTableView = sorting("Entry No.");
                fieldelement(PlaceofSupply; "GST ATADJ"."Place of Supply")
                {
                }
                textelement(Rate)
                {
                }
                textelement(GrossAdvanceAdjd)
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

                    Rate := GSTRCommonFunction_gCdu.ConvertDecimal_gFnc("GST ATADJ".Rate);
                    GrossAdvanceAdjd := GSTRCommonFunction_gCdu.ConvertDecimal_gFnc("GST ATADJ"."Gross Advance Adjusted");
                    CessAmount := GSTRCommonFunction_gCdu.ConvertDecimal_gFnc("GST ATADJ"."Cess Amount");
                end;

                trigger OnPreXmlItem()
                begin
                    if not HideWinDialog_gBln then
                        Window_gDlg.Update(1, "GST ATADJ".Count);
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
        GSTATADJ_gRec: Record "GST ATADJ";
        Window_gDlg: Dialog;
        Curr_gIn: Integer;
        GSTRCommonFunction_gCdu: Codeunit "GSTR Common Function";
        HideWinDialog_gBln: Boolean;


    procedure HideWinDialog_gFnc()
    begin
        HideWinDialog_gBln := true;
    end;
}

