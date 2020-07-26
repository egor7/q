/learn from .Q

lj:{.Q.ft[,\:[;y];x]}
.Q.ft:{
 $[$[
   99h=@t:v y; /dict
   98h=@. t;   /table
   0];
  [n:#+!y;n!x 0!y];
  x y
  ]}
.Q.v:{
 $[-11h=@x;     /?x is symbol
  .$[":"=*t:$x;  /?1st char of symbol is ":"
   `$t,"/";       /add "/" to symbol and return value(.) of it
   x];
  x]}

/ create splayed tables
`:db/tref/ set ([] c1:1 2 3; c2:1.1 2.2 3.3)
`:db/cust/ set .Q.en[`:db;] ([] sym:`ibm`msft`goog; name:`:db/sym?`oracle`microsoft`google)

/create partitioned tables
`:db/2015.01.01/t/ set .Q.en[`:db;] ([] ti:09:30:00 09:31:00; sym:`ibm`msft; p:101 33f)
`:db/2015.01.02/t/ set .Q.en[`:db;] ([] ti:09:30:00 09:31:00; sym:`ibm`msft; p:101.5 33.5)
`:db/2015.01.01/q/ set .Q.en[`:db;] ([] ti:09:30:00 09:31:00; sym:`ibm`msft; b:100.75 32.75; a:101.25 33.25)
`:db/2015.01.02/q/ set .Q.en[`:db;] ([] ti:09:30:00 09:30:00; sym:`ibm`msft; b:101.25 33.25; a:101.75 33.75)

/load
\l db
tref / +`c1`c2     !`:tref/
cust / +`sym`name  !`:cust/
t    / +`ti`sym`p  !`t
q    / +`ti`sym`b`a!`q
.Q.qp tref
.Q.qp cust
.Q.qp t
.Q.qp q

(`a`b`c!(1 4;2 5;3 6)) ~ flip(`a`b`c!1 2 3; `a`b`c!4 5 6)
dictionary of lists ~ flipped list of dictionaries

/ query partitioned, if symbol starts with :, then only splayed
.Q.qp
k){$[
  ~98h=@x; 0; /not table, 0
  ~@x:.+x; 0; /2nd part of table is list, 0
  ~":"=*$x
  ]}

/ apply f(x) to t(y)
.Q.ft
k){$[
  $[
   99h=@t:v y;
   98h=@. t;
   0
   ];
  [n:#+!y;n!x 0!y]; / nice
  x y
  ]}

/ rearrange columns, x becomes first
xcols
k){(x,f@&~(f:cols y)in x)#y}

cols
k){$[
  .Q.qp x:.Q.v x; / Partitioned?
  .Q.pf,!+x;      /   add "partitioned field" to table cols
  98h=@x;         / Simple table?
  !+x;            /   just table cols (convert to dict of lists, get keys)
  11h=@!x;        / Dictionary?
  !x;             /   dictionary keys
  !+0!x           / (keys-dict)!(data-dict): remove keys, get table cols
  ]}

/ rename
xcol
k){
 .Q.ft[{+$[99h=@x;@[!y;(!y)?!x;:;. x];x,(#x)_!y]!. y:+y}x]y}
