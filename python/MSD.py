import datetime
from datetime import date
import numpy as np
from scipy import signal
import scipy
from scipy.ndimage import gaussian_filter1d# could be deleted later
from numpy import ma
from symfit import parameters, variables, Fit
from scipy.optimize import curve_fit
import scipy.io
from scipy.signal import find_peaks
from scipy import stats
import pandas as pd
from scipy.interpolate import interp1d
import math
from scipy.ndimage import correlate1d

def soh(precip,time,lat_full,smoothwidth=None):
    '''
    second order harmonic
    '''
    date_time=np.full([len(time),2],np.nan)
    for i,t in enumerate(time):
        date_time[i,0]=date.fromordinal(t).month
        date_time[i,1]=date.fromordinal(t).day
    unique_d=np.unique(date_time,axis=0)
    precip_clim=np.full([precip.shape[0],precip.shape[1],366],np.nan)
    for i,t in enumerate(unique_d):
        index_here= np.logical_and(date_time[:,0]==t[0],date_time[:,1]==t[1])
        precip_clim[:,:,i]=np.nanmean(precip[:,:,index_here],axis=2)
    if smoothwidth is None or smoothwidth==1:
        precip_clim=precip_clim
    else:
        sig=smoothwidth/5
        smoothwidth = float(smoothwidth);
        smoothwidth = min(math.floor(smoothwidth), 2*precip.shape[2]);
        h = np.exp(-(np.arange(1,smoothwidth+1) - math.ceil(smoothwidth/2))**2/(2*sig**2));
        h=h/sum(h)
        if len(h)%2 == 0:
            h=np.concatenate(([0],h),axis=0)
        yr1=correlate1d(precip_clim, h, mode='constant', cval=0.0,axis=2)
        nanInd = np.full([precip_clim.shape[0],precip_clim.shape[1],precip_clim.shape[2]],0)
        halfwinsz = math.ceil(smoothwidth / 2)
        fill=np.full([precip_clim.shape[0],precip_clim.shape[1],halfwinsz],1)
        nanInd1=np.concatenate((fill,nanInd,fill),axis=2)
        ync =1-correlate1d(nanInd1.astype(float), h,mode='constant', cval=0.0,axis=2)
        ync=ync[:,:,np.arange(halfwinsz,halfwinsz+precip_clim.shape[2])]
        precip_clim = yr1/ync
        #sigma=(smoothwidth-2)/8
        #precip_clim=gaussian_filter1d(precip_clim,sigma,axis=2)
    expv=np.full([precip.shape[0],precip.shape[1]],np.nan)
    for i in range(0,precip_clim.shape[0]):
        for j in range(0,precip_clim.shape[1]):
            precip_here=np.squeeze(precip_clim[i,j,:])#time series at some location
            if np.isnan(precip_here).all()== False:
                if lat_full[i,j] >=0 :
                    indx=(np.array(list(range(date.toordinal(date(2000,5,1)),date.toordinal(date(2000,10,31))+1)))\
                    -date.toordinal(date(2000,1,1))).astype(int)
                elif lat_full[i,j]<0:
                    indx1=(np.array(list(range(date.toordinal(date(2000,11,1)),date.toordinal(date(2000,12,31))+1)))\
                       -date.toordinal(date(2000,1,1))).astype(int)
                    indx2=(np.array(list(range(date.toordinal(date(2000,1,1)),date.toordinal(date(2000,4,30))+1)))\
                       -date.toordinal(date(2000,1,1))).astype(int)
                    indx=np.concatenate((indx1,indx2),axis=0)
                precip_used=precip_here[indx]
                popt, pcov = curve_fit(lambda x,a,b,c: func(x,a,b,c,len(precip_used)),
                                   np.array(range(1,len(precip_used)+1)), precip_used)
                fitted=func(np.array(range(1,len(precip_used)+1)), *popt,len(precip_used))
                expv[i,j]=np.std(fitted,ddof=1)/np.std(precip_used,ddof=1)
    return expv

def func(x, a, b, c,l):
        return a+b*np.sin((2*np.pi/(l/2))*x+c)


def detect_monthly(precip,time,lat_full):
    precip_clim=np.full([precip.shape[0],precip.shape[1],12],np.nan)
    for m in range(0,12):
        index_here= time[:,1]==m+1
        precip_clim[:,:,m]=np.nanmean(precip[:,:,index_here],axis=2)
    depth=np.full([precip.shape[0],precip.shape[1]],np.nan)
    onset=np.full([precip.shape[0],precip.shape[1]],np.nan)
    ending=np.full([precip.shape[0],precip.shape[1]],np.nan)
    for i in range(0,precip_clim.shape[0]):
        for j in range(0,precip_clim.shape[1]):
            period_here=np.arange(0,12)
            precip_here=np.squeeze(precip_clim[i,j,:])
            lat_here=lat_full[i,j]
            if np.isnan(precip_here).all()==False:
                if lat_here < 0:
                    period_here=np.concatenate([np.arange(7,12),np.arange(1,6)])#row vector
                    precip_here=np.concatenate([precip_here[6:11],precip_here[0:5]])
                l,_= find_peaks(precip_here)
                p=precip_here[l]
                n=np.argsort(p)
                p=np.sort(p)
                l=l[n]
                if len(p)!=0 and len(l)!=0 and len(p)>=2:
                    p1=p[-1]
                    l1=l[-1]
                    p2=p[-2]
                    l2=l[-2]

                    l_start=min(l1,l2)
                    l_end=max(l1,l2)
                    if abs(l1-l2)>=2 and abs(l1-l2)<=4:
                        depth[i,j]=np.nanmean([p1,p2])-np.nanmin(precip_here[l_start:l_end])
                        onset[i,j]=period_here[l_start]
                        ending[i,j]=period_here[l_end]
                    elif abs(l1-l2)<2 and len(p)>=3:
                        l3=l[-3]
                        if abs(l3-l1)>=2 and abs(l3-l1)<=5 and abs(l3-l2)>=2 and abs(l3-l2)<=5:
                            l_start=np.nanmin([l1,l2,l3])
                            l_end=np.nanmax([l1,l2,l3])

                            depth[i,j]=np.nanmean([precip_here[l_start],precip_here[l_end]])\
                                       -np.nanmin(precip_here[l_start:l_end])
                            onset[i,j]=period_here[l_start]
                            ending[i,j]=period_here[l_end]
                        else:
                            depth[i,j]=np.nan
                            onset[i,j]=np.nan
                            ending[i,j]=np.nan
                    else:
                        depth[i,j]=np.nan
                        onset[i,j]=np.nan
                        ending[i,j]=np.nan
                else:
                    depth[i,j]=np.nan
                    onset[i,j]=np.nan
                    ending[i,j]=np.nan
            else:
                depth[i,j]=np.nan
                onset[i,j]=np.nan
                ending[i,j]=np.nan
    return depth,onset,ending

def detect_mg(precip,time,lat_full):
    precip_clim=np.full([precip.shape[0],precip.shape[1],12],np.nan)
    dur=np.full([precip_clim.shape[0],precip_clim.shape[1]],np.nan)
    RD=np.full([precip_clim.shape[0],precip_clim.shape[1]],np.nan)
    label=np.full([precip_clim.shape[0],precip_clim.shape[1]],np.nan)
    for m in range(0,12):
        index_here= time[:,1]==m+1
        precip_clim[:,:,m]=np.nanmean(precip[:,:,index_here],axis=2)
    for i in range(0,precip_clim.shape[0]):
        for j in range(0,precip_clim.shape[1]):
            precip_here=np.squeeze(precip_clim[i,j,:])
            lat_here=np.squeeze(lat_full[i,j])
            period_here=np.arange(1,13)
            num_day=np.array([31,29,31,30,31,30,31,31,30,31,30,31])
            if np.isnan(precip_here).all() == False:
                if lat_here > 0:
                    period_here=np.arange(5,11)
                else:
                    period_here=np.concatenate((np.arange(11,13),np.arange(1,5)),axis=0)
                precip_here=precip_here[period_here-1]
                l,_= find_peaks(precip_here)
                p=precip_here[l]
                if len(p)==0 or len(p)==1:
                    n=np.argsort(precip_here)
                    if {n[-1]}.issubset(np.array([0,len(precip_here)-1])) and {n[-2]}.issubset(np.array([0,len(precip_here)-1])):
                        dur[i,j]=len(precip_here)-2
                        range_msd=np.arange(1,len(precip_here)-1)
                        RD[i,j]=np.nansum(precip_here[range_msd]\
                                          *num_day[period_here[range_msd]-1])/np.nansum(precip_here*num_day[period_here-1])
                    elif len(p)==1 and np.nansum(np.unique([l[0],0])==np.unique([n[-1],n[-2]]))==2 and l[0]!=1:
                        dur[i,j]=len(range(0,l[0]))-1
                        range_msd=np.arange(1,l[0])
                        RD[i,j]=np.nansum(precip_here[range_msd]\
                                          *num_day[period_here[range_msd]-1])/np.nansum(precip_here*num_day[period_here-1])
                    elif len(p)==1 and np.nansum(np.unique([l[0],len(precip_here)-1])==np.unique([n[-1],n[-2]]))==2 and l[0]!=1:
                        dur[i,j]=len(range(l[0],len(precip_here)))-2
                        range_msd=np.arange(l[0],len(precip_here)-1)
                        RD[i,j]=np.nansum(precip_here[range_msd]\
                                          *num_day[period_here[range_msd]-1])/np.nansum(precip_here*num_day[period_here-1])
                    else:
                        dur[i,j]=np.nan
                        RD[i,j]=np.nan
                else:
                    n=np.argsort(p)
                    l=l[n]
                    l_start=np.nanmin([l[-1],l[-2]])
                    l_end=np.nanmax([l[-1],l[-2]])
                    if abs(l_end-l_start)>1:
                        dur[i,j]=len(range(l_start,l_end))-1
                        range_msd=np.arange(l_start+1,l_end)
                        RD[i,j]=np.nansum(precip_here[range_msd]\
                                          *num_day[period_here[range_msd]-1])/np.nansum(precip_here*num_day[period_here-1])
                    else:
                        dur[i,j]=np.nan
                        RD[i,j]=np.nan
            else:
                dur[i,j]=np.nan
                RD[i,j]=np.nan
        if RD[i,j]<0.1:
            labe[i,j]='weak'
        elif RD[i,j]<0.16:
            label[i,j]='moderate'
        elif RD[i,j]<=0.1:
            label[i,j]='strong'
        else:
            label_here=np.array([])




    return dur,RD,label


def detect_quadrant(precip,time,lat_full,clim_start=None,clim_end=None,msd_start=None,msd_end=None):
    if clim_start is None:
        clim_start=time[0,:]
    if clim_end is None:
        clim_end=time[-1,:]
    if msd_start is None:
        msd_start=np.nanmin(time[:,0])
    if msd_end is None:
        msd_end=np.nanmax(time[:,0])
    tstart=np.where((time[:,0]==clim_start[0])&(time[:,1]==clim_start[1]))[0][0]
    tend=np.where((time[:,0]==clim_end[0])&(time[:,1]==clim_end[1]))[0][0]
    precip_cclim=precip[:,:,range(tstart,tend)]
    time_cclim=time[range(tstart,tend+1),:]
    precip_clim=np.full([precip.shape[0],precip.shape[1],12],np.nan)
    BI=np.full([precip.shape[0],precip.shape[1],len(np.arange(msd_start,msd_end+1))],np.nan)
    for m in range(0,12):
        index_here=time_cclim[:,1]==m+1
        precip_clim[:,:,m]=np.nanmean(precip[:,:,index_here],axis=2)
    for i in range(0,precip.shape[0]):
        for j in range(0,precip.shape[1]):
            precip_here=np.squeeze(precip[i,j,:])
            precip_clim_here=np.squeeze(precip_clim[i,j,:])
            lat_here=lat_full[i,j]
            if np.isnan(precip_here).all()==False:
                for y in range(msd_start,msd_end+1):
                    precip_year=precip_here[time[:,0]==y]
                    if len(precip_year)==12:
                        if lat_here>0:
                            precip_o=precip_year[6]
                            precip_b=precip_year[5]
                            precip_a=precip_year[7]
                            precip_clim_b=precip_clim_here[5]
                            precip_clim_a=precip_clim_here[7]
                        else:
                            precip_o=precip_year[0]
                            precip_b=precip_year[11]
                            precip_a=precip_year[1]
                            precip_clim_b=precip_clim_here[11]
                            precip_clim_a=precip_clim_here[1]
                        if precip_b>precip_o and precip_a>precip_o:
                            BF=1
                        elif precip_b==precip_o and precip_a==precip_o:
                            BF=0
                        else:
                            BF=-1
                        BI[i,j,y-msd_start]=BF*((precip_a+precip_b)/(precip_clim_a+precip_clim_b))
    return BI

def interpnan(data,time):
    data_new=np.full((data.shape[0],data.shape[1],data.shape[2]),np.nan)
    x=time
    #time=np.tile(time,[data.shape[0],data.shape[1],1])
    for i in range(0,data.shape[0]):
        for j in range(0,data.shape[1]):
            y=np.squeeze(data[i,j,:])
            y_new=np.full((len(y),),np.nan)
            if np.isnan(y).all()==True or len(np.unique(y[~np.isnan(y)]))==1:
                y_new=y_new# not sure
            else:
                y_new[np.isnan(y)]=interp1d(x[~np.isnan(y)],y[~np.isnan(y)],fill_value='extrapolate')(x[np.isnan(y)])
                y_new[~np.isnan(y)]=y[~np.isnan(y)]
            data_new[i,j,:]=y_new
    return data_new


def detect_daily(precip,time,lat_full,smoothwidth=None,clim_start=None,clim_end=None,msd_start=None,msd_end=None):
    date_used=np.full([len(time),3],np.nan)
    for i,t in enumerate(time):
        date_used[i,0]=date.fromordinal(t).year
        date_used[i,1]=date.fromordinal(t).month
        date_used[i,2]=date.fromordinal(t).day

    if smoothwidth is None:
        smoothwidth=31
    if clim_start is None:
        clim_start=time[0]
    if clim_end is None:
        clim_end=time[-1]
    if msd_start is None:
        msd_start=date_used[0,0]
    if msd_end is None:
        msd_end=date_used[-1,0]

    sig=smoothwidth/5
    smoothwidth = float(smoothwidth);
    smoothwidth = min(math.floor(smoothwidth), 2*precip.shape[2]);
    h = np.exp(-(np.arange(1,smoothwidth+1) - math.ceil(smoothwidth/2))**2/(2*sig**2));
    h=h/sum(h)
    if len(h)%2 == 0:
        h=np.concatenate(([0],h),axis=0)
    #sigma=smoothwidth/5
    #truncate=np.nanmean([2.5*(smoothwidth-2)/smoothwidth,2.5])
    precip_for_clim=precip[:,:,np.arange(clim_start,clim_end+1)-time[0]]
    u_m_d=np.unique(date_used[:,1:],axis=0)
    precip_clim=np.full([precip.shape[0],precip.shape[1],366],np.nan)
    print('Calculating the climatology')
    for i in range(0,u_m_d.shape[0]):
        index_here=np.logical_and(date_used[:,1]==u_m_d[i,0],date_used[:,2]==u_m_d[i,1])
        precip_clim[:,:,i]=np.nanmean(precip_for_clim[:,:,index_here],axis=2)
    #precip_clim_sm=precip_clim# Gaussian later
    #precip_clim_sm=gaussian_filter1d(precip_clim,sigma,truncate=truncate,axis=2)
    yr1=correlate1d(precip_clim, h, mode='constant', cval=0.0,axis=2)
    nanInd = np.full([precip_clim.shape[0],precip_clim.shape[1],precip_clim.shape[2]],0)
    halfwinsz = math.ceil(smoothwidth / 2)
    fill=np.full([precip_clim.shape[0],precip_clim.shape[1],halfwinsz],1)
    nanInd1=np.concatenate((fill,nanInd,fill),axis=2)
    ync =1-correlate1d(nanInd1.astype(float), h,mode='constant', cval=0.0,axis=2)
    ync=ync[:,:,np.arange(halfwinsz,halfwinsz+precip_clim.shape[2])]
    precip_clim_sm = yr1/ync

    ####determining the MSD area#############
    binary_msd=np.full([precip.shape[0],precip.shape[1]],np.nan)
    imsd_climatology=np.full([precip.shape[0],precip.shape[1]],np.nan)
    for i in range(0,precip_clim_sm.shape[0]):
        for j in range(0,precip_clim_sm.shape[1]):
            print('Determining the MSD area, current location: x'+str(i+1),'y'+str(j+1))
            precip_here=np.squeeze(precip_clim_sm[i,j,:])
            lat_here=lat_full[i,j]
            period_here=np.arange(date.toordinal(date(2016,1,1)),date.toordinal(date(2016,12,31))+1)
            if np.isnan(precip_here).all()==False:
                if lat_here<0:
                    indx1=(np.arange(date.toordinal(date(2016,7,1)),date.toordinal(date(2016,12,31))+1)\
                          -date.toordinal(date(2016,1,1))).astype(int)
                    indx2=(np.arange(date.toordinal(date(2016,1,1)),date.toordinal(date(2016,6,30))+1)\
                          -date.toordinal(date(2016,1,1))).astype(int)
                    indx=np.concatenate((indx1,indx2),axis=0)
                    period_here=period_here[indx]
                    precip_here=precip_here[indx]
                    period_1=np.concatenate(((np.arange(date.toordinal(date(2016,11,15)),date.toordinal(date(2016,12,31))+1)
                                             ,(np.arange(date.toordinal(date(2016,1,1)),date.toordinal(date(2016,1,15))+1))))
                                             ,axis=0)
                    period_1_index=np.where(np.isin(period_here,period_1))[0]
                    period_2=np.arange(date.toordinal(date(2016,2,15)),date.toordinal(date(2016,4,15))+1)
                    period_2_index=np.where(np.isin(period_here,period_2))[0]
                else:
                    period_1=np.arange(date.toordinal(date(2016,5,15)),date.toordinal(date(2016,7,15))+1)
                    period_1_index=np.where(np.isin(period_here,period_1))[0]
                    period_2=np.arange(date.toordinal(date(2016,8,15)),date.toordinal(date(2016,10,15))+1)
                    period_2_index=np.where(np.isin(period_here,period_2))[0]

                rain_p1=precip_here[period_1_index]
                if np.isnan(rain_p1).all()==False:# remove 'if' after intepolation
                    p1=np.nanmax(rain_p1)
                    loc1=np.where(rain_p1==p1)[0][0]
                    ind1=period_1_index[loc1]
                else:
                    loc1=0
                    ind1=period_1_index[loc1]
                rain_p2=precip_here[period_2_index]
                if np.isnan(rain_p2).all()==False:# remove 'if' after intepolation
                    p2=np.nanmax(rain_p2)
                    loc2=np.where(rain_p2==p2)[0][0]
                    ind2=period_2_index[loc2]
                else:
                    loc2=0
                    ind2=period_2_index[loc2]
                mdl_start=stats.linregress(np.arange(1,ind1+2),precip_here[range(0,ind1+1)])
                mdl_end=stats.linregress(np.arange(ind2+1,367),precip_here[ind2:])
                trend_start=mdl_start.slope
                p_start=mdl_start.pvalue
                trend_end=mdl_end.slope
                p_end=mdl_end.pvalue
                if ind1==period_1_index[-1] or ind2==period_2_index[0] \
                   or (not np.isin(np.nanmax(precip_here),np.array([p1,p2])))\
                    or trend_start<=0 or trend_end>=0 or p_start >0.05 or p_end>0.05 :
                        binary_msd[i,j]=0
                else:
                    pmax=np.nanmax([p1,p2])
                    pmin=np.nanmean(precip_here[range(ind1,ind2+1)])
                    imsd=(pmax-pmin)/pmax
                    binary_msd[i,j]=1
                    imsd_climatology[i,j]=imsd
#####Determining the MSD event########
    x,y=np.where(binary_msd==1)
    MSD=np.empty((1,14))
    #precip_smooth=precip# Gaussian later
    #precip_smooth=gaussian_filter1d(precip,sigma,truncate=truncate,axis=2)

    yr2=correlate1d(precip, h, mode='constant', cval=0.0,axis=2)
    nanInd2 = np.full([precip.shape[0],precip.shape[1],precip.shape[2]],0)
    fill2=np.full([precip.shape[0],precip.shape[1],halfwinsz],1)
    nanInd22=np.concatenate((fill2,nanInd2,fill2),axis=2)
    ync2 =1-correlate1d(nanInd22.astype(float), h,mode='constant', cval=0.0,axis=2)
    ync2=ync2[:,:,np.arange(halfwinsz,halfwinsz+precip.shape[2])]
    precip_smooth = yr2/ync2
    for i in range(0,len(x)):
        print('Detecting MSD events,current location x',str(x[i]),'y',str(y[i]),str(i),'in',str(len(x)))
        precip_here=np.squeeze(precip_smooth[x[i],y[i],:])
        lat_here=lat_full[x[i],y[i]]
        if np.isnan(precip_here).all()==False:
            year_used=np.arange(msd_start,msd_end+1,dtype=int)
            for j in range(0,len(year_used)):
                if lat_here>=0:
                    index_here=np.where(np.isin(time,np.arange(date.toordinal(date(year_used[j],1,1))
                                                               ,date.toordinal(date(year_used[j],12,31))+1)))[0]
                    period_pmax1=np.arange(date.toordinal(date(year_used[j],5,15))
                                           ,date.toordinal(date(year_used[j],7,15))+1)
                    index_pmax1=np.where(np.isin(time,period_pmax1))[0]

                    period_pmax2=np.arange(date.toordinal(date(year_used[j],8,15))
                                           ,date.toordinal(date(year_used[j],10,15))+1)
                    index_pmax2=np.where(np.isin(time,period_pmax2))[0]
                else:
                    index_here=np.where(np.isin(time,np.arange(date.toordinal(date(year_used[j],7,1))
                                                               ,date.toordinal(date(year_used[j]+1,6,30))+1)))[0]
                    period_pmax1=np.arange(date.toordinal(date(year_used[j],11,15))
                                           ,date.toordinal(date(year_used[j]+1,1,15))+1)
                    index_pmax1=np.where(np.isin(time,period_pmax1))[0]

                    period_pmax2=np.arange(date.toordinal(date(year_used[j]+1,2,15))
                                           ,date.toordinal(date(year_used[j]+1,4,15))+1)
                    index_pmax2=np.where(np.isin(time,period_pmax2))[0]
                if np.isin(len(index_here),[365,366]):
                    precip_1=precip_here[index_pmax1]
                    precip_2=precip_here[index_pmax2]

                    pmax1=np.nanmax(precip_1)
                    loc1=np.where(precip_1==pmax1)[0]
                    pmax2=np.nanmax(precip_2)
                    loc2=np.where(precip_2==pmax2)[0]

                    ind1=index_pmax1[loc1][0]
                    ind2=index_pmax2[loc2][0]

                    xs=np.arange(index_here[0],ind1+1);
                    ys=precip_here[index_here[0]:ind1+1]
                    xs=xs[~np.isnan(ys)]
                    ys=ys[~np.isnan(ys)]

                    xe=np.arange(ind2,index_here[-1]+1)
                    ye=precip_here[ind2:index_here[-1]+1]
                    xe=xe[~np.isnan(ye)]
                    ye=ye[~np.isnan(ye)]
                    mdl_start=stats.linregress(xs,ys)
                    mdl_end=stats.linregress(xe,ye)
                    trend_start=mdl_start.slope
                    p_start=mdl_start.pvalue
                    trend_end=mdl_end.slope
                    p_end=mdl_end.pvalue


                    if (not (ind1==index_pmax1[-1] or ind2==index_pmax2[0] \
                             or (not np.isin(np.nanmax(precip_here[index_here]),[pmax1,pmax2]))
                            or trend_start<=0 or trend_end >=0 or p_start>0.05 or p_end>0.05)):
                        pmax=np.nanmax([pmax1,pmax2])
                        pmin=np.nanmean(precip_here[ind1:ind2+1])
                        loc_tmin=np.where(precip_here[ind1:ind2+1]==np.nanmin(precip_here[ind1:ind2+1]))[0][0]
                        ind_full=range(ind1,ind2+1)
                        imsd=(pmax-pmin)/pmax
                        imsd_here=np.array([year_used[j],x[i],y[i],(time+366)[ind1],
                            int(date.fromordinal(time[ind1]).strftime('%j')),(time+366)[ind2],
                            int(date.fromordinal(time[ind2]).strftime('%j')),
                            (time+366)[ind_full[loc_tmin]],int(date.fromordinal(time[ind_full[loc_tmin]]).strftime('%j')),
                            pmax,pmin,pmax1,pmax2,imsd ])
                        imsd_here=imsd_here[np.newaxis,:]
                        MSD=np.row_stack((MSD,imsd_here))
    MSD=pd.DataFrame(data=MSD,columns=['YEAR','XLOC','YLOC','ONSET','ONSET_D','ENDING','ENDING_D','PEAK','PEAK_D',
    'Pmax','Pmin','P1','P2','imsd'])
    MSD=MSD.drop([0])
    return MSD,precip_clim,imsd_climatology
