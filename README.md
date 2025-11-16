# DaphniaRNAvirus
RNA virus discovery from metatranscriptomes of Daphnia pulex.


## Workflow:
### Step 1: Download Data
I used SRA records from Hechler et al. in [Molecular Ecology](https://onlinelibrary.wiley.com/doi/10.1111/mec.17152).
```
cat Auxfiles/Daphnia_libraries.txt | awk -F "\t" '{print$3}' |while read line
do
echo ${line} |awk -F ";" '{print"ftp://"$1"\nftp://"$2}'
done > links.tmp
```
```
## This may take a file depending on the internet connection:

cat links.tmp |while read link 
do
wget ${link}
done 
```
## 
