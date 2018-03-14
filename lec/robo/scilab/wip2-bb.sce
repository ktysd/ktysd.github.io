clear;clf();
///// 左（赤）のバンバン入力 /////
function u=bang1(t)
    P = 6; //バンバン入力の強度
    /// 以下は3段の場合 ///
    t1=0.36; t2=0.78; t3=0.39; //切替時間の変更は0.01単位
    if (t<t1)
        u = P;
    elseif (t<t1+t2)
        u = -P;
    elseif (t<t1+t2+t3)
        u = P;
    else
        u = 0;
    end
endfunction
///// 右（青）のバンバン入力 /////
function u=bang2(t)
    u = 0; //0を返す = 何もしない 
endfunction
/////////////// 諸元 ///////////////
M=2, J=0.1, m=5, r=0.2, l=1, g=9.8;
bmax=0.9;   //転倒角
mu=0.3;     //摩擦係数
w0=3;       //リンクの自然長
////////////////////////////////////
///// ステップ関数ほか /////
function y = step( x )
    s = 100;
    y = 1.0./(1.0+exp(-s*x));               //ステップ関数
endfunction
function y = trap( x, x0, w )
    y = step((x-x0)+w).*step(-(x-x0)+w);    //台形関数
endfunction
function y = sgn( x )
    s = 1e4; //#1×10の4乗のこと = 10000
    y = (2.0/(1+exp(-s*x))-1.0);            //符号関数
endfunction
///// 床からの反力（ペナルティー法） /////
function ff = yuka(x)
    a=x(1); da=x(2); b=x(3); db=x(4);
    xm = [r*a+l*sin(b); r+l*cos(b)];
    dxm = [r*da+l*db*cos(b); -l*db*sin(b)];
    Kp=1e4; Cp=90; //これらの数値を変えると床の性質が変わる
    R = step(-xm(2))*(-Kp*xm(2)-Cp*dxm(2)); //垂直抗力
    F = -mu*R*sgn(dxm(1));                  //摩擦力
    ff = [F; R];                            //床からの反力
endfunction
///// リンクからの反力 /////
function pp = rinku(x)
    a1=x(1); da1=x(2); b1=x(3); db1=x(4);
    a2=x(5); da2=x(6); b2=x(7); db2=x(8);
    //リンクからの力
    ww = [r*(a2-a1)+l*(sin(b2)-sin(b1));...
                    l*(cos(b2)-cos(b1))];
    dww = [r*(da2-da1)+l*( db2*cos(b2)-db1*cos(b1));...
                       l*(-db2*sin(b2)+db1*sin(b1))];
    w = norm(ww); //wwの長さ
    dw = ( dww(1)*ww(1)+dww(2)*ww(2) )/w; //wwの長さの時間微分
    uu = ww/w; //単位ベクトル化
    ck = 5000; cw = 100; p = -ck*(w-w0)-cw*dw; //反力の大きさ
    pp = p*uu;
endfunction
///// 振り子先端に作用する力→一般化力 /////
function Ff = sentan(x,F)
    global r l;
    b=x(3);
    Ff = [r, 0; l*cos(b), -l*sin(b)]*F; //一般化力への変換公式
endfunction
///// 倒立制御入力 /////
function u = toritu(x,a0)
    a=x(1); da=x(2); b=x(3); db=x(4);
    /// 制御の打ち切り×(位置制御 + 倒立制御) ///
    u = trap(b,0,bmax)*(15*b + 1*db); //対戦用に「倒立制御のみ」に変更
endfunction
///// 運動方程式の右辺 ////
function h = uhen(x,F)
    a=x(1); da=x(2); b=x(3); db=x(4);
    A = [ (M+m)*r^2+J, m*l*r*cos(b); ...
         m*l*r*cos(b),    m*l^2];
    bb = [m*l*r*db^2 *sin(b); m*g*l*sin(b)] + F; //Fは一般化力
    h = A\bb;
endfunction
///// 運動方程式の定義 /////
function dx = eom(t,x)
    pp = rinku(x);    //リンクからの反力
    ///// 左 /////
    a=x(1); da=x(2); b=x(3); db=x(4);
    ff=yuka([a; da; b; db]);            //床反力
    Ff=sentan([a; da; b; db], ff - pp); //振り子先端への力→一般化力
    T =toritu([a; da; b; db],0);        //倒立制御
    T = T + bang1(t);                   //バンバン入力をトルクに加算
    FT=[T; -T];                         //トルク→一般化力
    h=uhen([a; da; b; db], FT+Ff);      //加速度で整理した右辺
    dx(1) = x(2); dx(2) = h(1);         //運動方程式
    dx(3) = x(4); dx(4) = h(2);
    ///// 右 /////
    a=x(5); da=x(6); b=x(7); db=x(8);
    ff=yuka([a; da; b; db]);            //床反力
    Ff=sentan([a; da; b; db], ff + pp); //振り子先端への力→一般化力
    T =toritu([a; da; b; db],w0/r);     //倒立制御
    T = T + bang2(t);                   //バンバン入力をトルクに加算
    FT=[T; -T];                         //トルク→一般化力
    h=uhen([a; da; b; db], FT+Ff);      //加速度の右辺
    dx(5) = x(6); dx(6) = h(1);         //運動方程式
    dx(7) = x(8); dx(8) = h(2);
endfunction
///// 運動方程式を解く /////
tn=801; tt=linspace(0,0.01*tn,tn);
x01=[0; 0; 0; 0];       //左側の初期値
x02=[w0/r; 0; 0; 0];    //右側の初期値
xx=ode( [x01;x02], 0, tt, eom );
///// ロボット描画用の関数 /////
function R=Rot(a)           //回転
    R=[cos(a),-sin(a);...
       sin(a), cos(a)];
endfunction
function yy=Trans(xx,rr)    //平行移動
    yy(1,:)=xx(1,:) + rr(1)*ones(xx(1,:));
    yy(2,:)=xx(2,:) + rr(2)*ones(xx(2,:));
endfunction
function endp = draw_robot(a,b,x,sp) //ロボット描画
//    x=r*a; //車輪中心の水平変位
    sn=5; sq=linspace(0,2*%pi*(sn-1)/sn,sn);
    spoke=r*[cos(sq);sin(sq)];      //原点にあるスポークの外周点
    spoke=Rot(-a) * spoke;          //角度a回転したスポークの外周点
    spoke=Trans(spoke,[x;r]);       //位置xのスポークの外周点
    xv=[x*ones(1:sn);spoke(1,:)]; yv=[r*ones(1:sn);spoke(2,:)];
    xsegs(xv,yv,2); xarc(x-r, 2*r, 2*r, 2*r, 0, 360*64); //スポーク; 車輪
    rod=[0,0;0,l];                  //原点にある棒の両端点
    rod=Rot(-b) * rod;              //角度βだけ回転した棒の両端点
    rod=Trans(rod,[x;r]);           //位置xの棒の両端点
    plot( rod(1,:), rod(2,:),sp);       //棒の描画
    gc=gce(); gc.children.thickness=2;  //線の太さ
    endp=rod(:,2);                      //棒の先端
endfunction
function draw_pair(x)
    a1=x(1); b1=x(3); a2=x(5); b2=x(7); 
    /// 重心まわりの描画 ///
    xM1=r*a1; xM2=r*a2; xm1=xM1+l*sin(b1); xm2=xM2+l*sin(b2);
    xG=(M*(xM1+xM2)+m*(xm1+xm2))/(2*M+2*m);     //重心の座標
    ep1=draw_robot(a1,b1,r*a1-xG,"r-");         //r 赤
    ep2=draw_robot(a2,b2,r*a2-xG,"b-");         //b 青
    plot([ep1(1),ep2(1)],[ep1(2),ep2(2)],"g-"); //リンクの描画
    gc=gca(); gc.isoview="on";                  //縦横比1
    gc.data_bounds=[-3,0;3,2];                  //座標軸の範囲
endfunction
drawlater; draw_pair( [x01;x02] ); drawnow;
sleep(2000); //2s待ち
realtimeinit(0.01); //アニメーションの時間刻み
for i=1:10:tn
    realtime(i);
    drawlater; clf();           //描画延期; 描画消去;
    draw_pair( xx(:,i) );       //ロボット描画
    xlabel(sprintf("%d / %d", i, tn));
    drawnow;                    //画面更新
end
///// 転倒時刻の測定 /////
i_1win=0; i_2win=0;
for i=1:tn
    b=xx(3,i); ep1=r+l*cos(b);
    b=xx(7,i); ep2=r+l*cos(b);
    if ( ep1<0 & i_2win==0 )
        i_2win=i;
    end
    if ( ep2<0 & i_1win==0 )
        i_1win=i;
    end
end
///// 転倒時刻の表示 /////
sy=1.5;
if ( i_1win==0 & i_2win==0 )             //引き分け
    xstring(-2,sy,"DRAW !");
elseif ( i_1win>0 & i_2win==0 ) //1の勝ち
    t_win=tt(i_1win);                   //勝った時刻
    xstring(-2,sy,sprintf("Red wins at  t = %.2f (i=%d)",t_win,i_1win));
elseif ( i_1win==0 & i_2win>0 ) //2の勝ち
    t_win=tt(i_2win);                   //勝った時刻
    xstring(-2,sy,sprintf("Blue wins at  t = %.2f (i=%d)",t_win,i_2win));
else
    xstring(0,sy,"DRAW (both lose)");    //共倒れ
end
gc=gce(); gc.font_size=5; drawnow;
