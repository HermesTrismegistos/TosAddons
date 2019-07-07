--OLD_SHOP_ITEM_LIST_GET
function EBI_try_catch(what)
    local status, result = pcall(what.try)
    if not status then
        what.catch(result)
    end
    return result
end

local acutil = require('acutil')

-- ライブラリ読み込み
function LEGEXPPOTIONGAUGE_ON_INIT(addon, frame)
    EBI_try_catch{
        try = function()
            LEGEXPPOTIONGAUGE_INVITEM_UPDATER={}
            LEGEXPPOTIONGAUGE_HOOK()
            --addon:RegisterMsg('GAME_START', 'LEGEXPPOTIONGAUGE_UPDATE');
            addon:RegisterMsg("OPEN_DLG_ACCOUNTWAREHOUSE", "ON_OPEN_ACCOUNTWAREHOUSE");
            addon:RegisterMsg('GAME_START_3SEC', 'LEGEXPPOTIONGAUGE_3SEC');
            addon:RegisterMsg('FPS_UPDATE', 'LEGEXPPOTIONGAUGE_SHOWWINDOW');
            addon:RegisterMsg("WAREHOUSE_ITEM_LIST", "LEGEXPPOTIONGAUGE_WAREHOUSE_INIT");
            addon:RegisterMsg("WAREHOUSE_ITEM_ADD", "LEGEXPPOTIONGAUGE_WAREHOUSE_INIT");
            addon:RegisterMsg("WAREHOUSE_ITEM_REMOVE", "LEGEXPPOTIONGAUGE_WAREHOUSE_INIT");
            addon:RegisterMsg("WAREHOUSE_ITEM_CHANGE_COUNT", "LEGEXPPOTIONGAUGE_WAREHOUSE_INIT");
            addon:RegisterMsg("WAREHOUSE_ITEM_IN", "LEGEXPPOTIONGAUGE_WAREHOUSE_INIT");
            addon:RegisterMsg("ACCOUNT_WAREHOUSE_ITEM_LIST", "LEGEXPPOTIONGAUGE_ACCOUNTWAREHOUSE_INIT");
            addon:RegisterMsg("ACCOUNT_WAREHOUSE_ITEM_ADD", "LEGEXPPOTIONGAUGE_ACCOUNTWAREHOUSE_INIT");
            addon:RegisterMsg("ACCOUNT_WAREHOUSE_ITEM_REMOVE", "LEGEXPPOTIONGAUGE_ACCOUNTWAREHOUSE_INIT");
            addon:RegisterMsg("ACCOUNT_WAREHOUSE_ITEM_CHANGE_COUNT", "LEGEXPPOTIONGAUGE_ACCOUNTWAREHOUSE_INIT");
            addon:RegisterMsg("ACCOUNT_WAREHOUSE_ITEM_IN", "LEGEXPPOTIONGAUGE_ACCOUNTWAREHOUSE_INIT");
            local timer = GET_CHILD(frame, "addontimer", "ui::CAddOnTimer");
			timer:SetUpdateScript("LEGEXPPOTIONGAUGE_UPDATE")
            timer:Start(0.3);
            
        end,
        catch = function(error)
            CHAT_SYSTEM(error)
        end
    }
    
end
function LEGEXPPOTIONGAUGE_SHOWWINDOW(frame)
    ui.GetFrame("legexppotiongauge"):ShowWindow(1)
end
function LEGEXPPOTIONGAUGE_3SEC()
    if(not LEGEXPPOTIONGAUGE_FIRSTRUN) then
        LEGEXPPOTIONGAUGE_FIRSTRUN=true
        INVENTORY_UPDATE_ICONS(ui.GetFrame("inventory"));
    end
    LEGEXPPOTIONGAUGE_UPDATE()
end
function LEGEXPPOTIONGAUGE_UPDATE()
    LEGEXPPOTIONGAUGE_UPDATE_FORKEYBOARD()
    --update inventory
    local frame =ui.GetFrame("inventory");
    
    for k,v in pairs(LEGEXPPOTIONGAUGE_INVITEM_UPDATER) do
 
        local slotset=GET_CHILD_RECURSIVELY(frame, v.parentName, 'ui::CSlotSet');
        if(slotset==nil) then
    
            LEGEXPPOTIONGAUGE_INVITEM_UPDATER[k]=nil
        end
        local slot=GET_CHILD_RECURSIVELY(slotset, v.slotName, 'ui::CSlot');
        if(slot==nil) then

            LEGEXPPOTIONGAUGE_INVITEM_UPDATER[k]=nil
        end
        LEGEXPPOTIONGAUGE_SETINFO(slot,v.invItem)
    end
end
function LEGEXPPOTIONGAUGE_UPDATE_FORKEYBOARD()
    local frame = ui.GetFrame('quickslotnexpbar');
    local sklCnt = frame:GetUserIValue('SKL_MAX_CNT');
    for i = 0, MAX_QUICKSLOT_CNT - 1 do
        local quickSlotInfo = quickslot.GetInfoByIndex(i);
        local applied = false
        if quickSlotInfo.type ~= 0 then
            local updateslot = true;
            if sklCnt > 0 then
                if quickSlotInfo.category == 'Skill' then
                    updateslot = false;
                end
                
                if i <= sklCnt then
                    updateslot = false;
                end
            end
            if true == updateslot and quickSlotInfo.category ~= 'NONE' and session.GetInvItemByGuid( quickSlotInfo:GetIESID())~=nil then
                local slot = GET_CHILD_RECURSIVELY(frame, "slot" .. i + 1, "ui::CSlot")
				LEGEXPPOTIONGAUGE_SETINFO(slot, session.GetInvItemByGuid( quickSlotInfo:GetIESID()))
				--LEGEXPPOTIONGAUGE_SET_QUICK_SLOT(frame, slot, quickSlotInfo.category, quickSlotInfo.type, quickSlotInfo:GetIESID(), 0, true, true);
                applied = true
            end
        else
            
            
            end
        if (applied == false) then
            local slot = GET_CHILD_RECURSIVELY(frame, "slot" .. i + 1, "ui::CSlot");
            LEGEXPPOTIONGAUGE_CLEARSLOT(slot)
        end
    end
end
function LEGEXPPOTIONGAUGE_HOOK()
	--acutil.setupHook("LEGEXPPOTIONGAUGE_INV_ICON_SETINFO_HOOK", "INV_ICON_SETINFO")
	if(OLD_INV_ICON_SETINFO == nil and INV_ICON_SETINFO ~= LEGEXPPOTIONGAUGE_INV_ICON_SETINFO_HOOK)then
		OLD_INV_ICON_SETINFO = INV_ICON_SETINFO;
		INV_ICON_SETINFO=LEGEXPPOTIONGAUGE_INV_ICON_SETINFO_HOOK
	end
	if(OLD_SET_QUICK_SLOT == nil and SET_QUICK_SLOT ~= LEGEXPPOTIONGAUGE_SET_QUICK_SLOT_HOOK)then
		OLD_SET_QUICK_SLOT = SET_QUICK_SLOT;
		SET_QUICK_SLOT=LEGEXPPOTIONGAUGE_SET_QUICK_SLOT_HOOK
	end
    --acutil.setupHook("LEGEXPPOTIONGAUGE_SET_QUICK_SLOT_HOOK", "SET_QUICK_SLOT")

end
function LEGEXPPOTIONGAUGE_SET_QUICK_SLOT_HOOK(frame, slot, category, type, iesID, makeLog, sendSavePacket, isForeceRegister)
	return LEGEXPPOTIONGAUGE_SET_QUICK_SLOT(frame, slot, category, type, iesID, makeLog, sendSavePacket, isForeceRegister)
end
function LEGEXPPOTIONGAUGE_INV_ICON_SETINFO_HOOK(frame, slot, invItem, customFunc, scriptArg, count)
	return LEGEXPPOTIONGAUGE_INV_ICON_SETINFO(frame, slot, invItem, customFunc, scriptArg, count)
end
function LEGEXPPOTIONGAUGE_SET_QUICK_SLOT(frame, slot, category, type, iesID, makeLog, sendSavePacket, isForeceRegister)
	--CHAT_SYSTEM("RRR")
    EBI_try_catch{
        try = function()
            OLD_SET_QUICK_SLOT(frame, slot, category, type, iesID, makeLog, sendSavePacket, isForeceRegister)
            LEGEXPPOTIONGAUGE_SETINFO(slot, session.GetInvItemByGuid(iesID))
        end,
        catch = function(error)
            CHAT_SYSTEM(error)
        end
    }

end

function LEGEXPPOTIONGAUGE_INV_ICON_SETINFO(frame, slot, invItem, customFunc, scriptArg, count)

    OLD_INV_ICON_SETINFO(frame, slot, invItem, customFunc, scriptArg, count)
    LEGEXPPOTIONGAUGE_INVITEM_UPDATER[invItem:GetIESID()]={slotName=slot:GetName(),parentName=slot:GetParent():GetName(),invItem=invItem}
    LEGEXPPOTIONGAUGE_SETINFO(slot, invItem)
end

function LEGEXPPOTIONGAUGE_SETINFO(slot, invItem)
    if (invItem ~= nil) then
        
        local itemClass = GetClassByType('Item', invItem.type);
        if (itemClass.GroupName == "ExpOrb") then
            local curexp, maxexp = GET_LEGENDEXPPOTION_EXP(GetIES(invItem:GetObject()))
   
            local gauge = slot:CreateOrGetControl("gauge", "expnum", 0, 0, slot:GetWidth(), 10)
            tolua.cast(gauge, "ui::CGauge")
            gauge:SetGravity(ui.LEFT, ui.BOTTOM)
            gauge:EnableHitTest(0)
            gauge:SetMaxPoint(maxexp)
			gauge:SetCurPoint(curexp)
			
            local txt = slot:CreateOrGetControl("richtext", "exptxt", 0, 0, slot:GetWidth(), 12)
            txt:SetGravity(ui.CENTER_HORZ, ui.BOTTOM)
            txt:EnableHitTest(0)
			if(curexp >= maxexp)then
				gauge:SetBarColor(0xFF00FF00)
				
				txt:SetText("{ol}{s16}MAX")
			else
				gauge:SetBarColor(0xFFFFFFFF)
				txt:SetText(string.format("{ol}{s16}%d%%", math.floor(curexp * 100.0 / maxexp)))
			end
			
        end
    end
end
function LEGEXPPOTIONGAUGE_CLEARSLOT(slot)
    if (slot:GetChild("expnum")) then
        slot:RemoveChild("expnum")
        slot:RemoveChild("exptxt")
    
    end
end
function LEGEXPPOTIONGAUGE_ACCOUNTWAREHOUSE_INIT()
    
    EBI_try_catch{
        try=function()
            local frame=ui.GetFrame("accountwarehouse")
            local slotset =  GET_CHILD_RECURSIVELY(frame, 'slotset',"ui::CSlotSet");
            for i=0 ,slotset:GetSlotCount()-1 do
                local slot=slotset:GetSlotByIndex(i)
                local icon=slot:GetIcon()
                if(icon~=nil)then
                    local info=icon:GetInfo()
                    if(info~=nil)then
                        local invItem=session.GetEtcItemByGuid(IT_ACCOUNT_WAREHOUSE, info:GetIESID());
                        local itemClass = GetClassByType('Item', invItem.type);
                        if (itemClass.GroupName == "ExpOrb") then
                            LEGEXPPOTIONGAUGE_SETINFO(slot,invItem)
                        else
                            LEGEXPPOTIONGAUGE_CLEARSLOT(slot)
                        end
                    else
                        LEGEXPPOTIONGAUGE_CLEARSLOT(slot)
                    end
                else
                    LEGEXPPOTIONGAUGE_CLEARSLOT(slot)
                end
            end


        end,

        catch=function(error)
            CHAT_SYSTEM(error)
        end
    }
end
function LEGEXPPOTIONGAUGE_WAREHOUSE_INIT()
    EBI_try_catch{
        try=function()
            local frame=ui.GetFrame("warehouse")
            local slotset =  GET_CHILD_RECURSIVELY(frame, 'slotset',"ui::CSlotSet");
            for i=0 ,slotset:GetSlotCount()-1 do
                local slot=slotset:GetSlotByIndex(i)
                local icon=slot:GetIcon()
                if(icon~=nil)then
                    local info=icon:GetInfo()
                    if(info~=nil)then
                        local invItem=session.GetEtcItemByGuid(IT_WAREHOUSE, info:GetIESID());
                        local itemClass = GetClassByType('Item', invItem.type);
                        if (itemClass.GroupName == "ExpOrb") then
                            LEGEXPPOTIONGAUGE_SETINFO(slot,invItem)
                        else
                            LEGEXPPOTIONGAUGE_CLEARSLOT(slot)
                        end
                    else
                        LEGEXPPOTIONGAUGE_CLEARSLOT(slot)
                    end
                else
                    LEGEXPPOTIONGAUGE_CLEARSLOT(slot)
                end
            end
        end,

        catch=function(error)
            CHAT_SYSTEM(error)
        end
    }
    
end
LEGEXPPOTIONGAUGE_HOOK()