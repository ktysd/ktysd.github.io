clear;clf();
/////////////// 諸元 ///////////////
M=1, J=0.1, m=5, r=0.2, l=1, g=9.8;
bmax=0.29; //転倒角
mu=0.3; //摩擦係数
////////////////////////////////////
///// ステップ関数ほか /////
function y = step( x )
 s = 100;
 y = 1.0./(1.0+exp(-s*x));              //ステップ関数
endfunction
function y = trap( x, x0, w )
 y = step((x-x0)+w).*step(-(x-x0)+w);   //台形関数
endfunction
function y = sgn( x )
    s = 1e4;
    y = (2.0/(1+exp(-s*x))-1.0);        //符号関数
endfunction
///// 床からの反力（ペナルティー法） /////
function ff = yuka(x)
  global r l mu;
  a=x(1); da=x(2); b=x(3); db=x(4);
  xm = [r*a+l*sin(b); r+l*cos(b)];
  dxm = [r*da+l*db*cos(b); -l*db*sin(b)];
  Kp=1e4; Cp=90;    //これらの数値を変えると床の性質が変わる
  R = step(-xm(2))*(-Kp*xm(2) -Cp*dxm(2)); //垂直抗力
  F = -mu*R*sgn(dxm(1)); //摩擦力
  ff = [F; R];      //床からの反力
endfunction
///// 運動方程式の定義 /////
function dx = eom(t,x)
    a=x(1); da=x(2); b=x(3); db=x(4);
    /// 制御の打ち切り×(位置制御 + 倒立制御) ///
    T = trap(b,0,bmax)*(1*a + 0.5*da + 40*b + 4*db);
    FT = [T; -T];   //トルク→一般化力
    /// ペナルティー法による床反力 ///
    ff=yuka([a; da; b; db]);
    Ff = [r, 0; l*cos(b), -l*sin(b)]*ff; //床反力→一般化力
    A = [(M+m)*r^2+J, m*l*r*cos(b); ...
             m*l*r*cos(b),    m*l^2];
    bb = [m*l*r*db^2 *sin(b); m*g*l*sin(b)] + FT + Ff;
    h = A\bb;       //加速度の右辺
    dx(1) = x(2); dx(2) = h(1);
    dx(3) = x(4); dx(4) = h(2);
endfunction
///// 運動方程式を解く /////
tn=401; tt=linspace(0,0.01*tn,tn);
x0=[0; 0; 0; 1];
xx=ode( x0, 0, tt, eom );
///// ロボット描画用の関数 /////
function R=Rot(a)           //回転
 R=[cos(a),-sin(a);...
    sin(a), cos(a)];
endfunction
function yy=Trans(xx,rr)    //平行移動
 yy(1,:)=xx(1,:) + rr(1)*ones(xx(1,:));
 yy(2,:)=xx(2,:) + rr(2)*ones(xx(2,:));
endfunction
function draw_robot(a,b)    //ロボット描画
    x=r*a; //車輪中心の水平変位
    sn=5; sq=linspace(0,2*%pi*(sn-1)/sn,sn);
    spoke=r*[cos(sq);sin(sq)];  //原点にあるスポークの外周点
    spoke=Rot(-a) * spoke;      //角度a回転したスポークの外周点
    spoke=Trans(spoke,[x;r]);   //位置xのスポークの外周点
    xv=[x*ones(1:sn);spoke(1,:)]; yv=[r*ones(1:sn);spoke(2,:)];
    xsegs(xv,yv,2); xarc(x-r, 2*r, 2*r, 2*r, 0, 360*64); //スポーク; 車輪
    rod=[0,0;0,l];              //原点にある棒の両端点
    rod=Rot(-b) * rod;          //角度βだけ回転した棒の両端点
    rod=Trans(rod,[x;r]);       //位置xの棒の両端点
    plot( rod(1,:), rod(2,:),"r-");     //棒の描画
    p=gce(); p.children.thickness=2;    //直前の描画; 線の太さ
    g=gca(); g.data_bounds=[-4,-1;4,2]; //座標軸の範囲
    g.isoview="on"; xgrid(4);           //縦横比1; グリッド;
endfunction
a=x0(1); b=x0(3); drawlater; draw_robot(a,b); drawnow;
sleep(2000); //2s待ち
realtimeinit(0.01); //アニメーションの時間刻み
for i=1:10:tn
    realtime(i);
    drawlater; clf();   //描画延期; 画面消去;
    a=xx(1,i); b=xx(3,i);
    draw_robot(a,b);
    xlabel(sprintf("%d / %d", i, tn));
    drawnow;            //画面更新;
end