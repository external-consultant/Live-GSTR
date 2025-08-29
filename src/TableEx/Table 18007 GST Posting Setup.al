tableextension 76958 GSTPostingSetup_T76958 extends "GST Posting Setup"
{
    fields
    {
        field(76951; "JV Recevible Account"; Code[20])
        {
            Caption = 'JV Recevible Account';
            DataClassification = ToBeClassified;
            TableRelation = "G/L Account";
        }
        field(76952; "JV Payable Account"; Code[20])
        {
            Caption = 'JV Payable Account';
            DataClassification = ToBeClassified;
            TableRelation = "G/L Account";
        }
    }
}
