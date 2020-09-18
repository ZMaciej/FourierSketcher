const paths = new Array("Loading", "Loading2", "Fourier", "Poland", "Square", "Woman", "World", "FacePath");
var currentPath = 0;
window.onload = function ()
{
    this.setup();
    window.setInterval(RefreshAnimation, 1000.0 / 60.0); // 60fps =  1s / 60frames
    window.onresize = ScreenResized;
};
window.onclick = function ()
{
    currentPath = (currentPath + 1) % paths.length;
    getSVG(null, paths[currentPath], onSVGload);
};
var Canvas;
var CanvasContext;
var ScreenSize;
var CurrentSvgFourier;
var ImageScaleBias = { Scale: 0, Bias: { x: 0, y: 0 } };

function setup()
{
    Canvas = document.createElement("canvas");
    document.body.appendChild(Canvas);
    ScreenSize = { Width: window.innerWidth, Height: window.innerHeight };
    Canvas.width = ScreenSize.Width;
    Canvas.height = ScreenSize.Height;
    CanvasContext = Canvas.getContext('2d');
    getSVG(null, paths[currentPath], onSVGload);
}
var Margin = 50;

function RefreshAnimation()
{
    CanvasContext.clearRect(0, 0, ScreenSize.Width, ScreenSize.Height);
    if (CurrentSvgFourier != null && CurrentSvgFourier.FourierVectors != null)
    {
        CurrentSvgFourier.FourierVectors.NextVector(512);
        CanvasContext.beginPath();
        var first = CurrentSvgFourier.FourierVectors.CurrentVector[0];
        CanvasContext.moveTo(first.GlobalEndPoint.Re * ImageScaleBias.Scale + ImageScaleBias.Bias.x, first.GlobalEndPoint.Im * ImageScaleBias.Scale + ImageScaleBias.Bias.y);
        for (let i = 1; i < 512; i++)
        {
            const el = CurrentSvgFourier.FourierVectors.CurrentVector[i].GlobalEndPoint;
            CanvasContext.lineTo(el.Re * ImageScaleBias.Scale + ImageScaleBias.Bias.x, el.Im * ImageScaleBias.Scale + ImageScaleBias.Bias.y);
        }
        CanvasContext.lineWidth = 2;
        CanvasContext.strokeStyle = 'black';
        CanvasContext.lineJoin = "round";
        CanvasContext.stroke();

        CanvasContext.beginPath();
        var first = CurrentSvgFourier.FourierVectors.Path[0];
        CanvasContext.moveTo(first.Re * ImageScaleBias.Scale + ImageScaleBias.Bias.x, first.Im * ImageScaleBias.Scale + ImageScaleBias.Bias.y);
        for (let i = 0; i < CurrentSvgFourier.FourierVectors.Path.length; i++)
        {
            const el = CurrentSvgFourier.FourierVectors.Path[i];
            CanvasContext.lineTo(el.Re * ImageScaleBias.Scale + ImageScaleBias.Bias.x, el.Im * ImageScaleBias.Scale + ImageScaleBias.Bias.y);
        }

        CanvasContext.lineWidth = 2;
        CanvasContext.strokeStyle = 'black';
        CanvasContext.lineJoin = "round";
        CanvasContext.stroke();
    }
    //CanvasContext.fillRect(0, 0, ScreenSize.Width, ScreenSize.Height);
    // ctx.fillStyle = 'RGBA(105, 105, 105, 0.8)';
}

function ScreenResized()
{
    ScreenSize = { Width: window.innerWidth, Height: window.innerHeight };
    Canvas.width = ScreenSize.Width;
    Canvas.height = ScreenSize.Height;
    ComputeImageScaleBias();
}

function ComputeImageScaleBias()
{
    if (CurrentSvgFourier != null)
    {
        if ((CurrentSvgFourier.Size.Width / CurrentSvgFourier.Size.Height) > (ScreenSize.Width - (2 * Margin)) / (ScreenSize.Height - (2 * Margin)))
        {
            var scale = (ScreenSize.Width - (2 * Margin)) * (1 / CurrentSvgFourier.Size.Width);
            ImageScaleBias = { Scale: scale, Bias: { x: ScreenSize.Width / 2, y: ScreenSize.Height / 2 } };
        }
        else
        {
            var scale = (ScreenSize.Height - (2 * Margin)) * (1 / CurrentSvgFourier.Size.Height);
            ImageScaleBias = { Scale: scale, Bias: { x: ScreenSize.Width / 2, y: ScreenSize.Height / 2 } };
        }
    }
}

function onSVGload(svgDocs, caller)
{
    var svg = svgDocs.documentElement;
    CurrentSvgFourier = new SvgFourier(svg);
    CurrentSvgFourier.GenerateFourierVectors(512, 2000, Rotation.Inverted);
    ComputeImageScaleBias();
}

function Create2DArray(dim1, dim2)
{
    var twoDimArray = new Array(dim1);
    for (var i = 0; i < twoDimArray.length; i++)
    {
        twoDimArray[i] = new Array(dim2);
    }
    return twoDimArray;
}

/** 
 * @param {object} caller 
 * @param {String} name 
 * @param {function(document ,callerObject)} callback 
 * @param {String} JWT
 */
function getSVG(caller, name, callback)
{
    var xhr = new XMLHttpRequest();
    xhr.open('GET', "paths/" + name + ".svg", true);
    xhr.responseType = "document";
    xhr.onerror = function ()
    {
    };
    xhr.onload = function ()
    {
        var status = xhr.status;
        if (status === 200 && xhr.response != null)
        {
            callback(xhr.response, caller);
        } else
        {
            console.log("cannot load document " + xhr.responseURL);
        }
    };
    xhr.send();
}