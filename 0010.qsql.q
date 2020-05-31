/https://code.kx.com/q/kb/programming-idioms/
/http://www.q-ist.com/2012/10/functional-query-functions.html
/https://code.kx.com/q/learn/brief-introduction/#random-data-generation
/ KxSystems/cookbook/tutorial

depts:`finance`packing`logistics`management`hoopjumping`trading`telesales
n:5
t:([]a:n?depts;b:n?100;c:upper n?`4)
t
(select a,b from t) ~ ?[t;();0b;`a`b!`a`b] /1b
(delete a,b from t) ~ ![t;();0b;`a`b] /1b
(delete from t where b>80) ~ ![t;enlist(>;`b;80);0b;`symbol$()] /1b
(delete from t where a=`telesales) ~ ![t;enlist (=;`a; enlist `telesales);0b;`symbol$()] /1b

select a,b,c,idx:i from t where i within 2 4

/get the hourly lowest and highest price
n:1000
stocks:`goog`amzn`msft`intel`amd`ibm
trade:([]stock:n?stocks; price:n?100.0;amount:100*10+n?20;time:n?24:00:00.000)
select low:min price,high:max price by stock,hour:time.hh from trade

/extract the time of the lowest and highest prices?
n:3000
t:`time xasc ([] time:09:30:00.0+n?23000000; sym:n?`AAPL`GOOG`IBM; price:50+(floor (n?0.99)*100)%100)
t
meta t
f:{select high:max price,
 low:min price,
 c:count where price=max price,
 time_high0:first time where price=max price,
 time_high9:last time where price=max price
 by sym,time.hh from x}
f[t]

/extract regular time series from observed quotes
n:300
t:`time xasc ([] time:09:30:00.0+n?23000000; sym:n?`AAPL`GOOG`IBM; bid:50+(floor (n?0.99)*100)%100; ask:51+(floor (n?0.99)*100)%100);
`minute xasc select last bid, last ask by sym,1 xbar time.minute from t

/https://code.kx.com/q/ref/xbar/
t:([]time:`s#10:00:00+asc 10?3600)
x:`s#10:00+00:00 00:08 00:13 00:27 00:30 00:36 00:39 00:50
select count i by 10 xbar time.minute from t
select time by x x bin time.minute from t

/better solution would be to use aj (*)
/TODO:fby https://code.kx.com/q4m3/9_Queries_q-sql/#9134-meaty-queries
n:300
t:`time xasc([]time:09:30:00.0+n?23000000;sym:n?`AAPL`GOOG`IBM;bid:50+(floor (n?0.99)*100)%100;ask:51+(floor (n?0.99)*100)%100)
select time,sym,bid,ask from t
select `second$time,sym,bid,ask from t

v:{$[-11h=@x;.$[":"=*t:$x;`$t,"/";x];x]};
.Q.v
.Q.ft:{
 $[
  $[99h=@t:v y;
   98h=@. t;
   0];
  [n:#+!y;n!x 0!y];
  x y
  ]
 };
res: aj[
 `sym`time;
 ([]sym:`AAPL`IBM`GOOG)
 cross
 ([]time:09:30:00+til `int$(16:00:00 - 09:30:00));
 select `second$time,sym,bid,ask from t
 ]
t

([]c1:1 2)
cross
1 2 3 cross `a`b

/cross
x:1 2 3
y:`a`b
k)#x /3
k)#y /2
k)(#x)##y /2 2 2
k)m:&(#x)##y /0 0 1 1 2 2
k)n:#m:&(#x)##y /6
x[m] / 1 1 2 2 3 3
n#y  /`a`b`a`b`a`b
(x[m],'n#y)~x cross y /1b

x:([]sym:`IBM`GOOG)
y:([]time:09:30:00+til 3)
k)m:&(#x)##y
k)n:#m
(x cross y)~x[m],'n#y /1b
(x cross y)~raze x,/:\:y

x:`a`b`c!10 20 30
y:`x`y!100 200
cross
k)m:&(#x)##y
k)n:#m
k)((!x)[m],'n#!y)
k)(. x)[m],'n#. y
raze x,/:\:y
z:x cross y
z[`a`x]

/(*)
/aj:{.Q.ft[.Q.ajf0[0;1;x;;z]]y}
n:300;
t:`time xasc([]time:09:30:00.0+n?23000000;sym:n?`AAPL`GOOG`IBM;bid:50+(floor (n?0.99)*100)%100;ask:51+(floor (n?0.99)*100)%100)
t:select `minute$time,sym,bid,ask from t
ts:([]sym:`AAPL`IBM`GOOG) cross ([]time:09:30+til `int$(16:00 - 09:30))
`time xasc aj[`sym`time;ts;t]
/in case of nonkeyed t it would be same as:
`time xasc .Q.ajf0[0;1;`sym`time;ts;t]

/ .Q.ft
t1:`n xasc flip`n`sym`time`prise`size!5?'(100,`3,.z.t,100f,10000)
t2:1!t1
.Q.ft[{x 0 1};t1]
.Q.ft[{x 0 1};t2]
/ .Q.ajf0
{[f;g;x;y;z]
 / x:symbols set, list
 / y:target table we apply function to
 / z:what we use to create application function, non-keyed
 d:x_z; /d:z without x columns
 $[&/j:-1<i:(x#z)bin x#y;
  ,'[y;d i];
  +.[+.Q.ff[y]d; (!+d;j); :; .+d i j:&j]
  ]
 }

(`n`m1`m2!1 10 100) , (+(,`n)!,1 20)!+`v1`v2!(11 21;101 201)
(`n`m1`m2!2 20 200) , (+(,`n)!,1 20)!+`v1`v2!(11 21;101 201)
 `n`m1`m2`v1`v2!1 10 100 11 101
 `n`m1`m2`v1`v2!2 20 200 0N 0N
ttt0
k)+`n`v1`v2!(1 20;11 21;101 201) /same as
(`n`v1`v2!1 11 101; `n`v1`v2!20 21 201)
ttt1
k)(+(,`n)!,1 20)!+`v1`v2!(11 21;101 201) /same as
((enlist`n)!(),1; (enlist`n)!(),20)!(`v1`v2!11 101; `v1`v2!21 201)

/ keyed table is a dictionary
show d:(`n`m!`a`b;`n`m!`x`y)!(`c1`c2!10 20;`c1`c2!100 200)
/ take by key
(`n`m!`a`b;`n`m!`a`b)#d /with keys
d(`n`m!`a`b;`n`m!`a`b)  /without keys

d:(`n`v1`v2!1 11 101; `n`v1`v2!20 21 201)
`v1`v2`v3#/:d /ok to get nonexist col line by line
`v1`v2`v3#d /err
(flip d)[`v1]~d[`v1]

(flip t1:`c1`c2!(1 2;10 20))~t2:(`c1`c2!(1 10);`c1`c2!(2 20))
t1[`c1]~t2[`c1]
