%% 3D constant-density acoustic frequency-domain modeling: Forward Modeling Kernel
%
% This script aims at demonstrating the simplest possible use of the forward
% modeling kernel using ForwardFD function. It also performs the same 
% computation using the legacy code for the sake of comparison.
% 
% Bear in mind that ForwardFD function is nothing but a wrapper to 
% WaveEquationFD function. Please, read the demo and tests for WaveEquationFD
% as well. The new routine fixes several issues present in the legacy version
% such as 
% 
% * automatic and abstract use of PML
% * properly rounded (up) grid spacing for the computational grid to satisfy 
%   stability conditions.
% * dynamic computational grid chosing depending on the frequency - the user
%   does not need to manually shrink/stretch the model for lower/higher 
%   frequency.
% * Computed wavefields match analitical wavefields
% * Fixed the sign of the wavefield - legacy code produces -conj(.) of the 
%   expected data
% 
% As usual, this script starts cleaning the enviroment and opening the log file
% 
vfile='../data/m_true.rsf';
dfile='../data/Dobs.rsf';
flog = fopen('../results/demo_ForwardFD_log','w');

%% F3d_old - Legacy Forward Modeling
%
% The old version of the code is very little verbose (although it does print 
% some information in F3d.log file) and requires some preprocessing.
%


% 
% First we read the data
%-------------------------------------------------------------------------------
plog(flog,'Starting forward modeling with old code...\n');
plog(flog,'=================================================================\n');
plog(flog,'=================================================================\n\n');
t1 = tic;
plog(flog,'* Reading data... \n');
[m0,nt,dt,ot] = rsf_read_all(vfile);
%
% and then we need to reorder some of the dimensions, and change the unit to
% km^2/s^2. Then, we manually define the computational grid and stretch the
% domain. In this example we don't change the domain size (by setting dx=dt(1).
% 
% For example, if we would like the computational grid to have half the points
% of the physical grid, we would set dx = 2*dt(1);
%-------------------------------------------------------------------------------
dx = dt(1);
m0 = permute(m0,[3 1 2]);
nt = [nt(3) nt(1) nt(2)];
m0 = 1e6./(m0.^2);
[zt,xt,yt]    = odn2grid(ot,dt,nt);
z             = zt(1):dx:zt(end);
x             = xt(1):dx:xt(end);
y             = yt(1):dx:yt(end);
L             = opKron(opLInterp1D(yt,y),opLInterp1D(xt,x),opLInterp1D(zt,z));
m0            = L*m0(:);
[o,d,n]       = grid2odn(z,x,y);

%
% Now we read the data; notice that we also need to permute the data
%-------------------------------------------------------------------------------
[data,nd,dd,od] = rsf_read_all(dfile);
data = permute(data,[3 1 2 6 4 5 7]);
nd = [nd(3) nd(1) nd(2) nd(6) nd(4) nd(5) nd(7)];
dd = [dd(3) dd(1) dd(2) dd(6) dd(4) dd(5) dd(7)];
od = [od(3) od(1) od(2) od(6) od(4) od(5) od(7)];

plog(flog,'* ',prod(nd(4:6)),' shots read; drawing receivers grid...\n');

% Now we set the PML size (as well manually) with nb=8. I have done the 
% calculations beforehand to ensure that 8 points is enough.
% 
% Further we draw the receivers grid.
%-------------------------------------------------------------------------------
nb=8;
modelo.o  = o;
modelo.d  = d;
modelo.n  = n;
modelo.nb = nb*[1 1 1];

[modelo.zrec,modelo.xrec,modelo.yrec,...
modelo.zsrc,modelo.xsrc,modelo.ysrc,modelo.freq] = odn2grid(od,dd,nd);

modelo.f0   = 0;
modelo.t0   = 0;
modelo.tol = 1e-6;

%% ForwardFD - New Forward Modeling
% 
% The new version of the code is rather verbose if the optional parameter |flog|
% is passed to ForwardFD; it prints information both on the screen and on the
% log file. If multiple Matlab workers are available, only the master worker
% prints the information while the other works ignore it.
% 
% Also the new code is very simple and requires virtually no set up.
% 
plog(flog,'Starting forward modeling with new code...\n');
plog(flog,'=================================================================\n');
plog(flog,'=================================================================\n\n');
t1 = tic;

plog(flog,'* Reading data... \n');
[model.v,model.nv,model.dv,model.ov] = rsf_read_all(vfile);
[acq.data,acq.nd,acq.dd,acq.od] = rsf_read_all(dfile);
model.unit = 'm/s';


% Create sources for synthetic data
% 
% If this would be real data, the acquisition geometry would be read from a 
% file instead!
%-------------------------------------------------------------------------------
plog(flog,'* ',prod(acq.nd(4:6)),' shots read; drawing receivers grid...\n');
[ acq.xrec,acq.yrec,acq.zrec,...
  acq.xsrc,acq.ysrc,acq.zsrc, acq.freq] = odn2grid(acq.od,acq.dd,acq.nd);

acq.sources  = speye( prod(acq.nd(4:6)) );
D_new = ForwardFD(model,acq,[],0);
t_new = num2str(toc(t1)/60);
plog(flog,'Finished in ',t_new,' minutes.\n\n');

%% Plotting Results
%
% Simply plots the data generated by both forward modeling kernels.
% They should produce similar results in most cases. The legacy forward modeling 
% kernel should produce some spurious reflections for some frequencies and some
% models, but in this example they are not visible.
%
sp = figure;
set(sp, 'Position', [0 0 1200 600]);
subplot(1,2,1);
imagesc(squeeze(-real(D_leg(1,:,:,ceil(nd(4)/2),...
                                  ceil(nd(5)/2),...
                                  ceil(nd(6)/2),1))));
axis image;
colorbar;
title(['Legacy (F3d) forward modeling kernel - ' t_leg ' minutes']);

subplot(1,2,2);
imagesc(squeeze(real(D_new(:,:,1,ceil(acq.nd(4)/2),...
                                 ceil(acq.nd(5)/2),...
                                 ceil(acq.nd(6)/2),1))));
axis image;
colorbar;
title(['New (ForwardFD) forward modeling kernel - ' t_new ' minutes']);

suptitle('A slice of the computed/predicted data, generated using both forward modeling kernels');

fclose(flog);
