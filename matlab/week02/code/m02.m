clear all; clc;

L=2; % segment
x=[1 2 3 4 5 6]; 
h=[1 1 1]; % signal and system
X=length(x); 
H=length(h); % signal and system length

hz=[h zeros(1,L-1)]; % zero padded system
y=zeros(1,X+H-1); % output variable initialization

for ii=1:L:X+L-1
 if ii==1
   xz=[zeros(1,H-1) x(ii:ii+L-1)];
   
 elseif ii==(X+L-1) % last segment
   xz=[x(ii-L:ii-1) zeros(1,H-1)];
  
 else % middle segment
   xz=x(ii-H+1:ii+L-1);
   
 end
 yz=cconv(xz,hz,L+H-1); % circular convolution
 yz = yz(H:end);
 if ii / 2 == 0
 else
    y(ii:ii+1) = y(ii:ii+1) + yz;
 end
end