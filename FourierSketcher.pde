import com.hamoid.*; //library for video recording
import geomerative.*; //library to extract points from Path
RShape Shape;
RPoint[][] pointPaths;
Complex[] ComplexPoints;
Complex[] PathBeforeFFT;
Complex[] PathAfterFFT;
Complex[] SortedAfterFFT;
FourierVector[][] AllRotationsFourierVectors;
int DrawnTrajectoryPointsCount = 2000; //affects speed of drawing and speed of UpdateDrawnTrajectory() function
Complex[] DrawnTrajectory = new Complex[DrawnTrajectoryPointsCount];
boolean UpdateTrajectory=true;
int FourierRank=1023;
int SizeOfFourierPoints = 1024; //Patch size on which Fourier transform is done; must be power of 2 to proper working FFT
VideoExport VideoOut;
boolean recording = false;
boolean startRecording = false;
boolean stopRecording = false;
String ShapeName = "Poland";
void setup() {
  size(1080, 1080);
  //fullScreen();
  smooth(2);
  VideoOut = new VideoExport(this); //startMovie, saveFrame, endMovie
  VideoOut.setFrameRate(30);
  RG.init(this); //geomerative needs this
  Shape = RG.loadShape(ShapeName+".svg");
  float margin = min(width, height)/21;
  Shape = RG.centerIn(Shape, g, margin); //centering
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
    AllRotationsFourierVectors = new FourierVector[DrawnTrajectoryPointsCount][SizeOfFourierPoints];
    GenerateAllRotationsFourierVectorsMatrix(SortedAfterFFT, PathAfterFFT, AllRotationsFourierVectors);
  }
}

//
double FourierRankImitation=(double)FourierRank;
boolean up=false;
int rankStep = 2;
int rankMax = FourierRank-1;
int rotationIndex = 0;
//
void draw() {

  //section resposible for automatic rank change while recording
  if (recording) {
    if (FourierRankImitation<SizeOfFourierPoints && up)
      FourierRankImitation+=rankStep;
    if (FourierRankImitation>=(rankStep+1) && !up)
      FourierRankImitation-=rankStep;
    if (FourierRankImitation>rankMax)
      up=false;
    if (FourierRankImitation<(rankStep+1))
    {
      up=true;
    }
    if ((int)FourierRankImitation!=FourierRank) {
      //UpdateTrajectory=true;
      FourierRank = (int)FourierRankImitation;
    }
  }
  //section resposible for automatic rank change while recording

  background(255);
  translate(width/2, height/2);

  DrawAllRotationsFourierVectors(AllRotationsFourierVectors, rotationIndex, FourierRank+1, true, true);

  strokeWeight(5);
  stroke(0);
  strokeCap(ROUND);
  strokeJoin(ROUND);
  for (int k=0; k<DrawnTrajectoryPointsCount; k++) {
    int ic = (k+rotationIndex)%DrawnTrajectoryPointsCount; //curent index
    int in = (ic+1)%DrawnTrajectoryPointsCount;  //next index
    if (!(AllRotationsFourierVectors[in][FourierRank].GlobalEndPoint.isNull || AllRotationsFourierVectors[ic][FourierRank].GlobalEndPoint.isNull))
    {
      strokeWeight(5*((float)k/DrawnTrajectoryPointsCount)); // the thickness of the line varies depending on the distance from the current point
      stroke(0);
      line((float)AllRotationsFourierVectors[in][FourierRank].GlobalEndPoint.Re, (float)AllRotationsFourierVectors[in][FourierRank].GlobalEndPoint.Im, (float)AllRotationsFourierVectors[ic][FourierRank].GlobalEndPoint.Re, (float)AllRotationsFourierVectors[ic][FourierRank].GlobalEndPoint.Im); //lines between all adjacent points
    }
  }

  stroke(0);
  strokeWeight(1);
  fill(255);
  //Shape.draw();
  ellipse((float)AllRotationsFourierVectors[rotationIndex][FourierRank].GlobalEndPoint.Re, (float)AllRotationsFourierVectors[rotationIndex][FourierRank].GlobalEndPoint.Im, 10, 10);

  rotationIndex+=1;
  rotationIndex%=DrawnTrajectoryPointsCount;

  if (startRecording)
  {
    String name = String.valueOf(ShapeName+"-"+year())+"-"+String.valueOf(month())+"-"+String.valueOf(day())+"-"+String.valueOf(hour())+"-"+String.valueOf(minute())+"-"+String.valueOf(second())+".mp4";
    VideoOut.setMovieFileName(name);
    VideoOut.startMovie();
    recording = true;
    println("video started");
    startRecording = false;
  }
  if (recording)
    VideoOut.saveFrame();
  if (stopRecording)
  {
    recording = false;
    VideoOut.endMovie();
    println("video ended");
    stopRecording = false;
  }
}

void keyPressed() {
  int step = 1;
  if (key == CODED) {
    if (keyCode == UP && FourierRank<(SizeOfFourierPoints-step)) {
      FourierRank+=step;
      UpdateTrajectory=true;
    } else if (keyCode == DOWN && FourierRank>step) {
      FourierRank-=step;
      UpdateTrajectory=true;
    }
  }
  if (key == 'r' || key == 'R') {
    if (!recording)
      startRecording = true; 
    else
      stopRecording = true;
  }
}

public void UpdateDrawnTrajectory()
{
  for (int q=0; q<DrawnTrajectoryPointsCount; q++) {
    //DrawnTrajectory[(q+i)%DrawnTrajectoryPointsCount] = EvaluateEnd(SortedAfterFFT, FourierRank);
    RotateComplexArray(PathAfterFFT);
  }
}

public Complex EvaluateEnd(Complex[] complexArray, int Rank) {
  double scale = 1.0/complexArray.length;
  if (Rank > complexArray.length)
    Rank = complexArray.length;
  Complex End = new Complex(0, 0);
  for (int i=0; i<Rank; i++) {
    End.Re = End.Re + complexArray[i].Re*scale;
    End.Im = End.Im + complexArray[i].Im*scale;
  }
  return End;
}

public void DrawAllRotationsFourierVectors(FourierVector[][] AllRotationsFourierVectors, int rotationIndex, int Rank, boolean withCircles, boolean withLines)
{
  FourierVector[][] ARFV = AllRotationsFourierVectors;
  int RI = rotationIndex;
  if (Rank > ARFV[0].length)
    Rank = ARFV[0].length;

  for (int i=1; i< Rank; i++)
  {
    if (withLines) {
      strokeWeight(1);
      line((float)ARFV[RI][i-1].GlobalEndPoint.Re, (float)ARFV[RI][i-1].GlobalEndPoint.Im, (float)ARFV[RI][i].GlobalEndPoint.Re, (float)ARFV[RI][i].GlobalEndPoint.Im);
    }
    if (withCircles) {
      noFill();
      strokeWeight(0.5);
      ellipse((float)ARFV[RI][i-1].GlobalEndPoint.Re, (float)ARFV[RI][i-1].GlobalEndPoint.Im, (float)ARFV[RI][i].ComplexVector.Mag()*2, (float)ARFV[RI][i].ComplexVector.Mag()*2);
      fill(0, 128, 255);
      ellipse((float)ARFV[RI][i-1].GlobalEndPoint.Re, (float)ARFV[RI][i-1].GlobalEndPoint.Im, 3, 3);
    }
  }
  fill(0, 0, 255);
  ellipse((float)ARFV[RI][Rank-1].GlobalEndPoint.Re, (float)ARFV[RI][Rank-1].GlobalEndPoint.Im, 5, 5);
}

public void RotateComplexArray(Complex[] complexArray) //rotate all vectors little bit
{
  double step= 2*PI/DrawnTrajectoryPointsCount; // distance between DrawnTrajectory[n] and DrawnTrajectory[n+1] will always been drawn with the same amount of time
  int center = complexArray.length/2;
  for (int i=1; i<center; i++)
  {
    complexArray[i].Rotate(i*step); //rotate counter clockwise
    complexArray[complexArray.length-i].Rotate(-i*step); //rotate clockwise
  }
}

public void GenerateAllRotationsFourierVectorsMatrix(Complex[] sortedAfterFFT, Complex[] pathAfterFFT, FourierVector[][] AllRotationsFourierVectors)
{
  float scale = 1.0/sortedAfterFFT.length;

  for (int j=0; j<DrawnTrajectoryPointsCount; j++) {
    Complex temp = new Complex(0, 0);
    for (int i=0; i<sortedAfterFFT.length; i++)
    {
      Complex PointCopy = new Complex(sortedAfterFFT[i].Re, sortedAfterFFT[i].Im).Mult(scale);
      temp = temp.Add(PointCopy);
      AllRotationsFourierVectors[j][i] = new FourierVector(PointCopy, temp);
    }
    RotateComplexArray(pathAfterFFT);
  }
}
