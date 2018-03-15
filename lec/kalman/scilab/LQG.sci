///// Kalman Bucy filter /////
//exec KBF.sci; //<==先に読み込む必要あり
///// Least square quadratic Gaussian regulator/////
function X = LQG(y,X0,t0,dt,A,D,C,Q,R,B,F)
    n=size(A,'r');
    CL = A-B*F; //closed-loop
    XX=ode( X0, t0, [t0,t0+dt], list(KBF_de,n,y,A,D,C,Q,R,CL) );
    X=XX(:,$);  //dt 後の解
endfunction
function u = LQG_control(F,X)
    u = -F*KBF_mean(X);
endfunction

