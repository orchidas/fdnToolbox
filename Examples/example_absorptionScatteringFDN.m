% Example for absorption in Scattering FDNs
%
% (c) Sebastian Jiro Schlecht:  23. April 2018
clear; clc; close all;

rng(5)

fs = 48000;
impulseResponseLength = fs*2;

%% define FDN
N = 4;
numInput = 1;
numOutput = 1;
inputGain = ones(N,numInput);
outputGain = ones(numOutput,N);
direct = zeros(numOutput,numInput);
delays = randi([500,2000],[1,N]);
numberOfStages = 3;
sparsity = 3;
maxShift = 30;
[feedbackMatrix, revFeedbackMatrix] = constructVelvetFeedbackMatrix(N,numberOfStages,sparsity);
[feedbackMatrix, revFeedbackMatrix] = randomMatrixShift(maxShift, feedbackMatrix, revFeedbackMatrix );

%% absorption filters including delay of scattering matrix
[approximation,approximationError] = matrixDelayApproximation(feedbackMatrix);

RT_DC = 2; % seconds
RT_NY = 0.5; % seconds

[absorption.b,absorption.a] = onePoleAbsorption(RT_DC, RT_NY, delays + approximation, fs);
loopMatrix = zDomainAbsorptionMatrix(feedbackMatrix, absorption.b, absorption.a);

%% compute impulse response and poles/zeros and reverberation time
irTimeDomain = dss2impz(impulseResponseLength, delays, loopMatrix, inputGain, outputGain, direct);
[res, pol, directTerm, isConjugatePolePair,metaData] = dss2pr(delays, loopMatrix, inputGain, outputGain, direct);
irResPol = pr2impz(res, pol, directTerm, isConjugatePolePair, impulseResponseLength);

difference = irTimeDomain - irResPol;
fprintf('Maximum devation betwen time-domain and pole-residues is %f\n', permute(max(abs(difference),[],1),[2 3 1]));

[reverberationTimeEarly, reverberationTimeLate, F0, powerSpectrum, edr] = reverberationTime(irTimeDomain, fs);

%% plot
figure(1); hold on; grid on;
t = 1:size(irTimeDomain,1);
plot( t, difference(1:end) );
plot( t, irTimeDomain - 2 );
plot( t, irResPol - 4 );
legend('Difference', 'TimeDomain', 'Res Pol')


figure(2); hold on; grid on;
plot(rad2hertz(angle(pol),fs),slope2RT60(mag2db(abs(pol)), fs),'x');
plot(F0,reverberationTimeLate);
plot(F0,reverberationTimeEarly);
set(gca,'XScale','log');
xlim([50 fs/2]);
xlabel('Frequency [hz]')
ylabel('Pole RT60 [s]')
legend({'Poles','Minimum','Maximum','T60 Late','T60 Early'})

figure(3); hold on; grid on;
plotImpulseResponseMatrix(1:size(feedbackMatrix,3),feedbackMatrix);

