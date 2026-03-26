if GetLocale() ~= "zhCN" then return end

local addon = _G._HorizonSuite_Loading or _G.HorizonSuiteBeta or _G.HorizonSuite
if not addon then return end

local L = setmetatable({}, { __index = addon.L })
addon.L = L
addon.StandardFont = UNIT_NAME_FONT

-- =====================================================================
-- OptionsPanel.lua — Title
-- =====================================================================
L["HORIZON SUITE"]                                                      = "HORIZON SUITE"

-- =====================================================================
-- OptionsPanel.lua — Sidebar module group labels
-- =====================================================================
L["Focus"]                                                              = "追踪"
L["Presence"]                                                           = "情境"
L["Other"]                                                              = "其他"

-- =====================================================================
-- OptionsPanel.lua — Section headers
-- =====================================================================
L["Quest types"]                                                        = "任务类型"
L["Element overrides"]                                                  = "元素颜色"
L["Per category"]                                                       = "每个分类"
L["Grouping Overrides"]                                                 = "分组覆盖"
-- L["Section Overrides"]                                                  = "Section Overrides"  -- NEEDS TRANSLATION
L["Other colors"]                                                       = "其他颜色"

-- =====================================================================
-- OptionsPanel.lua — Color row labels (collapsible group sub-rows)
-- =====================================================================
L["Section"]                                                            = "分类"
L["Title"]                                                              = "标题"
L["Zone"]                                                               = "区域"
L["Objective"]                                                          = "目标"

-- =====================================================================
-- OptionsPanel.lua — Toggle switch labels & tooltips
-- =====================================================================
L["Ready to Turn In overrides base colours"]                            = "准备提交覆盖基础颜色"
L["Ready to Turn In uses its colours for quests in that section."]      = "准备提交在该分类中使用其颜色"
L["Current Zone overrides base colours"]                                = "当前区域使用独立颜色"
L["Current Zone uses its colours for quests in that section."]          = "当前区域章节将使用其自己的颜色."
L["Current Quest overrides base colours"]                               = "当前任务覆盖基础颜色"
L["Current Quest uses its colours for quests in that section."]         = "当前任务在该分类中使用其颜色."
L["Use distinct color for completed objectives"]                        = "已完成目标使用不同颜色"
L["When on, completed objectives (e.g. 1/1) use the color below; when off, they use the same color as incomplete objectives."]= "启用时已完成目标(如 1/1)使用下方颜色；禁用时使用与未完成目标相同颜色"
L["Completed objective"]                                                = "已完成目标"

-- =====================================================================
-- OptionsPanel.lua — Button labels
-- =====================================================================
L["Reset"]                                                              = "重置"
L["Reset quest types"]                                                  = "重置任务类型"
L["Reset overrides"]                                                    = "重置覆盖"
L["Reset all to defaults"]                                              = "全部重置为默认值"
L["Reset to defaults"]                                                  = "重置为默认值"
L["Reset to default"]                                                   = "重置为默认值"

-- =====================================================================
-- OptionsPanel.lua — Search bar placeholder
-- =====================================================================
L["Search settings..."]                                                 = "搜索设置..."
L["Search fonts..."]                                                    = "搜索字体..."

-- =====================================================================
-- OptionsPanel.lua — Resize handle tooltip
-- =====================================================================
L["Drag to resize"]                                                     = "拖动以调整大小"

-- =====================================================================
-- OptionsData.lua Category names (sidebar)
-- =====================================================================
L["Profiles"]                                                           = "配置文件"
L["Modules"]                                                            = "模块"
-- L["Module Toggles"]                                                     = "Module Toggles"  -- NEEDS TRANSLATION
L["Axis"]                                                               = "Axis"

-- =====================================================================
-- DashboardPanel.lua — First-run welcome
-- =====================================================================
-- L["Dashboard welcome tab"]                                              = "Welcome"  -- NEEDS TRANSLATION
-- L["Dashboard welcome title"]                                            = "Welcome to Horizon Suite"  -- NEEDS TRANSLATION
-- L["Dashboard welcome head sub"]                                         = "What each module does and where to turn them on"  -- NEEDS TRANSLATION
-- L["Dashboard welcome intro"]                                            = "Horizon Suite is modular — enable only the pieces you want. Turning a module on or off applies on reload. Expand Contributors or Localisations below for credits and supported languages. Use Open module toggles under Modules, or open Axis, then Modules, in the sidebar. You can return to this Welcome page anytime from the sidebar."  -- NEEDS TRANSLATION
-- L["Dashboard welcome path"]                                             = "%s → %s → %s"  -- NEEDS TRANSLATION
-- L["Dashboard welcome modules heading"]                                  = "Modules"  -- NEEDS TRANSLATION
-- L["Dashboard welcome contributors heading"]                             = "Contributors"  -- NEEDS TRANSLATION
-- L["Dashboard welcome contributors body"]                                = [=[Thanks to everyone who has contributed to Horizon Suite:  -- NEEDS TRANSLATION

-- L["Dashboard welcome localisations heading"]                            = "Localisations"  -- NEEDS TRANSLATION
-- L["Dashboard welcome localisations body"]                               = [=[The options panel is localised for:  -- NEEDS TRANSLATION


-- L["Dashboard welcome open module toggles link"]                         = "Open module toggles"  -- NEEDS TRANSLATION
-- L["Axis module short description"]                                      = "Core settings hub: profiles, modules, and global toggles."  -- NEEDS TRANSLATION
-- L["Objective tracker for quests, world quests, rares, achievements, scenarios."]= "Objective tracker for quests, world quests, rares, achievements, scenarios."  -- NEEDS TRANSLATION
-- L["Zone text and notifications."]                                       = "Zone text and notifications."  -- NEEDS TRANSLATION
-- L["Minimap with zone text, coords, time, and button collector."]        = "Minimap with zone text, coords, time, and button collector."  -- NEEDS TRANSLATION
-- L["Tooltips with class colors, spec, and faction icons."]               = "Tooltips with class colors, spec, and faction icons."  -- NEEDS TRANSLATION
-- L["Loot toasts for items, money, currency, reputation."]                = "Loot toasts for items, money, currency, reputation, and bag overhaul."  -- NEEDS TRANSLATION
-- L["Essence module short description"]                                   = "Custom character sheet with 3D model, item level, stats, and gear grid."  -- NEEDS TRANSLATION
-- L["Meridian module short description"]                                  = "Join the Discord and have a guess!"  -- NEEDS TRANSLATION
-- L["Dashboard welcome community heading"]                                = "Community & Support"  -- NEEDS TRANSLATION
-- L["Discord"]                                                            = "Discord"  -- NEEDS TRANSLATION
-- L["Ko-fi"]                                                              = "Ko-fi"  -- NEEDS TRANSLATION
-- L["Patreon"]                                                            = "Patreon"  -- NEEDS TRANSLATION
-- L["GitLab"]                                                             = "GitLab"  -- NEEDS TRANSLATION
-- L["CurseForge"]                                                         = "CurseForge"  -- NEEDS TRANSLATION
-- L["Wago"]                                                               = "Wago"  -- NEEDS TRANSLATION
-- L["Copy link — %s"]                                                     = "Copy link — %s"  -- NEEDS TRANSLATION
L["Layout"]                                                             = "布局"
L["Visibility"]                                                         = "可见性"
L["Display"]                                                            = "显示"
L["Features"]                                                           = "功能"
L["Typography"]                                                         = "排版"
L["Appearance"]                                                         = "外观"
L["Colors"]                                                             = "颜色"
L["Organization"]                                                       = "组织"

-- =====================================================================
-- OptionsData.lua Section headers
-- =====================================================================
L["Panel behaviour"]                                                    = "面板行为"
L["Dimensions"]                                                         = "尺寸"
L["Instance"]                                                           = "副本"
L["Instances"]                                                          = "副本"
L["Combat"]                                                             = "战斗"
L["Filtering"]                                                          = "过滤"
L["Header"]                                                             = "标题"
-- L["Sections & structure"]                                               = "Sections & structure"  -- NEEDS TRANSLATION
-- L["Entry details"]                                                      = "Entry details"  -- NEEDS TRANSLATION
-- L["Progress & timers"]                                                  = "Progress & timers"  -- NEEDS TRANSLATION
-- L["Focus emphasis"]                                                     = "Focus emphasis"  -- NEEDS TRANSLATION
L["List"]                                                               = "列表"
L["Spacing"]                                                            = "间距"
L["Rare bosses"]                                                        = "稀有首领"
L["World quests"]                                                       = "世界任务"
L["Floating quest item"]                                                = "浮动任务物品"
L["Mythic+"]                                                            = "史诗+"
L["Achievements"]                                                       = "成就"
L["Endeavors"]                                                          = "宏图"
L["Decor"]                                                              = "装饰"
L["Scenario & Delve"]                                                   = "场景和地下堡"
L["Font"]                                                               = "字体"
-- L["Font families"]                                                      = "Font families"  -- NEEDS TRANSLATION
-- L["Global font size"]                                                   = "Global font size"  -- NEEDS TRANSLATION
-- L["Font sizes"]                                                         = "Font sizes"  -- NEEDS TRANSLATION
-- L["Per-element fonts"]                                                  = "Per-element fonts"  -- NEEDS TRANSLATION
L["Text case"]                                                          = "文本大小写"
L["Shadow"]                                                             = "阴影"
L["Panel"]                                                              = "面板"
L["Highlight"]                                                          = "高亮"
L["Color matrix"]                                                       = "颜色矩阵"
L["Focus order"]                                                        = "聚焦顺序"
L["Sort"]                                                               = "排序"
L["Behaviour"]                                                          = "行为"
L["Content Types"]                                                      = "内容类型"
L["Delves"]                                                             = "地下堡"
L["Delves & Dungeons"]                                                  = "地下堡与地下城"
L["Delve Complete"]                                                     = "地下堡完成"
L["Interactions"]                                                       = "交互"
L["Tracking"]                                                           = "追踪"
L["Scenario Bar"]                                                       = "场景条"

-- =====================================================================
-- OptionsData.lua Profiles
-- =====================================================================
L["Vista"]                                                              = "Vista"
L["Current profile"]                                                    = "当前配置文件"
L["Select the profile currently in use."]                               = "选择当前使用的配置文件"
L["Use global profile (account-wide)"]                                  = "使用全局配置文件(账号范围)"
L["All characters use the same profile."]                               = "所有角色使用相同的配置文件."
L["Enable per specialization profiles"]                                 = "启用专精配置文件"
L["Pick different profiles per spec."]                                  = "为每项专精选择不同配置文件"
L["Specialization"]                                                     = "专精"
L["Sharing"]                                                            = "分享"
L["Import profile"]                                                     = "导入配置文件"
L["Import string"]                                                      = "导入字符串"
L["Export profile"]                                                     = "导出配置文件"
L["Select a profile to export."]                                        = "选择要导出的配置文件"
L["Export string"]                                                      = "导出字符串"
L["Copy from profile"]                                                  = "从配置文件复制"
L["Source profile for copying."]                                        = "用于复制的源配置文件"
L["Copy from selected"]                                                 = "从选中的复制"
L["Create"]                                                             = "创建"
L["Create new profile from Default template"]                           = "从默认模板创建新配置文件"
L["Creates a new profile with all default settings."]                   = "创建一个包含所有默认设置的新配置文件."
L["Creates a new profile copied from the selected source profile."]     = "创建一个从选定的源配置文件复制的新配置文件."
L["Delete profile"]                                                     = "删除配置文件"
L["Select a profile to delete (current and Default not shown)."]        = "选择要删除的配置文件(不显示当前和默认配置文件)"
L["Delete selected"]                                                    = "删除选中项"
-- L["Delete selected profile"]                                            = "Delete selected profile"  -- NEEDS TRANSLATION
L["Delete"]                                                             = "删除"
L["Deletes the selected profile."]                                      = "删除选中的配置文件"
L["Global profile"]                                                     = "全局配置文件"
L["Per-spec profiles"]                                                  = "专精配置文件"

-- =====================================================================
-- OptionsData.lua Modules
-- =====================================================================
L["Enable Focus module"]                                                = "启用聚焦模块"
L["Show the objective tracker for quests, world quests, rares, achievements, and scenarios."]= "显示任务、世界任务、稀有怪物、成就和场景的目标追踪器"
L["Enable Presence module"]                                             = "启用Presence模块"
L["Cinematic zone text and notifications (zone changes, level up, boss emotes, achievements, quest updates)."]= "显示电影化区域文本与情境通知（包含区域切换、角色升级、首领喊话、成就达成及任务进度）."
L["Enable Cache module"]                                                = "启用Cache模块"
L["Cinematic loot notifications (items, money, currency, reputation)."] = "电影级战利品通知(物品, 金币, 货币, 声望)."
L["Enable Vista module"]                                                = "启用Vista模块"
L["Cinematic square minimap with zone text, coordinates, and button collector."]= "电影级方形小地图, 带有区域文本, 坐标和按钮收集器."
L["Cinematic square minimap with zone text, coordinates, time, and button collector."]= "带有区域文本, 坐标, 时间和按钮收集器的电影式方形小地图."
L["Beta"]                                                               = "测试版"
L["Scaling"]                                                            = "缩放"
-- L["Global Toggles"]                                                     = "Global Toggles"  -- NEEDS TRANSLATION
-- L["Suite-wide class colour tinting and UI scale (global or per module)."]= "Dashboard background theme, class colour tinting, and UI scale (global or per module)."  -- NEEDS TRANSLATION
L["Global UI scale"]                                                    = "全局UI缩放"
L["Scale all sizes, spacings, and fonts by this factor (50–200%). Does not change your configured values."]= "按此因子缩放所有大小、间距和字体(50-200%)。不改变已配置的数值"
L["Per-module scaling"]                                                 = "每模块缩放"
L["Override the global scale with individual sliders for each module."] = "使用各模块单独滑块覆盖全局缩放"
L["Overrides the global scale with individual sliders for Focus, Presence, Vista, etc."]= "使用目标、情境、Vista等模块单独滑块覆盖全局缩放"
L["Doesn't change your configured values, only the effective display scale."]= "不改变已配置的数值，仅改变有效显示比例"
L["Focus scale"]                                                        = "聚焦缩放"
L["Scale for the Focus objective tracker (50–200%)."]                   = "聚焦目标追踪器缩放(50-200%)"
L["Presence scale"]                                                     = "情境缩放"
L["Scale for the Presence cinematic text (50–200%)."]                   = "Presence过场文本缩放(50-200%)"
L["Vista scale"]                                                        = "Vista缩放"
L["Scale for the Vista minimap module (50–200%)."]                      = "Vista小地图模块缩放(50-200%)"
L["Insight scale"]                                                      = "洞察缩放"
L["Scale for the Insight tooltip module (50–200%)."]                    = "洞察提示模块缩放(50-200%)"
L["Cache scale"]                                                        = "Cache缩放"
L["Scale for the Cache loot toast module (50–200%)."]                   = "Cache战利品提示模块缩放(50-200%)"
L["Enable Horizon Insight module"]                                      = "启用Horizon洞察模块"
L["Cinematic tooltips with class colors, spec display, and faction icons."]= "电影级提示框, 带有职业颜色, 专精显示和阵营图标."
L["Horizon Insight"]                                                    = "Horizon洞察"
L["Insight"]                                                            = "洞察"
L["Tooltip anchor mode"]                                                = "提示锚定模式"
L["Where tooltips appear: follow cursor or fixed position."]            = "提示显示位置：跟随光标或固定位置"
L["Cursor"]                                                             = "光标"
L["Fixed"]                                                              = "固定"
L["Show anchor to move"]                                                = "显示锚点以移动"
-- L["Click to show or hide the anchor. Drag to set position, right-click to confirm."]= "Click to show or hide the anchor. Drag to set position, right-click to confirm."  -- NEEDS TRANSLATION
L["Show draggable frame to set fixed tooltip position. Drag, then right-click to confirm."]= "显示可拖动框架设置固定提示位置。拖动后右键确认"
L["Reset tooltip position"]                                             = "重置提示位置"
L["Reset fixed position to default."]                                   = "固定位置重置为默认值"
L["Tooltip background color"]                                           = "提示框背景颜色"
L["Color of the tooltip background."]                                   = "提示框背景颜色."
L["Tooltip background opacity"]                                         = "提示框背景不透明度"
L["Tooltip background opacity (0–100%)."]                               = "提示框背景不透明度 (0–100%)."
L["Tooltip font"]                                                       = "提示框字体"
L["Font family used for all tooltip text."]                             = "用于所有提示框文字的字体。"
L["Tooltips"]                                                           = "提示"
L["Item Tooltip"]                                                       = "物品提示"
L["Show transmog status"]                                               = "显示幻化状态"
L["Show whether you have collected the appearance of an item you hover over."]= "显示是否已收集鼠标悬停物品的外观"
L["Player Tooltip"]                                                     = "玩家提示"
L["Show guild rank"]                                                    = "显示公会等级"
L["Append the player's guild rank next to their guild name."]           = "在玩家的公会名称旁边附加其公会等级."
L["Show Mythic+ score"]                                                 = "显示史诗+分数"
L["Show the player's current season Mythic+ score, colour-coded by tier."]= "显示玩家当前赛季史诗+分数，按等级颜色编码"
L["Show item level"]                                                    = "显示物品等级"
L["Show the player's equipped item level after inspecting them."]       = "查看玩家后显示其装备物品等级"
L["Show honor level"]                                                   = "显示荣誉等级"
L["Show the player's PvP honor level in the tooltip."]                  = "提示中显示玩家PvP荣誉等级"
L["Show PvP title"]                                                     = "显示PvP称号"
L["Show the player's PvP title (e.g. Gladiator) in the tooltip."]       = "提示中显示玩家PvP称号(如角斗士)"
-- L["Character title"]                                                    = "Character title"  -- NEEDS TRANSLATION
-- L["Show the player's selected title (achievement or PvP) in the name line."]= "Show the player's selected title (achievement or PvP) in the name line."  -- NEEDS TRANSLATION
-- L["Title color"]                                                        = "Title color"  -- NEEDS TRANSLATION
-- L["Color of the character title in the player tooltip name line."]      = "Color of the character title in the player tooltip name line."  -- NEEDS TRANSLATION
L["Show status badges"]                                                 = "显示状态徽章"
L["Show inline badges for combat, AFK, DND, PvP flag, party/raid membership, friends, and whether the player is targeting you."]= "显示战斗、暂离、忙碌、PvP标志、队伍/团队成员、好友以及玩家是否正在瞄准您的状态徽章"
L["Show mount info"]                                                    = "显示坐骑信息"
L["When hovering a mounted player, show their mount name, source, and whether you own it."]= "悬停已坐骑玩家时显示其坐骑名称、来源及是否拥有"
-- L["Blank separator"]                                                    = "Blank separator"  -- NEEDS TRANSLATION
-- L["Use a blank line instead of dashes between tooltip sections."]       = "Use a blank line instead of dashes between tooltip sections."  -- NEEDS TRANSLATION
-- L["Show icons"]                                                         = "Show icons"  -- NEEDS TRANSLATION
-- L["Class icon style"]                                                   = "Class icon style"  -- NEEDS TRANSLATION
-- L["Use Default (Blizzard) or RondoMedia class icons on the class/spec line."]= "Use Default (Blizzard) or RondoMedia class icons on the class/spec line."  -- NEEDS TRANSLATION
-- L["RondoMedia class icons by RondoFerrari — https://www.curseforge.com/wow/addons/rondomedia"]= "RondoMedia class icons by RondoFerrari — https://www.curseforge.com/wow/addons/rondomedia"  -- NEEDS TRANSLATION
-- L["Default"]                                                            = "Default"  -- NEEDS TRANSLATION
-- L["Show faction, spec, mount, and Mythic+ icons in tooltips."]          = "Show faction, spec, mount, and Mythic+ icons in tooltips."  -- NEEDS TRANSLATION
L["Cache"]                                                              = "Cache"
L["General"]                                                            = "常规"
L["Position"]                                                           = "位置"
L["Reset position"]                                                     = "重置位置"
L["Reset loot toast position to default."]                              = "战利品提示位置重置为默认值"

-- =====================================================================
-- OptionsData.lua Layout
-- =====================================================================
L["Lock position"]                                                      = "锁定位置"
L["Prevent dragging the tracker."]                                      = "防止拖动追踪器"
L["Grow upward"]                                                        = "向上增长"
L["Grow-up header"]                                                     = "向上增长标题"
L["When growing upward: keep header at bottom, or at top until collapsed."]= "向上增长时：标题保持在底部，或折叠前保持在顶部"
L["Header at bottom"]                                                   = "标题在底部"
L["Header slides on collapse"]                                          = "折叠时标题滑动"
L["Anchor at bottom so the list grows upward."]                         = "底部锚定,列表向上增长"
L["Start collapsed"]                                                    = "开始时折叠"
L["Start with only the header shown until you expand."]                 = "开始时仅显示标题，展开后显示内容"
-- L["Align content right"]                                                = "Align content right"  -- NEEDS TRANSLATION
-- L["Right-align quest titles and objectives within the panel."]          = "Right-align quest titles and objectives within the panel."  -- NEEDS TRANSLATION
L["Panel width"]                                                        = "面板宽度"
L["Tracker width in pixels."]                                           = "追踪器宽度(像素)"
L["Max content height"]                                                 = "最大内容高度"
L["Max height of the scrollable list (pixels)."]                        = "可滚动列表最大高度(像素)"

-- =====================================================================
-- OptionsData.lua Visibility
-- =====================================================================
L["Always show M+ block"]                                               = "始终显示史诗+区块"
L["Show the M+ block whenever an active keystone is running"]           = "有活跃钥石运行时显示史诗+块"
L["Show in dungeon"]                                                    = "地下城中显示"
L["Show tracker in party dungeons."]                                    = "队伍地下城中显示追踪器"
L["Show in raid"]                                                       = "团队副本中显示"
L["Show tracker in raids."]                                             = "团队副本中显示追踪器"
L["Show in battleground"]                                               = "战场中显示"
L["Show tracker in battlegrounds."]                                     = "战场中显示追踪器"
L["Show in arena"]                                                      = "竞技场中显示"
L["Show tracker in arenas."]                                            = "竞技场中显示追踪器"
L["Hide in combat"]                                                     = "战斗中隐藏"
L["Hide tracker and floating quest item in combat."]                    = "战斗中隐藏任务追踪器和浮动任务物品"
L["Combat visibility"]                                                  = "战斗可见性"
L["How the tracker behaves in combat: show, fade to reduced opacity, or hide."]= "追踪器在战斗中的行为：显示、淡出或隐藏"
L["Show"]                                                               = "显示"
L["Fade"]                                                               = "淡化"
L["Hide"]                                                               = "隐藏"
L["Combat fade opacity"]                                                = "战斗淡化透明度"
L["How visible the tracker is when faded in combat (0 = invisible). Only applies when Combat visibility is Fade."]= "战斗中追踪器淡出时的可见程度(0 = 不可见)。仅当战斗可见性为淡出时生效"
L["Mouseover"]                                                          = "鼠标悬停"
L["Show only on mouseover"]                                             = "仅鼠标悬停时显示"
L["Fade tracker when not hovering; move mouse over it to show."]        = "鼠标未悬停时淡化追踪器; 将鼠标移上去以显示."
L["Faded opacity"]                                                      = "淡化透明度"
L["How visible the tracker is when faded (0 = invisible)."]             = "追踪器淡出时的可见程度(0 = 不可见)"
L["Only show quests in current zone"]                                   = "仅显示当前区域的任务"
L["Hide quests outside your current zone."]                             = "隐藏当前区域外的任务"

-- =====================================================================
-- OptionsData.lua Display — Header
-- =====================================================================
L["Show quest count"]                                                   = "显示任务计数"
L["Show quest count in header."]                                        = "标题中显示任务计数"
L["Header count format"]                                                = "标题计数格式"
L["Tracked/in-log or in-log/max-slots. Tracked excludes world/live-in-zone quests."]= "已追踪/日志中或日志中/最大槽位。已追踪排除世界/区域内实时任务"
L["Show header divider"]                                                = "显示标题分隔符"
L["Show the line below the header."]                                    = "标题下方显示线条"
L["Header divider color"]                                               = "标题分隔符颜色"
L["Color of the line below the header."]                                = "标题栏下方线条的颜色."
L["Super-minimal mode"]                                                 = "超极简模式"
L["Hide header for a pure text list."]                                  = "纯文本列表隐藏标题"
L["Show options button"]                                                = "显示选项按钮"
L["Show the Options button in the tracker header."]                     = "追踪器标题中显示选项按钮"
L["Header color"]                                                       = "标题颜色"
L["Color of the OBJECTIVES header text."]                               = "目标标题栏文本的颜色."
L["Header height"]                                                      = "标题高度"
L["Height of the header bar in pixels (18–48)."]                        = "标题栏高度(像素)(18-48)"

-- =====================================================================
-- OptionsData.lua Display — List
-- =====================================================================
L["Show section headers"]                                               = "显示分类标题"
L["Show category labels above each group."]                             = "每个分组上方显示分类标签"
L["Show category headers when collapsed"]                               = "折叠时显示分类标题"
L["Keep section headers visible when collapsed; click to expand a category."]= "折叠时保持分类标题可见；点击展开分类"
L["Show Nearby (Current Zone) group"]                                   = "显示附近(当前区域)分组"
L["Show in-zone quests in a dedicated Current Zone section. When off, they appear in their normal category."]= "在专用当前区域分类中显示区域内任务。关闭时显示在正常分类中"
L["Show zone labels"]                                                   = "显示区域标签"
L["Show zone name under each quest title."]                             = "每个任务标题下方显示区域名称"
L["Active quest highlight"]                                             = "当前任务高亮"
L["How the focused quest is highlighted."]                              = "聚焦任务的高亮显示方式"
L["Show quest item buttons"]                                            = "显示任务物品按钮"
L["Show usable quest item button next to each quest."]                  = "每个任务旁显示可用任务物品按钮"
-- L["Tooltips on hover"]                                                  = "Tooltips on hover"  -- NEEDS TRANSLATION
-- L["Show tooltips when hovering over tracker entries, item buttons, and scenario blocks."]= "Show tooltips when hovering over tracker entries, item buttons, and scenario blocks."  -- NEEDS TRANSLATION
-- L["Show WoWhead link in tooltips"]                                      = "Show WoWhead link in tooltips"  -- NEEDS TRANSLATION
-- L["When a tooltip is shown, add a link to open the quest, achievement, or NPC on WoWhead."]= "When a tooltip is shown, add a link to open the quest, achievement, or NPC on WoWhead."  -- NEEDS TRANSLATION
-- L["View on WoWhead"]                                                    = "View on WoWhead"  -- NEEDS TRANSLATION
-- L["Copy link"]                                                          = "Copy link"  -- NEEDS TRANSLATION
-- L["Copy the URL below (Ctrl+C) and paste in your browser."]             = "Copy the URL below (Ctrl+C) and paste in your browser."  -- NEEDS TRANSLATION
L["Show objective numbers"]                                             = "显示目标编号"
L["Objective prefix"]                                                   = "目标前缀"
L["Prefix each objective with a number or hyphen."]                     = "用数字或连字符作为目标前缀"
L["Numbers (1. 2. 3.)"]                                                 = "数字(1. 2. 3.)"
L["Hyphens (-)"]                                                        = "连字符(-)"
-- L["After section header"]                                               = "After section header"  -- NEEDS TRANSLATION
-- L["Before section header"]                                              = "Before section header"  -- NEEDS TRANSLATION
-- L["Below header"]                                                       = "Below header"  -- NEEDS TRANSLATION
L["Inline below title"]                                                 = "标题下方内联"
L["Prefix objectives with 1., 2., 3."]                                  = "用 1.、2.、3. 作为目标前缀"
L["Show completed count"]                                               = "显示已完成计数"
L["Show X/Y progress in quest title."]                                  = "任务标题中显示X/Y进度"
L["Show objective progress bar"]                                        = "显示目标进度条"
L["Show a progress bar under objectives that have numeric progress (e.g. 3/250). Only applies to entries with a single arithmetic objective where the required amount is greater than 1."]= "在具有数字进度(例如 3/250)的目标下方显示进度条。仅适用于具有单个算术目标且所需数量大于1的条目"
L["Use category color for progress bar"]                                = "使用分类颜色作为进度条"
L["When on, the progress bar matches the quest/achievement category color. When off, uses the custom fill color below."]= "启用时进度条与任务/成就分类颜色匹配。禁用时使用下方自定义填充颜色"
L["Progress bar texture"]                                               = "进度条纹理"
L["Progress bar types"]                                                 = "进度条类型"
L["Texture for the progress bar fill."]                                 = "进度条填充纹理."
L["Texture for the progress bar fill. Solid uses your chosen colors. SharedMedia addons add more options."]= "填充纹理. 纯色使用所选颜色. SharedMedia 插件可提供更多选项."
L["Show progress bar for X/Y objectives, percent-only objectives, or both."]= "为X/Y目标、仅百分比目标或两者显示进度条"
L["X/Y: objectives like 3/10. Percent: objectives like 45%."]           = "X/Y：如 3/10 的目标。百分比：如 45% 的目标"
L["X/Y only"]                                                           = "仅X/Y"
L["Percent only"]                                                       = "仅百分比"
L["Use tick for completed objectives"]                                  = "已完成目标使用勾号"
L["When on, completed objectives show a checkmark (✓) instead of green color."]= "启用时已完成目标显示勾号(✓)而非绿色"
L["Show entry numbers"]                                                 = "显示条目编号"
L["Prefix quest titles with 1., 2., 3. within each category."]          = "各分类中用 1.、2.、3. 作为任务标题前缀"
L["Completed objectives"]                                               = "已完成目标"
L["For multi-objective quests, how to display objectives you've completed (e.g. 1/1)."]= "多目标任务已完成目标的显示方式(例如 1/1)"
L["Show all"]                                                           = "显示全部"
L["Fade completed"]                                                     = "淡出已完成"
L["Hide completed"]                                                     = "隐藏已完成"
L["Show icon for in-zone auto-tracking"]                                = "显示区域内自动追踪图标"
L["Display an icon next to auto-tracked world quests and weeklies/dailies that are not yet in your quest log (in-zone only)."]= "在自动追踪的世界任务和周常/日常任务旁边显示图标, 这些任务尚未在您的任务日志中(仅限区域内)."
L["Auto-track icon"]                                                    = "自动追踪图标"
L["Choose which icon to display next to auto-tracked in-zone entries."] = "选择在自动追踪的区域条目旁边显示哪个图标."
L["Append ** to world quests and weeklies/dailies that are not yet in your quest log (in-zone only)."]= "在尚未在任务日志中的世界任务和周常/日常任务后附加 **(仅限区域内)."

-- =====================================================================
-- OptionsData.lua Display — Spacing
-- =====================================================================
L["Compact mode"]                                                       = "紧凑模式"
L["Preset: sets entry and objective spacing to 4 and 1 px."]            = "预设：将条目和目标间距设置为4和1像素"
L["Spacing preset"]                                                     = "间距预设"
L["Preset for entry and objective spacing: Default (8/2 px), Compact (4/1 px), Spaced (12/3 px), or Custom (use sliders)."]= "预设: 默认(8/2 px)、紧凑(4/1 px)、宽松(12/3 px)或自定义(使用滑块)."
L["Compact version"]                                                    = "紧凑版本"
L["Spaced version"]                                                     = "宽松版本"
L["Spacing between quest entries (px)"]                                 = "任务条目间间距(像素)"
L["Vertical gap between quest entries."]                                = "任务条目间垂直间距"
L["Spacing before category header (px)"]                                = "分类标题前间距(像素)"
L["Gap between last entry of a group and the next category label."]     = "分组末尾条目与下一分类标签之间的间距"
L["Spacing after category header (px)"]                                 = "分类标题后间距(像素)"
L["Gap between category label and first quest entry below it."]         = "分类标签与下方首个任务条目之间的间距"
L["Spacing between objectives (px)"]                                    = "目标间间距(像素)"
L["Vertical gap between objective lines within a quest."]               = "任务内目标行间垂直间距"
L["Title to content"]                                                   = "标题到内容"
L["Vertical gap between quest title and objectives or zone below it."]  = "任务标题与下方目标或区域之间的垂直间距."
L["Spacing below header (px)"]                                          = "标题下方间距(像素)"
L["Vertical gap between the objectives bar and the quest list."]        = "目标条和任务列表间垂直间距"
L["Reset spacing"]                                                      = "重置间距"

-- =====================================================================
-- OptionsData.lua Display — Other
-- =====================================================================
L["Show quest level"]                                                   = "显示任务等级"
L["Show quest level next to title."]                                    = "标题旁显示任务等级"
L["Dim non-focused quests"]                                             = "淡化非当前任务"
L["Slightly dim title, zone, objectives, and section headers that are not focused."]= "稍微淡化未聚焦的标题、区域、目标和分类标题"
L["Dim unfocused entries"]                                              = "淡化未聚焦条目"
L["Click a section header to expand that category."]                    = "点击分类标题展开该分类."

-- =====================================================================
-- Features — Rare bosses
-- =====================================================================
L["Show rare bosses"]                                                   = "显示稀有首领"
L["Show rare boss vignettes in the list."]                              = "列表中显示稀有首领标记"
L["Rare Loot"]                                                          = "稀有战利品"
L["Show treasure and item vignettes in the Rare Loot list."]            = "稀有战利品列表中显示宝藏和物品标记"
L["Rare sound volume"]                                                  = "稀有首领声音音量"
L["Volume of the rare alert sound (50–200%)."]                          = "稀有首领警报声音音量(50-200%)"
L["Boost or reduce the rare alert volume. 100% = normal; 150% = louder."]= "提升或降低稀有首领警报音量。100% = 正常；150% = 更大声"
L["Rare added sound"]                                                   = "添加稀有首领声音"
L["Play a sound when a rare is added."]                                 = "添加稀有首领时播放声音"

-- =====================================================================
-- OptionsData.lua Features — World quests
-- =====================================================================
L["Show in-zone world quests"]                                          = "显示区域内世界任务"
L["Auto-add world quests in your current zone. When off, only quests you've tracked or world quests you're in close proximity to appear (Blizzard default)."]= "自动添加当前区域的世界任务. 关闭时, 仅显示您已追踪或靠近的世界任务(暴雪默认)."

-- =====================================================================
-- OptionsData.lua Features — Floating quest item
-- =====================================================================
L["Show floating quest item"]                                           = "显示浮动任务物品"
L["Show quick-use button for the focused quest's usable item."]         = "为聚焦任务的可用物品显示快速使用按钮"
L["Lock floating quest item position"]                                  = "锁定浮动任务物品位置"
L["Prevent dragging the floating quest item button."]                   = "防止拖动浮动任务物品按钮"
L["Floating quest item source"]                                         = "浮动任务物品来源"
L["Which quest's item to show: super-tracked first, or current zone first."]= "显示哪个任务的物品：优先显示超级追踪还是当前区域"
L["Super-tracked, then first"]                                          = "超级追踪，然后首个"
L["Current zone first"]                                                 = "优先当前区域"

-- =====================================================================
-- OptionsData.lua Features — Mythic+
-- =====================================================================
L["Show Mythic+ block"]                                                 = "显示史诗+块"
L["Show timer, completion %, and affixes in Mythic+ dungeons."]         = "史诗+地下城显示计时器、完成百分比和词缀"
L["M+ block position"]                                                  = "史诗+块位置"
L["Position of the Mythic+ block relative to the quest list."]          = "史诗+块相对于任务列表的位置"
L["Show affix icons"]                                                   = "显示词缀图标"
L["Show affix icons next to modifier names in the M+ block."]           = "史诗+块中修饰符名称旁显示词缀图标"
L["Show affix descriptions in tooltip"]                                 = "提示中显示词缀描述"
L["Show affix descriptions when hovering over the M+ block."]           = "悬停史诗+块时显示词缀描述"
L["M+ completed boss display"]                                          = "史诗+已击败首领显示"
L["How to show defeated bosses: checkmark icon or green color."]        = "已击败首领的显示方式：勾选图标或绿色"
L["Checkmark"]                                                          = "勾号"
L["Green color"]                                                        = "绿色"

-- =====================================================================
-- OptionsData.lua Features — Achievements
-- =====================================================================
L["Show achievements"]                                                  = "显示成就"
L["Show tracked achievements in the list."]                             = "列表中显示追踪的成就"
L["Show completed achievements"]                                        = "显示已完成成就"
L["Include completed achievements in the tracker. When off, only in-progress tracked achievements are shown."]= "追踪器中包含已完成成就。关闭时仅显示进行中的追踪成就"
L["Show achievement icons"]                                             = "显示成就图标"
L["Show each achievement's icon next to the title. Requires 'Show quest type icons' in Display."]= "在成就标题旁显示图标。需要在显示中启用'显示任务类型图标'"
L["Only show missing requirements"]                                     = "仅显示缺失的要求"
L["Show only criteria you haven't completed for each tracked achievement. When off, all criteria are shown."]= "仅显示每个追踪成就中未完成的标准。关闭时显示所有标准"

-- =====================================================================
-- OptionsData.lua Features — Endeavors
-- =====================================================================
L["Show endeavors"]                                                     = "显示宏图"
L["Show tracked Endeavors (Player Housing) in the list."]               = "列表中显示追踪的宏图(玩家住房)"
L["Show completed endeavors"]                                           = "显示已完成宏图"
L["Include completed Endeavors in the tracker. When off, only in-progress tracked Endeavors are shown."]= "追踪器中包含已完成宏图。关闭时仅显示进行中的追踪宏图"

-- =====================================================================
-- OptionsData.lua Features — Decor
-- =====================================================================
L["Show decor"]                                                         = "显示装饰"
L["Show tracked housing decor in the list."]                            = "列表中显示追踪的住房装饰"
L["Show decor icons"]                                                   = "显示装饰图标"
L["Show each decor item's icon next to the title. Requires 'Show quest type icons' in Display."]= "在装饰物品标题旁显示图标。需要在显示中启用'显示任务类型图标'"

-- =====================================================================
-- OptionsData.lua Features — Adventure Guide
-- =====================================================================
L["Adventure Guide"]                                                    = "冒险指南"
L["Show Traveler's Log"]                                                = "显示旅行者日志"
L["Show tracked Traveler's Log objectives (Shift+click in Adventure Guide) in the list."]= "列表中显示追踪的旅行者日志目标(冒险指南中Shift+点击)"
L["Auto-remove completed activities"]                                   = "自动移除已完成的活动"
L["Automatically stop tracking Traveler's Log activities once they have been completed."]= "旅行者日志活动完成后自动停止追踪."

-- =====================================================================
-- OptionsData.lua Features — Scenario & Delve
-- =====================================================================
L["Show scenario events"]                                               = "显示场景事件"
L["Show active scenario and Delve activities. Delves appear in DELVES; other scenarios in SCENARIO EVENTS."]= "显示活动场景和地下堡活动。地下堡显示在地下堡分类；其他场景显示在场景事件中"
L["Track Delve, Dungeon, and scenario activities."]                     = "追踪地下堡、地下城和场景活动"
L["Delves appear in Delves section; dungeons in Dungeon; other scenarios in Scenario Events."]= "地下堡显示在地下堡分类;地下城显示在地下城分类;其他场景显示在场景事件中."
L["Delves appear in Delves section; other scenarios in Scenario Events."]= "地下堡显示在地下堡分类;其他场景显示在场景事件中."
L["Delve affix names"]                                                  = "地下堡词缀名称."
L["Delve/Dungeon only"]                                                 = "仅地下堡/地下城."
L["Scenario debug logging"]                                             = "场景调试日志"
L["Log scenario API data to chat. Use /h debug focus scendebug to toggle."]= "将场景API数据记录到聊天。使用 /h debug focus scendebug 切换"
L["Prints C_ScenarioInfo criteria and widget data when in a scenario. Helps diagnose display issues like Abundance 46/300."]= "场景中打印C_ScenarioInfo条件和小组件数据。有助于诊断显示问题，如丰饶 46/300"
L["Hide other categories in Delve or Dungeon"]                          = "地下堡或地下城中隐藏其他分类"
L["In Delves or party dungeons, show only the Delve/Dungeon section."]  = "地下堡或队伍地下城中仅显示地下堡/地下城分类"
L["Use delve name as section header"]                                   = "使用地下堡名称作为分类标题"
L["When in a Delve, show the delve name, tier, and affixes as the section header instead of a separate banner. Disable to show the Delve block above the list."]= "地下堡中显示名称、等级和词缀作为分类标题而非单独横幅。禁用以在列表上方显示地下堡块"
L["Show affix names in Delves"]                                         = "地下堡中显示词缀名称"
L["Show season affix names on the first Delve entry. Requires Blizzard's objective tracker widgets to be populated; may not show when using a full tracker replacement."]= "首个地下堡条目显示赛季词缀名称。需要暴雪目标追踪器小组件已填充；使用完整追踪器替换时可能不显示"
L["Cinematic scenario bar"]                                             = "电影级场景条"
L["Show timer and progress bar for scenario entries."]                  = "场景条目显示计时器和进度条"
L["Show timer"]                                                         = "显示计时器"
L["Show countdown timer on timed quests, events, and scenarios. When off, timers are hidden for all entry types."]= "计时任务、事件和场景显示倒计时器。关闭时所有条目类型计时器隐藏"
L["Timer display"]                                                      = "计时器显示"
L["Color timer by remaining time"]                                      = "按剩余时间为计时器着色"
L["Green when plenty of time left, yellow when running low, red when critical."]= "剩余时间充足为绿色，即将耗尽为黄色，危急为红色"
L["Where to show the countdown: bar below objectives or text beside the quest name."]= "倒计时显示位置：目标下方条形或任务名称旁文本"
L["Bar below"]                                                          = "下方条形"
L["Inline beside title"]                                                = "标题旁内联"

-- =====================================================================
-- OptionsData.lua Typography — Font
-- =====================================================================
L["Font family."]                                                       = "字体"
L["Title font"]                                                         = "标题字体"
L["Zone font"]                                                          = "区域字体"
L["Objective font"]                                                     = "目标字体"
L["Section font"]                                                       = "分类字体"
L["Use global font"]                                                    = "使用全局字体"
L["Font family for quest titles."]                                      = "任务标题字体"
L["Font family for zone labels."]                                       = "区域标签字体"
L["Font family for objective text."]                                    = "目标文本字体"
L["Font family for section headers."]                                   = "分类标题字体"
L["Header size"]                                                        = "标题大小"
L["Header font size."]                                                  = "标题字体大小"
L["Title size"]                                                         = "标题大小"
L["Quest title font size."]                                             = "任务标题字体大小"
L["Objective size"]                                                     = "目标大小"
L["Objective text font size."]                                          = "目标文本字体大小"
L["Zone size"]                                                          = "区域大小"
L["Zone label font size."]                                              = "区域标签字体大小"
L["Section size"]                                                       = "分类大小"
L["Section header font size."]                                          = "分类标题字体大小"
L["Progress bar font"]                                                  = "进度条字体"
L["Font family for the progress bar label."]                            = "进度条标签字体"
L["Progress bar text size"]                                             = "进度条文本大小"
L["Font size for the progress bar label. Also adjusts bar height. Affects quest objectives, scenario progress, and scenario timer bars."]= "进度条标签字体大小，同时调整进度条高度。影响任务目标、场景进度和场景计时条"
L["Progress bar fill"]                                                  = "进度条填充"
L["Progress bar text"]                                                  = "进度条文本"
L["Outline"]                                                            = "轮廓"
L["Font outline style."]                                                = "字体轮廓样式"

-- =====================================================================
-- OptionsData.lua Typography — Text case
-- =====================================================================
L["Header text case"]                                                   = "标题文本大小写"
L["Display case for header."]                                           = "标题的大小写格式"
L["Section header case"]                                                = "分类标题大小写"
L["Display case for category labels."]                                  = "分类标签的大小写格式"
L["Quest title case"]                                                   = "任务标题大小写"
L["Display case for quest titles."]                                     = "任务标题的大小写格式"

-- =====================================================================
-- OptionsData.lua Typography — Shadow
-- =====================================================================
L["Show text shadow"]                                                   = "显示文本阴影"
L["Enable drop shadow on text."]                                        = "启用文本阴影."
L["Shadow X"]                                                           = "阴影X"
L["Horizontal shadow offset."]                                          = "水平阴影偏移"
L["Shadow Y"]                                                           = "阴影Y"
L["Vertical shadow offset."]                                            = "垂直阴影偏移"
L["Shadow alpha"]                                                       = "阴影透明度"
L["Shadow opacity (0–1)."]                                              = "阴影不透明度(0-1)"

-- =====================================================================
-- OptionsData.lua Typography — Mythic+ Typography
-- =====================================================================
L["Mythic+ Typography"]                                                 = "史诗+排版"
L["Dungeon name size"]                                                  = "地下城名称大小"
L["Font size for dungeon name (8–32 px)."]                              = "地下城名称字体大小(8-32像素)"
L["Dungeon name color"]                                                 = "地下城名称颜色"
L["Text color for dungeon name."]                                       = "地下城名称文本颜色"
L["Timer size"]                                                         = "计时器大小"
L["Font size for timer (8–32 px)."]                                     = "计时器字体大小(8-32像素)"
L["Timer color"]                                                        = "计时器颜色"
L["Text color for timer (in time)."]                                    = "计时器文本颜色(在时间内)"
L["Timer overtime color"]                                               = "计时器超时颜色"
L["Text color for timer when over the time limit."]                     = "超时计时器文本颜色"
L["Progress size"]                                                      = "进度大小"
L["Font size for enemy forces (8–32 px)."]                              = "敌方部队字体大小(8-32像素)"
L["Progress color"]                                                     = "进度颜色"
L["Text color for enemy forces."]                                       = "敌方部队文本颜色"
L["Bar fill color"]                                                     = "条形填充颜色"
L["Progress bar fill color (in progress)."]                             = "进度条填充颜色(进行中)"
L["Bar complete color"]                                                 = "条形完成颜色"
L["Progress bar fill color when enemy forces are at 100%."]             = "敌方部队达到100%时的进度条填充颜色"
L["Affix size"]                                                         = "词缀大小"
L["Font size for affixes (8–32 px)."]                                   = "词缀字体大小(8-32像素)"
L["Affix color"]                                                        = "词缀颜色"
L["Text color for affixes."]                                            = "词缀文本颜色"
L["Boss size"]                                                          = "首领名称大小"
L["Font size for boss names (8–32 px)."]                                = "首领名称字体大小(8-32像素)"
L["Boss color"]                                                         = "首领名称颜色"
L["Text color for boss names."]                                         = "首领名称文本颜色"
L["Reset Mythic+ typography"]                                           = "重置史诗+排版"

-- =====================================================================
-- OptionsData.lua Appearance
-- =====================================================================
-- L["Frame"]                                                              = "Frame"  -- NEEDS TRANSLATION
-- L["Class colours - Dashboard"]                                          = "Class colours - Dashboard"  -- NEEDS TRANSLATION
-- L["Class Colours"]                                                      = "Class Colours"  -- NEEDS TRANSLATION
-- L["Enable all class colours"]                                           = "Enable all class colours"  -- NEEDS TRANSLATION
-- L["Toggle class colours on or off for all modules at once."]            = "Toggle class colours on or off for all modules at once."  -- NEEDS TRANSLATION
-- L["Dashboard"]                                                          = "Dashboard"  -- NEEDS TRANSLATION
-- L["Tint Focus header title, category section headers, main and between-section dividers, and super-tracked highlight bars and borders with your class colour."]= "Tint Focus header title, category section headers, main and between-section dividers, and super-tracked highlight bars and borders with your class colour."  -- NEEDS TRANSLATION
-- L["Tint Presence toast title and divider with your class colour."]      = "Tint Presence toast title and divider with your class colour."  -- NEEDS TRANSLATION
-- L["Tint Vista minimap, addon-bar, and panel borders and text with your class colour."]= "Tint Vista minimap, addon-bar, and panel borders and text with your class colour."  -- NEEDS TRANSLATION
-- L["Use class colour for player tooltip name, class line, and border."]  = "Use class colour for player tooltip name, class line, and border."  -- NEEDS TRANSLATION
-- L["Tint Cache loot icon glow and edit/anchor borders with your class colour."]= "Tint Cache loot icon glow and edit/anchor borders with your class colour."  -- NEEDS TRANSLATION
-- L["Tint the character name on the Essence sheet with your class colour."]= "Tint the character name on the Essence sheet with your class colour."  -- NEEDS TRANSLATION
-- L["Class colors"]                                                       = "Class colors"  -- NEEDS TRANSLATION
-- L["Tint dashboard accents, dividers, and highlights with your class colour."]= "Tint dashboard accents, dividers, and highlights with your class colour."  -- NEEDS TRANSLATION
-- L["Theme"]                                                              = "Theme"  -- NEEDS TRANSLATION
-- L["Dashboard background"]                                               = "Dashboard background"  -- NEEDS TRANSLATION
-- L["Background style for the module dashboard window (Axis). Default is flat; Midnight uses bundled artwork; Specialisation (auto) uses the in-game talent UI background for your current specialization."]= "Background style for the module dashboard window (Axis). Default is flat; Midnight uses bundled artwork; Specialisation (auto) uses the in-game talent UI background for your current specialization."  -- NEEDS TRANSLATION
-- L["Dashboard background Midnight"]                                      = "Midnight"  -- NEEDS TRANSLATION
-- L["Dashboard background Class talents"]                                 = "Specialisation (auto)"  -- NEEDS TRANSLATION
-- L["Dashboard background opacity"]                                       = "Dashboard background opacity"  -- NEEDS TRANSLATION
-- L["Adjust the opacity of the dashboard background (50–100%). Lower values let more of the game world show through."]= "Adjust the opacity of the dashboard background (50–100%). Lower values let more of the game world show through."  -- NEEDS TRANSLATION
L["Backdrop opacity"]                                                   = "背景透明度"
L["Panel background opacity (0–1)."]                                    = "面板背景不透明度(0-1)"
L["Show border"]                                                        = "显示边框"
L["Show border around the tracker."]                                    = "追踪器周围显示边框"
L["Show scroll indicator"]                                              = "显示滚动指示器"
L["Show a visual hint when the list has more content than is visible."] = "列表有更多内容不可见时显示视觉提示"
L["Scroll indicator style"]                                             = "滚动指示器样式"
L["Choose between a fade-out gradient or a small arrow to indicate scrollable content."]= "选择渐变或小箭头来指示可滚动内容."
L["Arrow"]                                                              = "箭头"
L["Highlight alpha"]                                                    = "高亮透明度"
L["Opacity of focused quest highlight (0–1)."]                          = "聚焦任务高亮的不透明度(0-1)"
L["Bar width"]                                                          = "条形宽度"
L["Width of bar-style highlights (2–6 px)."]                            = "进度条高亮宽度(2-6像素)"

-- =====================================================================
-- OptionsData.lua Organization
-- =====================================================================
L["Activity"]                                                           = "活动"
L["Content"]                                                            = "内容"
L["Sorting"]                                                            = "排序"
-- L["Elements"]                                                           = "Elements"  -- NEEDS TRANSLATION
-- L["Category order"]                                                     = "Category order"  -- NEEDS TRANSLATION
-- L["Category color for bar"]                                             = "Category color for bar"  -- NEEDS TRANSLATION
-- L["Checkmark for completed"]                                            = "Checkmark for completed"  -- NEEDS TRANSLATION
L["Current Quest category"]                                             = "当前任务分类"
L["Current Quest window"]                                               = "当前任务窗口"
L["Show quests with recent progress at the top."]                       = "最近有进展的任务显示在顶部"
L["Seconds of recent progress to show in Current Quest (30–120)."]      = "当前任务中显示的最近进展秒数(30-120)"
L["Quests you made progress on in the last minute appear in a dedicated section."]= "过去一分钟内有进展的任务显示在专用分类中"
L["Focus category order"]                                               = "聚焦分类顺序"
L["Drag to reorder categories. DELVES and SCENARIO EVENTS stay first."] = "拖动以重新排序类别. 地穴和场景事件保持在最前."
-- L["Drag to reorder. Delves and Scenarios stay first."]                  = "Drag to reorder. Delves and Scenarios stay first."  -- NEEDS TRANSLATION
L["Focus sort mode"]                                                    = "聚焦排序模式"
L["Order of entries within each category."]                             = "各分类中条目的顺序"
L["Auto-track accepted quests"]                                         = "自动追踪已接受任务"
L["When you accept a quest (quest log only, not world quests), add it to the tracker automatically."]= "接受任务时(仅任务日志，不包括世界任务)自动添加到追踪器"
L["Require Ctrl for focus & remove"]                                    = "需要Ctrl键聚焦和移除"
L["Require Ctrl for focus/add (Left) and unfocus/untrack (Right) to prevent misclicks."]= "需要Ctrl键聚焦/添加(左键)和取消聚焦/取消追踪(右键)，防止误点击"
L["Ctrl for focus / untrack"]                                           = "Ctrl键用于聚焦/取消追踪"
L["Ctrl to click-complete"]                                             = "Ctrl键点击完成"
L["Use classic click behaviour"]                                        = "使用经典点击行为"
L["Classic clicks"]                                                     = "经典点击模式"
L["Share with party"]                                                   = "与队伍分享"
L["Abandon quest"]                                                      = "放弃任务"
L["Stop tracking"]                                                      = "停止追踪"
L["This quest cannot be shared."]                                       = "此任务无法分享"
L["You must be in a party to share this quest."]                        = "必须在队伍中才能分享此任务"
L["When on, left-click opens the quest map and right-click shows share/abandon menu (Blizzard-style). When off, left-click focuses and right-click untracks; Ctrl+Right shares with party."]= "启用时左键打开任务地图，右键显示分享/放弃菜单(暴雪风格)。禁用时左键聚焦，右键取消追踪；Ctrl+右键与队伍分享"
L["Animations"]                                                         = "动画"
L["Enable slide and fade for quests."]                                  = "启用任务滑动和淡出效果"
L["Objective progress flash"]                                           = "目标进度闪烁"
L["Show flash when an objective completes."]                            = "目标完成时显示闪烁"
L["Flash intensity"]                                                    = "闪烁强度"
L["How noticeable the objective-complete flash is."]                    = "目标完成闪烁的明显程度"
L["Flash color"]                                                        = "闪烁颜色"
L["Color of the objective-complete flash."]                             = "目标完成闪烁的颜色."
L["Subtle"]                                                             = "微妙"
L["Medium"]                                                             = "中等"
L["Strong"]                                                             = "强"
L["Require Ctrl for click to complete"]                                 = "需要Ctrl键点击完成"
L["When on, requires Ctrl+Left-click to complete auto-complete quests. When off, plain Left-click completes them (Blizzard default). Only affects quests that can be completed by click (no NPC turn-in needed)."]= "启用时需要Ctrl+左键完成自动完成任务。禁用时普通左键完成(暴雪默认)。仅影响可通过点击完成的任务(无需NPC提交)"
L["Suppress untracked until reload"]                                    = "隐藏未追踪直到重载"
L["When on, right-click untrack on world quests and in-zone weeklies/dailies hides them until you reload or start a new session. When off, they reappear when you return to the zone."]= "启用时世界任务和区域内每周/每日任务右键取消追踪会隐藏直到重载或开始新会话。禁用时返回区域时重新出现"
L["Permanently suppress untracked quests"]                              = "永久隐藏未追踪任务"
L["When on, right-click untracked world quests and in-zone weeklies/dailies are hidden permanently (persists across reloads). Takes priority over 'Suppress until reload'. Accepting a suppressed quest removes it from the blacklist."]= "启用时右键取消追踪的世界任务和区域内每周/每日任务永久隐藏(重载后持续)。优先于'隐藏未追踪直到重载'。接受被隐藏任务会从黑名单移除"
L["Keep campaign quests in category"]                                   = "战役任务保留在分类中"
L["When on, campaign quests that are ready to turn in remain in the Campaign category instead of moving to Complete."]= "启用时准备提交的战役任务保留在战役分类而非移动到已完成"
L["Keep important quests in category"]                                  = "重要任务保留在分类中"
L["When on, important quests that are ready to turn in remain in the Important category instead of moving to Complete."]= "启用时准备提交的重要任务保留在重要分类而非移动到已完成"
L["TomTom quest waypoint"]                                              = "TomTom任务航点"
L["Set a TomTom waypoint when focusing a quest."]                       = "聚焦任务时设置TomTom航点"
L["Requires TomTom. Points the arrow to the next quest objective."]     = "需要TomTom。箭头指向下一个任务目标"
L["TomTom rare waypoint"]                                               = "TomTom稀有航点"
L["Set a TomTom waypoint when clicking a rare boss."]                   = "点击稀有首领时设置TomTom航点"
L["Requires TomTom. Points the arrow to the rare's location."]          = "需要TomTom。箭头指向稀有首领位置"
L["Find a Group"]                                                       = "寻找队伍"
L["Click to search for a group for this quest."]                        = "点击搜索此任务的队伍."

-- =====================================================================
-- OptionsData.lua Blacklist
-- =====================================================================
L["Blacklist"]                                                          = "黑名单"
-- L["Blacklist untracked"]                                                = "Blacklist untracked"  -- NEEDS TRANSLATION
L["Enable 'Blacklist untracked' in Behaviour to add quests here."]      = "在行为中启用'黑名单未追踪'添加任务"
L["Hidden Quests"]                                                      = "隐藏的任务"
L["Quests hidden via right-click untrack."]                             = "右键取消追踪隐藏的任务"
L["Blacklisted quests"]                                                 = "黑名单任务"
L["Permanently suppressed quests"]                                      = "永久隐藏的任务"
L["Right-click untrack quests with 'Permanently suppress untracked quests' enabled to add them here."]= "右键取消追踪任务并启用'永久隐藏未追踪任务'添加到此处"

-- =====================================================================
-- OptionsData.lua Presence
-- =====================================================================
L["Show quest type icons"]                                              = "显示任务类型图标"
L["Show quest type icon in the Focus tracker (quest accept/complete, world quest, quest update)."]= "聚焦追踪器中显示任务类型图标(任务接受/完成、世界任务、任务更新)"
L["Show quest type icons on toasts"]                                    = "提示上显示任务类型图标"
L["Show quest type icon on Presence toasts (quest accept/complete, world quest, quest update)."]= "Presence提示上显示任务类型图标(任务接受/完成、世界任务、任务更新)"
L["Toast icon size"]                                                    = "提示图标大小"
L["Quest icon size on Presence toasts (16–36 px). Default 24."]         = "Presence提示上的任务图标大小(16-36像素)。默认24"
L["Hide quest update title"]                                            = "隐藏任务更新标题"
L["Show only the objective line on quest progress toasts (e.g. 7/10 Boar Pelts), without the quest name or header."]= "任务进度提示仅显示目标行(如 7/10 野猪皮)，不显示任务名称或标题"
L["Show discovery line"]                                                = "显示发现提示行"
L["Discovery line"]                                                     = "发现提示行"
L["Show 'Discovered' under zone/subzone when entering a new area."]     = "进入新区域时在区域/子区域下方显示'已发现'"
L["Frame vertical position"]                                            = "框架垂直位置"
L["Vertical offset of the Presence frame from center (-300 to 0)."]     = "Presence框架从中心的垂直偏移(-300到0)"
L["Frame scale"]                                                        = "框架缩放"
L["Scale of the Presence frame (0.5–2)."]                               = "Presence框架缩放(0.5-2)"
L["Boss emote color"]                                                   = "首领表情颜色"
L["Color of raid and dungeon boss emote text."]                         = "团队副本和地下城 Boss 表情文本的颜色"
L["Discovery line color"]                                               = "发现提示行颜色"
L["Color of the 'Discovered' line under zone text."]                    = "区域文本下方 '已发现' 行的颜色"
L["Notification types"]                                                 = "通知类型"
L["Notifications"]                                                      = "通知"
L["Show notification when achievement criteria update (tracked achievements always; others when Blizzard provides the achievement ID)."]= "成就条件更新时显示通知(追踪的成就始终显示；其他在暴雪提供成就ID时显示)"
L["Show zone entry"]                                                    = "显示区域条目"
L["Show zone change when entering a new area."]                         = "进入新区域时显示区域变更"
L["Show subzone changes"]                                               = "显示子区域变更"
L["Show subzone change when moving within the same zone."]              = "同一区域内移动时显示子区域变更"
L["Hide zone name for subzone changes"]                                 = "子区域变更时隐藏区域名称"
L["When moving between subzones within the same zone, only show the subzone name. The zone name still appears when entering a new zone."]= "同一区域内子区域间移动时仅显示子区域名称。进入新区域时区域名称仍会出现"
-- L["Suppress in Delve"]                                                  = "Suppress in Delve"  -- NEEDS TRANSLATION
-- L["Suppress scenario progress notifications in Delves."]                = "Suppress scenario progress notifications in Delves."  -- NEEDS TRANSLATION
-- L["When on, hides objective update popups while in a Delve. Zone entry and completion toasts still show."]= "When on, hides objective update popups while in a Delve. Zone entry and completion toasts still show."  -- NEEDS TRANSLATION
L["Suppress zone changes in Mythic+"]                                   = "史诗+中隐藏区域变更"
L["In Mythic+, only show boss emotes, achievements, and level-up. Hide zone, quest, and scenario notifications."]= "史诗+中仅显示首领表情、成就和升级。隐藏区域、任务和场景通知"
L["Show level up"]                                                      = "显示升级"
L["Show level-up notification."]                                        = "显示升级通知"
L["Show boss emotes"]                                                   = "显示首领表情"
L["Show raid and dungeon boss emote notifications."]                    = "显示团队副本和地下城首领表情通知"
L["Show achievements"]                                                  = "显示成就"
L["Show achievement earned notifications."]                             = "显示成就获得通知"
L["Achievement progress"]                                               = "成就进度"
L["Achievement earned"]                                                 = "获得成就"
L["Quest accepted"]                                                     = "任务已接受"
L["World quest accepted"]                                               = "世界任务已接受"
L["Scenario complete"]                                                  = "场景完成"
L["Rare defeated"]                                                      = "稀有精英已击败"
L["Show notification when tracked achievement criteria update."]        = "追踪成就条件更新时显示通知"
L["Show quest accept"]                                                  = "显示任务接受"
L["Show notification when accepting a quest."]                          = "接受任务时显示通知"
L["Show world quest accept"]                                            = "显示世界任务接受"
L["Show notification when accepting a world quest."]                    = "接受世界任务时显示通知"
L["Show quest complete"]                                                = "显示任务完成"
L["Show notification when completing a quest."]                         = "完成任务时显示通知"
L["Show world quest complete"]                                          = "显示世界任务完成"
L["Show notification when completing a world quest."]                   = "完成世界任务时显示通知"
L["Show quest progress"]                                                = "显示任务进度"
L["Show notification when quest objectives update."]                    = "任务目标更新时显示通知"
L["Objective only"]                                                     = "仅目标"
L["Show only the objective line on quest progress toasts, hiding the 'Quest Update' title."]= "任务进度提示仅显示目标行，隐藏'任务更新'标题"
L["Show scenario start"]                                                = "显示场景开始"
L["Show notification when entering a scenario or Delve."]               = "进入场景或地下堡时显示通知"
L["Show scenario progress"]                                             = "显示场景进度"
L["Show notification when scenario or Delve objectives update."]        = "场景或地下堡目标更新时显示通知"
L["Animation"]                                                          = "动画"
L["Enable animations"]                                                  = "启用动画"
L["Enable entrance and exit animations for Presence notifications."]    = "为 Presence 通知启用进入和退出动画"
L["Entrance duration"]                                                  = "进入持续时间"
L["Duration of the entrance animation in seconds (0.2–1.5)."]           = "进入动画的持续时间(秒)(0.2–1.5)"
L["Exit duration"]                                                      = "退出持续时间"
L["Duration of the exit animation in seconds (0.2–1.5)."]               = "退出动画的持续时间(秒)(0.2–1.5)"
L["Hold duration scale"]                                                = "持续时间缩放"
L["Multiplier for how long each notification stays on screen (0.5–2)."] = "通知屏幕停留时间倍数(0.5-2)"
-- L["Preview"]                                                            = "Preview"  -- NEEDS TRANSLATION
-- L["Preview toast type"]                                                 = "Preview toast type"  -- NEEDS TRANSLATION
-- L["Select a toast type to preview."]                                    = "Select a toast type to preview."  -- NEEDS TRANSLATION
-- L["Show the selected toast type."]                                      = "Show the selected toast type."  -- NEEDS TRANSLATION
-- L["Preview Presence toast layouts live and open a detachable sample while adjusting other settings."]= "Preview Presence toast layouts live and open a detachable sample while adjusting other settings."  -- NEEDS TRANSLATION
-- L["Open detached preview"]                                              = "Open detached preview"  -- NEEDS TRANSLATION
-- L["Open a movable preview window that stays visible while you change other Presence settings."]= "Open a movable preview window that stays visible while you change other Presence settings."  -- NEEDS TRANSLATION
-- L["Animate preview"]                                                    = "Animate preview"  -- NEEDS TRANSLATION
-- L["Play the selected toast animation inside this preview window."]      = "Play the selected toast animation inside this preview window."  -- NEEDS TRANSLATION
-- L["Detached preview"]                                                   = "Detached preview"  -- NEEDS TRANSLATION
-- L["Keep this open while adjusting Typography or Colors."]               = "Keep this open while adjusting Typography or Colors."  -- NEEDS TRANSLATION
L["Typography"]                                                         = "排版"
L["Main title font"]                                                    = "主标题字体"
L["Font family for the main title."]                                    = "主标题字体"
L["Subtitle font"]                                                      = "副标题字体"
L["Font family for the subtitle."]                                      = "副标题字体"
-- L["Reset typography to defaults"]                                       = "Reset typography to defaults"  -- NEEDS TRANSLATION
-- L["Reset all Presence typography options (fonts, sizes, colors) to defaults."]= "Reset all Presence typography options (fonts, sizes, colors) to defaults."  -- NEEDS TRANSLATION
-- L["Large notifications"]                                                = "Large notifications"  -- NEEDS TRANSLATION
-- L["Medium notifications"]                                               = "Medium notifications"  -- NEEDS TRANSLATION
-- L["Small notifications"]                                                = "Small notifications"  -- NEEDS TRANSLATION
-- L["Large primary size"]                                                 = "Large primary size"  -- NEEDS TRANSLATION
-- L["Font size for large notification titles (zone, quest complete, achievement, etc.)."]= "Font size for large notification titles (zone, quest complete, achievement, etc.)."  -- NEEDS TRANSLATION
-- L["Large secondary size"]                                               = "Large secondary size"  -- NEEDS TRANSLATION
-- L["Font size for large notification subtitles."]                        = "Font size for large notification subtitles."  -- NEEDS TRANSLATION
-- L["Medium primary size"]                                                = "Medium primary size"  -- NEEDS TRANSLATION
-- L["Font size for medium notification titles (quest accept, subzone, scenario)."]= "Font size for medium notification titles (quest accept, subzone, scenario)."  -- NEEDS TRANSLATION
-- L["Medium secondary size"]                                              = "Medium secondary size"  -- NEEDS TRANSLATION
-- L["Font size for medium notification subtitles."]                       = "Font size for medium notification subtitles."  -- NEEDS TRANSLATION
-- L["Small primary size"]                                                 = "Small primary size"  -- NEEDS TRANSLATION
-- L["Font size for small notification titles (quest progress, achievement progress)."]= "Font size for small notification titles (quest progress, achievement progress)."  -- NEEDS TRANSLATION
-- L["Small secondary size"]                                               = "Small secondary size"  -- NEEDS TRANSLATION
-- L["Font size for small notification subtitles."]                        = "Font size for small notification subtitles."  -- NEEDS TRANSLATION

-- =====================================================================
-- OptionsData.lua Dropdown options — Outline
-- =====================================================================
L["None"]                                                               = "无"
L["Thick Outline"]                                                      = "粗轮廓"

-- =====================================================================
-- OptionsData.lua Dropdown options — Highlight style
-- =====================================================================
L["Bar (left edge)"]                                                    = "条 (左边缘)"
L["Bar (right edge)"]                                                   = "条 (右边缘)"
L["Bar (top edge)"]                                                     = "条 (上边缘)"
L["Bar (bottom edge)"]                                                  = "条 (下边缘)"
L["Outline only"]                                                       = "仅轮廓"
L["Soft glow"]                                                          = "柔和发光"
L["Dual edge bars"]                                                     = "双边缘条"
L["Pill left accent"]                                                   = "标签左侧强调"

-- =====================================================================
-- OptionsData.lua Dropdown options — M+ position
-- =====================================================================
L["Top"]                                                                = "顶部"
L["Bottom"]                                                             = "底部"

-- =====================================================================
-- OptionsData.lua Vista — Text element positions
-- =====================================================================
L["Location position"]                                                  = "位置"
L["Place the zone name above or below the minimap."]                    = "区域名称放置在小地图上方或下方"
L["Coordinates position"]                                               = "坐标位置"
L["Place the coordinates above or below the minimap."]                  = "坐标放置在小地图上方或下方"
L["Clock position"]                                                     = "时钟位置"
L["Place the clock above or below the minimap."]                        = "时钟放置在小地图上方或下方"

-- =====================================================================
-- OptionsData.lua Dropdown options — Text case
-- =====================================================================
L["Lower Case"]                                                         = "小写"
L["Upper Case"]                                                         = "大写"
L["Proper"]                                                             = "标准"

-- =====================================================================
-- OptionsData.lua Dropdown options — Header count format
-- =====================================================================
L["Tracked / in log"]                                                   = "已追踪/日志中"
L["In log / max slots"]                                                 = "日志中/最大槽位"

-- =====================================================================
-- OptionsData.lua Dropdown options — Sort mode
-- =====================================================================
L["Alphabetical"]                                                       = "字母顺序"
L["Quest Type"]                                                         = "任务类型"
L["Quest Level"]                                                        = "任务等级"

-- =====================================================================
-- OptionsData.lua Misc
-- =====================================================================
L["Custom"]                                                             = "自定义"
L["Order"]                                                              = "顺序"

-- =====================================================================
-- Tracker section labels (SECTION_LABELS)
-- =====================================================================
L["DUNGEON"]                                                            = "地下城"
L["RAID"]                                                               = "团队副本"
L["DELVES"]                                                             = "地下堡"
L["SCENARIO EVENTS"]                                                    = "场景事件"
-- L["Stage"]                                                              = "Stage"  -- NEEDS TRANSLATION
-- L["Stage %d: %s"]                                                       = "Stage %d: %s"  -- NEEDS TRANSLATION
L["AVAILABLE IN ZONE"]                                                  = "区域内可用"
L["EVENTS IN ZONE"]                                                     = "区域内事件"
L["CURRENT EVENT"]                                                      = "当前事件"
L["CURRENT QUEST"]                                                      = "当前任务"
L["CURRENT ZONE"]                                                       = "当前区域"
L["CAMPAIGN"]                                                           = "战役"
L["IMPORTANT"]                                                          = "重要"
L["LEGENDARY"]                                                          = "传说"
L["WORLD QUESTS"]                                                       = "世界任务"
L["WEEKLY QUESTS"]                                                      = "每周任务"
L["PREY"]                                                               = "猎物"
L["Abundance"]                                                          = "丰裕"
L["Abundance Bag"]                                                      = "丰裕之袋"
L["abundance held"]                                                     = "已持有丰裕"
L["DAILY QUESTS"]                                                       = "日常任务"
L["RARE BOSSES"]                                                        = "稀有首领"
L["ACHIEVEMENTS"]                                                       = "成就"
L["ENDEAVORS"]                                                          = "宏图"
L["DECOR"]                                                              = "装饰"
L["QUESTS"]                                                             = "任务"
L["READY TO TURN IN"]                                                   = "准备提交"

-- =====================================================================
-- Core.lua, FocusLayout.lua, PresenceCore.lua, FocusUnacceptedPopup.lua
-- =====================================================================
L["OBJECTIVES"]                                                         = "目标"
L["Options"]                                                            = "选项"
L["Open Horizon Suite"]                                                 = "打开 Horizon Suite"
L["Open the full Horizon Suite options panel to configure Focus, Presence, Vista, and other modules."]= "打开完整的 Horizon Suite 选项面板以配置 Focus、Presence、Vista 和其他模块。"
L["Show minimap icon"]                                                  = "显示小地图图标"
L["Show a clickable icon on the minimap that opens the options panel."] = "在小地图上显示可点击的图标以打开选项面板。"
-- L["Lock minimap button position"]                                       = "Lock minimap button position"  -- NEEDS TRANSLATION
-- L["Prevent dragging the Horizon minimap button."]                       = "Prevent dragging the Horizon minimap button."  -- NEEDS TRANSLATION
-- L["Reset minimap button position"]                                      = "Reset minimap button position"  -- NEEDS TRANSLATION
-- L["Reset the minimap button to the default position (bottom-left)."]    = "Reset the minimap button to the default position (bottom-left)."  -- NEEDS TRANSLATION
-- L["Drag to move (when unlocked)."]                                      = "Drag to move (when unlocked)."  -- NEEDS TRANSLATION
-- L["Locked"]                                                             = "Locked"  -- NEEDS TRANSLATION
L["Discovered"]                                                         = "已发现"
L["Refresh"]                                                            = "刷新"
L["Best-effort only. Some unaccepted quests are not exposed until you interact with NPCs or meet phasing conditions."]= "仅尽力而为. 某些未接受的任务直到与NPC交互或满足阶段条件才会显示"
L["Unaccepted Quests - %s (map %s) - %d match(es)"]                     = "未接受任务 - %s(地图 %s)- %d 个匹配"

L["LEVEL UP"]                                                           = "升级"
L["You have reached level 80"]                                          = "已达到等级80"
L["You have reached level %s"]                                          = "已达到等级 %s"
L["ACHIEVEMENT EARNED"]                                                 = "获得成就"
L["Exploring the Midnight Isles"]                                       = "探索午夜群岛"
L["Exploring Khaz Algar"]                                               = "探索卡兹阿加尔"
L["QUEST COMPLETE"]                                                     = "任务完成"
L["Objective Secured"]                                                  = "目标已锁定"
L["Aiding the Accord"]                                                  = "援助协定"
L["WORLD QUEST"]                                                        = "世界任务"
L["WORLD QUEST COMPLETE"]                                               = "世界任务完成"
L["Azerite Mining"]                                                     = "艾泽里特矿石"
L["WORLD QUEST ACCEPTED"]                                               = "世界任务已接受"
L["QUEST ACCEPTED"]                                                     = "任务已接受"
L["The Fate of the Horde"]                                              = "部落的命运"
L["New Quest"]                                                          = "新任务"
L["QUEST UPDATE"]                                                       = "任务更新"
L["Boar Pelts: 7/10"]                                                   = "野猪皮: 7/10"
L["Dragon Glyphs: 3/5"]                                                 = "龙之符文: 3/5"

L["Presence test commands:"]                                            = "情境测试命令："
L["  /h presence debugtypes - Dump notification toggles and Blizzard suppression state"]= "  /h presence debugtypes - 显示通知开关和暴雪抑制状态"
L["Presence: Playing demo reel (all notification types)..."]            = "情境：播放演示(所有通知类型)..."
L["  /h presence         - Show help + test current zone"]              = "  /h presence         - 显示帮助 + 测试当前区域"
L["  /h presence zone     - Test Zone Change"]                          = "  /h presence zone     - 测试区域变更"
L["  /h presence subzone  - Test Subzone Change"]                       = "  /h presence subzone  - 测试子区域变更"
L["  /h presence discover - Test Zone Discovery"]                       = "  /h presence discover - 测试区域发现"
L["  /h presence level    - Test Level Up"]                             = "  /h presence level    - 测试升级"
L["  /h presence boss     - Test Boss Emote"]                           = "  /h presence boss     - 测试Boss表情"
L["  /h presence ach      - Test Achievement"]                          = "  /h presence ach      - 测试成就"
L["  /h presence accept   - Test Quest Accepted"]                       = "  /h presence accept   - 测试接受任务"
L["  /h presence wqaccept - Test World Quest Accepted"]                 = "  /h presence wqaccept - 测试接受世界任务"
L["  /h presence scenario - Test Scenario Start"]                       = "  /h presence scenario - 测试场景开始"
L["  /h presence quest    - Test Quest Complete"]                       = "  /h presence quest    - 测试任务完成"
L["  /h presence wq       - Test World Quest"]                          = "  /h presence wq       - 测试世界任务"
L["  /h presence update   - Test Quest Update"]                         = "  /h presence update   - 测试任务更新"
L["  /h presence achprogress - Test Achievement Progress"]              = "  /h presence achprogress - 测试成就进度"
L["  /h presence all      - Demo reel (all types)"]                     = "  /h presence all      - 演示卷轴(所有类型)"
L["  /h presence debug    - Dump state to chat"]                        = "  /h presence debug    - 转储状态到聊天"
L["  /h presence debuglive - Toggle live debug panel (log as events happen)"]= "  /h presence debuglive - 切换实时调试面板(记录事件)"

-- =====================================================================
-- OptionsData.lua Vista — General
L["Position & layout"]                                                  = "位置和布局"
-- =====================================================================
L["Minimap"]                                                            = "小地图"
L["Minimap size"]                                                       = "小地图大小"
L["Width and height of the minimap in pixels (100–400)."]               = "小地图宽度和高度(像素)(100-400)"
L["Circular minimap"]                                                   = "圆形小地图"
L["Circular shape"]                                                     = "圆形."
L["Use a circular minimap instead of square."]                          = "使用圆形小地图而非方形"
L["Lock minimap position"]                                              = "锁定小地图位置"
L["Prevent dragging the minimap."]                                      = "防止拖动小地图"
L["Reset minimap position"]                                             = "重置小地图位置"
L["Reset minimap to its default position (top-right)."]                 = "小地图重置为默认位置(右上角)"
L["Auto Zoom"]                                                          = "自动缩放"
L["Auto zoom-out delay"]                                                = "自动缩出延迟"
L["Seconds after zooming before auto zoom-out fires. Set to 0 to disable."]= "缩放后自动缩小的延迟秒数。设置为0禁用"

-- =====================================================================
-- OptionsData.lua Vista — Typography
-- =====================================================================
L["Zone Text"]                                                          = "区域文本"
L["Zone font"]                                                          = "区域字体"
L["Font for the zone name below the minimap."]                          = "小地图下方区域名称字体"
L["Zone font size"]                                                     = "区域字体大小"
L["Zone text color"]                                                    = "区域文本颜色"
L["Color of the zone name text."]                                       = "区域名称文本的颜色"
L["Coordinates Text"]                                                   = "坐标文本"
L["Coordinates font"]                                                   = "坐标字体"
L["Font for the coordinates text below the minimap."]                   = "小地图下方坐标文本字体"
L["Coordinates font size"]                                              = "坐标字体大小"
L["Coordinates text color"]                                             = "坐标文本颜色"
L["Color of the coordinates text."]                                     = "坐标文本的颜色"
L["Coordinate precision"]                                               = "坐标精度"
L["Number of decimal places shown for X and Y coordinates."]            = "X和Y坐标显示的小数位数"
L["No decimals (e.g. 52, 37)"]                                          = "无小数(例如 52, 37)"
L["1 decimal (e.g. 52.3, 37.1)"]                                        = "1 位小数 (例如 52.3, 37.1)"
L["2 decimals (e.g. 52.34, 37.12)"]                                     = "2 位小数 (例如 52.34, 37.12)"
L["Time Text"]                                                          = "时间文本"
L["Time font"]                                                          = "时间字体"
L["Font for the time text below the minimap."]                          = "小地图下方时间文本字体"
L["Time font size"]                                                     = "时间字体大小"
L["Time text color"]                                                    = "时间文本颜色"
L["Color of the time text."]                                            = "时间文本的颜色"
-- L["Performance Text"]                                                   = "Performance Text"  -- NEEDS TRANSLATION
-- L["Performance font"]                                                   = "Performance font"  -- NEEDS TRANSLATION
-- L["Font for the FPS and latency text below the minimap."]               = "Font for the FPS and latency text below the minimap."  -- NEEDS TRANSLATION
-- L["Performance font size"]                                              = "Performance font size"  -- NEEDS TRANSLATION
-- L["Performance text color"]                                             = "Performance text color"  -- NEEDS TRANSLATION
-- L["Color of the FPS and latency text."]                                 = "Color of the FPS and latency text."  -- NEEDS TRANSLATION
L["Difficulty Text"]                                                    = "难度文本"
L["Difficulty text color (fallback)"]                                   = "难度文本颜色(备用)"
L["Default color when no per-difficulty color is set."]                 = "当没有设置特定难度颜色时的默认颜色"
L["Difficulty font"]                                                    = "难度字体"
L["Font for the instance difficulty text."]                             = "副本难度文本字体"
L["Difficulty font size"]                                               = "难度字体大小"
L["Per-Difficulty Colors"]                                              = "每难度颜色"
L["Mythic color"]                                                       = "史诗颜色"
L["Color for Mythic difficulty text."]                                  = "史诗难度文本的颜色"
L["Heroic color"]                                                       = "英雄颜色"
L["Color for Heroic difficulty text."]                                  = "英雄难度文本的颜色"
L["Normal color"]                                                       = "普通颜色"
L["Color for Normal difficulty text."]                                  = "普通难度文本的颜色"
L["LFR color"]                                                          = "随机团队颜色"
L["Color for Looking For Raid difficulty text."]                        = "随机团队难度文本的颜色"

-- =====================================================================
-- OptionsData.lua Vista — Visibility
-- =====================================================================
L["Text Elements"]                                                      = "文本元素"
L["Show zone text"]                                                     = "显示区域文本"
L["Show the zone name below the minimap."]                              = "小地图下方显示区域名称"
L["Zone text display mode"]                                             = "区域文本显示模式"
L["What to show: zone only, subzone only, or both."]                    = "显示内容：仅区域、仅子区域或两者"
L["Zone only"]                                                          = "仅区域"
L["Subzone only"]                                                       = "仅子区域"
L["Both"]                                                               = "两者"
L["Show coordinates"]                                                   = "显示坐标"
L["Show player coordinates below the minimap."]                         = "小地图下方显示玩家坐标"
L["Show time"]                                                          = "显示时间"
L["Show current game time below the minimap."]                          = "小地图下方显示当前游戏时间"
-- L["24-hour clock"]                                                      = "24-hour clock"  -- NEEDS TRANSLATION
-- L["Display time in 24-hour format (e.g. 14:30 instead of 2:30 PM)."]    = "Display time in 24-hour format (e.g. 14:30 instead of 2:30 PM)."  -- NEEDS TRANSLATION
L["Use local time"]                                                     = "使用本地时间"
L["When on, shows your local system time. When off, shows server time."]= "启用时显示本地系统时间。禁用时显示服务器时间"
-- L["Show FPS and latency"]                                               = "Show FPS and latency"  -- NEEDS TRANSLATION
-- L["Show FPS and latency (ms) below the minimap."]                       = "Show FPS and latency (ms) below the minimap."  -- NEEDS TRANSLATION
L["Minimap Buttons"]                                                    = "小地图按钮"
L["Queue status and mail indicator are always shown when relevant."]    = "队列状态和邮件指示器在相关时始终显示"
L["Show tracking button"]                                               = "显示追踪按钮"
L["Show the minimap tracking button."]                                  = "显示小地图追踪按钮"
L["Tracking button on mouseover only"]                                  = "仅鼠标悬停时显示追踪按钮"
L["Hide tracking button until you hover over the minimap."]             = "悬停小地图时显示追踪按钮"
L["Show calendar button"]                                               = "显示日历按钮"
L["Show the minimap calendar button."]                                  = "显示小地图日历按钮"
L["Calendar button on mouseover only"]                                  = "仅鼠标悬停时显示日历按钮"
L["Hide calendar button until you hover over the minimap."]             = "悬停小地图时显示日历按钮"
L["Show zoom buttons"]                                                  = "显示缩放按钮"
L["Show the + and - zoom buttons on the minimap."]                      = "小地图显示+和-缩放按钮"
L["Zoom buttons on mouseover only"]                                     = "仅鼠标悬停时显示缩放按钮"
L["Hide zoom buttons until you hover over the minimap."]                = "悬停小地图时显示缩放按钮"

-- =====================================================================
-- OptionsData.lua Vista — Display (Border / Text Positions / Buttons)
-- =====================================================================
L["Border"]                                                             = "边框"
L["Show a border around the minimap."]                                  = "小地图周围显示边框"
L["Border color"]                                                       = "边框颜色"
L["Color (and opacity) of the minimap border."]                         = "小地图边框的颜色 (和不透明度)"
L["Border thickness"]                                                   = "边框粗细"
L["Thickness of the minimap border in pixels (1–8)."]                   = "小地图边框粗细(像素)(1-8)"
-- L["Class colours"]                                                      = "Class colours"  -- NEEDS TRANSLATION
-- L["Tint Vista border and text (coords, time, FPS/MS labels) with your class colour. Numbers use the configured colour."]= "Tint Vista border and text (coords, time, FPS/MS labels) with your class colour. Numbers use the configured colour."  -- NEEDS TRANSLATION
L["Text Positions"]                                                     = "文本位置"
L["Drag text elements to reposition them. Lock to prevent accidental movement."]= "拖动文本元素重新定位。锁定可防止意外移动"
L["Lock zone text position"]                                            = "锁定区域文本位置"
L["When on, the zone text cannot be dragged."]                          = "启用时区域文本无法拖动"
L["Lock coordinates position"]                                          = "锁定坐标位置"
L["When on, the coordinates text cannot be dragged."]                   = "启用时坐标文本无法拖动"
L["Lock time position"]                                                 = "锁定时间位置"
L["When on, the time text cannot be dragged."]                          = "启用时时间文本无法拖动"
-- L["Performance text position"]                                          = "Performance text position"  -- NEEDS TRANSLATION
-- L["Place the FPS/latency text above or below the minimap."]             = "Place the FPS/latency text above or below the minimap."  -- NEEDS TRANSLATION
-- L["Lock performance text position"]                                     = "Lock performance text position"  -- NEEDS TRANSLATION
-- L["When on, the FPS/latency text cannot be dragged."]                   = "When on, the FPS/latency text cannot be dragged."  -- NEEDS TRANSLATION
L["Lock difficulty text position"]                                      = "锁定难度文本位置"
L["When on, the difficulty text cannot be dragged."]                    = "启用时难度文本无法拖动"
L["Button Positions"]                                                   = "按钮位置"
L["Drag buttons to reposition them. Lock to prevent movement."]         = "拖动按钮以重新定位. 锁定以防止移动"
L["Lock Zoom In button"]                                                = "锁定放大按钮"
L["Prevent dragging the + zoom button."]                                = "防止拖动放大按钮"
L["Lock Zoom Out button"]                                               = "锁定缩小按钮"
L["Prevent dragging the - zoom button."]                                = "防止拖动缩小按钮"
L["Lock Tracking button"]                                               = "锁定追踪按钮"
L["Prevent dragging the tracking button."]                              = "防止拖动追踪按钮"
L["Lock Calendar button"]                                               = "锁定日历按钮"
L["Prevent dragging the calendar button."]                              = "防止拖动日历按钮"
L["Lock Queue button"]                                                  = "锁定队列按钮"
L["Prevent dragging the queue status button."]                          = "防止拖动队列状态按钮"
L["Lock Mail indicator"]                                                = "锁定邮件指示器"
L["Prevent dragging the mail icon."]                                    = "防止拖动邮件图标"
-- L["Disable queue handling"]                                             = "Disable queue handling"  -- NEEDS TRANSLATION
L["Disable queue button handling"]                                      = "禁用队列按钮处理"
L["Turn off all queue button anchoring (use if another addon manages it)."]= "关闭所有队列按钮锚定(其他插件管理时使用)"
L["Button Sizes"]                                                       = "按钮大小"
L["Adjust the size of minimap overlay buttons."]                        = "调整小地图覆盖按钮的大小"
L["Tracking button size"]                                               = "追踪按钮大小"
L["Size of the tracking button (pixels)."]                              = "追踪按钮大小(像素)"
L["Calendar button size"]                                               = "日历按钮大小"
L["Size of the calendar button (pixels)."]                              = "日历按钮大小(像素)"
L["Queue button size"]                                                  = "队列按钮大小"
L["Size of the queue status button (pixels)."]                          = "队列状态按钮大小(像素)"
L["Zoom button size"]                                                   = "缩放按钮大小"
L["Size of the zoom in / zoom out buttons (pixels)."]                   = "放大/缩小按钮大小(像素)"
L["Mail indicator size"]                                                = "邮件指示器大小"
L["Size of the new mail icon (pixels)."]                                = "新邮件图标大小(像素)"
L["Addon button size"]                                                  = "插件按钮大小"
L["Size of collected addon minimap buttons (pixels)."]                  = "收集的插件小地图按钮大小(像素)"

-- =====================================================================
-- OptionsData.lua Vista — Minimap Addon Buttons
-- =====================================================================
-- L["Addon Buttons"]                                                      = "Addon Buttons"  -- NEEDS TRANSLATION
L["Minimap Addon Buttons"]                                              = "小地图插件按钮"
L["Button Management"]                                                  = "按钮管理"
L["Manage addon minimap buttons"]                                       = "管理小地图插件按钮"
L["When on, Vista takes control of addon minimap buttons and groups them by the selected mode."]= "启用时Vista控制插件小地图按钮并按所选模式分组"
L["Button mode"]                                                        = "按钮模式"
L["How addon buttons are presented: hover bar below minimap, panel on right-click, or floating drawer button."]= "插件按钮显示方式：小地图下方悬停条、右键面板或浮动抽屉按钮"
-- L["Always show bar"]                                                    = "Always show bar"  -- NEEDS TRANSLATION
L["Always show mouseover bar (for positioning)"]                        = "始终显示鼠标悬停栏(用于定位)"
L["Keep the mouseover bar visible at all times so you can reposition it. Disable when done."]= "始终保持鼠标悬停条可见以便重新定位。完成后禁用"
L["Disable when done."]                                                 = "完成后禁用"
L["Mouseover bar"]                                                      = "鼠标悬停条"
L["Right-click panel"]                                                  = "右键面板"
L["Floating drawer"]                                                    = "浮动抽屉"
L["Lock drawer button position"]                                        = "锁定抽屉按钮位置"
L["Prevent dragging the floating drawer button."]                       = "防止拖动浮动抽屉按钮"
L["Lock mouseover bar position"]                                        = "锁定鼠标悬停条位置"
L["Prevent dragging the mouseover button bar."]                         = "防止拖动鼠标悬停按钮条"
L["Lock right-click panel position"]                                    = "锁定右键面板位置"
L["Prevent dragging the right-click panel."]                            = "防止拖动右键面板"
L["Buttons per row/column"]                                             = "每行/列的按钮数"
L["Controls how many buttons appear before wrapping. For left/right direction this is columns; for up/down it is rows."]= "控制换行前显示多少个按钮. 左/右方向为列数; 上/下方向为行数"
L["Expand direction"]                                                   = "展开方向"
L["Direction buttons fill from the anchor point. Left/Right = horizontal rows. Up/Down = vertical columns."]= "按钮从锚点开始填充的方向. 左/右 = 水平行. 上/下 = 垂直列"
L["Right"]                                                              = "右"
L["Left"]                                                               = "左"
L["Down"]                                                               = "下"
L["Up"]                                                                 = "上"
L["Mouseover Bar Appearance"]                                           = "鼠标悬停条外观"
L["Background and border for the mouseover button bar."]                = "鼠标悬停按钮栏的背景和边框."
L["Backdrop color"]                                                     = "背景颜色"
L["Background color of the mouseover button bar (use alpha to control transparency)."]= "鼠标悬停按钮栏的背景颜色(使用alpha控制透明度)."
L["Show bar border"]                                                    = "显示条形边框"
L["Show a border around the mouseover button bar."]                     = "鼠标悬停按钮条周围显示边框"
L["Bar border color"]                                                   = "栏边框颜色"
L["Border color of the mouseover button bar."]                          = "鼠标悬停按钮栏的边框颜色."
L["Bar background color"]                                               = "栏背景颜色"
L["Panel background color."]                                            = "面板背景颜色"
L["Close / Fade Timing"]                                                = "关闭/淡出计时"
L["Mouseover bar — close delay (seconds)"]                              = "鼠标悬停条 - 关闭延迟(秒)"
L["How long (in seconds) the bar stays visible after the cursor leaves. 0 = instant fade."]= "光标离开后条形保持可见的时间(秒)。0 = 立即淡出"
L["Right-click panel — close delay (seconds)"]                          = "右键面板 - 关闭延迟(秒)"
L["How long (in seconds) the panel stays open after the cursor leaves. 0 = never auto-close (close by right-clicking again)."]= "光标离开后面板保持打开的时间(秒)。0 = 永不自动关闭(通过再次右键关闭)"
L["Floating drawer — close delay (seconds)"]                            = "浮动抽屉 - 关闭延迟(秒)"
L["Drawer close delay"]                                                 = "抽屉关闭延迟"
L["How long (in seconds) the drawer panel stays open after clicking away. 0 = never auto-close (close only by clicking the drawer button again)."]= "点击其他位置后抽屉面板保持打开的时间(秒)。0 = 永不自动关闭(仅通过再次点击抽屉按钮关闭)"
L["Mail icon blink"]                                                    = "邮件图标闪烁"
L["When on, the mail icon pulses to draw attention. When off, it stays at full opacity."]= "启用时邮件图标脉冲引起注意。禁用时保持完全不透明"
L["Panel Appearance"]                                                   = "面板外观"
L["Colors for the drawer and right-click button panels."]               = "抽屉和右键按钮面板的颜色"
L["Panel background color"]                                             = "面板背景颜色"
L["Background color of the addon button panels."]                       = "插件按钮面板的背景颜色"
L["Panel border color"]                                                 = "面板边框颜色"
L["Border color of the addon button panels."]                           = "插件按钮面板的边框颜色"
L["Managed buttons"]                                                    = "已管理的按钮"
L["When off, this button is completely ignored by this addon."]         = "关闭时此插件完全忽略此按钮"
L["(No addon buttons detected yet)"]                                    = "(尚未检测到插件按钮)"
L["Visible buttons (check to include)"]                                 = "可见按钮(勾选以包含)"
L["(No addon buttons detected yet — open your minimap first)"]          = "(尚未检测到插件按钮 — 请先打开你的小地图)"



