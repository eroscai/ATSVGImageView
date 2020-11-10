# Rounded Irregular Shape

[中文说明](https://github.com/eroscai/ATSVGImageView/wiki/%E7%BB%98%E5%88%B6%E4%B8%8D%E8%A7%84%E5%88%99%E5%BD%A2%E7%8A%B6%E7%9A%84-ShapeLayer%EF%BC%8C%E8%BF%98%E5%8F%AF%E4%BB%A5%E5%B8%A6%E5%9C%86%E8%A7%92%E5%93%A6)

How to draw irregular shapes easily?

- Convert irregular shapes into SVG image
- Parse SVG image to UIBeizerPath(via [PocketSVG](https://github.com/pocketsvg/PocketSVG))
- Create ShapeLayer with UIBeizerPath

How to add rounded corners to irregular shapes？

- Parse (CGPoint, CGPathElementType) from CGPath
- Caculate radius for each line type points
- Add arc to these points
- Integrate all to generate new UIBeizerPath

Done!

![demo](./demo.gif)

For more details please run DEMO project.