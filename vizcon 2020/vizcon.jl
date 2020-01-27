using FFTW, Luxor, Images, TestImages, Colors

function fourierfill(w, h, F)
    @layer begin
        a = CartesianIndices(F)
        for i in a
            re, im = F[i].re, F[i].im
            sethue(LCHab(70, 80, rescale(re, -8, 8, 0, 255)))
            r, c = Tuple(i)
            pt = Point(-w/2 + c, -h/2 + r)
            t = mask(pt, O, w, h, easingfunction=easeoutquad)
            box(K * pt, K * t, K * t, :fill)
        end
        box(O, K , K , :fill) # it was a bug, Dave
    end
end

const w, h = 128, 128
const K = 16

function main(fname)
    img = testimage("cameraman")
    img1 = imresize(img, w, h)
    timg = fft(channelview(img1))
    # F = timg
    F = fftshift(timg)
    Drawing((K * w), (K * h), fname)
    origin()
    background("grey5")
    setline(0.25)

    @layer begin
        setopacity(0.5)
        fourierfill(w, h, F)
    end

    fontface("Archivo-Black")
    fontsize(450)
    sethue("orange")
    setline(5)

    # VIZCON
    textoutlines("VIZCON", O, halign=:center,:path)
    clip()
    fourierfill(w, h, F)
    clipreset()
    textoutlines("VIZCON", O, halign=:center,:stroke)

    # BERLIN
    textoutlines("BERLIN", O + (0, 340), halign=:center,:path)
    clip()
    fourierfill(w, h, F)
    clipreset()
    textoutlines("BERLIN", O + (0, 340), halign=:center,:stroke)

    # Julia
    @layer begin
        setopacity(1.0)
        translate(0, -650)
        scale(2.5)
        translate(-165, -125)
        julialogo()
    end

    # date
    sethue("white")
    fontsize(100)
    setopacity(0.75)
    texttrack("MARCH 12-16 2020", O + (-900, 600), 500, 100)

    # url
    fontsize(60)
    fontface("ArchivoNarrow-Bold")
    setopacity(1)
    te = textextents("Visit discourse.julialang.org/tag/plotting")
    texttrack("Visit discourse.julialang.org/tag/plotting", O + (-te[3], 900), 365, 60)

    finish()
    preview()
end

main("/tmp/vizcon.svg")
