clear; clf();
///// definition of target system /////
c=0.3; k=1; dt=0.1;
F=[1, dt; -k*dt, 1-c*dt];
G=[1; dt];
H=[0, 1];

///// solve the target system /////
function [xx,yy,tt] = solve_target(x0,tn,F,G,H,Q,R)
  x=x0; xx=[]; yy=[];
  rand('seed',9);
  wt=sqrt(Q)*rand(size(Q,'c'),tn,'normal');
  vt=sqrt(R)*rand(size(R,'c'),tn,'normal');
  tt=1:tn;
  for ti=tt
    y = H*x + vt(ti);
    xx = [xx;x'];
    yy = [yy;y'];
    x = F*x + G*wt(ti); //measurement
  end
endfunction

///// Kalman filtering /////
exec KF.sci;
function xx = KalmanFilter(yy,x0,P0,F,G,H,Q,R);
  //initial condition
  xp=x0; Pp=P0;
  xx=[]; tn=max(size(yy));
  for ti=1:tn
    //filtering
    [xf, xp, Pp] = KF(yy(ti),xp,Pp,F,G,H,Q,R);
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
    g.data_bounds=[0,-1.5;200,1.5];    //座標軸の設定
    plot(tt',xx(:,2), "go", tt',yy, "b-", tt',xxf(:,2), "r-");
    legend("Real","Noisy measured","Filtered");
    xlabel("Time"); ylabel("Measurement"); 
    subplot(2,2,3);
    plot(xx(:,1),xx(:,2), "go", xxint,yy, "b-");
    legend("Real","Num. int");
    xlabel("Sum of y_n*dt"); ylabel("y_n"); 
    subplot(2,2,4);
    plot(xx(:,1),xx(:,2), "go", xxf(:,1),xxf(:,2), "r-");
    legend("Real","Filtered");
    xlabel("x_1"); ylabel("x_2"); 
    g=gca(); g.isoview="off";      //座標軸の取得; 縦横比1;
    g.data_bounds=[-1,-1.5;1.2,1.5];    //座標軸の設定
endfunction

tn=200; x0=[1; 0];
///// noiseless system + noisy measurement /////
Q=1e-8; R=0.1; 
[xx,yy,tt]=solve_target(x0,tn,F,G,H,Q,R);
xxf = KalmanFilter(yy,x0,[0,0;0,0],F,G,H,Q,R);
xxint=numint(x0,yy,dt);
plot_result(tt,xx,yy,xxf,xxint);
prefix="1dof_KF_Q0_R1"; 
xs2eps(0,prefix+".eps"); xs2png(0,prefix+".png");
sleep(2000);

// noisy system + noiseless measurement
Q=1e-3; R=1e-16; 
[xx,yy,tt]=solve_target(x0,tn,F,G,H,Q,R);
xxf = KalmanFilter(yy,x0,[0,0;0,0],F,G,H,Q,R);
plot_result(tt,xx,yy,xxf,xxint);
prefix="1dof_KF_Q1_R0"; 
xs2eps(0,prefix+".eps"); xs2png(0,prefix+".png");
sleep(2000);

// noisy system + noisy measurement
Q=1e-3; R=0.1;  
[xx,yy,tt]=solve_target(x0,tn,F,G,H,Q,R);
xxf = KalmanFilter(yy,x0,[0,0;0,0],F,G,H,Q,R);
plot_result(tt,xx,yy,xxf,xxint);
prefix="1dof_KF_Q1_R1"; 
xs2eps(0,prefix+".eps"); xs2png(0,prefix+".png");
sleep(2000);
