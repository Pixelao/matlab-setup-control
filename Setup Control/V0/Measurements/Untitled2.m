clear
TPL = @(I,x0,gamma,x) I./(1+((x-x0)/gamma).^2); % three point lorentzian

F1 = @(p,x) TPL(p(1),p(2),p(3),x);
% guessF1=[1 1.93 1];
% 
% F1C = @(p,x) TPL(p(1),p(2),p(3),x)+p(4);

% F2 = @(p,x) p(1)+TPL(p(2),p(3),p(4),x)+TPL(p(5),p(6),p(7),x);
% guess=[0 1 1.84 1 0.01 1.86 0.01];
% lb=[0 0 1.8 0 0 1.85 0 0];
% ub=[1 1 1.85 1000 1 1.9 1000 1];

F3 = @(p,x) p(1)+TPL(p(2),p(3),p(4),x)+TPL(p(5),p(6),p(7),x)+TPL(p(8),p(9),p(10),x);
guess=[0 0.1 1.84 1 0.1 1.86 1 0.1 1.895 1];
lb=[0 0 1.8 0 0 1.85 0 0 1.885 0 0];
ub=[1 1 1.85 1000 1 1.885 1000 1 1.91 1000 1];



XX=get(gco,'xdata');
YY=get(gco,'ydata');

X=XX(XX>1.8 & XX<1.9);
Y=YY(XX>1.8 & XX<1.9);

 options = optimoptions('lsqcurvefit','MaxFunEvals',1e6,...
     'MaxIter',2000,'FunctionTolerance',1e-12);

p = lsqcurvefit(F3,guess,X,Y,lb,ub,options);

figure
plot(XX,YY)
hold on
plot(XX,F1(p(2:4),XX),XX,F1(p(5:7),XX),XX,F1(p(8:10),XX),XX,F3(p,XX))
xlim([1.8 2.1])