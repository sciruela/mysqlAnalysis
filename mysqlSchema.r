library("ggplot2") 
library("reshape2")
library("RMySQL")

connection<-dbConnect(MySQL(), user="root", password="",host="127.0.0.1",port=3306,dbname='')

pdf("/Users/sciruela/Documents/mysqlSchema/graph1.pdf")
query<-"SELECT TABLE_SCHEMA,SUM(DATA_LENGTH) SCHEMA_LENGTH FROM information_schema.TABLES WHERE TABLE_SCHEMA!='information_schema' GROUP BY TABLE_SCHEMA"
result<-dbGetQuery(connection,query)
result$TABLE_SCHEMA<-reorder(result$TABLE_SCHEMA,result$SCHEMA_LENGTH)
p<-ggplot(result)+geom_bar(aes(x=TABLE_SCHEMA,y=SCHEMA_LENGTH))+coord_flip()
p<-p+xlab("Size")+ylab("")
p<-p+opts(title="Schemas' size")
print(p)
dev.off()

pdf("/Users/sciruela/Documents/mysqlSchema/graph2.pdf")
query<-"SELECT TABLE_SCHEMA,TABLE_NAME,TABLE_ROWS,DATA_LENGTH FROM information_schema.TABLES WHERE TABLE_SCHEMA!='information_schema'"
result<-dbGetQuery(connection,query)
result<-within(result,TABLE_NAME<-factor(TABLE_NAME,levels=sort(TABLE_NAME,decreasing=TRUE)))
p<-ggplot(result)+geom_bar(aes(x=TABLE_NAME,y=DATA_LENGTH))+coord_flip()+facet_wrap(~TABLE_SCHEMA,scales='free')
p<-p+xlab("Size")+ylab("")
p<-p+opts(title="Tables' size")
print(p)
dev.off()

pdf("/Users/sciruela/Documents/mysqlSchema/graph3.pdf")
query<-"SELECT TABLE_SCHEMA,TABLE_NAME,100*TABLE_ROWS/FLOOR(MAX_DATA_LENGTH/AVG_ROW_LENGTH) AS USED FROM information_schema.TABLES WHERE TABLE_SCHEMA!='information_schema'"
#   query<-"SELECT TABLE_SCHEMA,TABLE_NAME,RAND(42)*100 AS USED FROM information_schema.TABLES WHERE TABLE_SCHEMA!='information_schema'"

result<-dbGetQuery(connection,query)
result$LEFTOVER<-100-result$USED
result<-within(result,TABLE_NAME<-factor(TABLE_NAME,levels=sort(TABLE_NAME,decreasing=TRUE)))
result<-melt(result,id.vars=c("TABLE_SCHEMA","TABLE_NAME"),variable.name='TYPE',value.name='PROPORTION',na.rm=TRUE)
p<-ggplot(result)
p<-p+geom_bar(aes(x=TABLE_NAME,y=PROPORTION,fill=TYPE),stat='identity')
p<-p+coord_flip()+facet_wrap(~TABLE_SCHEMA,scales='free')
p<-p+scale_fill_manual(values=c("USED"='#DD0000',LEFTOVER='#AAAAAA'))
p<-p+xlab('')+ylab('')+opts(title="Tables' usage")
print(p)
dev.off()


pdf("/Users/sciruela/Documents/mysqlSchema/graph4.pdf")
query<-"SELECT TABLE_SCHEMA, MAX(100*TABLE_ROWS/FLOOR(MAX_DATA_LENGTH/AVG_ROW_LENGTH)) AS USED FROM information_schema.TABLES WHERE TABLE_SCHEMA!='information_schema' GROUP BY TABLE_SCHEMA"
#   query<-"SELECT TABLE_SCHEMA, MAX(100*RAND(42)) AS USED FROM information_schema.TABLES WHERE TABLE_SCHEMA!='information_schema' GROUP BY TABLE_SCHEMA"

result<-dbGetQuery(connection,query)
result$LEFTOVER<-100-result$USED
result$TABLE_SCHEMA<-reorder(result$TABLE_SCHEMA,result$USED)
result<-melt(result,id.vars=c("TABLE_SCHEMA"),variable.name='TYPE',value.name='PROPORTION',na.rm=TRUE)
p<-ggplot(result)
p<-p+geom_bar(aes(x=TABLE_SCHEMA,y=PROPORTION,fill=TYPE),stat='identity')
p<-p+coord_flip()
p<-p+scale_fill_manual(values=c("USED"='#DD0000',LEFTOVER='#AAAAAA'))
p<-p+xlab("")+ylab("")+opts(title="Largest Usage")
print(p)
dev.off()
dbDisconnect(connection)
