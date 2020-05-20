/format  0: [ delimiter;     t]
/save    0: [ filesymbol;    strings]
/read0   0::[(filesymbol,o,n)]
`:t0 0: ("bar";"baz")
`:t0 0: "|" 0: ([] n:1+til 3;t:2020.01.01+3?30)
`:t0 0::
(`:t0;4;12) 0::
h1:hopen `:t0
neg[h1] "qux"
hclose h1

/`:t1 1: 255h
hdel`:t1;
h1:hopen `:t1
h1[255h]
hclose h1

/same
0x0 sv reverse 1::[`:t1 1: (reverse 0x0 vs 255h)]
(enlist "h";enlist 2) 1: `:t1
(enlist "h";enlist 2) 1: (reverse 0x0 vs 255h)
(enlist "i";enlist 4) 1: (reverse 0x0 vs 255i)

/how to get byte sequence
/in the same simple way as it being read, see prev
/`:t1 1: 255h

/set variant
`:tt set 255 1001h
.[`:tt;();:;0xa199]
get `:tt

/read formatted
("SI*";enlist":") 0: ("s:i:ss";"aa:1:str1";"bb:2:str2";"cc:3:str3")
(!/)"I=;"0:"0=aa;1=bb;2=bc"
(0::) `:_w 0: string system "w"
("J ";";") 0: `:_w 0: string system "w"

/full cycle
// https://code.kx.com/q/kb/loading-from-large-files/
// https://github.com/KxSystems/cookbook/blob/master/dataloader/gencsv.q
gen1day:{[date;n] ([]
  sourcetime:`timestamp$date+asc 09:00:00.0 + n?08:00:00.0;
  inst:n?(1000?`4); //?
  price:n?100f;
  size:n?10000;
  e1:n?20;
  x:n?(`N`O`L`X);
  e2:n?10)
 }
/memory
show t:gen1day[2020.01.21;5]
show s:"|" 0: t
("psfjjsj";enlist"|") 0: s
("psfjjsj";enlist"|") 0: "|" 0: gen1day[2020.01.21;5]
/disk
`:t0 0: "|" 0: t
("psfjjsj";enlist"|") 0:  `:t0
("psfjjsj";enlist"|") 0: (`:t0 0::)
hdel `:t0

// ?question about table meta
// how to read from csv file to renamed columns
