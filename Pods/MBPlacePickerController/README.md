MBPlacePicker
======================

A view controller for picking a location. I wrote it to be a simple wrapper around automatic location detection, but also to offer manual location selection in case GPS isn't available.

Screenshots
---
There are more screenshots in the [screenshots folder](/screenshots).

![Jerusalem](screenshots/2.2.0/Readme/Default-Dark.png)
![Permissions 7](screenshots/2.2.0/Readme/Permissions7.png)
![Prompt](screenshots/2.2.0/Readme/Permissions8.png)
![Automatic](screenshots/2.2.0/Readme/Search.png)

Getting Started
---
You'll need to find the `MBPlacePickerController` subfolder in the repository and add it to your project. CocoaPods support is experimental, with the following line: 

	pod 'MBPlacePickerController', '~>2.3.1'

Dependencies
---
`MBPlacePickerController` was built in Objective-C with the iOS 7 SDK, ARC, and Core Location. As of version 2.2.0, MBPlacePickerController requires the iOS 8 SDK, but will work with iOS 7. (The 2.0.0 release was not comptible with iOS 7. Earlier and later releases are.)

Relevant Files
---
Whatever's in the `MBPickerController` folder. It's got a few folders in there, including `CRLCoreLib`, `Place Picker`, `Map View`, and `Resources`. Take all of the folders in 
there and add them to your project.

Configuring MBPlacePickerController:
---
For iOS 8, you need to add one of the following keys to your application's Info.plist.

If you want MBPlacePicker to request "always authorized" permissions, add `NSLocationAlwaysUsageDescription` to your Info.plist. This is identical to the iOS 7 `kCLAuthorizationStatusAuthorized` behavior. 

If you want `MBPlacePicker` to request "when-in-use" permissions, add the `NSLocationWhenInUseUsageDescription`key to your Info.plist.

**Note:** If you want to show the app's name in your description, use ${PRODUCT_NAME}, as shown in the following example:

> NSLocationWhenInUseUsageDescription | ${PRODUCT_NAME} needs your location to work correctly. 

Support for App Extensions:
---

If you want the place picker's cached location to be visible to your app extensions, set the `defaultsSuiteName` property on the place picker to match whatever your app group id is. 

Showing a Picker
---
To show a place picker, you need to follow three easy steps:

	// Step 0: Import the header.
	#import "MBPlacePickerController.h"
	
	// Step 1: Access the singleton picker
	MBPlacePickerController *picker = [MBPlacePickerController sharedPicker];
	
	// Step 2: Display the Picker
	[picker display];
	
That's it!

Picking A Place
---

To get a location when the user picks one, or to get a location when automatic updates come back, assign a delegate to the place picker. You'll need to implement one delegate method to catch those location updates. Assume the picker from "Showing a Picker," your code should look like the following:

	picker.delegate = self;	// Could be anything, really.
	
	
In your delegate, implement this one crazy method that handles almost all the work for you!

	- (void)placePickerController:(MBPlacePickerController *)placePicker didChangeToPlace:(CLLocation *)place
	{
		//	Do something with the location.
	}

This method will fire whenever the user taps a place, or when Core Location passes a location back to the picker.

About the Places and Sorting Them:
===

The list of places is something I compiled a while back. If you want to change it, you have two options. 

1. You can edit the list of locations directly. Inside the `Resources` folder, there's a file named `locations.json`. 

2. You can keep the list fresh by keeping the latest version on your server. Set a string value to the `serverURL` property on the picker to tell it where to look. It will update whenever its `viewDidAppear` method is called. 

In either case, you're going to want to follow the following convention for each location:

	{
 	"name" : "Boston, Massachusetts, USA",	// City name
	"longitude" : -71.0597732,	//	Longitude
  	"latitude" : 42.3584308,	//	Latitude
  	"continent" : "North America"	//	Continent
  	}
  	

If you don't provide a properly capitalized continent, the continent sorting will break. Valid continents are technically any string, but you should use these:

	"North America"
	"Central America"
	"South America"
	"Africa"
	"Asia"
	"Europe"
	"Antarctica"



About the Singleton
---

**Note:** You don't have to create a singleton picker, but if you want to use it to get a continuous stream of location updates across various parts of your app, or use  the cached location, it's best to use the singleton for consistency. 

If you're not into that, just call `alloc] init]` instead. 

Extras
===
These are some nicities that exist for your fun and pleasure.

Automatic Location Updates
---
To get automatic location updates, call `enableAutomaticUpdates` on your picker. Note that in the event that a user selects a location, `disableAutomaticUpdates` will be called, and you'll have to re-enable automatic updates if you want them. You can call `disableAutomaticUpdates` by yourself if you'd like.

	[picker enableAutomaticUpdates];	
	
The corollary of that is disabling the automatic updates:

	[picker disableAutomaticUpdates];


Customizing the Marker Color:
---

To customize the color of the marker that the map uses to show a manually chosen location, set the `markerColor` property of the picker's map view. (The automatic location marker is always purple.)

	picker.map.markerColor = [UIColor orangeColor]; // Sets the marker to Orange.

Customizing the Marker Size:
---
To customize the size of the marker that the map uses to show a manually chosen location, set the `markerDiameter` property.

	picker.map.markerDiameter = 30.0f; // Sets the marker to 30.0f. (30 is default size.)
	
Showing or Hiding User Location:
---
The map view has a toggle for displaying user location (even if the location is manual.) The user's location is indicated by a purple circle.

	picker.map.showUserLocation = YES;	// Enables user location.

Search
---
Search is included for free in 2.2.0. You can turn it on and off by setting the `showSearch` property of the `MBPlacePickerController`. The default value is `YES`.

License
---
The source code here is released under the MIT License. See [LICENSE](/LICENSE) for details. 

Special Thanks
---
This one goes out to Randall Munroe, because without [XKCD #977](http://xkcd.com/977/), I'd still be searching the internet for the [Plate Carrée map projection](http://en.wikipedia.org/wiki/Equirectangular_projection). That's the one where pixels equal latitude and longitude points. I had seen [this video](http://www.upworthy.com/we-have-been-mislead-by-an-erroneous-map-of-the-world-for-500-years?c=ufb7) before, but watching it again after seeing the xkcd made me laugh out loud.

The [map image I used](http://simple.wikipedia.org/wiki/Equirectangular_projection#mediaviewer/File:Equirectangular-projection.jpg) comes from Wikipedia, and according to Wikipedia, is in the public domain.

The image used in the app icon is "[Arrow by Alexander Smith](http://thenounproject.com/term/arrow/49558/) from The Noun Project." (They made me write that, but I'm happy to share good work.)

