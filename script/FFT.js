// code of FFT copied from here https://introcs.cs.princeton.edu/java/97data/FFT.java.html
// works only on arrays with element count = 2^n


class FFT
{
    constructor(x)
    {
        this.inputSeries = x;
    }

    Compute()
    {
        this.resultSeries = this.#scaleVectors(this.#sortByFourierOrder(this.#computeRecursive(this.inputSeries)));
    }

    #scaleVectors(arr)
    {
        var newArr = new Array(arr.length);
        let scaleFactor = 1.0 / arr.length;
        for (let i = 0; i < arr.length; i++)
        {
            newArr[i] = arr[i].Mult(scaleFactor);
        }
        return newArr;
    }

    #sortByFourierOrder(arr)
    {
        var toReturn = new Array(arr.length);

        for (let i = 0; i < arr.length; i++)
        {
            if (i % 2 == 0)
                toReturn[i] = arr[i / 2];
            else
                toReturn[i] = arr[arr.length - ((i + 1) / 2)];
        }

        return toReturn;
    }

    #computeRecursive(x)
    {
        if (!(x instanceof Array))
        {
            throw "x is not instance of an Array";
        }

        var n = x.length;

        // base case
        if (n == 1) return new Array(x[0]);

        // radix 2 Cooley-Tukey FFT
        if (n % 2 != 0)
        {
            throw "input series count " + n + " is not a power of 2";
        }

        // fft of even terms
        var even = new Array(n / 2);
        for (let k = 0; k < n / 2; k++)
        {
            even[k] = x[2 * k];
        }
        var q = this.#computeRecursive(even);

        // fft of odd terms
        var odd = even;  // reuse the array
        for (let k = 0; k < n / 2; k++)
        {
            odd[k] = x[2 * k + 1];
        }
        var r = this.#computeRecursive(odd);

        // combine
        var y = new Array(n);
        for (let k = 0; k < n / 2; k++)
        {
            var kth = -2 * k * Math.PI / n;
            var wk = new Complex(Math.cos(kth), Math.sin(kth));
            y[k] = q[k].Add(wk.Mult(r[k]));
            y[k + n / 2] = q[k].Sub(wk.Mult(r[k]));
        }
        return y;
    }
}