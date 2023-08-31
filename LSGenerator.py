content = []
with open('LSConfig.txt', 'r') as input_file:
    for line in input_file:
        content.append(line.strip())

parsed = []
for i in content:
    temp = i.split(' ')
    
    background = 0
    if "|" in i:
        image = [temp[0].split("|")[0],temp[0].split("|")[1]]
        background = 1
    else:
        image = [temp[0]]
    
    resizing = temp[1]
    
    filltype = temp[2]
    
    fillcolor = [temp[3],temp[4],temp[5],temp[6]]
    
    parsed.append([image,resizing,filltype,fillcolor,background])
    
    
with open('LSMod.ini', 'w') as output_file:
    output_file.write(f"""[Constants]
global $swapvar = 0
global $isLS = 0

[Present]
if $isLS == 0
	$swapvar  = $swapvar + 1
	if $swapvar > {len(content) - 1}
		$swapvar = 0
	endif
endif
post $isLS = 0

[TextureOverrideLS]
hash = 77fe5250

$isLS = 1

local $x55temp = x55
local $y55temp = y55
local $z55temp = z55
local $w55temp = w55

local $x56temp = x56
local $y56temp = y56
local $z56temp = z56
local $w56temp = w56

local $x57temp = x57

Resourcet33temp = ps-t33
Resourcet34temp = ps-t34

run = CommandListRandom

post x55 = $x55temp
post y55 = $y55temp
post z55 = $z55temp
post w55 = $w55temp

post x56 = $x56temp
post y56 = $y56temp
post z56 = $z56temp
post w56 = $w56temp

post x57 = $x56temp

post ps-t33 = Resourcet33temp
post ps-t34 = Resourcet34temp

[CommandListRandom]
x55 = res_width
y55 = res_height
""")
    
    n = 0
    
    for pars in parsed:
        if n != 0:
            output_file.write("else ")
        
        output_file.write(f"if $swapvar == {n}\n")
        output_file.write(f"    z55 = {pars[1]}\n")
        output_file.write(f"    w55 = {pars[2]}\n")
        output_file.write(f"    x56 = {pars[3][0]}\n")
        output_file.write(f"    y56 = {pars[3][1]}\n")
        output_file.write(f"    z56 = {pars[3][2]}\n")
        output_file.write(f"    w56 = {pars[3][3]}\n")
        output_file.write(f"    x57 = {pars[4]}\n")
        output_file.write(f"    ps-t33 = Resource{pars[0][0]}\n")
        if pars[4] == 1:
            output_file.write(f"    ps-t34 = Resource{pars[0][1]}\n")
        
        n+= 1
        
    output_file.write("endif\n")
    
    output_file.write("run = CustomShaderLoadingScreen\n")
    
    output_file.write(f"""[CustomShaderLoadingScreen]
vs = draw_2d.hlsl
ps = draw_2d.hlsl
blend = ADD SRC_ALPHA INV_SRC_ALPHA
cull = none
topology = triangle_strip
o0 = set_viewport bb
Draw = 4,0

[Resourcet33temp]
[Resourcet34temp]
""")

    for pars in parsed:
        for i in pars[0]:
            output_file.write(f"[Resource{i}]\nfilename = data\\{i}\n")