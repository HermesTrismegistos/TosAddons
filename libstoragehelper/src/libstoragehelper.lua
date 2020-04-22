local g={
    debug=false
}
local function EBI_try_catch(what)
    local status, result = pcall(what.try)
    if not status then
        what.catch(result)
    end
    return result
end
local function EBI_IsNoneOrNil(val)
    return val == nil or val == "None" or val == "nil"
end
local function DBGOUT(msg)

    EBI_try_catch{
        try = function()
            if (g.debug == true) then
                CHAT_SYSTEM(msg)
                
                print(msg)
            
            end
        end,
        catch = function(error)
        end
    }

end


function ERROUT(msg)
    EBI_try_catch{
        try = function()
            CHAT_SYSTEM(msg)
            print(msg)
        end,
        catch = function(error)
        end
    }

end


local p={
    debug=false,
    target=IT_ACCOUNT_WAREHOUSE,
}

function p.get_exist_item_index(itemObj)
    local ret1 = false
    local ret2 = -1
    
    if geItemTable.IsStack(itemObj.ClassID) == 1 then
        local itemList = session.GetEtcItemList(p.target));    
        local sortedGuidList = itemList:GetGuidList();    
        local sortedCnt = sortedGuidList:Count();
        
        for i = 0, sortedCnt - 1 do
            local guid = sortedGuidList:Get(i);
            local invItem = itemList:GetItemByGuid(guid)
            local invItem_obj = GetIES(invItem:GetObject());
            if itemObj.ClassID == invItem_obj.ClassID then
                ret1 = true
                ret2 = invItem.invIndex 
                break
            end
        end
        return ret1, ret2
    else
        return false, -1
    end
end
function p.get_valid_index()
    local itemList = session.GetEtcItemList(p.target);
    local guidList = itemList:GetGuidList();
    local sortedGuidList = itemList:GetGuidList();
    local sortedCnt = sortedGuidList:Count();
    local account = session.barrack.GetMyAccount();
    local slotCount = account:GetAccountWarehouseSlotCount();
    local start_index = 0
    local last_index = p.storagesize() - 1
    local itemCnt = 0;
    local guidList = itemList:GetGuidList();
    local cnt = guidList:Count();
    local offset=offset or 0
    for i = 0, cnt - 1 do
        local guid = guidList:Get(i);
        local invItem = itemList:GetItemByGuid(guid);
        local obj = GetIES(invItem:GetObject());
        if obj.ClassName ~= MONEY_NAME and invItem.invIndex < p.getcountpertab() then
            itemCnt = itemCnt + 1;
        end
    end
    local __set = {}
    local inc = 0
    local money_offset = 0
    for i = 0, sortedCnt - 1 do
        local guid = sortedGuidList:Get(i)
        local invItem = itemList:GetItemByGuid(guid)
        local obj = GetIES(invItem:GetObject());
        
        if obj.ClassName ~= MONEY_NAME then
            __set[invItem.invIndex] = {item = invItem, obj = obj, mode = 1}

        
        else
            --__set[invItem.invIndex] = {item = invItem, obj = obj, mode = 2}
            money_offset=1
        end
    end
    local first=0
    for i=0,slotCount do
        if(__set[i]~=nil)then
            first=first+1

        end
    end
     -- -1 is preventaion tos bug
    DBGOUT(string.format("prevent %d/%d",first,slotCount-1))
    if(first>=(slotCount-1))then
        
        for i=0,p.getcountpertab() do
            __set[i] ={mode=1}
        end
    end
    --prevent tos bug
    for i=1,p.gettabcount() do
        local count=0
        for j=p.getcountpertab()*i,p.getcountpertab()*(i+1) do
            if(__set[j]~=nil and __set[j].mode==1)then
                count=count+1
    
            end
        end
        if(count>=(p.getcountpertab()-1))then
            for j=p.getcountpertab()*i,p.getcountpertab()*(i+1) do
                __set[j] ={mode=1}
            end
        end
    end

    local index = start_index
    
    for k=start_index,last_index+1 do
        index = k
        if __set[k] == nil then
            offset=offset-1
            if(offset<=0)then
                break
            end
        end
    end
    
    DBGOUT("idx" .. index)
    return index
end

function p.gettabcount()
    if (true == session.loginInfo.IsPremiumState(ITEM_TOKEN)) then
        return 5
       
    else
        return 1
       
    end
end

function p.getcountpertab()
    return 70
end
--- gets storage size.
--- reduced one for each tab from the actual for preventation tos bug.
function p.storagesize()
    local account = session.barrack.GetMyAccount();
    local slotCount = account:GetAccountWarehouseSlotCount();
    
    return (slotCount-1) + (p.gettabcount() - 1) * (p.getcountpertab()-1)
end
--- gets storage size.
--- reduced one for each tab from the actual for preventation tos bug.
function p.storageremain()

    
    return p.storagesize()-p.count()
end
function p.checkvalid(iesid,silent)
    local invItem=session.GetInvItemByGuid(iesid)
    local itemList = session.GetEtcItemList(p.target);  
    local obj = GetIES(invItem:GetObject())
    if p.storagesize() <= p.count() then
        if(not silent)then
            ui.SysMsg(ClMsg('CannotPutBecauseMasSlot'));
        end
        return false;

    end
    if true == invItem.isLockState then
        if(not silent)then
            ui.SysMsg(ClMsg("MaterialItemIsLock"));
        end
        return;
    end
    
    local itemCls = GetClassByType("Item", obj.ClassID);
    if itemCls.ItemType == 'Quest' then
        if(not silent)then
            ui.MsgBox(ScpArgMsg("IT_ISNT_REINFORCEABLE_ITEM"));
        end
        return;
    end
    
    local enableTeamTrade = TryGetProp(itemCls, "TeamTrade");
    if enableTeamTrade ~= nil and enableTeamTrade == "NO" then
        if(not silent)then
            ui.SysMsg(ClMsg("ItemIsNotTradable"));
        end
        return;
    end
    return true
end
---acquires invItem and invObj
function p.itemandobj(iesid)
    local invItem = session.GetInvItemByGuid(iesid)
    local invItem_obj = GetIES(invItem:GetObject());
    return invItem,invItem_obj
end
function p.aw()
    return ui.GetFrame("accountwarehouse")
end
-- put item
-- if count is nil,will use totalcount
-- return if succeeded true ,else false 
function p.putitem(iesid,count,slient)
    if(not p.checkvalid(iesid,slient))then
        return false
    end
    local invItem,invObj=p.itemandobj(iesid)
    local ret, idx = p.get_exist_item_index(invObj)
    
    if (ret == false) then

        idx = p.get_valid_index()
    end
    if(idx)then

        item.PutItemToWarehouse(p.target, invItem:GetIESID(), tostring(math.min(count or invItem.count,invItem.count)), p.aw():GetUserIValue("HANDLE"), idx)
        return true
    end

    return false
end
-- current item count
function p.count()
    local itemList = session.GetEtcItemList(p.target);
    local guidlist = itemList:GetSortedGuidList();
    local cnt = itemList:Count();
    local rcnt=0
    for i = 0, cnt - 1 do
        local guid = guidlist:Get(i);
        local invItem = itemList:GetItemByGuid(guid)
        local invItem_obj = GetIES(invItem:GetObject());
        if invItem_obj.ClassName ~= MONEY_NAME then
            rcnt=rcnt+1
        end
    end
    return rcnt
end
-- return bool,
-- get items
-- itemlist is list of item and count
-- such as 
-- {
--  {iesid="1514816461831",count=2},
--  {iesid="2488814315343",count=2}
-- }
-- if count is nil,will use totalcount
-- return if succeeded true ,else false 
-- if you will task from persona warehouse ,list length must be 1 and make sure sufficient silver.
function p.getitems(itemlist)
    session.ResetItemList();
    local awframe = p.aw();
    for _,v in ipairs(itemlist) do
        local invItem = session.GetEtcItemByGuid(p.target, v.iesid);
        local cnt = math.min(v.count or invItem.count,invItem.count)
        
        cnt = invItem.count
    
        DBGOUT("TAKE")
        session.AddItemID( v.iesid, cnt);
    end
    item.TakeItemFromWarehouse_List(p.target, session.GetItemIDList(), awframe:GetUserIValue("HANDLE"));
end
--gets account money
--return amount of silver as string
function p.accountmoney()
    local itemList = session.GetEtcItemList(IT_ACCOUNT_WAREHOUSE);
    local cnt, visItemList = GET_INV_ITEM_COUNT_BY_PROPERTY( { { Name = 'ClassName', Value = MONEY_NAME } }, false, itemList);
    local visItem = visItemList[1];
    if visItem == nil then
        return "0";
    end

    return visItem:GetAmountStr()
end
-- itemslist iterator
-- returns iesid,invItem,invObj
function p.items()
    local itemList = session.GetEtcItemList(p.target);
    local guidList = itemList:GetGuidList();
    local sortedGuidList = itemList:GetSortedGuidList();    
    local sortedCnt = sortedGuidList:Count();    
    local i=0
    return function()
        while i<sortedCnt do
            local guid = sortedGuidList:Get(i)
            i=i+1
            local invItem = itemList:GetItemByGuid(guid)

            if invItem ~= nil then
                local obj = GetIES(invItem:GetObject());
                if obj.ClassName ~= MONEY_NAME  then
                    return guid,invItem,obj
                end
            end
          
        end
        return nil
    end
end


LIBSTORAGEHELPER=p