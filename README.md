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

### 3-1. 작업 디렉토리 준비

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
### 3-3. Dockerfile로 웹 서버 이미지 빌드

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
### 3-4. 포트 매핑으로 컨테이너 실행 및 접속 확인

**목표**: 컨테이너 내부 웹 서버(80번 포트)를 호스트(내 컴퓨터)에서 접근 가능하게 연결한다.
```bash
docker run -d -p 8080:80 --name my-web-container my-web
docker ps
```
- `-p 8080:80` : 호스트의 8080번 포트를 컨테이너의 80번 포트(nginx가 듣고 있는 포트)로 연결한다는 뜻
- `-d` : 백그라운드에서 계속 실행되게 함 (detached, "떨어져서 돌아간다"는 뜻)
- `--name my-web-container` : 컨테이너에 이름을 붙여서, 나중에 이름으로 컨테이너를 찾기 쉽게 함

브라우저에서 `http://localhost:8080` 접속하여 웹 페이지 렌더링 확인.

**결과**: `docker ps`에서 `Up` 상태와 `0.0.0.0:8080->80/tcp` 포트 매핑을 확인했다. 브라우저에서 "내 첫 Docker 웹서버"라는 제목이 정상적으로 출력됨을 확인했다.