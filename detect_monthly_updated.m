function [depth,onset,ending]...
    =detect_monthly_updated(precip,time,lat_full,varargin)
%detect_monthly_updated - daily version for detect_monthly
%proposed by Karnauskas et al. (2013).
%  Syntax
%
%  [depth,onset,ending]=detect_monthly_updated(precip,time,lat_full)
%
%  Description
%
%  [depth,onset,ending]=detect_monthly_updated(precip,time,lat_full) returns
%  outputs containing information about climatological MSD events based on
%  daily climatological data. DEPTH, ONSET, ENDING are seperately
%  intensity, onset and ending day of year for climatological MSD event in
%  each grid of precip.
%
%  Input Arguments
%   precip - 3D monthly precipitation (mm/day) to detect MSD events,
%   specified as a m-by-n-by-t matrix. m and n separately indicate two
%   spatial dimensions and t indicates temporal dimension.
%
%   time - A numeric vector corresponding to the time of precip in the
%   format of datenum().
%
%   lat_full - A numeric matrix (m-by-n) indicating latitude for PRECIP.
%   This is actually used to distinguish the situation in northern/southern
%   hemisphere so if you do not have exact latitude data please use
%   positive/negative value for northern/southern hemisphere.
%
%  Output Arguments
%   depth - A numeric matrix (m-by-n) indicating the intensity for
%   climatological MSD in each grid.
%
%   onset - A numeric matrix (m-by-n) indicating the onset day of year for
%   climatological MSD in each grid.
%
%   ending - A numeric matrix (m-by-n) indicating the ending day of year for
%   climatological MSD in each grid.
%
%  Reference
%   Karnauskas, K.B., Seager, R., Giannini, A. and Busalacchi, A.J., 2013.
%   A simple mechanism for the climatological midsummer droughalong the
%   Pacific coast of Central America. Atmosfera, 26(2), pp.261-281.

paramNames = {'smoothwidth'};
defaults   = {31};

[vsmoothwidth]...
    = internal.stats.parseArgs(paramNames, defaults, varargin{:});

%% calculating climatology
time=datevec(time);
u_m_d=unique(time(:,2:3),'rows');

precip_clim=NaN(120,60,366);

for i=1:size(u_m_d,1)
    index_here = time(:,2)==u_m_d(i,1) & time(:,3)==u_m_d(i,2);
    precip_clim(:,:,i)=nanmean(precip(:,:,index_here),3);
end

precip_clim_sm=smoothdata(precip_clim,3,'gaussian',vsmoothwidth);

%% determining the MSD area
depth=NaN(size(precip,1),size(precip,2));
onset=NaN(size(precip,1),size(precip,2));
ending=NaN(size(precip,1),size(precip,2));

for i=1:size(precip_clim_sm,1)
    
    for j=1:size(precip_clim_sm,2)
        precip_here=squeeze(precip_clim_sm(i,j,:));
        lat_here=lat_full(i,j);
        period_here=(datenum(2016,1,1):datenum(2016,12,31))';
        if nansum(isnan(precip_here))~=length(precip_here)
            if lat_here<0
                period_here=[period_here((datenum(2016,7,1):datenum(2016,12,31))-datenum(2016,1,1)+1);...
                    period_here((datenum(2016,1,1):datenum(2016,6,30))-datenum(2016,1,1)+1)];
                precip_here=[precip_here((datenum(2016,7,1):datenum(2016,12,31))-datenum(2016,1,1)+1);...
                    precip_here((datenum(2016,1,1):datenum(2016,6,30))-datenum(2016,1,1)+1)];
            end
            
            [p,l]=findpeaks(precip_here);
            [p,n]=sort(p);
            l=l(n);
            
            if ~isempty(p) && ~isempty(l) && length(p)>=2
            
            p1=p(end);
            l1=l(end);
            p2=p(end-1);
            l2=l(end-1);
            
            l_start=nanmin([l1 l2]);
            l_end=nanmax([l1 l2]);
            
            if (abs(l1-l2)+1)>=30 && (abs(l1-l2)+1)<=120
                depth(i,j)=nanmean([p1 p2])-nanmean(precip_here(l_start:l_end));
                onset(i,j)=l_start;
                ending(i,j)=l_end;
            elseif (abs(l1-l2)+1)<=30 && length(p)>=3
                p3=p(end-2);
                l3=l(end-2);
                
                if (abs(l3-l1)+1)>=30 && (abs(l3-l1)+1)<=150 && (abs(l3-l2)+1)>=30 && (abs(l3-l2)+1)<=150
                    l_start=nanmin([l1 l2 l3]);
                    l_end=nanmax([l1 l2 l3]);
                    
                    depth(i,j)=nanmean([p1 p2 p3])-nanmean(precip_here(l_start:l_end));
                    onset(i,j)=l_start;
                    ending(i,j)=l_end;
                end
            end
            
            end
            
            
        end
    end
    
end