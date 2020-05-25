\ts:100000 10 vs 123
\ts:100000 "J"$/:string 123
\ts:100000 "J"$' string 123
\ts:100000 value each string 123
\ts:100000 .Q.n?string 123

show n:5?1000
10 vs/:n
10 vs' n
("J"$/:)'[string n] /ok
("J"$/:)/:[string n] /err
"J"($/:)/:string n /ok

show n:string 5?1000
($/:)/:["J";n]
($/:)'["J";n]
($')'["J";n]
("J"$')'[n]
$''["J";n]
"J"($')'n
"J"$/:/:n
"J"$''n

value each ' n /ok ?
value each/: n /ok ???

(value')'[n] /ok
value''[n] /ok
(value') each n /ok
value' each n /err ???
(value each)'[n] /ok

'['[value]][n] /ok
each[each[value]][n] /ok

value each'n /ok
(value each)'[n] /ok
value (each') n /err
value each' [n] /err same
value each [n] /err pretty same
parse"count each n"
parse"count each [n]"
/ that's the case!
/ each is a function!, and it try to apply [n] as a first arg

value each'n
each'[n] /err pretty pretty same
/ k){x'y}'[("45";"745";"898";"935";"64")]
/pseudo code:
/value {x'y}' n
parse"count each n"
parse"count {x'[y]} n"
count {x'[y]} n / err, seems like q make `each` infix
/ [n] is a parameter for each
parse"count each [n]"
parse"count {x'[y]} [n]"

(value each')n /ok
(value '')n /ok
(value')'[n] /ok
value''[n] /ok
value (each') n

parse "count each' n"
parse "count {x'[y]}' n"
parse "count each'[n]" /err
parse "count each' n" /same
parse "(each')[count;n]" /same

/for ' we should pointout about single arg always
/but for each we should not never,  it wants it left arg

m:(1;2;(3;(5;6;(7 8 9))))
count m
3
count each m
1 1 2
count each' m
1
1
1 3
count each'' m
1
1
(1;1 1 3)
count each''' m
1
1
(1;(1;1;1 1 1))

parse "count each m"
parse "count each[m]"
parse "count each''' m"
parse "count each'''[m]"
