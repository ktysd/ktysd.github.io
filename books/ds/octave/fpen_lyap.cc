/* "fpen_lyap.cc"
 *
 * [...]$ mkoctfile fpen_lyap.cc
 *
 * として fpen_lyap.oct に変換する．
 */
#include <octave/oct.h>
#include <octave/LSODE.h>

/* 運動方程式
 * ※ octave でベクトルの第1成分は x(1) だが，ここでは x(0)
 * --- ここから --- */
struct _p { double c, k, P, omeg; } p;
ColumnVector xdot(const ColumnVector& x, double t) {
  ColumnVector dx(4);
  dx(0) = x(1); /* octave では dx(1)=x(2) */
  dx(1) = -p.c*x(1) -p.k*sin(x(0)) + p.P*cos(p.omeg*t);
  dx(2) = x(3); /* octave では dx(3)=x(4) */
  dx(3) = -p.k*cos(x(0))*x(2) -p.c*x(3) ;
  return dx;
}
/* --- ここまで --- */

double norm2(ColumnVector x) {
  double r=0.0;
  int dim=x.rows()/2;
  for (int i=dim; i<dim*2; i++) {
    r += x(i)*x(i);
  }
  return sqrt(r);
}
void normalize(ColumnVector &x, double r) {
  int dim=x.rows()/2;
  for (int i=dim; i<dim*2; i++) {
    x(i)/=r;
  }
}

DEFUN_DLD (fpen_lyap, args, , "Poincare map for a single pendlumn") {
  /* 引数の取得 */
  double get_global_double( char* s);
  ColumnVector x0 (args(0).vector_value ()); //初期値
  double T = (args(1).double_value ()); //周期
  double m = (args(2).int_value ()); //無視する過渡の点数
  double n = (args(3).int_value ()); //出力点数
  /* global 変数の取得 */
  p.c = get_global_double( "c" );
  p.k = get_global_double( "k" );
  p.P = get_global_double( "P" );
  p.omeg = get_global_double( "omeg" );
  /* 数値積分 */
  int dim = x0.rows(); //次元
  int Tn = 200; //分割数
  double t=0.0, dt = T/(double)Tn;
  ODEFunc odef(xdot);
  ColumnVector x=x0; //解
  x(2)=1.0; x(3)=0.0;
  double r = norm2(x);
  for ( int i=1; i<m; i++ ) { /* 過渡を無視する */
    normalize(x,r); /* 長さを1に */
    LSODE ls(x, 0.0, odef);
    for ( int ti=1; ti<=Tn; ti++ ) {
      t = dt*(double)ti;
      x = ls.do_integrate(t);
    }
    r = norm2(x);
  }
  Matrix pm(n,dim);
  ColumnVector lam(n-1);
  for ( int j=0; j<dim; j++ ) {
    pm(0,j)=x(j);
  }
  for ( int i=1; i<n; i++ ) {
    normalize(x,r); /* 長さを1に */
    LSODE ls(x, 0.0, odef);
    for ( int ti=1; ti<=Tn; ti++ ) {
      t = dt*(double)ti;
      x = ls.do_integrate(t);
    }
    r = norm2(x);
    lam(i-1)=log(r)/T;
    for ( int j=0; j<dim; j++ ) {
      pm(i,j)=x(j);
    }
  }
  octave_value_list retval;
  retval(1) = octave_value(lam);
  retval(0) = octave_value(pm);
  return retval;
}

double get_global_double( char* s ) {
  double retval = 0.123456789012345;
  octave_value tmp = get_global_value (s, true);
  if ( ! tmp.is_defined () || tmp.is_empty() )
    octave_stdout<< "Global variable \"" << s << "\" is empty";
  else
    retval = tmp.double_value ();
  return retval;
}