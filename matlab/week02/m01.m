clear all; clc;

L = 2;
x = [1,2,3,4,5,6];
h = [1,1,1];
X = length(x);
hz=[h zeros(1,L-1)]; % zero padded system
H = length(h);
y = zeros(1, X+H-1);   %[0,0,0,0,0,0,0,0]

for ii=1:L:X-1
 xz=[x(ii:ii+L-1) zeros(1,H-1)]; % zero padded segment
 yz = cconv(xz, hz, L+H-1);
 y(ii:ii+L+H-2) = y(ii:ii+L+H-2) + yz;   
end
