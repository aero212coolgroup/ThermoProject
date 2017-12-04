% Values for table: T h u s pf vf
% Velocity in (m/s)
vin = 76.38888;
% Air Mass Flow Rate (kg/s)
mdot = 51.6083;
% Fuel + Air Mass Flow Rate (kg/hr)
FAmdot = 3338.4583;

%% Assumptions
% Air Density (kg/m^3)
ro = 0.6756;
% Initial Temperature (K)
T0 = 255.65;
% Initial Pressure (kPa)
P0 = 49.586;
% Compressor Pressure Ratio Per Stage
cpr = 40/14;
% Compressor Efficiency
ce = 0.97;
%  Ideal pressure after first compressor
P2s = cpr * P0;
% Initial Reduced Pressure
pr1 = .7937;
% Critical Temp of air(K)
Tc = 132.65;
% Critical Pressure of Air(Pa)
Pc = 3774356;
% R constant(kJ/(kmol*K))
R = 8.314;
% Molar Mass of Air(kg/kmol)
M = 28.97;

%initializing table
%table collects data about states after the listed change
%ex: c1 = state after first compression
z=zeros(21);
statevariables = table(z(:,1),z(:,1),z(:,1),z(:,1),'VariableNames',{'p','v','T','s'},'RowNames',{'cinitial','c1','c2','c3','c4','c5','c6','c7','c8','c9','c10','c11','c12','c13','c14','combust','t1','t2','t3','t4','n'});%,'RowNames',{'cinitial','c1','c2','c3','c4','c5','c6','c7','c8','c9','c10','c11','c12','c13','c14','combust','t1','t2','t3','t4','n'};
%put known values into table
statevariables.T(1) = T0;
statevariables.p(1) = P0;
statevariables.v(1) = R*T0/(P0*M);

%interpolate for s initial
%Find Higher Properties for Interpolation
rows = find(IdealPropertiesofAir.T>T0,1);
THigh = IdealPropertiesofAir.T(rows);
sHigh = IdealPropertiesofAir.s(rows);

%Find Lower Properties for Interpolation
rows = find(IdealPropertiesofAir.T<T0,1,'last');
TLow = IdealPropertiesofAir.T(rows);
sLow = IdealPropertiesofAir.s(rows);

% Solve for unknown s1 (Initial Entropy)
syms s1
s1 = vpasolve((T0-TLow)/(s1-sLow) == (THigh-TLow)/(sHigh-sLow),s1);
statevariables.s(1) = s1;
%%  Initial Values



%Find Higher Properties for Interpolation
rows = find(IdealPropertiesofAir.T>T0,1);
THigh = IdealPropertiesofAir.T(rows);
hHigh = IdealPropertiesofAir.h(rows);

%Find Lower Properties for Interpolation
rows = find(IdealPropertiesofAir.T<T0,1,'last');
TLow = IdealPropertiesofAir.T(rows);
hLow = IdealPropertiesofAir.h(rows);

% Solve for unknown h1 (Initial Enthalpy)
syms h1
h1 = vpasolve((T0-TLow)/(h1-hLow) == (THigh-TLow)/(hHigh-hLow),h1);

for i = 1:1:14% loop to make this repeat 14 times
%P2s = cpr * P0;

pr2s = cpr*pr1;

%%
%Find Higher Properties for Interpolation
rows = find(IdealPropertiesofAir.pf>pr2s,1);
prHigh = IdealPropertiesofAir.pf(rows);
hHigh = IdealPropertiesofAir.h(rows);

%Find Lower Properties for Interpolation
rows = find(IdealPropertiesofAir.pf<pr2s,1,'last');
prLow = IdealPropertiesofAir.pf(rows);
hLow = IdealPropertiesofAir.h(rows);

%solve for unknown h2s (Ideal enthalpy after compression)
syms h2s
h2s = vpasolve((h2s-hLow)/(pr2s - prLow)==(hHigh-hLow)/(prHigh-prLow),h2s);

% solve for unknown h2w (actual h2 after compression)

syms h2w
h2w = vpasolve(ce == (h2s - h1)/(h2w - h1),h2w);

%% Solve for Temperature after stage 1 of compressor
%Interpolate T from h

syms t2 %t2=temperature after 1st compressor

%Find Higher Properties for Interpolation
rows = find(IdealPropertiesofAir.h>h2w,1);
THigh = IdealPropertiesofAir.T(rows);
hHigh = IdealPropertiesofAir.h(rows);

%Find Lower Properties for Interpolation
rows = find(IdealPropertiesofAir.h<h2w,1,'last');
TLow = IdealPropertiesofAir.T(rows);
hLow = IdealPropertiesofAir.h(rows);

t2 = vpasolve((THigh-TLow)/(hHigh-hLow) == (t2-TLow)/(h2w-hLow),t2);
%% Solve for specific entropy after stage 1 of compressor
%Find Higher Properties for Interpolation
rows = find(IdealPropertiesofAir.h>h2w,1);
hHigh = IdealPropertiesofAir.h(rows);
sHigh = IdealPropertiesofAir.s(rows);

%Find Lower Properties for Interpolation
rows = find(IdealPropertiesofAir.h<h2w,1,'last');
hLow = IdealPropertiesofAir.h(rows);
sLow = IdealPropertiesofAir.s(rows);

syms ent
ent = vpasolve((h2w-hLow)/(ent - sLow)==(hHigh-hLow)/(sHigh-sLow),ent);

%% Solve for specific volume after stage 1 of compressor

%interpolate for vf

%Find Higher Properties for Interpolation
rows = find(IdealPropertiesofAir.h>h2w,1);
hHigh = IdealPropertiesofAir.h(rows);
vfHigh = IdealPropertiesofAir.vf(rows);

%Find Lower Properties for Interpolation
rows = find(IdealPropertiesofAir.h<h2w,1,'last');
hLow = IdealPropertiesofAir.h(rows);
vfLow = IdealPropertiesofAir.vf(rows);

syms vf2
vf2 = vpasolve((h2w-hLow)/(vf2 - vfLow)==(hHigh-hLow)/(vfHigh-vfLow),vf2);
%still need to find v final


%interpolate for pr2
%Find Higher Properties for Interpolation
rows = find(IdealPropertiesofAir.h>h2w,1);
hHigh = IdealPropertiesofAir.h(rows);
pfHigh = IdealPropertiesofAir.pf(rows);

%Find Lower Properties for Interpolation
rows = find(IdealPropertiesofAir.h<h2w,1,'last');
hLow = IdealPropertiesofAir.h(rows);
pfLow = IdealPropertiesofAir.pf(rows);

syms pf2
pf2 = vpasolve((h2w-hLow)/(pf2 - pfLow)==(hHigh-hLow)/(pfHigh-pfLow),pf2)


%store all necessary state data in table
statevariables.p(i+1) = P0;
statevariables.v(i+1) = 0;
statevariables.T(i+1) = t2;
statevariables.s(i+1) = ent;

%resets initial variables as new state
% Initial Temperature (K)
T0 = t2;
% Initial Pressure (kPa)
P0 = P2s;%Not sure about this one: where is p @state 2 calculated?
%  Ideal pressure after first compressor
P2s = cpr * P0;
% Initial Reduced Pressure
pr1 = pf2
%h
h1=h2w;

end % still needs a way to tabulate data
%% Put in loop to iterate 14 times
%%