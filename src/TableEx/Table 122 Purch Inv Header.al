tableextension 76954 "Purch.Inv.Header_TabEx76954" extends "Purch. Inv. Header"
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
        // field(76953; "Vendor Invoice Date"; Date)
        // {
        //     Caption = 'Vendor Invoice Date';
        //     DataClassification = ToBeClassified;
        // }
    }
}
