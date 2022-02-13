using Luxor


		# svg file to convert:
		
svgf = readsvg("input.svg")

aspectratio = svgf.width/svgf.height

W = 1200
        # width height pathname:
        
Drawing(W, W ÷ aspectratio, "output.png")
origin()
scale(max(Luxor.current_width(), Luxor.current_height())/max(svgf.width, svgf.height))
placeimage(svgf, centered=true)
finish()
preview()
