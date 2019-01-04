## on myDf : select_cols cols c1, c2, c3 : count 
## on dataframe : drop_cols cols c1, c2, c3 : count
## on df : select_cols cols c1, c2 : count
## on df : select_cols cols c1, c2, c3 : count

## on df : drop_rows 

myDf.select(c1, c2, c3).count()
dataframe.select(c1, c2, c3).count()
df.select(c1, c2).count()
df.select(c1, c2, c3).count()


