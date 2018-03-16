# "Wmat.m"
function W = Wmat( aa )
  n = length(aa);  #固有方程式の次数
  W=zeros(n,n);
  for i=1:n
    for j=1:n
      if ( i+j < n+1 )
        W(i,j) = aa(i+j);
      elseif ( i+j == n+1 )
        W(i,j) = 1;
      endif
    endfor
  endfor
endfunction