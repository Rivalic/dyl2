#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

// External function to trigger device rotation
extern void rotateDeviceIdentifiers(void);

@interface FloatingRotateButton : UIButton
@property (nonatomic, assign) CGPoint lastLocation;
@end

@implementation FloatingRotateButton

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup {
    // Button styling
    self.backgroundColor = [[UIColor orangeColor] colorWithAlphaComponent:0.85];
    self.layer.cornerRadius = 30;
    self.layer.shadowColor = [UIColor blackColor].CGColor;
    self.layer.shadowOffset = CGSizeMake(0, 2);
    self.layer.shadowRadius = 4;
    self.layer.shadowOpacity = 0.3;
    
    // Icon/Text
    [self setTitle:@"🔄" forState:UIControlStateNormal];
    self.titleLabel.font = [UIFont systemFontOfSize:30];
    
    // Add tap action
    [self addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    // Make draggable
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    [self addGestureRecognizer:pan];
}

- (void)buttonTapped:(UIButton *)sender {
    NSLog(@"[FloatingButton] Rotate button tapped!");
    
    // Visual feedback - pulse animation
    [UIView animateWithDuration:0.1 animations:^{
        self.transform = CGAffineTransformMakeScale(0.9, 0.9);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.1 animations:^{
            self.transform = CGAffineTransformIdentity;
        }];
    }];
    
    // Trigger device rotation
    rotateDeviceIdentifiers();
    
    // Show success alert
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self showSuccessAnimation];
    });
}

- (void)showSuccessAnimation {
    // Spin animation to indicate success
    CABasicAnimation *rotation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotation.toValue = @(M_PI * 2);
    rotation.duration = 0.5;
    rotation.cumulative = YES;
    rotation.repeatCount = 1;
    [self.layer addAnimation:rotation forKey:@"rotationAnimation"];
    
    // Brief color change
    UIColor *originalColor = self.backgroundColor;
    [UIView animateWithDuration:0.3 animations:^{
        self.backgroundColor = [[UIColor greenColor] colorWithAlphaComponent:0.85];
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.3 animations:^{
            self.backgroundColor = originalColor;
        }];
    }];
}

- (void)handlePan:(UIPanGestureRecognizer *)recognizer {
    CGPoint translation = [recognizer translationInView:self.superview];
    
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        self.lastLocation = self.center;
    }
    
    if (recognizer.state == UIGestureRecognizerStateChanged) {
        self.center = CGPointMake(self.lastLocation.x + translation.x,
                                  self.lastLocation.y + translation.y);
    }
    
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        // Snap to edges
        CGRect bounds = self.superview.bounds;
        CGFloat padding = 20;
        CGPoint newCenter = self.center;
        
        // Keep within bounds
        if (newCenter.x < padding + self.bounds.size.width / 2) {
            newCenter.x = padding + self.bounds.size.width / 2;
        } else if (newCenter.x > bounds.size.width - padding - self.bounds.size.width / 2) {
            newCenter.x = bounds.size.width - padding - self.bounds.size.width / 2;
        }
        
        if (newCenter.y < padding + self.bounds.size.height / 2) {
            newCenter.y = padding + self.bounds.size.height / 2;
        } else if (newCenter.y > bounds.size.height - padding - self.bounds.size.height / 2) {
            newCenter.y = bounds.size.height - padding - self.bounds.size.height / 2;
        }
        
        [UIView animateWithDuration:0.3 animations:^{
            self.center = newCenter;
        }];
    }
}

@end

// Inject floating button into key window
__attribute__((constructor))
static void initializeFloatingButton() {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSLog(@"[FloatingButton] Initializing floating rotate button...");
        
        UIWindow *keyWindow = nil;
        for (UIWindow *window in [UIApplication sharedApplication].windows) {
            if (window.isKeyWindow) {
                keyWindow = window;
                break;
            }
        }
        
        if (!keyWindow) {
            keyWindow = [[UIApplication sharedApplication].windows firstObject];
        }
        
        if (keyWindow) {
            // Position in top-left safe zone
            CGFloat buttonSize = 60;
            CGFloat topPadding = 60; // Below status bar/notch
            CGFloat leftPadding = 20;
            
            FloatingRotateButton *button = [[FloatingRotateButton alloc] initWithFrame:CGRectMake(leftPadding, topPadding, buttonSize, buttonSize)];
            button.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin;
            
            [keyWindow addSubview:button];
            
            // Bring to front
            [keyWindow bringSubviewToFront:button];
            
            NSLog(@"[FloatingButton] Floating button added to window!");
        } else {
            NSLog(@"[FloatingButton] ERROR: Could not find key window!");
        }
    });
}
