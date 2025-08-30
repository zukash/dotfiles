-- Notification Center Keyboard Controller
-- Hammerspoon + AXUIElement による完全版

local ax = require("hs.axuielement")

-- NotificationController クラス
local NotificationController = {}

function NotificationController:new()
    local obj = {}
    setmetatable(obj, self)
    self.__index = self
    obj.currentIndex = 1
    return obj
end

function NotificationController:getWindow()
    local runningApps = hs.application.runningApplications()
    
    for _, app in ipairs(runningApps) do
        if app:name() == "Notification Center" then
            local axApp = ax.applicationElement(app)
            local windows = axApp:attributeValue("AXWindows") or {}
            if #windows > 0 then
                return windows[1]
            end
        end
    end
    return nil
end

function NotificationController:getAllButtons()
    local window = self:getWindow()
    if not window then return {} end
    
    local function getAllElements(element, depth)
        depth = depth or 0
        if depth > 5 then return {} end
        
        local result = {}
        local children = element:attributeValue("AXChildren") or {}
        
        for _, child in ipairs(children) do
            table.insert(result, child)
            local subElements = getAllElements(child, depth + 1)
            for _, subElement in ipairs(subElements) do
                table.insert(result, subElement)
            end
        end
        return result
    end
    
    local allElements = getAllElements(window)
    local buttons = {}
    
    for _, element in ipairs(allElements) do
        if element:attributeValue("AXRole") == "AXButton" then
            table.insert(buttons, element)
        end
    end
    
    return buttons
end

-- 通知カードのみを取得（制御ボタンは除外）
function NotificationController:getNotificationCards()
    local window = self:getWindow()
    if not window then return {} end
    
    local function getAllElements(element, depth)
        depth = depth or 0
        if depth > 5 then return {} end
        
        local result = {}
        local children = element:attributeValue("AXChildren") or {}
        
        for _, child in ipairs(children) do
            table.insert(result, child)
            local subElements = getAllElements(child, depth + 1)
            for _, subElement in ipairs(subElements) do
                table.insert(result, subElement)
            end
        end
        return result
    end
    
    local allElements = getAllElements(window)
    local notificationCards = {}
    
    for _, element in ipairs(allElements) do
        local role = element:attributeValue("AXRole")
        local subrole = element:attributeValue("AXSubrole") or ""
        
        -- 通知カードのみを選択（制御ボタンは除外）
        if role == "AXButton" and 
           (subrole == "AXNotificationCenterAlert" or 
            subrole == "AXNotificationCenterAlertStack" or 
            subrole == "AXNotificationCenterBanner") then
            table.insert(notificationCards, element)
        end
    end
    
    return notificationCards
end

-- 展開（スマート判定付き）
function NotificationController:expand()
    local buttons = self:getAllButtons()
    
    -- 展開ボタンがあるかチェック
    for _, button in ipairs(buttons) do
        local help = button:attributeValue("AXHelp")
        if help and help:find("expand") then
            button:performAction("AXPress")
            hs.timer.usleep(500000) -- 0.5秒待機
            return true
        end
    end
    
    -- 展開ボタンがない場合は単一通知
    if #buttons == 1 then
        local desc = buttons[1]:attributeValue("AXDescription") or ""
        if desc:find("stacked") then
            return false
        else
            return false
        end
    end
    
    return false
end

-- 折りたたみ（Show Less ボタンを押す）
function NotificationController:collapse()
    local buttons = self:getAllButtons()
    
    -- Show Less ボタンを探す
    for _, button in ipairs(buttons) do
        local desc = button:attributeValue("AXDescription") or ""
        local help = button:attributeValue("AXHelp") or ""
        
        -- "Show Less" や "Show Fewer" などのテキストを検索
        if desc:find("Show Less") or desc:find("Show Fewer") or 
           help:find("show less") or help:find("show fewer") or
           desc:find("collapse") or help:find("collapse") then
            button:performAction("AXPress")
            hs.timer.usleep(500000) -- 0.5秒待機
            
            -- インデックスをリセット
            self.currentIndex = 1
            return true
        end
    end
    
    -- Show Less ボタンが見つからない場合は何もしない
    return false
end


-- 移動（通知カードのみを対象）
function NotificationController:move(direction)
    local notificationCards = self:getNotificationCards()
    
    -- 通知カードがない場合
    if #notificationCards == 0 then
        return false
    end
    
    -- 1件の通知の場合は、常にハイライトのみ実行
    if #notificationCards == 1 then
        self.currentIndex = 1
        self:highlightCurrentNotificationCard()
        return true
    end
    
    -- 現在のインデックスを通知カードの範囲内に調整
    local currentCardIndex = math.max(1, math.min(self.currentIndex, #notificationCards))
    
    local newCardIndex = currentCardIndex
    if direction == "up" then
        newCardIndex = math.max(1, currentCardIndex - 1)
    elseif direction == "down" then
        newCardIndex = math.min(#notificationCards, currentCardIndex + 1)
    end
    
    if newCardIndex ~= currentCardIndex then
        self.currentIndex = newCardIndex
        self:highlightCurrentNotificationCard()
        return true
    end
    
    -- 端に到達した場合もサイレント
    return false
end

-- 現在の通知をハイライト（視覚的フィードバック）
function NotificationController:highlightCurrentNotification()
    -- 後方互換性のために残す - 新しい関数を呼び出し
    return self:highlightCurrentNotificationCard()
end

-- 現在の通知カードをハイライト（通知カードのみを対象）
function NotificationController:highlightCurrentNotificationCard()
    local notificationCards = self:getNotificationCards()
    if self.currentIndex > #notificationCards or self.currentIndex < 1 then
        return false
    end
    
    local currentCard = notificationCards[self.currentIndex]
    local position = currentCard:attributeValue("AXPosition")
    local size = currentCard:attributeValue("AXSize")
    
    if position then
        -- 通知カードの中央にマウスを移動（アラートなしの静かなハイライト）
        local centerX = position.x + (size and size.width and size.width / 2 or 200)
        local centerY = position.y + (size and size.height and size.height / 2 or 40)
        hs.mouse.absolutePosition({x = centerX, y = centerY})
        return true
    end
    
    return false
end


-- 通知カードの総数を取得
function NotificationController:getNotificationCount()
    local notificationCards = self:getNotificationCards()
    return #notificationCards
end

-- クリック（通知カードのみを対象）
function NotificationController:click()
    local notificationCards = self:getNotificationCards()
    if self.currentIndex > #notificationCards or self.currentIndex < 1 then
        return false
    end
    
    local card = notificationCards[self.currentIndex]
    local result = card:performAction("AXPress")
    
    return result ~= nil
end

-- 個別削除（直接Closeアクション方式）
function NotificationController:deleteDirect()
    local notificationCards = self:getNotificationCards()
    if self.currentIndex > #notificationCards or self.currentIndex < 1 then
        print("Invalid current index: " .. self.currentIndex)
        return false
    end
    
    print("=== Direct Individual Delete ===")
    print("Target index: " .. self.currentIndex .. " of " .. #notificationCards)
    
    local targetCard = notificationCards[self.currentIndex]
    local subrole = targetCard:attributeValue("AXSubrole") or ""
    local actions = targetCard:actionNames() or {}
    
    print("Target card subrole: " .. subrole)
    print("Available actions: " .. table.concat(actions, ", "))
    
    -- Closeアクションを実行
    for _, action in ipairs(actions) do
        if action:find("Close") then
            print("Found Close action: " .. action)
            print("Executing individual delete...")
            
            local result = targetCard:performAction(action)
            if result then
                print("Direct individual delete successful!")
                -- インデックスを調整（通知カード数の範囲内に収める）
                local newCount = self:getNotificationCount()
                if newCount > 0 then
                    self.currentIndex = math.min(self.currentIndex, newCount)
                else
                    self.currentIndex = 1
                end
                return true
            else
                print("Failed to execute Close action")
            end
            break
        end
    end
    
    print("No Close action found")
    return false
end

-- 個別削除（ホバー + Xボタンクリック方式）
function NotificationController:delete()
    -- まず直接Close方式を試行
    print("=== Individual Delete (Trying direct method first) ===")
    local directResult = self:deleteDirect()
    if directResult then
        return true
    end
    
    print("Direct method failed, trying hover method...")
    
    local window = self:getWindow()
    if not window then
        return false
    end
    
    -- 全要素を取得
    local function getAllElements(element, depth)
        depth = depth or 0
        if depth > 5 then return {} end
        
        local result = {}
        local children = element:attributeValue("AXChildren") or {}
        
        for _, child in ipairs(children) do
            table.insert(result, child)
            local subElements = getAllElements(child, depth + 1)
            for _, subElement in ipairs(subElements) do
                table.insert(result, subElement)
            end
        end
        return result
    end
    
    local allElements = getAllElements(window)
    local notificationButtons = {}
    
    -- 通知ボタンを収集
    for _, element in ipairs(allElements) do
        local role = element:attributeValue("AXRole")
        local desc = element:attributeValue("AXDescription") or ""
        local subrole = element:attributeValue("AXSubrole") or ""
        
        if role == "AXButton" and 
           (subrole == "AXNotificationCenterAlert" or 
            subrole == "AXNotificationCenterAlertStack" or 
            subrole == "AXNotificationCenterBanner") then
            table.insert(notificationButtons, element)
        end
    end
    
    if #notificationButtons == 0 then
        return false
    end
    
    -- currentIndexに対応する通知を特定
    local targetIndex = 1
    for i, item in ipairs(notificationButtons) do
        if i == self.currentIndex or (self.currentIndex > #notificationButtons) then
            targetIndex = math.min(i, #notificationButtons)
            break
        end
    end
    
    local targetNotification = notificationButtons[targetIndex]
    local position = targetNotification:attributeValue("AXPosition")
    
    if not position then
        return false
    end
    
    -- 通知の中央にホバー
    local centerX = position.x + 150  -- 通知の中央付近
    local centerY = position.y + 30
    
    hs.mouse.absolutePosition({x = centerX, y = centerY})
    
    -- ホバー効果のために1秒待機
    hs.timer.usleep(1000000)
    
    -- 削除ボタンを探す
    local updatedElements = getAllElements(window)
    local deleteButton = nil
    
    for _, element in ipairs(updatedElements) do
        local role = element:attributeValue("AXRole")
        local desc = element:attributeValue("AXDescription") or ""
        local id = element:attributeValue("AXIdentifier") or ""
        
        if role == "AXButton" and desc == "Close" and id == "xmark" then
            deleteButton = element
            break
        end
    end
    
    if deleteButton then
        local result = deleteButton:performAction("AXPress")
        
        if result then
            -- インデックスを調整
            if self.currentIndex > 1 then
                self.currentIndex = self.currentIndex - 1
            end
            return true
        else
            return false
        end
    else
        return false
    end
end


-- グローバルインスタンス
local controller = NotificationController:new()

-- 長押し中のキーバインド
local longPressKeys = {}

-- Ctrl+Q 長押し方式のキーバインド
hs.hotkey.bind({"ctrl"}, "q", 
    function() -- pressed
        -- Ctrl+Q を押したときに展開
        controller:expand()
        
        -- 長押し中のキーバインドを登録（Ctrlキーも考慮）
        longPressKeys = {
            hs.hotkey.bind({"ctrl"}, "j", function()
                print("j pressed - calling move down")
                controller:move("down")
            end),
            hs.hotkey.bind({"ctrl"}, "k", function()
                print("k pressed - calling move up")
                controller:move("up")
            end),
            hs.hotkey.bind({"ctrl"}, "h", function()
                print("h pressed - calling delete")
                controller:delete()
            end),
            hs.hotkey.bind({"ctrl"}, "l", function()
                print("l pressed - calling click")
                controller:click()
            end)
        }
    end,
    function() -- released
        -- Ctrl+Q を離したときに折りたたみ
        controller:collapse()
        
        -- 長押し中のキーバインドを削除
        for _, hotkey in ipairs(longPressKeys) do
            hotkey:delete()
        end
        longPressKeys = {}
    end
)


print("Notification Center Keyboard Controller loaded!")
print("Controls:")
print("  Ctrl+Q: Press to Expand, Release to Collapse")
print("  While holding Ctrl+Q, press j/k/h/l for quick actions:")
print("    j: Down, k: Up, h: Delete, l: Click")