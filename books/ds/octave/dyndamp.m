# "dyndamp.m"
global k c kmu cmu mu;
k=1; c=0.01; kmu=1; cmu=0.01;
mu=0.05;
function y=G(s)
 global k c kmu cmu mu;
 A=[      0,      1,      0,      0; ...
     -k-kmu, -c-cmu,     kmu,     cmu; ...
          0,      0,      0,      1; ...
      kmu/mu,  cmu/mu, -kmu/mu, -cmu/mu ];
 b=[0;1;0;0];
 I=eye(4); #単位行列
 inv(s*I-A);
 y=inv(s*I-A)*b;
endfunction
### 2つ目のばねが硬い場合 ###
kmu=100; #硬くして一体で動かす
omm=linspace(0.5,1.5,100);
RR1=[]; Phi1=[];
for j=1:100
  omeg=omm(j);
  Giw=G(i*omeg);
  Giw(3)=Giw(3)-Giw(1); #相対変位
  Giw(4)=Giw(4)-Giw(2); #相対速度
  R=abs(Giw)';   #振幅比
  phi=arg(Giw)'; #位相差
  RR1=[RR1;R]; Phi1=[Phi1;phi];
endfor
### 2つ目のばね・減衰器を最適調整した場合 ###
kmu=mu/(1+mu)^2
cmu=kmu*sqrt(3/2*mu*(1+mu))
RR2=[]; Phi2=[];
for j=1:100
  omeg=omm(j);
  Giw=G(i*omeg);
  phi=arg(Giw)'; #位相差
  Giw(3)=Giw(3)-Giw(1); #相対変位
  Giw(4)=Giw(4)-Giw(2); #相対速度
  R=abs(Giw)';   #振幅比 ↑ ここで差をとってはダメ
  RR2=[RR2;R]; Phi2=[Phi2;phi];
endfor
### 振幅比のグラフ ###
plot(omm,RR1(:,1),"r-;R_1;",'linewidth',5); hold on;
plot(omm,RR1(:,3),"bo;R'_3;",'markersize',5); hold off;
xlabel('{/Symbol w}'); ylabel('R'); axis([0.5,1.5,-4,120]);
drawnow(); sleep(1);
print -deps2 -F:26 dyndamp1.eps
plot(omm,RR2(:,1),"r-;R_1;",'linewidth',5); hold on;
plot(omm,RR2(:,3),"bo;R'_3;",'markersize',5); hold off;
xlabel('{/Symbol w}'); ylabel('R'); #axis([0.5,1.5,-1,25]);
drawnow(); sleep(1);
print -deps2 -F:26 dyndamp2.eps
### 位相差のグラフ ###
plot(omm,Phi1(:,1),"r-;{/Symbol f}_1;",'linewidth',5); hold on;
Phi2(:,3)=mod(Phi2(:,3).- 2*pi,2*pi)-2*pi;
plot(omm,Phi1(:,3),"bo;{/Symbol f}'_3;",'markersize',5); hold off;
xlabel('{/Symbol w}'); ylabel('{/Symbol f}'); axis([0.5,1.5,-pi,0]);
grid on; drawnow(); sleep(1);
print -deps2 -F:26 dyndamp_phi1.eps
plot(omm,Phi2(:,1),"r-;{/Symbol f}_1;",'linewidth',5); hold on;
Phi2(:,3)=mod(Phi2(:,3).- 2*pi,2*pi)-2*pi;
plot(omm,Phi2(:,3),"bo;{/Symbol f}'_3;",'markersize',5); hold off;
xlabel('{/Symbol w}'); ylabel('{/Symbol f}'); axis([0.5,1.5,-2*pi,0]);
grid on; drawnow();
print -deps2 -F:26 dyndamp_phi2.eps
save dyndamp.dat RR1 RR2 Phi2