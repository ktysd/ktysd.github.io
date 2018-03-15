clear; clf(); //変数リセット; グラフリセット;
///// システムの定義 /////
M=2/3; m=1/3; l=2; g=9.8; cx=0.5; cq=0.2; ndim=4;
//sw=1e-9; sv=0.1;
sw=0; sv=0.1;
// 初期値:運動方程式
x0=[1; 0; 0.2; 0];          // ← ここに初期値！
n=400; tt=linspace(0,20,n); //時間を表す等差数列
function dx = eom(t,x,D,u,w) //運動方程式 uは外部入力
    MM = [M+m, m*l*cos(x(3)); cos(x(3)), l];
    bb = [-cx*x(2)+m*l*(x(4)**2)*sin(x(3))+u; -cq*x(4)-g*sin(x(3))];
    h = MM\bb; //(MMの逆行列)*bbと同じ．inv(MM)*bbと書くより速い
    dx(1) = x(2); dx(2) = h(1);
    dx(3) = x(4); dx(4) = h(2);
    dx = dx + D*w;
endfunction
// 線形化 dx = A*x + B*u, y = C*x
A=[ 0, 1, 0, 0; ...
    0, -cx/M, g*m/M, cq*m/M; ...
    0, 0, 0, 1; ...
    0, cx/(M*l), -g*(M+m)/(M*l), -cq*(M+m)/(M*l) ];
B=[0; 1/M; 0; -1/(M*l)];
C=[0, 1, 0, 0; ...
   0, 0, 0, 1];
// 雑音
D=[0;0;0;1];  //システム雑音の係数行列
///// 最適レギュレータ /////
function F = lqr_gain( Q, R )
    Qdim=size(Q,'r'); Big=sysdiag(Q,R);
    [w,wp]=fullrf(Big);  //[C1,D12]'*[C1,D12]=Big
    C1=wp(:,1:Qdim);D12=wp(:,Qdim+1:$);
    [F0,FX] = lqr(syslin('c',A,B,C1,D12));
    F=-F0;
endfunction
F_lqr = lqr_gain(diag([2,1,5,1]),1);  //重み：状態=diag(...), 入力=1
///// Kalman-Bucy filter (KBF) /////
global KBF_gain;
exec ../KF/KBF.sci; 
exec ./LQG.sci; 
///// 初期値:数値積分による推定 /////
yint=[x0(1);x0(3)]; dt=tt(2)-tt(1); //数値積分による変位の推定
///// 運動方程式を解く /////
function [xx,xxe,yy,fnam] = Solve( estimator, gain, sw0, sv0, prefix )
    F = gain;
    Q=sw0;             //システム雑音の分散共分散行列(1x1)
    R=diag([sv0,sv0]); //観測雑音の分散共分散行列(2x2)
    rand('seed',7);
    x=x0; xe=x; xx=[]; xxe=[]; yy=[];
    X=KBF_setX0(x0,zeros(ndim,ndim));
    xkb=x0;
    for ti=1:n-1
        w=sqrt(Q/dt)*rand(1,'normal'); //ガウス白色雑音(システム)
        v=sqrt(R/dt)*rand(2,1,'normal'); //ガウス白色雑音(観測)
        y=C*x + v; 
        if ( estimator == 0 )
            xe=x;
        elseif ( estimator == 1 )
            xe=xkb;
        elseif ( estimator == 2 )
            yint=yint+y*dt;
            xe=[yint(1);y(1);yint(2);y(2)];
        end
        xx=[xx,x]; xxe=[xxe,xe]; yy=[yy,y]; //時系列をストア
        u=-F*xe; //制御入力
        xs=ode( x, tt(ti), tt(ti:ti+1), list(eom,D,u,w) ); //数値積分
        x=xs(:,$); //1ステップ後の解を保持
        X=LQG(y,X,tt(ti),dt,A,D,C,Q,R,B,F);
        xkb=KBF_mean(X,ndim) //1ステップ後の解を保持
    end
    KBF_stabiliby=spec(A-KBF_gain*C);
    disp(KBF_stabiliby)
    data=[tt(1:n-1);xx;xxe;yy]';
    fnam='crane-'+prefix;
    fprintfMat(fnam+".dat",data,"%f");
endfunction

//アニメーションする．
function draw_mech(x,xe,fnam)
    g=gca(); g.isoview="on";        //座標軸の取得; 縦横比1;
    g.data_bounds=[-3,-3;3,1];    //座標軸の設定
    xM = [x(1);0]; xm = xM + l*[sin(x(3));-cos(x(3))];
    plot([xM(1),xm(1)],[xM(2),xm(2)],'g-'); //振り子 状態
    p=gce();p.children.thickness=3;         //直前の描画の線の太さ
    xM = [xe(1);0]; xm = xM + l*[sin(xe(3));-cos(xe(3))];
    plot([xM(1),xm(1)],[xM(2),xm(2)],'b:'); //振り子 推定値
    p=gce();p.children.thickness=3;         //直前の描画の線の太さ
    p.children.line_style=7;
    legend(["physical","estimated"]);
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
        xs2png(0,'anim/crane'+string(1000+i)+".png");
    end
    unix('./anim/make_anim.sh '+fnam);
endfunction


///// 制御，Fはゲイン/////
if (1)
[xx,xxe,yy,fn]=Solve(2, F_lqr, sw, sv, "ctrl-num-ran"); 
//anim_mech(xx,xxe,fn);
mp4_mech(xx,xxe,fn);
[xx,xxe,yy,fn]=Solve(1, F_lqr, sw, sv, "ctrl-kbf-ran"); 
//anim_mech(xx,xxe,fn);
mp4_mech(xx,xxe,fn);
end
[xx,xxe,yy,fn]=Solve(2, F_lqr, 1e-12, 1e-12, "ctrl-num-det"); 
//anim_mech(xx,xxe,fn);
mp4_mech(xx,xxe,fn);
