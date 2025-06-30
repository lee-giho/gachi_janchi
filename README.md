<img src="https://capsule-render.vercel.app/api?type=waving&height=250&color=0:ff7eb3,100:87CEEB&text=가치,%20잔치&fontSize=60&fontAlignY=30&animation=fadeIn&rotate=0&desc=게임%20요소가%20추가된%20맛집%20애플리케이션%20&descSize=30&reversal=false&fontColor=ffffff" style="width: 120%;">

# 🚀 프로젝트 소개 🚀  


## 프로젝트 개요 및 배경
기존의 맛집 애플리케이션은 단순히 리뷰와 추천 글을 통해 자신의 맛집을 공유하고 알아보며 음식점을 방문하고 있습니다.<br>
우리는 이러한 맛집 애플리케이션에 게임 요소를 추가하여 사람들에게 새로움에 대한 도전과 적극적인 참여를 이끌어내고자 합니다.<br>
가치, 잔치는 리뷰 수와 높은 별점, 추천 글이 아닌 원하는 재료를 획득하기 위해 새로운 음식점에 방문하며 숨은 맛집을 찾을 수 있습니다.<br>
직접 방문하여 재료를 획득해야 하는 시스템은 주변 음식점 상권의 활성화에도 도움이 될 것입니다.<br>
<br>

## 팀원 소개
<table align="center">
 <tr>
    <td align="center"><a href="https://github.com/dyun23"><img src="https://github.com/user-attachments/assets/db7dcd49-7090-4708-ae09-c2f9686f45ff" width="150px;" alt=""></td>
    <td align="center"><a href="https://github.com/sue06004"><img src="https://github.com/user-attachments/assets/2377ed7f-4031-4af6-a79f-e655d66d0c39" width="150px;" alt=""></td>
<tr>
    <td align="center">🔥<a href="https://github.com/jin2304"><b>이기호</b></td>
    <td align="center">🌳<a href="https://github.com/soohoon0821"><b>박정훈</b></td>
  </tr>
   <tr>
    <td align="center"><b></b></td>
    <td align="center"><b></b></td>
  </tr>
  </table>

<br>
            
# 🛠 프로젝트 설계 🏗  
## 기술 스택

### ✔ Frond-end
<div>
 <img src="https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white"/>
</div>

### ✔ Back-end
<div>
 <img src="https://img.shields.io/badge/Spring Boot-6DB33F?style=for-the-badge&logo=SpringBoot&logoColor=white"/>
 <img src="https://img.shields.io/badge/JAVA-FF7800?style=for-the-badge&logo=JAVA&logoColor=white"/>
 <img src="https://img.shields.io/badge/JWT-black?style=for-the-badge&logo=JSON%20web%20tokens"/>
 <img src="https://img.shields.io/badge/JPA-FF7800?style=for-the-badge&logo=JAVA&logoColor=white"/>
 <img src="https://img.shields.io/badge/Redis(for Caching)-DC382D?style=for-the-badge&logo=Redis&logoColor=white">
</div>

### ✔ Cloud
<div>
 <img src="https://img.shields.io/badge/AWS-%23FF9900.svg?style=for-the-badge&logo=amazon-aws&logoColor=white"/>
 <img src="https://img.shields.io/badge/MongoDB Atlas-%234ea94b.svg?style=for-the-badge&logo=mongodb&logoColor=white"/>
</div>

### ✔ DB
<div>
 <img src="https://img.shields.io/badge/MySQL-4479A1?style=for-the-badge&logo=MySQL&logoColor=white"/>
 <img src="https://img.shields.io/badge/MongoDB-%234ea94b.svg?style=for-the-badge&logo=mongodb&logoColor=white"/>
</div>

### ✔ Dev tools
<div>
 <img src="https://img.shields.io/badge/Visual%20Studio%20Code-0078d7.svg?style=for-the-badge&logo=visual-studio-code&logoColor=white">
 <img src="https://img.shields.io/badge/Git-F05032?style=for-the-badge&logo=Git&logoColor=white"/>
 <img src="https://img.shields.io/badge/GitHub-181717?style=for-the-badge&logo=GitHub&logoColor=white"/>
</div>

### ✔ Communication
<div>
 <img src="https://img.shields.io/badge/discord-5865F2?style=for-the-badge&logo=discord&logoColor=white"/>
 <img src="https://img.shields.io/badge/figma-F24E1E?style=for-the-badge&logo=figma&logoColor=white"/>
</div>

<br>

## 🏗 시스템 아키텍처 🏛  
<div align="center">
 <img src="https://github.com/user-attachments/assets/04c8949b-7737-44bf-bb54-0572f5cbf6be" height="600"/>
</div>

<br>

## 🛠 ERD 🗂  
<div align="center">
 <img src="https://github.com/user-attachments/assets/b67a8bf4-35a5-4c3d-850a-3a24e186b960"/>
</div>

<br>

# 🛠 프로젝트 내용 및 기능 🏗  
## 주요 내용  

### 1. 로그인 및 회원가입
#### 1.1. 회원가입<br>
사용자는 로컬 계정과 소셜 계정(구글, 네이버)으로 나뉩니다.<br>
로컬 계정 회원가입은 이름과 이메일, 아이디, 비밀번호를 입력하여 진행합니다.<br>
소셜 계정 회원가입은 google_sign_in과 flutter_naver_login 라이브러리를 사용해 로그인을 하고, idToken으로 사용자의 정보를 데이터베이스에 저장합니다.

#### 1.2. 로그인<br>
로그인을 하면 JWT 토큰인 Access Token과 Refresh Token을 반환받습니다. <br>
- Access Token : API 요청을 보낼 때 사용한다. 하루의 유효 기간을 가지며 헤더에 "Bearer "를 붙여 포함시켜 요청을 보냅니다.<br>
- Refresh Token : 만료된 Access Token을 재발급 받을 때 사용됩니다. 한 달의 유효 기간을 가집니다.<br>
Flutter 애플리케이션 내에 민감한 데이터를 관리할 수 있는 SecureStorage에 해당 토큰들을 저장하고 사용합니다. 그 외에 자동 로그인 여부를 저장하여 자동로그인 기능을 구현했습니다. <br>

#### 1.3. 아이디와 비밀번호 찾기<br>
구글 이메일 SMTP를 사용하여 사용자에게 인증번호 6자리를 보내주고 3분의 유효시간을 줍니다.<br>
이메일 인증을 완료하면 아이디 찾기는 기존 아이디를 알 수 있고, 비밀번호는 재설정하게 됩니다.<br>

### 2. 지도 작업 - 음식점 별 재료 이미지 마커<br>
flutter_naver_map과 geolocator 라이브러리를 사용해 지도를 불러오고 음식점 위치를 이미지 마커를 표시합니다.<br>
음식점 별 재료는 @PostConstruct와 @Scheduled 어노테이션을 사용해 서버가 시작될 때와 매일 자정에 랜덤으로 지정/업데이트를 해줍니다.<br>
애플리케이션에 보이는 지도의 경계 값을 가져와 해당 구역에 있는 음식점들에 대한 정보를 요청해 가져옵니다. 구역 밖에 있는 음식점들에 대한 마커와 정보는 다시 지도를 움직여 해당 구역이 보일 때 가져오게 됩니다.<br>
오른쪽 아래의 쇼핑카트 아이콘을 통해 지도에 표시될 재료 필터를 선택할 수 있습니다. 선택된 필터는 초기화 버튼을 통해 한 번에 제거할 수 있습니다.

### 3. 경험치 획득<br>
가치, 잔치 애플리케이션에서는 활동을 하며 경험치를 획득하고 레벨을 올리며 랭킹을 올릴 수 있습니다.<br>
경험치를 획득하는 기준은 다음과 같습니다.<br>
- 음식점을 방문해서 재료를 얻을 때 : 20 경험치
- 이미지가 없는 리뷰를 작성할 때 : 30 경험치
- 이미지가 있는 리뷰를 작성할 때 : 40 경험치
- 획득한 이미지로 컬렉션을 해제할 때 : 50 경험치
- 특정 조건을 채워 칭호를 획득할 때 : 10 ~ 60 경험치

### 4. 방문 음식점 기록<br>
음식점을 방문하여 음식점 ID가 담긴 QR코드를 스캐너를 통해 스캔하면 그때 보이는 재료를 획득할 수 있습니다.<br>
QR코드 스캔이 완료되면 정보가 저장되고 방문내역 탭으로 이동되어 바로 확인할 수 있습니다.<br>

### 5. 리뷰 작성<br>
방문내역 탭으로 이동해 방문했던 음식점들에 대해 리뷰를 작성할 수 있습니다.<br>
사진(선택)과 먹었던 메뉴(선택), 리뷰 내용, 별점을 입력할 수 있습니다.<br>
마이페이지의 리뷰 메뉴에서 내가 작성한 리뷰를 모아서 볼 수 있습니다.<br>
이때, 해당 페이지에서는 리뷰 수정과 삭제가 가능합니다.<br>
리뷰 수정과 삭제는 그에 해당하는 경험치가 차감되거나 추가로 획득될 수 있습니다.<br>

### 6. 컬렉션 획득<br>
컬렉션 화면에서 모은 재료로 여러가지 컬렉션을 해제할 수 있습니다.<br>
재료의 조합으로 컬렉션을 해제하며 중복으로 획득할 수 없습니다.<br>
추후 계획으로, 다른 사용자가 모은 컬렉션을 볼 수 있는 페이지도 구현할 계획입니다.<br>

### 7. 칭호 획득<br>
특정 조건을 만족하면 마이페이지의 내정보에서 획득하고 대표 칭호를 선택할 수 있습니다.<br>
해당 칭호는 사용자의 닉네임 옆에 붙어서 다른 사용자들에게 보이게 됩니다.<br>

### 8. 마이페이지<br>
마이페이지에서는 내 정보 변경과 모은재료 확인, 작성한 리뷰 확인이 가능합니다.<br>
내 정보 변경에서 프로필 사진과 닉네임, 칭호, 비밀번호 변경을 할 수 있습니다. 이때, 비밀번호 변경은 현재 비밀번호 확인을 통해 변경할 수 있습니다.<br>
로그아웃과 탈퇴도 가능하며, 탈퇴의 경우에는 사유도 선택적으로 작성할 수 있습니다.<br>
추후 계획으로, 관리자 페이지를 만들어 탈퇴 사유에 대한 정보도 다룰 계획입니다.<br>

<br>

## 주요 기능 영상
| **회원가입** | **로그인** | **아이디/비밀번호 찾기** |
| :---: | :---: | :---: |
| <img src="https://github.com/user-attachments/assets/28c9b5b0-d0ce-4e63-9aff-095b8bc72579" height="350" /> | <img src="https://github.com/user-attachments/assets/247790cf-07af-4abd-ac1f-0ac5a7436e6e" height="350" /> | <img src="https://github.com/user-attachments/assets/6ccbf001-4fdb-4ce2-859a-8c348d2bae23" height="350" /> |
| **홈 탭** | **랭킹 탭** | **즐겨찾기 탭** |
| <img src="https://github.com/user-attachments/assets/492a7c43-38e8-4722-a5b9-a20fe69d1cda" height="350" /> | <img src="https://github.com/user-attachments/assets/2e9cab98-40e0-45eb-8679-ad50b43a134d" height="350" /> | <img src="https://github.com/user-attachments/assets/5826c3ef-54f2-495a-a232-ad76cba16290" height="350" /> |
| **방문내역 탭** | **마이페이지 탭** | **음식점 상세 페이지** |
| <img src="https://github.com/user-attachments/assets/d5547eb0-5bb0-4558-9481-bc6986cdf9da" height="350" /> | <img src="https://github.com/user-attachments/assets/3f4b75ba-16c7-4ffd-92ad-d08dfa96259b" height="350" /> | <img src="https://github.com/user-attachments/assets/467f1063-69cf-4df5-9d07-7116cfcbf694" height="350" /> |
| **리뷰 등록** | | |
| <img src="https://github.com/user-attachments/assets/58ff8f83-f31a-4183-b637-3a32ae82fe70" height="350" />


<br><br>
# 📈 성능 개선
review테이블에 100,000건의 리뷰 데이터와 그에 따른 리뷰 이미지/메뉴(리뷰당 0 ~ 5개) 테이블에 각각 250,000건의 데이터를 저장하며 성능 저하가 발생했습니다.

## 추가로 사용된 기술<br>
### ✔ Monitoring
<img src="https://img.shields.io/badge/Prometheus-E6522C?style=for-the-badge&logo=Prometheus&logoColor=white"><br>
### ✔ Dashboard
<img src="https://img.shields.io/badge/grafana-%23F46800.svg?style=for-the-badge&logo=grafana&logoColor=white"><br>
### ✔ Load Testing
<img src="https://img.shields.io/badge/k6-0078d7.svg?style=for-the-badge&logo=k6&logoColor=white">

## 지도 영역 내 음식점 정보 조회 API 성능 개선
### 🔍 문제 인식
Prometheus + Grafana 기반 모니터링과 k6 부하 테스트를 통해 평균 응답 시간이 음식점 34곳 조회 기준 36초 이상 걸리는 병목을 확인했습니다.<br>
지도 영역 기반 음식점 조회 API는 각 음식점마다 리뷰 수, 평균 별점, 재료를 개별로 조회해야 하는 복합 응답 구조입니다.<br>
따라서 기존 코드에서는 음식점 수만큼 반복 쿼리를 수행해 N+1 문제가 발생했습니다.<br>
→ 34곳의 음식점을 조회하는데 115건의 쿼리 발생<br>

### 🛠️ 개선 방식
- **리뷰 통계 전용 테이블 분리**<br>
성능 이슈가 있는 COUNT, AVG 연산을 제거하여 빠른 조회
- **JPQL 기반 DTO Projection 쿼리를 구현하여 리뷰 수/평균을 한 번에 조회**<br>
- **Redis 캐시 도입**<br>
음식점 id를 기반으로 정보를 DTO 형태로 캐싱(TTL 10분)<br>
Redis hit 시 즉시 반환, miss 시 MySQL 조회 및 캐시 저장 후 반환

### 📊 개선 결과 (k6 부하 테스트)
VUs: 100<br>
Duration: 10m
| **항목**	| **성능 개선 전**	| **성능 개선 후**(인덱스만 적용)	| **성능 개선 후** |	**Redis 캐시 적용 후**	| **개선 효과**(인덱스 적용부터) |
| :---: | :---: | :---: | :---: | :---: | :---: |
| **평균 응답 시간**	| 36s	| 1s	| 139ms |	66ms |	약 93% 감소 |
| **p(90)**	| 51s	| 1s	| 192ms	| 164ms	| 약 83% 감소 |
| **p(95)**	| 52s	| 1s	| 228ms	| 214ms	| 약 78% 감소 |
| **p(99)**	| 52s	| 2s	| 308ms	| 336ms	| 약 83% 감소 |
| **HTTP 요청 수**	| 1.7k	| 38.5k	| 428.7k	| 906.6k	| 약 23배 증가 |
| **TPS**	| 2.67/s	| 64.07/s	| 714.41/s	| 1.51k/s	| 약 23배 향상 |

인덱스 적용 후로부터 N+1 문제 완화 및 쿼리 최적화, 캐시 도입을 통해 **평균 응답 시간은 약 93% 단축**되고 **TPS는 약 23배 향상**시켰으며, 실제 **쿼리 수도 115개에서 15개 또는 0개**(Redis에 값이 있을 경우)로 줄였습니다.


## 리뷰 조회 API 성능 개선
### 🔍 문제 인식
Prometheus + Grafana 기반 모니터링과 k6 부하 테스트를 통해 평균 응답 시간이 리뷰 10건 조회 기준 2초 이상, 전체 조회 기준 30초 이상 걸리는 병목을 확인했습니다.<br>
리뷰 조회 API는 리뷰뿐만 아니라 관련 정보인 사용자와 칭호, 리뷰 이미지, 리뷰 메뉴 등 여러 데이터를 조회해야 하는 복합 응답 구조입니다.<br>
따라서 기존 코드에서는 각 리뷰마다 개별적으로 user와 title, review_image, review_menu 테이블을 조회하면서 N+1 문제가 발생했습니다.<br>
-> 10개의 리뷰를 조회하는데 38건의 쿼리 발생<br>

### 🛠️ 개선 방식
- **QueryDSL 기반 DTO Projection 쿼리를 구현하여 Review와 User, Title을 한 번에 조회**
- **ReviewImage와 ReviewMenu는 IN 조건으로 일괄 조회한 후 매핑**
- **쿼리 속도 향상을 위해 리뷰 정렬 방식에 따른 복합 인덱스 적용**

### 📊 개선 결과 (k6 부하 테스트)
VUs: 100<br>
Duration: 10m
| **항목** | **성능 개선 전** | **성능 개선 후** | **개선 효과** |
| :---: | :---: | :---: | :---: |
| **평균 응답 시간** | 2s | 63ms | 약 96% 감소 |
| **p(90)** | 3s | 103ms | 약 96% 감소 |
| **p(95)** | 4s | 118ms | 약 97% 감소 |
| **p(99)** | 4s | 166ms | 약 95% 감소 |
| **HTTP 요청 수** | 21.7k | 937.7k | 약 43배 증가 |
| **TPS** | 36/s | 1560/s | 약 43배 향상 |

N+1 문제 완화 및 쿼리 최적화를 통해 **평균 응답 시간은 약 96% 단축**되고 **TPS는 약 43배 향상**시켰으며, 실제 **쿼리 수도 38개에서 4개**로 줄였습니다.

<br><br>
# 🛠 추후 계획
| **추가 기능** | **설명** |
| :---: | :---: |
| 관리자 페이지 | 전체 데이터 조회 및 관리 |
| 사장님 페이지 | 음식점을 운영하는 사장님이 음식점에 대한 정보를 입력하고 등록 |
| 새로운 게임적 요소 | 랜덤 상자, 멀티&싱글 모드 등 |

