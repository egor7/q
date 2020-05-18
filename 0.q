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
