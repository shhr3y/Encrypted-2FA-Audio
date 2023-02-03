# Encrypted-2FA-Audio

This repository contains the code for the Offline Two-Factor Authentication using Audio project done for CS 598 EKS Smart cities, homes and beyond under Prof. Elahe Soltanaghai. The project demonstrates offline audio based 2FA working between a web application that allows users to autheticate into 3rd party website and iOS App which works as a authenticator device not dependent on network connection for authetication.

## Getting Started
Follow these steps to install and run the sample app:

Clone the repository:
`git clone https://github.com/18suresha/5982FAProject.git`

## iOS App
This app acts as the authenticator in the transaction. For the first time when users launches the app it will need a active internet connection for registeration process but after finishing, it wont need internet access.

**Prerequisites**  
Xcode

### Installation
* `cd 5982FAProject/iOS`

* run `pod install`

* now, open Audio2FA.xcodeproj file in the Xcode

* pass your App-ID in the AppDelegate file, and run the app.


## Web App
This acts as authenticating party in the transaction. when a user tries to authenticate, this will interact with authenticator for authentication.

**Prerequisites**   
Node.js   
npm (comes with Node.js)

### Running the server

In the `WebApp` folder, open up `index.html` in a Google Chrome browser.

Once you open the web app, login with your email and password, a popup will open up, click `Start Capturing`, and play the audio on your phone by clicking the button in the app. The popup should disappear and you should be redirected to the main webpage with a successful login message.

These instructions will get you a copy of the project up and running on your local machine for development and testing purposes.

## Authors
**18suresha**  
**shhr3y**  
**NamrataVajrala**  


More information regarding this project can be found in the info_paper.pdf attached.
