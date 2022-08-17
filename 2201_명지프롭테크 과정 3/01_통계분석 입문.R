
##################
# 1주_통계학 입문
##################

#------------
# 0_접속하기
#------------

# R Studio server 접속

# 강의 / 연구목적으로 만든 Rstudio Server에 접속하여 바로 실행
# (온라인 환경이 미리 구성되어 있어 별도의 세팅이 필요 없음)

# 접속주소: http://159.223.63.63:8787/
# 접속 아이디와 비밀번호는 수강생별로 생성하여 알려드립니다.

# R Studio server 구성

# R Studio가 실행되면 다음과 같이 네 개의 창이 뜨게 됨

# |-----------|-------------|
# |  Source   | Environment |
# |  Script   | History     |
# |-----------|-------------|
# |   Consol  | File / Plot |
# |           |   Viewer    |
# |-----------|-------------|

# File 탭에서 01_통계학입문.R 파일 클릭
# Script 창에서 바로 실행 가능


#------------------
# 1_R 데이터 입력
#-----------------

# 01_작업폴더 경로 설정

getwd()            # 현재 작업폴더가 어디로 세팅되어 있는지 확인

# 02_간단 계산하기

# R은 객체(object)를 만들어서 데이터를 처리할 수 있음
# 데이터 유형은 크게 3가지: 숫자형(Numeric), 문자형(Character), 논리형(Logical)
#---#
1+3                      # 숫자형 계산 ⇒ 정답 4
1/3                      # 숫자형 계산 ⇒ 정답 0.3333... 
#---#
데이터_1 <- 1            # 숫자형 + 문자형 계산 ⇒ 정답 3
데이터_2 <- 2+데이터_1	   
#---#
sum(1,2,3,4,5,6,7,8,9,10)      # 숫자형 계산 ⇒ 여기서 c ⇒ concatenate [연결시키다]
sum(c(1,2,3,4,5,6,7,8,9,10))  

# 03_반복 데이터의 생성

rep("a", times=10)      # 정답: "a" "a" "a" "a" "a" "a" "a" "a" "a" "a"
rep( c("a", 1), 5)      # 정답: "a" "1" "a" "1" "a" "1" "a" "1" "a" "1" 
#---#
rep(1:3, each=3)        # 정답: 1 1 1 2 2 2 3 3 3
#---#                  
seq(1, 5)              # 일정한 구조를 가지는 순차 데이터 생성
seq(1, 6, by =2)       # 정답 : 1 3 5   일정간격으로 순차적으로 숫자 생성
#---#
rm(list = ls())   # 메모리 청소                
# 참고: 콘솔 창에서 Ctrl + L 누르면 화면 클리어

# 정신건강을 위한 상식 !

# 샵(#) 표시는 주석 ⇒ R은 # 이후의 코드 무시함
# R은 대문자와 소문자를 구분함
# 코드 중간 중간에 설명 달아줄 것 ⇒ 코드가 길어졌을 때 스트레스 적음

# 04_벡터값 입력

x <- c(1, 2, 3, 4)             # 숫자형: 
y <- c("a", "b", "c", "d")    # 문자형: 문자형 벡터에는 반드시 " "가 들어가야 함
z <- c(TRUE, TRUE, FALSE)    # 논리형: TRUE는 1,  FALSE는 0으로 인식함
#---#
ls() # 리스트 보기
rm(list = ls())   # 메모리 청소  

# 05_NA / Null

# NA(Not Available) 값이 없음 ⇒ 누락된 값 ⇒ 결측치
score <- c(85, 72, NA, 43)           # NA가 포함된 데이터 세트
score 
is.na(score)                         # NA 진리값(참/거짓) 판별
mean(score, na.rm = T)               # na를 remove한 상태(na.rm=T)에서만 평균값 계산 가능

# 06_대치법

# NA가 값이 있어야 하는데 없는 것(결측치)라고 한다면 null은 아예 값이 없음을 의미함 
score <- c(85, 72, NULL, 43)         # null이 포함된 데이터 세트
score 
mean(score)                          # null은 존재하지 않는 값이기 때문에 그냥 mean 계산해도 무방함


#------------------------
# 2_R 데이터 구조의 이해
#-----------------------

# 01_벡터 입력

V1 <- c(1,2,3)        # 벡터(vector)는 동일한 유형의 데이터로 구성되어 있는 1차원의 데이터 구조
V2 <- c("Hello","R")   # 숫자형 벡터 데이터(위)와 문자형 벡터 데이터(아래)

# 02_요인 입력

F1 <- c("A", "B", "C")   # 문자형 벡터 데이터 만들기                                             
F2 <- factor(F1)       # 요인(factor)형으로 변환 ⇒ F2는 A,B,C라는 세 개의 범주로 구성되어 있음  

# 03_행렬

M1 <- matrix(1:12, nrow=3)              # 1~12까지 숫자를 행(row)의 수가 3개인 행렬로 만들어라
M2 <- matrix(1:12, nrow=3, byrow=T)     # byrow=T는 행을 기준으로 숫자를 나열하라 !!! 

# 04_배열

A1 <- array(1:12, c(2,3,2))     # [① 1~12까지 숫자]를 [② 2×3의 행렬]로 [③ 2층]으로 만들어라

# 05_데이터프레임

d1 <- c(1,2,3)            # 데이터 유형에 상관없이 2차원 형태의 데이터 구조를 생성
d2 <- c("A", "B", "C") 
d3 <- data.frame(d1,d2)                                                           
d3

# 06_리스트

L1 <- list(V1,F2,M2,A1,d3)   
# 벡터, 행렬, 배열, 데이터프레임 같이 서로 다른 데이터 구조를 묶을 수 있는 끝판왕

# 07_데이터 구조 속성확인

is.vector(score)
is.matrix(M1)
is.array(A1)
is.data.frame(d3)
is.list(L1)


#-------------------
# 3_R 데이터 합치기
#------------------

# 01_합치기: rbind 와 cbind는 무슨 차이?

v1 <- c(1,2,3) ; v2 <- c(4,5,6) ; v3 <- c(7,8,9)

matrix_r <- rbind(v1, v2, v3)
matrix_c <- cbind(v1, v2, v3)

# 02_합치기(bind)와 결합(merge)하기는 뭔가 다른가?

# bind는 그냥 붙여넣는 것
# merge는 동일 key 값을 기준으로 결합하는 것 => merge(A, B, by='key)

# 03_Join: merge를 보다 정교하게 작업해볼까?

# (1) 고객 아이디와 이름 결합하기  
cust_id <- c("c01","c02","c03","c04", "c05", "c06", "c07")
last_name <- c("Kim", "Lee", "Choi", "Park", "Bae", "Kim", "Lim")
cust_list <- data.frame(cust_id, last_name)

# (2) 고객 아이디와 구매금액(만원) 결합하기  
cust_id = c("c03", "c04", "c05", "c06", "c07", "c08", "c09")
buy_won = c(3, 1, 0, 7, 3, 4, 1)
cust_pay <- data.frame(cust_id, buy_won)

# (3) inner join: 교집합
cust_inner <- merge(x = cust_list, y = cust_pay, by = 'cust_id')

# (4) outer join: 교집합
cust_outer <- merge(x = cust_list, y = cust_pay, by = 'cust_id', all = TRUE)

# (5) left outer join: 부분 합집합 -> 이름 NA 있음
cust_lout <- merge(x = cust_list, y = cust_pay, by = 'cust_id', all.y = TRUE)

# (6) right outer join: 부분 합집합 -> 구매금액 NA 있음
cust_rout <- merge(x = cust_list, y = cust_pay, by = 'cust_id', all.x = TRUE)


#---------------
# 4_R 행열 삭제
#---------------

# 01_추출 및 삭제 기본원칙

# R에서 쓰이는 데이터프레임은 행과 열을 가지고 있음
# [2,1] ⇒ 2행 1열  / [1,3] ⇒ 1행 3열
# [2,]  ⇒ 2행 전체  / [,3]  ⇒ 3열 전체 

# 02_추출 및 삭제 실습

dim(iris)      # iris 데이터 세트 구조 확인: 150 행 5열
head(iris)

#---#
x <- iris[1,]; x   # 1행만 추출
#---#
x <- iris[c(1:3),]; x   # 1~3행만 추출
#---#
x <- iris[,c(3:5)]  # 3~5열만 추출
head(x)
#---#
x <- iris[-c(1:140),]   # 1~140행 삭제 ⇒ 단 행 번호는 그대로 남아있음
head(x)
#---#
rownames(x) <- NULL  # 행 번호를 초기화
head(x)


#---------------
# 5_요약/파생변수 만들기
#---------------

# 01_요약변수 만들기 실습

library(ggplot2)  # install.packages("ggplot2")  # ggplot2 라이브러리 설치 및 로딩
mpg <- as.data.frame(ggplot2::mpg)               #  ggplo2의 mpg 데이터를 데이터프레임 형태로 불러오기
head(mpg) ; tail(mpg)                            # 데이터의 앞부분과 뒷부분을 확인 
View(mpg)                                        # Raw 데이터 뷰어 창에서 확인
dim(mpg) ; str(mpg)                              # 행·열 출력 ; 데이터 속성 확인  
summary(mpg)                                     # 요약 통계량 출력

# 02_파생변수 만들기 1: 조합형

# mpg데이터는  도시연비(cty)와 고속도로 연비(hwy)를 따로 계산하고 있음 
# 이를 통합(조합)하여 통합연비 변수(파생변수)를 만들 수 있음

library(ggplot2)  # install.packages("ggplot2")  # ggplot2 라이브러리 설치 및 로딩
mpg <- as.data.frame(ggplot2::mpg)               #  ggplo2의 mpg 데이터를 데이터프레임 형태로 불러오기
#---#
mpg$total <- (mpg$cty + mpg$hwy)/2               # 통합 연비 변수 생성
head(mpg)
mean(mpg$total)                                  # 통합 연비 변수 평균

# 03_파생변수 만들기 2: 조건형

# 조건에 따라 다른 값을 반환하는 조건문 함수를 이용하여 합경판정 변수를 작성

mpg$test <- ifelse(mpg$total >= 20, "pass", "fail")  # ifelse() 함수 사용 ⇒ 20 이상이면 pass / 아니면 fail
head(mpg, 20) 
#---#
table(mpg$test)    # 연비 합격 빈도표 생성
library(ggplot2)     # ggplot2 로드
qplot(mpg$test)    # 연비 합격 빈도 막대 그래프 생성 
#---#
# 전체 자동차 중에서 연비 기준을 충족해 '고연비 합격 판정'을 받은 자동차가 몇 대나 되는가?
# 중첩조건문을 활용하여 기준을 세 종류로 변경함 ⇒ if else 안에 if else 넣기
mpg$grade <- ifelse(mpg$total >= 30, "A",            # total을 기준으로 A, B, C 등급 부여
                    ifelse(mpg$total >= 20, "B", "C"))       # A : 30이상, B : 20~29, C : 20미만
head(mpg, 20)  
#---#
table(mpg$test)    # 연비 합격 빈도표 생성
library(ggplot2)     # ggplot2 로드
qplot(mpg$test)    # 연비 합격 빈도 막대 그래프 생성 

# 04_reshape 패키지로 파생변수 만들기

# (1) R 은 이러한 재구조화 작업을 위하여 reshape 패키지 내에 melt() 함수와 cast() 함수를 내장하고 있음
# 웨이터가 팁(tip)을 받은 정보를 기록한 데이터 ⇒ tips
# 여기에는 total_bill(총지불액), tip(팁), sex(성별), smoker(흡연유무), day(요일), time(점심,저녁), size(인원수)가 있음

library(reshape)  # install.packages("reshape")
data(tips)      
head(tips)
#-------------------------------------------------------
#     total_bill  tip    sex  smoker day  time  size no 
#    1      16.99 1.01 Female     No Sun Dinner    2  1
#    2      10.34 1.66   Male     No Sun Dinner    3  2
#    3      21.01 3.50   Male     No Sun Dinner    3  3
#-------------------------------------------------------
tips$no <- 1:nrow(tips)    # no 컬럼을 추가하고 일련번호를 매긴다

# (2) melt하기
# no(일련번호), sex(성별), smoker(흡연유무), day(요일), time(점심,저녁) 자료만 melt 함
# 'tips' 안에 있던 하나의 row가 melt 되면서 'tips_melt'에서 3개로 분해됨: 244개 row => melt 이후 732개로 3배 증가 
tips_melt <- melt(tips, id=c("no","sex","smoker","day","time"), na.rm=TRUE) 
# 하나의 row가 3개로 분해됨: 원래 244개 row 이었으나 ⇒ melt 이후에는 732개로 3배 증가
head(tips_melt,2) 
str(tips_melt) 
table(tips_melt$variable)     # variable 보면 total_bill, tip, size가 각각 244개(total: 732개) 

# (3) 캐스트 함수를 사용해서 행을 time, 열을 variable로 요약함
tips_cast_time <- cast(tips_melt, time ~ variable, mean) 
tips_cast_time # Lunch / Dinner에 따라서 total_bill, tip, size가 어떻게 다른지 평균(mean)으로 종합정리

# (4) 평균 뿐만 아니라 관측치 수까지 알고 싶다면 ⇒ c(mean, length) 조합 사용[컬럼이름_통계값 이름]
tips_cast_time <- cast(tips_melt, time ~ variable, c(mean, length)) 
tips_cast_time 

# (5) 두번째 인수에 |를 그어주면 값별로 따로 테이블 만들어 줌
tips_cast_time <- cast(tips_melt, day ~ . |variable, mean) 
tips_cast_time 

# (6) 마지막 행에 총 합계(all)을 표시해 줌
tips_cast_time <- cast(tips_melt, day ~ variable, mean, margins=c("grand_row", "grand_col")) 
tips_cast_time 

# (7) variable 가운데 tip만 보여줌
tips_cast_time <- cast(tips_melt, day ~ variable, mean, subset=variable=="tip") 
tips_cast_time 

# reshape 패키지에서는 경우의 수를 조합하여 데이터를 녹였다가(melt) 재구조화(cast) 하여 파생변수 만들어 낼 수 있음

