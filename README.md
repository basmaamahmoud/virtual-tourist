# virtual-tourist

## Description
- It allows users to tour the world without leaving the comforts of their couch.
- It allows you to drop pins on a map and pull up Flickr images associated with that location.
- Locations and images are stored using Core Data.

## Setup
- In this application i used mapkit.
- Core Data was used to store selected locations.
- You need to get flickr.photos.search api key from "https://www.flickr.com/services/api/flickr.photos.search.html"

## How to run it

- When the app first starts it will open to the map view. Users will be able to zoom and scroll around.
- Tapping and holding the map drops a new pin, you can place any number of pins on the map.
- When a pin is tapped, the app will navigate to the Photo Album view associated with the pin.
- Once the images have all been downloaded, the app should enable the New Collection button at the bottom of the page. Tapping this button will empty the photo album and fetch a new set of images.
- you can remove photos from an album by tapping them. Pictures will flow up to fill the space vacated by the removed photo.
- Tapping the back button will return you to the Map view.

## Images for the App

![simulator screen shot - iphone 8 plus - 2018-08-10 at 14 50 37](https://user-images.githubusercontent.com/35192412/43958814-061ecd84-9cad-11e8-8745-012c6fe1caa9.png)    ![simulator screen shot - iphone 8 plus - 2018-08-10 at 14 48 03](https://user-images.githubusercontent.com/35192412/43958815-070e5df4-9cad-11e8-9f77-65e494a60532.png)
![simulator screen shot - iphone 8 plus - 2018-08-10 at 14 48 07](https://user-images.githubusercontent.com/35192412/43958820-080f7e7c-9cad-11e8-9566-7f0c9ca0a64c.png)    ![simulator screen shot - iphone 8 plus - 2018-08-10 at 14 52 53](https://user-images.githubusercontent.com/35192412/43958869-2d0b744c-9cad-11e8-842c-c9140d6939ab.png)


