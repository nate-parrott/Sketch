//
//  SKImageExtractView.m
//  Sketch
//
//  Created by Nate Parrott on 9/22/12.
//
//

#import "SKImageExtractView.h"
#import "Image.h"
#import "CGPointExtras.h"
#import "UIImage+Data.h"

#include <vector.h>

@implementation SKImageExtractView
@synthesize delegate=_delegate;

-(void)setImage:(UIImage*)image {
    if (!_image) {
        // setup:
        _imageView = [[UIImageView alloc] init];
        [self addSubview:_imageView];
        _selectionOutlineView = [UIImageView new];
        [self addSubview:_selectionOutlineView];
    }
    _image = image;
    _imageView.image = image;
}
-(ImageWrapper*)edgeImage {
    if (!_edgeImage
        ||
        !CGSizeEqualToSize(self.bounds.size, _lastEdgeImageSize)) {
        _lastEdgeImageSize = self.bounds.size;
        ImageWrapper* wrapper = Image::createImage(_image, self.bounds.size.width, self.bounds.size.height);
        wrapper.image->HistogramEqualisation();
        _edgeImage = wrapper.image->gaussianBlur().image->cannyEdgeExtract(0.3, 0.7);
        //[UIImagePNGRepresentation(_edgeImage.image->toUIImage()) writeToFile:@"/Users/nateparrott/Desktop/edges.png" atomically:YES];
    }
    return _edgeImage;
}
-(UIImage*)grayscaleEdgeImage {
    if (!_edgeImageGrayscale
        ||
        !CGSizeEqualToSize(self.bounds.size, _lastEdgeImageSize)) {
        _lastEdgeImageSize = self.bounds.size;
        ImageWrapper* wrapper = Image::createImage(_image, self.bounds.size.width, self.bounds.size.height);
        wrapper.image->HistogramEqualisation();
        _edgeImageGrayscale = wrapper.image->gaussianBlur().image->cannyEdgeExtract(0.2, 0.7).image->toGrayscaleUIImage();
        [UIImagePNGRepresentation(_edgeImageGrayscale) writeToFile:@"/Users/nateparrott/Desktop/edges.png" atomically:YES];
        //[UIImagePNGRepresentation(_edgeImage.image->toUIImage()) writeToFile:@"/Users/nateparrott/Desktop/edges.png" atomically:YES];
    }
    return _edgeImageGrayscale;
}
#pragma mark Layout
-(void)layoutSubviews {
    [super layoutSubviews];
    _imageView.frame = self.bounds;
    _selectionOutlineView.frame = self.bounds;
}
#pragma mark Closest-edge method
-(CGPoint)closestEdgeToPoint:(CGPoint)p inDirection:(CGFloat)angle tolerance:(CGFloat)radius {
    Image* edgeImage = [self edgeImage].image;
    for (int i=0; i<ceil(radius); i++) {
        for (int m=-1; m<=1; m+=2) {
            CGPoint shifted = CGPointShift(p, angle, i*m);
            //shifted.x *= edgeImage->getWidth() / self.bounds.size.width;
            //shifted.y *= edgeImage->getHeight() / self.bounds.size.height;
            if (edgeImage->at(shifted.x*edgeImage->getWidth() / self.bounds.size.width, shifted.y*edgeImage->getHeight() / self.bounds.size.height) < 255) {
                return shifted;
            }
        }
    }
    return p;
}
-(CGPoint)nearestEdgeToPoint:(CGPoint)p tolerance:(CGFloat)tolerance {
    Image* edgeImage = [self edgeImage].image;
    /*for (int i=0; i<tolerance; i++) {
        for (int xp=-1; xp<=1; xp+=2) {
            for (int yp=-1; yp<=1; yp+=2) {
                CGPoint point = CGPointMake(p.x+xp*i, p.y+yp*i);
                point.x *= edgeImage->getWidth() / _lastEdgeImageSize.width;
                point.y *= edgeImage->getHeight() / _lastEdgeImageSize.height;
                if (edgeImage->at(point.x, point.y) < 255) {
                    return point;
                }
            }
        }
    }*/
    if (edgeImage->at(p.x*edgeImage->getWidth() / self.bounds.size.width, p.y*edgeImage->getHeight() / self.bounds.size.height) < 200) {
        return p;
    }
    for (int i=1; i<tolerance; i++) {
        for (int x=p.x-i; x<=p.x+i; x+=i*2) {
            for (int y=p.y-i; y<=p.y+i; y+=i*2) {
                CGPoint point = CGPointMake(x, y);
                if (edgeImage->at(point.x*edgeImage->getWidth() / self.bounds.size.width, point.y*edgeImage->getHeight() / self.bounds.size.height) < 200) {
                    return point;
                }
            }
        }
    }
    return p;
}
/*
#pragma mark Line-hugging (unused)
-(NSArray*)pointsByHuggingEdgesAlongLineFrom:(CGPoint)start to:(CGPoint)end withTolerance:(CGFloat)radius {
    NSMutableArray* points = [NSMutableArray new];
    CGPoint lastPointAdded = CGPointMake(MAXFLOAT, MAXFLOAT);
#define GOT_POINT(p) if (!CGPointEqualToPoint(lastPointAdded, p)) {lastPointAdded = p; [points addObject:[NSValue valueWithCGPoint:p]];}
    
    CGFloat angle = CGPointAngleBetween(end, start);
    if (_lastLineSegmentAngle!=MAXFLOAT) {
        int intermediateAngles = 5;
        for (int i=0; i<intermediateAngles; i++) {
            CGFloat intermediateAngle = _lastLineSegmentAngle*(intermediateAngles-1-i)/intermediateAngles + angle*i/intermediateAngles;
            CGPoint p = [self closestEdgeToPoint:start inDirection:intermediateAngle tolerance:radius];
            GOT_POINT(p);
        }
    }
    _lastLineSegmentAngle = angle;
    CGFloat distance = CGPointDistance(end, start);
    for (int i=0; i<ceil(distance); i++) {
        CGPoint p = CGPointShift(start, angle, i);
        GOT_POINT([self closestEdgeToPoint:p inDirection:angle tolerance:radius]);
    }
    
    return points;
}
*/
/*#pragma mark Contour-tracing line-hugging
-(NSArray*)pointsByTracingContoursAlongLineFrom:(CGPoint)start to:(CGPoint)end withRadius:(CGFloat)radius {
    
}
+(NSArray*)traceContoursInPortion:(CGRect)portion ofImage:(UIImage*)image {
    NSMutableArray* contours = [NSMutableArray new];
    
    IGImageData* imageData = [image imageDataForSubImage:portion];
    
    //[UIImagePNGRepresentation([UIImage imageFromImageData:imageData]) writeToFile:@"/Users/nateparrott/Desktop/imgdata.png" atomically:YES];
    
#define PIX(x, y, channel) (x>=0 && y>=0 && x<imageData->w && y<imageData->h? imageData->data[(int)(imageData->w*(y) + (x))*4 + channel] < 20 : 0)
#define SETPIX(x,y,channel,val) imageData->data[(int)(imageData->w*(y) + (x))*4 + channel] = val? 0 : 255
    
    for (int startX=0; startX<imageData->w; startX++) {
        for (int startY=0; startY<imageData->h; startY++) {
            if (PIX(startX, startY, 0)) {
                //NSLog(@"%i, %i, %i", startX, startY, PIX(startX, startY, 0));
                SETPIX(startX, startY, 0, 0);
                // find a filled pixel to the left
                CGPoint leftStartPoint = CGPointZero;
                if (PIX(startX-1, startY+1, 0)) {
                    leftStartPoint = CGPointMake(startX-1, startY+1);
                }
                CGPoint rightStartPoint = CGPointZero;
                if (PIX(startX+1, startY, 0) > 0) {
                    rightStartPoint = CGPointMake(startX+1, startY);
                } else if (PIX(startX, startY+1, 0) > 0) {
                    rightStartPoint = CGPointMake(startX, startY+1);
                } else if (PIX(startX+1, startY+1, 0) > 0) {
                    rightStartPoint = CGPointMake(startX+1, startY+1);
                }
                std::vector<CGPoint>* contour = new std::vector<CGPoint>;
                for (int right=0; right<2; right++) {
                    CGPoint p = right? rightStartPoint : leftStartPoint;
                    
                    std::vector<CGPoint> path;
                    while (!CGPointEqualToPoint(p, CGPointZero)) {
                        path.push_back(CGPointMake(p.x+portion.origin.x, p.y+portion.origin.y));
                        SETPIX(p.x, p.y, 0, 0);
                        CGPoint nextP = CGPointZero;
                        for (int tolerateDiagonal=0; tolerateDiagonal<2; tolerateDiagonal++) {
                            for (int dx=-1; dx<=1; dx++) {
                                for (int dy=-1; dy<=1; dy++) {
                                    if (!tolerateDiagonal && abs(dx) && abs(dy)) continue;
                                    if (PIX(p.x+dx, p.y+dy, 0) && CGPointEqualToPoint(nextP, CGPointZero)) {
                                        nextP = CGPointMake(p.x+dx, p.y+dy);
                                    }
                                }
                            }
                        }
                        p = nextP;
                    }
                    if (right) {
                        NSLog(@"right: %i", (int)path.size());
                        contour->insert(contour->end(), path.begin(), path.end());
                    } else {
                        NSLog(@"left: %i", (int)path.size());
                        contour->insert(contour->begin(), path.rbegin(), path.rend());
                    }
                }
                [contours addObject:[NSValue valueWithPointer:contour]];
            }
        }
    }
    IGImageDataRelease(imageData);
    return contours;
}*/
#pragma mark Point selection
-(void)addPointsToSelectionLine:(NSArray*)points {
    CGFloat scale = [UIScreen mainScreen].scale;
    CGSize imageSize = CGSizeMake(floorf(self.bounds.size.width*scale), floorf(self.bounds.size.height*scale));
    UIGraphicsBeginImageContext(imageSize);
    [_selectionOutlineView.image drawInRect:CGRectMake(0, 0, imageSize.width, imageSize.height)];
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    BOOL initial = YES;
    for (NSValue* p in points) {
        CGPoint point = p.CGPointValue;
        if (initial) {
            CGContextMoveToPoint(ctx, point.x*scale, point.y*scale);
            initial = NO;
        } else {
            CGContextAddLineToPoint(ctx, point.x*scale, point.y*scale);
        }
        [_selectionPath addLineToPoint:point];
    }
    CGContextStrokePath(ctx);
    UIImage* image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    _selectionOutlineView.image = image;
}
-(void)movedToPoint:(CGPoint)point {
    //[self addPointsToSelectionLine:@[[NSValue valueWithCGPoint:[self nearestEdgeToPoint:_lastTouchPoint tolerance:20]], [NSValue valueWithCGPoint:[self nearestEdgeToPoint:point tolerance:20]]]];
    CGPoint start = CGPointEqualToPoint(_lastEdgePoint, CGPointZero)? _lastTouchPoint : _lastEdgePoint;
    if (CGPointDistance(start, point) > 60) {
        [self addPointsToSelectionLine:@[[NSValue valueWithCGPoint:point]]];
        _lastEdgePoint = point;
    } else {
        NSArray* points = [SKImageExtractView pathFromPoint:start boundingAreaStart:_lastTouchPoint to:point radius:20 inImageOfSize:_imageView.bounds.size edgeImage:[self grayscaleEdgeImage]];
        [self addPointsToSelectionLine:points];
        
        _lastEdgePoint = [[points lastObject] CGPointValue];
    }
    _lastTouchPoint = point;
}
#pragma mark Touch handling
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    _lastEdgePoint = CGPointZero;
    _lastTouchPoint = [[touches anyObject] locationInView:self];
    _lastLineSegmentAngle = MAXFLOAT;
    _selectionOutlineView.image = nil;
    _selectionPath = [UIBezierPath new];
    [_selectionPath moveToPoint:_lastTouchPoint];
    
    _magnificationLoupe = [[SKMagnificationLoupe alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    _magnificationLoupe.center = CGPointMake(_lastTouchPoint.x, _lastTouchPoint.y-60);
    [self addSubview:_magnificationLoupe];
    _magnificationLoupe.alpha = 0;
    [_magnificationLoupe magnifyImages:@[_imageView.image] toSize:CGSizeMake(self.bounds.size.width*2, self.bounds.size.height*2) focusPoint:CGPointMake(_lastTouchPoint.x*2, _lastTouchPoint.y*2)];
    [UIView animateWithDuration:0.3 animations:^{
        _magnificationLoupe.alpha = 1;
    }];
}
-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    CGPoint point = [[touches anyObject] locationInView:self];
    //[self addPointsToSelectionLine:[self pointsByHuggingEdgesAlongLineFrom:_lastTouchPoint to:point withTolerance:20]];
    if (CGPointDistance(point, _lastTouchPoint) >= 30) {
        [self movedToPoint:point];
    }
    
    CGFloat magLoupeShiftAngle = -M_PI/2;
    _magnificationLoupe.center = CGPointShift(point, magLoupeShiftAngle, 60);
    /*if (CGPointAngleBetween(_lastTouchPoint, point) < -M_PI*0.2 && CGPointAngleBetween(_lastTouchPoint, point) > -M_PI*0.8) {
        magLoupeShiftAngle = 0;
    }
    [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
        [UIView setAnimationCurve:UIViewAnimationCurveLinear];
        _magnificationLoupe.center = CGPointShift(point, magLoupeShiftAngle, 60);
    } completion:nil];*/
    NSArray* toMagnify = _selectionOutlineView.image? @[_imageView.image, _selectionOutlineView.image] : @[_imageView.image];
    [_magnificationLoupe magnifyImages:toMagnify toSize:CGSizeMake(self.bounds.size.width*2, self.bounds.size.height*2) focusPoint:CGPointMake(point.x*2, point.y*2)];
}
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [self movedToPoint:[[touches anyObject] locationInView:self]];
    [UIView animateWithDuration:0.3 animations:^{
        _magnificationLoupe.alpha = 0;
    } completion:^(BOOL finished) {
        [_magnificationLoupe removeFromSuperview];
        _magnificationLoupe = nil;
    }];
    
    [_selectionPath closePath];
    UIImage* result = [self extractImageFromSelectionPath:_selectionPath];
    [self.delegate imageExtractView:self didExtractImage:result];
}
#pragma mark Extraction
-(UIImage*)maskImageFromSelectionPath:(UIBezierPath*)selectionPath {
    selectionPath = [selectionPath copy];
    [selectionPath applyTransform:CGAffineTransformMakeScale(1, -1)];
    UIGraphicsBeginImageContext(selectionPath.bounds.size);
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    CGContextConcatCTM(ctx, CGAffineTransformMakeTranslation(-selectionPath.bounds.origin.x, -selectionPath.bounds.origin.y));
    
    CGContextSetFillColorWithColor(ctx, [UIColor blackColor].CGColor);
    CGContextFillRect(ctx, selectionPath.bounds);
    
    CGContextAddPath(ctx, selectionPath.CGPath);
    CGContextSetFillColorWithColor(ctx, [UIColor whiteColor].CGColor);
    CGContextFillPath(ctx);
    
    UIImage* image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    ImageWrapper* imageWrapper = Image::createImage(image, image.size.width, image.size.height);
    imageWrapper = imageWrapper.image->gaussianBlur();
    
    return imageWrapper.image->toGrayscaleUIImage();
}
-(UIImage*)extractImageFromSelectionPath:(UIBezierPath*)selectionPath {
    UIGraphicsBeginImageContext(selectionPath.bounds.size);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextConcatCTM(ctx, CGAffineTransformMakeTranslation(selectionPath.bounds.origin.x*-1, selectionPath.bounds.origin.y*-1));
    CGContextClipToMask(ctx, selectionPath.bounds, [self maskImageFromSelectionPath:selectionPath].CGImage);
    //CGContextAddPath(ctx, selectionPath.CGPath);
    //CGContextClip(ctx);
    [_imageView.image drawInRect:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height)];
    UIImage* image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}
#pragma mark Interface
-(void)reset {
    _selectionOutlineView.image = nil;
}
/*class ContourEntry {
public:
    std::vector<CGPoint>* path;
    CGPoint closestPointToStart;
    CGPoint closestPointToEnd;
    ContourEntry(std::vector<CGPoint>* aPath, CGPoint startPoint, CGPoint endPoint) {
        path = aPath;
        closestPointToStart = aPath->at(0);
        closestPointToEnd = aPath->at(0);
        for (int i=1; i<aPath->size(); i++) {
            CGPoint p = aPath->at(i);
            if (CGPointDistance(p, startPoint) < CGPointDistance(closestPointToStart, startPoint)) {
                closestPointToStart = p;
            }
            if (CGPointDistance(p, endPoint) < CGPointDistance(closestPointToEnd, endPoint)) {
                closestPointToEnd = p;
            }
        }
    }
};

class ContourChain {
public:
    std::vector<ContourEntry*> entries;
    float cost(CGPoint startPoint, CGPoint endPoint) {
        float dist = 0;
        for (int i=0; i<entries.size(); i++) {
            ContourEntry* entry = entries.at(i);
            dist += CGPointDistance(startPoint, entry->closestPointToStart);
            startPoint = entry->closestPointToEnd;
        }
        return dist;
    };
    float heuristic(CGPoint endPoint) {
        return CGPointDistance(entries.at(entries.size()-1)->closestPointToEnd, endPoint);
    }
    ContourChain(ContourEntry* firstEntry) {
        entries.push_back(firstEntry);
    }
};

+(UIImage*)annotateEdges:(UIImage*)image {
    CGPoint start = CGPointMake(130, 157);
    CGPoint end = CGPointMake(135, 209);
    
#define TO_EDGE_SPACE(p) CGPointMake(p.x*edges.size.width/image.size.width, p.y*edges.size.height/image.size.height)
    
    ImageWrapper* wrapper = Image::createImage(image, image.size.width, image.size.height);
    wrapper.image->HistogramEqualisation();
    wrapper = wrapper.image->gaussianBlur().image->cannyEdgeExtract(0.3, 0.7);
    UIImage* edges = wrapper.image->toGrayscaleUIImage();
    //[UIImagePNGRepresentation(edges) writeToFile:@"/Users/nateparrott/Desktop/edgeimg.png" atomically:YES];
    NSArray* contours = [SKImageExtractView traceContoursInPortion:CGRectMake(120, 120, 100, 100) ofImage:edges];
    
    UIGraphicsBeginImageContext(edges.size);
    [edges drawInRect:CGRectMake(0, 0, edges.size.width, edges.size.height)];
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(ctx, [UIColor colorWithRed:1 green:0 blue:0 alpha:0.5].CGColor);
    CGContextSetLineWidth(ctx, 3);
    
    for (NSValue* vectorPtr in contours) {
        std::vector<CGPoint>* path = (std::vector<CGPoint>*)[vectorPtr pointerValue];
        if (path->size()) {
            CGContextMoveToPoint(ctx, path->at(0).x, path->at(0).y);
            for (int i=1; i<path->size(); i+=3) {
                CGContextAddLineToPoint(ctx, path->at(i).x, path->at(i).y);
            }
            CGContextStrokePath(ctx);
        }
        delete path;
    }
    
    UIImage* output = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return output;
}*/
#pragma mark Edge tracking

CGFloat CGPointDistanceFromLine(CGPoint p, CGPoint lineStart, CGPoint lineEnd) {
    p.x -= lineStart.x;
    p.y -= lineStart.y;
    lineEnd.x -= lineStart.x;
    lineEnd.y -= lineStart.y;
    lineStart = CGPointZero;
    p = CGPointApplyAffineTransform(p, CGAffineTransformMakeRotation(-atan2f(lineEnd.y, lineEnd.x)));
    lineEnd = CGPointApplyAffineTransform(lineEnd, CGAffineTransformMakeRotation(-atan2f(lineEnd.y, lineEnd.x)));
    float yDist = p.y;
    float xDist = 0;
    if (p.x > MAX(lineEnd.x, lineStart.x)) {
        xDist = p.x - MAX(lineEnd.x, lineStart.x);
    } else if (p.x < MIN(lineEnd.x, lineStart.x)) {
        xDist = MIN(lineEnd.x, lineStart.x) - p.x;
    }
    return sqrtf(powf(xDist, 2) + powf(yDist, 2));
}

typedef struct {
    short dx, dy;
    int cost;
} SKEdgeTraceEntry;

+(NSArray*)pathFromPoint:(CGPoint)start boundingAreaStart:(CGPoint)boundingAreaStart to:(CGPoint)end radius:(CGFloat)radius inImageOfSize:(CGSize)imageSize edgeImage:(UIImage*)edges {
#define TO_EDGE_SPACE(p) CGPointMake(p.x*edges.size.width/imageSize.width, p.y*edges.size.height/imageSize.height)
    
    float nonEdgePixelCost = 4;
    float edgePixelCost = 1;
    
    boundingAreaStart = TO_EDGE_SPACE(boundingAreaStart);
    start = TO_EDGE_SPACE(start);
    start = CGPointMake((int)start.x, (int)start.y);
    end = TO_EDGE_SPACE(end);
    end = CGPointMake((int)end.x, (int)end.y);
    
    CGPoint finishLineStart = CGPointShift(end, CGPointAngleBetween(boundingAreaStart, end)+M_PI/2, radius);
    CGPoint finishLineEnd = CGPointShift(end, CGPointAngleBetween(boundingAreaStart, end)-M_PI/2, radius);
    
    CGRect rect;
    rect.origin.x = (int)MAX(0, MIN(boundingAreaStart.x-radius, end.x-radius));
    rect.origin.y = (int)MAX(0, MIN(boundingAreaStart.y-radius, end.y-radius));
    rect.size.width = (int)(MIN(edges.size.width, MAX(boundingAreaStart.x+radius, end.x+radius)) - rect.origin.x);
    rect.size.height = (int)(MIN(edges.size.height, MAX(boundingAreaStart.y+radius, end.y+radius)) - rect.origin.y);
    
#define GRID_POINT(xcoord,ycoord) traceGrid[(int)((ycoord-rect.origin.y)*rect.size.width + xcoord-rect.origin.x)]
#define IS_POINT_EDGE(xcoord,ycoord) ( edgeData->data[4*(int)((ycoord-rect.origin.y)*rect.size.width + xcoord-rect.origin.x)] == 0 )
    
    SKEdgeTraceEntry* traceGrid = new SKEdgeTraceEntry[(int)(rect.size.width*rect.size.height)];
    memset(traceGrid, 0, sizeof(SKEdgeTraceEntry)*(int)(rect.size.width*rect.size.height));
    IGImageData* edgeData = [edges imageDataForSubImage:rect];
    
    NSMutableSet* frontierPoints = [NSMutableSet new];
    [frontierPoints addObject:[NSValue valueWithCGPoint:start]];
    
    CGPoint foundPoint = CGPointZero;
    while (CGPointEqualToPoint(foundPoint, CGPointZero)) {
        CGPoint bestPoint;
        float bestPointScore = MAXFLOAT;
        for (NSValue* v in frontierPoints) {
            CGPoint p = v.CGPointValue;
            float score = GRID_POINT(p.x, p.y).cost * CGPointDistanceFromLine(p, finishLineStart, finishLineEnd) * edgePixelCost;
            if (score < bestPointScore) {
                bestPoint = p;
                bestPointScore = score;
            }
        }
        if (bestPointScore==MAXFLOAT) {
            // for whatever reason, we've failed
            CGPoint point = end;
            CGPoint imagePoint = CGPointMake(point.x * imageSize.width/edges.size.width, point.y * imageSize.height/imageSize.height);

            return @[[NSValue valueWithCGPoint:imagePoint]];
        }
        [frontierPoints removeObject:[NSValue valueWithCGPoint:bestPoint]];
        for (int dx=-1; dx<=1; dx++) {
            for (int dy=-1; dy<=1; dy++) {
                if (dx==0 && dy==0) continue;
                CGPoint p = CGPointMake(bestPoint.x+dx, bestPoint.y+dy);
                if (!CGRectContainsPoint(rect, p)) {
                    continue;
                }
                if (CGPointDistanceFromLine(p, finishLineStart, finishLineEnd) <= 2) {
                    foundPoint = p;
                }
                SKEdgeTraceEntry* entry = &(GRID_POINT(p.x, p.y));
                if (entry->dx==0 && entry->dy==0) {
                    entry->dx = dx;
                    entry->dy = dy;
                    entry->cost = GRID_POINT(bestPoint.x, bestPoint.y).cost + ( IS_POINT_EDGE(p.x, p.y)? edgePixelCost : nonEdgePixelCost );
                    [frontierPoints addObject:[NSValue valueWithCGPoint:CGPointMake(p.x, p.y)]];
                }
            }
        }
    }
    
    NSMutableArray* backwardsPath = [NSMutableArray new];
    CGPoint p = foundPoint;
    while (!CGPointEqualToPoint(start, p)) {
        [backwardsPath addObject:[NSValue valueWithCGPoint:p]];
        SKEdgeTraceEntry entry = GRID_POINT(p.x, p.y);
        p.x -= entry.dx;
        p.y -= entry.dy;
    }
    
    delete traceGrid;
    IGImageDataRelease(edgeData);
    
    NSMutableArray* forwardPath = [NSMutableArray arrayWithCapacity:backwardsPath.count];
    for (NSValue* point in backwardsPath.reverseObjectEnumerator) {
        CGPoint imagePoint = CGPointMake(point.CGPointValue.x * imageSize.width/edges.size.width, point.CGPointValue.y * imageSize.height/imageSize.height);
        [forwardPath addObject:[NSValue valueWithCGPoint:imagePoint]];
    }
    return forwardPath;
}

#pragma mark Testing

/*
+(NSArray*)pathFromPoint:(CGPoint)start to:(CGPoint)end inImage:(UIImage*)image radius:(CGFloat)radius {
    
    ImageWrapper* wrapper = Image::createImage(image, image.size.width, image.size.height);
    wrapper.image->HistogramEqualisation();
    wrapper = wrapper.image->gaussianBlur().image->cannyEdgeExtract(0.3, 0.7);
    UIImage* edges = wrapper.image->toGrayscaleUIImage();
    return [SKImageExtractView pathFromPoint:start to:end radius:radius inImageOfSize:image.size edgeImage:edges];
}*/

@end
