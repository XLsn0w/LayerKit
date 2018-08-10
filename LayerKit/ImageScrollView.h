

#import <UIKit/UIKit.h>

@class TiledImageView;

@interface ImageScrollView : UIScrollView <UIScrollViewDelegate> {
	// The TiledImageView that is currently front most
	TiledImageView* frontTiledView;
	// The old TiledImageView that we draw on top of when the zooming stops
	TiledImageView* backTiledView;	
	// A low res version of the image that is displayed until the TiledImageView
	// renders its content.
	UIImageView *backgroundImageView;
    float minimumScale;
	// current image zoom scale
	CGFloat imageScale;
    UIImage* image;
}
@property (retain) UIImage* image;
@property (retain) TiledImageView* backTiledView;	

- (instancetype)initWithFrame:(CGRect)frame image:(UIImage*)image;

@end
