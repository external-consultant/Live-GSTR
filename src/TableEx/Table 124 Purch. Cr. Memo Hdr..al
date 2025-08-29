tableextension 76955 PurchCrMemoHdr_TabEx76955 extends "Purch. Cr. Memo Hdr."
{
    fields
    {
        field(76951; "GSTR-1/IFF/GSTR-5 Period"; Text[10])
        {
            Caption = 'GSTR-1/IFF/GSTR-5 Period';
            DataClassification = ToBeClassified;
        }
        field(76952; "GSTR Force Matched Reversed"; Boolean)
        {
            Caption = 'GSTR Force Matched Reversed';
            DataClassification = ToBeClassified;
        }
    }
}
