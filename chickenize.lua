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
--  This package is copyright © 2021 Arno L. Trautmann. It may be distributed and/or
--  modified under the conditions of the LaTeX Project Public License, either version 1.3c
--  of this license or (at your option) any later version. This work has the LPPL mainten-
--  ance status ‘maintained’.

local nodeid   = node.id
local nodecopy = node.copy
local nodenew  = node.new
local nodetail = node.tail
local nodeslide = node.slide
local noderemove = node.remove
local nodetraverseid = node.traverse_id
local nodeinsertafter = node.insert_after
local nodeinsertbefore = node.insert_before

Hhead = nodeid("hhead")
RULE  = nodeid("rule")
GLUE  = nodeid("glue")
WHAT  = nodeid("whatsit")
COL   = node.subtype("pdf_colorstack")
DISC  = nodeid("disc")
GLYPH = nodeid("glyph")
GLUE  = nodeid("glue")
HLIST = nodeid("hlist")
KERN  = nodeid("kern")
PUNCT = nodeid("punct")
PENALTY = nodeid("penalty")
PDF_LITERAL = node.subtype("pdf_literal")
color_push = nodenew(WHAT,COL)
color_pop = nodenew(WHAT,COL)
color_push.stack = 0
color_pop.stack = 0
color_push.command = 1
color_pop.command = 2
chicken_pagenumbers = true

chickenstring = {}
chickenstring[1] = "chicken" -- chickenstring is a table, please remeber this!

chickenizefraction = 0.5 -- set this to a small value to fool somebody,
-- or to see if your text has been read carefully. This is also a great way to lay easter eggs for your own class / package …
chicken_substitutions = 0 -- value to count the substituted chickens. Makes sense for testing your proofreaders.

local match = unicode.utf8.match
chickenize_ignore_word = false
chickenize_real_stuff = function(i,head)
    while ((i.next.id == GLYPH) or (i.next.id == KERN) or (i.next.id == DISC) or (i.next.id == HLIST)) do  --find end of a word
      i.next = i.next.next
    end

    chicken = {}  -- constructing the node list.

-- Should this be done only once? No, otherwise we lose the freedom to change the string in-document.
-- But it could be done only once each paragraph as in-paragraph changes are not possible!

    chickenstring_tmp = chickenstring[math.random(1,#chickenstring)]
    chicken[0] = nodenew(GLYPH,1)  -- only a dummy for the loop
    for i = 1,string.len(chickenstring_tmp) do
      chicken[i] = nodenew(GLYPH,1)
      chicken[i].font = font.current()
      chicken[i-1].next = chicken[i]
    end

    j = 1
    for s in string.utfvalues(chickenstring_tmp) do
      local char = unicode.utf8.char(s)
      chicken[j].char = s
      if match(char,"%s") then
        chicken[j] = nodenew(GLUE)
        chicken[j].width = space
        chicken[j].shrink = shrink
        chicken[j].stretch = stretch
      end
      j = j+1
    end

    nodeslide(chicken[1])
    lang.hyphenate(chicken[1])
    chicken[1] = node.kerning(chicken[1])    -- FIXME: does not work
    chicken[1] = node.ligaturing(chicken[1]) -- dito

    nodeinsertbefore(head,i,chicken[1])
    chicken[1].next = chicken[2] -- seems to be necessary … to be fixed
    chicken[string.len(chickenstring_tmp)].next = i.next

    -- shift lowercase latin letter to uppercase if the original input was an uppercase
    if (chickenize_capital and (chicken[1].char > 96 and chicken[1].char < 123)) then
      chicken[1].char = chicken[1].char - 32
    end

  return head
end

chickenize = function(head)
  for i in nodetraverseid(GLYPH,head) do  --find start of a word
    -- Random determination of the chickenization of the next word:
    if math.random() > chickenizefraction then
      chickenize_ignore_word = true
    elseif chickencount then
      chicken_substitutions = chicken_substitutions + 1
    end

    if (chickenize_ignore_word == false) then  -- normal case: at the beginning of a word, we jump into chickenization
      if (i.char > 64 and i.char < 91) then chickenize_capital = true else chickenize_capital = false end
      head = chickenize_real_stuff(i,head)
    end

-- At the end of the word, the ignoring is reset. New chance for everyone.
    if not((i.next.id == GLYPH) or (i.next.id == DISC) or (i.next.id == PUNCT) or (i.next.id == KERN)) then
      chickenize_ignore_word = false
    end
  end
  return head
end

local separator     = string.rep("=", 28)
local texiowrite_nl = texio.write_nl
nicetext = function()
  texiowrite_nl("Output written on "..tex.jobname..".pdf ("..status.total_pages.." chicken,".." eggs).")
  texiowrite_nl(" ")
  texiowrite_nl(separator)
  texiowrite_nl("Hello my dear user,")
  texiowrite_nl("good job, now go outside and enjoy the world!")
  texiowrite_nl(" ")
  texiowrite_nl("And don't forget to feed your chicken!")
  texiowrite_nl(separator .. "\n")
  if chickencount then
    texiowrite_nl("There were "..chicken_substitutions.." substitutions made.")
    texiowrite_nl(separator)
  end
end
boustrophedon = function(head)
  rot = node.new(WHAT,PDF_LITERAL)
  rot2 = node.new(WHAT,PDF_LITERAL)
  odd = true
    for line in node.traverse_id(0,head) do
      if odd == false then
        w = line.width/65536*0.99625 -- empirical correction factor (?)
        rot.data  = "-1 0 0 1 "..w.." 0 cm"
        rot2.data = "-1 0 0 1 "..-w.." 0 cm"
        line.head = node.insert_before(line.head,line.head,nodecopy(rot))
        nodeinsertafter(line.head,nodetail(line.head),nodecopy(rot2))
        odd = true
      else
        odd = false
      end
    end
  return head
end
boustrophedon_glyphs = function(head)
  odd = false
  rot = nodenew(WHAT,PDF_LITERAL)
  rot2 = nodenew(WHAT,PDF_LITERAL)
  for line in nodetraverseid(0,head) do
    if odd==true then
      line.dir = "TRT"
      for g in nodetraverseid(GLYPH,line.head) do
        w = -g.width/65536*0.99625
        rot.data = "-1 0 0 1 " .. w .." 0 cm"
        rot2.data = "-1 0 0 1 " .. -w .." 0 cm"
        line.head = node.insert_before(line.head,g,nodecopy(rot))
        nodeinsertafter(line.head,g,nodecopy(rot2))
      end
      odd = false
      else
        line.dir = "TLT"
        odd = true
      end
    end
  return head
end
boustrophedon_inverse = function(head)
  rot = node.new(WHAT,PDF_LITERAL)
  rot2 = node.new(WHAT,PDF_LITERAL)
  odd = true
    for line in node.traverse_id(0,head) do
      if odd == false then
texio.write_nl(line.height)
        w = line.width/65536*0.99625 -- empirical correction factor (?)
        h = line.height/65536*0.99625
        rot.data  = "-1 0 0 -1 "..w.." "..h.." cm"
        rot2.data = "-1 0 0 -1 "..-w.." "..0.5*h.." cm"
        line.head = node.insert_before(line.head,line.head,node.copy(rot))
        node.insert_after(line.head,node.tail(line.head),node.copy(rot2))
        odd = true
      else
        odd = false
      end
    end
  return head
end
function bubblesort(head)
  for line in nodetraverseid(0,head) do
    for glyph in nodetraverseid(GLYPH,line.head) do

    end
  end
  return head
end
--  Take care: This will slow down the compilation extremely, by about a factor of 2! Only use for playing around or counting a final version of your document!
countglyphs = function(head)
  for line in nodetraverseid(0,head) do
    for glyph in nodetraverseid(GLYPH,line.head) do
      glyphnumber = glyphnumber + 1
      if (glyph.next.next) then
        if (glyph.next.id == 10) and (glyph.next.next.id == GLYPH) then
          spacenumber = spacenumber + 1
        end
        counted_glyphs_by_code[glyph.char] = counted_glyphs_by_code[glyph.char] + 1
      end
    end
  end
  return head
end
printglyphnumber = function()
  texiowrite_nl("\nNumber of glyphs by character code (only up to 127):")
  for i = 1,127 do --%% FIXME: should allow for more characters, but cannot be printed to console output – print into document?
    texiowrite_nl(string.char(i)..": "..counted_glyphs_by_code[i])
  end

  texiowrite_nl("\nTotal number of glyphs in this document: "..glyphnumber)
  texiowrite_nl("Number of spaces in this document: "..spacenumber)
  texiowrite_nl("Glyphs plus spaces: "..glyphnumber+spacenumber.."\n")
end
countwords = function(head)
  for glyph in nodetraverseid(GLYPH,head) do
    if (glyph.next.id == GLUE) then
      wordnumber = wordnumber + 1
    end
  end
  wordnumber = wordnumber + 1 -- add 1 for the last word in a paragraph which is not found otherwise
  return head
end
printwordnumber = function()
  texiowrite_nl("\nNumber of words in this document: "..wordnumber)
end

detectdoublewords = function(head)
  prevlastword  = {}  -- array of numbers representing the glyphs
  prevfirstword = {}
  newlastword   = {}
  newfirstword  = {}
  for line in nodetraverseid(0,head) do
    for g in nodetraverseid(GLYPH,line.head) do
texio.write_nl("next glyph",#newfirstword+1)
      newfirstword[#newfirstword+1] = g.char
      if (g.next.id == 10) then break end
    end
texio.write_nl("nfw:"..#newfirstword)
  end
end

printdoublewords = function()
  texio.write_nl("finished")
end
francize = function(head)
  for n in nodetraverseid(GLYPH,head) do
    if ((n.char > 47) and (n.char < 58)) then
      n.char = math.random(48,57)
    end
  end
  return head
end
function gameofchicken()
  GOC_lifetab = {}
  GOC_spawntab = {}
  GOC_antilifetab = {}
  GOC_antispawntab = {}
  -- translate the rules into an easily-manageable table
  for i=1,#GOCrule_live do; GOC_lifetab[GOCrule_live[i]] = true end
  for i=1,#GOCrule_spawn do; GOC_spawntab[GOCrule_spawn[i]] = true end
  for i=1,#GOCrule_antilive do; GOC_antilifetab[GOCrule_antilive[i]] = true end
  for i=1,#GOCrule_antispawn do; GOC_antispawntab[GOCrule_antispawn[i]] = true end
-- initialize the arrays
local life = {}
local antilife = {}
local newlife = {}
local newantilife = {}
for i = 0, GOCx do life[i] = {}; newlife[i] = {} for j = 0, GOCy do life[i][j] = 0 end end
for i = 0, GOCx do antilife[i] = {}; newantilife[i] = {} for j = 0, GOCy do antilife[i][j] = 0 end end
function applyruleslife(neighbors, lifeij, antineighbors, antilifeij)
  if GOC_spawntab[neighbors] then myret = 1 else -- new cell
  if GOC_lifetab[neighbors] and (lifeij == 1) then myret = 1 else myret =  0 end end
  if antineighbors > 1 then myret =  0 end
  return myret
end
function applyrulesantilife(neighbors, lifeij, antineighbors, antilifeij)
  if (antineighbors == 3) then myret = 1 else -- new cell or keep cell
  if (((antineighbors > 1) and (antineighbors < 4)) and (lifeij == 1)) then myret = 1 else myret =  0 end end
  if neighbors > 1 then myret =  0 end
  return myret
end
-- prepare some special patterns as starter
life[53][26] = 1 life[53][25] = 1 life[54][25] = 1 life[55][25] = 1 life[54][24] = 1
  print("start");
  for i = 1,GOCx do
    for j = 1,GOCy do
      if (life[i][j]==1) then texio.write("X") else if (antilife[i][j]==1) then texio.write("O") else texio.write("_") end end
    end
    texio.write_nl(" ");
  end
  os.sleep(GOCsleep)

  for i = 0, GOCx do
    for j = 0, GOCy do
        newlife[i][j] = 0 -- Fill the values from the start settings here
        newantilife[i][j] = 0 -- Fill the values from the start settings here
    end
  end

  for k = 1,GOCiter do -- iterate over the cycles
    texio.write_nl(k);
    for i = 1, GOCx-1 do -- iterate over lines
      for j = 1, GOCy-1 do -- iterate over columns -- prevent edge effects
        local neighbors = (life[i-1][j-1] + life[i-1][j] + life[i-1][j+1] + life[i][j-1] + life[i][j+1] +  life[i+1][j-1] + life[i+1][j] + life[i+1][j+1])
        local antineighbors = (antilife[i-1][j-1] + antilife[i-1][j] + antilife[i-1][j+1] + antilife[i][j-1] + antilife[i][j+1] +  antilife[i+1][j-1] + antilife[i+1][j] + antilife[i+1][j+1])

        newlife[i][j] = applyruleslife(neighbors, life[i][j],antineighbors, antilife[i][j])
        newantilife[i][j] = applyrulesantilife(neighbors,life[i][j], antineighbors,antilife[i][j])
      end
    end

    for i = 1, GOCx do
      for j = 1, GOCy do
        life[i][j] = newlife[i][j] -- copy the values
        antilife[i][j] = newantilife[i][j] -- copy the values
      end
    end

    for i = 1,GOCx do
      for j = 1,GOCy do
        if GOC_console then
          if (life[i][j]==1) then texio.write("X") else if (antilife[i][j]==1) then texio.write("O") else texio.write("_") end end
        end
        if GOC_pdf then
          if (life[i][j]==1) then tex.print("\\placeat("..(i/10)..","..(j/10).."){"..GOCcellcode.."}") end
          if (antilife[i][j]==1) then tex.print("\\placeat("..(i/10)..","..(j/10).."){"..GOCanticellcode.."}") end
        end
      end
    end
    tex.print(".\\newpage")
    os.sleep(GOCsleep)
  end
end --end function gameofchicken
function make_a_gif()
  os.execute("convert -verbose -dispose previous -background white -alpha remove -alpha off -density "..GOCdensity.." "..tex.jobname ..".pdf " ..tex.jobname..".gif")
  os.execute("gwenview "..tex.jobname..".gif")
end
local quotestrings = {
   [171] = true,  [172] = true,
  [8216] = true, [8217] = true, [8218] = true,
  [8219] = true, [8220] = true, [8221] = true,
  [8222] = true, [8223] = true,
  [8248] = true, [8249] = true, [8250] = true,
}
guttenbergenize_rq = function(head)
  for n in nodetraverseid(GLYPH,head) do
    local i = n.char
    if quotestrings[i] then
      noderemove(head,n)
    end
  end
  return head
end
hammertimedelay = 1.2
local htime_separator = string.rep("=", 30) .. "\n" -- slightly inconsistent with the “nicetext”
hammertime = function(head)
  if hammerfirst then
    texiowrite_nl(htime_separator)
    texiowrite_nl("============STOP!=============\n")
    texiowrite_nl(htime_separator .. "\n\n\n")
    os.sleep (hammertimedelay*1.5)
    texiowrite_nl(htime_separator .. "\n")
    texiowrite_nl("==========HAMMERTIME==========\n")
    texiowrite_nl(htime_separator .. "\n\n")
    os.sleep (hammertimedelay)
    hammerfirst = false
  else
    os.sleep (hammertimedelay)
    texiowrite_nl(htime_separator)
    texiowrite_nl("======U can't touch this!=====\n")
    texiowrite_nl(htime_separator .. "\n\n")
    os.sleep (hammertimedelay*0.5)
  end
  return head
end
italianizefraction = 0.5 --%% gives the amount of italianization
mynode = nodenew(GLYPH) -- prepare a dummy glyph

italianize = function(head)
  -- skip "h/H" randomly
  for n in node.traverse_id(GLYPH,head) do -- go through all glyphs
      if n.prev.id ~= GLYPH then -- check if it's a word start
      if ((n.char == 72) or (n.char == 104)) and (tex.normal_rand() < italianizefraction) then -- if it's h/H, remove randomly
        n.prev.next = n.next
      end
    end
  end

  -- add h or H in front of vowels
  for n in nodetraverseid(GLYPH,head) do
    if math.random() < italianizefraction then
    x = n.char
    if x == 97 or x == 101 or x == 105 or x == 111 or x == 117 or
       x == 65 or x ==  69 or x ==  73 or x == 79 or x == 85 then
      if (n.prev.id == GLUE) then
        mynode.font = n.font
        if x > 90 then  -- lower case
          mynode.char = 104
        else
          mynode.char = 72 -- upper case – convert into lower case
          n.char = x + 32
        end
          node.insert_before(head,n,node.copy(mynode))
        end
      end
    end
  end

  -- add e after words, but only after consonants
  for n in node.traverse_id(GLUE,head) do
    if n.prev.id == GLYPH then
    x = n.prev.char
    -- skip vowels and randomize
    if not(x == 97 or x == 101 or x == 105 or x == 111 or x == 117 or x == 44 or x == 46) and math.random() > 0.2 then
        mynode.char = 101           -- it's always a lower case e, no?
        mynode.font = n.prev.font -- adapt the current font
        node.insert_before(head,n,node.copy(mynode)) -- insert the e in the node list
      end
    end
  end

  return head
end
italianizerandwords = function(head)
words = {}
wordnumber = 0
-- head.next.next is the very first word. However, let's try to get the first word after the first space correct.
  for n in nodetraverseid(GLUE,head) do -- let's try to count words by their separators
    wordnumber = wordnumber + 1
    if n.next then
      words[wordnumber] = {}
      words[wordnumber][1] = node.copy(n.next)

      glyphnumber = 1
      myglyph = n.next
      while myglyph.next do
        node.tail(words[wordnumber][1]).next = node.copy(myglyph.next)
        myglyph = myglyph.next
      end
    end
  print(#words)
  if #words > 0 then
  print("lengs is: ")
  print(#words[#words])
  end
  end
--myinsertnode = head.next.next -- first letter
--node.tail(words[1][1]).next = myinsertnode.next
--myinsertnode.next = words[1][1]

  return head
end

italianize_old = function(head)
  local wordlist = {} -- here we will store the number of words of the sentence.
  local words = {} -- here we will store the words of the sentence.
  local wordnumber = 0
  -- let's first count all words in one sentence, howboutdat?
  wordlist[wordnumber] = 1 -- let's save the word *length* in here …

  for n in nodetraverseid(GLYPH,head) do
    if (n.next.id == GLUE) then -- this is a space
      wordnumber = wordnumber + 1
      wordlist[wordnumber] = 1
      words[wordnumber] = n.next.next
    end
    if (n.next.id == GLYPH) then  -- it's a glyph
    if (n.next.char == 46) then -- this is a full stop.
      wordnumber = wordnumber + 1
      texio.write_nl("this sentence had "..wordnumber.."words.")
      for i=0,wordnumber-1 do
      texio.write_nl("word "..i.." had " .. wordlist[i] .. "glyphs")
      end
      texio.write_nl(" ")
      wordnumber = -1 -- to compensate the fact that the next node will be a space, this would count one word too much.
    else

      wordlist[wordnumber] = wordlist[wordnumber] + 1 -- the current word got 1 glyph longer
      end
    end
  end
  return head
end

itsame = function()
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
chickenkernamount = 0
chickeninvertkerning = false

function kernmanipulate (head)
  if chickeninvertkerning then -- invert the kerning
    for n in nodetraverseid(11,head) do
      n.kern = -n.kern
    end
  else             -- if not, set it to the given value
    for n in nodetraverseid(11,head) do
      n.kern = chickenkernamount
    end
  end
  return head
end

leetspeak_onlytext = false
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
  for line in nodetraverseid(Hhead,head) do
    for i in nodetraverseid(GLYPH,line.head) do
      if not leetspeak_onlytext or
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
leftsideright = function(head)
  local factor = 65536/0.99626
  for n in nodetraverseid(GLYPH,head) do
    if (leftsiderightarray[n.char]) then
      shift = nodenew(WHAT,PDF_LITERAL)
      shift2 = nodenew(WHAT,PDF_LITERAL)
      shift.data = "q -1 0 0 1 " .. n.width/factor .." 0 cm"
      shift2.data = "Q 1 0 0 1 " .. n.width/factor .." 0 cm"
      nodeinsertbefore(head,n,shift)
      nodeinsertafter(head,n,shift2)
    end
  end
  return head
end
local letterspace_glue   = nodenew(GLUE)
local letterspace_pen    = nodenew(PENALTY)

letterspace_glue.width   = tex.sp"0pt"
letterspace_glue.stretch = tex.sp"0.5pt"
letterspace_pen.penalty  = 10000
letterspaceadjust = function(head)
  for glyph in nodetraverseid(GLYPH, head) do
    if glyph.prev and (glyph.prev.id == GLYPH or glyph.prev.id == DISC or glyph.prev.id == KERN) then
      local g = nodecopy(letterspace_glue)
      nodeinsertbefore(head, glyph, g)
      nodeinsertbefore(head, g, nodecopy(letterspace_pen))
    end
  end
  return head
end
textletterspaceadjust = function(head)
  for glyph in nodetraverseid(GLYPH, head) do
    if node.has_attribute(glyph,luatexbase.attributes.letterspaceadjustattr) then
      if glyph.prev and (glyph.prev.id == node.id"glyph" or glyph.prev.id == node.id"disc" or glyph.prev.id == KERN) then
        local g = node.copy(letterspace_glue)
        nodeinsertbefore(head, glyph, g)
        nodeinsertbefore(head, g, nodecopy(letterspace_pen))
      end
    end
  end
  luatexbase.remove_from_callback("pre_linebreak_filter","textletterspaceadjust")
  return head
end
matrixize = function(head)
  x = {}
  s = nodenew(DISC)
  for n in nodetraverseid(GLYPH,head) do
    j = n.char
    for m = 0,7 do -- stay ASCII for now
      x[7-m] = nodecopy(n) -- to get the same font etc.

      if (j / (2^(7-m)) < 1) then
        x[7-m].char = 48
      else
        x[7-m].char = 49
        j = j-(2^(7-m))
      end
      nodeinsertbefore(head,n,x[7-m])
      nodeinsertafter(head,x[7-m],nodecopy(s))
    end
    noderemove(head,n)
  end
  return head
end
medievalumlaut = function(head)
  local factor = 65536/0.99626
  local org_e_node = nodenew(GLYPH)
  org_e_node.char = 101
  for line in nodetraverseid(0,head) do
    for n in nodetraverseid(GLYPH,line.head) do
      if (n.char == 228 or n.char == 246 or n.char == 252) then
        e_node = nodecopy(org_e_node)
        e_node.font = n.font
        shift = nodenew(WHAT,PDF_LITERAL)
        shift2 = nodenew(WHAT,PDF_LITERAL)
        shift2.data = "Q 1 0 0 1 " .. e_node.width/factor .." 0 cm"
        nodeinsertafter(head,n,e_node)

        nodeinsertbefore(head,e_node,shift)
        nodeinsertafter(head,e_node,shift2)

        x_node = nodenew(KERN)
        x_node.kern = -e_node.width
        nodeinsertafter(head,shift2,x_node)
      end

      if (n.char == 228) then -- ä
        shift.data = "q 0.5 0 0 0.5 " ..
          -n.width/factor*0.85 .." ".. n.height/factor*0.75 .. " cm"
        n.char = 97
      end
      if (n.char == 246) then -- ö
        shift.data = "q 0.5 0 0 0.5 " ..
          -n.width/factor*0.75 .." ".. n.height/factor*0.75 .. " cm"
        n.char = 111
      end
      if (n.char == 252) then -- ü
        shift.data = "q 0.5 0 0 0.5 " ..
          -n.width/factor*0.75 .." ".. n.height/factor*0.75 .. " cm"
        n.char = 117
      end
    end
  end
  return head
end
local separator     = string.rep("=", 28)
local texiowrite_nl = texio.write_nl
pancaketext = function()
  texiowrite_nl("Output written on "..tex.jobname..".pdf ("..status.total_pages.." chicken,".." eggs).")
  texiowrite_nl(" ")
  texiowrite_nl(separator)
  texiowrite_nl("Soo ... you decided to use \\pancakenize.")
  texiowrite_nl("That means you owe me a pancake!")
  texiowrite_nl(" ")
  texiowrite_nl("(This goes by document, not compilation.)")
  texiowrite_nl(separator.."\n\n")
  texiowrite_nl("Looking forward for my pancake! :)")
  texiowrite_nl("\n\n")
end

randomfontslower = 1
randomfontsupper = 0
randomfonts = function(head)
  local rfub
  if randomfontsupper > 0 then  -- fixme: this should be done only once, no? Or at every paragraph?
    rfub = randomfontsupper  -- user-specified value
  else
    rfub = font.max()        -- or just take all fonts
  end
  for line in nodetraverseid(Hhead,head) do
    for i in nodetraverseid(GLYPH,line.head) do
      if not(randomfonts_onlytext) or node.has_attribute(i,luatexbase.attributes.randfontsattr) then
        i.font = math.random(randomfontslower,rfub)
      end
    end
  end
  return head
end
uclcratio = 0.5 -- ratio between uppercase and lower case
randomuclc = function(head)
  for i in nodetraverseid(GLYPH,head) do
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
  for line in nodetraverseid(Hhead,head) do
    for i in nodetraverseid(GLYPH,line.head) do
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
  for line in nodetraverseid(0,head) do
    for i in nodetraverseid(GLYPH,line.head) do
      if not(randomcolor_onlytext) or
         (node.has_attribute(i,luatexbase.attributes.randcolorattr))
      then
        color_push.data = randomcolorstring()  -- color or grey string
        line.head = nodeinsertbefore(line.head,i,nodecopy(color_push))
        nodeinsertafter(line.head,i,nodecopy(color_pop))
      end
    end
  end
  return head
end
  sailheight = 12
  mastheight = 4
  hullheight = 5
  relnumber = 402
function relationship()
--%% check if there's a problem with any character in the current font
  f = font.getfont(font.current())
  fullfont = 1
  for i = 8756,8842 do
    if not(f.characters[i]) then texio.write_nl((i).." not available") fullfont = 0 end
  end
--%% store the result of the check for later, then go on to construct the ship:
  shipheight = sailheight + mastheight + hullheight
  tex.print("\\parshape "..(shipheight)) --%% prepare the paragraph shape ...
  for i =1,sailheight do
    tex.print(" "..(4.5-i/3.8).."cm "..((i-0.5)/2.5).."cm ")
   end
  for i =1,mastheight do
    tex.print(" "..(3.2).."cm "..(1).."cm ")
  end
  for i =1,hullheight do
    tex.print(" "..((i-1)/2).."cm "..(10-i).."cm ")
  end
  tex.print("\\noindent") --%% ... up to here, then insert relations
  for i=1,relnumber do
    tex.print("\\ \\char"..math.random(8756,8842))
  end
  tex.print("\\break")
end
function cutparagraph(head)
  local parsum = 0
  for n in nodetraverseid(HLIST,head) do
    parsum = parsum + 1
    if parsum > shipheight then
      node.remove(head,n)
    end
  end
  return head
end
function missingcharstext()
  if (fullfont == 0) then
  local separator     = string.rep("=", 28)
local texiowrite_nl = texio.write_nl
  texiowrite_nl("Output written on "..tex.jobname..".pdf ("..status.total_pages.." chicken,".." eggs).")
  texiowrite_nl(" ")
  texiowrite_nl(separator)
  texiowrite_nl("CAREFUL!!")
  texiowrite_nl("\\relationship needs special characters (unicode points 8756 to 8842)")
  texiowrite_nl("Your font does not support all of them!")
  texiowrite_nl("consider using another one, e.g. the XITS font supplied with TeXlive.")
  texiowrite_nl(separator .. "\n")
  end
end
substitutewords_strings = {}

addtosubstitutions = function(input,output)
  substitutewords_strings[#substitutewords_strings + 1] = {}
  substitutewords_strings[#substitutewords_strings][1] = input
  substitutewords_strings[#substitutewords_strings][2] = output
end

substitutewords = function(head)
  for i = 1,#substitutewords_strings do
    head = string.gsub(head,substitutewords_strings[i][1],substitutewords_strings[i][2])
  end
  return head
end
suppressonecharbreakpenaltynode = node.new(PENALTY)
suppressonecharbreakpenaltynode.penalty = 10000
function suppressonecharbreak(head)
  for i in node.traverse_id(GLUE,head) do
    if ((i.next) and (i.next.next.id == GLUE)) then
        pen = node.copy(suppressonecharbreakpenaltynode)
        node.insert_after(head,i.next,pen)
    end
  end

  return head
end
tabularasa_onlytext = false

tabularasa = function(head)
  local s = nodenew(KERN)
  for line in nodetraverseid(HLIST,head) do
    for n in nodetraverseid(GLYPH,line.head) do
      if not(tabularasa_onlytext) or node.has_attribute(n,luatexbase.attributes.tabularasaattr) then
        s.kern = n.width
        nodeinsertafter(line.list,n,nodecopy(s))
        line.head = noderemove(line.list,n)
      end
    end
  end
  return head
end
tanjanize = function(head)
  local s = nodenew(KERN)
  local m = nodenew(GLYPH,1)
  local use_letter_i = true
  scale = nodenew(WHAT,PDF_LITERAL)
  scale2 = nodenew(WHAT,PDF_LITERAL)
  scale.data  = "0.5 0 0 0.5 0 0 cm"
  scale2.data = "2   0 0 2   0 0 cm"

  for line in nodetraverseid(HLIST,head) do
    for n in nodetraverseid(GLYPH,line.head) do
      mimicount = 0
      tmpwidth  = 0
      while ((n.next.id == GLYPH) or (n.next.id == 11) or (n.next.id == 7) or (n.next.id == 0)) do  --find end of a word
        n.next = n.next.next
        mimicount = mimicount + 1
        tmpwidth = tmpwidth + n.width
      end

    mimi = {}  -- constructing the node list.
    mimi[0] = nodenew(GLYPH,1)  -- only a dummy for the loop
    for i = 1,string.len(mimicount) do
      mimi[i] = nodenew(GLYPH,1)
      mimi[i].font = font.current()
      if(use_letter_i) then mimi[i].char = 109 else mimi[i].char = 105 end
      use_letter_i = not(use_letter_i)
      mimi[i-1].next = mimi[i]
    end
--]]

line.head = nodeinsertbefore(line.head,n,nodecopy(scale))
nodeinsertafter(line.head,n,nodecopy(scale2))
      s.kern = (tmpwidth*2-n.width)
      nodeinsertafter(line.head,n,nodecopy(s))
    end
  end
  return head
end
uppercasecolor_onlytext = false

uppercasecolor = function (head)
  for line in nodetraverseid(Hhead,head) do
    for upper in nodetraverseid(GLYPH,line.head) do
      if not(uppercasecolor_onlytext) or node.has_attribute(upper,luatexbase.attributes.uppercasecolorattr) then
        if (((upper.char > 64) and (upper.char < 91)) or
            ((upper.char > 57424) and (upper.char < 57451)))  then  -- for small caps! nice ☺
          color_push.data = randomcolorstring()  -- color or grey string
          line.head = nodeinsertbefore(line.head,upper,nodecopy(color_push))
          nodeinsertafter(line.head,upper,nodecopy(color_pop))
        end
      end
    end
  end
  return head
end
upsidedown = function(head)
  local factor = 65536/0.99626
  for line in nodetraverseid(Hhead,head) do
    for n in nodetraverseid(GLYPH,line.head) do
      if (upsidedownarray[n.char]) then
        shift = nodenew(WHAT,PDF_LITERAL)
        shift2 = nodenew(WHAT,PDF_LITERAL)
        shift.data = "q 1 0 0 -1 0 " .. n.height/factor .." cm"
        shift2.data = "Q 1 0 0 1 " .. n.width/factor .." 0 cm"
        nodeinsertbefore(head,n,shift)
        nodeinsertafter(head,n,shift2)
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
  for line in nodetraverseid(Hhead,head) do
    local rule_bad = nodenew(RULE)

    if colorexpansion then  -- if also the font expansion should be shown
--%% here use first_glyph function!!
      local g = line.head
n = node.first_glyph(line.head.next)
texio.write_nl(line.head.id)
texio.write_nl(line.head.next.id)
texio.write_nl(line.head.next.next.id)
texio.write_nl(n.id)
      while not(g.id == GLYPH) and (g.next) do g = g.next end -- find first glyph on line. If line is empty, no glyph:
      if (g.id == GLYPH) then                                 -- read width only if g is a glyph!
        exp_factor = g.expansion_factor/10000 --%% neato, luatex now directly gives me this!!
        exp_color = colorstretch_coloroffset + (exp_factor*0.1) .. " g"
texio.write_nl(exp_factor)
        rule_bad.width = 0.5*line.width  -- we need two rules on each line!
      end
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
      line.head = nodeinsertbefore(line.head,line.head,nodecopy(color_push))
    else
      node.flush_list(p)
      line.head = nodecopy(color_push)
    end
    nodeinsertafter(line.head,line.head,rule_bad)  -- then the rule
    nodeinsertafter(line.head,line.head.next,nodecopy(color_pop)) -- and then pop!
    tmpnode =  nodeinsertafter(line.head,line.head.next.next,kern_back)

    -- then a rule with the expansion color
    if colorexpansion then  -- if also the stretch/shrink of letters should be shown
      color_push.data = exp_color
      nodeinsertafter(line.head,tmpnode,nodecopy(color_push))
      nodeinsertafter(line.head,tmpnode.next,nodecopy(rule_bad))
      nodeinsertafter(line.head,tmpnode.next.next,nodecopy(color_pop))
    end
    if colorstretchnumbers then
      j = 1
      glue_ratio_output = {}
      for s in string.utfvalues(math.abs(glue_ratio)) do -- using math.abs here gets us rid of the minus sign
        local char = unicode.utf8.char(s)
        glue_ratio_output[j] = nodenew(GLYPH,1)
        glue_ratio_output[j].font = font.current()
        glue_ratio_output[j].char = s
        j = j+1
      end
      if math.abs(glue_ratio) > drawstretchthreshold then
        if glue_ratio < 0 then color_push.data = "0.99 0 0 rg"
        else color_push.data = "0 0.99 0 rg" end
      else color_push.data = "0 0 0 rg"
      end

      nodeinsertafter(line.head,node.tail(line.head),nodecopy(color_push))
      for i = 1,math.min(j-1,7) do
        nodeinsertafter(line.head,node.tail(line.head),glue_ratio_output[i])
      end
      nodeinsertafter(line.head,node.tail(line.head),nodecopy(color_pop))
    end -- end of stretch number insertion
  end
  return head
end

function scorpionize_color(head)
  color_push.data = ".35 .55 .75 rg"
  nodeinsertafter(head,head,nodecopy(color_push))
  nodeinsertafter(head,node.tail(head),nodecopy(color_pop))
  return head
end
substlist = {}
substlist[1488] = 64289
substlist[1491] = 64290
substlist[1492] = 64291
substlist[1499] = 64292
substlist[1500] = 64293
substlist[1501] = 64294
substlist[1512] = 64295
substlist[1514] = 64296
function variantjustification(head)
  math.randomseed(1)
  for line in nodetraverseid(Hhead,head) do
    if (line.glue_sign == 1 and line.glue_order == 0) then -- exclude the last line!
      substitutions_wide = {} -- we store all “expandable” letters of each line
      for n in nodetraverseid(GLYPH,line.head) do
        if (substlist[n.char]) then
          substitutions_wide[#substitutions_wide+1] = n
        end
      end
      line.glue_set = 0   -- deactivate normal glue expansion
      local width = node.dimensions(line.head)  -- check the new width of the line
      local goal = line.width
      while (width < goal and #substitutions_wide > 0) do
        x = math.random(#substitutions_wide)      -- choose randomly a glyph to be substituted
        oldchar = substitutions_wide[x].char
        substitutions_wide[x].char = substlist[substitutions_wide[x].char] -- substitute by wide letter
        width = node.dimensions(line.head)             -- check if the line is too wide
        if width > goal then substitutions_wide[x].char = oldchar break end -- substitute back if the line would be too wide and break out of the loop
        table.remove(substitutions_wide,x)          -- if further substitutions have to be done, remove the just substituted node from the list
      end
    end
  end
  return head
end
zebracolorarray = {}
zebracolorarray_bg = {}
zebracolorarray[1] = "0.1 g"
zebracolorarray[2] = "0.9 g"
zebracolorarray_bg[1] = "0.9 g"
zebracolorarray_bg[2] = "0.1 g"
function zebranize(head)
  zebracolor = 1
  for line in nodetraverseid(Hhead,head) do
    if zebracolor == #zebracolorarray then zebracolor = 0 end
    zebracolor = zebracolor + 1
    color_push.data = zebracolorarray[zebracolor]
    line.head =     nodeinsertbefore(line.head,line.head,nodecopy(color_push))
    for n in nodetraverseid(GLYPH,line.head) do
      if n.next then else
        nodeinsertafter(line.head,n,nodecopy(color_pull))
      end
    end

    local rule_zebra = nodenew(RULE)
    rule_zebra.width = line.width
    rule_zebra.height = tex.baselineskip.width*4/5
    rule_zebra.depth = tex.baselineskip.width*1/5

    local kern_back = nodenew(RULE)
    kern_back.width = -line.width

    color_push.data = zebracolorarray_bg[zebracolor]
    line.head = nodeinsertbefore(line.head,line.head,nodecopy(color_pop))
    line.head = nodeinsertbefore(line.head,line.head,nodecopy(color_push))
    nodeinsertafter(line.head,line.head,kern_back)
    nodeinsertafter(line.head,line.head,rule_zebra)
  end
  return (head)
end
--
function pdf_print (...)
  for _, str in ipairs({...}) do
    pdf.print(str .. " ")
  end
  pdf.print("\n")
end

function move (p1,p2)
  if (p2) then
    pdf_print(p1,p2,"m")
  else
    pdf_print(p1[1],p1[2],"m")
  end
end

function line(p1,p2)
  if (p2) then
    pdf_print(p1,p2,"l")
  else
    pdf_print(p1[1],p1[2],"l")
  end
end

function curve(p11,p12,p21,p22,p31,p32)
  if (p22) then
    p1,p2,p3 = {p11,p12},{p21,p22},{p31,p32}
  else
    p1,p2,p3 = p11,p12,p21
  end
  pdf_print(p1[1], p1[2],
              p2[1], p2[2],
              p3[1], p3[2], "c")
end

function close ()
  pdf_print("h")
end

drawwidth = 1

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

sloppynessh = 5
sloppynessv = 5

function disturb_point(point)
  return {point[1] + (math.random() - 1/2)*sloppynessh,
          point[2] + (math.random() - 1/2)*sloppynessv}
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
  linewidth(drawwidth*(math.random()+0.5))
  stroke()
end

function sloppyellipsis(center,radiusx,radiusy)
  local left = disturb_point({center[1] - radiusx, center[2]})
  local lefttop = disturb_point({left[1], left[2] + 1.45*radiusy})
  local leftbot = {lefttop[1], lefttop[2] - 2.9*radiusy}
  local right = disturb_point({center[1] + radiusx, center[2]})
  local righttop = disturb_point({right[1], right[2] + 1.45*radiusy})
  local rightbot = disturb_point({right[1], right[2] - 1.45*radiusy})

  local right_end = disturb_point(right)

  move (right)
  curve (rightbot, leftbot, left)
  curve (lefttop, righttop, right_end)
  linewidth(drawwidth*(math.random()+0.5))
  stroke()
end

function sloppyline(start,stop)
  local start_line = disturb_point(start)
  local stop_line = disturb_point(stop)
  start = disturb_point(start)
  stop = disturb_point(stop)
  move(start) curve(start_line,stop_line,stop)
  linewidth(drawwidth*(math.random()+0.5))
  stroke()
end
-- 
--  End of File `chickenize.lua'.
