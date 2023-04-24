
##############################
# 통계검정 1: t-test 해봅시다
##############################

# 1-01_강원도 원주시와 춘천시 2022년 아파트 실거래 자료 불러오기

apt_all <- read.csv("https://raw.githubusercontent.com/cmman75/article/main/data/kangwon_2022.csv", header = T, fileEncoding = "euc-kr")
head(apt_all)

# 1-02_원주시와 춘천시의 아파트 데이터 비교

boxplot(price ~ si, data = apt_all)

# 1-03_춘천시와 원주시의 아파트 데이터 분리

# install.packages("dplyr")
library(dplyr)  

si_1 <- apt_all %>% filter(si == "춘천시")
si_2 <- apt_all %>% filter(si == "원주시")

# 1-04_춘천시와 원주시의 아파트 실거래가 기술통계

# 1) 평균을 구해보자

mean(si_1$price) # 춘천시 아파트 평균 매매가
mean(si_2$price) # 원주시 아파트 평균 매매가 

# 2) 편차를 구해보자 => 각 관측치에서 평균을 뺀 값

si_1$price - 22200.69
si_2$price - 18220.78

# 3) 분산을 구해보자 => 각 관측치에서 평균을 뺀 값을 제곱하고, 다시 전체 관측건수로 나눈 것

sum((si_1$price - mean(si_1$price))^2) / (nrow(si_1)-1) # 춘천시 아파트 분산 
sum((si_2$price - mean(si_2$price))^2) / (nrow(si_2)-1) # 원주시 아파트 분산 

var(si_1$price)  # 춘천시 아파트 분산
var(si_2$price)  # 원주시 아파트 분산

# 4) 표준편차를 구해보자

sqrt(144371403) # 춘천시 아파트 표준편차
sqrt(115372586) # 원주시 아파트 표준편차

# 1-05_밀도분포 시각화 하기

d1 <- density(si_1$price)  # 춘천시 아파트 매매가 밀도분포
plot(d1)

d2 <- density(si_2$price)  # 원주시 아파트 매매가 밀도분포
lines(d2, col="red")


# 1-06_통계 분석: t-test

# (1) t-검정 메커니즘

# t-검정은 두 집단 간 평균을 비교하는 통계분석 기법
# 다시 말해 t-검정은 두 집단 간 평균 차이에 대한 통계적 유의성을 검증하는 방법
#                    -------------------

#                 => 두 집단이 퍼져 있는 정도(분산)와 몰려있는 정도(평균)을 비교하여 집단 간 차이 유무 분석
#                             --------------------    -------------------
#                                    noise                    signal
#          춘천평균  원주평균          |                         |
#             |         |              |-------------------------|
#  |          |  signal |                                    |
#  |          |---------|              # # # # # #    귀무(H0): noise < signal => 두 집단은 통계학적으로 차이가 없음
#  |         # #      * *              #  signal  #   대립(H1): noise > signal => 두 집단은 통계학적으로 차이가 있음
#  |control #   #    *   *             #  ------  #     
#  | group #     #  *     *   <<====   #  noise   # 
#  |      #       #        *           # # # # # #                
#  |    #       *   #        *                      
#  |  #       *       #         * treatment group                  
#  |_______________________________                 
#    |----------------|                     
#     noise1 |------------------|
#   (춘천분산)       noise2       
#                  (원주분산)  

# (2) t-검정

t.test (si_1$price, si_2$price, var.equal=TRUE)

# 해석 1: p value가 2.2e-16보다 작음
#         p < 0.00000000000000022

#         [p > 0.05] => 귀무가설 채택 => 춘천과 원주 아파트 가격은 차이가 없음
#         [p < 0.05] => 귀무가설 기각하고 대립가설 채택 => 춘천과 원주 아파트 가격은 차이가 없지 않음

#         통계적으로 춘천과 원주의 아파트 가격은 유의미한 차이가 있음 


# 해석 2: 춘천 아파트 평균 가격은 2.2억 / 원주 아파트 평균 가격은 1.8억 원
#         춘천시의 아파트 가격이 원주시에 비하여 평균적으로 4천만 원 높은 것으로 나타남


# 1-07_메모리 정리 

rm(list = ls())


##############################
# 통계검정 2: ANOVA 해봅시다
##############################

# 2-01_파일 불러오기

apt_all <- read.csv("https://raw.githubusercontent.com/cmman75/article/main/data/kangwon_2022.csv", header = T, fileEncoding = "euc-kr")
head(apt_all)

# 2-02_원주시만 추출하기

si  <- apt_all %>% filter(grepl("원주시", si))  # 원주시만 추출
aggregate(si$price, list(si$dong), FUN=mean)    # 원주시 동별 아파트 매매가 평균 

# 2-03_데이터 분포특성 비교하기

library(ggplot2) # install.packages("ggplot2")
ggplot(data=si, aes(x=price, group=dong, fill=dong)) + 
  geom_density(alpha=.4) + 
  facet_wrap(~dong) 

# 2-04_원주시 비교대상지 선택

# install.packages("dplyr")
library(dplyr)
dong <- si %>% filter(grepl("단계동|단구동|개운동", dong))

boxplot(price ~ dong, data = dong)
ggplot(data=dong, aes(x=price, group=dong, fill=dong)) +  # 밀도함수 그리기
       geom_density(alpha=.4) 

# 2-05_동별 평균과 분산 

aggregate(dong$price, list(dong$dong), FUN=mean)    # 동별 아파트 매매가 평균 
aggregate(dong$price, list(dong$dong), FUN=var)     # 동별 아파트 매매가 분산

# 2-06_ANOVA 분석 => 3개 이상의 그룹이 동일한지 / 차이가 있는지 비교할 때 사용

# 1) 기본 메커니즘

#----------------------------------#
#     단구      개운       단계    #
#     평균      평균       평균    #
#     (1.7)     (1.8)      (1.9)   #
#      |----------|-----------|      ==> 집단 간 변동(SSTR) -> 지역이 달라서 나타나는 차이(집단적 특성) 
#                                    #
#  |------|  |-------|  |---------|  ==> 집단 내 변동(SSE)  -> 개별 아파트 특성이 달라서 나타나는 차이(개별적 특성)
#    60 M      105 M        81 M     #
#      |---------------------|       ==> 총변동(SST)   
#                                    #
#-----------------------------------------------------#
#  SST(총변동)  = SSTR(집단간편차) + SSE(집단내편차) 
#                 ----------------   --------------   #   [내생요인] => 지역이 달라서 나타나는 차이
#                     [내생요인]    [외생요인]        #   [외생요인] => 개별 아파트 특성이 달라서 나타나는 차이
#-----------------------------------------------------#

# 2) ANOVA 분석

avol <- aov(dong$price ~ dong$dong)  
summary(avol)

# 해석 1: p value가 7.64e-06보다 작음
#         p < 0.00000764(7.64e-06)

#         [p > 0.05] => 귀무가설 채택                   => 세 지역의 아파트 가격은 차이가 없음
#         [p < 0.05] => 귀무가설 기각하고 대립가설 채택 => 세 지역의 아파트 가격은 차이가 없지 않음

#         통계적으로 세 지역의 아파트 가격은 유의미한 차이가 있음 


# 2-06_ANOVA 분석 원리 설명 

aggregate(dong_all$price, list(dong_all$dong), FUN = mean) # 각 집단별 평균
aggregate(dong_all$price, list(dong_all$dong), FUN = var)  # 각 집단별 분산

# 2-07_메모리 정리 

rm(list = ls())

######################
# 회귀분석: 미래예측
#####################

# 3-01_파일 불러오기

apt_all <- read.csv("https://raw.githubusercontent.com/cmman75/article/main/data/kangwon_2022.csv", header = T, fileEncoding = "euc-kr")
head(apt_all)

# 3-02_연월일 데이터 설정

library(lubridate)
apt_all$ym <- ymd(apt_all$ym)  

# 3-03_지역 구분

si_1 <- apt_all %>% filter(grepl("춘천시", si))
si_1 <- aggregate(price ~ ym, data = si_1, FUN = mean)
head(si_1)

si_2  <- apt_all %>% filter(grepl("원주시", si))
si_2 <- aggregate(price ~ ym, data = si_2, FUN = mean)
head(si_2)

# 3-04_지역별로 아파트 가격 예측(회귀분석)

si_1_model <- lm(price ~ ym, data = si_1)
summary(si_1_model)
# price = -23040.887 + 2.364*x  
# 한달이 지날때마다 평균 2.364만원 씩 오름

plot(price ~ ym, data=si_1)
abline(si_1_model, col="red")

si_2_model <- lm(price ~ ym, data = si_2)
summary(si_2_model)
# price = -34427.613 + 2.751*x  
# 한 달이 지날때 마다 평균 2.751만 원씩 오름

plot(price ~ ym, data=si_2)
abline(si_2_model, col="red")

# 3-04_메모리 정리 

rm(list = ls())

