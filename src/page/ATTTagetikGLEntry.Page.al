page 50042 "ATT Tagetik G/L Entry"
{
    ApplicationArea = All;
    Caption = 'Tagetik GL Entry', comment = 'ESP="Mov. Contabilidad Tagetik"';
    PageType = List;
    SourceTable = "ATT Tagetik G/L Entry";
    UsageCategory = Lists;
    Editable = false;
    Permissions = tabledata "G/L Entry" = r;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("ATT Entry No."; Rec."ATT Entry No.")
                {
                    ApplicationArea = All;
                }
                field("ATT Company"; Rec."ATT Company")
                {
                    ApplicationArea = All;
                }
                field("ATT Last GL Entry No."; Rec."ATT Last GL Entry No.")
                {
                    ApplicationArea = All;
                }
                field("ATT G/L Account No."; Rec."ATT G/L Account No.")
                {
                    ApplicationArea = All;
                }
                field("ATT G/L Account Name"; Rec."ATT G/L Account Name")
                {
                    ApplicationArea = All;
                }
                field("ATT Posting Date"; Rec."ATT Posting Date")
                {
                    ApplicationArea = All;
                }
                field("ATT Account Nature"; Rec."ATT Account Nature")
                {
                    ApplicationArea = All;
                }
                field("ATT Account Type"; Rec."ATT Account Type")
                {
                    ApplicationArea = All;
                }
                field("ATT Account Conv. Type"; Rec."ATT Account Conv. Type")
                {
                    ApplicationArea = All;
                }
                field("ATT LCY Code"; Rec."ATT LCY Code")
                {
                    ApplicationArea = All;
                }
                field("ATT Amount"; Rec."ATT Amount")
                {
                    ApplicationArea = All;
                }
                field("ATT Cost Center Code"; Rec."ATT Cost Center Code")
                {
                    ApplicationArea = All;
                }
                field("ATT Cost Center Name"; Rec."ATT Cost Center Name")
                {
                    ApplicationArea = All;
                }
                field("ATT IC Code"; Rec."ATT IC Code")
                {
                    ApplicationArea = All;
                }
                field("ATT IC Name"; Rec."ATT IC Name")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            group(Tagetik)
            {
                action(LoadData)
                {
                    ApplicationArea = All;
                    Caption = 'Load data', comment = 'ESP="Cargar datos"';
                    Image = Process;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedOnly = true;

                    trigger OnAction()
                    var
                        vLTagetikType: Enum "ATT Tagetik Type";
                        Window: Dialog;
                        WindowText_Txt: Label 'Processing..', comment = 'ESP="Procesando.."';
                        LocalText001_Txt: Label 'Process ended.', comment = 'ESP="Proceso finalizado."';
                    begin
                        Window.Open(WindowText_Txt);

                        Rec.CheckTagetik();
                        Rec.LoadTagetikGLEntries(vLTagetikType::Manual);

                        Window.Close();
                        Message(LocalText001_Txt);
                    end;
                }
                action(ClearData)
                {
                    ApplicationArea = All;
                    Caption = 'Clear data', comment = 'ESP="Limpiar datos"';
                    Image = Delete;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedOnly = true;

                    trigger OnAction()
                    var
                        rLTagetikGLEntry: Record "ATT Tagetik G/L Entry";
                        LocalText001_Txt: Label 'Process ended.', comment = 'ESP="Proceso finalizado."';
                    begin
                        Rec.CheckTagetik();

                        rLTagetikGLEntry.Reset();
                        rLTagetikGLEntry.DeleteAll(true);
                        Message(LocalText001_Txt);
                    end;
                }
                action(TagetikLog)
                {
                    ApplicationArea = All;
                    Caption = 'Tagetik Log', comment = 'ESP="Log Tagetik"';
                    Image = Log;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedOnly = true;
                    RunObject = page "ATT Tagetik Log";
                }
            }
        }
    }
}