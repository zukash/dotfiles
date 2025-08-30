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
           (subrole == "AXNotificationCenterAlert" or subrole == "AXNotificationCenterAlertStack") then
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

-- トグル（展開/折りたたみの自動判定）
function NotificationController:toggle()
    local buttons = self:getAllButtons()
    
    -- 現在の状態を判定
    local hasExpandButton = false
    local hasCollapseButton = false
    
    for _, button in ipairs(buttons) do
        local desc = button:attributeValue("AXDescription") or ""
        local help = button:attributeValue("AXHelp") or ""
        
        -- 展開ボタンをチェック
        if help and help:find("expand") then
            hasExpandButton = true
        end
        
        -- 折りたたみボタンをチェック
        if desc:find("Show Less") or desc:find("Show Fewer") or 
           help:find("show less") or help:find("show fewer") or
           desc:find("collapse") or help:find("collapse") then
            hasCollapseButton = true
        end
    end
    
    -- 状態に応じて適切なアクションを実行
    if hasCollapseButton then
        -- Show Less ボタンがある場合は折りたたむ
        return self:collapse()
    elseif hasExpandButton then
        -- 展開ボタンがある場合は展開
        return self:expand()
    else
        -- どちらのボタンもない場合の判定
        if #buttons == 1 then
            local desc = buttons[1]:attributeValue("AXDescription") or ""
            if desc:find("stacked") then
                -- 積み重ね状態なのでクリックして展開を試みる
                return self:click()
            else
                return false
            end
        else
            return false
        end
    end
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

-- 通知の説明文を読みやすく整理
function NotificationController:formatNotificationDescription(desc)
    if not desc then return "Unknown notification" end
    
    -- 長すぎる場合は切り詰める
    local maxLength = 60
    local cleanDesc = desc
    
    -- 一般的なパターンのクリーンアップ
    cleanDesc = cleanDesc:gsub("^%s+", ""):gsub("%s+$", "") -- 前後の空白除去
    cleanDesc = cleanDesc:gsub("%s+", " ") -- 連続空白を単一に
    
    -- アプリ名を抽出（括弧内の情報）
    local appName = cleanDesc:match("%(([^)]+)%)")
    local message = cleanDesc:gsub("%s*%([^)]*%)%s*", "") -- 括弧内を除去
    
    if appName and message and #message > 0 then
        cleanDesc = string.format("%s: %s", appName, message)
    end
    
    -- 長さ制限
    if #cleanDesc > maxLength then
        cleanDesc = cleanDesc:sub(1, maxLength - 3) .. "..."
    end
    
    return cleanDesc
end

-- 現在の通知のインデックス（通知カードのみの中での位置）を取得
function NotificationController:getCurrentNotificationIndex()
    return self.currentIndex
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
        
        if role == "AXButton" and subrole == "AXNotificationCenterAlert" then
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

-- 直接Clear Allアクション（通知要素のアクションを使用）
function NotificationController:clearAllDirect()
    local buttons = self:getAllButtons()
    
    print("=== Direct Clear All ===")
    print("Total buttons found: " .. #buttons)
    
    -- 通知要素を探してClear Allアクションを実行
    for i, button in ipairs(buttons) do
        local subrole = button:attributeValue("AXSubrole") or ""
        local actions = button:actionNames() or {}
        
        -- 通知要素かどうか判定
        if subrole == "AXNotificationCenterAlert" or subrole == "AXNotificationCenterAlertStack" then
            print("Found notification element at index " .. i)
            print("Available actions: " .. table.concat(actions, ", "))
            
            -- Clear AllまたはCloseアクションを探す
            for _, action in ipairs(actions) do
                if action:find("Clear All") then
                    print("Found Clear All action: " .. action)
                    print("Executing Clear All...")
                    
                    local result = button:performAction(action)
                    if result then
                        print("Direct Clear All successful!")
                        self.currentIndex = 1
                        return true
                    else
                        print("Failed to execute Clear All action")
                    end
                elseif action:find("Close") then
                    print("Found Close action (single notification): " .. action)
                    print("Executing Close...")
                    
                    local result = button:performAction(action)
                    if result then
                        print("Direct Close successful!")
                        self.currentIndex = 1
                        return true
                    else
                        print("Failed to execute Close action")
                    end
                end
            end
        end
    end
    
    print("No Clear All or Close action found in notification elements")
    return false
end

-- 全削除（Clear All ボタンを押す）
function NotificationController:clearAll()
    -- まず直接アクション方式を試行
    print("=== Clear All (Trying direct method first) ===")
    local directResult = self:clearAllDirect()
    if directResult then
        return true
    end
    
    print("Direct method failed, trying fallback method...")
    
    local buttons = self:getAllButtons()
    
    print("=== Clear All Fallback ===")
    print("Total buttons found: " .. #buttons)
    
    -- すべてのボタンの詳細を出力
    for i, button in ipairs(buttons) do
        local desc = button:attributeValue("AXDescription") or ""
        local title = button:attributeValue("AXTitle") or ""
        local help = button:attributeValue("AXHelp") or ""
        local role = button:attributeValue("AXRole") or ""
        local subrole = button:attributeValue("AXSubrole") or ""
        local id = button:attributeValue("AXIdentifier") or ""
        
        print(string.format("Button %d:", i))
        print("  Role: " .. role)
        print("  Subrole: " .. subrole)
        print("  Title: " .. title)
        print("  Description: " .. desc)
        print("  Help: " .. help)
        print("  Identifier: " .. id)
        print("  ---")
    end
    
    -- Clear All ボタンを探す（より広範囲の検索）
    for i, button in ipairs(buttons) do
        local desc = button:attributeValue("AXDescription") or ""
        local title = button:attributeValue("AXTitle") or ""
        local help = button:attributeValue("AXHelp") or ""
        local id = button:attributeValue("AXIdentifier") or ""
        
        -- 大文字小文字を無視して検索
        local descLower = desc:lower()
        local titleLower = title:lower()
        local helpLower = help:lower()
        local idLower = id:lower()
        
        if descLower:find("clear") or titleLower:find("clear") or 
           helpLower:find("clear") or idLower:find("clear") or
           descLower:find("すべて") or titleLower:find("すべて") or
           helpLower:find("すべて") then
            print("Found potential Clear button at index " .. i)
            print("  Attempting to press...")
            
            local result = button:performAction("AXPress")
            if result then
                print("  Success!")
                hs.timer.usleep(500000) -- 0.5秒待機
                self.currentIndex = 1
                return true
            else
                print("  Failed to press button")
            end
        end
    end
    
    -- getAllButtons()で見つからない場合は、より深くUIツリーを検索
    print("Searching deeper in UI tree...")
    local window = self:getWindow()
    if window then
        local function getAllElementsDeep(element, depth, maxDepth)
            depth = depth or 0
            maxDepth = maxDepth or 10
            if depth > maxDepth then return {} end
            
            local result = {}
            local children = element:attributeValue("AXChildren") or {}
            
            for _, child in ipairs(children) do
                table.insert(result, child)
                local subElements = getAllElementsDeep(child, depth + 1, maxDepth)
                for _, subElement in ipairs(subElements) do
                    table.insert(result, subElement)
                end
            end
            return result
        end
        
        local allElements = getAllElementsDeep(window)
        print("Deep search found " .. #allElements .. " elements")
        
        for i, element in ipairs(allElements) do
            local role = element:attributeValue("AXRole") or ""
            local desc = element:attributeValue("AXDescription") or ""
            local title = element:attributeValue("AXTitle") or ""
            local help = element:attributeValue("AXHelp") or ""
            local id = element:attributeValue("AXIdentifier") or ""
            
            -- ボタンまたはクリック可能な要素のみをチェック
            if role == "AXButton" or role == "AXMenuItem" then
                local descLower = desc:lower()
                local titleLower = title:lower()
                local helpLower = help:lower()
                local idLower = id:lower()
                
                if descLower:find("clear") or titleLower:find("clear") or 
                   helpLower:find("clear") or idLower:find("clear") or
                   descLower:find("すべて") or titleLower:find("すべて") then
                    print("Deep search found potential Clear element:")
                    print("  Role: " .. role)
                    print("  Description: " .. desc)
                    print("  Title: " .. title)
                    print("  Help: " .. help)
                    print("  ID: " .. id)
                    
                    local result = element:performAction("AXPress")
                    if result then
                        print("  Deep search success!")
                        hs.timer.usleep(500000)
                        self.currentIndex = 1
                        return true
                    else
                        print("  Deep search failed to press")
                    end
                end
            end
        end
    end
    
    print("Clear All button not found in deep search either")
    return false
end

-- 状態確認
function NotificationController:status()
    local buttons = self:getAllButtons()
    local window = self:getWindow()
    
    if not window then
        print("Notification Center not accessible")
        return false
    end
    
    print("Current index: " .. self.currentIndex .. " of " .. #buttons)
    
    if #buttons > 0 and self.currentIndex >= 1 and self.currentIndex <= #buttons then
        local currentButton = buttons[self.currentIndex]
        local desc = currentButton:attributeValue("AXDescription")
        print("Current notification: " .. (desc or "unknown"))
    elseif #buttons > 0 then
        -- インデックスを修正
        self.currentIndex = 1
        local currentButton = buttons[self.currentIndex]
        local desc = currentButton:attributeValue("AXDescription")
        print("Index reset to 1. Current notification: " .. (desc or "unknown"))
    end
    
    return true
end

-- 現在の通知カードの詳細情報を表示
function NotificationController:showCurrentNotification()
    local notificationCards = self:getNotificationCards()
    if self.currentIndex > #notificationCards or self.currentIndex < 1 then
        return false
    end
    
    local currentCard = notificationCards[self.currentIndex]
    local desc = currentCard:attributeValue("AXDescription") or "Unknown"
    local title = currentCard:attributeValue("AXTitle") or "No title"
    local help = currentCard:attributeValue("AXHelp") or "No help"
    local role = currentCard:attributeValue("AXRole") or "Unknown role"
    local subrole = currentCard:attributeValue("AXSubrole") or "No subrole"
    
    -- 詳細情報をコンソールに出力
    print("=== Current Notification Card Details ===")
    print("Index: " .. self:getCurrentNotificationIndex() .. "/" .. self:getNotificationCount())
    print("Title: " .. title)
    print("Description: " .. desc)
    print("Help: " .. help)
    print("Role: " .. role)
    print("Subrole: " .. subrole)
    print("=========================================")
    
    -- 視覚的にもハイライト
    self:highlightCurrentNotificationCard()
    
    return true
end

-- グローバルインスタンス
local controller = NotificationController:new()

-- CommandPalette クラス
local CommandPalette = {}

function CommandPalette:new()
    local obj = {}
    setmetatable(obj, self)
    self.__index = self
    obj.commands = {}
    return obj
end

function CommandPalette:addCommand(name, description, action)
    table.insert(self.commands, {
        text = name,
        subText = description,
        action = action
    })
    print("Added command: " .. name .. " (total: " .. #self.commands .. ")")
end

function CommandPalette:show()
    print("Showing command palette with " .. #self.commands .. " commands")
    local chooser = hs.chooser.new(function(selected)
        if selected then
            -- selectedのindexを使ってactionを実行
            local index = selected.index or 1
            if self.commands[index] and self.commands[index].action then
                self.commands[index].action()
            end
        end
    end)
    
    -- choices用の配列を作成（actionフィールドを除外）
    local choices = {}
    for i, cmd in ipairs(self.commands) do
        table.insert(choices, {
            text = cmd.text,
            subText = cmd.subText,
            index = i
        })
    end
    
    chooser:choices(choices)
    chooser:show()
end

-- グローバルコマンドパレット
local commandPalette = CommandPalette:new()

-- Notification関連コマンドを登録
commandPalette:addCommand("Move Up", "通知を上に移動", function()
    controller:move("up")
end)

commandPalette:addCommand("Move Down", "通知を下に移動", function()
    controller:move("down")
end)

commandPalette:addCommand("Click Notification", "現在の通知をクリック", function()
    controller:click()
end)

commandPalette:addCommand("Delete Notification", "現在の通知を削除", function()
    controller:delete()
end)

commandPalette:addCommand("Delete Notification (Direct)", "通知要素のアクションで直接削除", function()
    controller:deleteDirect()
end)

commandPalette:addCommand("Toggle Expand/Collapse", "通知の展開/折りたたみを切り替え", function()
    controller:toggle()
end)

commandPalette:addCommand("Expand Notifications", "通知を展開", function()
    controller:expand()
end)

commandPalette:addCommand("Collapse Notifications", "通知を折りたたみ", function()
    controller:collapse()
end)

commandPalette:addCommand("Highlight Current", "現在の通知をハイライト", function()
    controller:highlightCurrentNotification()
end)

commandPalette:addCommand("Show Status", "通知の状態を表示", function()
    controller:status()
end)

commandPalette:addCommand("Show Details", "現在の通知の詳細を表示", function()
    controller:showCurrentNotification()
end)

commandPalette:addCommand("Clear All", "すべての通知を削除", function()
    controller:clearAll()
end)

commandPalette:addCommand("Clear All (Direct)", "通知要素のアクションで直接削除", function()
    controller:clearAllDirect()
end)

-- 長押し中のキーバインド
local longPressKeys = {}

-- Ctrl+Q 長押し方式のキーバインド
hs.hotkey.bind({"ctrl"}, "q", 
    function() -- pressed
        print("Ctrl+Q pressed - enabling quick mode")
        hs.alert.show("Quick Mode", 0.5)
        
        -- 長押し中のキーバインドを登録（Ctrlキーも考慮）
        longPressKeys = {
            hs.hotkey.bind({"ctrl"}, "j", function()
                print("ctrl+j pressed in quick mode")
                controller:move("down")
                hs.alert.show("↓", 0.3)
            end),
            hs.hotkey.bind({"ctrl"}, "k", function()
                print("ctrl+k pressed in quick mode")
                controller:move("up")
                hs.alert.show("↑", 0.3)
            end),
            hs.hotkey.bind({"ctrl"}, "h", function()
                print("ctrl+h pressed in quick mode")
                controller:collapse()
                hs.alert.show("Collapse", 0.3)
            end),
            hs.hotkey.bind({"ctrl"}, "l", function()
                print("ctrl+l pressed in quick mode")
                controller:expand()
                hs.alert.show("Expand", 0.3)
            end),
            hs.hotkey.bind({"ctrl"}, "o", function()
                print("ctrl+o pressed in quick mode")
                controller:click()
                hs.alert.show("Click", 0.3)
            end),
            hs.hotkey.bind({"ctrl"}, "i", function()
                print("ctrl+i pressed in quick mode")
                controller:delete()
                hs.alert.show("Delete", 0.3)
            end)
        }
        print("Registered " .. #longPressKeys .. " hotkeys")
    end,
    function() -- released
        print("Ctrl+Q released - disabling quick mode")
        -- 長押し中のキーバインドを削除
        for i, hotkey in ipairs(longPressKeys) do
            print("Deleting hotkey " .. i)
            hotkey:delete()
        end
        longPressKeys = {}
    end
)

-- コマンドパレット用のキーバインド（別のキーに変更）
hs.hotkey.bind({"ctrl", "shift"}, "p", function()
    commandPalette:show()
end)

print("Notification Center Keyboard Controller loaded!")
print("Controls:")
print("  Ctrl+Q: Hold and press j/k/h/l/o/i for quick actions")
print("    j: Down, k: Up, h: Collapse, l: Expand, o: Click, i: Delete")
print("  Ctrl+Shift+P: Open command palette")

-- 手動テスト用のグローバル関数も提供
_G.nc = controller
_G.cp = commandPalette

-- デバッグ用関数
function _G.checkCommands()
    print("Command count: " .. #commandPalette.commands)
    for i, cmd in ipairs(commandPalette.commands) do
        print(i .. ": " .. cmd.text .. " - " .. cmd.subText)
    end
end

-- 通知構造の詳細デバッグ関数
function _G.debugNotificationStructure()
    local window = controller:getWindow()
    if not window then
        print("Notification Center window not found")
        return
    end
    
    print("=== NOTIFICATION STRUCTURE DEBUG ===")
    
    local function analyzeElement(element, depth, path)
        depth = depth or 0
        path = path or "root"
        if depth > 8 then return end
        
        local indent = string.rep("  ", depth)
        local role = element:attributeValue("AXRole") or "unknown"
        local desc = element:attributeValue("AXDescription") or ""
        local title = element:attributeValue("AXTitle") or ""
        local id = element:attributeValue("AXIdentifier") or ""
        local subrole = element:attributeValue("AXSubrole") or ""
        
        print(string.format("%s[%d] %s (%s)", indent, depth, role, path))
        if subrole ~= "" then print(indent .. "  Subrole: " .. subrole) end
        if title ~= "" then print(indent .. "  Title: " .. title) end
        if desc ~= "" then print(indent .. "  Description: " .. desc) end
        if id ~= "" then print(indent .. "  ID: " .. id) end
        
        -- 利用可能なアクション一覧
        local actions = element:actionNames() or {}
        if #actions > 0 then
            print(indent .. "  Actions: " .. table.concat(actions, ", "))
        end
        
        -- 利用可能な属性一覧（重要なもののみ）
        local attributes = element:attributeNames() or {}
        local importantAttrs = {}
        for _, attr in ipairs(attributes) do
            if attr:find("AX") and not attr:find("Position") and not attr:find("Size") then
                table.insert(importantAttrs, attr)
            end
        end
        if #importantAttrs > 0 then
            print(indent .. "  Attributes: " .. table.concat(importantAttrs, ", "))
        end
        
        -- 特に通知関連の要素の場合は詳細分析
        if role == "AXButton" and (subrole == "AXNotificationCenterAlert" or 
            desc:find("notification") or title:find("notification")) then
            print(indent .. "  >>> NOTIFICATION ELEMENT FOUND <<<")
            
            -- この要素で試せる全アクションをテスト（読み取り専用）
            for _, action in ipairs(actions) do
                print(indent .. "    Available action: " .. action)
            end
        end
        
        print(indent .. "  ---")
        
        -- 子要素を再帰的に調査
        local children = element:attributeValue("AXChildren") or {}
        for i, child in ipairs(children) do
            analyzeElement(child, depth + 1, path .. "." .. i)
        end
    end
    
    analyzeElement(window, 0, "notification_center")
    print("=== END DEBUG ===")
end

-- 代替削除方法のテスト関数
function _G.testAlternativeDeletion()
    print("=== TESTING ALTERNATIVE DELETION METHODS ===")
    
    local buttons = controller:getAllButtons()
    if #buttons == 0 then
        print("No buttons found")
        return
    end
    
    -- 通知ボタンのみを抽出
    local notificationButtons = {}
    for i, button in ipairs(buttons) do
        local subrole = button:attributeValue("AXSubrole") or ""
        local desc = button:attributeValue("AXDescription") or ""
        if subrole == "AXNotificationCenterAlert" or desc:find("notification") then
            table.insert(notificationButtons, {index = i, element = button})
        end
    end
    
    if #notificationButtons == 0 then
        print("No notification buttons found")
        return
    end
    
    local testElement = notificationButtons[1].element
    print("Testing on first notification element...")
    
    -- 1. 利用可能な全アクションを試行（安全なもののみ）
    local actions = testElement:actionNames() or {}
    print("Available actions: " .. table.concat(actions, ", "))
    
    -- 2. 削除関連のアクションを探す
    local deleteActions = {}
    for _, action in ipairs(actions) do
        local actionLower = action:lower()
        if actionLower:find("delete") or actionLower:find("remove") or 
           actionLower:find("close") or actionLower:find("dismiss") then
            table.insert(deleteActions, action)
        end
    end
    
    if #deleteActions > 0 then
        print("Found potential delete actions: " .. table.concat(deleteActions, ", "))
        
        -- 最初の削除系アクションをテスト
        local testAction = deleteActions[1]
        print("Testing action: " .. testAction)
        
        -- 注意：実際には実行しない（テスト目的）
        print("Would execute: testElement:performAction('" .. testAction .. "')")
    else
        print("No delete-related actions found")
    end
    
    -- 3. 子要素で削除ボタンを探す（ホバーなし）
    print("\n--- Searching for delete buttons in children ---")
    local function findDeleteButtons(element, depth)
        if depth > 3 then return {} end
        
        local result = {}
        local children = element:attributeValue("AXChildren") or {}
        
        for _, child in ipairs(children) do
            local role = child:attributeValue("AXRole") or ""
            local desc = child:attributeValue("AXDescription") or ""
            local id = child:attributeValue("AXIdentifier") or ""
            
            if role == "AXButton" then
                local descLower = desc:lower()
                local idLower = id:lower()
                
                if descLower:find("close") or descLower:find("delete") or 
                   descLower:find("remove") or idLower:find("close") or
                   idLower:find("delete") or idLower:find("xmark") then
                    table.insert(result, {
                        element = child,
                        desc = desc,
                        id = id,
                        depth = depth
                    })
                end
            end
            
            -- 再帰検索
            local subResults = findDeleteButtons(child, depth + 1)
            for _, subResult in ipairs(subResults) do
                table.insert(result, subResult)
            end
        end
        
        return result
    end
    
    local deleteButtons = findDeleteButtons(testElement, 0)
    if #deleteButtons > 0 then
        print("Found " .. #deleteButtons .. " potential delete buttons:")
        for i, btn in ipairs(deleteButtons) do
            print("  " .. i .. ": " .. btn.desc .. " (ID: " .. btn.id .. ", depth: " .. btn.depth .. ")")
        end
    else
        print("No delete buttons found in children")
    end
    
    print("=== END TEST ===")
end

-- ホバーなし削除の実験的実装
function NotificationController:deleteWithoutHover()
    print("=== Attempting deletion without hover ===")
    
    local buttons = self:getAllButtons()
    if #buttons == 0 then
        print("No buttons found")
        return false
    end
    
    -- 現在の通知を特定
    local targetButton = buttons[self.currentIndex]
    if not targetButton then
        print("Target button not found at index " .. self.currentIndex)
        return false
    end
    
    print("Target button found, analyzing...")
    
    -- Method 1: 通知要素の直接アクション試行
    local actions = targetButton:actionNames() or {}
    print("Available actions on notification: " .. table.concat(actions, ", "))
    
    for _, action in ipairs(actions) do
        local actionLower = action:lower()
        if actionLower:find("delete") or actionLower:find("remove") or 
           actionLower:find("dismiss") then
            print("Trying direct action: " .. action)
            local result = targetButton:performAction(action)
            if result then
                print("Success with direct action!")
                self.currentIndex = math.max(1, self.currentIndex - 1)
                return true
            end
        end
    end
    
    -- Method 2: 子要素から削除ボタンを探す（ホバーなし）
    print("Searching for delete buttons in child elements...")
    local function findAndTryDeleteButtons(element, depth)
        if depth > 3 then return false end
        
        local children = element:attributeValue("AXChildren") or {}
        for _, child in ipairs(children) do
            local role = child:attributeValue("AXRole") or ""
            local desc = child:attributeValue("AXDescription") or ""
            local id = child:attributeValue("AXIdentifier") or ""
            
            if role == "AXButton" then
                local descLower = desc:lower()
                local idLower = id:lower()
                
                if descLower:find("close") or idLower:find("xmark") or
                   descLower:find("delete") or idLower:find("delete") then
                    print("Found potential delete button: " .. desc .. " (ID: " .. id .. ")")
                    local result = child:performAction("AXPress")
                    if result then
                        print("Success with child delete button!")
                        self.currentIndex = math.max(1, self.currentIndex - 1)
                        return true
                    else
                        print("Failed to press child delete button")
                    end
                end
            end
            
            -- 再帰的に子要素も探索
            if findAndTryDeleteButtons(child, depth + 1) then
                return true
            end
        end
        return false
    end
    
    if findAndTryDeleteButtons(targetButton, 0) then
        return true
    end
    
    -- Method 3: フォーカス設定後のキーボードショートカット
    print("Trying keyboard shortcuts...")
    
    -- 通知にフォーカスを設定
    local focusResult = targetButton:setAttributeValue("AXFocused", true)
    if focusResult then
        print("Focus set, trying Delete key...")
        hs.timer.usleep(100000) -- 0.1秒待機
        
        -- Deleteキーを送信
        hs.eventtap.keyStroke({}, "delete")
        hs.timer.usleep(100000)
        
        -- 結果を確認（通知数が減ったかどうか）
        local newButtons = self:getAllButtons()
        if #newButtons < #buttons then
            print("Success with keyboard shortcut!")
            self.currentIndex = math.max(1, self.currentIndex - 1)
            return true
        end
        
        -- Backspaceも試行
        print("Trying Backspace key...")
        hs.eventtap.keyStroke({}, "forwarddelete")
        hs.timer.usleep(100000)
        
        local newButtons2 = self:getAllButtons()
        if #newButtons2 < #buttons then
            print("Success with Backspace!")
            self.currentIndex = math.max(1, self.currentIndex - 1)
            return true
        end
    end
    
    print("All methods failed")
    return false
end