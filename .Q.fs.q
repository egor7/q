fsn:{[f;s;n]
 >[-7!s]
 {[f;s;x;n]
  i:(#r)^1 + last@&"\n"=r:1:(s;x;n);
  f@`\:i#r;
  x+i
 }[f;s;;n]/0}

/ https://kx.com/blog/kdb-q-insights-scripting-with-q/
\d .log
out:{-1 string[.z.p]," ### INFO ### ",x};
err:{-2 string[.z.p]," ### ERROR ### ",x};
\d .
sayhello:{.log.out["Hello ",x]};

main:{
  sayhello d[`name];
  exit 0;
 };

@[main;`;{.log.err "Error running main: ",x;exit 1}];

/https://github.com/KxSystems/cookbook/blob/master/dataloader/loader.q
dir:"f"
l:(` sv) each (d,) each key d:hsym `$dir
