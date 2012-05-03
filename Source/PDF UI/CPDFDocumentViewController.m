//
//  PDFReaderViewController.m
//  PDFReader
//
//  Created by Jonathan Wight on 02/19/11.
//  Copyright 2011 toxicsoftware.com. All rights reserved.
//

#import "CPDFDocumentViewController.h"

#import "CPDFDocument.h"
#import "CPDFPageViewController.h"
#import "CPDFPage.h"
#import "CPreviewBar.h"
#import "CPDFPageView.h"
#import "CContentScrollView.h"
#import <QuartzCore/QuartzCore.h>

@interface CPDFDocumentViewController () <CPDFDocumentDelegate, UIPageViewControllerDelegate, UIPageViewControllerDataSource, UIGestureRecognizerDelegate, CPreviewBarDelegate>

@property (readwrite, nonatomic, strong) UIPageViewController *pageViewController;
@property (readwrite, nonatomic, strong) IBOutlet CPreviewBar *previewBar;
@end

@implementation CPDFDocumentViewController

@synthesize document = _document;

- (id)initWithDocument:(CPDFDocument *)inDocument
    {
    if ((self = [super initWithNibName:@"CPDFDocumentViewController" bundle:NULL]) != NULL)
        {
        _document = inDocument;
        _document.delegate = self;
        }
    return(self);
    }

- (id)initWithURL:(NSURL *)inURL;
    {
    CPDFDocument *theDocument = [[CPDFDocument alloc] initWithURL:inURL];
    return([self initWithDocument:theDocument]);
    }

- (void)didReceiveMemoryWarning
    {
    [super didReceiveMemoryWarning];
    }

#pragma mark - View lifecycle

- (void)viewDidLoad
    {
    [super viewDidLoad];

    self.title = self.document.title;

    self.previewBar.delegate = self;
    [self.previewBar sizeToFit];

    UIPageViewControllerSpineLocation theSpineLocation = UIPageViewControllerSpineLocationMin;
    if (_document.numberOfPages > 1 && UIInterfaceOrientationIsLandscape([UIDevice currentDevice].orientation))
        {
        theSpineLocation = UIPageViewControllerSpineLocationMid;
        }
    NSDictionary *theOptions = [NSDictionary dictionaryWithObjectsAndKeys:
        [NSNumber numberWithInt:theSpineLocation], UIPageViewControllerOptionSpineLocationKey,
        NULL];

    self.pageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStylePageCurl navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:theOptions];
    self.pageViewController.delegate = self;
    self.pageViewController.dataSource = self;
    [self addChildViewController:self.pageViewController];
    self.pageViewController.view.frame = self.view.bounds;
    [self.view insertSubview:self.pageViewController.view atIndex:0];

    NSMutableArray *theViewControllers = [NSMutableArray arrayWithObjects:
        [[CPDFPageViewController alloc] initWithPage:[_document pageForPageNumber:1]],
        NULL
        ];
    if (self.pageViewController.spineLocation == UIPageViewControllerSpineLocationMid)
        {
        [theViewControllers addObject:
            [[CPDFPageViewController alloc] initWithPage:[_document pageForPageNumber:2]]
            ];
        }
    [self.pageViewController setViewControllers:theViewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:NULL];

    UITapGestureRecognizer *theTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
    [self.view addGestureRecognizer:theTapGestureRecognizer];
    }

- (void)viewDidUnload
    {
    [super viewDidUnload];
    }

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
    {
    return(YES);
    }

- (void)tap:(UITapGestureRecognizer *)inRecognizer
    {
    BOOL theFlag = !self.navigationController.navigationBarHidden;

    [UIView animateWithDuration:UINavigationControllerHideShowBarDuration animations:^{
        [self.navigationController setNavigationBarHidden:theFlag animated:YES];
        self.previewBar.alpha = (1.0 - theFlag);
        } completion:^(BOOL finished) {
        }];
    }

- (IBAction)gotoPage:(id)sender
    {
    NSUInteger thePageNumber = self.previewBar.selectedPreviewIndex + 1;

    NSMutableArray *theViewControllers = [NSMutableArray arrayWithObjects:
        [[CPDFPageViewController alloc] initWithPage:[_document pageForPageNumber:thePageNumber]],
        NULL
        ];
    if (self.pageViewController.spineLocation == UIPageViewControllerSpineLocationMid)
        {
        [theViewControllers addObject:
            [[CPDFPageViewController alloc] initWithPage:[_document pageForPageNumber:thePageNumber + 1]]
            ];
        }
    [self.pageViewController setViewControllers:theViewControllers direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:NULL];
    }

#pragma mark -

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
    {
    CPDFPageViewController *theViewController = (CPDFPageViewController *)viewController;

    NSUInteger theNextPageNumber = theViewController.page.pageNumber - 1;
    if (theNextPageNumber < 1 || theNextPageNumber > self.document.numberOfPages)
        {
        return(NULL);
        }

    CPDFPage *thePage = [self.document pageForPageNumber:theNextPageNumber];
    theViewController = [[CPDFPageViewController alloc] initWithPage:thePage];

    return(theViewController);
    }

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
    {
    CPDFPageViewController *theViewController = (CPDFPageViewController *)viewController;

    NSUInteger theNextPageNumber = theViewController.page.pageNumber + 1;
    if (theNextPageNumber < 1 || theNextPageNumber > self.document.numberOfPages)
        {
        return(NULL);
        }

    CPDFPage *thePage = [self.document pageForPageNumber:theNextPageNumber];
    theViewController = [[CPDFPageViewController alloc] initWithPage:thePage];

    return(theViewController);
    }

#pragma mark -

- (UIPageViewControllerSpineLocation)pageViewController:(UIPageViewController *)pageViewController spineLocationForInterfaceOrientation:(UIInterfaceOrientation)orientation;
    {
    UIPageViewControllerSpineLocation theSpineLocation;
    NSArray *theViewControllers = NULL;

	if (UIInterfaceOrientationIsPortrait(orientation) || self.document.numberOfPages == 1)
        {
		theSpineLocation = UIPageViewControllerSpineLocationMin;

		UIViewController *currentViewController = [self.pageViewController.viewControllers objectAtIndex:0];
		theViewControllers = [NSArray arrayWithObject:currentViewController];
        }
    else
        {
        theSpineLocation = UIPageViewControllerSpineLocationMid;

        CPDFPageViewController *currentViewController = [self.pageViewController.viewControllers objectAtIndex:0];

        NSUInteger indexOfCurrentViewController = currentViewController.page.pageNumber - 1;
        if (indexOfCurrentViewController == 0 || indexOfCurrentViewController % 2 == 0)
            {
            UIViewController *nextViewController = [self pageViewController:self.pageViewController viewControllerAfterViewController:currentViewController];
            theViewControllers = [NSArray arrayWithObjects:currentViewController, nextViewController, nil];
            }
        else
            {
            UIViewController *previousViewController = [self pageViewController:self.pageViewController viewControllerBeforeViewController:currentViewController];
            theViewControllers = [NSArray arrayWithObjects:previousViewController, currentViewController, nil];
            }
        }

//    NSLog(@"%d %@", theSpineLocation, theViewControllers);

    [self.pageViewController setViewControllers:theViewControllers direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:NULL];
    return(theSpineLocation);
    }

#pragma mark -

- (NSInteger)numberOfPreviewsInPreviewBar:(CPreviewBar *)inPreviewBar
    {
    return(self.document.numberOfPages);
    }

- (UIImage *)previewBar:(CPreviewBar *)inPreviewBar previewAtIndex:(NSInteger)inIndex;
    {
    UIImage *theImage = [self.document pageForPageNumber:inIndex + 1].thumbnail;
    return(theImage);
    }

#pragma mark -

- (void)PDFDocument:(CPDFDocument *)inDocument didUpdateThumbnailForPage:(CPDFPage *)inPage
    {
    [self.previewBar updatePreviewAtIndex:inPage.pageNumber - 1];
    }

@end