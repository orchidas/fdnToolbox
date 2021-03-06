% Example for various ways to compute the Newton step in the modal
% decomposition.
%
% Sebastian J. Schlecht, Friday, 23 August 2019
clear; clc; close all;


rng(5)
fs = 48000;
gainPerSample = db2mag(RT602slope(1,fs));

%% Define FDN
N = 2;
delays = 10+( randi([5,15],[1,N]) );

%% generate Matrix
switch 'general'
    case 'simple'
        A(:,:,4) = orth(randn(N));
        invA = A; invA(:,:,4) = inv(A(:,:,4));
    case 'twoStages'
        matrix1 = randn(N); eye(N);  orth(randn(N));
        matrix2 = 0.9*orth(randn(N));
        delayV = [2 5]; ( randi([1,5],[1,N]) );
        invDelayV = max(delayV(:)) - delayV;
        delayMat = constructDelayMatrix( delayV );
        invDelayMat = constructDelayMatrix( invDelayV );
        
        A = matrix1;
        A = matrixConvolution(A,delayMat);
        A = matrixConvolution(A,matrix2);
        dd = detPolynomial(A,'z^-1');
        
        invA = inv(matrix1);
        invA = matrixConvolution(delayMat,invA);
        invA = matrixConvolution(inv(matrix2),invA);
    case 'general'
        I = 2;
        matrixType = 'random';
        sparsity = 3;
        
        [A,invA] = constructCascadedParaunitaryMatrix( N, I, 'matrixType', matrixType, 'sparsity', sparsity );
end

G = diag(gainPerSample.^delays);
A = matrixConvolution(G,A);
invA = matrixConvolution(invA,inv(G));
degA = polyDegree(detPolynomial(A,'z^-1'),'z^-1')
numberOfPoles = sum(delays) + degA
%% Test value
z = 0.95 * exp(1i * 0.7);

%% Symbolic
syms zz;
symDelay = diag(zz.^delays);
symA = mpoly2sym(A,zz);

Psym = symDelay - symA;
PsymDer = diff(Psym);

psym = zz^degA * det(Psym);
psymDer = diff(psym);
invNewtonSymPoly = psymDer / psym;
double(subs(invNewtonSymPoly,z))


invNewtonSym = ( trace( Psym \ PsymDer ) + degA/zz);
double(subs(invNewtonSym,z))


%% Symbolic Reverse
symAr = subs(symA,1/zz); % According to definition
symArDer = diff(symAr);

symInvA = inv(symAr);
double(subs(symInvA,z))

symInvAAA = inv(symA); % commute the inverse operations
double(subs(symInvAAA,1/z))


symInvAA = mpoly2sym(invA,zz); % Cascade inverse
double(subs(symInvAA,z))

PsymRev = symDelay - symInvAA;
PsymRevDer = diff(PsymRev);

psymRev = (-1)^N * det(symAr) * det(PsymRev);
psymRevDer = diff(psymRev);

reversedNewton = subs(psymRevDer,1/zz) / subs(psymRev,1/zz) ;
invNewtonSymRevPoly = numberOfPoles / zz - reversedNewton / zz^2;
double(subs(invNewtonSymRevPoly,z))

reversedNewton = trace( subs(PsymRev,1/zz)  \  subs(PsymRevDer,1/zz) + subs(symInvAA,1/zz) * subs(symArDer,1/zz) ) ;
invNewtonSymRev = numberOfPoles / zz - reversedNewton / zz^2;
double(subs(invNewtonSymRev,z))

%% Direct Matrix
zDelay = zDomainDelay(delays);
zA = tfMatrix(A,ones(N),'z^-1');
zADer = derive(zA);
Pz = zDelay.at(z) - at(zA,z);
PzDer = zDelay.der(z) - at(zADer,z);
gcpDirect = z^degA * det( Pz );
gcpDirectDer = z^degA * det(Pz) * ( trace( inv( Pz ) * PzDer) + degA/z);

invNewtonDirect = gcpDirectDer/gcpDirect

%% GCP
gcp = generalCharPoly( delays, A ); % implicit multiplication with z^degA
gcpDer = polyder(gcp);
gcpVal = polyval(gcp,z);
gcpDerVal =  polyval(gcpDer,z);
invNewtonGCP = gcpDerVal / gcpVal

%% Loop
loop = zDomainStandardLoop(delays, A, invA);
invNewtonLoop = trace( loop.at(z)  \ loop.der(z)  ) + degA/z

%% Reverse Loop
iz = 1/z;
reversedNewton = trace( loop.atRev(iz)  \ loop.derRev(iz) ) + trace(  loop.invFeedbackTF.at(iz) * loop.feedbackTF.der(1/iz) / -iz^2 );
invNewtonLoopR = loop.numberOfDelayUnits / z - reversedNewton / z^2

