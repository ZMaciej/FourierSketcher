class SvgFourierAnimator
{
    #canvasContext = null;
    #canvas = null;
    #imageScaleBias = { Scale: 0, Bias: { x: 0, y: 0 } };
    constructor(canvas, svgFourier, rank)
    {
        this.#canvas = canvas;
        this.#canvasContext = canvas.CanvasContext;
        canvas.OnCanvasContextChangeHandlers.push({ handler: this.#contextChange, caller: this });
        $(canvas.CanvasContext).on('propertyChange', this.#contextChange);
        if (svgFourier != null)
        {
            this.SetSvgFourier(svgFourier);
            if (rank < svgFourier.Rank)
                this.Rank = rank;
            else
                this.Rank = svgFourier.Rank;
        }
        else
            this.Rank = rank;
    }

    SetSvgFourier(svgFourier)
    {
        if (!svgFourier.Ready)
            svgFourier.GenerateFourierVectors(256, 2000, Rotation.Inverted);
        this.SvgFourier = svgFourier;
        this.#computeImageScaleBias()
    }

    #contextChange(that)
    {
        that.#computeImageScaleBias();
    }

    #computeImageScaleBias()
    {
        var Margin = 50;
        if (this.SvgFourier != null)
        {
            if ((this.SvgFourier.Size.Width / this.SvgFourier.Size.Height) > (this.#canvas.CanvasSize.Width - (2 * Margin)) / (this.#canvas.CanvasSize.Height - (2 * Margin)))
            {
                var scale = (this.#canvas.CanvasSize.Width - (2 * Margin)) * (1 / this.SvgFourier.Size.Width);
                this.#imageScaleBias = { Scale: scale, Bias: { x: this.#canvas.CanvasSize.Width / 2, y: this.#canvas.CanvasSize.Height / 2 } };
            }
            else
            {
                var scale = (this.#canvas.CanvasSize.Height - (2 * Margin)) * (1 / this.SvgFourier.Size.Height);
                this.#imageScaleBias = { Scale: scale, Bias: { x: this.#canvas.CanvasSize.Width / 2, y: this.#canvas.CanvasSize.Height / 2 } };
            }
        }
    }

    RefreshAnimation()
    {
        var ScreenSize = this.#canvas.CanvasSize;
        if (this.Rank > this.SvgFourier.Rank)
            this.Rank = this.SvgFourier.Rank;
        this.#canvasContext.clearRect(0, 0, ScreenSize.Width, ScreenSize.Height);
        if (this.SvgFourier != null && this.SvgFourier.FourierVectors != null)
        {
            this.SvgFourier.FourierVectors.NextVector(this.Rank);
            this.#canvasContext.beginPath();
            var first = this.SvgFourier.FourierVectors.CurrentVector[0];
            this.#canvasContext.moveTo(first.GlobalEndPoint.Re * this.#imageScaleBias.Scale + this.#imageScaleBias.Bias.x, first.GlobalEndPoint.Im * this.#imageScaleBias.Scale + this.#imageScaleBias.Bias.y);
            for (let i = 1; i < this.Rank; i++)
            {
                const el = this.SvgFourier.FourierVectors.CurrentVector[i].GlobalEndPoint;
                this.#canvasContext.lineTo(el.Re * this.#imageScaleBias.Scale + this.#imageScaleBias.Bias.x, el.Im * this.#imageScaleBias.Scale + this.#imageScaleBias.Bias.y);
            }
            this.#canvasContext.lineWidth = 2;
            this.#canvasContext.strokeStyle = 'black';
            this.#canvasContext.lineJoin = "round";
            this.#canvasContext.stroke();

            this.#canvasContext.beginPath();
            var first = this.SvgFourier.FourierVectors.Path[0];
            this.#canvasContext.moveTo(first.Re * this.#imageScaleBias.Scale + this.#imageScaleBias.Bias.x, first.Im * this.#imageScaleBias.Scale + this.#imageScaleBias.Bias.y);

            for (let i = 0; i < this.SvgFourier.FourierVectors.Path.length; i++)
            {
                const el = this.SvgFourier.FourierVectors.Path[i];
                this.#canvasContext.lineTo(el.Re * this.#imageScaleBias.Scale + this.#imageScaleBias.Bias.x, el.Im * this.#imageScaleBias.Scale + this.#imageScaleBias.Bias.y);
            }
            this.#canvasContext.lineWidth = 2;
            this.#canvasContext.strokeStyle = 'black';
            this.#canvasContext.lineJoin = "round";
            this.#canvasContext.stroke();
        }
        //CanvasContext.fillRect(0, 0, ScreenSize.Width, ScreenSize.Height);
        // ctx.fillStyle = 'RGBA(105, 105, 105, 0.8)';
    }
}