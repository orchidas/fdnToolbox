% Example for dss2pr_direct
% 
% Sebastian J. Schlecht, Sunday, 13. January 2019
clear; clc; close all;

rng(8)   
fs = 48000;
impulseResponseLength = fs/4;

%% FDN define
N = 4;
numInput = 1;
numOutput = 1;
inputGain = eye(N,numInput);
outputGain = eye(numOutput,N);
direct = zeros(numOutput,numInput);
delays = randi([50,100],[1,N]);
matrix = randn(N); 

%% compute
tic
[res.EAI, pol.EAI, directTerm.EAI, isConjugatePolePair.EAI] = ss2pr_fdn(delays, matrix, inputGain, outputGain, direct);
toc
tic
[res.eig, pol.eig, directTerm.eig, isConjugatePolePair.eig] = dss2pr_direct(delays, matrix, inputGain, outputGain, direct,'eig');
toc
tic
[res.polyeig, pol.polyeig, directTerm.polyeig, isConjugatePolePair.polyeig] = dss2pr_direct(delays, matrix, inputGain, outputGain, direct,'polyeig');
toc
tic
[res.roots, pol.roots, directTerm.roots, isConjugatePolePair.roots] = dss2pr_direct(delays, matrix, inputGain, outputGain, direct,'roots');
toc
%% plot
close all;

figure(1); hold on; grid on;
fnames = fieldnames(pol);
markers = {'x','o','<','>'};
for it = 1:length(fnames)
    name = fnames{it};
    plot(angle(pol.(name)),mag2db(abs(pol.(name))),markers{it});
end
legend(fnames)
xlabel('Pole Angle [rad]')
ylabel('Pole Magnitude [dB]')


