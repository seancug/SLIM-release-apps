% read SLIM_ROOT environment
slimcomp = getenv('SLIM_COMP');
if length(slimcomp)<1
	fprintf('FATAL ERROR: SLIM_COMP environment does not exist\n');
	fprintf('\t source appropriate environment.(sh/csh) in installation directory\n');
	return;
end
slimapps = getenv('SLIM_APPS');
if length(slimapps)<1
	fprintf('FATAL ERROR: SLIM_APPS environment does not exist\n');
	fprintf('\t source appropriate environment.(sh/csh) in installation directory\n');
	return;
end

% start
fprintf('Loading SLIM Toolboxes from\n\t%s\n',slimapps);

% SPOT (slim updates)
addpath([slimapps '/tools/utilities/SPOT-SLIM']);
addpath([slimapps '/tools/utilities/SPOT-SLIM/tests']);
try
   addpath(fullfile(spot.path,'tests','xunit'));
catch ME
   error('Can''t find xunit toolbox.');
end
% pSPOT
addpath([slimapps '/tools/utilities/pSPOT']);
% SPGL1-SLIM (parallel)
%addpath([slimroot '/tools/solvers/SPGL1-SLIM']);

% CurveLab
% if isdir([slimcomp '/tools/transforms/CurveLab-2.1.2-SLIM'])
%     addpath([slimcomp '/tools/transforms/CurveLab-2.1.2-SLIM/fdct_usfft_matlab']);
%     addpath([slimcomp '/tools/transforms/CurveLab-2.1.2-SLIM/fdct_wrapping_matlab']);
%     addpath([slimcomp '/tools/transforms/CurveLab-2.1.2-SLIM/fdct_wrapping_cpp/mex']);
%     addpath([slimcomp '/tools/transforms/CurveLab-2.1.2-SLIM/fdct3d/mex']);
%     addpath([slimcomp '/tools/transforms/CurveLab-2.1.2-SLIM/mecv']);
% else
%     warning('CurveLab directory not foound');
%     %error('CurveLab directory not foound');
% end

% REPSI
%addpath([slimroot '/tools/algorithms/REPSI']);
% Krylov solvers
SLIM_APPS.tools.solvers.Krylov
% CommonFreqModeling
addpath([slimapps '/tools/algorithms/CommonFreqModeling']);
% 2DFreqModeling
addpath([slimapps '/tools/algorithms/2DFreqModeling']);
% Miscellaneous
addpath([slimapps '/tools/operators/misc']);
addpath([slimapps '/tools/functions/misc']);
addpath([slimapps '/tools/solvers/QuasiNewton']);

% MADAGASCAR
% if isdir([slimcomp '/external/lib'])
%     addpath([slimcomp '/external/lib']);
% else
%     warning('MADAGASCAR directory not foound');
%     %error('MADAGASCAR directory not foound');
% end
% done
fprintf('Done loading SLIM Toolboxes\n');
%path
curdir = pwd;
addpath([curdir '/mbin']);

