class Complex {
  double Re;
  double Im;
  Double _magnitude;
  boolean isNull;

  public Complex()
  {
    isNull=true;
  }

  public Complex(double re, double im) {
    Re=re;
    Im=im;
    isNull = false;
  }

  public Complex Add(Complex b) {
    return new Complex(this.Re + b.Re, this.Im + b.Im);
  }

  public Complex Sub(Complex b) {
    return new Complex(this.Re - b.Re, this.Im - b.Im);
  }

  public Complex Mult(Complex b) {
    //(a.Re + ia.Im) * (b.Re + ib.Im) = (a.Re * b.Re - a.Im * b.Im) * i(a.Re * b.Im + a.Im + b.Re)
    return new Complex((this.Re * b.Re) - (this.Im * b.Im), (this.Re * b.Im) + (this.Im * b.Re));
  }

  public Complex Mult(double scale) {
    return new Complex(this.Re * scale, this.Im * scale);
  }

  public void Rotate(double rotationRad) {
    //Complex rotationVector = new Complex(Math.cos(rotationRad), Math.sin(rotationRad));
    //Complex afterRotation = this.Mult(rotationVector);
    //this.Re = afterRotation.Re;
    //this.Im = afterRotation.Im;

    //more efficient way
    double Cos = Math.cos(rotationRad);
    double Sin = Math.sin(rotationRad);
    double temp = this.Re;
    this.Re = (this.Re * Cos) - (this.Im * Sin);
    this.Im = (temp * Sin) + (this.Im * Cos);
  }
  public Complex Scale(double scale) {
    return new Complex(scale*Re, scale*Im);
  }

  public double Mag()
  {
    if (_magnitude == null)
    {
      _magnitude = Math.sqrt(this.Re*this.Re + this.Im*this.Im);
    }
    return _magnitude;
  }

  @Override
    public String toString() {
    return String.format("(%.3f + %.3fi)", Re, Im);
  }
}
