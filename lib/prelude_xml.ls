@prelude__init=~> this[it] = prelude[it]
prelude.each prelude__init, <[ id isType replicate List each map compact filter reject partition find head first tail last initial empty reverse unique uniqueBy fold foldl fold1 foldl1 foldr foldr1 unfoldr concat concatMap flatten difference intersection union countBy groupBy andList orList any all sort sortWith sortBy sum product mean average maximum minimum maximumBy minimumBy scan scanl scan1 scanl1 scanr scanr1 slice take drop splitAt takeWhile dropWhile span breakList zip zipWith zipAll zipAllWith at elemIndex elemIndices findIndex findIndices Obj keys values pairsToObj objToPairs listsToObj objToLists empty each map filter compact reject partition find Str split join lines unlines words unwords chars unchars repeat capitalize camelize dasherize empty reverse slice take drop splitAt takeWhile dropWhile span breakStr Func apply curry flip fix over memoize Num max min negate abs signum quot rem div mod recip pi tau exp sqrt ln pow sin cos tan asin acos atan atan2 truncate round ceiling floor isItNaN even odd gcd lcm ]>

@blaze__init=(tag)~>this[tag]=HTML[tag.toUpperCase!]
each blaze__init, <[ aside video track source polygon svg b input link h5 h6 strong img meta source br hr div span a p h4 h3 h2 h1 button table thead tr th tbody td small ul ol li span label select option textarea form output i sub time section html head body title script footer header article link nav figure figcaption tfoot video source type iframe ]>

@main_blaze = HTML[\MAIN]
@header_blaze = HTML[\HEADER]

@D =( cls, ...args)-> div class:cls, args

@P =( cls, ...args)-> p class:cls, args 

@d =(cls, ...args)-> 
    if cls.indexOf(\.)>-1 && cls.match(/[\S]+/g) 
        cls .= replace /\./g ' '
        HTML[\DIV] class:cls, args
    else HTML[\DIV] cls, args

@T =(o,code)->
    if typeof o is \object
        Router.route o.name, path:o?path||(\/ + o.name)
        template o.name, code
    else 
        Router.route o, path:\/ + o
        template o, code

 