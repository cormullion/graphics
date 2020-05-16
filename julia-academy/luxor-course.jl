# ## Introduction to vector graphics with Luxor.jl

# This course is a short introduction to making vector graphics. By the end of this course you will have learnt quite a bit about how to use Luxor to make vector graphics, and started making some cool images.

# Luxor.jl is a simple package designed to make *vector graphics*, which are pictures made out of colored lines and curves, plus any text. Luxor produces PNG, SVG, and PDF files; PDF and SVG are resolution-independent formats, so you can scale them up or down as much as you like without losing detail. PNG files are, like photos and JPEG images, made at a specific resolution.

# Luxor sits in the space between the heavy-duty Julia plotting packages such as Plots.jl, Gadfly, and Pyplot (among others), and applications such as Inkscape and Adobe Illustrator. Like Plots.jl et al, you specify what you want to draw with Julia functions and parameters using code, rather than by clicking and pointing at the screen with a mouse or trackpad. Like Inkscape/Illustrator, you have the task of specifying every shape and color you want in your final drawing, rather than having the software do everything for you.

# If you've learnt a bit about Julia already, and if you can remember some of the geometry you learned at school (angles, coordinates, and so on), you know enough to get started. To install Luxor, use the Julia package manager:

## using Pkg
## Pkg.add("Luxor")

# # Chapter 1: The first task: design a logo

# The new (and currently fictitious) organization JuliaFission has just asked you to design a new logo for them. They're something to do with atoms and particles, perhaps? So we'll design a new logo for them using some basic shapes; perhaps colored circles in some kind of spiral formation would look suitably "atomic". Let's try out some ideas.

# ### A first drawing

using Luxor

Drawing(500, 500, "my-drawing.png")
origin()
setcolor("red")
circle(Point(0, 0), 100, :fill)
finish()
preview()

# is short piece of code does the following things:

# - Makes a new drawing 500 units square, and saves it in "my-drawing.png" in PNG format.

# - Moves the zero point from the top left to the center. Graphics applications often start measuring from the top left (or bottom left), but it's easier to work out the positions of things if you start at the center.)

# - Selects one of the 200 or so named colors (defined [here](http://juliagraphics.github.io/Colors.jl/stable/))

# - Draws a circle at x = 0, y = 0, with radius 100 units, and fills it with the current color.)

# - Finishes the drawing and displays it on the screen.

# In case you're wondering, the units are *points* (as in font sizes), and there are 72 points in an inch, just over 3 per millimeter. The y-axis points down the page, by the way. If you want to be reminded of where the x and y axes are, uses the `rulers()` function.

# The `:fill` at the end of `circle()` is one of a set of symbols that lets you display the shape in different ways. There's also `:stroke`, which draws around the edges but doesn't fill the shape with color. You might also meet `:path`, `fillpreserve`, `strokepreserve`, `clip`, and `:none`.

# ### Circles in a spiral

# We want more than just one circle. We'll define a triangular shape, and place circles at each corner. The `ngon()` function creates regular polygon (eg triangles, squares, etc.), and the `vertices=true` keyword returns the corner points - just what we want.

Drawing(500, 500, "my-drawing.png")
origin()
setcolor("red")
corners = ngon(Point(0, 0), 80, 3, vertices=true)
circle.(corners, 10, :fill)
finish()
preview()

# Notice the "." after `circle`. This broadcasts the `circle()` function over the `corners`, drawing a red filled circle at every point.

# The arguments to `ngon` are centerpoint, radius, and number of sides. Try changing the third argument from 3 to 4 or 33.

# To create a spiral of circles, we want to repeat this `ngon`...`circle` part more than once. A simple loop will do: we'll rotate everything by `i * ` 5° (`deg2rad(5)` radians) each time (so 5°, 10°, 15°, 20°, 25°, and 30°), and increase the size of the shape by multiples of 10:

Drawing(500, 500, "my-drawing.png")
origin()
setcolor("red")
for i in 1:6
    rotate(i * deg2rad(5))
    corners = ngon(Point(0, 0), 80 + 10i, 3, vertices=true)
    circle.(corners, 10, :fill)
end
finish()
preview()

# ### Just add color

# The Julia colors are available as constants in Luxor, so we can make two changes that cycle through them. The first line creates the set of colors; the `setcolor()` function then works through them. `mod1()` is the 1-based `mod` function, essential for working with Julia and its 1-based indexing.

const colors = (Luxor.julia_green, Luxor.julia_red,Luxor.julia_purple, Luxor.julia_blue) ### <-
Drawing(500, 500, "my-drawing.png")
origin()
for i in 1:6
    setcolor(colors[mod1(i, end)]) ### <-
    rotate(i * deg2rad(5))
    corners = ngon(Point(0, 0), 80 + 10i, 3, vertices=true)
    circle.(corners, 10, :fill)
end
finish()
preview()

# ## Taking particles seriously

# The flat circles are a bit dull, so let's write a function that takes circles seriously. The `drawcircle()` function draws lots of circles, but each one is drawn with a slightly smaller radius and a slightly lighter shade of the incoming color. The `rescale()` function in Luxor provides an easy way to map or adjust values from one range to another; here, numbers between 5 and 1 are mapped to numbers between 0.5 and 3. And the radius is scaled to run between `radius` and `radius/6`. Also, let's make them get larger as they spiral outwards, by adding `4i` to the radius when called by `drawcircle()`.

function drawcircle(pos, radius, n) ## <-
    c = colors[mod1(n, end)]
    for i in 5:-0.1:1
        setcolor(rescale(i, 5, 1, 0.5, 3) .* c)
        circle(pos + (i/2, i/2), rescale(i, 5, 1, radius, radius/6), :fill)
    end
end

Drawing(500, 500, "my-drawing.png")
    origin()
    for i in 1:6
        rotate(i * deg2rad(5))
        corners = ngon(Point(0, 0), 80 + 10i, 3, vertices=true)
        drawcircle.(corners, 10 + 4i, i) ## <-
    end
    finish()
    preview()

# This is looking quite promising. But here's the thing: in a parallel universe, you might already have made this in no time at all using Adobe Illustrator or Inkscape. But with this Luxor code, you can try all kinds of different variations with almost immediate results - just walk through the parameter space, either manually or via code, and see what effects you get. You don't have to redraw everything with different angles and radii...

# So here's what a pentagonal theme with more circles looks like:

Drawing(500, 500, "my-drawing.png")
origin()
for i in 1:12
    rotate(i * deg2rad(1.5))
    corners = ngon(Point(0, 0), 10 + 12i, 5, vertices=true)
    drawcircle.(corners, 5 + 2i, i)
end
finish()
preview()

# To tidy up, it's a good idea to move the code into functions, and do a bit of housekeeping. The final script looks like this:

using Luxor

const colors = (Luxor.julia_green, Luxor.julia_red,Luxor.julia_purple, Luxor.julia_blue)

function drawcircle(pos, radius, n)
    c = colors[mod1(n, end)]
    for i in 5:-.1:1
        setcolor(rescale(i, 5, 1, 0.5, 3) .* c)
        circle(pos + (i/2, i/2), rescale(i, 5, 1, radius, radius/6), :fill)
    end
end

function main(filename)
    Drawing(500, 500, filename)
    origin()
    for i in 1:12
        rotate(i * deg2rad(1.5))
        corners = ngon(Point(0, 0), 10 + 12i, 5, vertices=true)
        drawcircle.(corners, 5 + 2i, i)
    end
    finish()
    preview()
end

main("my-drawing.svg")

# To create a high-quality resolution-independent SVG, just change the suffix from ".png" to ".svg"

# So, did the JuliaFission organization like their logo? Who knows!? But if not, we can always recycle some of these ideas for future projects.

# ### Challenges

# Before you move on to the next chapter, perhaps you'd like to take an extra challenge or two?

# #### 1. Remember the random values

# Using random numbers is a great way to find new patterns and shapes; but unless you know what the values are, you can't reproduce them. So modify the code so that the random numbers are remembered, and drawn on the screen (you can use the `text(str, position)` function),

# #### 2. Backgrounds

# Because there's no background, the SVG or PNG image created will have a transparent background. This is usually what you want for an icon or logo. But this design might look good against a darker colored background. Use `background()` or `paint()` and experiment.

# #### 3. Randomize

# Try refactoring your code so that you can automatically run through various parameter ranges.

# # Chapter 2: Interactive geometry

# Circles, lines, arcs, and polygons are the fundamental particles of Luxor. One way to explore some of the features is to use the interactive abilities of a Jupyter notebook.

# You'll need to add the Interact.jl package if you haven't already done so:

# using Pkg

# Pkg.add("Interact")

import Interact: @manipulate

# Interact.jl has a `@manipulate()` macro that provides a slider. This feeds a changing numeric value into the Luxor code that's generating the image. Because we don't want to generate thousands of images for the slider positions, we'll use the in-memory (file-less) version of the `Drawing()` function with the `:svg` option, assign the drawing to `d`, and then return `d` as the result. (You must run this in Jupyter, not Atom/Juno or VS Code.)

@manipulate for r1 in 80:200, r2 in 80:200
    d = Drawing(500, 500, :svg)
    origin()
    sethue("black")
    circle(Point(-100, 0), r1, :stroke)
    circle(Point(100, 0), r2, :stroke)
    flag, ip1, ip2 = intersectioncirclecircle(Point(-100, 0), r1, Point(100, 0), r2)

    if flag
        sethue("red")
        circle(ip1, 12, :fill)
        sethue("green")
        circle(ip2, 10, :fill)
    end
    finish()
    return d
end

# The mathematics going on behind the scenes here avoids the situation when there is a single intersection point, probably because it would demand too much accuracy from the floating-point routines involved. Simple graphics aren't perfectly accurate!

# ## Sample size

# Now let's investigate the `polysample()` function, a useful tool that creates new versions of polygons by "sampling" them a given number of times. First we create a regular polygon, using `ngonside()` rather than `ngon()`, with `nsides` sides and a side length of 100. Then we sample the polygon `s` times.

@manipulate for s in 3:100, nsides=3:12
    d = Drawing(500, 500, :svg)
    origin()
    sethue("black")
    pgon = ngonside(Point(0, 0), 100, nsides, vertices=true)

    ## resample it
    psampled = polysample(pgon, s)

    ## draw the new polygon
    prettypoly(psampled, :stroke, close=true)

    ## show perimeter values
    text(string(polyperimeter(psampled)), halign=:center)
    text(string(polyperimeter(pgon)), Point(0, 40), halign=:center)

    finish()
    return d
end

# We used the `prettypoly()` function to apply a stroke to the sampled polygon. It's called `prettypoly()` because it automatically highlights the vertices for you with small circles - very useful when you're working with unfamiliar polygons.

# We've also introduced the `text(str, pt)` function, that draws a string of text at a point.

# Notice that at low sampling rates (low `s` values) the shape is rendered approximately rather than accurately.

# ## Pretty poly

# With a few changes we can see some more of `prettypoly()` in action. Let's get rid of the sampling, and just vary the size of the polygons drawn at the vertices of the original `pgon`. We pass an *anonymous function* that is applied at each vertex, allowing us to apply any sequence of graphics instructions at each vertex in turn. In this case we select a color at random, draw another polygon centered at the vertex, then outline it in black.

@manipulate for nsides in 3:12, sidelength in 40:80
    d = Drawing(500, 500, :svg)
    origin()
    setopacity(0.6)
    sethue("black")
    pgon = ngonside(Point(0, 0), sidelength, nsides, 0, vertices=true)
    prettypoly(pgon, :none, close=true, () ->
        begin
            randomhue()
            ngon(O, sidelength, nsides, 0, :fillpreserve)
            sethue("black")
            strokepath()
        end)
    finish()
    d
end

# The letter `O` is a short-cut for `Point(0, 0)`. The anonymous function runs after the x and y axes have been moved to the position of the vertex, and therefore all graphics are applied relative to the vertex position.

# ## Specifying locations

# It's useful to be able to refer to specific points on a drawing. To help you do this, there are functions such as `midpoint()` and `between()`, among many others. There are also functions for working with *bounding boxes*, which rectangular areas defined by two opposite corners.

# `BoundingBox()` is a constructor which returns the rectangular extent of various things, such as, in this case, the entire drawing. Multiplying by `k` reduces its size.

# The `between()` function takes two points and a number between 0.0 and 1.0, and finds the point at that interval between them. Here, it's broadcasting over a range, finding 11 points between 0.0 and 1.0, ready for `circle()` to use.

@manipulate for k in 0:0.1:1.0
    d = Drawing(500, 500, :png)
    origin()

    bbox = BoundingBox() * k
    box(bbox, :stroke) ## quick way to draw around a bounding box

    ## draw circles between top left and bottom right corner
    circle.(between.(bbox..., 0:0.1:1.0), 5, :stroke)

    sethue("red")
    ## refer the top left corner of the bounding box
    circle(boxtopleft(bbox), 10, :fill)
    finish()
    return d
end

# A bounding box provides nine useful 'named' positioning functions: `boxtopleft()`, `boxmiddleright()`, and so on.

# ### Challenges

# #### 1. More exploring

# Other interesting Luxor functions to explore might be `rule()`, which can be told to keep the lines inside a bounding box, `pointinverse()`, `intersectionlinecircle()`, and `intersectboundingboxes()`, to name a few.

# # Chapter 3: Conference badges; placing text

# Remember when people used to attend conferences in person, and they'd wear badges to help identify themselves to others? Some day soon, perhaps, we'll be doing it again. Until then, we can work on a useful application for Luxor that will generate these badges automatically. Given a DataFrame containing the details of attendees, Luxor can process the rows and create a unique badge for each person.

# If you want to follow along, install DataFrames.jl, and download the free [Barlow Condensed](https://fonts.google.com/specimen/Barlow+Condensed) font from Google Fonts, because we want a strong but narrow font for the confined space of a badge.

using DataFrames, Colors

# Let's quickly define a few arbitrary attendees (any resemblance to real individuals or companies is unintended):

attendees = DataFrame(
    FirstName      =   ["Alice", "Bob", "Chuck", "Damian", "Elizabeth", "Jacquelinetta", "Gus"],
    LastName       =   ["Blackwood", "Greybeard", "Whitehat", "Gryffindor", "van Purple", "Magickata", "McTurquoisepherson" ],
    Organization   =   ["Avocado Corp",
                        "Sirius Cybernetics Corporation",
                        "Institute of Conference Badge Designers",
                        "Umbrella Corporation",
                        "Abstergo Industries",
                        "Cyberdyne Systems",
                        "Acme Industries"],
    URL            =   ["www.avocadocorp.com"
                         "www.siriuscyberneticscorporation.com"
                         "www.instituteofconferencebadgedesigners.com"
                         "www.umbrellacorporation.com"
                         "www.abstergoindustries.com"
                         "www.cyberdynesystemscorporation.com"
                         "www.acme.com"])

# Some useful information:

const conference_name = "Dark Matters"
const conference_year = "2020"
const card_dimensions = (298, 420)

struct Attendee
    firstname:: String
    lastname:: String
    organization:: String
    url:: String
end

# Luxor provides a few ways to divide up the drawing area, and two useful ones are Tilers and Tables. A Tiler constructor divides up a specified area into identical rectangular tiles; a Table constructor makes rows and columns, but each row can be a different height, and each column can be a different width. The Table constructor can accepts rows/columns, or vectors defining row and column heights. For this task, we'll define a table with 1 column, and 8 rows, and a bit of sketching and experimentation suggests the following row heights.

table = Table([100, 5, 90, 50, 40, 40, 5, 90], [298])

# This quick test shows the basic structure:

Drawing(card_dimensions..., "testcard.svg")
origin()
sethue("black")
for (pos, n) in table
    box(pos, table.colwidths[1], table.rowheights[n], :stroke)
    circle(pos, 4, :fill)
end
finish()
preview()

# The four pieces of information for each attendee are to be placed in table rows 3, 4, 5, and 6. Let's try it out. The throwaway `test_draw_attendee()` function takes a single row of the DataFrame and draws the four pieces of text in these four table cells.

function test_draw_attendee(a, table)
    person = Attendee(a...)
    Drawing(card_dimensions..., "/tmp/testcard-$(person.firstname)-$(person.lastname).png")
    origin()
    sethue("green")
    for (pos, k) in table
        box(pos, table.colwidths[1], table.rowheights[k], :stroke)
    end
    sethue("red")
    text(person.firstname,    table[3])
    text(person.lastname,     table[4])
    text(person.organization, table[5])
    text(person.url,          table[6])
    finish()
    preview()
end

test_draw_attendee(attendees[1, :], table)

# This looks structurally OK. But it's not very appealing visually, so the main job now is to place the text more carefully and use some color.

# We'll make a custom text-drawing function. This draws the text in `str`, and tries to use the font and font size supplied to fit in a space `w` by `h`. But, if the text would be too wide, the font size is reduced until it fits. We can use the `textextents()` function for this, because it returns a useful list of all the dimensions of the text with the current settings.

function drawtext(str, pos, w, h;
        margin=20,
        fsize=20,
        fface="BarlowCondensed-Bold",
        fground = colorant"black",
        bground = colorant"white",
        halignment = :left)
    fontface(fface)
    fontsize(fsize)
    ## check and recalculate if necessary
    textwidth = textextents(str)
    if textwidth[3] > (w - 2margin)
        fs = fsize
        while(textwidth[3] > (w - 2margin))
            fs -= 2
            fontsize(fs)
            textwidth = textextents(str)
        end
        fontsize(fs)
    end
    ## paint the box
    sethue(bground)
    box(pos, w, h, :fillstroke)
    sethue(fground)
    ## allow for centered text
    if halignment == :left
        text(str, pos - (w/2 - margin, 0), halign=:left, valign=:middle)
    else
        text(str, pos - (w/2 - margin, 0), valign=:middle)
    end
end


# Finally, this function draws a single badge. It's mostly calls to `drawtext()`, adding some graphics before and after:

function draw_attendee(a, table)
    person = Attendee(a...)
    Drawing(card_dimensions..., "/tmp/testbadge-$(person.firstname)-$(person.lastname).svg")
    origin()
    background("white")
    sethue("black")
    w = table.colwidths[1]

    @layer begin
        sethue("black")
        box(table, 1, :fill)

        ## dividers
        sethue("red")
        box(table, 2, :fill)
        box(table, 7, :fill)
    end

    drawtext(person.firstname, table[3], w, table.rowheights[3],
        fsize=70, fface="BarlowCondensed-Black",
        fground = "white",
        bground = HSV(230, .8, .2))
    drawtext(person.lastname, table[4], w, table.rowheights[4],
        fsize=40, fface="BarlowCondensed-Bold",
        fground = "white",
        bground = HSV(230, .8, .2))
    drawtext(person.organization, table[5], w, table.rowheights[5],
        fsize=30, fface="BarlowCondensed-Bold",
        fground = "white",
        bground = HSV(230, .6, .5))
    drawtext(person.url, table[6], w, table.rowheights[6],
        fsize=20, fface="BarlowCondensed-Bold",
        fground = "white",
        bground = HSV(230, .5, .7))

    ## what conference is this anyway?
    drawtext(uppercase(conference_name) * "∞" * conference_year, table[8], table.colwidths[1], table.rowheights[8],
        fsize=40, fface="BarlowCondensed-Black",
        fground = "black",
        bground = "darkorange",
        halignment=:center)

    ## final decoration
    @layer begin
        translate(table[1])
        setopacity(0.3)
        setline(0.5)
        sethue("white")
        epitrochoid(200, 31, 250, :stroke)
        end

    finish()
    preview()
end

# Each one can be checked individually:

#-

function testone()
    draw_attendee(attendees[6, :], table)
end

testone()

#-

# And then we can generate them all:

function testall()
    for r in eachrow(attendees)
        println("printing $(r.FirstName * " " * r.LastName)")
        draw_attendee(r, table)
    end
end

testall()

# ### Challenges

# #### 1. Add a QR code

# Adding a QR code to each badge sounds like fun. You can find a nice Julia QR code package [here](https://github.com/jiegillet/QRCode.jl). It's easy enough to generate a grid of black and white squares using Luxor's Table or Tiler objects.

# #### 2. Logos

# People love adding logos to conference-related material. Try adding some to the design. If the logo is provided as a PNG image, you can use Luxor's `readpng()` and `placeimage()` functions. Otherwise you might have to incorporate Luxor code to reproduce the desired logo, because there's no PDF/EPS/SVG import tools. Luckily the Julia logo has already been done.

# #### 3. Provide printer-friendly masters

# We've made a separate image for each badge. But often you would send larger sheets containing four to six badges (possibly complete with crop marks) to the print shop, so that they could run them through their machines and then trim them. So you could refactor the code so that it fits four or six badges on a suitably larger sheet. Perhaps the PDF format is going to be more useful here.

# # Chapter 4: Generative art

# You can make art with anything - these days you might not even need a pencil. Luxor has plenty of tools to help you make some art. The phrase "generative art" suggests that the computer code does most of the work generating the image; perhaps the presence of your guiding hand justifies you claiming to be co-creator.

# You need only have a basic idea to get started. If it doesn't go anywhere, then you just start over. The idea for this chapter is based on a random walk: you place a simple linei and circle ("blob") graphic next to other ones, and use randomness to see what emerges.

using Colors

# A simple Blob structure holds start and end points, and keeps track of a color and a radius.

struct Blob
   st::Point
   fi::Point
   col::Colorant
   radius::Float64
end

# This is a place to store Blobs:

todolist = Blob[]

# This function takes an existing Blob object, and returns a new one that's slightly different. Its color, direction, and radius are randomly shifted. A call to `rand(1:10)` introduces some different behaviour: the new Blob is either placed alongside an existing one, or it's attached to the end:

function mutate(blob::Blob)
   currentcol = convert(HSV, blob.col)
   newcol = HSV(mod(currentcol.h + rand(-4:4), 360),
        mod(currentcol.s + 0.1, 1),
        mod(currentcol.v + 0.1, 1))
   newradius = mod(rand(Bool) ? blob.radius * 1.1 : blob.radius * 0.9, 20)
   newdirection = slope(blob.st, blob.fi) + rand(-1:0.1:1) * (π/5 * rand())
   if rand(1:10) < 5
      return Blob(blob.fi, blob.fi + polar(rand(5:10), newdirection), newcol, newradius)
   else
      return Blob(blob.st, blob.st + polar(rand(5:10), newdirection), newcol, newradius)
   end
end

# The `draw()` function draws the blob, and adds new mutated blobs, but only if they're still on the drawing.

function draw(blob::Blob, todolist)
   move(blob.st)
   line(blob.fi)
   setline(4)
   sethue(blob.col)
   strokepath()
   circle(blob.fi, blob.radius, :fill)
   ## add new blobs if they're on the drawing
   if isinside(blob.fi, BoundingBox())
      push!(todolist, mutate(blob))
   end
end

function draw(blob::Blob, todolist)
    move(blob.st)
    line(blob.fi)
    setline(4)
    sethue(blob.col)
    strokepath()
    circle(blob.fi, blob.radius, :fill)
    ## add new blobs if they're on the drawing
    if isinside(blob.fi, BoundingBox())
        push!(todolist, mutate(blob))
    end
end

# Because each walk only goes in one direction, a better balanced image is achieved by stacking a dozen images with varying opacities.

# The results are unpredictable, and - this being art - it's difficult to say whether the images are pleasing or horrible. The next time you run it, you might get a masterpiece! Or perhaps you won't...

function gen()
    Drawing(500, 500, "blobart.svg")
    origin()
    background("antiquewhite")
    for i in 1:12
      setopacity(i/12)
      seed = Blob(Point(0, 0), Point(rand(-5:5, 2)...), HSB(180, 0.5, 0.5), 10)
      push!(todolist, seed)
      while !isempty(todolist)
         draw(pop!(todolist), todolist)
      end
    end
    finish()
    preview()
end

gen()

# Fortunately "art is in the eye of the beholder", so if you like these, that's great. And if you don't, you can start thinking of different ways to coax beautiful images from Julia code!

# ## Challenges

# #### 1. Create more masterpieces

# And post your creations online!
