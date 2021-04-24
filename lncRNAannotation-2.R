'''
@�ļ�    :lncRNA-2.r
@˵��    :
@ʱ��    :2021/04/24 13:43:03
@����    :½�س�
@�汾    :1.0
@Email   :lu_baicheng@163.com
'''


#install.packages("DealGPL570")
#BiocManager::install("limma")
library(DealGPL570)#����GEO���ݿ���GPL570ƽ̨�����еı�����ԭʼ���ݣ���ԭʼ���ݴ����ɱ���������
library(limma)
setwd("C:\\Users\\½�س�\\Desktop\\DKD")#���ù���·��
file<-list.files(pattern = "GSE79973_RAW.tar",full.names = T)#����GEO�����ص�GSE79973_RAW.tarԭʼ���ݵ���
result<-DealGPL570(file = file)#��DealGPL570���������GSE79973��ԭʼ���ݣ���һ��̽��ID���ڶ���GENE symbol��������������Ļ������ֵ
ENSG<-read.table("ENSG.txt",header = F,quote="",sep = "\t",check.names = F)
Ref<-read.table("Ref.txt",header = F,quote="",sep = "\t",check.names = F)
Ensembl_ZS<-read.table("Ensembl_ZS.txt",header = T,quote="",sep = "\t",check.names = F)
Refseq_ZS<-read.table("Refseq_ZS.txt",header = T,quote="",sep = "\t",check.names = F)

ENSG_lnc<-Ensembl_ZS[which(Ensembl_ZS$`Gene type`=="lncRNA"),]#������������lncrna��ENsembleID��ȡ����
REF_lnc<-Refseq_ZS[which(Refseq_ZS$`Gene type`=="lncRNA"),]#������������lncrna��RefseqID��ȡ����

m<-as.character(ENSG_lnc$`Gene stable ID`)
prode_ENSG_lnc<-ENSG[which(ENSG[,2]%in%c(m)),]  #�ҵ�̽����ENsembleID���л���������Lncrna�Ķ�Ӧ��ϵ
n<-as.character(REF_lnc$`RefSeq ncRNA ID`)
prode_REF_lnc<-Ref[which(Ref[,2]%in%c(n)),]#�ҵ�̽����RefseqID���л���������lncrna�Ķ�Ӧ��ϵ


result_prode_ENSG_lnc<-unique(prode_ENSG_lnc[,1])
result_prode_REF_lnc<-unique(prode_REF_lnc[,1])
expre<-result[which(result$probe_id%in%c(as.character(union(result_prode_ENSG_lnc,result_prode_REF_lnc)))),]
expre<-expre[!duplicated(expre[,'probe_id']),]#��̽��ID����ȥ�أ���Ϊһ��̽����Ӧ�������
expre<-aggregate(x=expre[,3:(ncol(expre))],by=list(expre$symbol),FUN=mean)#��һ�������Ӧ���̽��ȡƽ��ֵ
#����������Start
group<-rep(c("case","control"),10)#����geo���ݿ�����Ϣ��ʾ������case,control˳�����λ�����10�顣
design<-model.matrix(~0+factor(group))
colnames(design)<-levels(factor(group))
rownames(design)<-colnames(expre[,2:ncol(expre)])
fit<-lmFit(expre[,2:ncol(expre)],design)
cont.matrix<-makeContrasts("case-control",levels = c("case","control"))
fit2<-contrasts.fit(fit,cont.matrix)
fit2<-eBayes(fit2)
tempOutput<-topTable(fit2,coef=1,n=Inf,adjust="BH")
diff<-na.omit(tempOutput)#ȥ����ֵ��
#����������Finsh
diff<-cbind(expre$Group.1,diff)
expre_df<-diff[which(diff$'P.Value'<0.01),]#�õ���������lncrna
names(expre_df)[1]<-"Gene_symbol"
write.table(expre_df,"expre_df.txt",row.names = F,col.names = T,sep = "\t",quote =F)