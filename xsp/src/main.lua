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
ret, userUI = showUI("ui.json")


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
local g_s_chapterMap = {point(38,65,0xeef6fe), point(1216,18,0xd4c3a1)} -- bigmap
local g_s_exploreMap = {point(1146,22,0xd5c4a2), point(1209,21,0xd5c4a2), point(978,29,0x341c0b)} -- explore map
local g_s_ensure = {point(837,404,0xf4b25f), point(632,365,0xccb49b), point(440,405,0xf4b25f)}
local g_s_battleReady = {point(27,41,0xeef6fe), point(27,43,0xedf5fd), point(33,48,0xeef6fe)}
local g_s_battleStart = {point(43,33,0xd5c4a2), point(107,51,0xd5c4a2), point(172,48,0xd5c4a2)}
local g_s_mainTown = {point(771,37,0xf6562e), point(1167,31,0xd5c4a2), point(808,30,0x381f0f)}
local g_s_teamPanel = {point(855,582,0xf4b25f), point(1062,582,0xf4b25f)}
local g_s_teamCanBuild = {point(811,597,0xf4b25f), point(1032,619,0xf4b25f)}
local g_s_teamJoinedPanel = {point(333,582,0xdd6951), point(442,587,0xc6bdb5)}
local g_s_teamInvited = {point(531,410,0xdd6951), point(756,411,0xf4b25f), point(638,402,0xccb49b)}
local g_s_teamCanStart = {point(1092,264,0xcec6bd), point(978,588,0xf4b25f)}
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
local g_explorePos = {650,135}
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
local g_teamBuildRealButton = {876,561}

local g_teamMethod = userUI.team_method + 1
local g_teamHost = userUI.team_host + 1
local g_teamWinContinue = userUI.team_win_continue + 1
local g_teamLoseContinue = userUI.team_lose_continue + 1

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
      if isSceneFuzzy(scene) then
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
  sysLog(string.format("wait repeat %s sec", counter))
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


-- monType: 1 exp怪，2全部但是不包含boss 3全部
local function find_mon3(monType, ms)
  sysLog(string.format("find_mon: type:%s", monType))
  local expx, expy
  --keepScreen(true)
  local points 
  if monType == 1 then
    
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
  if g_s_battleReady == wait_appear(g_s_battleReady, g_s_battleStart) then
    sysLog("press ready")
    tap(unpack(g_p_ready))
  end
  local resultScene = wait_appear(g_s_win, g_s_lose)
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
  
  -- 训练狗粮
  local function dog_trainning()
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
			mSleep(2000)
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
  
  -- 刷御魂
  local function soul_hunting()
    local soulButton = {269,511}
    local soulFloorStartY = 152
    local soulFloorEndY = 517
    local soulFloorX = 520
    local soulFBHeight = 60
    local soulFBEdge = 8
    local s_soulPanel = {point(551,179,0xccb49b), point(534,254,0xccb49b)}	
    local soulFloor = userUI.soul_floor + 1
    local soulFloorButton 
    local resultS
    local nextS
    local winCount = 0
    local loseCount = 0
    local isLastWin = false 
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
    while true do 
      tapScroll()
      mSleep(1000)
      tap(unpack(g_teamButton))
      mSleep(1000)
      tap(unpack(soulButton))
      wait_appear(s_soulPanel)
      select_soul_floor()
      mSleep(1000)
      if g_teamHost == 2 then 
        local x; local y
        -- 一直尝试加入组队
        while true do
          x, y = find_join_button()
          if x ~= -1 and y~= -1 then 
            sysLog(string.format("house button x:%d, y:%d", x, y))
            tap(x, y)
            tap(x, y)
          end
          mSleep(1000)
          local nextScene = wait_appear(g_s_teamJoinedPanel, g_s_teamPanel, g_s_battleReady)
          if nextScene ~= g_s_teamPanel then 
            sysLog("join scene")
            break 
          end
          tap(unpack(g_teamRefreshButton))
          mSleep(500)
        end
        -- 进入战斗-> 结果 -> 接受下次组队邀请或拒绝 -> 进入战斗 循环
        while true do
          resultS, nextS = battle_scene({g_s_mainTown, g_s_teamInvited})
          if resultS == g_s_win then 
            winCount = winCount + 1
            isLastWin = true
          else
            loseCount = loseCount + 1
            isLastWin = false
          end
          sysLog(string.format("soul win count %d, lose %d", winCount, loseCount))
          if nextS == g_s_teamInvited then 
            sysLog("soul invited after")
            if (isLastWin and g_teamWinContinue == 1) or (not isLastWin and g_teamLoseContinue == 1) then 
              tap(unpack(g_teamAcceptButton))
              mSleep(2000)
              if isSceneFuzzy(g_s_mainTown) then break end
            else 
              tap(unpack(g_teamRefuseButton))
              break 
            end
          else
            sysLog("not invite scene")
            break 
          end 
        end
      else
        wait_appear(g_s_teamCanBuild)
        sysLog("can build")
        tap(unpack(g_teamBuildButton))
        mSleep(1000)
        tap(unpack(g_teamBuildRealButton))
        while true do 
          wait_appear(g_s_teamCanStart)
          tap(unpack(g_teamStartButton))
          resultS = battle_scene({g_s_teamInvited})
          if resultS == g_s_win then 
            winCount = winCount + 1
            isLastWin = true
          else
            loseCount = loseCount + 1
            isLastWin = false
          end 
          sysLog(string.format("soul win count %d, lose %d", winCount, loseCount))
          if (isLastWin and g_teamWinContinue == 1) or (not isLastWin and g_teamLoseContinue == 1) then 
            tap(unpack(g_teamAcceptButton))
          else 
            tap(unpack(g_teamRefuseButton))
            wait_appear(g_s_mainTown)
            --            tap(g_backButton)
            --            mSleep(1000)
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
    local p_sendButton = {472,688}
    local p_enterSpace = {138,681}
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
	
  local METHOD = {dog_trainning, soul_hunting, chat_ad}
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
  
  
  --init("com.netease.onmyoji", 1)
  --setScreenScale(720, 1280)
  
  
  