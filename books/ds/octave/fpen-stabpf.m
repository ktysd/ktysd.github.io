# "fpen-stabpf.m"
load fpen-bd.dat #fpen_bd; 分岐図
load fpen-stab.dat #fpen_stab eig070 eig065; 安定判別
eig070
eig065
### 安定性で分割 ###
i=1; mae=fpen_stab(i,3);
ps=[]; pu=[];
for i=1:rows(fpen_stab);
 mae=fpen_stab(i,3);
 if (mae<1)
  ps=[ps;fpen_stab(i,1:2)]; #安定
 else
  pu=[pu;fpen_stab(i,1:2)]; #不安定
 endif
endfor
hold on; pu2=pu(1:2:rows(pu),:); #表示を粗く
plot(ps(:,1),ps(:,2), "k-", 'linewidth', 2);
plot(pu2(:,1),pu2(:,2), "ko", 'markersize', 6);
plot(fpen_bd(:,1),fpen_bd(:,2), ".");
axis([0.61,0.68,-7.9,-6.5]);
xlabel("c"); ylabel("p_n"); drawnow();
#print -deps2 -F:20 fpen-stabpf.eps