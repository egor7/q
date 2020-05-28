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

/better solution would be to use aj
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