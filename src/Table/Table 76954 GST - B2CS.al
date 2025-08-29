Table 76954 "GST - B2CS"
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
        field(76955; Type; Option)
        {
            OptionCaption = 'OE,E';
            OptionMembers = OE,E;
        }
        field(76956; "Place of Supply"; Text[100])
        {
        }
        field(76957; Rate; Decimal)
        {
            BlankZero = true;
        }
        field(76958; "Taxable Value"; Decimal)
        {
            BlankZero = true;
        }
        field(76959; "Cess Amount"; Decimal)
        {
            BlankZero = true;
        }
        field(76960; "E-Commerce GSTIN"; Code[20])
        {
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

