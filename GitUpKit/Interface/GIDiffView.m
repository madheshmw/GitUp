//  Copyright (C) 2015-2018 Pierre-Olivier Latour <info@pol-online.net>
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>.

#if !__has_feature(objc_arc)
#error This file requires ARC
#endif

#import "GIPrivate.h"

#define kTextFontSize 10
#define kTextLineHeightPadding 3
#define kTextLineDescentAdjustment 1

CFDictionaryRef GIDiffViewAttributes = nil;

CTLineRef GIDiffViewAddedLine = NULL;
CTLineRef GIDiffViewDeletedLine = NULL;

CGFloat GIDiffViewLineHeight = 0.0;
CGFloat GIDiffViewLineDescent = 0.0;

const char* GIDiffViewMissingNewlinePlaceholder = "🚫\n";

@implementation GIDiffView

+ (void)initialize {
  GIDiffViewAttributes = CFBridgingRetain(@{(id)kCTFontAttributeName : [NSFont userFixedPitchFontOfSize:kTextFontSize], (id)kCTForegroundColorFromContextAttributeName : (id)kCFBooleanTrue});

  CFAttributedStringRef addedString = CFAttributedStringCreate(kCFAllocatorDefault, CFSTR("+"), GIDiffViewAttributes);
  GIDiffViewAddedLine = CTLineCreateWithAttributedString(addedString);
  CFRelease(addedString);

  CFAttributedStringRef deletedString = CFAttributedStringCreate(kCFAllocatorDefault, CFSTR("-"), GIDiffViewAttributes);
  GIDiffViewDeletedLine = CTLineCreateWithAttributedString(deletedString);
  CFRelease(deletedString);

  CGFloat ascent;
  CGFloat descent;
  CGFloat leading;
  CTLineGetTypographicBounds(GIDiffViewAddedLine, &ascent, &descent, &leading);
  GIDiffViewLineHeight = ceilf(ascent + descent + leading) + kTextLineHeightPadding;
  GIDiffViewLineDescent = ceilf(descent) + kTextLineDescentAdjustment;
}

- (void)_windowKeyDidChange:(NSNotification*)notification {
  if ([self hasSelection]) {
    [self setNeedsDisplay:YES];  // TODO: Only redraw what's needed
  }
}

- (void)viewDidMoveToWindow {
  [super viewDidMoveToWindow];

  if (self.window) {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_windowKeyDidChange:) name:NSWindowDidBecomeKeyNotification object:self.window];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_windowKeyDidChange:) name:NSWindowDidResignKeyNotification object:self.window];
  } else {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSWindowDidResignKeyNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSWindowDidBecomeKeyNotification object:nil];
  }
}

- (void)didFinishInitializing {
  _backgroundColor = NSColor.textBackgroundColor;
}

- (instancetype)initWithFrame:(NSRect)frameRect {
  if ((self = [super initWithFrame:frameRect])) {
    [self didFinishInitializing];
  }
  return self;
}

- (instancetype)initWithCoder:(NSCoder*)coder {
  if ((self = [super initWithCoder:coder])) {
    [self didFinishInitializing];
  }
  return self;
}

- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self name:NSWindowDidResignKeyNotification object:nil];
  [[NSNotificationCenter defaultCenter] removeObserver:self name:NSWindowDidBecomeKeyNotification object:nil];
}

- (BOOL)isOpaque {
  return YES;
}

- (BOOL)isEmpty {
  [self doesNotRecognizeSelector:_cmd];
  return NO;
}

- (void)didUpdatePatch {
  [self clearSelection];
}

- (void)setPatch:(GCDiffPatch*)patch {
  if (patch != _patch) {
    _patch = patch;
    [self didUpdatePatch];

    [self setNeedsDisplay:YES];
  }
}

- (CGFloat)updateLayoutForWidth:(CGFloat)width {
  [self doesNotRecognizeSelector:_cmd];
  return 0.0;
}

- (void)drawRect:(NSRect)dirtyRect {
  [self doesNotRecognizeSelector:_cmd];
}

- (BOOL)hasSelection {
  [self doesNotRecognizeSelector:_cmd];
  return NO;
}

- (BOOL)hasSelectedText {
  [self doesNotRecognizeSelector:_cmd];
  return NO;
}

- (BOOL)hasSelectedLines {
  [self doesNotRecognizeSelector:_cmd];
  return NO;
}

- (void)clearSelection {
  [self doesNotRecognizeSelector:_cmd];
}

- (void)getSelectedText:(NSString**)text oldLines:(NSIndexSet**)oldLines newLines:(NSIndexSet**)newLines {
  [self doesNotRecognizeSelector:_cmd];
}

- (BOOL)acceptsFirstResponder {
  return YES;
}

- (BOOL)becomeFirstResponder {
  if (self.hasSelection) {
    [self setNeedsDisplay:YES];
  }
  return YES;
}

- (BOOL)resignFirstResponder {
  if (self.hasSelection) {
    [self setNeedsDisplay:YES];
  }
  return YES;
}

- (BOOL)validateUserInterfaceItem:(id<NSValidatedUserInterfaceItem>)item {
  if (item.action == @selector(copy:)) {
    return [self hasSelection];
  }

  return NO;
}

- (void)copy:(id)sender {
  [[NSPasteboard generalPasteboard] declareTypes:@[ NSPasteboardTypeString ] owner:nil];
  NSString* text;
  [self getSelectedText:&text oldLines:NULL newLines:NULL];
  [[NSPasteboard generalPasteboard] setString:text forType:NSPasteboardTypeString];
}

@end
