// join is a very fruitful function

/trivial
1,2
1,2 3
1 2,3

/(dict,dict): add columns
d1:     `a`b  ! 1 2
d2:       `b`c!   3 4
(d1,d2)~`a`b`c! 1 3 4

/(table,table): add rows
t1:(enlist `a`b!1 2)
t2:(enlist `a`b!3 4)
(t1,t2) ~ (`a`b!1 2;`a`b!3 4)

/(keyed table,keyed table): add rows
k1:(`a`b!1 2;`a`b!3 5)!(`c`d`e!10 20 30;`c`d`e!40 50 60)
k2:(`a`b!1 2;`a`b!3 4)!(`c`d`e!15 25 35;`c`d`e!45 55 65)
(k1,k2)
/ a b| c  d  e 
/ ---| --------
/ 1 2| 15 25 35
/ 3 5| 40 50 60
/ 3 4| 45 55 65

/(dict,keyed table): add cols
k2:(`a`b!1 2;`a`b!3 4)!(`c`d`e!15 25 35;`c`d`e!45 55 65)
/                  a b| c  d  e 
/                  ---| --------
d1:     `a`b`c`d  !1 2  10 20
/                  1 2| 15 25 35
/                  3 4| 45 55 65
(d1,k2)~`a`b`c`d`e!1 2  15 25 35
