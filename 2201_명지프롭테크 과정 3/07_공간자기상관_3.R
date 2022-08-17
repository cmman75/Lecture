
#######################
# 7주_공간자기상관분석
#######################

#-------------------
# 1_자기상관의 기초
#------------------

# 01_공간적 자기상관이란 무엇인가?

# 공간 데이터에는 공간 정보(위치, 형태) 뿐만 아니라 비공간 정보(속성)도 포함됨
# 시각화 된 도면을 통하여 => 직관적으로 비공간 정보가 밀집된 지역과 그렇지 않은 지역을 구분할 수 있음
# 그러나 이러한 기준이 사람에 따라 일관되지 않기 때문에 객관적 지표로 삼기 어려움

# 따라서 누구나 객관적으로 판단할 수 있는 통계적 기법을 활용하여
# 비공간 정보들이 서로 밀집(클러스터링)되어 있는지
# 아니면 (무작위로) 분산되어 있는지 살펴 볼 필요가 있음

# 이렇듯 특정 정보가 밀집/ 분산되어 있는지 보는 것을 => 공간자기상관 관계라고 함
# (끼리끼리 모여 있는지... 아닌지 판단)


# 02_(일반적) 자기상관이란 무엇인가? 

# 공간자기상관을 알기 위해서는 우선적으로 자기상관이라는 개념에 대하여 이해하여야 함
# 자기상관이란 특정 데이터를 중심으로 주변에 분포하고 있는 데이터와의 상관관계(또는 유사성)을 측정하는 것임

# 사례 1: Negative 자기상관

# (1) 다음과 같은 관측값 a, b가 이 있다고 가정하자(값들이 랜덤함)
d <- c(90, 27, 37, 56, 88, 20, 85, 96, 61, 58)
a <- d[-length(d)]; a  # 높은 순서에서 낮은 순서로 정렬
b <- d[-1]; b          # 첫번째 데이터를 제외하고 낮은순서에서 높은 순서로 정렬

# (2) 관측값을 플로팅 하면 다음과 같음
plot(a, b, xlab='t', ylab='t-1')  # a, b 두 데이터의 관계 시각화

# (3) 두 값 사이의 자기상관관계를 계산하여 보자
cor(a, b)      # [1] -0.2222057 관측값 사이의 상관성이 매우낮음 (negative 관계)

# 사례 2: Positive 자기상관

# (1) 다음과 같은 관측값 a, b가 이 있다고 가정하자
d <- sort(d); d         # 데이터가 낮은 순서에서 높은 순서로 정렬
a <- d[-length(d)] ;  a # 데이터를 낮은 순서에서 높은 순서로 정렬
b <- d[-1] ;  b         # 첫번째 데이터를 제외하고 낮은순서에서 높은 순서로 정렬

# (2) 관측값을 플로팅하면 다음과 같음
plot(a, b, xlab='t', ylab='t-1')

# (3) 두 값 사이의 자기상관관계를 계산하여 보자
cor(a, b)    ## [1] 0.9530641 관측값 사이의 상관성이 매우 높음(positive 관계)


# 03_시간적 자기상관(Temporal autocorrelation) 이란 무엇인가?

# 자기상관관계를 보다 심화하면 => 시간적 자기상관(temporal autocorrelation) 개념으로 확장 가능
# 우리가 장기간에 걸쳐 특정한 현상을 관측하였을 때 => 일관성 또는 연속성이 나타나는 것을 알 수 있음

# ex) 지난 10년 동안 몸무게가 50kg -> 80kg으로 증가시 => 점진적인(gradually) 패턴 변화임
#     즉, 어제는 60kg였다가 오늘은 80kg이고 내일은 70kg로 줄어들 수는 없음

# 시간에 따라 어떠한 관측치의 변화를 관찰해 보면 일정한 방향성을 가지고(정방향 또는 역방향) 점진적으로 변화하기 때문에 
# 한 지점 x 에 대한 관측값과 그 이후의 지점인 x-d 의 관측치를 두고(= 두 지점의 관측치에 대한) 상관성 분석을 할 수 있음

# 사례 3: 

acf(d) # acf function(autocorrelation function): d 데이터의 자기상관관계의 lag(래그)가 어떻게 나타나는지 알려줌
       # 인접한 지점의 관측값과 비교할 수록 래그가 높음(두번째 관측치까지는 통계적으로 자기상관이 존재함)
       # 하지만 관측값에서 멀어질수록 자기상관은 약해짐

rm(list=ls())  # 메모리 정리
dev.off()      # 플롯창 정리


#---------------------------------------------
# 2_(전역) 공간자기상관 분석: Gloabl Moran's I
#---------------------------------------------

# 01_캘리포니아 오존측정 데이터 다운로드

# 캘리포니아 LA 32 곳에서 (1개월 동안) 오존 발생량 측정 
# 이 데이터에는 스테이션 번호, 좌표, 일일 최고 8시간 평균(Av8top)이 포함
# (자료는 UCLA 공간분석 연구소에서 다운로드 가능)
# https://stats.idre.ucla.edu/r/faq/how-can-i-calculate-morans-i-in-r/

load(url("http://159.223.63.63:3838/data/autocorrelation/ozon.rdata"))

head(ozone, n=10)

library(leaflet)   # 지도 시각화 
library(dplyr)

leaflet() %>% addTiles() %>% addCircleMarkers(data=ozone, fillColor = "red", radius = (ozone$Av8top)^1.5, label=ozone$Station)



leaflet() %>% addTiles() %>% 
              addCircleMarkers(data= ozone, fillColor ="red", radius= (ozone$Av8top)^1.5, label = ~Station)

# 02_오존 데이터는 공간적으로 자기상관관계를 가지고 있는가? (특정 지역에 밀집되어 있는가?)

# 미국 캘리포니아 주 LA시의 오존측정 결과가 다음과 같다고 하자
# 지도를 살펴보면 동북쪽으로 갈수록 동그라미가 커지고(오존 농도가 높아지고)
# 남서쪽으로 갈수록 작아지는(오존 농도가 옅어지는) 패턴을 보이는 것을 알 수 있음

# 문제는 이러한 설명이 주관적이고 정성적이라는 것임 (정성적 설명은 충분하지 않을 수 있음)
# 따라서 공간적 자기상관관계 같은 통계적 기법을 활용하여 유사성(similarity) 정도를 객관화 할 필요가 있음

# 공간적 자기상관관계 분석에 있어서 가장 간단하고 일반적인 분석 기법은 Global Moran’s I 검정
# 이는 비공간적 정보(여기서는 오존농도)가 공간적으로 상관관계(=인접하고 있는지)가 있는지 검정(test)하는 통계 분석방법임

# 03_오존데이터 공간적 자기상관 분석 방법 

# Moran's I 의 분석방법은 모두 네 단계로로 이루어짐

# 1) 분석대상지를 일정한 형태 및 크기의 공간분석단위(spatial analysis unit)로 분할
# 2) 지리적 공간상에서 발생하는 현상을 단위지역별(예: 카운티 등)로 집계
# 3) 단위지역별로 집계한 결과들 간 유사성(similarity)을 측정

#    유사성: 기준이 되는 어떤 수치로부터 두 지역이 같은 방향으로 크거나 작은 정도를 의미
#    ex) 두 카운티의 오존측정결과의 유사성이 => 전국 평균보다 크다면   -> 두 카운티는 같은 방향으로의 유사성 있음
#                                            => 전국 평균과 동일하다면 -> 두 카운티는 유사성이 없음(무상관)    
#                                            => 전국 평균보다 작다면   -> 두 카운티 유사성 방향이 다름 

# 4) 단위지역들 간 지리적 공간상에서의 인접성(spatial adjacency)을 규정
#    단위지역들이 담고 있는 유사성을 공간적 자기상관성으로 치환하기 위한 필요조건임
#    유사성을 가지는 단위지역들이 지리적 공간상에서 가까이 모이려는 성향이 없고 임의로(randomly) 분포한다면 공간적 자기상관성 없다고 판단

# 04_역거리행렬 생성

ozone.dists <- as.matrix(dist(cbind(ozone$Lon, ozone$Lat)))  # 위경도 기준 거리 행렬 메트릭스 만들기
ozone.dists[1:5, 1:5]

ozone.dists.inv <- 1 / ozone.dists   # 역메트릭스(1/거리) 계산(거리가 가까울수록 증가 / 멀수록 감소)
diag(ozone.dists.inv) <- 0           # 자기자신의 거리는 0 
ozone.dists.inv[1:10, 1:10]

# 05_공간적 유사도 측정(공간자기상관관계)

library(ape)  #  install.packages("ape") 
Moran.I(ozone$Av8top, ozone.dists.inv)  # 분석결과 p < 0.05

# 귀무가설(차이가 없음, 동일함)이 기각
# 대립가설(동일하지 않음= 클러스터링 됨)이 채택됨

rm(list=ls())  # 메모리 정리
dev.off()      # 플롯창 정리

#--------------------------------------------------------------
# 3_(국지) 공간자기상관 분석: Local Moran's I(핫스팟/콜드스팟)
#--------------------------------------------------------------

# 0_개요

# Gloabl Moran's I를 통하여 오존 데이터의 클러스터링이 존재함을 확인하였음
# 그렇다면 어느 지역에 클러스터링이 나타나는가를 특정할 필요가 있음
# 이를 위하여 국지적 공간자기상관관계 분석방법인 Local Moran's I를 사용함
# 분석결과를 통하여 Positive / Negative 클러스터링을 확인할 수 있음
# 이러한 분석 방법을 핫스팟 / 콜드스팟 분석이라고도 함

# 01_데이터 불러오기

load(url("http://159.223.63.63:3838/data/autocorrelation/ozon.rdata"))  # 데이터 불러오기
head(ozone, n=10)  # 미리보기

# 02_오존 측정소 좌표값 추출  

plot(ozone[,4:3])
coord <- ozone[,4:3]
coord
coord <- as.matrix(coord)

# 03_이웃범위 설정

library(spdep)  # install.packages("spdep")
S_dist  <-  dnearneigh(coord, 0, 0.6)  # 이웃(neighborhood) 범위 설정(위경도 0.6도 이내)

S_dist[[18]]  # 72번 관측지점(목록에서 첫번째)의 이웃 관측지점은 1개: 84번(목록에서 6번째) 

# 04_공간 가중치(spatial weights)로 이웃 목록을 작성  

lw <- nb2listw(S_dist, style="W", zero.policy=T)
lw$weights  # 1 / 이웃 갯수

# 05_오존 데이터를 표준화 함

ozone$Av8_norm <- scale(ozone$Av8top)  %>% as.vector()
head(ozone$Av8_norm)

# 06_공간 래그 변수(spatially lagged variable)를 생성

ozone$Av8_norm_lag <- lag.listw(lw, ozone$Av8_norm)

# 07_오존 원 데이터 - 공간 래그 데이터 비교 

summary(ozone$Av8_norm)
summary(ozone$Av8_norm_lag)

# 08_오존 원 데이터 - 공간 래그 데이터 플로팅

x <- ozone$Av8_norm
y <- ozone$Av8_norm_lag

plot(ozone$Av8_norm, ozone$Av8_norm_lag)
moran.plot(x, lw)

# [x]
#  II   |  I      # I   (high-high) : 해당 관측소 오존 ▲ / 이웃 관측소 오존 ▲
# ------|----     # II  (high-low)  : 해당 관측소 오존 ▲ / 이웃 관측소 오존 ▼
#  IV   |  III    # III (low-high)  : 해당 관측소 오존 ▼ / 이웃 관측소 오존 ▲
#          [y]    # IV  (low-low)   : 해당 관측소 오존 ▼ / 이웃 관측소 오존 ▼


# 09_Local Moran's I 특성 추출(평균, 중앙값..)

lmoran <- localmoran(ozone$Av8top, lw)
lmoran

# 10_I분면 데이터와 4분면 데이터만 추출

ozone$quad_sig <- NA   # 모든 분면에 NA값 입력(quadrant-sign)
head(ozone)

# I 분면(high-high) 구하기
ozone[(ozone$Av8_norm >= 0 & ozone$Av8_norm_lag >= 0) & (lmoran[, 5] <= 0.05), "quad_sig"] <- "high-high"

# II 분면(high-low) 구하기
ozone[(ozone$Av8_norm >= 0 & ozone$Av8_norm_lag <= 0) & (lmoran[, 5] <= 0.05), "quad_sig"] <- "high-low"

# III 분면(low-high) 구하기
ozone[(ozone$Av8_norm <= 0 & ozone$Av8_norm_lag >= 0) & (lmoran[, 5] <= 0.05), "quad_sig"] <- "low-high"

# IV 분면(low-low) 구하기
ozone[(ozone$Av8_norm <= 0 & ozone$Av8_norm_lag <= 0) & (lmoran[, 5] <= 0.05), "quad_sig"] <- "low-low"

head(ozone) # 확인

# 11_불필요한 데이터 정리하기

ozone <- na.omit(ozone)  # 공간자기상관의 의미가 없는 관측소(NA 데이터) 지우기 
# lmoran[, 5] > 0.05     # Local Moran's I > 0.05 이면 통계적으로 의미 없음

ozone <- subset(ozone, quad_sig!= "high-low")
ozone <- subset(ozone, quad_sig!= "low-high")
ozone$id <- rownames(ozone)

ozone  # 확인

# 12_분면 정보를 요인형 데이터로 변환 

ozone$quad_sig <- as.factor(ozone$quad_sig)
ozone$quad_sig   # 확인

# 13_플로팅

library(dplyr)
library(ggplot2)
df <- fortify(ozone, region="id")
df <- left_join(df, ozone)

df %>% 
  ggplot(aes(Lon, Lat, group = id, color = quad_sig)) + 
  geom_point(size = 4)  + 
  coord_equal() + 
  theme_void() + 
  scale_fill_brewer(palette = "Set1")

# 14_지도 시각화

library(leaflet)   # 지도 시각화 
library(dplyr)

pal <- colorFactor(palette = c('red', 'blue'),domain = df$quad_sig)
leaflet(df) %>% addTiles() %>% 
  addCircleMarkers(~Lon, ~Lat, color = ~pal(quad_sig))



#############################################################
###########################################################

# 서울시 아파트 매매 실거래 불러오기 
load(url("http://159.223.63.63:3838/data/k_means/apt_seoul.Rdata"))

head(apt_seoul, n=10)  # 미리보기

# 02_좌표값 추출  

plot(apt_seoul[,14:15])
coord <- apt_seoul[,14:15]
coord
coord <- as.matrix(coord)

# 03_이웃범위 설정

library(spdep)  # install.packages("spdep")
S_dist  <-  dnearneigh(coord, 0, 0.0003)  # 이웃(neighborhood) 범위 설정(위경도 0.6도 이내)

S_dist[[3]]  # 3번 관측지점(목록에서 첫번째)의 이웃 관측지점은 1개: 84번(목록에서 6번째) 

# 04_공간 가중치(spatial weights)로 이웃 목록을 작성  

lw <- nb2listw(S_dist, style="W", zero.policy=T)
lw$weights  # 1 / 이웃 갯수

# 05_데이터를 표준화 함

apt_seoul$price_norm <- scale(apt_seoul$price)  %>% as.vector()
head(apt_seoul$price_norm)

# 06_공간 래그 변수(spatially lagged variable)를 생성

apt_seoul$apt_norm_lag <- lag.listw(lw, apt_seoul$price_norm)

# 07_원 데이터 - 공간 래그 데이터 비교 

summary(apt_seoul$price_norm)
summary(apt_seoul$apt_norm_lag)

# 08_오존 원 데이터 - 공간 래그 데이터 플로팅

x <- apt_seoul$price_norm
y <- apt_seoul$apt_norm_lag

plot(apt_seoul$price_norm, apt_seoul$apt_norm_lag)
moran.plot(x, lw)

# [x]
#  II   |  I      # I   (high-high) : 해당 관측소 오존 ▲ / 이웃 관측소 오존 ▲
# ------|----     # II  (high-low)  : 해당 관측소 오존 ▲ / 이웃 관측소 오존 ▼
#  IV   | III     # III (low-high)  : 해당 관측소 오존 ▼ / 이웃 관측소 오존 ▲
#          [y]    # IV  (low-low)   : 해당 관측소 오존 ▼ / 이웃 관측소 오존 ▼


# 09_Local Moran's I 특성 추출(평균, 중앙값..)

lmoran <- localmoran(apt_seoul$price_norm, lw)
lmoran

# 10_I분면 데이터와 4분면 데이터만 추출

apt_seoul$quad_sig <- NA   # 모든 분면에 NA값 입력(quadrant-sign)
head(apt_seoul)

# I 분면(high-high) 구하기
apt_seoul[(apt_seoul$price_norm >= 0 & apt_seoul$apt_norm_lag >= 0) & (lmoran[, 5] <= 0.05), "quad_sig"] <- "high-high"

# II 분면(high-low) 구하기
apt_seoul[(apt_seoul$price_norm >= 0 & apt_seoul$apt_norm_lag <= 0) & (lmoran[, 5] <= 0.05), "quad_sig"] <- "high-low"

# III 분면(low-high) 구하기
apt_seoul[(apt_seoul$price_norm <= 0 & apt_seoul$apt_norm_lag >= 0) & (lmoran[, 5] <= 0.05), "quad_sig"] <- "low-high"

# IV 분면(low-low) 구하기
apt_seoul[(apt_seoul$price_norm <= 0 & apt_seoul$apt_norm_lag <= 0) & (lmoran[, 5] <= 0.05), "quad_sig"] <- "low-low"

head(apt_seoul) # 확인

# 11_불필요한 데이터 정리하기

apt_seoul <- na.omit(apt_seoul)  # 공간자기상관의 의미가 없는 관측소(NA 데이터) 지우기 
# lmoran[, 5] > 0.05     # Local Moran's I > 0.05 이면 통계적으로 의미 없음

apt_seoul <- subset(apt_seoul, quad_sig!= "high-low")
apt_seoul <- subset(apt_seoul, quad_sig!= "low-high")
apt_seoul$id <- rownames(apt_seoul)

apt_seoul  # 확인

# 12_분면 정보를 요인형 데이터로 변환 

apt_seoul$quad_sig <- as.factor(apt_seoul$quad_sig)
apt_seoul$quad_sig   # 확인

# 13_플로팅

library(dplyr)
library(ggplot2)

apt_seoul %>% 
  ggplot(aes(lat, lon, group = id, color = quad_sig)) + 
  geom_point(size = 4)  + 
  coord_equal() + 
  theme_void() + 
  scale_fill_brewer(palette = "Set1")

# 14_지도 시각화

library(leaflet)   # 지도 시각화 
library(dplyr)

pal <- colorFactor(palette = c('red', 'blue'),domain = apt_seoul$quad_sig)
leaflet(apt_seoul) %>% addTiles() %>% 
  addCircleMarkers(~lat, ~lon, color = ~pal(quad_sig))




