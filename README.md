# Remote Script

[사용법]


1. 프로젝트 루트 디렉토리에 .env 파일 생성
```
PRIVATE_KEY=[개인키 경로]
```


2. .profile에 아래 문구 추가

```
alias sc='bash .../remote-script/config/select_host.sh'
alias remote='go run .../remote-script/main.go'
```

2. sc + 검색어로 선택할 서버 검색


3. remote-script/scripts에 원격으로 사용할 스크립트 파일 저장 후 사용

```
remote [스크립트명.sh]
```