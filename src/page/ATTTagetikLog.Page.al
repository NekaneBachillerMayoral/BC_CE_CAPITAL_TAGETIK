page 60050 "ATT Tagetik Log"
{
    PageType = List;
    UsageCategory = None;
    SourceTable = "ATT Tagetik Log";
    Editable = false;
    Caption = 'Tagetik Log', comment = 'ESP="Log Tagetik"';

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("ATT Entry No."; Rec."ATT Entry No.")
                {
                    ApplicationArea = All;
                }
                field("ATT Tagetik Type"; Rec."ATT Tagetik Type")
                {
                    ApplicationArea = All;
                }
                field("ATT User"; Rec."ATT User")
                {
                    ApplicationArea = All;
                }
                field("ATT Init DateTime"; Rec."ATT Init DateTime")
                {
                    ApplicationArea = All;
                }
                field("ATT Ending DateTime"; Rec."ATT Ending DateTime")
                {
                    ApplicationArea = All;
                }
                field("ATT In Execution"; Rec."ATT In Execution")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
}