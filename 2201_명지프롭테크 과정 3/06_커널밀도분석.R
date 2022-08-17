
###################
# 6주_커널밀도분석
###################

#---------------------------------
# 1_메사추세스의 스타벅스 입지특성
#--------------------------------

# 01_파일 불러오기  

load(url("http://159.223.63.63:3838/data/kernel/starbucks.Rdata"))

# starbucks : 메사추세스 스타벅스 매장 위치 (ppp layer)
# ma        : 매사추세스 행정경계 (polygon layer)
# pop       : 메사추세스 인구밀도 분포 (image layer)

# 02_라이브러리 등록하기 

library(sf)
library(spatstat)   # install.packages("spatstat")
library(rgdal)      # install.packages("rgdal")
library(maptools)   # install.packages("maptools")
library(raster)     # install.packages("raster")

# 03_매사추세스 지역 내 스타벅스 위치 플로팅 

plot(ma, main=NULL)    # 메사추세스 경계 그리기 
plot(starbucks, cols= "red", pch=20, add=T) # 스타벅스 위치 그리기

# 04_인구밀도 분포 특성 분석과 변환[로그변환]

plot(pop) # 인구밀도 그리기
hist(pop, main=NULL, las=1)  # 대부분 저밀집 지역임

# 이대로 인구밀도 데이터를 쓸 수 없기 때문에 변환 필요함
# 이 때 사용하는 변환 방법 중 하나가 로그변환임

# 로그변환은 데이터의 x 축과 y 축의 스케일이 지나치게 비대칭적일 때 사용함
# 연령에 따른 재산보유액 연구: 연령: 0~80세, 재산보유액: 0 ~ 1조원
# 데이터 간 단위가 지나치게 다르면 결과값이 이상해 질 수 있음
# 이러한 경우 양변에 log 취함: log는 큰 수를 같은 비율의 작은 수로 바꿔줌
# => 결과적으로 복잡한 계산을 심플하게 만들어 줌

pop.lg <- log(pop) 
hist(pop.lg, main=NULL, las=1)

# 05_로그변환 전 / 후 비교(pop vs. pop_log)

par(mfrow = c(1,2))
hist(pop, main=NULL, las=1) ; hist(pop.lg, main=NULL, las=1)  # 로그변환 이전 / 이후
plot(pop, main=NULL); plot(pop.lg, main=NULL)                 # 로그변환 이전 / 이후
rm(pop) ; par(mfrow = c(1,1))                                 # 불필요한 변수 지우기 

# 06_Quardrat 카운팅

Q <- quadratcount(starbucks, nx= 6, ny=3) ; plot(Q)  # 대상지역을 3 X 6의 격자 셀로 구분
plot(starbucks, pch=20, cols="red", main=NULL, add=T)    # 스타벅스 위치 포인트 그리기 
plot(ma, main=NULL, border="blue", add=TRUE)  

Q_table <- as.data.frame(Q) ; Q_table                # 각 셀별로 포인트 개수 카운팅
rm(Q_table)                                          # 불필요한 변수 지우기

# 07_밀도분석과 플로팅

intensity(Q)  # 셀별 포인트 밀도 

# 셀별 밀도가 너무 낮음 => why? 단위가 m이기 때문에 => km 단위로 재조정 필요함
plot(intensity(Q, image=TRUE), main=NULL, las=1)        # 셀별 포인트 밀도 플로팅
plot(starbucks, pch=20, cex=0.6, col= "red", add=TRUE)  # 스타벅스 매장위치 표시
plot(ma, main=NULL, border="orange", add=TRUE)  

# 08_스케일 재조정 rescale (지도를 m^2 단위 => km^2 단위로 조정)

pop.lg.km <- rescale(pop.lg, 1000, "km")   # 로그 인구밀도 지도 스케일 변환
pop.lg; pop.lg.km
plot(pop.lg.km, main=NA)

ma.km <- rescale(ma, 1000, "km") # 메사추세스 경계지도 스케일 변환(m -> km)
ma; ma.km
plot(ma.km, add=T)

starbucks.km <- rescale(starbucks, 1000, "km")   # 스타벅스 위치지도 스케일 변환
starbucks; starbucks.km
plot(starbucks.km, col ="black", pch= 20, add=T)

rm(list = c('starbucks', 'ma', 'pop.lg', 'Q', 'Q_density', 'Q.d')) # 불필요한 변수 지우기

# 09_재조정된 스케일(km^2 단위로 재조정)

Q <- quadratcount(starbucks.km, nx= 6, ny=3)
Q_density <- intensity(Q)

# 10_인구밀도 특성에 따라 적절하게 등급을 구분함

hist(pop.lg.km)                    # 히스토그램 모양으로 살펴보면 
abline(v = c(4, 6, 8), col="red")  # pixel value가 4, 6, 8 되는 지점을 구분

# [참고] 테셀레이션(Tessellation)이란?
# 마루나 욕실 바닥에 깔려 있는 타일처럼 어떠한 틈이나 포개짐이 없이 평면이나 공간을 도형으로 완벽하게 덮는 것을 의미

# 11_테셀레이션 분석(불규칙적인 그리드 분석)

# 인구밀도 래스터 데이터를 이용하여 비균일한 표면을 만들 수 있음
# 인구밀도를 크게 4개 등급으로 구분(비균일 표면)  

brk  <- c( -Inf, 4, 6, 8 , Inf)   # 구분점을 기점으로 brk[break] 만들어 줌

Zcut <- cut(pop.lg.km, breaks=brk, labels=1:4)  # 레스터 데이트를 등급에 따라 구분
E    <- tess(image=Zcut)                        # 비균일 표면(tesselated surface) 생성

plot(E, main="", las=1)     # 로그화된 인구밀도(pop.lg.km)에 따라 메사추세스를 구분함

# 12_tessellation surface 분석 1: 매장 숫자(point) 카운팅 

Q <- quadratcount(starbucks.km, tess = E)  # 등급에 따라 포인트(스타벅스 매장 수) 카운팅 하기
plot(Q)   # plot에 숫자 나타내기
Q         # 인구밀도 등급에 따른 매장 수 

# 1  2  3  4   [인구밀도 등급]   =>  인구밀도가 증가할 수록 매장 수가 증가 
# 0  3 86 82   [스타벅스 매장 수]

# 13-1_tessellation surface 2: 밀도분석

library(sysfonts)  # 시스템 폰트 로딩(우분투에서 플롯 한글깨짐 방지)
font_add("NanumGothic","/usr/share/fonts/NanumFont/NanumGothic.ttf")

Q_density <- intensity(Q)  ; Q_density   # 인구밀도 등급에 따른 매장 밀도 (매장 수 / km^2)

plot(intensity(Q, image=TRUE), las=1, main="인구밀도와 스타벅스")  # 인구밀도
plot(starbucks.km, pch=20, cex=0.6, col="red", add=TRUE)           # 스타벅스 매장위치

# 13-2_똑같은 밀도분석을 다음과 같이 컬러를 change하여 분석할 수도 있음

cl <-  interp.colours(c("lightyellow", "orange" ,"red"), E$n)      # 컬러 세팅
plot(intensity(Q, image=TRUE), las=1, col=cl, main=NULL)           # 인구밀도분포
plot(starbucks.km, pch=20, cex=1, col="blue", add=TRUE)   # 스타벅스 매장위치

# 14_커널밀도추정 분석

K1 <- density.ppp(starbucks.km) # 커널밀도는 함수의 모양과 대역폭(bandwidth)을 설정하는것이 
                                # 중요한데 여기에서는 디폴트값 사용
plot(K1, main=NULL, las=1)      # 플로팅하기 
plot(starbucks.km, pch=20, cex=0.6, col="red", add=TRUE)  # 스타벅스 매장위치
plot(ma.km, main=NULL, add=TRUE)  # 행정구역 경계
contour(K1, add=TRUE)             # contour 그리기 

K2 <- density(starbucks.km, sigma=50) # 대역폭(bandwidth)을 50km 로 설정

plot(K2, main=NULL, las=1)
plot(starbucks.km, pch=20, cex=0.6, col="red", add=TRUE)  # 스타벅스 매장위치
plot(ma.km, main=NULL, add=TRUE)  
contour(K2, add=TRUE)

K3 <- density(starbucks.km, kernel = "disc", sigma=50) # 대역폭(bandwidth)을 50km 로 설정하고
                                                       # 커널 모양을 디스크 형태로 설정
plot(K3, main=NULL, las=1)
plot(starbucks.km, pch=20, cex=0.6, col="black", add=TRUE)  # 스타벅스 매장위치
plot(ma.km, main=NULL, add=TRUE)  
contour(K3, add=TRUE)      # 커널모양 옵션: gaussian, epanechnikov, quartic, disc emd

# 15_공간 상관관계 분석: 스타벅스 매장 간의 거리(ANN: average nearest neighbor)

# 일정한 범위 안에 다른 스타벅스 매장이 있을 확률 계산
mean(nndist(starbucks.km, k=1))   # 최소 한 개 매장
mean(nndist(starbucks.km, k=2))   # 최소 두 개 매장

# 가장 인접하고 있는 매장 20 개의 거리(평균) => 5km, 10km 지점에서 변화 보임
ANN <- apply(nndist(starbucks.km, k=1:20),2,FUN=mean)
plot(ANN ~ eval(1:20), type="b", main=NULL, xlab="가까운 스타벅스", ylab="거리(km)",las=1)

# 16_Nearest Neighbor Analysis(가장 가까운 이웃 스타벅스 매장 간 거리 기반 분석): G-F Function 분석 

# G Function은 가장 가까운 이웃간의 거리에 대한 분포의 누적도수분포 함수로 정의함
# (1) 분석하고자 하는 Point 간의 최단 거리를 계산
# (2) 기준 거리를 늘려감에 따라 Point 간의 최단거리가 기준거리 미만이 되는 점들의 갯수를 누적하여 그래프화

G_fun <- Gest(starbucks.km)
plot(G_fun, main = "메사추세스 스타벅스 G-Value")

# F-Function의 경우 가장 가까운 이웃간의 거리에 대한 분포의 누적도수분포 함수로 정의함
# (1) 분석하고자 하는 지역 전체에 무작위(Random)로 Point를 배치한 다음 
# (2) 포인트 간 최단 거리를 계산 
# (3) (이후 G 함수와 마찬가지로) 기준 거리를 늘려감에 따라 Point 간의 최단거리가 기준거리 미만이 되는 점들의 갯수를 누적하여 그래프화

F_fun <- Fest(starbucks.km)
plot(F_fun, main = "메사추세스 스타벅스 F-Value")

# G/F-Function 값 해석
# (1) 가운데 파란색의 그래프는 Point Pattern이 Poisson 분포를 따른다고(Complete Spatial Randomness distribution) 가정할 때 이상적인 분포 형태 
# (2) G Function => 가까운 거리에서는 G-Value > Poission 분포 / 먼거리에서는 G-Value < Poission 분포
#                   가까운 스타벅스 매장은 평균거리보다 가까이(밀집되어) 있으며 / 멀리 있는 스타벅스 매장은 평균거리보다 떨어져(분산되어) 있음 
# (3) F Function => 가까운 거리에서는 F-Value < Poission 분포 / 먼거리에서는 F-Value > Poission 분포
#                   가까운 스타벅스 매장은 이상치보다 가까이 있으며 / 멀리 있는 스타벅스 매장은 이상분포치에 가까움

rm(list = ls()) # 메모리 정리
graphics.off()  # 그래픽 정리


#---------------------------------
# 2_서울 스타벅스 입지특성
#--------------------------------

# 01_파일 불러오기  

# 서울시 생활인구 밀도 레스터 데이터 불러오기
load(url("http://159.223.63.63:3838/data/kernel/seoul_pop.Rdata"))  
pop <- d ; rm("d")
plot(pop)

# 서울시 스타벅스 위치 데이터 불러오기 
load(url("http://159.223.63.63:3838/data/kernel/seoul_starbucks.Rdata"))
plot(starbucks)

# 서울시 경계도 불러오기 
load(url("http://159.223.63.63:3838/data/kernel/seoul_bnd.Rdata"))
plot(bnd, col=NA, border="red", add=TRUE)

# starbucks : 서울 스타벅스 매장 위치  (ppp layer)
# bnd       : 서울 행정경계   (polygon layer)
# pop       : 서울 인구밀도 분포    (raster layer)

# 02_라이브러리 등록하기 

library(spatstat)   # install.packages("spatstat")
library(rgdal)      # install.packages("rgdal")
library(maptools)   # install.packages("maptools")
library(raster)     # install.packages("raster")

# 03_인구밀도 분포 특성 분석 => 로그변환 필요한가?

plot(pop) # 인구밀도 그리기
hist(pop, main=NULL, las=1)  # bias가 크지 않기 때문에 안해도 될 것 같음

# 04_Quardrat 카운팅

Q <- quadratcount(starbucks, nx= 6, ny=3) ; plot(Q)    # 대상지역을 3 X 6의 격자 셀로 구분
plot(starbucks, pch=20, cols="red", main=NULL, add=T)  # 스타벅스 위치 포인트 그리기 
Q_table <- as.data.frame(Q) ; Q_table                  # 각 셀별로 포인트 개수 카운팅
rm(Q_table)                                            # 불필요한 변수 지우기

# 05_밀도분석과 플로팅

intensity(Q)  # 셀별 포인트 밀도 
# 셀별 밀도가 너무 낮음 => why? 단위가 m이기 때문에 => km 단위로 재조정 필요함

plot(intensity(Q, image=TRUE), main=NULL, las=1)               # 셀별 포인트 밀도 플로팅
plot(starbucks, pch=20, cex=1, col= "black", add=TRUE)  # 스타벅스 매장위치 표시
plot(bnd, col=NA, border="black", add=TRUE)

# 6_인구밀도 특성에 따라 적절하게 등급을 구분함

hist(pop)                    # 히스토그램 모양으로 살펴보면 
abline(v = c(100000, 600000, col="red"))  # pixel value가 4, 6, 8 되는 지점을 구분

# [참고] 테셀레이션(Tessellation)
# 마루나 욕실 바닥에 깔려 있는 타일처럼 어떠한 틈이나 포개짐이 없이 평면이나 공간을 도형으로 완벽하게 덮는 것

# 7_테셀레이션 분석(불규칙적인 그리드 분석)

# 인구밀도 래스터 데이터를 이용하여 비균일한 표면을 만들 수 있음
# 인구밀도를 크게 4개 등급으로 구분(비균일 표면)  

brk  <- c( -Inf, 100000, 600000, Inf)   # 구분점을 기점으로 brk[break] 만들어 줌

Zcut <- cut(pop, breaks=brk, labels=1:3)  # 레스터 데이트를 등급에 따라 구분
E    <- tess(image=Zcut)                        # 비균일 표면(tesselated surface) 생성

plot(E, main="", las=1)     # 로그화된 인구밀도(pop.lg.km)에 따라 서울 구분함

# 8_tessellation surface 분석 1: 매장 숫자(point) 카운팅 

Q <- quadratcount(starbucks, tess = E)  # 등급에 따라 포인트(스타벅스 매장 수) 카운팅 하기
plot(Q)   # plot에 숫자 나타내기
Q         # 인구밀도 등급에 따른 매장 수 

# 1   2   3     [인구밀도 등급]   =>  중간 밀도가 많음
# ------------                       
# 81 336  74   [스타벅스 매장 수]

# 9-1_tessellation surface 2: 밀도분석

library(sysfonts)  # 시스템 폰트 로딩(우분투에서 플롯 한글깨짐 방지)
                   # 윈도우에서는 작업시 무시해도 됨 
font_add("NanumGothic","/usr/share/fonts/NanumFont/NanumGothic.ttf")

Q_density <- intensity(Q)  ; Q_density   # 인구밀도 등급에 따른 매장 밀도 (매장 수 / km^2)

plot(intensity(Q, image=TRUE), las=1, main="인구밀도와 스타벅스")  # 인구밀도
plot(starbucks, pch=20, cex=0.6, col="red", add=TRUE)              # 스타벅스 매장위치

# 9-2_똑같은 밀도분석을 다음과 같이 컬러를 change하여 분석할 수도 있음

cl <-  interp.colours(c("lightyellow", "orange" ,"red"), E$n)      # 컬러 세팅
plot(intensity(Q, image=TRUE), las=1, col=cl, main=NULL)           # 인구밀도분포
plot(starbucks, pch=20, cex=1, col="black", add=TRUE)   # 스타벅스 매장위치

# 10_커널밀도추정 분석(세가지 시나리오)

K1 <- density.ppp(starbucks) # 커널밀도는 함수의 모양과 대역폭(bandwidth)을 설정하는것이 
                             # 중요한데 여기에서는 디폴트 값을 사용함
plot(K1, main=NULL, las=1)      # 플로팅하기 
plot(starbucks, pch=20, cex=0.6, col="red", add=TRUE)  # 스타벅스 매장위치
plot(bnd, main=NULL, col=NA, add=TRUE)  
contour(K1, add=TRUE)           # contour 그리기 

K2 <- density(starbucks, sigma=0.01) # 대역폭(bandwidth)를 0.1km 로 설정하였을 때

plot(K2, main=NULL, las=1)
plot(starbucks, pch=20, cex=0.6, col="red", add=TRUE)  # 스타벅스 매장위치
plot(bnd, main=NULL, col=NA, add=TRUE) 
contour(K2, add=TRUE)

K3 <- density(starbucks, kernel = "disc", sigma=0.01) # 대역폭(bandwidth)을 0.1km 로 설정하고

plot(K3, main=NULL, las=1)                             # 커널함수 모양을 디스크 함수로 사용하였을 때
plot(starbucks, pch=20, cex=0.6, col="red", add=TRUE)  # 스타벅스 매장위치
plot(bnd, main=NULL, col=NA, add=TRUE) 
contour(K3, add=TRUE)                                  # 함수모양 옵션: gaussian, epanechnikov, quartic, disc emd

# 11_공간 상관관계 분석: 스타벅스 매장 간의 거리(ANN: average nearest neighbor)

# 일정한 범위 안에 다른 스타벅스 매장이 있을 확률 계산
mean(nndist(starbucks, k=1))*1000   # 최소 한 개 매장
mean(nndist(starbucks, k=2))*1000   # 최소 두 개 매장

# 가장 인접하고 있는 매장 20 개의 거리(평균) => 5km, 10km 지점에서 변화 보임
ANN <- apply(nndist(starbucks, k=1:20),2,FUN=mean)
plot(ANN ~ eval(1:20), type="b", main=NULL, xlab="가까운 스타벅스", ylab="거리(km)",las=1)

# 12_Nearest Neighbor Analysis(가장 가까운 이웃 스타벅스 매장 간 거리 기반 분석): G-F Function 분석 

# G Function은 가장 가까운 이웃간의 거리에 대한 분포의 누적도수분포 함수로 정의함
# (1) 분석하고자 하는 Point 간의 최단 거리를 계산
# (2) 기준 거리를 늘려감에 따라 Point 간의 최단거리가 기준거리 미만이 되는 점들의 갯수를 누적하여 그래프화

G_fun <- Gest(starbucks)
plot(G_fun, main = "서울 스타벅스 G-Value")

# Function의 경우 가장 가까운 이웃간의 거리에 대한 분포의 누적도수분포 함수로 정의함
# (1) 분석하고자 하는 지역 전체에 무작위(Random)로 Point를 배치한 다음 
# (2) 포인트 간 최단 거리를 계산 
# (3) (이후 G 함수와 마찬가지로) 기준 거리를 늘려감에 따라 Point 간의 최단거리가 기준거리 미만이 되는 점들의 갯수를 누적하여 그래프화

F_fun <- Fest(starbucks)
plot(F_fun, main = "서울 스타벅스 G-Value")

# G/F-Function 값 해석
# (1) 가운데 파란색의 그래프는 Point Pattern이 Poisson 분포를 따른다고(Complete Spatial Randomness distribution) 가정할 때 이상적인 분포 형태 
# (2) G Function => 가까운 거리에서는 G-Value > Poission 분포 / 먼거리에서는 G-Value < Poission 분포
#                   가까운 스타벅스 매장은 평균거리보다 가까이(밀집되어) 있으며 / 멀리 있는 스타벅스 매장은 평균거리보다 떨어져(분산되어) 있음 
# (3) F Function => 가까운 거리에서는 F-Value < Poission 분포 / 먼거리에서는 F-Value > Poission 분포
#                   가까운 스타벅스 매장은 이상치보다 가까이 있으며 / 멀리 있는 스타벅스 매장은 이상분포치에 가까움






