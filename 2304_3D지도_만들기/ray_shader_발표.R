
######################
### Rayshader 패키지
#####################

#----------------------
# 0_패키지 설치와 소개
#----------------------

# 0-01_소개

# rayshade 패키지는 raytracing과 hillshading algorithms을 기반으로 하는 R 기반 2D / 3D 매핑 소프트웨어임
# 특히 지도와 관련하여, 이 패키지는 ggplot2 오브젝트를 3D 시각화 할 수 있다는 장점을 가지고 있음
# 이 모델링은 카메라 시점을 움직여서 자유롭게 3D 애니메이션으로 만들 수 있다는 장점을 가지고 있음
# 안내: https://www.rayshader.com/

# 0-02_패키지 설치

# install.packages("devtools")                           
# devtools::install_github("tylermorganwall/rayshader")  # rayshader 패키지 설치하기
# remotes::install_github("dmurdoch/rgl")                # packageVersion("rgl")  # 버전 낮으면 올려줘야 함

#-------------------------------------------------------
# 1_실습 1: 단계도(Choropleth) 3D: North Carolina 출생률
#-------------------------------------------------------

# 1-01_작업디렉토리 세팅

rm(list = ls())
setwd(dirname(rstudioapi::getSourceEditorContext()$path))

# 1-02_라이브러리 불러오기

library(sf)         # install.packages("sf")
library(ggplot2)    # install.packages("remote")
library(rayshader)  # remotes::install_github("tylermorganwall/rayshader")
library(viridis)    # install.packages("viridis")

# 1-03_데이터 불러오기

nc <- st_read(system.file("shape/nc.shp", package="sf"), quiet = TRUE)
head(nc)         # North Carolina주의 카운티별 유아돌연사증후군(Sudden Infant Death Syndrome: SIDS) 샘플 데이터

# 1-04_지도 시각화: 1979년 미국 노스 캘로라이나 카운티별 출생률 시각화

gg_nc <- ggplot(nc) + geom_sf(aes(fill = BIR79, color= 'grey')) +  
                      scale_fill_viridis("Area") +
                      theme(legend.position = "none") +
                      ggtitle("카운티별 출생률") +
                      theme_bw()
gg_nc
class(gg_nc)

# 1-05_3D 시각화

plot_gg(gg_nc,   multicore = TRUE,  width = 6, height= 5, scale= 250, raytrace = FALSE, windowsize=c(1400,866), zoom = 0.55, phi = 30, pad = 50)

# 옵션 설명  
# multicore: 병렬처리 사용여부
# width:  그래프 가로길이(기본 6)
# height: 그래프 세로길이(기본 5)
# scale: 그래프의 크기(기본 250)
# raytrace: 3차원 장면을 사실적으로 랜더링하기 위한 알고리즘
#           (빛의 반사, 굴절 등을 고려하여 그래프를 생성)
# windowsize: 그래프 창 크기(기본값 1400 X 866)  
# zoom: 그래프 줌 레벨 (기본 0.55)
# phi: 그래프 각도(시점) (기본 30)
# pad: 그래프 가장자리 여백(기본 50)
  
#----------------------------------------
# 2_실습 2: 등고선 3D: 인천시 지도 만들기
#----------------------------------------

# 2-01_작업디렉토리 세팅

rm(list = ls())
setwd(dirname(rstudioapi::getSourceEditorContext()$path))

# 2-02_시도 경계선 불러오기

library(raster)                                          # install.packages("sf")
map <-getData('GADM', country='south korea', level=2)    # 레벨 2 수준(시군구) 에서 한국 행정구역 지도 가져오기  
                                                         # 참고: https://gadm.org/maps.html 
map$NL_NAME_1  # 시도명 보기
map$NL_NAME_2  # 시군구명 보기
plot(map)      # 지도 플로팅

# 2-03_시도 경계선 추출(인천만)

library(sf)     # install.packages("sf")
library(dplyr)  # install.packages("dplyr")

map <- as(map, "sf")                        # map 파일 SP 형식 => SF형으로 변환 필요
map <- map %>% filter(NAME_1 == "Incheon")  # 인천만 추출
plot(map$geometry)

# 2-04_인천 추출결과 지도 상에서 확인

library(leaflet)   # install.packages("leaflet")
leaflet() %>% addTiles() %>% addPolygons(data = map)

# 2-05_geo-viz로 DEM 자료 불러오기

library(geoviz)  # install.packages("geoviz")
dem <- mapzen_dem(37.5, 126.3,  square_km = 40, max_tiles = 20)
# mapzen_dem은 Mapzen의 지형 타일(terrain tiles)을 기반으로한 DEM(Digital Elevation Model) 데이터
# 전세계 지형 및 해저지형 데이터를 제공함

# 2-06_DEM 자료 지도 시각화

plot(dem)                 # DEM 자료 불러오기
plot(map$geometry, add=T) # 인천 추출결과 덧붙이기

# 2-07_DEM 자료 필터링(해수면 위 데이터만 필터링)

tmp <- dem <= 0                      # 해수면 아래만 추출
plot(tmp) 

dem <- mask(dem, tmp, maskvalue=1)   # 전체 DEM - 해수면 아래 DEM
plot(dem)
plot(map$geometry, add=T) # 플로팅 

rm("tmp")                            # 불필요한 변수 제거

# 2-08_3D 시각화

library(rasterVis)  # devtools::install_github('oscarperpinan/rasterVis')

mycols <- colorRampPalette(c("blue", "red", "green", "yellow"))
plot3D(dem, col = mycols(100), adjust=TRUE)         # 3D 플로팅

# 2-09_rasterToPoints

library(tibble)                                # install.packages("tibble")
dem_pnt <- as_tibble(rasterToPoints(dem))
dem_pnt <- na.omit(dem_pnt)
plot3d(dem_pnt, maxpixels = 100)

# 2-10_지도 시각화

library(leaflet)
leaflet() %>% addTiles() %>%
              addCircleMarkers(data = dem_pnt[50000:100000,], lng = ~x, lat = ~y, radius= 1)

# 2-11_그리드 2D 지도

library(rayshader)
library(ggplot2)

plot_out <-  ggplot(data=dem_pnt, aes(x = x, y = y, z = layer)) +
             stat_summary_2d(bins = 50, size = 0, color = "black") +# stat_summary_hex()
             scale_fill_viridis_c(option = "C") +
             scale_x_continuous("X",expand = c(0,0)) +
             scale_y_continuous("Y",expand = c(0,0)) +
             scale_fill_gradientn("Z",colours = terrain.colors(10)) + 
             coord_fixed()

plot_out

# 2-12_그리드 3D 지도 

plot_gg(plot_out, multicore = TRUE, raytrace = TRUE, width = 8, height = 8, 
        scale = 300, windowsize = c(1400, 866), zoom = 0.6, phi = 30, theta = 30)


# 2-13_동영상 추출

library(av) # install.packages("av")
render_movie(filename = "demo",  
             type = "orbit", 
             phi = 45,  
             theta = 60)

library(rgl)
rgl.clear()

# 2-14_등고선 2D 지도

plot_out <-  dem_pnt %>% ggplot() +
                geom_tile(aes(x= x,y= y,fill= layer))  +
                geom_contour(aes(x= x,y= y,z= layer),color=NA) + 
                scale_x_continuous("X",expand = c(0,0)) +
                scale_y_continuous("Y",expand = c(0,0)) +
                scale_fill_gradientn("Z",colours = terrain.colors(10)) + 
                coord_fixed()

plot_out

# 2-15_등고선 3D 지도

plot_gg(plot_out, multicore = TRUE, width = 6, height= 2, scale= 250, raytrace = FALSE, windowsize=c(1400,866), zoom = 0.55, phi = 30, pad = 50)

# 2-16_정리하기

library(rgl)
rgl.clear()
rgl.close()


#-----------------------------------------------
# 3_실습 3: 인구 데이터 시각화: 뉴저지 인구밀도
#----------------------------------------------

# 3-01_라이브러리 불러오기

library(tidycensus)  # install.packages("tidycensus")
library(tidyverse)   # install.packages("tidyverse")
library(rayshader)   # install.packages("rayshader")
library(rayrender)   # install.packages("rayrender")
library(sf)          # install.packages("sf")
library(viridis)     # install.packages("viridis")
library(units)       # install.packages("units")

#	4-02_데이터 불러오기

data <- get_acs(variables = "B01001_001", geography = "tract", state = "NJ", survey = "acs5", year = 2019, geometry = TRUE ) %>%  st_transform(3424)
data                
                                
# 4-03_인구밀도 계산

data <- data %>% mutate(area = set_units(st_area(data), mi^2), 
                        pop_density = as.numeric(estimate/area))

data %>% ggplot(aes(fill = pop_density)) +
         geom_sf(color = NA) +
         scale_fill_viridis_c(option = "plasma", trans = "sqrt")

# 4-04_ggplot 그리기

plot <- data %>% ggplot(aes(fill = pop_density)) +
                     geom_sf(color = NA) +
                     scale_fill_viridis_c(option = "plasma", trans = "sqrt") +
                     theme(axis.line = element_line(colour = "transparent"),
                           panel.grid.minor = element_blank(),
                           panel.grid.major = element_blank(),
                           panel.border = element_blank(),
                           axis.title.x = element_blank(),
                           axis.title.y = element_blank(),
                           axis.ticks = element_blank(),
                           axis.text = element_blank(),
                           panel.background = element_rect(fill = "transparent", color = "white"), 
                           plot.background = element_rect(fill = "transparent", colour = "white"), 
                           legend.text = element_text(color = "transparent"),
                           legend.title = element_text(color = "transparent"), 
                           legend.position = "blank")

plot

# 4-03_3D plot 그리기

plot_gg(plot, multicore = TRUE, width = 6, height= 6, scale= 300, fov = 60, theta = 270,  phi = 25, zoom = 0.2, pad = 50, raytrace = FALSE,  windowsize=c(2500,1000), )

# 4-04_정리하기

library(rgl)
rgl::rgl.clear()
rgl.close()


#------------------------------------------
# 4_실습 4: 대한민국 주요도시 인구밀도 현황
#------------------------------------------

# 4-01_작업디렉토리 세팅

rm(list = ls())
setwd(dirname(rstudioapi::getSourceEditorContext()$path))

# 4-02_라이브러리 불러오기

library(rayshader)
library(ggplot2)
library(dplyr)
library(maps)
library(ggmap)

# 4-03_도시 데이터 불러오기

data(world.cities)

# 4-04_대한민국 도시 데이터만 가져오기

world.cities <- world.cities
city <- world.cities %>% filter(country.etc == "Korea South") 

# 4-05_대한민국 지도 가져오기(레스터 데이터)

library(ggmap) # install.packages("ggmap")
city_map <- get_stamenmap(bbox = c(left = min(city$long)-3,
                                   bottom = min(city$lat)-1,
                                   right = max(city$long)+3,
                                   top = max(city$lat)+3),
                          maptype = "watercolor",
                          zoom = 5)
ggmap(city_map)

# 4-06_지도 이미지(워터컬러 이미지) 만들기

city_map_attributes <- attributes(city_map)
city_map_trans <- matrix(adjustcolor(city_map, alpha.f = 0), nrow = nrow(city_map))
attributes(city_map_trans) <- city_map_attributes
city_map_trans

# 4-07_ggplot으로 인구 시각화

together_plot <- ggmap(city_map_trans) +
  geom_point(data = city, 
             aes(x = long, y = lat, color = pop)) +
  scale_color_viridis_c(option = "C")

together_plot

# 4-08_인구 + 지도 시각화

point_plot <- ggmap(city_map) +
                geom_point(data = city, 
                           aes(x = long, y = lat, color = pop)) +
                scale_color_viridis_c(option = "C")
point_plot

# 4-09_3D 지도 

plot_gg(list(point_plot,together_plot),multicore=TRUE, width=4.5, height=4.5, scale=250, windowsize = c(1000,800))


#-----------------------------------
# 5_실습 5: 홍콩 인구밀도 분포
#----------------------------------

# 5-01_디렉토리 세팅

rm(list = ls())
setwd(dirname(rstudioapi::getSourceEditorContext()$path))


population <- read.csv("./tmp/District Name.csv")
colnames(population) = c("name", "Population")

hkmap = readRDS("./tmp/HKG_adm1.rds")

library(ggplot2)
# Preprocessing

map_data = data.frame(id=hkmap$ID_1, Code=hkmap$HASC_1, name=hkmap$NAME_1)
map_data$Code = gsub('HK.', '', as.character(map_data$Code))
map_data = merge(map_data, population, by = 'name')
hkmapdf = fortify(hkmap)
map_data = merge(hkmapdf, map_data, by="id")
map_data$Population = as.numeric(map_data$Population)



# Map
map_bg = ggplot(map_data, aes(long, lat, group=group, fill = Population)) +
  geom_polygon() + # Shape
  scale_fill_gradient(limits=range(map_data$Population), 
                      low="#FFF3B0", high="#E09F3E") + # Population Density Color
  layer(geom="path", stat="identity", position="identity", 
        mapping=aes(x=long, y=lat, group=group, 
                    color=I('#FFFFFF'))) # Boarder Color

map_bg = map_bg + theme(legend.position = "none", 
                        axis.line=element_blank(), 
                        axis.text.x=element_blank(), axis.title.x=element_blank(),
                        axis.text.y=element_blank(), axis.title.y=element_blank(),
                        axis.ticks=element_blank(), 
                        panel.background = element_blank()) # Clean Everything
map_bg

# Save as PNG
xlim = ggplot_build(map_bg)$layout$panel_scales_x[[1]]$range$range
ylim = ggplot_build(map_bg)$layout$panel_scales_y[[1]]$range$range
ggsave('map_bg.png', width = diff(xlim)*40, height = diff(ylim)*40, units = "cm")



##############################################################
# DEMO 2 - Transform the 2D plot into 3D plot with rayshader
##############################################################

# Real Estate Dataset
estate_df = read.csv('./tmp/real_estate_master_df.csv')
estate_df$apr_price = as.numeric(gsub('[^0-9]', '', estate_df$Price_Per_SqFeet_Apr2020))
estate_df$mar_price = as.numeric(gsub('[^0-9]', '', estate_df$Price_Per_SqFeet_Mar2020))

# Read Background Image
library(png)
hk_map_bg = readPNG('map_bg.png')

# 2D Plot
library(ggplot2)
library(grid)
estate_price = ggplot(estate_df) + 
  annotation_custom(rasterGrob(hk_map_bg, width=unit(1,"npc"), height=unit(1,"npc")), 
                    -Inf, Inf, -Inf, Inf) + # Background
  xlim(xlim[1],xlim[2]) + # x-axis Mapping
  ylim(ylim[1],ylim[2]) + # y-axis Mapping
  geom_point(aes(x=Longitude, y=Latitude, color=apr_price), size=2) + # Points
  scale_colour_gradient(name = '成交呎價(實)\n(HKD)', 
                        limits=range(estate_df$apr_price), 
                        low="#FCB9B2", high="#B23A48") + # Price Density Color
  theme(axis.line=element_blank(), 
        axis.text.x=element_blank(), axis.title.x=element_blank(),
        axis.text.y=element_blank(), axis.title.y=element_blank(),
        axis.ticks=element_blank(), 
        panel.background = element_blank()) # Clean Everything
estate_price
ggsave('estate_price.png', width = diff(xlim)*40, height = diff(ylim)*40, units = "cm")


# 3D Plot
library(rayshader)  # install.packages("rayshader")
plot_gg(estate_price, multicore = TRUE, width = diff(xlim)*10 ,height=diff(ylim)*10, fov = 70, scale = 300)

# Windows Size Setting
library(rgl)
par3d(windowRect = c(0, 0, diff(xlim) * 2500, diff(ylim) * 2500))

# Render Image
#render_camera(fov = 70, zoom = 0.2, theta = 30, phi = 20)
#render_depth(focus = 0.8, focallength = 600)

