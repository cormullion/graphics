using Luxor


function convert_svg_to_png(fname, width=1200)
    # svg file to convert:
    svgf = readsvg(fname)
    aspectratio = svgf.width / svgf.height
    W = width
    Drawing(W, W ÷ aspectratio, fname * ".png")
    origin()
    scale(max(Luxor.current_width(), Luxor.current_height()) / max(svgf.width, svgf.height))
    placeimage(svgf, centered = true)
    finish()
    preview()
end

map(convert_svg_to_png, filter(f -> endswith(f, ".svg"), readdir()))
