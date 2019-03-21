function [dur,RD,label]=detect_mg(precip,time,lat_full)
%detect_mg - Detecting climatological MSD using climatological monthly
%precipitation using algorithm from Mosi?o and Garc¡§?a.
%
%  Syntax
%
%  [dur,RD,label]=detect_mg(precip,time,lat_full)
%
%  Description
%
%  [dur,RD,label]=detect_mg(precip,time,lat_full) returns outputs
%  associated with climatological MSD. dur is a numeric matrix in size of
%  m-by-n, indicating number of months during climatological MSD in each
%  grid. RD is a numeric matrix in size of m-by-n, indicating the quotient
%  between the representative area of the deficit and the total accumulated
%  precipitation from May to October. label is a cell in size of m-by-n,
%  indicating the label of climatological MSD in each gird.
%
%  Input Arguments
%   precip - 3D monthly precipitation (mm/day) to calculate climatology,
%   specified as a m-by-n-by-t matrix. m and n separately indicate two
%   spatial dimensions and t indicates temporal dimension.
%
%   time - A 2D numeric matrix in size of t-by-2, where the first column
%   indicates corresponding years and the second column indicates
%   corresponding months.
%
%   lat_full - A numeric matrix (m-by-n) indicating latitude for PRECIP.
%   This is actually used to distinguish the situation in northern/southern
%   hemisphere so if you do not have exact latitude data please use
%   positive/negative value for northern/southern hemisphere.
%
%  Output Arguments
%   dur - A numeric matrix (m-by-n) containing the number of months during
%   climatological MSD in each grid.
%
%   RD - A numeric matrix (m-by-n) containing the quotient
%   between the representative area of the deficit and the total accumulated
%   precipitation from May to October.
%
%   label - A 2D cell (m-by-n) containing the label of MSD in each grid.
%   'weak' for RD(i,j)<0.1, 'moderate' for 0.1<=RD(i,j)<0.16, 'strong' for
%   RD(i,j)>=0.16.

precip_clim=NaN(size(precip,1),size(precip,2),12);
for i=1:12
    index_here=time(:,2)==i;
    precip_clim(:,:,i)=nanmean(precip(:,:,index_here),3);
end
precip_cell=num2cell(precip_clim,3);
lat_cell=num2cell(lat_full,3);
[dur,RD,label]=cellfun(@detect_here,precip_cell,lat_cell,'UniformOutput',false);
dur=cell2mat(dur);
RD=cell2mat(RD);
function [dur_here,RD_here,label_here]=detect_here(precip_here,lat_here)
precip_here=squeeze(precip_here);
num_day=[31;29;31;30;31;30;31;31;30;31;30;31]; 
if nansum(isnan(precip_here))~=length(precip_here)
    if lat_here>0
        period_here=(5:10)';
    else
        period_here=[(11:12)';(1:4)'];
        
    end
    precip_here=precip_here(period_here);
    [p,l]=findpeaks(precip_here);
    
    if isempty(p) || length(p)==1
        [~,n]=sort(precip_here);
        if ismember(n(end),[1 length(precip_here)]) && ismember(n(end-1),[1 length(precip_here)])
            dur_here=length(precip_here)-2;
            range_msd=(2:(length(precip_here)-1))';
            RD_here = nansum(precip_here(range_msd).*num_day(period_here(range_msd)))./...
                nansum(precip_here.*num_day(period_here));
            
        elseif length(p)==1 && nansum(unique([l 1])==unique([n(end) n(end-1)]))==2 && ...
                l~=2
            dur_here=length(1:l)-2;
            range_msd=(2:(l-1))';
            RD_here=nansum(precip_here(range_msd).*num_day(period_here(range_msd)))./...
                nansum(precip_here.*num_day(period_here));
        elseif length(p)==1 && nansum(unique([l length(precip_here)])==unique([n(end) n(end-1)]))==2 && ...
                l~=2
            dur_here=length(l:length(precip_here))-2;
            range_msd=(l+1):(length(precip_here)-1);
            RD_here=nansum(precip_here(range_msd).*num_day(period_here(range_msd)))./...
                nansum(precip_here.*num_day(period_here));
            
        else
            dur_here=nan;
            RD_here=nan;
            
        end
        
    else
        [~,n]=sort(p);
        l=l(n);
        l_start=nanmin(l(end-1:end));
        l_end=nanmax(l(end-1:end));
        if abs(l_start-l_end)>1
            dur_here=length(l_start:l_end)-2;
            range_msd=((l_start+1):(l_end-1))';
            RD_here = nansum(precip_here(range_msd).*num_day(period_here(range_msd)))./...
                nansum(precip_here.*num_day(period_here));
        else
            dur_here=nan;
            RD_here=nan;
            
        end
    end
else
    dur_here=nan;
    RD_here=nan;
end


if RD_here<0.1
    label_here='weak';
elseif RD_here<0.16
    label_here='moderate';
elseif RD_here<=0.1
    label_here='strong';
else
    label_here=[];
end