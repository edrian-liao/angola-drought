%% Generate Monthly Drought Label Data (RZSM) in Angola
clear; clc
load('output\SM_Africa_shapefile.mat','coordsAfrica')
load('input/SMAPCenterCoordinates9KM.mat','SMAPCenterLatitudes','SMAPCenterLongitudes') % Loads SMAP coordinates
%% cut coordinates to Angola
angolashp = shaperead('input\Angola_shp\AGO_adm0.shp','UseGeoCoords',true);

coordsAngola = struct('Lat',[],'Lon',[]);
coordsAngola.Lat = cut2D(coordsAfrica.Lat,coordsAfrica.Lat,coordsAfrica.Lon,angolashp);
coordsAngola.Lon = cut2D(coordsAfrica.Lon,coordsAfrica.Lat,coordsAfrica.Lon,angolashp);
save('output\coordsAngola.mat','coordsAngola')
%% cut soil moisture data to Angola and apply filter
load('output/avgSM_Africa_8day.mat','avgSM_Africa')
avgSM_Angola = cutStruct3D(avgSM_Africa,'SM',coordsAfrica.Lat,coordsAfrica.Lon,angolashp);
RZSM_Angola = filterSurfaceToRZSM(avgSM_Angola,60);
save('output/RZSM_Angola.mat','RZSM_Angola','-v7.3')
%% cut porosity data to Angola
load('input/porosity_9km.mat'); % Loads porosity array
bboxAngola = [-18.0421,-4.3726; 11.6685,24.0821];
porosityAngola = cut2D(porosity,SMAPCenterLatitudes,SMAPCenterLongitudes,bboxAngola);
save('output/porosityAngola.mat','porosityAngola')
%% Drought thresholds from RZSM_Angola
pct = [0.50, 0.30, 0.21, 0.11, 0.06, 0.03];
pctLabels = ["Median","D0","D1","D2","D3","D4"];

% load('output/porosityAngola.mat','porosityAngola')
% load('output/RZSM_Angola.mat','RZSM_Angola')
D_AngolaRoot = calculateDThresholds(RZSM_Angola,porosityAngola,pct,pctLabels);
save('output/DThresholdsAngola_8dayRoot.mat', 'D_AngolaRoot','-v7.3')
%% Aggregate to monthly period using thresholds computed above
% load('output/DThresholdsAngola_8dayRoot.mat', 'D_AngolaRoot')
% load('output/RZSM_Angola.mat','RZSM_Angola')
% load('output/porosityAngola.mat','porosityAngola')
pct = [0.30, 0.21, 0.11, 0.06, 0.03]; % Percentiles of D0-D4 drought
pctValues = [0 1 2 3 4]; % Values correspond to D0-D4 drought
startDate = datetime(2015,04,01);
endDate = datetime(2023,12,02);

aggPct_Angola = aggregateSMPercentilesToMonth(startDate,endDate,...
                D_AngolaRoot,RZSM_Angola,pct,pctValues,porosityAngola);
save('output/aggregatedPercentiles_withDroughtLabels_AngolaRoot.mat','aggPct_Angola')
%% Convert to GeoTIFF
% load('output/coordsAngola.mat')
% load('output/aggregatedPercentiles_withDroughtLabels_AngolaRoot.mat','aggPct_Angola')
for idate = 1:length(aggPct_Angola)
    R = georasterref('RasterSize',size(aggPct_Angola(idate).droughtLabels), ...
    'LatitudeLimits',[min(coordsAngola.Lat,[],'all') max(coordsAngola.Lat,[],'all')],...
    'LongitudeLimits',[min(coordsAngola.Lon,[],'all') max(coordsAngola.Lon,[],'all')]);
    yr = num2str(aggPct_Angola(idate).Year); 
    mo = num2str(aggPct_Angola(idate).Month,'%02d'); %Add zero if single digit
    filename = ['output/Figures/Monthly Angola Drought Labels/',yr,'_',mo,'.tif'];
    geotiffwrite(filename,flipud(aggPct_Angola(idate).droughtLabels),R)
end
