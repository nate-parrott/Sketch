//
//  IGImageData.h
//  iOSplusOpenCV
//
//  Created by Nate Parrott on 9/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#ifndef iOSplusOpenCV_IGImageData_h
#define iOSplusOpenCV_IGImageData_h

#ifdef __cplusplus
extern "C" {
#endif

// RGBA
typedef struct {
    int w, h;
    unsigned char* data;
} IGImageData;

void IGImageDataRelease(IGImageData* data);
float IGImageDataAverageBrightnessForSubrect(IGImageData* data, int x, int y, int w, int h);
IGImageData* IGImageDataFromSubrect(IGImageData* original, int x, int y, int w, int h);

#ifdef __cplusplus
}
#endif

#endif
