# "mck.m"
global k c omeg;
k=1; c=0.1;
### シミュレーションから計測した振幅比 ###
function dx=eom(x,t)
 global k c omeg;
 A=[ 0,  1; ...
    -k, -c ];
 b=[0;1];
 ut=cos(omeg*t);
 dx=A*x+b*ut;
endfunction
omn=51; freq1=linspace(0.6,1.4,omn);
xpp=[];
for omi=1:omn;
 omeg=freq1(omi);
 T=2*pi/omeg;
 tt=linspace(0,20*T,20*50);
 xx=lsode(@eom,[0;0],tt);
 tti=[20*45:20*50]; #終端時刻付近のデータ番号
 steady=xx(tti,1);  #定常応答
 plot(tt,cos(omeg*tt), "-", ... #入力
      tt,xx(:,1),"-",'linewidth',4,  ... #応答
      tt(tti),steady,"o"); #p-pの計測点
 xlabel("Time"); ylabel("x(t)");
 axis([0,20*T,-10,10]);
 title(sprintf("{/Symbol w}=%f",omeg));
 drawnow(); sleep(0.1);
 switch (omi)
  case 1
   title(""); print -deps2 -F:24 mck_01.eps
  case 26
   title(""); print -deps2 -F:24 mck_26.eps
  case 51
   title(""); print -deps2 -F:24 mck_51.eps
 endswitch
 pp=max(steady)-min(steady);
 xpp=[xpp;pp/2];
endfor
sleep(1);
plot(freq1,xpp,"o;x_{p-p}/2;",'markersize',8);
xlabel("{/Symbol w}"); ylabel("R"); axis([0.6,1.4,0,12]);
sleep(2);
### 伝達関数で計算した振幅比 ###
function y=G(s)
 global k c;
 A=[ 0,  1; ...
    -k, -c ];
 b=[0;1];
 I=eye(2); #単位行列
 inv(s*I-A);
 y=inv(s*I-A)*b;
endfunction
freq2=linspace(0.6,1.4,100); RR=[];
for j=1:100
  omeg=freq2(j);
  Giw=G(i*omeg);
  R=abs(Giw);   #振幅比 (変位,速度)
  phi=arg(Giw); #位相差 (変位,速度)
  RR=[RR,R(1)]; #振幅比 (変位)
endfor
hold on;
plot(freq2,RR,"r-;|G(i{/Symbol w})|;",'linewidth',5);
xlabel('{/Symbol w}'); ylabel('R'); axis([0.6,1.4,0,12]);
drawnow();
print -deps2 -F:24 mck_R.eps