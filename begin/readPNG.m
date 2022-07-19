function imgRGBA = readPNG(imPath)
[rotateImg, map, alpha]=imread(imPath);
imgRGBA = rotateImg;
imgRGBA(:,:,4)=alpha;
end