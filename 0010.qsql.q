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

time:.z.t
7h$time mod 1000
time

n:1000
stocks:`goog`amzn`msft`intel`amd`ibm
trade:([]stock:n?stocks; price:n?100.0;amount:100*10+n?20;time:n?24:00:00.000)

/get the hourly lowest and highest price
select low:min price,high:max price by stock, time.hh from trade

/extract the time of the lowest and highest prices?
