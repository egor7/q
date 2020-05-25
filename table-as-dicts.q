//https://qriouskdb.wordpress.com/2018/12/15/flipped-tables/

/ways to create a table
t1:([]a:`a`b`c; b:10 20 30)
t2:(`a`b!(`a;10); `a`b!(`b;20); `a`b!(`c;30))
t3:flip `a`b!(`a`b`c;10 20 30)
t1~t2 /1b
t2~t3 /1b
(`a`b!(`a;10); `a`b!(`b;20); `a`b!(`c;30))

`a`b!((`a;10); (`b;20); (`c;30))

/enlists
(flip enlist `a`b!(`a;10)) ~ `a`b!(`a;10) /0b
(flip enlist `a`b!(`a;10)) ~ `a`b!(enlist `a;enlist 10) /1b

/what table is:
/ a.list of dictionaries (t2)
/ b.dictionary of list flipped (t3)

/1.enlisted dictionary is a table (a.)
type enlist `a`b!(`a;10) /98h

t:(`a`b!(`a;10); `a`b!(`b;20); `a`b!(`c;30))
(flip t)[`a]~t`a /1b

/rw funcs
raze{([] parent:enlist first i; child:enlist last i:x where x in .Q.n )} each ("parent:2 child:3";"parent:5 child:4")
raze{([parent:enlist first i];child:enlist last i:x where x in .Q.n)}each("parent:2 child:3";"parent:5 child:4";"parent:2 child:1")
{`parent`child!x where x in .Q.n}each("parent:2 child:3";"parent:5 child:4";"parent:2 child:1")
{0N!x} each t

t:(`a`b!(`a;10); `a`b!(`b;20); `a`b!(`c;30))
(flip 1#t) ~ first 1#t /0b
