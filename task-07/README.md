```bash
export GOPATH=$WORKSPACE
export PATH="$PATH:$(go env GOPATH)/bin"

sed -i 's/1.DEVELOPMENT/1.$BUILD_NUMBER/g' ./rice-box.go

make

md5sum artifacts/*/word-cloud-generator* >artifacts/word-cloud-generator.md5

gzip artifacts/*/word-cloud-generator*
```

```bash
sudo service wordcloud stop

curl -X GET -u admin:admin "http://192.168.50.11:8081/repository/word-cloud-generator/1/word-cloud-generator/1.$BUILD_NUMBER/word-cloud-generator-1.$BUILD_NUMBER.gz" -o /opt/wordcloud/word-cloud-generator.gz
gunzip /opt/wordcloud/word-cloud-generator.gz
chmod +x /opt/wordcloud/word-cloud-generator

sudo service wordcloud start
```

```bash
res=`curl -s -H "Content-Type: application/json" -d '{"text":"ths is a really really really important thing this is"}' http://192.168.50.20:8888/version | jq '. | length'`
if [ "1" != "$res" ]; then
  exit 99
fi

res=`curl -s -H "Content-Type: application/json" -d '{"text":"ths is a really really really important thing this is"}' http://192.168.50.20:8888/api | jq '. | length'`
if [ "7" != "$res" ]; then
  exit 99
fi
```
