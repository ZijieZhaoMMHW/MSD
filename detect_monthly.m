function [depth,onset,ending]=detect_monthly(precip,time,lat_full)
%detect_monthly - Detecting climatological MSD events using algorithm
%proposed by Karnauskas et al. (2013).
%  Syntax
%
%  [depth,onset,ending]=detect_monthly(precip,time,lat_full)
%
%  Description
%
%  [depth,onset,ending]=detect_monthly(precip,time,lat_full) returns
%  outputs containing information about climatological MSD events based on
%  monthly climatological data. DEPTH, ONSET, ENDING are seperately
%  intensity, onset month, ending month for climatological MSD event in
%  each grid of precip.
%
%  Input Arguments
%   precip - 3D monthly precipitation (mm/day) to detect MSD events,
%   specified as a m-by-n-by-t matrix. m and n separately indicate two
%   spatial dimensions and t indicates temporal dimension.
%
%   time - A numeric matrix in size of t-by-2. The first column indicates
%   the corresponding year while the second column indicates the
%   corresponding month (1 to 12).
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
%   onset - A numeric matrix (m-by-n) indicating the onset month for
%   climatological MSD in each grid.
%
%   ending - A numeric matrix (m-by-n) indicating the ending month for
%   climatological MSD in each grid.
%
%  Reference
%   Karnauskas, K.B., Seager, R., Giannini, A. and Busalacchi, A.J., 2013.
%   A simple mechanism for the climatological midsummer droughalong the
%   Pacific coast of Central America. Atmosfera, 26(2), pp.261-281.
precip_clim=NaN(size(precip,1),size(precip,2),12);
for i=1:12
    precip_clim(:,:,i)=nanmean(precip(:,:,time(:,2)==i),3);
end
precip_cell=num2cell(precip_clim,3);
lat_cell=num2cell(lat_full,3);

[depth,onset,ending]=cellfun(@detect_one,precip_cell,lat_cell);


function [depth_here,onset_here,ending_here]=detect_one(precip_here,lat_here)
precip_here=squeeze(precip_here);
period_here=(1:12)';
if nansum(isnan(precip_here))~=length(precip_here)
    if lat_here<0
        period_here=([7:12 1:6])';
        precip_here=precip_here([7:12 1:6]);
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
        
        if (abs(l1-l2))>=2 && (abs(l1-l2))<=4
            depth_here=nanmean([p1 p2])-nanmin(precip_here(l_start:l_end));
            onset_here=period_here(l_start);
            ending_here=period_here(l_end);
        elseif (abs(l1-l2))<2 && length(p)>=3
            l3=l(end-2);
            
            if (abs(l3-l1))>=2 && (abs(l3-l1))<=5 && (abs(l3-l2))>=2 && (abs(l3-l2))<=5
                l_start=nanmin([l1 l2 l3]);
                l_end=nanmax([l1 l2 l3]);
                
                depth_here=nanmean([precip_here(l_start) precip_here(l_end)])-nanmin(precip_here(l_start:l_end));
                onset_here=period_here(l_start);
                ending_here=period_here(l_end);
            else
                depth_here=nan;
                onset_here=nan;
                ending_here=nan;
            end
        else
            depth_here=nan;
            onset_here=nan;
            ending_here=nan;
        end
    else
        depth_here=nan;
        onset_here=nan;
        ending_here=nan;
    end
else
    depth_here=nan;
    onset_here=nan;
    ending_here=nan;
    
end
