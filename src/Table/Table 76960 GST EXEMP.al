Table 76960 "GST EXEMP"
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
        field(76955; Description; Text[50])
        {
        }
        field(76956; "Total Compsition"; Decimal)
        {
            BlankZero = true;
        }
        field(76957; "Nil Rated Supplies"; Decimal)
        {
            BlankZero = true;
        }
        field(76958; Exempted; Decimal)
        {
            BlankZero = true;
            Caption = 'Exempted (other than nil rated/non GST supply)';
        }
        field(76959; "Non-GST supplies"; Decimal)
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
    }

    fieldgroups
    {
    }
}

