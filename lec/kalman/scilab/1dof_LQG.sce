clear; clf(); //変数リセット; グラフリセット;
///// システムの定義 /////
m=1; cx=0.1; kx=0.1; ndim=2;
// 初期値:運動方程式
x0=[1; 0];          // ← ここに初期値！
n=400; tt=linspace(0,100,n); //時間を表す等差数列
function dx = eom(t,x,A,B,D,u,w) //運動方程式 uは外部入力
    dx = A*x + B*u + D*w
endfunction
A=[0, 1; ...
   -kx/m, -cx/m];
B=[0; 1/m];
C=[1, 0];
// 雑音
D=[0;1];     //システム雑音の係数行列
Q=0;     //システム雑音の分散共分散行列(1x1)
R=0.01;  //観測雑音の分散共分散行列(1x1)
///// Kalman-Bucy filter (KBF) /////
global KBF_gain;
exec ../KF/KBF.sci; 
exec ./LQG.sci; 
///// 数値微分による推定 /////
yint=x0(1); dt=tt(2)-tt(1);
ydiff=x0(1); yprev=ydiff;
///// 移動平均による濾波 /////
ma_n=20; yold=x0(1)*ones(1,ma_n);
///// 運動方程式を解く /////
function [xx,xxe,yy,fnam] = Solve( estimator, gain, Q0, R0, prefix )
    F = gain;
    Q = Q0;  //システム雑音の分散共分散行列
    R = R0;  //観測雑音の分散共分散行列
    rand('seed',7);
    x=x0; xe=x; xx=[]; xxe=[]; yy=[];
    X=KBF_setX0(x0,zeros(ndim,ndim));
    xkb=x0;
    for ti=1:n-1
        w=sqrt(Q/dt)*rand(1,'normal'); //ガウス白色雑音(システム)
        v=sqrt(R/dt)*rand(1,'normal'); //ガウス白色雑音(観測)
        y=C*x + v; 
        if ( estimator == 0 )
            xe=x;
        elseif ( estimator == 1 )
            xe=xkb(1:ndim);
        elseif ( estimator == 2 )
            ydiff=(y-yprev)/dt; yprev=y; xe=[y;ydiff];
        elseif ( estimator == 3 )
            yold=[yold(2:$),y];
            yave=mean(yold);//0.5*(yold(1)+y);
            ydiff=(yave-yprev)/dt; yprev=yave; xe=[yave;ydiff];
        end
        xx=[xx,x]; xxe=[xxe,xe]; yy=[yy,y]; //時系列をストア
        u=-F*xe; //制御入力
        xs=ode( x, tt(ti), tt(ti:ti+1), list(eom,A,B,D,u,w) ); //数値積分
        x=xs(:,$); //1ステップ後の解を保持
        X=LQG(y,X,tt(ti),dt,A,D,C,Q,R,B,F);
        xkb=KBF_mean(X,ndim) //1ステップ後の解を保持
    end
    KBF_stabiliby=spec(A-KBF_gain*C);
    disp(KBF_stabiliby)
    data=[tt(1:n-1);xx;xxe;yy]';
    fnam='1dof-'+prefix;
    fprintfMat(fnam+".dat",data,"%f");
endfunction

//アニメーションする．
function draw_mech(x,xe,fnam)
    g=gca(); g.isoview="on";      //座標軸の取得; 縦横比1;
    g.data_bounds=[-1.2,-0.2;1.2,0.4];    //座標軸の設定
    wd=0.1; ht=0.2;
    px=[x(1)-wd,x(1)-wd,x(1)+wd,x(1)+wd,x(1)-wd];
    py=[0,ht,ht,0,0];
    plot([x(1),x(1)],[0,ht],'g-',[xe(1)],[0],'bo'); //縦線と○
    p=gce();p.children.thickness=3;         //直前の描画の線の太さ
    legend(["physical","estimated"],[0.5,0.5]);
    plot(px,py,'k-'); //箱
    p=gce();p.children.thickness=2;         //直前の描画の線の太さ
    xgrid(5);                               //グリッドon
    xlabel(fnam); 
endfunction
function anim_mech(xx,xxe,fnam)
    n = size(xx,'c');
    clf(); 
    draw_mech(x0,x0,fnam); drawnow; //初期描画; 画面更新;
    sleep(2000);                //2秒待ち
    realtimeinit(0.05);         //アニメーションの時間刻み
    for i=1:2:n   //コマ送り
        realtime(i);            //リアルタイム更新設定
        drawlater; clf();       //描画延期; 画面消去
        x=xx(:,i);              //状態ベクトル取得
        xe=xxe(:,i);            //推定値取得
        draw_mech(x,xe,fnam); drawnow;  //機構描画; 画面更新
    end
endfunction
function mp4_mech(xx,xxe,fnam)
    n = size(xx,'c');
    for i=1:4:n    //コマ送り
        drawlater(); clf();     //描画延期; 画面消去
        x=xx(:,i);              //状態ベクトル取得
        xe=xxe(:,i);            //推定値取得
        draw_mech(x,xe,fnam);   //機構描画
        drawnow();
        xs2png(0,'anim/1dof'+string(1000+i)+".png");
    end
    unix('./anim/make_anim.sh '+fnam);
endfunction


///// 制御，Fはゲイン/////
//[xx,xxe,yy]=Solve(0, [0,0],    Q, R,    "x-free-ran");
//[xx,xxe,yy]=Solve(0, [0,0.45], Q, R,    "x-ctrl-ran");
[xx,xxe,yy,fn]=Solve(2, [0,0],    Q, R,    "free-num-ran"); 
//anim_mech(xx,xxe,fn);
mp4_mech(xx,xxe,fn);
if(1)
[xx,xxe,yy,fn]=Solve(2, [0,0],    Q, 1e-9, "free-num-det"); 
[xx,xxe,yy,fn]=Solve(2, [0,0.45], Q, R,    "ctrl-num-ran"); 
//anim_mech(xx,xxe,fn);
mp4_mech(xx,xxe,fn);
[xx,xxe,yy,fn]=Solve(2, [0,0.45], Q, 1e-9, "ctrl-num-det"); 
[xx,xxe,yy,fn]=Solve(3, [0,0],    Q, R,    "free-numma-ran"); 
//anim_mech(xx,xxe,fn);
mp4_mech(xx,xxe,fn);
[xx,xxe,yy,fn]=Solve(3, [0,0.45], Q, R,    "ctrl-numma-ran"); 
//anim_mech(xx,xxe,fn);
mp4_mech(xx,xxe,fn);
[xx,xxe,yy,fn]=Solve(3, [0,0.45], Q, 1e-9, "ctrl-numma-det"); 
[xx,xxe,yy,fn]=Solve(1, [0,0],    Q, R,    "free-kbf-ran"); 
//anim_mech(xx,xxe,fn);
mp4_mech(xx,xxe,fn);
[xx,xxe,yy,fn]=Solve(1, [0,0.45], Q, R,    "ctrl-kbf-ran"); 
//anim_mech(xx,xxe,fn);
mp4_mech(xx,xxe,fn);
end
//A2 = A-B*F; //閉ループ系
