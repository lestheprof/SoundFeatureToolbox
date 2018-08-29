function gb=gabor_fn_1(bw,gamma,psi,lambda,theta,display, varargin)
% bw    = bandwidth, (1)
% gamma = aspect ratio, (0.5)
% psi   = phase shift, (0)
% lambda= wave length, (>=2)
% theta = angle in rad, [0 pi)
% added a display option LSS 12 12 13.
%
% allow for setting x and y sizes: lss 12 12 13
%
i=1 ;
while(i<=size(varargin,2))
    switch lower(varargin{i})
        case 'szx';
            szx=varargin{i+1};
            i=i+1;
        case 'szy';
            szy=varargin{i+1};
            i=i+1;
            
        otherwise
            error('gabor_fn_1: Unknown argument %s given',varargin{i});
    end
    i=i+1;
end


sigma = (lambda/pi)*sqrt(log(2)/2)*((2^bw+1)/(2^bw-1)); % brackets added for clarity
sigma_x = sigma;
sigma_y = sigma/gamma;

% sz=fix(8*max(sigma_y,sigma_x));
% if mod(sz,2)==0, sz=sz+1;end
if (~exist('szx', 'var'))
    szx = fix(8*sigma_y);
end
if mod(szx,2)==0, szx=szx+1;end
if(~exist('szy', 'var') || (szy==0))
    szy = fix(8*sigma_x);
end
if mod(szy,2)==0, szy=szy+1;end

% alternatively, use a fixed size
% sz = 60;

[x, y]=meshgrid(-fix(szx/2):fix(szx/2),fix(szy/2):-1:fix(-szy/2));
% x (right +)
% y (up +)

% Rotation
x_theta=x*cos(theta)+y*sin(theta);
y_theta=-x*sin(theta)+y*cos(theta);

gb=exp(-0.5*(x_theta.^2/sigma_x^2+y_theta.^2/sigma_y^2)).*cos(2*pi/lambda*x_theta+psi);
if display
    figure('Name', 'Gabor Filter') ; 
    surf(gb);
    top = max(max(gb)) ;
        bot = min(min(gb)) ;
        lim = max(top, -bot) ;
        imagesc(gb') ; set(gca, 'YDir', 'normal') ; set(gca, 'CLim', [-lim lim]) ;
        clim = get(gca, 'CLim') ; 
    title(['bw=' num2str(bw) ' gamma=' num2str(gamma) ' psi=' num2str(psi) ' lambda=' num2str(lambda)...
        ' theta=' num2str(theta) ' szx=' num2str(szx) ' szy=' num2str(szy) ' (min, max)=(' num2str(clim(1)), ', ' num2str(clim(2)), ')' ]) ;
end
end
