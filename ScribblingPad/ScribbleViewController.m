//
//  ScribbleViewController.m
//  ScribblingPad
//
//  Created by Raghav Sai Cheedalla on 7/18/15.
//  Copyright (c) 2015 Raghav Sai Cheedalla. All rights reserved.
//

#import "ScribbleViewController.h"
#import "ScribbleView.h"

@interface ScribbleViewController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet ScribbleView   *scribblingView;
@property (nonatomic, strong) UIButton              *leftButton;

@property BOOL                                      leftButtonToggle;

@end

@implementation ScribbleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupNavBar];
}

#pragma mark - UI design methods
// This method is responsible for setting up the navigation bar
- (void)setupNavBar
{
    [self setupRightBarNavigation];
    [self setupLeftBarNavigation];
}


- (void)setupRightBarNavigation
{
    UIBarButtonItem *barButtonItemSave = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveToPhotoRoll)];
    UIButton *rightbutton = [self setupRightButton];
    UIBarButtonItem *barButtonItemImage = [[UIBarButtonItem alloc] initWithCustomView:rightbutton];
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:barButtonItemSave,barButtonItemImage, nil];
}

- (void)setupLeftBarNavigation
{
    UIBarButtonItem *barButtonItemClear = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(clear)];
    
    [self setupLeftButton];
    UIBarButtonItem *barButtonItemErase = [[UIBarButtonItem alloc] initWithCustomView:self.leftButton];
    self.navigationItem.leftBarButtonItems = [NSArray arrayWithObjects:barButtonItemClear,barButtonItemErase, nil];
    self.leftButtonToggle = YES;
}

- (void)setupLeftButton
{
    self.leftButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.leftButton setFrame:CGRectMake(0, 0, 60, 60)];
    [self.leftButton setTintColor:[UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0]];
    [self.leftButton setTitle:@"Erase" forState:UIControlStateNormal];
    [self.leftButton addTarget:self action:@selector(erase) forControlEvents:UIControlEventTouchUpInside];
}

- (UIButton *)setupRightButton
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    [button setFrame:CGRectMake(0, 0, 60, 60)];
    [button setTintColor:[UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0]];
    [button setTitle:@"Image" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(imagePick) forControlEvents:UIControlEventTouchUpInside];
    return button;
}


#pragma mark - Utility methods
- (void)saveToPhotoRoll
{
    UIImage *imageToBeSaved = [self getImageFromView];
    UIImageWriteToSavedPhotosAlbum(imageToBeSaved, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
}

- (void)clear
{
    [self.scribblingView clearView];
    
}

- (void)erase
{
    [self.scribblingView activateErase];
    if(self.leftButtonToggle)
    {
        [self.leftButton setTitle:@"Pen" forState:UIControlStateNormal];
        self.leftButtonToggle = NO;
    }
    else
    {
        [self.leftButton setTitle:@"Erase" forState:UIControlStateNormal];
        self.leftButtonToggle = YES;
    }
}

- (UIImage *)getImageFromView
{
    UIGraphicsBeginImageContext(self.scribblingView.bounds.size);
    [self.scribblingView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    image = [self convertImageToPNG:image];
    return image;
}

- (UIImage *)convertImageToPNG:(UIImage *)image
{
    NSData *imageData = UIImagePNGRepresentation(image);
    return [UIImage imageWithData:imageData];
}


- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo: (void *) contextInfo
{
    if(!error)
    {
        NSLog(@"image saved to camera roll");
    }
}

- (void)imagePick
{
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    imagePickerController.delegate = self;
    [self presentViewController:imagePickerController animated:YES completion:nil];
}

#pragma mark - UIImagePickerControllerDelegate methods
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    self.scribblingView.imageToBeDisplayed = [info valueForKey:UIImagePickerControllerOriginalImage];
    [self.scribblingView  clearView];
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
