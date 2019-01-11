function [MSD,precip_clim,imsd_climatology]...
    =detect_daily(precip,time,lat_full,varargin)
%detect_daily - Detecting climatological and annual MSD events
%  Syntax
%
%  [MSD]=detect_daily(precip,time,lat_full);
%  [MSD,precip_clim,imsd_climatology]=detect_daily(precip,time,lat_full,varargin);
%
%  Description
%
%  [MSD]=detect_daily(precip,time,lat_full) returns a table MSD, containing
%  all the detected MSD siganls based on daily rainfall data PRECIP
%  (m-by-n-by-t). TIME is the corresponding time of PRECIP in the format of
%  datenum(), e.g. datenum(1979,1,1):datenum(2017,12,31). LAT_FULL (m-by-n) is the
%  latitude in each grid.
%
%  [MSD,precip_clim,imsd_climatology]=detect_daily(precip,time,lat_full,varargin)
%  also returns outputs associated with climatological MSD. PRECIP_CLIM is
%  the climatology of precipitation. IMSD_CLIMATOLOGY is the intensity of
%  the 
%
%  Input Arguments
%   precip - 3D daily precipitation (mm/day) to detect MSD events,
%   specified as a m-by-n-by-t matrix. m and n separately indicate two
%   spatial dimensions and t indicates temporal dimension.
%
%   time - A numeric vector corresponding to the time of 
%
%   lat_full - A numeric matrix (m-by-n) indicating latitude for PRECIP.
%   This is actually used to distinguish the situation in northern/southern
%   hemisphere so if you do not have exact latitude data please use
%   positive/negative value for northern/southern hemisphere.
%
%   'smoothwidth' - Default is 31. Width of window to smooth raw and
%   climatological precipitation
%
%   'clim_start' - Default is the first element of TIME. The time for the
%   calculation of climatology in the format of datenum().
%
%   'clim_end' - Default is the last element of TIME. The time for the
%   calculation of climatology in the format of datenum().
%
%   'msd_start' - Default is the first year with complete annual
%   precipitation in the format of datenum().
%
%   'msd_end' - Default is the last year with complete annual precipitation
%   in the format of datenum().
%
%  Output Arguments
%   MSD - A table containing all detected MSD events where each row
%   corresponding to a particular event and each column corresponding to a
%   metric. Specified metrics are:
%       - YEAR - the year when MSD events happen. For southern hemisphere,
%       it corresponds to the first half year.
%       - XLOC - location of each event in x-dimension of PRECIP.
%       - YLOC - location of each event in y-dimension of PRECIP.
%       - ONSET - the onset date of each event in the format of datenum().
%       - ONSET_D - the day of year for ONSET.
%       - ENDING - the ending date of each event in the format of
%       datenum().
%       - ENDING_D the day of year for ENDING.
%       - PEAK - the peak date of each event in the format of datenum().
%       - PEAK_D - the day of year for PEAK_D.
%       - Pmax.
%       - Pmin.
%       - P1 - the precipitation on the onset of MSD.
%       - P2 - the precipitation on the end of MSD.
%       - imsd - the intensity of MSD.
%
%   precip_clim - A 3D matrix (m-by-n-by-366) containing climatologies.
%
%   imsd_climatology - A matrix (m-by-n) containing the intensity of MSD
%   calculated based on precip_clim.

date_used=datevec(time);
warning off

paramNames = {'smoothwidth','clim_start','clim_end','msd_start','msd_end'};
defaults   = {31,time(1),time(end),date_used(1,1),date_used(end,1)};

[vsmoothwidth, vclim_start,vclim_end,vmsd_start,vmsd_end]...
    = internal.stats.parseArgs(paramNames, defaults, varargin{:});

precip_for_clim=precip(:,:,(vclim_start:vclim_end)-time(1)+1);

%% calculating climatology
u_m_d=unique(date_used(:,2:3),'rows');

precip_clim=NaN(120,60,366);

fprintf('Calculating the climatology\n');

for i=1:size(u_m_d,1);
    index_here = date_used(:,2)==u_m_d(i,1) & date_used(:,3)==u_m_d(i,2);
    precip_clim(:,:,i)=nanmean(precip_for_clim(:,:,index_here),3);
end

precip_clim_sm=smoothdata(precip_clim,3,'gaussian',vsmoothwidth);

%% determining the MSD area
binary_msd=NaN(120,60);

imsd_climatology=NaN(120,60);


for i=1:size(precip_clim_sm,1);
    
    for j=1:size(precip_clim_sm,2);
        fprintf(['Determining the MSD area, current location: x' num2str(i) ' y' num2str(j) '\n']);
        precip_here=squeeze(precip_clim_sm(i,j,:));
        lat_here=lat_full(i,j);
        period_here=(datenum(2016,1,1):datenum(2016,12,31))';
        if nansum(isnan(precip_here))~=length(precip_here);
            if lat_here<0;
                period_here=[period_here((datenum(2016,7,1):datenum(2016,12,31))-datenum(2016,1,1)+1);...
                    period_here((datenum(2016,1,1):datenum(2016,6,30))-datenum(2016,1,1)+1)];
                precip_here=[precip_here((datenum(2016,7,1):datenum(2016,12,31))-datenum(2016,1,1)+1);...
                    precip_here((datenum(2016,1,1):datenum(2016,6,30))-datenum(2016,1,1)+1)];
                
                period_1=[(datenum(2016,11,15):datenum(2016,12,31))';(datenum(2016,1,1):datenum(2016,1,15))'];
                period_1_index=find(ismember(period_here,period_1));
                
                period_2=(datenum(2016,2,15):datenum(2016,4,15))';
                period_2_index=find(ismember(period_here,period_2));
                
            else
                period_1=(datenum(2016,5,15):datenum(2016,7,15))';
                period_1_index=find(ismember(period_here,period_1));
                
                period_2=(datenum(2016,8,15):datenum(2016,10,15))';
                period_2_index=find(ismember(period_here,period_2));
                
            end
            
            rain_p1=precip_here(period_1_index);
            [p1,loc1]=nanmax(rain_p1);
            ind1=period_1_index(loc1);
            
            rain_p2=precip_here(period_2_index);
            [p2,loc2]=nanmax(rain_p2);
            ind2=period_2_index(loc2);
            
            mdl_start=fitlm(1:ind1,precip_here(1:ind1));
            mdl_end=fitlm(ind2:366,precip_here(ind2:end));
            trend_start=mdl_start.Coefficients.Estimate(2);
            p_start=mdl_start.Coefficients.pValue(2);
            trend_end=mdl_end.Coefficients.Estimate(2);
            p_end=mdl_end.Coefficients.pValue(2);
                
            if ind1==period_1_index(end) || ind2==period_2_index(1) ... %%|| nanmax(clim_here(ind1+15:ind2-15))>=pmax1 || nanmax(clim_here(ind1+15:ind2-15))>=pmax2 ...
                    || (~ismember(nanmax(precip_here),[p1,p2])) || trend_start<=0 || trend_end>=0 || p_start>0.05 || p_end>0.05
                binary_msd(i,j)=0;
            else
                pmax=nanmax([p1 p2]);
                pmin=nanmean(precip_here(ind1:ind2));
                
                imsd=(pmax-pmin)./pmax;
                binary_msd(i,j)=1;
                imsd_climatology(i,j)=imsd;
                
            end
        end
    end
    
end

%% Determining the MSD event

[x,y]=find(binary_msd==1);

MSD=[];

precip_smooth=smoothdata(precip,3,'gaussian',vsmoothwidth);

for i=1:length(x)
    fprintf(['Detecting MSD events, current location: x' num2str(x(i)) ' y' num2str(y(i)) ' ' num2str(i) ' in ' num2str(length(x)) '\n']);
    precip_here=squeeze(precip_smooth(x(i),y(i),:));
    lat_here=lat_full(x(i),y(i));
    if nansum(isnan(precip_here))~=length(precip_here)
        
        year_used=vmsd_start:vmsd_end;
        
        for j=1:length(year_used)
            if lat_here>=0;
                index_here=find(ismember(time,datenum(year_used(j),1,1):datenum(year_used(j),12,31)));
                
                period_pmax1=datenum(year_used(j),5,15):datenum(year_used(j),7,15);
                index_pmax1=find(ismember(time,period_pmax1));
                
                period_pmax2=datenum(year_used(j),8,15):datenum(year_used(j),10,15);
                index_pmax2=find(ismember(time,period_pmax2));
            
            else
                index_here=find(ismember(time,datenum(year_used(j),7,1):datenum(year_used(j)+1,6,30)));
                
                period_pmax1=datenum(year_used(j),11,15):datenum(year_used(j)+1,1,15);
                index_pmax1=find(ismember(time,period_pmax1));
                
                period_pmax2=datenum(year_used(j)+1,2,15):datenum(year_used(j)+1,4,15);
                index_pmax2=find(ismember(time,period_pmax2));
            end
            
            if ismember(length(index_here),[365 366]);
                
                precip_1=precip_here(index_pmax1);
                precip_2=precip_here(index_pmax2);
                
                [pmax1,loc1]=nanmax(precip_1);
                [pmax2,loc2]=nanmax(precip_2);
                
                ind1=index_pmax1(loc1);
                ind2=index_pmax2(loc2);
                
                mdl_start=fitlm(index_here(1):ind1,precip_here(index_here(1):ind1));
                mdl_end=fitlm(ind2:index_here(end),precip_here(ind2:index_here(end)));
                trend_start=mdl_start.Coefficients.Estimate(2);
                p_start=mdl_start.Coefficients.pValue(2);
                trend_end=mdl_end.Coefficients.Estimate(2);
                p_end=mdl_end.Coefficients.pValue(2);
                
                if ~(ind1==index_pmax1(end) || ind2==index_pmax2(1) ||  ...
                        (~ismember(nanmax(precip_here(index_here)),[pmax1,pmax2])) || trend_start<=0 || trend_end>=0 || p_start>0.05 || p_end>0.05)
                    pmax=nanmax([pmax1 pmax2]);
                    pmin=nanmean(precip_here(ind1:ind2));
                    [~,loc_tmin]=nanmin(precip_here(ind1:ind2));
                    ind_full=ind1:ind2;
                    
                    imsd=(pmax-pmin)./pmax;
                    imsd_here=[year_used(j) x(i) y(i) time(ind1) day(datetime(datevec(time(ind1))),'dayofyear') time(ind2) day(datetime(datevec(time(ind2))),'dayofyear') time(ind_full(loc_tmin)) day(datetime(datevec(time(ind_full(loc_tmin)))),'dayofyear') pmax pmin pmax1 pmax2 imsd];
                    MSD=[MSD;imsd_here];
                end
            end
        end
    end
end
MSD=table(MSD(:,1),MSD(:,2),MSD(:,3),MSD(:,4),MSD(:,5),MSD(:,6),MSD(:,7),...
    MSD(:,8),MSD(:,9),MSD(:,10),MSD(:,11),MSD(:,12),MSD(:,13),MSD(:,14),'variablenames',...
    {'YEAR','XLOC','YLOC','ONSET','ONSET_D','ENDING','ENDING_D','PEAK','PEAK_D',...
    'Pmax','Pmin','P1','P2','imsd'});