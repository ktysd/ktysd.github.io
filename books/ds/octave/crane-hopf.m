# "crane-hopf.m" ※旧"invp-hopf.m"
global M m l g KK;  #大域変数の宣言
M=2/3; m=1/3; l=1; g=-9.8;
KK=[22.4933,7,3,5]; #Hopf分岐点
KK(1)=0.8*KK(1) #リミットサイクル側にちょっとずらす
function dx=eqn(x,t)
 global M m l g KK; #関数の中から大域変数を参照する宣言
 ut = -KK*x;  #制御入力
 D=M*l + m*l*(1-cos(x(3))^2);
 dx(1) = x(2);
 dx(2) = ( m*l^2*x(4)^2*sin(x(3)) - m*l*g*cos(x(3))*sin(x(3)) )/D ...
         + l/D * ut;
 dx(3) = x(4);
 dx(4) = ( -m*l^2*x(4)^2*cos(x(3))*sin(x(3)) + (M+m)*g*sin(x(3)) )/D ...
         - cos(x(3))/D * ut;
endfunction
x0=[1; 0.2; 0; 0];       #初期値(ちょっと倒れて静止)
n=1500;                   #時間のきざみ数
tt=linspace(0,30,n);     #時間0〜10の等比数列
xx=lsode("eqn", x0, tt); #常微分方程式"eqn"を解く
subplot(2,1,1); plot( xx(:,1), xx(:,2) );
subplot(2,1,2); plot( xx(:,3), xx(:,4) );
sleep(2);clf;
for i=1:5:n  #簡易アニメーション 5つ飛ばしで描画
 x=xx(i,1);              #第1変数が台車の位置
 theta=xx(i,3);          #第3変数が倒れ角
 plot( [x,x+l*sin(theta)], [0,l*cos(theta)] ); #線分のプロット
 axis([-5,5,-5,5],'square');    #座標軸の設定
 title(sprintf("xxxxx: %d",i)); #タイトルの設定
 grid on; drawnow();
 if ( i==1 ) sleep(1);   #初回は1秒待機
 else sleep(0.02); endif  #この数値でアニメーション速度を調整
endfor