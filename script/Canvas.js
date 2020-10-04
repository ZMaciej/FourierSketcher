class CanvasHolder
{
    #canvasDocumentElement = null;
    constructor()
    {
        this.OnCanvasContextChangeHandlers = new Array();
        this.#canvasDocumentElement = document.createElement("canvas");
        this.CanvasContext = this.#canvasDocumentElement.getContext('2d');
        this.CanvasSize = { Width: window.innerWidth, Height: window.innerHeight };
        this.#canvasDocumentElement.width = this.CanvasSize.Width;
        this.#canvasDocumentElement.height = this.CanvasSize.Height;
        document.body.appendChild(this.#canvasDocumentElement);
        this.#setDPI(window.devicePixelRatio || 1);
        OnResizeHandlers.push({ handler: this.#screenResized, caller: this });
    }

    #screenResized(that)
    {
        that.CanvasSize = { Width: window.innerWidth, Height: window.innerHeight };
        that.#canvasDocumentElement.width = that.CanvasSize.Width;
        that.#canvasDocumentElement.height = that.CanvasSize.Height;
        that.#setDPI(window.devicePixelRatio || 1);
    }

    #setDPI(dpi)
    {
        // Set up CSS size.
        this.#canvasDocumentElement.style.width = this.CanvasSize.Width + 'px';
        this.#canvasDocumentElement.style.height = this.CanvasSize.Height + 'px';

        // Get size information.
        var scaleFactor = dpi;
        var width = parseFloat(this.#canvasDocumentElement.style.width);
        var height = parseFloat(this.#canvasDocumentElement.style.height);

        // Resize the canvas.
        //this.CanvasContext = this.#canvasDocumentElement.getContext('2d');
        this.#canvasDocumentElement.width = Math.ceil(width * scaleFactor);
        this.#canvasDocumentElement.height = Math.ceil(height * scaleFactor);

        this.CanvasContext.setTransform(scaleFactor, 0, 0, scaleFactor, 0, 0);
        this.#onCanvasContextChange();
    }

    #onCanvasContextChange()
    {
        this.OnCanvasContextChangeHandlers.forEach(action =>
        {
            action.handler(action.caller);
        });
    }
}