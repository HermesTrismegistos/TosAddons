--DEVELOPERCONSOLE
local acutil = require("acutil");

DEVELOPERCONSOLE_SETTINGSLOCATION = string.format('../addons/%s/settings.json', "developerconsole")
DEVELOPERCONSOLE_TEMPTEXTLOCATION = string.format('../addons/%s/temptext.txt', "developerconsole")
DEVELOPERCONSOLE_SETTINGS = DEVELOPERCONSOLE_SETTINGS or {}
DEVELOPERCONSOLE_DEBUG = true
DEVELOPERCONSOLE_CURSOR = 0
DEVELOPERCONSOLE_INTELLI = false
DEVELOPERCONSOLE_INTELLI_COUNT = 0
DEVELOPERCONSOLE_INTELLI_TABLE=nil
DEVELOPERCONSOLE_INTELLI_STR = ""
DEVELOPERCONSOLE_INTELLI_ITERATOR = nil
DEVELOPERCONSOLE_INTELLI_ITERATOR_KEY = nil
DEVELOPERCONSOLE_INTELLI_SELECT=0
local lstr = loadstring or load
function EBI_try_catch(what)
    local status, result = pcall(what.try)
    if not status then
        what.catch(result)
    end
    return result
end
local function ERROUT(msg)
    EBI_try_catch{
        try = function()
            CHAT_SYSTEM(msg)
            print(msg)
        end,
        catch = function(error)
        end
    }

end
function string.starts(String, Start)
    return string.sub(String, 1, string.len(Start)) == Start
end

function DEVELOPERCONSOLE_ON_INIT(addon, frame)
    acutil.slashCommand("/dev", DEVELOPERCONSOLE_TOGGLE_FRAME);
    acutil.slashCommand("/console", DEVELOPERCONSOLE_TOGGLE_FRAME);
    acutil.slashCommand("/devconsole", DEVELOPERCONSOLE_TOGGLE_FRAME);
    acutil.slashCommand("/developerconsole", DEVELOPERCONSOLE_TOGGLE_FRAME);
    
    acutil.setupHook(DEVELOPERCONSOLE_PRINT_TEXT, "print");
    acutil.addSysIcon('developerconsole', 'sysmenu_sys', 'developerconsole', 'DEVELOPERCONSOLE_TOGGLE_FRAME')
    if not DEVELOPERCONSOLE_SETTINGSLOADED then
        DEVELOPERCONSOLE_SETTINGS = {
            history = {}
        }
        local t, err = acutil.loadJSON(DEVELOPERCONSOLE_SETTINGSLOCATION, DEVELOPERCONSOLE_SETTINGS)
        if err then
            --設定ファイル読み込み失敗時処理
            CHAT_SYSTEM(string.format('[%s] cannot load setting files', "developerconsole"))
        else
            --設定ファイル読み込み成功時処理
            DEVELOPERCONSOLE_SETTINGS = t
        end
        DEVELOPERCONSOLE_SETTINGSLOADED = true
    end
    DEVELOPERCONSOLE_LOG = {}
    DEVELOPERCONSOLE_RESIZE()
    CLEAR_CONSOLE();
end
function DEVELOPERCONSOLE_SAVE_SETTINGS()
    
    acutil.saveJSON(DEVELOPERCONSOLE_SETTINGSLOCATION, DEVELOPERCONSOLE_SETTINGS)
end
function DEVELOPERCONSOLE_TOGGLE_FRAME()
    ui.ToggleFrame("developerconsole");
end

function DEVELOPERCONSOLE_OPEN()
    
    DEVELOPERCONSOLE_INIT()

end
function DEVELOPERCONSOLE_INIT()
    EBI_try_catch{
        try = function()
            local frame = ui.GetFrame("developerconsole");
            local textViewLog = frame:GetChild("textview_log");
            textViewLog:ShowWindow(1);
            textViewLog:SetEventScript(ui.RBUTTONUP, "DEVELOPERCONSOLE_LOG_ON_RCLICK")
            frame:ShowTitleBar(0);
            --devconsole:ShowTitleBarFrame(1);
            frame:SetSkinName("chat_window");
            frame:EnableMove(1);
            frame:SetEventScript(ui.RESIZE, "DEVELOPERCONSOLE_ON_RESIZE")
            frame:SetEventScript(ui.RBUTTONDOWN, "DEVELOPERCONSOLE_DEBUG_RELOAD")
            if DEVELOPERCONSOLE_SETTINGS.x ~= nil then
                frame:SetOffset(DEVELOPERCONSOLE_SETTINGS.x, DEVELOPERCONSOLE_SETTINGS.y)
                frame:Resize(DEVELOPERCONSOLE_SETTINGS.w, DEVELOPERCONSOLE_SETTINGS.h)
            
            end
            local textViewLog = frame:GetChild("textview_log");
            local input = frame:GetChild("input");
            AUTO_CAST(input)
            input:SetEnableEditTag(1)
            --trick
            input:SetFontName("white_16_ol")
            --input:SetFormat("{@st42b}{s16}{#FFFFFF}%s{/}")
            --input:SetFontName("")
            input:SetTypingScp('DEVELOPERCONSOLE_ON_TYPE');
            
            local execute = frame:GetChild("execute");
            execute:SetEventScript(ui.LBUTTONUP, "DEVELOPERCONSOLE_ENTER_KEY")
            local btnopt = frame:CreateOrGetControl("button", "btnopt", 0, 0, 0, 0)
            btnopt:SetEventScript(ui.LBUTTONUP, "DEVELOPERCONSOLE_CONTEXT")
            btnopt:SetText("...")
            local timer = GET_CHILD(frame, "addontimer", "ui::CAddOnTimer");
            timer:SetUpdateScript("DEVELOPERCONSOLE_UPDATE");
            timer:Start(0.01);
            DEVELOPERCONSOLE_RESIZE()
            local isf = ui.GetFrame("developerconsoleintellisense")
            isf:SetSkinName("bg")
            isf:Resize(400, 300)
            local list = isf:GetChild("triggers");
            AUTO_CAST(list)
            list:SetOffset(0, 0)
            list:Resize(400, 300)
            list:SetEventScript(ui.LBUTTONUP,"DEVELOPERCONSOLE_DETERMINE_INTELLI")
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function DEVELOPERCONSOLE_DEBUG_RELOAD()
    local ebi = "E:\\\\ToSProject\\\\TosAddons\\\\developerconsoleex\\\\src\\\\addon_d.ipf\\\\developerconsole\\\\developerconsole.lua"
    if DEVELOPERCONSOLE_DEBUG then
        local f = assert(lstr('dofile("' .. ebi .. '")'));
        local status, error = pcall(f);
        if not status then
            CHAT_SYSTEM(tostring(error));
        else
            CHAT_SYSTEM("RELOADED DC")
            DEVELOPERCONSOLE_INIT()
        end
    end
end
function DEVELOPERCONSOLE_RESIZE()
    EBI_try_catch{
        try = function()
            local frame = ui.GetFrame("developerconsole");
            local textViewLog = frame:GetChild("textview_log");
            local input = frame:GetChild("input");
            local execute = frame:GetChild("execute");
            local btnopt = frame:GetChild("btnopt")
            local w = frame:GetWidth()
            local h = frame:GetHeight()
            local m = 10
            local btm = 30
            textViewLog:SetOffset(m, m)
            textViewLog:Resize(w - m * 2, h - m * 2 - btm)
            
            input:SetOffset(m, h - m - btm)
            --trick
            input:Resize(w - m * 2 - 40, 40)
            input:Invalidate()
            input:Resize(w - m * 2 - 40, 30)
            
            
            execute:SetOffset(w - 70 - m, h - m - btm)
            execute:Resize(40, 30)
            
            btnopt:SetOffset(w - 30 - m, h - m - btm)
            btnopt:Resize(30, 30)
        
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function DEVELOPERCONSOLE_LOG_ON_RCLICK()
    local frame = ui.GetFrame("developerconsole");
    local context = ui.CreateContextMenu("Context", "", 0, 0, 300, 100)
    ui.AddContextMenuItem(context, "Copy", "DEVELOPERCONSOLE_COPY()")
    context:Resize(100, context:GetHeight())
    ui.OpenContextMenu(context)
end
function DEVELOPERCONSOLE_COPY()
    local f
    EBI_try_catch{
        try = function()
            local frame = ui.GetFrame("developerconsole");
            local textViewLog = frame:GetChild("textview_log");
            local text = ""
            -- f = io.open(DEVELOPERCONSOLE_TEMPTEXTLOCATION, "w")
            for _, v in ipairs(DEVELOPERCONSOLE_LOG) do
                text = text .. v .. "\n"
            --f:write(text .. "\n")
            end
            -- f:close()
            --local s = DEVELOPERCONSOLE_TEMPTEXTLOCATION:gsub("/", "\\")
            --debug.ShellExecute("notepad \"" .. s .. "\"")
            ui.WriteClipboardText(text)
        end,
        catch = function(error)
            ERROUT(error)
        -- f:close()
        end
    }
end
function DEVELOPERCONSOLE_ON_TYPE()
    local frame = ui.GetFrame("developerconsole");
    local input = frame:GetChild("input");
    local text = input:GetCursurLeftText();
    if ui.IsFrameVisible("developerconsoleintellisense") == 1 then
        if (text:match("([%w_%.])$") ~= nil) then
            DEVELOPERCONSOLE_INTELLISENSE(frame)
        else
            ui.CloseFrame("developerconsoleintellisense")
        end
    end
end
function DEVELOPERCONSOLE_SAVE_OFFSET()
    local frame = ui.GetFrame("developerconsole");
    DEVELOPERCONSOLE_SETTINGS.x = frame:GetX()
    DEVELOPERCONSOLE_SETTINGS.y = frame:GetY()
    DEVELOPERCONSOLE_SETTINGS.w = frame:GetWidth()
    DEVELOPERCONSOLE_SETTINGS.h = frame:GetHeight()
    DEVELOPERCONSOLE_SAVE_SETTINGS()
end
function DEVELOPERCONSOLE_ON_RESIZE()
    DEVELOPERCONSOLE_RESIZE()
end
function DEVELOPERCONSOLE_CONTEXT()
    local frame = ui.GetFrame("developerconsole");
    local context = ui.CreateContextMenu("Context", "", 0, 0, 300, 100)
    ui.AddContextMenuItem(context, "Clear Console", "CLEAR_CONSOLE()")
    ui.AddContextMenuItem(context, "Do File", "DEVELOPERCONSOLE_DOFILE_CHOOSE()")
    ui.AddContextMenuItem(context, "Debug Frame", "TOGGLE_UI_DEBUG()")
    ui.AddContextMenuItem(context, "{} to <>", "DEVELOPERCONSOLE_ESCAPEBRACKET()")
    ui.AddContextMenuItem(context, "<> to {}", "DEVELOPERCONSOLE_SURROUNDBRACKET()")
    ui.AddContextMenuItem(context, "Show Explorer", "DEVELOPERCONSOLE_EXPLORER()")
    context:Resize(300, context:GetHeight())
    ui.OpenContextMenu(context)
end
function DEVELOPERCONSOLE_DOFILE_CHOOSE(frame)
    local frame = ui.GetFrame("developerconsole");
    INPUT_STRING_BOX_CB(frame, "Input the path of lua script", "DEVELOPERCONSOLE_DOFILE", "", nil, nil, 260, false)
end
function DEVELOPERCONSOLE_DOFILE(frame, argStr)
    EBI_try_catch{
        try = function()
            
            local s = string.gsub(argStr, "\\", "\\\\")
            local text
            if string.find(s, "\"") ~= nil then
                text = "dofile(" .. s .. ");"
            else
                text = "dofile(\"" .. s .. "\");"
            end
            
            local input = frame:GetChild("input");
            input:SetText(text)
        end,
        catch = function(error)
            ERROUT(error)
        
        end
    }
end
function DEVELOPERCONSOLE_EXPLORER(frame)
    debug.OpenDataDir("")
end
function DEVELOPERCONSOLE_ESCAPEBRACKET(frame)
    local textview_log = GET_CHILD(frame, "textview_log", "ui::CTextView")
    textview_log:Clear()
    local text = DEVELOPERCONSOLE_LOG or {}
    DEVELOPERCONSOLE_LOG = {}
    for i, k in ipairs(text) do
        local s = k;
        s = string.gsub(s, "{", "<")
        s = string.gsub(s, "}", ">")
        
        DEVELOPERCONSOLE_ADDTEXT(s)
    end
end
function DEVELOPERCONSOLE_SURROUNDBRACKET(frame)
    local input = frame:GetChild("input");
    local curtext = input:GetText()
    if (curtext == nil) then
        curtext = ""
    end
    INPUT_STRING_BOX_CB(frame, "<> will be replaced to {}{nl}(Immediate Execute)", "DEVELOPERCONSOLE_SURROUNDBRACKET_EXEC", curtext, nil, nil, 65536, false)
end
function DEVELOPERCONSOLE_SURROUNDBRACKET_EXEC(frame, argStr)
    
    
    local s = argStr;
    s = string.gsub(s, "<", "{")
    s = string.gsub(s, ">", "}")
    
    DEVELOPERCONSOLE_EXEC(nil, s, argStr)
end
function DEVELOPERCONSOLE_CLOSE()
    local frame = ui.GetFrame("developerconsole");
    if (frame ~= nil) then
        local timer = GET_CHILD(frame, "addontimer", "ui::CAddOnTimer");
        timer:Stop();
    end
end

function TOGGLE_UI_DEBUG()
    debug.ToggleUIDebug();
end

function CLEAR_CONSOLE()
    local frame = ui.GetFrame("developerconsole");
    
    if frame ~= nil then
        local textlog = frame:GetChild("textview_log");
        
        if textlog ~= nil then
            tolua.cast(textlog, "ui::CTextView");
            textlog:Clear();
            DEVELOPERCONSOLE_LOG = {}
        end
    end
end
function DEVELOPERCONSOLE_ADDTEXT(text)
    if (text) then
        local frame = ui.GetFrame("developerconsole");
        local textlog = frame:GetChild("textview_log");
        tolua.cast(textlog, "ui::CTextView");
        textlog:AddText(text, "white_16_ol");
        DEVELOPERCONSOLE_LOG[#DEVELOPERCONSOLE_LOG + 1] = text
    end
end
function DEVELOPERCONSOLE_PRINT_TEXT(text)
    if text == nil or text == "" then
        return;
    end
    
    local frame = ui.GetFrame("developerconsole");
    local textlog = frame:GetChild("textview_log");
    
    if textlog ~= nil then
        tolua.cast(textlog, "ui::CTextView");
        DEVELOPERCONSOLE_ADDTEXT(text);
    end
end
function DEVELOPERCONSOLE_INTELLISENSE()
    EBI_try_catch{
        try = function()
            local frame=ui.GetFrame("developerconsole")
            local isf = ui.GetFrame("developerconsoleintellisense")
            local input = frame:GetChild("input");
            AUTO_CAST(input)
            isf:ShowWindow(1)
            isf:SetOffset(frame:GetX() + input:GetX() + math.min(#input:GetCursurLeftText() * 8, frame:GetWidth()), frame:GetY() + input:GetY() + input:GetHeight())
            local list = isf:GetChild("triggers");
            AUTO_CAST(list)
            list:ClearItemAll()
            
            --絞り込み
            DEVELOPERCONSOLE_INTELLI = true
            local tbl1=string.match(input:GetCursurLeftText():lower(), "([%w_%.%s]-)%.[%w_%s]*$")
            local tbl2=string.match(input:GetCursurLeftText():lower(), "([%w_%s]-)$")
            local tbl=tbl1 or tbl2 or "_G"
            --validate
            local f = lstr("return ("..tbl..")");
            local status, error = pcall(f);
            if(not status or type(error)=="function")then
                tbl=_G
            else
                tbl=error or _G
            end
            
            DEVELOPERCONSOLE_INTELLI_TABLE=tbl
            DEVELOPERCONSOLE_INTELLI_STR = string.match(input:GetCursurLeftText():lower(), "[%w_]-$") or ""
            DEVELOPERCONSOLE_INTELLI_ITERATOR = pairs(DEVELOPERCONSOLE_INTELLI_TABLE)
            DEVELOPERCONSOLE_INTELLI_ITERATOR_KEY = nil
            DEVELOPERCONSOLE_INTELLI_COUNT = 0
            DEVELOPERCONSOLE_INTELLI_SELECT=0
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function DEVELOPERCONSOLE_DETERMINE_INTELLI()
    local frame=ui.GetFrame("developerconsole")
    local isf = ui.GetFrame("developerconsoleintellisense")
    local input = frame:GetChild("input");
    local s=string.match(input:GetCursurLeftText(),"(.-)[%w_]*$") or input:GetCursurLeftText()
    local list = isf:GetChild("triggers");
    AUTO_CAST(list)
    if(list:GetSelItemIndex()>=0)then
        input:SetText(s..list:GetSelItemText()..input:GetCursurRightText())
    end
    ReserveScript('ui.CloseFrame("developerconsoleintellisense")',0.01)
end
function DEVELOPERCONSOLE_UPDATE(frame)
    EBI_try_catch{
        try = function()
            
            local doupdate = nil
            if ui.IsFrameVisible("developerconsoleintellisense") == 0 then
                if (DEVELOPERCONSOLE_KEYDOWNFLAG == false) then
                    if 1 == keyboard.IsKeyPressed("UP") then
                        --previous
                        if (DEVELOPERCONSOLE_CURSOR < (#DEVELOPERCONSOLE_SETTINGS.history - 1)) then
                            DEVELOPERCONSOLE_CURSOR = DEVELOPERCONSOLE_CURSOR + 1
                        end
                        
                        doupdate = DEVELOPERCONSOLE_SETTINGS.history[#DEVELOPERCONSOLE_SETTINGS.history - DEVELOPERCONSOLE_CURSOR]
                        
                        DEVELOPERCONSOLE_KEYDOWNFLAG = true
                    elseif 1 == keyboard.IsKeyPressed("DOWN") then
                        
                        --new
                        if (DEVELOPERCONSOLE_CURSOR > 0) then
                            DEVELOPERCONSOLE_CURSOR = DEVELOPERCONSOLE_CURSOR - 1
                        elseif DEVELOPERCONSOLE_CURSOR < 0 then
                            DEVELOPERCONSOLE_CURSOR = 0
                        end
                        
                        doupdate = DEVELOPERCONSOLE_SETTINGS.history[#DEVELOPERCONSOLE_SETTINGS.history - DEVELOPERCONSOLE_CURSOR]
                        DEVELOPERCONSOLE_KEYDOWNFLAG = true
                    end
                    if (doupdate ~= nil) then
                        
                        local textlog = frame:GetChild("textview_log");
                        local editbox = frame:GetChild("input");
                        tolua.cast(editbox, "ui::CEditControl");
                        editbox:SetText(doupdate)
                    
                    end
                else
                    if 1 == keyboard.IsKeyPressed("UP") then
                        
                        elseif 1 == keyboard.IsKeyPressed("DOWN") then
                        
                        else
                            DEVELOPERCONSOLE_KEYDOWNFLAG = false
                    end
                end
                
                if 1 == keyboard.IsKeyDown("LBRACKET") and (keyboard.IsKeyPressed("LALT") == 1 or keyboard.IsKeyPressed("RALT") == 1) then
                    local editbox = frame:GetChild("input");
                    tolua.cast(editbox, "ui::CEditControl");
                    editbox:SetText(editbox:GetText() .. "｛")
                end
                if 1 == keyboard.IsKeyDown("RBRACKET") and (keyboard.IsKeyPressed("LALT") == 1 or keyboard.IsKeyPressed("RALT") == 1) then
                    local editbox = frame:GetChild("input");
                    tolua.cast(editbox, "ui::CEditControl");
                    editbox:SetText(editbox:GetText() .. "｝")
                end
                if 1 == keyboard.IsKeyDown("ENTER") and (keyboard.IsKeyPressed("LALT") == 1 or keyboard.IsKeyPressed("RALT") == 1) then
                    
                    DEVELOPERCONSOLE_ENTER_KEY(frame)
                end
                if 1 == keyboard.IsKeyDown("SPACE") and (keyboard.IsKeyPressed("LCTRL") == 1 or keyboard.IsKeyPressed("RCTRL") == 1) then
                    local editbox = frame:GetChild("input");
                    tolua.cast(editbox, "ui::CEditControl");
                    --最後のスペースを消す
                    editbox:SetText(editbox:GetCursurLeftText():sub(1, -2) .. editbox:GetCursurRightText())
                    DEVELOPERCONSOLE_INTELLISENSE(frame)
                end
            end
            if ui.IsFrameVisible("developerconsoleintellisense") == 1 then
                local editbox = frame:GetChild("input");
                tolua.cast(editbox, "ui::CEditControl");
                if (editbox:IsHaveFocus() == 0) then
                    ui.CloseFrame("developerconsoleintellisense")
                end
                local isf = ui.GetFrame("developerconsoleintellisense")
                local list = isf:GetChild("triggers");
                AUTO_CAST(list)
                if 1 == keyboard.IsKeyPressed("LEFT") or 1 == keyboard.IsKeyPressed("RIGHT") then
                    DEVELOPERCONSOLE_ON_TYPE()
                end
                local cur=list:GetSelItemIndex() 
                if 1 == keyboard.IsKeyDown("UP") then
                
                    list:DeSelectItemAll()
                    list:SelectItem(math.max(0,cur-1))
                    list:Invalidate()
                    
                elseif 1 == keyboard.IsKeyDown("DOWN") then
                   
                    
                    list:DeSelectItemAll()
                    list:SelectItem(math.min(DEVELOPERCONSOLE_INTELLI_COUNT-1,cur+1))
                    list:Invalidate()
                
                elseif 1 == keyboard.IsKeyDown("NEXT") then
                   
                    list:DeSelectItemAll()
                    list:SelectItem(math.min(DEVELOPERCONSOLE_INTELLI_COUNT-1,cur+7))
                    list:Invalidate()
                    
                elseif 1 == keyboard.IsKeyDown("PRIOR") then
                
                    list:DeSelectItemAll()
                    list:SelectItem(math.max(0,cur-7))
                    list:Invalidate()
                    
                end
                if 1 == keyboard.IsKeyDown("ENTER") or 1 == keyboard.IsKeyDown("TAB")  then
                    local s=string.match(editbox:GetCursurLeftText(),"(.-)[%w_]*$") or editbox:GetCursurLeftText()
                    if(list:GetSelItemIndex()>=0)then
                        editbox:SetText(s..list:GetSelItemText()..editbox:GetCursurRightText())
                    end
                    ReserveScript('ui.CloseFrame("developerconsoleintellisense")',0.01)
                end
                if 1 == keyboard.IsKeyDown("TAB")  then
                    local s=string.match(editbox:GetCursurLeftText(),"(.-)[%w_]*$") or editbox:GetCursurLeftText()
                    if(list:GetSelItemIndex()>=0)then
                        editbox:SetText(s..list:GetSelItemText().."."..editbox:GetCursurRightText())
                    end
                    ReserveScript("DEVELOPERCONSOLE_INTELLISENSE()",0.01)
                end
                if 1 == keyboard.IsKeyDown("ESCAPE") then
                    ui.CloseFrame("developerconsoleintellisense")
                end

                AUTO_CAST(list)
                if DEVELOPERCONSOLE_INTELLI and DEVELOPERCONSOLE_INTELLI_ITERATOR then
                    --イテレータを回す
                    local limit = 10000
                    
                    
                    for i = 0, limit do
                        local k, _ = DEVELOPERCONSOLE_INTELLI_ITERATOR(DEVELOPERCONSOLE_INTELLI_TABLE, DEVELOPERCONSOLE_INTELLI_ITERATOR_KEY)
                        DEVELOPERCONSOLE_INTELLI_ITERATOR_KEY = k
                        
                        
                        if (k == nil) then
                            DEVELOPERCONSOLE_INTELLI = false
                            DEVELOPERCONSOLE_INTELLI_ITERATOR = nil
                            
                            break
                        end
                        if (DEVELOPERCONSOLE_INTELLI_STR == "" or k:lower():starts(DEVELOPERCONSOLE_INTELLI_STR)) then
                            list:AddItem(tostring(k), DEVELOPERCONSOLE_INTELLI_COUNT)
                            
                            DEVELOPERCONSOLE_INTELLI_COUNT = DEVELOPERCONSOLE_INTELLI_COUNT + 1
                            if(list:GetSelItemIndex()<0)then
                                list:SelectItem(0)
                            end
                            if (DEVELOPERCONSOLE_INTELLI_COUNT > 100) then
                                DEVELOPERCONSOLE_INTELLI = false
                                DEVELOPERCONSOLE_INTELLI_ITERATOR = nil
                                break
                            
                            end
                        
                        end
                    end
                    list:ShowWindow(1)
                    list:Invalidate()
                end
            end
        end,
        catch = function(error)
            ERROUT(error)
        
        end
    }
end
function DEVELOPERCONSOLE_ENTER_KEY(frame, control, argStr, argNum)
    if ui.IsFrameVisible("developerconsoleintellisense") == 1 then
        ui.CloseFrame("developerconsoleintellisense")
    else
        
        local textlog = frame:GetChild("textview_log");
        
        if textlog ~= nil then
            tolua.cast(textlog, "ui::CTextView");
            
            local editbox = frame:GetChild("input");
            
            if editbox ~= nil then
                tolua.cast(editbox, "ui::CEditControl");
                local commandText = editbox:GetText();
                
                DEVELOPERCONSOLE_EXEC(frame, commandText)
            end
        end
    end
end

function DEVELOPERCONSOLE_EXEC(frame, commandText, originalstr)
    if (frame == nil) then
        frame = ui.GetFrame("developerconsole")
    end
    
    local textlog = frame:GetChild("textview_log");
    
    if textlog ~= nil then
        tolua.cast(textlog, "ui::CTextView");
        
        local editbox = frame:GetChild("input");
        
        if editbox ~= nil then
            tolua.cast(editbox, "ui::CEditControl");
            
            if commandText ~= nil and commandText ~= "" then
                if (keyboard.IsKeyPressed("LALT") == 1 or keyboard.IsKeyPressed("RALT") == 1) then
                    commandText = commandText:gsub("｛", "{"):gsub("｝", "}")
                end
                DEVELOPERCONSOLE_IGNORE_FLAG = false
                local s = "[Execute] " .. commandText;
                DEVELOPERCONSOLE_ADDTEXT(s);
                local f = assert(lstr(commandText));
                local status, error = pcall(f);
                
                if not status then
                    DEVELOPERCONSOLE_ADDTEXT(tostring(error));
                end
                if (DEVELOPERCONSOLE_IGNORE_FLAG == false) then
                    if (#DEVELOPERCONSOLE_SETTINGS.history == 0 or DEVELOPERCONSOLE_SETTINGS.history[#DEVELOPERCONSOLE_SETTINGS.history] ~= (originalstr or commandText)) then
                        DEVELOPERCONSOLE_SETTINGS.history[#DEVELOPERCONSOLE_SETTINGS.history + 1] = originalstr or commandText
                    end
                    editbox:SetText("");
                end
                
                DEVELOPERCONSOLE_CURSOR = -1
                DEVELOPERCONSOLE_SAVE_SETTINGS()
            end
        end
    end

end


-- Print contents of `tbl`, with indentation.
-- `indent` sets the initial level of indentation.
function tprint(tbl, indent)
    if not indent then indent = 0 end
    for k, v in pairs(tbl) do
        formatting = string.rep("  ", indent) .. k .. ": "
        if type(v) == "table" then
            print(formatting)
            tprint(v, indent + 1)
        elseif type(v) == 'boolean' then
            print(formatting .. tostring(v))
        elseif type(v) == 'function' then
            print(formatting .. "func")
        elseif type(v) == 'userdata' then
            print(formatting .. "userdata")
        else
            print(formatting .. v)
        end
    end
end

function twrite(tbl, indent)
    
    if not indent then indent = 0 end
    for k, v in pairs(tbl) do
        if (type(k) == 'userdata') then
            formatting = string.rep("  ", indent) .. "userdata" .. ": "
            io.write(formatting .. "\n")
        else
            formatting = string.rep("  ", indent) .. tostring(k) .. ": "
            if type(v) == "table" then
                --tx=tx .. formatting.."\n"
                io.write(formatting .. "\n" .. tostring(twrite(v, indent + 1)) .. "\n")
            elseif type(v) == 'boolean' then
                io.write(formatting .. tostring(v) .. "\n")
            elseif type(v) == 'function' then
                io.write(formatting .. "func" .. "\n")
            elseif type(v) == 'userdata' then
                io.write(formatting .. "userdata" .. "\n")
            else
                io.write(formatting .. v .. "\n")
            end
        end
    end
    return tx
end
function tdump(tbl, indent)
    tx = ""
    if not indent then indent = 0 end
    for k, v in pairs(tbl) do
        if (type(k) == 'userdata') then
            formatting = string.rep("  ", indent) .. "userdata" .. ": "
            tx = tx .. formatting .. "\n"
        else
            formatting = string.rep("  ", indent) .. k .. ": "
            if type(v) == "table" then
                --tx=tx .. formatting.."\n"
                tx = tx .. formatting .. "\n" .. tdump(v, indent + 1) .. "\n"
            elseif type(v) == 'boolean' then
                tx = tx .. formatting .. tostring(v) .. "\n"
            elseif type(v) == 'function' then
                tx = tx .. formatting .. "func" .. "\n"
            elseif type(v) == 'userdata' then
                tx = tx .. formatting .. "userdata" .. "\n"
            else
                tx = tx .. formatting .. v .. "\n"
            end
        end
    end
    return tx
end
function twriteflat(tbl, fd)
    
    if not indent then indent = 0 end
    for k, v in pairs(tbl) do
        
        if (type(k) == 'userdata') then
            formatting = string.rep("  ", indent) .. "userdata" .. ": "
            fd:write(formatting .. "\n")
        else
            formatting = string.rep("  ", indent) .. tostring(k) .. ": "
            if type(v) == "table" then
                --tx=tx .. formatting.."\n"
                fd:write(formatting .. "table" .. "\n")
            elseif type(v) == 'boolean' then
                fd:write(formatting .. tostring(v) .. "\n")
            elseif type(v) == 'function' then
                fd:write(formatting .. "func" .. "\n")
            elseif type(v) == 'userdata' then
                fd:write(formatting .. "userdata" .. "\n")
            else
                fd:write(formatting .. v .. "\n")
            end
        end
    end

end
