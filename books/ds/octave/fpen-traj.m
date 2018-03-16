# "fpend-traj.m" ※環境によっては実行時間がかかる！
global c k P omeg;
function dx=eom(x,t)
 global c k P omeg;
 dx(1) = x(2);
 dx(2) = -c*x(2) -k*sin(x(1)) + P*cos(omeg*t);
endfunction
k=1; P=2.7; omeg=1; T=2*pi/omeg;
x0=[0;0];
tn=1000; #無視する過渡応答
dn=tn+500; #取得するデータ長
tt=linspace(0,dn*T,50*dn);
### 1周期 ###
c=0.7; xx=lsode("eom",x0,tt)(tn+1:dn,:); #過渡を削除
hold off; plot(xx(:,1),xx(:,2),"-",'linewidth',5);
hold on; plot(xx(1,1),xx(1,2),"o",'markersize',10);
xlabel("x(t)"); ylabel('{~x{.5.}(t)}'); axis([-9,-2,-3,3]); drawnow();
print -deps2 -F:24 fpen-traj1.eps
### 2周期 ###
x0=xx(1,:)'; #分岐図と履歴を合わせるため
c=0.65; xx=lsode("eom",x0,tt)(tn+1:dn,:); #過渡を削除
hold off; plot(xx(:,1),xx(:,2),"-",'linewidth',5);
hold on; plot(xx([1,51],1),xx([1,51],2),"o",'markersize',10);
xlabel("x(t)"); ylabel('{~x{.5.}(t)}'); axis([-9,-2,-3,3]); drawnow();
print -deps2 -F:24 fpen-traj2.eps
### 4周期 ###
x0=xx(1,:)'; #分岐図と履歴を合わせるため
c=0.63; xx=lsode("eom",x0,tt)(tn+1:dn,:); #過渡を削除
hold off; plot(xx(:,1),xx(:,2),"-",'linewidth',5);
hold on; plot(xx([1,51,101,151],1),xx([1,51,101,151],2),"o",'markersize',10);
xlabel("x(t)"); ylabel('{~x{.5.}(t)}'); axis([-9,-2,-3,3]); drawnow();
print -deps2 -F:24 fpen-traj4.eps
### 無限周期 ###
x0=xx(1,:)'; #分岐図と履歴を合わせるため
c=0.61; xx=lsode("eom",x0,tt)(tn+1:dn,:); #過渡を削除
hold off; plot(xx(:,1),xx(:,2),"-",'linewidth',5);
xlabel("x(t)"); ylabel('{~x{.5.}(t)}'); axis([-9,-2,-3,3]); drawnow();
#print -deps2 -F:24 fpen-trajx.eps