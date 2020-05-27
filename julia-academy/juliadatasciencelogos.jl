using Luxor, Random

function juliatables1(cpos::Point, radius, twidth, theight, nrows, ncols)
    # clockwise, from bottom LEFT...
    gsave()
    points3 = ngon(cpos, radius, 3, pi/6, vertices=true)
    theta = 0
    for (n, centerp) in enumerate(points3)
        gsave()
        translate(centerp)
        tiles = Tiler(twidth, theight, nrows, ncols)
        for (pos, p) in tiles
            sethue("black")
            if tiles.currentrow == 1 && tiles.currentcol == 1

            elseif tiles.currentrow == 1
                sethue("grey70")
                box(pos, tiles.tilewidth, tiles.tileheight, :stroke)
                sethue(cols[mod1(tiles.currentcol, 3)])
                circle(pos, 3, :fill)
            elseif tiles.currentcol == 1
                sethue("grey70")
                box(pos, tiles.tilewidth, tiles.tileheight, :stroke)
                box(pos, 6, 4, :fill)
            elseif tiles.currentrow > 1
                box(pos, tiles.tilewidth - 2, tiles.tileheight - 2, :stroke)
                sethue(cols[mod1(tiles.currentcol, 3)])
                box(pos, tiles.tilewidth - 6, tiles.tileheight - 6, :fill)
            end
        end
        grestore()
    end
    grestore()
end

function drawflask(pos;
    scalefactor=1)
    flask = Point[Point(100, 0), Point(25, -140), Point(25, -220),
        Point(-25, -220), Point(-25, -140), Point(-100, 0)]
    @layer begin
        translate(pos + (0, 100))
        scale(scalefactor)
        sethue("black")
        setline(20)
        #polysmooth(flask, 10, :fill)
        polysmooth(flask, 10, :clip)
        positions = between.(
            boxtopcenter(BoundingBox(flask)),
            boxbottomcenter(BoundingBox(flask)),
            range(0.5, 1.0, length=3))
        @layer begin
            setopacity(0.9)
            for i in 1:3
                sethue(cols[mod1(i, end)])
                box(positions[i], 200, boxheight(BoundingBox(flask))/2, :fill)
            end
            setopacity(0.3)
            for i in 1:15
                sethue("white")
                circle(rand(BoundingBox(flask) * 0.5), 4, :fill)
            end
        end
        clipreset()
        sethue("black")
        polysmooth(flask, 10, :stroke)
    end
end

const cols = [Luxor.julia_green, Luxor.julia_red,Luxor.julia_purple, Luxor.julia_blue]

function datascienceicon()
    Random.seed!(1)
    sethue("antiquewhite")
    squircle(O, 240, 240, :fill, rt=0.1)

    sethue("plum1")
    circle(O, 200, :fill)

    @layer begin
        setopacity(0.98)
        scale(0.8)
        setline(0.5)
        # cpos, radius, twidth, theight, nrows, ncols)
        juliatables1(Point(-120, -100), 100, 150, 150, 7, 7)
    end
    drawflask(O + (30, 100), scalefactor=1.7)
end

function drawicon()
    Drawing(500, 500, "/tmp/juliadatascienceicon.svg")
    origin()
    datascienceicon()
    finish()
    preview()
end

function drawlogo()
    Drawing(960, 540, "/tmp/juliadatascienceandtitle.svg")
    Luxor.background("ivory")
    origin()
    table = Table([540], [540, 960-540])
    translate(table[1])
    datascienceicon()
    translate(table[2])
    sethue("black")
    fontface("MacklinVariable_Slab-Black")
    fontsize(120)
    Luxor.textbox(["Data", "Science"], O - (0, 80), leading=90)
    finish()
    preview()
end

drawicon()
drawlogo()
