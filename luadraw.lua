-- code [mostly] by Paul Isambert.

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

local function rand ()
  return math.random(-100,100)/60
end

function sloppyline(p1,p2)
  local c1 = {p1[1] + rand(), p1[2] + rand()}
  local c2 = {p2[1] + rand(), p2[2] + rand()}
  p1[1], p1[2] = p1[1] + rand(), p1[2] + rand()
  p2[1], p2[2] = p2[1] + rand(), p2[2] + rand()
  linewidth(math.max(.5,rand()/1.5))
  move(p1) curve(c1, c2, p2) stroke()
end
