class Complex
{
    constructor(re, im)
    {
        this.isNull = true;
        this._magnitude = null;
        if (re != null && im != null)
        {
            this.Re = re;
            this.Im = im;
            this.isNull = false;
        }
    }

    Add(b)
    {
        return new Complex(this.Re + b.Re, this.Im + b.Im);
    }

    Sub(b)
    {
        return new Complex(this.Re - b.Re, this.Im - b.Im);
    }

    Mult(b)
    {
        if (b instanceof Complex)
        {//(a.Re + ia.Im) * (b.Re + ib.Im) = (a.Re * b.Re - a.Im * b.Im) * i(a.Re * b.Im + a.Im + b.Re)
            return new Complex((this.Re * b.Re) - (this.Im * b.Im), (this.Re * b.Im) + (this.Im * b.Re));
        }
        else
        {
            return this.Scale(b);
        }
    }

    Rotate(rotationRad)
    {
        var Cos = Math.cos(rotationRad);
        var Sin = Math.sin(rotationRad);
        var temp = this.Re;
        this.Re = (this.Re * Cos) - (this.Im * Sin);
        this.Im = (temp * Sin) + (this.Im * Cos);
    }

    Scale(scale)
    {
        return new Complex(scale * this.Re, scale * this.Im);
    }

    Copy()
    {
        return new Complex(this.Re, this.Im);
    }

    Mag()
    {
        if (_magnitude == null)
        {
            _magnitude = Math.sqrt(this.Re * this.Re + this.Im * this.Im);
        }
        return _magnitude;
    }
}
