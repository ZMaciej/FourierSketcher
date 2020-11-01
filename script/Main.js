const paths = new Array("Loading", "Loading2", "Fourier", "Poland", "Square", "World");
var fourierSvgs = {};
var currentPath = 0;
var Canvas = null;
var FourierAnimator = null;
var OnResizeHandlers = new Array();
var fourierResolution = 256;
window.onload = function ()
{
    window.onresize = OnResize;
    setup();
    setupSidebar();
    setupSidebarSvgs();
    window.setInterval(Refresh, 1000.0 / 60.0); // 60fps =  1s / 60frames
};
// window.onclick = function ()
// {
//     currentPath = (currentPath + 1) % paths.length;
//     getSVG(null, paths[currentPath], onSVGload);
// };

var CurrentSvgFourier;

function OnResize()
{
    OnResizeHandlers.forEach(action =>
    {
        action.handler(action.caller);
    });
}

function setup()
{
    Canvas = new CanvasHolder();
    getSVG(null, paths[currentPath], onSVGload);
    FourierAnimator = new SvgFourierAnimator(Canvas, null, Number.MAX_SAFE_INTEGER);
}

function setupSidebarSvgs()
{
    paths.forEach(element =>
    {
        getSVG(element, element, onSideBarSvgLoad);
    });
}

function onSideBarSvgLoad(svgDocs, caller)
{
    var svg = svgDocs.documentElement;
    fourierSvgs[caller] = new SvgFourier(svg);
    $(svg).addClass('svgTab');
    $(svg).on('click', () => (FourierAnimator.SetSvgFourier(fourierSvgs[caller])));
    $('.paths')[0].appendChild(svg);
}

function Refresh()
{
    if (FourierAnimator != null)
    {
        FourierAnimator.RefreshAnimation();
    }
}

function onSVGload(svgDocs, caller)
{
    var svg = svgDocs.documentElement;
    CurrentSvgFourier = new SvgFourier(svg);
    CurrentSvgFourier.GenerateFourierVectors(fourierResolution, 2000, Rotation.Inverted);
    FourierAnimator.SetSvgFourier(CurrentSvgFourier);
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