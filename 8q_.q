/http://www.nsl.com/papers/qn.htm
/_dvl means ^
,/
{$[n=#*x;
  ,*x;
  ,/                   / raze
  .z.s'f
      x,
         \:/:          / cross
              (!n)^,/x / remove x from n!
  ]
}'

n=8

/8=count first x
{enlist first x}'[(f:0 -1 1+/:)til 8]
/main case
row:til 8
{row where not row in x}'[(f:0 -1 1+/:)til 8]
{x,\:/: row where not row in x}'[(f:0 -1 1)+/:til 8]
