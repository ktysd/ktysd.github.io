# "pend.m"　　ここはコメント行．#～行末をOctaveは無視する
global m l c g;  #大域変数の宣言
m=1; l=1; c=1; g=9.8;
function dx=eqn(x,t)
 global m l c g; #関数の中から大域変数を参照する宣言
 dx(1) = x(2);
 dx(2) = -c/(m*l*l)*x(2)-g/l*sin(x(1));
endfunction
x0=[pi/5;0];             #初期値．pi は円周率
n=100;                   #時間のきざみ数
tt=linspace(0,10,n);     #時間0～10の等比数列
xx=lsode("eqn", x0, tt); #常微分方程式"eqn"を解く
for i=1:n  #簡易アニメーション
 theta=xx(i,1);          #第1変数が角度
 plot( [0,sin(theta)], [0,-cos(theta)], 'linewidth', 4); #線分のプロット
 axis([-2,2,-2,2],'square');    #座標軸の設定
 title(sprintf("xxxxx: %d",i)); #タイトルの設定
 grid on; drawnow();
 if ( i==1 ) sleep(1);   #初回は1秒待機
 else sleep(0.1); endif  #この数値でアニメーション速度を調整
endfor