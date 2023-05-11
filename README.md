# FootPrint 👣 📸

FootPrint is a work-in-progress iOS app built entirely in SwiftUI. 
It helps you track your walking activity by fetching images from [Flickr Search API](https://www.flickr.com/services/api/flickr.photos.search.html) 
based on your current location coordinate for every 100 meters you walk. 
This way, you can view a gallery of photos from places you've been without even having to take out your camera!

### 📱 Screenshots 

<p align="left">
<img src="https://github.com/Sa74/FootPrint/blob/main/Screenshots/StartActivity.png" alt="Start Activity" width="200"/>
<img src="https://github.com/Sa74/FootPrint/blob/main/Screenshots/DuringActivity.png" alt="During Activity" width="200"/>
<img src="https://github.com/Sa74/FootPrint/blob/main/Screenshots/AfterActivity.png" alt="After Activity" height="400" width="205"/>
</p>

## 🏗 Architecture
The codebase follows the **MVVM (Model-View-ViewModel)** architecture pattern. 
The app is split into three main layers: the Presentation layer, the Domain layer, and the Data layer.

### Presentation Layer
The Presentation layer consists of **SwiftUI** views that display data and handle user interactions. 
The views are connected to their corresponding view models via the **@StateObject** property wrapper.

### Domain Layer
The Domain layer contains the business logic of the app. 
It includes the **ActivityTrackingController** class, which is responsible for tracking user walking activity and triggers actions.

### Data Layer
The Data layer handles network requests and data storage. 
It includes the **FlickerPhotoDownloader** struct, which fetches photos from the Flickr API, and the **AsyncImage**, handles loading and caching images.

## 🌐 Network Layers
The network layer of the app is powered by the **URLSession** API, which is used to fetch data from the Flickr API. 
The **NetworkHandler** class encapsulates the networking logic and maps the response data to any Decodable model using the **Combine** framework.

## 🧪 Test Suits
The codebase also includes a comprehensive test suite using **XCTest** framework. 
The tests cover different parts of the app, including the network layer and view models.

## 📝 License
This project is licensed under the MIT License. See the [LICENSE](https://github.com/Sa74/FootPrint/blob/main/LICENSE) file for details.

## 🙏 Acknowledgements
FootPrint was inspired by the concept of **'PhotoWalking'** - a popular activity among photographers. 
Special thanks to the Flickr API for providing a great source of photos for the app.

