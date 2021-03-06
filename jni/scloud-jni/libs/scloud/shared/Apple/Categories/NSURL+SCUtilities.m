/*
Copyright © 2012-2013, Silent Circle, LLC.  All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:
    * Any redistribution, use, or modification is done solely for personal 
      benefit and not for any commercial purpose or for monetary gain
    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name Silent Circle nor the
      names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL SILENT CIRCLE, LLC BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/
//
//  NSURL+SCUtilities.m
//  SilentText
//

#import "NSURL+SCUtilities.h"
#import "UIImage+Thumbnail.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <AVFoundation/AVFoundation.h>

@implementation NSURL (SCUtilities)

static const CGFloat kThumbNailWidth = 112.5;
static const CGFloat kThumbNailHeight = 150;


-(UIImage*) movieImage
{
    UIImage* thumbnail = NULL;
    
    NSString *extension = [self.absoluteString pathExtension];
    if(extension)
    {
        CFStringRef mediaType =   UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension,
                                                                        (__bridge CFStringRef) extension,
                                                                        NULL);
        if(UTTypeConformsTo( mediaType, kUTTypeMovie))
        {
            AVAsset *asset = [AVAsset assetWithURL:self];
            AVAssetImageGenerator *gen = [[AVAssetImageGenerator alloc] initWithAsset:asset];
            gen.appliesPreferredTrackTransform = YES;
            CMTime time = CMTimeMakeWithSeconds(0.0, 600);
            NSError *error = nil;
            CMTime actualTime;
            
            CGImageRef image = [gen copyCGImageAtTime:time actualTime:&actualTime error:&error];
            
            
            thumbnail = [UIImage imageWithCGImage:image];
             CGImageRelease(image);
            
        }
        
        CFRelease(mediaType);
    }
    
    return thumbnail;
}

            
#warning finish this code for ST173_BUG

#if 0

-(UIImage*) movieImageForSize:(CGSize) theSize
{
    UIImage* thumbnail = NULL;
    
    NSString *extension = [self.absoluteString pathExtension];
    if(extension)
    {
        CFStringRef mediaType =   UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension,
                                                                        (__bridge CFStringRef) extension,
                                                                        NULL);
        if(UTTypeConformsTo( mediaType, kUTTypeMovie))
        {
            AVAsset *asset = [AVAsset assetWithURL:self];
            AVAssetImageGenerator *gen = [[AVAssetImageGenerator alloc] initWithAsset:asset];
            gen.appliesPreferredTrackTransform = YES;
            CMTime time = CMTimeMakeWithSeconds(0.0, 600);
            NSError *error = nil;
            CMTime actualTime;
            
            CGImageRef image = [gen copyCGImageAtTime:time actualTime:&actualTime error:&error];
          
            UIInterfaceOrientation orientation = UIInterfaceOrientationPortrait;
            
            AVAssetTrack *videoTrack = [[asset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
            CGSize size = [videoTrack naturalSize];
            CGAffineTransform txf = [videoTrack preferredTransform];
            
            if (size.width == txf.tx && size.height == txf.ty)
                orientation =  UIInterfaceOrientationLandscapeRight;
            else if (txf.tx == 0 && txf.ty == 0)
                orientation =  UIInterfaceOrientationLandscapeLeft;
            else if (txf.tx == 0 && txf.ty == size.width)
                orientation =  UIInterfaceOrientationPortraitUpsideDown;
            
            thumbnail =  [UIImage imageWithCGImage:image];
            
    //        thumbnail = [[UIImage imageWithCGImage:image] scaledToHeight:theSize.height];
            
  /*          if((orientation == UIInterfaceOrientationPortrait)
               || (orientation == UIInterfaceOrientationPortraitUpsideDown))
            {
                thumbnail = [[UIImage imageWithCGImage:image] scaledToHeight:theSize.height];
            }
            else if((orientation == UIInterfaceOrientationLandscapeRight)
                    || (orientation == UIInterfaceOrientationLandscapeLeft))
            {
                thumbnail = [[UIImage imageWithCGImage:image] scaledToWidth:theSize.width];
            }
            
  
            UIImage* playback = [UIImage imageNamed:@"playback.png"];
            
               
            size_t width = theSize.width;
            size_t height =  theSize.height;
            
            UIGraphicsBeginImageContext(CGSizeMake(width, height));
            
            [thumbnail drawAtPoint:CGPointZero];
            
    //        [playback  drawInRect:CGRectMake(width/2 - playback.size.width/2 , height/2 - playback.size.height/2, 200, 200)];
            
   //         thumbnail = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
      */
          CGImageRelease(image);
            
        }
        
        CFRelease(mediaType);
      }
    
    return thumbnail;
}

#endif

-(UIImage*) thumbNail
{
    UIImage* thumbnail = NULL;
      
    NSString *extension = [self.absoluteString pathExtension];
    if(extension)
    {
        CFStringRef mediaType =   UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension,
                                                                                         (__bridge CFStringRef) extension,
                                                                                         NULL);
        
        if(UTTypeConformsTo(  mediaType, kUTTypePDF))
        {
            CGPDFDocumentRef pdf = CGPDFDocumentCreateWithURL((__bridge CFURLRef)self);
            if(pdf)
            {
                CGPDFPageRef  page = CGPDFDocumentGetPage(pdf, 1);
                if(page)
                {
                    CGRect pageSize = CGPDFPageGetBoxRect(page, kCGPDFMediaBox);
                    CGRect thumbRect = {0,0,0,0};
                    
                    if(pageSize.size.height > pageSize.size.width)
                    {
                        float oldHeight = pageSize.size.height;
                        float scaleFactor = kThumbNailHeight / oldHeight;
                        
                        float newWidth = pageSize.size.width * scaleFactor;
                        float newHeight = oldHeight * scaleFactor;
                        
                        thumbRect.size = CGSizeMake(newWidth,newHeight);
                    }
                    else
                    {
                        float oldWidth = pageSize.size.width;
                        float scaleFactor = kThumbNailHeight / oldWidth;
                        
                        float newHeight = pageSize.size.height * scaleFactor;
                        float newWidth = oldWidth * scaleFactor;
                        
                        thumbRect.size = CGSizeMake(newWidth,newHeight);
                    }
                    
                    UIGraphicsBeginImageContext(thumbRect.size);
                    CGContextRef context = UIGraphicsGetCurrentContext();
                    
                    CGContextSaveGState(context);
                    CGContextTranslateCTM(context, 0.0, thumbRect.size.height);
                    CGContextScaleCTM(context, 1.0, -1.0);
                    
                    CGContextSetGrayFillColor(context, 1.0, 1.0);
                    CGContextFillRect(context, thumbRect);
                    
                    CGAffineTransform pdfTransform = CGPDFPageGetDrawingTransform(page, kCGPDFMediaBox, thumbRect, 0, true);
                    // And apply the transform.
                    CGContextConcatCTM(context, pdfTransform);
                    CGContextDrawPDFPage(context, page);
                    
                    // Create the new UIImage from the context
                    thumbnail = UIGraphicsGetImageFromCurrentImageContext();
                    
                    CGContextRestoreGState(context);
                    
                }
            }
            CGPDFDocumentRelease(pdf);
        }
        else if(UTTypeConformsTo( mediaType, kUTTypeImage))
        {
            UIImage* image = [UIImage imageWithData:[NSData dataWithContentsOfURL:self]];
             
            if(image.size.height > image.size.width)
                thumbnail = [image scaledToHeight:kThumbNailHeight];
            else
                thumbnail = [image scaledToWidth:kThumbNailHeight];
        }
        else if(UTTypeConformsTo( mediaType, kUTTypeAudio))
        {
             
            NSTimeInterval duration;
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"mm:ss"];
          
            NSError *error;
            AVAudioPlayer* avAudioPlayer = [[AVAudioPlayer alloc]initWithContentsOfURL:self error:&error];
            
            duration = avAudioPlayer.duration;
            avAudioPlayer = nil;
            
            NSString* durationString = [formatter stringFromDate:[NSDate dateWithTimeIntervalSince1970: duration]];
            
            thumbnail = [UIImage imageNamed: @"vmemo70"] ;
            thumbnail = [thumbnail imageWithBadgeOverlay:NULL text:durationString textColor:[UIColor whiteColor]];
        }
        else if(UTTypeConformsTo( mediaType, kUTTypeMovie))
        {
            AVAsset *asset = [AVAsset assetWithURL:self];
            AVAssetImageGenerator *gen = [[AVAssetImageGenerator alloc] initWithAsset:asset];
            gen.appliesPreferredTrackTransform = YES;
            CMTime time = CMTimeMakeWithSeconds(0.0, 600);
            NSError *error = nil;
            CMTime actualTime;
            
            CGImageRef image = [gen copyCGImageAtTime:time actualTime:&actualTime error:&error];
            
            UIInterfaceOrientation orientation = UIInterfaceOrientationPortrait;
            
            AVAssetTrack *videoTrack = [[asset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
            CGSize size = [videoTrack naturalSize];
            CGAffineTransform txf = [videoTrack preferredTransform];
            
            if (size.width == txf.tx && size.height == txf.ty)
                orientation =  UIInterfaceOrientationLandscapeRight;
            else if (txf.tx == 0 && txf.ty == 0)
                orientation =  UIInterfaceOrientationLandscapeLeft;
            else if (txf.tx == 0 && txf.ty == size.width)
                orientation =  UIInterfaceOrientationPortraitUpsideDown;
            
            if((orientation == UIInterfaceOrientationPortrait)
               || (orientation == UIInterfaceOrientationPortraitUpsideDown))
            {
                thumbnail = [[UIImage imageWithCGImage:image] scaledToHeight:kThumbNailHeight];
            }
            else if((orientation == UIInterfaceOrientationLandscapeRight)
                    || (orientation == UIInterfaceOrientationLandscapeLeft))
            {
                thumbnail = [[UIImage imageWithCGImage:image] scaledToWidth:kThumbNailHeight];
            }
            
            
            CGImageRelease(image);
            
            NSTimeInterval durationSeconds = CMTimeGetSeconds([asset duration]);
            
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"mm:ss"];
            
            NSString* durationString = [formatter stringFromDate:
                                        [NSDate dateWithTimeIntervalSince1970:durationSeconds]];
            
            thumbnail = [thumbnail imageWithBadgeOverlay:[UIImage imageNamed:@"movie.png"] text:durationString  textColor:[UIColor whiteColor] ];
        }
        
        CFRelease(mediaType);
    }
    
    // last attempt let UIDocumentInteractionController try
    if(!thumbnail)
    {
        UIDocumentInteractionController *doc =   [UIDocumentInteractionController interactionControllerWithURL:self];
        NSArray *icons = doc.icons;
        thumbnail =  [[[icons lastObject] copy] scaledToWidth: kThumbNailWidth];
        doc = NULL;
        
    }
    
    return thumbnail;
    
}
@end
