//
//  CLibraryViewController.m
//  iOS-PDF-Reader
//
//  Created by Jonathan Wight on 05/31/11.
//  Copyright 2012 Jonathan Wight. All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without modification, are
//  permitted provided that the following conditions are met:
//
//     1. Redistributions of source code must retain the above copyright notice, this list of
//        conditions and the following disclaimer.
//
//     2. Redistributions in binary form must reproduce the above copyright notice, this list
//        of conditions and the following disclaimer in the documentation and/or other materials
//        provided with the distribution.
//
//  THIS SOFTWARE IS PROVIDED BY JONATHAN WIGHT ``AS IS'' AND ANY EXPRESS OR IMPLIED
//  WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
//  FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL JONATHAN WIGHT OR
//  CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
//  CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
//  SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
//  ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
//  NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
//  ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//
//  The views and conclusions contained in the software and documentation are those of the
//  authors and should not be interpreted as representing official policies, either expressed
//  or implied, of Jonathan Wight.

#import "CLibraryCollectionViewController.h"

#import "CPDFDocumentPageViewController.h"
#import "NSFileManager_BugFixExtensions.h"
#import "CPDFDocument.h"
#import "CLibrary.h"
#import "CPreviewCollectionViewCell.h"

@interface CLibraryCollectionViewController ()
@end

#pragma mark -

@implementation CLibraryCollectionViewController

- (void)viewDidLoad
    {
    [super viewDidLoad];

    self.title = @"Library";

    self.library = [[CLibrary alloc] init];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidOpenURL:) name:@"applicationDidOpenURL" object:NULL];

    [self.library scanDirectories];
    [self.collectionView reloadData];
    }

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
    {
    return (YES);
    }

#pragma mark - Table view data source

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section;
    {
    return([self.library.URLs count]);
    }

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath;
    {
    NSURL *theURL = self.library.URLs[indexPath.item];
    CPDFDocument *theDocument = [[CPDFDocument alloc] initWithURL:theURL];

    CPreviewCollectionViewCell *theCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CELL" forIndexPath:indexPath];
    UIImage *theImage = theDocument.coverImage;
    theCell.imageView.image = theImage;
    return(theCell);
    }

#pragma mark - Table view delegate

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
    {
    CPDFDocumentPageViewController *theDestination = segue.destinationViewController;
//    theDestination.magazineMode = NO;

    NSIndexPath *indexPath = [self.collectionView indexPathForCell:sender];

    NSURL *theURL = (self.library.URLs)[indexPath.row];
    theDestination.documentURL = theURL;
    }

- (void)applicationDidOpenURL:(NSNotification *)inNotification
    {
//    [self scanDirectories];
//    [self.tableView reloadData];
//
//    NSURL *theURL = [inNotification userInfo][@"URL"];
//    CPDFDocumentViewController *theViewController = [[CPDFDocumentViewController alloc] initWithURL:theURL];
//    if (self.navigationController.topViewController == self)
//        {
//        [self.navigationController pushViewController:theViewController animated:YES];
//        }
//    else
//        {
//        [self.navigationController setViewControllers:@[self, theViewController] animated:YES];
//        }
    }

@end