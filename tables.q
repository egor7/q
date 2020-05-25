/https://qriouskdb.wordpress.com/2019/03/09/except-tables/
show trade:([] time:.z.p; sym:5?`AAPL`GOOG`IPM`JPM`GE; price:5?100.0; side:5?`B`S)
show buy:select from trade where side=`B
show sell:select from trade where side=`S

select from trade where trade in sell
select from trade except sell
trade where trade in sell
trade except sell

(`time`sym#trade) ~ select time,sym from trade /1b

/https://qriouskdb.wordpress.com/2019/05/25/upsert-vs-insert/
tab:flip`time`sym`price`qty!"PSFJ"$\:()
`tab upsert (.z.p;`IPM;50f;15)
`tab insert (.z.p;`IPM;50f;15)

/We can also add new records to a keyed table:
tab:1!flip`ID`time`sym`price`qty!"JPSFJ"$\:()
tab upsert(1;.z.p;`IPM;50f;15)
`tab upsert(1;.z.p;`IPM;50f;15)
tab upsert(1;.z.p;`IPM;50f;15)
`tab insert(2;.z.p;`IPM;50f;15)

/1.insert requires a symbol as the first argument.

{t:flip`time`sym`price`qty!"PSFJ"$\:();`t insert(.z.p;`IPM;50f;15)}[]
show t:flip`time`sym`price`qty!"PSFJ"$\:()
{`t insert(.z.p;`IPM;50f;15)}[]

tab:([]time:5?.z.p;sym:upper 5?`3;price:5?50f;qty:5?50)
`:tab/ upsert .Q.en[`:.;tab]
count get `:tab /5

tab:([]time:5?.z.p;sym:upper 5?`3;price:5?50f;qty:5?50)
`:tab upsert .Q.en[`:.;tab]
count get `:tab /10

tab:([]time:5?.z.p;sym:upper 5?`3;price:5?50f;qty:5?50)
upsert[`:tab; .Q.en[`:.;tab]]
(upsert).(`:tab; .Q.en[`:.;tab])
upsert /.[;();,;]
