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
Hhead = node.id("hhead")
RULE = node.id("rule")
GLUE = node.id("glue")
WHAT = node.id("whatsit")
COL = node.subtype("pdf_colorstack")
GLYPH = node.id("glyph")
color_push = node.new(WHAT,COL)
color_pop = node.new(WHAT,COL)
color_push.stack = 0
color_pop.stack = 0
color_push.cmd = 1
color_pop.cmd = 2
chickenstring = "Chicken"

local tbl = font.getfont(font.current())
local space = tbl.parameters.space
local shrink = tbl.parameters.space_shrink
local stretch = tbl.parameters.space_stretch
local match = unicode.utf8.match

chickenize = function(head)
  for i in node.traverse_id(37,head) do  --find start of a word
    while ((i.next.id == 37) or (i.next.id == 11) or (i.next.id == 7) or (i.next.id == 0)) do  --find end of a word
      i.next = i.next.next
    end

    chicken = {}  -- constructing the node list. Should be done only once?
    chicken[0] = node.new(37,1)  -- only a dummy for the loop
    for i = 1,string.len(chickenstring) do
      chicken[i] = node.new(37,1)
      chicken[i].font = font.current()
      chicken[i-1].next = chicken[i]
    end

    j = 1
    for s in string.utfvalues(chickenstring) do
      local char = unicode.utf8.char(s)
      chicken[j].char = s
      if match(char,"%s") then
        chicken[j] = node.new(10)
        chicken[j].spec = node.new(47)
        chicken[j].spec.width = space
        chicken[j].spec.shrink = shrink
        chicken[j].spec.stretch = stretch
      end
      j = j+1
    end

    node.insert_before(head,i,chicken[1])
    chicken[1].next = chicken[2] -- seems to be necessary … to be fixed
    chicken[string.len(chickenstring)].next = i.next
  end

  return head
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
  for line in node.traverse_id(Hhead,head) do
    for i in node.traverse_id(GLYPH,line.head) do
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
randomfontslower = 1
randomfontsupper = 0
randomfonts = function(head)
  if (randomfontsupper > 0) then  -- fixme: this should be done only once, no? Or at every paragraph?
    rfub = randomfontsupper  -- user-specified value
  else
    rfub = font.max()        -- or just take all fonts
  end
  for line in node.traverse_id(Hhead,head) do
    for i in node.traverse_id(GLYPH,line.head) do
      if not(randomfonts_onlytext) or node.has_attribute(i,luatexbase.attributes.randfontsattr) then
        i.font = math.random(randomfontslower,rfub)
      end
    end
  end
  return head
end
uclcratio = 0.5 -- so, this can even be changed!
randomuclc = function(head)
  for i in node.traverse_id(37,head) do
    if math.random() < uclcratio then
      i.char = tex.uccode[i.char]
    else
      i.char = tex.lccode[i.char]
end
  end
  return head
end
randomchars = function(head)
  for line in node.traverse_id(Hhead,head) do
    for i in node.traverse_id(GLYPH,line.head) do
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
rainbow_Rgb = 1-step -- we start in the red phase
rainbow_rGb = step   -- values x must always be 0 < x < 1
rainbow_rgB = step
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
    return rainbow_Rgb..rainbow_rGb..rainbow_rgB.." rg"
  else
    Rgb = math.random(Rgb_lower,Rgb_upper)/255
    rGb = math.random(rGb_lower,rGb_upper)/255
    rgB = math.random(rgB_lower,rgB_upper)/255
    return Rgb..rGb..rgB.." rg"
  end
end
randomcolor = function(head)
  for line in node.traverse_id(0,head) do
    for i in node.traverse_id(37,line.head) do
      if not(randomcolor_onlytext) or
         (node.has_attribute(i,luatexbase.attributes.randcolorattr))
      then
        color_push.data = randomcolorstring()  -- color or grey string
        line.head = node.insert_before(line.head,i,node.copy(color_push))
        node.insert_after(line.head,i,node.copy(color_pop))
      end
    end
  end
  return head
end
uppercasecolor = function (head)
  for line in node.traverse_id(Hhead,head) do
    for upper in node.traverse_id(GLYPH,line.head) do
      if (((upper.char > 64) and (upper.char < 91)) or
          ((upper.char > 57424) and (upper.char < 57451)))  then  -- for small caps! nice ☺
        color_push.data = randomcolorstring()  -- color or grey string
        line.head = node.insert_before(line.head,upper,node.copy(color_push))
        node.insert_after(line.head,upper,node.copy(color_pop))
      end
    end
  end
  return head
end
keeptext = true
colorexpansion = true
colorstretch = function (head)

  local f = font.getfont(font.current()).characters
  for line in node.traverse_id(Hhead,head) do
    local rule_bad = node.new(RULE)

if colorexpansion then  -- if also the font expansion should be shown
      local g = line.head
        while not(g.id == 37) do
         g = g.next
        end
      exp_factor = g.width / f[g.char].width
      exp_color = .5 + (1-exp_factor)*10 .. " g"
      rule_bad.width = 0.5*line.width  -- we need two rules on each line!
    else
      rule_bad.width = line.width  -- only the space expansion should be shown, only one rule
    end
    rule_bad.height = tex.baselineskip.width*4/5  -- this should give a better output
    rule_bad.depth = tex.baselineskip.width*1/5

    local glue_ratio = 0
    if line.glue_order == 0 then
      if line.glue_sign == 1 then
        glue_ratio = .5 * math.min(line.glue_set,1)
      else
        glue_ratio = -.5 * math.min(line.glue_set,1)
      end
    end
    color_push.data = .5 + glue_ratio .. " g"
-- set up output
    local p = line.head

  -- a rule to immitate kerning all the way back
    local kern_back = node.new(RULE)
    kern_back.width = -line.width

  -- if the text should still be displayed, the color and box nodes are inserted additionally
  -- and the head is set to the color node
    if keeptext then
      line.head = node.insert_before(line.head,line.head,node.copy(color_push))
    else
      node.flush_list(p)
      line.head = node.copy(color_push)
    end
    node.insert_after(line.head,line.head,rule_bad)  -- then the rule
    node.insert_after(line.head,line.head.next,node.copy(color_pop)) -- and then pop!
    tmpnode =  node.insert_after(line.head,line.head.next.next,kern_back)

    -- then a rule with the expansion color
    if colorexpansion then  -- if also the stretch/shrink of letters should be shown
      color_push.data = exp_color
      node.insert_after(line.head,tmpnode,node.copy(color_push))
      node.insert_after(line.head,tmpnode.next,node.copy(rule_bad))
      node.insert_after(line.head,tmpnode.next.next,node.copy(color_pop))
    end
  end
  return head
end
-- 
--  End of File `chickenize.lua'.
