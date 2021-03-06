% current directory
curdir = pwd;
addpath([curdir '/..']);

% initialize empty options struct to delete any previous values
options = [];

% output directory
options.outputDir = curdir;

% location of stylesheet
options.stylesheet = [curdir '/slim.xsl'];

% format
options.format      = 'html';

% no thumbnails
options.createThumbnail = false;

% whether to show that code
options.showCode = true;


% publish some files without running the code
options.evalCode = false;

publish('index.m',options);
%publish('makedoc.m',options);

% publish a file and run the code
options.evalCode = true;

publish('example.m',options);

% close figures
close all;
% open file for viewing
open('index.html')
