\c 40 200i
qfind:{([] q:k;k:.q k:key[.q] where (string value .q) like "*",x,"*")}
show qfind"@&"
\\
