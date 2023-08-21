



# 1. cloudshell



## 1) dockerize from tsl0922/ttyd



### (1) 실행

```sh
$ docker run -it --rm -p  7681:7681 tsl0922/ttyd

004bb0c386ae ...

```



### (2) 필요한 solution 설치

```sh
apt update
apt install vim 
apt install net-tools 
apt install iputils-ping
apt install netcat
apt install ssh
apt install curl
```





### (3) commit

```sh
$ docker commit -p cloudshell ssongman/cloudshell:tsl0922_202308220152

$ docker push ssongman/cloudshell:tsl0922_202308220152


```





### (4) test

```sh

$ docker run -it --rm -p 7681:7681 --name cloudshell ssongman/cloudshell:tsl0922_20230822

```





## 2) [참고] dockerize



### ㅇ 빌드1

```sh
cd ~/song/githubrepo/cloudshell

docker build -t ssongman/cloudshell -f Dockerfile .

docker push ssongman/cloudshell
```





### ㅇ 빌드2 - simple

```sh
cd ~/song/githubrepo/cloudshell

docker build -t ssongman/cloudshell:simple_20230821 -f Dockerfile_simple .

docker run --name cloudshell ssongman/cloudshell:simple_20230821


docker run -it --rm -p 7681:7681 ssongman/cloudshell:simple_20230821 bash
```




​				

### ㅇ 빌드3 - origin

```sh
$ cd ~/song/githubrepo/cloudshell

$ docker build -t ssongman/cloudshell:origin_20230821 -f Dockerfile_origin .

docker run --name cloudshell --rm ssongman/cloudshell:origin_20230821 -p 7681

docker run --name cloudshell --rm ssongman/cloudshell:origin_20230821 -W bash

docker run --name cloudshell --rm ssongman/cloudshell:origin_20230821 pwd
```





### ㅇ clean up

```sh
docker rm -f cloudshell
```



# 2. authnginx



```sh

$ mkdir -p  ~/song/authnginx
$ cd ~/song/authnginx


```





### index.html

```xml
<!DOCTYPE html>
<html lang="ja">
<head>
	<meta charset="utf-8" />
	<title>Authorized Area</title>
</head>
<body>
	<p>Here is an Authorized Area.</p>
</body>
</html>
```





### gen_htpasswd

```sh
#!/bin/bash

USER_NAME=song
PASSWD=songpass
CRYPTPASS=`openssl passwd -crypt ${PASSWD}`

echo "${USER_NAME}:${CRYPTPASS}" >> /etc/nginx/.htpasswd
```





### default.conf

```nginx
server {
    listen 8080;
    
    # auth 설정
    # proxy pass 설정
    location / {
        #root   /usr/share/nginx/html;
        #index  index.html index.htm;
    	auth_basic	"Restricted";
    	auth_basic_user_file	/etc/nginx/.htpasswd;
    	proxy_pass http://localhost:7681;
    }
}
```











## Dockerize



### Dockerfile

```Dockerfile

FROM nginx:1.23

# COPY nginx.conf /etc/nginx
COPY default.conf /etc/nginx/conf.d
COPY gen_htpasswd /etc/nginx

RUN apt update
RUN apt install -y openssl

RUN chmod 777 /etc/nginx/gen_htpasswd
RUN /etc/nginx/gen_htpasswd



```





### docker build & push

```sh


$ docker build -t ssongman/authnginx:202308220251 .
$ docker build -t ssongman/authnginx:202308220311 .


$ docker push ssongman/authnginx:202308220251
$ docker push ssongman/authnginx:202308220311


# docker run
$ docker run --name authnginx --rm -p 8081:8080 ssongman/authnginx:202308220251

$ docker rm -f authnginx

# test
$ curl localhost:8081

http://localhost:8081/



```













# 3. k8s deploy

## 1) deploy

```sh
# namespace
$ kubectl create namespace cloudshell


# deploy
$ kubectl -n cloudshell create deploy cloudshell --image=ssongman/cloudshell -- sleep 365d


# svc
$ kubectl -n cloudshell expose deployment/cloudshell --port 80


# ingress
$ kubectl -n cloudshell create ingress cloudshell \
  --rule="cloudshell.ssongman.duckdns.org/=cloudshell:80"
  

$ kubectl create ingress simple --rule="foo.com/bar=svc1:8080,tls=my-cert"

kubectl create ingress catch-all --class=otheringress --rule="/path=svc:port"
```



## 2) deploy yaml

```yaml
# 아래 내용으로 수정

 
--
    spec:
      containers:
      - image: ssongman/cloudshell:tsl0922_202308220152
        name: cloudshell
        ports:
        - containerPort: 7681
          protocol: TCP
      - image: ssongman/authnginx:202308220251
        name: authnginx
        ports:
        - containerPort: 8080
          protocol: TCP
--

```



















## 3) clean up

```sh
$ kubectl -n cloudshell delete deploy  cloudshell
$ kubectl -n cloudshell delete svc     cloudshell
$ kubectl -n cloudshell delete ingress cloudshell

```



