using Luxor, Colors

let
    cols = [Luxor.julia_red, Luxor.julia_green, Luxor.julia_purple]
    Drawing(500, 500,  "/tmp/turing.svg")
    origin()
    sethue("grey5")
    circle(O, 245, :fillpreserve)
    circle(O, 245, :clip)

    translate(-80, 100)

    k = 140 # widens the curve
    h = 130 # height of curve
    redcurve = [Point(k * x, -h * exp(-x^2)) for x in   -10:0.01:10]
    greencurve = [Point(0.65k * x, -250 * exp(-x^2)) for x in -10:0.01:10]
    purplecurve = [Point(0.5k * x, -120 * exp(-x^2)) for x in -10:0.01:10]

    # curves need shifting ↔
    polymove!(greencurve, O, Point(100, 0))
    polymove!(purplecurve, O, Point(240, 5))

    # the thickening
    g(x, θ) = rescale(abs(sin(θ) * sin(θ)), 0, 1, 8, 12)

    for (i, thecurve) in enumerate([redcurve, greencurve, purplecurve])
        @layer begin
            pgon = offsetpoly(thecurve, g)
            poly(pgon, :clip)
            for j in 0:0.1:1
                c = convert(HSB, RGB(cols[i]...))
                sethue(HSB(c.h, 0.8, rescale(j, 0, 1, 0.4, 1.0)))
                setline(20-20j)
                poly(thecurve, :stroke)
            end
        end
    end
    clipreset()
    origin()
    setline(10)
    sethue(0.78, 0.88, 0.95)
    circle(O, 240, :stroke)
    finish()
    preview()
end
