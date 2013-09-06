//
//  IGImageData.c
//  iOSplusOpenCV
//
//  Created by Nate Parrott on 9/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#include "IGImageData.h"
#include <stdlib.h>

void IGImageDataRelease(IGImageData* data) {
    free(data->data);
    free(data);
}

float IGImageDataAverageBrightnessForSubrect(IGImageData* data, int x, int y, int w, int h) {
    int chunkSize = 100;
    int totalPixels = w*h*3;
    
    float runningAverage = 0;
    int i = 0;
    int acc = 0;
    for (int row=y; row<y+h; row++) {
        for (int col=x; col<x+w; col++) {
            for (int p=0; p<3; p++) {
                unsigned char pix = data->data[4*(row*data->w + col)+p];
                acc += pix;
                
                i++;
                if (i==chunkSize) {
                    float chunkAvg = acc * 1.0 / chunkSize;
                    runningAverage += chunkAvg * chunkSize * 1.0 / totalPixels;
                    acc = 0;
                    i = 0;
                }
            }
        }
    }
    float remainingAvg = acc * 1.0 / i;
    runningAverage += remainingAvg * i * 1.0 / totalPixels;
    
    return runningAverage;
}
IGImageData* IGImageDataFromSubrect(IGImageData* original, int x, int y, int w, int h) {
    IGImageData* new = malloc(sizeof(IGImageData));
    new->w = w;
    new->h = h;
    new->data = malloc(4*w*h);
    for (int targetx=0; targetx<w; targetx++) {
        for (int targety=0; targety<h; targety++) {
            for (int i=0; i<4; i++) {
                new->data[4*(targety*w + targetx) + i] = original->data[4*((targety+y)*original->w + targetx+x) + i];
            }
        }
    }
    return new;
}
