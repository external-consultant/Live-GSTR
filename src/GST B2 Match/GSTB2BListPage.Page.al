Page 76952 "GSTB2B List Page"
{
    DeleteAllowed = true;
    InsertAllowed = false;
    PageType = Worksheet;
    SourceTable = GSTB2BXMLPort_;
    SourceTableView = sorting("Entry No.")
                      order(descending)
                      where(Post = filter(false));

    layout
    {
        area(content)
        {
            group(Option)
            {
                Caption = 'Option';
                field(ReturnFileMonth; ReturnFileMonth)
                {
                    ApplicationArea = Basic;
                    Caption = 'Return File Month';
                    MaxValue = 12;
                    MinValue = 1;

                    trigger OnValidate()
                    begin
                        CurrPage.SaveRecord;
                        CurrPage.Update(false);
                    end;
                }
                field(ReturnFileYear; ReturnFileYear)
                {
                    ApplicationArea = Basic;
                    Caption = 'Return File Year';
                    MaxValue = 9999;
                    MinValue = 2017;
                }
            }
            repeater(Group)
            {
                field("Entry No."; Rec."Entry No.")
                {
                    ApplicationArea = Basic;
                }
                field("GSTIN of supplier"; Rec."GSTIN of supplier")
                {
                    ApplicationArea = Basic;
                }
                field("Trade/Legal name"; Rec."Trade/Legal name")
                {
                    ApplicationArea = Basic;
                }
                field("Invoice Number"; Rec."Invoice Number")
                {
                    ApplicationArea = Basic;
                }
                field("Invoice Date"; Rec."Invoice Date")
                {
                    ApplicationArea = Basic;
                }
                field("Invoice Value"; Rec."Invoice Value")
                {
                    ApplicationArea = Basic;
                }
                field("Taxable Value"; Rec."Taxable Value")
                {
                    ApplicationArea = Basic;
                }
                field("Integrated Tax"; Rec."Integrated Tax")
                {
                    ApplicationArea = Basic;
                }
                field("Central Tax"; Rec."Central Tax")
                {
                    ApplicationArea = Basic;
                }
                field("State/UT Tax"; Rec."State/UT Tax")
                {
                    ApplicationArea = Basic;
                }
                field("TOTAL GST"; Rec."TOTAL GST")
                {
                    ApplicationArea = Basic;
                }
                field("GSTR-1/IFF/GSTR-5 Period"; Rec."GSTR-1/IFF/GSTR-5 Period")
                {
                    ApplicationArea = Basic;
                }
                field("Credit Availed"; Rec."Credit Availed")
                {
                    ApplicationArea = Basic;
                }
                field(Checked; Rec.Checked)
                {
                    ApplicationArea = Basic;
                }
                field("Invoice Match"; Rec."Invoice Match")
                {
                    ApplicationArea = Basic;
                }
                field("Matching Error"; Rec."Matching Error")
                {
                    ApplicationArea = Basic;
                    StyleExpr = Style_gTxt;
                }
                field("Document Type"; Rec."Document Type")
                {
                    ApplicationArea = Basic;
                }
                field("Matched Invoice No."; Rec."Matched Invoice No.")
                {
                    ApplicationArea = Basic;
                }
                field("Force Match Invoice No."; Rec."Force Match Invoice No.")
                {
                    ApplicationArea = Basic;
                }
                field("Forced Match Remarks"; Rec."Forced Match Remarks")
                {
                    ApplicationArea = Basic;
                }
                field("Forced Match"; Rec."Forced Match")
                {
                    ApplicationArea = Basic;
                }
                field("Return File Month"; Rec."Return File Month")
                {
                    ApplicationArea = Basic;
                    Editable = false;
                }
                field(Control33027952; Rec.Post)
                {
                    ApplicationArea = Basic;
                    Editable = false;
                    Enabled = false;
                }
                field(Remarks; Rec.Remarks)
                {
                    ApplicationArea = Basic;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Import File")
            {
                ApplicationArea = Basic;
                Image = Import;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    ImportItemJournalRM_lXml: XmlPort "GSTB2B Import";
                begin

                    Clear(ImportItemJournalRM_lXml);
                    ImportItemJournalRM_lXml.Run;
                    CurrPage.Update;
                end;
            }
            action("Match Invoice ")
            {
                ApplicationArea = Basic;
                Image = CheckDuplicates;
                Promoted = true;
                PromotedCategory = Category5;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    GSTB2BMgt_lCdu: Codeunit "GSTB2B Mgt.";
                begin
                    if ReturnFileMonth = 0 then Error('Invalid Month');
                    if ReturnFileYear = 0 then Error('Invalid Year');
                    Clear(GSTB2BMgt_lCdu);
                    GSTB2BMgt_lCdu.MatchingInvoice_gFnc(ReturnFileMonth, ReturnFileYear);
                end;
            }
            action("Forced Match Invoice ")
            {
                ApplicationArea = Basic;
                Image = CheckDuplicates;
                Promoted = true;
                PromotedCategory = Category5;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    GSTB2BMgt_lCdu: Codeunit "GSTB2B Mgt.";
                begin
                    if ReturnFileMonth = 0 then Error('Invalid Month');
                    if ReturnFileYear = 0 then Error('Invalid Year');
                    Clear(GSTB2BMgt_lCdu);
                    GSTB2BMgt_lCdu.ManuallyMatch_gFnc(Rec, ReturnFileMonth, ReturnFileYear);
                end;
            }
            action("View Matched Invoice")
            {
                ApplicationArea = Basic;
                Image = ViewCheck;
                Promoted = true;
                PromotedCategory = Category4;

                trigger OnAction()
                var
                    MatchedGSTB2BListPage_lPge: Page "Matched GSTB2B List Page";
                begin
                    Clear(MatchedGSTB2BListPage_lPge);
                    MatchedGSTB2BListPage_lPge.Run;
                end;
            }
            action("Unmatch Entry")
            {
                ApplicationArea = Basic;

                trigger OnAction()
                var
                    GSTB2BMgt1_lCdu: Codeunit "GSTB2B Mgt.";
                begin
                    Clear(GSTB2BMgt1_lCdu);
                    GSTB2BMgt1_lCdu.UndoMatch_gFnc(Rec, Rec."Entry No.");
                end;
            }
            action(Post)
            {
                ApplicationArea = Basic;

                trigger OnAction()
                var
                    GSTB2BMgt_lCdu: Codeunit "GSTB2B Mgt.";
                    GSTB2BPost_lRpt: Report "GSTB2B Post";
                    PostingDate_lDte: Date;
                    GSTB2BXMLPort_lRec: Record GSTB2BXMLPort_;
                begin
                    if ReturnFileMonth = 0 then Error('Invalid Month');
                    if ReturnFileYear = 0 then Error('Invalid Year');

                    PostingDate_lDte := 0D;
                    Clear(GSTB2BPost_lRpt);
                    GSTB2BPost_lRpt.RunModal;
                    PostingDate_lDte := GSTB2BPost_lRpt.GetRejComm_gFnc;

                    if PostingDate_lDte = 0D then
                        Error('Posting Date is mandatory');

                    GSTB2BXMLPort_lRec.Reset;
                    CurrPage.SetSelectionFilter(GSTB2BXMLPort_lRec);

                    Clear(GSTB2BMgt_lCdu);
                    GSTB2BMgt_lCdu.SetPostingDate_gDte(PostingDate_lDte);
                    GSTB2BMgt_lCdu.PostMatch_gFnc(Rec, ReturnFileMonth, ReturnFileYear);
                end;
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        Style_gTxt := '';
        if Rec."Matching Error" <> '' then
            Style_gTxt := 'Attention';
    end;

    var
        Style_gTxt: Text;
        ReturnFileMonth: Integer;
        ReturnFileYear: Integer;
}

