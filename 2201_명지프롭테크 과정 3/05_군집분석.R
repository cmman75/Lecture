
#########################
# 5주_K-means clustering
########################

#-------
# 1_개요
#-------

# 01_군집분석이란?

# 각 객체(대상)의 유사성을 측정하여 
# ① 유사성이 높은 대상집단을 분류
# ② 군집에 속한 객체 들의 유사성과 서로 다른 군집에 속한 객체간의 상이성을 규명하는 분석 방법

# 특성에 따라 고객을 여러 개의 배타적인 집단으로 구분함
# 결과는 분석 방법(모델링)에 따라 달라짐.
# 군집의 개수나 구조에 대한 가정 없이 데이터로부터 거리를 기준으로 군집화를 유도
# 마케팅 조사에서 소비자들의 상품구매행동이나 life style에 따른 소비자군을 분류하여 시장 전략 수립 등에 활용

# 02_k-means clustering

# 가장 간단한 비지도학습 군집(clustering) 알고리즘
# 비지도학습이기 때문에 k-means 클러스터링은 레이블이 없는 데이터들만으로도 작동

# (1) 사용자로부터 입력받은 k의 값에 따라, 임의로 클러스터 중심(centroid) k개를 설정
# (2) k개의 클러스터 중심으로부터 모든 데이터가 얼마나 떨어져 있는지 계산한 후에, 가장 가까운 클러스터 중심을 각 데이터의 클러스터로 정해줌


# (3) 각 클러스터에 속하는 데이터들의 평균을 계산함으로 클러스터 중심을 옮김
# (4) 보정된 클러스터 중심을 기준으로 2, 3단계를 반복
# (5) 더이상 클러스터 중심이 이동하지 않으면 알고리즘을 종료

#------------
# 2_기초분석
#-----------

# 01_아이리스 파일 불러오기

iris <- iris

# 02_데이터 탐색: 상관분석

pairs(iris)  # 변수로 Petal.Width - Sepal.Length 선택

# 03_데이터 탐색: 시각화

library(ggplot2)
ggplot(data=iris, aes(x=Petal.Width, y=Sepal.Length, colour=Species)) + 
   geom_point(shape=19, size=4) 

# 04_최적 클러스터링 갯수 찾기

library(factoextra) # install.packages("factoextra")
fviz_nbclust(iris, kmeans, method = "wss")  # 가장 변동성 없는 구간 선택

# 05_k-means 클러스터링 분석

iris_k_means <- kmeans(iris[,c("Petal.Width", "Sepal.Length")], 3) 
iris_k_means

# 06_분석결과 확인하기

table(iris_k_means$cluster) # 클러스터 사이즈 확인하기
iris_k_means$centers        # 중심점 확인하기 

# 07_iris 데이터 + 클러스터링 분석결과 결합

cluster <- iris_k_means$cluster
iris_k_means_x_y <- cbind(cluster, iris[,c("Petal.Width", "Sepal.Length")])
head(iris_k_means_x_y)

# 08_분석결과 시각화

ggplot(data=iris_k_means_x_y, 
  aes(x=Petal.Width, y=Sepal.Length, colour=cluster)) + 
  geom_point(shape=19, size=4) 


#-----------------------------------------------
# 3_K-Means를 활용한 서울시 아파트 하위시장 분석 
#-----------------------------------------------

# 01_서울시 아파트 실거래가 데이터 불러오기

load(url("http://159.223.63.63:3838/data/k_means/apt_seoul.Rdata"))
load(url("http://159.223.63.63:3838/data/k_means/seoul_bnd.Rdata"))

plot(bnd$geometry)

# 02_실거래가 데이터 지도로 확인하기

library(ggplot2) # install.packages("ggplot2")
ggplot(apt_seoul, aes(x=lat, y=lon)) + geom_point()

# 03_클러스터 수 설정하기 

K = 5

# 04_임의 중심점 k개 설정하기 

init_centroids_index = sample(nrow(apt_seoul),K)   # 랜덤 샘플링 통한 임의 중심점 5개(k=5) 설정하기 
init_centroids_index   
ggplot(apt_seoul, aes(x=lat, y=lon)) + geom_point(color = "grey") +  geom_point(data=apt_seoul[init_centroids_index,], color = "red", size =3)

# 05_거리계산 컨테이너(빈깡통) 만들기

distance_matrix = matrix(data = NA, nrow = nrow(apt_seoul), ncol = K)      # 빈 메트릭스 만들기 
head(distance_matrix)
tail(distance_matrix)

# 06_빈벡터 만들기

cluster = vector()    
centroid_lon = vector()
centroid_lat = vector()

# 07_각 아파트 단지(point 1)와 초기 중심지(point 2) 사이의 거리를 계산

library(geosphere)

for (k in c(1:K)) {                                                   # (1) k=5 => 5번 반복하기 
  for (i in c(1:nrow(apt_seoul))) {                                   # (2) i는 1에서 부터 모든 아파트 단지(6605개) 반복 
    apt_i = as.numeric(apt_seoul[i,14:15])                            # (3) apt_i는 i 번째 아파트 단지의 좌표값
    centroid_k = as.numeric(apt_seoul[init_centroids_index[k],14:15]) # (4) centroid_k => 랜덤 샘플링 한 5개 아파트 단지의 좌표값 
    distance_matrix[i,k] = distHaversine(apt_i, centroid_k)           # (5) apt_i - centroid_k 모든 거리 계산하여 메트릭스에 넣기 
    msg <- paste0("[", k, "번째", i, "아파트 거리 계산 완료]")
    cat(msg, "\n\n")
  }
}

head(distance_matrix) # 계산결과 확인

# 08_초기(initial) 클러스터 할당 (distance_matrix의 k1 ~ k5 중에서 최소가 되는 값 선택)

for (i in c(1:nrow(apt_seoul))) {
  cluster[i] = which.min(distance_matrix[i,])
  }

cluster  # 클러스터링 결과 확인

# 09_반복설정

old_cluster = vector(length = length(cluster))
new_cluster = cluster
head(new_cluster)

# 10_반복 계산

cnt <- 1

while (!all(old_cluster == new_cluster)) { # old 와 new가 똑같아지면 멈춤)
  # 최적 중심점 5개 업데이트
  old_cluster = new_cluster
  for (k in c(1:K)) {
    cluster_k = which(old_cluster == k) 
    centroid_lon[k] = weighted.mean(apt_seoul$lon[cluster_k], apt_seoul$py[cluster_k]) 
    centroid_lat[k] = weighted.mean(apt_seoul$lat[cluster_k], apt_seoul$py[cluster_k])  
  }
  df_centroid = as.data.frame(cbind(centroid_lat, centroid_lon))
  # 아파트와 중심점 거리 계산
  for (k in c(1:K)) {
    for (i in c(1:nrow(apt_seoul))) {
      apt_i = as.numeric(apt_seoul[i,14:15])
      centroid_k = as.numeric(df_centroid[k,])
      distance_matrix[i,k] = distHaversine(apt_i, centroid_k)
    }
  }
  # 각 도시의 클러스터 할당 업데이트
  for (i in c(1:nrow(apt_seoul))) {
    cluster[i] = which.min(distance_matrix[i,])
  }
  # 새로운 클러스터 할당 업데이트
  cnt <- cnt + 1
  new_cluster = cluster
  cat(cnt, "\n\n")
}

# 11_old와 new 비교

new_cluster
old_cluster

# 12_클러스터 번호 할당 

apt_seoul$cluster <- as.factor(new_cluster)

# 13_시각화 표현하기

library(ggplot2)
my_pal <- RColorBrewer::brewer.pal(n=8, name = "Dark2")
ggplot(apt_seoul, aes(x = lat, y = lon, color = cluster, fill = new_cluster)) + geom_point(size = 4, shape = 21)

# 14_컨벡스 헐 알고리즘

library(plyr)  # install.packages("ply)
find_hull = function(df) df[chull(df[,1], df[,2]), ]
boundary = ddply(apt_seoul[,14:16], .variables = "new_cluster", .fun = find_hull)

library(ggplot2)
library(sf)
ggplot(apt_seoul, aes(lat, lon, color = new_cluster, fill = cluster)) + 
   geom_point(size = 2) + 
   geom_polygon(data = boundary, aes(lat, lon), alpha = 0.5)



fit <- lm(apt_seoul$price ~ apt_seoul$cluster)
summary(fit)

ggplot(data=apt_seoul, aes(x=ymd, y=price, group=cluster)) +
  geom_point(color="red", size= 1) +
  facet_wrap(~cluster, scale='free_y', ncol=3) +
  stat_smooth(method = 'lm')
