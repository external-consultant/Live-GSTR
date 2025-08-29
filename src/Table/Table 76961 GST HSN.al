Table 76961 "GST HSN"
{

    fields
    {
        field(76951; "Entry No."; Integer)
        {
            AutoIncrement = true;
            Editable = false;
        }
        field(76952; "GST Month"; Integer)
        {
            Editable = false;
            MaxValue = 12;
            MinValue = 1;
        }
        field(76953; "GST Year"; Integer)
        {
            Editable = false;
            MinValue = 2017;
        }
        field(76954; "GST Registration No."; Code[15])
        {
            Caption = 'GST Registration No.';
            Editable = false;
            TableRelation = "GST Registration Nos.";

            trigger OnValidate()
            var
                GSTRegistrationNos: Record "GST Registration Nos.";
            begin
            end;
        }
        field(76955; HSN; Code[20])
        {
        }
        field(76956; Description; Text[50])
        {
        }
        field(76957; UQC; Text[50])
        {
        }
        field(76958; "Total Quantity"; Decimal)
        {
            BlankZero = true;
        }
        field(76959; "Total Value"; Decimal)
        {
            BlankZero = true;
        }
        field(76960; "Taxable Value"; Decimal)
        {
            BlankZero = true;
        }
        field(76961; "Integrated Tax Amount"; Decimal)
        {
            BlankZero = true;
        }
        field(76962; "Central Tax Amount"; Decimal)
        {
            BlankZero = true;
        }
        field(76963; "State/UT Tax Amount"; Decimal)
        {
            BlankZero = true;
        }
        field(76964; "Cess Amount"; Decimal)
        {
            BlankZero = true;
        }
        field(76965; "GSTGroup Code"; Code[20])
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(76966; "GST %"; Decimal)
        {
            DataClassification = ToBeClassified;
            Description = 'T23698';
        }
    }

    keys
    {
        key(Key1; "Entry No.")
        {
            Clustered = true;
        }
        key(Key2; "GST Month", "GST Year")
        {
        }
    }

    fieldgroups
    {
    }
}

