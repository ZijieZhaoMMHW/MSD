function expv=soh(precip,time,lat_full,varargin)
%soh - calculating explained variance of daily precipitation in rainy season 
%by second order harmonic (SOH)
%  Syntax
%
%  expv=soh(precip,time,lat_full) 
%
%  Description
%
%  expv=soh(precip,time,lat_full) returns proportion of explained variance
%  in each grid.
%
%  Input Arguments
%   precip - 3D daily precipitation (mm/day) in size of m-by-n-by-t.
%
%   time - A numeric vector (length t) corresponding to the time of precip.
%
%   lat_full - A numeric matrix (m-by-n) indicating latitude for PRECIP.
%   This is actually used to distinguish the situation in northern/southern
%   hemisphere so if you do not have exact latitude data please use
%   positive/negative value for northern/southern hemisphere.
%
%   'smoothwidth' - Default is 1. Width of window to smooth calculated
%   climatological precipitation
%
%  Output Arguments
%   exp - A numeric matrix (in size of m-by-n, ranging from 0 to 1)
%   containing proportion of explained variance of daily precipitation in
%   rainy season by a second order harmonic.
%
%  Reference
%   Curtis, Scott. "Interannual variability of the bimodal distribution of
%   summertime ainfall over Central America and tropical storm activity in
%   the far-eastern Pacific."?Climate Research22.2 (2002): 141-146.

paramNames = {'smoothwidth'};
defaults   = {1};

[vsmoothwidth]...
    = internal.stats.parseArgs(paramNames, defaults, varargin{:});

date_time=datevec(time);
unique_d=unique(date_time(:,2:3),'rows');
precip_clim=NaN(size(precip,1),size(precip,2),366);
for i=1:size(unique_d,1)
    index_here= date_time(:,2)==unique_d(i,1) & date_time(:,3)==unique_d(i,2);
    precip_clim(:,:,i)=nanmean(precip(:,:,index_here),3);
end
precip_clim=smoothdata(precip_clim,3,'gaussian',vsmoothwidth);
expv=NaN(size(precip,1),size(precip,2));
for i=1:size(precip_clim,1)
    for j=1:size(precip_clim,2)
        precip_here=squeeze(precip_clim(i,j,:));
        if nansum(isnan(precip_here))==0
            if lat_full(i,j)>=0
                precip_used=precip_here((datenum(2000,5,1):datenum(2000,10,31))-datenum(2000,1,1)+1);
            else
                precip_used=[precip_here((datenum(2000,11,1):datenum(2000,12,31))-datenum(2000,1,1)+1);...
                    precip_here((datenum(2000,1,1):datenum(2000,4,30))-datenum(2000,1,1)+1)];
            end
            equ=['a+b*sin((2*pi./' num2str(length(precip_used)./2) ').*x+c)'];
            mdl=fit((1:length(precip_used))',precip_used,equ);
            fitted=mdl((1:length(precip_used))');
            
            expv(i,j)=std(fitted)./std(precip_used);
        end
    end
end
            
                
            
    
    

