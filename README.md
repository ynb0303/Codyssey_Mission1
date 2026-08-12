# 프로젝트 구조

​```bash
docker-mission/
├── Dockerfile        # nginx 기반 이미지 빌드 정의
├── index.html        # 컨테이너에 복사되는 정적 웹 페이지
└── README.md         # 실습 기록 및 결과 문서
​```

재현 방법: 이 폴더를 클론한 뒤 `docker build -t my-web .` → `docker run -d -p 8080:80 --name my-web-container my-web` 순서로 실행하면 동일하게 재현할 수 있다.

# 개발 워크스테이션 세팅 미션 (미션1)
## 1. 미션 개요
터미널, Docker, Git을 직접 손으로 세팅해보며, 코드가 "내 컴퓨터에서만 되는" 문제를 줄이고 누구나 같은 방식으로 실행할 수 있는 개발 환경을 구성하였다. 터미널로 작업 디렉토리를 정리하고, Docker로 웹 서버를 컨테이너화한 뒤 포트 매핑, 바인드 마운트, 볼륨을 이용해 "변경 반영"과 "데이터 영속성"을 직접 검증했다. 마지막으로 Git/GitHub로 결과물을 버전 관리하고 원격 저장소에 올렸다.
## 2. 실행 환경

| 항목 | 내용 |
|---|---|
| OS | macOS 15.7.4 (Build 24G517) |
| 셸 | zsh |
| Docker | 28.5.2 |
| Git | 2.53.0 |
| 에디터 | Visual Studio Code |
## 3. 단계별 작업 내용

### 참고: 이미지(Image)와 컨테이너(Container)의 차이

- **이미지**: 실행에 필요한 파일, 설정, 라이브러리를 담은 "불변(immutable)" 템플릿. 
  한 번 빌드되면 내용이 바뀌지 않는다. (예: my-web 이미지)
- **컨테이너**: 이미지를 실제로 "실행"시킨 상태. 이미지 위에 쓰기 가능한 레이어가 하나 더 얹혀서
  실행 중 생긴 변경 사항(로그, 임시 파일 등)은 컨테이너에만 남고 원본 이미지에는 영향을 주지 않는다.
- 같은 이미지로 여러 개의 컨테이너를 동시에 띄울 수 있고, 컨테이너를 지워도 이미지는 그대로 남는다.

### 3-1. 작업 디렉토리 준비

**작업 정리 (삭제 확인)**
\`\`\`bash
touch temp.txt
ls
rm temp.txt
ls
\`\`\`
결과: `temp.txt` 생성 후 `ls`로 확인, `rm`으로 삭제 후 다시 `ls`로 사라진 것을 확인했다.

**목표**: 실습용 작업 공간을 별도 폴더로 분리해서 관리한다.

```bash
cd ~/Desktop
mkdir docker-mission
cd docker-mission
pwd
```

**결과**: `/Users/yyangyn143681/Desktop/docker-mission` 경로에 작업 폴더가 생성됨을 확인했다.

### 3-2. Docker 설치 및 점검

**목표**: 컨테이너를 실행할 수 있는 Docker 환경이 정상 동작하는지 확인한다.
```bash
docker --version
docker ps
docker images
```
**결과**: Docker 28.5.2가 정상 설치되어 있음을 확인했다. `docker ps`로 실행 중인 컨테이너 목록을, `docker images`로 로컬에 저장된 이미지 목록을 확인했다.

**hello-world 컨테이너 실행 확인**
\`\`\`bash
docker run hello-world
\`\`\`
결과: "Hello from Docker!" 메시지 출력으로 Docker 데몬과의 통신, 이미지 pull, 컨테이너 생성/실행까지 
전 과정이 정상 동작함을 확인했다.

### 3-3. 파일 권한 확인 및 변경

### 참고: 파일 권한 확인 및 변경

**목표**: 파일 권한을 확인하고 변경하는 방법을 실습한다.

```bash
ls -l index.html
chmod 644 index.html
ls -l index.html
```

**결과:**
`-rw-r--r--`(644) 권한 확인.

**권한 규칙 (rwx / 숫자 표기)**

권한은 소유자(owner) / 그룹(group) / 기타(other) 세 그룹에 대해 각각 
읽기(r=4) / 쓰기(w=2) / 실행(x=1) 권한을 부여하는 방식이다. 이 셋을 더해 숫자로 표기한다.

- `755` = 소유자: rwx(7), 그룹: r-x(5), 기타: r-x(5) → 실행 파일/스크립트에 흔히 사용
- `644` = 소유자: rw-(6), 그룹: r--(4), 기타: r--(4) → 일반 문서/설정 파일에 흔히 사용

`ls -l` 출력에서 맨 앞 10글자(예: `-rw-r--r--`)로 확인할 수 있다.

### 3-4. Dockerfile로 웹 서버 이미지 빌드

**목표**: nginx 기반 이미지 위에 정적 HTML 파일을 올려 나만의 웹 서버 이미지를 만든다.

`index.html`:
```html
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
</head>
<body>
    <h1>내 첫 Docker 웹서버</h1>
</body>
</html>
```
```dockerfile
FROM nginx:alpine
COPY index.html /usr/share/nginx/html/index.html
```
- `FROM nginx:alpine` : nginx 웹 서버가 이미 설치된 가벼운(alpine) 리눅스 이미지를 기반으로 삼는다는 뜻
- `COPY index.html /usr/share/nginx/html/index.html` : 내 컴퓨터의 index.html 파일을, nginx가 웹 페이지로 인식하는 폴더 안에 복사해 넣는다는 뜻
```bash
docker build -t my-web .
```
- `docker build` : Dockerfile에 적힌 내용대로 이미지를 만들어내는 명령
- `-t my-web` : 만들어질 이미지에 `my-web`이라는 이름표(tag)를 붙인다
- `.` (마침표) : 지금 있는 폴더에서 Dockerfile을 찾으라는 뜻

**결과**: `my-web` 이미지가 정상적으로 빌드되어 `docker images`로 확인됨.

### 3-5. 포트 매핑으로 컨테이너 실행 및 접속 확인

**목표**: 컨테이너 내부 웹 서버(80번 포트)를 호스트(내 컴퓨터)에서 접근 가능하게 연결한다.
```bash
docker run -d -p 8080:80 --name my-web-container my-web
docker ps
```
- `-p 8080:80` : 호스트의 8080번 포트를 컨테이너의 80번 포트(nginx가 듣고 있는 포트)로 연결한다는 뜻
- 컨테이너는 기본적으로 호스트와 분리된 네트워크 네임스페이스에 있어서, 포트를 명시적으로 
연결(`-p`)해주지 않으면 호스트에서 컨테이너 내부 서비스에 접근할 수 없다. 이는 의도치 않은 
서비스 노출을 막기 위한 기본 보안 설계이기도 하다. 실습 환경(로컬)에서는 문제가 없지만, 
운영 환경에서는 필요한 포트만 최소한으로 열고, 방화벽 규칙이나 접근 제어(예: 특정 IP만 허용)를 
함께 고려해야 한다.
- `-d` : 백그라운드에서 계속 실행되게 함 (detached, "떨어져서 돌아간다"는 뜻)
- `--name my-web-container` : 컨테이너에 이름을 붙여서, 나중에 이름으로 컨테이너를 찾기 쉽게 함

브라우저에서 `http://localhost:8080` 접속하여 웹 페이지 렌더링 확인.

**결과**: `docker ps`에서 `Up` 상태와 `0.0.0.0:8080->80/tcp` 포트 매핑을 확인했다. 브라우저에서 "내 첫 Docker 웹서버"라는 제목이 정상적으로 출력됨을 확인했다.

포트 매핑 접속 증거

![Docker 스크린샷](https://github.com/ynb0303/Codyssey_Mission2/blob/main/docs/screenshots/Docker.webp?raw=true)

**참고: 포트 점유 프로세스 확인**

특정 포트가 이미 사용 중인지 확인하려면 `lsof`로 해당 포트를 점유한 프로세스를 조회할 수 있다.

\`\`\`bash
lsof -i :8080
\`\`\`
결과: OrbStack 프로세스가 8080 포트를 LISTEN 상태로 점유하고 있음을 확인했다. 
포트가 이미 사용 중이라면 기존 컨테이너를 정리(`docker rm -f`)하거나, 
다른 호스트 포트(예: `-p 8081:80`)로 변경해 실행할 수 있다.

### 3-6. 바인드 마운트 (Bind Mount)

호스트의 특정 폴더를 컨테이너 내부 경로에 직접 연결하여, 호스트에서 파일을 수정하면 컨테이너에도 즉시 반영되는지 확인했다.

**경로 선택 기준**: `$(pwd)`처럼 상대 경로 기반 명령을 쓰면 실행하는 위치에 따라 결과가 
달라질 수 있어 재현성이 떨어진다. 다른 사람이 그대로 재현하려면 절대 경로(예: 
`/Users/yyangyn143681/Desktop/docker-mission`)를 명시하거나, 최소한 "이 명령은 
docker-mission 폴더 안에서 실행해야 한다"는 조건을 README에 명시하는 것이 안전하다.

**실행 명령**
\`\`\`bash
docker run -d -p 8080:80 --name my-web-bind -v $(pwd):/usr/share/nginx/html nginx:alpine
\`\`\`

**변경 전**
- `index.html` 원본 내용을 브라우저에서 확인 (스크린샷: 링크)

**호스트 파일 수정**
\`\`\`bash
echo "수정 테스트! 바로 반영되나요?" > index.html
\`\`\`

**변경 후**
- 브라우저 새로고침 시 컨테이너 재시작 없이 즉시 변경 내용 반영 확인 (스크린샷: 링크)

→ 바인드 마운트를 사용하면 컨테이너를 재빌드/재시작하지 않아도 호스트 파일 변경이 즉시 컨테이너에 반영됨을 확인했다.

바인드 마운트 (변경 전/후)

**변경 전 (마운트 직후):**

![바인드 마운트 변경 전](./screenshots/bind-mount-before.webp)

**변경 후:**

![바인드 마운트 변경 후](./screenshots/port-mapping-after.webp)

### 3-7. Docker 볼륨 (영속성)

바인드 마운트는 호스트 폴더에 의존하지만, Docker 볼륨은 Docker가 관리하는 별도 저장 공간으로 컨테이너가 삭제되어도 데이터가 유지되는지 검증했다.

**볼륨 생성 및 데이터 기록**
\`\`\`bash
docker run -it --name test -v my-data:/data ubuntu bash
echo "does this data survive?" > /data/test.txt
exit
\`\`\`

**컨테이너 삭제**
\`\`\`bash
docker rm test
\`\`\`

**새 컨테이너로 같은 볼륨 연결 후 데이터 확인**
\`\`\`bash
docker run -it --name test2 -v my-data:/data ubuntu bash
cat /data/test.txt
\`\`\`
결과: `does this data survive?` 출력 확인

→ 컨테이너(test)를 삭제해도 볼륨(my-data)에 저장된 데이터는 유지되며, 새 컨테이너(test2)에서 동일 볼륨을 연결하면 이전 데이터에 그대로 접근 가능함을 확인했다.

**참고: 볼륨 백업 방법**

Docker 볼륨은 호스트에서 직접 파일 탐색기로 열 수 없기 때문에, 임시 컨테이너를 하나 띄워
tar로 압축해서 호스트로 꺼내는 방식을 흔히 사용한다.

​```bash
docker run --rm -v my-data:/data -v $(pwd):/backup ubuntu tar czf /backup/my-data-backup.tar.gz -C /data .
​```

이렇게 하면 `my-data-backup.tar.gz` 파일이 호스트의 현재 폴더에 생성되어, 필요할 때 
새 볼륨에 다시 풀어(restore) 넣을 수 있다.

### 3-8. Git 설정 및 GitHub 연동

**Git 사용자 정보 설정**
\`\`\`bash
git config --global user.name "ynb0303"
git config --global user.email "본인이메일"
git config --global --list
\`\`\`
결과:
\`\`\`
user.name=ynb0303
user.email=본인이메일
\`\`\`

**GitHub 연동**
- VSCode에서 GitHub 계정(ynb0303)으로 로그인 완료 (스크린샷: 링크)
- 원격 저장소(`ynb0303/Codyssey_Mission1`) 연결 및 push 완료
\`\`\`bash
git remote -v
git push origin main
\`\`\`

**결과:**
\`\`\`
origin  https://github.com/ynb0303/Codyssey_Mission1.git (fetch)
origin  https://github.com/ynb0303/Codyssey_Mission1.git (push)
\`\`\`

**3-8. GitHub 연동 증거**
![GitHub 연동 화면](./screenshots/github-connect.webp)

## 4. 트러블슈팅

| # | 문제 | 원인 가설 | 확인 | 해결/대안 |
|---|---|---|---|---|
| 1 | `docker ps-a` 명령이 `unknown command` 에러 | `-a` 옵션과 `ps` 사이 공백 누락 | `docker --help`로 옵션 구문 확인 | `docker ps -a`로 공백 추가하여 해결 |
| 2 | `cat > Dockerfile << 'EOF'` 형태로 heredoc 붙여넣기 시 Dockerfile이 빈 파일로 생성되어 build 에러(`Dockerfile cannot be empty`) 발생 | 터미널 붙여넣기 과정에서 heredoc 종료 마커 인식이 깨짐 | `cat Dockerfile`로 내용이 비어있음을 확인 | `echo` 명령을 줄 단위로 나눠 실행(`>`, `>>`)하여 해결 |
| 3 | 바인드 마운트용 컨테이너(`my-web-bind`)를 실행했으나 브라우저에 변경 사항이 반영되지 않음 | `docker ps -a` 확인 결과 상태가 `Created`(미실행)였음 — 포트 8080을 기존 컨테이너(`my-web-8080`)가 이미 점유해 실행 실패 | `docker ps -a`로 컨테이너 STATUS 확인 | 기존 컨테이너를 `docker rm -f`로 정리한 뒤 재실행하여 해결. 동일 포트를 여러 컨테이너가 동시에 쓸 수 없음을 확인 |
