function data_new=interpnan(data,time)
data_cell=num2cell(data,3);
data_new=cell2mat(cellfun(@interp1d,repmat({time},size(data,1),size(data,2)),data_cell,'UniformOutput',false));
end


function y_new=interp1d(x,y)
y=squeeze(y);
y_new=NaN(length(y),1);
if nansum(isnan(y))==length(y) || length(unique(y))==1
    
else
    y_new(isnan(y))=interp1(x(~isnan(y)),y(~isnan(y)),x(isnan(y)));
    y_new(~isnan(y))=y(~isnan(y));
end
y_new=reshape(y_new,1,1,length(y_new));
end