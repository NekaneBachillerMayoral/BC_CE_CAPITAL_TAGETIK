page 50112 "ATT Dim. Set Entry - Tagetik"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "Dimension Set Entry";
    Caption = 'Dimension Set Entry', comment = 'ESP="Mov. grupo dimensiones"';
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("Dimension Set ID"; Rec."Dimension Set ID")
                {
                    ApplicationArea = All;
                }
                field("Dimension Code"; Rec."Dimension Code")
                {
                    ApplicationArea = All;
                }
                field("Dimension Value Code"; Rec."Dimension Value Code")
                {
                    ApplicationArea = All;
                }
                field("Dimension Value ID"; Rec."Dimension Value ID")
                {
                    ApplicationArea = All;
                }
                field("Dimension Name"; Rec."Dimension Name")
                {
                    ApplicationArea = All;
                }
                field("Dimension Value Name"; Rec."Dimension Value Name")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
}
