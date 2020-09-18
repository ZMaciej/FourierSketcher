class SvgFourier
{
    constructor(svgDocument)
    {
        this.svg = svgDocument;
    }

    GenerateFourierVectors(Rank, Length, Direction)
    {
        var points = this.#getPoints(Rank);
        this.Size = {
            Width: points.Width, Height: points.Height
        };
        let fft = new FFT(points.Points);
        fft.Compute();
        this.FourierVectors = new CircleFourierVectors(fft.resultSeries, Length, Direction);
    }

    #getPoints(Count)
    {
        var path = d3.select(this.svg).select('path').node();
        if (path == null || Count == null || Count == 0)
        {
            return null;
        }
        var l = path.getTotalLength();
        var points = new Array();
        var xMin = Infinity;
        var xMax = -Infinity;
        var yMin = Infinity;
        var yMax = -Infinity;
        for (let i = 0; i < Count; i++)
        {
            var point = path.getPointAtLength((i * l) / Count);
            if (xMin > point.x)
                xMin = point.x;
            if (xMax < point.x)
                xMax = point.x;
            if (yMin > point.y)
                yMin = point.y;
            if (yMax < point.y)
                yMax = point.y;
            points.push(point);
        }
        var width = (xMax - xMin);
        var height = (yMax - yMin);
        var scaleFactor;
        if (width > height)
            scaleFactor = width;
        else
            scaleFactor = height;

        //normalizing centering and mapping to Complex
        for (let i = 0; i < points.length; i++)
        {
            var x = (points[i].x - (xMin + width / 2)) / scaleFactor;
            var y = (points[i].y - (yMin + height / 2)) / scaleFactor;
            points[i] = new Complex(x, y);
        }
        return new ComplexPointsPath(points, width / scaleFactor, height / scaleFactor);
    }
}