if GetLocale() ~= "koKR" then return end

local addon = _G._HorizonSuite_Loading or _G.HorizonSuiteBeta or _G.HorizonSuite
if not addon then return end

local L = setmetatable({}, { __index = function(t, k) return k end })
addon.L = L
addon.StandardFont = UNIT_NAME_FONT

-- =====================================================================
-- OptionsPanel.lua — Title
-- =====================================================================
L["HORIZON SUITE"]                                                  = "HORIZON SUITE"

-- =====================================================================
-- OptionsPanel.lua — Sidebar module group labels
-- =====================================================================
L["Focus"]                                                          = "퀘스트 목표 목록 설정"
L["Presence"]                                                       = "상황 알림 설정"
L["Other"]                                                          = "기타"

-- =====================================================================
-- OptionsPanel.lua — Section headers
-- =====================================================================
L["Quest types"]                                                    = "퀘스트 유형"
L["Element overrides"]                                              = "개별 요소 색상"
L["Per category"]                                                   = "유형별 색상"
L["Grouping Overrides"]                                             = "그룹 우선 색상"
L["Other colors"]                                                   = "기타 색상"

-- =====================================================================
-- OptionsPanel.lua — Color row labels (collapsible group sub-rows)
-- =====================================================================
L["Section"]                                                        = "구역"
L["Title"]                                                          = "제목"
L["Zone"]                                                           = "지역"
L["Objective"]                                                      = "목표 목록"

-- =====================================================================
-- OptionsPanel.lua — Toggle switch labels & tooltips
-- =====================================================================
L["Ready to Turn In overrides base colours"]                        = "완료 퀘스트 색상을 우선 적용"
L["Ready to Turn In uses its colours for quests in that section."]  = "완료 가능한 퀘스트가 있으면 해당 구역에 색상을 우선 적용합니다."
L["Current Zone overrides base colours"]                            = "현재 지역 색상을 우선 적용"
L["Current Zone uses its colours for quests in that section."]      = "현재 지역에 해당하는 퀘스트가 있으면 해당 구역에 지역 색상을 우선 적용합니다."
L["Use distinct color for completed objectives"]                    = "완료된 목표에 다른 색상 사용"
L["When on, completed objectives (e.g. 1/1) use the color below; when off, they use the same color as incomplete objectives."] = "활성화하면 완료된 목표(예: 1/1)에 아래 색상을 사용하고, 비활성화하면 미완료 목표와 같은 색상을 사용합니다."
L["Completed objective"]                                            = "완료된 목표"

-- =====================================================================
-- OptionsPanel.lua — Button labels
-- =====================================================================
L["Reset"]                                                         = "초기화"
L["Reset quest types"]                                             = "퀘스트 유형 초기화"
L["Reset overrides"]                                               = "개별 요소 초기화"
L["Reset to defaults"]                                             = "기본값으로 초기화"
L["Reset to default"]                                              = "기본값으로 초기화"

-- =====================================================================
-- OptionsPanel.lua — Search bar placeholder
-- =====================================================================
L["Search settings..."]                                            = "설정 검색..."
L["Search fonts..."]                                               = "글꼴 검색..."

-- =====================================================================
-- OptionsPanel.lua — Resize handle tooltip
-- =====================================================================
L["Drag to resize"]                                                = "드래그하여 크기 조절"

-- =====================================================================
-- OptionsData.lua Category names (sidebar)
-- =====================================================================
L["Modules"]                                            = "기능"
L["Layout"]                                             = "레이아웃"
L["Visibility"]                                         = "표시 조건"
L["Display"]                                            = "표시"
L["Features"]                                           = "기능"
L["Typography"]                                         = "글꼴"
L["Appearance"]                                         = "외형"
L["Colors"]                                             = "색상"
L["Organization"]                                       = "정렬"

-- =====================================================================
-- OptionsData.lua Section headers
-- =====================================================================
L["Panel behaviour"]                                    = "패널 동작"
L["Dimensions"]                                         = "크기"
L["Instance"]                                           = "인스턴스"
L["Combat"]                                             = "전투"
L["Filtering"]                                          = "필터"
L["Header"]                                             = "헤더"
L["List"]                                               = "목표 목록"
L["Spacing"]                                            = "간격"
L["Rare bosses"]                                        = "희귀 우두머리"
L["World quests"]                                       = "전역 퀘스트"
L["Floating quest item"]                                = "퀘스트 아이템 버튼"
L["Mythic+"]                                            = "쐐기"
L["Achievements"]                                       = "업적"
L["Endeavors"]                                          = "활동 과제"
L["Decor"]                                              = "장식"
L["Scenario & Delve"]                                   = "시나리오 및 구렁"
L["Font"]                                               = "글꼴"
L["Text case"]                                          = "대소문자"
L["Shadow"]                                             = "그림자"
L["Panel"]                                              = "패널"
L["Highlight"]                                          = "강조"
L["Color matrix"]                                       = "색상표"
L["Focus order"]                                        = "목록 순서"
L["Sort"]                                               = "정렬"
L["Behaviour"]                                          = "동작"
L["Content Types"]                                      = "콘텐츠 유형"
L["Delves"]                                             = "구렁"
L["Interactions"]                                       = "상호작용"
L["Tracking"]                                           = "추적"
L["Scenario Bar"]                                       = "시나리오 바"

-- =====================================================================
-- OptionsData.lua Modules
-- =====================================================================
L["Enable Focus module"]                                = "목표 목록 기능 활성화"
L["Show the objective tracker for quests, world quests, rares, achievements, and scenarios."] = "퀘스트, 전역 퀘스트, 희귀 몹, 업적, 시나리오를 추적하는 목표 목록창을 표시합니다."
L["Enable Presence module"]                             = "상황 알림  활성화"
L["Cinematic zone text and notifications (zone changes, level up, boss emotes, achievements, quest updates)."] = "시네마틱 지역 텍스트 및 알림 (지역 이동, 레벨 업, 우두머리 감정 표현, 업적, 퀘스트 갱신)."
L["Enable Yield module"]                                = "획득 알림 기능 활성화"
L["Cinematic loot notifications (items, money, currency, reputation)."] = "보기 좋은 전리품 알림창 (아이템, 금화, 통화, 평판)."
L["Enable Vista module"]                                = "미니맵 기능 활성화"
L["Cinematic square minimap with zone text, coordinates, and button collector."] = "지역 텍스트, 좌표, 버튼 수집기가 있는 보기 좋은(?) 사각형 미니맵."
L["Beta"]                                               = "Beta"
L["Scaling"]                                            = "크기 조정"
L["Global UI scale"]                                    = "전체 UI 크기 조정"
L["Scale all sizes, spacings, and fonts by this factor (50–200%). Does not change your configured values."] = "모든 크기, 간격, 글꼴을 이 비율로 조정합니다 (50–200%). 설정값은 변경되지 않습니다."
L["Per-module scaling"]                                 = "기능별 크기 조정 활성화"
L["Override the global scale with individual sliders for each module."] = "전체 크기 조정을 무시하고 각 기능별로 개별 슬라이더를 사용합니다."
L["Focus scale"]                                        = "목록"
L["Scale for the Focus objective tracker (50–200%)."]   = "목표 목록(추적기)의 크기 조정 (50–200%)."
L["Presence scale"]                                     = "상황 알림"
L["Scale for the Presence cinematic text (50–200%)."]   = "보기 좋은 상황 알림 텍스트의 크기 조정 (50–200%)."
L["Vista scale"]                                        = "미니맵"
L["Scale for the Vista minimap module (50–200%)."]      = "미니맵 기능의 크기 조정 (50–200%)."
L["Insight scale"]                                      = "툴팁"
L["Scale for the Insight tooltip module (50–200%)."]    = "툴팁 크기 조정 (50–200%)."
L["Yield scale"]                                        = "획득 알림"
L["Scale for the Yield loot toast module (50–200%)."]   = "획득 알림 기능의 크기 조정 (50–200%)."
L["Enable Horizon Insight module"]                      = "툴팁 기능 활성화"
L["Cinematic tooltips with class colors, spec display, and faction icons."] = "직업 색상, 전문화 표시, 진영 아이콘이 있는 시네마틱 툴팁."
L["Horizon Insight"]                                    = "툴팁 기능"
L["Insight"]                                            = "툴팁"
L["Tooltip anchor mode"]                                = "툴팁 고정 방식"
L["Where tooltips appear: follow cursor or fixed position."] = "툴팁 표시 위치: 커서 추적 또는 고정 위치."
L["Cursor"]                                             = "커서"
L["Fixed"]                                              = "고정"
L["Show anchor to move"]                                = "이동용 상자 표시"
L["Show draggable frame to set fixed tooltip position. Drag, then right-click to confirm."] = "고정 툴팁 위치를 설정할 드래그 가능한 프레임을 표시합니다. 드래그한 후 우클릭하여 확인(고정)합니다."
L["Reset tooltip position"]                             = "툴팁 위치 초기화"
L["Reset fixed position to default."]                   = "고정된 위치를 기본값으로 초기화합니다."
L["Yield"]                                              = "획득 알림"
L["General"]                                            = "일반"
L["Position"]                                           = "위치"
L["Reset position"]                                     = "위치 초기화"
L["Reset loot toast position to default."]              = "전리품 알림 위치를 기본값으로 초기화합니다."

-- =====================================================================
-- OptionsData.lua Layout
-- =====================================================================
L["Lock position"]                                      = "위치 잠금"
L["Prevent dragging the tracker."]                      = "목록을 드래그할 수 없게 합니다."
L["Grow upward"]                                        = "위로 확장"
L["Anchor at bottom so the list grows upward."]         = "아래 기준으로 목록이 위쪽으로 확장됩니다."
L["Start collapsed"]                                    = "접힌 상태로 시작"
L["Start with only the header shown until you expand."] = "펼치기 전까지 헤더만 표시합니다."
L["Panel width"]                                        = "패널 너비"
L["Tracker width in pixels."]                           = "목록 너비 (픽셀)."
L["Max content height"]                                 = "최대 콘텐츠 높이"
L["Max height of the scrollable list (pixels)."]        = "스크롤 목록의 최대 높이 (픽셀)."

-- =====================================================================
-- OptionsData.lua Visibility
-- =====================================================================
L["Always show M+ block"]                                           = "쐐기 항상 표시"
L["Show the M+ block whenever an active keystone is running"]       = "활성 쐐기 실행 중에는 쐐기 블록을 항상 표시합니다."
L["Show in dungeon"]                                    = "던전에서 표시"
L["Show tracker in party dungeons."]                    = "파티 던전에서 추적기를 표시합니다."
L["Show in raid"]                                       = "공격대에서 표시"
L["Show tracker in raids."]                             = "공격대에서 추적기를 표시합니다."
L["Show in battleground"]                               = "전장에서 표시"
L["Show tracker in battlegrounds."]                     = "전장에서 추적기를 표시합니다."
L["Show in arena"]                                      = "투기장에서 표시"
L["Show tracker in arenas."]                            = "투기장에서 추적기를 표시합니다."
L["Hide in combat"]                                     = "전투 중 숨기기"
L["Hide tracker and floating quest item in combat."]    = "전투 중 추적기와 퀘스트 아이템 버튼을 숨깁니다."
L["Combat visibility"]                                  = "전투 중 표시"
L["How the tracker behaves in combat: show, fade to reduced opacity, or hide."] = "전투 중 추적기 동작: 표시, 흐리게 표시 또는 숨기기."
L["Show"]                                               = "표시"
L["Fade"]                                               = "흐리게"
L["Hide"]                                               = "숨기기"
L["Combat fade opacity"]                                = "전투 중 흐림 투명도"
L["How visible the tracker is when faded in combat (0 = invisible). Only applies when Combat visibility is Fade."] = "전투 중 목록의 투명도 정도 (0 = 완전 투명). 전투 중 표시가 흐리게일 때만 적용됩니다."
L["Mouseover"]                                          = "마우스 오버"
L["Show only on mouseover"]                             = "마우스 오버 시에만 표시"
L["Fade tracker when not hovering; move mouse over it to show."] = "마우스를 올리지 않으면 목록을 흐리게 표시합니다. 마우스를 올리면 표시됩니다."
L["Faded opacity"]                                      = "흐림 투명도"
L["How visible the tracker is when faded (0 = invisible)."] = "흐릿할 때 목록의 표시 정도 (0 = 완전 투명)."
L["Only show quests in current zone"]                   = "현재 지역 퀘스트만 표시"
L["Hide quests outside your current zone."]             = "현재 지역 밖의 퀘스트를 숨깁니다."

-- =====================================================================
-- OptionsData.lua Display — Header
-- =====================================================================
L["Show quest count"]                                   = "퀘스트 수 표시"
L["Show quest count in header."]                        = "헤더에 퀘스트 수를 표시합니다."
L["Header count format"]                                = "헤더 수 표시 형식"
L["Tracked/in-log or in-log/max-slots. Tracked excludes world/live-in-zone quests."] = "추적 중/퀘스트 목록 또는 퀘스트 목록/최대 슬롯. 추적 수에는 전역 퀘스트가 포함되지 않습니다."
L["Show header divider"]                                = "헤더 구분선 표시"
L["Show the line below the header."]                    = "헤더 아래 구분선을 표시합니다."
L["Header divider color"]                              = "헤더 구분선 색상"
L["Color of the line below the header."]               = "헤더 아래 선의 색상."
L["Super-minimal mode"]                                 = "간결하게 표시"
L["Hide header for a pure text list."]                  = "헤더를 숨기고 텍스트 목록만 표시합니다."
L["Show options button"]                                = "옵션 버튼 표시"
L["Show the Options button in the tracker header."]     = "추적기 헤더에 옵션 버튼을 표시합니다."
L["Header color"]                                       = "헤더 색상"
L["Color of the OBJECTIVES header text."]               = "목표 헤더 텍스트의 색상."
L["Header height"]                                      = "헤더 높이"
L["Height of the header bar in pixels (18–48)."]        = "헤더 바 높이 (픽셀, 18–48)."

-- =====================================================================
-- OptionsData.lua Display — List
-- =====================================================================
L["Show section headers"]                               = "구역 헤더 표시"
L["Show category labels above each group."]             = "각 그룹 위에 유형 라벨을 표시합니다."
L["Show category headers when collapsed"]               = "접힌 상태에서 구역 헤더 표시"
L["Keep section headers visible when collapsed; click to expand a category."] = "접힌 상태에서도 구역 헤더를 표시합니다. 클릭하면 해당 유형을 펼칩니다."
L["Show Nearby (Current Zone) group"]                   = "근처(현재 지역) 그룹 표시"
L["Show in-zone quests in a dedicated Current Zone section. When off, they appear in their normal category."] = "현재 지역 퀘스트를 전용 구역으로 표시합니다. 끄면 기존 유형에 그대로 표시됩니다."
L["Show zone labels"]                                   = "지역명 표시"
L["Show zone name under each quest title."]             = "각 퀘스트 제목 아래에 지역명을 표시합니다."
L["Active quest highlight"]                             = "퀘스트 강조"
L["How the focused quest is highlighted."]              = "퀘스트의 강조 방식."
L["Show quest item buttons"]                            = "퀘스트 아이템 버튼 표시"
L["Show usable quest item button next to each quest."]  = "각 퀘스트 옆에 사용 가능한 아이템 버튼을 표시합니다."
L["Show objective numbers"]                             = "목표 번호 표시"
L["Prefix objectives with 1., 2., 3."]                  = "목표 앞에 1., 2., 3. 번호를 붙입니다."
L["Show completed count"]                               = "완료 수 표시"
L["Show X/Y progress in quest title."]                  = "퀘스트 제목에 X/Y 진행도를 표시합니다."
L["Show objective progress bar"]                        = "목표 진행 바 표시"
L["Show a progress bar under objectives that have numeric progress (e.g. 3/250). Only applies to entries with a single arithmetic objective where the required amount is greater than 1."] = "숫자 진행도가 있는 목표 아래에 진행 바를 표시합니다 (예: 3/250). 필요 수량이 1보다 큰 단일 산술 목표가 있는 항목에만 적용됩니다."
L["Use category color for progress bar"]                = "진행 바에 카테고리 색상 사용"
L["When on, the progress bar matches the quest/achievement category color. When off, uses the custom fill color below."] = "활성화하면 진행 바가 퀘스트/업적 카테고리 색상과 일치합니다. 비활성화하면 아래의 사용자 지정 채우기 색상을 사용합니다."
L["Use tick for completed objectives"]                  = "완료된 목표에 체크 표시 사용"
L["When on, completed objectives show a checkmark (✓) instead of green color."] = "활성화하면 완료된 목표에 초록색 대신 체크 표시(✓)가 나타납니다."
L["Show entry numbers"]                                 = "항목 번호 표시"
L["Prefix quest titles with 1., 2., 3. within each category."] = "각 유형 내에서 퀘스트 제목 앞에 1., 2., 3. 번호를 붙입니다."
L["Completed objectives"]                               = "완료된 목표"
L["For multi-objective quests, how to display objectives you've completed (e.g. 1/1)."] = "다중 목표 퀘스트에서 완료된 목표(예: 1/1) 표시 방식."
L["Show all"]                                           = "모두 표시"
L["Fade completed"]                                     = "완료 시 흐리게"
L["Hide completed"]                                     = "완료 시 숨기기"
L["Show icon for in-zone auto-tracking"]                = "지역 내 자동 추적 아이콘 표시"
L["Display an icon next to auto-tracked world quests and weeklies/dailies that are not yet in your quest log (in-zone only)."] = "퀘스트 로그에 없는 자동 추적된 전역 퀘스트 및 주간/일일 퀘스트 옆에 아이콘을 표시합니다 (지역 내에서만)."
L["Auto-track icon"]                                    = "자동 추적 아이콘"
L["Choose which icon to display next to auto-tracked in-zone entries."] = "지역 내 자동 추적 항목 옆에 표시할 아이콘을 선택합니다."
L["Append ** to world quests and weeklies/dailies that are not yet in your quest log (in-zone only)."] = "퀘스트 목록에 없는 전역 퀘스트/주간·일일 퀘스트에 ** 접미사를 붙입니다 (해당 지역 내에서만)."

-- =====================================================================
-- OptionsData.lua Display — Spacing
-- =====================================================================
L["Compact mode"]                                                   = "간결 하게"
L["Preset: sets entry and objective spacing to 4 and 1 px."]        = "사전 설정: 퀘스트 간격 4px, 목표 간격 1px로 설정합니다."
L["Spacing between quest entries (px)"]                             = "퀘스트 항목 간격 (px)"
L["Vertical gap between quest entries."]                            = "퀘스트 항목 사이의 세로 간격."
L["Spacing before category header (px)"]                            = "구역 헤더 위 간격 (px)"
L["Gap between last entry of a group and the next category label."] = "이전 그룹의 마지막 항목과 다음 구역 라벨 사이의 간격."
L["Spacing after category header (px)"]                             = "구역 헤더 아래 간격 (px)"
L["Gap between category label and first quest entry below it."]     = "구역 라벨과 첫 번째 퀘스트 항목 사이의 간격."
L["Spacing between objectives (px)"]                                = "목표 간격 (px)"
L["Vertical gap between objective lines within a quest."]           = "퀘스트 내 목표 줄 사이의 세로 간격."
L["Spacing below header (px)"]                                      = "헤더 아래 간격 (px)"
L["Vertical gap between the objectives bar and the quest list."]    = "목표 바와 퀘스트 목록 사이의 세로 간격."
L["Reset spacing"]                                                  = "간격 초기화"

-- =====================================================================
-- OptionsData.lua Display — Other
-- =====================================================================
L["Show quest level"]                                   = "퀘스트 레벨 표시"
L["Show quest level next to title."]                    = "제목 옆에 퀘스트 레벨을 표시합니다."
L["Dim non-focused quests"]                             = "비활성 퀘스트 흐리게"
L["Slightly dim title, zone, objectives, and section headers that are not focused."] = "포커스되지 않은 퀘스트의 제목, 지역, 목표, 구역 헤더를 약간 흐리게 표시합니다."

-- =====================================================================
-- Features — Rare bosses
-- =====================================================================
L["Show rare bosses"]                                   = "희귀 우두머리 표시"
L["Show rare boss vignettes in the list."]              = "목록에 희귀 우두머리를 표시합니다."
L["Rare added sound"]                                   = "희귀 몹 등장 효과음"
L["Play a sound when a rare is added."]                 = "희귀 몹이 추가되면 효과음을 재생합니다."
L["Rare added sound choice"]                            = "희귀 몹 효과음 선택"
L["Choose which sound to play when a rare boss appears. Requires LibSharedMedia sounds to be installed for extra options."] = "희귀 보스가 나타날 때 재생할 효과음을 선택합니다. 추가 옵션을 사용하려면 LibSharedMedia 사운드가 설치되어 있어야 합니다."

-- =====================================================================
-- OptionsData.lua Features — World quests
-- =====================================================================
L["Show in-zone world quests"]                          = "현재 지역 전역 퀘스트 표시"
L["Auto-add world quests in your current zone. When off, only quests you've tracked or world quests you're in close proximity to appear (Blizzard default)."] = "현재 지역의 전역 퀘스트를 자동으로 표시합니다. 끄면 추적 목록에 있거나 퀘스트 지역에 가까이 있는 전역 퀘스트만 표시됩니다 (블리자드 기본값)."

-- =====================================================================
-- OptionsData.lua Features — Floating quest item
-- =====================================================================
L["Show floating quest item"]                           = "퀘스트 아이템 버튼 표시"
L["Show quick-use button for the focused quest's usable item."] = "고정된 퀘스트의 사용 가능한 아이템을 빠른 사용 버튼으로 표시합니다."
L["Lock floating quest item position"]                  = "퀘스트 아이템 버튼 위치 잠금"
L["Prevent dragging the floating quest item button."]   = "퀘스트 아이템 버튼을 드래그할 수 없게 합니다."
L["Floating quest item source"]                         = "퀘스트 아이템 버튼 소스"
L["Which quest's item to show: super-tracked first, or current zone first."] = "표시할 퀘스트 아이템: 초점 퀘스트 우선 또는 현재 지역 우선."
L["Super-tracked, then first"]                          = "고정 퀘스트 우선"
L["Current zone first"]                                 = "현재 지역 우선"

-- =====================================================================
-- OptionsData.lua Features — Mythic+
-- =====================================================================
L["Show Mythic+ block"]                                 = "쐐기 정보 표시"
L["Show timer, completion %, and affixes in Mythic+ dungeons."] = "쐐기 던전에서 시간, 완료율, 쐐기 속성을 표시합니다."
L["M+ block position"]                                  = "쐐기 정보 표시 위치"
L["Position of the Mythic+ block relative to the quest list."] = "퀘스트 목록에 대한 쐐기 정보 표시의 위치."
L["Show affix icons"]                                   = "시즌 효과 아이콘 표시"
L["Show affix icons next to modifier names in the M+ block."] = "시즌 효과 이름 옆에 아이콘을 표시합니다."
L["Show affix descriptions in tooltip"]                 = "툴팁에 시즌 효과 설명 표시"
L["Show affix descriptions when hovering over the M+ block."] = "표시 위에 마우스를 올리면 시즌 효과 설명을 표시합니다."
L["M+ completed boss display"]                          = "처치 우두머리 표시"
L["How to show defeated bosses: checkmark icon or green color."] = "처치한 우두머리 표시 방식: 체크 아이콘 또는 초록색."
L["Checkmark"]                                          = "체크 표시"
L["Green color"]                                        = "초록색"

-- =====================================================================
-- OptionsData.lua Features — Achievements
-- =====================================================================
L["Show achievements"]                                  = "업적 표시"
L["Show tracked achievements in the list."]             = "추적 중인 업적을 목록에 표시합니다."
L["Show completed achievements"]                        = "완료된 업적 표시"
L["Include completed achievements in the tracker. When off, only in-progress tracked achievements are shown."] = "완료된 업적도 목록에 표시합니다. 끄면 진행 중인 업적만 표시됩니다."
L["Show achievement icons"]                             = "업적 아이콘 표시"
L["Show each achievement's icon next to the title. Requires 'Show quest type icons' in Display."] = "각 업적의 아이콘을 제목 옆에 표시합니다. '퀘스트 유형 아이콘 표시' 옵션이 필요합니다."
L["Only show missing requirements"]                     = "미완료 조건만 표시"
L["Show only criteria you haven't completed for each tracked achievement. When off, all criteria are shown."] = "추적 중인 업적에서 미완료 조건만 표시합니다. 끄면 모든 조건을 표시합니다."

-- =====================================================================
-- OptionsData.lua Features — Endeavors
-- =====================================================================
L["Show endeavors"]                                       = "활동 과제 표시"
L["Show tracked Endeavors (Player Housing) in the list."] = "추적 중인 활동 과제(플레이어 주택)를 목록에 표시합니다."
L["Show completed endeavors"]                             = "완료된 활동 과제 표시"
L["Include completed Endeavors in the tracker. When off, only in-progress tracked Endeavors are shown."] = "완료된 활동 과제도 추적기에 표시합니다. 끄면 진행 중인 활동 과제만 표시됩니다."

-- =====================================================================
-- OptionsData.lua Features — Decor
-- =====================================================================
L["Show decor"]                                         = "장식 표시"
L["Show tracked housing decor in the list."]            = "추적 중인 주택 장식을 목록에 표시합니다."
L["Show decor icons"]                                   = "장식 아이콘 표시"
L["Show each decor item's icon next to the title. Requires 'Show quest type icons' in Display."] = "각 장식 아이템의 아이콘을 제목 옆에 표시합니다. '퀘스트 유형 아이콘 표시' 옵션이 필요합니다."

-- =====================================================================
-- OptionsData.lua Features — Adventure Guide
-- =====================================================================
L["Adventure Guide"]                                    = "모험 안내서"
L["Show Traveler's Log"]                                = "여행자의 기록 표시"
L["Show tracked Traveler's Log objectives (Shift+click in Adventure Guide) in the list."] = "추적 중인 여행자의 기록 목표(모험 안내서에서 Shift+클릭)를 목록에 표시합니다."
L["Auto-remove completed activities"]                   = "완료된 활동 자동 제거"
L["Automatically stop tracking Traveler's Log activities once they have been completed."] = "완료된 여행자의 기록 활동의 추적을 자동으로 중지합니다."

-- =====================================================================
-- OptionsData.lua Features — Scenario & Delve
-- =====================================================================
L["Show scenario events"]                               = "시나리오 표시"
L["Show active scenario and Delve activities. Delves appear in DELVES; other scenarios in SCENARIO EVENTS."] = "시나리오와 구렁을 표시합니다. 구렁은 DELVES에, 기타 시나리오는 SCENARIO EVENTS에 표시됩니다."
L["Hide other categories in Delve or Dungeon"]          = "구렁/던전에서 다른 유형 숨기기"
L["In Delves or party dungeons, show only the Delve/Dungeon section."] = "구렁 또는 파티 던전에서는 해당 구역만 표시합니다."
L["Use delve name as section header"]                   = "구렁명을 구역 헤더로 사용"
L["When in a Delve, show the delve name, tier, and affixes as the section header instead of a separate banner. Disable to show the Delve block above the list."] = "구렁 중일 때 별도 배너 대신 구역 헤더에 구렁명, 난이도 단계, 시즌 효과를 표시합니다. 끄면 목록 위에 구렁 블록이 표시됩니다."
L["Show affix names in Delves"]                         = "구렁에 시즌 효과 표시"
L["Show season affix names on the first Delve entry. Requires Blizzard's objective tracker widgets to be populated; may not show when using a full tracker replacement."] = "첫 번째 구렁 항목에 시즌 효과 이름을 표시합니다. Blizzard 목표 추적기 위젯이 필요하며, 전체 추적기 대체 시 표시되지 않을 수 있습니다."
L["Cinematic scenario bar"]                             = "보기 좋은 시나리오 바"
L["Show timer and progress bar for scenario entries."]  = "시나리오 항목에 시간과 진행 바를 표시합니다."
L["Show timer"]                                         = "타이머 표시"
L["Show countdown timer on timed quests, events, and scenarios. When off, timers are hidden for all entry types."] = "제한 시간 퀘스트, 이벤트, 시나리오에서 카운트다운 타이머 표시. 끄면 모든 유형의 타이머가 숨겨집니다."
L["Timer display"]                                      = "타이머 표시"
L["Color timer by remaining time"]                     = "남은 시간에 따른 타이머 색상"
L["Green when plenty of time left, yellow when running low, red when critical."] = "여유 있을 때 녹색, 부족할 때 노란색, 위급할 때 빨간색."
L["Where to show the countdown: bar below objectives or text beside the quest name."] = "카운트다운 표시 위치: 목표 아래 막대 또는 퀘스트 이름 옆 텍스트."
L["Bar below"]                                          = "아래 막대"
L["Inline beside title"]                                = "제목 옆"
L["Show countdown timer bars on timed quests, events, and scenarios. When off, timer bars are hidden for all entry types."] = "시간 제한 퀘스트, 이벤트 및 시나리오에 카운트다운 타이머 바를 표시합니다. 꺼져 있으면 모든 항목에서 타이머 바가 숨겨집니다."

-- =====================================================================
-- OptionsData.lua Typography — Font
-- =====================================================================
L["Font family."]                                       = "글꼴."
L["Title font"]                                         = "제목 글꼴"
L["Zone font"]                                          = "지역 글꼴"
L["Objective font"]                                     = "목표 글꼴"
L["Section font"]                                       = "구역 글꼴"
L["Use global font"]                                    = "전역 글꼴 사용"
L["Font family for quest titles."]                      = "퀘스트 제목 글꼴."
L["Font family for zone labels."]                       = "지역명 글꼴."
L["Font family for objective text."]                    = "목표 글꼴."
L["Font family for section headers."]                   = "구역 헤더 글꼴."
L["Header size"]                                        = "헤더 크기"
L["Header font size."]                                  = "헤더 글자 크기."
L["Title size"]                                         = "제목 크기"
L["Quest title font size."]                             = "퀘스트 제목 글자 크기."
L["Objective size"]                                     = "목표 크기"
L["Objective text font size."]                          = "목표 텍스트 글자 크기."
L["Zone size"]                                          = "지역 크기"
L["Zone label font size."]                              = "지역명 글자 크기."
L["Section size"]                                       = "구역 크기"
L["Section header font size."]                          = "구역 헤더 글자 크기."
L["Progress bar font"]                                  = "진행 바 글꼴"
L["Font family for the progress bar label."]            = "진행 바 텍스트의 글자."
L["Progress bar text size"]                             = "진행 바 텍스트 크기"
L["Font size for the progress bar label. Also adjusts bar height. Affects quest objectives, scenario progress, and scenario timer bars."] = "진행 바 글자 크기. 바 높이도 함께 조정됩니다. 퀘스트 목표, 시나리오 진행 및 시나리오 타이머 바에 적용됩니다."
L["Progress bar fill"]                                  = "진행 바 채우기"
L["Progress bar text"]                                  = "진행 바 글자"
L["Outline"]                                            = "외곽선"
L["Font outline style."]                                = "글꼴에 적용할 외곽선 종류를 설정합니다."

-- =====================================================================
-- OptionsData.lua Typography — Text case
-- =====================================================================
L["Header text case"]                                   = "헤더 대소문자"
L["Display case for header."]                           = "헤더의 대소문자 표시 방식."
L["Section header case"]                                = "구역 헤더 대소문자"
L["Display case for category labels."]                  = "유형 라벨의 대소문자 표시 방식."
L["Quest title case"]                                   = "퀘스트 제목 대소문자"
L["Display case for quest titles."]                     = "퀘스트 제목의 대소문자 표시 방식."

-- =====================================================================
-- OptionsData.lua Typography — Shadow
-- =====================================================================
L["Show text shadow"]                                   = "글자 그림자 표시"
L["Enable drop shadow on text."]                        = "글자에 그림자를 표시합니다."
L["Shadow X"]                                           = "가로"
L["Horizontal shadow offset."]                          = "가로 그림자 설정."
L["Shadow Y"]                                           = "세로"
L["Vertical shadow offset."]                            = "세로 그림자 설정."
L["Shadow alpha"]                                       = "그림자 투명도"
L["Shadow opacity (0–1)."]                              = "그림자 투명도 (0–1)."

-- =====================================================================
-- OptionsData.lua Typography — Mythic+ Typography
-- =====================================================================
L["Mythic+ Typography"]                                 = "쐐기돌 글자"
L["Dungeon name size"]                                  = "던전명 크기"
L["Font size for dungeon name (8–32 px)."]              = "던전명 글자 크기 (8–32 px)."
L["Dungeon name color"]                                 = "던전명 색상"
L["Text color for dungeon name."]                       = "던전명 글자 색상."
L["Timer size"]                                         = "타이머 크기"
L["Font size for timer (8–32 px)."]                     = "타이머 글자 크기 (8–32 px)."
L["Timer color"]                                        = "타이머 색상"
L["Text color for timer (in time)."]                    = "타이머 글자 색상 (제한 시간 내)."
L["Timer overtime color"]                               = "타이머 초과 색상"
L["Text color for timer when over the time limit."]     = "시간 초과 시 타이머 글자 색상."
L["Progress size"]                                      = "진행도 크기"
L["Font size for enemy forces (8–32 px)."]              = "적 병력 글자 크기 (8–32 px)."
L["Progress color"]                                     = "진행도 색상"
L["Text color for enemy forces."]                       = "적 병력 글자 색상."
L["Bar fill color"]                                     = "진행 바 채우기 색상"
L["Progress bar fill color (in progress)."]             = "진행 바 채우기 색상 (진행 중)."
L["Bar complete color"]                                 = "바 완료 색상"
L["Progress bar fill color when enemy forces are at 100%."] = "적 병력 100% 시 진행 바 채우기 색상."
L["Affix size"]                                         = "시즌 효과 크기"
L["Font size for affixes (8–32 px)."]                   = "시즌 효과 글자 크기 (8–32 px)."
L["Affix color"]                                        = "시즌 효과 색상"
L["Text color for affixes."]                            = "시즌 효과 글자 색상."
L["Boss size"]                                          = "우두머리 이름 크기"
L["Font size for boss names (8–32 px)."]                = "우두머리 이름 글자 크기 (8–32 px)."
L["Boss color"]                                         = "우두머리 이름 색상"
L["Text color for boss names."]                         = "우두머리 이름 글자 색상."
L["Reset Mythic+ typography"]                           = "쐐기돌 글자 초기화"

-- =====================================================================
-- OptionsData.lua Appearance
-- =====================================================================
L["Backdrop opacity"]                                   = "배경 투명도"
L["Panel background opacity (0–1)."]                    = "패널 배경 투명도 (0–1)."
L["Show border"]                                        = "테두리 표시"
L["Show border around the tracker."]                    = "목록 주변에 테두리를 표시합니다."
L["Show scroll indicator"]                              = "스크롤 표시기 표시"
L["Show a visual hint when the list has more content than is visible."] = "목록에 보이는 것보다 더 많은 항목이 있을 때 시각적 힌트를 표시합니다."
L["Scroll indicator style"]                             = "스크롤 표시기 스타일"
L["Choose between a fade-out gradient or a small arrow to indicate scrollable content."] = "스크롤 가능한 항목을 나타내는 페이드 그라데이션 또는 작은 화살표 중 선택합니다."
L["Arrow"]                                              = "화살표"
L["Highlight alpha"]                                    = "강조 투명도"
L["Opacity of focused quest highlight (0–1)."]          = "고정된 퀘스트 강조의 투명도 (0–1)."
L["Bar width"]                                          = "바 너비"
L["Width of bar-style highlights (2–6 px)."]            = "바 스타일 강조의 너비 (2–6 px)."

-- =====================================================================
-- OptionsData.lua Organization
-- =====================================================================
L["Focus category order"]                               = "퀘스트 목록 유형 순서"
L["Drag to reorder categories. DELVES and SCENARIO EVENTS stay first."] = "드래그하여 유형 순서를 변경합니다. DELVES와 SCENARIO EVENTS는 항상 최상위에 고정됩니다."
L["Focus sort mode"]                                    = "퀘스트 목록 정렬 방식"
L["Order of entries within each category."]             = "각 유형 내 항목의 정렬 순서."
L["Auto-track accepted quests"]                         = "수락한 퀘스트 자동 추적"
L["When you accept a quest (quest log only, not world quests), add it to the tracker automatically."] = "퀘스트를 수락하면 목록에 자동으로 추가합니다 (퀘스트 목록만 해당, 전역 퀘스트 제외)."
L["Require Ctrl for focus & remove"]                    = "퀘스트 목록/제거 시 Ctrl 필요"
L["Require Ctrl for focus/add (Left) and unfocus/untrack (Right) to prevent misclicks."] = "클릭 방지를 위해 퀘스트 목록/추가(좌클릭)와 해제/추적 중지(우클릭) 시 컨트롤 키를 요구합니다."
L["Use classic click behaviour"]                             = "클래식 클릭 동작 사용"
L["Share with party"]                                        = "파티에 공유"
L["Abandon quest"]                                           = "퀘스트 포기"
L["Stop tracking"]                                           = "추적 중지"
L["This quest cannot be shared."]                             = "이 퀘스트는 공유할 수 없습니다."
L["You must be in a party to share this quest."]              = "이 퀘스트를 공유하려면 파티에 참여해야 합니다."
L["When on, left-click opens the quest map and right-click shows share/abandon menu (Blizzard-style). When off, left-click focuses and right-click untracks; Ctrl+Right shares with party."] = "활성화 시 좌클릭으로 퀘스트 지도 열기, 우클릭으로 공유/포기 메뉴 표시(블리자드 방식). 비활성화 시 좌클릭으로 추적, 우클릭으로 추적 해제; Ctrl+우클릭으로 파티에 공유."
L["Animations"]                                         = "애니메이션"
L["Enable slide and fade for quests."]                  = "퀘스트에 슬라이드 및 페이드 효과를 활성화합니다."
L["Objective progress flash"]                           = "목표 완료 효과"
L["Show flash when an objective completes."]            = "목표 완료 시 효과를 표시합니다."
L["Flash intensity"]                                    = "효과 강도"
L["How noticeable the objective-complete flash is."]    = "목표 완료 시 표시되는 효과의 강도입니다."
L["Flash color"]                                        = "효과 색상"
L["Color of the objective-complete flash."]             = "목표 완료 시 표시되는 효과의 색상입니다."
L["Subtle"]                                             = "은은함"
L["Medium"]                                             = "보통"
L["Strong"]                                             = "강함"
L["Require Ctrl for click to complete"]                 = "클릭 완료 시 컨트롤 키 필요"
L["When on, requires Ctrl+Left-click to complete auto-complete quests. When off, plain Left-click completes them (Blizzard default). Only affects quests that can be completed by click (no NPC turn-in needed)."] = "활성화하면 자동 완료 퀘스트를 완료할 때 Ctrl+좌클릭이 필요합니다. 비활성화하면 일반 좌클릭으로 완료됩니다 (Blizzard 기본값). NPC 제출 없이 클릭으로 완료 가능한 퀘스트에만 적용됩니다."
L["Suppress untracked until reload"]                    = "재접속 전까지 추적 해제 숨기기"
L["When on, right-click untrack on world quests and in-zone weeklies/dailies hides them until you reload or start a new session. When off, they reappear when you return to the zone."] = "활성화하면 전역 퀘스트와 지역 내 주간·일일 퀘스트에서 우클릭 추적 해제 시 재접속할 때까지 숨깁니다. 비활성화하면 해당 지역에 돌아오면 다시 표시됩니다."
L["Permanently suppress untracked quests"]              = "추적 해제한 퀘스트 영구 숨기기"
L["When on, right-click untracked world quests and in-zone weeklies/dailies are hidden permanently (persists across reloads). Takes priority over 'Suppress until reload'. Accepting a suppressed quest removes it from the blacklist."] = "활성화하면 우클릭 추적 해제한 전역 퀘스트와 지역 내 주간·일일 퀘스트가 영구적으로 숨겨집니다 (재접속 후에도 유지). '재접속 전까지 숨기기'보다 우선합니다. 숨긴 퀘스트를 수락하면 차단 목록에서 제거됩니다."
L["Keep campaign quests in category"]                   = "대장정 퀘스트를 카테고리에 유지"
L["When on, campaign quests that are ready to turn in remain in the Campaign category instead of moving to Complete."] = "활성화하면 완료 가능한 대장정 퀘스트가 완료 카테고리로 이동하지 않고 캠페인 카테고리에 남습니다."
L["Keep important quests in category"]                  = "중요 퀘스트를 카테고리에 유지"
L["When on, important quests that are ready to turn in remain in the Important category instead of moving to Complete."] = "활성화하면 완료 가능한 중요 퀘스트가 완료 카테고리로 이동하지 않고 중요 카테고리에 남습니다."
L["TomTom quest waypoint"]                               = "TomTom 퀘스트 경유지"
L["Set a TomTom waypoint when focusing a quest."]        = "퀘스트를 집중할 때 TomTom 경유지를 설정합니다."
L["Requires TomTom. Points the arrow to the next quest objective."] = "TomTom이 필요합니다. 화살표가 다음 퀘스트 목표를 가리킵니다."

-- =====================================================================
-- OptionsData.lua Blacklist
-- =====================================================================
L["Blacklisted quests"]                                  = "차단된 퀘스트"
L["Permanently suppressed quests"]                       = "영구 숨김 퀘스트"
L["Right-click untrack quests with 'Permanently suppress untracked quests' enabled to add them here."] = "'추적 해제한 퀘스트 영구 숨기기'가 활성화된 상태에서 우클릭 추적 해제한 퀘스트가 여기에 추가됩니다."

-- =====================================================================
-- OptionsData.lua Presence
-- =====================================================================
L["Show quest type icons"]                              = "퀘스트 유형 아이콘 표시"
L["Show quest type icon in the Focus tracker (quest accept/complete, world quest, quest update)."] = "목표 추적기에 퀘스트 유형 아이콘을 표시합니다 (퀘스트 수락/완료, 전역 퀘스트, 퀘스트 갱신)."
L["Show quest type icons on toasts"]                    = "알림에 퀘스트 유형 아이콘 표시"
L["Show quest type icon on Presence toasts (quest accept/complete, world quest, quest update)."] = "알림에 퀘스트 유형 아이콘을 표시합니다 (퀘스트 수락/완료, 전역 퀘스트, 퀘스트 갱신)."
L["Toast icon size"]                                    = "알림 아이콘 크기"
L["Quest icon size on Presence toasts (16–36 px). Default 24."] = "알림의 퀘스트 아이콘 크기 (16–36 px). 기본값 24."
L["Hide quest update title"]                            = "퀘스트 진행 알림에서 제목 숨기기"
L["Show only the objective line on quest progress toasts (e.g. 7/10 Boar Pelts), without the quest name or header."] = "퀘스트 이름이나 제목 없이 목표 줄만 표시합니다 (예: 7/10 멧돼지 가죽)."
L["Show discovery line"]                                = "발견 텍스트 표시"
L["Show 'Discovered' under zone/subzone when entering a new area."] = "새 지역에 진입할 때 지역/하위 지역 아래에 '발견' 글자를 표시합니다."
L["Frame vertical position"]                            = "알림 세로 위치"
L["Vertical offset of the Presence frame from center (-300 to 0)."] = "중앙 기준 알림 프레임의 세로 위치(-300 ~ 0)."
L["Frame scale"]                                        = "알림 크기"
L["Scale of the Presence frame (0.5–2)."]              = "알림 프레임 크기 (0.5–2)."
L["Boss emote color"]                                   = "우두머리 감정 표현 색상"
L["Color of raid and dungeon boss emote text."]         = "공격대/던전 우두머리 감정 표현 글자 색상."
L["Discovery line color"]                               = "발견 글자 색상"
L["Color of the 'Discovered' line under zone text."]    = "지역 텍스트 아래 '발견' 글자 색상."
L["Notification types"]                                 = "알림 유형"
L["Show zone entry"]                                    = "지역 입장 표시"
L["Show zone change when entering a new area."]         = "새 지역에 입장할 때 알림을 표시합니다."
L["Show subzone changes"]                               = "하위 지역 변경 표시"
L["Show subzone change when moving within the same zone."] = "같은 지역 내에서 이동할 때 하위 지역 변경 알림을 표시합니다."
L["Hide zone name for subzone changes"]                 = "하위 지역 변경 시 지역 이름 숨기기"
L["When moving between subzones within the same zone, only show the subzone name. The zone name still appears when entering a new zone."] = "같은 지역 내에서 하위 지역 간 이동 시 하위 지역 이름만 표시합니다. 새 지역에 입장할 때는 지역 이름이 여전히 표시됩니다."
L["Suppress zone changes in Mythic+"]                   = "신화+ 던전에서 지역 변경 숨기기"
L["In Mythic+, only show boss emotes, achievements, and level-up. Hide zone, quest, and scenario notifications."] = "쐐기에서는 우두머리 감정 표현, 업적, 레벨 업만 표시합니다. 지역, 퀘스트, 시나리오 알림은 숨깁니다."
L["Show level up"]                                      = "레벨 업 표시"
L["Show level-up notification."]                        = "레벨 업 알림을 표시합니다."
L["Show boss emotes"]                                   = "우두머리 감정 표현 표시"
L["Show raid and dungeon boss emote notifications."]    = "공격대 및 던전 우두머리 감정 표현 알림을 표시합니다."
L["Show achievements"]                                  = "업적 표시"
L["Show achievement earned notifications."]             = "업적 달성 알림을 표시합니다."
L["Achievement progress"]                               = "업적 진행도"
L["Show notification when tracked achievement criteria update."] = "추적 중인 업적 기준이 갱신될 때 알림을 표시합니다."
L["Show quest accept"]                                  = "퀘스트 수락 표시"
L["Show notification when accepting a quest."]          = "퀘스트를 수락할 때 알림을 표시합니다."
L["Show world quest accept"]                            = "전역 퀘스트 수락 표시"
L["Show notification when accepting a world quest."]   = "전역 퀘스트를 수락할 때 알림을 표시합니다."
L["Show quest complete"]                                = "퀘스트 완료 표시"
L["Show notification when completing a quest."]         = "퀘스트를 완료할 때 알림을 표시합니다."
L["Show world quest complete"]                          = "전역 퀘스트 완료 표시"
L["Show notification when completing a world quest."]  = "전역 퀘스트를 완료할 때 알림을 표시합니다."
L["Show quest progress"]                                = "퀘스트 진행 표시"
L["Show notification when quest objectives update."]   = "퀘스트 목표가 갱신될 때 알림을 표시합니다."
L["Objective only"]                                     = "목표만 표시"
L["Show only the objective line on quest progress toasts, hiding the 'Quest Update' title."] = "퀘스트 진행 알림에서 '퀘스트 갱신' 제목을 숨기고 목표 줄만 표시합니다."
L["Show scenario start"]                                = "시나리오 시작 표시"
L["Show notification when entering a scenario or Delve."] = "시나리오나 구렁에 입장할 때 알림을 표시합니다."
L["Show scenario progress"]                             = "시나리오 진행 표시"
L["Show notification when scenario or Delve objectives update."] = "시나리오나 구렁 목표가 갱신될 때 알림을 표시합니다."
L["Animation"]                                          = "애니메이션"
L["Enable animations"]                                  = "애니메이션 사용"
L["Enable entrance and exit animations for Presence notifications."] = "알림의 등장 및 퇴장 애니메이션을 활성화합니다."
L["Entrance duration"]                                  = "등장 시간"
L["Duration of the entrance animation in seconds (0.2–1.5)."] = "등장 애니메이션 시간(초, 0.2–1.5)."
L["Exit duration"]                                      = "퇴장 시간"
L["Duration of the exit animation in seconds (0.2–1.5)."] = "퇴장 애니메이션 시간(초, 0.2–1.5)."
L["Hold duration scale"]                                = "표시 시간 크기 조절"
L["Multiplier for how long each notification stays on screen (0.5–2)."] = "각 알림이 화면에 표시되는 시간 크기조절 (0.5–2)."
L["Typography"]                                         = "글꼴"
L["Main title font"]                                    = "메인 제목 글꼴"
L["Font family for the main title."]                     = "메인 제목 글꼴 패밀리."
L["Subtitle font"]                                      = "부제목 글꼴"
L["Font family for the subtitle."]                      = "부제목 글꼴 패밀리."
L["Main title size"]                                    = "제목 크기"
L["Font size for the main title (24–72 px)."]           = "메인 제목 글자 크기 (24–72 px)."
L["Subtitle size"]                                      = "부제목 크기"
L["Font size for the subtitle (12–40 px)."]             = "부제목 글자 크기 (12–40 px)."

-- =====================================================================
-- OptionsData.lua Dropdown options — Outline
-- =====================================================================
L["None"]                                               = "없음"
L["Thick Outline"]                                      = "두꺼운 외곽선"

-- =====================================================================
-- OptionsData.lua Dropdown options — Highlight style
-- =====================================================================
L["Bar (left edge)"]                                    = "바 (왼쪽)"
L["Bar (right edge)"]                                   = "바 (오른쪽)"
L["Bar (top edge)"]                                     = "바 (위)"
L["Bar (bottom edge)"]                                  = "바 (아래)"
L["Outline only"]                                       = "외곽선만"
L["Soft glow"]                                          = "은은한 발광"
L["Dual edge bars"]                                     = "양쪽 바"
L["Pill left accent"]                                   = "알약형 왼쪽 강조"

-- =====================================================================
-- OptionsData.lua Dropdown options — M+ position
-- =====================================================================
L["Top"]                                                = "위"
L["Bottom"]                                             = "아래"

-- =====================================================================
-- OptionsData.lua Vista — Text element positions
-- =====================================================================
L["Location position"]                                  = "위치 표시"
L["Place the zone name above or below the minimap."]      = "지역 이름을 미니맵 위 또는 아래에 배치합니다."
L["Coordinates position"]                               = "좌표 위치"
L["Place the coordinates above or below the minimap."]   = "좌표를 미니맵 위 또는 아래에 배치합니다."
L["Clock position"]                                     = "시계 위치"
L["Place the clock above or below the minimap."]         = "시계를 미니맵 위 또는 아래에 배치합니다."

-- =====================================================================
-- OptionsData.lua Dropdown options — Text case
-- =====================================================================
L["Lower Case"]                                         = "소문자"
L["Upper Case"]                                         = "대문자"
L["Proper"]                                             = "첫 글자만 대문자"

-- =====================================================================
-- OptionsData.lua Dropdown options — Header count format
-- =====================================================================
L["Tracked / in log"]                                   = "추적 중 / 목록"
L["In log / max slots"]                                 = "목록 / 최대 목록"

-- =====================================================================
-- OptionsData.lua Dropdown options — Sort mode
-- =====================================================================
L["Alphabetical"]                                       = "이름순"
L["Quest Type"]                                         = "퀘스트 유형"
L["Quest Level"]                                        = "퀘스트 레벨"

-- =====================================================================
-- OptionsData.lua Misc
-- =====================================================================
L["Custom"]                                             = "사용자 지정"
L["Order"]                                              = "순서"

-- =====================================================================
-- Tracker section labels (SECTION_LABELS)
-- =====================================================================
L["DUNGEON"]           = "던전"
L["RAID"]              = "공격대"
L["DELVES"]            = "구렁"
L["SCENARIO EVENTS"]   = "시나리오"
L["AVAILABLE IN ZONE"] = "지역 내 수락 가능"
L["EVENTS IN ZONE"] = "지역 내 이벤트"
L["CURRENT ZONE"]      = "현재 지역"
L["CAMPAIGN"]          = "대장정"
L["IMPORTANT"]         = "중요"
L["LEGENDARY"]         = "전설"
L["WORLD QUESTS"]      = "전역 퀘스트"
L["WEEKLY QUESTS"]     = "주간 퀘스트"
L["DAILY QUESTS"]      = "일일 퀘스트"
L["RARE BOSSES"]       = "희귀 우두머리"
L["ACHIEVEMENTS"]      = "업적"
L["ENDEAVORS"]         = "활동 과제"
L["DECOR"]             = "장식"
L["QUESTS"]            = "퀘스트"
L["READY TO TURN IN"]  = "완료된 퀘스트"

-- =====================================================================
-- Core.lua, FocusLayout.lua, PresenceCore.lua, FocusUnacceptedPopup.lua
-- =====================================================================
L["OBJECTIVES"]                                                                                    = "목표"
L["Options"]                                                                                       = "옵션"
L["Discovered"]                                                                                    = "발견됨"
L["Refresh"]                                                                                       = "새로고침"
L["Best-effort only. Some unaccepted quests are not exposed until you interact with NPCs or meet phasing conditions."] = "최선을 다해 검색합니다. 일부 미수락 퀘스트는 NPC와 상호작용하거나 페이징 조건을 만족해야 노출됩니다."
L["Unaccepted Quests - %s (map %s) - %d match(es)"]                                                = "미수락 퀘스트 - %s (맵 %s) - %d건 일치"

L["LEVEL UP"]                                                                                      = "레벨 업"
L["You have reached level 80"]                                                                     = "드디어! 80레벨"
L["You have reached level %s"]                                                                     = "%s레벨에 도달했습니다"
L["ACHIEVEMENT EARNED"]                                                                            = "업적 달성"
L["Exploring the Midnight Isles"]                                                                  = "한밤의 섬 탐험"
L["Exploring Khaz Algar"]                                                                          = "카즈 알가르 탐험"
L["QUEST COMPLETE"]                                                                                = "퀘스트 완료"
L["Objective Secured"]                                                                             = "목표 확보"
L["Aiding the Accord"]                                                                             = "협약 지원"
L["WORLD QUEST"]                                                                                   = "전역 퀘스트"
L["Azerite Mining"]                                                                                = "아제라이트 채굴"
L["WORLD QUEST ACCEPTED"]                                                                          = "전역 퀘스트 수락"
L["QUEST ACCEPTED"]                                                                                = "퀘스트 수락"
L["The Fate of the Horde"]                                                                         = "호드의 운명"
L["New Quest"]                                                                                     = "새 퀘스트"
L["QUEST UPDATE"]                                                                                  = "퀘스트 업데이트"
L["Boar Pelts: 7/10"]                                                                              = "멧돼지 가죽: 7/10"
L["Dragon Glyphs: 3/5"]                                                                            = "용의 문양: 3/5"

L["Presence test commands:"]                                                                       = "상황 알림 테스트 명령어:"
L["  /h presence         - Show help + test current zone"]                                   = "  /h presence         - 도움말 표시 + 현재 지역 테스트"
L["  /h presence zone     - Test Zone Change"]                                               = "  /h presence zone     - 지역 변경 테스트"
L["  /h presence subzone  - Test Subzone Change"]                                            = "  /h presence subzone  - 하위 지역 변경 테스트"
L["  /h presence discover - Test Zone Discovery"]                                            = "  /h presence discover - 지역 발견 테스트"
L["  /h presence level    - Test Level Up"]                                                  = "  /h presence level    - 레벨 업 테스트"
L["  /h presence boss     - Test Boss Emote"]                                                = "  /h presence boss     - 우두머리 감정 표현 테스트"
L["  /h presence ach      - Test Achievement"]                                               = "  /h presence ach      - 업적 테스트"
L["  /h presence accept   - Test Quest Accepted"]                                            = "  /h presence accept   - 퀘스트 수락 테스트"
L["  /h presence wqaccept - Test World Quest Accepted"]                                      = "  /h presence wqaccept - 전역 퀘스트 수락 테스트"
L["  /h presence scenario - Test Scenario Start"]                                            = "  /h presence scenario - 시나리오 시작 테스트"
L["  /h presence quest    - Test Quest Complete"]                                            = "  /h presence quest    - 퀘스트 완료 테스트"
L["  /h presence wq       - Test World Quest"]                                               = "  /h presence wq       - 전역 퀘스트 테스트"
L["  /h presence update   - Test Quest Update"]                                              = "  /h presence update   - 퀘스트 업데이트 테스트"
L["  /h presence achprogress - Test Achievement Progress"]                                   = "  /h presence achprogress - 업적 진행도 테스트"
L["  /h presence all      - Demo reel (all types)"]                                          = "  /h presence all      - 데모 (모든 유형)"
L["  /h presence debug    - Dump state to chat"]                                             = "  /h presence debug    - 상태를 채팅에 출력"
L["  /h presence debuglive - Toggle live debug panel (log as events happen)"]                = "  /h presence debuglive - 실시간 디버그 패널 토글 (이벤트 발생 시 로그)"
L["Minimap"]                                                        = "미니맵"
L["Minimap size"]                                                   = "미니맵 크기"
L["Width and height of the minimap in pixels (100–400)."]           = "미니맵의 가로 및 세로 크기 (픽셀, 100–400)."
L["Circular minimap"]                                               = "원형 미니맵"
L["Use a circular minimap instead of square."]                      = "사각형 대신 원형 미니맵을 사용합니다."
L["Lock minimap position"]                                          = "미니맵 위치 잠금"
L["Prevent dragging the minimap."]                                  = "미니맵을 드래그할 수 없게 합니다."
L["Reset minimap position"]                                         = "미니맵 위치 초기화"
L["Reset minimap to its default position (top-right)."]             = "미니맵을 기본 위치(오른쪽 상단)로 초기화합니다."
L["Auto Zoom"]                                                      = "자동 줌"
L["Auto zoom-out delay"]                                            = "자동 줌아웃 지연"
L["Seconds after zooming before auto zoom-out fires. Set to 0 to disable."] = "줌 후 자동 줌아웃까지의 초. 0으로 설정하면 비활성화됩니다."
L["Zone Text"]                                                      = "지역 텍스트"
L["Zone font"]                                                      = "지역 글꼴"
L["Font for the zone name below the minimap."]                      = "미니맵 아래 지역명 글꼴."
L["Zone font size"]                                                 = "지역 글자 크기"
L["Zone text color"]                                                = "지역 텍스트 색상"
L["Color of the zone name text."]                                   = "지역명 텍스트 색상."
L["Coordinates Text"]                                               = "좌표 텍스트"
L["Coordinates font"]                                               = "좌표 글꼴"
L["Font for the coordinates text below the minimap."]               = "미니맵 아래 좌표 텍스트 글꼴."
L["Coordinates font size"]                                          = "좌표 글자 크기"
L["Coordinates text color"]                                         = "좌표 텍스트 색상"
L["Color of the coordinates text."]                                 = "좌표 텍스트 색상."
L["Coordinate precision"]                                           = "좌표 정밀도"
L["Number of decimal places shown for X and Y coordinates."]        = "X 및 Y 좌표에 표시할 소수 자릿수."
L["No decimals (e.g. 52, 37)"]                                      = "소수 없음 (예: 52, 37)"
L["1 decimal (e.g. 52.3, 37.1)"]                                    = "소수 1자리 (예: 52.3, 37.1)"
L["2 decimals (e.g. 52.34, 37.12)"]                                 = "소수 2자리 (예: 52.34, 37.12)"
L["Time Text"]                                                      = "시간 텍스트"
L["Time font"]                                                      = "시간 글꼴"
L["Font for the time text below the minimap."]                      = "미니맵 아래 시간 텍스트 글꼴."
L["Time font size"]                                                 = "시간 글자 크기"
L["Time text color"]                                                = "시간 텍스트 색상"
L["Color of the time text."]                                        = "시간 텍스트 색상."
L["Difficulty Text"]                                                = "난이도 텍스트"
L["Difficulty text color (fallback)"]                               = "난이도 텍스트 색상 (기본값)"
L["Default color when no per-difficulty color is set."]             = "난이도별 색상이 설정되지 않았을 때 사용하는 기본 색상."
L["Difficulty font"]                                                = "난이도 글꼴"
L["Font for the instance difficulty text."]                         = "인스턴스 난이도 텍스트 글꼴."
L["Difficulty font size"]                                           = "난이도 글자 크기"
L["Per-Difficulty Colors"]                                          = "난이도별 색상"
L["Mythic color"]                                                   = "신화 색상"
L["Color for Mythic difficulty text."]                              = "신화 난이도 텍스트 색상."
L["Heroic color"]                                                   = "영웅 색상"
L["Color for Heroic difficulty text."]                              = "영웅 난이도 텍스트 색상."
L["Normal color"]                                                   = "일반 색상"
L["Color for Normal difficulty text."]                              = "일반 난이도 텍스트 색상."
L["LFR color"]                                                      = "공격대 찾기 색상"
L["Color for Looking For Raid difficulty text."]                    = "공격대 찾기 난이도 텍스트 색상."
L["Text Elements"]                                                  = "텍스트 요소"
L["Show zone text"]                                                 = "지역 텍스트 표시"
L["Show the zone name below the minimap."]                          = "미니맵 아래에 지역명을 표시합니다."
L["Zone text display mode"]                                         = "지역 텍스트 표시 방식"
L["What to show: zone only, subzone only, or both."]                = "표시할 내용: 지역만, 하위 지역만, 또는 둘 다."
L["Zone only"]                                                      = "지역만"
L["Subzone only"]                                                   = "하위 지역만"
L["Both"]                                                           = "둘 다"
L["Show coordinates"]                                               = "좌표 표시"
L["Show player coordinates below the minimap."]                     = "미니맵 아래에 플레이어 좌표를 표시합니다."
L["Show time"]                                                      = "시간 표시"
L["Show current game time below the minimap."]                      = "미니맵 아래에 현재 게임 시간을 표시합니다."
L["Use local time"]                                                 = "로컬 시간 사용"
L["When on, shows your local system time. When off, shows server time."] = "활성화: 로컬 시스템 시간 표시. 비활성화: 서버 시간 표시."
L["Minimap Buttons"]                                                = "미니맵 버튼"
L["Queue status and mail indicator are always shown when relevant."] = "대기열 상태 및 우편 알림은 해당될 때 항상 표시됩니다."
L["Show tracking button"]                                           = "추적 버튼 표시"
L["Show the minimap tracking button."]                              = "미니맵 추적 버튼을 표시합니다."
L["Tracking button on mouseover only"]                              = "마우스 올릴 때만 추적 버튼 표시"
L["Hide tracking button until you hover over the minimap."]         = "미니맵에 마우스를 올릴 때까지 추적 버튼을 숨깁니다."
L["Show calendar button"]                                           = "달력 버튼 표시"
L["Show the minimap calendar button."]                              = "미니맵 달력 버튼을 표시합니다."
L["Calendar button on mouseover only"]                              = "마우스 올릴 때만 달력 버튼 표시"
L["Hide calendar button until you hover over the minimap."]         = "미니맵에 마우스를 올릴 때까지 달력 버튼을 숨깁니다."
L["Show zoom buttons"]                                              = "줌 버튼 표시"
L["Show the + and - zoom buttons on the minimap."]                  = "미니맵에 줌 + 및 - 버튼을 표시합니다."
L["Zoom buttons on mouseover only"]                                 = "마우스 올릴 때만 줌 버튼 표시"
L["Hide zoom buttons until you hover over the minimap."]            = "미니맵에 마우스를 올릴 때까지 줌 버튼을 숨깁니다."
L["Border"]                                                         = "테두리"
L["Show a border around the minimap."]                              = "미니맵 주위에 테두리를 표시합니다."
L["Border color"]                                                   = "테두리 색상"
L["Color (and opacity) of the minimap border."]                     = "미니맵 테두리의 색상 (및 불투명도)."
L["Border thickness"]                                               = "테두리 두께"
L["Thickness of the minimap border in pixels (1–8)."]               = "미니맵 테두리 두께 (픽셀, 1–8)."
L["Text Positions"]                                                 = "텍스트 위치"
L["Drag text elements to reposition them. Lock to prevent accidental movement."] = "텍스트 요소를 드래그하여 위치를 변경합니다. 잠금으로 실수로 움직이는 것을 방지합니다."
L["Lock zone text position"]                                        = "지역 텍스트 위치 잠금"
L["When on, the zone text cannot be dragged."]                      = "활성화 시 지역 텍스트를 드래그할 수 없습니다."
L["Lock coordinates position"]                                      = "좌표 위치 잠금"
L["When on, the coordinates text cannot be dragged."]               = "활성화 시 좌표 텍스트를 드래그할 수 없습니다."
L["Lock time position"]                                             = "시간 위치 잠금"
L["When on, the time text cannot be dragged."]                      = "활성화 시 시간 텍스트를 드래그할 수 없습니다."
L["Lock difficulty text position"]                                  = "난이도 텍스트 위치 잠금"
L["When on, the difficulty text cannot be dragged."]                = "활성화 시 난이도 텍스트를 드래그할 수 없습니다."
L["Button Positions"]                                               = "버튼 위치"
L["Drag buttons to reposition them. Lock to prevent movement."]     = "버튼을 드래그하여 위치를 변경합니다. 잠금으로 이동을 방지합니다."
L["Lock Zoom In button"]                                            = "줌 인 버튼 잠금"
L["Prevent dragging the + zoom button."]                            = "줌 + 버튼을 드래그할 수 없게 합니다."
L["Lock Zoom Out button"]                                           = "줌 아웃 버튼 잠금"
L["Prevent dragging the - zoom button."]                            = "줌 - 버튼을 드래그할 수 없게 합니다."
L["Lock Tracking button"]                                           = "추적 버튼 잠금"
L["Prevent dragging the tracking button."]                          = "추적 버튼을 드래그할 수 없게 합니다."
L["Lock Calendar button"]                                           = "달력 버튼 잠금"
L["Prevent dragging the calendar button."]                          = "달력 버튼을 드래그할 수 없게 합니다."
L["Lock Queue button"]                                              = "대기열 버튼 잠금"
L["Prevent dragging the queue status button."]                      = "대기열 상태 버튼을 드래그할 수 없게 합니다."
L["Disable queue button handling"]                                  = "대기열 버튼 관리 비활성화"
L["Turn off all queue button anchoring (use if another addon manages it)."] = "모든 대기열 버튼 고정을 끕니다 (다른 애드온이 관리하는 경우 사용)."
L["Button Sizes"]                                                   = "버튼 크기"
L["Adjust the size of minimap overlay buttons."]                    = "미니맵 오버레이 버튼의 크기를 조정합니다."
L["Tracking button size"]                                           = "추적 버튼 크기"
L["Size of the tracking button (pixels)."]                          = "추적 버튼 크기 (픽셀)."
L["Calendar button size"]                                           = "달력 버튼 크기"
L["Size of the calendar button (pixels)."]                          = "달력 버튼 크기 (픽셀)."
L["Queue button size"]                                              = "대기열 버튼 크기"
L["Size of the queue status button (pixels)."]                      = "대기열 상태 버튼 크기 (픽셀)."
L["Zoom button size"]                                               = "줌 버튼 크기"
L["Size of the zoom in / zoom out buttons (pixels)."]               = "줌 인/줌 아웃 버튼 크기 (픽셀)."
L["Mail indicator size"]                                            = "우편 알림 크기"
L["Size of the new mail icon (pixels)."]                            = "새 우편 아이콘 크기 (픽셀)."
L["Addon button size"]                                              = "애드온 버튼 크기"
L["Size of collected addon minimap buttons (pixels)."]              = "수집된 애드온 미니맵 버튼 크기 (픽셀)."
L["Minimap Addon Buttons"]                                          = "미니맵 애드온 버튼"
L["Button Management"]                                              = "버튼 관리"
L["Manage addon minimap buttons"]                                   = "애드온 미니맵 버튼 관리"
L["When on, Vista takes control of addon minimap buttons and groups them by the selected mode."] = "활성화 시 Vista가 애드온 미니맵 버튼을 제어하고 선택한 모드로 그룹화합니다."
L["Button mode"]                                                    = "버튼 모드"
L["How addon buttons are presented: hover bar below minimap, panel on right-click, or floating drawer button."] = "애드온 버튼 표시 방식: 미니맵 아래 호버 바, 우클릭 패널, 또는 플로팅 서랍 버튼."
L["Mouseover bar"]                                                  = "마우스오버 바"
L["Right-click panel"]                                              = "우클릭 패널"
L["Floating drawer"]                                                = "플로팅 서랍"
L["Lock drawer button position"]                                    = "서랍 버튼 위치 잠금"
L["Prevent dragging the floating drawer button."]                   = "플로팅 서랍 버튼을 드래그할 수 없게 합니다."
L["Lock mouseover bar position"]                                    = "마우스오버 바 위치 잠금"
L["Prevent dragging the mouseover button bar."]                     = "마우스오버 버튼 바를 드래그할 수 없게 합니다."
L["Lock right-click panel position"]                                = "우클릭 패널 위치 잠금"
L["Prevent dragging the right-click panel."]                        = "우클릭 패널을 드래그할 수 없게 합니다."
L["Buttons per row/column"]                                         = "행/열당 버튼 수"
L["Controls how many buttons appear before wrapping. For left/right direction this is columns; for up/down it is rows."] = "줄 바꿈 전 버튼 수를 제어합니다. 좌/우 방향은 열, 상/하 방향은 행입니다."
L["Expand direction"]                                               = "확장 방향"
L["Direction buttons fill from the anchor point. Left/Right = horizontal rows. Up/Down = vertical columns."] = "앵커 포인트에서 버튼이 채워지는 방향. 좌/우 = 가로 행. 상/하 = 세로 열."
L["Right"]                                                          = "오른쪽"
L["Left"]                                                           = "왼쪽"
L["Down"]                                                           = "아래"
L["Up"]                                                             = "위"
L["Panel Appearance"]                                               = "패널 외형"
L["Colors for the drawer and right-click button panels."]           = "서랍 및 우클릭 버튼 패널 색상."
L["Panel background color"]                                         = "패널 배경 색상"
L["Background color of the addon button panels."]                   = "애드온 버튼 패널의 배경 색상."
L["Panel border color"]                                             = "패널 테두리 색상"
L["Border color of the addon button panels."]                       = "애드온 버튼 패널의 테두리 색상."
L["Managed buttons"]                                                = "관리 중인 버튼"
L["When off, this button is completely ignored by this addon."]     = "비활성화 시 이 버튼은 애드온에서 완전히 무시됩니다."
L["(No addon buttons detected yet)"]                                = "(아직 감지된 애드온 버튼 없음)"
L["Visible buttons (check to include)"]                             = "표시 버튼 (포함하려면 체크)"
L["(No addon buttons detected yet — open your minimap first)"]      = "(아직 감지된 애드온 버튼 없음 — 미니맵을 먼저 여세요)"
