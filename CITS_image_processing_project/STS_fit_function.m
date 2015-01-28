
function  I = STS_fit_function(coef_vec,v)

a_pos = coef_vec(1);
a_neg = coef_vec(2);
b_pos = coef_vec(3);
b_neg = coef_vec(4);

v_neg = v(v<0);
v_pos = v(v>=0);
I_neg = -a_neg*(exp(b_neg*abs(v_neg))-1);
I_pos = a_pos*(exp(b_pos*abs(v_pos))-1);
I = [I_neg I_pos];

size(v)
size(v_neg)
size(v_pos)
size(I)