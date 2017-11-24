%comparison of several denoising algorithms in term of  : 
%-error : e = | diag_reconstructed - diag(Sp) | / |diag(Sp)|
%-convergence : c = | diag_rec(k-1) - diag(Sp)| / |diag_rec(k) - diag(Sp)|
%%
clear all
%close all

addpath('/home/adinsenmey/Bureau/Codes_Exterieurs/codes_debruitage_jerome')
addpath(genpath('/home/adinsenmey/Bureau/these_2017/Debruitage'))

freq = 3800;
Nsrc =1:150;
Mw=9000;
rho=0;
SNR = 10;

for i=1:length(Nsrc)
i
	%%% Generate data
	[Sq b Sp Sn] = generate_Spp_signal(freq, Nsrc(i) , rho , SNR , Mw);
    Sy(:,:,i)=Sp+diag(diag((Sn)));
	Rang(i)=rank(Sp,0.005*max(eig(Sp)));
	Rang2(i)=rank(Sp);

	CSM = Sy(:,:,i);
    d_ref(:,i)=real(diag(Sp));

	%%%--------------------------------------------------------------------------------------------
	%%% SLDR solved with proximal gradient
	%%%--------------------------------------------------------------------------------------------
	%lambda= 0.1;
	%[A E Nit out A_all] = proximal_gradient_rpca(CSM , lambda, 70,1e-10,-1,-1,-1,-1);
	
	%d_pg = real( diag(A_all(:,:,end)));	
	%err_pg(i)= norm( diag(d_ref - d_pg) ,1) / norm(d_ref,1);

	%%%--------------------------------------------------------------------------------------------
	%%% Alternating projections
	%%%--------------------------------------------------------------------------------------------
	%cvx (Hald)
% 	cvx_quiet('true')
% 	[CSM_cvx d1 cvx_it]=CSMRecHald(CSM);     
%   d_cvx(:,i)=diag(CSM_cvx);
%   err_cvx(i)= norm( d_ref(:,i)-real(d_cvx(:,i)) ,2)/norm(d_ref(:,i),2); 
    
	%linprog (Dougherty)
	%[CSM_linprog ii] = recdiagd(double(CSM),500,30);
    %d_linprog(:,i) = real(diag(CSM_linprog));
    %err_linprog(i)= norm( d_ref(:,i)-real(d_linprog(:,i))) / norm(d_ref(:,i)) ;

	%Alternating projection
	%[CSM_it, n, errec, D_AP] = recdiag(CSM,1,300,1e-9,30); %enlever les VP negatives puis recalculer les VP en interchangeant la diagonale
    %d_it(:,i) = real(diag(CSM_it));
    %err_it(i) = norm( d_ref(:,i)-real(d_it(:,i))) / norm(d_ref(:,i));
    
    %Version Jérôme (remove average value of the K greatest SV)
    [Sn,L] = SS_CSM_Fit(CSM,92);
    d_jerome(:,i) = real(diag(L*L'));
    d_jerome2(:,i) = real(diag(CSM-diag(Sn)));
    err_jerome(i) = norm( d_ref(:,i)-real(d_jerome(:,i))) / norm(d_ref(:,i));
    
end

%save('linprog','err_linprog','Rang2','d_linprog','d_ref')
%save('AP_it','err_it','Rang2','d_it','d_ref')


%%%--------------------------------------------------------------------------------------------
%%% Keep only K greatest eigenvalues
%%%--------------------------------------------------------------------------------------------
%s= min(real(eig(CSM)))/(1-sqrt(Nmic/Mw))^2; %estimation du bruit
%[l cdf]=distrib_vp_noise(Nmic,Mw,s);
%figure
%plot(cdf,10*log10(l));
%hold on
%plot(10*log10(sort(real(eig(Sy(:,:,f))))));
%K=input('Rang supposé ? ');

%[noise, L_signal] = SS_CSM_Fit(CSM,K);
%CSM_KVP = L_signal*L_signal';

%%%--------------------------------------------------------------------------------------------
%%% EM
%%%--------------------------------------------------------------------------------------------

%EM Jérôme
	%Initialisation par conservation des K premières VP
%[Ini.Syc, Ini.L] = SS_CSM_Fit(Sy(:,:,f),K); %initialisation
%    %Initialisation par des valeurs aléatoires
%v=var(diag(CSM));
%m=mean(diag(CSM));
%Ini.Syc=v*randn(93,1)+m;
%[u s] = eig(CSM-diag(Ini.Syc));
%Ini.L=u(:,1:K)*sqrt(s(1:K,1:K));


%option.max = 70; %max number of iteration
%option.rerr=1e-7;

%[L,sig2,beta2,flag,Sx, D_EM] = EM_CSM_Fit(Sy(:,:,f),Mw,K,option,Ini,Sp(:,:,f));

%for i=1:flag.count
%    norm_EM(i)=norm((D_EM(:,i)-d_ref)./d_ref);
%end

