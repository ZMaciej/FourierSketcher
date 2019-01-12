import geomerative.*; //library to extract points from Path

RShape Shape;
RPoint[][] pointPaths;
Complex[] ComplexPoints;
Complex[] PathBeforeFFT;
Complex[] PathAfterFFT;
Complex[] SortedAfterFFT;
int DrawnTrajectoryPointsCount = 2000; //affects speed of drawing and speed of EvaluateEnd() function
Complex[] DrawnTrajectory = new Complex[DrawnTrajectoryPointsCount];
boolean UpdateTrajectory=true;
int FourierRank=500;
int SizeOfFourierPoints = 1024; //Patch size on which I do Fourier transform; must be power of 2 to proper working FFT 

void setup() {
  //size(800, 800);
  fullScreen();
  //smooth();
  RG.init(this); //geomerative needs this
  Shape = RG.loadShape("FacePath.svg");
  Shape = RG.centerIn(Shape, g); //centering
  RG.setPolygonizer(RG.UNIFORMLENGTH); //Choosing Path to Points Mode: RG.ADAPTATIVE, RG.UNIFORMLENGTH or RG.UNIFORMSTEP
  pointPaths = Shape.getPointsInPaths();

  if (pointPaths.length>0) // there should be only one path in file so i consider only index 0
  {
    ComplexPoints = new Complex[pointPaths[0].length];
    if (pointPaths[0] != null) {
      for (int j = 0; j<pointPaths[0].length; j++) {
        ComplexPoints[j] = new Complex(pointPaths[0][j].x, pointPaths[0][j].y); //maping points of Path onto complex plane
      }
    }

    for (int i=0; i<DrawnTrajectory.length; i++)
    {
      DrawnTrajectory[i] = new Complex();
    }

    //interpolating ComplexPoints to different size to match FFT requirements
    PathBeforeFFT = new Complex[SizeOfFourierPoints];
    int l=0;
    double scaleFactor = (double)SizeOfFourierPoints/(ComplexPoints.length);
    for (int i=0; i<=ComplexPoints.length; i++)
    {
      while ((double)i*scaleFactor >= (double)l) {
        Complex previous = ComplexPoints[(i-1+ComplexPoints.length)%ComplexPoints.length];
        Complex difference = ComplexPoints[i%ComplexPoints.length].Sub(previous);
        double distance = l/scaleFactor -i+1;
        PathBeforeFFT[l%SizeOfFourierPoints] = new Complex(difference.Re*distance+previous.Re, difference.Im*distance+previous.Im);
        l++;
      }
    }

    PathAfterFFT = FFT(PathBeforeFFT); //Fast Fourier Transform
    //the result should be interpreted as mentioned here https://www.gaussianwaves.com/2015/11/interpreting-fft-results-complex-dft-frequency-bins-and-fftshift/
    //where negative frequency means that that particular harmonic rotates clockwise

    SortedAfterFFT = SortByFourierOrder(PathAfterFFT);
  }
}

int i=0;
void draw() {
  background(255);
  translate(width/2, height/2);
  
  if(UpdateTrajectory){
    UpdateDrawnTrajectory();
    UpdateTrajectory=false;
  }
  DrawComplexArray(SortedAfterFFT, FourierRank, true, true);
  RotateComplexArray(PathAfterFFT);

  strokeWeight(5);
  stroke(0);
  strokeCap(ROUND);
  strokeJoin(ROUND);
  for (int k=0; k<DrawnTrajectory.length; k++) {
    int ic = (k+i+DrawnTrajectory.length)%DrawnTrajectory.length; //curent index
    int in = (ic+1)%DrawnTrajectory.length;  //next index
    if (!(DrawnTrajectory[in].isNull || DrawnTrajectory[ic].isNull))
    {
      strokeWeight(5*((float)k/DrawnTrajectory.length));
      stroke(0);
      line((float)DrawnTrajectory[in].Re, (float)DrawnTrajectory[in].Im, (float)DrawnTrajectory[ic].Re, (float)DrawnTrajectory[ic].Im);
    }
  }

  stroke(0);
  strokeWeight(1);
  fill(255);
  //Shape.draw();
  ellipse((float)DrawnTrajectory[i].Re, (float)DrawnTrajectory[i].Im, 10, 10);
  i = (i+1)%DrawnTrajectory.length;
}

void keyPressed() {
  int step = 1;
  if (key == CODED) {
    if (keyCode == UP && FourierRank<SizeOfFourierPoints) {
      FourierRank+=step;
      UpdateTrajectory=true;
    } else if (keyCode == DOWN && FourierRank>step) {
      FourierRank-=step;
      UpdateTrajectory=true;
    }
  }
}

public void UpdateDrawnTrajectory()
{
  for (int q=0; q<DrawnTrajectoryPointsCount; q++) {
    DrawnTrajectory[(q+i)%DrawnTrajectoryPointsCount] = EvaluateEnd(SortedAfterFFT, FourierRank);
    RotateComplexArray(PathAfterFFT);
  }
}

public Complex EvaluateEnd(Complex[] complexArray, int Rank) {
  double scale = 1.0/complexArray.length;
  if (Rank > complexArray.length)
    Rank = complexArray.length;
  Complex End = new Complex(0, 0);
  for (int i=0; i<Rank; i++){
    End.Re = End.Re + complexArray[i].Re*scale;
    End.Im = End.Im + complexArray[i].Im*scale;
  }
  return End;
}

public Complex DrawComplexArray(Complex[] complexArray, int Rank, boolean withCircles, boolean withLines)
{
  if (Rank > complexArray.length)
    Rank = complexArray.length;
  float scale = 1.0/complexArray.length;
  Complex referencePoint = complexArray[0].Mult(scale);
  //pushMatrix();
  //translate((float)complexArray[0].Re*scale,(float)complexArray[0].Im*scale);
  for (int i=1; i< Rank; i++)
  {
    if (withLines) {
      strokeWeight(1);
      line((float)referencePoint.Re, (float)referencePoint.Im, (float)referencePoint.Re + (float)complexArray[i].Re*scale, (float)referencePoint.Im+(float)complexArray[i].Im*scale);
    }
    if (withCircles) {
      noFill();
      strokeWeight(0.5);
      ellipse((float)referencePoint.Re, (float)referencePoint.Im, (float)complexArray[i].Mag()*2*scale, (float)complexArray[i].Mag()*2*scale);
      fill(0, 128, 255);
      ellipse((float)referencePoint.Re, (float)referencePoint.Im, 3, 3);
    }
    referencePoint = referencePoint.Add(complexArray[i].Mult(scale));
  }
  fill(0, 0, 255);
  ellipse((float)referencePoint.Re, (float)referencePoint.Im, 5, 5);
  return referencePoint;
}

public void RotateComplexArray(Complex[] complexArray) //rad is how much the outer line rotates
{
  double step= 2*PI/DrawnTrajectoryPointsCount;
  int center = complexArray.length/2;
  for (int i=1; i<center; i++)
  {
    complexArray[i].Rotate(i*step); //rotate counter clockwise
    complexArray[complexArray.length-i].Rotate(-i*step); //rotate clockwise
  }
}

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
