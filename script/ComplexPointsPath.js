class ComplexPointsPath
{
    constructor(points, width, height)
    {
        this.Points = points;
        this.Width = width;
        this.Height = height;
    }
    Scale(factor)
    {
        for (let i = 0; i < this.Points.length; i++)
        {
            this.Points[i] = { x: this.Points[i].x * factor, y: this.Points[i].y * factor }
        }
        this.Width *= factor;
        this.Height *= factor;
    }
}