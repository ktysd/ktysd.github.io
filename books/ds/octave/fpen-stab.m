# "fpen-stab.m"
global c k P omeg T;
c=0.7; k=1; P=2.7; omeg=1.0;
n1=1000; #無視する過渡応答
n2=4000; #データ数
### 不動点の概算 ###
x0=[0;0];
T=2*pi/omeg; #外力の周期
xx=fpen_po(x0,T,n1,n2); #ポアンカレ写像
p0=xx(n2,:)'; #概算値
### 不動点の方程式 ###
function y=fixp(p0)
 global T;
 p1=fpen_po(p0,T,0,2)(2,:)';
 y=p0-p1;
endfunction
p=p0; nc=200; cc=linspace(0.7,0.6,nc+1);
fpen_stab=[];
for i=1:nc+1
 c=cc(i);
 p=fsolve("fixp",p); ### ニュートン法による不動点 ###
 R0=[p;1;0]; R1=fpen_polin(R0,T,0,2)(2,3:4)';
 R0=[p;0;1]; R2=fpen_polin(R0,T,0,2)(2,3:4)';
 R=[R1,R2]; eigenvalue=eig(R); mae=max(abs(eigenvalue));
 if(abs(c-0.7)<=1e-6) eig070=eigenvalue endif
 if(abs(c-0.65)<1e-6) eig065=eigenvalue; endif
 fpen_stab=[fpen_stab;c,p(1),mae];
endfor
plot(fpen_stab(:,1),fpen_stab(:,3), "k-", 'linewidth', 5); grid on;
xlabel("c"); ylabel("Largest |s_i|");
axis([0.64,0.7,0.6,1.4]);drawnow();
save fpen-stab.dat fpen_stab eig070 eig065
#print -deps2 -F:20 fpen-stab.eps