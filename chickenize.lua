-- 
--  This is file `chickenize.lua',
--  generated with the docstrip utility.
-- 
--  The original source files were:
-- 
--  chickenize.dtx  (with options: `lua')
--  
--  EXPERIMENTAL CODE
--  
--  Do not distribute this file without also distributing the
--  source files specified above.
--  
--  Do not distribute a modified version of this file under the same name.
--  

local traverseid = node.traverse_id
local insertbefore = node.insert_before
local insertafter = node.insert_after
local nodenew = node.new

Hhead = node.id("hhead")
RULE = node.id("rule")
GLUE = node.id("glue")
WHAT = node.id("whatsit")
COL = node.subtype("pdf_colorstack")
GLYPH = node.id("glyph")
color_push = nodenew(WHAT,COL)
color_pop = nodenew(WHAT,COL)
color_push.stack = 0
color_pop.stack = 0
color_push.cmd = 1
color_pop.cmd = 2
chicken_pagenumbers = true

chickenstring = {}
chickenstring[1] = "Chicken" -- chickenstring is a table, please remeber this!

chickenizefraction = 0.5
-- set this to a small value to fool somebody, or to see if your text has been read carefully. This is also a great way to lay easter eggs for your own class / package …

local tbl = font.getfont(font.current())
local space = tbl.parameters.space
local shrink = tbl.parameters.space_shrink
local stretch = tbl.parameters.space_stretch
local match = unicode.utf8.match
chickenize_ignore_word = false

chickenize_real_stuff = function(i,head)
    while ((i.next.id == 37) or (i.next.id == 11) or (i.next.id == 7) or (i.next.id == 0)) do  --find end of a word
      i.next = i.next.next
    end

    chicken = {}  -- constructing the node list.

-- Should this be done only once? No, then we loose the freedom to change the string in-document.
--but it could be done only once each paragraph as in-paragraph changes are not possible!

    chickenstring_tmp = chickenstring[math.random(1,#chickenstring)]
    chicken[0] = nodenew(37,1)  -- only a dummy for the loop
    for i = 1,string.len(chickenstring_tmp) do
      chicken[i] = nodenew(37,1)
      chicken[i].font = font.current()
      chicken[i-1].next = chicken[i]
    end

    j = 1
    for s in string.utfvalues(chickenstring_tmp) do
      local char = unicode.utf8.char(s)
      chicken[j].char = s
      if match(char,"%s") then
        chicken[j] = nodenew(10)
        chicken[j].spec = nodenew(47)
        chicken[j].spec.width = space
        chicken[j].spec.shrink = shrink
        chicken[j].spec.stretch = stretch
      end
      j = j+1
    end

    node.slide(chicken[1])
    lang.hyphenate(chicken[1])
    chicken[1] = node.kerning(chicken[1])    -- FIXME: does not work
    chicken[1] = node.ligaturing(chicken[1]) -- dito

    insertbefore(head,i,chicken[1])
    chicken[1].next = chicken[2] -- seems to be necessary … to be fixed
    chicken[string.len(chickenstring_tmp)].next = i.next
  return head
end

chickenize = function(head)
  for i in traverseid(37,head) do  --find start of a word
    if (chickenize_ignore_word == false) then  -- normal case: at the beginning of a word, we jump into chickenization
      head = chickenize_real_stuff(i,head)
    end

-- At the end of the word, the ignoring is reset. New chance for everyone.
    if not((i.next.id == 37) or (i.next.id == 7) or (i.next.id == 22) or (i.next.id == 11)) then
      chickenize_ignore_word = false
    end

-- and the random determination of the chickenization of the next word:
    if math.random() > chickenizefraction then
      chickenize_ignore_word = true
    end
  end
  return head
end

nicetext = function()
  texio.write_nl("Output written on "..tex.jobname..".pdf ("..status.total_pages.." chicken,".." eggs).")
  texio.write_nl(" ")
  texio.write_nl("----------------------------")
  texio.write_nl("Hello my dear user,")
  texio.write_nl("good job, now go outside and enjoy the world!")
  texio.write_nl(" ")
  texio.write_nl("And don't forget to feet your chicken!")
  texio.write_nl("----------------------------")
end
local itsame = function()
local mr = function(a,b) rectangle({a*10,b*-10},10,10) end
color = "1 .6 0"
for i = 6,9 do mr(i,3) end
for i = 3,11 do mr(i,4) end
for i = 3,12 do mr(i,5) end
for i = 4,8 do mr(i,6) end
for i = 4,10 do mr(i,7) end
for i = 1,12 do mr(i,11) end
for i = 1,12 do mr(i,12) end
for i = 1,12 do mr(i,13) end

color = ".3 .5 .2"
for i = 3,5 do mr(i,3) end mr(8,3)
mr(2,4) mr(4,4) mr(8,4)
mr(2,5) mr(4,5) mr(5,5) mr(9,5)
mr(2,6) mr(3,6) for i = 8,11 do mr(i,6) end
for i = 3,8 do mr(i,8) end
for i = 2,11 do mr(i,9) end
for i = 1,12 do mr(i,10) end
mr(3,11) mr(10,11)
for i = 2,4 do mr(i,15) end for i = 9,11 do mr(i,15) end
for i = 1,4 do mr(i,16) end for i = 9,12 do mr(i,16) end

color = "1 0 0"
for i = 4,9 do mr(i,1) end
for i = 3,12 do mr(i,2) end
for i = 8,10 do mr(5,i) end
for i = 5,8 do mr(i,10) end
mr(8,9) mr(4,11) mr(6,11) mr(7,11) mr(9,11)
for i = 4,9 do mr(i,12) end
for i = 3,10 do mr(i,13) end
for i = 3,5 do mr(i,14) end
for i = 7,10 do mr(i,14) end
end
leet_onlytext = false
leettable = {
  [101] = 51, -- E
  [105] = 49, -- I
  [108] = 49, -- L
  [111] = 48, -- O
  [115] = 53, -- S
  [116] = 55, -- T

  [101-32] = 51, -- e
  [105-32] = 49, -- i
  [108-32] = 49, -- l
  [111-32] = 48, -- o
  [115-32] = 53, -- s
  [116-32] = 55, -- t
}
leet = function(head)
  for line in traverseid(Hhead,head) do
    for i in traverseid(GLYPH,line.head) do
      if not(leetspeak_onlytext) or
         node.has_attribute(i,luatexbase.attributes.leetattr)
      then
        if leettable[i.char] then
          i.char = leettable[i.char]
        end
      end
    end
  end
  return head
end
local letterspace_glue = nodenew(node.id"glue")
local letterspace_spec = nodenew(node.id"glue_spec")
local letterspace_pen = nodenew(node.id"penalty")

letterspace_spec.width   = tex.sp"0pt"
letterspace_spec.stretch = tex.sp"2pt"
letterspace_glue.spec    = letterspace_spec
letterspace_pen.penalty  = 10000
letterspaceadjust = function(head)
  for glyph in traverseid(node.id"glyph", head) do
    if glyph.prev and (glyph.prev.id == node.id"glyph") then
      local g = node.copy(letterspace_glue)
      insertbefore(head, glyph, g)
      insertbefore(head, g, node.copy(letterspace_pen))
    end
  end
  return head
end
randomfontslower = 1
randomfontsupper = 0
randomfonts = function(head)
  if (randomfontsupper > 0) then  -- fixme: this should be done only once, no? Or at every paragraph?
    rfub = randomfontsupper  -- user-specified value
  else
    rfub = font.max()        -- or just take all fonts
  end
  for line in traverseid(Hhead,head) do
    for i in traverseid(GLYPH,line.head) do
      if not(randomfonts_onlytext) or node.has_attribute(i,luatexbase.attributes.randfontsattr) then
        i.font = math.random(randomfontslower,rfub)
      end
    end
  end
  return head
end
uclcratio = 0.5 -- ratio between uppercase and lower case
randomuclc = function(head)
  for i in traverseid(37,head) do
    if not(randomuclc_onlytext) or node.has_attribute(i,luatexbase.attributes.randuclcattr) then
      if math.random() < uclcratio then
        i.char = tex.uccode[i.char]
      else
        i.char = tex.lccode[i.char]
      end
    end
  end
  return head
end
randomchars = function(head)
  for line in traverseid(Hhead,head) do
    for i in traverseid(GLYPH,line.head) do
      i.char = math.floor(math.random()*512)
    end
  end
  return head
end
randomcolor_grey = false
randomcolor_onlytext = false --switch between local and global colorization
rainbowcolor = false

grey_lower = 0
grey_upper = 900

Rgb_lower = 1
rGb_lower = 1
rgB_lower = 1
Rgb_upper = 254
rGb_upper = 254
rgB_upper = 254
rainbow_step = 0.005
rainbow_Rgb = 1-rainbow_step -- we start in the red phase
rainbow_rGb = rainbow_step   -- values x must always be 0 < x < 1
rainbow_rgB = rainbow_step
rainind = 1          -- 1:red,2:yellow,3:green,4:blue,5:purple
randomcolorstring = function()
  if randomcolor_grey then
    return (0.001*math.random(grey_lower,grey_upper)).." g"
  elseif rainbowcolor then
    if rainind == 1 then -- red
      rainbow_rGb = rainbow_rGb + rainbow_step
      if rainbow_rGb >= 1-rainbow_step then rainind = 2 end
    elseif rainind == 2 then -- yellow
      rainbow_Rgb = rainbow_Rgb - rainbow_step
      if rainbow_Rgb <= rainbow_step then rainind = 3 end
    elseif rainind == 3 then -- green
      rainbow_rgB = rainbow_rgB + rainbow_step
      rainbow_rGb = rainbow_rGb - rainbow_step
      if rainbow_rGb <= rainbow_step then rainind = 4 end
    elseif rainind == 4 then -- blue
      rainbow_Rgb = rainbow_Rgb + rainbow_step
      if rainbow_Rgb >= 1-rainbow_step then rainind = 5 end
    else -- purple
      rainbow_rgB = rainbow_rgB - rainbow_step
      if rainbow_rgB <= rainbow_step then rainind = 1 end
    end
    return rainbow_Rgb.." "..rainbow_rGb.." "..rainbow_rgB.." rg"
  else
    Rgb = math.random(Rgb_lower,Rgb_upper)/255
    rGb = math.random(rGb_lower,rGb_upper)/255
    rgB = math.random(rgB_lower,rgB_upper)/255
    return Rgb.." "..rGb.." "..rgB.." ".." rg"
  end
end
randomcolor = function(head)
  for line in traverseid(0,head) do
    for i in traverseid(37,line.head) do
      if not(randomcolor_onlytext) or
         (node.has_attribute(i,luatexbase.attributes.randcolorattr))
      then
        color_push.data = randomcolorstring()  -- color or grey string
        line.head = insertbefore(line.head,i,node.copy(color_push))
        insertafter(line.head,i,node.copy(color_pop))
      end
    end
  end
  return head
end
uppercasecolor = function (head)
  for line in traverseid(Hhead,head) do
    for upper in traverseid(GLYPH,line.head) do
      if (((upper.char > 64) and (upper.char < 91)) or
          ((upper.char > 57424) and (upper.char < 57451)))  then  -- for small caps! nice ☺
        color_push.data = randomcolorstring()  -- color or grey string
        line.head = insertbefore(line.head,upper,node.copy(color_push))
        insertafter(line.head,upper,node.copy(color_pop))
      end
    end
  end
  return head
end
keeptext = true
colorexpansion = true

colorstretch_coloroffset = 0.5
colorstretch_colorrange = 0.5
chickenize_rule_bad_height = 4/5 -- height and depth of the rules
chickenize_rule_bad_depth = 1/5

colorstretchnumbers = true
drawstretchthreshold = 0.1
drawexpansionthreshold = 0.9
colorstretch = function (head)

  local f = font.getfont(font.current()).characters
  for line in traverseid(Hhead,head) do
    local rule_bad = nodenew(RULE)

if colorexpansion then  -- if also the font expansion should be shown
      local g = line.head
        while not(g.id == 37) do
         g = g.next
        end
      exp_factor = g.width / f[g.char].width
      exp_color = colorstretch_coloroffset + (1-exp_factor)*10 .. " g"
      rule_bad.width = 0.5*line.width  -- we need two rules on each line!
    else
      rule_bad.width = line.width  -- only the space expansion should be shown, only one rule
    end
    rule_bad.height = tex.baselineskip.width*chickenize_rule_bad_height -- this should give a better output
    rule_bad.depth = tex.baselineskip.width*chickenize_rule_bad_depth

    local glue_ratio = 0
    if line.glue_order == 0 then
      if line.glue_sign == 1 then
        glue_ratio = colorstretch_colorrange * math.min(line.glue_set,1)
      else
        glue_ratio = -colorstretch_colorrange * math.min(line.glue_set,1)
      end
    end
    color_push.data = colorstretch_coloroffset + glue_ratio .. " g"

-- set up output
    local p = line.head

  -- a rule to immitate kerning all the way back
    local kern_back = nodenew(RULE)
    kern_back.width = -line.width

  -- if the text should still be displayed, the color and box nodes are inserted additionally
  -- and the head is set to the color node
    if keeptext then
      line.head = insertbefore(line.head,line.head,node.copy(color_push))
    else
      node.flush_list(p)
      line.head = node.copy(color_push)
    end
    insertafter(line.head,line.head,rule_bad)  -- then the rule
    insertafter(line.head,line.head.next,node.copy(color_pop)) -- and then pop!
    tmpnode =  insertafter(line.head,line.head.next.next,kern_back)

    -- then a rule with the expansion color
    if colorexpansion then  -- if also the stretch/shrink of letters should be shown
      color_push.data = exp_color
      insertafter(line.head,tmpnode,node.copy(color_push))
      insertafter(line.head,tmpnode.next,node.copy(rule_bad))
      insertafter(line.head,tmpnode.next.next,node.copy(color_pop))
    end
    if colorstretchnumbers then
      j = 1
      glue_ratio_output = {}
      for s in string.utfvalues(math.abs(glue_ratio)) do -- using math.abs here gets us rid of the minus sign
        local char = unicode.utf8.char(s)
        glue_ratio_output[j] = nodenew(37,1)
        glue_ratio_output[j].font = font.current()
        glue_ratio_output[j].char = s
        j = j+1
      end
      if math.abs(glue_ratio) > drawstretchthreshold then
        if glue_ratio < 0 then color_push.data = "0.99 0 0 rg"
        else color_push.data = "0 0.99 0 rg" end
      else color_push.data = "0 0 0 rg"
      end

      insertafter(line.head,node.tail(line.head),node.copy(color_push))
      for i = 1,math.min(j-1,7) do
        insertafter(line.head,node.tail(line.head),glue_ratio_output[i])
      end
      insertafter(line.head,node.tail(line.head),node.copy(color_pop))
    end -- end of stretch number insertion
  end
  return head
end
--
function pdf_print (...)
  for _, str in ipairs({...}) do
    pdf.print(str .. " ")
  end
  pdf.print("\string\n")
end

function move (p)
  pdf_print(p[1],p[2],"m")
end

function line (p)
  pdf_print(p[1],p[2],"l")
end

function curve(p1,p2,p3)
  pdf_print(p1[1], p1[2],
            p2[1], p2[2],
            p3[1], p3[2], "c")
end

function close ()
  pdf_print("h")
end

function linewidth (w)
  pdf_print(w,"w")
end

function stroke ()
  pdf_print("S")
end
--

function strictcircle(center,radius)
  local left = {center[1] - radius, center[2]}
  local lefttop = {left[1], left[2] + 1.45*radius}
  local leftbot = {left[1], left[2] - 1.45*radius}
  local right = {center[1] + radius, center[2]}
  local righttop = {right[1], right[2] + 1.45*radius}
  local rightbot = {right[1], right[2] - 1.45*radius}

  move (left)
  curve (lefttop, righttop, right)
  curve (rightbot, leftbot, left)
stroke()
end

function disturb_point(point)
  return {point[1] + math.random()*5 - 2.5,
          point[2] + math.random()*5 - 2.5}
end

function sloppycircle(center,radius)
  local left = disturb_point({center[1] - radius, center[2]})
  local lefttop = disturb_point({left[1], left[2] + 1.45*radius})
  local leftbot = {lefttop[1], lefttop[2] - 2.9*radius}
  local right = disturb_point({center[1] + radius, center[2]})
  local righttop = disturb_point({right[1], right[2] + 1.45*radius})
  local rightbot = disturb_point({right[1], right[2] - 1.45*radius})

  local right_end = disturb_point(right)

  move (right)
  curve (rightbot, leftbot, left)
  curve (lefttop, righttop, right_end)
  linewidth(math.random()+0.5)
  stroke()
end

function sloppyline(start,stop)
  local start_line = disturb_point(start)
  local stop_line = disturb_point(stop)
  start = disturb_point(start)
  stop = disturb_point(stop)
  move(start) curve(start_line,stop_line,stop)
  linewidth(math.random()+0.5)
  stroke()
end
-- 
--  End of File `chickenize.lua'.
