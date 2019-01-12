public Complex[] FFT(Complex[] x) { // code of FFT copied from here https://introcs.cs.princeton.edu/java/97data/FFT.java.html
  int n = x.length;

  // base case
  if (n == 1) return new Complex[] { x[0] };

  // radix 2 Cooley-Tukey FFT
  if (n % 2 != 0) {
    throw new IllegalArgumentException("n is not a power of 2");
  }

  // fft of even terms
  Complex[] even = new Complex[n/2];
  for (int k = 0; k < n/2; k++) {
    even[k] = x[2*k];
  }
  Complex[] q = FFT(even);

  // fft of odd terms
  Complex[] odd  = even;  // reuse the array
  for (int k = 0; k < n/2; k++) {
    odd[k] = x[2*k + 1];
  }
  Complex[] r = FFT(odd);

  // combine
  Complex[] y = new Complex[n];
  for (int k = 0; k < n/2; k++) {
    double kth = -2 * k * Math.PI / n;
    Complex wk = new Complex(Math.cos(kth), Math.sin(kth));
    y[k]       = q[k].Add(wk.Mult(r[k]));
    y[k + n/2] = q[k].Sub(wk.Mult(r[k]));
  }
  return y;
}
