% Values for table: T h u s pf vf
while exist('IdealPropertiesofAir','var') ~= 1%prompts you to upload the table if if it isn't already in the workspace
uiimport('Ideal Properties of Air.txt')
pause(15)
end
% Velocity in (m/s)
vin = 152.7778;
% Air Mass Flow Rate (kg/s)
mdot = 113.026;
% Fuel + Air Mass Flow Rate (kg/hr)
FAmdot = 6716.4;

%% Assumptions
% Air Density (kg/m^3)
ro = 0.6759;
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
% mdot for afterburner (kg/s)
mdotaft = (-400 + 110 * mdot)/3600;
% Nozzle exit area (m^2)
Narea = 0.5 * 0.3;
%initial entropy(kj/(kg*K)
sint = 7.619;

%initializing table
%table collects data about states after the listed change
%ex: c1 = state after first compression
z=zeros(22);
statevariables = table(z(:,1),z(:,1),z(:,1),z(:,1),'VariableNames',{'p','v','T','s'},'RowNames',{'cinitial','c1','c2','c3','c4','c5','c6','c7','c8','c9','c10','c11','c12','c13','c14','combust','t1','t2','t3','t4','burner','n'});%,'RowNames',{'cinitial','c1','c2','c3','c4','c5','c6','c7','c8','c9','c10','c11','c12','c13','c14','combust','t1','t2','t3','t4','n'};
%put known values into table
statevariables.T(1) = T0;%T in K
statevariables.p(1) = P0;%P in kPa
statevariables.v(1) = R*T0/(P0*M);%v in m^3/kg
statevariables.s(1) = sint;
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
entlast = 1.59634;

for i = 1:1:14% loop to make this repeat 14 times
%P2s = cpr * P0;

pr2s = 40.^(i/14) * pr1;

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
pf2 = vpasolve((h2w-hLow)/(pf2 - pfLow)==(hHigh-hLow)/(pfHigh-pfLow),pf2);

%  Ideal pressure after first compressor
P2s = 40.^(i/14) * 49.586;
%store all necessary state data in table
statevariables.p(i+1) = P2s;
statevariables.v(i+1) = R*t2/(P2s*M);
statevariables.T(i+1) = t2;
scurrent = ent-entlast-R/M*log(statevariables.p(i+1)/statevariables.p(i)) + statevariables.s(i);
statevariables.s(i+1) = ent-entlast-R/M*log(statevariables.p(i+1)/statevariables.p(i)) + statevariables.s(i);

entlast = ent;
%resets final variables as new state
% Initial Temperature (K)
T0 = t2;
% Initial Pressure (kPa)


% Initial Reduced Pressure
%pr1 = pf2
P0 = P2s;%Not sure about this one: where is p @state 2 calculated?
%h
h1=h2w;

end  

% Calculate the heat addition by the combustion chamber 
mdot_air = 113.026;%kg/s
Qcomb = 43360;%kj/kg
mdot_comb = 1.86568;%kg/s
Qdot = Qcomb * mdot_comb;
QdotMdot = Qdot/(mdot_air-mdot_comb);

syms h3
h3 = vpasolve(QdotMdot == h3 - h2w,h3);



%Interpolate T from h

syms t2 

%Find Higher Properties for Interpolation
rows = find(IdealPropertiesofAir.h>h3,1);
THigh = IdealPropertiesofAir.T(rows);
hHigh = IdealPropertiesofAir.h(rows);

%Find Lower Properties for Interpolation
rows = find(IdealPropertiesofAir.h<h3,1,'last');
TLow = IdealPropertiesofAir.T(rows);
hLow = IdealPropertiesofAir.h(rows);

t2 = vpasolve((THigh-TLow)/(hHigh-hLow) == (t2-TLow)/(h3-hLow),t2);

%solve for s from h
%Find Higher Properties for Interpolation
rows = find(IdealPropertiesofAir.h>h3,1);
hHigh = IdealPropertiesofAir.h(rows);
sHigh = IdealPropertiesofAir.s(rows);

%Find Lower Properties for Interpolation
rows = find(IdealPropertiesofAir.h<h3,1,'last');
hLow = IdealPropertiesofAir.h(rows);
sLow = IdealPropertiesofAir.s(rows);

syms ent
ent = vpasolve((h3-hLow)/(ent - sLow)==(hHigh-hLow)/(sHigh-sLow),ent);

statevariables.p(16) = statevariables.p(15);
statevariables.v(16) = R*t2/(statevariables.p(15)*M);
statevariables.T(16) = t2;
statevariables.s(16) = ent-entlast-R/M*log(statevariables.p(16)/statevariables.p(15)) + statevariables.s(15);
entlast = ent;

for j = 1:1:4% loop to make this repeat 4 times
%P2s = cpr * P0;


%pr3s = 1/(40.^(j/4) * pr2s;
pr3s = 1/(1.46275964^(j/4)) * pr2s;

%%
%Find Higher Properties for Interpolation
rows = find(IdealPropertiesofAir.pf>pr3s,1);
prHigh = IdealPropertiesofAir.pf(rows);
hHigh = IdealPropertiesofAir.h(rows);

%Find Lower Properties for Interpolation
rows = find(IdealPropertiesofAir.pf<pr3s,1,'last');
prLow = IdealPropertiesofAir.pf(rows);
hLow = IdealPropertiesofAir.h(rows);

%solve for unknown h2s (Ideal enthalpy after compression)
syms h3s
h3s = vpasolve((hHigh-h3s)/(prHigh-pr3s)==(hHigh-hLow)/(prHigh-prLow),h3s);

% solve for unknown h2w (actual h2 after compression)

syms h4
h4 = vpasolve(.94 == (h4 - h3)/(h3s-h3),h4);

%% Solve for Temperature after stage 1 of compressor
%Interpolate T from h

syms t3 %t2=temperature after 1st compressor

%Find Higher Properties for Interpolation
rows = find(IdealPropertiesofAir.h>h4,1);
THigh = IdealPropertiesofAir.T(rows);
hHigh = IdealPropertiesofAir.h(rows);

%Find Lower Properties for Interpolation
rows = find(IdealPropertiesofAir.h<h4,1,'last');
TLow = IdealPropertiesofAir.T(rows);
hLow = IdealPropertiesofAir.h(rows);

t3 = vpasolve((THigh-TLow)/(hHigh-hLow) == (THigh-t3)/(hHigh-h4),t3);
%% Solve for specific entropy after stage 1 of compressor
%Find Higher Properties for Interpolation
rows = find(IdealPropertiesofAir.h>h4,1);
hHigh = IdealPropertiesofAir.h(rows);
sHigh = IdealPropertiesofAir.s(rows);

%Find Lower Properties for Interpolation
rows = find(IdealPropertiesofAir.h<h4,1,'last');
hLow = IdealPropertiesofAir.h(rows);
sLow = IdealPropertiesofAir.s(rows);

syms ent3
ent3 = vpasolve((h4-hLow)/(ent3 - sLow)==(hHigh-hLow)/(sHigh-sLow),ent3);

%% Solve for specific volume after stage 1 of compressor

%interpolate for vf

%Find Higher Properties for Interpolation
rows = find(IdealPropertiesofAir.h>h4,1);
hHigh = IdealPropertiesofAir.h(rows);
vfHigh = IdealPropertiesofAir.vf(rows);

%Find Lower Properties for Interpolation
rows = find(IdealPropertiesofAir.h<h4,1,'last');
hLow = IdealPropertiesofAir.h(rows);
vfLow = IdealPropertiesofAir.vf(rows);

syms vf3
vf3 = vpasolve((h4-hLow)/(vf3 - vfLow)==(hHigh-hLow)/(vfHigh-vfLow),vf3);
%still need to ind v final

    speciv3 = vf3 * R * Tc / Pc;
    
    %pf2 = pf2 * 1/(40.^(j/4));%vpasolve((h2w-hLow)/(pf2 - pfLow)==(hHigh-hLow)/(pfHigh-pfLow),pf2);

%P2s = 1/40.^(j/4) * 1983.4;
P2s = 1983.4 * 1/(1.46275964.^(j/4));
%resets initial variables as new state

statevariables.p(j+16) = P2s;
statevariables.v(j+16) = R*t2/(statevariables.p(j+16)*M);
statevariables.T(j+16) = t3;
statevariables.s(j+16) = ent3-entlast-R/M*log(statevariables.p(j+16)/statevariables.p(j+15)) + statevariables.s(j+15);

entlast = ent3;


% Initial Reduced Pressure
%pr1 = pf2
%P0 = P2s;%Not sure about this one: where is p @state 2 calculated?
%h
%h1=h2w;
end
% afterburner section

qdot_aft = mdotaft * Qcomb;
qdotmdot_aft = qdot_aft / mdot;
syms h5
h5 = vpasolve(qdotmdot_aft == h5 - h4,h5);

%Interpolate T from h

syms t3 %t2=temperature after 1st compressor

%Find Higher Properties for Interpolation
rows = find(IdealPropertiesofAir.h>h5,1);
THigh = IdealPropertiesofAir.T(rows);
hHigh = IdealPropertiesofAir.h(rows);

%Find Lower Properties for Interpolation
rows = find(IdealPropertiesofAir.h<h5,1,'last');
TLow = IdealPropertiesofAir.T(rows);
hLow = IdealPropertiesofAir.h(rows);

t3 = vpasolve((THigh-TLow)/(hHigh-hLow) == (t3-TLow)/(h5-hLow),t3);

%solve for s from h
%Find Higher Properties for Interpolation
rows = find(IdealPropertiesofAir.h>h5,1);
hHigh = IdealPropertiesofAir.h(rows);
sHigh = IdealPropertiesofAir.s(rows);

%Find Lower Properties for Interpolation
rows = find(IdealPropertiesofAir.h<h5,1,'last');
hLow = IdealPropertiesofAir.h(rows);
sLow = IdealPropertiesofAir.s(rows);

syms ent
ent = vpasolve((h5-hLow)/(ent - sLow)==(hHigh-hLow)/(sHigh-sLow),ent);

statevariables.p(21) = statevariables.p(20);
statevariables.v(21) = R*t3/(statevariables.p(21)*M);
statevariables.T(21) = t3;
statevariables.s(21) = ent-entlast-R/M*log(statevariables.p(21)/statevariables.p(20)) + statevariables.s(20);

entlast = ent;

%% Nozzle Section

syms h6

h6 = vpasolve(0.94 == (h5 - h6) / (h5 - 255.7226), h6);

%Interpolate T from h

syms t3 %t2=temperature after 1st compressor

%Find Higher Properties for Interpolation
rows = find(IdealPropertiesofAir.h>h6,1);
THigh = IdealPropertiesofAir.T(rows);
hHigh = IdealPropertiesofAir.h(rows);

%Find Lower Properties for Interpolation
rows = find(IdealPropertiesofAir.h<h6,1,'last');
TLow = IdealPropertiesofAir.T(rows);
hLow = IdealPropertiesofAir.h(rows);

t3 = vpasolve((THigh-TLow)/(hHigh-hLow) == (t3-TLow)/(h6-hLow),t3);

%solve for s from h
%Find Higher Properties for Interpolation
rows = find(IdealPropertiesofAir.h>h6,1);
hHigh = IdealPropertiesofAir.h(rows);
sHigh = IdealPropertiesofAir.s(rows);

%Find Lower Properties for Interpolation
rows = find(IdealPropertiesofAir.h<h6,1,'last');
hLow = IdealPropertiesofAir.h(rows);
sLow = IdealPropertiesofAir.s(rows);

syms ent
ent = vpasolve((h6-hLow)/(ent - sLow)==(hHigh-hLow)/(sHigh-sLow),ent);

statevariables.p(22) = statevariables.p(15);
statevariables.v(22) = R*t3/(statevariables.p(22)*M);
statevariables.T(22) = t3;
statevariables.s(22) = ent-entlast-R/M*log(statevariables.p(22)/statevariables.p(21)) + statevariables.s(21);


