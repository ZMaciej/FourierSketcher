const Rotation = {
    Normal: 1,
    Inverted: -1
}

class CircleFourierVectors
{
    #currentRotation = 0;

    constructor(complexPointsPath, drawnTrajectoryPointsCount, direction)
    {
        this.RotatingVectors = Create2DArray(drawnTrajectoryPointsCount, complexPointsPath.length);
        this.DrawnTrajectoryPointsCount = drawnTrajectoryPointsCount;
        var step = 2.0 * Math.PI / drawnTrajectoryPointsCount;
        this.#generateRotatingVectors(complexPointsPath, step, direction);
        this.#currentRotation = 0;
    }

    NextVector(endPoint)
    {
        this.#currentRotation += 1;
        this.#currentRotation %= this.DrawnTrajectoryPointsCount;
        this.CurrentVector = this.RotatingVectors[this.#currentRotation];
        this.Path = new Array(this.DrawnTrajectoryPointsCount);
        if (endPoint == null || endPoint > this.RotatingVectors[0].length - 1 || endPoint < 0)
        {
            endPoint = this.RotatingVectors[0].length - 1;
        }
        for (let i = 0; i < this.Path.length; i++)
        {
            var index = (i + this.#currentRotation) % this.DrawnTrajectoryPointsCount;
            this.Path[i] = this.RotatingVectors[index][endPoint].GlobalEndPoint;
        }
    }

    #generateRotatingVectors(arr, step, direction)
    {
        for (let j = 0; j < this.DrawnTrajectoryPointsCount; j++)
        {
            let globalEndPoint = new Complex(0, 0);
            for (let i = 0; i < arr.length; i++)
            {
                let PointCopy = new Complex(arr[i].Re, arr[i].Im);
                globalEndPoint = globalEndPoint.Add(PointCopy);
                this.RotatingVectors[j][i] = new FourierVector(PointCopy, globalEndPoint);
            }
            arr = this.#rotateVectors(arr, step, direction);
        }
    }

    #rotateVectors(arr, step, direction)
    {
        var vectorsArray = this.#vectorsCopy(arr);
        let center = vectorsArray.length / 2;
        for (let i = 1; i < center; i++)
        {
            let rotation = step * i;
            vectorsArray[i * 2 - 1].Rotate(direction * rotation); //rotate counter clockwise
            vectorsArray[i * 2].Rotate(-direction * rotation); //rotate clockwise
        }
        return vectorsArray;
    }

    #vectorsCopy(arr)
    {
        var newArr = new Array(arr.length);
        for (let i = 0; i < arr.length; i++)
        {
            newArr[i] = arr[i].Copy();
        }
        return newArr;
    }
}