clear;clf();
///// 運動方程式 /////
m=1; l=1; J=m*l^2/3;  g = 9.8; mu=0.3;
function y = torq(x,f)
    y = det([x,f]); 
endfunction
function y = signum( x )
    y = (2.0/(1+exp(-1e4*x))-1.0); //符号関数
endfunction
function y = step( x )
    y = 1.0/(1.0+exp(-1e4*x)); //ステップ関数
endfunction
function fy = R( y, dy ) //床反力
    Kp=8e3; Cp=25; fy = step(-y)*(-Kp*y -Cp*dy);              //『方法1』
    //Kp=12e3; Cp=80; fy = step(-y)*(-Kp*y -step(-dy)*Cp*dy); //『方法2』
endfunction
function fx = F( dx, R ) //摩擦力
    fx = -signum(dx)*mu*R;
endfunction
function dq = eom(t,q)
    x=q(1); dx=q(2); y=q(3); dy=q(4); a=q(5); da=q(6);
    u1 = -(l/2)*[cos(a); sin(a)]; u2 = -u1;
    du1 =-(l/2)*da*[-sin(a); cos(a)]; du2 = -du1;
    X1 = [x;y]+u1;         //端点1の位置
    X2 = [x;y]+u2;         //端点2の位置
    dX1 = [dx;dy]+du1;     //端点1の速度
    dX2 = [dx;dy]+du2;     //端点2の速度
    R1 = R(X1(2), dX1(2)); //床垂直抗力1
    R2 = R(X2(2), dX2(2)); //床垂直抗力2
    F1 = F(dX1(1), R1);    //床摩擦力1
    F2 = F(dX2(1), R2);    //床摩擦力2
    f1 = [F1;R1]; f2 = [F2;R2];        //端点に作用する力
    F = f1 + f2 + m*[0;-g];            //合力
    T = torq(u1, f1) + torq(u2, f2);   //合トルク
    dq(1) = dx; dq(2) = F(1)/m;
    dq(3) = dy; dq(4) = F(2)/m;
    dq(5) = da; dq(6) = T/J;
endfunction
///// 運動方程式を解く /////
n=130; tt=linspace(0,0.05*(n-1),n);
x0 = [0; 0; 5; 0; %pi/4; 0];
xx=ode( x0, 0, tt, eom );
///// アニメーションする /////
function draw_mech(x,y,th)
    g=gca();                   //座標軸の取得
    g.data_bounds(:,1)=[-2;4]; //x軸の範囲
    g.data_bounds(:,2)=[0;5];  //y軸の範囲
    g.isoview="on";            //縦横比1; グリッド;
    xset("color",1);           //基本色黒
    xsegs([-3;5],[0;0],9);     //x軸
    xsegs([0;0],[-0.5;5.5],9); //y軸
    u1 = -(l/2)*[cos(th); sin(th)]; u2 = -u1;
    X1 = [x;y]+u1; X2 = [x;y]+u2;
    xsegs([X1(1);X2(1)],[X1(2);X2(2)],5); //スティック
    p=gce(); p.thickness=2;    //直前の描画; 線の太さ
endfunction
x=x0(1); y=x0(3); th=x0(5);
draw_mech(x,y,th); drawnow; //描画実行; 画面更新;
//xclick(); //マウスクリック待ち
sleep(2000); 
realtimeinit(0.05); //アニメーションの時間刻み
for i=1:n
    realtime(i);
    drawlater(); clf(); //描画延期; 描画消去;
    x=xx(1,i); y=xx(3,i); th=xx(5,i);
    draw_mech(x,y,th);  //描画消去; 棒を描く;
    drawnow;            //画面更新
end
//xs2eps(0,"stick.eps");
