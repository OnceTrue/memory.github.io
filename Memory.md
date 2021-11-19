vscode 설치

![image](https://user-images.githubusercontent.com/85273192/121110586-7d47f380-c848-11eb-825c-65919bc7691b.png)

확장  azuretools 설치

![image](https://user-images.githubusercontent.com/85273192/121110601-833dd480-c848-11eb-9dcf-ea0b2461d613.png)

install-module az로 azure 모듈 설치?

![image](https://user-images.githubusercontent.com/85273192/121110611-8769f200-c848-11eb-97f7-69176117866e.png)

.tf 파일 생성

![image](https://user-images.githubusercontent.com/85273192/121110627-90f35a00-c848-11eb-94c9-7fff7e8e6565.png)

git 다운로드 및 설치 (기본값)

![image](https://user-images.githubusercontent.com/85273192/121153223-d6cc1480-c880-11eb-9d29-26af876b0a9c.png)

![image](https://user-images.githubusercontent.com/85273192/121153355-f2cfb600-c880-11eb-92c2-99e07c14bab7.png)

Azure Terraform 확장 설치

![image](https://user-images.githubusercontent.com/85273192/121155888-29a6cb80-c883-11eb-9dff-7f5ec84ab1f2.png)

이 후 부터 azure terraform init을 하면 다음과 같이 메뉴가 생성 됨

![image](https://user-images.githubusercontent.com/85273192/121156016-4d6a1180-c883-11eb-8589-d97293f0d58c.png)

그 다음 오른쪽 아래에 다음과 같이 Cloud shell로 열겠냐는 메시지가 나오고 ok를 누르면 node js관련 메시지가 발생함

![image](https://user-images.githubusercontent.com/85273192/121156181-712d5780-c883-11eb-8ee7-e18d97dc79ee.png)

node.js를 open을 누르면 웹사이트 접속 메시지가 나옴

![image](https://user-images.githubusercontent.com/85273192/121156543-be112e00-c883-11eb-8e4d-28a276cdb557.png)

![image](https://user-images.githubusercontent.com/85273192/121156564-c23d4b80-c883-11eb-9815-d171e3d9c385.png)

다시 open을 누르면 설치 웹사이트로 자동으로 이동 됨

![image](https://user-images.githubusercontent.com/85273192/121156614-cec1a400-c883-11eb-9d35-99a3c21ce09c.png)

사용할 버전을 선택하여 설치 여기서는 14.17.0버전을 선택 하였음

![image](https://user-images.githubusercontent.com/85273192/121156672-dc772980-c883-11eb-8b32-4ba21dad2dd0.png)

node.js설치 (기본값)

![image](https://user-images.githubusercontent.com/85273192/121156710-e8fb8200-c883-11eb-9bbe-0cf5ce087bd6.png)

설치 후 Terraform 껐다가 다시 실행 

Ctrl + Shift + p

Cloud shell로 열겠냐는 메시지가 나옴

![image](https://user-images.githubusercontent.com/85273192/121157751-c61d9d80-c884-11eb-86de-a326a1ffe464.png)

ok를 누르면 첫번째 실행에 대해 디렉터리 셋업을 해야 한다고 나옴 open 클릭

![image](https://user-images.githubusercontent.com/85273192/121157887-e64d5c80-c884-11eb-93d3-d3a7cda9c631.png)

Azure 로그인

![image](https://user-images.githubusercontent.com/85273192/121157925-eea59780-c884-11eb-8906-69def1093f8f.png)

Azure Cloude Shell 생성(여기서는 Bash로 생성)

![image](https://user-images.githubusercontent.com/85273192/121158049-05e48500-c885-11eb-8a9d-64b4a89aa8cf.png)

스토리지 생성

![image](https://user-images.githubusercontent.com/85273192/121158123-14cb3780-c885-11eb-8612-0cc8866cf303.png)

고급 설정

![image](https://user-images.githubusercontent.com/85273192/121158293-375d5080-c885-11eb-9a76-afc5bc194ba1.png)

이 후 azure terraform init을 하면 cloud shell로 열것이냐고 묻고 ok를 누르면 azure 로 열림

![image](https://user-images.githubusercontent.com/85273192/121158607-75f30b00-c885-11eb-9803-031777d0348e.png)

![image](https://user-images.githubusercontent.com/85273192/121159463-2bbe5980-c886-11eb-98dd-14967af36377.png)


추가로 로컬로 terraform 하기
아래 링크로 이동하여 사양에 맞는 파일을 다운로드 받음
https://www.terraform.io/downloads.html

압축을 풀고 특정 폴더에 terraform.exe파일을 넣음

![image](https://user-images.githubusercontent.com/85273192/142516791-3ce88c72-4d19-4ed1-ab6f-9898f2581a3a.png)

넣고 실행창에 다음을 입력 함
sysdm.cpl ,3

![image](https://user-images.githubusercontent.com/85273192/142516930-d3e59f45-4639-44a1-be70-4be6ff18afa5.png)

환경변수 클릭

![image](https://user-images.githubusercontent.com/85273192/142516981-aa53097f-fa9a-48b8-aa1c-272472ce39bc.png)

path 클릭 -> 편집 클릭

![image](https://user-images.githubusercontent.com/85273192/142517049-cff174f0-1c05-4f4b-9ad8-c022e98d8ec6.png)

새로만들기 클릭 -> terraform.exe파일을 추가 함

![image](https://user-images.githubusercontent.com/85273192/142517115-e3aa2a80-0860-4a9d-8307-804deadff904.png)

확인 및 적용 클릭

이 후 cmd 창으로 오면 "terraform"으로 입력시 

다음과 같이 나옴

![image](https://user-images.githubusercontent.com/85273192/142517257-b5ae585b-9e39-4c15-9765-6fa4e8ce16bc.png)

"terraform version" 입력시 다음과 같이 나옴

![image](https://user-images.githubusercontent.com/85273192/142517315-38a92ae6-4837-4b19-a49c-fcd541355594.png)

