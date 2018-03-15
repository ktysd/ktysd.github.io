// Transformation between vector and matrix
function v = mat2vec( mat )
    v = mat(:);
endfunction
function mat = vec2mat( v, n )
    mat = matrix(v,n,n);
endfunction
// KBF differential equation
function dX = KBF_de(t,X,ndim,y,A,D,C,Q,R,A2)
    xMean = X( 1:ndim ); //推定値（期待値）成分
    xCov  = X( (ndim+1):$ ); //共分散成分
    Cov = vec2mat(xCov,n); //
    //invR = pinv(R); K = Cov*C'*invR; //Kalman gain
    K = Cov*C'/R; //Kalman gain: Equivalent to the above
    KBF_gain = K;
    dMean = A2*xMean + K*(y - C*xMean);
    dCov = A*Cov + Cov*A' + D*Q*D' - K*C*Cov;
    dX = [dMean; mat2vec(dCov)];
endfunction
///// Kalman Brucy filter /////
function X = KBF(y,X0,t0,dt,A,D,C,Q,R)
    n=size(A,'r');
    XX=ode( X0, t0, [t0,t0+dt], list(KBF_de,n,y,A,D,C,Q,R,A) );
    X=XX(:,$); //dt 後の解
endfunction
// set initial values
function X0 = KBF_setX0( mean0, Cov0 )
    X0=[mean0;mat2vec(Cov0)];
endfunction
// get mean vector
function x = KBF_mean( X, ndim )
    x = X(1:ndim); //推定値（期待値）成分
endfunction
// get covariance matrix
function CovMat = KBF_Cov( X, ndim )
    CovVec = x( (ndim+1):$ ); //共分散成分
    CovMat = vec2mat( CovVec, ndim );
endfunction
