            initWith  preprocess       aggExpression                special/acc Cols
`sym        `         `sym
`time       00:00     `time.minute
`high       0n        "max price"      "row[`high]|inp`high"        "?[isFirst;inp`;]"
`low        0n        "min price"      "row[`low]&inp`low"          "?[isFirst;inp`;]"
`firstPrice 0n        "first price"    "row`firstPrice"             "?[isFirst;inp`;]"
`lastPrice  0n        "last price"     "inp`lastPrice"
`firstSize  0N        "first size"     "row`firstSize"              "?[isFirst;inp`;]"
`lastSize   0N        "last size"      "inp`lastSize"
`numTrades  0         "count i"                                     "row[`]+inp`"
`volume     0         "sum size"                                    "row[`]+inp`"
`pvolume    0f        "sum price"                                   "row[`]+inp`"
`turnover   0f        "sum price*size"                              "row[`]+inp`"
`avgPrice   0n                         "pvolume%numTrades"
`avgSize    0n                         "volume%numTrades"
`vwap       0n                         "turnover%volume"
`cumVolume  0                          "row[`cumVolume]+inp`volume"

aggCols:         reverse key[initWith] except `sym`time;
updateAgg:
{[aggTable;idx;inp]
  row:aggTable idx;
  isFirst:0=row`numTrades;
  .[aggTable;;:;]'[(idx;)each aggCols; (" , (";" sv string[aggCols],' ":",/:aggExpression    aggCols) , ")]};
            ^  ^                                                      ===================
            |  |                                                      : перед aggExpr
            |  |                                           aggCols перед :
            |  |                             ======> соединим ;
/итого изготовим список для
(firstPrice:?[isFirst;inp`;];
 lastPrice :inp`lastPrice)
            |
     idx firstPrice
     idx lastPrice
.[`t;;:;]'[(0;)each`price`size;(0.10;-10)]

init:{
  tradeAgg :: 0#enlist[initWith];
  currTime :: 00:00;
  offset   :: 0;
 };
roll:{[tm]
  if[currTime>tm; :init[]];
  offset::count tradeAgg;
 };

upd:{[tblName;data] / tblName not used but required
 updMinute[data] each exec distinct time from data:() xkey preprocess data
 };
updMinute:{[data;tm]
  if[tm<>currTime; roll tm; currTime::tm];
  data:select from data where time=tm;
  updateAgg[`tradeAgg;offset;data];
 };

/ test
syms:`IBM`AAPL`GOOG,-9997?`8
rnd:{[n;t] ([] sym:n?syms; time:t+asc n#til 25; price:n?10f; size:n?10)}
rnd[10000;00:00]


