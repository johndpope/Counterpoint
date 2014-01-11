//
//  GoogleMusicController.h
//  Counterpoint
//
//  Created by Becky on 12/11/13.
//  Copyright (c) 2013 Beckasaurus. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GoogleMusicController : NSObject <NSURLConnectionDelegate>

@property (nonatomic, retain) NSString* username;
@property (nonatomic, retain) NSString* password;

@property (nonatomic, retain) NSString* authenticationToken;
@property (nonatomic, retain) NSString* xtToken;
@property (nonatomic, retain) NSString* nextPageToken;
@property (nonatomic, retain) NSString* finalResponse;

@property (nonatomic) NSInteger requestStage;

@property (nonatomic, retain) NSMutableArray* songArray;

-(BOOL)loginWithUsername:(NSString*)username password:(NSString*)password;
-(NSString*)getStreamUrl:(NSString*)songID;
-(void)loadTracks;

@end

//Sample song structure
/*
 
 {
 album = "Live At The Royal Albert Hall";
 albumArtRef =     (
 {
 url = "http://lh5.ggpht.com/h1D6CydsUS0-3t9qp4wzpKjcbj3ZX1HNExEagA4OhPK5aFCEPF88rm8Jko0";
 }
 );
 albumArtist = "";
 albumId = B267ue4pwugvncxajh5posunrau;
 artist = Adele;
 artistArtRef =     (
 {
 url = "http://lh3.ggpht.com/gFUVKoHfRT2U8U-J_S1iYRveT0vTWgkS-vqh4RGYW1PRah1XHj2_62SGD4CadS0EyJ96J7uPNw";
 }
 );
 artistId =     (
 A6zfmftoiq7nkq4xqpqauep73ue
 );
 beatsPerMinute = 81;
 clientId = WZlrwLTLuLuy1agFzOgaGg;
 comment = "";
 composer = "";
 creationTimestamp = 1383599881435166;
 deleted = 0;
 discNumber = 1;
 durationMillis = 236000;
 estimatedSize = 7172376;
 genre = "R&B";
 id = "e2e741e0-6046-3316-9bfd-f963ccdec7dd";
 kind = "sj#track";
 lastModifiedTimestamp = 1383600375884719;
 nid = T4zyinhinxumz4y5mrbb2xeaegq;
 playCount = 2;
 rating = 0;
 recentTimestamp = 1383600375736000;
 title = "I'll Be Waiting";
 totalDiscCount = 1;
 totalTrackCount = 17;
 trackNumber = 2;
 year = 2011;
 }
 
 */
