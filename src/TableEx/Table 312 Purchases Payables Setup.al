tableextension 76957 PurchasesPayablesSetup_TabEx76 extends "Purchases & Payables Setup"
{
    fields
    {
        field(76951; "JV Receivable Nos."; Code[10])
        {
            Caption = 'JV Receivable Nos.';
            DataClassification = ToBeClassified;
            TableRelation = "No. Series";
        }
        field(76952; "JV Post on GSTB2B"; Boolean)
        {
            Caption = 'JV Post on GSTB2B';
            DataClassification = ToBeClassified;
        }
    }
}
