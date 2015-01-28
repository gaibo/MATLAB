
clear all

v = -1.5 : .1 : 1.5;
I = 1*v.^3 + .1*v.^2 - .1*v + .01;
I_o = I;
I = I + 2*(rand(size(I))-.5);

p = polyfit(v,I,3);

I_fit = p(1)*v.^3 + p(2)*v.^2 + p(3)*v.^1 + p(4);

%I_fit = p(1)*v.^6 + p(2)*v.^5 + p(3)*v.^4 + p(4)*v.^3 + p(5)*v.^2 + p(6)*v.^1 + p(7);


figure(1)
clf
plot(v,I); hold on
plot(v,I_o,'k')
plot(v,I_fit,'r')

%%
clear all

v = -1.5 : .01 : 1.5;
v_neg = v(v<0);
v_pos = v(v>=0);
I_neg = -.001*(exp(6*abs(v_neg))-1);
I_pos = .002*(exp(3.5*abs(v_pos))-1);
I = [I_neg I_pos];

I_o = I;
I = I + 1*(rand(size(I))-.5);

p = polyfit(v,I,6);

%I_fit = p(1)*v.^3 + p(2)*v.^2 + p(3)*v.^1 + p(4);

I_fit = p(1)*v.^6 + p(2)*v.^5 + p(3)*v.^4 + p(4)*v.^3 + p(5)*v.^2 + p(6)*v.^1 + p(7);

figure(1)
clf
plot(v,I); hold on
plot(v,I_o,'k')
plot(v,I_fit,'r')

a_pos_guess = .001;
a_neg_guess = .001;
b_pos_guess = 3;
b_neg_guess = 4;

% least square error fitting
coef_guess_vec(1) = a_pos_guess;
coef_guess_vec(2) = a_neg_guess;
coef_guess_vec(3) = b_pos_guess;
coef_guess_vec(4) = b_neg_guess;

% coef_fit_mat = zeros(numberX,numberY);
% for k1 = 1 : numberX
%     for k2 = 1 : numberY
%         I = data_mat(k1,k2,:);
        options = optimset('MaxFunEvals',1000,'TolFun',1e-9,'Display','off');
        coef_fit = lsqcurvefit(@STS_fit_function,coef_guess_vec,v,I,[],[],options);
        
%         coef_fit_mat(k1,k2,:) = coef_fit;
%         
%     end
% end


I_lsq_guess = STS_fit_function(coef_guess_vec,v);
I_lsq_fit = STS_fit_function(coef_fit,v);

figure(2)
clf
plot(v,I,'b.-'); hold on
plot(v,I_lsq_guess,'g')
plot(v,I_lsq_fit,'r')

