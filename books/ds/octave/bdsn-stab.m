# "bdsn-stab.m"
global c k K;
load bdsn-cont.dat #c k K FF xx
function m=Jaco(x,F) #ヤコビ行列
 global c k K;
 m = [0, 1; ...
      k*cos(x)-F*sin(x)-K, -c];
endfunction
function y=eigmax(x,F) #最大の固有値実部
 y=max(real(eig(Jaco(x,F))));
endfunction
### 安定判別 ###
xs=[]; Fs=[]; xu=[]; Fu=[];
for i=1:length(xx);
 stab=eigmax(xx(i),FF(i));
 if (stab<0)
  xs=[xs,xx(i)]; Fs=[Fs,FF(i)]; #安定平衡点
 else
  xu=[xu,xx(i)]; Fu=[Fu,FF(i)]; #不安定平衡点
 endif
endfor
### プロット用に安定平衡点を2分割する ###
jump=0; ns=length(xs);
for i=1:ns-1;
 if (abs(xs(i+1)-xs(i))>0.5)
  jump=i;
 endif
endfor
xs1=xs(1:jump); Fs1=Fs(1:jump);
xs2=xs(jump+1:ns); Fs2=Fs(jump+1:ns);
### 分岐図の描画 ###
hold on;
plot(Fs1,xs1,"-",'linewidth',3); #安定
plot(Fs2,xs2,"-",'linewidth',3); #安定
plot(Fu,xu,".1",'linewidth',3);  #不安定
xlabel("F"); ylabel("x");
axis([-0.3,0.3,-1,1]); drawnow;
save bdsn-stab.dat c k K Fs1 xs1 Fs2 xs2;
#print -deps2 -F:26 bdsn-stab.eps