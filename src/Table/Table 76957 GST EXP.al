Table 76957 "GST EXP"
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
        field(76955; "Export Type"; Option)
        {
            OptionCaption = 'WOPAY,WPAY';
            OptionMembers = WOPAY,WPAY;
        }
        field(76956; "Invoice Number"; Code[20])
        {
        }
        field(76957; "Invoice date"; Date)
        {
        }
        field(76958; "Invoice Value"; Decimal)
        {
            BlankZero = true;
        }
        field(76959; "Port Code"; Code[10])
        {
        }
        field(76960; "Shipping Bill Number"; Code[20])
        {
        }
        field(76961; "Shipping Bill Date"; Date)
        {
        }
        field(76962; Rate; Decimal)
        {
            BlankZero = true;
        }
        field(76963; "Taxable Value"; Decimal)
        {
            BlankZero = true;
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
        key(Key3; "Invoice Number", Rate)
        {
        }
    }

    fieldgroups
    {
    }
}

