function [x,y] = plotSin()
	x = (-pi:0.01:pi);
	y = sin(3*x);
	hold on;
	plot(x, y);
end

