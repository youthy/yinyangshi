local bb = require("badboy")
bb.loadutilslib()
local json = bb.getJSON()
local uiContent = json.decode(getUIContent("ui.json"))
local APP_NAME = "com.netease.onmyoji"
-- ui获取
local mainPage = uiContent.views[1]
local dogPage = uiContent.views[2]
local mainMethod = tonumber(mainPage.views[1].select) + 1
local ret
local userUI
--local textDict = createOcrDict("dict.txt")
ret, userUI = showUI("ui.json")
local xuanshang_act = userUI.xuanshang + 1


-- ###############辅助函数#########################
-- return point struct
-- (10, 20) -> {x = 10, y = 20}
-- (10, 20, 0xffffff) -> {x = 10, y = 20, color = 0xffffff}
local function point(x, y, ...)
  local tmp = {}
  tmp.x = x; tmp.y = y
  if #arg ~= 0 then tmp.color = arg[1] end
  return tmp
end
-- setting
local g_s_win = {point(512,204,0xa21b11), point(812,153,0xf4edce), point(578,270,0x909ba4)} -- win scene
local g_s_lose = {point(512,204,0x5e5468), point(726,168,0xbfb9ab), point(486,192,0x595063)} -- lose scene
local g_s_win2 = {point(407,203,0xd2c4ae), point(453,222,0xb71e12), point(485,221,0xd5c7b1)}
local g_s_team_win = {point(420,160,0xd4c6b0), point(453,164,0xb01c11), point(483,165,0xd2c4ae)}
local g_s_lose2 = {point(381,473,0xfbfbfb), point(831,504,0x221a2a), point(649,469,0xc93434)} 
local g_s_team_lose2 = {point(404,195,0xc0ad94), point(448,189,0x5c5366), point(476,210,0xc1ae94)}
local g_s_winGiftOpen = {point(675,518,0xba441a), point(605,452,0xe2d63c), point(749,513,0xd19118)}
local g_s_chapterMap = {point(38,65,0xeef6fe), point(1216,18,0xd4c3a1), point(1031,630,0x24171f)} -- bigmap
local g_s_exploreMap = {point(1146,22,0xd5c4a2), point(1209,21,0xd5c4a2), point(978,29,0x341c0b)} -- explore map
local g_s_ensure = {point(837,404,0xf4b25f), point(632,365,0xccb49b), point(440,405,0xf4b25f)}
local g_s_battleReady = {point(27,41,0xd5c4a2), point(1091,636,0x200d10), point(1086,621,0x87160a)}
local g_s_dogBattleReady = {point(27,41,0xd5c4a2), point(1091,636,0x200d10), point(1086,621,0x87160a), point(20,658,0x4f475f)}
local g_s_dogBattleStart = {point(140,684,0x826a54), point(57,661,0x7c6c48), point(26,661,0x8a755a)} 
local g_s_teamReady = {point(27,41,0xd5c4a2), point(592,24,0x100808), point(639,45,0xfff2d0)}
local g_s_battleStart = {point(43,33,0xd5c4a2), point(107,51,0xd5c4a2), point(172,48,0xd5c4a2)}
local g_s_mainTown = {point(771,37,0xf6562e), point(1167,31,0xd5c4a2), point(808,30,0x381f0f)}
local g_s_teamPanel = {point(855,582,0xf4b25f), point(1062,582,0xf4b25f)}
local g_s_teamCanBuild = {point(812,626,0xf4b25f), point(1060,648,0xf4b25f)}
local g_s_teamJoinedPanel = {point(333,582,0xdd6951), point(442,587,0xc6bdb5)}
local g_s_teamInvite = {point(531,410,0xdd6951), point(756,411,0xf4b25f), point(638,402,0xccb49b)}
local g_s_teamCanStart3 = {point(1092,264,0xcec6bd), point(978,588,0xf4b25f)}
local g_s_teamCanStart2 = {point(762,264,0xcec6bd), point(978,588,0xf4b25f)}
local g_s_invited = {point(131,235,0xb8a896), point(130,255,0x59b461), point(43,253,0xdb705f)}
local g_s_in_team_doging = {point(52,458,0x423120), point(43,479,0xf9f9f0), point(1145,22,0xd5c4a2)}
local g_s_xuanshang = {point(560,144,0xb39279), point(852,514,0xdc7161), point(850,420,0x53ae5b)}
local g_s_round_change = {point(659,361,0x272420), point(685,366,0x272420), point(622,238,0x0161be)}
local g_huntsoul_right_pos = {946,195}
local g_huntsoul_mid_pos = {628,161}
local g_huntsoul_left_pos = {334,202}
local bt_xuanshang_agree = {850,420}
local bt_xuanshang_refuse = {852,514}
local g_battle_boss_pos = {853,115}
local g_battle_little_pos = {965,271}
local g_battle_mid_pos = {784,259}
local g_invited_agree = {130, 255}
local g_invited_decline = {43, 253}
local g_exploreCenter = {640, 325}
local g_chapterStartY = 144
local g_chapterEndY = 643
local g_chapterHeight = 116
local g_chapterEdge = 2
local g_chapterX = 1180
local g_backButton = {50, 65}
local g_okButton = {775,400}
local g_cancelButton = {500, 400}
local g_shopButton = {530,640}
local g_shopVigorPos = {280,290}
local g_shopOkButton = {645,465}
local g_shopClosePos = {1190,130}
local g_explorePos = {550, 183}
local g_mailButton = {1167,36}
local g_mailOkButton = {843,613}
local g_mailClosePos = {1178,75}
local g_teamButton = {255,642}
local g_teamBuildButton = {1032,619}
local g_teamRefreshButton = {853,599}
local g_teamStartButton = {978,588}
local g_p_ready = {1165, 550} --  ready button pos
local g_teamRefuseButton = {525,428}
local g_teamAcceptButton = {753,428}
local g_teamBuildRealButton = {876,591}
local g_endbattleButton = {1260,50}
local g_yaoqiFontArea = {x1=530, y1=178, x2=647, y2=213}

local g_teamMethod = userUI.team_method + 1
local g_teamHost = userUI.team_host + 1
local g_teamWinContinue = userUI.team_win_continue + 1
local g_teamLoseContinue = userUI.team_lose_continue + 1
local g_teamMember = userUI.team_member + 2

-- 查找view
local function findView(views, key, val) 
  local view
  for _, v in ipairs(views) do
    if v[key] == val then
      view = v
      break
    end
  end
  return view
end

-- swip function version 2, the 1 is in badboy utils
local function swip2(x, y, x2, y2)
  touchDown(1, x, y)
  mSleep(1000)
  touchMove(1, x2, y2)
  mSleep(200)
  touchUp(1, x2, y2)
end

-- show hudId
local function show_message(str)
  
  local hudId = createHUD()
  showHUD(hudId, str, 12, "0xff000000", "0xffffffff", 1, 0, 200, 228, 32)
  mSleep(2000)
  hideHUD(hudId)
end
-- isScene({{x=100, y=100, color=0xffffff}, {x=200,y=200,color=0x0d0d0d}, ...}) -> true|false
-- 精确匹配场景
local function isSceneExactly(tab)
  for _, v in ipairs(tab) do
    local tmp = getColor(v.x, v.y)
    sysLog(string.format("scene v.x:%d, v.y:%d, v.color:%s, get:%s", v.x, v.y, v.color, tmp))
    if v.color ~= tmp then
      return false 
    end
  end
  return true
end
-- 模糊匹配场景
local function isSceneFuzzy(tab)
  for _, v in ipairs(tab) do
    x, y = findColorInRegionFuzzy(v.color, 95, v.x, v.y, v.x, v.y)
    if x == -1 or y == -1 then 
      return false 
    end
  end
  sysLog("fuzzy scene true")
  return true
end 


-- wait_appear(scence1, scence2, ...) -> nil
-- scene :: {point1, point2, ...}
-- point :: {x=100, y=100, color=0xffffff}...
local function wait_appear(...)
  local counter = 1
  local find = false
  while not find do
    for _, scene in ipairs(arg) do
      local status, result = pcall(isSceneFuzzy, scene)
      if status and result then
        find = true
        return scene
      end
    end
    mSleep(1000)
    sysLog(string.format("wait repeat %s sec", counter))
    counter = counter + 1
  end
end

local function do_until_appear(fun, ...)
local counter = 1
local find = false
while not find do
  fun()
  for _, scene in ipairs(arg) do
    if isSceneFuzzy(scene) then
      find = true
      return scene
    end
  end
  mSleep(1000)
  sysLog(string.format("do wait repeat %s sec", counter))
  counter = counter + 1
end
end

local function isVigorEnough() 
  x, y = findColorInRegionFuzzy(0xf8f3e0, 95, 961,15,994,44); 
  if x ~= -1 and y ~= -1 then  
    return true 
  end
  sysLog("vigor is not enough")
  return false
end

-- 打开卷轴
local function tapScroll()
  x, y = findColorInRegionFuzzy(0xdacac2, 98, 1203,610,1217,624)
  if x~= -1 and y ~= -1 then 
    tap(x, y)
  end
end

-- 收取邮件
local function pickMail()
  tap(unpack(g_mailButton))
  mSleep(1000)
  tap(351,175)
  mSleep(500)
  tap(unpack(g_mailOkButton))
  mSleep(1000)
  tap(unpack(g_mailClosePos))
  tap(unpack(g_mailClosePos))
end

local function buyVigor()
  tapScroll()
  mSleep(500)
  tap(unpack(g_shopButton))
  mSleep(1000)
  tap(unpack(g_shopVigorPos))
  mSleep(500)
  tap(unpack(g_shopOkButton))
  mSleep(500)
  tap(unpack(g_shopClosePos))
end


-- 选择章节
local function choose_chapter(chapter, chapterMax)
  local swipCount = 0
  local touchPoint = {x = 1180, y = 3*(g_chapterHeight + g_chapterEdge) + g_chapterStartY + 0.5*g_chapterHeight}
  -- find first chapter
  for i=1, 4 do
    touchDown(1, touchPoint.x, g_chapterEndY - 3*(g_chapterHeight + g_chapterEdge) - 0.5*g_chapterHeight)
    mSleep(50)
    touchMove(1, touchPoint.x, g_chapterEndY + 0.5*g_chapterHeight + g_chapterEdge)
    mSleep(50)
    touchUp(1, touchPoint.x, g_chapterEndY + 0.5*g_chapterHeight + g_chapterEdge)
    --swip(1180, 180, 1180, 640)
  end
  mSleep(1000)
  sysLog(chapter)	local pages = math.ceil(chapter/4)
  sysLog(pages)
  local remainder = chapter - (pages - 1)*4
  sysLog(remainder)
  while swipCount < pages - 1 do
    local targetY = touchPoint.y - 4*(g_chapterHeight+g_chapterEdge)
    touchDown(1, touchPoint.x, touchPoint.y)
    mSleep(50)
    touchMove(1, touchPoint.x, targetY)
    mSleep(50)
    touchUp(1, touchPoint.x, targetY)
    swipCount = swipCount + 1
  end 
  if pages ~= math.ceil(chapterMax/4) then 
    tap(touchPoint.x, (remainder - 1)*(g_chapterHeight + g_chapterEdge) + g_chapterHeight*0.5 + g_chapterStartY)
  else
    mSleep(1000)
    tap(touchPoint.x, g_chapterEndY - (chapterMax - chapter)*(g_chapterHeight + g_chapterEdge) - g_chapterHeight*0.5)
  end 
end

-- return mon table 
local function find_normal_mon()
  return findMultiColorInRegionFuzzyExt2(0xd9d9f5, {{x=0, y=51, color=0xf8f3e0},{x=-31,y=55,color=0x0d0d0d}}, 99, 0, 100, 1280, 600)
end
-- return boss x, y
local function find_boss()
  return findMultiColorInRegionFuzzy2(0xfa0c0c, {{x=0, y=51, color=0xf8f3e0},{x=-31,y=55,color=0x0d0d0d}}, 95, 0, 100, 1280, 600)
end


-- monType: 1 exp怪，2全部但是不包含boss 3全部,4exp+boss
local function find_mon3(monType, ms)
  sysLog(string.format("find_mon: type:%s", monType))
  local expx, expy
  --keepScreen(true)
  local points 
  if monType == 1 or monType == 4 then
    
    for i=1,4 do 
      --keepScreen(true)
      sysLog(i)
      points = find_normal_mon()
      if #points == 0 then break end
      for _, p in ipairs(points) do
        sysLog(string.format("mon3 point.x:%d, point.y:%d", p.x, p.y))
        expx, expy = findMultiColorInRegionFuzzy2(0xfbcc04, {{x=0, y=-8, color=0xdecf9c},{x=0, y=-13, color=0x2d1d0c}}, 95, math.max(0, p.x-120), p.y, p.x+120, p.y+180)
        if exps == -1 and expy == -1 then 
          expx, expy = findMultiColorInRegionFuzzy2(0x1e4e6d, {{x=9, y=-1, color=0xad8c6a}}, 99, math.max(0, p.x-120), p.y, p.x+120, p.y+180)
        end
        if expx ~= -1 and expy ~= -1 then 
          sysLog(string.format("exp find point.x:%d, point.y:%d", expx, expy))
          --  keepScreen(false)
          return p.x, p.y
        end
      end
      mSleep(ms)
    end 
    --keepScreen(false)
    if monType == 4 then return find_boss() end 
    return -1,-1
  elseif monType == 2 then
    points = find_normal_mon()
    if #points ~= 0 then 
      --keepScreen(false)
      sysLog(string.format("find all mon. get x:%d, y:%d", points[1].x, points[1].y))
      return points[1].x, points[1].y 
    end
  elseif monType == 3 then
    points = find_normal_mon()
    if #points ~= 0 then 
      -- keepScreen(false)
      sysLog(string.format("find all mon and boss . get x:%d, y:%d", points[1].x, points[1].y))
      return points[1].x, points[1].y 
    else 
      --keepScreen(false)
      sysLog(string.format("find all mon and boss"))
      return find_boss()
    end
  end
  -- keepScreen(false)
  return -1, -1
end

-- enter battle scene 
local function battle_scene(nextScene)
  sysLog("enter battle")
  -- if not ready press ready
  if wait_appear(g_s_battleReady, g_s_teamReady) ~= nil then
    sysLog("press ready")
    tap(unpack(g_p_ready))
  end
  local resultScene = wait_appear(g_s_win2, g_s_lose2, g_s_team_win, g_s_team_lose2)
  local f = function() tap(890, 110) end
  nextScene = do_until_appear(f, unpack(nextScene))
    -- keep tap until back to chapter map
    --      while not isSceneFuzzy(g_s_chapterMap) do
    --        tap(890, 110)
    --        mSleep(500)
    --      end
    --	tap(640, 360)
    --	mSleep(500)
    --	tap(640, 360)
    --	mSleep(500)
    --	tap(640, 360)
    --	mSleep(1000)
    return resultScene, nextScene
  end
  
  local function in_soul_hunting(pos)
    --local round = 0
    local win 
    while true do 
      if isSceneFuzzy(g_s_dogBattleStart) then
        toast("in battle")
				if pos then 
        while true do 
          if not isSceneFuzzy(g_s_dogBattleStart) then
						toast("battle end")
            break
          else
            tap(unpack(pos))
          end
          mSleep(1000)
        end
				end
      elseif isSceneFuzzy(g_s_teamReady) then
        toast("press team ready")
        tap(unpack(g_p_ready))
      elseif isSceneFuzzy(g_s_battleReady) then
        toast("press battle ready")
        tap(unpack(g_p_ready))
      elseif isSceneFuzzy(g_s_team_win) then
        toast("battle_end")
        win = true
        tap(unpack(g_endbattleButton))
        mSleep(1000)
        tap(unpack(g_endbattleButton))	
      elseif isSceneFuzzy(g_s_team_lose2) then 
        tap(unpack(g_endbattleButton))
        mSleep(1000)
        tap(unpack(g_endbattleButton))
        win = false
      elseif isSceneFuzzy(g_s_winGiftOpen) then
        toast("win")
        tap(unpack(g_endbattleButton))
      elseif isSceneFuzzy(g_s_teamInvite) then
        break    
			elseif isSceneFuzzy(g_s_mainTown) then
				break
      end
      mSleep(300)
    end
    return win
  end
  
  local function battle_scene_dog_team()
    local pos
    local touchPos = userUI.battle_select_pos + 1
    if touchPos == 1 then
      pos = g_battle_little_pos
    elseif touchPos == 2 then
      pos = g_battle_mid_pos
    elseif touchPos == 3 then 
      pos = g_battle_boss_pos
    else 
      pos = g_endbattleButton 
    end
    if wait_appear(g_s_dogBattleReady) ~= nil then
      sysLog("dog press ready")
      tap(unpack(g_p_ready))
    end
    wait_appear(g_s_dogBattleStart)
    sysLog("dog battle start")
    local f = function() tap(unpack(pos)) end
    nextScene = do_until_appear(f, g_s_in_team_doging, g_s_dogBattleReady, g_s_chapterMap)
      -- keep tap until back to chapter map
      --      while not isSceneFuzzy(g_s_chapterMap) do
      --        tap(890, 110)
      --        mSleep(500)
      --      end
      --	tap(640, 360)
      --	mSleep(500)
      --	tap(640, 360)
      --	mSleep(500)
      --	tap(640, 360)
      --	mSleep(1000)
      return nextScene
    end
    
    local function dog_trainning_solo()
      local p_normalMode = {335,230}
      local p_hardMode = {475, 200}
      local p_enter = {955, 530}
      local p_enterScene1 = point(450, 310, 0xc8af96)
      local p_enterScene2 = point(990,525, 0xf4b25f)
      local p_mapInside1 = point(38,65,0xeef6fe)
      local p_mapInside2 = point(1216,18,0xd4c3a1)
      local chapter = userUI.dog_chapter + 1
      local mode = userUI.dog_chapter_mode + 1
      local monType = userUI.dog_mon_type + 1
      local refreshFailed = userUI.dog_giveup + 1
      local endCondition = userUI.dog_end_cond + 1
      local winCountEnd = userUI.dog_end_mon_count + 0
      local buyVigorTimesMax = userUI.dog_end_vigor_times + 0
      local needEndGame = userUI.dog_end_game + 1
      local chapterMax = userUI.dog_chapter_max + 0
      local walkStepMax = userUI.dog_chapter_map_size + 1
      local checkInterval = (userUI.dog_check_interval + 1)*100
      local walkStep = 0
      local winCount = 0
      local needRefresh = false
      local needChooseChapter = true
      local loseCount = 0
      local vigorAlreadyBuy = 0
      local needBuyVigor = false 
      local buyVigorTimes = 0
      local function end_condition() 
        if endCondition == 1 then
          return winCount < winCountEnd
        elseif endCondition == 2 then
          if needBuyVigor then 
            return buyVigorTimes < buyVigorTimesMax
          else 
            return true 
          end
        else
          return true
        end
      end
      local function find_explore_pos()
        return findMultiColorInRegionFuzzy2(0x180e08, {{x=27, y=131, color=0xa8a098},{x=-5,y=19,color=0x26180b},{color=0xdb9aeb,x=-56,y=33}}, 95, 400, 100, 1280, 360)
      end
      sysLog(string.format("chapter:%d,mode:%d,mon_type:%d,refresh:%d,end_mon_count:%d,end_mon_vigor_times:%d",
      chapter, mode, monType, refreshFailed, winCountEnd, buyVigorTimes))
      mSleep(1000)
      tap(unpack(g_explorePos))
      --tap(find_explore_pos())
      wait_appear(g_s_exploreMap)
      
      while end_condition() do
        --  if needChooseChapter then 
        -- 进入过地图后再出来，屏幕中间就是要选择的章节
        mSleep(2000)
        choose_chapter(chapter, chapterMax)
        --		needChooseChapter = false
        --	else 
        --		tap(unpack(g_exploreCenter))
        --	end 
        -- wait until chapter enter scence appear
        wait_appear({p_enterScene1, p_enterScene2})
        if mode == 2 then -- choose hard mode 
          tap(unpack(p_hardMode))
        else 
          tap(unpack(p_normalMode))
        end
        mSleep(200)
        tap(unpack(p_enter)) -- enter map
        mSleep(3000)
        wait_appear(g_s_chapterMap)
        while walkStep < walkStepMax do
          if not isVigorEnough() then 
            -- check vigor
            needBuyVigor = true 
            break 
          end
          if walkStep > 0 then 
            tap(1250, 650)
            mSleep(3000)
            tap(1250, 650)
            mSleep(3000)
          end
          repeat
            x, y = find_mon3(monType, checkInterval)
            sysLog(string.format("########find mon ##### x:%d, y:%d", x, y))
            if x ~= -1 and y ~= -1 then 
              tap(x, y) 
              if battle_scene({g_s_chapterMap}) == g_s_win then 
                winCount = winCount + 1
              else
                loseCount = loseCount + 1
                if refreshFailed == 1 then 
                  needRefresh = true
                  break 
                end  -- if fail quit to refresh 
              end
            end
          until x == -1 and y == -1
          if needRefresh then 
            needRefresh = false
            break 
          end
          walkStep = walkStep + 1
        end
        sysLog(string.format("winCount: %d, loseCount: %d", winCount, loseCount))
        tap(unpack(g_backButton))
        mSleep(2000)
        tap(unpack(g_okButton))
        walkStep = 0
        wait_appear(g_s_exploreMap)
        if needBuyVigor then 
          if buyVigorTimes < buyVigorTimesMax then
            -- buy vigor
            tap(unpack(g_backButton))
            mSleep(2000)
            buyVigor()
            buyVigorTimes = buyVigorTimes + 1
            mSleep(1000)
            pickMail()
            mSleep(500)
            tap(unpack(g_explorePos))
            wait_appear(g_s_exploreMap)
            needChooseChapter = true
            needBuyVigor = false
          else
            break
          end
        end
      end
      if needEndGame == 1 then closeApp(APP_NAME) end
    end
    
    local function dog_trainning_team()
      local pos
      local touchPos = userUI.battle_select_pos + 1
      if touchPos == 1 then
        pos = g_battle_little_pos
      elseif touchPos == 2 then
        pos = g_battle_mid_pos
      elseif touchPos == 3 then 
        pos = g_battle_boss_pos
        --	else 
        --	  pos = g_endbattleButton 
      end
      while true do
        if isSceneFuzzy(g_s_invited) then
          toast("invited")
          tap(unpack(g_invited_agree))
        elseif isSceneFuzzy(g_s_xuanshang) then
          if xuanshang_act == 1 then
            tap(unpack(bt_xuanshang_agree))
          else
            tap(unpack(bt_xuanshang_refuse))
          end
        elseif isSceneFuzzy(g_s_chapterMap) then
          toast("chatpermap")
          if not isSceneFuzzy(g_s_in_team_doging) then
            toast("leave")
            tap(unpack(g_backButton))
            mSleep(2000)
            tap(unpack(g_okButton)) 
          end
        elseif isSceneFuzzy(g_s_dogBattleReady) then
          tap(unpack(g_p_ready))
          wait_appear(g_s_dogBattleStart)
          toast("battle_start")
          if pos then 
            --mSleep(500)
            tap(unpack(pos))
          end 
        elseif isSceneFuzzy(g_s_win2) or isSceneFuzzy(g_s_lose2) then
          toast("battle_end")
          tap(unpack(g_endbattleButton))
          --toast("one")
          mSleep(1000)
          tap(unpack(g_endbattleButton))
          --toast("two")
        elseif isSceneFuzzy(g_s_winGiftOpen) then
          toast("win")
          tap(unpack(g_endbattleButton))
        end
        mSleep(500)
      end
    end
    
    -- 训练狗粮
    local function dog_trainning()
      sysLog("dog training")
      local trainingType = userUI.dog_training_type + 1
      sysLog(trainingType)
      if trainingType == 1 then
        dog_trainning_solo()
      elseif trainingType == 2 then
        
        dog_trainning_team()
      end
    end
    
    
    -- 刷御魂
    local function soul_hunting()
      local soulButton = {269,511}
      local soulFloorStartY = 160
      local soulFloorEndY = 580
      local soulFloorX = 520
      local soulFBHeight = 60
      local soulFBEdge = 6
      local s_soulPanel = {point(510,187,0xffd07b), point(501,265,0x0f0f0f)}	
      local soulFloor = userUI.soul_floor + 1
      local soulFloorButton 
      local resultS
      local nextS
      local winCount = 0
      local loseCount = 0
      local isLastWin = false 
      local mon_pos = userUI.round_mon_pos + 1
      if mon_pos == 1 then
        mon_pos = g_huntsoul_left_pos
      elseif mon_pos == 2 then 
        mon_pos = g_huntsoul_mid_pos
      elseif mon_pos == 3 then
        mon_pos = g_huntsoul_right_pos
      else
        mon_pos = nil
      end
      local select_soul_floor = function()
        if soulFloor < 6 then 
          soulFloorButton = {soulFloorX, soulFloor*(soulFBHeight + soulFBEdge) + soulFloorStartY + 0.4*soulFBHeight}
          tap(unpack(soulFloorButton))
        else
          swip(524,518, 537,112)
          mSleep(300)
          soulFloorButton = {soulFloorX, soulFloorEndY - (10 - soulFloor)*(soulFBHeight + soulFBEdge) - 0.4*soulFBHeight}
          tap(unpack(soulFloorButton))
        end
      end
      local find_join_button = function()
        return findColorInRegionFuzzy(0x282520, 100, 994,168,1075,548); 
      end 
      sysLog(string.format("soulfloor %d", soulFloor))
			--sysLog("teamhost" .. team_host)
      if g_teamHost == 2 then
				while true do
					if isSceneFuzzy(g_s_invited) then
						toast("invited")
						tap(unpack(g_invited_agree))
					elseif isSceneFuzzy(g_s_teamReady) then
						toast("press team ready")
						tap(unpack(g_p_ready))
						in_soul_hunting(mon_pos)
					elseif isSceneFuzzy(g_s_battleReady) then
						toast("press battle ready")
						tap(unpack(g_p_ready))
						in_soul_hunting(mon_pos)
					elseif isSceneFuzzy(g_s_xuanshang) then
						toast("xuanshang")
						if xuanshang_act == 1 then
							tap(unpack(bt_xuanshang_agree))
						else
							tap(unpack(bt_xuanshang_refuse))
						end
					end
					mSleep(1000)
        end
      else
        while true do 
          tapScroll()
          mSleep(1000)
          tap(unpack(g_teamButton))
          mSleep(1000)
          tap(unpack(soulButton))
          wait_appear(s_soulPanel)
          select_soul_floor()
          mSleep(2000)
          --wait_appear(g_s_teamCanBuild)
          sysLog("can build")
          tap(unpack(g_teamBuildButton))
          mSleep(1000)
          tap(unpack(g_teamBuildRealButton))
          while true do 
            if g_teamMember == 3 then
              wait_appear(g_s_teamCanStart3)
            else
              wait_appear(g_s_teamCanStart2)
            end
            tap(unpack(g_teamStartButton))
            --            resultS = battle_scene({g_s_teamInvite})
            --            if resultS == g_s_win then 
            --              winCount = winCount + 1
            --              isLastWin = true
            --            else
            --              loseCount = loseCount + 1
            --              isLastWin = false
            --            end 
            --            sysLog(string.format("soul win count %d, lose %d", winCount, loseCount))
            isLastWin = in_soul_hunting(mon_pos)
            if (isLastWin and g_teamWinContinue == 1) or (not isLastWin and g_teamLoseContinue == 1) then 
              tap(unpack(g_teamAcceptButton))
            else 
              tap(unpack(g_teamRefuseButton))
              wait_appear(g_s_mainTown)
              --            tap(g_backButton)
              --            mSleep(1000)
              mSleep(2000)
              break 
            end
          end 
        end
      end
    end
    
    -- 刷屏
    local function chat_ad()
      math.randomseed(os.time())
      local chatChannel = userUI.chat_channel + 1
      local chatCd = userUI.chat_cd
      local chatContent = userUI.chat_content
      local p_chatButton = {1237,38}
      local p_worldButton = {36,202}
      local p_guildButton = {39,324}
      local p_nearButton = {39,449}
      local p_sendButton = {540,678}
      local p_enterSpace = {224,667}
      local p_ensureContent = {1106,77}
      local p_channelList = {p_worldButton, p_guildButton, p_nearButton}
      tap(unpack(p_chatButton))
      mSleep(2000)
      tap(unpack(p_channelList[chatChannel]))
      mSleep(1000)
      while true do
        tap(unpack(p_enterSpace))
        mSleep(1000)
        inputText("#CLEAR#")
        inputText(chatContent .. math.random(100))
        tap(unpack(p_ensureContent))
        sysLog("haha")
        mSleep(100)
        tap(unpack(p_sendButton))
        sysLog("send")
        mSleep(chatCd * 1000)
      end
    end
    
    local function orcFind()
      local line= {}
      line[1]= '02002000180100000100733BFE67488931224448F11F00600C018$海$0.0.104$20'
      line[2]= '020040F7FDF0420800002004008C0DC7ECCC11023842180300200$坊$1.0.88$18'
      line[3]= '0200401803002305B0B2610C2184300$主$3.5.68$18'
      --line[4]= '0200000000000010461912C00008010020040FC0F0000000000000000000000000001FF518821000000000000400FC1F222000108218400801000000000000000000000000100210421863FC7F08210C21840$海坊主$1.4.169$19'
      --line[5]= '01007F198100000000010E010000000000000041001000000000000000000000007007E400010060B01C600C0A810801402801007FF8$椒图$2.0.104$18'
      --line[6]= '080020000011E0100000000003FC000003F00000000000000000000000000000400300000789018000000000002000001C0000000000000000000000000000001002004008300000000003004000901393C048080100200400000000000000008010020040000000000010020000809C9F0240400801002004$跳跳哥哥$2.0.176$20'
      local textDict = createOcrDict(line)
      result = ocrText(textDict,g_yaoqiFontArea.x1,g_yaoqiFontArea.y1,g_yaoqiFontArea.x2, g_yaoqiFontArea.y2,{"0x636057-0x242525"}, 90, 0, 0)
      sysLog(result)
      --for k,v in pairs(results) do
      --	sysLog(string.format('{x=%d, y=%d, text=%s}', v.x, v.y, v.text))
      --end
    end
    
    local function wait_join()
      while true do
        if isSceneFuzzy(g_s_invited) then
          toast("invited")
          tap(unpack(g_invited_agree))
        elseif isSceneFuzzy(g_s_xuanshang) then
          toast("xuanshang")
          if xuanshang_act == 1 then
            tap(unpack(bt_xuanshang_agree))
          else
            tap(unpack(bt_xuanshang_refuse))
          end
        elseif isSceneFuzzy(g_s_teamReady) then
          toast("press team ready")
          tap(unpack(g_p_ready))
        elseif isSceneFuzzy(g_s_battleReady) then
          toast("press battle ready")
          tap(unpack(g_p_ready))
        elseif isSceneFuzzy(g_s_dogBattleReady) then
          toast("press dog ready")
          tap(unpack(g_p_ready))
        elseif isSceneFuzzy(g_s_win2) or isSceneFuzzy(g_s_team_win) or isSceneFuzzy(g_s_lose2) or isSceneFuzzy(g_s_team_lose2) then
          toast("battle_end")
          tap(unpack(g_endbattleButton))
          --toast("one")
          mSleep(1000)
          tap(unpack(g_endbattleButton))
          --toast("two")
        elseif isSceneFuzzy(g_s_winGiftOpen) then
          toast("win")
          tap(unpack(g_endbattleButton))
        end
        mSleep(1000)
      end 
    end
    
    
    
    local METHOD = {dog_trainning, soul_hunting, chat_ad, wait_join}
    --######################## MAIN FUNCTION ###############################
    local function main()
      
      setScreenScale(720, 1280) 
      init(APP_NAME, 1) -- home键在右侧初始化
      if ret == 1 then 
        METHOD[userUI.main_method + 1]()
      end
    end
    --############ ENTERANCE ###########################
    
    main()
    
    
    init("com.netease.onmyoji", 1)
    setScreenScale(720, 1280)
    
    --local p1 = getColor(25,253)
    --local p2 = getColor(36,133)
    --local p3 = getColor(1145,22)
    --toast(tostring(p1))
    --mSleep(1000) --6373404
    -- 6504728
    --toast(tostring(p2))
    --mSleep(1000) -- 10847325  9268554 6373149
    -- 5057290
    -- 6373150
    --toast(tostring(p3))
    --mSleep(1000) 
    --14009506
    --orcFind()
    --	if isSceneFuzzy(g_s_battleReady) then 
    --		sysLog("haha")
    --	elseif isSceneFuzzy(g_s_teamReady) then 
    --		sysLog("heihei")
    --	else
    --		sysLog("fuck")
    --	end
    
    
    