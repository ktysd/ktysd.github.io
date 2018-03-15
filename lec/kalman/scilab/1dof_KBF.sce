clear; clf();
///// definition of target system /////
c=0.3; k=1; dt=0.1; tn=200;
A=[0, 1; -k, -c];
D=[0; 1];
C=[0, 1];
x0=[1; 0];

///// solve the target system /////
function dx = eom(t,x,A,D,w)
  dx = A*x + D*w;
endfunction
function x = eom_solve(x0,t0,dt,A,D,w)
    xx=ode( x0, t0, [t0,t0+dt], list(eom,A,D,w) );
    x=xx(:,$); //dt 後の解
endfunction

function [xx,yy,tt] = solve_target(x0,tn,dt,A,D,C,Q,R)
  x=x0; xx=[x0']; yy=[(C*x0)']; tt=[0];
  rand('seed',9);
  wt=sqrt(Q)*rand(size(Q,'c'),tn,'normal');
  vt=sqrt(R)*rand(size(R,'c'),tn,'normal');
  for ti=1:tn
    t = ti*dt;
    /// solve target system ///
    x = eom_solve(x,t,dt,A,D,wt(ti));
    y = C*x + vt(ti);
    /// Store data ///
    xx = [xx;x']; yy = [yy;y']; tt = [tt;t];
  end
endfunction

///// Kalman Bucy filtering /////
exec KBF.sci;
function xx = KalmanBucyFilter(yy,tt,x0,P0,A,D,C,Q,R);
  //initial condition
  X0 = KBF_setX0( x0, P0 );
  X = X0; xx=[]; tn=length(tt); dt=tt(2)-tt(1);
  for ti=1:tn
    //filtering
    X = KBF(yy(ti),X,tt(ti),dt,A,D,C,Q,R);
    xf = KBF_mean(X,2);
    xx = [xx;xf'];
  end
endfunction

///// Numerical Integration /////
function xx=numint(x0,yy,dt)
  xx=[]; tn=max(size(yy));
  x=x0(1);
  for ti=1:tn
    xx = [xx;x'];
    x = x + yy(ti)*dt;
  end
endfunction

///// Calculating and plotting /////
function plot_result(tt,xx,yy,xxf,xxint)
    clf();
    subplot(2,1,1);
    g=gca(); g.isoview="off";      //座標軸の取得; 縦横比1;
    g.data_bounds=[0,-1.5;20,1.5];    //座標軸の設定
    plot(tt,xx(:,2), "g.", tt,yy, "b-", tt,xxf(:,2), "r-");
    legend("Real","Noisy measured","Filtered");
    xlabel("Time"); ylabel("Measurement"); 
    subplot(2,2,3);
    plot(xx(:,1),xx(:,2), "g.", xxint,yy, "b-");
    legend("Real","Num. int");
    xlabel("Sum of y_n*dt"); ylabel("y_n"); 
    subplot(2,2,4);
    plot(xx(:,1),xx(:,2), "g.", xxf(:,1),xxf(:,2), "r-");
    legend("Real","Filtered");
    xlabel("x_1"); ylabel("x_2"); 
    g=gca(); g.isoview="off";      //座標軸の取得; 縦横比1;
    g.data_bounds=[-1,-1.5;1.2,1.5];    //座標軸の設定
endfunction

tn=200; x0=[1; 0];
///// noiseless system + noisy measurement /////
Q=1e-16; R=0.1;
[xx,yy,tt]=solve_target(x0,tn,dt,A,D,C,Q,R);
xxf = KalmanBucyFilter(yy,tt,x0,[0,0;0,0],A,D,C,Q,R);
xxint=numint(x0,yy,dt);
plot_result(tt,xx,yy,xxf,xxint);
prefix="1dof_KBF_Q0_R1"; 
xs2eps(0,prefix+".eps"); xs2png(0,prefix+".png");

// noisy system + noiseless measurement
Q=0.1; R=1e-16; 
[xx,yy,tt]=solve_target(x0,tn,dt,A,D,C,Q,R);
xxf = KalmanBucyFilter(yy,tt,x0,[0,0;0,0],A,D,C,Q,R);
xxint=numint(x0,yy,dt);
plot_result(tt,xx,yy,xxf,xxint);
prefix="1dof_KBF_Q1_R0"; 
xs2eps(0,prefix+".eps"); xs2png(0,prefix+".png");

// noisy system + noisy measurement
Q=0.1; R=0.1;  
[xx,yy,tt]=solve_target(x0,tn,dt,A,D,C,Q,R);
xxf = KalmanBucyFilter(yy,tt,x0,[0,0;0,0],A,D,C,Q,R);
xxint=numint(x0,yy,dt);
plot_result(tt,xx,yy,xxf,xxint);
prefix="1dof_KBF_Q1_R1"; 
xs2eps(0,prefix+".eps"); xs2png(0,prefix+".png");
